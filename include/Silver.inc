/*
 * ======================================================
 *  [MODULO] Silver the Hedgehog - Avatar Espejo v2.0-OM
 *  (11o AVATAR DEL SUITE + SU KIT GMOD COMPLETO)
 *
 *  v2.0-OM (con manager 3.77.71, orden del owner: "es hora de que
 *  les coloques las habilidades del Gmod que tiene pasivas y eso" —
 *  reenvio los 118 Lua del addon OM) — EL KIT COMPLETO del
 *  register_noodles_silver.lua + pills_survivors_silver.lua (1612L),
 *  portado con las cifras del Lua (convars iguales que alla):
 *   - PASIVA «ENERGÍA» (Silver_PowerBar 0-100, cyan): arranca 100,
 *     regenera 5/s cuando nada está activo; la gastan el agarre (6/s),
 *     las rocas orbitando (1/s) y cada tick del time reversal (-10).
 *   - PASIVA «VIDA MÁXIMA 105» (el Lua: SetHealth 105).
 *   - Z = SUSPENSION / "IT'S NO USE!" (Lua E + LMB, ciclo de 3):
 *     pulsación 1 = modo hover (cd 5 anti-toggle, anim abilityhover);
 *     pulsación 2 = el AGARRE: rayo telekinetico a la mira (800u) — el
 *     objetivo queda COLGADO en el aire (clavado a su punto +70z,
 *     congelado, tinte CYAN, tu jugador quieto), drenando 6/s;
 *     pulsación 3 = LANZAMIENTO: aim*2000 + cd 17. Sin energía o si
 *     alguien más lo aturde: se suelta solo.
 *   - X = ROCKS (Lua R + LMB): cada pulsación invoca UNA roca (max 3,
 *     rockgranite03b del Lua con cadena nativa propano->gascan) que
 *     se alinean detrás de ti orbitando (50 atras, 60 entre ellas, la
 *     del medio +30 arriba si son 3), lerp 8, tinte CYAN + glow;
 *     mientras orbitan vas QUIETO (como el Lua) y drenan 1/s. La
 *     siguiente X con rocas vivas LANZA LA PRIMERA: aim*2500, gira;
 *     al DAR: stagger 0.5s + sonido; el 3er ACIERTO acumulado = el
 *     OM_Stun grande del Lua (3s + 15 DMG_CLUB). Al irse la última:
 *     cd 15 + 5*aciertos (el cd del Lua, crece con los fallos).
 *   - C = TIME REVERSAL (Lua T): graba tu posición cada 1s (max 10,
 *     -10 energía por tick, tick sounds 0-10); 2a pulsación (o al
 *     llenar/ quedarte sin energía) = REBOBINAR: te teletransporta
 *     hacia atras por los registros (0.09s por salto, anim de giro).
 *     Dano durante la grabación = CANCEL (cd 25); completado = cd 15.
 *   - SPACE EN EL AIRE = LEVITACION (Lua SPACE): vuelo hacia la MIRA
 *     (WASD; SHIFT = rápido), barra de 20 que drena 9.4/s (~2.1s) y
 *     se recarga en el suelo; vacía = cd 8s. Anim FlyIdle/hoverfire.
 *   - SONIDOS: los del Lua (om/silver — SilverSuspension, Throw, Land,
 *     Rockk, RockThrow, RockHit, reverseRelease, reverseCancel,
 *     charge cancel, ticks 0-10 + OM/Flystarting) — probe por
 *     FileExists (minuscula om/ primero, luego OM/ como el Lua);
 *     sin pack: el kit funciona igual en silencio.
 *   - GRÁFICOS: tinte CYAN del avatar y de la victima agarrada (el
 *     OM_highlight_Silver del Lua), glow nativo en las rocas, y el
 *     concrete_break2 del motor en el impacto de las rocas (el mismo
 *     sonido que usa el Lua).
 *
 *  v1.1-OM (con manager 3.77.70) — Silver pasa de personaje CST de SOLO
 *  MODELO a PERSONAJE SELECCIONABLE del manager (SILVER_INDEX 12,
 *  línea 13 del menú sc). La selección dispara la señal CST y el guard
 *  embebido aplica silver.cfg EN EL ACTO.
 *
 *  v1.0-OM (con manager 3.77.69, orden del owner: "hay que añadir
 *  ahora el avatar de blaze silver y el dr eggman") — Silver es un
 *  personaje CST DE MODELO (se aplica con sm_silver o por el mapa de
 *  slots del CST), así que su avatar vive en su propio modulo y se
 *  activa POR MODELO:
 *   - DETECCION: el survivor lleva el modelo survivor_silver.mdl
 *     (el único modelo del VPK CST silver — sin variantes)
 *     => el avatar espejo se monta solo, sin importar quien lo puso
 *     (sm_silver manual, mapa de slots del CST o perfil aplicado por
 *     señal). Si el modelo se va (cambio de personaje con perfil
 *     propio), la FSM lo desmonta sola.
 *   - YIELD: si el jugador tiene seleccionado un personaje del
 *     manager CON AVATAR PROPIO (Sonic/Tails/Knuckles/Amy/Shadow/
 *     Rouge/Cream/Metal/Eggman), ese avatar manda — el personaje
 *     seleccionado ES la identidad (con sus habilidades); el modelo
 *     CST puesto encima es solo skin. Sally y Sage NO tienen avatar
 *     propio: con ellos (o "Sin personaje") el avatar de Silver si
 *     se monta.
 *   - MODELO: models/Noodles/OM/silver.mdl del VPK de recursos (el
 *     mismo pack OM de los otros 8 avatares — sonic/tails/knuckles/
 *     amy/rouge/shadow/metal/cream). Detección FileExists estilo
 *     star_stun: si el archivo no está montado, TODO cae al
 *     survivor normal, CERO dependencia (y una línea en el log del
 *     server lo dice al arrancar el mapa).
 *   - Patron Cream v7.0-OM / Shadow v6.0 textual: copia R (la ven
 *     los demas) + copia L (la dueña) + cuerpo oculto + FSM 10 Hz +
 *     ragdoll de muerte 15s + anti-corpse 2s + adopción de huerfanos
 *     + pulso de pausa.
 *   - FSM POR PROBE (receta Amy v92): el .mdl no trae tabla
 *     documentada — cada estado tiene una CADENA de candidatos y
 *     gana el primer nombre que exista en el modelo; si falta, su
 *     estado base lo cubre (nunca T-pose). Estados: idle/walk/run/
 *     jump/fall + variantes lowhealth (HP<=40) + downed.
 *   - CERO gameplay: sin habilidades, sin hooks de dano, sin
 *     comandos — SOLO el avatar (el personaje es modelo CST puro).
 *     Convar único: silver_avatar 1.
 * ======================================================
 */

#if defined _Silver_included
    #endinput
#endif
#define _Silver_included

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
// Dependencias (defines del manager, disponibles antes de los includes)
// =======================
#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// =======================
// v1.0-OM: AVATAR ESPEJO SILVER.MDL (11o avatar del suite)
// =======================
#define SILVER_INC_VERSION    "v2.4-OM"   // v2.4: ROCAS CON DAÑO + SUPRESIÓN QUE DAÑA + TIME REVERSAL BLINDADO (pedido del owner 2026-10-17, ronda 2): (1) ROCAS: "ahora causarán daño de 125 a 250" [silver_rocks_dmg_min/max — antes 0: silver_rocks_basedamage_perrock DEPRECATED; las comunes de 50HP mueren AL INSTANTE con cualquier tirada] y "stun de 3seg si impactan más de 1 roca AL MISMO OBJETIVO" [el stun grande pasa del 3er acierto de la tanda al 2do acierto SOBRE EL MISMO objetivo, ventana 5s por victima]; (2) SUPRESIÓN: daño 120 AL AGARRAR + 120 AL LANZAR + 200 SI IMPACTA CON UN MURO [silver_susp_grabdmg/_throwdmg/_walldmg + el vigía de muro: velocidad horizontal desplomada con la vertical intacta = pared]; (3) TIME REVERSAL: YA NO SE INTERRUMPE POR DAÑO — el registro ahora guarda TAMBIÉN la vida y el rebobinado la RESTAURA ("regresará con la vida que tenía hasta ese momento": solo si es MAYOR — deshace el daño, jamás baja una cura); la ÚNICA cancelación es un STAGGER (chequeo diferido de m_staggerDist) — v2.3: LA BARRA AL CHAT — paleta colors.inc [volando {lightgreen} LEVITANDO! / RECARGA {green}=AMARILLO / poca carga {olive} / VACÍA {red}] vía g_iSBarChatColor + throttle sbar_chat_interval/_refresh (la captura del owner mató el rich text del hint: los <font> salen literales en L4D2) | v2.2: LA BARRA DE VUELO — pedido del owner 2026-10-15 ("...silver para su vuelo"): la flyingBar del Lua (OM_Fleetway_flyingBar 0-20) vive en BARRA GRÁFICA con el motor común SBar del manager 3.77.81 (Silver_BarState; cian al volar, RECARGA con el cd de 8s, VACÍA parpadea; el panel KeyHintText sigue con la ENERGÍA 0-100)   // v2.1: blindaje del RayFilter (IsClientInGame antes de GetClientTeam — slots conectando podían entrar al trace) + feedback de recarga en pantalla + línea del PANEL DE ESTADOS (KeyHintText siempre visible del manager 3.77.72)
#define SILVER_OM_MODEL       "models/Noodles/OM/silver.mdl"
#define SILVER_AVATAR_NAME    "silver_avatar_om"
#define SILVER_AVATAR_NAME_L  "silver_avatar_om_l"

// FSM de animación — los nombres se RESUELVEN contra el .mdl real por
// PROBE (receta Amy v92 / Shadow v6.0 / Cream v7.0): cada estado tiene
// una CADENA de candidatos y gana el primero que exista en el modelo;
// los que falten caen a su estado base (nunca T-pose)
#define SILVER_ST_IDLE         0
#define SILVER_ST_WALK         1
#define SILVER_ST_RUN          2
#define SILVER_ST_JUMP         3    // one-shot con ventana (receta Rouge)
#define SILVER_ST_FALL         4
#define SILVER_ST_IDLE_LOW     5    // lowhealth (HP <= 40)
#define SILVER_ST_WALK_LOW     6
#define SILVER_ST_RUN_LOW      7
#define SILVER_ST_DOWNED_IDLE  8    // incap
#define SILVER_ST_DOWNED_WALK  9
// v2.0-OM: estados de GAMEPLAY (nombres EXACTOS del Lua de Silver)
#define SILVER_ST_HOVER        10   // 'abilityhover' (suspensión activa)
#define SILVER_ST_SUSPLOOP     11   // 'suspensión loop' (agarrando)
#define SILVER_ST_FLYIDLE      12   // 'FlyIdle' / 'hoverfire' (levitación)
#define SILVER_ANIM_COUNT      13
#define SILVER_SEQ_MAX_CAND    6

#define SILVER_LOWHP           40     // umbral de las variantes lowhealth

// cadena de candidatos por estado (nombres GMod + variantes)
static const char g_sSilverSeqCand[SILVER_ANIM_COUNT][SILVER_SEQ_MAX_CAND][24] = {
    { "idle",            "Idle",           "idle01",       "",             "",       ""        },  // 0
    { "walk",            "Walk",           "walk01",       "",             "",       ""        },  // 1
    { "run",             "Run",            "run01",        "RunTopSpeed",  "",       ""        },  // 2
    { "jump",            "Jump",           "Jump2",        "jumpv",        "",       ""        },  // 3
    { "fall",            "Fall",           "glide",        "",             "",       ""        },  // 4
    { "idle_lowhealth",  "IdleLowHealth",  "idle_low",     "IdleLow",      "hurt",   ""        },  // 5
    { "walk_lowhealth",  "WalkLowHealth",  "walk_low",     "",             "",       ""        },  // 6
    { "run_lowhealth",   "RunLowHealth",   "run_low",      "",             "",       ""        },  // 7
    { "DownedIdle",      "downedidle",     "downed_idle",  "",             "",       ""        },  // 8
    { "DownedWalk",      "downedwalk",     "downed_walk",  "",             "",       ""        },  // 9
    // v2.0-OM: gameplay (nombres del Lua: pills_survivors_silver L188-197)
    { "abilityhover",    "AbilityHover",   "hover",        "Hover",        "idle_hover", ""    },  // 10
    { "suspensión loop", "SuspensionLoop", "suspensión",   "Suspensión",   "abilityhover", ""  },  // 11
    { "FlyIdle",         "fly",            "hoverfire",    "glide",        "float",  ""        }   // 12
};

