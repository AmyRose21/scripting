#if defined _pure_play_as_si_charger_included
 #endinput
#endif
#define _pure_play_as_si_charger_included

ConVar g_hCvarChargerHp;
ConVar g_hCvarChargerClawDmg;
ConVar g_hCvarChargerAbilityCooldown;
ConVar g_hCvarChargerImpactDmg;
ConVar g_hCvarChargerImpactRadius;
ConVar g_hCvarChargerHealPoint;

void AddChargerConVars()
{
    char desc[64];
    Format(desc, 64, "%t", "ConVar Charger HP");
    g_hCvarChargerHp = CreateConVar("l4d2_play_as_si_charger_hp", "400", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Charger Claw Damage");
    g_hCvarChargerClawDmg = CreateConVar("l4d2_play_as_si_charger_claw_dmg", "100", desc, 0, true, 10.0);
    Format(desc, 64, "%t", "ConVar Charger Ability Cooldown");
    g_hCvarChargerAbilityCooldown = CreateConVar("l4d2_play_as_si_charger_ability_cooldown", "3.0", desc, 0, true, 1.0);
    Format(desc, 64, "%t", "ConVar Charger Impact Damage");
    g_hCvarChargerImpactDmg = CreateConVar("l4d2_play_as_si_charger_impact_dmg", "500.0", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Charger Impact Radius");
    g_hCvarChargerImpactRadius = CreateConVar("l4d2_play_as_si_charger_impact_radius", "500.0", desc, 0, true, 50.0);
    Format(desc, 64, "%t", "ConVar Charger Heal");
    g_hCvarChargerHealPoint = CreateConVar("l4d2_play_as_si_charger_heal_point", "200.0", desc, 0, true, 100.0);

    HookEvent("charger_charge_end", OnChargerChargeEnd);
}

public void OnChargerChargeEnd(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(!IsSurvivor(client) || g_hPlayerZombie[client] == null || g_hPlayerZombie[client].ZombieClass != PLAYABLE_CHARGER)
        return;
    
    SDKUnhook(client, SDKHook_StartTouchPost, SDKHook_Charger_OnStartTouchPost);
    CreateTimer(0.5, Timer_Charger_Cooldown, client, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_Charger_Cooldown(Handle timer, int client)
{
    if(!IsSurvivor(client) || !IsPlayerAlive(client) || g_hPlayerZombie[client] == null || g_hPlayerZombie[client].ZombieClass != PLAYABLE_CHARGER)
    {
        return Plugin_Stop;
    }
    L4D2_SetCustomAbilityCooldown(client, GetConVarFloat(g_hCvarChargerAbilityCooldown));
    return Plugin_Continue;
}

// !rcon sm plugins reload l4d2_play_as_si
public void L4D2_ActivateAbility_Charger_Post(int client, int ability)
{
    if(!IsSurvivor(client)) return;
    
    SDKUnhook(client, SDKHook_StartTouchPost, SDKHook_Charger_OnStartTouchPost);
    SDKHook(client, SDKHook_StartTouchPost, SDKHook_Charger_OnStartTouchPost);
}

void ClearPlayerCharger(int client)
{
    SDKUnhook(client, SDKHook_StartTouchPost, SDKHook_Charger_OnStartTouchPost);
}

void SDKHook_Charger_OnStartTouchPost(int entity, int other)
{
    if(IsInfected(other))
    {
        EmitSoundToClient(entity, SOUND_CHARGER_LOUD_CHARGERIMPACT);
        SDKHooks_TakeDamage(other, entity, entity, GetConVarFloat(g_hCvarChargerImpactDmg), DMG_GENERIC, -1, NULL_VECTOR, NULL_VECTOR, false);
        L4D2_Charger_ThrowImpactedSurvivor(other, entity);
    }
    else
    {
        char classname[9]; GetEntityClassname(other, classname, 9);

        if(classname[0] != 'i' && classname[0] != 'w') return;  //For Performance

        if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
        {
            EmitSoundToClient(entity, SOUND_CHARGER_LOUD_CHARGERIMPACT);
            SDKHooks_TakeDamage(other, entity, entity, GetConVarFloat(g_hCvarChargerImpactDmg), DMG_GENERIC, -1, NULL_VECTOR, NULL_VECTOR, false);
        }
    }
}

public void L4D2_OnChargerImpact(int client)
{
    if(!IsSurvivor(client) || g_hPlayerZombie[client] == null || g_hPlayerZombie[client].ZombieClass != PLAYABLE_CHARGER)
        return;

    SDKUnhook(client, SDKHook_StartTouchPost, SDKHook_Charger_OnStartTouchPost);
    float center[3]; GetAbsOrigin(client, center);
    float target[3];
    
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsInfected(i) || !IsPlayerAlive(i))
            continue;

        GetAbsOrigin(i, target);
        if(GetVectorDistance(center, target) <= GetConVarFloat(g_hCvarChargerImpactRadius))
        {
            SDKHooks_TakeDamage(i, client, client, 1.0, DMG_BLAST, -1, NULL_VECTOR, NULL_VECTOR, false);
            L4D2_Charger_ThrowImpactedSurvivor(i, client);
        }
    }

    for(int i = MAXPLAYERS + 1; i < GetMaxEntities(); i++)
    {
        if(!IsValidEntity(i)) continue;

        char classname[9];
        GetEntityClassname(i, classname, 9);
        
        if(classname[0] != 'i' && classname[0] != 'w') continue;  //For Performance

        if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
        {
            GetAbsOrigin(i, target);
            if(GetVectorDistance(center, target)  <= GetConVarFloat(g_hCvarChargerImpactRadius))
            {
                SDKHooks_TakeDamage(i, client, client, 1.0, DMG_BLAST, -1, NULL_VECTOR, NULL_VECTOR, false);
            }
        }
    }
}