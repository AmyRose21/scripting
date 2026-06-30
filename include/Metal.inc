/*
 * ======================================================
 *  [MODULO] Metal Sonic - The Ultimate Machine (v3.0 - CANONICO)
 *
 *  Rol: Tanque Kamikaze / Bruiser
 *  Pasivas: Resistencia 50%, Sin Incap (Explota al morir), Sonar de Infectados, Impermeable.
 *  Habilidad 1: Destructive Charge (carga, agarra, arrastra y estampa)
 *  Habilidad 2: V. Maximum Overdrive (velocidad y dano electrico)
 *
 *  v3.0 - Implementacion canonica segun spec oficial:
 *   - Windup ~1s con parpadeo rojo (3 destellos).
 *   - Dash con controles resbaladizos (estilo Dropdash).
 *   - Al agarrar Executioner: Metal LO ARRASTRA, sigue moviendose.
 *   - Auto-dano 4 HP / 0.25s mientras arrastra. Total acumulado 40 HP.
 *   - Reducido si Metal < 30% HP. Muy reducido en Last Man Standing.
 *   - Si no mantiene W mientras arrastra: Metal se queda pegado, acumula
 *     40 HP de dano (PEOR que wall slam = 39).
 *   - Wall slam CON Executioner: infectado aturdido 10s, Metal pierde 39 HP (13x3).
 *     En LMS: 15 HP (5x3).
 *   - Wall slam SIN Executioner: rebota, aturdido 1-2s.
 *   - Cancel en windup: dano completo (ignora resistencia), CD reducido (50%),
 *     speed boost temporal que stacea con on-hit.
 *   - Fin natural del charge (acumula 40): infectado aturdido 3s, Metal libre.
 *   - El stun NO comienza hasta que Metal slamea al infectado contra pared
 *     o lo suelta (termina el charge).
 * ======================================================
 */

#if defined _Metal_included
    #endinput
#endif
#define _Metal_included

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

#if !defined METALSONIC_INDEX
    #define METALSONIC_INDEX 8
#endif

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// =======================
// Constantes Ajustables
// =======================
#define METAL_WINDUP_DURATION       1.0   // Carga canonica ~1 segundo
#define METAL_DASH_DURATION         2.5   // Tiempo maximo del dash antes de cancelar solo
#define METAL_GRAB_RADIUS           110.0 // Radio para agarrar al Executioner
#define METAL_DRAG_SPEED            600.0 // Velocidad de arrastre (resbaladiza)
#define METAL_DRAG_TURN_RATE        0.5   // Que tan lento gira (controles resbaladizos)

#define METAL_DRAG_DMG_NORMAL       4     // 4 HP cada 0.25s
#define METAL_DRAG_DMG_LOWHP        2     // Si <30% HP
#define METAL_DRAG_DMG_LMS          1     // Last Man Standing
#define METAL_DRAG_TOTAL_CAP        40    // Total acumulado antes de soltar automaticamente
#define METAL_DRAG_TICK             0.25  // Intervalo de auto-dano

#define METAL_DROP_STUN_TIME        3.0   // Stun al infectado cuando se suelta por 40 acumulado
#define METAL_WALL_SLAM_STUN        10.0  // Stun al infectado al slamear contra pared
#define METAL_WALL_SLAM_DMG         13.0  // Dano a Metal por hit (3 hits = 39 total)
#define METAL_WALL_SLAM_DMG_LMS     5.0   // Dano a Metal por hit en LMS (3 hits = 15 total)
#define METAL_WALL_SLAM_TICKS       3     // Cantidad de ticks de dano wall slam

#define METAL_BOUNCE_STUN_MIN       1.0   // Stun min al rebotar sin infectado
#define METAL_BOUNCE_STUN_MAX       2.0   // Stun max al rebotar sin infectado

#define METAL_CHARGE_COOLDOWN       25.0
#define METAL_CHARGE_CD_CANCELLED   12.5  // CD reducido si cancelan windup (50%)

#define METAL_CANCEL_SPEED_BOOST    1.25  // Multiplicador de velocidad al cancelar windup
#define METAL_CANCEL_BOOST_TIME     2.0   // Duracion del speed boost

#define METAL_OVERDRIVE_COOLDOWN    30.0
#define METAL_OVERDRIVE_DURATION    5.0
#define METAL_AURA_RADIUS           200.0
#define METAL_AURA_TICK             0.3
#define METAL_AURA_DMG_INF          15.0

