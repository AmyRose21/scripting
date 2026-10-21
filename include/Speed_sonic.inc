/*
 * ======================================================
 *  [MODULO] Speed Sonic - Zapatos de Velocidad v3.3
 *
 *  v3.3 (manager 3.77.13) - SIN AURA (pedido del owner
 *  2026-10-08: "ajustas el speed para que desde ahora no
 *  muestre el aura alrededor del modelo oculto del survivor
 *  ni tampoco el del avatar — solo se vera el trail"): el glow
 *  outline (m_iGlowType 3 + color) se retiró por completo — se
 *  dibuja SOBRE el cuerpo invisible (L4D2 dibuja el contorno
 *  aunque el modelo viaje en RENDER_NONE) y sobre las 2 copias
 *  del avatar = el "aura" que molestaba. Speed_SetBoostGlow
 *  queda como NO-OP documentado; el TRAIL de colores (BeamFollow
 *  sobre el avatar) queda como único efecto persistente.
 *
 *  v3.2 - STACK ADITIVO COMPARTIDO + ADRENALINA (feedback del owner
 *  09/30: "el MAX solo servia como dano y velocidad en si... no debe
 *  hacer conflicto con speed: si se usa uno y otro la velocidad SUMA;
 *  también haz que la velocidad sume la velocidad adicional del chute
 *  de adrenalina"): este modulo es ahora la AUTORIDAD ÚNICA de
 *  m_flMaxspeed del suite — UNA sola escritura por tick que SUMA todas
 *  las fuentes de velocidad del jugador (cero escritores enfrentados
 *  = cero conflicto):
 *      target = base x (1 + extra_sonic + extras_externos) + adrenalina
 *  - API NUEVA para modulos externos (Metal Overdrive etc.):
 *    Speed_StackSet(client, slot, extra) / Speed_StackTotalExtra /
 *    Speed_StackAnyActive / Speed_StackClear. SLOT 0 = Overdrive de
 *    Metal (+30% real). El hook por tick vive mientras haya CUALQUIER
 *    fuente activa (boost sonic O stack externo), y se suelta solo.
 *  - ADRENALINA (chute): m_bAdrenalineActive (netprop real de L4D2,
 *    el mismo que usa la lux library de left4dhooks) -> +40 uu/s
 *    (vanilla: 220 -> 260) SUMADOS al objetivo mientras nuestro writer
 *    este activo. Sin esto, el write por tick caía DESPUÉS del recalc
 *    del motor y ABSORBIA el bono (con boost activo el chute "no daba
 *    nada"). Ahora siempre suma, literal como pidió el owner.
 *  - SNAPSHOT ANTI DOBLE-CUENTA: si !speed se activa con adrenalina o
 *    stack ya activos, se resta el bono (y se des-multiplica el stack)
 *    para capturar la base NATURAL limpia.
 *  - WATCHDOG 2/3/4 re-escritos para la fuente múltiple (re-hook si
 *    cualquier fuente activa, unhook solo si NINGUNA, y 4a re-aplica
 *    la fórmula completa — saltando estados pausados/inválidos).
 *
 *  v3.1 - MULTIPLICADOR 2.5 -> 3.5 (feedback del owner 09/30:
 *  "AHORA SI FUNCIONA COMO VELOCIDAD REAL EN SI... solo que
 *  debes aumentar la velocidad de 2.5 a 3.5"): 220 x 3.5 =
 *  770 uu/s reales. Mismo método maxspeed (cero cambios de
 *  física), solo el tope sube. El cvar sm_sonic_speedmult
 *  sigue vivo (1.1-8.0) para ajustar en servidor.
 *
 *  v3.0 CAMBIO DE MÉTODO - MAXSPEED REAL (feedback del owner
 *  09/30: "cambiemos el método, usaremos maxspeed; aún con 2.5
 *  se siente debil y si salto llego literalmente a la pared en
 *  un instante"): el boost YA NO toca m_flLaggedMovementValue
 *  ni m_flGravity. Aplica VELOCIDAD REAL vía m_flMaxspeed
 *  (base 220 x multiplicador) re-aplicada cada tick en
 *  PreThinkPost (después de la recomputación de velocidad del
 *  juego, antes del movimiento de ese tick).
 *  POR QUE: el lagged ESCALA EL TIEMPO. El servidor simula 2.5x
 *  pero la predicción del cliente corre a 1x (rubber-band, se
 *  siente "debil") y el salto se reproduce en fast-forward (por
 *  eso "llegaba a la pared en 0.000001 s"). Con maxspeed el
 *  tiempo fluye a 1x: salto 100% vanilla (misma altura, mismo
 *  arco temporal), gravedad intacta, predicción perfecta del
 *  cliente (suave) y el alcance horizontal del salto sube igual
 *  que la velocidad de carrera, pero CONTROLABLE.
 *  BONUS de robustez: al no tocar el lagged, desaparece el
 *  conflicto con los multiplicadores de Amy (1.35), Shadow
 *  (1.3), Knuckles (0.7) y los estados de Metal.
 *
 *  v2.5 FIX CRITICO - EL BUCLE INFINITO DEL WATCHDOG (log del usuario
 *  09/09: "Invalid timer handle (error 3)" + "Velocidad normal
 *  restaurada" repetidos cada 1 s): los timers repetidos del boost
 *  (Trail/AfterImage/HUDUpdate/HUDFast) morian solos (return
 *  Plugin_Stop) sin anular su handle guardado -> el handle quedaba
 *  colgante -> ClearClientTimers hacia KillTimer de un handle MUERTO ->
 *  la excepción abortaba Timer_ResetStats antes de ResetClientState ->
 *  g_bIsBoosted atascado -> el watchdog re-disparaba cada segundo para
 *  siempre. Fix: toda auto-parada anula su handle (patron "if (g_hX ==
 *  timer) g_hX = null" ya usado aquí) + Timer_ResetStats anula
 *  g_hResetTimer al entrar (la llamada directa del watchdog llega con
 *  handles posiblemente muertos).
 *
 *  v2.4 FIX CRITICO - EL CRASH DEL CAPÍTULO 2 (causa raíz):
 *  - El kill-if KillTimer(g_hWatchdogTimer) de Speed_OnMapStart lanzaba
 *    "Invalid timer handle" en el OnMapStart del SEGUNDO mapa de cada
 *    sesión: el timer lleva TIMER_FLAG_NO_MAPCHANGE (SM lo mata solo al
 *    cambiar de mapa) pero la variable conservaba el handle muerto.
 *    Esa excepción ABORTABA el OnMapStart del manager entero: los 10
 *    personajes (Amy incluida) se quedaban SIN precache ni reset en el
 *    mapa 2+, y el jugo del golpe del impulso usaba sonidos/sprites con
 *    índices obsoletos del mapa anterior -> CIERRE DEL JUEGO al golpear
 *    zombies en el capítulo 2. Fix: CERO KillTimer aquí (creación
 *    incondicional, una instancia por mapa) + nuevo Speed_OnMapEnd que
 *    olvida los handles que SM ya mató. El manager además pasa a llamar
 *    a Speed_OnMapStart AL FINAL (blindaje anti-abort).
 *  - Eliminada la creación del watchdog/tips en OnPluginStart: el dueto
 *    dejaba dos watchdogs corriendo en el primer mapa.
 *
 *  v2.3 FIXES DE BUGS CRITICOS (mapchange):
 *  - El watchdog de seguridad y los tips automáticos morian para siempre
 *    al primer cambio de mapa (se creaban UNA vez en OnPluginStart con
 *    TIMER_FLAG_NO_MAPCHANGE, que mata el timer al cambiar de mapa; el
 *    comentario anterior deca lo contrario y era falso). Ahora se
 *    recrean en cada Speed_OnMapStart.
 *  - "Invalid Handle" en el log tras cambiar de mapa: los timers por
 *    cliente (trail/HUD/reset/afterimage) mueren en silencio con el mapa
 *    y sus handles quedaban colgados; el primer ClearClientTimers haca
 *    KillTimer sobre un handle ya cerrado. Ahora Speed_OnMapStart anula
 *    todos los handles y resetea el estado de boost.
 *
 *  v2.2 CHANGES (UPDATE DE CALIDAD DE VIDA):
 *  - ELIMINADO por completo el efecto FOV de "rush": en L4D2 el FOV
 *    extendido esconde el arma en primera persona. El boost ya no toca
 *    m_iFOV en ningún caso (se quitó el ConVar sm_sonic_fov).
 *  - FIX countdown real: antes el HUD solo se actualizaba cada 5s, así que
 *    el "SPEED ENDING 3-2-1" casi nunca llegaba a verse. Ahora en los
 *    últimos 5s el HUD pasa a modo rápido (1s) con tick sonoro real.
 *  - FIX lógico: solo sobrevivientes pueden activar el boost (antes un
 *    jugador del equipo infectado también podía usarlo en versus).
 *  - QoL: aviso en pantalla la primera vez que el boost se pausa (incap,
 *    agua, escalera o agarre), antes solo había log de debug.
 *  - QoL: feedback claro al desactivar manualmente con !speed.
 *  - ConVars vivas: sm_sonic_speedmult / sm_sonic_duration /
 *    sm_sonic_cooldown / sm_sonic_gravity
 *
 *  v2.1 CHANGES (anteriores):
 *  - Multiplicador por defecto 3.5x (v3.1, pedido del owner: 2.5 se quedaba
 *    corto); todo configurable en vivo vía ConVars
 *  - !speed es un TOGGLE limpio ON/OFF sin menus (!speedmenu abre el menú)
 *  - 1 mensaje de bienvenida por mapa; sin doble ejecución de comandos
 *    de chat; corregidos typo "VELLOCIDAD" y color \x5 inválido
 *
 *  v2.0 CHANGES - MEJORA MASIVA:
 *
 *  1. ROBUSTEZ DE CÓDIGO:
 *     - Validaciones estrictas en cada función (client > 0, <= MaxClients, IsClientInGame, IsPlayerAlive)
 *     - Protección contra double-hook (SDKUnhook antes de SDKHook)
 *     - Limpieza segura de handles con null checks
 *     - Array bounds checking en todos los accesos
 *     - Clamps de valores (velocidad 0.1-10.0, gravedad 0.01-5.0)
 *     - ConVars con validación null antes de usar
 *     - Cookies con validación de carga correcta
 *
 *  2. SEGURIDADES:
 *     - Detección de estados inválidos (incapacitated, pounceAttacker, tongueOwner,
 *       jockeyAttacker, pummelAttacker, carryAttacker) para pausar el boost
 *     - Pausa automática en agua (water level > 1) y escaleras
 *     - Protección contra uso durante round_end o map_change
 *     - Validación de que el cliente sigue siendo válido en cada tick
 *
 *  3. WATCHDOG MEJORADO (detecta y repara 5 tipos de bugs):
 *     a) Estado colgado: g_bIsBoosted=true pero buffEnd ya expiro
 *     b) Hook fantasma: g_bIsBoosted=true pero el hook no está activo
 *     c) Timer zombie: timers activos pero cliente desconectado
 *     d) Velocidad corrupta: m_flLaggedMovementValue fuera de rango
 *     e) Gravedad corrupta: m_flGravity <= 0 o > 5.0
 *     - Auto-fix sin intervención manual
 *     - Log detallado de cada fix aplicado
 *
 *  4. MEJORAS AL CÓDIGO DE VELOCIDAD:
 *     - Speed ramp: aceleración gradual (no instantanea) durante 0.5s
 *     - Detección de incap/water/ladder para pausar el boost sin cancelarlo
 *     - Cap de velocidad máxima (SPEED_MAX_MULT = 3.0) para evitar saltos raros
 *     - Suavizado de transición al desactivar (deceleración gradual)
 *     - Hook en PreThink + OnPlayerRunCmd para máxima precisión
 *
 *  5. EFECTOS TIPO SONIC:
 *     - Ring de chispas azules al activar (TE_SetupSparks + beam ring)
 *     - Trail persistente con color configurable (beam follow)
 *     - Shockwave expansiva (beam ring point que crece)
 *     - After-images (sprites fantasma cada 0.2s)
 *     - Glow effect durante el boost (entity glow)
 *     - Ring de desactivación al terminar (rojo para diferenciar)
 *     - Particulas de velocidad (weapon_pipebomb trail reutilizado)
 *     - Sonido de activación + desactivación + tick cuando queda poco
 *
 *  6. MINI-INTERFAZ MEJORADA:
 *     - Menú principal con 5 opciones (Activar, Color, Estado, Reset, Ayuda)
 *     - HUD con tiempo restante (PrintHintText cada 5s)
 *     - PrintCenterText cuando quedan < 3s ("SPEED ENDING!")
 *     - PrintCenterText con countdown en los últimos 3s
 *     - Sonidos de feedback (activación, desactivación, low time)
 *     - Barra de progreso visual en chat
 *
 *  7. SISTEMA DE AYUDA:
 *     - Comando !speedhelp / !sonichelp
 *     - Mensaje de bienvenida al conectar (PrintToChat con tips)
 *     - Tips automáticos cada 60s si el jugador no ha usado el boost
 *     - Información detallada en el menú (cooldown, duración, color actual)
 *     - Comando !speedinfo para ver estado actual
 *
 *  Comandos disponibles:
 *    !speed / !sonic       - Activar boost o abrir menú si ya está activo
 *    !speedmenu / !sonicmenu - Abrir menú principal
 *    !speedhelp / !sonichelp - Ver ayuda completa
 *    !speedinfo / !sonicinfo - Ver estado actual
 *    !resetspeed            - Resetear manualmente
 *    !colortrail            - Cambiar color del trail
 * ======================================================
 */

