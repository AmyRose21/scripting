// =============================================================
//  amy_fall_fix.sp - SourceMod Plugin (v5.0 - BLOQUEO REAL + DETECCION CONTINUA)
//  Fix de los fall / death screams para survivors CUSTOM (CST)
//
//  POR QUE ESTE PLUGIN EXISTE (diagnostico verificado):
//  El sonido "Player.Fall" esta definido en
//  scripts/game_sounds_player.txt asi:
//
//      "Player.Fall"
//      {
//          "wave"  "player/survivor/voice/$survivor/Fall01.wav"
//          ...
//      }
//
//  La variable $survivor la resuelve el MOTOR con su tabla
//  INTERNA de personajes (gambler, mechanic, producer, coach,
//  namvet, teenangst, biker, manager). Un modelo custom NO esta
//  en esa tabla: el sistema CST (Custom Survivor Takeover)
//  hace que Amy "tome" el personaje @coach con
//  survivor_slot = "anon", y el motor resuelve $survivor -> la
//  voz del personaje original (coach). El DeathScream igual.
//
//  El talker custom (yeoh_custom_talker_*_rules.nut) SI puede
//  redirigir las lineas del sistema de respuestas (talker):
//  PlayerLedgeHang*, ScreamWhilePounced, PlayerIncapacitated,
//  etc. Pero NO puede interceptar lo que el motor emite
//  directamente por codigo (Player.Fall / DeathScream).
//  De ahi que fall y el death scream eran los UNICOS sonidos
//  que quedaban con voz equivocada -> la unica solucion es un
//  plugin SourceMod que intercepte el sonido (sound hook).
//
//  TECNICA (v3.0+): AddNormalSoundHook (idea del plugin
//  "Silenced Infected" de SilverShot):
//  https://forums.alliedmods.net/showthread.php?t=137397
//  1. El hook ve CADA sonido ANTES de reproducirse
//  2. Si sale de la entidad de un survivor custom y es voz de
//     OTRO survivor -> sonido INCORRECTO -> volume = 0.0
//  3. Si ademas coincide con patron de caida/grito ->
//     se reproduce el sonido correcto de SU carpeta
//
//  NOVEDADES v4.0 (info obtenida de los VPK CST de Amy Rose):
//   * MULTI-SURVIVOR: configs/amy_fall_fix_survivors.txt define
//     <patron_modelo> <carpeta_voz> [offset_pitch] -> sirve para
//     amy, haruka, yusuke, sara, blake... cualquier custom CST
//   * PITCH por survivor (Amy Rose = +25, igual que el talker
//     CST: pitch_offsets = 25) para que el fall suene igual al
//     resto de su voz
//   * AUTODETECCION de sonidos: al cargar el mapa se sondea
//     fall01-04, deathscream01-09 y screamwhilepounced01-06
//     (solo se usan/reproducen los que existan de verdad)
//   * FIX: la carpeta de voz de Zoey es "teenangst" (v2/v3
//     usaban "teengirl", que no existe en el juego retail)
//   * StopWrongSounds usa las 8 carpetas correctas
//
//  NOVEDADES v4.1 (fix del error de consola "[Fall Fix] Error
//  playing: the index 'PlaySound' does not exist"):
//   El VPK de voz de Amy incluye un VScript ROTO:
//   scripts/vscripts/amy_fall_scream_fix.nut. Ese script
//   detecta la caida (de ahi el "Fall detected! Survivor
//   folder: amy") y luego llama a PlaySound(), una funcion
//   que NO EXISTE en la API de VScript de L4D2 -> el interprete
//   Squirrel lanza "the index 'PlaySound' does not exist" y su
//   catch lo imprime como "[Fall Fix] Error playing: ...".
//   NUNCA pudo funcionar (ademas su StopAmbientSoundOn no puede
//   detener sonidos CHAN_VOICE del motor).
//   -> NEUTRALIZADOR AUTOMATICO: el plugin crea un logic_script
//      y ejecuta un parche RunScriptCode que anula el Think()
//      del .nut (lo deja en no-op) y define un ::PlaySound
//      vacio. El spam de la consola desaparece SIN tocar los
//      VPK del mod. Cvar: sm_amyfallfix_neutralize (defecto 1).
//
//  CAPAS DE DEFENSA (por si una falla):
//    CAPA 1: SoundHook (bloqueo preventivo + reemplazo)
//    CAPA 2: Eventos player_ledge_grab / player_incapacitated
//    CAPA 3: Timer de respaldo de 0.1s (polling de estado)
//    CAPA 4: StopSound de limpieza en los eventos
//  Cooldown compartido (0.75s) anti sonidos dobles.
//
//  *** QUE CAMBIA EN LA v5.0 (falla reportada: "no detiene el
//      sonido, se escucha el grito de un survivor al azar") ***
//   1. DETECCION CONTINUA de customs (FIX PRINCIPAL): la v4.1
//      solo detectaba el modelo en player_spawn, pero CST aplica
//      el cambio de modelo DESPUES del spawn -> el plugin creia
//      que Amy era vanilla (g_iCustom = -1) y el sound hook NO
//      bloqueaba nada. La v5.0 re-detecta en el polling de 0.1s
//      y dentro del propio hook (deteccion perezosa).
//   2. FILTROS AMPLIADOS: firma del hook con 11 params (soundEntry)
//      y cubre las 3 formas de emision del grito: ruta resuelta
//      (player/survivor/voice/X/Fall03.wav), nombre de script del
//      motor ("Player.Fall") y variable sin resolver ($survivor).
//   3. BLOQUEO REAL: Plugin_Stop (verificado en el codigo fuente de
//      SourceMod, vsound.cpp: Pl_Stop -> MRES_SUPERCEDE -> el
//      sonido original NI SE EMITE). v4.1 usaba volume=0.0.
//      Cvar sm_amyfallfix_mute: 0=volumen, 1=stop (defecto), 2=nadie
//   4. MODO ESPIA de diagnostico: sm_amysoundlog <segundos> o
//      sm_amyfallfix_debug 2 -> registra cada sonido de voz con su
//      entidad y ruta (consola + logs/amy_fall_fix_spy.log).
//
//  COMPILACION:
//   - El .smx ya viene compilado en este paquete.
//   - Para recompilar: spcomp64 amy_fall_fix.sp (Linux, SM 1.10+)
// =============================================================

