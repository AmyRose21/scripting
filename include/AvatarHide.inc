// ==================================================================
//  AvatarHide.inc v1.4 — ARMAS/EQUIPO OCULTOS SOLO PARA AVATAR REAL
// ==================================================================
//  v1.4 (manager 3.77.70): la SEÑAL de personaje (AvatarHide_OnCharSignal)
//  ahora oculta el equipo AL INSTANTE también para CREAM / EGGMAN /
//  BLAZE / SILVER — antes esos cuatro solo entraban por el estado REAL
//  del prop que lee el timer de 0.2s (correcto pero con un parpadeo
//  breve al elegir el personaje). El timer se AUTO-CORRIGE igual: si el
//  .mdl no está montado y el avatar nunca aparece, la gracia de 1.5s
//  expira y las armas vuelven solas (cero dependencia intacta).
//  Abajo, el historial completo.
//  [QUE HACE] Cuando un superviviente lleva un AVATAR OM REAL montado
//  (el prop espejo R/L de Sonic / Tails / Knuckles / Amy / Shadow /
//  Rouge / Metal / Cream / Eggman / Blaze / Silver, o la bola de
//  Sonic), TODO su equipo desaparece del
//  cuerpo: armas de la espalda, secundaria de la cintura, botiquin /
//  desfibrilador, pastillas / adrenalina, lanzables y el arma que
//  lleva EN LA MANO (lo que ven los demas y su cuerpo en 3a persona).
//  En cuanto el avatar se quita (elige otro personaje, "Sin personaje",
//  muere o cambia a CST), sus armas y objetos VUELVEN a verse solos.
//
//  [LA REGLA DEL OWNER] "identificar con facilidad quien usa un avatar
//  y quien no": el detector es el ESTADO REAL de los props de avatar
//  del suite —
//    - Avatar OM vivo (Sonic/Tails/Knuckles/Amy/Shadow/Rouge/Metal/
//      Cream/Eggman/Blaze/Silver, + la bola de Sonic mientras rueda)
//                                                   -> equipo OCULTO.
//    - Sin personaje, superviviente normal, CST puro, o personajes
//      SIN avatar-prop (Sally / Sage)              -> equipo VISIBLE.
//  AvatarHide_PlayerHasAvatar(client) es esa consulta, lista para
//  cualquier otro modulo del suite.
//
//  [POR QUE ESTAS DOS TÉCNICAS] (lecciones verificadas en el server)
//   1) ESPALDA/CINTURON: los objetos del cuerpo NO son las entidades
//      de arma; el CLIENTE los dibuja según los bits del netprop
//      "m_iAddonBits" del JUGADOR (técnica del l4d_display_equipments
//      de Marttt). Se limpian a 0 en cada PostThinkPost porque el
//      juego los re-escribe al cambiar el inventario.
//   2) ARMA EN MANO: el cliente la dibuja pegada al hueso de la mano
//      con el WORLD MODEL del arma (m_iWorldModelIndex) — ni el render
//      mode ni el transmit la ocultan. Se pone a 0 (técnica de la
//      pistola fantasma del "Anti_Pose A.sp" del propio owner), con
//      guardado del modelo original por ent-ref para restaurarla al
//      soltarla al suelo (ahi SI se ve, para que otro la recoja).
//  El viewmodel de 1a persona NO se toca (el dueño juega normal);
//  palanca opcional avatarhide_viewmodel 1 para ocultarlo también.
//
//  [INTEGRACION] Identica a PathSense (el patron del último modulo):
//    - #include <AvatarHide>  (en el manager, tras <PathSense>)
//    - AvatarHide_Init()      (en OnPluginStart, ANTES de AutoExecConfig
//                              para que avatarhide_* nazca dentro del
//                              Sonic_Suite.cfg auto-guardado)
//    - AvatarHide_OnCharSignal(client, charIdx)  (en FireCharSignal:
//                              efecto EN EL MISMO FRAME del cambio de
//                              personaje + periodo de gracia anti-
//                              parpadeo mientras la FSM monta el prop)
//
//  [MOTOR] Un timer de 0.2s lee el estado REAL de los props de avatar
//  de todos los jugadores y auto-corrige: monta/desmonta de avatar,
//  respawn, muerte (el avatar se va a ragdoll), armas recogidas,
//  cambio de mapa, desconexiones. No depende de que ninguna señal
//  llegue: si el prop está vivo, oculta; si no, restaura.
//
//  v1.1 — FIX DEL ARMA RECOGIDA DEL SUELO (reporte del owner: "se
//  oculta el arma pero cuando el jugador recoje un arma del suelo
//  sea la que sea esa arma es visible y claro si cambio de arma esta
//  vuelve a ser invisible"). CAUSA: al recoger, el juego EQUIPA Y
//  DESPLIEGA el arma EN EL MISMO FRAME, y el cliente resuelve el
//  world model del arma en ese deploy; el timer de 0.2s ocultaba
//  TARDE — el cliente ya había dibujado el arma con su modelo y no
//  re-lee m_iWorldModelIndex hasta el PRÓXIMO deploy (por eso al
//  cambiar de arma se ocultaba). La receta empírica del propio
//  Anti_Pose A.sp del owner (GiveGhostWeapon: EquipPlayerWeapon y a
//  continuación m_iWorldModelIndex=0 EN EL MISMO FRAME) demuestra
//  que hay que ocultar EN EL MOMENTO DEL EQUIP. FIX: hooks por
//  cliente SDKHook_WeaponEquipPost (mismo frame del equip — cubre
//  recoger del suelo, give de plugins, spawn) + SDKHook_WeaponSwitchPost
//  (mismo frame de cada deploy) + re-ocultación diferida al frame
//  siguiente (por si el deploy re-escribe el worldmodel después del
//  hook). El timer de 0.2s queda como red de seguridad.
//
//  [CVARS] (auto-agregados a cfg/sourcemod/Sonic_Suite.cfg)
//    avatarhide_enable    1 — palanca maestra del sistema
//    avatarhide_viewmodel 0 — 1 = oculta también brazos/arma en 1a
//                             persona del dueño (m_bDrawViewmodel 0)
//
//  [COMANDO] sm_avatarhide (admin) — tabla de estado: quien tiene
//  avatar real ahora mismo y quien está con el equipo oculto.
// ==================================================================

