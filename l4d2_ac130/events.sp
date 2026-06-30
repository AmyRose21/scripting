#if defined _pure_ac130_events_included
 #endinput
#endif
#define _pure_ac130_events_included

void HookEvents()
{
    HookEvent("player_spawn", OnPlayerSpawn);
    HookEvent("player_death", OnPlayerDeath);
    HookEvent("infected_death", OnInfectedDeath);
    HookEvent("round_start", OnRoundStart, EventHookMode_Post);
    HookEvent("round_end", OnRoundEnd, EventHookMode_Pre);
    HookEvent("mission_lost", OnRoundEnd, EventHookMode_Pre);
    HookEvent("finale_win", OnRoundEnd, EventHookMode_Pre);
    HookEvent("map_transition", OnRoundEnd, EventHookMode_Pre);
}

void ClearState(int client)
{
    if(IsSurvivor(client) && allow[client])
    {
        AcceptEntityInput(client, "ClearParent");
        DeleteEntity(planes[client]);
        KillTimerSafety(reloadTimers[client][0]);
        KillTimerSafety(reloadTimers[client][1]);
        KillTimerSafety(reloadTimers[client][2]);
        allow[client] = false;
        SDKUnhook(client, SDKHook_OnTakeDamage, OnGodMode);
        SDKUnhook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
        planes[client] = 0;
        lastReloadTipTimes[client] = 0.0;
        lastFireEmptyTipTimes[client] = 0.0;
        lastSwitchTimes[client] = 0.0;
        lastFireTimes[client][0] = 0.0;
        lastFireTimes[client][1] = 0.0;
        lastFireTimes[client][2] = 0.0;
        planeSmoothParam[client] = 0.0;
        if(isMinigunFiring[client])
        {
            StopSound(client, SNDCHAN_WEAPON, SOUND_MINIGUN_FIRE);
        }
        isMinigunFiring[client] = false;
    }
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    for(int i = 1; i <= MAXPLAYERS; i++)
    {
        ClearState(i);
    }
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int userid = GetClientOfUserId(GetEventInt(event, "userid"));
    if(IsInfected(userid))
    {
        infectedMgr.Store(userid);
    }
    if(IsSurvivor(userid))
    {
        float pos[3]; GetAbsOrigin(userid, pos);
        float teamPos[3];
        bool needChangePosition = false;
        for(int i = 0; i <= MaxClients; i++)
        {
            if(i == userid)
                continue;
            if(IsSurvivor(i) && allow[i])
            {
                GetAbsOrigin(i, teamPos);
                if(GetVectorDistance(pos, teamPos) <= 100.0)
                {
                    needChangePosition = true;
                    break;
                }
            }
        }
        if(needChangePosition)
        {
            for(int i = 0; i <= MaxClients; i++)
            {
                if(i == userid)
                    continue;
                if(IsSurvivor(i) && !allow[i])
                {
                    GetAbsOrigin(i, teamPos);
                    TeleportEntity(userid, teamPos);
                    break;
                }
            }
        }
    }
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int userid = GetClientOfUserId(GetEventInt(event, "userid"));
    if(IsInfected(userid))
    {
        infectedMgr.Remove(userid);
    }
    if(IsSurvivor(userid))
    {
        ClearState(userid);
    }
    
}

public void OnInfectedDeath(Event event, const char[] name, bool dontBroadcast)
{
    // short	attacker	user ID who killed
    // short	infected_id	ID of the infected that died
    // short	gender	gender (type) of the infected
    // short	weapon_id	ID of the weapon used
    // bool	headshot	signals a headshot
    // bool	minigun	signals a minigun kill
    // bool	blast	signals a death from blast damage
    // bool	submerged	indicates the infected was submerged

    int infected = GetEventInt(event, "infected_id");
    infectedMgr.Remove(infected);
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
    {
        SDKHook(EntIndexToEntRef(entity), SDKHook_SpawnPost, OnCommonCreatedPost);
    }
}

void OnCommonCreatedPost(int entityRef)
{
    SDKUnhook(entityRef, SDKHook_SpawnPost, OnCommonCreatedPost);
    int entity = EntRefToEntIndex(entityRef);
    if(!IsValidEntity(entity))
        return

    infectedMgr.Store(entity);
}

public void OnClientDisconnect(int client)
{
    ClearState(client);
}


public Action L4D_OnPouncedOnSurvivor(int victim, int attacker)
{
    if(allow[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnGrabWithTongue(int victim, int attacker)
{
    if(allow[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnSlammedSurvivor(int victim, int attacker, bool &bWallSlam, bool &bDeadlyCharge)
{
    if(allow[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnStartCarryingVictim(int victim, int attacker)
{
    if(allow[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnPummelVictim(int attacker, int victim)
{
    if(allow[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnJockeyRide(int victim, int attacker)
{
    if(allow[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnVomitedUpon(int victim, int &attacker, bool &boomerExplosion)
{
    if(allow[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnPlayerFling(int client, int attacker, float vecDir[3])
{
    if(allow[client])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}