/*
 * ======================================================
 *  [MODULO] Dr. Eggman - The Genius Tactician v2.0 (Air Support Rework)
 *
 *  v2.0 CHANGES:
 *   - NUEVA PASIVA: "Eggman Air Support"
 *     Cuando Eggman aparece (spawn), se invoca un avion de carga que flota
 *     sobre el. Si Eggman cambia de clase o muere, el avion se va.
 *     El avion es puramente visual (da ambient de "Dr. Eggman esta aqui").
 *
 *   - ROBUSTEZ DE CODIGO:
 *     * Validaciones estrictas en cada funcion (client, entity, ref)
 *     * SDKUnhook antes de SDKHook (anti double-hook)
 *     * Limpieza segura de handles con null checks
 *     * ConVars con validacion null
 *     * Banderas explicitas de estado
 *     * ArrayList para trackeo de aviones activos (en vez de array gigante)
 *
 *   - FIXES:
 *     * Fix: g_hEggmanMineTimers array[2048] reemplazado por ArrayList
 *     * Fix: Timer de minas verificaba entidades invalidas
 *     * Fix: env_fire no se eliminaba correctamente
 *     * Fix: L4D_StaggerPlayer podia crashear con owner invalido
 *
 *  Rol: Soporte de Area / Control de Masas
 *  Pasivas:
 *    - Eggmobile Hover (Flota sobre agua/acido, inmune a caidas, -10% velocidad)
 *    - Eggman Air Support (Avion de carga flotando sobre Eggman)
 *  Habilidad 1: Badnik Mines (Despliega 3 minas explosivas)
 *  Habilidad 2: Death Egg Laser (Rayo orbital masivo)
 * ======================================================
 */

#if defined _Eggman_included
    #endinput
#endif
#define _Eggman_included

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
#if !defined EGGMAN_INDEX
    #define EGGMAN_INDEX 9
#endif

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// =======================
// Constantes
// =======================

// Modelo del avion de carga (C-130 del aeropuerto de L4D2)
#define EGGMAN_AIR_MODEL    "models/props_vehicles/airplane_jets.mdl"

// Posicionamiento del avion sobre Eggman
#define EGGMAN_AIR_HEIGHT   800.0   // Altura sobre Eggman
#define EGGMAN_AIR_OFFSET   300.0   // Offset horizontal (para que no este justo arriba)
#define EGGMAN_AIR_RADIUS   1500.0  // Radio de visibilidad

// Cooldowns
#define EGGMAN_MINES_CD     18.0
#define EGGMAN_LASER_CD     40.0

// Limites de seguridad
#define EGGMAN_MAX_MINES    20

// =======================
// Variables Globales
// =======================
float g_fEggmanMinesCD[MAXPLAYERS + 1];
float g_fEggmanLaserCD[MAXPLAYERS + 1];

// v2.0: Trackeo de aviones activos (un avion por Eggman)
int g_iEggmanAirEntity[MAXPLAYERS + 1] = { -1, ... };

// v2.0: Trackeo de minas activas (reemplaza el array[2048])
ArrayList g_hEggmanActiveMines = null;

// v2.0: Trackeo de fuegos activos
ArrayList g_hEggmanActiveFires = null;

// Sprites cacheados
int g_iEggmanBeamSprite = -1;
int g_iEggmanGlowSprite = -1;

// ConVars
ConVar g_cvEggmanMinesCD, g_cvEggmanLaserCD;
ConVar g_cvEggmanMineDamage, g_cvEggmanLaserDamage;
ConVar g_cvEggmanAirEnable;

#define Eggman_IsValidClient(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))
#define Eggman_IsValidEntity(%1) (IsValidEntity(%1) && (%1) != INVALID_ENT_REFERENCE)

// =======================
// Inicializacion
// =======================

