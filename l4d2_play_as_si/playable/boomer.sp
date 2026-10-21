#if defined _pure_play_as_si_boomer_included
 #endinput
#endif
#define _pure_play_as_si_boomer_included

Handle g_hBoomerVomitTimers[MAXPLAYERS + 1];
// float g_fBoomerScale[MAXPLAYERS + 1];
// int g_iBoomerBiteCount[MAXPLAYERS + 1];

float g_fBoomerVomitDamageRangeSquare;
float g_fBoomerExplosionRangeSquare;

ConVar g_hCvarBoomerHp;
ConVar g_hCvarBoomerClawDmg;
ConVar g_hCvarBoomerBonusDmg;
ConVar g_hCvarBoomerExplosionDmg;
ConVar g_hCvarBoomerExplosionRadius;
ConVar g_hCvarBoomerExplosionForce;
ConVar g_hCvarBoomerHealPoint;
ConVar g_hCvarBoomerVomitRadius;
ConVar g_hCvarBoomerAbilityCooldown;
// !rcon sm plugins reload l4d2_play_as_si
void AddBoomerConVars()
{
    char desc[128];
    Format(desc, 128, "%t", "ConVar Boomer HP");
    g_hCvarBoomerHp = CreateConVar("l4d2_play_as_si_boomer_hp", "400", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Boomer Claw Damage");
    g_hCvarBoomerClawDmg = CreateConVar("l4d2_play_as_si_boomer_claw_dmg", "150.0", desc, 0, true, 10.0);
    Format(desc, 128, "%t", "ConVar Boomer Bonus Damage");
    g_hCvarBoomerBonusDmg = CreateConVar("l4d2_play_as_si_boomer_bonus_dmg", "100.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Boomer Explosion Damage");
    g_hCvarBoomerExplosionDmg = CreateConVar("l4d2_play_as_si_boomer_explosion_dmg", "100.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Boomer Explosion Radius");
    g_hCvarBoomerExplosionRadius = CreateConVar("l4d2_play_as_si_boomer_explosion_radius", "100.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Boomer Explosion Force");
    g_hCvarBoomerExplosionForce = CreateConVar("l4d2_play_as_si_boomer_explosion_force", "1000.0", desc, 0, true, 300.0);
    Format(desc, 128, "%t", "ConVar Boomer Heal");
    g_hCvarBoomerHealPoint = CreateConVar("l4d2_play_as_si_boomer_heal_point", "400.0", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Boomer Vomit Radius");
    g_hCvarBoomerVomitRadius = CreateConVar("l4d2_play_as_si_boomer_vomit_radius", "200.0", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Boomer Ability Cooldown");
    g_hCvarBoomerAbilityCooldown = CreateConVar("l4d2_play_as_si_boomer_ability_cooldown", "4.0", desc, 0, true, 0.0);
}

void AfterConvarConfigExec_Boomer()
{
    if(GetConVarFloat(g_hCvarBoomerVomitRadius) >= 10000.0)
    {
        g_fBoomerVomitDamageRangeSquare = 100000000.0;
        SetConVarFloat(g_hCvarBoomerVomitRadius, 10000.0);
    }
    else
    {
        g_fBoomerVomitDamageRangeSquare = GetConVarFloat(g_hCvarBoomerVomitRadius) * GetConVarFloat(g_hCvarBoomerVomitRadius);
    }

    if(GetConVarFloat(g_hCvarBoomerExplosionRadius) >= 10000.0)
    {
        g_fBoomerExplosionRangeSquare = 100000000.0;
        SetConVarFloat(g_hCvarBoomerExplosionRadius, 10000.0);
    }
    else
    {
        g_fBoomerExplosionRangeSquare = GetConVarFloat(g_hCvarBoomerExplosionRadius) * GetConVarFloat(g_hCvarBoomerExplosionRadius);
    }
}

void ClearPlayerBoomer(int client)
{
    SetEntityMoveType(client, MOVETYPE_WALK);
    CloseHandleSafety(g_hBoomerVomitTimers[client]);
}

public Action L4D_ActivateAbility_Boomer(int client, int ability)
{
    if(!IsSurvivor(client))
        return Plugin_Continue;
    
    // Block all
    return Plugin_Handled;
}

public void L4D_ActivateAbility_Boomer_PostHandled(int client, int ability)
{
    if(!IsSurvivor(client))
        return;
    if(g_hBoomerVomitTimers[client] != null)
    {
        L4D2_SetCustomAbilityCooldown(client, 9999999.0);
        return;
    }
    L4D2_SetCustomAbilityCooldown(client, 9999999.0);

    float endPos[3]; GetAbsOrigin(client, endPos); endPos[2] += 300.0;    
    SetEntityMoveType(client, MOVETYPE_NONE);

    DataPack dp = CreateDataPack();
    dp.WriteCell(client);
    dp.WriteFloatArray(endPos, 3);
    
    RequestFrame(BoomerTakeOff, dp);
}

void BoomerTakeOff(DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    if(!IsSurvivor(client) || !IsPlayerAlive(client) || g_hPlayerZombie[client] == null)
    {
        delete dp;
        return;
    }

    float pos[3]; GetAbsOrigin(client, pos);
    float endPos[3]; dp.ReadFloatArray(endPos, 3);

    if(GetVectorDistance(pos, endPos, true) <= 100.0)
    {
        delete dp;
        g_hBoomerVomitTimers[client] = CreateTimer(GetTickInterval(), TimerBoomerListener, client, TIMER_REPEAT);
        
        PrintToChat(client, "%t", "Chat Boomer Taken Off");
        PrintHintText(client, "%t", "Hint Boomer Taken Off");
        return;
    }

    pos[2] += 10.0;
    TeleportEntity(client, pos);

    RequestFrame(BoomerTakeOff, dp);
}

Action TimerBoomerListener(Handle timer, int client)
{
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
    {
        g_hBoomerVomitTimers[client] = null;
        return Plugin_Stop;
    }

    if(GetClientButtons(client) & IN_ATTACK)
    {
        float endPos[3]; GetAbsOrigin(client, endPos); endPos[2]-= 295.0;

        DataPack dp = CreateDataPack();
        dp.WriteCell(client);
        dp.WriteFloatArray(endPos, 3);
    
        RequestFrame(BoomerLanded, dp);

        g_hBoomerVomitTimers[client] = null;
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

void BoomerLanded(DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    if(!IsSurvivor(client) || !IsPlayerAlive(client) || g_hPlayerZombie[client] == null)
    {
        delete dp;
        return;
    }

    float pos[3]; GetAbsOrigin(client, pos);
    float endPos[3]; dp.ReadFloatArray(endPos, 3);

    if(GetVectorDistance(pos, endPos, true) <= 400.0)
    {
        delete dp;
        OnBoomerJumpDownArrived(client);
        return;
    }

    pos[2] -= 20.0;
    TeleportEntity(client, pos);

    RequestFrame(BoomerLanded, dp);
}

void OnBoomerJumpDownArrived(int client)
{    
    SetEntityMoveType(client, MOVETYPE_WALK);
    
    L4D2_SetCustomAbilityCooldown(client, GetConVarFloat(g_hCvarBoomerAbilityCooldown));

    float center[3]; GetAbsOrigin(client, center);
    float victimPos[3];
    float velocity[3];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsInfected(i) && IsPlayerAlive(i))
        {
            GetAbsOrigin(i, victimPos);
            if(GetVectorDistance(center, victimPos, true) > g_fBoomerVomitDamageRangeSquare)
                continue;

            GetEntPropVector(i, Prop_Data, "m_vecVelocity", velocity);
            AddVectors(velocity, {0.0, 0.0, 1000.0}, velocity);
            TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, velocity);
            SDKHooks_TakeDamage(i, client, client, GetConVarFloat(g_hCvarBoomerBonusDmg), DMG_GENERIC, -1, NULL_VECTOR, NULL_VECTOR, false);
        }
        else if(IsSurvivor(i) && IsPlayerAlive(i))
        {
            GetAbsOrigin(i, victimPos);
            if(GetVectorDistance(center, victimPos, true) > g_fBoomerVomitDamageRangeSquare)
                continue;
            
            ShakeScreen(i, 0, 50.0, 100.0, 3.0);
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

        GetAbsOrigin(i, victimPos);
        if(GetVectorDistance(center, victimPos, true) > g_fBoomerVomitDamageRangeSquare)
            continue;
        
        if(StrEqual(classname, "witch", false))
        {
            SDKHooks_TakeDamage(i, client, client, GetConVarFloat(g_hCvarBoomerBonusDmg), DMG_BLAST, -1, {0.0, 0.0, 1000.0}, NULL_VECTOR, false);
        }
        else if(StrEqual(classname, "infected", false))
        {
            SDKHooks_TakeDamage(i, client, client, GetConVarFloat(g_hCvarBoomerBonusDmg), DMG_GENERIC, -1, {0.0, 0.0, 1000.0}, NULL_VECTOR, false);
        }
    }

    TE_SetupBeamRingPoint(center, GetConVarFloat(g_hCvarBoomerVomitRadius) - 10.0, GetConVarFloat(g_hCvarBoomerVomitRadius), g_iBeam, g_iGlow, 0, 15, 3.0, 5.0, 0.0, {50, 255, 50, 196}, 10, 0);
    TE_SendToAll();
}

void OnBoomerDeath(int client)
{
    float center[3]; GetAbsOrigin(client, center);
    PCreateParticle(client, PARTICLE_BOOMER_EXPLODE, 3.0, center);

    float victimPos[3];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsInfected(i) || !IsPlayerAlive(i))
            continue;
        GetAbsOrigin(i, victimPos);

        if(GetVectorDistance(center, victimPos, true) <= g_fBoomerExplosionRangeSquare)
        {
            AddExplosionForce(i, center, GetConVarFloat(g_hCvarBoomerExplosionForce));
            SDKHooks_TakeDamage(i, client, client, GetConVarFloat(g_hCvarBoomerExplosionDmg), DMG_GENERIC, -1, NULL_VECTOR, NULL_VECTOR, false);
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
        if(GetVectorDistance(center, victimPos, true) <= g_fBoomerExplosionRangeSquare)
        {
            SDKHooks_TakeDamage(i, client, client, GetConVarFloat(g_hCvarBoomerExplosionDmg), DMG_BLAST);
        }
        
    }
}