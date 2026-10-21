// =====================================================================================
//  MUSIC DIRECTOR (v1.4.0-UNIFICADO) — build 2026-10-14
// =====================================================================================
//  EL SISTEMA UNICO DE MUSICA DEL SERVER — reemplaza DOS plugins:
//
//    [REEMPLAZA] l4d_MusicMapStart.smx  (HarryPotter "Round start music")
//      -> musica de arranque de ronda / entrada al server + menu !music
//         (parar, repetir, volumen, elegir cancion, poner para todos)
//         + mp3on/mp3off + sm_music_update + limite de descargas
//
//    [REEMPLAZA] l4d_tank_wave_sound.smx (Dragokas frankenstein)
//      -> musica de TANK con seleccion aleatoria sin repetir, multi-tank,
//         bloqueo BRAVO de la musica nativa del tank (sound hook +
//         music_dynamic_stop_playing + Music::StopPlaying por SDKCall +
//         truco del boomer), musica de ESCAPE/VICTORIA en finales con
//         deteccion por relays/eventos/radar de sonido, y fade out al
//         matar al ultimo tank
//
//  LO NUEVO v1.0 (pedido del owner: "Unificarlos en un solo sistema y
//  perfeccionarlo mas. Que sea mas preciso y a la vez que pueda
//  respetar ciertas etapas de combate, ya que posiblemente con esto
//  haga un futuro LMS"):
//
//    1) MOTOR DE ETAPAS CON PRIORIDAD — una sola fuente de verdad:
//         NINGUNA(0) < ARRANQUE(10) < MENU(20) < CUSTOM(30)
//         < TANK(40) < ESCAPE(50) < LMS(55) < VICTORIA(60)
//       Una etapa de prioridad MAYOR interrumpe a la menor (un tank
//       corta la musica de arranque; el escape corta al tank). Cuando
//       la etapa termina, el audio del juego vuelve solo (music_manager
//       restaurado SIEMPRE, sin fugas).
//
//    2) PRECISION:
//       - tank_spawn solo en mapas NO-final (como el original); un tank
//         NUEVO a mitad del fade cancela el fade y sigue sonando
//       - tank_killed: SOLO el ultimo tank vivo devuelve el audio
//         (cuenta de tanks activos, multi-tank seguro)
//       - arranque de ronda con el guard original round_start/player_spawn
//         (una sola reproduccion por ronda)
//       - restauracion de music_manager por duracion (TAG- del
//         music_mapstart.txt) + forzada en round_end/mission_lost/
//         map_transition/OnMapEnd — el original lo dejaba en 0 a veces
//
//    3) VOLUMEN POR JUGADOR en TODAS las musicas (el tank original iba
//       fijo a 1.0) + mute individual (mp3off/mp3on)
//
//    4) API PARA EL FUTURO LMS (natives + forward, ver MusicDirector.inc):
//         MD_SetStage(stage, prioridad, duracion, sonido, global)
//         MD_ClearStage(stage) / MD_GetStage()
//         forward MD_OnStageChanged(oldStage, newStage, priority)
//       El LMS solo tendra que llamar MD_SetStage(MDST_LMS, ...) con
//       su propia lista de canciones — el motor de etapas ya existe.
//       Comando admin de prueba: sm_musicstage <stage> <prio> <seg> [sonido]
//
//  LO NUEVO v1.1 (fixes del owner tras la primera ronda del director,
//  2026-10-13: "faltaron unos fix en el music del super tank: la musica
//  no se reproducia en loop una vez terminaba la cancion... el LMS
//  estara por encima del escape pero no encima de la musica de victoria...
//  la musica de escape al momento que empiece a sonar no podra
//  escucharse ninguna otra musica..."):
//
//    5) LOOP DE LA MUSICA DEL TANK: la cancion del tank se re-emite SOLA
//       cuando termina, hasta que muere el ultimo tank (antes la cancion
//       acababa y quedaba un silencio largo hasta la muerte del tank).
//       Duracion exacta por cancion: formato OPCIONAL en
//       tank_wave_sounds.txt → "ruta.mp3 TAG- Nombre-segundos" (el mismo
//       formato de music_mapstart.txt; cero migracion: la lista actual
//       tal cual sigue valiendo). Sin TAG- se usa md_loop_fallback
//       (120s de fabrica). md_tank_loop 0 = comportamiento viejo.
//       El loop tambien aplica a ESCAPE y LMS con cancion (no tienen fin
//       natural de etapa).
//
//    6) JERARQUIA DEL LMS: MDST_LMS con prioridad 55, POR ENCIMA del
//       ESCAPE (50) pero POR DEBAJO DE LA VICTORIA (60) — el LMS
//       reemplaza al escape; la victoria reemplaza al LMS. Etapa nativa
//       nueva (8) + sm_musicstage 8 + MD_PRIO_LMS en el .inc.
//
//    7) ESCAPE EXCLUSIVO: mientras suena el escape NO se escucha NADA
//       mas — ni la musica de un tank nuevo (la etapa TANK es rechazada
//       por prioridad) ni la musica NATIVA del juego (el silenciador de
//       1s y el bloqueo de samples del tank corren tambien en ESCAPE y
//       LMS, no solo en TANK). SOLO el LMS o la victoria pueden
//       reemplazar el escape. Ademas las musicas PERSONALES se cortan
//       al entrar cualquier etapa global.
//
//    8) DETECCION MEJORADA:
//       - RADAR DE TANK por sonido: la propia musica nativa del tank
//         delata un tank activo aunque el evento tank_spawn se pierda
//         (spawns por vscript/plugins custom) — md_tank_radar
//       - WATCHDOG del tank: si la etapa TANK sigue viva pero ya no
//         queda ningun tank (evento perdido, admin slay, despawn), la
//         etapa se cierra con fade en ~2s (2 ticks de 1s)
//       - VICTORIA por finale_vehicle_leaving ADEMAS de finale_win
//         (algunos mapas cambian rapido y el win llegaba tarde)
//       - ESCAPE por gauntlet_finale_start (los finales gauntlet:
//         c1m4 atrio, c4m5 milltown, c5m5 bridge, c6m3 port)
//       - los timers de etapa/loop se sueltan en OnMapEnd antes de que
//         el motor cierre los NO_MAPCHANGE (matar un handle ya cerrado
//         era un error de handle latente)
//
//  LO NUEVO v1.2 (fix del owner, 2026-10-13: "SV_StartSound:
//  mobius/musica/Unbreakable_Diamond_Rouge_Solo.mp3 not precached (0).
//  Se te olvido colocar precache a las musicas"):
//
//    9) PRECACHE COMPLETO: el menu !music mostraba TODAS las canciones
//       de music_mapstart.txt pero solo se precacheaban N ALEATORIAS por
//       mapa (md_download_number 3 de fabrica). Herencia del original:
//       el viejo limitaba su LISTA ACTIVA a esas N y su menu solo
//       mostraba las precacheadas — nunca podia fallar; el unificado
//       mostro la lista COMPLETA en el menu pero heredo el limite de
//       precache a medias. Sintoma: cancion elegida en el menu →
//       "SV_StartSound: not precached (0)" y silencio total; y una
//       cancion que sono bien en un mapa (quedo en la loteria de las N
//       aleatorias) dejaba de sonar en el mapa siguiente.
//       FIX: PrecacheSound de TODAS las canciones de TODAS las listas
//       en cada OnMapStart y sm_music_update. md_download_number ahora
//       limita SOLO la DESCARGA del cliente (default 0 = todas se
//       descargan; > 0 = N aleatorias por mapa para servers con
//       bandwidth justo — quien no tenga el archivo no escuchara esa
//       cancion, pero el server ya nunca dara error de precache).
//       Ademas: aviso en el log si una cancion de la lista NO existe
//       en sound/ (para cazar MP3 que faltan por subir al server).
//
//  LO NUEVO v1.3 (pedido del owner, 2026-10-13: "debes ajustarle su
//  volumen y el codigo ya que aunque yo modifique la musica para que
//  se escuchara alta en el juego aun sigue sonando... algunas musicas
//  se oyen bajas y deben ser equilibradas" + "deben escucharse 1 a azar
//  no siempre se escuchara la misma"):
//
//   10) SELECCION DEL ESCAPE SIN REPETIR: la cancion del escape sortea
//       evitando la del final anterior (la misma receta del tank). Con
//       el azar puro y pocas canciones en la lista, en finales
//       consecutivos tocaba la misma una y otra vez.
//
//   11) LA CANCION DEL ESCAPE SE ANUNCIA EN EL CHAT (como la del tank)
//       para poder comprobar la variedad con sm_mdstatus/consola.
//
//   12) VOLUMEN MAESTRO md_volume_master (default 1.0): multiplicador
//       global de TODAS las musicas custom (arranque, personal, menu,
//       tank, escape, loop y fade). ACLARACION IMPORTANTE: 1.0 es el
//       TOPE del engine (el mensaje de sonido no codifica mas de 1.0)
//       — el codigo YA emitia al maximo desde v1.0. Para que la musica
//       suene POR ENCIMA de los demas sonidos del juego el ajuste va
//       en el ARCHIVO (libreria normalizada a -10 LUFS integrado, sin
//       clipping — ver el LEEME del paquete); este convar sirve para
//       BAJARLA sin tocar archivos (o equilibrar contra el volumen
//       de juego que cada jugador traiga).
//
//  LO NUEVO v1.4 (pedido del owner, 2026-10-14: "quizas si anulamos el
//  metodo del music 0 podamos hacer un trabajo mas limpio ya que music 0
//  aunque sea una solucion viable temporal no es definitiva pues si la
//  musica empieza a sonar al menos por una fraccion de segundo y luego
//  el music 0 se activa entonses la musica nativa no podra ser detenida"
//  + "No deberia ser remplazada por la del tank ... la musica que suena
//  para todos se pausara o se reducira para dejar paso a la del tank y
//  cuando termine dejara la musica anterior seguir como estaba" + "Las
//  musicas osea cuando colocas una musica Nesesita mas opciones en su
//  menu como detener la musica para todos si se coloco una musica global"):
//
//   13) MUSIC 0 ANULADO (md_music_manager, default 0). El viejo camino
//       hacia sm_cvar music_manager 0 al reproducir algo custom y 1 al
//       terminar. PROBLEMA CONFIRMADO (investigacion de la ronda pasada):
//       el cvar solo apaga el DESPACHADOR server-side; una pista que ya
//       este sonando EN EL CLIENTE sigue sonando y NO puede ser detenida
//       — el bug del rescate: la nativa del rescate arranca una fraccion
//       de segundo antes que la nuestra y queda sonando ENCIMA durante
//       toda la cancion. Y ademas es todo-o-nada: no puede respetar al
//       vomito del boomer como hacia el tankwave original.
//       v1.4: por defecto NUNCA se toca music_manager. En su lugar, EL
//       METODO DEL TANKWAVE GENERALIZADO (ver 14/15/16). md_music_manager 1
//       = rollback al viejo comportamiento por si hubiera que volver.
//
//   14) BLOQUEO PER-CLIENTE POR CATEGORIAS (el corazon quirurgico). El
//       hook ya no bloquea "la musica del tank solo en etapa TANK": ahora
//       clasifica cada sample nativo (TANK / HORDA / EVENTO / BOOMER) y,
//       mientras un cliente esta oyendo musica custom (etapa global con
//       cancion o personal), las categorias activas NO LE LLEGAN: se le
//       quita de la lista de destinatarios del sonido (Plugin_Changed).
//       El que NO esta oyendo custom (o el que se puso mp3off) sigue
//       oyendo al juego con normalidad. Convars: md_block_tank,
//       md_block_horde, md_block_events; md_respect_boomer 1 = el vomito
//       del boomer (pukricide/zombiebaitearly) JAMAS se bloquea ni se
//       para en modo quirurgico — el respeto del tankwave original.
//
//   15) CORTE PREVIO + ASEDIO DE 1s GENERALIZADOS:
//       - MD_PreClearNative: ANTES de emitir una custom se corta lo nativo
//         que ya este sonando para ese cliente (parada dinamica en vuelo
//         + stops SDKCall por nombre + StopSound de los .wav confirmados
//         en AUTO/STATIC/MUSIC). Es la pieza que faltaba en el MusicMapStart
//         original (el solo cortaba rutas del TANK): cualquier nativa que
//         hubiera arrancado un instante antes (¡rescate!) muere AHORA.
//       - El asedio de 1s (Timer_ApplyAllFixes) corre mientras suena
//         CUALQUIER custom, no solo en TANK/ESCAPE/LMS. Dos perfiles:
//         COMPLETO (tank/escape/LMS: receta original intacta, con truco
//         del boomer) y QUIRURGICO (menu/arranque/personal: solo stops
//         por nombre — sin truco, sin blanket — el boomer real no se toca).
//
//   16) PAUSA/REANUDACION DE LA MUSICA PARA TODOS: si suena una cancion
//       puesta PARA TODOS (etapa MENU) y entra una etapa mayor (tank/
//       escape/LMS/custom), la cancion NO muere: se guarda con el tiempo
//       que le quedaba y al cerrar esa etapa VUELVE ("cuando termine dejara
//       la musica anterior seguir como estaba"). Si el cierre fue con
//       fade, la vuelta espera a que termine la cola. md_menu_resume 0
//       apaga la feature; md_menu_resume_full 1 = la cancion vuelve
//       COMPLETA en vez de con su tiempo restante. HONESTIDAD DE ENGINE:
//       no existe seek/offset en EmitSound (la misma limitacion que
//       obliga al loop del tank a re-emitir) — la cancion vuelve desde el
//       principio, pero la ETAPA conserva su reloj original. Y "reducir"
//       (ducking) tampoco es posible: el volumen queda fijado en la
//       emision, no hay API para cambiarlo en mitad de la reproduccion.
//       Por eso la implementacion honesta es PAUSAR (cortar + volver).
//
//   17) MENU: nueva opcion "Detener la musica para todos" (mismo permiso
//       que ponerla) — visible cuando hay una global activa O en pausa;
//       en pausa cancela la vuelta. sm_mdstatus muestra la pausa. Y
//       md_native_debug 1 (default): log de cada sample nativo de musica
//       que ve el hook, para completar la tabla de rutas del SERVER con
//       datos REALES (las candidatas de horda/evento se afinan con ese
//       log — los nombres de evento inexistentes son no-op gratis).
//
//  LO NUEVO v1.5 (fixes del owner, 2026-10-14: "Hay un bug en el
//  sistema de musica. Cuando se coloca una musica en el reproductor
//  por alguna razon dispara la musica del tank y luego el watchdog lo
//  quita pero despues lo vuelve a poner luego lo quita y asi; cuando
//  le doy para a la musica queda sonando la musica que puse pero no
//  para en lugar de detenerse"):
//
//   18) BLINDAJE ANTI-LOOP DEL TANK (el corazon del fix). El RADAR de
//       sonido abria la etapa TANK a ciegas: con solo OIR un sample
//       nativo del tank (cue rezagada del juego, musica de un tank que
//       ya murio/despawneo, tanque de prop sin cliente) la etapa se
//       abria... y como NO habia tank vivo, el watchdog la cerraba a
//       los ~2s; 3s despues el radar la volvia a abrir; y asi PARA
//       SIEMPRE: tank 2s -> tu cancion -> tank 2s -> tu cancion... (el
//       anti-rebote de 3s y el watchdog de 2 ticks se pisaban justo).
//       v1.5: TriggerTankStage EXIGE un tank VIVO de verdad (evento
//       tank_spawn y radar); si no lo hay, arma una re-verificacion
//       diferida de 1.5s (la musica nativa puede preceder por un
//       instante al spawn del bot) y si el tank no aparece, NO se abre
//       nada. Los comandos admin (sm_playtank/sm_nexttank) no exigen
//       tank. Un sample fantasma queda ademas REGISTRADO en el log
//       para cazar de donde sale.
//
//   19) "DETONER LA MUSICA PARA TODOS" DETIENE DE VERDAD. Dos huecos:
//       (a) "stop-global" no estaba en la lista de exclusiones del
//       resume -> al parar, una PAUSA vieja podia resucitar la cancion
//       anterior EN EL ACTO ("le doy para y sigue sonando"); ahora el
//       stop limpia pausa + reanudacion pendiente SIEMPRE, en ambas
//       ramas del menu (parando la activa o cancelando la pausada).
//       (b) poner una cancion NUEVA para todos ahora descarta la pausa
//       de la anterior: el owner ya decidio que suena ESTA — la vieja
//       no puede resucitar encima cuando la nueva termine o al cerrar
//       una etapa mayor.
//
//  ARCHIVOS DE DATOS — LOS MISMOS DE SIEMPRE (cero migracion):
//       data/music_mapstart.txt      "ruta.mp3 TAG- Nombre-segundos"
//       data/tank_wave_sounds.txt    "ruta.mp3" (una por linea; v1.1
//                                     OPCIONAL: "ruta.mp3 TAG- Nombre-213"
//                                     le da duracion EXACTA al loop)
//       data/tank_finale_sounds.txt  "ruta.mp3" (comentadas = desactivadas)
//
//  INSTALACION: subir l4d_MusicDirector.smx Y BORRAR los dos .smx viejos
//  (l4d_MusicMapStart.smx y l4d_tank_wave_sound.smx) — si quedan los
//  dos viejos, la musica se pelea.
// =====================================================================================

