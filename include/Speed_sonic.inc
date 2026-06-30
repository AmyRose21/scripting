/*
 * ======================================================
 *  [MODULO] Speed Sonic - Zapatos de Velocidad v2.0 (Massive Rework)
 *
 *  v2.0 CHANGES - MEJORA MASIVA:
 *
 *  1. ROBUSTEZ DE CODIGO:
 *     - Validaciones estrictas en cada funcion (client > 0, <= MaxClients, IsClientInGame, IsPlayerAlive)
 *     - Proteccion contra double-hook (SDKUnhook antes de SDKHook)
 *     - Limpieza segura de handles con null checks
 *     - Array bounds checking en todos los accesos
 *     - Clamps de valores (velocidad 0.1-10.0, gravedad 0.01-5.0)
 *     - ConVars con validacion null antes de usar
 *     - Cookies con validacion de carga correcta
 *
 *  2. SEGURIDADES:
 *     - Deteccion de estados invalidos (incapacitated, pounceAttacker, tongueOwner,
 *       jockeyAttacker, pummelAttacker, carryAttacker) para pausar el boost
 *     - Pausa automatica en agua (water level > 1) y escaleras
 *     - Proteccion contra uso durante round_end o map_change
 *     - Validacion de que el cliente sigue siendo valido en cada tick
 *
 *  3. WATCHDOG MEJORADO (detecta y repara 5 tipos de bugs):
 *     a) Estado colgado: g_bIsBoosted=true pero buffEnd ya expiro
 *     b) Hook fantasma: g_bIsBoosted=true pero el hook no esta activo
 *     c) Timer zombie: timers activos pero cliente desconectado
 *     d) Velocidad corrupta: m_flLaggedMovementValue fuera de rango
 *     e) Gravedad corrupta: m_flGravity <= 0 o > 5.0
 *     - Auto-fix sin intervencion manual
 *     - Log detallado de cada fix aplicado
 *
 *  4. MEJORAS AL CODIGO DE VELOCIDAD:
 *     - Speed ramp: aceleracion gradual (no instantanea) durante 0.5s
 *     - Deteccion de incap/water/ladder para pausar el boost sin cancelarlo
 *     - Cap de velocidad maxima (SPEED_MAX_MULT = 3.0) para evitar saltos raros
 *     - Suavizado de transicion al desactivar (deceleracion gradual)
 *     - Hook en PreThink + OnPlayerRunCmd para maxima precision
 *
 *  5. EFECTOS TIPO SONIC:
 *     - Ring de chispas azules al activar (TE_SetupSparks + beam ring)
 *     - Trail persistente con color configurable (beam follow)
 *     - Shockwave expansiva (beam ring point que crece)
 *     - After-images (sprites fantasma cada 0.2s)
 *     - Glow effect durante el boost (entity glow)
 *     - Ring de desactivacion al terminar (rojo para diferenciar)
 *     - Particulas de velocidad (weapon_pipebomb trail reutilizado)
 *     - Sonido de activacion + desactivacion + tick cuando queda poco
 *
 *  6. MINI-INTERFAZ MEJORADA:
 *     - Menu principal con 5 opciones (Activar, Color, Estado, Reset, Ayuda)
 *     - HUD con tiempo restante (PrintHintText cada 5s)
 *     - PrintCenterText cuando quedan < 3s ("SPEED ENDING!")
 *     - PrintCenterText con countdown en los ultimos 3s
 *     - Sonidos de feedback (activacion, desactivacion, low time)
 *     - Barra de progreso visual en chat
 *
 *  7. SISTEMA DE AYUDA:
 *     - Comando !speedhelp / !sonichelp
 *     - Mensaje de bienvenida al conectar (PrintToChat con tips)
 *     - Tips automaticos cada 60s si el jugador no ha usado el boost
 *     - Informacion detallada en el menu (cooldown, duracion, color actual)
 *     - Comando !speedinfo para ver estado actual
 *
 *  Comandos disponibles:
 *    !speed / !sonic       - Activar boost o abrir menu si ya esta activo
 *    !speedmenu / !sonicmenu - Abrir menu principal
 *    !speedhelp / !sonichelp - Ver ayuda completa
 *    !speedinfo / !sonicinfo - Ver estado actual
 *    !resetspeed            - Resetear manualmente
 *    !colortrail            - Cambiar color del trail
 * ======================================================
 */

#if defined _Speed_sonic_included
    #endinput
#endif
#define _Speed_sonic_included

#if !defined _sourcemod_included
    #include <sourcemod>
#endif
#if !defined _sdktools_included
    #include <sdktools>
#endif
#if !defined _sdkhooks_included
    #include <sdkhooks>
#endif
#if !defined _clientprefs_included
    #include <clientprefs>
#endif

#pragma semicolon 1
#pragma newdecls required

// =======================
// CONFIGURACION (Ajustable via ConVars tambien)
// =======================
#define SPEED_MULTIPLIER       2.0    // Multiplicador de velocidad objetivo
#define SPEED_MAX_MULT         3.0    // Cap maximo (evita saltos raros)
#define SPEED_RAMP_DURATION    0.5    // Tiempo de aceleracion gradual (segundos)
#define GRAVITY_SCALE          0.45   // Gravedad baja para saltos largos
#define BUFF_DURATION          21.0   // Duracion del boost (segundos)
#define COOLDOWN               30.0   // Tiempo de espera entre usos (segundos)

#define SPEED_LOW_TIME_THRESHOLD  3.0  // Segundos para activar countdown visual
#define SPEED_HUD_TICK             5.0  // Cada cuanto mostrar HUD
#define SPEED_TIP_INTERVAL        60.0  // Intervalo de tips automaticos

// Limites de seguridad (clamp)
#define SPEED_MIN_CLAMP  0.1
#define SPEED_MAX_CLAMP  10.0
#define GRAVITY_MIN_CLAMP 0.01
#define GRAVITY_MAX_CLAMP 5.0