#if defined _Speed_sonic_included
    #endinput
#endif
#define _Speed_sonic_included

#if !defined _sourcemod_included
    #include <sourcemod>
#endif
#if !defined _sdktools_included
    #include <sdktools>
#endif
#if !defined _sdkhooks_included
    #include <sdkhooks>
#endif
#if !defined _clientprefs_included
    #include <clientprefs>
#endif

#pragma semicolon 1
#pragma newdecls required

// =======================
// CONFIGURACION (Ajustable vía ConVars también)
// =======================
#define SPEED_MULTIPLIER       3.5    // v3.1: multiplicador objetivo (se aplica a m_flMaxspeed; 220 x 3.5 = 770 uu/s)
#define SPEED_RAMP_DURATION    0.5    // Tiempo de aceleración gradual (segundos)
#define SPEED_BASE_MAXSPEED    220.0  // v3.0: velocidad natural de carrera del survivor (uu/s)
#define GRAVITY_SCALE          0.45   // v3.0: DEPRECATED (sin efecto): ya no se toca la gravedad
#define BUFF_DURATION          21.0   // Duración del boost (valor por defecto)
#define COOLDOWN               30.0   // Tiempo de espera entre usos (valor por defecto)

// v3.2: STACK ADITIVO + ADRENALINA (feedback: "si se usa uno y otro la
// velocidad SUMA... también la del chute de adrenalina")
#define SPEED_ADRENALINE_BONUS 40.0   // Vel. adicional del chute (vanilla: 220 -> 260 uu/s)
// v3.3 (suite 3.77.25): 2 -> 3 slots. El SLOT 2 es la EMBESTIDA de Metal
// v5.0 (truco Sonic: la embestida corre por el SUELO con el stack del
// Speed_sonic + auto-forward del RunCmd — el MOTOR lo mueve, escalones y
// rampas incluidos; aditivo puro: si Overdrive (+30%) está activo a la
// vez, el objetivo de la embestida ya viene del stack total).
#define SPEED_STACK_SLOTS      3      // Fuentes externas registrables en el stack
#define SPEED_STACK_METAL_OD   0      // SLOT 0: Overdrive de Metal (+30% real)
#define SPEED_STACK_SONIC_SPIN 1      // SLOT 1: bola del spindash de Sonic (sonic.inc)
#define SPEED_STACK_METAL_DASH 2      // SLOT 2: embestida de Metal v5.0 (por suelo)

// v2.2: ya NO hay efecto FOV (escondia el arma en primera persona)
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

#define SPEED_LOW_TIME_THRESHOLD  3.0  // Segundos para activar countdown visual
#define SPEED_HUD_TICK             5.0  // Cada cuánto mostrar HUD
#define SPEED_TIP_INTERVAL        60.0  // Intervalo de tips automáticos

// Limites de seguridad (clamp)
#define SPEED_MIN_CLAMP  0.1
#define SPEED_MAX_CLAMP  10.0
#define GRAVITY_MIN_CLAMP 0.01
#define GRAVITY_MAX_CLAMP 5.0

// =======================
// VARIABLES GLOBALES
// =======================
float g_fLastUse[MAXPLAYERS + 1];
float g_fBaseMaxspeed[MAXPLAYERS + 1];  // v3.0: snapshot de la velocidad natural (0 = sin snapshot)
int   g_PlayerColor[MAXPLAYERS + 1][4]; // RGBA del rastro
Handle g_hTrailTimer[MAXPLAYERS + 1];
Handle g_hResetTimer[MAXPLAYERS + 1];
Handle g_hHUDTimer[MAXPLAYERS + 1];
Handle g_hAfterImageTimer[MAXPLAYERS + 1];
// v2.3: handles de los timers globales (watchdog/tips) para poder
// recrearlos en cada mapa (con NO_MAPCHANGE mueren al cambiar de mapa)
Handle g_hWatchdogTimer = null;
Handle g_hTipsTimer = null;

// === Variables de Estado ===
bool  g_bIsBoosted[MAXPLAYERS + 1];
float g_fBuffEnd[MAXPLAYERS + 1];
float g_fBoostStart[MAXPLAYERS + 1];   // Para calcular el speed ramp
bool  g_bHookActive[MAXPLAYERS + 1];    // Track si el hook está activo (anti double-hook)
bool  g_bPaused[MAXPLAYERS + 1];        // Boost pausado (incap/water/ladder)

// v3.2: STACK ADITIVO de fuentes externas (Overdrive de Metal etc.).
// Cada slot guarda el "extra" multiplicador ADITIVO puro (0.30 = +30%
// sobre la base) que el writer único de este modulo suma al objetivo.
// POR ÍNDICE DE CLIENTE: se limpia SIEMPRE en death/disconnect (o el
// siguiente jugador que recicle el slot heredaria el extra).
float g_fSpeedStackExtra[MAXPLAYERS + 1][SPEED_STACK_SLOTS];

// === Restauración (Snapshots) ===
// v3.0: eliminados los snapshots de lagged/gravedad del método viejo. La
// restauración vuelve a la velocidad natural (g_fBaseMaxspeed) y normaliza
// lagged/gravedad a 1.0 solo como blindaje anti-herencia.

// === Sistema de Tips ===
float g_fNextTipTime[MAXPLAYERS + 1];
bool  g_bHasUsedBoost[MAXPLAYERS + 1];

// === Cookies y Cvars ===
Handle g_hColorCookie;
ConVar g_hCvarDebug;
ConVar g_hCvarRestoreLagged;   // v3.0: DEPRECATED (mantenido por compatibilidad de cfg)
ConVar g_hCvarEnableTips;

// === v2.1: Configuración en vivo del boost (ConVars) ===
ConVar g_hCvarMult;        // sm_sonic_speedmult
ConVar g_hCvarDuration;    // sm_sonic_duration
ConVar g_hCvarCooldown;    // sm_sonic_cooldown
ConVar g_hCvarGravity;     // sm_sonic_gravity

// === v2.1: Mensaje de bienvenida solo 1 vez por mapa ===
bool g_bWelcomeShown[MAXPLAYERS + 1];

// === Sprites cacheados ===
int g_iBeamSprite = -1;
int g_iGlowSprite = -1;
int g_iHaloSprite = -1;

// =======================
// MACROS DE VALIDACION
// =======================
#define Speed_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))
#define Speed_IsClientConnected(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1))

// =======================
// UTILIDADES INTERNAS
// =======================

void DebugLog(const char[] fmt, any ...)
{
    if (g_hCvarDebug == null || !g_hCvarDebug.BoolValue) return;
    char buffer[256];
    VFormat(buffer, sizeof(buffer), fmt, 2);
    PrintToServer("[SonicSpeed DEBUG] %s", buffer);
}

// Clamp seguro para velocidad
float Speed_ClampSpeed(float value)
{
    if (value < SPEED_MIN_CLAMP) return SPEED_MIN_CLAMP;
    if (value > SPEED_MAX_CLAMP) return SPEED_MAX_CLAMP;
    return value;
}

// v3.0: Speed_ClampGravity eliminado (el método maxspeed ya no toca la
// gravedad; GRAVITY_MAX_CLAMP sigue vigente para el watchdog CHECK 5)

// =======================
// v3.2: STACK ADITIVO DE VELOCIDAD (API pública del suite)
// =======================

