/*
 * ============================================================================
 *  cstguard.inc — v3.0.0 "EMBEBIDO" — el CST-Guard + motor CST como INCLUDE
 * ============================================================================
 *
 *  QUE ES ESTO
 *  ---------------------------------------------------------------------------
 *  Todo el CST-Guard (identidad por señal, auto-guard ronda/spawn/AFK/defib/
 *  rescate, watchdog, motor de aplicacion VScript con reintentos, comandos
 *  sm_amy / sm_sonic / sm_rouge / sm_cstcheck / sm_cstsignal / ..., mapa
 *  personaje->cfg persistente) vive AHORA dentro de ESTE archivo. El plugin
 *  que lo incluye (tu Sonic Manager) se convierte en el unico dueño del
 *  guard: sin natives, sin forwards globales, sin señales que se pierden,
 *  sin "vista gorda" entre dos plugins con vidas separadas.
 *
 *  v3.0.0 reemplaza al cstguard.inc de natives (v2.x): MISMO nombre de
 *  archivo, MISMA firma de CSTGuard_Signal / CSTGuard_Clear / CSTGuard_Query,
 *  asi tu manager parcheado NO cambia sus llamadas — solo recompila.
 *
 *  ---------------------------------------------------------------------------
 *  INTEGRACION EN EL MANAGER (UNA linea + el forward que ya tenes)
 *  ---------------------------------------------------------------------------
 *   1) Reemplaza tu viejo scripting/include/cstguard.inc por ESTE archivo.
 *
 *   2) En el .sp del manager ya tenes (o agrega):
 *
 *          #include <cstguard>
 *
 *   3) En tu OnPluginStart(), agrega UNA linea (idealmente al final):
 *
 *          CSTGuard_Init();
 *
 *      Eso es TODO el wiring. Eventos, timers, watchdog, comandos y cvars se
 *      registran solos ahi. NO hace falta cablear OnMapStart,
 *      OnClientDisconnect ni nada mas.
 *
 *   4) Tus llamadas siguen IGUAL (misma firma de siempre):
 *
 *          CSTGuard_Signal(client, "amy");   // al ASIGNAR el personaje
 *          CSTGuard_Clear(client);           // al LIBERARLO
 *
 *   5) El forward de re-anuncio (tu manager ya lo implementa del parche
 *      v2.2.0 — si no lo tiene, pegalo):
 *
 *          public void CSTGuard_OnResyncRequested()
 *          {
 *              // re-enviar TODAS las señales activas:
 *              // if (g_iPersonaje[i] == PERSONAJE_AMY) CSTGuard_Signal(i, "amy");
 *              // ...
 *          }
 *
 *      El guard lo dispara al arrancar, en cada ronda (+6s) y con sm_cstsync.
 *      (Si no queres implementarlo: #define CSTGUARD_NO_RESYNC antes del
 *       #include <cstguard> y el guard compila igual sin pedir re-anuncio.)
 *
 *   6) NUEVO — fin de la "vista gorda": el manager puede exigir revision
 *      INMEDIATA (mismo frame, sin esperar al watchdog):
 *
 *          CSTGuard_Verify(client);   // "acabo de tocar a este jugador: revisalo AHORA"
 *          CSTGuard_VerifyAll();      // "acabo de aplicar mi magia: revisa a todos AHORA"
 *          CSTGuard_IsReady();        // el CST (VScript) esta montado?
 *
 *      Recomendado: llamá CSTGuard_Verify(client) justo despues de asignar/
 *      re-aplicar un personaje, y CSTGuard_VerifyAll() cuando tu manager
 *      termina su barrido de inicio de ronda.
 *
 *  ---------------------------------------------------------------------------
 *  ADVERTENCIA IMPORTANTE (anti-guard-doble)
 *  ---------------------------------------------------------------------------
 *  Cuando compiles tu manager con este include adentro, BORRA del server:
 *
 *      addons/sourcemod/plugins/cst_skinchange.smx
 *
 *  Si el guard vive embebido en el manager, el plugin suelto DUPLICA los
 *  comandos (sm_amy se dispararia dos veces por apply doble). Uno u otro,
 *  nunca los dos.
 *
 *  ---------------------------------------------------------------------------
 *  TODO LO DEMAS SIGUE IGUAL QUE v2.3.0
 *  ---------------------------------------------------------------------------
 *   - La señal EJECUTA EL COMANDO del personaje (sm_amy / sm_sonic / ...) en
 *     el contexto del jugador señalado (target = quien ejecuta, nivel 4).
 *   - Mapa personaje->cfg: data/cst_skinchange_maps.txt (mismo archivo).
 *   - Cvars: cfg/sourcemod/cst_skinchange.cfg (mismo archivo).
 *   - sm_cstcheck / sm_cstsignal / sm_cstsync / sm_cstguard_maps / sm_cstapply.
 *   - Identidad: L0 señal -> L1 registro CST -> L2 nombre -> L3 modelo ->
 *     L4 slot; herencia en swap AFK; watchdog cada cstguard_watchdog_sec.
 *   - Cambio de mapa: el estado se resetea en round_start (hook interno) y el
 *     watchdog se refresca ahi; la señal por steamid sobrevive reconexiones.
 *
 *  Identificá la build: sm_cstcheck debe mostrar
 *      "v3.0.4 (build 2026-10-13f)" y "MODO v3.0.0 EMBEBIDO".
 * ============================================================================
 */

#if defined _cstguard_included
 #endinput
#endif
#define _cstguard_included

#include <sourcemod>
#include <sdktools>

#define CSTG_VERSION      "3.1.0"
#define CSTG_BUILD        "2026-10-18a"

#define CSTG_MAX_MAPS     8
#define CSTG_MAX_CHARS    20
#define CSTG_PROF_LEN     48
#define CSTG_SLOT_LEN     16
#define CSTG_NAME_LEN     64

#define CSTG_EMS_PREFIX   "ems/Custom_Survivor_Takeover/profiles/"
#define CSTG_MAPS_FILE    "data/cst_skinchange_maps.txt"
#define CSTG_MAPS_MARKER  "[MAPA-OFICIAL]"   // v3.0.3: el archivo que lo lleva MANDA tal cual

#define CSTG_CS_MAX_WAITS 10
#define CSTG_CS_WAIT_SEC  3.0

#define CSTG_MAX_PENDING  8
#define CSTG_WHO_WAIT     0.3
#define CSTG_MAX_SEEN     20

// v3.1.0 — cache de perfiles + barrido inteligente
#define CSTG_PC_MAX        24    // perfiles en cache (14 oficiales + margen custom)
#define CSTG_PC_MODELS     12    // modelos por perfil (mismo tope del ExplodeString de siempre)
#define CSTG_GIVEUP_CYCLES 3     // barridos consecutivos con apply sin asentar antes de aceptar el estado

// ----------------------------------------------------------------------------
// plugin: NO hay myinfo en un include — lo aporta el plugin que INCLUYE
// (tu manager, o el wrapper cst_skinchange.sp del paquete)
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// slots vanilla (mismo conjunto que vanilla_models del CST)
// ----------------------------------------------------------------------------

static const char g_cstg_Slots[CSTG_MAX_MAPS][CSTG_SLOT_LEN] =
{
    "coach", "mechanic", "producer", "gambler",
    "namvet", "teenangst", "manager", "biker"
};

// nombre legible de cada slot (mismo orden que g_cstg_Slots) para el diagnostico
static const char g_cstg_SlotNames[CSTG_MAX_MAPS][CSTG_SLOT_LEN] =
{
    "Coach", "Ellis", "Rochelle", "Nick",
    "Bill", "Zoey", "Louis", "Francis"
};

// ----------------------------------------------------------------------------
// v3.0.4 MAPA OFICIAL: los 14 PERFILES CST del server. v3.0.3 sembro los 13
// de los VPK *_cst.vpk; v3.0.4 REINTEGRA a rouge (owner 2026-10-13: "rouge
// rouge_r.cfg si existe solo que se paso colocarla en la descarga" — el
// perfil rouge_r.cfg vive en el server aunque el VPK no viniera en el pack).
// Orden: personajes del manager primero (orden del menu), despues los 4
// modelos extra que NO son personaje del manager (solo comando manual).
//   sonic tails knuckles amy shadow rouge cream metal eggman sage | big blaze omega silver
// sally queda FUERA a proposito: NO trae modelo/perfil en CST (seleccion =
// el modelo stock queda intacto). sm_rouge NO colisiona con Rouge.inc
// (alla solo existen sm_rouge_kick/bomb/wave/sweep/counter).
// ----------------------------------------------------------------------------

#define CSTG_DEF_CHARS 14

static const char g_cstg_DefCharKeys[CSTG_DEF_CHARS][CSTG_SLOT_LEN] =
{
    "sonic", "tails", "knuckles", "amy", "shadow", "rouge",
    "cream", "metal", "eggman", "sage",
    "big", "blaze", "omega", "silver"
};
static const char g_cstg_DefCharCfgs[CSTG_DEF_CHARS][CSTG_PROF_LEN] =
{
    "sonic.cfg", "tails.cfg", "knuckles.cfg", "amy.cfg", "shadow.cfg", "rouge_r.cfg",
    "cream.cfg", "metal.cfg", "eggman.cfg", "sage.cfg",
    "big.cfg", "blaze.cfg", "omega.cfg", "silver.cfg"
};

// v3.0.3: claves cuyo sm_<clave> NO se registra porque el SUITE ya es dueno
// del comando. sm_sage = alias de sm_sageset en Sage.inc (ciclar sets de
// Sage NO debe re-aplicar el modelo). El perfil sage.cfg se aplica igual por
// la senal del manager (seleccion/recuerdo leen el perfil del MAPA, no el
// comando) y manualmente con sm_cstapply sage.cfg.
// sm_sonic NO va aqui: coexiste con Speed_sonic desde la v2.2 (callbacks
// encadenados, comportamiento aceptado por el owner).
static const char g_cstg_SuiteOwnedCmds[][CSTG_SLOT_LEN] = { "sage" };

// ----------------------------------------------------------------------------
// consulta de identidad al registro publico del manager (una sola cadena)
// respuesta: "idx:Nombre|idx:Nombre|..." ("?" = sin registro) -> cstguard_who
// v3.0.2 FIX CRITICO: Convars es un GLOBAL RAIZ del VM de VScript, NO un
// miembro de la tabla DirectorScript (patron del propio CST: el
// yeoh_survivor_model_changer.nut llama Convars.SetValue a secas). El
// write-back anterior con DirectorScript.Convars reventaba el script en
// silencio y la consulta who quedaba MUERTA (desde la v2.2).
// ----------------------------------------------------------------------------

static const char CSTG_WHO_SCRIPT[] = "if(\"Custom_Survivor_Takeover\" in DirectorScript){local pc=DirectorScript.Custom_Survivor_Takeover.Persistent_Characters;if(pc!=null){local o=\"\";local p=null;while(p=Entities.FindByClassname(p,\"player\")){if(!p.IsSurvivor())continue;if(NetProps.GetPropInt(p,\"m_iTeamNum\")!=2)continue;local i=pc.EntityIndices.find(p.GetEntityIndex());if(i!=null&&i>=pc.NewNames.len())i=null;if(o!=\"\")o+=\"|\";o+=(\"\"+p.GetEntityIndex())+\":\"+((i==null)?\"?\":(\"\"+pc.NewNames[i]));}Convars.SetValue(\"cstguard_who\",o);}}";

// ----------------------------------------------------------------------------
// estado (TODO static: privado de ESTE archivo; no choca con las variables
// del plugin que incluye, aunque se llamen igual)
// ----------------------------------------------------------------------------

// mapa slot -> perfil (legacy; indice = slot index)
static char   g_cstg_MapProfile[CSTG_MAX_MAPS][CSTG_PROF_LEN];
static bool   g_cstg_MapSet[CSTG_MAX_MAPS];

// mapa personaje -> perfil (indice paralelo)
static char   g_cstg_CharKeys[CSTG_MAX_CHARS][CSTG_SLOT_LEN];
static char   g_cstg_CharCfg[CSTG_MAX_CHARS][CSTG_PROF_LEN];
static int    g_cstg_CharCount = 0;

// identidad que el manager reporta por survivor (cache de la ultima consulta)
static char   g_cstg_ManagerName[MAXPLAYERS + 1][CSTG_NAME_LEN];

// cola de consultas who (merge por tag, una in-flight)
static char   g_cstg_PendTag[CSTG_MAX_PENDING][32];
static bool   g_cstg_PendAll[CSTG_MAX_PENDING];
static bool   g_cstg_PendFilter[CSTG_MAX_PENDING][MAXPLAYERS + 1];
static int    g_cstg_iPendHead    = 0;
static int    g_cstg_iPendCount   = 0;
static bool   g_cstg_bWhoInFlight = false;
static int    g_cstg_iWhoSerial   = 0;

// comandos dinamicos registrados: base -> perfil
static StringMap g_cstg_RegisteredCmds = null;