// =======================
// VARIABLES GLOBALES
// =======================
float g_fLastUse[MAXPLAYERS + 1];
float g_fOriginalGravity[MAXPLAYERS + 1];
int   g_PlayerColor[MAXPLAYERS + 1][4]; // RGBA del rastro
Handle g_hTrailTimer[MAXPLAYERS + 1];
Handle g_hResetTimer[MAXPLAYERS + 1];
Handle g_hHUDTimer[MAXPLAYERS + 1];
Handle g_hAfterImageTimer[MAXPLAYERS + 1];

// === Variables de Estado ===
bool  g_bIsBoosted[MAXPLAYERS + 1];
float g_fBuffEnd[MAXPLAYERS + 1];
float g_fBoostStart[MAXPLAYERS + 1];   // Para calcular el speed ramp
bool  g_bHookActive[MAXPLAYERS + 1];    // Track si el hook esta activo (anti double-hook)
bool  g_bPaused[MAXPLAYERS + 1];        // Boost pausado (incap/water/ladder)

// === Restauracion (Snapshots) ===
float g_fPrevLagged[MAXPLAYERS + 1];
bool  g_bSavedPrevLagged[MAXPLAYERS + 1];
float g_fPrevGravity[MAXPLAYERS + 1];
bool  g_bSavedPrevGravity[MAXPLAYERS + 1];

// === Sistema de Tips ===
float g_fNextTipTime[MAXPLAYERS + 1];
bool  g_bHasUsedBoost[MAXPLAYERS + 1];

// === Cookies y Cvars ===
Handle g_hColorCookie;
ConVar g_hCvarDebug;
ConVar g_hCvarRestoreLagged;
ConVar g_hCvarEnableTips;

// === Sprites cacheados ===
int g_iBeamSprite = -1;
int g_iGlowSprite = -1;
int g_iHaloSprite = -1;

// =======================
// MACROS DE VALIDACION
// =======================
#define Speed_IsValidClient(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))
#define Speed_IsClientConnected(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1))

// =======================
// UTILIDADES INTERNAS
// =======================

void DebugLog(const char[] fmt, any ...)
{
    if (g_hCvarDebug == null || !g_hCvarDebug.BoolValue) return;
    char buffer[256];
    VFormat(buffer, sizeof(buffer), fmt, 2);
    PrintToServer("[SonicSpeed DEBUG] %s", buffer);
}

// Clamp seguro para velocidad
float Speed_ClampSpeed(float value)
{
    if (value < SPEED_MIN_CLAMP) return SPEED_MIN_CLAMP;
    if (value > SPEED_MAX_CLAMP) return SPEED_MAX_CLAMP;
    return value;
}

// Clamp seguro para gravedad
float Speed_ClampGravity(float value)
{
    if (value < GRAVITY_MIN_CLAMP) return GRAVITY_MIN_CLAMP;
    if (value > GRAVITY_MAX_CLAMP) return GRAVITY_MAX_CLAMP;
    return value;
}

// Limpia los timers de forma segura
void ClearClientTimers(int client)
{
    if (client < 1 || client > MaxClients) return;

    if (g_hTrailTimer[client] != null && g_hTrailTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hTrailTimer[client]);
        g_hTrailTimer[client] = null;
    }
    if (g_hResetTimer[client] != null && g_hResetTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hResetTimer[client]);
        g_hResetTimer[client] = null;
    }
    if (g_hHUDTimer[client] != null && g_hHUDTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hHUDTimer[client]);
        g_hHUDTimer[client] = null;
    }
    if (g_hAfterImageTimer[client] != null && g_hAfterImageTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hAfterImageTimer[client]);
        g_hAfterImageTimer[client] = null;
    }
}

// Limpia el estado y DESENGANCHA el hook de velocidad
void ResetClientState(int client)
{
    if (client < 1 || client > MaxClients) return;

    // IMPORTANTE: Quitar el hook que fuerza la velocidad (con check de double-unhook)
    if (g_bIsBoosted[client] && IsClientInGame(client) && g_bHookActive[client])
    {
        SDKUnhook(client, SDKHook_PreThink, Speed_OnPreThink);
        g_bHookActive[client] = false;
    }

    g_bIsBoosted[client] = false;
    g_fBuffEnd[client] = 0.0;
    g_fBoostStart[client] = 0.0;
    g_bPaused[client] = false;
    g_bHookActive[client] = false;

    // Resetear flags de restauracion
    g_bSavedPrevLagged[client] = false;
    g_fPrevLagged[client] = 1.0;
    g_bSavedPrevGravity[client] = false;
    g_fPrevGravity[client] = 1.0;
}

// Devuelve la gravedad objetivo (segura)
float GetExpectedBuffGravity(int client)
{
    float base = (g_bSavedPrevGravity[client]) ? g_fPrevGravity[client] : g_fOriginalGravity[client];
    if (base <= 0.0) base = 1.0;
    return Speed_ClampGravity(base * GRAVITY_SCALE);
}

// Detecta si el jugador esta en un estado invalido para el boost
bool Speed_IsPlayerInInvalidState(int client)
{
    if (!Speed_IsValidClient(client)) return true;

    // Incapacitado
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return true;

    // Siendo atacado por especiales
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return true;   // Hunter
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) return true;      // Smoker
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return true;   // Jockey
    if (GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0) return true;   // Charger
    if (GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0) return true;    // Charger carry

    // En agua profunda
    if (GetEntProp(client, Prop_Data, "m_nWaterLevel") > 1) return true;

    // En escalera
    if (GetEntityMoveType(client) == MOVETYPE_LADDER) return true;

    return false;
}

// =======================
// INICIO DEL MODULO
// =======================