public void Eggman_OnPluginStart()
{
    // ConVars con validacion
    g_cvEggmanMinesCD     = CreateConVar("eggman_mines_cd", "18.0", "Cooldown de Badnik Mines", _, true, 0.0, true, 120.0);
    g_cvEggmanLaserCD     = CreateConVar("eggman_laser_cd", "40.0", "Cooldown de Death Egg Laser", _, true, 0.0, true, 300.0);
    g_cvEggmanMineDamage  = CreateConVar("eggman_mine_damage", "200.0", "Dano de las minas", _, true, 0.0, true, 5000.0);
    g_cvEggmanLaserDamage = CreateConVar("eggman_laser_damage", "600.0", "Dano del laser", _, true, 0.0, true, 5000.0);
    g_cvEggmanAirEnable   = CreateConVar("eggman_air_enable", "1", "Habilita el avion de Eggman (1=si, 0=no)", _, true, 0.0, true, 1.0);

    RegConsoleCmd("sm_eggman_mines", Command_EggmanMines);
    RegConsoleCmd("sm_eggman_laser", Command_EggmanLaser);

    // Inicializar ArrayLists
    g_hEggmanActiveMines = new ArrayList();
    g_hEggmanActiveFires = new ArrayList();

    AutoExecConfig(true, "Eggman_Abilities");
}

public void Eggman_OnMapStart()
{
    // Sonidos estandar de L4D2
    PrecacheSound("weapons/hegrenade/explode3.wav", true);
    PrecacheSound("ambient/energy/zap9.wav", true);
    PrecacheSound("ambient/explosions/explode_1.wav", true);
    PrecacheSound("buttons/blip2.wav", true);

    // Modelos
    PrecacheModel("models/props_junk/propanecanister002a.mdl", true);
    PrecacheModel("materials/sprites/laserbeam.vmt", true);
    PrecacheModel("materials/sprites/glow01.vmt", true);

    // v2.0: Precache del modelo del avion
    PrecacheModel(EGGMAN_AIR_MODEL, true);

    // Cache de sprites
    g_iEggmanBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    g_iEggmanGlowSprite = PrecacheModel("materials/sprites/glow01.vmt", true);

    // Reset de estados por cliente
    for (int i = 1; i <= MaxClients; i++)
    {
        Eggman_ResetState(i);
    }

    // Limpiar ArrayLists
    if (g_hEggmanActiveMines != null) g_hEggmanActiveMines.Clear();
    if (g_hEggmanActiveFires != null) g_hEggmanActiveFires.Clear();
}

public void Eggman_OnMapEnd()
{
    // Limpiar aviones activos
    for (int i = 1; i <= MaxClients; i++)
    {
        Eggman_RemoveAirSupport(i);
    }

    if (g_hEggmanActiveMines != null) g_hEggmanActiveMines.Clear();
    if (g_hEggmanActiveFires != null) g_hEggmanActiveFires.Clear();
}

public void Eggman_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;

    // Anti double-hook
    SDKUnhook(client, SDKHook_OnTakeDamage, Eggman_OnTakeDamage);
    SDKUnhook(client, SDKHook_PreThink, Eggman_PreThink);

    SDKHook(client, SDKHook_OnTakeDamage, Eggman_OnTakeDamage);
    SDKHook(client, SDKHook_PreThink, Eggman_PreThink);

    Eggman_ResetState(client);
}

void Eggman_ResetState(int client)
{
    if (client < 1 || client > MaxClients) return;

    g_fEggmanMinesCD[client] = 0.0;
    g_fEggmanLaserCD[client] = 0.0;

    // v2.0: Remover avion si existe
    Eggman_RemoveAirSupport(client);
}

// =======================
// PASIVAS: EGGMOBILE HOVER + AIR SUPPORT
// =======================

