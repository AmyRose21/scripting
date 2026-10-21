/*
 ============================================================================
 FileNet Downloads — Descarga silenciosa de efectos de sonido y recursos
 ============================================================================
 Compañero del plugin "File Network" (Batfoxkid/Artvin).

 v1.0.1 (17-oct-2026) — FIX "send reliable stream overflow":
   El host del listen server (127.0.0.1 / loopback) ya tiene todos los
   archivos en su propia carpeta del juego. Ahora se le saltan TODOS los
   envios (antes el FileNet le bombeaba los archivos por el canal
   confiable y el motor tiraba "send reliable stream overflow" en bucle).

 ESTE PLUGIN ES EL AJUSTE PEDIDO:
   - SOLO se descarga lo listado en sound_mapstart.txt (efectos de sonido,
     y en el futuro particulas/materiales/modelos sueltos).
   - Las MUSICAS PERMANENTES NO van aqui: esas se distribuyen por VPK
     (permite actualizarlas, evita el problema de recache de los WAV y
     el cache que no se sube por red).
   - El VPK solo es para cambios grandes; un archivo suelto de efecto
     de sonido no justifica subir un VPK completo.

 Como funciona:
   - Lee las listas (por defecto "sound_mapstart.txt").
   - Precachea los sonidos listados para que EmitSound funcione.
   - Cuando un jugador entra (ya dentro del juego, sin pantalla de carga),
     envia los archivos uno por uno con FileNet_SendFile().
   - Recuerda por jugador la "version" de la lista que ya tiene (cookie).
     Si actualizas un sonido y la lista cambia de version, ese jugador
     vuelve a recibir todo. Eso corrige el problema clasico de las
     descargas de L4D2 (archivos viejos que nunca se actualizan).

 Listas leidas (se acumulan y se deduplican):
   1) addons/sourcemod/configs/sound_mapstart.txt
   2) sound_mapstart.txt (raiz del juego, left4dead2/)
   3) addons/sourcemod/configs/filenet/  (todos los .txt que metais ahi; para el futuro:
      particles_mapstart.txt, materials_mapstart.txt, etc.)
   4) sm_filenet_extra_lists "ruta1;ruta2"    (rutas extra)

 Formato del txt (tolerante):
   - Una ruta por linea, relativa a la carpeta del juego:
       sound/zelda/sfx/hyrule.wav
       particles/mishabilidades.pcf
   - Comentarios con // # o ;
   - Se aceptan comillas (formato KeyValues):  "sound/x.wav" "1"
   - Si una linea no empieza con una carpeta conocida (sound/, materials/,
     particles/, models/, scripts/, resource/, media/, maps/) se deduce
     por extension: wav/mp3/ogg -> sound/ | vmt/vtf -> materials/ |
     pcf -> particles/ | mdl/vvd/phy/vtx... -> models/
 ============================================================================
*/

#include <sourcemod>
#include <clientprefs>
#include <filenetwork>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION      "1.0.1"

#define FN_ROOT_COUNT       8

public Plugin myinfo =
{
        name            =       "FileNet Downloads",
        author          =       "Super Z",
        description     =       "Descarga silenciosa (sin pantalla de carga) de SFX y recursos listados en sound_mapstart.txt, via File-Network",
        version         =       PLUGIN_VERSION,
        url             =       "github.com/Batfoxkid/File-Network"
};

/* ---------- ConVars ---------- */

ConVar g_cvEnabled;
ConVar g_cvDelay;
ConVar g_cvMode;
ConVar g_cvPrecache;
ConVar g_cvPrecacheParticles;
ConVar g_cvExtraLists;
ConVar g_cvDebug;
ConVar g_cvMaxFileSize;

/* ---------- Datos de listas ---------- */

ArrayList g_Files;                  // rutas finales (minusculas, con carpeta raiz)
ArrayList g_Sizes;                  // tamano en bytes; -1 = no encontrada en el servidor

int g_iVersion;                     // hash FNV-1a de (ruta + tamano) de todo el listado
int g_iListSources;                 // cuantas listas se leyeron
int g_iMissingCount;                // archivos listados que no existen en el servidor

/* ---------- Estado por cliente ---------- */

bool  g_bSyncing[MAXPLAYERS+1];       // hay envios en curso
bool  g_bSessionSynced[MAXPLAYERS+1]; // ya sincronizado en esta conexion
bool  g_bPendingCookie[MAXPLAYERS+1]; // esperando a que las cookies se cacheen
bool  g_bForce[MAXPLAYERS+1];         // resync forzado (administrador)
int   g_iTotal[MAXPLAYERS+1];
int   g_iDone[MAXPLAYERS+1];
int   g_iFailed[MAXPLAYERS+1];
int   g_iSyncVersion[MAXPLAYERS+1];   // version del listado que se esta enviando

