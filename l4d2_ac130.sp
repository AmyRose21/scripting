#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <colors>
#include "l4d2_ac130/consts.sp"
#include "l4d2_ac130/convars.sp"
#include "l4d2_ac130/infected_manager.sp"
#include "l4d2_ac130/variables.sp"
#include "l4d2_ac130/utils.sp"
#include "l4d2_ac130/effects.sp"
#include "l4d2_ac130/events.sp"
#include "l4d2_ac130/missile.sp"
#include "l4d2_ac130/grenade.sp"
#include "l4d2_ac130/bullet.sp"
// #include "l4d2_ac130/test.sp"



public Plugin AC130PluginInfo =
{
    name = "AC130",
    author = "Pure_*",
    description = "Let players can drive AC130 and shoot",
    version = "0.1",
    url = ""
};

public OnPluginStart()
{
#if defined _pure_ac130_test_included
    RegisterTestCommand();
#endif
    InitConvars();
    InitVariables();

    HookEvents();

    RegConsoleCmd("sm_bh130", Command_Drive);
    RegConsoleCmd("sm_ubh130", Command_Undrive);
}

public void OnMapStart()
{
    PrecacheModel(MODEL_AC130, true);
    PrecacheModel(MODEL_MISSILE, true);
    PrecacheModel(MODEL_GRENADE_PROJECTILE, true);

    PrecacheSound(SOUND_MISSILE_FLY, true);
    PrecacheSound(SOUND_MINIGUN_FIRE, true);
    PrecacheSound(SOUND_MISSILE_EXPLODE, true);
    PrecacheSound(SOUND_GRENADE_LAUNCHER_FIRE, true);
    
    PrecacheGeneric(PARTICLE_GENERIC_MILITARY);
    PrecacheGeneric(PARTICLE_GENERIC_WEAPON);
    PrecacheGeneric(PARTICLE_GENERIC_BLOOD);
    PrecacheEffect("ParticleEffect");
    PrecacheParticleEffect(PARTICLE_MISSILE_TRAIL);
    PrecacheParticleEffect(PARTICLE_MISSILE_EXPLODE);
    PrecacheParticleEffect(PARTICLE_MISSILE_FIRE);
    PrecacheParticleEffect(PARTICLE_GRENADE_PROJECTILE_TRAIL);
    PrecacheParticleEffect(PARTICLE_MUZZLE_FLASH);
    PrecacheParticleEffect(PARTICLE_WEAPON_TRACER);
    PrecacheParticleEffect(PARTICLE_WEAPON_TRACER2);
    PrecacheParticleEffect(PARTICLE_BLOOD);
    PrecacheParticleEffect(PARTICLE_BLOOD_HEADSHOT);
    
}

Action Command_Undrive(int client, int args)
{
    if(planes[client] <= 0)
    {
        return Plugin_Stop;
    }
    allow[client] = false;
    SDKUnhook(client, SDKHook_OnTakeDamage, OnGodMode);
    SDKUnhook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
    AcceptEntityInput(client, "ClearParent");

    DeleteEntity(planes[client]);
    planes[client] = 0;

    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && GetEntityMoveType(i) == MOVETYPE_WALK)
        {
            float pos[3]; GetClientAbsOrigin(i, pos);
            TeleportEntity(client, pos);
            break;
        }
    }
    SetEntityMoveType(client, MOVETYPE_WALK);
    SetClientRenderNormal(client);
    return Plugin_Continue;
}

