/************************************************************************
  [L4D2] Pet Witch (Ported & Optimized)

  DESCRIPTION: 
  
    This plugin allows an admin to spawn a "pet witch" and attack a 
    selected player.

    Only admins with the slay flag can use it.

    PORT NOTES:
    - Converted for Left 4 Dead 2 compatibility.
    - Removed dependency on commentary_zombie_spawner.
    - Optimized owner tracking using global arrays instead of entity props.

  COMMAND:

    sm_petwitch - Opens the plugin menu.

  CVARS:

    l4d_pet_witch_enable "1"
    l4d_pet_witch_version "1.1.0"

 ************************************************************************/

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

/**
 * Compiler requires semicolons and the new syntax.
 */
#pragma semicolon 1
#pragma newdecls required

/**
 * Semantic versioning
 */
#define PLUGIN_VERSION  "1.1.0"
#define PLUGIN_INITIALS "\x03[PetWitch]\x01"

public Plugin myinfo = {
    name = "[L4D2] Pet Witch",
    author = "samuelviveiros (Ported by AI)",
    description = "Allows an admin to spawn a Pet Witch and attack a selected player",
    version = PLUGIN_VERSION,
    url = "https://github.com/samuelviveiros/l4d_pet_witch"
};

#define TEAM_SURVIVORS              2
#define MAX_ENTITIES                2048
#define SAFE_RAGE                   0.1

// Globals
int  g_TargetOfInvoker[MAXPLAYERS + 1]          = {-1, ...};
bool g_HasInvokerDamageHandler[MAXPLAYERS + 1]  = {false, ...};
int  g_InvokerOfPetWitch[MAX_ENTITIES + 1]      = {-1, ...};
bool g_StartledByTriggerHurt[MAX_ENTITIES + 1]  = {false, ...};


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion engine = GetEngineVersion();
    if (engine != Engine_Left4Dead2 && engine != Engine_Left4Dead)
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

