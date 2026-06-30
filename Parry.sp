#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks> // Asegúrate de tener left4dhooks.inc en scripting/include

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.4"

// --- ConVars ---
ConVar cv_ParryRadius;
ConVar cv_ParryMinSpeed;
ConVar cv_ParryDamage;
ConVar cv_EnableChargerParry;
ConVar cv_EnableWitchParry;
ConVar cv_ParrySound;

float g_fLastParryTime[MAXPLAYERS+1];

public Plugin myinfo =
{
    name = "[L4D2] Ultrakill Parry (Fix Particle)",
    author = "Converted by AI",
    description = "Parry mechanics with correct PrecacheParticle",
    version = PLUGIN_VERSION,
    url = ""
};

public void OnPluginStart()
{
    cv_ParryRadius = CreateConVar("uk_parry_radius", "200.0", "Radio del parry (Unidades)");
    cv_ParryMinSpeed = CreateConVar("uk_parry_min_velocity", "50.0", "Velocidad mínima");
    cv_ParryDamage = CreateConVar("uk_parry_damage", "100.0", "Daño del parry");
    cv_EnableChargerParry = CreateConVar("uk_parry_charger", "1", "1 = Parry Charger");
    cv_EnableWitchParry = CreateConVar("uk_parry_witch", "1", "1 = Parry Witch");
    cv_ParrySound = CreateConVar("uk_parry_sound", "1", "1 = Sonido activado");

    AutoExecConfig(true, "l4d2_ultrakill_parry");
}

public void OnMapStart()
{
    PrecacheSound("weapons/golf_club/hit_world_01.wav"); 
    PrecacheModel("materials/sprites/physcannon_bluecore1.vmt");
    PrecacheParticle("weapon_grenadelauncher");
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2)
        return Plugin_Continue;

    if (buttons & IN_ATTACK2)
    {
        float gameTime = GetGameTime();
        float nextShove = GetEntPropFloat(client, Prop_Send, "m_flNextShoveTime");

        // Margen de tolerancia para detectar el shove
        if (gameTime >= nextShove - 0.1 && gameTime > g_fLastParryTime[client] + 0.5)
        {
            g_fLastParryTime[client] = gameTime;
            PerformParry(client);
        }
    }
    return Plugin_Continue;
}

void PerformParry(int client)
{
    float pos[3], eyeAng[3], fwd[3];
    GetClientEyePosition(client, pos);
    GetClientEyeAngles(client, eyeAng);
    GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);

    float radius = cv_ParryRadius.FloatValue;

    // Lista de entidades que queremos poder devolver
    char targetClasses[][] = {
        "tank_rock",
        "grenade_launcher_projectile",
        "molotov_projectile",
        "pipe_bomb_projectile",
        "spitter_projectile",
        "vomitjar_projectile"
    };

    bool hitSomething = false;

    // 1. BUSCAR PROYECTILES ESPECÍFICOS
    for (int i = 0; i < sizeof(targetClasses); i++)
    {
        int entity = -1;
        while ((entity = FindEntityByClassname(entity, targetClasses[i])) != -1)
        {
            if (IsValidEntity(entity))
            {
                if (CheckAndParry(client, entity, pos, radius, fwd))
                    hitSomething = true;
            }
        }
    }

    // 2. BUSCAR INFECTADOS / WITCH
    if (!hitSomething)
    {
        CheckEnemies(client, pos, radius, fwd);
    }
}

bool CheckAndParry(int client, int entity, float clientPos[3], float radius, float fwd[3])
{
    float entPos[3];
    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entPos);

    if (GetVectorDistance(clientPos, entPos) <= radius)
    {
        if (IsLookingAt(client, entPos, 0.4)) 
        {
            ParryProjectile(client, entity, fwd);
            return true;
        }
    }
    return false;
}

void ParryProjectile(int client, int entity, float fwd[3])
{
    // Asignar nuevos dueños
    SetEntPropEnt(entity, Prop_Send, "m_hThrower", client);
    SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);

    float velocity[3];
    GetEntPropVector(entity, Prop_Data, "m_vecVelocity", velocity);
    float speed = GetVectorLength(velocity);
    
    if (speed < 1000.0) speed = 1200.0;
    else speed *= 1.5;

    ScaleVector(fwd, speed);
    TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fwd);

    DoParryEffects(client, entity);
}