Action Command_Drive(int client, int args)
{
    if(planes[client] > 0)
    {
        return Plugin_Stop;
    }
    int plane = CreateHelicopter(client);
    if(plane <= 0)
    {
#if defined _pure_is_lazy_to_make_translation
        CPrintToChat(client, "{red}[ERROR]{default} Failed to Create AC130");
#else
        CPrintToChat(client, "{red}[ERROR]{default} AC130创建失败");
#endif
        return Plugin_Stop;
    }
    Revive(client);
    SetEntProp(plane, Prop_Send, "m_nSequence", 3);
    SetEntPropFloat(plane, Prop_Send, "m_flCycle", 0.0);
    SetEntPropFloat(plane, Prop_Send, "m_flPlaybackRate", 1.0);
    weaponAmmoCnt[client][0] = ammoMaxCnt[0];
    weaponAmmoCnt[client][1] = ammoMaxCnt[1];
    weaponAmmoCnt[client][2] = ammoMaxCnt[2];
    float pos[3]; GetClientAbsOrigin(client, pos);
    float eyePos[3]; GetClientEyePosition(client, eyePos);
    float offset[3]; SubtractVectors(pos, eyePos, offset);
    float planePos[3]; AddVectors(pos, view_as<float>({0.0, 0.0, 700.0}), planePos);
    TeleportEntity(plane, planePos);

    allow[client] = true;
    SDKHook(client, SDKHook_OnTakeDamage, OnGodMode);
    SDKHook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);

    SetEntityMoveType(client, MOVETYPE_NOCLIP);

    for(int i = 0; i < 5; i++)
    {
        int weapon = GetPlayerWeaponSlot(client, i);
        if(weapon != -1)
        {
            SDKHooks_DropWeapon(client, weapon);
        }
    }

    SetClientTransparent(client);
    
    AddVectors(planePos, offset, planePos);

    int train = CreateTrackTrain(client, pos, planePos, OnDriverAboard);

    SetVariantString("!activator");
    AcceptEntityInput(client, "SetParent", train, train);

    AcceptEntityInput(train, "StartForward");

    planes[client] = plane;
    return Plugin_Continue;
}

void OnDriverAboard(const char[] output, int caller, int activator, float delay)
{
    int client = GetEntPropEnt(activator, Prop_Send, "m_hOwnerEntity");

    AcceptEntityInput(client, "ClearParent");
    SetVariantString("!activator");
    AcceptEntityInput(client, "SetParent", planes[client], planes[client]);
#if defined _pure_is_lazy_to_make_translation
        CPrintToChat(client, "{blue}AC130{default}: Captain %N, we have arrived and can support the ground forces.", client);
#else
        CPrintToChat(client, "{blue}AC130{default}: %N长官，我们到了，可以支援地面部队", client);
#endif
    DeleteTrackTrain(activator);
}

Action OnWeaponSwitch(int client, int weapon)
{
    return Plugin_Handled;
}

Action OnGodMode(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
    return Plugin_Handled;
}

int CreateHelicopter(int client)
{
    int entity = CreateEntityByName("prop_dynamic_override");
    if(entity <= 0)
    {
        
        return -1;
    }
    char name[64];
    Format(name, 64, "AC130-%d-%d", entity, client);
    DispatchKeyValue(entity, "model", MODEL_AC130);
    DispatchKeyValue(entity, "solid", "0");
    DispatchKeyValue(entity, "targetname", name);
    if(DispatchSpawn(entity))
    {
        ActivateEntity(entity);
        return entity;
    }
    DeleteEntity(entity);
    return -1;
}


public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if(!IsSurvivor(client))
        return Plugin_Continue;

    if(!allow[client])
        return Plugin_Continue;

    OperatePlane(client, buttons);

    if(buttons & IN_ZOOM)
    {
        SwitchWeapon(client);
    }

    if(buttons & IN_RELOAD)
    {
        Reload(client);
    }

    if(buttons & IN_ATTACK)
    {
        Shoot(client);
    }
    else
    {
        if(isMinigunFiring[client])
        {
            isMinigunFiring[client] = false;
            StopSound(client, SNDCHAN_WEAPON, SOUND_MINIGUN_FIRE);
        }
    }

    buttons = 0;
    vel[0] = 0.0;
    vel[1] = 0.0;
    vel[2] = 0.0;
    return Plugin_Changed;
}

