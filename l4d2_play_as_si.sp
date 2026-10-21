#pragma semicolon 1
// Use it zombieClass
#define PLAYABLE_SMOKER 1
#define PLAYABLE_BOOMER 2
#define PLAYABLE_HUNTER 3
#define PLAYABLE_SPITTER 4
#define PLAYABLE_JOCKEY 5
#define PLAYABLE_CHARGER 6
#define PLAYABLE_WITCH 7 // Custom Define. Not m_zombieClass Number
#define PLAYABLE_TANK 8

#define TEAM_SPECTATOR 1
#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3

// #define SOUND_BOOMER "sound/player/tank/voice/die/tank_death_01.wav"
#define SOUND_BOOMER_BITE "player/smoker/miss/cow_licklips_slurp2.wav"
#define SOUND_BOOMER "player/tank/voice/die/tank_death_01.wav"
#define SOUND_HEGRENADE_EXPLODE "weapons/hegrenade/explode3.wav"
#define SOUND_CHARGER_LOUD_CHARGERIMPACT "player/charger/loud_chargerimpact_03.wav"
#define PARTICLE_PIPEBOMB "weapon_pipebomb"
#define PARTICLE_BOOMER_EXPLODE "boomer_explode"
#define MODEL_BEAM "materials/sprites/laserbeam.vmt"
#define MODEL_HALO "materials/sprites/glow01.vmt"
#define MODEL_PIPEBOMB "models/w_models/weapons/w_eq_pipebomb.mdl"


char infectedNameTable[][] =
{
    "InvalidInfectedName0",
    "Smoker",
    "Boomer",
    "Hunter",
    "Spitter",
    "Jockey",
    "Charger",
    "Witch",
    "Tank"
};

char infectedWeaponNameTable[][] =
{
    "InvalidInfectedWeapon0",
    "smoker_claw",
    "boomer_claw",
    "hunter_claw",
    "spitter_claw",
    "jockey_claw",
    "charger_claw",
    "InvalidInfectedWeapon7",
    "tank_claw"
};

char infectedAbilityTable[][] =
{
    "InvalidInfectedAbility0",
    "ability_tongue",
    "ability_vomit", // ability_selfdestruct
    "ability_lunge",
    "ability_spit",
    "ability_leap",
    "ability_charge",
    "InvalidInfectedAbility7",
    "ability_throw"
};

char infectedModelNameTable[][] =
{
    "InvalidInfectedModel0",
    "models/infected/smoker.mdl",
    "models/infected/boomer.mdl",
    "models/infected/hunter.mdl",
    "models/infected/spitter.mdl",
    "models/infected/jockey.mdl",
    "models/infected/charger.mdl",
    "models/infected/witch.mdl",
    "models/infected/hulk.mdl"
};

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#include "l4d2_play_as_si/stocks.sp"

methodmap PlayerZombie < ArrayList
{
    public PlayerZombie()
    {
        return view_as<PlayerZombie>(new ArrayList(1, 4));
    }

    property int Owner
    {
        public get() { return this.Get(0); }
        public set(int value) { this.Set(0, value); }
    }

    property int ZombieClass
    {
        public get() { return this.Get(1); }
        public set(int value) { this.Set(1, value); }
    }

    property int Health
    {
        public get() { return this.Get(2); }
        public set(int value) { this.Set(2, value); }
    }

    property int MaxHealth
    {
        public get() { return this.Get(3); }
        public set(int value) { this.Set(3, value); }
    }
}

PlayerZombie g_hPlayerZombie[MAXPLAYERS + 1];
Handle g_hWeaponCheckTimer[MAXPLAYERS + 1];

int g_iBeam;
int g_iGlow;


#include "l4d2_play_as_si/playable/smoker.sp"
#include "l4d2_play_as_si/playable/boomer.sp"
#include "l4d2_play_as_si/playable/hunter.sp"
#include "l4d2_play_as_si/playable/spitter.sp"
#include "l4d2_play_as_si/playable/jockey.sp"
#include "l4d2_play_as_si/playable/charger.sp"
// #include "l4d2_play_as_si/playable/witch.sp"
#include "l4d2_play_as_si/playable/tank.sp"

public Plugin myinfo =
{
    name = "Play as Special Infected",
    author = "Pure_*",
    description = "Allows player to play special infected in coop mode",
    version = "1.2",
    url = "https://forums.alliedmods.net/showthread.php?t=350892"
}