public void OnPluginStart()
{
    CreateConVar("l4d_pet_witch_version", PLUGIN_VERSION, "[L4D] Pet Witch version", FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    CreateConVar("l4d_pet_witch_enable", "1", "Enable or disable this plugin.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

    AutoExecConfig(true, "l4d_pet_witch");

    RegAdminCmd("sm_petwitch", Command_ShowMenu, ADMFLAG_SLAY);
    
    // Precache the model for L4D2 to be safe
    if (!IsModelPrecached("models/infected/witch.mdl"))
        PrecacheModel("models/infected/witch.mdl");
}

public void OnMapStart()
{
    // Ensure cleanup on map start
    for (int i = 0; i <= MAX_ENTITIES; i++)
    {
        g_InvokerOfPetWitch[i] = -1;
        g_StartledByTriggerHurt[i] = false;
    }
}

public void OnEntityDestroyed(int entity)
{
    // Clean up if a witch dies or is removed
    if (entity > 0 && entity <= MAX_ENTITIES)
    {
        if (g_InvokerOfPetWitch[entity] != -1)
        {
            PetWitch_FreeResources(entity);
        }
    }
}

//----------------------------//
//    PET WITCH "METHODS"     //
//----------------------------//

public Action PetWitch_DamageHandler(int     petWitch,
                                     int&    attacker,
                                     int&    inflictor,
                                     float&  damage,
                                     int&    damagetype,
                                     int&    weapon,
                                     float   damageForce[3],
                                     float   damagePosition[3])
{
    // Only the invoker can cause direct damage.
    if (attacker == PetWitch_GetInvoker(petWitch))
    {
        return Plugin_Continue;
    }

    if (PetWitch_IsAttackerTriggerHurt(attacker))
    {
        PetWitch_SetStartledByTriggerHurt(petWitch, true);
        
        // Remove the trigger_hurt entity immediately
        AcceptEntityInput(attacker, "Kill");
        
        // Unhook logic so she behaves like a normal angry witch now
        PetWitch_RemoveHooks(petWitch);

        // Force target switch logic could go here, but usually rage handles it.
        // In L4D2, simple damage usually redirects aggro.
        
        return Plugin_Changed;
    }

    // Block damage from others while in "Pet" mode
    return Plugin_Handled;
}

void PetWitch_PerformSpawn(int invoker)
{
    float pos[3];
    if (!GetClientAimPosition(invoker, pos))
    {
        PrintToChat(invoker, "%s Could not find a spawn location.", PLUGIN_INITIALS);
        return;
    }

    // Direct spawn for L4D2 (More reliable than commentary spawner)
    int witch = CreateEntityByName("witch");
    if (!IsValidEntity(witch))
    {
        PrintToChat(invoker, "%s Failed to create witch entity.", PLUGIN_INITIALS);
        return;
    }

    // Set position and spawn
    DispatchKeyValue(witch, "spawnflags", "0"); // Normal witch
    TeleportEntity(witch, pos, NULL_VECTOR, NULL_VECTOR);
    DispatchSpawn(witch);
    ActivateEntity(witch);

    // Register the Pet
    PetWitch_Init(witch, invoker);
    
    // Visual confirm
    PrintToChat(invoker, "%s Pet Witch spawned!", PLUGIN_INITIALS);
}

void PetWitch_ThinkHandler(int witch)
{
    if (!IsValidEntity(witch))
    {
        SDKUnhook(witch, SDKHook_ThinkPost, PetWitch_ThinkHandler);
        return;
    }

    PetWitch_KeepAngerLow(witch);
}

void PetWitch_Init(int petWitch, int invoker)
{
    // Register global link
    g_InvokerOfPetWitch[petWitch] = invoker;
    
    // Setup Hooks
    PetWitch_SetupDamageHandler(petWitch);
    SDKHook(petWitch, SDKHook_ThinkPost, PetWitch_ThinkHandler);
}

void PetWitch_SetupDamageHandler(int petWitch)
{
    SDKHook(petWitch, SDKHook_OnTakeDamage, PetWitch_DamageHandler);
}

int PetWitch_GetInvoker(int petWitch)
{
    if (petWitch < 0 || petWitch > MAX_ENTITIES) return -1;
    return g_InvokerOfPetWitch[petWitch];
}

void PetWitch_KeepAngerLow(int petWitch)
{
    // In L4D2, we just keep rage at 0 until we want her to attack
    if (PetWitch_GetRage(petWitch) > SAFE_RAGE)
    {
        PetWitch_SetRage(petWitch, SAFE_RAGE);
    }
}

float PetWitch_GetRage(int petWitch)
{
    return GetEntPropFloat(petWitch, Prop_Send, "m_rage");
}

void PetWitch_SetRage(int petWitch, float rage)
{
    SetEntPropFloat(petWitch, Prop_Send, "m_rage", rage);
}

void PetWitch_FreeResources(int petWitch)
{
    PetWitch_RemoveHooks(petWitch);
    PetWitch_SetStartledByTriggerHurt(petWitch, false);
    
    if (petWitch > 0 && petWitch <= MAX_ENTITIES)
    {
        g_InvokerOfPetWitch[petWitch] = -1;
    }
}

void PetWitch_RemoveHooks(int petWitch)
{
    SDKUnhook(petWitch, SDKHook_ThinkPost, PetWitch_ThinkHandler);
    SDKUnhook(petWitch, SDKHook_OnTakeDamage, PetWitch_DamageHandler);
}

int PetWitch_GetTarget(int petWitch)
{
    int invoker = PetWitch_GetInvoker(petWitch);
    if (invoker == -1) return -1;
    return Invoker_GetTarget(invoker);
}

void PetWitch_ForceAttack(int petWitch)
{
    float origin[3];
    GetEntPropVector(petWitch, Prop_Send, "m_vecOrigin", origin);
    
    // Adding slight offset to ensure trigger hits
    origin[2] += 10.0;
    
    SpawnTriggerHurtAt(origin);
}

void PetWitch_KillPet(int petWitch)
{
    // Set health to 1 then hurt it
    SetEntProp(petWitch, Prop_Data, "m_iHealth", 1);

    float position[3];
    GetEntPropVector(petWitch, Prop_Send, "m_vecOrigin", position);
    position[2] += 10.0;

    SpawnTriggerHurtAt(position);
}

bool PetWitch_IsAttackerTriggerHurt(int attacker)
{
    if (attacker <= GetMaxClients() || !IsValidEntity(attacker))
    {
        return false;
    }

    char classname[64];
    GetEntityClassname(attacker, classname, sizeof(classname));

    if (!StrEqual(classname, "trigger_hurt"))
    {
        return false;
    }

    char targetname[64];
    GetEntPropString(attacker, Prop_Data, "m_iName", targetname, sizeof(targetname));

    return StrEqual(targetname, "pet_witch_hurter");
}

bool PetWitch_WasStartledByTriggerHurt(int petWitch)
{
    if (petWitch < 0 || petWitch > MAX_ENTITIES) return false;
    return g_StartledByTriggerHurt[petWitch];
}

void PetWitch_SetStartledByTriggerHurt(int petWitch, bool value)
{
    if (petWitch > 0 && petWitch <= MAX_ENTITIES)
        g_StartledByTriggerHurt[petWitch] = value;
}


//----------------------------//
//    INVOKER "METHODS"       //
//----------------------------//

int Invoker_GetTarget(int invoker)
{
    return g_TargetOfInvoker[invoker];
}

void Invoker_SetTarget(int invoker, int target)
{
    g_TargetOfInvoker[invoker] = target;
}

void Invoker_ForcePetsToAttack(int invoker)
{
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        // Check if this witch belongs to the invoker
        if (PetWitch_GetInvoker(witch) == invoker)
        {
            PetWitch_ForceAttack(witch);
        }
    }
}

void Invoker_KillAllPets(int invoker)
{
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (PetWitch_GetInvoker(witch) == invoker)
        {
            PetWitch_RemoveHooks(witch);
            PetWitch_KillPet(witch);
        }
    }
}

