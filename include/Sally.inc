/*
 * ======================================================
 *  [MODULO] Sally Acorn Abilities - Super Rework v6.2
 *
 *  v6.2 (con manager 3.77.8) - FIN DE LA AUTO-GENERACION INDIVIDUAL:
 *   - Eliminado el AutoExecConfig("Sally_Abilities") — el cfg
 *     individual se generaba con TODOS los cvars del plugin entero
 *     ("ConVars for plugin Sonic_ability_manager.smx"), o sea la
 *     MISMA lista que Sonic_Suite.cfg: duplicado puro que además
 *     pisaba valores al ejecutarse. Los cvars de Sally ya viven en
 *     la config única Sonic_Suite.cfg (v3.75, auto-guardada).
 *   - El manager 3.77.8 además BORRA los cfg residuales del server
 *     (SuiteCfg_DeleteLegacyFiles).
 *
 *  v6.1 CHANGES (ronda 28.1) - FIXES PEDIDOS POR EL OWNER:
 *   - "el rebote del escudo de agua no debería destruirse
 *     apenas se use": CAUSA RAÍZ — la caida rebotona frena a
 *     -900 y al aterrizar el motor aplicaba DAno DE CAIDA que
 *     el propio escudo absorbia: el slam se auto-comia el HP de
 *     la burbuja y la rompia en 1-2 rebotes. FIX: mientras la
 *     burbuja está activa TODO dano de caida (DMG_FALL) se niega
 *     completo SIN tocar el HP del escudo (la burbuja acolcha
 *     caidas, como el escudo de agua del Sonic clasico).
 *   - "aun cuando se destruye el escudo el sonido de el escudo
 *     de fuego sigue sonando": los sonidos de escudo pasan a un
 *     canal propio (SALLY_SHIELD_SNDCHAN = SNDCHAN_STATIC) en
 *     vez de SNDCHAN_AUTO (donde convive con voces/dano del
 *     juego y con el jingle de la 2a emisión apilada); corte
 *     reforzado en Sally_StopAllSounds (canal propio + AUTO por
 *     compatibilidad y 2 pasadas anti-apilado). El jingle de
 *     STOP/BREAK se emite en el MISMO canal del loop (además
 *     del StopSound, la emisión misma desaloja el slot).
 *   - Los inicios/expiraciones de regalo de Sage ya no duplican
 *     la emisión (el doble-emit de Sage_CastTeamShield se retira
 *     en Sage.inc v2.1: cada receptor ya emite el suyo).
 *
 *  v6.0 CHANGES (ronda 28) - ESCUDOS REGALABLES (set SALLY de Sage):
 *   - Pedido del owner: "sage si usa a sally ella puede darle escudos
 *     de agua o escudos fuegos a todo el equipo (obiamente duraran un
 *     tiempo como siempre ha durado) la de ella durara 5 seg más antes
 *     de desaparecer".
 *   - El sistema de escudos ya era PER-CLIENTE (flags + pools de HP +
 *     T_SallyThink + hooks): lo único que bloqueaba al resto era el
 *     gate Sally_IsSally. NUEVO helper Sally_ShieldSubject = la Sally
 *     real O cualquier receptor de escudo regalado por Sage (flags
 *     g_bSageGiftWater / g_bSageGiftFire, declarados en el manager
 *     ANTES de los includes).
 *   - Gates relajados (6): RunCmd (dash/bounce), PerformFireBoost,
 *     PerformBounce, WaterRegenTick, FireShieldExplosion,
 *     ApplyShieldPulse (el aura que empuja/quema). El ABSORB de
 *     Sally_OnTakeDamage cubre a los receptores de regalo.
 *   - Los COMANDOS (Cmd_ToggleShield / Cmd_ToggleBubble, sm_ de
 *     Sally) siguen EXCLUSIVOS de Sally: nadie más los enciende solo.
 *   - La inmunidad a acido/veneno/radiación es pasiva PERSONAL de la
 *     Sally real (no viaja con el regalo). El estado lo activa/apaga
 *     Sage.inc con los mismos flags; la expiración la lleva el timer
 *     de Sage.inc (duración estándar + bonus para la propia Sage).
 *
 *  v5.0 CHANGES - SUPER REWORK DE ESCUDOS:
 *
 *  ESCUDO DE FUEGO (rework completo tipo Sonic clasico):
 *   - Sin limite de tiempo: permanente hasta que se destruya
 *   - HP del escudo: 300 (absorbe dano en vez de Sally)
 *   - Impulso aéreo (dash): CD de 4 segundos, ejecuta dash frontal en el aire
 *   - Solo 1 escudo a la vez: no puede tener fire + water simultaneos
 *   - Muestra HP restante en pantalla vía PrintHintText
 *   - Al destruirse: explosión que quema + retrocede infectados + dano
 *   - Ya no lanza aura de fuego alrededor (eliminado por bug visual)
 *   - Sally ya no cambia de color (más sutil)
 *
 *  ESCUDO DE AGUA (rework):
 *   - Duración permanente (sin timer de fin)
 *   - Ya no absorbe dano para curar (era OP)
 *   - Regenera 1 HP cada 1.5s (pasiva, hasta max health)
 *   - Resistencia: 250 HP (absorbe dano en vez de Sally)
 *   - Bounce FIX: ya no se puede spamear presionando CTRL (cooldown de 1s)
 *   - Al rebotar: el oponente (infectado) rebota como siempre
 *   - Al destruirse: cae normalmente sin explosión
 *
 *  FIX: Otros jugadores no pueden usar habilidades de Sally
 *       (check estricto de SALLY_INDEX en todos los comandos)
 *
 *  ROBUSTEZ DE CÓDIGO:
 *   - Validaciones estrictas en cada función
 *   - SDKUnhook antes de SDKHook (anti double-hook)
 *   - Limpieza segura de handles con null checks
 *   - Clamp de HP y dano absorbido
 *   - ConVars con validación null
 *   - Banderas explícitas de estado
 *   - Sistema de HP de escudos separado de HP de Sally
 * ======================================================
 */

#if defined _Sally_included
    #endinput
#endif
#define _Sally_included

// v6.1 (R28.1): versión que reporta el sm_sjsver del manager
#define SALLY_INC_VERSION "v6.1"

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
#if !defined SALLY_INDEX
    #define SALLY_INDEX 4
#endif

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// v5: Defines de red protegidos (evitan warnings de redefinición)
#if !defined FL_EDICT_ALWAYS
    #define FL_EDICT_ALWAYS 2
#endif
#if !defined EF_BONEMERGE
    #define EF_BONEMERGE 1
#endif
#if !defined EF_BONEMERGE_FASTCULL
    #define EF_BONEMERGE_FASTCULL 8
#endif

// =======================
// Constantes
// =======================
#define SALLY_SND_FIRE_START    "mobius/sfx/shield_element/Sally_Acorn_fire_shield.mp3"
#define SALLY_SND_FIRE_STOP     "mobius/sfx/shield_element/Fire_shield_stop.mp3"
#define SALLY_SND_FIRE_BOOST    "mobius/sfx/shield_element/fire_boost.mp3"
#define SALLY_SND_FIRE_BREAK    "mobius/sfx/shield_element/fire_break.mp3"
#define SALLY_SND_WATER_START   "mobius/sfx/shield_element/Sally_Acorn_water_shield.mp3"
#define SALLY_SND_WATER_STOP    "mobius/sfx/shield_element/Sally_Acorn_water_shield_over.mp3"
#define SALLY_SND_WATER_REFLECT "mobius/sfx/shield_element/Sally_Acorn_water_shield_rebote.mp3"
#define SALLY_SND_BOUNCE        "mobius/sfx/shield_element/Sally_Acorn_water_shield_rebote.mp3"
#define SALLY_SND_FALLBACK      "ambient/energy/zap1.wav"  // fallback

// v6.1 (R28.1) FIX 2: canal dedicado de los sonidos de escudo. Antes
// el loop/jingle de escudo se emita en SNDCHAN_AUTO (0) junto a las
// voces de dolor, pasos y disparos del juego. Ahora el sonido "vivo"
// del escudo (START/STOP/BREAK de agua y fuego) vive SOLO aquí y el
// corte de Sally_StopAllSounds es exacto. SNDCHAN_STATIC es el canal
// del motor para ambientes/loops.
#define SALLY_SHIELD_SNDCHAN    SNDCHAN_STATIC

#define SALLY_PARTICLE_RING     "materials/sprites/laserbeam.vmt"

// v5: Configuración del Fire Shield (rework)
#define SALLY_FIRE_MAX_HP           300.0   // HP máximo del escudo de fuego
#define SALLY_FIRE_BOOST_CD         4.0     // CD del dash aéreo
#define SALLY_FIRE_BOOST_FORCE      800.0   // Fuerza del dash aéreo
#define SALLY_FIRE_EXPLOSION_RADIUS 400.0   // Radio de la explosión al romperse
#define SALLY_FIRE_EXPLOSION_DMG    150.0   // Dano de la explosión al romperse
#define SALLY_FIRE_EXPLOSION_IGNITE 5.0     // Tiempo de quemado de la explosión

// v5: Configuración del Water Shield (rework)
#define SALLY_WATER_MAX_HP          250.0   // HP máximo del escudo de agua
#define SALLY_WATER_REGEN_AMOUNT    1       // HP regenerado por tick
#define SALLY_WATER_REGEN_INTERVAL  1.5     // Intervalo de regeneración (segundos)
#define SALLY_WATER_BOUNCE_CD       1.0     // CD entre bounces (anti spam)
#define SALLY_WATER_BOUNCE_RADIUS   300.0   // Radio de la onda expansiva del bounce

// Limites de seguridad
#define HP_MIN 1
#define HP_MAX 500

// =======================
// Variables Globales
// =======================
Handle g_hSallyThinkTimer = INVALID_HANDLE;
bool g_bSallyMapActive = false;

// Estados de escudos
public bool g_bShieldActive[MAXPLAYERS + 1];   // Fire shield
public bool g_bBubbleActive[MAXPLAYERS + 1];   // Water shield

// v5: HP de los escudos (separado de HP de Sally)
float g_fFireShieldHP[MAXPLAYERS + 1];
float g_fWaterShieldHP[MAXPLAYERS + 1];

// v5: Sistema de dash aéreo del Fire Shield
float g_fFireBoostNextUse[MAXPLAYERS + 1];
bool  g_bFireBoostActive[MAXPLAYERS + 1];
float g_fFireBoostEndTime[MAXPLAYERS + 1];

// v5: Sistema de regeneración del Water Shield
float g_fWaterNextRegenTick[MAXPLAYERS + 1];

// Cooldowns
float g_fShieldNextUse[MAXPLAYERS + 1];
float g_fShieldNextTick[MAXPLAYERS + 1];
float g_fBubbleNextUse[MAXPLAYERS + 1];

// Mecanica de Rebote (Bubble)
bool  g_bBubbleDrop[MAXPLAYERS + 1];
int   g_iBubbleCombo[MAXPLAYERS + 1];
bool  g_bWasInAir[MAXPLAYERS + 1];
float g_fBubbleLastBounceTime[MAXPLAYERS + 1];  // v5: anti spam de bounces

// Visuales
int g_iSallyBubbleProp[MAXPLAYERS + 1] = { -1, ... };
int g_iSallyFireBarrierProp[MAXPLAYERS + 1] = { -1, ... };
int g_iSallyFireParticle[MAXPLAYERS + 1] = { -1, ... };

// ConVars
ConVar g_cvSallyEnable, g_cvSallyRadius, g_cvSallyDPS, g_cvSallyTick, g_cvSallyPushForce, g_cvSallyIgniteTime, g_cvSallyCooldown, g_cvSallyOnlyHuman;
stock ConVar g_cvSallyDuration;               // legacy v5: se crea (cfg) pero nunca se lee
ConVar g_cvSallyBubbleEnable, g_cvSallyBubbleCooldown, g_cvSallyBubbleReflect;
stock ConVar g_cvSallyBubbleDuration, g_cvSallyBubbleHeal, g_cvSallyBubbleAbsorb;   // legacy v5: creadas (cfg) pero nunca leidas
ConVar g_cvSallyBounceBase, g_cvSallyBounceDamage;

// v5: Nuevas ConVars para rework
ConVar g_cvSallyFireMaxHP, g_cvSallyFireBoostCD, g_cvSallyFireBoostForce;
ConVar g_cvSallyFireExplosionRadius, g_cvSallyFireExplosionDmg, g_cvSallyFireExplosionIgnite;
ConVar g_cvSallyWaterMaxHP, g_cvSallyWaterRegenAmount, g_cvSallyWaterRegenInterval;
ConVar g_cvSallyWaterBounceCD;

