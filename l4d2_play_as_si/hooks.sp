#if defined _pure_play_as_si_hooks_included
 #endinput
#endif
#define _pure_play_as_si_hooks_included

// Forbid player to switch weapon
// Issue: Infinite pistol spawn (May this logic is not perfect)
Action OnWeaponSwitch(int client, int weapon)
{
    CreateTimer(0.1, TimerOnSwitchPostCheck, client);
    return Plugin_Handled;
}

Action TimerOnSwitchPostCheck(Handle timer, int client)
{
    if(!IsClientInGame(client) || !IsPlayerAlive(client))
    {
        return Plugin_Stop;
    }

    int curWeapon = L4D_GetPlayerCurrentWeapon(client);
    if(curWeapon != -1)
    {
        char targetWeapon[32];
        Format(targetWeapon, 32, "weapon_%s", infectedWeaponNameTable[playerStatus[client]]);
        char classname[32];
        GetEntityClassname(curWeapon, classname, 32);
        if(!StrEqual(classname, targetWeapon, false))
        {
            ForcePlayerSuicide(client);
        }
    }
    return Plugin_Continue;
}