#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_VERSION   "5.0"
#define POLL_INTERVAL    0.1     // segundos entre chequeos de respaldo
#define VOICE_COOLDOWN   0.75    // anti sonidos dobles entre capas
#define NEUTRALIZE_REPEAT 30.0   // v4.1: re-aplicar el parche del .nut cada 30s
#define MAX_CUSTOMS      12      // max. survivors custom en el config
#define MAX_FALL_SND     9       // fall01..09
#define MAX_DEATH_SND    9       // deathscream01..09
#define MAX_POUNCE_SND   7       // screamwhilepounced01..06 + 02a
#define MAX_EXTRA_PATTERNS 32

// Tipos de sonido a reponer (codificados en el timer del hook)
#define SNDTYPE_FALL    0
#define SNDTYPE_DEATH   1
#define SNDTYPE_POUNCE  2

// ---------------------------------------------------------
// Survivors originales (carpetas de voz del MOTOR - para el
// StopSound de limpieza). FIX v4: Zoey = teenangst.
// Amy CST toma el slot de @coach -> el sonido incorrecto mas
// frecuente es el de coach, pero se cubren los 8.
// ---------------------------------------------------------
char g_BaseSurvivors[][] = {
    "gambler",    // Nick
    "mechanic",   // Ellis
    "producer",   // Rochelle
    "coach",      // Coach (slot que toma Amy CST)
    "namvet",     // Bill
    "teenangst",  // Zoey  (FIX v4: antes "teengirl", no existe)
    "biker",      // Francis
    "manager"     // Louis
};

// ---------------------------------------------------------
// Patrones que identifican un sonido de caida/grito dentro de
// la ruta del sample (comparacion sin mayusculas)
// ---------------------------------------------------------
char g_sBlockPatterns[][] = {
    "fall",
    "scream",
    "ledge"
};

// ---------------------------------------------------------
// Tabla de survivors custom (configs/amy_fall_fix_survivors.txt)
// ---------------------------------------------------------
char g_sModelPat[MAX_CUSTOMS][64];      // patron a buscar en la ruta del .mdl
char g_sVoiceFld[MAX_CUSTOMS][64];      // carpeta de voz propia (ej: amy)
int  g_iPitchOff[MAX_CUSTOMS];          // offset de pitch (ej: +25 Amy CST)
int  g_iCustomCount = 0;

// Sonidos detectados por custom (sondeo con PrecacheSound en OnMapStart)
char g_sFallSnd[MAX_CUSTOMS][MAX_FALL_SND][PLATFORM_MAX_PATH];
int  g_iFallCnt[MAX_CUSTOMS];
char g_sDeathSnd[MAX_CUSTOMS][MAX_DEATH_SND][PLATFORM_MAX_PATH];
int  g_iDeathCnt[MAX_CUSTOMS];
char g_sPounceSnd[MAX_CUSTOMS][MAX_POUNCE_SND][PLATFORM_MAX_PATH];
int  g_iPounceCnt[MAX_CUSTOMS];

// ---------------------------------------------------------
// Estado por jugador
// ---------------------------------------------------------
int   g_iCustom[MAXPLAYERS + 1];         // indice de custom detectado (-1 = vanilla)
bool  g_bLedgeHandled[MAXPLAYERS + 1];   // ledge en curso (ventana de bloqueo)
bool  g_bIncapHandled[MAXPLAYERS + 1];   // incap en curso (ventana de bloqueo)
float g_fLastVoice[MAXPLAYERS + 1];      // cooldown anti-dobles
float g_fNextDetect[MAXPLAYERS + 1];     // v5.0: throttle de re-deteccion por cliente
float g_fSpyUntil;                       // v5.0: modo espia activo hasta este instante

Handle g_hPollTimer = null;

// v4.1: neutralizador del amy_fall_scream_fix.nut del mod
int    g_iScriptEntRef    = INVALID_ENT_REFERENCE;
Handle g_hNeutralizeTimer = null;
bool   g_bNutPatchFailed  = false;

// Patrones extra de bloqueo (archivo opcional v3, se conserva)
int  g_iExtraPatternCount = 0;
char g_ExtraPatterns[MAX_EXTRA_PATTERNS][PLATFORM_MAX_PATH];

// ---------------------------------------------------------
// ConVars
// ---------------------------------------------------------
ConVar g_cvEnabled;
ConVar g_cvDebug;
ConVar g_cvVolume;
ConVar g_cvDownload;
ConVar g_cvWindow;
ConVar g_cvNeutralize;   // v4.1
ConVar g_cvMute;         // v5.0: estrategia de silenciado

public Plugin myinfo =
{
    name        = "Amy Fall Scream Fix (CST)",
    author      = "Z.ai",
    description = "Fix de fall/death screams para survivors custom CST + neutralizador del .nut roto del mod",
    version     = PLUGIN_VERSION,
    url         = ""
};

// =============================================================
// AskPluginLoad2 - comprobar juego (patron de SilverShot)
// =============================================================
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion engine = GetEngineVersion();
    if (engine != Engine_Left4Dead2)
    {
        strcopy(error, err_max, "Plugin solo compatible con Left 4 Dead 2.");
        return APLRes_SilentFailure;
    }
    return APLRes_Success;
}

