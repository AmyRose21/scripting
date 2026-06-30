/*
 * ======================================================
 *  [MODULO] Rouge the Bat - Spy & Treasure Hunter v7.0 (Tactical Rework)
 *
 *  v7.0 CHANGES:
 *   - FIX CRITICO: El "charco de acido" del Cebo Quimico ahora HACE DANO real.
 *     Se spawnea un insect_swarm nativo (entidad del spit del Spitter) que
 *     genera el efecto visual verde persistente. Adicionalmente se lanza un
 *     timer de dano por tick paralelo como respaldo robusto para asegurar
 *     que SIEMPRE haya dano a los infectados en el area, sin depender de
 *     gamedata externa ni signatures.
 *   - Reemplazo de g_bBombDetonated[2048] por ArrayList g_hRougeActiveBombs
 *     (mas eficiente, sin arrays gigantes).
 *   - Validaciones estrictas en todos los callbacks (client, entity, ref).
 *   - Cleanup correcto de DataPacks en todos los timers.
 *   - TIMER_FLAG_NO_MAPCHANGE en todos los timers repetitivos.
 *   - Verificacion de null en ConVars antes de usarlas.
 *   - Documentacion completa de cada funcion.
 *   - Mejor manejo de estados de cliente en reset.
 *
 *  Rol: Spy / Treasure Hunter / Crowd Control
 *  Pasivas: Bat Glide (planeo con SHIFT en el aire), Inmunidad a dano de caida,
 *           Treasure Vision (resalta items e infectados heridos en rosa).
 *  Habilidad 1 (Z): Cebo Quimico - granada rosa que explota y deja charco de acido real.
 *  Habilidad 2 (X): Bat Bomb Spray - 3 granadas rosa en abanico.
 * ======================================================
 */

#if defined _Rouge_included
    #endinput
#endif
#define _Rouge_included

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
#if !defined ROUGE_INDEX
    #define ROUGE_INDEX 6
#endif

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// =======================
// Constantes y Audio
// =======================
#define ROUGE_SND_KICK_HIT  "weapons/katana/melee/katana_hit_infected2.wav"
#define ROUGE_SND_THROW     "weapons/molotov/molotov_throw.wav"
#define ROUGE_SND_BEEP      "buttons/button16.wav"
#define ROUGE_SND_BOOM      "weapons/hegrenade/explode4.wav"
#define ROUGE_SND_ACID      "player/spitter/voice/attack/spitter-spit2.wav"
#define ROUGE_MODEL_BOMB    "models/w_models/weapons/w_eq_pipebomb.mdl"

// Configuracion del charco de acido (Habilidad 1)
#define ROUGE_ACID_RADIUS       220.0   // Radio de dano del charco
#define ROUGE_ACID_DURATION     8.0     // Duracion total del charco (segundos)
#define ROUGE_ACID_TICK         0.5     // Intervalo de dano por tick
#define ROUGE_ACID_DMG_SPEC     12.0    // Dano por tick a infectados especiales
#define ROUGE_ACID_DMG_COMM     80.0    // Dano por tick a infectados comunes
#define ROUGE_ACID_DMG_TANK     8.0     // Dano por tick al Tank

#define ROUGE_BAIT_FUSE         2.5     // Tiempo del fuse del cebo
#define ROUGE_BAIT_RADIUS       250.0   // Radio de la explosion inicial

// Configuracion de la Bat Bomb (Habilidad 2)
#define ROUGE_BOMB_MAX_ACTIVE   32      // Maximo de bombas activas simultaneas

// =======================
// Variables Globales
// =======================
float g_fRougeBaitCooldown[MAXPLAYERS + 1];
float g_fRougeBombCooldown[MAXPLAYERS + 1];

bool g_bRougeGliding[MAXPLAYERS + 1];

// Trackeo de bombas activas (reemplaza al g_bBombDetonated[2048])
ArrayList g_hRougeActiveBombs;

// Trackeo de charcos de acido activos (entidades insect_swarm)
ArrayList g_hRougeAcidPools;

// Timers
Handle g_hRougeVisionTimer = INVALID_HANDLE;

// Sprites
int g_iRougeGlowSprite = -1;
int g_iRougeBeamSprite = -1;

// v7.1: SDKCall para crear spit nativo del Spitter (sistema de Silvers)
Handle g_hRougeSDK_Spit = null;
bool g_bRougeAcidSpawn = false;  // Flag para detectar el proximo insect_swarm creado

// ConVars
ConVar g_cvRougeBaitCD, g_cvRougeBaitDamage;
ConVar g_cvRougeBombDamage, g_cvRougeBombRadius, g_cvRougeBombTimer, g_cvRougeBombCD;
ConVar g_cvRougeVisionRange;

#define Rouge_IsValidClient(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))
#define Rouge_IsValidEntity(%1) (IsValidEntity(%1) && (%1) != INVALID_ENT_REFERENCE)

// =======================
// Inicializacion
// =======================