#define MD_VERSION "1.5.0-unificado"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

// =====================================================================================
//  ETAPAS Y PRIORIDADES
// =====================================================================================
#define MDST_NONE        0    // nada sonando: audio del juego
#define MDST_ROUNDSTART  1    // musica de arranque de ronda (todos)
#define MDST_JOIN        2    // musica de entrada (personal, 1 cliente)
#define MDST_MENUMUSIC   3    // "!music" puesta para todos
#define MDST_CUSTOM      4    // API externa (sm_musicstage)
#define MDST_TANK        5    // TANK WAVE
#define MDST_ESCAPE      6    // escape/vehicle del final
#define MDST_VICTORY     7    // victoria: silencio custom, suena el juego
#define MDST_LMS         8    // v1.1: LAST MAN STANDING (futuro modo)

#define MD_PRIO_JOIN      5
#define MD_PRIO_ROUND    10
#define MD_PRIO_MENU     20
#define MD_PRIO_CUSTOM   30
#define MD_PRIO_TANK     40
#define MD_PRIO_ESCAPE   50
#define MD_PRIO_LMS      55   // v1.1: por ENCIMA del escape, por DEBAJO de la victoria
#define MD_PRIO_VICTORY  60

#define MD_CHANNEL        SNDCHAN_STATIC     // canal de las musicas (original tank)
#define MD_SOUNDLEVEL     135                // SNDLEVEL_RAID_SIREN del original
#define MD_FADE_STEP      0.05               // bajada del fade (0.1s por paso)
#define MD_STAGENAMES     { "Ninguna", "Arranque de ronda", "Entrada", "Menu", "Custom", "TANK WAVE", "Escape final", "Victoria", "LMS" }

// sonidos "silencio" del boomer (el truco original para cortar musicas del juego)
#define SOUND_BOOMER_VOMIT  "music/bacteria/pukricide.wav"
#define SOUND_L4D1_VOMIT    "music/bacteria/pukricide_l4d1.wav"

#define ZC_TANK 8

// canal de musica nativa del L4D2 (el MusicMapStart original lo definia a
// mano: "algunos compiladores no definen SNDCHAN_MUSIC" — 5 en este engine)
#define SNDCHAN_MUSIC_L4D2 5

// =====================================================================================
//  v1.4: TABLA DE MUSICA NATIVA — categorias para el bloqueo per-cliente
// =====================================================================================
#define MDNAT_IGNORE  0   // no es musica o no esta catalogada -> no se toca
#define MDNAT_TANK    1   // CONFIRMADA (batalla del tank_wave original en este server)
#define MDNAT_HORDE   2   // horda/panico
#define MDNAT_EVENT   3   // eventos: finale/rescate + canciones del escape nativo
#define MDNAT_BOOMER  4   // vomito del boomer — SE RESPETA como el tankwave original
#define MDNAT_OTHER   5   // music/* sin catalogar (se respeta; queda en el log)

static const char g_CatNames[][] = { "ignorar", "tank", "horda", "evento", "boomer", "otra" };

// ---- eventos dinamicos: CONFIRMADOS por el tank_wave original ----
static const char g_TankEvents[][] = {
    "Event.Tank", "Event.Tank_L4D1",
    "Event.TankMidpoint", "Event.TankMidpoint_L4D1",
    "Event.TankBrothers", "Event.TankBrothers_L4D1",
    "Event.FinalBattle", "Event.FinalBattle_L4D1",
    "Event.TankBattle"
};

// ---- .wav fisicos: CONFIRMADOS por el tank_wave original ----
static const char g_TankWavs[][] = {
    "music/tank/tank.wav", "music/tank/tankb.wav",
    "music/tank/tank_midpoint.wav", "music/tank/tank_brothers.wav",
    "music/tank/tank_finale.wav"
};

// ---- CANDIDATAS a confirmar con md_native_debug (si el nombre no existe
//      el SDKCall/StopSound es un no-op silencioso — reintentar es gratis;
//      el log del hook dice la verdad de este server y se afinan aqui) ----
static const char g_HordeEvents[][] = { "Event.ZombieHorde", "Event.Panic" };
static const char g_EventEvents[][] = { "Event.SurvivorRescue" };

// =====================================================================================
//  ESTADO GLOBAL
// =====================================================================================
public Plugin myinfo =
{
    name = "Music Director (unificado: arranque + menu + tank + escape + LMS-ready)",
    author = "Sonic Suite Team (sobre bases de Dragokas & HarryPotter)",
    description = "Un unico sistema de musica por ETAPAS DE COMBATE con prioridades (escape exclusivo, LMS sobre escape y bajo victoria), loop del tank, volumen por jugador, volumen maestro, blindaje anti-loop del radar y API para LMS",
    version = MD_VERSION,
    url = ""
};

// ---- etapa global vigente ----
int      g_iStage = MDST_NONE;                 // etapa ACTUAL
int      g_iStagePrio = 0;                     // prioridad de la etapa actual
char     g_sStageSound[PLATFORM_MAX_PATH];     // sonido de la etapa ("" = solo silenciar)
float    g_fStageEnd = 0.0;                    // fin programado (0 = sin limite)
Handle   g_hStageTimer = null;                 // timer de fin de etapa
char     g_sStageSrc[48];                      // quien la abrio (para logs)

// ---- reproduccion global en curso ----
char     g_sPlayingSound[PLATFORM_MAX_PATH];   // sonido SONANDO (para StopSound)
float    g_fFadeVolume = 1.0;
Handle   g_hFadeTimer = null;

// ---- v1.1: loop de la cancion vigente (tank/escape/LMS sin fin natural) ----
Handle   g_hLoopTimer = null;       // re-emitidor periodico de la cancion
float    g_fLoopInterval = 0.0;     // intervalo del loop (duracion conocida)
int      g_iTankGoneTicks = 0;      // watchdog: ticks consecutivos sin tanks
float    g_fNextTankRadar = 0.0;    // anti-rebote del radar de sonido
Handle   g_hRadarRecheck = null;     // v1.5: re-verificacion diferida del radar (musica sin tank visible aun)

// ---- v1.4: pausa de la musica PARA TODOS (etapa MENU) ----
char     g_sPausedSong[PLATFORM_MAX_PATH];   // cancion en pausa ("" = sin pausa)
float    g_fPausedRemain = 0.0;              // tiempo que le quedaba a la etapa al pausarse
bool     g_bResumePending = false;           // reanudar cuando el fade de cierre termine

// ---- bloqueo de musica nativa del juego (v1.4: generalizado) ----
Handle   g_hSpamTimer = null;                  // el asedio de 1s (perfil completo o quirurgico)
Handle   hSDK_StopMusic = null;                // Music::StopPlaying (SDKCall)

// ---- deteccion de final ----
bool     g_bIsFinale = false;
bool     g_bEscapeStarted = false;

// ---- listas ----
ArrayList g_aRoundMusic;      // music_mapstart.txt: rutas
ArrayList g_aRoundNames;      // ... y sus nombres TAG
ArrayList g_aRoundDuration;   // ... y sus duraciones (s)
ArrayList g_aTankMusic;       // tank_wave_sounds.txt
ArrayList g_aTankDuration;    // v1.1: duracion opcional TAG- (0 = desconocida)
ArrayList g_aFinaleMusic;     // tank_finale_sounds.txt
ArrayList g_aFinaleDuration;  // v1.1: idem
char      g_sLastTankSong[PLATFORM_MAX_PATH];
char      g_sLastEscapeSong[PLATFORM_MAX_PATH];   // v1.3: la del escape anterior (anti-repetir)

// ---- por cliente ----
bool     g_bMuted[MAXPLAYERS + 1];             // mp3off
float    g_fVolume[MAXPLAYERS + 1];            // volumen elegido
char     g_sPersonal[MAXPLAYERS + 1][PLATFORM_MAX_PATH];  // cancion personal (!music)
int      g_iPersonalIdx[MAXPLAYERS + 1];
int      g_iMenuPos[MAXPLAYERS + 1];
Handle   g_hJoinTimer[MAXPLAYERS + 1];
float    g_fNextPlayAll = 0.0;                 // cooldown del "para todos"

// ---- guard de arranque (original) ----
int      g_iRoundStartFlag = 0;
int      g_iPlayerSpawnFlag = 0;
Handle   g_hRoundDelayTimer = null;

// ---- convars ----
ConVar g_cvEnable, g_cvRoundPlay, g_cvRoundDelay, g_cvRoundMenu,
      g_cvJoinPlay, g_cvJoinDelay, g_cvJoinMenu, g_cvDownloadNumber,
      g_cvPlayAllCooldown, g_cvPlayAllAccess, g_cvTankPlay, g_cvEscapePlay,
      g_cvTankLoop, g_cvLoopFallback, g_cvTankRadar, g_cvDebug, g_cvVolMaster;
// v1.4:
ConVar g_cvMusicManager, g_cvBlockTank, g_cvBlockHorde, g_cvBlockEvents,
      g_cvRespectBoomer, g_cvNativeDebug, g_cvMenuResume, g_cvMenuResumeFull;

// =====================================================================================
//  CARGA DEL PLUGIN + NATIVES/forward (API LMS)
// =====================================================================================
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    CreateNative("MD_SetStage", Native_SetStage);
    CreateNative("MD_ClearStage", Native_ClearStage);
    CreateNative("MD_GetStage", Native_GetStage);
    RegPluginLibrary("MusicDirector");
    return APLRes_Success;
}

// native bool MD_SetStage(int stage, int priority, float duration, const char[] sound="", bool global=true);
public int Native_SetStage(Handle plugin, int numParams)
{
    int stage    = GetNativeCell(1);
    int priority = GetNativeCell(2);
    float duration = GetNativeCell(3);

    char sound[PLATFORM_MAX_PATH];
    GetNativeString(4, sound, sizeof(sound));

    return MD_EnterStage(stage, priority, sound, duration, "native") ? 1 : 0;
}

// native bool MD_ClearStage(int stage);
public int Native_ClearStage(Handle plugin, int numParams)
{
    int stage = GetNativeCell(1);
    if (g_iStage != stage) return 0;
    MD_LeaveStage(true, "native-clear");
    return 1;
}

// native int MD_GetStage();
public int Native_GetStage(Handle plugin, int numParams)
{
    return g_iStage;
}