#define METAL_SONAR_MAX_RANGE       800.0
#define METAL_SONAR_MIN_DELAY       0.1
#define METAL_SONAR_MAX_DELAY       0.5

#define METAL_LOW_HP_THRESHOLD      0.30  // 30% de HP maximo

// =======================
// Estados del Charge
// =======================
enum
{
    METAL_STATE_IDLE = 0,
    METAL_STATE_WINDUP,     // Cargando (inmovil, parpadea)
    METAL_STATE_DASH,       // Avanza buscando Executioner
    METAL_STATE_DRAGGING,   // Arrastrando Executioner, sigue en movimiento
    METAL_STATE_WALL_SLAM,  // Slameando contra pared (timer de 3 hits)
    METAL_STATE_BOUNCE      // Rebote sin infectado (stun 1-2s)
};

// =======================
// Variables Globales
// =======================
float g_fMetalChargeCD[MAXPLAYERS + 1];
float g_fMetalOverdriveCD[MAXPLAYERS + 1];

int   g_iMetalChargeState[MAXPLAYERS + 1];
int   g_iMetalGrabbedTarget[MAXPLAYERS + 1];
float g_fMetalStateEndTime[MAXPLAYERS + 1];
float g_fMetalNextDragTick[MAXPLAYERS + 1];   // Proximo tick de auto-dano
float g_fMetalAccumulatedDragDmg[MAXPLAYERS + 1]; // Dano acumulado en el drag actual
float g_fMetalWindupStartTime[MAXPLAYERS + 1]; // Para calcular los 3 destellos

// Wall slam
int   g_iMetalWallSlamHits[MAXPLAYERS + 1];
float g_fMetalNextWallSlamTick[MAXPLAYERS + 1];

// Overdrive
bool  g_bMetalOverdrive[MAXPLAYERS + 1];
float g_fMetalOverdriveEndTime[MAXPLAYERS + 1];
float g_fMetalNextAuraTick[MAXPLAYERS + 1];

// Sonar
float g_fMetalNextBeepTick[MAXPLAYERS + 1];

// Cancel boost
float g_fMetalCancelBoostEnd[MAXPLAYERS + 1];

// Cache de modelos precacheados
int g_iMetalSpriteGlow = 0;
int g_iMetalSpriteLaser = 0;

#define Metal_IsValidClient(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// Inicializacion
// =======================

public void Metal_OnPluginStart()
{
    RegConsoleCmd("sm_metal_charge", Command_MetalCharge);
    RegConsoleCmd("sm_metal_overdrive", Command_MetalOverdrive);
}

public void Metal_OnMapStart()
{
    PrecacheSound("buttons/button17.wav", true);
    PrecacheSound("ambient/explosions/explode_3.wav", true);
    PrecacheSound("ambient/energy/zap1.wav", true);
    PrecacheSound("npc/attack_helicopter/aheli_charge_up.wav", true);
    PrecacheSound("player/tank/hit/hulk_punch_1.wav", true);
    PrecacheSound("player/tank/hit/hulk_punch_2.wav", true);
    PrecacheSound("player/survivor/hit/crowbar_swing_miss1.wav", true);
    PrecacheSound("ambient/machines/electric_loop.wav", true);

    g_iMetalSpriteGlow  = PrecacheModel("materials/sprites/glow01.vmt", true);
    g_iMetalSpriteLaser = PrecacheModel("materials/sprites/laserbeam.vmt", true);

    for (int i = 1; i <= MaxClients; i++)
        Metal_ResetState(i);
}

public void Metal_OnClientPutInServer(int client)
{
    SDKUnhook(client, SDKHook_OnTakeDamage, Metal_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Metal_OnTakeDamage);

    SDKUnhook(client, SDKHook_PreThink, Metal_PreThink);
    SDKHook(client, SDKHook_PreThink, Metal_PreThink);
}

void Metal_ResetState(int client)
{
    g_iMetalChargeState[client]       = METAL_STATE_IDLE;
    g_iMetalGrabbedTarget[client]     = -1;
    g_bMetalOverdrive[client]         = false;
    g_fMetalChargeCD[client]          = 0.0;
    g_fMetalOverdriveCD[client]       = 0.0;
    g_fMetalAccumulatedDragDmg[client] = 0.0;
    g_iMetalWallSlamHits[client]      = 0;
    g_fMetalCancelBoostEnd[client]    = 0.0;
}