public void Rouge_OnPluginStart()
{
    // Habilidad 1: Cebo Quimico
    g_cvRougeBaitCD       = CreateConVar("rouge_bait_cooldown", "12.0", "Cooldown del Cebo Quimico", _, true, 0.0, true, 120.0);
    g_cvRougeBaitDamage   = CreateConVar("rouge_bait_damage", "300.0", "Dano de la explosion inicial del cebo", _, true, 0.0, true, 5000.0);

    // Habilidad 2: Bat Bomb Spray
    g_cvRougeBombDamage   = CreateConVar("rouge_bomb_damage", "600.0", "Dano de la explosion de la Bat Bomb", _, true, 0.0, true, 5000.0);
    g_cvRougeBombRadius   = CreateConVar("rouge_bomb_radius", "350.0", "Radio de explosion de la Bat Bomb", _, true, 50.0, true, 1500.0);
    g_cvRougeBombTimer    = CreateConVar("rouge_bomb_time", "1.5", "Tiempo para detonar si no toca a nadie", _, true, 0.1, true, 10.0);
    g_cvRougeBombCD       = CreateConVar("rouge_bomb_cooldown", "20.0", "Cooldown de la Bat Bomb", _, true, 0.0, true, 120.0);

    // Pasiva: Treasure Vision
    g_cvRougeVisionRange  = CreateConVar("rouge_vision_range", "1200.0", "Rango de vision de items e infectados", _, true, 100.0, true, 5000.0);

    // v7.1: Cargar gamedata para SDKCall de CSpitterProjectile_Create
    Rouge_LoadGamedata();

    // Comandos
    RegConsoleCmd("sm_rouge_kick", Command_RougeKick); // Mantiene el nombre por compatibilidad
    RegConsoleCmd("sm_rouge_bomb", Command_RougeBomb);

    // Hooks de eventos
    HookEvent("player_spawn", Rouge_Event_PlayerSpawn);
    HookEvent("player_death", Rouge_Event_PlayerDeath);
    HookEvent("round_start", Rouge_Event_RoundStart);

    // Inicializar ArrayLists
    g_hRougeActiveBombs = new ArrayList();
    g_hRougeAcidPools   = new ArrayList();

    // Timer de vision (repetitivo, no se pierde al cambiar de mapa)
    if (g_hRougeVisionTimer != INVALID_HANDLE)
    {
        KillTimer(g_hRougeVisionTimer);
        g_hRougeVisionTimer = INVALID_HANDLE;
    }
    g_hRougeVisionTimer = CreateTimer(1.0, T_RougeVisionThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    AutoExecConfig(true, "Rouge_Abilities");

    // Carga tardia: hookear clientes ya conectados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            Rouge_OnClientPutInServer(i);
        }
    }
}

// v7.1: Carga el gamedata para el SDKCall de CSpitterProjectile_Create
// Requiere el archivo gamedata/rouge_abilities.txt
void Rouge_LoadGamedata()
{
    Handle hGameData = LoadGameConfigFile("rouge_abilities");
    if (hGameData == null)
    {
        PrintToServer("[Rouge] WARNING: No se pudo cargar gamedata/rouge_abilities.txt");
        PrintToServer("[Rouge] WARNING: El charco de acido nativo NO estara disponible.");
        PrintToServer("[Rouge] WARNING: Se usara el sistema de respaldo (timer de dano).");
        g_hRougeSDK_Spit = null;
        return;
    }

    StartPrepSDKCall(SDKCall_Static);
    if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CSpitterProjectile_Create"))
    {
        PrintToServer("[Rouge] WARNING: Signature CSpitterProjectile_Create no encontrada en gamedata.");
        delete hGameData;
        g_hRougeSDK_Spit = null;
        return;
    }
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
    PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
    PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
    g_hRougeSDK_Spit = EndPrepSDKCall();

    if (g_hRougeSDK_Spit == null)
    {
        PrintToServer("[Rouge] WARNING: No se pudo preparar el SDKCall de CSpitterProjectile_Create.");
    }
    else
    {
        PrintToServer("[Rouge] OK: SDKCall de CSpitterProjectile_Create cargado correctamente.");
    }

    delete hGameData;
}

// v7.1: Detecta cuando el motor crea un insect_swarm (charco de spit)
// Esto nos permite trackear el charco nativo que crea el SDKCall
public void OnEntityCreated(int entity, const char[] classname)
{
    if (entity <= 0 || entity > 2048) return;

    // Si estamos esperando un insect_swarm (flag activado tras SDKCall)
    if (g_bRougeAcidSpawn)
    {
        if (strcmp(classname, "insect_swarm") == 0)
        {
            // Trackear en ArrayList
            if (g_hRougeAcidPools != null)
                g_hRougeAcidPools.Push(EntIndexToEntRef(entity));

            g_bRougeAcidSpawn = false;

            // Programar destruccion del charco al final de la duracion
            CreateTimer(ROUGE_ACID_DURATION, T_RougeAcidCleanup, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
        }
    }
}

public void Rouge_OnMapStart()
{
    // Precache de sonidos
    PrecacheSound(ROUGE_SND_KICK_HIT, true);
    PrecacheSound(ROUGE_SND_THROW, true);
    PrecacheSound(ROUGE_SND_BEEP, true);
    PrecacheSound(ROUGE_SND_BOOM, true);
    PrecacheSound(ROUGE_SND_ACID, true);

    // Precache de modelos
    PrecacheModel(ROUGE_MODEL_BOMB, true);
    g_iRougeGlowSprite = PrecacheModel("materials/sprites/glow01.vmt", true);
    g_iRougeBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);

    // Reset de estados por cliente
    for (int i = 1; i <= MaxClients; i++)
        Rouge_ResetState(i);

    // Limpiar ArrayLists
    if (g_hRougeActiveBombs != null) g_hRougeActiveBombs.Clear();
    if (g_hRougeAcidPools != null)   g_hRougeAcidPools.Clear();
}

