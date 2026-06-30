#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <left4dhooks>

#include <l4d2_afk>


#define TEAM_SPECTATOR    1
#define TEAM_SURVIVOR    2
#define TEAM_INFECTED    3
#define TEAM_PASSING    4

// Switch
ConVar allowPlugin;

// Timer
ConVar intervalToAfk;
ConVar intervalToSpecNext;

// Conditions
ConVar conditionSinglePlayer;
ConVar conditionOnControlled;
ConVar conditionOnProjectile;
ConVar conditionOnReloading;
ConVar conditionOnGettingUp;
ConVar conditionOnStaggering;

float afkTime[MAXPLAYERS + 1];

// external conditons from natives
StringMap exAfkConditionsInfo;
int exAfkConditions;
int playerStatus[MAXPLAYERS + 1];

ArrayList LastOwner;

// Natives
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{

    EngineVersion version = GetEngineVersion();
    if(version != Engine_Left4Dead2)
    {
        Format(error, err_max, "This plugin only runs on L4D2");
        return APLRes_SilentFailure;
    }

    RegPluginLibrary("l4d2_afk");
    CreateNative("L4D2_Afk_PreventClient", Native_Afk_PreventClient);
    CreateNative("L4D2_Afk_AllowClient", Native_Afk_AllowClient);

    return APLRes_Success;
}

any Native_Afk_PreventClient(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    char condition[32];
    GetNativeString(2, condition, 32);
    StringMapSnapshot shots = exAfkConditionsInfo.Snapshot();
    int index = 0;
    if(exAfkConditionsInfo.ContainsKey(condition))
    {
        exAfkConditionsInfo.GetValue(condition, index);
    }
    else
    {
        index = shots.Length;
        exAfkConditions |= (1 << index);
        exAfkConditionsInfo.SetValue(condition, index);
    }
    playerStatus[client] |= (1 << index);
    return 0;
}

any Native_Afk_AllowClient(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    char condition[32];
    GetNativeString(2, condition, 32);
    
    if(exAfkConditionsInfo.ContainsKey(condition))
    {
        int index = 0;
        exAfkConditionsInfo.GetValue(condition, index);
        playerStatus[client] &= ~(1 << index);
    }
    return 0;
}

public Plugin myinfo = 
{
    name = "l4d2_afk",
    author = "Pure_*",
    description = "Disallow AFK in serveral ways.",
    version = "0.1",
    url = "N/A"
}

public void OnPluginStart()
{

    LoadTranslationsWithCheck();
    

    char desc[64];
    Format(desc, 64, "%t", "ConVar Enable Plugin");
    allowPlugin = CreateConVar("l4d2_afk_enabled", "1", desc);
    Format(desc, 64, "%t", "ConVar Wait Time To Reuse AFK");
    intervalToAfk = CreateConVar("l4d2_afk_interval_afk", "8.0", desc, FCVAR_NOTIFY);
    Format(desc, 64, "%t", "ConVar Wait Time To Join Game");
    intervalToSpecNext = CreateConVar("l4d2_afk_interval_spec_next", "3.0", desc, FCVAR_NOTIFY);
    Format(desc, 64, "%t", "ConVar Condition Single");
    conditionSinglePlayer = CreateConVar("l4d2_afk_condition_single_player", "1", desc);
    Format(desc, 64, "%t", "ConVar Condition Incap By Infected");
    conditionOnControlled = CreateConVar("l4d2_afk_condition_on_controlled", "1", desc);
    Format(desc, 64, "%t", "ConVar Condition Projectile Flying");
    conditionOnProjectile = CreateConVar("l4d2_afk_condition_projectile", "1", desc);
    Format(desc, 64, "%t", "ConVar Condition Reloading");
    conditionOnReloading = CreateConVar("l4d2_afk_condition_reloading", "1", desc);
    Format(desc, 64, "%t", "ConVar Condition Getting Up");
    conditionOnGettingUp = CreateConVar("l4d2_afk_condition_getting_up", "1", desc);
    Format(desc, 64, "%t", "ConVar Condition Staggering");
    conditionOnStaggering = CreateConVar("l4d2_afk_condition_staggering", "1", desc);

    AutoExecConfig(true, "l4d2_afk");

    //监听休息命令.
    AddCommandListener(Command_Afk, "go_away_from_keyboard");
    //监听鼠标左键.
    AddCommandListener(CommandListener_SpecNext, "spec_next");

    HookEvent("round_end", OnRoundEnd);
    HookEvent("mission_lost", OnRoundEnd);
    HookEvent("finale_win", OnRoundEnd);
    HookEvent("map_transition", OnRoundEnd);

    LastOwner = new ArrayList(2);

    exAfkConditionsInfo = new StringMap();

    // RegConsoleCmd("sm_afktest", Command_AfkTest);
}