public void OnPluginStart()
{
    LoadTranslationsWithCheck();
    
    RegAdminCmd("sm_playassi", Command_PlayAsSI, ADMFLAG_SLAY);
    RegConsoleCmd("sm_playasmenu", ConsoleCommand_TransformMenu);
    RegConsoleCmd("sm_quitsi", Command_QuitSI);

    HookEvent("heal_success", OnHealSuccess);
    HookEvent("player_incapacitated", OnPlayerIncapacitated);
    HookEvent("player_death", OnPlayerDeath);
    HookEvent("player_bot_replace", OnPlayerReplacedByBot);
    HookEvent("bot_player_replace", OnBotReplacedByPlayer);
    HookEvent("round_end", OnRoundEnd);
    HookEvent("finale_win", OnRoundEnd);
    HookEvent("mission_lost", OnRoundEnd);
    HookEvent("map_transition", OnRoundEnd);

    AddSmokerConVar();
    AddBoomerConVars();
    AddHunterConVars();
    AddSpitterConVars();
    AddJockeyConVars();
    AddChargerConVars();
    // AddWitchConVars();
    AddTankConVars();
    
    AutoExecConfig(true, "l4d2_play_as_si");

    AfterConvarConfigExec_Boomer();
}

// !rcon sm plugins reload l4d2_play_as_si
// #region OnMapStart
public void OnMapStart()
{
    PrecacheEffect("ParticleEffect");
    PrecacheParticleEffect(PARTICLE_PIPEBOMB);
    PrecacheParticleEffect(PARTICLE_BOOMER_EXPLODE);
    PrecacheSound(SOUND_HEGRENADE_EXPLODE, true);
    PrecacheSound(SOUND_CHARGER_LOUD_CHARGERIMPACT, true);
    PrecacheSound(SOUND_BOOMER_BITE, true);
    PrecacheModel(MODEL_PIPEBOMB, true);
    PrecacheSound(SOUND_BOOMER, true);
    g_iBeam = PrecacheModel(MODEL_BEAM, true);
    g_iGlow = PrecacheModel(MODEL_HALO, true);
    for(int i = 1; i <= 8; i++)
    {
        PrecacheModel(infectedModelNameTable[i], true);
    }
}

// #region System Events
public void OnHealSuccess(Event event, const char[] name, bool dontBroadcast)
{
    int patient = GetClientOfUserId(GetEventInt(event, "subject"));
    if(g_hPlayerZombie[patient] == null) return;

    int amount = -1;
    switch(g_hPlayerZombie[patient].ZombieClass)
    {
        case PLAYABLE_SMOKER: amount = GetConVarInt(g_hCvarSmokerHealPoint);
        case PLAYABLE_BOOMER: amount = GetConVarInt(g_hCvarBoomerHealPoint);
        case PLAYABLE_HUNTER: amount = GetConVarInt(g_hCvarHunterHealPoint);
        case PLAYABLE_SPITTER: amount = GetConVarInt(g_hCvarSpitterHealPoint);
        case PLAYABLE_JOCKEY: amount = GetConVarInt(g_hCvarJockeyHealPoint);
        case PLAYABLE_CHARGER: amount = GetConVarInt(g_hCvarChargerHealPoint);
        case PLAYABLE_TANK: amount = GetConVarInt(g_hCvarTankHealPoint);
    }

    if(amount != -1)
    {
        SetPlayerHealth(patient, amount);
    }
}

public void OnPlayerIncapacitated(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    if(g_hPlayerZombie[victim] == null) return;

    if(IsClientValid(victim))
    {
        ClearPlayerZombie(victim);
        ForcePlayerSuicide(victim);
    }
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    // int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    if(IsClientValid(victim) && g_hPlayerZombie[victim] != null)
    {
        if(g_hPlayerZombie[victim].ZombieClass == PLAYABLE_BOOMER)
        {
            OnBoomerDeath(victim);
        }
        ClearPlayerZombie(victim);
        CloseHandleSafety(g_hPlayerZombie[victim]);
        RequestFrame(RespawnPlayer, victim);
    }
}

public void OnPlayerReplacedByBot(Event event, const char[] name, bool dontBroadcast)
{
    // short	player	user ID of the player
    // short	bot	user ID of the bot
    int player = GetClientOfUserId(GetEventInt(event, "player"));
    int bot = GetClientOfUserId(GetEventInt(event, "bot"));
    if(g_hPlayerZombie[player] == null) return;

    ClearPlayerZombie(player);

    g_hPlayerZombie[bot] = g_hPlayerZombie[player];
    g_hPlayerZombie[player] = null;
    g_hPlayerZombie[bot].Owner = bot;
    g_hPlayerZombie[bot].Health = GetEntProp(player, Prop_Data, "m_iHealth");
    ApplyPlayerZombieClass(bot);
}