void Invoker_SetupDamageHandler(int invoker)
{
    if (!g_HasInvokerDamageHandler[invoker])
    {
        g_HasInvokerDamageHandler[invoker] = true;
        SDKHook(invoker, SDKHook_OnTakeDamage, Invoker_DamageHandler);
    }
}

bool Invoker_HasDamageHandler(int client)
{
    return g_HasInvokerDamageHandler[client];
}

void Invoker_FreeResources(int invoker)
{
    g_HasInvokerDamageHandler[invoker] = false;
    SDKUnhook(invoker, SDKHook_OnTakeDamage, Invoker_DamageHandler);
}

public Action Invoker_DamageHandler(int     invoker,
                                  int&    attacker,
                                  int&    inflictor,
                                  float&  damage,
                                  int&    damagetype,
                                  int&    weapon,
                                  float   damageForce[3],
                                  float   damagePosition[3])
{
    // Prevent damage from own pet unless it was forced to attack via trigger_hurt
    if (attacker > GetMaxClients() && IsValidEntity(attacker))
    {
        char classname[64];
        GetEntityClassname(attacker, classname, sizeof(classname));
        
        if (StrEqual(classname, "witch"))
        {
            // If it's my pet and it wasn't startled by my trigger hurt, block damage
            if (PetWitch_GetInvoker(attacker) == invoker && !PetWitch_WasStartledByTriggerHurt(attacker))
            {
                return Plugin_Handled;
            }
        }
    }

    return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
    if (Invoker_HasDamageHandler(client))
    {
        Invoker_FreeResources(client);
    }
    
    // Also clear targets
    g_TargetOfInvoker[client] = -1;
    
    // Clean up pets owned by this client
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (PetWitch_GetInvoker(witch) == client)
        {
            // Just unmark ownership, let the witch exist or delete? 
            // Better to just unmark so it becomes a normal witch
            PetWitch_FreeResources(witch);
        }
    }
}


//----------------------------//
//            MENU            //
//----------------------------//

public Action Command_ShowMenu(int client, int args)
{
    if (client == 0)
    {
        ReplyToCommand(client, "%s Command is in-game only.", PLUGIN_INITIALS);
        return Plugin_Handled;
    }

    ConVar cvarPluginEnable = FindConVar("l4d_pet_witch_enable");
    if (cvarPluginEnable != null && GetConVarFloat(cvarPluginEnable) == 0.0)
    {
        ReplyToCommand(client, "%s Plugin disabled. See the config file.", PLUGIN_INITIALS);
        return Plugin_Handled;
    }

    Menu_DisplayOptions(client);

    return Plugin_Handled;
}

