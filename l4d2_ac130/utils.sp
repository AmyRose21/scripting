#if defined _pure_ac130_utils_included
 #endinput
#endif
#define _pure_ac130_utils_included

stock bool IsClientValid(int client)
{
    return 1 <= client && client <= MaxClients && IsClientInGame(client);
}

stock bool IsRealClient(int client)
{
    return IsClientValid(client) && !IsFakeClient(client);
}

stock bool IsSurvivor(int client)
{
    return IsClientValid(client) && GetClientTeam(client) == TEAM_SURVIVOR;
}

stock bool IsInfected(int client)
{
    return IsClientValid(client) && GetClientTeam(client) == TEAM_INFECTED;
}

stock bool IsCommonInfected(int entity)
{
    if (!IsValidEntity(entity))
        return false;

    char classname[9];
    GetEntityClassname(entity, classname, 9);
    return StrEqual(classname, "infected", false);
}

stock float GetAngleBetweenTwoDirection(float a[3], float b[3])
{
    float modA = SquareRoot(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
    float modB = SquareRoot(b[0] * b[0] + b[1] * b[1] + b[2] * b[2]);
    float dotProd = GetVectorDotProduct(a, b);
    float cos = dotProd / (modA * modB);
    return RadToDeg(ArcCosine(cos));
}

stock void ShowProgressBar(int client, float duration)
{
    SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
    SetEntPropFloat(client, Prop_Send, "m_flProgressBarDuration", duration);
}


void DeleteEntity(int entity)
{
    if(entity > 0 && IsValidEntity(entity))
    {
        AcceptEntityInput(entity, "Kill");
    }
}

stock void PrecacheEffect(const char[] effectName)
{
    static int table = INVALID_STRING_TABLE;
    
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("EffectDispatch");
    }
    bool save = LockStringTables(false);
    AddToStringTable(table, effectName);
    LockStringTables(save);
}

stock void PrecacheParticleEffect(const char[] effectName)
{
    static int table = INVALID_STRING_TABLE;
    
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("ParticleEffectNames");
    }
    bool save = LockStringTables(false);
    AddToStringTable(table, effectName);
    LockStringTables(save);
}

int CreateParticle(int client, const char[] particleName)
{
    int entity = CreateEntityByName("info_particle_system");
    if (entity <= 0)
    {
        PrintToChat(client, "[ERROR] info_particle_system 创建失败");
        return -1;
    }
    char name[128];
    Format(name, 128, "%s-%d-%d", particleName, entity, client);
    DispatchKeyValue(entity, "targetname", name);
    DispatchKeyValue(entity, "effect_name", particleName);
    if(DispatchSpawn(entity))
    {
        ActivateEntity(entity);
        AcceptEntityInput(entity, "Start");
        return entity;
    }
    DeleteEntity(entity);
    return -1;
}

int CreateParticleAutoKill(int client, const char[] particleName, float duration, float pos[3])
{
    int entity = CreateEntityByName("info_particle_system");
    if (entity <= 0)
    {
        PrintToChat(client, "[ERROR] info_particle_system 创建失败");
        return -1;
    }
    char name[128];
    Format(name, 128, "%s-%d-%d", particleName, entity, client);
    DispatchKeyValue(entity, "targetname", name);
    DispatchKeyValue(entity, "effect_name", particleName);
    if(DispatchSpawn(entity))
    {
        TeleportEntity(entity, pos);
        ActivateEntity(entity);
        AcceptEntityInput(entity, "Start");


        char variantName[64];
        Format(variantName, 64, "OnUser1 !self:Kill::%.1f:-1", duration);

        SetVariantString(variantName);
        AcceptEntityInput(entity, "AddOutput");
        AcceptEntityInput(entity, "FireUser1");
        return entity;
    }
    DeleteEntity(entity);
    return -1;
}

