/*
 * ======================================================
 *  [MODULO] Tails "Miles" Prower - Support & Utility v4.1 (Witch Fix)
 *  FIX: Lift-Off Assist y Air Steering añadidos al vuelo.
 *  FIX: Láser ahora atraviesa hordas enteras y daña a las Witches.
 *  FIX: Se permite disparar el láser mientras se vuela.
 *  FIX: Animal Sense ahora detecta Witches y limpia el brillo al morir Tails.
 *  FIX: Feedback visual para la curación de soporte (Anillo Verde).
 * ======================================================
 */

#if defined _Tails_included
    #endinput
#endif
#define _Tails_included

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

#if !defined TAILS_INDEX
    #define TAILS_INDEX 1
#endif

// =======================
// Constantes y Audio
// =======================
#define TAILS_SOUND_FLY_START   "mobius/sfx/tails/fly_start.mp3"
#define TAILS_SOUND_FLY_LOOP    "mobius/sfx/tails/fly_loop.mp3" 
#define TAILS_SOUND_CHARGE      "mobius/sfx/tails/charge.mp3"   
#define TAILS_SOUND_LASER_LOOP  "mobius/sfx/tails/laser_fire.mp3" 

// Colores del Laser (Amarillo Puro y Solido)
int g_iColorLaser[4] = {255, 255, 0, 255}; 
int g_iSpriteLaser = -1;
int g_iSpriteHalo = -1;
int g_iSpriteGlow = -1;

// =======================
// Variables Globales
// =======================
// --- Vuelo ---
bool g_bTailsFlying[MAXPLAYERS + 1];
float g_fTailsFuel[MAXPLAYERS + 1]; 
float g_fTailsFlyCooldown[MAXPLAYERS + 1];

// --- Laser ---
bool g_bTailsCharging[MAXPLAYERS + 1];     
bool g_bTailsFiring[MAXPLAYERS + 1];       
float g_fTailsLaserCooldown[MAXPLAYERS + 1];
float g_fTailsChargeStartTime[MAXPLAYERS + 1];
float g_fTailsFireEndTime[MAXPLAYERS + 1]; 

// --- Stagger Logic ---
float g_fLaserAccumulator[MAXPLAYERS + 1][MAXPLAYERS + 1]; 

// --- Timers ---
Handle g_hTailsPassiveTimer = INVALID_HANDLE; 
Handle g_hTailsActionTimer[MAXPLAYERS + 1]; 

// --- ConVars ---
ConVar g_cvTailsSenseRange;
ConVar g_cvTailsHealBoost;
ConVar g_cvTailsFlyDuration;
ConVar g_cvTailsFlyCooldown;
ConVar g_cvTailsFlySpeedUp;
ConVar g_cvTailsLaserDamage;  
ConVar g_cvTailsLaserCooldown;

#define Tails_IsValidClient(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif

// =======================
// Inicializacion
// =======================

public void Tails_OnPluginStart()
{
    // Pasivas
    g_cvTailsSenseRange = CreateConVar("tails_sense_range", "800.0", "Rango de deteccion del Animal Sense");
    g_cvTailsHealBoost  = CreateConVar("tails_heal_boost", "2.0", "Multiplicador de velocidad de curacion cerca de Tails");
    
    // Vuelo
    g_cvTailsFlyDuration = CreateConVar("tails_fly_duration", "10.0", "Duracion maxima del vuelo (segundos)");
    g_cvTailsFlyCooldown = CreateConVar("tails_fly_cooldown", "25.0", "Cooldown del vuelo");
    g_cvTailsFlySpeedUp  = CreateConVar("tails_fly_up_speed", "180.0", "Velocidad de ascenso al mantener espacio");

    // Laser 
    g_cvTailsLaserDamage   = CreateConVar("tails_laser_damage", "15.0", "Dano del canon laser por tick (0.1s)");
    g_cvTailsLaserCooldown = CreateConVar("tails_laser_cooldown", "45.0", "Cooldown del canon laser");

    HookEvent("player_death", Tails_Event_PlayerDeath);
    HookEvent("round_start", Tails_Event_RoundStart);
    HookEvent("heal_begin", Tails_Event_HealBegin);

    if (g_hTailsPassiveTimer != INVALID_HANDLE) KillTimer(g_hTailsPassiveTimer);
    g_hTailsPassiveTimer = CreateTimer(0.5, T_TailsPassiveLogic, _, TIMER_REPEAT);
    
    AutoExecConfig(true, "Tails_Abilities");
}

