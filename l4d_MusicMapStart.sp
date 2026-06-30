#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION		"1.5h-2024/1/8"

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <sdktools_sound>
#pragma newdecls required

public Plugin myinfo =
{
    name = "Round start music",
    author = "Dragokasm & HarryPotter",
    description = "Download and play custom music in game",
    version = PLUGIN_VERSION,
    url = "https://forums.alliedmods.net/showthread.php?p=2644771"
}

#define CVAR_FLAGS		FCVAR_NOTIFY

ConVar g_hCvarEnable, g_hCvarRoundStartPlay, g_hCvarRoundStartDelay, g_hCvarJRoundStartMenu, g_hCvarJoinServerPlay,
	g_hCvarJoinServerDelay, g_hCvarJoinServerMenu, g_hCvarDownloadMusicNumber,
	g_hCvarPlayMusicCoolDown, g_hCvarPlayMusicAccess;
int g_iRoundStart, g_iPlayerSpawn, g_iDownloadMusicNumber;
bool g_bEnabled, g_bCvarRoundStartPlay, g_bCvarJRoundStartMenu, g_bCvarJoinServerPlay, g_bCvarJoinServerMenu;
float g_fCvarRoundStartDelay, g_fCvarJoinServerDelay, g_fCvarPlayMusicCoolDown;
char g_sAccesslvl[AdminFlags_TOTAL];

ArrayList g_aFileSoundPath;
ArrayList g_aSoundPath;
ArrayList g_aFileNameTag;
ArrayList g_aNameTag;
ArrayList g_aDurations;

char 
	g_sListPath[PLATFORM_MAX_PATH];

int 
	g_iGlobalPlayMusicIndex = -1;

bool 
	g_bClientMuteMp3[MAXPLAYERS+1];

int 
	g_iMenuPosition[MAXPLAYERS+1] = {0},
	g_iClientIdx[MAXPLAYERS+1] = {0};

float 
	g_fSoundVolume[MAXPLAYERS+1],
	g_fPlayMusicTime;

Handle 
	g_hJoinServerTimer[MAXPLAYERS+1],
	PlayMusicRoundStartTimer;

