/*
 * ======================================================
 *  [MODULO] Knuckles the Echidna - Power & Defense v57 (Absolute Brick Wall)
 *  
 *  FIX: Detencion nativa del Charger ahora usa un Delay-Timer (0.05s).
 *       Esto fuerza la cancelacion de su habilidad de carga tras el impacto (Evita que pase de largo).
 *  FIX: Fricción absoluta instantánea ancla al Charger en el sitio del impacto.
 * ======================================================
 */

#if defined _Knuckles_included
    #endinput
#endif
#define _Knuckles_included

#if !defined _sourcemod_included
    #include <sourcemod>
#endif
#if !defined _sdktools_included
    #include <sdktools>
#endif
#if !defined _sdkhooks_included
    #include <sdkhooks>
#endif
#if !defined _l4d_stocks_included && !defined _left4dhooks_included
    #tryinclude <left4dhooks>
#endif

#if !defined KNUCKLES_INDEX
    #define KNUCKLES_INDEX 2
#endif

// =======================
// Constantes y Audio
// =======================
#define KNUX_SOUND_CHARGE_1     "player/survivor/hit/crowbar_swing_miss1.wav"
#define KNUX_SOUND_PUNCH        "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_1.wav"
#define KNUX_SOUND_SLAM         "player/tank/hit/hulk_punch_1.wav"
#define KNUX_SOUND_COUNTER      "weapons/knife/knife_deploy.wav"
#define KNUX_SOUND_COUNTER_HIT  "weapons/pan/pan_hit_infected1.wav" 
#define KNUX_SOUND_SMASH_HIT    "player/tank/hit/hulk_punch_2.wav"

#define KNUX_MAX_WALL_CHAINS    3

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif

// =======================
// Variables Globales
// =======================
bool  g_bKnuxGliding[MAXPLAYERS + 1];
bool  g_bKnuxClinging[MAXPLAYERS + 1];
int   g_iKnuxWallChains[MAXPLAYERS + 1];

bool  g_bKnuxCharging[MAXPLAYERS + 1]; 
bool  g_bKnuxSlamming[MAXPLAYERS + 1]; 
float g_fKnuxPunchCooldown[MAXPLAYERS + 1];

bool  g_bKnuxCountering[MAXPLAYERS + 1];
float g_fKnuxCounterEndTime[MAXPLAYERS + 1];
float g_fKnuxCounterCooldown[MAXPLAYERS + 1];
float g_fKnuxDisarmTank[MAXPLAYERS + 1]; 

float g_fKnuxExtendedImmunity[MAXPLAYERS + 1];

// Manejo de fisicas en pared
float g_fKnuxNextClingTime[MAXPLAYERS + 1];
int   g_iKnuxLastButtons[MAXPLAYERS + 1];

// Prevencion de impactos múltiples por un solo Dash
bool  g_bKnuxDashHit[MAXPLAYERS + 1][2048]; 

ConVar g_cvKnuxPunchCD, g_cvKnuxCounterCD;
ConVar g_cvKnuxGlideSpeed, g_cvKnuxGlideGravity;
ConVar g_cvKnuxDamageReduc, g_cvKnuxSlamDmg, g_cvKnuxSlamRadius;
ConVar g_cvKnuxCounterDuration;

#define Knux_IsValidClient(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

public void Knuckles_OnPluginStart()
{
    g_cvKnuxPunchCD         = CreateConVar("knux_punch_cooldown", "15.0", "Cooldown del Puño");
    g_cvKnuxCounterCD       = CreateConVar("knux_counter_cooldown", "20.0", "Cooldown del Counter");
    g_cvKnuxCounterDuration = CreateConVar("knux_counter_duration", "8.0", "Duracion de la Postura Defensiva");
    
    g_cvKnuxGlideSpeed    = CreateConVar("knux_glide_speed", "450.0", "Velocidad horizontal al planear");
    g_cvKnuxGlideGravity  = CreateConVar("knux_glide_gravity", "0.4", "Gravedad al planear");
    g_cvKnuxDamageReduc   = CreateConVar("knux_damage_reduction", "0.25", "Daño recibido al cargar");
    
    g_cvKnuxSlamDmg       = CreateConVar("knux_slam_damage", "500.0", "Daño del Ground Smash (+75% Buffed)");
    g_cvKnuxSlamRadius    = CreateConVar("knux_slam_radius", "450.0", "Radio del Ground Smash");

    RegConsoleCmd("sm_knux_punch", Command_KnuxPunch);
    RegConsoleCmd("sm_knux_counter", Command_KnuxCounter);

    HookEvent("player_spawn", Knux_Event_PlayerSpawn);
    HookEvent("player_death", Knux_Event_PlayerDeath);
    HookEvent("round_end", Knux_Event_RoundEnd);
    
    AutoExecConfig(true, "Knuckles_Abilities");

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i)) {
            Knux_ResetState(i);
            SDKUnhook(i, SDKHook_OnTakeDamage, Knux_OnTakeDamage);
            SDKHook(i, SDKHook_OnTakeDamage, Knux_OnTakeDamage);
            SDKUnhook(i, SDKHook_PreThink, Knux_PreThink);
            SDKHook(i, SDKHook_PreThink, Knux_PreThink);
            SDKUnhook(i, SDKHook_Touch, Knux_OnTouch);
            SDKHook(i, SDKHook_Touch, Knux_OnTouch);
        }
    }
}