// cadena de aplicacion por cliente
static char   g_cstg_ApplyProfile[MAXPLAYERS + 1][CSTG_PROF_LEN];
static char   g_cstg_ApplyPreModel[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
static char   g_cstg_ApplyTargetName[MAXPLAYERS + 1][CSTG_NAME_LEN];
static int    g_cstg_ApplyAttempt[MAXPLAYERS + 1];
static int    g_cstg_ApplyCsWait[MAXPLAYERS + 1];
static bool   g_cstg_ApplyActive[MAXPLAYERS + 1];

// señal del manager (push): clave de personaje por cliente + por steamid
static char       g_cstg_SignalKey[MAXPLAYERS + 1][CSTG_SLOT_LEN];
static StringMap  g_cstg_SignalBySteam = null;
static int        g_cstg_iSignalCount  = 0;

// probe CST
static bool   g_cstg_bCstReady       = false;
static bool   g_cstg_bCstWarned      = false;
static ConVar g_cstg_hProbeConVar    = null;
static ConVar g_cstg_hWhoConVar      = null;

// barrido
static int    g_cstg_iSweepToken     = 0;

// v3.1.0 — BARRIDO INTELIGENTE (dirty flag): true = algo cambio desde el
// ultimo barrido LIMPIO y el watchdog debe volver a consultar; false = nada
// que verificar -> el watchdog NO dispara VScript (cero Squirrel en reposo).
// Se re-arma con cualquier evento que pueda mover un modelo (spawn, señal,
// apply, defib, rescate, reemplazo bot<->player, cambio de equipo, reload)
static bool   g_cstg_bDirty          = true;
static int    g_cstg_iAppliedCycles  = 0;     // barridos seguidos que dispararon apply
static bool   g_cstg_bSweepApplied   = false; // el barrido en curso disparo un apply?

// v3.1.0 — CACHE DE PERFILES: CSTG_ParseProfile lee el .cfg del DISCO y se
// llamaba desde CSTG_ModelMatchesCfg en CADA evaluacion (cada señal, cada
// spawn-check y cada who-query del watchdog) = I/O de disco periodico en
// el hilo del server (microstutters en listen server). El cache parsea UNA
// vez por archivo y valida por mtime: si el owner edita el cfg, se
// re-parsea solo en la siguiente evaluacion.
static char   g_cstg_PCKey    [CSTG_PC_MAX][CSTG_PROF_LEN];
static char   g_cstg_PCName   [CSTG_PC_MAX][CSTG_NAME_LEN];
static char   g_cstg_PCSlot   [CSTG_PC_MAX][CSTG_SLOT_LEN];
static char   g_cstg_PCModels [CSTG_PC_MAX][CSTG_PC_MODELS][PLATFORM_MAX_PATH];
static int    g_cstg_PCModelN [CSTG_PC_MAX];
static bool   g_cstg_PCEnabled[CSTG_PC_MAX];
static float  g_cstg_PCChance [CSTG_PC_MAX];
static bool   g_cstg_PCHasTo  [CSTG_PC_MAX];
static int    g_cstg_PCMTime  [CSTG_PC_MAX];
static bool   g_cstg_PCOK     [CSTG_PC_MAX];   // entrada valida (parseo exitoso)
static int    g_cstg_PCCount  = 0;

// watchdog (handle para refrescarlo por ronda y tomar cambios de intervalo)
static Handle g_cstg_hWatchdog       = null;

// anti-doble-arranque de CSTGuard_Init()
static bool   g_cstg_bBooted         = false;

// cvars
static ConVar g_cstg_cvAuto, g_cstg_cvHumans, g_cstg_cvRetries, g_cstg_cvRetryDelay, g_cstg_cvDelay, g_cstg_cvDebug, g_cstg_cvSignal;
static ConVar g_cstg_cvWatchdog, g_cstg_cvWatchdogSec, g_cstg_cvSweepMode;

// ============================================================================
// carga — UNA llamada: CSTGuard_Init() desde el OnPluginStart del manager.
// (No hay AskPluginLoad2 ni natives: en modo embebido no hacen falta.)
// ============================================================================

stock void CSTGuard_Init()
{
    if (g_cstg_bBooted)
    {
        LogMessage("[CST-Guard] CSTGuard_Init() ya corrio una vez: se ignora la llamada repetida (el guard ya vive en este plugin)");
        return;
    }
    g_cstg_bBooted = true;

    g_cstg_cvAuto       = CreateConVar("cstguard_auto",       "1",   "Auto-guard: aplicar el cfg del personaje cuando el modelo no corresponde (1=on)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cstg_cvHumans     = CreateConVar("cstguard_humans",     "1",   "Auto-guard incluye jugadores humanos (0 = solo bots)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cstg_cvRetries    = CreateConVar("cstguard_retries",    "3",   "Intentos por aplicacion antes de rendirse", FCVAR_NOTIFY, true, 1.0, true, 10.0);
    g_cstg_cvRetryDelay = CreateConVar("cstguard_retrydelay", "1.0", "Segundos entre verificacion y reintento", FCVAR_NOTIFY, true, 0.5, true, 5.0);
    g_cstg_cvDelay      = CreateConVar("cstguard_delay",      "0.5", "Demora tras spawn antes de evaluar el modelo", FCVAR_NOTIFY, true, 0.1, true, 5.0);
    g_cstg_cvDebug      = CreateConVar("cstguard_debug",      "0",   "Logs extendidos del guard", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cstg_cvSignal     = CreateConVar("cstguard_signal",     "1",   "Capa de señal del manager (natives CSTGuard_*): 1 = la señal es la autoridad", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cstg_cvWatchdog   = CreateConVar("cstguard_watchdog",     "1",    "Watchdog: barrido periodico que re-verifica personajes (solo actua si el modelo no corresponde)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cstg_cvWatchdogSec= CreateConVar("cstguard_watchdog_sec", "30.0", "Segundos entre barridos del watchdog", FCVAR_NOTIFY, true, 10.0, true, 120.0);
    g_cstg_cvSweepMode  = CreateConVar("cstguard_sweepmode",    "1",    "v3.1.0: 1 = barrido INTELIGENTE (el watchdog solo consulta si algo cambio desde el ultimo barrido limpio: cero VScript en reposo) / 0 = clasico (consulta en cada ciclo)", FCVAR_NOTIFY, true, 0.0, true, 1.0);

    g_cstg_hProbeConVar = CreateConVar("cstguard_probe", "0", "Handshake interno con el CST (lo escribe el VScript; no tocar)", FCVAR_DONTRECORD);
    g_cstg_hWhoConVar   = CreateConVar("cstguard_who",   "", "Identidad por survivor que reporta el manager (lo escribe el VScript; no tocar)", FCVAR_DONTRECORD);

    AutoExecConfig(true, "cst_skinchange");

    g_cstg_RegisteredCmds = new StringMap();
    g_cstg_SignalBySteam  = new StringMap();

    RegAdminCmd("sm_cstguard_maps",   CSTG_Cmd_Maps,   ADMFLAG_CONFIG,  "sm_cstguard_maps \"<clave>=<perfil.cfg>,...\" — define/lista el mapa (personajes y/o slots)");
    RegAdminCmd("sm_cstapply",        CSTG_Cmd_Apply,  ADMFLAG_GENERIC, "sm_cstapply <perfil.cfg> [nombre|#userid]");
    RegAdminCmd("sm_cstcheck",        CSTG_Cmd_Check,  ADMFLAG_GENERIC, "sm_cstcheck — diagnostico CST + mapas + identidades + survivors");
    RegAdminCmd("sm_cstguard_reload", CSTG_Cmd_Reload, ADMFLAG_CONFIG,  "sm_cstguard_reload — relee el archivo de mapas");
    RegAdminCmd("sm_cstsignal",       CSTG_Cmd_Signal, ADMFLAG_GENERIC, "sm_cstsignal <nombre|#userid> <clave|clear> — simula la señal del manager");
    RegAdminCmd("sm_cstsync",         CSTG_Cmd_Sync,   ADMFLAG_GENERIC, "sm_cstsync — dispara el re-anuncio (CSTGuard_OnResyncRequested)");
    RegAdminCmd("sm_cstguard",        CSTG_Cmd_Info,   ADMFLAG_GENERIC, "sm_cstguard — ayuda del guard");

    HookEvent("player_spawn",        CSTG_Event_PlayerSpawn);
    HookEvent("round_start",         CSTG_Event_RoundStart);
    HookEvent("player_bot_replace",  CSTG_Event_PlayerBotReplace); // se fue AFK: el bot toma el control
    HookEvent("bot_player_replace",  CSTG_Event_BotPlayerReplace); // vuelve el humano: toma el control
    HookEvent("defibrillator_used",  CSTG_Event_Defib);
    HookEvent("survivor_rescued",    CSTG_Event_Rescued);
    HookEvent("player_disconnect",   CSTG_Event_PlayerDisconnect);  // limpia la señal del indice que se va (hook interno)
    HookEvent("player_team",         CSTG_Event_PlayerTeam);        // v3.1.0: cambio de equipo -> re-evaluar (dirty)

    CSTG_LoadMapsFile();
    CSTG_RegisterDynamicFromMaps();

    // arranque en caliente: SIEMPRE (server recien booteado o reload del
    // manager a mitad de partida — si no hay nada pendiente, no pasa nada)
    CreateTimer(2.0, CSTG_Timer_LateProbe);
    CreateTimer(3.5, CSTG_Timer_LateSweep);
    CreateTimer(4.5, CSTG_Timer_ResyncRequest); // el manager re-anuncia

    // watchdog persistente (SIN NO_MAPCHANGE: vive en todos los mapas; el
    // round_start lo refresca para tomar cambios de cstguard_watchdog_sec)
    g_cstg_hWatchdog = CreateTimer(g_cstg_cvWatchdogSec.FloatValue, CSTG_Timer_Watchdog, _, TIMER_REPEAT);

    char hostName[64];
    if (!GetPluginInfo(GetMyHandle(), PlInfo_Name, hostName, sizeof(hostName)))
        strcopy(hostName, sizeof(hostName), "(plugin host)");

    LogMessage("[CST-Guard] v%s (build %s) EMBEBIDO en \"%s\" — guard + motor CST + MAPA OFICIAL de %d perfiles (sonic tails knuckles amy shadow rouge cream metal eggman sage big blaze omega silver); LLAMADA DIRECTA: la señal ejecuta el perfil EN EL ACTO; sally sin modelo = stock intacto; sm_sage queda para Sage.inc; v3.1.0 OPTIMIZACION: cache de perfiles (cero lectura de disco al evaluar) + barrido inteligente (cero VScript en reposo)", CSTG_VERSION, CSTG_BUILD, hostName, CSTG_DEF_CHARS);
}

// ============================================================================
// eventos -> auto-guard
// ============================================================================

public void CSTG_Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_cstg_cvAuto.BoolValue)
        return;

    int userid = event.GetInt("userid");
    CreateTimer(g_cstg_cvDelay.FloatValue, CSTG_Timer_SpawnCheck, userid);
}

public Action CSTG_Timer_SpawnCheck(Handle timer, any userid)
{
    if (!g_cstg_cvAuto.BoolValue)
        return Plugin_Stop;

    int client = GetClientOfUserId(userid);
    if (client < 1 || !IsClientInGame(client) || GetClientTeam(client) != 2)
        return Plugin_Stop;

    CSTG_EnqueueWho("auto-spawn", client);
    return Plugin_Stop;
}

public void CSTG_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // ---- estado por mapa/ronda (antes vivia en el OnMapStart del plugin; en
    // modo embebido lo maneja este hook interno: el manager NO cablea nada) ----
    // estado de clientes fuera (userids nuevos) + identidad sin estrenar.
    // Las SEÑALES del manager NO se limpian: sobreviven el cambio de mapa
    // (los indices de cliente persisten conectados) y el manager re-anuncia
    // de todas formas con el resync de abajo.
    for (int i = 1; i <= MaxClients; i++)
    {
        g_cstg_ApplyActive[i] = false;
        g_cstg_ManagerName[i][0] = '\0';
    }

    g_cstg_bCstReady = false;
    g_cstg_iSweepToken++;
    g_cstg_iWhoSerial++;       // invalida respuestas who pendientes
    g_cstg_iPendHead = 0;      // cola vacia
    g_cstg_iPendCount = 0;
    g_cstg_bWhoInFlight = false;

    CSTG_ProbeFire(2.0); // margen para que el CST re-confirme tras cargar el mapa

    // watchdog fresco: toma el intervalo actual de cstguard_watchdog_sec
    if (g_cstg_hWatchdog != null)
        delete g_cstg_hWatchdog;
    g_cstg_hWatchdog = CreateTimer(g_cstg_cvWatchdogSec.FloatValue, CSTG_Timer_Watchdog, _, TIMER_REPEAT);

    // barridos: +3.5s (despues del probe) y +8s (registros tardios del manager)
    CreateTimer(3.5, CSTG_Timer_RoundSweep, g_cstg_iSweepToken);
    CreateTimer(8.0, CSTG_Timer_RoundSweep, g_cstg_iSweepToken);

    // el manager re-anuncia a todos (+6s)
    CreateTimer(6.0, CSTG_Timer_ResyncRequest);
}

public Action CSTG_Timer_RoundSweep(Handle timer, any token)
{
    if (token != g_cstg_iSweepToken)
        return Plugin_Stop;

    CSTG_EnqueueWho("auto-ronda", 0);
    return Plugin_Stop;
}

public Action CSTG_Timer_LateSweep(Handle timer)
{
    CSTG_EnqueueWho("auto-late", 0);
    return Plugin_Stop;
}

// AFK: el humano se fue y el bot toma el control del survivor
public void CSTG_Event_PlayerBotReplace(Event event, const char[] name, bool dontBroadcast)
{
    int bot    = GetClientOfUserId(event.GetInt("bot"));
    int player = GetClientOfUserId(event.GetInt("player"));
    if (bot < 1)
        return;

    CSTG_Debug("player_bot_replace: humano %d se fue AFK; bot %d toma el control -> re-check +1.5s", player, bot);

    // la identidad del personaje se queda con el SURVIVOR: el bot la hereda
    if (player >= 1 && strlen(g_cstg_SignalKey[player]) > 0)
        strcopy(g_cstg_SignalKey[bot], sizeof(g_cstg_SignalKey[]), g_cstg_SignalKey[player]);

    CreateTimer(1.5, CSTG_Timer_Recheck, GetClientUserId(bot));
}

// el humano vuelve y toma el control del survivor
public void CSTG_Event_BotPlayerReplace(Event event, const char[] name, bool dontBroadcast)
{
    int bot    = GetClientOfUserId(event.GetInt("bot"));
    int player = GetClientOfUserId(event.GetInt("player"));
    if (player < 1)
        return;

    CSTG_Debug("bot_player_replace: humano %d vuelve y toma el control (bot %d afuera) -> re-check +1.5s", player, bot);

    // el humano retoma su survivor: hereda la señal del bot si no tenia una
    if (strlen(g_cstg_SignalKey[player]) == 0 && bot >= 1 && strlen(g_cstg_SignalKey[bot]) > 0)
        strcopy(g_cstg_SignalKey[player], sizeof(g_cstg_SignalKey[]), g_cstg_SignalKey[bot]);

    CreateTimer(1.5, CSTG_Timer_Recheck, GetClientUserId(player));
}

public void CSTG_Event_Defib(Event event, const char[] name, bool dontBroadcast)
{
    int subject = GetClientOfUserId(event.GetInt("subject"));
    if (subject < 1)
        return;

    CSTG_Debug("defibrillator_used: %N revivido -> re-check +2.0s", subject);
    CreateTimer(2.0, CSTG_Timer_Recheck, GetClientUserId(subject));
}

public void CSTG_Event_Rescued(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("victim"));
    if (victim < 1)
        return;

    CSTG_Debug("survivor_rescued: %N rescatado -> re-check +2.0s", victim);
    CreateTimer(2.0, CSTG_Timer_Recheck, GetClientUserId(victim));
}

public Action CSTG_Timer_Recheck(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || !IsClientInGame(client) || GetClientTeam(client) != 2)
        return Plugin_Stop;

    // volver a llamar al CST si el personaje no coincide con lo que lleva
    CSTG_EnqueueWho("auto-recheck", client);
    return Plugin_Stop;
}

// ============================================================================
// motor de identidad: consulta al registro publico del manager (quien es quien)
// ============================================================================

// tag + client (0 = todos los survivors). Merge por tag; una consulta in-flight.
void CSTG_EnqueueWho(const char[] tag, int client)
{
    if (!g_cstg_bCstReady)
        return; // sin CST montado no hay registro publico que consultar

    int entry = -1;
    for (int i = 0; i < g_cstg_iPendCount; i++)
    {
        int e = (g_cstg_iPendHead + i) % CSTG_MAX_PENDING;
        if (strcmp(g_cstg_PendTag[e], tag) == 0)
        {
            entry = e;
            break;
        }
    }

    if (entry < 0)
    {
        if (g_cstg_iPendCount < CSTG_MAX_PENDING)
        {
            entry = (g_cstg_iPendHead + g_cstg_iPendCount) % CSTG_MAX_PENDING;
            strcopy(g_cstg_PendTag[entry], sizeof(g_cstg_PendTag[]), tag);
            g_cstg_PendAll[entry] = false;
            for (int c = 0; c <= MaxClients; c++)
                g_cstg_PendFilter[entry][c] = false;
            g_cstg_iPendCount++;
        }
        else
        {
            entry = g_cstg_iPendHead; // cola llena: la entrada mas vieja absorve (conserva su tag)
        }
    }

    if (client <= 0)
        g_cstg_PendAll[entry] = true;
    else if (client <= MaxClients)
        g_cstg_PendFilter[entry][client] = true;

    CSTG_PumpWho();
}