ConVar g_cvSilverAvatar;
bool   g_bSilverModelOK     = false;   // silver.mdl en el VPK montado
bool   g_bSilverSeqResolved = false;   // el probe ya corrio en este mapa
Handle g_hSilverAvatarThink = null;    // FSM 10 Hz
int    g_iSilverAvatar[MAXPLAYERS + 1];      // EntRef copia R (0 = sin avatar)
int    g_iSilverAvatarL[MAXPLAYERS + 1];     // EntRef copia L
int    g_iSilverBodyRender[MAXPLAYERS + 1];  // render ORIGINAL del survivor
int    g_iSilverAnimState[MAXPLAYERS + 1];   // estado FSM actual
float  g_fSilverJumpStart[MAXPLAYERS + 1];   // t0 de la ventana del jump
float  g_fSilverBodyYaw[MAXPLAYERS + 1];     // yaw suavizado del avatar
float  g_fSilverYawLastT[MAXPLAYERS + 1];
bool   g_bSilverSmSnap[MAXPLAYERS + 1];
float  g_fSilverSmLoc[MAXPLAYERS + 1][3];
float  g_fSilverSmLocL[MAXPLAYERS + 1][3];
float  g_fSilverDeathHideUntil[MAXPLAYERS + 1];   // ventana anti-corpse
float  g_vSilverDeathOrigin[MAXPLAYERS + 1][3];
bool   g_bSilverWelcomeSaid[MAXPLAYERS + 1];      // aviso 1 vez por mapa
char   g_sSilverSeq[SILVER_ANIM_COUNT][24];        // nombre RESUELTO por estado
bool   g_bSilverSeqOK[SILVER_ANIM_COUNT];          // el estado resolvo?

#define Silver_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// INICIALIZACION
// =======================

// ------------------ convars del kit (defaults del Lua) ------------------
ConVar g_cvSilverMaxEnergy, g_cvSilverEnergyOnSpawn, g_cvSilverEnergyRegen;
ConVar g_cvSilverMaxHp;
ConVar g_cvSilverSuspUse, g_cvSilverSuspCd, g_cvSilverSuspCdHit,
       g_cvSilverSuspDrain, g_cvSilverSuspRange, g_cvSilverSuspThrowVel;
ConVar g_cvSilverRockUse, g_cvSilverRockCdBase, g_cvSilverRockCdPerHit,
       g_cvSilverRockMax, g_cvSilverRockDrain, g_cvSilverRockSpeed,
       g_cvSilverRockStun, g_cvSilverRockHitStun;
// v2.4-OM: el fix de rocas + la supresión que daña
ConVar g_cvSilverRockDmgMin, g_cvSilverRockDmgMax;
ConVar g_cvSilverSuspGrabDmg, g_cvSilverSuspThrowDmg, g_cvSilverSuspWallDmg;
ConVar g_cvSilverTRCd, g_cvSilverTRCdDone, g_cvSilverTRMax, g_cvSilverTRTickDelay;
ConVar g_cvSilverFlyBar, g_cvSilverFlyDrain, g_cvSilverFlyRegen, g_cvSilverFlyCd,
       g_cvSilverFlySpeed, g_cvSilverFlySpeedFast;

// ------------------ sonidos del Lua (probe dual om/ y OM/) ------------------
// el Lua escribe "OM/silver/..."; el suite del L4D2 ha usado om/ minuscula
// (om/knuckles/punchstun.wav). El probe prueba MINUSCULA primero y luego
// la capital del Lua — se emite el que exista en el VPK montado.
#define SILVER_SND_COUNT  20
static const char g_sSilverSnd[SILVER_SND_COUNT][] = {
    "om/silver/SilverSuspension.ogg",
    "om/silver/SilverSuspensionThrow.ogg",
    "om/silver/SilverSuspensionLand.ogg",
    "om/silver/SilverRockk.ogg",
    "om/silver/SilverRockThrow.ogg",
    "om/silver/SilverRockHit.ogg",
    "om/silver/silver_reverseRelease.wav",
    "om/silver/silver_reverseCancel.ogg",
    "om/silver/charge cancel.wav",
    "om/silver/Silver time reverse tick 0.wav",
    "om/silver/Silver time reverse tick 1.wav",
    "om/silver/Silver time reverse tick 2.wav",
    "om/silver/Silver time reverse tick 3.wav",
    "om/silver/Silver time reverse tick 4.wav",
    "om/silver/Silver time reverse tick 5.wav",
    "om/silver/Silver time reverse tick 6.wav",
    "om/silver/Silver time reverse tick 7.wav",
    "om/silver/Silver time reverse tick 8.wav",
    "om/silver/Silver time reverse tick 9.wav",
    "om/flystarting.wav"
};
#define SILVER_SND_SUSP        0
#define SILVER_SND_THROW        1
#define SILVER_SND_LAND         2
#define SILVER_SND_ROCKSUMMON   3
#define SILVER_SND_ROCKTHROW    4
#define SILVER_SND_ROCKHIT      5
#define SILVER_SND_RRRELEASE    6
#define SILVER_SND_RRCANCEL     7
#define SILVER_SND_TICK0        9    // 9..18 = ticks 0..9
#define SILVER_SND_TICK9        18
#define SILVER_SND_FLYSTART    19
// el concrete_break2 del Lua (nativo del motor, sin probe)
#define SILVER_SND_CONCRETE    "physics/concrete/concrete_break2.wav"

char g_sSilverSndUse[SILVER_SND_COUNT][96];
bool g_bSilverSndOK[SILVER_SND_COUNT];

// ------------------ estado por jugador ------------------
float g_fSilverEnergy[MAXPLAYERS + 1];       // Silver_PowerBar 0..max
float g_fSilverSuspCd[MAXPLAYERS + 1];       // 'SilverSuspension_cd'
float g_fSilverRockCd[MAXPLAYERS + 1];       // 'SilverRock_cd'
float g_fSilverTRCd[MAXPLAYERS + 1];         // 'SilverTimeReversal_cd'
float g_fSilverFlyCdUntil[MAXPLAYERS + 1];   // cd de la levitación (barra vacía)
float g_fSilverFlyBar[MAXPLAYERS + 1];       // 'OM_Fleetway_flyingBar' (0..20)
// suspensión (ciclo Z): 0=nada 1=hover 3=agarrando
int   g_iSilverSusp[MAXPLAYERS + 1];
int   g_iSilverGrabTarget[MAXPLAYERS + 1];   // EntRef del agarrado
float g_vSilverGrabPos[MAXPLAYERS + 1][3];   // punto donde cuelga (+70z)
bool  g_bSilverGrabTinted[MAXPLAYERS + 1];
// rocks
int   g_iSilverRocks[MAXPLAYERS + 1][3];     // EntRefs (max 3)
int   g_iSilverRockCount[MAXPLAYERS + 1];
int   g_iSilverRocksHit[MAXPLAYERS + 1];     // aciertos de la tanda (para el cd)
int   g_iSilverRockFlying[MAXPLAYERS + 1];   // EntRef de la roca lanzada (0 = ninguna)
float g_fSilverRockDieAt[MAXPLAYERS + 1];    // vida de la roca lanzada (5s)
float g_fSilverRockNextGlow[MAXPLAYERS + 1];
// time reversal: 0=inactivo 1=grabando 2=rebobinando
int   g_iSilverTRPhase[MAXPLAYERS + 1];
int   g_iSilverTRCount[MAXPLAYERS + 1];      // registros 0..10
float g_vSilverTRPos[MAXPLAYERS + 1][11][3];
float g_fSilverTRYaw[MAXPLAYERS + 1][11];
int   g_iSilverTRHp[MAXPLAYERS + 1][11];     // v2.4-OM: la vida del registro (se restaura al rebobinar)
float g_fSilverTRNext[MAXPLAYERS + 1];       // próximo tick (1s grabando / 0.09s rebobinando)
// levitación
bool  g_bSilverFlying[MAXPLAYERS + 1];
bool  g_bSilverLaggedZero[MAXPLAYERS + 1];
// misc
int   g_iSilverForceAnim[MAXPLAYERS + 1];    // -1 = FSM normal
bool  g_bSilverDmgHooked[MAXPLAYERS + 1];
bool  g_bSilverMaxHpOn[MAXPLAYERS + 1];
bool  g_bSilverPreThinkHooked[MAXPLAYERS + 1];
int   g_iSilverGlowSprite = 0;
char  g_sSilverRockModel[96] = "models/props_wasteland/rockgranite03b.mdl";
Handle g_hSilverRockThink = null;


public void Silver_OnPluginStart()
{
    // v1.0-OM: avatar espejo (patron rouge_avatar / knux_avatar / shadow_avatar)
    g_cvSilverAvatar = CreateConVar("silver_avatar", "1", "Silver OM: avatar espejo (silver.mdl del VPK de recursos; se activa con el modelo silver aplicado por el CST)", _, true, 0.0, true, 1.0);

    // v2.0-OM: EL KIT — convars con los DEFAULTS EXACTOS del Lua
    // (register_noodles_silver.lua L6-46)
    g_cvSilverMaxEnergy    = CreateConVar("silver_maxenergy",       "100", "Lua: maxenergy");
    g_cvSilverEnergyOnSpawn= CreateConVar("silver_energyonspawn",  "100", "Lua: energyonspawn");
    g_cvSilverEnergyRegen  = CreateConVar("silver_energyregen",    "5",   "Lua: energyregen (energía por segundo en reposo)");
    g_cvSilverMaxHp        = CreateConVar("silver_maxhealth",      "105", "Lua: SetHealth 105 (la receta Rouge 125)");
    g_cvSilverSuspUse      = CreateConVar("silver_suspension_useable", "1", "Lua: suspension_useable");
    g_cvSilverSuspCd       = CreateConVar("silver_suspension_cooldownmiss", "5", "Lua: suspension_cooldownmiss (anti-toggle)");
    g_cvSilverSuspCdHit    = CreateConVar("silver_suspension_cooldown",     "17", "Lua: suspension_cooldown (tras lanzar)");
    g_cvSilverSuspDrain    = CreateConVar("silver_suspension_energydrain",  "6", "Lua: suspension_energydrain 5 -> 6/s sosteniendo (0.6/tick)");
    g_cvSilverSuspRange    = CreateConVar("silver_suspension_range",       "800", "alcance del rayo telekinetico (el cubo del Lua vuela y engancha)");
    g_cvSilverSuspThrowVel = CreateConVar("silver_suspension_throwvel",    "2000", "Lua: SetVelocity direction*2000");
    g_cvSilverRockUse      = CreateConVar("silver_rocks_useable",   "1",   "Lua: rocks_useable");
    g_cvSilverRockCdBase   = CreateConVar("silver_rocks_basecd",    "15",  "Lua: rocks_basecd");
    g_cvSilverRockCdPerHit = CreateConVar("silver_rocks_cdperrock", "5",   "Lua: rocks_cdperrock (por acierto de la tanda)");
    g_cvSilverRockMax      = CreateConVar("silver_rocks_maxrocks",  "3",   "Lua: rocks_maxrocks");
    g_cvSilverRockDrain    = CreateConVar("silver_rocks_drain",     "1",   "rocas orbitando: energía por segundo (Lua: 0.1/tick)");
    g_cvSilverRockSpeed    = CreateConVar("silver_rocks_speed",     "2500", "Lua: phys SetVelocity 2500");
    g_cvSilverRockStun     = CreateConVar("silver_rocks_basestun",  "3",   "Lua: rocks_basestun (el 3er acierto, seg)");
    CreateConVar("silver_rocks_basedamage_perrock", "0", "DEPRECATED v2.4: reemplazado por silver_rocks_dmg_min/_max (125-250 por roca). Registrado para no ensuciar el Sonic_Suite.cfg — YA SIN EFECTO");
    g_cvSilverRockHitStun  = CreateConVar("silver_rocks_hitstun",   "0.5", "el 'slow' 5s del Lua -> stagger corto por acierto (seg)");
    // v2.4-OM: FIX DEL LANZAMIENTO DE ROCAS (ronda 2 del owner)
    g_cvSilverRockDmgMin   = CreateConVar("silver_rocks_dmg_min", "125",
        "v2.4: daño MINIMO por roca que acierta (antes 0: solo stun)");
    g_cvSilverRockDmgMax   = CreateConVar("silver_rocks_dmg_max", "250",
        "v2.4: daño MAXIMO por roca (125-250; las comunes de 50HP mueren al instante con cualquier tirada)");
    // v2.4-OM: LA SUPRESIÓN QUE DAÑA (ronda 2 del owner)
    g_cvSilverSuspGrabDmg  = CreateConVar("silver_susp_grabdmg", "120",
        "v2.4: daño AL AGARRAR con la supresión (telequinesis)");
    g_cvSilverSuspThrowDmg = CreateConVar("silver_susp_throwdmg", "120",
        "v2.4: daño AL LANZAR al agarrado");
    g_cvSilverSuspWallDmg  = CreateConVar("silver_susp_walldmg", "200",
        "v2.4: daño si el lanzado impacta contra un muro (el vigía: horizontal desplomada + vertical intacta = pared)");
    g_cvSilverTRCd         = CreateConVar("silver_timereverseal_cd_end", "25", "Lua: timereverseal_cd_end (cancel por dano)");
    g_cvSilverTRCdDone     = CreateConVar("silver_timereverseal_cddone", "15", "rebobinado COMPLETO: cd 15 (Lua L843-845)");
    g_cvSilverTRMax        = CreateConVar("silver_timereverseal_max",  "10", "max de registros (Lua: 10)");
    g_cvSilverTRTickDelay  = CreateConVar("silver_timereverseal_tickduration", "1", "Lua: tickduration 1s");
    g_cvSilverFlyBar       = CreateConVar("silver_fly_bar",    "20",  "Lua: OM_maximum_flight 20");
    g_cvSilverFlyDrain     = CreateConVar("silver_fly_drain",  "9.4", "Lua: 0.94 cada 0.1s");
    g_cvSilverFlyRegen     = CreateConVar("silver_fly_regen",   "4.4", "Lua: 0.35 cada 0.08s");
    g_cvSilverFlyCd        = CreateConVar("silver_fly_cd",      "8",   "Lua: flyingBar_cd 8 al vaciarse");
    g_cvSilverFlySpeed     = CreateConVar("silver_fly_speed",   "150", "velocidad de la levitación (u/s)");
    g_cvSilverFlySpeedFast = CreateConVar("silver_fly_speedfast", "300", "con SHIFT (el speed 12 del Lua)");

    // v1.0-OM: la MUERTE del avatar en el POST propio (lección Rouge
    // v3.77.49: ni el PRE ni el POST del manager tocan el avatar)
    HookEvent("player_death", Silver_Event_PlayerDeath);

    // v3.77.69: sin AutoExecConfig — config ÚNICA del suite
    // (Sonic_Suite.cfg, auto-guardada; ver manager)
}

