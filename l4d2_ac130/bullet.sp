#if defined _pure_ac130_bullet_included
 #endinput
#endif
#define _pure_ac130_bullet_included

void ShootBullet(int client)
{
    float pos[3]; GetClientEyePosition(client, pos);
    float angle[3]; GetClientEyeAngles(client, angle);
    float fwd[3];
    float right[3];
    float up[3]; GetAngleVectors(angle, fwd, right, up);
    NormalizeVector(fwd, fwd); ScaleVector(fwd, GetRandomFloat(500.0, 800.0));
    NormalizeVector(right, right); ScaleVector(right, GetRandomFloat(-50.0, 50.0))
    NormalizeVector(up, up); ScaleVector(up, GetRandomFloat(-50.0, 50.0))
    
    float traceEndPos[3];
    traceEndPos[0] = pos[0];
    traceEndPos[1] = pos[1];
    traceEndPos[2] = pos[2];
    AddVectors(traceEndPos, fwd, traceEndPos);
    AddVectors(traceEndPos, right, traceEndPos);
    AddVectors(traceEndPos, up, traceEndPos);

    float traceStartPos[3];
    NormalizeVector(fwd, fwd); ScaleVector(fwd, GetRandomFloat(-500.0, -100.0));
    AddVectors(traceEndPos, fwd, traceStartPos);
    if(!isMinigunFiring[client])
    {
        isMinigunFiring[client] = true;
        EmitSoundToClient(client, SOUND_MINIGUN_FIRE, client, SNDCHAN_WEAPON);
    }
    
    ShowMuzzleFlash(pos, angle);
    ShowTrack(traceStartPos, traceEndPos);

    float enemyPos[3];
    int enemy = SelectEnemyOfMinDegree(client);
    if(enemy <= 0)
    {
        if(RayGetAimPosition(client, enemyPos))
        {
            EmitAmbientSound(SOUND_MINIGUN_HIT_FLOOR, enemyPos);
        }
    }
    else
    {
        GetAbsOrigin(enemy, enemyPos);
        EmitAmbientSound(SOUND_MINIGUN_HIT_ENEMY, enemyPos);
        CreateParticleAutoKill(client, PARTICLE_BLOOD, 0.1, enemyPos);
        SDKHooks_TakeDamage(enemy, client, client, GetConVarFloat(bulletHitDamage), DMG_BULLET, -1, NULL_VECTOR, NULL_VECTOR, false);
    }
}

void ShowMuzzleFlash(float pos[3], float angle[3])
{  
    int particle = CreateEntityByName("info_particle_system");
    DispatchKeyValue(particle, "effect_name", PARTICLE_MUZZLE_FLASH); 
    DispatchSpawn(particle);
    ActivateEntity(particle); 

    TeleportEntity(particle, pos, angle, NULL_VECTOR);
    AcceptEntityInput(particle, "Start");

    SetVariantString("OnUser1 !self:Kill::0.01:-1");
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");
}
void ShowTrack(float pos[3], float endpos[3])
{  
    char temp[32];        
    int target = CreateEntityByName("info_particle_target");
    Format(temp, 32, "cptarget%d", target);
    DispatchKeyValue(target, "targetname", temp);    
    TeleportEntity(target, endpos, NULL_VECTOR, NULL_VECTOR); 
    ActivateEntity(target); 
 
    int particle = CreateEntityByName("info_particle_system");
    DispatchKeyValue(particle, "effect_name", PARTICLE_WEAPON_TRACER2);
    DispatchKeyValue(particle, "cpoint1", temp);
    DispatchSpawn(particle);
    ActivateEntity(particle); 
    TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(particle, "Start");

    SetVariantString("OnUser1 !self:Kill::0.01:-1");
    AcceptEntityInput(target, "AddOutput");
    AcceptEntityInput(target, "FireUser1");

    SetVariantString("OnUser1 !self:Kill::0.01:-1");
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");
}