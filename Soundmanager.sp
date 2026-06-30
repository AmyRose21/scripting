#define PLUGIN_VERSION		"1.3"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <clientprefs>

public Plugin myinfo =
{
    name = "Map start music",
    author = "Dragokas",
    description = "Download and play one random music on map start",
    version = PLUGIN_VERSION,
    url = "https://github.com/dragokas/"
}

#define DEBUG 1

#if DEBUG
	#define CACHE_ALL_SOUNDS 1
#else
	#define CACHE_ALL_SOUNDS 0
#endif

#define CVAR_FLAGS		FCVAR_NOTIFY
#define SNDCHAN_DEFAULT SNDCHAN_STATIC // SNDCHAN_AUTO

EngineVersion g_Engine;

ArrayList g_SoundPath;
ArrayList g_SoundPathNewly;

Handle g_hCookieMusic = INVALID_HANDLE;
Handle g_hTimerMusic[MAXPLAYERS+1];

int g_iSndIdx = -1;
int g_iSndIdxNewly = -1;
int g_iCookie[MAXPLAYERS+1];

int g_iSoundVolume[MAXPLAYERS+1];

char g_sListPath[PLATFORM_MAX_PATH];
char g_sListPathNewly[PLATFORM_MAX_PATH];

bool g_bFirstConnect[MAXPLAYERS+1] = {true, ...};

ConVar g_hCvarEnable1;
ConVar g_hCvarDelay1;
ConVar g_hCvarShowMenu1;
ConVar g_hCvarUseNewly1;
ConVar g_hCvarDisplayName1;
ConVar g_hCvarPlayRoundStart1;