// =====================================================================================
//  INICIO
// =====================================================================================
public void OnPluginStart()
{
    CreateConVar("l4d_musicdirector_version", MD_VERSION, "Version del Music Director", FCVAR_NOTIFY|FCVAR_DONTRECORD);

    g_cvEnable         = CreateConVar("md_enable", "1", "1 = sistema activo; 0 = todo apagado", _, true, 0.0, true, 1.0);
    g_cvRoundPlay      = CreateConVar("md_roundstart_play", "1", "Musica a todos al ARRANCAR LA RONDA (la lista music_mapstart.txt)", _, true, 0.0, true, 1.0);
    g_cvRoundDelay     = CreateConVar("md_roundstart_delay", "1.0", "Segundos de espera antes de la musica de arranque", _, true, 0.0);
    g_cvRoundMenu      = CreateConVar("md_roundstart_menu", "1", "Mostrar el menu !music al arrancar la ronda", _, true, 0.0, true, 1.0);
    g_cvJoinPlay       = CreateConVar("md_join_play", "1", "Musica PERSONAL al ENTRAR al server (solo para quien entra)", _, true, 0.0, true, 1.0);
    g_cvJoinDelay      = CreateConVar("md_join_delay", "3.0", "Segundos despues de entrar para su musica", _, true, 0.0);
    g_cvJoinMenu       = CreateConVar("md_join_menu", "0", "Mostrar el menu !music al entrar", _, true, 0.0, true, 1.0);
    g_cvDownloadNumber = CreateConVar("md_download_number", "0", "v1.2: SOLO limita la DESCARGA de canciones de arranque por mapa (0 = todas). El PRECACHE ya es siempre de todas. > 0 = N aleatorias se descargan; el resto sonara solo para quien ya tenga el MP3", _, true, 0.0);
    g_cvPlayAllCooldown= CreateConVar("md_playall_cooldown", "3.0", "Enfriamiento (s) del 'poner para todos' del !music (0 = sin limite)", _, true, 0.0);
    g_cvPlayAllAccess  = CreateConVar("md_playall_access_flag", "", "Flags que pueden poner musica para TODOS ('' = todos; '-1' = nadie)", _);
    g_cvTankPlay       = CreateConVar("md_tank_play", "1", "Musica de TANK al aparecer (mapas NO-final, lista tank_wave_sounds.txt)", _, true, 0.0, true, 1.0);
    g_cvEscapePlay     = CreateConVar("md_escape_play", "1", "Musica de ESCAPE en la huida final (lista tank_finale_sounds.txt; lista vacia = solo silenciar al juego)", _, true, 0.0, true, 1.0);
    g_cvTankLoop       = CreateConVar("md_tank_loop", "1", "v1.1: 1 = la cancion del TANK se repite en LOOP hasta que muere el ultimo tank (antes quedaba silencio al terminar la cancion); 0 = comportamiento viejo", _, true, 0.0, true, 1.0);
    g_cvLoopFallback   = CreateConVar("md_loop_fallback", "120.0", "v1.1: segundos del loop cuando la cancion NO trae duracion TAG- en la lista (subelo si la cancion se corta antes de acabar; bajalo si queda silencio entre vueltas)", _, true, 10.0);
    g_cvTankRadar      = CreateConVar("md_tank_radar", "1", "v1.1: 1 = la musica NATIVA del tank activa la etapa TANK aunque el evento tank_spawn se pierda (deteccion extra por sonido)", _, true, 0.0, true, 1.0);
    g_cvDebug          = CreateConVar("md_debug", "0", "1 = log de cada cambio de etapa en consola", _, true, 0.0, true, 1.0);
    g_cvVolMaster      = CreateConVar("md_volume_master", "1.0", "v1.3: Volumen MAESTRO de todas las musicas custom (arranque/personal/menu/tank/escape/loop/fade). 1.0 = TOPE del engine (el codigo ya emite al maximo). Para que la musica suene MAS fuerte que los demas sonidos del juego el ajuste va en el MP3 (libreria normalizada a -10 LUFS); este convar es para BAJARLA o equilibrarla sin tocar archivos", _, true, 0.05, true, 1.0);

    // ---- v1.4: silencio quirurgico ----
    g_cvMusicManager  = CreateConVar("md_music_manager", "0", "v1.4: 1 = volver al viejo truco sm_cvar music_manager 0/1 (NO recomendado: una pista nativa que arranque una fraccion de segundo antes ya no puede ser detenida y queda sonando encima — el bug del rescate). 0 (default) = METODO QUIRURGICO del tankwave original: stops por cliente + bloqueo por categorias; el despachador de musica del juego NUNCA se apaga", _, true, 0.0, true, 1.0);
    g_cvBlockTank      = CreateConVar("md_block_tank", "1", "v1.4: bloquear la musica nativa del TANK a quien esta oyendo musica custom", _, true, 0.0, true, 1.0);
    g_cvBlockHorde     = CreateConVar("md_block_horde", "1", "v1.4: bloquear la musica nativa de HORDA/panico (music/panic, music/holdout) a quien esta oyendo musica custom", _, true, 0.0, true, 1.0);
    g_cvBlockEvents    = CreateConVar("md_block_events", "1", "v1.4: bloquear la musica nativa de eventos (finale/rescate/escape nativo) a quien esta oyendo musica custom", _, true, 0.0, true, 1.0);
    g_cvRespectBoomer  = CreateConVar("md_respect_boomer", "1", "v1.4: respetar la musica del vomito del boomer (pukricide/zombiebaitearly) como hacia el tankwave original — en modo quirurgico JAMAS se bloquea ni se para", _, true, 0.0, true, 1.0);
    g_cvNativeDebug    = CreateConVar("md_native_debug", "1", "v1.4: log de cada sample nativo de musica que ve el hook (para completar la tabla de rutas del server con datos REALES y afinar las candidatas de horda/evento). Dejalo 1 los primeros dias y revisa logs/L(date).log", _, true, 0.0, true, 1.0);
    g_cvMenuResume     = CreateConVar("md_menu_resume", "1", "v1.4: la musica puesta PARA TODOS se PAUSA cuando entra una etapa mayor (tank/escape/LMS) y al cerrarse esa etapa la cancion de antes VUELVE con el tiempo que le quedaba", _, true, 0.0, true, 1.0);
    g_cvMenuResumeFull = CreateConVar("md_menu_resume_full", "0", "v1.4: modo de reanudacion: 0 = la cancion vuelve con el TIEMPO RESTANTE de la etapa (como estaba); 1 = la cancion vuelve COMPLETA desde cero", _, true, 0.0, true, 1.0);

    AutoExecConfig(true, "l4d_MusicDirector");

    // ---- comandos del !music (todos preservados) ----
    RegConsoleCmd("sm_music", Cmd_Music, "Menu de musica");
    RegAdminCmd("sm_music_update", Cmd_MusicUpdate, ADMFLAG_BAN, "Recargar la lista de musicas");
    RegConsoleCmd("mp3off", Cmd_MusicOff, "Apagar tus musicas custom");
    RegConsoleCmd("mp3on", Cmd_MusicOn, "Encender tus musicas custom");

    // ---- comandos del tank (preservados del original) ----
    RegAdminCmd("sm_playtank", Cmd_PlayTank, ADMFLAG_GENERIC, "Forzar la musica del TANK");
    RegAdminCmd("sm_nexttank", Cmd_NextTankSong, ADMFLAG_GENERIC, "Cambiar a otra cancion de TANK");
    RegAdminCmd("sm_test_escape", Cmd_TestEscape, ADMFLAG_ROOT, "Probar la logica de escape final");

    // ---- nuevos del director ----
    RegAdminCmd("sm_musicstage", Cmd_Stage, ADMFLAG_GENERIC, "md: forzar una etapa — sm_musicstage <stage 1-7> <prio> <segundos> [ruta.mp3]");
    RegAdminCmd("sm_mdstop", Cmd_StopAll, ADMFLAG_ROOT, "Parar TODA la musica custom YA (corte seco)");
    RegConsoleCmd("sm_mdstatus", Cmd_Status, "Ver la etapa de musica actual");

    // ---- eventos ----
    HookEvent("round_start",        Event_RoundStart,  EventHookMode_PostNoCopy);
    HookEvent("player_spawn",       Event_PlayerSpawn, EventHookMode_PostNoCopy);
    HookEvent("round_end",          Event_RoundEnd);
    HookEvent("mission_lost",       Event_RoundEnd);
    HookEvent("map_transition",     Event_RoundEnd);
    HookEvent("player_disconnect",  Event_PlayerDisconnect, EventHookMode_Pre);

    HookEvent("tank_spawn",  Event_TankSpawn);
    HookEvent("tank_killed", Event_TankKilled);
    HookEvent("finale_escape_start", Event_EscapeStart);
    HookEvent("gauntlet_finale_start", Event_GauntletStart);   // v1.1: finales gauntlet (atrio/milltown/bridge/port)
    HookEvent("finale_win",  Event_FinaleWin);
    HookEvent("finale_vehicle_leaving", Event_VehicleLeaving); // v1.1: victoria temprana

    AddNormalSoundHook(SoundHook);

    // ---- listas ----
    g_aRoundMusic    = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
    g_aRoundNames    = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
    g_aRoundDuration = new ArrayList();
    g_aTankMusic      = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
    g_aTankDuration   = new ArrayList();
    g_aFinaleMusic    = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
    g_aFinaleDuration = new ArrayList();

    for (int i = 1; i <= MaxClients; i++)
    {
        g_fVolume[i] = 1.0;
        g_bMuted[i] = false;
    }

    LoadDirectorHack();
}

public void OnPluginEnd()
{
    // nunca dejar la musica del juego apagada
    KillLoopTimer();
    MD_StopAllPlayback(false);
    StopSpamTimer();
    g_sPausedSong[0] = '\0';
    g_bResumePending = false;
    SetGameMusicManager(true);
}

// =====================================================================================
//  CICLO DE MAPA
// =====================================================================================
public void OnMapStart()
{
    g_iStage = MDST_NONE;
    g_iStagePrio = 0;
    g_sStageSound[0] = '\0';
    g_sPlayingSound[0] = '\0';
    g_bEscapeStarted = false;
    g_iRoundStartFlag = 0;
    g_iPlayerSpawnFlag = 0;
    g_sLastTankSong[0] = '\0';
    g_sLastEscapeSong[0] = '\0';   // v1.3: tambien por mapa (cada campaña sortea limpio)
    g_sPausedSong[0] = '\0';      // v1.4: la pausa no cruza mapas
    g_fPausedRemain = 0.0;
    g_bResumePending = false;
    KillStageTimer();
    KillLoopTimer();
    StopSpamTimer();
    CancelFade();
    g_iTankGoneTicks = 0;
    g_fNextTankRadar = 0.0;

    PrecacheSound(SOUND_BOOMER_VOMIT, true);
    PrecacheSound(SOUND_L4D1_VOMIT, true);

    LoadLists();
    PrecacheAndDownload();

    // deteccion de mapa final (receta original completa)
    g_bIsFinale = CheckIfFinaleMap();
    if (g_bIsFinale)
    {
        ScanAndHookRelays();
        int entity = FindEntityByClassname(-1, "trigger_finale");
        if (entity != -1)
        {
            HookSingleEntityOutput(entity, "FinaleEscapeStart", OnFinaleLogicTriggered);
            HookSingleEntityOutput(entity, "FinaleVehicleReady", OnFinaleLogicTriggered);
        }
    }
}

public void OnMapEnd()
{
    MD_StopAllPlayback(false);
    ResetRoundFlags();
    SetGameMusicManager(true);
    StopSpamTimer();
    CancelFade();
    g_sPausedSong[0] = '\0';      // v1.4: idem al cambiar de mapa
    g_fPausedRemain = 0.0;
    g_bResumePending = false;

    // v1.1: los timers de etapa/loop son NO_MAPCHANGE — el motor los cierra
    // el solo al cambiar de mapa. Aqui SOLO soltamos la referencia (matar
    // un handle ya cerrado por el motor = error de handle latente).
    g_hStageTimer = null;
    g_hLoopTimer = null;
    g_hRadarRecheck = null;   // v1.5: idem el re-check del radar
    g_fStageEnd = 0.0;
    g_iTankGoneTicks = 0;
}

public void OnConfigsExecuted()
{
    // (las listas se recargan por mapa; aqui solo re-chequear descargas
    //  si un admin recargo el plugin a mitad de mapa)
    if (g_aRoundMusic.Length == 0 && g_aTankMusic.Length == 0)
        LoadLists();
}