// Macros
#define IsValidSurvivor(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1) && GetClientTeam(%1) == 2)
#define IsValidInfected(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1) && GetClientTeam(%1) == 3)

// =======================
// Utilidades de Particulas
// =======================
void Sally_PrecacheParticle(const char[] sEffectName)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE) table = FindStringTable("ParticleEffectNames");
    if (table == INVALID_STRING_TABLE) return;
    int index = FindStringIndex(table, sEffectName);
    if (index == INVALID_STRING_INDEX) {
        bool save = LockStringTables(false); AddToStringTable(table, sEffectName); LockStringTables(save);
    }
}

// v5: Helper para validar que el cliente es Sally
bool Sally_IsSally(int client)
{
    if (!IsValidSurvivor(client)) return false;
    if (g_iPlayerCharIdx[client] != SALLY_INDEX) return false;
    return true;
}

// v6 (R28): Helper de ESCUDO REGALABLE — la Sally real O cualquier
// receptor de escudo de Sage (set SALLY). Las LÓGICAS de escudo
// (dash/bounce del RunCmd, regen, pulso de aura, explosión, absorb)
// usan este gate. Los COMANDOS de Sally siguen usando Sally_IsSally.
bool Sally_ShieldSubject(int client)
{
    if (!IsValidSurvivor(client)) return false;
    if (g_iPlayerCharIdx[client] == SALLY_INDEX) return true;
    return (g_bSageGiftWater[client] || g_bSageGiftFire[client]);
}

// v5: Helper para clamp de HP
int Sally_ClampHP(int hp)
{
    if (hp < HP_MIN) return HP_MIN;
    if (hp > HP_MAX) return HP_MAX;
    return hp;
}

// =======================
// Inicialización
// =======================

public void Sally_OnPluginStart()
{
    // Fire Shield
    g_cvSallyEnable     = CreateConVar("sally_fire_enable", "1", "Habilita el escudo de fuego.");
    g_cvSallyRadius     = CreateConVar("sally_fire_radius", "400.0", "Radio del escudo.");
    g_cvSallyDPS        = CreateConVar("sally_fire_dps", "55.0", "Dano por pulso.");
    g_cvSallyTick       = CreateConVar("sally_fire_tick", "0.5", "Intervalo de pulsos.");
    g_cvSallyPushForce  = CreateConVar("sally_fire_push", "500.0", "Fuerza de empuje del pulso.");
    g_cvSallyIgniteTime = CreateConVar("sally_fire_ignite", "2.0", "Tiempo de quemado.");
    g_cvSallyDuration   = CreateConVar("sally_fire_duration", "20.0", "Duración del escudo (legacy, no usado en v5).");
    g_cvSallyCooldown   = CreateConVar("sally_fire_cooldown", "35.0", "Enfriamiento.");
    g_cvSallyOnlyHuman  = CreateConVar("sally_only_human", "1", "Solo humanos.");

    // v5: Fire Shield rework
    g_cvSallyFireMaxHP          = CreateConVar("sally_fire_max_hp", "300.0", "HP máximo del escudo de fuego.", _, true, 50.0, true, 1000.0);
    g_cvSallyFireBoostCD        = CreateConVar("sally_fire_boost_cd", "4.0", "CD del dash aéreo del Fire Shield.", _, true, 0.5, true, 30.0);
    g_cvSallyFireBoostForce     = CreateConVar("sally_fire_boost_force", "800.0", "Fuerza del dash aéreo.", _, true, 100.0, true, 5000.0);
    g_cvSallyFireExplosionRadius= CreateConVar("sally_fire_explosion_radius", "400.0", "Radio de la explosión al romperse.", _, true, 50.0, true, 2000.0);
    g_cvSallyFireExplosionDmg   = CreateConVar("sally_fire_explosion_dmg", "150.0", "Dano de la explosión al romperse.", _, true, 0.0, true, 2000.0);
    g_cvSallyFireExplosionIgnite= CreateConVar("sally_fire_explosion_ignite", "5.0", "Tiempo de quemado de la explosión.", _, true, 0.0, true, 30.0);

    // Bubble Shield
    g_cvSallyBubbleEnable   = CreateConVar("sally_bubble_enable", "1", "Habilita el escudo burbuja.");
    g_cvSallyBubbleDuration = CreateConVar("sally_bubble_duration", "15.0", "Duración del escudo burbuja (legacy, no usado en v5).");
    g_cvSallyBubbleCooldown = CreateConVar("sally_bubble_cooldown", "20.0", "Enfriamiento.");
    g_cvSallyBubbleReflect  = CreateConVar("sally_bubble_reflect", "400.0", "Fuerza del rebote al atacante.");
    g_cvSallyBubbleHeal     = CreateConVar("sally_bubble_healfactor", "1.0", "Factor de curación (legacy, no usado en v5).");
    g_cvSallyBubbleAbsorb   = CreateConVar("sally_bubble_absorb", "1", "Absorber dano (legacy, no usado en v5).");

    // v5: Water Shield rework
    g_cvSallyWaterMaxHP         = CreateConVar("sally_water_max_hp", "250.0", "HP máximo del escudo de agua.", _, true, 50.0, true, 1000.0);
    g_cvSallyWaterRegenAmount   = CreateConVar("sally_water_regen_amount", "1", "HP regenerado por tick.", _, true, 1.0, true, 50.0);
    g_cvSallyWaterRegenInterval = CreateConVar("sally_water_regen_interval", "1.5", "Intervalo de regeneración (segundos).", _, true, 0.5, true, 30.0);
    g_cvSallyWaterBounceCD      = CreateConVar("sally_water_bounce_cd", "1.0", "CD entre bounces (anti spam).", _, true, 0.5, true, 10.0);

    // Bubble Bounce Mechanic
    g_cvSallyBounceBase     = CreateConVar("sally_bounce_force", "600.0", "Fuerza base del salto al rebotar.");
    g_cvSallyBounceDamage   = CreateConVar("sally_bounce_damage", "100.0", "Dano de la onda expansiva al rebotar.");

    // Hooks
    HookEvent("player_death", E_SallyPlayerReset);
    HookEvent("player_disconnect", E_SallyPlayerReset);

    // v3.77.8 (Sally v6.2): AutoExecConfig eliminado - config ÚNICA
    // del suite (Sonic_Suite.cfg, auto-guardada; ver manager). El
    // archivo viejo queda muerto y el manager lo borra del server.
    Sally_ResetAll(true);
}

public void Sally_OnMapStart()
{
    g_bSallyMapActive = false;

    PrecacheModel(SALLY_PARTICLE_RING, true);
    PrecacheModel("materials/sprites/glow01.vmt", true);
    PrecacheModel("models/props_unique/airport/atlas_break_ball.mdl", true);

    PrecacheSound(SALLY_SND_FIRE_START, true);
    PrecacheSound(SALLY_SND_FIRE_STOP, true);
    PrecacheSound(SALLY_SND_FIRE_BOOST, true);
    PrecacheSound(SALLY_SND_FIRE_BREAK, true);
    PrecacheSound(SALLY_SND_WATER_START, true);
    PrecacheSound(SALLY_SND_WATER_STOP, true);
    PrecacheSound(SALLY_SND_WATER_REFLECT, true);
    PrecacheSound(SALLY_SND_FALLBACK, true);

    Sally_PrecacheParticle("fire_medium_01");

    Sally_ResetAll(true);
    g_bSallyMapActive = true;

    // FIX CRASH CAPÍTULO 2 (mismo vector que Speed v2.4): KillTimer sobre
    // un handle NO_MAPCHANGE muerto lanzaba "Invalid timer handle" y
    // abortaba el OnMapStart del manager (los personajes posteriores se
    // quedaban sin precache). El handle se olvida en Sally_OnMapEnd; aquí
    // guarda anti-dueto (nunca dos thinks) y CERO KillTimer.
    if (g_hSallyThinkTimer == INVALID_HANDLE)
        g_hSallyThinkTimer = CreateTimer(0.1, T_SallyThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void Sally_OnMapEnd()
{
    g_bSallyMapActive = false;
    Sally_ResetAll(true);
    // FIX CRASH CAPÍTULO 2: sin KillTimer. El timer lleva NO_MAPCHANGE
    // (SM lo mata solo al cerrar el nivel): aquí solo se OLVIDA el handle
    // para que el próximo Sally_OnMapStart cree una instancia fresca.
    g_hSallyThinkTimer = INVALID_HANDLE;
}

// =======================
// Gestion de Estado y Audio
// =======================

void Sally_StopAllSounds(int client)
{
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        // v6.1 (R28.1) FIX 2: corte por partida doble — el canal propio
        // del escudo (STATIC) y SNDCHAN_AUTO por compatibilidad. 2
        // pasadas ANTI-APILADO: si el motor apilo 2 emisiones del mismo
        // sample (p.ej. cast de Sage + regalo), una sola pasada podía
        // dejar una viva = "el sonido sigue sonando".
        for (int pass = 0; pass < 2; pass++)
        {
            StopSound(client, SALLY_SHIELD_SNDCHAN, SALLY_SND_FIRE_START);
            StopSound(client, SALLY_SHIELD_SNDCHAN, SALLY_SND_WATER_START);
            StopSound(client, SALLY_SHIELD_SNDCHAN, SALLY_SND_FIRE_BOOST);
            StopSound(client, SNDCHAN_AUTO, SALLY_SND_FIRE_START);
            StopSound(client, SNDCHAN_AUTO, SALLY_SND_WATER_START);
            StopSound(client, SNDCHAN_AUTO, SALLY_SND_FIRE_BOOST);
        }
    }
}

void Sally_ResetState(int client, bool fullCooldown = false)
{
    if (client < 1 || client > MaxClients) return;

    if (g_bShieldActive[client]) Sally_EffectStop(client);
    if (g_bBubbleActive[client]) Sally_EffectBubbleStop(client);

    Sally_StopAllSounds(client);

    g_bShieldActive[client]   = false;
    g_bBubbleActive[client]   = false;

    g_bBubbleDrop[client]     = false;
    g_iBubbleCombo[client]    = 0;
    g_bWasInAir[client]       = false;

    // v5: Reset HP de escudos
    g_fFireShieldHP[client]   = 0.0;
    g_fWaterShieldHP[client]  = 0.0;
    g_fFireBoostNextUse[client] = 0.0;
    g_bFireBoostActive[client]  = false;
    g_fFireBoostEndTime[client] = 0.0;
    g_fWaterNextRegenTick[client] = 0.0;
    g_fBubbleLastBounceTime[client] = 0.0;

    float now = GetEngineTime();
    g_fShieldNextUse[client]  = fullCooldown ? (now + g_cvSallyCooldown.FloatValue) : 0.0;
    g_fBubbleNextUse[client]  = fullCooldown ? (now + g_cvSallyBubbleCooldown.FloatValue) : 0.0;

    DestroySallyBubbleBarrier(client);
    DestroySallyFireBarrier(client);
    DestroySallyFireAura(client);

    if (IsClientInGame(client))
    {
        SetEntityRenderMode(client, RENDER_NORMAL);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Sally_ResetAll(bool fullCooldown = false)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            Sally_ResetState(i, fullCooldown);
            SDKUnhook(i, SDKHook_OnTakeDamage, Sally_OnTakeDamage);
            SDKHook(i, SDKHook_OnTakeDamage, Sally_OnTakeDamage);
        }
    }
}

public void Sally_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;
    // Anti double-hook
    SDKUnhook(client, SDKHook_OnTakeDamage, Sally_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Sally_OnTakeDamage);
    Sally_ResetState(client, false);
}

public void E_SallyPlayerReset(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
        Sally_ResetState(client, true);
}

// =======================
// SISTEMA VISUAL BARRERAS
// =======================

void CreateSallyBubbleBarrier(int client)
{
    DestroySallyBubbleBarrier(client);
    int shield = CreateEntityByName("prop_dynamic_override");
    if (shield == -1) return;

    DispatchKeyValue(shield, "model", "models/props_unique/airport/atlas_break_ball.mdl");
    DispatchKeyValue(shield, "solid", "0");

    DispatchSpawn(shield);

    SetEntityRenderMode(shield, RENDER_TRANSCOLOR);
    SetEntityRenderColor(shield, 0, 255, 255, 120);

    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] -= 120.0;
    TeleportEntity(shield, pos, NULL_VECTOR, NULL_VECTOR);

    SetVariantString("!activator");
    AcceptEntityInput(shield, "SetParent", client, shield);

    SetEntProp(shield, Prop_Send, "m_fEffects", GetEntProp(shield, Prop_Send, "m_fEffects") | EF_BONEMERGE | EF_BONEMERGE_FASTCULL);
    SetEdictFlags(shield, FL_EDICT_ALWAYS);

    g_iSallyBubbleProp[client] = EntIndexToEntRef(shield);
}