Handle g_hMusicTimer = INVALID_HANDLE;
public void OnPluginStart()
{
	LoadTranslations("MusicMapStart.phrases");
	
	CreateConVar(								"l4d_music_mapstart_version",				PLUGIN_VERSION,	"Plugin version", FCVAR_DONTRECORD);
	g_hCvarEnable = CreateConVar(				"l4d_music_mapstart_enable",				"1",			"Enable plugin. (1 - On / 0 - Off)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRoundStartPlay = CreateConVar(		"l4d_music_mapstart_play_roundstart",		"1",			"Play the music to everyone on round starts. (1 - Yes, 0 - No)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRoundStartDelay = CreateConVar(		"l4d_music_mapstart_delay_roundstart",		"1.0",			"Delay (in sec.) playing the music on round starts.", CVAR_FLAGS, true, 0.0);
	g_hCvarJRoundStartMenu = CreateConVar(		"l4d_music_mapstart_showmenu_roundstart",	"1",			"Show !music menu on round start? (1 - Yes, 0 - No)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarJoinServerPlay = CreateConVar(		"l4d_music_mapstart_play_joinserver",		"1",			"Play the music to client after player joins server? (1 - Yes, 0 - No)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarJoinServerDelay = CreateConVar(		"l4d_music_mapstart_delay_joinserver",		"3.0",			"Delay (in sec.) playing the music to client after player joins server.", CVAR_FLAGS, true, 0.0);
	g_hCvarJoinServerMenu = CreateConVar(		"l4d_music_mapstart_showmenu_joinserver",	"0",			"Show !music menu after player joins server? (1 - Yes, 0 - No)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarDownloadMusicNumber = CreateConVar(	"l4d_music_mapstart_download_number",		"3",			"How many random music files to download from 'data/music_mapstart.txt' each map. [0 - all at once]", CVAR_FLAGS, true, 0.0);
	g_hCvarPlayMusicCoolDown = CreateConVar(	"l4d_music_mapstart_playmusic_cooldown",	"3.0",			"Time in seconds all players can not play music everyone can hear agagin from !music menu. (0=off)", CVAR_FLAGS, true, 0.0);
	g_hCvarPlayMusicAccess = CreateConVar(		"l4d_music_mapstart_playmusic_access_flag", "", 			"Players with these flags have access to play music that everyone can hear. (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
	
	AutoExecConfig(true, "l4d_MusicMapStart");

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged);
	g_hCvarRoundStartPlay.AddChangeHook(ConVarChanged);
	g_hCvarRoundStartDelay.AddChangeHook(ConVarChanged);
	g_hCvarJRoundStartMenu.AddChangeHook(ConVarChanged);
	g_hCvarJoinServerPlay.AddChangeHook(ConVarChanged);
	g_hCvarJoinServerDelay.AddChangeHook(ConVarChanged);
	g_hCvarJoinServerMenu.AddChangeHook(ConVarChanged);
	g_hCvarDownloadMusicNumber.AddChangeHook(ConVarChanged);
	g_hCvarPlayMusicCoolDown.AddChangeHook(ConVarChanged);
	g_hCvarPlayMusicAccess.AddChangeHook(ConVarChanged);


	RegConsoleCmd("sm_music", 			Cmd_Music, 			"Music menu");
	RegAdminCmd("sm_music_update", 	Cmd_MusicUpdate, ADMFLAG_BAN, "Update music list from config");
	RegConsoleCmd("mp3off", Cmd_MusicOff, "Turn off music when round start/join server");
	RegConsoleCmd("mp3on", Cmd_MusicOn, "Turn on music when round start/join server");

	g_aFileSoundPath = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_aSoundPath = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_aFileNameTag = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_aNameTag = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_aDurations = new ArrayList();

	
	BuildPath(Path_SM, g_sListPath, sizeof(g_sListPath), "data/music_mapstart.txt");

	HookEvent("round_start", 			Event_RoundStart,	EventHookMode_PostNoCopy);
	HookEvent("player_spawn", Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("mission_lost", Event_RoundEnd); //wipe out
	HookEvent("map_transition", Event_RoundEnd); //mission complete
	HookEvent("player_disconnect", 		Event_PlayerDisconnect,		EventHookMode_Pre);

	for (int j = 1; j <= MaxClients; j++)
	{
		g_fSoundVolume[j] = 1.0;
		g_bClientMuteMp3[j] = false;
	}
		
	SetRandomSeed(GetTime());
}

public void OnPluginEnd()
{
	ResetPlugin();
	delete g_aFileSoundPath;
	delete g_aSoundPath;
	delete g_aFileNameTag;
	delete g_aNameTag;
}

public void OnMapEnd()
{
    // Detener música personalizada para todos
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i))
        {
            StopSoundCustom(i);
        }
    }

    ResetPlugin();
    ResetTimer();

    // Forzar reactivación de la música del juego
    SetGameMusicManager(true);

    delete PlayMusicRoundStartTimer;
}


public void OnConfigsExecuted()
{
	UpdateList();

	if (g_aFileSoundPath.Length == 0)
		return;
	
	char sSoundPath[PLATFORM_MAX_PATH], sNameTag[PLATFORM_MAX_PATH];
	char sDLPath[PLATFORM_MAX_PATH];
	
	delete g_aSoundPath;
	g_aSoundPath = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	delete g_aNameTag;
	g_aNameTag = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

	int iChosenIndex, temp, iRand = -1, iTotalMusicsInFile = g_aFileSoundPath.Length;
	
	bool bDownloadAll;
	if (g_iDownloadMusicNumber == 0 || iTotalMusicsInFile <= g_iDownloadMusicNumber)
	{
		bDownloadAll = true;
	}
	else
	{
		bDownloadAll = false;
	}
	
	if(bDownloadAll)
	{
		g_aSoundPath = g_aFileSoundPath.Clone();
		g_aNameTag = g_aFileNameTag.Clone();
	}
	else
	{
		int[] iArray = new int[iTotalMusicsInFile];
		for (int i = 0; i < iTotalMusicsInFile; ++i)
			iArray[i] = i;
		
		for (int i = 0; i < g_iDownloadMusicNumber; i++) //for example, We need 2 random musics from music list
		{
			iRand = GetRandomInt(0, iTotalMusicsInFile-1); //Generate random number
			iChosenIndex = iArray[iRand];
			/*swap*/
			temp = iArray[iTotalMusicsInFile-1];
			iArray[iTotalMusicsInFile-1] = iArray[iRand];
			iArray[iRand] = temp;
			iTotalMusicsInFile-- ;
			/**/
			g_aFileSoundPath.GetString(iChosenIndex, sSoundPath, sizeof(sSoundPath));
			g_aSoundPath.PushString(sSoundPath);

			g_aFileNameTag.GetString(iChosenIndex, sNameTag, sizeof(sNameTag));
			g_aNameTag.PushString(sNameTag);
		}
	}
					
	
	for (int i = 0; i < g_aSoundPath.Length; i++) {
		g_aSoundPath.GetString(i, sSoundPath, sizeof(sSoundPath));
		Format(sDLPath, sizeof(sDLPath), "sound/%s", sSoundPath);
		AddFileToDownloadsTable(sDLPath);
		PrecacheSound(sSoundPath);
		//LogMessage("added to downloads: %s", sDLPath);
	}
	
	int i;
	for(i = sizeof(sSoundPath) -1 ; i >= 0; --i )
	{
		if(sSoundPath[i] == '/') break;
	}
	
	g_iGlobalPlayMusicIndex = -1;
}

public void OnClientPutInServer(int client)
{
	if( IsFakeClient (client) || !g_bEnabled || !g_bCvarJoinServerPlay || PlayMusicRoundStartTimer != null) return;

	g_fPlayMusicTime = 0.0;

	delete g_hJoinServerTimer[client];
	g_hJoinServerTimer[client] = CreateTimer(g_fCvarJoinServerDelay, Timer_PlayMusicNewPlayer, client);
}

public void OnClientDisconnect(int client)
{
    delete g_hJoinServerTimer[client];
} 

void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bEnabled = g_hCvarEnable.BoolValue;
	g_bCvarRoundStartPlay = g_hCvarRoundStartPlay.BoolValue;
	g_fCvarRoundStartDelay = g_hCvarRoundStartDelay.FloatValue;
	g_bCvarJRoundStartMenu = g_hCvarJRoundStartMenu.BoolValue;
	g_bCvarJoinServerPlay = g_hCvarJoinServerPlay.BoolValue;
	g_fCvarJoinServerDelay = g_hCvarJoinServerDelay.FloatValue;
	g_bCvarJoinServerMenu = g_hCvarJoinServerMenu.BoolValue;
	g_iDownloadMusicNumber = g_hCvarDownloadMusicNumber.IntValue;
	g_fCvarPlayMusicCoolDown = g_hCvarPlayMusicCoolDown.FloatValue;
	g_hCvarPlayMusicAccess.GetString(g_sAccesslvl,sizeof(g_sAccesslvl));
}