public void Knuckles_OnMapStart()
{
    PrecacheSound(KNUX_SOUND_CHARGE_1, true);
    PrecacheSound(KNUX_SOUND_PUNCH, true);
    PrecacheSound(KNUX_SOUND_SLAM, true);
    PrecacheSound(KNUX_SOUND_COUNTER, true);
    PrecacheSound(KNUX_SOUND_COUNTER_HIT, true);
    PrecacheSound(KNUX_SOUND_SMASH_HIT, true);
    PrecacheParticle("gas_explosion_main"); 
    
    for (int i = 1; i <= MaxClients; i++) Knux_ResetState(i);
}

public void Knuckles_OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, Knux_OnTakeDamage);
    SDKHook(client, SDKHook_PreThink, Knux_PreThink);
    SDKHook(client, SDKHook_Touch, Knux_OnTouch);
}

public void Knux_Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && IsClientInGame(client)) {
        Knux_ResetState(client);
        SDKUnhook(client, SDKHook_OnTakeDamage, Knux_OnTakeDamage);
        SDKHook(client, SDKHook_OnTakeDamage, Knux_OnTakeDamage);
    }
}

public void Knux_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) { int client = GetClientOfUserId(event.GetInt("userid")); if (client > 0) Knux_ResetState(client); }
public void Knux_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) { for (int i = 1; i <= MaxClients; i++) Knux_ResetState(i); }

void Knux_ResetState(int client)
{
    g_bKnuxGliding[client] = false;
    g_bKnuxClinging[client] = false;
    g_iKnuxWallChains[client] = 0;
    g_bKnuxCharging[client] = false;
    g_bKnuxSlamming[client] = false;
    g_bKnuxCountering[client] = false;
    g_fKnuxDisarmTank[client] = 0.0;
    g_fKnuxExtendedImmunity[client] = 0.0;
    g_fKnuxNextClingTime[client] = 0.0;
    g_iKnuxLastButtons[client] = 0;
    
    if (IsClientInGame(client)) {
        if (!GetEntProp(client, Prop_Send, "m_isIncapacitated")) SetEntityMoveType(client, MOVETYPE_WALK);
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntityRenderColor(client, 255, 255, 255, 255);
        SetEntityGravity(client, 1.0);
        SetEntProp(client, Prop_Data, "m_takedamage", 2); 
    }
}

// INHABILITAR HABILIDADES DE LOS INFECTADOS ESPECIALES
void Knux_DisableInfectedAbility(int client, float duration)
{
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        int ability = GetEntPropEnt(client, Prop_Send, "m_customAbility");
        if (ability > 0 && IsValidEntity(ability))
        {
            SetEntPropFloat(ability, Prop_Send, "m_timestamp", GetGameTime() + duration);
        }
    }
}

// =======================
// LOGICA DE MOVIMIENTO & PRETHINK
// =======================

