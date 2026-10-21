/*
 * ======================================================
 *  [MODULO] Witch Flight v2.6 - Vuelo de la Witch con IA suspendida
 *  (sistema compartido: lo usan Amy, Knuckles, Tails y Sonic)
 *
 *  v2.6 - FIX "la witch toca superficie y no recibe el dano ni
 *      reacciona" (reportado en juego con v2.5). TRES cambios:
 *      (1) BUG CRITICO DEL TICK: la rama de ATERRIZAJE no sumaba
 *      'active'; con una sola witch volando (el caso típico) el
 *      timer de 33 Hz se apagaba EN el mismo tick del aterrizaje y
 *      el FL_FROZEN del stun de aterrizaje no se quitaba NUNCA ->
 *      witch ESTATUA: sin grito, sin persecución, sin respuesta al
 *      dano ni a los disparos (solo "revivia" si otro golpe la
 *      relanzaba). El stun de v2.5 solo expiraba si OTRA witch
 *      seguía volando (su active++ mantenia el timer vivo).
 *      (2) "TOCAR SUPERFICIE = DANO" LITERAL: nueva rama de CRASH
 *      contra pared/techo/pendiente: si la velocidad de entrada en
 *      la superficie supera WITCHFLIGHT_CRASH_SPEED (500) la witch
 *      CHOCA (dano de impacto + stun + rage) en vez de deslizarse
 *      amortiguando hasta caer después a velocidad de miel. Con
 *      anti-spam de 1 impacto de dano por segundo por vuelo
 *      (WITCHFLIGHT_IMPACT_CD): el laser de Tails relanza a la
 *      witch cada 0.1s y sin el gate dispararía dano a 10 Hz.
 *      (3) REACCION GARANTIZADA: al aterrizar/chocar se fuerza
 *      m_rage=1.0 en la witch viva (su IA no pudo rampar el rage
 *      mientras volaba congelada): se levanta ENFADADA y persigue
 *      a quien la mando a volar, en vez de sentarse tranquila.
 *
 *  v2.5 - STUN DE ATERRIZAJE (petición v68 de Amy: "el golpe no da
 *      stagger al impactar, lo da al aterrizar, con todos los tipos de
 *      infectados"). La witch no es CTerrorPlayer: L4D_StaggerPlayer no
 *      le aplica (es un NPC NextBot). Su equivalente exacto: al tocar
 *      suelo la FÍSICA se restaura ya (movetype original + velocidad
 *      cero) pero la IA sigue congelada (FL_FROZEN)
 *      WITCHFLIGHT_LAND_STUN segundos: cae de pie, se queda un instante
 *      "levantándose" y su IA se reactiva sola (el slot queda ocupado
 *      en fase stun y el tick la vigila). Un re-golpe durante el stun
 *      la relanza normal (sale de la fase stun sola). Si muere durante
 *      el stun: restauración completa inmediata (el check de salud del
 *      tick cubre la fase stun).
 *
 *  v2.4 - HARDENING del fix v53 del "crash del capítulo siguiente":
 *  (1) GUARD DE SALUD EN EL LANZAMIENTO: una witch muerta o en plena
 *      muerte (m_iHealth <= 0) ya no se lanza: su IA/motor está en
 *      transición y congelarla+teleportarla en ese estado es la
 *      receta del crash. (2) DETECCION DE ENTIDAD INCRUSTADA en el
 *      tick: si el rayo de colisión acierta a fracción ~0 (la witch
 *      esta DENTRO de geometria), se restaura INMEDIATAMENT en vez
 *      de seguir teleportándola dentro de la pared a 20 Hz hasta el
 *      timeout. La causa raíz del crash (witches invisibles golpeadas
 *      a través de la pared del safe room) se cierra en Amy v53 con
 *      LOS obligatorio en el swing; este hardening es la red de
 *      seguridad si algo más coloca una witch en geometria.
 *
 *  v2.3 - FIX del diagnostico v52 (crash del martillo en el capítulo
 *  siguiente): (1) ELIMINADO el PrecacheModel "lazy" dentro de
 *  WitchFlight_Ring: se llamaba en pleno gameplay (lanzamiento/
 *  aterrizaje de la witch) y el precache fuera de la fase de mapa
 *  es un vector conocido de inestabilidad del motor en L4D2
 *  (índices de modelo no sincronizados con los clientes). Ahora el
 *  sprite se precachea UNA VEZ POR MAPA en WitchFlight_OnMapStart
 *  (la llama el manager) y si por alguna razón no esta disponible, el
 *  ring visual se OMITE (es solo VFX, el vuelo funciona igual).
 *  (2) Logging del ciclo de vuelo al mismo archivo de diagnostico
 *  de Amy (logs/amy_hammer_debug.log) para rastrear launches/
 *  aterrizajes/restauraciones si el crash cae en esta cadena.
 *
 *  v2.2 - NUEVA API WitchFlight_OnMapEnd() (crash del martillo en el
 *  capítulo siguiente de la campaña): limpieza INMEDIATA y garantizada
 *  en el fin de mapa (mata el tick de 33 Hz y vacía los 4 slots) en vez
 *  de confiar en la autolimpieza "al primer tick del mapa nuevo". El
 *  diseño por-referencia ya era seguro (refs del mapa anterior resuelven
 *  a INVALID), pero ahora CERO callbacks corren con datos del mapa
 *  anterior: el cableado vive en el manager (OnMapEnd -> aquí).
 *  El manager la llama ANTES que a los OnMapEnd de los modulos.
 *
 *  v2.1: nueva API WitchFlight_CheckDead(witch). El golpe de Amy puede
 *  MATAR a la witch en pleno vuelo (el dano llega justo tras el
 *  lanzamiento): antes el cadaver esperaba congelado (FL_FROZEN +
 *  MOVETYPE_NONE) hasta el siguiente tick de 33 Hz. Los callers ahora
 *  la restauran AL INSTANTE justo después de aplicar dano.
 *
 *  v2.0 - FIX DEL BUG "la witch no se levanta del suelo y sigue
 *  activa" (reportado en juego con v1.x):
 *   - v1.x solo ponía MOVETYPE_NONE. PROBLEMA REAL: la witch NO se
 *     mueve por la física del movetype: es un NextBot cuya función
 *     DoThink corre CADA TICK (SetNextThink(gpGlobals->curtime), ver
 *     NextBot.cpp del Source SDK 2013) y su locomoción escribe la
 *     posición/velocidad directamente. El think sigue corriendo con
 *     MOVETYPE_NONE -> su IA seguía viva: seguía persiguiendo,
 *     atacando y su locomoción re-escribía la posición encima de
 *     nuestros teleports (por eso parecía "no levantarse").
 *   - SOLUCION (v2.0): el gate del propio motor. El mismo DoThink
 *     solo actualiza los componentes si:
 *         if (!NextBotStop.GetBool() && (GetFlags() & FL_FROZEN) == 0)
 *             Update();
 *     -> FL_FROZEN apaga la IA del NextBot SIN romper su calendario
 *     de thinks (equivalente local del cvar nb_stop). Ahora si:
 *     vuela de verdad (nadie re-escribe su posición), no ataca ni
 *     persigue mientras vuela, y al aterrizar se reactiva sola.
 *   - Además: cada tick de vuelo se RE-AFIRMA el estado (FL_FROZEN |
 *     MOVETYPE_NONE) por si algo externo lo limpia, y se re-sincroniza
 *     la velocidad de la entidad con la simulada.
 *
 *  v1.1: el ring de despegue solo sale en lanzamientos NUEVOS. En los
 *  re-golpes/re-empujes (el laser de Tails relanza cada 0.1s mientras
 *  el rayo la mantiene) no se repite el VFX (antes: 10 anillos/seg).
 *
 *  POR QUE ESTE SISTEMA (investigación del bug "la witch no se
 *  puede levantar / reacción rara"):
 *   - La Witch NO es un jugador (CTerrorPlayer) como el Tank o los
 *     especiales: es un NPC con IA NextBot propia. Wiki de Valve:
 *     "A Witch, controlled by NextBot AI".
 *   - No tiene estado "knocked down" como los comunes ni "stagger"
 *     como los especiales: es inmune al sistema de tropiezos del
 *     juego (ni el lanzagranadas la tambalea).
 *   - El vuelo lo integramos nosotros: gravedad manual, colisión
 *     solo contra el mundo (rayos con filtro que ignora entidades),
 *     deslizamiento en paredes y aterrizaje al detectar suelo. Al
 *     ATERRIZAR (o por seguridad a los 4s, o si muere en vuelo) se
 *     restaura TODO (movetype original + flags) y su IA se reactiva
 *     al instante, sin estado residual.
 *
 *  SEGURIDAD (nada de estados rotos jamás):
 *   - Timeout de WITCHFLIGHT_MAX_AIR segundos máximo en el aire.
 *   - Restauración si muere en vuelo / si el edict se recicla / si
 *     deja de ser clase "witch".
 *   - Timer SIN TIMER_FLAG_NO_MAPCHANGE + slots por REFERENCIA: al
 *     cambiar de mapa los slots inválidos se limpian solos.
 *   - Guard de restauración: solo se devuelve el movetype si la witch
 *     sigue en el NONE que pusimos (no se pisa estado ajeno), y el
 *     FL_FROZEN se quita solo en el slot que lo puso.
 *
 *  API:
 *   - WitchFlight_OnMapStart(): v2.3 - PRECACHE del sprite del ring
 *     (llamar desde el OnMapStart del manager, junto al resto).
 *   - WitchFlight_OnMapEnd(): limpieza de fin de mapa (manager).
 *   - WitchFlight_Launch(witch, attacker, velocity): lanza la witch
 *     suspendiendo su IA. false = no es witch / no hay slot libre
 *     (en ese caso no se toca NADA del estado de la entidad).
 *   - WitchFlight_IsFlying(witch): la witch está en pleno vuelo.
 *   - WitchFlight_CheckDead(witch): v2.1 - llamar justo después de
 *     daniar a una witch en vuelo: si murió, la restaura YA (sin
 *     esperar al tick de 33 Hz). No-op inocuo si sigue viva.
 * ======================================================
 */