Action Cmd_MusicOff(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[TS] This command cannot be used by server.");
		return Plugin_Handled;
	}

	g_bClientMuteMp3[client] = true;
	PrintToChat(client, "%T", "UnMute", client);
	return Plugin_Handled;
}

Action Cmd_MusicOn(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[TS] This command cannot be used by server.");
		return Plugin_Handled;
	}

	g_bClientMuteMp3[client] = false;
	PrintToChat(client, "%T", "Mute", client);
	return Plugin_Handled;
}

Action Cmd_MusicUpdate(int client, int args)
{
	UpdateList(client);
	return Plugin_Handled;
}

Action Cmd_Music(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[TS] This command cannot be used by server.");
		return Plugin_Handled;
	}

	if(g_bEnabled)
	{
		ShowMusicMenu(client);
	}
	return Plugin_Handled;
}

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_fSoundVolume[client] = 1.0; // restore defaults.
	g_iClientIdx[client] = 0;
	g_iMenuPosition[client] = 0;
}

bool UpdateList(int client = 0)
{
	char sSoundPath[PLATFORM_MAX_PATH];
	char buffer[PLATFORM_MAX_PATH];

	if (!FileExists(g_sListPath))
		SetFailState("Cannot open config file \"%s\"!", g_sListPath);

	File hFile = OpenFile(g_sListPath, "r");
	if( hFile == null )
	{
		if (client != 0)
			PrintToChat(client, "Cannot open config file \"%s\"!", g_sListPath);

		delete hFile;
		return false;
	}

	delete g_aFileSoundPath;
	g_aFileSoundPath = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	
	delete g_aFileNameTag;
	g_aFileNameTag = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

	while( !hFile.EndOfFile() && hFile.ReadLine(buffer, sizeof(buffer)) )
	{
		int len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';
		
		TrimString(buffer); // walkaround against line break bug

		SplitString(buffer, " TAG-", sSoundPath, sizeof(sSoundPath));
char sDurationStr[16];
SplitString(buffer, " TAG-", sSoundPath, sizeof(sSoundPath));
g_aFileSoundPath.PushString(sSoundPath);

ReplaceString(buffer, sizeof(buffer), sSoundPath, "", false);
ReplaceString(buffer, sizeof(buffer), " TAG- ", "", false);

// Buscar duración al final (separada por '-')
char sNameAndTime[PLATFORM_MAX_PATH];
strcopy(sNameAndTime, sizeof(sNameAndTime), buffer);
TrimString(sNameAndTime);

char sNameOnly[PLATFORM_MAX_PATH];
float fDuration = 30.0; // valor por defecto

int idx = FindCharInString(sNameAndTime, '-', true); // busca último '-'
if (idx != -1)
{
    strcopy(sNameOnly, sizeof(sNameOnly), sNameAndTime);
    sNameOnly[idx] = '\0';
    strcopy(sDurationStr, sizeof(sDurationStr), sNameAndTime[idx+1]);
    TrimString(sDurationStr);
    fDuration = StringToFloat(sDurationStr);
}
else
{
    strcopy(sNameOnly, sizeof(sNameOnly), sNameAndTime);
}

TrimString(sNameOnly);
g_aFileNameTag.PushString(sNameOnly);
g_aDurations.Push(fDuration);


		if (client != 0)
			PrintToChat(client, "Added: %s - %s", sSoundPath, buffer);
	}

	if(g_aFileSoundPath.Length == 0)
	{
		if (client != 0) PrintToChat(client, "Why No Any Music? You Fool!!!");
	}

	delete hFile;
	return true;
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_fPlayMusicTime = 0.0;

	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    // Detener música personalizada para todos los jugadores
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i))
        {
            StopSoundCustom(i); // StopSoundCustom debe cancelar el g_hMusicTimer también
        }
    }

    ResetPlugin();
    ResetTimer();

    // Forzar reactivación de la música del juego por si algo quedó pendiente
    SetGameMusicManager(true);

    delete PlayMusicRoundStartTimer;
}


