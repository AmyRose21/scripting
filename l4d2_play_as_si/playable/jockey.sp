
#if defined _pure_play_as_si_jockey_included
 #endinput
#endif
#define _pure_play_as_si_jockey_included

ConVar jockeyHp;
ConVar jockeyClawDmg;
ConVar jockeyBonusDmg;
ConVar jockeyHealPoint;

Handle jockeyRideTimers[MAXPLAYERS + 1];

void AddJockeyConVars()
{
    char desc[128];
    Format(desc, 128, "%t", "ConVar Jockey HP");
    jockeyHp = CreateConVar("l4d2_play_as_si_jockey_hp", "400", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Jockey Claw Damage");
    jockeyClawDmg = CreateConVar("l4d2_play_as_si_jockey_claw_dmg", "100.0", desc, 0, true, 10.0);
    Format(desc, 128, "%t", "ConVar Jockey Bonus Damage");
    jockeyBonusDmg = CreateConVar("l4d2_play_as_si_jockey_bonus_dmg", "100.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Jockey Heal");
    jockeyHealPoint = CreateConVar("l4d2_play_as_si_jockey_heal_point", "400.0", desc, 0, true, 100.0);

    // Jockey is very special or weird
    // Using ability or IN_JUMP can also trigger riding-on
    // So jockey does not need cool down

    // Format(desc, 64, "%t", "ConVar Jockey Ability Cooldown");
    // chargerAbilityCooldown = CreateConVar("l4d2_play_as_si_jockey_ability_cooldown", "3.0", desc, 0, true, 1.0);
}

public void OnJockeySuccess(int client)
{
    SetEntProp(client, Prop_Data, "m_iHealth", GetConVarInt(jockeyHp));
    SetEntProp(client, Prop_Data, "m_iMaxHealth", GetConVarInt(jockeyHp));
    // There may be no way to detect jockey ability use
    // So use a timer to detect ride on
    // Maybe low performance
    jockeyRideTimers[client] = CreateTimer(0.25, TimerJockeyBounsDamage, client, TIMER_REPEAT);
    SDKHook(client, SDKHook_OnTakeDamage, OnJockeyTakeDamage);
}

public void OnPlayerJockeyDeath(int client)
{
    KillTimerSafety(jockeyRideTimers[client]);
    SDKUnhook(client, SDKHook_OnTakeDamage, OnJockeyTakeDamage);
}

// JockeyBouns Damage
Action TimerJockeyBounsDamage(Handle timer, int client)
{
    if(!IsClientInGame(client) || !IsPlayerAlive(client) || playerStatus[client] != PLAYABLE_JOCKEY)
    {
        SDKUnhook(client, SDKHook_OnTakeDamage, OnJockeyTakeDamage);
        jockeyRideTimers[client] = null;
        return Plugin_Stop;
    }
    int si = L4D_GetVictimJockey(client);
    if(!si || !IsClientInGame(si) || !IsPlayerAlive(si))
    {
        return Plugin_Continue;
    }

    if(L4D_GetAttackerJockey(si) != client)
    {
        L4D2_Jockey_EndRide(si, client);
        return Plugin_Continue;
    }

    SDKHooks_TakeDamage(si, client, client, GetConVarFloat(jockeyBonusDmg), DMG_SLASH, -1, NULL_VECTOR, NULL_VECTOR, false);
    return Plugin_Continue;
}

// When Survivor-Jockey Ride On Infected, other survivors shoot will also do damage to Survivor-Jockey
// Use this to block damage
Action OnJockeyTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
    // Block Damage
    if(IsSurvivor(attacker))
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}