Handle g_hDelayTimer[MAXPLAYERS+1];
Handle g_hCookieTimer[MAXPLAYERS+1];

/* ---------- Cookie de version ---------- */

Cookie g_hVersionCookie;

/* ========================================================================
        Carga del plugin
   ======================================================================== */

public void OnPluginStart()
{
        LoadTranslations("common.phrases");

        g_cvEnabled           = CreateConVar("sm_filenet_enabled",             "1",    "1 = enviar los archivos listados a los clientes. 0 = desactivado.", _, true, 0.0, true, 1.0);
        g_cvDelay             = CreateConVar("sm_filenet_delay",               "5.0",  "Segundos tras entrar al servidor antes de empezar a enviar archivos.", _, true, 1.0, true, 60.0);
        g_cvMode              = CreateConVar("sm_filenet_mode",                "1",    "0 = una vez por conexion (reconectar = reenviar). 1 = recordar por jugador la version del listado (recomendado: solo reenvia cuando actualices un archivo). 2 = reenviar siempre (debug).", _, true, 0.0, true, 2.0);
        g_cvPrecache          = CreateConVar("sm_filenet_precache",            "1",    "1 = precachear los sonidos listados (necesario para que suenen).", _, true, 0.0, true, 1.0);
        g_cvPrecacheParticles = CreateConVar("sm_filenet_precache_particles",  "0",    "1 = PrecacheGeneric de los .pcf listados. Solo activalo cuando de verdad uses particulas custom registradas por el servidor (ver LEEME).", _, true, 0.0, true, 1.0);
        g_cvExtraLists        = CreateConVar("sm_filenet_extra_lists",         "",     "Listas adicionales separadas por ; (ruta relativa a la carpeta del juego o a addons/sourcemod/).");
        g_cvDebug             = CreateConVar("sm_filenet_debug",               "0",    "1 = registro detallado en consola.", _, true, 0.0, true, 1.0);
        g_cvMaxFileSize       = CreateConVar("sm_filenet_maxsize",             "32",   "MB minimos que se aseguran en net_maxfilesize (limite del motor para enviar archivos).", _, true, 1.0, true, 64.0);

        g_cvExtraLists.AddChangeHook(OnListCvarChanged);
        g_cvMode.AddChangeHook(OnListCvarChanged);

        g_hVersionCookie = new Cookie("filenet_dl_version", "FileNet Downloads: version del listado sincronizado", CookieAccess_Protected);

        RegAdminCmd("sm_filenet_status", Command_Status,    ADMFLAG_GENERIC,  "Estado del sistema de descargas FileNet");
        RegAdminCmd("sm_filenet_list",   Command_List,      ADMFLAG_GENERIC,  "Muestra los archivos listados en sound_mapstart.txt y compania");
        RegAdminCmd("sm_filenet_reload", Command_Reload,    ADMFLAG_CONFIG,   "Recarga las listas y resincroniza a los jugadores conectados");
        RegAdminCmd("sm_filenet_resync", Command_Resync,    ADMFLAG_CONFIG,   "Fuerza el reenvio completo: sm_filenet_resync <jugador|all>");

        g_Files = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
        g_Sizes = new ArrayList();

        AutoExecConfig(true, "plugin.filenetwork_downloads");

        // Carga tardia (plugin cargado con mapa en marcha)
        if (IsServerProcessing())
        {
                LoadLists();
                PrecacheListed();

                for (int i = 1; i <= MaxClients; i++)
                {
                        if (IsClientInGame(i) && !IsFakeClient(i))
                        {
                                delete g_hDelayTimer[i];
                                g_hDelayTimer[i] = CreateTimer(g_cvDelay.FloatValue, Timer_ClientSync, GetClientUserId(i));
                        }
                }
        }
}

public void OnConfigsExecuted()
{
        // El motor limita el envio de archivos por red con net_maxfilesize (MB).
        ConVar netMax = FindConVar("net_maxfilesize");
        if (netMax != null && netMax.IntValue < g_cvMaxFileSize.IntValue)
        {
                netMax.SetInt(g_cvMaxFileSize.IntValue);
                LogMessage("[FileNet] net_maxfilesize ajustado a %d MB para permitir envios grandes.", g_cvMaxFileSize.IntValue);
        }
}

public void OnLibraryAdded(const char[] name)
{
        if (StrEqual(name, "filenetwork"))
                LogMessage("[FileNet] Libreria File-Network disponible de nuevo.");
}