#if defined _avatarhide_inc_included
 #endinput
#endif
#define _avatarhide_inc_included

#define AVATARHIDE_VERSION "v1.3"

// ------------------------------------------------------------------
//  ESTADO
// ------------------------------------------------------------------

#define AH_MAX_ENTS 16384          // tope de índices de entidad (igual que el suite)
#define AH_GRACE    1.5            // segundos de gracia tras la señal: no restaurar
                                    // mientras la FSM monta/desmonta el prop

ConVar g_cvAHEnable;               // avatarhide_enable
ConVar g_cvAHViewModel;            // avatarhide_viewmodel

// SDKHooks de cliente ya puestos (PostThinkPost + WeaponDropPost)
bool  g_bAHHooked[MAXPLAYERS + 1];

// Estado actual de ocultación por jugador (borde del timer)
bool  g_bAHHiding[MAXPLAYERS + 1];

// Hasta cuando NO restaurar aunque el prop este en transición
float g_fAHGrace[MAXPLAYERS + 1];

// Guardado del worldmodel original por entidad (ent-ref con serial)
int   g_iAHTrackedRef[AH_MAX_ENTS];
int   g_iAHOrigWorldModel[AH_MAX_ENTS];

// ------------------------------------------------------------------
//  DETECCION — ¿avatar OM REAL vivo? (LA REGLA DEL OWNER)
// ------------------------------------------------------------------

// ¿Este ent-ref apunta a un prop vivo? (mismo criterio anti-barrido
// de la v3.77.40: solo el 0 es "sin avatar"; los legitimos pueden ser
// negativos por el bit alto del serial)
stock bool AvatarHide_RefAlive(int ref)
{
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    int ent = EntRefToEntIndex(ref);
    return (ent > MaxClients && IsValidEntity(ent));
}