// =======================
// HELPERS
// =======================

// Cuenta sobrevivientes vivos (no incapacitados)
int Metal_CountAliveSurvivors()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR)
        {
            if (GetEntProp(i, Prop_Send, "m_isIncapacitated") == 0)
                count++;
        }
    }
    return count;
}

// Detecta si Metal esta en Last Man Standing
bool Metal_IsLMS(int client)
{
    return Metal_CountAliveSurvivors() <= 1;
}

// Detecta si Metal esta por debajo del 30% de HP
bool Metal_IsLowHP(int client)
{
    int hp = GetClientHealth(client);
    int maxHp = GetEntProp(client, Prop_Send, "m_iMaxHealth");
    if (maxHp <= 0) maxHp = 100;
    return float(hp) <= float(maxHp) * METAL_LOW_HP_THRESHOLD;
}

// Devuelve el dano por tick de arrastre segun contexto
int Metal_GetDragDamage(int client)
{
    if (Metal_IsLMS(client))
        return METAL_DRAG_DMG_LMS;
    if (Metal_IsLowHP(client))
        return METAL_DRAG_DMG_LOWHP;
    return METAL_DRAG_DMG_NORMAL;
}

// =======================
// PASIVAS Y SONAR
// =======================

public void Metal_PreThink(int client)
{
    if (!Metal_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return;

    float now = GetEngineTime();

    // 0. Cancel speed boost (si activo)
    if (g_fMetalCancelBoostEnd[client] > 0.0)
    {
        if (now >= g_fMetalCancelBoostEnd[client])
        {
            g_fMetalCancelBoostEnd[client] = 0.0;
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        }
        else
        {
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", METAL_CANCEL_SPEED_BOOST);
        }
    }

    // 1. SONAR DE PROXIMIDAD
    if (now >= g_fMetalNextBeepTick[client] && g_iMetalChargeState[client] == METAL_STATE_IDLE)
    {
        g_fMetalNextBeepTick[client] = now + 0.5;

        int closestInfected = -1;
        float closestDist = METAL_SONAR_MAX_RANGE;
        float mPos[3], tPos[3];
        GetClientAbsOrigin(client, mPos);

        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
            {
                GetClientAbsOrigin(i, tPos);
                float dist = GetVectorDistance(mPos, tPos);
                if (dist < closestDist)
                {
                    closestDist = dist;
                    closestInfected = i;
                }
            }
        }

        if (closestInfected != -1)
        {
            float delay = METAL_SONAR_MIN_DELAY + (closestDist / METAL_SONAR_MAX_RANGE) * (METAL_SONAR_MAX_DELAY - METAL_SONAR_MIN_DELAY);
            g_fMetalNextBeepTick[client] = now + delay;

            int hp = GetClientHealth(client);
            int pitch = 100 + (150 - hp);
            if (pitch > 250) pitch = 250;
            if (pitch < 50)  pitch = 50;

            EmitSoundToClient(client, "buttons/button17.wav", _, _, _, _, _, pitch);
        }
    }

    // 2. OVERDRIVE
    if (g_bMetalOverdrive[client])
    {
        if (now >= g_fMetalOverdriveEndTime[client])
        {
            g_bMetalOverdrive[client] = false;
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            PrintCenterText(client, "Reactor sobrecalentado. Inmovilizado.");
            SetEntityMoveType(client, MOVETYPE_NONE);
            CreateTimer(1.5, T_Metal_OverheatEnd, GetClientUserId(client));
        }
        else
        {
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.3);
            if (now >= g_fMetalNextAuraTick[client])
            {
                g_fMetalNextAuraTick[client] = now + METAL_AURA_TICK;
                Metal_OverdriveAuraTick(client);
            }
        }
    }

    // 3. DESTRUCTIVE CHARGE
    if (g_iMetalChargeState[client] > METAL_STATE_IDLE)
    {
        Metal_ChargeThink(client, now);
    }
}