public void Silver_OnMapStart()
{
    // v1.0-OM: AVATAR — silver.mdl del VPK (detección FileExists estilo
    // star_stun: ve los VPK montados; sin el archivo TODO cae al
    // survivor normal, CERO dependencia)
    g_bSilverModelOK = FileExists(SILVER_OM_MODEL, true);
    if (g_bSilverModelOK) PrecacheModel(SILVER_OM_MODEL, true);

    // diagnostico del arranque para el owner (una línea en el log)
    if (g_bSilverModelOK)
        PrintToServer("[Silver %s] silver.mdl del VPK OK — avatar espejo listo (modelo silver aplicado = avatar).", SILVER_INC_VERSION);
    else
        PrintToServer("[Silver %s] silver.mdl NO encontrado (%s) — avatar DESACTIVADO este mapa (cero dependencia).", SILVER_INC_VERSION, SILVER_OM_MODEL);

    // v2.0-OM: SONIDOS — probe DUAL: el Lua escribe "OM/silver/...";
    // el suite L4D2 ha usado om/ minuscula. Se emite el que exista.
    {
        char low[96], up[96], probe[128];
        int ok = 0;
        for (int s = 0; s < SILVER_SND_COUNT; s++)
        {
            // minuscula om/ primero (como om/knuckles del suite)
            Format(probe, sizeof(probe), "sound/%s", g_sSilverSnd[s]);
            strcopy(g_sSilverSndUse[s], 96, g_sSilverSnd[s]);
            g_bSilverSndOK[s] = FileExists(probe, true);
            if (!g_bSilverSndOK[s])
            {
                // luego la capital del Lua: OM/...
                up[0] = '\0';
                strcopy(low, 96, g_sSilverSnd[s]);
                // solo el prefijo om/ -> OM/
                if (strncmp(low, "om/", 3) == 0)
                {
                    Format(up, sizeof(up), "OM/%s", low[3]);
                    Format(probe, sizeof(probe), "sound/%s", up);
                    if (FileExists(probe, true))
                    {
                        strcopy(g_sSilverSndUse[s], 96, up);
                        g_bSilverSndOK[s] = true;
                    }
                }
            }
            if (g_bSilverSndOK[s]) { PrecacheSound(g_sSilverSndUse[s], true); ok++; }
        }
        PrecacheSound(SILVER_SND_CONCRETE, true);   // nativo del motor
        if (ok < SILVER_SND_COUNT)
            PrintToServer("[Silver %s] sonidos om/silver del VPK: %d/%d (los que faltan se saltan en silencio — el kit funciona igual).", SILVER_INC_VERSION, ok, SILVER_SND_COUNT);
    }

    // v2.0-OM: modelo de las ROCAS — la rockgranite03b del Lua; cadena
    // nativa de L4D2 (propano -> gas can) si no está montada
    {
        static const char sRockModels[][] = {
            "models/props_wasteland/rockgranite03b.mdl",
            "models/props_junk/propanecanister001a.mdl",
            "models/props_junk/gascan001a.mdl"
        };
        strcopy(g_sSilverRockModel, sizeof(g_sSilverRockModel), sRockModels[0]);
        for (int m = 0; m < sizeof(sRockModels); m++)
        {
            if (FileExists(sRockModels[m], true))
            {
                strcopy(g_sSilverRockModel, sizeof(g_sSilverRockModel), sRockModels[m]);
                break;
            }
        }
        PrecacheModel(g_sSilverRockModel, true);
    }

    // v2.0-OM: glow sprite + think de la roca lanzada (30 Hz) + reset
    g_iSilverGlowSprite = PrecacheModel("materials/sprites/glow01.vmt", true);
    for (int i = 1; i <= MaxClients; i++) Silver_ResetGameplay(i, true);
    delete g_hSilverRockThink;
    g_hSilverRockThink = CreateTimer(0.033, T_SilverRockThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // v1.0-OM: FSM del avatar (10 Hz, patron T_RougeAvatarThink) + el
    // probe de secuencias se re-resuelve en cada mapa (el .mdl puede
    // cambiar entre VPKs)
    g_bSilverSeqResolved = false;
    for (int s = 0; s < SILVER_ANIM_COUNT; s++) g_bSilverSeqOK[s] = false;
    delete g_hSilverAvatarThink;
    g_hSilverAvatarThink = CreateTimer(0.1, T_SilverAvatarThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    for (int i = 1; i <= MaxClients; i++)
    {
        g_iSilverAvatar[i]     = 0;
        g_iSilverAvatarL[i]    = 0;
        g_iSilverAnimState[i]  = -1;
        g_bSilverWelcomeSaid[i] = false;
        g_fSilverDeathHideUntil[i] = 0.0;
    }
}

// =====================================================================
// DETECCION DEL PERSONAJE — POR MODELO (v3.77.70: Silver TAMBIÉN es
// seleccionable en el menú — SILVER_INDEX 12 — y el guard aplica
// silver.cfg al seleccionarlo, lo que deja el modelo survivor_silver
// puesto: esta detección lo pesca igual. El avatar sigue al MODELO,
// no a la selección: da igual quien lo aplico (menú del manager,
// sm_silver manual, mapa de slots del CST o perfil por señal).
// =====================================================================
bool Silver_PlayerIs(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return false;

    // el modelo CST del personaje: survivor_silver.mdl (único modelo
    // del VPK silver — sin variantes)
    char m[96];
    GetClientModel(client, m, sizeof(m));
    if (StrContains(m, "survivor_silver", false) == -1) return false;

    // YIELD: un personaje del manager CON AVATAR PROPIO seleccionado
    // manda — su avatar es el legitimo (el personaje es la identidad
    // con sus habilidades; el modelo CST encima es solo skin). Sally
    // y Sage NO tienen avatar: con ellos (o "Sin personaje") el
    // avatar de Silver SI se monta. Silver seleccionado (SILVER_INDEX)
    // NO entra en esta lista a propósito: es su propio personaje y
    // su avatar es este.
    int c = g_iPlayerCharIdx[client];
    if (c == SONIC_INDEX     || c == TAILS_INDEX    || c == KNUCKLES_INDEX
     || c == AMY_INDEX       || c == SHADOW_INDEX   || c == ROUGE_INDEX
     || c == CREAM_INDEX     || c == METALSONIC_INDEX || c == EGGMAN_INDEX)
        return false;

    return true;
}

// =====================================================================
// RESOLUCION DE SECUENCIAS POR PROBE (receta Amy v92 / Shadow v6.0 /
// Cream v7.0): SourcePawn no trae LookupSequence — se dispara
// SetAnimation(nombre) y se lee m_nSequence: si el índice CAMBIO, el
// nombre existe en el .mdl. Se resuelve UNA vez por mapa (al nacer el
// primer avatar, todo dentro del mismo frame).
// =====================================================================
void Silver_ResolveTry(int av, int state, const char[] name)
{
    if (g_bSilverSeqOK[state]) return;
    if (!HasEntProp(av, Prop_Send, "m_nSequence")) return;

    int before = GetEntProp(av, Prop_Send, "m_nSequence");
    SetVariantString(name);
    AcceptEntityInput(av, "SetAnimation");
    int after = GetEntProp(av, Prop_Send, "m_nSequence");

    if (after != before)
    {
        strcopy(g_sSilverSeq[state], sizeof(g_sSilverSeq[]), name);
        g_bSilverSeqOK[state] = true;
    }
}

void Silver_ResolveSeqs(int av)
{
    if (g_bSilverSeqResolved) return;
    g_bSilverSeqResolved = true;

    // cadena de candidatos por estado (nombres GMod + variantes)
    for (int st = 0; st < SILVER_ANIM_COUNT; st++)
    {
        for (int c = 0; c < SILVER_SEQ_MAX_CAND; c++)
        {
            if (g_sSilverSeqCand[st][c][0] == '\0') break;
            Silver_ResolveTry(av, st, g_sSilverSeqCand[st][c]);
            if (g_bSilverSeqOK[st]) break;
        }
    }

    // 2a pasada del idle (truco Amy v92: si el default del modelo YA
    // era idle, la primera prueba no movió el índice — ahora el actual
    // es otro y si "idle" existe, se registra)
    Silver_ResolveTry(av, SILVER_ST_IDLE, "idle");

    // fallbacks de las variantes que el modelo no traiga: la base
    // cubre el hueco (nunca T-pose)
    int fallbacks[SILVER_ANIM_COUNT];
    for (int fb = 0; fb < SILVER_ANIM_COUNT; fb++) fallbacks[fb] = -1;
    fallbacks[SILVER_ST_IDLE_LOW]    = SILVER_ST_IDLE;
    fallbacks[SILVER_ST_WALK_LOW]    = SILVER_ST_WALK;
    fallbacks[SILVER_ST_RUN_LOW]     = SILVER_ST_RUN;
    fallbacks[SILVER_ST_DOWNED_IDLE] = SILVER_ST_IDLE;
    fallbacks[SILVER_ST_DOWNED_WALK] = SILVER_ST_WALK;
    // v2.0-OM: los estados de juego caen a su base (nunca T-pose)
    fallbacks[SILVER_ST_HOVER]       = SILVER_ST_IDLE;
    fallbacks[SILVER_ST_SUSPLOOP]    = SILVER_ST_HOVER;
    fallbacks[SILVER_ST_FLYIDLE]     = SILVER_ST_FALL;

    for (int s = 0; s < SILVER_ANIM_COUNT; s++)
    {
        if (g_bSilverSeqOK[s] || fallbacks[s] < 0) continue;
        if (g_bSilverSeqOK[fallbacks[s]])
        {
            strcopy(g_sSilverSeq[s], sizeof(g_sSilverSeq[]), g_sSilverSeq[fallbacks[s]]);
            g_bSilverSeqOK[s] = true;
        }
    }
}

// la secuencia a usar para un estado (con triple red de seguridad)
void Silver_SeqFor(int state, char out[24])
{
    if (g_bSilverSeqOK[state])
        strcopy(out, 24, g_sSilverSeq[state]);
    else if (g_bSilverSeqOK[SILVER_ST_IDLE])
        strcopy(out, 24, g_sSilverSeq[SILVER_ST_IDLE]);
    else
        strcopy(out, 24, "idle");
}

// =====================================================================
// CREACION / MUERTE DE LAS COPIAS (receta Rouge v10.2 / Shadow v6.0 /
// Cream v7.0)
// =====================================================================
int Silver_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
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
    g_fSilverBodyYaw[client]  = ang[1];
    g_fSilverYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fSilverBodyYaw[client], loc);

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
        g_fSilverSmLoc[client][k]  = loc[k];
        g_fSilverSmLocL[client][k] = loc[k];
    }
    g_bSilverSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// v72-OM (adopción): un prop con NUESTRO nombre que esta FSM no rastrea
// es un huerfano por definición — muere en el instante del montaje.
bool Silver_IsMyAvatarRef(int ref)
{
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iSilverAvatar[i] == ref) return true;
        if (g_iSilverAvatarL[i] == ref) return true;
    }
    return false;
}

void Silver_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "silver_avatar_om", "silver_avatar_om_l" };
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
                if (Silver_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
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
        PrintToServer("[Silver %s] Adopción del montaje: %d huerfano(s) del avatar eliminado(s).", SILVER_INC_VERSION, ng);
}