// ¿El jugador lleva un avatar OM real montado AHORA MISMO?
// Sonic/Tails/Knuckles/Amy/Shadow/Rouge/Metal/Cream (prop espejo R/L) o
// la bola de Sonic. Sally/Sage/Eggman van por CST SIN avatar-prop
// -> devuelven false -> sus armas se ven (regla del owner).
stock bool AvatarHide_PlayerHasAvatar(int client)
{
    if (client < 1 || client > MaxClients) return false;

    if (AvatarHide_RefAlive(g_iSonicAvatar[client])  || AvatarHide_RefAlive(g_iSonicAvatarL[client]))  return true;
    if (AvatarHide_RefAlive(g_iSonicBall[client]))   return true;   // rodando = sigue siendo Sonic
    if (AvatarHide_RefAlive(g_iTailsAvatar[client])  || AvatarHide_RefAlive(g_iTailsAvatarL[client]))  return true;
    if (AvatarHide_RefAlive(g_iKnuxAvatar[client])   || AvatarHide_RefAlive(g_iKnuxAvatarL[client]))   return true;
    if (AvatarHide_RefAlive(g_iAmyOMAvatar[client])  || AvatarHide_RefAlive(g_iAmyOMAvatarL[client]))  return true;
    if (AvatarHide_RefAlive(g_iShadowAvatar[client]) || AvatarHide_RefAlive(g_iShadowAvatarL[client])) return true;
    if (AvatarHide_RefAlive(g_iRougeAvatar[client])  || AvatarHide_RefAlive(g_iRougeAvatarL[client]))  return true;
    if (AvatarHide_RefAlive(g_iMetalAvatar[client])  || AvatarHide_RefAlive(g_iMetalAvatarL[client]))  return true;
    if (AvatarHide_RefAlive(g_iCreamAvatar[client])  || AvatarHide_RefAlive(g_iCreamAvatarL[client]))  return true;   // v1.2: 8o avatar
    if (AvatarHide_RefAlive(g_iEggmanAvatar[client]) || AvatarHide_RefAlive(g_iEggmanAvatarL[client])) return true;   // v1.3: 9o avatar (Eggman v4.0-OM)
    if (AvatarHide_RefAlive(g_iBlazeAvatar[client])  || AvatarHide_RefAlive(g_iBlazeAvatarL[client]))  return true;   // v1.3: 10o avatar (Blaze v1.0-OM, modelo CST)
    if (AvatarHide_RefAlive(g_iSilverAvatar[client]) || AvatarHide_RefAlive(g_iSilverAvatarL[client])) return true;   // v1.3: 11o avatar (Silver v1.0-OM, modelo CST)

    return false;
}

// ------------------------------------------------------------------
//  API — init + señal (el manager las invoca)
// ------------------------------------------------------------------

stock void AvatarHide_Init()
{
    g_cvAHEnable = CreateConVar("avatarhide_enable", "1",
        "AvatarHide: 1 = oculta TODO el equipo (armas, botiquin, pastillas, lanzables) de quien lleva un AVATAR OM real; sin avatar las armas se ven.\n0 = sistema apagado (todos ven su equipo).", FCVAR_NOTIFY, true, 0.0, true, 1.0);

    g_cvAHViewModel = CreateConVar("avatarhide_viewmodel", "0",
        "AvatarHide: 1 = oculta TAMBIÉN los brazos y el arma en 1a persona del dueño del avatar.\n0 (recomendado) = el dueño juega normal; solo se oculta lo que ven los demas.", _, true, 0.0, true, 1.0);

    // Tabla de estado para el owner: quien usa avatar real y quien no
    RegAdminCmd("sm_avatarhide", AvatarHide_CmdStatus, ADMFLAG_GENERIC,
        "AvatarHide: tabla de estado (avatar real / equipo oculto por jugador)");

    // El motor: latido de 0.2s que lee el estado REAL de los props
    CreateTimer(0.2, AvatarHide_Timer, _, TIMER_REPEAT);

    // Late-load: enganchar a los que ya están conectados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i)) AvatarHide_HookClient(i);
        else                   g_bAHHooked[i]   = false;
        g_bAHHiding[i] = false;
        g_fAHGrace[i]  = 0.0;
    }
}