// =============================================================
// OnPluginStart
// =============================================================
public void OnPluginStart()
{
    g_cvEnabled  = CreateConVar("sm_amyfallfix_enabled",  "1", "1 = plugin activado, 0 = desactivado", _, true, 0.0, true, 1.0);
    g_cvDebug    = CreateConVar("sm_amyfallfix_debug",    "0", "0 = off, 1 = mensajes de debug, 2 = modo espia (registra TODOS los sonidos de voz)", _, true, 0.0, true, 2.0);
    g_cvVolume   = CreateConVar("sm_amyfallfix_volume",   "1.0", "Volumen de los sonidos reproducidos (0.0 - 1.0)", _, true, 0.0, true, 1.0);
    g_cvDownload = CreateConVar("sm_amyfallfix_download", "1", "1 = clientes descargan los sonidos desde el servidor", _, true, 0.0, true, 1.0);
    g_cvWindow   = CreateConVar("sm_amyfallfix_window",   "1", "1 = bloquear CUALQUIER voz ajena mientras cuelga/esta incapacitado", _, true, 0.0, true, 1.0);
    g_cvNeutralize = CreateConVar("sm_amyfallfix_neutralize", "1", "1 = neutraliza el amy_fall_scream_fix.nut del mod (evita el error 'PlaySound does not exist')", _, true, 0.0, true, 1.0);

    // v5.0: estrategia de silenciado (1 = Plugin_Stop, bloqueo total)
    g_cvMute      = CreateConVar("sm_amyfallfix_mute", "1", "Como silenciar el grito original: 0 = volumen 0.0, 1 = bloqueo total (recomendado), 2 = emitir a nadie", _, true, 0.0, true, 2.0);

    AutoExecConfig(true, "amy_fall_fix");

    // Eventos
    HookEvent("player_ledge_grab",     Event_LedgeGrab);
    HookEvent("player_incapacitated",  Event_Incapacitated);
    HookEvent("player_spawn",          Event_PlayerSpawn);
    HookEvent("player_death",          Event_PlayerDeath);
    HookEvent("round_start",           Event_RoundStart);

    // v5.0: comando de diagnostico (modo espia)
    RegAdminCmd("sm_amysoundlog", Cmd_SoundLog, ADMFLAG_GENERIC, "sm_amysoundlog <segundos> - registra todos los sonidos de voz para diagnostico");

    // CAPA 1: Sound Hook (bloqueo preventivo)
    AddNormalSoundHook(SoundHook);

    // Configs
    LoadCustomSurvivors();
    LoadExtraPatterns();

    // Soporte de carga tardia
    for (int i = 1; i <= MaxClients; i++)
    {
        g_fLastVoice[i]    = 0.0;
        g_fNextDetect[i]   = 0.0;
        g_iCustom[i]       = -1;
        g_bLedgeHandled[i] = false;
        g_bIncapHandled[i] = false;
        if (IsClientInGame(i))
            g_iCustom[i] = DetectCustomSurvivor(i);
    }

    PrintToServer("[AmyFallFix] v%s cargado: %d survivor(s) custom en config | Sound Hook v5 (bloqueo Plugin_Stop) + deteccion continua + 4 capas + neutralizador .nut",
                  PLUGIN_VERSION, g_iCustomCount);
    PrintToServer("[AmyFallFix] Diagnostico si algo sigue sonando: sm_amysoundlog 20 y haz caer a Amy; log en addons/sourcemod/logs/amy_fall_fix_spy.log");
}

public void OnPluginEnd()
{
    RemoveNormalSoundHook(SoundHook);
    KillNeutralizeTimer();
}

// =============================================================
// OnMapStart - sondear sonidos existentes + downloads + timer
// =============================================================
public void OnMapStart()
{
    ProbeCustomSounds();

    KillPollTimer();
    g_hPollTimer = CreateTimer(POLL_INTERVAL, Timer_Poll, _, TIMER_REPEAT);

    // v4.1: neutralizar el amy_fall_scream_fix.nut del mod
    SetupNutNeutralizer();
}

public void OnMapEnd()
{
    KillPollTimer();
    KillNeutralizeTimer();
}

void KillPollTimer()
{
    if (g_hPollTimer != null)
    {
        KillTimer(g_hPollTimer);
        g_hPollTimer = null;
    }
}

// =============================================================
// v4.1: NEUTRALIZADOR DEL VSCRIPT ROTO DEL MOD
// El VPK de voz de Amy incluye scripts/vscripts/
// amy_fall_scream_fix.nut, que llama a PlaySound() ( funcion
// INEXISTENTE en L4D2 ) -> "[Fall Fix] Error playing: the index
// 'PlaySound' does not exist" en cada caida.
// El parche Squirrel (idempotente):
//   1. ::Fall_Fix.Think  -> funcion vacia (el polling del .nut
//      deja de detectar/imprimir/intentar reproducir)
//   2. ::PlaySound       -> funcion vacia (por si algo la llama)
// Se aplica al cargar el mapa (2s/6s/12s, esperando a que el
// .nut termine de registrarse) y se re-aplica cada 30s (el VM
// de Squirrel se reinicia entre mapas/rondas).
// =============================================================
void SetupNutNeutralizer()
{
    KillNeutralizeTimer();

    if (!g_cvNeutralize.BoolValue)
        return;

    g_iScriptEntRef   = INVALID_ENT_REFERENCE;
    g_bNutPatchFailed = false;

    // Esperar a que el .nut del mod cargue (el propio .nut
    // reintenta su registro durante hasta 15 segundos)
    CreateTimer(2.0,  Timer_NeutralizeOnce);
    CreateTimer(6.0,  Timer_NeutralizeOnce);
    CreateTimer(12.0, Timer_NeutralizeOnce);

    // Re-aplicacion periodica (idempotente y barata)
    g_hNeutralizeTimer = CreateTimer(NEUTRALIZE_REPEAT, Timer_NeutralizeRepeat, _, TIMER_REPEAT);
}

void KillNeutralizeTimer()
{
    if (g_hNeutralizeTimer != null)
    {
        KillTimer(g_hNeutralizeTimer);
        g_hNeutralizeTimer = null;
    }
}

public Action Timer_NeutralizeOnce(Handle timer)
{
    ApplyNutPatch();
    return Plugin_Stop;
}

public Action Timer_NeutralizeRepeat(Handle timer)
{
    if (g_bNutPatchFailed || !g_cvNeutralize.BoolValue)
        return Plugin_Stop;

    ApplyNutPatch();
    return Plugin_Continue;
}

