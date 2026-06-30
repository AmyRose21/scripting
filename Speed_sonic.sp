/*
 * ======================================================
 *  Zapatos de Sonic - Buff de velocidad + Ajuste de gravedad + Color Personalizable
 *  Versión SourceMod (.sp) - PARCHE: corrección de restauración prematura de gravedad
 *  Autor: ChatGPT (GPT-5) - Parche final con manejo robusto de timers y watchdog
 * ======================================================
 */

#if defined _Speed_sonic_included
    #endinput
#endif
#define _Speed_sonic_included


#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

#define PLUGIN_NAME "SonicSpeedBoost"
#define PLUGIN_VERSION "3.1-patched-restore-lagged-gravity-2"

#define SPEED_MULTIPLIER 2.0
#define GRAVITY_SCALE 0.45
#define BUFF_DURATION 21.0
#define COOLDOWN 30.0

new Float:g_fLastUse[MAXPLAYERS + 1];
new Float:g_fOriginalGravity[MAXPLAYERS + 1];
new g_PlayerColor[MAXPLAYERS + 1][4]; // RGBA
Handle g_hTrailTimer[MAXPLAYERS + 1];

Handle g_hColorCookie; // Guardado permanente del color

// Nuevas variables para corregir el bug
new bool:g_bIsBoosted[MAXPLAYERS + 1];
new Float:g_fBuffEnd[MAXPLAYERS + 1];

// Variable para detectar si el plugin fue recargado
new bool:g_bPluginReloaded = false;

// --- NUEVO: manejador del timer de reset (solo 1 por jugador) ---
Handle g_hResetTimer[MAXPLAYERS + 1];

// --- NUEVO: guardado/restauración de m_flLaggedMovementValue previa ---
new Float:g_fPrevLagged[MAXPLAYERS + 1];
new bool:g_bSavedPrevLagged[MAXPLAYERS + 1];

// --- NUEVO: guardado/restauración de m_flGravity previa (snapshot al aplicar) ---
new Float:g_fPrevGravity[MAXPLAYERS + 1];
new bool:g_bSavedPrevGravity[MAXPLAYERS + 1];

// ConVars
Handle g_hCvarDebug = INVALID_HANDLE;
Handle g_hCvarRestoreLagged = INVALID_HANDLE;

// ==========================
// INFORMACIÓN DEL PLUGIN
// ==========================
public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "ChatGPT (GPT-5)",
    description = "Buff de velocidad con rastro colorido y gravedad ajustada (parche robusto)",
    version = PLUGIN_VERSION,
    url = "https://www.sourcemod.net/"
};

// ==========================
// UTILIDADES
// ==========================
void DebugLog(const char[] fmt, any ...)
{
    if (g_hCvarDebug == INVALID_HANDLE || !GetConVarBool(g_hCvarDebug))
        return;

    char buffer[256];
    VFormat(buffer, sizeof(buffer), fmt, 2);
    PrintToServer("[SonicSpeed DEBUG] %s", buffer);
}

// Devuelve el valor de gravedad que corresponde al buff (según snapshot o original)
float GetExpectedBuffGravity(int client)
{
    float base = (g_bSavedPrevGravity[client]) ? g_fPrevGravity[client] : g_fOriginalGravity[client];
    if (base <= 0.0) base = 1.0;
    return base * GRAVITY_SCALE;
}