public void OnClientPutInServer(int client)
{
    if (IsFakeClient(client) || !g_cvEnable.BoolValue || !g_cvJoinPlay.BoolValue) return;
    delete g_hJoinTimer[client];
    g_hJoinTimer[client] = CreateTimer(g_cvJoinDelay.FloatValue, Timer_JoinMusic, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientDisconnect(int client)
{
    delete g_hJoinTimer[client];
    g_sPersonal[client][0] = '\0';
    g_iPersonalIdx[client] = 0;
    g_iMenuPos[client] = 0;
}

// =====================================================================================
//  MOTOR DE ETAPAS — LA PIEZA NUEVA
// =====================================================================================

// Entra en una etapa global. Devuelve false si la etapa vigente tiene MAS
// prioridad (y por tanto no se interrumpe). duration 0 = sin limite
// (terminara quien la abrio). sound "" = etapa de SOLO-ILENCIO (bloquea al
// juego sin poner nada — el caso de la lista de escape comentada).
bool MD_EnterStage(int stage, int priority, const char[] sound, float duration, const char[] src)
{
    if (!g_cvEnable.BoolValue) return false;

    // VICTORIA y ESCAPE siempre entran; las demas respetan la prioridad
    if (stage != MDST_VICTORY && g_iStage != MDST_NONE && priority < g_iStagePrio)
    {
        MD_Debug("Etapa %d (prio %d, %s) RECHAZADA: vigente %d (prio %d)",
                 stage, priority, src, g_iStage, g_iStagePrio);
        return false;
    }

    int oldStage = g_iStage;

    // v1.4 PAUSA: si lo que suena es la cancion de PARA TODOS (etapa MENU)
    // y entra una etapa de prioridad MAYOR (tank/escape/LMS/custom), no la
    // matamos para siempre: se guarda con el tiempo que le quedaba y al
    // cerrar esa etapa VUELVE — "cuando termine dejara la musica anterior
    // seguir como estaba". La VICTORIA no pausa: es el final de la ronda.
    if (oldStage == MDST_MENUMUSIC && g_sPausedSong[0] == '\0'
        && priority > MD_PRIO_MENU && stage != MDST_VICTORY
        && g_sStageSound[0] != '\0' && g_cvMenuResume.BoolValue)
    {
        strcopy(g_sPausedSong, sizeof(g_sPausedSong), g_sStageSound);
        g_fPausedRemain = 0.0;
        if (g_fStageEnd > 0.0)
        {
            g_fPausedRemain = g_fStageEnd - GetEngineTime();
            if (g_fPausedRemain < 0.0) g_fPausedRemain = 0.0;
        }
        MD_Debug("Pausa: '%s' guardada (a la etapa le quedaban %.0fs)", g_sPausedSong, g_fPausedRemain);
    }

    // v1.4: entrar una etapa aborta cualquier reanudacion pendiente (la
    // PAUSA sigue guardada — se reintentara al cerrar esta nueva etapa)
    g_bResumePending = false;

    // la VICTORIA es el final de la ronda: la pausa no vuelve
    if (stage == MDST_VICTORY) g_sPausedSong[0] = '\0';

    // cortar lo anterior (seco: el fade es para el CIERRE, no para el relevo)
    MD_StopAllPlayback(false);

    // v1.1: las musicas PERSONALES tambien ceden ante una etapa global
    // (antes la de un jugador recien entrado podia quedar sonando encima
    // del tank/escape — exclusividad rota)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_sPersonal[i][0] != '\0')
        {
            if (IsClientInGame(i)) StopSound(i, MD_CHANNEL, g_sPersonal[i]);
            g_sPersonal[i][0] = '\0';
        }
    }

    g_iStage = stage;
    g_iStagePrio = priority;
    strcopy(g_sStageSound, sizeof(g_sStageSound), sound);
    strcopy(g_sStageSrc, sizeof(g_sStageSrc), src);
    KillStageTimer();
    KillLoopTimer();
    g_fStageEnd = 0.0;

    // failsafe de precision: si una etapa con CANCION no trae duracion
    // conocida (sin TAG- en la lista), le ponemos tope de 240s — el
    // original dejaba music_manager en 0 para siempre en ese caso
    if (duration <= 0.0 && sound[0] != '\0'
        && (stage == MDST_ROUNDSTART || stage == MDST_MENUMUSIC || stage == MDST_JOIN))
        duration = 240.0;

    if (duration > 0.0)
    {
        g_fStageEnd = GetEngineTime() + duration;
        g_hStageTimer = CreateTimer(duration, Timer_StageEnd, _, TIMER_FLAG_NO_MAPCHANGE);
    }

    // v1.4: el bloqueo nativo ya no es un flag de etapa: el hook decide por
    // cliente con MD_ClientHearsCustom() y el asedio toma su perfil segun
    // la etapa vigente (ver SoundHook y Timer_ApplyAllFixes)

    // reproduccion
    if (sound[0] != '\0')
    {
        MD_PlayGlobal(sound);
        // v1.4: el asedio de 1s lo arma MD_PlayGlobal (corre mientras suene
        // CUALQUIER custom — no solo en TANK/ESCAPE/LMS)
    }
    else
    {
        // etapa silenciosa. VICTORIA es la excepcion: ahi el que tiene que
        // sonar es el WIN DEL JUEGO (music_manager ARRIBA y parar las
        // dinamicas); el resto (escape sin lista) apaga al juego
        if (stage == MDST_VICTORY)
            SetGameMusicManager(true);
        else
            SetGameMusicManager(false);
        if (stage == MDST_TANK || stage == MDST_ESCAPE || stage == MDST_LMS) StartSpamTimer();
    }

    // v1.1 LOOP: TANK (si md_tank_loop), ESCAPE y LMS no tienen fin natural
    // de etapa — la cancion se re-emite SOLA al terminar. Las etapas con
    // duracion conocida (arranque/menu/custom con segundos) cierran solas
    // por su timer de etapa y no loopean.
    if (sound[0] != '\0' && duration <= 0.0
        && (stage == MDST_ESCAPE || stage == MDST_LMS
            || (stage == MDST_TANK && g_cvTankLoop.BoolValue)))
    {
        MD_ArmLoop(sound);
    }

    // aviso del cambio
    static const char names[9][24] = MD_STAGENAMES;
    MD_Debug("Etapa: %s -> %s (prio %d, src %s, sonido '%s', %.0fs)",
             names[oldStage], names[stage], priority, src, sound, duration);

    // forward para el LMS / otros plugins
    Call_StartForward_OnStageChanged(oldStage, stage, priority);
    return true;
}

// Termina la etapa vigente: fade (suave) o corte. Devuelve el audio del
// juego a su sitio. Siempre deja el sistema en NONE.
void MD_LeaveStage(bool fade, const char[] src)
{
    if (g_iStage == MDST_NONE) return;

    int oldStage = g_iStage;
    g_iStage = MDST_NONE;
    g_iStagePrio = 0;
    g_sStageSound[0] = '\0';
    KillStageTimer();
    KillLoopTimer();
    StopSpamTimer();
    g_iTankGoneTicks = 0;

    if (fade)
        MD_FadeOut();
    else
        MD_StopAllPlayback(false);

    // el audio del juego VUELVE (si nadie mas esta sonando)
    MD_RestoreGameMusicIfIdle();

    // v1.4: si hay una PARA TODOS en pausa, al cerrar esta etapa VUELVE.
    // Si el cierre fue con fade, la vuelta espera a que termine la cola
    // (~2s) para que la cola del tank no se coma el arranque de la cancion
    // de antes. round_end / sm_mdstop no reanudan: la ronda acabo o el
    // admin mando parar TODO. v1.5: "stop-global" (el boton del menu
    // "Detener la musica para todos") TAMPOCO reanuda — parar es PARAR;
    // antes una pausa vieja resucitaba en el acto (bug del owner: "le doy
    // para y la musica que puse sigue sonando").
    if (g_sPausedSong[0] != '\0'
        && !StrEqual(src, "round_end") && !StrEqual(src, "sm_mdstop")
        && !StrEqual(src, "stop-global"))
    {
        if (fade) g_bResumePending = true;    // Timer_FadeMusic llama a MD_TryResumeMenu
        else      MD_TryResumeMenu();
    }

    static const char names[9][24] = MD_STAGENAMES;
    MD_Debug("Etapa: %s -> NINGUNA (%s, fade=%d)", names[oldStage], src, fade);
    Call_StartForward_OnStageChanged(oldStage, MDST_NONE, 0);
}

public Action Timer_StageEnd(Handle timer)
{
    g_hStageTimer = null;
    MD_LeaveStage(true, "duracion");
    return Plugin_Stop;
}

void KillStageTimer()
{
    if (g_hStageTimer != null)
    {
        KillTimer(g_hStageTimer);
        g_hStageTimer = null;
    }
    g_fStageEnd = 0.0;
}

// =====================================================================================
//  REPRODUCCION — el motor comun (global con volumen/mute por jugador)
// =====================================================================================
void MD_PlayGlobal(const char[] sound)
{
    CancelFade();
    MD_StopAllPlayback(false);
    strcopy(g_sPlayingSound, sizeof(g_sPlayingSound), sound);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
        if (g_bMuted[i]) continue;
        MD_PreClearNative(i);   // v1.4: corta lo nativo que ya este sonando ANTES de emitir
        EmitSoundToClient(i, sound, SOUND_FROM_PLAYER, MD_CHANNEL, MD_SOUNDLEVEL, SND_NOFLAGS, g_fVolume[i] * g_cvVolMaster.FloatValue);
    }
    SetGameMusicManager(false);          // v1.4: no-op con md_music_manager 0 (default)
    StartSpamTimer();                   // v1.4: asedio mientras suena (perfil segun etapa)
    MD_Debug("Sonando (global): %s", sound);
}

// v1.4 — EL CORTE PREVIO QUIRURGICO: mata la musica nativa que YA este
// sonando para este cliente, un instante ANTES de emitir la custom. Es la
// pieza que le faltaba al MusicMapStart original (solo cortaba rutas del
// TANK): por eso una musica de rescate que arrancara una fraccion de
// segundo antes quedaba SONANDO ENCIMA durante toda la cancion.
// Receta: (1) parada dinamica en vuelo — una sola pasada, mata CUALQUIER
// cue del sistema dinamico sin importar su nombre (el despachador del
// juego sigue vivo y las cues NUEVAS las caza el hook + el asedio de 1s);
// (2) stops SDKCall por nombre de evento (no-op si no existe);
// (3) StopSound de los .wav fisicos confirmados en AUTO/STATIC/MUSIC.
// SIN truco del boomer: en modo quirurgico el vomito real no se toca.
void MD_PreClearNative(int client)
{
    if (!IsClientInGame(client) || IsFakeClient(client)) return;

    ClientCommand(client, "music_dynamic_stop_playing");

    for (int k = 0; k < sizeof(g_TankEvents); k++)
        Internal_StopMusic(client, g_TankEvents[k]);
    for (int k = 0; k < sizeof(g_HordeEvents); k++)
        Internal_StopMusic(client, g_HordeEvents[k]);
    for (int k = 0; k < sizeof(g_EventEvents); k++)
        Internal_StopMusic(client, g_EventEvents[k]);

    for (int k = 0; k < sizeof(g_TankWavs); k++)
    {
        StopSound(client, SNDCHAN_AUTO,       g_TankWavs[k]);
        StopSound(client, SNDCHAN_STATIC,     g_TankWavs[k]);
        StopSound(client, SNDCHAN_MUSIC_L4D2, g_TankWavs[k]);
    }
}

// v1.4 — devuelve la cancion de PARA TODOS que fue pausada por una etapa
// mayor. Re-abre la etapa MENU con la MISMA cancion y el tiempo que le
// quedaba ("sigue como estaba"). HONESTIDAD DE ENGINE: no existe seek/offset
// en EmitSound (la misma limitacion que obliga al loop del tank a re-emitir):
// la cancion vuelve desde el principio, pero la ETAPA conserva su reloj
// original. "Reducirla" (ducking) tampoco es posible: el volumen queda
// fijado en la emision — por eso la implementacion honesta es PAUSAR.
void MD_TryResumeMenu()
{
    if (g_sPausedSong[0] == '\0') return;
    if (g_iStage != MDST_NONE) return;    // alguien volvio a entrar: la pausa sigue
    if (!g_cvMenuResume.BoolValue) { g_sPausedSong[0] = '\0'; return; }

    char song[PLATFORM_MAX_PATH];
    strcopy(song, sizeof(song), g_sPausedSong);

    float duration = g_fPausedRemain;
    if (g_cvMenuResumeFull.BoolValue)
    {
        // modo completo: la cancion entera desde cero (TAG- o failsafe 240)
        int idx = g_aRoundMusic.FindString(song);
        duration = (idx != -1) ? view_as<float>(g_aRoundDuration.Get(idx)) : 0.0;
        if (duration <= 0.0) duration = 240.0;
    }
    if (duration < 3.0)
    {
        // le quedaba un suspiro (o nada): mas limpio no devolverla
        g_sPausedSong[0] = '\0';
        MD_Debug("Reanudacion cancelada: a la etapa le quedaban %.0fs", duration);
        return;
    }

    g_sPausedSong[0] = '\0';
    if (MD_EnterStage(MDST_MENUMUSIC, MD_PRIO_MENU, song, duration, "reanudacion"))
        PrintToChatAll("\x04[Music]\x01 La musica de antes sigue: \x03%s", song);
}

// musica PERSONAL de un cliente (entrada / menu elegir): SOLO si no hay
// etapa global — las etapas de combate mandan sobre el capricho personal
void MD_PlayPersonal(int client, const char[] sound, float duration)
{
    if (!IsClientInGame(client) || IsFakeClient(client)) return;
    if (g_iStage != MDST_NONE)
    {
        PrintToChat(client, "\x04[Music]\x01 Hay una etapa de combate sonando (%s) — tu eleccion espera a que termine.", MD_StageName());
        return;
    }
    MD_StopPersonal(client);
    strcopy(g_sPersonal[client], sizeof(g_sPersonal[]), sound);
    if (g_bMuted[client]) return;

    MD_PreClearNative(client);   // v1.4: corta lo nativo de ESTE cliente antes de emitir
    EmitSoundToClient(client, sound, SOUND_FROM_PLAYER, MD_CHANNEL, MD_SOUNDLEVEL, SND_NOFLAGS, g_fVolume[client] * g_cvVolMaster.FloatValue);
    SetGameMusicManager(false);  // v1.4: no-op con md_music_manager 0 (default)
    StartSpamTimer();            // v1.4: asedio quirurgico mientras suena la personal
    MD_Debug("Sonando (personal %N): %s", client, sound);

    if (duration > 0.0)
        CreateTimer(duration, Timer_PersonalEnd, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_PersonalEnd(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0) MD_StopPersonal(client);
    return Plugin_Stop;
}

void MD_StopPersonal(int client)
{
    if (client > 0 && client <= MaxClients && g_sPersonal[client][0] != '\0')
    {
        if (IsClientInGame(client))
            StopSound(client, MD_CHANNEL, g_sPersonal[client]);
        g_sPersonal[client][0] = '\0';
        MD_RestoreGameMusicIfIdle();
    }
}

// corte SECO de lo global (y avisa a las personales que cedan)
void MD_StopAllPlayback(bool andPersonal)
{
    if (g_sPlayingSound[0] != '\0')
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i))
                StopSound(i, MD_CHANNEL, g_sPlayingSound);
        }
        g_sPlayingSound[0] = '\0';
    }
    CancelFade();

    if (andPersonal)
    {
        for (int i = 1; i <= MaxClients; i++)
            if (g_sPersonal[i][0] != '\0' && IsClientInGame(i))
                StopSound(i, MD_CHANNEL, g_sPersonal[i]);
    }
}

// FADE OUT suave (receta original: -5% cada 0.1s = ~2s)
void MD_FadeOut()
{
    if (g_sPlayingSound[0] == '\0')
    {
        MD_RestoreGameMusicIfIdle();
        return;
    }
    CancelFade();
    g_fFadeVolume = 1.0;
    g_hFadeTimer = CreateTimer(0.1, Timer_FadeMusic, _, TIMER_REPEAT);
}

public Action Timer_FadeMusic(Handle timer)
{
    if (g_sPlayingSound[0] == '\0')
    {
        g_hFadeTimer = null;
        return Plugin_Stop;
    }

    g_fFadeVolume -= MD_FADE_STEP;
    if (g_fFadeVolume <= 0.0)
    {
        MD_StopAllPlayback(false);
        g_hFadeTimer = null;
        MD_RestoreGameMusicIfIdle();

        // v1.4: termino la cola del cierre -> la PARA TODOS en pausa VUELVE
        if (g_bResumePending)
        {
            g_bResumePending = false;
            MD_TryResumeMenu();
        }
        return Plugin_Stop;
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && !g_bMuted[i])
            EmitSoundToClient(i, g_sPlayingSound, SOUND_FROM_PLAYER, MD_CHANNEL, MD_SOUNDLEVEL, SND_CHANGEVOL, g_fFadeVolume * g_cvVolMaster.FloatValue);
    }
    return Plugin_Continue;
}

void CancelFade()
{
    if (g_hFadeTimer != null)
    {
        KillTimer(g_hFadeTimer);
        g_hFadeTimer = null;
    }
    g_fFadeVolume = 1.0;
}

// el audio del juego vuelve SOLO cuando ya no suena nada custom
void MD_RestoreGameMusicIfIdle()
{
    if (g_sPlayingSound[0] != '\0') return;
    for (int i = 1; i <= MaxClients; i++)
        if (g_sPersonal[i][0] != '\0') return;
    SetGameMusicManager(true);
}

