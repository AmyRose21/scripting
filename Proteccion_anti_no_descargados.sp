#include <sourcemod>

public Plugin myinfo =
{
    name = "Download Filter Enforcer",
    author = "Ayudante",
    description = "Verifica si los jugadores permiten descargas",
    version = "1.0",
    url = ""
};

public void OnClientPostAdminCheck(int client)
{
    if (!IsFakeClient(client))
    {
        // Consultamos la configuración del jugador apenas entra
        QueryClientConVar(client, "cl_downloadfilter", ConVarCheck);
    }
}

public void ConVarCheck(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
    if (!IsClientInGame(client)) return;

    // "all" = Descarga todo (Correcto)
    // "nosounds" = No descarga música (Malo para tu server)
    // "none" = No descarga nada (Muy malo)
    // "mapsonly" = Solo mapas (Malo para tus skins/musica)

    if (!StrEqual(cvarValue, "all", false))
    {
        // AVISO EN EL CHAT PARA TI Y TODOS
        PrintToChatAll("\x04[AVISO]\x01 El jugador \x03%N\x01 tiene las descargas RESTRINGIDAS (%s).", client, cvarValue);
        PrintToChatAll("\x04[AVISO]\x01 No escuchará la música ni verá las skins.");

        // OPCIONAL: Si quieres expulsarlos hasta que lo arreglen, descomenta la linea de abajo:
        KickClient(client, "Por favor pon en consola: cl_downloadfilter all");
        
        // O mandarle un mensaje directo de advertencia
        PrintToChat(client, "\x03[IMPORTANTE]\x01 Tienes las descargas bloqueadas. Escribe \x04cl_downloadfilter all\x01 en tu consola para ver/oír todo.");
    }
    else
    {
        // Si todo está bien
        PrintToChat(client, "\x04[EXITO]\x01 Tu configuración de descarga es correcta. Deberías escuchar la música.");
    }
}