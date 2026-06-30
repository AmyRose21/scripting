#if defined _pure_play_as_si_smoker_included
 #endinput
#endif
#define _pure_play_as_si_smoker_included

Handle smokerTongueFlyTimers[MAXPLAYERS + 1];
Handle smokerGrabTimers[MAXPLAYERS + 1];
int smokerTongue[MAXPLAYERS + 1][2];

ConVar smokerHp;
ConVar smokerTongueFlyDuration;
ConVar smokerClawDmg;
ConVar smokerBonusDmg;
ConVar smokerAbilityCooldown
ConVar smokerHealPoint;

void AddSmokerConVar()
{
    char desc[128];
    Format(desc, 128, "%t", "ConVar Smoker HP");
    smokerHp = CreateConVar("l4d2_play_as_si_smoker_hp", "400", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Smoker Tongue Fly Duration");
    smokerTongueFlyDuration = CreateConVar("l4d2_play_as_si_smoker_tongue_fly_duration", "3.0", desc, 0, true, 1.0);
    Format(desc, 128, "%t", "ConVar Smoker Claw Damage");
    smokerClawDmg = CreateConVar("l4d2_play_as_si_smoker_claw_dmg", "100.0", desc, 0, true, 10.0);
    Format(desc, 128, "%t", "ConVar Smoker Bonus Damage");
    smokerBonusDmg = CreateConVar("l4d2_play_as_si_smoker_bonus_dmg", "50.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Smoker Ability Cooldown");
    smokerAbilityCooldown = CreateConVar("l4d2_play_as_si_smoker_ability_cooldown", "3.0", desc, 0, true, 3.0);
    Format(desc, 128, "%t", "ConVar Smoker Heal");
    smokerHealPoint = CreateConVar("l4d2_play_as_si_smoker_heal_point", "400", desc, 0, true, 100.0);
}

public void OnSmokerSuccess(int client)
{
    SetEntProp(client, Prop_Data, "m_iHealth", GetConVarInt(smokerHp));
    SetEntProp(client, Prop_Data, "m_iMaxHealth", GetConVarInt(smokerHp));
}

public void OnPlayerSmokerDeath(int client)
{
    KillSmokerTongue(client);
    KillTimerSafety(smokerTongueFlyTimers[client]);
    KillTimerSafety(smokerGrabTimers[client]);
}


void OnSmokerAbilityUse(int client)
{
    if(smokerGrabTimers[client] != null)
        return;

    int ability = L4D_GetPlayerCustomAbility(client);
    if(ability == -1)
        return;

    // Force break tongue, use a virtual tongue
    // to avoid grab teammates
    SetEntPropEnt(ability, Prop_Send, "m_currentTipTarget", -1);

    if(smokerTongueFlyTimers[client] != null)
        return;

    if(smokerGrabTimers[client] != null)
        return;
    
    CreateTongue(client);

}

void CreateTongue(int client) 
{
    float source[3];
    GetClientEyePosition(client, source);
    float angle[3];
    GetClientEyeAngles(client, angle);
    float dir[3];
    GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR);
    NormalizeVector(dir, dir);

    // end
    
    int targetEntity = CreateEntityByName("info_particle_target");
    char targetEntityName[32];
    Format(targetEntityName, 32, "target%d-%d", targetEntity, client);
    DispatchKeyValue(targetEntity, "targetname", targetEntityName);
    DispatchKeyValue(targetEntity, "spawnflags", "0");
    DispatchSpawn(targetEntity);
    TeleportEntity(targetEntity, source);
    
    // start

    int sourceEntity = CreateEntityByName("info_particle_system");

    char sourceEntityName[32];
    Format(sourceEntityName, 32, "target%d-%d", sourceEntity, client);

    DispatchKeyValue(sourceEntity, "targetname", sourceEntityName);
    DispatchKeyValue(sourceEntity, "effect_name", "smoker_tongue");
    DispatchKeyValue(sourceEntity, "cpoint1", targetEntityName);
    DispatchSpawn(sourceEntity);
    ActivateEntity(sourceEntity);
 
    AcceptEntityInput(sourceEntity, "Start");

    SetVariantString("!activator");
    AcceptEntityInput(sourceEntity, "SetParent", client);
    float relativePos[3] = {0.0, 0.0, 50.0};
    TeleportEntity(sourceEntity, relativePos);

    smokerTongue[client][0] = sourceEntity;
    smokerTongue[client][1] = targetEntity;

    DataPack dp;
    smokerTongueFlyTimers[client] = CreateDataTimer(0.05, TimerTongueFly, dp, TIMER_REPEAT);
    dp.WriteCell(client);
    dp.WriteFloat(GetGameTime() + GetConVarFloat(smokerTongueFlyDuration));
    dp.WriteFloatArray(dir, 3);
}