// Velocidad adicional del chute de adrenalina. El motor ya la suma al
// recalcular m_flMaxspeed, pero el write por tick de este modulo cae
// DESPUÉS de ese recalc y la absorbe: por eso la re-sumamos al objetivo
// explicitamente mientras el writer este activo (netprop real de L4D2,
// el mismo que usa la lux library de left4dhooks).
float Speed_GetAdrenalineBonus(int client)
{
    if (GetEntProp(client, Prop_Send, "m_bAdrenalineActive") > 0)
        return SPEED_ADRENALINE_BONUS;
    return 0.0;
}

// Suma de TODOS los extras externos activos (parte ADITIVA del stack)
float Speed_StackTotalExtra(int client)
{
    float total = 0.0;
    for (int s = 0; s < SPEED_STACK_SLOTS; s++)
        total += g_fSpeedStackExtra[client][s];
    return total;
}

// Hay alguna fuente externa activa?
bool Speed_StackAnyActive(int client)
{
    for (int s = 0; s < SPEED_STACK_SLOTS; s++)
        if (g_fSpeedStackExtra[client][s] > 0.0001)
            return true;
    return false;
}

// Limpia todos los slots (muerte/desconexion/spawn: el índice se recicla)
void Speed_StackClear(int client)
{
    if (client < 1 || client > MaxClients) return;
    for (int s = 0; s < SPEED_STACK_SLOTS; s++)
        g_fSpeedStackExtra[client][s] = 0.0;
}

// v3.2: objetivo TOTAL del jugador (fórmula única del suite):
//   base x (1 + sonicExtra + extras_externos) + adrenalina
// sonicExtra llega por parámetro porque el boost tiene su curva ramp;
// los externos suman plano. Aditivo puro: JAMÁS se multiplican entre si
// ("si se usa uno y otro la velocidad SUMA"). EJEMPLO real: !speed x3.5
// + Overdrive de Metal x1.3 + adrenalina ->
//   220 x (1 + 2.5 + 0.3) + 40 = 876 uu/s.
float Speed_GetStackTarget(int client, float sonicExtra)
{
    float totalExtra = sonicExtra + Speed_StackTotalExtra(client);
    float mult = Speed_ClampSpeed(1.0 + totalExtra);
    return Speed_GetBaseSpeed(client) * mult + Speed_GetAdrenalineBonus(client);
}

// v3.2: registro de una fuente externa (la invoca Metal cada tick mientras
// dura su Overdrive: auto-cura tipo "reafirmación", igual que el
// FLYGRAVITY de la embestida). extra = multiplicador ADITIVO puro
// (0.30 = +30%). Idempotente: sin cambio de valor = cero trabajo.
// Gestiona el ciclo de vida del hook: mientras haya CUALQUIER fuente
// (boost o stack) el writer sigue vivo; con la última apagada restaura
// la velocidad natural y suelta el hook.
void Speed_StackSet(int client, int slot, float extra)
{
    if (client < 1 || client > MaxClients) return;
    if (slot < 0 || slot >= SPEED_STACK_SLOTS) return;
    if (extra < 0.0) extra = 0.0;

    // Idempotente: sin cambio, cero trabajo este tick
    if (FloatAbs(g_fSpeedStackExtra[client][slot] - extra) < 0.0001) return;
    g_fSpeedStackExtra[client][slot] = extra;

    if (!IsClientInGame(client)) return;

    if (g_bIsBoosted[client] || Speed_StackAnyActive(client))
    {
        // Escritura INMEDIATA del nuevo objetivo (la fuente arranca justo
        // ahora; el próximo tick el writer la refina con su ramp exacta)
        if (IsPlayerAlive(client) && !Speed_IsPlayerInInvalidState(client))
        {
            float sonicExtra = 0.0;
            if (g_bIsBoosted[client] && !g_bPaused[client])
                sonicExtra = Speed_ClampSpeed(Speed_GetMultiplier()) - 1.0;
            Speed_ApplyMaxSpeed(client, Speed_GetStackTarget(client, sonicExtra));
        }
        if (!g_bHookActive[client])
        {
            SDKHook(client, SDKHook_PreThinkPost, Speed_OnPreThink);
            g_bHookActive[client] = true;
        }
    }
    else
    {
        // Última fuente apagada: restaurar la natural AHORA (con el bono
        // de adrenalina si está activo: es lo que el motor calcularia por
        // si solo una vez que dejamos de escribir) y soltar el hook.
        if (IsPlayerAlive(client))
            Speed_ApplyMaxSpeed(client, Speed_GetBaseSpeed(client) + Speed_GetAdrenalineBonus(client));
        if (g_bHookActive[client])
        {
            SDKUnhook(client, SDKHook_PreThinkPost, Speed_OnPreThink);
            g_bHookActive[client] = false;
        }
    }
}

// === v2.1: Valores configurables en vivo (con fallback seguro) ===
float Speed_GetMultiplier()   { return (g_hCvarMult != null)     ? g_hCvarMult.FloatValue     : SPEED_MULTIPLIER; }
float Speed_GetDuration()     { return (g_hCvarDuration != null) ? g_hCvarDuration.FloatValue : BUFF_DURATION; }
float Speed_GetCooldown()     { return (g_hCvarCooldown != null) ? g_hCvarCooldown.FloatValue : COOLDOWN; }
float Speed_GetGravityScale() { return (g_hCvarGravity != null)  ? g_hCvarGravity.FloatValue  : GRAVITY_SCALE; }

// Limpia los timers de forma segura
void ClearClientTimers(int client)
{
    if (client < 1 || client > MaxClients) return;

    if (g_hTrailTimer[client] != null && g_hTrailTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hTrailTimer[client]);
        g_hTrailTimer[client] = null;
    }
    if (g_hResetTimer[client] != null && g_hResetTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hResetTimer[client]);
        g_hResetTimer[client] = null;
    }
    if (g_hHUDTimer[client] != null && g_hHUDTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hHUDTimer[client]);
        g_hHUDTimer[client] = null;
    }
    if (g_hAfterImageTimer[client] != null && g_hAfterImageTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hAfterImageTimer[client]);
        g_hAfterImageTimer[client] = null;
    }
}

// Limpia el estado y DESENGANCHA el hook de velocidad
void ResetClientState(int client)
{
    if (client < 1 || client > MaxClients) return;

    // IMPORTANTE: Quitar el hook que fuerza la velocidad (con check de double-unhook)
    // v3.0: PreThinkPost — el write de maxspeed aterriza DESPUÉS de la
    // recomputación de velocidad del juego y ANTES del movimiento del tick.
    // v3.2: si el STACK sigue activo (p.ej. Overdrive de Metal), el writer
    // debe seguir vivo: se mantiene el hook y la fuente externa lo suelta
    // cuando termine (Speed_StackSet / auto-limpieza del propio writer).
    if (!Speed_StackAnyActive(client) && IsClientInGame(client) && g_bHookActive[client])
    {
        SDKUnhook(client, SDKHook_PreThinkPost, Speed_OnPreThink);
        g_bHookActive[client] = false;
    }

    g_bIsBoosted[client] = false;
    g_fBuffEnd[client] = 0.0;
    g_fBoostStart[client] = 0.0;
    g_bPaused[client] = false;
    g_bHookActive[client] = false;

    // v3.0: reset del snapshot de velocidad natural (0 = volver a capturar)
    g_fBaseMaxspeed[client] = 0.0;
}

// v3.0: velocidad natural del jugador (snapshot al activar; 220 por defecto)
float Speed_GetBaseSpeed(int client)
{
    if (g_fBaseMaxspeed[client] >= 80.0 && g_fBaseMaxspeed[client] <= 400.0)
        return g_fBaseMaxspeed[client];
    return SPEED_BASE_MAXSPEED;
}

// v3.0: aplica m_flMaxspeed solo si difiere (evita writes innecesarios del netprop)
void Speed_ApplyMaxSpeed(int client, float value)
{
    float cur = GetEntPropFloat(client, Prop_Data, "m_flMaxspeed");
    if (FloatAbs(cur - value) > 0.5)
        SetEntPropFloat(client, Prop_Data, "m_flMaxspeed", value);
}

// Detecta si el jugador está en un estado inválido para el boost
bool Speed_IsPlayerInInvalidState(int client)
{
    if (!Speed_IsValidClient(client)) return true;

    // Incapacitado
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return true;

    // Siendo atacado por especiales
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return true;   // Hunter
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) return true;      // Smoker
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return true;   // Jockey
    if (GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0) return true;   // Charger
    if (GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0) return true;    // Charger carry

    // En agua profunda
    if (GetEntProp(client, Prop_Data, "m_nWaterLevel") > 1) return true;

    // En escalera
    if (GetEntityMoveType(client) == MOVETYPE_LADDER) return true;

    return false;
}

// =======================
// INICIO DEL MODULO
// =======================