public void Tails_OnMapStart()
{
    PrecacheSound(TAILS_SOUND_FLY_START, true);
    PrecacheSound(TAILS_SOUND_FLY_LOOP, true);
    PrecacheSound(TAILS_SOUND_CHARGE, true);
    PrecacheSound(TAILS_SOUND_LASER_LOOP, true);
    
    g_iSpriteLaser = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    g_iSpriteHalo = PrecacheModel("materials/sprites/glow01.vmt", true);
    g_iSpriteGlow = PrecacheModel("materials/sprites/redglow1.vmt", true); 
}

// =======================
// Eventos y Limpieza
// =======================

public void Tails_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        Tails_ResetState(i);
        g_fTailsFlyCooldown[i] = 0.0;
        g_fTailsLaserCooldown[i] = 0.0;
        SDKUnhook(i, SDKHook_PreThink, Tails_FlyThink);
    }
}

public Action Tails_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        Tails_StopFlying(client);
        Tails_ResetState(client);
    }
    return Plugin_Continue;
}

void Tails_ResetState(int client)
{
    g_bTailsCharging[client] = false;
    
    if (g_bTailsFiring[client]) {
        StopSound(client, SNDCHAN_AUTO, TAILS_SOUND_LASER_LOOP); 
    }
    
    g_bTailsFiring[client] = false;
    
    if (g_hTailsActionTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hTailsActionTimer[client]);
        g_hTailsActionTimer[client] = INVALID_HANDLE;
    }
    for(int j=1; j<=MaxClients; j++) g_fLaserAccumulator[client][j] = 0.0;
    
    if (IsClientInGame(client)) {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
}

// =======================
// PASIVA 1: ANIMAL SENSE (SENSE DE WITCHES & SI)
// =======================

public Action T_TailsPassiveLogic(Handle timer)
{
    int tailsCount = 0;
    int tailsClients[MAXPLAYERS + 1];
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (Tails_IsValidClient(i) && g_iPlayerCharIdx[i] == TAILS_INDEX)
        {
            tailsClients[tailsCount++] = i;
        }
    }
    
    // Si no hay ningun Tails en el juego, limpiamos los brillos residuales
    if (tailsCount == 0)
    {
        Tails_ClearAnimalSense();
        return Plugin_Continue;
    }
    
    float rangeSq = g_cvTailsSenseRange.FloatValue * g_cvTailsSenseRange.FloatValue;
    
    // Detectar Infectados Especiales
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;

        float targetPos[3];
        GetClientAbsOrigin(i, targetPos);
        
        bool inRange = false;
        for (int t = 0; t < tailsCount; t++)
        {
            float tPos[3]; GetClientAbsOrigin(tailsClients[t], tPos);
            if (GetVectorDistance(tPos, targetPos, true) <= rangeSq)
            {
                inRange = true;
                break;
            }
        }

        if (inRange)
        {
            SetEntProp(i, Prop_Send, "m_iGlowType", 3); 
            SetEntProp(i, Prop_Send, "m_glowColorOverride", 16776960); // Amarillo
            SetEntProp(i, Prop_Send, "m_bFlashing", 1);
        }
        else if (GetEntProp(i, Prop_Send, "m_iGlowType") == 3)
        {
            SetEntProp(i, Prop_Send, "m_iGlowType", 0);
            SetEntProp(i, Prop_Send, "m_bFlashing", 0);
        }
    }
    
    // Detectar Witches
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (!IsValidEntity(witch)) continue;
        
        float targetPos[3];
        GetEntPropVector(witch, Prop_Send, "m_vecOrigin", targetPos);
        
        bool inRange = false;
        for (int t = 0; t < tailsCount; t++)
        {
            float tPos[3]; GetClientAbsOrigin(tailsClients[t], tPos);
            if (GetVectorDistance(tPos, targetPos, true) <= rangeSq)
            {
                inRange = true;
                break;
            }
        }

        if (inRange)
        {
            SetEntProp(witch, Prop_Send, "m_iGlowType", 3); 
            SetEntProp(witch, Prop_Send, "m_glowColorOverride", 16776960); // Amarillo
            SetEntProp(witch, Prop_Send, "m_bFlashing", 1);
        }
        else if (GetEntProp(witch, Prop_Send, "m_iGlowType") == 3)
        {
            SetEntProp(witch, Prop_Send, "m_iGlowType", 0);
            SetEntProp(witch, Prop_Send, "m_bFlashing", 0);
        }
    }
    
    return Plugin_Continue;
}