stock int CreateTrackTrain(int client, float startPos[3], float endPos[3], EntityOutput onTrainArrived)
{
    int endEntity = CreateEntityByName("path_track");
    if(endEntity <= 0)
    {
        PrintToChat(client, "[ERROR] path_track end 创建失败");
        return -1;
    }
    char endName[32];
    Format(endName, 32, "End-%d-%d", endEntity, client);
    DispatchKeyValue(endEntity, "targetname", endName);
    if(DispatchSpawn(endEntity))
    {   
        ActivateEntity(endEntity);
        AcceptEntityInput(endEntity, "EnablePath");
        TeleportEntity(endEntity, endPos);
    }
    else
    {
        DeleteEntity(endEntity);
        return -1;
    }
    HookSingleEntityOutput(endEntity, "OnPass", onTrainArrived, true);


    int startEntity = CreateEntityByName("path_track");
    if(startEntity <= 0)
    {
        PrintToChat(client, "[ERROR] path_track start 创建失败");
        return -1;
    }
    char startName[32];
    Format(startName, 32, "Start-%d-%d", startEntity, client);
    DispatchKeyValue(startEntity, "targetname", startName);
    DispatchKeyValue(startEntity, "target", endName);
    if(DispatchSpawn(startEntity))
    {   
        ActivateEntity(startEntity);
        AcceptEntityInput(startEntity, "EnablePath");
        TeleportEntity(startEntity, startPos);
    }
    else
    {
        DeleteEntity(endEntity);
        DeleteEntity(startEntity);
        return -1;
    }

    int controller = CreateEntityByName("func_tracktrain");
    if(controller <= 0)
    {
        PrintToChat(client, "[ERROR] track_train 创建失败");
        return -1;
    }
    char name[64];
    Format(name, 64, "Controller-%d-%d-%d-%d", controller, client, startEntity, endEntity);  // 把路径相关entity写到名字里面去
    DispatchKeyValue(controller, "spawnflags", "24")//16 | 2 | 8 | 512);
    DispatchKeyValue(controller, "targetname", name);
    DispatchKeyValue(controller, "target", startName);
    DispatchKeyValueInt(controller, "speed", 1000);
    DispatchKeyValueInt(controller, "startspeed", 1000);
    DispatchKeyValue(controller, "velocitytype", "2");
    DispatchKeyValue(controller, "orientationtype", "0");
    DispatchKeyValue(controller, "wheels", "50");
    DispatchKeyValue(controller, "bank", "0");
    
    // !rcon sm plugins reload l4d2_ac130

    if(DispatchSpawn(controller))
    {
        SetEntPropEnt(controller, Prop_Send, "m_hOwnerEntity", client);
        ActivateEntity(controller);
        TeleportEntity(controller, startPos);
    }
    else
    {
        DeleteEntity(startEntity);
        DeleteEntity(endEntity);
        DeleteEntity(controller);
        return -1;
    }

    return controller;
}


void DeleteTrackTrain(int train)
{
    // Format(name, 64, "Controller-%d-%d-%d-%d", controller, client, startEntity, endEntity);
    char name[64]
    GetEntPropString(train, Prop_Data, "m_iName", name, 64);
    char combinedName[16][5];
    ExplodeString(name, "-", combinedName, 80, 5);

    for(int i = 3; i < 5; i++)
    {
        int entity = StringToInt(combinedName[i]);
        DeleteEntity(entity);
    }
    DeleteEntity(StringToInt(combinedName[1]));
}

stock void SetClientTransparent(int client, int opacity = 0)
{
    SetEntityRenderMode(client, RENDER_TRANSCOLOR);
    SetEntityRenderColor(client, 255, 255, 255, opacity);
}

stock void SetClientRenderNormal(int client)
{
    SetEntityRenderMode(client, RENDER_NORMAL);
    SetEntityRenderColor(client, 255, 255, 255, 255);
}

stock void SetEntityTransparent(int entity, int opacity = 0)
{
    SetEntityRenderFx(entity, RENDERFX_HOLOGRAM);
    SetEntityRenderColor(entity, 255, 255, 255, opacity);
}

stock void SetEntityRenderNormal(int entity)
{
    SetEntityRenderFx(entity, RENDERFX_NONE);
    SetEntityRenderColor(entity, 255, 255, 255, 255);
}

stock bool RayGetAimPosition(int client, float hitPoint[3]) 
{
    float vAngles[3];
    float fOrigin[3];
    GetClientEyePosition(client, fOrigin);
    GetClientEyeAngles(client, vAngles);

    Handle trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

    if(TR_DidHit(trace)) 
    {
        TR_GetEndPosition(hitPoint, trace);
        CloseHandle(trace);
        return true;
    }
    CloseHandle(trace);
    return false;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask) 
{
    return !IsSurvivor(entity);
} 

stock void KillTimerSafety(Handle& timer)
{
    if(timer != null)
    {
        delete timer;
    }
    timer = null;
}

stock void CheatCommand(int client, char[] command, char[] arguments)
{
    if (!IsClientInGame(client))
    {
        return;
    }
    
    int admindata = GetUserFlagBits(client);
    SetUserFlagBits(client, ADMFLAG_ROOT);
    int flags = GetCommandFlags(command);
    SetCommandFlags(command, flags & ~FCVAR_CHEAT);
    FakeClientCommand(client, "%s %s", command, arguments);
    SetCommandFlags(command, flags);
    SetUserFlagBits(client, admindata);
}

stock void Revive(int client)
{
    // Try to Kill Infected Controller
    int infected = L4D2_GetInfectedAttacker(client);
    if(infected != -1)
    {
        ForcePlayerSuicide(infected);
    }
    CheatCommand(client, "give", " health");
}