// Aura de Overdrive
void Metal_OverdriveAuraTick(int client)
{
    float mPos[3];
    GetClientAbsOrigin(client, mPos);

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3];
            GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(mPos, zPos) <= METAL_AURA_RADIUS)
                SDKHooks_TakeDamage(entity, client, client, 999.0, DMG_SHOCK);
        }
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float tPos[3];
            GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(mPos, tPos) <= METAL_AURA_RADIUS)
                SDKHooks_TakeDamage(i, client, client, METAL_AURA_DMG_INF, DMG_SHOCK);
        }
    }

    TE_SetupSparks(mPos, NULL_VECTOR, 5, 2);
    TE_SendToAll();
}

// =======================
// DESTRUCTIVE CHARGE - THINK PRINCIPAL
// =======================

void Metal_ChargeThink(int client, float now)
{
    int state  = g_iMetalChargeState[client];
    int target = g_iMetalGrabbedTarget[client];

    // ---- ESTADO 1: WINDUP (cargando ~1s) ----
    if (state == METAL_STATE_WINDUP)
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);

        // Parpadeo rojo con 3 destellos visibles sobre 1 segundo
        float elapsed = now - g_fMetalWindupStartTime[client];
        float freq = METAL_WINDUP_DURATION / 3.0; // 3 destellos
        float phase = elapsed / freq;
        float sineVal = Sine(phase * 3.14159 * 2.0);
        int alpha = RoundToNearest(sineVal * 127.5 + 127.5);
        if (alpha < 50) alpha = 50;
        if (alpha > 255) alpha = 255;

        SetEntityRenderMode(client, RENDER_TRANSCOLOR);
        SetEntityRenderColor(client, 255, 0, 0, alpha);

        if (now >= g_fMetalStateEndTime[client])
        {
            // Transicion a DASH
            g_iMetalChargeState[client] = METAL_STATE_DASH;
            g_fMetalStateEndTime[client] = now + METAL_DASH_DURATION;
            SetEntityRenderColor(client, 255, 0, 0, 255);
            EmitSoundToAll("npc/attack_helicopter/aheli_charge_up.wav", client);

            // Impulso inicial (estilo Peelout)
            float ang[3], fwd[3], vel[3];
            GetClientEyeAngles(client, ang);
            GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
            ScaleVector(fwd, 1500.0);
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            vel[0] += fwd[0];
            vel[1] += fwd[1];
            vel[2] = 0.0;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
            PrintCenterText(client, "DESTRUCTIVE CHARGE!");
        }
        return;
    }

    // ---- ESTADO 2: DASH (avanza resbaladizo, busca Executioner) ----
    if (state == METAL_STATE_DASH)
    {
        // Mantener velocidad alta (controles resbaladizos: no auto-rotacion)
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        float speed2D = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
        if (speed2D < 1000.0)
        {
            float ang[3], fwd[3];
            GetClientEyeAngles(client, ang);
            GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
            ScaleVector(fwd, 1200.0);
            vel[0] = fwd[0];
            vel[1] = fwd[1];
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        }

        // Buscar auto-objetivo
        if (target == -1)
        {
            int grabbed = Metal_FindGrabTarget(client);
            if (grabbed != -1)
            {
                Metal_BeginDrag(client, grabbed, now);
                return;
            }
        }

        // Choco pared SIN infectado -> rebote y stun 1-2s
        if (Metal_HitWall(client))
        {
            Metal_DoBounce(client);
            return;
        }

        // Tiempo agotado
        if (now >= g_fMetalStateEndTime[client])
        {
            Metal_CancelCharge(client, false);
        }
        return;
    }

    // ---- ESTADO 3: DRAGGING (arrastra Executioner, Metal sigue moviendose) ----
    if (state == METAL_STATE_DRAGGING)
    {
        // Validar target
        if (!Metal_IsValidClient(target))
        {
            Metal_CancelCharge(client, false);
            return;
        }

        // Auto-dano periodico
        if (now >= g_fMetalNextDragTick[client])
        {
            g_fMetalNextDragTick[client] = now + METAL_DRAG_TICK;
            int dmg = Metal_GetDragDamage(client);
            g_fMetalAccumulatedDragDmg[client] += float(dmg);
            Metal_TakeSelfDamage(client, float(dmg));

            // Si llegamos al cap de 40 acumulado -> soltar automaticamente
            if (g_fMetalAccumulatedDragDmg[client] >= float(METAL_DRAG_TOTAL_CAP))
            {
                Metal_DropByDamageCap(client, target);
                return;
            }
        }

        // Verificar si mantiene W presionada
        int buttons = GetClientButtons(client);
        if (!(buttons & IN_FORWARD))
        {
            // Metal se queda pegado en sitio, pero sigue acumulando dano
            // (segun spec: peor que wall slam porque acumula 40)
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);
            PrintCenterText(client, "Mantén W para arrastrarlo a la pared!");
        }
        else
        {
            // Avanza arrastrando al infectado (velocidad resbaladiza)
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);

            // Empujar a Metal hacia adelante a velocidad de arrastre
            float vel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            float speed2D = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
            if (speed2D < METAL_DRAG_SPEED)
            {
                float ang[3], fwd[3];
                GetClientEyeAngles(client, ang);
                GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
                ScaleVector(fwd, METAL_DRAG_SPEED);
                vel[0] = fwd[0];
                vel[1] = fwd[1];
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
            }
        }

        // Sincronizar posicion del Executioner: pegado adelante de Metal
        float mPos[3], mAng[3], fwd[3];
        GetClientAbsOrigin(client, mPos);
        GetClientAbsAngles(client, mAng);
        GetAngleVectors(mAng, fwd, NULL_VECTOR, NULL_VECTOR);
        mPos[0] += fwd[0] * 35.0;
        mPos[1] += fwd[1] * 35.0;
        mPos[2] += 10.0;
        TeleportEntity(target, mPos, NULL_VECTOR, NULL_VECTOR);

        // Choco pared CON infectado -> WALL SLAM
        if (Metal_HitWall(client))
        {
            Metal_BeginWallSlam(client, target, now);
            return;
        }

        if (now >= g_fMetalStateEndTime[client])
            Metal_CancelCharge(client, false);

        return;
    }

    // ---- ESTADO 4: WALL_SLAM (timer de 3 hits) ----
    if (state == METAL_STATE_WALL_SLAM)
    {
        // Metal inmovil mientras slamea
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);
        SetEntityMoveType(client, MOVETYPE_NONE);

        if (now >= g_fMetalNextWallSlamTick[client])
        {
            g_fMetalNextWallSlamTick[client] = now + 0.1;
            g_iMetalWallSlamHits[client]++;

            // Calcular dano por hit segun LMS
            float dmgPerHit = Metal_IsLMS(client) ? METAL_WALL_SLAM_DMG_LMS : METAL_WALL_SLAM_DMG;

            // Sonido + sparks cada hit
            float pos[3];
            GetClientAbsOrigin(client, pos);
            EmitSoundToAll("player/tank/hit/hulk_punch_2.wav", client);
            TE_SetupSparks(pos, NULL_VECTOR, 6, 3);
            TE_SendToAll();

            if (Metal_IsValidClient(target))
            {
                // Mantener infectado pegado a la pared
                float tPos[3], mAng[3], fwd[3];
                GetClientAbsOrigin(client, tPos);
                GetClientAbsAngles(client, mAng);
                GetAngleVectors(mAng, fwd, NULL_VECTOR, NULL_VECTOR);
                tPos[0] += fwd[0] * 35.0;
                tPos[1] += fwd[1] * 35.0;
                tPos[2] += 10.0;
                TeleportEntity(target, tPos, NULL_VECTOR, NULL_VECTOR);
            }

            Metal_TakeSelfDamage(client, dmgPerHit);

            if (g_iMetalWallSlamHits[client] >= METAL_WALL_SLAM_TICKS)
            {
                // Final del wall slam: aturdir infectado 10s
                if (Metal_IsValidClient(target))
                {
                    L4D_StaggerPlayer(target, client, NULL_VECTOR);
                    SetEntPropFloat(target, Prop_Send, "m_flLaggedMovementValue", 0.0);
                    CreateTimer(METAL_WALL_SLAM_STUN, T_Metal_UnstunInfected, GetClientUserId(target));
                }

                PrintCenterText(client, "¡Estampado! Infectado aturdido %.0fs.", METAL_WALL_SLAM_STUN);

                // Reset final
                SetEntityRenderColor(client, 255, 255, 255, 255);
                SetEntityMoveType(client, MOVETYPE_WALK);
                SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
                g_iMetalChargeState[client]   = METAL_STATE_IDLE;
                g_iMetalGrabbedTarget[client] = -1;
                g_iMetalWallSlamHits[client]  = 0;
                g_fMetalAccumulatedDragDmg[client] = 0.0;
            }
        }
        return;
    }

    // ---- ESTADO 5: BOUNCE (rebote sin infectado, stun 1-2s) ----
    if (state == METAL_STATE_BOUNCE)
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);
        SetEntityMoveType(client, MOVETYPE_NONE);

        if (now >= g_fMetalStateEndTime[client])
        {
            SetEntityMoveType(client, MOVETYPE_WALK);
            SetEntityRenderColor(client, 255, 255, 255, 255);
            g_iMetalChargeState[client] = METAL_STATE_IDLE;
            PrintCenterText(client, "Recuperado del rebote.");
        }
        return;
    }
}

