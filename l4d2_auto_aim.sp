#define _spanish_version
#include <sourcemod>
#include <left4dhooks_lux_library>
#include <sdkhooks>
#include <sdktools>
#include <l4d_anim>

#define TEAM_SPECTATOR 1
#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3

#define PLUGIN_PREFIX "\x04[Auto-Aim]\x01"
#define DATA_FILE "l4d2_auto_aim_durations.txt"

public Plugin AutoAimPluginInfo =
{
    name = "Auto Aim",
    author = "Pure_*",
    description = "Permite al jugador auto-apuntar a Infectados inmediatamente",
    version = "0.7",
    url = ""
};

int durations[MAXPLAYERS + 1];
Handle timers[MAXPLAYERS + 1];
int selectedPlayer[MAXPLAYERS + 1];   // Para el menu: jugador seleccionado por cada admin

StringMap infecteds;
StringMap allowedWeapons;
StringMap pendingDurations;   // SteamID -> segundos restantes (persistencia entre rondas/sesiones)

ConVar mode;
ConVar angleLimit;
ConVar aimCommonInfected;
ConVar aimSpecialInfected;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion version = GetEngineVersion();
    if(version != Engine_Left4Dead2)
    {
        Format(error, err_max, "[Auto-Aim] Este plugin solo es compatible con Left 4 Dead 2");
        return APLRes_SilentFailure;
    }
    return APLRes_Success;
}

public OnPluginStart()
{
    infecteds = new StringMap();
    allowedWeapons = new StringMap();
    pendingDurations = new StringMap();
    allowedWeapons.SetValue("autoshotgun", true);
    allowedWeapons.SetValue("hunting_rifle", true);
    allowedWeapons.SetValue("pistol", true);
    allowedWeapons.SetValue("pistol_magnum", true);
    allowedWeapons.SetValue("pumpshotgun", true);
    allowedWeapons.SetValue("rifle", true);
    allowedWeapons.SetValue("rifle_ak47", true);
    allowedWeapons.SetValue("rifle_desert", true);
    allowedWeapons.SetValue("rifle_m60", true);
    allowedWeapons.SetValue("rifle_sg552", true);
    allowedWeapons.SetValue("shotgun_chrome", true);
    allowedWeapons.SetValue("shotgun_spas", true);
    allowedWeapons.SetValue("smg", true);
    allowedWeapons.SetValue("smg_mp5", true);
    allowedWeapons.SetValue("smg_silenced", true);
    allowedWeapons.SetValue("sniper_awp", true);
    allowedWeapons.SetValue("sniper_military", true);
    allowedWeapons.SetValue("sniper_scout", true);

    // Comandos originales (mantenidos por compatibilidad)
    RegAdminCmd("sm_autoaim", Command_AutoAim, ADMFLAG_SLAY, "sm_autoaim <jugador> <tiempo_segundos> - Activa Auto-Aim");
    RegAdminCmd("sm_quitaa", Command_QuitAutoAim, ADMFLAG_SLAY, "sm_quitaa - Desactiva tu propio Auto-Aim");

    // Nuevos comandos de menu UI
    RegAdminCmd("sm_aamenu", Command_AutoAimMenu, ADMFLAG_SLAY, "Abre el menu de Auto-Aim");
    RegAdminCmd("sm_autoaim_menu", Command_AutoAimMenu, ADMFLAG_SLAY, "Abre el menu de Auto-Aim");

    HookEvent("player_spawn", OnPlayerSpawn);
    HookEvent("player_death", OnPlayerDeath);
    HookEvent("infected_death", OnInfectedDeath);
    HookEvent("weapon_fire", OnWeaponFire);
    HookEvent("round_start", OnRoundStart);
    HookEvent("round_end", OnRoundEnd);
    HookEvent("finale_win", OnRoundEnd);
    HookEvent("mission_lost", OnRoundEnd);
    HookEvent("map_transition", OnRoundEnd);

    mode = CreateConVar("l4d2_auto_aim_mode", "0", "Modo de Auto-Aim, 0 es modo normal, 1 es modo Spin Bot", 0, true, 0.0, true, 1.0);
    angleLimit = CreateConVar("l4d2_auto_aim_limited_angle", "45.0", "Solo usar cuando el modo es 0, el angulo entre la linea de vision del jugador y la cabeza del enemigo", 0, true, 45.0, true, 89.0);
    aimCommonInfected = CreateConVar("l4d2_auto_aim_ci_enable", "1", "Auto-apuntar a infectados comunes? (0=desactivado, 1=activado)", 0, true, 0.0, true, 1.0);
    aimSpecialInfected = CreateConVar("l4d2_auto_aim_si_enable", "1", "Auto-apuntar a infectados especiales? (0=desactivado, 1=activado)", 0, true, 0.0, true, 1.0);

    AutoExecConfig(true, "l4d2_auto_aim");

    // Cargar duraciones pendientes del archivo (persistencia entre sesiones)
    LoadDurationsFromFile();
}