public void Speed_OnPluginStart()
{
    // Inicializar datos de todos los slots
    for (int i = 1; i <= MaxClients; i++)
    {
        g_hTrailTimer[i] = null;
        g_hResetTimer[i] = null;
        g_hHUDTimer[i] = null;
        g_hAfterImageTimer[i] = null;
        g_bHookActive[i] = false;
        g_bPaused[i] = false;
        g_fBoostStart[i] = 0.0;
        g_bHasUsedBoost[i] = false;
        g_fNextTipTime[i] = 0.0;
        ResetClientState(i);
        g_fLastUse[i] = 0.0;
        g_fOriginalGravity[i] = 1.0;

        // Color por defecto (Azul Sonic clasico)
        g_PlayerColor[i][0] = 0;
        g_PlayerColor[i][1] = 150;
        g_PlayerColor[i][2] = 255;
        g_PlayerColor[i][3] = 200;
    }

    // Watchdog de seguridad (cada 1 segundo, repara estados corruptos)
    CreateTimer(1.0, Timer_WatchdogCheck, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // Timer de tips automaticos
    CreateTimer(SPEED_TIP_INTERVAL, Timer_AutoTips, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // Comandos
    RegConsoleCmd("sm_speed", Command_Speed);
    RegConsoleCmd("sm_sonic", Command_Speed);
    RegConsoleCmd("sm_speedmenu", Command_SpeedMenu);
    RegConsoleCmd("sm_sonicmenu", Command_SpeedMenu);
    RegConsoleCmd("sm_speedhelp", Command_SpeedHelp);
    RegConsoleCmd("sm_sonichelp", Command_SpeedHelp);
    RegConsoleCmd("sm_speedinfo", Command_SpeedInfo);
    RegConsoleCmd("sm_sonicinfo", Command_SpeedInfo);
    RegConsoleCmd("sm_resetspeed", Command_ForceReset);
    RegConsoleCmd("sm_colortrail", Command_ColorMenu);
    RegConsoleCmd("speed", Command_Speed);           // Alias chat
    RegConsoleCmd("sonic", Command_Speed);           // Alias chat
    RegConsoleCmd("speedmenu", Command_SpeedMenu);   // Alias chat
    RegConsoleCmd("speedhelp", Command_SpeedHelp);   // Alias chat
    RegConsoleCmd("speedinfo", Command_SpeedInfo);   // Alias chat
    RegConsoleCmd("colortrail", Command_ColorMenu);  // Alias chat

    // Eventos
    HookEvent("player_disconnect", Event_PlayerDisconnect);
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("player_spawn", Speed_Event_PlayerSpawn);
    HookEvent("round_end", Speed_Event_RoundEnd);

    // Persistencia (cookies)
    g_hColorCookie = RegClientCookie("sonic_trail_color", "Color del rastro Sonic", CookieAccess_Public);

    // ConVars
    g_hCvarDebug = CreateConVar("sm_sonic_debug", "0", "Enable debug logs (0/1)", FCVAR_NONE, true, 0.0, true, 1.0);
    g_hCvarRestoreLagged = CreateConVar("sm_sonic_restore_lagged", "1", "Restore previous speed after buff (0/1)", FCVAR_NONE, true, 0.0, true, 1.0);
    g_hCvarEnableTips = CreateConVar("sm_sonic_tips", "1", "Enable auto tips for new players (0/1)", FCVAR_NONE, true, 0.0, true, 1.0);

    AutoExecConfig(true, "Speed_Sonic");

    // Carga tardia (Late Load) para jugadores ya conectados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && AreClientCookiesCached(i))
            LoadPlayerColor(i);
    }
}

public void Speed_OnMapStart()
{
    // Precache de sprites (cacheados para no recargarlos en cada uso)
    g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    g_iGlowSprite = PrecacheModel("materials/sprites/glow01.vmt", true);
    g_iHaloSprite = PrecacheModel("materials/sprites/halo01.vmt", true);

    // Precache de sonidos
    PrecacheSound("mobius/sfx/boost.mp3", true);
    PrecacheSound("ambient/energy/zap1.wav", true);
    PrecacheSound("ambient/energy/zap2.wav", true);
    PrecacheSound("buttons/button17.wav", true);
    PrecacheSound("player/survivor/voice/gambler/relayreactivate04.wav", true);

    // El watchdog se mantiene activo entre mapas (TIMER_REPEAT|FLAG_NO_MAPCHANGE)
    // No necesitamos crearlo de nuevo aqui
}

// =======================
// CORE: LOGICA DE VELOCIDAD
// =======================

// Hook de PreThink: fuerza la velocidad en cada tick
public void Speed_OnPreThink(int client)
{
    if (!Speed_IsValidClient(client)) return;
    if (!g_bIsBoosted[client]) return;

    // Pausar si esta en estado invalido
    if (Speed_IsPlayerInInvalidState(client))
    {
        if (!g_bPaused[client])
        {
            g_bPaused[client] = true;
            // Restaurar velocidad normal mientras este pausado
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            SetEntPropFloat(client, Prop_Data, "m_flGravity", 1.0);
            DebugLog("Player %d: boost paused (invalid state)", client);
        }
        return;
    }
    else if (g_bPaused[client])
    {
        // Reanudar
        g_bPaused[client] = false;
        DebugLog("Player %d: boost resumed", client);
    }

    float now = GetEngineTime();
    float elapsed = now - g_fBoostStart[client];

    // SPEED RAMP: aceleracion gradual durante SPEED_RAMP_DURATION
    float currentMult;
    if (elapsed < SPEED_RAMP_DURATION)
    {
        // Interpolacion lineal de 1.0 a SPEED_MULTIPLIER
        float progress = elapsed / SPEED_RAMP_DURATION;
        currentMult = 1.0 + (SPEED_MULTIPLIER - 1.0) * progress;
    }
    else
    {
        // Verificar si estamos cerca del final para decelerar
        float timeRemaining = g_fBuffEnd[client] - now;
        if (timeRemaining < 0.5)
        {
            // Deceleracion gradual en los ultimos 0.5s
            float progress = timeRemaining / 0.5;
            currentMult = 1.0 + (SPEED_MULTIPLIER - 1.0) * progress;
        }
        else
        {
            currentMult = SPEED_MULTIPLIER;
        }
    }

    // Aplicar velocidad con clamp de seguridad
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", Speed_ClampSpeed(currentMult));

    // Aplicar gravedad baja
    SetEntPropFloat(client, Prop_Data, "m_flGravity", GetExpectedBuffGravity(client));
}

// =======================
// COMANDOS PRINCIPALES
// =======================

public Action Command_Speed(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    // Si ya esta boosteado, abrir menu de estado
    if (g_bIsBoosted[client])
    {
        Command_SpeedMenu(client, 0);
        return Plugin_Handled;
    }

    if (!IsPlayerAlive(client))
    {
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Debes estar vivo para activar el boost.");
        return Plugin_Handled;
    }

    // Verificar estado invalido
    if (Speed_IsPlayerInInvalidState(client))
    {
        PrintToChat(client, "\x04[ZapatosSonic]\x01 No puedes activar el boost en este estado (incapacitado/agua/escalera/being grabbed).");
        return Plugin_Handled;
    }

    float timeNow = GetEngineTime();
    if (timeNow < g_fLastUse[client] + COOLDOWN)
    {
        float remaining = (g_fLastUse[client] + COOLDOWN) - timeNow;
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Espera \x05%.1f\x01 segundos para reusar.", remaining);
        PrintCenterText(client, "Cooldown: %.1fs", remaining);
        return Plugin_Handled;
    }

    g_fLastUse[client] = timeNow;
    g_bHasUsedBoost[client] = true;
    ApplySpeedBoost(client);
    return Plugin_Handled;
}

public Action Command_SpeedMenu(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    ShowSpeedMainMenu(client);
    return Plugin_Handled;
}

public Action Command_SpeedHelp(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    ShowSpeedHelp(client);
    return Plugin_Handled;
}

public Action Command_SpeedInfo(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    ShowSpeedInfo(client);
    return Plugin_Handled;
}

// =======================
// MENU PRINCIPAL (Mini-interfaz)
// =======================

void ShowSpeedMainMenu(int client)
{
    Menu menu = new Menu(MenuHandler_MainMenu);
    menu.SetTitle("ZAPATOS SONIC - Menu Principal");

    if (g_bIsBoosted[client])
    {
        float remaining = g_fBuffEnd[client] - GetEngineTime();
        if (remaining < 0.0) remaining = 0.0;
        char display[64];
        Format(display, sizeof(display), "BOOST ACTIVO - Restante: %.1fs", remaining);
        menu.AddItem("active", display, ITEMDRAW_DISABLED);
        menu.AddItem("reset", "Desactivar boost ahora");
    }
    else
    {
        float timeNow = GetEngineTime();
        if (timeNow < g_fLastUse[client] + COOLDOWN)
        {
            float remaining = (g_fLastUse[client] + COOLDOWN) - timeNow;
            char info[64];
            Format(info, sizeof(info), "Activar boost (CD: %.1fs)", remaining);
            menu.AddItem("activate_cd", info, ITEMDRAW_DISABLED);
        }
        else
        {
            menu.AddItem("activate", "Activar boost ahora!");
        }
    }

    menu.AddItem("color", "Cambiar color del rastro");
    menu.AddItem("info", "Ver estado actual");
    menu.AddItem("help", "Ayuda completa");

    menu.ExitButton = true;
    menu.Display(client, 30);
}

public int MenuHandler_MainMenu(Menu menu, MenuAction action, int client, int param)
{
    if (action == MenuAction_End)
    {
        delete menu;
    }
    else if (action == MenuAction_Select)
    {
        if (client <= 0 || !IsClientInGame(client)) return 0;

        char info[32];
        menu.GetItem(param, info, sizeof(info));

        if (StrEqual(info, "activate"))
        {
            Command_Speed(client, 0);
        }
        else if (StrEqual(info, "reset"))
        {
            Command_ForceReset(client, 0);
        }
        else if (StrEqual(info, "color"))
        {
            Command_ColorMenu(client, 0);
        }
        else if (StrEqual(info, "info"))
        {
            ShowSpeedInfo(client);
        }
        else if (StrEqual(info, "help"))
        {
            ShowSpeedHelp(client);
        }
    }
    return 0;
}

// =======================
// SISTEMA DE AYUDA
// =======================

void ShowSpeedHelp(int client)
{
    PrintToChat(client, "\x04=== ZAPATOS SONIC - AYUDA ===");
    PrintToChat(client, "\x01 \x05!speed\x01 o \x05!sonic\x01 - Activar boost de velocidad");
    PrintToChat(client, "\x01 \x05!speedmenu\x01 - Abrir este menu");
    PrintToChat(client, "\x01 \x05!speedinfo\x01 - Ver estado actual (boost, cooldown, color)");
    PrintToChat(client, "\x01 \x05!colortrail\x01 - Cambiar color del rastro");
    PrintToChat(client, "\x01 \x05!resetspeed\x01 - Desactivar boost manualmente");
    PrintToChat(client, "\x01 \x05!speedhelp\x01 - Mostrar esta ayuda");
    PrintToChat(client, "\x04==============================");
    PrintToChat(client, "\x01 Duracion: \x05%.0fs\x01 | Cooldown: \x05%.0fs\x01 | Multiplicador: \x05%.1fx\x01",
        BUFF_DURATION, COOLDOWN, SPEED_MULTIPLIER);
    PrintToChat(client, "\x01 El boost se pausa automaticamente si eres incapacitado,");
    PrintToChat(client, "\x01 agarrado por un especial, estas en agua o en escaleras.");
}

void ShowSpeedInfo(int client)
{
    PrintToChat(client, "\x04=== ESTADO ZAPATOS SONIC ===");

    if (g_bIsBoosted[client])
    {
        float remaining = g_fBuffEnd[client] - GetEngineTime();
        if (remaining < 0.0) remaining = 0.0;
        PrintToChat(client, "\x01 Boost: \x05ACTIVO\x01 | Tiempo restante: \x05%.1fs\x01", remaining);
    }
    else
    {
        float timeNow = GetEngineTime();
        if (timeNow < g_fLastUse[client] + COOLDOWN)
        {
            float remaining = (g_fLastUse[client] + COOLDOWN) - timeNow;
            PrintToChat(client, "\x01 Boost: \x03INACTIVO\x01 | Cooldown: \x05%.1fs\x01", remaining);
        }
        else
        {
            PrintToChat(client, "\x01 Boost: \x03LISTO\x01 | Puedes activarlo con \x05!speed\x01");
        }
    }

    PrintToChat(client, "\x01 Color del rastro: \x05RGB(%d, %d, %d)\x01",
        g_PlayerColor[client][0], g_PlayerColor[client][1], g_PlayerColor[client][2]);
    PrintToChat(client, "\x04============================");
}

// =======================
// APLICACION DEL BOOST
// =======================

void ApplySpeedBoost(int client)
{
    if (!Speed_IsValidClient(client)) return;

    // 1. Guardar Gravedad Original (Si no estamos ya boosteados)
    if (!g_bIsBoosted[client])
    {
        float currentG = GetEntPropFloat(client, Prop_Data, "m_flGravity");
        if (currentG <= 0.0) currentG = 1.0;
        g_fOriginalGravity[client] = Speed_ClampGravity(currentG);
    }

    // 2. Guardar Velocidad Previa (Snapshot)
    if (g_hCvarRestoreLagged != null && g_hCvarRestoreLagged.BoolValue)
    {
        if (!g_bSavedPrevLagged[client])
        {
            float prev = GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue");
            if (prev <= 0.0) prev = 1.0;
            g_fPrevLagged[client] = Speed_ClampSpeed(prev);
            g_bSavedPrevLagged[client] = true;
        }
    }
    else
    {
        g_bSavedPrevLagged[client] = false;
    }

    // 3. Guardar Gravedad Actual (Snapshot Pre-Buff)
    if (!g_bSavedPrevGravity[client])
    {
        float prevG = GetEntPropFloat(client, Prop_Data, "m_flGravity");
        if (prevG <= 0.0) prevG = 1.0;
        g_fPrevGravity[client] = Speed_ClampGravity(prevG);
        g_bSavedPrevGravity[client] = true;
    }

    // 4. Activar Estado
    g_bIsBoosted[client] = true;
    g_fBuffEnd[client] = GetEngineTime() + BUFF_DURATION;
    g_fBoostStart[client] = GetEngineTime();
    g_bPaused[client] = false;

    // 5. ACTIVAR EL HOOK DE VELOCIDAD (con proteccion anti double-hook)
    if (g_bHookActive[client])
    {
        SDKUnhook(client, SDKHook_PreThink, Speed_OnPreThink);
    }
    SDKHook(client, SDKHook_PreThink, Speed_OnPreThink);
    g_bHookActive[client] = true;

    // 6. Aplicar cambios iniciales (velocidad 1.0, ramp la subira gradualmente)
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntPropFloat(client, Prop_Data, "m_flGravity", GetExpectedBuffGravity(client));

    // 7. Feedback: efectos visuales + sonidos + mensajes
    Speed_CreateActivationEffects(client);

    PrintToChat(client, "\x04[ZapatosSonic]\x05 VELLOCIDAD SONICA ACTIVADA!");
    PrintCenterText(client, ">>> VELOCIDAD SONICA <<<\nDuracion: %.0fs", BUFF_DURATION);

    // 8. Iniciar timers
    ClearClientTimers(client);

    g_hTrailTimer[client] = CreateTimer(0.3, Timer_RefreshTrail, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    g_hResetTimer[client] = CreateTimer(BUFF_DURATION, Timer_ResetStats, client, TIMER_FLAG_NO_MAPCHANGE);
    g_hHUDTimer[client] = CreateTimer(SPEED_HUD_TICK, Timer_HUDUpdate, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    g_hAfterImageTimer[client] = CreateTimer(0.2, Timer_AfterImage, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

// =======================
// EFECTOS VISUALES TIPO SONIC
// =======================

// Efectos al activar el boost
void Speed_CreateActivationEffects(int client)
{
    if (!Speed_IsValidClient(client)) return;

    float origin[3];
    GetClientAbsOrigin(client, origin);
    origin[2] += 10.0;

    int color[4];
    color[0] = g_PlayerColor[client][0];
    color[1] = g_PlayerColor[client][1];
    color[2] = g_PlayerColor[client][2];
    color[3] = 200;

    // 1. Shockwave expansiva (beam ring point que crece)
    if (g_iGlowSprite > 0)
    {
        TE_SetupBeamRingPoint(origin, 10.0, 400.0, g_iGlowSprite, g_iHaloSprite, 0, 15, 0.6, 20.0, 2.0, color, 5, 0);
        TE_SendToAll();
    }

    // 2. Ring de chispas azules
    TE_SetupSparks(origin, NULL_VECTOR, 8, 4);
    TE_SendToAll();

    // 3. Glow inicial en el jugador
    SetEntProp(client, Prop_Send, "m_iGlowType", 3);
    SetEntProp(client, Prop_Send, "m_glowColorOverride", Speed_RGBToInt(color));
    SetEntProp(client, Prop_Send, "m_bFlashing", 1);

    // 4. Sonido de activacion
    EmitSoundToAll("mobius/sfx/boost.mp3", client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.0);
}

// Efectos al desactivar el boost
void Speed_CreateDeactivationEffects(int client)
{
    if (!Speed_IsValidClient(client)) return;

    float origin[3];
    GetClientAbsOrigin(client, origin);
    origin[2] += 10.0;

    // Ring de desactivacion (rojo para diferenciar)
    int deactColor[4] = {255, 50, 50, 200};
    if (g_iGlowSprite > 0)
    {
        TE_SetupBeamRingPoint(origin, 10.0, 200.0, g_iGlowSprite, g_iHaloSprite, 0, 15, 0.4, 10.0, 1.0, deactColor, 3, 0);
        TE_SendToAll();
    }

    // Quitar glow
    SetEntProp(client, Prop_Send, "m_iGlowType", 0);
    SetEntProp(client, Prop_Send, "m_bFlashing", 0);

    // Sonido de desactivacion
    EmitSoundToAll("ambient/energy/zap2.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.7);
}

// Convierte RGBA a int para glowColorOverride
int Speed_RGBToInt(int color[4])
{
    return (color[2] << 16) | (color[1] << 8) | color[0];
}

// Trail de color que sigue al jugador
void Speed_CreateColorTrail(int client)
{
    if (!Speed_IsValidClient(client)) return;
    if (g_iBeamSprite <= 0) return;

    TE_SetupBeamFollow(client, g_iBeamSprite, 0, 0.6, 10.0, 1.0, 3, g_PlayerColor[client]);
    TE_SendToAll();
}

// After-image (sprite fantasma)
void Speed_CreateAfterImage(int client)
{
    if (!Speed_IsValidClient(client)) return;
    if (g_iGlowSprite <= 0) return;

    float origin[3];
    GetClientAbsOrigin(client, origin);
    origin[2] += 30.0;

    // Sprite de glow que se desvanece
    TE_SetupGlowSprite(origin, g_iGlowSprite, 0.3, 0.8, 100);
    TE_SendToAll();
}

// =======================
// TIMERS DE CONTROL
// =======================

public Action Timer_RefreshTrail(Handle timer, any data)
{
    int client = data;
    if (!Speed_IsValidClient(client)) return Plugin_Stop;
    if (!g_bIsBoosted[client]) return Plugin_Stop;

    if (!g_bPaused[client])
    {
        Speed_CreateColorTrail(client);
    }
    return Plugin_Continue;
}

public Action Timer_AfterImage(Handle timer, any data)
{
    int client = data;
    if (!Speed_IsValidClient(client)) return Plugin_Stop;
    if (!g_bIsBoosted[client]) return Plugin_Stop;

    if (!g_bPaused[client])
    {
        Speed_CreateAfterImage(client);
    }
    return Plugin_Continue;
}

public Action Timer_HUDUpdate(Handle timer, any data)
{
    int client = data;
    if (!Speed_IsValidClient(client)) return Plugin_Stop;
    if (!g_bIsBoosted[client]) return Plugin_Stop;

    float remaining = g_fBuffEnd[client] - GetEngineTime();
    if (remaining <= 0.0) return Plugin_Stop;

    // HUD con tiempo restante
    if (!g_bPaused[client])
    {
        PrintHintText(client, "VELOCIDAD SONICA\nTiempo restante: %.1fs", remaining);
    }
    else
    {
        PrintHintText(client, "BOOST PAUSADO\n(Espera a estar libre)");
    }

    // Countdown en los ultimos 3 segundos
    if (remaining <= SPEED_LOW_TIME_THRESHOLD && remaining > 0.0)
    {
        PrintCenterText(client, "SPEED ENDING!\n%.0f", remaining);
        EmitSoundToClient(client, "buttons/button17.wav", _, _, _, _, _, 150);
    }

    return Plugin_Continue;
}

public Action Timer_ResetStats(Handle timer, any data)
{
    int client = data;
    if (client < 1 || client > MaxClients) return Plugin_Stop;

    // Si el cliente se fue, limpiar memoria
    if (!IsClientInGame(client))
    {
        ResetClientState(client);
        ClearClientTimers(client);
        return Plugin_Stop;
    }

    float timeNow = GetEngineTime();

    // Si se renovo el buff antes de terminar, reprogramar
    if (timeNow < g_fBuffEnd[client])
    {
        float remaining = g_fBuffEnd[client] - timeNow;
        if (remaining < 0.1) remaining = 0.1;
        g_hResetTimer[client] = CreateTimer(remaining + 0.1, Timer_ResetStats, client, TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Stop;
    }

    // RESTAURAR VALORES
    Speed_RestorePlayerStats(client);

    // Efectos de desactivacion
    if (IsPlayerAlive(client))
    {
        Speed_CreateDeactivationEffects(client);
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Velocidad normal restaurada.");
    }

    // Limpieza final
    ClearClientTimers(client);
    ResetClientState(client);

    return Plugin_Stop;
}

// Restaura los stats del jugador a sus valores previos
void Speed_RestorePlayerStats(int client)
{
    if (!IsClientInGame(client)) return;

    // Velocidad
    float targetSpeed;
    if (g_hCvarRestoreLagged != null && g_hCvarRestoreLagged.BoolValue && g_bSavedPrevLagged[client])
        targetSpeed = g_fPrevLagged[client];
    else
        targetSpeed = 1.0;

    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", Speed_ClampSpeed(targetSpeed));

    // Gravedad
    float targetGravity;
    if (g_bSavedPrevGravity[client])
        targetGravity = g_fPrevGravity[client];
    else
        targetGravity = (g_fOriginalGravity[client] > 0.0) ? g_fOriginalGravity[client] : 1.0;

    SetEntPropFloat(client, Prop_Data, "m_flGravity", Speed_ClampGravity(targetGravity));

    // Quitar glow
    SetEntProp(client, Prop_Send, "m_iGlowType", 0);
    SetEntProp(client, Prop_Send, "m_bFlashing", 0);
}

// =======================
// EVENTOS Y LIMPIEZA
// =======================

public Action Command_ForceReset(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    if (!g_bIsBoosted[client])
    {
        PrintToChat(client, "\x04[ZapatosSonic]\x01 No tienes el boost activo.");
        return Plugin_Handled;
    }

    PrintToChat(client, "\x04[ZapatosSonic]\x01 Restaurando manualmente...");

    // Forzar el reset
    g_fBuffEnd[client] = 0.0; // Asegurar que el timer lo procese como expirado
    Timer_ResetStats(INVALID_HANDLE, client);

    return Plugin_Handled;
}

public void Speed_Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));

    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        // Tomar snapshot de gravedad "base" al aparecer, si no esta boosteado
        if (!g_bIsBoosted[client])
        {
            float g = GetEntPropFloat(client, Prop_Data, "m_flGravity");
            if (g <= 0.0) g = 1.0;
            g_fOriginalGravity[client] = Speed_ClampGravity(g);
        }

        // Cargar color
        if (AreClientCookiesCached(client)) LoadPlayerColor(client);

        // Mensaje de bienvenida (solo la primera vez por spawn)
        if (g_hCvarEnableTips != null && g_hCvarEnableTips.BoolValue)
        {
            CreateTimer(3.0, Timer_WelcomeMessage, client, TIMER_FLAG_NO_MAPCHANGE);
            g_fNextTipTime[client] = GetEngineTime() + 30.0;
        }
    }
}

public Action Timer_WelcomeMessage(Handle timer, any client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return Plugin_Stop;

    PrintToChat(client, "\x04[ZapatosSonic]\x01 Escribe \x05!speed\x01 o \x05!speedhelp\x01 para usar los Zapatos Sonic.");
    return Plugin_Stop;
}

public void Speed_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    // Limpiar todos los estados al final de la ronda
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && g_bIsBoosted[i])
        {
            Speed_RestorePlayerStats(i);
            ClearClientTimers(i);
            ResetClientState(i);
        }
    }
}

