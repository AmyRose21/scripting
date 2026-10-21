/*
 * ======================================================
 *  [MODULO] Cream the Rabbit - Super Rework v7.0-OM (SU AVATAR)
 *
 *  v7.0-OM (manager 3.77.68, orden del owner: "el siguiente avatar
 *  es Cream") — 8o AVATAR DEL SUITE, patron Shadow v6.0 / Rouge
 *  v10.2:
 *   - AVATAR ESPEJO cream.mdl: models/Noodles/OM/cream.mdl del VPK
 *     (FileExists: si no esta, CERO dependencia — survivor normal).
 *     Copia R (los demas) + copia L (la dueña) + cuerpo oculto +
 *     FSM 10 Hz + ragdoll de muerte 15s + anti-corpse 2s + adopción
 *     de huerfanos + pulso de pausa.
 *   - FSM POR PROBE (receta Amy v92): idle/walk/run/jump/fall + FLY
 *     DE OREJAS (el glide de SPACE, su pasiva existente) + lowhealth
 *     <=30 (el umbral de "Cheese desmayado") + downed + one-shots
 *     CURA/RESURRECCION.
 *   - Tinte DORADO del avatar en la inmunidad post-resurrección.
 *   - La MUERTE del avatar vive en el POST propio (lección Rouge
 *     v3.77.49); Cream_OnPlayerDeath queda en puro reset y el nuevo
 *     Cream_OnPluginEnd hace el restore del cuerpo al descargar.
 *   - Convar cream_avatar 1.
 *
 *  v6.1 (con manager 3.77.8) - FIN DE LA AUTO-GENERACION INDIVIDUAL:
 *   - Eliminado el AutoExecConfig("Cream_Abilities") — el cfg
 *     individual se generaba con TODOS los cvars del plugin entero
 *     ("ConVars for plugin Sonic_ability_manager.smx"), o sea la
 *     MISMA lista que Sonic_Suite.cfg: duplicado puro que además
 *     pisaba valores al ejecutarse. Los cvars de Cream ya viven en
 *     la config única Sonic_Suite.cfg (v3.75, auto-guardada).
 *   - El manager 3.77.8 además BORRA los cfg residuales del server
 *     (SuiteCfg_DeleteLegacyFiles).
 *
 *  v6 (R26) - EL APARTADO DE SOPORTE (pedido del owner): "cream
 *  será el apartado de soporte que tendrá la regeneración y su
 *  cura pero mejorada ya no se interrupe si la golpean y puede
 *  curar al moverse":
 *   - REGENERACION PASIVA: +1 HP cada 2s (viva, sin full HP y sin
 *     incapacidad). También para SAGE con el set soporte prestado.
 *   - CURA MEJORADA: ya NO se interrumpe por dano (fuera el
 *     CancelHeal del OnTakeDamage de v5) y se cura MÓVIL: sin la
 *     ralentización 0.3 (m_flLaggedMovement) y sin requisito de
 *     pisar suelo (aire incluido).
 *   - RESURRECCION con CD: "su habilidad revivir tendrá cd en vez
 *     de esperar 1 ronda entera será de 120 seg. Para sage ella
 *     solo esperara 30 seg" — 120s Cream / 30s Sage (set prestado
 *     vía Sage.inc: Z = cura, X = revivir). Se resetea en ronda o
 *     mapa nuevo. Sin muertos: el CD NO se consume.
 *
 *  v5.2 FIX: el glow dorado del revivido salia AZUL CLARO (el color estaba
 *  escrito con los bytes invertidos respecto a la convención del juego,
 *  R + G<<8 + B<<16). Ahora si es oro (255, 215, 0).
 *
 *  v5.1 CHANGES (FIXES DE BUGS Y LÓGICA):
 *  - FIX CRASH-LOG: Cream_OnMapStart llamaba KillTimer sobre handles de
 *    heal timers que ya murieron solos con TIMER_FLAG_NO_MAPCHANGE al
 *    cambiar de mapa (generaba errores "Invalid handle"). Ahora se
 *    anulan los handles antes del reset.
 *  - FIX LÓGICA: Cheese despertaba aunque la vida hubiera bajado de 50
 *    durante los 12s de espera (el timer seguía corriendo igual).
 *  - FIX LÓGICA: la autocuración NO contaba como "alguien curado", así
 *    que si Cream estaba sola el heal se autointerrumpia a los 3 ticks
 *    aunque se estuviera curando a si misma.
 *  - FIX LÓGICA: el glide se aplicaba también en escaleras y agua
 *    profunda (TeleportEntity en esos estados lanzaba al jugador).
 *  - FIX LÓGICA: la inmunidad de los REVIVIDOS (2s) estaba prometida en
 *    el header pero solo se implementaba el glow dorado, SIN bloqueo de
 *    dano. Ahora bloquea dano de verdad.
 *  - QoL: los revividos reciben un kit básico (pistola + pastillas) para
 *    no quedar indefensos al aparecer.
 *  - QoL: el cooldown del heal ahora cuenta desde el INICIO (antes desde
 *    que terminaba, alargándolo de facto).
 *  - QoL: mensaje al completar la curación de forma natural.
 *
 *  v5.0 CHANGES - SUPER REWORK:
 *
 *  1. NUEVA HABILIDAD 2: RESURRECCION
 *     - Reemplaza completamente el Dash
 *     - Revive a TODOS los jugadores muertos del mapa
 *     - Los revividos aparecen con HP completa (100)
 *     - 1 USO POR RONDA (se reinicia al cambiar de mapa o reiniciar ronda)
 *     - Si no hay muertos, NO se consume el uso
 *     - Efectos visuales: ring de revivir dorado, glow en revividos, sonido angelical
 *     - Cream queda inmune por 3 segundos después de revivir (protección)
 *     - Los revividos quedan inmunes 2 segundos al aparecer
 *     - Comando: sm_cream_dash (mantiene nombre por compatibilidad)
 *     - Comando nuevo: sm_cream_revive
 *
 *  2. ROBUSTEZ DE CÓDIGO:
 *     - Validaciones estrictas en cada función (client, entity, ref)
 *     - SDKUnhook antes de SDKHook (anti double-hook)
 *     - Limpieza segura de handles con null checks
 *     - Clamp de HP (0-200) y radio (>0)
 *     - ConVars con validación null
 *     - Banderas explícitas de estado
 *     - ArrayList para trackeo de estados temporales
 *
 *  3. FIX DE BUGS:
 *     - BUG 1: Cheese podía desmayarse múltiples veces seguidas (cooldown no respetado)
 *       FIX: g_bCheeseAlive se checkea ANTES de aplicar el desmayo
 *     - BUG 2: Heal activo no se cancelaba correctamente al morir
 *       FIX: Cream_ResetState ahora cancela el heal explicitamente
 *     - BUG 3: Timer de heal quedaba zombie si el cliente se desconectaba
 *       FIX: Timer verifica IsClientInGame en cada tick
 *     - BUG 4: Glide activo durante incap (causaba movimiento raro)
 *       FIX: PreThink checkea m_isIncapacitated antes del glide
 *     - BUG 5: m_iMaxHealth podía devolver 0 o negativo (causaba HP negativo)
 *       FIX: Clamp a mínimo 1 en todas las lecturas de maxHealth
 *     - BUG 6: Cooldowns no se reseteaban al cambiar de mapa
 *       FIX: Cream_OnMapStart resetea todos los cooldowns
 *     - BUG 7: Touch hook podía dispararse con entidades inválidas
 *       FIX: Validación IsValidEntity + EntRefToEntIndex en cada touch
 *     - BUG 8: Speed boost de aliados no se reseteaba si se desconectaban
 *       FIX: Timer verifica IsClientInGame antes de aplicar reset
 *
 *  4. REAJUSTES:
 *     - Heal: radio más grande (300->350), más ticks (7->8), sin autodano
 *     - Cheese: cooldown de protección ajustado (40->35s), respawn más rápido (15->12s)
 *     - Glide: descenso más lento (-50 -> -40), max speed ajustado (250->280)
 *     - HP cap de revividos: 100 (no se revive con buffos previos)
 *     - Inmunidad post-revive: 3 segundos para evitar morir inmediatamente
 *
 *  Habilidad 1: Heal de área (MÓVIL TOTAL: sin slow ni interrupción)
 *  Habilidad 2: Resurrección (CD 120s / Sage 30s)
 *  Pasivas: REGENERACION (+1HP/2s), Glide WASD, Cheese defiende y revive
 * ======================================================
 */

#if defined _Cream_included
    #endinput
#endif
#define _Cream_included

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
#if !defined _si_stagger_included
    #include <SI_Stagger>
#endif
#if !defined _pin_release_included
    #include <Pin_Release>
#endif

// =======================
// Dependencias
// =======================
#if !defined CREAM_INDEX
    #define CREAM_INDEX 7
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
#define CHEESE_ALIVE_HEAL       10
#define CHEESE_DEAD_HEAL        5
#define CHEESE_RESPAWN_TIME     12.0    // v5: bajado de 15 a 12s
#define CHEESE_PROTECT_CD       35.0    // v5: bajado de 40 a 35s
#define CHEESE_DESPAWN_HP       30      // HP bajo el cual Cheese se desmaya

#define CREAM_HEAL_RADIUS       90.0   // v7.1: el Lua GMod (survivors2 L2107: FindInSphere 90) — era 350 del pre-Lua
#define CREAM_HEAL_TICKS        7      // v7.1: el Lua: 7.1s de canal con paso de 1s (era 8)
// v6 (R26): CREAM_HEAL_SPEED_MULT (0.3) RETIRADO: "puede curar al
// moverse" = velocidad 100% durante toda la curación
#define CREAM_HEAL_TICK_TIME    1.0

#define CREAM_GLIDE_DESCENT     -40.0   // v5: descenso más lento
#define CREAM_GLIDE_MAX_SPEED   280.0   // v5: max speed ajustado
#define CREAM_GLIDE_ACCEL       20.0

// Resurrección (v6: CD en vez de 1-uso-por-ronda)
#define CREAM_REVIVE_HP             100     // HP con la que reviven
#define CREAM_REVIVE_CD             120.0   // v6 (R26): "en vez de esperar 1 ronda entera será de 120 seg"
#define SAGE_REVIVE_CD              30.0    // v6 (R26): "Para sage ella solo esperara 30 seg"
#define CREAM_REGEN_INTERVAL        2.0     // v6 (R26): regeneración pasiva: cada 2s...
#define CREAM_REGEN_AMOUNT          1       // ... suma +1 HP (hasta el máximo)
#define CREAM_REVIVE_IMMUNE_TIME    3.0     // Inmunidad post-revive de Cream
#define CREAM_REVIVE_VICTIM_IMMUNE  2.0     // Inmunidad post-revive de los revividos
#define CREAM_REVIVE_RADIUS         2000.0  // Radio de busqueda (mapa entero)

// Limites de seguridad
#if !defined HP_MIN
    #define HP_MIN 1
#endif
#if !defined HP_MAX
    #define HP_MAX 200
#endif

// =======================
// Sonidos
// =======================
#define SND_CREAM_HEAL      "mobius/sfx/cream/heal_loop.wav"
#define SND_CREAM_REVIVE    "mobius/sfx/cream/revive.mp3"
#define SND_CHEESE_DIE      "mobius/sfx/cream/chao_die.wav"
#define SND_CHEESE_ALIVE    "mobius/sfx/cream/chao_happy.wav"
#define SND_CREAM_FALLBACK  "ambient/energy/zap1.wav"  // fallback si no existe revive.mp3

// =======================
// Variables Globales
// =======================
bool  g_bCreamHealActive[MAXPLAYERS + 1];
bool  g_bCheeseAlive[MAXPLAYERS + 1];
bool  g_bCheeseCanDespawn[MAXPLAYERS + 1]; // v5: anti multi-despawns