// v3: Inicia el arrastre del Executioner
void Metal_BeginDrag(int client, int target, float now)
{
    g_iMetalGrabbedTarget[client]      = target;
    g_iMetalChargeState[client]        = METAL_STATE_DRAGGING;
    g_fMetalNextDragTick[client]       = now + METAL_DRAG_TICK;
    g_fMetalAccumulatedDragDmg[client] = 0.0;
    g_fMetalStateEndTime[client]       = now + 10.0; // Limite de seguridad

    EmitSoundToAll("ambient/machines/electric_loop.wav", client);
    PrintCenterText(client, "Ejecutioner agarrado! Mantén W para estamparlo.");
}

// v3: Suelta al infectado porque acumulo 40 HP de dano (no slameo)
void Metal_DropByDamageCap(int client, int target)
{
    if (Metal_IsValidClient(target))
    {
        // Stun de 3s al infectado por soltarlo
        L4D_StaggerPlayer(target, client, NULL_VECTOR);
        SetEntPropFloat(target, Prop_Send, "m_flLaggedMovementValue", 0.0);
        CreateTimer(METAL_DROP_STUN_TIME, T_Metal_UnstunInfected, GetClientUserId(target));
    }

    SetEntityRenderColor(client, 255, 255, 255, 255);
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    g_iMetalChargeState[client]       = METAL_STATE_IDLE;
    g_iMetalGrabbedTarget[client]     = -1;
    g_fMetalAccumulatedDragDmg[client] = 0.0;

    PrintCenterText(client, "Carga terminada. Infectado aturdido %.0fs.", METAL_DROP_STUN_TIME);
}

