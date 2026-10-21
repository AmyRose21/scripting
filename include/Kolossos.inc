/*
 * =====================================================================
 *  [MODULO] KOLOSSOS — El Coloso de OutComeMemories v1.2-OM
 *  PERSONAJE 14 DEL SUITE (KOLOSSOS_INDEX 13)
 *
 *  Port directo de "Lua de OM de Gmod/autorun/include/killer/
 *  noodles_om_pills_killer_kolossos.lua" (by noodles) — el killer
 *  colosal del pack OM pills, traido a L4D2 como personaje jugable.
 *
 *  v1.4 (manager 3.77.98) — LAS CAPAS DEL GRAB + AGARRAR ESPECIALES
 *  (reporte del owner tras probar la v1.3: "la animacion grab nunca se
 *  logra apresiar es pisoteada por la animacion de caminar" y "No agarra
 *  a especiales (al tank no lo agarra. tampoco)"; "la animacion por
 *  capas si es compatible con l4d2, por que no se le esta aplicando?").
 *  RAIZ del bug 1 (el kolossos.qc del zip del owner lo confirma): las
 *  secuencias Grab/GrabIdle/GrabPunch/GrabThrow estan compiladas con
 *  weightlist "weights_swing" (SOLO animan los 15 huesos de brazos) +
 *  addlayer delta de torso + fps 60 — fueron autoradas EXCLUSIVAMENTE
 *  como gestures de CAPA (el AddGesture del GMod las reproduce asi:
 *  brazos encima de la locomocion, piernas vivas). Ponerlas como
 *  secuencia PRINCIPAL del prop (motor monocapa v1.3) deja los huesos
 *  peso-0 en pose de referencia = un vistazo de nada "pisoteado por
 *  caminar". FIX: MOTOR DE CAPAS REAL — m_AnimOverlay (L4D2 lo lleva en
 *  CBaseAnimating, compatible con props): slot 1 = pose GrabIdle
 *  sostenida (ACT_HOVER), slot 2 = reach/puño/lanzamiento (one-shots de
 *  duracion COMPLETA), SOBRE la locomocion main (walk/run/idle) — las
 *  PIERNAS SIGUEN ANDANDO mientras los brazos agarran, exactamente el
 *  sistema de los survivors al cambiar arma que pedia el owner. Sonda
 *  HasEntProp + GetEntPropArraySize por mapa, convar
 *  kolossos_grab_layers (1 = capas auto, 0 = fallback monocapa v1.3),
 *  driver per-tick del m_flCycle y duraciones corregidas al fps 60 REAL
 *  del QC (reach 0.52s / puño 0.85s / lanzamiento 1.02s — v1.3 asumía
 *  30fps: el doble). FIX del bug 2: el tank estaba EXPLICITAMENTE
 *  excluido en la v1.0 ("demasiado grande para el puño") y los demas
 *  especiales perdian contra cualquier comun en la esfera (los commons
 *  se chequeaban primero con return): ahora los ESPECIALES tienen
 *  PRIORIDAD (se chequean primero, el mas cercano), el TANK entra por
 *  convar kolossos_grab_tank (default 1) y la WITCH por
 *  kolossos_grab_witch (default 1, via movetype como los commons).
 *
 *  v1.3 (manager 3.77.97) — LAS ANIMACIONES DEL GRAB (reporte del
 *  owner con los SMD decompilados del .mdl: "faltaron las animaciones
 *  de grab; la del lanzamiento debe ser PRIORITARIA y durar lo que
 *  debe durar; las grab son de solo torso y las piernas tienen que
 *  seguir andando, como los survivors cuando cambian arma"). Analisis
 *  de los SMD: Grab 31f / GrabPunch 51f / GrabThrow 61f animan SOLO
 *  brazos+torso (cero piernas) y GrabIdle es una pose de 1 frame — en
 *  GMod son GESTURES (ACT_HOVER sostiene, ACT_DISARM lanza cortado a
 *  0.9s con fade, MELEE_ATTACK2 puÿea) sobre la locomocion base. El
 *  prop de L4D2 es MONOCAPA (sin overlay), asi que la serie se cablea
 *  con la regla "las piernas nunca se congelan": [a] KOL_ST_GRABREACH
 *  al enganchar (el reach, one-shot), [b] KOL_ST_GRABHOLD plantado
 *  (pose GrabIdle) y WALK en el suelo moviÿendose / JUMP-FALL en el
 *  aire (la locomocion MANDA sobre la pose mientras haya movimiento),
 *  [c] KOL_ST_GRABPUNCH por puÿo, [d] KOL_ST_GRABTHROW al lanzar:
 *  prioridad MAXIMA (KOL_SHOT_MAX: ni el stun ni otra acciÿn la
 *  cortan) y DURACION COMPLETA medida EN VIVO contra el .mdl real
 *  (calibrador m_flCycle con prop desechable — el fps del .mdl no es
 *  30: el Kill del Lua dura 1.65s con 276 frames) + la victima sale
 *  volando a +0.3s del arranque (GMod l.2154). El combo 3er puÿo ->
 *  lanzamiento queda encadenado (GMod l.2617: duration+1.75).
 *
 *  v1.2 (manager 3.77.96) — FIX "AL ELEGIRLO NO SALE EL AVATAR"
 *  (reporte del owner tras probar la v1.1): la FSM de 10 Hz llevaba
 *  TIMER_FLAG_NO_MAPCHANGE pero se creaba UNA SOLA VEZ en
 *  OnPluginStart — al primer cambio de mapa el timer moria y NUNCA se
 *  re-creaba: sin T_KolossosThink no hay montaje (Kolossos_CreateAvatar
 *  SOLO la llama la FSM), no hay auto-reparacion de la copia L y no hay
 *  tick del kit (avalancha/agarre/bloqueo/indicator). Por eso la v1.0
 *  parecia funcionar (se probO en el primer mapa tras instalar) y en el
 *  mapa 2+ el coloso ya no salia. Receta canon del suite (Rouge v10 /
 *  Blaze v2.11 / Silver v2.0): re-crear el timer en OnMapStart + nuevo
 *  Kolossos_OnMapEnd que suelta el handle mientras sigue vivo (la
 *  leccion del "crash del capitulo 2" del manager v3.30). FIX
 *  secundario incluido: el ref de la copia R ahora se asigna ANTES de
 *  crear la L (CreateAvatarL valida que la R exista; en v1.0/v1.1 la L
 *  nacia solo por la auto-reparacion 0.1s tarde, con el cuerpo ya en
 *  RENDER_NONE = una decima de invisibilidad total en cada montaje).
 *
 *  v1.1 (manager 3.77.95) — LAS ANIMACIONES COMPLETAS + EL FIX DEL
 *  DOBLADO, reporte del owner: "Las animaciones de kolossos faltaron" y
 *  "si yo muevo la camara el personaje se dobla a mirar, un error viejo
 *  de cuando probabamos a Tails". [1] FIX DOBLADO: la copia L (la que
 *  ve el dueño) ahora contra-rota contra los EYE angles (receta Tails
 *  v5.17-B / Blaze — el bug v5.4 "cuerpo inclinado con la mira" era
 *  exactamente este): SU cliente arma el parent con el cuerpo PREDICHO
 *  = camara completa, y cancelando el pitch de la mirada el coloso
 *  queda vertical SIEMPRE en su pantalla, ergido tambien al pausar.
 *  [2] ANIMS: la FSM pasa de 5 estados base a las 15 del registro del
 *  Lua: chargestart (windup), charge_notimpaled / Charge_impaled
 *  (avalancha segun HitList, rate 1.2 del animrates), BlockStart +
 *  BlockPos (bloqueo), BlockProjectile / BlackCounterMelee (counters
 *  segun distancia <300u), slaminwall (tope de pared con empalados,
 *  1.3s + Sound.mp3), Kill (ejecucion del agarre cuando un puo mata,
 *  1.65s + la risa a +1s), stun (ShouldAlternate), walk con la victima
 *  en vilo (run->walk) y paso a 3x durante el lunge del grab. Todas se
 *  resuelven por SONDA contra el .mdl real (SetAnimation + m_nSequence)
 *  con cadena de fallbacks: nunca T-pose aunque falte una secuencia.
 *
 *  SIN CUERPO CST (no existe un survivor model de Kolossos): el
 *  AVATAR ESPEJO (patron Blaze v2.11 / sonic.inc v6.30 — doble copia
 *  R/L + modo TP + pulso de pausa + FSM de animacion) se monta sobre
 *  el survivor que el jugador tenga puesto en ese momento. El modelo
 *  vive en kolossos_model (convar); sin el archivo el personaje
 *  funciona igual, solo sin espejo (g_bKolModelOK, patron Blaze).
 *
 *  KIT GMod (registro oficial om_survivors_register_noodles_kolossos):
 *   [Z] CHARGE    — windup 0.8s (suspiro -> rumble -> rugido) y
 *                   avalancha a velocidad de embestida que EMPALA a
 *                   todo lo que toca (esfera 90u): dano + extension
 *                   +3.75s por victima nueva; al terminar, las
 *                   victimas vivas salen VOLANDAS. Pared = tope seco
 *                   (Kol wall bump). CD 22s.
 *                   GMod: OUTCOMEMEMORIES_N_Kolosssos_Charge* (22/7/25/3.75).
 *                   Receta de movimiento: la del Destructive Charge de
 *                   Metal v5.0 — slot del stack (m_flMaxspeed) +
 *                   auto-forward del RunCmd (vel[0] saturado) + DEBRIS.
 *   [X] GRAB      — lunge 0.6s; el primer infectado de la esfera 90u
 *                   queda AGARRADO en vilo (max 10s): Z = puo (15),
 *                   3 puos y sale volando (kol sting and pull out);
 *                   X de nuevo lo suelta (kolossos_grab_cancel 0 = off,
 *                   default GMod). CD 25s (2s si la victima muere sola).
 *                   GMod: GrabCooldown 25 / PunchesLeft 3 / slamDamage 15.
 *   [C] INDICATOR — 5s de "peek": todos los infectados vivos en radio
 *                   llevan un glow rojo sobre la cabeza + ping cada 1s
 *                   (susurro al activar). CD 14s.
 *                   GMod: IndicatorDuration 5 / Cooldown 14 (wallhack).
 *   [B] BLOCK     — 3.5s inmune al dano de infectados (movimiento
 *                   bloqueado); el primer golpe que absorbe CONSUME el
 *                   bloqueo y dispara el CONTRAGOLPE: gira hacia el
 *                   atacante y le devuelve una ROCA en arco (granito
 *                   3x, 35 dano al tocar). CD 14s.
 *                   GMod: BlockDuration 3.5 / BlockProjectile + roca
 *                   rockgranite03b.mdl scale 3 del counter.
 *
 *  PASIVAS: vida max 670 (kolossos_health, receta Metal_ApplyMaxHealth,
 *  vuelta a 100 al dejar el personaje) + resistencia de dano
 *  (kolossos_resistance 100 = neutro; 50 = mitad de dano recibido).
 *  NO portado a v1: el M1 melee de puos (L4D2 pelea con armas, el kit
 *  vive en las 4 teclas) y el Climb de paredes (posible v1.1).
 *
 *  SONIDOS: sound/om/kolossos/ (27 wavs del killer) copiados del addon GMod. Cada uno se chequea con FileExists: sin el archivo
 *  cae al fallback nativo HL2/L4D2 (patron g_bMetalSnd* de Metal.inc)
 *  — CERO dependencia dura.
 *
 *  INTEGRACION (manager 3.77.94): MAX_CHARS 14, KOLOSSOS_INDEX 13,
 *  fila de binds Z/X/C + B (precedente Rouge), dispatcher de las 4
 *  habilidades, OnPlayerRunCmd (auto-forward del charge),
 *  CleanupCharModuleState y banner sm_sjsver. ESTE modulo se auto-
 *  engancha sus eventos (player_spawn/player_death/round_start) —
 *  cero cableado extra en el manager.
 *
 *  CERO codigo FX de otros modulos tocado. Cero sistemas de bots.
 * =====================================================================
 */

#define KOLOSSOS_INC_VERSION "1.4-OM"

// ------------------------- CONSTANTES KIT ---------------------------
// (defaults = registro oficial GMod om_survivors_register_noodles_kolossos;
//  velocidad L4D2 calibrada al Destructive Charge de Metal v5.0: 750)
#define KOL_SND_LEVEL              87      // GMod: soundLevel 87 del killer
#define KOL_CHG_WINDUP_T          0.8     // chargestart_Kolossos = +0.8s (duracion del windup)
#define KOL_CHG_WINDUP_SIGH        0.15    // kol sigh i think.wav
#define KOL_CHG_WINDUP_RUMBLE      0.35    // kol charge start ground rumble
#define KOL_CHG_WINDUP_ROAR        0.75    // KolossosChargeRoar.wav
#define KOL_CHG_LAUNCH_MIN         300.0   // impulso de arranque (min)
#define KOL_CHG_FOV                105     // camara abierta (receta Metal)
#define KOL_CHG_COLGROUP           2       // DEBRIS durante la avalancha
#define KOL_CHG_STUCK_TIME         0.6     // watchdog: <80 u/s este tiempo = tope
#define KOL_CHG_STUCK_MINVEL       80.0
#define KOL_CHG_FLING_FWD          500.0   // lanzamiento de victimas al final
#define KOL_CHG_FLING_UP           300.0
#define KOL_GRAB_HOLD_DIST         55.0    // la victima viaja a 55u delante
#define KOL_GRAB_HOLD_Z            12.0
#define KOL_GRAB_FLING_FWD         500.0
#define KOL_GRAB_FLING_UP          300.0
#define KOL_GRAB_FLING_DELAY       0.3     // v1.3: GMod l.2154 — la victima vuela a +0.3s del arranque del throw
#define KOL_GRAB_THROW_AT          1.4     // v1.3: 3er puo -> lanzamiento encadenado (GMod duration+1.75 con la anim de por medio)

// v1.3: prioridades del one-shot (un disparo nuevo solo pisa al activo
// si su prioridad es igual o mayor — el LANZAMIENTO no lo corta nadie)
#define KOL_SHOT_ACT               1       // counters / blockstart / slaminwall
#define KOL_SHOT_GRAB              2       // grab reach / puo
#define KOL_SHOT_MAX               3       // Kill / GrabThrow — prioridad total

// v1.4: fallbacks fps 60 del QC del owner (kolossos.qc: TODAS las grab
// van a fps 60, no 30 — Grab 31f/60 = 0.52s, GrabPunch 51f/60 = 0.85s,
// GrabThrow 61f/60 = 1.02s; v1.3 asumía 30fps = el doble de largo)
#define KOL_DUR_GRABREACH          0.52    // Grab.smd 31 frames @ 60fps
#define KOL_DUR_GRABPUNCH          0.85    // GrabPunch.smd 51 frames @ 60fps
#define KOL_DUR_GRABTHROW          1.02    // GrabThrow.smd 61 frames @ 60fps

// v1.4: slots del MOTOR DE CAPAS (m_AnimOverlay) en el avatar — L4D2
// lleva el sistema de overlays en CBaseAnimating (los props lo tienen):
// slot 1 = pose GrabIdle sostenida mientras se sujeta, slot 2 = los
// one-shots de la serie (reach / puño / lanzamiento). El 0 queda libre.
#define KOL_LAYER_HOLD             1       // pose de sujetar (ACT_HOVER)
#define KOL_LAYER_SHOT             2       // one-shots de la serie grab
#define KOL_LAYER_MIN_SIZE         3       // hacen falta >= 3 slots
#define KOL_IND_PING_EVERY         1.0     // heartbeat del indicator
#define KOL_ROCK_LIFETIME          3.0     // la roca muere sola si no toca nada
#define KOL_ROCK_ARC_TIME          0.5     // GMod: travelTime 0.5
#define KOL_ROCK_ARC_PEAK          150.0   // GMod: peakHeight 150
#define KOL_ROCK_TOUCH_RADIUS      100.0   // AoE del impacto de la roca
#define KOL_DASH_VEL_INJECT        900.0   // vel[0] saturado (receta Metal)
#define KOL_MAXENT                 2048    // sprites del indicator (por indice)

// ------------------------- ESTADOS ----------------------------------
#define KOL_CHG_IDLE               0
#define KOL_CHG_WINDUP             1
#define KOL_CHG_DASH               2

// FSM de animacion del avatar — v1.1: EL REGISTRO COMPLETO del killer Lua.
// anims.default (L134-145): idle/run/walk/jump(jump2)/fall(glide)/
// slaminwall/BlockStart/BlackCounterMelee/BlockProjectile/Kill.
// ShouldAlternate (L322-395): stun/climb/BlockPos/chargestart/
// charge_notimpaled/Charge_impaled (+run->walk con victima en vilo).
// animrates (L404-439): charge 1.2 | lunge del grab 3 | run base 1.05.
#define KOL_ST_IDLE                0
#define KOL_ST_WALK                1
#define KOL_ST_RUN                 2
#define KOL_ST_JUMP                3
#define KOL_ST_FALL                4
#define KOL_ST_STUN                5    // ShouldAlternate: stun
#define KOL_ST_CHARGESTART         6    // windup de la avalancha
#define KOL_ST_CHARGE              7    // avalancha sin empalados
#define KOL_ST_CHARGE_IMP          8    // avalancha CON empalados
#define KOL_ST_BLOCKSTART          9    // arranque del bloqueo (one-shot)
#define KOL_ST_BLOCK               10   // pose de bloqueo (BlockPos)
#define KOL_ST_BLOCKPROJ           11   // counter a distancia (one-shot)
#define KOL_ST_COUNTER             12   // counter melee (one-shot)
#define KOL_ST_SLAMINWALL          13   // tope de pared con empalados (one-shot)
#define KOL_ST_KILL                14   // ejecucion del agarre (one-shot)
#define KOL_ST_GRABREACH           15   // v1.3: el reach al enganchar la victima (one-shot)
#define KOL_ST_GRABHOLD            16   // v1.3: plantado sujetando (pose GrabIdle)
#define KOL_ST_GRABPUNCH           17   // v1.3: puo al agarrado (one-shot)
#define KOL_ST_GRABTHROW           18   // v1.3: EL LANZAMIENTO (one-shot prioridad maxima)
#define KOL_ST_COUNT               19

