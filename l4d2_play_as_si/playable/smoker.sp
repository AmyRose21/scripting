#if defined _pure_play_as_si_smoker_included
 #endinput
#endif
#define _pure_play_as_si_smoker_included

ArrayList g_hSmokerTongueFlyData[MAXPLAYERS + 1];
Handle g_hSmokerGrabTimers[MAXPLAYERS + 1];
int g_iSmokerTongue[MAXPLAYERS + 1][2];


ConVar g_hCvarSmokerHp;
ConVar g_hCvarSmokerTongueFlyDuration;
ConVar g_hCvarSmokerClawDmg;
ConVar g_hCvarSmokerBonusDmg;
ConVar g_hCvarSmokerAbilityCooldown;
ConVar g_hCvarSmokerHealPoint;

void AddSmokerConVar()
{
    char desc[128];
    Format(desc, 128, "%t", "ConVar Smoker HP");
    g_hCvarSmokerHp = CreateConVar("l4d2_play_as_si_smoker_hp", "400", desc, 0, true, 100.0);
    Format(desc, 128, "%t", "ConVar Smoker Tongue Fly Duration");
    g_hCvarSmokerTongueFlyDuration = CreateConVar("l4d2_play_as_si_smoker_tongue_fly_duration", "3.0", desc, 0, true, 1.0);
    Format(desc, 128, "%t", "ConVar Smoker Claw Damage");
    g_hCvarSmokerClawDmg = CreateConVar("l4d2_play_as_si_smoker_claw_dmg", "100.0", desc, 0, true, 10.0);
    Format(desc, 128, "%t", "ConVar Smoker Bonus Damage");
    g_hCvarSmokerBonusDmg = CreateConVar("l4d2_play_as_si_smoker_bonus_dmg", "50.0", desc, 0, true, 50.0);
    Format(desc, 128, "%t", "ConVar Smoker Ability Cooldown");
    g_hCvarSmokerAbilityCooldown = CreateConVar("l4d2_play_as_si_smoker_ability_cooldown", "3.0", desc, 0, true, 3.0);
    Format(desc, 128, "%t", "ConVar Smoker Heal");
    g_hCvarSmokerHealPoint = CreateConVar("l4d2_play_as_si_smoker_heal_point", "400", desc, 0, true, 100.0);

    for(int i = 1; i <= MAXPLAYERS; i++)
    {
        g_iSmokerTongue[i][0] = -1;
        g_iSmokerTongue[i][1] = -1;
    }
}

void ClearPlayerSmoker(int client)
{
    KillSmokerTongue(client);
    CloseHandleSafety(g_hSmokerTongueFlyData[client]);
    CloseHandleSafety(g_hSmokerGrabTimers[client]);
}