// Ejecuta el parche Squirrel via RunScriptCode
void ApplyNutPatch()
{
    if (g_bNutPatchFailed || !g_cvNeutralize.BoolValue)
        return;

    int ent = GetScriptEntity();
    if (ent == -1)
    {
        g_bNutPatchFailed = true;
        LogError("[Amy Fall Fix] No se pudo crear el logic_script para neutralizar el .nut del mod.");
        LogError("[Amy Fall Fix] El error '[Fall Fix] Error playing: ...' seguira apareciendo (es solo spam, no afecta al juego).");
        return;
    }

    // Parche Squirrel (idempotente):
    //  - Think() del .nut roto -> no-op
    //  - ::PlaySound -> funcion vacia (el error desaparece)
    SetVariantString("if(\"Fall_Fix\" in ::getroottable()) { ::Fall_Fix.Think = function() {} }; if(!(\"PlaySound\" in ::getroottable())) { ::PlaySound <- function(...) {} }");

    if (AcceptEntityInput(ent, "RunScriptCode", ent, ent))
    {
        if (g_cvDebug.BoolValue)
            PrintToServer("[Amy Fall Fix] Parche neutralizador del .nut aplicado (RunScriptCode).");
    }
    else if (!g_bNutPatchFailed)
    {
        g_bNutPatchFailed = true;
        LogError("[Amy Fall Fix] RunScriptCode no aceptado en este servidor: neutralizador desactivado.");
        LogError("[Amy Fall Fix] Alternativa manual: extraer y borrar scripts/vscripts/amy_fall_scream_fix.nut del VPK de voz.");
    }
}

// Crea (o reutiliza) la entidad que ejecuta el VScript
int GetScriptEntity()
{
    int ent = EntRefToEntIndex(g_iScriptEntRef);
    if (ent > 0 && IsValidEntity(ent))
        return ent;

    ent = CreateEntityByName("logic_script");
    if (ent == -1)
        return -1;

    if (!DispatchSpawn(ent))
        return -1;

    g_iScriptEntRef = EntIndexToEntRef(ent);
    return ent;
}

// =============================================================
// ProbeCustomSounds - autodeteccion de sonidos por custom
// Sondea con PrecacheSound (ademas PRECACHEA los validos) y
// registra en la tabla de descargas los que existan.
// Asi el plugin se adapta solo a lo que realmente hay montado
// (fall01-04, deathscream01-09, screamwhilepounced01-06+02a).
// =============================================================
void ProbeCustomSounds()
{
    char snd[PLATFORM_MAX_PATH];

    for (int c = 0; c < g_iCustomCount; c++)
    {
        g_iFallCnt[c]   = 0;
        g_iDeathCnt[c]  = 0;
        g_iPounceCnt[c] = 0;

        // Fall01..Fall09
        for (int j = 1; j <= MAX_FALL_SND; j++)
        {
            Format(snd, sizeof(snd), "player/survivor/voice/%s/Fall%02d.wav", g_sVoiceFld[c], j);
            if (PrepareSound(snd))
            {
                strcopy(g_sFallSnd[c][g_iFallCnt[c]], PLATFORM_MAX_PATH, snd);
                g_iFallCnt[c]++;
            }
        }

        // DeathScream01..09 (Amy CST trae 9, no 5)
        for (int j = 1; j <= MAX_DEATH_SND; j++)
        {
            Format(snd, sizeof(snd), "player/survivor/voice/%s/DeathScream%02d.wav", g_sVoiceFld[c], j);
            if (PrepareSound(snd))
            {
                strcopy(g_sDeathSnd[c][g_iDeathCnt[c]], PLATFORM_MAX_PATH, snd);
                g_iDeathCnt[c]++;
            }
        }

        // ScreamWhilePounced01..06 (+ la variante 02a)
        for (int j = 1; j <= 6; j++)
        {
            Format(snd, sizeof(snd), "player/survivor/voice/%s/ScreamWhilePounced%02d.wav", g_sVoiceFld[c], j);
            if (PrepareSound(snd))
            {
                strcopy(g_sPounceSnd[c][g_iPounceCnt[c]], PLATFORM_MAX_PATH, snd);
                g_iPounceCnt[c]++;
            }
        }
        Format(snd, sizeof(snd), "player/survivor/voice/%s/ScreamWhilePounced02a.wav", g_sVoiceFld[c]);
        if (PrepareSound(snd))
        {
            strcopy(g_sPounceSnd[c][g_iPounceCnt[c]], PLATFORM_MAX_PATH, snd);
            g_iPounceCnt[c]++;
        }

        // Resumen / avisos
        if (g_iFallCnt[c] == 0)
        {
            LogError("[Amy Fall Fix] El survivor custom '%s' (voz '%s') NO tiene sonidos Fall01-09 audibles.",
                     g_sModelPat[c], g_sVoiceFld[c]);
            LogError("[Amy Fall Fix] Verifica que el VPK de voz este montado en el servidor.");
        }
        else if (g_cvDebug.BoolValue)
        {
            PrintToServer("[Amy Fall Fix] '%s': %d fall, %d deathscream, %d pounce detectados.",
                          g_sVoiceFld[c], g_iFallCnt[c], g_iDeathCnt[c], g_iPounceCnt[c]);
        }
    }
}

// Sondear + precachear + registrar en downloads si existe
bool PrepareSound(const char[] sound)
{
    char path[PLATFORM_MAX_PATH];
    Format(path, sizeof(path), "sound/%s", sound);

    if (g_cvDownload.BoolValue && FileExists(path))
    {
        AddFileToDownloadsTable(path);
    }

    return PrecacheSound(sound);
}

// =============================================================
// Limpieza por cliente
// =============================================================
public void OnClientDisconnect(int client)
{
    g_iCustom[client]       = -1;
    g_bLedgeHandled[client] = false;
    g_bIncapHandled[client] = false;
    g_fLastVoice[client]    = 0.0;
    g_fNextDetect[client]   = 0.0;
}