public void Speed_OnPluginStart()
{
    // Inicializar datos de todos los slots
    for (int i = 1; i <= MaxClients; i++)
    {
        g_hTrailTimer[i] = null;
        g_hResetTimer[i] = null;
        g_hHUDTimer[i] = null;
        g_hAfterImageTimer[i] = null;
        g_bHookActive[i] = false;
        g_bPaused[i] = false;
        g_fBoostStart[i] = 0.0;
        g_bHasUsedBoost[i] = false;
        g_fNextTipTime[i] = 0.0;
        g_bWelcomeShown[i] = false;
        ResetClientState(i);
        g_fLastUse[i] = 0.0;
        g_fBaseMaxspeed[i] = 0.0;
        // v3.2: stack de fuentes externas en cero (explícito; SourcePawn
        // ya inicia en cero los globals, pero queda documentado el contrato)
        Speed_StackClear(i);

        // Color por defecto (Azul Sonic clasico)
        g_PlayerColor[i][0] = 0;
        g_PlayerColor[i][1] = 150;
        g_PlayerColor[i][2] = 255;
        g_PlayerColor[i][3] = 200;
    }

    // v2.4: watchdog y tips se crean aquí SOLO para cubrir la carga
    // a mitad de mapa (sm plugins reload: OnMapStart NO dispara en ese
    // flujo y el watchdog quedaría muerto hasta el próximo mapa). NO hay
    // dueto: Speed_OnMapStart tiene guarda anti-dueto y en el arranque
    // normal (OnPluginStart -> OnMapStart) la guarda ve el timer vivo y
    // no crea otro. Cero KillTimer en todo el ciclo de vida.
    g_hWatchdogTimer = CreateTimer(1.0, Timer_WatchdogCheck, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    g_hTipsTimer = CreateTimer(SPEED_TIP_INTERVAL, Timer_AutoTips, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // (Comandos)
    RegConsoleCmd("sm_speed", Command_Speed);
    RegConsoleCmd("sm_sonic", Command_Speed);
    RegConsoleCmd("sm_speedmenu", Command_SpeedMenu);
    RegConsoleCmd("sm_sonicmenu", Command_SpeedMenu);
    RegConsoleCmd("sm_speedhelp", Command_SpeedHelp);
    RegConsoleCmd("sm_sonichelp", Command_SpeedHelp);
    RegConsoleCmd("sm_speedinfo", Command_SpeedInfo);
    RegConsoleCmd("sm_sonicinfo", Command_SpeedInfo);
    RegConsoleCmd("sm_resetspeed", Command_ForceReset);
    RegConsoleCmd("sm_colortrail", Command_ColorMenu);
    RegConsoleCmd("speed", Command_Speed);           // Alias chat
    RegConsoleCmd("sonic", Command_Speed);           // Alias chat
    RegConsoleCmd("speedmenu", Command_SpeedMenu);   // Alias chat
    RegConsoleCmd("speedhelp", Command_SpeedHelp);   // Alias chat
    RegConsoleCmd("speedinfo", Command_SpeedInfo);   // Alias chat
    RegConsoleCmd("colortrail", Command_ColorMenu);  // Alias chat

    // Eventos
    HookEvent("player_disconnect", Event_PlayerDisconnect);
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("player_spawn", Speed_Event_PlayerSpawn);
    HookEvent("round_end", Speed_Event_RoundEnd);

    // Persistencia (cookies)
    g_hColorCookie = RegClientCookie("sonic_trail_color", "Color del rastro Sonic", CookieAccess_Public);

    // ConVars
    g_hCvarDebug = CreateConVar("sm_sonic_debug", "0", "Enable debug logs (0/1)", FCVAR_NONE, true, 0.0, true, 1.0);
    // v3.0: sm_sonic_restore_lagged queda DEPRECATED (el boost ya no toca el
    // lagged; se mantiene creado para que las cfg viejas carguen sin errores)
    g_hCvarRestoreLagged = CreateConVar("sm_sonic_restore_lagged", "1", "DEPRECATED v3.0: sin efecto (maxspeed siempre se restaura)", FCVAR_NONE, true, 0.0, true, 1.0);
    g_hCvarEnableTips = CreateConVar("sm_sonic_tips", "1", "Enable auto tips for new players (0/1)", FCVAR_NONE, true, 0.0, true, 1.0);

    // v2.1: Configuración del boost ajustable EN VIVO (sin recompilar)
    g_hCvarMult     = CreateConVar("sm_sonic_speedmult", "3.5", "v3.1: multiplicador aplicado a m_flMaxspeed (base 220 uu/s, 3.5 = 770)", FCVAR_NOTIFY, true, 1.1, true, 8.0);
    g_hCvarDuration = CreateConVar("sm_sonic_duration", "21.0", "Duración del boost en segundos", FCVAR_NOTIFY, true, 5.0, true, 120.0);
    g_hCvarCooldown = CreateConVar("sm_sonic_cooldown", "30.0", "Enfriamiento entre usos en segundos", FCVAR_NOTIFY, true, 0.0, true, 300.0);
    // v3.0: sm_sonic_gravity queda DEPRECATED (con maxspeed el salto es
    // vanilla: misma altura y mismo arco temporal que sin boost)
    g_hCvarGravity  = CreateConVar("sm_sonic_gravity", "0.45", "DEPRECATED v3.0: sin efecto (el boost ya no modifica la gravedad)", FCVAR_NOTIFY, true, 0.05, true, 1.0);

    // v3.75: AutoExecConfig eliminado - config ÚNICA del suite (Sonic_Suite.cfg, auto-guardada; ver manager). El archivo viejo queda muerto.

    // Carga tardia (Late Load) para jugadores ya conectados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && AreClientCookiesCached(i))
            LoadPlayerColor(i);
    }
}

public void Speed_OnMapStart()
{
    // v2.1: Reiniciar el flag de bienvenida (1 mensaje por mapa)
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bWelcomeShown[i] = false;
    }

    // Precache de sprites (cacheados para no recargarlos en cada uso)
    g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    g_iGlowSprite = PrecacheModel("materials/sprites/glow01.vmt", true);
    g_iHaloSprite = PrecacheModel("materials/sprites/halo01.vmt", true);

    // Precache de sonidos
    PrecacheSound("mobius/sfx/boost.mp3", true);
    PrecacheSound("ambient/energy/zap1.wav", true);
    PrecacheSound("ambient/energy/zap2.wav", true);
    PrecacheSound("buttons/button17.wav", true);
    PrecacheSound("player/survivor/voice/gambler/relayreactivate04.wav", true);

    // ============================================================
    //  v2.4 FIX CRITICO - EL CRASH DEL CAPÍTULO 2 (causa raíz):
    //  los kill-if KillTimer de aquí arriba lanzaban "Invalid timer
    //  handle" en el OnMapStart del SEGUNDO mapa de cada sesión (SM ya
    //  había matado el timer NO_MAPCHANGE al cambiar de mapa y la
    //  variable conservaba el handle muerto). La excepción ABORTABA el
    //  OnMapStart del manager: Amy/Sonic/Tails/Knuckles/Sally/... se
    //  quedaban SIN precache ni reset en el mapa 2+, y el golpe del
    //  impulso de Amy usaba sonidos/sprites con índices obsoletos ->
    //  cierre del juego al golpear zombies en el capítulo 2.
    //
    //  Solución: CERO KillTimer en esta función (no puede lanzar
    //  excepciones). Creación con GUARDA ANTI-DUETO: en un cambio de mapa
    //  normal el handle viejo ya se olvido en Speed_OnMapEnd y aquí se
    //  crea fresco; si ya hay instancia viva (carga mid-map o dueto), la
    //  guarda evita crear otra. Resultado: una instancia por mapa, siempre
    //  vivo, sin matar nada a mano.
    // ============================================================
    // Guarda anti-dueto: si ya hay instancia viva (OnMapStart sin OnMapEnd
    // de por medio) no se crea otra. En un cambio de mapa normal el handle
    // viejo ya se olvido en Speed_OnMapEnd y SM mata el timer al cerrar el
    // nivel, así que aquí siempre se crea fresco.
    if (g_hWatchdogTimer == null)
        g_hWatchdogTimer = CreateTimer(1.0, Timer_WatchdogCheck, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    if (g_hTipsTimer == null)
        g_hTipsTimer = CreateTimer(SPEED_TIP_INTERVAL, Timer_AutoTips, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // v2.3 FIX "INVALID HANDLE": los timers por cliente (trail/HUD/reset/
    // afterimage) llevan NO_MAPCHANGE y mueren en silencio al cambiar de
    // mapa SIN correr su callback -> los handles quedaban colgados y el
    // primer ClearClientTimers posterior haca KillTimer sobre un handle
    // ya cerrado (error de nativa en el log). Se anulan aquí (los timers
    // ya están muertos, solo hay que olvidar los valores) y se resetea el
    // estado de boost: en el nuevo mapa los valores base se re-snapshotearan
    // al spawn (Speed_Event_PlayerSpawn).
    for (int i = 1; i <= MaxClients; i++)
    {
        g_hTrailTimer[i]      = null;
        g_hResetTimer[i]      = null;
        g_hHUDTimer[i]        = null;
        g_hAfterImageTimer[i] = null;

        g_bIsBoosted[i]   = false;
        g_bPaused[i]      = false;
        g_bHookActive[i]  = false;
        g_fBuffEnd[i]     = 0.0;
        g_fBoostStart[i]  = 0.0;
        g_fBaseMaxspeed[i] = 0.0;
    }
}

// ============================================================
//  v2.4 - NUEVO Speed_OnMapEnd: olvidar los handles de los timers
//  NO_MAPCHANGE (watchdog/tips) y de los timers por cliente. Si la
//  variable conservara el valor tras el cambio de mapa, cualquier
//  KillTimer futuro sobre ella reventaría con "Invalid timer handle"
//  (el vector del crash del capítulo 2). Se cablea PRIMERO en el
//  OnMapEnd del manager (cero nativas: no puede abortar la cadena).
// ============================================================
public void Speed_OnMapEnd()
{
    // NO KillTimer aquí (intención): el forward OnMapEnd puede llegar antes
    // o después del auto-kill de SM según el camino de cierre, y KillTimer
    // sobre un handle ya muerto es EXACTAMENTE la excepción que abortaba el
    // OnMapStart del manager. Nullar no puede fallar nunca: los timers
    // NO_MAPCHANGE mueren solos al cerrar el nivel y el próximo OnMapStart
    // crea instancias frescas por la guarda anti-dueto.
    g_hWatchdogTimer = null;
    g_hTipsTimer     = null;

    // v2.3 (movido a donde pertenece): los timers por cliente (trail/HUD/
    // reset/afterimage) también llevan NO_MAPCHANGE y mueren en silencio.
    for (int i = 1; i <= MaxClients; i++)
    {
        g_hTrailTimer[i]      = null;
        g_hResetTimer[i]      = null;
        g_hHUDTimer[i]        = null;
        g_hAfterImageTimer[i] = null;
    }
}

// =======================
// CORE: LÓGICA DE VELOCIDAD
// =======================

// Hook de PreThink: LA ÚNICA escritura de velocidad de todo el suite
// (v3.2: antes solo empujaba el boost sonic; ahora mantiene la suma de
// TODAS las fuentes del jugador mientras haya alguna activa)
public void Speed_OnPreThink(int client)
{
    if (!Speed_IsValidClient(client)) return;

    // v3.2: el writer vive mientras haya CUALQUIER fuente (boost sonic O
    // stack externo). Sin fuentes: auto-limpieza (restaura natural y
    // suelta el hook — imposible dejar un hook zombie colgando).
    if (!g_bIsBoosted[client] && !Speed_StackAnyActive(client))
    {
        if (g_bHookActive[client])
        {
            if (IsPlayerAlive(client))
                Speed_ApplyMaxSpeed(client, Speed_GetBaseSpeed(client) + Speed_GetAdrenalineBonus(client));
            SDKUnhook(client, SDKHook_PreThinkPost, Speed_OnPreThink);
            g_bHookActive[client] = false;
        }
        return;
    }

    // Pausar si está en estado inválido (aplica al boost Y al stack:
    // mientras dure el estado, se escribe la velocidad natural)
    if (Speed_IsPlayerInInvalidState(client))
    {
        if (!g_bPaused[client])
        {
            g_bPaused[client] = true;
            // v3.0: restaurar la velocidad NATURAL mientras este pausado
            // (el lagged/gravedad ya no se tocan: quedan siempre en 1.0)
            Speed_ApplyMaxSpeed(client, Speed_GetBaseSpeed(client));
            // v2.2 QoL: avisar en pantalla SOLO si el boost propio esta
            // activo (el stack externo, p.ej. el Overdrive de Metal,
            // pausa en silencio: su habilidad sigue su curso)
            if (g_bIsBoosted[client])
                PrintCenterText(client, "BOOST PAUSADO\n(incap / agarre / agua / escalera)");
            DebugLog("Player %d: speed writer paused (invalid state)", client);
        }
        return;
    }
    else if (g_bPaused[client])
    {
        // Reanudar
        g_bPaused[client] = false;
        DebugLog("Player %d: speed writer resumed", client);
    }

    float now = GetEngineTime();

    // v3.2: extra del boost sonic (su curva ramp/decel de siempre; 0.0
    // si el boost no está activo — el stack externo puede estarlo solo)
    float sonicExtra = 0.0;
    if (g_bIsBoosted[client])
    {
        float elapsed = now - g_fBoostStart[client];
        float targetMult = Speed_GetMultiplier();

        // SPEED RAMP: aceleración gradual durante SPEED_RAMP_DURATION
        float currentMult;
        if (elapsed < SPEED_RAMP_DURATION)
        {
            // Interpolación lineal de 1.0 al multiplicador objetivo
            float progress = elapsed / SPEED_RAMP_DURATION;
            currentMult = 1.0 + (targetMult - 1.0) * progress;
        }
        else
        {
            // Verificar si estamos cerca del final para decelerar
            float timeRemaining = g_fBuffEnd[client] - now;
            if (timeRemaining < 0.5)
            {
                // Deceleración gradual en los últimos 0.5s
                float progress = timeRemaining / 0.5;
                currentMult = 1.0 + (targetMult - 1.0) * progress;
            }
            else
            {
                currentMult = targetMult;
            }
        }
        sonicExtra = currentMult - 1.0;
    }

    // v3.0: aplicar VELOCIDAD REAL (m_flMaxspeed) — v3.2: en UNA sola
    // escritura se SUMAN todas las fuentes (aditivo, jamás se pisan):
    //   base x (1 + extra_sonic + extras_externos) + adrenalina
    // El tiempo fluye a 1x: salto y gravedad quedan 100% vanilla.
    // PreThinkPost garantiza que el write cae después de cualquier
    // recomputación de velocidad del juego y antes del movimiento.
    Speed_ApplyMaxSpeed(client, Speed_GetStackTarget(client, sonicExtra));
}

// =======================
// COMANDOS PRINCIPALES
// =======================

public Action Command_Speed(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    // v2.1: TOGGLE LIMPIO — si el boost ya está activo, se desactiva directo.
    // (Antes abria un menú molesto; el menú ahora SOLO se abre con !speedmenu)
    if (g_bIsBoosted[client])
    {
        Speed_DeactivateBoost(client);
        return Plugin_Handled;
    }

    if (!IsPlayerAlive(client))
    {
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Debes estar vivo para activar el boost.");
        return Plugin_Handled;
    }

    // v2.2 FIX: solo sobrevivientes (antes un infectado en versus podía usarlo)
    if (GetClientTeam(client) != TEAM_SURVIVOR)
    {
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Solo los sobrevivientes pueden usar el boost.");
        return Plugin_Handled;
    }

    // Verificar estado inválido
    if (Speed_IsPlayerInInvalidState(client))
    {
        PrintToChat(client, "\x04[ZapatosSonic]\x01 No puedes activar el boost en este estado (incapacitado/agua/escalera/being grabbed).");
        return Plugin_Handled;
    }

    float timeNow = GetEngineTime();
    float cooldown = Speed_GetCooldown();
    if (timeNow < g_fLastUse[client] + cooldown)
    {
        float remaining = (g_fLastUse[client] + cooldown) - timeNow;
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Espera \x05%.1f\x01 segundos para reusar.", remaining);
        PrintCenterText(client, "Cooldown: %.1fs", remaining);
        return Plugin_Handled;
    }

    g_fLastUse[client] = timeNow;
    g_bHasUsedBoost[client] = true;
    ApplySpeedBoost(client);
    return Plugin_Handled;
}

public Action Command_SpeedMenu(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    ShowSpeedMainMenu(client);
    return Plugin_Handled;
}

public Action Command_SpeedHelp(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    ShowSpeedHelp(client);
    return Plugin_Handled;
}

public Action Command_SpeedInfo(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    ShowSpeedInfo(client);
    return Plugin_Handled;
}

// =======================
// MENÚ PRINCIPAL (Mini-interfaz)
// =======================

void ShowSpeedMainMenu(int client)
{
    Menu menu = new Menu(MenuHandler_MainMenu);
    menu.SetTitle("ZAPATOS SONIC - Menú Principal");

    if (g_bIsBoosted[client])
    {
        float remaining = g_fBuffEnd[client] - GetEngineTime();
        if (remaining < 0.0) remaining = 0.0;
        char display[64];
        Format(display, sizeof(display), "BOOST ACTIVO - Restante: %.1fs", remaining);
        menu.AddItem("active", display, ITEMDRAW_DISABLED);
        menu.AddItem("reset", "Desactivar boost ahora");
    }
    else
    {
        float timeNow = GetEngineTime();
        if (timeNow < g_fLastUse[client] + Speed_GetCooldown())
        {
            float remaining = (g_fLastUse[client] + Speed_GetCooldown()) - timeNow;
            char info[64];
            Format(info, sizeof(info), "Activar boost (CD: %.1fs)", remaining);
            menu.AddItem("activate_cd", info, ITEMDRAW_DISABLED);
        }
        else
        {
            menu.AddItem("activate", "Activar boost ahora!");
        }
    }

    menu.AddItem("color", "Cambiar color del rastro");
    menu.AddItem("info", "Ver estado actual");
    menu.AddItem("help", "Ayuda completa");

    menu.ExitButton = true;
    menu.Display(client, 30);
}

public int MenuHandler_MainMenu(Menu menu, MenuAction action, int client, int param)
{
    if (action == MenuAction_End)
    {
        delete menu;
    }
    else if (action == MenuAction_Select)
    {
        if (client <= 0 || !IsClientInGame(client)) return 0;

        char info[32];
        menu.GetItem(param, info, sizeof(info));

        if (StrEqual(info, "activate"))
        {
            Command_Speed(client, 0);
        }
        else if (StrEqual(info, "reset"))
        {
            Command_ForceReset(client, 0);
        }
        else if (StrEqual(info, "color"))
        {
            Command_ColorMenu(client, 0);
        }
        else if (StrEqual(info, "info"))
        {
            ShowSpeedInfo(client);
        }
        else if (StrEqual(info, "help"))
        {
            ShowSpeedHelp(client);
        }
    }
    return 0;
}

// =======================
// SISTEMA DE AYUDA
// =======================

void ShowSpeedHelp(int client)
{
    PrintToChat(client, "\x04=== ZAPATOS SONIC - AYUDA ===");
    PrintToChat(client, "\x01 \x05!speed\x01 o \x05!sonic\x01 - Activar/DESACTIVAR el boost (toggle)");
    PrintToChat(client, "\x01 \x05!speedmenu\x01 - Abrir este menú");
    PrintToChat(client, "\x01 \x05!speedinfo\x01 - Ver estado actual (boost, cooldown, color)");
    PrintToChat(client, "\x01 \x05!colortrail\x01 - Cambiar color del rastro");
    PrintToChat(client, "\x01 \x05!resetspeed\x01 - Desactivar boost manualmente");
    PrintToChat(client, "\x01 \x05!speedhelp\x01 - Mostrar esta ayuda");
    PrintToChat(client, "\x04==============================");
    PrintToChat(client, "\x01 Duración: \x05%.0fs\x01 | Cooldown: \x05%.0fs\x01 | Multiplicador: \x05%.1fx\x01",
        Speed_GetDuration(), Speed_GetCooldown(), Speed_GetMultiplier());
    PrintToChat(client, "\x01 Configurable en vivo: \x05sm_sonic_speedmult\x01, \x05sm_sonic_duration\x01,");
    PrintToChat(client, "\x01 \x05sm_sonic_cooldown\x01 (v3.0: método MaxSpeed, salto vanilla)");
    PrintToChat(client, "\x01 El boost se pausa áutomaticamente si eres incapacitado,");
    PrintToChat(client, "\x01 agarrado por un especial, estas en agua o en escaleras.");
}

void ShowSpeedInfo(int client)
{
    PrintToChat(client, "\x04=== ESTADO ZAPATOS SONIC ===");

    if (g_bIsBoosted[client])
    {
        float remaining = g_fBuffEnd[client] - GetEngineTime();
        if (remaining < 0.0) remaining = 0.0;
        PrintToChat(client, "\x01 Boost: \x05ACTIVO\x01 | Tiempo restante: \x05%.1fs\x01", remaining);
    }
    else
    {
        float timeNow = GetEngineTime();
        if (timeNow < g_fLastUse[client] + Speed_GetCooldown())
        {
            float remaining = (g_fLastUse[client] + Speed_GetCooldown()) - timeNow;
            PrintToChat(client, "\x01 Boost: \x03INACTIVO\x01 | Cooldown: \x05%.1fs\x01", remaining);
        }
        else
        {
            PrintToChat(client, "\x01 Boost: \x03LISTO\x01 | Puedes activarlo con \x05!speed\x01");
        }
    }

    PrintToChat(client, "\x01 Color del rastro: \x05RGB(%d, %d, %d)\x01",
        g_PlayerColor[client][0], g_PlayerColor[client][1], g_PlayerColor[client][2]);
    PrintToChat(client, "\x04============================");
}

// =======================
// APLICACION DEL BOOST
// =======================

void ApplySpeedBoost(int client)
{
    if (!Speed_IsValidClient(client)) return;

    // 1. v3.0: SNAPSHOT de la velocidad natural (m_flMaxspeed) si no esta
    //    boosteado. Sane clamp: fuera de [80, 400] se asume 220.
    //    v3.2 ANTI DOBLE-CUENTA: si hay adrenalina o stack externo activos,
    //    el valor actual NO es la base natural (el writer o el motor ya
    //    sumaron encima): se resta el bono del chute y se des-multiplica
    //    el stack (inversión exacta de la fórmula del writer) para
    //    capturar la base LIMPIA. Sin esto, activar !speed con adrenalina
    //    contaba el bono dos veces (en la base Y en el target).
    if (!g_bIsBoosted[client])
    {
        float curMs = GetEntPropFloat(client, Prop_Data, "m_flMaxspeed");
        curMs -= Speed_GetAdrenalineBonus(client);
        if (Speed_StackAnyActive(client))
            curMs /= (1.0 + Speed_StackTotalExtra(client));
        if (curMs < 80.0 || curMs > 400.0) curMs = SPEED_BASE_MAXSPEED;
        g_fBaseMaxspeed[client] = curMs;
    }

    // 2. v3.0: blindaje anti-herencia del método viejo (lagged/gravedad a 1.0
    //    en la activación; si Amy/Metal/Shadow tienen un multiplicador propio
    //    activo, su think lo re-aplica en el siguiente frame)
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntPropFloat(client, Prop_Data, "m_flGravity", 1.0);

    // 3. Activar Estado
    float duration = Speed_GetDuration();
    g_bIsBoosted[client] = true;
    g_fBuffEnd[client] = GetEngineTime() + duration;
    g_fBoostStart[client] = GetEngineTime();
    g_bPaused[client] = false;

    // 4. ACTIVAR EL HOOK DE VELOCIDAD (con protección anti double-hook)
    //    v3.0: PreThinkPost (write de maxspeed DESPUÉS de la recomputación
    //    de velocidad del juego, ANTES del movimiento del tick)
    if (g_bHookActive[client])
    {
        SDKUnhook(client, SDKHook_PreThinkPost, Speed_OnPreThink);
    }
    SDKHook(client, SDKHook_PreThinkPost, Speed_OnPreThink);
    g_bHookActive[client] = true;

    // 5. Aplicar velocidad base (el ramp la subira gradualmente)
    Speed_ApplyMaxSpeed(client, Speed_GetBaseSpeed(client));

    // 6. Feedback: efectos visuales + sonidos + mensajes
    Speed_CreateActivationEffects(client);

    // v3.2: mostrar el TOTAL apilado (si el Overdrive de Metal u otra
    // fuente del stack ya está activo, se ve la SUMA real, no solo el cvar)
    float displayMult = 1.0 + (Speed_GetMultiplier() - 1.0) + Speed_StackTotalExtra(client);
    PrintToChat(client, "\x04[ZapatosSonic]\x05 VELOCIDAD SÓNICA ACTIVADA! \x01(x%.1f durante %.0fs)", displayMult, duration);
    PrintCenterText(client, ">>> VELOCIDAD SÓNICA <<<\nDuración: %.0fs", duration);

    // 7. Iniciar timers
    ClearClientTimers(client);

    g_hTrailTimer[client] = CreateTimer(0.3, Timer_RefreshTrail, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    g_hResetTimer[client] = CreateTimer(duration, Timer_ResetStats, client, TIMER_FLAG_NO_MAPCHANGE);
    g_hHUDTimer[client] = CreateTimer(SPEED_HUD_TICK, Timer_HUDUpdate, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    g_hAfterImageTimer[client] = CreateTimer(0.2, Timer_AfterImage, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

// =======================
// EFECTOS VISUALES TIPO SONIC
// =======================

// Efectos al activar el boost
void Speed_CreateActivationEffects(int client)
{
    if (!Speed_IsValidClient(client)) return;

    float origin[3];
    GetClientAbsOrigin(client, origin);
    origin[2] += 10.0;

    int color[4];
    color[0] = g_PlayerColor[client][0];
    color[1] = g_PlayerColor[client][1];
    color[2] = g_PlayerColor[client][2];
    color[3] = 200;

    // 1. Shockwave expansiva (beam ring point que crece)
    if (g_iGlowSprite > 0)
    {
        TE_SetupBeamRingPoint(origin, 10.0, 400.0, g_iGlowSprite, g_iHaloSprite, 0, 15, 0.6, 20.0, 2.0, color, 5, 0);
        TE_SendToAll();
    }

    // 2. Ring de chispas azules
    TE_SetupSparks(origin, NULL_VECTOR, 8, 4);
    TE_SendToAll();

    // 3. Glow inicial en el jugador (v6.6: consciente del avatar)
    Speed_SetBoostGlow(client, true);

    // 4. Sonido de activación
    EmitSoundToAll("mobius/sfx/boost.mp3", client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.0);
}

// Efectos al desactivar el boost
void Speed_CreateDeactivationEffects(int client)
{
    if (!Speed_IsValidClient(client)) return;

    float origin[3];
    GetClientAbsOrigin(client, origin);
    origin[2] += 10.0;

    // Ring de desactivación (rojo para diferenciar)
    int deactColor[4] = {255, 50, 50, 200};
    if (g_iGlowSprite > 0)
    {
        TE_SetupBeamRingPoint(origin, 10.0, 200.0, g_iGlowSprite, g_iHaloSprite, 0, 15, 0.4, 10.0, 1.0, deactColor, 3, 0);
        TE_SendToAll();
    }

    // Quitar glow (v6.6: también de los avatares si los había)
    Speed_SetBoostGlow(client, false);

    // Sonido de desactivación
    EmitSoundToAll("ambient/energy/zap2.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.7);
}

// v3.3 (manager 3.77.13) / PEDIDO DEL OWNER 2026-10-08: "ajustas el
// speed para que desde ahora no muestre el aura alrededor del modelo
// oculto del survivor ni tampoco el del avatar — solo se vera el
// trail". El glow outline (m_iGlowType 3) se dibuja SOBRE el cuerpo
// invisible (L4D2 dibuja el contorno aunque el modelo viaje en
// RENDER_NONE) y sobre las 2 copias del avatar = el "aura". Queda como
// NO-OP documentado: las llamadas de activación/desactivación siguen
// existiendo (inofensivas) y el TRAIL de colores (BeamFollow) queda
// como único efecto persistente del boost. El historial del porque
// existía (v6.6, consciente del avatar) queda abajo a propósito.
// v6.6 Sonic: aplicador de glow consciente del avatar. Tails Y
// Sonic viajan con el cuerpo en RENDER_NONE — el glow (m_iGlowType)
// al CLIENTE dibuja el contorno de un cuerpo invisible = no se ve
// (ES "el error que antes tenía tails pero que ahora lo tiene
// sonic"). Con avatar vivo el glow iba a SUS entidades (R para los
// demas, L para el dueño); sin avatar, al player como siempre.
stock void Speed_SetBoostGlow(int client, bool on)   // v3.3: no-op intencional (glow retirado)
{
    // v3.3: NO-OP intencional (pedido del owner): no tocar
    // m_iGlowType / m_glowColorOverride / m_nGlowRange / m_bFlashing
    // en NINGÚN objetivo (player ni avatares) — el aura se retira.
    // El trail de colores (Speed_CreateColorTrail) sigue intacto.
    #pragma unused client
    #pragma unused on
}

// Trail de color que sigue al jugador
void Speed_CreateColorTrail(int client)
{
    if (!Speed_IsValidClient(client)) return;
    if (g_iBeamSprite <= 0) return;

    // v5.20 Tails / v6.6 Sonic: si el jugador tiene avatar OM vivo, el
    // trail sale del CUERPO DEL AVATAR (el survivor viaja en RENDER_NONE
    // y el beam le salía "del aire"). El timer de refresh lo re-resuelve
    // cada envío, así que si el avatar se recrea, el próximo refresh ya
    // lo sigue.
    int avOwner, avOthers;
    if (Tails_GetAvatarEnts(client, avOwner, avOthers)
        || Sonic_GetAvatarEnts(client, avOwner, avOthers))
    {
        if (avOwner == avOthers)
        {
            // avatar único (tails_follow 1): un solo beam para todos
            TE_SetupBeamFollow(avOthers, g_iBeamSprite, 0, 0.6, 10.0, 1.0, 3, g_PlayerColor[client]);
            TE_SendToAll();
        }
        else
        {
            // dual v5.17-B: el dueño ve el beam de SU copia (L) y los
            // demás el de la copia R (mismo split de SetTransmit)
            TE_SetupBeamFollow(avOwner, g_iBeamSprite, 0, 0.6, 10.0, 1.0, 3, g_PlayerColor[client]);
            TE_SendToClient(client);

            int[] recipients = new int[MaxClients];
            int n = 0;
            for (int i = 1; i <= MaxClients; i++)
                if (i != client && IsClientInGame(i))
                    recipients[n++] = i;
            if (n > 0)
            {
                TE_SetupBeamFollow(avOthers, g_iBeamSprite, 0, 0.6, 10.0, 1.0, 3, g_PlayerColor[client]);
                TE_Send(recipients, n);
            }
        }
        return;
    }

    TE_SetupBeamFollow(client, g_iBeamSprite, 0, 0.6, 10.0, 1.0, 3, g_PlayerColor[client]);
    TE_SendToAll();
}

// After-image (sprite fantasma)
void Speed_CreateAfterImage(int client)
{
    if (!Speed_IsValidClient(client)) return;
    if (g_iGlowSprite <= 0) return;

    float origin[3];
    GetClientAbsOrigin(client, origin);
    origin[2] += 30.0;

    // Sprite de glow que se desvanece
    TE_SetupGlowSprite(origin, g_iGlowSprite, 0.3, 0.8, 100);
    TE_SendToAll();
}

// =======================
// TIMERS DE CONTROL
// =======================

public Action Timer_RefreshTrail(Handle timer, any data)
{
    int client = data;
    if (!Speed_IsValidClient(client)) { if (g_hTrailTimer[client] == timer) g_hTrailTimer[client] = null; return Plugin_Stop; }   // v2.5
    if (!g_bIsBoosted[client]) { if (g_hTrailTimer[client] == timer) g_hTrailTimer[client] = null; return Plugin_Stop; }          // v2.5

    if (!g_bPaused[client])
    {
        Speed_CreateColorTrail(client);
    }
    return Plugin_Continue;
}

public Action Timer_AfterImage(Handle timer, any data)
{
    int client = data;
    if (!Speed_IsValidClient(client)) { if (g_hAfterImageTimer[client] == timer) g_hAfterImageTimer[client] = null; return Plugin_Stop; }   // v2.5
    if (!g_bIsBoosted[client]) { if (g_hAfterImageTimer[client] == timer) g_hAfterImageTimer[client] = null; return Plugin_Stop; }          // v2.5

    if (!g_bPaused[client])
    {
        Speed_CreateAfterImage(client);
    }
    return Plugin_Continue;
}

public Action Timer_HUDUpdate(Handle timer, any data)
{
    int client = data;
    if (!Speed_IsValidClient(client)) { if (g_hHUDTimer[client] == timer) g_hHUDTimer[client] = null; return Plugin_Stop; }   // v2.5
    if (!g_bIsBoosted[client]) { if (g_hHUDTimer[client] == timer) g_hHUDTimer[client] = null; return Plugin_Stop; }          // v2.5

    float remaining = g_fBuffEnd[client] - GetEngineTime();
    if (remaining <= 0.0) { if (g_hHUDTimer[client] == timer) g_hHUDTimer[client] = null; return Plugin_Stop; }               // v2.5

    // v2.2 FIX CRITICO: el HUD corria cada 5s, así que el countdown
    // "SPEED ENDING 3-2-1" casi nunca se llegaba a ver (la ventana de 3s
    // caía entre ticks). En los últimos 5s cambiamos a modo rápido de 1s.
    if (remaining <= 5.0)
    {
        g_hHUDTimer[client] = null;              // este timer muere con Plugin_Stop
        g_hHUDTimer[client] = CreateTimer(1.0, Timer_HUDFast, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Stop;
    }

    // HUD con tiempo restante
    if (!g_bPaused[client])
    {
        PrintHintText(client, "VELOCIDAD SÓNICA\nTiempo restante: %.1fs", remaining);
    }
    else
    {
        PrintHintText(client, "BOOST PAUSADO\n(Espera a estar libre)");
    }

    return Plugin_Continue;
}

// v2.2: HUD rápido (1s) para los últimos 5s — countdown REAL 5..4..3..2..1
public Action Timer_HUDFast(Handle timer, any data)
{
    int client = data;
    if (!Speed_IsValidClient(client)) { if (g_hHUDTimer[client] == timer) g_hHUDTimer[client] = null; return Plugin_Stop; }   // v2.5
    if (!g_bIsBoosted[client])
    {
        if (g_hHUDTimer[client] == timer) g_hHUDTimer[client] = null;
        return Plugin_Stop;
    }

    float remaining = g_fBuffEnd[client] - GetEngineTime();
    if (remaining <= 0.0) { if (g_hHUDTimer[client] == timer) g_hHUDTimer[client] = null; return Plugin_Stop; }   // v2.5

    if (g_bPaused[client])
    {
        PrintHintText(client, "BOOST PAUSADO\n(Espera a estar libre)");
        return Plugin_Continue;
    }

    if (remaining <= SPEED_LOW_TIME_THRESHOLD)
    {
        // Últimos 3s: countdown grande + tick sonoro por segundo
        PrintCenterText(client, "SPEED ENDING!\n%.0f", remaining);
        EmitSoundToClient(client, "buttons/button17.wav", _, _, _, _, _, 150);
    }
    else
    {
        PrintHintText(client, "VELOCIDAD SÓNICA\nTiempo restante: %.0fs", remaining);
    }

    return Plugin_Continue;
}

public Action Timer_ResetStats(Handle timer, any data)
{
    int client = data;
    if (client < 1 || client > MaxClients) return Plugin_Stop;

    // v2.5: el watchdog invoca aquí DIRECTAMENTE (timer = INVALID_HANDLE) y
    // puede llegar con el handle del reset ya muerto (el timer se detuvo
    // solo antes). Se anula al ENTRAR: el KillTimer de ClearClientTimers
    // jamás toca un handle colgante, la función ya nunca aborta a medias
    // y ResetClientState siempre completa (el watchdog deja de re-disparar).
    g_hResetTimer[client] = null;

    // Si el cliente se fue, limpiar memoria
    if (!IsClientInGame(client))
    {
        ResetClientState(client);
        ClearClientTimers(client);
        return Plugin_Stop;
    }

    float timeNow = GetEngineTime();

    // Si se renovo el buff antes de terminar, reprogramar
    if (timeNow < g_fBuffEnd[client])
    {
        float remaining = g_fBuffEnd[client] - timeNow;
        if (remaining < 0.1) remaining = 0.1;
        g_hResetTimer[client] = CreateTimer(remaining + 0.1, Timer_ResetStats, client, TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Stop;
    }

    // RESTAURAR VALORES
    Speed_RestorePlayerStats(client);

    // Efectos de desactivación
    if (IsPlayerAlive(client))
    {
        Speed_CreateDeactivationEffects(client);
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Velocidad normal restaurada.");
    }

    // Limpieza final
    ClearClientTimers(client);
    ResetClientState(client);

    return Plugin_Stop;
}

// Restaura los stats del jugador a sus valores previos
void Speed_RestorePlayerStats(int client)
{
    if (!IsClientInGame(client)) return;

    // v3.0: restaurar la VELOCIDAD NATURAL (snapshot o 220 por defecto).
    // La fricción del suelo desacelera suavemente (no hay frenado en seco;
    // además el decel-ramp de los últimos 0.5s ya redujo el multiplicador).
    // v3.2: si el STACK sigue activo (Overdrive de Metal etc.), el objetivo
    // correcto NO es la natural: es la del stack puro (el writer la sigue
    // manteniendo mientras dure la fuente externa).
    float restoreTarget = Speed_GetBaseSpeed(client);
    if (Speed_StackAnyActive(client))
        restoreTarget = Speed_GetStackTarget(client, 0.0);
    SetEntPropFloat(client, Prop_Data, "m_flMaxspeed", restoreTarget);

    // v3.0: normalizar lagged y gravedad (el boost ya no los toca; esto
    // limpia cualquier herencia del método viejo v2.x)
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntPropFloat(client, Prop_Data, "m_flGravity", 1.0);

    // v3.0: lectura de los cvars DEPRECATED (solo trazabilidad en el log
    // de debug; mantiene las referencias vivas y las cfgs compatibles)
    DebugLog("Player %d: maxspeed restored to %.0f (deprecated: gravity scale %.2f, restore_lagged %d)",
        client, Speed_GetBaseSpeed(client), Speed_GetGravityScale(),
        (g_hCvarRestoreLagged != null && g_hCvarRestoreLagged.BoolValue) ? 1 : 0);

    // Quitar glow (v6.6: consciente del avatar — Sonic v6.6)
    Speed_SetBoostGlow(client, false);
}

// =======================
// EVENTOS Y LIMPIEZA
// =======================

public Action Command_ForceReset(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    if (!g_bIsBoosted[client])
    {
        PrintToChat(client, "\x04[ZapatosSonic]\x01 No tienes el boost activo.");
        return Plugin_Handled;
    }

    Speed_DeactivateBoost(client);
    return Plugin_Handled;
}

// v2.1: Desactivación limpia y directa del boost (usada por el toggle !speed
// y por !resetspeed). Restaura velocidad y gravedad, reproduce el efecto
// de apagado y limpia timers — SIN abrir ningún menú.
void Speed_DeactivateBoost(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!g_bIsBoosted[client]) return;

    // v2.2 QoL: feedback distinto para desactivación manual
    if (IsClientInGame(client))
        PrintCenterText(client, "Boost desactivado");

    // Marcar como expirado y procesar la restauración completa
    g_fBuffEnd[client] = 0.0;
    Timer_ResetStats(null, client);
}

public void Speed_Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));

    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        // v3.0: al aparecer, si no esta boosteado: snapshot de la velocidad
        // natural + higiene anti-herencia (lagged/gravedad a 1.0 en estado
        // fresco: en el spawn no hay habilidad activa, es el único momento
        // 100% seguro para normalizar sin pisar a nadie). Solo survivors:
        // el Super Tank usa lagged legitimamente en tanques (no en spawn).
        if (!g_bIsBoosted[client] && GetClientTeam(client) == TEAM_SURVIVOR)
        {
            // v3.2: higiene defensiva del stack en spawn fresco (el
            // ResetState de cada modulo ya limpia su propio slot: doble
            // seguro contra cualquier orden de eventos)
            Speed_StackClear(client);
            float ms = GetEntPropFloat(client, Prop_Data, "m_flMaxspeed");
            if (ms < 80.0 || ms > 400.0) ms = SPEED_BASE_MAXSPEED;
            g_fBaseMaxspeed[client] = ms;

            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            SetEntPropFloat(client, Prop_Data, "m_flGravity", 1.0);
        }

        // Cargar color
        if (AreClientCookiesCached(client)) LoadPlayerColor(client);

        // v2.1: Mensaje de bienvenida solo UNA vez por mapa (antes salia en CADA spawn)
        if (g_hCvarEnableTips != null && g_hCvarEnableTips.BoolValue && !g_bWelcomeShown[client])
        {
            g_bWelcomeShown[client] = true;
            CreateTimer(3.0, Timer_WelcomeMessage, client, TIMER_FLAG_NO_MAPCHANGE);
            g_fNextTipTime[client] = GetEngineTime() + 30.0;
        }
    }
}

public Action Timer_WelcomeMessage(Handle timer, any client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return Plugin_Stop;

    PrintToChat(client, "\x04[ZapatosSonic]\x01 Escribe \x05!speed\x01 o \x05!speedhelp\x01 para usar los Zapatos Sonic.");
    return Plugin_Stop;
}

public void Speed_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    // Limpiar todos los estados al final de la ronda
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && g_bIsBoosted[i])
        {
            Speed_RestorePlayerStats(i);
            ClearClientTimers(i);
            ResetClientState(i);
        }
    }
}

public void Speed_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients) return;

    DebugLog("Player %d died. Resetting boost.", client);

    // v3.2: las fuentes externas del stack mueren con el jugador (el
    // ResetState de cada modulo, p.ej. Metal, también limpia su slot: doble
    // seguro). Primero los slots, después ResetClientState (para que vea
    // "cero fuentes" y suelte el hook de verdad).
    Speed_StackClear(client);

    if (g_bIsBoosted[client] && IsClientInGame(client))
    {
        Speed_RestorePlayerStats(client);
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Boost perdido por muerte.");
    }

    ClearClientTimers(client);
    ResetClientState(client);
}