void Tails_ClearAnimalSense()
{
    // Limpieza Especiales
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            if (GetEntProp(i, Prop_Send, "m_iGlowType") == 3)
            {
                SetEntProp(i, Prop_Send, "m_iGlowType", 0);
                SetEntProp(i, Prop_Send, "m_bFlashing", 0);
            }
        }
    }
    // Limpieza Witches
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (IsValidEntity(witch))
        {
            if (GetEntProp(witch, Prop_Send, "m_iGlowType") == 3)
            {
                SetEntProp(witch, Prop_Send, "m_iGlowType", 0);
                SetEntProp(witch, Prop_Send, "m_bFlashing", 0);
            }
        }
    }
}

// =======================
// PASIVA 2: MEDIC SUPPORT
// =======================

public void Tails_Event_HealBegin(Event event, const char[] name, bool dontBroadcast)
{
    int healer = GetClientOfUserId(event.GetInt("userid"));
    if (!Tails_IsValidClient(healer)) return;

    bool tailsNearby = false;
    float healerPos[3]; GetClientAbsOrigin(healer, healerPos);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (Tails_IsValidClient(i) && g_iPlayerCharIdx[i] == TAILS_INDEX)
        {
            float tailsPos[3]; GetClientAbsOrigin(i, tailsPos);
            if (GetVectorDistance(healerPos, tailsPos) < 250.0)
            {
                tailsNearby = true;
                break;
            }
        }
    }

    if (tailsNearby)
    {
        float duration = GetEntPropFloat(healer, Prop_Send, "m_flProgressBarDuration");
        if (duration > 0.0)
        {
            float boost = g_cvTailsHealBoost.FloatValue;
            if (boost < 1.0) boost = 1.0;
            float newDuration = duration / boost;
            
            // FIX: Calcular el tiempo exacto en el que debe terminar la curación
            float newTime = GetGameTime() + newDuration;
            
            // 1. Sincronizar la barra visual (Lo que ya tenías)
            SetEntPropFloat(healer, Prop_Send, "m_flProgressBarDuration", newDuration);
            SetEntPropFloat(healer, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
            
            // 2. FORZAR AL ARMA A TERMINAR ANTES (El verdadero fix)
            int weapon = GetEntPropEnt(healer, Prop_Send, "m_hActiveWeapon");
            if (weapon > 0 && IsValidEntity(weapon))
            {
                SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", newTime);
                
                // Algunas armas usan este timer secundario para la animación de uso
                if (HasEntProp(weapon, Prop_Send, "m_flTimeWeaponIdle"))
                {
                    SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", newTime);
                }
            }
            
            // 3. FORZAR AL JUGADOR A PODER ACTUAR ANTES
            SetEntPropFloat(healer, Prop_Send, "m_flNextAttack", newTime);
            
            PrintCenterText(healer, "⚕️ ¡Soporte de Tails! Curación acelerada.");
            
            // Feedback Visual del Aura
            float hPos[3]; GetClientAbsOrigin(healer, hPos); hPos[2] += 10.0;
            TE_SetupBeamRingPoint(hPos, 10.0, 150.0, g_iSpriteHalo, 0, 0, 0, 1.0, 10.0, 0.0, {0, 255, 0, 200}, 0, 0);
            TE_SendToAll();
        }
    }
}

// =======================
// ACTIVA 1: GLIDE (VUELO ASISTIDO Y STEERING)
// =======================