// Resurrección (v6: COOLDOWN — 120s Cream / 30s Sage del set prestado)
float g_fCreamReviveNextUse[MAXPLAYERS + 1];
bool  g_bCreamReviveImmune[MAXPLAYERS + 1]; // Inmunidad temporal post-revive
float g_fCreamRevivedImmuneUntil[MAXPLAYERS + 1]; // v5.1: inmunidad REAL de los revividos
float g_fCreamRegenNext[MAXPLAYERS + 1];   // v6 (R26): próximo tick de regeneración

float g_fCreamHealCooldown[MAXPLAYERS + 1];
float g_fCheeseRespawnTime[MAXPLAYERS + 1];
float g_fCheeseProtectTime[MAXPLAYERS + 1];
float g_fCreamReviveImmuneEnd[MAXPLAYERS + 1];

Handle g_hCreamHealTimer[MAXPLAYERS + 1];

// Sprites cacheados
int g_iCreamGlowSprite = -1;
int g_iCreamBeamSprite = -1;
int g_iCreamHaloSprite = -1;

// =======================
// v7.0-OM: AVATAR ESPEJO CREAM.MDL (8o avatar del suite)
// =======================
#define CREAM_INC_VERSION    "v7.3-OM"   // v7.3: LA CURA MAS ANCHA + EL DASH QUE PEGA (pedido del owner 2026-10-17, ronda 2): (1) "rango aumentado a 125 (su velocidad de cura seguirá =)" — el radio de la cura 90 -> 125 [cream_heal_radius 125; el MONTO y el cd quedan IGUAL]; (2) EL DASH: "causará 5 de daño a ella misma" [cream_dash_dmg 20 -> 5] y "causará entre 120 a 180 de daño a los infectados SI (los comunes son dañados moderadamente más que los SI)" [cream_dash_dmg_si_min/_max 120-180 + cream_dash_dmg_commonmult 1.5 = los NPC pagan 180-270] | v7.2: feedback de recarga del dash en pantalla + línea del PANEL DE ESTADOS (KeyHintText siempre visible del manager 3.77.72)
#define CREAM_OM_MODEL       "models/Noodles/OM/cream.mdl"
#define CREAM_AVATAR_NAME    "cream_avatar_om"
#define CREAM_AVATAR_NAME_L  "cream_avatar_om_l"

// FSM de animación — los nombres se RESUELVEN contra el .mdl real por
// PROBE (receta Amy v92 / Shadow v6.0): cada estado tiene una CADENA de
// candidatos y gana el primero que exista en el modelo; los que falten
// caen a su estado base (nunca T-pose)
#define CREAM_ST_IDLE         0
#define CREAM_ST_WALK         1
#define CREAM_ST_RUN          2
#define CREAM_ST_JUMP         3    // one-shot con ventana (receta Rouge)
#define CREAM_ST_FALL         4
#define CREAM_ST_IDLE_LOW     5    // lowhealth (HP <= 30: Cheese desmayado)
#define CREAM_ST_WALK_LOW     6
#define CREAM_ST_RUN_LOW      7
#define CREAM_ST_DOWNED_IDLE  8    // incap
#define CREAM_ST_DOWNED_WALK  9
#define CREAM_ST_FLY          10   // GLIDE DE OREJAS (SPACE en el aire — su pasiva)
#define CREAM_ST_HEAL         11   // one-shot: cura de área
#define CREAM_ST_REVIVE       12   // one-shot: resurrección
#define CREAM_ANIM_COUNT      13
#define CREAM_SEQ_MAX_CAND    6

#define CREAM_LOCK_HEAL       1.0    // FSM quieta durante el casteo de la cura
#define CREAM_LOCK_REVIVE     1.3    // FSM quieta durante la resurrección

// cadena de candidatos por estado (nombres GMod + variantes)
static const char g_sCreamSeqCand[CREAM_ANIM_COUNT][CREAM_SEQ_MAX_CAND][24] = {
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
    { "fly",             "Fly",            "FlyIdle",      "flap",         "glide",  "float"   },  // 10
    { "heal",            "Heal",           "HealStart",    "cast",         "Cast",   "cheer"   },  // 11
    { "revive",          "Revive",         "resurrect",    "cheer",        "heal",   ""        }   // 12
};

ConVar g_cvCreamAvatar;
bool   g_bCreamModelOK     = false;   // cream.mdl en el VPK montado
bool   g_bCreamSeqResolved = false;   // el probe ya corrio en este mapa
Handle g_hCreamAvatarThink = null;    // FSM 10 Hz
int    g_iCreamAvatar[MAXPLAYERS + 1];      // EntRef copia R (0 = sin avatar)
int    g_iCreamAvatarL[MAXPLAYERS + 1];     // EntRef copia L
int    g_iCreamBodyRender[MAXPLAYERS + 1];  // render ORIGINAL del survivor
int    g_iCreamAnimState[MAXPLAYERS + 1];   // estado FSM actual
float  g_fCreamAnimLock[MAXPLAYERS + 1];    // lock de one-shot en curso
float  g_fCreamJumpStart[MAXPLAYERS + 1];   // t0 de la ventana del jump
float  g_fCreamBodyYaw[MAXPLAYERS + 1];     // yaw suavizado del avatar
float  g_fCreamYawLastT[MAXPLAYERS + 1];
bool   g_bCreamSmSnap[MAXPLAYERS + 1];
float  g_fCreamSmLoc[MAXPLAYERS + 1][3];
float  g_fCreamSmLocL[MAXPLAYERS + 1][3];
float  g_fCreamDeathHideUntil[MAXPLAYERS + 1];   // ventana anti-corpse
float  g_vCreamDeathOrigin[MAXPLAYERS + 1][3];
char   g_sCreamSeq[CREAM_ANIM_COUNT][24];       // nombre RESUELTO por estado
bool   g_bCreamSeqOK[CREAM_ANIM_COUNT];         // el estado resolvo?

// ConVars
ConVar g_cvCreamHealCD;
ConVar g_cvCreamHealRadius;
// v7.3-OM: el dash que pega
ConVar g_cvCreamDashDmgSiMin, g_cvCreamDashDmgSiMax, g_cvCreamDashDmgCommonMult;
// v7.1-OM: EL DASH del Lua — declaraciones (van ANTES de OnPluginStart)
ConVar g_cvCreamDashCd, g_cvCreamDashSpeed, g_cvCreamDashLift, g_cvCreamDashRange,
       g_cvCreamDashDmg, g_cvCreamDashBoost, g_cvCreamDashBoostT;
float g_fCreamDashUntil[MAXPLAYERS + 1];
float g_fCreamDashCdUntil[MAXPLAYERS + 1];
float g_fCreamBoostUntil[MAXPLAYERS + 1];
float g_fCreamDashNextScan[MAXPLAYERS + 1];
bool  g_bCreamBoostOn[MAXPLAYERS + 1];
bool  g_bCreamDashSndOK[3];
char  g_sCreamDashSndUse[3][64];
#define CREAM_DASHSND_GO    0
#define CREAM_DASHSND_HIT   1
#define CREAM_DASHSND_WALL  2

#define Cream_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// INICIALIZACION
// =======================

public void Cream_OnPluginStart()
{
    g_cvCreamHealCD       = CreateConVar("cream_heal_cooldown", "15.0", "Cooldown de la habilidad de curar", _, true, 0.0, true, 120.0);
    g_cvCreamHealRadius   = CreateConVar("cream_heal_radius", "125.0", "v7.3: radio de la cura [90 -> 125 pedido del owner; el MONTO y la velocidad de cura quedan IGUAL]", _, true, 50.0, true, 2000.0);

    // v7.1-OM: EL DASH del Lua GMod (survivors2 L2252-2281) — convars
    g_cvCreamDashCd     = CreateConVar("cream_dash_cd",     "15",  "Lua: Cream_Dash_cd 15");
    g_cvCreamDashSpeed  = CreateConVar("cream_dash_speed",  "500", "Lua: fwd*500 (impulso horizontal)");
    g_cvCreamDashLift   = CreateConVar("cream_dash_lift",   "145", "Lua: vel2.z = 145");
    g_cvCreamDashRange  = CreateConVar("cream_dash_range",  "90",  "Lua: FindInSphere 90");
    g_cvCreamDashDmg    = CreateConVar("cream_dash_dmg",    "5",   "v7.3: el COSTE — daño a una misma [20 -> 5, pedido del owner]");
    // v7.3-OM: EL DASH QUE PEGA (ronda 2 del owner)
    g_cvCreamDashDmgSiMin  = CreateConVar("cream_dash_dmg_si_min", "120",
        "v7.3: daño MINIMO del dash a los infectados ESPECIALES");
    g_cvCreamDashDmgSiMax  = CreateConVar("cream_dash_dmg_si_max", "180",
        "v7.3: daño MAXIMO del dash a los SI (120-180 por dash)");
    g_cvCreamDashDmgCommonMult = CreateConVar("cream_dash_dmg_commonmult", "1.5",
        "v7.3: los comunes pagan el daño del dash x esto (1.5 = moderadamente más que los SI: 180-270)");
    g_cvCreamDashBoost  = CreateConVar("cream_dash_boost",  "1.6", "Lua: OM_SpeedBoost_Damage +800 por 5s -> 1.6x en L4D2");
    g_cvCreamDashBoostT = CreateConVar("cream_dash_boosttime", "5", "Lua: 5s de speed boost");

    // v7.0-OM: avatar espejo (patron rouge_avatar / knux_avatar / shadow_avatar)
    g_cvCreamAvatar = CreateConVar("cream_avatar", "1", "Cream OM: avatar espejo (cream.mdl del VPK de recursos, patron Sonic/Tails/Amy/Metal/Knuckles/Rouge/Shadow)", _, true, 0.0, true, 1.0);

    // v7.0-OM: la MUERTE del avatar en el POST propio (lección Rouge
    // v3.77.49: ni el PRE ni el POST del manager tocan el avatar de Cream)
    HookEvent("player_death", Cream_Event_PlayerDeath);

    // Comandos
    RegConsoleCmd("sm_cream_heal", Command_CreamHeal);
    // Mantiene el nombre por compatibilidad con el Manager (Habilidad 2 = Dash slot)
    RegConsoleCmd("sm_cream_dash", Command_CreamRevive);
    // Comando nuevo y más intuitivo
    RegConsoleCmd("sm_cream_revive", Command_CreamRevive);
    RegConsoleCmd("sm_cream_revivir", Command_CreamRevive);

    // v3.77.8 (Cream v6.1): AutoExecConfig eliminado - config ÚNICA
    // del suite (Sonic_Suite.cfg, auto-guardada; ver manager). El
    // archivo viejo queda muerto y el manager lo borra del server.

    // Hot reload: hookear clientes ya conectados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            Cream_OnClientPutInServer(i);
        }
    }
}