public void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        // v3.2: los slots del stack son POR ÍNDICE DE CLIENTE: hay que
        // limpiarlos SIEMPRE en la desconexion o el siguiente jugador
        // que recicle el índice heredaria el extra del Overdrive de Metal
        Speed_StackClear(client);
        ClearClientTimers(client);
        ResetClientState(client);
        g_fLastUse[client] = 0.0;
        g_fBaseMaxspeed[client] = 0.0;
        g_bHasUsedBoost[client] = false;
        g_fNextTipTime[client] = 0.0;
    }
}

// =======================
// WATCHDOG MEJORADO (SEGURIDAD)
// =======================

public Action Timer_WatchdogCheck(Handle timer)
{
    float timeNow = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;

        // === CHECK 1: Estado colgado (buffEnd expirado pero sigue boosteado) ===
        if (g_bIsBoosted[i] && timeNow > g_fBuffEnd[i] + 1.0)
        {
            DebugLog("WATCHDOG [1]: Force restore for Player %d (buff expired but still boosted)", i);
            Timer_ResetStats(INVALID_HANDLE, i);
            continue;
        }

        // === CHECK 2: Hook fantasma (cualquier fuente activa pero hook off) ===
        if ((g_bIsBoosted[i] || Speed_StackAnyActive(i)) && !g_bHookActive[i] && IsPlayerAlive(i))
        {
            DebugLog("WATCHDOG [2]: Re-hooking Player %d (speed source active but hook inactive)", i);
            SDKHook(i, SDKHook_PreThinkPost, Speed_OnPreThink);
            g_bHookActive[i] = true;
        }

        // === CHECK 3: Hook activo pero SIN ninguna fuente (hook zombie) ===
        if (!g_bIsBoosted[i] && !Speed_StackAnyActive(i) && g_bHookActive[i])
        {
            DebugLog("WATCHDOG [3]: Unhooking Player %d (no speed source but hook active)", i);
            SDKUnhook(i, SDKHook_PreThinkPost, Speed_OnPreThink);
            g_bHookActive[i] = false;
        }

        // === CHECK 4: Velocidad (v3.0: m_flMaxspeed) ===
        // IMPORTANTE: NO se normaliza el lagged en general. Amy (1.35),
        // Shadow (1.3), Knuckles (0.7) y los estados de Metal lo usan de
        // forma legitima; el Super Tank lo usa en tanques. El boost v3.0
        // jamás escribe lagged, así que solo se interviene el maxspeed.
        if (IsPlayerAlive(i))
        {
            // 4a: maxspeed atascado (boost o stack activo pero el juego lo
            // reseteo por cambio de arma / adrenalina / etc) -> re-aplicar
            // el objetivo COMPLETO (v3.2: fórmula del stack con adrenalina;
            // se salta si esta pausado o en estado inválido para no pisar
            // la pausa del writer)
            if ((g_bIsBoosted[i] || Speed_StackAnyActive(i)) && !g_bPaused[i] && !Speed_IsPlayerInInvalidState(i))
            {
                float sonicExtra = g_bIsBoosted[i] ? (Speed_ClampSpeed(Speed_GetMultiplier()) - 1.0) : 0.0;
                float expected = Speed_GetStackTarget(i, sonicExtra);
                float curMs = GetEntPropFloat(i, Prop_Data, "m_flMaxspeed");
                if (FloatAbs(curMs - expected) > 1.0)
                {
                    DebugLog("WATCHDOG [4a]: Re-applying maxspeed for Player %d (%.0f -> %.0f)", i, curMs, expected);
                    SetEntPropFloat(i, Prop_Data, "m_flMaxspeed", expected);
                }
            }

            // 4b: maxspeed corrupto (0 o negativo) -> velocidad natural
            float curSpeed = GetEntPropFloat(i, Prop_Data, "m_flMaxspeed");
            if (curSpeed < 1.0)
            {
                DebugLog("WATCHDOG [4b]: Fixing corrupt maxspeed for Player %d (was %.1f)", i, curSpeed);
                SetEntPropFloat(i, Prop_Data, "m_flMaxspeed", SPEED_BASE_MAXSPEED);
            }

            // === CHECK 5: Gravedad corrupta (<= 0 o > 5.0). v3.0: el boost
            // no la toca; solo se normaliza si esta FUERA de rango sane para
            // no pisar gravedades legitimas de otros sistemas ===
            float currentGrav = GetEntPropFloat(i, Prop_Data, "m_flGravity");
            if (currentGrav <= 0.0 || currentGrav > GRAVITY_MAX_CLAMP)
            {
                DebugLog("WATCHDOG [5]: Fixing corrupt gravity for Player %d (was %.2f)", i, currentGrav);
                SetEntPropFloat(i, Prop_Data, "m_flGravity", 1.0);
            }
        }

        // === CHECK 6: Timers zombie (cliente desconectado con timers activos) ===
        if (!IsPlayerAlive(i) && (g_hTrailTimer[i] != null || g_hResetTimer[i] != null || g_hHUDTimer[i] != null))
        {
            DebugLog("WATCHDOG [6]: Clearing zombie timers for Player %d", i);
            ClearClientTimers(i);
        }
    }

    return Plugin_Continue;
}