// ------------------------- CONVARS ----------------------------------
ConVar g_cvKolEnabled;
ConVar g_cvKolModel;
ConVar g_cvKolAvatar;
ConVar g_cvKolHealth;
ConVar g_cvKolResist;
ConVar g_cvKolChgSpeed;
ConVar g_cvKolChgDur;
ConVar g_cvKolChgMaxDur;
ConVar g_cvKolChgDmg;
ConVar g_cvKolChgAdd;
ConVar g_cvKolChgCd;
ConVar g_cvKolChgRadius;
ConVar g_cvKolGrabCd;
ConVar g_cvKolGrabWindow;
ConVar g_cvKolGrabHold;
ConVar g_cvKolGrabPunches;
ConVar g_cvKolGrabPunchDmg;
ConVar g_cvKolGrabCancel;
ConVar g_cvKolGrabLayers;                       // v1.4: motor de capas del grab
ConVar g_cvKolGrabTank;                         // v1.4: agarrar al tank
ConVar g_cvKolGrabWitch;                        // v1.4: agarrar a la witch
ConVar g_cvKolIndCd;
ConVar g_cvKolIndDur;
ConVar g_cvKolIndRadius;
ConVar g_cvKolBlockCd;
ConVar g_cvKolBlockDur;
ConVar g_cvKolRockDmg;
ConVar g_cvKolRockScale;

// ------------------------- ESTADO POR JUGADOR -----------------------
int    g_iKolChargeState[MAXPLAYERS + 1];   // KOL_CHG_*
float  g_fKolChargeEnd[MAXPLAYERS + 1];     // fin del DASH (extensible)
float  g_fKolChargeCdUntil[MAXPLAYERS + 1];
float  g_fKolWindupStart[MAXPLAYERS + 1];
float  g_fKolStuckSince[MAXPLAYERS + 1];
int    g_iKolSavedColGroup[MAXPLAYERS + 1]; // DEBRIS enter/exit
ArrayList g_hKolHitList[MAXPLAYERS + 1];    // EntRefs empalados (fling final)

int    g_iKolGrabVictim[MAXPLAYERS + 1];    // EntRef del agarrado
int    g_iKolGrabPunches[MAXPLAYERS + 1];
int    g_iKolGrabMoveType[MAXPLAYERS + 1];  // movetype a restaurar (commons)
float  g_fKolLungeUntil[MAXPLAYERS + 1];    // ventana del lunge 0.6s
float  g_fKolGrabHoldEnd[MAXPLAYERS + 1];   // max 10s en vilo
float  g_fKolGrabCdUntil[MAXPLAYERS + 1];
bool   g_bKolGrabLunged[MAXPLAYERS + 1];    // el impulso del lunge ya salio

float  g_fKolBlockUntil[MAXPLAYERS + 1];
float  g_fKolBlockCdUntil[MAXPLAYERS + 1];
bool   g_bKolBlockCountered[MAXPLAYERS + 1]; // el parry ya disparo la roca

float  g_fKolIndUntil[MAXPLAYERS + 1];
float  g_fKolIndCdUntil[MAXPLAYERS + 1];
float  g_fKolIndNextPing[MAXPLAYERS + 1];

// ------------------------- AVATAR ESPEJO ----------------------------
int    g_iKolAvatar[MAXPLAYERS + 1];        // EntRef copia R (0 = sin avatar)
int    g_iKolAvatarL[MAXPLAYERS + 1];       // EntRef copia L
int    g_iKolBodyRender[MAXPLAYERS + 1];    // render del cuerpo oculto
int    g_iKolAnimState[MAXPLAYERS + 1];
int    g_iKolAnimShotState[MAXPLAYERS + 1];  // v1.1: one-shot activo (-1 = ninguno)
float  g_fKolAnimShotUntil[MAXPLAYERS + 1];  // v1.1: fin del one-shot
int    g_iKolAnimShotTier[MAXPLAYERS + 1];   // v1.3: prioridad del one-shot activo (KOL_SHOT_*)
float  g_fKolGrabThrowAt[MAXPLAYERS + 1];    // v1.3: lanzamiento encadenado tras el 3er puo (0 = off)
int    g_iKolGrabFlingRef[MAXPLAYERS + 1];   // v1.3: victima del fling demorado (+0.3s, EntRef)
float  g_fKolSeqDur[KOL_ST_COUNT];           // v1.3: duraciones REALES medidas al .mdl (0 = fallback)

// v1.4: MOTOR DE CAPAS — los one-shots de la serie grab viajan en
// m_AnimOverlay (brazos) mientras el main sigue en locomocion (piernas)
int    g_iKolSeqIdx[KOL_ST_COUNT];             // v1.4: INDICE de secuencia (lo da la sonda — las capas usan indice, no nombre)
bool   g_bKolLayersOK = false;                 // v1.4: el prop soporta m_AnimOverlay (sonda por mapa)
int    g_iKolLayerSize = 0;                    // v1.4: slots disponibles
int    g_iKolLayShotState[MAXPLAYERS + 1];     // v1.4: one-shot de capa activo (-1 = ninguno)
float  g_fKolLayShotStart[MAXPLAYERS + 1];     // v1.4: arranque del one-shot de capa
float  g_fKolLayShotDur[MAXPLAYERS + 1];       // v1.4: duracion del one-shot de capa
bool   g_bKolLayHoldOn[MAXPLAYERS + 1];        // v1.4: pose GrabIdle sostenida en slot 1
Handle g_hKolLayThink = null;                  // v1.4: driver per-tick del ciclo de la capa
bool   g_bKolCalibDone = false;              // v1.3: el calibrador ya corrio en este mapa
int    g_iKolCalibProp = INVALID_ENT_REFERENCE; // v1.3: prop desechable del calibrador
int    g_iKolCalibStage = 0;                 // v1.3: 0=reach 1=punch 2=throw
float  g_fKolCalibStart = 0.0;               // v1.3: arranque del stage actual
float  g_fKolCalibLastCycle = -1.0;          // v1.3: ultimo m_flCycle leido
float  g_fKolJumpStart[MAXPLAYERS + 1];
float  g_fKolBodyYaw[MAXPLAYERS + 1];
float  g_fKolYawLastT[MAXPLAYERS + 1];
float  g_fKolSmLoc[MAXPLAYERS + 1][3];
float  g_fKolSmLocL[MAXPLAYERS + 1][3];
bool   g_bKolSmSnap[MAXPLAYERS + 1];
bool   g_bKolWelcomeSaid[MAXPLAYERS + 1];
bool   g_bKolHooked[MAXPLAYERS + 1];      // OnTakeDamage enganchado (auto-gestion FSM)
bool   g_bKolHpApplied[MAXPLAYERS + 1];   // vida max aplicada en esta vida

// ------------------------- ASSETS -----------------------------------
bool   g_bKolModelOK = false;              // kolossos.mdl montado (patron Blaze)
bool   g_bKolWarnedModel = false;
bool   g_bKolSeqsOK = false;
bool   g_bKolSeqOK[KOL_ST_COUNT];
char   g_sKolSeqName[KOL_ST_COUNT][24] = { "idle", "walk", "run", "jump", "fall",
                                            "idle", "idle", "run", "run", "idle",
                                            "idle", "idle", "idle", "idle", "idle",
                                            // v1.3: la serie del grab (defaults = nombres de los SMD)
                                            "Grab", "GrabIdle", "GrabPunch", "GrabThrow" };

// sonidos del killer (sound/om/kolossos/) — fallback nativo si falta
bool   g_bKolSndSigh, g_bKolSndRumble, g_bKolSndRoar, g_bKolSndStartup;
bool   g_bKolSndImpacts, g_bKolSndLaugh, g_bKolSndWallBump;
bool   g_bKolSndGrabLunge, g_bKolSndGrabUse, g_bKolSndImpale;
bool   g_bKolSndPunch, g_bKolSndPullOut, g_bKolSndWhisper, g_bKolSndBlock;
bool   g_bKolSndPing;                      // om/metal/ping1.wav (ya del suite)
bool   g_bKolSndSlam;                       // v1.1: Sound.mp3 (slam con empalados)
bool   g_bKolSndLaughKill;                  // v1.1: Kolossos laughing.wav (Kill)
char   g_sKolLaughPath[PLATFORM_MAX_PATH];  // v1.1: ruta real (carpeta Kolossos/kolossos)
bool   g_bKolRockModel = false;            // rockgranite03b.mdl (nativo L4D2)

// sprites del indicator: g_iKolIndSprite[entidx] = EntRef del glow
int    g_iKolIndSprite[KOL_MAXENT + 1];

// ------------------------- TIMER FSM --------------------------------
Handle g_hKolThink = null;                 // 10 Hz (patron T_BlazeAvatarThink)

// =====================================================================
//  UTILIDADES
// =====================================================================

bool Kolossos_PlayerIs(int client)
{
    if (client < 1 || client > MaxClients) return false;
    if (!IsClientInGame(client)) return false;
    return g_iPlayerCharIdx[client] == KOLOSSOS_INDEX;
}

bool Kolossos_Valid(int client)
{
    if (!Kolossos_PlayerIs(client)) return false;
    return (IsPlayerAlive(client) && GetClientTeam(client) == 2);
}

float Kolossos_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// la direccion de movimiento (receta Metal_GetMoveDir: mirar no frena)
void Kolossos_GetMoveDir(int client, float dir[3])
{
    float ang[3];
    GetClientEyeAngles(client, ang);
    dir[0] = Cosine(DegToRad(ang[1]));
    dir[1] = Sine(DegToRad(ang[1]));
    dir[2] = 0.0;
}

void Kolossos_Emit(int client, bool has, const char[] real, const char[] fallback)
{
    if (has) EmitSoundToAll(real, client, _, KOL_SND_LEVEL);
    else if (fallback[0] != '\0') EmitSoundToAll(fallback, client, _, KOL_SND_LEVEL);
}

// =====================================================================
//  CICLO DE VIDA DEL MODULO
// =====================================================================