Action tmrStart(Handle timer)
{
	ResetPlugin();
	ResetTimer();

	if(g_bEnabled && g_bCvarRoundStartPlay)
	{
		delete PlayMusicRoundStartTimer;
		PlayMusicRoundStartTimer = CreateTimer(g_fCvarRoundStartDelay, Timer_PlayMusicRoundStart);	
	}

	return Plugin_Continue;
}

Action Timer_PlayMusicRoundStart(Handle timer)
{
	char sPath[PLATFORM_MAX_PATH];

	int iRandomIdx = GetRandomInt(0, g_aSoundPath.Length - 1);
	g_aSoundPath.GetString(iRandomIdx, sPath, sizeof(sPath));
	for (int j = 1; j <= MaxClients; j++) g_iClientIdx[j] = iRandomIdx;

	for (int j = 1; j <= MaxClients; j++) 
	{
		if (IsClientInGame(j) && !IsFakeClient(j))
		{
			StopSoundCustom(j);
			
			if(!g_bClientMuteMp3[j])
			{
				EmitSoundCustom(j, sPath);
				PrintToChat(j, "%T", "Mute", j);
				if (g_bCvarJRoundStartMenu)
					ShowMusicMenu(j, false);
			}
		}
	}

	PlayMusicRoundStartTimer = null;
	return Plugin_Continue;
}