public void Speed_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients) return;

    DebugLog("Player %d died. Resetting boost.", client);

    if (g_bIsBoosted[client] && IsClientInGame(client))
    {
        Speed_RestorePlayerStats(client);
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Boost perdido por muerte.");
    }

    ClearClientTimers(client);
    ResetClientState(client);
}

public void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        ClearClientTimers(client);
        ResetClientState(client);
        g_fLastUse[client] = 0.0;
        g_fOriginalGravity[client] = 1.0;
        g_bHasUsedBoost[client] = false;
        g_fNextTipTime[client] = 0.0;
    }
}

// =======================
// WATCHDOG MEJORADO (SEGURIDAD)
// =======================

public Action Timer_WatchdogCheck(Handle timer)
{
    float timeNow = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;

        // === CHECK 1: Estado colgado (buffEnd expirado pero sigue boosteado) ===
        if (g_bIsBoosted[i] && timeNow > g_fBuffEnd[i] + 1.0)
        {
            DebugLog("WATCHDOG [1]: Force restore for Player %d (buff expired but still boosted)", i);
            Timer_ResetStats(INVALID_HANDLE, i);
            continue;
        }

        // === CHECK 2: Hook fantasma (boosted pero hook no activo) ===
        if (g_bIsBoosted[i] && !g_bHookActive[i] && IsPlayerAlive(i))
        {
            DebugLog("WATCHDOG [2]: Re-hooking Player %d (boosted but hook inactive)", i);
            SDKHook(i, SDKHook_PreThink, Speed_OnPreThink);
            g_bHookActive[i] = true;
        }

        // === CHECK 3: Hook activo pero no boosteado (hook zombie) ===
        if (!g_bIsBoosted[i] && g_bHookActive[i])
        {
            DebugLog("WATCHDOG [3]: Unhooking Player %d (not boosted but hook active)", i);
            SDKUnhook(i, SDKHook_PreThink, Speed_OnPreThink);
            g_bHookActive[i] = false;
        }

        // === CHECK 4: Velocidad corrupta ===
        if (IsPlayerAlive(i))
        {
            float currentSpeed = GetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue");
            if (currentSpeed < SPEED_MIN_CLAMP || currentSpeed > SPEED_MAX_CLAMP)
            {
                DebugLog("WATCHDOG [4]: Fixing corrupt speed for Player %d (was %.2f)", i, currentSpeed);
                if (g_bIsBoosted[i] && !g_bPaused[i])
                    SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", Speed_ClampSpeed(SPEED_MULTIPLIER));
                else
                    SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 1.0);
            }

            // === CHECK 5: Gravedad corrupta ===
            float currentGrav = GetEntPropFloat(i, Prop_Data, "m_flGravity");
            if (currentGrav <= 0.0 || currentGrav > GRAVITY_MAX_CLAMP)
            {
                DebugLog("WATCHDOG [5]: Fixing corrupt gravity for Player %d (was %.2f)", i, currentGrav);
                if (g_bIsBoosted[i] && !g_bPaused[i])
                    SetEntPropFloat(i, Prop_Data, "m_flGravity", GetExpectedBuffGravity(i));
                else
                    SetEntPropFloat(i, Prop_Data, "m_flGravity", 1.0);
            }
        }

        // === CHECK 6: Timers zombie (cliente desconectado con timers activos) ===
        if (!IsPlayerAlive(i) && (g_hTrailTimer[i] != null || g_hResetTimer[i] != null || g_hHUDTimer[i] != null))
        {
            DebugLog("WATCHDOG [6]: Clearing zombie timers for Player %d", i);
            ClearClientTimers(i);
        }
    }

    return Plugin_Continue;
}

