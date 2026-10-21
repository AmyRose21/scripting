/*
 * ============================================================================
 *  Doll_System.inc  —  Sistema Modular de Poderes Doll  (v2.1)
 * ============================================================================
 *
 *  v2.1 (R28.2) - STUN AURA "AURA LIMPIA": dentro del radio el IE se
 *          ralentiza (0.5); al SALIR del radio — o al apagar el poder en
 *          el menú, o si la dueña se desconecta — recupera su velocidad
 *          normal. Antes el 0.5 quedaba pegado al IE para el resto de la
 *          partida (no existía ningún reset: death->ghost->respawn
 *          heredaba el slow). Guardas de compatibilidad: el aura nunca
 *          pisa slows más fuertes (Rompe-huesos 0.2 de Amy) y solo
 *          restaura 1.0 sobre el 0.5 exacto que el propio aura dejo
 *          (congelamientos 0.0 y boosts 1.0-2.0 de otros sistemas
 *          quedan intactos).
 *
 *  CARACTERÍSTICAS:
 *  - Activación por SteamID (no por personaje)
 *  - Menú interactivo para activar/desactivar cada poder
 *  - Independiente del personaje (funciona con cualquier survivor)
 *  - Preferencias guardadas en cookie (persisten entre sesiones)
 *  - Fácil de extender: añade un poder al enum, al array de nombres,
 *    y un case en el switch correspondiente
 *
 *  COMANDOS:
 *  - sm_mastery     : Abre el menú de poderes (solo SteamIDs autorizados)
 *  - sm_masterystatus   : Muestra estado actual en consola
 *
 *  CÓMO AÑADIR UN PODER NUEVO:
 *  1. Añádelo al enum DollPowers (antes de DollPower_COUNT)
 *  2. Añádelo a g_sDollPowerNames y g_sDollPowerDesc
 *  3. Implementa su lógica en el hook correspondiente:
 *     - Daño recibido  → DollSys_OnTakeDamage
 *     - PreThink        → DollSys_PreThink
 *     - RunCmd          → DollSys_OnPlayerRunCmd
 *     - Al matar        → DollSys_OnPlayerDeath (cuando matas a un SI)
 *  4. Usa: if (Doll_IsPowerEnabled(client, DollPower_MiPoder)) { ... }
 *
 *  STEAMIDs AUTORIZADOS:
 *  Edita el array g_sDollSteamIDs abajo para añadir más jugadores.
 * ============================================================================
 */

#if defined _Doll_System_included
    #endinput
#endif
#define _Doll_System_included

#define DOLL_INC_VERSION "2.1"   // v2.1: sonda de versión (sm_sjsver del manager)

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

// ============================================================================
//  CONFIGURACIÓN — SteamIDs autorizadas para usar Doll System
//  Para añadir más: aumenta DOLL_STEAMID_COUNT y añade el SteamID al array
// ============================================================================

// Roles
enum DollRole {
    Role_Amy = 0,    // La Princesa / Dueña
    Role_Sally,      // La Muñequita
    Role_Any         // Cualquiera de las dos
};

#define DOLL_STEAMID_COUNT 2
char g_sDollSteamIDs[DOLL_STEAMID_COUNT][32] = {
    "STEAM_1:1:410494263",  // Amy  (la Princesa)
    "STEAM_1:0:889541669"   // Sally (la muñequita)
};

// Rol de cada SteamID (debe coincidir con el array de arriba)
DollRole g_eDollSteamIDRole[DOLL_STEAMID_COUNT] = {
    Role_Amy,
    Role_Sally
};

// Rol del player detectado al conectar
DollRole g_eDollPlayerRole[MAXPLAYERS + 1];

// ============================================================================
//  DEFINICIÓN DE PODERES
//  Para añadir un poder: añádelo aquí (antes de DollPower_COUNT)
//  y luego añade su nombre y descripción en los arrays de abajo
// ============================================================================
#define MAX_DOLL_POWERS 26

enum DollPowers {
    DollPower_CinturaParaAca = 0,    // TP back + 75% buff 6s
    DollPower_DivaDoll,              // 75% damage reduction siempre
    DollPower_Dodge,                 // 50% evasión + 2.5s invuln
    DollPower_NerviosDeAcero,        // 3 revives, scaling damage 2x/4.5x/7x
    DollPower_AlmaDominada,          // Regen 1HP/4s + fire immune
    DollPower_AntiWitch,             // Witch hace 99.9% menos, tú haces 100x
    DollPower_IncapInmune,           // Sin daño mientras incapped
    DollPower_VerdugoDeGigantes,     // 2x daño a infectados
    DollPower_Enlace,                // Divide daño entre allies
    DollPower_DobleSalto,            // Doble salto en el aire
    DollPower_Lifesteal,             // Cura 5HP por kill
    DollPower_SpeedBoost,            // +50% velocidad cuando HP < 30
    DollPower_DamageReflect,         // Refleja 25% del daño
    DollPower_HealPulse,             // Cura 2HP a allies cada 5s
    DollPower_Crit,                  // 15% chance de crítico x2
    DollPower_TankKiller,            // 3x daño a Tanks
    DollPower_FallImmune,            // Inmune a caídas
    DollPower_FireImmune,            // Inmune a fuego
    DollPower_AcidImmune,            // Inmune a ácido/spit
    DollPower_GhostMode,             // 2s invisibilidad al recibir daño
    DollPower_StunAura,              // Ralentiza SI cercanos
    DollPower_MunecaPrincesa,        // Boost cuando Amy cae
    DollPower_AutoCleanse,           // Limpia agarres cada 10s
    DollPower_ShieldBubble,          // Escudo 200HP cada 30s
    DollPower_AntiVomito,            // Refleja el vómito del boomer (menú Mastery)
    DollPower_COUNT
}

// Nombres y descripciones para el menú
char g_sDollPowerNames[DollPower_COUNT][48] = {
    "Trae esa cintura para acá",
    "Diva Doll (75% reducción)",
    "Dodge (50% evasión)",
    "Nervios de acero (3 revives)",
    "Alma dominada (regen + fire)",
    "Anti-Witch",
    "Incap Inmune",
    "Verdugo de Gigantes (2x SI)",
    "Enlace (split con allies)",
    "Doble salto",
    "Lifesteal (5HP/kill)",
    "Speed Boost (HP<30)",
    "Damage Reflect (25%)",
    "Heal Pulse (2HP/5s)",
    "Crit (15% x2)",
    "Tank Killer (3x)",
    "Fall Immune",
    "Fire Immune",
    "Acid Immune",
    "Ghost Mode (2s)",
    "Stun Aura",
    "Muñeca Princesa",
    "Auto Cleanse (10s)",
    "Shield Bubble (200HP/30s)",
    "Anti-Vómito (reflejo)"
};

char g_sDollPowerDesc[DollPower_COUNT][96] = {
    "TP de vuelta + 75% reducción 6s al alejarse",
    "75% reducción de daño siempre activa",
    "50% chance de evadir + 2.5s invulnerable",
    "Auto-revive 3 veces, daño escala 2x/4.5x/7x",
    "Regen 1HP/4s + inmunidad a fuego",
    "Witch hace 99.9% menos daño, tú haces 100x a witch",
    "Sin daño mientras incapacitada",
    "2x daño a infectados especiales",
    "Divide daño entre aliados vivos",
    "Doble salto en el aire",
    "Cura 5HP por cada infectado muerto",
    "+50% velocidad cuando HP < 30",
    "Refleja 25% del daño al atacante",
    "Cura 2HP a aliados cercanos cada 5s",
    "15% chance de golpe crítico x2 daño",
    "3x daño a Tanks",
    "Inmune a daño de caída",
    "Inmune a daño de fuego",
    "Inmune a ácido/spit de Spitter",
    "2s de invisibilidad al recibir daño",
    "Ralentiza SI cercanos (radio 500)",
    "Poderes aumentan cuando Amy cae",
    "Limpia agarres automáticamente cada 10s",
    "Escudo de 200HP que se regenera cada 30s",
    "Vómito del boomer devuelto: su propia bilis, sale volando y 100 daño"
};