public void OnLibraryRemoved(const char[] name)
{
        if (StrEqual(name, "filenetwork"))
                LogError("[FileNet] ¡La libreria File-Network (filenetwork.smx) se descargo! No se pueden enviar archivos hasta que vuelva.");
}

/* ========================================================================
        Lectura de listas (sound_mapstart.txt y compania)
   ======================================================================== */

public void OnMapStart()
{
        LoadLists();
        PrecacheListed();

        // Red de seguridad: revisa a los jugadores ya conectados al cambiar de mapa.
        CreateTimer(8.0, Timer_MapSyncCheck);
}

public Action Timer_MapSyncCheck(Handle timer)
{
        for (int i = 1; i <= MaxClients; i++)
        {
                if (IsClientInGame(i) && !IsFakeClient(i))
                        SyncClient(i);
        }
        return Plugin_Stop;
}

void LoadLists()
{
        g_Files.Clear();
        g_Sizes.Clear();
        g_iListSources = 0;
        g_iMissingCount = 0;

        char buffer[PLATFORM_MAX_PATH];

        // 1) addons/sourcemod/configs/sound_mapstart.txt
        BuildPath(Path_SM, buffer, sizeof(buffer), "configs/sound_mapstart.txt");
        LoadOneList(buffer, "configs/sound_mapstart.txt");

        // 2) sound_mapstart.txt en la raiz del juego (left4dead2/), via search path
        if (FileExists("sound_mapstart.txt", true, "GAME"))
                LoadOneListValve("sound_mapstart.txt", "raiz del juego");

        // 3) addons/sourcemod/configs/filenet/*.txt
        BuildPath(Path_SM, buffer, sizeof(buffer), "configs/filenet");
        if (DirExists(buffer))
        {
                DirectoryListing dir = OpenDirectory(buffer);
                if (dir != null)
                {
                        char entry[PLATFORM_MAX_PATH];
                        FileType type;
                        while (dir.GetNext(entry, sizeof(entry), type))
                        {
                                if (type != FileType_File)
                                        continue;

                                int len = strlen(entry);
                                if (len < 5)
                                        continue;

                                // solo .txt
                                if (!StrEqual(entry[len-4], ".txt"))
                                        continue;

                                if (entry[0] == '.' || StrContains(entry, "readme", false) != -1)
                                        continue;

                                char full[PLATFORM_MAX_PATH];
                                Format(full, sizeof(full), "%s/%s", buffer, entry);
                                LoadOneList(full, entry);
                        }
                        delete dir;
                }
        }

        // 4) Listas extra del convar sm_filenet_extra_lists
        char extras[512];
        g_cvExtraLists.GetString(extras, sizeof(extras));
        if (extras[0])
        {
                char piece[PLATFORM_MAX_PATH];
                int pos = 0;
                while (extras[pos] != '\0')
                {
                        int idx = StrContains(extras[pos], ";");
                        if (idx == -1)
                        {
                                strcopy(piece, sizeof(piece), extras[pos]);
                                pos = strlen(extras);
                        }
                        else
                        {
                                strcopy(piece, sizeof(piece), extras[pos]);
                                piece[idx] = '\0';
                                pos += idx + 1;
                        }

                        TrimString(piece);
                        if (piece[0])
                                LoadExtraList(piece);
                }
        }

        ComputeVersion();

        LogMessage("[FileNet] Listas cargadas: %d archivo(s) desde %d lista(s). Version del listado: %d.", g_Files.Length, g_iListSources, g_iVersion);
        if (g_iMissingCount > 0)
                LogError("[FileNet] ¡OJO! %d archivo(s) de la lista NO existen en el servidor. Usa sm_filenet_list para verlos.", g_iMissingCount);
}

void LoadExtraList(const char[] piece)
{
        // Ruta absoluta, relativa al juego (search path) o relativa a addons/sourcemod/
        if (FileExists(piece))
        {
                LoadOneList(piece, piece);
                return;
        }

        if (FileExists(piece, true, "GAME"))
        {
                LoadOneListValve(piece, piece);
                return;
        }

        char buffer[PLATFORM_MAX_PATH];
        BuildPath(Path_SM, buffer, sizeof(buffer), piece);
        if (FileExists(buffer))
                LoadOneList(buffer, piece);
        else
                LogError("[FileNet] Lista extra no encontrada: \"%s\"", piece);
}

void LoadOneList(const char[] path, const char[] displayName)
{
        File file = OpenFile(path, "r");
        if (file == null)
        {
                LogError("[FileNet] No se pudo abrir la lista \"%s\".", displayName);
                return;
        }

        ParseListFile(file, displayName);
        delete file;
}

