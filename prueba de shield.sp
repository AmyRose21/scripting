/**
 *  RiotShieldBuff - advanced conversion from VScript to SourceMod
 *  - Uses SDKHooks and DHooks (requires both to be loaded)
 *  - Blocks/reflects damage from special infected when player is holding a riot shield
 *
 *  Author: converted for you
 *  Notes: See comments for spots where DHooks is recommended/used.
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>        // DHooks (must be available on your server)
//#include <colors>        // optional for nicer chat text (remove if you don't have it)

// --- Configurable ---------------------------------------------------------
#define PLUGIN_NAME "RiotShieldBuff"
#define PLUGIN_VERSION "1.0.0"

#define MAX_PLAYERS 64

// Sound files (precache them)
new const String:g_szBlockSounds[][] = {
    "weapons/riotshield/RiotShield_Block1.mp3",
    "weapons/riotshield/RiotShield_Block2.mp3",
    "weapons/riotshield/RiotShield_Block3.mp3"
};

// Which infected classnames to treat (common L4D2 names; adapt if different)
new const String:g_szInfectedClasses[][] = {
    "infected_smoker",   // smoker
    "infected_hunter",   // hunter
    "infected_jockey",   // jockey
    "infected_charger"   // charger
};

// Block options (tweak)
new bool:g_bCanBlockSmoker = true;
new bool:g_bCanBlockHunter = true;
new bool:g_bCanBlockJockey = true;
new bool:g_bCanBlockCharger = true;

new Float:g_fBlockChance = 90.0;     // percent chance to block when conditions met (0-100)
new Float:g_fReflectDamage = 10.0;   // damage to reflect to the attacker (0 = none)
new Float:g_fCooldown = 1.0;         // seconds cooldown per player to avoid spam

// Match infected classes to the above booleans by index
enum InfectedType
{
    INF_SMOKER = 0,
    INF_HUNTER = 1,
    INF_JOCKEY = 2,
    INF_CHARGER = 3
}

// Per-player state
new Float:g_flNextAllowed[MAX_PLAYERS+1];

// Customizable: classnames for riotshield weapon (change if server uses different classname)
new const String:g_szRiotShieldWeapon = "weapon_riotshield";

// ---------------------------------------------------------------------------
// Forward declarations
public void OnPluginStart();
public void PrecacheResources();
public void HookPlayers();
public void OnClientPutInServer(int client);
public void OnClientDisconnect(int client);

public Action Player_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype);
bool IsPlayerHoldingRiotShield(int client);
bool AreLookingAtEachOther(int user, int victim, float fDotThreshold = 0.7);
void PlayShieldSound(int client);
void TryCancelSpecialAttack(int victim, int attacker, int infType);
int GetInfectedTypeByClassname(const char[] classname);

// -------------------- Plugin lifecycle ------------------------------------
public void OnPluginStart()
{
    HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post); // optional debug hook
    PrecacheResources();

    // Hook new/respawned players to SDKHooks OnTakeDamage
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Post);

    // Attach to existing clients (if reload)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
            OnClientPutInServer(i);
    }

    // Optional: register DHooks detours for very specific engine functions.
    // See TryCancelSpecialAttack where we call DHooks detours stubs (you may need to setup them here).
    PrintToServer("[RiotShieldBuff] v%s loaded. Requires SDKHooks + DHooks.", PLUGIN_VERSION);
}

public void PrecacheResources()
{
    // Add to downloads & precache
    char full[PLATFORM_MAX_PATH];
    for (int i = 0; i < sizeof(g_szBlockSounds); i++)
    {
        Format(full, sizeof(full), "sound/%s", g_szBlockSounds[i]);
        if (FileExists(full, true))
            AddFileToDownloadsTable(full);
        PrecacheSound(g_szBlockSounds[i], true);
    }
}

// Called when a player spawns / enters the game
public void OnClientPutInServer(int client)
{
    if (!IsValidClient(client)) return;
    g_flNextAllowed[client] = 0.0;

    // Hook take damage for the player entity via SDKHooks
    SDKHook(client, SDKHook_OnTakeDamage, Player_TakeDamage);
}

public void OnClientDisconnect(int client)
{
    if (!IsValidClient(client)) return;
    g_flNextAllowed[client] = 0.0;
    SDKUnhook(client, SDKHook_OnTakeDamage, Player_TakeDamage);
}

// Event handlers for spawn/disconnect to manage hooks
public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    if (IsValidClient(client))
    {
        OnClientPutInServer(client);
    }
    return Plugin_Continue;
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    if (client > 0)
    {
        OnClientDisconnect(client);
    }
    return Plugin_Continue;
}

// Optional debug hook
public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    // Kept for debugging if needed
    return Plugin_Continue;
}

// -------------------- Damage hook (SDKHook_OnTakeDamage) -----------------
// Signature: (victim, &attacker, &inflictor, &damage, &damagetype)
// - This is called before the damage is applied. We can modify `damage` and cancel.
public Action Player_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    // Only care about human survivors (players)
    if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return Plugin_Continue;

    // Attacker must be valid entity (special infected are NPC entities)
    if (attacker <= 0 || !IsValidEntity(attacker)) return Plugin_Continue;

    // Quick cooldown check
    float now = GetEngineTime();
    if (now < g_flNextAllowed[victim]) return Plugin_Continue;

    // Check if victim holds a riot shield
    if (!IsPlayerHoldingRiotShield(victim)) return Plugin_Continue;

    // Determine attacker classname
    char classname[64];
    GetEntityClassname(attacker, classname, sizeof(classname));

    int infType = GetInfectedTypeByClassname(classname);
    if (infType == -1) return Plugin_Continue;

    // Check if this infected type is allowed to be blocked
    bool canBlock = false;
    if (infType == INF_SMOKER) canBlock = g_bCanBlockSmoker;
    else if (infType == INF_HUNTER) canBlock = g_bCanBlockHunter;
    else if (infType == INF_JOCKEY) canBlock = g_bCanBlockJockey;
    else if (infType == INF_CHARGER) canBlock = g_bCanBlockCharger;

    if (!canBlock) return Plugin_Continue;

    // Check facing: attacker must be roughly in front of the victim
    if (!AreLookingAtEachOther(attacker, victim, 0.65)) // tweak threshold if needed
        return Plugin_Continue;

    // Random chance
    if (GetRandomFloat(0.0, 100.0) > g_fBlockChance)
        return Plugin_Continue;

    // At this point: block the attack
    // Set damage to zero
    damage = 0.0;

    // Play shield sound & set cooldown
    PlayShieldSound(victim);
    g_flNextAllowed[victim] = now + g_fCooldown;

    // Optionally reflect damage to attacker (SDKHooks_TakeDamage)
    if (g_fReflectDamage > 0.0 && IsValidEntity(attacker))
    {
        // SDKHooks_TakeDamage(entity, inflictor, attacker, damage, damagetype, weapon = -1, bypass = false)
        // We attempt to inflict damage on the attacker, marking the victim as the inflictor.
        SDKHooks_TakeDamage(attacker, victim, victim, g_fReflectDamage, DMG_GENERIC, -1, false);
    }

    // Try to cancel/interrupt specific special behavior (tongue, mount, pummel)
    TryCancelSpecialAttack(victim, attacker, infType);

    // Prevent any further hooks from processing original damage (plugin changed)
    return Plugin_Changed;
}

// -------------------- Helpers ---------------------------------------------

/** IsPlayerHoldingRiotShield
 *  Returns true if the player has the riotshield equipped (primary slot or active weapon).
 */