public void OnPluginEnd()
{
    // Guardar estado al descargar el plugin
    SaveDurationsToFile();
}

public void OnClientPutInServer(int client)
{
    if(IsFakeClient(client) || client < 1 || client > MaxClients)
        return;

    // Restaurar tiempo pendiente si existe (por SteamID)
    RestorePlayerDuration(client);
}

public void OnClientDisconnect(int client)
{
    if(durations[client] > 0)
    {
        // Guardar tiempo restante por SteamID antes de limpiar
        SavePlayerDuration(client);
        KillTimerSafety(timers[client]);
        durations[client] = 0;
        SaveDurationsToFile();
    }
    selectedPlayer[client] = 0;
}

// ============================================================================
//  COMANDOS
// ============================================================================

Action Command_QuitAutoAim(int client, int args)
{
    if(durations[client] > 0)
    {
        KillTimerSafety(timers[client]);
        durations[client] = 0;
        PrintToChat(client, "%s Tu Auto-Aim ha sido \x04desactivado\x01.", PLUGIN_PREFIX);
    }
    return Plugin_Handled;
}

Action Command_AutoAim(int client, int args)
{
    if(args < 2)
    {
        PrintToChat(client, "%s Uso: sm_autoaim <jugador> <tiempo_segundos>", PLUGIN_PREFIX);
        return Plugin_Handled;
    }
    int player = GetCmdArgInt(1);
    int time = GetCmdArgInt(2);
    if(!IsClientValid(player))
    {
        PrintToChat(client, "%s Jugador invalido.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }
    if(time <= 0)
    {
        PrintToChat(client, "%s El tiempo debe ser mayor a 0.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }

    if(durations[player] > 0)
    {
        durations[player] += time;
    }
    else
    {
        durations[player] = time;
        timers[player] = CreateTimer(1.0, CountDown, player, TIMER_REPEAT);
    }
    return Plugin_Handled;
}

// ============================================================================
//  SISTEMA DE MENU UI
// ============================================================================

Action Command_AutoAimMenu(int client, int args)
{
    if(!IsClientValid(client))
        return Plugin_Handled;

    ShowMainMenu(client);
    return Plugin_Handled;
}

void ShowMainMenu(int client)
{
    Menu menu = new Menu(MainMenuHandler);
    menu.SetTitle("Auto-Aim - Menu Principal\n \n");

    int activeCount = 0;
    for(int i = 1; i <= MaxClients; i++)
        if(durations[i] > 0) activeCount++;

    char giveItem[64];
    Format(giveItem, sizeof(giveItem), "Dar Auto-Aim a jugador");
    char removeItem[64];
    Format(removeItem, sizeof(removeItem), "Quitar Auto-Aim de jugador");
    char statusItem[64];
    Format(statusItem, sizeof(statusItem), "Ver estados actuales (%d activo%s)", activeCount, activeCount == 1 ? "" : "s");

    menu.AddItem("give", giveItem);
    menu.AddItem("remove", removeItem);
    menu.AddItem("status", statusItem);

    menu.Display(client, 30);
}

int MainMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
        case MenuAction_End:
            delete menu;
        case MenuAction_Select:
        {
            char info[16];
            menu.GetItem(param2, info, sizeof(info));

            if(StrEqual(info, "give"))
                ShowPlayerListMenu(param1, false);
            else if(StrEqual(info, "remove"))
                ShowPlayerListMenu(param1, true);
            else if(StrEqual(info, "status"))
                ShowStatusMenu(param1);
        }
    }
    return 0;
}

void ShowPlayerListMenu(int client, bool removeMode)
{
    Menu menu = new Menu(PlayerListHandler);
    if(removeMode)
        menu.SetTitle("Quitar Auto-Aim\nSelecciona jugador\n \n");
    else
        menu.SetTitle("Dar Auto-Aim\nSelecciona jugador\n \n");

    bool found = false;
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsClientValid(i))
            continue;
        if(IsFakeClient(i))
            continue;

        char name[MAX_NAME_LENGTH];
        GetClientName(i, name, sizeof(name));

        char display[MAX_NAME_LENGTH + 64];
        if(durations[i] > 0)
            Format(display, sizeof(display), "%s (Activo: %ds)", name, durations[i]);
        else
            Format(display, sizeof(display), "%s", name);

        if(removeMode && durations[i] <= 0)
            continue;

        char num[8];
        IntToString(i, num, sizeof(num));
        menu.AddItem(num, display);
        found = true;
    }

    if(!found)
    {
        if(removeMode)
            PrintToChat(client, "%s No hay jugadores con Auto-Aim activo.", PLUGIN_PREFIX);
        else
            PrintToChat(client, "%s No hay jugadores validos en el servidor.", PLUGIN_PREFIX);
        delete menu;
        ShowMainMenu(client);
        return;
    }

    menu.ExitBackButton = true;
    menu.Display(client, 30);
}

int PlayerListHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
        case MenuAction_End:
            delete menu;
        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
                ShowMainMenu(param1);
        }
        case MenuAction_Select:
        {
            char info[8];
            menu.GetItem(param2, info, sizeof(info));
            int player = StringToInt(info);

            if(!IsClientValid(player))
            {
                PrintToChat(param1, "%s El jugador ya no esta disponible.", PLUGIN_PREFIX);
                ShowMainMenu(param1);
                return 0;
            }

            if(durations[player] > 0)
            {
                KillTimerSafety(timers[player]);
                durations[player] = 0;
                PrintToChat(param1, "%s Auto-Aim \x04quitado\x01 de \x03%N\x01.", PLUGIN_PREFIX, player);
                ShowMainMenu(param1);
            }
            else
            {
                selectedPlayer[param1] = player;
                ShowDurationMenu(param1);
            }
        }
    }
    return 0;
}

void ShowDurationMenu(int client)
{
    int player = selectedPlayer[client];
    if(!IsClientValid(player))
    {
        PrintToChat(client, "%s El jugador ya no esta disponible.", PLUGIN_PREFIX);
        ShowMainMenu(client);
        return;
    }

    Menu menu = new Menu(DurationMenuHandler);
    menu.SetTitle("Duracion para %N\n \n", player);

    menu.AddItem("30", "30 segundos");
    menu.AddItem("60", "1 minuto (60s)");
    menu.AddItem("120", "2 minutos (120s)");
    menu.AddItem("180", "3 minutos (180s)");
    menu.AddItem("300", "5 minutos (300s)");
    menu.AddItem("600", "10 minutos (600s)");
    menu.AddItem("1200", "20 minutos (1200s)");
    menu.AddItem("9999", "Permanente (9999s)");

    menu.ExitBackButton = true;
    menu.Display(client, 30);
}

int DurationMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
        case MenuAction_End:
            delete menu;
        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
                ShowPlayerListMenu(param1, false);
        }
        case MenuAction_Select:
        {
            char info[8];
            menu.GetItem(param2, info, sizeof(info));
            int time = StringToInt(info);

            int player = selectedPlayer[param1];
            if(!IsClientValid(player))
            {
                PrintToChat(param1, "%s El jugador ya no esta disponible.", PLUGIN_PREFIX);
                ShowMainMenu(param1);
                return 0;
            }

            if(durations[player] > 0)
            {
                durations[player] += time;
                PrintToChat(param1, "%s Tiempo \x04anadido\x01 a \x03%N\x01. Total: \x04%d\x01 segundos.", PLUGIN_PREFIX, player, durations[player]);
            }
            else
            {
                durations[player] = time;
                timers[player] = CreateTimer(1.0, CountDown, player, TIMER_REPEAT);
                PrintToChat(param1, "%s Auto-Aim \x04activado\x01 para \x03%N\x01 durante \x04%d\x01 segundos.", PLUGIN_PREFIX, player, time);
            }
            ShowMainMenu(param1);
        }
    }
    return 0;
}