bool g_bEnabled;
// Custom EmitSound to allow compatibility with all game engines
void EmitSoundCustom(
	int client, 
	const char[] sound,
	int flags,
	int entity = SOUND_FROM_PLAYER,
	int channel = SNDCHAN_DEFAULT,
	int level = SNDLEVEL_NORMAL,
	
	float volume = SNDVOL_NORMAL,
	int pitch = SNDPITCH_NORMAL,
	int speakerentity = -1,
	const float origin[3] = NULL_VECTOR,
	const float dir[3] = NULL_VECTOR,
	bool updatePos = true,
	float soundtime = 0.0)
{
	int clients[1];
	clients[0] = client;
	
	if (g_Engine == Engine_Left4Dead || g_Engine == Engine_Left4Dead2)
		level = SNDLEVEL_GUNFIRE;
	
	volume = float(g_iSoundVolume[client]) / 10.0 * 4.5;
	if (volume > 1.0)
		volume = 1.0;
	
	if (g_hCvarDisplayName1.IntValue == 1)
	{
		CPrintToChat(client, "%t%s", "Playing", sound);
		CPrintToChat(client, "%t", "Info");
	}
	
	EmitSound(clients, 1, sound, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}

void StopSoundPerm(int client, const char[] sound)
{
	//PrintToChat(client, "Client %d is trying to stop sound \"%s\"", client, sound);
	int clients[1];
	clients[0] = client;
	EmitSound(clients, 1, sound, SOUND_FROM_PLAYER, SNDCHAN_DEFAULT, SNDLEVEL_GUNFIRE, SND_STOPLOOPING, 1.0, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	StopSound(client, SNDCHAN_STATIC, sound);
	StopSound(client, SNDCHAN_DEFAULT, sound);
    StopSound(client, SNDCHAN_AUTO, sound);
    StopSound(client, SNDCHAN_WEAPON, sound);
    StopSound(client, SNDCHAN_VOICE, sound);
    StopSound(client, SNDCHAN_ITEM, sound);
    StopSound(client, SNDCHAN_BODY, sound);
    StopSound(client, SNDCHAN_STREAM, sound);
    StopSound(client, SNDCHAN_VOICE_BASE, sound);
    StopSound(client, SNDCHAN_USER_BASE, sound);
} 

public void OnPluginStart()
{
	LoadTranslations("MusicMapStart.phrases");
	
	g_Engine = GetEngineVersion();
	
	CreateConVar(							"l4d_music_mapstart_version1",				PLUGIN_VERSION,	"Plugin version", FCVAR_DONTRECORD );
	g_hCvarEnable1 = CreateConVar(			"l4d_music_mapstart_enable1",				"1",			"Enable plugin (1 - On / 0 - Off)", CVAR_FLAGS );
	g_hCvarDelay1 = CreateConVar(			"l4d_music_mapstart_delay1",					"99999999999",			"Delay (in sec.) between player join and playing the music", CVAR_FLAGS );
	g_hCvarShowMenu1 = CreateConVar(			"l4d_music_mapstart_showmenu1",				"0",			"Show !music menu on round start? (1 - Yes, 0 - No)", CVAR_FLAGS );
	g_hCvarUseNewly1 = CreateConVar(			"l4d_music_mapstart_use_firstconnect_list1",	"0",			"Use separate music list for newly connected players? (1 - Yes, 0 - No)", CVAR_FLAGS );
	g_hCvarDisplayName1 = CreateConVar(		"l4d_music_mapstart_display_in_chat1",		"0",			"Display music name in chat? (1 - Yes, 0 - No)", CVAR_FLAGS );
	g_hCvarPlayRoundStart1 = CreateConVar(	"l4d_music_mapstart_play_roundstart1",		"0",			"Play music on round start as well? (1 - Yes, 0 - No, mean play on new map start only)", CVAR_FLAGS );
	
	AutoExecConfig(true,			"l4d_sound_mapstart");
	
	RegConsoleCmd("sm_sound_update1", 	Cmd_MusicUpdate, 	"Populate music list from config");
	
	g_SoundPath = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_SoundPathNewly = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	
	BuildPath(Path_SM, g_sListPath, sizeof(g_sListPath), "data/sound_mapstart.txt");
	BuildPath(Path_SM, g_sListPathNewly, sizeof(g_sListPathNewly), "data/sound_mapstart_newly.txt");
	
	if (!UpdateList())
		SetFailState("Cannot open config file \"%s\" or \"%s\"!", g_sListPath, g_sListPathNewly);
	
	g_hCookieMusic = RegClientCookie("music_mapstart_cookie", "", CookieAccess_Protected);
	
	HookConVarChange(g_hCvarEnable1,				ConVarChanged);
	GetCvars();
	
	SetRandomSeed(GetTime());
}

public void OnPluginEnd()
{
	delete g_SoundPath;
	delete g_SoundPathNewly;
	CloseHandle(g_hCookieMusic);
}

public Action Cmd_Music(int client, int args)
{
	bool bDebug = false;
	#if DEBUG
		bDebug = true;
	#endif
	
	if (args == 0)
		ShowMusicMenu1(client);
	
	if (args > 0 && (bDebug || IsClientRootAdmin(client)))
	{
		char sIdx[10];
		int iIdx;
		GetCmdArgString(sIdx, sizeof(sIdx));
		iIdx = StringToInt(sIdx);
		
		char sPath[PLATFORM_MAX_PATH];
		g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
		StopCurrentSound(client);
		PrintToChat(client, "stop - %i - %s", g_iSndIdx, sPath);
		
		if (iIdx == -1) { // play next
			iIdx = g_iSndIdx + 1;
			if (iIdx >= g_SoundPath.Length)
				iIdx = 0;
		}
		
		g_SoundPath.GetString(iIdx, sPath, sizeof(sPath));
		PrintToChat(client, "play - %i - %s", iIdx, sPath);
		PrecacheSound(sPath);
		EmitSoundCustom(client, sPath, SND_NOFLAGS);
		
		g_iSndIdx = iIdx;
	}
	return Plugin_Handled;
}

public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	InitHook();
}

void GetCvars()
{
	g_bEnabled = g_hCvarEnable1.BoolValue;
	InitHook();
}

void InitHook()
{
	static bool bHooked;
	
	if (g_bEnabled) {
		if (!bHooked) {
			HookEvent("round_start", 			Event_RoundStart,	EventHookMode_PostNoCopy);
			HookEvent("round_end", 				Event_RoundEnd,		EventHookMode_PostNoCopy);
			HookEventEx("finale_win", 			Event_RoundEnd,		EventHookMode_PostNoCopy);
			HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy);
			HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy);
			HookEvent("player_disconnect", 		Event_PlayerDisconnect,		EventHookMode_Pre);
			bHooked = true;
		}
	} else {
		if (bHooked) {
			UnhookEvent("round_start", 			Event_RoundStart,	EventHookMode_PostNoCopy);
			UnhookEvent("round_end", 			Event_RoundEnd,		EventHookMode_PostNoCopy);
			UnhookEvent("mission_lost", 		Event_RoundEnd,		EventHookMode_PostNoCopy);
			UnhookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy);
			UnhookEvent("player_disconnect", 	Event_PlayerDisconnect,		EventHookMode_Pre);
			UnhookEvent("finale_win", 			Event_RoundEnd,		EventHookMode_PostNoCopy);
			bHooked = false;
		}
	}
}