void CSTG_PumpWho()
{
    if (g_cstg_bWhoInFlight || g_cstg_iPendCount == 0)
        return;

    g_cstg_bWhoInFlight = true;
    g_cstg_iWhoSerial++;

    // limpiar el canal: si el script falla, la respuesta queda vacia y se cae
    // a las capas sync en vez de parsear una respuesta vieja
    g_cstg_hWhoConVar.SetString("", false);

    SetVariantString(CSTG_WHO_SCRIPT);
    AcceptEntityInput(0, "RunScriptCode"); // worldspawn, patron del propio CST

    CreateTimer(CSTG_WHO_WAIT, CSTG_Timer_WhoReadback, g_cstg_iWhoSerial);
}

public Action CSTG_Timer_WhoReadback(Handle timer, any serial)
{
    g_cstg_bWhoInFlight = false;

    if (serial != g_cstg_iWhoSerial)
        return Plugin_Stop; // llego una nueva consulta: esta respuesta es vieja

    CSTG_ParseWhoAnswer();

    if (g_cstg_iPendCount > 0)
    {
        char tag[32];
        strcopy(tag, sizeof(tag), g_cstg_PendTag[g_cstg_iPendHead]);

        bool all = g_cstg_PendAll[g_cstg_iPendHead];
        bool filter[MAXPLAYERS + 1];
        for (int c = 0; c <= MaxClients; c++)
            filter[c] = g_cstg_PendFilter[g_cstg_iPendHead][c];

        g_cstg_iPendHead = (g_cstg_iPendHead + 1) % CSTG_MAX_PENDING;
        g_cstg_iPendCount--;

        // v3.1.0: el estado de "limpio" se decide aqui — un barrido del
        // watchdog termina LIMPIO si ninguna evaluacion disparo un apply.
        // Limpio -> el watchdog entra en reposo (cero VScript) hasta el
        // proximo evento. Con apply -> sigue sucio y re-intenta, con tope
        // de CSTG_GIVEUP_CYCLES ciclos seguidos para no entrar en un bucle
        // infinito de applies cuando un perfil nunca asienta (cfg roto,
        // takeover vacio): a partir de ahi se acepta el estado hasta el
        // proximo evento (spawn/señal/etc lo re-intenta de todos modos).
        bool sweepWatch = (strcmp(tag, "watchdog") == 0);
        if (sweepWatch)
            g_cstg_bSweepApplied = false;

        for (int c = 1; c <= MaxClients; c++)
        {
            if (!all && !filter[c])
                continue;
            CSTG_EvaluateClient(c, tag);
        }

        if (sweepWatch)
        {
            if (!g_cstg_bSweepApplied)
            {
                g_cstg_bDirty = false;
                g_cstg_iAppliedCycles = 0;
                CSTG_Debug("barrido watchdog LIMPIO: reposo hasta el proximo evento");
            }
            else
            {
                g_cstg_iAppliedCycles++;
                if (g_cstg_iAppliedCycles >= CSTG_GIVEUP_CYCLES)
                {
                    g_cstg_bDirty = false;
                    g_cstg_iAppliedCycles = 0;
                    LogMessage("[CST-Guard] v3.1.0: %d barridos seguidos con apply sin asentar (perfil/cfg que no cambia el modelo): se acepta el estado hasta el proximo evento — revisa sm_cstcheck (cfg existente + takeovers no vacios)", CSTG_GIVEUP_CYCLES);
                }
            }
        }
    }

    CSTG_PumpWho(); // sigue con la siguiente consulta encolada
    return Plugin_Stop;
}

// "idx:Nombre|idx:Nombre|..." -> cache g_cstg_ManagerName[client] (idx == indice de
// entidad == indice de cliente para players en Source)
void CSTG_ParseWhoAnswer()
{
    char raw[512];
    g_cstg_hWhoConVar.GetString(raw, sizeof(raw));
    if (strlen(raw) == 0)
        return; // script fallo o sin survivors: se quedan las capas sync

    char pieces[12][CSTG_NAME_LEN];
    int n = ExplodeString(raw, "|", pieces, sizeof(pieces), sizeof(pieces[]));

    for (int i = 0; i < n; i++)
    {
        int colon = FindCharInString(pieces[i], ':');
        if (colon <= 0)
            continue;

        pieces[i][colon] = '\0';
        int idx = StringToInt(pieces[i]);
        if (idx < 1 || idx > MaxClients)
            continue;

        strcopy(g_cstg_ManagerName[idx], CSTG_NAME_LEN, pieces[i][colon + 1]);
    }
}

// ============================================================================
// evaluacion: quien ES este survivor y su modelo le corresponde?
// ============================================================================

void CSTG_EvaluateClient(int client, const char[] tag)
{
    if (!g_cstg_cvAuto.BoolValue || !g_cstg_bCstReady)
        return;
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || GetClientTeam(client) != 2)
        return;
    if (!IsFakeClient(client) && !g_cstg_cvHumans.BoolValue)
        return;

    char model[PLATFORM_MAX_PATH];
    GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));

    char who[CSTG_NAME_LEN];
    GetClientName(client, who, sizeof(who));

    // ---- quien ES? L0 señal del manager (push) -> L1 registro CST -> L2 nombre -> L3 modelo ----
    int  k   = -1;
    char via[24];
    via[0] = '\0';

    char sig[CSTG_SLOT_LEN];
    CSTG_SignalOf(client, sig, sizeof(sig)); // indice + fallback steamid

    if (g_cstg_cvSignal.BoolValue && strlen(sig) > 0)
    {
        k = CSTG_SignalKeyIndex(sig);
        if (k >= 0)
            strcopy(via, sizeof(via), "señal");
        else
        {
            // identidad conocida pero SIN cfg (metal/sally/eggman): autoridad
            // del manager -> no se adivina por capas sync, no se toca nada
            CSTG_Debug("%s ES \"%s\" (señal del manager, sin cfg): no se toca", who, sig);
            return;
        }
    }

    if (strlen(g_cstg_ManagerName[client]) > 0)
    {
        k = CSTG_KeyOfIdentity(g_cstg_ManagerName[client]);
        if (k >= 0)
            strcopy(via, sizeof(via), "manager");
    }

    if (k < 0)
    {
        k = CSTG_KeyOfIdentity(who);
        if (k >= 0)
            strcopy(via, sizeof(via), IsFakeClient(client) ? "nombre-bot" : "nombre");
    }

    if (k < 0)
    {
        k = CSTG_KeyOfModel(model);
        if (k >= 0)
            strcopy(via, sizeof(via), "modelo");
    }

    // ---- el personaje tiene cfg: el modelo le TIENE que corresponder ----
    if (k >= 0)
    {
        if (CSTG_ModelMatchesCfg(model, g_cstg_CharCfg[k]))
        {
            CSTG_Debug("%s ES \"%s\" (via %s): el modelo ya corresponde a %s, no se toca",
                       who, g_cstg_CharKeys[k], via, g_cstg_CharCfg[k]);
            return;
        }

        char identity[CSTG_NAME_LEN];
        if (strcmp(via, "señal") == 0)
            strcopy(identity, sizeof(identity), sig);
        else
            strcopy(identity, sizeof(identity), (strlen(g_cstg_ManagerName[client]) > 0) ? g_cstg_ManagerName[client] : who);

        LogMessage("[CST-Guard] %s -> %s : ES \"%s\" (via %s) pero lleva %s -> debe machear con %s",
                   tag, who, identity, via, model, g_cstg_CharCfg[k]);
        // v2.3.0: mismo nucleo que la señal — se ejecuta el COMANDO del
        // personaje (sm_<clave>) en el contexto de este survivor
        CSTG_RunPlayerCommand(client, k, tag);
        return;
    }

    // ---- L4 legacy: slot con modelo stock (comportamiento 2.0.x) ----
    int slot = CSTG_SlotOfModel(model);
    if (slot >= 0 && g_cstg_MapSet[slot])
    {
        CSTG_ApplyStart(client, g_cstg_MapProfile[slot], tag, who);
        return;
    }

    CSTG_Debug("%s: no es un personaje mapeado (manager=\"%s\") ni slot stock mapeado -> no se toca",
               who, g_cstg_ManagerName[client]);
}

// la clave es prefijo-de-palabra del nombre: "Amy Rose"->amy, "Metal Sonic" NO es sonic
int CSTG_KeyOfIdentity(const char[] name)
{
    if (strlen(name) == 0)
        return -1;

    for (int k = 0; k < g_cstg_CharCount; k++)
    {
        if (StrContains(name, g_cstg_CharKeys[k], false) != 0)
            continue; // no empieza con la clave

        int klen = strlen(g_cstg_CharKeys[k]);
        char c = name[klen];
        if (c == '\0' || c == ' ' || c == '-' || c == '_' || c == '.')
            return k; // frontera de palabra: fin, espacio, guion, guion bajo, punto
    }
    return -1;
}

// primera palabra del basename del .mdl: amy_rose.mdl->amy; metal_sonic.mdl->metal
int CSTG_KeyOfModel(const char[] model)
{
    int slash = FindCharInString(model, '/', true);
    char base[PLATFORM_MAX_PATH];
    strcopy(base, sizeof(base), model[slash + 1]);

    for (int i = 0; base[i] != '\0'; i++)
        if (base[i] >= 'A' && base[i] <= 'Z')
            base[i] += 32;

    for (int i = 0; base[i] != '\0'; i++)
    {
        char c = base[i];
        if (c == '_' || c == '-' || c == '.')
        {
            base[i] = '\0';
            break;
        }
    }

    if (strlen(base) == 0)
        return -1;

    for (int k = 0; k < g_cstg_CharCount; k++)
        if (strcmp(base, g_cstg_CharKeys[k]) == 0)
            return k;

    return -1;
}

// el modelo actual esta en random_models del cfg? (si no se puede leer el cfg,
// dejamos que aplique: la verificacion por cambio de modelo sigue corriendo)
bool CSTG_ModelMatchesCfg(const char[] model, const char[] profile)
{
    // v3.1.0 OPTIMIZACION: antes esto abria el .cfg del DISCO y hacia
    // ExplodeString en CADA llamada (cada señal, cada spawn-check y cada
    // who-query del watchdog = I/O periodico en el hilo del server,
    // microstutters en listen server). Ahora: una sola pasada por el
    // CSTG_ProfileCached (cache validado por mtime) y comparacion directa
    // contra la lista PRE-EXPLOTADA en memoria.
    char pname[CSTG_NAME_LEN], pslot[CSTG_SLOT_LEN], pmodels[512];
    bool enabled, hasTo; float chance;
    int nModels;

    if (!CSTG_ProfileCached(profile, pname, sizeof(pname), pslot, sizeof(pslot),
                            enabled, chance, pmodels, sizeof(pmodels), nModels, hasTo))
        return false;

    if (nModels == 0)
        return false; // sin lista de modelos no hay confirmacion posible

    int e = CSTG_ProfileCacheFind(profile);
    if (e < 0)
        return false;

    for (int m = 0; m < g_cstg_PCModelN[e]; m++)
        if (strcmp(g_cstg_PCModels[e][m], model) == 0)
            return true;

    return false;
}

// ============================================================================
// v3.1.0 — CACHE DE PERFILES (cero I/O de disco al evaluar)
// ============================================================================

int CSTG_ProfileCacheFind(const char[] profile)
{
    for (int e = 0; e < g_cstg_PCCount; e++)
        if (strcmp(g_cstg_PCKey[e], profile) == 0)
            return e;
    return -1;
}

void CSTG_ProfileCacheFlush()
{
    g_cstg_PCCount = 0;
}

// parsea (o re-parsea) y llena la entrada e del cache
bool CSTG_ProfileCacheFill(int e, const char[] profile)
{
    char pname[CSTG_NAME_LEN], pslot[CSTG_SLOT_LEN], pmodels[512];
    bool enabled, hasTo; float chance;
    int nModels;

    bool ok = CSTG_ParseProfile(profile, pname, sizeof(pname), pslot, sizeof(pslot),
                                enabled, chance, pmodels, sizeof(pmodels), nModels, hasTo);

    strcopy(g_cstg_PCKey[e],  CSTG_PROF_LEN, profile);
    strcopy(g_cstg_PCName[e], CSTG_NAME_LEN, pname);
    strcopy(g_cstg_PCSlot[e], CSTG_SLOT_LEN, pslot);
    g_cstg_PCEnabled[e] = enabled;
    g_cstg_PCChance[e]  = chance;
    g_cstg_PCHasTo[e]   = hasTo;

    g_cstg_PCModelN[e] = 0;
    if (ok && nModels > 0)
    {
        char tmp[CSTG_PC_MODELS][PLATFORM_MAX_PATH];
        int nM = ExplodeString(pmodels, " ", tmp, sizeof(tmp), sizeof(tmp[]));
        if (nM > CSTG_PC_MODELS) nM = CSTG_PC_MODELS;
        for (int m = 0; m < nM; m++)
            strcopy(g_cstg_PCModels[e][m], PLATFORM_MAX_PATH, tmp[m]);
        g_cstg_PCModelN[e] = nM;
    }

    char path[PLATFORM_MAX_PATH];
    Format(path, sizeof(path), "%s%s", CSTG_EMS_PREFIX, profile);
    g_cstg_PCMTime[e] = FileExists(path) ? GetFileTime(path, FileTime_LastChange) : 0;
    g_cstg_PCOK[e]    = ok;
    return ok;
}