public void OnBotReplacedByPlayer(Event event, const char[] name, bool dontBroadcast)
{
    // short	bot	user ID of the bot
    // short	player	user ID of the player
    int player = GetClientOfUserId(GetEventInt(event, "player"));
    int bot = GetClientOfUserId(GetEventInt(event, "bot"));
    if(g_hPlayerZombie[bot] == null) return;

    ClearPlayerZombie(bot);

    g_hPlayerZombie[player] = g_hPlayerZombie[bot];
    g_hPlayerZombie[bot] = null;
    g_hPlayerZombie[player].Owner = player;
    g_hPlayerZombie[player].Health = GetEntProp(bot, Prop_Data, "m_iHealth");
    ApplyPlayerZombieClass(player);
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    // Clear Survivor-SI
    // Don't clear Data, inorder to cross chapters and restore
    for(int i = 1; i <= MAXPLAYERS; i++)
    {
        if(g_hPlayerZombie[i] != null)
        {
            if(IsSurvivor(i))
            {
                g_hPlayerZombie[i].Health = GetEntProp(i, Prop_Data, "m_iHealth");
                ClearPlayerZombie(i);
            }
            else
            {
                CloseHandleSafety(g_hPlayerZombie[i]);
                continue;
            }
            CloseHandleSafety(g_hWeaponCheckTimer[i]);
            if(StrEqual(name, "finale_win", false) || StrEqual(name, "mission_lost", false))
            {
                CloseHandleSafety(g_hPlayerZombie[i]);
            }
        }
    }
}


// #region Forwards
public void L4D_OnFirstSurvivorLeftSafeArea_Post(int client)
{
    // Restore Survivor-SI
    for(int i = 1; i <= MAXPLAYERS; i++)
    {
        if(g_hPlayerZombie[i] == null) continue;

        // !rcon sm plugins reload l4d2_play_as_si
        if(IsSurvivor(i) && IsPlayerAlive(i))
        {
            ApplyPlayerZombieClass(i);
        }
        else
        {
            CloseHandleSafety(g_hPlayerZombie[i]);
        }
    }
}

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
    // Most condition, player is not Survivor-SI
    if(g_hPlayerZombie[client] != null && (buttons & IN_RELOAD))
    {
        int victim = L4D_GetVictimHunter(client);
        if(g_hPlayerZombie[client].ZombieClass == PLAYABLE_HUNTER && victim)
        {
            L4D_Hunter_ReleaseVictim(victim, client);
            return;
        }
        victim = L4D_GetVictimJockey(client);
        if(g_hPlayerZombie[client].ZombieClass == PLAYABLE_JOCKEY && victim)
        {
            L4D2_Jockey_EndRide(victim, client);
            return;
        }
        victim = L4D_GetVictimSmoker(client);
        if(g_hPlayerZombie[client].ZombieClass == PLAYABLE_SMOKER && victim)
        {
            L4D_Smoker_ReleaseVictim(victim, client);
            return;
        }
    }
}

public void L4D_OnDoAnimationEvent_Post(int client, int event, int variant_param)
{
    if(g_hPlayerZombie[client] == null) return;
    // if(playerStatus[client] && playerStatus[client] != PLAYABLE_TANK && (event == PLAYERANIMEVENT_HAND_ATTACK || event == PLAYERANIMEVENT_HAND_LOW_ATTACK))
    if(g_hPlayerZombie[client].ZombieClass != PLAYABLE_TANK && (event == 33 || event == 34))
    {
        RequestFrame(DOClawDamage, client);
    }
}

