#if defined _pure_play_as_si_boomer_included
 #endinput
#endif
#define _pure_play_as_si_boomer_included

StringMap boomerVomitedList;
StringMap boomerVoomitOwner;
Handle boomerVomitTimers[MAXPLAYERS + 1];
Handle boomerBonusDamageTimer;

ConVar boomerHp;
ConVar boomerClawDmg;
ConVar boomerBonusDmg;
ConVar boomerExplosionDmg;
ConVar boomerExplosionRadius;
ConVar boomerExplosionForce;
ConVar boomerHealPoint;
ConVar boomerVomitRadius;
ConVar boomerVomitAngle;
ConVar boomerVomitEffectDuration;
ConVar boomerAbilityCooldown;

void AddBoomerConVars()
{
    boomerVomitedList = new StringMap();
    boomerVoomitOwner = new StringMap();

    char desc[128];
    Format(desc, 128, "%t", "ConVar Boomer HP");
    boomerHp = CreateConVar("l4d2_play_as_si_boomer_hp", "400", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Boomer Claw Damage");
    boomerClawDmg = CreateConVar("l4d2_play_as_si_boomer_claw_dmg", "150.0", desc, 0, true, 10.0);
    Format(desc, 128, "%t", "ConVar Boomer Bonus Damage");
    boomerBonusDmg = CreateConVar("l4d2_play_as_si_boomer_bonus_dmg", "100.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Boomer Explosion Damage");
    boomerExplosionDmg = CreateConVar("l4d2_play_as_si_boomer_explosion_dmg", "100.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Boomer Explosion Radius");
    boomerExplosionRadius = CreateConVar("l4d2_play_as_si_boomer_explosion_radius", "100.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Boomer Explosion Force");
    boomerExplosionForce = CreateConVar("l4d2_play_as_si_boomer_explosion_force", "1000.0", desc, 0, true, 300.0);
    Format(desc, 128, "%t", "ConVar Boomer Heal");
    boomerHealPoint = CreateConVar("l4d2_play_as_si_boomer_heal_point", "400.0", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Boomer Vomit Radius");
    boomerVomitRadius = CreateConVar("l4d2_play_as_si_boomer_vomit_radius", "200.0", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Boomer Vomit Angle");
    boomerVomitAngle = CreateConVar("l4d2_play_as_si_boomer_vomit_angle", "45.0", desc, 0, true, 90.0);
    Format(desc, 128, "%t", "ConVar Boomer Vomit Effect Duration");
    boomerVomitEffectDuration = CreateConVar("l4d2_play_as_si_boomer_vomit_effect_duration", "10.0", desc, 0, true, 5.0);
    Format(desc, 128, "%t", "ConVar Boomer Ability Cooldown");
    boomerAbilityCooldown = CreateConVar("l4d2_play_as_si_boomer_ability_cooldown", "4.0", desc, 0, true, 0.0);
}

public void OnBoomerSuccess(int client)
{
    SetEntProp(client, Prop_Data, "m_iHealth", GetConVarInt(boomerHp));
    SetEntProp(client, Prop_Data, "m_iMaxHealth", GetConVarInt(boomerHp));
}

public void OnBoomerAbilityUse(int client)
{
    if(boomerVomitTimers[client] == null)
    {
        DataPack dp;
        boomerVomitTimers[client] = CreateDataTimer(0.3, TimerVomit, dp, TIMER_REPEAT);
        dp.WriteCell(client);
        dp.WriteFloat(GetGameTime() + 3.0);
    }
}

Action TimerVomit(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
    {
        boomerVomitTimers[client] = null;
        return Plugin_Stop;
    }
    float endTime = dp.ReadFloat();
    if(endTime < GetGameTime())
    {
        boomerVomitTimers[client] = null;
        SetAbilityCooldown(client, GetConVarFloat(boomerAbilityCooldown), 0.5);
        return Plugin_Stop;
    }
    float center[3];
    GetAbsOrigin(client, center);
    float eyeAngle[3];
    GetClientEyeAngles(client, eyeAngle);
    float eyeDir[3];
    GetAngleVectors(eyeAngle, eyeDir, NULL_VECTOR, NULL_VECTOR);

    float victimPos[3];
    float dir[3];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsInfected(i))
            continue;
        GetAbsOrigin(i, victimPos);
        MakeVectorFromPoints(center, victimPos, dir);

        if(GetVectorDistance(center, victimPos) <= GetConVarFloat(boomerVomitRadius) && GetAngleBetweenTwoDirections(eyeDir, dir) <= GetConVarFloat(boomerVomitAngle))
        {
            AddToVomit(i, client);
            L4D_CTerrorPlayer_OnVomitedUpon(i, client);
        }
    }
    char classname[9];
    for(int i = MAXPLAYERS; i <= GetMaxEntities(); i++)
    {
        if(!IsValidEntity(i))
            continue;
        GetEntityClassname(i, classname, 9);
        if(classname[0] != 'i' && classname[0] != 'w')
            continue;

        bool isWitch = StrEqual(classname, "witch", false);
        if(!StrEqual(classname, "infected", false) && !isWitch)
            continue;

        GetAbsOrigin(i, victimPos);
        MakeVectorFromPoints(center, victimPos, dir);
        if(GetVectorDistance(center, victimPos) <= GetConVarFloat(boomerVomitRadius) && GetAngleBetweenTwoDirections(eyeDir, dir) <= GetConVarFloat(boomerVomitAngle))
        {
            AddToVomit(i, client);
            int attacker = client;
            if(isWitch)
            {
                attacker = GetRandomInfected(1); // Alive Infected
            }
            L4D2_Infected_OnHitByVomitJar(i, attacker);
        }
    }
    return Plugin_Continue;
}

public void OnPlayerBoomerDeath(int client)
{
    float center[3];
    GetAbsOrigin(client, center);
    PCreateParticle(client, "explosion_huge", 3.0, center);

    float victimPos[3];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsInfected(i))
            continue;
        GetAbsOrigin(i, victimPos);

        if(GetVectorDistance(center, victimPos) <= GetConVarFloat(boomerExplosionRadius))
        {
            AddExplosionForce(i, center, GetConVarFloat(boomerExplosionForce));
            SDKHooks_TakeDamage(i, client, client, GetConVarFloat(boomerExplosionDmg), DMG_GENERIC);
        }
    }

    char classname[9];
    for(int i = MAXPLAYERS; i <= GetMaxEntities(); i++)
    {
        if(!IsValidEntity(i))
            continue;
        GetEntityClassname(i, classname, 9);
        if(classname[0] != 'i' && classname[0] != 'w')
            continue;

        if(!StrEqual(classname, "infected", false) && !StrEqual(classname, "witch", false))
            continue;

        GetAbsOrigin(i, victimPos);

        if(GetVectorDistance(center, victimPos) <= GetConVarFloat(boomerExplosionRadius))
        {
            SDKHooks_TakeDamage(i, client, client, GetConVarFloat(boomerExplosionDmg), DMG_BLAST);
        }
    }
}
// !rcon sm plugins reload l4d2_play_as_si
public void AddToVomit(int entity, int attacker)
{
    if(!IsValidEntity(entity) || !IsSurvivor(attacker) || playerStatus[attacker] != PLAYABLE_BOOMER)
        return;
    char id[8];
    Format(id, 8, "%d", entity);
    if(!boomerVomitedList.ContainsKey(id))
    {
        boomerVomitedList.SetValue(id, GetGameTime() + GetConVarFloat(boomerVomitEffectDuration));
        boomerVoomitOwner.SetValue(id, attacker);
        // Infected or Common Push in List Then DO Damage
        if(boomerBonusDamageTimer == null)
        {
            boomerBonusDamageTimer = CreateTimer(0.25, TimerBoomerBonusDamage, 0, TIMER_REPEAT);
        }
    }
}