void ShowStatusMenu(int client)
{
    Menu menu = new Menu(StatusMenuHandler);
    menu.SetTitle("Estados de Auto-Aim\n \n");

    bool found = false;
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsClientValid(i))
            continue;
        if(durations[i] <= 0)
            continue;

        char name[MAX_NAME_LENGTH];
        GetClientName(i, name, sizeof(name));

        char display[MAX_NAME_LENGTH + 64];
        Format(display, sizeof(display), "%s - %d segundos restantes", name, durations[i]);

        char num[8];
        IntToString(i, num, sizeof(num));
        menu.AddItem(num, display);
        found = true;
    }

    if(!found)
    {
        PrintToChat(client, "%s No hay jugadores con Auto-Aim activo.", PLUGIN_PREFIX);
        delete menu;
        ShowMainMenu(client);
        return;
    }

    menu.ExitBackButton = true;
    menu.Display(client, 30);
}

int StatusMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
        case MenuAction_End:
            delete menu;
        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
                ShowMainMenu(param1);
        }
        case MenuAction_Select:
        {
            char info[8];
            menu.GetItem(param2, info, sizeof(info));
            int player = StringToInt(info);

            if(IsClientValid(player) && durations[player] > 0)
            {
                KillTimerSafety(timers[player]);
                durations[player] = 0;
                PrintToChat(param1, "%s Auto-Aim \x04quitado\x01 de \x03%N\x01.", PLUGIN_PREFIX, player);
            }
            ShowStatusMenu(param1);
        }
    }
    return 0;
}

Action CountDown(Handle timer, int client)
{
    if(!IsClientValid(client))
    {
        timers[client] = null;
        durations[client] = 0;
        return Plugin_Stop;
    }
    durations[client]--;
    if(durations[client] <= 0)
    {
        timers[client] = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// ============================================================================
//  ENTIDADES Y EVENTOS
// ============================================================================

public void OnEntityCreated(int entity, const char[] classname)
{
    if(StrEqual(classname, "infected", false) && GetConVarBool(aimCommonInfected))
    {
        SDKHook(EntIndexToEntRef(entity), SDKHook_SpawnPost, OnCommonCreatedPost);
    }
}

void OnCommonCreatedPost(int entityRef)
{
    SDKUnhook(entityRef, SDKHook_SpawnPost, OnCommonCreatedPost);
    int entity = EntRefToEntIndex(entityRef);
    if(!IsValidEntity(entity))
        return;

    AddToMap(entity, 2);
}

public void OnWeaponFire(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(!IsSurvivor(client))
        return;
    if(durations[client] <= 0)
        return;

    char weaponName[32];
    GetEventString(event, "weapon", weaponName, 32);
    if(!allowedWeapons.ContainsKey(weaponName))
        return;

    // Obtener transform del jugador
    float eye[3];
    GetClientEyePosition(client, eye);
    float eyeAngle[3];
    GetClientEyeAngles(client, eyeAngle);
    float eyeDir[3];
    GetAngleVectors(eyeAngle, eyeDir, NULL_VECTOR, NULL_VECTOR);

    int closestTarget = -1;
    float minDistance = 999999999.0;
    float targetAngle[3];

    float pos[3];
    float dir[3];
    float angle[3];

    Handle trace = null;

    StringMapSnapshot shots = infecteds.Snapshot();
    char num[8];
    int type;

    for(int i = 0; i < shots.Length; i++)
    {
        shots.GetKey(i, num, 8);

        if(!infecteds.GetValue(num, type))
            continue;

        int entity = StringToInt(num);

        if(entity <= 0 || !IsValidEntity(entity))
        {
            RemoveFromMap(entity);
            continue;
        }

        bool isInfected = false;
        if(entity > MAXPLAYERS && IsCommonInfected(entity))
        {
            int curHp = GetEntProp(entity, Prop_Data, "m_iHealth");
            if(curHp <= 0)
                continue;
            // Adjunto de cabeza del infectado comun
            if(!GetAttachmentVectors(entity, "forward", pos, dir))
            {
                GetAbsOrigin(entity, pos);
                pos[2] += 50.0;
            }
        }
        else if(IsInfected(entity))
        {
            isInfected = true;
            int zombieClass = GetEntProp(entity, Prop_Send, "m_zombieClass");
            if(zombieClass == 8)
                GetClientEyePosition(entity, pos);  // Tank no tiene cabeza
            else
                L4D_GetBonePosition(entity, L4D_GetZombieBone(entity, Bone_Head), pos);
        }
        else
        {
            RemoveFromMap(entity);
            continue;
        }

        MakeVectorFromPoints(eye, pos, dir);
        // Modo normal necesita verificar angulo
        if(GetConVarInt(mode) == 0)
        {
            if(GetAngleBetweenTwoDirection(eyeDir, dir) > GetConVarFloat(angleLimit))
                continue;
        }
        GetVectorAngles(dir, angle);
        if(!isInfected)
            trace = TR_TraceRayFilterEx(eye, angle, MASK_SHOT, RayType_Infinite, TraceFilterCommon, client);
        else
            trace = TR_TraceRayFilterEx(eye, angle, MASK_SHOT, RayType_Infinite, TraceFilterSpecial, client);
        if(trace == null)
            continue;

        if(TR_DidHit(trace))
        {
            float endPoint[3];
            TR_GetEndPosition(endPoint, trace);

            float originDis = GetVectorDistance(eye, pos);
            float hitDis = GetVectorDistance(eye, endPoint);
            if(FloatAbs(originDis - hitDis) < 15.0 && minDistance > hitDis)
            {
                closestTarget = entity;
                minDistance = hitDis;
                targetAngle[0] = angle[0];
                targetAngle[1] = angle[1];
                targetAngle[2] = angle[2];
            }
        }
        CloseHandle(trace);
    }
    CloseHandle(shots);
    // Girar al jugador para apuntar al objetivo
    if(closestTarget != -1)
    {
        TeleportEntity(client, NULL_VECTOR, targetAngle);
    }
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if(!GetConVarBool(aimSpecialInfected))
        return;

    int infected = GetClientOfUserId(GetEventInt(event, "userid"));
    if(IsInfected(infected))
    {
        AddToMap(infected, 1);
    }
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int infected = GetClientOfUserId(GetEventInt(event, "userid"));
    if(IsInfected(infected))
    {
        RemoveFromMap(infected);
    }
}

public void OnInfectedDeath(Event event, const char[] name, bool dontBroadcast)
{
    int infected = GetEventInt(event, "infected_id");
    RemoveFromMap(infected);
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // Reanudar timers para jugadores con tiempo pendiente al iniciar ronda
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsClientInGame(i) || IsFakeClient(i))
            continue;

        // Si el jugador ya tiene duracion activa, reanudar timer
        if(durations[i] > 0 && timers[i] == null)
        {
            timers[i] = CreateTimer(1.0, CountDown, i, TIMER_REPEAT);
            continue;
        }

        // Si no tiene duracion activa, intentar restaurar de pendientes (por SteamID)
        if(durations[i] <= 0)
        {
            RestorePlayerDuration(i);
        }
    }
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    // Pausar timers y guardar tiempo restante por SteamID (sin borrarlo)
    for(int i = 1; i <= MAXPLAYERS; i++)
    {
        if(durations[i] > 0)
        {
            SavePlayerDuration(i);
            KillTimerSafety(timers[i]);
            durations[i] = 0;
        }
    }
    infecteds.Clear();
    SaveDurationsToFile();
}

