/**
 * anti_caida_avatar_v3.sp
 * Anti Caída por Avatar (v3.3 — +eggman/blaze/silver_avatar_om/_l de los avatares 9o/10o/11o; v3.2 — +cream_avatar_om/_l del 8o avatar; v3.1 — hotfix del crashe masivo) — pedido literal del owner 2026-10-11:
 *   "podrias ponerle el poder antifall al avatar por defecto? para los
 *    que tienen el avatar, y para los que no tienen el avatar, 40% de
 *    reduccion de dano de caida (checa cada 0.1s si tienen avatar; si
 *    no tienen o se lo quitaron, re-ajusta)"
 *
 * REGLA (v3):
 *  - CON avatar vivo = dano de caida 0 (antifall total).
 *  - SIN avatar      = dano de caida x (1 - sm_falldmg_reduce) = 60%
 *                      (40% de reduccion).
 *  - Chequeo cada 0.1s (sm_avatar_fall_check): escanea los props con
 *    los TARGETNAMES EXACTOS que crea el suite (la copia _l SIEMPRE
 *    queda PARENTADA al jugador: prop "moveparent" en L4D2). Si el avatar aparece,
 *    desaparece o lo matan, el estado se RE-AJUSTA al vuelo en el
 *    siguiente chequeo (cambio anotado en el log del servidor).
 *
 * DETECCION 100% AUTOCONTENIDA: cero dependencia del manager, cero
 * natives — lee las entidades del suite igual que su barrido
 * OM_SweepOrphanAvatars (mismos nombres, mismas clases). Con el suite
 * apagado no hay avatares => todos caen en la regla del 40%.
 *
 * v3.0 (suite 3.77.51) sobre la v2.1 del arbol del owner:
 *  - FIX del fallback DMG_FALL de la v2: era (1<<8) que NO es caida
 *    (1<<8 = blast/rocket); el correcto es (1<<5). Con el include de
 *    left4dhooks cargado nunca se activaba el fallback, pero si
 *    alguien compila sin el define quedaba el bug.
 *  - La v2 anulaba la caida PARA TODOS sin distincion; la v3 aplica la
 *    regla por avatar pedida. Para recuperar el comportamiento viejo
 *    (todos inmunes): sm_falldmg_reduce 1.0.
 *  - Supresion de gritos de caida de la v2 INTACTA (forwards del
 *    left4dhooks).
 *
 * v3.1 (2026-10-12, HOTFIX del exception masivo reportado en el log del
 *  server: 'Property "m_hMoveParent" not found (entity 263/prop_dynamic)'
 *  en Timer_AvatarCheck, linea 185, varias veces por segundo):
 *  - CAUSA: la v3.0 leia el parent con GetEntPropEnt(ent, Prop_Send,
 *    "m_hMoveParent"), pero en L4D2 la sendtable NO publica ese nombre
 *    (es el nombre de CS:GO+). El SDK del branch l4d2 lo registra como
 *    SENDINFO_NAME(m_hMoveParent, moveparent) => el prop neteado se
 *    llama "moveparent" (baseentity.cpp:253). El mismo nombre que ya
 *    usan amy_powers.sp:1355, l4d_grenades.sp:3095 y l4d_hats.sp:1352
 *    en ESTE server, sin tronar.
 *  - DAÑO COLATERAL: la exception abortaba el callback ANTES del
 *    re-ajuste => NADIE quedaba marcado con avatar: todos pagaban el
 *    40% en vez de la inmunidad. Ademas, ~10 exceptions/s = ~10 stack
 *    traces/s machacando el log del disco.
 *  - FIX: getter en cascada AntiCaida_GetAvatarParent() con HasEntProp
 *    en cada piso (Send "moveparent" -> Data "m_hMoveParent" [ruta ya
 *    usada por Amy.inc:4669 dentro del suite] -> Data "m_pParent" ->
 *    -1). Imposible de tronar en cualquier rama de Source.
 *  - Cero cambios de regla, convars o timer: mismas reglas v3.
 *
 * Requisitos:
 *  - SourceMod 1.12+ (mismo arbol del suite)
 *  - SDKHooks
 *  - Left4DHooks (para silenciar los gritos, como la v2)
 *
 * Autor: Asistente (v3 sobre la v2.1 del owner)
 */

#include <sourcemod>
#include <sdkhooks>
#include <left4dhooks> // usa tu left4dhooks.inc