// WRAPPER con la MISMA FIRMA de CSTG_ParseProfile: primera llamada lee el
// disco; las siguientes responden desde memoria (re-parse solo si el mtime
// del archivo cambio — el owner puede editar el cfg en caliente y el cache
// lo nota solo). Un perfil que NO existe se cachea como fallo, pero revive
// solo si aparece despues (mtime 0 -> real).
bool CSTG_ProfileCached(const char[] profile,
                        char[] outName, int nameLen,
                        char[] outSlot, int slotLen,
                        bool &enabled, float &chance,
                        char[] outModels, int modelsLen,
                        int &modelCount, bool &hasTakeovers)
{
    int e = CSTG_ProfileCacheFind(profile);
    if (e < 0)
    {
        if (g_cstg_PCCount >= CSTG_PC_MAX)
            CSTG_ProfileCacheFlush();   // presupuesto agotado: recicla (14 oficiales + custom girando)
        e = g_cstg_PCCount;
        g_cstg_PCCount++;
        CSTG_ProfileCacheFill(e, profile);
    }
    else
    {
        char path[PLATFORM_MAX_PATH];
        Format(path, sizeof(path), "%s%s", CSTG_EMS_PREFIX, profile);
        int mt = FileExists(path) ? GetFileTime(path, FileTime_LastChange) : 0;
        if (mt != g_cstg_PCMTime[e])
            CSTG_ProfileCacheFill(e, profile);   // el cfg cambio en disco: re-parsear
    }

    strcopy(outName, nameLen, g_cstg_PCName[e]);
    strcopy(outSlot, slotLen, g_cstg_PCSlot[e]);
    enabled      = g_cstg_PCEnabled[e];
    chance       = g_cstg_PCChance[e];
    hasTakeovers = g_cstg_PCHasTo[e];
    modelCount   = g_cstg_PCModelN[e];

    outModels[0] = '\0';
    for (int m = 0; m < g_cstg_PCModelN[e]; m++)
    {
        if (m > 0) StrCat(outModels, modelsLen, " ");
        StrCat(outModels, modelsLen, g_cstg_PCModels[e][m]);
    }

    return g_cstg_PCOK[e];
}

// ============================================================================
// API DEL MANAGER (EMBEBIDA): stocks con la MISMA firma del cstguard.inc v2.x
// — el manager NO cambia sus llamadas; ahora ejecutan directo en el mismo
// plugin (cero natives, cero saltos entre plugins, cero señales perdidas)
// ============================================================================

/**
 * Señal push: "este client ES este personaje" (misma firma de siempre).
 * Registra la identidad (indice + steamid) y, si el personaje tiene cfg y el
 * modelo actual no corresponde, EJECUTA el comando del personaje (sm_amy /
 * sm_sonic / ...) en su contexto. Para no-admins y bots tambien.
 * v3.0.2: LLAMADA DIRECTA — sin esperar al probe del CST ni a las capas
 * auto. Y si el cliente aun no esta in-game (cookie al reconectar), la
 * identidad se registra igual y la llamada sale en su primer spawn.
 *
 * @return true si el guard recibio la señal.
 */
stock bool CSTGuard_Signal(int client, const char[] characterKey)
{
    if (!g_cstg_bBooted)
    {
        // v3.0.1: llamada ANTES de CSTGuard_Init() (p.ej. late-load del host
        // señalando antes de arrancar el guard): se ignora a proposito en
        // vez de reventar con handles nulos. El re-anuncio del guard
        // (+4.5s) re-establece las señales de todos modos.
        LogMessage("[CST-Guard] señal para el cliente %d ANTES de CSTGuard_Init(): ignorada (arranca el guard antes de señalizar; el re-anuncio la repone)", client);
        return false;
    }

    if (client < 1 || client > MaxClients || !IsClientConnected(client))
    {
        LogMessage("[CST-Guard] señal ignorada: cliente %d invalido o no conectado", client);
        return false;
    }

    if (strlen(characterKey) == 0)
        return false;

    // v3.0.2 — "cuando el jugador RECUERDE": la cookie puede cargar ANTES de
    // que el cliente entre al juego (reconexion). La identidad se registra
    // IGUAL (indice + steamid) y la llamada directa sale en su primer spawn
    // (la evaluacion L0 del spawn pesca esta señal guardada).
    if (!IsClientInGame(client))
    {
        char keyN[CSTG_SLOT_LEN];
        strcopy(keyN, sizeof(keyN), characterKey);
        TrimString(keyN);
        for (int i = 0; keyN[i] != '\0'; i++)
        {
            if (keyN[i] >= 'A' && keyN[i] <= 'Z')
                keyN[i] += 32;
            else if (keyN[i] == ' ')
                keyN[i] = '_';
        }
        if (strlen(keyN) == 0)
            return false;

        strcopy(g_cstg_SignalKey[client], CSTG_SLOT_LEN, keyN);
        if (!IsFakeClient(client) && IsClientAuthorized(client))
        {
            char sid[64];
            if (GetClientAuthId(client, AuthId_Steam2, sid, sizeof(sid)))
                g_cstg_SignalBySteam.SetString(sid, keyN, true);
        }
        g_cstg_iSignalCount++;
        CSTGuard_MarkDirty("señal del manager");   // v3.1.0: la autoridad cambio -> re-verificar
        LogMessage("[CST-Guard] señal: cliente %d ES \"%s\" (aun no in-game): identidad registrada, se aplicara en su primer spawn", client, keyN);
        return true;
    }

    return CSTG_HandleSignal(client, characterKey, "señal");
}

/**
 * El personaje fue removido de este client (vuelve a stock / se libera).
 * El guard olvida la identidad y deja de re-aplicar su cfg.
 */
stock bool CSTGuard_Clear(int client)
{
    if (!g_cstg_bBooted)
        return false;   // v3.0.1: guard sin arrancar — nada que limpiar (handles nulos)

    if (client < 1 || client > MaxClients)
        return false;

    g_cstg_SignalKey[client][0] = '\0';

    if (IsClientInGame(client) && !IsFakeClient(client) && IsClientAuthorized(client))
    {
        char sid[64];
        if (GetClientAuthId(client, AuthId_Steam2, sid, sizeof(sid)))
            g_cstg_SignalBySteam.Remove(sid);
    }

    CSTG_Debug("señal limpiada para el cliente %d", client);
    CSTGuard_MarkDirty("señal limpiada");   // v3.1.0
    return true;
}

/**
 * Que señal tiene este client segun el guard? (ultima señal recibida).
 *
 * @return true si el guard conoce la señal del client.
 */
stock bool CSTGuard_Query(int client, char[] buffer, int maxlen)
{
    buffer[0] = '\0';
    if (!g_cstg_bBooted)
        return false;   // v3.0.1: guard sin arrancar — no hay señales registradas

    if (client < 1 || client > MaxClients)
        return false;

    CSTG_SignalOf(client, buffer, maxlen);
    return strlen(buffer) > 0;
}

/**
 * NUEVO v3.0.0 — fin de la "vista gorda": el manager acaba de tocar a este
 * jugador (asignarle/re-aplicarle personaje, modelo, lo que sea) y le exige
 * al guard que lo revise AHORA MISMO (mismo frame, sin esperar al watchdog).
 * Si hay descoincidencia personaje/cfg vs modelo, se ejecuta el comando del
 * personaje en su contexto. Respeta cstguard_auto / cstguard_signal.
 */
stock bool CSTGuard_Verify(int client)
{
    if (!g_cstg_bBooted)
        return false;   // v3.0.1: guard sin arrancar — nada que verificar

    if (client < 1 || client > MaxClients || !IsClientInGame(client))
        return false;

    CSTG_EvaluateClient(client, "manager-verify");
    return true;
}

/**
 * NUEVO v3.0.0 — idem CSTGuard_Verify pero para TODOS los survivors.
 * Llamarlo cuando el manager termina su propio barrido (ej: re-aplicar
 * personajes en inicio de ronda).
 */
stock void CSTGuard_VerifyAll()
{
    if (!g_cstg_bBooted)
        return;   // v3.0.1: guard sin arrancar — nada que verificar

    for (int c = 1; c <= MaxClients; c++)
        CSTG_EvaluateClient(c, "manager-verify");
}

/**
 * NUEVO v3.0.0 — el CST (Custom_Survivor_Takeover) esta montado en VScript?
 */
stock bool CSTGuard_IsReady()
{
    return g_cstg_bCstReady;
}

// nucleo compartido por el stock CSTGuard_Signal y por sm_cstsignal
bool CSTG_HandleSignal(int client, const char[] rawKey, const char[] source)
{
    // normalizar: lowercase, espacios -> '_', recorte
    char key[CSTG_SLOT_LEN];
    strcopy(key, sizeof(key), rawKey);
    TrimString(key);
    for (int i = 0; key[i] != '\0'; i++)
    {
        if (key[i] >= 'A' && key[i] <= 'Z')
            key[i] += 32;
        else if (key[i] == ' ')
            key[i] = '_';
    }
    if (strlen(key) == 0)
        return false;

    // registro doble: indice de cliente + steamid (reconexiones)
    strcopy(g_cstg_SignalKey[client], CSTG_SLOT_LEN, key);
    if (!IsFakeClient(client) && IsClientAuthorized(client))
    {
        char sid[64];
        if (GetClientAuthId(client, AuthId_Steam2, sid, sizeof(sid)))
            g_cstg_SignalBySteam.SetString(sid, key, true);
    }
    g_cstg_iSignalCount++;
    CSTGuard_MarkDirty("señal del manager");   // v3.1.0: la autoridad cambio -> re-verificar

    char who[CSTG_NAME_LEN];
    GetClientName(client, who, sizeof(who));

    int k = CSTG_SignalKeyIndex(key);
    if (k < 0)
    {
        // personaje sin cfg (metal/sally/eggman...): identidad sola, no se toca
        LogMessage("[CST-Guard] %s: %s ES \"%s\" (sin cfg mapeado: solo identidad, no se toca el CST)", source, who, key);
        return true;
    }

    LogMessage("[CST-Guard] %s: %s ES \"%s\" -> %s", source, who, key, g_cstg_CharCfg[k]);

    // v3.0.2 — LLAMADA DIRECTA (pedido del owner: "cuando se seleccione un
    // personaje se llamara directamente el sm_<cfg disponible>"): la señal
    // del manager es la AUTORIDAD y se ejecuta EN EL ACTO. El bloqueo antiguo
    // (signal && auto && bCstReady) moria siempre en bCstReady: el write-back
    // del probe usaba DirectorScript.Convars (INEXISTENTE: Convars es global
    // raiz del VM), asi que el probe nunca confirmaba y la señal quedaba
    // registrada sin ejecutar NADA. Esa era la "vista gorda".
    if (!g_cstg_cvSignal.BoolValue)
    {
        LogMessage("[CST-Guard] %s: señal registrada pero cstguard_signal=0: no se ejecuta el comando", who);
        return true;
    }

    char model[PLATFORM_MAX_PATH];
    GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));

    if (CSTG_ModelMatchesCfg(model, g_cstg_CharCfg[k]))
    {
        // log VISIBLE a proposito: cero decisiones invisibles
        LogMessage("[CST-Guard] %s ya lleva un modelo de %s: señal satisfecha, no se re-aplica", who, g_cstg_CharCfg[k]);
        return true;
    }

    // LLAMADA DIRECTA: sm_<clave> (sm_amy / sm_sonic / sm_rouge / ...) en el
    // CONTEXTO del jugador señalado — seleccion y recuerdo, mismo frame.
    // ApplyStart trae reintentos propios si el CST aun esta montando.
    CSTG_RunPlayerCommand(client, k, source);
    return true;
}

// la clave matchea el mapa de personajes? exacto o por frontera de palabra
// ("amy_rose" -> amy si amy esta mapeado). -1 = personaje sin cfg
int CSTG_SignalKeyIndex(const char[] key)
{
    if (strlen(key) == 0)
        return -1;

    for (int k = 0; k < g_cstg_CharCount; k++)
        if (strcmp(key, g_cstg_CharKeys[k]) == 0)
            return k;

    for (int k = 0; k < g_cstg_CharCount; k++)
    {
        int klen = strlen(g_cstg_CharKeys[k]);
        if (strncmp(key, g_cstg_CharKeys[k], klen, false) != 0)
            continue;

        char c = key[klen];
        if (c == '\0' || c == '_' || c == '-' || c == ' ')
            return k;
    }
    return -1;
}

// señal del cliente: por indice, con fallback a su steamid
void CSTG_SignalOf(int client, char[] out, int maxLen)
{
    out[0] = '\0';
    if (client < 1 || client > MaxClients)
        return;

    strcopy(out, maxLen, g_cstg_SignalKey[client]);
    if (strlen(out) > 0)
        return;

    if (IsClientInGame(client) && !IsFakeClient(client) && IsClientAuthorized(client))
    {
        char sid[64];
        if (GetClientAuthId(client, AuthId_Steam2, sid, sizeof(sid)))
            g_cstg_SignalBySteam.GetString(sid, out, maxLen);
    }
}

// dispara CSTGuard_OnResyncRequested(): el manager re-anuncia a todos.
// EMBEBIDO: llamada DIRECTA al forward del propio plugin (mismo plugin,
// cero forwards globales, cero listeners que contar).
// Si el host no implementa el forward, compila con CSTGUARD_NO_RESYNC.
void CSTG_RequestResync()
{
    CSTG_Debug("re-anuncio pedido (CSTGuard_OnResyncRequested, embebido)");
#if !defined CSTGUARD_NO_RESYNC
    CSTGuard_OnResyncRequested();
#endif
}

public Action CSTG_Timer_ResyncRequest(Handle timer)
{
    CSTG_RequestResync();
    return Plugin_Stop;
}

// ============================================================================
// v2.3.0 LA SEÑAL EJECUTA EL COMANDO DEL JUGADOR
// (pedido del owner: "ejecutar el comando del jugador usando el contexto del
// comando que diste, sea sm_amy o sm_sonic")
// ============================================================================

// Ejecuta el comando dinamico sm_<clave> (sm_amy, sm_sonic, sm_rouge, ...)
// EN EL CONTEXTO de <client>: el MISMO perfil registrado del comando y el
// MISMO motor de aplicacion/verificacion/reintentos que si lo hubiera
// tipeado. El target es quien "ejecuta" el comando (el jugador señalado),
// igual que el nivel 4 de sm_<clave> — por eso funciona no importa en cual
// de los 8 avatars este. Este camino NO pasa por el chequeo de admin: la
// señal del manager es de confianza y tiene que funcionar igual para
// jugadores no-admin y bots.
bool CSTG_RunPlayerCommand(int client, int k, const char[] tag)
{
    if (k < 0 || k >= g_cstg_CharCount)
        return false;

    char base[CSTG_SLOT_LEN], profile[CSTG_PROF_LEN];
    strcopy(base,    sizeof(base),    g_cstg_CharKeys[k]);
    strcopy(profile, sizeof(profile), g_cstg_CharCfg[k]);

    // el perfil REGISTRADO del comando manda: es lo que sm_<clave> usaria
    char regProfile[CSTG_PROF_LEN];
    if (g_cstg_RegisteredCmds.GetString(base, regProfile, sizeof(regProfile)))
        strcopy(profile, sizeof(profile), regProfile);

    char name[CSTG_NAME_LEN];
    GetClientName(client, name, sizeof(name));

    LogMessage("[CST-Guard] %s -> %s : ejecutando sm_%s en su contexto -> %s", tag, name, base, profile);
    return CSTG_ApplyStart(client, profile, tag, name);
}

// ============================================================================
// motor de aplicacion: disparo VScript + verificacion + reintentos
// ============================================================================

