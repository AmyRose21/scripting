/*
 * ======================================================
 *  [MODULO] Shadow the Hedgehog - Ultimate Lifeform Rework v6.0-OM (SU AVATAR)
 *
 *  v6.0-OM (manager 3.77.49, orden del owner: "con que añadieras
 *  a shadow Om su avatar y demas cosas de Gmod"):
 *    - AVATAR ESPEJO shadow.mdl (7o avatar del suite, patron Rouge
 *      v10.2 / Amy v95): modelos/Noodles/OM/shadow.mdl del VPK
 *      (FileExists: si no esta, CERO dependencia — survivor normal).
 *      Copia R (los demas) + copia L (el dueño) + cuerpo oculto +
 *      FSM 10 Hz + ragdoll de muerte 15s + anti-corpse 2s + adopción
 *      de huerfanos + pulso de pausa + tinte ROJO con los Anillos.
 *    - FSM POR PROBE (receta Amy v92): shadow.mdl no trae tabla
 *      documentada — cada estado tiene una CADENA de candidatos
 *      (idle/walk/run/jump/fall + lowhealth<=50 + downed + HOVER
 *      propio + one-shots SNAP/BLAST) y gana el primer nombre que
 *      exista en el modelo; si falta, su estado base lo cubre.
 *    - ONE-SHOTS de habilidad sobre las DOS copias: Chaos Snap y
 *      Chaos Blast ahora tienen SU animación (si el .mdl la trae).
 *    - Convar shadow_avatar 1.
 *
 *  v5.2 (anterior): Chaos Snap (Z, teleport + golpe al especial en la
 *  trayectoria), Chaos Blast (X, 500 dmg área + desintegración),
 *  Hover Shoes (SPACE en el aire), Anillos Inhibidores (<50 HP:
 *  dano -50% + velocidad +30% + Blast potenciado).
 * ======================================================
 */

#if defined _Shadow_included
    #endinput
#endif
#define _Shadow_included

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

// =======================
// Dependencias
// =======================
#if !defined SHADOW_INDEX
    #define SHADOW_INDEX 5
#endif

// =======================
// Constantes y Audio
// =======================
#define SHADOW_SOUND_DASH       "mobius/sfx/shadow/dash.mp3"
#define SHADOW_SOUND_SNAP       "mobius/sfx/shadow/chaos_snap.mp3"
#define SHADOW_SOUND_PARRY      "mobius/sfx/shadow/chaos_blast.mp3"
// v6.0: golpe del snap a un especial en la trayectoria (nativo L4D2,
// sin descargas)
#define SHADOW_SOUND_SNAP_HIT   "player/tank/hit/hulk_punch_2.wav"

// v6.0: parámetros del Chaos Snap
#define SHADOW_SNAP_RANGE       600.0   // alcance máximo del teleport
#define SHADOW_SNAP_WALL_GAP    16.0    // margen anti-atasco contra muros
#define SHADOW_SNAP_CORRIDOR    60.0    // radio del "corredor" de detección de especiales
#define SHADOW_SNAP_STANDOFF    80.0    // distancia de aparición ante un especial
#define SHADOW_SNAP_HIT_DMG     150.0   // dano del golpe tras el TP

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif

// =======================
// v6.0-OM: AVATAR ESPEJO SHADOW.MDL (7o avatar del suite)
// =======================
#define SHADOW_INC_VERSION   "v6.0-OM"   // v6.0-OM: SU AVATAR (manager 3.77.49); v5.2: kit GMod (snap/blast/hover/anillos)
#define SHADOW_OM_MODEL      "models/Noodles/OM/shadow.mdl"
#define SHADOW_AVATAR_NAME   "shadow_avatar_om"
#define SHADOW_AVATAR_NAME_L "shadow_avatar_om_l"

// FSM de animación — los nombres se RESUELVEN contra el .mdl real por
// PROBE (receta Amy v92): cada estado tiene una cadena de candidatos y
// gana el primero que exista en el modelo (shadow.mdl no trae tabla
// documentada); los que falten caen a su estado base (nunca T-pose)
#define SHADOW_ST_IDLE        0
#define SHADOW_ST_WALK        1
#define SHADOW_ST_RUN         2
#define SHADOW_ST_JUMP        3    // one-shot con ventana (receta Rouge)
#define SHADOW_ST_FALL        4
#define SHADOW_ST_IDLE_LOW    5    // lowhealth (HP <= 50: los Anillos)
#define SHADOW_ST_WALK_LOW    6
#define SHADOW_ST_RUN_LOW     7
#define SHADOW_ST_DOWNED_IDLE 8    // incap
#define SHADOW_ST_DOWNED_WALK 9
#define SHADOW_ST_HOVER       10   // Hover Shoes (SPACE mantenido en el aire)
#define SHADOW_ST_SNAP        11   // one-shot: Chaos Snap
#define SHADOW_ST_BLAST       12   // one-shot: Chaos Blast
#define SHADOW_ANIM_COUNT     13
#define SHADOW_SEQ_MAX_CAND   6

#define SHADOW_LOCK_SNAP      0.50   // FSM quieta durante el snap
#define SHADOW_LOCK_BLAST     0.90   // FSM quieta durante el blast

// cadena de candidatos por estado (nombres del lua GMod + variantes)
static const char g_sShadowSeqCand[SHADOW_ANIM_COUNT][SHADOW_SEQ_MAX_CAND][24] = {
    { "idle",            "Idle",           "idle01",       "",             "",   ""        },  // 0
    { "walk",            "Walk",           "walk01",       "",             "",   ""        },  // 1
    { "run",             "Run",            "run01",        "RunTopSpeed",  "",   ""        },  // 2
    { "jump",            "Jump",           "Jump2",        "jumpv",        "",   ""        },  // 3
    { "fall",            "Fall",           "glide",        "",             "",   ""        },  // 4
    { "idle_lowhealth",  "IdleLowHealth",  "idle_low",     "IdleLow",      "",   ""        },  // 5
    { "walk_lowhealth",  "WalkLowHealth",  "walk_low",     "",             "",   ""        },  // 6
    { "run_lowhealth",   "RunLowHealth",   "run_low",      "",             "",   ""        },  // 7
    { "DownedIdle",      "downedidle",     "downed_idle",  "",             "",   ""        },  // 8
    { "DownedWalk",      "downedwalk",     "downed_walk",  "",             "",   ""        },  // 9
    { "hover",           "Hover",          "float",        "fly",          "glide", ""     },  // 10
    { "snap",            "ChaosSnap",      "chaos_snap",   "teleport",     "ChaosControl", "jump" },  // 11
    { "blast",           "ChaosBlast",     "chaos_blast",  "rage",         "jump", ""     }   // 12
};

// ---- v6.0-OM: estado del avatar (globals) ----
ConVar g_cvShadowAvatar;
bool   g_bShadowModelOK     = false;   // shadow.mdl en el VPK montado
bool   g_bShadowSeqResolved = false;   // el probe ya corrio en este mapa
Handle g_hShadowAvatarThink = null;    // FSM 10 Hz
int    g_iShadowAvatar[MAXPLAYERS + 1];      // EntRef copia R (0 = sin avatar)
int    g_iShadowAvatarL[MAXPLAYERS + 1];     // EntRef copia L
int    g_iShadowBodyRender[MAXPLAYERS + 1];  // render ORIGINAL del survivor
int    g_iShadowAnimState[MAXPLAYERS + 1];   // estado FSM actual
float  g_fShadowAnimLock[MAXPLAYERS + 1];    // lock de one-shot en curso
float  g_fShadowJumpStart[MAXPLAYERS + 1];   // t0 de la ventana del jump
float  g_fShadowBodyYaw[MAXPLAYERS + 1];     // yaw suavizado del avatar
float  g_fShadowYawLastT[MAXPLAYERS + 1];
bool   g_bShadowSmSnap[MAXPLAYERS + 1];
float  g_fShadowSmLoc[MAXPLAYERS + 1][3];
float  g_fShadowSmLocL[MAXPLAYERS + 1][3];
float  g_fShadowDeathHideUntil[MAXPLAYERS + 1];   // ventana anti-corpse
float  g_vShadowDeathOrigin[MAXPLAYERS + 1][3];
char   g_sShadowSeq[SHADOW_ANIM_COUNT][24];       // nombre RESUELTO por estado
bool   g_bShadowSeqOK[SHADOW_ANIM_COUNT];         // el estado resolvo?