// Señal del manager: cambio de personaje EN EL MISMO FRAME. La usamos
// para efecto instantaneo + periodo de gracia (la FSM monta el prop en
// este frame o el siguiente; sin gracia habría un parpadeo de armas).
stock void AvatarHide_OnCharSignal(int client, int charIdx)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
        return;

    if (!g_cvAHEnable.BoolValue) return;

    // ¿El personaje elegido es de los que montan avatar-prop OM?
    // v1.4: CREAM / EGGMAN / BLAZE / SILVER entran a la señal (los 4
    // son seleccionables y montan avatar por selección — el guard
    // aplica su cfg CST y la FSM monta el prop; la gracia cubre la
    // transición y el timer auto-corrige si el .mdl falta)
    bool bCharHasAvatar =
        charIdx == SONIC_INDEX      ||
        charIdx == TAILS_INDEX      ||
        charIdx == KNUCKLES_INDEX   ||
        charIdx == AMY_INDEX        ||
        charIdx == SHADOW_INDEX     ||
        charIdx == ROUGE_INDEX      ||
        charIdx == METALSONIC_INDEX ||
        charIdx == CREAM_INDEX      ||
        charIdx == EGGMAN_INDEX     ||
        charIdx == BLAZE_INDEX      ||
        charIdx == SILVER_INDEX;

    if (bCharHasAvatar)
    {
        g_bAHHiding[client] = true;
        g_fAHGrace[client]  = GetGameTime() + AH_GRACE;   // sin parpadeo
        AvatarHide_Apply(client);
    }
    else
    {
        // "Sin personaje", Sally/Sage (sin avatar-prop), freechars...
        g_bAHHiding[client] = false;
        g_fAHGrace[client]  = 0.0;
        AvatarHide_Restore(client);
    }
}

// ------------------------------------------------------------------
//  MOTOR — latido 0.2s: estado REAL de los props + auto-corrección
// ------------------------------------------------------------------

stock void AvatarHide_HookClient(int client)
{
    if (g_bAHHooked[client]) return;
    g_bAHHooked[client] = true;
    SDKHook(client, SDKHook_PostThinkPost, AvatarHide_PostThinkPost);
    SDKHook(client, SDKHook_WeaponDropPost, AvatarHide_WeaponDropPost);
    // v1.1: EL FIX DEL PICKUP — ocultar EN EL MISMO FRAME del equip y
    // del deploy (el cliente resuelve el world model del arma justo
    // ahi; 0.2s después es TARDE y el arma queda visible hasta el
    // próximo cambio de arma)
    SDKHook(client, SDKHook_WeaponEquipPost,   AvatarHide_WeaponEquipPost);
    SDKHook(client, SDKHook_WeaponSwitchPost,  AvatarHide_WeaponSwitchPost);
}

// v1.1: criterio único para los hooks de evento (mismo frame): el
// estado de borde del timer O el estado REAL del prop (si el avatar
// acaba de montarse y el timer aún no latió, el equip igual oculta)
bool AvatarHide_ShouldHideNow(int client)
{
    if (g_cvAHEnable == null || !g_cvAHEnable.BoolValue) return false;
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return false;
    if (GetClientTeam(client) != 2 || !IsPlayerAlive(client)) return false;
    return g_bAHHiding[client] || AvatarHide_PlayerHasAvatar(client);
}

// v1.1: recoger arma del suelo / give de plugin / armas del spawn —
// el juego EQUIPA en este frame y DESPLIEGA en este mismo frame: el
// worldmodel a 0 YA llega al cliente ANTES de que lo dibuje (la
// receta Anti_Pose del owner)
void AvatarHide_WeaponEquipPost(int client, int weapon)
{
    if (weapon <= MaxClients || !IsValidEntity(weapon)) return;
    if (!AvatarHide_ShouldHideNow(client)) return;
    AvatarHide_HideEnt(weapon);
}

// v1.1: cada deploy/cambio de arma — re-ocultar en el mismo frame (por
// si el deploy del juego re-escribio m_iWorldModelIndex) + refuerzo en
// el frame siguiente (por si la re-escritura llega después del hook)
void AvatarHide_WeaponSwitchPost(int client, int weapon)
{
    if (weapon <= MaxClients || !IsValidEntity(weapon)) return;
    if (!AvatarHide_ShouldHideNow(client)) return;
    AvatarHide_HideEnt(weapon);
    RequestFrame(AvatarHide_RehideFrame, EntIndexToEntRef(weapon));
}