bool CSTG_ApplyStart(int client, const char[] profile, const char[] tag, const char[] targetName)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || GetClientTeam(client) != 2)
        return false;

    if (!CSTG_ValidProfileName(profile))
    {
        LogMessage("[CST-Guard] perfil invalido '%s' (se ignora)", profile);
        return false;
    }

    // aplicacion ya en curso para el MISMO perfil (señal + verify casi
    // simultaneos, watchdog durante un apply): no se dispara de nuevo
    if (g_cstg_ApplyActive[client] && strcmp(g_cstg_ApplyProfile[client], profile) == 0)
    {
        CSTG_Debug("%s: aplicacion de %s ya en curso (intento %d): no se repite",
                   targetName, profile, g_cstg_ApplyAttempt[client]);
        return true;
    }

    // estado fresco (la validacion por userid+active mata cadenas previas)
    strcopy(g_cstg_ApplyProfile[client],    CSTG_PROF_LEN, profile);
    strcopy(g_cstg_ApplyTargetName[client], CSTG_NAME_LEN, targetName);
    GetEntPropString(client, Prop_Data, "m_ModelName", g_cstg_ApplyPreModel[client], PLATFORM_MAX_PATH);
    g_cstg_ApplyAttempt[client] = 1;
    g_cstg_ApplyCsWait[client]  = 0;
    g_cstg_ApplyActive[client]  = true;
    g_cstg_bSweepApplied        = true;      // v3.1.0: el barrido en curso NO cuenta como limpio
    CSTGuard_MarkDirty("apply en curso");   // v3.1.0: al terminar hay que re-verificar

    LogMessage("[CST-Guard] %s -> %s : aplicando %s (intento 1)", tag, targetName, profile);
    PrintToChatAll("\x01[\x04CST\x01] Aplicando perfil \x03%s\x01 ...", profile);

    if (CSTG_InCutscene(client))
    {
        CSTG_Debug("%s esta en cinematica (m_hViewEntity): se espera antes de disparar", targetName);
        // no disparamos en cinematica: la verificacion reintenta sin consumir intento
    }
    else
    {
        CSTG_FireApply(client, profile);
    }

    CreateTimer(g_cstg_cvRetryDelay.FloatValue, CSTG_Timer_Verify, GetClientUserId(client));
    return true;
}

public Action CSTG_Timer_Verify(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || !IsClientInGame(client) || !g_cstg_ApplyActive[client])
        return Plugin_Stop;

    char model[PLATFORM_MAX_PATH];
    GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));

    // exito: el modelo dejo de ser el que tenia
    if (strcmp(model, g_cstg_ApplyPreModel[client]) != 0)
    {
        LogMessage("[CST-Guard] %s listo: %s (intento %d)", g_cstg_ApplyTargetName[client], model, g_cstg_ApplyAttempt[client]);
        g_cstg_ApplyActive[client] = false;
        CSTGuard_MarkDirty("apply exitoso");   // v3.1.0: confirmar en el proximo barrido y volver al reposo
        return Plugin_Stop;
    }

    // sin cambio: si esta en cinematica esperamos SIN consumir intento
    if (CSTG_InCutscene(client) && g_cstg_ApplyCsWait[client] < CSTG_CS_MAX_WAITS)
    {
        g_cstg_ApplyCsWait[client]++;
        CSTG_Debug("%s en cinematica, espera %d/%d", g_cstg_ApplyTargetName[client], g_cstg_ApplyCsWait[client], CSTG_CS_MAX_WAITS);
        CreateTimer(CSTG_CS_WAIT_SEC, CSTG_Timer_Verify, userid);
        return Plugin_Stop;
    }

    // reintentos agotados
    if (g_cstg_ApplyAttempt[client] >= g_cstg_cvRetries.IntValue)
    {
        LogMessage("[CST-Guard] %s no pudo salir de %s tras %d intentos (v%s build %s: corre sm_cstcheck — cfg existente, takeovers no vacios, modelos montados)%s",
                   g_cstg_ApplyTargetName[client], g_cstg_ApplyPreModel[client], g_cstg_ApplyAttempt[client],
                   CSTG_VERSION, CSTG_BUILD,
                   (CSTG_SlotOfModel(g_cstg_ApplyPreModel[client]) < 0) ? " [nota: el modelo previo NO era stock]" : "");
        g_cstg_ApplyActive[client] = false;
        CSTGuard_MarkDirty("apply fallido");   // v3.1.0: re-intentar en el proximo ciclo (con tope de ciclos)
        return Plugin_Stop;
    }

    // reintento
    g_cstg_ApplyAttempt[client]++;
    bool preStock = (CSTG_SlotOfModel(g_cstg_ApplyPreModel[client]) >= 0);
    LogMessage("[CST-Guard] %s sigue en %s (%s), reintentando (intento %d)...%s",
               g_cstg_ApplyTargetName[client], preStock ? "stock" : "su modelo previo", g_cstg_ApplyPreModel[client],
               g_cstg_ApplyAttempt[client],
               preStock ? "" : " (ya no era stock: quizas ya tenia ese modelo)");

    CSTG_FireApply(client, g_cstg_ApplyProfile[client]);
    CreateTimer(g_cstg_cvRetryDelay.FloatValue, CSTG_Timer_Verify, userid);
    return Plugin_Stop;
}

// EL disparo: exactamente el camino del !skinchange del CST, nada inventado
void CSTG_FireApply(int client, const char[] profile)
{
    char code[256];
    // v2.0.1: (cfg, false, false) = debug off + GAMBLE OFF -> determinista
    Format(code, sizeof(code),
        "DirectorScript.Custom_Survivor_Takeover.SetCharacterProfile(GetPlayerFromUserID(%d), DirectorScript.CST_Base_Profile.GetProfile(\"%s\", false, false))",
        GetClientUserId(client), profile);

    SetVariantString(code);
    AcceptEntityInput(0, "RunScriptCode"); // worldspawn, patron del propio CST
}

// ============================================================================
// probe CST (handshake por convar write-back desde VScript)
// ============================================================================

void CSTG_ProbeFire(float delay)
{
    g_cstg_hProbeConVar.SetString("0", false);
    // v3.0.2 FIX CRITICO: Convars RAIZ (antes DirectorScript.Convars: el
    // script reventaba en silencio — "the index 'Convars' does not exist" —
    // el convar nunca se escribia y g_cstg_bCstReady quedaba en 0 PARA
    // SIEMPRE: señal, watchdog, sweeps y who-queries muertos mientras los
    // comandos manuales seguian vivos. Patron correcto = el del propio CST)
    SetVariantString("if(\"Custom_Survivor_Takeover\" in DirectorScript){Convars.SetValue(\"cstguard_probe\",\"1\")}");
    AcceptEntityInput(0, "RunScriptCode");
    CreateTimer(delay, CSTG_Timer_Probe);
}

public Action CSTG_Timer_Probe(Handle timer)
{
    bool wasReady = g_cstg_bCstReady;
    g_cstg_bCstReady = (g_cstg_hProbeConVar.IntValue == 1);

    if (g_cstg_bCstReady)
    {
        if (!wasReady)
        {
            LogMessage("[CST-Guard] CST detectado (Custom_Survivor_Takeover presente en VScript)");
            // v3.0.2: el CST acaba de confirmar — se pide re-anuncio para
            // aplicar YA las señales que llegaron antes de que montara (sin
            // esperar al watchdog ni al resync de la proxima ronda)
            CreateTimer(0.5, CSTG_Timer_ResyncRequest);
        }
        g_cstg_bCstWarned = false;
    }
    else if (!g_cstg_bCstWarned)
    {
        g_cstg_bCstWarned = true;
        LogMessage("[CST-Guard] CST NO detectado: el addon del workshop 3521730239 no esta montado o no cargo. Auto-guard inactivo; los comandos manuales dispararan igual (y fallaran hasta montarlo).");
    }
    return Plugin_Stop;
}

public Action CSTG_Timer_LateProbe(Handle timer)
{
    CSTG_ProbeFire(0.7);
    return Plugin_Stop;
}

// ============================================================================
// watchdog periodico
// ============================================================================

// barrido periodico: encola una consulta who para todos (la evaluacion solo
// dispara el comando del personaje si hay descoincidencia real)
public Action CSTG_Timer_Watchdog(Handle timer)
{
    if (!g_cstg_cvWatchdog.BoolValue || !g_cstg_cvAuto.BoolValue)
        return Plugin_Continue;

    // v3.1.0 — BARRIDO INTELIGENTE: en modo 1, si desde el ultimo barrido
    // LIMPIO no cambio nada (sin señales nuevas, sin applies, sin entradas,
    // sin cambios de equipo), el watchdog NO dispara la consulta who:
    // CERO ejecuciones de VScript en estado estable. El guard sigue
    // re-verificando EN EL ACTO ante cualquier evento (spawn, señal, defib,
    // rescate, reemplazo bot<->player, cambio de equipo), que es cuando de
    // verdad puede moverse un modelo. cstguard_sweepmode 0 = clasico
    // (barrido incondicional cada ciclo, comportamiento de la v3.0.x).
    if (g_cstg_cvSweepMode != null && g_cstg_cvSweepMode.IntValue == 1 && !g_cstg_bDirty)
        return Plugin_Continue;

    CSTG_EnqueueWho("watchdog", 0);
    return Plugin_Continue;
}

// el indice de cliente se puede reusar: la señal por indice se va con el
// cliente (la entrada por steamid queda para cuando reconecte).
// Hook interno a "player_disconnect": el manager NO necesita cablear
// OnClientDisconnect para esto.
// v3.1.0 — API publica del barrido inteligente: marca que algo cambio y
// el watchdog debe volver a consultar en su proximo ciclo (lo disparan los
// eventos internos del guard y puede llamarlo el host tras cualquier
// operacion que toque modelos/perfiles).
stock void CSTGuard_MarkDirty(const char[] why)
{
    g_cstg_bDirty = true;
    CSTG_Debug("barrido re-armado (%s)", why);
}

// v3.1.0 — estado del guard para sm_omdiag
stock void CSTGuard_Diag(char[] out, int maxlen)
{
    Format(out, maxlen, "barrido=%s | estado=%s | cache=%d/%d perfiles",
           (g_cstg_cvSweepMode != null && g_cstg_cvSweepMode.IntValue == 1) ? "inteligente" : "clasico",
           g_cstg_bDirty ? "pendiente" : "reposo",
           g_cstg_PCCount, CSTG_PC_MAX);
}

public void CSTG_Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client < 1 || client > MaxClients)
        return;

    g_cstg_SignalKey[client][0] = '\0';
    g_cstg_ManagerName[client][0] = '\0';
    CSTGuard_MarkDirty("player_disconnect");   // v3.1.0: la identidad del slot cambia
}

// v3.1.0: cambio de equipo (entra a espectador, toma SI, vuelve a survivor)
// -> la identidad evaluada puede cambiar: re-armar el barrido
public void CSTG_Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    CSTGuard_MarkDirty("player_team");
}

// ============================================================================
// comandos
// ============================================================================

public Action CSTG_Cmd_Info(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    char clist[384], slist[256], dyn[384];
    CSTG_CharMapToString(clist, sizeof(clist));
    CSTG_MapsToString(slist, sizeof(slist));
    CSTG_DynamicList(dyn, sizeof(dyn));
    ReplyToCommand(client, "[CST-Guard] v%s (EMBEBIDO) — guard de skins via CST (señal del manager + mapa por PERSONAJE)", CSTG_VERSION);
    ReplyToCommand(client, "[CST-Guard] mapa personajes: %s", (strlen(clist) > 0 ? clist : "(vacio)"));
    ReplyToCommand(client, "[CST-Guard] mapa slots (legacy): %s", (strlen(slist) > 0 ? slist : "(vacio)"));
    ReplyToCommand(client, "[CST-Guard] sm_cstguard_maps \"amy=amy.cfg,metal=metal.cfg,silver=silver.cfg\" — definir (\"\" limpia TODO)");
    ReplyToCommand(client, "[CST-Guard] sm_cstapply <perfil.cfg> [nombre|#userid] — aplicar directo (sin target: perfil -> vos)");
    ReplyToCommand(client, "[CST-Guard] sm_cstcheck — diagnostico completo (identidades del manager incluidas)");
    ReplyToCommand(client, "[CST-Guard] sm_cstsignal <nombre|#userid> <clave|clear> — simula la señal del manager");
    ReplyToCommand(client, "[CST-Guard] sm_cstsync — pedir al manager que re-anuncie (forward de resync)");
    ReplyToCommand(client, "[CST-Guard] sm_cstguard_reload — releer archivo de mapas");
    ReplyToCommand(client, "[CST-Guard] dinamicos: %s", dyn);
    return Plugin_Handled;
}