#if !defined DMG_FALL
    #define DMG_FALL (1<<5)   // v3 FIX: 1<<5 = caida real (la v2 ponia 1<<8 = blast)
#endif

public Plugin myinfo =
{
    name = "Anti Caida v3.3 (Antifall por Avatar — +Eggman/Blaze/Silver 9o/10o/11o avatares)",
    author = "Asistente",
    description = "Avatar vivo = 0 dano de caida; sin avatar = 40% de reduccion. Re-check cada 0.1s con re-ajuste. v3.1: fix moveparent.",
    version = "3.1",
    url = ""
};

#define SUPPRESS_TIME 1.0 // segundos que suprimimos vocalizaciones tras detectar caida

ConVar gCvar_NoFallDmg;        // master: 0 = plugin apagado (dano vanilla)
ConVar gCvar_SilenceFall;      // gritos (v2, intacto)
ConVar gCvar_Reduce;           // v3: fraccion de reduccion SIN avatar (0.40)
ConVar gCvar_CheckInterval;    // v3: segundos entre chequeos de avatar (0.1)

new bool:g_bSuppressVocalize[MAXPLAYERS+1]; // flag por cliente (v2)
new bool:g_bHasAvatar[MAXPLAYERS+1];        // v3: estado actual por cliente
Handle g_hAvatarTimer = null;               // v3: timer de re-check

// =====================================================================
// v3: TARGETNAMES EXACTOS de todos los avatares que crea el suite —
// copia 1:1 de la lista del OM_SweepOrphanAvatars del manager (actuales
// R/L + bola del spin + legacy de versiones viejas). La copia _l de
// cada personaje SIEMPRE nace parentada al jugador (SetParent
// "!activator"), asi que el parent es la firma fiable de "tiene avatar".
// =====================================================================
static const char g_sAvatarNames[][] = {
    "knuckles_avatar_om",   "knuckles_avatar_om_l",
    "sonic_avatar_om",      "sonic_avatar_om_l",
    "sonic_ball_om",
    "amy_avatar_om",        "amy_avatar_om_l",
    "metal_avatar_om",      "metal_avatar_om_l",
    "tails_avatar_om",      "tails_avatar_om_l",
    "rouge_avatar_om",      "rouge_avatar_om_l",
    "shadow_avatar_om",     "shadow_avatar_om_l",
    "cream_avatar_om",      "cream_avatar_om_l",    // v3.2: 8o avatar (Cream v7.0-OM)
    "eggman_avatar_om",     "eggman_avatar_om_l",   // v3.3: 9o avatar (Eggman v4.0-OM)
    "blaze_avatar_om",      "blaze_avatar_om_l",    // v3.3: 10o avatar (Blaze v1.0-OM, modelo CST)
    "silver_avatar_om",     "silver_avatar_om_l",   // v3.3: 11o avatar (Silver v1.0-OM, modelo CST)
    "tails_avatar",         "tails_avatar_tp",
    "knux_avatar",          "sonicom_avatar",
    "metalom_avatar",       "amyom_avatar"
};

public void OnPluginStart()
{
    gCvar_NoFallDmg = CreateConVar("sm_nofalldmg", "1", "Master: sistema de dano de caida activo (1=Sí, 0=dano vanilla sin tocar)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    gCvar_SilenceFall = CreateConVar("sm_silencefall", "1", "Silenciar gritos de caída (1=Sí, 0=No)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    gCvar_Reduce = CreateConVar("sm_falldmg_reduce", "0.40", "v3: fraccion de reduccion de dano de caida para QUIEN NO TIENE avatar (0.40 = paga el 60%; 1.0 = comportamiento v2: todos inmunes)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    gCvar_CheckInterval = CreateConVar("sm_avatar_fall_check", "0.1", "v3: segundos entre chequeos de avatar (pedido del owner: 0.1)", FCVAR_NOTIFY, true, 0.05, true, 5.0);

    // v3: cambiar el intervalo en caliente reinicia el timer al vuelo
    gCvar_CheckInterval.AddChangeHook(OnCheckIntervalChanged);

    HookEvent("player_spawn", Event_PlayerSpawn_Post, EventHookMode_Post);
    HookEvent("player_disconnect", Event_Player_Disconnect, EventHookMode_Post);

    // Enganchar jugadores ya conectados: SDKHook para daño
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
        }
    }

    AntiCaida_StartAvatarTimer();

    // version de los convars al cargar (para el log)
    LogMessage("[Anti Caida v3.3] Cargado. Avatar=0 dano caida | sin avatar=-%.0f%% (sm_falldmg_reduce %.2f) | check cada %.2fs",
        gCvar_Reduce.FloatValue * 100.0, gCvar_Reduce.FloatValue, gCvar_CheckInterval.FloatValue);
    PrintToServer("[Anti Caida v3.3] Cargado. sm_nofalldmg=%d sm_silencefall=%d sm_falldmg_reduce=%.2f sm_avatar_fall_check=%.2f",
        gCvar_NoFallDmg.IntValue, gCvar_SilenceFall.IntValue, gCvar_Reduce.FloatValue, gCvar_CheckInterval.FloatValue);
}