public void Knux_PreThink(int client)
{
    if (!Knux_IsValidClient(client)) return;
    
    // Tank Disarm
    if (GetClientTeam(client) == TEAM_INFECTED && GetEntProp(client, Prop_Send, "m_zombieClass") == 8) {
        if (GetEngineTime() < g_fKnuxDisarmTank[client]) {
            int b = GetClientButtons(client);
            if (b & IN_ATTACK) SetEntProp(client, Prop_Data, "m_nButtons", b & ~IN_ATTACK);
        }
        return;
    }
    
    if (g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return; 

    // Safety Checks
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0 || 
        GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0)
    {
        if (g_bKnuxCharging[client] || g_bKnuxSlamming[client] || g_bKnuxClinging[client] || g_bKnuxGliding[client] || g_bKnuxCountering[client]) {
            Knux_ResetState(client);
        }
        return;
    }

    // LOGICA DE TIEMPO DEL COUNTER
    if (g_bKnuxCountering[client])
    {
        if (GetEngineTime() > g_fKnuxCounterEndTime[client]) Knux_StopCounter(client);
    }

    int buttons = GetClientButtons(client);
    int flags = GetEntityFlags(client);
    float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    
    // Resetear al tocar suelo
    if (flags & FL_ONGROUND) {
        if (g_bKnuxGliding[client] || g_bKnuxClinging[client]) SetEntityGravity(client, 1.0);
        g_iKnuxWallChains[client] = 0;
        g_bKnuxGliding[client] = false;
        g_bKnuxClinging[client] = false;
        
        if (!g_bKnuxCharging[client] && !g_bKnuxSlamming[client]) SetEntityMoveType(client, MOVETYPE_WALK);
        
        if (g_bKnuxSlamming[client]) Knux_PerformGroundSlam(client);
    }

    // LOGICA DE CARGA DEL PUÑO
    if (g_bKnuxCharging[client])
    {
        if (buttons & IN_RELOAD) { Knux_ResetState(client); PrintCenterText(client, "❌ Carga Cancelada"); g_iKnuxLastButtons[client] = buttons; return; }
        
        if ((buttons & IN_ATTACK) || (buttons & IN_ATTACK2)) {
            int newButtons = buttons & ~(IN_ATTACK | IN_ATTACK2); 
            SetEntProp(client, Prop_Data, "m_nButtons", newButtons);
            Knux_ReleasePunch(client); 
            g_iKnuxLastButtons[client] = buttons;
            return;
        }
    }

    // FISICAS EN EL AIRE Y PARED
    if (!(flags & FL_ONGROUND))
    {
        // 1. Enganche a la Pared (SOLO SI ESTÁ EN EL AIRE)
        if (!g_bKnuxCharging[client] && !g_bKnuxClinging[client] && !g_bKnuxSlamming[client] && g_iKnuxWallChains[client] < KNUX_MAX_WALL_CHAINS) {
            if (GetEngineTime() > g_fKnuxNextClingTime[client] && Knux_IsNearWall(client)) {
                g_bKnuxClinging[client] = true;
                g_bKnuxGliding[client] = false;
                g_iKnuxWallChains[client]++;
                
                float stop[3] = {0.0, 0.0, 0.0};
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, stop);
                SetEntityMoveType(client, MOVETYPE_NONE); 
                PrintCenterText(client, "🧱 Agarrado (%d/%d)", g_iKnuxWallChains[client], KNUX_MAX_WALL_CHAINS);
            }
        }

        // 2. Salida de la Pared (Responsivo al mantener salto o presionarlo)
        if (g_bKnuxClinging[client]) {
            if (buttons & IN_JUMP) {
                g_bKnuxClinging[client] = false;
                g_fKnuxNextClingTime[client] = GetEngineTime() + 0.5; // Cooldown de pared
                
                SetEntityMoveType(client, MOVETYPE_WALK); 
                float ang[3], fwd[3]; GetClientEyeAngles(client, ang); ang[0] = 0.0; 
                GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
                
                // IMPULSO FUERTE
                ScaleVector(fwd, g_cvKnuxGlideSpeed.FloatValue * 1.2); 
                fwd[2] = 450.0; // Gran empuje hacia arriba
                
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fwd);
                g_bKnuxGliding[client] = true;
                g_iKnuxLastButtons[client] = buttons;
                
                return; // Return inmediato para evitar que el Air Steering anule la velocidad de salto
            }
        }

        // 3. Air Steering (Control Aéreo Activo)
        if (g_bKnuxGliding[client] && !g_bKnuxClinging[client]) 
        {
            SetEntityGravity(client, g_cvKnuxGlideGravity.FloatValue);
            if (vel[2] < -250.0) vel[2] = -250.0; // Velocidad terminal del planeo

            // Direccion basada en la cámara (WASD)
            float fwdAng[3], fwd[3], right[3];
            GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
            GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);

            float accel = 25.0; 
            float maxSpeed = g_cvKnuxGlideSpeed.FloatValue;
            bool apply = false;

            if (buttons & IN_FORWARD)  { vel[0] += fwd[0]*accel; vel[1] += fwd[1]*accel; apply = true; }
            if (buttons & IN_BACK)     { vel[0] -= fwd[0]*accel; vel[1] -= fwd[1]*accel; apply = true; }
            if (buttons & IN_MOVELEFT) { vel[0] -= right[0]*accel; vel[1] -= right[1]*accel; apply = true; }
            if (buttons & IN_MOVERIGHT){ vel[0] += right[0]*accel; vel[1] += right[1]*accel; apply = true; }

            if (apply) {
                float speed2D = SquareRoot(vel[0]*vel[0] + vel[1]*vel[1]);
                if (speed2D > maxSpeed) {
                    vel[0] = (vel[0]/speed2D) * maxSpeed;
                    vel[1] = (vel[1]/speed2D) * maxSpeed;
                }
            }
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        }
        else if (!g_bKnuxClinging[client] && !g_bKnuxSlamming[client]) 
        {
            // Control Aéreo Normal (Pequeña aceleracion extra al saltar normal)
            float fwdAng[3], fwd[3], right[3];
            GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
            GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);
            
            float accel = 12.0; 
            float maxSpeed = 300.0; 
            bool apply = false;
            
            if (buttons & IN_FORWARD)  { vel[0] += fwd[0]*accel; vel[1] += fwd[1]*accel; apply = true; }
            if (buttons & IN_BACK)     { vel[0] -= fwd[0]*accel; vel[1] -= fwd[1]*accel; apply = true; }
            if (buttons & IN_MOVELEFT) { vel[0] -= right[0]*accel; vel[1] -= right[1]*accel; apply = true; }
            if (buttons & IN_MOVERIGHT){ vel[0] += right[0]*accel; vel[1] += right[1]*accel; apply = true; }

            if (apply) {
                float speed2D = SquareRoot(vel[0]*vel[0] + vel[1]*vel[1]);
                if (speed2D > maxSpeed) {
                    vel[0] = (vel[0]/speed2D) * maxSpeed;
                    vel[1] = (vel[1]/speed2D) * maxSpeed;
                }
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
            }
        }
    }
    
    // Spitter Counter
    if (g_bKnuxCountering[client]) Knux_ScanForSpitterProjectile(client);
    
    g_iKnuxLastButtons[client] = buttons;
}