public Action CSTG_Cmd_Maps(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (args < 1)
    {
        char clist[384], slist[256];
        CSTG_CharMapToString(clist, sizeof(clist));
        CSTG_MapsToString(slist, sizeof(slist));
        ReplyToCommand(client, "[CST-Guard] mapa personajes: %s", (strlen(clist) > 0 ? clist : "(vacio)"));
        ReplyToCommand(client, "[CST-Guard] mapa slots (legacy): %s", (strlen(slist) > 0 ? slist : "(vacio)"));
        ReplyToCommand(client, "[CST-Guard] uso: sm_cstguard_maps \"amy=amy.cfg,metal=metal.cfg,silver=silver.cfg\" (personajes) o \"survivor_coach=amy.cfg\" (slots)");
        ReplyToCommand(client, "[CST-Guard] las claves de personaje matchean el registro del manager / nombre del bot / modelo");
        return Plugin_Handled;
    }

    char raw[512];
    GetCmdArgString(raw, sizeof(raw));
    TrimString(raw);

    // quitar comillas envolventes si vinieron ("amy=amy.cfg,...")
    int rawLen = strlen(raw);
    if (rawLen >= 2 && raw[0] == '"' && raw[rawLen-1] == '"')
    {
        raw[rawLen-1] = '\0';
        char inner[512];
        strcopy(inner, sizeof(inner), raw[1]);
        strcopy(raw, sizeof(raw), inner);
        TrimString(raw);
    }

    // limpiar TODO
    if (strlen(raw) == 0 || strcmp(raw, "\"\"") == 0)
    {
        for (int i = 0; i < CSTG_MAX_MAPS; i++)
            g_cstg_MapSet[i] = false;
        g_cstg_CharCount = 0;
        CSTG_SaveMapsFile();
        ReplyToCommand(client, "[CST-Guard] mapas limpiados (auto-guard no aplicara nada)");
        LogMessage("[CST-Guard] mapas limpiados por comando");
        return Plugin_Handled;
    }

    // parsear "clave=perfil,clave=perfil,..." (claves de personaje O slots)
    char pieces[24][96];
    int nPieces = ExplodeString(raw, ",", pieces, sizeof(pieces), sizeof(pieces[]));

    bool newMapSet[CSTG_MAX_MAPS];
    char newMapProfile[CSTG_MAX_MAPS][CSTG_PROF_LEN];
    char newCharKeys[CSTG_MAX_CHARS][CSTG_SLOT_LEN];
    char newCharCfgs[CSTG_MAX_CHARS][CSTG_PROF_LEN];
    int  newCharCount = 0;

    for (int i = 0; i < CSTG_MAX_MAPS; i++)
    {
        newMapSet[i] = false;
        newMapProfile[i][0] = '\0';
    }

    int count = 0, bad = 0;
    for (int i = 0; i < nPieces; i++)
    {
        char piece[96];
        strcopy(piece, sizeof(piece), pieces[i]);
        TrimString(piece);
        if (strlen(piece) == 0)
            continue;

        char parts[2][96];
        if (ExplodeString(piece, "=", parts, 2, sizeof(parts[])) != 2)
        {
            bad++;
            ReplyToCommand(client, "[CST-Guard] pieza invalida (falta '='): \"%s\"", piece);
            continue;
        }

        char key[CSTG_SLOT_LEN], profile[CSTG_PROF_LEN];
        strcopy(key, sizeof(key), parts[0]);
        strcopy(profile, sizeof(profile), parts[1]);
        TrimString(key);
        TrimString(profile);

        if (!CSTG_ValidProfileName(profile))
        {
            bad++;
            ReplyToCommand(client, "[CST-Guard] perfil invalido \"%s\" (formato: nombre.cfg, sin espacios ni comillas)", profile);
            continue;
        }

        // primero slots (legacy; NormalizeSlot ademas lowercasea y pela "survivor_")
        int slotIdx = CSTG_NormalizeSlot(key, sizeof(key));
        if (slotIdx >= 0)
        {
            newMapSet[slotIdx] = true;
            strcopy(newMapProfile[slotIdx], CSTG_PROF_LEN, profile);
            count++;
            continue;
        }

        // si no es slot: clave de personaje
        if (CSTG_ValidCharKey(key))
        {
            if (newCharCount >= CSTG_MAX_CHARS)
            {
                bad++;
                ReplyToCommand(client, "[CST-Guard] demasiados personajes (max %d)", CSTG_MAX_CHARS);
                continue;
            }
            strcopy(newCharKeys[newCharCount], CSTG_SLOT_LEN, key);
            strcopy(newCharCfgs[newCharCount], CSTG_PROF_LEN, profile);
            newCharCount++;
            count++;
            continue;
        }

        bad++;
        ReplyToCommand(client, "[CST-Guard] clave desconocida \"%s\" (no es slot ni clave valida de personaje)", key);
    }

    if (count == 0)
    {
        ReplyToCommand(client, "[CST-Guard] nada aplicado (%d piezas invalidas)", bad);
        return Plugin_Handled;
    }

    for (int i = 0; i < CSTG_MAX_MAPS; i++)
    {
        g_cstg_MapSet[i] = newMapSet[i];
        strcopy(g_cstg_MapProfile[i], CSTG_PROF_LEN, newMapProfile[i]);
    }
    g_cstg_CharCount = newCharCount;
    for (int i = 0; i < g_cstg_CharCount; i++)
    {
        strcopy(g_cstg_CharKeys[i], CSTG_SLOT_LEN, newCharKeys[i]);
        strcopy(g_cstg_CharCfg[i], CSTG_PROF_LEN, newCharCfgs[i]);
    }

    CSTG_SaveMapsFile();
    CSTG_RegisterDynamicFromMaps();

    char clist[384], slist[256];
    CSTG_CharMapToString(clist, sizeof(clist));
    CSTG_MapsToString(slist, sizeof(slist));
    ReplyToCommand(client, "[CST-Guard] mapas seteados (%d entradas, %d invalidas): personajes: %s | slots: %s",
                   count, bad, clist, slist);
    LogMessage("[CST-Guard] mapas seteados por comando: personajes: %s | slots: %s", clist, slist);

    // barrido inmediato para no esperar al proximo spawn
    CSTG_EnqueueWho("comando-maps", 0);

    return Plugin_Handled;
}

public Action CSTG_Cmd_Apply(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (args < 1)
    {
        ReplyToCommand(client, "[CST-Guard] uso: sm_cstapply <perfil.cfg> [nombre|#userid]");
        return Plugin_Handled;
    }

    char profile[CSTG_PROF_LEN];
    GetCmdArg(1, profile, sizeof(profile));
    if (!CSTG_ValidProfileName(profile))
    {
        ReplyToCommand(client, "[CST-Guard] perfil invalido \"%s\" (formato: nombre.cfg)", profile);
        return Plugin_Handled;
    }

    // target explicito
    if (args >= 2)
    {
        char targ[CSTG_NAME_LEN];
        GetCmdArg(2, targ, sizeof(targ));

        int target = 0;
        if (targ[0] == '#')
            target = GetClientOfUserId(StringToInt(targ[1]));
        if (target < 1)
            target = CSTG_FindByName(targ, true); // contains, mas flexible para manual

        if (target < 1 || !IsClientInGame(target) || GetClientTeam(target) != 2)
        {
            ReplyToCommand(client, "[CST-Guard] target no encontrado o no es survivor: \"%s\"", targ);
            return Plugin_Handled;
        }

        char tname[CSTG_NAME_LEN];
        GetClientName(target, tname, sizeof(tname));
        CSTG_ApplyStart(target, profile, "comando", tname);
        ReplyToCommand(client, "[CST-Guard] aplicando %s a %s", profile, tname);
        return Plugin_Handled;
    }

    // resolucion igual al comando dinamico (nombre -> slot -> mapa -> VOS)
    if (!CSTG_ResolveAndApply(profile, "comando", client))
        ReplyToCommand(client, "[CST-Guard] no se encontro target para %s (check sm_cstcheck)", profile);

    return Plugin_Handled;
}

public Action CSTG_Cmd_Check(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    ReplyToCommand(client, "[CST-Guard] ===== DIAGNOSTICO v%s (build %s) =====", CSTG_VERSION, CSTG_BUILD);
    ReplyToCommand(client, "[CST-Guard] barrido: %s | estado: %s | perfiles en cache: %d/%d",
                   (g_cstg_cvSweepMode != null && g_cstg_cvSweepMode.IntValue == 1) ? "INTELIGENTE (solo consulta si algo cambio)" : "clasico (consulta en cada ciclo)",
                   g_cstg_bDirty ? "pendiente (consultara en el proximo ciclo)" : "en reposo (nada que verificar)",
                   g_cstg_PCCount, CSTG_PC_MAX);
    ReplyToCommand(client, "[CST-Guard] MODO v3.0.0 EMBEBIDO: guard + CST corren DENTRO de este plugin; la señal EJECUTA el comando del personaje (sm_amy / sm_sonic / ...) en el contexto del jugador");

    // capa de señal (embebida: este plugin ES el listener, no hay natives)
    ReplyToCommand(client, "[CST-Guard] señal del manager: %d recibidas | resync: EMBEBIDO (via CSTGuard_OnResyncRequested directo)",
                   g_cstg_iSignalCount);

    // probe fresco (el resultado se imprime al log y queda para la proxima)
    CSTG_ProbeFire(0.7);
    ReplyToCommand(client, "[CST-Guard] CST (VScript): %s (probe relanzado; ejecuta sm_cstcheck de nuevo en 2s para ver el resultado)",
                   g_cstg_bCstReady ? "DETECTADO" : "NO confirmado aun");

    char clist[384], slist[256];
    CSTG_CharMapToString(clist, sizeof(clist));
    CSTG_MapsToString(slist, sizeof(slist));
    ReplyToCommand(client, "[CST-Guard] mapa personajes: %s", (strlen(clist) > 0 ? clist : "(vacio)"));
    ReplyToCommand(client, "[CST-Guard] mapa slots (legacy): %s", (strlen(slist) > 0 ? slist : "(vacio)"));

    // consulta de identidad fresca (alimenta g_cstg_ManagerName; resultado en la
    // proxima ejecucion de sm_cstcheck — y corrige sobre la marcha si hace falta)
    if (g_cstg_bCstReady)
    {
        CSTG_EnqueueWho("check", 0);
        ReplyToCommand(client, "[CST-Guard] consulta al manager relanzada: re-ejecuta sm_cstcheck en 2s para ver las identidades");
    }

    // salud de cada perfil mapeado (personajes primero, luego slots, sin repetir)
    char seen[CSTG_MAX_SEEN][CSTG_PROF_LEN];
    int nSeen = 0;
    for (int i = 0; i < g_cstg_CharCount; i++)
        CSTG_ReportProfile(client, g_cstg_CharCfg[i], seen, nSeen);
    for (int i = 0; i < CSTG_MAX_MAPS; i++)
        if (g_cstg_MapSet[i])
            CSTG_ReportProfile(client, g_cstg_MapProfile[i], seen, nSeen);

    // estado de survivors: quien ES segun el manager + si su modelo matchea
    char model[PLATFORM_MAX_PATH], cname[CSTG_NAME_LEN];
    int n = 0;
    for (int c = 1; c <= MaxClients; c++)
    {
        if (!IsClientInGame(c) || GetClientTeam(c) != 2)
            continue;

        n++;
        GetClientName(c, cname, sizeof(cname));
        GetEntPropString(c, Prop_Data, "m_ModelName", model, sizeof(model));

        int k = -1;
        char via[24];
        via[0] = '\0';

        char sig[CSTG_SLOT_LEN];
        CSTG_SignalOf(c, sig, sizeof(sig));

        if (g_cstg_cvSignal.BoolValue && strlen(sig) > 0)
        {
            k = CSTG_SignalKeyIndex(sig);
            if (k >= 0)
                strcopy(via, sizeof(via), "señal");
        }
        if (k < 0 && strlen(g_cstg_ManagerName[c]) > 0)
        {
            k = CSTG_KeyOfIdentity(g_cstg_ManagerName[c]);
            if (k >= 0)
                strcopy(via, sizeof(via), "manager");
        }
        if (k < 0)
        {
            k = CSTG_KeyOfIdentity(cname);
            if (k >= 0)
                strcopy(via, sizeof(via), "nombre");
        }
        if (k < 0)
        {
            k = CSTG_KeyOfModel(model);
            if (k >= 0)
                strcopy(via, sizeof(via), "modelo");
        }

        if (k >= 0)
        {
            bool matches = CSTG_ModelMatchesCfg(model, g_cstg_CharCfg[k]);
            ReplyToCommand(client, "[CST-Guard] survivor: %s (%s) [señal: %s] [manager: %s] ES \"%s\" (via %s) -> %s %s [%s]",
                           cname, IsFakeClient(c) ? "BOT" : "HUMANO",
                           (strlen(sig) > 0 ? sig : "-"),
                           (strlen(g_cstg_ManagerName[c]) > 0 ? g_cstg_ManagerName[c] : "(sin consulta aun)"),
                           g_cstg_CharKeys[k], via, g_cstg_CharCfg[k],
                           matches ? "MODELO OK" : "MODELO NO CORRESPONDE ->",
                           model);
        }
        else
        {
            int slot = CSTG_SlotOfModel(model);
            if (slot >= 0 && g_cstg_MapSet[slot])
                ReplyToCommand(client, "[CST-Guard] survivor: %s (%s) [señal: %s] [manager: %s] [avatar stock: %s] [STOCK -> slot legacy: %s] %s",
                               cname, IsFakeClient(c) ? "BOT" : "HUMANO",
                               (strlen(sig) > 0 ? sig : "-"),
                               (strlen(g_cstg_ManagerName[c]) > 0 ? g_cstg_ManagerName[c] : "(sin consulta aun)"),
                               g_cstg_SlotNames[slot], g_cstg_MapProfile[slot], model);
            else if (slot >= 0)
                ReplyToCommand(client, "[CST-Guard] survivor: %s (%s) [señal: %s] [manager: %s] [avatar stock: %s] [sin personaje/slot mapeado] %s",
                               cname, IsFakeClient(c) ? "BOT" : "HUMANO",
                               (strlen(sig) > 0 ? sig : "-"),
                               (strlen(g_cstg_ManagerName[c]) > 0 ? g_cstg_ManagerName[c] : "(sin consulta aun)"),
                               g_cstg_SlotNames[slot], model);
            else
                ReplyToCommand(client, "[CST-Guard] survivor: %s (%s) [señal: %s] [manager: %s] [custom, sin personaje mapeado] %s",
                               cname, IsFakeClient(c) ? "BOT" : "HUMANO",
                               (strlen(sig) > 0 ? sig : "-"),
                               (strlen(g_cstg_ManagerName[c]) > 0 ? g_cstg_ManagerName[c] : "(sin consulta aun)"),
                               model);
        }
    }
    if (n == 0)
        ReplyToCommand(client, "[CST-Guard] survivors: (ninguno conectado ahora)");

    char dyn[384];
    CSTG_DynamicList(dyn, sizeof(dyn));
    ReplyToCommand(client, "[CST-Guard] comandos dinamicos: %s", dyn);
    ReplyToCommand(client, "[CST-Guard] auto=%d humanos=%d intentos=%d delay=%.1f",
                   g_cstg_cvAuto.IntValue, g_cstg_cvHumans.IntValue, g_cstg_cvRetries.IntValue, g_cstg_cvRetryDelay.FloatValue);
    return Plugin_Handled;
}

// bloque de salud de un cfg (una vez por perfil distinto; max CSTG_MAX_SEEN)
void CSTG_ReportProfile(int client, const char[] profile, char seen[][CSTG_PROF_LEN], int &nSeen)
{
    for (int i = 0; i < nSeen; i++)
        if (strcmp(seen[i], profile) == 0)
            return; // ya reportado

    if (nSeen < CSTG_MAX_SEEN)
        strcopy(seen[nSeen++], CSTG_PROF_LEN, profile);

    char path[PLATFORM_MAX_PATH];
    Format(path, sizeof(path), "%s%s", CSTG_EMS_PREFIX, profile);

    if (!FileExists(path))
    {
        ReplyToCommand(client, "[CST-Guard] perfil %s: FALTA en %s", profile, path);
        return;
    }

    char pname[CSTG_NAME_LEN], pslot[CSTG_SLOT_LEN], pmodels[512];
    bool enabled, hasTo; float chance;
    int nModels;
    if (CSTG_ProfileCached(profile, pname, sizeof(pname), pslot, sizeof(pslot),
                          enabled, chance, pmodels, sizeof(pmodels), nModels, hasTo))
    {
        ReplyToCommand(client, "[CST-Guard] perfil %s: OK nombre=\"%s\" slot=%s enabled=%s chance=%.0f%% takeovers=%s",
                       profile, pname, pslot, enabled ? "true" : "FALSE", chance,
                       hasTo ? "OK" : "VACIO");
        if (!hasTo)
            ReplyToCommand(client, "[CST-Guard]   takeovers vacio en el cfg -> el CST RECHAZA el perfil SIEMPRE (fijalo)");

        if (nModels == 0)
        {
            ReplyToCommand(client, "[CST-Guard]   modelos: (no se encontro random_models en el cfg)");
        }
        else
        {
            // disponibilidad REAL de cada modelo (FS + VPKs montados)
            char mlist[12][PLATFORM_MAX_PATH];
            int nM = ExplodeString(pmodels, " ", mlist, sizeof(mlist), sizeof(mlist[]));
            for (int m = 0; m < nM; m++)
            {
                bool ok = FileExists(mlist[m], true);
                ReplyToCommand(client, "[CST-Guard]   modelo %d/%d: %s -> %s", m + 1, nM, mlist[m],
                               ok ? "DISPONIBLE" : "FALTA EN EL SERVER (ruta mal o addon no montado)");
            }
        }
    }
    else
        ReplyToCommand(client, "[CST-Guard] perfil %s: existe pero ilegible (revisar sintaxis)", profile);
}