public void Rouge_OnMapEnd()
{
    if (g_hRougeVisionTimer != INVALID_HANDLE)
    {
        KillTimer(g_hRougeVisionTimer);
        g_hRougeVisionTimer = INVALID_HANDLE;
    }

    if (g_hRougeActiveBombs != null) g_hRougeActiveBombs.Clear();
    if (g_hRougeAcidPools != null)   g_hRougeAcidPools.Clear();
}

// =======================
// Gestion de Estados
// =======================

public void Rouge_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;

    SDKUnhook(client, SDKHook_OnTakeDamage, Rouge_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Rouge_OnTakeDamage);

    SDKUnhook(client, SDKHook_PreThink, Rouge_PreThink);
    SDKHook(client, SDKHook_PreThink, Rouge_PreThink);
}

public void Rouge_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // Limpiar bombas y charcos activos al iniciar ronda
    if (g_hRougeActiveBombs != null) g_hRougeActiveBombs.Clear();
    if (g_hRougeAcidPools != null)   g_hRougeAcidPools.Clear();
}

public void Rouge_Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client)) return;

    if (g_iPlayerCharIdx[client] == ROUGE_INDEX)
    {
        Rouge_ResetState(client);
        // Re-hookear por seguridad
        SDKUnhook(client, SDKHook_OnTakeDamage, Rouge_OnTakeDamage);
        SDKHook(client, SDKHook_OnTakeDamage, Rouge_OnTakeDamage);
        SDKUnhook(client, SDKHook_PreThink, Rouge_PreThink);
        SDKHook(client, SDKHook_PreThink, Rouge_PreThink);
    }
}

public void Rouge_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && IsClientInGame(client))
    {
        Rouge_ResetState(client);
    }
}

void Rouge_ResetState(int client)
{
    if (client < 0 || client > MaxClients) return;

    g_bRougeGliding[client]     = false;
    g_fRougeBaitCooldown[client] = 0.0;
    g_fRougeBombCooldown[client] = 0.0;

    if (IsClientInGame(client))
    {
        SetEntityRenderColor(client, 255, 255, 255, 255);
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
        SetEntProp(client, Prop_Send, "m_CollisionGroup", 5);

        if (!GetEntProp(client, Prop_Send, "m_isIncapacitated"))
        {
            SetEntityMoveType(client, MOVETYPE_WALK);
            float stop[3] = {0.0, 0.0, 0.0};
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, stop);
        }
    }
}

// =======================
// PASIVAS: BAT GLIDE & FALL IMMUNITY
// =======================

public void Rouge_PreThink(int client)
{
    if (!Rouge_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return;

    // Cancelar planeo si esta incapacitado o siendo atacado por hunter/jockey/etc
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0)
    {
        if (g_bRougeGliding[client]) Rouge_ResetState(client);
        return;
    }

    int flags = GetEntityFlags(client);
    int buttons = GetClientButtons(client);

    if (flags & FL_ONGROUND)
    {
        if (g_bRougeGliding[client]) g_bRougeGliding[client] = false;
    }
    else if (!g_bRougeGliding[client])
    {
        // Activar planeo con SHIFT en el aire
        if (buttons & IN_SPEED)
        {
            g_bRougeGliding[client] = true;

            float vel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            if (vel[2] < -80.0) vel[2] = -80.0;

            float fwdAng[3], fwd[3], right[3];
            GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
            GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);

            float accel = 20.0;
            if (buttons & IN_FORWARD)   { vel[0] += fwd[0] * accel;  vel[1] += fwd[1] * accel; }
            if (buttons & IN_BACK)      { vel[0] -= fwd[0] * accel;  vel[1] -= fwd[1] * accel; }
            if (buttons & IN_MOVELEFT)  { vel[0] -= right[0] * accel; vel[1] -= right[1] * accel; }
            if (buttons & IN_MOVERIGHT) { vel[0] += right[0] * accel; vel[1] += right[1] * accel; }

            // Limitar velocidad horizontal maxima
            float maxSpeed = 300.0;
            float speed2D = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
            if (speed2D > maxSpeed)
            {
                vel[0] = (vel[0] / speed2D) * maxSpeed;
                vel[1] = (vel[1] / speed2D) * maxSpeed;
            }

            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        }
    }
}

public Action Rouge_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Rouge_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != ROUGE_INDEX) return Plugin_Continue;

    // Inmunidad a dano de caida (planeo de murcielago)
    if (damagetype & DMG_FALL)
    {
        damage = 0.0;
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

// =======================
// PASIVA: TREASURE HUNTER (VISION)
// =======================

public Action T_RougeVisionThink(Handle timer)
{
    // Verificacion de ConVar (puede ser null si el plugin se esta cargando)
    if (g_cvRougeVisionRange == null) return Plugin_Continue;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!Rouge_IsValidClient(i)) continue;
        if (g_iPlayerCharIdx[i] != ROUGE_INDEX) continue;

        Rouge_ScanTargets(i);
    }
    return Plugin_Continue;
}