public void Kolossos_OnPluginStart()
{
    g_cvKolEnabled     = CreateConVar("kolossos_enabled", "1", "Kolossos: personaje activo (0 = kit apagado)", 0, true, 0.0, true, 1.0);
    g_cvKolModel       = CreateConVar("kolossos_model", "models/noodles/om/kolossos.mdl", "Kolossos: ruta del .mdl del avatar espejo (sin archivo = sin avatar, kit sigue)");
    g_cvKolAvatar      = CreateConVar("kolossos_avatar", "1", "Kolossos: avatar espejo montado sobre el survivor actual (0 = solo kit)", 0, true, 0.0, true, 1.0);
    g_cvKolHealth      = CreateConVar("kolossos_health", "670", "Kolossos: vida maxima al elegirlo (GMod 670; 0 = sin cambio)", 0, true, 0.0);
    g_cvKolResist      = CreateConVar("kolossos_resistance", "100", "Kolossos: % de dano recibido (100 = neutro, 50 = mitad)", 0, true, 1.0, true, 1000.0);

    g_cvKolChgSpeed    = CreateConVar("kolossos_charge_speed", "750", "Kolossos [Z] Charge: velocidad uu/s de la avalancha (GMod 1400; calibracion L4D2 tipo Metal)", 0, true, 100.0, true, 1400.0);
    g_cvKolChgDur      = CreateConVar("kolossos_charge_duration", "7", "Kolossos [Z] Charge: duracion base en s (GMod 7)", 0, true, 1.0, true, 30.0);
    g_cvKolChgMaxDur   = CreateConVar("kolossos_charge_maxduration", "20", "Kolossos [Z] Charge: tope total con extensiones por empale (anti-horda infinita)", 0, true, 5.0, true, 60.0);
    g_cvKolChgDmg      = CreateConVar("kolossos_charge_damage", "25", "Kolossos [Z] Charge: dano de empale por victima (GMod 25)", 0, true, 1.0);
    g_cvKolChgAdd      = CreateConVar("kolossos_charge_impale_add", "3.75", "Kolossos [Z] Charge: s extra por victima nueva (GMod 3.75)", 0, true, 0.0, true, 10.0);
    g_cvKolChgCd       = CreateConVar("kolossos_charge_cooldown", "22", "Kolossos [Z] Charge: cooldown s (GMod 22)", 0, true, 1.0);
    g_cvKolChgRadius   = CreateConVar("kolossos_charge_radius", "90", "Kolossos [Z] Charge: radio de empale u (GMod 90)", 0, true, 30.0, true, 250.0);

    g_cvKolGrabCd      = CreateConVar("kolossos_grab_cooldown", "25", "Kolossos [X] Grab: cooldown s (GMod 25)", 0, true, 1.0);
    g_cvKolGrabWindow  = CreateConVar("kolossos_grab_window", "0.6", "Kolossos [X] Grab: ventana del lunge s (GMod 0.6)", 0, true, 0.1, true, 3.0);
    g_cvKolGrabHold    = CreateConVar("kolossos_grab_hold", "10", "Kolossos [X] Grab: max s con la victima en vilo (GMod 10)", 0, true, 1.0, true, 30.0);
    g_cvKolGrabPunches = CreateConVar("kolossos_grab_punches", "3", "Kolossos [X] Grab: puos antes del lanzamiento (GMod 3)", 0, true, 1.0, true, 10.0);
    g_cvKolGrabPunchDmg= CreateConVar("kolossos_grab_punchdamage", "15", "Kolossos [X] Grab: dano por puo (GMod slamDamage 15)", 0, true, 1.0);
    g_cvKolGrabCancel  = CreateConVar("kolossos_grab_cancel", "0", "Kolossos [X] Grab: X de nuevo suelta a la victima (GMod CanCancelGrab=0)", 0, true, 0.0, true, 1.0);
    // v1.4: el motor de capas (m_AnimOverlay) — brazos de la serie grab
    // SOBRE la locomocion (piernas andando, como los survivors al cambiar
    // arma). 1 = auto (capas si el prop las soporta); 0 = monocapa v1.3
    g_cvKolGrabLayers  = CreateConVar("kolossos_grab_layers", "1", "Kolossos [X] Grab: 1 = serie grab por CAPAS m_AnimOverlay (piernas vivas), 0 = monocapa", 0, true, 0.0, true, 1.0);
    g_cvKolGrabTank    = CreateConVar("kolossos_grab_tank", "1", "Kolossos [X] Grab: 1 = TAMBIEN agarra al tank (v1.4: el veto de la v1.0 fuera)", 0, true, 0.0, true, 1.0);
    g_cvKolGrabWitch   = CreateConVar("kolossos_grab_witch", "1", "Kolossos [X] Grab: 1 = tambien agarra a la witch", 0, true, 0.0, true, 1.0);

    g_cvKolIndCd       = CreateConVar("kolossos_indicator_cooldown", "14", "Kolossos [C] Indicator: cooldown s (GMod 14)", 0, true, 1.0);
    g_cvKolIndDur      = CreateConVar("kolossos_indicator_duration", "5", "Kolossos [C] Indicator: duracion s (GMod 5)", 0, true, 1.0, true, 30.0);
    g_cvKolIndRadius   = CreateConVar("kolossos_indicator_radius", "3000", "Kolossos [C] Indicator: radio de deteccion u (0 = todo el mapa)", 0, true, 0.0);

    g_cvKolBlockCd     = CreateConVar("kolossos_block_cooldown", "14", "Kolossos [B] Block: cooldown s (GMod 14)", 0, true, 1.0);
    g_cvKolBlockDur    = CreateConVar("kolossos_block_duration", "3.5", "Kolossos [B] Block: duracion s (GMod 3.5)", 0, true, 0.5, true, 10.0);
    g_cvKolRockDmg     = CreateConVar("kolossos_rock_damage", "35", "Kolossos [B] Block: dano de la roca del contragolpe", 0, true, 1.0);
    g_cvKolRockScale   = CreateConVar("kolossos_rock_scale", "3", "Kolossos [B] Block: escala de la roca (GMod 3)", 0, true, 0.5, true, 6.0);

    RegConsoleCmd("sm_kolossos", Kolossos_CmdDebug, "Kolossos: estado del kit (debug)");

    HookEvent("player_spawn",   Kolossos_EventSpawn);
    HookEvent("player_death",   Kolossos_EventDeath);
    HookEvent("round_start",    Kolossos_EventRoundStart);

    for (int i = 1; i <= MaxClients; i++)
    {
        g_iKolSavedColGroup[i] = -1;
        g_iKolBodyRender[i]    = -1;
        g_iKolAnimState[i]     = -1;
        g_iKolAnimShotState[i] = -1;
        g_fKolAnimShotUntil[i] = 0.0;
        g_iKolLayShotState[i]  = -1;   // v1.4: sin one-shot de capa
        g_fKolLayShotStart[i]  = 0.0;
        g_fKolLayShotDur[i]    = 0.0;
        g_bKolLayHoldOn[i]     = false;
        g_iKolGrabMoveType[i]  = -1;
        g_iKolGrabVictim[i]    = 0;
        g_hKolHitList[i]       = null;
    }
    for (int e = 0; e <= KOL_MAXENT; e++) g_iKolIndSprite[e] = 0;

    delete g_hKolThink;
    g_hKolThink = CreateTimer(0.1, T_KolossosThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // v1.4: driver per-tick del ciclo de las capas (m_flCycle del slot 2
    // — el cliente NO avanza los overlays de un prop: lo empuja el server)
    delete g_hKolLayThink;
    g_hKolLayThink = CreateTimer(0.0, T_Kol_LayerThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void Kolossos_OnMapStart()
{
    // v1.2 FIX "AL ELEGIRLO NO SALE EL AVATAR" — la FSM de 10 Hz llevaba
    // TIMER_FLAG_NO_MAPCHANGE pero solo se creaba en OnPluginStart: al
    // primer cambio de mapa moria y ya nunca revivia (sin FSM no hay
    // montaje del avatar, ni auto-reparacion de la L, ni tick del kit).
    // Receta canon del suite (Rouge v10 L786 / Blaze v2.11 L755 / Silver
    // v2.0): re-crear el timer AQUI, en CADA arranque de mapa.
    delete g_hKolThink;
    g_hKolThink = CreateTimer(0.1, T_KolossosThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // v1.4: el driver de capas tambien renace en cada mapa (leccion v1.2)
    delete g_hKolLayThink;
    g_hKolLayThink = CreateTimer(0.0, T_Kol_LayerThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // modelo del avatar (patron Blaze g_bBlazeModelOK)
    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));
    g_bKolModelOK = (mdl[0] != '\0') && FileExists(mdl, true);
    if (g_bKolModelOK)
    {
        PrecacheModel(mdl, true);
        g_bKolSeqsOK = false;   // se resuelven al nacer el primer avatar
        g_bKolCalibDone = false;   // v1.3: las duraciones se miden de nuevo (prop nuevo)
        g_bKolLayersOK = false;    // v1.4: la sonda de capas corre de nuevo
        g_iKolLayerSize = 0;
        for (int s = 0; s < KOL_ST_COUNT; s++)
        {
            g_fKolSeqDur[s] = 0.0;
            g_iKolSeqIdx[s] = -1;   // v1.4: indices reales al re-sondear
        }
    }
    else if (!g_bKolWarnedModel)
    {
        g_bKolWarnedModel = true;
        LogMessage("[Kolossos] Sin '%s' — avatar espejo OFF (el kit funciona igual). Copia el .mdl a esa ruta para activarlo.", mdl);
    }

    // la roca del contragolpe (nativa L4D2: models/props_wasteland/rockgranite03b.mdl)
    g_bKolRockModel = FileExists("models/props_wasteland/rockgranite03b.mdl", true);
    if (g_bKolRockModel) PrecacheModel("models/props_wasteland/rockgranite03b.mdl", true);

    // sonidos del killer: carpeta om/kolossos del addon GMod + fallbacks nativos
    g_bKolSndSigh      = FileExists("sound/om/kolossos/kol sigh i think.wav", true);
    g_bKolSndRumble    = FileExists("sound/om/kolossos/kol charge start ground rumble.wav", true);
    g_bKolSndRoar      = FileExists("sound/om/kolossos/KolossosChargeRoar.wav", true);
    g_bKolSndStartup   = FileExists("sound/om/kolossos/StartUpCharge.wav", true);
    g_bKolSndImpacts   = FileExists("sound/om/kolossos/Kol impacts.wav", true);
    g_bKolSndLaugh     = FileExists("sound/om/kolossos/Kol charge laugh impale.wav", true);
    g_bKolSndWallBump  = FileExists("sound/om/kolossos/Kol wall bump.wav", true);
    g_bKolSndGrabLunge = FileExists("sound/om/kolossos/kol grab lunge.wav", true);
    g_bKolSndGrabUse   = FileExists("sound/om/kolossos/Kol uses grab.wav", true);
    g_bKolSndImpale    = FileExists("sound/om/kolossos/Kol impales.wav", true);
    g_bKolSndPunch     = FileExists("sound/om/kolossos/kolossos punching.wav", true);
    g_bKolSndPullOut   = FileExists("sound/om/kolossos/kol sting and pull out.wav", true);
    g_bKolSndWhisper   = FileExists("sound/om/kolossos/kol whispers.wav", true);
    g_bKolSndBlock     = FileExists("sound/om/kolossos/kol block.wav", true);
    g_bKolSndPing      = FileExists("sound/om/metal/ping1.wav", true);   // ya lo usa Metal
    // v1.1: el slam con empalados ("Sound.mp3" literal del Lua l.1735) y
    // la risa de la ejecucion (carpeta con K mayuscula en el Lua l.1225:
    // "OM/Kolossos/Kolossos laughing.wav" — se prueban ambas mayusculas)
    g_bKolSndSlam      = FileExists("sound/om/kolossos/Sound.mp3", true);
    g_bKolSndLaughKill = (FileExists("sound/om/Kolossos/Kolossos laughing.wav", true)
                       || FileExists("sound/om/kolossos/Kolossos laughing.wav", true));
    g_sKolLaughPath[0] = '\0';
    if (g_bKolSndLaughKill)
    {
        if (FileExists("sound/om/Kolossos/Kolossos laughing.wav", true))
            strcopy(g_sKolLaughPath, PLATFORM_MAX_PATH, "om/Kolossos/Kolossos laughing.wav");
        else
            strcopy(g_sKolLaughPath, PLATFORM_MAX_PATH, "om/kolossos/Kolossos laughing.wav");
    }

    if (g_bKolSndSigh)      PrecacheSound("om/kolossos/kol sigh i think.wav", true);
    if (g_bKolSndRumble)    PrecacheSound("om/kolossos/kol charge start ground rumble.wav", true);
    if (g_bKolSndRoar)      PrecacheSound("om/kolossos/KolossosChargeRoar.wav", true);
    if (g_bKolSndStartup)   PrecacheSound("om/kolossos/StartUpCharge.wav", true);
    if (g_bKolSndImpacts)   PrecacheSound("om/kolossos/Kol impacts.wav", true);
    if (g_bKolSndLaugh)     PrecacheSound("om/kolossos/Kol charge laugh impale.wav", true);
    if (g_bKolSndWallBump)  PrecacheSound("om/kolossos/Kol wall bump.wav", true);
    if (g_bKolSndGrabLunge) PrecacheSound("om/kolossos/kol grab lunge.wav", true);
    if (g_bKolSndGrabUse)   PrecacheSound("om/kolossos/Kol uses grab.wav", true);
    if (g_bKolSndImpale)    PrecacheSound("om/kolossos/Kol impales.wav", true);
    if (g_bKolSndPunch)     PrecacheSound("om/kolossos/kolossos punching.wav", true);
    if (g_bKolSndPullOut)   PrecacheSound("om/kolossos/kol sting and pull out.wav", true);
    if (g_bKolSndWhisper)   PrecacheSound("om/kolossos/kol whispers.wav", true);
    if (g_bKolSndBlock)     PrecacheSound("om/kolossos/kol block.wav", true);
    if (g_bKolSndPing)      PrecacheSound("om/metal/ping1.wav", true);
    if (g_bKolSndSlam)      PrecacheSound("om/kolossos/Sound.mp3", true);
    if (g_bKolSndLaughKill) PrecacheSound(g_sKolLaughPath, true);

    g_bKolWarnedModel = false;   // avisa 1 vez por mapa si falta el modelo
}

// v1.2: la mitad que faltaba del ciclo de vida (patron Rouge_OnMapEnd /
// Blaze_OnMapEnd / Silver_OnMapEnd): soltar el handle del timer AQUI,
// mientras sigue vivo, para que el OnMapStart del mapa siguiente no
// herede un handle muerto (la leccion del "crash del capitulo 2" del
// manager v3.30) — y el estado del kit a cero porque las entidades
// (avatares, sprites del indicator, rocas) murieron con el mapa. La
// limpieza PROFUNDA del gameplay la hace round_start del mapa nuevo.
public void Kolossos_OnMapEnd()
{
    delete g_hKolThink;
    delete g_hKolLayThink;   // v1.4: driver de capas fuera con el mapa

    // v1.3: el prop del calibrador y sus medidas mueren con el mapa
    int cp = EntRefToEntIndex(g_iKolCalibProp);
    if (cp > 0 && IsValidEntity(cp)) AcceptEntityInput(cp, "Kill");
    g_iKolCalibProp   = INVALID_ENT_REFERENCE;
    g_bKolCalibDone   = false;
    g_iKolCalibStage  = 0;
    g_fKolCalibStart  = 0.0;
    g_fKolCalibLastCycle = -1.0;
    for (int s = 0; s < KOL_ST_COUNT; s++) g_fKolSeqDur[s] = 0.0;

    for (int i = 1; i <= MaxClients; i++)
    {
        // avatares y anims: las entidades murieron con el mapa
        g_iKolAvatar[i]        = 0;
        g_iKolAvatarL[i]       = 0;
        g_iKolAnimState[i]     = -1;
        g_iKolAnimShotState[i] = -1;
        g_fKolAnimShotUntil[i] = 0.0;
        g_iKolAnimShotTier[i]  = KOL_SHOT_ACT;
        g_fKolGrabThrowAt[i]   = 0.0;
        g_iKolGrabFlingRef[i]  = 0;
        g_iKolBodyRender[i]    = -1;
        g_bKolSmSnap[i]        = false;

        // el kit a cero (refs y ventanas del mapa viejo)
        g_iKolChargeState[i]    = KOL_CHG_IDLE;
        g_fKolChargeEnd[i]      = 0.0;
        g_fKolWindupStart[i]    = 0.0;
        g_fKolChargeCdUntil[i]  = 0.0;
        g_fKolStuckSince[i]     = 0.0;
        g_iKolSavedColGroup[i]  = -1;
        g_iKolGrabVictim[i]     = 0;
        g_iKolGrabPunches[i]    = 0;
        g_iKolGrabMoveType[i]   = -1;
        g_fKolLungeUntil[i]     = 0.0;
        g_fKolGrabHoldEnd[i]    = 0.0;
        g_fKolGrabCdUntil[i]    = 0.0;
        g_bKolGrabLunged[i]     = false;
        g_fKolBlockUntil[i]     = 0.0;
        g_fKolBlockCdUntil[i]   = 0.0;
        g_bKolBlockCountered[i] = false;
        g_fKolIndUntil[i]       = 0.0;
        g_fKolIndCdUntil[i]     = 0.0;
        g_fKolIndNextPing[i]    = 0.0;

        // flags de auto-gestion de la FSM: el mapa nuevo arranca limpio
        g_bKolHooked[i]    = false;
        g_bKolHpApplied[i] = false;

        if (g_hKolHitList[i] != null)
        {
            delete g_hKolHitList[i];
            g_hKolHitList[i] = null;
        }
    }

    // los sprites del indicator murieron con el mapa
    for (int e = 0; e <= KOL_MAXENT; e++) g_iKolIndSprite[e] = 0;
}

// =====================================================================
//  EVENTOS (auto-enganchados — cero cableado en el manager)
// =====================================================================

public void Kolossos_EventSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!Kolossos_PlayerIs(client)) return;
    if (GetClientTeam(client) != 2) return;

    Kolossos_ResetState(client);

    // hook de dano (resistencia + block) — idempotente
    SDKUnhook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);

    // vida max (receta Metal_ApplyMaxHealth)
    Kolossos_ApplyMaxHealth(client);
}

public void Kolossos_EventDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client < 1 || client > MaxClients) return;

    // si era un agarrado por Kolossos: restaurar su movetype
    if (g_iPlayerCharIdx[client] != KOLOSSOS_INDEX)
    {
        for (int k = 1; k <= MaxClients; k++)
            if (g_iKolGrabVictim[k] != 0 && EntRefToEntIndex(g_iKolGrabVictim[k]) == client)
                Kolossos_GrabRelease(k, false, true);
        return;
    }

    // el Kolossos murio: cancelar todo (el avatar lo baja la FSM en 0.1s)
    Kolossos_ResetState(client);
    SDKUnhook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
    Kolossos_RestoreMaxHealth(client);
}

public void Kolossos_EventRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // barrido de arranque: huerfanos del mapa anterior fuera (patron Suite)
    Kolossos_KillGhostAvatarProps();
    Kolossos_KillAllIndSprites();

    for (int i = 1; i <= MaxClients; i++)
    {
        Kolossos_ResetState(i);
        g_bKolWelcomeSaid[i] = false;
    }
}

// =====================================================================
//  RESET / CLEANUP (manager: CleanupCharModuleState case KOLOSSOS_INDEX)
// =====================================================================

void Kolossos_ResetState(int client)
{
    // cancelar charge (restaura colision/velocidad/FOV/loop)
    if (g_iKolChargeState[client] != KOL_CHG_IDLE)
        Kolossos_ChargeEnd(client, false);

    // soltar al agarrado
    if (g_iKolGrabVictim[client] != 0)
        Kolossos_GrabRelease(client, false, false);

    g_fKolLungeUntil[client]   = 0.0;
    g_fKolGrabCdUntil[client]  = 0.0;
    g_fKolBlockUntil[client]   = 0.0;
    g_fKolBlockCdUntil[client] = 0.0;
    g_bKolBlockCountered[client] = false;
    g_iKolAnimShotState[client] = -1;   // v1.1: sin one-shot
    g_fKolAnimShotUntil[client] = 0.0;
    g_iKolAnimShotTier[client]  = KOL_SHOT_ACT;   // v1.3
    Kolossos_LayerHold(client, false);            // v1.4: pose de sujetar fuera
    Kolossos_LayerClearShot(client);              // v1.4: one-shot de capa fuera
    g_fKolGrabThrowAt[client]   = 0.0;            // v1.3: sin lanzamiento pendiente
    g_iKolGrabFlingRef[client]  = 0;              // v1.3 (anula el fling demorado si habia)
    g_fKolIndUntil[client]     = 0.0;
    g_fKolIndCdUntil[client]   = 0.0;
    g_fKolIndNextPing[client]  = 0.0;

    if (g_hKolHitList[client] != null)
    {
        delete g_hKolHitList[client];
        g_hKolHitList[client] = null;
    }
}

// limpieza total: cambio de personaje / disconnect (manager la llama;
// para disconnect el propio modulo la invoca desde la FSM)
void Kolossos_CleanupState(int client)
{
    Kolossos_ResetState(client);
    Kolossos_KillAvatar(client);
    Kolossos_RestoreMaxHealth(client);
    SDKUnhook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
    g_bKolHooked[client]     = false;   // el slot puede reutilizarse (disconnect)
    g_bKolHpApplied[client]  = false;
    g_bKolWelcomeSaid[client] = false;
    g_iKolAnimState[client]   = -1;
    g_iKolAnimShotState[client] = -1;
    g_fKolAnimShotUntil[client] = 0.0;
    g_iKolAnimShotTier[client]  = KOL_SHOT_ACT;   // v1.3
    g_iKolLayShotState[client] = -1;              // v1.4: capas fuera
    g_bKolLayHoldOn[client]    = false;
    g_fKolGrabThrowAt[client]   = 0.0;            // v1.3
    g_iKolGrabFlingRef[client]  = 0;              // v1.3
}

// =====================================================================
//  STATS (receta Metal_ApplyMaxHealth / RestoreMaxHealth)
// =====================================================================

void Kolossos_ApplyMaxHealth(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client) || GetClientTeam(client) != 2) return;

    int maxhp = g_cvKolHealth.IntValue;
    if (maxhp <= 0) return;

    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", maxhp);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", maxhp);

    if (IsPlayerAlive(client) && !GetEntProp(client, Prop_Send, "m_isIncapacitated"))
    {
        int hp = GetClientHealth(client);
        if (hp >= 100 && hp < maxhp)
            SetEntityHealth(client, maxhp);
    }
}

void Kolossos_RestoreMaxHealth(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] == KOLOSSOS_INDEX) return;   // sigue siendo Kolossos

    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", 100);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", 100);

    if (IsPlayerAlive(client) && GetClientHealth(client) > 100)
        SetEntityHealth(client, 100);
}

// =====================================================================
//  AVATAR ESPEJO (patron Blaze v2.11 / sonic.inc v6.30 — 14o avatar)
// =====================================================================

#define KOL_AVATAR_NAME   "kolossos_avatar_om"
#define KOL_AVATAR_NAME_L "kolossos_avatar_om_l"

int Kolossos_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
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
    g_fKolBodyYaw[client]  = ang[1];
    g_fKolYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fKolBodyYaw[client], loc);

    if (!tpMode)
    {
        // parentado (modo default: el motor mueve la posicion)
        SetVariantString("!activator");
        AcceptEntityInput(av, "SetParent", client);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", loc);
    }

    for (int k = 0; k < 3; k++)
    {
        g_fKolSmLoc[client][k]  = loc[k];
        g_fKolSmLocL[client][k] = loc[k];
    }
    g_bKolSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// resolucion de secuencias contra el .mdl REAL (sonda del patron
// Blaze_ResolveTry: SetAnimation + m_nSequence — SIN LookupSequence,// que no existe en SM 1.12; una vez por mapa)
void Kolossos_ResolveTry(int av, int state, const char[] name)
{
    if (!HasEntProp(av, Prop_Send, "m_nSequence")) return;

    int before = GetEntProp(av, Prop_Send, "m_nSequence");
    SetVariantString(name);
    AcceptEntityInput(av, "SetAnimation");
    int after = GetEntProp(av, Prop_Send, "m_nSequence");

    if (after != before)
    {
        strcopy(g_sKolSeqName[state], 24, name);
        g_bKolSeqOK[state] = true;
        g_iKolSeqIdx[state] = after;   // v1.4: el INDICE — las capas (m_AnimOverlay) usan indice, no nombre
    }
}