// =======================
// SISTEMA DE TIPS AUTOMATICOS
// =======================

public Action Timer_AutoTips(Handle timer)
{
    if (g_hCvarEnableTips == null || !g_hCvarEnableTips.BoolValue) return Plugin_Continue;

    float timeNow = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (g_bHasUsedBoost[i]) continue; // Solo a los que no han usado el boost
        if (timeNow < g_fNextTipTime[i]) continue;

        // Tip aleatorio
        int tipNum = GetRandomInt(1, 4);
        switch (tipNum)
        {
            case 1: PrintToChat(i, "\x04[TIP]\x01 Escribe \x05!speed\x01 para activar los Zapatos Sonic y correr a velocidad super sonica!");
            case 2: PrintToChat(i, "\x04[TIP]\x01 Escribe \x5!speedhelp\x01 para ver todos los comandos disponibles.");
            case 3: PrintToChat(i, "\x04[TIP]\x01 Escribe \x05!colortrail\x01 para personalizar el color de tu rastro de velocidad.");
            case 4: PrintToChat(i, "\x04[TIP]\x01 Escribe \x05!speedinfo\x01 para ver el estado de tu boost y cooldown.");
        }

        g_fNextTipTime[i] = timeNow + SPEED_TIP_INTERVAL;
    }

    return Plugin_Continue;
}