// ============================================================================
//  ROL DE CADA PODER
//  Role_Amy   → solo Amy (la Princesa)
//  Role_Sally → solo Sally (la muñequita)
//  Role_Any   → cualquiera de las dos
// ============================================================================
DollRole g_eDollPowerRole[DollPower_COUNT] = {
    Role_Sally,  // CinturaParaAca  — Sally es jalada hacia Amy
    Role_Any,    // DivaDoll        — ambas pueden tener reducción
    Role_Any,    // Dodge           — ambas pueden esquivar
    Role_Sally,  // NerviosDeAcero  — Sally revive cuando Amy cae
    Role_Sally,  // AlmaDominada    — Sally es dominada por Amy
    Role_Any,    // AntiWitch       — ambas
    Role_Any,    // IncapInmune     — ambas
    Role_Amy,    // VerdugoDeGigantes — Amy protege a su muñequita
    Role_Amy,    // Enlace          — Amy comparte daño con el equipo
    Role_Amy,    // DobleSalto      — Amy tiene su doble salto
    Role_Any,    // Lifesteal        — ambas
    Role_Any,    // SpeedBoost       — ambas
    Role_Amy,    // DamageReflect    — Amy refleja daño
    Role_Amy,    // HealPulse        — Amy cura a su equipo
    Role_Any,    // Crit             — ambas
    Role_Amy,    // TankKiller       — Amy caza Tanks
    Role_Any,    // FallImmune       — ambas
    Role_Any,    // FireImmune       — ambas
    Role_Any,    // AcidImmune       — ambas
    Role_Any,    // GhostMode        — ambas
    Role_Amy,    // StunAura         — Amy tiene aura de autoridad
    Role_Sally,  // MunecaPrincesa   — Sally despierta cuando Amy cae
    Role_Any,    // AutoCleanse      — ambas
    Role_Any,    // ShieldBubble     — ambas
    Role_Amy,    // AntiVomito       — la Princesa devuelve el vómito
};

// Helper: ¿el player tiene permiso para usar este poder?
// (Definido después de las variables globales — ver más abajo)

// ============================================================================
//  ESTADO DEL SISTEMA
// ============================================================================
bool   g_bDollPlayer[MAXPLAYERS + 1];                       // ¿Es Doll autorizado?
bool   g_bDollPowerEnabled[MAXPLAYERS + 1][DollPower_COUNT]; // Toggle por poder
Cookie g_hDollPrefsCookie;                                  // Cookie de preferencias

// Variables de estado para poderes activos
bool   g_bDollDodgeActive[MAXPLAYERS + 1];
float  g_fDollDodgeEnd[MAXPLAYERS + 1];
bool   g_bDollGhostActive[MAXPLAYERS + 1];
float  g_fDollGhostEnd[MAXPLAYERS + 1];
int    g_iDollNerviosRevives[MAXPLAYERS + 1];
float  g_fDollNerviosDmgMult[MAXPLAYERS + 1];
float  g_fDollAlmaLastRegen[MAXPLAYERS + 1];
float  g_fDollHealPulseLast[MAXPLAYERS + 1];
float  g_fDollAutoCleanseLast[MAXPLAYERS + 1];
int    g_iDollShieldHP[MAXPLAYERS + 1];
float  g_fDollShieldRegenLast[MAXPLAYERS + 1];
bool   g_bDollSysJumped[MAXPLAYERS + 1];
float  g_fDollLastChatMsg[MAXPLAYERS + 1];

// Cintura para Acá
#define DOLL_CINTURA_MAX_DIST      1500.0
#define DOLL_CINTURA_WARN_DIST     1200.0
#define DOLL_CINTURA_TP_DIST       1500.0
#define DOLL_CINTURA_BUFF_DURATION 6.0
#define DOLL_CINTURA_REDUCTION     0.75
bool   g_bDollCinturaBuff[MAXPLAYERS + 1];
float  g_fDollCinturaBuffEnd[MAXPLAYERS + 1];
bool   g_bDollWarnedFar[MAXPLAYERS + 1];
int    g_iDollSysAmyClient = -1;  // Para Cintura y Muñeca Princesa (Doll_System)
bool   g_bDollSysAmyDead = false;

// Constantes
#define DOLL_DODGE_CHANCE          50
#define DOLL_DODGE_INVULN_DURATION 2.5
#define DOLL_GHOST_DURATION        2.0
#define DOLL_NERVIOS_MAX_REVIVES   3
#define DOLL_ALMA_REGEN_INTERVAL   4.0
#define DOLL_HEALPULSE_INTERVAL    5.0
#define DOLL_HEALPULSE_RADIUS      500.0
#define DOLL_HEALPULSE_AMOUNT      2
#define DOLL_LIFESTEAL_AMOUNT      5
#define DOLL_SPEEDBOOST_THRESHOLD  30
#define DOLL_SPEEDBOOST_MULT       1.5
#define DOLL_REFLECT_PERCENT       0.25
#define DOLL_CRIT_CHANCE           15
#define DOLL_CRIT_MULT             2.0
#define DOLL_TANKKILLER_MULT       3.0
#define DOLL_VERDUGO_MULT          2.0
#define DOLL_AUTOCLEANSE_INTERVAL  10.0
#define DOLL_SHIELD_MAX_HP         200
#define DOLL_SHIELD_REGEN_INTERVAL 30.0
#define DOLL_STUNAURA_RADIUS       500.0
#define DOLL_STUNAURA_SLOW         0.5    // v2.1: 50% de velocidad dentro del aura
#define DOLLSYS_DOUBLEJUMP_FORCE      300.0
#define DOLL_DOLL_REDUCTION        0.75
#define DOLL_WITCH_DMG_MULT        0.001
#define DOLL_WITCH_KILL_MULT       100.0
#define DOLL_ENLACE_REBOUND_REDUCE 0.50

// Helper: ¿el player tiene permiso para usar este poder?
bool DollSys_CanUsePower(int client, DollPowers power)
{
    if (!g_bDollPlayer[client]) return false;

    DollRole powerRole = g_eDollPowerRole[power];
    if (powerRole == Role_Any) return true;

    return g_eDollPlayerRole[client] == powerRole;
}

// ============================================================================
//  INICIALIZACIÓN
// ============================================================================
public void DollSys_OnPluginStart()
{
    // Crear cookie para guardar preferencias
    g_hDollPrefsCookie = new Cookie("mastery_power_prefs", "Mastery Power toggles", CookieAccess_Protected);

    // Registrar comandos
    RegConsoleCmd("sm_mastery", DollSys_CommandMenu, "Abrir menú Mastery Power");
    RegConsoleCmd("sm_masterystatus", DollSys_CommandStatus, "Estado Mastery Power");

    // Hooks
    HookEvent("player_spawn", DollSys_OnPlayerSpawn);
    HookEvent("player_death", DollSys_OnPlayerDeath);
    HookEvent("round_start", DollSys_OnRoundStart, EventHookMode_PostNoCopy);
    HookEvent("witch_spawn", DollSys_OnWitchSpawn);
    HookEvent("player_incapacitated", DollSys_OnPlayerIncapacitated);
    HookEvent("player_ledge_grab", DollSys_OnPlayerIncapacitated);
}