void Kolossos_ResolveSeqs(int av)
{
    if (g_bKolSeqsOK) return;
    g_bKolSeqsOK = true;

    // v1.4: indices de secuencia frescos (la sonda los rellena)
    for (int s = 0; s < KOL_ST_COUNT; s++) g_iKolSeqIdx[s] = -1;

    // candidatos por estado: nombres literales del registro anims del
    // killer Lua + variantes comunes por si el .mdl difiere
    char idleCands[][16]  = { "idle", "Idle", "IDLE", "idle01" };
    char walkCands[][16]  = { "walk", "Walk", "walk01", "WalkAll" };
    char runCands[][16]   = { "run", "Run", "run01", "RunAll" };
    char jumpCands[][16]  = { "jump", "Jump", "jump01" };
    char fallCands[][16]  = { "fall", "Fall", "glide", "fall01" };
    char stunCands[][16]  = { "stun", "Stun" };
    char chgStCands[][22] = { "chargestart", "ChargeStart", "charge_start" };
    char chgCands[][22]   = { "charge_notimpaled", "charge", "Charge" };
    char chgImpCands[][22]= { "Charge_impaled", "charge_impaled", "ChargeImpaled" };
    char blkStCands[][22] = { "BlockStart", "blockstart" };
    char blkCands[][22]   = { "BlockPos", "blockpos", "Block" };
    char blkPrCands[][22] = { "BlockProjectile", "blockprojectile" };
    char ctrCands[][22]   = { "BlackCounterMelee", "blackcountermelee", "CounterMelee" };
    char slamCands[][22]  = { "slaminwall", "SlamInWall", "slam_in_wall" };
    char killCands[][22]  = { "Kill", "kill", "Execution" };
    // v1.3: la serie del grab — nombres literales de los SMD del .mdl
    // (Grab 31f / GrabIdle pose / GrabPunch 51f / GrabThrow 61f)
    char grabRcCands[][22] = { "Grab", "grab", "Grab_reach", "Reach" };
    char grabHdCands[][22] = { "GrabIdle", "grabidle", "Grab_Idle", "grab_idle", "IdleGrab" };
    char grabPnCands[][22] = { "GrabPunch", "grabpunch", "Grab_Punch", "Punch" };
    char grabThCands[][22] = { "GrabThrow", "grabthrow", "Grab_Throw", "Throw" };

    for (int c = 0; c < sizeof(idleCands); c++) { Kolossos_ResolveTry(av, KOL_ST_IDLE, idleCands[c]); if (g_bKolSeqOK[KOL_ST_IDLE]) break; }
    for (int c = 0; c < sizeof(walkCands); c++) { Kolossos_ResolveTry(av, KOL_ST_WALK, walkCands[c]); if (g_bKolSeqOK[KOL_ST_WALK]) break; }
    for (int c = 0; c < sizeof(runCands);  c++) { Kolossos_ResolveTry(av, KOL_ST_RUN,  runCands[c]);  if (g_bKolSeqOK[KOL_ST_RUN])  break; }
    for (int c = 0; c < sizeof(jumpCands); c++) { Kolossos_ResolveTry(av, KOL_ST_JUMP, jumpCands[c]); if (g_bKolSeqOK[KOL_ST_JUMP]) break; }
    for (int c = 0; c < sizeof(fallCands); c++) { Kolossos_ResolveTry(av, KOL_ST_FALL, fallCands[c]); if (g_bKolSeqOK[KOL_ST_FALL]) break; }
    for (int c = 0; c < sizeof(stunCands); c++) { Kolossos_ResolveTry(av, KOL_ST_STUN, stunCands[c]); if (g_bKolSeqOK[KOL_ST_STUN]) break; }
    for (int c = 0; c < sizeof(chgStCands); c++) { Kolossos_ResolveTry(av, KOL_ST_CHARGESTART, chgStCands[c]); if (g_bKolSeqOK[KOL_ST_CHARGESTART]) break; }
    for (int c = 0; c < sizeof(chgCands); c++)   { Kolossos_ResolveTry(av, KOL_ST_CHARGE, chgCands[c]);      if (g_bKolSeqOK[KOL_ST_CHARGE]) break; }
    for (int c = 0; c < sizeof(chgImpCands); c++){ Kolossos_ResolveTry(av, KOL_ST_CHARGE_IMP, chgImpCands[c]);if (g_bKolSeqOK[KOL_ST_CHARGE_IMP]) break; }
    for (int c = 0; c < sizeof(blkStCands); c++) { Kolossos_ResolveTry(av, KOL_ST_BLOCKSTART, blkStCands[c]); if (g_bKolSeqOK[KOL_ST_BLOCKSTART]) break; }
    for (int c = 0; c < sizeof(blkCands); c++)   { Kolossos_ResolveTry(av, KOL_ST_BLOCK, blkCands[c]);        if (g_bKolSeqOK[KOL_ST_BLOCK]) break; }
    for (int c = 0; c < sizeof(blkPrCands); c++) { Kolossos_ResolveTry(av, KOL_ST_BLOCKPROJ, blkPrCands[c]);  if (g_bKolSeqOK[KOL_ST_BLOCKPROJ]) break; }
    for (int c = 0; c < sizeof(ctrCands); c++)   { Kolossos_ResolveTry(av, KOL_ST_COUNTER, ctrCands[c]);      if (g_bKolSeqOK[KOL_ST_COUNTER]) break; }
    for (int c = 0; c < sizeof(slamCands); c++)  { Kolossos_ResolveTry(av, KOL_ST_SLAMINWALL, slamCands[c]);  if (g_bKolSeqOK[KOL_ST_SLAMINWALL]) break; }
    for (int c = 0; c < sizeof(killCands); c++)  { Kolossos_ResolveTry(av, KOL_ST_KILL, killCands[c]);        if (g_bKolSeqOK[KOL_ST_KILL]) break; }
    for (int c = 0; c < sizeof(grabRcCands); c++) { Kolossos_ResolveTry(av, KOL_ST_GRABREACH, grabRcCands[c]); if (g_bKolSeqOK[KOL_ST_GRABREACH]) break; }
    for (int c = 0; c < sizeof(grabHdCands); c++) { Kolossos_ResolveTry(av, KOL_ST_GRABHOLD, grabHdCands[c]);  if (g_bKolSeqOK[KOL_ST_GRABHOLD]) break; }
    for (int c = 0; c < sizeof(grabPnCands); c++) { Kolossos_ResolveTry(av, KOL_ST_GRABPUNCH, grabPnCands[c]); if (g_bKolSeqOK[KOL_ST_GRABPUNCH]) break; }
    for (int c = 0; c < sizeof(grabThCands); c++) { Kolossos_ResolveTry(av, KOL_ST_GRABTHROW, grabThCands[c]); if (g_bKolSeqOK[KOL_ST_GRABTHROW]) break; }

    // cadena de fallbacks (nunca T-pose; cada hueco cae a su par visual
    // mas cercano: la avalancha sin anim dedicada corre, el bloqueo sin
    // pose se planta, los one-shot raros caen a idle)
    if (!g_bKolSeqOK[KOL_ST_CHARGE])
        Kolossos_FallbackTo(KOL_ST_CHARGE, KOL_ST_RUN);
    if (!g_bKolSeqOK[KOL_ST_CHARGE_IMP])
        Kolossos_FallbackTo(KOL_ST_CHARGE_IMP, g_bKolSeqOK[KOL_ST_CHARGE] ? KOL_ST_CHARGE : KOL_ST_RUN);
    if (!g_bKolSeqOK[KOL_ST_BLOCK])
        Kolossos_FallbackTo(KOL_ST_BLOCK, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_BLOCKSTART])
        Kolossos_FallbackTo(KOL_ST_BLOCKSTART, KOL_ST_BLOCK);
    if (!g_bKolSeqOK[KOL_ST_BLOCKPROJ])
        Kolossos_FallbackTo(KOL_ST_BLOCKPROJ, KOL_ST_BLOCK);
    if (!g_bKolSeqOK[KOL_ST_COUNTER])
        Kolossos_FallbackTo(KOL_ST_COUNTER, KOL_ST_BLOCK);
    if (!g_bKolSeqOK[KOL_ST_STUN])
        Kolossos_FallbackTo(KOL_ST_STUN, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_CHARGESTART])
        Kolossos_FallbackTo(KOL_ST_CHARGESTART, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_SLAMINWALL])
        Kolossos_FallbackTo(KOL_ST_SLAMINWALL, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_KILL])
        Kolossos_FallbackTo(KOL_ST_KILL, KOL_ST_IDLE);

    // v1.3: la serie del grab — cada hueco cae a su par visual mas cercano
    // (sujetando sin pose = plantado normal; sin reach/puo/throw caen por
    // la cadena hasta idle — nunca T-pose)
    if (!g_bKolSeqOK[KOL_ST_GRABHOLD])
        Kolossos_FallbackTo(KOL_ST_GRABHOLD, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_GRABREACH])
        Kolossos_FallbackTo(KOL_ST_GRABREACH, g_bKolSeqOK[KOL_ST_GRABHOLD] ? KOL_ST_GRABHOLD : KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_GRABPUNCH])
        Kolossos_FallbackTo(KOL_ST_GRABPUNCH, g_bKolSeqOK[KOL_ST_GRABREACH] ? KOL_ST_GRABREACH : KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_GRABTHROW])
        Kolossos_FallbackTo(KOL_ST_GRABTHROW, g_bKolSeqOK[KOL_ST_GRABPUNCH] ? KOL_ST_GRABPUNCH : (g_bKolSeqOK[KOL_ST_GRABREACH] ? KOL_ST_GRABREACH : KOL_ST_IDLE));

    // locomocion base: lo que falte cae a idle (regla v1.0)
    for (int s = 1; s <= KOL_ST_FALL; s++)
    {
        if (!g_bKolSeqOK[s])
            Kolossos_FallbackTo(s, KOL_ST_IDLE);
    }
}

// v1.1: copia el nombre resuelto de un estado a otro (fallback en cadena)
void Kolossos_FallbackTo(int dst, int src)
{
    strcopy(g_sKolSeqName[dst], 24, g_sKolSeqName[src]);
    g_bKolSeqOK[dst] = g_bKolSeqOK[src];
}

void Kolossos_SeqFor(int state, char[] out, int maxlen)
{
    strcopy(out, maxlen, g_sKolSeqName[state]);
}

// =====================================================================
//  v1.3: CALIBRADOR DE DURACIONES — "debe durar lo que debe durar".
//  Los SMD dicen 31/51/61 frames, pero el fps REAL lo decide el .mdl
//  compilado (el Kill del Lua dura 1.65s con 276 frames — NO es 30fps).
//  En vez de adivinar: se mide EN VIVO con un prop desechable —
//  SetAnimation + m_bClientSideAnimation 0 (el SERVER avanza m_flCycle)
//  y se cuenta cuanto tarda el ciclo en clavarse en 1.0 (fin de un
//  one-shot no loopeado). Una sola vez por mapa, al primer montaje.
// =====================================================================

int Kolossos_CalibStateOf(int stage)
{
    if (stage <= 0) return KOL_ST_GRABREACH;
    if (stage == 1) return KOL_ST_GRABPUNCH;
    return KOL_ST_GRABTHROW;
}

void Kolossos_CalibStart()
{
    if (g_bKolCalibDone || !g_bKolModelOK) return;

    // sin ninguna secuencia de la serie no hay nada que medir
    if (!g_bKolSeqOK[KOL_ST_GRABREACH] && !g_bKolSeqOK[KOL_ST_GRABPUNCH]
        && !g_bKolSeqOK[KOL_ST_GRABTHROW])
    {
        g_bKolCalibDone = true;
        return;
    }

    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));

    int cp = CreateEntityByName("prop_dynamic_override");
    if (cp <= 0 || !IsValidEntity(cp))
    {
        g_bKolCalibDone = true;   // sin prop: fallbacks 30fps y listo
        return;
    }
    DispatchKeyValue(cp, "model", mdl);
    DispatchKeyValue(cp, "targetname", "kolossos_calib_om");
    DispatchKeyValue(cp, "solid", "0");
    DispatchKeyValue(cp, "disableshadows", "1");
    DispatchSpawn(cp);

    // invisible y lejos: solo el SERVER lo anima (asi m_flCycle avanza
    // de verdad y se puede medir)
    SetEntityRenderMode(cp, RENDER_NONE);
    if (HasEntProp(cp, Prop_Send, "m_bClientSideAnimation"))
        SetEntProp(cp, Prop_Send, "m_bClientSideAnimation", 0);

    float far[3] = { 0.0, 0.0, -16000.0 };
    TeleportEntity(cp, far, NULL_VECTOR, NULL_VECTOR);

    g_iKolCalibProp      = EntIndexToEntRef(cp);
    g_iKolCalibStage     = 0;
    g_fKolCalibStart     = 0.0;
    g_fKolCalibLastCycle = -1.0;

    CreateTimer(0.1, Kolossos_T_Calib, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

// el tick del calibrador (10 Hz): stage actual -> anim -> esperar el clavado
public Action Kolossos_T_Calib(Handle timer)
{
    // el prop murio (fin de mapa): se re-calibrara en el proximo montaje
    int cp = EntRefToEntIndex(g_iKolCalibProp);
    if (cp <= 0 || !IsValidEntity(cp))
    {
        g_bKolCalibDone = false;
        return Plugin_Stop;
    }

    float now = GetEngineTime();

    // arrancar el stage actual si falta (saltando los no resueltos)
    if (g_fKolCalibStart == 0.0)
    {
        while (g_iKolCalibStage < 3 && !g_bKolSeqOK[Kolossos_CalibStateOf(g_iKolCalibStage)])
            g_iKolCalibStage++;

        if (g_iKolCalibStage >= 3) return Kolossos_CalibFinish(cp);

        char seq[24];
        Kolossos_SeqFor(Kolossos_CalibStateOf(g_iKolCalibStage), seq, sizeof(seq));
        SetVariantString(seq);
        AcceptEntityInput(cp, "SetAnimation");
        if (HasEntProp(cp, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(cp, Prop_Data, "m_flPlaybackRate", 1.0);

        g_fKolCalibStart     = now;
        g_fKolCalibLastCycle = -1.0;
        return Plugin_Continue;
    }

    float cycle = 0.0;
    if (HasEntProp(cp, Prop_Send, "m_flCycle"))
        cycle = GetEntPropFloat(cp, Prop_Send, "m_flCycle");

    int st = Kolossos_CalibStateOf(g_iKolCalibStage);

    // one-shot no loopeado: el ciclo se clava en ~1.0 al terminar
    if (cycle >= 0.999)
    {
        float dur = now - g_fKolCalibStart + 0.05;   // gracia de cierre
        if (dur < 0.2)  dur = 0.2;
        if (dur > 4.0)  dur = 0.0;    // absurdo: fallback 30fps
        g_fKolSeqDur[st] = dur;

        g_iKolCalibStage++;
        g_fKolCalibStart = 0.0;
        if (g_iKolCalibStage >= 3) return Kolossos_CalibFinish(cp);
    }
    // el ciclo dejo de avanzar: fin legitimo SOLO si ya iba avanzado
    // (cerca del 1.0); si sigue en el arranque es que el SERVER no
    // anima este prop -> calibracion imposible: fallbacks 30fps
    else if (g_fKolCalibLastCycle >= 0.0 && cycle <= g_fKolCalibLastCycle)
    {
        if (cycle < 0.5) return Kolossos_CalibGiveUp(cp);

        float dur2 = now - g_fKolCalibStart + 0.05;
        if (dur2 < 0.2) dur2 = 0.2;
        if (dur2 > 4.0) dur2 = 0.0;
        g_fKolSeqDur[st] = dur2;

        g_iKolCalibStage++;
        g_fKolCalibStart = 0.0;
        if (g_iKolCalibStage >= 3) return Kolossos_CalibFinish(cp);
    }
    else if (now - g_fKolCalibStart > 4.5)
    {
        // loopeado o algo raro: fallback 30fps para este y seguir
        g_fKolSeqDur[st] = 0.0;
        g_iKolCalibStage++;
        g_fKolCalibStart = 0.0;
        if (g_iKolCalibStage >= 3) return Kolossos_CalibFinish(cp);
    }
    else g_fKolCalibLastCycle = cycle;

    return Plugin_Continue;
}

// el server no anima el prop (client-side anim real): nada se puede
// medir en vivo — fallbacks 30fps de los SMD y fuera
Action Kolossos_CalibGiveUp(int cp)
{
    for (int s = 0; s < KOL_ST_COUNT; s++) g_fKolSeqDur[s] = 0.0;
    return Kolossos_CalibFinish(cp);
}

Action Kolossos_CalibFinish(int cp)
{
    AcceptEntityInput(cp, "Kill");
    g_iKolCalibProp = INVALID_ENT_REFERENCE;
    g_bKolCalibDone = true;
    return Plugin_Stop;
}

// =====================================================================
//  v1.4: MOTOR DE CAPAS — m_AnimOverlay sobre el avatar (ambas copias).
//  Es EL sistema que pedia el owner: "la animacion por capas si es
//  compatible con l4d2, por que no se le esta aplicando?" — L4D2 lleva
//  el sistema de overlays dentro de CBaseAnimating (los props tambien
//  lo networkan). Las secuencias grab del .mdl estan autoradas como
//  gestures (weightlist weights_swing = SOLO brazos + addlayer delta
//  de torso): en una CAPA solo contribuyen sus huesos con peso > 0,
//  asi que los BRAZOS agarran mientras las PIERNAS siguen andando en
//  el main (walk/run/idle) — el mismo sistema de los survivors al
//  cambiar arma. El cliente no avanza el ciclo de un overlay de prop:
//  el SERVER lo empuja (driver per-tick T_Kol_LayerThink).
// =====================================================================

// la sonda: ¿este prop networka m_AnimOverlay y con cuantos slots?
void Kolossos_LayerProbe(int av)
{
    g_bKolLayersOK = false;
    g_iKolLayerSize = 0;

    if (!HasEntProp(av, Prop_Send, "m_AnimOverlay.m_nSequence")) return;

    int size = GetEntPropArraySize(av, Prop_Send, "m_AnimOverlay.m_nSequence");
    if (size < KOL_LAYER_MIN_SIZE) return;   // hacen falta los slots 1 y 2

    // verificacion de escritura: el slot 2 acepta y devuelve el valor
    int before = GetEntProp(av, Prop_Send, "m_AnimOverlay.m_nSequence", _, KOL_LAYER_SHOT);
    SetEntProp(av, Prop_Send, "m_AnimOverlay.m_nSequence", 0, _, KOL_LAYER_SHOT);
    int readBack = GetEntProp(av, Prop_Send, "m_AnimOverlay.m_nSequence", _, KOL_LAYER_SHOT);
    SetEntProp(av, Prop_Send, "m_AnimOverlay.m_nSequence", before, _, KOL_LAYER_SHOT);
    if (readBack != 0) return;               // el slot no se deja escribir

    g_iKolLayerSize = size;
    g_bKolLayersOK = true;
}

// ¿el motor de capas esta operativo? (convar + sonda del mapa)
bool Kolossos_LayersActive()
{
    return g_cvKolGrabLayers != null && g_cvKolGrabLayers.BoolValue
        && g_bKolLayersOK && g_iKolLayerSize >= KOL_LAYER_MIN_SIZE;
}

// escribe un slot de capa en UN prop (todo con guarda: si el .mdl o el
// prop no soporta un campo, se escribe lo que haya)
void Kolossos_LayerWrite(int av, int slot, int seqIdx, float cycle, float weight, int order)
{
    if (av <= 0 || !IsValidEntity(av)) return;

    SetEntProp(av, Prop_Send, "m_AnimOverlay.m_nSequence", seqIdx, _, slot);
    SetEntPropFloat(av, Prop_Send, "m_AnimOverlay.m_flCycle", cycle, slot);
    if (HasEntProp(av, Prop_Send, "m_AnimOverlay.m_flPrevCycle"))
        SetEntPropFloat(av, Prop_Send, "m_AnimOverlay.m_flPrevCycle", cycle, slot);
    if (HasEntProp(av, Prop_Send, "m_AnimOverlay.m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Send, "m_AnimOverlay.m_flPlaybackRate", 1.0, slot);
    SetEntPropFloat(av, Prop_Send, "m_AnimOverlay.m_flWeight", weight, slot);
    if (HasEntProp(av, Prop_Send, "m_AnimOverlay.m_flWeightDeltaRate"))
        SetEntPropFloat(av, Prop_Send, "m_AnimOverlay.m_flWeightDeltaRate", 0.0, slot);
    if (HasEntProp(av, Prop_Send, "m_AnimOverlay.m_nOrder"))
        SetEntProp(av, Prop_Send, "m_AnimOverlay.m_nOrder", order, _, slot);
}

// escribe el mismo slot en las DOS copias del avatar (R + L)
void Kolossos_LayerWriteBoth(int client, int slot, int seqIdx, float cycle, float weight, int order)
{
    int av = EntRefToEntIndex(g_iKolAvatar[client]);
    if (av > 0 && IsValidEntity(av))
        Kolossos_LayerWrite(av, slot, seqIdx, cycle, weight, order);
    if (g_iKolAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iKolAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
            Kolossos_LayerWrite(avL, slot, seqIdx, cycle, weight, order);
    }
}

// lanza un ONE-SHOT de la serie grab en la capa 2 (brazos) — el main
// sigue en locomocion (piernas). Devuelve false si hay que caer al
// motor monocapa (sin capas / secuencia sin resolver)
bool Kolossos_LayerShot(int client, int state, float dur)
{
    if (!Kolossos_LayersActive()) return false;
    if (g_iKolSeqIdx[state] < 0) return false;   // la sonda no la resolvio

    Kolossos_LayerWriteBoth(client, KOL_LAYER_SHOT, g_iKolSeqIdx[state], 0.0, 1.0, 2);
    g_iKolLayShotState[client] = state;
    g_fKolLayShotStart[client] = GetEngineTime();
    g_fKolLayShotDur[client]   = (dur > 0.15) ? dur : 0.2;
    return true;
}

// apaga la capa del one-shot
void Kolossos_LayerClearShot(int client)
{
    if (g_iKolLayShotState[client] < 0) return;
    g_iKolLayShotState[client] = -1;
    Kolossos_LayerWriteBoth(client, KOL_LAYER_SHOT, 0, 0.0, 0.0, 0);
}

// la POSE de sujetar (GrabIdle, el ACT_HOVER del GMod) en la capa 1:
// 1 frame congelado — brazos sujetando mientras el main camina/corre.
// Sin resolver GrabIdle: se queda en locomocion pura (degradacion fina)
void Kolossos_LayerHold(int client, bool on)
{
    if (on == g_bKolLayHoldOn[client]) return;
    if (!on)
    {
        g_bKolLayHoldOn[client] = false;
        Kolossos_LayerWriteBoth(client, KOL_LAYER_HOLD, 0, 0.0, 0.0, 0);
        return;
    }
    if (!Kolossos_LayersActive()) return;
    if (g_iKolSeqIdx[KOL_ST_GRABHOLD] < 0) return;

    g_bKolLayHoldOn[client] = true;
    Kolossos_LayerWriteBoth(client, KOL_LAYER_HOLD, g_iKolSeqIdx[KOL_ST_GRABHOLD], 0.0, 1.0, 1);
}

// el dispatcher de la serie grab: CAPAS si se puede (piernas vivas),
// monocapa v1.3 si no — MISMA prioridad en ambos mundos
void Kolossos_GrabShot(int client, int state, float dur, int tier)
{
    if (Kolossos_LayerShot(client, state, dur)) return;
    Kolossos_AnimShot(client, state, dur, tier);   // fallback monocapa
}

// driver per-tick: empuja el m_flCycle de la capa one-shot (el cliente
// NO avanza overlays de props — sin esto la capa quedaria clavada en 0)
public Action T_Kol_LayerThink(Handle timer)
{
    float now = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iKolLayShotState[i] < 0) continue;

        int av = EntRefToEntIndex(g_iKolAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iKolLayShotState[i] = -1;   // avatar muerto: tracking fuera
            continue;
        }

        float t = (now - g_fKolLayShotStart[i]) / g_fKolLayShotDur[i];
        if (t < 0.0) t = 0.0;
        if (t > 1.0) t = 1.0;

        // el LANZAMIENTO y el REACH duran lo que deben durar: el ciclo
        // llega a 1.0 y la capa se apaga recien ahi (nadie la corta)
        if (t >= 1.0)
        {
            Kolossos_LayerClearShot(i);
            continue;
        }

        Kolossos_LayerWriteBoth(i, KOL_LAYER_SHOT, g_iKolSeqIdx[g_iKolLayShotState[i]], t, 1.0, 2);
    }

    return Plugin_Continue;
}

// transmit: R la ven TODOS menos el dueno; L solo el dueno
public Action Kolossos_TransmitAvatarR(int entity, int client)
{
    if (Kolossos_PlayerIs(client)) return Plugin_Handled;
    return Plugin_Continue;
}

public Action Kolossos_TransmitAvatarL(int entity, int client)
{
    if (Kolossos_PlayerIs(client)) return Plugin_Continue;
    return Plugin_Handled;
}

void Kolossos_CreateAvatarL(int client)
{
    if (!g_bKolModelOK) return;
    if (!Kolossos_Valid(client)) return;
    if (g_iKolAvatar[client] == 0) return;

    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));
    int av = Kolossos_CreateAvatarProp(client, mdl, KOL_AVATAR_NAME_L);
    if (av == 0) return;

    char seqIdle[24];
    Kolossos_SeqFor(KOL_ST_IDLE, seqIdle, sizeof(seqIdle));
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Kolossos_TransmitAvatarL);
    g_iKolAvatarL[client] = EntIndexToEntRef(av);
}