void Rouge_ScanTargets(int client)
{
    if (!Rouge_IsValidClient(client)) return;
    if (g_cvRougeVisionRange == null) return;

    float pos[3];
    GetClientAbsOrigin(client, pos);
    float range = g_cvRougeVisionRange.FloatValue;
    float rangeSq = range * range;

    // 1. VISION DE ITEMS (beam rosa en items valiosos)
    static const char itemClasses[][] = {
        "weapon_first_aid_kit", "weapon_defibrillator", "weapon_pain_pills", "weapon_adrenaline",
        "weapon_rifle", "weapon_shotgun_spas", "weapon_sniper_military", "weapon_grenade_launcher",
        "weapon_upgradepack_explosive", "weapon_upgradepack_incendiary"
    };

    for (int c = 0; c < sizeof(itemClasses); c++)
    {
        int entity = -1;
        while ((entity = FindEntityByClassname(entity, itemClasses[c])) != -1)
        {
            if (!IsValidEntity(entity)) continue;
            float itemPos[3];
            GetEntPropVector(entity, Prop_Data, "m_vecOrigin", itemPos);
            if (GetVectorDistance(pos, itemPos, true) <= rangeSq)
            {
                TE_SetupBeamRingPoint(itemPos, 10.0, 30.0, g_iRougeGlowSprite, 0, 0, 0, 0.5, 2.0, 0.0, {255, 105, 180, 150}, 0, 0);
                TE_SendToClient(client);
            }
        }
    }

    // 2. VISION DE INFECTADOS ESPECIALES HERIDOS (<50% HP)
    int colorPink = 9639167; // Rosa hot
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;

        int hp = GetClientHealth(i);
        int maxHp = GetEntProp(i, Prop_Data, "m_iMaxHealth");
        if (maxHp <= 0) maxHp = 100;

        if (hp <= (maxHp * 0.5))
        {
            float targetPos[3];
            GetClientAbsOrigin(i, targetPos);
            if (GetVectorDistance(pos, targetPos, true) <= rangeSq)
            {
                SetEntProp(i, Prop_Send, "m_iGlowType", 3);
                SetEntProp(i, Prop_Send, "m_glowColorOverride", colorPink);
                SetEntProp(i, Prop_Send, "m_bFlashing", 1);
            }
            else
            {
                if (GetEntProp(i, Prop_Send, "m_iGlowType") == 3)
                    SetEntProp(i, Prop_Send, "m_iGlowType", 0);
            }
        }
    }
}

// =======================
// HABILIDAD 1: CEBO QUIMICO (con FIX del charco de acido real)
// ==========================================================

public Action Command_RougeKick(int client, int args)
{
    if (!Rouge_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fRougeBaitCooldown[client])
    {
        PrintCenterText(client, "Cebo Quimico en CD: %.1f", g_fRougeBaitCooldown[client] - now);
        return Plugin_Handled;
    }

    g_fRougeBaitCooldown[client] = now + g_cvRougeBaitCD.FloatValue;

    float pos[3], ang[3], vel[3];
    GetClientEyePosition(client, pos);
    GetClientEyeAngles(client, ang);

    GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
    pos[0] += vel[0] * 30.0;
    pos[1] += vel[1] * 30.0;
    pos[2] += vel[2] * 30.0;

    // Crear la granada de tubo rosa
    int bomb = CreateEntityByName("pipe_bomb_projectile");
    if (bomb == -1)
    {
        PrintCenterText(client, "Error: no se pudo crear el cebo.");
        return Plugin_Handled;
    }

    DispatchKeyValue(bomb, "model", ROUGE_MODEL_BOMB);
    DispatchSpawn(bomb);

    SetEntPropEnt(bomb, Prop_Data, "m_hThrower", client);
    SetEntPropEnt(bomb, Prop_Send, "m_hOwnerEntity", client);
    SetEntityRenderColor(bomb, 255, 20, 147, 255); // Rosa

    // Velocidad de lanzamiento
    ScaleVector(vel, 1500.0);
    vel[2] += 200.0;
    TeleportEntity(bomb, pos, ang, vel);

    // Timer propio para forzar la explosion a los ROUGE_BAIT_FUSE segundos
    DataPack dp = new DataPack();
    dp.WriteCell(EntIndexToEntRef(bomb));
    dp.WriteCell(GetClientUserId(client));
    CreateTimer(ROUGE_BAIT_FUSE, T_RougeBaitDetonate, dp, TIMER_FLAG_NO_MAPCHANGE);

    EmitSoundToAll(ROUGE_SND_THROW, client);
    PrintCenterText(client, "Cebo Quimico lanzado!");

    return Plugin_Handled;
}