// ============================================================================
//  MAPA DE INFECTADOS
// ============================================================================

void AddToMap(int entity, int headRefEntity)
{
    char num[8];
    Format(num, 8, "%d", entity);
    if(!infecteds.ContainsKey(num))
    {
        infecteds.SetValue(num, headRefEntity);
    }
}

void RemoveFromMap(int entity)
{
    char num[8];
    Format(num, 8, "%d", entity);
    if(infecteds.ContainsKey(num))
    {
        infecteds.Remove(num);
    }
}

public bool TraceFilterCommon(int entity, int contentsMask, int self)
{
    if(!IsCommonInfected(entity))
    {
        return false;
    }
    return true;
}

public bool TraceFilterSpecial(int entity, int contentsMask, int self)
{
    if(!IsInfected(entity))
    {
        return false;
    }
    return true;
}

// ============================================================================
//  PERSISTENCIA DE DURACIONES (entre rondas y sesiones)
// ============================================================================

// Guarda el tiempo restante del jugador en pendingDurations usando su SteamID
void SavePlayerDuration(int client)
{
    if(durations[client] <= 0)
        return;

    char auth[32];
    if(!GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth)))
        return;

    pendingDurations.SetValue(auth, durations[client], true);
}

// Restaura el tiempo pendiente del jugador desde pendingDurations (por SteamID)
void RestorePlayerDuration(int client)
{
    // Si ya tiene duracion activa, no sobrescribir
    if(durations[client] > 0)
        return;

    if(!IsClientValid(client) || IsFakeClient(client))
        return;

    char auth[32];
    if(!GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth)))
        return;

    int remaining = 0;
    if(pendingDurations.GetValue(auth, remaining) && remaining > 0)
    {
        durations[client] = remaining;
        // Remover de pendientes para evitar restauracion fantasma tras expirar
        pendingDurations.Remove(auth);

        // Iniciar timer si aun no esta corriendo
        if(timers[client] == null)
        {
            timers[client] = CreateTimer(1.0, CountDown, client, TIMER_REPEAT);
        }

        PrintToChat(client, "%s Auto-Aim \x04reanudado\x01. Tiempo restante: \x04%d\x01 segundos.", PLUGIN_PREFIX, remaining);
    }
}

