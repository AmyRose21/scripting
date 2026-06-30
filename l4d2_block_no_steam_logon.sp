#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>

// Definiciones del GameData
#define GAMEDATA_FILE           "l4d2_block_no_steam_logon"
#define DETOUR_FUNCTION         "CSteam3Server::OnValidateAuthTicketResponseHelper"
#define SDKCALL_GETCLIENTNAME   "CBaseClient::GetClientName"
#define SDKCALL_ISTIMINGOUT     "CNetChan::IsTimingOut"
#define SDKCALL_DISCONNECT      "CBaseClient::Disconnect"
#define SDKCALL_GETNETCHANNEL   "CBaseClient::GetNetChannel"
#define OFFSET_NAME             "CBaseClient->m_Name"

#define CLIENTNAME_TIMED_OUT    "%s timed out."

// Variables Globales
Handle g_hSDKCall_GetClientName;
Handle g_hSDKCall_IsTimingOut;
Handle g_hSDKCall_Disconnect;
Handle g_hSDKCall_GetNetChannel;
Handle g_hDetour_AuthTicket;

GlobalForward g_hFWD_OnValidateAuthTicketResponseHelper = null;

ConVar g_hCvar_DropOrNot = null;
ConVar g_hCvar_CheckTimeOut = null;

bool g_bDropOrNot = false;
bool g_bCheckTimeOut = false;

// Sistema Operativo y Offsets
EngineVersion g_Engine = Engine_Unknown;
int g_iOff_CBaseClient_m_Name = -1;

// Enumeración de respuestas de Steam
enum EAuthSessionResponse
{
    k_EAuthSessionResponseOK = 0,
    k_EAuthSessionResponseUserNotConnectedToSteam = 1,
    k_EAuthSessionResponseNoLicenseOrExpired = 2,
    k_EAuthSessionResponseVACBanned = 3,
    k_EAuthSessionResponseLoggedInElseWhere = 4,
    k_EAuthSessionResponseVACCheckTimedOut = 5,
    k_EAuthSessionResponseAuthTicketCanceled = 6,
    k_EAuthSessionResponseAuthTicketInvalidAlreadyUsed = 7,
    k_EAuthSessionResponseAuthTicketInvalid = 8,
}

// Methodmaps para facilitar el uso de punteros
methodmap INetChannel
{
    public bool IsTimingOut() {
        if (g_hSDKCall_IsTimingOut == null) return false;
        return SDKCall(g_hSDKCall_IsTimingOut, view_as<Address>(this));
    }
}

methodmap CBaseClient
{
    public INetChannel GetNetChannel() {
        if (g_hSDKCall_GetNetChannel == null) return view_as<INetChannel>(Address_Null);
        return view_as<INetChannel>(SDKCall(g_hSDKCall_GetNetChannel, view_as<Address>(this)));
    }

    public void Disconnect(const char[] reason) {
        if (g_hSDKCall_Disconnect != null) {
            SDKCall(g_hSDKCall_Disconnect, view_as<Address>(this), reason);
        }
    }

    public void GetClientName(char[] name, int maxlen) {
        if (g_hSDKCall_GetClientName != null) {
            SDKCall(g_hSDKCall_GetClientName, view_as<Address>(this), name, maxlen);
        }
    }
}

#define PLUGIN_VERSION "1.2.3"

public Plugin myinfo =
{
    name        = "[L4D2] Block No Steam Logon",
    author      = "blueblur (Modified by AI)",
    description = "Attempts to bypass server's 'no steam logon' disconnection.",
    version     = PLUGIN_VERSION,
    url         = "https://github.com/blueblur0730/modified-plugins"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    g_Engine = GetEngineVersion();
    if (g_Engine != Engine_Left4Dead2)
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
        return APLRes_SilentFailure;
    }

    g_hFWD_OnValidateAuthTicketResponseHelper = new GlobalForward("OnValidateAuthTicketResponseHelper", ET_Event, Param_Any, Param_String);
    RegPluginLibrary("l4d2_block_no_steam_logon");
    return APLRes_Success;
}

