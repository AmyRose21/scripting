#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>


#include "l4d2_play_as_si/external.sp"

#include "l4d2_play_as_si/consts.sp"
#include "l4d2_play_as_si/variables.sp"
#include "l4d2_play_as_si/stocks.sp"
#include "l4d2_play_as_si/hooks.sp"

#include "l4d2_play_as_si/playable/smoker.sp"
#include "l4d2_play_as_si/playable/boomer.sp"
#include "l4d2_play_as_si/playable/hunter.sp"
#include "l4d2_play_as_si/playable/spitter.sp"
#include "l4d2_play_as_si/playable/jockey.sp"
#include "l4d2_play_as_si/playable/charger.sp"
// #include "l4d2_play_as_si/playable/witch.sp"
#include "l4d2_play_as_si/playable/tank.sp"

#include "l4d2_play_as_si/events.sp"
// #include "l4d2_play_as_si/hud.sp"

// Timer tracking to prevent orphaned timers on disconnect
// Mantenemos esto porque es seguro y evita errores de "Client not in game"
Handle timerSpawnPostCheck[MAXPLAYERS + 1];

public Plugin PlayAsSIPlugin =
{
    name = "Play as Special Infected",
    author = "Pure_*",
    description = "Allows player to play special infected in coop mode",
    version = "1.2", // Version bump for fix
    url = "https://forums.alliedmods.net/showthread.php?t=350892"
}

public void OnPluginStart()
{
    LoadTranslationsWithCheck();
    
    RegAdminCmd("sm_playassi", Command_PlayAsSI, ADMFLAG_SLAY);
    RegConsoleCmd("sm_quitsi", Command_QuitSI);

    HookEvent("heal_success", OnHealSuccess);
    HookEvent("ability_use", OnAbilityUse);
    HookEvent("player_hurt", OnPlayerHurt);
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
    
}


// !rcon sm plugins reload l4d2_play_as_si

public void OnMapStart()
{
    PrecacheEffect("ParticleEffect");
    PrecacheParticleEffect("weapon_pipebomb");
    PrecacheParticleEffect("explosion_huge");
    PrecacheSound("weapons/hegrenade/explode3.wav", true);
    PrecacheSound("player/charger/loud_chargerimpact_03.wav", true);
    PrecacheModel("models/w_models/weapons/w_eq_pipebomb.mdl", true);
    for(int i = 1; i <= 8; i++)
    {
        PrecacheModel(infectedModelNameTable[i], true);
    }
}


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

Action Command_QuitSI(int client, int args)
{ 
    if(playerStatus[client])
    {
        ForcePlayerSuicide(client);
    }
    return Plugin_Continue;
}

Action Command_PlayAsSI(int client, int args)
{
    int player = GetCmdArgInt(1);
    if (!client || !IsClientInGame(client) || !L4D_HasAnySurvivorLeftSafeArea())
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
    if(playerStatus[player])
    {
        PrintHintText(player, "%t", "Already Survivor-SI Check");
        return Plugin_Handled;
    }
    if(zombieClass < 0 || zombieClass > 8)
    {
        PrintHintText(player, "%t", "Invalid Infected ID");
        return Plugin_Handled;
    }
    if(zombieClass == 7)
    {
        PrintHintText(player, "Can't Play Now");
        // playerStatus[player] = zombieClass;
        // // SetEntityModel(player, infectedModelNameTable[zombieClass]);
        // OnWitchSuccess(player);
        return Plugin_Handled;
    }
    // Check player debuff and remove
    Revive(player);
    // Disable Away_From_KeyBoard
    TryDisableAfk(player);

    playerStatus[player] = zombieClass;

    // Set to Team-Infected
    // *_claw can only be given when player is in infected team 
    SetEntProp(player, Prop_Send, "m_iTeamNum", TEAM_INFECTED);
    SetEntityModel(player, infectedModelNameTable[zombieClass]);
    CheatCommand(player, "give", infectedWeaponNameTable[zombieClass]);
    SetEntProp(player, Prop_Send, "m_iTeamNum", TEAM_SURVIVOR);
    // Create ability
    int ability = CreateEntityByName(infectedAbilityTable[zombieClass]);
    if(ability != -1)
    {
        DispatchSpawn(ability);

        // REVERTIDO: Usamos Handle local. Es necesario recalcular la dirección cada vez
        // porque la entidad 'ability' cambia en cada spawn.
        Handle onAbilityCreated;
    
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
        SDKCall(onAbilityCreated, ability, player);  // need to call this
        SetEntPropEnt(player, Prop_Send, "m_customAbility", ability);
        
        // IMPORTANTE: Cerrar el handle aquí para evitar memory leak
        CloseHandle(onAbilityCreated);
    }
    // disable switch weapon
    SDKHook(player, SDKHook_WeaponSwitch, OnWeaponSwitch);

    // FIX: Track timer to prevent leaks (Mantenemos esto, es seguro)
    KillTimerSafety(timerSpawnPostCheck[player]);
    timerSpawnPostCheck[player] = CreateTimer(1.0, OnSpawnPostCheck, player);
    
    return Plugin_Continue;
}