// =======================
// Variables Globales
// =======================
// --- Cooldowns ---
float g_fShadowSnapCD[MAXPLAYERS + 1];
float g_fShadowBlastCD[MAXPLAYERS + 1];
float g_fInhibitorReady[MAXPLAYERS + 1];
float g_fInhibitorEndTime[MAXPLAYERS + 1];
float g_fLastDamageTime[MAXPLAYERS + 1];

// --- Estados de Rage ---
bool  g_bInhibitorActive[MAXPLAYERS + 1];

#define Shadow_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// Inicialización
// =======================

public void Shadow_OnPluginStart()
{
    HookEvent("player_spawn", Shadow_Event_PlayerSpawn);
    HookEvent("player_death", Shadow_Event_PlayerDeath);

    // v6.0-OM: avatar espejo (patron rouge_avatar / knux_avatar)
    g_cvShadowAvatar = CreateConVar("shadow_avatar", "1", "Shadow OM: avatar espejo (shadow.mdl del VPK de recursos, patron Tails/Sonic/Amy/Metal/Knuckles/Rouge)", _, true, 0.0, true, 1.0);
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            Shadow_OnClientPutInServer(i);
        }
    }
}

public void Shadow_OnMapStart()
{
    PrecacheSound(SHADOW_SOUND_DASH, true);
    PrecacheSound(SHADOW_SOUND_SNAP, true);
    PrecacheSound(SHADOW_SOUND_PARRY, true);
    PrecacheSound(SHADOW_SOUND_SNAP_HIT, true);   // v6.0: golpe del snap
    
    PrecacheModel("materials/sprites/laserbeam.vmt", true);
    PrecacheModel("materials/sprites/glow01.vmt", true);

    // v6.0-OM: AVATAR — shadow.mdl del VPK (detección FileExists estilo
    // star_stun: ve los VPK montados; sin el archivo TODO cae al
    // survivor normal, CERO dependencia)
    g_bShadowModelOK = FileExists(SHADOW_OM_MODEL, true);
    if (g_bShadowModelOK) PrecacheModel(SHADOW_OM_MODEL, true);

    // v6.0-OM: FSM del avatar (10 Hz, patron T_RougeAvatarThink) + el
    // probe de secuencias se re-resuelve en cada mapa (el .mdl puede
    // cambiar entre VPKs)
    g_bShadowSeqResolved = false;
    for (int s = 0; s < SHADOW_ANIM_COUNT; s++) g_bShadowSeqOK[s] = false;
    delete g_hShadowAvatarThink;
    g_hShadowAvatarThink = CreateTimer(0.1, T_ShadowAvatarThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    for (int i = 1; i <= MaxClients; i++)
        Shadow_ResetState(i);
}

// =======================
// Gestion de Estado
// =======================

public void Shadow_OnClientPutInServer(int client)
{
    SDKUnhook(client, SDKHook_OnTakeDamage, Shadow_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Shadow_OnTakeDamage);
    
    SDKUnhook(client, SDKHook_PreThink, Shadow_PreThink);
    SDKHook(client, SDKHook_PreThink, Shadow_PreThink);
}

public void Shadow_Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && IsClientInGame(client))
    {
        if (g_iPlayerCharIdx[client] == SHADOW_INDEX)
        {
            Shadow_ResetState(client);
            SDKUnhook(client, SDKHook_OnTakeDamage, Shadow_OnTakeDamage);
            SDKHook(client, SDKHook_OnTakeDamage, Shadow_OnTakeDamage);
            SDKUnhook(client, SDKHook_PreThink, Shadow_PreThink);
            SDKHook(client, SDKHook_PreThink, Shadow_PreThink);
        }
    }
}

public void Shadow_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0) return;

    // v6.0-OM: MUERTE DEL AVATAR — ragdoll shadow.mdl con la velocidad
    // del momento + ventana anti-corpse (receta Rouge v10.2 / Knuckles
    // v75) y el cuerpo del survivor vuelve a verse para el
    // spectate/revive. Este hook es POST: el avatar muere AQUÍ (la
    // lección Sonic v3.76.2 — en PRE el restore dejaba ver el corpse
    // del survivor).
    if (g_iPlayerCharIdx[client] == SHADOW_INDEX && g_iShadowAvatar[client] != 0)
    {
        Shadow_SpawnDeathRagdoll(client);
        g_fShadowDeathHideUntil[client] = GetEngineTime() + 2.0;
        GetClientAbsOrigin(client, g_vShadowDeathOrigin[client]);
        Shadow_KillAvatarOnly(client);
    }

    Shadow_ResetState(client);
}

void Shadow_ResetState(int client)
{
    g_fShadowSnapCD[client] = 0.0;
    g_fShadowBlastCD[client] = 0.0;
    g_fInhibitorReady[client] = 0.0;
    g_fInhibitorEndTime[client] = 0.0;
    g_fLastDamageTime[client] = 0.0;
    g_bInhibitorActive[client] = false;
    
    if (IsClientInGame(client))
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

// ==============================================================
// HOVER SHOES (PASIVA DE MOVILIDAD) & INHIBITOR SPEED OVERRIDES
// ==============================================================

public void Shadow_PreThink(int client)
{
    if (!Shadow_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != SHADOW_INDEX) return;

    int flags = GetEntityFlags(client);
    int buttons = GetClientButtons(client);

    if (g_bInhibitorActive[client])
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.3);
        
        float pos[3]; GetClientAbsOrigin(client, pos);
        pos[0] += GetRandomFloat(-15.0, 15.0);
        pos[1] += GetRandomFloat(-15.0, 15.0);
        pos[2] += GetRandomFloat(5.0, 45.0);
        TE_SetupGlowSprite(pos, PrecacheModel("materials/sprites/glow01.vmt"), 0.2, 0.5, 255);
        TE_SendToAll();
    }

    if (!(flags & FL_ONGROUND))
    {
        if (buttons & IN_JUMP)
        {
            float vel[3]; 
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            
            if (vel[2] < -20.0) 
            {
                vel[2] = -20.0;
            }

            float fwdAng[3], fwd[3], right[3];
            GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
            GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);

            float accel = 20.0; 
            if (buttons & IN_FORWARD)  { vel[0] += fwd[0]*accel; vel[1] += fwd[1]*accel; }
            if (buttons & IN_BACK)     { vel[0] -= fwd[0]*accel; vel[1] -= fwd[1]*accel; }
            if (buttons & IN_MOVELEFT) { vel[0] -= right[0]*accel; vel[1] -= right[1]*accel; }
            if (buttons & IN_MOVERIGHT){ vel[0] += right[0]*accel; vel[1] += right[1]*accel; }

            float maxSpeed = 300.0;
            float speed2D = SquareRoot(vel[0]*vel[0] + vel[1]*vel[1]);
            if (speed2D > maxSpeed) {
                vel[0] = (vel[0]/speed2D) * maxSpeed;
                vel[1] = (vel[1]/speed2D) * maxSpeed;
            }

            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

            float feetPos[3]; GetClientAbsOrigin(client, feetPos);
            TE_SetupSparks(feetPos, view_as<float>({0.0,0.0,-1.0}), 5, 2);
            TE_SendToAll();
        }
    }
}

