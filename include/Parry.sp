#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "2.6"

/* ------------------------------------------------------------------
 *  v2.6 (suite 3.77.44 — orden del owner 2026-10-10: "el ultimo cambio
 *  que hiciste solo hiciste que el Vscript jamas se enterara del tema
 *  este... No tienes que poner un identificador de personaje...
 *  se te hace tan dificil hacer algo como hiciste con el super tank?"):
 *  ESTE PLUGIN YA NO PARTICIPA DEL PARRY — SOLO WATCHDOG + DIAGNOSTICO.
 *
 *  La torre de naipes murio. La .43 abria la ventana asi (5 eslabones):
 *    postura -> ServerCommand knxparry_state -> Cmd_KnxParryState ->
 *    gate knxparry_chars (publicado por el manager) ->
 *    Parry_NotifyNut (RunScriptCode) -> ChCh_KnxNotify ->
 *    gate uk_parry_chars DEL .NUT (convar que SOLO mantenia ESTE
 *    plugin v2.4+). Si CUALQUIER eslabon faltaba — un Parry.smx viejo,
 *    una publicacion que no llego, un convar vacio — el VScript jamas
 *  se enteraba y TODO moria en silencio (hasta la llamada DIRECTA de
 *  Amy era rechazada por el gate del .nut).
 *
 *  La 3.77.44 es el patron supertank (SetAmyMode), SIN intermediarios:
 *    - Knuckles.inc v75: la POSTURA llama DIRECTO (RunScriptCode) a la
 *      entrada ChCh_KnxNotify del chch_parrying.nut v2.8.
 *    - Amy.inc v104: la POSE DE DEFENSA de la Z llama a SU entrada
 *      ChCh_AmyNotify (nueva) del mismo .nut.
 *    - LA ENTRADA ES LA IDENTIDAD: no hay registro de personajes, no
 *      hay convars espejo, no hay gates. Quien llama define de quien
 *      es la ventana.
 *
 *  Lo que queda vivo aqui (y por que):
 *    1. WATCHDOG del loop del .nut (cada 2 s, ::ChCh_EnsureLoop por
 *       RunScriptCode): si algo mata el logic_timer chch_parry_loop a
 *       mitad de ronda, lo revive. Guard de "in getroottable()" =
 *       no-op silencioso en .nuts viejos.
 *    2. CARGA de los .nut al empezar el mapa (chch_parrying.nut y el
 *       shim knuckles_parry_state.nut; ambos idempotentes — si tu
 *       loader ya los corrio, sus guards lo hacen no-op).
 *    3. knx_parry_status: diagnostico honesto — handshake, heartbeat,
 *       loop, y LAS VENTANAS LAS REPORTA EL PROPIO .NUT (su
 *       ChCh_ParryStatus imprime quien las tiene abiertas y de quien
 *       son), porque el estado ya no vive aqui.
 *
 *  RETIRADO (muerto con el registro de personajes): knxparry_state,
 *  knxparry_chars, Parry_SetWindow/CloseWindow/NotifyNut, el ejecutor
 *  nativo de la ventana (Timer_ParryWindow/WindowScan/WindowDeflect/
 *  Watch*) y sus convars (uk_parry_window, uk_parry_window_radius,
 *  uk_parry_window_sound, uk_parry_window_max, uk_parry_sound,
 *  uk_parry_chars, uk_amy_chars). Una cfg vieja con esas lineas solo
 *  tira "Unknown command" — cosmetico, sin efecto.
 * ------------------------------------------------------------------ */

ConVar cv_KnxAPI;     // handshake con chch_parrying.nut v2.2+ (lo marca el propio .nut al cargar)
ConVar cv_NutBeat;    // heartbeat del .nut v2.4+ (escribe su Time() en cada EnsureLoop)

bool g_bMapStarted = false;   // el watchdog no corre sin mapa (no hay entidades)

#define KNX_SCRIPT_RUNNER_NAME "knx_parry_runner"

public Plugin myinfo =
{
    name = "[L4D2] Ultrakill Parry (Fix Particle)",
    author = "Converted by AI",
    description = "v2.6 SOLO WATCHDOG: la ventana de parry vive en el chch_parrying.nut y la abren las entradas directas del manager (patron supertank)",
    version = PLUGIN_VERSION,
    url = ""
};

