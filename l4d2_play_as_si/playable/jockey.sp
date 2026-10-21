
#if defined _pure_play_as_si_jockey_included
 #endinput
#endif
#define _pure_play_as_si_jockey_included

ConVar g_hCvarJockeyHp;
ConVar g_hCvarJockeyClawDmg;
ConVar g_hCvarJockeyRidingDmg;
ConVar g_hCvarJockeyHealPoint;

Handle g_hJockeyRideTimers[MAXPLAYERS + 1];

void AddJockeyConVars()
{
    char desc[128];
    Format(desc, 128, "%t", "ConVar Jockey HP");
    g_hCvarJockeyHp = CreateConVar("l4d2_play_as_si_jockey_hp", "400", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Jockey Claw Damage");
    g_hCvarJockeyClawDmg = CreateConVar("l4d2_play_as_si_jockey_claw_dmg", "100.0", desc, 0, true, 10.0);
    Format(desc, 128, "%t", "ConVar Jockey Bonus Damage");
    g_hCvarJockeyRidingDmg = CreateConVar("l4d2_play_as_si_jockey_bonus_dmg", "100.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Jockey Heal");
    g_hCvarJockeyHealPoint = CreateConVar("l4d2_play_as_si_jockey_heal_point", "400.0", desc, 0, true, 100.0);

    // Jockey is very special or weird
    // Using ability or IN_JUMP can also trigger riding-on
    // So jockey does not need cool down

    // Format(desc, 64, "%t", "ConVar Jockey Ability Cooldown");
    // chargerAbilityCooldown = CreateConVar("l4d2_play_as_si_jockey_ability_cooldown", "3.0", desc, 0, true, 1.0);
}

public void ClearPlayerJockey(int client)
{
    CloseHandleSafety(g_hJockeyRideTimers[client]);
    SDKUnhook(client, SDKHook_OnTakeDamage, SDKHook_Jockey_OnTakeDamage);
}

// Jockey Riding Damage
Action RepeatTimer_Jockey_RidingDamage(Handle timer, int client)
{
    if(!IsClientValid(client) || !IsPlayerAlive(client) || g_hPlayerZombie[client] == null || g_hPlayerZombie[client].ZombieClass != PLAYABLE_JOCKEY)
    {
        SDKUnhook(client, SDKHook_OnTakeDamage, SDKHook_Jockey_OnTakeDamage);
        g_hJockeyRideTimers[client] = null;
        return Plugin_Stop;
    }

    int si = L4D_GetVictimJockey(client);
    if(!IsClientValid(si) || !IsPlayerAlive(si))
    {
        SDKUnhook(client, SDKHook_OnTakeDamage, SDKHook_Jockey_OnTakeDamage);
        g_hJockeyRideTimers[client] = null;
        return Plugin_Stop;
    }

    if(L4D_GetAttackerJockey(si) != client)
    {
        L4D2_Jockey_EndRide(si, client);
        SDKUnhook(client, SDKHook_OnTakeDamage, SDKHook_Jockey_OnTakeDamage);
        g_hJockeyRideTimers[client] = null;
        return Plugin_Stop;
    }

    SDKHooks_TakeDamage(si, client, client, GetConVarFloat(g_hCvarJockeyRidingDmg), DMG_SLASH, -1, NULL_VECTOR, NULL_VECTOR, false);
    return Plugin_Continue;
}

public void L4D2_OnJockeyRide_Post(int victim, int attacker)
{
    if(!IsInfected(victim) || !IsSurvivor(attacker)) return;
    if(g_hPlayerZombie[attacker] == null || g_hPlayerZombie[attacker].ZombieClass != PLAYABLE_JOCKEY) return;

    SDKUnhook(attacker, SDKHook_OnTakeDamage, SDKHook_Jockey_OnTakeDamage);
    SDKHook(attacker, SDKHook_OnTakeDamage, SDKHook_Jockey_OnTakeDamage);
    
    CloseHandleSafety(g_hJockeyRideTimers[attacker]);
    g_hJockeyRideTimers[attacker] = CreateTimer(0.25, RepeatTimer_Jockey_RidingDamage, attacker, TIMER_REPEAT);
}

// When Survivor-Jockey Ride On Infected, other survivors shoot will also do damage to Survivor-Jockey
// Use this to block damage
Action SDKHook_Jockey_OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
    // Block Damage
    return IsSurvivor(attacker) ? Plugin_Handled : Plugin_Continue;
}