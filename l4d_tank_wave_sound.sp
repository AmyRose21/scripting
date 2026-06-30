#define PLUGIN_VERSION "23.3.0-RandomTankMusic-OriginalBase"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

// CONFIGURACIÓN DE AUDIO
#define CUSTOM_MUSIC_CHANNEL SNDCHAN_STATIC 
#define MUSIC_LEVEL          SNDLEVEL_RAID_SIREN 
#define MUSIC_VOL            1.0           
#define SNDLEVEL_RAID_SIREN  135  

// SONIDOS DE SILENCIO (BOOMER)
#define SOUND_BOOMER_VOMIT "music/bacteria/pukricide.wav"
#define SOUND_L4D1_VOMIT   "music/bacteria/pukricide_l4d1.wav"

// CLASE ZOMBIE
#define ZC_TANK 8

public Plugin myinfo = 
{
    name = "Tank Wave Sound (Victory, Silence, Multi-Tank & Random Music)",
    author = "Dragokas & Ewe & Fixer",
    description = "Frankenstein Logic + Victory Music + Smart Tank Detection + FadeOut + Random Music per Tank",
    version = PLUGIN_VERSION,
    url = ""
}

char FILE_TANK_WAVE_SOUNDS[PLATFORM_MAX_PATH]   = "data/tank_wave_sounds.txt";
char FILE_TANK_FINALE_SOUNDS[PLATFORM_MAX_PATH] = "data/tank_finale_sounds.txt";

ArrayList g_SoundTank;
ArrayList g_SoundFinale;

char g_sCurrentTankSound[PLATFORM_MAX_PATH];
char g_sCurrentFinaleSound[PLATFORM_MAX_PATH];
char g_sLastPlayedSound[PLATFORM_MAX_PATH];

bool g_bIsFinale;
bool g_bEscapeMusicStarted;
int iLastTankPlayedTime;
float g_fCurrentFadeVolume; // Variable para controlar el volumen actual del fade

Handle hSDK_StopMusic = null; 
Handle g_hSpamTimer = null;   
Handle g_hFadeTimer = null; // Timer para el efecto de desvanecimiento

ConVar g_hCvarEnable, g_hCvarWaveMusic, g_hCvarFinaleMusic;

public void OnPluginStart()
{
    g_hCvarEnable       = CreateConVar("l4d_tank_sound_enable", "1", "Activar plugin", FCVAR_NOTIFY);
    g_hCvarWaveMusic    = CreateConVar("l4d_tank_sound_wave",   "1", "Musica de Tank en mapas normales", FCVAR_NOTIFY);
    g_hCvarFinaleMusic  = CreateConVar("l4d_tank_sound_finale", "1", "Musica de escape/victoria en finales", FCVAR_NOTIFY);
    
    AutoExecConfig(true, "l4d_tank_sound_victory");

    RegAdminCmd("sm_test_finale", CmdTestFinale, ADMFLAG_ROOT, "Test Finale Logic");
    RegAdminCmd("sm_stopsound_custom", CmdStopSound, ADMFLAG_ROOT, "Stop All");
	
	  // Comando para forzar la música del Tank (Admin)
    RegAdminCmd("sm_playtank", Cmd_PlayTank, ADMFLAG_GENERIC, "Forzar musica de Tank");
    
    // Comando para saltar a la siguiente canción de Tank (Admin)
    RegAdminCmd("sm_nexttank", Cmd_NextTankSong, ADMFLAG_GENERIC, "Cambiar a otra cancion de Tank");
	
    g_SoundTank = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
    g_SoundFinale = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

    BuildPath(Path_SM, FILE_TANK_WAVE_SOUNDS, sizeof(FILE_TANK_WAVE_SOUNDS), FILE_TANK_WAVE_SOUNDS);
    BuildPath(Path_SM, FILE_TANK_FINALE_SOUNDS, sizeof(FILE_TANK_FINALE_SOUNDS), FILE_TANK_FINALE_SOUNDS);

    HookEvent("tank_spawn", Event_TankSpawn);
    HookEvent("tank_killed", Event_TankKilled);
    HookEvent("round_start", Event_RoundStart);
    HookEvent("round_end", Event_RoundEnd);
    
    HookEvent("finale_escape_start", Event_EscapeStart_Backup);
    HookEvent("finale_win", Event_FinaleWin);
    HookEvent("mission_lost", Event_RoundEnd);
    
    AddNormalSoundHook(SoundHook_Radar);
    LoadDirectorHack();
}