public Action Command_TailsFly(int client, int args)
{
    if (!Tails_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != TAILS_INDEX) return Plugin_Handled;

    if (g_bTailsFlying[client])
    {
        Tails_StopFlying(client);
        PrintCenterText(client, "Vuelo cancelado.");
        return Plugin_Handled;
    }

    if (GetEngineTime() < g_fTailsFlyCooldown[client])
    {
        PrintCenterText(client, "Cansado... Espera %.1fs", g_fTailsFlyCooldown[client] - GetEngineTime());
        return Plugin_Handled;
    }

    g_bTailsFlying[client] = true;
    g_fTailsFuel[client] = GetEngineTime() + g_cvTailsFlyDuration.FloatValue;
    
    // Lift-Off Assist (Despegue Asistido para evitar cancelacion instantanea por piso)
    float pos[3], vel[3];
    GetClientAbsOrigin(client, pos); pos[2] += 10.0;
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[2] = 250.0; 
    TeleportEntity(client, pos, NULL_VECTOR, vel);
    
    SDKHook(client, SDKHook_PreThink, Tails_FlyThink);
    EmitSoundToAll(TAILS_SOUND_FLY_START, client);
    PrintCenterText(client, "🚁 ¡Planeando! (Manten ESPACIO para subir, WASD para moverte)");
    
    return Plugin_Handled;
}

public void Tails_FlyThink(int client)
{
    if (g_iPlayerCharIdx[client] != TAILS_INDEX) { Tails_StopFlying(client); return; }
    if (!g_bTailsFlying[client] || !IsPlayerAlive(client)) { SDKUnhook(client, SDKHook_PreThink, Tails_FlyThink); return; }

    float engineTime = GetEngineTime();
    
    if (engineTime > g_fTailsFuel[client])
    {
        Tails_StopFlying(client);
        PrintCenterText(client, "⚠️ ¡Se acabo el combustible de vuelo!");
        return;
    }

    int flags = GetEntityFlags(client);
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);

    // Si toca el suelo y venia cayendo (Con 0.5s de gracia tras el Lift-Off)
    if ((flags & FL_ONGROUND) && vel[2] <= 0.0)
    {
        if (g_cvTailsFlyDuration.FloatValue - (g_fTailsFuel[client] - engineTime) > 0.5)
        {
            Tails_StopFlying(client);
            return;
        }
    }

    vel[2] = -50.0; // Caida lenta base
    if (GetClientButtons(client) & IN_JUMP) vel[2] = g_cvTailsFlySpeedUp.FloatValue;

    // Air Steering (Control Aéreo Total)
    float fwdAng[3], fwd[3], right[3];
    GetClientEyeAngles(client, fwdAng);
    fwdAng[0] = 0.0;
    GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);

    int buttons = GetClientButtons(client);
    float accel = 20.0;
    float maxSpeed = 250.0;
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

void Tails_StopFlying(int client)
{
    if (!g_bTailsFlying[client]) return;
    g_bTailsFlying[client] = false;
    g_fTailsFlyCooldown[client] = GetEngineTime() + g_cvTailsFlyCooldown.FloatValue;
    SDKUnhook(client, SDKHook_PreThink, Tails_FlyThink);
}

// =======================
// ACTIVA 2: LASER CANNON (CON PENETRACIÓN)
// =======================

public Action Command_TailsLaser(int client, int args)
{
    if (!Tails_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != TAILS_INDEX) return Plugin_Handled;

    float now = GetEngineTime();

    if (g_bTailsFiring[client]) return Plugin_Handled;

    if (g_bTailsCharging[client])
    {
        if (now - g_fTailsChargeStartTime[client] >= 1.0)
        {
            Tails_StartFiring(client);
        }
        else
        {
            PrintCenterText(client, "⚠️ ¡Cargando turbinas! (%.1fs)", 1.0 - (now - g_fTailsChargeStartTime[client]));
        }
        return Plugin_Handled;
    }

    if (now < g_fTailsLaserCooldown[client])
    {
        PrintCenterText(client, "🔫 Cañón recalentado. Espera %.1fs", g_fTailsLaserCooldown[client] - now);
        return Plugin_Handled;
    }

    g_bTailsCharging[client] = true;
    g_fTailsChargeStartTime[client] = now;
    
    // QoL: Ya no cancelamos el vuelo. Se puede cargar desde el aire.
    
    EmitSoundToAll(TAILS_SOUND_CHARGE, client);
    PrintCenterText(client, "⚡ ¡Cargando Láser! Presiona de nuevo para DISPARAR.");
    
    if (g_hTailsActionTimer[client] != INVALID_HANDLE) KillTimer(g_hTailsActionTimer[client]);
    g_hTailsActionTimer[client] = CreateTimer(0.1, T_TailsChargeLoop, GetClientUserId(client), TIMER_REPEAT);

    return Plugin_Handled;
}