public void OnPluginStart()
{
    cv_KnxAPI = CreateConVar("uk_parry_knx_api", "0", "FLAG INTERNO: el chch_parrying.nut v2.2 lo pone a 1 al cargar (handshake). Lo lee knx_parry_status", FCVAR_DONTRECORD);
    cv_NutBeat = CreateConVar("uk_parry_nut_beat", "0", "FLAG INTERNO: heartbeat del chch_parrying.nut v2.4+ (escribe su Time() en cada EnsureLoop). Lo lee knx_parry_status", FCVAR_DONTRECORD);
    CreateConVar("uk_parry_version", PLUGIN_VERSION, "versión del plugin (beacon para el .nut)");

    // v2.6: sin AutoExecConfig — ya no hay NADA configurable aqui (la
    // ventana vive en el .nut y la abren las entradas directas). La cfg
    // vieja l4d2_ultrakill_parry.cfg queda dormida: sin este plugin
    // ejecutandola, sus lineas sueltas ya no importan.

    // DIAGNÓSTICO — si algo no bloquea, esto dice QUÉ está pasando
    RegServerCmd("knx_parry_status", Cmd_ParryStatus, "Diagnóstico del parry: handshake, heartbeat, loop del .nut y ventanas (las reporta el .nut)");

    // EL WATCHDOG — su propio timer de 2 s (antes vivia dentro del
    // timer del ejecutor nativo, que ya no existe)
    CreateTimer(2.0, Timer_Watchdog, _, TIMER_REPEAT);
}

public void OnMapStart()
{
    g_bMapStarted = true;

    // heartbeat limpio (lo marca el .nut v2.4 al cargar) y handshake a 0
    // (el .nut lo vuelve a marcar a 1 al cargar; si nadie lo marca es
    // que no está o es viejo)
    if (cv_NutBeat != null) cv_NutBeat.SetFloat(0.0);
    cv_KnxAPI.SetInt(0);

    // carga el chch_parrying.nut (idempotente: si tu loader ya lo corrió,
    // sus guards lo hacen no-op) para que las entradas
    // ChCh_KnxNotify/ChCh_AmyNotify existan aunque nadie más lo cargue
    bool bChCh = FileExists("scripts/vscripts/chch_parrying.nut");
    if (bChCh)
    {
        int runner2 = Parry_GetScriptRunner();
        if (runner2 != -1)
        {
            SetVariantString("chch_parrying");
            AcceptEntityInput(runner2, "RunScriptFile");
            SetVariantString("chch_parrying.nut");
            AcceptEntityInput(runner2, "RunScriptFile");
        }
    }

    // carga el PUENTE de estado (solo expone la API VScript externa
    // KnucklesParryWindow/End; sin el archivo todo sigue funcionando)
    bool bState = false;
    if (FileExists("scripts/vscripts/knuckles_parry_state.nut"))
    {
        int runner = Parry_GetScriptRunner();
        if (runner != -1)
        {
            SetVariantString("knuckles_parry_state");
            bool ok = AcceptEntityInput(runner, "RunScriptFile");
            SetVariantString("knuckles_parry_state.nut");
            ok = AcceptEntityInput(runner, "RunScriptFile") || ok;
            if (ok) bState = true;
        }
    }

    if (bChCh)
        PrintToServer("[Parry] v%s: chch_parrying.nut cargado — la ventana la abren las entradas directas del manager (ChCh_KnxNotify / ChCh_AmyNotify, patron supertank)", PLUGIN_VERSION);
    else
        PrintToServer("[Parry] v%s: SIN chch_parrying.nut — no hay parry de proyectiles (instala el .nut del suite en scripts/vscripts/)", PLUGIN_VERSION);

    if (bState)
        PrintToServer("[Parry] v%s: knuckles_parry_state.nut cargado (API VScript externa: KnucklesParryWindow / KnucklesParryEnd)", PLUGIN_VERSION);
}