void OperatePlane(int client, int buttons)
{
    float origin[3]; GetAbsOrigin(planes[client], origin);
    float offset[3]; offset = view_as<float>({0.0, 0.0, 0.0});
    float rotate[3]; GetEntPropVector(planes[client], Prop_Send, "m_angRotation", rotate);

    if(buttons & (IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT | IN_DUCK | IN_SPEED))
    {
        planeSmoothParam[client] += smoothTick;
        if(planeSmoothParam[client] >= 1.0)
        {
            planeSmoothParam[client] = 1.0;
        }
    }
    else
    {
        planeSmoothParam[client] = 0.0;
        if(FloatAbs(rotate[0]) >= 1.1)
        {
            rotate[0] -= rotate[0] / FloatAbs(rotate[0]);
        }
        else
        {
            rotate[0] = 0.0;
        }

        if(FloatAbs(rotate[2]) >= 2.2)
        {
            rotate[2] -= (rotate[2] / FloatAbs(rotate[1])) * 2;
        }
        else
        {
            rotate[2] = 0.0;
        }
    }

    if(buttons & IN_FORWARD)
    {
        offset[0] += 5.0 * planeSmoothParam[client];
        rotate[0] += 5.0 * planeSmoothParam[client];
        if(rotate[0] >= 30.0)
        {
            rotate[0] = 30.0;
        }
    }
    if(buttons & IN_BACK)
    {
        offset[0] -= 5.0 * planeSmoothParam[client];
        rotate[0] -= 5.0 * planeSmoothParam[client];
        if(rotate[0] <= -30.0)
        {
            rotate[0] = -30.0;
        }
    }
    if(buttons & IN_MOVELEFT)
    {
        offset[1] += 5.0 * planeSmoothParam[client];
        rotate[1] += 2.0 * planeSmoothParam[client];
        rotate[2] -= 2.0 * planeSmoothParam[client];
        if(rotate[2] <= -20.0)
        {
            rotate[2] = -20.0;
        }
    }
    if(buttons & IN_MOVERIGHT)
    {
        offset[1] -= 5.0 * planeSmoothParam[client];
        rotate[1] -= 2.0 * planeSmoothParam[client];
        rotate[2] += 2.0 * planeSmoothParam[client];
        if(rotate[2] >= 20.0)
        {
            rotate[2] = 20.0;
        }
    }

    
    float fwd[3];
    float right[3];
    GetAngleVectors(rotate, fwd, right, NULL_VECTOR); NormalizeVector(fwd, fwd); NormalizeVector(right, right);
    ScaleVector(fwd, offset[0]); ScaleVector(right, offset[1]); AddVectors(fwd, right, offset); offset[2] = 0.0;
    
    if(buttons & IN_DUCK)
    {
        offset[2] -= 2.0 * planeSmoothParam[client];
    }
    
    if(buttons & IN_SPEED)
    {
        offset[2] += 2.0 * planeSmoothParam[client];
    }

    AddVectors(origin, offset, origin);
    TeleportEntity(planes[client], origin, rotate);
}

void SwitchWeapon(int client)
{
    if(GetGameTime() - lastSwitchTimes[client] < 0.3)
        return;

    lastSwitchTimes[client] = GetGameTime();

    weaponId[client]++;
    if(weaponId[client] > 2)
    {
        weaponId[client] = 0;
    }
    // 
#if defined _pure_is_lazy_to_make_translation
    CPrintToChat(client, "{blue}AC130{default}: Captain %N, switch to %s. Over!", client, tips[weaponId[client]]);
#else
    CPrintToChat(client, "{blue}AC130{default}: %N长官，已经切换到%s", client, tips[weaponId[client]]);
#endif
}