void Kolossos_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iKolAvatarL[client]);
    if (g_iKolAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Kolossos_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iKolAvatarL[client] = 0;
}

void Kolossos_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    Kolossos_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iKolAvatar[client]);
    if (g_iKolAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Kolossos_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iKolAvatar[client] = 0;
    g_iKolAnimState[client] = -1;

    // devolver el cuerpo (spectate/revive/cambio de personaje)
    if (IsClientInGame(client) && g_iKolBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iKolBodyRender[client]));
        g_iKolBodyRender[client] = -1;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Kolossos_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Kolossos_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Kolossos_AvatarFollow);
}

void Kolossos_CreateAvatar(int client)
{
    if (!Kolossos_Valid(client)) return;

    // limpieza del ciclo anterior (reemplazo limpio)
    Kolossos_KillAvatar(client);

    // adopcion: todo prop de ESTE modulo que la FSM no rastrea = huerfano
    Kolossos_KillGhostAvatarProps();

    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));
    int av = Kolossos_CreateAvatarProp(client, mdl, KOL_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    Kolossos_ResolveSeqs(av);

    // v1.4: sonda de capas (m_AnimOverlay) — una vez por mapa, con el
    // mismo prop de la sonda de nombres
    Kolossos_LayerProbe(av);

    // v1.3: medir las duraciones reales de la serie del grab contra el
    // .mdl ("debe durar lo que debe durar") — una vez por mapa
    Kolossos_CalibStart();

    char seqIdle[24];
    Kolossos_SeqFor(KOL_ST_IDLE, seqIdle, sizeof(seqIdle));
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");
    g_iKolAnimState[client] = KOL_ST_IDLE;

    SDKHook(av, SDKHook_SetTransmit, Kolossos_TransmitAvatarR);

    // v1.2: el ref de la R ANTES de crear la L — CreateAvatarL valida que
    // la R exista, y en v1.0/v1.1 este ref se asignaba DESPUES: la copia
    // L (la que ve el DUENO) nacia solo por la auto-reparacion de la FSM
    // 0.1s tarde, con el cuerpo ya en RENDER_NONE = una decima de
    // invisibilidad total en cada montaje. Ahora nace en el mismo tick.
    g_iKolAvatar[client] = EntIndexToEntRef(av);

    g_iKolAvatarL[client] = 0;
    Kolossos_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iKolBodyRender[client] = view_as<int>(curMode);
    else if (g_iKolBodyRender[client] == -1)
        g_iKolBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    // per-tick: angulos locales (contra-rotacion del parent)
    SDKHook(client, SDKHook_PostThink, Kolossos_AvatarFollow);

    // pulso de pausa en cada montaje (la infra del suite)
    Tails_PauseFix_Trigger(client);

    if (!g_bKolWelcomeSaid[client] && !IsFakeClient(client))
    {
        g_bKolWelcomeSaid[client] = true;
        PrintToChat(client, "\x04[Kolossos]\x01 Avatar espejo activo — 14o avatar del suite. Z Carga | X Agarre | C Indicator | B Bloqueo.");
    }
}

// (patron Blaze_IsMyAvatarRef — huerfanos por definicion)
bool Kolossos_IsMyAvatarRef(int ref)
{
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iKolAvatar[i] == ref) return true;
        if (g_iKolAvatarL[i] == ref) return true;
    }
    return false;
}

