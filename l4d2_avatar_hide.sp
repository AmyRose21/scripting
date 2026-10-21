/*
 * ============================================================================
 * l4d2_avatar_hide.sp — [L4D2] Modo Avatar: ocultar equipo del cuerpo
 * ============================================================================
 *
 * PROPOSITO
 *   Cuando el "Modo Avatar" del Sonic Manager está activo, los supervivientes
 *   son personajes de Sonic y no deben mostrar NADA de equipo encima:
 *   ni armas en la espalda, ni arma en mano, ni botiquín, ni pastillas,
 *   ni lanzables, ni bidones. Aplica al jugador local Y a los bots/aliados.
 *   La vista en 1ª persona (viewmodel) NO se toca.
 *
 * POR QUE EL INTENTO ANTERIOR NO FUNCIONABA
 *   En L4D2 los objetos de la espalda/cinturón NO son las entidades de arma:
 *   el CLIENTE los dibuja según los bits del netprop "m_iAddonBits" del
 *   JUGADOR. Por eso hacer SetEntityRenderMode() sobre las armas no ocultaba
 *   nada. (Técnica descubierta gracias a "l4d_display_equipments" de Marttt.)
 *
 * TÉCNICA (doble)
 *   1) m_iAddonBits = 0 en SDKHook_PostThinkPost  ->  oculta TODO lo de la
 *      espalda/cinturón (primaria enfundada, secundaria, lanzables,
 *      botiquín/desfibrilador, pastillas/adrenalina, packs, diésel).
 *   2) SDKHooks_SetTransmit en las entidades de arma  ->  oculta el arma que
 *      llevan EN LA MANO (la entidad nunca llega al cliente = nunca se dibuja,
 *      es 100% fiable). Al soltarla al suelo, vuelve a ser visible.
 *
 * USO
 *   sm_avatarhide <objetivo> <1|0>
 *       Ejemplos:  sm_avatarhide @all 1     (todos)
 *                  sm_avatarhide #15 1      (por userid)
 *                  sm_avatarhide Nick 0     (por nombre)
 *   (También se puede llamar desde otro plugin, ver abajo.)
 *
 * INTEGRACIÓN EN SONIC MANAGER (una línea en cada sitio)
 *   Al ACTIVAR el avatar:     ServerCommand("sm_avatarhide #%d 1", GetClientUserId(client));
 *   Al DESACTIVAR el avatar:  ServerCommand("sm_avatarhide #%d 0", GetClientUserId(client));
 *   (Si el avatar se aplica a todos de golpe: ServerCommand("sm_avatarhide @all 1"); )
 *
 * CVARS  (cfg/sourcemod/l4d2_avatar_hide.cfg)
 *   l4d2_avatarhide_enable  1  — 1=plugin activo, 0=apagado (todo vuelve a verse)
 *   l4d2_avatarhide_own    1  — 1=ocultar también a MI mi arma activa.
 *                               Si tu contador de munición desapareciera, pon 0.
 * ============================================================================
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0"

#define TEAM_SURVIVOR  2
#define MAX_SLOTS      5      // 0=primaria 1=secundaria 2=lanzable 3=botiquín/defib 4=pastillas/adren 5=objetos (bidón, gnomo...)
#define MAX_ENTS       16384  // para el control de hooks de transmit

// ---- Bits "addon" de L4D2 (mismos valores que l4d_display_equipments) ----
#define ADDON_PRIMARY        (1 << 0)   // arma primaria en la espalda
#define ADDON_SECONDARY      (1 << 1)   // arma secundaria en la cadera
#define ADDON_THROWABLES     (1 << 2)   // lanzables (molotov, pipebomb, biliar)
#define ADDON_KIT_DEFIB_PACK (1 << 3)   // botiquín / desfibrilador / packs de mejora
#define ADDON_PILLS_ADREN    (1 << 4)   // pastillas / adrenalina
#define ADDON_TONGUE         (1 << 5)   // lengua (Smoker; se limpia por si acaso)
#define ADDON_DIESEL         (1 << 7)   // bidones de gasóleo (Hard Rain)

ConVar g_cvEnable;
ConVar g_cvHideOwn;

bool g_bAvatar[MAXPLAYERS + 1];    // modo avatar activo por jugador
int  g_iHookRef[MAX_ENTS];         // ref de entidad que ya tiene el transmit enganchado

// ============================================================================
public Plugin myinfo =
{
    name        = "[L4D2] Modo Avatar — Ocultar equipo del cuerpo",
    author      = "Super Z (técnica addon-bits de Marttt / l4d_display_equipments)",
    description = "Oculta armas, botiquines y objetos del cuerpo de los supervivientes (Modo Avatar Sonic).",
    version     = PLUGIN_VERSION,
    url         = ""
};

// ============================================================================
public void OnPluginStart()
{
    RegAdminCmd("sm_avatarhide", Cmd_AvatarHide, ADMFLAG_GENERIC,
        "sm_avatarhide <#userid|nombre|@all|@survivors> <1|0> — oculta o muestra el equipo del cuerpo");

    g_cvEnable = CreateConVar("l4d2_avatarhide_enable", "1",
        "1=Plugin activo, 0=apagado (todo vuelve a ser visible).", FCVAR_NOTIFY, true, 0.0, true, 1.0);

    g_cvHideOwn = CreateConVar("l4d2_avatarhide_own", "1",
        "1=Ocultar también al dueño su arma activa (recomendado).\nSi tu HUD de munición desaparece, pon 0.", _, true, 0.0, true, 1.0);

    AutoExecConfig(true, "l4d2_avatar_hide");

    // Red de seguridad: re-aplica cada 0.2s (armas nuevas que recojan, cambios de slots, etc.)
    CreateTimer(0.2, Timer_Mantener, _, TIMER_REPEAT);
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
    SDKHook(client, SDKHook_WeaponDropPost, OnWeaponDropPost);
}

public void OnClientDisconnect(int client)
{
    g_bAvatar[client] = false;
}

public void OnMapEnd()
{
    // Las referencias de entidad caducan al cambiar de mapa
    for (int i = 0; i < MAX_ENTS; i++)
        g_iHookRef[i] = 0;
}

// ============================================================================
// Comando: sm_avatarhide <objetivo> <1|0>
// ============================================================================
public Action Cmd_AvatarHide(int client, int args)
{
    if (args < 2)
    {
        ReplyToCommand(client, "[Avatar] Uso: sm_avatarhide <#userid|nombre|@all|@survivors> <1|0>");
        return Plugin_Handled;
    }

    char sTarget[64], sOn[8];
    GetCmdArg(1, sTarget, sizeof(sTarget));
    GetCmdArg(2, sOn, sizeof(sOn));
    bool bOn = (StringToInt(sOn) != 0);

    char sName[MAX_TARGET_LENGTH];
    int  targets[MAXPLAYERS];
    bool bMl;
    int  n = ProcessTargetString(sTarget, client, targets, MAXPLAYERS,
            COMMAND_FILTER_CONNECTED, sName, sizeof(sName), bMl);

    if (n <= 0)
    {
        ReplyToCommand(client, "[Avatar] Objetivo no válido.");
        return Plugin_Handled;
    }

    for (int i = 0; i < n; i++)
        AvatarSet(targets[i], bOn);

    ReplyToCommand(client, "[Avatar] Equipo %s para %d jugador(es).", bOn ? "OCULTO" : "VISIBLE", n);
    return Plugin_Handled;
}

void AvatarSet(int client, bool bOn)
{
    g_bAvatar[client] = bOn;

    if (bOn)
        OcultarEquipo(client);       // efecto inmediato; el timer mantiene el resto
    else
        RestaurarCliente(client);
}

// ============================================================================
// 1) ESPALDA / CINTURÓN — limpiar m_iAddonBits en cada think.
//    El juego re-escribe los bits al recoger/cambiar equipo, por eso hay que
//    hacerlo continuamente (misma técnica que l4d_display_equipments).
// ============================================================================
public void OnPostThinkPost(int client)
{
    if (!g_cvEnable.BoolValue || !g_bAvatar[client])
        return;

    if (GetClientTeam(client) != TEAM_SURVIVOR)
        return;

    if (GetEntProp(client, Prop_Send, "m_iAddonBits") != 0)
        SetEntProp(client, Prop_Send, "m_iAddonBits", 0);
}

// ============================================================================
// 2) ARMA EN MANO — ocultar las entidades de arma (slots 0..5)
// ============================================================================
void OcultarEquipo(int client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != TEAM_SURVIVOR)
        return;

    for (int slot = 0; slot <= MAX_SLOTS; slot++)
    {
        int w = GetPlayerWeaponSlot(client, slot);
        if (w <= MaxClients || !IsValidEntity(w))
            continue;

        OcultarEntidad(w);
    }
}

void OcultarEntidad(int ent)
{
    // a) La entidad nunca se transmite => nunca se dibuja (ni en mano, ni glow, nada).
    //    Esto SIEMPRE funciona, a diferencia de SetEntityRenderMode solo.
    int ref = EntIndexToEntRef(ent);
    if (ent > 0 && ent < MAX_ENTS && g_iHookRef[ent] != ref)
    {
        g_iHookRef[ent] = ref;
        SDKHooks_SetTransmit(ent, Hook_Transmit);
    }

    // b) Refuerzo por si acaso
    SetEntityRenderMode(ent, RENDER_NONE);
    SetEntityRenderColor(ent, 0, 0, 0, 0);
}

// ¿Esta entidad debe verse para este espectador?
public Action Hook_Transmit(int ent, int viewer)
{
    if (!g_cvEnable.BoolValue)
        return Plugin_Continue;

    // Dueño del arma (m_hOwnerEntity) o del prop enganchado (m_hMoveParent)
    int owner = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
    if (owner < 1 || owner > MaxClients)
        owner = GetEntPropEnt(ent, Prop_Data, "m_hMoveParent");

    if (owner < 1 || owner > MaxClients || !g_bAvatar[owner])
        return Plugin_Continue;   // arma en el suelo o de un no-avatar: visible

    // Válvula de escape: el dueño siempre ve SU arma activa (por si el HUD de
    // munición fallara con l4d2_avatarhide_own 0)
    if (!g_cvHideOwn.BoolValue && viewer == owner
        && GetEntPropEnt(owner, Prop_Send, "m_hActiveWeapon") == ent)
        return Plugin_Continue;

    return Plugin_Handled;        // no se dibuja para nadie
}

// ============================================================================
// Red de seguridad: cada 0.2s re-aplica la ocultación
// ============================================================================
public Action Timer_Mantener(Handle timer)
{
    if (!g_cvEnable.BoolValue)
        return Plugin_Continue;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_bAvatar[i] && IsClientInGame(i))
            OcultarEquipo(i);
    }

    return Plugin_Continue;
}

// ============================================================================
// Al soltar un arma: cae al suelo y DEBE volver a verse para todos
// ============================================================================
public void OnWeaponDropPost(int client, int weapon)
{
    if (weapon > MaxClients && IsValidEntity(weapon))
    {
        SetEntityRenderMode(weapon, RENDER_NORMAL);
        SetEntityRenderColor(weapon, 255, 255, 255, 255);
        // El transmit sigue enganchado pero ya no oculta: al no tener dueño,
        // Hook_Transmit devuelve Plugin_Continue automáticamente.
    }
}

// ============================================================================
// Restaurar todo al desactivar el modo avatar
// ============================================================================
void RestaurarCliente(int client)
{
    if (!IsClientInGame(client))
        return;

    // 1) Devolver el render a las armas que lleva
    for (int slot = 0; slot <= MAX_SLOTS; slot++)
    {
        int w = GetPlayerWeaponSlot(client, slot);
        if (w > MaxClients && IsValidEntity(w))
        {
            SetEntityRenderMode(w, RENDER_NORMAL);
            SetEntityRenderColor(w, 255, 255, 255, 255);
        }
    }

    // 2) Reconstruir los bits addon según lo que lleve encima.
    //    (El juego los re-corrige por sí solo la próxima vez que el
    //     inventario cambie; esto es para que se vean YA mismo.)
    if (GetClientTeam(client) == TEAM_SURVIVOR)
    {
        int bits = 0;
        if (GetPlayerWeaponSlot(client, 0) != -1) bits |= ADDON_PRIMARY;
        if (GetPlayerWeaponSlot(client, 1) != -1) bits |= ADDON_SECONDARY;
        if (GetPlayerWeaponSlot(client, 2) != -1) bits |= ADDON_THROWABLES;
        if (GetPlayerWeaponSlot(client, 3) != -1) bits |= ADDON_KIT_DEFIB_PACK;
        if (GetPlayerWeaponSlot(client, 4) != -1) bits |= ADDON_PILLS_ADREN;
        SetEntProp(client, Prop_Send, "m_iAddonBits", bits);
    }
}