public Action L4D_ActivateAbility_Smoker(int client, int ability)
{
    if(!IsSurvivor(client))
        return Plugin_Continue;

    if(g_hSmokerTongueFlyData[client] != null)
    {
        L4D2_SetCustomAbilityCooldown(client, 9999999.0);
        return Plugin_Handled;
    }
        
    
    if(g_hSmokerGrabTimers[client] != null)
    {
        L4D2_SetCustomAbilityCooldown(client, 9999999.0);
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

// !rcon sm plugins reload l4d2_play_as_si

public void L4D_ActivateAbility_Smoker_Post(int client, int ability)
{
    if(!IsSurvivor(client)) return;
    // Force break tongue, use a virtual tongue
    // to avoid grab teammates
    SetEntPropEnt(ability, Prop_Send, "m_currentTipTarget", -1);

    if(!TryCreateTongue(client))
    {
        L4D2_SetCustomAbilityCooldown(client, GetConVarFloat(g_hCvarSmokerAbilityCooldown));
        return;
    }
    L4D2_SetCustomAbilityCooldown(client, 9999999.0);

    float source[3]; GetClientEyePosition(client, source);
    float angle[3]; GetClientEyeAngles(client, angle);
    float dir[3]; GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR);
    NormalizeVector(dir, dir);

    AcceptEntityInput(g_iSmokerTongue[client][0], "SetParent", client);
    float relativePos[3] = {0.0, 0.0, 50.0};
    TeleportEntity(g_iSmokerTongue[client][0], relativePos);
    TeleportEntity(g_iSmokerTongue[client][1], source);

    g_hSmokerTongueFlyData[client] = new ArrayList(1, 4);
    g_hSmokerTongueFlyData[client].Set(0, GetGameTime() + GetConVarFloat(g_hCvarSmokerTongueFlyDuration));
    g_hSmokerTongueFlyData[client].Set(1, dir[0] * 10.0);
    g_hSmokerTongueFlyData[client].Set(2, dir[1] * 10.0);
    g_hSmokerTongueFlyData[client].Set(3, dir[2] * 10.0);

    RequestFrame(RequestFrame_Smoker_TongueFly, client);
}

bool TryCreateTongue(int client) 
{
    // end
    int targetEntity = CreateEntityByName("info_particle_target");
    if(targetEntity == -1)
    {
        g_iSmokerTongue[client][0] = -1;
        g_iSmokerTongue[client][1] = -1;
        return false;
    }
    char targetEntityName[32];
    Format(targetEntityName, 32, "target%d-%d", targetEntity, client);
    DispatchKeyValue(targetEntity, "targetname", targetEntityName);
    DispatchKeyValue(targetEntity, "spawnflags", "0");
    DispatchSpawn(targetEntity);
    
    // start
    int sourceEntity = CreateEntityByName("info_particle_system");
    if(sourceEntity == -1)
    {
        DeleteEntity(targetEntity);
        g_iSmokerTongue[client][0] = -1;
        g_iSmokerTongue[client][1] = -1;
        return false;
    }

    char sourceEntityName[32];
    Format(sourceEntityName, 32, "target%d-%d", sourceEntity, client);

    DispatchKeyValue(sourceEntity, "targetname", sourceEntityName);
    DispatchKeyValue(sourceEntity, "effect_name", "smoker_tongue");
    DispatchKeyValue(sourceEntity, "cpoint1", targetEntityName);
    DispatchSpawn(sourceEntity);
    ActivateEntity(sourceEntity);
 
    AcceptEntityInput(sourceEntity, "Start");

    SetVariantString("!activator");

    g_iSmokerTongue[client][0] = sourceEntity;
    g_iSmokerTongue[client][1] = targetEntity;

    return true;
}

void RequestFrame_Smoker_TongueFly(int client)
{
    if(!IsSurvivor(client) || !IsPlayerAlive(client)
    || g_hPlayerZombie[client] == null || g_hPlayerZombie[client].ZombieClass != PLAYABLE_SMOKER
    || g_hSmokerTongueFlyData[client] == null)
    {
        CloseHandleSafety(g_hSmokerTongueFlyData[client]);
        KillSmokerTongue(client);
        return;
    }
    int tongueSourceEntity = g_iSmokerTongue[client][0];
    int tongueTargetEntity = g_iSmokerTongue[client][1];
    if(!IsValidEntity(tongueSourceEntity) || !IsValidEntity(tongueTargetEntity))
    {
        CloseHandleSafety(g_hSmokerTongueFlyData[client]);
        KillSmokerTongue(client);
        L4D2_SetCustomAbilityCooldown(client, GetConVarFloat(g_hCvarSmokerAbilityCooldown));
        return;
    }
    float endTime = g_hSmokerTongueFlyData[client].Get(0);
    if(endTime <= GetGameTime())
    {
        KillSmokerTongue(client);
        CloseHandleSafety(g_hSmokerTongueFlyData[client]);
        L4D2_SetCustomAbilityCooldown(client, GetConVarFloat(g_hCvarSmokerAbilityCooldown));
        return;
    }

    float source[3]; GetAbsOrigin(tongueTargetEntity, source);
    float victimPos[3];
    // Detect whitch infected can be grabbed
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsInfected(i) || !IsPlayerAlive(i)) continue;
        
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
            CloseHandleSafety(g_hSmokerTongueFlyData[client]);

            // grab
            DataPack dp;
            g_hSmokerGrabTimers[client] = CreateDataTimer(0.25, RepeatTimer_Smoker_BonusDamage, dp, TIMER_REPEAT);
            dp.WriteCell(client);
            dp.WriteCell(i);
            return;
        }
    }

    // Tongue move forward
    float step[3];
    step[0] = g_hSmokerTongueFlyData[client].Get(1);
    step[1] = g_hSmokerTongueFlyData[client].Get(2);
    step[2] = g_hSmokerTongueFlyData[client].Get(3);
    AddVectors(source, step, source);
    TeleportEntity(tongueTargetEntity, source);

    RequestFrame(RequestFrame_Smoker_TongueFly, client);
}

