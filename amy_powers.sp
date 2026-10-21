/*
 * ============================================================================
 *  amy_powers.sp  —  Amy Powers + Super Tank Control
 * ============================================================================
 *
 *  Plugin unificado que:
 *    1. Activa/desactiva el Super Tank mod (persiste en config)
 *    2. Da a Amy acceso a las habilidades del Super Tank via VScript bridge
 *    3. FILTRO ANTI-FRIENDLY FIRE: si Amy (survivor) usa una habilidad,
 *       los survivors NO reciben daño de esa habilidad
 *
 *  REQUIERE: Super Tank mod cargado en el servidor (VScript)
 *
 *  ARQUITECTURA:
 *    SMX (este plugin) = cerebro + control del Super Tank
 *    VScript (Super Tank original) = músculo (ejecuta las habilidades)
 *
 *  COMANDOS:
 *    sm_supertank <on|off|status>    Activa/desactiva/consulta el Super Tank
 *    sm_amy_tz [target]              Thunder Zap (rayo chain)
 *    sm_amy_meteor [target]          Meteor Storm
 *    sm_amy_fire [target]            Hellfire Pillar
 *    sm_amy_orbital [target]         Orbital Strike
 *    sm_amy_megumin [target]         Megumin Explosion
 *    sm_amy_electro [target]         Electrocute
 *    sm_amy_blackhole [target]       Black Hole (atrae infectados)
 *    sm_amy_explosive [target]       Explosive Detonate
 *    sm_amy_hellspot [target]        Hellfire Spot (zona de fuego)
 *    sm_amy_powers_help              Lista de comandos
 *
 *  CONFIGURACIÓN:
 *    El estado del Super Tank (on/off) se guarda en:
 *    addons/sourcemod/data/amy_supertank_status.txt
 *
 *  FILOSOFÍA:
 *    - Super Tank ON  → Tanks tienen poderes + Amy puede usar habilidades
 *    - Super Tank OFF → Tanks normales (sin poderes) + Amy NO puede usar habilidades
 *    - El filtro anti-FF siempre está activo: Amy nunca daña a otros survivors
 * ============================================================================
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION  "1.0"
#define PLUGIN_PREFIX   "\x04[Amy]\x01"

#define TEAM_SURVIVOR   2
#define TEAM_INFECTED   3

// Cooldowns por habilidad (segundos)
#define CD_THUNDERZAP   3.0
#define CD_METEOR       30.0
#define CD_FIRE         10.0
#define CD_ORBITAL      60.0
#define CD_MEGUMIN      90.0
#define CD_ELECTRO      8.0
#define CD_BLACKHOLE    20.0
#define CD_EXPLOSIVE    15.0
#define CD_HELLSPOT     12.0
#define CD_FIREGROUND   15.0
#define CD_FLAMEWAVE    20.0
#define CD_FIRERAIN     25.0
#define CD_FLAMESPIN    20.0
#define CD_STORM        45.0
#define CD_ELECTROFIELD 15.0
#define CD_QUAKE        30.0
#define CD_VOMIT        15.0
#define CD_ACID         20.0
#define CD_FREEZE       25.0
#define CD_MEGUMINS     60.0
#define CD_EXPATH       18.0
#define CD_MINES        20.0
#define CD_SUN          40.0
#define CD_REFLECT      30.0
#define CD_ACIDAREA     18.0
#define CD_HYDRO        22.0
#define CD_SWORDS       35.0
#define CD_CLOAK        25.0
#define CD_LASER        30.0
#define CD_DEATHCURSE   50.0
#define CD_LIGHTNINGZAP 5.0
#define CD_ELECTRICMINE 10.0
#define CD_SINGULARITY  25.0
#define CD_DEATHBH      35.0
#define CD_SWIFT        8.0
#define CD_HYPERDRIVE   12.0
#define CD_SHIFT        10.0
#define CD_TELEPORT     15.0
#define CD_FOG          18.0
#define CD_INFECTAREA   20.0
#define CD_EXDETOVL     20.0
#define CD_EXDETONATOR  15.0
#define CD_RUPTURE      25.0
#define CD_DISRUPTION   25.0
#define CD_METEORRAIN   25.0
#define CD_DISARM       20.0
#define CD_REFLECTOVL   35.0
#define CD_IMMORTAL     40.0
#define CD_NIRVANA      45.0
#define CD_BURNACID     18.0
#define CD_FREEZEVL     28.0
#define CD_EFIELD       18.0
#define CD_DEATHHOLE    35.0
#define CD_STORMCURR    30.0
#define CD_SWORDGUARD   35.0
#define CD_DEATHVAIL    40.0

// Sword Guardian - daño personalizado
#define SWORD_BASE_DMG      35.0
#define SWORD_WITCH_MULT    3.0
#define SWORD_COMMON_MULT   3.0
#define SWORD_RADIUS        54.0
#define SWORD_INTERVAL      0.3
#define SWORD_DURATION      10.0
Handle g_hSwordDamageTimer[MAXPLAYERS + 1];

#define MAX_ABILITIES   56
#define CD_RANDOM       15.0

float g_fLastUse[MAXPLAYERS + 1][MAX_ABILITIES];

// ============================================================
//  SISTEMA DE HABILIDAD ALEATORIA
//  sm_amy_random ejecuta una habilidad aleatoria del pool.
//  Muestra cooldown en pantalla y anuncia la próxima habilidad.
// ============================================================

// Pool de habilidades válidas (excluye regen/heal que solo sirven para Tanks)
#define RANDOM_POOL_SIZE 50

// Estructura: {funcionVScript, nombreParaMostrar, tomaLocation}
char g_sRandomFuncs[RANDOM_POOL_SIZE][64];
char g_sRandomNames[RANDOM_POOL_SIZE][32];
bool  g_bRandomTakesLoc[RANDOM_POOL_SIZE];
bool  g_bRandomSelfCast[RANDOM_POOL_SIZE];
int   g_iRandomPoolCount = 0;

int   g_iNextRandomAbility[MAXPLAYERS + 1];    // Índice de la próxima habilidad
float g_fRandomLastUse[MAXPLAYERS + 1];
Handle g_hRandomCDTimer[MAXPLAYERS + 1];        // Timer para mostrar cooldown en pantalla

// Estado del Super Tank (cargado desde archivo)
bool g_bSuperTankEnabled = true;
bool g_bSuperTankLoaded = false;    // ¿El Super Tank mod está cargado en el servidor?

// Categorías de habilidades:
// 0 = location-based (pasan Vector)
// 1 = target-entity (crean info_target en posición del objetivo)
// 2 = self-cast (necesitan el player entity de Amy que se mueve)
enum eCastType {
    CAST_LOCATION = 0,
    CAST_TARGET,
    CAST_SELF
};

// Trackeo de habilidades activas para el filtro anti-FF
bool g_bAmyAbilityActive = false;
int  g_iAmyAbilityAttacker = 0;
float g_fAmyAbilityEndTime = 0.0;

enum eAbility {
    AB_TZ = 0,
    AB_METEOR,
    AB_FIRE,
    AB_ORBITAL,
    AB_MEGUMIN,
    AB_ELECTRO,
    AB_BLACKHOLE,
    AB_EXPLOSIVE,
    AB_HELLSPOT,
    AB_FIREGROUND,
    AB_FLAMEWAVE,
    AB_FIRERAIN,
    AB_FLAMESPIN,
    AB_STORM,
    AB_ELECTROFIELD,
    AB_QUAKE,
    AB_VOMIT,
    AB_ACID,
    AB_FREEZE,
    AB_MEGUMINS,
    AB_EXPATH,
    AB_MINES,
    AB_SUN,
    AB_REFLECT,
    AB_ACIDAREA,
    AB_HYDRO,
    AB_SWORDS,
    AB_CLOAK,
    AB_LASER,
    AB_DEATHCURSE,
    AB_LIGHTNINGZAP,
    AB_ELECTRICMINE,
    AB_SINGULARITY,
    AB_DEATHBH,
    AB_SWIFT,
    AB_HYPERDRIVE,
    AB_SHIFT,
    AB_TELEPORT,
    AB_FOG,
    AB_INFECTAREA,
    AB_EXDETOVL,
    AB_EXDETONATOR,
    AB_RUPTURE,
    AB_DISRUPTION,
    AB_METEORRAIN,
    AB_DISARM,
    AB_REFLECTOVL,
    AB_IMMORTAL,
    AB_NIRVANA,
    AB_BURNACID,
    AB_FREEZEVL,
    AB_EFIELD,
    AB_DEATHHOLE,
    AB_STORMCURR,
    AB_SWORDGUARD,
    AB_DEATHVAIL
};

public Plugin myinfo = {
    name        = "Amy Powers + Super Tank Control",
    author      = "Amy",
    description = "Control del Super Tank + habilidades para Amy con filtro anti-FF",
    version     = PLUGIN_VERSION,
    url         = ""
};

public void OnPluginStart() {
    // Comando de control del Super Tank
    RegAdminCmd("sm_supertank", Cmd_SuperTankControl, ADMFLAG_ROOT, "sm_supertank <on|off|status> - Controla el Super Tank mod");

    // Comandos de habilidades de Amy (9 originales)
    RegConsoleCmd("sm_amy_tz",        Cmd_Ability, "Thunder Zap - Rayo chain (CD: 3s)");
    RegConsoleCmd("sm_amy_meteor",    Cmd_Ability, "Meteor Rain - Lluvia de meteoros (CD: 30s)");
    RegConsoleCmd("sm_amy_fire",      Cmd_Ability, "Hellfire Pillar (CD: 10s)");
    RegConsoleCmd("sm_amy_orbital",   Cmd_Ability, "Orbital Strike (CD: 60s)");
    RegConsoleCmd("sm_amy_megumin",   Cmd_Ability, "Megumin Explosion (CD: 90s)");
    RegConsoleCmd("sm_amy_electro",   Cmd_Ability, "Electrocute (CD: 8s)");
    RegConsoleCmd("sm_amy_blackhole", Cmd_Ability, "Black Hole (CD: 20s)");
    RegConsoleCmd("sm_amy_explosive", Cmd_Ability, "Explosive Detonate (CD: 15s)");
    RegConsoleCmd("sm_amy_hellspot",  Cmd_Ability, "Hellfire Spot (CD: 12s)");

    // 10 habilidades nuevas
    RegConsoleCmd("sm_amy_fireground",  Cmd_Ability, "Fire Ground - Fuego en el suelo (CD: 15s)");
    RegConsoleCmd("sm_amy_flamewave",   Cmd_Ability, "Flame Wave - Onda de fuego (CD: 20s)");
    RegConsoleCmd("sm_amy_firerain",    Cmd_Ability, "Fire Rains - Lluvia de fuego (CD: 25s)");
    RegConsoleCmd("sm_amy_flamespin",   Cmd_Ability, "Flame Spin - Torbellino de fuego (CD: 20s)");
    RegConsoleCmd("sm_amy_storm",       Cmd_Ability, "Thunder Storm - Tormenta electrica (CD: 45s)");
    RegConsoleCmd("sm_amy_efield",      Cmd_Ability, "Electric Field - Campo electrico (CD: 15s)");
    RegConsoleCmd("sm_amy_quake",       Cmd_Ability, "Earthquake - Terremoto (CD: 30s)");
    RegConsoleCmd("sm_amy_vomit",       Cmd_Ability, "Vomit Bomb - Multi bombas de vomito (CD: 15s)");
    RegConsoleCmd("sm_amy_acid",        Cmd_Ability, "Acid Path - Camino de acido (CD: 20s)");
    
    // 11 habilidades nuevas (20-30)
    RegConsoleCmd("sm_amy_megumins",    Cmd_Ability, "Megumin Explosions - Multiples explosiones (CD: 60s)");
    RegConsoleCmd("sm_amy_expath",      Cmd_Ability, "Explosive Path - Camino de explosiones (CD: 18s)");
    RegConsoleCmd("sm_amy_mines",       Cmd_Ability, "Electric Mine Field - Campo de minas (CD: 20s)");
    RegConsoleCmd("sm_amy_sun",         Cmd_Ability, "Praise The Sun - Rayo de luz solar (CD: 40s)");
    RegConsoleCmd("sm_amy_reflect",     Cmd_Ability, "Reflect Shield - Escudo reflector (CD: 30s)");
    RegConsoleCmd("sm_amy_acidarea",    Cmd_Ability, "Acid Area - Area de acido (CD: 18s)");
    RegConsoleCmd("sm_amy_hydro",       Cmd_Ability, "Hydro Bomb - Bomba de hielo (CD: 22s)");
    RegConsoleCmd("sm_amy_swords",      Cmd_Ability, "Sword Rain - Lluvia de espadas (CD: 35s)");
        RegConsoleCmd("sm_amy_laser",       Cmd_Ability, "Laser Defense - Defensa laser (CD: 30s)");
    RegConsoleCmd("sm_amy_deathcurse",  Cmd_Ability, "Death Curse - Maldicion de muerte (CD: 50s)");

    // 26 habilidades finales (31-56)
    RegConsoleCmd("sm_amy_lzap",        Cmd_Ability, "Lightning Zap - Rayo rapido (CD: 5s)");
    RegConsoleCmd("sm_amy_emine",       Cmd_Ability, "Electric Mine - Mina electrica (CD: 10s)");
    RegConsoleCmd("sm_amy_singularity", Cmd_Ability, "Singularity - Singularidad (CD: 25s)");
    RegConsoleCmd("sm_amy_deathbh",     Cmd_Ability, "Death Black Hole - Agujero negro de muerte (CD: 35s)");
    RegConsoleCmd("sm_amy_swift",       Cmd_Ability, "Swift Impact - Impacto rapido (CD: 8s)");
    RegConsoleCmd("sm_amy_hyperdrive",  Cmd_Ability, "Hyperdrive - Hiperpropulsion (CD: 12s)");
    RegConsoleCmd("sm_amy_shift",       Cmd_Ability, "Shift Toward - Desplazamiento (CD: 10s)");
    RegConsoleCmd("sm_amy_teleport",    Cmd_Ability, "Teleport - Teletransporte (CD: 15s)");
    RegConsoleCmd("sm_amy_fog",         Cmd_Ability, "Fog Effect - Niebla toxica (CD: 18s)");
    RegConsoleCmd("sm_amy_infectarea",  Cmd_Ability, "Infectious Area - Area infecciosa (CD: 20s)");
    RegConsoleCmd("sm_amy_exdetovl",    Cmd_Ability, "Explosive Detonate Ovl - Explosion potente (CD: 20s)");
    RegConsoleCmd("sm_amy_exdetonator", Cmd_Ability, "Explode Detonator - Detonador (CD: 15s)");
    RegConsoleCmd("sm_amy_rupture",     Cmd_Ability, "Rupture Effect - Ruptura (CD: 25s)");
    RegConsoleCmd("sm_amy_disruption",  Cmd_Ability, "Disruption World - Disrupcion (CD: 25s)");
    RegConsoleCmd("sm_amy_meteorrain",  Cmd_Ability, "Meteor Rain - Lluvia de meteoros (CD: 25s)");
    RegConsoleCmd("sm_amy_disarm",      Cmd_Ability, "Disarm Shield - Escudo desarmador (CD: 20s)");
    RegConsoleCmd("sm_amy_reflectovl",  Cmd_Ability, "Reflect Shield Ovl - Escudo reflector potente (CD: 35s)");
    RegConsoleCmd("sm_amy_immortal",    Cmd_Ability, "Immortality - Inmortalidad (CD: 40s)");
    RegConsoleCmd("sm_amy_nirvana",     Cmd_Ability, "Nirvana - Nirvana (CD: 45s)");
    RegConsoleCmd("sm_amy_burnacid",    Cmd_Ability, "Burning Acid - Acido ardiente (CD: 18s)");
        RegConsoleCmd("sm_amy_efield2",     Cmd_Ability, "Electric Field - Campo electrico (CD: 18s)");
    RegConsoleCmd("sm_amy_deathhole",   Cmd_Ability, "Death Hole - Agujero de muerte (CD: 35s)");
            RegConsoleCmd("sm_amy_deathvail",   Cmd_Ability, "Death Vail - Velo de muerte (CD: 40s)");
    RegConsoleCmd("sm_amy_swordguard",  Cmd_Ability, "Sword Guardian - Espadas orbitales (CD: 35s)");

    RegConsoleCmd("sm_amy_powers_help", Cmd_Help, "Lista de comandos de Amy Powers");

    // Habilidad aleatoria
    RegConsoleCmd("sm_amy_random", Cmd_RandomAbility, "Habilidad aleatoria del Super Tank (CD: 15s)");
    RegConsoleCmd("sm_amy_r",      Cmd_RandomAbility, "Habilidad aleatoria (alias corto)");

    // Inicializar pool de habilidades aleatorias
    InitRandomPool();

    // Hook de daño para filtro anti-FF
    HookEvent("player_hurt", OnPlayerHurt, EventHookMode_Pre);

    // Cargar estado guardado del Super Tank
    LoadSuperTankStatus();
}

public void OnMapStart() {
    // Verificar si el Super Tank está cargado (con un pequeño delay)
    CreateTimer(5.0, Timer_CheckSuperTank, _, TIMER_FLAG_NO_MAPCHANGE);

    // Aplicar el estado guardado después de que el Super Tank se cargue
    CreateTimer(8.0, Timer_ApplySuperTankStatus, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientDisconnect(int client) {
    g_iNextRandomAbility[client] = -1;
    g_fRandomLastUse[client] = 0.0;
    if (g_hRandomCDTimer[client] != null) {
        KillTimer(g_hRandomCDTimer[client]);
        g_hRandomCDTimer[client] = null;
    }
    if (g_hSwordDamageTimer[client] != null) {
        KillTimer(g_hSwordDamageTimer[client]);
        g_hSwordDamageTimer[client] = null;
    }
}

public void OnPluginEnd() {
    for (int i = 1; i <= MaxClients; i++) {
        if (g_hRandomCDTimer[i] != null) {
            KillTimer(g_hRandomCDTimer[i]);
            g_hRandomCDTimer[i] = null;
        }
        if (g_hSwordDamageTimer[i] != null) {
            KillTimer(g_hSwordDamageTimer[i]);
            g_hSwordDamageTimer[i] = null;
        }
    }
}

// ============================================================================
//  VERIFICACIÓN DEL SUPER TANK
// ============================================================================

Action Timer_CheckSuperTank(Handle timer) {
    g_bSuperTankLoaded = IsSuperTankLoaded();

    if (g_bSuperTankLoaded) {
        LogMessage("[Amy] Super Tank mod DETECTADO en el servidor.");
    } else {
        LogMessage("[Amy] Super Tank mod NO detectado. Las habilidades no funcionaran.");
    }

    return Plugin_Stop;
}

// Verifica si el Super Tank está cargado buscando su flag global
bool IsSuperTankLoaded() {
    int runner = FindOrCreateScriptRunner();
    if (runner == -1) return false;

    // Verificar la flag SuperTankScript del Super Tank
    char code[256];
    Format(code, sizeof(code),
        "if ('SuperTankScript' in getroottable() && SuperTankScript) { ClientPrint(null, 5, '[Amy] Super Tank DETECTADO'); } else { ClientPrint(null, 5, '[Amy] Super Tank NO detectado'); }");

    SetVariantString(code);
    return AcceptEntityInput(runner, "RunScriptCode");
}

// ============================================================================
//  CONTROL DEL SUPER TANK (on/off)
// ============================================================================

Action Timer_ApplySuperTankStatus(Handle timer) {
    ApplySuperTankStatus();
    return Plugin_Stop;
}

void ApplySuperTankStatus() {
    if (!g_bSuperTankLoaded) return;

    int runner = FindOrCreateScriptRunner();
    if (runner == -1) return;

    // Setear TankSettingOption.Disable_All_Powers según el estado guardado
    char code[128];
    if (g_bSuperTankEnabled) {
        Format(code, sizeof(code), "TankSettingOption.Disable_All_Powers <- 0");
        LogMessage("[Amy] Super Tank ACTIVADO (Tanks tienen poderes).");
    } else {
        Format(code, sizeof(code), "TankSettingOption.Disable_All_Powers <- 1");
        LogMessage("[Amy] Super Tank DESACTIVADO (Tanks sin poderes).");
    }

    SetVariantString(code);
    AcceptEntityInput(runner, "RunScriptCode");
}

Action Cmd_SuperTankControl(int client, int args) {
    if (args < 1) {
        ReplyToCommand(client, "[Amy] Uso: sm_supertank <on|off|status>");
        ReplyToCommand(client, "[Amy] Estado actual: %s", g_bSuperTankEnabled ? "ACTIVADO" : "DESACTIVADO");
        ReplyToCommand(client, "[Amy] Super Tank mod cargado: %s", g_bSuperTankLoaded ? "SI" : "NO");
        return Plugin_Handled;
    }

    char arg[16];
    GetCmdArg(1, arg, sizeof(arg));

    if (StrEqual(arg, "on", false)) {
        g_bSuperTankEnabled = true;
        SaveSuperTankStatus();
        ApplySuperTankStatus();
        ReplyToCommand(client, "[Amy] Super Tank ACTIVADO. Los Tanks tendran poderes.");
        PrintToChatAll("%s Super Tank \x04ACTIVADO\x01 por el admin.", PLUGIN_PREFIX);
    }
    else if (StrEqual(arg, "off", false)) {
        g_bSuperTankEnabled = false;
        SaveSuperTankStatus();
        ApplySuperTankStatus();
        ReplyToCommand(client, "[Amy] Super Tank DESACTIVADO. Los Tanks seran normales.");
        PrintToChatAll("%s Super Tank \x04DESACTIVADO\x01 por el admin. Amy puede usar sus habilidades.", PLUGIN_PREFIX);
    }
    else if (StrEqual(arg, "status", false)) {
        ReplyToCommand(client, "[Amy] === Estado del Super Tank ===");
        ReplyToCommand(client, "[Amy] Mod cargado: %s", g_bSuperTankLoaded ? "SI" : "NO");
        ReplyToCommand(client, "[Amy] Poderes activos: %s", g_bSuperTankEnabled ? "SI" : "NO");
    }
    else {
        ReplyToCommand(client, "[Amy] Argumento invalido. Usa: on, off, o status");
    }

    return Plugin_Handled;
}

// ============================================================================
//  PERSISTENCIA DEL ESTADO
// ============================================================================

void LoadSuperTankStatus() {
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "data/amy_supertank_status.txt");

    if (!FileExists(path)) {
        g_bSuperTankEnabled = true;  // default: activado
        return;
    }

    KeyValues kv = new KeyValues("supertank");
    if (!kv.ImportFromFile(path)) {
        delete kv;
        g_bSuperTankEnabled = true;
        return;
    }

    g_bSuperTankEnabled = kv.GetNum("enabled", 1) != 0;
    delete kv;

    LogMessage("[Amy] Estado del Super Tank cargado: %s", g_bSuperTankEnabled ? "ACTIVADO" : "DESACTIVADO");
}

void SaveSuperTankStatus() {
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "data/amy_supertank_status.txt");

    KeyValues kv = new KeyValues("supertank");
    kv.SetNum("enabled", g_bSuperTankEnabled ? 1 : 0);
    kv.ExportToFile(path);
    delete kv;
}

// ============================================================================
//  COMANDO: HELP
// ============================================================================

Action Cmd_Help(int client, int args) {
    ReplyToCommand(client, "=== Amy Powers (30 habilidades) ===");
    ReplyToCommand(client, "Control: sm_supertank on/off/status");
    ReplyToCommand(client, "");
    ReplyToCommand(client, "Habilidades (target: aim/self/entityID, vacio=aim):");
    ReplyToCommand(client, "  sm_amy_tz [t]        Thunder Zap (%.0fs)    sm_amy_megumins [t]  Megumin Explosions (%.0fs)", CD_THUNDERZAP, CD_MEGUMINS);
    ReplyToCommand(client, "  sm_amy_meteor [t]    Meteor Rain (%.0fs)    sm_amy_expath [t]    Explosive Path (%.0fs)", CD_METEOR, CD_EXPATH);
    ReplyToCommand(client, "  sm_amy_fire [t]      Hellfire Pillar (%.0fs) sm_amy_mines [t]     Electric Mines (%.0fs)", CD_FIRE, CD_MINES);
    ReplyToCommand(client, "  sm_amy_orbital [t]   Orbital Strike (%.0fs) sm_amy_sun [t]       Praise The Sun (%.0fs)", CD_ORBITAL, CD_SUN);
    ReplyToCommand(client, "  sm_amy_megumin [t]   Megumin Explosion (%.0fs) sm_amy_reflect [t]  Reflect Shield (%.0fs)", CD_MEGUMIN, CD_REFLECT);
    ReplyToCommand(client, "  sm_amy_electro [t]   Electrocute (%.0fs)     sm_amy_acidarea [t] Acid Area (%.0fs)", CD_ELECTRO, CD_ACIDAREA);
    ReplyToCommand(client, "  sm_amy_blackhole [t] Black Hole (%.0fs)      sm_amy_hydro [t]    Hydro Bomb (%.0fs)", CD_BLACKHOLE, CD_HYDRO);
    ReplyToCommand(client, "  sm_amy_explosive [t] Explosive Detonate (%.0fs) sm_amy_swords [t] Sword Rain (%.0fs)", CD_EXPLOSIVE, CD_SWORDS);
    ReplyToCommand(client, "  sm_amy_hellspot [t]  Hellfire Spot (%.0fs)   sm_amy_cloak [t]    Flame Cloak (%.0fs)", CD_HELLSPOT, CD_CLOAK);
    ReplyToCommand(client, "  sm_amy_fireground [t] Fire Ground (%.0fs)   sm_amy_laser [t]    Laser Defense (%.0fs)", CD_FIREGROUND, CD_LASER);
    ReplyToCommand(client, "  sm_amy_flamewave [t] Flame Wave (%.0fs)     sm_amy_deathcurse [t] Death Curse (%.0fs)", CD_FLAMEWAVE, CD_DEATHCURSE);
    ReplyToCommand(client, "  sm_amy_firerain [t]  Fire Rains (%.0fs)", CD_FIRERAIN);
    ReplyToCommand(client, "  sm_amy_flamespin [t] Flame Spin (%.0fs)", CD_FLAMESPIN);
    ReplyToCommand(client, "  sm_amy_storm [t]     Thunder Storm (%.0fs)", CD_STORM);
    ReplyToCommand(client, "  sm_amy_efield [t]    Electric Field (%.0fs)", CD_ELECTROFIELD);
    ReplyToCommand(client, "  sm_amy_quake [t]     Earthquake (%.0fs)", CD_QUAKE);
    ReplyToCommand(client, "  sm_amy_vomit [t]     Vomit Bomb (%.0fs)", CD_VOMIT);
    ReplyToCommand(client, "  sm_amy_acid [t]      Acid Path (%.0fs)", CD_ACID);
    ReplyToCommand(client, "  sm_amy_freeze [t]    Freezing Aura (%.0fs)", CD_FREEZE);
    ReplyToCommand(client, "");
    ReplyToCommand(client, "Filtro anti-FF: las habilidades NO dañan a otros survivors.");
    return Plugin_Handled;
}

// ============================================================================
//  COMANDO: ABILITY (genérico para todas las habilidades)
// ============================================================================

Action Cmd_Ability(int client, int args) {
    if (!IsValidClient(client) || IsFakeClient(client)) {
        ReplyToCommand(client, "[Amy] Solo jugadores reales.");
        return Plugin_Handled;
    }

    if (GetClientTeam(client) != TEAM_SURVIVOR) {
        ReplyToCommand(client, "[Amy] Solo supervivientes pueden usar estas habilidades.");
        return Plugin_Handled;
    }

    if (!IsPlayerAlive(client)) {
        ReplyToCommand(client, "[Amy] Debes estar vivo.");
        return Plugin_Handled;
    }

    // Verificar que el Super Tank esté cargado
    if (!g_bSuperTankLoaded) {
        PrintToChat(client, "%s El Super Tank mod no esta cargado. Habilidades no disponibles.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }

    // Obtener nombre del comando
    char cmdName[64];
    GetCmdArg(0, cmdName, sizeof(cmdName));

    // Mapear comando a función VScript + cooldown + nombre
    char vscriptFunc[64];
    float cooldown;
    eAbility abilityId;
    char abilityName[32];
    eCastType castType = CAST_TARGET;

    if (StrEqual(cmdName, "sm_amy_tz")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ThunderZap");
        cooldown = CD_THUNDERZAP;
        abilityId = AB_TZ;
        strcopy(abilityName, sizeof(abilityName), "Thunder Zap");
    }
    else if (StrEqual(cmdName, "sm_amy_meteor")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "SpawnMeteorsRain");
        cooldown = CD_METEOR;
        abilityId = AB_METEOR;
        strcopy(abilityName, sizeof(abilityName), "Meteor Rain");
        castType = CAST_LOCATION;
    }
    else if (StrEqual(cmdName, "sm_amy_fire")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "HellfirePillar");
        cooldown = CD_FIRE;
        abilityId = AB_FIRE;
        strcopy(abilityName, sizeof(abilityName), "Hellfire Pillar");
    }
    else if (StrEqual(cmdName, "sm_amy_orbital")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "OrbitalStrike");
        cooldown = CD_ORBITAL;
        abilityId = AB_ORBITAL;
        strcopy(abilityName, sizeof(abilityName), "Orbital Strike");
        castType = CAST_LOCATION;
    }
    else if (StrEqual(cmdName, "sm_amy_megumin")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "MeguminExplosion");
        cooldown = CD_MEGUMIN;
        abilityId = AB_MEGUMIN;
        strcopy(abilityName, sizeof(abilityName), "Megumin Explosion");
    }
    else if (StrEqual(cmdName, "sm_amy_electro")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "Electrocute");
        cooldown = CD_ELECTRO;
        abilityId = AB_ELECTRO;
        strcopy(abilityName, sizeof(abilityName), "Electrocute");
    }
    else if (StrEqual(cmdName, "sm_amy_blackhole")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ActivateBlackHole");
        cooldown = CD_BLACKHOLE;
        abilityId = AB_BLACKHOLE;
        strcopy(abilityName, sizeof(abilityName), "Black Hole");
    }
    else if (StrEqual(cmdName, "sm_amy_explosive")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ExplosiveDetonate");
        cooldown = CD_EXPLOSIVE;
        abilityId = AB_EXPLOSIVE;
        strcopy(abilityName, sizeof(abilityName), "Explosive Detonate");
        castType = CAST_LOCATION;
    }
    else if (StrEqual(cmdName, "sm_amy_hellspot")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "HellfireSpot");
        cooldown = CD_HELLSPOT;
        abilityId = AB_HELLSPOT;
        strcopy(abilityName, sizeof(abilityName), "Hellfire Spot");
        castType = CAST_LOCATION;
    }
    // === 10 HABILIDADES NUEVAS ===
    else if (StrEqual(cmdName, "sm_amy_fireground")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "FireGround");
        cooldown = CD_FIREGROUND;
        abilityId = AB_FIREGROUND;
        strcopy(abilityName, sizeof(abilityName), "Fire Ground");
    }
    else if (StrEqual(cmdName, "sm_amy_flamewave")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "HellFlameWave");
        cooldown = CD_FLAMEWAVE;
        abilityId = AB_FLAMEWAVE;
        strcopy(abilityName, sizeof(abilityName), "Flame Wave");
    }
    else if (StrEqual(cmdName, "sm_amy_firerain")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "FireRains");
        cooldown = CD_FIRERAIN;
        abilityId = AB_FIRERAIN;
        strcopy(abilityName, sizeof(abilityName), "Fire Rains");
    }
    else if (StrEqual(cmdName, "sm_amy_flamespin")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "FlameSpin");
        cooldown = CD_FLAMESPIN;
        abilityId = AB_FLAMESPIN;
        strcopy(abilityName, sizeof(abilityName), "Flame Spin");
    }
    else if (StrEqual(cmdName, "sm_amy_storm")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ThunderStorm");
        cooldown = CD_STORM;
        abilityId = AB_STORM;
        strcopy(abilityName, sizeof(abilityName), "Thunder Storm");
    }
    else if (StrEqual(cmdName, "sm_amy_efield")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ElectroField");
        cooldown = CD_ELECTROFIELD;
        abilityId = AB_ELECTROFIELD;
        strcopy(abilityName, sizeof(abilityName), "Electric Field");
        castType = CAST_LOCATION;
    }
    else if (StrEqual(cmdName, "sm_amy_quake")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "EarthquakeEffectInner");
        cooldown = CD_QUAKE;
        abilityId = AB_QUAKE;
        strcopy(abilityName, sizeof(abilityName), "Earthquake");
        castType = CAST_SELF;
    }
    else if (StrEqual(cmdName, "sm_amy_vomit")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "VomitOverlord");
        cooldown = CD_VOMIT;
        abilityId = AB_VOMIT;
        strcopy(abilityName, sizeof(abilityName), "Vomit Bomb");
    }
    else if (StrEqual(cmdName, "sm_amy_acid")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "AcidPath");
        cooldown = CD_ACID;
        abilityId = AB_ACID;
        strcopy(abilityName, sizeof(abilityName), "Acid Path");
    }
        cooldown = CD_FREEZE;
        abilityId = AB_FREEZE;
        strcopy(abilityName, sizeof(abilityName), "Freezing Aura");
    }
    // === 11 HABILIDADES NUEVAS (20-30) ===
    else if (StrEqual(cmdName, "sm_amy_megumins")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "MeguminExplosions");
        cooldown = CD_MEGUMINS;
        abilityId = AB_MEGUMINS;
        strcopy(abilityName, sizeof(abilityName), "Megumin Explosions");
    }
    else if (StrEqual(cmdName, "sm_amy_expath")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ExplosivePath");
        cooldown = CD_EXPATH;
        abilityId = AB_EXPATH;
        strcopy(abilityName, sizeof(abilityName), "Explosive Path");
    }
    else if (StrEqual(cmdName, "sm_amy_mines")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ElectricMineField");
        cooldown = CD_MINES;
        abilityId = AB_MINES;
        strcopy(abilityName, sizeof(abilityName), "Electric Mine Field");
    }
    else if (StrEqual(cmdName, "sm_amy_sun")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "PraiseTheSUN");
        cooldown = CD_SUN;
        abilityId = AB_SUN;
        strcopy(abilityName, sizeof(abilityName), "Praise The Sun");
        castType = CAST_LOCATION;
    }
    else if (StrEqual(cmdName, "sm_amy_reflect")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ReflectShield");
        cooldown = CD_REFLECT;
        abilityId = AB_REFLECT;
        strcopy(abilityName, sizeof(abilityName), "Reflect Shield");
        castType = CAST_SELF;
    }
    else if (StrEqual(cmdName, "sm_amy_acidarea")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "AcidArea");
        cooldown = CD_ACIDAREA;
        abilityId = AB_ACIDAREA;
        strcopy(abilityName, sizeof(abilityName), "Acid Area");
    }
    else if (StrEqual(cmdName, "sm_amy_hydro")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "HydroBomb");
        cooldown = CD_HYDRO;
        abilityId = AB_HYDRO;
        strcopy(abilityName, sizeof(abilityName), "Hydro Bomb");
    }
    else if (StrEqual(cmdName, "sm_amy_swords")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "SwordRain");
        cooldown = CD_SWORDS;
        abilityId = AB_SWORDS;
        strcopy(abilityName, sizeof(abilityName), "Sword Rain");
        castType = CAST_LOCATION;
    }
        cooldown = CD_CLOAK;
        abilityId = AB_CLOAK;
        strcopy(abilityName, sizeof(abilityName), "Flame Cloak");
        castType = CAST_SELF;
    }
    else if (StrEqual(cmdName, "sm_amy_laser")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "LaserDefense");
        cooldown = CD_LASER;
        abilityId = AB_LASER;
        strcopy(abilityName, sizeof(abilityName), "Laser Defense");
    }
    else if (StrEqual(cmdName, "sm_amy_deathcurse")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "DeathCurse");
        cooldown = CD_DEATHCURSE;
        abilityId = AB_DEATHCURSE;
        strcopy(abilityName, sizeof(abilityName), "Death Curse");
    }
    // === 26 HABILIDADES FINALES (31-56) ===
    else if (StrEqual(cmdName, "sm_amy_lzap")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "LightningZap");
        cooldown = CD_LIGHTNINGZAP;
        abilityId = AB_LIGHTNINGZAP;
        strcopy(abilityName, sizeof(abilityName), "Lightning Zap");
    }
    else if (StrEqual(cmdName, "sm_amy_emine")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ElectricMine");
        cooldown = CD_ELECTRICMINE;
        abilityId = AB_ELECTRICMINE;
        strcopy(abilityName, sizeof(abilityName), "Electric Mine");
    }
    else if (StrEqual(cmdName, "sm_amy_singularity")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "SingularityEventHorizon");
        cooldown = CD_SINGULARITY;
        abilityId = AB_SINGULARITY;
        strcopy(abilityName, sizeof(abilityName), "Singularity");
    }
    else if (StrEqual(cmdName, "sm_amy_deathbh")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "DeathBlackHole");
        cooldown = CD_DEATHBH;
        abilityId = AB_DEATHBH;
        strcopy(abilityName, sizeof(abilityName), "Death Black Hole");
    }
    else if (StrEqual(cmdName, "sm_amy_swift")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "SwiftImpact");
        cooldown = CD_SWIFT;
        abilityId = AB_SWIFT;
        strcopy(abilityName, sizeof(abilityName), "Swift Impact");
        castType = CAST_SELF;
    }
    else if (StrEqual(cmdName, "sm_amy_hyperdrive")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "Hyperdrive");
        cooldown = CD_HYPERDRIVE;
        abilityId = AB_HYPERDRIVE;
        strcopy(abilityName, sizeof(abilityName), "Hyperdrive");
    }
    else if (StrEqual(cmdName, "sm_amy_shift")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ShiftToward");
        cooldown = CD_SHIFT;
        abilityId = AB_SHIFT;
        strcopy(abilityName, sizeof(abilityName), "Shift Toward");
    }
    else if (StrEqual(cmdName, "sm_amy_teleport")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "TeleportToSomeone");
        cooldown = CD_TELEPORT;
        abilityId = AB_TELEPORT;
        strcopy(abilityName, sizeof(abilityName), "Teleport");
    }
    else if (StrEqual(cmdName, "sm_amy_fog")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "FogEffect");
        cooldown = CD_FOG;
        abilityId = AB_FOG;
        strcopy(abilityName, sizeof(abilityName), "Fog Effect");
    }
    else if (StrEqual(cmdName, "sm_amy_infectarea")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "InfectiousArea");
        cooldown = CD_INFECTAREA;
        abilityId = AB_INFECTAREA;
        strcopy(abilityName, sizeof(abilityName), "Infectious Area");
    }
    else if (StrEqual(cmdName, "sm_amy_exdetovl")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ExplosiveDetonateOvl");
        cooldown = CD_EXDETOVL;
        abilityId = AB_EXDETOVL;
        strcopy(abilityName, sizeof(abilityName), "Explosive Detonate Ovl");
        castType = CAST_LOCATION;
    }
    else if (StrEqual(cmdName, "sm_amy_exdetonator")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ExplodeDetonator");
        cooldown = CD_EXDETONATOR;
        abilityId = AB_EXDETONATOR;
        strcopy(abilityName, sizeof(abilityName), "Explode Detonator");
    }
    else if (StrEqual(cmdName, "sm_amy_rupture")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "RuptureEffect");
        cooldown = CD_RUPTURE;
        abilityId = AB_RUPTURE;
        strcopy(abilityName, sizeof(abilityName), "Rupture Effect");
    }
    else if (StrEqual(cmdName, "sm_amy_disruption")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "DisruptionWorld");
        cooldown = CD_DISRUPTION;
        abilityId = AB_DISRUPTION;
        strcopy(abilityName, sizeof(abilityName), "Disruption World");
    }
    else if (StrEqual(cmdName, "sm_amy_meteorrain")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "MeteorRain");
        cooldown = CD_METEORRAIN;
        abilityId = AB_METEORRAIN;
        strcopy(abilityName, sizeof(abilityName), "Meteor Rain");
    }
    else if (StrEqual(cmdName, "sm_amy_disarm")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "DisarmShield");
        cooldown = CD_DISARM;
        abilityId = AB_DISARM;
        strcopy(abilityName, sizeof(abilityName), "Disarm Shield");
        castType = CAST_SELF;
    }
    else if (StrEqual(cmdName, "sm_amy_reflectovl")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ReflecShieldOvl");
        cooldown = CD_REFLECTOVL;
        abilityId = AB_REFLECTOVL;
        strcopy(abilityName, sizeof(abilityName), "Reflect Shield Ovl");
        castType = CAST_SELF;
    }
    else if (StrEqual(cmdName, "sm_amy_immortal")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "Immortality");
        cooldown = CD_IMMORTAL;
        abilityId = AB_IMMORTAL;
        strcopy(abilityName, sizeof(abilityName), "Immortality");
        castType = CAST_SELF;
    }
    else if (StrEqual(cmdName, "sm_amy_nirvana")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "Nirvana");
        cooldown = CD_NIRVANA;
        abilityId = AB_NIRVANA;
        strcopy(abilityName, sizeof(abilityName), "Nirvana");
        castType = CAST_SELF;
    }
    else if (StrEqual(cmdName, "sm_amy_burnacid")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "BurningAcid");
        cooldown = CD_BURNACID;
        abilityId = AB_BURNACID;
        strcopy(abilityName, sizeof(abilityName), "Burning Acid");
    }
        cooldown = CD_FREEZEVL;
        abilityId = AB_FREEZEVL;
        strcopy(abilityName, sizeof(abilityName), "Freezing Aura Ovl");
    }
    else if (StrEqual(cmdName, "sm_amy_efield2")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "ElectricField");
        cooldown = CD_EFIELD;
        abilityId = AB_EFIELD;
        strcopy(abilityName, sizeof(abilityName), "Electric Field");
    }
    else if (StrEqual(cmdName, "sm_amy_deathhole")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "DeathHole");
        cooldown = CD_DEATHHOLE;
        abilityId = AB_DEATHHOLE;
        strcopy(abilityName, sizeof(abilityName), "Death Hole");
    }
        cooldown = CD_STORMCURR;
        abilityId = AB_STORMCURR;
        strcopy(abilityName, sizeof(abilityName), "Storm Current");
        castType = CAST_SELF;
    }
        cooldown = CD_SWORDGUARD;
        abilityId = AB_SWORDGUARD;
        strcopy(abilityName, sizeof(abilityName), "Sword Guardian");
        castType = CAST_SELF;
    }
    else if (StrEqual(cmdName, "sm_amy_deathvail")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "DeathVail");
        cooldown = CD_DEATHVAIL;
        abilityId = AB_DEATHVAIL;
        strcopy(abilityName, sizeof(abilityName), "Death Vail");
    }
    else if (StrEqual(cmdName, "sm_amy_swordguard")) {
        strcopy(vscriptFunc, sizeof(vscriptFunc), "SwordGuardian");
        cooldown = CD_SWORDGUARD;
        abilityId = AB_SWORDGUARD;
        strcopy(abilityName, sizeof(abilityName), "Sword Guardian");
        castType = CAST_SELF;
    }
    else {
        ReplyToCommand(client, "[Amy] Comando no reconocido: %s", cmdName);
        return Plugin_Handled;
    }

    // Verificar cooldown
    float now = GetEngineTime();
    if (now - g_fLastUse[client][abilityId] < cooldown) {
        float remaining = cooldown - (now - g_fLastUse[client][abilityId]);
        PrintToChat(client, "%s \x03%s\x01 en cooldown: \x04%.1fs\x01 restantes.",
            PLUGIN_PREFIX, abilityName, remaining);
        return Plugin_Handled;
    }

    // Resolver target
    int targetEntity = -1;
    float targetPos[3];

    if (args < 1) {
        targetEntity = GetAimedEntity(client);
        if (targetEntity <= 0) {
            if (!GetAimedPosition(client, targetPos)) {
                PrintToChat(client, "%s No apuntas a ningun objetivo.", PLUGIN_PREFIX);
                return Plugin_Handled;
            }
        }
    } else {
        char arg[32];
        GetCmdArg(1, arg, sizeof(arg));

        if (StrEqual(arg, "aim", false)) {
            targetEntity = GetAimedEntity(client);
            if (targetEntity <= 0) {
                if (!GetAimedPosition(client, targetPos)) {
                    PrintToChat(client, "%s No apuntas a ningun objetivo.", PLUGIN_PREFIX);
                    return Plugin_Handled;
                }
            }
        } else if (StrEqual(arg, "self", false)) {
            targetEntity = client;
        } else {
            targetEntity = StringToInt(arg);
            if (targetEntity <= 0 || !IsValidEntity(targetEntity)) {
                PrintToChat(client, "%s Entidad invalida: %s", PLUGIN_PREFIX, arg);
                return Plugin_Handled;
            }
        }
    }

    // Obtener posición del target
    if (targetEntity > 0) {
        if (targetEntity <= MaxClients) {
            GetClientAbsOrigin(targetEntity, targetPos);
        } else {
            GetEntPropVector(targetEntity, Prop_Send, "m_vecOrigin", targetPos);
        }
    }

    // Registrar uso para cooldown
    g_fLastUse[client][abilityId] = now;

    // === ACTIVAR FILTRO ANTI-FF ===
    // El filtro bloquea daño a survivors mientras la habilidad esté activa.
    // Self-cast: 12 segundos (shields y espadas necesitan más tiempo)
    // Target/Location: 5 segundos (suficiente para explosiones)
    g_bAmyAbilityActive = true;
    g_iAmyAbilityAttacker = client;
    if (castType == CAST_SELF) {
        g_fAmyAbilityEndTime = now + 12.0;
    } else {
        g_fAmyAbilityEndTime = now + 5.0;
    }

    // === LLAMAR LA FUNCIÓN VSCRIPT DEL SUPER TANK ===
    // IMPORTANTE: VScript de L4D2 NO tiene Entities.GetByIndex().
    // La forma correcta es crear la entidad DENTRO de VScript y pasarla
    // directamente como variable local.
    //
    // Las funciones entity-based del Super Tank también requieren:
    //   2. Script scope validado (ValidateScriptScope)
    //   3. Flags específicas en el scope (ej: "DoomsdayTank" para MeteorStorm)
    char code[2048];
    if (castType == CAST_LOCATION) {
        // Location-based: pasar Vector directamente
        Format(code, sizeof(code),
            "%s(Vector(%f, %f, %f))",
            vscriptFunc, targetPos[0], targetPos[1], targetPos[2]);
    } else if (castType == CAST_SELF) {
        // Self-cast: encontrar el player entity de Amy en VScript y pasarlo.
        // Estas habilidades (shields, swords, etc.) necesitan un entity que se MUEVE,
        // no un info_target estático. Usamos el player de Amy.
        // SetParent en el player hace que los efectos sigan a Amy.
        Format(code, sizeof(code),
            "local p = null; local found = null; while(p = Entities.FindByClassname(p, \"player\")) { if(p.GetEntityIndex() == %d) { found = p; break; } } if(found != null) { found.ValidateScriptScope(); local s = found.GetScriptScope(); s.DoomsdayTank <- true; s.ThunderTank <- true; s.HellfireTank <- true; s.Hellflame <- true; s.SingularityTank <- true; s.blacklord <- true; s.CorruptedTank <- true; s.boomlord <- true; s.Lightning <- true; s.SwiftTank <- true; s.RuptureTank <- true; s.NukeTank <- true; s.InfectTank <- true; s.NoxiousTank <- true; s.HydroTank <- true; s.SamsaraTank <- true; s.TankLives <- 3; s.ImmTimer <- 10; s.MeteorCount <- 0; s.deathlord <- true; s.MeteorLord <- true; s.DisarmTank <- true; s.Shield <- true; s.shieldlord <- true; s.Reflecting <- true; s.Berserk <- true; s.TempestTank <- true; s.LegionTank <- true; s.ElementTank <- true; s.HungerTank <- true; s.ShiftTank <- true; s.flashtank <- true; s.EvericeTank <- true; s.ArcanaTank <- true; %s(found); }",
            client, vscriptFunc);
    } else {
        // Target-entity: crear info_target en la posición del objetivo
        Format(code, sizeof(code),
            "local e = SpawnEntityFromTable(\"info_target\", {origin = Vector(%f, %f, %f)}); e.ValidateScriptScope(); local s = e.GetScriptScope(); s.DoomsdayTank <- true; s.ThunderTank <- true; s.HellfireTank <- true; s.Hellflame <- true; s.SingularityTank <- true; s.blacklord <- true; s.CorruptedTank <- true; s.boomlord <- true; s.Lightning <- true; s.SwiftTank <- true; s.RuptureTank <- true; s.NukeTank <- true; s.InfectTank <- true; s.NoxiousTank <- true; s.HydroTank <- true; s.SamsaraTank <- true; s.TankLives <- 3; s.ImmTimer <- 10; s.MeteorCount <- 0; s.deathlord <- true; s.MeteorLord <- true; s.DisarmTank <- true; s.Shield <- true; s.shieldlord <- true; s.Reflecting <- true; s.Berserk <- true; s.TempestTank <- true; s.LegionTank <- true; s.ElementTank <- true; s.HungerTank <- true; s.ShiftTank <- true; s.flashtank <- true; s.EvericeTank <- true; s.ArcanaTank <- true; %s(e); DoEntFire(\"!self\", \"Kill\", \"\", 5.0, null, e);",
            targetPos[0], targetPos[1], targetPos[2],
            vscriptFunc);
    }

    int runner = FindOrCreateScriptRunner();
    if (runner == -1) {
        PrintToChat(client, "%s Error: no se encontro logic_script.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }

    SetVariantString(code);
    bool success = AcceptEntityInput(runner, "RunScriptCode");

    if (success) {
        PrintToChat(client, "%s \x03%s\x01 activado!", PLUGIN_PREFIX, abilityName);

        // Si es self-cast (shields, etc.), programar limpieza de props tras 10s
        // El Super Tank no limpia los shields porque espera que el Tank muera.
        // Amy no muere, así que nosotros los limpiamos.
        if (castType == CAST_SELF) {
            DataPack cleanPack = new DataPack();
            cleanPack.WriteCell(GetClientUserId(client));
            CreateTimer(10.0, Timer_CleanupSelfCast, cleanPack, TIMER_FLAG_NO_MAPCHANGE);

            // Si es SwordGuardian, iniciar timer de daño personalizado
            // Esto reemplaza el DamageInterval del Super Tank con nuestra lógica:
            // - Daño base 35 a especiales
            // - 3x daño a commons y witches
            // - Sinergia con Dash Verdugo (multiplicador según HP ratio)
            if (StrEqual(cmdName, "sm_amy_swordguard") || StrEqual(vscriptFunc, "SwordGuardian")) {
                if (g_hSwordDamageTimer[client] != null) {
                    KillTimer(g_hSwordDamageTimer[client]);
                }
                DataPack swordPack = new DataPack();
                swordPack.WriteCell(GetClientUserId(client));
                g_hSwordDamageTimer[client] = CreateTimer(SWORD_INTERVAL, Timer_SwordDamage, swordPack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
            }
        }
    } else {
        PrintToChat(client, "%s Error ejecutando %s.", PLUGIN_PREFIX, abilityName);
    }

    return Plugin_Handled;
}

// ============================================================================
//  FILTRO ANTI-FRIENDLY FIRE
// ============================================================================

// Hook de player_hurt para bloquear daño a survivors durante habilidades de Amy
void OnPlayerHurt(Event event, const char[] name, bool dontBroadcast) {
    if (!g_bAmyAbilityActive) return;

    float now = GetEngineTime();
    if (now > g_fAmyAbilityEndTime) {
        g_bAmyAbilityActive = false;
        return;
    }

    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    if (victim <= 0 || victim > MaxClients) return;
    if (!IsClientInGame(victim)) return;

    // Si la víctima es survivor Y la habilidad la activó un survivor (Amy)
    if (GetClientTeam(victim) == TEAM_SURVIVOR && g_iAmyAbilityAttacker > 0) {
        // Bloquear el daño: restaurar la salud del victim
        int dmg = event.GetInt("dmg_health");
        if (dmg > 0) {
            int currentHp = GetClientHealth(victim);
            int newHp = currentHp + dmg;
            int maxHp = GetEntProp(victim, Prop_Send, "m_iMaxHealth");
            if (newHp > maxHp) newHp = maxHp;
            SetEntityHealth(victim, newHp);

            // También restaurar health buffer si aplica
            int dmgBuffer = event.GetInt("dmg_health");
            if (dmgBuffer > 0) {
                float buffer = GetEntPropFloat(victim, Prop_Send, "m_healthBuffer");
                SetEntPropFloat(victim, Prop_Send, "m_healthBuffer", buffer + float(dmgBuffer));
            }
        }
    }
}

// ============================================================================
//  SISTEMA DE HABILIDAD ALEATORIA
// ============================================================================

// Inicializa el pool de habilidades aleatorias
// Excluye: RegenHP, HungerRegenHP, DrainHealth (solo curan al Tank, no útil para Amy)
void InitRandomPool() {
    g_iRandomPoolCount = 0;

    // Habilidades entity-based
    AddToRandomPool("ThunderZap", "Thunder Zap", false);
    AddToRandomPool("HellfirePillar", "Hellfire Pillar", false);
    AddToRandomPool("MeguminExplosion", "Megumin Explosion", false);
    AddToRandomPool("MeguminExplosions", "Megumin Explosions", false);
    AddToRandomPool("Electrocute", "Electrocute", false);
    AddToRandomPool("ActivateBlackHole", "Black Hole", false);
    AddToRandomPool("FireGround", "Fire Ground", false);
    AddToRandomPool("HellFlameWave", "Flame Wave", false);
    AddToRandomPool("FireRains", "Fire Rains", false);
    AddToRandomPool("FlameSpin", "Flame Spin", false);
    AddToRandomPool("ThunderStorm", "Thunder Storm", false);
    AddToRandomPool("EarthquakeEffectInner", "Earthquake", false, true);
    AddToRandomPool("VomitOverlord", "Vomit Bomb", false);
    AddToRandomPool("AcidPath", "Acid Path", false);
        AddToRandomPool("ElectricMineField", "Electric Mines", false);
    AddToRandomPool("ElectricMine", "Electric Mine", false);
    AddToRandomPool("LightningZap", "Lightning Zap", false);
    AddToRandomPool("SingularityEventHorizon", "Singularity", false);
    AddToRandomPool("DeathBlackHole", "Death Black Hole", false);
    AddToRandomPool("SwiftImpact", "Swift Impact", false, true);
    AddToRandomPool("Hyperdrive", "Hyperdrive", false);
    AddToRandomPool("ShiftToward", "Shift Toward", false);
    AddToRandomPool("FogEffect", "Fog Effect", false);
    AddToRandomPool("InfectiousArea", "Infectious Area", false);
    AddToRandomPool("ExplodeDetonator", "Explode Detonator", false);
    AddToRandomPool("ExplosivePath", "Explosive Path", false);
    AddToRandomPool("RuptureEffect", "Rupture Effect", false);
    AddToRandomPool("DisruptionWorld", "Disruption World", false);
        AddToRandomPool("DisarmShield", "Disarm Shield", false, true);
    AddToRandomPool("ReflecShieldOvl", "Reflect Shield Ovl", false, true);
            AddToRandomPool("BurningAcid", "Burning Acid", false);
        AddToRandomPool("ElectricField", "Electric Field", false);
    AddToRandomPool("DeathHole", "Death Hole", false);
            AddToRandomPool("DeathVail", "Death Vail", false);
    AddToRandomPool("DeathCurse", "Death Curse", false);
    AddToRandomPool("ReflectShield", "Reflect Shield", false, true);
    AddToRandomPool("AcidArea", "Acid Area", false);
    AddToRandomPool("HydroBomb", "Hydro Bomb", false);
        AddToRandomPool("LaserDefense", "Laser Defense", false);
    AddToRandomPool("TeleportToSomeone", "Teleport", false);
    AddToRandomPool("SwordGuardian", "Sword Guardian", false, true);

    // Habilidades location-based
    AddToRandomPool("SpawnMeteorsRain", "Meteor Rain", true);
    AddToRandomPool("OrbitalStrike", "Orbital Strike", true);
    AddToRandomPool("ExplosiveDetonate", "Explosive Detonate", true);
    AddToRandomPool("HellfireSpot", "Hellfire Spot", true);
    AddToRandomPool("ElectroField", "Electric Field", true);
    AddToRandomPool("PraiseTheSUN", "Praise The Sun", true);
    AddToRandomPool("SwordRain", "Sword Rain", true);
    AddToRandomPool("ExplosiveDetonateOvl", "Explosive Detonate Ovl", true);

    // Inicializar next ability para todos los jugadores
    for (int i = 1; i <= MaxClients; i++) {
        g_iNextRandomAbility[i] = -1;
        g_fRandomLastUse[i] = 0.0;
        g_hRandomCDTimer[i] = null;
    }

    PrintToServer("[Amy] Pool de habilidades aleatorias inicializado: %d habilidades", g_iRandomPoolCount);
}

void AddToRandomPool(const char[] funcName, const char[] displayName, bool isLocation, bool isSelfCast = false) {
    if (g_iRandomPoolCount >= RANDOM_POOL_SIZE) return;
    strcopy(g_sRandomFuncs[g_iRandomPoolCount], 64, funcName);
    strcopy(g_sRandomNames[g_iRandomPoolCount], 32, displayName);
    g_bRandomTakesLoc[g_iRandomPoolCount] = isLocation;
    g_bRandomSelfCast[g_iRandomPoolCount] = isSelfCast;
    g_iRandomPoolCount++;
}

Action Cmd_RandomAbility(int client, int args) {
    if (!IsValidClient(client) || IsFakeClient(client)) {
        ReplyToCommand(client, "[Amy] Solo jugadores reales.");
        return Plugin_Handled;
    }
    if (GetClientTeam(client) != TEAM_SURVIVOR) {
        ReplyToCommand(client, "[Amy] Solo supervivientes.");
        return Plugin_Handled;
    }
    if (!IsPlayerAlive(client)) {
        ReplyToCommand(client, "[Amy] Debes estar vivo.");
        return Plugin_Handled;
    }
    if (!g_bSuperTankLoaded) {
        PrintToChat(client, "%s Super Tank no cargado.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }
    if (g_iRandomPoolCount == 0) {
        PrintToChat(client, "%s Pool de habilidades vacio.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }

    // Verificar cooldown
    float now = GetEngineTime();
    if (now - g_fRandomLastUse[client] < CD_RANDOM) {
        float remaining = CD_RANDOM - (now - g_fRandomLastUse[client]);
        PrintToChat(client, "%s Habilidad aleatoria en cooldown: \x04%.1fs\x01", PLUGIN_PREFIX, remaining);
        return Plugin_Handled;
    }

    // Si no hay próxima habilidad seleccionada, elegir una aleatoria
    if (g_iNextRandomAbility[client] < 0 || g_iNextRandomAbility[client] >= g_iRandomPoolCount) {
        g_iNextRandomAbility[client] = GetRandomInt(0, g_iRandomPoolCount - 1);
    }

    int abilityIdx = g_iNextRandomAbility[client];
    char vscriptFunc[64];
    char abilityName[32];
    bool isLocation;
    bool isSelfCast;
    strcopy(vscriptFunc, sizeof(vscriptFunc), g_sRandomFuncs[abilityIdx]);
    strcopy(abilityName, sizeof(abilityName), g_sRandomNames[abilityIdx]);
    isLocation = g_bRandomTakesLoc[abilityIdx];
    isSelfCast = g_bRandomSelfCast[abilityIdx];

    // Resolver target
    int targetEntity = -1;
    float targetPos[3];

    if (!GetAimedPosition(client, targetPos)) {
        // Si no apunta a posición, usar su propia posición
        GetClientAbsOrigin(client, targetPos);
    }

    targetEntity = GetAimedEntity(client);
    if (targetEntity > 0) {
        if (targetEntity <= MaxClients) {
            GetClientAbsOrigin(targetEntity, targetPos);
        } else {
            GetEntPropVector(targetEntity, Prop_Send, "m_vecOrigin", targetPos);
        }
    }

    // Registrar uso
    g_fRandomLastUse[client] = now;

    // Activar filtro anti-FF
    g_bAmyAbilityActive = true;
    g_iAmyAbilityAttacker = client;
    g_fAmyAbilityEndTime = now + 5.0;

    // Ejecutar la habilidad
    char code[2048];
    if (isLocation) {
        Format(code, sizeof(code), "%s(Vector(%f, %f, %f))", vscriptFunc, targetPos[0], targetPos[1], targetPos[2]);
    } else if (isSelfCast) {
        Format(code, sizeof(code),
            "local p = null; local found = null; while(p = Entities.FindByClassname(p, \"player\")) { if(p.GetEntityIndex() == %d) { found = p; break; } } if(found != null) { found.ValidateScriptScope(); local s = found.GetScriptScope(); s.DoomsdayTank <- true; s.ThunderTank <- true; s.HellfireTank <- true; s.Hellflame <- true; s.SingularityTank <- true; s.blacklord <- true; s.CorruptedTank <- true; s.boomlord <- true; s.Lightning <- true; s.SwiftTank <- true; s.RuptureTank <- true; s.NukeTank <- true; s.InfectTank <- true; s.NoxiousTank <- true; s.HydroTank <- true; s.SamsaraTank <- true; s.TankLives <- 3; s.ImmTimer <- 10; s.MeteorCount <- 0; s.deathlord <- true; s.MeteorLord <- true; s.DisarmTank <- true; s.Shield <- true; s.shieldlord <- true; s.Reflecting <- true; s.Berserk <- true; s.TempestTank <- true; s.LegionTank <- true; s.ElementTank <- true; s.HungerTank <- true; s.ShiftTank <- true; s.flashtank <- true; s.EvericeTank <- true; s.ArcanaTank <- true; %s(found); }",
            client, vscriptFunc);
    } else {
        Format(code, sizeof(code),
            "local e = SpawnEntityFromTable(\"info_target\", {origin = Vector(%f, %f, %f)}); e.ValidateScriptScope(); local s = e.GetScriptScope(); s.DoomsdayTank <- true; s.ThunderTank <- true; s.HellfireTank <- true; s.Hellflame <- true; s.SingularityTank <- true; s.blacklord <- true; s.CorruptedTank <- true; s.boomlord <- true; s.Lightning <- true; s.SwiftTank <- true; s.RuptureTank <- true; s.NukeTank <- true; s.InfectTank <- true; s.NoxiousTank <- true; s.HydroTank <- true; s.SamsaraTank <- true; s.TankLives <- 3; s.ImmTimer <- 10; s.MeteorCount <- 0; s.deathlord <- true; s.MeteorLord <- true; s.DisarmTank <- true; s.Shield <- true; s.shieldlord <- true; s.Reflecting <- true; s.Berserk <- true; s.TempestTank <- true; s.LegionTank <- true; s.ElementTank <- true; s.HungerTank <- true; s.ShiftTank <- true; s.flashtank <- true; s.EvericeTank <- true; s.ArcanaTank <- true; %s(e); DoEntFire(\"!self\", \"Kill\", \"\", 5.0, null, e);",
            targetPos[0], targetPos[1], targetPos[2], vscriptFunc);
    }

    int runner = FindOrCreateScriptRunner();
    if (runner == -1) {
        PrintToChat(client, "%s Error: no se encontro logic_script.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }

    SetVariantString(code);
    bool success = AcceptEntityInput(runner, "RunScriptCode");

    if (success) {
        PrintToChat(client, "%s \x03%s\x01 activado!", PLUGIN_PREFIX, abilityName);
    } else {
        PrintToChat(client, "%s Error ejecutando %s.", PLUGIN_PREFIX, abilityName);
    }

    // Elegir la PRÓXIMA habilidad aleatoria y anunciarla
    int nextIdx = GetRandomInt(0, g_iRandomPoolCount - 1);
    g_iNextRandomAbility[client] = nextIdx;
    char nextName[32];
    strcopy(nextName, sizeof(nextName), g_sRandomNames[nextIdx]);
    PrintToChat(client, "%s Proxima habilidad: \x04%s\x01", PLUGIN_PREFIX, nextName);

    // Iniciar timer para mostrar cooldown en pantalla
    if (g_hRandomCDTimer[client] != null) {
        KillTimer(g_hRandomCDTimer[client]);
    }
    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    g_hRandomCDTimer[client] = CreateTimer(0.5, Timer_RandomCooldown, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Handled;
}

// Timer que muestra el cooldown restante en pantalla
Action Timer_RandomCooldown(Handle timer, DataPack pack) {
    pack.Reset();
    int userId = pack.ReadCell();

    int client = GetClientOfUserId(userId);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) {
        g_hRandomCDTimer[client] = null;
        delete pack;
        return Plugin_Stop;
    }

    float now = GetEngineTime();
    float remaining = CD_RANDOM - (now - g_fRandomLastUse[client]);

    if (remaining <= 0.0) {
        // Cooldown terminado
        char nextName[32];
        strcopy(nextName, sizeof(nextName), g_sRandomNames[g_iNextRandomAbility[client]]);
        PrintHintText(client, "<font color='#FF00FF' size='20'>>> HABILIDAD LISTA <<</font>\n<font color='#FF80C0'>Proxima: %s</font>\n<font color='#00FF00'>Usa sm_amy_r</font>", nextName);
        g_hRandomCDTimer[client] = null;
        delete pack;
        return Plugin_Stop;
    }

    // Mostrar cooldown restante
    char nextName[32];
    strcopy(nextName, sizeof(nextName), g_sRandomNames[g_iNextRandomAbility[client]]);
    PrintHintText(client, "<font color='#FF00FF' size='18'>Habilidad Aleatoria</font>\n<font color='#FFFFFF'>Enfriamiento: %.1fs</font>\n<font color='#FF80C0'>Proxima: %s</font>", remaining, nextName);

    // Reset pack para el siguiente tick
    pack.Reset();
    pack.WriteCell(userId);

    return Plugin_Continue;
}

// ============================================================================
//  LIMPIEZA DE SHIELDS Y SELF-CAST
// ============================================================================

// Timer que limpia props de shields y efectos self-cast tras 10 segundos.
// El Super Tank no limpia estos props porque espera que el Tank muera.
// Amy no muere, así que nosotros los eliminamos.
Action Timer_CleanupSelfCast(Handle timer, DataPack pack) {
    pack.Reset();
    int userId = pack.ReadCell();
    delete pack;

    int client = GetClientOfUserId(userId);
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Stop;

    // Buscar y matar props parented a Amy:
    // - Shield props (Shield_prop, targetname contiene "shield")
    // - Func_rotating (de SwordGuardian, targetname contiene "func_rot")
    // - Flame props (targetname contiene "flame" o "cloak")
    int entity = -1;

    // Buscar prop_dynamic con targetnames de shields
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != -1) {
        if (!IsValidEntity(entity)) continue;
        char name[64];
        GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
        // Shields del Super Tank usan names como "shield", "fortress", etc.
        if (StrContains(name, "shield") >= 0 || StrContains(name, "fortress") >= 0 ||
            StrContains(name, "ovl_func_rot") >= 0 || StrContains(name, "sword") >= 0) {
            // Verificar que esté parented a Amy
            int parent = GetEntPropEnt(entity, Prop_Send, "moveparent");
            if (parent == client) {
                RemoveEntity(entity);
            }
        }
    }

    // Buscar func_rotating (de SwordGuardian)
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "func_rotating")) != -1) {
        if (!IsValidEntity(entity)) continue;
        int parent = GetEntPropEnt(entity, Prop_Send, "moveparent");
        if (parent == client) {
            RemoveEntity(entity);
        }
    }

    // Limpiar flags del scope de Amy (Reflecting, etc.)
    int runner = FindOrCreateScriptRunner();
    if (runner != -1) {
        char code[256];
        Format(code, sizeof(code),
            "local p = null; while(p = Entities.FindByClassname(p, \"player\")) { if(p.GetEntityIndex() == %d) { p.ValidateScriptScope(); local s = p.GetScriptScope(); if(\"Reflecting\" in s) s.Reflecting <- false; } }",
            client);
        SetVariantString(code);
        AcceptEntityInput(runner, "RunScriptCode");
    }

    return Plugin_Stop;
}

// ============================================================================
//  SWORD GUARDIAN - DAÑO PERSONALIZADO
//  Reemplaza el DamageInterval del Super Tank con lógica de Amy:
//  - Daño base 35 a especiales (SI players)
//  - 3x daño a commons (infected) y witches
//  - Sinergia con Dash Verdugo: si el target tiene más HP que Amy, más daño
//  - NO daña a survivors (el anti-FF también lo cubre)
// ============================================================================

Action Timer_SwordDamage(Handle timer, DataPack pack) {
    pack.Reset();
    int userId = pack.ReadCell();

    int client = GetClientOfUserId(userId);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) {
        g_hSwordDamageTimer[client] = null;
        delete pack;
        return Plugin_Stop;
    }

    // Obtener posición de Amy
    float amyPos[3];
    GetClientAbsOrigin(client, amyPos);
    amyPos[2] += 40.0;

    float radiusSq = SWORD_RADIUS * SWORD_RADIUS;
    float survivorHP = float(GetClientHealth(client));
    if (survivorHP < 50.0) survivorHP = 50.0;

    // Calcular multiplicador de Dash Verdugo
    // Mismo cálculo que Amy_CalculateDashMultiplier en Amy.inc
    float dashMult = 1.0;

    // Dañar infectados especiales (SI players)
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float targetPos[3];
        GetClientAbsOrigin(targetPos, targetPos);
        targetPos[2] += 40.0;

        if (GetVectorDistance(amyPos, targetPos, true) > radiusSq) continue;

        // Calcular daño con Dash Verdugo
        float dmg = SWORD_BASE_DMG;

        int targetHP = GetClientHealth(i);
        if (targetHP <= 0) continue;

        // Ratio = targetHP / survivorHP
        float ratio = float(targetHP) / survivorHP;
        if (ratio < 1.0) ratio = 1.0;

        // Dash Verdugo por tramos (igual que en Amy.inc)
        if (ratio <= 1.0) {
            dashMult = 1.0;
        } else if (ratio <= 5.0) {
            dashMult = 1.5;
        } else if (ratio <= 10.0) {
            dashMult = 2.0;
        } else if (ratio <= 50.0) {
            dashMult = 2.5;
        } else if (ratio <= 100.0) {
            dashMult = 3.0;
        } else if (ratio <= 500.0) {
            dashMult = 3.5;
        } else {
            dashMult = 4.0;
        }

        dmg *= dashMult;

        SDKHooks_TakeDamage(i, client, client, dmg, DMG_SLASH);
    }

    // Dañar commons (3x daño base)
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1) {
        if (!IsValidEntity(entity)) continue;

        float entityPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityPos);
        entityPos[2] += 40.0;

        if (GetVectorDistance(amyPos, entityPos, true) > radiusSq) continue;

        float dmg = SWORD_BASE_DMG * SWORD_COMMON_MULT;
        SDKHooks_TakeDamage(entity, client, client, dmg, DMG_SLASH);
    }

    // Dañar witches (3x daño base)
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1) {
        if (!IsValidEntity(entity)) continue;

        float entityPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityPos);
        entityPos[2] += 40.0;

        if (GetVectorDistance(amyPos, entityPos, true) > radiusSq) continue;

        float dmg = SWORD_BASE_DMG * SWORD_WITCH_MULT;
        SDKHooks_TakeDamage(entity, client, client, dmg, DMG_SLASH);
    }

    // Reset pack para el siguiente tick
    pack.Reset();
    pack.WriteCell(userId);

    return Plugin_Continue;
}

// ============================================================================
//  HELPERS
// ============================================================================

int FindOrCreateScriptRunner() {
    int entity = FindEntityByClassname(-1, "logic_script");
    if (entity != -1 && IsValidEntity(entity)) return entity;

    entity = CreateEntityByName("logic_script");
    if (entity != -1) DispatchSpawn(entity);
    return entity;
}

int GetAimedEntity(int client) {
    float eyePos[3], eyeAng[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);

    Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceFilter_NoSelf, client);
    if (trace == null) return -1;

    int target = -1;
    if (TR_DidHit(trace)) {
        target = TR_GetEntityIndex(trace);
    }
    delete trace;
    return target;
}

bool GetAimedPosition(int client, float pos[3]) {
    float eyePos[3], eyeAng[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);

    Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SOLID, RayType_Infinite, TraceFilter_NoPlayers, client);
    if (trace == null) return false;

    bool hit = false;
    if (TR_DidHit(trace)) {
        TR_GetEndPosition(pos, trace);
        hit = true;
    }
    delete trace;
    return hit;
}

public bool TraceFilter_NoSelf(int entity, int mask, int self) {
    return entity != self;
}

public bool TraceFilter_NoPlayers(int entity, int mask, int self) {
    if (entity == self) return false;
    if (1 <= entity && entity <= MaxClients) return false;
    return true;
}

bool IsValidClient(int client) {
    return 1 <= client && client <= MaxClients && IsClientInGame(client);
}