Action TimerTongueFly(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    if(!IsClientInGame(client) || !IsPlayerAlive(client) || playerStatus[client] != PLAYABLE_SMOKER)
    {
        KillSmokerTongue(client);
        smokerTongueFlyTimers[client] = null;
        return Plugin_Stop;
    }
    int tongueSourceEntity = smokerTongue[client][0];
    int tongueTargetEntity = smokerTongue[client][1];
    if(!IsValidEntity(tongueSourceEntity) || !IsValidEntity(tongueTargetEntity))
    {
        KillSmokerTongue(client);
        smokerTongueFlyTimers[client] = null;
        SetAbilityCooldown(client, GetConVarFloat(smokerAbilityCooldown));
        return Plugin_Stop;
    }
    float endTime = dp.ReadFloat();
    if(endTime <= GetGameTime())
    {
        KillSmokerTongue(client);
        smokerTongueFlyTimers[client] = null;
        SetAbilityCooldown(client, GetConVarFloat(smokerAbilityCooldown));
        return Plugin_Stop;
    }
    float dir[3];
    dp.ReadFloatArray(dir, 3);

    float source[3];
    GetAbsOrigin(tongueTargetEntity, source);
    
    float victimPos[3];
    // Detect whitch infected can be grabbed
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsInfected(i))
            continue;
        
        GetAbsOrigin(i, victimPos);
        victimPos[2] += 50.0;
        if(GetVectorDistance(source, victimPos, true) <= 10000.0)
        {
            // Do not put tongue_target on victim
            // When victim dead, the particle effect will left in the world

            // SetVariantString("!activator");
            // AcceptEntityInput(tongueTargetEntity, "SetParent", i);
            // float relativePos[3] = {0.0, 0.0, 50.0};
            // TeleportEntity(smokerTongue[client][1], relativePos);
            L4D_ForceSmokerVictim(i, client);

            // grab
            DataPack dp2;
            smokerGrabTimers[client] = CreateDataTimer(0.25, TimerSmokerBonusDamage, dp2, TIMER_REPEAT);
            dp2.WriteCell(client);
            dp2.WriteCell(i);
            smokerTongueFlyTimers[client] = null;
            return Plugin_Stop;
        }
    }

    // Tongue move forward
    ScaleVector(dir, 50.0);
    AddVectors(source, dir, source);
    TeleportEntity(tongueTargetEntity, source);

    return Plugin_Continue;
}

Action TimerSmokerBonusDamage(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    if(!IsClientInGame(client) || !IsPlayerAlive(client) || playerStatus[client] != PLAYABLE_SMOKER)
    {
        KillSmokerTongue(client);
        smokerGrabTimers[client] = null;
        SetAbilityCooldown(client, GetConVarFloat(smokerAbilityCooldown));
        return Plugin_Stop;
    }
    int si = dp.ReadCell();
    if(!IsClientInGame(si) || !IsPlayerAlive(si))
    {
        KillSmokerTongue(client);
        smokerGrabTimers[client] = null;
        SetAbilityCooldown(client, GetConVarFloat(smokerAbilityCooldown));
        return Plugin_Stop;
    }
    
    float pos[3];
    GetClientAbsOrigin(si, pos);
    pos[2] += 50.0;
    TeleportEntity(smokerTongue[client][1], pos);

    if(L4D_GetAttackerSmoker(si) != client)
    {
        L4D_Smoker_ReleaseVictim(si, client);
        KillSmokerTongue(client);
        smokerGrabTimers[client] = null;
        SetAbilityCooldown(client, GetConVarFloat(smokerAbilityCooldown));
        return Plugin_Stop;
    }
    
    SDKHooks_TakeDamage(si, client, client, GetConVarFloat(smokerBonusDmg), DMG_SLASH, -1, NULL_VECTOR, NULL_VECTOR, false);
    return Plugin_Continue;
}

static const float VOID_VECTOR[3];
void KillSmokerTongue(int client)
{
    int source = smokerTongue[client][0];
    int target = smokerTongue[client][1];

    if (IsValidEdict(target)) {
        AcceptEntityInput(target, "ClearParent");
        TeleportEntity(target, VOID_VECTOR);
        SetVariantString("OnUser1 !self:Kill::1.0:-1");
        AcceptEntityInput(target, "AddOutput");
        AcceptEntityInput(target, "FireUser1");
    }

    if (IsValidEdict(source)) {
        AcceptEntityInput(source, "ClearParent");
        TeleportEntity(source, VOID_VECTOR);
        SetVariantString("OnUser1 !self:Kill::1.0:-1");
        AcceptEntityInput(source, "AddOutput");
        AcceptEntityInput(source, "FireUser1");
    }

    smokerTongue[client][0] = -1;
    smokerTongue[client][1] = -1;
}