void DOClawDamage(int client)
{
    if(g_hPlayerZombie[client] == null) return;

    float damage = -1.0;
    switch(g_hPlayerZombie[client].ZombieClass)
    {
        case PLAYABLE_SMOKER: damage = GetConVarFloat(g_hCvarSmokerClawDmg);
        case PLAYABLE_BOOMER: damage = GetConVarFloat(g_hCvarBoomerClawDmg);
        case PLAYABLE_HUNTER: damage = GetConVarFloat(g_hCvarHunterClawDmg);
        case PLAYABLE_SPITTER: damage = GetConVarFloat(g_hCvarSpitterClawDmg);
        case PLAYABLE_JOCKEY: damage = GetConVarFloat(g_hCvarJockeyClawDmg);
        case PLAYABLE_CHARGER: damage = GetConVarFloat(g_hCvarChargerClawDmg);
    }

    if(damage <= 0.0)
        return;

    float center[3]; GetAbsOrigin(client, center);
    float pos[3];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsInfected(i) || !IsPlayerAlive(i))
            continue;

        GetAbsOrigin(i, pos);
        if(GetVectorDistance(center, pos, true) <= 10000.0)
        {
            SDKHooks_TakeDamage(i, client, client, damage, DMG_SLASH, -1, NULL_VECTOR, NULL_VECTOR, false);
        }
    }

    char classname[9];
    for(int i = MAXPLAYERS; i <= GetMaxEntities(); i++)
    {
        if(!IsValidEntity(i)) continue;

        GetEntityClassname(i, classname, 9);
        if(classname[0] != 'i' && classname[0] != 'w')
            continue;

        if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
        {
            GetAbsOrigin(i, pos);
            if(GetVectorDistance(center, pos, true) <= 10000.0)
            {
                SDKHooks_TakeDamage(i, client, client, damage, DMG_SLASH, -1, NULL_VECTOR, NULL_VECTOR, false);
            }
        }
    }
}

// #region Translation
void LoadTranslationsWithCheck()
{
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "translations/l4d2_play_as_si.phrases.txt");
    if(FileExists(path))
    {
        LoadTranslations("l4d2_play_as_si.phrases.txt");
    }
    else
    {
        LogError("l4d2_play_as_si.phrases.txt is not existed");
    }
}

// #region Timer
Action RepeatTimer_WeaponCheck(Handle timer, int client)
{
    // Check primary weapon
    // Remove secondary, throwable, medkit, pill
    if(g_hPlayerZombie[client] == null)
    {
        g_hWeaponCheckTimer[client] = null;
        return Plugin_Stop;
    }
    // !rcon sm plugins reload l4d2_play_as_si
    if(!IsClientValid(client))
    {
        CloseHandleSafety(g_hPlayerZombie[client]);
        g_hWeaponCheckTimer[client] = null;
        return Plugin_Stop;
    }

    int weapon = GetPlayerWeaponSlot(client, 0);
    if(weapon == -1)
    {
        ClearPlayerZombie(client);
        g_hWeaponCheckTimer[client] = null;
        ForcePlayerSuicide(client);
        return Plugin_Stop;
    }
    char classname[32]; GetEntityClassname(weapon, classname, 32);
    int zombieClass = g_hPlayerZombie[client].ZombieClass;
    if(StrContains(classname, infectedWeaponNameTable[zombieClass], false) != -1)
    {
        for(int i = 1; i <= 4; i++)
        {
            weapon = GetPlayerWeaponSlot(client, i);
            DeleteEntity(weapon);
        }
        return Plugin_Continue;
    }
    else
    {
        g_hWeaponCheckTimer[client] = null;
        ClearPlayerZombie(client);
        ForcePlayerSuicide(client);

        return Plugin_Stop;
    }
}

// #region SDKHooks
Action SDKHook_OnWeaponSwitch(int client, int weapon)
{
    return g_hPlayerZombie[client] == null ? Plugin_Continue : Plugin_Handled;   
}

// #region Command
Action Command_QuitSI(int client, int args)
{ 
    if(g_hPlayerZombie[client] != null)
    {
        ForcePlayerSuicide(client);
    }

    return Plugin_Continue;
}

