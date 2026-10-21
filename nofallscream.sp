#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

/**
 * NO FALL SCREAM (L4D2)  v1.0.0
 * ----------------------------------------------------------------------------
 * Bloquea el "grito de caida" de los supervivientes.
 *
 * POR QUE LAS VERSIONES ANTERIORES (amy_fall_fix) NO FUNCIONABAN:
 *   El grito de caida real de L4D2 NO es el sonido generico "pl_fallpain"
 *   de Source. Son archivos de VOZ de cada superviviente:
 *       sound/player/survivor/voice/<carpeta>/fall01.wav  (fall01..fall03)
 *   Carpetas: gambler(Nick) mechanic(Ellis) coach(Coach) producer(Rochelle)
 *             namvet(Bill) biker(Francis) manager(Louis) teengirl(Zoey)
 *
 * METODO DE BLOQUEO (doble):
 *   1) PATRON: el sound hook intercepta todo sonido cuyo archivo sea
 *      "fall*.wav" dentro de la voz de superviviente (o "fallpain"),
 *      en el canal de voz (SNDCHAN_VOICE). Funciona aunque el jugador
 *      use un pack de voz personalizado del taker (rutas personalizadas).
 *   2) GUARDIAN DE CAIDA: si un superviviente esta cayendo rapido
 *      (velocidad vertical < umbral) o acaba de aterrizar, se bloquea
 *      TODA su voz durante esa ventana. Red de seguridad: silencia el
 *      grito aunque el archivo se llame distinto en una voz custom.
 *
 * Diagnostico: sm_nofall_debug 2 muestra por consola TODA la voz que pasa
 * por el servidor. Si durante el grito no aparece ninguna linea "VOZ",
 * el sonido lo reproduce el cliente (mod VPK) y ningun plugin de servidor
 * puede silenciarlo (esa es la prueba definitiva).
 */

#define PLUGIN_VERSION "1.0.0"

public Plugin myinfo =
{
        name        = "No Fall Scream (L4D2)",
        author      = "Super Z",
        description = "Bloquea el grito de caida de los supervivientes (reemplaza amy_fall_fix)",
        version     = PLUGIN_VERSION,
        url         = ""
};

// ---------------------------------------------------------------- Cvars ----
ConVar g_cvEnable;   // bloqueo general
ConVar g_cvMode;     // 1 = todos los supervivientes | 2 = solo modelos custom (taker)
ConVar g_cvGuard;    // guardian de caida on/off
ConVar g_cvVel;      // umbral de velocidad vertical (caida)
ConVar g_cvWindow;   // segundos de bloqueo tras dejar de caer
ConVar g_cvExtra;    // patrones extra separados por comas
ConVar g_cvDebug;    // 0 nada | 1 bloqueos | 2 + toda la voz de supervivientes

// Valores cacheados (ruta rapida del hook: se disparan MUCHOS sonidos)
bool  g_bEnable;
int   g_iMode;
bool  g_bGuard;
float g_fVel;
float g_fWindow;
int   g_iDebug;

char  g_sExtras[8][32];
int   g_iExtraCount;

// Estado
float g_fFallingUntil[MAXPLAYERS + 1];
int   g_iBlockedPattern;
int   g_iBlockedGuard;
int   g_iBlockedAmbient;