public void Cream_OnMapStart()
{
    // Precache de sonidos
    PrecacheSound(SND_CREAM_HEAL, true);
    PrecacheSound(SND_CREAM_REVIVE, true);
    PrecacheSound(SND_CHEESE_DIE, true);
    PrecacheSound(SND_CHEESE_ALIVE, true);
    PrecacheSound(SND_CREAM_FALLBACK, true);

    // Precache de sprites (cacheados)
    g_iCreamGlowSprite  = PrecacheModel("materials/sprites/glow01.vmt", true);
    g_iCreamBeamSprite  = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    g_iCreamHaloSprite  = PrecacheModel("materials/sprites/halo01.vmt", true);

    // v7.1-OM: sonidos del DASH (probe dual om/ + OM/ como el Lua)
    {
        char low[96], up[96], probe[128];
        static const char sDashSnd[][64] = {
            "om/cream/Dash.wav",
            "om/cream/DashHit.wav",
            "om/cream/Wallhit.wav"
        };
        int ok = 0;
        for (int s = 0; s < sizeof(sDashSnd); s++)
        {
            Format(probe, sizeof(probe), "sound/%s", sDashSnd[s]);
            strcopy(g_sCreamDashSndUse[s], 64, sDashSnd[s]);
            g_bCreamDashSndOK[s] = FileExists(probe, true);
            if (!g_bCreamDashSndOK[s])
            {
                strcopy(low, 96, sDashSnd[s]);
                if (strncmp(low, "om/", 3) == 0)
                {
                    Format(up, sizeof(up), "OM/%s", low[3]);
                    Format(probe, sizeof(probe), "sound/%s", up);
                    if (FileExists(probe, true))
                    {
                        strcopy(g_sCreamDashSndUse[s], 64, up);
                        g_bCreamDashSndOK[s] = true;
                    }
                }
            }
            if (g_bCreamDashSndOK[s]) { PrecacheSound(g_sCreamDashSndUse[s], true); ok++; }
        }
        if (ok < sizeof(sDashSnd))
            PrintToServer("[Cream %s] sonidos om/cream del dash: %d/3 (los que faltan se saltan en silencio).", CREAM_INC_VERSION, ok);
    }

    // v7.0-OM: AVATAR — cream.mdl del VPK (detección FileExists estilo
    // star_stun: ve los VPK montados; sin el archivo TODO cae al
    // survivor normal, CERO dependencia)
    g_bCreamModelOK = FileExists(CREAM_OM_MODEL, true);
    if (g_bCreamModelOK) PrecacheModel(CREAM_OM_MODEL, true);

    // v7.0-OM: FSM del avatar (10 Hz, patron T_RougeAvatarThink) + el
    // probe de secuencias se re-resuelve en cada mapa (el .mdl puede
    // cambiar entre VPKs)
    g_bCreamSeqResolved = false;
    for (int s = 0; s < CREAM_ANIM_COUNT; s++) g_bCreamSeqOK[s] = false;
    delete g_hCreamAvatarThink;
    g_hCreamAvatarThink = CreateTimer(0.1, T_CreamAvatarThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // v5.1 FIX CRASH-LOG: los timers de heal llevan TIMER_FLAG_NO_MAPCHANGE
    // y mueren solos al cambiar de mapa. Hay que anular los handles ANTES
    // del reset para no hacer KillTimer() sobre handles ya liberados
    // (eso generaba errores "Invalid handle" en cada cambio de mapa).
    for (int i = 1; i <= MaxClients; i++)
    {
        g_hCreamHealTimer[i] = null;
        Cream_ResetState(i);
        g_fCreamReviveNextUse[i] = 0.0; // v6: CD de revive reiniciado por mapa
        g_fCreamRevivedImmuneUntil[i] = 0.0;
        g_fCreamRegenNext[i] = 0.0;     // v6 (R26): regeneración desde cero
    }
}

// =======================
// EVENTOS Y LIMPIEZA
// =======================

public void Cream_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;

    // v5.1: limpiar estado del slot (por si el jugador anterior fue revivido)
    g_fCreamRevivedImmuneUntil[client] = 0.0;

    // Anti double-hook
    SDKUnhook(client, SDKHook_OnTakeDamage, Cream_OnTakeDamage);
    SDKUnhook(client, SDKHook_PreThink, Cream_PreThink);

    SDKHook(client, SDKHook_OnTakeDamage, Cream_OnTakeDamage);
    SDKHook(client, SDKHook_PreThink, Cream_PreThink);
}

// Llamado desde el Manager
public void Cream_Event_PlayerSpawn(Event event, const char[] name, int client)
{
    if (client <= 0 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;

    if (g_iPlayerCharIdx[client] == CREAM_INDEX)
    {
        Cream_ResetState(client);
        g_bCheeseAlive[client] = true;
        g_bCheeseCanDespawn[client] = true;

        // v6 (R26): mensajes con el CD (ya no es "1 vez por ronda")
        EmitSoundToClient(client, SND_CHEESE_ALIVE);
        PrintToChat(client, "\x04[Cream]\x01 Cheese contigo: curación potenciada (10/tick) + \x05REGENERACION\x01 (+1 HP cada 2s).");
        PrintToChat(client, "\x04[Cream]\x01 \x05Resurreccion\x01: CD de \x05120s\x01 tras usarla (Sage la presta a 30s). La cura ya NO se interrumpe y te mueves normal al curar.");
    }
}

// Llamado desde el Manager al final de ronda
public void Cream_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    // v5: Resetear revive al final de ronda
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i <= MaxClients)
        {
            g_fCreamReviveNextUse[i] = 0.0;   // v6: CD de revive reiniciado por ronda
            Cream_ResetState(i);
        }
    }
}

void Cream_ResetState(int client)
{
    if (client < 0 || client > MaxClients) return;

    // v5 FIX BUG 2: Cancelar heal explicitamente
    g_bCreamHealActive[client] = false;
    g_fCreamRegenNext[client] = 0.0;   // v6 (R26): regeneración desde cero
    g_bCheeseCanDespawn[client] = true;
    g_fCheeseRespawnTime[client] = 0.0;
    g_fCheeseProtectTime[client] = 0.0;
    g_bCreamReviveImmune[client] = false;
    g_fCreamReviveImmuneEnd[client] = 0.0;
    g_fCreamRevivedImmuneUntil[client] = 0.0; // v5.1

    // v5 FIX BUG 3: Limpiar timer de heal de forma segura
    if (g_hCreamHealTimer[client] != null && g_hCreamHealTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hCreamHealTimer[client]);
        g_hCreamHealTimer[client] = null;
    }

    // v7.1-OM: reset del DASH
    g_fCreamDashUntil[client]  = 0.0;
    g_fCreamDashCdUntil[client]= 0.0;
    g_fCreamBoostUntil[client] = 0.0;
    g_fCreamDashNextScan[client] = 0.0;

    if (client >= 1 && client <= MaxClients && IsClientInGame(client))
    {
        SetEntityMoveType(client, MOVETYPE_WALK);
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

// =======================
// HELPERS DE SEGURIDAD
// =======================

// Clamp de HP
int Cream_ClampHP(int hp)
{
    if (hp < HP_MIN) return HP_MIN;
    if (hp > HP_MAX) return HP_MAX;
    return hp;
}

// Obtener maxHealth de forma segura
int Cream_GetMaxHealth(int client)
{
    int maxHp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
    if (maxHp <= 0) maxHp = 100;
    return maxHp;
}

// =======================
// PASIVAS: GLIDE (WASD STEERING) & AUTO-DEFENSA DE CHEESE
// =======================

public void Cream_PreThink(int client)
{
    if (!Cream_IsValidClient(client)) return;

    // v6 (R26): "el apartado de soporte que tendrá la regeneración":
    // Cream SIEMPRE regenera; SAGE con el set SOPORTE prestado
    // también (el set viaja con su regeneración)
    int idx = g_iPlayerCharIdx[client];
    bool isCream = (idx == CREAM_INDEX);
    if (!isCream && !(idx == SAGE_INDEX && g_iSageActiveSet[client] == SAGESET_CREAM))
        return;

    // v5 FIX BUG 4: ni glide ni regeneración incapacitada
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
    {
        return;
    }

    float now = GetEngineTime();

    // v6 (R26) - REGENERACION PASIVA: +1 HP cada CREAM_REGEN_INTERVAL
    // mientras viva y sin llegar al máximo (la incapacidad queda fuera)
    if (now >= g_fCreamRegenNext[client])
    {
        g_fCreamRegenNext[client] = now + CREAM_REGEN_INTERVAL;
        int hp = GetClientHealth(client);
        int maxhp = Cream_GetMaxHealth(client);
        if (hp > 0 && hp < maxhp)
        {
            int newHp = hp + CREAM_REGEN_AMOUNT;
            if (newHp > maxhp) newHp = maxhp;
            SetEntityHealth(client, newHp);
        }
    }

    if (!isCream) return;   // v6: glide/Cheese son identidad de Cream

    int flags = GetEntityFlags(client);
    int buttons = GetClientButtons(client);

    // 1. RECOBRAR A CHEESE (Si vida >= 50 y Cheese estaba desmayado)
    if (!g_bCheeseAlive[client] && GetClientHealth(client) >= 50)
    {
        if (g_fCheeseRespawnTime[client] == 0.0)
        {
            g_fCheeseRespawnTime[client] = now + CHEESE_RESPAWN_TIME;
        }
        else if (now >= g_fCheeseRespawnTime[client])
        {
            // v5.1 FIX: re-validar que siga con 50+ HP al despertar
            // (antes despertaba igual aunque la vida hubiera bajado)
            if (GetClientHealth(client) >= 50)
            {
                g_bCheeseAlive[client] = true;
                g_bCheeseCanDespawn[client] = true; // v5: re-habilitar despawn
                g_fCheeseRespawnTime[client] = 0.0;
                EmitSoundToClient(client, SND_CHEESE_ALIVE);
                PrintToChat(client, "\x04[Cream]\x01 Cheese se ha despertado y vuelve a tu lado!");
            }
            else
            {
                // Bajo de 50: reiniciar la espera hasta que vuelva a estar sana
                g_fCheeseRespawnTime[client] = 0.0;
            }
        }
    }

    // 2. AUTO-DEFENSA DE CHEESE (Corta agarres de especiales áutomaticamente)
    if (g_bCheeseAlive[client])
    {
        int attacker = Cream_GetAttacker(client);
        if (attacker > 0 && IsClientInGame(attacker) && IsPlayerAlive(attacker))
        {
            if (now >= g_fCheeseProtectTime[client])
            {
                g_fCheeseProtectTime[client] = now + CHEESE_PROTECT_CD;

                float pos[3]; GetClientAbsOrigin(client, pos);
                // v5.3: stagger SEGURO (auto-recuperación del estado del
                // motor a los 1.8s: sin el fix, el atacante quedaba
                // tambaleándose en el suelo sin levantarse)
                SIStagger_Auto(attacker, client, pos);
                SDKHooks_TakeDamage(attacker, client, client, 150.0, DMG_CLUB);

                // Forzar liberación del motor de red de L4D2
                Cream_ClearAllGrabs(client);

                EmitSoundToAll(SND_CHEESE_ALIVE, client);
                PrintToChat(client, "\x04[Cream]\x01 Cheese embistio al atacante y te ha salvado!");
            }
        }
    }

    // v5.1 FIX: no planear en escalera ni en agua profunda
    // (TeleportEntity en esos estados lanzaba al jugador de forma rara)
    bool onLadder    = (GetEntityMoveType(client) == MOVETYPE_LADDER);
    bool inDeepWater = (GetEntProp(client, Prop_Data, "m_nWaterLevel") > 1);

    // 3. LÓGICA DE PLANEO CON DIRECCION (Glide WASD)
    if (!(flags & FL_ONGROUND) && (buttons & IN_JUMP) && !onLadder && !inDeepWater)
    {
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);

        // Descenso lento controlado
        if (vel[2] < CREAM_GLIDE_DESCENT)
        {
            vel[2] = CREAM_GLIDE_DESCENT;
        }

        // Air Steering
        float fwdAng[3], fwd[3], right[3];
        GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
        GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);

        if (buttons & IN_FORWARD)   { vel[0] += fwd[0] * CREAM_GLIDE_ACCEL;  vel[1] += fwd[1] * CREAM_GLIDE_ACCEL; }
        if (buttons & IN_BACK)      { vel[0] -= fwd[0] * CREAM_GLIDE_ACCEL;  vel[1] -= fwd[1] * CREAM_GLIDE_ACCEL; }
        if (buttons & IN_MOVELEFT)  { vel[0] -= right[0] * CREAM_GLIDE_ACCEL; vel[1] -= right[1] * CREAM_GLIDE_ACCEL; }
        if (buttons & IN_MOVERIGHT) { vel[0] += right[0] * CREAM_GLIDE_ACCEL; vel[1] += right[1] * CREAM_GLIDE_ACCEL; }

        // Limitar velocidad horizontal
        float speed2D = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
        if (speed2D > CREAM_GLIDE_MAX_SPEED)
        {
            vel[0] = (vel[0] / speed2D) * CREAM_GLIDE_MAX_SPEED;
            vel[1] = (vel[1] / speed2D) * CREAM_GLIDE_MAX_SPEED;
        }

        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    }

    // 4. GESTION DE INMUNIDAD POST-REVIVE
    if (g_bCreamReviveImmune[client] && now > g_fCreamReviveImmuneEnd[client])
    {
        g_bCreamReviveImmune[client] = false;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }

    // 5. v7.1-OM: EL DASH DEL LUA — ventana de 1s + speed boost 5s
    Cream_DashTick(client, now);
}