void LoadTranslationsWithCheck()
{
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "translations/l4d2_afk.phrases.txt");
    if(FileExists(path))
    {
        LoadTranslations("l4d2_afk.phrases.txt");
    }
    else
    {
        LogError("l4d2_afk.phrases.txt is not existed");
    }
}

// !rcon sm plugins reload l4d2_afk

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    for(int i = 0; i <= MAXPLAYERS; i++)
    {
        afkTime[i] = 0.0;
        playerStatus[i] = 0;
    }
    exAfkConditions = 0;
    exAfkConditionsInfo.Clear();
    LastOwner.Clear();
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if(classname[0] != 'm' && classname[0] != 'g')
        return;
    
    if(strncmp(classname, "molotov_projectile", 18) == 0 || strncmp(classname, "grenade_launcher_projectile", 27) == 0)
        SDKHook(entity, SDKHook_SpawnPost, OnProjectileSpawnPost);
}

public void OnProjectileSpawnPost(int entity)
{
    SDKUnhook(entity, SDKHook_SpawnPost, OnProjectileSpawnPost);
    if(entity <= MaxClients || !IsValidEntity(entity))
        return;

    int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
    if(IsValidClient(client) && GetClientTeam(client) == TEAM_SURVIVOR && !IsFakeClient(client))
    {
        int index = LastOwner.Push(GetClientUserId(client));
        LastOwner.Set(index, EntIndexToEntRef(entity), 1);
    }
}

public void OnEntityDestroyed(int entity)
{
    if(entity <= MaxClients || !IsValidEntity(entity))
        return;
    
    char classname[32];
    GetEntityClassname(entity, classname, 32);
    if(classname[0] != 'm' && classname[0] != 'g')
        return;
        
    if(strncmp(classname, "molotov_projectile", 18) == 0 || strncmp(classname, "grenade_launcher_projectile", 27) == 0)
    {
        int index = LastOwner.FindValue(EntIndexToEntRef(entity), 1);
        if(index != -1)
            LastOwner.Erase(index);
    }
}