// =============================================================
// CAPA 1: SOUND HOOK (v5.0)
// Intercepta CADA sonido del juego antes de reproducirse.
// CAMBIOS v5.0 respecto a la v4.1:
//  - Firma con soundEntry + seed (11 params, sobrecarga estable
//    en SM 1.10..1.13): permite ver el nombre de script del motor
//  - Cubre las 3 formas de emision del grito: ruta resuelta,
//    nombre de script ("Player.Fall") y "$survivor" sin resolver
//  - Deteccion perezosa dentro del hook (CST cambia el modelo
//    DESPUES del player_spawn -> la v4.1 veia "vanilla" y no
//    bloqueaba nada)
//  - Bloqueo real con Plugin_Stop (el sonido original NO se emite)
// =============================================================
public Action SoundHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH],
                        int &entity, int &channel, float &volume, int &level, int &pitch, int &flags,
                        char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
    if (!g_cvEnabled.BoolValue)
        return Plugin_Continue;

    // ---------------------------------------------------------
    // Clasificar el sonido. El motor puede entregar el grito de
    // varias formas y la v4.1 solo cubria la primera:
    //   a) ruta resuelta: player/survivor/voice/coach/Fall03.wav
    //   b) nombre de script: "Player.Fall" (en soundEntry o sample)
    //   c) variable sin resolver: .../$survivor/Fall01.wav
    // ---------------------------------------------------------
    bool isVoicePath  = (StrContains(sample, "player/survivor/voice/", false) != -1);
    bool hasDollar    = (StrContains(sample, "$survivor", false) != -1);
    bool isFallScript = (!isVoicePath && (IsEngineFallName(sample) || IsEngineFallName(soundEntry)));

    // Modo espia (diagnostico): registrar todo lo relevante
    if ((g_cvDebug.IntValue >= 2 || GetGameTime() < g_fSpyUntil)
        && (isVoicePath || isFallScript || hasDollar || channel == SNDCHAN_VOICE))
    {
        SpyLog(entity, channel, sample, soundEntry);
    }

    if (!isVoicePath && !isFallScript && !hasDollar)
        return Plugin_Continue;

    // ---------------------------------------------------------
    // Resolver la entidad emisora (con re-deteccion perezosa:
    // el FIX PRINCIPAL de la v5.0)
    // ---------------------------------------------------------
    int c = -1;
    if (entity >= 1 && entity <= MaxClients && IsClientInGame(entity))
    {
        if (g_iCustom[entity] < 0)
            c = LazyDetect(entity);
        else
            c = g_iCustom[entity];
    }

    // ---------------------------------------------------------
    // Caso 1: la entidad ES un survivor custom
    // ---------------------------------------------------------
    if (c >= 0)
    {
        // Los sonidos de SU PROPIA carpeta son correctos: pasar
        if (isVoicePath && OwnFolder(sample, c))
            return Plugin_Continue;

        bool isFallPattern = MatchesBlockPattern(sample);
        bool inWindow = g_bLedgeHandled[entity] || g_bIncapHandled[entity];

        // Bloquear si es grito del motor, patron de caida/grito o
        // esta en plena caida/colgado/incap (ventana)
        if (isFallScript || hasDollar || isFallPattern || (g_cvWindow.BoolValue && inWindow))
        {
            if (g_cvDebug.IntValue >= 1)
            {
                if (isFallScript || hasDollar)
                    PrintToServer("[AmyFallFix] Grito del MOTOR bloqueado por nombre de script (%s): '%s' entry='%s'",
                                  g_sVoiceFld[c], sample, soundEntry);
                else if (isFallPattern)
                    PrintToServer("[AmyFallFix] Sonido incorrecto bloqueado por patron (%s): %s", g_sVoiceFld[c], sample);
                else
                    PrintToServer("[AmyFallFix] Voz incorrecta bloqueada por ventana (%s): %s", g_sVoiceFld[c], sample);
            }

            // Programar el reemplazo en el proximo frame (emitir
            // dentro del propio hook no es seguro)
            if ((isFallScript || hasDollar || isFallPattern)
                && GetGameTime() - g_fLastVoice[entity] >= VOICE_COOLDOWN)
            {
                g_fLastVoice[entity] = GetGameTime();
                CreateTimer(0.0, Timer_HookVoice,
                            (GetClientUserId(entity) << 2) | ClassifySndType(sample, soundEntry));
            }

            return BlockSound(numClients, volume);
        }

        return Plugin_Continue;
    }

    // ---------------------------------------------------------
    // Caso 2: entidad vanilla o sin entidad. Si es un grito del
    // MOTOR sin entidad valida y hay un custom en plena ventana
    // de caida, bloquearlo igual (defensa extra: algunas emisiones
    // llegan con entidad 0 o invalida)
    // ---------------------------------------------------------
    if ((isFallScript || hasDollar) && AnyCustomInWindow())
    {
        if (g_cvDebug.IntValue >= 1)
            PrintToServer("[AmyFallFix] Grito del MOTOR sin entidad valida, bloqueado por ventana: '%s'", sample);

        return BlockSound(numClients, volume);
    }

    // Voz desde una entidad vanilla: no tocar
    return Plugin_Continue;
}

// v5.0: aplicar la estrategia de silenciado configurada
Action BlockSound(int &numClients, float &volume)
{
    switch (g_cvMute.IntValue)
    {
        case 2:
        {
            numClients = 0;                 // emitir a nadie
            return Plugin_Changed;
        }
        case 0:
        {
            volume = 0.0;                   // volumen cero (clasico)
            return Plugin_Changed;
        }
    }

    // 1 (defecto): Plugin_Stop = el sonido original NI SE EMITE
    // (verificado en el codigo fuente de SourceMod, vsound.cpp:
    //  Pl_Stop -> MRES_SUPERCEDE -> se salta la llamada original)
    return Plugin_Stop;
}

// v5.0: nombres de script del motor que son gritos de caida
bool IsEngineFallName(const char[] name)
{
    if (name[0] == '\0')
        return false;

    return (StrEqual(name, "Player.Fall", false)
         || StrEqual(name, "Player.ScreamWhilePounced", false)
         || StrEqual(name, "Player.FallScream", false));
}

// v5.0: es un sonido de la carpeta de voz PROPIA del custom?
// (StrContains en vez de prefijo: algunos sonidos llegan con
//  prefijos como ")" delante de la ruta)
bool OwnFolder(const char[] sample, int c)
{
    int pos = StrContains(sample, "player/survivor/voice/", false);
    if (pos == -1)
        return false;

    int len = strlen(g_sVoiceFld[c]);
    return (strncmp(sample[pos + 21], g_sVoiceFld[c], len, false) == 0
            && sample[pos + 21 + len] == '/');
}

// v5.0: clasificar el tipo de grito por contenido (sample + entry)
int ClassifySndType(const char[] sample, const char[] soundEntry)
{
    if (StrContains(soundEntry, "pounced", false) != -1
        || StrContains(sample, "screamwhilepounced", false) != -1)
        return SNDTYPE_POUNCE;
    if (StrContains(sample, "scream", false) != -1)
        return SNDTYPE_DEATH;
    return SNDTYPE_FALL;
}