// Devuelve el atacante actual de cualquier especial, o -1
int Cream_GetAttacker(int client)
{
    int attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
    if (attacker > 0) return attacker;
    attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
    if (attacker > 0) return attacker;
    attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
    if (attacker > 0) return attacker;
    attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
    if (attacker > 0) return attacker;
    attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
    if (attacker > 0) return attacker;
    return -1;
}

// Limpia todos los agarres del motor
void Cream_ClearAllGrabs(int client)
{
    // v5.3: liberación COMPLETA vía Pin_Release (antes solo se ponía a
    // -1 las props del lado de la victima: el hunter/jockey/smoker
    // segua "enganchado" del lado del motor, su música de agarre le
    // sonaba a Cream en loop y el atacante podía re-agarrar al instante).
    PinRelease_Cleanse(client);
}

// =======================
// GESTION DE DANO
// =======================

public Action Cream_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Cream_IsValidClient(victim)) return Plugin_Continue;

    // v5.1 FIX: inmunidad REAL de los REVIVIDOS por Resurrección (2s).
    // El header v5.0 la prometia, pero solo se implementaba el glow dorado.
    if (g_fCreamRevivedImmuneUntil[victim] > 0.0 && GetEngineTime() < g_fCreamRevivedImmuneUntil[victim])
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    if (g_iPlayerCharIdx[victim] != CREAM_INDEX) return Plugin_Continue;

    // 1. Inmunidad post-revive
    if (g_bCreamReviveImmune[victim])
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // v6 (R26): "ya no se interrumpe si la golpean" — la curación
    // SIGUE corriendo aunque reciba dano (fuera el cancel del v5)

    // 3. v5 FIX BUG 1: El desmayo de Cheese (con flag anti multi-despawn)
    int currentHealth = GetClientHealth(victim);
    if (g_bCheeseAlive[victim] && g_bCheeseCanDespawn[victim] && (currentHealth - damage) < float(CHEESE_DESPAWN_HP))
    {
        g_bCheeseAlive[victim] = false;
        g_bCheeseCanDespawn[victim] = false; // v5: Evitar despawns repetidos
        g_fCheeseRespawnTime[victim] = 0.0;
        EmitSoundToClient(victim, SND_CHEESE_DIE);
        PrintToChat(victim, "\x04[Cream]\x01 Cheese se ha desmayado! Curate sobre 50 HP para que despierte.");
    }

    return Plugin_Continue;
}

// =======================
// HABILIDAD 1: HEAL (MOVILIDAD PARCIAL Y AUTO-HEAL)
// =======================

public Action Command_CreamHeal(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Cream_IsValidClient(client)) return Plugin_Handled;
    // v6 (R26): Sage con el SET SOPORTE prestado cura igual que Cream
    if (g_iPlayerCharIdx[client] != CREAM_INDEX
        && !(g_iPlayerCharIdx[client] == SAGE_INDEX && g_iSageActiveSet[client] == SAGESET_CREAM))
        return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fCreamHealCooldown[client])
    {
        PrintToChat(client, "\x04[Cream]\x01 Curación en enfriamiento (\x05%.1fs\x01)", g_fCreamHealCooldown[client] - now);
        return Plugin_Handled;
    }

    // v6 (R26): "puede curar al moverse" — FUERA el requisito de pisar
    // suelo: la cura acompania el movimiento completo (aire incluido)

    // v5.1: tampoco incapacitada
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
    {
        PrintToChat(client, "\x04[Cream]\x01 No puedes curar incapacitada.");
        return Plugin_Handled;
    }

    // v5.1 QoL: el cooldown cuenta desde el INICIO del heal (antes se
    // contaba desde que terminaba o se cancelaba, alargándolo de facto)
    g_fCreamHealCooldown[client] = now + ((g_cvCreamHealCD != null) ? g_cvCreamHealCD.FloatValue : 15.0);

    // v6 (R26): "mejorada... puede curar al moverse": SIN ralentización
    // (la v5 clavaba m_flLaggedMovementValue a 0.3 — se movía al 30%).
    // Se mueve al 100% durante toda la curación.
    g_bCreamHealActive[client] = true;

    // v7.0-OM: one-shot de la CURA sobre las DOS copias del avatar (si
    // el .mdl trae la anim; Sage con el set prestado no tiene avatar = no-op)
    Cream_AvatarOneShot(client, CREAM_ST_HEAL, CREAM_LOCK_HEAL);

    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(CREAM_HEAL_TICKS);

    g_hCreamHealTimer[client] = CreateTimer(CREAM_HEAL_TICK_TIME, T_CreamHealTick, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    PrintToChat(client, "\x04[Cream]\x01 Curación de área \x05MOVIL\x01 iniciada (velocidad 100%, sin interrupciones)...");
    return Plugin_Handled;
}

public Action T_CreamHealTick(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    int ticksLeft = pack.ReadCell();

    int client = GetClientOfUserId(userid);

    // v5 FIX BUG 3: Verificar cliente en cada tick
    if (!Cream_IsValidClient(client) || !g_bCreamHealActive[client])
    {
        delete pack;
        if (client > 0 && client <= MaxClients) g_hCreamHealTimer[client] = null;
        return Plugin_Stop;
    }

    ticksLeft--;

    if (ticksLeft <= 0)
    {
        Cream_CancelHeal(client);
        PrintToChat(client, "\x04[Cream]\x01 Curación de área completada."); // v5.1 QoL
        delete pack;
        return Plugin_Stop;
    }

    pack.Position = view_as<DataPackPos>(0);
    pack.WriteCell(userid);
    pack.WriteCell(ticksLeft);

    float radius = (g_cvCreamHealRadius != null) ? g_cvCreamHealRadius.FloatValue : CREAM_HEAL_RADIUS;
    float clientPos[3]; GetClientAbsOrigin(client, clientPos);
    int healAmount = g_bCheeseAlive[client] ? CHEESE_ALIVE_HEAL : CHEESE_DEAD_HEAL;
    bool anyoneHealed = false;

    // Curar Aliados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_SURVIVOR) continue;

        float targetPos[3]; GetClientAbsOrigin(i, targetPos);
        if (GetVectorDistance(clientPos, targetPos) <= radius)
        {
            int hp = GetClientHealth(i);
            int maxhp = Cream_GetMaxHealth(i);
            if (hp < maxhp)
            {
                int newHp = Cream_ClampHP(hp + healAmount);
                if (newHp > maxhp) newHp = maxhp;
                SetEntityHealth(i, newHp);
                anyoneHealed = true;
            }
        }
    }

    // Auto-curación
    int myHp = GetClientHealth(client);
    int myMaxhp = Cream_GetMaxHealth(client);
    if (myHp < myMaxhp)
    {
        int newMyHp = Cream_ClampHP(myHp + healAmount);
        if (newMyHp > myMaxhp) newMyHp = myMaxhp;
        SetEntityHealth(client, newMyHp);
        // v5.1 FIX: la autocuración cuenta como curación válida (antes, si
        // Cream estaba sola, el heal se autointerrumpia a los 3 ticks)
        anyoneHealed = true;
    }

    if (!anyoneHealed && ticksLeft < CREAM_HEAL_TICKS - 2)
    {
        PrintToChat(client, "\x04[Cream]\x01 Nadie cerca. Curación cancelada.");
        Cream_CancelHeal(client);
        delete pack;
        return Plugin_Stop;
    }

    // Efecto visual
    if (g_iCreamGlowSprite > 0)
    {
        TE_SetupBeamRingPoint(clientPos, 10.0, radius, g_iCreamGlowSprite, 0, 0, 0, 0.5, 5.0, 0.0, {0, 255, 100, 100}, 0, 0);
        TE_SendToAll();
    }
    EmitSoundToAll(SND_CREAM_HEAL, client);

    return Plugin_Continue;
}

void Cream_CancelHeal(int client)
{
    if (client < 1 || client > MaxClients) return;

    g_bCreamHealActive[client] = false;

    if (IsClientInGame(client))
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }

    if (g_hCreamHealTimer[client] != null && g_hCreamHealTimer[client] != INVALID_HANDLE)
    {
        // No matar el timer aquí porque está en medio de su callback
        g_hCreamHealTimer[client] = null;
    }

    // v5.1: el cooldown ya se fija al INICIAR el heal (Command_CreamHeal),
    // no al terminarlo.
}

// =======================
// HABILIDAD 2: RESURRECCION (v6: CD 120s — Sage la presta a 30s)
// =======================

public Action Command_CreamRevive(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Cream_IsValidClient(client)) return Plugin_Handled;
    // v6 (R26): Sage con el SET SOPORTE prestado también revive (30s)
    if (g_iPlayerCharIdx[client] != CREAM_INDEX
        && !(g_iPlayerCharIdx[client] == SAGE_INDEX && g_iSageActiveSet[client] == SAGESET_CREAM))
        return Plugin_Handled;

    // v6 (R26): "su habilidad revivir tendrá cd en vez de esperar 1
    // ronda entera será de 120 seg. Para sage ella solo esperara 30 seg"
    float now = GetEngineTime();
    float reviveCD = (g_iPlayerCharIdx[client] == SAGE_INDEX) ? SAGE_REVIVE_CD : CREAM_REVIVE_CD;
    if (now < g_fCreamReviveNextUse[client])
    {
        PrintCenterText(client, "Resurrección recargando: %.0fs", g_fCreamReviveNextUse[client] - now);
        PrintToChat(client, "\x04[Cream]\x01 Resurrección en recarga: \x05%.0fs\x01 (tu CD: %.0fs).", g_fCreamReviveNextUse[client] - now, reviveCD);
        return Plugin_Handled;
    }

    // Buscar jugadores muertos
    ArrayList deadPlayers = new ArrayList();
    Cream_FindDeadSurvivors(client, deadPlayers);

    if (deadPlayers.Length == 0)
    {
        delete deadPlayers;
        PrintCenterText(client, "No hay jugadores muertos para revivir.");
        PrintToChat(client, "\x04[Cream]\x01 No hay jugadores muertos para revivir. El uso no se consume.");
        return Plugin_Handled;
    }

    // Consumir el uso (solo si hay muertos): CD desde el USO
    g_fCreamReviveNextUse[client] = now + reviveCD;

    // Aplicar inmunidad a Cream por 3 segundos
    g_bCreamReviveImmune[client] = true;
    g_fCreamReviveImmuneEnd[client] = GetEngineTime() + CREAM_REVIVE_IMMUNE_TIME;
    SetEntityRenderColor(client, 255, 255, 150, 255); // Amarillo dorado

    // v7.0-OM: el DORADO también en el AVATAR (el cuerpo esta
    // RENDER_NONE con el avatar montado — el tinte del survivor solo
    // no se veía) + one-shot de RESURRECCION sobre las DOS copias
    Cream_AvatarSetColor(client, 255, 255, 150, 255);
    Cream_AvatarOneShot(client, CREAM_ST_REVIVE, CREAM_LOCK_REVIVE);

    // Revivir a todos los muertos
    int revivedCount = 0;
    float creamPos[3];
    GetClientAbsOrigin(client, creamPos);

    for (int i = 0; i < deadPlayers.Length; i++)
    {
        int deadClient = deadPlayers.Get(i);
        if (Cream_RevivePlayer(client, deadClient, creamPos))
        {
            revivedCount++;
        }
    }

    delete deadPlayers;

    // Efectos visuales de revivir
    Cream_CreateReviveEffects(client, creamPos);

    // Feedback
    PrintToChatAll("\x04[Cream]\x05 %N\x01 ha revivido a \x05%d\x01 compañero(s) con HP completa!", client, revivedCount);
    PrintCenterText(client, "RESURRECCION!\nRevividos: %d", revivedCount);

    // Timer para quitar la inmunidad de Cream
    CreateTimer(CREAM_REVIVE_IMMUNE_TIME, T_CreamEndReviveImmune, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Handled;
}