/*******************************************
 * v3: TIMER DE CHEQUEO DE AVATAR (0.1s)
 * - SIN TIMER_FLAG_NO_MAPCHANGE: con ese
 *   flag el timer moria en el primer cambio
 *   de mapa y nunca revivia. El callback
 *   tolera el cambio de mapa por si solo.
 *******************************************/
void AntiCaida_StartAvatarTimer()
{
    if (g_hAvatarTimer != null)
    {
        KillTimer(g_hAvatarTimer);
        g_hAvatarTimer = null;
    }
    g_hAvatarTimer = CreateTimer(gCvar_CheckInterval.FloatValue, Timer_AvatarCheck, _, TIMER_REPEAT);
}

public void OnCheckIntervalChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    AntiCaida_StartAvatarTimer();
    LogMessage("[Anti Caida v3.3] Intervalo de chequeo: %s -> %s", oldValue, newValue);
}

public void OnMapStart()
{
    // las entidades del suite se re-crean en el mapa nuevo: estado en
    // blanco hasta que el proximo chequeo (0.1s) lo rellene
    for (int i = 1; i <= MaxClients; i++)
        g_bHasAvatar[i] = false;
}

/*******************************************
 * v3.1: GETTER DEL PARENT A PRUEBA DE
 * SENDTABLES DE L4D2 — la v3.0 pregunto
 * por "m_hMoveParent" en Prop_Send y L4D2
 * le tiro la exception a la cara en cada
 * pasada (el nombre neteado real es
 * "moveparent"; "m_hMoveParent" con esa
 * grafia vive en el DATAMAP, no en la
 * sendtable). Este getter pregunta
 * PRIMERO y lee DESPUES, con cascada de
 * 3 pisos: Send "moveparent" ->
 * Data "m_hMoveParent" -> Data "m_pParent".
 *******************************************/
int AntiCaida_GetAvatarParent(int ent)
{
    if (HasEntProp(ent, Prop_Send, "moveparent"))
        return GetEntPropEnt(ent, Prop_Send, "moveparent");

    if (HasEntProp(ent, Prop_Data, "m_hMoveParent"))
        return GetEntPropEnt(ent, Prop_Data, "m_hMoveParent");

    if (HasEntProp(ent, Prop_Data, "m_pParent"))
        return GetEntPropEnt(ent, Prop_Data, "m_pParent");

    return -1;
}

public Action Timer_AvatarCheck(Handle timer)
{
    // estado fresco por pasada; se compara contra el anterior para
    // re-ajustar y anotar SOLO los cambios (nada de spam)
    bool bNew[MAXPLAYERS+1];
    for (int i = 1; i <= MaxClients; i++) bNew[i] = false;

    static const char sClasses[][] = { "prop_dynamic_override", "prop_dynamic" };
    char nameBuf[64];

    for (int c = 0; c < sizeof(sClasses); c++)
    {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, sClasses[c])) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            GetEntPropString(ent, Prop_Data, "m_iName", nameBuf, sizeof(nameBuf));
            if (nameBuf[0] == '\0') continue;

            bool bIsAvatar = false;
            for (int n = 0; n < sizeof(g_sAvatarNames); n++)
            {
                if (StrEqual(nameBuf, g_sAvatarNames[n]))
                {
                    bIsAvatar = true;
                    break;
                }
            }
            if (!bIsAvatar) continue;

            // firma: el avatar parentado a este jugador
            // v3.1: NUNCA en linea recta — el getter en cascada no trona
            int parent = AntiCaida_GetAvatarParent(ent);
            if (parent > 0 && parent <= MaxClients && IsClientInGame(parent))
                bNew[parent] = true;
        }
    }

    // re-ajuste: comparar y anotar los cambios
    for (int i = 1; i <= MaxClients; i++)
    {
        if (bNew[i] == g_bHasAvatar[i]) continue;
        g_bHasAvatar[i] = bNew[i];

        if (!IsClientInGame(i)) continue;
        if (g_bHasAvatar[i])
            LogMessage("[Anti Caida v3.3] %N TIENE avatar -> caida ANULADA (0 dano)", i);
        else
            LogMessage("[Anti Caida v3.3] %N SIN avatar -> caida con -%.0f%% (paga el %.0f%%)",
                i, gCvar_Reduce.FloatValue * 100.0, (1.0 - gCvar_Reduce.FloatValue) * 100.0);
    }

    return Plugin_Continue;
}