public Action T_TailsChargeLoop(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (!Tails_IsValidClient(client) || !IsPlayerAlive(client) || !g_bTailsCharging[client])
    {
        g_hTailsActionTimer[client] = INVALID_HANDLE;
        return Plugin_Stop;
    }

    float pos[3]; GetClientAbsOrigin(client, pos); pos[2] += 10.0;
    
    TE_SetupBeamRingPoint(pos, 40.0, 10.0, g_iSpriteLaser, g_iSpriteHalo, 0, 15, 0.1, 5.0, 0.0, g_iColorLaser, 0, 0);
    TE_SendToAll();
    
    TE_SetupGlowSprite(pos, g_iSpriteGlow, 0.1, 1.2, 80);
    TE_SendToAll();

    return Plugin_Continue;
}

void Tails_StartFiring(int client)
{
    g_bTailsCharging[client] = false; 
    g_bTailsFiring[client] = true;    
    
    g_fTailsFireEndTime[client] = GetEngineTime() + 4.0;

    if (g_hTailsActionTimer[client] != INVALID_HANDLE) KillTimer(g_hTailsActionTimer[client]);
    g_hTailsActionTimer[client] = CreateTimer(0.1, T_TailsFireLoop, GetClientUserId(client), TIMER_REPEAT);

    EmitSoundToAll(TAILS_SOUND_LASER_LOOP, client);
    PrintCenterText(client, "🔥 ¡FUEGO A DISCRECIÓN!");
    
    // Si no está volando, penaliza la velocidad de movimiento (Sentimiento de arma pesada)
    if (!g_bTailsFlying[client])
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.5);
    }
}