public Action CSTG_Cmd_Reload(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    for (int i = 0; i < CSTG_MAX_MAPS; i++)
        g_cstg_MapSet[i] = false;
    g_cstg_CharCount = 0;
    CSTG_LoadMapsFile();
    CSTG_RegisterDynamicFromMaps();

    char clist[384], slist[256];
    CSTG_CharMapToString(clist, sizeof(clist));
    CSTG_MapsToString(slist, sizeof(slist));
    ReplyToCommand(client, "[CST-Guard] mapas releidos: personajes: %s | slots: %s",
                   (strlen(clist) > 0 ? clist : "(vacio)"), (strlen(slist) > 0 ? slist : "(vacio)"));
    return Plugin_Handled;
}

// ============================================================================
// señal manual + re-anuncio (prueba del camino del manager sin parchearlo)
// ============================================================================

public Action CSTG_Cmd_Signal(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (args < 2)
    {
        ReplyToCommand(client, "[CST-Guard] uso: sm_cstsignal <nombre|#userid> <clave|clear>");
        ReplyToCommand(client, "[CST-Guard] ejemplo: sm_cstsignal amy amy  (el survivor \"amy\" ES amy -> aplica amy.cfg si hace falta)");
        return Plugin_Handled;
    }

    char targ[CSTG_NAME_LEN], key[64];
    GetCmdArg(1, targ, sizeof(targ));
    GetCmdArg(2, key, sizeof(key));

    int target = 0;
    if (targ[0] == '#')
        target = GetClientOfUserId(StringToInt(targ[1]));
    if (target < 1)
        target = CSTG_FindByName(targ, true);

    if (target < 1 || !IsClientInGame(target) || GetClientTeam(target) != 2)
    {
        ReplyToCommand(client, "[CST-Guard] target no encontrado o no es survivor: \"%s\"", targ);
        return Plugin_Handled;
    }

    if (strcmp(key, "clear", false) == 0)
    {
        g_cstg_SignalKey[target][0] = '\0';
        if (!IsFakeClient(target) && IsClientAuthorized(target))
        {
            char sid[64];
            if (GetClientAuthId(target, AuthId_Steam2, sid, sizeof(sid)))
                g_cstg_SignalBySteam.Remove(sid);
        }
        ReplyToCommand(client, "[CST-Guard] señal limpiada para %N", target);
        return Plugin_Handled;
    }

    if (CSTG_HandleSignal(target, key, "manual"))
        ReplyToCommand(client, "[CST-Guard] señal manual entregada: %N = \"%s\" (ver log / resultado)", target, key);
    else
        ReplyToCommand(client, "[CST-Guard] señal invalida (clave vacia)");

    return Plugin_Handled;
}

public Action CSTG_Cmd_Sync(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    CSTG_RequestResync();

    ReplyToCommand(client, "[CST-Guard] re-anuncio disparado (CSTGuard_OnResyncRequested, EMBEBIDO): este plugin re-anuncia sus personajes");
    return Plugin_Handled;
}

// comando dinamico sm_<perfil|clave>
public Action CSTG_Cmd_DynamicProfile(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    char cmd[64], base[CSTG_PROF_LEN], profile[CSTG_PROF_LEN];
    GetCmdArg(0, cmd, sizeof(cmd));

    // cmd = "sm_amy" -> base = "amy"
    strcopy(base, sizeof(base), cmd);
    ReplaceString(base, sizeof(base), "sm_", "");

    if (!g_cstg_RegisteredCmds.GetString(base, profile, sizeof(profile)))
    {
        ReplyToCommand(client, "[CST-Guard] perfil no registrado para %s", cmd);
        return Plugin_Handled;
    }

    if (!CSTG_ResolveAndApply(profile, "comando", client))
        ReplyToCommand(client, "[CST-Guard] no se encontro target para %s (check sm_cstcheck)", profile);

    return Plugin_Handled;
}

// ============================================================================
// resolucion de target (semantica del !skinchange del CST)
// ============================================================================

bool CSTG_ResolveAndApply(const char[] profile, const char[] tag, int caller)
{
    char pname[CSTG_NAME_LEN], pslot[CSTG_SLOT_LEN], pmodels[512];
    bool enabled, hasTo; float chance;
    int nModels;
    bool haveCfg = CSTG_ProfileCached(profile, pname, sizeof(pname), pslot, sizeof(pslot),
                                     enabled, chance, pmodels, sizeof(pmodels), nModels, hasTo);

    int target = 0;

    // 1) por nombre del perfil (StartsWith, como GetPlayerByName del CST)
    if (haveCfg && strlen(pname) > 0)
        target = CSTG_FindByName(pname, false);

    // 2) por survivor_slot del propio perfil
    if (target < 1 && haveCfg && strlen(pslot) > 0)
    {
        int slotIdx = CSTG_NormalizeSlot(pslot, sizeof(pslot));
        if (slotIdx >= 0)
            target = CSTG_FindBySlot(slotIdx);
    }

    // 3) por slot inverso del mapa legacy (que slot apunta a este perfil)
    if (target < 1)
    {
        for (int i = 0; i < CSTG_MAX_MAPS && target < 1; i++)
            if (g_cstg_MapSet[i] && strcmp(g_cstg_MapProfile[i], profile) == 0)
                target = CSTG_FindBySlot(i);
    }

    // 4) el admin que corre el comando (si es survivor vivo): asi el cambio
    //    pasa NO IMPORTA en cual de los 8 avatars (stock o custom) estes
    if (target < 1 && caller >= 1 && caller <= MaxClients &&
        IsClientInGame(caller) && GetClientTeam(caller) == 2)
    {
        target = caller;
        CSTG_Debug("niveles 1-3 sin match: target = caller (%N)", caller);
    }

    if (target < 1)
        return false;

    char tname[CSTG_NAME_LEN];
    GetClientName(target, tname, sizeof(tname));
    CSTG_ApplyStart(target, profile, tag, tname);
    return true;
}

int CSTG_FindByName(const char[] needle, bool contains)
{
    char cname[CSTG_NAME_LEN];
    for (int c = 1; c <= MaxClients; c++)
    {
        if (!IsClientInGame(c) || GetClientTeam(c) != 2)
            continue;

        GetClientName(c, cname, sizeof(cname));
        if (contains)
        {
            if (StrContains(cname, needle, false) != -1)
                return c;
        }
        else if (StrContains(cname, needle, false) == 0) // StartsWith, como el CST
            return c;
    }
    return 0;
}

int CSTG_FindBySlot(int slotIdx)
{
    char model[PLATFORM_MAX_PATH], want[PLATFORM_MAX_PATH];
    Format(want, sizeof(want), "models/survivors/survivor_%s.mdl", g_cstg_Slots[slotIdx]);

    for (int c = 1; c <= MaxClients; c++)
    {
        if (!IsClientInGame(c) || GetClientTeam(c) != 2)
            continue;
        GetEntPropString(c, Prop_Data, "m_ModelName", model, sizeof(model));
        if (strcmp(model, want) == 0)
            return c;
    }
    return 0;
}

// ============================================================================
// lectura del perfil CST (ems/Custom_Survivor_Takeover/profiles/<perfil>.cfg)
// ============================================================================

bool CSTG_ParseProfile(const char[] profile,
                       char[] outName, int nameLen,
                       char[] outSlot, int slotLen,
                       bool &enabled, float &chance,
                       char[] outModels, int modelsLen, int &modelCount,
                       bool &hasTakeovers)
{
    outName[0]   = '\0';
    outSlot[0]   = '\0';
    outModels[0] = '\0';
    modelCount   = 0;
    hasTakeovers = false;
    enabled      = true;
    chance       = 100.0;

    char path[PLATFORM_MAX_PATH];
    Format(path, sizeof(path), "%s%s", CSTG_EMS_PREFIX, profile);
    if (!FileExists(path))
        return false;

    File f = OpenFile(path, "r");
    if (f == null)
        return false;

    char line[512], key[64], val[512];
    bool anyKey = false;
    while (f.ReadLine(line, sizeof(line)))
    {
        // recortar derecha
        int len = strlen(line);
        while (len > 0 && (line[len-1] == '\n' || line[len-1] == '\r' || line[len-1] == ' ' || line[len-1] == '\t'))
            line[--len] = '\0';

        // recortar izquierda
        int start = 0;
        while (line[start] == ' ' || line[start] == '\t')
            start++;

        // "clave = valor"
        int eq = StrContains(line[start], "=");
        if (eq <= 0)
            continue;

        strcopy(key, sizeof(key), line[start]);
        key[eq] = '\0';
        TrimString(key);

        strcopy(val, sizeof(val), line[start + eq + 1]);
        TrimString(val);

        // arrays multilinea: si el valor no cerro con ']', seguimos leyendo
        // (el serializador del CST escribe una linea; un cfg editado a mano
        // puede venir en varias)
        if (StrContains(val, "]") == -1 &&
            (strcmp(key, "random_models") == 0 || strcmp(key, "takeovers") == 0 || strcmp(key, "random_names") == 0))
        {
            char more[256];
            int guard = 0;
            while (guard < 12 && f.ReadLine(more, sizeof(more)))
            {
                guard++;
                StrCat(val, sizeof(val), " ");
                StrCat(val, sizeof(val), more);
                if (StrContains(more, "]") != -1)
                    break;
            }
        }

        if (strcmp(key, "random_names") == 0)
        {
            CSTG_FirstQuoted(val, outName, nameLen);
            anyKey = true;
        }
        else if (strcmp(key, "survivor_slot") == 0)
        {
            CSTG_FirstQuoted(val, outSlot, slotLen);
            anyKey = true;
        }
        else if (strcmp(key, "random_models") == 0)
        {
            CSTG_CollectQuoted(val, outModels, modelsLen, modelCount);
            anyKey = true;
        }
        else if (strcmp(key, "takeovers") == 0)
        {
            hasTakeovers = CSTG_ArrayHasContent(val);
            anyKey = true;
        }
        else if (strcmp(key, "enabled") == 0)
        {
            enabled = (StrContains(val, "false") == -1);
            anyKey = true;
        }
        else if (strcmp(key, "takeover_chance") == 0)
        {
            chance = StringToFloat(val);
            anyKey = true;
        }
    }
    delete f;
    return anyKey;
}

// agrega a out todas las cadenas entrecomilladas de src (separadas por espacio)
void CSTG_CollectQuoted(const char[] src, char[] out, int maxLen, int &count)
{
    int len = strlen(src);
    int i = 0;
    while (i < len)
    {
        while (i < len && src[i] != '"')
            i++;
        if (i >= len)
            break;
        i++; // comilla de apertura
        int start = i;
        while (i < len && src[i] != '"')
            i++;
        if (i >= len)
            break; // sin comilla de cierre

        char tmp[PLATFORM_MAX_PATH];
        int n = i - start;
        if (n >= sizeof(tmp))
            n = sizeof(tmp) - 1;
        strcopy(tmp, n + 1, src[start]);

        if (strlen(out) > 0)
            StrCat(out, maxLen, " ");
        StrCat(out, maxLen, tmp);
        count++;

        i++; // comilla de cierre
    }
}

// "[]" o "[ ]" -> false; al menos un elemento -> true
bool CSTG_ArrayHasContent(const char[] src)
{
    char buf[256];
    strcopy(buf, sizeof(buf), src);
    ReplaceString(buf, sizeof(buf), "[", " ");
    ReplaceString(buf, sizeof(buf), "]", " ");
    ReplaceString(buf, sizeof(buf), ",", " ");
    TrimString(buf);
    return strlen(buf) > 0;
}

void CSTG_FirstQuoted(const char[] src, char[] out, int maxLen)
{
    out[0] = '\0';
    int o1 = StrContains(src, "\"");
    if (o1 < 0)
        return;

    char rest[256];
    strcopy(rest, sizeof(rest), src[o1 + 1]);

    int o2 = StrContains(rest, "\"");
    if (o2 < 0)
        return;
    if (o2 >= maxLen)
        o2 = maxLen - 1;

    strcopy(out, o2 + 1, rest);
    out[o2] = '\0';
}

// ============================================================================
// mapas personaje/slot <-> perfil: normalizacion, persistencia, dinamicos
// ============================================================================

// acepta "survivor_coach" o "coach"; devuelve indice o -1; normaliza el buffer
int CSTG_NormalizeSlot(char[] slot, int maxLen)
{
    for (int i = 0; slot[i] != '\0' && i < maxLen; i++)
        if (slot[i] >= 'A' && slot[i] <= 'Z')
            slot[i] += 32;

    if (strncmp(slot, "survivor_", 9, false) == 0)
    {
        char tmp[CSTG_SLOT_LEN];
        strcopy(tmp, sizeof(tmp), slot[9]);
        strcopy(slot, maxLen, tmp);
    }

    for (int i = 0; i < CSTG_MAX_MAPS; i++)
        if (strcmp(slot, g_cstg_Slots[i]) == 0)
            return i;

    return -1;
}

// clave de personaje: [a-z0-9_-], 1..15 (el buffer ya viene lowercase de NormalizeSlot)
bool CSTG_ValidCharKey(const char[] key)
{
    int len = strlen(key);
    if (len < 1 || len >= CSTG_SLOT_LEN)
        return false;

    for (int i = 0; i < len; i++)
    {
        char c = key[i];
        bool ok = (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_' || c == '-';
        if (!ok)
            return false;
    }
    return true;
}

bool CSTG_ValidProfileName(const char[] profile)
{
    int len = strlen(profile);
    if (len < 4 || len >= CSTG_PROF_LEN)
        return false;
    if (StrContains(profile, ".cfg") != len - 4)
        return false;

    for (int i = 0; i < len; i++)
    {
        char c = profile[i];
        bool ok = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
                  (c >= '0' && c <= '9') || c == '_' || c == '-' || c == '.';
        if (!ok)
            return false;
    }
    return true;
}

void CSTG_MapsToString(char[] out, int maxLen)
{
    out[0] = '\0';
    for (int i = 0; i < CSTG_MAX_MAPS; i++)
    {
        if (!g_cstg_MapSet[i])
            continue;
        if (strlen(out) > 0)
            StrCat(out, maxLen, ", ");
        StrCat(out, maxLen, g_cstg_Slots[i]);
        StrCat(out, maxLen, "=");
        StrCat(out, maxLen, g_cstg_MapProfile[i]);
    }
}

void CSTG_CharMapToString(char[] out, int maxLen)
{
    out[0] = '\0';
    for (int i = 0; i < g_cstg_CharCount; i++)
    {
        if (strlen(out) > 0)
            StrCat(out, maxLen, ", ");
        StrCat(out, maxLen, g_cstg_CharKeys[i]);
        StrCat(out, maxLen, "=");
        StrCat(out, maxLen, g_cstg_CharCfg[i]);
    }
}

void CSTG_SaveMapsFile()
{
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), CSTG_MAPS_FILE);

    File f = OpenFile(path, "w");
    if (f == null)
    {
        LogMessage("[CST-Guard] no se pudo escribir %s", path);
        return;
    }

    f.WriteLine("# cst_skinchange v%s — mapa = perfil (una linea por entrada) %s", CSTG_VERSION, CSTG_MAPS_MARKER);
    f.WriteLine("# ESTE ARCHIVO MANDA: borra la linea que no quieras y recarga (sm_cstguard_reload)");
    f.WriteLine("# mapa oficial = los 14 perfiles CST del server (VPK *_cst.vpk + rouge_r.cfg):");
    f.WriteLine("#   sonic tails knuckles amy shadow rouge cream metal eggman sage");
    f.WriteLine("#   + extras de comando manual: big blaze omega silver");
    f.WriteLine("# sally SIN modelo en CST: sin linea = el modelo stock queda intacto.");
    f.WriteLine("# clave de SLOT (legacy): coach mechanic producer gambler namvet teenangst manager biker");
    for (int i = 0; i < g_cstg_CharCount; i++)
        f.WriteLine("%s %s", g_cstg_CharKeys[i], g_cstg_CharCfg[i]);
    for (int i = 0; i < CSTG_MAX_MAPS; i++)
        if (g_cstg_MapSet[i])
            f.WriteLine("%s %s", g_cstg_Slots[i], g_cstg_MapProfile[i]);
    delete f;
}