public void OnPluginStart()
{
    CreateConVar("l4d2_block_no_steam_logon_version", PLUGIN_VERSION, "Plugin Version", FCVAR_NOTIFY | FCVAR_DONTRECORD);

    g_hCvar_DropOrNot = CreateConVar("l4d2_block_no_steam_logon_enable", "1", "Enable to prevent no steam logon disconnection.", _, true, 0.0, true, 1.0);
    g_hCvar_CheckTimeOut = CreateConVar("l4d2_block_no_steam_logon_check_timeout", "1", "Enable to check client's timeout.", _, true, 0.0, true, 1.0);
    
    g_hCvar_DropOrNot.AddChangeHook(OnCvarChange);
    g_hCvar_CheckTimeOut.AddChangeHook(OnCvarChange);
    
    // Cargar configuraciones iniciales
    OnCvarChange(null, "", "");
    
    InitGameData();
}

void OnCvarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_bDropOrNot    = g_hCvar_DropOrNot.BoolValue;
    g_bCheckTimeOut = g_hCvar_CheckTimeOut.BoolValue;
}

// --- Detour Callback ---
public MRESReturn DTR_OnValidateAuthTicketResponseHelper_Pre(DHookReturn hReturn, DHookParam hParam)
{
    // Argumento 1: CBaseClient* cl
    CBaseClient pBaseClient = view_as<CBaseClient>(hParam.Get(1));

    // Validar puntero
    if (view_as<Address>(pBaseClient) == Address_Null)
        return MRES_Ignored;

    char sName[128];
    bool bNameFound = false;

    // Lógica para obtener el nombre basada en SO
    // En Windows a veces GetClientName no es virtual o accesible fácilmente via SDKCall
    if (g_iOff_CBaseClient_m_Name != -1)
    {
        // Intento directo de memoria (Funciona en ambos si el offset es correcto)
        ReadMemoryString(view_as<Address>(pBaseClient) + view_as<Address>(g_iOff_CBaseClient_m_Name), sName, sizeof(sName));
        if (sName[0] != '\0') bNameFound = true;
    }

    if (!bNameFound && g_hSDKCall_GetClientName != null)
    {
        // Fallback a SDKCall (común en Linux)
        pBaseClient.GetClientName(sName, sizeof(sName));
    }
    
    if (sName[0] == '\0') {
        Format(sName, sizeof(sName), "<Unknown>");
    }

    // Argumento 2: EAuthSessionResponse response
    EAuthSessionResponse response = view_as<EAuthSessionResponse>(hParam.Get(2));
    
    // Solo loguear si no es éxito
    if (response != k_EAuthSessionResponseOK) {
        PrintLog("### Found a client with auth problem, name: %s, EAuthSessionResponse: %d", sName, response);
    }

    Call_StartForward(g_hFWD_OnValidateAuthTicketResponseHelper);
    Call_PushCell(response);
    Call_PushString(sName);
    Call_Finish();

    // Chequeo de Timeout
    if (g_bCheckTimeOut)
    {
        INetChannel netchan = pBaseClient.GetNetChannel();
        if (view_as<Address>(netchan) != Address_Null && netchan.IsTimingOut())
        {
            char reason[128];
            Format(reason, sizeof(reason), CLIENTNAME_TIMED_OUT, sName);
            PrintLog("### Disconnecting timed out client, reason: %s", reason);
            pBaseClient.Disconnect(reason); 
            return MRES_Supercede;
        }
    }

    // Lógica de Bloqueo de No Steam Logon
    switch (response)
    {
        case k_EAuthSessionResponseUserNotConnectedToSteam,
             k_EAuthSessionResponseAuthTicketCanceled,
             k_EAuthSessionResponseAuthTicketInvalidAlreadyUsed,
             k_EAuthSessionResponseAuthTicketInvalid:
        {
            if (g_bDropOrNot)
            {
                PrintLog("### Bypassing no steam logon disconnection for client: %s", sName);
                return MRES_Supercede; // Bloquea la desconexión
            }
        }
    }

    return MRES_Ignored;
}

