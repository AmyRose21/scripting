#pragma semicolon 1
#include <sourcemod>
#include <colors>

public Plugin ListPlayerPluginInfo =
{
    name = "List Player Info",
    author = "Pure_*",
    description = "List Player's clientID and name",
    version = "0.1",
    url = "N/A"
};

public OnPluginStart()
{
    RegAdminCmd("sm_lsplayer", ListClientID, ADMFLAG_SLAY, "List Player Infomation");
}



public Action ListClientID(int client, int args)
{
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i))
        {
            CPrintToChat(client, "Name: {blue}%N {default}ClientID: {olive}%d {default}Fake?: {green}%d {default}Spectetor: {green}%d", i, i, IsFakeClient(i), GetClientRealID(i));
        }
    }
    return Plugin_Continue;
}


int GetClientRealID(int client)
{
	if(HasEntProp(client, Prop_Send, "m_humanSpectatorUserID"))
    {
        int id = GetClientOfUserId(GetEntProp(client, Prop_Send, "m_humanSpectatorUserID"));
        if(id != 0)
        {
            return id;
        }
        else
        {
            return client;
        }
    }
	return 0;
}