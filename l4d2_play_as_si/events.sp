#if defined _pure_play_as_si_events_included
 #endinput
#endif
#define _pure_play_as_si_events_included

public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
    // Most condition, player is not Survivor-SI
    if(playerStatus[client] && (buttons & IN_RELOAD))
    {
        int victim = L4D_GetVictimHunter(client);
        if(playerStatus[client] == PLAYABLE_HUNTER && victim)
        {
            L4D_Hunter_ReleaseVictim(victim, client);
            return;
        }
        victim = L4D_GetVictimJockey(client);
        if(playerStatus[client] == PLAYABLE_JOCKEY && victim)
        {
            L4D2_Jockey_EndRide(victim, client);
            return;
        }
        victim = L4D_GetVictimSmoker(client);
        if(playerStatus[client] == PLAYABLE_SMOKER && victim)
        {
            L4D_Smoker_ReleaseVictim(victim, client);
            return;
        }
    }
}

public void OnHealSuccess(Event event, const char[] name, bool dontBroadcast)
{
    int patient = GetClientOfUserId(GetEventInt(event, "subject"));
    if(!playerStatus[patient])
    {
        return;
    }

    int amount = -1;
    switch(playerStatus[patient])
    {
        case PLAYABLE_SMOKER:
        {
            amount = GetConVarInt(smokerHealPoint);
        }
        case PLAYABLE_BOOMER:
        {
            amount = GetConVarInt(boomerHealPoint)
        }
        case PLAYABLE_HUNTER:
        {
            amount = GetConVarInt(hunterHealPoint);
        }
        case PLAYABLE_SPITTER:
        {
            amount = GetConVarInt(spitterHealPoint);
        }
        case PLAYABLE_JOCKEY:
        {
            amount = GetConVarInt(jockeyHealPoint)
        }
        case PLAYABLE_CHARGER:
        {
            amount = GetConVarInt(chargerHealPoint);
        }
        case PLAYABLE_TANK:
        {
            amount = GetConVarInt(tankHealPoint);
        }
    }
    if(amount != -1)
    {
        SetPlayerHealth(patient, amount);
    }
}

// Deprecated cause can't detec
// public void OnPlayerJump(Event event, const char[] name, bool dontBroadcast)
// {
//     // short	userid
//     int userid = GetClientOfUserId(GetEventInt(event, "userid"));
//     if(IsSurvivor(userid) && playerStatus[userid] == PLAYABLE_JOCKEY && IsPlayerAlive(userid))
//     {
//         OnJockeyAbilityUse(userid);
//     }
// }

public void OnAbilityUse(Event event, const char[] name, bool dontBroadcast)
{
    int userid = GetClientOfUserId(GetEventInt(event, "userid"));
    if(IsSurvivor(userid))
    {
        char abilityName[16];
        GetEventString(event, "ability", abilityName, 16);
        if(StrEqual(abilityName, "ability_charge", false))
        {
            OnChargerAbilityUse(userid);
        }
        else if(StrEqual(abilityName, "ability_spit", false))
        {
            OnSpitterAbilityUse(userid);
        }
        else if(StrEqual(abilityName, "ability_lunge", false))
        {
            OnHunterAbilityUse(userid);
        }
        else if(StrEqual(abilityName, "ability_tongue", false))
        {
            OnSmokerAbilityUse(userid);
        }
        else if(StrEqual(abilityName, "ability_vomit", false))
        {
            OnBoomerAbilityUse(userid);
        }
        // PrintToChatAll("%s %N", abilityName, userid);
    }
    // short	userid	
    // string	ability	Classname of ability. Possible values:
    //     ability_tongue
    //     ability_vomit
    //     ability_lunge
    //     ability_spit
    //     ability_charge
    //     ability_throw
    //     for the Smoker, Boomer, Hunter, Spitter, Charger and Tank respectively.

    // short	context	enum of the way it was used (different for each ability)
    // Doesn't fire for jockey
}

public void OnPlayerIncapacitated(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    if(playerStatus[victim] && IsRealClient(victim))
    {
        ForcePlayerSuicide(victim);
        SDKUnhook(victim, SDKHook_WeaponSwitch, OnWeaponSwitch);
    }
}

public void OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    
    if(IsSurvivor(victim) && playerStatus[attacker])
    {
        // Survivor-SI can alse hit Survivor-Humans and may make Survivor-Humans to be staggered
        // So here to set Survivor-Humans god mode for compensation
        TrySetGodMode(victim);
    }

}


public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int userid = GetClientOfUserId(GetEventInt(event, "userid"));
    // int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    if(IsClientValid(userid) && playerStatus[userid])
    {
        switch(playerStatus[userid])
        {
            case PLAYABLE_SMOKER:
            {
                OnPlayerSmokerDeath(userid);
            }
            case PLAYABLE_BOOMER:
            {
                OnPlayerBoomerDeath(userid);
            }
            case PLAYABLE_HUNTER:
            {
                OnPlayerHunterDeath(userid);
            }
            case PLAYABLE_SPITTER:
            {
                
            }
            case PLAYABLE_JOCKEY:
            {
                OnPlayerJockeyDeath(userid);
            }
            case PLAYABLE_CHARGER:
            {
                OnPlayerChargerDeath(userid);
            }
            case PLAYABLE_TANK:
            {
                
            }
        }
        // Dead CallBack
        RequestFrame(RespawnPlayer, userid);
        playerStatus[userid] = 0;
        SDKUnhook(userid, SDKHook_WeaponSwitch, OnWeaponSwitch);  // Garantee to un hook
        TryEnableAfk(userid);
    }

}