public void OnMapStart()
{
    g_sLastPlayedSound[0] = '\0';
    g_sCurrentTankSound[0] = '\0'; // Limpiar para que la primera ronda elija una al azar
    g_sCurrentFinaleSound[0] = '\0';
    iLastTankPlayedTime = 0;
    g_bEscapeMusicStarted = false;
    StopSpamTimer();
    CancelFade();

    PrecacheSound(SOUND_BOOMER_VOMIT, true);
    PrecacheSound(SOUND_L4D1_VOMIT, true);

    LoadMusicTank();
    LoadMusicFinale();
    PrepareSounds(); // Ahora precarga TODAS las canciones

    g_bIsFinale = CheckIfFinaleMap();

    if (g_bIsFinale)
    {
        ScanAndHookRelays();
        int entity = FindEntityByClassname(-1, "trigger_finale");
        if (entity != -1) {
            HookSingleEntityOutput(entity, "FinaleEscapeStart", OnFinaleLogicTriggered);
            HookSingleEntityOutput(entity, "FinaleVehicleReady", OnFinaleLogicTriggered);
        }
    }
}

// =========================================================================
//  DETECTAR VICTORIA
// =========================================================================

public void Event_FinaleWin(Event event, const char[] name, bool dontBroadcast)
{
    PrintToChatAll("\x04[Music] \x01¡Victoria! Restaurando audio del juego.");
    StopSpamTimer();
    StopCurrentMusic(false); // Corte inmediato en victoria para que suene el WIN del juego
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i))
        {
            ClientCommand(i, "music_dynamic_stop_playing");
        }
    }
    
    g_bEscapeMusicStarted = false;
}

// =========================================================================
//  SISTEMA DE DETECCIÓN (FINALE)
// =========================================================================

public void OnFinaleLogicTriggered(const char[] output, int caller, int activator, float delay)
{
    TriggerTheNuke("ENTIDAD: trigger_finale Output");
}

public void OnSpyRelayTriggered(const char[] output, int caller, int activator, float delay)
{
    char sName[128];
    GetEntPropString(caller, Prop_Data, "m_iName", sName, sizeof(sName));
    
    if (StrEqual(sName, "relay_car_ready") || 
        StrEqual(sName, "relay_start_heli") || 
        StrEqual(sName, "helicopter_land_relay") ||
        StrEqual(sName, "relay_leave_boat") || 
        StrEqual(sName, "plane_takeoff_relay") || 
        StrEqual(sName, "generator_final_button_relay") || 
        StrContains(sName, "escape", false) != -1 || 
        StrContains(sName, "vehicle", false) != -1 ||
        StrContains(sName, "ready", false) != -1
       )
    {
        char sReason[256];
        Format(sReason, sizeof(sReason), "LÓGICA: Relay (%s)", sName);
        TriggerTheNuke(sReason);
    }
}

