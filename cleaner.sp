#pragma semicolon 1 
#include <PTaH> 

public Plugin myinfo =
{
	name = "Cleaner",
	author = "Phoenix (˙·٠●Феникс●٠·˙)",
	version = "1.0.0",
	url = "https://zizt.ru/ | http://hlmod.ru | https://forums.alliedmods.net/"
};

char sPath[128];
char sFilter[32][256];
int sFilter_;

public void OnPluginStart()  
{
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/cleaner.cfg");
	if(!FileExists(sPath)) SetFailState("[Cleaner] File cleaner.cfg not found");
	PTaH(PTaH_ServerConsolePrint, Hook, ServerConsolePrint); 
}

public void OnMapStart() 
{
	sFilter_ = 0;
	File bdc = OpenFile(sPath, "r");
	while (!bdc.EndOfFile())
	{
		bdc.ReadLine(sFilter[sFilter_], sizeof(sFilter[]));
		sFilter_++;
	}
	delete bdc;
}

public Action ServerConsolePrint(const char[] sMessage) 
{
	for(int i; i < sFilter_; i++) if (StrContains(sMessage, sFilter[i]) != -1) return Plugin_Handled; 
	return Plugin_Continue; 
} 