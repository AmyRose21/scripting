/**
 * l4d2_om_survivors.inc — API de OM Survivors v103 (Pet Fusion 4.36)
 *
 * El motor de campeones del pet aplicado a los SURVIVORS del equipo con
 * los PERSONAJES DEL SUITE: transforma los bots en el personaje que
 * ELIJAS (Sonic, Tails, Amy, Knuckles, Shadow, Metal, Rouge, Blaze,
 * Silver, Cream, Eggman), lo mantienen entre mapas (misma campana) y al
 * terminar la campana se borra todo.
 *
 * Incluye este archivo en cualquier plugin que quiera manejarlo
 * (el Sonic Ability Manager ya lo trae de serie desde v3.77.92):
 *
 *   #include <l4d2_om_survivors>
 *   ...
 *   L4D2OM_OpenMenu(client);                    // abre la GUI de asignacion
 *   L4D2OM_TransformSurvivor(bot, 2, client);   // bot -> Amy (0..10)
 *   int omChar = L4D2OM_GetSurvivorChar(bot);   // -1 = normal
 *
 * TODAS las natives son OPCIONALES: sin el plugin l4d2_om_survivors.smx
 * cargado, tu plugin no se rompe (usa GetFeatureStatus antes de llamar).
 */

#if defined _l4d2_om_survivors_included
 #endinput
#endif
#define _l4d2_om_survivors_included

/**
 * Abre la GUI de asignacion (survivor -> personaje OM).
 *
 * @param client   jugador que vera el menu
 * @return         true si se abrio
 */
native bool L4D2OM_OpenMenu(int client);

/**
 * Transforma UN bot superviviente en el personaje indicado y lo ASIGNA
 * (el survivor lo mantiene hasta el fin de la campana).
 *
 * @param survivor   indice del bot superviviente
 * @param omChar     personaje OM (0..10: Sonic, Tails, Amy, Knuckles,
 *                   Shadow, Metal, Rouge, Blaze, Silver, Cream, Eggman)
 * @param cmdr       quien manda / a quien acompana (0 = cualquiera)
 * @return           true si se transformo
 */
native bool L4D2OM_TransformSurvivor(int survivor, int omChar, int cmdr);

/**
 * Devuelve el bot a la normalidad y QUITA su asignacion de la campana.
 *
 * @param survivor   indice del bot superviviente
 * @return           true si habia algo que deshacer
 */
native bool L4D2OM_RevertSurvivor(int survivor);

/**
 * Que personaje OM ES ahora mismo este survivor.
 *
 * @param survivor   indice del bot superviviente
 * @return           el personaje (0..10) o -1 si esta normal
 */
native int L4D2OM_GetSurvivorChar(int survivor);

/**
 * Que personaje tiene ASIGNADO el SLOT para esta campana (sobrevive a que
 * el bot aun no haya nacido en el mapa: es la memoria entre mapas).
 *
 * @param survivorSlot   m_survivorCharacter del survivor (0..7:
 *                       Nick, Rochelle, Coach, Ellis, Bill, Zoey, Francis, Louis)
 * @return               el personaje (0..10) o -1 si sin asignar
 */
native int L4D2OM_GetAssignment(int survivorSlot);

/**
 * Cuantos personajes OM hay en el sistema (11).
 *
 * @return   cantidad de personajes
 */
native int L4D2OM_GetCharCount();

/**
 * Nombre del personaje OM ("Sonic", "Tails", "Amy", ..., "Eggman").
 *
 * @param omChar    personaje (0..10)
 * @param buf       buffer de salida
 * @param maxlen    tamano del buffer
 * @return          true si el personaje existe
 */
native bool L4D2OM_GetCharName(int omChar, char[] buf, int maxlen);

/**
 * Borra TODAS las asignaciones de la campana (los bots vuelven a la
 * normalidad). Es lo mismo que pasa solo al terminar la campana.
 *
 * @return   siempre true
 */
native bool L4D2OM_ClearCampaign();

/**
 * Un survivor se transformo en personaje OM.
 *
 * @param survivor   el bot que se transformo
 * @param omChar     el personaje que se puso (0..10)
 * @param replay     true si es una RE-APLICACION automatica al cambiar de
 *                   mapa (no una asignacion nueva del jugador)
 */
forward void L4D2OM_OnSurvivorTransformed(int survivor, int omChar, bool replay);

/**
 * Un survivor asignado volvio a la normalidad (le quitaron la asignacion).
 *
 * @param survivor   el bot devuelto
 * @param omChar     el personaje que llevaba (0..10)
 */
forward void L4D2OM_OnSurvivorReverted(int survivor, int omChar);

public SharedPlugin __pl_l4d2_om_survivors =
{
    name = "l4d2_om_survivors",
    file = "l4d2_om_survivors.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,   // v104: patron estandar del suite (Defib_Fix/PathSense):
                    // sin #undef REQUIRE_PLUGIN la dependencia es blanda y el
                    // core llama __pl_.._SetNTVOptional -> natives OPCIONALES
#endif
};

public void __pl_l4d2_om_survivors_SetNTVOptional()
{
    MarkNativeAsOptional("L4D2OM_OpenMenu");
    MarkNativeAsOptional("L4D2OM_TransformSurvivor");
    MarkNativeAsOptional("L4D2OM_RevertSurvivor");
    MarkNativeAsOptional("L4D2OM_GetSurvivorChar");
    MarkNativeAsOptional("L4D2OM_GetAssignment");
    MarkNativeAsOptional("L4D2OM_GetCharCount");
    MarkNativeAsOptional("L4D2OM_GetCharName");
    MarkNativeAsOptional("L4D2OM_ClearCampaign");
}
