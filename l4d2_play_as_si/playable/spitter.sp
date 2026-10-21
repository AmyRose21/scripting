#if defined _pure_play_as_si_spitter_included
 #endinput
#endif
#define _pure_play_as_si_spitter_included

ConVar g_hCvarSpitterHp;
ConVar g_hCvarSpitterClawDmg;
ConVar g_hCvarSpitterAcidDmg;
ConVar g_hCvarSpitterAbilityCooldown;
ConVar g_hCvarSpitterHealPoint;

void AddSpitterConVars()
{
    char desc[64];
    Format(desc, 64, "%t", "ConVar Spitter HP");
    g_hCvarSpitterHp = CreateConVar("l4d2_play_as_si_spitter_hp", "400", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Spitter Claw Damage");
    g_hCvarSpitterClawDmg = CreateConVar("l4d2_play_as_si_spitter_claw_dmg", "100", desc, 0, true, 10.0);
    Format(desc, 64, "%t", "ConVar Spitter Acid Damage");
    g_hCvarSpitterAcidDmg = CreateConVar("l4d2_play_as_si_spitter_acid_dmg", "20.0", desc, 0, true, 10.0);
    Format(desc, 64, "%t", "ConVar Spitter Ability Cooldown");
    g_hCvarSpitterAbilityCooldown = CreateConVar("l4d2_play_as_si_spitter_ability_cooldown", "5.0", desc, 0, true, 1.0);
    Format(desc, 64, "%t", "ConVar Spitter Heal");
    g_hCvarSpitterHealPoint = CreateConVar("l4d2_play_as_si_spitter_heal_point", "200.0", desc, 0, true, 100.0);
}

// !rcon sm plugins reload l4d2_play_as_si
public void L4D2_ActivateAbility_Spitter_Post(int client, int ability)
{
    if(!IsSurvivor(client)) return;
    // Wait 2 seconds to set spitter ability cooldown
    CreateTimer(2.0, Timer_Spitter_Cooldown, client, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_Spitter_Cooldown(Handle timer, int client)
{
    if(!IsClientValid(client) || !IsPlayerAlive(client) || g_hPlayerZombie[client] == null || g_hPlayerZombie[client].ZombieClass != PLAYABLE_SPITTER)
    {
        return Plugin_Stop;
    }
    L4D2_SetCustomAbilityCooldown(client, GetConVarFloat(g_hCvarSpitterAbilityCooldown));
    return Plugin_Continue;
}

public Action L4D2_CInsectSwarm_CanHarm(int acid, int spitter, int entity)
{
    if(IsSurvivor(spitter))
    {
        if(IsSurvivor(entity))
        {
            return Plugin_Handled;
        }
        else if(IsInfected(entity) || IsCommonInfected(entity) || IsWitch(entity))
        {
            SDKHooks_TakeDamage(entity, acid, spitter, GetConVarFloat(g_hCvarSpitterAcidDmg), DMG_GENERIC, -1, NULL_VECTOR, NULL_VECTOR, false);
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}