// v1.4: music 0 ANULADO POR DEFAULT. El cvar solo apaga el DESPACHADOR
// server-side (sv+cheat): una pista que ya este sonando EN EL CLIENTE sigue
// sonando y NO puede ser detenida — el bug del rescate. Ademas es todo-o-nada
// (no puede respetar al boomer). El metodo del tankwave (stops por cliente +
// hook por categorias, arriba) lo reemplaza; md_music_manager 1 = rollback.
void SetGameMusicManager(bool enable)
{
    if (g_cvMusicManager == null || !g_cvMusicManager.BoolValue) return;
    if (enable) ServerCommand("sm_cvar music_manager 1");
    else        ServerCommand("sm_cvar music_manager 0");
}

// =====================================================================================
//  BLOQUEO DE MUSICA NATIVA (receta original del tank, intacta) + v1.1
// =====================================================================================
public Action SoundHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity,
                        int &channel, float &volume, int &level, int &pitch, int &flags,
                        char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
    // 1) radar de escape: si el juego empieza su musica de huida y aun no
    //    detectamos el escape, es que la logica del mapa se disparo
    if (g_bIsFinale && !g_bEscapeStarted)
    {
        if (StrContains(sample, "skinonourteeth", false) != -1 ||
            StrContains(sample, "themonsterswithout", false) != -1 ||
            StrContains(sample, "midnightride", false) != -1 ||
            StrContains(sample, "onebadman", false) != -1 ||
            StrContains(sample, "finalnail", false) != -1)
        {
            TriggerEscape("RADAR de sonido");
        }
    }

    // 2) v1.1 RADAR DE TANK: la propia musica nativa del tank delata un tank
    //    activo aunque el evento tank_spawn se pierda (spawns por vscript o
    //    plugins custom). Solo en mapas NO-final (en finales la musica del
    //    tank la lleva el juego, como siempre) y sin etapa de combate mayor
    //    ya sonando — durante ESCAPE/LMS/VICTORIA el escape manda.
    //    v1.5: TriggerTankStage EXIGE tank vivo (ver el blindaje anti-loop
    //    en su cabecera) — un sample fantasma ya NO abre la etapa.
    if (!g_bIsFinale && g_cvTankPlay.BoolValue && g_cvTankRadar.BoolValue
        && g_iStage != MDST_TANK && g_iStage != MDST_ESCAPE
        && g_iStage != MDST_LMS && g_iStage != MDST_VICTORY
        && GetEngineTime() >= g_fNextTankRadar
        && MD_IsNativeTankMusic(sample))
    {
        g_fNextTankRadar = GetEngineTime() + 3.0;    // anti-rebote
        if (TriggerTankStage("RADAR de sonido (musica nativa del tank)"))
            return Plugin_Handled;   // esta emision nativa no suena: ya pusimos la nuestra
    }

    // 3) v1.4 BLOQUEO PER-CLIENTE POR CATEGORIAS: mientras un cliente esta
    //    oyendo musica custom (etapa global con cancion, o personal), la
    //    musica nativa de las categorias activas NO LE LLEGA: se le quita
    //    de la lista de destinatarios del sonido (Plugin_Changed). El que
    //    NO esta oyendo custom (o el que se puso mp3off) sigue oyendo al
    //    juego con normalidad — el respeto del tankwave, ahora per-cliente
    //    y para TODA la libreria nativa, no solo la del tank.
    int cat = MD_NativeCategory(sample);

    if (g_cvNativeDebug.BoolValue && cat != MDNAT_IGNORE)
        LogMessage("[NATIVO] sample='%s' categoria=%s", sample, g_CatNames[cat]);

    bool blockThis = false;
    if      (cat == MDNAT_TANK)   blockThis = g_cvBlockTank.BoolValue;
    else if (cat == MDNAT_HORDE)  blockThis = g_cvBlockHorde.BoolValue;
    else if (cat == MDNAT_EVENT)  blockThis = g_cvBlockEvents.BoolValue;
    else if (cat == MDNAT_BOOMER) blockThis = !g_cvRespectBoomer.BoolValue;
    // MDNAT_OTHER (music/* sin catalogar) se respeta: queda en el log

    if (blockThis)
    {
        int kept[64];
        int newCount = 0;
        bool removed = false;
        for (int c = 0; c < numClients; c++)
        {
            if (MD_ClientHearsCustom(clients[c])) { removed = true; continue; }
            kept[newCount++] = clients[c];
        }
        if (!removed) return Plugin_Continue;
        if (newCount == 0) return Plugin_Handled;   // nadie la oye
        for (int c = 0; c < newCount; c++) clients[c] = kept[c];
        numClients = newCount;
        return Plugin_Changed;                      // suena SOLO para los que no oyen custom
    }

    return Plugin_Continue;
}

// v1.1: el matcher unico de musica nativa del tank (lo usan el bloqueo y el radar)
bool MD_IsNativeTankMusic(const char[] sample)
{
    if (StrContains(sample, "music/tank/", false) != -1)      return true;
    if (StrContains(sample, "bacteria/tank", false) != -1)   return true;
    if (StrContains(sample, "tank.wav", false) != -1)        return true;
    if (StrContains(sample, "tankb.wav", false) != -1)       return true;
    if (StrContains(sample, "tank_midpoint", false) != -1)   return true;
    if (StrContains(sample, "tank_brothers", false) != -1)   return true;
    if (StrContains(sample, "tank_finale", false) != -1)     return true;
    return false;
}

// v1.4: clasifica un sample nativo. Orden importa: el boomer primero
// (pukricide vive en music/bacteria/ igual que las rutas del tank).
int MD_NativeCategory(const char[] sample)
{
    if (StrContains(sample, "pukricide", false) != -1)        return MDNAT_BOOMER;
    if (StrContains(sample, "zombiebaitearly", false) != -1)  return MDNAT_BOOMER;
    if (MD_IsNativeTankMusic(sample))                         return MDNAT_TANK;
    if (StrContains(sample, "music/panic/", false) != -1)     return MDNAT_HORDE;
    if (StrContains(sample, "music/holdout/", false) != -1)   return MDNAT_HORDE;
    if (StrContains(sample, "music/finale/", false) != -1)    return MDNAT_EVENT;
    if (StrContains(sample, "survivorrescue", false) != -1)   return MDNAT_EVENT;
    // canciones del escape nativo (el radar de siempre, ahora tambien categoria)
    if (StrContains(sample, "skinonourteeth", false) != -1
        || StrContains(sample, "themonsterswithout", false) != -1
        || StrContains(sample, "midnightride", false) != -1
        || StrContains(sample, "onebadman", false) != -1
        || StrContains(sample, "finalnail", false) != -1)     return MDNAT_EVENT;
    if (StrContains(sample, "music/", false) != -1)           return MDNAT_OTHER;
    return MDNAT_IGNORE;
}

// v1.4: este cliente esta oyendo musica custom (o el silencio exclusivo de
// una etapa global)? -> la nativa de las categorias activas no debe llegarle
bool MD_ClientHearsCustom(int i)
{
    if (i <= 0 || i > MaxClients) return false;
    if (!IsClientInGame(i) || IsFakeClient(i)) return false;
    if (g_bMuted[i]) return false;   // mp3off: sigue oyendo al juego

    // etapas de exclusividad total: tank suena para todos; escape/LMS son
    // exclusivos por regla del owner (nada mas se escucha con ellos)
    if (g_iStage == MDST_TANK || g_iStage == MDST_ESCAPE || g_iStage == MDST_LMS)
        return true;

    // etapa con cancion sonando (menu/arranque/custom): la oyen los no-muteados
    if (g_iStage != MDST_NONE && g_sPlayingSound[0] != '\0')
        return true;

    // musica personal sonando para este cliente
    if (g_sPersonal[i][0] != '\0')
        return true;

    return false;
}

// v1.4: el asedio de 1s — corre mientras suena CUALQUIER custom (no solo
// en TANK/ESCAPE/LMS). Dos perfiles por cliente: COMPLETO (la etapa es
// exclusiva: receta original con truco del boomer + parada blanket) y
// QUIRURGICO (menu/arranque/personal: solo stops por nombre — el vomito
// real del boomer no se toca). Se suelta solo cuando ya no suena nada custom.
void StartSpamTimer()
{
    if (g_hSpamTimer == null)
    {
        Timer_ApplyAllFixes(null);
        g_hSpamTimer = CreateTimer(1.0, Timer_ApplyAllFixes, _, TIMER_REPEAT);
    }
}

void StopSpamTimer()
{
    if (g_hSpamTimer != null)
    {
        KillTimer(g_hSpamTimer);
        g_hSpamTimer = null;
    }
}

public Action Timer_ApplyAllFixes(Handle timer)
{
    // v1.4: hay algo custom sonando? (cancion de etapa o personal de alguien)
    bool anyPersonal = false;
    for (int i = 1; i <= MaxClients && !anyPersonal; i++)
        if (g_sPersonal[i][0] != '\0') anyPersonal = true;

    // suelta: ya no hay etapa NI nada custom sonando
    if (g_iStage == MDST_NONE && g_sPlayingSound[0] == '\0' && !anyPersonal)
    {
        StopSpamTimer();
        if (g_sPlayingSound[0] != '\0' && g_hFadeTimer == null)
            MD_FadeOut();
        return Plugin_Stop;
    }

    // v1.1 WATCHDOG del tank: la etapa sigue viva pero ya NO queda ningun
    // tank (tank_killed perdido, admin slay, despawn raro) -> cerrar con
    // fade. 2 ticks consecutivos para no cortar por un frame raro.
    if (g_iStage == MDST_TANK)
    {
        if (GetActiveTankCount(0) == 0)
        {
            if (++g_iTankGoneTicks >= 2)
            {
                g_iTankGoneTicks = 0;
                MD_LeaveStage(true, "watchdog: sin tanks");
                PrintToChatAll("\x04[Music]\x01 Amenaza eliminada (watchdog). Audio normal restaurado.");
                return Plugin_Stop;   // MD_LeaveStage ya mato este timer
            }
        }
        else g_iTankGoneTicks = 0;
    }

    // v1.4: dos perfiles por cliente
    bool fullProfile = (g_iStage == MDST_TANK || g_iStage == MDST_ESCAPE || g_iStage == MDST_LMS);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;

        if (fullProfile)
        {
            // perfil COMPLETO — receta original del tank_wave intacta:
            // la etapa es exclusiva, NADA del juego se mete
            MD_StopNativeByName(i);

            // el truco del boomer original
            ClientCommand(i, "music_dynamic_play Event.Boomer");
            EmitSoundToClient(i, SOUND_BOOMER_VOMIT, SOUND_FROM_PLAYER, 6, SNDLEVEL_NORMAL, SND_CHANGEVOL, 0.001);
            EmitSoundToClient(i, SOUND_L4D1_VOMIT,   SOUND_FROM_PLAYER, 6, SNDLEVEL_NORMAL, SND_CHANGEVOL, 0.001);
            ClientCommand(i, "music_dynamic_stop_playing");
        }
        else if (MD_ClientHearsCustom(i))
        {
            // perfil QUIRURGICO — menu/arranque/personal: SOLO stops por
            // nombre. Sin truco del boomer, sin blanket: el vomito real
            // del boomer NO se toca (el respeto del tankwave original)
            MD_StopNativeByName(i);
        }
    }
    return Plugin_Continue;
}

// v1.4: los stops por nombre — comunes a los dos perfiles (un nombre que
// no exista es un no-op silencioso: reintentar es gratis)
void MD_StopNativeByName(int i)
{
    for (int k = 0; k < sizeof(g_TankEvents); k++)
        Internal_StopMusic(i, g_TankEvents[k]);
    for (int k = 0; k < sizeof(g_HordeEvents); k++)
        Internal_StopMusic(i, g_HordeEvents[k]);
    for (int k = 0; k < sizeof(g_EventEvents); k++)
        Internal_StopMusic(i, g_EventEvents[k]);

    for (int k = 0; k < sizeof(g_TankWavs); k++)
    {
        StopSound(i, SNDCHAN_AUTO,       g_TankWavs[k]);
        StopSound(i, SNDCHAN_STATIC,     g_TankWavs[k]);
        StopSound(i, SNDCHAN_MUSIC_L4D2, g_TankWavs[k]);
    }
}

// =====================================================================================
//  ETAPA: ARRANQUE DE RONDA + ENTRADA (original MusicMapStart)
// =====================================================================================
public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    ResetRoundFlags();
    delete g_hRoundDelayTimer;

    // guard original: la musica sale UNA vez por ronda (round_start y el
    // primer player_spawn pueden llegar en cualquier orden)
    if (g_iPlayerSpawnFlag == 1 && g_iRoundStartFlag == 0)
        ScheduleRoundMusic();
    g_iRoundStartFlag = 1;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (g_iPlayerSpawnFlag == 0 && g_iRoundStartFlag == 1)
        ScheduleRoundMusic();
    g_iPlayerSpawnFlag = 1;
}

void ScheduleRoundMusic()
{
    delete g_hRoundDelayTimer;
    g_hRoundDelayTimer = CreateTimer(0.5, Timer_RoundGo, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RoundGo(Handle timer)
{
    g_hRoundDelayTimer = null;
    if (!g_cvEnable.BoolValue || !g_cvRoundPlay.BoolValue) return Plugin_Stop;
    if (g_aRoundMusic.Length == 0) return Plugin_Stop;

    // el delay configurable del original (md_roundstart_delay) va AQUI,
    // despues del guard de 0.5s de round_start/player_spawn
    g_hRoundDelayTimer = CreateTimer(g_cvRoundDelay.FloatValue, Timer_RoundPlay, _, TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Stop;
}

public Action Timer_RoundPlay(Handle timer)
{
    g_hRoundDelayTimer = null;
    if (!g_cvEnable.BoolValue || !g_cvRoundPlay.BoolValue) return Plugin_Stop;
    if (g_aRoundMusic.Length == 0) return Plugin_Stop;

    // una cancion aleatoria de la lista para TODOS (etapa ARRANQUE). La
    // duracion conocida (TAG-) programa su fin y la vuelta del audio del
    // juego — el original a veces lo dejaba apagado
    int idx = GetRandomInt(0, g_aRoundMusic.Length - 1);
    char path[PLATFORM_MAX_PATH];
    g_aRoundMusic.GetString(idx, path, sizeof(path));
    float duration = g_aRoundDuration.Get(idx);

    if (MD_EnterStage(MDST_ROUNDSTART, MD_PRIO_ROUND, path, duration, "ronda"))
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            g_iPersonalIdx[i] = idx;
            if (IsClientInGame(i) && !IsFakeClient(i) && !g_bMuted[i] && g_cvRoundMenu.BoolValue)
                ShowMusicMenu(i, false);
        }
    }
    return Plugin_Stop;
}

public Action Timer_JoinMusic(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0) { return Plugin_Stop; }
    g_hJoinTimer[client] = null;
    if (!IsClientInGame(client) || IsFakeClient(client)) return Plugin_Stop;
    if (!g_cvEnable.BoolValue || !g_cvJoinPlay.BoolValue) return Plugin_Stop;
    if (g_aRoundMusic.Length == 0) return Plugin_Stop;
    if (g_hRoundDelayTimer != null) return Plugin_Stop;   // arrancando la ronda: ya sonara la global

    int idx = GetRandomInt(0, g_aRoundMusic.Length - 1);
    char path[PLATFORM_MAX_PATH];
    g_aRoundMusic.GetString(idx, path, sizeof(path));
    g_iPersonalIdx[client] = idx;
    MD_PlayPersonal(client, path, g_aRoundDuration.Get(idx));

    if (g_cvJoinMenu.BoolValue && !g_bMuted[client])
        ShowMusicMenu(client, false);
    return Plugin_Stop;
}

