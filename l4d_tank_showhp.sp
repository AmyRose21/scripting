#define PLUGIN_VERSION "1.3"

#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

// Se ha eliminado #include <colors> para evitar el error.
// Usaremos los códigos de color nativos de L4D (\x04, \x03, etc).

#define DEBUG 0

// Opciones de visualización (Bitwise)
#define COMPONENT_LABEL         1   // Texto "HP"
#define COMPONENT_BAR           2   // La barra gráfica [||||...]
#define COMPONENT_CURRENT_HP    4   // Vida actual numérica
#define COMPONENT_MAX_HP        8   // Vida máxima numérica
#define COMPONENT_NAME          16  // Nombre del jugador Tank
#define COMPONENT_ALL           31

// Configuración de la barra
#define BAR_SIZE                40
#define CHAR_FILL               "|" // Caracter de vida llena
#define CHAR_EMPTY              ":" // Caracter de vida vacía

public Plugin myinfo =
{
    name = "[L4D1 & L4D2] Tank Show HP Remastered",
    author = "Alex Dragokas (Edit by AI)",
    description = "Muestra la vida del Tank de forma estética al dispararle",
    version = PLUGIN_VERSION,
    url = "http://dragokas.com/"
};

ConVar g_hCvarEnable, g_hCvarComponents, g_hCvarKillMsg;
bool g_bEnabled, g_bLeft4Dead2, g_bKillMsg, g_bLateload;

// Pre-caching de las barras
char g_sBarStrings[BAR_SIZE + 1][BAR_SIZE * 3]; 

int g_iComponents;
float g_fLastTime[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();
    if (test == Engine_Left4Dead2) g_bLeft4Dead2 = true;
    else if (test != Engine_Left4Dead)
    {
        strcopy(error, err_max, "Este plugin solo soporta Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }
    g_bLateload = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
    CreateConVar("l4d_showtankhp_version", PLUGIN_VERSION, "L4D Infected HP version", FCVAR_NOTIFY | FCVAR_DONTRECORD);

    g_hCvarEnable       = CreateConVar("l4d_showtankhp_enable",       "1",    "Activar plugin (1 - Si, 0 - No)", FCVAR_NOTIFY);
    g_hCvarComponents   = CreateConVar("l4d_showtankhp_components",   "31",   "Componentes a mostrar (Sumar valores: 1-Label, 2-Barra, 4-HP Actual, 8-HP Max, 16-Nombre)", FCVAR_NOTIFY);
    g_hCvarKillMsg      = CreateConVar("l4d_showtankhp_kill_msg",     "1",    "Mostrar mensaje al morir el tank (1 - Si, 0 - No)", FCVAR_NOTIFY);
    
    AutoExecConfig(true, "l4d_showtankhp");
    
    BuildBarStrings();
    
    GetCvars();

    g_hCvarEnable.AddChangeHook(OnCvarChanged);
    g_hCvarComponents.AddChangeHook(OnCvarChanged);
    g_hCvarKillMsg.AddChangeHook(OnCvarChanged);
}

void BuildBarStrings()
{
    for (int i = 0; i <= BAR_SIZE; i++)
    {
        g_sBarStrings[i][0] = '\0';
        for (int k = 0; k < i; k++)
            StrCat(g_sBarStrings[i], sizeof(g_sBarStrings[]), CHAR_FILL);
        for (int k = i; k < BAR_SIZE; k++)
            StrCat(g_sBarStrings[i], sizeof(g_sBarStrings[]), CHAR_EMPTY);
    }
}

public void OnCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    GetCvars();
}

void GetCvars()
{
    g_bEnabled = g_hCvarEnable.BoolValue;
    g_iComponents = g_hCvarComponents.IntValue;
    g_bKillMsg = g_hCvarKillMsg.BoolValue;
    InitHook();
}

void InitHook()
{
    static bool bHooked;
    
    if (g_bEnabled && !bHooked) {
        HookEvent("player_hurt",    Event_OnPlayerHurt);
        HookEvent("tank_killed",    Event_OnTankKilled);
        bHooked = true;
    } else if (!g_bEnabled && bHooked) {
        UnhookEvent("player_hurt",  Event_OnPlayerHurt);
        UnhookEvent("tank_killed",  Event_OnTankKilled);
        bHooked = false;
    }
}

public void Event_OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    
    if (attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker) || IsFakeClient(attacker))
        return;

    float fNow = GetEngineTime();
    if (fNow - g_fLastTime[attacker] < 0.1)
        return;
        
    g_fLastTime[attacker] = fNow;
    
    int tank = GetClientOfUserId(event.GetInt("userid"));
    if (!IsTank(tank))
        return;

    int nowHP = event.GetInt("health");
    if (nowHP < 0) nowHP = 0;
    
    int maxHP = GetEntProp(tank, Prop_Data, "m_iMaxHealth");
    if (maxHP < 1) maxHP = 1;

    int idx = (nowHP * BAR_SIZE) / maxHP;
    
    if (idx < 0) idx = 0;
    if (idx > BAR_SIZE) idx = BAR_SIZE;
    
    char sMessage[256];
    
    if (g_iComponents & COMPONENT_NAME)
        Format(sMessage, sizeof(sMessage), "%N ", tank);
        
    if (g_iComponents & COMPONENT_LABEL)
        StrCat(sMessage, sizeof(sMessage), "HP: ");

    if (g_iComponents & COMPONENT_BAR)
        Format(sMessage, sizeof(sMessage), "%s[%s] ", sMessage, g_sBarStrings[idx]);
        
    if ((g_iComponents & COMPONENT_CURRENT_HP) && (g_iComponents & COMPONENT_MAX_HP))
    {
        Format(sMessage, sizeof(sMessage), "%s%d/%d", sMessage, nowHP, maxHP);
    }
    else if (g_iComponents & COMPONENT_CURRENT_HP)
    {
        Format(sMessage, sizeof(sMessage), "%s%d", sMessage, nowHP);
    }
    
    PrintCenterText(attacker, sMessage);
}

public void Event_OnTankKilled(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bKillMsg) return;

    int tank = GetClientOfUserId(event.GetInt("userid"));
    
    if (tank && IsClientInGame(tank))
    {
        // Usamos códigos nativos: \x04 = Verde, \x03 = Color Equipo (LightGreen), \x01 = Normal
        if(g_bLeft4Dead2)
            PrintToChatAll("\x04[Tank]\x03 %N\x01 ha muerto!", tank);
        else
            PrintToChatAll("\x03[Tank]\x01 %N ha muerto!", tank);
            
        PrintHintTextToAll("++ %N R.I.P ++", tank);
    }
}

bool IsTank(int client)
{
    if (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3)
    {
        int class = GetEntProp(client, Prop_Send, "m_zombieClass");
        if (class == (g_bLeft4Dead2 ? 8 : 5))
            return true;
    }
    return false;
}