public Action SoundHook_Radar(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
    // 1. Lógica original de escape
    if (g_bIsFinale)
    {
        if (StrContains(sample, "skinonourteeth", false) != -1 || 
            StrContains(sample, "themonsterswithout", false) != -1 ||
            StrContains(sample, "midnightride", false) != -1 ||
            StrContains(sample, "onebadman", false) != -1 ||
            StrContains(sample, "finalnail", false) != -1)
        {
            if (!g_bEscapeMusicStarted)
            {
                char sReason[256];
                Format(sReason, sizeof(sReason), "RADAR: Detectado (%s)", sample);
                TriggerTheNuke(sReason);
            }
            return Plugin_Handled;
        }
    }

    // 2. BLOQUEO BRAVO DE MÚSICA DE TANK
    // Si nuestra música está sonando, bloqueamos TODOS los archivos nativos del Tank
    if (g_sLastPlayedSound[0] != '\0' || g_bEscapeMusicStarted)
    {
        if (StrContains(sample, "music/tank/", false) != -1 || 
            StrContains(sample, "bacteria/tank", false) != -1 ||
            StrContains(sample, "tank.wav", false) != -1 ||
            StrContains(sample, "tankb.wav", false) != -1 ||
            StrContains(sample, "tank_midpoint", false) != -1 ||
            StrContains(sample, "tank_brothers", false) != -1 ||
            StrContains(sample, "tank_finale", false) != -1)
        {
            return Plugin_Handled; // Bloquear el sonido nativo
        }
    }

    return Plugin_Continue;
}

public void Event_EscapeStart_Backup(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bIsFinale && !g_bEscapeMusicStarted) 
    {
        TriggerTheNuke("EVENTO: finale_escape_start");
    }
}

// =========================================================================
//  EJECUCIÓN DE SILENCIO (CORE LOGIC)
// =========================================================================

void TriggerTheNuke(char[] reason)
{
    if (!g_hCvarEnable.BoolValue || !g_hCvarFinaleMusic.BoolValue) return;
    if (g_bEscapeMusicStarted) return;
    
    g_bEscapeMusicStarted = true;
    
    PrintToChatAll("\x03[DIAGNOSTICO] \x04ACTIVADO POR: \x05%s", reason);
    
    StartSpamTimer(); 
    StopCurrentMusic(false); // Corte seco para empezar la nueva música de escape
    
    if (g_sCurrentFinaleSound[0] != '\0')
    {
        CreateTimer(0.1, Timer_PlayFinale);
    }
    else
    {
         if(g_SoundFinale.Length > 0) {
             g_SoundFinale.GetString(0, g_sCurrentFinaleSound, sizeof(g_sCurrentFinaleSound));
             CreateTimer(0.1, Timer_PlayFinale);
         }
    }
}

public Action Timer_ApplyAllFixes(Handle timer)
{
    // FIX ADICIONAL: Seguridad para Tanks
    if (!g_bIsFinale && g_hSpamTimer != null)
    {
        if (GetActiveTankCount(-1) == 0)
        {
            // Si ya no hay tanks, detenemos el silenciador para que vuelva la música normal
            StopSpamTimer();
            // Y aseguramos que nuestra música esté haciendo fade out o apagada
            if (g_sLastPlayedSound[0] != '\0' && g_hFadeTimer == null)
            {
                StopCurrentMusic(true);
            }
            return Plugin_Stop;
        }
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i))
        {
            // DETENER TODAS LAS VARIANTES DE EVENTOS DE MÚSICA DEL TANK Y BATALLA FINAL
            Internal_StopMusic(i, "Event.Tank");
            Internal_StopMusic(i, "Event.Tank_L4D1");
            Internal_StopMusic(i, "Event.TankMidpoint");
            Internal_StopMusic(i, "Event.TankMidpoint_L4D1");
            Internal_StopMusic(i, "Event.TankBrothers");
            Internal_StopMusic(i, "Event.TankBrothers_L4D1");
            Internal_StopMusic(i, "Event.FinalBattle");
            Internal_StopMusic(i, "Event.FinalBattle_L4D1");
            Internal_StopMusic(i, "Event.TankBattle"); // Variante extra de seguridad
            
            // Truco del boomer original
            ClientCommand(i, "music_dynamic_play Event.Boomer");
            EmitSoundToClient(i, SOUND_BOOMER_VOMIT, SOUND_FROM_PLAYER, 6, SNDLEVEL_NORMAL, SND_CHANGEVOL, 0.001);
            EmitSoundToClient(i, SOUND_L4D1_VOMIT,   SOUND_FROM_PLAYER, 6, SNDLEVEL_NORMAL, SND_CHANGEVOL, 0.001);
            ClientCommand(i, "music_dynamic_stop_playing");
            
            // Forzar detener los archivos .wav físicos en los canales por si el Director los reproduce directamente
            StopSound(i, SNDCHAN_AUTO, "music/tank/tank.wav");
            StopSound(i, SNDCHAN_AUTO, "music/tank/tankb.wav");
            StopSound(i, SNDCHAN_AUTO, "music/tank/tank_midpoint.wav");
            StopSound(i, SNDCHAN_AUTO, "music/tank/tank_brothers.wav");
            StopSound(i, SNDCHAN_AUTO, "music/tank/tank_finale.wav");
            StopSound(i, SNDCHAN_STATIC, "music/tank/tank.wav");
            StopSound(i, SNDCHAN_STATIC, "music/tank/tankb.wav");
        }
    }
    return Plugin_Continue;
}