void ResetRoundFlags()
{
    g_iRoundStartFlag = 0;
    g_iPlayerSpawnFlag = 0;
}

// =====================================================================================
//  ETAPA: TANK (original tank_wave_sound)
// =====================================================================================
public void Event_TankSpawn(Event event, const char[] name, bool dontBroadcast)
{
    TriggerTankStage("evento tank_spawn");
}

// v1.1: camino UNICO del tank — evento, radar de sonido y comandos admin.
// Devuelve true si la etapa TANK quedo sonando.
// v1.5 BLINDAJE ANTI-LOOP: requireLiveTank (evento y radar pasan true)
// EXIGE un tank VIVO de verdad antes de abrir la etapa. El bug del owner:
// poner una musica en el reproductor -> "disparaba la musica del tank" ->
// el watchdog la cerraba a los ~2s (sin tanks) -> el radar la volvia a
// abrir (anti-rebote de solo 3s) -> watchdog -> radar -> ... LOOP ETERNO
// interrumpiendo la cancion cada pocos segundos. Ahora un sample nativo
// SIN tank vivo NO abre nada: arma una re-verificacion diferida (1.5s,
// por si la musica precede por un instante al spawn del bot) y si el
// tank no aparece, fuera — y el sample queda en el log para cazarlo.
bool TriggerTankStage(const char[] reason, bool requireLiveTank = true)
{
    if (!g_cvEnable.BoolValue || !g_cvTankPlay.BoolValue) return false;
    if (g_bIsFinale) return false;   // en finales la musica del tank la lleva el juego (original)

    // v1.5: la etapa TANK solo existe con un tank REAL. La musica nativa
    // puede quedar sonando/re-emitiendose sin tank vivo (cue rezagada,
    // tanque de prop/plugin sin cliente, admin slay): abrirla a ciegas
    // era el motor del loop radar<->watchdog.
    if (requireLiveTank && GetActiveTankCount(0) == 0)
    {
        MD_ArmRadarRecheck();
        LogMessage("[MusicDirector] RADAR: musica nativa del tank PERO SIN tank vivo — etapa NO abierta (re-check 1.5s). Fuente: %s", reason);
        MD_Debug("Tank RECHAZADO (%s): sin tank vivo", reason);
        return false;
    }

    // tank nuevo a mitad de FADE: cancelar el fade y seguir sonando
    if (g_hFadeTimer != null) CancelFade();

    // si la etapa TANK ya esta sonando (multi-tank): no reiniciar la cancion
    if (g_iStage == MDST_TANK && g_sPlayingSound[0] != '\0') return true;

    // si hay una etapa de prioridad MAYOR sonando (escape/LMS), el tank
    // pierde — el escape es exclusivo y solo LMS/victoria lo reemplazan
    if (g_iStage != MDST_NONE && g_iStagePrio > MD_PRIO_TANK) return false;

    if (g_aTankMusic.Length == 0) return false;

    // seleccion aleatoria SIN repetir la del tank anterior
    char song[PLATFORM_MAX_PATH];
    int guard = 0;
    do {
        g_aTankMusic.GetString(GetRandomInt(0, g_aTankMusic.Length - 1), song, sizeof(song));
        guard++;
    } while (g_aTankMusic.Length > 1 && StrEqual(song, g_sLastTankSong) && guard < 16);
    strcopy(g_sLastTankSong, sizeof(g_sLastTankSong), song);

    if (MD_EnterStage(MDST_TANK, MD_PRIO_TANK, song, 0.0, reason))
    {
        PrintToChatAll("\x04[Music]\x01 \x03TANK WAVE\x01 — %s", song);
        return true;
    }
    return false;
}

public void Event_TankKilled(Event event, const char[] name, bool dontBroadcast)
{
    if (g_iStage != MDST_TANK) return;

    int victim = GetClientOfUserId(event.GetInt("userid"));

    // multi-tank: solo el ULTIMO tank devuelve el audio (original)
    if (GetActiveTankCount(victim) > 0) return;

    g_iTankGoneTicks = 0;
    MD_LeaveStage(true, "ultimo tank muerto");
    PrintToChatAll("\x04[Music]\x01 Amenaza eliminada. Audio normal restaurado.");
}

int GetActiveTankCount(int ignoreClient)
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == ignoreClient) continue;
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3)
            if (GetEntProp(i, Prop_Send, "m_zombieClass") == ZC_TANK)
                count++;
    }
    return count;
}

// =====================================================================================
//  v1.5: RE-CHECK DIFERIDO DEL RADAR
// =====================================================================================
// La musica nativa del tank puede llegar un instante ANTES de que el bot
// del tank sea visible para GetActiveTankCount. Esperamos 1.5s y miramos
// otra vez: si el tank aparecio, la etapa entra (y sonara hasta que
// muera de verdad); si NO aparecio, la musica era un fantasma (cue
// rezagada / tanque de prop) y NO se abre nada — asi muere el loop
// radar->watchdog->radar->watchdog que interrumpia la cancion del menu
// cada pocos segundos.
void MD_ArmRadarRecheck()
{
    if (g_hRadarRecheck != null) return;   // ya hay una re-verificacion en vuelo
    g_hRadarRecheck = CreateTimer(1.5, Timer_RadarRecheck, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RadarRecheck(Handle timer)
{
    g_hRadarRecheck = null;

    // mientras esperabamos alguien abrio una etapa mayor: fuera
    if (g_iStage == MDST_TANK || g_iStage == MDST_ESCAPE
        || g_iStage == MDST_LMS || g_iStage == MDST_VICTORY) return Plugin_Stop;
    if (g_bIsFinale) return Plugin_Stop;

    if (GetActiveTankCount(0) > 0)
    {
        TriggerTankStage("RADAR re-check (tank confirmado a los 1.5s)");
    }
    else
    {
        MD_Debug("RADAR re-check: sigue sin haber tank — no se abre la etapa");
    }
    return Plugin_Stop;
}

void MD_KillRadarRecheck()
{
    if (g_hRadarRecheck != null)
    {
        KillTimer(g_hRadarRecheck);
        g_hRadarRecheck = null;
    }
}

// =====================================================================================
//  ETAPA: ESCAPE / VICTORIA (deteccion original multi-via)
// =====================================================================================
public void OnFinaleLogicTriggered(const char[] output, int caller, int activator, float delay)
{
    TriggerEscape("ENTIDAD: trigger_finale Output");
}

public void OnSpyRelayTriggered(const char[] output, int caller, int activator, float delay)
{
    char sName[128];
    GetEntPropString(caller, Prop_Data, "m_iName", sName, sizeof(sName));

    if (StrEqual(sName, "relay_car_ready") ||
        StrEqual(sName, "relay_start_heli") ||
        StrEqual(sName, "helicopter_land_relay") ||
        StrEqual(sName, "relay_leave_boat") ||
        StrEqual(sName, "plane_takeoff_relay") ||
        StrEqual(sName, "generator_final_button_relay") ||
        StrContains(sName, "escape", false) != -1 ||
        StrContains(sName, "vehicle", false) != -1 ||
        StrContains(sName, "ready", false) != -1)
    {
        char sReason[160];
        Format(sReason, sizeof(sReason), "relay (%s)", sName);
        TriggerEscape(sReason);
    }
}

public void Event_EscapeStart(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bIsFinale) TriggerEscape("evento finale_escape_start");
}

// v1.1: los finales GAUNTLET (c1m4 atrio, c4m5 milltown, c5m5 bridge,
// c6m3 port...) arrancan la huida con este evento — antes esos mapas
// dependian solo del radar de sonido y de los relays
public void Event_GauntletStart(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bIsFinale) TriggerEscape("evento gauntlet_finale_start");
}

void TriggerEscape(const char[] reason)
{
    if (!g_cvEnable.BoolValue || !g_cvEscapePlay.BoolValue) return;
    if (g_bEscapeStarted) return;
    if (g_iStage == MDST_VICTORY) return;

    g_bEscapeStarted = true;

    // la cancion de escape (lista vacia/comentada = etapa de solo-silencio:
    // el juego se calla pero no suena nada custom — exactamente como hoy)
    char song[PLATFORM_MAX_PATH];
    if (g_aFinaleMusic.Length > 0)
    {
        // v1.3: azar SIN repetir la del final anterior (receta del tank).
        // Pedido del owner: "deben escucharse 1 a azar no siempre se
        // escuchara la misma" — con el azar puro y pocas canciones, en
        // finales consecutivos tocaba la misma una y otra vez.
        int guard = 0;
        do {
            g_aFinaleMusic.GetString(GetRandomInt(0, g_aFinaleMusic.Length - 1), song, sizeof(song));
            guard++;
        } while (g_aFinaleMusic.Length > 1 && StrEqual(song, g_sLastEscapeSong) && guard < 16);
        strcopy(g_sLastEscapeSong, sizeof(g_sLastEscapeSong), song);
    }

    MD_EnterStage(MDST_ESCAPE, MD_PRIO_ESCAPE, song, 0.0, reason);
    PrintToChatAll("\x04[Music]\x01 \x05ESCAPE\x01 activado por: %s", reason);
    if (song[0] != '\0')
        PrintToChatAll("\x04[Music]\x01 Escape: \x03%s", song);   // v1.3: como el tank, para comprobar la variedad
}

public void Event_FinaleWin(Event event, const char[] name, bool dontBroadcast)
{
    MD_TriggerVictory("evento finale_win");
}

// v1.1: el vehiculo largandose TAMBIEN es victoria — en algunos mapas el
// finale_win llega tarde o nunca (cambio de mapa rapido) y la musica
// custom se quedaba sonando en la pantalla de creditos
public void Event_VehicleLeaving(Event event, const char[] name, bool dontBroadcast)
{
    MD_TriggerVictory("evento finale_vehicle_leaving");
}

// v1.1: camino unico de la victoria (finale_win + finale_vehicle_leaving)
void MD_TriggerVictory(const char[] reason)
{
    if (g_iStage == MDST_VICTORY) return;   // ya esta en victoria (los 2 eventos pueden llegar)

    // victoria: TODO custom fuera YA — que suene el win del juego
    g_bEscapeStarted = false;
    MD_EnterStage(MDST_VICTORY, MD_PRIO_VICTORY, "", 0.0, reason);

    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && !IsFakeClient(i))
            ClientCommand(i, "music_dynamic_stop_playing");

    // la etapa victoria termina sola en 20s (por si el mapa tarda)
    CreateTimer(20.0, Timer_VictoryEnd, _, TIMER_FLAG_NO_MAPCHANGE);
    PrintToChatAll("\x04[Music]\x01 \x04VICTORIA\x01 — audio del juego restaurado. (%s)", reason);
}

public Action Timer_VictoryEnd(Handle timer)
{
    if (g_iStage == MDST_VICTORY)
        MD_LeaveStage(false, "fin de victoria");
    return Plugin_Stop;
}

// =====================================================================================
//  FIN DE RONDA / MAPA — limpieza TOTAL (sin fugas de music_manager)
// =====================================================================================
public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    g_sPausedSong[0] = '\0';      // v1.4: la pausa no cruza rondas
    g_bResumePending = false;
    MD_KillRadarRecheck();        // v1.5: la re-verificacion del radar tampoco
    MD_LeaveStage(false, "round_end");
    MD_StopAllPlayback(true);
    ResetRoundFlags();
    delete g_hRoundDelayTimer;
    SetGameMusicManager(true);
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        delete g_hJoinTimer[client];
        g_sPersonal[client][0] = '\0';
        g_fVolume[client] = 1.0;
        g_bMuted[client] = false;
        g_iPersonalIdx[client] = 0;
        g_iMenuPos[client] = 0;
        MD_RestoreGameMusicIfIdle();
    }
    return Plugin_Continue;
}

// =====================================================================================
//  EL MENU !music (original MusicMapStart, mismo flujo)
// =====================================================================================
public Action Cmd_Music(int client, int args)
{
    if (client <= 0) return Plugin_Handled;
    if (g_cvEnable.BoolValue) ShowMusicMenu(client, true);
    return Plugin_Handled;
}

void ShowMusicMenu(int client, bool forever)
{
    Menu menu = new Menu(MenuHandler_Main);

    // v1.4: el titulo avisa si hay una PARA TODOS en pausa
    if (g_sPausedSong[0] != '\0')
        menu.SetTitle("MUSIC DIRECTOR — Etapa: %s\n(Hay una cancion PARA TODOS en pausa: vuelve al cerrar esta etapa)", MD_StageName());
    else
        menu.SetTitle("MUSIC DIRECTOR — Etapa: %s", MD_StageName());

    menu.AddItem("1", "Parar mi musica");
    menu.AddItem("2", "Repetir mi cancion");
    menu.AddItem("3", "Volumen");
    menu.AddItem("4", "Elegir cancion (solo yo)");

    char sAccess[24];
    g_cvPlayAllAccess.GetString(sAccess, sizeof(sAccess));
    if (HasAccess(client, sAccess))
    {
        menu.AddItem("5", "Poner cancion PARA TODOS");
        // v1.4: detener la global (activa o en pausa) — mismo permiso que ponerla
        if (g_iStage == MDST_MENUMUSIC || g_sPausedSong[0] != '\0')
            menu.AddItem("6", "Detener la musica para todos");
    }

    menu.Pagination = MENU_NO_PAGINATION;
    menu.ExitButton = true;
    if (forever) menu.Display(client, MENU_TIME_FOREVER);
    else         menu.Display(client, 20);
}