void CSTG_LoadMapsFile()
{
    // v3.1.0: el mapa puede traer perfiles nuevos -> cache de perfiles
    // invalidado y barrido re-armado (los cfg se re-leeran una sola vez)
    CSTG_ProfileCacheFlush();
    CSTGuard_MarkDirty("mapa de perfiles recargado");

    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), CSTG_MAPS_FILE);

    if (!FileExists(path))
    {
        // PRIMERA VEZ: mapa oficial = los 14 perfiles CST del server
        CSTG_SeedDefaultChars();
        CSTG_SaveMapsFile();
        LogMessage("[CST-Guard] sin %s: sembrado el mapa oficial de %d perfiles (sonic tails knuckles amy shadow rouge cream metal eggman sage big blaze omega silver)", CSTG_MAPS_FILE, CSTG_DEF_CHARS);
        return;
    }

    File f = OpenFile(path, "r");
    if (f == null)
        return;

    char line[256], key[CSTG_SLOT_LEN], profile[CSTG_PROF_LEN];
    int loaded = 0;
    bool bOfficialFile = false;   // v3.0.3: ya lleva el marcador -> el archivo MANDA tal cual
    bool bAllKnown     = true;    // v3.0.3: todas las entradas son pares oficiales/historicos (seed viejo)
    while (f.ReadLine(line, sizeof(line)))
    {
        // v3.0.3: marcador del propio guard — el archivo ya es el mapa
        // oficial (o fue editado a mano despues): se respeta TAL CUAL.
        if (StrContains(line, CSTG_MAPS_MARKER) != -1)
        {
            bOfficialFile = true;
            continue;
        }
        if (line[0] == '#' || line[0] == '\n' || line[0] == '\r')
            continue;

        // "<clave> <perfil.cfg>"
        int sp = BreakString(line, key, sizeof(key));
        if (sp == -1)
            continue;
        strcopy(profile, sizeof(profile), line[sp]);
        TrimString(profile);
        TrimString(key);

        if (!CSTG_ValidProfileName(profile))
        {
            LogMessage("[CST-Guard] linea ignorada en %s: \"%s %s\"", CSTG_MAPS_FILE, key, profile);
            continue;
        }

        // primero slots (legacy), despues personajes
        int slotIdx = CSTG_NormalizeSlot(key, sizeof(key));
        if (slotIdx >= 0)
        {
            g_cstg_MapSet[slotIdx] = true;
            strcopy(g_cstg_MapProfile[slotIdx], CSTG_PROF_LEN, profile);
            loaded++;
        }
        else if (CSTG_ValidCharKey(key))
        {
            if (g_cstg_CharCount < CSTG_MAX_CHARS)
            {
                strcopy(g_cstg_CharKeys[g_cstg_CharCount], CSTG_SLOT_LEN, key);
                strcopy(g_cstg_CharCfg[g_cstg_CharCount], CSTG_PROF_LEN, profile);
                g_cstg_CharCount++;
                loaded++;

                // v3.0.3: pares fuera de lo oficial/historico = archivo custom
                if (!CSTG_DefaultPairKnown(key, profile))
                    bAllKnown = false;
            }
            else
                LogMessage("[CST-Guard] mapa lleno (%d personajes): \"%s %s\" queda fuera", CSTG_MAX_CHARS, key, profile);
        }
        else
        {
            LogMessage("[CST-Guard] linea ignorada en %s: \"%s %s\"", CSTG_MAPS_FILE, key, profile);
        }
    }
    delete f;

    if (bOfficialFile)
    {
        LogMessage("[CST-Guard] %d mapas cargados de %s [MAPA-OFICIAL: el archivo manda] (personajes: %d)", loaded, CSTG_MAPS_FILE, g_cstg_CharCount);
        return;
    }

    // v3.0.3 UPGRADE: archivo viejo (v2.x/3.0.x, sin marcador)
    if (bAllKnown)
    {
        // seed viejo (amy/rouge/sonic historico + lo que el owner agrego de
        // la lista oficial, ej metal): se RE-SIEMBRA al mapa oficial de 14
        // (v3.0.4: rouge regresa — rouge_r.cfg existe en el server)
        int prev = g_cstg_CharCount;
        CSTG_SeedDefaultChars();
        CSTG_SaveMapsFile();
        LogMessage("[CST-Guard] mapa viejo (%d entradas, todas oficiales/historicas): RE-SIEMBRADO a los %d perfiles oficiales (rouge REINTEGRADO via rouge_r.cfg)", prev, CSTG_DEF_CHARS);
        return;
    }

    // archivo CUSTOM (perfiles propios): se conserva TODO y se completan
    // los oficiales que falten; a partir del save, el archivo manda.
    int added = 0;
    for (int i = 0; i < CSTG_DEF_CHARS && g_cstg_CharCount < CSTG_MAX_CHARS; i++)
    {
        bool bHave = false;
        for (int k = 0; k < g_cstg_CharCount; k++)
            if (strcmp(g_cstg_CharKeys[k], g_cstg_DefCharKeys[i]) == 0)
            {
                bHave = true;
                break;
            }
        if (bHave)
            continue;

        strcopy(g_cstg_CharKeys[g_cstg_CharCount], CSTG_SLOT_LEN, g_cstg_DefCharKeys[i]);
        strcopy(g_cstg_CharCfg[g_cstg_CharCount], CSTG_PROF_LEN, g_cstg_DefCharCfgs[i]);
        g_cstg_CharCount++;
        added++;
    }

    // siempre se re-graba con el marcador: desde ESTE momento el archivo
    // manda (borrar/editar lineas se respeta en las siguientes cargas).
    CSTG_SaveMapsFile();
    if (added > 0)
        LogMessage("[CST-Guard] mapa custom: %d perfiles oficiales completados (los tuyos se conservan; desde ahora el archivo manda)", added);
    else
        LogMessage("[CST-Guard] mapa custom completo: re-grabado con marcador %s (desde ahora el archivo manda)", CSTG_MAPS_MARKER);

    if (loaded > 0)
        LogMessage("[CST-Guard] %d mapas cargados de %s (personajes: %d)", loaded, CSTG_MAPS_FILE, g_cstg_CharCount);
}

// v3.0.3: carga la tabla de personajes con el mapa oficial de 14
void CSTG_SeedDefaultChars()
{
    g_cstg_CharCount = 0;
    for (int i = 0; i < CSTG_DEF_CHARS; i++)
    {
        strcopy(g_cstg_CharKeys[g_cstg_CharCount], CSTG_SLOT_LEN, g_cstg_DefCharKeys[i]);
        strcopy(g_cstg_CharCfg[g_cstg_CharCount], CSTG_PROF_LEN, g_cstg_DefCharCfgs[i]);
        g_cstg_CharCount++;
    }
}

// v3.0.3: el par clave->perfil es oficial (los 14) o historico (los seeds
// v2.2-3.0.2: amy/rouge/sonic)? clave por equivalencia de frontera cuenta
// ("metal_sonic metal.cfg" == "metal metal.cfg"). Un archivo donde TODAS
// las entradas son asi = seed viejo -> candidato a re-sembra.
bool CSTG_DefaultPairKnown(const char[] key, const char[] profile)
{
    for (int i = 0; i < CSTG_DEF_CHARS; i++)
        if (strcmp(profile, g_cstg_DefCharCfgs[i]) == 0 && CSTG_KeyEqOrBoundary(key, g_cstg_DefCharKeys[i]))
            return true;

    // seeds historicos v2.2-3.0.2
    static const char oldKeys[3][] = { "amy", "rouge", "sonic" };
    static const char oldCfgs[3][] = { "amy.cfg", "rouge_r.cfg", "sonic.cfg" };
    for (int i = 0; i < 3; i++)
        if (strcmp(profile, oldCfgs[i]) == 0 && CSTG_KeyEqOrBoundary(key, oldKeys[i]))
            return true;

    return false;
}

// v3.0.3: key == dkey, o key = dkey + frontera ('_' '-' ' ') — el mismo
// criterio de CSTG_SignalKeyIndex, case-insensitive
bool CSTG_KeyEqOrBoundary(const char[] key, const char[] dkey)
{
    if (strcmp(key, dkey, false) == 0)
        return true;

    int klen = strlen(dkey);
    if (strncmp(key, dkey, klen, false) != 0)
        return false;

    char c = key[klen];
    return c == '_' || c == '-' || c == ' ';
}

// v3.0.3: el suite ya es dueno de ese comando base? (sm_sage = Sage.inc)
bool CSTG_SuiteOwnedCmd(const char[] base)
{
    for (int i = 0; i < sizeof(g_cstg_SuiteOwnedCmds); i++)
        if (strcmp(base, g_cstg_SuiteOwnedCmds[i]) == 0)
            return true;
    return false;
}

// registra sm_<base> (y sm_<alias> si difiere) -> perfil; el primero gana
void CSTG_RegisterDynamicAlias(const char[] alias, const char[] profile)
{
    if (strlen(alias) == 0)
        return;

    char base[CSTG_PROF_LEN];
    strcopy(base, sizeof(base), alias);
    for (int k = 0; base[k] != '\0'; k++)
    {
        char c = base[k];
        if (c >= 'A' && c <= 'Z')
            base[k] = c + 32;
        else if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_'))
            base[k] = '_';
    }

    if (strlen(base) == 0)
        return;

    // v3.0.3: comandos que el SUITE ya es dueno (sm_sage = Sage.inc, alias
    // de sm_sageset): NO se registran ni se encadenan — ciclar sets de Sage
    // no debe re-aplicar el modelo. El perfil sage.cfg se aplica igual por
    // la senal (seleccion/recuerdo usan el perfil del MAPA) o sm_cstapply.
    // sm_sonic NO esta en la lista: coexiste con Speed_sonic desde la v2.2.
    if (CSTG_SuiteOwnedCmd(base))
    {
        LogMessage("[CST-Guard] sm_%s NO registrado (el suite ya es dueno de ese comando); el perfil se aplica por senal o sm_cstapply %s", base, profile);
        return;
    }

    char existing[CSTG_PROF_LEN];
    if (g_cstg_RegisteredCmds.GetString(base, existing, sizeof(existing)))
        return; // ya registrado: se conserva el primero

    char cmd[64];
    Format(cmd, sizeof(cmd), "sm_%s", base);
    RegAdminCmd(cmd, CSTG_Cmd_DynamicProfile, ADMFLAG_GENERIC, "CST: aplica el perfil mapeado");
    g_cstg_RegisteredCmds.SetString(base, profile);
    LogMessage("[CST-Guard] comando dinamico registrado: %s -> %s", cmd, profile);
}

void CSTG_RegisterDynamicFromMaps()
{
    // personajes: alias por CLAVE (sm_rouge) y por basename del cfg (sm_rouge_r)
    for (int i = 0; i < g_cstg_CharCount; i++)
    {
        char base[CSTG_PROF_LEN];
        strcopy(base, sizeof(base), g_cstg_CharCfg[i]);
        int len = strlen(base);
        if (len > 4 && strcmp(base[len-4], ".cfg") == 0)
            base[len-4] = '\0';

        CSTG_RegisterDynamicAlias(base, g_cstg_CharCfg[i]);
        CSTG_RegisterDynamicAlias(g_cstg_CharKeys[i], g_cstg_CharCfg[i]);
    }

    // slots legacy: solo basename del cfg
    for (int i = 0; i < CSTG_MAX_MAPS; i++)
    {
        if (!g_cstg_MapSet[i])
            continue;

        char base[CSTG_PROF_LEN];
        strcopy(base, sizeof(base), g_cstg_MapProfile[i]);
        int len = strlen(base);
        if (len > 4 && strcmp(base[len-4], ".cfg") == 0)
            base[len-4] = '\0';

        CSTG_RegisterDynamicAlias(base, g_cstg_MapProfile[i]);
    }
}

void CSTG_DynamicList(char[] out, int maxLen)
{
    out[0] = '\0';
    StringMapSnapshot snap = g_cstg_RegisteredCmds.Snapshot();
    for (int i = 0; i < snap.Length; i++)
    {
        char base[CSTG_PROF_LEN], profile[CSTG_PROF_LEN];
        snap.GetKey(i, base, sizeof(base));
        g_cstg_RegisteredCmds.GetString(base, profile, sizeof(profile));

        if (strlen(out) > 0)
            StrCat(out, maxLen, ", ");
        StrCat(out, maxLen, "sm_");
        StrCat(out, maxLen, base);
        StrCat(out, maxLen, " (");
        StrCat(out, maxLen, profile);
        StrCat(out, maxLen, ")");
    }
    delete snap;
    if (strlen(out) == 0)
        strcopy(out, maxLen, "(ninguno — setea el mapa primero)");
}

// ============================================================================
// helpers
// ============================================================================

int CSTG_SlotOfModel(const char[] model)
{
    char want[PLATFORM_MAX_PATH];
    for (int i = 0; i < CSTG_MAX_MAPS; i++)
    {
        Format(want, sizeof(want), "models/survivors/survivor_%s.mdl", g_cstg_Slots[i]);
        if (strcmp(model, want) == 0)
            return i;
    }
    return -1;
}

bool CSTG_InCutscene(int client)
{
    if (!HasEntProp(client, Prop_Send, "m_hViewEntity"))
        return false;
    return GetEntPropEnt(client, Prop_Send, "m_hViewEntity") != -1;
}

void CSTG_Debug(const char[] fmt, any ...)
{
    if (!g_cstg_cvDebug.BoolValue)
        return;
    char buf[256];
    VFormat(buf, sizeof(buf), fmt, 2);
    LogMessage("[CST-Guard][debug] %s", buf);
}