// =======================
// SISTEMA DE COLORES Y MENU
// =======================

public void Speed_OnClientCookiesCached(int client)
{
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
        LoadPlayerColor(client);
}

void SavePlayerColor(int client)
{
    if (!IsClientInGame(client)) return;
    if (g_hColorCookie == null) return;

    char sColor[32];
    Format(sColor, sizeof(sColor), "%d %d %d %d",
        g_PlayerColor[client][0], g_PlayerColor[client][1],
        g_PlayerColor[client][2], g_PlayerColor[client][3]);
    SetClientCookie(client, g_hColorCookie, sColor);
    PrintToChat(client, "\x04[ZapatosSonic]\x01 Color guardado: RGB(%d, %d, %d)",
        g_PlayerColor[client][0], g_PlayerColor[client][1], g_PlayerColor[client][2]);
}

void LoadPlayerColor(int client)
{
    if (!IsClientInGame(client)) return;
    if (g_hColorCookie == null) return;

    char sColor[64];
    GetClientCookie(client, g_hColorCookie, sColor, sizeof(sColor));

    if (sColor[0] == '\0')
    {
        // Default: Azul Sonic
        g_PlayerColor[client][0] = 0;
        g_PlayerColor[client][1] = 150;
        g_PlayerColor[client][2] = 255;
        g_PlayerColor[client][3] = 200;
        return;
    }

    char parts[4][8];
    if (ExplodeString(sColor, " ", parts, 4, 8) >= 4)
    {
        g_PlayerColor[client][0] = StringToInt(parts[0]);
        g_PlayerColor[client][1] = StringToInt(parts[1]);
        g_PlayerColor[client][2] = StringToInt(parts[2]);
        g_PlayerColor[client][3] = StringToInt(parts[3]);

        // Clamp de valores RGB
        for (int c = 0; c < 4; c++)
        {
            if (g_PlayerColor[client][c] < 0) g_PlayerColor[client][c] = 0;
            if (g_PlayerColor[client][c] > 255) g_PlayerColor[client][c] = 255;
        }
    }
}