// public void OnInfectedDeath(Event event, const char[] name, bool dontBroadcast)
// {
    // short	attacker	user ID who killed
    // short	infected_id	ID of the infected that died
    // short	gender	gender (type) of the infected
    // short	weapon_id	ID of the weapon used
    // bool	headshot	signals a headshot
    // bool	minigun	signals a minigun kill
    // bool	blast	signals a death from blast damage
    // bool	submerged	indicates the infected was submerged
    // int infectedId = GetEventInt(event, "infected_id");
    // RemoveInfectedFromVomit(infectedId);

// }

public void OnPlayerReplacedByBot(Event event, const char[] name, bool dontBroadcast)
{
    // short	player	user ID of the player
    // short	bot	user ID of the bot
    int player = GetClientOfUserId(GetEventInt(event, "player"));
    int bot = GetClientOfUserId(GetEventInt(event, "bot"));
    if(playerStatus[player])
    {
        SDKUnhook(player, SDKHook_WeaponSwitch, OnWeaponSwitch);
        ForcePlayerSuicide(bot);
        TryEnableAfk(player);
        RequestFrame(RespawnPlayer, player);

        switch(playerStatus[player])
        {
            case PLAYABLE_SMOKER:
            {
                OnPlayerSmokerDeath(player);
            }
            case PLAYABLE_BOOMER:
            {
                OnPlayerBoomerDeath(player);
            }
            case PLAYABLE_HUNTER:
            {
                OnPlayerHunterDeath(player);
            }
            case PLAYABLE_SPITTER:
            {
                
            }
            case PLAYABLE_JOCKEY:
            {
                OnPlayerJockeyDeath(player);
            }
            case PLAYABLE_CHARGER:
            {
                OnPlayerChargerDeath(player);
            }
            case PLAYABLE_TANK:
            {
                
            }
        }
        playerStatus[player] = 0;
    }
    
}

public void OnBotReplacedByPlayer(Event event, const char[] name, bool dontBroadcast)
{
    // short	bot	user ID of the bot
    // short	player	user ID of the player
    // int player = GetClientOfUserId(GetEventInt(event, "player"));
    // int bot = GetClientOfUserId(GetEventInt(event, "bot"));
    // playerStatus[player] = 0;
    // SDKUnhook(player, SDKHook_WeaponSwitch, OnWeaponSwitch);
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    for(int i = 1; i <= MAXPLAYERS; i++)
    {
        if(playerStatus[i])
        {
            SDKUnhook(i, SDKHook_WeaponSwitch, OnWeaponSwitch);
            ForcePlayerSuicide(i);
        }
        playerStatus[i] = 0;
    }
}

public void L4D_OnDoAnimationEvent_Post(int client, int event, int variant_param)
{
    // if(playerStatus[client] && playerStatus[client] != PLAYABLE_TANK && (event == PLAYERANIMEVENT_HAND_ATTACK || event == PLAYERANIMEVENT_HAND_LOW_ATTACK))
    if(playerStatus[client] && playerStatus[client] != PLAYABLE_TANK && (event == 33 || event == 34))
    {
        RequestFrame(DOClawDamage, client);
    }
}

void DOClawDamage(int client)
{
    float damage = -1.0;
    switch(playerStatus[client])
    {
        case PLAYABLE_SMOKER:
        {
            damage = GetConVarFloat(smokerClawDmg);
        }
        case PLAYABLE_BOOMER:
        {
            damage = GetConVarFloat(boomerClawDmg);
        }
        case PLAYABLE_HUNTER:
        {
            damage = GetConVarFloat(hunterClawDmg);
        }
        case PLAYABLE_SPITTER:
        {
            damage = GetConVarFloat(spitterClawDmg);
        }
        case PLAYABLE_JOCKEY:
        {
            damage = GetConVarFloat(jockeyClawDmg);
        }
        case PLAYABLE_CHARGER:
        {
            damage = GetConVarFloat(chargerClawDmg);
        }
    }

    if(damage <= 0.0)
        return;

    float center[3];
    GetAbsOrigin(client, center);
    float pos[3];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsInfected(i) || !IsPlayerAlive(i))
            continue;

        GetAbsOrigin(i, pos);
        if(GetVectorDistance(center, pos) <= 100.0)
        {
            SDKHooks_TakeDamage(i, client, client, damage, DMG_SLASH, -1, NULL_VECTOR, NULL_VECTOR, false);
        }
    }

    char classname[9];
    for(int i = MAXPLAYERS; i <= GetMaxEntities(); i++)
    {
        if(!IsValidEntity(i)) continue;

        GetEntityClassname(i, classname, 9);
        if(classname[0] != 'i' && classname[0] != 'w')
            continue;

        if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
        {
            GetAbsOrigin(i, pos);
            if(GetVectorDistance(center, pos) <= 100.0)
            {
                SDKHooks_TakeDamage(i, client, client, damage, DMG_SLASH, -1, NULL_VECTOR, NULL_VECTOR, false);
            }
        }
    }
}