void Kolossos_KillGhostAvatarProps()
{
    int ent = -1;
    char name[32];
    while ((ent = FindEntityByClassname(ent, "prop_dynamic_override")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        GetEntPropString(ent, Prop_Data, "m_iName", name, sizeof(name));
        if (StrEqual(name, KOL_AVATAR_NAME) || StrEqual(name, KOL_AVATAR_NAME_L))
        {
            if (!Kolossos_IsMyAvatarRef(EntIndexToEntRef(ent)))
                AcceptEntityInput(ent, "Kill");   // huerfano
        }
    }
}

// per-tick: yaw suavizado 900 grados/s + TP/local del R + contra-rotacion L
public void Kolossos_AvatarFollow(int client)
{
    if (g_iKolAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Kolossos_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    float yawObj = g_fKolBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fKolBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    float now = GetEngineTime();
    float dt  = now - g_fKolYawLastT[client];
    g_fKolYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fKolBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fKolBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bKolSmSnap[client];
    GetClientAbsAngles(client, par);
    float yawPuppet = g_fKolBodyYaw[client];

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iKolAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        if (Tails_AvatarTPOn())
        {
            float posTP[3], angTP[3];
            GetClientAbsOrigin(client, posTP);
            angTP[0] = 0.0;
            angTP[1] = yawPuppet;
            angTP[2] = 0.0;
            TeleportEntity(av, posTP, angTP, NULL_VECTOR);
            Tails_MarkInterp(av);
        }
        else
        {
            Tails_AvatarLocalAngles(par[0], par[1], yawPuppet, loc);
            loc[1] = Tails_UnwrapYaw(g_fKolSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fKolSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fKolSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }
    g_bKolSmSnap[client] = false;

    // ---- copia L: contra-rotada contra los EYE del dueno ----
    // v1.1 FIX DEL DOBLADO (reporte del owner: "si muevo la camara el
    // personaje se dobla a mirar" — el bug v5.4 de la era Tails): la
    // copia L es la que ve el DUEÑO, y SU cliente arma el parent con el
    // cuerpo PREDICHO = camara completa (pitch incluido). Contra-rotar
    // contra los ABS angles (lo que hizo la v1.0) deja el pitch de la
    // mirada SIN cancelar en su pantalla -> el coloso se inclina con la
    // camara y al pausar queda doblado. La receta correcta es la del
    // Tails v5.17-B / Blaze: GetClientEyeAngles + Tails_AvatarLocalAngles
    // -> vertical SIEMPRE en la pantalla del dueno (ergido tambien al
    // pausar: la ultima escritura cancela el ultimo pitch de la camara).
    if (g_iKolAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iKolAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], yawPuppet, loc);
            loc[1] = Tails_UnwrapYaw(g_fKolSmLocL[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fKolSmLocL[client], 0.05, dt, false);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fKolSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
}

// v1.1: lanza una animacion ONE-SHOT (Kill / slaminwall / counters /
// BlockStart) que bloquea la FSM hasta su fin — el equivalente del
// PillAnim directo del GMod para las anims que no son estados continuos.
// v1.3: + PRIORIDAD (tier): un disparo nuevo solo pisa al activo si es
// de igual o mayor categoria — el LANZAMIENTO (KOL_SHOT_MAX) no lo
// corta nadie, como pidio el owner ("debe durar lo que debe durar")
void Kolossos_AnimShot(int client, int state, float dur, int tier)
{
    if (client < 1 || client > MaxClients) return;

    float now = GetEngineTime();
    if (g_iKolAnimShotState[client] >= 0 && now < g_fKolAnimShotUntil[client]
        && tier < g_iKolAnimShotTier[client])
        return;   // uno de mayor prioridad esta sonando: NO se pisa

    g_iKolAnimShotState[client] = state;
    g_fKolAnimShotUntil[client] = now + dur;
    g_iKolAnimShotTier[client]  = tier;
}

// v1.3: duracion de un one-shot de la serie grab — la medida EN VIVO
// contra el .mdl si el calibrador pudo correr; si no, el fallback 30fps
// de los SMD (31/51/61 frames)
float Kolossos_ShotDur(int state, float fallback)
{
    if (g_fKolSeqDur[state] > 0.15) return g_fKolSeqDur[state];
    return fallback;
}

// anims del avatar — v1.1: EL ARBOL COMPLETO de prioridades del Lua.
// ShouldAlternate manda el orden: stun > agarre (run->walk) > bloqueo >
// chargestart > charge (impaled/no) ; los one-shot por encima de todo;
// animrates: charge 1.2 | lunge del grab 3x | curva L4D2 para el run
void Kolossos_AvatarUpdate(int client, int av, float now)
{
    int state;
    float rate = 1.0;

    // ---- [1] one-shot activo (Kill / slaminwall / counter / BlockStart) ----
    if (g_iKolAnimShotState[client] >= 0 && now < g_fKolAnimShotUntil[client])
    {
        state = g_iKolAnimShotState[client];
    }
    else
    {
        if (g_iKolAnimShotState[client] >= 0)
        {
            g_iKolAnimShotState[client] = -1;
            g_iKolAnimShotTier[client]  = KOL_SHOT_ACT;   // v1.3
        }

        // ---- [2] aturdido (ShouldAlternate: "stun" en todos los estados) ----
        if (OM_IsStunned(client))
        {
            state = KOL_ST_STUN;
        }
        // ---- [3] victima en vilo — v1.4 LA SERIE DEL GRAB POR CAPAS ----
        //      Con capas (kolossos_grab_layers 1): el main es SIEMPRE
        //      locomocion (idle/walk/jump/fall) — la pose de sujetar
        //      vive en la capa 1 y reach/puo/lanzamiento en la capa 2:
        //      las PIERNAS SIGUEN ANDANDO mientras los brazos agarran,
        //      como los survivors al cambiar arma (lo que pedia el
        //      owner). Sin capas: la regla monocapa v1.3 (walk en
        //      movimiento, pose GrabIdle SOLO plantado).
        else if (g_iKolGrabVictim[client] != 0)
        {
            bool lay = Kolossos_LayersActive();
            if (!(GetEntityFlags(client) & FL_ONGROUND))
            {
                float hvel[3];
                GetEntPropVector(client, Prop_Data, "m_vecVelocity", hvel);
                state = (hvel[2] > 40.0) ? KOL_ST_JUMP : KOL_ST_FALL;
            }
            else if (lay)
                state = (Kolossos_Speed2D(client) > 40.0) ? KOL_ST_WALK : KOL_ST_IDLE;
            else
                state = (Kolossos_Speed2D(client) > 40.0) ? KOL_ST_WALK : KOL_ST_GRABHOLD;
        }
        // ---- [4] bloqueo en pie (ShouldAlternate: "BlockPos") ----
        else if (g_fKolBlockUntil[client] > now)
        {
            state = KOL_ST_BLOCK;
        }
        // ---- [5] windup de la avalancha (ShouldAlternate: "chargestart") ----
        else if (g_iKolChargeState[client] == KOL_CHG_WINDUP)
        {
            state = KOL_ST_CHARGESTART;
        }
        // ---- [6] avalancha: impalados o no (rate 1.2 del animrates) ----
        else if (g_iKolChargeState[client] == KOL_CHG_DASH)
        {
            bool imp = (g_hKolHitList[client] != null && g_hKolHitList[client].Length > 0);
            state = imp ? KOL_ST_CHARGE_IMP : KOL_ST_CHARGE;
            rate  = 1.2;
        }
        else
        {
            bool lunge = (g_fKolLungeUntil[client] > now);

            // ---- [7] aire (jump2="jump" / glide="fall") ----
            if (!(GetEntityFlags(client) & FL_ONGROUND))
            {
                float vel[3];
                GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
                state = (vel[2] > 40.0) ? KOL_ST_JUMP : KOL_ST_FALL;
            }
            else if (g_iKolAnimState[client] == KOL_ST_JUMP
                     && now - g_fKolJumpStart[client] < 0.5)
            {
                state = KOL_ST_JUMP;   // FL_ONGROUND parpadea en escalones
            }
            else
            {
                float s = Kolossos_Speed2D(client);
                if (s < 40.0)               state = KOL_ST_IDLE;
                else if (s < 150.0
                         || (GetClientButtons(client) & IN_DUCK)) state = KOL_ST_WALK;
                else
                {
                    state = KOL_ST_RUN;
                    rate  = 1.32 * (s / 450.0);   // curva L4D2 (GMod base 1.05)
                    if (rate < 0.72) rate = 0.72;
                    if (rate > 3.6)  rate = 3.6;
                }
            }

            // ---- [8] lunge del grab: paso a 3x (animrates walk/run=3) ----
            if (lunge && (state == KOL_ST_WALK || state == KOL_ST_RUN)) rate = 3.0;
        }
    }

    if (state != g_iKolAnimState[client])
    {
        if (state == KOL_ST_JUMP) g_fKolJumpStart[client] = now;

        char seqUse[24];
        Kolossos_SeqFor(state, seqUse, sizeof(seqUse));

        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iKolAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iKolAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                SetVariantString(seqUse);   // el variant es de UN SOLO USO
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iKolAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iKolAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iKolAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

// =====================================================================
//  [Z] HABILIDAD 1 — CHARGE (la avalancha empaladora)
//  GMod l.2311-2397: windup 0.8 (suspiro 0.15 / rumble 0.35 / rugido
//  0.75) -> Charging_kolossos 7s a velocidad charge; esfera 90u:
//  ChargeImpaleDamage + HitList + extension 3.75s por victima; fling
//  final (fwd*5000+up*2000 en GMod = fwd*500+up*300 en L4D2).
//  Receta de movimiento: Metal v5.0 (stack + auto-forward + DEBRIS).
// =====================================================================

void Kolossos_Ability1(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    // puo durante un agarre = pegarle al agarrado (GMod l.2566)
    if (g_iKolGrabVictim[client] != 0)
    {
        Kolossos_GrabPunch(client);
        return;
    }

    if (g_iKolChargeState[client] != KOL_CHG_IDLE)
    {
        PrintCenterText(client, "Ya estas en avalancha.");
        return;
    }
    if (g_fKolLungeUntil[client] > now
        || g_fKolBlockUntil[client] > now
        || g_fKolIndUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolChargeCdUntil[client])
    {
        PrintCenterText(client, "Charge: %.1fs", g_fKolChargeCdUntil[client] - now);
        return;
    }

    g_fKolChargeCdUntil[client] = now + g_cvKolChgCd.FloatValue;

    // ---- WINDUP 0.8s: congelado, suspiro -> rumble -> rugido ----
    g_iKolChargeState[client]  = KOL_CHG_WINDUP;
    g_fKolWindupStart[client]  = now;
    g_fKolChargeEnd[client]    = now + KOL_CHG_WINDUP_T + g_cvKolChgDur.FloatValue;
    g_fKolStuckSince[client]   = 0.0;

    if (g_hKolHitList[client] == null)
        g_hKolHitList[client] = new ArrayList();
    else
        g_hKolHitList[client].Clear();

    // sonido de arranque + stages del windup (GMod timer.Simple;
    // codigo = userid*10 + stage — userids grandes ya no rompen el decode)
    Kolossos_Emit(client, g_bKolSndStartup, "om/kolossos/StartUpCharge.wav",
                  "npc/attack_helicopter/aheli_charge_up.wav");
    CreateTimer(KOL_CHG_WINDUP_SIGH, Kolossos_T_WindupStage, GetClientUserId(client) * 10 + 0);
    CreateTimer(KOL_CHG_WINDUP_RUMBLE, Kolossos_T_WindupStage, GetClientUserId(client) * 10 + 1);
    CreateTimer(KOL_CHG_WINDUP_ROAR, Kolossos_T_WindupStage, GetClientUserId(client) * 10 + 2);

    PrintCenterText(client, "Cargando la avalancha...");
}

// stages del windup: 0=suspiro 1=rumble 2=rugido (codigo = userid*10 + stage)
public Action Kolossos_T_WindupStage(Handle timer, int code)
{
    int stage = code % 10;
    int client = GetClientOfUserId(code / 10);
    if (client < 1 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (g_iKolChargeState[client] != KOL_CHG_WINDUP) return Plugin_Stop;

    switch (stage)
    {
        case 0: Kolossos_Emit(client, g_bKolSndSigh, "om/kolossos/kol sigh i think.wav", "");
        case 1: Kolossos_Emit(client, g_bKolSndRumble, "om/kolossos/kol charge start ground rumble.wav",
                              "ambient/machines/thumper_startup1.wav");
        case 2:
        {
            Kolossos_Emit(client, g_bKolSndRoar, "om/kolossos/KolossosChargeRoar.wav",
                          "npc/attack_helicopter/aheli_alert1.wav");
            // transicion WINDUP -> DASH (la FSM toma el control desde aqui)
            Kolossos_ChargeLaunch(client);
        }
    }
    return Plugin_Stop;
}

// el arranque de la avalancha (receta Metal v5.0: stack + impulso + DEBRIS)
void Kolossos_ChargeLaunch(int client)
{
    g_iKolChargeState[client] = KOL_CHG_DASH;

    // restaurar el lagged del windup y topear la velocidad por el stack
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    Kolossos_DashSpeedSet(client, g_cvKolChgSpeed.FloatValue);

    // DEBRIS: atraviesa cuerpos durante la avalancha (como el mod)
    if (g_iKolSavedColGroup[client] == -1)
    {
        g_iKolSavedColGroup[client] = GetEntProp(client, Prop_Data, "m_CollisionGroup");
        SetEntProp(client, Prop_Data, "m_CollisionGroup", KOL_CHG_COLGROUP);
    }

    // impulso de arranque (el tope ya alzado clampea el motor)
    float dir[3], vel[3];
    Kolossos_GetMoveDir(client, dir);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[0] = dir[0] * (KOL_CHG_LAUNCH_MIN < g_cvKolChgSpeed.FloatValue ? g_cvKolChgSpeed.FloatValue : KOL_CHG_LAUNCH_MIN);
    vel[1] = dir[1] * (KOL_CHG_LAUNCH_MIN < g_cvKolChgSpeed.FloatValue ? g_cvKolChgSpeed.FloatValue : KOL_CHG_LAUNCH_MIN);
    if (GetEntityFlags(client) & FL_ONGROUND)
        vel[2] = 0.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    // camara de velocidad (receta Metal)
    SetEntProp(client, Prop_Send, "m_iFOV", KOL_CHG_FOV);
    SetEntProp(client, Prop_Send, "m_iFOVStart", KOL_CHG_FOV);

    PrintCenterText(client, "AVALANCHA!");
}

// tope de velocidad via el stack del Speed_sonic (receta Metal_DashSpeedSet)
void Kolossos_DashSpeedSet(int client, float target)
{
    float base = Speed_GetBaseSpeed(client);
    if (base < 50.0) base = 220.0;
    float extra = target / base - 1.0;
    if (extra < 0.0) extra = 0.0;
    Speed_StackSet(client, SPEED_STACK_KOLOSSOS, extra);
}

// fin de la avalancha: timeout / pared / cancel / muerte
void Kolossos_ChargeEnd(int client, bool hitWall)
{
    if (g_iKolChargeState[client] == KOL_CHG_IDLE) return;

    // lagged del windup si quedo clavado en 0
    if (g_iKolChargeState[client] == KOL_CHG_WINDUP)
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);

    // fuera DEBRIS + slot del stack + frenado suave + FOV
    if (g_iKolSavedColGroup[client] > 0)
        SetEntProp(client, Prop_Data, "m_CollisionGroup", g_iKolSavedColGroup[client]);
    g_iKolSavedColGroup[client] = -1;
    Speed_StackSet(client, SPEED_STACK_KOLOSSOS, 0.0);

    if (IsClientInGame(client) && IsPlayerAlive(client))
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntProp(client, Prop_Send, "m_iFOV", 0);
        SetEntProp(client, Prop_Send, "m_iFOVStart", 0);

        float vel[3], endVel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        endVel[0] = vel[0] * 0.25;
        endVel[1] = vel[1] * 0.25;
        endVel[2] = vel[2];
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, endVel);
    }

    // fling de las victimas vivas de la HitList (el GMod las suelta volando)
    // v1.1: capturar ANTES si habia empalados (FlingHitList vacia la lista)
    bool hadImpaled = (g_hKolHitList[client] != null && g_hKolHitList[client].Length > 0);
    Kolossos_FlingHitList(client, hitWall);

    // tope de pared: slaminwall con empalados (anim 1.3s + Sound.mp3) o
    // el wall bump seco sin ellos (GMod l.1729-1747); CD 3.65s en ambos
    if (hitWall && IsClientInGame(client) && IsPlayerAlive(client))
    {
        if (hadImpaled)
        {
            Kolossos_AnimShot(client, KOL_ST_SLAMINWALL, 1.3, KOL_SHOT_ACT);
            Kolossos_Emit(client, g_bKolSndSlam, "om/kolossos/Sound.mp3",
                          "physics/concrete/concrete_break2.wav");
        }
        else
        {
            Kolossos_Emit(client, g_bKolSndWallBump, "om/kolossos/Kol wall bump.wav",
                          "physics/concrete/concrete_break2.wav");
        }
    }

    g_iKolChargeState[client] = KOL_CHG_IDLE;
}

// las victimas empaladas que siguen vivas salen volando al final
void Kolossos_FlingHitList(int client, bool hitWall)
{
    if (g_hKolHitList[client] == null) return;

    float dir[3];
    Kolossos_GetMoveDir(client, dir);

    // contra la pared: direccion aleatoria (GMod l.1914-1931)
    if (hitWall)
    {
        switch (GetRandomInt(0, 2))
        {
            case 0: { dir[0] = 1.0;  dir[1] = 0.0; }   // derecha
            case 1: { dir[0] = -1.0; dir[1] = 0.0; }   // izquierda
            case 2: { /* sigue de frente */ }
        }
    }

    float push[3];
    push[0] = dir[0] * KOL_CHG_FLING_FWD;
    push[1] = dir[1] * KOL_CHG_FLING_FWD;
    push[2] = KOL_CHG_FLING_UP;

    int n = g_hKolHitList[client].Length;
    for (int i = 0; i < n; i++)
    {
        int ent = EntRefToEntIndex(g_hKolHitList[client].Get(i));
        if (ent <= 0 || !IsValidEntity(ent)) continue;

        if (ent > 0 && ent <= MaxClients)
        {
            if (!IsClientInGame(ent) || !IsPlayerAlive(ent)) continue;
            if (GetClientTeam(ent) != 3) continue;   // solo infectados
            TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
        }
        else
        {
            // commons: empuje fisico del cuerpo (si sigue vivo)
            if (GetEntProp(ent, Prop_Data, "m_iHealth") > 0 && HasEntProp(ent, Prop_Data, "m_vecVelocity"))
                TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
    g_hKolHitList[client].Clear();
}

// el tick del DASH (10 Hz): tope re-afirmado, impacto de empale, watchdog
void Kolossos_ChargeDashThink(int client, float now)
{
    // tope + FOV re-afirmados (auto-cura, receta Metal)
    Kolossos_DashSpeedSet(client, g_cvKolChgSpeed.FloatValue);
    SetEntProp(client, Prop_Send, "m_iFOV", KOL_CHG_FOV);
    SetEntProp(client, Prop_Send, "m_iFOVStart", KOL_CHG_FOV);

    // ---- impacto: esfera frontal, sin repetir victimas (HitList) ----
    // REGLA v3.77.85 (crash silencioso de la horda): el dano NUNCA va
    // dentro del FindEntityByClassname — SNAPSHOT de refs primero, dano
    // DESPUES re-validando (un comun muerto libera su edicto al instante).
    float pos[3], dir[3];
    GetClientAbsOrigin(client, pos);
    Kolossos_GetMoveDir(client, dir);
    pos[0] += dir[0] * 30.0;
    pos[1] += dir[1] * 30.0;
    pos[2] += 40.0;

    float radius = g_cvKolChgRadius.FloatValue;
    float dmg    = g_cvKolChgDmg.FloatValue;
    bool  newVictim = false;

    int   snapEnts[64];
    bool  snapIsSI[64];
    int   snapCount = 0;

    // 1) commons ("infected") — solo SNAPSHOT
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (GetVectorDistance(epos, pos) > radius) continue;
        if (Kolossos_OnHitList(client, ent)) continue;

        Kolossos_HitListAdd(client, ent);
        newVictim = true;
        snapEnts[snapCount] = ent;
        snapIsSI[snapCount] = false;
        snapCount++;
    }

    // 2) infectados especiales (clients team 3) + tank — solo SNAPSHOT
    for (int t = 1; t <= MaxClients && snapCount < 64; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (GetVectorDistance(tpos, pos) > radius) continue;
        if (Kolossos_OnHitList(client, t)) continue;

        Kolossos_HitListAdd(client, t);
        newVictim = true;
        snapEnts[snapCount] = t;
        snapIsSI[snapCount] = true;
        snapCount++;
    }

    // 3) witch (entidad, no client) — solo SNAPSHOT
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(w)) continue;
        if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
        float wpos[3];
        GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
        if (GetVectorDistance(wpos, pos) > radius) continue;
        if (Kolossos_OnHitList(client, w)) continue;

        Kolossos_HitListAdd(client, w);
        newVictim = true;
        snapEnts[snapCount] = w;
        snapIsSI[snapCount] = false;   // witch: dano puro, sin stun
        snapCount++;
    }

    // 4) EL DAÑO VA AQUI — fuera de los bucles, re-validando cada ref
    for (int k = 0; k < snapCount; k++)
    {
        int v = snapEnts[k];
        if (v <= 0 || !IsValidEntity(v)) continue;
        if (snapIsSI[k] && (v <= MaxClients))
        {
            if (!IsClientInGame(v) || !IsPlayerAlive(v)) continue;
            OM_AbilityDamage(v, client, dmg);
            OM_Stun(v, 1.0, client, 0.0, DMG_OM_CLUB, false);   // aturdido 1s
        }
        else if (v > MaxClients)
        {
            if (GetEntProp(v, Prop_Data, "m_iHealth") <= 0) continue;
            OM_AbilityDamage(v, client, dmg);
        }
    }

    if (newVictim)
    {
        Kolossos_Emit(client, g_bKolSndImpacts, "om/kolossos/Kol impacts.wav",
                      "physics/flesh/flesh_impact_hard4.wav");
        if (g_bKolSndLaugh && GetRandomInt(1, 3) == 1)
            EmitSoundToAll("om/kolossos/Kol charge laugh impale.wav", client, _, KOL_SND_LEVEL);

        // extension por victima nueva (GMod ImapleChargeDuration 3.75)
        float newEnd = g_fKolChargeEnd[client] + g_cvKolChgAdd.FloatValue;
        float maxEnd = g_fKolWindupStart[client] + KOL_CHG_WINDUP_T + g_cvKolChgMaxDur.FloatValue;
        if (newEnd > maxEnd) newEnd = maxEnd;
        g_fKolChargeEnd[client] = newEnd;
    }

    // ---- watchdog de atasco / tope de pared (receta Metal_StuckCheck) ----
    if (GetEntityFlags(client) & FL_ONGROUND)
    {
        if (Kolossos_Speed2D(client) < KOL_CHG_STUCK_MINVEL)
        {
            if (g_fKolStuckSince[client] == 0.0)
                g_fKolStuckSince[client] = now;
            else if (now - g_fKolStuckSince[client] >= KOL_CHG_STUCK_TIME)
            {
                Kolossos_ChargeEnd(client, true);   // tope seco
                return;
            }
        }
        else g_fKolStuckSince[client] = 0.0;
    }
    else g_fKolStuckSince[client] = 0.0;

    // ---- fin natural ----
    if (now >= g_fKolChargeEnd[client])
        Kolossos_ChargeEnd(client, false);
}

bool Kolossos_OnHitList(int client, int ent)
{
    if (g_hKolHitList[client] == null) return false;
    return g_hKolHitList[client].FindValue(EntIndexToEntRef(ent)) != -1;
}

void Kolossos_HitListAdd(int client, int ent)
{
    if (g_hKolHitList[client] == null) g_hKolHitList[client] = new ArrayList();
    g_hKolHitList[client].Push(EntIndexToEntRef(ent));
}

// =====================================================================
//  [X] HABILIDAD 2 — GRAB (lunge, agarre en vilo y combo de puos)
//  GMod l.2398-2479 (lunge 0.6s) + l.2041-2072 (esfera 90 -> agarrado,
//  PunchesLeft 3, max 10s) + l.2566-2630 (puos slamDamage 15).
// =====================================================================

void Kolossos_Ability2(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    // X de nuevo durante el agarre = soltar (CanCancelGrab, default off)
    if (g_iKolGrabVictim[client] != 0)
    {
        if (g_cvKolGrabCancel.BoolValue)
        {
            g_iKolGrabPunches[client] = 0;
            Kolossos_GrabRelease(client, true, false);
        }
        else PrintCenterText(client, "Puos: %d (Z)", g_iKolGrabPunches[client]);
        return;
    }

    if (g_iKolChargeState[client] != KOL_CHG_IDLE
        || g_fKolBlockUntil[client] > now
        || g_fKolIndUntil[client] > now
        || g_fKolLungeUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolGrabCdUntil[client])
    {
        PrintCenterText(client, "Grab: %.1fs", g_fKolGrabCdUntil[client] - now);
        return;
    }

    // ---- lunge: ventana de captura + impulso corto hacia delante ----
    g_fKolLungeUntil[client]  = now + g_cvKolGrabWindow.FloatValue;
    g_bKolGrabLunged[client]  = false;

    Kolossos_Emit(client, g_bKolSndGrabLunge, "om/kolossos/kol grab lunge.wav",
                  "ambient/wind/wind_hit1.wav");
    Kolossos_Emit(client, g_bKolSndGrabUse, "om/kolossos/Kol uses grab.wav", "");

    PrintCenterText(client, "Agarre!");
}

// el tick del lunge (10 Hz): impulso + esfera de captura
void Kolossos_GrabLungeThink(int client, float now)
{
    // impulso del lunge: UNA vez, al entrar (GMod velocidad grab 1750
    // durante la ventana — en L4D2: impulso unico + ventana de captura)
    if (!g_bKolGrabLunged[client])
    {
        g_bKolGrabLunged[client] = true;
        float dir[3], vel[3];
        Kolossos_GetMoveDir(client, dir);
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[0] += dir[0] * 400.0;
        vel[1] += dir[1] * 400.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    }

    // esfera frontal de captura (GMod FindInSphere 90u en el pecho)
    float pos[3], dir[3];
    GetClientAbsOrigin(client, pos);
    Kolossos_GetMoveDir(client, dir);
    pos[0] += dir[0] * 40.0;
    pos[1] += dir[1] * 40.0;
    pos[2] += 40.0;

    float radius = g_cvKolChgRadius.FloatValue;

    // v1.4 — ESPECIALES PRIMERO (reporte del owner: "No agarra a
    // especiales (al tank no lo agarra. tampoco)"). En la v1.0-1.3 los
    // commons se chequeaban primero con return: cualquier comun en la
    // esfera se robaba el agarre y el TANK estaba explicitamente vetado
    // ("demasiado grande para el puño") — el unico especial que SE ACERCA
    // era inagarrable. Ahora: [1] SI+TANK (clientes team 3, el mas
    // cercano), [2] commons, [3] witch (via movetype, como los commons)
    int bestSI = 0;
    float bestSIDist = radius;
    for (int t = 1; t <= MaxClients; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        // v1.4: el tank entra por convar (el veto de la v1.0 fuera)
        if (GetEntProp(t, Prop_Send, "m_zombieClass") == 8
            && !g_cvKolGrabTank.BoolValue) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        float d = GetVectorDistance(tpos, pos);
        if (d > bestSIDist) continue;
        bestSI = t;
        bestSIDist = d;
    }
    if (bestSI != 0)
    {
        Kolossos_GrabBegin(client, bestSI);
        return;
    }

    // commons (GMod: cualquier player/NPC/NextBot) — el MAS CERCANO
    int bestCm = 0;
    float bestCmDist = radius;
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        float d = GetVectorDistance(epos, pos);
        if (d > bestCmDist) continue;
        bestCm = ent;
        bestCmDist = d;
    }
    if (bestCm != 0)
    {
        Kolossos_GrabBegin(client, bestCm);
        return;
    }

    // v1.4: la WITCH (convar) — entidad como los commons: congelada por
    // movetype, en vilo por la FSM, y los puños le pegan igual
    if (g_cvKolGrabWitch.BoolValue)
    {
        int w = -1;
        int bestW = 0;
        float bestWDist = radius;
        while ((w = FindEntityByClassname(w, "witch")) != -1)
        {
            if (!IsValidEntity(w)) continue;
            if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
            float wpos[3];
            GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
            float d = GetVectorDistance(wpos, pos);
            if (d > bestWDist) continue;
            bestW = w;
            bestWDist = d;
        }
        if (bestW != 0)
        {
            Kolossos_GrabBegin(client, bestW);
            return;
        }
    }

    // ventana agotada sin nadie: CD completo (GMod l.2179)
    if (now >= g_fKolLungeUntil[client])
    {
        g_fKolLungeUntil[client] = 0.0;
        g_fKolGrabCdUntil[client] = now + g_cvKolGrabCd.FloatValue;
    }
}

// la victima queda en vilo delante del coloso
void Kolossos_GrabBegin(int client, int victim)
{
    g_fKolLungeUntil[client] = 0.0;
    g_iKolGrabVictim[client] = EntIndexToEntRef(victim);
    g_iKolGrabPunches[client] = g_cvKolGrabPunches.IntValue;
    g_fKolGrabHoldEnd[client] = GetEngineTime() + g_cvKolGrabHold.FloatValue;

    // congelar a la victima: commons por movetype, SI por OM_Stun
    if (victim > 0 && victim <= MaxClients)
    {
        float stunDur = g_cvKolGrabHold.FloatValue + 1.0;
        OM_Stun(victim, stunDur, client, 0.0, DMG_OM_CLUB, false);
    }
    else
    {
        g_iKolGrabMoveType[client] = GetEntProp(victim, Prop_Data, "movetype");
        SetEntProp(victim, Prop_Data, "movetype", MOVETYPE_NONE);
    }

    Kolossos_Emit(client, g_bKolSndImpale, "om/kolossos/Kol impales.wav",
                  "physics/flesh/flesh_break3.wav");

    // v1.4: la POSE de sujetar (GrabIdle = el ACT_HOVER del GMod) vive en
    // la CAPA 1 desde el enganche — brazos sujetando mientras el main
    // sigue en locomocion (piernas andando, el sistema del owner)
    Kolossos_LayerHold(client, true);

    // v1.3: el REACH — la serie del grab arranca con el enganche (el
    // "Grab" 31f de los SMD; en GMod el reach es el gesture del lunge
    // MELEE_ATTACK1, pero aca el lunge va a 3x con las piernas vivas:
    // el lugar monocapa natural del reach es JUSTO al enganchar)
    // v1.4: por CAPAS — brazos del reach sobre las piernas corriendo;
    // si no hay capas cae al one-shot monocapa de la v1.3
    Kolossos_GrabShot(client, KOL_ST_GRABREACH,
                      Kolossos_ShotDur(KOL_ST_GRABREACH, KOL_DUR_GRABREACH),
                      KOL_SHOT_GRAB);

    PrintCenterText(client, "Agarrado! Puos restantes: %d (Z)", g_iKolGrabPunches[client]);
}

// el tick del agarre: victima en vilo delante + validacion + timeout
void Kolossos_GrabHoldThink(int client, float now)
{
    int victim = EntRefToEntIndex(g_iKolGrabVictim[client]);
    bool dead = false;

    if (victim <= 0 || !IsValidEntity(victim))
        dead = true;
    else if (victim <= MaxClients)
    {
        if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) dead = true;
    }
    else if (GetEntProp(victim, Prop_Data, "m_iHealth") <= 0) dead = true;

    if (dead)
    {
        // la victima murio sola: CD corto (GMod l.2026: grab_cd +2)
        Kolossos_GrabRelease(client, false, true);
        return;
    }

    // en vilo delante del coloso (GMod: ragdoll pegado a la mano derecha)
    float pos[3], dir[3];
    GetClientAbsOrigin(client, pos);
    Kolossos_GetMoveDir(client, dir);
    pos[0] += dir[0] * KOL_GRAB_HOLD_DIST;
    pos[1] += dir[1] * KOL_GRAB_HOLD_DIST;
    pos[2] += KOL_GRAB_HOLD_Z;
    TeleportEntity(victim, pos, NULL_VECTOR, NULL_VECTOR);

    // v1.3: lanzamiento encadenado tras el 3er puo (GMod l.2617-2623:
    // duration+1.75 — el throw sale DESPUES de la anim del puo, no
    // instantaneo)
    if (g_fKolGrabThrowAt[client] > 0.0 && now >= g_fKolGrabThrowAt[client])
    {
        g_fKolGrabThrowAt[client] = 0.0;
        Kolossos_GrabRelease(client, true, false);
        return;
    }

    // timeout del agarre (max 10s)
    if (now >= g_fKolGrabHoldEnd[client])
        Kolossos_GrabRelease(client, true, false);
}