/*******************************************
 * Eventos de conexión/desconexión (v2)
 *******************************************/
public void Event_PlayerSpawn_Post(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client))
    {
        SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
        g_bSuppressVocalize[client] = false;
        // el estado de avatar lo rellena el chequeo de 0.1s (nada que
        // hacer aqui: spawn != avatar todavia)
    }
}

public void Event_Player_Disconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
        g_bSuppressVocalize[client] = false;
        g_bHasAvatar[client] = false;
    }
}

bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}

/*******************************************
 * v3: REGLA DE DAÑO POR CAÍDA
 *  - master off (sm_nofalldmg 0) = vanilla
 *  - CON avatar  = 0.0
 *  - SIN avatar  = x (1 - sm_falldmg_reduce)
 *******************************************/
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!IsValidClient(victim))
        return Plugin_Continue;

    if (gCvar_NoFallDmg.IntValue == 0)
        return Plugin_Continue;

    if (damagetype & DMG_FALL)
    {
        if (g_bHasAvatar[victim])
        {
            // antifall del avatar: caida anulada por completo
            damage = 0.0;
            return Plugin_Changed;
        }

        float fReduce = gCvar_Reduce.FloatValue;
        if (fReduce > 0.0)
        {
            damage *= (1.0 - fReduce);
            return Plugin_Changed;
        }
    }

    return Plugin_Continue;
}

/*******************************************
 * Left4DHooks forwards utilizados (v2, INTACTO):
 *  - L4D_OnFalling(int client)
 *  - L4D_OnLedgeGrabbed(int client)
 *  - L4D_OnFatalFalling(int client, int camera)
 *  - L4D_OnSpeakResponseConcept_Pre(int entity)
 *******************************************/

/* Called when CTerrorPlayer::OnFalling() is invoked */
public void L4D_OnFalling(int client)
{
    if (!IsValidClient(client)) return;
    if (gCvar_SilenceFall.IntValue == 0) return;

    // Suprimir vocalizaciones brevemente
    SuppressVocalizeFor(client, SUPPRESS_TIME);
}

/* Called whenever CTerrorPlayer::OnLedgeGrabbed invoked */
public Action L4D_OnLedgeGrabbed(int client)
{
    if (!IsValidClient(client)) return Plugin_Continue;
    if (gCvar_SilenceFall.IntValue == 0) return Plugin_Continue;

    SuppressVocalizeFor(client, SUPPRESS_TIME);
    return Plugin_Continue;
}

/* Called for fatal falling camera - block camera if needed (we don't block camera here) */
public Action L4D_OnFatalFalling(int client, int camera)
{
    if (!IsValidClient(client)) return Plugin_Continue;
    if (gCvar_SilenceFall.IntValue == 0) return Plugin_Continue;

    SuppressVocalizeFor(client, SUPPRESS_TIME);

    return Plugin_Continue;
}

/* Pre-forward fired when the engine will make an entity "speak" a response concept. */
public void L4D_OnSpeakResponseConcept_Pre(int entity)
{
    if (entity <= 0 || entity > MaxClients) return;
    if (!IsValidClient(entity)) return;
    if (gCvar_SilenceFall.IntValue == 0) return;

    if (g_bSuppressVocalize[entity])
    {
        // (comportamiento v2 conservado)
        g_bSuppressVocalize[entity] = false;
    }
}

/* Helper: suprime vocalizaciones para un cliente durante `time` segundos */
stock void SuppressVocalizeFor(int client, float time)
{
    g_bSuppressVocalize[client] = true;
    CreateTimer(time, Timer_ClearSuppress, client, TIMER_FLAG_NO_MAPCHANGE);
}

/* Timer callback para limpiar el flag */
public Action Timer_ClearSuppress(Handle timer, any client)
{
    int cl = client;
    if (cl > 0 && cl <= MaxClients)
    {
        g_bSuppressVocalize[cl] = false;
    }
    return Plugin_Stop;
}