// Monta el avatar completo (R + L + cuerpo oculto). pulsePause SOLO para
// montajes de ciclo de vida (spawn/selección/reparación tardia de la FSM).
void Silver_CreateAvatar(int client, bool pulsePause = true)
{
    if (!g_bSilverModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;

    // v72-OM (reemplazo limpio): si este cliente ya tenía un R o L vivo
    // (montaje doble por orden raro de eventos), muere AQUÍ enterito.
    {
        int oldR = EntRefToEntIndex(g_iSilverAvatar[client]);
        if (g_iSilverAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Silver_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iSilverAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iSilverAvatarL[client]);
        if (g_iSilverAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Silver_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iSilverAvatarL[client] = 0;
    }

    // v72-OM: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje.
    Silver_KillGhostAvatarProps();

    int av = Silver_CreateAvatarProp(client, SILVER_OM_MODEL, SILVER_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    // resolver las secuencias contra el .mdl REAL (probe Amy v92, UNA
    // vez por mapa — el primer avatar nace resolviendo para todos)
    Silver_ResolveSeqs(av);

    char seqIdle[24];
    Silver_SeqFor(SILVER_ST_IDLE, seqIdle);
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");
    g_iSilverAnimState[client] = 0;

    SDKHook(av, SDKHook_SetTransmit, Silver_TransmitAvatarR);

    g_iSilverAvatarL[client] = 0;
    Silver_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iSilverBodyRender[client] = view_as<int>(curMode);
    else if (g_iSilverBodyRender[client] == -1)
        g_iSilverBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    g_iSilverAvatar[client] = EntIndexToEntRef(av);

    // per-tick: angulos locales (contra-rotación del parent)
    SDKHook(client, SDKHook_PostThink, Silver_AvatarFollow);

    // PULSO DE PAUSA en cada montaje de ciclo de vida (la misma infra
    // sv_pausable del suite; convar tails_pausefix manda para TODOS los
    // avatares — es UN solo sistema, 11o avatar del suite)
    if (pulsePause)
        Tails_PauseFix_Trigger(client);

    // aviso UNA vez por mapa (solo humanos — los bots con el modelo
    // silver del mapa de slots del CST también tienen avatar, sin spam)
    if (!g_bSilverWelcomeSaid[client] && !IsFakeClient(client))
    {
        g_bSilverWelcomeSaid[client] = true;
        PrintToChat(client, "\x04[Silver]\x01 Avatar espejo activo (\x05silver.mdl\x01) — 11o avatar del suite.");
    }
}

void Silver_CreateAvatarL(int client)
{
    if (!g_bSilverModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iSilverAvatar[client] == 0) return;

    int av = Silver_CreateAvatarProp(client, SILVER_OM_MODEL, SILVER_AVATAR_NAME_L);
    if (av == 0) return;

    char seqIdle[24];
    Silver_SeqFor(SILVER_ST_IDLE, seqIdle);
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Silver_TransmitAvatarL);

    g_iSilverAvatarL[client] = EntIndexToEntRef(av);
}

void Silver_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iSilverAvatarL[client]);
    if (g_iSilverAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Silver_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iSilverAvatarL[client] = 0;
}

// Mata las copias R+L y devuelve el cuerpo. SIN desenganchar el follow
// (lo hace Silver_KillAvatar).
void Silver_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    Silver_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iSilverAvatar[client]);
    if (g_iSilverAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Silver_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iSilverAvatar[client] = 0;
    g_iSilverAnimState[client] = -1;

    // devolver el cuerpo (spectate/revive/cambio de personaje)
    if (IsClientInGame(client) && g_iSilverBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iSilverBodyRender[client]));
        g_iSilverBodyRender[client] = -1;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Silver_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Silver_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Silver_AvatarFollow);
}

// Transmit filters (patron Rouge/Sonic/Metal/Shadow/Cream): la R no la
// ve su dueña (tiene su L), la L la ve SOLO su dueña.
public Action Silver_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iSilverAvatar[i] != 0 && EntRefToEntIndex(g_iSilverAvatar[i]) == entity)
        {
            if (client == i && g_iSilverAvatarL[i] != 0
                && EntRefToEntIndex(g_iSilverAvatarL[i]) > 0)
                return Plugin_Handled;   // la dueña tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

public Action Silver_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iSilverAvatarL[i] != 0 && EntRefToEntIndex(g_iSilverAvatarL[i]) == entity)
        {
            if (client == i) return Plugin_Continue;   // la dueña si
            return Plugin_Handled;                     // nadie más
        }
    }
    return Plugin_Continue;
}

// FOLLOW PER-TICK (receta Rouge: yaw suave con deadband 3 grados,
// contra-rotación amortiguada, reloj vivo, copia L contra los eye
// angles de la dueña; la R por TP en modo tp).
public void Silver_AvatarFollow(int client)
{
    if (g_iSilverAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Silver_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    // ---- yaw objetivo: dirección REAL del movimiento ----
    float yawObj = g_fSilverBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fSilverBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    // ---- giro suave hacia el objetivo (~900 grados/s) ----
    float now = GetEngineTime();
    float dt  = now - g_fSilverYawLastT[client];
    g_fSilverYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fSilverBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fSilverBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bSilverSmSnap[client];
    GetClientAbsAngles(client, par);
    float yawPuppet = g_fSilverBodyYaw[client];

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iSilverAvatar[client]);
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
            loc[1] = Tails_UnwrapYaw(g_fSilverSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fSilverSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fSilverSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }

    // ---- copia L: contra-rotada contra los EYE de la dueña ----
    if (g_iSilverAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iSilverAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3], locL[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], yawPuppet, locL);
            locL[1] = Tails_UnwrapYaw(g_fSilverSmLocL[client][1], locL[1]);
            Tails_ExpDamp(locL, g_fSilverSmLocL[client], 0.05, dt, snap);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fSilverSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
    g_bSilverSmSnap[client] = false;
}