// ==========================
// INICIO
// ==========================
public void OnPluginStart()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        g_hTrailTimer[i] = INVALID_HANDLE;
        g_hResetTimer[i] = INVALID_HANDLE;
        g_bIsBoosted[i] = false;
        g_fBuffEnd[i] = 0.0;
        g_bSavedPrevLagged[i] = false;
        g_fPrevLagged[i] = 1.0;
        g_bSavedPrevGravity[i] = false;
        g_fPrevGravity[i] = 1.0;
    }
	
    // Marcar como recargado
    g_bPluginReloaded = true;

    // Llamar a la función original del OnPluginStart
    // Tu código aquí para registrar comandos y eventos

    CreateTimer(1.0, Timer_WatchdogCheck, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    RegConsoleCmd("sm_speed", Command_Speed);
    RegConsoleCmd("sm_sonic", Command_Speed);
    RegConsoleCmd("speed", Command_Speed);
    RegConsoleCmd("sonic", Command_Speed);
	RegConsoleCmd("sm_resetspeed", Command_ForceReset);

    RegConsoleCmd("sm_colortrail", Command_ColorMenu);
    RegConsoleCmd("colortrail", Command_ColorMenu);

    HookEvent("player_disconnect", Event_PlayerDisconnect);
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_death", Event_PlayerDeath);

    g_hColorCookie = RegClientCookie("sonic_trail_color", "Color del rastro Sonic", CookieAccess_Public);

    // ConVars: debug y si restauramos lagged movement a su valor previo
    g_hCvarDebug = CreateConVar("sm_sonic_debug", "0", "Enable debug logs for SonicSpeedBoost (0/1)", FCVAR_NONE, true, 0.0, true, 1.0);
    g_hCvarRestoreLagged = CreateConVar("sm_sonic_restore_lagged", "1", "Restore previous m_flLaggedMovementValue instead of forcing 1.0 (0/1)", FCVAR_NONE, true, 0.0, true, 1.0);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && AreClientCookiesCached(i))
        {
            LoadPlayerColor(i);
            PrintToServer("[ZapatosSonic] Configuración recargada para cliente %d al iniciar el plugin.", i);
        }
    }

    PrintToServer("[SonicSpeed] Plugin cargado correctamente (parche aplicado).");
}

public Action Command_ForceReset(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client))
        return Plugin_Handled;

    if (!g_bIsBoosted[client])
    {
        PrintToChat(client, "[ZapatosSonic] No tienes el efecto activo.");
        return Plugin_Handled;
    }

    PrintToChat(client, "[ZapatosSonic] Restaurando manualmente velocidad y gravedad...");
    Timer_ResetStats(INVALID_HANDLE, client);
    return Plugin_Handled;
}


public void OnClientConnected(int client)
{
    if (client <= 0 || client > MaxClients)
        return;

    // Inicializar solo si no hay cookie todavía
    if (!AreClientCookiesCached(client))
    {
        g_PlayerColor[client][0] = 0;
        g_PlayerColor[client][1] = 150;
        g_PlayerColor[client][2] = 255;
        g_PlayerColor[client][3] = 200;

    g_fLastUse[client] = 0.0;
    g_fOriginalGravity[client] = 1.0;
    g_bIsBoosted[client] = false;
    g_fBuffEnd[client] = 0.0;

    if (g_hTrailTimer[client] != INVALID_HANDLE)
    {
        CloseHandle(g_hTrailTimer[client]);
        g_hTrailTimer[client] = INVALID_HANDLE;
    }

    if (g_hResetTimer[client] != INVALID_HANDLE)
    {
        CloseHandle(g_hResetTimer[client]);
        g_hResetTimer[client] = INVALID_HANDLE;
    }

    g_bSavedPrevLagged[client] = false;
    g_fPrevLagged[client] = 1.0;

    g_bSavedPrevGravity[client] = false;
    g_fPrevGravity[client] = 1.0;
}
}

// ==========================
// EVENTOS
// ==========================
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        // CAMBIO: solo actualizar la "gravedad original" si el jugador NO está boosteado.
        if (!g_bIsBoosted[client])
        {
            float g = GetEntPropFloat(client, Prop_Data, "m_flGravity");
            if (g <= 0.0)
                g = 1.0;
            g_fOriginalGravity[client] = g;
            DebugLog("Player %d spawn: gravity snapshot = %.3f", client, g);
        }
        else
        {
            DebugLog("Player %d spawn: boost activo, no sobrescribo gravity original", client);
        }
    }