public void DollSys_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // Reset estado de todos los jugadores
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bDollPlayer[i] = false;
        g_eDollPlayerRole[i] = Role_Any;
        g_bDollDodgeActive[i] = false;
        g_bDollGhostActive[i] = false;
        g_iDollNerviosRevives[i] = 0;
        g_fDollNerviosDmgMult[i] = 1.0;
        g_fDollAlmaLastRegen[i] = 0.0;
        g_fDollHealPulseLast[i] = 0.0;
        g_fDollAutoCleanseLast[i] = 0.0;
        g_iDollShieldHP[i] = 0;
        g_fDollShieldRegenLast[i] = 0.0;
        g_bDollSysJumped[i] = false;
        g_fDollLastChatMsg[i] = 0.0;
        g_bDollCinturaBuff[i] = false;
        g_bDollWarnedFar[i] = false;
    }

    // Reset Amy state
    g_iDollSysAmyClient = -1;
    g_bDollSysAmyDead = false;

    // Re-detectar Doll players después de 2s
    CreateTimer(2.0, DollSys_Timer_RoundStartRecheck, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action DollSys_Timer_RoundStartRecheck(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        DollSys_CheckDollStatus(i);
    }
    return Plugin_Stop;
}

public void DollSys_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    // Verificar si es Doll
    DollSys_CheckDollStatus(client);

    // Si es SI, hookearlo para multiplicadores de daño
    if (GetClientTeam(client) == 3) // TEAM_INFECTED
    {
        SDKHook(client, SDKHook_OnTakeDamage, DollSys_OnSIDamage);
    }

    // Detectar si este Doll es Amy (para Cintura y Muñeca Princesa)
    char auth[32];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
    if (DollSys_MatchSteamID(auth, "STEAM_1:1:410494263") ||
        DollSys_MatchSteamID(auth, "STEAM_0:1:410494263"))
    {
        g_iDollSysAmyClient = client;
        g_bDollSysAmyDead = false;
    }
}

// ============================================================================
//  NERVIOS DE ACERO — Auto-revive al caer incapacitada (solo si Amy cayó)
//  Muñeca Princesa — Boost cuando Amy está muerta
// ============================================================================
public void DollSys_OnPlayerIncapacitated(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    if (victim <= 0 || victim > MaxClients || !g_bDollPlayer[victim]) return;

    // Nervios de Acero: solo funciona si Muñeca Princesa está activada
    // (es decir, si Amy cayó) O si la propia victim es Amy y está sola
    bool princesaMode = DollSys_IsPrincesaMode(victim);

    if (Doll_IsPowerEnabled(victim, DollPower_NerviosDeAcero) &&
        princesaMode &&
        g_iDollNerviosRevives[victim] < DOLL_NERVIOS_MAX_REVIVES)
    {
        // Timer de 1.5s para revive (dar tiempo al juego a procesar la incap)
        // v51: TIMER_DATA_HNDL_CLOSE - si el mapa gira dentro del revive, el
        // pack se cierra con el kill del timer (antes: leak silencioso).
        DataPack dp = new DataPack();
        dp.WriteCell(victim);
        CreateTimer(1.5, DollSys_Timer_NerviosRevive, dp, TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
    }
}

public Action DollSys_Timer_NerviosRevive(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    // v51: el pack lo cierra TIMER_DATA_HNDL_CLOSE al terminar el timer

    if (!g_bDollPlayer[client] || !IsClientInGame(client) || !IsPlayerAlive(client))
        return Plugin_Stop;

    if (g_iDollNerviosRevives[client] >= DOLL_NERVIOS_MAX_REVIVES)
        return Plugin_Stop;

    // Verificar que siga incapacitada
    if (!GetEntProp(client, Prop_Send, "m_isIncapacitated"))
        return Plugin_Stop;

    g_iDollNerviosRevives[client]++;

    // Aplicar multiplicador según el nivel de revive
    switch (g_iDollNerviosRevives[client])
    {
        case 1: g_fDollNerviosDmgMult[client] = 2.0;
        case 2: g_fDollNerviosDmgMult[client] = 4.5;
        case 3: g_fDollNerviosDmgMult[client] = 7.0;
    }

    // Reincorporar
    SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);
    SetEntProp(client, Prop_Send, "m_isHangingFromLedge", 0);

    int newHp = GetClientHealth(client);
    if (newHp < 50) SetEntityHealth(client, 50);

    // Efecto visual
    float pos[3];
    GetClientAbsOrigin(client, pos);
    TE_SetupBeamRingPoint(pos, 10.0, 200.0,
                          PrecacheModel("materials/sprites/laserbeam.vmt"),
                          PrecacheModel("materials/sprites/halo01.vmt"),
                          0, 0, 1.0, 3.0, 30.0, {255, 0, 128, 255}, 0, 0);
    TE_SendToClient(client);

    EmitSoundToClient(client, "ambient/energy/force_field_loop1.wav");

    DollSys_ThrottledChat(client, ">> NERVIOS DE ACERO << Revive %d / %d — Daño x%.1f",
        g_iDollNerviosRevives[client], DOLL_NERVIOS_MAX_REVIVES, g_fDollNerviosDmgMult[client]);

    return Plugin_Stop;
}

// ¿Está en modo Muñeca Princesa? (Amy cayó o no está)
bool DollSys_IsPrincesaMode(int client)
{
    if (!g_bDollPlayer[client]) return false;
    if (!IsPlayerAlive(client)) return false;

    // Si Muñeca Princesa no está activada, nunca entra en este modo
    if (!Doll_IsPowerEnabled(client, DollPower_MunecaPrincesa)) return false;

    // Si Amy no está conectada o está muerta, activar modo princesa
    if (g_iDollSysAmyClient <= 0) return true;
    if (!IsClientInGame(g_iDollSysAmyClient)) return true;
    if (!IsPlayerAlive(g_iDollSysAmyClient)) return true;
    if (g_bDollSysAmyDead) return true;

    return false;
}

// Verificar si el player es Doll por SteamID
void DollSys_CheckDollStatus(int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    char auth[32];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));

    bool wasDoll = g_bDollPlayer[client];
    g_bDollPlayer[client] = false;
    g_eDollPlayerRole[client] = Role_Any;  // Reset

    for (int i = 0; i < DOLL_STEAMID_COUNT; i++)
    {
        if (DollSys_MatchSteamID(auth, g_sDollSteamIDs[i]))
        {
            g_bDollPlayer[client] = true;
            g_eDollPlayerRole[client] = g_eDollSteamIDRole[i];
            break;
        }
    }

    // Si acaba de ser detectado como Doll, cargar preferencias
    if (g_bDollPlayer[client] && !wasDoll)
    {
        DollSys_LoadPrefs(client);
        SDKHook(client, SDKHook_OnTakeDamage, DollSys_OnTakeDamage);

        char roleName[32];
        switch (g_eDollPlayerRole[client])
        {
            case Role_Amy:   roleName = "Princesa Amy";
            case Role_Sally: roleName = "Muñequita Sally";
            default:         roleName = "Doll";
        }
        PrintToChat(client, "\x04[Mastery]\x01 Mastery Power activado (\x03%s\x01). Escribe \x04!mastery\x01 para configurar poderes.", roleName);
    }
    else if (!g_bDollPlayer[client] && wasDoll)
    {
        SDKUnhook(client, SDKHook_OnTakeDamage, DollSys_OnTakeDamage);
    }
}

// >>> FIX: llamado por el plugin principal cuando las cookies del cliente
// terminan de cargarse. Antes, si player_spawn ocurría antes de que la
// cookie estuviera en caché, las preferencias nunca se cargaban y todos
// los poderes quedaban desactivados hasta reconectar.
public void DollSys_OnClientCookiesCached(int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;
    if (!g_bDollPlayer[client]) return;
    DollSys_LoadPrefs(client);
}