void LoadOneListValve(const char[] path, const char[] displayName)
{
        File file = OpenFile(path, "r", true, "GAME");
        if (file == null)
        {
                LogError("[FileNet] No se pudo abrir la lista \"%s\" (via GAME).", displayName);
                return;
        }

        ParseListFile(file, displayName);
        delete file;
}

void ParseListFile(File file, const char[] displayName)
{
        char line[PLATFORM_MAX_PATH];
        int added = 0;
        while (file.ReadLine(line, sizeof(line)))
        {
                if (ParseListLine(line) && AddEntry(line))
                        added++;
        }

        g_iListSources++;
        if (g_cvDebug.BoolValue)
                PrintToServer("[FileNet]   %-40s -> %d archivo(s)", displayName, added);
}

/**
 * Limpia una linea del txt de descargas.
 * Devuelve true si queda una ruta valida en "line".
 * Soporta: comentarios (// # ;), lineas vacias, comillas tipo KeyValues,
 * comentarios al final de la linea y BOM.
 */
bool ParseListLine(char[] line)
{
        // Quitar BOM
        if (line[0] == '\xEF' && line[1] == '\xBB' && line[2] == '\xBF')
                strcopy(line, PLATFORM_MAX_PATH, line[3]);

        ReplaceString(line, PLATFORM_MAX_PATH, "\r", "");
        ReplaceString(line, PLATFORM_MAX_PATH, "\t", " ");
        TrimString(line);

        if (line[0] == '\0')
                return false;

        // Linea completa comentada
        if (line[0] == '/' && line[1] == '/')
                return false;
        if (line[0] == '#' || line[0] == ';')
                return false;

        // Corchetes de KeyValues: seccion, ignorar
        if (line[0] == '{' || line[0] == '}')
                return false;

        // Comentario al final de la linea
        int cut = StrContains(line, "//");
        if (cut > 0)
                line[cut] = '\0';

        // Si hay comillas, extraer tokens con formato de ruta (soporta KeyValues)
        if (StrContains(line, "\"") != -1)
        {
                char tokens[2][PLATFORM_MAX_PATH];
                int count = 0;

                char cursor[PLATFORM_MAX_PATH];
                strcopy(cursor, sizeof(cursor), line);

                while (count < 2)
                {
                        int open = FindCharInString(cursor, '"');
                        if (open == -1)
                                break;

                        int close = FindCharInString(cursor[open+1], '"');
                        if (close == -1)
                                break;

                        strcopy(tokens[count], PLATFORM_MAX_PATH, cursor[open+1]);
                        tokens[count][close] = '\0';
                        count++;

                        int next = open + 1 + close + 1;
                        if (next >= strlen(cursor))
                                break;

                        strcopy(cursor, sizeof(cursor), cursor[next]);
                }

                // El primer token que parezca una ruta es la entrada.
                // Cubre: "sound/a.wav" "1"   y   "sound/a.wav"  ""
                bool found = false;
                for (int i = 0; i < count; i++)
                {
                        TrimString(tokens[i]);
                        if (tokens[i][0] != '\0' && LooksLikePath(tokens[i]))
                        {
                                strcopy(line, PLATFORM_MAX_PATH, tokens[i]);
                                found = true;
                                break;
                        }
                }

                if (!found)
                        return false;
        }

        TrimString(line);
        return line[0] != '\0';
}

/**
 * Añade una ruta al listado (deduplica, deduce carpeta raiz, valida).
 */
bool AddEntry(char[] path)
{
        // Normalizar
        ReplaceString(path, PLATFORM_MAX_PATH, "\\", "/");
        String_ToLower(path);

        // Quitar ./ inicial
        if (StrContains(path, "./") == 0)
                strcopy(path, PLATFORM_MAX_PATH, path[2]);

        // Rutas con ".." o que apunten a la carpeta download del servidor: fuera
        if (StrContains(path, "..") != -1 || StrContains(path, "download/") == 0)
                return false;

        TrimString(path);
        int len = strlen(path);
        if (len < 4 || len > 240)
                return false;

        // ¿Ya tiene carpeta raiz conocida? Si no, deducirla por extension
        if (!HasKnownRoot(path))
                SmartPrefix(path, PLATFORM_MAX_PATH);

        // Deduplicar
        if (g_Files.FindString(path) != -1)
                return false;

        // ¿Existe en el servidor?
        int size = FileSize(path, true, "GAME");
        if (size < 0)
        {
                g_iMissingCount++;
                LogError("[FileNet] Listado pero NO encontrado en el servidor: \"%s\" (no se enviara).", path);
        }
        else if (StrContains(path, " ") != -1)
        {
                LogError("[FileNet] \"%s\" contiene ESPACIOS. Renombralo con guiones bajos: los espacios rompen las descargas de Source.", path);
        }

        g_Files.PushString(path);
        g_Sizes.Push(size);
        return true;
}