// Z durante el agarre: puo (GMod l.2566-2630)
// v1.1: si el puo MATA a la victima -> la EJECUCION del GMod (l.1137-
// 1142): PillAnim("Kill") por la duracion de la secuencia (1.65s en el
// registro) + la risa "Kolossos laughing" un segundo despues (l.1220-1228)
void Kolossos_GrabPunch(int client)
{
    int victim = EntRefToEntIndex(g_iKolGrabVictim[client]);
    if (victim <= 0 || !IsValidEntity(victim)) return;

    float now = GetEngineTime();

    Kolossos_Emit(client, g_bKolSndPunch, "om/kolossos/kolossos punching.wav",
                  "physics/flesh/flesh_impact_hard3.wav");

    OM_AbilityDamage(victim, client, g_cvKolGrabPunchDmg.FloatValue);

    // ?murio con ese puo? (SI: cliente muerto / comun sin vida)
    bool killed = false;
    if (victim <= MaxClients)
        killed = (!IsClientInGame(victim) || !IsPlayerAlive(victim));
    else
        killed = (!IsValidEntity(victim) || GetEntProp(victim, Prop_Data, "m_iHealth") <= 0);

    if (killed)
    {
        // v1.3: la ejecucion ahora es prioridad MAXIMA (nadie la corta)
        Kolossos_AnimShot(client, KOL_ST_KILL, 1.65, KOL_SHOT_MAX);
        if (g_bKolSndLaughKill)
            CreateTimer(1.0, Kolossos_T_KillLaugh, GetClientUserId(client));

        // v1.3: ejecucion pura — sin lanzamiento (el Kill ES el payoff)
        g_iKolGrabPunches[client] = 0;
        Kolossos_GrabRelease(client, false, true);
        return;
    }

    // v1.3: el puo tiene su animacion (el gesture MELEE_ATTACK2 del GMod
    // = GrabPunch 51f de los SMD) — prioridad GRAB: la locomocion no la
    // corta, solo el lanzamiento/ejecucion
    // v1.4: por CAPAS — el puo va en la capa 2 sobre la pose de sujetar
    // (capa 1) y las piernas siguen en el main (walk si te mueves)
    Kolossos_GrabShot(client, KOL_ST_GRABPUNCH,
                      Kolossos_ShotDur(KOL_ST_GRABPUNCH, KOL_DUR_GRABPUNCH),
                      KOL_SHOT_GRAB);

    g_iKolGrabPunches[client]--;
    if (g_iKolGrabPunches[client] <= 0)
    {
        // v1.3: combo completo ENCADENADO (GMod l.2617-2623: al 3er puo
        // duration+1.75): el lanzamiento sale cuando la anim del puo
        // TERMINA — cada anim dura lo que debe durar
        float punchDur = Kolossos_ShotDur(KOL_ST_GRABPUNCH, KOL_DUR_GRABPUNCH);
        g_fKolGrabThrowAt[client] = now + punchDur + 0.1;
        g_fKolGrabHoldEnd[client] = now + punchDur + 1.0;
        PrintCenterText(client, "TERCER PUO — lanzamiento!");
    }
    else
    {
        PrintCenterText(client, "Puo! Quedan %d", g_iKolGrabPunches[client]);
    }
}

// v1.1: la risa de la ejecucion (GMod l.1220-1228: laughing 1s tras el Kill)
public Action Kolossos_T_KillLaugh(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (!Kolossos_PlayerIs(client)) return Plugin_Stop;
    if (g_sKolLaughPath[0] != '\0')
        EmitSoundToAll(g_sKolLaughPath, client, _, KOL_SND_LEVEL);
    return Plugin_Stop;
}

// v1.3: LA VICTIMA VUELA A +0.3s DEL ARRANQUE DE LA ANIM (GMod
// l.2154: timer.Simple(0.3) -> phys:SetVelocityInstantaneous(fwd*700))
// — el brazo empuja al frente cuando la anim llega al envion
public Action Kolossos_T_GrabFling(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (!Kolossos_PlayerIs(client)) return Plugin_Stop;

    int victim = EntRefToEntIndex(g_iKolGrabFlingRef[client]);
    g_iKolGrabFlingRef[client] = 0;
    if (victim <= 0 || !IsValidEntity(victim)) return Plugin_Stop;

    float dir[3], push[3];
    Kolossos_GetMoveDir(client, dir);
    push[0] = dir[0] * KOL_GRAB_FLING_FWD;
    push[1] = dir[1] * KOL_GRAB_FLING_FWD;
    push[2] = KOL_GRAB_FLING_UP;
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, push);
    return Plugin_Stop;
}

// soltar: fling opcional + restaurar a la victima + CD
void Kolossos_GrabRelease(int client, bool fling, bool victimDied)
{
    int victim = EntRefToEntIndex(g_iKolGrabVictim[client]);
    g_iKolGrabVictim[client] = 0;
    g_fKolGrabThrowAt[client] = 0.0;    // v1.3: sin lanzamiento pendiente
    g_iKolGrabFlingRef[client] = 0;     // v1.3: anula un fling demorado previo

    // v1.4: la pose de sujetar se apaga SIEMPRE al soltar (con o sin
    // lanzamiento — el ACT_HOVER del GMod se remueve al liberar)
    Kolossos_LayerHold(client, false);

    if (victim > 0 && IsValidEntity(victim))
    {
        // restaurar movimiento
        if (victim <= MaxClients)
        {
            if (IsClientInGame(victim)) OM_Stun_Clear(victim);
        }
        else if (g_iKolGrabMoveType[client] > 0)
        {
            SetEntProp(victim, Prop_Data, "movetype", g_iKolGrabMoveType[client]);
        }

        // v1.3: EL LANZAMIENTO — la anim PRIORITARIA de duracion COMPLETA
        // (en GMod era el gesture ACT_DISARM cortado a 0.9s con fade; aca
        // manda sobre todo: KOL_SHOT_MAX nadie la corta y la duracion la
        // midio el calibrador contra el .mdl real) + la victima vuela a
        // +0.3s del arranque (GMod l.2154)
        // v1.4: por CAPAS — el lanzamiento viaja en la capa 2 su ciclo
        // COMPLETO (0->1.0: nadie lo corta) con las piernas en el main
        if (fling && IsClientInGame(client) && IsPlayerAlive(client))
        {
            Kolossos_GrabShot(client, KOL_ST_GRABTHROW,
                              Kolossos_ShotDur(KOL_ST_GRABTHROW, KOL_DUR_GRABTHROW),
                              KOL_SHOT_MAX);
            g_iKolGrabFlingRef[client] = EntIndexToEntRef(victim);
            CreateTimer(KOL_GRAB_FLING_DELAY, Kolossos_T_GrabFling, GetClientUserId(client));

            Kolossos_Emit(client, g_bKolSndPullOut, "om/kolossos/kol sting and pull out.wav",
                          "physics/flesh/flesh_impact_bullet1.wav");
        }
    }

    g_iKolGrabMoveType[client] = -1;

    float now = GetEngineTime();
    if (victimDied)
        g_fKolGrabCdUntil[client] = now + 2.0;                       // GMod: murio sola
    else
        g_fKolGrabCdUntil[client] = now + g_cvKolGrabCd.FloatValue;  // CD completo
}

// =====================================================================
//  [C] HABILIDAD 3 — INDICATOR (el peek: glow rojo sobre los infectados)
//  GMod l.458-549: durante IndicatorDuration todos los players/NPCs en
//  rango llevan el border indicator + pings; susurro al activar.
//  L4D2: sprites glow01 rojos sobre la cabeza, refresco a 10 Hz.
// =====================================================================

void Kolossos_Ability3(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    if (g_iKolChargeState[client] != KOL_CHG_IDLE
        || g_iKolGrabVictim[client] != 0
        || g_fKolLungeUntil[client] > now
        || g_fKolBlockUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolIndCdUntil[client])
    {
        PrintCenterText(client, "Indicator: %.1fs", g_fKolIndCdUntil[client] - now);
        return;
    }

    g_fKolIndUntil[client]    = now + g_cvKolIndDur.FloatValue;
    g_fKolIndCdUntil[client]  = now + g_cvKolIndCd.FloatValue;
    g_fKolIndNextPing[client] = now;

    // susurro del coloso (solo el jugador lo oye, como el GMod client-side)
    if (g_bKolSndWhisper)
        EmitSoundToClient(client, "om/kolossos/kol whispers.wav", client, _, KOL_SND_LEVEL);

    PrintCenterText(client, "INDICATOR!");
}

// el tick del indicator: mantener la nube de sprites sobre los vivos
void Kolossos_IndicatorThink(int client, float now)
{
    float pos[3];
    GetClientAbsOrigin(client, pos);
    float radius = g_cvKolIndRadius.FloatValue;

    // marcar quienes estan en rango (bitmap de este tick)
    static bool inRange[KOL_MAXENT + 1];
    for (int e = 1; e <= KOL_MAXENT; e++) inRange[e] = false;

    // 1) infectados especiales
    for (int t = 1; t <= MaxClients; t++)
    {
        if (!IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (radius > 0.0 && GetVectorDistance(tpos, pos) > radius) continue;
        inRange[t] = true;
    }

    // 2) commons
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (ent > KOL_MAXENT) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (radius > 0.0 && GetVectorDistance(epos, pos) > radius) continue;
        inRange[ent] = true;
    }

    // 3) witch
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (!IsValidEntity(w)) continue;
        if (w > KOL_MAXENT) continue;
        if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
        float wpos[3];
        GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
        if (radius > 0.0 && GetVectorDistance(wpos, pos) > radius) continue;
        inRange[w] = true;
    }

    // mantener la nube: crear/mover los que estan, matar los que salieron
    for (int e = 1; e <= KOL_MAXENT; e++)
    {
        if (!inRange[e])
        {
            if (g_iKolIndSprite[e] != 0)
            {
                int sp = EntRefToEntIndex(g_iKolIndSprite[e]);
                if (sp > 0 && IsValidEntity(sp)) AcceptEntityInput(sp, "Kill");
                g_iKolIndSprite[e] = 0;
            }
            continue;
        }

        float head[3];
        if (e <= MaxClients)
        {
            if (!IsClientInGame(e) || !IsPlayerAlive(e)) continue;
            GetClientAbsOrigin(e, head);
            head[2] += 72.0;
        }
        else
        {
            GetEntPropVector(e, Prop_Data, "m_vecOrigin", head);
            head[2] += 64.0;
        }

        int sp = EntRefToEntIndex(g_iKolIndSprite[e]);
        if (g_iKolIndSprite[e] != 0 && (sp <= 0 || !IsValidEntity(sp)))
        {
            g_iKolIndSprite[e] = 0;
            sp = -1;
        }

        if (sp <= 0)
            g_iKolIndSprite[e] = Kolossos_SpawnIndSprite(head);
        else
            SetEntPropVector(sp, Prop_Data, "m_vecOrigin", head);
    }

    // heartbeat del ping (cada 1s, solo para el coloso)
    if (now >= g_fKolIndNextPing[client])
    {
        g_fKolIndNextPing[client] = now + KOL_IND_PING_EVERY;
        if (g_bKolSndPing) EmitSoundToClient(client, "om/metal/ping1.wav", client, _, 60);
        else EmitSoundToClient(client, "buttons/button17.wav", client, _, 60);
    }
}

int Kolossos_SpawnIndSprite(const float pos[3])
{
    // glow01: sprite nativo (cero dependencia de assets del mod)
    int sp = CreateEntityByName("env_sprite");
    if (sp <= 0 || !IsValidEntity(sp)) return 0;

    DispatchKeyValue(sp, "model", "sprites/glow01.vmt");
    DispatchKeyValue(sp, "rendercolor", "255 32 32");
    DispatchKeyValue(sp, "rendermode", "5");      // additive
    DispatchKeyValue(sp, "renderamt", "255");
    DispatchKeyValue(sp, "scale", "0.6");
    DispatchKeyValue(sp, "GlowProxySize", "16");
    DispatchSpawn(sp);

    TeleportEntity(sp, pos, NULL_VECTOR, NULL_VECTOR);
    return EntIndexToEntRef(sp);
}

// fin del indicator: barrido completo de la nube
void Kolossos_IndicatorStop()
{
    for (int e = 1; e <= KOL_MAXENT; e++)
    {
        if (g_iKolIndSprite[e] == 0) continue;
        int sp = EntRefToEntIndex(g_iKolIndSprite[e]);
        if (sp > 0 && IsValidEntity(sp)) AcceptEntityInput(sp, "Kill");
        g_iKolIndSprite[e] = 0;
    }
}

void Kolossos_KillAllIndSprites() { Kolossos_IndicatorStop(); }