bool Knux_IsNearWall(int client)
{
    float pos[3], ang[3], fwd[3], end[3];
    GetClientEyePosition(client, pos); GetClientEyeAngles(client, ang);
    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(fwd, 40.0); AddVectors(pos, fwd, end);
    float mins[3] = {-16.0, -16.0, -16.0}; float maxs[3] = {16.0, 16.0, 16.0};
    Handle trace = TR_TraceHullFilterEx(pos, end, mins, maxs, MASK_SOLID, Knux_TraceFilter_World, client);
    bool hit = TR_DidHit(trace); delete trace;
    return hit;
}
public bool Knux_TraceFilter_World(int entity, int contentsMask, int data) { return (entity == 0); }

// =======================
// ACTIVA 1: PUNCH / GROUND SLAM
// =======================

public Action Command_KnuxPunch(int client, int args)
{
    if (!Knux_IsValidClient(client) || g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return Plugin_Handled;
    
    if (g_bKnuxCharging[client]) return Plugin_Handled; 
    if (g_bKnuxCountering[client]) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fKnuxPunchCooldown[client]) {
        PrintCenterText(client, "Punch Cooldown: %.1f", g_fKnuxPunchCooldown[client] - now);
        return Plugin_Handled;
    }

    g_bKnuxCharging[client] = true;
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.7); 
    EmitSoundToAll(KNUX_SOUND_CHARGE_1, client);
    
    PrintCenterText(client, "✊ [CLICK] GOLPEAR | [R] CANCELAR");
    return Plugin_Handled;
}

void Knux_ReleasePunch(int client)
{
    g_bKnuxCharging[client] = false;
    g_fKnuxPunchCooldown[client] = GetEngineTime() + g_cvKnuxPunchCD.FloatValue;
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntityMoveType(client, MOVETYPE_WALK);

    if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // AIR SLAM (Caida en picada)
        g_bKnuxSlamming[client] = true;
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[0] = 0.0; vel[1] = 0.0; vel[2] = -1500.0; 
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        PrintCenterText(client, "☄️ METEOR SMASH!");
    }
    else
    {
        // DASH PUNCH (Ataque terrestre)
        float ang[3], fwd[3], pos[3];
        GetClientEyeAngles(client, ang);
        GetClientAbsOrigin(client, pos);
        
        pos[2] += 10.0;
        float dashAng[3]; dashAng[0] = 0.0; dashAng[1] = ang[1]; dashAng[2] = 0.0;
        GetAngleVectors(dashAng, fwd, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(fwd, 1500.0);
        fwd[2] = 200.0; 
        
        TeleportEntity(client, pos, NULL_VECTOR, fwd);
        EmitSoundToAll(KNUX_SOUND_PUNCH, client);
        
        for (int i = 0; i < 2048; i++) g_bKnuxDashHit[client][i] = false;
        
        DataPack pack = new DataPack();
        pack.WriteCell(GetClientUserId(client));
        pack.WriteFloat(GetEngineTime());
        CreateTimer(0.1, T_KnuxSweep, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action T_KnuxSweep(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    float startTime = pack.ReadFloat();
    
    int client = GetClientOfUserId(userid);
    
    // Parada a los 0.5s de empuje
    if (!Knux_IsValidClient(client) || GetEngineTime() - startTime > 0.5)
    {
        return Plugin_Stop;
    }
    
    float pos[3]; GetClientAbsOrigin(client, pos);
    float radius = 160.0;
    
    // Rastro Visual (Anillos)
    pos[2] += 30.0;
    TE_SetupBeamRingPoint(pos, 10.0, radius, PrecacheModel("materials/sprites/laserbeam.vmt"), 0, 0, 0, 0.2, 5.0, 0.0, {255, 50, 0, 255}, 0, 0);
    TE_SendToAll();
    pos[2] -= 30.0;

    // Detectar Jugadores Infectados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            if (!g_bKnuxDashHit[client][i])
            {
                float targetPos[3]; GetClientAbsOrigin(i, targetPos);
                if (GetVectorDistance(pos, targetPos) <= radius)
                {
                    Knux_ApplyPunchHit(client, i);
                    g_bKnuxDashHit[client][i] = true;
                }
            }
        }
    }
    
    // Detectar Comunes y Witches
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity) && !g_bKnuxDashHit[client][entity])
        {
            float targetPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos);
            if (GetVectorDistance(pos, targetPos) <= radius)
            {
                Knux_ApplyPunchHit(client, entity);
                g_bKnuxDashHit[client][entity] = true;
            }
        }
    }
    
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (IsValidEntity(entity) && !g_bKnuxDashHit[client][entity])
        {
            float targetPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos);
            if (GetVectorDistance(pos, targetPos) <= radius)
            {
                Knux_ApplyPunchHit(client, entity);
                g_bKnuxDashHit[client][entity] = true;
            }
        }
    }
    
    return Plugin_Continue;
}