public Action T_TailsFireLoop(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (!Tails_IsValidClient(client) || !g_bTailsFiring[client])
    {
        Tails_ResetState(client);
        return Plugin_Stop;
    }

    if (GetEngineTime() > g_fTailsFireEndTime[client])
    {
        Tails_EndFiring(client);
        return Plugin_Stop;
    }

    float origin[3], angles[3], endPos[3];
    GetClientEyePosition(client, origin);
    GetClientEyeAngles(client, angles);
    
    Handle trace = TR_TraceRayFilterEx(origin, angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer, client);
    if (TR_DidHit(trace)) TR_GetEndPosition(endPos, trace);
    else
    {
        float fwd[3]; GetAngleVectors(angles, fwd, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(fwd, 2000.0);
        AddVectors(origin, fwd, endPos);
    }
    delete trace;

    // Visuals
    TE_SetupBeamPoints(origin, endPos, g_iSpriteLaser, g_iSpriteHalo, 0, 0, 0.15, 30.0, 30.0, 0, 0.0, g_iColorLaser, 0);
    TE_SendToAll();
    
    int white[4] = {255, 255, 255, 255};
    TE_SetupBeamPoints(origin, endPos, g_iSpriteLaser, g_iSpriteHalo, 0, 0, 0.15, 10.0, 10.0, 0, 0.0, white, 0);
    TE_SendToAll();
    
    TE_SetupSparks(endPos, view_as<float>({0.0,0.0,1.0}), 50, 20);
    TE_SendToAll();
    TE_SetupGlowSprite(endPos, g_iSpriteHalo, 0.1, 2.0, 200);
    TE_SendToAll();

    Tails_ProcessLaserHit(client, origin, endPos);

    return Plugin_Continue;
}

void Tails_EndFiring(int client)
{
    g_bTailsFiring[client] = false;
    g_hTailsActionTimer[client] = INVALID_HANDLE;
    g_fTailsLaserCooldown[client] = GetEngineTime() + g_cvTailsLaserCooldown.FloatValue;
    
    for(int j=1; j<=MaxClients; j++) g_fLaserAccumulator[client][j] = 0.0;

    PrintCenterText(client, "🔋 Cañón agotado. Enfriando...");
    StopSound(client, SNDCHAN_AUTO, TAILS_SOUND_LASER_LOOP); 
    
    if (IsClientInGame(client)) {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
}

void Tails_ProcessLaserHit(int attacker, float start[3], float end[3])
{
    float damageTick = g_cvTailsLaserDamage.FloatValue; 
    float radiusSq = 180.0 * 180.0; 
    
    float vecLine[3];
    SubtractVectors(end, start, vecLine);
    float dotLine = GetVectorDotProduct(vecLine, vecLine);

    // 1. Especiales y Tank (MaxClients)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;

        float targetPos[3]; GetClientAbsOrigin(i, targetPos); targetPos[2] += 30.0;
        
        bool hit = false;
        
        if (GetVectorDistance(end, targetPos, true) <= radiusSq) hit = true;
        else if (dotLine > 0.0)
        {
            float vecPoint[3], tempLine[3];
            SubtractVectors(targetPos, start, vecPoint);
            float t = GetVectorDotProduct(vecPoint, vecLine) / dotLine;
            if (t >= 0.0 && t <= 1.0) 
            {
                float closestPoint[3];
                tempLine = vecLine;
                ScaleVector(tempLine, t);
                AddVectors(start, tempLine, closestPoint);
                if (GetVectorDistance(closestPoint, targetPos) <= 75.0) hit = true; 
            }
        }

        if (hit)
        {
            SDKHooks_TakeDamage(i, attacker, attacker, damageTick, DMG_ENERGYBEAM | DMG_SHOCK);

            float pushDir[3];
            MakeVectorFromPoints(start, targetPos, pushDir);
            NormalizeVector(pushDir, pushDir);
            ScaleVector(pushDir, 350.0); 
            pushDir[2] = 100.0; 
            
            float vel[3]; GetEntPropVector(i, Prop_Data, "m_vecVelocity", vel);
            AddVectors(vel, pushDir, vel);
            TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vel);

            g_fLaserAccumulator[attacker][i] += 0.1;
            
            bool isTank = (GetEntProp(i, Prop_Send, "m_zombieClass") == 8);
            float threshold = isTank ? 2.5 : 1.5;
            
            if (g_fLaserAccumulator[attacker][i] >= threshold)
            {
                L4D_StaggerPlayer(i, attacker, start);
                g_fLaserAccumulator[attacker][i] = 0.0; 
                
                TE_SetupExplosion(targetPos, g_iSpriteHalo, 10.0, 1, 0, 0, 0);
                TE_SendToAll();
            }
        }
        else
        {
            if (g_fLaserAccumulator[attacker][i] > 0.0) 
                g_fLaserAccumulator[attacker][i] -= 0.05; 
        }
    }

    // 2. Infectados Comunes
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            zPos[2] += 30.0;
            
            bool hit = false;
            if (GetVectorDistance(end, zPos) <= 180.0) hit = true;
            else if (dotLine > 0.0)
            {
                float vecPoint[3], tempLine[3];
                SubtractVectors(zPos, start, vecPoint);
                float t = GetVectorDotProduct(vecPoint, vecLine) / dotLine;
                if (t >= 0.0 && t <= 1.0) 
                {
                    float closestPoint[3];
                    tempLine = vecLine;
                    ScaleVector(tempLine, t);
                    AddVectors(start, tempLine, closestPoint);
                    if (GetVectorDistance(closestPoint, zPos) <= 75.0) hit = true; 
                }
            }

            if (hit)
            {
                SDKHooks_TakeDamage(entity, attacker, attacker, damageTick, DMG_ENERGYBEAM);
                float push[3]; MakeVectorFromPoints(start, zPos, push); NormalizeVector(push, push); ScaleVector(push, 400.0);
                push[2] += 150.0;
                TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }
    
    // 3. Witches
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float wPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", wPos);
            wPos[2] += 30.0;
            
            bool hit = false;
            if (GetVectorDistance(end, wPos) <= 180.0) hit = true;
            else if (dotLine > 0.0)
            {
                float vecPoint[3], tempLine[3];
                SubtractVectors(wPos, start, vecPoint);
                float t = GetVectorDotProduct(vecPoint, vecLine) / dotLine;
                if (t >= 0.0 && t <= 1.0) 
                {
                    float closestPoint[3];
                    tempLine = vecLine;
                    ScaleVector(tempLine, t);
                    AddVectors(start, tempLine, closestPoint);
                    if (GetVectorDistance(closestPoint, wPos) <= 75.0) hit = true; 
                }
            }

            if (hit)
            {
                SDKHooks_TakeDamage(entity, attacker, attacker, damageTick, DMG_ENERGYBEAM);
                float push[3]; MakeVectorFromPoints(start, wPos, push); NormalizeVector(push, push); ScaleVector(push, 250.0);
                push[2] += 100.0;
                TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask, int data)
{
    return entity != data;
}