if (!AreClientCookiesCached(client))
{
    // Todavía no están listas las cookies, esperar a que se cacheen
    DebugLog("Player %d spawn sin cookies cacheadas aún.", client);
}
else
{
    // Asegurar que el color esté cargado si no lo estaba
    char sColor[32];
    GetClientCookie(client, g_hColorCookie, sColor, sizeof(sColor));
    if (sColor[0] != '\0')
    {
        char parts[4][8];
        int count = ExplodeString(sColor, " ", parts, 4, 8);
        if (count >= 4)
        {
            g_PlayerColor[client][0] = StringToInt(parts[0]);
            g_PlayerColor[client][1] = StringToInt(parts[1]);
            g_PlayerColor[client][2] = StringToInt(parts[2]);
            g_PlayerColor[client][3] = StringToInt(parts[3]);
            DebugLog("Player %d -> Color restaurado en spawn desde cookies.", client);
        }
    }
}

}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients)
        return;

    DebugLog("Player %d died: cleaning timers and restoring if needed", client);

    // Cerrar timers del rastro / reset para evitar timers "huérfanos"
    if (g_hTrailTimer[client] != INVALID_HANDLE)
    {
        CloseHandle(g_hTrailTimer[client]);
        g_hTrailTimer[client] = INVALID_HANDLE;
    }

    if (g_hResetTimer[client] != INVALID_HANDLE)
    {
        CloseHandle(g_hResetTimer[client]);
        g_hResetTimer[client] = INVALID_HANDLE;
    }

    // Restauración del m_flLaggedMovementValue según ConVar
    if (g_hCvarRestoreLagged != INVALID_HANDLE && GetConVarBool(g_hCvarRestoreLagged) && g_bSavedPrevLagged[client])
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", g_fPrevLagged[client]);
        DebugLog("Player %d: restored previous m_flLaggedMovementValue = %.3f on death", client, g_fPrevLagged[client]);
    }
    else
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        DebugLog("Player %d: forced m_flLaggedMovementValue = 1.0 on death", client);
    }

    // Restauración del gravity: si tenemos snapshot previa, restaurarla; si no, usar g_fOriginalGravity
    if (g_bSavedPrevGravity[client])
    {
        SetEntPropFloat(client, Prop_Data, "m_flGravity", g_fPrevGravity[client]);
        DebugLog("Player %d: restored previous m_flGravity = %.3f on death", client, g_fPrevGravity[client]);
    }
    else
    {
        if (g_fOriginalGravity[client] <= 0.0)
            g_fOriginalGravity[client] = 1.0;
        SetEntPropFloat(client, Prop_Data, "m_flGravity", g_fOriginalGravity[client]);
        DebugLog("Player %d: restored original gravity fallback = %.3f on death", client, g_fOriginalGravity[client]);
    }

    g_bIsBoosted[client] = false;
    g_fBuffEnd[client] = 0.0;

    // limpiar flags previos
    g_bSavedPrevLagged[client] = false;
    g_fPrevLagged[client] = 1.0;

    g_bSavedPrevGravity[client] = false;
    g_fPrevGravity[client] = 1.0;

    PrintToChat(client, "[ZapatosSonic] Efecto cancelado al morir 💀");
}

public void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        DebugLog("Player %d disconnected: cleaning timers", client);

        if (g_hTrailTimer[client] != INVALID_HANDLE)
        {
            CloseHandle(g_hTrailTimer[client]);
            g_hTrailTimer[client] = INVALID_HANDLE;
        }

        if (g_hResetTimer[client] != INVALID_HANDLE)
        {
            CloseHandle(g_hResetTimer[client]);
            g_hResetTimer[client] = INVALID_HANDLE;
        }

        // No podemos restaurar entprops si el cliente se desconecta (entidad desaparece),
        // pero limpiamos estados para cuando vuelva a conectar.
        g_bIsBoosted[client] = false;
        g_fBuffEnd[client] = 0.0;
        g_fLastUse[client] = 0.0;
        g_fOriginalGravity[client] = 1.0;

        g_bSavedPrevLagged[client] = false;
        g_fPrevLagged[client] = 1.0;

        g_bSavedPrevGravity[client] = false;
        g_fPrevGravity[client] = 1.0;
    }
}