// >>> FIX: llamado por el plugin principal al desconectarse un cliente.
// Evita que el siguiente jugador que reutilice el mismo slot herede el
// estado del Doll anterior.
public void DollSys_OnClientDisconnect(int client)
{
    // v2.1 (R28.2): si la dueña del Stun Aura se desconecta con el poder
    // activo, devolver la velocidad normal a los IE que quedaron a 0.5
    // (la RunCmd ya no correra para este client y nadie más los limpiara).
    // Se hace ANTES de resetear el estado del client.
    if (g_bDollPlayer[client]
        && g_eDollPlayerRole[client] == Role_Amy
        && g_bDollPowerEnabled[client][DollPower_StunAura])
    {
        DollSys_ClearStunAura();
    }

    g_bDollPlayer[client] = false;
    g_eDollPlayerRole[client] = Role_Any;
    g_bDollDodgeActive[client] = false;
    g_bDollGhostActive[client] = false;
    g_iDollNerviosRevives[client] = 0;
    g_fDollNerviosDmgMult[client] = 1.0;
    g_iDollShieldHP[client] = 0;
    g_bDollSysJumped[client] = false;
    g_bDollCinturaBuff[client] = false;
    g_bDollWarnedFar[client] = false;
    if (g_iDollSysAmyClient == client) g_iDollSysAmyClient = -1;
}

// Helper: comparar SteamID aceptando STEAM_0 o STEAM_1
bool DollSys_MatchSteamID(const char[] actualAuth, const char[] expectedAuth)
{
    // Comparación directa
    if (StrEqual(actualAuth, expectedAuth)) return true;

    // Fallback: aceptar STEAM_0: o STEAM_1: (difieren en posición 6)
    // "STEAM_X:Y:Z" → posición 6 es el X (0 o 1)
    if (strlen(actualAuth) >= 8 && strlen(expectedAuth) >= 8)
    {
        // Verificar que ambos empiezan con "STEAM_"
        if (StrContains(actualAuth, "STEAM_") == 0 && StrContains(expectedAuth, "STEAM_") == 0)
        {
            // Si el resto (desde posición 7) es igual, aceptar
            if (StrEqual(actualAuth[7], expectedAuth[7])) return true;
        }
    }
    return false;
}

// ============================================================================
//  SISTEMA DE PREFERENCIAS (COOKIE)
// ============================================================================
void DollSys_LoadPrefs(int client)
{
    if (!AreClientCookiesCached(client)) return;

    char prefs[64];
    g_hDollPrefsCookie.Get(client, prefs, sizeof(prefs));

    if (prefs[0] == '\0')
    {
        // Primera vez: activar todos los poderes por defecto
        for (int i = 0; i < view_as<int>(DollPower_COUNT); i++)
        {
            g_bDollPowerEnabled[client][i] = true;
        }
        DollSys_SavePrefs(client);
        return;
    }

    // Cargar desde el string: "10101101..." donde cada char es ON/OFF
    // >>> FIX: si la cookie es más corta que DollPower_COUNT (guardada con
    // una versión antigua del sistema con menos poderes), NO se lee más
    // allá del final del string. Los poderes nuevos se activan por defecto.
    int len = strlen(prefs);
    for (int i = 0; i < view_as<int>(DollPower_COUNT); i++)
    {
        g_bDollPowerEnabled[client][i] = (i >= len || prefs[i] == '1');
    }
}

void DollSys_SavePrefs(int client)
{
    char prefs[view_as<int>(DollPower_COUNT) + 1];
    for (int i = 0; i < view_as<int>(DollPower_COUNT); i++)
    {
        prefs[i] = g_bDollPowerEnabled[client][i] ? '1' : '0';
    }
    prefs[view_as<int>(DollPower_COUNT)] = '\0';
    g_hDollPrefsCookie.Set(client, prefs);
}

// Helper: ¿un poder está activado para este jugador?
bool Doll_IsPowerEnabled(int client, DollPowers power)
{
    if (!g_bDollPlayer[client]) return false;
    if (!g_bDollPowerEnabled[client][power]) return false;

    // Verificar que el player tenga el rol correcto para este poder
    DollRole powerRole = g_eDollPowerRole[power];
    if (powerRole == Role_Any) return true;

    return g_eDollPlayerRole[client] == powerRole;
}

// ============================================================================
//  MENÚ DE PODERES
// ============================================================================
public Action DollSys_CommandMenu(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || client > MaxClients || !IsClientInGame(client))
    {
        ReplyToCommand(client, "[Mastery] Comando solo usable in-game.");
        return Plugin_Handled;
    }

    // Re-verificar SteamID en este momento (por si player_spawn se ejecutó antes
    // de que el plugin cargara, o si el cache estaba desactualizado)
    if (!g_bDollPlayer[client])
    {
        DollSys_CheckDollStatus(client);
    }

    // Si sigue sin ser Doll, mostrar diagnóstico
    if (!g_bDollPlayer[client])
    {
        char auth[32];
        GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
        PrintToChat(client, "\x04[Mastery]\x01 No estás autorizado. Tu SteamID: \x03%s\x01", auth);
        PrintToChat(client, "\x04[Mastery]\x01 SteamIDs autorizadas:");
        for (int i = 0; i < DOLL_STEAMID_COUNT; i++)
        {
            PrintToChat(client, "  \x03%s\x01", g_sDollSteamIDs[i]);
        }
        return Plugin_Handled;
    }

    DollSys_ShowMenu(client);
    return Plugin_Handled;
}

void DollSys_ShowMenu(int client)
{
    DollSys_ShowMenuAt(client, 0);
}

// Muestra el menú empezando en una posición concreta.
// Se usa para volver a abrirlo EN LA MISMA PÁGINA tras alternar un poder.
void DollSys_ShowMenuAt(int client, int firstItem)
{
    Menu menu = new Menu(DollSys_MenuHandler);

    // Contar poderes disponibles y activos para el resumen del título
    int totalUsable = 0;
    int totalActive = 0;
    for (int i = 0; i < view_as<int>(DollPower_COUNT); i++)
    {
        if (!DollSys_CanUsePower(client, view_as<DollPowers>(i))) continue;
        totalUsable++;
        if (g_bDollPowerEnabled[client][i]) totalActive++;
    }

    // Título con el rol del player + resumen de activos
    char title[128];
    char roleName[32];
    switch (g_eDollPlayerRole[client])
    {
        case Role_Amy:   roleName = "Princesa Amy (Dueña)";
        case Role_Sally: roleName = "Muñequita Sally";
        default:         roleName = "Doll";
    }
    Format(title, sizeof(title), "Mastery Power — %s\nActivos: %d / %d   (pulsa para cambiar)\n ",
        roleName, totalActive, totalUsable);
    menu.SetTitle(title);

    char item[96];
    char infoStr[8];

    // >>> MEJORA DE APARIENCIA <<<
    // Antes los poderes se listaban en el orden del enum y los separadores
    // de sección salían intercalados cada 2-3 líneas (UNIVERSAL, PRINCESA,
    // UNIVERSAL...). Ahora se agrupan en 2 bloques limpios:
    //   Sección 1: PODERES UNIVERSALES (Role_Any)
    //   Sección 2: PODERES DEL ROL (Princesa o Muñequita)
    for (int s = 0; s < 2; s++)
    {
        DollRole sectionRole = (s == 0) ? Role_Any : g_eDollPlayerRole[client];
        if (s == 1 && sectionRole == Role_Any) break; // rol sin sección propia

        // Solo añadir el separador si la sección tiene al menos un poder
        bool hasPowers = false;
        for (int i = 0; i < view_as<int>(DollPower_COUNT) && !hasPowers; i++)
        {
            if (g_eDollPowerRole[i] == sectionRole &&
                DollSys_CanUsePower(client, view_as<DollPowers>(i)))
            {
                hasPowers = true;
            }
        }
        if (!hasPowers) continue;

        char section[48];
        switch (sectionRole)
        {
            case Role_Amy:   section = "— PODERES DE LA PRINCESA —";
            case Role_Sally: section = "— PODERES DE LA MUÑEQUITA —";
            default:         section = "— PODERES UNIVERSALES —";
        }
        menu.AddItem("-1", section, ITEMDRAW_DISABLED);

        // Índices del poder dentro de la sección (agrupados, sin intercalar)
        for (int i = 0; i < view_as<int>(DollPower_COUNT); i++)
        {
            if (g_eDollPowerRole[i] != sectionRole) continue;
            if (!DollSys_CanUsePower(client, view_as<DollPowers>(i))) continue;

            // Indicador alineado: "[ON]  " y "[OFF] " ocupan lo mismo
            if (g_bDollPowerEnabled[client][i])
            {
                Format(item, sizeof(item), "[ON]  %s", g_sDollPowerNames[i]);
            }
            else
            {
                Format(item, sizeof(item), "[OFF] %s", g_sDollPowerNames[i]);
            }
            IntToString(i, infoStr, sizeof(infoStr));
            menu.AddItem(infoStr, item);
        }
    }

    menu.ExitButton = true;

    // Mantener la página actual si se especifica una posición de inicio
    if (firstItem > 0)
    {
        menu.DisplayAt(client, firstItem, 30);
    }
    else
    {
        menu.Display(client, 30);
    }
}