Action OnSpawnPostCheck(Handle timer, int client)
{
    timerSpawnPostCheck[client] = null; // Reset handle

    if(!IsClientInGame(client) || !IsPlayerAlive(client))
    {
        SDKUnhook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
        playerStatus[client] = 0;
        return Plugin_Stop;
    }
    char modelName[32];
    GetClientModel(client, modelName, 32);
    char zombieName[8];
    bool isSuccess = false;
    if(playerStatus[client])
    {
        isSuccess = StrEqual(modelName, infectedModelNameTable[playerStatus[client]], false);
        Format(zombieName, 8, infectedNameTable[playerStatus[client]]);
    }

    if(!isSuccess)
    {
        playerStatus[client] = 0;
        ForcePlayerSuicide(client);
        SDKUnhook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
        RequestFrame(RespawnPlayer, client);

        PrintToChat(client, "[%t] %t","Notice", "Post Check Failure", zombieName);
    }
    else
    {
        //Success Callback
        char onSuccess[32];
        Format(onSuccess, 32, "On%sSuccess", zombieName);
        Function func = GetFunctionByName(INVALID_HANDLE, onSuccess);
        if(func != INVALID_FUNCTION)
        {
            Call_StartFunction(INVALID_HANDLE, func);
            Call_PushCell(client);
            Call_Finish();
        }

    }
    return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if(!IsValidEntity(entity))
        return;

    // Optimization: Check first char before StrEqual
    if(classname[0] == 't' && StrEqual(classname, "tank_rock", false))
    {
        SDKHook(entity, SDKHook_SpawnPost, OnRockSpawnPost);
    }
    
}


public void OnEntityDestroyed(int entity)
{
    if(!IsValidEntity(entity))
        return;
    char classname[32];
    GetEntityClassname(entity, classname, 32);
    if (StrEqual(classname, "tank_rock", false))
    {
        OnTankRockDestroyed(entity);
    }
}


public void OnClientDisconnect(int client)
{
    // FIX: Kill timer on disconnect (Mantenemos esto)
    KillTimerSafety(timerSpawnPostCheck[client]);

    if(playerStatus[client])
    {
        SDKUnhook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
        switch(playerStatus[client])
        {
            case PLAYABLE_CHARGER:
            {
                OnPlayerChargerDeath(client);
            }
            case PLAYABLE_HUNTER:
            {
                OnPlayerHunterDeath(client);
            }
            case PLAYABLE_SMOKER:
            {
                OnPlayerSmokerDeath(client);
            }
            case PLAYABLE_JOCKEY:
            {
                OnPlayerJockeyDeath(client);
            }
        }
        playerStatus[client] = 0;
    }
}


// Block Infected-SI control Survivor-SI

public Action L4D_OnPouncedOnSurvivor(int victim, int attacker)
{
    if(playerStatus[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnGrabWithTongue(int victim, int attacker)
{
    if(playerStatus[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnSlammedSurvivor(int victim, int attacker, bool &bWallSlam, bool &bDeadlyCharge)
{
    if(playerStatus[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnStartCarryingVictim(int victim, int attacker)
{
    if(playerStatus[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnPummelVictim(int attacker, int victim)
{
    if(playerStatus[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnJockeyRide(int victim, int attacker)
{
    if(playerStatus[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnVomitedUpon(int victim, int &attacker, bool &boomerExplosion)
{
    if(playerStatus[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnPlayerFling(int client, int attacker, float vecDir[3])
{
    if(playerStatus[client])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}