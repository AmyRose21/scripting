#if defined _pure_play_as_si_hunter_included
 #endinput
#endif
#define _pure_play_as_si_hunter_included

ConVar hunterHp;
ConVar hunterClawDmg;
ConVar hunterPounceDmg;
ConVar hunterBonusDmg;
ConVar hunterHealPoint;

bool isHunterTouchHooked[MAXPLAYERS + 1];
Handle hunterPinTimers[MAXPLAYERS + 1];
Handle hunterCheckOnGroundTimers[MAXPLAYERS + 1];

void AddHunterConVars()
{
    char desc[128];
    Format(desc, 128, "%t", "ConVar Hunter HP");
    hunterHp = CreateConVar("l4d2_play_as_si_hunter_hp", "400", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Hunter Claw Damage");
    hunterClawDmg = CreateConVar("l4d2_play_as_si_hunter_claw_dmg", "100.0", desc, 0, true, 10.0);
    Format(desc, 128, "%t", "ConVar Hunter Pounce Damage");
    hunterPounceDmg = CreateConVar("l4d2_play_as_si_hunter_pounce_dmg", "200.0", desc, 0, true, 200.0);
    Format(desc, 128, "%t", "ConVar Hunter Bonus Damage");
    hunterBonusDmg = CreateConVar("l4d2_play_as_si_hunter_bonus_dmg", "100.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Hunter Heal");
    hunterHealPoint = CreateConVar("l4d2_play_as_si_hunter_heal_point", "400.0", desc, 0, true, 100.0);
}

public void OnHunterSuccess(int client)
{
    SetEntProp(client, Prop_Data, "m_iHealth", GetConVarInt(hunterHp));
    SetEntProp(client, Prop_Data, "m_iMaxHealth", GetConVarInt(hunterHp));
}

public void OnHunterAbilityUse(int client)
{
    HookTouchHunter(client);
    if(hunterCheckOnGroundTimers[client] == null)
    {
        hunterCheckOnGroundTimers[client] = CreateTimer(0.25, TimerCheckHunterIsOnGround, client, TIMER_REPEAT);
    }
}

/**
 * Can't find any interface to check when hunter ends pounce
 * So set a timer to check if hunter is on the ground after lunge pounce
 * 
 */
Action TimerCheckHunterIsOnGround(Handle timer, int client)
{
    int flags = GetEntityFlags(client);
    if(flags & FL_ONGROUND)
    {
        UnhookTouchHunter(client);
        hunterCheckOnGroundTimers[client] = null;
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

public void OnPlayerHunterDeath(int client)
{
    KillTimerSafety(hunterPinTimers[client]);
    KillTimerSafety(hunterCheckOnGroundTimers[client]);
    UnhookTouchHunter(client);
}

void HookTouchHunter(int client)
{
    if(!isHunterTouchHooked[client])
    {
        isHunterTouchHooked[client] = true;
        SDKHook(client, SDKHook_StartTouch, OnStartTouchHunter);
    }
}

void UnhookTouchHunter(int client)
{
    SDKUnhook(client, SDKHook_StartTouch, OnStartTouchHunter);
    isHunterTouchHooked[client] = false;
}

Action OnStartTouchHunter(int entity, int other)
{
    if(IsSpecialInfected(other))
    {
        UnhookTouchHunter(entity);
        KillTimerSafety(hunterCheckOnGroundTimers[entity]);
        L4D_ForceHunterVictim(other, entity);

        DataPack dp;
        hunterPinTimers[entity] = CreateDataTimer(0.25, TimerHunterBounsDamage, dp, TIMER_REPEAT);
        dp.WriteCell(entity);
        dp.WriteCell(other);
    }
    else
    {
        char classname[9];
        GetEntityClassname(other, classname, 9);

        if(classname[0] != 'i' && classname[0] != 'w') return Plugin_Continue;  //For Performance

        if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
        {
            SDKHooks_TakeDamage(other, entity, entity, GetConVarFloat(hunterPounceDmg));
        }
    }
    return Plugin_Continue;
}


// HunterBonus Damage
Action TimerHunterBounsDamage(Handle timer, DataPack dp)
{

    dp.Reset();
    int client = dp.ReadCell();
    if(!IsClientInGame(client) || !IsPlayerAlive(client) || playerStatus[client] != PLAYABLE_HUNTER)
    {
        hunterPinTimers[client] = null;
        return Plugin_Stop;
    }
    int si = dp.ReadCell();
    if(!IsClientInGame(si) || !IsPlayerAlive(si))
    {
        hunterPinTimers[client] = null;
        return Plugin_Stop;
    }
    if(L4D_GetAttackerHunter(si) != client)
    {
        L4D_Hunter_ReleaseVictim(si, client);
        hunterPinTimers[client] = null;
        return Plugin_Stop;
    }
    
    SDKHooks_TakeDamage(si, client, client, GetConVarFloat(hunterBonusDmg), DMG_SLASH, -1, NULL_VECTOR, NULL_VECTOR, false);
    return Plugin_Continue;
}