// =======================
// SISTEMA DE TIPS AUTOMÁTICOS
// =======================

public Action Timer_AutoTips(Handle timer)
{
    if (g_hCvarEnableTips == null || !g_hCvarEnableTips.BoolValue) return Plugin_Continue;

    float timeNow = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (g_bHasUsedBoost[i]) continue; // Solo a los que no han usado el boost
        if (timeNow < g_fNextTipTime[i]) continue;

        // Tip aleatorio
        int tipNum = GetRandomInt(1, 4);
        switch (tipNum)
        {
            case 1: PrintToChat(i, "\x04[TIP]\x01 Escribe \x05!speed\x01 para activar los Zapatos Sonic y correr a velocidad super sónica!");
            case 2: PrintToChat(i, "\x04[TIP]\x01 Escribe \x05!speedhelp\x01 para ver todos los comandos disponibles.");
            case 3: PrintToChat(i, "\x04[TIP]\x01 Escribe \x05!colortrail\x01 para personalizar el color de tu rastro de velocidad.");
            case 4: PrintToChat(i, "\x04[TIP]\x01 Escribe \x05!speedinfo\x01 para ver el estado de tu boost y cooldown.");
        }

        g_fNextTipTime[i] = timeNow + SPEED_TIP_INTERVAL;
    }

    return Plugin_Continue;
}