void Knux_ApplyPunchHit(int attacker, int victim)
{
    bool isWitch = false;
    char cls[32];
    
    if (victim > MaxClients) {
        GetEntityClassname(victim, cls, sizeof(cls));
        if (StrEqual(cls, "witch")) isWitch = true;
    }

    if (victim <= MaxClients && IsClientInGame(victim)) {
        float pos[3]; GetClientAbsOrigin(attacker, pos);
        L4D_StaggerPlayer(victim, attacker, pos);
        
        float fling[3]; GetClientEyeAngles(attacker, fling);
        GetAngleVectors(fling, fling, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(fling, 800.0); fling[2] = 300.0;
        L4D2_CTerrorPlayer_Fling(victim, attacker, fling);
        
        SDKHooks_TakeDamage(victim, attacker, attacker, 100.0, DMG_CLUB);
        EmitSoundToAll(KNUX_SOUND_SMASH_HIT, victim);
    } else {
        SDKHooks_TakeDamage(victim, attacker, attacker, 1000.0, DMG_CLUB);
        EmitSoundToAll(KNUX_SOUND_SMASH_HIT, attacker);
        if (isWitch) {
            float push[3]; GetClientEyeAngles(attacker, push);
            GetAngleVectors(push, push, NULL_VECTOR, NULL_VECTOR);
            ScaleVector(push, 800.0); push[2] = 400.0;
            Knux_FlingWitch(victim, push);
        }
    }
}

void Knux_PerformGroundSlam(int client)
{
    g_bKnuxSlamming[client] = false;
    SetEntityMoveType(client, MOVETYPE_WALK);

    EmitSoundToAll(KNUX_SOUND_SLAM, client);
    
    float pos[3]; GetClientAbsOrigin(client, pos);
    float radius = g_cvKnuxSlamRadius.FloatValue;
    float damage = g_cvKnuxSlamDmg.FloatValue; 
    
    TE_SetupBeamRingPoint(pos, 10.0, radius, PrecacheModel("materials/sprites/laserbeam.vmt"), 0, 0, 0, 0.5, 20.0, 0.0, {255, 50, 0, 255}, 0, 0);
    TE_SendToAll();

    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;
        float targetPos[3]; GetClientAbsOrigin(i, targetPos);
        if (GetVectorDistance(pos, targetPos) <= radius) {
            SDKHooks_TakeDamage(i, client, client, damage, DMG_BLAST);
            L4D_StaggerPlayer(i, client, pos); 
            float push[3]; MakeVectorFromPoints(pos, targetPos, push); NormalizeVector(push, push); ScaleVector(push, 600.0); push[2] = 400.0;
            TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
    
    int infected = -1;
    while ((infected = FindEntityByClassname(infected, "infected")) != -1) {
        if (IsValidEntity(infected)) {
            float zPos[3]; GetEntPropVector(infected, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(pos, zPos) <= radius) {
                SDKHooks_TakeDamage(infected, client, client, damage, DMG_BLAST);
            }
        }
    }
    
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1) {
        if (IsValidEntity(witch)) {
            float wPos[3]; GetEntPropVector(witch, Prop_Send, "m_vecOrigin", wPos);
            if (GetVectorDistance(pos, wPos) <= radius) {
                float push[3]; MakeVectorFromPoints(pos, wPos, push); 
                NormalizeVector(push, push); ScaleVector(push, 900.0); push[2] = 400.0;
                Knux_FlingWitch(witch, push);
                SDKHooks_TakeDamage(witch, client, client, damage, DMG_BLAST);
            }
        }
    }
}

void Knux_FlingWitch(int witch, float dir[3])
{
    SetEntityMoveType(witch, MOVETYPE_STEP); 
    TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, dir);
}