public int MenuHandler_Main(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_End: delete menu;
        case MenuAction_Select:
        {
            int client = param1;
            char sItem[8];
            menu.GetItem(param2, sItem, sizeof(sItem));

            switch (StringToInt(sItem))
            {
                case 1: MD_StopPersonal(client);
                case 2:
                {
                    char path[PLATFORM_MAX_PATH];
                    if (g_iPersonalIdx[client] >= 0 && g_iPersonalIdx[client] < g_aRoundMusic.Length)
                    {
                        g_aRoundMusic.GetString(g_iPersonalIdx[client], path, sizeof(path));
                        MD_PlayPersonal(client, path, g_aRoundDuration.Get(g_iPersonalIdx[client]));
                    }
                }
                case 3: { ShowVolumeMenu(client); return 0; }
                case 4: { ShowListMenu(client, false); return 0; }
                case 5: { ShowListMenu(client, true); return 0; }
                case 6:
                {
                    // v1.4: detener la PARA TODOS — activa o en pausa.
                    // v1.5: parar = PARAR: en AMBAS ramas muere tambien la
                    // pausa y la reanudacion pendiente (antes, con una
                    // pausa vieja dada vuelta, la cancion anterior podia
                    // resucitar justo despues del stop).
                    if (g_iStage == MDST_MENUMUSIC)
                    {
                        g_sPausedSong[0] = '\0';
                        g_bResumePending = false;
                        MD_LeaveStage(false, "stop-global");
                        PrintToChatAll("\x04[Music]\x01 %N detuvo la musica para todos.", client);
                    }
                    else if (g_sPausedSong[0] != '\0')
                    {
                        g_sPausedSong[0] = '\0';
                        g_bResumePending = false;
                        PrintToChatAll("\x04[Music]\x01 %N cancelo la musica para todos: no volvera al terminar la etapa.", client);
                    }
                }
            }
            ShowMusicMenu(client, true);
        }
    }
    return 0;
}

void ShowVolumeMenu(int client)
{
    Menu menu = new Menu(MenuHandler_Volume);
    menu.SetTitle("VOLUMEN DE TUS MUSICAS");
    menu.AddItem("0.0", "0.0 (mudo)");
    menu.AddItem("0.2", "0.2");
    menu.AddItem("0.4", "0.4");
    menu.AddItem("0.6", "0.6");
    menu.AddItem("0.8", "0.8");
    menu.AddItem("1.0", "1.0 (max)");
    menu.ExitBackButton = true;
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Volume(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_End: delete menu;
        case MenuAction_Cancel:
            if (param2 == MenuCancel_ExitBack) ShowMusicMenu(param1, true);
        case MenuAction_Select:
        {
            int client = param1;
            char sItem[8];
            menu.GetItem(param2, sItem, sizeof(sItem));
            g_fVolume[client] = StringToFloat(sItem);

            // re-emite lo que este sonando con el nuevo volumen
            char path[PLATFORM_MAX_PATH];
            if (g_sPersonal[client][0] != '\0')
            {
                strcopy(path, sizeof(path), g_sPersonal[client]);
                MD_StopPersonal(client);
                MD_PlayPersonal(client, path, 0.0);
            }
            else if (g_sPlayingSound[0] != '\0' && !g_bMuted[client])
            {
                strcopy(path, sizeof(path), g_sPlayingSound);
                MD_PlayGlobal(path);
            }
            ShowVolumeMenu(client);
        }
    }
    return 0;
}

void ShowListMenu(int client, bool forAll)
{
    Menu menu;
    if (forAll) { menu = new Menu(MenuHandler_PlayAll);   menu.SetTitle("PONER PARA TODOS"); }
    else        { menu = new Menu(MenuHandler_Choose);    menu.SetTitle("ELEGIR (solo yo)"); }

    char index[8], sName[128];
    for (int i = 0; i < g_aRoundMusic.Length; i++)
    {
        IntToString(i, index, sizeof(index));
        g_aRoundNames.GetString(i, sName, sizeof(sName));
        menu.AddItem(index, sName);
    }
    menu.ExitBackButton = true;
    menu.ExitButton = true;
    menu.DisplayAt(client, g_iMenuPos[client], MENU_TIME_FOREVER);
}

public int MenuHandler_PlayAll(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_End: delete menu;
        case MenuAction_Cancel:
            if (param2 == MenuCancel_ExitBack) ShowMusicMenu(param1, true);
        case MenuAction_Select:
        {
            int client = param1;
            if (GetEngineTime() < g_fNextPlayAll)
            {
                PrintToChat(client, "\x04[Music]\x01 Espera %.0fs para poner otra para todos.", g_fNextPlayAll - GetEngineTime());
            }
            else if (g_aRoundMusic.Length > 0)
            {
                char sItem[8], path[PLATFORM_MAX_PATH], sName[128];
                menu.GetItem(param2, sItem, sizeof(sItem));
                int idx = StringToInt(sItem);
                g_aRoundMusic.GetString(idx, path, sizeof(path));
                g_aRoundNames.GetString(idx, sName, sizeof(sName));
                float duration = g_aRoundDuration.Get(idx);
                g_fNextPlayAll = GetEngineTime() + g_cvPlayAllCooldown.FloatValue;

                // para TODOS = etapa MENU (la prioridad deja pasar a tank/escape).
                // v1.5: una cancion NUEVA reemplaza a la vieja TAMBIEN en la
                // pausa: si habia una PARA TODOS esperando a volver (pausada
                // por una etapa mayor), el owner ya decidio que suena ESTA —
                // la vieja no puede resucitar encima cuando esta termine.
                g_sPausedSong[0] = '\0';
                g_bResumePending = false;
                if (MD_EnterStage(MDST_MENUMUSIC, MD_PRIO_MENU, path, duration, "menu-todos"))
                {
                    for (int i = 1; i <= MaxClients; i++) g_iPersonalIdx[i] = idx;
                    PrintToChatAll("\x04[Music]\x01 %N puso para todos: \x03%s\x01", client, sName);
                }
            }
            g_iMenuPos[client] = menu.Selection;
            ShowListMenu(client, true);
        }
    }
    return 0;
}

public int MenuHandler_Choose(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_End: delete menu;
        case MenuAction_Cancel:
            if (param2 == MenuCancel_ExitBack) ShowMusicMenu(param1, true);
        case MenuAction_Select:
        {
            int client = param1;
            char sItem[8], path[PLATFORM_MAX_PATH];
            menu.GetItem(param2, sItem, sizeof(sItem));
            int idx = StringToInt(sItem);
            g_aRoundMusic.GetString(idx, path, sizeof(path));
            g_iPersonalIdx[client] = idx;
            MD_PlayPersonal(client, path, g_aRoundDuration.Get(idx));
            g_iMenuPos[client] = menu.Selection;
            ShowListMenu(client, false);
        }
    }
    return 0;
}

// =====================================================================================
//  COMANDOS
// =====================================================================================
public Action Cmd_MusicOff(int client, int args)
{
    if (client <= 0) return Plugin_Handled;
    g_bMuted[client] = true;
    MD_StopPersonal(client);
    if (g_sPlayingSound[0] != '\0' && IsClientInGame(client))
        StopSound(client, MD_CHANNEL, g_sPlayingSound);
    PrintToChat(client, "\x04[Music]\x01 Tus musicas custom: \x03APAGADAS\x01 (mp3on para volver).");
    return Plugin_Handled;
}

public Action Cmd_MusicOn(int client, int args)
{
    if (client <= 0) return Plugin_Handled;
    g_bMuted[client] = false;
    PrintToChat(client, "\x04[Music]\x01 Tus musicas custom: \x03ENCENDIDAS\x01.");
    return Plugin_Handled;
}

public Action Cmd_MusicUpdate(int client, int args)
{
    LoadLists();
    PrecacheAndDownload();
    ReplyToCommand(client, "[Music] Listas recargadas: %d arranque / %d tank / %d escape.",
                   g_aRoundMusic.Length, g_aTankMusic.Length, g_aFinaleMusic.Length);
    return Plugin_Handled;
}

public Action Cmd_PlayTank(int client, int args)
{
    if (g_aTankMusic.Length == 0)
    {
        ReplyToCommand(client, "[Music] La lista de tank esta vacia.");
        return Plugin_Handled;
    }
    char song[PLATFORM_MAX_PATH];
    g_aTankMusic.GetString(GetRandomInt(0, g_aTankMusic.Length - 1), song, sizeof(song));
    strcopy(g_sLastTankSong, sizeof(g_sLastTankSong), song);
    MD_EnterStage(MDST_TANK, MD_PRIO_TANK, song, 0.0, "sm_playtank");
    ReplyToCommand(client, "[Music] Musica de TANK forzada: %s", song);
    return Plugin_Handled;
}

public Action Cmd_NextTankSong(int client, int args)
{
    if (g_aTankMusic.Length == 0) return Plugin_Handled;

    char song[PLATFORM_MAX_PATH];
    int guard = 0;
    do {
        g_aTankMusic.GetString(GetRandomInt(0, g_aTankMusic.Length - 1), song, sizeof(song));
        guard++;
    } while (g_aTankMusic.Length > 1 && StrEqual(song, g_sLastTankSong) && guard < 16);
    strcopy(g_sLastTankSong, sizeof(g_sLastTankSong), song);

    MD_EnterStage(MDST_TANK, MD_PRIO_TANK, song, 0.0, "sm_nexttank");
    ReplyToCommand(client, "[Music] Cancion de TANK cambiada: %s", song);
    return Plugin_Handled;
}

public Action Cmd_TestEscape(int client, int args)
{
    g_bIsFinale = true;
    g_bEscapeStarted = false;
    TriggerEscape("comando de prueba");
    ReplyToCommand(client, "[Music] Prueba de escape disparada.");
    return Plugin_Handled;
}

public Action Cmd_StopAll(int client, int args)
{
    g_bEscapeStarted = false;
    g_sPausedSong[0] = '\0';      // v1.4: parar TODO incluye la pausa
    g_bResumePending = false;
    MD_LeaveStage(false, "sm_mdstop");
    MD_StopAllPlayback(true);
    SetGameMusicManager(true);
    ReplyToCommand(client, "[Music] Toda la musica custom detenida. Audio del juego restaurado.");
    return Plugin_Handled;
}

public Action Cmd_Status(int client, int args)
{
    ReplyToCommand(client, "[Music Director %s] Etapa: %s (prio %d) | Sonando: %s | metodo: %s",
                   MD_VERSION, MD_StageName(), g_iStagePrio,
                   (g_sPlayingSound[0] != '\0') ? g_sPlayingSound : "nada",
                   g_cvMusicManager.BoolValue ? "music_manager 0/1 (viejo)" : "silencio quirurgico (music 0 anulado)");
    if (g_sPausedSong[0] != '\0')
        ReplyToCommand(client, "[Music] PARA TODOS en pausa: %s (vuelve al cerrar esta etapa; le quedaban %.0fs)", g_sPausedSong, g_fPausedRemain);
    if (g_iStage != MDST_NONE && g_fStageEnd > 0.0)
        ReplyToCommand(client, "[Music] La etapa termina en %.0fs.", g_fStageEnd - GetEngineTime());
    if (g_hLoopTimer != null)
        ReplyToCommand(client, "[Music] Loop activo: la cancion se repite cada %.0fs mientras dure la etapa.", g_fLoopInterval);
    return Plugin_Handled;
}

// sm_musicstage <stage 1-7> <prio> <segundos> [ruta.mp3] — ADMIN/LMS
public Action Cmd_Stage(int client, int args)
{
    if (args < 3)
    {
        ReplyToCommand(client, "[Music] Uso: sm_musicstage <1-8> <prio> <segundos 0=inf> [ruta/sonido]");
        ReplyToCommand(client, "[Music] Etapas: 1=arranque 2=entrada 3=menu 4=custom 5=tank 6=escape 7=victoria 8=LMS (prio 55)");
        return Plugin_Handled;
    }

    char s1[8], s2[8], s3[16], s4[PLATFORM_MAX_PATH];
    GetCmdArg(1, s1, sizeof(s1));
    GetCmdArg(2, s2, sizeof(s2));
    GetCmdArg(3, s3, sizeof(s3));
    if (args >= 4) GetCmdArg(4, s4, sizeof(s4));
    else s4 = "";

    int stage = StringToInt(s1);
    int prio  = StringToInt(s2);
    float dur = StringToFloat(s3);

    if (stage < 1 || stage > 8) { ReplyToCommand(client, "[Music] Etapa fuera de rango (1-8)."); return Plugin_Handled; }
    if (prio <= 0) prio = (stage == MDST_LMS) ? MD_PRIO_LMS : MD_PRIO_CUSTOM;

    if (MD_EnterStage(stage, prio, s4, dur, "sm_musicstage"))
        ReplyToCommand(client, "[Music] Etapa %d (prio %d, %.0fs) ACTIVA.", stage, prio, dur);
    else
        ReplyToCommand(client, "[Music] RECHAZADA: hay una etapa con mas prioridad sonando (%s).", MD_StageName());
    return Plugin_Handled;
}

// =====================================================================================
//  LISTAS Y PRECACHE (formatos originales intactos)
// =====================================================================================
void LoadLists()
{
    // ---- music_mapstart.txt: "ruta.mp3 TAG- Nombre-segundos" ----
    char path[PLATFORM_MAX_PATH];
    g_aRoundMusic.Clear();
    g_aRoundNames.Clear();
    g_aRoundDuration.Clear();

    BuildPath(Path_SM, path, sizeof(path), "data/music_mapstart.txt");
    File f = OpenFile(path, "r");
    if (f != null)
    {
        char buffer[PLATFORM_MAX_PATH], sSound[PLATFORM_MAX_PATH];
        while (!f.EndOfFile() && f.ReadLine(buffer, sizeof(buffer)))
        {
            TrimString(buffer);
            if (buffer[0] == '\0' || buffer[0] == '/' ) continue;

            // "ruta TAG- Nombre-duracion" (formato del server: split por " TAG- ")
            if (SplitString(buffer, " TAG-", sSound, sizeof(sSound)) > 0)
            {
                ReplaceString(buffer, sizeof(buffer), sSound, "", false);
                ReplaceString(buffer, sizeof(buffer), " TAG- ", "", false);
                TrimString(buffer);

                // duracion al final, tras el ultimo '-'
                char sName[PLATFORM_MAX_PATH], sDur[16];
                float duration = 0.0;
                int idx = FindCharInString(buffer, '-', true);
                if (idx != -1)
                {
                    strcopy(sName, sizeof(sName), buffer);
                    sName[idx] = '\0';
                    strcopy(sDur, sizeof(sDur), buffer[idx + 1]);
                    TrimString(sDur);
                    duration = StringToFloat(sDur);
                    TrimString(sName);
                }
                else strcopy(sName, sizeof(sName), buffer);

                g_aRoundMusic.PushString(sSound);
                g_aRoundNames.PushString(sName);
                g_aRoundDuration.Push(duration);
            }
            else
            {
                // linea sin TAG: la ruta sola, sin nombre ni duracion
                g_aRoundMusic.PushString(buffer);
                g_aRoundNames.PushString(buffer);
                g_aRoundDuration.Push(0.0);
            }
        }
        delete f;
    }
    else LogMessage("[MusicDirector] No existe data/music_mapstart.txt (musica de arranque desactivada)");

    // ---- tank_wave_sounds.txt / tank_finale_sounds.txt: "ruta.mp3" ----
    // (v1.1: aceptan TAMBIEN el formato opcional con duracion
    //  "ruta.mp3 TAG- Nombre-segundos" — el mismo de music_mapstart.txt)
    ReadSongList("data/tank_wave_sounds.txt", g_aTankMusic, g_aTankDuration);
    ReadSongList("data/tank_finale_sounds.txt", g_aFinaleMusic, g_aFinaleDuration);
}