void CheckEnemies(int client, float pos[3], float radius, float fwd[3])
{
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "player")) != -1)
    {
        if (!IsValidClient(entity) || GetClientTeam(entity) != 3 || !IsPlayerAlive(entity)) continue;
        
        float entPos[3];
        GetClientAbsOrigin(entity, entPos);
        
        if (GetVectorDistance(pos, entPos) <= radius && IsLookingAt(client, entPos, 0.5))
        {
            int zClass = GetEntProp(entity, Prop_Send, "m_zombieClass");
            if (zClass == 6 && cv_EnableChargerParry.BoolValue)
            {
                ParryInfected(client, entity, true);
            }
            else
            {
                ParryInfected(client, entity, false);
            }
        }
    }

    if (cv_EnableWitchParry.BoolValue)
    {
        entity = -1;
        while ((entity = FindEntityByClassname(entity, "witch")) != -1)
        {
            float entPos[3];
            GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entPos);
            if (GetVectorDistance(pos, entPos) <= radius && IsLookingAt(client, entPos, 0.5))
            {
                ParryWitch(client, entity);
            }
        }
    }
}

void ParryInfected(int client, int enemy, bool isCharger)
{
    float damage = cv_ParryDamage.FloatValue;
    float clientPos[3];
    GetClientAbsOrigin(client, clientPos);

    float stop[3] = {0.0, 0.0, 0.0};
    TeleportEntity(enemy, NULL_VECTOR, NULL_VECTOR, stop);

    L4D_StaggerPlayer(enemy, client, clientPos);

    if (isCharger)
    {
        SetEntProp(enemy, Prop_Send, "m_isCharging", 0);
        SetEntProp(enemy, Prop_Send, "m_iAbilityLungeState", 0);
        SetEntPropFloat(enemy, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 2.0);
    }

    SDKHooks_TakeDamage(enemy, client, client, damage, DMG_CLUB);
    DoParryEffects(client, enemy);
}

void ParryWitch(int client, int witch)
{
    float damage = cv_ParryDamage.FloatValue;
    float clientPos[3];
    GetClientAbsOrigin(client, clientPos);
    
    SDKHooks_TakeDamage(witch, client, client, damage, DMG_CLUB);
    
    float witchPos[3], push[3];
    GetEntPropVector(witch, Prop_Send, "m_vecOrigin", witchPos);
    SubtractVectors(witchPos, clientPos, push);
    NormalizeVector(push, push);
    ScaleVector(push, 500.0);
    push[2] += 200.0;
    TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, push);
    
    DoParryEffects(client, witch);
}

void DoParryEffects(int client, int target)
{
    if (cv_ParrySound.BoolValue)
    {
        // Emitir sonido desde el cliente para asegurar que se escuche
        EmitSoundToAll("weapons/golf_club/hit_world_01.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
    }

    float pos[3];
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos);
    pos[2] += 20.0;

    int sprite = CreateEntityByName("env_sprite");
    if (IsValidEntity(sprite))
    {
        DispatchKeyValue(sprite, "model", "materials/sprites/physcannon_bluecore1.vmt");
        DispatchKeyValue(sprite, "scale", "0.25");
        DispatchKeyValue(sprite, "rendermode", "9");
        DispatchKeyValue(sprite, "rendercolor", "100 255 255");
        DispatchKeyValue(sprite, "spawnflags", "1");
        DispatchSpawn(sprite);
        TeleportEntity(sprite, pos, NULL_VECTOR, NULL_VECTOR);
        
        SetVariantString("OnUser1 !self:Kill::0.1:1");
        AcceptEntityInput(sprite, "FireUser1");
    }
}

// Utilidades
bool IsLookingAt(int client, float targetPos[3], float threshold)
{
    float clientPos[3], clientAng[3], fwd[3], toTarget[3];
    GetClientEyePosition(client, clientPos);
    GetClientEyeAngles(client, clientAng);
    GetAngleVectors(clientAng, fwd, NULL_VECTOR, NULL_VECTOR);
    SubtractVectors(targetPos, clientPos, toTarget);
    NormalizeVector(toTarget, toTarget);
    return (GetVectorDotProduct(fwd, toTarget) >= threshold);
}

bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}

// ESTA ES LA FUNCIÓN QUE FALTABA
void PrecacheParticle(const char[] sEffectName)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE) table = FindStringTable("ParticleEffectNames");
    
    if (table != INVALID_STRING_TABLE)
    {
        if (FindStringIndex(table, sEffectName) == INVALID_STRING_INDEX)
        {
            bool save = LockStringTables(false);
            AddToStringTable(table, sEffectName);
            LockStringTables(save);
        }
    }
}