public int DollSys_MenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        int client = param1;

        // >>> FIX CRÍTICO <<<
        // param2 es la POSICIÓN física del item dentro del menú (incluye los
        // separadores de sección), NO el índice del poder. El código anterior
        // usaba param2 directamente como índice y, como los separadores ocupan
        // posiciones, la posición nunca coincidía con el índice real: pulsar
        // "Doble salto" terminaba activando/desactivando OTRO poder.
        // El índice correcto se guardó en el "info" del item → se lee aquí.
        char infoStr[16];
        if (!menu.GetItem(param2, infoStr, sizeof(infoStr)))
        {
            return 0;
        }

        int powerIdx = StringToInt(infoStr);
        if (powerIdx < 0 || powerIdx >= view_as<int>(DollPower_COUNT))
        {
            return 0;
        }

        // Castear a DollPowers para usar como índice del array
        DollPowers power = view_as<DollPowers>(powerIdx);

        // Toggle
        g_bDollPowerEnabled[client][power] = !g_bDollPowerEnabled[client][power];
        DollSys_SavePrefs(client);

        // v2.1 (R28.2): apagar el Stun Aura limpia YA el slow de todos los
        // IE que quedaron exactamente a 0.5 (la marca del aura). Sin esto
        // seguirian lentos "por el resto de la partida" con el poder OFF.
        if (power == DollPower_StunAura && !g_bDollPowerEnabled[client][power])
        {
            DollSys_ClearStunAura();
        }

        char status[16];
        status = g_bDollPowerEnabled[client][power] ? "ACTIVADO" : "DESACTIVADO";
        PrintToChat(client, "\x04[Mastery]\x01 %s: \x03%s\x01", g_sDollPowerNames[power], status);
        // Mostrar también la descripción para recordar qué hace el poder
        PrintToChat(client, "\x04[Mastery]\x01 \x05%s\x01", g_sDollPowerDesc[power]);

        // Re-abrir el menú en la MISMA página donde estaba el item
        int firstItem = 0;
        int perPage = menu.Pagination;
        if (perPage > 0)
        {
            firstItem = (param2 / perPage) * perPage;
        }
        DollSys_ShowMenuAt(client, firstItem);
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
    return 0;
}

// ============================================================================
//  COMANDO DE ESTADO
// ============================================================================
public Action DollSys_CommandStatus(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return Plugin_Handled;

    PrintToConsole(client, "");
    PrintToConsole(client, "========================================");
    PrintToConsole(client, "  MASTERY POWER — ESTADO");
    PrintToConsole(client, "========================================");
    PrintToConsole(client, "  Doll Player: %s", g_bDollPlayer[client] ? "SI" : "NO");

    if (g_bDollPlayer[client])
    {
        char roleName[32];
        switch (g_eDollPlayerRole[client])
        {
            case Role_Amy:   roleName = "Princesa Amy (Dueña)";
            case Role_Sally: roleName = "Muñequita Sally";
            default:         roleName = "Doll (universal)";
        }
        PrintToConsole(client, "  Rol: %s", roleName);
    }
    PrintToConsole(client, "");

    if (g_bDollPlayer[client])
    {
        PrintToConsole(client, "PODERES DISPONIBLES PARA TU ROL:");
        for (int i = 0; i < view_as<int>(DollPower_COUNT); i++)
        {
            DollPowers power = view_as<DollPowers>(i);

            // Indicar el rol del poder
            char powerRoleTag[16];
            switch (g_eDollPowerRole[power])
            {
                case Role_Amy:   powerRoleTag = "[Princesa]";
                case Role_Sally: powerRoleTag = "[Muñequita]";
                default:         powerRoleTag = "[Universal]";
            }

            // Solo mostrar poderes que el player pueda usar
            bool canUse = DollSys_CanUsePower(client, power);
            if (!canUse) continue;

            PrintToConsole(client, "  %s [%s] %s — %s",
                g_bDollPowerEnabled[client][i] ? "ON " : "OFF",
                powerRoleTag,
                g_sDollPowerNames[i],
                g_sDollPowerDesc[i]);
        }
    }

    PrintToConsole(client, "");
    PrintToConsole(client, "========================================");
    PrintToChat(client, "\x04[Mastery]\x01 Estado enviado a la consola (~)");

    return Plugin_Handled;
}

// ============================================================================
//  HOOKS PRINCIPALES — Cada poder se chequea aquí
// ============================================================================

