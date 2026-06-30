#if defined _pure_ac130_grenade_included
 #endinput
#endif
#define _pure_ac130_grenade_included

void ShootGrenade(int client)
{
    float pos[3]; GetClientEyePosition(client, pos);
    float angle[3]; GetClientEyeAngles(client, angle);
    float dir[3]; GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR); NormalizeVector(dir, dir);

    int grenade = CreateGrenadeProjectile(client);
    if(grenade <= 0)
    {
#if defined _pure_is_lazy_to_make_translation
        CPrintToChat(client, "{red}[ERROR]{default} Fail to Create Grenade");
#else
        CPrintToChat(client, "{red}[ERROR]{default} 榴弹出错了，请通知管理员");
#endif
        return;
    }
    TeleportEntity(grenade, pos, angle);

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

    int train = CreateTrackTrain(client, pos, endPos, OnGrenadeProjectileArrived);

    SetVariantString("!activator");
    AcceptEntityInput(grenade, "SetParent", train, train);

    AcceptEntityInput(train, "StartForward");
    // 播放榴弹开火音效
    EmitSoundToClient(client, SOUND_GRENADE_LAUNCHER_FIRE);
}

int CreateGrenadeProjectile(int client)
{
    int entity = CreateEntityByName("prop_dynamic_override");
    if(entity <= 0)
    {
        return -1;
    }
    char name[64];
    Format(name, 64, "GP-%d-%d", entity, client);
    DispatchKeyValue(entity, "model", MODEL_GRENADE_PROJECTILE);
    DispatchKeyValue(entity, "solid", "0");
    DispatchKeyValue(entity, "targetname", name);
    if(DispatchSpawn(entity))
    {
        ActivateEntity(entity);

        int trail = CreateParticle(client, PARTICLE_GRENADE_PROJECTILE_TRAIL);
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
void OnGrenadeProjectileArrived(const char[] output, int caller, int activator, float delay)
{
    int client = GetEntPropEnt(activator, Prop_Send, "m_hOwnerEntity");
    float center[3]; GetAbsOrigin(caller, center);

    int projectile;
    if(GetRandomInt(1, 10) <= 5)
    {
        projectile = L4D2_GrenadeLauncherPrj(client, center, view_as<float>({0.0, 0.0, 0.0}));
    }
    else
    {
        projectile = L4D2_GrenadeLauncherPrj(client, center, view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR, NULL_VECTOR, true);
    }
    L4D_DetonateProjectile(projectile);
    DeleteTrackTrain(activator);
} 