public void OnClientCookiesCached(int client)
{
	ReadCookie(client);
}

void ReadCookie(int client)
{
	char sCookie[16];
	GetClientCookie(client, g_hCookieMusic, sCookie, sizeof(sCookie));
	if(sCookie[0] != '\0')
	{
		g_iCookie[client] = StringToInt(sCookie);
	}
	g_iSoundVolume[client] = GetCookieVolume(client);
}

public void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_iCookie[client] = 0;
	g_hTimerMusic[client] = INVALID_HANDLE;
	g_bFirstConnect[client] = true;
}

public Action Cmd_MusicUpdate(int client, int args)
{
	ReadCookie(client);
	UpdateList(client);
	g_iSndIdx = -1;
	g_iSndIdxNewly = -1;
	OnMapStart();
	return Plugin_Handled;
}

bool UpdateList(int client = 0)
{
	return UpdateListDefault(client) && UpdateListNewly(client);
}

bool UpdateListDefault(int client = 0)
{
	g_SoundPath.Clear();

	char sLine[PLATFORM_MAX_PATH];
	File hFile = OpenFile(g_sListPath, "r");
	if( hFile == null )
	{
		if (client != 0)
			PrintToChat(client, "Cannot open config file \"%s\"!", g_sListPath);
		return false;
	}
	else {
		while( !hFile.EndOfFile() && hFile.ReadLine(sLine, sizeof(sLine)) )
		{
			TrimString(sLine); // walkaround against line break bug
			if (sLine[0] != '/' && sLine[1] != '/')
			{
				#if DEBUG
				if (client != 0)
					PrintToChat(client, "Added: %s", sLine);
				#endif
				g_SoundPath.PushString(sLine);
			}
		}
		CloseHandle(hFile);
	}
	return true;
}
bool UpdateListNewly(int client = 0)
{
	g_SoundPathNewly.Clear();
	
	if (g_hCvarUseNewly1.IntValue == 0) {
		return true;
	}
	
	char sLine[PLATFORM_MAX_PATH];
	File hFile = OpenFile(g_sListPathNewly, "r");
	if( hFile == null )
	{
		if (client != 0)
			PrintToChat(client, "Cannot open config file \"%s\"!", g_sListPathNewly);
		return false;
	}
	else {
		while( !hFile.EndOfFile() && hFile.ReadLine(sLine, sizeof(sLine)) )
		{
			#if DEBUG
			if (client != 0)
				PrintToChat(client, "Added: %s", sLine);
			#endif
			
			TrimString(sLine); // walkaround against line break bug
			g_SoundPathNewly.PushString(sLine);
		}
		CloseHandle(hFile);
	}
	return true;
}