#if defined _witch_flight_included
    #endinput
#endif
#define _witch_flight_included

#if !defined _sourcemod_included
    #include <sourcemod>
#endif
#if !defined _sdktools_included
    #include <sdktools>
#endif
#if !defined _sdkhooks_included
    #include <sdkhooks>
#endif

// =======================
// Constantes
// =======================
#define WITCHFLIGHT_SLOTS      4       // witches volando a la vez (max)
#define WITCHFLIGHT_TICK       0.03    // integración a ~33 Hz
#define WITCHFLIGHT_MAX_AIR    4.0     // segundos de vuelo máximo (seguridad)
#define WITCHFLIGHT_GRAVITY    800.0   // = sv_gravity por defecto
#define WITCHFLIGHT_TERMINAL   1600.0  // velocidad de caida máxima
#define WITCHFLIGHT_MAX_SPEED  2200.0  // velocidad de lanzamiento máxima
#define WITCHFLIGHT_LAND_STUN   0.75    // v2.5: stun de aterrizaje (segundos de IA congelada tras tocar suelo)
#define WITCHFLIGHT_CRASH_SPEED 500.0   // v2.6: vel de entrada en pared/techo que cuenta como CHOQUE (dano + stun)
#define WITCHFLIGHT_IMPACT_CD   1.0     // v2.6: anti-spam del dano de impacto (segundos, por vuelo)