// ---------- DAÑO RECIBIDO POR DOLL ----------
public Action DollSys_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!g_bDollPlayer[victim]) return Plugin_Continue;
    if (!IsPlayerAlive(victim)) return Plugin_Continue;

    float now = GetEngineTime();
    float originalDamage = damage;
    bool changed = false;

    // ===== PASIVA: Ghost Mode (invisibilidad al recibir daño) =====
    if (Doll_IsPowerEnabled(victim, DollPower_GhostMode) && !g_bDollGhostActive[victim])
    {
        g_bDollGhostActive[victim] = true;
        g_fDollGhostEnd[victim] = now + DOLL_GHOST_DURATION;
        SetEntProp(victim, Prop_Data, "m_CollisionGroup", 1);
        SetEntityRenderMode(victim, RENDER_TRANSCOLOR);
        SetEntityRenderColor(victim, 255, 255, 255, 80);
        DollSys_ThrottledChat(victim, "Ghost Mode activado (2s)");
    }

    // ===== PASIVA: Incap Inmune =====
    if (Doll_IsPowerEnabled(victim, DollPower_IncapInmune))
    {
        bool isIncap = false;
        if (HasEntProp(victim, Prop_Send, "m_isIncapacitated"))
        {
            isIncap = GetEntProp(victim, Prop_Send, "m_isIncapacitated") != 0;
        }
        if (isIncap)
        {
            damage = 0.0;
            DollSys_ThrottledChat(victim, "Incap Inmune: 0 daño");
            return Plugin_Changed;
        }
    }

    // ===== PASIVA: Fire Immune =====
    if (Doll_IsPowerEnabled(victim, DollPower_FireImmune) && (damagetype & DMG_BURN))
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    // ===== PASIVA: Fall Immune =====
    if (Doll_IsPowerEnabled(victim, DollPower_FallImmune) && (damagetype & DMG_FALL))
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    // ===== PASIVA: Acid Immune (spit de Spitter) =====
    if (Doll_IsPowerEnabled(victim, DollPower_AcidImmune) && (damagetype & DMG_ACID))
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    // ===== PASIVA: Anti-Witch =====
    if (Doll_IsPowerEnabled(victim, DollPower_AntiWitch) && DollSys_IsWitchAttacker(attacker, inflictor))
    {
        damage *= DOLL_WITCH_DMG_MULT;
        DollSys_ThrottledChat(victim, "Anti-Witch: daño reducido 99.9%%");
        return Plugin_Changed;
    }

    // ===== PASIVA: Dodge =====
    if (Doll_IsPowerEnabled(victim, DollPower_Dodge))
    {
        if (g_bDollDodgeActive[victim] && now < g_fDollDodgeEnd[victim])
        {
            damage = 0.0;
            return Plugin_Changed;
        }

        if (GetRandomInt(1, 100) <= DOLL_DODGE_CHANCE)
        {
            g_bDollDodgeActive[victim] = true;
            g_fDollDodgeEnd[victim] = now + DOLL_DODGE_INVULN_DURATION;
            damage = 0.0;
            DollSys_ThrottledChat(victim, "Dodge! 2.5s invulnerable");
            return Plugin_Changed;
        }
    }

    // ===== PASIVA: Shield Bubble (absorbe daño) =====
    if (Doll_IsPowerEnabled(victim, DollPower_ShieldBubble) && g_iDollShieldHP[victim] > 0)
    {
        if (damage <= float(g_iDollShieldHP[victim]))
        {
            g_iDollShieldHP[victim] -= RoundToNearest(damage);
            damage = 0.0;
            DollSys_ThrottledChat(victim, "Shield Bubble: %d HP restante", g_iDollShieldHP[victim]);
            return Plugin_Changed;
        }
        else
        {
            damage -= float(g_iDollShieldHP[victim]);
            g_iDollShieldHP[victim] = 0;
            DollSys_ThrottledChat(victim, "Shield Bubble destruido");
            changed = true;
        }
    }

    // ===== PASIVA: Diva Doll (75% reducción) =====
    if (Doll_IsPowerEnabled(victim, DollPower_DivaDoll))
    {
        damage *= (1.0 - DOLL_DOLL_REDUCTION);
        changed = true;
    }

    // ===== PASIVA: Cintura buff (75% reducción por 6s tras TP) =====
    if (Doll_IsPowerEnabled(victim, DollPower_CinturaParaAca) &&
        g_bDollCinturaBuff[victim] && now < g_fDollCinturaBuffEnd[victim])
    {
        damage *= (1.0 - DOLL_CINTURA_REDUCTION);
        changed = true;
    }

    // ===== PASIVA: Damage Reflect =====
    if (Doll_IsPowerEnabled(victim, DollPower_DamageReflect) && attacker > 0 && attacker <= MaxClients)
    {
        float reflectDmg = originalDamage * DOLL_REFLECT_PERCENT;
        SDKHooks_TakeDamage(attacker, victim, victim, reflectDmg, DMG_GENERIC);
        DollSys_ThrottledChat(victim, "Reflectado %.1f a atacante", reflectDmg);
    }

    // ===== PASIVA: Enlace (dividir con allies) =====
    if (Doll_IsPowerEnabled(victim, DollPower_Enlace))
    {
        int allies[32];
        int numAllies = 0;
        for (int i = 1; i <= MaxClients; i++)
        {
            if (i == victim) continue;
            if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
            if (GetClientTeam(i) != 2) continue; // TEAM_SURVIVOR
            allies[numAllies++] = i;
        }

        if (numAllies > 0)
        {
            float share = damage / float(numAllies);
            for (int i = 0; i < numAllies; i++)
            {
                SDKHooks_TakeDamage(allies[i], 0, 0, share, DMG_GENERIC);
            }
            damage = 0.0;
            DollSys_ThrottledChat(victim, "Enlace: dividido entre %d allies", numAllies);
            return Plugin_Changed;
        }
        else
        {
            // Sin allies: rebotar al enemigo
            if (attacker > 0 && attacker <= MaxClients && GetClientTeam(attacker) == 3)
            {
                float rebound = damage * DOLL_VERDUGO_MULT;
                SDKHooks_TakeDamage(attacker, victim, victim, rebound, DMG_GENERIC);
                damage *= DOLL_ENLACE_REBOUND_REDUCE;
                changed = true;
            }
        }
    }

    return changed ? Plugin_Changed : Plugin_Continue;
}

// ---------- DAÑO INFLIGIDO POR DOLL A SI ----------
public Action DollSys_OnSIDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
    if (!g_bDollPlayer[attacker]) return Plugin_Continue;

    bool changed = false;

    // ===== Verdugo de Gigantes (2x daño a SI) =====
    if (Doll_IsPowerEnabled(attacker, DollPower_VerdugoDeGigantes))
    {
        damage *= DOLL_VERDUGO_MULT;
        changed = true;
    }

    // ===== Tank Killer (3x a Tanks) =====
    if (Doll_IsPowerEnabled(attacker, DollPower_TankKiller))
    {
        char cls[32];
        GetEntityClassname(victim, cls, sizeof(cls));
        if (StrEqual(cls, "tank", false) ||
            (GetClientTeam(victim) == 3 && GetEntProp(victim, Prop_Send, "m_zombieClass") == 8))
        {
            damage *= DOLL_TANKKILLER_MULT;
            changed = true;
        }
    }

    // ===== Nervios de Acero (multiplicador escalando) =====
    if (Doll_IsPowerEnabled(attacker, DollPower_NerviosDeAcero))
    {
        float mult = g_fDollNerviosDmgMult[attacker];
        if (mult > 1.0)
        {
            damage *= mult;
            changed = true;
        }
    }

    // ===== Crit (15% chance x2) =====
    if (Doll_IsPowerEnabled(attacker, DollPower_Crit))
    {
        if (GetRandomInt(1, 100) <= DOLL_CRIT_CHANCE)
        {
            damage *= DOLL_CRIT_MULT;
            changed = true;
        }
    }

    // ===== Anti-Witch (100x a witch) =====
    if (Doll_IsPowerEnabled(attacker, DollPower_AntiWitch))
    {
        char cls[32];
        GetEntityClassname(victim, cls, sizeof(cls));
        if (StrEqual(cls, "witch", false))
        {
            damage *= DOLL_WITCH_KILL_MULT;
            changed = true;
        }
    }

    return changed ? Plugin_Changed : Plugin_Continue;
}

