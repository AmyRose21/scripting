#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

#define PLUGIN_VERSION "2.6-Fixed"
#define ARRAY_SIZE 2048
#define ENTITY_SAFE_LIMIT 2000
#define EXPLODE_INTERVAL 6.0

#define MODEL_GASCAN                "models/props_junk/gascan001a.mdl"

static const char FIRE_PARTICLE[] =         "gas_explosion_ground_fire";
static const char EXPLOSION_PARTICLE[] =    "weapon_pipebomb";
static const char EXPLOSION_PARTICLE2[] =   "weapon_grenade_explosion";
static const char EXPLOSION_PARTICLE3[] =   "explosion_huge_b";
static const char DAMAGE_WHITE_SMOKE[] =    "minigun_overheat_smoke";
static const char DAMAGE_BLACK_SMOKE[] =    "smoke_burning_engine_01";
static const char DAMAGE_FIRE_SMALL[] =     "burning_engine_01";
static const char DAMAGE_FIRE_HUGE[] =      "fire_window_hotel2";
static const char EXPLOSION_SOUND[] =       "ambient/explosions/explode_1.wav";
static const char EXPLOSION_SOUND2[] =      "ambient/explosions/explode_2.wav";
static const char EXPLOSION_SOUND3[] =      "ambient/explosions/explode_3.wav";
static const char FIRE_SOUND[] =            "ambient/fire/fire_med_loop1.wav";

bool g_bConfigLoaded;
bool g_bL4D2Version;

// Entity Data Arrays
bool g_bLowWreck[ARRAY_SIZE+1];
bool g_bMidWreck[ARRAY_SIZE+1];
bool g_bHighWreck[ARRAY_SIZE+1];
bool g_bCritWreck[ARRAY_SIZE+1];
bool g_bExploded[ARRAY_SIZE+1];
bool g_bHooked[ARRAY_SIZE+1];
int g_iEntityDamage[ARRAY_SIZE+1];
int g_iParticle[ARRAY_SIZE+1] = {-1};

// Global Logic
bool g_bDisabled = false;
int g_iPlayerSpawn, g_iRoundStart;
float g_GameExplodeTime;
char g_sUnloadMap[512];

// ConVars and Cache
ConVar g_cvarMaxHealth, g_cvarRadius, g_cvarPower, g_cvarDamage,
    g_cvarPanicEnable, g_cvarPanicChance, g_cvarInfected, g_cvarTankDamage, 
    g_cvarRemoveCarTime, g_cvarUnloadMap,
    g_cvarExplosionDmg, g_cvarCarHealthState, g_cvarCarMethod;

int g_iMaxHealth, g_iPanicChance, g_iDamage, g_iCarMethod;
float g_fRadius, g_fPower, g_fTankDamage, g_fRemoveCarTime;
bool g_bPanicEnable, g_bInfected, g_bExplosionDmg, g_bCarHealthState;

public Plugin myinfo = 
{
    name = "[L4D1/2] Explosive Cars",
    author = "honorcode23, Fixed: kochiurun119, HarryPotter, Optimized by Assistant",
    description = "Cars explode after they take some damage",
    version = PLUGIN_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?t=138644"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
    EngineVersion test = GetEngineVersion();

    if( test == Engine_Left4Dead )
    {
        g_bL4D2Version = false;
    }
    else if( test == Engine_Left4Dead2 )
    {
        g_bL4D2Version = true;
    }
    else
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success; 
}