void StartSpamTimer()
{
    if (g_hSpamTimer == null)
    {
        Timer_ApplyAllFixes(null);
        g_hSpamTimer = CreateTimer(1.0, Timer_ApplyAllFixes, _, TIMER_REPEAT);
    }
}

void StopSpamTimer()
{
    if (g_hSpamTimer != null)
    {
        KillTimer(g_hSpamTimer);
        g_hSpamTimer = null;
    }
}

public Action Timer_PlayFinale(Handle timer)
{
    PlayCustomSound(g_sCurrentFinaleSound);
    return Plugin_Handled;
}

// -------------------------------------------------------------------------
// FUNCIONES DE AUDIO & FADE (DESVANECIMIENTO)
// -------------------------------------------------------------------------

void PlayCustomSound(char[] sSound)
{
    // Si iba a hacer fade out, lo cancelamos y subimos volumen
    CancelFade(); 
    StopCurrentMusic(false); // Stop anterior

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i))
        {
            EmitSoundToClient(i, sSound, SOUND_FROM_PLAYER, CUSTOM_MUSIC_CHANNEL, MUSIC_LEVEL, SND_NOFLAGS, MUSIC_VOL);
        }
    }
    strcopy(g_sLastPlayedSound, sizeof(g_sLastPlayedSound), sSound);
}

// Nueva función unificada para detener música
void StopCurrentMusic(bool bFade = false)
{
    if (g_sLastPlayedSound[0] == '\0') return;

    // Si ya estamos haciendo fade, no interrumpimos
    if (g_hFadeTimer != null && bFade) return;

    if (bFade)
    {
        // INICIAR FADE OUT
        CancelFade();
        g_fCurrentFadeVolume = 1.0;
        g_hFadeTimer = CreateTimer(0.1, Timer_FadeMusic, _, TIMER_REPEAT);
    }
    else
    {
        // CORTE INMEDIATO
        CancelFade();
        PerformStopSound();
    }
}

void PerformStopSound()
{
    for (int i = 1; i <= MaxClients; i++) 
        if (IsClientInGame(i)) 
            StopSound(i, CUSTOM_MUSIC_CHANNEL, g_sLastPlayedSound);
    
    g_sLastPlayedSound[0] = '\0';
}

void CancelFade()
{
    if (g_hFadeTimer != null)
    {
        KillTimer(g_hFadeTimer);
        g_hFadeTimer = null;
    }
}

public Action Timer_FadeMusic(Handle timer)
{
    g_fCurrentFadeVolume -= 0.05; // Baja 5% cada 0.1s (Total ~2 segs)

    if (g_fCurrentFadeVolume <= 0.0)
    {
        PerformStopSound();
        g_hFadeTimer = null;
        return Plugin_Stop;
    }

    // Aplicar nuevo volumen a todos los clientes
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i))
        {
            // SND_CHANGEVOL permite cambiar el volumen de un sonido en reproducción
            EmitSoundToClient(i, g_sLastPlayedSound, SOUND_FROM_PLAYER, CUSTOM_MUSIC_CHANNEL, MUSIC_LEVEL, SND_CHANGEVOL, g_fCurrentFadeVolume);
        }
    }
    return Plugin_Continue;
}