public Action Command_Afk(int client, const char[] command, int args)
{
    if(!GetConVarBool(allowPlugin))
        return Plugin_Continue;
    
    if(IsValidClient(client))
    {
        if(!IsPlayerAlive(client))
        {
            // PrintToChat(client,"\x04[提示]\x05死亡状态禁止使用休息.");
            PrintToChat(client, "\x04[%t]\x05 %t", "Notice", "Condition Dead");
            return Plugin_Handled;
        }

        if(GetClientTeam(client) == TEAM_SURVIVOR)
        {
            float waitTime = GetConVarFloat(intervalToAfk) - (GetGameTime() - afkTime[client]);
            if(waitTime > 0)
            {
                // PrintCenterText(client, "请等待 %.1f 秒后再使用休息", waitTime);
                PrintCenterText(client, "%t", "Condition Reuse", waitTime);
                
                return Plugin_Handled;
            }
            else if(playerStatus[client] & exAfkConditions)
            {
                // PrintHintText(client, "存在自定义条件禁止使用休息命令");
                PrintHintText(client, "%t", "Condition Customer");
                return Plugin_Handled;
            }
            else if(GetConVarBool(conditionSinglePlayer) && GetSurvivorsNumber() <= 1)
            {
                // PrintToChat(client, "\x04[提示]\x05必须要两名玩家才能使用休息指令");
                PrintToChat(client, "\x04[%t]\x05 %t", "Notice", "Condition Single");
                return Plugin_Handled;
            }
            else if(GetConVarBool(conditionOnControlled) && IsControlled(client))
            {
                // PrintCenterText(client, "被特感控制时禁止使用休息");
                PrintCenterText(client, "%t", "Condition Incap By Infected");
                return Plugin_Handled;
            }
            else if(GetConVarBool(conditionOnProjectile) && LastOwner.FindValue(GetClientUserId(client), 0) != -1)
            {
                // PrintCenterText(client, "发射榴弹或投掷燃烧瓶时禁止使用休息");
                PrintCenterText(client, "%t", "Condition Projectile Flying");
                return Plugin_Handled;
            }
            else if(GetConVarBool(conditionOnReloading) && IsInReload(client))
            {
                PrintCenterText(client, "%t", "Condition Reloading");
                // PrintCenterText(client, "更换弹药时禁止使用休息");
                return Plugin_Handled;
            }
            else if(GetConVarBool(conditionOnGettingUp) && IsGettingUp(client))
            {
                // PrintToChat(client, "\x04[提示]\x05起身过程中禁止使用休息");
                PrintToChat(client, "\x04[%t]\x05%t", "Notice", "Condition Getting Up");
                return Plugin_Handled;
            }
            else if (GetConVarBool(conditionOnStaggering) && L4D_IsPlayerStaggering(client))
            {
                // PrintToChat(client, "\x04[提示]\x05硬直状态时禁止使用休息");
                PrintToChat(client, "\x04[%t]\x05%t" ,"Notice", "Condition Staggering");
                return Plugin_Handled;
            }
            else 
            {
                afkTime[client] = GetGameTime();
                L4D_GoAwayFromKeyboard(client);
                return Plugin_Handled;
            }
        }
        else if(GetClientTeam(client) == TEAM_SPECTATOR)
        {
            // PrintToChat(client,"\x04[提示]\x05你当前已经加入了观察者");
            PrintToChat(client,"\x04[%t]\x05%t", "Notice", "Condition Spectator");
            return Plugin_Handled;
        }
        else if(GetClientTeam(client) == TEAM_INFECTED)
        {
            // PrintToChat(client,"\x04[提示]\x05休息指令只限幸存者使用");
            PrintToChat(client,"\x04[%t]\x05%t", "Notice", "Condition Not Survivor");
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}


//闲置后短时间内禁止加入幸存者(只限闲置状态,旁观者不受此限制).
public Action CommandListener_SpecNext(int client, char[] command, int argc)
{
    if(IsValidClient(client) && !IsFakeClient(client))
    {
        if(GetClientTeam(client) == TEAM_SPECTATOR && iGetBotOfIdle(client))
        {
            float waitTime = GetConVarFloat(intervalToSpecNext) - (GetGameTime() - afkTime[client]);
            if (waitTime > 0)
            {
                // PrintCenterText(client, "请等待 %.1f 秒后再加入幸存者.", waitTime);
                PrintCenterText(client, "%t", "Condition JoinGame", waitTime);
                afkTime[client] = 0.0;
                return Plugin_Handled;
            }
        }
    }
    return Plugin_Continue;
}



// Utils ------------------


stock bool IsInReload(int client)
{
    int iActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    
    return IsValidEdict(iActiveWeapon) && GetEntProp(iActiveWeapon, Prop_Data, "m_bInReload") == 1;
}


//https://github.com/LuxLuma/L4D2_Adrenaline_Recovery
stock bool IsGettingUp(int client) {
    static char sModel[31];
    GetClientModel(client, sModel, sizeof sModel);
    switch (sModel[29]) {
        case 'b': {    //nick
            switch (GetEntProp(client, Prop_Send, "m_nSequence")) {
                case 680, 667, 671, 672, 630, 620, 627:
                    return true;
            }
        }

        case 'd': {    //rochelle
            switch (GetEntProp(client, Prop_Send, "m_nSequence")) {
                case 687, 679, 678, 674, 638, 635, 629:
                    return true;
            }
        }

        case 'c': {    //coach
            switch (GetEntProp(client, Prop_Send, "m_nSequence")) {
                case 669, 661, 660, 656, 630, 627, 621:
                    return true;
            }
        }

        case 'h': {    //ellis
            switch (GetEntProp(client, Prop_Send, "m_nSequence")) {
                case 684, 676, 675, 671, 625, 635, 632:
                    return true;
            }
        }

        case 'v': {    //bill
            switch (GetEntProp(client, Prop_Send, "m_nSequence")) {
                case 772, 764, 763, 759, 538, 535, 528:
                    return true;
            }
        }

        case 'n': {    //zoey
            switch (GetEntProp(client, Prop_Send, "m_nSequence")) {
                case 824, 823, 819, 809, 547, 544, 537:
                    return true;
            }
        }

        case 'e': {    //francis
            switch (GetEntProp(client, Prop_Send, "m_nSequence")) {
                case 775, 767, 766, 762, 541, 539, 531:
                    return true;
            }
        }

        case 'a': {    //louis
            switch (GetEntProp(client, Prop_Send, "m_nSequence")) {
                case 772, 764, 763, 759, 538, 535, 528:
                    return true;
            }
        }

        case 'w': {    //adawong
            switch (GetEntProp(client, Prop_Send, "m_nSequence")) {
                case 687, 679, 678, 674, 638, 635, 629:
                    return true;
            }
        }
    }

    return false;
}

stock bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}

stock int GetSurvivorsNumber()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 2)
        {
            count++;
        }
    }
    return count;
}

stock bool IsControlled(int client)
{
    if(GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0)
        return true;
    if(GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0)
        return true;
    if(GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0)
        return true;
    if(GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0)
        return true;
    if(GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0)
        return true;
    return false;
}

stock int iGetBotOfIdle(int client)
{
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR && (iHasIdlePlayer(i) == client))
            return i;
    }
    return 0;
}

stock int iHasIdlePlayer(int client)
{
    char sNetClass[64];
    if(!GetEntityNetClass(client, sNetClass, sizeof(sNetClass)))
        return 0;

    if(FindSendPropInfo(sNetClass, "m_humanSpectatorUserID") < 1)
        return 0;

    client = GetClientOfUserId(GetEntProp(client, Prop_Send, "m_humanSpectatorUserID"));
    if(client && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == TEAM_SPECTATOR)
        return client;

    return 0;
}