// ==========================
// CARGA Y GUARDADO DE COOKIES
// ==========================
public void OnClientCookiesCached(int client)
{
    if (!IsClientInGame(client))
        return;

    char sColor[32];
    GetClientCookie(client, g_hColorCookie, sColor, sizeof(sColor));

    if (sColor[0] == '\0')
    {
        // Color por defecto azul
        g_PlayerColor[client][0] = 0;
        g_PlayerColor[client][1] = 150;
        g_PlayerColor[client][2] = 255;
        g_PlayerColor[client][3] = 200;
        SavePlayerColor(client);
        PrintToChat(client, "[ZapatosSonic] Se aplicó el color predeterminado (Azul).");
    }
    else
    {
        char parts[4][8];
        int count = ExplodeString(sColor, " ", parts, 4, 8);
        if (count >= 4)
        {
            g_PlayerColor[client][0] = StringToInt(parts[0]);
            g_PlayerColor[client][1] = StringToInt(parts[1]);
            g_PlayerColor[client][2] = StringToInt(parts[2]);
            g_PlayerColor[client][3] = StringToInt(parts[3]);
        }
        PrintToChat(client, "[ZapatosSonic] Tu color de rastro fue cargado automáticamente.");
    }

    DebugLog("Player %d cookies cargadas: R=%d G=%d B=%d A=%d",
        client,
        g_PlayerColor[client][0],
        g_PlayerColor[client][1],
        g_PlayerColor[client][2],
        g_PlayerColor[client][3]);
}


void SavePlayerColor(int client)
{
    if (!IsClientInGame(client))
        return;

    char sColor[32];
    Format(sColor, sizeof(sColor), "%d %d %d %d",
        g_PlayerColor[client][0],
        g_PlayerColor[client][1],
        g_PlayerColor[client][2],
        g_PlayerColor[client][3]);

    SetClientCookie(client, g_hColorCookie, sColor);
    PrintToChat(client, "[ZapatosSonic] Color guardado permanentemente.");
}

void LoadPlayerColor(int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client))
        return;

    char sColor[64];
    GetClientCookie(client, g_hColorCookie, sColor, sizeof(sColor));

    if (sColor[0] == '\0')
    {
        g_PlayerColor[client][0] = 0;
        g_PlayerColor[client][1] = 150;
        g_PlayerColor[client][2] = 255;
        g_PlayerColor[client][3] = 200;
        return;
    }

    char parts[4][8];
    int count = ExplodeString(sColor, " ", parts, 4, 8);
    if (count >= 4)
    {
        g_PlayerColor[client][0] = StringToInt(parts[0]);
        g_PlayerColor[client][1] = StringToInt(parts[1]);
        g_PlayerColor[client][2] = StringToInt(parts[2]);
        g_PlayerColor[client][3] = StringToInt(parts[3]);
    }
    else
    {
        g_PlayerColor[client][0] = 0;
        g_PlayerColor[client][1] = 150;
        g_PlayerColor[client][2] = 255;
        g_PlayerColor[client][3] = 200;
    }
}

// ==========================
// COMANDO PRINCIPAL
// ==========================
public Action Command_Speed(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client))
    {
        PrintToServer("[ZapatosSonic]  Este comando solo puede usarlo un jugador en el juego.");
        return Plugin_Handled;
    }

    if (!IsPlayerAlive(client))
    {
        PrintToChat(client, "[ZapatosSonic] Debes estar vivo para usar esto.");
        return Plugin_Handled;
    }

    float timeNow = GetEngineTime();
    if (timeNow < g_fLastUse[client] + COOLDOWN)
    {
        float remaining = (g_fLastUse[client] + COOLDOWN) - timeNow;
        PrintToChat(client, "[ZapatosSonic] En enfriamiento. Espera %.1f segundos 🕒", remaining);
        return Plugin_Handled;
    }

    g_fLastUse[client] = timeNow;
    ApplySpeedBoost(client);
    CreateBoostWave(client);
    return Plugin_Handled;
}