bool HasKnownRoot(const char[] path)
{
        static const char roots[FN_ROOT_COUNT][] =
        {
                "sound/", "materials/", "particles/", "models/",
                "scripts/", "resource/", "media/", "maps/"
        };

        for (int i = 0; i < FN_ROOT_COUNT; i++)
        {
                if (StrContains(path, roots[i]) == 0)
                        return true;
        }
        return false;
}

/**
 * Deduce la carpeta del juego por la extension:
 * wav/mp3/ogg -> sound/ | vmt/vtf -> materials/ | pcf -> particles/ |
 * mdl/vvd/phy/vtx/ani/lip -> models/
 */
void SmartPrefix(char[] path, int maxlen)
{
        int dot = FindCharInString(path, '.', true);
        if (dot == -1)
                return;

        char ext[16];
        strcopy(ext, sizeof(ext), path[dot+1]);

        char prefixed[PLATFORM_MAX_PATH];
        if (StrEqual(ext, "wav") || StrEqual(ext, "mp3") || StrEqual(ext, "ogg"))
                Format(prefixed, sizeof(prefixed), "sound/%s", path);
        else if (StrEqual(ext, "vmt") || StrEqual(ext, "vtf"))
                Format(prefixed, sizeof(prefixed), "materials/%s", path);
        else if (StrEqual(ext, "pcf"))
                Format(prefixed, sizeof(prefixed), "particles/%s", path);
        else if (StrEqual(ext, "mdl") || StrEqual(ext, "vvd") || StrEqual(ext, "phy")
                || StrEqual(ext, "vtx") || StrEqual(ext, "ani") || StrEqual(ext, "lip"))
                Format(prefixed, sizeof(prefixed), "models/%s", path);
        else
                return; // extension desconocida: dejar tal cual (se avisara si falta)

        strcopy(path, maxlen, prefixed);
}

bool LooksLikePath(const char[] text)
{
        if (StrContains(text, "/") != -1)
                return true;

        int dot = FindCharInString(text, '.', true);
        if (dot == -1)
                return false;

        char ext[16];
        strcopy(ext, sizeof(ext), text[dot+1]);
        return StrEqual(ext, "wav") || StrEqual(ext, "mp3") || StrEqual(ext, "ogg")
                || StrEqual(ext, "vmt") || StrEqual(ext, "vtf") || StrEqual(ext, "pcf")
                || StrEqual(ext, "mdl") || StrEqual(ext, "vvd") || StrEqual(ext, "phy")
                || StrEqual(ext, "vtx");
}

/** FNV-1a de 32 bits sobre cada "ruta|tamano" — cambia si actualizas un archivo. */
void ComputeVersion()
{
        int version = 2166136261;

        char path[PLATFORM_MAX_PATH];
        for (int i = 0; i < g_Files.Length; i++)
        {
                g_Files.GetString(i, path, sizeof(path));
                int size = g_Sizes.Get(i);

                for (int c = 0; path[c] != '\0'; c++)
                        version = (version ^ view_as<int>(path[c])) * 16777619;

                version = (version ^ size) * 16777619;
                version = (version ^ i) * 16777619;
        }

        g_iVersion = version;
}

void String_ToLower(char[] text)
{
        int len = strlen(text);
        for (int i = 0; i < len; i++)
        {
                if (text[i] >= 'A' && text[i] <= 'Z')
                        text[i] = view_as<char>(text[i] + 32);
        }
}

/* ========================================================================
        Precache (para que los sonidos realmente suenen)
   ======================================================================== */

void PrecacheListed()
{
        if (!g_cvPrecache.BoolValue)
                return;

        char path[PLATFORM_MAX_PATH];
        int sounds = 0, particles = 0;

        for (int i = 0; i < g_Files.Length; i++)
        {
                g_Files.GetString(i, path, sizeof(path));

                int dot = FindCharInString(path, '.', true);
                if (dot == -1)
                        continue;

                char ext[16];
                strcopy(ext, sizeof(ext), path[dot+1]);

                if (StrEqual(ext, "wav") || StrEqual(ext, "mp3") || StrEqual(ext, "ogg"))
                {
                        // PrecacheSound usa la ruta SIN el prefijo sound/
                        char rel[PLATFORM_MAX_PATH];
                        if (StrContains(path, "sound/") == 0)
                                strcopy(rel, sizeof(rel), path[6]);
                        else
                                strcopy(rel, sizeof(rel), path);

                        if (!PrecacheSound(rel, true) && g_Sizes.Get(i) >= 0)
                                LogError("[FileNet] PrecacheSound fallo: \"%s\"", rel);
                        else
                                sounds++;
                }
                else if (StrEqual(ext, "pcf") && g_cvPrecacheParticles.BoolValue)
                {
                        if (!PrecacheGeneric(path, true))
                                LogError("[FileNet] PrecacheGeneric fallo: \"%s\"", path);
                        else
                                particles++;
                }
        }

        if (sounds || particles)
                LogMessage("[FileNet] Precacheado: %d sonido(s)%s", sounds, particles ? " y particulas custom registradas" : "");
}

