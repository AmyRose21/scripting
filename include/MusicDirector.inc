// =====================================================================================
//  MusicDirector.inc — API PUBLICA DEL SISTEMA UNIFICADO DE MUSICA (v1.1)
// =====================================================================================
//  Para el futuro modo LMS (Last Man Standing) y cualquier otro plugin que
//  quiera musica por etapas de combate. El plugin l4d_MusicDirector.smx
//  expone estas natives + el forward MD_OnStageChanged (RegPluginLibrary
//  "MusicDirector").
//
//  ETAPAS DEFINIDAS (usa tus propios numeros si necesitas mas — el motor
//  solo entiende stage + prioridad):
//     MDST_NONE 0 | MDST_ROUNDSTART 1 | MDST_JOIN 2 | MDST_MENUMUSIC 3
//     MDST_CUSTOM 4 | MDST_TANK 5 | MDST_ESCAPE 6 | MDST_VICTORY 7
//     MDST_LMS 8 (Last Man Standing — v1.1)
//
//  PRIORIDADES DE FABRICA (v1.1):
//     MD_PRIO_JOIN 5 < ROUND 10 < MENU 20 < CUSTOM 30 < TANK 40
//     < ESCAPE 50 < LMS 55 < VICTORIA 60
//  El LMS queda POR ENCIMA del escape y POR DEBAJO de la victoria
//  (pedido del owner): el LMS reemplaza al escape; la victoria
//  reemplaza al LMS; nada suena encima del escape salvo LMS/victoria.
//
//  LOOP (v1.1): si tu etapa no trae duracion (0.0) y lleva cancion,
//  la cancion se REPITE SOLA mientras la etapa viva (el intervalo sale
//  del TAG- de las listas del director o de md_loop_fallback). Si le
//  pones duracion, la etapa cierra sola al agotarla (sin loop).
//
//  EJEMPLO LMS (cuando exista el modo):
//     #include <MusicDirector>
//     ...
//     // 1 superviviente vivo: etapa LMS con su musica, SIN duracion
//     // (loopea sola hasta que llames a MD_ClearStage o gane la partida)
//     MD_SetStage(MDST_LMS, MD_PRIO_LMS, 0.0, "mobius/musica/blink.mp3");
//     ...
//     MD_ClearStage(MDST_LMS);   // vuelve el audio normal (con fade)
// =====================================================================================

#if defined _MusicDirector_included
 #endinput
#endif
#define _MusicDirector_included

#define MDST_NONE        0
#define MDST_ROUNDSTART  1
#define MDST_JOIN        2
#define MDST_MENUMUSIC   3
#define MDST_CUSTOM      4    // API externa
#define MDST_TANK        5
#define MDST_ESCAPE      6
#define MDST_VICTORY     7
#define MDST_LMS         8    // v1.1: Last Man Standing (prio 55)

#define MD_PRIO_JOIN      5
#define MD_PRIO_ROUND    10
#define MD_PRIO_MENU     20
#define MD_PRIO_CUSTOM   30
#define MD_PRIO_TANK     40
#define MD_PRIO_ESCAPE   50
#define MD_PRIO_LMS      55   // v1.1: por encima del ESCAPE, debajo de VICTORIA
#define MD_PRIO_VICTORY  60

/**
 * Entra en una etapa de musica GLOBAL para todos los jugadores.
 *
 * @param stage      Id de la etapa (MDST_* o el tuyo propio).
 * @param priority   Prioridad — una etapa vigente con prioridad MAYOR
 *                   bloquea esta (tank no deja poner menu, etc.). Para el
 *                   LMS usa MD_PRIO_LMS (55): reemplaza al escape pero
 *                   nunca a la victoria.
 * @param duration   Segundos de la etapa (0 = sin limite: terminara con
 *                   MD_ClearStage o por un evento de juego; si lleva
 *                   cancion, esta LOOPEA sola — v1.1).
 * @param sound      Sonido a reproducir (ya precacheado por ti), o ""
 *                   para una etapa de SOLO-SILENCIO (apaga al juego).
 * @return           true si la etapa entro; false si habia una con mas
 *                   prioridad sonando.
 */
native bool MD_SetStage(int stage, int priority, float duration, const char[] sound = "");

/**
 * Termina la etapa indicada (con fade suave) SOLO si es la vigente.
 *
 * @param stage      La etapa a cerrar (MDST_*).
 * @return           true si se cerro; false si no era la vigente.
 */
native bool MD_ClearStage(int stage);

/**
 * La etapa GLOBAL vigente ahora mismo (MDST_NONE = nada).
 */
native int MD_GetStage();

/**
 * Se dispara en CADA cambio de etapa global (incluidas las internas del
 * director: tank, escape, arranque...). Ideal para que el LMS sepa que
 * su musica fue interrumpida por un tank... o reemplazada por el escape.
 *
 * @param oldStage   La etapa anterior.
 * @param newStage   La etapa nueva (MDST_NONE si se cerro).
 * @param priority   La prioridad de la etapa nueva.
 */
forward void MD_OnStageChanged(int oldStage, int newStage, int priority);

/**
 * LIBRERIA: haz public const char PluginName[] = "MusicDirector"; en tu
 * .sp para exigir que el director este cargado (SharedPlugin).
 */
public SharedPlugin __pl_MusicDirector =
{
    name = "MusicDirector",
    file = "l4d_MusicDirector.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

public void __pl_MusicDirector_SetNTVOptional()
{
    MarkNativeAsOptional("MD_SetStage");
    MarkNativeAsOptional("MD_ClearStage");
    MarkNativeAsOptional("MD_GetStage");
}