Action Command_PlayAsSI(int client, int args)
{
    int player = GetCmdArgInt(1);
    if (!IsSurvivor(player)) return Plugin_Handled;
    // if (!IsPlayerAlive(player) || !L4D_HasAnySurvivorLeftSafeArea())
    if (!IsPlayerAlive(player))
    {
        PrintHintText(player, "%t", "Player Left Safe Area Check");
        return Plugin_Handled;
    }

    int zombieClass = GetCmdArgInt(2);
    if(!IsClientInGame(player) || !IsPlayerAlive(player))
    {
        PrintHintText(player, "%t", "Dead and Spectator Check");
        return Plugin_Handled;
    }

    if(zombieClass <= 0 || zombieClass > 8)
    {
        PrintHintText(player, "%t", "Invalid Infected ID");
        return Plugin_Handled;
    }
    if(zombieClass == 7)
    {
        PrintHintText(player, "Can't Play Now");
        return Plugin_Handled;
    }
    // Check player debuff and remove
    Revive(player);

    if(g_hPlayerZombie[player] != null)
    {
        ClearPlayerZombie(player);
    }

    CloseHandleSafety(g_hPlayerZombie[player]);
    CloseHandleSafety(g_hWeaponCheckTimer[player]);
    // !rcon sm plugins reload l4d2_play_as_si
    
    g_hPlayerZombie[player] = new PlayerZombie();
    g_hPlayerZombie[player].Owner = player;
    g_hPlayerZombie[player].ZombieClass = zombieClass;
    g_hPlayerZombie[player].Health = GetZombieMaxHealth(zombieClass);
    g_hPlayerZombie[player].MaxHealth = GetZombieMaxHealth(zombieClass);

    RequestFrame(ApplyPlayerZombieClass, player);
    
    return Plugin_Continue;
}

void ApplyPlayerZombieClass(int client)
{
    if(g_hPlayerZombie[client] == null) return;
    int zombieClass = g_hPlayerZombie[client].ZombieClass;

    // Set to Team-Infected
    // *_claw can only be given when player is in infected team
    SetEntProp(client, Prop_Send, "m_iTeamNum", TEAM_INFECTED);
    SetEntProp(client, Prop_Send, "m_zombieClass", zombieClass);
    SetEntityModel(client, infectedModelNameTable[zombieClass]);
    CheatCommand(client, "give", infectedWeaponNameTable[zombieClass]);
    SetEntProp(client, Prop_Send, "m_iTeamNum", TEAM_SURVIVOR);
    // Create ability
    int ability = CreateEntityByName(infectedAbilityTable[zombieClass]);
    if(ability != -1)
    {
        DispatchSpawn(ability);

        Handle onAbilityCreated = null;
    
        if(onAbilityCreated == null)
        {
            StartPrepSDKCall(SDKCall_Entity);
            PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
            // Access function CBaseAbility::OnCreate of current ability
            // 206 for linux | 205 for windows | Mac? Who knows!
            int osOffset = GetOSType() == OS_linux ? 206 : 205;
            // from https://forums.alliedmods.net/showthread.php?t=327961
            PrepSDKCall_SetAddress(view_as<Address>(LoadFromAddress(view_as<Address>(LoadFromAddress(GetEntityAddress(ability), NumberType_Int32) + osOffset * 4), NumberType_Int32)));
            onAbilityCreated = EndPrepSDKCall();
        }
        SDKCall(onAbilityCreated, ability, client);  // need to call this
        SetEntPropEnt(client, Prop_Send, "m_customAbility", ability);
        SetEntPropEnt(ability, Prop_Send, "m_hOwnerEntity", client);
        CloseHandle(onAbilityCreated);
    }

    SetEntProp(client, Prop_Data, "m_iHealth", g_hPlayerZombie[client].Health);
    SetEntProp(client, Prop_Data, "m_iMaxHealth", g_hPlayerZombie[client].MaxHealth);
    // disable switch weapon
    SDKHook(client, SDKHook_WeaponSwitch, SDKHook_OnWeaponSwitch);

    CloseHandleSafety(g_hWeaponCheckTimer[client]);
    g_hWeaponCheckTimer[client] = CreateTimer(1.0, RepeatTimer_WeaponCheck, client, TIMER_REPEAT);
}

Action ConsoleCommand_TransformMenu(int client, int args)
{
    if(!IsSurvivor(client) || !IsPlayerAlive(client) || IsFakeClient(client)) return Plugin_Handled;

    Menu menu = new Menu(MenuHandler_TransformMenu);
    menu.SetTitle("Play As SI Menu");
    for(int i = 0; i <= 8; i++)
    {
        if(i == 7) continue;  // Skip Witch
        if(i == 0)
        {
            if(g_hPlayerZombie[client] != null)
            {
                menu.AddItem("0", "Exit");
            }
        }
        else
        {
            if(g_hPlayerZombie[client] != null && g_hPlayerZombie[client].ZombieClass == i)
            {
                continue;
            }
            else
            {
                char item[8]; Format(item, 8, "%d", i);
                menu.AddItem(item, infectedNameTable[i]);
            }
        }
    }
    menu.Display(client, MENU_TIME_FOREVER);
    return Plugin_Continue;
}