/* ========================================================================
        Sincronizacion por cliente
   ======================================================================== */

public void OnClientPutInServer(int client)
{
        if (IsFakeClient(client))
                return;

        g_bSyncing[client] = false;
        g_bSessionSynced[client] = false;
        g_bPendingCookie[client] = false;
        g_bForce[client] = false;
        g_iTotal[client] = 0;
        g_iDone[client] = 0;
        g_iFailed[client] = 0;

        if (!g_cvEnabled.BoolValue)
                return;

        delete g_hDelayTimer[client];
        g_hDelayTimer[client] = CreateTimer(g_cvDelay.FloatValue, Timer_ClientSync, GetClientUserId(client));
}

public Action Timer_ClientSync(Handle timer, int userid)
{
        int client = GetClientOfUserId(userid);
        if (client > 0)
        {
                g_hDelayTimer[client] = null;
                SyncClient(client);
        }
        return Plugin_Stop;
}

public void OnClientCookiesCached(int client)
{
        if (g_bPendingCookie[client])
        {
                g_bPendingCookie[client] = false;
                delete g_hCookieTimer[client];
                SyncClient(client);
        }
}

public void OnClientDisconnect(int client)
{
        delete g_hDelayTimer[client];
        delete g_hCookieTimer[client];

        g_bSyncing[client] = false;
        g_bSessionSynced[client] = false;
        g_bPendingCookie[client] = false;
        g_bForce[client] = false;
        g_iTotal[client] = 0;
        g_iDone[client] = 0;
        g_iFailed[client] = 0;
}

/**
 * Decide si hay que enviarle el listado a un cliente y lo encola.
 */
void SyncClient(int client)
{
        if (!g_cvEnabled.BoolValue)
                return;

        if (g_bSyncing[client])
                return;

        if (!IsClientInGame(client) || IsFakeClient(client))
                return;

        // ----------------------------------------------------------------------
        // v1.0.1 FIX "send reliable stream overflow":
        // En un LISTEN SERVER el host juega desde 127.0.0.1 ("loopback") y su
        // carpeta del juego ES la carpeta del server: ya tiene TODOS los
        // archivos en disco. Enviarle bytes con INetChannel::SendFile es
        // trabajo inutil que satura el canal confiable, y el motor escupe
        // "127.0.0.1:27015: send reliable stream overflow" en bucle.
        // El host se salta la sincronizacion SIEMPRE (tambien en resync
        // forzado de admin: no hay nada que sincronizar por red).
        // ----------------------------------------------------------------------
        char ip[24];
        if (GetClientIP(client, ip, sizeof(ip))
            && (ip[0] == 'l'                       // "loopback" (listen server host)
                || strncmp(ip, "127.", 4) == 0     // 127.x.x.x
                || StrEqual(ip, "localhost")))
        {
                g_bSyncing[client]      = false;
                g_bSessionSynced[client] = true;   // sincronizado por definicion
                g_bPendingCookie[client] = false;
                delete g_hDelayTimer[client];
                if (g_cvDebug.BoolValue)
                        LogMessage("[FileNet] %N es el host local (%s): ya tiene los archivos en disco, no se envia nada.", client, ip);
                return;
        }

        if (!LibraryExists("filenetwork"))
        {
                LogError("[FileNet] filenetwork.smx no esta cargado; no se envia nada a %N.", client);
                return;
        }

        if (g_Files.Length == 0)
                return;

        int mode = g_cvMode.IntValue;

        // ¿Ya esta sincronizado con la version actual?
        if (!g_bForce[client])
        {
                if (mode == 0 && g_bSessionSynced[client])
                        return;

                if (mode == 1)
                {
                        if (!AreClientCookiesCached(client))
                        {
                                // Esperar a que las cookies lleguen (con red de seguridad de 20s)
                                if (!g_bPendingCookie[client])
                                {
                                        g_bPendingCookie[client] = true;
                                        delete g_hCookieTimer[client];
                                        g_hCookieTimer[client] = CreateTimer(20.0, Timer_CookieFallback, GetClientUserId(client));
                                }
                                return;
                        }

                        int stored = g_hVersionCookie.GetInt(client, 0);
                        if (stored != 0 && stored == g_iVersion)
                        {
                                g_bSessionSynced[client] = true;
                                if (g_cvDebug.BoolValue)
                                        LogMessage("[FileNet] %N ya tiene la version %d del listado; nada que enviar.", client, g_iVersion);
                                return;
                        }
                }
        }

        StartSend(client);
}