void Reload(int client)
{
    int id = weaponId[client];
    if(weaponAmmoCnt[client][id] >= ammoMaxCnt[id])
    {
        if(GetGameTime() - lastReloadTipTimes[client] > 3.0)
        {
#if defined _pure_is_lazy_to_make_translation
            CPrintToChat(client, "{blue}AC130{default}: Captain {olive}%N{default}, the ammo is full. Over!", client);
#else
            CPrintToChat(client, "{blue}AC130{default}: {olive}%N{default}长官，弹药是满的", client);
#endif
            lastReloadTipTimes[client] = GetGameTime();
        }
        return;
    }
    
    if(reloadTimers[client][id] != null)
    {
        if(GetGameTime() - lastReloadTipTimes[client] > 3.0)
        {
#if defined _pure_is_lazy_to_make_translation
            CPrintToChat(client, "{blue}AC130{default}: Captain {olive}%N{default}, reloading. Over!", client);
#else
            CPrintToChat(client, "{blue}AC130{default}: {olive}%N{default}长官，正在装填中，请稍等...", client);
#endif   
            lastReloadTipTimes[client] = GetGameTime();
        }
        return;
    }
    

    DataPack dp;
    reloadTimers[client][id] = CreateDataTimer(reloadDuration[id], Timer_Reload, dp, TIMER_FLAG_NO_MAPCHANGE);
    dp.WriteCell(client);
    dp.WriteCell(id);
#if defined _pure_is_lazy_to_make_translation
    CPrintToChat(client, "{blue}AC130{default}: Captain {olive}%N{default}, the %s ammo will be loaded in %.1f seconds. Over!", client, tips[id], reloadDuration[id]);
#else
    CPrintToChat(client, "{blue}AC130{default}: {olive}%N{default}长官，%s弹药%.0f秒后装填完毕", client, tips[id], reloadDuration[id]);
#endif  
}

Action Timer_Reload(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    int id = dp.ReadCell();
    if(!IsSurvivor(client))
    {
        reloadTimers[client][id] = null;
        return Plugin_Stop;
    }
    reloadTimers[client][id] = null;
    weaponAmmoCnt[client][id] = ammoMaxCnt[id];
#if defined _pure_is_lazy_to_make_translation
    CPrintToChat(client, "{blue}AC130{default}: Captain {olive}%N{default}, %s reloading completed. Over!", client, tips[id]);
#else
    CPrintToChat(client, "{blue}AC130{default}: {olive}%N{default}长官，%s弹药装填完毕", client, tips[id]);
#endif 
    
    return Plugin_Continue;
}

void Shoot(int client)
{
    int id = weaponId[client];
    if(weaponAmmoCnt[client][id] <= 0)
    {
        if(GetGameTime() - lastFireEmptyTipTimes[client] < 2.0)
        {
#if defined _pure_is_lazy_to_make_translation
            CPrintToChat(client, "{blue}AC130{default}: Captain {olive}%N{default}, wait for reloading. Over!", client);
#else
            CPrintToChat(client, "{blue}AC130{default}: {olive}%N{default}长官，请等待装填", client);
#endif 
            lastFireEmptyTipTimes[client] = GetGameTime();
        }
        return;
    }

    if(GetGameTime() - lastFireTimes[client][id] <= shootInterval[id])
        return;

    lastFireTimes[client][id] = GetGameTime();

    
    switch(id)
    {
        case 0:
        {
            ShootMissile(client);
        }
        case 1:
        {
            ShootGrenade(client);
        }
        case 2:
        {
            ShootBullet(client);
        }
    }

    weaponAmmoCnt[client][id]--;

    if(weaponAmmoCnt[client][id] <= 0)
    {
        Reload(client);
    }
}



int SelectEnemyOfMinDegree(int client)
{
    float startPos[3]; GetClientEyePosition(client, startPos);
    float angle[3]; GetClientEyeAngles(client, angle);
    float fwd[3]; GetAngleVectors(angle, fwd, NULL_VECTOR, NULL_VECTOR);

    int target = -1;
    float minDegrees = 361.0;
    float pos[3];
    float dir[3];

    ArrayList arr = infectedMgr.GetAllInfecteds();
    for(int i = 0; i < arr.Length; i++)
    {
        int infected = arr.Get(i);
        GetAbsOrigin(infected, pos);
        
        MakeVectorFromPoints(startPos, pos, dir);
        float degree = GetAngleBetweenTwoDirection(fwd, dir);
        if(degree > 30.0)
            continue;
        if(degree > minDegrees)
            continue;
        
        minDegrees = degree;
        target = infected;
    }
    CloneHandle(arr);

    return target;
}