// v5.0: hay algun custom en ventana de caida/colgado/incap?
bool AnyCustomInWindow()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if ((g_bLedgeHandled[i] || g_bIncapHandled[i]) && g_iCustom[i] >= 0)
            return true;
    }
    return false;
}

// v5.0: re-deteccion perezosa con throttle. CST cambia el modelo
// DESPUES del player_spawn, por eso hay que re-comprobar. Se llama
// desde el polling y desde dentro del propio sound hook.
int LazyDetect(int client)
{
    if (GetGameTime() < g_fNextDetect[client])
        return g_iCustom[client];

    g_fNextDetect[client] = GetGameTime() + 0.5;

    int before = g_iCustom[client];
    g_iCustom[client] = DetectCustomSurvivor(client);

    if (g_iCustom[client] >= 0 && before < 0)
    {
        // Aviso unico por transicion: sirve para verificar en
        // consola que la deteccion continua funciona
        PrintToServer("[AmyFallFix] Custom detectado (deteccion continua): %N -> voz '%s'",
                      client, g_sVoiceFld[g_iCustom[client]]);
    }

    return g_iCustom[client];
}

// v5.0: log del modo espia (consola + logs/amy_fall_fix_spy.log)
void SpyLog(int entity, int channel, const char[] sample, const char[] soundEntry)
{
    char name[MAX_NAME_LENGTH];
    if (entity >= 1 && entity <= MaxClients && IsClientInGame(entity))
        GetClientName(entity, name, sizeof(name));
    else
        strcopy(name, sizeof(name), "(sin entidad)");

    PrintToServer("[AmyFallFix SPY] ent=%d (%s) ch=%d sample='%s' entry='%s'",
                  entity, name, channel, sample, soundEntry);
    LogToFile("amy_fall_fix_spy.log", "ent=%d (%s) ch=%d sample='%s' entry='%s'",
              entity, name, channel, sample, soundEntry);
}

// v5.0: sm_amysoundlog <segundos> - activar el modo espia
public Action Cmd_SoundLog(int client, int args)
{
    int secs = 15;
    if (args >= 1)
    {
        char arg[16];
        GetCmdArg(1, arg, sizeof(arg));
        secs = StringToInt(arg);
    }
    if (secs < 1)   secs = 1;
    if (secs > 300) secs = 300;

    g_fSpyUntil = GetGameTime() + float(secs);

    ReplyToCommand(client, "[AmyFallFix] MODO ESPIA activo durante %d segundos. Haz caer a Amy AHORA.", secs);
    ReplyToCommand(client, "[AmyFallFix] El log queda en addons/sourcemod/logs/amy_fall_fix_spy.log (y en consola).");
    return Plugin_Handled;
}

// Dispatcher: userid y tipo de sonido codificados en un entero
// (userid << 2 | tipo). Se resuelve al disparar el timer.
public Action Timer_HookVoice(Handle timer, int value)
{
    int client = GetClientOfUserId(value >> 2);
    if (client <= 0 || !IsClientInGame(client) || g_iCustom[client] < 0)
        return Plugin_Stop;

    int c = g_iCustom[client];

    switch (value & 3)
    {
        case SNDTYPE_POUNCE:
        {
            if (g_iPounceCnt[c] > 0) PlayPounceScream(client, c);
            else if (g_iDeathCnt[c] > 0) PlayDeathScream(client, c);
        }
        case SNDTYPE_DEATH:
        {
            if (g_iDeathCnt[c] > 0) PlayDeathScream(client, c);
            else if (g_iFallCnt[c] > 0) PlayFallSound(client, c);
        }
        default: // SNDTYPE_FALL
        {
            if (g_iFallCnt[c] > 0) PlayFallSound(client, c);
            else if (g_iDeathCnt[c] > 0) PlayDeathScream(client, c);
        }
    }

    return Plugin_Stop;
}

// ---------------------------------------------------------
// ¿El sample coincide con un patron de caida/grito?
// ---------------------------------------------------------
bool MatchesBlockPattern(const char[] sample)
{
    for (int i = 0; i < sizeof(g_sBlockPatterns); i++)
    {
        if (StrContains(sample, g_sBlockPatterns[i], false) != -1)
            return true;
    }
    for (int i = 0; i < g_iExtraPatternCount; i++)
    {
        if (StrContains(sample, g_ExtraPatterns[i], false) != -1)
            return true;
    }
    return false;
}

// =============================================================
// HELPER: detectar a que survivor custom corresponde un cliente
// (por el patron del modelo del config; -1 si es vanilla)
// =============================================================
int DetectCustomSurvivor(int client)
{
    if (client <= 0 || !IsClientInGame(client))
        return -1;

    char model[PLATFORM_MAX_PATH];
    GetClientModel(client, model, sizeof(model));
    if (model[0] == '\0')
        return -1;

    for (int c = 0; c < g_iCustomCount; c++)
    {
        if (StrContains(model, g_sModelPat[c], false) != -1)
            return c;
    }
    return -1;
}

// =============================================================
// EVENTO: player_spawn
// =============================================================
public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client))
        return;

    g_iCustom[client]       = DetectCustomSurvivor(client);
    g_bLedgeHandled[client] = false;
    g_bIncapHandled[client] = false;
}

// =============================================================
// EVENTO: player_death
// =============================================================
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client))
        return;

    g_bLedgeHandled[client] = false;
    g_bIncapHandled[client] = false;
}

// =============================================================
// EVENTO: round_start
// =============================================================
public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bLedgeHandled[i] = false;
        g_bIncapHandled[i] = false;
    }

    // v4.1: el VM de Squirrel se reinicia con la ronda -> re-parchear
    if (g_cvNeutralize.BoolValue && !g_bNutPatchFailed)
    {
        CreateTimer(2.0, Timer_NeutralizeOnce);
        CreateTimer(8.0, Timer_NeutralizeOnce);
    }
}