void DestroySallyBubbleBarrier(int client)
{
    if (client < 1 || client > MaxClients) return;
    int ent = EntRefToEntIndex(g_iSallyBubbleProp[client]);
    if (ent > 0 && IsValidEntity(ent)) AcceptEntityInput(ent, "Kill");
    g_iSallyBubbleProp[client] = -1;
}

void CreateSallyFireBarrier(int client)
{
    DestroySallyFireBarrier(client);
    int shield = CreateEntityByName("prop_dynamic_override");
    if (shield == -1) return;

    DispatchKeyValue(shield, "model", "models/props_unique/airport/atlas_break_ball.mdl");
    DispatchKeyValue(shield, "solid", "0");

    DispatchSpawn(shield);

    SetEntityRenderMode(shield, RENDER_TRANSCOLOR);
    SetEntityRenderColor(shield, 255, 100, 30, 120);

    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] -= 120.0;
    TeleportEntity(shield, pos, NULL_VECTOR, NULL_VECTOR);

    SetVariantString("!activator");
    AcceptEntityInput(shield, "SetParent", client, shield);

    SetEntProp(shield, Prop_Send, "m_fEffects", GetEntProp(shield, Prop_Send, "m_fEffects") | EF_BONEMERGE | EF_BONEMERGE_FASTCULL);
    SetEdictFlags(shield, FL_EDICT_ALWAYS);

    g_iSallyFireBarrierProp[client] = EntIndexToEntRef(shield);
}

void DestroySallyFireBarrier(int client)
{
    if (client < 1 || client > MaxClients) return;
    int ent = EntRefToEntIndex(g_iSallyFireBarrierProp[client]);
    if (ent > 0 && IsValidEntity(ent)) AcceptEntityInput(ent, "Kill");
    g_iSallyFireBarrierProp[client] = -1;
}

void DestroySallyFireAura(int client)
{
    if (client < 1 || client > MaxClients) return;
    int ent = EntRefToEntIndex(g_iSallyFireParticle[client]);
    if (ent > 0 && IsValidEntity(ent)) AcceptEntityInput(ent, "Kill");
    g_iSallyFireParticle[client] = -1;
}

void Sally_BubblePlop(float pos[3])
{
    TE_SetupEnergySplash(pos, NULL_VECTOR, true);
    TE_SendToAll();

    int sprite = PrecacheModel(SALLY_PARTICLE_RING);
    TE_SetupBeamRingPoint(pos, 10.0, 250.0, sprite, 0, 0, 0, 0.5, 10.0, 0.0, {0, 255, 255, 200}, 0, 0);
    TE_SendToAll();
}

// =======================
// Lógica de Input (OnPlayerRunCmd)
// ======================================================================

public void Sally_OnPlayerRunCmd(int client, int &buttons)
{
    // v6 (R28): dash (fuego) y caida rebotona (agua) también para los
    // receptores de escudo regalado de Sage. La Sally real entra igual.
    if (!Sally_ShieldSubject(client)) return;

    // v5: Fire Shield - Dash aéreo (presionar DUCK/CTRL en el aire)
    if (g_bShieldActive[client])
    {
        int flags = GetEntityFlags(client);
        bool onGround = (flags & FL_ONGROUND) != 0;

        // Dash aéreo solo si está en el aire y presiona DUCK
        if (!onGround && (buttons & IN_DUCK) && !g_bFireBoostActive[client])
        {
            float now = GetEngineTime();
            if (now >= g_fFireBoostNextUse[client])
            {
                Sally_PerformFireBoost(client);
            }
        }

        // Reset del flag de boost activo cuando termina
        if (g_bFireBoostActive[client] && GetEngineTime() > g_fFireBoostEndTime[client])
        {
            g_bFireBoostActive[client] = false;
        }
    }

    // v5: Water Shield - Bounce (presionar DUCK/CTRL en el aire)
    if (g_bBubbleActive[client])
    {
        int flags = GetEntityFlags(client);
        bool onGround = (flags & FL_ONGROUND) != 0;

        if (!onGround)
        {
            // v5 FIX: Anti spam de bounces (cooldown de 1s)
            if ((buttons & IN_DUCK) && !g_bBubbleDrop[client])
            {
                float now = GetEngineTime();
                if (now - g_fBubbleLastBounceTime[client] >= g_cvSallyWaterBounceCD.FloatValue)
                {
                    g_bBubbleDrop[client] = true;
                    float vel[3];
                    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
                    if (vel[2] > -900.0) vel[2] = -900.0;
                    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
                    PrintCenterText(client, "Caida Sónica de Burbuja!");
                }
            }
            g_bWasInAir[client] = true;
        }
        else
        {
            if (g_bWasInAir[client])
            {
                if (g_bBubbleDrop[client])
                {
                    Sally_PerformBounce(client);
                    g_fBubbleLastBounceTime[client] = GetEngineTime();
                }
                else
                {
                    if (g_iBubbleCombo[client] > 0)
                    {
                        g_iBubbleCombo[client] = 0;
                        PrintCenterText(client, "Combo Reiniciado.");
                    }
                }
            }
            g_bWasInAir[client] = false;
            g_bBubbleDrop[client] = false;
        }
    }
}

// v5: Dash aéreo del Fire Shield (tipo Sonic clasico)
void Sally_PerformFireBoost(int client)
{
    if (!Sally_ShieldSubject(client)) return;   // v6 (R28): regalo de Sage cuenta
    if (!g_bShieldActive[client]) return;

    float now = GetEngineTime();
    g_fFireBoostNextUse[client] = now + g_cvSallyFireBoostCD.FloatValue;
    g_bFireBoostActive[client] = true;
    g_fFireBoostEndTime[client] = now + 0.3; // duración del boost visual

    // Impulso frontal en la dirección que mira Sally
    float ang[3], fwd[3], vel[3];
    GetClientEyeAngles(client, ang);
    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);

    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[0] += fwd[0] * g_cvSallyFireBoostForce.FloatValue;
    vel[1] += fwd[1] * g_cvSallyFireBoostForce.FloatValue;
    vel[2] += 100.0; // pequeño impulso vertical

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    // Efectos visuales
    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 20.0;

    int sprite = PrecacheModel(SALLY_PARTICLE_RING);
    TE_SetupBeamRingPoint(pos, 10.0, 200.0, sprite, 0, 0, 0, 0.3, 5.0, 1.0, {255, 100, 30, 200}, 0, 0);
    TE_SendToAll();

    TE_SetupSparks(pos, fwd, 5, 3);
    TE_SendToAll();

    // Sonido (con fallback)
    EmitSoundToAll(SALLY_SND_FIRE_BOOST, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    EmitSoundToAll(SALLY_SND_FALLBACK, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5);

    PrintCenterText(client, "FIRE DASH!");
    PrintHintText(client, "Fire Shield HP: %.0f / %.0f\nDash CD: %.1fs",
        g_fFireShieldHP[client], g_cvSallyFireMaxHP.FloatValue, g_cvSallyFireBoostCD.FloatValue);
}

void Sally_PerformBounce(int client)
{
    if (!Sally_ShieldSubject(client)) return;   // v6 (R28): regalo de Sage cuenta

    int combo = g_iBubbleCombo[client];
    if (combo > 7) combo = 7;

    float baseForce = g_cvSallyBounceBase.FloatValue;
    float finalForce = baseForce * (1.0 + (float(combo) * 0.1));

    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[2] = finalForce;

    float pos[3]; GetClientAbsOrigin(client, pos);
    pos[2] += 15.0;

    TeleportEntity(client, pos, NULL_VECTOR, vel);

    g_iBubbleCombo[client]++;
    EmitSoundToAll(SALLY_SND_BOUNCE, client);

    Sally_BubblePlop(pos);

    float damage = g_cvSallyBounceDamage.FloatValue + (combo * 10.0);

    int sprite = PrecacheModel(SALLY_PARTICLE_RING);
    TE_SetupBeamRingPoint(pos, 10.0, 300.0, sprite, 0, 0, 0, 0.5, 10.0, 0.0, {0, 255, 255, 200}, 0, 0);
    TE_SendToAll();

    float radius = SALLY_WATER_BOUNCE_RADIUS;

    // Infectados especiales
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidInfected(i))
        {
            float tPos[3]; GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(pos, tPos) <= radius)
            {
                SDKHooks_TakeDamage(i, client, client, damage, DMG_SHOCK);
                // v48: stagger SEGURO (SIStagger_Auto): los bots
                // staggered a veces no se levantan solos (bug del motor
                // con OnStaggered); auto-cancel a los 1.8s/3.0s.
                SIStagger_Auto(i, client, pos);

                float push[3];
                MakeVectorFromPoints(pos, tPos, push);
                NormalizeVector(push, push);
                ScaleVector(push, 500.0);
                push[2] += 200.0;
                TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }

    // Infectados comunes
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(pos, zPos) <= radius)
            {
                SDKHooks_TakeDamage(entity, client, client, damage, DMG_BLAST);
                float push[3];
                MakeVectorFromPoints(pos, zPos, push);
                NormalizeVector(push, push);
                ScaleVector(push, 600.0);
                push[2] = 300.0;
                TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }

    PrintCenterText(client, "BOING! (Combo x%d)", g_iBubbleCombo[client]);
}

// =======================
// Think Timer
// =======================

public Action T_SallyThink(Handle timer)
{
    if (!g_bSallyMapActive) return Plugin_Continue;
    if (g_cvSallyEnable == null && g_cvSallyBubbleEnable == null) return Plugin_Continue;

    float now = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2)
        {
            if (i <= MaxClients && g_bShieldActive[i]) Sally_StopShield(i);
            if (i <= MaxClients && g_bBubbleActive[i]) Sally_StopBubble(i);
            continue;
        }

        // v5: Fire Shield - lógica permanente (sin timer de fin)
        if (g_bShieldActive[i])
        {
            float pos[3]; GetClientAbsOrigin(i, pos);
            pos[0] += GetRandomFloat(-20.0, 20.0);
            pos[1] += GetRandomFloat(-20.0, 20.0);
            pos[2] += GetRandomFloat(10.0, 50.0);
            TE_SetupSparks(pos, view_as<float>({0.0, 0.0, 50.0}), 2, 1);
            TE_SendToAll();

            // Pulso de dano periodico (cada tick)
            if (now >= g_fShieldNextTick[i])
            {
                // Actualizar tiempo del próximo tick
                g_fShieldNextTick[i] = now + ((g_cvSallyTick != null) ? g_cvSallyTick.FloatValue : 0.5);
                Sally_ApplyShieldPulse(i);
            }

            // Mostrar HP en pantalla cada 0.5s
            if (now >= g_fFireBoostEndTime[i] + 0.5)
            {
                PrintHintText(i, "Fire Shield HP: %.0f / %.0f",
                    g_fFireShieldHP[i], g_cvSallyFireMaxHP.FloatValue);
            }
        }

        // v5: Water Shield - lógica permanente + regeneración
        if (g_bBubbleActive[i])
        {
            // v5: Regeneración de HP cada 1.5s
            if (now >= g_fWaterNextRegenTick[i])
            {
                g_fWaterNextRegenTick[i] = now + g_cvSallyWaterRegenInterval.FloatValue;
                Sally_WaterRegenTick(i);
            }

            // Mostrar HP en pantalla cada 0.5s
            if (now >= g_fWaterNextRegenTick[i] - 0.5)
            {
                PrintHintText(i, "Water Shield HP: %.0f / %.0f",
                    g_fWaterShieldHP[i], g_cvSallyWaterMaxHP.FloatValue);
            }

            // Efectos visuales esporadicos
            if (now >= g_fBubbleLastBounceTime[i] + 0.2)
            {
                float bPos[3]; GetClientAbsOrigin(i, bPos);
                bPos[0] += GetRandomFloat(-40.0, 40.0);
                bPos[1] += GetRandomFloat(-40.0, 40.0);
                bPos[2] += GetRandomFloat(10.0, 80.0);

                int sprite = PrecacheModel("materials/sprites/glow01.vmt");
                TE_SetupGlowSprite(bPos, sprite, 0.5, 0.3, 80);
                TE_SendToAll();
            }
        }
    }
    return Plugin_Continue;
}