// ==========================
// BOOST DE VELOCIDAD
// ==========================
void ApplySpeedBoost(int client)
{
    // Guardar la gravedad ORIGINAL "global" solo la primera vez que se aplica mientras no esté boosteado.
    if (!g_bIsBoosted[client])
    {
        g_fOriginalGravity[client] = GetEntPropFloat(client, Prop_Data, "m_flGravity");
        if (g_fOriginalGravity[client] <= 0.0)
            g_fOriginalGravity[client] = 1.0;
    }

    // --- NUEVO: Guardar el valor previo de m_flLaggedMovementValue si la ConVar lo permite ---
    if (g_hCvarRestoreLagged != INVALID_HANDLE && GetConVarBool(g_hCvarRestoreLagged))
    {
        if (!g_bSavedPrevLagged[client])
        {
            float prev = GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue");
            if (prev <= 0.0) prev = 1.0;
            g_fPrevLagged[client] = prev;
            g_bSavedPrevLagged[client] = true;
            DebugLog("Player %d: saved previous m_flLaggedMovementValue = %.3f", client, prev);
        }
    }
    else
    {
        g_bSavedPrevLagged[client] = false;
    }

    // --- NUEVO: Guardar snapshot de gravity justo al aplicar el buff (si no guardado) ---
    if (!g_bSavedPrevGravity[client])
    {
        float prevG = GetEntPropFloat(client, Prop_Data, "m_flGravity");
        if (prevG <= 0.0) prevG = 1.0;
        g_fPrevGravity[client] = prevG;
        g_bSavedPrevGravity[client] = true;
        DebugLog("Player %d: saved previous m_flGravity = %.3f", client, prevG);
    }

    g_bIsBoosted[client] = true;
    float timeNow = GetEngineTime();
    g_fBuffEnd[client] = timeNow + BUFF_DURATION;

    // Aplicar valores de buff basados en el snapshot de gravedad
    float gravityToApply = GetExpectedBuffGravity(client);

    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", SPEED_MULTIPLIER);
    SetEntPropFloat(client, Prop_Data, "m_flGravity", gravityToApply);

    DebugLog("Player %d: applied lagged=%.3f gravity=%.3f (scale %.3f)", client, SPEED_MULTIPLIER, gravityToApply, GRAVITY_SCALE);

    PrintToChat(client, "[ZapatosSonic] ¡Velocidad activada!");
    PrintCenterText(client, " ¡Velocidad y agilidad aumentadas! ");

    CreateColorTrail(client);

    // Cerrar timer de trail previo si existe
    if (g_hTrailTimer[client] != INVALID_HANDLE)
    {
        CloseHandle(g_hTrailTimer[client]);
        g_hTrailTimer[client] = INVALID_HANDLE;
    }

    g_hTrailTimer[client] = CreateTimer(1.0, Timer_RefreshTrail, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // --- NUEVO: asegurar solo 1 reset-timer por jugador ---
    if (g_hResetTimer[client] != INVALID_HANDLE)
    {
        CloseHandle(g_hResetTimer[client]);
        g_hResetTimer[client] = INVALID_HANDLE;
    }
    // Crear un timer único que se ejecutará cuando DEBE terminar el buff.
    g_hResetTimer[client] = CreateTimer(BUFF_DURATION, Timer_ResetStats, client);
}

// ==========================
// REFRESCAR TRAIL
// ==========================
public Action Timer_RefreshTrail(Handle timer, any data)
{
    int client = data;

    if (client <= 0 || client > MaxClients)
        return Plugin_Stop;
    if (!IsClientInGame(client) || !IsPlayerAlive(client))
        return Plugin_Stop;

    float timeNow = GetEngineTime();
    if (!g_bIsBoosted[client] || timeNow > g_fBuffEnd[client])
        return Plugin_Stop;

    CreateColorTrail(client);
    return Plugin_Continue;
}

// ==========================
// RESTAURAR ESTADÍSTICAS
// ==========================
public Action Timer_ResetStats(Handle timer, any data)
{
    int client = data;
    if (client <= 0 || client > MaxClients)
        return Plugin_Stop;

    // Si el jugador ya no está en el juego, no podemos restaurar entprops.
    // Limpiamos banderas internas y cerramos timers.
    if (!IsClientInGame(client))
    {
        g_bIsBoosted[client] = false;
        g_fBuffEnd[client] = 0.0;
        if (g_hTrailTimer[client] != INVALID_HANDLE)
        {
            CloseHandle(g_hTrailTimer[client]);
            g_hTrailTimer[client] = INVALID_HANDLE;
        }
        g_bSavedPrevLagged[client] = false;
        g_bSavedPrevGravity[client] = false;
        // Este timer termina ahora.
        g_hResetTimer[client] = INVALID_HANDLE;
        return Plugin_Stop;
    }

    // Si el tiempo actual aún es menor que el fin del buff, significa que este timer fue creado
    // antes de una re-aplicación; en ese caso lo reprogramamos para el tiempo restante.
    float timeNow = GetEngineTime();
    if (timeNow < g_fBuffEnd[client])
    {
        float remaining = g_fBuffEnd[client] - timeNow;
        // Añadimos un pequeño margen para evitar que vuelva a dispararse inmediatamente.
        if (remaining < 0.05)
            remaining = 0.05;
        DebugLog("Player %d: Timer_ResetStats fired early; rescheduling in %.3f seconds (timeNow %.3f < buffEnd %.3f)", client, remaining, timeNow, g_fBuffEnd[client]);

        // Cerrar handle actual y crear uno nuevo con el tiempo restante.
        if (g_hResetTimer[client] != INVALID_HANDLE)
        {
            CloseHandle(g_hResetTimer[client]);
            g_hResetTimer[client] = INVALID_HANDLE;
        }
        g_hResetTimer[client] = CreateTimer(remaining + 0.05, Timer_ResetStats, client);
        return Plugin_Stop;
    }

    // RESTAURACIÓN: preferimos restaurar el valor previo de m_flLaggedMovementValue si la ConVar lo permite
    if (g_hCvarRestoreLagged != INVALID_HANDLE && GetConVarBool(g_hCvarRestoreLagged) && g_bSavedPrevLagged[client])
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", g_fPrevLagged[client]);
        DebugLog("Player %d: restored previous m_flLaggedMovementValue = %.3f on buff end", client, g_fPrevLagged[client]);
    }
    else
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        DebugLog("Player %d: forced m_flLaggedMovementValue = 1.0 on buff end", client);
    }

    // Restauración de gravity: preferimos restaurar la snapshot tomada al aplicar el buff
    if (g_bSavedPrevGravity[client])
    {
        SetEntPropFloat(client, Prop_Data, "m_flGravity", g_fPrevGravity[client]);
        DebugLog("Player %d: restored previous m_flGravity = %.3f on buff end", client, g_fPrevGravity[client]);
    }
    else
    {
        if (g_fOriginalGravity[client] <= 0.0)
            g_fOriginalGravity[client] = 1.0;
        SetEntPropFloat(client, Prop_Data, "m_flGravity", g_fOriginalGravity[client]);
        DebugLog("Player %d: restored original gravity fallback = %.3f on buff end", client, g_fOriginalGravity[client]);
    }

    // Marcar timer como terminado
    g_hResetTimer[client] = INVALID_HANDLE;

    g_bIsBoosted[client] = false;
    g_fBuffEnd[client] = 0.0;

    if (g_hTrailTimer[client] != INVALID_HANDLE)
    {
        CloseHandle(g_hTrailTimer[client]);
        g_hTrailTimer[client] = INVALID_HANDLE;
    }

    // limpiar flags y valores previos
    g_bSavedPrevLagged[client] = false;
    g_fPrevLagged[client] = 1.0;

    g_bSavedPrevGravity[client] = false;
    g_fPrevGravity[client] = 1.0;

    PrintToChat(client, "[ZapatosSonic] Velocidad normal restaurada ");
    PrintCenterText(client, " Velocidad restaurada ");
    return Plugin_Stop;
}