// =======================
// ACTIVA 2: COUNTER (PERSISTENTE)
// =======================

public Action Command_KnuxCounter(int client, int args)
{
    if (!Knux_IsValidClient(client) || g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return Plugin_Handled;
    if (g_bKnuxCharging[client]) return Plugin_Handled;

    if (g_bKnuxCountering[client]) {
        Knux_StopCounter(client); 
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fKnuxCounterCooldown[client]) {
        PrintCenterText(client, "Counter Cooldown: %.1f", g_fKnuxCounterCooldown[client] - now);
        return Plugin_Handled;
    }

    g_bKnuxCountering[client] = true;
    g_fKnuxCounterEndTime[client] = now + g_cvKnuxCounterDuration.FloatValue;
    
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.5); 
    EmitSoundToAll(KNUX_SOUND_COUNTER, client);
    SetEntityRenderColor(client, 200, 200, 255, 255); 
    
    PrintCenterText(client, "🛡️ POSTURA DEFENSIVA (%.1fs)", g_cvKnuxCounterDuration.FloatValue);
    
    return Plugin_Handled;
}

void Knux_StopCounter(int client)
{
    g_bKnuxCountering[client] = false;
    if (IsClientInGame(client)) {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0); 
        SetEntityRenderColor(client, 255, 255, 255, 255);
        SetEntProp(client, Prop_Data, "m_takedamage", 2); 
    }
    g_fKnuxCounterCooldown[client] = GetEngineTime() + g_cvKnuxCounterCD.FloatValue;
    PrintCenterText(client, "Postura terminada.");
}

// ===================================================================================
// HOOKS "FAKE SI" (EXTRAÍDOS DE L4D2_PLAY_AS_SI)
// BLOQUEO ABSOLUTO DE AGARRES (SMOKER / CHARGER / FLING / BOOMER)
// ===================================================================================

