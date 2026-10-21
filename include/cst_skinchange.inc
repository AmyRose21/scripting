/*
 * ============================================================================
 *  cst_skinchange.inc — API del puente/guardia CST para tus otros plugins
 * ============================================================================
 *  Requiere: cst_skinchange.smx compilado y cargado en el servidor.
 *
 *  Ejemplo de uso (tu sistema de seleccion de personaje):
 *
 *    #include <cst_skinchange>
 *
 *    // OPCION A — aplicacion directa: cuando tu menu elige "amy":
 *    CST_ApplyProfile(client, "amy.cfg");
 *
 *    // OPCION B — dejar que la guardia lo detecte sola: cuando tu selector
 *    // (SCS o el que sea) deja al jugador en coach/ellis/rochelle, el CST lo
 *    // toma solo (watchdog cada 0.5s). Forzar el check cuando quieras:
 *    CST_GuardCheck(client);
 *
 *    // Preguntar que perfil tiene asignado:
 *    char cfg[64];
 *    if (CST_GetProfile(client, cfg, sizeof(cfg))) { ... }
 *
 *    // Enterarse cuando el CST aplico (tambien dispara para bots):
 *    public void CST_OnProfileApplied(int client, const char[] cfg) { ... }
 */

#if defined _cst_skinchange_included
#endinput
#endif
#define _cst_skinchange_included

/**
 * Aplica YA un perfil CST al jugador (modelo + voz + nombre de bot + slot).
 * La guardia verifica 1.2s despues y reintenta sola si algo fallo.
 *
 * @param client   jugador (debe estar en el equipo superviviente)
 * @param profile  cfg del perfil, ej. "amy.cfg", "sonic.cfg", "rouge_r.cfg"
 * @return         true si se lanzo la aplicacion
 */
native bool CST_ApplyProfile(int client, const char[] profile);

/**
 * Devuelve el perfil CST asignado al jugador por la guardia.
 *
 * @return  true si hay perfil asignado (buffer lleno), false si ninguno.
 */
native bool CST_GetProfile(int client, char[] buffer, int maxlen);

/**
 * Fuerza una pasada del check de la guardia para ese jugador (diferida 0.1s).
 * Es el "check": lee el modelo actual y aplica el cfg mapeado si hace falta.
 */
native void CST_GuardCheck(int client);

/**
 * Forward: el CST aplico y verifico el perfil de un jugador.
 *
 * @param client  jugador al que se aplico (humano o bot)
 * @param cfg     perfil aplicado, ej. "rouge_r.cfg"
 */
forward void CST_OnProfileApplied(int client, const char[] cfg);

public SharedPlugin __pl_cst_skinchange =
{
    name = "cst_skinchange",
    file = "cst_skinchange.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_cst_skinchange_SetNTVOptional()
{
    MarkNativeAsOptional("CST_ApplyProfile");
    MarkNativeAsOptional("CST_GetProfile");
    MarkNativeAsOptional("CST_GuardCheck");
}
#endif