// v1.1: re-ocultación diferida — el frame siguiente al deploy. Mira el
// DUEÑO REAL del arma (por si el frame cambio de manos) y solo actúa
// si sigue siendo un jugador con equipo oculto.
void AvatarHide_RehideFrame(any ref)
{
    int ent = EntRefToEntIndex(ref);
    if (ent <= MaxClients || ent >= AH_MAX_ENTS || !IsValidEntity(ent)) return;

    int owner = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
    if (owner < 1 || owner > MaxClients || !IsClientInGame(owner)) return;
    if (!AvatarHide_ShouldHideNow(owner)) return;

    AvatarHide_HideEnt(ent);
}

Action AvatarHide_Timer(Handle timer)
{
    // Palanca apagada en caliente: restaurar a todos los ocultos
    if (!g_cvAHEnable.BoolValue)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (!IsClientInGame(i)) { g_bAHHooked[i] = false; continue; }
            if (g_bAHHiding[i])
            {
                g_bAHHiding[i] = false;
                g_fAHGrace[i]  = 0.0;
                AvatarHide_Restore(i);
            }
        }
        return Plugin_Continue;
    }

    float now = GetGameTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { g_bAHHooked[i] = false; continue; }   // desconecto -> re-hook al volver

        // Enganchar clientes nuevos sin depender de OnClientPutInServer
        if (!g_bAHHooked[i]) AvatarHide_HookClient(i);

        bool bHasAvatar = AvatarHide_PlayerHasAvatar(i);   // ESTADO REAL

        if (bHasAvatar)
        {
            g_bAHHiding[i] = true;
            g_fAHGrace[i]  = 0.0;
            AvatarHide_Apply(i);          // re-aplica: armas recogidas, cambio de slot...
        }
        else if (g_bAHHiding[i])
        {
            // El prop se fue (murió / cambio de personaje / lo quitaron):
            // restaurar las armas... salvo periodo de gracia (transición
            // de la FSM mientras monta el prop del personaje nuevo).
            if (now >= g_fAHGrace[i])
            {
                g_bAHHiding[i] = false;
                AvatarHide_Restore(i);
            }
        }
    }

    return Plugin_Continue;
}

// ------------------------------------------------------------------
//  TÉCNICA 1 — ESPALDA/CINTURON: m_iAddonBits = 0 en cada think
// ------------------------------------------------------------------

void AvatarHide_PostThinkPost(int client)
{
    if (!g_cvAHEnable.BoolValue || !g_bAHHiding[client]) return;
    if (GetClientTeam(client) != 2) return;              // solo supervivientes

    if (GetEntProp(client, Prop_Send, "m_iAddonBits") != 0)
        SetEntProp(client, Prop_Send, "m_iAddonBits", 0);
}

// ------------------------------------------------------------------
//  TÉCNICA 2 — ARMA EN MANO: m_iWorldModelIndex = 0 (Anti_Pose A.sp)
// ------------------------------------------------------------------

#define AH_SLOT_MAX 5      // 0=primaria 1=secundaria 2=lanzable 3=kit/defib 4=pills/adren 5=carry

void AvatarHide_Apply(int client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2)
        return;

    for (int slot = 0; slot <= AH_SLOT_MAX; slot++)
    {
        int w = GetPlayerWeaponSlot(client, slot);
        if (w > MaxClients) AvatarHide_HideEnt(w);
    }

    if (g_cvAHViewModel.BoolValue && GetEntProp(client, Prop_Send, "m_bDrawViewmodel") != 0)
        SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
}

void AvatarHide_HideEnt(int ent)
{
    if (ent <= MaxClients || ent >= AH_MAX_ENTS || !IsValidEntity(ent)) return;

    int ref = EntIndexToEntRef(ent);

    // Primera vez que tocamos esta entidad: guardar su worldmodel real
    if (g_iAHTrackedRef[ent] != ref)
    {
        g_iAHTrackedRef[ent]     = ref;
        g_iAHOrigWorldModel[ent] = GetEntProp(ent, Prop_Send, "m_iWorldModelIndex");
    }

    if (GetEntProp(ent, Prop_Send, "m_iWorldModelIndex") != 0)
        SetEntProp(ent, Prop_Send, "m_iWorldModelIndex", 0);

    // Refuerzo por si la entidad se dibuja "suelta"
    SetEntityRenderMode(ent, RENDER_NONE);
    SetEntityRenderColor(ent, 0, 0, 0, 0);
}

