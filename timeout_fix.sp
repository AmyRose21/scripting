#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

public Plugin myinfo = 
{
    name = "Timeout Fixer (Listen Server)",
    author = "Asistente",
    description = "Evita desconexiones por timeout en servidores locales",
    version = "1.0",
    url = ""
};

public void OnPluginStart()
{
    // Buscar el convar y forzar su valor
    ConVar cvTimeout = FindConVar("sv_timeout");
    if (cvTimeout != null)
    {
        cvTimeout.SetInt(9999);
        cvTimeout.AddChangeHook(OnCvarChanged); // Evitar que el juego lo cambie de nuevo
    }
    
    ConVar cvConnTimeout = FindConVar("sv_connect_timeout");
    if (cvConnTimeout != null)
    {
        cvConnTimeout.SetInt(9999);
    }
}

public void OnCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    // Si el juego intenta bajar el timeout, lo volvemos a subir a 9999
    if (StringToInt(newValue) < 9999)
    {
        convar.SetInt(9999);
    }
}

public void OnClientPutInServer(int client)
{
    // Cuando tu amigo entre al servidor, le enviaremos un comando para subir su cl_timeout
    if (!IsFakeClient(client))
    {
        // Esto fuerza al cliente a tener un timeout alto mientras esté en tu servidor
        SendConVarValue(client, FindConVar("sv_timeout"), "9999");
    }
}