// =======================
// SISTEMA DE COLORES Y MENÚ
// =======================

public void Speed_OnClientCookiesCached(int client)
{
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
        LoadPlayerColor(client);
}

void SavePlayerColor(int client)
{
    if (!IsClientInGame(client)) return;
    if (g_hColorCookie == null) return;

    char sColor[32];
    Format(sColor, sizeof(sColor), "%d %d %d %d",
        g_PlayerColor[client][0], g_PlayerColor[client][1],
        g_PlayerColor[client][2], g_PlayerColor[client][3]);
    Sonic_SafeSetCookie(client, g_hColorCookie, sColor);   // v3.77.79: a prueba de modo solo (peon fake sin cookies en cache)
    PrintToChat(client, "\x04[ZapatosSonic]\x01 Color guardado: RGB(%d, %d, %d)",
        g_PlayerColor[client][0], g_PlayerColor[client][1], g_PlayerColor[client][2]);
}

void LoadPlayerColor(int client)
{
    if (!IsClientInGame(client)) return;
    if (g_hColorCookie == null) return;

    char sColor[64];
    GetClientCookie(client, g_hColorCookie, sColor, sizeof(sColor));

    if (sColor[0] == '\0')
    {
        // Default: Azul Sonic
        g_PlayerColor[client][0] = 0;
        g_PlayerColor[client][1] = 150;
        g_PlayerColor[client][2] = 255;
        g_PlayerColor[client][3] = 200;
        return;
    }

    char parts[4][8];
    if (ExplodeString(sColor, " ", parts, 4, 8) >= 4)
    {
        g_PlayerColor[client][0] = StringToInt(parts[0]);
        g_PlayerColor[client][1] = StringToInt(parts[1]);
        g_PlayerColor[client][2] = StringToInt(parts[2]);
        g_PlayerColor[client][3] = StringToInt(parts[3]);

        // Clamp de valores RGB
        for (int c = 0; c < 4; c++)
        {
            if (g_PlayerColor[client][c] < 0) g_PlayerColor[client][c] = 0;
            if (g_PlayerColor[client][c] > 255) g_PlayerColor[client][c] = 255;
        }
    }
}