public void OnClientPutInServer(int client)
{
	if (client && !IsFakeClient(client))
	{
		if (g_hTimerMusic[client] == INVALID_HANDLE)
		{
			g_hTimerMusic[client] = CreateTimer(g_hCvarDelay1.FloatValue, Timer_PlayMusic, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (g_hCvarPlayRoundStart1.IntValue == 0)
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if (g_hTimerMusic[i] == INVALID_HANDLE)
			{
				g_hTimerMusic[i] = CreateTimer(g_hCvarDelay1.FloatValue, Timer_PlayMusic, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetTimer();
}
public void OnMapEnd()
{
	ResetTimer();
}

void ResetTimer()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_hTimerMusic[i] = INVALID_HANDLE;
	}
}

public Action Timer_PlayMusic(Handle timer, int UserId)
{
	int client = GetClientOfUserId(UserId);
	g_hTimerMusic[client] = INVALID_HANDLE;
	
	if (client != 0 && IsClientInGame(client)) 
	{
		if (GetCookiePlayMusic(client))
		{
			char sPath[PLATFORM_MAX_PATH];
			
			if (g_bFirstConnect[client] && g_hCvarUseNewly1.IntValue == 1 && g_SoundPathNewly.Length > 0)
			{
				g_SoundPathNewly.GetString(g_iSndIdxNewly, sPath, sizeof(sPath));
			}
			else if (g_SoundPath.Length > 0)
			{
				g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
			}
			
			EmitSoundCustom(client, sPath, SND_NOFLAGS);
		}
		if (GetCookieShowMenu(client))
		{
			if (g_hCvarShowMenu1.BoolValue)
				ShowMusicMenu1(client);
		}
		g_bFirstConnect[client] = false;
	}
}

void ShowMusicMenu1(int client)
{
	Menu menu = new Menu(MenuHandler_MenuMusic, MENU_ACTIONS_DEFAULT);	
	menu.SetTitle("!No_disp");
	menu.AddItem("0", Translate(client, "%t", "Congratulation1"), ITEMDRAW_DISABLED);
	menu.AddItem("1", Translate(client, "%t", "Congratulation2"), ITEMDRAW_DISABLED);
	menu.AddItem("2", Translate(client, "%t", "Congratulation3"), ITEMDRAW_DISABLED);
	menu.AddItem("3", "", ITEMDRAW_DISABLED);
	menu.AddItem("5", Translate(client, "%t", "StopMusic"));
	menu.AddItem("6", Translate(client, "%t", "PlayAgain"));
	menu.AddItem("-1", Translate(client, "%t", "Settings"));
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_MenuMusic(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Select:
		{
			int client = param1;
			int ItemIndex = param2;
			
			char sItem[16];
			char sPath[PLATFORM_MAX_PATH];
			menu.GetItem(ItemIndex, sItem, sizeof(sItem));
			
			switch(StringToInt(sItem)) {
				case 5: {
					StopCurrentSound(client);
				}
				case 6: {
					StopCurrentSound(client);
					
					if (g_SoundPath.Length > 0)
					{
						g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
						EmitSoundCustom(client, sPath, SND_NOFLAGS);
					}
					else if (g_hCvarUseNewly1.IntValue == 1 && g_SoundPathNewly.Length > 0)
					{
						g_SoundPathNewly.GetString(g_iSndIdxNewly, sPath, sizeof(sPath));
						EmitSoundCustom(client, sPath, SND_NOFLAGS);
					}
				}
				case -1: {
					ShowMenuSettings1(client);
					return;
				}
			}
			ShowMusicMenu1(client);
		}
	}
}

void ShowMenuSettings1(int client)
{
	Menu menu = new Menu(MenuHandler_MenuSettings, MENU_ACTIONS_DEFAULT);
	menu.SetTitle("!musicnodisponible - %T", "Settings", client);
	
	menu.AddItem("7", Translate(client, "%t", "Volume"));
	#if (DEBUG)
		menu.AddItem("8", Translate(client, "%t", "GoNext"));
	#endif
	if (GetCookiePlayMusic(client))
	{
		menu.AddItem("9", Translate(client, "%t", "NoMusicNextMap"));
	}
	else {
		menu.AddItem("9", Translate(client, "%t", "MusicNextMap"));
	}
	if (GetCookieShowMenu(client))
	{
		menu.AddItem("10", Translate(client, "%t", "NoMenuAutostart"));
	}
	else {
		menu.AddItem("10", Translate(client, "%t", "MenuAutostart"));
	}
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}


public int MenuHandler_MenuSettings(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Cancel:
			if (param2 == MenuCancel_ExitBack)
				ShowMusicMenu1(param1);
		
		case MenuAction_Select:
		{
			int client = param1;
			int ItemIndex = param2;
			
			char sItem[16];
			menu.GetItem(ItemIndex, sItem, sizeof(sItem));
			
			switch(StringToInt(sItem)) {
				case 7: {
					ShowVolumeMenu(client);
					return;
				}
				case 8: {
					FakeClientCommand(client, "sm_music -1");
				}
				case 9: {
					g_iCookie[client] ^= 4;
					SaveCookie(client);
				}
				case 10: {
					g_iCookie[client] ^= 2;
					SaveCookie(client);
				}
			}
			ShowMenuSettings1(client);
		}
	}
}			

void StopCurrentSound(int client)
{
	char sPath[PLATFORM_MAX_PATH];
	
	if (g_SoundPath.Length > 0)
	{
		g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
		StopSoundPerm(client, sPath);
	}
	if (g_hCvarUseNewly1.IntValue == 1 && g_SoundPathNewly.Length > 0)
	{
		g_SoundPathNewly.GetString(g_iSndIdxNewly, sPath, sizeof(sPath));
		StopSoundPerm(client, sPath);
	}
}

void ShowVolumeMenu(int client)
{
	Menu menu = new Menu(MenuHandler_MenuVolume, MENU_ACTIONS_DEFAULT);	
	menu.SetTitle("%t", "NextVolume", client);
	char sItem[16];
	char sDisplay[16];
	
	for (int vol = 2; vol <= 10; vol += 2)
	{
		IntToString(vol, sItem, sizeof(sItem));
		Format(sDisplay, sizeof(sDisplay), "%s%.1f", vol == g_iSoundVolume[client] ? "> " : "", float(vol) / 10.0);
		menu.AddItem(sItem, sDisplay);
	}
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_MenuVolume(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Cancel:
			if (param2 == MenuCancel_ExitBack)
				ShowMusicMenu1(param1);
		
		case MenuAction_Select:
		{
			int client = param1;
			int ItemIndex = param2;
			
			char sItem[16];
			char sPath[PLATFORM_MAX_PATH];
			menu.GetItem(ItemIndex, sItem, sizeof(sItem));
			
			g_iSoundVolume[client] = StringToInt(sItem);
			g_iCookie[client] = (g_iCookie[client] & 0x0F) | (g_iSoundVolume[client] << 4);
			SaveCookie(client);
			g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
			StopSoundPerm(client, sPath);
			EmitSoundCustom(client, sPath, SND_NOFLAGS);
			ShowVolumeMenu(client);
		}
	}
}

stock char[] Translate(int client, const char[] format, any ...)
{
	char buffer[192];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);
	return buffer;
}

stock void ReplaceColor(char[] message, int maxLen)
{
    ReplaceString(message, maxLen, "{white}", "\x01", false);
    ReplaceString(message, maxLen, "{cyan}", "\x03", false);
    ReplaceString(message, maxLen, "{orange}", "\x04", false);
    ReplaceString(message, maxLen, "{green}", "\x05", false);
}

stock void CPrintToChat(int iClient, const char[] format, any ...)
{
    char buffer[192];
    SetGlobalTransTarget(iClient);
    VFormat(buffer, sizeof(buffer), format, 3);
    ReplaceColor(buffer, sizeof(buffer));
    PrintToChat(iClient, "\x01%s", buffer);
}

public void OnMapStart()
{
	// remove already played track from the list
	if (g_iSndIdx != -1 && g_SoundPath.Length > 0)
	{
		g_SoundPath.Erase(g_iSndIdx);
	}
	if (g_iSndIdxNewly != -1 && g_hCvarUseNewly1.IntValue == 1 && g_SoundPathNewly.Length > 0)
	{
		g_SoundPathNewly.Erase(g_iSndIdxNewly);
	}
	
	// fill the list if it become empty
	if (g_SoundPath.Length == 0)
	{
		UpdateListDefault();
	}
	if (g_hCvarUseNewly1.IntValue == 1 && g_SoundPathNewly.Length == 0)
	{
		UpdateListNewly();
	}
	
	// select random track
	if (g_SoundPath.Length > 0)
	{
		g_iSndIdx = GetRandomInt(0, g_SoundPath.Length - 1);
	}
	if (g_hCvarUseNewly1.IntValue == 1 && g_SoundPathNewly.Length > 0)
	{
		g_iSndIdxNewly = GetRandomInt(0, g_SoundPathNewly.Length - 1);
	}
	
	char sSoundPath[PLATFORM_MAX_PATH];
	char sDLPath[PLATFORM_MAX_PATH];
	char sSoundPathNewly[PLATFORM_MAX_PATH];
	char sDLPathNewly[PLATFORM_MAX_PATH];
	
	#if CACHE_ALL_SOUNDS
		if (g_SoundPath.Length > 0)
		{
			for (int i = 0; i < g_SoundPath.Length; i++) {
				g_SoundPath.GetString(i, sSoundPath, sizeof(sSoundPath));
				Format(sDLPath, sizeof(sDLPath), "sound/%s", sSoundPath);
				AddFileToDownloadsTable(sDLPath);
				#if (DEBUG)
					PrintToChatAll("added to downloads: %s", sDLPath);
				#endif
				PrecacheSound(sSoundPath, true);
			}
		}
		if (g_hCvarUseNewly1.IntValue == 1 && g_SoundPathNewly.Length > 0)
		{
			for (int i = 0; i < g_SoundPathNewly.Length; i++) {
				g_SoundPathNewly.GetString(i, sSoundPathNewly, sizeof(sSoundPathNewly));
				Format(sDLPathNewly, sizeof(sDLPathNewly), "sound/%s", sSoundPathNewly);
				AddFileToDownloadsTable(sDLPathNewly);
				#if (DEBUG)
					PrintToChatAll("added to downloads: %s", sDLPathNewly);
				#endif
				PrecacheSound(sSoundPathNewly, true);
			}
		}
	#else
		if (g_SoundPath.Length > 0)
		{
			g_SoundPath.GetString(g_iSndIdx, sSoundPath, sizeof(sSoundPath));
			Format(sDLPath, sizeof(sDLPath), "sound/%s", sSoundPath);
			AddFileToDownloadsTable(sDLPath);
			PrecacheSound(sSoundPath, true);
		}
		if (g_hCvarUseNewly1.IntValue == 1 && g_SoundPathNewly.Length > 0)
		{
			g_SoundPathNewly.GetString(g_iSndIdxNewly, sSoundPathNewly, sizeof(sSoundPathNewly));
			Format(sDLPathNewly, sizeof(sDLPathNewly), "sound/%s", sSoundPathNewly);
			if (strcmp(sDLPathNewly, sDLPath) != 0)
			{
				AddFileToDownloadsTable(sDLPathNewly);
				PrecacheSound(sSoundPathNewly, true);
			}
		}
	#endif
}

bool IsCookieLoaded(int client)
{
	return (g_iCookie[client] & 1) != 0;
}
bool GetCookieShowMenu(int client)
{
	if (!IsCookieLoaded(client))
		return true;
	return (g_iCookie[client] & 2) != 0;
}
bool GetCookiePlayMusic(int client)
{
	if (!IsCookieLoaded(client))
		return true;
	return (g_iCookie[client] & 4) != 0;
}
int GetCookieVolume(int client)
{
	if (!IsCookieLoaded(client))
		return 10;
	int volume = (g_iCookie[client] & 0xF0) >> 4;
	return volume == 0 ? 10 : volume;
}
void SaveCookie(int client)
{
	if (client < 1 || !IsClientInGame(client) || IsFakeClient(client))
		return;
	
	char sCookie[16];
	g_iCookie[client] |= 1;
	IntToString(g_iCookie[client], sCookie, sizeof(sCookie));
	
	if (AreClientCookiesCached(client)) {
		SetClientCookie(client, g_hCookieMusic, sCookie);
	}
}



stock bool IsClientRootAdmin(int client)
{
	return ((GetUserFlagBits(client) & ADMFLAG_ROOT) != 0);
}