// v3: Inicia el wall slam (3 hits de 13 HP)
void Metal_BeginWallSlam(int client, int target, float now)
{
    g_iMetalChargeState[client]   = METAL_STATE_WALL_SLAM;
    g_iMetalWallSlamHits[client]  = 0;
    g_fMetalNextWallSlamTick[client] = now + 0.05;

    // Frenar a Metal de inmediato
    float zero[3] = {0.0, 0.0, 0.0};
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, zero);

    PrintCenterText(client, "¡Estampando contra la pared!");
    EmitSoundToAll("player/tank/hit/hulk_punch_1.wav", client);
}

// v3: Rebote sin infectado
void Metal_DoBounce(int client)
{
    // Aplicar velocidad hacia atras
    float ang[3], back[3], vel[3];
    GetClientEyeAngles(client, ang);
    GetAngleVectors(ang, back, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(back, -500.0);
    vel[0] = back[0];
    vel[1] = back[1];
    vel[2] = 200.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    SetEntityRenderColor(client, 255, 255, 255, 255);
    g_iMetalChargeState[client] = METAL_STATE_BOUNCE;

    // Stun aleatorio 1-2s
    float stunTime = METAL_BOUNCE_STUN_MIN + GetRandomFloat(0.0, METAL_BOUNCE_STUN_MAX - METAL_BOUNCE_STUN_MIN);
    g_fMetalStateEndTime[client] = GetEngineTime() + stunTime;

    PrintCenterText(client, "¡Rebote! Aturdido %.1fs.", stunTime);
    EmitSoundToAll("player/survivor/hit/crowbar_swing_miss1.wav", client);
}

// v3: Busca un infectado especial dentro del radio de agarre
int Metal_FindGrabTarget(int client)
{
    float mPos[3], tPos[3];
    GetClientAbsOrigin(client, mPos);

    int best = -1;
    float bestDist = METAL_GRAB_RADIUS;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        GetClientAbsOrigin(i, tPos);
        float dist = GetVectorDistance(mPos, tPos);
        if (dist < bestDist)
        {
            bestDist = dist;
            best = i;
        }
    }
    return best;
}