Action Timer_PlayMusicNewPlayer(Handle timer, int client)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		char sPath[PLATFORM_MAX_PATH];
		
		int iRandomIdx = GetRandomInt(0, g_aSoundPath.Length - 1);
		g_aSoundPath.GetString(iRandomIdx, sPath, sizeof(sPath));
		g_iClientIdx[client] = iRandomIdx;

		StopSoundCustom(client);
		
		if(!g_bClientMuteMp3[client])
		{
			
			EmitSoundCustom(client, sPath);
			if (g_bCvarJoinServerMenu)
				ShowMusicMenu(client, false);
		}
	}

	g_hJoinServerTimer[client] = null;
	return Plugin_Continue;
}

void ShowMusicMenu(int client, bool forever = true)
{
	Menu menu = new Menu(MenuHandler_MenuMusic, MENU_ACTIONS_DEFAULT);	
	menu.SetTitle("%T", "Music Menu", client);
	menu.AddItem("1", Translate(client, "%t", "StopMusic"));
	menu.AddItem("2", Translate(client, "%t", "PlayAgain"));
	menu.AddItem("3", Translate(client, "%t", "Volume"));
	menu.AddItem("4", Translate(client, "%t", "ChooseMusic"));
	
	if(HasAccess(client, g_sAccesslvl))
		menu.AddItem("5", Translate(client, "%t", "PlayMusic"));
	
	menu.Pagination = MENU_NO_PAGINATION;
	menu.ExitButton = true;
	if (forever) menu.Display(client, MENU_TIME_FOREVER);
	else menu.Display(client, 20);
}

int MenuHandler_MenuMusic(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Select:
		{
			int client = param1;
			int ItemIndex = param2;
			
			char sItem[32];
			char sPath[PLATFORM_MAX_PATH];
			menu.GetItem(ItemIndex, sItem, sizeof(sItem));
			
			switch(StringToInt(sItem)) {
				case 1: {
					StopSoundCustom(client);
				}
				case 2: {
					StopSoundCustom(client);

					g_aSoundPath.GetString(g_iClientIdx[client], sPath, sizeof(sPath));
					EmitSoundCustom(client, sPath);
				}
				case 3: {
					ShowVolumeMenu(client);
					return 0;
				}
				case 4: {
					ShowAllMenu(client, false);
					return 0;
				}
				case 5: {
					ShowAllMenu(client, true);
					return 0;
				}
			}
			ShowMusicMenu(client);
		}
	}

	return 0;
}

void ShowVolumeMenu(int client)
{
	Menu menu = new Menu(MenuHandler_MenuVolume, MENU_ACTIONS_DEFAULT);	
	menu.SetTitle("%T", "NextVolume", client);
	menu.AddItem("0.0", "0.0");
	menu.AddItem("0.2", "0.2");
	menu.AddItem("0.4", "0.4");
	menu.AddItem("0.6", "0.6");
	menu.AddItem("0.8", "0.8");
	menu.AddItem("1.0", "1.0");

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int MenuHandler_MenuVolume(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Cancel:
			if (param2 == MenuCancel_ExitBack)
				ShowMusicMenu(param1);
		
		case MenuAction_Select:
		{
			int client = param1;
			int ItemIndex = param2;
			
			char sItem[32];
			char sPath[PLATFORM_MAX_PATH];
			
			StopSoundCustom(client);
			
			menu.GetItem(ItemIndex, sItem, sizeof(sItem));
			g_fSoundVolume[client] = StringToFloat(sItem);
			g_aSoundPath.GetString(g_iClientIdx[client], sPath, sizeof(sPath));
			EmitSoundCustom(client, sPath);
			
			ShowMusicMenu(client);
		}
	}

	return 0;
}