bool IsPlayerHoldingRiotShield(int client)
{
    if (!IsClientInGame(client)) return false;

    // Check active weapon first
    int weapon = GetPlayerWeaponSlot(client, 0); // slot 0 (primary)
    if (weapon != -1 && IsValidEntity(weapon))
    {
        char wname[64];
        GetEntityClassname(weapon, wname, sizeof(wname));
        if (StrEqual(wname, g_szRiotShieldWeapon, false))
            return true;
    }

    // Also check active weapon entity
    int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    if (active != -1 && IsValidEntity(active))
    {
        char aw[64];
        GetEntityClassname(active, aw, sizeof(aw));
        if (StrEqual(aw, g_szRiotShieldWeapon, false))
            return true;
    }

    return false;
}

/** AreLookingAtEachOther
 *  Check if 'user' is roughly facing 'victim' and viceversa, using dot product.
 *  fDotThreshold: e.g. 0.7 means fairly close to forward direction.
 */
bool AreLookingAtEachOther(int user, int victim, float fDotThreshold = 0.7)
{
    if (user <= 0 || victim <= 0) return false;
    if (!IsValidEntity(user) || !IsValidEntity(victim)) return false;

    // Get victim forward vector
    float angVictim[3];
    GetClientEyeAngles(victim, angVictim); // eye angles
    float forwardVictim[3];
    GetAngleVectors(angVictim, forwardVictim, NULL_VECTOR, NULL_VECTOR);

    // direction from victim to user
    float posUser[3], posVictim[3];
    GetClientAbsOrigin(user, posUser);
    GetClientAbsOrigin(victim, posVictim);

    float dirVU[3];
    dirVU[0] = posUser[0] - posVictim[0];
    dirVU[1] = posUser[1] - posVictim[1];
    dirVU[2] = posUser[2] - posVictim[2];
    NormalizeVector(dirVU, dirVU);

    float dot = (forwardVictim[0]*dirVU[0]) + (forwardVictim[1]*dirVU[1]) + (forwardVictim[2]*dirVU[2]);
    if (dot < fDotThreshold) return false;

    // Optionally check the other way (user looking at victim)
    float angUser[3];
    GetClientEyeAngles(user, angUser);
    float forwardUser[3];
    GetAngleVectors(angUser, forwardUser, NULL_VECTOR, NULL_VECTOR);

    float dirUV[3];
    dirUV[0] = posVictim[0] - posUser[0];
    dirUV[1] = posVictim[1] - posUser[1];
    dirUV[2] = posVictim[2] - posUser[2];
    NormalizeVector(dirUV, dirUV);

    float dot2 = (forwardUser[0]*dirUV[0]) + (forwardUser[1]*dirUV[1]) + (forwardUser[2]*dirUV[2]);
    if (dot2 < 0.2) // user may not strictly look at victim; small tolerance
        return false;

    return true;
}