// ==========================
// EFECTOS VISUALES
// ==========================
void CreateColorTrail(int client)
{
    int beamModel = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    if (beamModel <= 0)
        return;

    TE_SetupBeamFollow(client, beamModel, 0, 0.6, 10.0, 1.0, 3, g_PlayerColor[client]);
    TE_SendToAll();
}

void CreateBoostWave(int client)
{
    float origin[3];
    GetClientAbsOrigin(client, origin);

    int color[4];
    color[0] = g_PlayerColor[client][0];
    color[1] = g_PlayerColor[client][1];
    color[2] = g_PlayerColor[client][2];
    color[3] = 200;

    int modelIndex = PrecacheModel("materials/sprites/glow.vmt", true);

    TE_SetupBeamRingPoint(origin, 10.0, 400.0, modelIndex, 0, 0, 0, 0.5, 15.0, 2.0, color, 0, 0);
    TE_SendToAll();


    EmitSoundToAll("mobius/sfx/boost.mp3", client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.0);
}

// ==========================
// MENÚ DE COLORES
// ==========================
public Action Command_ColorMenu(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client))
    {
        PrintToServer("[ZapatosSonic]  Este comando solo puede usarlo un jugador.");
        return Plugin_Handled;
    }

    Menu menu = new Menu(MenuHandler_ColorSelect);
    menu.SetTitle(" Elige tu color de rastro:");

    menu.AddItem("255 0 0 200", "Rojo");
    menu.AddItem("0 255 0 200", "Verde");
    menu.AddItem("0 0 255 200", "Azul");
    menu.AddItem("255 255 0 200", "Amarillo");
    menu.AddItem("0 255 255 200", "Cian");
    menu.AddItem("255 0 255 200", "Magenta");
    menu.AddItem("255 165 0 200", "Naranja");
    menu.AddItem("255 192 203 200", "Rosa");
    menu.AddItem("255 255 255 200", "Blanco");
    menu.AddItem("128 0 128 200", "Morado");

    menu.ExitButton = true;
    menu.Display(client, 30);

    return Plugin_Handled;
}