// Guarda pendingDurations + duraciones activas a un archivo KeyValues
void SaveDurationsToFile()
{
    KeyValues kv = new KeyValues("auto_aim");

    // Primero, guardar todas las duraciones pendientes (jugadores desconectados)
    StringMapSnapshot snap = pendingDurations.Snapshot();
    char key[32];
    int value;
    for(int i = 0; i < snap.Length; i++)
    {
        snap.GetKey(i, key, sizeof(key));
        if(pendingDurations.GetValue(key, value) && value > 0)
        {
            kv.SetNum(key, value);
        }
    }
    delete snap;

    // Luego, guardar duraciones activas (sobrescribe si el SteamID ya estaba)
    for(int i = 1; i <= MaxClients; i++)
    {
        if(durations[i] > 0 && IsClientValid(i))
        {
            char auth[32];
            if(GetClientAuthId(i, AuthId_Steam2, auth, sizeof(auth)))
            {
                kv.SetNum(auth, durations[i]);
            }
        }
    }

    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "data/%s", DATA_FILE);
    kv.ExportToFile(path);
    delete kv;
}

// Carga duraciones pendientes desde el archivo al iniciar el plugin
void LoadDurationsFromFile()
{
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "data/%s", DATA_FILE);

    if(!FileExists(path))
        return;

    KeyValues kv = new KeyValues("auto_aim");
    if(!kv.ImportFromFile(path))
    {
        delete kv;
        return;
    }

    if(!kv.GotoFirstSubKey(false))
    {
        delete kv;
        return;
    }

    char key[32];
    int value;
    do
    {
        kv.GetSectionName(key, sizeof(key));
        value = kv.GetNum(NULL_STRING, 0);
        if(value > 0)
        {
            pendingDurations.SetValue(key, value, true);
        }
    } while(kv.GotoNextKey(false));

    delete kv;

    PrintToServer("[Auto-Aim] Cargadas %d duraciones pendientes desde archivo.", pendingDurations.Size);
}

// ============================================================================
//  STOCKS
// ============================================================================

stock float GetAngleBetweenTwoDirection(float a[3], float b[3])
{
    float modA = SquareRoot(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
    float modB = SquareRoot(b[0] * b[0] + b[1] * b[1] + b[2] * b[2]);
    float dotProd = GetVectorDotProduct(a, b);
    float cos = dotProd / (modA * modB);
    return RadToDeg(ArcCosine(cos));
}

stock bool IsTank(int entity)
{
    if(IsInfected(entity))
    {
        return GetEntProp(entity, Prop_Send, "m_zombieClass") == 8;
    }
    return false;
}

stock void KillTimerSafety(Handle& timer)
{
    if(timer != null)
    {
        delete timer;
    }
    timer = null;
}

stock bool IsCommonInfected(int entity)
{
    if (entity > 0 && IsValidEntity(entity))
    {
        char classname[16];
        GetEntityClassname(entity, classname, 16);
        return StrEqual(classname, "infected", false);
    }
    return false;
}

stock bool IsClientValid(int client)
{
    return 1 <= client && client <= MaxClients && IsClientInGame(client);
}

stock bool IsRealClient(int client)
{
    return IsClientValid(client) && !IsFakeClient(client);
}

stock bool IsSurvivor(int client)
{
    return IsClientValid(client) && GetClientTeam(client) == TEAM_SURVIVOR;
}

stock bool IsInfected(int client)
{
    return IsClientValid(client) && GetClientTeam(client) == TEAM_INFECTED;
}