// Busca todos los sobrevivientes muertos del mapa
void Cream_FindDeadSurvivors(int creamClient, ArrayList deadList)
{
    if (deadList == null) return;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == creamClient) continue;
        if (!IsClientInGame(i)) continue;
        if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
        if (IsPlayerAlive(i)) continue;

        deadList.Push(i);
    }
}

// ============================================================================
// v6.0: SISTEMA DE RESURRECCION - L4D_RespawnPlayer minimalista
// ============================================================================
// Enfoque minimalista y probado:
// 1. Cream_RevivePlayer: valida y programa un timer simple
// 2. T_CreamDoRevive: hace L4D_RespawnPlayer + sets mínimos + teleport
// 3. T_CreamPostRevive: 0.3s después, re-aplica modelo + sets
//
// Filosofia: MENOS es MÁS. Cuantas menos cosas hagamos al mismo tiempo,
// más probable es que el motor procese correctamente cada cambio.
// ============================================================================

bool Cream_RevivePlayer(int creamClient, int deadClient, float spawnPos[3])
{
    if (deadClient < 1 || deadClient > MaxClients) return false;
    if (!IsClientInGame(deadClient)) return false;
    if (IsPlayerAlive(deadClient)) return false;

    int currentTeam = GetClientTeam(deadClient);
    if (currentTeam != TEAM_SURVIVOR && currentTeam != 1) return false;

    // Programar el revive en un timer de 0.1s
    // Esto es CRITICO: si intentamos revivir en el mismo frame que el comando,
    // el motor de L4D2 puede ignorar el respawn.
    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(deadClient));
    dp.WriteCell(GetClientUserId(creamClient));
    dp.WriteFloat(spawnPos[0]);
    dp.WriteFloat(spawnPos[1]);
    dp.WriteFloat(spawnPos[2]);
    CreateTimer(0.1, T_CreamDoRevive, dp, TIMER_FLAG_NO_MAPCHANGE);

    return true;
}

// FASE 2: Realiza el respawn con la MÍNIMA cantidad de cambios posible
public Action T_CreamDoRevive(Handle timer, DataPack dp)
{
    dp.Reset();
    int deadUid = dp.ReadCell();
    int creamUid = dp.ReadCell();
    float spawnPos[3];
    spawnPos[0] = dp.ReadFloat();
    spawnPos[1] = dp.ReadFloat();
    spawnPos[2] = dp.ReadFloat();
    delete dp;

    int deadClient = GetClientOfUserId(deadUid);
    int creamClient = GetClientOfUserId(creamUid);

    if (deadClient <= 0 || !IsClientInGame(deadClient)) return Plugin_Stop;
    if (IsPlayerAlive(deadClient)) return Plugin_Stop;

    // PASO 1: Forzar team a survivor (sin esto, L4D_RespawnPlayer falla)
    if (GetClientTeam(deadClient) != TEAM_SURVIVOR)
    {
        ChangeClientTeam(deadClient, TEAM_SURVIVOR);
    }

    // PASO 2: Llamar a L4D_RespawnPlayer (native de left4dhooks)
    // Esta native internamente invoca a CTerrorPlayer::RespawnPlayer() que es
    // lo que el motor usa para el defibrilador nativo.
    L4D_RespawnPlayer(deadClient);

    // PASO 3: Verificar que revivió
    if (!IsPlayerAlive(deadClient))
    {
        if (creamClient > 0 && IsClientInGame(creamClient))
            PrintToChat(creamClient, "\x04[Cream]\x01 No se pudo revivir a %N.", deadClient);
        return Plugin_Stop;
    }

    // PASO 4: Setear HP (L4D_RespawnPlayer deja HP al máximo del personaje)
    SetEntityHealth(deadClient, Cream_ClampHP(CREAM_REVIVE_HP));

    // PASO 4b: v5.1 — inmunidad REAL de dano (2s) para el revivido.
    // Antes solo se ponía el glow dorado; el bloqueo está en Cream_OnTakeDamage.
    g_fCreamRevivedImmuneUntil[deadClient] = GetEngineTime() + CREAM_REVIVE_VICTIM_IMMUNE;

    // PASO 5: Teleportar a la posición de Cream (sin trace, simpler)
    float zeroVel[3] = {0.0, 0.0, 0.0};
    TeleportEntity(deadClient, spawnPos, NULL_VECTOR, zeroVel);

    // PASO 6: Glow dorado temporal (feedback visual)
    // v5.2 FIX: el color estaba en orden invertido ((255<<16)|(215<<8) =
    // azul claro (0,215,255) en la convención R+G<<8+B<<16 del juego).
    // Oro real = R=255, G=215, B=0 -> 255 | (215 << 8) = 55295.
    SetEntProp(deadClient, Prop_Send, "m_iGlowType", 3);
    SetEntProp(deadClient, Prop_Send, "m_glowColorOverride", 255 | (215 << 8));
    SetEntProp(deadClient, Prop_Send, "m_bFlashing", 1);

    // PASO 7: Efectos visuales y sonidos
    float victimPos[3];
    GetClientAbsOrigin(deadClient, victimPos);
    victimPos[2] += 20.0;

    if (g_iCreamGlowSprite > 0)
    {
        TE_SetupBeamRingPoint(victimPos, 10.0, 200.0, g_iCreamGlowSprite, g_iCreamHaloSprite, 0, 15, 1.0, 15.0, 2.0, {255, 215, 0, 220}, 5, 0);
        TE_SendToAll();
    }
    TE_SetupSparks(victimPos, NULL_VECTOR, 8, 4);
    TE_SendToAll();

    EmitSoundToAll(SND_CREAM_REVIVE, deadClient, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);
    EmitSoundToAll(SND_CHEESE_ALIVE, deadClient, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // PASO 8: Feedback
    PrintCenterText(deadClient, "HAS SIDO REVIVIDO POR CREAM!\nHP: 100");
    if (creamClient > 0 && IsClientInGame(creamClient))
        PrintToChat(deadClient, "\x04[Cream]\x05 %N\x01 te ha revivido! HP: %d", creamClient, CREAM_REVIVE_HP);

    // PASO 9: Programar FASE 3 a 0.3s para re-setear el modelo
    // (FIX del bug de cabeza flotante / invisible)
    DataPack postPack = new DataPack();
    postPack.WriteCell(GetClientUserId(deadClient));
    postPack.WriteCell(GetClientUserId(creamClient));
    postPack.WriteFloat(spawnPos[0]);
    postPack.WriteFloat(spawnPos[1]);
    postPack.WriteFloat(spawnPos[2]);
    CreateTimer(0.3, T_CreamPostRevive, postPack, TIMER_FLAG_NO_MAPCHANGE);

    // PASO 10: Timer para limpiar glow
    DataPack cleanupPack = new DataPack();
    cleanupPack.WriteCell(GetClientUserId(deadClient));
    CreateTimer(CREAM_REVIVE_VICTIM_IMMUNE, T_CreamReviveVictimCleanup, cleanupPack, TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Stop;
}

// FASE 3: Re-setea el modelo 0.3s después del revive
// FIX del bug de "cabeza flotante" (solo se ve mitad del cuerpo)
public Action T_CreamPostRevive(Handle timer, DataPack pack)
{
    pack.Reset();
    int deadUid = pack.ReadCell();
    int creamUid = pack.ReadCell();
    float pos[3];
    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();
    delete pack;

    int deadClient = GetClientOfUserId(deadUid);
    int creamClient = GetClientOfUserId(creamUid);

    if (deadClient <= 0 || !IsClientInGame(deadClient)) return Plugin_Stop;

    // Si murió de nuevo, reintentar una vez
    if (!IsPlayerAlive(deadClient))
    {
        if (creamClient > 0 && IsClientInGame(creamClient))
        {
            ChangeClientTeam(deadClient, TEAM_SURVIVOR);
            L4D_RespawnPlayer(deadClient);
            if (IsPlayerAlive(deadClient))
            {
                SetEntityHealth(deadClient, Cream_ClampHP(CREAM_REVIVE_HP));
                float zero[3] = {0.0, 0.0, 0.0};
                TeleportEntity(deadClient, pos, NULL_VECTOR, zero);
            }
        }
        return Plugin_Stop;
    }

    // === FIX CRITICO: Re-setear el modelo ===
    // Esto arregla el bug de cabeza flotante
    char modelName[256];
    GetClientModel(deadClient, modelName, sizeof(modelName));
    if (modelName[0] != '\0')
    {
        SetEntityModel(deadClient, modelName);
    }

    // Reset de la secuencia de animación (deja de reproducir anim de muerte)
    if (HasEntProp(deadClient, Prop_Send, "m_nSequence"))
        SetEntProp(deadClient, Prop_Send, "m_nSequence", 0);

    if (HasEntProp(deadClient, Prop_Send, "m_flCycle"))
        SetEntPropFloat(deadClient, Prop_Send, "m_flCycle", 0.0);

    if (HasEntProp(deadClient, Prop_Send, "m_flPlaybackRate"))
        SetEntPropFloat(deadClient, Prop_Send, "m_flPlaybackRate", 1.0);

    // Reset de render (por si acaso)
    SetEntityRenderMode(deadClient, RENDER_NORMAL);
    SetEntityRenderColor(deadClient, 255, 255, 255, 255);

    // Reset de movimiento
    SetEntPropFloat(deadClient, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntityMoveType(deadClient, MOVETYPE_WALK);

    // Limpiar estados negativos
    SetEntProp(deadClient, Prop_Send, "m_isIncapacitated", 0);
    SetEntProp(deadClient, Prop_Send, "m_isHangingFromLedge", 0);
    SetEntPropEnt(deadClient, Prop_Send, "m_pounceAttacker", -1);
    SetEntPropEnt(deadClient, Prop_Send, "m_tongueOwner", -1);
    SetEntPropEnt(deadClient, Prop_Send, "m_jockeyAttacker", -1);
    SetEntPropEnt(deadClient, Prop_Send, "m_carryAttacker", -1);
    SetEntPropEnt(deadClient, Prop_Send, "m_pummelAttacker", -1);

    // Asegurar HP
    SetEntityHealth(deadClient, Cream_ClampHP(CREAM_REVIVE_HP));

    // v5.1 QoL: kit básico para que el revivido no quede indefenso
    // (pistola si no tiene secundaria + pastillas si no lleva)
    if (GetPlayerWeaponSlot(deadClient, 1) == -1)
        GivePlayerItem(deadClient, "pistol");
    if (GetPlayerWeaponSlot(deadClient, 4) == -1)
        GivePlayerItem(deadClient, "pain_pills");

    // Re-teleportar por seguridad
    float zero[3] = {0.0, 0.0, 0.0};
    TeleportEntity(deadClient, pos, NULL_VECTOR, zero);

    return Plugin_Stop;
}

// Limpieza del revivido (quitar glow)
public Action T_CreamReviveVictimCleanup(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    delete pack;

    int client = GetClientOfUserId(userid);
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        SetEntProp(client, Prop_Send, "m_iGlowType", 0);
        SetEntProp(client, Prop_Send, "m_bFlashing", 0);
    }
    return Plugin_Stop;
}

// Efectos visuales de revivir en Cream
void Cream_CreateReviveEffects(int client, float pos[3])
{
    pos[2] += 30.0;

    // Ring dorado expansivo grande
    if (g_iCreamGlowSprite > 0)
    {
        TE_SetupBeamRingPoint(pos, 10.0, 800.0, g_iCreamGlowSprite, g_iCreamHaloSprite, 0, 15, 1.0, 30.0, 3.0, {255, 215, 0, 220}, 10, 0);
        TE_SendToAll();

        // Ring secundario más pequeño
        TE_SetupBeamRingPoint(pos, 10.0, 300.0, g_iCreamBeamSprite, g_iCreamHaloSprite, 0, 15, 0.6, 15.0, 2.0, {255, 255, 100, 200}, 5, 0);
        TE_SendToAll();
    }

    // Chispas
    TE_SetupSparks(pos, NULL_VECTOR, 10, 5);
    TE_SendToAll();

    // Sonido angelical (con fallback)
    EmitSoundToAll(SND_CREAM_REVIVE, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);
}

// Fin de la inmunidad de Cream
public Action T_CreamEndReviveImmune(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        g_bCreamReviveImmune[client] = false;
        SetEntityRenderColor(client, 255, 255, 255, 255);
        Cream_AvatarTintReset(client);   // v7.0: el avatar vuelve a su color
        PrintToChat(client, "\x04[Cream]\x01 Inmunidad post-revive terminada.");
    }
    return Plugin_Stop;
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
// v7.0-OM: ESTA FUNCION NO TOCA EL AVATAR — la muerte del avatar (ragdoll
// + anti-corpse + KillAvatarOnly) vive en el POST propio del modulo
// (Cream_Event_PlayerDeath, más abajo), la lección Rouge v3.77.49: si el
// manager la llamara ANTES de ese POST, mataría el avatar y el ragdoll
// JAMÁS saldría. Aquí solo el reset clasico (cancela heal, libera timers).
public void Cream_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != CREAM_INDEX) return;
    Cream_ResetState(client);
}