void AvatarHide_RestoreEnt(int ent)
{
    if (ent <= MaxClients || ent >= AH_MAX_ENTS || !IsValidEntity(ent)) return;

    int ref = EntIndexToEntRef(ent);

    if (g_iAHTrackedRef[ent] == ref && g_iAHOrigWorldModel[ent] != 0)
        SetEntProp(ent, Prop_Send, "m_iWorldModelIndex", g_iAHOrigWorldModel[ent]);

    g_iAHTrackedRef[ent]     = 0;
    g_iAHOrigWorldModel[ent] = 0;

    SetEntityRenderMode(ent, RENDER_NORMAL);
    SetEntityRenderColor(ent, 255, 255, 255, 255);
}

// Al soltar un arma (o morir, que suelta todo): cae al suelo y DEBE
// verse para que otro jugador la recoja.
void AvatarHide_WeaponDropPost(int client, int weapon)
{
    AvatarHide_RestoreEnt(weapon);
}

// ------------------------------------------------------------------
//  RESTAURACION COMPLETA del jugador (perdió el avatar / palanca off)
// ------------------------------------------------------------------

// Bits addon reales según lo que lleva en los slots (para que se vean
// YA mismo; el juego los re-corrige solo en el próximo cambio)
#define AH_ADDON_PRIMARY    (1 << 0)
#define AH_ADDON_SECONDARY  (1 << 1)
#define AH_ADDON_THROW      (1 << 2)
#define AH_ADDON_KITDEFIB   (1 << 3)
#define AH_ADDON_PILLSADREN (1 << 4)

stock void AvatarHide_Restore(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;

    // 1) Devolver el modelo a las armas que lleva
    for (int slot = 0; slot <= AH_SLOT_MAX; slot++)
    {
        int w = GetPlayerWeaponSlot(client, slot);
        if (w > MaxClients) AvatarHide_RestoreEnt(w);
    }

    // 2) Devolver los brazos en 1a persona si los habiamos ocultado
    if (GetEntProp(client, Prop_Send, "m_bDrawViewmodel") == 0)
        SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);

    // 3) Reconstruir los bits addon
    if (GetClientTeam(client) == 2)
    {
        int bits = 0;
        if (GetPlayerWeaponSlot(client, 0) != -1) bits |= AH_ADDON_PRIMARY;
        if (GetPlayerWeaponSlot(client, 1) != -1) bits |= AH_ADDON_SECONDARY;
        if (GetPlayerWeaponSlot(client, 2) != -1) bits |= AH_ADDON_THROW;
        if (GetPlayerWeaponSlot(client, 3) != -1) bits |= AH_ADDON_KITDEFIB;
        if (GetPlayerWeaponSlot(client, 4) != -1) bits |= AH_ADDON_PILLSADREN;
        SetEntProp(client, Prop_Send, "m_iAddonBits", bits);
    }
}

// ------------------------------------------------------------------
//  COMANDO — tabla de estado para el owner
// ------------------------------------------------------------------

Action AvatarHide_CmdStatus(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    PrintToConsole(client, "");
    PrintToConsole(client, "=== AvatarHide %s — estado (avatar real -> equipo oculto) ===", AVATARHIDE_VERSION);
    PrintToConsole(client, "avatarhide_enable : %d | avatarhide_viewmodel : %d",
        g_cvAHEnable.IntValue, g_cvAHViewModel.IntValue);
    PrintToConsole(client, "");

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;

        int idx = g_iPlayerCharIdx[i];
        char sChar[24];
        if (idx >= 0 && idx < MAX_CHARS) strcopy(sChar, sizeof(sChar), g_CharNames[idx]);
        else                             strcopy(sChar, sizeof(sChar), "Sin personaje");

        bool bAvatar = AvatarHide_PlayerHasAvatar(i);
        PrintToConsole(client, "%N  |  %-14s  |  avatar real: %-3s  |  equipo: %s",
            i, sChar, bAvatar ? "SI" : "NO",
            g_bAHHiding[i] ? "OCULTO" : "visible");
    }

    PrintToConsole(client, "");
    return Plugin_Handled;
}