public int MenuHandler_ColorSelect(Menu menu, MenuAction action, int client, int param)
{
    if (action == MenuAction_End)
    {
        delete menu;
    }
    else if (action == MenuAction_Select)
    {
        char info[64];
        menu.GetItem(param, info, sizeof(info));

        char parts[4][8];
        int count = ExplodeString(info, " ", parts, 4, 8);
        if (count >= 4)
        {
            g_PlayerColor[client][0] = StringToInt(parts[0]);
            g_PlayerColor[client][1] = StringToInt(parts[1]);
            g_PlayerColor[client][2] = StringToInt(parts[2]);
            g_PlayerColor[client][3] = StringToInt(parts[3]);
        }

        SavePlayerColor(client);

        PrintToChat(client, "[ZapatosSonic] Color seleccionado: R:%d G:%d B:%d ",
            g_PlayerColor[client][0],
            g_PlayerColor[client][1],
            g_PlayerColor[client][2]);
        PrintCenterText(client, " ¡Color de rastro actualizado! ");
    }
    return 0;
}

// ==========================
// CHAT TRIGGERS
// ==========================
public Action:OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    if (StrEqual(sArgs, "!speed", false) || StrEqual(sArgs, "!sonic", false))
    {
        Command_Speed(client, 0);
        return Plugin_Handled;
    }
    if (StrEqual(sArgs, "!colortrail", false))
    {
        Command_ColorMenu(client, 0);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

// ==========================
// WATCHDOG DE RESTAURACIÓN MEJORADO
// ==========================
public void OnMapStart()
{
    // Timer global que revisa los estados de los jugadores
    CreateTimer(1.0, Timer_WatchdogCheck, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(3.0, Timer_ReloadPlayerColors);
	// Precache de sonidos
	int boostSound = PrecacheSound("mobius/sfx/boost.mp3", true);
}



public Action Timer_WatchdogCheck(Handle timer)
{
    float timeNow = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i))
            continue;

        // Detectar si el jugador tiene un buff vencido sin restaurar
        if (g_bIsBoosted[i])
        {
            // Verificar si el buff ha expirado y si la gravedad sigue siendo 'buffed'
            if (timeNow > g_fBuffEnd[i] + 1.0)
            {
                float currentG = GetEntPropFloat(i, Prop_Data, "m_flGravity");
                float expectedBuffG = GetExpectedBuffGravity(i);

                // Restauramos solo si la gravedad sigue 'buffed'
                if (currentG <= expectedBuffG + 0.01)
                {
                    DebugLog("WATCHDOG: Player %d detected with expired buff and gravity still buffed. Restoring...", i);

                    // Cerrar timers asociados
                    if (IsValidHandle(g_hTrailTimer[i]))
                    {
                        CloseHandle(g_hTrailTimer[i]);
                    }
                    g_hTrailTimer[i] = INVALID_HANDLE;

                    if (IsValidHandle(g_hResetTimer[i]))
                    {
                        CloseHandle(g_hResetTimer[i]);
                    }
                    g_hResetTimer[i] = INVALID_HANDLE;

                    // Restaurar la velocidad y gravedad
                    if (IsPlayerAlive(i))
                    {
                        // Restaurar m_flLaggedMovementValue
                        SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 1.0);

                        // Restaurar gravedad a la original
                        float gravityRestore = (g_bSavedPrevGravity[i]) ? g_fPrevGravity[i] : g_fOriginalGravity[i];
                        if (gravityRestore <= 0.0)
                            gravityRestore = 1.0;
                        SetEntPropFloat(i, Prop_Data, "m_flGravity", gravityRestore);
                        DebugLog("WATCHDOG: Player %d restored gravity to %.3f", i, gravityRestore);
                    }

                    // Limpiar todas las variables internas
                    g_bIsBoosted[i] = false;
                    g_fBuffEnd[i] = 0.0;
                    g_fLastUse[i] = 0.0;

                    g_bSavedPrevLagged[i] = false;
                    g_fPrevLagged[i] = 1.0;

                    g_bSavedPrevGravity[i] = false;
                    g_fPrevGravity[i] = 1.0;

                    // Notificar al jugador
                    if (IsClientInGame(i))
                    {
                        PrintToChat(i, "[ZapatosSonic] ⚙ Tu velocidad fue restaurada automáticamente.");
                        PrintCenterText(i, " Velocidad normal restaurada ");
                        EmitSoundToAll("ambient/energy/zap1.wav", i, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.5);
                    }
                }
            }
        }
    }

    return Plugin_Continue;
}