// =======================
// GESTION DE DANO Y AUTO-DESTRUCCION
// =======================

public Action Metal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Metal_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != METALSONIC_INDEX) return Plugin_Continue;

    // Inmunidades pasivas
    if (damagetype & DMG_FALL || damagetype & DMG_ACID || damagetype & DMG_POISON || damagetype & DMG_RADIATION)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // v3: Si esta en WINDUP y lo golpean -> CANCEL con dano completo, CD reducido, speed boost
    if (g_iMetalChargeState[victim] == METAL_STATE_WINDUP)
    {
        Metal_CancelWindup(victim);
        return Plugin_Changed; // dano completo (sin reduccion 50%)
    }

    // v3: Si esta en WALL_SLAM o BOUNCE, no recibe dano externo
    if (g_iMetalChargeState[victim] == METAL_STATE_WALL_SLAM ||
        g_iMetalChargeState[victim] == METAL_STATE_BOUNCE)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // Reduccion 50% en el resto de casos
    damage *= 0.5;
    return Plugin_Changed;
}

// v3: Cancela el windup con penalizacion: CD reducido + speed boost
void Metal_CancelWindup(int client)
{
    float now = GetEngineTime();

    // CD reducido (50% del normal)
    g_fMetalChargeCD[client] = now + METAL_CHARGE_CD_CANCELLED;

    // Speed boost temporal (stacea con on-hit boost existente)
    g_fMetalCancelBoostEnd[client] = now + METAL_CANCEL_BOOST_TIME;
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", METAL_CANCEL_SPEED_BOOST);

    // Reset visual y estado
    SetEntityRenderColor(client, 255, 255, 255, 255);
    g_iMetalChargeState[client]   = METAL_STATE_IDLE;
    g_iMetalGrabbedTarget[client] = -1;

    PrintCenterText(client, "¡Carga interrumpida! Speed boost activado.");
    EmitSoundToClient(client, "player/survivor/hit/crowbar_swing_miss1.wav");
}

// Dano propio que ignora la reduccion de 50%
void Metal_TakeSelfDamage(int client, float amount)
{
    int hp = GetClientHealth(client);
    hp -= RoundToNearest(amount);

    if (hp <= 0)
    {
        Metal_SelfDestruct(client, true);
    }
    else
    {
        SetEntityHealth(client, hp);
    }
}

// Explosion al morir
void Metal_SelfDestruct(int client, bool fromCharge)
{
    if (!Metal_IsValidClient(client)) return;

    float pos[3];
    GetClientAbsOrigin(client, pos);

    TE_SetupExplosion(pos, g_iMetalSpriteGlow, 50.0, 1, 0, 600, 0);
    TE_SendToAll();
    EmitSoundToAll("ambient/explosions/explode_3.wav", client);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float tPos[3];
            GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(pos, tPos) <= 500.0)
            {
                L4D_StaggerPlayer(i, client, pos);
                SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 0.1);
                CreateTimer(5.0, T_Metal_UnstunInfected, GetClientUserId(i));
            }
        }
    }

    // Liberar target si estaba agarrado
    int target = g_iMetalGrabbedTarget[client];
    if (target > 0 && IsClientInGame(target) && IsPlayerAlive(target))
    {
        SetEntityMoveType(target, MOVETYPE_WALK);
        SetEntPropFloat(target, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }

    Metal_ResetState(client);
    ForcePlayerSuicide(client);
    PrintToChatAll("\x04[Metal Sonic]\x01 se ha auto-destruido para proteger al equipo.");
}

public Action T_Metal_UnstunInfected(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntityMoveType(client, MOVETYPE_WALK);
    }
    return Plugin_Stop;
}

// =======================
// HABILIDAD 1: DESTRUCTIVE CHARGE
// =======================