// =======================
// Estado por slot
// =======================
static int    g_iWFRef[WITCHFLIGHT_SLOTS];      // referencia de entidad
static int    g_iWFOrigMT[WITCHFLIGHT_SLOTS];   // movetype ORIGINAL (pre-vuelo)
static int    g_iWFAttacker[WITCHFLIGHT_SLOTS]; // autor del golpe (credito)
static float  g_vWFVel[WITCHFLIGHT_SLOTS][3];   // velocidad simulada
static float  g_fWFStart[WITCHFLIGHT_SLOTS];    // inicio del vuelo
static float  g_fWFLast[WITCHFLIGHT_SLOTS];     // último tick (para dt real)
static float  g_fWFLandStunUntil[WITCHFLIGHT_SLOTS]; // v2.5: fin del stun de aterrizaje (0 = volando, no en stun)
static float  g_fWFImpactDmgAt[WITCHFLIGHT_SLOTS];   // v2.6: último dano de impacto del slot (anti-spam)
static Handle g_hWFTick = null;                 // timer global (compartido)
static int    g_iWFSprite = 0;                  // v2.3: sprite del ring (precache por mapa)
static ConVar g_cvWFDbg = null;                 // v2.3: amy_dbg_log (buscado lazy)

// ============================================================
//  v2.3 - LOG (al archivo de diagnostico de Amy)
// ============================================================
static void WFDbg(const char[] fmt, any ...)
{
    if (g_cvWFDbg == null) g_cvWFDbg = FindConVar("amy_dbg_log");
    if (g_cvWFDbg == null || !g_cvWFDbg.BoolValue) return;
    char buf[192];
    VFormat(buf, sizeof(buf), fmt, 2);
    LogToFile("amy_hammer_debug.log", buf);
}

// ============================================================
//  API PUBLICA
// ============================================================

// v2.3: PRECACHE del sprite del ring UNA VEZ POR MAPA. Llamar desde el
// OnMapStart del manager (antes de que cualquier witch pueda volar).
// El PrecacheModel en pleno gameplay (patron "lazy" de v1.x-v2.2) es
// un vector de inestabilidad conocido del motor en L4D2: fuera de la
// fase de precache de mapa, los índices de modelo no están garantizados
// sincronizados con los clientes conectados.
public void WitchFlight_OnMapStart()
{
    g_iWFSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    WFDbg("=== WitchFlight v2.6 OnMapStart: sprite ring=%d ===", g_iWFSprite);
}

// v2.2: limpieza de fin de mapa. Llamar desde el manager en OnMapEnd.
// Mata el tick global (si sigue vivo) y vacía los 4 slots. Idempotente
// y segura en ambos estados (timer vivo: KillTimer es dueño legitimo;
// timer ya apagado por el propio callback: el handle quedó en null).
// Las witches en vuelo mueren con el mapa junto con TODO su estado - no
// hay nada que restaurar de ellas aquí.
public void WitchFlight_OnMapEnd()
{
    WFDbg("=== WitchFlight OnMapEnd: matando tick + vaciando slots ===");
    if (g_hWFTick != null)
    {
        KillTimer(g_hWFTick);
        g_hWFTick = null;
    }
    for (int i = 0; i < WITCHFLIGHT_SLOTS; i++)
    {
        WitchFlight_Clear(i);
    }
}