public Action Timer_CookieFallback(Handle timer, int userid)
{
        int client = GetClientOfUserId(userid);
        if (client > 0)
        {
                g_hCookieTimer[client] = null;
                if (g_bPendingCookie[client])
                {
                        // Las cookies nunca llegaron (raro). Enviar de todos modos:
                        // es mas seguro enviar de mas que de menos.
                        g_bPendingCookie[client] = false;
                        g_bForce[client] = true;
                        SyncClient(client);
                }
        }
        return Plugin_Stop;
}

void StartSend(int client)
{
        g_iTotal[client] = 0;
        g_iDone[client] = 0;
        g_iFailed[client] = 0;
        g_bSyncing[client] = true;
        g_iSyncVersion[client] = g_iVersion;
        g_bForce[client] = false;

        char path[PLATFORM_MAX_PATH];
        for (int i = 0; i < g_Files.Length; i++)
        {
                if (g_Sizes.Get(i) < 0)
                        continue; // archivo ausente en el servidor: ya se aviso al cargar

                g_Files.GetString(i, path, sizeof(path));
                FileNet_SendFile(client, path, OnFileSent);
                g_iTotal[client]++;
        }

        if (g_iTotal[client] == 0)
        {
                g_bSyncing[client] = false;
                g_bSessionSynced[client] = true;
                return;
        }

        LogMessage("[FileNet] Enviando %d archivo(s) a %N (version %d)...", g_iTotal[client], client, g_iSyncVersion[client]);
}

/** Callback de FileNet_SendFile: un archivo termino (bien o mal). */
public void OnFileSent(int client, const char[] file, bool success, any data)
{
        if (client < 1 || client > MaxClients)
                return;

        if (!g_bSyncing[client])
                return; // callback de una cola antigua (p. ej. tras sm_filenet_reload)

        g_iDone[client]++;

        if (!success)
        {
                g_iFailed[client]++;
                LogError("[FileNet] No se pudo enviar \"%s\" a %N.", file, client);
        }

        if (g_iDone[client] < g_iTotal[client])
                return;

        // Sincronizacion completa
        g_bSyncing[client] = false;
        g_bSessionSynced[client] = true;

        if (g_iFailed[client] == 0)
        {
                if (g_cvMode.IntValue == 1 && AreClientCookiesCached(client))
                {
                        char versionStr[16];
                        IntToString(g_iSyncVersion[client], versionStr, sizeof(versionStr));
                        g_hVersionCookie.Set(client, versionStr);
                }

                LogMessage("[FileNet] %N sincronizado: %d archivo(s) correctos.", client, g_iDone[client]);
        }
        else
        {
                // Con fallos no guardamos la cookie: la proxima entrada reintentara.
                LogError("[FileNet] %N termino con %d fallo(s) de %d. Se reintentara al reconectar.", client, g_iFailed[client], g_iTotal[client]);
        }
}

/* ========================================================================
        Comandos de administracion
   ======================================================================== */

public Action Command_Status(int client, int args)
{
        bool fileNet = LibraryExists("filenetwork");

        ReplyToCommand(client, "[FileNet] ===== FileNet Downloads v%s =====", PLUGIN_VERSION);
        ReplyToCommand(client, "[FileNet] Libreria File-Network: %s", fileNet ? "CARGADA (correcto)" : "NO CARGADA (falta filenetwork.smx + gamedata)");
        ReplyToCommand(client, "[FileNet] Archivos listados: %d | faltantes en servidor: %d | listas leidas: %d", g_Files.Length, g_iMissingCount, g_iListSources);
        ReplyToCommand(client, "[FileNet] Version del listado: %d | modo: %d | precache sonidos: %s | precache particulas: %s",
                g_iVersion, g_cvMode.IntValue, g_cvPrecache.BoolValue ? "si" : "no", g_cvPrecacheParticles.BoolValue ? "si" : "no");

        ConVar netMax = FindConVar("net_maxfilesize");
        if (netMax != null)
                ReplyToCommand(client, "[FileNet] net_maxfilesize: %d MB", netMax.IntValue);

        int humans;
        for (int i = 1; i <= MaxClients; i++)
        {
                if (!IsClientInGame(i) || IsFakeClient(i))
                        continue;

                humans++;
                char state[96];
                if (g_bSyncing[i])
                        Format(state, sizeof(state), "enviando %d/%d (fallos: %d)", g_iDone[i], g_iTotal[i], g_iFailed[i]);
                else if (g_bSessionSynced[i])
                        Format(state, sizeof(state), "sincronizado");
                else if (g_bPendingCookie[i])
                        Format(state, sizeof(state), "esperando cookies del cliente");
                else
                        Format(state, sizeof(state), "pendiente");

                ReplyToCommand(client, "[FileNet]   %N: %s", i, state);
        }

        if (!humans)
                ReplyToCommand(client, "[FileNet] No hay jugadores humanos conectados.");
        else if (g_Files.Length == 0)
                ReplyToCommand(client, "[FileNet] Lista VACIA: coloca sound_mapstart.txt en addons/sourcemod/configs/ (o usa la Herramienta FileNet).");

        return Plugin_Handled;
}