// Detonacion del Cebo Quimico
public Action T_RougeBaitDetonate(Handle timer, DataPack dp)
{
    dp.Reset();
    int bombRef = dp.ReadCell();
    int clientUid = dp.ReadCell();
    delete dp; // Liberar memoria inmediatamente

    int bomb = EntRefToEntIndex(bombRef);
    int client = GetClientOfUserId(clientUid);

    // Validar bomba
    if (bomb <= 0 || !IsValidEntity(bomb))
        return Plugin_Stop;

    // Obtener posicion antes de destruir la bomba
    float pos[3];
    GetEntPropVector(bomb, Prop_Send, "m_vecOrigin", pos);

    // 1. DESTRUIR LA GRANADA (para que deje de rebotar)
    RemoveEntity(bomb);

    // Validar cliente (puede haberse desconectado)
    int ownerClient = 0;
    if (client > 0 && IsClientInGame(client))
        ownerClient = client;

    // 2. EXPLOSION INICIAL (env_explosion nativa)
    Rouge_CreateExplosion(pos, ownerClient, ROUGE_BAIT_RADIUS, g_cvRougeBaitDamage.FloatValue);

    // 3. FIX CRITICO: CREAR CHARCO DE ACIDO REAL
    //    Spawn del insect_swarm (entidad nativa del spit del Spitter) que genera
    //    el efecto visual verde persistente. Adicionalmente lanzamos un timer
    //    de dano por tick paralelo como respaldo para garantizar dano real.
    Rouge_CreateAcidPool(pos, ownerClient);

    // 4. Dano inicial a infectados especiales y Tanks en el radio
    Rouge_DamageInfectedInRadius(pos, ROUGE_BAIT_RADIUS, g_cvRougeBaitDamage.FloatValue, ownerClient, DMG_BLAST, true);

    // 5. Anillo visual rosa expansivo
    TE_SetupBeamRingPoint(pos, 10.0, 350.0, g_iRougeBeamSprite, g_iRougeGlowSprite, 0, 15, 0.5, 10.0, 0.0, {255, 20, 147, 200}, 0, 0);
    TE_SendToAll();

    EmitSoundToAll(ROUGE_SND_BOOM, ownerClient > 0 ? ownerClient : 0);

    return Plugin_Stop;
}

