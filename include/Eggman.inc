/*
 * ======================================================
 *  [MODULO] Dr. Eggman - The Genius Tactician v4.0-OM (SU AVATAR)
 *
 *  v4.0-OM (con manager 3.77.69, orden del owner: "hay que añadir
 *  ahora el avatar de baze silver y el dr eggman") — 9o AVATAR DEL
 *  SUITE, patron Cream v7.0-OM / Shadow v6.0 textual adaptado al
 *  kit de Eggman:
 *   - eggman.mdl del VPK de recursos (models/Noodles/OM/: el mismo
 *     pack OM de los otros 8 avatares). Detección FileExists estilo
 *     star_stun: si el archivo no está montado, TODO cae al survivor
 *     normal, CERO dependencia (y una línea en el log del server lo
 *     dice al arrancar el mapa).
 *   - Copia R (la ven los demas) + copia L (la dueña) + cuerpo
 *     oculto + FSM 10 Hz + ragdoll de muerte 15s + anti-corpse 2s +
 *     adopción de huerfanos + pulso de pausa.
 *   - FSM POR PROBE (receta Amy v92): idle/walk/run/jump/fall +
 *     variantes lowhealth (HP<=40) + downed + ONE-SHOTS de las DOS
 *     habilidades (Badnik Mines al desplegar / Death Egg Laser con
 *     lock que cubre la carga de 2s + disparo) y DEL JET (el doble
 *     salto aéreo tiene su pose — hover/jet si el .mdl la trae).
 *   - La MUERTE del avatar en el POST propio del modulo (lección
 *     Rouge v3.77.49: Eggman_OnPlayerDeath queda en puro reset).
 *   - Convar nuevo: eggman_avatar 1.
 *
 *  v3.1 (con manager 3.77.8) - FIN DE LA AUTO-GENERACION INDIVIDUAL:
 *   - Eliminado el AutoExecConfig("Eggman_Abilities") — el cfg
 *     individual se generaba con TODOS los cvars del plugin entero
 *     ("ConVars for plugin Sonic_ability_manager.smx"), o sea la
 *     MISMA lista que Sonic_Suite.cfg: duplicado puro que además
 *     pisaba valores al ejecutarse. Los cvars de Eggman ya viven en
 *     la config única Sonic_Suite.cfg (v3.75, auto-guardada).
 *   - El manager 3.77.8 además BORRA los cfg residuales del server
 *     (SuiteCfg_DeleteLegacyFiles).
 *
 *  v3.0 CHANGES (REWORK COMPLETO):
 *   - ELIMINADO: "Eggman Air Support" (avion C-130 flotando a 800 u):
 *     * El modelo airplane_jets.mdl se veía con texturas rotas/negras
 *     * Era 100% visual: no aportaba NADA útil al jugador
 *     * Gastaba 1 entidad + TeleportEntity en PreThink cada frame
 *     * El hook SDKHook_PreThink se elimina entero (rendimiento)
 *
 *   - ELIMINADO: penalización -10% velocidad permanente. Era una
 *     desventaja neta (lento SIEMPRE a cambio de nada). Además pisaba
 *     m_flLaggedMovementValue cada frame y CHOCABA con otros sistemas
 *     (Speed_sonic x2.5, Sonic Hero Mode x1.5, staggers de SI).
 *
 *   - NUEVA PASIVA: "EGGMOBILE JET" (doble salto real)
 *     * Pulsar SALTO de nuevo EN EL AIRE dispara el jet del Eggmobile
 *     * Impulso vertical configurable (def. +320) + empuje frontal
 *     * FX: burst de energía + chispas + anillo + sonido eléctrico
 *     * Cooldown corto (2s); 1 jet por salto (reset al aterrizar)
 *     * Guardas: no en incap, no agarrado (pounce/tongue/jockey/pummel/
 *       carry), no colgando de borde, no en escalera
 *
 *   - PASIVAS MANTENIDAS:
 *     * Inmunidad a dano de caida (el Eggmobile flota)
 *     * Inmunidad a acido/veneno/radiación (flota sobre charcos)
 *
 *   - BADNIK MINES v2 (pulidas):
 *     * Glow rojo visible (env_sprite additive parented a la mina)
 *     * Mina congelada (DisableMotion): queda plantada donde se pone
 *     * Detección con 1 timer GLOBAL (0.25s) en vez de 1 timer + DataPack
 *       POR MINA (antes: hasta 3 timers + FindEntityByClassname x3 cada
 *       0.2s por mina)
 *     * ArrayList por bloques {mina, sprite, owner} -> limpieza total
 *     * El dano en área ahora también afecta a la witch
 *     * Auto-kill garantizado de mina (15s) y sprite (16s) vía OnUser1
 *
 *   - DEATH EGG LASER v2 (pulido):
 *     * Telegrafiado: durante la carga de 2s se marca la zona de impacto
 *       (anillo pulsante rojo + haz vertical de aviso + blips sonoros)
 *     * Al disparar: doble haz + explosión + stagger (como antes)
 *
 *  Rol: Control de Área / Comandante tecnologico
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
#define EGGMAN_LASER_CD     20.0    // v5.2-OM: 40 -> 20 (pedido del owner)
#define EGGMAN_LASER_CHARGE  2.0    // Tiempo de carga del laser
#define EGGMAN_LASER_PULSES  8      // Blips de telegrafo durante la carga

// Doble salto (pasiva)
#define EGGMAN_JET_FORCE_DEF    550.0   // v5.1-OM: MÁS POTENCIA pasiva (pedido del owner: "el doble salto debe ganar más postencia ya pasivamente"; el Lua traía 400)
#define EGGMAN_JET_FORWARD_DEF  0.0     // v5.0-OM: el Lua MANTIENE la velocidad horizontal actual (era 200)
#define EGGMAN_JET_CD_DEF       10.0    // v5.0-OM: el Lua L641: JetpackJumpCooldown 10 (era 2)

// Minas
#define EGGMAN_MINE_TRIGGER 80.0    // Radio de activación por proximidad
#define EGGMAN_MINE_DMG_R   200.0   // Radio del dano en área
#define EGGMAN_MINE_LIFE    15.0    // Vida de la mina si nadie la pisa
#define EGGMAN_MAX_MINE_BLOCKS 24   // Max de bloques {mina,sprite,owner} en el ArrayList

// =======================
// Variables Globales
// =======================
float g_fEggmanMinesCD[MAXPLAYERS + 1];
float g_fEggmanLaserCD[MAXPLAYERS + 1];

// Pasiva: Eggmobile Jet (doble salto)
bool  g_bEggmanJetReady[MAXPLAYERS + 1];    // Recargado al tocar suelo/escalera
float g_fEggmanJetNext[MAXPLAYERS + 1];     // Tiempo del próximo jet permitido
int   g_iEggmanLastButtons[MAXPLAYERS + 1]; // Detección de flanco de IN_JUMP

// Minas activas: ArrayList PLANO (blocksize=1) usado como bloques lógicos de
// 3 celdas {mineRef, spriteRef, ownerUserId}. Se borran celda a celda en
// orden DESCENDENTE (semantica 100% portable entre includes viejos y nuevos).
#define EGGMAN_MINE_BLOCK 3
ArrayList g_hEggmanActiveMines = null;

// Fuegos activos (refs simples)
ArrayList g_hEggmanActiveFires = null;

// Sprites cacheados
int g_iEggmanBeamSprite = -1;
int g_iEggmanGlowSprite = -1;

// =======================
// v4.0-OM: AVATAR ESPEJO EGGMAN.MDL (9o avatar del suite)
// =======================
#define EGGMAN_INC_VERSION    "v5.2-OM"   // v5.2: EL ZAPPER + EL ESCUDO QUE STUNEA + EL LASER MAS RAPIDO (pedido del owner 2026-10-17, ronda 2): (1) DEATH EGG LASER: cooldown 40 -> 20 [eggman_laser_cd 20], area de impacto 400 -> 450 [eggman_laser_radius] y SONIDO DE EXPLOSION DE VERDAD (el explode_1.wav era contenido HL2 que L4D2 NO trae = se oia NADA — ahora el de la pipe bomb del PROPIO L4D2, espacial en el punto de impacto); (2) LAS BADNIK MINES SON AHORA EL ZAPPER: un rayo tipo Tails que DAÑA y RALENTIZA a los zombies — 250-450 por segundo [eggman_zapper_dps_min/max], ATRAVIESA a los comunes MATANDOLOS AL INSTANTE, a los SI los frena [eggman_zapper_slow 0.35] durante [eggman_zapper_duration 3.0]s (mismo keybind y mismo cd eggman_mines_cd 18; eggman_mine_damage queda DEPRECATED); (3) EL ESCUDO REWORK: stunea al atacante 3.5s [eggman_shield_stun 3.5; tank 2.5s por eggman_shield_stun_tank] + RAGDOLL volador hacia atras [Sonic_SpawnFlingRagdollEx — la receta Rouge v10.5] + 5% de vida max como daño [eggman_shield_hitdmg 0.05; tank 2%] + soporta HASTA 3 IMPACTOS de especiales [eggman_shield_maxhits 3 — al 3ro POP]; los COMUNES NO ROMPEN el escudo (bloqueados en silencio, sin contar); inmune a VOMITO de boomer y spitter mientras dura [Eggman_VomitShield en el dispatcher de Knuckles.inc; el acido de la spitter ya estaba bloqueado 24/7]; y si lo agarra hunter/jockey/smoker: el especial RECIBE el stun directamente y el doctor queda LIBRE [Eggman_CheckGrabCure] — Eggman es INMUNE a agarres DE POR SI como Metal Sonic [Eggman_ControlImmune en los dispatchers de sonic.inc] | v5.1: EL ESCUDO BLOQUEA DE VERDAD (L4D2 manda muchas garras con damagetype 0 — ahora cubre el melee real) + stun del atacante DIFERIDO con RequestFrame (lección Amy v106: nada de dano dentro del hook de dano) + BOOST a 650 u/s de velocidad OBJETIVO (eggman_boost_target, pedido del owner) + doble salto con MÁS potencia (vz 550) + línea del PANEL DE ESTADOS
#define EGGMAN_OM_MODEL       "models/Noodles/OM/eggman.mdl"
#define EGGMAN_AVATAR_NAME    "eggman_avatar_om"
#define EGGMAN_AVATAR_NAME_L  "eggman_avatar_om_l"

// FSM de animación — los nombres se RESUELVEN contra el .mdl real por
// PROBE (receta Amy v92 / Shadow v6.0 / Cream v7.0): cada estado tiene
// una CADENA de candidatos y gana el primero que exista en el modelo;
// los que falten caen a su estado base (nunca T-pose)
#define EGGMAN_ST_IDLE         0
#define EGGMAN_ST_WALK         1
#define EGGMAN_ST_RUN          2
#define EGGMAN_ST_JUMP         3    // one-shot con ventana (receta Rouge)
#define EGGMAN_ST_FALL         4
#define EGGMAN_ST_IDLE_LOW     5    // lowhealth (HP <= 40)
#define EGGMAN_ST_WALK_LOW     6
#define EGGMAN_ST_RUN_LOW      7
#define EGGMAN_ST_DOWNED_IDLE  8    // incap
#define EGGMAN_ST_DOWNED_WALK  9
#define EGGMAN_ST_JET          10   // one-shot: Eggmobile Jet (doble salto)
#define EGGMAN_ST_MINES        11   // one-shot: Badnik Mines
#define EGGMAN_ST_LASER        12   // one-shot: Death Egg Laser (carga+disparo)
#define EGGMAN_ST_BOOST        13   // v5.0-OM: Jetpack Boost sostenido (el run del Lua)
#define EGGMAN_ANIM_COUNT      14
#define EGGMAN_SEQ_MAX_CAND    6

#define EGGMAN_LOWHP           40     // umbral de las variantes lowhealth

#define EGGMAN_LOCK_JET        0.7    // FSM quieta durante el boost del jet
#define EGGMAN_LOCK_MINES      1.0    // FSM quieta durante el despliegue
#define EGGMAN_LOCK_LASER      2.2    // FSM quieta durante la carga (2s) + disparo

// cadena de candidatos por estado (nombres GMod + variantes)
static const char g_sEggmanSeqCand[EGGMAN_ANIM_COUNT][EGGMAN_SEQ_MAX_CAND][24] = {
    { "idle",            "Idle",           "idle01",       "Idle01",       "",       ""        },  // 0
    { "walk",            "Walk",           "walk01",       "WalkAll",      "",       ""        },  // 1
    { "run",             "Run",            "run01",        "RunAll",        "RunTopSpeed", ""  },  // 2
    { "jump",            "Jump",           "Jump2",        "jumpv",         "",       ""        },  // 3
    { "fall",            "Fall",           "glide",        "",              "",       ""        },  // 4
    { "idle_lowhealth",  "IdleLowHealth",  "idle_low",     "IdleLow",       "hurt",   ""        },  // 5
    { "walk_lowhealth",  "WalkLowHealth",  "walk_low",     "",              "",       ""        },  // 6
    { "run_lowhealth",   "RunLowHealth",   "run_low",      "",              "",       ""        },  // 7
    { "DownedIdle",      "downedidle",     "downed_idle",  "",              "",       ""        },  // 8
    { "DownedWalk",      "downedwalk",     "downed_walk",  "",              "",       ""        },  // 9
    { "jet",             "Jet",            "jetboost",     "hover",         "Hover",  "fly"     },  // 10
    { "plant",           "deploy",         "Deploy",       "throw",         "attack", "Attack"   },  // 11
    { "laser",           "Laser",          "cast",         "Cast",          "attack", "shoot"    },  // 12
    { "Jetpack",         "jetpack",        "jet",          "jetboost",      "run",    ""        }   // 13 v5.0-OM (el run del boost)
};

ConVar g_cvEggmanAvatar;
bool   g_bEggmanModelOK     = false;   // eggman.mdl en el VPK montado
bool   g_bEggmanSeqResolved = false;   // el probe ya corrio en este mapa
Handle g_hEggmanAvatarThink = null;    // FSM 10 Hz
int    g_iEggmanAvatar[MAXPLAYERS + 1];      // EntRef copia R (0 = sin avatar)
int    g_iEggmanAvatarL[MAXPLAYERS + 1];     // EntRef copia L
int    g_iEggmanBodyRender[MAXPLAYERS + 1];  // render ORIGINAL del survivor
int    g_iEggmanAnimState[MAXPLAYERS + 1];   // estado FSM actual
float  g_fEggmanAnimLock[MAXPLAYERS + 1];    // lock de one-shot en curso
float  g_fEggmanJumpStart[MAXPLAYERS + 1];   // t0 de la ventana del jump
float  g_fEggmanBodyYaw[MAXPLAYERS + 1];     // yaw suavizado del avatar
float  g_fEggmanYawLastT[MAXPLAYERS + 1];
bool   g_bEggmanSmSnap[MAXPLAYERS + 1];
float  g_fEggmanSmLoc[MAXPLAYERS + 1][3];
float  g_fEggmanSmLocL[MAXPLAYERS + 1][3];
float  g_fEggmanDeathHideUntil[MAXPLAYERS + 1];   // ventana anti-corpse
float  g_vEggmanDeathOrigin[MAXPLAYERS + 1][3];
char   g_sEggmanSeq[EGGMAN_ANIM_COUNT][24];       // nombre RESUELTO por estado
bool   g_bEggmanSeqOK[EGGMAN_ANIM_COUNT];        // el estado resolvo?

// ConVars
ConVar g_cvEggmanMinesCD, g_cvEggmanLaserCD;
ConVar g_cvEggmanMineDamage, g_cvEggmanLaserDamage;
ConVar g_cvEggmanJetEnable, g_cvEggmanJetForce, g_cvEggmanJetForward, g_cvEggmanJetCD;
// v5.0-OM: BOOST + ESCUDO del Lua (survivors2_eggman L240-664) — declaraciones
ConVar g_cvEggBoostCd, g_cvEggBoostTime, g_cvEggBoostSpeed, g_cvEggBoostTarget;
ConVar g_cvEggShieldCd, g_cvEggShieldCdPop, g_cvEggShieldTime, g_cvEggShieldBlockExt, g_cvEggShieldStun;
// v5.2-OM: el escudo que stunea + el zapper + el laser rapidito
ConVar g_cvEggShieldMaxHits, g_cvEggShieldHitDmg, g_cvEggShieldHitDmgTank;
ConVar g_cvEggShieldStunTank, g_cvEggShieldPush;
ConVar g_cvEggmanLaserRadius;
ConVar g_cvEggZapDpsMin, g_cvEggZapDpsMax, g_cvEggZapDuration, g_cvEggZapSlow;
float g_fEggBoostUntil[MAXPLAYERS + 1];
float g_fEggBoostCdUntil[MAXPLAYERS + 1];
float g_fEggBoostNextGlow[MAXPLAYERS + 1];
bool  g_bEggBoostOn[MAXPLAYERS + 1];
float g_fEggShieldUntil[MAXPLAYERS + 1];
float g_fEggShieldCdUntil[MAXPLAYERS + 1];
bool  g_bEggShieldOn[MAXPLAYERS + 1];
bool  g_bEggShieldPopped[MAXPLAYERS + 1];
// v5.2-OM: el estado del escudo rework + del zapper
int   g_iEggShieldHits[MAXPLAYERS + 1];       // impactos absorbidos (0..maxhits)
int   g_iEggShieldHitRef[MAXPLAYERS + 1];     // atacante del paquete diferido (EntRef)
bool  g_bEggZapActive[MAXPLAYERS + 1];       // el zapper está disparando
float g_fEggZapEndAt[MAXPLAYERS + 1];        // fin del rayo del zapper
float g_fEggZapSlowUntil[MAXPLAYERS + 1];    // por-VICTIMA: fin del frenado del zapper
Handle g_hEggZapTimer[MAXPLAYERS + 1];       // el tick del rayo (0.1s)
float g_fEggJetNoBoostUntil[MAXPLAYERS + 1];   // 'Eggman_jetpackdisabled' (1s tras el escudo)
int   g_iEggForceAnim[MAXPLAYERS + 1];         // -1 = FSM normal
// voicelines del fin de persecución (el 'PeelOut_saidoutahere' del Lua)
bool  g_bEggChaseNear[MAXPLAYERS + 1];
bool  g_bEggChaseWasNear[MAXPLAYERS + 1];
float g_fEggChaseNextCheck[MAXPLAYERS + 1];
// sonidos (probe dual)
#define EGG_SND_COUNT 18
static const char g_sEggSnd[EGG_SND_COUNT][] = {
    "om/eggman/jetpack boost activation layer 1.wav",
    "om/eggman/jetpack boost activation layer 2.wav",
    "om/eggman/eggman double jump.wav",
    "om/eggman/shieldactivation.wav",
    "om/eggman/shield popping.wav",
    "om/eggman/shield deactivated new.wav",
    "om/eggman/voiceline/eggmanshieldvoice1.wav",
    "om/eggman/voiceline/eggmanshieldvoice2.wav",
    "om/eggman/voiceline/eggmanshieldvoice3.wav",
    "om/eggman/voiceline/eggmanendsachase (1).wav",
    "om/eggman/voiceline/eggmanendsachase (2).wav",
    "om/eggman/voiceline/eggmanendsachase (3).wav",
    "om/eggman/voiceline/eggmanendsachase (4).wav",
    "om/eggman/voiceline/eggmanendsachase (5).wav",
    "om/eggman/voiceline/eggmanendsachase (6).wav",
    "om/eggman/voiceline/eggmanendsachase (7).wav",
    "om/eggman/voiceline/eggmanendsachase (8).wav",
    "om/eggman/voiceline/eggmanendsachase (9).wav"
};
#define EGG_SND_BOOST1     0
#define EGG_SND_BOOST2     1
#define EGG_SND_DJUMP      2
#define EGG_SND_SHACT      3
#define EGG_SND_SHPOP      4
#define EGG_SND_SHOFF      5
#define EGG_SND_SHVOICE    6   // 6..8
#define EGG_SND_CHASE      9   // 9..17
char g_sEggSndUse[EGG_SND_COUNT][96];
bool g_bEggSndOK[EGG_SND_COUNT];

#define Eggman_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))
#define Eggman_IsValidEntity(%1) (IsValidEntity(%1) && (%1) != INVALID_ENT_REFERENCE)

// =======================
// Inicialización
// =======================

public void Eggman_OnPluginStart()
{
    // ConVars (se mantienen los nombres originales para respetar cfgs)
    g_cvEggmanMinesCD     = CreateConVar("eggman_mines_cd", "18.0", "Cooldown de Badnik Mines", _, true, 0.0, true, 120.0);
    g_cvEggmanLaserCD     = CreateConVar("eggman_laser_cd", "20.0", "Cooldown de Death Egg Laser [v5.2: 40 -> 20, pedido del owner]", _, true, 0.0, true, 300.0);
    g_cvEggmanMineDamage  = CreateConVar("eggman_mine_damage", "200.0", "DEPRECATED v5.2: las Badnik Mines son ahora EL ZAPPER (eggman_zapper_*). Registrado para no ensuciar el Sonic_Suite.cfg — YA SIN EFECTO", _, true, 0.0, true, 5000.0);
    g_cvEggmanLaserRadius = CreateConVar("eggman_laser_radius", "450",
        "v5.2: area de impacto del Death Egg Laser (antes 400 fijo)", _, true, 50.0, true, 2000.0);
    g_cvEggmanLaserDamage = CreateConVar("eggman_laser_damage", "600.0", "Dano del laser", _, true, 0.0, true, 5000.0);

    // v3.0: ConVars del nuevo doble salto
    g_cvEggmanJetEnable   = CreateConVar("eggman_jet_enable", "1", "Habilita la pasiva Eggmobile Jet (doble salto)", _, true, 0.0, true, 1.0);
    g_cvEggmanJetForce    = CreateConVar("eggman_jet_force", "550.0", "v5.1-OM: potencia del doble salto pasivo (vz; el Lua traía 400 — pedido del owner: más potencia)", _, true, 100.0, true, 1000.0);
    g_cvEggmanJetForward  = CreateConVar("eggman_jet_forward", "0.0", "v5.0-OM: el Lua MANTIENE la velocidad horizontal (0 = sin empuje extra)", _, true, 0.0, true, 600.0);
    g_cvEggmanJetCD       = CreateConVar("eggman_jet_cd", "10.0", "v5.0-OM: el Lua: JetpackJumpCooldown 10", _, true, 0.0, true, 30.0);

    // v5.0-OM: BOOST + ESCUDO (los del Lua survivors2_eggman)
    g_cvEggBoostCd    = CreateConVar("eggman_boost_cd",    "22",   "Lua: JetpackBoostcooldown 22");
    g_cvEggBoostTime  = CreateConVar("eggman_boost_time",  "3.75", "Lua: JetpackBoost 3.75s");
    g_cvEggBoostSpeed = CreateConVar("eggman_boost_speed",  "2.0",  "Lua: run 412->1400 = x3.4 alla; L4D2: 2.0x es el techo comodo (SOLO se usa si eggman_boost_target = 0)");
    // v5.1-OM: velocidad OBJETIVO del boost — pedido del owner: "la
    // habilidad de velocidad de egman debería aumentar la velocidad así
    // como el Speed aumentar su velocidad a 650". El multiplicador
    // lagged se calcula SOLO contra la velocidad max real (220 base).
    g_cvEggBoostTarget = CreateConVar("eggman_boost_target", "650", "v5.1: velocidad OBJETIVO del Jetpack Boost en u/s (650 como el Speed; el lagged se calcula solo). 0 = multiplicador viejo de eggman_boost_speed");
    g_cvEggShieldCd   = CreateConVar("eggman_shield_cd",     "26", "Lua: 26 al apagarse solo");
    g_cvEggShieldCdPop= CreateConVar("eggman_shield_cdpop",  "35", "Lua: 35 si PARO un golpe (popped)");
    g_cvEggShieldTime = CreateConVar("eggman_shield_time",   "5",  "Lua: 5s de escudo (+0.25 por bloqueo)");
    g_cvEggShieldBlockExt = CreateConVar("eggman_shield_blockext", "0.25", "Lua: cada bloqueo extiende 0.25s");
    g_cvEggShieldStun= CreateConVar("eggman_shield_stun", "3.5",  "v5.2: stun del atacante que golpea el escudo [1 -> 3.5, pedido del owner]");
    // v5.2-OM: EL ESCUDO REWORK + EL ZAPPER (ronda 2 del owner)
    g_cvEggShieldMaxHits  = CreateConVar("eggman_shield_maxhits", "3",
        "v5.2: impactos de ESPECIALES que soporta el escudo (al 3ro POP; los comunes NO rompen el escudo)", _, true, 1.0, true, 10.0);
    g_cvEggShieldHitDmg   = CreateConVar("eggman_shield_hitdmg", "0.05",
        "v5.2: daño al atacante como % de su vida max (5%) al golpear el escudo");
    g_cvEggShieldHitDmgTank= CreateConVar("eggman_shield_hitdmg_tank", "0.02",
        "v5.2: el % de vida max del daño al atacante si es el tank (2%)");
    g_cvEggShieldStunTank = CreateConVar("eggman_shield_stun_tank", "2.5",
        "v5.2: el stun del paquete si el atacante es el tank (2.5s)");
    g_cvEggShieldPush     = CreateConVar("eggman_shield_push", "650",
        "v5.2: velocidad (u/s) del ragdoll volador hacia atras (receta Rouge v10.5)", _, true, 0.0, true, 2000.0);
    g_cvEggZapDpsMin  = CreateConVar("eggman_zapper_dps_min", "250",
        "v5.2: daño POR SEGUNDO minimo del Zapper (el rayo que reemplaza a las minas)");
    g_cvEggZapDpsMax  = CreateConVar("eggman_zapper_dps_max", "450",
        "v5.2: daño POR SEGUNDO maximo del Zapper (250-450/s; comunes atravesados y muertos al instante)");
    g_cvEggZapDuration = CreateConVar("eggman_zapper_duration", "3.0",
        "v5.2: segundos de rayo del Zapper", _, true, 0.5, true, 10.0);
    g_cvEggZapSlow   = CreateConVar("eggman_zapper_slow", "0.35",
        "v5.2: frenado de los SI mientras el rayo los toca (m_flLaggedMovementValue; 0.35 = 35% de velocidad)", _, true, 0.05, true, 1.0);

    RegConsoleCmd("sm_eggman_mines", Command_EggmanMines);
    RegConsoleCmd("sm_eggman_laser", Command_EggmanLaser);

    // v4.0-OM: avatar espejo (patron rouge_avatar / knux_avatar /
    // shadow_avatar / cream_avatar)
    g_cvEggmanAvatar = CreateConVar("eggman_avatar", "1", "Eggman OM: avatar espejo (eggman.mdl del VPK de recursos, patron Sonic/Tails/Amy/Metal/Knuckles/Rouge/Shadow/Cream)", _, true, 0.0, true, 1.0);

    // v4.0-OM: la MUERTE del avatar en el POST propio (lección Rouge
    // v3.77.49: ni el PRE ni el POST del manager tocan el avatar de
    // Eggman)
    HookEvent("player_death", Eggman_Event_PlayerDeath);

    // Inicializar ArrayLists (PLANO: cada Push = 1 celda; los bloques de 3
    // celdas por mina se gestionan manualmente con Erase descendente)
    g_hEggmanActiveMines = new ArrayList();
    g_hEggmanActiveFires = new ArrayList();

    // v3.77.8 (Eggman v3.1): AutoExecConfig eliminado - config ÚNICA
    // del suite (Sonic_Suite.cfg, auto-guardada; ver manager). El
    // archivo viejo queda muerto y el manager lo borra del server.
}

public void Eggman_OnMapStart()
{
    // Sonidos estándar de L4D2 (cero descargas nuevas)
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

    // v5.0-OM: SONIDOS del Lua (probe dual om/ + OM/)
    {
        char low[96], up[96], probe[128];
        int ok = 0;
        for (int s = 0; s < EGG_SND_COUNT; s++)
        {
            Format(probe, sizeof(probe), "sound/%s", g_sEggSnd[s]);
            strcopy(g_sEggSndUse[s], 96, g_sEggSnd[s]);
            g_bEggSndOK[s] = FileExists(probe, true);
            if (!g_bEggSndOK[s])
            {
                strcopy(low, 96, g_sEggSnd[s]);
                if (strncmp(low, "om/", 3) == 0)
                {
                    Format(up, sizeof(up), "OM/%s", low[3]);
                    Format(probe, sizeof(probe), "sound/%s", up);
                    if (FileExists(probe, true))
                    {
                        strcopy(g_sEggSndUse[s], 96, up);
                        g_bEggSndOK[s] = true;
                    }
                }
            }
            if (g_bEggSndOK[s]) { PrecacheSound(g_sEggSndUse[s], true); ok++; }
        }
        if (ok < EGG_SND_COUNT)
            PrintToServer("[Eggman %s] sonidos om/eggman del VPK: %d/%d (los que faltan se saltan en silencio — el kit funciona igual).", EGGMAN_INC_VERSION, ok, EGG_SND_COUNT);
    }

    // v4.0-OM: AVATAR — eggman.mdl del VPK (detección FileExists estilo
    // star_stun: ve los VPK montados; sin el archivo TODO cae al
    // survivor normal, CERO dependencia)
    g_bEggmanModelOK = FileExists(EGGMAN_OM_MODEL, true);
    if (g_bEggmanModelOK) PrecacheModel(EGGMAN_OM_MODEL, true);

    // diagnostico del arranque para el owner (una línea en el log)
    if (g_bEggmanModelOK)
        PrintToServer("[Eggman %s] eggman.mdl del VPK OK — avatar espejo listo.", EGGMAN_INC_VERSION);
    else
        PrintToServer("[Eggman %s] eggman.mdl NO encontrado (%s) — avatar DESACTIVADO este mapa (cero dependencia).", EGGMAN_INC_VERSION, EGGMAN_OM_MODEL);

    // v4.0-OM: FSM del avatar (10 Hz, patron T_RougeAvatarThink) + el
    // probe de secuencias se re-resuelve en cada mapa (el .mdl puede
    // cambiar entre VPKs)
    g_bEggmanSeqResolved = false;
    for (int s = 0; s < EGGMAN_ANIM_COUNT; s++) g_bEggmanSeqOK[s] = false;
    delete g_hEggmanAvatarThink;
    g_hEggmanAvatarThink = CreateTimer(0.1, T_EggmanAvatarThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // Reset de estados por cliente (jet, cooldowns)
    for (int i = 1; i <= MaxClients; i++)
    {
        Eggman_ResetState(i);
        g_iEggmanAvatar[i]          = 0;
        g_iEggmanAvatarL[i]         = 0;
        g_iEggmanAnimState[i]       = -1;
        g_fEggmanDeathHideUntil[i]  = 0.0;
    }

    // Limpiar ArrayLists (refs del mapa anterior inservibles)
    if (g_hEggmanActiveMines != null) g_hEggmanActiveMines.Clear();
    if (g_hEggmanActiveFires != null) g_hEggmanActiveFires.Clear();

    // v3.0: el timer global de minas muere solo (TIMER_FLAG_NO_MAPCHANGE).
}

public void Eggman_OnMapEnd()
{
    // v4.0-OM: FSM del avatar muere con el mapa; refs a cero
    delete g_hEggmanAvatarThink;
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iEggmanAvatar[i]         = 0;
        g_iEggmanAvatarL[i]        = 0;
        g_iEggmanAnimState[i]      = -1;
        g_fEggmanDeathHideUntil[i] = 0.0;
        // v5.0-OM: boost/escudo/voicelines a cero
        g_bEggBoostOn[i]           = false;
        g_bEggShieldOn[i]          = false;
        g_bEggShieldPopped[i]      = false;
        g_fEggBoostUntil[i]        = 0.0;
        g_fEggBoostCdUntil[i]      = 0.0;
        g_fEggShieldUntil[i]       = 0.0;
        g_fEggShieldCdUntil[i]     = 0.0;
        g_fEggJetNoBoostUntil[i]   = 0.0;
        g_bEggChaseNear[i]         = false;
        g_bEggChaseWasNear[i]      = false;
        g_iEggForceAnim[i]         = -1;
    }

    // Los timers NO_MAPCHANGE y entidades mueren con el mapa.
    // Soltar handles y vaciar listas para que el mapa nuevo arranque limpio.
    if (g_hEggmanActiveMines != null) g_hEggmanActiveMines.Clear();
    if (g_hEggmanActiveFires != null) g_hEggmanActiveFires.Clear();
}

public void Eggman_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;

    // Anti double-hook (solo OnTakeDamage: PreThink ya no existe en v3.0)
    SDKUnhook(client, SDKHook_OnTakeDamage, Eggman_OnTakeDamage);
    SDKUnhook(client, SDKHook_PreThink, Eggman_PreThink); // por si venía de una versión vieja recargada

    SDKHook(client, SDKHook_OnTakeDamage, Eggman_OnTakeDamage);

    Eggman_ResetState(client);
}

// =====================================================================
// v5.0-OM: BOOST + ESCUDO + VOICELINES — el kit del Lua GMod
// (survivors2_eggman.lua L240-664) que faltaba en el port original.
// =====================================================================

void Egg_Snd(int idx, int ent)
{
    if (idx < 0 || idx >= EGG_SND_COUNT || !g_bEggSndOK[idx]) return;
    if (ent > 0 && IsValidEntity(ent)) EmitSoundToAll(g_sEggSndUse[idx], ent, SNDCHAN_AUTO, 90);
}

// ---- C = JETPACK BOOST (Lua E L657-664) ----
void Eggman_Ability3(int client)   // boost
{
    if (!Eggman_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return;
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    float now = GetEngineTime();

    if (g_bEggBoostOn[client]) return;                       // ya está activo
    if (now < g_fEggShieldUntil[client])
    {
        PrintCenterText(client, "[BOOST] bloqueado mientras el escudo está arriba");
        return;                                             // el Lua: nada de boost con escudo arriba
    }
    if (now < g_fEggJetNoBoostUntil[client])
    {
        PrintCenterText(client, "[BOOST] estabilizando tras el escudo: %.1fs", g_fEggJetNoBoostUntil[client] - now);
        return;                                             // ni 1s después del escudo
    }
    if (now < g_fEggBoostCdUntil[client])
    {
        PrintCenterText(client, "[BOOST] en enfriamiento: %.1fs", g_fEggBoostCdUntil[client] - now);
        return;
    }

    float dur = (g_cvEggBoostTime != null) ? g_cvEggBoostTime.FloatValue : 3.75;
    g_fEggBoostUntil[client]    = now + dur;
    g_fEggBoostNextGlow[client] = now;
    g_iEggForceAnim[client]     = EGGMAN_ST_BOOST;

    Egg_Snd(EGG_SND_BOOST1, client);   // las 2 capas del Lua
    Egg_Snd(EGG_SND_BOOST2, client);
    PrintCenterText(client, "[BOOST] JETPACK CHARGE!");
}

// ---- B = SOAPY SHIELD (Lua T L651-656) ----
void Eggman_Ability4(int client)   // escudo
{
    if (!Eggman_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != EGGMAN_INDEX) return;
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    float now = GetEngineTime();

    if (g_bEggShieldOn[client]) return;
    if (now < g_fEggShieldCdUntil[client])
    {
        PrintCenterText(client, "[SHIELD] en enfriamiento: %.1fs", g_fEggShieldCdUntil[client] - now);
        return;
    }

    float dur = (g_cvEggShieldTime != null) ? g_cvEggShieldTime.FloatValue : 5.0;
    g_fEggShieldUntil[client]  = now + dur;
    g_bEggShieldOn[client]     = true;
    g_bEggShieldPopped[client] = false;

    // voz aleatoria de las 3 del Lua + la activación
    int v = 6 + GetRandomInt(0, 2);
    Egg_Snd(v, client);
    Egg_Snd(EGG_SND_SHACT, client);

    // tinte CYAN del avatar mientras dura (el highlight del Lua)
    int av  = EntRefToEntIndex(g_iEggmanAvatar[client]);
    int avL = EntRefToEntIndex(g_iEggmanAvatarL[client]);
    if (av  > 0 && IsValidEntity(av))  SetEntityRenderColor(av, 0, 175, 245, 255);
    if (avL > 0 && IsValidEntity(avL)) SetEntityRenderColor(avL, 0, 175, 245, 255);

    PrintCenterText(client, "[SHIELD] SOAPY SHIELD! (bloquea cuerpo a cuerpo)");
}

// cancel de downed/muerte (el CustomFunctionForDowned del Lua)
void Eggman_CancelBoostShield(int client)
{
    if (g_bEggBoostOn[client])
    {
        g_bEggBoostOn[client] = false;
        g_fEggBoostUntil[client] = 0.0;
        if (IsClientInGame(client) && HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
    if (g_iEggForceAnim[client] == EGGMAN_ST_BOOST) g_iEggForceAnim[client] = -1;
    if (g_bEggShieldOn[client])
    {
        g_bEggShieldOn[client] = false;
        g_fEggShieldUntil[client] = 0.0;
        g_fEggJetNoBoostUntil[client] = GetEngineTime() + 1.0;
        // color original del avatar
        int av  = EntRefToEntIndex(g_iEggmanAvatar[client]);
        int avL = EntRefToEntIndex(g_iEggmanAvatarL[client]);
        if (av  > 0 && IsValidEntity(av))  SetEntityRenderColor(av, 255, 255, 255, 255);
        if (avL > 0 && IsValidEntity(avL)) SetEntityRenderColor(avL, 255, 255, 255, 255);
    }
}

// el tick (desde T_EggmanAvatarThink 10 Hz): ventanas + voicelines
void Eggman_GameplayTick(int client, float now)
{
    // v5.2-OM: INMUNE A AGARRES (la capa de CURA): si un hunter/jockey/
    // smoker lo cazó en un frame que el forward no cubrió, el especial
    // recibe el stun directamente y el doctor queda LIBRE (return barato
    // cuando no hay agarre — cero coste por tick)
    Eggman_CheckGrabCure(client);
    // ------------------ BOOST activo ------------------
    if (g_bEggBoostOn[client] || now < g_fEggBoostUntil[client])
    {
        if (!g_bEggBoostOn[client])
            g_bEggBoostOn[client] = true;   // primera vuelta

        // v5.1-OM: VELOCIDAD OBJETIVO 650 u/s — pedido del owner:
        // "debería aumentar la velocidad así como el Speed aumentar su
        // velocidad a 650". El multiplicador lagged se calcula contra la
        // velocidad máxima REAL del survivor (220 base / 260 adrenalina)
        // para que la efectiva SEA ~650 u/s. eggman_boost_target 0 = el
        // multiplicador fijo viejo (eggman_boost_speed).
        if (HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
        {
            float bMult = 2.0;
            if (g_cvEggBoostTarget != null && g_cvEggBoostTarget.FloatValue > 100.0)
            {
                float baseSpd = 220.0;
                if (HasEntProp(client, Prop_Data, "m_flMaxspeed"))
                {
                    float ms = GetEntPropFloat(client, Prop_Data, "m_flMaxspeed");
                    if (ms > 80.0) baseSpd = ms;
                }
                bMult = g_cvEggBoostTarget.FloatValue / baseSpd;
                if (bMult > 4.0) bMult = 4.0;
                if (bMult < 1.0) bMult = 1.0;
            }
            else if (g_cvEggBoostSpeed != null)
                bMult = g_cvEggBoostSpeed.FloatValue;
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", bMult);
        }

        // glow atras cada 0.2s (el om_eggman_expell del Lua)
        if (now >= g_fEggBoostNextGlow[client] && g_iEggmanGlowSprite > 0)
        {
            float p[3], eye[3], fwd[3];
            GetClientAbsOrigin(client, p);
            GetClientEyeAngles(client, eye); eye[0] = 0.0;
            GetAngleVectors(eye, fwd, NULL_VECTOR, NULL_VECTOR);
            p[0] -= fwd[0] * 40.0; p[1] -= fwd[1] * 40.0; p[2] += 5.0;
            TE_SetupGlowSprite(p, g_iEggmanGlowSprite, 0.18, 2.2, 220);
            TE_SendToAll();
            g_fEggBoostNextGlow[client] = now + 0.2;
        }

        if (now >= g_fEggBoostUntil[client])
        {
            // fin del boost: cd 22 (Lua L616-619)
            g_bEggBoostOn[client] = false;
            g_fEggBoostCdUntil[client] = now + ((g_cvEggBoostCd != null) ? g_cvEggBoostCd.FloatValue : 22.0);
            if (IsClientInGame(client) && HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
                SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            if (g_iEggForceAnim[client] == EGGMAN_ST_BOOST) g_iEggForceAnim[client] = -1;
        }
    }

    // ------------------ ESCUDO: fin de ventana ------------------
    if (g_bEggShieldOn[client] && now >= g_fEggShieldUntil[client])
    {
        g_bEggShieldOn[client] = false;
        g_fEggShieldUntil[client] = 0.0;
        g_fEggJetNoBoostUntil[client] = now + 1.0;    // el Lua: 1s sin boost tras el escudo

        if (g_bEggShieldPopped[client])
        {
            g_fEggShieldCdUntil[client] = now + ((g_cvEggShieldCdPop != null) ? g_cvEggShieldCdPop.FloatValue : 35.0);
            Egg_Snd(EGG_SND_SHPOP, client);
        }
        else
        {
            g_fEggShieldCdUntil[client] = now + ((g_cvEggShieldCd != null) ? g_cvEggShieldCd.FloatValue : 26.0);
        }
        Egg_Snd(EGG_SND_SHOFF, client);

        // color original del avatar
        int av  = EntRefToEntIndex(g_iEggmanAvatar[client]);
        int avL = EntRefToEntIndex(g_iEggmanAvatarL[client]);
        if (av  > 0 && IsValidEntity(av))  SetEntityRenderColor(av, 255, 255, 255, 255);
        if (avL > 0 && IsValidEntity(avL)) SetEntityRenderColor(avL, 255, 255, 255, 255);
    }

    // ------------------ VOICELINES del fin de persecución ------------------
    // (el PeelOut_saidoutahere del Lua L386-440: enemigos a 700u; cuando
    // se van después de haber estado, una de las 9 al azar — 1 vez por ronda)
    if (now >= g_fEggChaseNextCheck[client])
    {
        g_fEggChaseNextCheck[client] = now + 0.5;
        float c[3];
        GetClientAbsOrigin(client, c);

        bool near = false;
        for (int t = 1; t <= MaxClients && !near; t++)
        {
            if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
            if (GetClientTeam(t) != TEAM_INFECTED) continue;
            float p[3]; GetClientAbsOrigin(t, p);
            if (GetVectorDistance(c, p) <= 700.0) { near = true; break; }
        }
        if (!near)
        {
            static const char sNpc[][] = { "infected", "witch", "tank" };
            for (int n = 0; n < sizeof(sNpc) && !near; n++)
            {
                int ent = -1;
                while ((ent = FindEntityByClassname(ent, sNpc[n])) != -1)
                {
                    if (!IsValidEntity(ent)) continue;
                    if (!HasEntProp(ent, Prop_Data, "m_iHealth")) continue;
                    if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
                    float p[3]; GetEntPropVector(ent, Prop_Data, "m_vecOrigin", p);
                    if (GetVectorDistance(c, p) <= 700.0) { near = true; break; }
                }
            }
        }

        g_bEggChaseNear[client] = near;
        if (near) g_bEggChaseWasNear[client] = true;
        else if (g_bEggChaseWasNear[client])
        {
            // se acabó la persecución: voz al azar de las 9 del Lua
            g_bEggChaseWasNear[client] = false;
            int v = EGG_SND_CHASE + GetRandomInt(0, 8);
            Egg_Snd(v, client);
        }
    }
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

    // v5.0-OM: boost + escudo + voicelines
    Eggman_CancelBoostShield(client);
    g_fEggBoostCdUntil[client]    = 0.0;
    g_fEggShieldCdUntil[client]   = 0.0;
    g_bEggShieldPopped[client]    = false;
    g_fEggJetNoBoostUntil[client] = 0.0;
    g_bEggChaseNear[client]       = false;
    g_bEggChaseWasNear[client]    = false;
    g_fEggChaseNextCheck[client]  = 0.0;
    g_iEggForceAnim[client]       = -1;

    // v5.2-OM: reset del escudo rework + parada del zapper
    g_iEggShieldHits[client]      = 0;
    g_iEggShieldHitRef[client]    = 0;
    if (g_hEggZapTimer[client] != null)
    {
        // el timer se mata solo en su proximo tick (muerte/respawn)
        KillTimer(g_hEggZapTimer[client]);
        g_hEggZapTimer[client] = null;
    }
    g_bEggZapActive[client] = false;
}

// =======================
// PASIVAS: HOVER DEL EGGMOBILE (inmunidades)
// =======================

public Action Eggman_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Eggman_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != EGGMAN_INDEX) return Plugin_Continue;

    // v5.1-OM: EL ESCUDO QUE BLOQUEA DE VERDAD — reporte del owner:
    // "la habilidad del escudo no está sirviendo como 4 habilidad".
    // El v5.0 solo miraba DMG_CLUB/SLASH/CRUSH, pero en L4D2 la garra
    // del común y varios básicos de los especiales llegan con el
    // damagetype VACÍO (0) — en GMod si vienen clasificados. Ahora el
    // bloqueo cubre: (a) los 3 tipos físicos del Lua, y (b) el CUERPO A
    // CUERPO real de L4D2 = atacante del equipo infectado cuyo
    // inflictor es EL MISMO atacante (garra de común/SI/punch del
    // tank). Proyectiles (roca del tank, escupitajo) y fuego quedan
    // FUERA, como el cuerpo a cuerpo del Lua.
    if (g_bEggShieldOn[victim])
    {
        bool meleeHit = (damagetype & DMG_CLUB || damagetype & DMG_SLASH || damagetype & DMG_CRUSH);
        if (!meleeHit && attacker > 0 && attacker == inflictor)
        {
            if (attacker <= MaxClients)
                meleeHit = (IsClientInGame(attacker) && GetClientTeam(attacker) == TEAM_INFECTED);
            else if (IsValidEntity(attacker) && HasEntProp(attacker, Prop_Data, "m_iTeamNum"))
                meleeHit = (GetEntProp(attacker, Prop_Data, "m_iTeamNum") == TEAM_INFECTED
                            && HasEntProp(attacker, Prop_Data, "m_iHealth")
                            && GetEntProp(attacker, Prop_Data, "m_iHealth") > 0);
        }
        if (meleeHit)
        {
            damage = 0.0;
            float now = GetEngineTime();

            // v5.2-OM: EL ESCUDO REWORK — ¿quién golpea?
            // (los players SI/tank son attacker <= MaxClients; los NPC
            // se clasifican por classname: witch y tank cuentan como
            // especiales, el resto son comunes)
            bool isWitch  = (attacker > MaxClients && Eggman_IsWitchEnt(attacker));
            bool isTankNpc= (attacker > MaxClients && !isWitch && Eggman_IsTankEnt(attacker));
            bool isCommon = (attacker > MaxClients && !isWitch && !isTankNpc);

            if (isCommon)
            {
                // v5.2-OM: LOS COMUNES NO ROMPEN ESTE ESCUDO — bloqueados
                // en silencio: sin contar impacto, sin stun, sin extension
                // ("los comunes no rompen este escudo")
            }
            else
            {
                // especial (player SI/tank, o witch/tank NPC): cuenta IMPACTO
                int maxHits = (g_cvEggShieldMaxHits != null) ? g_cvEggShieldMaxHits.IntValue : 3;
                g_iEggShieldHits[victim]++;
                float ext = (g_cvEggShieldBlockExt != null) ? g_cvEggShieldBlockExt.FloatValue : 0.25;
                g_fEggShieldUntil[victim] = now + ext;
                g_bEggShieldPopped[victim] = true;

                // v5.2-OM: el PAQUETE diferido (la leccion Amy v106 se
                // MANTIENE: nada de dano dentro del hook) — stun 3.5s
                // (2.5s tank) + RAGDOLL volador atras + 5% de vida max
                // (2% tank); la witch recibe su variante SEGURA dentro
                g_iEggShieldHitRef[victim] = EntIndexToEntRef(attacker);
                RequestFrame(Egg_ShieldHitFrame, EntIndexToEntRef(victim));

                if (g_iEggShieldHits[victim] >= maxHits)
                {
                    // al 3er impacto: el escudo POP — se apaga YA (el
                    // tick de la ventana lo cierra con su cd 35 + sonidos)
                    g_bEggShieldOn[victim] = false;
                    g_fEggShieldUntil[victim] = now;
                    PrintCenterText(victim, "[SHIELD] ¡ROTO por %d impactos de especiales!", maxHits);
                }
                else
                    PrintCenterText(victim, "[SHIELD] ¡BLOQUEADO! (%d/%d impactos)", g_iEggShieldHits[victim], maxHits);
            }

            // el pop visual: glow + sonido
            Egg_Snd(EGG_SND_SHPOP, victim);
            if (g_iEggmanGlowSprite > 0)
            {
                float p[3];
                GetClientAbsOrigin(victim, p); p[2] += 40.0;
                TE_SetupBeamRingPoint(p, 10.0, 120.0, g_iEggmanGlowSprite, g_iEggmanGlowSprite, 0, 15, 0.3, 8.0, 1.0, {0, 175, 245, 220}, 0, 0);
                TE_SendToAll();
            }
            return Plugin_Changed;
        }
    }

    // Inmune a caidas (Eggmobile flota) — ahora SI importa: el doble salto
    // anima a jugar con la altura
    if (damagetype & DMG_FALL)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // Inmune a acido, veneno o radiación (flota sobre el charco)
    if (damagetype & DMG_ACID || damagetype & DMG_POISON || damagetype & DMG_RADIATION)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

// v5.2-OM: EL PAQUETE DEL ESCUDO, DIFERIDO al frame siguiente (fuera
// del hook de dano — la ventana segura del suite; la leccion Amy v106
// se mantiene). Orden martillo v106 / Rouge v10.5: DAÑO AMPLIFICADO
// PRIMERO; letal = cadaver volando (Sonic_DeadFlingCopy); sobrevive =
// OM_Stun (3.5s / 2.5s tank) + RAGDOLL VOLADOR hacia atras
// (Sonic_SpawnFlingRagdollEx, la receta Rouge v10.5) + 5% de vida max
// como daño (2% tank). La witch recibe la variante SEGURA del suite:
// daño + WitchFlight_Launch — JAMAS hielo propio sobre su IA.
public void Egg_ShieldHitFrame(any data)
{
    int eggman = EntRefToEntIndex(view_as<int>(data));
    if (eggman <= 0 || eggman > MaxClients) return;
    if (!IsClientInGame(eggman) || !IsPlayerAlive(eggman)) return;

    int attacker = EntRefToEntIndex(g_iEggShieldHitRef[eggman]);
    g_iEggShieldHitRef[eggman] = 0;
    if (attacker <= 0 || !IsValidEntity(attacker)) return;

    bool isWitch = Eggman_IsWitchEnt(attacker);
    bool isTank  = (!isWitch && ((attacker <= MaxClients)
                    ? (IsClientInGame(attacker) && GetEntProp(attacker, Prop_Send, "m_zombieClass") == 8)
                    : Eggman_IsTankEnt(attacker)));

    // el % de vida max como daño (5% / 2% tank)
    float pct = (g_cvEggShieldHitDmg != null) ? g_cvEggShieldHitDmg.FloatValue : 0.05;
    if (isTank) pct = (g_cvEggShieldHitDmgTank != null) ? g_cvEggShieldHitDmgTank.FloatValue : 0.02;

    float maxHp = 1.0;
    if (attacker <= MaxClients) maxHp = float(GetEntProp(attacker, Prop_Data, "m_iMaxHealth"));
    else if (HasEntProp(attacker, Prop_Data, "m_iMaxHealth")) maxHp = float(GetEntProp(attacker, Prop_Data, "m_iMaxHealth"));
    if (maxHp < 1.0) maxHp = 100.0;
    float dmg = maxHp * pct;
    if (dmg < 1.0) dmg = 1.0;

    // dirección: ALEJÁNDOLO del doctor (horizontal + elevación corta — la
    // receta Rouge v10.5 de la patada baja)
    float ePos[3], aPos[3];
    GetClientAbsOrigin(eggman, ePos);
    if (attacker <= MaxClients) GetClientAbsOrigin(attacker, aPos);
    else GetEntPropVector(attacker, Prop_Data, "m_vecOrigin", aPos);
    float dir[3]; MakeVectorFromPoints(ePos, aPos, dir);
    dir[2] = 0.25;
    if (NormalizeVector(dir, dir) < 0.01) { dir[0] = 0.0; dir[1] = 1.0; dir[2] = 0.25; }
    NormalizeVector(dir, dir);

    float push = (g_cvEggShieldPush != null) ? g_cvEggShieldPush.FloatValue : 650.0;

    // 1) DAÑO PRIMERO (orden martillo v106)
    SDKHooks_TakeDamage(attacker, eggman, eggman, dmg, DMG_CLUB);

    // 2) ¿murió con el golpe? el cadaver vuela (receta Rouge/sonic v6.35)
    bool alive;
    if (attacker <= MaxClients) alive = IsClientInGame(attacker) && IsPlayerAlive(attacker);
    else alive = (IsValidEntity(attacker) && HasEntProp(attacker, Prop_Data, "m_iHealth")
                  && GetEntProp(attacker, Prop_Data, "m_iHealth") > 0);

    if (!alive)
    {
        if (attacker <= MaxClients)
            Sonic_DeadFlingCopy(attacker, dir, push, false);
        return;
    }

    if (isWitch)
    {
        // variante SEGURA (la regla del suite v2.10-witch): JAMAS hielo
        // propio sobre su IA — solo el lanzamiento del Witch_Flight
        float wpush[3];
        wpush = dir;
        ScaleVector(wpush, push);
        wpush[2] = 260.0;
        WitchFlight_Launch(attacker, eggman, wpush);
        return;
    }

    // 3) sobrevive: STUN + RAGDOLL volador (players SI/tank)
    float st = (g_cvEggShieldStun != null) ? g_cvEggShieldStun.FloatValue : 3.5;
    if (isTank) st = (g_cvEggShieldStunTank != null) ? g_cvEggShieldStunTank.FloatValue : 2.5;

    if (attacker <= MaxClients && OM_Stun(attacker, st, eggman, 0.0, DMG_OM_CLUB, true))
    {
        Sonic_SpawnFlingRagdollEx(attacker, dir, push, 0.35, 900.0);
        PrintCenterText(eggman, "[SHIELD] ¡STUN %.1fs + RAGDOLL VOLADOR!", st);
    }
    else
    {
        // NPC tank (bot) o iframes ajenos: al menos el empujón clásico
        float vpush[3];
        vpush = dir;
        ScaleVector(vpush, push);
        vpush[2] = 300.0;
        if (attacker <= MaxClients) TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, vpush);
        else
        {
            // NPC: los tanques bot se mueven por IA — el empujón seguro es
            // el Witch_Flight (IA suspendida + aterrizaje con impacto)
            WitchFlight_Launch(attacker, eggman, vpush);
        }
    }
}

// Puente de compatibilidad: el PreThink del avion ya no existe (v3.0).
// Se mantiene vacío para no romper includes antiguos que lo referencien.
public void Eggman_PreThink(int client) {}

// =======================
// NUEVA PASIVA v3.0: EGGMOBILE JET (DOBLE SALTO)
// =======================
// El manager invoca a esta función en cada RunCmd de un Eggman vivo:
// usamos detección de flanco de IN_JUMP para el salto aéreo.

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

    // En suelo o escalera: el jet se re-arma para el próximo salto
    if ((flags & FL_ONGROUND) || GetEntityMoveType(client) == MOVETYPE_LADDER)
    {
        g_bEggmanJetReady[client] = true;
        g_iEggmanLastButtons[client] = buttons;
        return;
    }

    // Flanco de pulsación de SALTO (nueva pulsación, no mantener)
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

    // --- IMPULSO DEL JET (v5.0-OM: EXACTO del Lua L625-631: la
    // velocidad horizontal ACTUAL se conserva, la vertical pasa a 400) ---
    float force   = (g_cvEggmanJetForce != null)   ? g_cvEggmanJetForce.FloatValue   : EGGMAN_JET_FORCE_DEF;
    float fwdPower = (g_cvEggmanJetForward != null) ? g_cvEggmanJetForward.FloatValue : EGGMAN_JET_FORWARD_DEF;

    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);

    // Vertical: vz = 400 PLANO (el Lua: currentplyVelocity.z = 400)
    vel[2] = force;

    // Horizontal: empuje en la dirección de la mira (sin pitch)
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
        // Anillo de propulsión expandiéndose (colores Eggman: rojo/naranja)
        TE_SetupBeamRingPoint(pos, 5.0, 130.0, g_iEggmanGlowSprite, g_iEggmanGlowSprite,
                              0, 15, 0.25, 8.0, 1.0, {255, 170, 0, 200}, 0, 0);
        TE_SendToAll();
    }

    // Chispas del jet hacia abajo
    TE_SetupSparks(pos, view_as<float>({0.0, 0.0, -1.0}), 8, 4);
    TE_SendToAll();

    // Burst de energía eléctrica
    TE_SetupEnergySplash(pos, view_as<float>({0.0, 0.0, -1.0}), false);
    TE_SendToAll();

    // Sonido del jet: el del Lua (probe); fallback zap9 nativo
    if (g_bEggSndOK[EGG_SND_DJUMP])
        EmitSoundToAll(g_sEggSndUse[EGG_SND_DJUMP], client, SNDCHAN_AUTO, 90);
    else
        EmitSoundToAll("ambient/energy/zap9.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 120);

    PrintCenterText(client, "[JET] EGGMOBILE BOOST!");

    // v4.0-OM: one-shot del JET sobre las DOS copias del avatar (si el
    // .mdl trae "jet"/"hover"/"fly"; si no, la pose del salto la cubre)
    Eggman_AvatarOneShot(client, EGGMAN_ST_JET, EGGMAN_LOCK_JET);
}

// =======================
// HABILIDAD 1: BADNIK MINES v2 (glow + detección global)
// =======================

public Action Command_EggmanMines(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
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

    // v5.2-OM: LAS MINAS SON AHORA EL ZAPPER — mismo keybind, mismo cd
    // (eggman_mines_cd 18), NUEVA habilidad (ver Eggman_StartZapper,
    // en la sección ZAPPER abajo). El deploy viejo de las 3 minas queda
    // bajo #if 0 como referencia muerta.
    Eggman_StartZapper(client);
    return Plugin_Handled;


}

// Timer GLOBAL: chequea proximidad de todas las minas de una sola vez.
// (v2 tenía 1 timer + DataPack POR MINA con FindEntityByClassname x3 cada 0.2s)
public Action T_EggmanMinesTick(Handle timer)
{
    if (g_hEggmanActiveMines == null)
    {
        return Plugin_Stop;
    }

    int blocks = g_hEggmanActiveMines.Length / EGGMAN_MINE_BLOCK;
    if (blocks <= 0)
    {
        return Plugin_Stop;
    }

    for (int b = blocks - 1; b >= 0; b--)
    {
        int base = b * EGGMAN_MINE_BLOCK;

        int mine = EntRefToEntIndex(g_hEggmanActiveMines.Get(base));
        if (mine == INVALID_ENT_REFERENCE || !IsValidEntity(mine))
        {
            // La mina ya no existe (explosión, kill, limpieza) -> quitar bloque
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
// que los índices de las celdas restantes no se desplacen durante el borrado)
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

    // Dano en área
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

    // v3.0: la witch también recibe el dano de las minas (antes solo el laser)
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
        DispatchKeyValue(fire, "spawnflags", "1"); // Sin expansión
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
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
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

    // v4.0-OM: one-shot del LASER sobre las DOS copias del avatar — el
    // lock (2.2s) cubre la CARGA del telegrafo (2s) + el disparo: el
    // avatar se queda en la pose de casteo mientras el rayo cae
    Eggman_AvatarOneShot(client, EGGMAN_ST_LASER, EGGMAN_LOCK_LASER);

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

        // Haz vertical fino de aviso (de donde vendrá el disparo)
        TE_SetupBeamPoints(skyPos, targetPos, g_iEggmanBeamSprite, 0, 0, 0, 0.25,
                           3.0, 3.0, 0, 0.0, {255, 0, 0, 130}, 0);
        TE_SendToAll();

        // Anillo que delimita la zona de impacto (v5.2: del tamaño REAL
        // del area — eggman_laser_radius)
        TE_SetupBeamRingPoint(targetPos, 20.0, (g_cvEggmanLaserRadius != null) ? g_cvEggmanLaserRadius.FloatValue : 450.0, g_iEggmanGlowSprite, g_iEggmanGlowSprite,
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

        // Explosión
        TE_SetupExplosion(targetPos, glow, 60.0, 1, 0, 500, 0);
        TE_SendToAll();
    }

    // v5.2-OM: SONIDO DE EXPLOSION DE VERDAD — el explode_1.wav era
    // contenido de HL2 que L4D2 NO trae (se oia NADA): ahora el de la
    // PIPE BOMB del PROPIO L4D2, ESPACIAL en el punto de impacto
    EmitSoundToAll("weapons/hegrenade/explode_3.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_GUNFIRE,
                   _, 1.0, 120, -1, targetPos);

    // v5.2-OM: area de impacto 400 -> eggman_laser_radius (450)
    float radius = (g_cvEggmanLaserRadius != null) ? g_cvEggmanLaserRadius.FloatValue : 450.0;
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

// =====================================================================
// v5.2-OM: EL ZAPPER + EL ESCUDO REWORK — inmunidades y el rayo nuevo
// =====================================================================

// --- clasificación de NPCs (para el escudo y el paquete) ---
bool Eggman_IsWitchEnt(int ent)
{
    if (ent <= MaxClients || !IsValidEntity(ent)) return false;
    static char cls[16];
    GetEntityClassname(ent, cls, sizeof(cls));
    return StrEqual(cls, "witch", false);
}
bool Eggman_IsTankEnt(int ent)
{
    if (ent <= MaxClients || !IsValidEntity(ent)) return false;
    static char cls[16];
    GetEntityClassname(ent, cls, sizeof(cls));
    return StrEqual(cls, "tank", false);
}

// --- la inmunidad a VOMITO del boomer mientras el escudo está arriba ---
// (la spitter ya estaba cubierta: el Eggmobile bloquea DMG_ACID 24/7)
bool Eggman_VomitShield(int victim)
{
    if (victim <= 0 || victim > MaxClients) return false;
    if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return false;
    if (g_iPlayerCharIdx[victim] != EGGMAN_INDEX) return false;
    return g_bEggShieldOn[victim];
}

// --- la inmunidad a AGARRES "de por si" (como Metal Sonic) ---
// la llaman los dispatchers de sonic.inc (pounce/jockey); la capa de
// CURA vive en Eggman_CheckGrabCure (GameplayTick)
bool Eggman_ControlImmune(int client)
{
    if (client <= 0 || client > MaxClients) return false;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return false;
    return g_iPlayerCharIdx[client] == EGGMAN_INDEX;
}

// --- la capa de CURA de agarres: si un hunter/jockey/smoker lo cazó
// en un frame que el forward no cubrió: el especial RECIBE el stun
// directamente (el paquete completo del escudo) y el doctor queda
// LIBRE por los caminos del MOTOR (L4D2_Jockey_EndRide etc.)
void Eggman_CheckGrabCure(int client)
{
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    int pounce = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
    int tongue = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
    int jockey = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
    if (pounce <= 0 && tongue <= 0 && jockey <= 0) return;

    int attacker = 0;
    if (pounce > 0)      { attacker = pounce; L4D_Hunter_ReleaseVictim(client, pounce); }
    else if (tongue > 0) { attacker = tongue; L4D_Smoker_ReleaseVictim(client, tongue); }
    else                 { attacker = jockey; L4D2_Jockey_EndRide(client, jockey); }
    if (attacker > 0 && attacker <= MaxClients)
    {
        g_iEggShieldHitRef[client] = EntIndexToEntRef(attacker);
        RequestFrame(Egg_ShieldHitFrame, EntIndexToEntRef(client));
        PrintCenterText(client, "[EGGMAN] ¡Agarre anulado — el especial recibe el stun!");
    }
}

// --- EL ZAPPER: el rayo tipo Tails que reemplaza a las Badnik Mines ---
void Eggman_StartZapper(int client)
{
    // one-shot de anim sobre las DOS copias + sonido de activación
    // (zap9: ya usado por el laser y el jet — probado en este server)
    Eggman_AvatarOneShot(client, EGGMAN_ST_MINES, EGGMAN_LOCK_MINES);
    EmitSoundToAll("ambient/energy/zap9.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 120);

    float dur = (g_cvEggZapDuration != null) ? g_cvEggZapDuration.FloatValue : 3.0;
    if (dur < 0.1) dur = 0.1;
    g_bEggZapActive[client] = true;
    g_fEggZapEndAt[client]  = GetEngineTime() + dur;

    if (g_hEggZapTimer[client] != null) KillTimer(g_hEggZapTimer[client]);
    g_hEggZapTimer[client] = CreateTimer(0.1, T_EggZapperTick, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    PrintCenterText(client, "[ZAPPER] ¡Rayo activo! (%.1fs — daña y ralentiza)", dur);
}

void Eggman_StopZapper(int client)
{
    g_bEggZapActive[client] = false;
    g_hEggZapTimer[client] = null;

    // quitar el frenado de las victimas (respetando congelados ajenos:
    // si OM_IsStunned, su propio sistema maneja su LaggedMovement)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_fEggZapSlowUntil[i] <= 0.0) continue;
        g_fEggZapSlowUntil[i] = 0.0;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (OM_IsStunned(i)) continue;                    // congelado: no pisarle el 0
        if (HasEntProp(i, Prop_Send, "m_flLaggedMovementValue"))
            SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
    PrintCenterText(client, "[ZAPPER] rayo agotado — enfriando (eggman_mines_cd)");
}

public Action T_EggZapperTick(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)
        || g_iPlayerCharIdx[client] != EGGMAN_INDEX || !g_bEggZapActive[client])
        return Plugin_Stop;
    if (g_hEggZapTimer[client] != timer) return Plugin_Stop;   // un timer nuevo la mató

    float now = GetEngineTime();
    if (now >= g_fEggZapEndAt[client]) { Eggman_StopZapper(client); return Plugin_Stop; }

    // el rayo: ojo -> primer solid (mundo/props), hasta 1500u si no hay
    float pos[3], ang[3], end[3];
    GetClientEyePosition(client, pos);
    GetClientEyeAngles(client, ang);
    Handle tr = TR_TraceRayFilterEx(pos, ang, MASK_SOLID, RayType_Infinite, Eggman_TraceFilter_NoPlayers, client);
    if (TR_DidHit(tr)) TR_GetEndPosition(end, tr);
    else
    {
        float fwd[3]; GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
        end[0] = pos[0] + fwd[0] * 1500.0;
        end[1] = pos[1] + fwd[1] * 1500.0;
        end[2] = pos[2] + fwd[2] * 1500.0;
    }
    delete tr;

    // FX del rayo (naranja Eggman) + glow al final
    if (g_iEggmanBeamSprite > 0 && g_iEggmanGlowSprite > 0)
    {
        TE_SetupBeamPoints(pos, end, g_iEggmanBeamSprite, 0, 0, 0, 0.12, 8.0, 3.0, 0, 0.0, {255, 170, 0, 220}, 0);
        TE_SendToAll();
        TE_SetupGlowSprite(end, g_iEggmanGlowSprite, 0.12, 1.2, 180);
        TE_SendToAll();
    }

    // daño por tick: 250-450/s partido en 10
    float dMin = (g_cvEggZapDpsMin != null) ? g_cvEggZapDpsMin.FloatValue : 250.0;
    float dMax = (g_cvEggZapDpsMax != null) ? g_cvEggZapDpsMax.FloatValue : 450.0;
    if (dMax < dMin) dMax = dMin;
    float tick = GetRandomFloat(dMin, dMax) / 10.0;
    float slow = (g_cvEggZapSlow != null) ? g_cvEggZapSlow.FloatValue : 0.35;
    if (slow < 0.05) slow = 0.05;

    // 1) SI players: daño + FRENO mientras el rayo los toca
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client || !IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;
        if (!Eggman_ZapLineHit(pos, end, i)) continue;
        if (OM_IsStunned(i))
        {
            SDKHooks_TakeDamage(i, client, client, tick, DMG_SHOCK);   // congelado: solo daño
            continue;
        }
        SDKHooks_TakeDamage(i, client, client, tick, DMG_SHOCK);
        if (HasEntProp(i, Prop_Send, "m_flLaggedMovementValue"))
            SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", slow);
        g_fEggZapSlowUntil[i] = now + 0.25;   // se re-ancla por tick
    }

    // 2) comunes: ATRAVIESA la línea y muere AL INSTANTE (snapshot)
    int zlist[96]; int zc = 0;
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (zc >= sizeof(zlist)) break;
        if (!IsValidEntity(ent)) continue;
        if (!Eggman_ZapLineHitEnt(pos, end, ent)) continue;
        zlist[zc++] = ent;
    }
    for (int k = 0; k < zc; k++) SDKHooks_TakeDamage(zlist[k], client, client, 9999.0, DMG_SHOCK);

    // 3) witches: el daño del tick (sin hielo ni fuego — la regla del suite)
    ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (!Eggman_ZapLineHitEnt(pos, end, ent)) continue;
        SDKHooks_TakeDamage(ent, client, client, tick, DMG_SHOCK);
    }
    return Plugin_Continue;
}

// ¿el cuerpo (a +30z) está a <=90u del segmento del rayo o <=120u de su
// extremo? (la misma matemática del rayo de Tails)
bool Eggman_ZapLineHit(const float start[3], const float end[3], int pl)
{
    float tPos[3]; GetClientAbsOrigin(pl, tPos); tPos[2] += 30.0;
    return Eggman_ZapPointHit(start, end, tPos);
}
bool Eggman_ZapLineHitEnt(const float start[3], const float end[3], int ent)
{
    if (!IsValidEntity(ent)) return false;
    float ePos[3]; GetEntPropVector(ent, Prop_Data, "m_vecOrigin", ePos); ePos[2] += 30.0;
    return Eggman_ZapPointHit(start, end, ePos);
}
bool Eggman_ZapPointHit(const float start[3], const float end[3], const float p[3])
{
    if (GetVectorDistance(end, p) <= 120.0) return true;
    float line[3]; SubtractVectors(end, start, line);
    float dd = GetVectorDotProduct(line, line);
    if (dd <= 0.0) return false;
    float vp[3]; SubtractVectors(p, start, vp);
    float t = GetVectorDotProduct(vp, line) / dd;
    if (t < 0.0 || t > 1.0) return false;
    float cp[3]; cp = line; ScaleVector(cp, t); AddVectors(start, cp, cp);
    return GetVectorDistance(cp, p) <= 90.0;
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

// v4.0-OM: al morir, SOLO reset de estado — la MUERTE del avatar
// (ragdoll + anti-corpse + KillAvatarOnly) vive en el POST propio del
// modulo (Eggman_Event_PlayerDeath, la lección Rouge v3.77.49: si el
// manager la llamara ANTES de ese POST, mataría el avatar y el ragdoll
// JAMÁS saldría)
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

// v4.0-OM: limpieza al DESCARGAR el plugin (OnPluginEnd del manager) —
// aquí SI se mata el avatar con restore del cuerpo (no murió nadie: el
// plugin se va). SIN ragdoll.
public void Eggman_OnPluginEnd(int client)
{
    if (client < 1 || client > MaxClients) return;
    Eggman_KillAvatar(client);
    Eggman_ResetState(client);
}

// =====================================================================
// =====================================================================
//  v4.0-OM: AVATAR ESPEJO EGGMAN.MDL (9o AVATAR DEL SUITE)
//  Patron Cream v7.0-OM / Shadow v6.0 textual, adaptado al kit de
//  Eggman: detección por ÍNDICE (personaje del manager) + one-shots
//  de MINAS/LASER/JET sobre las DOS copias.
// =====================================================================
// =====================================================================

// =====================================================================
// RESOLUCION DE SECUENCIAS POR PROBE (receta Amy v92 / Shadow v6.0 /
// Cream v7.0): SourcePawn no trae LookupSequence — se dispara
// SetAnimation(nombre) y se lee m_nSequence: si el índice CAMBIO, el
// nombre existe en el .mdl. Se resuelve UNA vez por mapa (al nacer el
// primer avatar, todo dentro del mismo frame).
// =====================================================================
void Eggman_ResolveTry(int av, int state, const char[] name)
{
    if (g_bEggmanSeqOK[state]) return;
    if (!HasEntProp(av, Prop_Send, "m_nSequence")) return;

    int before = GetEntProp(av, Prop_Send, "m_nSequence");
    SetVariantString(name);
    AcceptEntityInput(av, "SetAnimation");
    int after = GetEntProp(av, Prop_Send, "m_nSequence");

    if (after != before)
    {
        strcopy(g_sEggmanSeq[state], sizeof(g_sEggmanSeq[]), name);
        g_bEggmanSeqOK[state] = true;
    }
}

void Eggman_ResolveSeqs(int av)
{
    if (g_bEggmanSeqResolved) return;
    g_bEggmanSeqResolved = true;

    // cadena de candidatos por estado (nombres GMod + variantes)
    for (int st = 0; st < EGGMAN_ANIM_COUNT; st++)
    {
        for (int c = 0; c < EGGMAN_SEQ_MAX_CAND; c++)
        {
            if (g_sEggmanSeqCand[st][c][0] == '\0') break;
            Eggman_ResolveTry(av, st, g_sEggmanSeqCand[st][c]);
            if (g_bEggmanSeqOK[st]) break;
        }
    }

    // 2a pasada del idle (truco Amy v92: si el default del modelo YA
    // era idle, la primera prueba no movió el índice — ahora el actual
    // es otro y si "idle" existe, se registra)
    Eggman_ResolveTry(av, EGGMAN_ST_IDLE, "idle");

    // fallbacks de las variantes que el modelo no traiga: la base
    // cubre el hueco (nunca T-pose)
    int fallbacks[EGGMAN_ANIM_COUNT];
    for (int fb = 0; fb < EGGMAN_ANIM_COUNT; fb++) fallbacks[fb] = -1;
    fallbacks[EGGMAN_ST_IDLE_LOW]    = EGGMAN_ST_IDLE;
    fallbacks[EGGMAN_ST_WALK_LOW]    = EGGMAN_ST_WALK;
    fallbacks[EGGMAN_ST_RUN_LOW]     = EGGMAN_ST_RUN;
    fallbacks[EGGMAN_ST_DOWNED_IDLE] = EGGMAN_ST_IDLE;
    fallbacks[EGGMAN_ST_DOWNED_WALK] = EGGMAN_ST_WALK;
    fallbacks[EGGMAN_ST_JET]         = EGGMAN_ST_JUMP;
    fallbacks[EGGMAN_ST_MINES]       = EGGMAN_ST_IDLE;
    fallbacks[EGGMAN_ST_LASER]       = EGGMAN_ST_IDLE;

    for (int s = 0; s < EGGMAN_ANIM_COUNT; s++)
    {
        if (g_bEggmanSeqOK[s] || fallbacks[s] < 0) continue;
        if (g_bEggmanSeqOK[fallbacks[s]])
        {
            strcopy(g_sEggmanSeq[s], sizeof(g_sEggmanSeq[]), g_sEggmanSeq[fallbacks[s]]);
            g_bEggmanSeqOK[s] = true;
        }
    }
}

// la secuencia a usar para un estado (con triple red de seguridad)
void Eggman_SeqFor(int state, char out[24])
{
    if (g_bEggmanSeqOK[state])
        strcopy(out, 24, g_sEggmanSeq[state]);
    else if (g_bEggmanSeqOK[EGGMAN_ST_IDLE])
        strcopy(out, 24, g_sEggmanSeq[EGGMAN_ST_IDLE]);
    else
        strcopy(out, 24, "idle");
}

// =====================================================================
// CREACION / MUERTE DE LAS COPIAS (receta Rouge v10.2 / Shadow v6.0 /
// Cream v7.0)
// =====================================================================
int Eggman_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
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
    g_fEggmanBodyYaw[client]  = ang[1];
    g_fEggmanYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fEggmanBodyYaw[client], loc);

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
        g_fEggmanSmLoc[client][k]  = loc[k];
        g_fEggmanSmLocL[client][k] = loc[k];
    }
    g_bEggmanSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// v72-OM (adopción): un prop con NUESTRO nombre que esta FSM no rastrea
// es un huerfano por definición — muere en el instante del montaje.
bool Eggman_IsMyAvatarRef(int ref)
{
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iEggmanAvatar[i] == ref) return true;
        if (g_iEggmanAvatarL[i] == ref) return true;
    }
    return false;
}

void Eggman_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "eggman_avatar_om", "eggman_avatar_om_l" };
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
                if (Eggman_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
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
        PrintToServer("[Eggman %s] Adopción del montaje: %d huerfano(s) del avatar eliminado(s).", EGGMAN_INC_VERSION, ng);
}

// Monta el avatar completo (R + L + cuerpo oculto). pulsePause SOLO para
// montajes de ciclo de vida (spawn/selección/reparación tardia de la FSM).
void Eggman_CreateAvatar(int client, bool pulsePause = true)
{
    if (!g_bEggmanModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;

    // v72-OM (reemplazo limpio): si este cliente ya tenía un R o L vivo
    // (montaje doble por orden raro de eventos), muere AQUÍ enterito.
    {
        int oldR = EntRefToEntIndex(g_iEggmanAvatar[client]);
        if (g_iEggmanAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Eggman_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iEggmanAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iEggmanAvatarL[client]);
        if (g_iEggmanAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Eggman_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iEggmanAvatarL[client] = 0;
    }

    // v72-OM: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje.
    Eggman_KillGhostAvatarProps();

    int av = Eggman_CreateAvatarProp(client, EGGMAN_OM_MODEL, EGGMAN_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    // resolver las secuencias contra el .mdl REAL (probe Amy v92, UNA
    // vez por mapa — el primer avatar nace resolviendo para todos)
    Eggman_ResolveSeqs(av);

    char seqIdle[24];
    Eggman_SeqFor(EGGMAN_ST_IDLE, seqIdle);
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");
    g_iEggmanAnimState[client] = 0;

    SDKHook(av, SDKHook_SetTransmit, Eggman_TransmitAvatarR);

    g_iEggmanAvatarL[client] = 0;
    Eggman_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iEggmanBodyRender[client] = view_as<int>(curMode);
    else if (g_iEggmanBodyRender[client] == -1)
        g_iEggmanBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    g_iEggmanAvatar[client] = EntIndexToEntRef(av);

    // per-tick: angulos locales (contra-rotación del parent)
    SDKHook(client, SDKHook_PostThink, Eggman_AvatarFollow);

    // PULSO DE PAUSA en cada montaje de ciclo de vida (la misma infra
    // sv_pausable del suite; convar tails_pausefix manda para TODOS los
    // avatares — es UN solo sistema, 9o avatar del suite)
    if (pulsePause)
        Tails_PauseFix_Trigger(client);
}

void Eggman_CreateAvatarL(int client)
{
    if (!g_bEggmanModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iEggmanAvatar[client] == 0) return;

    int av = Eggman_CreateAvatarProp(client, EGGMAN_OM_MODEL, EGGMAN_AVATAR_NAME_L);
    if (av == 0) return;

    char seqIdle[24];
    Eggman_SeqFor(EGGMAN_ST_IDLE, seqIdle);
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Eggman_TransmitAvatarL);

    g_iEggmanAvatarL[client] = EntIndexToEntRef(av);
}

void Eggman_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iEggmanAvatarL[client]);
    if (g_iEggmanAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Eggman_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iEggmanAvatarL[client] = 0;
}

// Mata las copias R+L y devuelve el cuerpo. SIN desenganchar el follow
// (lo hace Eggman_KillAvatar).
void Eggman_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    Eggman_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iEggmanAvatar[client]);
    if (g_iEggmanAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Eggman_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iEggmanAvatar[client] = 0;
    g_iEggmanAnimState[client] = -1;

    // devolver el cuerpo (spectate/revive/cambio de personaje)
    if (IsClientInGame(client) && g_iEggmanBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iEggmanBodyRender[client]));
        g_iEggmanBodyRender[client] = -1;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Eggman_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Eggman_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Eggman_AvatarFollow);
}

// Transmit filters (patron Rouge/Sonic/Metal/Shadow/Cream): la R no la
// ve su dueña (tiene su L), la L la ve SOLO su dueña.
public Action Eggman_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iEggmanAvatar[i] != 0 && EntRefToEntIndex(g_iEggmanAvatar[i]) == entity)
        {
            if (client == i && g_iEggmanAvatarL[i] != 0
                && EntRefToEntIndex(g_iEggmanAvatarL[i]) > 0)
                return Plugin_Handled;   // la dueña tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

public Action Eggman_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iEggmanAvatarL[i] != 0 && EntRefToEntIndex(g_iEggmanAvatarL[i]) == entity)
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
public void Eggman_AvatarFollow(int client)
{
    if (g_iEggmanAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Eggman_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    // ---- yaw objetivo: dirección REAL del movimiento ----
    float yawObj = g_fEggmanBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fEggmanBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    // ---- giro suave hacia el objetivo (~900 grados/s) ----
    float now = GetEngineTime();
    float dt  = now - g_fEggmanYawLastT[client];
    g_fEggmanYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fEggmanBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fEggmanBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bEggmanSmSnap[client];
    GetClientAbsAngles(client, par);
    float yawPuppet = g_fEggmanBodyYaw[client];

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iEggmanAvatar[client]);
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
            loc[1] = Tails_UnwrapYaw(g_fEggmanSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fEggmanSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fEggmanSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }

    // ---- copia L: contra-rotada contra los EYE de la dueña ----
    if (g_iEggmanAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iEggmanAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3], locL[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], yawPuppet, locL);
            locL[1] = Tails_UnwrapYaw(g_fEggmanSmLocL[client][1], locL[1]);
            Tails_ExpDamp(locL, g_fEggmanSmLocL[client], 0.05, dt, snap);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fEggmanSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
    g_bEggmanSmSnap[client] = false;
}

// FSM de 10 Hz: montaje / auto-reparación / muerte del avatar (patron
// T_RougeAvatarThink / T_ShadowAvatarThink / T_CreamAvatarThink)
public Action T_EggmanAvatarThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Eggman_KillAvatar(i); continue; }

        bool esEggmanVivo = (g_iPlayerCharIdx[i] == EGGMAN_INDEX
                          && IsPlayerAlive(i) && GetClientTeam(i) == 2);

        // incap = fuera (defensa anti terceros — la FSM re-monta sola
        // al levantarla: la misma regla de Rouge/Shadow/Cream)
        if (esEggmanVivo && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
        {
            esEggmanVivo = false;
            // v5.0-OM: downed = cancel del boost/escudo (el CustomFunctionForDowned del Lua)
            if (g_bEggBoostOn[i] || g_bEggShieldOn[i]) Eggman_CancelBoostShield(i);
        }

        // v5.0-OM: EL TICK DEL KIT (boost/escudo/voicelines) — con o sin
        // avatar. Aturdido = cancel (no pelear contra el stun del suite).
        if (IsPlayerAlive(i) && GetClientTeam(i) == 2)
        {
            if (OM_IsStunned(i))
            {
                if (g_bEggBoostOn[i] || g_bEggShieldOn[i]) Eggman_CancelBoostShield(i);
            }
            else if (g_iPlayerCharIdx[i] == EGGMAN_INDEX)
                Eggman_GameplayTick(i, now);
        }

        // ---- montaje ----
        if (g_iEggmanAvatar[i] == 0)
        {
            if (esEggmanVivo && g_cvEggmanAvatar != null && g_cvEggmanAvatar.BoolValue
                && g_bEggmanModelOK)
            {
                Eggman_CreateAvatar(i);
            }
            continue;
        }

        // quitar avatar si dejó de ser un Eggman survivor vivo de pie
        if (!esEggmanVivo)
        {
            Eggman_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iEggmanAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iEggmanAvatar[i] = 0;
            g_iEggmanAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (el motor lo resetea al
        // cambiar de capítulo/rescue: fix Tails v5.4)
        if (g_iEggmanBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparación de la copia L (montaje tardio: pulso también)
        if (g_iEggmanAvatarL[i] == 0 && g_iEggmanAvatar[i] != 0)
        {
            Eggman_CreateAvatarL(i);
            if (g_iEggmanAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // ---- FSM de animación ----
        av = EntRefToEntIndex(g_iEggmanAvatar[i]);
        if (g_iEggmanAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Eggman_AvatarUpdate(i, av, now);
    }
    return Plugin_Continue;
}

// =====================================================================
// FSM DE ANIMACION — prioridades: incap (DownedIdle/DownedWalk) ->
// aire (jump subiendo / fall cayendo) -> suelo (idle/walk/run con
// variantes lowhealth de HP<=40). Los one-shots (JET/MINAS/LASER)
// llegan por Eggman_AvatarOneShot y bloquean la FSM mientras corren.
// =====================================================================
void Eggman_AvatarUpdate(int client, int av, float now)
{
    // lock de one-shot en curso (Jet/Mines/Laser)
    if (now < g_fEggmanAnimLock[client]) return;

    int state;
    float rate = 1.0;

    // v5.0-OM: anim de juego forzada (el BOOST sostenido)
    if (g_iEggForceAnim[client] >= 0)
    {
        state = g_iEggForceAnim[client];
    }
    else if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
    {
        // DownedIdle/DownedWalk
        state = (Eggman_Speed2D(client) > 40.0) ? EGGMAN_ST_DOWNED_WALK : EGGMAN_ST_DOWNED_IDLE;
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // AIRE: sube = jump; cae = fall — con la ventana del jump
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[2] > 40.0)
        {
            state = EGGMAN_ST_JUMP;
        }
        else
        {
            bool jumpLive = false;
            if (g_iEggmanAnimState[client] == EGGMAN_ST_JUMP)
            {
                float jt = now - g_fEggmanJumpStart[client];
                if (jt < 0.5)      jumpLive = true;
                else if (jt < 1.5 && !Eggman_JumpAnimDone(av)) jumpLive = true;
            }
            state = jumpLive ? EGGMAN_ST_JUMP : EGGMAN_ST_FALL;
        }
    }
    else if (g_iEggmanAnimState[client] == EGGMAN_ST_JUMP && !Eggman_JumpAnimDone(av)
             && now - g_fEggmanJumpStart[client] < 0.5)
    {
        // FL_ONGROUND parpadea al saltar rozando escalones
        state = EGGMAN_ST_JUMP;
    }
    else
    {
        // SUELO: idle/walk/run (lowhealth <= 40)
        bool low = (GetClientHealth(client) <= EGGMAN_LOWHP);
        float s = Eggman_Speed2D(client);
        if (s < 40.0)
            state = low ? EGGMAN_ST_IDLE_LOW : EGGMAN_ST_IDLE;
        else if (s < 150.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = low ? EGGMAN_ST_WALK_LOW : EGGMAN_ST_WALK;
            rate = 1.0;   // rate 1 constante del framework GMod
        }
        else
        {
            state = low ? EGGMAN_ST_RUN_LOW : EGGMAN_ST_RUN;
            rate = 1.32 * (s / 450.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6)  rate = 3.6;
        }
    }

    if (state != g_iEggmanAnimState[client])
    {
        // el t0 del jump para su ventana (receta Rouge/Sonic/Knuckles)
        if (state == EGGMAN_ST_JUMP) g_fEggmanJumpStart[client] = now;

        char seqUse[24];
        Eggman_SeqFor(state, seqUse);

        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iEggmanAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iEggmanAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                // el variant es de UN SOLO USO — re-armarlo
                SetVariantString(seqUse);
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iEggmanAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iEggmanAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iEggmanAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

float Eggman_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// el one-shot del jump termino? (m_flCycle del prop — la misma sonda
// del Rouge_JumpAnimDone / Knux_JumpAnimDone / Shadow_JumpAnimDone)
bool Eggman_JumpAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return true;
}

// ONE-SHOT de habilidad sobre las DOS copias (el Jet, las Minas y el
// Laser). Bloquea la FSM mientras corre.
void Eggman_AvatarOneShot(int client, int stIdx, float lock)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iEggmanAvatar[client] == 0) return;   // sin avatar: no-op

    char seqUse[24];
    Eggman_SeqFor(stIdx, seqUse);

    int av = EntRefToEntIndex(g_iEggmanAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
    }
    if (g_iEggmanAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iEggmanAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetVariantString(seqUse);
            AcceptEntityInput(avL, "SetAnimation");
        }
    }
    g_iEggmanAnimState[client] = stIdx;
    g_fEggmanAnimLock[client] = GetEngineTime() + lock;
}

// =====================================================================
// MUERTE DEL AVATAR — ragdoll eggman.mdl + filtro anti-corpse
// (receta Rouge v10.2 / Knuckles v75 / Metal v5.0 / Shadow v6.0 /
// Cream v7.0)
// =====================================================================
void Eggman_SpawnDeathRagdoll(int client)
{
    if (!g_bEggmanModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", EGGMAN_OM_MODEL);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    CreateTimer(15.0, T_EggmanDeathRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_EggmanDeathRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Filtro anti-ragdoll (patron Rouge/Sonic/Knuckles/Shadow/Cream —
// enrutado por el OnEntityCreated central de Rouge.inc, que despacha
// a este modulo)
public void Eggman_CheckDeathRagdoll(any ref)
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
        if (g_fEggmanDeathHideUntil[i] == 0.0 || now >= g_fEggmanDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_vEggmanDeathOrigin[i]) < 200.0)
        {
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}

// v3.77.69: dispatch del OnEntityCreated central de Rouge.inc — la
// ventana anti-corpse de las muertes del Eggman con avatar
public void Eggman_OnEntityCreated(int entity, const char[] classname)
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
            if (g_fEggmanDeathHideUntil[i] == 0.0 || nowOM >= g_fEggmanDeathHideUntil[i])
                continue;
            RequestFrame(Eggman_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }
}

// LA MUERTE DEL AVATAR (hook POST propio — la lección Rouge v3.77.49:
// ni el PRE ni el POST del manager tocan el avatar de Eggman; TODO pasa
// aquí: ragdoll + ventana anti-corpse + KillAvatarOnly. La lección
// Sonic v3.76.2: en PRE el restore dejaba ver el corpse del survivor.)
public void Eggman_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0) return;

    if (g_iPlayerCharIdx[client] == EGGMAN_INDEX)
    {
        if (g_iEggmanAvatar[client] != 0)
        {
            Eggman_SpawnDeathRagdoll(client);
            g_fEggmanDeathHideUntil[client] = GetEngineTime() + 2.0;
            GetClientAbsOrigin(client, g_vEggmanDeathOrigin[client]);
            Eggman_KillAvatarOnly(client);   // el cuerpo vuelve a verse para el spectate/revive
        }
        Eggman_ResetState(client);
    }
}

// =====================================================================
// v5.1-OM: LÍNEA DEL PANEL DE ESTADOS — el manager 3.77.72 la pinta en
// el KeyHintText SIEMPRE VISIBLE (pedido del owner: "los enfriamientos
// de cream blaze eggman y bueno silver deben verse ya que no se ven").
// Muestra el estado del jet/doble salto, los 4 cooldowns Z/X/C/B y los
// estados activos de boost/escudo.
// =====================================================================
void Eggman_HUDLine(int client, char[] out, int maxlen, float now)
{
    int n = 0;
    n += Format(out[n], maxlen - n, "EGGMAN");

    if (g_bEggBoostOn[client] && n < maxlen - 36)
        n += Format(out[n], maxlen - n, "  [BOOST %.1fs]", g_fEggBoostUntil[client] - now);
    if (g_bEggShieldOn[client] && n < maxlen - 38)
        n += Format(out[n], maxlen - n, "  [ESCUDO %.1fs]", g_fEggShieldUntil[client] - now);

    if (n < maxlen - 44)
    {
        n += Format(out[n], maxlen - n, "\nZ Minas: ");
        if (now < g_fEggmanMinesCD[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fEggmanMinesCD[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTAS");
    }
    if (n < maxlen - 44)
    {
        n += Format(out[n], maxlen - n, "\nX Laser: ");
        if (now < g_fEggmanLaserCD[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fEggmanLaserCD[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTO");
    }
    if (n < maxlen - 44)
    {
        n += Format(out[n], maxlen - n, "\nC Boost: ");
        if (g_bEggBoostOn[client])
            n += Format(out[n], maxlen - n, "ACTIVO");
        else if (now < g_fEggBoostCdUntil[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fEggBoostCdUntil[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTO");
    }
    if (n < maxlen - 44)
    {
        n += Format(out[n], maxlen - n, "\nB Escudo: ");
        if (g_bEggShieldOn[client])
            n += Format(out[n], maxlen - n, "ACTIVO");
        else if (now < g_fEggShieldCdUntil[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fEggShieldCdUntil[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTO");
    }
    if (n < maxlen - 56)
    {
        n += Format(out[n], maxlen - n, "\nDoble salto: ");
        if (g_bEggmanJetReady[client])
            n += Format(out[n], maxlen - n, "LISTO");
        else if (now < g_fEggmanJetNext[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fEggmanJetNext[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTO");
    }
}
