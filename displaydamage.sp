#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.3-L4D2"
#define BASE_MODE 2
#define AD_MSG "Say !displaymode <0/1/2/3> to change the damage display mode."

// Variables Globales
ConVar g_cvAllowed;
ConVar g_cvAds;
ConVar g_cvDefaultMode;
ConVar g_cvDelay;
ConVar g_cvMsgMode;

float g_fLastMsgTime[MAXPLAYERS + 1];
int g_iDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];
int g_iDisplayMode[MAXPLAYERS + 1] = {BASE_MODE, ...};

public Plugin myinfo = 
{
    name = "Display Damage (L4D2 Fix)",
    author = "NBK - Sammy-ROCK! (Fixed by AI)",
    description = "Display the damage that the player did/received.",
    version = PLUGIN_VERSION,
    url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
    char sModName[64];
    GetGameFolderName(sModName, sizeof(sModName));
    
    // Verificación compatible con L4D1 y L4D2
    if (!StrEqual(sModName, "left4dead", false) && !StrEqual(sModName, "left4dead2", false))
        SetFailState("This plugin is for Left 4 Dead 1 & 2 only.");

    // Hook Events
    HookEvent("infected_hurt", Event_InfectedHurt);
    HookEvent("player_hurt", Event_PlayerHurt);
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("round_start", Event_RoundStart); // Importante para limpiar datos en L4D2

    // ConVars
    g_cvAds = CreateConVar("sm_display_damage_ads", "1", "Enables Display Damage to advertise to players.");
    g_cvAllowed = CreateConVar("sm_display_damage_enabled", "1", "Enables Display Damage to players.");
    g_cvDefaultMode = CreateConVar("sm_display_damage_default", "2", "Default Display Damage mode. 1 = all; 2 = damage done; 3 = damage taken; 0 = no display.");
    g_cvDelay = CreateConVar("sm_display_damage_delay", "1.0", "Minimum delay between damage displays.");
    g_cvMsgMode = CreateConVar("sm_display_damage_mode", "1", "Mode to display damage. 1=Hint; 2=Center; 3=Chat.", FCVAR_NOTIFY, true, 1.0, true, 3.0);
    
    CreateConVar("sm_display_damage_version", PLUGIN_VERSION, "Version of Display Damage plugin.", FCVAR_NOTIFY|FCVAR_DONTRECORD);

    RegConsoleCmd("sm_displaymode", Command_DisplayMode);
    
    AutoExecConfig(true, "displaydamage");
    
    // Timer para anuncio (Ads)
    CreateTimer(GetRandomFloat(250.0, 350.0), Timer_AdsPlugin, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientPutInServer(int client)
{
    if (client > 0 && client <= MaxClients)
    {
        // Resetear variables al entrar
        for (int i = 0; i <= MaxClients; i++)
        {
            g_iDamage[client][i] = 0;
            g_iDamage[i][client] = 0;
        }
        g_fLastMsgTime[client] = 0.0;

        if (!IsFakeClient(client))
            g_iDisplayMode[client] = g_cvDefaultMode.IntValue;
        else
            g_iDisplayMode[client] = 0;
    }
}

public Action Command_DisplayMode(int client, int args)
{
    if (client == 0) return Plugin_Handled;

    if (args < 1)
        g_iDisplayMode[client] = g_cvDefaultMode.IntValue;
    else 
    {
        char arg[10];
        GetCmdArg(1, arg, sizeof(arg));
        g_iDisplayMode[client] = StringToInt(arg);
    }

    switch(g_iDisplayMode[client]) 
    {
        case 1: ReplyToCommand(client, "[DisplayDamage] Any damage will be displayed. (%i)", g_iDisplayMode[client]);
        case 2: ReplyToCommand(client, "[DisplayDamage] Damage you've done will be displayed. (%i)", g_iDisplayMode[client]);
        case 3: ReplyToCommand(client, "[DisplayDamage] Damage you've received will be displayed. (%i)", g_iDisplayMode[client]);
        default: ReplyToCommand(client, "[DisplayDamage] Damage will not be displayed. (%i)", g_iDisplayMode[client]);
    }
    return Plugin_Handled;
}

// Limpiar daño al inicio de ronda (Esencial para L4D2)
public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    for(int i = 0; i <= MaxClients; i++)
    {
        for(int j = 0; j <= MaxClients; j++)
        {
            g_iDamage[i][j] = 0;
        }
    }
    return Plugin_Continue;
}

bool IsEnoughTime(int client)
{
    float fTime = GetGameTime();
    float fNeeded = g_cvDelay.FloatValue;
    if (fTime - g_fLastMsgTime[client] > fNeeded)
    {
        g_fLastMsgTime[client] = fTime;
        return true;
    }
    return false;
}

// Daño a Infectados Comunes
public Action Event_InfectedHurt(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_cvAllowed.BoolValue) return Plugin_Continue;

    int attackerUserId = event.GetInt("attacker");
    int client = GetClientOfUserId(attackerUserId);

    if (client > 0 && IsClientInGame(client))
    {
        int amount = event.GetInt("amount");
        g_iDamage[client][0] += amount; // Indice 0 usado para Horda/Infectados Comunes

        if (IsEnoughTime(client) && (g_iDisplayMode[client] == 1 || g_iDisplayMode[client] == 2))
            Display(client, g_cvMsgMode.IntValue, "You hurt Horde for %i HP.", g_iDamage[client][0]);
    }
    return Plugin_Continue;
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_cvAllowed.BoolValue) return Plugin_Continue;

    int damage = event.GetInt("dmg_health");
    
    // BugFix original para tanque o daño masivo absurdo
    if (damage < 1000) 
    {
        int client = GetClientOfUserId(event.GetInt("userid")); // Víctima
        int attackerUserId = event.GetInt("attacker");
        int attacker = GetClientOfUserId(attackerUserId); // Atacante

        // Validar víctima
        if (client > 0 && IsClientInGame(client))
        {
            // Si hay un atacante válido (Jugador vs Jugador)
            if (attacker > 0 && IsClientInGame(attacker))
            {
                g_iDamage[attacker][client] += damage;
                int mode = g_cvMsgMode.IntValue;

                // Mensaje a la víctima
                if ((g_iDisplayMode[client] == 1 || g_iDisplayMode[client] == 3) && IsEnoughTime(client))
                {
                    Display(client, mode, "%N hurt you for %i HP.", attacker, g_iDamage[attacker][client]);
                }

                // Mensaje al atacante
                if ((g_iDisplayMode[attacker] == 1 || g_iDisplayMode[attacker] == 2) && IsEnoughTime(attacker))
                {
                    Display(attacker, mode, "You hurt %N for %i HP.", client, g_iDamage[attacker][client]);
                }
            }
            // Si el atacante es 0 o inválido (Horda, Mundo, Fuego, etc.)
            else 
            {
                // Usamos attacker = 0 para almacenar daño recibido del entorno/horda
                // Nota: En player_hurt, si attacker es 0 suele ser world o common infected
                g_iDamage[0][client] += damage;
                
                if ((g_iDisplayMode[client] == 1 || g_iDisplayMode[client] == 3) && IsEnoughTime(client))
                {
                    // Determinar si fue infected o world (simplificado a Horde/Environment)
                    Display(client, g_cvMsgMode.IntValue, "Environment/Horde hurt you for %i HP.", g_iDamage[0][client]);
                }
            }
        }
    }
    return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_cvAllowed.BoolValue) return Plugin_Continue;

    int client = GetClientOfUserId(event.GetInt("userid"));

    if (client > 0 && IsClientInGame(client))
    {
        int iTotalDamageDone = 0;
        int iTotalDamageTaken = 0;

        // Calcular totales
        for(int i = 0; i <= MaxClients; i++)
        {
            iTotalDamageDone += g_iDamage[client][i];
            iTotalDamageTaken += g_iDamage[i][client];
            
            // Limpiar contadores específicos relacionados con este cliente
            g_iDamage[client][i] = 0; 
            g_iDamage[i][client] = 0; 
        }

        int mode = g_cvMsgMode.IntValue;

        if (g_iDisplayMode[client] == 1 || g_iDisplayMode[client] == 2)
            Display(client, mode, "You did %i total damage before dying.", iTotalDamageDone);
        
        if (g_iDisplayMode[client] == 1 || g_iDisplayMode[client] == 3)
            Display(client, mode, "You took %i total damage before dying.", iTotalDamageTaken);
    }
    return Plugin_Continue;
}

public Action Timer_AdsPlugin(Handle timer)
{
    if (g_cvAllowed.BoolValue && g_cvAds.BoolValue)
    {
        int mode = g_cvMsgMode.IntValue;
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && !IsFakeClient(i))
            {
                Display(i, mode, AD_MSG);
            }
        }
    }
    return Plugin_Continue;
}

void Display(int client, int mode, const char[] format, any ...)
{
    if (!IsClientInGame(client)) return;

    char buffer[192];
    VFormat(buffer, sizeof(buffer), format, 4);

    switch(mode)
    {
        case 1: PrintHintText(client, "%s", buffer);
        case 2: PrintCenterText(client, "%s", buffer);
        case 3: PrintToChat(client, "\x04[DD] \x01%s", buffer); // Color verde para chat
    }
}