// -------------------------------------------------------------------------
// UTILIDADES
// -------------------------------------------------------------------------

void LoadMusicTank() { ReadFileToArrayList(FILE_TANK_WAVE_SOUNDS, g_SoundTank); }
void LoadMusicFinale() { ReadFileToArrayList(FILE_TANK_FINALE_SOUNDS, g_SoundFinale); }

void ReadFileToArrayList(char[] sPath, ArrayList list)
{
    list.Clear();
    File hFile = OpenFile(sPath, "r");
    if( hFile == null ) { LogError("Failed to open file: \"%s\"", sPath); return; }
    char str[PLATFORM_MAX_PATH];
    while( !hFile.EndOfFile() && hFile.ReadLine(str, sizeof(str)) )
    {
        TrimString(str);
        if( str[0] != '\0' && str[0] != '/' ) list.PushString(str);
    }
    delete hFile;
}

void PrepareSounds()
{
    char sBuffer[PLATFORM_MAX_PATH];
    char sSound[PLATFORM_MAX_PATH];
    
    // Precachear TODAS las canciones de Tank
    for (int i = 0; i < g_SoundTank.Length; i++) {
        g_SoundTank.GetString(i, sSound, sizeof(sSound));
        PrecacheSound(sSound, true);
        Format(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
        AddFileToDownloadsTable(sBuffer);
    }
    
    // Precachear TODAS las canciones de Finale
    for (int i = 0; i < g_SoundFinale.Length; i++) {
        g_SoundFinale.GetString(i, sSound, sizeof(sSound));
        PrecacheSound(sSound, true);
        Format(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
        AddFileToDownloadsTable(sBuffer);
    }
}

// -------------------------------------------------------------------------
// SDKCALLS
// -------------------------------------------------------------------------

void LoadDirectorHack()
{
    GenerateGameData();
    GameData hGameData = new GameData("dynamic_soundtrack_sets-l4d2");
    if (hGameData != null) {
        StartPrepSDKCall(SDKCall_Raw);
        PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "Music::StopPlaying");
        PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
        PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
        PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
        hSDK_StopMusic = EndPrepSDKCall();
        delete hGameData;
    }
}

void GenerateGameData()
{
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/dynamic_soundtrack_sets-l4d2.txt");
    if (!FileExists(sPath)) {
        File f = OpenFile(sPath, "w");
        if (f != null) {
            f.WriteLine("\"Games\"");
            f.WriteLine("{");
            f.WriteLine("    \"left4dead2\"");
            f.WriteLine("    {");
            f.WriteLine("        \"Signatures\"");
            f.WriteLine("        {");
            f.WriteLine("            \"Music::StopPlaying\"");
            f.WriteLine("            {");
            f.WriteLine("                \"library\"    \"server\"");
            f.WriteLine("                \"linux\"      \"@_ZN5Music11StopPlayingEPKcfb\"");
            f.WriteLine("                \"mac\"        \"@_ZN5Music11StopPlayingEPKcfb\"");
            f.WriteLine("                \"windows\"    \"\\x55\\x8B\\x2A\\x83\\x2A\\x2A\\xA1\\x2A\\x2A\\x2A\\x2A\\x83\\x2A\\x2A\\x2A\\x56\\x8B\\x2A\\x89\\x2A\\x2A\\x0F\\x84\\x25\"");
            f.WriteLine("            }");
            f.WriteLine("        }");
            f.WriteLine("    }");
            f.WriteLine("}");
            delete f;
        }
    }
}

void Internal_StopMusic(int client, const char[] musicEvent)
{
    if (hSDK_StopMusic != null && IsClientInGame(client) && !IsFakeClient(client)) {
        Address pMusic = GetEntityAddress(client) + view_as<Address>(GetEntSendPropOffs(client, "m_music"));
        if (pMusic != Address_Null) SDKCall(hSDK_StopMusic, pMusic, musicEvent, 0.0, false);
    }
}

// -------------------------------------------------------------------------
// EVENTOS JUEGO
// -------------------------------------------------------------------------

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    StopCurrentMusic(false);
    StopSpamTimer();
    iLastTankPlayedTime = 0;
    g_bEscapeMusicStarted = false;
    g_sCurrentTankSound[0] = '\0'; // Resetear para que la primera canción de la ronda sea aleatoria
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    StopCurrentMusic(false);
    StopSpamTimer();
}