// ==============================================================
// PASIVA: ANILLOS INHIBIDORES (I-FRAMES & DETECCION DE DAÑO)
// ==============================================================

public Action Shadow_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Shadow_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != SHADOW_INDEX) return Plugin_Continue;

    g_fLastDamageTime[victim] = GetEngineTime();

    if (g_bInhibitorActive[victim])
    {
        damage *= 0.5;
        return Plugin_Changed;
    }

    int currentHealth = GetClientHealth(victim);
    float now = GetEngineTime();
    if ((currentHealth - damage) <= 50.0 && now >= g_fInhibitorReady[victim])
    {
        g_fInhibitorReady[victim] = now + 60.0; 
        g_fInhibitorEndTime[victim] = now + 15.0; 
        g_bInhibitorActive[victim] = true;

        PrintToChat(victim, "\x04[Shadow]\x01 ¡ANILLOS INHIBIDORES REMOVIDOS! Daño Recibido -50% | Velocidad +30% | Chaos Blast Potenciado.");
        EmitSoundToAll(SHADOW_SOUND_DASH, victim);

        // v6.0-OM: el avatar se enciende de ROJO mientras dura el rage
        Shadow_AvatarSetColor(victim, 255, 80, 80, 255);

        CreateTimer(15.0, T_EndInhibitors, GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
    }

    return Plugin_Continue;
}

public Action T_EndInhibitors(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0)
    {
        g_bInhibitorActive[client] = false;
        if (IsClientInGame(client))
        {
            PrintToChat(client, "\x04[Shadow]\x01 Anillos inhibidores colocados de nuevo. Modo normal.");
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);

            // v6.0-OM: tinte base de vuelta
            Shadow_AvatarTintReset(client);
        }
    }
    return Plugin_Stop;
}

// ==============================================================
// HABILIDAD 1: CHAOS SNAP (TELEPORT & PERFECT DODGE CHAOS CONTROL)
// ==============================================================

public Action Command_ShadowAbility(int client, int args)
{
    if (!Shadow_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != SHADOW_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fShadowSnapCD[client])
    {
        PrintCenterText(client, "Chaos Snap Cooldown: %.1f", g_fShadowSnapCD[client] - now);
        return Plugin_Handled;
    }

    g_fShadowSnapCD[client] = now + 12.0;
    Shadow_PerformChaosSnap(client);

    return Plugin_Handled;
}

void Shadow_PerformChaosSnap(int client)
{
    float angles[3];
    GetClientEyeAngles(client, angles);

    float fwd[3];
    GetAngleVectors(angles, fwd, NULL_VECTOR, NULL_VECTOR);

    // v6.0 (petición usuario) FIX PAREDES: antes el snap trazaba un
    // RAYO DE UN PUNTO desde el ojo y teleportaba el ORIGEN de Shadow
    // exactamente al plano del muro -> quedaba incrustado / pegado a
    // la pared (sobre todo en angulos rasantes). Ahora se traza un
    // HULL con el cuerpo COMPLETO (32x32x72, origen al centro): el
    // teleport solo aterriza donde CABE el cuerpo entero, y además se
    // recula SHADOW_SNAP_WALL_GAP unidades del punto de impacto para
    // no quedar pegado al muro.
    float start[3];
    GetClientAbsOrigin(client, start);

    float end[3];
    end[0] = start[0] + fwd[0] * (SHADOW_SNAP_RANGE + 32.0);
    end[1] = start[1] + fwd[1] * (SHADOW_SNAP_RANGE + 32.0);
    end[2] = start[2] + fwd[2] * (SHADOW_SNAP_RANGE + 32.0);

    float mins[3] = {-16.0, -16.0, -36.0};
    float maxs[3] = {16.0, 16.0, 36.0};

    float endPos[3];
    float rayLen = SHADOW_SNAP_RANGE;   // distancia real del snap

    Handle trace = TR_TraceHullFilterEx(start, end, mins, maxs, MASK_SOLID,
                                         Shadow_TraceFilter_Body, client);
    if (TR_DidHit(trace))
    {
        float impact[3];
        TR_GetEndPosition(impact, trace);

        float dist = GetVectorDistance(start, impact);
        if (dist > SHADOW_SNAP_WALL_GAP)
        {
            // recular del muro para NO quedar pegado
            float back[3];
            back = fwd;
            ScaleVector(back, -SHADOW_SNAP_WALL_GAP);
            AddVectors(impact, back, endPos);
            rayLen = dist - SHADOW_SNAP_WALL_GAP;
        }
        else
        {
            // muro pegado a la cara: snap mínimo in situ
            endPos = start;
            rayLen = 0.0;
        }
    }
    else
    {
        // camino libre: aterrizar al alcance máximo
        endPos[0] = start[0] + fwd[0] * SHADOW_SNAP_RANGE;
        endPos[1] = start[1] + fwd[1] * SHADOW_SNAP_RANGE;
        endPos[2] = start[2] + fwd[2] * SHADOW_SNAP_RANGE;
    }
    delete trace;

    // ============================================================
    // v6.0 (petición usuario) NUEVO: ESPECIAL EN LA TRAYECTORIA.
    // Si hay un infectado especial dentro del "corredor" del snap
    // (el cilindro de radio SHADOW_SNAP_CORRIDOR alrededor de la
    // línea de vuelo, más cerca que el muro), Shadow NO completa el
    // recorrido: se teletransporta HASTA EL (separa
    // SHADOW_SNAP_STANDOFF), le suelta un golpe y el especial sale
    // VOLANDO hacia atras (en la dirección del snap).
    // ============================================================
    int snapTarget = -1;
    float snapTargetT = 999999.0;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float tPos[3];
        GetClientAbsOrigin(i, tPos);
        tPos[2] += 30.0;   // apuntar al torso

        // proyección del torso sobre la línea del snap
        float toT[3];
        SubtractVectors(tPos, start, toT);
        float t = GetVectorDotProduct(toT, fwd);
        if (t < 40.0 || t > rayLen) continue;   // detrás o más alla del destino

        float closest[3];
        closest[0] = start[0] + fwd[0] * t;
        closest[1] = start[1] + fwd[1] * t;
        closest[2] = start[2] + fwd[2] * t;

        if (GetVectorDistance(closest, tPos) <= SHADOW_SNAP_CORRIDOR)
        {
            if (t < snapTargetT)
            {
                snapTarget = i;
                snapTargetT = t;
            }
        }
    }

    if (snapTarget != -1)
    {
        // aterrizar ANTE el especial (standoff) pero nunca detrás del
        // arranque; el tramo ya quedó validado por el hull trace
        float tpDist = snapTargetT - SHADOW_SNAP_STANDOFF;
        if (tpDist < 30.0) tpDist = 30.0;
        if (tpDist > rayLen) tpDist = rayLen;

        endPos[0] = start[0] + fwd[0] * tpDist;
        endPos[1] = start[1] + fwd[1] * tpDist;
        endPos[2] = start[2] + fwd[2] * tpDist;
    }

    // liberar de cualquier agarre antes de volar (igual que antes)
    SetEntPropEnt(client, Prop_Send, "m_pounceAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_jockeyAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_carryAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_pummelAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_tongueOwner", -1);

    TeleportEntity(client, endPos, NULL_VECTOR, NULL_VECTOR);
    EmitSoundToAll(SHADOW_SOUND_SNAP, client);

    // v6.0-OM: SU animación del snap sobre las DOS copias del avatar
    Shadow_AvatarOneShot(client, SHADOW_ST_SNAP, SHADOW_LOCK_SNAP);

    // --- MEJORAS VISUALES (SNAP) ---
    int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
    int glow = PrecacheModel("materials/sprites/glow01.vmt");
    
    int colorBeam[4] = {150, 0, 255, 200};
    int colorRing[4] = {150, 0, 255, 200};
    
    // 1. Estela de distorsión morada brillante
    TE_SetupBeamPoints(start, endPos, beam, 0, 0, 0, 0.4, 15.0, 15.0, 0, 0.0, colorBeam, 0);
    TE_SendToAll();
    
    // 2. Luz dinámica morada en el destino
    Shadow_CreateTempLight(endPos, 150, 0, 255, 0.5, 400.0);
    
    // 3. Anillo de choque en el destino
    TE_SetupBeamRingPoint(endPos, 10.0, 250.0, beam, glow, 0, 15, 0.3, 20.0, 0.0, colorRing, 0, 0);
    TE_SendToAll();
    
    // 4. Chispas electricas en el destino
    TE_SetupSparks(endPos, NULL_VECTOR, 5, 3);
    TE_SendToAll();

    // v6.0: golpe al especial interceptado (después del TP para que
    // el dano se acredite desde la nueva posición)
    if (snapTarget != -1)
    {
        Shadow_SnapStrike(client, snapTarget, fwd);
    }

    float now = GetEngineTime();
    if (now - g_fLastDamageTime[client] <= 1.2)
    {
        TriggerChaosControl(client);
    }
}