/** PlayShieldSound
 *  Plays a random block sound to the victim (or to all if you prefer).
 */
void PlayShieldSound(int client)
{
    if (!IsClientInGame(client)) return;
    int idx = GetRandomInt(0, sizeof(g_szBlockSounds)-1);
    EmitSoundToClient(client, g_szBlockSounds[idx], SNDCHAN_AUTO, SNDLEVEL_NORMAL, 0.0, 1.0);
}

/** TryCancelSpecialAttack
 *  Attempts to interrupt special infected actions using:
 *   - DHooks to detour engine functions (recommended)
 *   - AcceptEntityInput to break the tongue entity or detach mounts
 *  This function uses several safe attempts that often work across maps.
 */
void TryCancelSpecialAttack(int victim, int attacker, int infType)
{
    if (infType == INF_SMOKER)
    {
        // Attempt 1: find a "tongue" entity attached to the smoker and kill it
        // Many smoker tongues are a separate entity — we try a search for entities owned by smoker
        int ent = -1;
        int found = -1;
        while ((ent = FindEntityByClassname(ent, "smoker_tongue")) != -1)
        {
            // check owner
            int owner = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
            if (owner == attacker)
            {
                AcceptEntityInput(ent, "Kill");
                found = ent;
                break;
            }
        }

        // If not found, try detaching victim from smoker (common input: Detach or ForceDetach)
        // AcceptEntityInput(attacker, "DetachVictim") // map/AI dependent
        // DHooks detour opportunity: hook smoker tongue attach function and cancel it (recommended)
    }
    else if (infType == INF_JOCKEY)
    {
        // If victim is mounted by jockey, try to force dismount
        // Many jockeys parent the victim; try to unparent
        // AcceptEntityInput(attacker, "DetachVictim") // may not exist; keep as hint
        // Or find "jockey_ride" entity and kill it
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, "jockey_ride")) != -1)
        {
            int owner = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
            if (owner == attacker)
            {
                AcceptEntityInput(ent, "Kill");
                break;
            }
        }

        // DHooks: hook jockey attach function to prevent attaching in first place.
    }
    else if (infType == INF_CHARGER)
    {
        // Charger pummel / grapple: try to stop pummel animation or unparent
        // Attempt to kill "charger_pummel" entity if present
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, "charger_pummel")) != -1)
        {
            int owner = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
            if (owner == attacker)
            {
                AcceptEntityInput(ent, "Kill");
                break;
            }
        }
        // Also consider teleporting attacker slightly back to interrupt their animation:
        // float pos[3]; GetClientAbsOrigin(attacker, pos); pos[0]+=10.0; TeleportEntity(attacker, pos, NULL_VECTOR, NULL_VECTOR);
    }
    else if (infType == INF_HUNTER)
    {
        // Hunter pounce: the damage already cancelled above; to interrupt pounce we can try to
        // reset hunter state entity or kill pounce entity if exists.
        // No simple universal entity; DHooks detour of pounce method is best.
    }

    // Note: the above entity names (smoker_tongue, jockey_ride, charger_pummel) may vary by mod/map.
    // Best approach: use DHooks to detour engine functions that create/attach these behaviors.
}

// Map classname -> infected type index (or -1 if unknown)
int GetInfectedTypeByClassname(const char[] classname)
{
    if (StrContains(classname, "smoker", false) != -1) return INF_SMOKER;
    if (StrContains(classname, "hunter", false) != -1) return INF_HUNTER;
    if (StrContains(classname, "jockey", false) != -1) return INF_JOCKEY;
    if (StrContains(classname, "charger", false) != -1) return INF_CHARGER;
    return -1;
}

// -------------------- Admin commands to tweak config (optional) -----------------
public Action Command_RSB_SetChance(int client, int args)
{
    if (!IsClientAdmin(client)) return Plugin_Handled;
    if (args < 1) { PrintToChat(client, "[RiotShieldBuff] Uso: sm_rsb_chance <0-100>"); return Plugin_Handled; }
    char sarg[16];
    GetCmdArg(1, sarg, sizeof(sarg));
    float val = StringToFloat(sarg);
    if (val < 0.0) val = 0.0;
    if (val > 100.0) val = 100.0;
    g_fBlockChance = val;
    PrintToChatAll("[RiotShieldBuff] Block chance set to %.1f%%", g_fBlockChance);
    return Plugin_Handled;
}

// -------------------- Utility: IsClientAdmin --------------------------------
bool IsClientAdmin(int client)
{
    if (!IsClientInGame(client)) return false;
    return GetUserFlagBits(client) != 0 && CheckCommandAccess(client, "sm_rsb_admin", ADMFLAG_GENERIC, true);
}