// FSM de 10 Hz: montaje / auto-reparación / muerte del avatar (patron
// T_RougeAvatarThink / T_ShadowAvatarThink / T_CreamAvatarThink)
public Action T_SilverAvatarThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Silver_KillAvatar(i); continue; }

        bool esSilverViva = (Silver_PlayerIs(i)
                         && IsPlayerAlive(i) && GetClientTeam(i) == 2);

        // incap = fuera (defensa anti terceros — la FSM re-monta sola
        // al levantarla: la misma regla de Rouge/Shadow/Cream)
        if (esSilverViva && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            esSilverViva = false;

        // v2.0-OM: EL TICK DEL KIT — con o sin avatar (el gameplay es del
        // PERSONAJE). Downed/muerto = cancel suave.
        if (IsPlayerAlive(i) && GetClientTeam(i) == 2)
        {
            if (GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            {
                if (g_iSilverSusp[i] != 0 || g_iSilverTRPhase[i] != 0 || g_iSilverRockCount[i] > 0 || g_bSilverFlying[i])
                    Silver_ResetGameplay(i, false);
            }
            else
                Silver_GameplayThink(i, now);
        }

        // ---- montaje ----
        if (g_iSilverAvatar[i] == 0)
        {
            if (esSilverViva && g_cvSilverAvatar != null && g_cvSilverAvatar.BoolValue
                && g_bSilverModelOK)
            {
                Silver_CreateAvatar(i);
            }
            continue;
        }

        // quitar avatar si dejó de ser una Silver survivor viva de pie
        if (!esSilverViva)
        {
            Silver_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iSilverAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iSilverAvatar[i] = 0;
            g_iSilverAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (el motor lo resetea al
        // cambiar de capítulo/rescue: fix Tails v5.4)
        if (g_iSilverBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparación de la copia L (montaje tardio: pulso también)
        if (g_iSilverAvatarL[i] == 0 && g_iSilverAvatar[i] != 0)
        {
            Silver_CreateAvatarL(i);
            if (g_iSilverAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // ---- FSM de animación ----
        av = EntRefToEntIndex(g_iSilverAvatar[i]);
        if (g_iSilverAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Silver_AvatarUpdate(i, av, now);
    }
    return Plugin_Continue;
}

// =====================================================================
// FSM DE ANIMACION — prioridades: incap (DownedIdle/DownedWalk) ->
// aire (jump subiendo / fall cayendo) -> suelo (idle/walk/run con
// variantes lowhealth de HP<=40).
// =====================================================================
void Silver_AvatarUpdate(int client, int av, float now)
{
    int state;
    float rate = 1.0;

    // v2.0-OM: anim de juego forzada (hover / suspensión loop / FlyIdle)
    if (g_iSilverForceAnim[client] >= 0)
    {
        state = g_iSilverForceAnim[client];
    }
    else if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
    {
        // DownedIdle/DownedWalk
        state = (Silver_Speed2D(client) > 40.0) ? SILVER_ST_DOWNED_WALK : SILVER_ST_DOWNED_IDLE;
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // AIRE: sube = jump; cae = fall — con la ventana del jump
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[2] > 40.0)
        {
            state = SILVER_ST_JUMP;
        }
        else
        {
            bool jumpLive = false;
            if (g_iSilverAnimState[client] == SILVER_ST_JUMP)
            {
                float jt = now - g_fSilverJumpStart[client];
                if (jt < 0.5)      jumpLive = true;
                else if (jt < 1.5 && !Silver_JumpAnimDone(av)) jumpLive = true;
            }
            state = jumpLive ? SILVER_ST_JUMP : SILVER_ST_FALL;
        }
    }
    else if (g_iSilverAnimState[client] == SILVER_ST_JUMP && !Silver_JumpAnimDone(av)
             && now - g_fSilverJumpStart[client] < 0.5)
    {
        // FL_ONGROUND parpadea al saltar rozando escalones
        state = SILVER_ST_JUMP;
    }
    else
    {
        // SUELO: idle/walk/run (lowhealth <= 40)
        bool low = (GetClientHealth(client) <= SILVER_LOWHP);
        float s = Silver_Speed2D(client);
        if (s < 40.0)
            state = low ? SILVER_ST_IDLE_LOW : SILVER_ST_IDLE;
        else if (s < 150.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = low ? SILVER_ST_WALK_LOW : SILVER_ST_WALK;
            rate = 1.0;   // rate 1 constante del framework GMod
        }
        else
        {
            state = low ? SILVER_ST_RUN_LOW : SILVER_ST_RUN;
            rate = 1.32 * (s / 450.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6)  rate = 3.6;
        }
    }

    if (state != g_iSilverAnimState[client])
    {
        // el t0 del jump para su ventana (receta Rouge/Sonic/Knuckles)
        if (state == SILVER_ST_JUMP) g_fSilverJumpStart[client] = now;

        char seqUse[24];
        Silver_SeqFor(state, seqUse);

        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iSilverAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iSilverAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                // el variant es de UN SOLO USO — re-armarlo
                SetVariantString(seqUse);
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iSilverAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iSilverAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iSilverAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

float Silver_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// el one-shot del jump termino? (m_flCycle del prop — la misma sonda
// del Rouge_JumpAnimDone / Knux_JumpAnimDone / Shadow_JumpAnimDone)
bool Silver_JumpAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return true;
}

// =====================================================================
// v2.0-OM: EL KIT GMOD DE SILVER (register_noodles_silver.lua +
// pills_survivors_silver.lua L464-1210). El gameplay es del PERSONAJE:
// corre con Silver_PlayerIs (modelo silver puesto), con o sin avatar.
// Los NÚMEROS son los del Lua; las convars traen sus defaults.
// =====================================================================

// ------------------ helpers ------------------
void Silver_Snd(int idx, int ent)
{
    if (idx < 0 || idx >= SILVER_SND_COUNT || !g_bSilverSndOK[idx]) return;
    if (ent > 0 && IsValidEntity(ent)) EmitSoundToAll(g_sSilverSndUse[idx], ent, SNDCHAN_AUTO, 90);
}

// el tinte CYAN (0,175,245) del Lua para el avatar o la victima
void Silver_TintEnt(int ent, bool on)
{
    if (ent <= 0 || !IsValidEntity(ent)) return;
    if (on)  SetEntityRenderColor(ent, 0, 175, 245, 255);
    else     SetEntityRenderColor(ent, 255, 255, 255, 255);
}

void Silver_AvatarTint(int client, bool on)
{
    int av  = EntRefToEntIndex(g_iSilverAvatar[client]);
    int avL = EntRefToEntIndex(g_iSilverAvatarL[client]);
    if (on) {
        if (av  > 0 && IsValidEntity(av))  SetEntityRenderColor(av, 0, 175, 245, 255);
        if (avL > 0 && IsValidEntity(avL)) SetEntityRenderColor(avL, 0, 175, 245, 255);
    } else {
        if (av  > 0 && IsValidEntity(av))  SetEntityRenderColor(av, 255, 255, 255, 255);
        if (avL > 0 && IsValidEntity(avL)) SetEntityRenderColor(avL, 255, 255, 255, 255);
    }
}

void Silver_AddEnergy(int client, float amount)
{
    float mx = (g_cvSilverMaxEnergy != null) ? g_cvSilverMaxEnergy.FloatValue : 100.0;
    g_fSilverEnergy[client] += amount;
    if (g_fSilverEnergy[client] > mx) g_fSilverEnergy[client] = mx;
    if (g_fSilverEnergy[client] < 0.0) g_fSilverEnergy[client] = 0.0;
}

// PASIVA: vida máxima 105 (la receta Rouge_ApplyMaxHealth)
void Silver_ApplyMaxHealth(int client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != TEAM_SURVIVOR) return;
    int maxHp = (g_cvSilverMaxHp != null) ? g_cvSilverMaxHp.IntValue : 105;
    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", maxHp);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", maxHp);
    g_bSilverMaxHpOn[client] = true;
    if (!GetEntProp(client, Prop_Send, "m_isIncapacitated"))
    {
        int hp = GetClientHealth(client);
        if (hp >= 100 && hp < maxHp)
            SetEntityHealth(client, maxHp);
    }
}

void Silver_RestoreMaxHealth(int client)
{
    if (!g_bSilverMaxHpOn[client]) return;
    g_bSilverMaxHpOn[client] = false;
    if (!IsClientInGame(client)) return;
    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", 100);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", 100);
}

// primer enemigo válido en una esfera (SI players + comunes/witch/tank)
int Silver_ScanEnemy(int client, const float center[3], float radius)
{
    for (int t = 1; t <= MaxClients; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != TEAM_INFECTED) continue;
        float p[3];
        GetClientAbsOrigin(t, p);
        if (GetVectorDistance(center, p) <= radius) return t;
    }
    static const char sNpc[][] = { "infected", "witch", "tank" };
    int ent = -1;
    for (int n = 0; n < sizeof(sNpc); n++)
    {
        ent = -1;
        while ((ent = FindEntityByClassname(ent, sNpc[n])) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            if (!HasEntProp(ent, Prop_Data, "m_iHealth")) continue;
            if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
            float p[3];
            GetEntPropVector(ent, Prop_Data, "m_vecOrigin", p);
            if (GetVectorDistance(center, p) <= radius) return ent;
        }
    }
    return 0;
}

// ------------------ entry points (manager: Z / X / C) ------------------
void Silver_Ability1(int client)   // Z: el ciclo de la Suspensión
{
    if (!Silver_PlayerIs(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2) return;
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    float now = GetEngineTime();

    // sin energía no hay nada (el Lua: PowerBar < 10)
    if (g_fSilverEnergy[client] < 10.0) return;
    // rocks activas o time reversal: no (el Lua los bloquea entre si)
    if (g_iSilverRockCount[client] > 0 || g_iSilverRockFlying[client] != 0) return;
    if (g_iSilverTRPhase[client] != 0) return;
    if (g_bSilverFlying[client]) return;

    if (g_iSilverSusp[client] == 0)
    {
        if (now < g_fSilverSuspCd[client])
        {
            PrintCenterText(client, "[Silver] Suspensión en enfriamiento: %.1fs", g_fSilverSuspCd[client] - now);
            return;
        }
        if (g_cvSilverSuspUse != null && !g_cvSilverSuspUse.BoolValue) return;
        // pulsación 1: modo hover (Lua L947-961: enabled=1, cd 5)
        g_iSilverSusp[client] = 1;
        g_fSilverSuspCd[client] = now + ((g_cvSilverSuspCd != null) ? g_cvSilverSuspCd.FloatValue : 5.0);
        Silver_Snd(SILVER_SND_SUSP, client);
        g_iSilverForceAnim[client] = SILVER_ST_HOVER;
        return;
    }

    if (g_iSilverSusp[client] == 1)
    {
        // pulsación 2: el AGARRE — rayo telekinetico a la mira (el cubo
        // del Lua vuela 2100 y engancha al primero de la esfera 80; aquí
        // el rayo directo: lo que tengas en la mira a 800u)
        float eye[3], fwd[3], end[3];
        GetClientEyePosition(client, eye);
        GetClientEyeAngles(client, eye);
        GetAngleVectors(eye, fwd, NULL_VECTOR, NULL_VECTOR);
        float range = (g_cvSilverSuspRange != null) ? g_cvSilverSuspRange.FloatValue : 800.0;
        end[0] = eye[0] + fwd[0] * range;
        end[1] = eye[1] + fwd[1] * range;
        end[2] = eye[2] + fwd[2] * range;

        int victim = 0;
        // 1) rayo exacto
        Handle tr = TR_TraceRayFilterEx(eye, end, MASK_SOLID, RayType_EndPoint, Silver_RayFilter, client);
        if (TR_DidHit(tr))
        {
            int hitEnt = TR_GetEntityIndex(tr);
            if (hitEnt > 0 && hitEnt <= MaxClients && IsClientInGame(hitEnt)
                && IsPlayerAlive(hitEnt) && GetClientTeam(hitEnt) == TEAM_INFECTED)
                victim = hitEnt;
        }
        delete tr;
        // 2) si el rayo no tocó a nadie: esfera 80 sobre el punto
        if (victim == 0)
        {
            float c[3];
            c[0] = eye[0] + fwd[0] * range * 0.5;
            c[1] = eye[1] + fwd[1] * range * 0.5;
            c[2] = eye[2] + fwd[2] * range * 0.5;
            victim = Silver_ScanEnemy(client, c, 90.0);
        }

        if (victim == 0)
        {
            // fallo: fuera del modo (sin castigo extra — el cd 5 ya corrio)
            g_iSilverSusp[client] = 0;
            g_iSilverForceAnim[client] = -1;
            return;
        }

        // v2.4-OM: la supresión ahora hace daño AL AGARRAR (120); si el
        // daño mata al objetivo (un común de 50HP no aguanta), no se
        // arrastra un cadaver — fuera del modo
        float gd = (g_cvSilverSuspGrabDmg != null) ? g_cvSilverSuspGrabDmg.FloatValue : 120.0;
        if (gd > 0.0) OM_AbilityDamage(victim, client, gd, DMG_OM_CLUB);
        bool gAlive;
        if (victim <= MaxClients) gAlive = IsClientInGame(victim) && IsPlayerAlive(victim);
        else gAlive = (IsValidEntity(victim) && GetEntProp(victim, Prop_Data, "m_iHealth") > 0);
        if (!gAlive)
        {
            g_iSilverSusp[client] = 0;
            g_iSilverForceAnim[client] = -1;
            return;
        }

        // ENGANCHADO (Lua L1493-1528): colgado a su punto +70z
        g_iSilverSusp[client] = 3;
        g_iSilverGrabTarget[client] = EntIndexToEntRef(victim);
        float gp[3];
        if (victim <= MaxClients) GetClientAbsOrigin(victim, gp);
        else GetEntPropVector(victim, Prop_Data, "m_vecOrigin", gp);
        gp[2] += 70.0;
        CopyVector(gp, g_vSilverGrabPos[client]);
        // tinte CYAN del objetivo (el OM_highlight_Silver del Lua)
        g_bSilverGrabTinted[client] = true;
        Silver_TintEnt(victim, true);
        g_iSilverForceAnim[client] = SILVER_ST_SUSPLOOP;
        Silver_Snd(SILVER_SND_LAND, client);
        // el jugador quieto mientras agarra (OM_NoMovement del Lua)
        g_bSilverLaggedZero[client] = true;
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0001);
        return;
    }

    if (g_iSilverSusp[client] == 3)
    {
        // pulsación 3: LANZAMIENTO (Lua L1539-1579)
        int tgt = EntRefToEntIndex(g_iSilverGrabTarget[client]);
        if (tgt > 0 && IsValidEntity(tgt))
        {
            float eye[3], fwd[3], v[3];
            GetClientEyeAngles(client, eye);
            GetAngleVectors(eye, fwd, NULL_VECTOR, NULL_VECTOR);
            float tv = (g_cvSilverSuspThrowVel != null) ? g_cvSilverSuspThrowVel.FloatValue : 2000.0;
            CopyVector(fwd, v); ScaleVector(v, tv);
            TeleportEntity(tgt, NULL_VECTOR, NULL_VECTOR, v);

            // v2.4-OM: daño AL LANZAR (120) + el vigía de impacto contra muro
            float td = (g_cvSilverSuspThrowDmg != null) ? g_cvSilverSuspThrowDmg.FloatValue : 120.0;
            if (td > 0.0)
            {
                bool tAlive;
                if (tgt <= MaxClients) tAlive = IsClientInGame(tgt) && IsPlayerAlive(tgt);
                else tAlive = (GetEntProp(tgt, Prop_Data, "m_iHealth") > 0);
                if (tAlive) OM_AbilityDamage(tgt, client, td, DMG_OM_CLUB);
            }
            Silver_WallWatchStart(client, tgt);
        }
        Silver_ReleaseGrab(client);
        g_fSilverSuspCd[client] = now + ((g_cvSilverSuspCdHit != null) ? g_cvSilverSuspCdHit.FloatValue : 17.0);
        Silver_Snd(SILVER_SND_THROW, client);
    }
}

void Silver_ReleaseGrab(int client)
{
    int tgt = EntRefToEntIndex(g_iSilverGrabTarget[client]);
    if (tgt > 0 && IsValidEntity(tgt) && g_bSilverGrabTinted[client])
        Silver_TintEnt(tgt, false);            // color original
    g_iSilverGrabTarget[client] = 0;
    g_bSilverGrabTinted[client] = false;
    if (g_iSilverSusp[client] == 3) g_iSilverSusp[client] = 0;
    if (g_bSilverLaggedZero[client])
    {
        g_bSilverLaggedZero[client] = false;
        if (IsClientInGame(client) && HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
    if (g_iSilverForceAnim[client] == SILVER_ST_SUSPLOOP) g_iSilverForceAnim[client] = -1;
}

public bool Silver_RayFilter(int entity, int contentsMask, any data)
{
    if (entity == view_as<int>(data)) return false;
    if (entity > 0 && entity <= MaxClients)
    {
        // v2.1-OM: IsClientInGame ANTES de GetClientTeam (un slot
        // conectándose tiene edict en la lista de trazado pero sin
        // equipo legible — el orden seguro del resto del suite)
        if (!IsClientInGame(entity)) return false;
        return (GetClientTeam(entity) == TEAM_INFECTED);   // solo el equipo 3 engancha
    }
    return true;
}

void Silver_Ability2(int client)   // X: Rocks (invocar o lanzar la primera)
{
    if (!Silver_PlayerIs(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2) return;
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    float now = GetEngineTime();
    if (g_iSilverTRPhase[client] != 0) return;
    if (g_iSilverSusp[client] != 0) return;
    if (g_bSilverFlying[client]) return;
    if (g_cvSilverRockUse != null && !g_cvSilverRockUse.BoolValue) return;
    if (g_iSilverRockFlying[client] != 0) return;    // una en vuelo a la vez

    // ---- con rocas vivas: LANZAR LA PRIMERA (el LMB del Lua) ----
    if (g_iSilverRockCount[client] > 0)
    {
        int rock = EntRefToEntIndex(g_iSilverRocks[client][0]);
        // quitarla del orbit (corrimiento del array)
        for (int r = 0; r < 2; r++) g_iSilverRocks[client][r] = g_iSilverRocks[client][r + 1];
        g_iSilverRocks[client][2] = 0;
        g_iSilverRockCount[client]--;
        if (rock <= 0 || !IsValidEntity(rock))
        {
            Silver_RockCdCheck(client);
            return;
        }

        // vuelo controlado: la mueve nuestro think 30 Hz (aim*2500)
        g_iSilverRockFlying[client] = EntIndexToEntRef(rock);
        g_fSilverRockDieAt[client] = now + 5.0;
        Silver_Snd(SILVER_SND_ROCKTHROW, client);
        Silver_RockCdCheck(client);
        return;
    }

    // ---- invocar UNA roca (max 3) ----
    if (now < g_fSilverRockCd[client])
    {
        PrintCenterText(client, "[Silver] Rocks en enfriamiento: %.1fs", g_fSilverRockCd[client] - now);
        return;
    }
    if (g_fSilverEnergy[client] < 30.0) return;    // el Lua: PowerBar < 30

    int maxR = (g_cvSilverRockMax != null) ? g_cvSilverRockMax.IntValue : 3;
    if (maxR > 3) maxR = 3;
    if (g_iSilverRockCount[client] >= maxR) return;

    // nace detrás, desde el suelo (Lua L1049-1057: -120 fwd, trace 300 abajo)
    float eye[3], fwd[3], right[3];
    GetClientEyeAngles(client, eye);
    GetAngleVectors(eye, fwd, right, NULL_VECTOR);
    float sp[3];
    GetClientAbsOrigin(client, sp);
    sp[0] -= fwd[0] * 120.0; sp[1] -= fwd[1] * 120.0;

    float start[3], end[3];
    CopyVector(sp, start); start[2] += 100.0;
    CopyVector(sp, end);   end[2]   -= 300.0;
    Handle tr = TR_TraceRayFilterEx(start, end, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Silver_RayFilter, client);
    float ground[3];
    if (TR_DidHit(tr)) TR_GetEndPosition(ground, tr);
    else CopyVector(sp, ground);
    delete tr;

    int rock = CreateEntityByName("prop_dynamic_override");
    if (rock <= 0 || !IsValidEntity(rock)) return;
    DispatchKeyValue(rock, "model", g_sSilverRockModel);
    DispatchKeyValue(rock, "targetname", "silver_rock_om");
    DispatchKeyValue(rock, "solid", "0");
    DispatchSpawn(rock);
    // nace a -60z y SUBE 0.25s hasta +60 (el rise del Lua)
    ground[2] -= 60.0;
    TeleportEntity(rock, ground, NULL_VECTOR, NULL_VECTOR);
    SetEntityRenderColor(rock, 0, 175, 245, 255);   // CYAN desde que nace

    g_iSilverRocks[client][g_iSilverRockCount[client]] = EntIndexToEntRef(rock);
    g_iSilverRockCount[client]++;
    Silver_Snd(SILVER_SND_ROCKSUMMON, client);

    // jugador quieto mientras orbitan (OM_NoMovement del Lua)
    if (!g_bSilverLaggedZero[client])
    {
        g_bSilverLaggedZero[client] = true;
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0001);
    }
}

// cuando la última roca se va (lanzada o destruida): el cd del Lua
// (15 base + 5 por acierto de la tanda). RocksHit se limpia en la
// próxima invocación desde cero (CurrentRockCount 0 -> RocksHit 0).
void Silver_RockCdCheck(int client)
{
    if (g_iSilverRockCount[client] > 0) return;
    float base = (g_cvSilverRockCdBase != null) ? g_cvSilverRockCdBase.FloatValue : 15.0;
    float per  = (g_cvSilverRockCdPerHit != null) ? g_cvSilverRockCdPerHit.FloatValue : 5.0;
    g_fSilverRockCd[client] = GetEngineTime() + base + per * float(g_iSilverRocksHit[client]);
    g_iSilverRocksHit[client] = 0;
    if (g_bSilverLaggedZero[client])
    {
        g_bSilverLaggedZero[client] = false;
        if (IsClientInGame(client) && HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
}

void Silver_Ability3(int client)   // C: Time Reversal
{
    if (!Silver_PlayerIs(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2) return;
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    float now = GetEngineTime();
    if (g_iSilverSusp[client] != 0) return;
    if (g_iSilverRockCount[client] > 0 || g_iSilverRockFlying[client] != 0) return;
    if (g_bSilverFlying[client]) return;

    if (g_iSilverTRPhase[client] == 0)
    {
        if (now < g_fSilverTRCd[client])
        {
            PrintCenterText(client, "[Silver] Time Reversal en enfriamiento: %.1fs", g_fSilverTRCd[client] - now);
            return;
        }
        if (g_fSilverEnergy[client] < 10.0) return;
        if (g_cvSilverTRMax == null || g_cvSilverTRMax.IntValue < 1) return;

        // EMPEZAR A GRABAR (Lua L1141-1176): registro 0 ya mismo
        g_iSilverTRPhase[client] = 1;
        g_iSilverTRCount[client] = 0;
        Silver_TRRecord(client);
        Silver_Snd(SILVER_SND_TICK0, client);
        g_fSilverTRNext[client] = now + ((g_cvSilverTRTickDelay != null) ? g_cvSilverTRTickDelay.FloatValue : 1.0);
        return;
    }

    if (g_iSilverTRPhase[client] == 1)
    {
        // 2a pulsación: REBOBINAR ya (Lua L1205-1208)
        g_iSilverTRPhase[client] = 2;
        g_fSilverTRNext[client] = 0.0;   // arranca en el próximo tick
        return;
    }
    // en pleno rebobinado no se puede volver a pulsar (se ignora)
}

// registra la pos+yaw ACTUAL del jugador (Lua L820-822)
void Silver_TRRecord(int client)
{
    int maxR = (g_cvSilverTRMax != null) ? g_cvSilverTRMax.IntValue : 10;
    if (maxR > 10) maxR = 10;
    if (g_iSilverTRCount[client] >= maxR) return;

    int slot = g_iSilverTRCount[client];
    float p[3], a[3];
    GetClientAbsOrigin(client, p);
    GetClientAbsAngles(client, a);
    CopyVector(p, g_vSilverTRPos[client][slot]);
    g_fSilverTRYaw[client][slot] = a[1];
    // v2.4-OM: el registro ahora guarda TAMBIEN la vida — "regresará
    // con la vida que tenía hasta ese momento"
    g_iSilverTRHp[client][slot] = GetClientHealth(client);
    g_iSilverTRCount[client]++;
}

// =====================================================================
// v2.0-OM: EL TICK DEL KIT — desde T_SilverAvatarThink (10 Hz).
// =====================================================================
void Silver_GameplayThink(int client, float now)
{
    if (!Silver_PlayerIs(client)) return;

    // hooks perezosos
    if (!g_bSilverDmgHooked[client])
    {
        SDKHook(client, SDKHook_OnTakeDamage, Silver_OnTakeDamage);
        g_bSilverDmgHooked[client] = true;
    }
    if (!g_bSilverPreThinkHooked[client])
    {
        SDKHook(client, SDKHook_PreThink, Silver_PreThink);
        g_bSilverPreThinkHooked[client] = true;
    }

    // PASIVA vida max 105 (una vez por vida)
    if (!g_bSilverMaxHpOn[client]) Silver_ApplyMaxHealth(client);

    // v2.4-OM: el vigía del muro del lanzamiento de la supresión
    Silver_WallWatchTick(client);

    bool draining = false;

    // ------------------ SUSPENSION: sosteniendo al objetivo ------------------
    if (g_iSilverSusp[client] == 3)
    {
        draining = true;
        int tgt = EntRefToEntIndex(g_iSilverGrabTarget[client]);
        bool valid = (tgt > 0 && IsValidEntity(tgt)
                      && (tgt > MaxClients || (IsClientInGame(tgt) && IsPlayerAlive(tgt)))
                      && (tgt <= MaxClients || GetEntProp(tgt, Prop_Data, "m_iHealth") > 0));
        // si alguien más lo aturdio: soltar (el Lua L594-597)
        if (valid && tgt <= MaxClients && OM_IsStunned(tgt)) valid = false;

        if (!valid)
        {
            Silver_ReleaseGrab(client);
        }
        else
        {
            // colgado en su punto, congelado (el SetPos del Lua cada think)
            float z[3] = { 0.0, 0.0, 0.0 };
            TeleportEntity(tgt, g_vSilverGrabPos[client], NULL_VECTOR, z);
            // drena 6/s (Lua: 0.6/tick)
            float dr = (g_cvSilverSuspDrain != null) ? g_cvSilverSuspDrain.FloatValue : 6.0;
            Silver_AddEnergy(client, -dr * 0.1);
            if (g_fSilverEnergy[client] <= 0.0) Silver_ReleaseGrab(client);
        }
    }

    // ------------------ ROCKS: orbitando ------------------
    if (g_iSilverRockCount[client] > 0)
    {
        draining = true;
        float self[3], fwd[3], right[3];
        GetClientAbsOrigin(client, self);
        float eye[3];
        GetClientEyeAngles(client, eye);
        GetAngleVectors(eye, fwd, right, NULL_VECTOR);

        int count = g_iSilverRockCount[client];
        float centerIdx = float(count + 1) * 0.5;    // (count+1)/2 del Lua

        for (int r = 0; r < count; r++)
        {
            int rock = EntRefToEntIndex(g_iSilverRocks[client][r]);
            if (rock <= 0 || !IsValidEntity(rock))
            {
                // murió sola (mapa/limpieza): sacarla del orbit
                for (int q = r; q < 2; q++) g_iSilverRocks[client][q] = g_iSilverRocks[client][q + 1];
                g_iSilverRocks[client][2] = 0;
                g_iSilverRockCount[client]--;
                r--; count--;
                continue;
            }
            // geometria del Lua: 50 atras, 60 entre ellas, 60 arriba
            // (la del medio +30 si son 3: height 90)
            float side = (float(r + 1) - centerIdx) * 60.0;
            float height = 60.0;
            if (count == 3 && r == 1) height = 90.0;

            float tp[3];
            tp[0] = self[0] - fwd[0] * 50.0 + right[0] * side;
            tp[1] = self[1] - fwd[1] * 50.0 + right[1] * side;
            tp[2] = self[2] + height;

            // lerp 8 (el Lua: LerpVector(FrameTime*8) — aquí tick 0.1)
            float cp[3];
            GetEntPropVector(rock, Prop_Data, "m_vecOrigin", cp);
            float k = 0.8;
            cp[0] += (tp[0] - cp[0]) * k;
            cp[1] += (tp[1] - cp[1]) * k;
            cp[2] += (tp[2] - cp[2]) * k;
            float na[3];
            GetClientAbsAngles(client, na);
            TeleportEntity(rock, cp, na, NULL_VECTOR);

            // glow pulsante cada 0.3s (el OM_tinyball del Lua)
            if (now >= g_fSilverRockNextGlow[client] && g_iSilverGlowSprite > 0)
            {
                TE_SetupGlowSprite(cp, g_iSilverGlowSprite, 0.25, 0.9, 150);
                TE_SendToAll();
                g_fSilverRockNextGlow[client] = now + 0.3;
            }
        }
        if (g_iSilverRockCount[client] == 0) Silver_RockCdCheck(client);
        else
        {
            // drena 1/s mientras orbitan (Lua: 0.1/tick)
            float dr = (g_cvSilverRockDrain != null) ? g_cvSilverRockDrain.FloatValue : 1.0;
            Silver_AddEnergy(client, -dr * 0.1);
            if (g_fSilverEnergy[client] <= 0.0)
            {
                // sin energía: las rocas se hunden y desaparecen (el sink del Lua)
                for (int r = 0; r < g_iSilverRockCount[client]; r++)
                {
                    int rock = EntRefToEntIndex(g_iSilverRocks[client][r]);
                    if (rock > 0 && IsValidEntity(rock)) AcceptEntityInput(rock, "Kill");
                    g_iSilverRocks[client][r] = 0;
                }
                g_iSilverRockCount[client] = 0;
                Silver_RockCdCheck(client);
            }
        }
    }

    // ------------------ TIME REVERSAL ------------------
    if (g_iSilverTRPhase[client] == 1)
    {
        draining = true;   // no regenera mientras graba
        if (now >= g_fSilverTRNext[client])
        {
            int maxR = (g_cvSilverTRMax != null) ? g_cvSilverTRMax.IntValue : 10;
            if (maxR > 10) maxR = 10;
            if (g_iSilverTRCount[client] >= maxR || g_fSilverEnergy[client] < 10.0)
            {
                g_iSilverTRPhase[client] = 2;   // a rebobinar
                g_fSilverTRNext[client] = 0.0;
            }
            else
            {
                // cada tick: -10 energía + sonido N + registro (Lua L806-830)
                Silver_AddEnergy(client, -10.0);
                int idx = g_iSilverTRCount[client];
                Silver_TRRecord(client);
                int sndIdx = SILVER_SND_TICK0 + idx;   // registro 1 -> tick 1, 2 -> tick 2...
                if (sndIdx > SILVER_SND_TICK9) sndIdx = SILVER_SND_TICK9;
                Silver_Snd(sndIdx, client);
                g_fSilverTRNext[client] = now + ((g_cvSilverTRTickDelay != null) ? g_cvSilverTRTickDelay.FloatValue : 1.0);
            }
        }
    }
    else if (g_iSilverTRPhase[client] == 2)
    {
        draining = true;
        if (now >= g_fSilverTRNext[client])
        {
            if (g_iSilverTRCount[client] <= 0)
            {
                // termino el rebobinado completo: cd corto (Lua: 15)
                g_iSilverTRPhase[client] = 0;
                g_fSilverTRCd[client] = now + ((g_cvSilverTRCdDone != null) ? g_cvSilverTRCdDone.FloatValue : 15.0);
            }
            else
            {
                // un salto hacia atras (0.09s por registro — Lua L762-797)
                g_iSilverTRCount[client]--;
                int slot = g_iSilverTRCount[client];
                float yaw = g_fSilverTRYaw[client][slot];
                float a[3];
                GetClientAbsAngles(client, a);
                a[1] = yaw;
                float z[3] = { 0.0, 0.0, 0.0 };
                TeleportEntity(client, g_vSilverTRPos[client][slot], a, z);
                // v2.4-OM: REGRESA CON LA VIDA QUE TENÍA — el rebobinado
                // restaura la vida del registro (solo si es MAYOR que la
                // actual: deshace el daño, JAMAS baja una cura)
                if (g_iSilverTRHp[client][slot] > GetClientHealth(client))
                    SetEntProp(client, Prop_Send, "m_iHealth", g_iSilverTRHp[client][slot]);
                Silver_Snd(SILVER_SND_RRRELEASE, client);
                g_fSilverTRNext[client] = now + 0.09;
            }
        }
    }

    // ------------------ LEVITACION: vuelo ------------------
    if (g_bSilverFlying[client] && OM_IsStunned(client))
        Silver_FlyEnd(client);   // aturdido volando: aterrizar (no pelear con el stun)

    if (g_bSilverFlying[client])
    {
        draining = true;
        // drena 9.4/s (Lua: 0.94 cada 0.1)
        float dr = (g_cvSilverFlyDrain != null) ? g_cvSilverFlyDrain.FloatValue : 9.4;
        g_fSilverFlyBar[client] -= dr * 0.1;
        if (g_fSilverFlyBar[client] < 0.0) g_fSilverFlyBar[client] = 0.0;

        if (g_fSilverFlyBar[client] <= 0.0)
        {
            Silver_FlyEnd(client);
            g_fSilverFlyCdUntil[client] = now + ((g_cvSilverFlyCd != null) ? g_cvSilverFlyCd.FloatValue : 8.0);
        }
        else
        {
            // vuelo hacia la MIRA (WASD libre; SHIFT = rápido — el
            // SpeedAccelerate 1.8/s del Lua, mapeado a 150/300 u/s)
            float eye[3], dir[3];
            GetClientEyeAngles(client, eye);
            GetAngleVectors(eye, dir, NULL_VECTOR, NULL_VECTOR);
            bool fast = ((GetClientButtons(client) & IN_SPEED) != 0);
            float spd = fast
                ? ((g_cvSilverFlySpeedFast != null) ? g_cvSilverFlySpeedFast.FloatValue : 300.0)
                : ((g_cvSilverFlySpeed      != null) ? g_cvSilverFlySpeed.FloatValue      : 150.0);
            float v[3];
            CopyVector(dir, v); ScaleVector(v, spd);
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, v);
            if (GetEntityFlags(client) & FL_ONGROUND) Silver_FlyEnd(client);
        }
    }
    else if (GetEntityFlags(client) & FL_ONGROUND)
    {
        // recarga en el suelo (0.44/tick — el 0.35/0.08s del Lua)
        float mx = (g_cvSilverFlyBar != null) ? g_cvSilverFlyBar.FloatValue : 20.0;
        if (g_fSilverFlyBar[client] < mx)
        {
            float rg = (g_cvSilverFlyRegen != null) ? g_cvSilverFlyRegen.FloatValue : 4.4;
            g_fSilverFlyBar[client] += rg * 0.1;
            if (g_fSilverFlyBar[client] > mx) g_fSilverFlyBar[client] = mx;
        }
    }

    // ------------------ regeneración de energía ------------------
    if (!draining)
    {
        float rg = (g_cvSilverEnergyRegen != null) ? g_cvSilverEnergyRegen.FloatValue : 5.0;
        Silver_AddEnergy(client, rg * 0.1);
    }
}

void Silver_FlyEnd(int client)
{
    if (!g_bSilverFlying[client]) return;
    g_bSilverFlying[client] = false;
    if (IsClientInGame(client)) SetEntityGravity(client, 1.0);
    if (g_bSilverLaggedZero[client])
    {
        g_bSilverLaggedZero[client] = false;
        if (IsClientInGame(client) && HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
    if (g_iSilverForceAnim[client] == SILVER_ST_FLYIDLE) g_iSilverForceAnim[client] = -1;
}

// SPACE en el aire = levitación (el edge del IN_JUMP — patron Cream)
public void Silver_PreThink(int client)
{
    if (!Silver_PlayerIs(client)) return;
    if (!IsPlayerAlive(client) || GetClientTeam(client) != 2) return;
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) { Silver_FlyEnd(client); return; }
    if (OM_IsStunned(client)) { Silver_FlyEnd(client); return; }
    if (g_iSilverTRPhase[client] != 0) return;
    if (g_iSilverSusp[client] != 0) return;
    if (g_iSilverRockCount[client] > 0) return;

    if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // la barra tiene que tener algo y el cd vencido
        if (g_fSilverFlyBar[client] <= 0.5) return;
        float now = GetEngineTime();
        if (now < g_fSilverFlyCdUntil[client]) return;

        if (g_bSilverFlying[client])
        {
            // 2a pulsación de SPACE = aterrizar el vuelo (el toggle del Lua)
            if ((GetClientButtons(client) & IN_JUMP) != 0) return;   // mantenida: sigue
            Silver_FlyEnd(client);
            return;
        }
        if ((GetClientButtons(client) & IN_JUMP) != 0)
        {
            // DESPEGUE (Lua L888-929)
            g_bSilverFlying[client] = true;
            g_bSilverLaggedZero[client] = true;
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0001);
            SetEntityGravity(client, 0.0);   // sin caida entre ticks de la FSM
            float z[3] = { 0.0, 0.0, 0.0 };
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, z);
            g_iSilverForceAnim[client] = SILVER_ST_FLYIDLE;
            Silver_Snd(SILVER_SND_FLYSTART, client);
        }
    }
    else if (g_bSilverFlying[client])
        Silver_FlyEnd(client);
}

// =====================================================================
// v2.0-OM: THINK DE LA ROCA LANZADA (30 Hz) — vuelo controlado
// aim*2500 con esfera 80 de detección (el RockThinking del Lua).
// =====================================================================
// v2.4-OM: EL VIGÍA DEL MURO — "si impacta con un muro dañara 200 de
// daño": tras el lanzamiento se vigila a la victima 1.2s (tick 0.1s desde
// el kit think): si venia a >300 u/s HORIZONTAL y la horizontal se cae de
// golpe CONSERVANDO la vertical = es PARED (el piso mata la vertical, la
// pared mata la horizontal) -> pega el daño del muro.
int   g_iSilverWallWatchRef[MAXPLAYERS + 1];
float g_vSilverWallPrevVel[MAXPLAYERS + 1][3];
int   g_iSilverWallWatchTicks[MAXPLAYERS + 1];

void Silver_WallWatchStart(int client, int tgt)
{
    if (tgt <= 0 || !IsValidEntity(tgt)) return;
    g_iSilverWallWatchRef[client]   = EntIndexToEntRef(tgt);
    g_iSilverWallWatchTicks[client] = 12;   // 1.2s a 0.1s
    GetEntPropVector(tgt, Prop_Data, "m_vecVelocity", g_vSilverWallPrevVel[client]);
}

void Silver_WallWatchTick(int client)
{
    if (g_iSilverWallWatchRef[client] == 0) return;
    int tgt = EntRefToEntIndex(g_iSilverWallWatchRef[client]);
    g_iSilverWallWatchTicks[client]--;
    if (tgt <= 0 || !IsValidEntity(tgt) || g_iSilverWallWatchTicks[client] <= 0)
    {
        g_iSilverWallWatchRef[client] = 0;
        return;
    }
    bool alive;
    if (tgt <= MaxClients) alive = IsClientInGame(tgt) && IsPlayerAlive(tgt);
    else alive = (GetEntProp(tgt, Prop_Data, "m_iHealth") > 0);
    if (!alive) { g_iSilverWallWatchRef[client] = 0; return; }

    float v[3];
    GetEntPropVector(tgt, Prop_Data, "m_vecVelocity", v);
    float prevH = g_vSilverWallPrevVel[client][0] * g_vSilverWallPrevVel[client][0]
                 + g_vSilverWallPrevVel[client][1] * g_vSilverWallPrevVel[client][1];
    float curH  = v[0] * v[0] + v[1] * v[1];
    if (prevH > 300.0 * 300.0 && curH < prevH * 0.16)
    {
        // impacto: la horizontal se desplomó con la vertical intacta = PARED
        float wd = (g_cvSilverSuspWallDmg != null) ? g_cvSilverSuspWallDmg.FloatValue : 200.0;
        if (wd > 0.0) OM_AbilityDamage(tgt, client, wd, DMG_OM_CLUB);
        g_iSilverWallWatchRef[client] = 0;
        return;
    }
    g_vSilverWallPrevVel[client][0] = v[0];
    g_vSilverWallPrevVel[client][1] = v[1];
    g_vSilverWallPrevVel[client][2] = v[2];
}

// v2.4-OM: aciertos de roca POR OBJETIVO (el stun grande es del 2do
// acierto sobre EL MISMO objetivo — ventana de 5s por victima; slots
// por EntRef, el patron del suite)
#define SILVER_ROCK_TGT_SLOTS 8
static int   g_iSilverRockTgtRef[SILVER_ROCK_TGT_SLOTS];
static int   g_iSilverRockTgtHits[SILVER_ROCK_TGT_SLOTS];
static float g_fSilverRockTgtAt[SILVER_ROCK_TGT_SLOTS];

int Silver_RockTargetHits(int victim)
{
    if (victim <= 0) return 0;
    int ref = EntIndexToEntRef(victim);
    float now = GetEngineTime();
    for (int s = 0; s < SILVER_ROCK_TGT_SLOTS; s++)
    {
        if (g_iSilverRockTgtRef[s] == 0 || g_iSilverRockTgtRef[s] != ref) continue;
        if (now - g_fSilverRockTgtAt[s] > 5.0) g_iSilverRockTgtHits[s] = 0;   // expiró la ventana
        return g_iSilverRockTgtHits[s];
    }
    return 0;
}

void Silver_RockTargetNote(int victim, int hits)
{
    if (victim <= 0) return;
    int ref = EntIndexToEntRef(victim);
    float now = GetEngineTime();
    int slot = -1;
    for (int s = 0; s < SILVER_ROCK_TGT_SLOTS; s++)
    {
        if (g_iSilverRockTgtRef[s] == ref) { slot = s; break; }
        if (g_iSilverRockTgtRef[s] == 0 && slot < 0) slot = s;
    }
    if (slot < 0)
    {
        int oldest = 0;   // sin slots: recicla el más viejo
        for (int s = 1; s < SILVER_ROCK_TGT_SLOTS; s++)
            if (g_fSilverRockTgtAt[s] < g_fSilverRockTgtAt[oldest]) oldest = s;
        slot = oldest;
    }
    g_iSilverRockTgtRef[slot]  = ref;
    g_iSilverRockTgtHits[slot] = hits;
    g_fSilverRockTgtAt[slot]   = now;
}

public Action T_SilverRockThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iSilverRockFlying[i] == 0) continue;
        int rock = EntRefToEntIndex(g_iSilverRockFlying[i]);
        if (rock <= 0 || !IsValidEntity(rock))
        {
            g_iSilverRockFlying[i] = 0;
            continue;
        }
        if (now >= g_fSilverRockDieAt[i])
        {
            AcceptEntityInput(rock, "Kill");
            g_iSilverRockFlying[i] = 0;
            continue;
        }
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) { AcceptEntityInput(rock, "Kill"); g_iSilverRockFlying[i] = 0; continue; }

        float rp[3];
        GetEntPropVector(rock, Prop_Data, "m_vecOrigin", rp);

        // objetivo: esfera 80 sobre la roca
        int victim = Silver_ScanEnemy(i, rp, 80.0);
        if (victim > 0)
        {
            // ACIERTO (Lua L1327-1372)
            g_iSilverRocksHit[i]++;
            float hs = (g_cvSilverRockHitStun != null) ? g_cvSilverRockHitStun.FloatValue : 0.5;
            float bigStun = (g_cvSilverRockStun != null) ? g_cvSilverRockStun.FloatValue : 3.0;

            // v2.4-OM: FIX DEL LANZAMIENTO DE ROCAS — "ahora causarán daño
            // de 125 a 250": cada roca que ACIERTA pega el aleatorio del
            // rango (antes 0). Las comunes de 50HP mueren AL INSTANTE con
            // cualquier tirada (125 ya las revienta). El stun grande pasa
            // del 3er acierto de la TANDA al 2do ACIERTO SOBRE EL MISMO
            // OBJETIVO (per-victima, ventana 5s)
            float dMin = (g_cvSilverRockDmgMin != null) ? g_cvSilverRockDmgMin.FloatValue : 125.0;
            float dMax = (g_cvSilverRockDmgMax != null) ? g_cvSilverRockDmgMax.FloatValue : 250.0;
            if (dMax < dMin) dMax = dMin;
            float dmg = GetRandomFloat(dMin, dMax);

            int tgtHits = Silver_RockTargetHits(victim) + 1;
            Silver_RockTargetNote(victim, tgtHits);

            if (tgtHits >= 2)
            {
                // 2+ rocas AL MISMO OBJETIVO: el OM_Stun grande (3s)
                OM_AbilityDamage(victim, i, dmg, DMG_OM_CLUB);
                if (victim <= MaxClients) OM_Stun(victim, bigStun, i, 0.0, DMG_OM_CLUB, false);
                else
                {
                    // común/witch/tank: el empujon del golpe (no hay stun para NPCs)
                    float eye[3], fwd[3], pv[3];
                    GetClientEyeAngles(i, eye);
                    GetAngleVectors(eye, fwd, NULL_VECTOR, NULL_VECTOR);
                    CopyVector(fwd, pv); pv[2] += 0.2;
                    ScaleVector(pv, 900.0);
                    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, pv);
                }
            }
            else
            {
                // 1a roca sobre este objetivo: el daño + el stagger corto
                OM_AbilityDamage(victim, i, dmg, DMG_OM_CLUB);
                if (victim <= MaxClients)
                    OM_Stun(victim, hs, i, 0.0, DMG_OM_CLUB, false);   // el "slow" del Lua -> stagger corto
                else
                {
                    // común: empujon corto (no hay stagger para NPCs)
                    float eye2[3], fwd2[3], pv2[3];
                    GetClientEyeAngles(i, eye2);
                    GetAngleVectors(eye2, fwd2, NULL_VECTOR, NULL_VECTOR);
                    CopyVector(fwd2, pv2); pv2[2] += 0.15;
                    ScaleVector(pv2, 450.0);
                    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, pv2);
                }
            }

            Silver_Snd(SILVER_SND_ROCKHIT, rock);
            EmitSoundToAll(SILVER_SND_CONCRETE, rock, SNDCHAN_AUTO, 90);   // el concrete_break2 del Lua
            if (g_iSilverGlowSprite > 0)
            {
                TE_SetupGlowSprite(rp, g_iSilverGlowSprite, 0.4, 1.5, 200);
                TE_SendToAll();
            }
            AcceptEntityInput(rock, "Kill");
            g_iSilverRockFlying[i] = 0;
            continue;
        }

        // pared delante?
        float vel[3];
        GetEntPropVector(rock, Prop_Data, "m_vecVelocity", vel);
        if (NormalizeVector(vel, vel) < 10.0)
        {
            AcceptEntityInput(rock, "Kill");
            g_iSilverRockFlying[i] = 0;
            continue;
        }
        {
            Handle tr = TR_TraceRayFilterEx(rp, vel, MASK_SOLID_BRUSHONLY, RayType_Infinite, Silver_RayFilter, rock);
            bool hitWorld = false;
            if (TR_DidHit(tr))
            {
                int hitEnt = TR_GetEntityIndex(tr);
                if (hitEnt == 0 || hitEnt > MaxClients) hitWorld = true;
            }
            delete tr;
            if (hitWorld)
            {
                AcceptEntityInput(rock, "Kill");
                g_iSilverRockFlying[i] = 0;
                continue;
            }
        }

        // sostener el vuelo (aim*2500 — el phys:SetVelocity del Lua)
        float eye[3], fwd[3];
        GetClientEyeAngles(i, eye);
        GetAngleVectors(eye, fwd, NULL_VECTOR, NULL_VECTOR);
        float spd = (g_cvSilverRockSpeed != null) ? g_cvSilverRockSpeed.FloatValue : 2500.0;
        float v[3];
        CopyVector(fwd, v); ScaleVector(v, spd);
        TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, v);
    }
    return Plugin_Continue;
}