// ----------------------------------------------------------------- Init ----
public void OnPluginStart()
{
        CreateConVar("sm_nofall_version", PLUGIN_VERSION, "Version de No Fall Scream",
                FCVAR_NOTIFY|FCVAR_DONTRECORD);

        g_cvEnable = CreateConVar("sm_nofall_enable", "1",
                "1 = bloquear el grito de caida, 0 = desactivado", 0, true, 0.0, true, 1.0);
        g_cvMode = CreateConVar("sm_nofall_mode", "1",
                "1 = bloquea a TODOS los supervivientes | 2 = solo a jugadores con modelo personalizado (skins del taker)", 0, true, 1.0, true, 2.0);
        g_cvGuard = CreateConVar("sm_nofall_guard", "1",
                "1 = ademas silencia toda la voz del jugador mientras cae / al aterrizar (red de seguridad)", 0, true, 0.0, true, 1.0);
        g_cvVel = CreateConVar("sm_nofall_velocidad", "-350.0",
                "Velocidad vertical que cuenta como caida (unidades/seg). -350 ignora saltos normales");
        g_cvWindow = CreateConVar("sm_nofall_ventana", "1.2",
                "Segundos que se sigue silenciando la voz tras dejar de caer (aterrizaje)", 0, true, 0.1, true, 5.0);
        g_cvExtra = CreateConVar("sm_nofall_extra", "",
                "Patrones extra a bloquear, separados por comas (ej: ledgehang,screamwhilepounced)");
        g_cvDebug = CreateConVar("sm_nofall_debug", "0",
                "0 = nada | 1 = registrar bloqueos | 2 = ademas registrar TODA la voz de supervivientes (diagnostico)", 0, true, 0.0, true, 2.0);

        g_cvEnable.AddChangeHook(OnCvarChanged);
        g_cvMode.AddChangeHook(OnCvarChanged);
        g_cvGuard.AddChangeHook(OnCvarChanged);
        g_cvVel.AddChangeHook(OnCvarChanged);
        g_cvWindow.AddChangeHook(OnCvarChanged);
        g_cvExtra.AddChangeHook(OnCvarChanged);
        g_cvDebug.AddChangeHook(OnCvarChanged);

        RegConsoleCmd("sm_nofall", Cmd_Status, "Muestra el estado del bloqueo de gritos de caida");

        AutoExecConfig(true, "plugin.nofallscream");
        RefreshCache();

        AddNormalSoundHook(SoundHook);
        AddAmbientSoundHook(AmbientHook);
}

public void OnPluginEnd()
{
        RemoveNormalSoundHook(SoundHook);
        RemoveAmbientSoundHook(AmbientHook);
}

public void OnConfigsExecuted()
{
        RefreshCache();
}

public void OnClientDisconnect(int client)
{
        g_fFallingUntil[client] = 0.0;
}

// ------------------------------------------------------------- Comando ----
public Action Cmd_Status(int client, int args)
{
        ReplyToCommand(client, "[NoFall] version %s | estado: %s | modo: %s",
                PLUGIN_VERSION,
                g_bEnable ? "ACTIVO" : "DESACTIVADO",
                g_iMode == 1 ? "todos los supervivientes" : "solo modelos personalizados");
        ReplyToCommand(client, "[NoFall] guardian de caida: %s (umbral %.0f, ventana %.1fs)",
                g_bGuard ? "ON" : "OFF", g_fVel, g_fWindow);
        char extras[256];
        g_cvExtra.GetString(extras, sizeof extras);
        ReplyToCommand(client, "[NoFall] debug: %d | patrones extra: %s",
                g_iDebug, g_iExtraCount > 0 ? extras : "(ninguno)");
        ReplyToCommand(client, "[NoFall] bloqueados desde la carga: %d por patron, %d por guardian, %d ambientales",
                g_iBlockedPattern, g_iBlockedGuard, g_iBlockedAmbient);
        return Plugin_Handled;
}