// FIX: Crear un charco de acido REAL que hace dano
// v7.1: Crea un charco de acido nativo usando SDKCall a CSpitterProjectile_Create
// Sistema basado en el plugin "Prototype Grenades" de Silvers.
// Requiere gamedata/rouge_abilities.txt con la signature CSpitterProjectile_Create.
void Rouge_CreateAcidPool(float pos[3], int ownerClient)
{
    // Ajustar posicion al suelo para que el charco se posicione correctamente
    float groundPos[3];
    groundPos[0] = pos[0];
    groundPos[1] = pos[1];
    groundPos[2] = pos[2];

    // Trace hacia abajo para encontrar el suelo
    float endPos[3];
    endPos[0] = pos[0];
    endPos[1] = pos[1];
    endPos[2] = pos[2] - 100.0;

    Handle trace = TR_TraceRayFilterEx(pos, endPos, MASK_SOLID, RayType_EndPoint, Rouge_TraceFilter_NoPlayers, 0);
    if (TR_DidHit(trace))
    {
        TR_GetEndPosition(groundPos, trace);
    }
    delete trace;

    // === METODO 1: SDKCall a CSpitterProjectile_Create (sistema de Silvers) ===
    // Esto crea un spit nativo del Spitter. El motor detecta el aterrizaje y
    // crea automaticamente un insect_swarm (el charco verde visible).
    // OnEntityCreated detectara el insect_swarm y lo trackeara en g_hRougeAcidPools.
    if (g_hRougeSDK_Spit != null && ownerClient > 0)
    {
        // Activar flag para que OnEntityCreated capture el proximo insect_swarm
        g_bRougeAcidSpawn = true;

        // Posicion: ligeramente arriba del suelo para que el spit caiga
        float spawnPos[3];
        spawnPos[0] = groundPos[0];
        spawnPos[1] = groundPos[1];
        spawnPos[2] = groundPos[2] + 5.0;

        // Angulos: sin rotacion
        float ang[3];
        ang[0] = 0.0;
        ang[1] = 0.0;
        ang[2] = 0.0;

        // Velocidad: hacia abajo para forzar el aterrizaje rapido
        float vel[3];
        vel[0] = 0.0;
        vel[1] = 0.0;
        vel[2] = -100.0;

        // Llamar a CSpitterProjectile_Create(pos, ang, vel, ang, owner)
        int acidEnt = SDKCall(g_hRougeSDK_Spit, spawnPos, ang, vel, ang, ownerClient);

        if (acidEnt > 0 && IsValidEntity(acidEnt))
        {
            // Setear owner para que el dano se atribuya correctamente
            SetEntPropEnt(acidEnt, Prop_Data, "m_hThrower", ownerClient);
            SetEntPropEnt(acidEnt, Prop_Send, "m_hOwnerEntity", ownerClient);
        }
    }
    else
    {
        // === METODO 1 FALLBACK: Crear spitter_projectile manualmente ===
        // Si no hay gamedata, usar el metodo manual (menos confiable)
        int acidEnt = CreateEntityByName("spitter_projectile");
        if (acidEnt != -1)
        {
            DispatchSpawn(acidEnt);

            if (ownerClient > 0)
            {
                SetEntPropEnt(acidEnt, Prop_Data, "m_hThrower", ownerClient);
                SetEntPropEnt(acidEnt, Prop_Send, "m_hOwnerEntity", ownerClient);
            }

            float spawnPos[3];
            spawnPos[0] = groundPos[0];
            spawnPos[1] = groundPos[1];
            spawnPos[2] = groundPos[2] + 50.0;

            float vel[3];
            vel[0] = 0.0;
            vel[1] = 0.0;
            vel[2] = -200.0;

            TeleportEntity(acidEnt, spawnPos, NULL_VECTOR, vel);

            if (g_hRougeAcidPools != null)
                g_hRougeAcidPools.Push(EntIndexToEntRef(acidEnt));

            CreateTimer(ROUGE_ACID_DURATION, T_RougeAcidCleanup, EntIndexToEntRef(acidEnt), TIMER_FLAG_NO_MAPCHANGE);
        }
    }

    // === METODO 2: Timer de dano por tick paralelo (respaldo robusto) ===
    // Esto garantiza que SIEMPRE haya dano a infectados en el area, sin importar
    // si el charco nativo funciona o no.
    DataPack acidPack = new DataPack();
    acidPack.WriteFloat(groundPos[0]);
    acidPack.WriteFloat(groundPos[1]);
    acidPack.WriteFloat(groundPos[2]);
    acidPack.WriteCell(GetClientUserId(ownerClient > 0 ? ownerClient : 0));
    acidPack.WriteCell(0); // contador de ticks

    int maxTicks = RoundToNearest(ROUGE_ACID_DURATION / ROUGE_ACID_TICK);
    acidPack.WriteCell(maxTicks);

    CreateTimer(ROUGE_ACID_TICK, T_RougeAcidTick, acidPack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // Efectos visuales adicionales (anillo verde inicial + sonido de spit)
    TE_SetupBeamRingPoint(groundPos, 10.0, ROUGE_ACID_RADIUS, g_iRougeBeamSprite, g_iRougeGlowSprite, 0, 15, 0.5, 8.0, 0.0, {120, 255, 80, 200}, 0, 0);
    TE_SendToAll();

    TE_SetupSparks(groundPos, NULL_VECTOR, 5, 3);
    TE_SendToAll();

    EmitSoundToAll(ROUGE_SND_ACID, ownerClient > 0 ? ownerClient : 0, _, _, _, 0.7);
}

// Timer de dano por tick del charco de acido (respaldo robusto)
public Action T_RougeAcidTick(Handle timer, DataPack pack)
{
    pack.Reset();
    float pos[3];
    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();
    int ownerUid = pack.ReadCell();
    int tickCount = pack.ReadCell();
    int maxTicks = pack.ReadCell();

    int owner = GetClientOfUserId(ownerUid);
    if (owner > 0 && !IsClientInGame(owner)) owner = 0;

    tickCount++;

    // Dano a infectados especiales (y Tank)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float tPos[3];
        GetClientAbsOrigin(i, tPos);
        if (GetVectorDistance(pos, tPos) <= ROUGE_ACID_RADIUS)
        {
            float dmg = ROUGE_ACID_DMG_SPEC;
            // Detectar si es Tank (zombie type 8)
            if (GetEntProp(i, Prop_Send, "m_zombieClass") == 8)
                dmg = ROUGE_ACID_DMG_TANK;

            SDKHooks_TakeDamage(i,
                owner > 0 ? owner : 0,
                owner > 0 ? owner : 0,
                dmg,
                DMG_ACID);
        }
    }

    // Dano a infectados comunes en el radio
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float zPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(pos, zPos) <= ROUGE_ACID_RADIUS)
        {
            SDKHooks_TakeDamage(entity,
                owner > 0 ? owner : 0,
                owner > 0 ? owner : 0,
                ROUGE_ACID_DMG_COMM,
                DMG_ACID);
        }
    }

    // Efecto visual cada 2 ticks (chispas verdes)
    if (tickCount % 2 == 0)
    {
        TE_SetupSparks(pos, NULL_VECTOR, 3, 1);
        TE_SendToAll();
    }

    // Fin del charco
    if (tickCount >= maxTicks)
    {
        delete pack;
        return Plugin_Stop;
    }

    // Re-escribir todo el DataPack con el tickCount actualizado
    // (evita problemas de pack.Position entre versiones de SourcePawn)
    pack.Reset();
    pack.WriteFloat(pos[0]);
    pack.WriteFloat(pos[1]);
    pack.WriteFloat(pos[2]);
    pack.WriteCell(ownerUid);
    pack.WriteCell(tickCount);
    pack.WriteCell(maxTicks);

    return Plugin_Continue;
}

// Limpieza del insect_swarm al expirar
public Action T_RougeAcidCleanup(Handle timer, int ref)
{
    int entity = EntRefToEntIndex(ref);
    if (entity > 0 && IsValidEntity(entity))
    {
        // Remover del ArrayList
        if (g_hRougeAcidPools != null)
        {
            int idx = g_hRougeAcidPools.FindValue(ref);
            if (idx != -1) g_hRougeAcidPools.Erase(idx);
        }
        RemoveEntity(entity);
    }
    return Plugin_Stop;
}

// =======================
// HABILIDAD 2: BAT BOMB SPRAY
// =======================

