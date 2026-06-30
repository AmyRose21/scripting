#if defined _pure_ac130_missile_included
 #endinput
#endif
#define _pure_ac130_missile_included

void ShootMissile(int client)
{
    float pos[3]; GetClientEyePosition(client, pos);
    float angle[3]; GetClientEyeAngles(client, angle);
    float dir[3]; GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR); NormalizeVector(dir, dir);

    int missile = CreateMissile(client);
    if(missile <= 0)
    {
#if defined _pure_is_lazy_to_make_translation
        CPrintToChat(client, "{red}[ERROR]{default} Fail to Create Missile");
#else
        CPrintToChat(client, "{red}[ERROR]{default} 导弹出错了");
#endif
        return;
    }    
    TeleportEntity(missile, pos, angle);

    float endPos[3];
    int enemy = SelectEnemyOfMinDegree(client);
    if(enemy <= 0)
    {
        if(!RayGetAimPosition(client, endPos))
        {
            // 没有敌人就视线前方发射
            ScaleVector(dir, 1500.0);
            AddVectors(pos, dir, endPos);
        }
    }
    else
    {
        GetAbsOrigin(enemy, endPos);
    }
    
    int train = CreateTrackTrain(client, pos, endPos, OnMissileArrived);
    
    SetVariantString("!activator");
    AcceptEntityInput(missile, "SetParent", train, train);

    AcceptEntityInput(train, "StartForward");
    CreateParticleAutoKill(client, PARTICLE_MISSILE_FIRE, 3.0, pos);
    EmitSoundToAll(SOUND_MISSILE_FLY);
    ShakeScreen(client, 0, 10.0, 100.0, 2.0);
#if defined _pure_is_lazy_to_make_translation
        CPrintToChat(client, "{blue}AC130{default}: Captain {olive}%N{default}, Missile Launched.", client);
        CPrintToChatAll("{blue}%N{default}: Ground troops, MISSILE is coming!", client);
#else
        CPrintToChat(client, "{blue}AC130{default}: {olive}%N{default}长官，导弹已发射", client);
        CPrintToChatAll("{blue}%N{default}:地面部队，空中支援来袭，注意躲避", client);
#endif
    
}

int CreateMissile(int client)
{
    int entity = CreateEntityByName("prop_dynamic_override");
    if(entity <= 0)
    {
        return -1;
    }
    char name[64];
    Format(name, 64, "Missile-%d-%d", entity, client);
    DispatchKeyValue(entity, "model", MODEL_MISSILE);
    DispatchKeyValue(entity, "solid", "0");
    DispatchKeyValue(entity, "targetname", name);
    if(DispatchSpawn(entity))
    {
        ActivateEntity(entity);

        int trail = CreateParticle(client, PARTICLE_MISSILE_TRAIL);
        if (trail > 0)
        {
            SetVariantString("!activator");
            AcceptEntityInput(trail, "SetParent", entity, entity);
            TeleportEntity(trail, view_as<float>({0.0, 0.0, 0.0}), view_as<float>({0.0, 0.0, 0.0}))
        }
        return entity;
    }
    DeleteEntity(entity);
    return -1;
}


// caller -> 终点
// activator -> controller(track train)
void OnMissileArrived(const char[] output, int caller, int activator, float delay)
{
    int client = GetEntPropEnt(activator, Prop_Send, "m_hOwnerEntity");
    float center[3]; GetAbsOrigin(caller, center);
    EmitSoundToAll(SOUND_MISSILE_EXPLODE);

    CreateParticleAutoKill(client, PARTICLE_MISSILE_EXPLODE, 3.0, center);

    DOMissileForceAndDamageToInfected(client, center);
    DOMissileForceAndDamageToSurvivor(client, center);
    
    DeleteTrackTrain(activator);
}

void DOMissileForceAndDamageToInfected(int client, float center[3])
{
    float velocity[3];
    float explodeVelocity[3];
    float pos[3];

    float radius = GetConVarFloat(missileExplodeRadius);
    float damage = GetConVarFloat(missileExplodeDamage);
    float force = GetConVarFloat(missileExplodeForce);

    ArrayList arr = infectedMgr.GetAllInfecteds();
    for(int i = 0; i < arr.Length; i++)
    {
        int infected = arr.Get(i);
        GetAbsOrigin(infected, pos);
        float distance = GetVectorDistance(center, pos);
        
        if(distance > radius)
            continue;
        float fade = 1.0 - distance / radius;
        if(infected <= MAXPLAYERS)
        {
            // Special Infected
            MakeVectorFromPoints(center, pos, explodeVelocity);
            NormalizeVector(explodeVelocity, explodeVelocity);
            ScaleVector(explodeVelocity, fade * force);

            GetEntPropVector(infected, Prop_Data, "m_vecVelocity", velocity);

            AddVectors(velocity, explodeVelocity, velocity);
            TeleportEntity(infected, NULL_VECTOR, NULL_VECTOR, velocity);
        }
        SDKHooks_TakeDamage(infected, client, client, fade * damage, DMG_BLAST, -1, NULL_VECTOR, NULL_VECTOR, false);
    }
    CloneHandle(arr);
}

void DOMissileForceAndDamageToSurvivor(int client, float center[3])
{
    float velocity[3];
    float explodeVelocity[3];
    float pos[3];

    // Todo 配置参数
    float radius = GetConVarFloat(missileExplodeRadius);
    float damage = GetConVarFloat(missileExplodeTeamDamage);
    float force = GetConVarFloat(missileExplodeForce);
    float shakeAmplitude = GetConVarFloat(missileExplodeShakeAmplitude);
    float shakeDuration = GetConVarFloat(missileExplodeShakeDuration);
    for(int i = 1; i <= MaxClients; i++)
    {
        // if(i != client && IsSurvivor(i) && IsPlayerAlive(i))
        if(IsSurvivor(i) && IsPlayerAlive(i))
        {
            GetAbsOrigin(i, pos);
            float distance = GetVectorDistance(center, pos);
            if(distance > radius)
                continue;
            float fade  = 1.0 - distance / radius;
            MakeVectorFromPoints(center, pos, explodeVelocity);
            NormalizeVector(explodeVelocity, explodeVelocity);
            ScaleVector(explodeVelocity, fade * force);

            GetEntPropVector(i, Prop_Data, "m_vecVelocity", velocity);

            AddVectors(velocity, explodeVelocity, velocity);
            TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, velocity);
            SDKHooks_TakeDamage(i, client, client, damage * fade, DMG_BULLET, -1, NULL_VECTOR, NULL_VECTOR, false);
            ShakeScreen(i, 0, fade * shakeAmplitude, 150.0, shakeDuration * fade);
        }
    }
}