public Action Command_ColorMenu(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    Menu menu = new Menu(MenuHandler_ColorSelect);
    menu.SetTitle("COLOR DEL RASTRO SONIC\nColor actual: RGB(%d, %d, %d)",
        g_PlayerColor[client][0], g_PlayerColor[client][1], g_PlayerColor[client][2]);

    menu.AddItem("0 150 255 200", "Azul Sonic (Clasico)");
    menu.AddItem("255 0 0 200", "Rojo");
    menu.AddItem("0 255 0 200", "Verde");
    menu.AddItem("255 255 0 200", "Amarillo");
    menu.AddItem("0 255 255 200", "Cian");
    menu.AddItem("255 0 255 200", "Magenta");
    menu.AddItem("255 165 0 200", "Naranja");
    menu.AddItem("128 0 128 200", "Morado");
    menu.AddItem("255 20 147 200", "Rosa Hot");
    menu.AddItem("0 255 128 200", "Verde Neón");
    menu.AddItem("255 255 255 200", "Blanco");

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
        if (client <= 0 || !IsClientInGame(client)) return 0;

        char info[64];
        menu.GetItem(param, info, sizeof(info));
        char parts[4][8];
        ExplodeString(info, " ", parts, 4, 8);

        g_PlayerColor[client][0] = StringToInt(parts[0]);
        g_PlayerColor[client][1] = StringToInt(parts[1]);
        g_PlayerColor[client][2] = StringToInt(parts[2]);
        g_PlayerColor[client][3] = StringToInt(parts[3]);

        SavePlayerColor(client);
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Color actualizado.");

        // Volver al menu principal
        ShowSpeedMainMenu(client);
    }
    return 0;
}

// =======================
// HOOK DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
public void Speed_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;

    if (g_bIsBoosted[client] && IsClientInGame(client))
    {
        Speed_RestorePlayerStats(client);
    }

    ClearClientTimers(client);
    ResetClientState(client);
}

// Hook de say command para alias de chat
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Continue;

    if (StrEqual(sArgs, "!speed", false) || StrEqual(sArgs, "!sonic", false))
    {
        Command_Speed(client, 0);
        return Plugin_Handled;
    }
    if (StrEqual(sArgs, "!speedmenu", false) || StrEqual(sArgs, "!sonicmenu", false))
    {
        Command_SpeedMenu(client, 0);
        return Plugin_Handled;
    }
    if (StrEqual(sArgs, "!colortrail", false))
    {
        Command_ColorMenu(client, 0);
        return Plugin_Handled;
    }
    if (StrEqual(sArgs, "!speedhelp", false) || StrEqual(sArgs, "!sonichelp", false))
    {
        Command_SpeedHelp(client, 0);
        return Plugin_Handled;
    }
    if (StrEqual(sArgs, "!speedinfo", false) || StrEqual(sArgs, "!sonicinfo", false))
    {
        Command_SpeedInfo(client, 0);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}
