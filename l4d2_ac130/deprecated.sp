void ShootMissile(int client)
{
    float pos[3]; GetClientEyePosition(client, pos);
    float angle[3]; GetClientEyeAngles(client, angle);
    float dir[3]; GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR); NormalizeVector(dir, dir); ScaleVector(dir, 50.0);

    int missile = CreateMissile(client);
    if(missile <= 0)
    {
        PrintToChat(client, "[ERROR] 导弹出错了，请通知管理员");
        return;
    }

    TeleportEntity(missile, pos, angle);
    int enemy = SelectEnemyOfMinDegree(client);
    if(enemy <= 0)
    {
        // 用飞行时间即可 -> 爆炸
        DataPack dp;
        CreateDataTimer(0.1, Timer_MissileFly_Time, dp, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        dp.WriteCell(missile);
        dp.WriteCell(client);
        dp.WriteFloat(GetGameTime() + 2.0);
        dp.WriteFloatArray(dir, 3);
    }
    else
    {
        float terminal[3]; GetAbsOrigin(enemy, terminal);
        DataPack dp;
        CreateDataTimer(0.1, Timer_MissileFly_Target, dp, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        dp.WriteCell(missile);
        dp.WriteCell(client);
        dp.WriteFloatArray(terminal, 3);
        dp.WriteFloatArray(dir, 3);
    }
    
    // todo 播放导弹飞行音效
    EmitSoundToAll("animation/jets/jet_by_01_mono.wav");
    CPrintToChat(client, "{blue}AC130{default}: {olive}%N{default}长官，导弹已发射", client);
    CPrintToChatAll("{blue}%N{default}:地面部队，空中支援来袭，注意躲避", client);
}

Action Timer_MissileFly_Time(Handle timer, DataPack dp)
{
    dp.Reset();
    int missile = dp.ReadCell();
    if(!IsValidEntity(missile))
    {
        return Plugin_Stop;
    }
    int client = dp.ReadCell();
    if(!IsSurvivor(client))
    {
        DeleteEntity(missile);
        return Plugin_Stop;
    }
    float endTime = dp.ReadFloat();
    float dir[3]; dp.ReadFloatArray(dir, 3);
    float pos[3]; GetAbsOrigin(missile, pos);
    if(GetGameTime() >= endTime)
    {
        DOForceAndDamage(client, pos);
        // 爆炸音效
        // 爆炸粒子效果
        DeleteEntity(missile);
        return Plugin_Stop;
    }

    AddVectors(pos, dir, pos);
    TeleportEntity(missile, pos);
    return Plugin_Continue;
}

Action Timer_MissileFly_Target(Handle timer, DataPack dp)
{
    dp.Reset();
    int missile = dp.ReadCell();
    if(!IsValidEntity(missile))
    {
        return Plugin_Stop;
    }
    int client = dp.ReadCell();
    if(!IsSurvivor(client))
    {
        DeleteEntity(missile);
        return Plugin_Stop;
    }
    float hitPoint[3]; dp.ReadFloatArray(hitPoint, 3);
    float dir[3]; dp.ReadFloatArray(dir, 3);

    float pos[3]; GetAbsOrigin(missile, pos);
    
    if(GetVectorDistance(pos, hitPoint, true) <= 2500.0)
    {
        DOForceAndDamage(client, hitPoint);
        // 爆炸音效
       
        EmitSoundToAll(SOUND_MISSILE_EXPLODE);
        
        // 爆炸粒子效果
        PCreateParticle(client, "explosion_huge", 3.0, hitPoint);
        DeleteEntity(missile);
        return Plugin_Stop;
    }
    
    AddVectors(pos, dir, pos);
    TeleportEntity(missile, pos);
    return Plugin_Continue;
}

Action Timer_GrenadeFly_Time(Handle timer, DataPack dp)
{
    dp.Reset();
    int grenade = dp.ReadCell();
    if(!IsValidEntity(grenade))
    {
        return Plugin_Stop;
    }
    int client = dp.ReadCell();
    if(!IsSurvivor(client))
    {
        DeleteEntity(grenade);
        return Plugin_Stop;
    }
    float endTime = dp.ReadFloat();
    if(GetGameTime() >= endTime)
    {
        L4D_DetonateProjectile(grenade);
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

Action Timer_GrenadeFly_Target(Handle timer, DataPack dp)
{
    dp.Reset();
    int grenade = dp.ReadCell();
    if(!IsValidEntity(grenade))
    {
        return Plugin_Stop;
    }
    int client = dp.ReadCell();
    if(!IsSurvivor(client))
    {
        DeleteEntity(grenade);
        return Plugin_Stop;
    }
    float pos[3]; dp.ReadFloatArray(pos, 3);
    TeleportEntity(grenade, pos);
    L4D_DetonateProjectile(grenade);
    return Plugin_Continue;
}

void ShootBullet(int client)
{
    // int minigun = miniguns[client];
    float pos[3]; GetClientEyePosition(client, pos);
    float angle[3]; GetClientEyeAngles(client, angle);
    float dir[3]; 
    

    SetEntProp(minigun, Prop_Send, "m_firing", 1);
    SetEntPropFloat(minigun, Prop_Send, "m_heat", 0.0);
    SetEntProp(minigun, Prop_Send, "m_overheated", 0);

    int enemy = SelectEnemyOfMinDegree(client);
    if(enemy <= 0)
    {
        GetClientEyeAngles(client, angle);
        DispatchKeyValueVector(minigun, "Angles", angle);
    }
    else
    {
        float enemyPos[3]; GetAbsOrigin(enemy, enemyPos);
        MakeVectorFromPoints(pos, enemyPos, dir);
        GetVectorAngles(dir, angle);
        DispatchKeyValueVector(minigun, "Angles", angle);
        SDKHooks_TakeDamage(enemy, client, client, 50.0, DMG_BULLET, -1, NULL_VECTOR, NULL_VECTOR, false);
    }
}