public Action Command_MetalCharge(int client, int args)
{
    if (!Metal_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return Plugin_Handled;
    if (g_iMetalChargeState[client] != METAL_STATE_IDLE)
    {
        PrintCenterText(client, "Ya estas en carga.");
        return Plugin_Handled;
    }
    if (g_bMetalOverdrive[client])
    {
        PrintCenterText(client, "No puedes cargar durante Overdrive.");
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fMetalChargeCD[client])
    {
        PrintCenterText(client, "Cooldown: %.1f", g_fMetalChargeCD[client] - now);
        return Plugin_Handled;
    }

    g_fMetalChargeCD[client] = now + METAL_CHARGE_COOLDOWN;

    // Iniciar WINDUP
    g_iMetalChargeState[client]    = METAL_STATE_WINDUP;
    g_fMetalStateEndTime[client]   = now + METAL_WINDUP_DURATION;
    g_fMetalWindupStartTime[client] = now;
    PrintCenterText(client, "Cargando Destructive Charge...");

    return Plugin_Handled;
}

// Cancela la carga (no por interrupcion de windup)
void Metal_CancelCharge(int client, bool hitWall)
{
    if (g_iMetalChargeState[client] == METAL_STATE_IDLE) return;

    int target = g_iMetalGrabbedTarget[client];

    // Restaurar movilidad
    SetEntityRenderColor(client, 255, 255, 255, 255);
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntityMoveType(client, MOVETYPE_WALK);

    if (target > 0 && IsClientInGame(target) && IsPlayerAlive(target))
    {
        SetEntityMoveType(target, MOVETYPE_WALK);
    }

    g_iMetalChargeState[client]    = METAL_STATE_IDLE;
    g_iMetalGrabbedTarget[client]  = -1;
    g_fMetalAccumulatedDragDmg[client] = 0.0;
}

public Action T_Metal_UnstunMetal(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client))
    {
        SetEntityMoveType(client, MOVETYPE_WALK);
    }
    return Plugin_Stop;
}

// =======================
// HABILIDAD 2: V. MAXIMUM OVERDRIVE
// =======================

public Action Command_MetalOverdrive(int client, int args)
{
    if (!Metal_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return Plugin_Handled;
    if (g_bMetalOverdrive[client]) return Plugin_Handled;
    if (g_iMetalChargeState[client] != METAL_STATE_IDLE)
    {
        PrintCenterText(client, "No puedes usar Overdrive durante una carga.");
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fMetalOverdriveCD[client])
    {
        PrintCenterText(client, "Overdrive Cooldown: %.1f", g_fMetalOverdriveCD[client] - now);
        return Plugin_Handled;
    }

    g_fMetalOverdriveCD[client]     = now + METAL_OVERDRIVE_COOLDOWN;
    g_bMetalOverdrive[client]       = true;
    g_fMetalOverdriveEndTime[client] = now + METAL_OVERDRIVE_DURATION;
    g_fMetalNextAuraTick[client]    = now;

    EmitSoundToAll("ambient/energy/zap1.wav", client);
    PrintCenterText(client, "V. MAXIMUM OVERDRIVE ACTIVADO");

    return Plugin_Handled;
}

public Action T_Metal_OverheatEnd(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client))
    {
        SetEntityMoveType(client, MOVETYPE_WALK);
        PrintCenterText(client, "Reactor enfriado.");
    }
    return Plugin_Stop;
}

// =======================
// UTILIDADES
// =======================

bool Metal_HitWall(int client)
{
    float pos[3], endPos[3], ang[3], fwd[3];
    GetClientEyePosition(client, pos);
    GetClientEyeAngles(client, ang);

    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(fwd, 40.0);
    AddVectors(pos, fwd, endPos);

    Handle trace = TR_TraceRayFilterEx(pos, endPos, MASK_SOLID, RayType_EndPoint, Metal_TraceFilter_NoPlayers, client);
    bool hit = TR_DidHit(trace);
    delete trace;
    return hit;
}

public bool Metal_TraceFilter_NoPlayers(int entity, int contentsMask, int data)
{
    if (entity == data) return false;
    if (entity > 0 && entity <= MaxClients) return false;
    return true;
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
public void Metal_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return;

    // Liberar al infectado si estaba agarrado
    int target = g_iMetalGrabbedTarget[client];
    if (target > 0 && IsClientInGame(target) && IsPlayerAlive(target))
    {
        SetEntityMoveType(target, MOVETYPE_WALK);
        SetEntPropFloat(target, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
    Metal_ResetState(client);
}

// Puente de compatibilidad
public void Metal_OnPlayerRunCmd(int client, int &buttons) {}