// =====================================================================
// v2.0-OM: dano — el único caso: CANCEL del time reversal grabando
// (el EntityTakeDamage hook del Lua L1180-1201).
// =====================================================================
public Action Silver_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)) return Plugin_Continue;
    if (!Silver_PlayerIs(victim)) return Plugin_Continue;
    if (g_iSilverTRPhase[victim] != 1 && g_iSilverTRPhase[victim] != 2) return Plugin_Continue;

    // v2.4-OM: TIME REVERSAL YA NO SE INTERRUMPE POR DAÑO — "si este
    // recibe daño durante el time reversal, cuando este regrese regresará
    // con la vida que tenía hasta ese momento": el daño entra normal y el
    // REBOBINADO lo deshace al restaurar la vida del registro. La UNICA
    // forma de cancelarlo es un STAGGER de alguna forma — se chequea en
    // el frame siguiente (m_staggerDist > 0 = tambaleado por el motor).
    RequestFrame(Silver_TRStaggerCheck, GetClientUserId(victim));
    return Plugin_Continue;
}

// v2.4-OM: ¿el golpe lo dejó tambaleado (stagger)? la única cancelación
// del TR (cd 25, sonido de cancel del Lua)
public void Silver_TRStaggerCheck(any userid)
{
    int victim = GetClientOfUserId(view_as<int>(userid));
    if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)) return;
    if (g_iSilverTRPhase[victim] != 1 && g_iSilverTRPhase[victim] != 2) return;
    if (!HasEntProp(victim, Prop_Send, "m_staggerDist")) return;
    if (GetEntPropFloat(victim, Prop_Send, "m_staggerDist") > 0.0)
    {
        // stagger: cancel (Lua: Canceled -> cd 25)
        g_iSilverTRPhase[victim] = 0;
        g_iSilverTRCount[victim] = 0;
        g_fSilverTRCd[victim] = GetEngineTime() + ((g_cvSilverTRCd != null) ? g_cvSilverTRCd.FloatValue : 25.0);
        Silver_Snd(SILVER_SND_RRCANCEL, victim);
    }
}

