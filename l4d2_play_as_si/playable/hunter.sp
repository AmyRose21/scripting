#if defined _pure_play_as_si_hunter_included
 #endinput
#endif
#define _pure_play_as_si_hunter_included

ConVar g_hCvarHunterHp;
ConVar g_hCvarHunterClawDmg;
ConVar g_hCvarHunterPounceDmg;
ConVar g_hCvarHunterBonusDmg;
ConVar g_hCvarHunterHealPoint;

Handle g_hHunterPinTimers[MAXPLAYERS + 1];
Handle g_hHunterCheckOnGroundTimers[MAXPLAYERS + 1];

void AddHunterConVars()
{
    char desc[128];
    Format(desc, 128, "%t", "ConVar Hunter HP");
    g_hCvarHunterHp = CreateConVar("l4d2_play_as_si_hunter_hp", "400", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Hunter Claw Damage");
    g_hCvarHunterClawDmg = CreateConVar("l4d2_play_as_si_hunter_claw_dmg", "100.0", desc, 0, true, 10.0);
    Format(desc, 128, "%t", "ConVar Hunter Pounce Damage");
    g_hCvarHunterPounceDmg = CreateConVar("l4d2_play_as_si_hunter_pounce_dmg", "200.0", desc, 0, true, 200.0);
    Format(desc, 128, "%t", "ConVar Hunter Bonus Damage");
    g_hCvarHunterBonusDmg = CreateConVar("l4d2_play_as_si_hunter_bonus_dmg", "100.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Hunter Heal");
    g_hCvarHunterHealPoint = CreateConVar("l4d2_play_as_si_hunter_heal_point", "400.0", desc, 0, true, 100.0);
}

public void L4D_ActivateAbility_Hunter_Post(int client, int ability)
{
    if(!IsSurvivor(client)) return;
    
    if(g_hHunterCheckOnGroundTimers[client] == null)
    {
        SDKUnhook(client, SDKHook_StartTouchPost, SDKHook_Hunter_OnStartTouchPost);
        SDKHook(client, SDKHook_StartTouchPost, SDKHook_Hunter_OnStartTouchPost);
        g_hHunterCheckOnGroundTimers[client] = CreateTimer(0.25, RepeatTimer_Hunter_CheckOnGround, client, TIMER_REPEAT);
    }
}

/**
 * Can't find any interface to check when hunter ends pounce
 * So set a timer to check if hunter is on the ground after lunge pounce
 * 
 */
Action RepeatTimer_Hunter_CheckOnGround(Handle timer, int client)
{
    if(!IsClientValid(client) || !IsPlayerAlive(client) || g_hPlayerZombie[client] == null || g_hPlayerZombie[client].ZombieClass != PLAYABLE_HUNTER)
    {
        g_hHunterCheckOnGroundTimers[client] = null;
        return Plugin_Stop;
    }
    int flags = GetEntityFlags(client);
    if(flags & FL_ONGROUND)
    {
        SDKUnhook(client, SDKHook_StartTouchPost, SDKHook_Hunter_OnStartTouchPost);
        g_hHunterCheckOnGroundTimers[client] = null;
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

void ClearPlayerHunter(int client)
{
    CloseHandleSafety(g_hHunterPinTimers[client]);
    CloseHandleSafety(g_hHunterCheckOnGroundTimers[client]);
    SDKUnhook(client, SDKHook_StartTouchPost, SDKHook_Hunter_OnStartTouchPost);
}

void SDKHook_Hunter_OnStartTouchPost(int entity, int other)
{
    if(IsInfected(other))
    {
        SDKUnhook(entity, SDKHook_StartTouchPost, SDKHook_Hunter_OnStartTouchPost);
        CloseHandleSafety(g_hHunterCheckOnGroundTimers[entity]);
        L4D_ForceHunterVictim(other, entity);
        
        CloseHandleSafety(g_hHunterPinTimers[entity]);
        DataPack dp;
        g_hHunterPinTimers[entity] = CreateDataTimer(0.25, RepeatTimer_Hunter_BonusDamage, dp, TIMER_REPEAT);
        dp.WriteCell(entity);
        dp.WriteCell(other);
    }
    else
    {
        char classname[9]; GetEntityClassname(other, classname, 9);

        if(classname[0] != 'i' && classname[0] != 'w') return;  //For Performance

        if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
        {
            SDKHooks_TakeDamage(other, entity, entity, GetConVarFloat(g_hCvarHunterPounceDmg), DMG_GENERIC, -1, NULL_VECTOR, NULL_VECTOR, false);
        }
    }
}


// HunterBonus Damage
Action RepeatTimer_Hunter_BonusDamage(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    if(!IsClientInGame(client) || !IsPlayerAlive(client) || g_hPlayerZombie[client] == null || g_hPlayerZombie[client].ZombieClass != PLAYABLE_HUNTER)
    {
        g_hHunterPinTimers[client] = null;
        return Plugin_Stop;
    }
    int si = dp.ReadCell();
    if(!IsClientInGame(si) || !IsPlayerAlive(si))
    {
        g_hHunterPinTimers[client] = null;
        return Plugin_Stop;
    }
    if(L4D_GetAttackerHunter(si) != client)
    {
        L4D_Hunter_ReleaseVictim(si, client);
        g_hHunterPinTimers[client] = null;
        return Plugin_Stop;
    }
    
    SDKHooks_TakeDamage(si, client, client, GetConVarFloat(g_hCvarHunterBonusDmg), DMG_SLASH, -1, NULL_VECTOR, NULL_VECTOR, false);
    return Plugin_Continue;
}