public void OnPluginStart()
{
    g_cvarMaxHealth         = CreateConVar("l4d_explosive_cars_health",             "5000", "Maximum health of the cars", FCVAR_NOTIFY, true, 0.0);
    g_cvarRadius            = CreateConVar("l4d_explosive_cars_radius",             "420",  "Maximum radius of the explosion", FCVAR_NOTIFY, true, 0.0);
    g_cvarPower             = CreateConVar("l4d_explosive_cars_power",              "300",  "(L4D2 only) Power of the explosion when the car explodes", FCVAR_NOTIFY, true, 0.0);
    g_cvarDamage            = CreateConVar("l4d_explosive_cars_damage",             "10",   "Damage made by the explosion", FCVAR_NOTIFY, true, 0.0);
    g_cvarPanicEnable       = CreateConVar("l4d_explosive_cars_panic",              "1",    "Should the car explosion cause a panic event? (1: Yes 0: No)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvarPanicChance       = CreateConVar("l4d_explosive_cars_panic_chance",       "5",    "Chance that the cars explosion might call a horde (1 / CVAR) [1: Always]", FCVAR_NOTIFY, true, 1.0);
    g_cvarInfected          = CreateConVar("l4d_explosive_cars_infected",           "1",    "Should infected trigger the car explosion? (1: Yes 0: No)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvarTankDamage        = CreateConVar("l4d_explosive_cars_tank",               "0",    "How much damage do the tank deal to the cars? (0: Default, which is 999 from the engine)", FCVAR_NOTIFY, true, 0.0);
    g_cvarRemoveCarTime     = CreateConVar("l4d_explosive_cars_removetime",         "60",   "Time to wait before removing the exploded car in case it blockes the way. (0: Don't remove)", FCVAR_NOTIFY, true);
    g_cvarUnloadMap         = CreateConVar("l4d_explosive_cars_unload_map",         "",     "On which maps should the plugin disable itself? separate by commas (no spaces). (Example: c5m3_cemetery,c5m5_bridge)", FCVAR_NOTIFY);
    g_cvarExplosionDmg      = CreateConVar("l4d_explosive_cars_explosion_damage",   "1",    "If 1, cars get damaged by another car's explosion", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvarCarHealthState    = CreateConVar("l4d_explosive_cars_health_outline",     "1",    "(L4D2) If 1, Display outline glow of car's health", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvarCarMethod         = CreateConVar("l4d_explosive_cars_flying_method",      "0",    "(L4D2) Which method to send survivor flying by car.\n0=Flings a player to the ground, like they were hit by a Charger\n1=Stagger player", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    
    CreateConVar("l4d_explosive_cars_version", PLUGIN_VERSION, "Version of the l4d Explosive Cars plugin", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    AutoExecConfig(true, "l4d_explosive_cars");

    GetCvars();
    g_cvarMaxHealth.AddChangeHook(ConVarChanged_Cvars);
    g_cvarRadius.AddChangeHook(ConVarChanged_Cvars);
    g_cvarPower.AddChangeHook(ConVarChanged_Cvars);
    g_cvarDamage.AddChangeHook(ConVarChanged_Cvars);
    g_cvarPanicEnable.AddChangeHook(ConVarChanged_Cvars);
    g_cvarPanicChance.AddChangeHook(ConVarChanged_Cvars);
    g_cvarInfected.AddChangeHook(ConVarChanged_Cvars);
    g_cvarTankDamage.AddChangeHook(ConVarChanged_Cvars);
    g_cvarRemoveCarTime.AddChangeHook(ConVarChanged_Cvars);
    g_cvarUnloadMap.AddChangeHook(ConVarChanged_Cvars);
    g_cvarExplosionDmg.AddChangeHook(ConVarChanged_Cvars);
    g_cvarCarHealthState.AddChangeHook(ConVarChanged_Cvars);
    g_cvarCarMethod.AddChangeHook(ConVarChanged_Cvars);

    //Events
    HookEvent("player_spawn",       Event_PlayerSpawn,  EventHookMode_PostNoCopy);
    HookEvent("round_start",        Event_RoundStart,   EventHookMode_PostNoCopy);
    HookEvent("round_end",          Event_RoundEnd,     EventHookMode_PostNoCopy);
}

public void OnPluginEnd()
{
    ResetPlugin();
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
    GetCvars();
}

void GetCvars()
{
    g_iMaxHealth = g_cvarMaxHealth.IntValue;
    g_fRadius = g_cvarRadius.FloatValue;
    g_fPower = g_cvarPower.FloatValue;
    g_iDamage = g_cvarDamage.IntValue;
    g_bPanicEnable = g_cvarPanicEnable.BoolValue;
    g_iPanicChance = g_cvarPanicChance.IntValue;
    g_bInfected = g_cvarInfected.BoolValue;
    g_fTankDamage = g_cvarTankDamage.FloatValue;
    g_fRemoveCarTime = g_cvarRemoveCarTime.FloatValue;
    g_cvarUnloadMap.GetString(g_sUnloadMap, sizeof(g_sUnloadMap));
    g_bExplosionDmg = g_cvarExplosionDmg.BoolValue;
    g_bCarHealthState = g_cvarCarHealthState.BoolValue;
    g_iCarMethod = g_cvarCarMethod.IntValue;
}

public void OnConfigsExecuted()
{
    GetCvars();

    g_bConfigLoaded = true;
    g_bDisabled = false;

    char sCurrentMap[64];
    GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));
    
    if(StrContains(g_sUnloadMap, sCurrentMap) >= 0 && g_sUnloadMap[0] != '\0')
    {
        g_bDisabled = true;
    }

    if(!g_bDisabled)
    {
        if(g_bL4D2Version)
        {
            PrecacheParticle(EXPLOSION_PARTICLE2);
            PrecacheParticle(DAMAGE_FIRE_SMALL);
            PrecacheParticle(DAMAGE_FIRE_HUGE);
        }

        PrecacheParticle(FIRE_PARTICLE);
        PrecacheParticle(DAMAGE_BLACK_SMOKE);
        PrecacheParticle(EXPLOSION_PARTICLE);
        PrecacheParticle(EXPLOSION_PARTICLE3);
        PrecacheParticle(DAMAGE_WHITE_SMOKE);
        PrecacheModel("sprites/muzzleflash4.vmt");
        PrecacheModel("models/props_vehicles/cara_82hatchback_wrecked.mdl");
        PrecacheModel("models/props_vehicles/cara_95sedan_wrecked.mdl");

        PrecacheSound(FIRE_SOUND);
        PrecacheSound(EXPLOSION_SOUND);
        PrecacheSound(EXPLOSION_SOUND2);
        PrecacheSound(EXPLOSION_SOUND3);
    }
}

public void OnMapStart()
{
    PrecacheModel(MODEL_GASCAN, true);
}

public void OnMapEnd()
{
    ResetPlugin();
    g_bConfigLoaded = false;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    ResetPlugin();
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    g_GameExplodeTime = 0.0;

    if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
        CreateTimer(0.5, TimerStart, _, TIMER_FLAG_NO_MAPCHANGE);
    g_iRoundStart = 1;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
        CreateTimer(0.5, TimerStart, _, TIMER_FLAG_NO_MAPCHANGE);
    g_iPlayerSpawn = 1;
}

Action TimerStart(Handle timer)
{
    ResetPlugin();

    if(g_bDisabled) return Plugin_Continue;

    FindMapCars();

    return Plugin_Continue;
}

void FindMapCars()
{
    // Reset data
    for(int i = 1; i <= ARRAY_SIZE; i++)
    {
        ResetEntityData(i);
    }

    int maxEnts = GetMaxEntities();
    char classname[64], model[256];

    for (int entity = MaxClients + 1; entity <= maxEnts; entity++)
    {
        if (!IsValidEntity(entity)) continue;
        
        GetEntityClassname(entity, classname, sizeof(classname));

        if(strncmp(classname, "prop_physics", 12) == 0)
        {
            GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
            
            // Skip utility carts
            if(strcmp(model, "models/props_vehicles/airport_baggage_cart2.mdl", false) == 0) continue;
            if(strcmp(model, "models/props_vehicles/generatortrailer01.mdl", false) == 0) continue;

            if(IsTankProp(entity, model))
            {
                HookCar(entity);
            }
        }
        else if(strcmp(classname, "prop_car_alarm") == 0)
        {
            HookCar(entity);
        }
    }
}

public void OnEntityDestroyed(int entity)
{
    if(entity > 0 && entity <= ARRAY_SIZE)
    {
        ResetEntityData(entity);
    }
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if(g_bDisabled || !g_bConfigLoaded) return;
    if(entity <= 0 || entity > ARRAY_SIZE) return;

    // Use NextFrame to ensure props are fully loaded (model name, etc.)
    RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
}

void OnNextFrame(int entityRef)
{
    if(g_bDisabled) return;

    int entity = EntRefToEntIndex(entityRef);
    if (entity == INVALID_ENT_REFERENCE) return;
    if (g_bHooked[entity]) return;

    char classname[64];
    GetEntityClassname(entity, classname, sizeof(classname));

    if(strncmp(classname, "prop_physics", 12) == 0)
    {
        char model[256];
        GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
        
        if(IsTankProp(entity, model))
        {
            HookCar(entity);
        }
    }
    else if(strcmp(classname, "prop_car_alarm") == 0)
    {
        HookCar(entity);
    }
}

void HookCar(int entity)
{
    if(g_bHooked[entity]) return;

    g_bHooked[entity] = true;
    ResetEntityData(entity); // Ensure clean state
    g_bHooked[entity] = true; // Re-set true as Reset clears it
    SDKHook(entity, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}

void ResetEntityData(int entity)
{
    g_iEntityDamage[entity] = 0;
    g_bLowWreck[entity] = false;
    g_bMidWreck[entity] = false;
    g_bHighWreck[entity] = false;
    g_bCritWreck[entity] = false;
    g_bExploded[entity] = false;
    g_bHooked[entity] = false;
    g_iParticle[entity] = -1;
}

// Fixed Logic for detecting hittable cars in L4D1 and L4D2
bool IsTankProp(int entity, const char[] model)
{
    if (!IsValidEntity(entity)) return false;

    // L4D2 Method: Check for Glow property set by Director/Map
    if (g_bL4D2Version)
    {
        if (HasEntProp(entity, Prop_Send, "m_hasTankGlow")) 
        {
            if (GetEntProp(entity, Prop_Send, "m_hasTankGlow", 1) == 1)
                return true;
        }
    }

    // Fallback / L4D1 Method: Check model name
    if (StrContains(model, "vehicle", false) != -1 || 
        StrContains(model, "cars", false) != -1 || 
        StrContains(model, "taxi", false) != -1 ||
        StrContains(model, "police", false) != -1)
    {
        return true;
    }

    if (strcmp(model, "models/props/cs_assault/forklift.mdl", false) == 0)
    {
        return true;
    }

    return false;
}

void OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
    if(g_bDisabled) return;

    if(victim <= 0 || victim > ARRAY_SIZE) return;

    // Validate attacker and inflictor logic
    char inflictorClass[64] = "";
    char attackerClass[64] = "";

    if(IsValidEntity(inflictor)) GetEntityClassname(inflictor, inflictorClass, sizeof(inflictorClass));
    if(IsValidEntity(attacker)) GetEntityClassname(attacker, attackerClass, sizeof(attackerClass));

    int MaxDamageHandle = g_iMaxHealth / 5;

    // --- Damage Modifications ---
    if(strcmp(attackerClass, "player") == 0)
    {
        if(g_bL4D2Version && (strcmp(inflictorClass, "weapon_chainsaw") == 0 || strcmp(inflictorClass, "weapon_melee") == 0))
        {
            damage = 5.0;
        }
        else if(strcmp(inflictorClass, "tank_rock") == 0 || strcmp(inflictorClass, "weapon_tank_claw") == 0)
        {
            if(g_fTankDamage > 0.0) damage = g_fTankDamage;
        }
        
        // Prevent infected from damaging cars if CVar is set
        if(attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == 3 && !g_bInfected)
        {
            damage = 0.0;
        }
    }
    
    // Explosion damage from other cars
    if(strcmp(inflictorClass, "env_explosion") == 0 || strcmp(inflictorClass, "env_physexplosion") == 0)
    {
        if(!g_bExplosionDmg) damage = 0.0;
        else damage = 3000.0;
    }
    // Pipe bombs and Grenade Launchers
    else if (strcmp(inflictorClass, "pipe_bomb_projectile") == 0 || (g_bL4D2Version && strcmp(inflictorClass, "grenade_launcher_projectile") == 0))
    {
        damage = 3000.0;
    }
    // Fire damage
    else if (strcmp(inflictorClass, "inferno") == 0 || (g_bL4D2Version && strcmp(inflictorClass, "fire_cracker_blast") == 0))
    {
        damage = 100.0;
    }

    if(damage <= 0.0) return;

    g_iEntityDamage[victim] += RoundToFloor(damage);
    int tdamage = g_iEntityDamage[victim];

    // --- Damage Stages ---
    if(tdamage >= MaxDamageHandle && tdamage < MaxDamageHandle * 2 && !g_bLowWreck[victim])
    {
        UpdateCarGlow(victim, 65535, 0); // Cyan/White
        AttachParticle(victim, DAMAGE_WHITE_SMOKE);
        g_bLowWreck[victim] = true;
    }
    else if(tdamage >= MaxDamageHandle * 2 && tdamage < MaxDamageHandle * 3 && !g_bMidWreck[victim])
    {
        UpdateCarGlow(victim, 13260, 0); // Orange
        AttachParticle(victim, DAMAGE_BLACK_SMOKE);
        g_bMidWreck[victim] = true;
    }
    else if(tdamage >= MaxDamageHandle * 3 && tdamage < MaxDamageHandle * 4 && !g_bHighWreck[victim])
    {
        UpdateCarGlow(victim, 225, 0); // Red
        EmitSoundToAll(FIRE_SOUND, victim);
        if(g_bL4D2Version) AttachParticle(victim, DAMAGE_FIRE_SMALL);
        g_bHighWreck[victim] = true;
    }
    else if(tdamage >= MaxDamageHandle * 4 && tdamage < MaxDamageHandle * 5 && !g_bCritWreck[victim])
    {
        UpdateCarGlow(victim, 255, 1); // Red Flashing
        if(g_bL4D2Version) AttachParticle(victim, DAMAGE_FIRE_HUGE);
        g_bCritWreck[victim] = true;
    }
    else if(tdamage > MaxDamageHandle * 5 && !g_bExploded[victim])
    {
        UpdateCarGlow(victim, 255, 1);
        if(!g_bCritWreck[victim])
        {
            EmitSoundToAll(FIRE_SOUND, victim);
            if(g_bL4D2Version) AttachParticle(victim, DAMAGE_FIRE_HUGE);
            g_bCritWreck[victim] = true;
        }

        CreateTimer(GetRandomInt(0, 100) * 0.0001, Timer_ExplodeCar, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
    }
}

void UpdateCarGlow(int entity, int color, int flashing)
{
    if(!g_bL4D2Version || !g_bCarHealthState) return;
    
    SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
    SetEntProp(entity, Prop_Send, "m_glowColorOverride", color);
    SetEntProp(entity, Prop_Send, "m_nGlowRange", 500);
    SetEntProp(entity, Prop_Send, "m_bFlashing", flashing);
}

Action Timer_ExplodeCar(Handle timer, any entityRef)
{
    if(g_bDisabled) return Plugin_Continue;

    int car = EntRefToEntIndex(entityRef);
    if (car == INVALID_ENT_REFERENCE) return Plugin_Continue;

    if(g_bL4D2Version)
    {
        SetEntProp(car, Prop_Send, "m_iGlowType", 0);
        SetEntProp(car, Prop_Send, "m_bFlashing", 0);
    }

    if(g_GameExplodeTime < GetEngineTime())
    {
        g_bExploded[car] = true;
        float carPos[3];
        GetEntPropVector(car, Prop_Data, "m_vecOrigin", carPos);
        
        CreateExplosion(car, carPos);
        EditCar(car);
        LaunchCar(car);

        SDKUnhook(car, SDKHook_OnTakeDamagePost, OnTakeDamagePost);

        g_GameExplodeTime = GetEngineTime() + EXPLODE_INTERVAL;
    }

    return Plugin_Continue;
}

void EditCar(int car)
{
    SetEntityRenderColor(car, 51, 51, 51, 255);
    char sModel[256];
    GetEntPropString(car, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
    ReplaceStringEx(sModel, sizeof(sModel), ".mdl", "");
    Format(sModel, sizeof(sModel), "%s_wrecked.mdl", sModel);
    
    if(FileExists(sModel, true))
    {
        if(!IsModelPrecached(sModel)) PrecacheModel(sModel);
        SetEntityModel(car, sModel);
    }
}

void LaunchCar(int car)
{
    float vel[3];
    GetEntPropVector(car, Prop_Data, "m_vecVelocity", vel);
    vel[0] += GetRandomFloat(50.0, 300.0);
    vel[1] += GetRandomFloat(50.0, 300.0);
    vel[2] += GetRandomFloat(600.0, 1500.0); // Reduced vertical launch slightly for realism
    
    TeleportEntity(car, NULL_VECTOR, NULL_VECTOR, vel);
    CreateTimer(4.0, timerNormalVelocity, EntIndexToEntRef(car), TIMER_FLAG_NO_MAPCHANGE);
    
    if(g_fRemoveCarTime > 0.0)
    {
        CreateTimer(g_fRemoveCarTime, timerRemoveCarFire, EntIndexToEntRef(car), TIMER_FLAG_NO_MAPCHANGE);
    }
}

Action timerNormalVelocity(Handle timer, any entityRef)
{
    if(g_bDisabled) return Plugin_Continue;

    int car = EntRefToEntIndex(entityRef);
    if (car != INVALID_ENT_REFERENCE && IsValidEntity(car))
    {
        float vel[3];
        SetEntPropVector(car, Prop_Data, "m_vecVelocity", vel); // Keeps current velocity but effectively stops boosting
        TeleportEntity(car, NULL_VECTOR, NULL_VECTOR, vel);
    }

    return Plugin_Continue;
}

Action timerRemoveCarFire(Handle timer, int ref)
{
    if(g_bDisabled) return Plugin_Continue;

    int car = EntRefToEntIndex(ref);
    if(car != INVALID_ENT_REFERENCE)
    {
        int p = g_iParticle[car];
        if( IsValidEntRef(p) )
        {
            AcceptEntityInput(p, "Kill");
        }
        g_iParticle[car] = -1;
        AcceptEntityInput(car, "Kill");
    }

    return Plugin_Continue;
}

void CreateExplosion(int car, float carPos[3])
{
    char sRadius[16], sPower[16], sDamage[11];
    IntToString(RoundFloat(g_fRadius), sRadius, sizeof(sRadius));
    IntToString(RoundFloat(g_fPower), sPower, sizeof(sPower));
    IntToString(g_iDamage, sDamage, sizeof(sDamage));

    SpawnParticle(EXPLOSION_PARTICLE, carPos);
    
    if(g_bL4D2Version)
    {
        SpawnParticle(EXPLOSION_PARTICLE2, carPos);
    }

    SpawnParticle(EXPLOSION_PARTICLE3, carPos);

    // Temp fire trace
    int exTrace = CreateEntityByName("info_particle_system");
    if(CheckIfEntitySafe(exTrace))
    {
        DispatchKeyValue(exTrace, "effect_name", FIRE_PARTICLE);
        DispatchSpawn(exTrace);
        ActivateEntity(exTrace);
        TeleportEntity(exTrace, carPos, NULL_VECTOR, NULL_VECTOR);
        AcceptEntityInput(exTrace, "Start");
        CreateTimer(1.5, timerStop, EntIndexToEntRef(exTrace), TIMER_FLAG_NO_MAPCHANGE);
    }

    // Main Explosion
    int exEntity = CreateEntityByName("env_explosion");
    if(CheckIfEntitySafe(exEntity))
    {
        DispatchKeyValue(exEntity, "fireballsprite", "sprites/muzzleflash4.vmt");
        DispatchKeyValueInt(exEntity, "iMagnitude", g_iDamage);
        DispatchKeyValueInt(exEntity, "iRadiusOverride", RoundFloat(g_fRadius));
        DispatchKeyValue(exEntity, "spawnflags", "828"); // No Sound (we play custom), No Debris, No Smoke
        DispatchSpawn(exEntity);
        TeleportEntity(exEntity, carPos, NULL_VECTOR, NULL_VECTOR);
        AcceptEntityInput(exEntity, "Explode");
        CreateTimer(1.5, timerDeleteParticles, EntIndexToEntRef(exEntity), TIMER_FLAG_NO_MAPCHANGE);
    }

    // Physics Force
    int exPhys = CreateEntityByName("env_physexplosion");
    if(CheckIfEntitySafe(exPhys))
    {
        DispatchKeyValue(exPhys, "radius", sRadius);
        DispatchKeyValue(exPhys, "magnitude", sPower);
        DispatchSpawn(exPhys);
        TeleportEntity(exPhys, carPos, NULL_VECTOR, NULL_VECTOR);
        AcceptEntityInput(exPhys, "Explode");
        CreateTimer(1.5, timerDeleteParticles, EntIndexToEntRef(exPhys), TIMER_FLAG_NO_MAPCHANGE);
    }

    CreateFireOnGround(car, carPos);

    int randSound = GetRandomInt(1, 3);
    if(randSound == 1) EmitSoundToAll(EXPLOSION_SOUND);
    else if(randSound == 2) EmitSoundToAll(EXPLOSION_SOUND2);
    else EmitSoundToAll(EXPLOSION_SOUND3);
    
    if(g_bPanicEnable)
    {
        if(GetRandomInt(1, g_iPanicChance) == 1)
        {
            PanicEvent();
            PrintToChatAll("\x04[ExplosiveCars] \x03The explosion attracted the horde!");
        }
    }
    
    // Fling Survivors
    float survivorPos[3], traceVec[3], resultingFling[3], currentVelVec[3];
    for(int player = 1; player <= MaxClients; player++)
    {
        if(!IsClientInGame(player) || !IsPlayerAlive(player) || GetClientTeam(player) != 2) continue;

        GetEntPropVector(player, Prop_Data, "m_vecOrigin", survivorPos);

        if(GetVectorDistance(carPos, survivorPos) <= g_fRadius)
        {
            if(g_bL4D2Version && g_iCarMethod == 0)
            {
                MakeVectorFromPoints(carPos, survivorPos, traceVec);
                GetVectorAngles(traceVec, resultingFling);

                resultingFling[0] = Cosine(DegToRad(resultingFling[1])) * g_fPower;
                resultingFling[1] = Sine(DegToRad(resultingFling[1])) * g_fPower;
                resultingFling[2] = g_fPower;

                GetEntPropVector(player, Prop_Data, "m_vecVelocity", currentVelVec);
                AddVectors(resultingFling, currentVelVec, resultingFling);

                L4D2_CTerrorPlayer_Fling(player, player, resultingFling);
            }
            else
            {
                L4D_StaggerPlayer(player, player, carPos);
            }
        }
    }
}

void SpawnParticle(const char[] name, float pos[3])
{
    int p = CreateEntityByName("info_particle_system");
    if(CheckIfEntitySafe(p))
    {
        DispatchKeyValue(p, "effect_name", name);
        DispatchSpawn(p);
        ActivateEntity(p);
        TeleportEntity(p, pos, NULL_VECTOR, NULL_VECTOR);
        AcceptEntityInput(p, "Start");
        CreateTimer(1.5, timerDeleteParticles, EntIndexToEntRef(p), TIMER_FLAG_NO_MAPCHANGE);
    }
}

Action timerStop(Handle timer, int ref)
{
    int entity = EntRefToEntIndex(ref);
    if(entity != INVALID_ENT_REFERENCE)
    {
        AcceptEntityInput(entity, "Stop");
        AcceptEntityInput(entity, "Kill");
    }
    return Plugin_Continue;
}

Action timerDeleteParticles(Handle timer, int ref)
{
    int entity = EntRefToEntIndex(ref);
    if(entity != INVALID_ENT_REFERENCE)
    {
        AcceptEntityInput(entity, "Kill");
    }
    return Plugin_Continue;
}

int PrecacheParticle(const char[] sEffectName)
{
    static int table = INVALID_STRING_TABLE;
    if( table == INVALID_STRING_TABLE )
    {
        table = FindStringTable("ParticleEffectNames");
    }

    if( table == INVALID_STRING_TABLE ) return INVALID_STRING_INDEX;

    int index = FindStringIndex(table, sEffectName);
    if( index == INVALID_STRING_INDEX )
    {
        bool save = LockStringTables(false);
        AddToStringTable(table, sEffectName);
        LockStringTables(save);
        index = FindStringIndex(table, sEffectName);
    }

    return index;
}

void AttachParticle(int car, const char[] Particle_Name)
{
    float carPos[3];
    char sName[64], sTargetName[64];
    
    // Clean old particle
    int entity = g_iParticle[car];
    if( IsValidEntRef(entity) )
    {
        AcceptEntityInput(EntRefToEntIndex(entity), "Kill");
        g_iParticle[car] = -1;
    }

    int Particle = CreateEntityByName("info_particle_system");
    if( CheckIfEntitySafe(Particle) )
    {
        g_iParticle[car] = EntIndexToEntRef(Particle);
        GetEntPropVector(car, Prop_Data, "m_vecOrigin", carPos);
        TeleportEntity(Particle, carPos, NULL_VECTOR, NULL_VECTOR);
        DispatchKeyValue(Particle, "effect_name", Particle_Name);

        Format(sName, sizeof(sName), "car_p_%d", car);
        DispatchKeyValue(car, "targetname", sName);
        
        Format(sTargetName, sizeof(sTargetName), "car_pt_%d", car);
        DispatchKeyValue(Particle, "targetname", sTargetName);
        DispatchKeyValue(Particle, "parentname", sName);
        
        DispatchSpawn(Particle);
        SetVariantString(sName);
        AcceptEntityInput(Particle, "SetParent", Particle, Particle);
        ActivateEntity(Particle);
        AcceptEntityInput(Particle, "Start");
    }
}

void PanicEvent()
{
    L4D_ForcePanicEvent();
}

bool CheckIfEntitySafe(int entity)
{
    if(entity == -1) return false;
    if(entity > ENTITY_SAFE_LIMIT)
    {
        AcceptEntityInput(entity, "Kill");
        return false;
    }
    return true;
}

bool IsValidEntRef(int entRef)
{
    return (entRef != -1 && EntRefToEntIndex(entRef) != INVALID_ENT_REFERENCE);
}

void ResetPlugin()
{
    g_iRoundStart = 0;
    g_iPlayerSpawn = 0;
}

void CreateFireOnGround(int car, float carPos[3])
{
    int entity = CreateEntityByName("prop_physics");
    if( entity != -1 )
    {
        SetEntityModel(entity, MODEL_GASCAN);
        
        // Setup hooks to hide it
        SDKHook(entity, SDKHook_SetTransmit, OnTransmitExplosive);

        int flags = GetEntityFlags(entity);
        SetEntityFlags(entity, flags|FL_EDICT_DONTSEND);

        SetEntityRenderMode(entity, RENDER_TRANSALPHAADD);
        SetEntityRenderColor(entity, 0, 0, 0, 0);

        SetEntProp(entity, Prop_Send, "m_CollisionGroup", 1);
        SetEntityMoveType(entity, MOVETYPE_NONE);

        TeleportEntity(entity, carPos, NULL_VECTOR, NULL_VECTOR);
        DispatchSpawn(entity);

        SetEntPropEnt(entity, Prop_Data, "m_hPhysicsAttacker", car);
        SetEntPropFloat(entity, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());

        AcceptEntityInput(entity, "Break");
    }
}

Action OnTransmitExplosive(int entity, int client)
{
    return Plugin_Handled;
}