// v6.0: golpe del Chaos Snap al especial interceptado en la
// trayectoria: dano + stagger seguro + sale VOLANDO hacia atras (en
// la dirección del snap, alejándose de Shadow).
void Shadow_SnapStrike(int client, int victim, const float fwd[3])
{
    if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return;

    float vPos[3];
    GetClientAbsOrigin(victim, vPos);

    SDKHooks_TakeDamage(victim, client, client, SHADOW_SNAP_HIT_DMG, DMG_CLUB);

    // stagger seguro (auto-recuperación del motor: 1.8s SI / 3.0s Tank)
    SIStagger_Auto(victim, client, vPos);

    // VUELA HACIA ATRAS: en la dirección del snap (le pega y lo manda
    // en la misma dirección en la que Shadow viajo)
    float push[3];
    push[0] = fwd[0];
    push[1] = fwd[1];
    push[2] = fwd[2];
    ScaleVector(push, 700.0);
    push[2] += 400.0;
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, push);

    // FX del impacto
    EmitSoundToAll(SHADOW_SOUND_SNAP_HIT, victim);

    int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
    int glow = PrecacheModel("materials/sprites/glow01.vmt");
    TE_SetupBeamRingPoint(vPos, 10.0, 150.0, beam, glow, 0, 15, 0.3, 12.0, 0.0, {255, 220, 80, 220}, 0, 0);
    TE_SendToAll();
    TE_SetupSparks(vPos, NULL_VECTOR, 20, 8);
    TE_SendToAll();

    if (IsClientInGame(client))
    {
        PrintCenterText(client, "CHAOS SNAP: impacto directo!");
    }
}

// v6.0: filtro del hull trace del snap: el cuerpo de Shadow viaja
// libre de jugadores e infectados (comunes/witch) para no chocar con
// cuerpos que no deben bloquear el teleport; muros, props y puertas
// SI bloquean (no se teleporta dentro de ellos).
public bool Shadow_TraceFilter_Body(int entity, int contentsMask, int data)
{
    if (entity == data) return false;                     // el propio Shadow
    if (entity > 0 && entity <= MaxClients) return false; // jugadores (SI: se interceptan aparte)

    if (entity > MaxClients && IsValidEntity(entity))
    {
        static char cls[16];
        GetEntityClassname(entity, cls, sizeof(cls));
        if (strcmp(cls, "infected") == 0) return false;   // comunes: no bloquean
        if (strcmp(cls, "witch") == 0) return false;      // witch: no bloquea
    }

    return true;   // mundo / props / puertas: bloquean
}