public bool WitchFlight_IsFlying(int witch)
{
    if (witch <= MaxClients || !IsValidEntity(witch)) return false;
    int ref = EntIndexToEntRef(witch);
    for (int i = 0; i < WITCHFLIGHT_SLOTS; i++)
    {
        if (g_iWFRef[i] != 0 && g_iWFRef[i] == ref) return true;
    }
    return false;
}

// v2.1: llamada por los callers justo después de aplicar dano a una
// witch en vuelo (strike/salto de Amy, puño de Knuckles...). Si el
// golpe la mató, restaura TODO al instante para que la muerte proceda
// con el estado normal del motor (sin FL_FROZEN ni MOVETYPE_NONE
// residuales sobre el cadaver). No-op inocuo si sigue viva o no vuela.
void WitchFlight_CheckDead(int witch)
{
    if (witch <= MaxClients || !IsValidEntity(witch)) return;

    int ref = EntIndexToEntRef(witch);
    for (int i = 0; i < WITCHFLIGHT_SLOTS; i++)
    {
        if (g_iWFRef[i] == 0 || g_iWFRef[i] != ref) continue;

        char cls[16];
        GetEntityClassname(witch, cls, sizeof(cls));
        if (StrEqual(cls, "witch", false)
            && GetEntProp(witch, Prop_Data, "m_iHealth") <= 0)
        {
            WitchFlight_Restore(i, witch, false);
        }
        return;   // una witch solo ocupa un slot
    }
}

// Lanza la witch suspendiendo su IA de locomoción.
// Devuelve false (sin tocar nada) si no es witch válida o no hay slot.
bool WitchFlight_Launch(int witch, int attacker, const float velocity[3])
{
    if (witch <= MaxClients || !IsValidEntity(witch)) return false;

    char cls[16];
    GetEntityClassname(witch, cls, sizeof(cls));
    if (!StrEqual(cls, "witch", false)) return false;

    // v2.4: GUARD DE SALUD. Una witch muerta o muriendo (salud <= 0) no
    // se lanza NUNCA: su maquina de estados está en plena transición de
    // muerte y congelarla (FL_FROZEN) + cambiar su movetype + teleportarla
    // en ese instante es exactamente el tipo de intervention que tumba el
    // motor. Sin vuelo: el dano del golpe sigue su curso normal.
    if (GetEntProp(witch, Prop_Data, "m_iHealth") <= 0)
    {
        WFDbg("[WF] Launch RECHAZADO: witch=%d sin salud (muerta/muriendo)", witch);
        return false;
    }

    // Slot: el suyo si ya está en vuelo (re-golpe en el aire) o uno libre
    int ref = EntIndexToEntRef(witch);
    int slot = -1;
    for (int i = 0; i < WITCHFLIGHT_SLOTS; i++)
    {
        if (g_iWFRef[i] == ref) { slot = i; break; }
        if (slot == -1 && g_iWFRef[i] == 0) slot = i;
    }
    if (slot == -1) return false; // sin slots: ni la tocamos

    WFDbg("[WF] Launch: witch=%d slot=%d attacker=%d vel=(%.0f, %.0f, %.0f)",
          witch, slot, attacker, velocity[0], velocity[1], velocity[2]);

    bool newLaunch = false;
    if (g_iWFRef[slot] != ref)
    {
        // Slot NUEVO: capturar el movetype ORIGINAL antes de suspender
        // la IA. (En un re-golpe NO se re-captura: el original legitimo
        // es el previo al primer lanzamiento, no el NONE que pusimos.)
        g_iWFOrigMT[slot] = view_as<int>(GetEntityMoveType(witch));
        g_iWFRef[slot] = ref;
        newLaunch = true;
        g_fWFImpactDmgAt[slot] = 0.0;   // v2.6: vuelo NUEVO = cooldown de impacto nuevo
    }

    g_iWFAttacker[slot] = (attacker > 0 && attacker <= MaxClients
                           && IsClientInGame(attacker)) ? attacker : 0;

    float vel[3];
    vel = velocity;
    float len = GetVectorLength(vel);
    if (len > WITCHFLIGHT_MAX_SPEED)
    {
        ScaleVector(vel, WITCHFLIGHT_MAX_SPEED / len);
    }

    g_vWFVel[slot] = vel;
    g_fWFStart[slot] = GetEngineTime();
    g_fWFLast[slot]  = GetEngineTime();
    g_fWFLandStunUntil[slot] = 0.0;   // v2.5: re-lanzada = fuera de la fase stun

    // IA suspendida DE VERDAD (v2.0, dos capas):
    //  1) FL_FROZEN: el gate del propio motor NextBot (DoThink solo
    //     invoca Update() si (GetFlags() & FL_FROZEN) == 0). Con el
    //     flag puesto su locomoción/comportamiento no corren -> nadie
    //     re-escribe su posición y no puede atacar en el aire.
    //  2) MOVETYPE_NONE: la física del motor tampoco integra nada.
    // El vuelo lo integramos nosotros en WitchFlight_Tick y su IA se
    // "descongela" sola al restaurar (el calendario de thinks nunca
    // se tocó, sigue re-agendándose cada tick).
    SetEntityMoveType(witch, MOVETYPE_NONE);
    SetEntityFlags(witch, GetEntityFlags(witch) | FL_FROZEN);
    TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, vel);

    // Encarar la dirección de vuelo (queda mirando a donde va)
    WitchFlight_FaceFlight(witch, vel);

    // VFX de despegue: SOLO en lanzamientos nuevos (v1.1). Un re-golpe o
    // el empuje sostenido del laser no repite el ring (serían 10/s).
    if (newLaunch)
    {
        float origin[3];
        GetEntPropVector(witch, Prop_Data, "m_vecAbsOrigin", origin);
        WitchFlight_Ring(origin, 10.0, 120.0, 0.35, 255, 120, 120);
    }

    if (g_hWFTick == null)
    {
        // SIN TIMER_FLAG_NO_MAPCHANGE: si el mapa cambia, los slots por
        // referencia se limpian solos al primer tick y el timer se apaga
        // el solo (active == 0 -> Plugin_Stop). Nunca queda un handle
        // muerto que nadie recrea.
        g_hWFTick = CreateTimer(WITCHFLIGHT_TICK, WitchFlight_Tick, _,
                                TIMER_REPEAT);
    }
    return true;
}

