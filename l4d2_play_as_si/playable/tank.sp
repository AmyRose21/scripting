#if defined _pure_play_as_si_tank_included
 #endinput
#endif
#define _pure_play_as_si_tank_included

ConVar g_hCvarTankHp;
ConVar g_hCvarTankClawDmg;
ConVar g_hCvarTankClawRadius;
ConVar g_hCvarTankRockDmg;
ConVar g_hCvarTankRockRadius;
ConVar g_hCvarTankRockExplodeForce;
ConVar g_hCvarTankHealPoint;
ConVar g_hCvarTankAbilityCooldown;

int g_iTankClawSwingCount[MAXPLAYERS + 1];

void AddTankConVars()
{
    char desc[64];
    Format(desc, 64, "%t", "ConVar Tank HP");
    g_hCvarTankHp = CreateConVar("l4d2_play_as_si_tank_hp", "1000", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Claw Damage");
    g_hCvarTankClawDmg = CreateConVar("l4d2_play_as_si_tank_claw_damage", "500.0", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Claw Radius");
    g_hCvarTankClawRadius = CreateConVar("l4d2_play_as_si_tank_claw_radius", "100.0", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Rock Damage");
    g_hCvarTankRockDmg = CreateConVar("l4d2_play_as_si_tank_rock_damage", "500.0", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Rock Radius");
    g_hCvarTankRockRadius = CreateConVar("l4d2_play_as_si_tank_rock_radius", "300.0", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Rock Force");
    g_hCvarTankRockExplodeForce = CreateConVar("l4d2_play_as_si_tank_rock_explode_force", "300.0", desc, 0, true, 300.0);
    Format(desc, 64, "%t", "ConVar Tank Heal");
    g_hCvarTankHealPoint = CreateConVar("l4d2_play_as_si_tank_heal_point", "400", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Ability Cooldown");
    g_hCvarTankAbilityCooldown = CreateConVar("l4d2_play_as_si_tank_ability_cooldown", "2.0", desc, 0, true, 1.0);
}

public void L4D_OnCThrowActivate_Post(int ability)
{
    int client = GetEntPropEnt(ability, Prop_Send, "m_hOwnerEntity");
    if(!IsSurvivor(client)) return;

    L4D2_SetCustomAbilityCooldown(client, GetConVarFloat(g_hCvarTankAbilityCooldown));
}

// !rcon sm plugins reload l4d2_play_as_si
// This forward called 10 times in one swing, so do a fliter for performance
public void L4D_TankClaw_DoSwing_Post(int tank, int claw)
{
    if(!IsSurvivor(tank))
        return;
    
    g_iTankClawSwingCount[tank]++;
    // Only judge once per swing
    if(g_iTankClawSwingCount[tank] % 10 != 5)
        return;
    // Garantee not overflow range of Int
    if(g_iTankClawSwingCount[tank] >= 10)
        g_iTankClawSwingCount[tank] -= 10;

    float tankPos[3]; GetAbsOrigin(tank, tankPos);

    float victimPos[3];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            GetAbsOrigin(i, victimPos);
            float distance = GetVectorDistance(tankPos, victimPos);
            if (distance <= GetConVarFloat(g_hCvarTankClawRadius))
            {
                SDKHooks_TakeDamage(i, tank, tank, GetConVarFloat(g_hCvarTankClawDmg), DMG_BLAST, -1, NULL_VECTOR, NULL_VECTOR, false);
            }
        }
    }
    
    char classname[9];
    for(int i = MAXPLAYERS; i < GetMaxEntities(); i++)
    {
        if(!IsValidEntity(i)) continue;

        GetEntityClassname(i, classname, 9);

        if(classname[0] != 'i' && classname[0] != 'w') continue;  //For Performance

        if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
        {
            GetAbsOrigin(i, victimPos);
            float distance = GetVectorDistance(tankPos, victimPos);
            if(distance <= GetConVarFloat(g_hCvarTankClawRadius))
            {
                SDKHooks_TakeDamage(i, tank, tank, GetConVarFloat(g_hCvarTankClawDmg), DMG_BLAST, -1, NULL_VECTOR, NULL_VECTOR, false);
            }
        }
    }    
}

// Prevent Team Mate to be hit
public Action L4D_TankClaw_OnPlayerHit_Pre(int tank, int claw, int player)
{
    if((IsSurvivor(tank) && IsSurvivor(player)) // Prevent Team Mate to be hit
      || (!IsSurvivor(tank) && g_hPlayerZombie[player] != null && g_hPlayerZombie[player].ZombieClass == PLAYABLE_TANK))  // Prevent SI-Tank to be hit
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public void L4D_TankClaw_OnPlayerHit_Post(int tank, int claw, int player)
{
    if(IsSurvivor(tank) && IsInfected(player))
    {
        float pos[3]; GetAbsOrigin(player, pos);
        PCreateParticle(player, PARTICLE_PIPEBOMB, 2.0, pos);
        EmitAmbientSound(SOUND_HEGRENADE_EXPLODE, pos);
    }
}

public Action L4D_TankRock_BounceTouch(int tank, int rock, int entity)
{
    if(IsSurvivor(tank) && IsInfected(entity))
    {
        L4D_DetonateProjectile(rock);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}


public void L4D_TankRock_OnDetonate(int tank, int rock)
{
    if(!IsSurvivor(tank)) return;
    
    float rockPos[3]; GetAbsOrigin(rock, rockPos);
    
    // collect all entities in range
    ArrayList entities = new ArrayList();
    float victimPos[3];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            GetAbsOrigin(i, victimPos);
            float distance = GetVectorDistance(rockPos, victimPos);
            if (distance <= GetConVarFloat(g_hCvarTankRockRadius))
            {
                entities.Push(i);
            }
        }
    }

    for(int i = MAXPLAYERS + 1; i < GetMaxEntities(); i++)
    {
        if(!IsValidEntity(i)) continue;

        char classname[9]; GetEntityClassname(i, classname, 9);

        if(classname[0] != 'i' && classname[0] != 'w') continue;

        if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
        {
            GetAbsOrigin(i, victimPos);
            float distance = GetVectorDistance(rockPos, victimPos);
            if(distance <= GetConVarFloat(g_hCvarTankRockRadius))
            {
                entities.Push(i);
            }
        }
        
    }

    for(int i = 0; i < entities.Length; i++)
    {
        int victim = entities.Get(i);
        AddExplosionForce(victim, rockPos, GetConVarFloat(g_hCvarTankRockExplodeForce));
        SDKHooks_TakeDamage(victim, tank, tank, GetConVarFloat(g_hCvarTankRockDmg), DMG_GENERIC, -1, NULL_VECTOR, NULL_VECTOR, false);
    }
    CloseHandle(entities);
}