public void ForceRestoreStats(int client)
{
    if (client <= 0 || client > MaxClients)
        return;

    // Restaurar la gravedad y velocidad forzosamente
    if (g_hCvarRestoreLagged != INVALID_HANDLE && GetConVarBool(g_hCvarRestoreLagged) && g_bSavedPrevLagged[client])
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", g_fPrevLagged[client]);
        DebugLog("ForceRestoreStats: Player %d -> restored laggedMovement=%.3f", client, g_fPrevLagged[client]);
    }
    else
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }

    float gravityRestore = (g_bSavedPrevGravity[client]) ? g_fPrevGravity[client] : g_fOriginalGravity[client];
    if (gravityRestore <= 0.0)
        gravityRestore = 1.0;

    SetEntPropFloat(client, Prop_Data, "m_flGravity", gravityRestore);
    DebugLog("ForceRestoreStats: Player %d -> restored gravity=%.3f", client, gravityRestore);

    // Limpiar el estado del jugador
    g_bIsBoosted[client] = false;
    g_fBuffEnd[client] = 0.0;

    g_bSavedPrevLagged[client] = false;
    g_fPrevLagged[client] = 1.0;

    g_bSavedPrevGravity[client] = false;
    g_fPrevGravity[client] = 1.0;

    PrintToChat(client, "[ZapatosSonic] Velocidad y gravedad restauradas debido a un fallo.");
    PrintCenterText(client, " Velocidad y gravedad restauradas forzosamente ");
}

public Action Timer_ReloadPlayerColors(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && AreClientCookiesCached(i))
        {
            LoadPlayerColor(i);
            DebugLog("Reloaded color for player %d after map start", i);
        }
    }
    return Plugin_Stop;
}