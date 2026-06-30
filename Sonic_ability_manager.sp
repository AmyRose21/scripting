/*
 * ======================================================
 *  SonicJumpSurvivors - Manager Universal (Fixed v3.15 - 10 Chars)
 *  FIX: Checkpoint removed, replaced with Sonic Wind.
 *  FIX: Duplicated L4D2 native events removed from Sally, centralized here.
 *  FIX: UTF-8 Warnings purged entirely (No emojis or accents).
 *  NEW: Metal Sonic and Dr. Eggman integrated.
 *  v3.9:  Metal_OnPlayerDeath hook + Metal v3.0 (canonical Destructive Charge).
 *  v3.10: Rouge_OnPlayerDeath hook + Rouge v7.0 (real acid pool damage).
 *  v3.11: Amy_OnPlayerDeath hook + Amy v43 (melee animation fix + robustness).
 *  v3.12: Cream_OnPlayerDeath hook + Cream v5.0 (Resurrection, 1 use per round).
 *  v3.13: Sally_OnPlayerDeath hook + Sally v5.0 (Fire/Water shield rework).
 *  v3.14: ROBUSTEZ GENERAL - validaciones estrictas, OnPluginEnd, fix de macros,
 *         limpieza de timers en disconnect, logging de errores, proteccion anti-crash.
 *  v3.15: Eggman_OnPlayerSpawn/Death/Disconnect hooks + Eggman v2.0 (Air Support).
 * ======================================================
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <left4dhooks>
#include <sdktools_trace>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME "SonicJumpSurvivors - Universal"
#define PLUGIN_VERSION "3.15.0"

#define MAX_SOUNDS 4
#define INVALID_SOUND_INDEX -1

#define MAX_CHARS 10
#define INVALID_CHAR_INDEX -1

#define SONIC_INDEX      0
#define TAILS_INDEX      1
#define KNUCKLES_INDEX   2
#define AMY_INDEX        3
#define SALLY_INDEX      4
#define SHADOW_INDEX     5
#define ROUGE_INDEX      6
#define CREAM_INDEX      7
#define METALSONIC_INDEX 8
#define EGGMAN_INDEX     9


public char g_SoundPaths[MAX_SOUNDS][PLATFORM_MAX_PATH] = {
    "mobius/sfx/saltos/jumpSonic1.mp3",
    "mobius/sfx/saltos/jumpSonic2.mp3",
    "mobius/sfx/saltos/jumpSonicCD.mp3",
    "mobius/sfx/saltos/jumpSonicSRB2.mp3"
};
static const char g_SoundNames[MAX_SOUNDS][] = { "Sonic 1", "Sonic 2", "Sonic CD", "Sonic SRB2" };

public char g_CharNames[MAX_CHARS][] = {
    "Sonic", "Tails", "Knuckles", "Amy", "Sally", "Shadow", "Rouge", "Cream", "Metal Sonic", "Dr. Eggman"
};

public int g_iPlayerCharIdx[MAXPLAYERS + 1];
public int g_iPlayerSoundIdx[MAXPLAYERS + 1];
bool g_bSonicHeroMode[MAXPLAYERS + 1];

ConVar g_cvSJEnable, g_cvSJVolume, g_cvSJCooldown, g_cvSonicBoost, g_cvVelZMin;
float g_flNextAllowed[MAXPLAYERS + 1];
int g_iCharTakenBy[MAX_CHARS];

Handle g_hSoundCookie;
Handle g_hCharCookie;
StringMap g_mCharOwner;
char g_sOwnersFile[PLATFORM_MAX_PATH];

int g_iOff_Incapacitated = -1;
int g_iOff_PounceAttacker = -1;
int g_iOff_TongueOwner = -1;
int g_iOff_JockeyAttacker = -1;
int g_iOff_PummelAttacker = -1;
int g_iOff_CarryAttacker = -1;
int g_iOff_LaggedMovement = -1;
int g_iOff_Velocity = -1;

#define IsValidClient(%1) (%1 > 0 && %1 <= MaxClients && IsClientInGame(%1) && !IsFakeClient(%1))
#define IsSurvivor(%1) (GetClientTeam(%1) == 2)

public void AddSoundToDownloadsAndPrecache(const char[] soundPath)
{
    char fullPath[PLATFORM_MAX_PATH];
    Format(fullPath, sizeof(fullPath), "sound/%s", soundPath);
    if (FileExists(fullPath, true)) 
    {
        AddFileToDownloadsTable(fullPath);
    }
    PrecacheSound(soundPath, true);
}

// Includes completos
#include <Speed_sonic>
#include <sonic>
#include <Tails>  
#include <Knuckles>
#include <Amy>
#include <Sally>
#include <Shadow>
#include <Rouge>
#include <Cream>
#include <Metal>
#include <Eggman>

public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "Author",
    description = "Universal Sonic Abilities Manager",
    version = PLUGIN_VERSION,
    url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    CreateNative("Sonic_GetPlayerCharIndex", Native_GetPlayerCharIndex);
    return APLRes_Success;
}

public int Native_GetPlayerCharIndex(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    if (!IsValidClient(client)) return -1;
    return g_iPlayerCharIdx[client];
}

public void OnPluginStart()
{
    g_iOff_Incapacitated  = FindSendPropInfo("CTerrorPlayer", "m_isIncapacitated");
    g_iOff_PounceAttacker = FindSendPropInfo("CTerrorPlayer", "m_pounceAttacker");
    g_iOff_TongueOwner    = FindSendPropInfo("CTerrorPlayer", "m_tongueOwner");
    g_iOff_JockeyAttacker = FindSendPropInfo("CTerrorPlayer", "m_jockeyAttacker");
    g_iOff_PummelAttacker = FindSendPropInfo("CTerrorPlayer", "m_pummelAttacker");
    g_iOff_CarryAttacker  = FindSendPropInfo("CTerrorPlayer", "m_carryAttacker");
    g_iOff_LaggedMovement = FindSendPropInfo("CTerrorPlayer", "m_flLaggedMovementValue");
    g_iOff_Velocity       = FindSendPropInfo("CBasePlayer",   "m_vecVelocity[0]");

    g_cvSJEnable   = CreateConVar("sj_enable", "1", "Habilita el plugin", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvSJVolume   = CreateConVar("sj_volume", "1.0", "Volumen global", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvSJCooldown = CreateConVar("sj_cooldown", "0.15", "Cooldown salto", FCVAR_NOTIFY, true, 0.0, true, 5.0);
    g_cvSonicBoost = CreateConVar("sj_sonicboost", "1.0", "Multiplicador impulso", FCVAR_NOTIFY);
    g_cvVelZMin    = CreateConVar("sj_velzmin", "200.0", "Velocidad Z minima", FCVAR_NOTIFY);

    HookEvent("player_jump", Event_PlayerJump, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
    HookEvent("round_start", OnRoundStart);
    HookEvent("player_spawn", Event_PlayerSpawn);

    RegConsoleCmd("sm_sjs_ability1", Command_Ability1, "Habilidad Primaria (Tecla Z)");
    RegConsoleCmd("sm_sjs_ability2", Command_Ability2, "Habilidad Secundaria (Tecla X)");

    RegConsoleCmd("js", Cmd_OpenSoundMenu);
    RegConsoleCmd("sc", Cmd_OpenCharMenu);
    RegConsoleCmd("cinfo", Cmd_ShowCharInfo);
    RegConsoleCmd("sm_forceragdoll", Cmd_CreateRagdoll);

    RegAdminCmd("sm_setsound", Cmd_OpenSoundMenu, ADMFLAG_GENERIC);
    RegAdminCmd("freechars", Cmd_FreeAllChars, ADMFLAG_GENERIC);

    g_hSoundCookie = RegClientCookie("sj_sound_choice", "Sonic Sound", CookieAccess_Public);
    g_hCharCookie  = RegClientCookie("sj_char_choice", "Sonic Char", CookieAccess_Public);

    for (int i = 0; i < MAX_CHARS; i++) g_iCharTakenBy[i] = 0;
    for (int i = 1; i <= MaxClients; i++) g_iPlayerCharIdx[i] = INVALID_CHAR_INDEX;

    g_mCharOwner = new StringMap();
    BuildPath(Path_SM, g_sOwnersFile, sizeof(g_sOwnersFile), "data/sonic_jump_survivors_owners.cfg");
    LoadOwnersFromFile();

    Speed_OnPluginStart();
    Sonic_OnMapStart(); 
    Tails_OnPluginStart();
    Knuckles_OnPluginStart();
    Amy_OnPluginStart();
    Sally_OnPluginStart();
    Shadow_OnPluginStart();
    Rouge_OnPluginStart();
    Cream_OnPluginStart();
    Metal_OnPluginStart();
    Eggman_OnPluginStart();

    AutoExecConfig(true, "sonic_jump_survivors");

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && AreClientCookiesCached(i))
        {
            LoadPlayerSoundChoice(i);
            LoadPlayerCharChoice(i);
            MaybePromptMenus(i);
        }
    }
}

// v3.14: Limpieza al descargar el plugin (evita fugas de hooks y timers)
public void OnPluginEnd()
{
    // Limpiar estado de todos los clientes activos
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i <= MaxClients && IsClientInGame(i))
        {
            // Forzar reset de cada modulo
            Speed_OnPlayerDeath(i);
            Metal_OnPlayerDeath(i);
            Rouge_OnPlayerDeath(i);
            Amy_OnPlayerDeath(i);
            Cream_OnPlayerDeath(i);
            Sally_OnPlayerDeath(i);
        }
    }

    // Guardar owners antes de salir
    SaveOwnersToFile();

    PrintToServer("[SonicJumpSurvivors] Plugin descargado. Estado limpiado.");
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Continue;

    int charIdx = g_iPlayerCharIdx[client];
    if (charIdx < 0 || charIdx >= MAX_CHARS) return Plugin_Continue;

    if (charIdx == AMY_INDEX)
    {
        Amy_OnPlayerRunCmd(client, buttons);
    }
    else if (charIdx == SALLY_INDEX)
    {
        Sally_OnPlayerRunCmd(client, buttons);
    }
    else if (charIdx == SHADOW_INDEX)
    {
        Shadow_OnPlayerRunCmd_Proxy(client, buttons);
    }
    else if (charIdx == METALSONIC_INDEX)
    {
        Metal_OnPlayerRunCmd(client, buttons);
    }
    else if (charIdx == EGGMAN_INDEX)
    {
        Eggman_OnPlayerRunCmd(client, buttons);
    }
    
    if (g_bIsBoneBroken[client])
    {
        Amy_OnPlayerRunCmd_Victim(client, buttons);
    }
    
    return Plugin_Continue;
}

public Action Command_Ability1(int client, int args)
{
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;
    if (!g_cvSJEnable.BoolValue) return Plugin_Handled;

    int charIdx = g_iPlayerCharIdx[client];
    if (charIdx < 0 || charIdx >= MAX_CHARS) return Plugin_Handled;

    switch (charIdx)
    {
        case SONIC_INDEX:      HabilidadSonicSuperJump(client);
        case TAILS_INDEX:      Command_TailsLaser(client, 0);
        case KNUCKLES_INDEX:   Command_KnuxPunch(client, 0);
        case AMY_INDEX:        Command_HammerStrike(client, 0);
        case SALLY_INDEX:      Cmd_ToggleShield(client, 0);
        case SHADOW_INDEX:     Command_ShadowAbility(client, 0);
        case ROUGE_INDEX:      Command_RougeKick(client, 0);
        case CREAM_INDEX:      Command_CreamHeal(client, 0);
        case METALSONIC_INDEX: Command_MetalCharge(client, 0);
        case EGGMAN_INDEX:     Command_EggmanMines(client, 0);
        default: PrintCenterText(client, "[X] Personaje sin Habilidad 1 definida");
    }
    return Plugin_Handled;
}

public Action Command_Ability2(int client, int args)
{
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;
    if (!g_cvSJEnable.BoolValue) return Plugin_Handled;

    int charIdx = g_iPlayerCharIdx[client];
    if (charIdx < 0 || charIdx >= MAX_CHARS) return Plugin_Handled;

    switch (charIdx)
    {
        case SONIC_INDEX:      Sonic_ActivateSonicWind(client);
        case TAILS_INDEX:      Command_TailsFly(client, 0);
        case KNUCKLES_INDEX:   Command_KnuxCounter(client, 0);
        case AMY_INDEX:        Command_HammerJump(client, 0);
        case SALLY_INDEX:      Cmd_ToggleBubble(client, 0);
        case SHADOW_INDEX:     Command_ShadowDash(client, 0);
        case ROUGE_INDEX:      Command_RougeBomb(client, 0);
        case CREAM_INDEX:      Command_CreamRevive(client, 0);
        case METALSONIC_INDEX: Command_MetalOverdrive(client, 0);
        case EGGMAN_INDEX:     Command_EggmanLaser(client, 0);
        default: PrintCenterText(client, "[X] Personaje sin Habilidad 2 definida");
    }
    return Plugin_Handled;
}

public void OnGameFrame()
{
    // v3.14: Validacion de ConVar antes de continuar
    if (g_cvSJEnable == null || !g_cvSJEnable.BoolValue) return;

    // v3.14: Validar offsets antes de usarlos (anti-crash)
    if (g_iOff_Incapacitated == -1 || g_iOff_LaggedMovement == -1) return;

    bool amyInDanger = false;
    bool amyExists = false;
    if (g_iCharTakenBy[AMY_INDEX] != 0 && g_iCharTakenBy[AMY_INDEX] > 0
        && g_iCharTakenBy[AMY_INDEX] <= MaxClients
        && IsClientInGame(g_iCharTakenBy[AMY_INDEX]))
    {
        amyExists = true;
    }

    if (amyExists)
    {
        int i = g_iCharTakenBy[AMY_INDEX];
        if (IsPlayerAlive(i))
        {
            if (GetEntData(i, g_iOff_Incapacitated, 1) > 0 ||
                SafeGetEntDataEnt(i, g_iOff_PounceAttacker) > 0 ||
                SafeGetEntDataEnt(i, g_iOff_TongueOwner) > 0 ||
                SafeGetEntDataEnt(i, g_iOff_JockeyAttacker) > 0 ||
                SafeGetEntDataEnt(i, g_iOff_PummelAttacker) > 0 ||
                SafeGetEntDataEnt(i, g_iOff_CarryAttacker) > 0)
            {
                amyInDanger = true;
            }
        }
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || !IsSurvivor(i)) continue;

        int charIdx = g_iPlayerCharIdx[i];

        if (charIdx == SONIC_INDEX)
        {
            if (amyInDanger)
            {
                if (!g_bSonicHeroMode[i])
                {
                    g_bSonicHeroMode[i] = true;
                    PrintCenterText(i, "[+] AMY ESTA EN PELIGRO! MODO IMPARABLE ACTIVADO!");
                    EmitSoundToClient(i, "mobius/sfx/boost.mp3");
                }
                Sonic_PushCommons(i);
                float currentLag = GetEntDataFloat(i, g_iOff_LaggedMovement);
                if (currentLag < 1.5) SetEntDataFloat(i, g_iOff_LaggedMovement, 1.5);
            }
            else
            {
                if (g_bSonicHeroMode[i])
                {
                    g_bSonicHeroMode[i] = false;
                    SetEntDataFloat(i, g_iOff_LaggedMovement, 1.0);
                    PrintCenterText(i, "Peligro neutralizado. Modo normal.");
                }
            }
        }

        if (charIdx == SHADOW_INDEX)
        {
            int buttons = GetClientButtons(i);
            Shadow_OnPlayerRunCmd_Proxy(i, buttons);
        }
    }
}

void Sonic_PushCommons(int client)
{
    float pos[3]; GetClientAbsOrigin(client, pos);
    float radius = 120.0;

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(pos, zPos) <= radius)
        {
            float push[3]; MakeVectorFromPoints(pos, zPos, push); NormalizeVector(push, push); ScaleVector(push, 300.0); push[2] = 150.0;
            TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
}

// ===================================================================================
// EVENTOS L4D & HOOKS CENTRALES
// ===================================================================================

public Action L4D_TankClaw_OnPlayerHit_Pre(int tank, int claw, int player)
{
    if (IsValidClient(player))
    {
        if (g_iPlayerCharIdx[player] == KNUCKLES_INDEX && Knuckles_CheckTankCounter(tank, player)) return Plugin_Handled;
        if (g_iPlayerCharIdx[player] == SONIC_INDEX && g_bSonicHeroMode[player]) return Plugin_Handled;
        if (g_iPlayerCharIdx[player] == SALLY_INDEX && Sally_IsBubbleActive(player)) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnKnockedDown(int client, int reason)
{
    if (IsValidClient(client))
    {
        if (g_iPlayerCharIdx[client] == KNUCKLES_INDEX && Knuckles_IsPhysicsImmune(client)) return Plugin_Handled;
        if (g_iPlayerCharIdx[client] == SALLY_INDEX && Sally_IsBubbleActive(client)) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnFling(int client, int &attacker, float vector[3])
{
    if (IsValidClient(client))
    {
        if (g_iPlayerCharIdx[client] == KNUCKLES_INDEX && Knuckles_IsPhysicsImmune(client)) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnStagger(int target, int source)
{
    if (IsValidClient(target))
    {
        if (g_iPlayerCharIdx[target] == KNUCKLES_INDEX && Knuckles_IsPhysicsImmune(target)) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnPouncedOnSurvivor_Pre(int victim, int attacker)
{
    if (IsValidClient(victim))
    {
        if (g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && Knuckles_CheckSpecialCounter(victim, attacker)) return Plugin_Handled;
        if (g_iPlayerCharIdx[victim] == SONIC_INDEX && g_bSonicHeroMode[victim]) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnJockeyRide_Pre(int victim, int attacker)
{
    if (IsValidClient(victim))
    {
        if (g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && Knuckles_CheckSpecialCounter(victim, attacker)) return Plugin_Handled;
        if (g_iPlayerCharIdx[victim] == SONIC_INDEX && g_bSonicHeroMode[victim]) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnChargerImpact_Pre(int charger, int victim)
{
    if (IsValidClient(victim))
    {
        if (g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && Knuckles_CheckSpecialCounter(victim, charger)) return Plugin_Handled;
        if (g_iPlayerCharIdx[victim] == SONIC_INDEX && g_bSonicHeroMode[victim]) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnTongueGrab_Pre(int victim, int smoker)
{
    if (IsValidClient(victim))
    {
        if (g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && Knuckles_HandleSmokerCounter(victim, smoker)) return Plugin_Handled;
        if (g_iPlayerCharIdx[victim] == SONIC_INDEX && g_bSonicHeroMode[victim]) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action Cmd_CreateRagdoll(int client, int args)
{
    CreateSonicRagdoll(client);
    return Plugin_Handled;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int inflictor = 0;

    Speed_Event_PlayerDeath(event, name, dontBroadcast);

    // v3.9: Limpieza de estado de Metal Sonic al morir (libera infectado agarrado, resetea carga)
    if (victim > 0 && IsClientInGame(victim))
    {
        Metal_OnPlayerDeath(victim);
    }

    // v3.10: Limpieza de estado de Rouge al morir (reset cooldowns, gliding, render)
    if (victim > 0 && IsClientInGame(victim))
    {
        Rouge_OnPlayerDeath(victim);
    }

    // v3.11: Limpieza de estado de Amy al morir (reset fury, momentum, disarm, timers)
    if (victim > 0 && IsClientInGame(victim))
    {
        Amy_OnPlayerDeath(victim);
    }

    // v3.12: Limpieza de estado de Cream al morir (cancela heal, libera timers)
    if (victim > 0 && IsClientInGame(victim))
    {
        Cream_OnPlayerDeath(victim);
    }

    // v3.13: Limpieza de estado de Sally al morir (reset escudos, barreras, cooldowns)
    if (victim > 0 && IsClientInGame(victim))
    {
        Sally_OnPlayerDeath(victim);
    }

    // v3.15: Limpieza de estado de Eggman al morir (remover avion de Air Support)
    if (victim > 0 && IsClientInGame(victim))
    {
        Eggman_OnPlayerDeath(victim);
    }

    if (!IsValidClient(victim)) return Plugin_Continue;

    float damage = 9999.0;
    int dmgType = 0;

    return Sonic_OnPlayerDeath(victim, attacker, inflictor, damage, dmgType);
}

public void OnMapStart()
{
    PrecacheAndAddToDownloads();
    LoadOwnersFromFile();
    RebuildCharOccupancyFromPlayers();

    Speed_OnMapStart();
    Sonic_OnMapStart();
    Tails_OnMapStart();
    Knuckles_OnMapStart();
    Amy_OnMapStart();
    Sally_OnMapStart();
    Shadow_OnMapStart();
    Rouge_OnMapStart();
    Cream_OnMapStart();
    Metal_OnMapStart();
    Eggman_OnMapStart();
}

public void OnMapEnd()
{
    Sally_OnMapEnd();
    Amy_OnMapEnd();
    Rouge_OnMapEnd();
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    Sonic_OnRoundStart();
    Tails_Event_RoundStart(event, name, dontBroadcast);
    Knux_Event_RoundEnd(event, name, dontBroadcast);

    // v3.12: Resetear el uso de Resurreccion de Cream al iniciar nueva ronda
    Cream_Event_RoundEnd(event, name, dontBroadcast);
}

public void OnClientPutInServer(int client)
{
    g_flNextAllowed[client] = 0.0;
    g_iPlayerSoundIdx[client] = INVALID_SOUND_INDEX;
    g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX;
    g_bSonicHeroMode[client] = false;

    Sonic_OnClientPutInServer(client);
    Knuckles_OnClientPutInServer(client);
    Sally_OnClientPutInServer(client);
    Shadow_OnClientPutInServer(client);
    Rouge_OnClientPutInServer(client);
    Cream_OnClientPutInServer(client);
    Metal_OnClientPutInServer(client);
    Eggman_OnClientPutInServer(client);

    if (AreClientCookiesCached(client))
    {
        LoadPlayerSoundChoice(client);
        LoadPlayerCharChoice(client);
        MaybePromptMenus(client); 
    }
}

public void OnClientCookiesCached(int client)
{
    LoadPlayerSoundChoice(client);
    LoadPlayerCharChoice(client);
    RebuildCharOccupancyFromPlayers();
    MaybePromptMenus(client);
    Speed_OnClientCookiesCached(client);
}

public void OnClientDisconnect(int client)
{
    if (client < 1 || client > MaxClients) return;

    // Liberar personaje asignado
    int cur = g_iPlayerCharIdx[client];
    if (cur >= 0 && cur < MAX_CHARS && g_iCharTakenBy[cur] == client)
        g_iCharTakenBy[cur] = 0;

    g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX;
    g_bSonicHeroMode[client] = false;
    g_iPlayerSoundIdx[client] = INVALID_SOUND_INDEX;
    g_flNextAllowed[client] = 0.0;

    // v3.14: Forzar limpieza de estado de cada modulo
    // (evita fugas de timers y hooks si el cliente se desconecta con abilities activas)
    if (cur == METALSONIC_INDEX) Metal_OnPlayerDeath(client);
    if (cur == ROUGE_INDEX) Rouge_OnPlayerDeath(client);
    if (cur == AMY_INDEX) Amy_OnPlayerDeath(client);
    if (cur == CREAM_INDEX) Cream_OnPlayerDeath(client);
    if (cur == SALLY_INDEX) Sally_OnPlayerDeath(client);
    if (cur == EGGMAN_INDEX) Eggman_OnClientDisconnect(client);

    // Speed_sonic se limpia solo via Event_PlayerDisconnect, pero forzamos aqui tambien
    Speed_OnPlayerDeath(client);
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        char clientName[64]; GetClientName(client, clientName, sizeof(clientName));

        Speed_Event_PlayerSpawn(event, clientName, client);
        Knux_Event_PlayerSpawn(event, clientName, client);
        Shadow_Event_PlayerSpawn(event, clientName, client);
        Rouge_Event_PlayerSpawn(event, clientName, client);
        Cream_Event_PlayerSpawn(event, clientName, client);

        // v3.15: Hook de Eggman spawn (invoca avion de Air Support)
        if (g_iPlayerCharIdx[client] == EGGMAN_INDEX)
        {
            Eggman_OnPlayerSpawn(client);
        }
    }
}

void PrecacheAndAddToDownloads()
{
    for (int i = 0; i < MAX_SOUNDS; i++)
    {
        AddSoundToDownloadsAndPrecache(g_SoundPaths[i]);
    }
}

public Action Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
    // v3.14: Validacion de ConVar null
    if (g_cvSJEnable == null || !g_cvSJEnable.BoolValue) return Plugin_Continue;

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!IsValidClient(client) || !IsSurvivor(client)) return Plugin_Continue;

    // v3.14: Validar g_bTailsFlying antes de acceder
    if (g_iPlayerCharIdx[client] == TAILS_INDEX)
    {
        if (g_bTailsFlying[client]) return Plugin_Continue;
    }

    PlayJumpSound(client);
    TryApplySonicBoostOnJump(client);
    return Plugin_Continue;
}

void PlayJumpSound(int client)
{
    if (client < 1 || client > MaxClients) return;

    int idx = g_iPlayerSoundIdx[client];
    if (idx < 0 || idx >= MAX_SOUNDS) return;

    // v3.14: Validar ConVars antes de usar
    if (g_cvSJCooldown == null || g_cvSJVolume == null) return;

    float now = GetEngineTime();
    if (now < g_flNextAllowed[client]) return;

    g_flNextAllowed[client] = now + g_cvSJCooldown.FloatValue;
    EmitSoundToAll(g_SoundPaths[idx], client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, g_cvSJVolume.FloatValue);
}

void TryApplySonicBoostOnJump(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;

    // v3.14: Validar offsets y ConVars
    if (g_iOff_Velocity == -1) return;
    if (g_cvVelZMin == null || g_cvSonicBoost == null) return;

    float vel[3];
    GetEntDataVector(client, g_iOff_Velocity, vel);

    if (vel[2] >= g_cvVelZMin.FloatValue)
    {
        float mult = g_cvSonicBoost.FloatValue;
        // v3.14: Validar que el multiplicador sea positivo
        if (mult <= 0.0) mult = 1.0;
        vel[2] *= mult;
        SetEntDataVector(client, g_iOff_Velocity, vel);
    }
}

public void OnPlayerSelectCharacter(int client)
{
    if (!IsClientInGame(client)) return;

    int charIdx = g_iPlayerCharIdx[client];
    if (charIdx < 0 || charIdx >= MAX_CHARS) return;

    ClientCommand(client, "bind z sm_sjs_ability1");
    ClientCommand(client, "bind x sm_sjs_ability2");

    char ability1[32], ability2[32];

    switch (charIdx)
    {
        case SONIC_INDEX:      { ability1 = "Homing Attack"; ability2 = "Sonic Wind"; }
        case TAILS_INDEX:      { ability1 = "Laser";         ability2 = "Vuelo"; }
        case KNUCKLES_INDEX:   { ability1 = "Puno";          ability2 = "Counter"; }
        case AMY_INDEX:        { ability1 = "Golpe";         ability2 = "Salto Martillo"; }
        case SALLY_INDEX:      { ability1 = "Escudo Fuego";  ability2 = "Escudo Burbuja"; }
        case SHADOW_INDEX:     { ability1 = "Chaos Snap";    ability2 = "Chaos Blast"; }
        case ROUGE_INDEX:      { ability1 = "Bomba";         ability2 = "Patada"; }
        case CREAM_INDEX:      { ability1 = "Curar";         ability2 = "Revivir"; }
        case METALSONIC_INDEX: { ability1 = "Destructive Charge"; ability2 = "V. Maximum Overdrive"; }
        case EGGMAN_INDEX:     { ability1 = "Badnik Mines";  ability2 = "Death Egg Laser"; }
    }

    PrintToChat(client, "[SonicJump] Personaje: %s", g_CharNames[charIdx]);
    PrintToChat(client, "[Controles] Z: %s | X: %s", ability1, ability2);
}

bool GetClientSteamID(int client, char steam[64])
{
    if (!IsClientAuthorized(client)) return false;
    return GetClientAuthId(client, AuthId_Steam2, steam, sizeof(steam), true);
}

void CharIdxToKey(int idx, char key[8]) { IntToString(idx, key, sizeof(key)); }

bool GetCharOwnerSteam(int idx, char steam[32])
{
    char key[8]; CharIdxToKey(idx, key);
    return g_mCharOwner.GetString(key, steam, sizeof(steam));
}

void SetCharOwnerSteam(int idx, int client)
{
    char steam[32];
    if (!GetClientSteamID(client, steam)) return;
    char key[8]; CharIdxToKey(idx, key);
    g_mCharOwner.SetString(key, steam);
}

void RemoveCharOwner(int idx)
{
    char key[8]; CharIdxToKey(idx, key);
    g_mCharOwner.Remove(key);
}

void ClearAllCharOwners() 
{ 
    g_mCharOwner.Clear(); 
}

bool IsCharAvailableForClient(int idx, int client)
{
    if (g_iCharTakenBy[idx] != 0 && g_iCharTakenBy[idx] != client) return false;
    char ownerSteam[32], clientSteam[32];
    if (GetCharOwnerSteam(idx, ownerSteam)) {
        if (!GetClientSteamID(client, clientSteam)) return false;
        if (!StrEqual(ownerSteam, clientSteam)) return false;
    }
    return true;
}

void LoadOwnersFromFile()
{
    KeyValues kv = new KeyValues("SonicJumpOwners");
    if (!kv.ImportFromFile(g_sOwnersFile)) { delete kv; return; }
    
    ClearAllCharOwners();
    
    if (kv.GotoFirstSubKey(false)) {
        do {
            char key[8]; kv.GetSectionName(key, sizeof(key));
            char steam[32]; kv.GetString("steam64", steam, sizeof(steam), "");
            if (steam[0]) g_mCharOwner.SetString(key, steam);
        } while (kv.GotoNextKey(false));
    }
    delete kv;
}

void SaveOwnersToFile()
{
    KeyValues kv = new KeyValues("SonicJumpOwners");
    for (int i = 0; i < MAX_CHARS; i++) {
        char key[8], steam[32]; CharIdxToKey(i, key);
        if (g_mCharOwner.GetString(key, steam, sizeof(steam))) {
            kv.JumpToKey(key, true); kv.SetString("steam64", steam); kv.GoBack();
        }
    }
    kv.ExportToFile(g_sOwnersFile);
    delete kv;
}

bool IsClientAmyAllowed(int client) { return CheckCommandAccess(client, "sj_amy", ADMFLAG_GENERIC, true); }

void AssignCharacterToClient(int charIdx, int client) { if (!(0 <= charIdx < MAX_CHARS)) return; g_iCharTakenBy[charIdx] = client; }

void RebuildCharOccupancyFromPlayers()
{
    for (int client = 1; client <= MaxClients; client++) {
        if (!IsValidClient(client)) continue;
        int idx = g_iPlayerCharIdx[client];
        
        if (!(0 <= idx < MAX_CHARS) && AreClientCookiesCached(client)) {
            LoadPlayerCharChoice(client); idx = g_iPlayerCharIdx[client];
        }
        
        if (!(0 <= idx < MAX_CHARS)) continue;
        
        if (g_iCharTakenBy[idx] == client) continue; 

        if (IsCharAvailableForClient(idx, client)) {
            AssignCharacterToClient(idx, client); SetCharOwnerSteam(idx, client);
        } else {
            if (g_iCharTakenBy[idx] != 0 && IsClientInGame(g_iCharTakenBy[idx])) {
                g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX;
            } else {
                AssignCharacterToClient(idx, client); SetCharOwnerSteam(idx, client);
            }
        }
    }
    SaveOwnersToFile();
}

public Action Cmd_OpenSoundMenu(int client, int args)
{
    if (!IsValidClient(client)) return Plugin_Handled;
    ShowJumpSoundMenu(client);
    return Plugin_Handled;
}

void ShowJumpSoundMenu(int client)
{
    Menu menu = new Menu(MenuHandler_JumpSound);
    menu.SetTitle("Selecciona sonido de salto");
    char info[8], display[64];
    for (int i = 0; i < MAX_SOUNDS; i++) {
        IntToString(i, info, sizeof(info));
        Format(display, sizeof(display), "%s%s", g_SoundNames[i], (g_iPlayerSoundIdx[client] == i) ? " [Actual]" : "");
        menu.AddItem(info, display);
    }
    menu.AddItem("nosound", "Sin sonido");
    menu.ExitButton = true;
    menu.Display(client, 15);
}

public int MenuHandler_JumpSound(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) delete menu;
    else if (action == MenuAction_Select) {
        char info[16]; menu.GetItem(item, info, sizeof(info));
        if (StrEqual(info, "nosound")) {
            g_iPlayerSoundIdx[client] = INVALID_SOUND_INDEX;
            SetClientCookie(client, g_hSoundCookie, "");
            PrintToChat(client, "[SonicJump] Sonido desactivado.");
            ShowJumpSoundMenu(client); return 0;
        }
        int idx = StringToInt(info);
        g_iPlayerSoundIdx[client] = idx;
        char cookieVal[8]; IntToString(idx, cookieVal, sizeof(cookieVal));
        SetClientCookie(client, g_hSoundCookie, cookieVal);
        PrintToChat(client, "[SonicJump] Sonido: %s", g_SoundNames[idx]);
        if (g_iPlayerCharIdx[client] == INVALID_CHAR_INDEX) ShowCharMenu(client);
        else ShowJumpSoundMenu(client);
    }
    return 0;
}

public Action Cmd_OpenCharMenu(int client, int args)
{
    if (!IsValidClient(client)) return Plugin_Handled;
    ShowCharMenu(client);
    return Plugin_Handled;
}

void ShowCharMenu(int client)
{
    Menu menu = new Menu(MenuHandler_Char);
    menu.SetTitle("Selecciona tu personaje");
    char info[8], display[96];
    char ownerSteam[32], clientSteam[32]; GetClientSteamID(client, clientSteam);

    for (int i = 0; i < MAX_CHARS; i++) {
        IntToString(i, info, sizeof(info));
        bool amy = (i == AMY_INDEX), allowedAmy = IsClientAmyAllowed(client);
        bool takenByOther = (g_iCharTakenBy[i] != 0 && g_iCharTakenBy[i] != client);
        bool ownedByOther = false;
        if (GetCharOwnerSteam(i, ownerSteam)) {
            if (!clientSteam[0] || !StrEqual(ownerSteam, clientSteam)) ownedByOther = true;
        }
        bool disabled = takenByOther || ownedByOther || (amy && !allowedAmy);
        char status[48] = "";
        if (disabled) strcopy(status, sizeof(status), " (No disponible)");
        else if (g_iPlayerCharIdx[client] == i) strcopy(status, sizeof(status), " [Actual]");
        Format(display, sizeof(display), "%s%s", g_CharNames[i], status);
        menu.AddItem(info, display, disabled ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }
    menu.AddItem("nochar", "Sin personaje");
    menu.ExitButton = true;
    menu.Display(client, 20);
}

public int MenuHandler_Char(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) delete menu;
    else if (action == MenuAction_Select) {
        char info[16]; menu.GetItem(item, info, sizeof(info));
        if (StrEqual(info, "nochar")) {
            int prev = g_iPlayerCharIdx[client];
            if (0 <= prev < MAX_CHARS) {
                if (g_iCharTakenBy[prev] == client) g_iCharTakenBy[prev] = 0;
                char ownerSteam[32], clientSteam[32];
                if (GetCharOwnerSteam(prev, ownerSteam) && GetClientSteamID(client, clientSteam) && StrEqual(ownerSteam, clientSteam)) {
                    RemoveCharOwner(prev); SaveOwnersToFile();
                }
            }
            g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX;
            SetClientCookie(client, g_hCharCookie, "");
            PrintToChat(client, "[SonicJump] Personaje desactivado.");
            if (g_iPlayerSoundIdx[client] == INVALID_SOUND_INDEX) ShowJumpSoundMenu(client);
            else ShowCharMenu(client);
            return 0;
        }
        int idx = StringToInt(info);
        if (idx == AMY_INDEX && !IsClientAmyAllowed(client)) {
            PrintToChat(client, "[SonicJump] Amy es exclusiva."); ShowCharMenu(client); return 0;
        }
        if (!IsCharAvailableForClient(idx, client)) {
            PrintToChat(client, "[SonicJump] %s no disponible.", g_CharNames[idx]); ShowCharMenu(client); return 0;
        }
        int prev = g_iPlayerCharIdx[client];
        if (0 <= prev < MAX_CHARS && g_iCharTakenBy[prev] == client) g_iCharTakenBy[prev] = 0;
        AssignCharacterToClient(idx, client);
        g_iPlayerCharIdx[client] = idx;
        char cookie[8]; IntToString(idx, cookie, sizeof(cookie));
        SetClientCookie(client, g_hCharCookie, cookie);
        SetCharOwnerSteam(idx, client); SaveOwnersToFile();

        OnPlayerSelectCharacter(client);

        if (g_iPlayerSoundIdx[client] == INVALID_SOUND_INDEX) ShowJumpSoundMenu(client);
        else ShowCharMenu(client);
    }
    return 0;
}

public Action Cmd_FreeAllChars(int client, int args)
{
    ClearAllCharOwners(); SaveOwnersToFile();
    for (int i = 0; i < MAX_CHARS; i++) g_iCharTakenBy[i] = 0;
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
        g_iPlayerCharIdx[i] = INVALID_CHAR_INDEX;
    }
    PrintToChatAll("[SonicJump] Personajes liberados.");
    return Plugin_Handled;
}

void LoadPlayerSoundChoice(int client)
{
    if (!IsValidClient(client)) return;
    char buf[8]; GetClientCookie(client, g_hSoundCookie, buf, sizeof(buf));
    if (!buf[0]) return;
    int idx = StringToInt(buf);
    g_iPlayerSoundIdx[client] = (0 <= idx < MAX_SOUNDS) ? idx : INVALID_SOUND_INDEX;
}

void LoadPlayerCharChoice(int client)
{
    if (!IsValidClient(client)) return;
    char buf[8]; GetClientCookie(client, g_hCharCookie, buf, sizeof(buf));
    if (!buf[0]) return;
    int idx = StringToInt(buf);
    if (!(0 <= idx < MAX_CHARS)) { g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX; return; }
    if (idx == AMY_INDEX && !IsClientAmyAllowed(client)) {
        g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX; SetClientCookie(client, g_hCharCookie, ""); return;
    }
    if (!IsCharAvailableForClient(idx, client)) {
        g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX; return;
    }
    AssignCharacterToClient(idx, client);
    g_iPlayerCharIdx[client] = idx;
    SetCharOwnerSteam(idx, client); SaveOwnersToFile();
}

void MaybePromptMenus(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] == INVALID_CHAR_INDEX) { ShowCharMenu(client); return; }
    if (g_iPlayerSoundIdx[client] == INVALID_SOUND_INDEX) { ShowJumpSoundMenu(client); return; }
}

public Action Cmd_ShowCharInfo(int client, int args)
{
    char steam[64]; GetClientSteamID(client, steam);
    PrintToChat(client, "[SonicJump] ID: %s | Snd: %d | Char: %d", steam, g_iPlayerSoundIdx[client], g_iPlayerCharIdx[client]);
    return Plugin_Handled;
}

public Action L4D_OnEntityKilled(int victim, int attacker, int inflictor)
{
    if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker)) {
        if (g_iPlayerCharIdx[attacker] == SONIC_INDEX) Sonic_OnKillInfected_Explosion(attacker, victim);
    }
    return Plugin_Continue;
}

public void CreateSonicRagdoll(int client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos); GetClientAbsAngles(client, ang); GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    char model[PLATFORM_MAX_PATH]; GetClientModel(client, model, sizeof(model));
    int ent = CreateEntityByName("prop_ragdoll");
    if (ent == -1) return;
    DispatchKeyValue(ent, "model", model); DispatchKeyValue(ent, "spawnflags", "4");
    DispatchSpawn(ent); TeleportEntity(ent, pos, ang, vel);
    SetEntityRenderColor(ent, 255, 255, 255, 255); SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
    SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
    SetVariantString("OnUser1 !self:kill::15.0:1"); AcceptEntityInput(ent, "AddOutput"); AcceptEntityInput(ent, "FireUser1");
}

int SafeGetEntDataEnt(int entity, int offset)
{
    if (offset == -1) return -1;
    return GetEntDataEnt2(entity, offset);
}