Action RepeatTimer_Smoker_BonusDamage(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    if(!IsClientInGame(client) || !IsPlayerAlive(client) || g_hPlayerZombie[client] == null || g_hPlayerZombie[client].ZombieClass != PLAYABLE_SMOKER)
    {
        KillSmokerTongue(client);
        g_hSmokerGrabTimers[client] = null;
        L4D2_SetCustomAbilityCooldown(client, GetConVarFloat(g_hCvarSmokerAbilityCooldown));
        return Plugin_Stop;
    }
    int si = dp.ReadCell();
    if(!IsClientInGame(si) || !IsPlayerAlive(si))
    {
        KillSmokerTongue(client);
        g_hSmokerGrabTimers[client] = null;
        L4D2_SetCustomAbilityCooldown(client, GetConVarFloat(g_hCvarSmokerAbilityCooldown));
        return Plugin_Stop;
    }
    
    float pos[3]; GetClientAbsOrigin(si, pos);
    pos[2] += 50.0;
    TeleportEntity(g_iSmokerTongue[client][1], pos);

    if(L4D_GetAttackerSmoker(si) != client)
    {
        L4D_Smoker_ReleaseVictim(si, client);
        KillSmokerTongue(client);
        g_hSmokerGrabTimers[client] = null;
        L4D2_SetCustomAbilityCooldown(client, GetConVarFloat(g_hCvarSmokerAbilityCooldown));
        return Plugin_Stop;
    }
    
    SDKHooks_TakeDamage(si, client, client, GetConVarFloat(g_hCvarSmokerBonusDmg), DMG_SLASH, -1, NULL_VECTOR, NULL_VECTOR, false);
    return Plugin_Continue;
}

static const float VOID_VECTOR[3];
void KillSmokerTongue(int client)
{
    int source = g_iSmokerTongue[client][0];
    int target = g_iSmokerTongue[client][1];
    g_iSmokerTongue[client][0] = -1;
    g_iSmokerTongue[client][1] = -1;

    // Edict 0 is worldspawn; IsValidEdict(0) can be true — never ClearParent/Kill on it (server crash).
    if (target > 0 && IsValidEdict(target)) {
        AcceptEntityInput(target, "ClearParent");
        TeleportEntity(target, VOID_VECTOR);
        SetVariantString("OnUser1 !self:Kill::1.0:-1");
        AcceptEntityInput(target, "AddOutput");
        AcceptEntityInput(target, "FireUser1");
    }

    if (source > 0 && IsValidEdict(source)) {
        AcceptEntityInput(source, "ClearParent");
        TeleportEntity(source, VOID_VECTOR);
        SetVariantString("OnUser1 !self:Kill::1.0:-1");
        AcceptEntityInput(source, "AddOutput");
        AcceptEntityInput(source, "FireUser1");
    }
}