void ShowAllMenu(int client, bool music_type)
{
	Menu menu = null;	
	char index[4];
	if(music_type)
	{
		menu = new Menu(MenuHandler_MenuPlayMusic, MENU_ACTIONS_DEFAULT);
		menu.SetTitle("%T", "PlayMusic", client);
	}
	else
	{
		menu = new Menu(MenuHandler_MenuChooseMusic, MENU_ACTIONS_DEFAULT);
		menu.SetTitle("%T", "ChooseMusic", client);
	}
	

	char sName[PLATFORM_MAX_PATH];
	for (int i = 0; i < g_aSoundPath.Length; i++) {
		IntToString(i, index, sizeof(index));
		g_aNameTag.GetString(i, sName, sizeof(sName));
		menu.AddItem(index, sName);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.DisplayAt(client, g_iMenuPosition[client], MENU_TIME_FOREVER);
}

int MenuHandler_MenuPlayMusic(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Cancel:
			if (param2 == MenuCancel_ExitBack)
				ShowMusicMenu(param1);
		
		case MenuAction_Select:
		{
			int client = param1;
			if(g_fPlayMusicTime < GetEngineTime())
			{
				char sItem[32];
				char sPath[PLATFORM_MAX_PATH];
				menu.GetItem(param2, sItem, sizeof(sItem));
				int MusicIndex = StringToInt(sItem);
				
				g_aSoundPath.GetString(MusicIndex, sPath, sizeof(sPath));
		
				char sName[PLATFORM_MAX_PATH];
				g_aNameTag.GetString(MusicIndex, sName, sizeof(sName));
				StopTankMusicAll();
				for (int j = 1; j <= MaxClients; j++) 
				{
					if (!IsClientInGame(j) || IsFakeClient(j)) continue;

					StopSoundCustom(j);
					StopSound(j, SNDCHAN_AUTO, sPath);
					if(!g_bClientMuteMp3[j])
					{
						EmitSoundCustom(j, sPath);
					}

					CPrintToChat(j, "%T", "Request Song", j, client, sName);
					g_fPlayMusicTime = GetEngineTime() + g_fCvarPlayMusicCoolDown;
				}
				
				g_iGlobalPlayMusicIndex = MusicIndex;
			}
			else
			{
				CPrintToChat(client, "%T", "Too quickly", client, g_fCvarPlayMusicCoolDown);
			}

			g_iMenuPosition[client] = menu.Selection; 
			ShowAllMenu(client, true);
		}
	}

	return 0;
}


int MenuHandler_MenuChooseMusic(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Cancel:
			if (param2 == MenuCancel_ExitBack)
				ShowMusicMenu(param1);
		
		case MenuAction_Select:
		{
			int client = param1;

			char sItem[32];
			char sPath[PLATFORM_MAX_PATH];
			menu.GetItem(param2, sItem, sizeof(sItem));
			int MusicIndex = StringToInt(sItem);
			
			StopSoundCustom(client);

			g_aSoundPath.GetString(MusicIndex, sPath, sizeof(sPath));
			g_iClientIdx[client] = MusicIndex;
	
			StopSound(client, SNDCHAN_AUTO, sPath);
			EmitSoundCustom(client, sPath);

			g_iMenuPosition[client] = menu.Selection; 
			ShowAllMenu(client, false);
		}
	}

	return 0;
}

char[] Translate(int client, const char[] format, any ...)
{
	char buffer[192];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);
	return buffer;
}