// ------------------------------------------------------------ Utilidades ---
void RefreshCache()
{
        g_bEnable = g_cvEnable.BoolValue;
        g_iMode   = g_cvMode.IntValue;
        g_bGuard  = g_cvGuard.BoolValue;
        g_fVel    = g_cvVel.FloatValue;
        g_fWindow = g_cvWindow.FloatValue;
        g_iDebug  = g_cvDebug.IntValue;

        char buf[256];
        g_cvExtra.GetString(buf, sizeof buf);
        g_iExtraCount = ExplodeString(buf, ",", g_sExtras, sizeof g_sExtras, sizeof g_sExtras[]);
        for (int i = 0; i < g_iExtraCount; i++)
        {
                TrimString(g_sExtras[i]);
                NormalizeSample(g_sExtras[i]);
                if (g_sExtras[i][0] == '\0')
                {
                        // patron vacio: compactar
                        for (int j = i; j < g_iExtraCount - 1; j++)
                        {
                                strcopy(g_sExtras[j], sizeof g_sExtras[], g_sExtras[j + 1]);
                        }
                        g_iExtraCount--;
                        i--;
                }
        }
}

public void OnCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
        RefreshCache();
}

// Normaliza: minusculas, '\'->'/', quita prefijos raros ('*', '#', etc.)
void NormalizeSample(char s[PLATFORM_MAX_PATH])
{
        int i = 0;
        while (s[i] != '\0')
        {
                int c = view_as<int>(s[i]);
                if (c >= 'A' && c <= 'Z')
                {
                        c += 32;
                }
                else if (c == '\\')
                {
                        c = '/';
                }
                s[i] = view_as<char>(c);
                i++;
        }

        int start = 0;
        while (s[start] != '\0')
        {
                int c = view_as<int>(s[start]);
                if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9'))
                {
                        break;
                }
                start++;
        }
        if (start > 0)
        {
                int j = 0;
                while (s[start + j] != '\0')
                {
                        s[j] = s[start + j];
                        j++;
                }
                s[j] = '\0';
        }
}

// Nombre de archivo (tras la ultima '/')
void GetFileName(const char[] path, char fname[64])
{
        int slash = FindCharInString(path, '/', true);
        if (slash == -1)
        {
                strcopy(fname, sizeof fname, path);
        }
        else
        {
                strcopy(fname, sizeof fname, path[slash + 1]);
        }
}

void DebugPrint(int level, const char[] format, any ...)
{
        if (g_iDebug < level)
        {
                return;
        }
        char buffer[254];
        VFormat(buffer, sizeof buffer, format, 3);
        PrintToServer("[NoFall] %s", buffer);
}

// --------------------------------------------- GUARDIAN: velocidad de caida
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
        if (!g_bEnable || !g_bGuard)
        {
                return Plugin_Continue;
        }
        if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))
        {
                return Plugin_Continue;
        }
        if (GetClientTeam(client) != 2)
        {
                return Plugin_Continue;
        }

        float curVel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", curVel);
        if (curVel[2] < g_fVel)
        {
                // cayendo rapido: mantener la ventana activa mientras dure la caida
                g_fFallingUntil[client] = GetGameTime() + g_fWindow;
        }
        return Plugin_Continue;
}