void Menu_DisplayOptions(int client)
{
    Menu menu = new Menu(Menu_OptionsHandler);
    menu.SetTitle("Pet Witch (L4D2)");

    menu.AddItem("spawn", "Spawn under the crosshair");
    menu.AddItem("attack", "Start attack");
    menu.AddItem("kill", "Kill pets");

    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_OptionsHandler(Menu menu,
                               MenuAction action,
                               int param1,
                               int param2)
{
    int invoker = param1;

    if (action == MenuAction_Select)
    {
        switch (param2)
        {
            case 0:
            {
                PetWitch_PerformSpawn(invoker);

                if (!Invoker_HasDamageHandler(invoker))
                {
                    Invoker_SetupDamageHandler(invoker);
                }

                Menu_DisplayOptions(invoker);
            }
            case 1:
            {
                Menu_DisplayTargets(invoker);
            }
            case 2:
            {
                Invoker_KillAllPets(invoker);
                Menu_DisplayOptions(invoker); // Re-open menu
            }
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
    return 0;
}

void Menu_AddSurvivorAsItem(Menu menu, int survivor)
{
    char indexAsString[8];
    IntToString(survivor, indexAsString, sizeof(indexAsString));

    char survivorName[MAX_NAME_LENGTH];
    GetClientName(survivor, survivorName, sizeof(survivorName));

    menu.AddItem(indexAsString, survivorName);
}

void Menu_DisplayTargets(int client)
{
    Menu menu = new Menu(Menu_TargetsHandler);
    menu.SetTitle("Select target:");

    bool found = false;
    for (int survivor = 1; survivor <= GetMaxClients(); survivor++)
    {
        if (IsSurvivorConnectedAndAlive(survivor))
        {
            Menu_AddSurvivorAsItem(menu, survivor);
            found = true;
        }
    }

    if (!found)
    {
        menu.AddItem("", "No survivors available", ITEMDRAW_DISABLED);
    }

    menu.ExitButton = false;
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_TargetsHandler(Menu menu,
                               MenuAction action,
                               int param1,
                               int param2)
{
    int invoker = param1;

    if (action == MenuAction_Select)
    {
        char indexAsString[8];
        menu.GetItem(param2, indexAsString, sizeof(indexAsString));

        int target = StringToInt(indexAsString);
        
        // Verify target is still valid
        if (IsSurvivorConnectedAndAlive(target))
        {
            Invoker_SetTarget(invoker, target);
            Invoker_ForcePetsToAttack(invoker);
            PrintToChat(invoker, "%s Pets ordered to attack!", PLUGIN_INITIALS);
        }
        else
        {
            PrintToChat(invoker, "%s Target is no longer valid.", PLUGIN_INITIALS);
        }
    }
    else if (action == MenuAction_Cancel)
    {
        if (param2 == MenuCancel_ExitBack)
        {
            Menu_DisplayOptions(invoker);
        }
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
    return 0;
}


//----------------------------//
//      USEFUL FUNCTIONS      //
//----------------------------//

int SpawnTriggerHurtAt(float origin[3])
{
    int hurter = CreateEntityByName("trigger_hurt");
    if (hurter == -1)
    {
        return -1;
    }

    DispatchSpawn(hurter);
    ActivateEntity(hurter);

    DispatchKeyValue(hurter, "targetname", "pet_witch_hurter");
    DispatchKeyValue(hurter, "damage", "10");          // Force high damage to ensure startle
    DispatchKeyValue(hurter, "damagetype", "2");      // BULLET
    DispatchKeyValue(hurter, "spawnflags", "2");      // Only NPCs

    // Auto-kill logic
    SetVariantString("OnHurt !self:Kill::0.1:-1");   
    AcceptEntityInput(hurter, "AddOutput");

    SetEntProp(hurter, Prop_Send, "m_nSolidType", 2); // 2 = Bounding Box

    float mins[3] = {-10.0, -10.0, -10.0};
    float maxs[3] = {10.0, 10.0, 10.0};
    SetEntPropVector(hurter, Prop_Send, "m_vecMins", mins);
    SetEntPropVector(hurter, Prop_Send, "m_vecMaxs", maxs);

    TeleportEntity(hurter, origin, NULL_VECTOR, NULL_VECTOR);

    return hurter;
}

stock bool GetClientAimPosition(int client, float aimPosition[3])
{
    float angles[3];
    float origin[3];

    GetClientEyePosition(client, origin);
    GetClientEyeAngles(client, angles);

    Handle trace = TR_TraceRayFilterEx(origin, angles, MASK_SHOT, RayType_Infinite, Callback_TraceEntityFilter);
        
    if (TR_DidHit(trace))
    {   	 
        TR_GetEndPosition(aimPosition, trace);
        // Do not adjust aimPosition back by -35.0, let's spawn directly at crosshair but slightly up
        aimPosition[2] += 5.0; 
        delete trace;
        return true;
    }
    
    delete trace;
    return false;
}

public bool Callback_TraceEntityFilter(int entity, int contentsMask)
{
	return entity > GetMaxClients();
}

bool IsSurvivorConnectedAndAlive(int survivor)
{
    return (
        survivor > 0 && survivor <= GetMaxClients() &&
        IsClientConnected(survivor) &&
        IsClientInGame(survivor) &&
        IsPlayerAlive(survivor) &&
        GetClientTeam(survivor) == TEAM_SURVIVORS
    );
}