public Action Eggman_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Eggman_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != EGGMAN_INDEX) return Plugin_Continue;

    // Inmune a caidas (Eggmobile flota)
    if (damagetype & DMG_FALL)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // Inmune a acido y veneno (Flota sobre el charco)
    if (damagetype & DMG_ACID || damagetype & DMG_POISON || damagetype & DMG_RADIATION)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public void Eggman_PreThink(int client)
{
    if (!Eggman_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return;

    // Eggman es 10% mas lento caminando
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.9);

    // v2.0: Verificar que el avion este presente
    if (g_cvEggmanAirEnable != null && g_cvEggmanAirEnable.BoolValue)
    {
        Eggman_EnsureAirSupport(client);
    }
}

// =======================
// PASIVA: EGGMAN AIR SUPPORT (Avion de carga flotando)
// =======================

// Crea o asegura que el avion este presente sobre Eggman
void Eggman_EnsureAirSupport(int client)
{
    if (!Eggman_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return;

    // Verificar si el avion actual sigue siendo valido
    int air = g_iEggmanAirEntity[client];
    if (air > 0 && IsValidEntity(air))
    {
        // El avion existe, actualizar su posicion para que siga a Eggman
        Eggman_UpdateAirPosition(client, air);
        return;
    }

    // El avion no existe o es invalido, crearlo
    Eggman_SpawnAirSupport(client);
}

// Spawnea el avion sobre Eggman
void Eggman_SpawnAirSupport(int client)
{
    if (!Eggman_IsValidClient(client)) return;

    // Eliminar avion anterior si existe
    Eggman_RemoveAirSupport(client);

    // Crear el avion como prop_dynamic_override
    int air = CreateEntityByName("prop_dynamic_override");
    if (air <= 0 || !IsValidEntity(air))
    {
        PrintToServer("[Eggman] ERROR: No se pudo crear el avion de Air Support");
        return;
    }

    // Configurar el avion
    DispatchKeyValue(air, "model", EGGMAN_AIR_MODEL);
    DispatchKeyValue(air, "solid", "0");
    DispatchKeyValue(air, "rendermode", "0"); // Normal
    DispatchKeyValue(air, "renderfx", "0");
    DispatchKeyValue(air, "rendercolor", "255 255 255");
    DispatchKeyValue(air, "disablereceiveshadows", "1");
    DispatchKeyValue(air, "disableshadows", "1");

    // Spawn
    if (!DispatchSpawn(air))
    {
        PrintToServer("[Eggman] ERROR: DispatchSpawn fallo para el avion");
        RemoveEntity(air);
        return;
    }

    // Posicionar sobre Eggman
    Eggman_UpdateAirPosition(client, air);

    // Activar
    ActivateEntity(air);

    // Setar como no solido (no bloquear movimiento)
    SetEntProp(air, Prop_Data, "m_nSolidType", 0);
    SetEntProp(air, Prop_Send, "m_CollisionGroup", 0);

    // Guardar referencia
    g_iEggmanAirEntity[client] = EntIndexToEntRef(air);

    // Efectos visuales de aparicion
    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += EGGMAN_AIR_HEIGHT;

    // Sonido de avion (opcional, usar sonido de motor del juego)
    // EmitSoundToAll("ambient/energy/zap1.wav", air, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // Beam desde el avion hasta Eggman (estilo "tracking laser")
    if (g_iEggmanBeamSprite > 0)
    {
        float clientPos[3];
        GetClientAbsOrigin(client, clientPos);
        clientPos[2] += 50.0;

        TE_SetupBeamPoints(pos, clientPos, g_iEggmanBeamSprite, 0, 0, 0, 0.5, 2.0, 2.0, 0, 0.0, {255, 255, 255, 100}, 0);
        TE_SendToAll();
    }

    PrintToServer("[Eggman] Air Support invocado para %N", client);
}

// Actualiza la posicion del avion para que siga a Eggman
void Eggman_UpdateAirPosition(int client, int air)
{
    if (!Eggman_IsValidClient(client)) return;
    if (air <= 0 || !IsValidEntity(air)) return;

    float pos[3], ang[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);

    // Calcular posicion del avion (arriba y ligeramente detras)
    float fwd[3], right[3];
    GetAngleVectors(ang, fwd, right, NULL_VECTOR);

    // Offset: arriba + detras + ligeramente a la derecha
    pos[0] -= fwd[0] * EGGMAN_AIR_OFFSET;
    pos[1] -= fwd[1] * EGGMAN_AIR_OFFSET;
    pos[2] += EGGMAN_AIR_HEIGHT;

    // Angulos del avion (inclinado como si estuviera volando)
    float airAng[3];
    airAng[0] = 0.0; // Sin pitch
    airAng[1] = ang[1] + 180.0; // Mirando hacia Eggman
    airAng[2] = 0.0; // Sin roll

    // Teleportar el avion
    TeleportEntity(air, pos, airAng, NULL_VECTOR);

    // Setar parent para que siga a Eggman automaticamente
    // Nota: SetParent puede causar problemas con prop_dynamic, mejor usar TeleportEntity en PreThink
}

// Remueve el avion de Eggman
void Eggman_RemoveAirSupport(int client)
{
    if (client < 1 || client > MaxClients) return;

    int air = g_iEggmanAirEntity[client];
    if (air > 0)
    {
        int ent = EntRefToEntIndex(air);
        if (ent > 0 && IsValidEntity(ent))
        {
            // Efecto de desaparicion
            float pos[3];
            GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
            TE_SetupSparks(pos, NULL_VECTOR, 5, 3);
            TE_SendToAll();

            RemoveEntity(ent);
            PrintToServer("[Eggman] Air Support removido de %N", client);
        }
    }
    g_iEggmanAirEntity[client] = -1;
}

// =======================
// HABILIDAD 1: BADNIK MINES
// =======================

public Action Command_EggmanMines(int client, int args)
{
    if (!Eggman_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    float cd = (g_cvEggmanMinesCD != null) ? g_cvEggmanMinesCD.FloatValue : EGGMAN_MINES_CD;
    if (now < g_fEggmanMinesCD[client])
    {
        PrintCenterText(client, "Minas en Cooldown: %.1f", g_fEggmanMinesCD[client] - now);
        return Plugin_Handled;
    }

    g_fEggmanMinesCD[client] = now + cd;

    float pos[3], ang[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);

    // Desplegar 3 minas en abanico
    for (int i = 0; i < 3; i++)
    {
        float mineAng[3], fwd[3], minePos[3];
        mineAng = ang;

        if (i == 0) mineAng[1] -= 30.0;
        else if (i == 2) mineAng[1] += 30.0;

        GetAngleVectors(mineAng, fwd, NULL_VECTOR, NULL_VECTOR);
        minePos[0] = pos[0] + fwd[0] * 100.0;
        minePos[1] = pos[1] + fwd[1] * 100.0;
        minePos[2] = pos[2];

        // Trazar rayo al suelo para ponerlas bien
        Handle trace = TR_TraceRayFilterEx(minePos, view_as<float>({90.0, 0.0, 0.0}), MASK_SOLID, RayType_Infinite, Eggman_TraceFilter_NoPlayers, client);
        if (TR_DidHit(trace)) TR_GetEndPosition(minePos, trace);
        delete trace;

        minePos[2] += 5.0;

        int mine = CreateEntityByName("prop_physics_override");
        if (mine != -1)
        {
            DispatchKeyValue(mine, "model", "models/props_junk/propanecanister002a.mdl");
            DispatchKeyValue(mine, "rendercolor", "255 0 0");
            DispatchSpawn(mine);
            TeleportEntity(mine, minePos, mineAng, NULL_VECTOR);

            SetEntProp(mine, Prop_Data, "m_takedamage", 0); // Invulnerable hasta pisarla

            // v2.0: Trackear en ArrayList
            if (g_hEggmanActiveMines != null)
                g_hEggmanActiveMines.Push(EntIndexToEntRef(mine));

            // Timer para revisar si la pisan
            DataPack dp = new DataPack();
            dp.WriteCell(EntIndexToEntRef(mine));
            dp.WriteCell(GetClientUserId(client));
            CreateTimer(0.2, T_EggmanMineTick, dp, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

            // Auto-destruir tras 15s si no la pisan
            char input[64];
            Format(input, sizeof(input), "OnUser1 !self:Kill::15.0:-1");
            SetVariantString(input); AcceptEntityInput(mine, "AddOutput");
            AcceptEntityInput(mine, "FireUser1");
        }
    }

    PrintCenterText(client, "Minas Badnik desplegadas!");
    EmitSoundToClient(client, "buttons/blip2.wav");
    return Plugin_Handled;
}

public Action T_EggmanMineTick(Handle timer, DataPack dp)
{
    dp.Reset();
    int mineRef = dp.ReadCell();
    int ownerUid = dp.ReadCell();
    delete dp;

    int mine = EntRefToEntIndex(mineRef);
    int owner = GetClientOfUserId(ownerUid);

    // v2.0: Validar que la mina sigue existiendo
    if (mine == INVALID_ENT_REFERENCE || !IsValidEntity(mine))
    {
        // Remover del ArrayList
        if (g_hEggmanActiveMines != null)
        {
            int idx = g_hEggmanActiveMines.FindValue(mineRef);
            if (idx != -1) g_hEggmanActiveMines.Erase(idx);
        }
        return Plugin_Stop;
    }

    // Si el owner se desconecto, eliminar la mina
    if (owner <= 0)
    {
        Eggman_RemoveMine(mine, mineRef);
        return Plugin_Stop;
    }

    float mPos[3];
    GetEntPropVector(mine, Prop_Send, "m_vecOrigin", mPos);

    // Revisar infectados comunes
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(mPos, zPos) <= 80.0)
            {
                Eggman_DetonateMine(mine, mineRef, owner, mPos);
                return Plugin_Stop;
            }
        }
    }

    // Revisar Witches
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float wPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", wPos);
            if (GetVectorDistance(mPos, wPos) <= 80.0)
            {
                Eggman_DetonateMine(mine, mineRef, owner, mPos);
                return Plugin_Stop;
            }
        }
    }

    // Revisar Especiales
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float tPos[3]; GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(mPos, tPos) <= 80.0)
            {
                Eggman_DetonateMine(mine, mineRef, owner, mPos);
                return Plugin_Stop;
            }
        }
    }

    return Plugin_Continue;
}

