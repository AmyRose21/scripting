/**
 * l4d2_pet_christmas.inc — API del Pet Christmas Rework v2.0
 *
 * Incluye este archivo en cualquier plugin que quiera invocar el pet
 * desde su propio menu (por ejemplo, un "menu de mejoras" externo):
 *
 *   #include <l4d2_pet_christmas>
 *   ...
 *   L4D2Pet_Summon(client);      // invoca o recarga el pet del jugador
 *   L4D2Pet_Dismiss(client);     // lo despide
 *   if (L4D2Pet_IsActive(client)) ...
 */

#if defined _l4d2_pet_christmas_included
 #endinput
#endif
#define _l4d2_pet_christmas_included

/**
 * Invoca el pet del jugador (equivale al boton "Invocar Pet" del menu).
 * Si ya tiene pet, recarga su energia.
 *
 * @param client   indice del jugador superviviente
 * @return         true si se invoco o recargo
 */
native bool L4D2Pet_Summon(int client);

/**
 * Despide el pet del jugador.
 *
 * @param client   indice del jugador
 * @return         true si habia pet y se retiro
 */
native bool L4D2Pet_Dismiss(int client);

/**
 * Comprueba si el jugador tiene un pet activo.
 *
 * @param client   indice del jugador
 * @return         true si el pet esta vivo
 */
native bool L4D2Pet_IsActive(int client);

public SharedPlugin __pl_l4d2_pet_christmas =
{
    name = "l4d2_pet_christmas",
    file = "l4d2_pet_christmas.smx",
    info = "Pet Christmas Rework v2.0",
    version = "2.0.0"
};

public void __pl_l4d2_pet_christmas_SetNTVOptional()
{
    MarkNativeAsOptional("L4D2Pet_Summon");
    MarkNativeAsOptional("L4D2Pet_Dismiss");
    MarkNativeAsOptional("L4D2Pet_IsActive");
}