// =====================================================================
//  [B] HABILIDAD 4 — BLOCK (el parry del coloso + contragolpe de roca)
//  GMod l.2500-2536 (activacion: inmune + sin moverse 3.5s) + l.1253-
//  1271 (dano a 0 mientras bloquea) + l.1274+ (OM_AfterStunBlock: el
//  bloqueo se CONSUME con el golpe, gira al atacante y le devuelve
//  la roca rockgranite03b scale 3 en arco).
// =====================================================================

void Kolossos_Ability4(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    if (g_iKolChargeState[client] != KOL_CHG_IDLE
        || g_iKolGrabVictim[client] != 0
        || g_fKolLungeUntil[client] > now
        || g_fKolIndUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolBlockCdUntil[client])
    {
        PrintCenterText(client, "Block: %.1fs", g_fKolBlockCdUntil[client] - now);
        return;
    }

    float dur = g_cvKolBlockDur.FloatValue;
    g_fKolBlockUntil[client]     = now + dur;
    g_fKolBlockCdUntil[client]   = now + g_cvKolBlockCd.FloatValue;
    g_bKolBlockCountered[client] = false;

    // v1.1: anim de arranque del bloqueo (GMod l.2520: PillAnim(BlockStart))
    // — la FSM sostiene BlockPos durante toda la ventana
    Kolossos_AnimShot(client, KOL_ST_BLOCKSTART, 0.5, KOL_SHOT_ACT);

    // planta los pies (GMod: OM_NoMovement durante el bloqueo)
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);

    Kolossos_Emit(client, g_bKolSndBlock, "om/kolossos/kol block.wav",
                  "physics/metal/metal_solid_impact_bullet4.wav");

    PrintCenterText(client, "BLOQUEO!");
}

// fin del bloqueo (consumido por el counter o expirado)
void Kolossos_BlockEnd(int client)
{
    if (g_fKolBlockUntil[client] == 0.0) return;
    g_fKolBlockUntil[client] = 0.0;

    if (IsClientInGame(client) && IsPlayerAlive(client))
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
}

// el contragolpe: gira al atacante y devuelve la ROCA en arco
// v1.1: la anim del counter segun la distancia del atacante (GMod
// l.1347-1355: <300u = BlackCounterMelee cuerpo a cuerpo / si no =
// BlockProjectile a distancia, l.1438-1443)
void Kolossos_BlockCounter(int client, int attacker)
{
    g_bKolBlockCountered[client] = true;

    if (!IsClientInGame(attacker) || !IsPlayerAlive(client)) return;

    // girar hacia el atacante (GMod l.1306-1309: angulo asignado)
    float apos[3], mpos[3], ang[3];
    GetClientAbsOrigin(attacker, apos);
    GetClientAbsOrigin(client, mpos);
    ang[0] = 0.0;
    ang[1] = RadToDeg(ArcTangent2(apos[1] - mpos[1], apos[0] - mpos[0]));
    ang[2] = 0.0;
    TeleportEntity(client, NULL_VECTOR, ang, NULL_VECTOR);

    // la anim del contragolpe segun distancia (GMod l.1347)
    bool meleeRange = (GetVectorDistance(apos, mpos) < 300.0);
    Kolossos_AnimShot(client, meleeRange ? KOL_ST_COUNTER : KOL_ST_BLOCKPROJ, 1.0, KOL_SHOT_ACT);

    Kolossos_SpawnCounterRock(client, apos);
}

// la roca: prop_physics con velocidad balistica (travelTime 0.5, peak 150)
void Kolossos_SpawnCounterRock(int client, const float targetPos[3])
{
    if (!g_bKolRockModel)
    {
        // sin la roca nativa: dano directo al atacante (fallback honesto)
        return;
    }

    int rock = CreateEntityByName("prop_physics_override");
    if (rock <= 0 || !IsValidEntity(rock)) return;

    char scaleStr[8];
    FloatToString(g_cvKolRockScale.FloatValue, scaleStr, sizeof(scaleStr));

    DispatchKeyValue(rock, "model", "models/props_wasteland/rockgranite03b.mdl");
    DispatchKeyValue(rock, "targetname", "kolossos_rock_om");
    DispatchKeyValue(rock, "modelscale", scaleStr);
    DispatchSpawn(rock);

    // origen: a los pies del coloso (GMod l.1461: GetPos() - 30z)
    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] -= 30.0;
    TeleportEntity(rock, pos, NULL_VECTOR, NULL_VECTOR);

    // velocidad balistica: t=0.5s, gravedad 800 (GMod travelTime/peakHeight)
    float t = KOL_ROCK_ARC_TIME;
    float g = 800.0;
    float dz = (targetPos[2] + 20.0) - pos[2] + KOL_ROCK_ARC_PEAK;
    float vel[3];
    vel[0] = (targetPos[0] - pos[0]) / t;
    vel[1] = (targetPos[1] - pos[1]) / t;
    vel[2] = dz / t + 0.5 * g * t;
    TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, vel);

    // al tocar: dano en area alrededor del punto de impacto
    SDKHook(rock, SDKHook_StartTouch, Kolossos_RockTouch);

    // watchdog: si no toco nada en 3s, muere sola
    CreateTimer(KOL_ROCK_LIFETIME, Kolossos_T_RockKill, EntIndexToEntRef(rock));

    Kolossos_Emit(client, g_bKolSndRumble, "om/kolossos/kol charge start ground rumble.wav",
                  "ambient/machines/thumper_hit.wav");
}

// impacto de la roca: dano en radio a lo que este cerca
// (REGLA v3.77.85: SNAPSHOT primero, dano fuera de los bucles)
public void Kolossos_RockTouch(int rock, int other)
{
    float pos[3];
    GetEntPropVector(rock, Prop_Data, "m_vecOrigin", pos);
    float dmg = g_cvKolRockDmg.FloatValue;

    // buscar al Kolossos dueno de la roca (por targetname es suya toda)
    int owner = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (Kolossos_PlayerIs(i)) { owner = i; break; }
    }

    int   snapEnts[64];
    bool  snapIsSI[64];
    int   snapCount = 0;

    // commons — snapshot
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(ent) || ent == other) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (GetVectorDistance(epos, pos) > KOL_ROCK_TOUCH_RADIUS) continue;
        snapEnts[snapCount] = ent;
        snapIsSI[snapCount] = false;
        snapCount++;
    }

    // infectados especiales — snapshot
    for (int t = 1; t <= MaxClients && snapCount < 64; t++)
    {
        if (t == owner || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (GetVectorDistance(tpos, pos) > KOL_ROCK_TOUCH_RADIUS) continue;
        snapEnts[snapCount] = t;
        snapIsSI[snapCount] = true;
        snapCount++;
    }

    // witch — snapshot
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(w)) continue;
        if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
        float wpos[3];
        GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
        if (GetVectorDistance(wpos, pos) > KOL_ROCK_TOUCH_RADIUS) continue;
        snapEnts[snapCount] = w;
        snapIsSI[snapCount] = false;
        snapCount++;
    }

    // EL DAÑO VA AQUI — fuera de los bucles, re-validando
    for (int k = 0; k < snapCount; k++)
    {
        int v = snapEnts[k];
        if (v <= 0 || !IsValidEntity(v)) continue;
        if (snapIsSI[k] && v <= MaxClients)
        {
            if (!IsClientInGame(v) || !IsPlayerAlive(v)) continue;
        }
        else if (v > MaxClients)
        {
            if (GetEntProp(v, Prop_Data, "m_iHealth") <= 0) continue;
        }
        SDKHooks_TakeDamage(v, owner, owner, dmg, DMG_CLUB);
    }

    AcceptEntityInput(rock, "Kill");
}

public Action Kolossos_T_RockKill(Handle timer, int ref)
{
    int rock = EntRefToEntIndex(ref);
    if (rock > 0 && IsValidEntity(rock))
    {
        SDKUnhook(rock, SDKHook_StartTouch, Kolossos_RockTouch);
        AcceptEntityInput(rock, "Kill");
    }
    return Plugin_Stop;
}

// =====================================================================
//  DAÑO ENTRANTE: resistencia pasiva + inmunidad del bloqueo + counter
// =====================================================================

public Action Kolossos_OnTakeDamage(int victim, int &attacker, int &inflictor,
                                    float &damage, int &damagetype, int &weapon,
                                    float damageForce[3], float damagePosition[3],
                                    int damagecustom)
{
    if (!Kolossos_PlayerIs(victim)) return Plugin_Continue;

    // ---- bloqueo activo: dano de infectados a CERO (GMod l.1256-1261) ----
    if (g_fKolBlockUntil[victim] > GetEngineTime())
    {
        bool infectedAttacker = false;
        if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
            infectedAttacker = (GetClientTeam(attacker) == 3);
        else if (attacker > MaxClients && IsValidEntity(attacker))
        {
            char cls[16];
            GetEntityClassname(attacker, cls, sizeof(cls));
            infectedAttacker = (StrEqual(cls, "infected") || StrEqual(cls, "witch"));
        }

        if (infectedAttacker)
        {
            damage = 0.0;

            // el PRIMER golpe consuma el bloqueo y dispara el counter
            if (!g_bKolBlockCountered[victim] && attacker > 0)
            {
                Kolossos_BlockEnd(victim);
                Kolossos_BlockCounter(victim, attacker);
            }
            return Plugin_Changed;
        }
    }

    // ---- resistencia pasiva (kolossos_resistance 100 = neutro) ----
    float resist = g_cvKolResist.FloatValue;
    if (resist < 99.5 && resist > 0.0)
    {
        damage *= resist / 100.0;
        return Plugin_Changed;
    }

    return Plugin_Continue;
}

// =====================================================================
//  RUNCMD: auto-forward de la avalancha (receta Metal v5.0)
// =====================================================================

public bool Kolossos_OnPlayerRunCmd(int client, int &buttons, float vel[3])
{
    if (!Kolossos_PlayerIs(client)) return false;
    if (!IsPlayerAlive(client)) return false;

    // durante el WINDUP: clavado en el sitio
    if (g_iKolChargeState[client] == KOL_CHG_WINDUP)
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);
        return false;
    }

    if (g_iKolChargeState[client] != KOL_CHG_DASH) return false;

    // forwardmove saturado (el engine clampea al m_flMaxspeed del stack)
    vel[0] = KOL_DASH_VEL_INJECT;
    vel[1] = 0.0;
    if (vel[2] < 0.0) vel[2] = 0.0;
    return true;
}

// =====================================================================
//  FSM CENTRAL (10 Hz — patron T_BlazeAvatarThink)
// =====================================================================

public Action T_KolossosThink(Handle timer)
{
    float now = GetEngineTime();

    // el indicator es global (una sola nube a la vez por simplicidad):
    // buscar al Kolossos que lo tiene activo
    int indOwner = 0;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Kolossos_KillAvatar(i); continue; }

        bool esKolViva = (Kolossos_PlayerIs(i) && IsPlayerAlive(i)
                          && GetClientTeam(i) == 2);

        // incap = cancel suave (la FSM re-monta al levantarse)
        if (esKolViva && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            esKolViva = false;

        // ---- EL TICK DEL KIT ----
        if (esKolViva)
        {
            if (OM_IsStunned(i))
            {
                // aturdido: cancelar todo (no pelear contra el stun)
                if (g_iKolChargeState[i] != KOL_CHG_IDLE) Kolossos_ChargeEnd(i, false);
                if (g_iKolGrabVictim[i] != 0) Kolossos_GrabRelease(i, false, false);
                if (g_fKolBlockUntil[i] > 0.0) Kolossos_BlockEnd(i);
            }
            else
            {
                // auto-gestion: hook de dano + vida max UNA vez por vida
                // (cubre tambien la eleccion a mitad de ronda via menu)
                if (!g_bKolHooked[i])
                {
                    g_bKolHooked[i] = true;
                    SDKUnhook(i, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
                    SDKHook(i, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
                }
                if (!g_bKolHpApplied[i])
                {
                    g_bKolHpApplied[i] = true;
                    Kolossos_ApplyMaxHealth(i);
                }

                // charge: windup (lagged 0) / dash (impacto + watchdog)
                if (g_iKolChargeState[i] == KOL_CHG_DASH)
                    Kolossos_ChargeDashThink(i, now);
                else if (g_iKolChargeState[i] == KOL_CHG_WINDUP
                         && now >= g_fKolWindupStart[i] + KOL_CHG_WINDUP_T)
                {
                    // safety: los timers del windup se perdieron (mapchange)
                    Kolossos_ChargeLaunch(i);
                }

                // grab: ventana del lunge / victima en vilo
                if (g_fKolLungeUntil[i] > now)
                    Kolossos_GrabLungeThink(i, now);
                else if (g_iKolGrabVictim[i] != 0)
                    Kolossos_GrabHoldThink(i, now);

                // block: expiracion natural
                if (g_fKolBlockUntil[i] > 0.0 && now >= g_fKolBlockUntil[i])
                    Kolossos_BlockEnd(i);

                // indicator
                if (g_fKolIndUntil[i] > now) indOwner = i;
            }
        }
        else
        {
            // no es Kolossos vivo: limpiar estado si quedo algo
            if (g_iKolChargeState[i] != KOL_CHG_IDLE) Kolossos_ChargeEnd(i, false);
            if (g_iKolGrabVictim[i] != 0) Kolossos_GrabRelease(i, false, false);
            if (g_fKolBlockUntil[i] > 0.0) Kolossos_BlockEnd(i);
            if (g_fKolIndUntil[i] > 0.0)   g_fKolIndUntil[i] = 0.0;
        }

        // ---- montaje del avatar ----
        if (g_iKolAvatar[i] == 0)
        {
            if (esKolViva && g_cvKolAvatar != null && g_cvKolAvatar.BoolValue
                && g_bKolModelOK)
            {
                Kolossos_CreateAvatar(i);
            }
            continue;
        }

        if (!esKolViva)
        {
            Kolossos_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iKolAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iKolAvatar[i] = 0;
            g_iKolAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (fix Tails v5.4)
        if (g_iKolBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparacion de la copia L
        if (g_iKolAvatarL[i] == 0 && g_iKolAvatar[i] != 0)
        {
            Kolossos_CreateAvatarL(i);
            if (g_iKolAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // FSM de animacion
        av = EntRefToEntIndex(g_iKolAvatar[i]);
        if (g_iKolAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Kolossos_AvatarUpdate(i, av, now);
    }

    // la nube del indicator vive mientras su dueno la tenga activa
    if (indOwner != 0)
        Kolossos_IndicatorThink(indOwner, now);
    else
        Kolossos_IndicatorStop();

    return Plugin_Continue;
}

// =====================================================================
//  DEBUG
// =====================================================================

public Action Kolossos_CmdDebug(int client, int args)
{
    client = Sonic_SoloClient(client);
    if (!IsValidClient(client)) return Plugin_Handled;

    float now = GetEngineTime();
    PrintToConsole(client, "=== Kolossos v%s ===", KOLOSSOS_INC_VERSION);
    PrintToConsole(client, "Personaje: %s | Vida: %d/%d",
                   Kolossos_PlayerIs(client) ? "SI" : "NO",
                   GetClientHealth(client),
                   GetEntProp(client, Prop_Data, "m_iMaxHealth"));
    PrintToConsole(client, "Modelo: %s | Avatar R: %s | L: %s",
                   g_bKolModelOK ? "OK" : "FALTA",
                   g_iKolAvatar[client] != 0 ? "vivo" : "-",
                   g_iKolAvatarL[client] != 0 ? "vivo" : "-");
    PrintToConsole(client, "Charge: estado %d | fin %.1f | CD %.1f",
                   g_iKolChargeState[client],
                   g_fKolChargeEnd[client] - now,
                   g_fKolChargeCdUntil[client] - now);
    PrintToConsole(client, "Grab: victima %d | puos %d | lunge %.1f | CD %.1f",
                   g_iKolGrabVictim[client] != 0 ? EntRefToEntIndex(g_iKolGrabVictim[client]) : -1,
                   g_iKolGrabPunches[client],
                   g_fKolLungeUntil[client] - now,
                   g_fKolGrabCdUntil[client] - now);
    PrintToConsole(client, "Block: %.1f | Indicator: %.1f",
                   g_fKolBlockUntil[client] - now,
                   g_fKolIndUntil[client] - now);
    // v1.1: la FSM de animacion al dia (estado + one-shot activo)
    char seqNow[24];
    Kolossos_SeqFor(g_iKolAnimState[client] >= 0 ? g_iKolAnimState[client] : 0, seqNow, sizeof(seqNow));
    PrintToConsole(client, "Anim: estado %d (%s) | one-shot %s (prio %d)",
                   g_iKolAnimState[client], seqNow,
                   (g_iKolAnimShotState[client] >= 0 && now < g_fKolAnimShotUntil[client])
                       ? g_sKolSeqName[g_iKolAnimShotState[client]] : "-",
                   g_iKolAnimShotTier[client]);
    // v1.4: el estado del MOTOR DE CAPAS — si el avatar del prop
    // networka m_AnimOverlay (slots) y que hay sonando ahora
    char layShot[24];
    if (g_iKolLayShotState[client] >= 0) strcopy(layShot, 24, g_sKolSeqName[g_iKolLayShotState[client]]);
    else strcopy(layShot, 24, "-");
    PrintToConsole(client, "Capas: %s (slots %d) | sujetar %s | one-shot %s | convar kolossos_grab_layers %d",
                   Kolossos_LayersActive() ? "ACTIVAS" : (g_bKolLayersOK ? "sondadas pero convar OFF" : "NO DISPONIBLES (fallback monocapa)"),
                   g_iKolLayerSize,
                   g_bKolLayHoldOn[client] ? "ON" : "off",
                   layShot,
                   g_cvKolGrabLayers != null ? g_cvKolGrabLayers.IntValue : -1);
    // v1.3: la serie del grab — duraciones medidas + lanzamiento pendiente
    PrintToConsole(client, "GrabSerie: reach %.2fs | punch %.2fs | throw %.2fs (0 = fallback QC 60fps) | lanzar en %.1fs",
                   g_fKolSeqDur[KOL_ST_GRABREACH], g_fKolSeqDur[KOL_ST_GRABPUNCH],
                   g_fKolSeqDur[KOL_ST_GRABTHROW],
                   g_fKolGrabThrowAt[client] > 0.0 ? g_fKolGrabThrowAt[client] - now : 0.0);
    PrintToChat(client, "\x04[Kolossos]\x01 Estado en consola (sm_kolossos).");
    return Plugin_Handled;
}