// =============================================================
// EVENTO: player_ledge_grab (CAPA 2)
// =============================================================
public void Event_LedgeGrab(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_cvEnabled.BoolValue)
        return;

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client) || g_iCustom[client] < 0)
        return;

    if (g_bLedgeHandled[client])
        return;
    g_bLedgeHandled[client] = true;

    if (g_cvDebug.BoolValue)
        PrintToServer("[Amy Fall Fix] Ledge grab de '%s' detectado (evento).", g_sVoiceFld[g_iCustom[client]]);

    HandleFall(client, true);
}

// =============================================================
// EVENTO: player_incapacitated (CAPA 2)
// =============================================================
public void Event_Incapacitated(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_cvEnabled.BoolValue)
        return;

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client) || g_iCustom[client] < 0)
        return;

    if (g_bIncapHandled[client])
        return;
    g_bIncapHandled[client] = true;

    if (g_cvDebug.BoolValue)
        PrintToServer("[Amy Fall Fix] Incapacitacion de '%s' detectada (evento).", g_sVoiceFld[g_iCustom[client]]);

    HandleFall(client, false);
}

// =============================================================
// NUCLEO: procesar una caida/incap de un custom (CAPA 2)
// =============================================================
void HandleFall(int client, bool isLedge)
{
    // CAPA 4: limpieza por si el hook no bloqueo algo
    StopWrongSounds(client);
    StopCustomSounds(client);

    // Reproducir el sonido correcto (cooldown anti-dobles:
    // si el Sound Hook ya lo disparo, no se repite)
    if (GetGameTime() - g_fLastVoice[client] < VOICE_COOLDOWN)
        return;

    g_fLastVoice[client] = GetGameTime();

    int c = g_iCustom[client];
    if (c < 0)
        return;

    // Ledge -> fall scream / Incap -> death scream
    if (isLedge)
    {
        if (g_iFallCnt[c] > 0)
            PlayFallSound(client, c);
    }
    else
    {
        if (g_iDeathCnt[c] > 0)
            PlayDeathScream(client, c);
        else if (g_iFallCnt[c] > 0)
            PlayFallSound(client, c);
    }
}

// =============================================================
// CAPA 4: StopSound de limpieza (por si el hook no atrapo algo)
// Las 8 carpetas VANILLA del motor (con teenangst CORREGIDO).
// StopSound sobre rutas inexistentes es inofensivo.
// =============================================================
void StopWrongSounds(int client)
{
    StopSound(client, SNDCHAN_VOICE, "Player.Fall");
    StopSound(client, SNDCHAN_VOICE, "Player.ScreamWhilePounced");

    char s[PLATFORM_MAX_PATH];
    for (int i = 0; i < sizeof(g_BaseSurvivors); i++)
    {
        for (int j = 1; j <= 4; j++)
        {
            Format(s, sizeof(s), "player/survivor/voice/%s/Fall%02d.wav", g_BaseSurvivors[i], j);
            StopSound(client, SNDCHAN_VOICE, s);
        }
        for (int j = 1; j <= 9; j++)
        {
            Format(s, sizeof(s), "player/survivor/voice/%s/DeathScream%02d.wav", g_BaseSurvivors[i], j);
            StopSound(client, SNDCHAN_VOICE, s);
        }
    }
}

// Detener los propios antes de re-emitir (evita solaparse)
void StopCustomSounds(int client)
{
    int c = g_iCustom[client];
    if (c < 0)
        return;

    for (int i = 0; i < g_iFallCnt[c]; i++)
        StopSound(client, SNDCHAN_VOICE, g_sFallSnd[c][i]);
    for (int i = 0; i < g_iDeathCnt[c]; i++)
        StopSound(client, SNDCHAN_VOICE, g_sDeathSnd[c][i]);
    for (int i = 0; i < g_iPounceCnt[c]; i++)
        StopSound(client, SNDCHAN_VOICE, g_sPounceSnd[c][i]);
}

// =============================================================
// HELPER: reproducir el fall sound del custom
// Pitch = aleatorio 90-100 (como Player.Fall del engine:
// "pitch" "90,100") + offset del config (Amy CST: +25)
// =============================================================
void PlayFallSound(int client, int c)
{
    if (g_iFallCnt[c] <= 0)
        return;

    int idx = GetRandomInt(0, g_iFallCnt[c] - 1);

    // SNDLEVEL_SCREAMING = 90dB (igual que Player.Fall del motor)
    EmitSoundToAll(g_sFallSnd[c][idx], client, SNDCHAN_VOICE, SNDLEVEL_SCREAMING, _,
                   g_cvVolume.FloatValue, GetRandomInt(90, 100) + g_iPitchOff[c]);

    if (g_cvDebug.BoolValue)
        PrintToServer("[Amy Fall Fix] Reproduciendo fall: %s (pitch %d)", g_sFallSnd[c][idx], 100 + g_iPitchOff[c]);
}

// =============================================================
// HELPER: reproducir el death scream del custom
// =============================================================
void PlayDeathScream(int client, int c)
{
    if (g_iDeathCnt[c] <= 0)
        return;

    int idx = GetRandomInt(0, g_iDeathCnt[c] - 1);

    // SNDLEVEL_TRAIN = 100dB (grito a maxima intensidad)
    EmitSoundToAll(g_sDeathSnd[c][idx], client, SNDCHAN_VOICE, SNDLEVEL_TRAIN, _,
                   g_cvVolume.FloatValue, GetRandomInt(90, 100) + g_iPitchOff[c]);

    if (g_cvDebug.BoolValue)
        PrintToServer("[Amy Fall Fix] Reproduciendo death scream: %s", g_sDeathSnd[c][idx]);
}

// =============================================================
// HELPER: reproducir el pounce scream del custom (si el talker
// del custom no lo cubriera, el hook lo reemplaza aqui)
// =============================================================
void PlayPounceScream(int client, int c)
{
    if (g_iPounceCnt[c] <= 0)
        return;

    int idx = GetRandomInt(0, g_iPounceCnt[c] - 1);

    // SNDLEVEL_TRAIN = 100dB (igual que Player.ScreamWhilePounced)
    EmitSoundToAll(g_sPounceSnd[c][idx], client, SNDCHAN_VOICE, SNDLEVEL_TRAIN, _,
                   g_cvVolume.FloatValue, GetRandomInt(90, 100) + g_iPitchOff[c]);

    if (g_cvDebug.BoolValue)
        PrintToServer("[Amy Fall Fix] Reproduciendo pounce scream: %s", g_sPounceSnd[c][idx]);
}