public Action L4D_OnGrabWithTongue(int victim, int attacker)
{
    if (Knux_IsValidClient(victim) && g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && g_bKnuxCountering[victim])
    {
        Knuckles_HandleSmokerCounter(victim, attacker);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnStartCarryingVictim(int victim, int attacker)
{
    if (Knux_IsValidClient(victim) && g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && g_bKnuxCountering[victim])
    {
        Knuckles_CheckSpecialCounter(victim, attacker);
        return Plugin_Handled; 
    }
    return Plugin_Continue;
}

public Action L4D2_OnSlammedSurvivor(int victim, int attacker, bool &bWallSlam, bool &bDeadlyCharge)
{
    if (Knux_IsValidClient(victim) && g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && g_bKnuxCountering[victim])
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnPlayerFling(int client, int attacker, float vecDir[3])
{
    if (Knux_IsValidClient(client) && g_iPlayerCharIdx[client] == KNUCKLES_INDEX && g_bKnuxCountering[client])
    {
        PrintCenterText(client, "⚓ [COUNTER] ¡INMOVILIDAD!");
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnVomitedUpon(int victim, int &attacker, bool &boomerExplosion)
{
    if (Knux_IsValidClient(victim) && g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && g_bKnuxCountering[victim])
    {
        if (Knux_IsValidClient(attacker))
        {
            EmitSoundToAll(KNUX_SOUND_COUNTER_HIT, victim);
            float duration = 15.0;
            SetEntPropFloat(attacker, Prop_Send, "m_itTimer", GetGameTime() + duration);
            
            float vAttacker[3], vVictim[3], vPush[3];
            GetClientAbsOrigin(attacker, vAttacker); GetClientAbsOrigin(victim, vVictim);
            
            MakeVectorFromPoints(vVictim, vAttacker, vPush);
            NormalizeVector(vPush, vPush);
            ScaleVector(vPush, 800.0); vPush[2] = 300.0;
            
            L4D2_CTerrorPlayer_Fling(attacker, victim, vPush);
            SDKHooks_TakeDamage(attacker, victim, victim, 100.0, DMG_ACID);
            
            PrintCenterText(victim, "🤢 [COUNTER] ¡VÓMITO REFLEJADO!");
            PrintCenterText(attacker, "🤮 ¡TE HAS VOMITADO A TI MISMO!");
            
            Knux_DisableInfectedAbility(attacker, 5.0); // Cooldown forzado
        }
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

// ===================================================================================
// OTROS HOOKS EXISTENTES
// ===================================================================================

public bool Knuckles_IsPhysicsImmune(int client)
{
    if (!Knux_IsValidClient(client) || g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return false;
    if (g_bKnuxCountering[client] || GetEngineTime() < g_fKnuxExtendedImmunity[client]) return true;
    return false;
}

public bool Knuckles_CheckTankCounter(int tank, int player)
{
    if (Knux_IsValidClient(player) && g_bKnuxCountering[player])
    {
        EmitSoundToAll(KNUX_SOUND_COUNTER_HIT, player);
        g_fKnuxDisarmTank[tank] = GetEngineTime() + 5.0; 
        g_fKnuxExtendedImmunity[player] = GetEngineTime() + 3.0;
        
        float zeroVel[3] = {0.0, 0.0, 0.0};
        TeleportEntity(player, NULL_VECTOR, NULL_VECTOR, zeroVel);
        SetEntityMoveType(player, MOVETYPE_NONE);
        
        CreateTimer(0.2, T_RestoreMovement, GetClientUserId(player));
        CreateTimer(0.5, T_RemoveGodMode, GetClientUserId(player));
        SetEntProp(player, Prop_Data, "m_takedamage", 0); 
        
        float push[3]; GetClientEyeAngles(player, push);
        GetAngleVectors(push, push, NULL_VECTOR, NULL_VECTOR); ScaleVector(push, 1000.0); push[2] = 400.0;
        L4D2_CTerrorPlayer_Fling(tank, player, push);
        
        PrintCenterText(player, "🛡️ TANK BLOQUEADO! (3s Inmunidad)");
        return true;
    }
    return false;
}

public Action T_RestoreMovement(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client)) SetEntityMoveType(client, MOVETYPE_WALK);
    return Plugin_Stop;
}

public Action T_RemoveGodMode(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client)) SetEntProp(client, Prop_Data, "m_takedamage", 2); 
    return Plugin_Stop;
}

// DETENCION ABSOLUTA DEL CHARGER Y CAZADORES (CON RETRASO DE 0.05S)
public bool Knuckles_CheckSpecialCounter(int victim, int attacker)
{
    if (Knux_IsValidClient(victim) && g_bKnuxCountering[victim]) {
        if (Knux_IsValidClient(attacker)) {
            EmitSoundToAll(KNUX_SOUND_COUNTER_HIT, victim);
            
            // Friccion absoluta instantánea para evitar que el Charger pase de largo
            float zeroVel[3] = {0.0, 0.0, 0.0};
            float vAtt[3]; GetClientAbsOrigin(attacker, vAtt);
            TeleportEntity(attacker, vAtt, NULL_VECTOR, zeroVel);
            
            // Llamamos al Hard Stop retrasado por 0.05s para que el motor no sobreescriba el stagger
            DataPack pack = new DataPack();
            pack.WriteCell(GetClientUserId(victim));
            pack.WriteCell(GetClientUserId(attacker));
            CreateTimer(0.05, T_KnuxHardStopAttacker, pack, TIMER_FLAG_NO_MAPCHANGE);
            
            PrintCenterText(victim, "⛔ ¡ATAQUE DESTRUIDO EN SECO!");
        }
        return true; 
    }
    return false;
}

public Action T_KnuxHardStopAttacker(Handle timer, DataPack pack)
{
    pack.Reset();
    int victim = GetClientOfUserId(pack.ReadCell());
    int attacker = GetClientOfUserId(pack.ReadCell());
    delete pack;

    if (Knux_IsValidClient(victim) && Knux_IsValidClient(attacker))
    {
        float vPos[3], vAttacker[3], push[3]; 
        GetClientAbsOrigin(victim, vPos); 
        GetClientAbsOrigin(attacker, vAttacker);
        
        MakeVectorFromPoints(vPos, vAttacker, push);
        NormalizeVector(push, push); 
        ScaleVector(push, 800.0); 
        push[2] = 400.0;
        
        // 1. Force the stagger nativo (Detiene la carga del Charger permanentemente)
        L4D_StaggerPlayer(attacker, victim, vPos);
        
        // 2. Fling físico
        L4D2_CTerrorPlayer_Fling(attacker, victim, push);
        
        // 3. Daño
        SDKHooks_TakeDamage(attacker, victim, victim, 200.0, DMG_CLUB);
        
        // 4. Limpieza de punteros forzados (Desvinculación absoluta)
        SetEntPropEnt(victim, Prop_Send, "m_pounceAttacker", -1);
        SetEntPropEnt(victim, Prop_Send, "m_jockeyAttacker", -1);
        SetEntPropEnt(victim, Prop_Send, "m_carryAttacker", -1);
        SetEntPropEnt(victim, Prop_Send, "m_pummelAttacker", -1);
        
        // 5. Cooldown forzado
        Knux_DisableInfectedAbility(attacker, 5.0);
    }
    return Plugin_Stop;
}

// Smoker Counter Inmunidad Pura (CON RETRASO DE 0.05S)
public bool Knuckles_HandleSmokerCounter(int victim, int smoker)
{
    if (Knux_IsValidClient(victim) && g_bKnuxCountering[victim]) {
        EmitSoundToAll(KNUX_SOUND_COUNTER_HIT, victim);
        
        if (Knux_IsValidClient(smoker)) {
            DataPack pack = new DataPack();
            pack.WriteCell(GetClientUserId(victim));
            pack.WriteCell(GetClientUserId(smoker));
            CreateTimer(0.05, T_KnuxHardStopSmoker, pack, TIMER_FLAG_NO_MAPCHANGE);
        }
        
        PrintCenterText(victim, "🛡️ ¡INMUNE AL SMOKER!");
        return true; 
    }
    return false;
}

public Action T_KnuxHardStopSmoker(Handle timer, DataPack pack)
{
    pack.Reset();
    int victim = GetClientOfUserId(pack.ReadCell());
    int smoker = GetClientOfUserId(pack.ReadCell());
    delete pack;

    if (Knux_IsValidClient(victim) && Knux_IsValidClient(smoker)) {
        float vPos[3]; GetClientAbsOrigin(victim, vPos);
        L4D_StaggerPlayer(smoker, victim, vPos);
        Knux_DisableInfectedAbility(smoker, 5.0);
    }
    return Plugin_Stop;
}

// Touch Intercept: Backup de Choque para Slam y Counter
public Action Knux_OnTouch(int client, int other)
{
    if (g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return Plugin_Continue;

    // Ground Slam Detonacion Instantanea por chocar
    if (g_bKnuxSlamming[client]) 
    {
        Knux_PerformGroundSlam(client);
        return Plugin_Continue;
    }

    // COUNTER AGRESIVO de Colision (Hunter/Jockey Fallback)
    if (g_bKnuxCountering[client] && other > 0 && other <= MaxClients)
    {
        if (IsClientInGame(other) && GetClientTeam(other) == TEAM_INFECTED)
        {
            int zClass = GetEntProp(other, Prop_Send, "m_zombieClass");
            if (zClass == 6 || ((zClass == 3 || zClass == 5) && !(GetEntityFlags(other) & FL_ONGROUND)))
            {
                Knuckles_CheckSpecialCounter(client, other);
                return Plugin_Handled; 
            }
        }
    }

    return Plugin_Continue;
}

void Knux_ScanForSpitterProjectile(int client)
{
    int entity = -1; float clientPos[3]; GetClientEyePosition(client, clientPos);
    while ((entity = FindEntityByClassname(entity, "spitter_projectile")) != -1) {
        if (IsValidEntity(entity)) {
            float projPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", projPos);
            if (GetVectorDistance(clientPos, projPos) < 250.0) {
                AcceptEntityInput(entity, "Kill");
                Knux_FireGrenade(client);
                EmitSoundToAll(KNUX_SOUND_COUNTER_HIT, client);
                PrintCenterText(client, "🧪 ¡ACIDO REFLEJADO!");
                break;
            }
        }
    }
}

void Knux_FireGrenade(int client)
{
    int grenade = CreateEntityByName("grenade_launcher_projectile");
    if (grenade != -1) {
        float pos[3], ang[3], fwd[3];
        GetClientEyePosition(client, pos); GetClientEyeAngles(client, ang);
        GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR); ScaleVector(fwd, 1200.0);
        DispatchSpawn(grenade); SetEntPropEnt(grenade, Prop_Send, "m_hOwnerEntity", client); SetEntProp(grenade, Prop_Send, "m_iTeamNum", 2);
        TeleportEntity(grenade, pos, ang, fwd);
    }
}

public Action Knux_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Knux_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != KNUCKLES_INDEX) return Plugin_Continue;

    if (g_bKnuxCharging[victim]) { damage *= g_cvKnuxDamageReduc.FloatValue; return Plugin_Changed; }

    if (GetEngineTime() < g_fKnuxExtendedImmunity[victim]) {
        damage = 0.0; return Plugin_Handled;
    }

    if (g_bKnuxCountering[victim] && attacker > 0) {
        if (attacker <= MaxClients && GetClientTeam(attacker) == TEAM_INFECTED && GetEntProp(attacker, Prop_Send, "m_zombieClass") == 8) {
            Knuckles_CheckTankCounter(attacker, victim);
        }
        char cls[32]; GetEntityClassname(attacker, cls, sizeof(cls));
        if (StrEqual(cls, "infected")) {
            SDKHooks_TakeDamage(attacker, victim, victim, 100.0, DMG_CLUB);
        }
        damage = 0.0; 
        return Plugin_Handled;
    }
    return Plugin_Continue;
}