// v7.0-OM: limpieza al DESCARGAR el plugin (OnPluginEnd del manager) —
// aquí SI se mata el avatar con restore del cuerpo (no murió nadie: el
// plugin se va). SIN ragdoll.
public void Cream_OnPluginEnd(int client)
{
    if (client < 1 || client > MaxClients) return;
    Cream_KillAvatar(client);
    Cream_ResetState(client);
}

// =====================================================================
// =====================================================================
//  v7.0-OM: AVATAR ESPEJO CREAM.MDL (8o AVATAR DEL SUITE)
//  Patron Shadow v6.0 / Rouge v10.2 textual, adaptado al kit de Cream:
//   - cream.mdl del VPK (models/Noodles/OM/): copia R (los demas) +
//     copia L (la dueña) + cuerpo oculto + FSM 10 Hz + ragdoll de
//     muerte 15s + anti-corpse 2s + adopción de huerfanos + pulso de
//     pausa.
//   - FSM POR PROBE (receta Amy v92): cream.mdl no trae tabla
//     documentada — cada estado tiene una CADENA de candidatos y gana
//     el primer nombre que exista en el modelo; si falta, su estado
//     base lo cubre (nunca T-pose).
//   - FLY DE OREJAS: su glide de SPACE (pasiva existente del v5) tiene
//     SU estado propio en el aire (como el HOVER de Shadow / el aleteo
//     de Rouge).
//   - LOWHEALTH = CHEESE_DESPAWN_HP (30): el umbral de "Cheese
//     desmayado" — el avatar se ve malito justo cuando su compañero
//     chao está fuera de combate.
//   - ONE-SHOTS: la CURA y la RESURRECCION tienen su animación sobre
//     las DOS copias (si el .mdl las trae).
//   - Tinte DORADO del avatar durante la inmunidad post-resurrección
//     (antes el tinte del survivor era invisible: el cuerpo esta
//     RENDER_NONE con el avatar montado).
// =====================================================================
// =====================================================================

// =====================================================================
// RESOLUCION DE SECUENCIAS POR PROBE (receta Amy v92 / Shadow v6.0):
// SourcePawn no trae LookupSequence — se dispara SetAnimation(nombre)
// y se lee m_nSequence: si el índice CAMBIO, el nombre existe en el
// .mdl. Se resuelve UNA vez por mapa (al nacer el primer avatar, todo
// dentro del mismo frame — el cliente solo ve el resultado final).
// =====================================================================
void Cream_ResolveTry(int av, int state, const char[] name)
{
    if (g_bCreamSeqOK[state]) return;
    if (!HasEntProp(av, Prop_Send, "m_nSequence")) return;

    int before = GetEntProp(av, Prop_Send, "m_nSequence");
    SetVariantString(name);
    AcceptEntityInput(av, "SetAnimation");
    int after = GetEntProp(av, Prop_Send, "m_nSequence");

    if (after != before)
    {
        strcopy(g_sCreamSeq[state], sizeof(g_sCreamSeq[]), name);
        g_bCreamSeqOK[state] = true;
    }
}

void Cream_ResolveSeqs(int av)
{
    if (g_bCreamSeqResolved) return;
    g_bCreamSeqResolved = true;

    // cadena de candidatos por estado (nombres GMod + variantes)
    for (int st = 0; st < CREAM_ANIM_COUNT; st++)
    {
        for (int c = 0; c < CREAM_SEQ_MAX_CAND; c++)
        {
            if (g_sCreamSeqCand[st][c][0] == '\0') break;
            Cream_ResolveTry(av, st, g_sCreamSeqCand[st][c]);
            if (g_bCreamSeqOK[st]) break;
        }
    }

    // 2a pasada del idle (truco Amy v92: si el default del modelo YA
    // era idle, la primera prueba no movió el índice — ahora el actual
    // es otro y si "idle" existe, se registra)
    Cream_ResolveTry(av, CREAM_ST_IDLE, "idle");

    // fallbacks de las variantes que el modelo no traiga: la base
    // cubre el hueco (nunca T-pose)
    int fallbacks[CREAM_ANIM_COUNT];
    for (int fb = 0; fb < CREAM_ANIM_COUNT; fb++) fallbacks[fb] = -1;
    fallbacks[CREAM_ST_IDLE_LOW]    = CREAM_ST_IDLE;
    fallbacks[CREAM_ST_WALK_LOW]    = CREAM_ST_WALK;
    fallbacks[CREAM_ST_RUN_LOW]     = CREAM_ST_RUN;
    fallbacks[CREAM_ST_DOWNED_IDLE] = CREAM_ST_IDLE;
    fallbacks[CREAM_ST_DOWNED_WALK] = CREAM_ST_WALK;
    fallbacks[CREAM_ST_FLY]         = CREAM_ST_FALL;
    fallbacks[CREAM_ST_HEAL]        = CREAM_ST_IDLE;
    fallbacks[CREAM_ST_REVIVE]      = CREAM_ST_IDLE;

    for (int s = 0; s < CREAM_ANIM_COUNT; s++)
    {
        if (g_bCreamSeqOK[s] || fallbacks[s] < 0) continue;
        if (g_bCreamSeqOK[fallbacks[s]])
        {
            strcopy(g_sCreamSeq[s], sizeof(g_sCreamSeq[]), g_sCreamSeq[fallbacks[s]]);
            g_bCreamSeqOK[s] = true;
        }
    }
}

// la secuencia a usar para un estado (con triple red de seguridad)
void Cream_SeqFor(int state, char out[24])
{
    if (g_bCreamSeqOK[state])
        strcopy(out, 24, g_sCreamSeq[state]);
    else if (g_bCreamSeqOK[CREAM_ST_IDLE])
        strcopy(out, 24, g_sCreamSeq[CREAM_ST_IDLE]);
    else
        strcopy(out, 24, "idle");
}

// =====================================================================
// CREACION / MUERTE DE LAS COPIAS (receta Rouge v10.2 / Shadow v6.0)
// =====================================================================
int Cream_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
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
    g_fCreamBodyYaw[client]  = ang[1];
    g_fCreamYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fCreamBodyYaw[client], loc);

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
        g_fCreamSmLoc[client][k]  = loc[k];
        g_fCreamSmLocL[client][k] = loc[k];
    }
    g_bCreamSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// v72-OM (adopción): un prop con NUESTRO nombre que esta FSM no rastrea
// es un huerfano por definición — muere en el instante del montaje.
bool Cream_IsMyAvatarRef(int ref)
{
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iCreamAvatar[i] == ref) return true;
        if (g_iCreamAvatarL[i] == ref) return true;
    }
    return false;
}

void Cream_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "cream_avatar_om", "cream_avatar_om_l" };
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
                if (Cream_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
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
        PrintToServer("[Cream v7.0-OM] Adopción del montaje: %d huerfano(s) del avatar eliminado(s).", ng);
}

// Monta el avatar completo (R + L + cuerpo oculto). pulsePause SOLO para
// montajes de ciclo de vida (spawn/selección/reparación tardia de la FSM).
void Cream_CreateAvatar(int client, bool pulsePause = true)
{
    if (!g_bCreamModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;

    // v72-OM (reemplazo limpio): si este cliente ya tenía un R o L vivo
    // (montaje doble por orden raro de eventos), muere AQUÍ enterito.
    {
        int oldR = EntRefToEntIndex(g_iCreamAvatar[client]);
        if (g_iCreamAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Cream_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iCreamAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iCreamAvatarL[client]);
        if (g_iCreamAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Cream_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iCreamAvatarL[client] = 0;
    }

    // v72-OM: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje.
    Cream_KillGhostAvatarProps();

    int av = Cream_CreateAvatarProp(client, CREAM_OM_MODEL, CREAM_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    // resolver las secuencias contra el .mdl REAL (probe Amy v92, UNA
    // vez por mapa — el primer avatar nace resolviendo para todos)
    Cream_ResolveSeqs(av);

    char seqIdle[24];
    Cream_SeqFor(CREAM_ST_IDLE, seqIdle);
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");
    g_iCreamAnimState[client] = 0;

    SDKHook(av, SDKHook_SetTransmit, Cream_TransmitAvatarR);

    g_iCreamAvatarL[client] = 0;
    Cream_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iCreamBodyRender[client] = view_as<int>(curMode);
    else if (g_iCreamBodyRender[client] == -1)
        g_iCreamBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    // v7.0: si la inmunidad post-resurrección está activa, el tinte
    // DORADO sigue encendido tras el remontaje
    if (g_bCreamReviveImmune[client])
        Cream_AvatarSetColor(client, 255, 255, 150, 255);

    g_iCreamAvatar[client] = EntIndexToEntRef(av);

    // per-tick: angulos locales (contra-rotación del parent)
    SDKHook(client, SDKHook_PostThink, Cream_AvatarFollow);

    // PULSO DE PAUSA en cada montaje de ciclo de vida (la misma infra
    // sv_pausable del suite; convar tails_pausefix manda para TODOS los
    // avatares — es UN solo sistema, 8o avatar del suite)
    if (pulsePause)
        Tails_PauseFix_Trigger(client);
}

void Cream_CreateAvatarL(int client)
{
    if (!g_bCreamModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iCreamAvatar[client] == 0) return;

    int av = Cream_CreateAvatarProp(client, CREAM_OM_MODEL, CREAM_AVATAR_NAME_L);
    if (av == 0) return;

    char seqIdle[24];
    Cream_SeqFor(CREAM_ST_IDLE, seqIdle);
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Cream_TransmitAvatarL);

    g_iCreamAvatarL[client] = EntIndexToEntRef(av);
}

void Cream_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iCreamAvatarL[client]);
    if (g_iCreamAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Cream_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iCreamAvatarL[client] = 0;
}

// Mata las copias R+L y devuelve el cuerpo. SIN desenganchar el follow
// (lo hace Cream_KillAvatar).
void Cream_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    Cream_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iCreamAvatar[client]);
    if (g_iCreamAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Cream_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iCreamAvatar[client] = 0;
    g_iCreamAnimState[client] = -1;

    // devolver el cuerpo (spectate/revive/cambio de personaje)
    if (IsClientInGame(client) && g_iCreamBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iCreamBodyRender[client]));
        g_iCreamBodyRender[client] = -1;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Cream_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Cream_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Cream_AvatarFollow);
}

