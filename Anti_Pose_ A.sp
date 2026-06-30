#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
    name = "Anti A-Pose / Invisible Weapon Fix",
    author = "ChatGPT & User",
    description = "Arma invisible + Sin Balas + Sin Brazos + Sin HUD (Icono/Mira).",
    version = "7.0"
};

// Flags de HIDEHUD para Source Engine
#define HIDEHUD_WEAPONSELECTION (1 << 0) // Oculta selección de armas y munición
#define HIDEHUD_CROSSHAIR       (1 << 8) // Oculta la mira (Crosshair)

int g_iGhostRef[MAXPLAYERS + 1] = {INVALID_ENT_REFERENCE, ...};

public void OnPluginStart()
{
    HookEvent("player_spawn", OnPlayerSpawn);
    CreateTimer(1.0, Timer_CheckPlayers, _, TIMER_REPEAT);
}

public void OnClientPutInServer(int client)
{
    g_iGhostRef[client] = INVALID_ENT_REFERENCE;
    SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client))
    {
        g_iGhostRef[client] = INVALID_ENT_REFERENCE;
        // Restaurar todo al nacer
        RestorePlayerView(client);
    }
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if (!IsValidClient(client) || !IsPlayerAlive(client))
        return Plugin_Continue;

    int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    int ghostWeapon = EntRefToEntIndex(g_iGhostRef[client]);

    // ¿El jugador tiene el GHOST en la mano?
    if (IsValidEntity(activeWeapon) && activeWeapon == ghostWeapon)
    {
        // 1. BLOQUEAR INPUTS
        if (buttons & IN_ATTACK) buttons &= ~IN_ATTACK;
        if (buttons & IN_RELOAD) buttons &= ~IN_RELOAD;

        // 2. FORZAR MUNICIÓN A 0
        SetEntProp(activeWeapon, Prop_Send, "m_iClip1", 0);
        
        // 3. COOLDOWN INFINITO (No disparar)
        SetEntPropFloat(activeWeapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 1.0);

        // 4. OCULTAR BRAZOS (FPS)
        SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);

        // 5. OCULTAR HUD (Icono de arma y Mira)
        int currentFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
        // Solo aplicamos si faltan los flags para evitar spam de red
        if (!(currentFlags & HIDEHUD_WEAPONSELECTION) || !(currentFlags & HIDEHUD_CROSSHAIR))
        {
            SetEntProp(client, Prop_Send, "m_iHideHUD", currentFlags | HIDEHUD_WEAPONSELECTION | HIDEHUD_CROSSHAIR);
        }

        return Plugin_Changed;
    }
    else
    {
        // SI NO ESTÁ USANDO EL GHOST (Tiene otra arma o ninguna activa)
        // Restauramos la visión y el HUD inmediatamente
        RestorePlayerView(client);
    }
    
    return Plugin_Continue;
}

public Action Timer_CheckPlayers(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2) 
            continue;

        if (!ClientHasAnyWeapon(i))
        {
            GiveGhostWeapon(i);
        }
        else
        {
            CheckAndRemoveGhostIfRedundant(i);
        }
    }
    return Plugin_Continue;
}

void GiveGhostWeapon(int client)
{
    if (IsValidEntity(EntRefToEntIndex(g_iGhostRef[client])))
        return;

    int weapon = CreateEntityByName("weapon_pistol");
    if (weapon == -1) return;

    DispatchSpawn(weapon);
    EquipPlayerWeapon(client, weapon);
    
    g_iGhostRef[client] = EntIndexToEntRef(weapon);

    // Invisibilidad TERCERA PERSONA
    SetEntityRenderMode(weapon, RENDER_NONE);
    SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", 0);
    SetEntProp(weapon, Prop_Send, "m_iClip1", 0);
}

// Función auxiliar para restaurar todo a la normalidad
void RestorePlayerView(int client)
{
    if (!IsValidClient(client)) return;

    // 1. Restaurar Brazos (ViewModel)
    if (GetEntProp(client, Prop_Send, "m_bDrawViewmodel") == 0)
    {
        SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
    }

    // 2. Restaurar HUD (Quitar flags de ocultar)
    int currentFlags = GetEntProp(client, Prop_Send, "m_iHideHUD");
    // Verificamos si tiene nuestros flags activados
    if ((currentFlags & HIDEHUD_WEAPONSELECTION) || (currentFlags & HIDEHUD_CROSSHAIR))
    {
        // Operación Bitwise para quitar SOLO nuestros flags
        int newFlags = currentFlags & ~HIDEHUD_WEAPONSELECTION & ~HIDEHUD_CROSSHAIR;
        SetEntProp(client, Prop_Send, "m_iHideHUD", newFlags);
    }
}

void CheckAndRemoveGhostIfRedundant(int client)
{
    int ghost = EntRefToEntIndex(g_iGhostRef[client]);
    
    if (ghost == -1 || !IsValidEntity(ghost)) 
    {
        g_iGhostRef[client] = INVALID_ENT_REFERENCE;
        return;
    }

    bool hasRealWeapon = false;
    
    for (int slot = 0; slot < 5; slot++)
    {
        int w = GetPlayerWeaponSlot(client, slot);
        if (w > 0 && w != ghost)
        {
            hasRealWeapon = true;
            break;
        }
    }

    if (hasRealWeapon)
    {
        RestorePlayerView(client);
        RemovePlayerItem(client, ghost);
        AcceptEntityInput(ghost, "Kill");
        g_iGhostRef[client] = INVALID_ENT_REFERENCE;
    }
}

public Action OnWeaponDrop(int client, int weapon)
{
    if (!IsValidEntity(weapon)) return Plugin_Continue;

    if (EntIndexToEntRef(weapon) == g_iGhostRef[client])
    {
        RestorePlayerView(client);
        RemovePlayerItem(client, weapon);
        AcceptEntityInput(weapon, "Kill");
        g_iGhostRef[client] = INVALID_ENT_REFERENCE;
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

bool ClientHasAnyWeapon(int client)
{
    for (int i = 0; i < 5; i++)
    {
        int weapon = GetPlayerWeaponSlot(client, i);
        if (weapon > 0) return true;
    }
    return false;
}

bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client));
}