void EmitSoundCustom(int client, const char[] sound)
{
    StopTankMusic(client);
    SetGameMusicManager(false);

    float volume = g_fSoundVolume[client];
    EmitSoundToClient(client, sound, _, SNDCHAN_AUTO, SNDLEVEL_CONVO, _, volume, _, _, _, _, _, _);

    // Cancelar temporizador anterior si existe
    if (g_hMusicTimer != INVALID_HANDLE && IsValidHandle(g_hMusicTimer))
    {
        delete g_hMusicTimer;
        g_hMusicTimer = INVALID_HANDLE;
    }

    // Buscar duración de la canción
    int index = g_iClientIdx[client];
    if (index >= 0 && index < g_aDurations.Length)
    {
        float fDuration = g_aDurations.Get(index);
        if (fDuration > 0.0)
        {
            g_hMusicTimer = CreateTimer(fDuration, Timer_EnableMusicManager);
        }
    }
}







void StopSoundCustom(int client)
{
    static char sPath[PLATFORM_MAX_PATH];

    if (g_iGlobalPlayMusicIndex >= 0)
    {
        g_aSoundPath.GetString(g_iGlobalPlayMusicIndex, sPath, sizeof(sPath));
        StopSound(client, SNDCHAN_AUTO, sPath);
    }

    g_aSoundPath.GetString(g_iClientIdx[client], sPath, sizeof(sPath));
    StopSound(client, SNDCHAN_AUTO, sPath);

    // Cancelar el temporizador si sigue activo
    if (g_hMusicTimer != INVALID_HANDLE && IsValidHandle(g_hMusicTimer))
    {
        delete g_hMusicTimer;
        g_hMusicTimer = INVALID_HANDLE;
    }

    SetGameMusicManager(true);
}



void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
	SetGameMusicManager(true);
}

void ResetTimer()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_hJoinServerTimer[i] != null && IsValidHandle(g_hJoinServerTimer[i]))
        {
            delete g_hJoinServerTimer[i];
            g_hJoinServerTimer[i] = null;
        }
    }

    // Timer global de música
    if (g_hMusicTimer != INVALID_HANDLE && IsValidHandle(g_hMusicTimer))
    {
        delete g_hMusicTimer;
        g_hMusicTimer = INVALID_HANDLE;
    }

    // Timer de música de ronda
    if (PlayMusicRoundStartTimer != null && IsValidHandle(PlayMusicRoundStartTimer))
    {
        delete PlayMusicRoundStartTimer;
        PlayMusicRoundStartTimer = null;
    }
}



bool HasAccess(int client, char[] sAcclvl)
{
	// no permissions set
	if (strlen(sAcclvl) == 0)
		return true;

	else if (StrEqual(sAcclvl, "-1"))
		return false;

	// check permissions
	if ( GetUserFlagBits(client) & ReadFlagString(sAcclvl) )
	{
		return true;
	}

	return false;
}


// Detiene la música del Tank sin usar Left4DHooks
void StopTankMusic(int client)
{
    if (!IsClientInGame(client) || IsFakeClient(client))
        return;

    // Lista de posibles rutas o eventos de música del Tank
    static const char tankSounds[][] = {
        "music/tank/tank.wav",
        "music/tank/tank_midpoint.wav",
        "music/tank/tank_brothers.wav",
        "music/tank/tank_finale.wav",
        "Event.Tank",
        "Event.TankMidpoint",
        "Event.TankBrothers"
    };

    // Algunos compiladores no definen SNDCHAN_MUSIC, así que usamos 5 manualmente
    #define SNDCHAN_MUSIC 5

    for (int i = 0; i < sizeof(tankSounds); i++)
    {
        StopSound(client, SNDCHAN_AUTO, tankSounds[i]);
        StopSound(client, SNDCHAN_STATIC, tankSounds[i]);
        StopSound(client, SNDCHAN_MUSIC, tankSounds[i]);
    }
}

// Detiene la música del Tank para todos los jugadores conectados
void StopTankMusicAll()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        StopTankMusic(i);
    }
}


void SetGameMusicManager(bool enable)
{
    if (enable)
        ServerCommand("sm_cvar music_manager 1");
    else
        ServerCommand("sm_cvar music_manager 0");
}

public Action Timer_EnableMusicManager(Handle timer)
{
    SetGameMusicManager(true);
    g_hMusicTimer = INVALID_HANDLE;
    return Plugin_Stop;
}