public Action Command_ColorMenu(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    Menu menu = new Menu(MenuHandler_ColorSelect);
    menu.SetTitle("COLOR DEL RASTRO SONIC\nColor actual: RGB(%d, %d, %d)",
        g_PlayerColor[client][0], g_PlayerColor[client][1], g_PlayerColor[client][2]);

    menu.AddItem("0 150 255 200", "Azul Sonic (Clasico)");
    menu.AddItem("255 0 0 200", "Rojo");
    menu.AddItem("0 255 0 200", "Verde");
    menu.AddItem("255 255 0 200", "Amarillo");
    menu.AddItem("0 255 255 200", "Cian");
    menu.AddItem("255 0 255 200", "Magenta");
    menu.AddItem("255 165 0 200", "Naranja");
    menu.AddItem("128 0 128 200", "Morado");
    menu.AddItem("255 20 147 200", "Rosa Hot");
    menu.AddItem("0 255 128 200", "Verde Neón");
    menu.AddItem("255 255 255 200", "Blanco");

    menu.ExitButton = true;
    menu.Display(client, 30);
    return Plugin_Handled;
}

public int MenuHandler_ColorSelect(Menu menu, MenuAction action, int client, int param)
{
    if (action == MenuAction_End)
    {
        delete menu;
    }
    else if (action == MenuAction_Select)
    {
        if (client <= 0 || !IsClientInGame(client)) return 0;

        char info[64];
        menu.GetItem(param, info, sizeof(info));
        char parts[4][8];
        ExplodeString(info, " ", parts, 4, 8);

        g_PlayerColor[client][0] = StringToInt(parts[0]);
        g_PlayerColor[client][1] = StringToInt(parts[1]);
        g_PlayerColor[client][2] = StringToInt(parts[2]);
        g_PlayerColor[client][3] = StringToInt(parts[3]);

        SavePlayerColor(client);
        PrintToChat(client, "\x04[ZapatosSonic]\x01 Color actualizado.");

        // v2.1: Ya no se re-abre el menú principal áutomaticamente
    }
    return 0;
}

// =======================
// HOOK DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
public void Speed_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;

    if (g_bIsBoosted[client] && IsClientInGame(client))
    {
        Speed_RestorePlayerStats(client);
    }

    ClearClientTimers(client);
    ResetClientState(client);
}

// =======================
// FIN DEL MODULO
// =======================
//
// v2.1 NOTA: Se elimino el hook OnClientSayCommand. Los comandos !speed,
// !sonic, !speedmenu, !colortrail, etc. ya están registrados con
// RegConsoleCmd, y SourceMod procesa los triggers de chat (!comando)
// áutomaticamente. El hook antiguo provocaba ejecución doble de los
// comandos (se activaban 2 veces por mensaje de chat).

