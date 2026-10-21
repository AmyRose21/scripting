/*
 * ======================================================
 *  [MODULO] Dr. Eggman - The Genius Tactician v3.1 (Eggmobile Jet Rework)
 *
 *  v3.1 (con manager 3.77.8) - FIN DE LA AUTO-GENERACION INDIVIDUAL:
 *   - Eliminado el AutoExecConfig("Eggman_Abilities") — el cfg
 *     individual se generaba con TODOS los cvars del plugin entero
 *     ("ConVars for plugin Sonic_ability_manager.smx"), o sea la
 *     MISMA lista que Sonic_Suite.cfg: duplicado puro que ademas
 *     pisaba valores al ejecutarse. Los cvars de Eggman ya viven en
 *     la config unica Sonic_Suite.cfg (v3.75, auto-guardada).
 *   - El manager 3.77.8 ademas BORRA los cfg residuales del server
 *     (SuiteCfg_DeleteLegacyFiles).
 *
 *  v3.0 CHANGES (REWORK COMPLETO):
 *   - ELIMINADO: "Eggman Air Support" (avion C-130 flotando a 800 u):
 *     * El modelo airplane_jets.mdl se veia con texturas rotas/negras
 *     * Era 100% visual: no aportaba NADA util al jugador
 *     * Gastaba 1 entidad + TeleportEntity en PreThink cada frame
 *     * El hook SDKHook_PreThink se elimina entero (rendimiento)
 *
 *   - ELIMINADO: penalizacion -10% velocidad permanente. Era una
 *     desventaja neta (lento SIEMPRE a cambio de nada). Ademas pisaba
 *     m_flLaggedMovementValue cada frame y CHOCABA con otros sistemas
 *     (Speed_sonic x2.5, Sonic Hero Mode x1.5, staggers de SI).
 *
 *   - NUEVA PASIVA: "EGGMOBILE JET" (doble salto real)
 *     * Pulsar SALTO de nuevo EN EL AIRE dispara el jet del Eggmobile
 *     * Impulso vertical configurable (def. +320) + empuje frontal
 *     * FX: burst de energia + chispas + anillo + sonido electrico
 *     * Cooldown corto (2s); 1 jet por salto (reset al aterrizar)
 *     * Guardas: no en incap, no agarrado (pounce/tongue/jockey/pummel/
 *       carry), no colgando de borde, no en escalera
 *
 *   - PASIVAS MANTENIDAS:
 *     * Inmunidad a dano de caida (el Eggmobile flota)
 *     * Inmunidad a acido/veneno/radiacion (flota sobre charcos)
 *
 *   - BADNIK MINES v2 (pulidas):
 *     * Glow rojo visible (env_sprite additive parented a la mina)
 *     * Mina congelada (DisableMotion): queda plantada donde se pone
 *     * Deteccion con 1 timer GLOBAL (0.25s) en vez de 1 timer + DataPack
 *       POR MINA (antes: hasta 3 timers + FindEntityByClassname x3 cada
 *       0.2s por mina)
 *     * ArrayList por bloques {mina, sprite, owner} -> limpieza total
 *     * El dano en area ahora tambien afecta a la witch
 *     * Auto-kill garantizado de mina (15s) y sprite (16s) via OnUser1
 *
 *   - DEATH EGG LASER v2 (pulido):
 *     * Telegrafiado: durante la carga de 2s se marca la zona de impacto
 *       (anillo pulsante rojo + haz vertical de aviso + blips sonoros)
 *     * Al disparar: doble haz + explosion + stagger (como antes)
 *
 *  Rol: Control de Area / Comandante tecnologico
 *  Pasivas: Eggmobile Jet (doble salto) + hover anti-caida/anti-acido
 *  Habilidad 1: Badnik Mines (3 minas explosivas con glow)
 *  Habilidad 2: Death Egg Laser (rayo orbital telegrafiado)
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

// Cooldowns por defecto (las habilidades usan ConVars)
#define EGGMAN_MINES_CD     18.0
#define EGGMAN_LASER_CD     40.0
#define EGGMAN_LASER_CHARGE  2.0    // Tiempo de carga del laser
#define EGGMAN_LASER_PULSES  8      // Blips de telegrafo durante la carga

// Doble salto (pasiva)
#define EGGMAN_JET_FORCE_DEF    320.0   // Impulso vertical del jet
#define EGGMAN_JET_FORWARD_DEF  200.0   // Empuje horizontal en la direccion de la mira
#define EGGMAN_JET_CD_DEF       2.0     // Cooldown entre jets aereos

// Minas
#define EGGMAN_MINE_TRIGGER 80.0    // Radio de activacion por proximidad
#define EGGMAN_MINE_DMG_R   200.0   // Radio del dano en area
#define EGGMAN_MINE_LIFE    15.0    // Vida de la mina si nadie la pisa
#define EGGMAN_MAX_MINE_BLOCKS 24   // Max de bloques {mina,sprite,owner} en el ArrayList

// =======================
// Variables Globales
// =======================
float g_fEggmanMinesCD[MAXPLAYERS + 1];
float g_fEggmanLaserCD[MAXPLAYERS + 1];

// Pasiva: Eggmobile Jet (doble salto)
bool  g_bEggmanJetReady[MAXPLAYERS + 1];    // Recargado al tocar suelo/escalera
float g_fEggmanJetNext[MAXPLAYERS + 1];     // Tiempo del proximo jet permitido
int   g_iEggmanLastButtons[MAXPLAYERS + 1]; // Deteccion de flanco de IN_JUMP

// Minas activas: ArrayList PLANO (blocksize=1) usado como bloques logicos de
// 3 celdas {mineRef, spriteRef, ownerUserId}. Se borran celda a celda en
// orden DESCENDENTE (semantica 100% portable entre includes viejos y nuevos).
#define EGGMAN_MINE_BLOCK 3
ArrayList g_hEggmanActiveMines = null;
Handle g_hEggmanMinesTimer = null;   // Timer global de deteccion (0.25s)

// Fuegos activos (refs simples)
ArrayList g_hEggmanActiveFires = null;

// Sprites cacheados
int g_iEggmanBeamSprite = -1;
int g_iEggmanGlowSprite = -1;

// ConVars
ConVar g_cvEggmanMinesCD, g_cvEggmanLaserCD;
ConVar g_cvEggmanMineDamage, g_cvEggmanLaserDamage;
ConVar g_cvEggmanJetEnable, g_cvEggmanJetForce, g_cvEggmanJetForward, g_cvEggmanJetCD;

#define Eggman_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))
#define Eggman_IsValidEntity(%1) (IsValidEntity(%1) && (%1) != INVALID_ENT_REFERENCE)

// =======================
// Inicializacion
// =======================

public void Eggman_OnPluginStart()
{
    // ConVars (se mantienen los nombres originales para respetar cfgs)
    g_cvEggmanMinesCD     = CreateConVar("eggman_mines_cd", "18.0", "Cooldown de Badnik Mines", _, true, 0.0, true, 120.0);
    g_cvEggmanLaserCD     = CreateConVar("eggman_laser_cd", "40.0", "Cooldown de Death Egg Laser", _, true, 0.0, true, 300.0);
    g_cvEggmanMineDamage  = CreateConVar("eggman_mine_damage", "200.0", "Dano de las minas", _, true, 0.0, true, 5000.0);
    g_cvEggmanLaserDamage = CreateConVar("eggman_laser_damage", "600.0", "Dano del laser", _, true, 0.0, true, 5000.0);

    // v3.0: ConVars del nuevo doble salto
    g_cvEggmanJetEnable   = CreateConVar("eggman_jet_enable", "1", "Habilita la pasiva Eggmobile Jet (doble salto)", _, true, 0.0, true, 1.0);
    g_cvEggmanJetForce    = CreateConVar("eggman_jet_force", "320.0", "Impulso vertical del doble salto", _, true, 100.0, true, 800.0);
    g_cvEggmanJetForward  = CreateConVar("eggman_jet_forward", "200.0", "Empuje horizontal del doble salto (dir. de la mira)", _, true, 0.0, true, 600.0);
    g_cvEggmanJetCD       = CreateConVar("eggman_jet_cd", "2.0", "Cooldown del doble salto aereo", _, true, 0.0, true, 30.0);

    RegConsoleCmd("sm_eggman_mines", Command_EggmanMines);
    RegConsoleCmd("sm_eggman_laser", Command_EggmanLaser);

    // Inicializar ArrayLists (PLANO: cada Push = 1 celda; los bloques de 3
    // celdas por mina se gestionan manualmente con Erase descendente)
    g_hEggmanActiveMines = new ArrayList();
    g_hEggmanActiveFires = new ArrayList();

    // v3.77.8 (Eggman v3.1): AutoExecConfig eliminado - config UNICA
    // del suite (Sonic_Suite.cfg, auto-guardada; ver manager). El
    // archivo viejo queda muerto y el manager lo borra del server.
}

public void Eggman_OnMapStart()
{
    // Sonidos estandar de L4D2 (cero descargas nuevas)
    PrecacheSound("weapons/hegrenade/explode3.wav", true);
    PrecacheSound("ambient/energy/zap9.wav", true);
    PrecacheSound("ambient/explosions/explode_1.wav", true);
    PrecacheSound("buttons/blip2.wav", true);
    PrecacheSound("buttons/blip1.wav", true);

    // Modelos
    PrecacheModel("models/props_junk/propanecanister002a.mdl", true);
    PrecacheModel("materials/sprites/laserbeam.vmt", true);
    PrecacheModel("materials/sprites/glow01.vmt", true);

    // Cache de sprites
    g_iEggmanBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    g_iEggmanGlowSprite = PrecacheModel("materials/sprites/glow01.vmt", true);

    // Reset de estados por cliente (jet, cooldowns)
    for (int i = 1; i <= MaxClients; i++)
    {
        Eggman_ResetState(i);
    }

    // Limpiar ArrayLists (refs del mapa anterior inservibles)
    if (g_hEggmanActiveMines != null) g_hEggmanActiveMines.Clear();
    if (g_hEggmanActiveFires != null) g_hEggmanActiveFires.Clear();

    // v3.0: el timer global de minas muere solo (TIMER_FLAG_NO_MAPCHANGE);
    // solo soltar el handle para poder recrearlo bajo demanda.
    g_hEggmanMinesTimer = null;
}

public void Eggman_OnMapEnd()
{
    // Los timers NO_MAPCHANGE y entidades mueren con el mapa.
    // Soltar handles y vaciar listas para que el mapa nuevo arranque limpio.
    g_hEggmanMinesTimer = null;
    if (g_hEggmanActiveMines != null) g_hEggmanActiveMines.Clear();
    if (g_hEggmanActiveFires != null) g_hEggmanActiveFires.Clear();
}

public void Eggman_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;

    // Anti double-hook (solo OnTakeDamage: PreThink ya no existe en v3.0)
    SDKUnhook(client, SDKHook_OnTakeDamage, Eggman_OnTakeDamage);
    SDKUnhook(client, SDKHook_PreThink, Eggman_PreThink); // por si venia de una version vieja recargada

    SDKHook(client, SDKHook_OnTakeDamage, Eggman_OnTakeDamage);

    Eggman_ResetState(client);
}

void Eggman_ResetState(int client)
{
    if (client < 1 || client > MaxClients) return;

    g_fEggmanMinesCD[client] = 0.0;
    g_fEggmanLaserCD[client] = 0.0;

    // v3.0: reset del sistema de doble salto
    g_bEggmanJetReady[client] = true;
    g_fEggmanJetNext[client] = 0.0;
    g_iEggmanLastButtons[client] = 0;
}

// =======================
// PASIVAS: HOVER DEL EGGMOBILE (inmunidades)
// =======================

public Action Eggman_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Eggman_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != EGGMAN_INDEX) return Plugin_Continue;

    // Inmune a caidas (Eggmobile flota) — ahora SI importa: el doble salto
    // anima a jugar con la altura
    if (damagetype & DMG_FALL)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // Inmune a acido, veneno o radiacion (flota sobre el charco)
    if (damagetype & DMG_ACID || damagetype & DMG_POISON || damagetype & DMG_RADIATION)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

// Puente de compatibilidad: el PreThink del avion ya no existe (v3.0).
// Se mantiene vacio para no romper includes antiguos que lo referencien.
public void Eggman_PreThink(int client) {}

// =======================
// NUEVA PASIVA v3.0: EGGMOBILE JET (DOBLE SALTO)
// =======================
// El manager llama a esta funcion en cada RunCmd de un Eggman vivo:
// usamos deteccion de flanco de IN_JUMP para el salto aereo.

public void Eggman_OnPlayerRunCmd(int client, int &buttons)
{
    if (!Eggman_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return;
    if (g_cvEggmanJetEnable == null || !g_cvEggmanJetEnable.BoolValue)
    {
        g_iEggmanLastButtons[client] = buttons;
        return;
    }

    int flags = GetEntityFlags(client);

    // En suelo o escalera: el jet se re-arma para el proximo salto
    if ((flags & FL_ONGROUND) || GetEntityMoveType(client) == MOVETYPE_LADDER)
    {
        g_bEggmanJetReady[client] = true;
        g_iEggmanLastButtons[client] = buttons;
        return;
    }

    // Flanco de pulsacion de SALTO (nueva pulsacion, no mantener)
    bool bNewJumpPress = ((buttons & IN_JUMP) != 0) && ((g_iEggmanLastButtons[client] & IN_JUMP) == 0);
    g_iEggmanLastButtons[client] = buttons;

    if (!bNewJumpPress || !g_bEggmanJetReady[client]) return;

    // Guardas de estado: no jet si esta incapacitado, agarrado o colgando
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    if (GetEntProp(client, Prop_Send, "m_isHangingFromLedge") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0) return;

    float now = GetEngineTime();
    float cd = (g_cvEggmanJetCD != null) ? g_cvEggmanJetCD.FloatValue : EGGMAN_JET_CD_DEF;

    if (now < g_fEggmanJetNext[client])
    {
        // Feedback de recarga solo cuando lo intenta
        PrintCenterText(client, "Eggmobile Jet recargando: %.1fs", g_fEggmanJetNext[client] - now);
        return;
    }
    g_fEggmanJetNext[client] = now + cd;

    // --- IMPULSO DEL JET ---
    float force   = (g_cvEggmanJetForce != null)   ? g_cvEggmanJetForce.FloatValue   : EGGMAN_JET_FORCE_DEF;
    float fwdPower = (g_cvEggmanJetForward != null) ? g_cvEggmanJetForward.FloatValue : EGGMAN_JET_FORWARD_DEF;

    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);

    // Vertical: si esta cayendo, el jet corta la caida de golpe
    vel[2] = (vel[2] < 0.0) ? force : (vel[2] + force * 0.6);

    // Horizontal: empuje en la direccion de la mira (sin pitch)
    if (fwdPower > 0.0)
    {
        float ang[3], fwd[3];
        GetClientEyeAngles(client, ang);
        ang[0] = 0.0;
        GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(fwd, fwdPower);
        vel[0] += fwd[0];
        vel[1] += fwd[1];
    }

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    // Un jet por salto: se re-arma al aterrizar
    g_bEggmanJetReady[client] = false;

    // --- FX DEL JET (todo one-shot, cero entidades persistentes) ---
    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] -= 5.0; // a la altura de los pies

    if (g_iEggmanGlowSprite > 0)
    {
        // Anillo de propulsion expandiendose (colores Eggman: rojo/naranja)
        TE_SetupBeamRingPoint(pos, 5.0, 130.0, g_iEggmanGlowSprite, g_iEggmanGlowSprite,
                              0, 15, 0.25, 8.0, 1.0, {255, 170, 0, 200}, 0, 0);
        TE_SendToAll();
    }

    // Chispas del jet hacia abajo
    TE_SetupSparks(pos, view_as<float>({0.0, 0.0, -1.0}), 8, 4);
    TE_SendToAll();

    // Burst de energia electrica
    TE_SetupEnergySplash(pos, view_as<float>({0.0, 0.0, -1.0}), false);
    TE_SendToAll();

    // Sonido electrico del jet (estandar de L4D2, ya precacheado)
    EmitSoundToAll("ambient/energy/zap9.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 120);

    PrintCenterText(client, "[JET] EGGMOBILE BOOST!");
}

// =======================
// HABILIDAD 1: BADNIK MINES v2 (glow + deteccion global)
// =======================

public Action Command_EggmanMines(int client, int args)
{
    if (!Eggman_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return Plugin_Handled;

    // Guardas: no desplegar incapacitado ni agarrado
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return Plugin_Handled;

    float now = GetEngineTime();
    float cd = (g_cvEggmanMinesCD != null) ? g_cvEggmanMinesCD.FloatValue : EGGMAN_MINES_CD;
    if (now < g_fEggmanMinesCD[client])
    {
        PrintCenterText(client, "Minas en Cooldown: %.1f", g_fEggmanMinesCD[client] - now);
        return Plugin_Handled;
    }

    // v3.0: tope de seguridad de bloques activos (evita spam acumulado)
    if (g_hEggmanActiveMines != null && g_hEggmanActiveMines.Length >= EGGMAN_MAX_MINE_BLOCKS * EGGMAN_MINE_BLOCK)
    {
        PrintCenterText(client, "Demasiadas minas activas en el mapa!");
        return Plugin_Handled;
    }

    g_fEggmanMinesCD[client] = now + cd;

    float pos[3], ang[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);

    int ownerUid = GetClientUserId(client);

    // Desplegar 3 minas en abanico (-30, 0, +30 grados)
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

        // Trazar rayo al suelo para plantarla bien
        Handle trace = TR_TraceRayFilterEx(minePos, view_as<float>({90.0, 0.0, 0.0}), MASK_SOLID, RayType_Infinite, Eggman_TraceFilter_NoPlayers, client);
        if (TR_DidHit(trace)) TR_GetEndPosition(minePos, trace);
        delete trace;

        minePos[2] += 5.0;

        int mine = CreateEntityByName("prop_physics_override");
        if (mine == -1 || !IsValidEntity(mine)) continue;

        // Nombre para poder parentar el glow a la mina
        char sMineName[32];
        Format(sMineName, sizeof(sMineName), "eggmine_%d_%d", ownerUid, i);

        DispatchKeyValue(mine, "model", "models/props_junk/propanecanister002a.mdl");
        DispatchKeyValue(mine, "rendercolor", "255 60 40");
        DispatchKeyValue(mine, "targetname", sMineName);
        DispatchSpawn(mine);
        TeleportEntity(mine, minePos, mineAng, NULL_VECTOR);

        SetEntProp(mine, Prop_Data, "m_takedamage", 0); // Invulnerable hasta pisarla

        // v3.0: congelar la fisica -> la mina queda PLANTADA donde se pone
        AcceptEntityInput(mine, "DisableMotion");

        // v3.0: glow rojo visible parentado a la mina
        int sprite = -1;
        sprite = CreateEntityByName("env_sprite");
        if (sprite != -1 && IsValidEntity(sprite))
        {
            DispatchKeyValue(sprite, "model", "materials/sprites/glow01.vmt");
            DispatchKeyValue(sprite, "parentname", sMineName);
            DispatchKeyValue(sprite, "rendercolor", "255 50 30");
            DispatchKeyValue(sprite, "renderamt", "200");
            DispatchKeyValue(sprite, "scale", "0.3");
            DispatchKeyValue(sprite, "rendermode", "5");   // additive
            DispatchKeyValue(sprite, "spawnflags", "1");   // start on
            DispatchSpawn(sprite);
            TeleportEntity(sprite, minePos, NULL_VECTOR, NULL_VECTOR);

            // Auto-destruir el sprite (1s despues de su mina, por si acaso)
            SetVariantString("OnUser1 !self:Kill::16.0:-1");
            AcceptEntityInput(sprite, "AddOutput");
            AcceptEntityInput(sprite, "FireUser1");
        }

        // Auto-destruir la mina tras 15s si nadie la pisa
        char input[64];
        Format(input, sizeof(input), "OnUser1 !self:Kill::%.1f:-1", EGGMAN_MINE_LIFE);
        SetVariantString(input); AcceptEntityInput(mine, "AddOutput");
        AcceptEntityInput(mine, "FireUser1");

        // Registrar bloque {mina, sprite, owner}
        if (g_hEggmanActiveMines != null)
        {
            g_hEggmanActiveMines.Push(EntIndexToEntRef(mine));
            g_hEggmanActiveMines.Push(sprite != -1 ? EntIndexToEntRef(sprite) : -1);
            g_hEggmanActiveMines.Push(ownerUid);
        }
    }

    // v3.0: arrancar el UNICO timer global de deteccion si no vive ya
    if (g_hEggmanMinesTimer == null)
    {
        g_hEggmanMinesTimer = CreateTimer(0.25, T_EggmanMinesTick, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }

    PrintCenterText(client, "Minas Badnik desplegadas!");
    EmitSoundToClient(client, "buttons/blip2.wav");
    return Plugin_Handled;
}

// Timer GLOBAL: chequea proximidad de todas las minas de una sola vez.
// (v2 tenia 1 timer + DataPack POR MINA con FindEntityByClassname x3 cada 0.2s)
public Action T_EggmanMinesTick(Handle timer)
{
    if (g_hEggmanActiveMines == null)
    {
        g_hEggmanMinesTimer = null;
        return Plugin_Stop;
    }

    int blocks = g_hEggmanActiveMines.Length / EGGMAN_MINE_BLOCK;
    if (blocks <= 0)
    {
        g_hEggmanMinesTimer = null;
        return Plugin_Stop;
    }

    for (int b = blocks - 1; b >= 0; b--)
    {
        int base = b * EGGMAN_MINE_BLOCK;

        int mine = EntRefToEntIndex(g_hEggmanActiveMines.Get(base));
        if (mine == INVALID_ENT_REFERENCE || !IsValidEntity(mine))
        {
            // La mina ya no existe (explosion, kill, limpieza) -> quitar bloque
            // (el sprite tiene su propio auto-kill a 16s, no hay que tocarlo)
            Eggman_EraseBlockCells(base);
            continue;
        }

        // Si el owner se desconecto, eliminar la mina fisicamente
        int owner = GetClientOfUserId(g_hEggmanActiveMines.Get(base + 2));
        if (owner <= 0 || !IsClientInGame(owner))
        {
            Eggman_RemoveMineBlock(b, true);
            continue;
        }

        float mPos[3];
        GetEntPropVector(mine, Prop_Send, "m_vecOrigin", mPos);

        bool boom = false;

        // Infectados especiales (jugadores)
        for (int i = 1; i <= MaxClients && !boom; i++)
        {
            if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
            {
                float tPos[3]; GetClientAbsOrigin(i, tPos);
                if (GetVectorDistance(mPos, tPos) <= EGGMAN_MINE_TRIGGER) boom = true;
            }
        }

        // Comunes
        int ent = -1;
        while (!boom && (ent = FindEntityByClassname(ent, "infected")) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            float zPos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(mPos, zPos) <= EGGMAN_MINE_TRIGGER) { boom = true; break; }
        }

        // Witches
        ent = -1;
        while (!boom && (ent = FindEntityByClassname(ent, "witch")) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            float wPos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", wPos);
            if (GetVectorDistance(mPos, wPos) <= EGGMAN_MINE_TRIGGER) { boom = true; break; }
        }

        if (boom) Eggman_DetonateMine(b, owner, mPos);
    }

    return Plugin_Continue;
}

// Borra las 3 celdas de un bloque del ArrayList (orden DESCENDENTE para
// que los indices de las celdas restantes no se desplacen durante el borrado)
void Eggman_EraseBlockCells(int base)
{
    if (g_hEggmanActiveMines == null) return;
    if (base < 0 || base + 2 >= g_hEggmanActiveMines.Length) return;
    g_hEggmanActiveMines.Erase(base + 2);
    g_hEggmanActiveMines.Erase(base + 1);
    g_hEggmanActiveMines.Erase(base);
}

// Elimina el bloque de una mina del ArrayList y (opcionalmente) del mundo
void Eggman_RemoveMineBlock(int b, bool killWorld)
{
    if (g_hEggmanActiveMines == null) return;
    int base = b * EGGMAN_MINE_BLOCK;

    int mineRef   = g_hEggmanActiveMines.Get(base);
    int spriteRef = g_hEggmanActiveMines.Get(base + 1);

    Eggman_EraseBlockCells(base);

    if (killWorld)
    {
        int sprite = EntRefToEntIndex(spriteRef);
        if (sprite > 0 && IsValidEntity(sprite))
        {
            AcceptEntityInput(sprite, "ClearParent");
            RemoveEntity(sprite);
        }
        int mine = EntRefToEntIndex(mineRef);
        if (mine > 0 && IsValidEntity(mine)) RemoveEntity(mine);
    }
}

void Eggman_DetonateMine(int b, int owner, float pos[3])
{
    // Quitar del ArrayList y del mundo (mina + sprite)
    Eggman_RemoveMineBlock(b, true);

    // Efectos
    if (g_iEggmanGlowSprite > 0)
    {
        TE_SetupExplosion(pos, g_iEggmanGlowSprite, 20.0, 1, 0, 200, 0);
        TE_SendToAll();
    }
    TE_SetupSparks(pos, NULL_VECTOR, 30, 10);
    TE_SendToAll();
    EmitSoundToAll("weapons/hegrenade/explode3.wav", owner > 0 ? owner : 0);

    // Dano en area
    float damage = (g_cvEggmanMineDamage != null) ? g_cvEggmanMineDamage.FloatValue : 200.0;

    // Infectados especiales (jugadores)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float tPos[3]; GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(pos, tPos) <= EGGMAN_MINE_DMG_R)
            {
                SDKHooks_TakeDamage(i, owner > 0 ? owner : 0, owner > 0 ? owner : 0, damage, DMG_BLAST);
            }
        }
    }

    // Comunes
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        float zPos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(pos, zPos) <= EGGMAN_MINE_DMG_R)
        {
            SDKHooks_TakeDamage(ent, owner > 0 ? owner : 0, owner > 0 ? owner : 0, damage, DMG_BLAST);
        }
    }

    // v3.0: la witch tambien recibe el dano de las minas (antes solo el laser)
    ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        float wPos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", wPos);
        if (GetVectorDistance(pos, wPos) <= EGGMAN_MINE_DMG_R)
        {
            SDKHooks_TakeDamage(ent, owner > 0 ? owner : 0, owner > 0 ? owner : 0, damage, DMG_BLAST);
        }
    }

    // Dejar charco de fuego (Inferno)
    int fire = CreateEntityByName("env_fire");
    if (fire != -1 && IsValidEntity(fire))
    {
        DispatchKeyValue(fire, "firesize", "150");
        DispatchKeyValue(fire, "health", "5"); // 5 segundos
        DispatchKeyValue(fire, "spawnflags", "1"); // Sin expansion
        TeleportEntity(fire, pos, NULL_VECTOR, NULL_VECTOR);
        DispatchSpawn(fire);
        ActivateEntity(fire);
        SetEntPropFloat(fire, Prop_Data, "m_flFireLifetime", 5.0);
        AcceptEntityInput(fire, "StartFire");

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
// HABILIDAD 2: DEATH EGG LASER v2 (telegrafiado)
// =======================

public Action Command_EggmanLaser(int client, int args)
{
    if (!Eggman_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return Plugin_Handled;

    // Guardas: no castear incapacitado ni agarrado
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return Plugin_Handled;
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return Plugin_Handled;
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) return Plugin_Handled;
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return Plugin_Handled;

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

    // Disparo real tras la carga
    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(client));
    dp.WriteFloat(endPos[0]);
    dp.WriteFloat(endPos[1]);
    dp.WriteFloat(endPos[2]);
    CreateTimer(EGGMAN_LASER_CHARGE, T_Eggman_LaserFire, dp, TIMER_FLAG_NO_MAPCHANGE);

    // v3.0: telegrafo — marca la zona de impacto durante la carga
    DataPack tp = new DataPack();
    tp.WriteCell(GetClientUserId(client));
    tp.WriteFloat(endPos[0]);
    tp.WriteFloat(endPos[1]);
    tp.WriteFloat(endPos[2]);
    tp.WriteCell(EGGMAN_LASER_PULSES);
    CreateTimer(0.25, T_Eggman_LaserTelegraph, tp, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Handled;
}

// Pulsos de aviso durante la carga: anillo + haz vertical + blip 3D
public Action T_Eggman_LaserTelegraph(Handle timer, DataPack tp)
{
    tp.Reset();
    int ownerUid = tp.ReadCell();
    float targetPos[3];
    targetPos[0] = tp.ReadFloat();
    targetPos[1] = tp.ReadFloat();
    targetPos[2] = tp.ReadFloat();
    int pulses = tp.ReadCell();

    pulses--;
    if (pulses <= 0)
    {
        delete tp;
        return Plugin_Stop;
    }

    // Reescribir el pack con el contador actualizado
    tp.Reset();
    tp.WriteCell(ownerUid);
    tp.WriteFloat(targetPos[0]);
    tp.WriteFloat(targetPos[1]);
    tp.WriteFloat(targetPos[2]);
    tp.WriteCell(pulses);

    // Dibujar el telegrafo (zona roja pulsante)
    if (g_iEggmanBeamSprite > 0 && g_iEggmanGlowSprite > 0)
    {
        float skyPos[3];
        skyPos = targetPos;
        skyPos[2] += 1200.0;

        // Haz vertical fino de aviso (de donde vendra el disparo)
        TE_SetupBeamPoints(skyPos, targetPos, g_iEggmanBeamSprite, 0, 0, 0, 0.25,
                           3.0, 3.0, 0, 0.0, {255, 0, 0, 130}, 0);
        TE_SendToAll();

        // Anillo que delimita la zona de impacto
        TE_SetupBeamRingPoint(targetPos, 20.0, 400.0, g_iEggmanGlowSprite, g_iEggmanGlowSprite,
                              0, 15, 0.24, 12.0, 1.0, {255, 60, 40, 200}, 0, 0);
        TE_SendToAll();
    }

    // Blip de aviso sonoro ESPACIAL en la zona (todos lo oyen desde el punto)
    EmitSoundToAll("buttons/blip1.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL,
                   _, 1.0, 120, -1, targetPos);

    return Plugin_Continue;
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

    int beam = g_iEggmanBeamSprite;
    int glow = g_iEggmanGlowSprite;

    if (beam > 0 && glow > 0)
    {
        // Laser principal (gordo y opaco)
        TE_SetupBeamPoints(skyPos, targetPos, beam, 0, 0, 0, 1.0, 50.0, 50.0, 0, 0.0, {255, 0, 0, 255}, 0);
        TE_SendToAll();

        // Laser brillante (fino y blanco)
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
                // Validar owner antes de llamar L4D_StaggerPlayer
                if (owner > 0 && IsClientInGame(owner))
                    L4D_StaggerPlayer(i, owner, targetPos);
            }
        }
    }

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(targetPos, zPos) <= radius)
        {
            SDKHooks_TakeDamage(entity, owner, owner, 9999.0, DMG_ENERGYBEAM);
        }
    }

    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float wPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", wPos);
        if (GetVectorDistance(targetPos, wPos) <= radius)
        {
            SDKHooks_TakeDamage(entity, owner, owner, damage, DMG_ENERGYBEAM);
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

// v3.0: al aparecer, resetear el jet y avisar de la pasiva nueva
public void Eggman_OnPlayerSpawn(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return;

    Eggman_ResetState(client);

    PrintToChat(client, "\x04[Eggman]\x01 Pasiva: \x05EGGMOBILE JET\x01 (salta de nuevo en el aire). Inmune a caidas y acido.");
}

// v3.0: al morir, solo reset de estado (ya no hay avion que retirar)
public void Eggman_OnPlayerDeath(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return;

    Eggman_ResetState(client);
}

// v3.0: al desconectar, solo reset de estado
public void Eggman_OnClientDisconnect(int client)
{
    if (client < 1 || client > MaxClients) return;
    Eggman_ResetState(client);
}
