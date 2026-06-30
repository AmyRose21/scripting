#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.1"

ConVar BindModeCVAR;
ConVar BindAutoCVAR;

public Plugin myinfo =
{
    name = "Key Binder",
    author = "hihi1210 (Updated)",
    description = "Simple works!",
    version = PLUGIN_VERSION,
    url = "CPT"
};

public void OnPluginStart()
{
    char game_name[64];
    GetGameFolderName(game_name, sizeof(game_name));
    if (!StrEqual(game_name, "left4dead", false) && !StrEqual(game_name, "left4dead2", false))
    {
        SetFailState("Key Binder supports Left 4 Dead or Left 4 Dead 2 only.");
    }
    
    RegConsoleCmd("sm_bind", cmd_BindMenu);
    
    CreateConVar("l4d2_bind_version", PLUGIN_VERSION, "Version of L4D2 Bind", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    BindModeCVAR = CreateConVar("l4d2_bind_mode", "1", "Bind Mode: (0: auto bind when player join, 1: player need to confirm it using menu)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    BindAutoCVAR = CreateConVar("l4d2_bind_autodisplay", "0", "Auto display menu after the player join the server (only work with l4d2_bind_mode 1)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
}

public void OnClientPostAdminCheck(int client)
{
    if (IsFakeClient(client))
        return;

    if (BindAutoCVAR.IntValue == 1 && BindModeCVAR.IntValue == 1)
    {
        CreateTimer(40.0, Timer_ShowBind, client);
    }
    
    if (BindModeCVAR.IntValue == 0)
    {
        ApplyBinds(client);
    }
}

public Action Timer_ShowBind(Handle timer, any client)
{
    if (IsClientInGame(client))
    {
        BindMenu(client);
    }
    return Plugin_Stop;
}

public Action cmd_BindMenu(int client, int args)
{
    if (client > 0 && IsClientInGame(client))
    {
        BindMenu(client);
    }
    return Plugin_Handled;
}

void BindMenu(int client)
{
    Panel TeamPanel = new Panel();
    TeamPanel.SetTitle("Do you want to bind your buttons?");
    TeamPanel.DrawText("Information:");
    
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), "configs/bind/panel.txt");
    
    File file = OpenFile(sPath, "rb");
    if (file != null)
    {
        char readData[256];
        while (!file.EndOfFile() && file.ReadLine(readData, sizeof(readData)))
        {
            TrimString(readData);
            if (readData[0] != '\0')
            {
                TeamPanel.DrawText(readData);
            }
        }
        delete file;
    }
    else
    {
        LogError("Could not open file: %s", sPath);
    }

    TeamPanel.DrawItem("Yes");
    TeamPanel.DrawItem("No");
    TeamPanel.Send(client, BindMenu_Handler, 30);
    
    delete TeamPanel;
}

public int BindMenu_Handler(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        switch (param2)
        {
            case 1: // Yes
            {
                ApplyBinds(param1);
            }
            case 2: // No
            {
                // Do nothing
            }
        }
    }
    return 0;
}

void ApplyBinds(int client)
{
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), "configs/bind/bind.txt");
    
    File file = OpenFile(sPath, "rb");
    if (file == null)
    {
        LogError("Could not open file: %s", sPath);
        return;
    }
    
    char readData[256];
    while (!file.EndOfFile() && file.ReadLine(readData, sizeof(readData)))
    {
        TrimString(readData);
        // Ignorar líneas vacías o comentarios simples
        if (readData[0] != '\0' && readData[0] != '/' && readData[0] != '#')
        {
            ClientCommand(client, readData);
        }
    }
    delete file;
}