// Transmit filters (patron Rouge/Sonic/Metal/Shadow): la R no la ve su
// dueña (tiene su L), la L la ve SOLO su dueña.
public Action Cream_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iCreamAvatar[i] != 0 && EntRefToEntIndex(g_iCreamAvatar[i]) == entity)
        {
            if (client == i && g_iCreamAvatarL[i] != 0
                && EntRefToEntIndex(g_iCreamAvatarL[i]) > 0)
                return Plugin_Handled;   // la dueña tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

public Action Cream_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iCreamAvatarL[i] != 0 && EntRefToEntIndex(g_iCreamAvatarL[i]) == entity)
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
public void Cream_AvatarFollow(int client)
{
    if (g_iCreamAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Cream_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    // ---- yaw objetivo: dirección REAL del movimiento ----
    float yawObj = g_fCreamBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fCreamBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    // ---- giro suave hacia el objetivo (~900 grados/s) ----
    float now = GetEngineTime();
    float dt  = now - g_fCreamYawLastT[client];
    g_fCreamYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fCreamBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fCreamBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bCreamSmSnap[client];
    GetClientAbsAngles(client, par);
    float yawPuppet = g_fCreamBodyYaw[client];

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iCreamAvatar[client]);
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
            loc[1] = Tails_UnwrapYaw(g_fCreamSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fCreamSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fCreamSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }

    // ---- copia L: contra-rotada contra los EYE de la dueña ----
    if (g_iCreamAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iCreamAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3], locL[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], yawPuppet, locL);
            locL[1] = Tails_UnwrapYaw(g_fCreamSmLocL[client][1], locL[1]);
            Tails_ExpDamp(locL, g_fCreamSmLocL[client], 0.05, dt, snap);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fCreamSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
    g_bCreamSmSnap[client] = false;
}

// FSM de 10 Hz: montaje / auto-reparación / muerte del avatar (patron
// T_RougeAvatarThink / T_ShadowAvatarThink)
public Action T_CreamAvatarThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Cream_KillAvatar(i); continue; }

        bool esCreamViva = (g_iPlayerCharIdx[i] == CREAM_INDEX
                         && IsPlayerAlive(i) && GetClientTeam(i) == 2);

        // incap = fuera (defensa anti terceros — la FSM re-monta sola
        // al levantarla: la misma regla de Rouge/Shadow)
        if (esCreamViva && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            esCreamViva = false;

        // ---- montaje ----
        if (g_iCreamAvatar[i] == 0)
        {
            if (esCreamViva && g_cvCreamAvatar != null && g_cvCreamAvatar.BoolValue
                && g_bCreamModelOK)
            {
                Cream_CreateAvatar(i);
            }
            continue;
        }

        // quitar avatar si dejó de ser una Cream survivor viva de pie
        if (!esCreamViva)
        {
            Cream_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iCreamAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iCreamAvatar[i] = 0;
            g_iCreamAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (el motor lo resetea al
        // cambiar de capítulo/rescue: fix Tails v5.4)
        if (g_iCreamBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparación de la copia L (montaje tardio: pulso también)
        if (g_iCreamAvatarL[i] == 0 && g_iCreamAvatar[i] != 0)
        {
            Cream_CreateAvatarL(i);
            if (g_iCreamAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // ---- FSM de animación ----
        av = EntRefToEntIndex(g_iCreamAvatar[i]);
        if (g_iCreamAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Cream_AvatarUpdate(i, av, now);
    }
    return Plugin_Continue;
}

// =====================================================================
// FSM DE ANIMACION — prioridades: incap (DownedIdle/DownedWalk) ->
// aire (FLY DE OREJAS con SPACE mantenido [su glide, la pasiva manda] /
// jump subiendo / fall cayendo) -> suelo (idle/walk/run con variantes
// lowhealth de HP<=30 — el umbral de "Cheese desmayado").
// =====================================================================
void Cream_AvatarUpdate(int client, int av, float now)
{
    // lock de one-shot en curso (Heal/Revive)
    if (now < g_fCreamAnimLock[client]) return;

    int state;
    float rate = 1.0;

    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
    {
        // DownedIdle/DownedWalk
        state = (Cream_Speed2D(client) > 40.0) ? CREAM_ST_DOWNED_WALK : CREAM_ST_DOWNED_IDLE;
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        int btn = GetClientButtons(client);
        if (btn & IN_JUMP)
        {
            // FLY DE OREJAS: SPACE mantenido en el aire = su glide (la
            // pasiva del v5; si el .mdl trae "fly"/"flap", esa es SU
            // pose; si no, "fall" por el fallback)
            state = CREAM_ST_FLY;
        }
        else
        {
            // AIRE: sube = jump; cae = fall — con la ventana del jump
            float vel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            if (vel[2] > 40.0)
            {
                state = CREAM_ST_JUMP;
            }
            else
            {
                bool jumpLive = false;
                if (g_iCreamAnimState[client] == CREAM_ST_JUMP)
                {
                    float jt = now - g_fCreamJumpStart[client];
                    if (jt < 0.5)      jumpLive = true;
                    else if (jt < 1.5 && !Cream_JumpAnimDone(av)) jumpLive = true;
                }
                state = jumpLive ? CREAM_ST_JUMP : CREAM_ST_FALL;
            }
        }
    }
    else if (g_iCreamAnimState[client] == CREAM_ST_JUMP && !Cream_JumpAnimDone(av)
             && now - g_fCreamJumpStart[client] < 0.5)
    {
        // FL_ONGROUND parpadea al saltar rozando escalones
        state = CREAM_ST_JUMP;
    }
    else
    {
        // SUELO: idle/walk/run (lowhealth <= 30, el umbral de Cheese)
        bool low = (GetClientHealth(client) <= CHEESE_DESPAWN_HP);
        float s = Cream_Speed2D(client);
        if (s < 40.0)
            state = low ? CREAM_ST_IDLE_LOW : CREAM_ST_IDLE;
        else if (s < 150.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = low ? CREAM_ST_WALK_LOW : CREAM_ST_WALK;
            rate = 1.0;   // rate 1 constante del framework GMod
        }
        else
        {
            state = low ? CREAM_ST_RUN_LOW : CREAM_ST_RUN;
            rate = 1.32 * (s / 450.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6)  rate = 3.6;
        }
    }

    if (state != g_iCreamAnimState[client])
    {
        // el t0 del jump para su ventana (receta Rouge/Sonic/Knuckles)
        if (state == CREAM_ST_JUMP) g_fCreamJumpStart[client] = now;

        char seqUse[24];
        Cream_SeqFor(state, seqUse);

        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iCreamAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iCreamAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                // el variant es de UN SOLO USO — re-armarlo
                SetVariantString(seqUse);
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iCreamAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iCreamAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iCreamAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

float Cream_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// el one-shot del jump termino? (m_flCycle del prop — la misma sonda
// del Rouge_JumpAnimDone / Knux_JumpAnimDone / Shadow_JumpAnimDone)
bool Cream_JumpAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return true;
}

// ONE-SHOT de habilidad sobre las DOS copias (la Cura y la
// Resurrección). Bloquea la FSM mientras corre.
void Cream_AvatarOneShot(int client, int stIdx, float lock)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iCreamAvatar[client] == 0) return;   // Sage (set prestado): sin avatar, no-op

    char seqUse[24];
    Cream_SeqFor(stIdx, seqUse);

    int av = EntRefToEntIndex(g_iCreamAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
    }
    if (g_iCreamAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iCreamAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetVariantString(seqUse);
            AcceptEntityInput(avL, "SetAnimation");
        }
    }
    g_iCreamAnimState[client] = stIdx;
    g_fCreamAnimLock[client] = GetEngineTime() + lock;
}

// =====================================================================
// TINTES DEL AVATAR — v7.0: la inmunidad post-resurrección enciende el
// DORADO de las DOS copias (antes el tinte del survivor era invisible:
// el cuerpo esta RENDER_NONE con el avatar montado).
// =====================================================================
void Cream_AvatarSetColor(int client, int r, int g, int b, int a)
{
    int av = EntRefToEntIndex(g_iCreamAvatar[client]);
    if (g_iCreamAvatar[client] != 0 && av > 0 && IsValidEntity(av))
        SetEntityRenderColor(av, r, g, b, a);
    int avL = EntRefToEntIndex(g_iCreamAvatarL[client]);
    if (g_iCreamAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
        SetEntityRenderColor(avL, r, g, b, a);
}

void Cream_AvatarTintReset(int client)
{
    Cream_AvatarSetColor(client, 255, 255, 255, 255);
}

// =====================================================================
// MUERTE DEL AVATAR — ragdoll cream.mdl + filtro anti-corpse
// (receta Rouge v10.2 / Knuckles v75 / Metal v5.0 / Shadow v6.0)
// =====================================================================
void Cream_SpawnDeathRagdoll(int client)
{
    if (!g_bCreamModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", CREAM_OM_MODEL);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    CreateTimer(15.0, T_CreamDeathRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_CreamDeathRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Filtro anti-ragdoll (patron Rouge/Sonic/Knuckles/Shadow — enrutado
// por el OnEntityCreated central de Rouge.inc, que despacha a este
// modulo)
public void Cream_CheckDeathRagdoll(any ref)
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
        if (g_fCreamDeathHideUntil[i] == 0.0 || now >= g_fCreamDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_vCreamDeathOrigin[i]) < 200.0)
        {
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}

// v3.77.68: dispatch del OnEntityCreated central de Rouge.inc — la
// ventana anti-corpse de las muertes de la Cream con avatar
public void Cream_OnEntityCreated(int entity, const char[] classname)
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
            if (g_fCreamDeathHideUntil[i] == 0.0 || nowOM >= g_fCreamDeathHideUntil[i])
                continue;
            RequestFrame(Cream_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }
}

// LA MUERTE DEL AVATAR (hook POST propio — la lección Rouge v3.77.49:
// ni el PRE ni el POST del manager tocan el avatar de Cream; TODO pasa
// aquí: ragdoll + ventana anti-corpse + KillAvatarOnly + reset. La
// lección Sonic v3.76.2: en PRE el restore dejaba ver el corpse del
// survivor.)
public void Cream_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0) return;

    if (g_iPlayerCharIdx[client] == CREAM_INDEX)
    {
        if (g_iCreamAvatar[client] != 0)
        {
            Cream_SpawnDeathRagdoll(client);
            g_fCreamDeathHideUntil[client] = GetEngineTime() + 2.0;
            GetClientAbsOrigin(client, g_vCreamDeathOrigin[client]);
            Cream_KillAvatarOnly(client);   // el cuerpo vuelve a verse para el spectate/revive
        }
        Cream_ResetState(client);
    }
}

// v7.0: refs a cero al cerrar el mapa (las entidades murieron con el;
// el timer de la FSM es NO_MAPCHANGE y muere solo)
public void Cream_OnMapEnd()
{
    delete g_hCreamAvatarThink;
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iCreamAvatar[i] = 0;
        g_iCreamAvatarL[i] = 0;
        g_iCreamAnimState[i] = -1;
        g_fCreamDeathHideUntil[i] = 0.0;
        // v7.1-OM: el dash también
        g_fCreamDashUntil[i] = 0.0;
        g_fCreamDashCdUntil[i] = 0.0;
        g_fCreamBoostUntil[i] = 0.0;
    }
}

// =====================================================================
// v7.1-OM: EL DASH DEL LUA GMOD (survivors2.lua L2252-2281 + think
// L1985-2096) — tecla C. El kit que faltaba de Cream: el Lua trae 3
// habilidades (E heal / T dash / SPACE glide) y el suite solo tenía 2.
//  - C: si estas en el suelo te levanta +5z; impulso fwd*500 + 145z;
//    ventana de golpeo 1s (esfera 90 a +50z): al DAR — knockback al
//    objetivo (dir*900 + 200z), rebote propio atras (-400 +100z),
//    DashHit.wav, +5s de speed boost (1.6x) y el COSTE del Lua:
//    20 de dano a una misma.
//  - Pared delante durante el dash: rebote -200+100z + Wallhit.wav.
// =====================================================================

void Cream_DashSnd(int idx, int ent)
{
    if (idx < 0 || idx > 2 || !g_bCreamDashSndOK[idx]) return;
    if (ent > 0 && IsValidEntity(ent)) EmitSoundToAll(g_sCreamDashSndUse[idx], ent, SNDCHAN_AUTO, 90);
}

// entry point (manager: tecla C de Cream)
void Cream_Ability3(int client)
{
    if (!Cream_IsValidClient(client)) return;
    int idx = g_iPlayerCharIdx[client];
    if (idx != CREAM_INDEX) return;
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    float now = GetEngineTime();
    if (now < g_fCreamDashCdUntil[client])
    {
        PrintCenterText(client, "[Cream] Dash en enfriamiento: %.1fs", g_fCreamDashCdUntil[client] - now);
        return;
    }
    if (now < g_fCreamDashUntil[client]) return;

    g_fCreamDashCdUntil[client] = now + ((g_cvCreamDashCd != null) ? g_cvCreamDashCd.FloatValue : 15.0);

    // si estas en el suelo: la levantada +5z del Lua
    float pos[3];
    GetClientAbsOrigin(client, pos);
    if (GetEntityFlags(client) & FL_ONGROUND)
    {
        pos[2] += 5.0;
        TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
    }

    // el impulso del Lua: fwd*500 + z 145
    float eye[3], fwd[3], v[3];
    GetClientEyeAngles(client, eye);
    GetAngleVectors(eye, fwd, NULL_VECTOR, NULL_VECTOR);
    float spd = (g_cvCreamDashSpeed != null) ? g_cvCreamDashSpeed.FloatValue : 500.0;
    float lift = (g_cvCreamDashLift  != null) ? g_cvCreamDashLift.FloatValue  : 145.0;
    CopyVector(fwd, v); ScaleVector(v, spd); v[2] = lift;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, v);

    g_fCreamDashUntil[client]    = now + 1.0;      // DashDuration 1s
    g_fCreamDashNextScan[client] = now + 0.1;
    Cream_DashSnd(CREAM_DASHSND_GO, client);

    // glow del arranque (gráfico nativo)
    if (g_iCreamGlowSprite > 0)
    {
        float p2[3];
        GetClientAbsOrigin(client, p2); p2[2] += 40.0;
        TE_SetupGlowSprite(p2, g_iCreamGlowSprite, 0.35, 1.3, 180);
        TE_SendToAll();
    }
}