// =====================================================================
// v2.0-OM: RESET del kit — muerte o cambio de personaje.
// =====================================================================
void Silver_ResetGameplay(int client, bool death)
{
    // soltar al agarrado
    Silver_ReleaseGrab(client);
    g_iSilverSusp[client] = 0;
    // rocas: fuera todas
    for (int r = 0; r < 3; r++)
    {
        if (g_iSilverRocks[client][r] != 0)
        {
            int rock = EntRefToEntIndex(g_iSilverRocks[client][r]);
            if (rock > 0 && IsValidEntity(rock)) AcceptEntityInput(rock, "Kill");
            g_iSilverRocks[client][r] = 0;
        }
    }
    if (g_iSilverRockFlying[client] != 0)
    {
        int rock = EntRefToEntIndex(g_iSilverRockFlying[client]);
        if (rock > 0 && IsValidEntity(rock)) AcceptEntityInput(rock, "Kill");
        g_iSilverRockFlying[client] = 0;
    }
    g_iSilverRockCount[client] = 0;
    g_iSilverRocksHit[client] = 0;
    g_fSilverRockCd[client] = 0.0;
    g_fSilverSuspCd[client] = 0.0;
    // time reversal
    g_iSilverTRPhase[client] = 0;
    g_iSilverTRCount[client] = 0;
    g_fSilverTRCd[client] = 0.0;
    // levitación
    Silver_FlyEnd(client);
    g_fSilverFlyCdUntil[client] = 0.0;
    g_fSilverFlyBar[client] = (g_cvSilverFlyBar != null) ? g_cvSilverFlyBar.FloatValue : 20.0;
    // energía: al valor de spawn (100 por el Lua)
    if (death || g_bSilverMaxHpOn[client])
    {
        g_fSilverEnergy[client] = (g_cvSilverEnergyOnSpawn != null) ? g_cvSilverEnergyOnSpawn.FloatValue : 100.0;
    }
    // vida max de vuelta al 100 SOLO en muerte/cambio (la incap la conserva)
    if (death) Silver_RestoreMaxHealth(client);
    g_iSilverForceAnim[client] = -1;
    Silver_AvatarTint(client, false);
}