// Remueve una mina del ArrayList y del mundo
void Eggman_RemoveMine(int mine, int mineRef)
{
    if (g_hEggmanActiveMines != null)
    {
        int idx = g_hEggmanActiveMines.FindValue(mineRef);
        if (idx != -1) g_hEggmanActiveMines.Erase(idx);
    }

    if (mine > 0 && IsValidEntity(mine))
    {
        RemoveEntity(mine);
    }
}

void Eggman_DetonateMine(int mine, int mineRef, int owner, float pos[3])
{
    // v2.0: Remover del ArrayList y del mundo
    Eggman_RemoveMine(mine, mineRef);

    // Efectos
    if (g_iEggmanGlowSprite > 0)
    {
        TE_SetupExplosion(pos, g_iEggmanGlowSprite, 20.0, 1, 0, 200, 0);
        TE_SendToAll();
    }
    EmitSoundToAll("weapons/hegrenade/explode3.wav", owner > 0 ? owner : 0);

    // Dano en area
    float damage = (g_cvEggmanMineDamage != null) ? g_cvEggmanMineDamage.FloatValue : 200.0;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float tPos[3]; GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(pos, tPos) <= 200.0)
            {
                SDKHooks_TakeDamage(i, owner > 0 ? owner : 0, owner > 0 ? owner : 0, damage, DMG_BLAST);
            }
        }
    }

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(pos, zPos) <= 200.0)
            {
                SDKHooks_TakeDamage(entity, owner > 0 ? owner : 0, owner > 0 ? owner : 0, damage, DMG_BLAST);
            }
        }
    }

    // Dejar charco de fuego (Inferno)
    int fire = CreateEntityByName("env_fire");
    if (fire != -1)
    {
        DispatchKeyValue(fire, "firesize", "150");
        DispatchKeyValue(fire, "health", "5"); // 5 segundos
        DispatchKeyValue(fire, "spawnflags", "1"); // Sin expansion
        TeleportEntity(fire, pos, NULL_VECTOR, NULL_VECTOR);
        DispatchSpawn(fire);
        ActivateEntity(fire);
        SetEntPropFloat(fire, Prop_Data, "m_flFireLifetime", 5.0);
        AcceptEntityInput(fire, "StartFire");

        // v2.0: Trackear el fuego en ArrayList
        if (g_hEggmanActiveFires != null)
            g_hEggmanActiveFires.Push(EntIndexToEntRef(fire));

        CreateTimer(5.0, T_Eggman_KillFire, EntIndexToEntRef(fire), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action T_Eggman_KillFire(Handle timer, int ref)
{
    int ent = EntRefToEntIndex(ref);
    if (ent > 0 && IsValidEntity(ent))
    {
        // v2.0: Remover del ArrayList
        if (g_hEggmanActiveFires != null)
        {
            int idx = g_hEggmanActiveFires.FindValue(ref);
            if (idx != -1) g_hEggmanActiveFires.Erase(idx);
        }

        AcceptEntityInput(ent, "Extinguish");
        RemoveEntity(ent);
    }
    return Plugin_Stop;
}

// =======================
// HABILIDAD 2: DEATH EGG LASER
// =======================

public Action Command_EggmanLaser(int client, int args)
{
    if (!Eggman_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    float cd = (g_cvEggmanLaserCD != null) ? g_cvEggmanLaserCD.FloatValue : EGGMAN_LASER_CD;
    if (now < g_fEggmanLaserCD[client])
    {
        PrintCenterText(client, "Death Egg Cooldown: %.1f", g_fEggmanLaserCD[client] - now);
        return Plugin_Handled;
    }

    g_fEggmanLaserCD[client] = now + cd;

    // Trazar rayo al suelo frente a el
    float pos[3], ang[3], endPos[3];
    GetClientEyePosition(client, pos);
    GetClientEyeAngles(client, ang);

    Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, Eggman_TraceFilter_NoPlayers, client);
    if (TR_DidHit(trace)) TR_GetEndPosition(endPos, trace);
    else
    {
        float fwd[3]; GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
        endPos[0] = pos[0] + fwd[0] * 1000.0;
        endPos[1] = pos[1] + fwd[1] * 1000.0;
        endPos[2] = pos[2] + fwd[2] * 1000.0;
    }
    delete trace;

    // 1. Fase de Carga (2 segundos)
    PrintCenterText(client, "Fijando objetivo... Death Egg Ray entrante.");
    EmitSoundToAll("ambient/energy/zap9.wav", client);

    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(client));
    dp.WriteFloat(endPos[0]);
    dp.WriteFloat(endPos[1]);
    dp.WriteFloat(endPos[2]);

    CreateTimer(2.0, T_Eggman_LaserFire, dp, TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Handled;
}

public Action T_Eggman_LaserFire(Handle timer, DataPack dp)
{
    dp.Reset();
    int owner = GetClientOfUserId(dp.ReadCell());
    float targetPos[3];
    targetPos[0] = dp.ReadFloat();
    targetPos[1] = dp.ReadFloat();
    targetPos[2] = dp.ReadFloat();
    delete dp;

    if (owner <= 0) return Plugin_Stop;

    // 2. Fase de Impacto (Laser gigante del cielo)
    float skyPos[3];
    skyPos = targetPos;
    skyPos[2] += 2000.0; // El laser viene del cielo

    // v2.0: Usar sprites cacheados
    int beam = g_iEggmanBeamSprite;
    int glow = g_iEggmanGlowSprite;

    if (beam > 0 && glow > 0)
    {
        // Laser principal (Gordo y opaco)
        TE_SetupBeamPoints(skyPos, targetPos, beam, 0, 0, 0, 1.0, 50.0, 50.0, 0, 0.0, {255, 0, 0, 255}, 0);
        TE_SendToAll();

        // Laser brillante (Fino y blanco)
        TE_SetupBeamPoints(skyPos, targetPos, beam, 0, 0, 0, 1.0, 10.0, 10.0, 0, 0.0, {255, 255, 255, 255}, 0);
        TE_SendToAll();

        // Explosion
        TE_SetupExplosion(targetPos, glow, 60.0, 1, 0, 500, 0);
        TE_SendToAll();
    }

    EmitSoundToAll("ambient/explosions/explode_1.wav");

    float radius = 400.0;
    float damage = (g_cvEggmanLaserDamage != null) ? g_cvEggmanLaserDamage.FloatValue : 600.0;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float tPos[3]; GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(targetPos, tPos) <= radius)
            {
                SDKHooks_TakeDamage(i, owner, owner, damage, DMG_ENERGYBEAM);
                // v2.0: Validar owner antes de llamar L4D_StaggerPlayer
                if (owner > 0 && IsClientInGame(owner))
                    L4D_StaggerPlayer(i, owner, targetPos);
            }
        }
    }

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(targetPos, zPos) <= radius)
            {
                SDKHooks_TakeDamage(entity, owner, owner, 9999.0, DMG_ENERGYBEAM);
            }
        }
    }

    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (IsValidEntity(witch))
        {
            float wPos[3]; GetEntPropVector(witch, Prop_Send, "m_vecOrigin", wPos);
            if (GetVectorDistance(targetPos, wPos) <= radius)
            {
                SDKHooks_TakeDamage(witch, owner, owner, damage, DMG_ENERGYBEAM);
            }
        }
    }

    return Plugin_Stop;
}