// ------------------------------------------------------------- SOUND HOOK --
public Action SoundHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH],
        int &entity, int &channel, float &volume, int &level, int &pitch, int &flags,
        char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
        if (!g_bEnable)
        {
                return Plugin_Continue;
        }

        // Ruta rapida: el 99% de sonidos no son voz ni contienen 'fall'
        bool voiceChan = (channel == SNDCHAN_VOICE);
        if (!voiceChan
                && StrContains(sample, "voice/") == -1
                && StrContains(sample, "fall") == -1)
        {
                return Plugin_Continue;
        }

        char s[PLATFORM_MAX_PATH];
        strcopy(s, sizeof s, sample);
        NormalizeSample(s);
        char e[PLATFORM_MAX_PATH];
        strcopy(e, sizeof e, soundEntry);
        NormalizeSample(e);

        bool svVoicePath = (StrContains(s, "survivor/voice/") != -1);

        // Quien emite el sonido
        int client = 0;
        if (entity >= 1 && entity <= MaxClients)
        {
                client = entity;
        }
        bool isSurvivor = false;
        bool bCustomModel = true;
        if (client > 0 && IsClientInGame(client) && GetClientTeam(client) == 2)
        {
                isSurvivor = true;
                char mdl[PLATFORM_MAX_PATH];
                GetClientModel(client, mdl, sizeof mdl);
                // modelos stock de L4D2: models/survivors/survivor_*.mdl
                if (StrContains(mdl, "survivors/") != -1)
                {
                        bCustomModel = false;
                }
        }
        bool inScope = isSurvivor && (g_iMode == 1 || bCustomModel);

        // --- 1) bloqueo por patron ---
        bool isFall = false;

        if (StrContains(s, "fallpain") != -1 || StrContains(e, "fallpain") != -1)
        {
                isFall = true; // dolor de caida generico del motor: siempre seguro
        }

        if (!isFall)
        {
                char fname[64];
                GetFileName(s, fname);
                if (strncmp(fname, "fall", 4) == 0)
                {
                        // fall01.wav .. fall03.wav y variantes (fall_x, fall2b...)
                        if (svVoicePath || (voiceChan && isSurvivor))
                        {
                                isFall = true;
                        }
                }
                else if (voiceChan && isSurvivor && StrContains(e, "fall") != -1)
                {
                        // entrada de soundscript tipo "Survivor.Fall" desde un superviviente
                        isFall = true;
                }
        }

        if (!isFall && g_iExtraCount > 0)
        {
                for (int i = 0; i < g_iExtraCount && !isFall; i++)
                {
                        if (StrContains(s, g_sExtras[i]) != -1 && (svVoicePath || (voiceChan && isSurvivor)))
                        {
                                isFall = true;
                        }
                        else if (voiceChan && isSurvivor && StrContains(e, g_sExtras[i]) != -1)
                        {
                                isFall = true;
                        }
                }
        }

        if (isFall)
        {
                g_iBlockedPattern++;
                DebugPrint(1, "BLOQUEADO (patron) '%s' entry='%s' ent=%d ch=%d", sample, soundEntry, entity, channel);
                return Plugin_Stop;
        }

        // --- 2) guardian de caida: silenciar voz mientras cae / al aterrizar ---
        if (voiceChan && isSurvivor && inScope && g_bGuard
                && client > 0 && GetGameTime() < g_fFallingUntil[client])
        {
                g_iBlockedGuard++;
                DebugPrint(1, "BLOQUEADO (guardian de caida) '%s' entry='%s' ent=%d", sample, soundEntry, entity);
                return Plugin_Stop;
        }

        // --- diagnostico nivel 2: registrar toda la voz de supervivientes ---
        if (g_iDebug >= 2 && voiceChan && isSurvivor)
        {
                DebugPrint(2, "VOZ ent=%d '%s' entry='%s'", entity, sample, soundEntry);
        }

        return Plugin_Continue;
}

// --------------------------------------------------------- AMBIENT HOOK ----
public Action AmbientHook(char sample[PLATFORM_MAX_PATH], int &entity, float &volume,
        int &level, int &pitch, float pos[3], int &flags, float &delay)
{
        if (!g_bEnable)
        {
                return Plugin_Continue;
        }
        if (StrContains(sample, "voice/") == -1 && StrContains(sample, "fall") == -1)
        {
                return Plugin_Continue;
        }

        char s[PLATFORM_MAX_PATH];
        strcopy(s, sizeof s, sample);
        NormalizeSample(s);

        bool svVoicePath = (StrContains(s, "survivor/voice/") != -1);

        bool isFall = (StrContains(s, "fallpain") != -1);
        if (!isFall && svVoicePath)
        {
                char fname[64];
                GetFileName(s, fname);
                if (strncmp(fname, "fall", 4) == 0)
                {
                        isFall = true;
                }
        }

        if (isFall)
        {
                g_iBlockedAmbient++;
                DebugPrint(1, "BLOQUEADO (ambiental) '%s'", sample);
                return Plugin_Stop;
        }
        return Plugin_Continue;
}