public void RemoveInfectedFromVomit(int entity)
{
    char id[8];
    Format(id, 8, "%d", entity);
    if(boomerVomitedList.ContainsKey(id))
    {
        boomerVomitedList.Remove(id);
        boomerVoomitOwner.Remove(id);
    }
}

Action TimerBoomerBonusDamage(Handle timer)
{
    if(boomerVomitedList.Size <= 0)
    {
        boomerVomitedList.Clear();
        boomerVoomitOwner.Clear();
        boomerBonusDamageTimer = null;
        return Plugin_Stop;
    }
        
    char id[8];
    StringMapSnapshot shots = boomerVomitedList.Snapshot();
    for(int i = 0; i < shots.Length; i++)
    {
        shots.GetKey(i, id, 8);
        int entity = StringToInt(id);
        int attacker = -1;
        float endTime = -1.0;
        boomerVoomitOwner.GetValue(id, attacker);
        boomerVomitedList.GetValue(id, endTime);
        // (alive SI or common) and valid attacker and in damage duration
        if(((IsInfected(entity) && IsPlayerAlive(entity)) || IsCommonInfected(entity)) && IsSurvivor(attacker) && endTime >= GetGameTime())
        {
            SDKHooks_TakeDamage(entity, attacker, attacker, GetConVarFloat(boomerBonusDmg), DMG_IGNITE);
        }
        else
        {
            boomerVomitedList.Remove(id);
            boomerVoomitOwner.Remove(id);
        }
    }
    CloseHandle(shots);
    return Plugin_Continue;
}