// v5: Regeneración de HP del Water Shield
void Sally_WaterRegenTick(int client)
{
    if (!Sally_ShieldSubject(client)) return;   // v6 (R28): regen también para regalos
    if (!g_bBubbleActive[client]) return;

    int hp = GetClientHealth(client);
    int maxHp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
    if (maxHp <= 0) maxHp = 100;

    if (hp < maxHp)
    {
        int regenAmount = g_cvSallyWaterRegenAmount.IntValue;
        int newHp = hp + regenAmount;
        if (newHp > maxHp) newHp = maxHp;
        SetEntityHealth(client, Sally_ClampHP(newHp));
    }
}

// =======================
// Lógica Escudo Fuego (v5 rework)
// =======================

public Action Cmd_ToggleShield(int client, int args)
{
    // v5 FIX: Validación estricta de que es Sally
    if (!Sally_IsSally(client)) return Plugin_Handled;
    if (g_cvSallyEnable == null || !g_cvSallyEnable.BoolValue) return Plugin_Handled;
    if (g_cvSallyOnlyHuman != null && g_cvSallyOnlyHuman.BoolValue && IsFakeClient(client) && !Sonic_IsSoloHost(client)) return Plugin_Handled;

    // Si ya tiene el escudo activo, desactivarlo
    if (g_bShieldActive[client])
    {
        Sally_StopShield(client, false); // false = no explosión, solo apagar
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fShieldNextUse[client])
    {
        PrintToChat(client, "\x04[Sally]\x01 Enfriamiento: \x05%.1fs\x01", g_fShieldNextUse[client] - now);
        return Plugin_Handled;
    }

    // v5: No se pueden tener 2 escudos a la vez
    if (g_bBubbleActive[client])
    {
        PrintToChat(client, "\x04[Sally]\x01 Ya tienes el escudo de agua activo. Desactivalo primero.");
        return Plugin_Handled;
    }

    // Activar Fire Shield
    g_bShieldActive[client] = true;

    // v5: HP del escudo = máximo configurado
    g_fFireShieldHP[client] = g_cvSallyFireMaxHP.FloatValue;
    g_fShieldNextTick[client] = 0.0;
    g_fFireBoostNextUse[client] = 0.0;
    g_bFireBoostActive[client] = false;

    // v5: Ya no cambia el color de Sally (más sutil)
    CreateSallyFireBarrier(client);
    Sally_EffectStart(client);
    PrintToChat(client, "\x04[Sally]\x05 Escudo de Fuego activado!\x01 HP: %.0f | Dash: presiona CTRL en el aire",
        g_fFireShieldHP[client]);
    return Plugin_Handled;
}

// v5: Detener el Fire Shield (puede ser con explosión o sin)
// withExplosion = false por defecto (para llamadas con 1 solo argumento)
void Sally_StopShield(int client, bool withExplosion = false)
{
    if (!g_bShieldActive[client]) return;
    g_bShieldActive[client] = false;
    g_fShieldNextUse[client] = GetEngineTime() + g_cvSallyCooldown.FloatValue;

    DestroySallyFireBarrier(client);
    DestroySallyFireAura(client);
    Sally_EffectStop(client);
    Sally_StopAllSounds(client);

    if (IsClientInGame(client))
    {
        SetEntityRenderMode(client, RENDER_NORMAL);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }

    // v5: Explosión al romperse (solo si withExplosion = true)
    if (withExplosion && IsClientInGame(client) && IsPlayerAlive(client))
    {
        Sally_FireShieldExplosion(client);
        PrintToChat(client, "\x04[Sally]\x01 Escudo destruido! Explosión liberada.");
    }
    else
    {
        PrintToChat(client, "\x04[Sally]\x01 Escudo de Fuego desactivado.");
    }
}

// v5: Explosión del Fire Shield al romperse
void Sally_FireShieldExplosion(int client)
{
    if (!Sally_ShieldSubject(client)) return;   // v6 (R28): regalo roto = explota igual

    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 20.0;

    float radius = g_cvSallyFireExplosionRadius.FloatValue;
    float damage = g_cvSallyFireExplosionDmg.FloatValue;
    float igniteTime = g_cvSallyFireExplosionIgnite.FloatValue;

    // Efectos visuales
    int sprite = PrecacheModel(SALLY_PARTICLE_RING);
    TE_SetupBeamRingPoint(pos, 10.0, radius, sprite, 0, 0, 0, 0.5, 15.0, 2.0, {255, 100, 30, 255}, 0, 0);
    TE_SendToAll();

    TE_SetupSparks(pos, NULL_VECTOR, 20, 10);
    TE_SendToAll();

    // Sonido de explosión
    // v6.1 (R28.1) FIX 2: la rotura suena en el MISMO canal del loop
    // (desaloja el sonido vivo) ; el fallback se queda en AUTO para no
    // pisarlo. Sonido de rotura = reemplazo físico del de escudo.
    EmitSoundToAll(SALLY_SND_FIRE_BREAK, client, SALLY_SHIELD_SNDCHAN, SNDLEVEL_RAIDSIREN);
    EmitSoundToAll(SALLY_SND_FALLBACK, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.8);

    // Dano + quemado + retroceso a infectados especiales
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidInfected(i)) continue;

        float tPos[3]; GetClientAbsOrigin(i, tPos);
        if (GetVectorDistance(pos, tPos) <= radius)
        {
            SDKHooks_TakeDamage(i, client, client, damage, DMG_BURN);
            IgniteEntity(i, igniteTime);
            // v48: stagger SEGURO (auto-recuperación garantizada)
            SIStagger_Auto(i, client, pos);

            float push[3];
            MakeVectorFromPoints(pos, tPos, push);
            NormalizeVector(push, push);
            ScaleVector(push, 800.0);
            push[2] += 300.0;
            TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
        }
    }

    // Dano + quemado a infectados comunes
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(pos, zPos) <= radius)
        {
            SDKHooks_TakeDamage(entity, client, client, damage * 2.0, DMG_BURN);
            IgniteEntity(entity, igniteTime);

            float push[3];
            MakeVectorFromPoints(pos, zPos, push);
            NormalizeVector(push, push);
            ScaleVector(push, 1000.0);
            push[2] = 400.0;
            TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
}

void Sally_ApplyShieldPulse(int owner)
{
    if (!Sally_ShieldSubject(owner)) return;    // v6 (R28): el aura late igual en los regalos

    float origin[3]; GetClientAbsOrigin(owner, origin);
    float radius = g_cvSallyRadius.FloatValue;
    float push = g_cvSallyPushForce.FloatValue;
    float ignite = g_cvSallyIgniteTime.FloatValue;
    float damage = g_cvSallyDPS.FloatValue * g_cvSallyTick.FloatValue;

    int sprite = PrecacheModel(SALLY_PARTICLE_RING);
    TE_SetupBeamRingPoint(origin, 10.0, radius, sprite, 0, 0, 0, 0.2, 4.0, 2.0, {255, 100, 30, 100}, 0, 0);
    TE_SendToAll();

    TE_SetupSparks(origin, NULL_VECTOR, 10, 5);
    TE_SendToAll();

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity)) Sally_ProcessEntity(owner, entity, origin, radius * radius, damage, push, ignite);
    }
    for (int j = 1; j <= MaxClients; j++)
    {
        if (IsValidInfected(j)) Sally_ProcessEntity(owner, j, origin, radius * radius, damage, push, ignite);
    }
}

void Sally_ProcessEntity(int owner, int ent, const float origin[3], float radiusSq, float damage, float push, float ignite)
{
    if (!IsValidEntity(ent)) return;

    float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
    if (GetVectorDistance(origin, pos, true) > radiusSq) return;

    float dir[3];
    MakeVectorFromPoints(origin, pos, dir);
    NormalizeVector(dir, dir);
    ScaleVector(dir, push);
    dir[2] += 200.0;

    TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, dir);

    SDKHooks_TakeDamage(ent, owner, owner, damage, DMG_BURN);
    IgniteEntity(ent, ignite);
}

// =======================
// Lógica Escudo Burbuja (v5 rework)
// =======================

public Action Cmd_ToggleBubble(int client, int args)
{
    // v5 FIX: Validación estricta de que es Sally
    if (!Sally_IsSally(client)) return Plugin_Handled;
    if (g_cvSallyBubbleEnable == null || !g_cvSallyBubbleEnable.BoolValue) return Plugin_Handled;
    if (g_cvSallyOnlyHuman != null && g_cvSallyOnlyHuman.BoolValue && IsFakeClient(client) && !Sonic_IsSoloHost(client)) return Plugin_Handled;

    // Si ya tiene el escudo activo, desactivarlo
    if (g_bBubbleActive[client])
    {
        Sally_StopBubble(client);
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fBubbleNextUse[client])
    {
        PrintToChat(client, "\x04[Sally]\x01 Enfriamiento: \x05%.1fs\x01", g_fBubbleNextUse[client] - now);
        return Plugin_Handled;
    }

    // v5: No se pueden tener 2 escudos a la vez
    if (g_bShieldActive[client])
    {
        PrintToChat(client, "\x04[Sally]\x01 Ya tienes el escudo de fuego activo. Desactivalo primero.");
        return Plugin_Handled;
    }

    // Activar Water Shield
    g_bBubbleActive[client] = true;

    // v5: HP del escudo = máximo configurado
    g_fWaterShieldHP[client] = g_cvSallyWaterMaxHP.FloatValue;
    g_fWaterNextRegenTick[client] = now + g_cvSallyWaterRegenInterval.FloatValue;

    g_iBubbleCombo[client] = 0;
    g_bBubbleDrop[client] = false;
    g_fBubbleLastBounceTime[client] = 0.0;

    CreateSallyBubbleBarrier(client);
    Sally_EffectBubbleStart(client);
    PrintToChat(client, "\x04[Sally]\x05 Escudo de Agua activado!\x01 HP: %.0f | Regen: +%d HP/%.1fs\nPresiona CTRL en el aire para rebotar",
        g_fWaterShieldHP[client], g_cvSallyWaterRegenAmount.IntValue, g_cvSallyWaterRegenInterval.FloatValue);
    return Plugin_Handled;
}