int MenuHandler_TransformMenu(Menu menu, MenuAction action, int client, int option)
{
    if(action == MenuAction_Select)
    {
        char item[8]; menu.GetItem(option, item, 8);
        int index = StringToInt(item);
        if(index == 0)
        {
            ClearPlayerZombie(client);
            CloseHandleSafety(g_hWeaponCheckTimer[client]);
            g_hWeaponCheckTimer[client] = null;
            ForcePlayerSuicide(client);
        }
        else
        {
            Format(item, 8, "%d %s", client, item);
            CheatCommand(client, "sm_playassi", item);
        }
        delete menu;
    }
    else
    {
        delete menu;
    }
    return 0;
}

// #region Dependent Utils
int GetZombieMaxHealth(int zombieClass)
{
    int hp = 100;
    switch(zombieClass)
    {
        case PLAYABLE_SMOKER: hp = GetConVarInt(g_hCvarSmokerHp);
        case PLAYABLE_BOOMER: hp = GetConVarInt(g_hCvarBoomerHp);
        case PLAYABLE_HUNTER: hp = GetConVarInt(g_hCvarHunterHp);
        case PLAYABLE_SPITTER: hp = GetConVarInt(g_hCvarSpitterHp);
        case PLAYABLE_JOCKEY: hp = GetConVarInt(g_hCvarJockeyHp);
        case PLAYABLE_CHARGER: hp = GetConVarInt(g_hCvarChargerHp);
        case PLAYABLE_TANK: hp = GetConVarInt(g_hCvarTankHp);
    }
    return hp;
}

void ClearPlayerZombie(int client)
{
    if(g_hPlayerZombie[client] == null) return;
    switch(g_hPlayerZombie[client].ZombieClass)
    {
        case PLAYABLE_SMOKER: ClearPlayerSmoker(client);
        case PLAYABLE_BOOMER: ClearPlayerBoomer(client);
        case PLAYABLE_HUNTER: ClearPlayerHunter(client);
        // case PLAYABLE_SPITTER: ClearPlayerSpitter(client);
        case PLAYABLE_JOCKEY: ClearPlayerJockey(client);
        case PLAYABLE_CHARGER: ClearPlayerCharger(client);
        // case PLAYABLE_TANK: ClearPlayerTank(client);
    }

    DeleteEntity(L4D_GetPlayerCustomAbility(client));
    int weapon = GetPlayerWeaponSlot(client, 0);
    if(weapon != -1 && IsValidEntity(weapon))
    {
        RemovePlayerItem(client, weapon);
        DeleteEntity(weapon);
    }
    SetEntPropEnt(client, Prop_Send, "m_customAbility", -1);
    SDKUnhook(client, SDKHook_WeaponSwitch, SDKHook_OnWeaponSwitch);
    CloseHandleSafety(g_hWeaponCheckTimer[client]);
}


// #region Block Infected-SI control Survivor-SI

public Action L4D_OnPouncedOnSurvivor(int victim, int attacker)
{
    return g_hPlayerZombie[victim] != null ? Plugin_Handled : Plugin_Continue;
}

public Action L4D_OnGrabWithTongue(int victim, int attacker)
{
    return g_hPlayerZombie[victim] != null ? Plugin_Handled : Plugin_Continue;
}

public Action L4D2_OnSlammedSurvivor(int victim, int attacker, bool &bWallSlam, bool &bDeadlyCharge)
{
    return g_hPlayerZombie[victim] != null ? Plugin_Handled : Plugin_Continue;
}

public Action L4D2_OnStartCarryingVictim(int victim, int attacker)
{
    return g_hPlayerZombie[victim] != null ? Plugin_Handled : Plugin_Continue;
}

public Action L4D2_OnPummelVictim(int attacker, int victim)
{
    return g_hPlayerZombie[victim] != null ? Plugin_Handled : Plugin_Continue;
}

public Action L4D2_OnJockeyRide(int victim, int attacker)
{
    return g_hPlayerZombie[victim] != null ? Plugin_Handled : Plugin_Continue;
}

// public Action L4D_OnVomitedUpon(int victim, int &attacker, bool &boomerExplosion)
// {
//     return g_hPlayerZombie[victim] != null ? Plugin_Handled : Plugin_Continue;
// }

public Action L4D2_OnPlayerFling(int client, int attacker, float vecDir[3])
{
    return g_hPlayerZombie[client] != null ? Plugin_Handled : Plugin_Continue;
}