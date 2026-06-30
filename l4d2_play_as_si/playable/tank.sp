#if defined _pure_play_as_si_tank_included
 #endinput
#endif
#define _pure_play_as_si_tank_included

ConVar tankHp;
ConVar tankClawDmg;
ConVar tankClawRadius;
ConVar tankRockDmg;
ConVar tankRockRadius;
ConVar tankRockExplodeForce;
ConVar tankHealPoint;
ConVar tankAbilityCooldown;

int clawSwingCount[MAXPLAYERS + 1];

void AddTankConVars()
{
    char desc[64];
    Format(desc, 64, "%t", "ConVar Tank HP");
    tankHp = CreateConVar("l4d2_play_as_si_tank_hp", "1000", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Claw Damage");
    tankClawDmg = CreateConVar("l4d2_play_as_si_tank_claw_damage", "500.0", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Claw Radius");
    tankClawRadius = CreateConVar("l4d2_play_as_si_tank_claw_radius", "100.0", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Rock Damage");
    tankRockDmg = CreateConVar("l4d2_play_as_si_tank_rock_damage", "500.0", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Rock Radius");
    tankRockRadius = CreateConVar("l4d2_play_as_si_tank_rock_radius", "300.0", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Rock Force");
    tankRockExplodeForce = CreateConVar("l4d2_play_as_si_tank_rock_explode_force", "300.0", desc, 0, true, 300.0)
    Format(desc, 64, "%t", "ConVar Tank Heal");
    tankHealPoint = CreateConVar("l4d2_play_as_si_tank_heal_point", "400", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Tank Ability Cooldown");
    tankAbilityCooldown = CreateConVar("l4d2_play_as_si_tank_ability_cooldown", "2.0", desc, 0, true, 1.0);
}

void OnRockSpawnPost(int entity)
{
    SDKUnhook(entity, SDKHook_SpawnPost, OnRockSpawnPost);
    RequestFrame(OnRockSpawnPostNextFrame, EntIndexToEntRef(entity));
}

void OnRockSpawnPostNextFrame(int entRef)
{
    int client = GetEntPropEnt(EntRefToEntIndex(entRef), Prop_Data, "m_hThrower");
    if(!IsRealClient(client))
    {
        return;
    }
    SetAbilityCooldown(client, GetConVarFloat(tankAbilityCooldown));
}

public void OnTankRockDestroyed(int entity)
{
    int tank = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
    if(!IsRealClient(tank))
    {
        return;
    }
    
    float rockPos[3];
    GetAbsOrigin(entity, rockPos);
    
    // collect all entities in range
    ArrayList entities = new ArrayList();
    float victimPos[3];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            GetAbsOrigin(i, victimPos);
            float distance = GetVectorDistance(rockPos, victimPos);
            if (distance <= GetConVarFloat(tankRockRadius))
            {
                entities.Push(i);
            }
        }
    }

    for(int i = MAXPLAYERS + 1; i < GetMaxEntities(); i++)
    {
        if(!IsValidEntity(i)) continue;

        char classname[9];
        GetEntityClassname(i, classname, 9);

        if(classname[0] != 'i' && classname[0] != 'w') continue;

        if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
        {
            GetAbsOrigin(i, victimPos);
            float distance = GetVectorDistance(rockPos, victimPos);
            if(distance <= GetConVarFloat(tankRockRadius))
            {
                entities.Push(i);
            }
        }
        
    }

    for(int i = 0; i < entities.Length; i++)
    {
        int victim = entities.Get(i);
        AddExplosionForce(victim, rockPos, GetConVarFloat(tankRockExplodeForce));
        SDKHooks_TakeDamage(victim, tank, tank, GetConVarFloat(tankRockDmg));
    }
    CloseHandle(entities);

}

// This forward called 10 times in one swing, so do a fliter for performance
public void L4D_TankClaw_DoSwing_Post(int tank, int claw)
{
    if(!IsSurvivor(tank))
        return;
    
    clawSwingCount[tank]++;
    // Only judge once per swing
    if(clawSwingCount[tank] % 10 != 5)
        return;
    // Garantee not overflow range of Int
    if(clawSwingCount[tank] >= 10)
        clawSwingCount[tank] -= 10;

    float tankPos[3];
    GetAbsOrigin(tank, tankPos);

    float victimPos[3];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            GetAbsOrigin(i, victimPos);
            float distance = GetVectorDistance(tankPos, victimPos);
            if (distance <= GetConVarFloat(tankClawRadius))
            {
                SDKHooks_TakeDamage(i, tank, tank, GetConVarFloat(tankClawDmg), DMG_BLAST);
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
            if(distance <= GetConVarFloat(tankClawRadius))
            {
                SDKHooks_TakeDamage(i, tank, tank, GetConVarFloat(tankClawDmg), DMG_BLAST);
            }
        }
    }    
}

// Prevent Team Mate to be hit
public Action L4D_TankClaw_OnPlayerHit_Pre(int tank, int claw, int player)
{
    if((IsSurvivor(tank) && IsSurvivor(player)) || (!IsSurvivor(tank) && (playerStatus[player] == PLAYABLE_TANK)))
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public void L4D_TankClaw_OnPlayerHit_Post(int tank, int claw, int player)
{
    if(IsRealClient(tank) && IsClientInGame(player) && IsPlayerAlive(player))
    {
        float pos[3];
        GetAbsOrigin(player, pos);
        PCreateParticle(player, "weapon_pipebomb", 2.0, pos);
        EmitSoundToAll("weapons/hegrenade/explode3.wav");
    }
}

public Action L4D_TankRock_BounceTouch(int tank, int rock, int entity)
{
    if(IsRealClient(tank) && IsSpecialInfected(entity))
    {
        L4D_DetonateProjectile(rock);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}


// ---------------Call Back

// Call On SpawnCheckPost
public void OnTankSuccess(int client)
{
    SetEntProp(client, Prop_Data, "m_iHealth", GetConVarInt(tankHp));
    SetEntProp(client, Prop_Data, "m_iMaxHealth", GetConVarInt(tankHp));
}