// MUERTE DEL AVATAR — ragdoll silver.mdl + filtro anti-corpse
// (receta Rouge v10.2 / Knuckles v75 / Metal v5.0 / Shadow v6.0 /
// Cream v7.0)
// =====================================================================
void Silver_SpawnDeathRagdoll(int client)
{
    if (!g_bSilverModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", SILVER_OM_MODEL);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    CreateTimer(15.0, T_SilverDeathRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_SilverDeathRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Filtro anti-ragdoll (patron Rouge/Sonic/Knuckles/Shadow/Cream —
// enrutado por el OnEntityCreated central de Rouge.inc, que despacha
// a este modulo)
public void Silver_CheckDeathRagdoll(any ref)
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
        if (g_fSilverDeathHideUntil[i] == 0.0 || now >= g_fSilverDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_vSilverDeathOrigin[i]) < 200.0)
        {
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}

// v3.77.69: dispatch del OnEntityCreated central de Rouge.inc — la
// ventana anti-corpse de las muertes de la Silver con avatar
public void Silver_OnEntityCreated(int entity, const char[] classname)
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
            if (g_fSilverDeathHideUntil[i] == 0.0 || nowOM >= g_fSilverDeathHideUntil[i])
                continue;
            RequestFrame(Silver_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }
}

// LA MUERTE DEL AVATAR (hook POST propio — la lección Rouge v3.77.49:
// ni el PRE ni el POST del manager tocan el avatar de Silver; TODO pasa
// aquí: ragdoll + ventana anti-corpse + KillAvatarOnly. La lección
// Sonic v3.76.2: en PRE el restore dejaba ver el corpse del survivor.)
public void Silver_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0) return;

    if (Silver_PlayerIs(client))
    {
        // v2.0-OM: el kit se resetea con la muerte (energía al spawn, vida al 100)
        Silver_ResetGameplay(client, true);

        if (g_iSilverAvatar[client] != 0)
        {
            Silver_SpawnDeathRagdoll(client);
            g_fSilverDeathHideUntil[client] = GetEngineTime() + 2.0;
            GetClientAbsOrigin(client, g_vSilverDeathOrigin[client]);
            Silver_KillAvatarOnly(client);   // el cuerpo vuelve a verse para el spectate/revive
        }
    }
}

// v1.0-OM: limpieza al DESCARGAR el plugin (OnPluginEnd del manager) —
// aquí SI se mata el avatar con restore del cuerpo (no murió nadie: el
// plugin se va). SIN ragdoll.
public void Silver_OnPluginEnd(int client)
{
    if (client < 1 || client > MaxClients) return;
    Silver_KillAvatar(client);
}

// v1.0-OM: refs a cero al cerrar el mapa (las entidades murieron con el;
// el timer de la FSM es NO_MAPCHANGE y muere solo)
public void Silver_OnMapEnd()
{
    delete g_hSilverAvatarThink;
    delete g_hSilverRockThink;     // v2.0-OM: el think de la roca también
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iSilverAvatar[i] = 0;
        g_iSilverAvatarL[i] = 0;
        g_iSilverAnimState[i] = -1;
        g_fSilverDeathHideUntil[i] = 0.0;
        // v2.0-OM: el kit entero a cero (refs de rocas incluidas)
        g_iSilverRocks[i][0] = 0; g_iSilverRocks[i][1] = 0; g_iSilverRocks[i][2] = 0;
        g_iSilverRockFlying[i] = 0;
        g_iSilverRockCount[i] = 0;
        g_iSilverGrabTarget[i] = 0;
        g_iSilverSusp[i] = 0;
        g_iSilverTRPhase[i] = 0;
        g_iSilverTRCount[i] = 0;
        g_bSilverFlying[i] = false;
        g_bSilverLaggedZero[i] = false;
        g_iSilverForceAnim[i] = -1;
        g_bSilverMaxHpOn[i] = false;
        g_fSilverEnergy[i] = 0.0;
        g_fSilverFlyBar[i] = 0.0;
        g_fSilverSuspCd[i] = 0.0;
        g_fSilverRockCd[i] = 0.0;
        g_fSilverTRCd[i] = 0.0;
        g_fSilverFlyCdUntil[i] = 0.0;
    }
}

// =====================================================================
// =====================================================================
// v2.2-OM: LA BARRA DE VUELO — el estado para el motor SBar del
// manager 3.77.81 (pedido del owner: "...silver para su vuelo").
// La flyingBar del Lua (OM_Fleetway_flyingBar 0-20): drena 9.4/s
// levitando (SPACE en el aire), se recarga en el suelo y al vaciarse
// deja 8s de cd (silver_fly_cd). El panel KeyHintText sigue mostrando
// la ENERGÍA (0-100) — la barra es del VUELO.
// =====================================================================
bool Silver_BarState(int client)
{
    float mx = (g_cvSilverFlyBar != null) ? g_cvSilverFlyBar.FloatValue : 20.0;
    if (mx < 1.0) mx = 20.0;
    float f = g_fSilverFlyBar[client];
    if (f < 0.0) f = 0.0;
    if (f > mx) f = mx;
    float now = GetEngineTime();
    bool cd = (now < g_fSilverFlyCdUntil[client]);

    SBar_Clear();
    g_fSBarFrac = f / mx;
    g_iSBarNum  = RoundToFloor(f);
    g_iSBarDen  = RoundToFloor(mx);
    strcopy(g_sSBarLabel, sizeof(g_sSBarLabel), "VUELO");

    bool empty = (f < 0.5);
    if (empty)                          g_bSBarBlink = true;                          // VACÍA: rojo-gris
    else if (g_bSilverFlying[client]) { g_iSBarChatColor = SBAR_CHAT_LIGHTGR; }   // volando — chat: verde claro
    else if (cd)                       { g_iSBarChatColor = SBAR_CHAT_GREEN;   }   // llena PERO en cd — chat: AMARILLO recargando
    else if (g_fSBarFrac < 0.25)       { g_iSBarChatColor = SBAR_CHAT_OLIVE;   }   // poca carga — chat: oliva
    else                               { g_iSBarChatColor = SBAR_CHAT_LIGHTGR; }   // lista / recargando — chat: verde claro

    if (g_bSilverFlying[client])      strcopy(g_sSBarTag, sizeof(g_sSBarTag), "LEVITANDO!");
    else if (cd)   Format(g_sSBarTag, sizeof(g_sSBarTag), "RECARGA %.0fs", g_fSilverFlyCdUntil[client] - now);
    else if (empty) strcopy(g_sSBarTag, sizeof(g_sSBarTag), "VACÍA!");
    return true;
}

// v2.1-OM: LÍNEA DEL PANEL DE ESTADOS — el manager 3.77.72 la pinta en// v2.1-OM: LÍNEA DEL PANEL DE ESTADOS — el manager 3.77.72 la pinta en
// el KeyHintText SIEMPRE VISIBLE. Energía, barra de levitación, rocas
// orbitando, fases activas y cooldowns Z/X/C + SPACE.
// =====================================================================
void Silver_HUDLine(int client, char[] out, int maxlen, float now)
{
    int n = 0;
    int en = RoundToFloor(g_fSilverEnergy[client]);

    n += Format(out[n], maxlen - n, "SILVER  ENERGÍA %d/100", en);

    if (g_iSilverSusp[client] == 3 && n < maxlen - 24)
        n += Format(out[n], maxlen - n, "  [AGARRE!]");
    if (g_iSilverTRPhase[client] == 1 && n < maxlen - 28)
        n += Format(out[n], maxlen - n, "  [GRABANDO %d]", g_iSilverTRCount[client]);
    else if (g_iSilverTRPhase[client] == 2 && n < maxlen - 24)
        n += Format(out[n], maxlen - n, "  [REBOBINANDO]");
    if (g_bSilverFlying[client] && n < maxlen - 36)
        n += Format(out[n], maxlen - n, "  [LEVITACION %.0f]", g_fSilverFlyBar[client]);

    if (n < maxlen - 44)
    {
        n += Format(out[n], maxlen - n, "\nZ Suspensión: ");
        if (g_iSilverSusp[client] != 0)
            n += Format(out[n], maxlen - n, "ACTIVA");
        else if (now < g_fSilverSuspCd[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fSilverSuspCd[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTA");
    }
    if (n < maxlen - 40)
    {
        n += Format(out[n], maxlen - n, "\nX Rocks: ");
        if (g_iSilverRockCount[client] > 0)
            n += Format(out[n], maxlen - n, "%d orbitando", g_iSilverRockCount[client]);
        else if (now < g_fSilverRockCd[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fSilverRockCd[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTA");
    }
    if (n < maxlen - 44)
    {
        n += Format(out[n], maxlen - n, "\nC TimeRev: ");
        if (g_iSilverTRPhase[client] != 0)
            n += Format(out[n], maxlen - n, "ACTIVO");
        else if (now < g_fSilverTRCd[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fSilverTRCd[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTA");
    }
    if (n < maxlen - 56)
    {
        n += Format(out[n], maxlen - n, "\nSPACE Levitar: ");
        if (g_bSilverFlying[client])
            n += Format(out[n], maxlen - n, "volando");
        else if (now < g_fSilverFlyCdUntil[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fSilverFlyCdUntil[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTA (%.0f/20)", g_fSilverFlyBar[client]);
    }
}