void Sally_StopBubble(int client)
{
    if (!g_bBubbleActive[client]) return;
    g_bBubbleActive[client] = false;
    g_fBubbleNextUse[client] = GetEngineTime() + g_cvSallyBubbleCooldown.FloatValue;

    Sally_EffectBubbleStop(client);
    Sally_StopAllSounds(client);

    float pos[3]; GetClientAbsOrigin(client, pos);
    pos[2] += 20.0;
    Sally_BubblePlop(pos);

    DestroySallyBubbleBarrier(client);

    if (IsClientInGame(client))
    {
        SetEntityRenderMode(client, RENDER_NORMAL);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
    PrintToChat(client, "\x04[Sally]\x01 Escudo de Agua desactivado.");
}

// =======================
// Gestion de Dano (v5: escudos absorben dano)
// =======================

public Action Sally_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (victim < 1 || victim > MaxClients) return Plugin_Continue;
    // v6 (R28): el absorb de escudos cubre a la Sally real Y a los
    // receptores de regalo de Sage. Las pasivas PERSONALES de Sally
    // (acido/veneno/radiación) NO viajan con el regalo.
    if (g_iPlayerCharIdx[victim] != SALLY_INDEX
        && !g_bSageGiftWater[victim] && !g_bSageGiftFire[victim]) return Plugin_Continue;
    if (!IsValidSurvivor(victim)) return Plugin_Continue;

    // Inmunidad a dano toxico/acido/radiación (pasiva de SOLO la Sally real)
    if (g_iPlayerCharIdx[victim] == SALLY_INDEX
        && ((damagetype & DMG_ACID) || (damagetype & DMG_POISON) || (damagetype & DMG_RADIATION)))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // v6.1 (R28.1) FIX 1 - pedido del owner: "el rebote del escudo de
    // agua no debería destruirse apenas se use". CAUSA: la caida
    // rebotona frena a -900 y al aterrizar el motor aplicaba dano de
    // caida (DMG_FALL) que el PROPIO escudo absorbia en el bloque de
    // abajo: el slam se auto-comia el HP de la burbuja y la rompia en
    // 1-2 usos. FIX: la burbuja acolcha TODAS las caidas mientras este
    // activa (Sally real y regalos de Sage por igual) — el dano de
    // caida se niega SIN tocar el HP del escudo. En el Sonic clasico
    // el escudo de agua hace exactamente esto: cancela el impacto.
    if (g_bBubbleActive[victim] && (damagetype & DMG_FALL))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // v5: Fire Shield absorbe dano
    if (g_bShieldActive[victim])
    {
        // El escudo absorbe todo el dano
        g_fFireShieldHP[victim] -= damage;
        damage = 0.0; // Sally no recibe dano

        // Efecto visual de absorción
        float vPos[3]; GetClientAbsOrigin(victim, vPos);
        vPos[2] += 20.0;
        TE_SetupSparks(vPos, NULL_VECTOR, 3, 2);
        TE_SendToAll();

        // Mostrar HP restante
        PrintHintText(victim, "Fire Shield HP: %.0f / %.0f",
            g_fFireShieldHP[victim] > 0 ? g_fFireShieldHP[victim] : 0.0,
            g_cvSallyFireMaxHP.FloatValue);

        // Si el escudo se rompió, explosión!
        if (g_fFireShieldHP[victim] <= 0.0)
        {
            Sally_StopShield(victim, true); // true = con explosión
        }

        return Plugin_Handled;
    }

    // v5: Water Shield absorbe dano + rebate al atacante
    if (g_bBubbleActive[victim])
    {
        // El escudo absorbe todo el dano
        g_fWaterShieldHP[victim] -= damage;
        damage = 0.0; // Sally no recibe dano

        // Efecto visual de absorción
        float vPos[3]; GetClientAbsOrigin(victim, vPos);
        vPos[2] += 20.0;
        TE_SetupSparks(vPos, NULL_VECTOR, 3, 2);
        TE_SendToAll();

        // Rebote del atacante (igual que antes)
        if (IsValidInfected(attacker))
        {
            float push = g_cvSallyBubbleReflect.FloatValue;
            Sally_ProcessEntity(victim, attacker, vPos, 99999.9, 0.0, push, 0.0);
            EmitSoundToAll(SALLY_SND_WATER_REFLECT, victim);

            // v48: liberación COMPLETA del agarre vía Pin_Release.
            // Antes solo se limpiaban las props del lado de la victima
            // (el hunter/jockey/smoker quedaba con su m_pounceVictim
            // apuntando a Sally) y la música de agarre le seguida
            // sonando a Sally en loop. PinRelease_Cleanse limpia ambos
            // lados, corta la música del motor (L4D_StopMusic) y
            // aturde al atacante con stagger seguro (auto getup).
            PinRelease_Cleanse(victim);
        }

        // Mostrar HP restante
        PrintHintText(victim, "Water Shield HP: %.0f / %.0f",
            g_fWaterShieldHP[victim] > 0 ? g_fWaterShieldHP[victim] : 0.0,
            g_cvSallyWaterMaxHP.FloatValue);

        // Si el escudo se rompió, caer
        if (g_fWaterShieldHP[victim] <= 0.0)
        {
            Sally_StopBubble(victim);
        }

        return Plugin_Handled;
    }

    return Plugin_Continue;
}

bool Sally_IsBubbleActive(int client)
{
    if (client < 1 || client > MaxClients) return false;
    return g_bBubbleActive[client];
}

// =======================
// Utilidades de Chat y Audio
// =======================

void Sally_EffectStart(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    // v6.1 (R28.1) FIX 2: canal propio del escudo (corte exacto al morir)
    EmitSoundToAll(SALLY_SND_FIRE_START, client, SALLY_SHIELD_SNDCHAN);
}

void Sally_EffectStop(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    // v6.1 (R28.1) FIX 2: MISMO canal del loop — el jingle de apagado
    // desaloja el slot del sonido vivo además del StopSound previo
    EmitSoundToAll(SALLY_SND_FIRE_STOP, client, SALLY_SHIELD_SNDCHAN);
}

void Sally_EffectBubbleStart(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    EmitSoundToAll(SALLY_SND_WATER_START, client, SALLY_SHIELD_SNDCHAN);
}

void Sally_EffectBubbleStop(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    EmitSoundToAll(SALLY_SND_WATER_STOP, client, SALLY_SHIELD_SNDCHAN);
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
public void Sally_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != SALLY_INDEX) return;
    Sally_ResetState(client, false);
}

// ============================================================================
//  SISTEMA DOLL — Pasivas especiales para SteamIDs específicas
//  Solo se activa cuando la SteamID de Sally y Amy coinciden.
//  Amy:   STEAM_0:1:410494263   (La Princesa / Dueña)
//  Sally: STEAM_0:0:889541669   (La Muñequita de juegos)
//
//  -----------------------------------------------------------------------
//  TRASFONDO TEMÁTICO
//  -----------------------------------------------------------------------
//  Amy es la Princesa. Sally es SU muñequita de juegos.
//  No es una jugadora libre: vive en su cajita y solo sale para jugar
//  con la Princesa. Si se aleja demasiado, la Princesa la jala de la
//  cintura con hilos mágicos y la devuelve a su cajita.
//
//  Pasiva 2: "TRAE ESA CINTURA PARA ACÁ"
//    - Le recuerda a Sally que ella es una muñequita de juegos.
//    - La cintura es el "asa" por donde la muñeca es arrastrada.
//    - Si Sally se aleja >1200 de Amy → TP de vuelta + buff 75% por 6s.
//    - Aviso a Amy: "Sally se alejó mucho, ella no puede escapar de su cajita."
//  -----------------------------------------------------------------------
// ============================================================================

#define DOLL_AMY_STEAMID   "STEAM_1:1:410494263"
#define DOLL_SALLY_STEAMID "STEAM_1:0:889541669"

// Helper: comparar SteamID aceptando tanto STEAM_0: como STEAM_1: (compatibilidad L4D2)
bool Doll_MatchSteamID(const char[] actualAuth, const char[] expectedAuth)
{
    // Comparación directa
    if (StrEqual(actualAuth, expectedAuth)) return true;

    // Si el actual empieza con STEAM_0 y el esperado con STEAM_1 (o viceversa),
    // comparar ignorando ese dígito
    if (strlen(actualAuth) >= 8 && strlen(expectedAuth) >= 8)
    {
        if (actualAuth[5] != expectedAuth[5])
        {
            if (StrEqual(actualAuth[7], expectedAuth[7])) return true;
        }
    }
    return false;
}

// Helper: leer m_iSurvivorCharacter de forma segura (sin crashear)
// ESTRATEGIA: usar el nombre del modelo como fuente PRIMARIA (más confiable)
int Doll_GetSurvCharSafe(int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return -1;
    if (GetClientTeam(client) != TEAM_SURVIVOR) return -1;

    // Usar el nombre del modelo como fuente primaria
    char modelName[256];
    GetEntPropString(client, Prop_Data, "m_ModelName", modelName, sizeof(modelName));

    // Detectar por nombre de modelo
    if (StrContains(modelName, "rochelle", false) >= 0 ||
        StrContains(modelName, "survivor_producer", false) >= 0) return 1;
    if (StrContains(modelName, "zoey", false) >= 0 ||
        StrContains(modelName, "survivor_teenangst", false) >= 0) return 0;
    if (StrContains(modelName, "coach", false) >= 0 ||
        StrContains(modelName, "survivor_coach", false) >= 0) return 2;
    if (StrContains(modelName, "ellis", false) >= 0 ||
        StrContains(modelName, "survivor_mechanic", false) >= 0) return 3;
    if (StrContains(modelName, "nick", false) >= 0 ||
        StrContains(modelName, "survivor_gambler", false) >= 0) return 4;
    if (StrContains(modelName, "bill", false) >= 0 ||
        StrContains(modelName, "survivor_namvet", false) >= 0) return 5;
    if (StrContains(modelName, "francis", false) >= 0 ||
        StrContains(modelName, "survivor_biker", false) >= 0) return 6;
    if (StrContains(modelName, "louis", false) >= 0 ||
        StrContains(modelName, "survivor_manager", false) >= 0) return 7;

    // Fallback: si el modelo no se reconoce, usar m_iSurvivorCharacter
    if (HasEntProp(client, Prop_Send, "m_iSurvivorCharacter"))
    {
        return GetEntProp(client, Prop_Send, "m_iSurvivorCharacter");
    }

    return -1;
}

#define CINTURA_MAX_DIST      1200.0
#define CINTURA_WARN_DIST     1000.0
#define SALLY_TAROT_CD        25.0
#define SALLY_SHIELD_CD_MULT  2.0
#define DOLL_DMG_REDUCE_BASE  0.50
#define DOLL_DMG_REDUCE_CINTURA 0.75
#define CINTURA_BUFF_DURATION  6.0
#define DODGE_INVULN_DURATION  2.5
#define DODGE_CHANCE          50
#define DOLL_CONTROL_DURATION  5.0

// PASIVA 4: Nervios de acero
#define NERVIOS_MAX_REVIVES     3
#define NERVIOS_DMG_MULT_LV1    2.0   // Tras 1er revive: 2x daño a infectados
#define NERVIOS_DMG_MULT_LV2    4.5   // Tras 2do revive: 4.5x
#define NERVIOS_DMG_MULT_LV3    7.0   // Tras 3er revive: 7x

// PASIVA 6: Cintura y alma dominada
#define ALMA_REGEN_INTERVAL     4.0   // 1 HP cada 4s (Amy viva)
#define ALMA_REGEN_INTERVAL_DEAD 2.0  // 1 HP cada 2s (Amy caída)

// PASIVA 11: Doble salto (cuando Amy cayó)
#define DOLL_DOUBLEJUMP_FORCE   300.0

bool  g_bDollSally[MAXPLAYERS + 1];
bool  g_bDollAmy[MAXPLAYERS + 1];
int   g_iDollAmyClient = -1;
int   g_iDollSallyClient = -1;
bool  g_bCinturaBuff[MAXPLAYERS + 1];
float g_fCinturaBuffEnd[MAXPLAYERS + 1];
bool  g_bAmyDead[MAXPLAYERS + 1];
bool  g_bDollControl[MAXPLAYERS + 1];
float g_fDollControlEnd[MAXPLAYERS + 1];
bool  g_bDodgeActive[MAXPLAYERS + 1];
float g_fDodgeEnd[MAXPLAYERS + 1];
bool  g_bWarnedFar[MAXPLAYERS + 1];
stock Handle g_hDollResizeMenu = null;        // legacy: asignado pero nunca leido

// PASIVA 4: Nervios de acero — contador de revives
int   g_iNerviosReviveCount[MAXPLAYERS + 1];  // 0 a NERVIOS_MAX_REVIVES
float g_fNerviosDmgMult[MAXPLAYERS + 1];       // multiplicador actual

// PASIVA 6: Cintura y alma dominada — regen
float g_fAlmaLastRegen[MAXPLAYERS + 1];        // último tick de regen
// Anti-witch: si Sally está sola, witch instakill = nullificado
// Daño a witch = 100x

// PASIVA 11: Doble salto (cuando Amy cayó)
bool  g_bDollJumped[MAXPLAYERS + 1];           // ya hizo el 2do salto en el aire
int   g_iDollJumpCount[MAXPLAYERS + 1];        // saltos hechos en el aire

// Inicialización del sistema Doll
void Doll_OnPluginStart()
{
    HookEvent("player_spawn", Doll_OnPlayerSpawn);
    HookEvent("player_death", Doll_OnPlayerDeath);
    HookEvent("round_start", Doll_OnRoundStart, EventHookMode_PostNoCopy);
    HookEvent("player_incapacitated", Doll_OnPlayerIncapacitated);  // PASIVA 4
    HookEvent("player_ledge_grab", Doll_OnPlayerIncapacitated);     // PASIVA 4 (ledge grab)
    HookEvent("witch_spawn", Doll_OnWitchSpawn);                    // PASIVA 6 anti-witch
}

void Doll_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bDollSally[i] = false;
        g_bDollAmy[i] = false;
        g_bAmyDead[i] = false;
        g_bDollControl[i] = false;
        g_bDodgeActive[i] = false;
        g_bCinturaBuff[i] = false;
        g_bWarnedFar[i] = false;

        // PASIVA 4 / 6 / 11 reset
        g_iNerviosReviveCount[i] = 0;
        g_fNerviosDmgMult[i]     = 1.0;
        g_fAlmaLastRegen[i]      = 0.0;
        g_bDollJumped[i]         = false;
        g_iDollJumpCount[i]      = 0;
    }
    g_iDollAmyClient = -1;
    g_iDollSallyClient = -1;
}