void TriggerChaosControl(int client)
{
    int timescale = CreateEntityByName("func_timescale");
    if (timescale != -1)
    {
        DispatchKeyValueFloat(timescale, "desiredTimescale", 0.25); 
        DispatchKeyValueFloat(timescale, "acceleration", 4.0);
        DispatchKeyValueFloat(timescale, "minBlendRate", 1.0);
        DispatchKeyValueFloat(timescale, "blendDeltaMultiplier", 3.0);
        DispatchSpawn(timescale);
        AcceptEntityInput(timescale, "Start");

        EmitSoundToAll(SHADOW_SOUND_SNAP, client);
        PrintToChatAll("\x04[Shadow]\x01 ¡CHAOS CONTROL! El tiempo global se ha ralentizado.");

        float pos[3]; GetClientAbsOrigin(client, pos);
        int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
        int glow = PrecacheModel("materials/sprites/glow01.vmt");
        int colorCtrl[4] = {0, 255, 255, 100};
        
        TE_SetupBeamRingPoint(pos, 10.0, 1000.0, beam, glow, 0, 0, 0.5, 10.0, 0.0, colorCtrl, 0, 0);
        TE_SendToAll();

        CreateTimer(3.0, T_EndChaosControl, EntIndexToEntRef(timescale), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action T_EndChaosControl(Handle timer, int ref)
{
    int entity = EntRefToEntIndex(ref);
    if (entity != INVALID_ENT_REFERENCE && IsValidEntity(entity))
    {
        AcceptEntityInput(entity, "Stop");
        AcceptEntityInput(entity, "Kill");
    }
    return Plugin_Stop;
}

// ==============================================================
// HABILIDAD 2: CHAOS BLAST (COLOSAL ONDA DE CHOQUE)
// ==============================================================

public Action Command_ShadowDash(int client, int args)
{
    if (!Shadow_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != SHADOW_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fShadowBlastCD[client])
    {
        PrintCenterText(client, "Chaos Blast Cooldown: %.1f", g_fShadowBlastCD[client] - now);
        return Plugin_Handled;
    }

    g_fShadowBlastCD[client] = now + 30.0; 
    TriggerChaosBlast(client);

    return Plugin_Handled;
}

void TriggerChaosBlast(int client)
{
    float pos[3]; GetClientAbsOrigin(client, pos);
    
    float vel[3]; vel[0] = 0.0; vel[1] = 0.0; vel[2] = 200.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    EmitSoundToAll(SHADOW_SOUND_PARRY, client);

    // v6.0-OM: SU animación del blast sobre las DOS copias del avatar
    Shadow_AvatarOneShot(client, SHADOW_ST_BLAST, SHADOW_LOCK_BLAST);

    float radius = 450.0;
    float damage = 500.0;

    // --- MEJORAS VISUALES (BLAST) ---
    int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
    int glow = PrecacheModel("materials/sprites/glow01.vmt");
    
    int colorRed[4] = {255, 0, 0, 255};
    int colorOrange[4] = {255, 100, 0, 255};
    
    if (g_bInhibitorActive[client])
    {
        damage = 750.0;
        radius = 600.0;
        TE_SetupBeamRingPoint(pos, 10.0, 600.0, beam, glow, 0, 15, 0.8, 30.0, 0.0, colorOrange, 0, 0); TE_SendToAll();
        CreateTimer(0.1, T_ShadowBlastRing2, EntIndexToEntRef(client));
        CreateTimer(0.2, T_ShadowBlastRing3, EntIndexToEntRef(client));
    }
    else
    {
        TE_SetupBeamRingPoint(pos, 10.0, 450.0, beam, glow, 0, 15, 0.6, 25.0, 0.0, colorRed, 0, 0); TE_SendToAll();
        CreateTimer(0.1, T_ShadowBlastRing2, EntIndexToEntRef(client));
        CreateTimer(0.2, T_ShadowBlastRing3, EntIndexToEntRef(client));
    }
    
    TE_SetupSparks(pos, NULL_VECTOR, 50, 20);
    TE_SendToAll();
    TE_SetupExplosion(pos, glow, 10.0, 1, 0, 0, 0); TE_SendToAll();

    // EL TEMBLOR DE CÁMARA (env_shake) HA SIDO ELIMINADO A PETICIÓN TUYA.

    // --- DAÑO Y DESINTEGRACIÓN ---
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float tPos[3]; GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(pos, tPos) <= radius)
            {
                int healthBefore = GetClientHealth(i);
                SDKHooks_TakeDamage(i, client, client, damage, DMG_BLAST);
                L4D_StaggerPlayer(i, client, pos);

                if (GetClientHealth(i) <= 0 && healthBefore > 0) {
                    Shadow_DissolveEntity(i);
                }

                float push[3]; MakeVectorFromPoints(pos, tPos, push);
                NormalizeVector(push, push);
                ScaleVector(push, 800.0);
                push[2] += 300.0;
                TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(pos, zPos) <= radius)
            {
                int healthBefore = GetEntProp(entity, Prop_Data, "m_iHealth");
                SDKHooks_TakeDamage(entity, client, client, 1000.0, DMG_BLAST);
                IgniteEntity(entity, 3.0);

                if (GetEntProp(entity, Prop_Data, "m_iHealth") <= 0 && healthBefore > 0) {
                    Shadow_DissolveEntity(entity);
                }
            }
        }
    }

    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (IsValidEntity(witch))
        {
            float wPos[3]; GetEntPropVector(witch, Prop_Send, "m_vecOrigin", wPos);
            if (GetVectorDistance(pos, wPos) <= radius)
            {
                int healthBefore = GetEntProp(witch, Prop_Data, "m_iHealth");
                SDKHooks_TakeDamage(witch, client, client, damage, DMG_BLAST);
                
                if (GetEntProp(witch, Prop_Data, "m_iHealth") <= 0 && healthBefore > 0) {
                    Shadow_DissolveEntity(witch);
                }
                
                float push[3]; MakeVectorFromPoints(pos, wPos, push);
                NormalizeVector(push, push); ScaleVector(push, 800.0); push[2] = 300.0;
                TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }
}

// Timers para los anillos escalonados
public Action T_ShadowBlastRing2(Handle timer, int clientRef)
{
    int client = EntRefToEntIndex(clientRef);
    if (client > 0 && IsValidEntity(client))
    {
        float pos[3]; GetClientAbsOrigin(client, pos);
        int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
        int glow = PrecacheModel("materials/sprites/glow01.vmt");
        
        int colorO2[4] = {255, 150, 0, 255};
        int colorR2[4] = {150, 0, 0, 255};
        
        if (g_bInhibitorActive[client])
            TE_SetupBeamRingPoint(pos, 10.0, 400.0, beam, glow, 0, 15, 0.6, 25.0, 0.0, colorO2, 0, 0);
        else
            TE_SetupBeamRingPoint(pos, 10.0, 300.0, beam, glow, 0, 15, 0.6, 25.0, 0.0, colorR2, 0, 0);
        TE_SendToAll();
    }
    return Plugin_Stop;
}

public Action T_ShadowBlastRing3(Handle timer, int clientRef)
{
    int client = EntRefToEntIndex(clientRef);
    if (client > 0 && IsValidEntity(client))
    {
        float pos[3]; GetClientAbsOrigin(client, pos);
        int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
        int glow = PrecacheModel("materials/sprites/glow01.vmt");
        
        int colorO3[4] = {255, 200, 0, 255};
        int colorR3[4] = {100, 0, 0, 255};
        
        if (g_bInhibitorActive[client])
            TE_SetupBeamRingPoint(pos, 10.0, 200.0, beam, glow, 0, 15, 0.4, 20.0, 0.0, colorO3, 0, 0);
        else
            TE_SetupBeamRingPoint(pos, 10.0, 150.0, beam, glow, 0, 15, 0.4, 20.0, 0.0, colorR3, 0, 0);
        TE_SendToAll();
    }
    return Plugin_Stop;
}

// ==============================================================
// FUNCIÓN DE DESINTEGRACIÓN (Vaporizer Effect)
// ==============================================================

void Shadow_DissolveEntity(int victim)
{
    if (!IsValidEntity(victim)) return;
    
    int dissolver = CreateEntityByName("env_entity_dissolver");
    if (dissolver == -1) return;
    
    DispatchKeyValue(dissolver, "target", "shadow_dissolve_targ");
    DispatchKeyValue(dissolver, "magnitude", "220");
    DispatchKeyValue(dissolver, "speed", "3");
    DispatchSpawn(dissolver);
    
    DispatchKeyValue(victim, "targetname", "shadow_dissolve_targ");
    AcceptEntityInput(dissolver, "Dissolve", victim, victim);
    
    SetVariantString("OnUser1 !self:Kill::1.0:-1");
    AcceptEntityInput(dissolver, "AddOutput");
    AcceptEntityInput(dissolver, "FireUser1");
}

// Función para crear luces dinámicas temporales
void Shadow_CreateTempLight(float pos[3], int r, int g, int b, float duration, float distance)
{
    int light = CreateEntityByName("light_dynamic");
    if (light == -1) return;
    
    char sColor[16];
    Format(sColor, sizeof(sColor), "%i %i %i 255", r, g, b);
    DispatchKeyValue(light, "_light", sColor);
    DispatchKeyValueFloat(light, "distance", distance);
    DispatchKeyValueFloat(light, "spotlight_radius", 200.0);
    DispatchKeyValue(light, "style", "6"); // Estilo pulsante
    DispatchSpawn(light);
    TeleportEntity(light, pos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(light, "TurnOn");
    
    char input[64];
    Format(input, sizeof(input), "OnUser1 !self:TurnOff::%f:-1", duration - 0.1);
    SetVariantString(input); AcceptEntityInput(light, "AddOutput");
    Format(input, sizeof(input), "OnUser1 !self:Kill::%f:-1", duration);
    SetVariantString(input); AcceptEntityInput(light, "AddOutput");
    AcceptEntityInput(light, "FireUser1");
}

// ==============================================================
// PUENTES DE COMPATIBILIDAD CON EL MANAGER GENERAL (NO TOCAR)
// ==============================================================

public void Shadow_OnPlayerRunCmd_Proxy(int client, int &buttons)
{
}

// =====================================================================
// =====================================================================
//  v6.0-OM — AVATAR ESPEJO SHADOW.MDL (el 7o avatar del suite: patron
//  Rouge v10.2 / Knuckles v75 / Amy v95). copia R (la que ven los
//  DEMAS, parentada o por TP según tails_avatar_tp) + copia L (la que
//  ve el dueño, contra-rotada con sus eye angles) + cuerpo del
//  survivor oculto (RENDER_NONE) + FSM 10 Hz + RESOLUCION DE
//  SECUENCIAS POR PROBE (receta Amy v92: shadow.mdl no trae tabla
//  documentada — cada estado tiene una CADENA de candidatos y gana el
//  primer nombre que exista en el modelo) + tinte ROJO con los Anillos
//  Inhibidores + ragdoll de muerte 15s + filtro anti-corpse 2s +
//  ADOPCION de huerfanos (v72-OM: esta FSM es la ÚNICA creadora de
//  props con su nombre de avatar).
// =====================================================================
// =====================================================================

// =====================================================================
// RESOLUCION DE SECUENCIAS POR PROBE (receta Amy v92): SourcePawn no
// trae LookupSequence — se dispara SetAnimation(nombre) y se lee
// m_nSequence: si el índice CAMBIO, el nombre existe en el .mdl. Se
// resuelve UNA vez por mapa (al nacer el primer avatar, todo dentro
// del mismo frame — el cliente solo ve el resultado final).
// =====================================================================
void Shadow_ResolveTry(int av, int state, const char[] name)
{
    if (g_bShadowSeqOK[state]) return;
    if (!HasEntProp(av, Prop_Send, "m_nSequence")) return;

    int before = GetEntProp(av, Prop_Send, "m_nSequence");
    SetVariantString(name);
    AcceptEntityInput(av, "SetAnimation");
    int after = GetEntProp(av, Prop_Send, "m_nSequence");

    if (after != before)
    {
        strcopy(g_sShadowSeq[state], sizeof(g_sShadowSeq[]), name);
        g_bShadowSeqOK[state] = true;
    }
}

void Shadow_ResolveSeqs(int av)
{
    if (g_bShadowSeqResolved) return;
    g_bShadowSeqResolved = true;

    // cadena de candidatos por estado (nombres del lua GMod + variantes)
    for (int st = 0; st < SHADOW_ANIM_COUNT; st++)
    {
        for (int c = 0; c < SHADOW_SEQ_MAX_CAND; c++)
        {
            if (g_sShadowSeqCand[st][c][0] == '\0') break;
            Shadow_ResolveTry(av, st, g_sShadowSeqCand[st][c]);
            if (g_bShadowSeqOK[st]) break;
        }
    }

    // 2a pasada del idle (truco Amy v92: si el default del modelo YA
    // era idle, la primera prueba no movió el índice — ahora el actual
    // es otro y si "idle" existe, se registra)
    Shadow_ResolveTry(av, SHADOW_ST_IDLE, "idle");

    // fallbacks de las variantes que el modelo no traiga: la base
    // cubre el hueco (nunca T-pose)
    int fallbacks[SHADOW_ANIM_COUNT];
    for (int fb = 0; fb < SHADOW_ANIM_COUNT; fb++) fallbacks[fb] = -1;
    fallbacks[SHADOW_ST_IDLE_LOW]    = SHADOW_ST_IDLE;
    fallbacks[SHADOW_ST_WALK_LOW]    = SHADOW_ST_WALK;
    fallbacks[SHADOW_ST_RUN_LOW]     = SHADOW_ST_RUN;
    fallbacks[SHADOW_ST_DOWNED_IDLE] = SHADOW_ST_IDLE;
    fallbacks[SHADOW_ST_DOWNED_WALK] = SHADOW_ST_WALK;
    fallbacks[SHADOW_ST_HOVER]       = SHADOW_ST_FALL;
    fallbacks[SHADOW_ST_SNAP]        = SHADOW_ST_JUMP;
    fallbacks[SHADOW_ST_BLAST]       = SHADOW_ST_JUMP;

    for (int s = 0; s < SHADOW_ANIM_COUNT; s++)
    {
        if (g_bShadowSeqOK[s] || fallbacks[s] < 0) continue;
        if (g_bShadowSeqOK[fallbacks[s]])
        {
            strcopy(g_sShadowSeq[s], sizeof(g_sShadowSeq[]), g_sShadowSeq[fallbacks[s]]);
            g_bShadowSeqOK[s] = true;
        }
    }
}

// la secuencia a usar para un estado (con triple red de seguridad)
void Shadow_SeqFor(int state, char out[24])
{
    if (g_bShadowSeqOK[state])
        strcopy(out, 24, g_sShadowSeq[state]);
    else if (g_bShadowSeqOK[SHADOW_ST_IDLE])
        strcopy(out, 24, g_sShadowSeq[SHADOW_ST_IDLE]);
    else
        strcopy(out, 24, "idle");
}

// =====================================================================
// CREACION / MUERTE DE LAS COPIAS (receta Rouge v10.2 textual)
// =====================================================================
int Shadow_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
{
    int av = CreateEntityByName("prop_dynamic_override");
    if (av <= 0 || !IsValidEntity(av)) return 0;

    DispatchKeyValue(av, "model", model);
    DispatchKeyValue(av, "targetname", targetname);
    DispatchKeyValue(av, "solid", "0");
    DispatchKeyValue(av, "disableshadows", "1");
    DispatchSpawn(av);

    float pos[3], ang[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    ang[0] = 0.0;                          // pitch NUNCA
    ang[2] = 0.0;                          // roll NUNCA
    g_fShadowBodyYaw[client]  = ang[1];
    g_fShadowYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fShadowBodyYaw[client], loc);

    if (!tpMode)
    {
        // parentado (modo Tails default: el motor mueve la posición,
        // cero delay de red, anims suaves; aquí solo se escriben angulos)
        SetVariantString("!activator");
        AcceptEntityInput(av, "SetParent", client);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", loc);
    }

    for (int k = 0; k < 3; k++)
    {
        g_fShadowSmLoc[client][k]  = loc[k];
        g_fShadowSmLocL[client][k] = loc[k];
    }
    g_bShadowSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// v72-OM (adopción): un prop con NUESTRO nombre que esta FSM no rastrea
// es un huerfano por definición — muere en el instante del montaje.
bool Shadow_IsMyAvatarRef(int ref)
{
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iShadowAvatar[i] == ref) return true;
        if (g_iShadowAvatarL[i] == ref) return true;
    }
    return false;
}

void Shadow_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "shadow_avatar_om", "shadow_avatar_om_l" };
    static const char sClasses[][] = { "prop_dynamic_override", "prop_dynamic" };
    int ghosts[8];
    int ng = 0;
    char nameBuf[64];

    // primero se recolecta, luego se mata — el FindEntityByClassname
    // tras un Kill a mitad de loop es tierra de nadie en L4D2
    for (int c = 0; c < sizeof(sClasses); c++)
    {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, sClasses[c])) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            GetEntPropString(ent, Prop_Data, "m_iName", nameBuf, sizeof(nameBuf));
            if (nameBuf[0] == '\0') continue;

            for (int n = 0; n < sizeof(sGhostNames); n++)
            {
                if (!StrEqual(nameBuf, sGhostNames[n], false)) continue;
                if (Shadow_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
                if (ng < sizeof(ghosts)) ghosts[ng++] = EntIndexToEntRef(ent);
                break;
            }
        }
    }

    for (int g = 0; g < ng; g++)
    {
        int e = EntRefToEntIndex(ghosts[g]);
        if (e > 0 && IsValidEntity(e)) AcceptEntityInput(e, "Kill");
    }

    if (ng > 0)
        PrintToServer("[Shadow v6.0-OM] Adopción del montaje: %d huerfano(s) del avatar eliminado(s).", ng);
}