public void Event_TankSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_hCvarEnable.BoolValue || !g_hCvarWaveMusic.BoolValue) return;
    if (g_bIsFinale) return; 

    // Si ya estamos "Spameando" (música sonando), no reiniciamos.
    if (g_hSpamTimer != null && g_hFadeTimer == null) return;

    // Si estábamos haciendo fade out, lo cancelamos y subimos volumen (nuevo tank)
    if (g_hFadeTimer != null) CancelFade();

    if (GetTime() - iLastTankPlayedTime < 5) return;

    if (g_SoundTank.Length > 0)
    {
        // SELECCIÓN ALEATORIA PARA CADA TANK
        int idx = GetRandomInt(0, g_SoundTank.Length - 1);
        char sNewSound[PLATFORM_MAX_PATH];
        g_SoundTank.GetString(idx, sNewSound, sizeof(sNewSound));
        
        // Evitar repetir la misma canción del Tank anterior (si hay más de 1)
        if (g_SoundTank.Length > 1) {
            while (StrEqual(sNewSound, g_sCurrentTankSound)) {
                idx = GetRandomInt(0, g_SoundTank.Length - 1);
                g_SoundTank.GetString(idx, sNewSound, sizeof(sNewSound));
            }
        }
        
        strcopy(g_sCurrentTankSound, sizeof(g_sCurrentTankSound), sNewSound);
        
        PlayCustomSound(g_sCurrentTankSound);
        iLastTankPlayedTime = GetTime();
        
        StartSpamTimer(); 
        PrintToChatAll("\x04[Music] \x01Tank Wave!");
    }
}

public void Event_TankKilled(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bIsFinale) return;

    int victim = GetClientOfUserId(event.GetInt("userid"));

    // FIX MULTI-TANK: Si quedan tanks vivos, no hacemos nada.
    if (GetActiveTankCount(victim) > 0) return;

    // Si era el último tank, iniciamos el proceso de restauración
    if (StrEqual(g_sLastPlayedSound, g_sCurrentTankSound))
    {
        // Detenemos el silenciador del juego (la música normal empieza a volver)
        StopSpamTimer();
        
        // Iniciamos el fade out de nuestra música (efecto de transición suave)
        StopCurrentMusic(true);
        
        PrintToChatAll("\x04[Music] \x01Amenaza eliminada. Audio normal restaurado.");
    }
}

int GetActiveTankCount(int ignoreClient)
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == ignoreClient) continue; 
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3) 
        {
            if (GetEntProp(i, Prop_Send, "m_zombieClass") == ZC_TANK)
            {
                count++;
            }
        }
    }
    return count;
}

