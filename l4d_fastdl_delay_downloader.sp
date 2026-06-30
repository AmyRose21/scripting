/**
 * l4d2_blackscreen_fix - Versión con Notificaciones de Estado
 * v1.3 - Añadida detección de estado de descarga al entrar.
 */

#pragma semicolon 1
#pragma newdecls required
 
#include <sourcemod>
#include <sdktools>
#include <stringtables_data> 

#define CONFIG_FILE "data/l4d_fastdl_delay_downloader.cfg"

ArrayList g_aItems;
ArrayList g_sRestricted;
int g_iItemsTotal = 0;
bool g_bDownloadsDeleted = false; // Nueva variable para saber el estado actual

ConVar g_cvEnable;
ConVar g_cvLog;
ConVar g_cvNotifyJoin; // Nueva CVar para avisar en chat

public Plugin myinfo =
{
    name = "[L4D & L4D2] Black Screen Fix (Notifier)",
    author = "BHaType, Dragokas, Harry, Improved by Assistant",
    description = "Descarga archivos solo al inicio y notifica estado",
    version = "1.3-2025",
    url = "https://forums.alliedmods.net/showthread.php?t=318739"
};

public void OnPluginStart()
{
    g_cvEnable = CreateConVar("l4d_bs_fix_enable", "1", "Activar o desactivar el plugin", FCVAR_NOTIFY);
    g_cvLog = CreateConVar("l4d_bs_fix_log", "1", "1 = Logs en consola del servidor", FCVAR_NOTIFY);
    g_cvNotifyJoin = CreateConVar("l4d_bs_fix_notify_join", "1", "1 = Avisar en chat si el jugador descargó archivos o no", FCVAR_NOTIFY);
    
    AutoExecConfig(true, "l4d_blackscreen_fix");

    RegAdminCmd("sm_get_exclude_items", CMD_GetStringRestricted, ADMFLAG_ROOT, "Muestra lista de exclusión");
    RegAdminCmd("sm_restore_st", CMD_RestoreDownloadables, ADMFLAG_ROOT, "Restaura manualmente la tabla");
    
    HookEvent("map_transition", Event_RestoreDownloads, EventHookMode_Pre);
    AddCommandListener(ServerCmd_changelevel, "changelevel");

    g_aItems = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
    g_sRestricted = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

    CheckConfig();
}

public void OnMapStart()
{
    g_iItemsTotal = 0;
    g_bDownloadsDeleted = false; // Al inicio del mapa, las descargas están ACTIVAS
    
    ReadRestrictedFiles();

    if(g_cvEnable.BoolValue)
    {
        CreateTimer(30.0, Timer_SaveDownloadables, _, TIMER_FLAG_NO_MAPCHANGE);
    }
}

// -------------------------------------------------------------------------
// Notificación al entrar el jugador
// -------------------------------------------------------------------------

public void OnClientPostAdminCheck(int client)
{
    if (IsFakeClient(client)) return;

    // Solo notificamos si el admin lo quiere
    if (g_cvNotifyJoin.BoolValue)
    {
        if (!g_bDownloadsDeleted)
        {
            // El jugador entró antes de los 30 segundos
            PrintToChatAll("\x04[BS FIX]\x01 Jugador \x03%N\x01 se unió a tiempo. \x05(Archivos Descargados/Verificados)", client);
        }
        else
        {
            // El jugador entró después de que borramos la lista
            PrintToChatAll("\x04[BS FIX]\x01 Jugador \x03%N\x01 se unió tarde. \x05(Descarga OMITIDA para evitar pantalla negra)", client);
        }
    }
}

// -------------------------------------------------------------------------
// Lógica de Guardado y Limpieza
// -------------------------------------------------------------------------

Action Timer_SaveDownloadables(Handle timer)
{
    SaveAndClearDownloadables();
    return Plugin_Continue;
}

void SaveAndClearDownloadables()
{
    int iTable = FindStringTable("downloadables");
    if(iTable == INVALID_STRING_TABLE) return;
    
    g_aItems.Clear();
    int iNum = GetStringTableNumStrings(iTable);
    char sItems[PLATFORM_MAX_PATH];

    for (int i = 0; i < iNum; i++)
    {
        ReadStringTable(iTable, i, sItems, sizeof(sItems));
        if(g_sRestricted.FindString(sItems) >= 0) continue;
        g_aItems.PushString(sItems);
    }
    
    g_iItemsTotal = g_aItems.Length;

    INetworkStringTable table = INetworkStringTable(iTable);
    table.DeleteStrings();
    
    // Marcamos que las descargas han sido eliminadas
    g_bDownloadsDeleted = true;
    
    if(g_cvLog.BoolValue)
        PrintToServer("[BS FIX] Tiempo de descarga finalizado. %d archivos ocultos.", g_iItemsTotal);
}

// -------------------------------------------------------------------------
// Lógica de Restauración
// -------------------------------------------------------------------------

void Event_RestoreDownloads(Event event, const char[] name, bool dontBroadcast)
{
    RestoreDownloadables();
}

Action ServerCmd_changelevel(int client, const char[] command, int argc)
{
    RestoreDownloadables();
    return Plugin_Continue;
}

Action CMD_RestoreDownloadables(int client, int args)
{
    if (RestoreDownloadables()) ReplyToCommand(client, "[BS FIX] Tabla restaurada.");
    else ReplyToCommand(client, "[BS FIX] Nada que restaurar.");
    return Plugin_Handled;
}

bool RestoreDownloadables()
{
    if (!g_cvEnable.BoolValue || g_iItemsTotal == 0) return false;

    int length = g_aItems.Length;
    if (length == 0) return false;

    char sItems[PLATFORM_MAX_PATH];
    for (int i = 0; i < length; i++)
    {
        g_aItems.GetString(i, sItems, sizeof(sItems));
        if (sItems[0] != '\0') AddFileToDownloadsTable(sItems);
    }
    
    g_aItems.Clear();
    g_iItemsTotal = 0;
    g_bDownloadsDeleted = false; // Restauramos el estado

    if(g_cvLog.BoolValue) PrintToServer("[BS FIX] Archivos restaurados para cambio de mapa.");
    return true;
}

// -------------------------------------------------------------------------
// Configuración
// -------------------------------------------------------------------------

void CheckConfig()
{
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), CONFIG_FILE);

    if (!FileExists(sPath))
    {
        File hFile = OpenFile(sPath, "w");
        if (hFile != null)
        {
            hFile.WriteLine("// Lista de archivos que NO deben ser eliminados.");
            delete hFile;
        }
    }
}

int ReadRestrictedFiles()
{
    g_sRestricted.Clear();
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), CONFIG_FILE);
    
    if (FileExists(sPath))
    {
        int index = 0;
        char szBuffer[PLATFORM_MAX_PATH];
        File hFile = OpenFile(sPath, "r");
        while (ReadFileLine(hFile, szBuffer, sizeof(szBuffer)))
        {
            TrimString(szBuffer);
            if(szBuffer[0] == '\0' || (szBuffer[0] == '/' && szBuffer[1] == '/')) continue;
            g_sRestricted.PushString(szBuffer);
            index++;
        }
        delete hFile;
        return index;
    }
    return 0;
}

Action CMD_GetStringRestricted(int client, int args)
{
    int total = g_sRestricted.Length;
    char sRestricted[PLATFORM_MAX_PATH];
    for (int i = 0; i < total; i++)
    {
        g_sRestricted.GetString(i, sRestricted, sizeof(sRestricted));
        ReplyToCommand(client, "%d. %s", i + 1, sRestricted);
    }
    return Plugin_Handled;
}