void Doll_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    // PASIVA 4: Hookear Special Infected para multiplicador de daño de Sally
    if (GetClientTeam(client) == TEAM_INFECTED)
    {
        SDKHook(client, SDKHook_OnTakeDamage, Doll_OnSIDamage);
    }

    char auth[32];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));

    if (Doll_MatchSteamID(auth, DOLL_AMY_STEAMID))
    {
        g_bDollAmy[client] = true;
        g_iDollAmyClient = client;
        g_bAmyDead[client] = false;

        // DEBUG: anuncio en consola del servidor
        int survivor = Doll_GetSurvCharSafe(client);
        char survName[32];
        switch(survivor)
        {
            case 0: strcopy(survName, sizeof(survName), "Nick");
            case 1: strcopy(survName, sizeof(survName), "Rochelle");
            case 2: strcopy(survName, sizeof(survName), "Coach");
            case 3: strcopy(survName, sizeof(survName), "Ellis");
            case 4: strcopy(survName, sizeof(survName), "Bill");
            case 5: strcopy(survName, sizeof(survName), "Zoey");
            case 6: strcopy(survName, sizeof(survName), "Francis");
            case 7: strcopy(survName, sizeof(survName), "Louis");
            default: strcopy(survName, sizeof(survName), "Desconocido");
        }
        PrintToServer("[Doll] === AMY ESPECIAL CONECTADA ===");
        PrintToServer("[Doll] SteamID: %s", auth);
        PrintToServer("[Doll] Client: %d | Nombre: %N", client, client);
        PrintToServer("[Doll] Survivor: %s (ID %d)", survName, survivor);
        PrintToServer("[Doll] Estado: Doll Amy activa");

        if (survivor == 5)
        {
            PrintToServer("[Doll] ✓ Amy usando Zoey (correcto)");
        }
        else
        {
            PrintToServer("[Doll] ✗ ADVERTENCIA: Amy NO está usando Zoey (usa %s). Las pasivas Doll no funcionaran correctamente.", survName);
            PrintToChat(client, "\x04[Doll]\x01 ADVERTENCIA: Debes usar a \x04Zoey\x01 para que las pasivas Doll funcionen.");
        }

        // Verificar si Sally también está conectada
        if (g_iDollSallyClient > 0 && IsClientInGame(g_iDollSallyClient))
        {
            PrintToServer("[Doll] ✓ Sally especial detectada (client %d). Sistema Doll ACTIVO.", g_iDollSallyClient);
        }
        else
        {
            PrintToServer("[Doll] ✗ Sally especial NO detectada. Sistema Doll incompleto.");
        }
    }

    if (Doll_MatchSteamID(auth, DOLL_SALLY_STEAMID))
    {
        g_bDollSally[client] = true;
        g_iDollSallyClient = client;
        g_bWarnedFar[client] = false;
        SDKHook(client, SDKHook_OnTakeDamage, Doll_OnTakeDamage);

        // DEBUG: anuncio en consola del servidor
        int survivor = Doll_GetSurvCharSafe(client);
        char survName[32];
        switch(survivor)
        {
            case 0: strcopy(survName, sizeof(survName), "Nick");
            case 1: strcopy(survName, sizeof(survName), "Rochelle");
            case 2: strcopy(survName, sizeof(survName), "Coach");
            case 3: strcopy(survName, sizeof(survName), "Ellis");
            case 4: strcopy(survName, sizeof(survName), "Bill");
            case 5: strcopy(survName, sizeof(survName), "Zoey");
            case 6: strcopy(survName, sizeof(survName), "Francis");
            case 7: strcopy(survName, sizeof(survName), "Louis");
            default: strcopy(survName, sizeof(survName), "Desconocido");
        }
        PrintToServer("[Doll] === SALLY ESPECIAL CONECTADA ===");
        PrintToServer("[Doll] SteamID: %s", auth);
        PrintToServer("[Doll] Client: %d | Nombre: %N", client, client);
        PrintToServer("[Doll] Survivor: %s (ID %d)", survName, survivor);
        PrintToServer("[Doll] Estado: Doll Sally activa");

        if (survivor == 1)
        {
            PrintToServer("[Doll] ✓ Sally usando Rochelle (correcto)");
        }
        else
        {
            PrintToServer("[Doll] ✗ ADVERTENCIA: Sally NO está usando Rochelle (usa %s). Las pasivas Doll no funcionaran correctamente.", survName);
            PrintToChat(client, "\x04[Doll]\x01 ADVERTENCIA: Debes usar a \x04Rochelle\x01 para que las pasivas Doll funcionen.");
        }

        // Verificar si Amy también está conectada
        if (g_iDollAmyClient > 0 && IsClientInGame(g_iDollAmyClient))
        {
            PrintToServer("[Doll] ✓ Amy especial detectada (client %d). Sistema Doll ACTIVO.", g_iDollAmyClient);
        }
        else
        {
            PrintToServer("[Doll] ✗ Amy especial NO detectada. Sistema Doll incompleto.");
        }
    }
}

void Doll_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    if (victim <= 0 || victim > MaxClients) return;

    if (g_bDollAmy[victim])
    {
        g_bAmyDead[victim] = true;
        if (g_iDollSallyClient > 0 && IsClientInGame(g_iDollSallyClient))
        {
            PrintHintText(g_iDollSallyClient, "<font color='#FF0000' size='24'>>> MUÑECA PRINCESA <<</font>\n<font color='#FF80C0'>Amy ha caido. Despierta, Sally.</font>");
        }
    }

    if (g_bDollSally[victim])
    {
        g_bDodgeActive[victim] = false;
        g_bDollControl[victim] = false;
        g_bCinturaBuff[victim] = false;
    }
}

// PASIVA 2 + 3: "TRAE ESA CINTURA PARA ACÁ" + Doll atrapada
// Le recuerda a Sally que es una muñequita de juegos de la Princesa.
// La cintura es el asa por donde la muñeca es arrastrada.
void Doll_PreThink(int client)
{
    if (!g_bDollSally[client]) return;
    if (!IsPlayerAlive(client)) return;
    if (g_iDollAmyClient <= 0 || !IsClientInGame(g_iDollAmyClient) || !IsPlayerAlive(g_iDollAmyClient)) return;

    float sallyPos[3], amyPos[3];
    GetClientAbsOrigin(client, sallyPos);
    GetClientAbsOrigin(g_iDollAmyClient, amyPos);
    float dist = GetVectorDistance(sallyPos, amyPos);

    if (dist >= CINTURA_WARN_DIST && dist < CINTURA_MAX_DIST && !g_bWarnedFar[client])
    {
        PrintHintText(client, "<font color='#FF80C0'>¡Te estás alejando mucho de Amy!</font>\n<font color='#FFFFFF'>Distancia: %.0f / %.0f</font>", dist, CINTURA_MAX_DIST);
        g_bWarnedFar[client] = true;
    }
    else if (dist < CINTURA_WARN_DIST)
    {
        g_bWarnedFar[client] = false;
    }

    if (dist >= CINTURA_MAX_DIST)
    {
        // Los hilos de la Princesa cortan cualquier agarre de SI antes del TP.
        // Temáticamente: la muñequita es jalada con tanta fuerza que los
        // Hunter/Smoker/Charger/Jockey la sueltan.
        bool wasGrappled = Doll_IsBeingGrappled(client);
        Doll_FreeFromGrapples(client);

        TeleportEntity(client, amyPos, NULL_VECTOR, NULL_VECTOR);

        // Efecto visual: hilo de marioneta desde Amy hasta la cintura de Sally
        float sallyCintura[3];
        sallyCintura = amyPos; // ya teleportada, así que está junto a Amy
        sallyCintura[2] += 36.0; // altura aprox. de la cintura
        Doll_DrawPuppetThread(amyPos, sallyCintura);

        g_bCinturaBuff[client] = true;
        g_fCinturaBuffEnd[client] = GetEngineTime() + CINTURA_BUFF_DURATION;

        // Mensaje a Sally: la Princesa la jaló de la cintura
        if (wasGrappled)
        {
            PrintHintText(client, "<font color='#FF00FF' size='24'>>> TRAE ESA CINTURA PARA ACÁ <<</font>\n<font color='#FF80C0'>La Princesa cortó tus hilos y jaló tu cintura. Vuelve a tu cajita.</font>");
        }
        else
        {
            PrintHintText(client, "<font color='#FF00FF' size='24'>>> TRAE ESA CINTURA PARA ACÁ <<</font>\n<font color='#FF80C0'>La Princesa te jaló de la cintura. Vuelve a tu cajita.</font>");
        }
        EmitSoundToClient(client, "ambient/energy/force_field_loop1.wav");

        // Mensaje a Amy: su muñequita intentó escapar de la cajita
        if (IsClientInGame(g_iDollAmyClient) && !IsFakeClient(g_iDollAmyClient))
        {
            if (wasGrappled)
            {
                PrintHintText(g_iDollAmyClient, "<font color='#FF00FF' size='24'>>> TRAE ESA CINTURA PARA ACÁ <<</font>\n<font color='#FF80C0'>Cortaste los hilos que atrapaban a tu muñequita. Sally vuelve a su cajita.</font>");
            }
            else
            {
                PrintHintText(g_iDollAmyClient, "<font color='#FF00FF' size='24'>>> TRAE ESA CINTURA PARA ACÁ <<</font>\n<font color='#FF80C0'>Sally se alejó mucho, ella no puede escapar de su cajita.</font>");
            }
            EmitSoundToClient(g_iDollAmyClient, "ambient/energy/force_field_loop1.wav");
        }

        g_bWarnedFar[client] = false;
    }

    float now = GetEngineTime();
    if (g_bCinturaBuff[client] && now > g_fCinturaBuffEnd[client])
        g_bCinturaBuff[client] = false;
    if (g_bDodgeActive[client] && now > g_fDodgeEnd[client])
        g_bDodgeActive[client] = false;
    if (g_bDollControl[client] && now > g_fDollControlEnd[client])
        g_bDollControl[client] = false;
}

// PASIVA 3 + 9 + 10: Reducción de daño, dodge, división con Amy
public Action Doll_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!g_bDollSally[victim]) return Plugin_Continue;
    if (!IsPlayerAlive(victim)) return Plugin_Continue;

    float now = GetEngineTime();

    // PASIVA 7: Doll Control → invulnerable
    if (g_bDollControl[victim] && now < g_fDollControlEnd[victim])
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    // PASIVA 9: Dodge activo → invulnerable 2.5s
    if (g_bDodgeActive[victim] && now < g_fDodgeEnd[victim])
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    // PASIVA 6: Inmunidad a daño de fuego
    if (damagetype & DMG_BURN)
    {
        damage = 0.0;
        if (IsClientInGame(victim) && !IsFakeClient(victim))
            PrintHintText(victim, "<font color='#FF80C0'>Los hilos de Amy apagan el fuego. La muñequita no arde.</font>");
        return Plugin_Changed;
    }

    // PASIVA 6: Anti-Witch — si Sally está sola, el instakill de la Witch es nulo
    // Detectamos Witch como atacante
    if (attacker > 0 && attacker <= MaxClients && GetClientTeam(attacker) == TEAM_INFECTED)
    {
        // Witch es un SI especial: clase witch (zombie class 7 en L4D2)
        // Pero las witches son NPCs, no jugadores. Esto se maneja en Doll_OnWitchSpawn
        // y vía SDKHook en la witch.
    }

    // PASIVA 9: 50% chance de dodge
    if (!g_bDodgeActive[victim] && GetRandomInt(1, 100) <= DODGE_CHANCE)
    {
        g_bDodgeActive[victim] = true;
        g_fDodgeEnd[victim] = now + DODGE_INVULN_DURATION;
        PrintHintText(victim, "<font color='#FF00FF'>>> DODGE <<</font>\n<font color='#FF80C0'>2.5s de invulnerabilidad</font>");
        damage = 0.0;
        return Plugin_Changed;
    }

    // PASIVA 2: Negar daño de entorno (caída, etc)
    if (damagetype & DMG_FALL || damagetype & DMG_CRUSH)
    {
        if (damage >= float(GetClientHealth(victim)))
        {
            damage = 0.0;
            g_bCinturaBuff[victim] = true;
            g_fCinturaBuffEnd[victim] = now + CINTURA_BUFF_DURATION;
            PrintHintText(victim, "<font color='#FF00FF'>>> TRAE ESA CINTURA PARA ACÁ <<</font>\n<font color='#FF80C0'>Los hilos de la Princesa niegan el daño. La muñequita no se rompe sola.</font>");
            return Plugin_Changed;
        }
    }

    // PASIVA 3: Reducción de daño (50% o 75% con cintura)
    float reduceMult = DOLL_DMG_REDUCE_BASE;
    if (g_bCinturaBuff[victim] && now < g_fCinturaBuffEnd[victim])
        reduceMult = DOLL_DMG_REDUCE_CINTURA;
    damage *= (1.0 - reduceMult);

    // PASIVA 10: Soy una Doll → dividir 50% del daño con Amy
    if (g_iDollAmyClient > 0 && IsClientInGame(g_iDollAmyClient) && IsPlayerAlive(g_iDollAmyClient) && !g_bAmyDead[g_iDollAmyClient])
    {
        float amyDmg = damage * 0.25;  // Amy recibe 25% del original
        damage *= 0.5;  // Sally recibe 50%
        SDKHooks_TakeDamage(g_iDollAmyClient, 0, 0, amyDmg, DMG_GENERIC);
    }

    return Plugin_Changed;
}