// encuentra (o crea) un logic_script para ejecutar VScript.
// (lección v51 de Amy): SOLO se reusa NUESTRO runner etiquetado —
// el FindByClassname a ciegas podía devolver un logic_script DEL MAPA
// (eventos, fades, spawns) y ejecutar código ahí encima pisa su estado.
// Nuestro runner se crea nuevo, con scope limpio, y muere con el mapa.
int Parry_GetScriptRunner()
{
    int entity = -1;
    char nameBuf[32];
    while ((entity = FindEntityByClassname(entity, "logic_script")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        GetEntPropString(entity, Prop_Data, "m_iName", nameBuf, sizeof(nameBuf));
        if (StrEqual(nameBuf, KNX_SCRIPT_RUNNER_NAME, false)) return entity;
    }
    entity = CreateEntityByName("logic_script");
    if (entity != -1)
    {
        DispatchKeyValue(entity, "targetname", KNX_SCRIPT_RUNNER_NAME);
        DispatchSpawn(entity);
    }
    return entity;
}

/* ==================================================================
 *  EL WATCHDOG — cada 2 s le pide al .nut que reviva su loop si algo
 *  lo mató (::ChCh_EnsureLoop; en .nuts viejos el guard lo hace no-op).
 *  Con el .nut vivo esto también refresca el heartbeat
 *  uk_parry_nut_beat para knx_parry_status.
 * ================================================================== */
public Action Timer_Watchdog(Handle timer)
{
    if (!g_bMapStarted) return Plugin_Continue;
    Parry_NudgeNutLoop();
    return Plugin_Continue;
}

void Parry_NudgeNutLoop()
{
    int runner = Parry_GetScriptRunner();
    if (runner == -1 || !IsValidEntity(runner)) return;

    SetVariantString("local r = getroottable(); if(\"ChCh_EnsureLoop\" in r) r.ChCh_EnsureLoop()");
    AcceptEntityInput(runner, "RunScriptCode");
}

/* ==================================================================
 *  DIAGNÓSTICO — todo el estado del sistema en un comando. La próxima
 *  vez que "no bloquea nada", esto dice QUÉ está pasando.
 * ================================================================== */
public Action Cmd_ParryStatus(int args)
{
    PrintToServer("==================== PARRY STATUS ====================");
    PrintToServer(" Parry.smx           : v%s (SOLO WATCHDOG — la ventana de parry vive en el .nut)", PLUGIN_VERSION);
    PrintToServer(" uk_parry_knx_api    : %d (handshake del .nut: 1 = cargó)", cv_KnxAPI.IntValue);

    // heartbeat del .nut v2.4+ (escribe su Time() en cada EnsureLoop)
    float beat = (cv_NutBeat != null) ? cv_NutBeat.FloatValue : 0.0;
    if (cv_KnxAPI.IntValue == 1 && beat > 0.0 && Parry_BeatFresh(beat))
        PrintToServer(" .nut heartbeat      : VIVO (latido hace %.1f s)", GetGameTime() - beat);
    else if (cv_KnxAPI.IntValue == 1 && beat <= 0.0)
        PrintToServer(" .nut heartbeat      : SIN LATIDOS -> .nut VIEJO (v2.3-) sin EnsureLoop; ACTUALIZA chch_parrying.nut a v2.4+");
    else if (cv_KnxAPI.IntValue == 1)
        PrintToServer(" .nut heartbeat      : MUERTO (ultimo latido hace %.1f s) -> el watchdog lo revive en <=2 s", GetGameTime() - beat);
    else
        PrintToServer(" .nut heartbeat      : n/a (sin handshake: no hay .nut cargado — instala chch_parrying.nut en scripts/vscripts/)");

    // el loop del .nut existe?
    int loops = 0;
    int ent = -1;
    char nameBuf[32];
    while ((ent = FindEntityByClassname(ent, "logic_timer")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        GetEntPropString(ent, Prop_Data, "m_iName", nameBuf, sizeof(nameBuf));
        if (StrEqual(nameBuf, "chch_parry_loop", false)) loops++;
    }
    PrintToServer(" loop chch_parry_loop: %d (1 = correcto; 0 = muerto -> revive en <=2 s por el watchdog; >1 = duplicado)", loops);

    // v2.6: LAS VENTANAS VIVEN EN EL .NUT — QUE EL LAS REPORTE. Su
    // ChCh_ParryStatus (v2.8) imprime quien las tiene abiertas, de
    // quien son (AMY/KNUCKLES) y cuantos segundos les quedan.
    int runner = Parry_GetScriptRunner();
    if (runner != -1 && IsValidEntity(runner))
    {
        SetVariantString("local r = getroottable(); if(\"ChCh_ParryStatus\" in r) r.ChCh_ParryStatus()");
        AcceptEntityInput(runner, "RunScriptCode");
    }
    else
        PrintToServer(" ventanas abiertas   : (sin runner para preguntarle al .nut)");

    PrintToServer(" la ventana la abre  : LA HABILIDAD, llamada directa del manager al .nut");
    PrintToServer("                       (postura de Knuckles -> ChCh_KnxNotify / pose Z de Amy -> ChCh_AmyNotify)");
    PrintToServer(" el shove            : YA NO PARREA NI ABRE VENTANA (para nadie, desde la v2.5)");
    PrintToServer("=======================================================");
    return Plugin_Handled;
}

// helper del status: latido fresco (<= 5 s de vida)
bool Parry_BeatFresh(float beat)
{
    return (GetGameTime() - beat) <= 5.0;
}