// =============================================================
// CAPA 3: TIMER de respaldo (polling de estado cada 0.1s)
// =============================================================
public Action Timer_Poll(Handle timer)
{
    if (!g_cvEnabled.BoolValue)
        return Plugin_Continue;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || GetClientTeam(client) != 2)
            continue; // solo survivors (equipo 2)

        // v5.0: DETECCION CONTINUA (fix principal). El sistema CST
        // cambia el modelo del survivor DESPUES del player_spawn,
        // asi que la deteccion solo-en-spawn quedaba obsoleta (-1)
        // y el sound hook dejaba pasar el grito original.
        if (g_iCustom[client] < 0)
            LazyDetect(client);

        if (!IsPlayerAlive(client))
        {
            g_bLedgeHandled[client] = false;
            g_bIncapHandled[client] = false;
            continue;
        }

        // Props booleanas: 1 byte
        bool hanging  = view_as<bool>(GetEntProp(client, Prop_Send, "m_isHangingFromLedge", 1));
        bool incapped = view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1));

        if (!hanging && !incapped)
        {
            g_bLedgeHandled[client] = false;
            g_bIncapHandled[client] = false;
            continue;
        }

        if (hanging && !g_bLedgeHandled[client])
        {
            g_bLedgeHandled[client] = true;
            if (g_iCustom[client] >= 0)
            {
                if (g_cvDebug.BoolValue)
                    PrintToServer("[Amy Fall Fix] Polling: ledge detectado para '%s'.", g_sVoiceFld[g_iCustom[client]]);
                HandleFall(client, true);
            }
        }
        else if (incapped && !hanging && !g_bIncapHandled[client])
        {
            g_bIncapHandled[client] = true;
            if (g_iCustom[client] >= 0)
            {
                if (g_cvDebug.BoolValue)
                    PrintToServer("[Amy Fall Fix] Polling: incap detectada para '%s'.", g_sVoiceFld[g_iCustom[client]]);
                HandleFall(client, false);
            }
        }
    }

    return Plugin_Continue;
}

// =============================================================
// LoadCustomSurvivors - tabla de survivors custom
// Archivo: addons/sourcemod/configs/amy_fall_fix_survivors.txt
//
//   # formato: <patron_modelo> <carpeta_voz> [offset_pitch]
//   survivor_amy amy 25
//   survivor_haruka haruka 25
//
// Si el archivo NO existe se usa el valor por defecto
// (survivor_amy -> amy, pitch +25, igual que el talker CST).
// =============================================================
void LoadCustomSurvivors()
{
    g_iCustomCount = 0;

    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "configs/amy_fall_fix_survivors.txt");

    if (!FileExists(path))
    {
        // Por defecto: Amy Rose CST (modelo survivor_amy, voz amy,
        // pitch +25 segun ems/custom_talker/settings.cfg del VPK)
        strcopy(g_sModelPat[0], 64, "survivor_amy");
        strcopy(g_sVoiceFld[0], 64, "amy");
        g_iPitchOff[0] = 25;
        g_iCustomCount = 1;

        PrintToServer("[Amy Fall Fix] configs/amy_fall_fix_survivors.txt no encontrado: usando Amy Rose por defecto (pitch +25).");
        return;
    }

    File file = OpenFile(path, "r");
    if (file == null)
        return;

    char line[256];
    char model[64];
    char folder[64];
    char pitchstr[16];

    while (g_iCustomCount < MAX_CUSTOMS && file.ReadLine(line, sizeof(line)))
    {
        TrimString(line);

        // Comentarios y lineas vacias
        if (line[0] == '\0' || line[0] == '#' || line[0] == ';' || line[0] == '/')
            continue;

        int pos = BreakString(line, model, sizeof(model));
        if (pos == -1 || model[0] == '\0')
            continue;

        int pos2 = BreakString(line[pos], folder, sizeof(folder));
        if (folder[0] == '\0')
        {
            LogError("[Amy Fall Fix] Linea invalida en amy_fall_fix_survivors.txt (falta carpeta de voz): %s", line);
            continue;
        }

        int pitch = 0;
        if (pos2 != -1)
        {
            strcopy(pitchstr, sizeof(pitchstr), line[pos + pos2]);
            TrimString(pitchstr);
            pitch = StringToInt(pitchstr);
        }

        strcopy(g_sModelPat[g_iCustomCount], 64, model);
        strcopy(g_sVoiceFld[g_iCustomCount], 64, folder);
        g_iPitchOff[g_iCustomCount] = pitch;
        g_iCustomCount++;
    }

    delete file;

    PrintToServer("[Amy Fall Fix] %d survivor(s) custom cargados desde configs/amy_fall_fix_survivors.txt", g_iCustomCount);
}

// =============================================================
// LoadExtraPatterns - patrones extra de bloqueo (opcional, v3)
// Archivo: addons/sourcemod/configs/amy_fall_fix_sounds.txt
// Un PATRON (texto a buscar dentro de la ruta del sonido) por
// linea. Lineas con # o ; son comentarios.
// =============================================================
void LoadExtraPatterns()
{
    g_iExtraPatternCount = 0;

    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "configs/amy_fall_fix_sounds.txt");

    if (!FileExists(path))
        return; // archivo opcional: no es error

    File file = OpenFile(path, "r");
    if (file == null)
        return;

    char line[PLATFORM_MAX_PATH];
    while (g_iExtraPatternCount < MAX_EXTRA_PATTERNS && file.ReadLine(line, sizeof(line)))
    {
        TrimString(line);

        if (line[0] == '\0' || line[0] == '#' || line[0] == ';' || line[0] == '/')
            continue;

        strcopy(g_ExtraPatterns[g_iExtraPatternCount], PLATFORM_MAX_PATH, line);
        g_iExtraPatternCount++;
    }

    delete file;

    if (g_iExtraPatternCount > 0)
    {
        PrintToServer("[Amy Fall Fix] %d patron(es) extra de bloqueo cargados desde configs/amy_fall_fix_sounds.txt", g_iExtraPatternCount);
    }
}