// PASIVA 5: Muñeca Princesa
bool Doll_IsPrincesaMode(int client)
{
    if (!g_bDollSally[client]) return false;
    if (!IsPlayerAlive(client)) return false;
    if (g_iDollAmyClient <= 0) return true;
    if (!IsClientInGame(g_iDollAmyClient)) return true;
    if (!IsPlayerAlive(g_iDollAmyClient)) return true;
    if (g_bAmyDead[g_iDollAmyClient]) return true;
    return false;
}

stock bool Doll_IsGrabImmune(int client)
{
    if (!g_bDollSally[client]) return false;
    if (g_bDodgeActive[client] && GetEngineTime() < g_fDodgeEnd[client]) return true;
    if (Doll_IsPrincesaMode(client)) return true;
    return false;
}

// PASIVA 7: Doll Control
Action Doll_CommandControl(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!g_bDollAmy[client]) return Plugin_Handled;
    if (!IsPlayerAlive(client)) return Plugin_Handled;
    if (g_iDollSallyClient <= 0 || !IsClientInGame(g_iDollSallyClient) || !IsPlayerAlive(g_iDollSallyClient))
    {
        PrintToChat(client, "\x04[Doll]\x01 Sally no está disponible.");
        return Plugin_Handled;
    }
    g_bDollControl[g_iDollSallyClient] = true;
    g_fDollControlEnd[g_iDollSallyClient] = GetEngineTime() + DOLL_CONTROL_DURATION;

    PrintToChat(client, "\x04[Doll]\x01 Controlando a Sally por \x045s\x01. Es invulnerable.");
    PrintToChat(g_iDollSallyClient, "\x04[Doll]\x01 Amy te está controlando. Eres invulnerable por 5s.");

    return Plugin_Handled;
}

// PASIVA 8: Menú de resize
Action Doll_CommandResize(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!g_bDollAmy[client]) return Plugin_Handled;
    if (g_iDollSallyClient <= 0 || !IsClientInGame(g_iDollSallyClient))
    {
        PrintToChat(client, "\x04[Doll]\x01 Sally no está disponible.");
        return Plugin_Handled;
    }
    Menu menu = new Menu(Doll_ResizeHandler);
    menu.SetTitle("Tamaño de Sally\n \n");
    menu.AddItem("0.5", "Pequeña (0.5x)");
    menu.AddItem("0.75", "Mediana (0.75x)");
    menu.AddItem("1.0", "Normal (1.0x)");
    menu.AddItem("1.25", "Grande (1.25x)");
    menu.AddItem("1.5", "Gigante (1.5x)");
    menu.Display(client, 15);
    return Plugin_Handled;
}

int Doll_ResizeHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_End: delete menu;
        case MenuAction_Select:
        {
            char info[16];
            menu.GetItem(param2, info, sizeof(info));
            float scale = StringToFloat(info);
            if (g_iDollSallyClient > 0 && IsClientInGame(g_iDollSallyClient))
            {
                SetEntPropFloat(g_iDollSallyClient, Prop_Send, "m_flModelScale", scale);
                PrintToChat(param1, "\x04[Doll]\x01 Tamaño de Sally: \x04%.2fx\x01", scale);
            }
        }
    }
    return 0;
}

// PASIVA 8: Detección de infectados especiales
void Doll_DetectSpecialInfected(int client)
{
    if (!g_bDollSally[client]) return;
    if (!IsPlayerAlive(client)) return;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;
        float sallyPos[3], infectedPos[3];
        GetClientAbsOrigin(client, sallyPos);
        GetClientAbsOrigin(i, infectedPos);
        float dist = GetVectorDistance(sallyPos, infectedPos);
        if (dist <= 500.0)
        {
            int zombieClass = GetEntProp(i, Prop_Send, "m_zombieClass");
            char className[32];
            switch (zombieClass)
            {
                case 1: strcopy(className, sizeof(className), "Smoker");
                case 2: strcopy(className, sizeof(className), "Boomer");
                case 3: strcopy(className, sizeof(className), "Hunter");
                case 4: strcopy(className, sizeof(className), "Spitter");
                case 5: strcopy(className, sizeof(className), "Jockey");
                case 6: strcopy(className, sizeof(className), "Charger");
                case 8: strcopy(className, sizeof(className), "Tank");
                default: strcopy(className, sizeof(className), "Infectado");
            }
            PrintHintText(client, "<font color='#FF80C0'>%s detectado a %.0fm</font>", className, dist / 50.0);
        }
    }
}

// PASIVA 9: Ghost mode durante dodge + PASIVA 11: Doble salto
void Doll_OnPlayerRunCmd(int client, int buttons = 0)
{
    if (!g_bDollSally[client]) return;
    if (!IsPlayerAlive(client)) return;
    float now = GetEngineTime();
    if (g_bDodgeActive[client] && now < g_fDodgeEnd[client])
    {
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 1);
    }
    else
    {
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
    }
    static float lastDetect[MAXPLAYERS + 1];
    if (now - lastDetect[client] >= 1.0)
    {
        Doll_DetectSpecialInfected(client);
        lastDetect[client] = now;
    }

    // PASIVA 11: Doble salto (si Amy cayó)
    if (buttons != 0)
    {
        Doll_HandleDoubleJump(client, buttons);
    }

    // PASIVA 6: Regeneración de alma
    Doll_AlmaRegenTick(client);
}

// ============================================================================
//  COMANDO DEBUG: sm_dolldebug
//  Muestra el estado completo del sistema Doll en consola.
//  Solo visible para la persona que lo ejecuta (no.broadcast).
// ============================================================================

Action Doll_CommandDebug(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    PrintToConsole(client, "");
    PrintToConsole(client, "========================================");
    PrintToConsole(client, "  SISTEMA DOLL — ESTADO ACTUAL");
    PrintToConsole(client, "========================================");
    PrintToConsole(client, "");

    // Estado de Amy
    PrintToConsole(client, "[AMY]");
    if (g_iDollAmyClient > 0 && IsClientInGame(g_iDollAmyClient))
    {
        int survivor = Doll_GetSurvCharSafe(g_iDollAmyClient);
        char survName[32];
        switch(survivor)
        {
            case 0: strcopy(survName, sizeof(survName), "Nick");
            case 1: strcopy(survName, sizeof(survName), "Rochelle");
            case 2: strcopy(survName, sizeof(survName), "Coach");
            case 3: strcopy(survName, sizeof(survName), "Ellis");
            case 4: strcopy(survName, sizeof(survName), "Bill");
            case 5: strcopy(survName, sizeof(survName), "Zoey");
            case 6: strcopy(survName, sizeof(survName), "Francis");
            case 7: strcopy(survName, sizeof(survName), "Louis");
            default: strcopy(survName, sizeof(survName), "Desconocido");
        }
        PrintToConsole(client, "  Conectada: SI (client %d, %N)", g_iDollAmyClient, g_iDollAmyClient);
        PrintToConsole(client, "  Survivor: %s (ID %d)", survName, survivor);
        PrintToConsole(client, "  Viva: %s", IsPlayerAlive(g_iDollAmyClient) ? "SI" : "NO");
        PrintToConsole(client, "  Skin correcta (Zoey): %s", survivor == 5 ? "SI" : "NO");
    }
    else
    {
        PrintToConsole(client, "  Conectada: NO");
    }
    PrintToConsole(client, "");

    // Estado de Sally
    PrintToConsole(client, "[SALLY]");
    if (g_iDollSallyClient > 0 && IsClientInGame(g_iDollSallyClient))
    {
        int survivor = Doll_GetSurvCharSafe(g_iDollSallyClient);
        char survName[32];
        switch(survivor)
        {
            case 0: strcopy(survName, sizeof(survName), "Nick");
            case 1: strcopy(survName, sizeof(survName), "Rochelle");
            case 2: strcopy(survName, sizeof(survName), "Coach");
            case 3: strcopy(survName, sizeof(survName), "Ellis");
            case 4: strcopy(survName, sizeof(survName), "Bill");
            case 5: strcopy(survName, sizeof(survName), "Zoey");
            case 6: strcopy(survName, sizeof(survName), "Francis");
            case 7: strcopy(survName, sizeof(survName), "Louis");
            default: strcopy(survName, sizeof(survName), "Desconocido");
        }
        PrintToConsole(client, "  Conectada: SI (client %d, %N)", g_iDollSallyClient, g_iDollSallyClient);
        PrintToConsole(client, "  Survivor: %s (ID %d)", survName, survivor);
        PrintToConsole(client, "  Viva: %s", IsPlayerAlive(g_iDollSallyClient) ? "SI" : "NO");
        PrintToConsole(client, "  Skin correcta (Rochelle): %s", survivor == 1 ? "SI" : "NO");

        // Estado de pasivas
        float now = GetEngineTime();
        PrintToConsole(client, "");
        PrintToConsole(client, "  [PASIVAS]");
        PrintToConsole(client, "    Doll Control: %s", (g_bDollControl[g_iDollSallyClient] && now < g_fDollControlEnd[g_iDollSallyClient]) ? "ACTIVO" : "inactivo");
        PrintToConsole(client, "    Dodge: %s", (g_bDodgeActive[g_iDollSallyClient] && now < g_fDodgeEnd[g_iDollSallyClient]) ? "ACTIVO" : "inactivo");
        PrintToConsole(client, "    Cintura Buff: %s", (g_bCinturaBuff[g_iDollSallyClient] && now < g_fCinturaBuffEnd[g_iDollSallyClient]) ? "ACTIVO (75%% reducción)" : "inactivo (50%% reducción base)");

        // Distancia
        if (g_iDollAmyClient > 0 && IsClientInGame(g_iDollAmyClient) && IsPlayerAlive(g_iDollSallyClient) && IsPlayerAlive(g_iDollAmyClient))
        {
            float sallyPos[3], amyPos[3];
            GetClientAbsOrigin(g_iDollSallyClient, sallyPos);
            GetClientAbsOrigin(g_iDollAmyClient, amyPos);
            float dist = GetVectorDistance(sallyPos, amyPos);
            PrintToConsole(client, "    Distancia a Amy: %.0f / %.0f (aviso a %.0f)", dist, CINTURA_MAX_DIST, CINTURA_WARN_DIST);
            if (dist >= CINTURA_MAX_DIST) PrintToConsole(client, "    ⚠ CINTURA ACTIVADA (demasiado lejos)");
            else if (dist >= CINTURA_WARN_DIST) PrintToConsole(client, "    ⚠ AVISO: acercándose al limite");
        }

        // Modo Princesa
        PrintToConsole(client, "    Muñeca Princesa: %s", Doll_IsPrincesaMode(g_iDollSallyClient) ? "ACTIVO" : "inactivo");
    }
    else
    {
        PrintToConsole(client, "  Conectada: NO");
    }
    PrintToConsole(client, "");

    // Resumen del sistema
    PrintToConsole(client, "[SISTEMA]");
    bool bothConnected = (g_iDollAmyClient > 0 && IsClientInGame(g_iDollAmyClient) && g_iDollSallyClient > 0 && IsClientInGame(g_iDollSallyClient));
    PrintToConsole(client, "  Ambas conectadas: %s", bothConnected ? "SI" : "NO");
    PrintToConsole(client, "  Sistema Doll: %s", bothConnected ? "ACTIVO" : "INACTIVO");
    PrintToConsole(client, "");
    PrintToConsole(client, "========================================");

    if (client > 0 && client <= MaxClients)
    {
        PrintToChat(client, "\x04[Doll]\x01 Estado del sistema enviado a la consola. (presiona ~ para ver)");
    }

    return Plugin_Handled;
}

// ============================================================================
//  PASIVA 4: NERVIOS DE ACERO
//  Si Amy murió y Sally cae incapacitada, se reincorpora automáticamente.
//  Máximo 3 revives por ronda.
//  Cada revive aumenta el daño de Sally a infectados:
//    Revive 1 → 2x daño
//    Revive 2 → 4.5x daño
//    Revive 3 → 7x daño
//  Temáticamente: la muñequita sin dueña se vuelve más peligrosa
//  cada vez que se levanta.
// ============================================================================