public Action Command_RougeBomb(int client, int args)
{
    if (!Rouge_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fRougeBombCooldown[client])
    {
        PrintCenterText(client, "Bat Bomb Spray Cooldown: %.1f", g_fRougeBombCooldown[client] - now);
        return Plugin_Handled;
    }

    float eyePos[3], eyeAng[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);

    int bombsCreated = 0;
    for (int i = 0; i < 3; i++)
    {
        float throwAng[3], fwd[3], spawnPos[3];
        throwAng[0] = eyeAng[0];
        throwAng[1] = eyeAng[1];
        throwAng[2] = eyeAng[2];

        // Abanico: bomba central + 2 laterales
        if (i == 1) throwAng[1] -= 22.0;
        else if (i == 2) throwAng[1] += 22.0;

        GetAngleVectors(throwAng, fwd, NULL_VECTOR, NULL_VECTOR);

        spawnPos[0] = eyePos[0] + (fwd[0] * 35.0);
        spawnPos[1] = eyePos[1] + (fwd[1] * 35.0);
        spawnPos[2] = eyePos[2] + (fwd[2] * 35.0);

        int bomb = CreateEntityByName("pipe_bomb_projectile");
        if (bomb == -1) continue;

        DispatchKeyValue(bomb, "model", ROUGE_MODEL_BOMB);
        DispatchSpawn(bomb);

        float velocity[3];
        velocity[0] = fwd[0] * 1100.0;
        velocity[1] = fwd[1] * 1100.0;
        velocity[2] = fwd[2] * 1100.0 + 300.0;

        TeleportEntity(bomb, spawnPos, throwAng, velocity);

        SetEntPropEnt(bomb, Prop_Send, "m_hOwnerEntity", client);
        SetEntityRenderColor(bomb, 255, 0, 255, 255);

        // Trail rosa siguiendo la bomba
        TE_SetupBeamFollow(bomb, g_iRougeBeamSprite, 0, 0.8, 5.0, 5.0, 0, {255, 20, 147, 200});
        TE_SendToAll();

        // Hook de toque para detonacion por contacto
        SDKHook(bomb, SDKHook_Touch, BatBomb_OnTouch);

        // Trackear en ArrayList (reemplaza g_bBombDetonated[2048])
        if (g_hRougeActiveBombs != null)
            g_hRougeActiveBombs.Push(EntIndexToEntRef(bomb));

        // Timer de detonacion por fuse
        CreateTimer(g_cvRougeBombTimer.FloatValue, T_RougeDetonateBomb, EntIndexToEntRef(bomb), TIMER_FLAG_NO_MAPCHANGE);

        // Beep parpadeante
        DataPack pack = new DataPack();
        pack.WriteCell(EntIndexToEntRef(bomb));
        pack.WriteCell(2);
        CreateTimer(0.5, T_RougeBombBeep, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

        bombsCreated++;
    }

    if (bombsCreated == 0)
    {
        PrintCenterText(client, "Error: no se pudieron crear las bombas.");
        return Plugin_Handled;
    }

    g_fRougeBombCooldown[client] = now + g_cvRougeBombCD.FloatValue;
    EmitSoundToAll(ROUGE_SND_THROW, client);
    PrintCenterText(client, "Granadas X3 Spray Lanzadas!");

    return Plugin_Handled;
}

// Verifica si una bomba ya fue detonada (usando ArrayList)
bool Rouge_IsBombDetonated(int bomb)
{
    if (bomb <= 0 || !IsValidEntity(bomb)) return true;
    if (g_hRougeActiveBombs == null) return true;

    int ref = EntIndexToEntRef(bomb);
    return g_hRougeActiveBombs.FindValue(ref) == -1;
}

// Marca una bomba como detonada (la remueve del ArrayList)
void Rouge_MarkBombDetonated(int bomb)
{
    if (bomb <= 0 || g_hRougeActiveBombs == null) return;

    int ref = EntIndexToEntRef(bomb);
    int idx = g_hRougeActiveBombs.FindValue(ref);
    if (idx != -1) g_hRougeActiveBombs.Erase(idx);
}

public Action BatBomb_OnTouch(int bomb, int other)
{
    if (bomb <= 0 || !IsValidEntity(bomb)) return Plugin_Continue;
    if (Rouge_IsBombDetonated(bomb)) return Plugin_Continue;

    int owner = GetEntPropEnt(bomb, Prop_Send, "m_hOwnerEntity");
    if (other == owner) return Plugin_Continue;

    // Ignorar otras bombas
    if (other > MaxClients && IsValidEntity(other))
    {
        char classname[32];
        GetEntityClassname(other, classname, sizeof(classname));
        if (StrEqual(classname, "pipe_bomb_projectile")) return Plugin_Continue;
    }

    CreateTimer(0.05, T_RougeDetonateBomb, EntIndexToEntRef(bomb), TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Continue;
}

public Action T_RougeBombBeep(Handle timer, DataPack pack)
{
    pack.Reset();
    int ref = pack.ReadCell();
    int count = pack.ReadCell();

    int bomb = EntRefToEntIndex(ref);
    if (bomb == INVALID_ENT_REFERENCE || !IsValidEntity(bomb) || Rouge_IsBombDetonated(bomb))
    {
        delete pack;
        return Plugin_Stop;
    }

    EmitSoundToAll(ROUGE_SND_BEEP, bomb);

    float pos[3];
    GetEntPropVector(bomb, Prop_Send, "m_vecOrigin", pos);
    pos[2] += 5.0;
    TE_SetupGlowSprite(pos, g_iRougeGlowSprite, 0.2, 1.5, 200);
    TE_SendToAll();

    // Parpadeo de colores
    int r = 255, g = 0, b = 255;
    if (count % 2 != 0) { r = 255; g = 100; b = 255; }
    SetEntityRenderColor(bomb, r, g, b, 255);

    count--;

    if (count <= 0)
    {
        delete pack;
        return Plugin_Stop;
    }

    // Re-escribir todo el DataPack con el count actualizado
    // (evita problemas de pack.Position entre versiones de SourcePawn)
    pack.Reset();
    pack.WriteCell(ref);
    pack.WriteCell(count);

    return Plugin_Continue;
}

public Action T_RougeDetonateBomb(Handle timer, int ref)
{
    int bomb = EntRefToEntIndex(ref);
    if (bomb == INVALID_ENT_REFERENCE || !IsValidEntity(bomb) || Rouge_IsBombDetonated(bomb))
        return Plugin_Stop;

    // Marcar como detonada (remueve del ArrayList)
    Rouge_MarkBombDetonated(bomb);

    float pos[3];
    GetEntPropVector(bomb, Prop_Send, "m_vecOrigin", pos);
    int owner = GetEntPropEnt(bomb, Prop_Send, "m_hOwnerEntity");
    if (!Rouge_IsValidClient(owner)) owner = 0;

    // Explosion nativa (env_explosion) para efecto visual realista
    Rouge_CreateExplosion(pos, owner, g_cvRougeBombRadius.FloatValue, g_cvRougeBombDamage.FloatValue);

    // Ring rosa expansivo
    TE_SetupBeamRingPoint(pos, 10.0, g_cvRougeBombRadius.FloatValue, g_iRougeBeamSprite, g_iRougeGlowSprite, 0, 15, 0.4, 20.0, 0.0, {255, 20, 147, 255}, 10, 0);
    TE_SendToAll();

    // Particula del pipebomb nativo
    int particle = CreateEntityByName("info_particle_system");
    if (IsValidEntity(particle))
    {
        DispatchKeyValue(particle, "effect_name", "weapon_pipebomb");
        DispatchKeyValueVector(particle, "origin", pos);
        DispatchSpawn(particle);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "Start");
        SetVariantString("OnUser1 !self:kill::2.0:1");
        AcceptEntityInput(particle, "AddOutput");
        AcceptEntityInput(particle, "FireUser1");
    }

    // Dano a infectados especiales y comunes en el radio
    Rouge_DamageInfectedInRadius(pos, g_cvRougeBombRadius.FloatValue, g_cvRougeBombDamage.FloatValue, owner, DMG_BLAST, true);

    // Destruir la bomba
    RemoveEntity(bomb);

    return Plugin_Stop;
}

// =======================
// UTILIDADES
// =======================

// Crea una explosion VISUAL (sin dano nativo). El dano real lo hace Rouge_DamageInfectedInRadius
// que filtra por equipo (solo infectados). Esto evita que Rouge se dane a si misma.
void Rouge_CreateExplosion(float pos[3], int owner, float radius, float damage)
{
    // Usar TE_SetupExplosion para efecto visual puro (no hace dano)
    int sprite = PrecacheModel("materials/sprites/glow01.vmt", true);
    TE_SetupExplosion(pos, sprite, 10.0, 1, 0, RoundToNearest(radius), 0);
    TE_SendToAll();

    // Beam ring expansivo para efecto visual
    int beamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    int haloSprite = PrecacheModel("materials/sprites/halo01.vmt", true);
    int color[4] = {255, 20, 147, 200}; // Rosa
    TE_SetupBeamRingPoint(pos, 10.0, radius, beamSprite, haloSprite, 0, 15, 0.5, 10.0, 0.0, color, 5, 0);
    TE_SendToAll();

    // Sonido de explosion
    EmitSoundToAll(ROUGE_SND_BOOM, owner > 0 ? owner : 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // NOTA: No usamos env_explosion nativa porque dana a TODOS los jugadores
    // incluyendo a Rouge. El dano real se hace via Rouge_DamageInfectedInRadius
    // que filtra por equipo (solo TEAM_INFECTED).
}

// Dano a infectados especiales y comunes en un radio
void Rouge_DamageInfectedInRadius(float pos[3], float radius, float damage, int attacker, int dmgType, bool stagger)
{
    // Infectados especiales (players)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float tPos[3];
        GetClientAbsOrigin(i, tPos);
        if (GetVectorDistance(pos, tPos) <= radius)
        {
            SDKHooks_TakeDamage(i,
                attacker > 0 ? attacker : 0,
                attacker > 0 ? attacker : 0,
                damage,
                dmgType);
            if (stagger) L4D_StaggerPlayer(i, attacker > 0 ? attacker : 0, pos);
        }
    }

    // Infectados comunes (NPCs)
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float zPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(pos, zPos) <= radius)
        {
            SDKHooks_TakeDamage(entity,
                attacker > 0 ? attacker : 0,
                attacker > 0 ? attacker : 0,
                damage * 2.0, // Comunes reciben mas dano
                dmgType);
        }
    }
}

// Trace filter que ignora players
public bool Rouge_TraceFilter_NoPlayers(int entity, int contentsMask, int data)
{
    if (entity > 0 && entity <= MaxClients) return false;
    return true;
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
public void Rouge_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return;
    Rouge_ResetState(client);
}

// Puente de compatibilidad
public void Rouge_OnPlayerRunCmd(int client, int &buttons) {}