// =======================
// UTILIDADES
// =======================

public bool Eggman_TraceFilter_NoPlayers(int entity, int contentsMask, int data)
{
    if (entity == data) return false;
    if (entity > 0 && entity <= MaxClients) return false;
    return true;
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// v2.0: Llamado cuando Eggman aparece (spawn)
public void Eggman_OnPlayerSpawn(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return;

    Eggman_ResetState(client);

    // Invocar el avion de Air Support
    if (g_cvEggmanAirEnable != null && g_cvEggmanAirEnable.BoolValue)
    {
        // Pequeno delay para que el cliente este completamente cargado
        CreateTimer(1.0, T_Eggman_SpawnAirSupport, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    }

    PrintToChat(client, "\x04[Eggman]\x01 Air Support disponible. Eggmobile listo.");
}

public Action T_Eggman_SpawnAirSupport(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return Plugin_Stop;

    Eggman_SpawnAirSupport(client);
    return Plugin_Stop;
}

// v2.0: Llamado cuando Eggman muere o cambia de clase
public void Eggman_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return;

    // Remover el avion (Eggman murio, el avion se va)
    Eggman_RemoveAirSupport(client);
    Eggman_ResetState(client);
}

// v2.0: Llamado cuando el cliente se desconecta
public void Eggman_OnClientDisconnect(int client)
{
    if (client < 1 || client > MaxClients) return;

    // Remover el avion
    Eggman_RemoveAirSupport(client);
    Eggman_ResetState(client);
}

// Puente de compatibilidad
public void Eggman_OnPlayerRunCmd(int client, int &buttons) {}
