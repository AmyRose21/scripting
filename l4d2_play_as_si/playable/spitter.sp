#if defined _pure_play_as_si_spitter_included
 #endinput
#endif
#define _pure_play_as_si_spitter_included

ConVar spitterHp;
ConVar spitterClawDmg;
ConVar spitterAcidDmg;
ConVar spitterAbilityCooldown;
ConVar spitterHealPoint;

void AddSpitterConVars()
{
    char desc[64];
    Format(desc, 64, "%t", "ConVar Spitter HP");
    spitterHp = CreateConVar("l4d2_play_as_si_spitter_hp", "400", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Spitter Claw Damage");
    spitterClawDmg = CreateConVar("l4d2_play_as_si_spitter_claw_dmg", "100", desc, 0, true, 10.0);
    Format(desc, 64, "%t", "ConVar Spitter Acid Damage");
    spitterAcidDmg = CreateConVar("l4d2_play_as_si_spitter_acid_dmg", "20.0", desc, 0, true, 10.0);
    Format(desc, 64, "%t", "ConVar Spitter Ability Cooldown");
    spitterAbilityCooldown = CreateConVar("l4d2_play_as_si_spitter_ability_cooldown", "5.0", desc, 0, true, 1.0);
    Format(desc, 64, "%t", "ConVar Spitter Heal");
    spitterHealPoint = CreateConVar("l4d2_play_as_si_spitter_heal_point", "200.0", desc, 0, true, 100.0);
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
            SDKHooks_TakeDamage(entity, acid, spitter, GetConVarFloat(spitterAcidDmg), DMG_ACID);
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}


public void OnSpitterAbilityUse(int client)
{
    // Wait 2 seconds to set spitter ability cooldown
    SetAbilityCooldown(client, GetConVarFloat(spitterAbilityCooldown), 2.0);
}

//-------------Callback
public void OnSpitterSuccess(int client)
{
    SetEntProp(client, Prop_Data, "m_iHealth", GetConVarInt(spitterHp));
    SetEntProp(client, Prop_Data, "m_iMaxHealth", GetConVarInt(spitterHp));
}