bool CheckIfFinaleMap()
{
    if (FindEntityByClassname(-1, "trigger_finale") != -1) return true;
    char sMap[64];
    GetCurrentMap(sMap, sizeof(sMap));
    
    if (StrEqual(sMap, "l4d_hospital05_rooftop", false) ||
        StrEqual(sMap, "c12m5_cornfield", false) || 
        StrEqual(sMap, "c1m4_atrium", false) ||
        StrEqual(sMap, "c2m5_concert", false) ||
        StrEqual(sMap, "c3m4_plantation", false) ||
        StrEqual(sMap, "c4m5_milltown_escape", false) ||
        StrEqual(sMap, "c5m5_bridge", false) ||
        StrEqual(sMap, "c6m3_port", false) ||
        StrEqual(sMap, "c7m3_port", false) ||
        StrEqual(sMap, "c8m5_rooftop", false) ||
        StrEqual(sMap, "c9m2_lots", false) ||
        StrEqual(sMap, "c10m5_houseboat", false) ||
        StrEqual(sMap, "c11m5_runway", false) ||
        StrEqual(sMap, "c13m4_cutthroatcreek", false) || 
        StrEqual(sMap, "l4d_river03_port", false)
       ) return true;
    return false;
}

void ScanAndHookRelays()
{
    int entity = -1;
    char sName[128];
    while ((entity = FindEntityByClassname(entity, "logic_relay")) != -1)
    {
        GetEntPropString(entity, Prop_Data, "m_iName", sName, sizeof(sName));
        if (StrEqual(sName, "relay_car_ready") || 
            StrEqual(sName, "relay_start_heli") || 
            StrEqual(sName, "helicopter_land_relay") ||
            StrEqual(sName, "relay_escape_starts") || 
            StrEqual(sName, "escape_relay") ||
            StrEqual(sName, "relay_leave_boat") ||
            StrEqual(sName, "plane_takeoff_relay") || 
            StrEqual(sName, "generator_final_button_relay") ||
            StrContains(sName, "apc", false) != -1 ||
            StrContains(sName, "vehicle", false) != -1 ||
            StrContains(sName, "ready", false) != -1 ||
            StrContains(sName, "escape", false) != -1
           )
        {
            HookSingleEntityOutput(entity, "OnTrigger", OnSpyRelayTriggered);
        }
    }
}

public Action CmdTestFinale(int client, int args)
{
    g_bIsFinale = true;
    g_bEscapeMusicStarted = false;
    ReplyToCommand(client, "Test Ultimate: Activando todas las soluciones.");
    TriggerTheNuke("Test Command");
    return Plugin_Handled;
}

public Action CmdStopSound(int client, int args)
{
    StopCurrentMusic(false);
    StopSpamTimer();
    ReplyToCommand(client, "Sounds stopped.");
    return Plugin_Handled;
}

public Action Cmd_PlayTank(int client, int args)
{
    if (g_SoundTank.Length > 0)
    {
        // Elegir una canción aleatoria
        int idx = GetRandomInt(0, g_SoundTank.Length - 1);
        g_SoundTank.GetString(idx, g_sCurrentTankSound, sizeof(g_sCurrentTankSound));
        
        PlayCustomSound(g_sCurrentTankSound);
        StartSpamTimer(); 
        ReplyToCommand(client, "[Music] Música de Tank forzada.");
    }
    return Plugin_Handled;
}

public Action Cmd_NextTankSong(int client, int args)
{
    if (g_SoundTank.Length > 0)
    {
        // Elegir una canción diferente a la actual
        int idx = GetRandomInt(0, g_SoundTank.Length - 1);
        char sNewSound[PLATFORM_MAX_PATH];
        g_SoundTank.GetString(idx, sNewSound, sizeof(sNewSound));
        
        if (g_SoundTank.Length > 1) {
            while (StrEqual(sNewSound, g_sCurrentTankSound)) {
                idx = GetRandomInt(0, g_SoundTank.Length - 1);
                g_SoundTank.GetString(idx, sNewSound, sizeof(sNewSound));
            }
        }
        
        strcopy(g_sCurrentTankSound, sizeof(g_sCurrentTankSound), sNewSound);
        
        // Reproducir la nueva canción inmediatamente
        PlayCustomSound(g_sCurrentTankSound);
        StartSpamTimer();
        ReplyToCommand(client, "[Music] Canción de Tank cambiada.");
    }
    return Plugin_Handled;
}