public void Doll_OnPlayerIncapacitated(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    if (victim <= 0 || victim > MaxClients || !g_bDollSally[victim]) return;
    if (!Doll_IsPrincesaMode(victim)) return;  // Solo si Amy cayó
    if (g_iNerviosReviveCount[victim] >= NERVIOS_MAX_REVIVES) return;

    // Esperar 1.5s antes de revive (dar tiempo al juego a procesar la incap)
    DataPack dp = new DataPack();
    dp.WriteCell(victim);
    CreateTimer(1.5, Doll_Timer_NerviosRevive, dp, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Doll_Timer_NerviosRevive(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    dp.Close();

    if (!g_bDollSally[client] || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (g_iNerviosReviveCount[client] >= NERVIOS_MAX_REVIVES) return Plugin_Stop;

    // Verificar que siga incapacitada
    if (!GetEntProp(client, Prop_Send, "m_isIncapacitated")) return Plugin_Stop;

    g_iNerviosReviveCount[client]++;

    // Aplicar multiplicador según el nivel de revive
    switch (g_iNerviosReviveCount[client])
    {
        case 1: g_fNerviosDmgMult[client] = NERVIOS_DMG_MULT_LV1;
        case 2: g_fNerviosDmgMult[client] = NERVIOS_DMG_MULT_LV2;
        case 3: g_fNerviosDmgMult[client] = NERVIOS_DMG_MULT_LV3;
    }

    // Reincorporar a Sally
    SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
    SetEntProp(client, Prop_Send, "m_isHangingFromLedge", 0);

    // Restaurar HP
    int newHp = GetClientHealth(client);
    if (newHp < 50) SetEntityHealth(client, 50);

    // Efecto visual + mensaje
    float pos[3];
    GetClientAbsOrigin(client, pos);
    TE_SetupBeamRingPoint(pos, 10.0, 200.0,
                          PrecacheModel("materials/sprites/laserbeam.vmt"),
                          PrecacheModel("materials/sprites/halo01.vmt"),
                          0, 0, 1.0, 3.0, 30.0, {255, 0, 128, 255}, 0, 0);
    TE_SendToClient(client);

    EmitSoundToClient(client, "ambient/energy/force_field_loop1.wav");

    PrintHintText(client, "<font color='#FF0000' size='24'>>> NERVIOS DE ACERO <<</font>\n<font color='#FF80C0'>Revive %d / %d — Daño a infectados x%.1f</font>",
                  g_iNerviosReviveCount[client], NERVIOS_MAX_REVIVES, g_fNerviosDmgMult[client]);

    return Plugin_Stop;
}

// Helper: aplicar multiplicador de daño a infectados
float Doll_GetNerviosDamageMult(int client)
{
    if (!g_bDollSally[client]) return 1.0;
    return g_fNerviosDmgMult[client];
}

// ============================================================================
//  PASIVA 6: CINTURA Y ALMA DOMINADA
//  Amy tiene control completo de su muñeca. Es un juguete para los
//  caprichos de Amy. Le otorga:
//    - Regeneración: 1 HP cada 4s (2s si Amy cayó)
//    - Inmunidad a daño de fuego (manejada en Doll_OnTakeDamage)
//    - Anti-Witch: si Sally está sola, instakill de Witch = nullificado
//    - Daño a Witch = 100x (instakill)
// ============================================================================

public void Doll_OnWitchSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int witch = event.GetInt("witchid");
    if (witch <= 0 || !IsValidEntity(witch)) return;

    // Hookear daño a la witch para multiplicar x100 si Sally la golpea
    SDKHook(witch, SDKHook_OnTakeDamage, Doll_OnWitchTakeDamage);
}

public Action Doll_OnWitchTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    // ¿Sally es la atacante?
    if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
    if (!g_bDollSally[attacker]) return Plugin_Continue;

    // Aplicar 100x daño (instakill)
    damage *= 100.0;
    return Plugin_Changed;
}

// PASIVA 4: Multiplicador de daño de Sally a infectados
// Se hookea en los SI cuando spawnean para aplicar el multiplicador
public Action Doll_OnSIDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    // ¿Sally es la atacante?
    if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
    if (!g_bDollSally[attacker]) return Plugin_Continue;

    // Aplicar multiplicador de Nervios de Acero si Amy cayó
    if (!Doll_IsPrincesaMode(attacker)) return Plugin_Continue;

    float mult = Doll_GetNerviosDamageMult(attacker);
    if (mult > 1.0)
    {
        damage *= mult;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

// Llamar desde Doll_PreThink para regen pasivo
void Doll_AlmaRegenTick(int client)
{
    if (!g_bDollSally[client]) return;
    if (!IsPlayerAlive(client)) return;

    float now = GetEngineTime();
    float interval = ALMA_REGEN_INTERVAL;
    if (Doll_IsPrincesaMode(client)) interval = ALMA_REGEN_INTERVAL_DEAD;

    if (now - g_fAlmaLastRegen[client] < interval) return;

    int hp = GetClientHealth(client);
    int maxHp = GetEntProp(client, Prop_Send, "m_iMaxHealth");
    if (hp < maxHp)
    {
        SetEntityHealth(client, hp + 1);
    }
    g_fAlmaLastRegen[client] = now;
}

// ============================================================================
//  PASIVA 11: UNA MUÑECA CONSENTIDA EN EL MUNDO
//  Si Amy cayó, Sally puede alterar las reglas y ejecutar el doble salto
//  de Amy. Refuerza la idea de que cuando Amy no está, Sally absorbe
//  parte de su poder.
// ============================================================================

// Llamar desde Doll_OnPlayerRunCmd cuando se presione IN_JUMP en el aire
void Doll_HandleDoubleJump(int client, int buttons)
{
    if (!g_bDollSally[client]) return;
    if (!IsPlayerAlive(client)) return;
    if (!Doll_IsPrincesaMode(client)) return;  // Solo si Amy cayó

    // Detectar si está en el agua o en el suelo
    int waterLevel = GetEntProp(client, Prop_Data, "m_nWaterLevel");
    bool onGround = (GetEntityFlags(client) & FL_ONGROUND) != 0;

    if (onGround || waterLevel >= 2)
    {
        // Reset: en el suelo, puede volver a hacer doble salto
        g_bDollJumped[client] = false;
        g_iDollJumpCount[client] = 0;
        return;
    }

    // Si presiona salto en el aire y no ha hecho el doble salto
    if ((buttons & IN_JUMP) && !g_bDollJumped[client])
    {
        g_bDollJumped[client] = true;
        g_iDollJumpCount[client]++;

        // Aplicar impulso vertical (doble salto)
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[2] = DOLL_DOUBLEJUMP_FORCE;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

        // Efecto visual breve (solo Sally lo ve)
        PrintHintText(client, "<font color='#FF80C0'>>> DOBLE SALTO DE AMY <<</font>");
        EmitSoundToClient(client, "ambient/energy/zap1.wav");
    }
}

// ============================================================================
//  DETECCIÓN DE AGARRES — ¿Sally está siendo agarrada por un SI?
//  Returns: true si está bajo efecto de Hunter/Smoker/Charger/Jockey
// ============================================================================
bool Doll_IsBeingGrappled(int client)
{
    if (!IsPlayerAlive(client)) return false;

    // Hunter pounce
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0)  return true;
    // Smoker tongue
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner")   > 0)  return true;
    // Charger pummel
    if (GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0)  return true;
    // Charger carry
    if (GetEntPropEnt(client, Prop_Send, "m_carryAttacker")  > 0)  return true;
    // Jockey ride
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0)  return true;

    return false;
}

// ============================================================================
//  LIBERACIÓN DE AGARRES — "TRAE ESA CINTURA PARA ACÁ"
//
//  Los hilos de la Princesa cortan cualquier agarre de Special Infected
//  antes de teleportar a Sally. Temáticamente: la muñequita es jalada
//  con tanta fuerza que ningún Hunter/Smoker/Charger/Jockey puede
//  sostenerla.
//
//  Esto evita el caso frustrante donde Sally se teletransporta al lado
//  de Amy mientras sigue being pounced/smoked/charged/rode.
//
//  v48: delega en Pin_Release.inc. La versión antigua solo ponía los
//  enlaces a -1 y aturdia al SI con MOVETYPE_NONE + un timer que
//  restauraba por ÍNDICE crudo (si el SI moria/desconectaba durante el
//  stun, el restauraba el movetype del PRÓXIMO ocupante del slot).
//  Además el motor nunca corria su camino de "fin de agarre", así que
//  la música de agarre le seguida sonando a la victima en loop (bug
//  reportado: "hunter/jockey/smoker liberados y la música sigue").
//  PinRelease_Cleanse (v2.0): liberación por el CAMINO DEL MOTOR
//  (L4D_Hunter_ReleaseVictim, L4D2_Jockey_EndRide, etc) + música
//  cortada (L4D_StopMusic) + atacante aturdido con stagger seguro
//  (SIStagger_Auto, se levanta garantizado). Sin escrituras crudas
//  de enlaces: las versiones que cortaban con -1 crasheaban el
//  engine cuando el infectado quedaba con su estado interno roto.
// ============================================================================
void Doll_FreeFromGrapples(int client)
{
    PinRelease_Cleanse(client);
}

// (v48: Doll_IsValidSI fue eliminado: su único consumidor era el viejo
// Doll_StunSI, reemplazado por el stagger seguro de Pin_Release.)

// ============================================================================
//  EFECTO VISUAL: Hilo de Marioneta
//  Dibuja un beam rosa brillante desde Amy (la Princesa) hasta la cintura
//  de Sally (la muñequita). Refuerza visualmente la pasiva
//  "TRAE ESA CINTURA PARA ACÁ".
//
//  IMPORTANTE: Solo Amy y Sally ven este efecto. Ningún otro jugador
//  del servidor debe enterarse de la dinámica muñequita-princesa.
// ============================================================================
void Doll_DrawPuppetThread(float startPos[3], float endPos[3])
{
    // Construir lista de clientes que verán el efecto (solo Amy + Sally)
    int viewers[2];
    int numViewers = 0;

    if (g_iDollSallyClient > 0 && IsClientInGame(g_iDollSallyClient) && !IsFakeClient(g_iDollSallyClient))
    {
        viewers[numViewers++] = g_iDollSallyClient;
    }
    if (g_iDollAmyClient > 0 && IsClientInGame(g_iDollAmyClient) && !IsFakeClient(g_iDollAmyClient))
    {
        viewers[numViewers++] = g_iDollAmyClient;
    }

    if (numViewers == 0) return; // nadie válido para ver el efecto

    // Elevar startPos un poco (pecho/manos de Amy, como si el hilo saliera de ella)
    startPos[2] += 40.0;

    int color[4] = {255, 64, 192, 230};   // Rosa Princesa (#FF40C0)

    int beamModel = PrecacheModel("materials/sprites/laserbeam.vmt");
    int haloModel = PrecacheModel("materials/sprites/halo01.vmt");

    // Beam de corta duración que simula el jalón del hilo
    TE_SetupBeamPoints(startPos, endPos, beamModel, haloModel,
                       0, 0, 0.6,       // startFrame, frameRate, life
                       2.0, 2.0,        // startWidth, endWidth
                       0, 0.0,          // fadeLength, amplitude
                       color, 0);
    TE_Send(viewers, numViewers);   // SOLO Amy + Sally

    // Pulso extra en la cintura de Sally (efecto "agarre")
    // Signature: TE_SetupBeamRingPoint(center[3], startRadius, endRadius,
    //                                   ModelIndex, HaloIndex, StartFrame, FrameRate,
    //                                   Life, Width, Amplitude, Color[4], Speed, Flags)
    TE_SetupBeamRingPoint(endPos,
                          1.5,       // startRadius (float) - radio inicial del anillo
                          30.0,      // endRadius   (float) - radio final del anillo
                          beamModel, // ModelIndex  (int)
                          haloModel, // HaloIndex   (int)
                          0,         // StartFrame  (int)
                          0,         // FrameRate   (int)
                          0.4,       // Life        (float)
                          2.0,       // Width       (float)
                          0.0,       // Amplitude   (float)
                          color,     // Color[4]    (int[4])
                          0,         // Speed       (int)
                          0);        // Flags       (int)
    TE_Send(viewers, numViewers);   // SOLO Amy + Sally
}