// ---------- PRETHINK (cada frame) ----------
public void DollSys_PreThink(int client)
{
    if (!g_bDollPlayer[client]) return;
    if (!IsPlayerAlive(client)) return;

    float now = GetEngineTime();

    // ===== Ghost Mode: expiración =====
    if (g_bDollGhostActive[client] && now > g_fDollGhostEnd[client])
    {
        g_bDollGhostActive[client] = false;
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
        SetEntityRenderMode(client, RENDER_NORMAL);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }

    // ===== Dodge: expiración =====
    if (g_bDollDodgeActive[client] && now > g_fDollDodgeEnd[client])
    {
        g_bDollDodgeActive[client] = false;
    }

    // ===== Alma Dominada: regen =====
    if (Doll_IsPowerEnabled(client, DollPower_AlmaDominada) &&
        now - g_fDollAlmaLastRegen[client] >= DOLL_ALMA_REGEN_INTERVAL)
    {
        int hp = GetClientHealth(client);
        int maxHp = GetEntProp(client, Prop_Send, "m_iMaxHealth");
        if (hp < maxHp)
        {
            SetEntityHealth(client, hp + 1);
        }
        g_fDollAlmaLastRegen[client] = now;
    }

    // ===== Heal Pulse: curar allies cercanos =====
    if (Doll_IsPowerEnabled(client, DollPower_HealPulse) &&
        now - g_fDollHealPulseLast[client] >= DOLL_HEALPULSE_INTERVAL)
    {
        DollSys_DoHealPulse(client);
        g_fDollHealPulseLast[client] = now;
    }

    // ===== Auto Cleanse: limpiar agarres =====
    if (Doll_IsPowerEnabled(client, DollPower_AutoCleanse) &&
        now - g_fDollAutoCleanseLast[client] >= DOLL_AUTOCLEANSE_INTERVAL)
    {
        if (DollSys_IsBeingGrappled(client))
        {
            DollSys_CleanseGrapples(client);
            DollSys_ThrottledChat(client, "Auto Cleanse: agarres limpiados");
        }
        g_fDollAutoCleanseLast[client] = now;
    }

    // ===== Shield Bubble: regeneración =====
    if (Doll_IsPowerEnabled(client, DollPower_ShieldBubble) &&
        g_iDollShieldHP[client] < DOLL_SHIELD_MAX_HP &&
        now - g_fDollShieldRegenLast[client] >= DOLL_SHIELD_REGEN_INTERVAL)
    {
        g_iDollShieldHP[client] = DOLL_SHIELD_MAX_HP;
        g_fDollShieldRegenLast[client] = now;
        DollSys_ThrottledChat(client, "Shield Bubble regenerado (%d HP)", DOLL_SHIELD_MAX_HP);
    }

    // ===== Speed Boost: cuando HP < 30 =====
    if (Doll_IsPowerEnabled(client, DollPower_SpeedBoost))
    {
        int hp = GetClientHealth(client);
        if (hp > 0 && hp < DOLL_SPEEDBOOST_THRESHOLD)
        {
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", DOLL_SPEEDBOOST_MULT);
        }
        else
        {
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        }
    }

    // ===== Stun Aura: ralentizar SI cercanos =====
    if (Doll_IsPowerEnabled(client, DollPower_StunAura))
    {
        DollSys_DoStunAura(client);
    }

    // ===== Cintura para Acá: TP de vuelta si se aleja mucho de Amy =====
    if (Doll_IsPowerEnabled(client, DollPower_CinturaParaAca))
    {
        DollSys_HandleCintura(client, now);
    }

    // ===== Cintura buff: expiración =====
    if (g_bDollCinturaBuff[client] && now > g_fDollCinturaBuffEnd[client])
    {
        g_bDollCinturaBuff[client] = false;
    }
}

// Implementación de Cintura para Acá
void DollSys_HandleCintura(int client, float now)
{
    // Solo aplica si Amy está conectada y viva
    if (g_iDollSysAmyClient <= 0 || !IsClientInGame(g_iDollSysAmyClient) || !IsPlayerAlive(g_iDollSysAmyClient))
        return;

    // Si el propio cliente ES Amy, no aplicar (Amy no se jala a sí misma)
    if (client == g_iDollSysAmyClient) return;

    float sallyPos[3], amyPos[3];
    GetClientAbsOrigin(client, sallyPos);
    GetClientAbsOrigin(g_iDollSysAmyClient, amyPos);
    float dist = GetVectorDistance(sallyPos, amyPos);

    // Aviso a 1200
    if (dist >= DOLL_CINTURA_WARN_DIST && dist < DOLL_CINTURA_TP_DIST && !g_bDollWarnedFar[client])
    {
        DollSys_ThrottledChat(client, "¡Te estás alejando mucho de Amy! (%.0f / %.0f)", dist, DOLL_CINTURA_TP_DIST);
        g_bDollWarnedFar[client] = true;
    }
    else if (dist < DOLL_CINTURA_WARN_DIST)
    {
        g_bDollWarnedFar[client] = false;
    }

    // TP a 1500
    if (dist >= DOLL_CINTURA_TP_DIST)
    {
        // Limpiar agarres antes del TP
        if (DollSys_IsBeingGrappled(client))
        {
            DollSys_CleanseGrapples(client);
        }

        TeleportEntity(client, amyPos, NULL_VECTOR, NULL_VECTOR);

        // Activar buff de Cintura (75% reducción por 6s)
        g_bDollCinturaBuff[client] = true;
        g_fDollCinturaBuffEnd[client] = now + DOLL_CINTURA_BUFF_DURATION;

        DollSys_ThrottledChat(client, ">> TRAE ESA CINTURA PARA ACÁ << Vuelve a tu cajita.");
        EmitSoundToClient(client, "ambient/energy/force_field_loop1.wav");

        // Mensaje a Amy
        if (IsClientInGame(g_iDollSysAmyClient) && !IsFakeClient(g_iDollSysAmyClient))
        {
            DollSys_ThrottledChat(g_iDollSysAmyClient, "Sally se alejó mucho, ella no puede escapar de su cajita.");
            EmitSoundToClient(g_iDollSysAmyClient, "ambient/energy/force_field_loop1.wav");
        }

        g_bDollWarnedFar[client] = false;
    }
}

// ---------- RUN CMD ----------
public void DollSys_OnPlayerRunCmd(int client, int buttons)
{
    if (!g_bDollPlayer[client]) return;
    if (!IsPlayerAlive(client)) return;

    // ===== Doble Salto =====
    if (Doll_IsPowerEnabled(client, DollPower_DobleSalto))
    {
        DollSys_HandleDoubleJump(client, buttons);
    }
}

// ---------- AL MATAR ----------
public void DollSys_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    // Detectar si Amy murió (para activar Muñeca Princesa en Sally)
    if (victim > 0 && victim <= MaxClients && victim == g_iDollSysAmyClient)
    {
        g_bDollSysAmyDead = true;
        // Avisar a todos los Dolls que Amy cayó
        for (int i = 1; i <= MaxClients; i++)
        {
            if (!g_bDollPlayer[i] || i == victim) continue;
            if (!IsClientInGame(i) || IsFakeClient(i)) continue;
            DollSys_ThrottledChat(i, ">> MUÑECA PRINCESA << Amy ha caído. Despierta.");
        }
    }

    if (attacker <= 0 || attacker > MaxClients) return;
    if (!g_bDollPlayer[attacker]) return;
    if (victim <= 0 || victim > MaxClients) return;

    // ===== Lifesteal =====
    if (Doll_IsPowerEnabled(attacker, DollPower_Lifesteal))
    {
        int hp = GetClientHealth(attacker);
        int maxHp = GetEntProp(attacker, Prop_Send, "m_iMaxHealth");
        int newHp = hp + DOLL_LIFESTEAL_AMOUNT;
        if (newHp > maxHp) newHp = maxHp;
        SetEntityHealth(attacker, newHp);
        DollSys_ThrottledChat(attacker, "Lifesteal: +%d HP", DOLL_LIFESTEAL_AMOUNT);
    }
}

// ---------- WITCH SPAWN ----------
public void DollSys_OnWitchSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int witch = event.GetInt("witchid");
    if (witch <= 0 || !IsValidEntity(witch)) return;
    SDKHook(witch, SDKHook_OnTakeDamage, DollSys_OnWitchDamage);
}