// ============================================================
//  NUCLEO: tick de simulación (20 Hz)
// ============================================================
public Action WitchFlight_Tick(Handle timer)
{
    int active = 0;
    float now = GetEngineTime();

    for (int i = 0; i < WITCHFLIGHT_SLOTS; i++)
    {
        if (g_iWFRef[i] == 0) continue;

        int witch = EntRefToEntIndex(g_iWFRef[i]);
        if (witch <= 0 || !IsValidEntity(witch))
        {
            WitchFlight_Clear(i);   // edict liberado/reciclado
            continue;
        }

        char cls[16];
        GetEntityClassname(witch, cls, sizeof(cls));
        if (!StrEqual(cls, "witch", false))
        {
            WitchFlight_Clear(i);   // el edict ahora es otra entidad
            continue;
        }

        // Murió en pleno vuelo -> restaurar (no dejar un cadaver NONE)
        if (GetEntProp(witch, Prop_Data, "m_iHealth") <= 0)
        {
            WitchFlight_Restore(i, witch, false);
            continue;
        }

        // v2.5: FASE STUN DE ATERRIZAJE (la witch ya tocó suelo pero
        // sigue congelada un instante: su "stagger al aterrizar"). La
        // física ya esta restaurada (movetype original + velocidad
        // cero); solo mantenemos FL_FROZEN hasta que expire.
        if (g_fWFLandStunUntil[i] > 0.0)
        {
            if (now >= g_fWFLandStunUntil[i])
            {
                SetEntityFlags(witch, GetEntityFlags(witch) & ~FL_FROZEN);
                WFDbg("[WF] witch=%d se levanta (fin del stun de aterrizaje)", witch);
                WitchFlight_Clear(i);
                continue;
            }
            // re-afirmar el congelamiento si algo externo lo limpio
            if ((GetEntityFlags(witch) & FL_FROZEN) == 0)
            {
                SetEntityFlags(witch, GetEntityFlags(witch) | FL_FROZEN);
            }
            active++;
            continue;
        }

        // dt real (protegido contra lag spikes)
        float dt = now - g_fWFLast[i];
        if (dt <= 0.0) dt = WITCHFLIGHT_TICK;
        if (dt > 0.25) dt = 0.25;
        g_fWFLast[i] = now;

        // v2.0: RE-AFIRMAR la suspensión cada tick. Si algo externo
        // (un shove del motor, un evento, otro plugin) limpio el
        // movetype o el flag, la witch intentara reactivarse: la
        // congelamos otra vez mientras siga en pleno vuelo.
        if (GetEntityMoveType(witch) != MOVETYPE_NONE)
        {
            SetEntityMoveType(witch, MOVETYPE_NONE);
        }
        if ((GetEntityFlags(witch) & FL_FROZEN) == 0)
        {
            SetEntityFlags(witch, GetEntityFlags(witch) | FL_FROZEN);
        }

        // Seguridad: nunca más de MAX_AIR segundos en el aire
        if (now - g_fWFStart[i] > WITCHFLIGHT_MAX_AIR)
        {
            // Restaurar CON velocidad: el movetype original (STEP) tiene
            // gravedad propia -> la witch cae y aterriza sola, IA activa.
            WitchFlight_Restore(i, witch, true);
            continue;
        }

        float vel[3];
        vel = g_vWFVel[i];

        // Gravedad manual (NONE no integra física)
        vel[2] -= WITCHFLIGHT_GRAVITY * dt;
        if (vel[2] < -WITCHFLIGHT_TERMINAL) vel[2] = -WITCHFLIGHT_TERMINAL;

        float origin[3];
        GetEntPropVector(witch, Prop_Data, "m_vecAbsOrigin", origin);

        // Desplazamiento real del tick (velocidad * dt, SIN margen)
        float move[3];
        move = vel;
        ScaleVector(move, dt);

        // Extremo del rayo con margen anti-tunel: el margen SOLO alarga
        // el trace (para no atravesar paredes delgadas entre ticks), NO
        // acelera a la witch. RayType_EndPoint pide la posición ABSOLUTA.
        float traceEnd[3];
        traceEnd = move;
        float len = GetVectorLength(move);
        if (len > 1.0)
        {
            float pad[3];
            pad = move;
            NormalizeVector(pad, pad);
            ScaleVector(pad, 4.0);
            AddVectors(traceEnd, pad, traceEnd);
        }
        AddVectors(origin, traceEnd, traceEnd);

        // Colisión SOLO contra el mundo (el filtro ignora toda entidad:
        // ni la propia witch, ni jugadores, ni comunes frenan el vuelo)
        Handle trace = TR_TraceRayFilterEx(origin, traceEnd, MASK_SOLID,
                                           RayType_EndPoint,
                                           WitchFlight_WorldOnly, 0);

        // v2.4: ENTIDAD INCRUSTADA: el rayo acierta a fracción ~0 = la
        // witch esta DENTRO de geometria (spawn dentro de pared, empuje
        // a través de muro, nudge mal resuelto). NO hay vuelo posible:
        // restaurarla YA y dejar que su IA/motor la desatasquen (los NPC
        // tienen su propio mecanismo de unstuck). Seguir teleportándola
        // dentro del solido a 20 Hz hasta el timeout = torturar al motor.
        if (TR_DidHit(trace) && TR_GetFraction(trace) < 0.05)
        {
            WFDbg("[WF] witch=%d DENTRO de geometria (fracción %.3f): restauración inmediata", witch, TR_GetFraction(trace));
            delete trace;
            WitchFlight_Restore(i, witch, false);
            continue;
        }

        if (TR_DidHit(trace))
        {
            float hitPos[3], normal[3];
            TR_GetEndPosition(hitPos, trace);
            TR_GetPlaneNormal(trace, normal);

            if (normal[2] >= 0.65)
            {
                // SUELO -> aterrizar
                float land[3];
                land = hitPos;
                land[2] += 32.0;   // dejarla de pie (STEP asienta el resto)
                TeleportEntity(witch, land, NULL_VECTOR, NULL_VECTOR);

                int attacker = g_iWFAttacker[i];
                float impact[3];
                impact = vel;

                // v2.5: STAGGER AL ATERRIZAR (petición v68 de Amy): la
                // física se restaura YA (movetype original + velocidad
                // cero) pero su IA sigue congelada
                // WITCHFLIGHT_LAND_STUN segundos: la witch cae de pie,
                // se queda un instante "levantándose" y su IA se
                // reactiva sola (el bloque de fase stun del tick la
                // vigila; el slot queda ocupado hasta que expire).
                if (GetEntityMoveType(witch) == MOVETYPE_NONE)
                {
                    SetEntityMoveType(witch, view_as<MoveType>(g_iWFOrigMT[i]));
                }
                float zeroVel[3] = {0.0, 0.0, 0.0};
                TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, zeroVel);
                g_fWFLandStunUntil[i] = now + WITCHFLIGHT_LAND_STUN;
                WFDbg("[WF] witch=%d ATERRIZO: física restaurada, stun de aterrizaje %.2fs",
                      witch, WITCHFLIGHT_LAND_STUN);

                // v2.6: dano de impacto con ANTI-SPAM (max 1 por segundo
                // por vuelo): el laser de Tails relanza a la witch cada
                // 0.1s; sin este gate, su ciclo aterrizaje-relanzamiento
                // dispararía dano+hint a 10 Hz. El stun SI se aplica
                // siempre (aterriza "aturdida" aunque el dano este en CD).
                if (now - g_fWFImpactDmgAt[i] >= WITCHFLIGHT_IMPACT_CD)
                {
                    g_fWFImpactDmgAt[i] = now;
                    WitchFlight_Landing(witch, attacker, impact);
                }
                delete trace;

                // v2.6: FIX CRITICO del reporte ("la witch aterriza y no
                // recibe el dano ni reacciona"): esta rama NO sumaba
                // 'active'. Con una sola witch volando (el caso típico)
                // el tick veía active==0 y SE APAGABA en el mismo
                // instante del aterrizaje: el slot seguía ocupado en
                // fase stun, pero nadie quitaba JAMÁS el FL_FROZEN ->
                // witch ESTATUA (sin grito, sin persecución, sin
                // respuesta al dano ni a los disparos) hasta que otro
                // golpe la relanzara. El stun de v2.5 solo expiraba de
                // verdad si OTRA witch seguía volando (su active++
                // mantenia vivo el timer por pura casualidad).
                active++;
                continue;
            }

            // v2.6: CRASH CONTRA PARED/TECHO/PENDIENTE: "tocar
            // superficie = dano" literal. Si la componente de la
            // velocidad que ENTRA en la superficie supera
            // WITCHFLIGHT_CRASH_SPEED, la witch no se desliza
            // amortiguando: CHOCA y recibe el mismo trato que el
            // aterrizaje (dano de impacto + stun + física restaurada
            // + rage). Cubre los empujes horizontales fuertes (puño de
            // Knuckles 800, stagger del laser 650, dash de Sonic)
            // contra muros y techos; el laser sostenido de Tails (450)
            // sigue siendo deslizamiento + su golpe dedicado de 1.5s,
            // como siempre.
            float crashInto = -GetVectorDotProduct(vel, normal);
            if (crashInto >= WITCHFLIGHT_CRASH_SPEED)
            {
                float crashVel[3];
                crashVel = normal;
                ScaleVector(crashVel, -crashInto);

                // Recolocar pegada al impacto, sin incrustarse
                float crashNudge[3], crashPos[3];
                crashNudge = normal;
                ScaleVector(crashNudge, 20.0);
                AddVectors(hitPos, crashNudge, crashPos);
                TeleportEntity(witch, crashPos, NULL_VECTOR, NULL_VECTOR);

                if (GetEntityMoveType(witch) == MOVETYPE_NONE)
                {
                    SetEntityMoveType(witch, view_as<MoveType>(g_iWFOrigMT[i]));
                }
                float crashZero[3] = {0.0, 0.0, 0.0};
                TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, crashZero);
                g_fWFLandStunUntil[i] = now + WITCHFLIGHT_LAND_STUN;
                WFDbg("[WF] witch=%d CRASH contra superficie (vel de entrada %.0f): stun de %.2fs",
                      witch, crashInto, WITCHFLIGHT_LAND_STUN);

                if (now - g_fWFImpactDmgAt[i] >= WITCHFLIGHT_IMPACT_CD)
                {
                    g_fWFImpactDmgAt[i] = now;
                    WitchFlight_Landing(witch, g_iWFAttacker[i], crashVel);
                }
                delete trace;
                active++;
                continue;
            }

            // PARED/TECHO -> deslizar: quitar la componente que entra
            float dot = GetVectorDotProduct(vel, normal);
            if (dot < 0.0)
            {
                float proj[3];
                proj = normal;
                ScaleVector(proj, dot);
                SubtractVectors(vel, proj, vel);
            }
            ScaleVector(vel, 0.85);   // amortiguar un poco el choque

            // Recolocar pegada al impacto, sin incrustarse en la pared
            float nudge[3], safe[3];
            nudge = normal;
            ScaleVector(nudge, 16.0);
            AddVectors(hitPos, nudge, safe);
            TeleportEntity(witch, safe, NULL_VECTOR, NULL_VECTOR);
        }
        else
        {
            // Vuelo libre: avanzar
            float newOrigin[3];
            AddVectors(origin, move, newOrigin);
            TeleportEntity(witch, newOrigin, NULL_VECTOR, NULL_VECTOR);
        }
        delete trace;

        // Sincronizar la velocidad de la entidad (continuidad si hay
        // restauración por timeout) y guardar el estado del slot
        g_vWFVel[i] = vel;
        TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, vel);
        active++;
    }

    if (active == 0)
    {
        g_hWFTick = null;   // nadie volando: apagar el timer
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// El rayo solo colisiona con el MUNDO (ignora toda entidad)
public bool WitchFlight_WorldOnly(int entity, int contentsMask)
{
    return false;
}

// ============================================================
//  RESTAURACION Y LIMPIEZA
// ============================================================

// Devuelve el movetype ORIGINAL a la witch. keepVel=true conserva la
// velocidad simulada (para que el STEP + gravedad real termine la caida);
// keepVel=false la deja en reposo (aterrizaje/muerte).
static void WitchFlight_Restore(int slot, int witch, bool keepVel)
{
    WFDbg("[WF] Restore: slot=%d witch=%d keepVel=%d", slot, witch, keepVel ? 1 : 0);
    if (witch > 0 && IsValidEntity(witch))
    {
        float vel[3];
        if (keepVel)
        {
            vel = g_vWFVel[slot];
        }
        else
        {
            vel[0] = 0.0; vel[1] = 0.0; vel[2] = 0.0;
        }

        // Guard: solo devolver el movetype que pusimos nosotros.
        // v2.5: el guard ya NO envuelve el flag ni la velocidad: en la
        // fase stun de aterrizaje el movetype ya es el ORIGINAL y sin
        // esto la witch quedaría congelada para siempre (el bug de
        // v1.x). El FL_FROZEN de un slot activo es NUESTRO (lo
        // re-afirmamos cada tick de vuelo y de stun).
        if (GetEntityMoveType(witch) == MOVETYPE_NONE)
        {
            SetEntityMoveType(witch, view_as<MoveType>(g_iWFOrigMT[slot]));
        }

        // v2.0/v2.5: devolver el flag de IA (FL_FROZEN). Con eso su
        // DoThink vuelve a llamar Update() al tick siguiente y la
        // witch se reactiva al instante (persigue si esta enojada).
        SetEntityFlags(witch, GetEntityFlags(witch) & ~FL_FROZEN);
        TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, vel);
    }
    WitchFlight_Clear(slot);
}