// --- Inicialización del GameData (Sin Wrapper) ---
void InitGameData()
{
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/%s.txt", GAMEDATA_FILE);

    if (!FileExists(sPath)) {
        SetFailState("GameData file not found: %s", sPath);
    }

    Handle hGameConf = LoadGameConfigFile(GAMEDATA_FILE);
    if (hGameConf == null)
        SetFailState("Failed to load GameData: %s", GAMEDATA_FILE);

    // 1. Obtener Offset m_Name
    g_iOff_CBaseClient_m_Name = GameConfGetOffset(hGameConf, OFFSET_NAME);
    if (g_iOff_CBaseClient_m_Name == -1) {
        LogError("Warning: Failed to find offset %s in gamedata.", OFFSET_NAME);
    }

    // 2. Setup Detour
    g_hDetour_AuthTicket = DHookCreateFromConf(hGameConf, DETOUR_FUNCTION);
    if (g_hDetour_AuthTicket == null) {
        SetFailState("Failed to create detour: %s", DETOUR_FUNCTION);
    }
    
    if (!DHookEnableDetour(g_hDetour_AuthTicket, false, DTR_OnValidateAuthTicketResponseHelper_Pre)) {
        SetFailState("Failed to enable detour: %s", DETOUR_FUNCTION);
    }

    // 3. SDKCalls
    StartPrepSDKCall(SDKCall_Raw);
    if (PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, SDKCALL_GETCLIENTNAME)) {
        PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer); // name buffer
        PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // length
        PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain); // void/bool? usually void for char* getters
        g_hSDKCall_GetClientName = EndPrepSDKCall();
    }
    
    // IsTimingOut
    StartPrepSDKCall(SDKCall_Raw);
    if (PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, SDKCALL_ISTIMINGOUT)) {
        PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
        g_hSDKCall_IsTimingOut = EndPrepSDKCall();
    } else {
        LogError("Failed to verify SDKCall: %s", SDKCALL_ISTIMINGOUT);
    }

    // Disconnect
    StartPrepSDKCall(SDKCall_Raw);
    if (PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, SDKCALL_DISCONNECT)) {
        PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer); // reason
        g_hSDKCall_Disconnect = EndPrepSDKCall();
    } else {
        LogError("Failed to verify SDKCall: %s", SDKCALL_DISCONNECT);
    }

    // GetNetChannel
    StartPrepSDKCall(SDKCall_Raw);
    if (PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, SDKCALL_GETNETCHANNEL)) {
        PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain); // Returns pointer
        g_hSDKCall_GetNetChannel = EndPrepSDKCall();
    } else {
        LogError("Failed to verify SDKCall: %s", SDKCALL_GETNETCHANNEL);
    }

    delete hGameConf;
}

stock void PrintLog(const char[] Message, any...)
{
    char sFormat[256];
    VFormat(sFormat, sizeof(sFormat), Message, 2);

    static char Path[PLATFORM_MAX_PATH];
    if (Path[0] == '\0')
        BuildPath(Path_SM, Path, PLATFORM_MAX_PATH, "logs/l4d2_block_no_steam_logon.log");

    LogToFileEx(Path, sFormat);
}

// Función auxiliar para leer strings de memoria directamente
stock void ReadMemoryString(Address addr, char[] buffer, int size)
{
    if (addr == Address_Null) {
        buffer[0] = '\0';
        return;
    }

    int max = size - 1;
    int i = 0;
    int charVal;
    
    for (; i < max; i++)
    {
        charVal = LoadFromAddress(addr + view_as<Address>(i), NumberType_Int8);
        buffer[i] = view_as<char>(charVal);
        
        if (charVal == 0)
            return;
    }

    buffer[i] = '\0';
}