public Action DollSys_OnWitchDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
    if (!g_bDollPlayer[attacker]) return Plugin_Continue;

    bool changed = false;

    // Anti-Witch: 100x daño
    if (Doll_IsPowerEnabled(attacker, DollPower_AntiWitch))
    {
        damage *= DOLL_WITCH_KILL_MULT;
        changed = true;
    }

    // Verdugo
    if (Doll_IsPowerEnabled(attacker, DollPower_VerdugoDeGigantes))
    {
        damage *= DOLL_VERDUGO_MULT;
        changed = true;
    }

    // Crit
    if (Doll_IsPowerEnabled(attacker, DollPower_Crit) && GetRandomInt(1, 100) <= DOLL_CRIT_CHANCE)
    {
        damage *= DOLL_CRIT_MULT;
        changed = true;
    }

    return changed ? Plugin_Changed : Plugin_Continue;
}

// ============================================================================
//  HELPERS DE PODERES
// ============================================================================

// --- Doble salto ---
void DollSys_HandleDoubleJump(int client, int buttons)
{
    int waterLevel = GetEntProp(client, Prop_Data, "m_nWaterLevel");
    bool onGround = (GetEntityFlags(client) & FL_ONGROUND) != 0;

    if (onGround || waterLevel >= 2)
    {
        g_bDollSysJumped[client] = false;
        return;
    }

    if ((buttons & IN_JUMP) && !g_bDollSysJumped[client])
    {
        g_bDollSysJumped[client] = true;
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[2] = DOLLSYS_DOUBLEJUMP_FORCE;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        EmitSoundToClient(client, "ambient/energy/zap1.wav");
    }
}

// --- Heal Pulse ---
void DollSys_DoHealPulse(int client)
{
    float origin[3];
    GetClientAbsOrigin(client, origin);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != 2) continue;

        float pos[3];
        GetClientAbsOrigin(i, pos);

        if (GetVectorDistance(origin, pos) <= DOLL_HEALPULSE_RADIUS)
        {
            int hp = GetClientHealth(i);
            int maxHp = GetEntProp(i, Prop_Send, "m_iMaxHealth");
            if (hp < maxHp)
            {
                SetEntityHealth(i, hp + DOLL_HEALPULSE_AMOUNT);
            }
        }
    }
}

// --- Stun Aura (v2.1 "Aura Limpia") ---
// Dentro del radio: el IE se ralentiza (50%). Al salir del radio (o al
// apagarse el aura): recupera su velocidad normal. El slow ya NO queda
// pegado "por el resto de la partida".
// Guardas de compatibilidad: el aura solo escribe 0.5 sobre velocidades
// más rápidas que 0.5 (nunca pisa el Rompe-huesos de Amy, 0.2) y solo
// restaura 1.0 cuando el valor actual es exactamente 0.5 — la marca que
// el propio aura dejo (nunca toca congelamientos de 0.0 ni boosts
// 1.0-2.0 puestos por otros sistemas del server).
void DollSys_DoStunAura(int client)
{
    float origin[3];
    GetClientAbsOrigin(client, origin);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != 3) continue; // TEAM_INFECTED

        float pos[3];
        GetClientAbsOrigin(i, pos);
        float cur = GetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue");

        if (GetVectorDistance(origin, pos) <= DOLL_STUNAURA_RADIUS)
        {
            // Ralentizar al SI — solo si no arrastra un slow más fuerte
            // de otro sistema (Rompe-huesos 0.2 manda sobre el aura).
            if (cur > DOLL_STUNAURA_SLOW)
                SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", DOLL_STUNAURA_SLOW);
        }
        else if (cur == DOLL_STUNAURA_SLOW)
        {
            // Aura limpia: fuera del área vuelve a su velocidad normal.
            // (== 0.5 exacto: solo limpiamos el slow que el aura puso)
            SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 1.0);
        }
    }
}

// v2.1 (R28.2): barrido de limpieza del StunAura. Se invoca al APAGAR el
// poder en el menú (!mastery) y cuando la dueña se desconecta con el aura
// activa: la RunCmd ya no correra para limpiar, así que aquí se devuelve
// la velocidad normal a todo IE que quede exactamente a 0.5.
// Sin filtro de "vivo": los IE bots muertos (ghost) heredan el 0.5 del
// slot y al spawnear deben salir normales.
void DollSys_ClearStunAura()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        if (GetClientTeam(i) != 3) continue;
        if (GetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue") == DOLL_STUNAURA_SLOW)
            SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
}

// --- Detección de agarres ---
bool DollSys_IsBeingGrappled(int client)
{
    if (!IsPlayerAlive(client)) return false;
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return true;
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) return true;
    if (GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0) return true;
    if (GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0) return true;
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return true;
    return false;
}

// --- Limpiar agarres ---
void DollSys_CleanseGrapples(int client)
{
    if (!IsPlayerAlive(client)) return;

    int attacker = -1;

    attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
    if (attacker > 0)
    {
        SetEntPropEnt(attacker, Prop_Send, "m_pounceVictim", -1);
        SetEntPropEnt(client, Prop_Send, "m_pounceAttacker", -1);
    }

    attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
    if (attacker > 0)
    {
        SetEntPropEnt(attacker, Prop_Send, "m_tongueVictim", -1);
        SetEntPropEnt(client, Prop_Send, "m_tongueOwner", -1);
    }

    attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
    if (attacker > 0)
    {
        SetEntPropEnt(attacker, Prop_Send, "m_pummelVictim", -1);
        SetEntPropEnt(client, Prop_Send, "m_pummelAttacker", -1);
    }

    attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
    if (attacker > 0)
    {
        SetEntPropEnt(attacker, Prop_Send, "m_carryVictim", -1);
        SetEntPropEnt(client, Prop_Send, "m_carryAttacker", -1);
    }

    attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
    if (attacker > 0)
    {
        SetEntPropEnt(attacker, Prop_Send, "m_jockeyVictim", -1);
        SetEntPropEnt(client, Prop_Send, "m_jockeyAttacker", -1);
    }

    SetEntityMoveType(client, MOVETYPE_WALK);
}

// --- Detección de witch como atacante ---
bool DollSys_IsWitchAttacker(int attacker, int inflictor)
{
    int possibleWitch = (attacker > 0 && IsValidEntity(attacker)) ? attacker : inflictor;
    if (possibleWitch <= 0 || !IsValidEntity(possibleWitch)) return false;
    char cls[32];
    GetEntityClassname(possibleWitch, cls, sizeof(cls));
    return StrEqual(cls, "witch");
}

// --- PrintToChat con throttle (evita reliable stream overflow) ---
void DollSys_ThrottledChat(int client, const char[] format, any ...)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;
    if (IsFakeClient(client)) return;

    float now = GetEngineTime();
    if (now - g_fDollLastChatMsg[client] < 1.5) return;

    g_fDollLastChatMsg[client] = now;

    char buffer[256];
    VFormat(buffer, sizeof(buffer), format, 3);
    PrintToChat(client, "\x04[Mastery]\x01 %s", buffer);
}

// ============================================================================
//  API PÚBLICA — Funciones para usar desde otros plugins/includes
// ============================================================================

// ¿Tiene activado el Anti-Vómito? (API para Amy.inc)
// El manager incluye Amy.inc ANTES que este archivo, así que Amy no puede
// referenciar el enum DollPowers directo: se expone este wrapper (la
// llamada a función definida después sí resuelve, como Knuckles ->
// Amy_VomitCounter). El poder se activa/desactiva desde el menú
// (sm_mastery) y la preferencia persiste en cookie. Default ON para
// conservar el comportamiento fijo de v64-v68.
bool DollSys_AntiVomitoActive(int client)
{
    return Doll_IsPowerEnabled(client, DollPower_AntiVomito);
}