// el tick del dash (desde Cream_PreThink — cada frame; el scan de
// golpeo cada 0.1s)
void Cream_DashTick(int client, float now)
{
    if (g_iPlayerCharIdx[client] != CREAM_INDEX) return;

    // aturdido: cortar el boost y la ventana (no pelear con el stun)
    if (OM_IsStunned(client))
    {
        if (g_bCreamBoostOn[client])
        {
            g_bCreamBoostOn[client] = false;
            g_fCreamBoostUntil[client] = 0.0;
            if (HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
                SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        }
        g_fCreamDashUntil[client] = 0.0;
        return;
    }

    // ---- speed boost activo (5s a 1.6x — el +800 del Lua) ----
    if (now < g_fCreamBoostUntil[client])
    {
        if (!g_bCreamBoostOn[client])
        {
            g_bCreamBoostOn[client] = true;
        }
        if (HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue",
                (g_cvCreamDashBoost != null) ? g_cvCreamDashBoost.FloatValue : 1.6);
    }
    else if (g_bCreamBoostOn[client])
    {
        g_bCreamBoostOn[client] = false;
        if (IsClientInGame(client) && HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }

    if (now >= g_fCreamDashUntil[client]) return;

    // ---- ventana de golpeo (el think del Lua) ----
    if (now >= g_fCreamDashNextScan[client])
    {
        g_fCreamDashNextScan[client] = now + 0.1;

        // pared delante? (el latching() del Lua — trace 30 al frente)
        float pos[3], eye[3], fwd[3], endp[3];
        GetClientAbsOrigin(client, pos);
        GetClientEyeAngles(client, eye); eye[0] = 0.0;
        GetAngleVectors(eye, fwd, NULL_VECTOR, NULL_VECTOR);
        endp[0] = pos[0] + fwd[0] * 30.0;
        endp[1] = pos[1] + fwd[1] * 30.0;
        endp[2] = pos[2] + 40.0;
        Handle tr = TR_TraceRayFilterEx(pos, endp, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Cream_DashTraceFilter, client);
        bool wall = TR_DidHit(tr);
        delete tr;
        if (wall)
        {
            // rebote de pared: -fwd*200 +100z (vel2 del Lua) + Wallhit.wav
            float rv[3];
            CopyVector(fwd, rv); ScaleVector(rv, -200.0); rv[2] = 100.0;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, rv);
            Cream_DashSnd(CREAM_DASHSND_WALL, client);
            g_fCreamDashUntil[client] = 0.0;
            return;
        }

        // objetivo: esfera 90 a +50z
        float c[3];
        GetClientAbsOrigin(client, c); c[2] += 50.0;
        float range = (g_cvCreamDashRange != null) ? g_cvCreamDashRange.FloatValue : 90.0;

        int victim = 0;
        float vdir[3];
        for (int t = 1; t <= MaxClients && victim == 0; t++)
        {
            if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
            if (GetClientTeam(t) != TEAM_INFECTED) continue;
            float p[3]; GetClientAbsOrigin(t, p);
            if (GetVectorDistance(c, p) <= range) { victim = t; SubtractVectors(p, c, vdir); NormalizeVector(vdir, vdir); }
        }
        static const char sNpc[][] = { "infected", "witch", "tank" };
        for (int n = 0; n < sizeof(sNpc) && victim == 0; n++)
        {
            int ent = -1;
            while ((ent = FindEntityByClassname(ent, sNpc[n])) != -1)
            {
                if (!IsValidEntity(ent)) continue;
                if (!HasEntProp(ent, Prop_Data, "m_iHealth")) continue;
                if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
                float p[3]; GetEntPropVector(ent, Prop_Data, "m_vecOrigin", p);
                if (GetVectorDistance(c, p) <= range) { victim = ent; SubtractVectors(p, c, vdir); NormalizeVector(vdir, vdir); break; }
            }
        }

        if (victim > 0)
        {
            // el ACIERTO del Lua: knockback dir*900 +200z (la victima sube
            // +15z como el up*5/+40 del Lua), rebote propio -400+100z
            float tp[3];
            if (victim <= MaxClients) GetClientAbsOrigin(victim, tp);
            else GetEntPropVector(victim, Prop_Data, "m_vecOrigin", tp);
            tp[2] += 15.0;
            TeleportEntity(victim, tp, NULL_VECTOR, NULL_VECTOR);
            float kv[3];
            CopyVector(vdir, kv); kv[2] += 0.22;
            ScaleVector(kv, 900.0);
            TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, kv);

            // v7.3-OM: EL DASH QUE PEGA — "causará entre 120 a 180 de daño
            // a los infectados SI (los comunes son dañados moderadamente
            // más que los SI)": SI -> aleatorio del rango; NPC (común/
            // witch/tank) -> el rango x cream_dash_dmg_commonmult (1.5)
            float dSiMin = (g_cvCreamDashDmgSiMin != null) ? g_cvCreamDashDmgSiMin.FloatValue : 120.0;
            float dSiMax = (g_cvCreamDashDmgSiMax != null) ? g_cvCreamDashDmgSiMax.FloatValue : 180.0;
            if (dSiMax < dSiMin) dSiMax = dSiMin;
            float ddash = GetRandomFloat(dSiMin, dSiMax);
            if (victim > MaxClients)
            {
                float cMult = (g_cvCreamDashDmgCommonMult != null) ? g_cvCreamDashDmgCommonMult.FloatValue : 1.5;
                if (cMult < 0.1) cMult = 0.1;
                ddash *= cMult;
            }
            OM_AbilityDamage(victim, client, ddash, DMG_CLUB);

            float rv[3];
            CopyVector(fwd, rv); ScaleVector(rv, -400.0); rv[2] = 100.0;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, rv);

            Cream_DashSnd(CREAM_DASHSND_HIT, client);

            // +5s de speed boost
            g_fCreamBoostUntil[client] = now + ((g_cvCreamDashBoostT != null) ? g_cvCreamDashBoostT.FloatValue : 5.0);

            // EL COSTE del Lua: 5 de daño a una misma [v7.3: 20 -> 5]
            float cost = (g_cvCreamDashDmg != null) ? g_cvCreamDashDmg.FloatValue : 5.0;
            SDKHooks_TakeDamage(client, client, client, cost, DMG_GENERIC, -1);

            g_fCreamDashUntil[client] = 0.0;   // cierra la ventana
        }
    }
}

public bool Cream_DashTraceFilter(int entity, int contentsMask, any data)
{
    if (entity > 0 && entity <= MaxClients) return false;   // los specials no son "pared"
    return entity != view_as<int>(data);
}

// =====================================================================
// v7.2-OM: LÍNEA DEL PANEL DE ESTADOS — el manager 3.77.72 la pinta en
// el KeyHintText SIEMPRE VISIBLE (pedido del owner: "los enfriamientos
// de cream... deben verse"). Cooldowns de cura / resurrección / dash
// + el estado del boost post-dash.
// =====================================================================
void Cream_HUDLine(int client, char[] out, int maxlen, float now)
{
    int n = 0;
    n += Format(out[n], maxlen - n, "CREAM");

    if (g_bCreamBoostOn[client] && n < maxlen - 32)
        n += Format(out[n], maxlen - n, "  [BOOST %.1fs]", g_fCreamBoostUntil[client] - now);

    if (n < maxlen - 44)
    {
        n += Format(out[n], maxlen - n, "\nZ Cura de área: ");
        if (now < g_fCreamHealCooldown[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fCreamHealCooldown[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTA");
    }
    if (n < maxlen - 44)
    {
        n += Format(out[n], maxlen - n, "\nX Resurrección: ");
        if (now < g_fCreamReviveNextUse[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fCreamReviveNextUse[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTA");
    }
    if (n < maxlen - 40)
    {
        n += Format(out[n], maxlen - n, "\nC Dash: ");
        if (now < g_fCreamDashCdUntil[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fCreamDashCdUntil[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTA");
    }
    if (n < maxlen - 56)
        n += Format(out[n], maxlen - n, "\nPasivas: regen +1HP/2s · glide con SPACE");
}