// Monta el avatar completo (R + L + cuerpo oculto). pulsePause SOLO para
// montajes de ciclo de vida (spawn/selección/reparación tardia de la FSM).
void Shadow_CreateAvatar(int client, bool pulsePause = true)
{
    if (!g_bShadowModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;

    // v72-OM (reemplazo limpio): si este cliente ya tenía un R o L vivo
    // (montaje doble por orden raro de eventos), muere AQUÍ enterito.
    {
        int oldR = EntRefToEntIndex(g_iShadowAvatar[client]);
        if (g_iShadowAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Shadow_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iShadowAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iShadowAvatarL[client]);
        if (g_iShadowAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Shadow_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iShadowAvatarL[client] = 0;
    }

    // v72-OM: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje.
    Shadow_KillGhostAvatarProps();

    int av = Shadow_CreateAvatarProp(client, SHADOW_OM_MODEL, SHADOW_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    // v6.0: resolver las secuencias contra el .mdl REAL (probe Amy v92,
    // UNA vez por mapa — el primer avatar nace resolviendo para todos)
    Shadow_ResolveSeqs(av);

    char seqIdle[24];
    Shadow_SeqFor(SHADOW_ST_IDLE, seqIdle);
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");
    g_iShadowAnimState[client] = 0;

    SDKHook(av, SDKHook_SetTransmit, Shadow_TransmitAvatarR);

    g_iShadowAvatarL[client] = 0;
    Shadow_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iShadowBodyRender[client] = view_as<int>(curMode);
    else if (g_iShadowBodyRender[client] == -1)
        g_iShadowBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    // v6.0: si los Anillos Inhibidores están activos, el tinte ROJO
    // sigue encendido tras el remontaje
    if (g_bInhibitorActive[client])
        Shadow_AvatarSetColor(client, 255, 80, 80, 255);

    g_iShadowAvatar[client] = EntIndexToEntRef(av);

    // per-tick: angulos locales (contra-rotación del parent)
    SDKHook(client, SDKHook_PostThink, Shadow_AvatarFollow);

    // PULSO DE PAUSA en cada montaje de ciclo de vida (la misma infra
    // sv_pausable del suite; convar tails_pausefix manda para TODOS los
    // avatares — es UN solo sistema, 7o avatar del suite)
    if (pulsePause)
        Tails_PauseFix_Trigger(client);
}

void Shadow_CreateAvatarL(int client)
{
    if (!g_bShadowModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iShadowAvatar[client] == 0) return;

    int av = Shadow_CreateAvatarProp(client, SHADOW_OM_MODEL, SHADOW_AVATAR_NAME_L);
    if (av == 0) return;

    char seqIdle[24];
    Shadow_SeqFor(SHADOW_ST_IDLE, seqIdle);
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Shadow_TransmitAvatarL);

    g_iShadowAvatarL[client] = EntIndexToEntRef(av);
}

void Shadow_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iShadowAvatarL[client]);
    if (g_iShadowAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Shadow_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iShadowAvatarL[client] = 0;
}

// Mata las copias R+L y devuelve el cuerpo. SIN desenganchar el follow
// (lo hace Shadow_KillAvatar).
void Shadow_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    Shadow_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iShadowAvatar[client]);
    if (g_iShadowAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Shadow_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iShadowAvatar[client] = 0;
    g_iShadowAnimState[client] = -1;

    // devolver el cuerpo (spectate/revive/cambio de personaje)
    if (IsClientInGame(client) && g_iShadowBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iShadowBodyRender[client]));
        g_iShadowBodyRender[client] = -1;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Shadow_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Shadow_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Shadow_AvatarFollow);
}