public Action Command_List(int client, int args)
{
        ReplyToCommand(client, "[FileNet] ===== %d archivo(s) listados =====", g_Files.Length);

        char path[PLATFORM_MAX_PATH];
        int shown;
        for (int i = 0; i < g_Files.Length && shown < 300; i++)
        {
                g_Files.GetString(i, path, sizeof(path));
                int size = g_Sizes.Get(i);

                if (size < 0)
                        ReplyToCommand(client, "[%03d] %s  ¡FALTA EN EL SERVIDOR!", i+1, path);
                else
                        ReplyToCommand(client, "[%03d] %s  (%d KB)", i+1, path, size / 1024);
                shown++;
        }

        if (g_Files.Length > shown)
                ReplyToCommand(client, "... y %d mas.", g_Files.Length - shown);

        return Plugin_Handled;
}

public Action Command_Reload(int client, int args)
{
        LoadLists();
        PrecacheListed();

        ReplyToCommand(client, "[FileNet] Listas recargadas: %d archivo(s), version %d.", g_Files.Length, g_iVersion);
        if (g_iMissingCount > 0)
                ReplyToCommand(client, "[FileNet] ¡Atencion! %d archivo(s) no existen en el servidor.", g_iMissingCount);

        // Resincronizar a los conectados (la version pudo cambiar)
        for (int i = 1; i <= MaxClients; i++)
        {
                if (IsClientInGame(i) && !IsFakeClient(i))
                {
                        g_bSessionSynced[i] = false;
                        SyncClient(i);
                }
        }

        LogAction(client, -1, "\"%L\" recargo las listas de FileNet.", client);
        return Plugin_Handled;
}

public Action Command_Resync(int client, int args)
{
        if (args < 1)
        {
                ReplyToCommand(client, "[FileNet] Uso: sm_filenet_resync <jugador | #userid | all>");
                return Plugin_Handled;
        }

        char pattern[64];
        GetCmdArg(1, pattern, sizeof(pattern));

        if (StrEqual(pattern, "all", false))
        {
                int count;
                for (int i = 1; i <= MaxClients; i++)
                {
                        if (IsClientInGame(i) && !IsFakeClient(i))
                        {
                                g_bSessionSynced[i] = false;
                                g_bForce[i] = true;
                                SyncClient(i);
                                count++;
                        }
                }
                ReplyToCommand(client, "[FileNet] Resync forzado lanzado para %d jugador(es).", count);
                return Plugin_Handled;
        }

        char targetName[MAX_TARGET_LENGTH];
        int targets[MAXPLAYERS];
        bool tnIsMb;

        int count = ProcessTargetString(pattern, client, targets, sizeof(targets), COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_BOTS, targetName, sizeof(targetName), tnIsMb);
        if (count <= 0)
        {
                ReplyToTargetError(client, count);
                return Plugin_Handled;
        }

        for (int i = 0; i < count; i++)
        {
                g_bSessionSynced[targets[i]] = false;
                g_bForce[targets[i]] = true;
                SyncClient(targets[i]);
        }

        ReplyToCommand(client, "[FileNet] Resync forzado para: %s", targetName);
        LogAction(client, -1, "\"%L\" forzo resync de FileNet para: %s", client, targetName);
        return Plugin_Handled;
}

/* ========================================================================
        Cambios de convar
   ======================================================================== */

public void OnListCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
        // Recargar listas con un pequeño delay para no duplicar trabajo
        CreateTimer(1.0, Timer_CvarReload);
}

public Action Timer_CvarReload(Handle timer)
{
        if (IsServerProcessing())
                LoadLists();
        return Plugin_Stop;
}