// v1.1: lee "ruta.mp3" simple (duracion 0 = el loop usara md_loop_fallback)
// o el formato OPCIONAL con duracion "ruta.mp3 TAG- Nombre-213" — el
// mismo de music_mapstart.txt. CERO migracion: las listas actuales tal
// cual siguen valiendo.
void ReadSongList(const char[] relPath, ArrayList list, ArrayList durations)
{
    list.Clear();
    durations.Clear();
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), relPath);
    File f = OpenFile(path, "r");
    if (f == null)
    {
        LogMessage("[MusicDirector] No existe %s", relPath);
        return;
    }
    char buffer[PLATFORM_MAX_PATH], sSound[PLATFORM_MAX_PATH];
    while (!f.EndOfFile() && f.ReadLine(buffer, sizeof(buffer)))
    {
        TrimString(buffer);
        if (buffer[0] == '\0' || buffer[0] == '/') continue;

        if (SplitString(buffer, " TAG-", sSound, sizeof(sSound)) > 0)
        {
            // duracion al final, tras el ultimo '-'
            char sDur[16];
            float duration = 0.0;
            int idx = FindCharInString(buffer, '-', true);
            if (idx != -1)
            {
                strcopy(sDur, sizeof(sDur), buffer[idx + 1]);
                TrimString(sDur);
                duration = StringToFloat(sDur);
            }
            if (duration < 0.0) duration = 0.0;
            list.PushString(sSound);
            durations.Push(duration);
        }
        else
        {
            list.PushString(buffer);
            durations.Push(0.0);
        }
    }
    delete f;
}

void PrecacheAndDownload()
{
    char sSound[PLATFORM_MAX_PATH], sDL[PLATFORM_MAX_PATH];

    // ---- v1.2 FIX: PRECACHE DE TODAS, SIEMPRE ----
    // El menu !music reproduce CUALQUIER cancion de music_mapstart.txt,
    // asi que TODAS deben estar precacheadas o el engine tira
    // "SV_StartSound: not precached (0)" y queda en silencio. El precache
    // es solo del lado del server (registro en la tabla de sonidos):
    // registrar 40-50 rutas cuesta nada. Lo que SI se puede limitar es
    // la DESCARGA del cliente (bandwidth) — eso es md_download_number.
    int total = g_aRoundMusic.Length;
    for (int i = 0; i < total; i++)
    {
        g_aRoundMusic.GetString(i, sSound, sizeof(sSound));
        if (!PrecacheSound(sSound, true))
            LogMessage("[MusicDirector] AVISO: '%s' NO existe en sound/ — revisa que el MP3 este subido al server (la cancion no sonara).", sSound);
    }

    // ---- descargas de la lista de arranque (SOLO bandwidth) ----
    // md_download_number 0 (default v1.2) = TODAS se descargan: el menu
    // puede reproducir cualquiera y todos los clientes la tienen.
    // > 0 = solo N aleatorias por mapa van a la tabla de descargas
    // (receta del original para servers con bandwidth justo): el resto
    // esta precacheada y sonara solo para quien ya tenga el MP3.
    int n = g_cvDownloadNumber.IntValue;
    if (n > 0 && total > n)
    {
        // marcas de seleccion (swap-remove del original)
        int[] order = new int[total];
        for (int i = 0; i < total; i++) order[i] = i;
        for (int i = 0; i < n; i++)
        {
            int pick = GetRandomInt(0, total - 1 - i);
            g_aRoundMusic.GetString(order[pick], sSound, sizeof(sSound));
            Format(sDL, sizeof(sDL), "sound/%s", sSound);
            AddFileToDownloadsTable(sDL);
            order[pick] = order[total - 1 - i];
        }
    }
    else
    {
        for (int i = 0; i < total; i++)
        {
            g_aRoundMusic.GetString(i, sSound, sizeof(sSound));
            Format(sDL, sizeof(sDL), "sound/%s", sSound);
            AddFileToDownloadsTable(sDL);
        }
    }

    // tank y escape: TODAS (precache + descarga, como siempre)
    for (int i = 0; i < g_aTankMusic.Length; i++)
    {
        g_aTankMusic.GetString(i, sSound, sizeof(sSound));
        if (!PrecacheSound(sSound, true))
            LogMessage("[MusicDirector] AVISO: '%s' NO existe en sound/ — revisa que el MP3 este subido al server (la cancion no sonara).", sSound);
        Format(sDL, sizeof(sDL), "sound/%s", sSound);
        AddFileToDownloadsTable(sDL);
    }
    for (int i = 0; i < g_aFinaleMusic.Length; i++)
    {
        g_aFinaleMusic.GetString(i, sSound, sizeof(sSound));
        if (!PrecacheSound(sSound, true))
            LogMessage("[MusicDirector] AVISO: '%s' NO existe en sound/ — revisa que el MP3 este subido al server (la cancion no sonara).", sSound);
        Format(sDL, sizeof(sDL), "sound/%s", sSound);
        AddFileToDownloadsTable(sDL);
    }
}

// =====================================================================================
//  DETECCION DE MAPA FINAL (lista original completa)
// =====================================================================================
bool CheckIfFinaleMap()
{
    if (FindEntityByClassname(-1, "trigger_finale") != -1) return true;

    char sMap[64];
    GetCurrentMap(sMap, sizeof(sMap));
    if (StrEqual(sMap, "l4d_hospital05_rooftop", false) ||
        StrEqual(sMap, "c12m5_cornfield", false) ||
        StrEqual(sMap, "c1m4_atrium", false) ||
        StrEqual(sMap, "c2m5_concert", false) ||
        StrEqual(sMap, "c3m4_plantation", false) ||
        StrEqual(sMap, "c4m5_milltown_escape", false) ||
        StrEqual(sMap, "c5m5_bridge", false) ||
        StrEqual(sMap, "c6m3_port", false) ||
        StrEqual(sMap, "c7m3_port", false) ||
        StrEqual(sMap, "c8m5_rooftop", false) ||
        StrEqual(sMap, "c9m2_lots", false) ||
        StrEqual(sMap, "c10m5_houseboat", false) ||
        StrEqual(sMap, "c11m5_runway", false) ||
        StrEqual(sMap, "c13m4_cutthroatcreek", false) ||
        StrEqual(sMap, "l4d_river03_port", false))
        return true;
    return false;
}

void ScanAndHookRelays()
{
    int entity = -1;
    char sName[128];
    while ((entity = FindEntityByClassname(entity, "logic_relay")) != -1)
    {
        GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));
        if (StrEqual(sName, "relay_car_ready") ||
            StrEqual(sName, "relay_start_heli") ||
            StrEqual(sName, "helicopter_land_relay") ||
            StrEqual(sName, "relay_escape_starts") ||
            StrEqual(sName, "escape_relay") ||
            StrEqual(sName, "relay_leave_boat") ||
            StrEqual(sName, "plane_takeoff_relay") ||
            StrEqual(sName, "generator_final_button_relay") ||
            StrContains(sName, "apc", false) != -1 ||
            StrContains(sName, "vehicle", false) != -1 ||
            StrContains(sName, "ready", false) != -1 ||
            StrContains(sName, "escape", false) != -1)
        {
            HookSingleEntityOutput(entity, "OnTrigger", OnSpyRelayTriggered);
        }
    }
}

// =====================================================================================
//  SDKCALL Music::StopPlaying (generador de gamedata original)
// =====================================================================================
void LoadDirectorHack()
{
    GenerateGameData();
    GameData hGameData = new GameData("dynamic_soundtrack_sets-l4d2");
    if (hGameData != null)
    {
        StartPrepSDKCall(SDKCall_Raw);
        PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "Music::StopPlaying");
        PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
        PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
        PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
        hSDK_StopMusic = EndPrepSDKCall();
        delete hGameData;
    }
}

void GenerateGameData()
{
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/dynamic_soundtrack_sets-l4d2.txt");
    if (FileExists(sPath)) return;

    File f = OpenFile(sPath, "w");
    if (f != null)
    {
        f.WriteLine("\"Games\"");
        f.WriteLine("{");
        f.WriteLine("    \"left4dead2\"");
        f.WriteLine("    {");
        f.WriteLine("        \"Signatures\"");
        f.WriteLine("        {");
        f.WriteLine("            \"Music::StopPlaying\"");
        f.WriteLine("            {");
        f.WriteLine("                \"library\"    \"server\"");
        f.WriteLine("                \"linux\"      \"@_ZN5Music11StopPlayingEPKcfb\"");
        f.WriteLine("                \"mac\"        \"@_ZN5Music11StopPlayingEPKcfb\"");
        f.WriteLine("                \"windows\"    \"\\x55\\x8B\\x2A\\x83\\x2A\\x2A\\xA1\\x2A\\x2A\\x2A\\x2A\\x83\\x2A\\x2A\\x2A\\x56\\x8B\\x2A\\x89\\x2A\\x2A\\x0F\\x84\\x25\"");
        f.WriteLine("            }");
        f.WriteLine("        }");
        f.WriteLine("    }");
        f.WriteLine("}");
        delete f;
    }
}

void Internal_StopMusic(int client, const char[] musicEvent)
{
    if (hSDK_StopMusic != null && IsClientInGame(client) && !IsFakeClient(client))
    {
        Address pMusic = GetEntityAddress(client) + view_as<Address>(GetEntSendPropOffs(client, "m_music"));
        if (pMusic != Address_Null) SDKCall(hSDK_StopMusic, pMusic, musicEvent, 0.0, false);
    }
}

// =====================================================================================
//  LOOP DE CANCION (v1.1) — tank/escape/LMS sin fin natural de etapa
// =====================================================================================
// duracion conocida de una cancion (TAG- en la lista) o 0 si es externa
float MD_SongDuration(const char[] song)
{
    int idx = g_aTankMusic.FindString(song);
    if (idx != -1) return view_as<float>(g_aTankDuration.Get(idx));
    idx = g_aFinaleMusic.FindString(song);
    if (idx != -1) return view_as<float>(g_aFinaleDuration.Get(idx));
    return 0.0;   // desconocida (ej. sonido LMS de un plugin externo)
}

// arma el re-emitidor: cada X segundos vuelve a sonar la cancion de la
// etapa mientras esta viva. X = duracion TAG- de la cancion o, si no la
// trae, md_loop_fallback (GetSoundDuration esta ROTO en este motor —
// deprecado "does not work, may crash" — por eso el fallback)
void MD_ArmLoop(const char[] song)
{
    KillLoopTimer();
    float interval = MD_SongDuration(song);
    if (interval < 5.0) interval = g_cvLoopFallback.FloatValue;
    g_fLoopInterval = interval;
    g_hLoopTimer = CreateTimer(interval, Timer_LoopSong, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    MD_Debug("Loop armado: %.0fs (%s)", interval, song);
}

public Action Timer_LoopSong(Handle timer)
{
    // la etapa pudo cerrarse o cambiar de cancion entre ticks: si este
    // timer sigue vivo pero ya no es el del loop actual, fuera
    if (g_iStage == MDST_NONE || g_sPlayingSound[0] == '\0' || g_hLoopTimer != timer)
    {
        if (g_hLoopTimer == timer) g_hLoopTimer = null;
        return Plugin_Stop;
    }

    char song[PLATFORM_MAX_PATH];
    strcopy(song, sizeof(song), g_sPlayingSound);
    MD_PlayGlobal(song);   // respeta volumen y mute por jugador
    MD_Debug("Loop de etapa (%s): re-emitida", MD_StageName());
    return Plugin_Continue;
}

void KillLoopTimer()
{
    if (g_hLoopTimer != null)
    {
        KillTimer(g_hLoopTimer);
        g_hLoopTimer = null;
    }
    g_fLoopInterval = 0.0;
}

// =====================================================================================
//  UTILIDADES
// =====================================================================================
void MD_Debug(const char[] format, any ...)
{
    if (g_cvDebug == null || !g_cvDebug.BoolValue) return;
    char buffer[256];
    VFormat(buffer, sizeof(buffer), format, 2);
    PrintToServer("[MusicDirector] %s", buffer);
}

char[] MD_StageName()
{
    static const char names[9][24] = MD_STAGENAMES;
    char buf[24];
    if (g_iStage < 0 || g_iStage > 8) strcopy(buf, sizeof(buf), "?");
    else strcopy(buf, sizeof(buf), names[g_iStage]);
    return buf;
}

bool HasAccess(int client, char[] sAcclvl)
{
    if (strlen(sAcclvl) == 0) return true;
    if (StrEqual(sAcclvl, "-1")) return false;
    if (GetUserFlagBits(client) & ReadFlagString(sAcclvl)) return true;
    return false;
}

// forward declarado a mano (el include MusicDirector.inc lo trae para los
// consumidores; aqui lo resolvemos con un CreateForward global)
Handle g_hFwdStageChanged = null;

Handle MD_GetStageChangedForward()
{
    if (g_hFwdStageChanged == null)
        g_hFwdStageChanged = CreateGlobalForward("MD_OnStageChanged", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
    return g_hFwdStageChanged;
}

void Call_StartForward_OnStageChanged(int oldStage, int newStage, int priority)
{
    Handle fwd = MD_GetStageChangedForward();
    if (fwd == null) return;
    Call_StartForward(fwd);
    Call_PushCell(oldStage);
    Call_PushCell(newStage);
    Call_PushCell(priority);
    Call_Finish();
}