// Transmit filters (patron Rouge/Sonic/Metal): la R no la ve su dueño
// (tiene su L), la L la ve SOLO su dueño.
public Action Shadow_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iShadowAvatar[i] != 0 && EntRefToEntIndex(g_iShadowAvatar[i]) == entity)
        {
            if (client == i && g_iShadowAvatarL[i] != 0
                && EntRefToEntIndex(g_iShadowAvatarL[i]) > 0)
                return Plugin_Handled;   // el dueño tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

public Action Shadow_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iShadowAvatarL[i] != 0 && EntRefToEntIndex(g_iShadowAvatarL[i]) == entity)
        {
            if (client == i) return Plugin_Continue;   // el dueño si
            return Plugin_Handled;                     // nadie más
        }
    }
    return Plugin_Continue;
}

// FOLLOW PER-TICK (receta Rouge: yaw suave con deadband 3 grados,
// contra-rotación amortiguada, reloj vivo, copia L contra los eye
// angles del dueño; la R por TP en modo tp).
public void Shadow_AvatarFollow(int client)
{
    if (g_iShadowAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Shadow_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    // ---- yaw objetivo: dirección REAL del movimiento ----
    float yawObj = g_fShadowBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fShadowBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    // ---- giro suave hacia el objetivo (~900 grados/s) ----
    float now = GetEngineTime();
    float dt  = now - g_fShadowYawLastT[client];
    g_fShadowYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fShadowBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fShadowBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bShadowSmSnap[client];
    GetClientAbsAngles(client, par);
    float yawPuppet = g_fShadowBodyYaw[client];

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iShadowAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        if (Tails_AvatarTPOn())
        {
            // R POR TP: TeleportEntity por tick en pose mundo + reloj
            // vivo, SIN EF_NOINTERP -> los clientes de los demas la
            // INTERPOLAN = suave sin depender de la pausa
            float posTP[3], angTP[3];
            GetClientAbsOrigin(client, posTP);
            angTP[0] = 0.0;                      // pitch NUNCA
            angTP[1] = yawPuppet;
            angTP[2] = 0.0;                      // roll NUNCA
            TeleportEntity(av, posTP, angTP, NULL_VECTOR);
            Tails_MarkInterp(av);
        }
        else
        {
            Tails_AvatarLocalAngles(par[0], par[1], yawPuppet, loc);
            loc[1] = Tails_UnwrapYaw(g_fShadowSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fShadowSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fShadowSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }

    // ---- copia L: contra-rotada contra los EYE del dueño ----
    if (g_iShadowAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iShadowAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3], locL[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], yawPuppet, locL);
            locL[1] = Tails_UnwrapYaw(g_fShadowSmLocL[client][1], locL[1]);
            Tails_ExpDamp(locL, g_fShadowSmLocL[client], 0.05, dt, snap);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fShadowSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
    g_bShadowSmSnap[client] = false;
}

// FSM de 10 Hz: montaje / auto-reparación / muerte del avatar (patron
// T_RougeAvatarThink)
public Action T_ShadowAvatarThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Shadow_KillAvatar(i); continue; }

        bool esShadowVivo = (g_iPlayerCharIdx[i] == SHADOW_INDEX
                           && IsPlayerAlive(i) && GetClientTeam(i) == 2);

        // incap = fuera (defensa anti terceros)
        if (esShadowVivo && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            esShadowVivo = false;

        // ---- montaje ----
        if (g_iShadowAvatar[i] == 0)
        {
            if (esShadowVivo && g_cvShadowAvatar != null && g_cvShadowAvatar.BoolValue
                && g_bShadowModelOK)
            {
                Shadow_CreateAvatar(i);
            }
            continue;
        }

        // quitar avatar si dejó de ser un Shadow survivor vivo de pie
        if (!esShadowVivo)
        {
            Shadow_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iShadowAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iShadowAvatar[i] = 0;
            g_iShadowAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (el motor lo resetea al
        // cambiar de capítulo/rescue: fix Tails v5.4)
        if (g_iShadowBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparación de la copia L (montaje tardio: pulso también)
        if (g_iShadowAvatarL[i] == 0 && g_iShadowAvatar[i] != 0)
        {
            Shadow_CreateAvatarL(i);
            if (g_iShadowAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // ---- FSM de animación ----
        av = EntRefToEntIndex(g_iShadowAvatar[i]);
        if (g_iShadowAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Shadow_AvatarUpdate(i, av, now);
    }
    return Plugin_Continue;
}

// =====================================================================
// FSM DE ANIMACION — prioridades: incap (DownedIdle/DownedWalk) ->
// aire (HOVER con SPACE mantenido [la pasiva Hover Shoes manda] /
// jump subiendo / fall cayendo) -> suelo (idle/walk/run con variantes
// lowhealth de HP<=50 — el umbral de los Anillos Inhibidores).
// =====================================================================
void Shadow_AvatarUpdate(int client, int av, float now)
{
    // lock de one-shot en curso (Snap/Blast)
    if (now < g_fShadowAnimLock[client]) return;

    int state;
    float rate = 1.0;

    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
    {
        // DownedIdle/DownedWalk
        state = (Shadow_Speed2D(client) > 40.0) ? SHADOW_ST_DOWNED_WALK : SHADOW_ST_DOWNED_IDLE;
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        int btn = GetClientButtons(client);
        if (btn & IN_JUMP)
        {
            // HOVER SHOES: SPACE mantenido en el aire = su pose propia
            // (si el .mdl la trae; si no, "fall" por el fallback)
            state = SHADOW_ST_HOVER;
        }
        else
        {
            // AIRE: sube = jump; cae = fall — con la ventana del jump
            float vel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            if (vel[2] > 40.0)
            {
                state = SHADOW_ST_JUMP;
            }
            else
            {
                bool jumpLive = false;
                if (g_iShadowAnimState[client] == SHADOW_ST_JUMP)
                {
                    float jt = now - g_fShadowJumpStart[client];
                    if (jt < 0.5)      jumpLive = true;
                    else if (jt < 1.5 && !Shadow_JumpAnimDone(av)) jumpLive = true;
                }
                state = jumpLive ? SHADOW_ST_JUMP : SHADOW_ST_FALL;
            }
        }
    }
    else if (g_iShadowAnimState[client] == SHADOW_ST_JUMP && !Shadow_JumpAnimDone(av)
             && now - g_fShadowJumpStart[client] < 0.5)
    {
        // FL_ONGROUND parpadea al saltar rozando escalones
        state = SHADOW_ST_JUMP;
    }
    else
    {
        // SUELO: idle/walk/run (lowhealth <= 50, el umbral de los Anillos)
        bool low = (GetClientHealth(client) <= 50);
        float s = Shadow_Speed2D(client);
        if (s < 40.0)
            state = low ? SHADOW_ST_IDLE_LOW : SHADOW_ST_IDLE;
        else if (s < 150.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = low ? SHADOW_ST_WALK_LOW : SHADOW_ST_WALK;
            rate = 1.0;   // rate 1 constante del framework GMod
        }
        else
        {
            state = low ? SHADOW_ST_RUN_LOW : SHADOW_ST_RUN;
            rate = 1.32 * (s / 450.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6)  rate = 3.6;
        }
    }

    if (state != g_iShadowAnimState[client])
    {
        // el t0 del jump para su ventana (receta Rouge/Sonic/Knuckles)
        if (state == SHADOW_ST_JUMP) g_fShadowJumpStart[client] = now;

        char seqUse[24];
        Shadow_SeqFor(state, seqUse);

        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iShadowAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iShadowAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                // el variant es de UN SOLO USO — re-armarlo
                SetVariantString(seqUse);
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iShadowAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iShadowAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iShadowAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

float Shadow_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// el one-shot del jump termino? (m_flCycle del prop — la misma sonda
// del Rouge_JumpAnimDone / Knux_JumpAnimDone)
bool Shadow_JumpAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return true;
}

// ONE-SHOT de habilidad sobre las DOS copias (Chaos Snap / Chaos
// Blast). Bloquea la FSM mientras corre.
void Shadow_AvatarOneShot(int client, int stIdx, float lock)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iShadowAvatar[client] == 0) return;

    char seqUse[24];
    Shadow_SeqFor(stIdx, seqUse);

    int av = EntRefToEntIndex(g_iShadowAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
    }
    if (g_iShadowAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iShadowAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetVariantString(seqUse);
            AcceptEntityInput(avL, "SetAnimation");
        }
    }
    g_iShadowAnimState[client] = stIdx;
    g_fShadowAnimLock[client] = GetEngineTime() + lock;
}

// =====================================================================
// TINTES DEL AVATAR — v6.0: los Anillos Inhibidores lo encienden de
// ROJO mientras la pasiva está activa (visual del "rage" del GMod).
// =====================================================================
void Shadow_AvatarSetColor(int client, int r, int g, int b, int a)
{
    int av = EntRefToEntIndex(g_iShadowAvatar[client]);
    if (g_iShadowAvatar[client] != 0 && av > 0 && IsValidEntity(av))
        SetEntityRenderColor(av, r, g, b, a);
    int avL = EntRefToEntIndex(g_iShadowAvatarL[client]);
    if (g_iShadowAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
        SetEntityRenderColor(avL, r, g, b, a);
}

void Shadow_AvatarTintReset(int client)
{
    Shadow_AvatarSetColor(client, 255, 255, 255, 255);
}

// =====================================================================
// MUERTE DEL AVATAR — ragdoll shadow.mdl + filtro anti-corpse
// (receta Rouge v10.2 / Knuckles v75 / Metal v5.0)
// =====================================================================
void Shadow_SpawnDeathRagdoll(int client)
{
    if (!g_bShadowModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", SHADOW_OM_MODEL);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    CreateTimer(15.0, T_ShadowDeathRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_ShadowDeathRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Filtro anti-ragdoll (patron Rouge/Sonic/Knuckles — enrutado por el
// OnEntityCreated central de Rouge.inc, que despacha a este modulo)
public void Shadow_CheckDeathRagdoll(any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent <= 0 || !IsValidEntity(ent)) return;

    char model[96];
    GetEntPropString(ent, Prop_Data, "m_ModelName", model, sizeof(model));
    if (strncmp(model, "models/survivors/", 17) != 0) return;

    float now = GetEngineTime();
    float o[3];
    GetEntPropVector(ent, Prop_Data, "m_vecOrigin", o);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_fShadowDeathHideUntil[i] == 0.0 || now >= g_fShadowDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_vShadowDeathOrigin[i]) < 200.0)
        {
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}

// v3.77.49: dispatch del OnEntityCreated central de Rouge.inc — la
// ventana anti-corpse de las muertes del Shadow con avatar
public void Shadow_OnEntityCreated(int entity, const char[] classname)
{
    if (StrEqual(classname, "prop_ragdoll")
        || StrEqual(classname, "prop_physics")
        || StrEqual(classname, "prop_physics_override")
        || StrEqual(classname, "prop_dynamic")
        || StrEqual(classname, "prop_dynamic_override")
        || StrEqual(classname, "cs_ragdoll")
        || StrEqual(classname, "survivor_death_model"))
    {
        float nowOM = GetEngineTime();
        for (int i = 1; i <= MaxClients; i++)
        {
            if (g_fShadowDeathHideUntil[i] == 0.0 || nowOM >= g_fShadowDeathHideUntil[i])
                continue;
            RequestFrame(Shadow_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }
}

// Limpieza generica (OnPluginEnd del manager): mata el avatar y
// devuelve el cuerpo. SIN ragdoll (el plugin se descarga, no murió).
public void Shadow_OnPlayerDeath(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iPlayerCharIdx[client] != SHADOW_INDEX) return;
    Shadow_KillAvatar(client);
    Shadow_ResetState(client);
}

// v6.0: refs a cero al cerrar el mapa (las entidades murieron con el;
// el timer de la FSM es NO_MAPCHANGE y muere solo)
public void Shadow_OnMapEnd()
{
    delete g_hShadowAvatarThink;
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iShadowAvatar[i] = 0;
        g_iShadowAvatarL[i] = 0;
        g_iShadowAnimState[i] = -1;
        g_fShadowDeathHideUntil[i] = 0.0;
    }
}