static void WitchFlight_Clear(int slot)
{
    g_iWFRef[slot] = 0;
    g_iWFOrigMT[slot] = 0;
    g_iWFAttacker[slot] = 0;
    g_fWFStart[slot] = 0.0;
    g_fWFLast[slot] = 0.0;
    g_fWFLandStunUntil[slot] = 0.0;   // v2.5: sin stun de aterrizaje pendiente
    g_fWFImpactDmgAt[slot] = 0.0;     // v2.6: sin cooldown de impacto pendiente
    g_vWFVel[slot][0] = 0.0;
    g_vWFVel[slot][1] = 0.0;
    g_vWFVel[slot][2] = 0.0;
}

// ============================================================
//  ATERRIZAJE: dano de impacto + VFX + aviso
// ============================================================
static void WitchFlight_Landing(int witch, int attacker, const float vel[3])
{
    if (witch <= 0 || !IsValidEntity(witch)) return;

    float pos[3];
    GetEntPropVector(witch, Prop_Data, "m_vecAbsOrigin", pos);

    // Dano de impacto proporcional a la velocidad de aterrizaje
    float speed = GetVectorLength(vel);
    float dmg = speed * 0.055;
    if (dmg < 15.0) dmg = 15.0;
    if (dmg > 150.0) dmg = 150.0;

    if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
    {
        SDKHooks_TakeDamage(witch, attacker, attacker, dmg, DMG_CLUB);
        PrintHintText(attacker,
            "<font color='#FF69B4' size='20'>>> WITCH DERRIBADA! <<</font>\n\
<font color='#FFFFFF'>Dano de impacto: -%.0f HP</font>", dmg);
    }
    else
    {
        SDKHooks_TakeDamage(witch, 0, 0, dmg, DMG_CLUB);
    }

    // v2.6: REACCION GARANTIZADA. El dano solo "asusta" de verdad a
    // la witch si su IA alcanza a procesarlo, y su IA estuvo
    // congelada (FL_FROZEN) durante todo el vuelo: el rage pudo no
    // rampar nunca y al reactivarse quedarse TRANQUILA (se vuelve a
    // sentar como si nada). Forzamos m_rage a tope: al expirar el stun
    // de aterrizaje se levanta ENFADADA y persigue a quien la mandó a
    // volar. El guard de netprop cubre la remota posibilidad de una
    // build del servidor sin m_rage expuesto (se omite sin error de
    // runtime; la witch ya se asusto igual por el propio dano).
    if (GetEntProp(witch, Prop_Data, "m_iHealth") > 0
        && FindSendPropInfo("witch", "m_rage") != -1)
    {
        SetEntPropFloat(witch, Prop_Send, "m_rage", 1.0);
        WFDbg("[WF] witch=%d ENFADADA al tocar superficie (m_rage=1.0)", witch);
    }

    // VFX de aterrizaje: onda expansiva
    WitchFlight_Ring(pos, 10.0, 250.0, 0.6, 255, 80, 130);
}

// ============================================================
//  HELPERS
// ============================================================

// Onda expansiva visual (sprite nativo).
// v2.3: usa el índice precacheado EN OnMapStart (NUNCA PrecacheModel en
// pleno juego). Si el sprite no esta disponible, el ring se omite: es
// solo VFX, el vuelo funciona igual.
static void WitchFlight_Ring(const float pos[3], float startR, float endR,
                             float life, int r, int g, int b)
{
    if (g_iWFSprite <= 0) return;

    int color[4];
    color[0] = r; color[1] = g; color[2] = b; color[3] = 200;
    TE_SetupBeamRingPoint(pos, startR, endR, g_iWFSprite, 0, 0, 15, life,
                          12.0, 0.0, color, 0, 0);
    TE_SendToAll();
}

// Encara la witch hacia la dirección del vuelo (solo yaw)
static void WitchFlight_FaceFlight(int witch, const float vel[3])
{
    float horiz = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
    if (horiz < 50.0) return;   // caida casi vertical: no rotar

    float angles[3];
    angles[0] = 0.0;
    angles[1] = RadToDeg(ArcTangent2(vel[1], vel[0]));
    angles[2] = 0.0;
    TeleportEntity(witch, NULL_VECTOR, angles, NULL_VECTOR);
}
