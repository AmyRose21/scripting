#if defined _pure_ac130_test_included
 #endinput
#endif
#define _pure_ac130_test_included


void RegisterTestCommand()
{
    RegConsoleCmd("sm_bh", TestCommand_CreateHelicopterAndBoard);
    RegConsoleCmd("sm_ubh", TestCommand_UnboardHelicopter);
}

// !rcon sm plugins reload l4d2_ac130_remastered


Action TestCommand_CreateHelicopterAndBoard(int client, int args)
{
    int plane = CreateHelicopter(client);
    if(plane <= 0)
    {
        PrintToChat(client, "[ERROR] AC130创建失败");
        return Plugin_Stop;
    }
    SetEntProp(plane, Prop_Send, "m_nSequence", 3);
    SetEntPropFloat(plane, Prop_Send, "m_flCycle", 0.0);
    SetEntPropFloat(plane, Prop_Send, "m_flPlaybackRate", 1.0);
    weaponAmmoCnt[client][0] = ammoMaxCnt[0];
    weaponAmmoCnt[client][1] = ammoMaxCnt[1];
    weaponAmmoCnt[client][2] = ammoMaxCnt[2];
    float pos[3]; GetClientAbsOrigin(client, pos);
    float eyePos[3]; GetClientEyePosition(client, eyePos);
    float offset[3]; SubtractVectors(pos, eyePos, offset);
    float planePos[3]; AddVectors(pos, view_as<float>({0.0, 0.0, 700.0}), planePos);
    TeleportEntity(plane, planePos);

    allow[client] = true;
    SDKHook(client, SDKHook_OnTakeDamage, OnGodMode);
    SDKHook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);

    SetEntityMoveType(client, MOVETYPE_NOCLIP);

    for(int i = 0; i < 5; i++)
    {
        int weapon = GetPlayerWeaponSlot(client, i);
        if(weapon != -1)
        {
            SDKHooks_DropWeapon(client, weapon);
        }
    }

    SetClientTransparent(client);
    
    AddVectors(planePos, offset, planePos);

    int train = CreateTrackTrain(client, pos, planePos, OnPlayerAboard);

    SetVariantString("!activator");
    AcceptEntityInput(client, "SetParent", train, train);

    AcceptEntityInput(train, "StartForward");

    planes[client] = plane;
    return Plugin_Continue;
}

void OnPlayerAboard(const char[] output, int caller, int activator, float delay)
{
    int client = GetEntPropEnt(activator, Prop_Send, "m_hOwnerEntity");

    AcceptEntityInput(client, "ClearParent");
    SetVariantString("!activator");
    AcceptEntityInput(client, "SetParent", planes[client], planes[client]);

    DeleteTrackTrain(activator);
}



Action TestCommand_UnboardHelicopter(int client, int args)
{
    if(planes[client] <= 0)
    {
        PrintToChat(client, "[ERROR] AC130还未创建");
        return Plugin_Stop;
    }
    allow[client] = false;
    SDKUnhook(client, SDKHook_OnTakeDamage, OnGodMode);
    SDKUnhook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
    AcceptEntityInput(client, "ClearParent");

    DeleteEntity(planes[client]);
    planes[client] = 0;

    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && GetEntityMoveType(i) == MOVETYPE_WALK)
        {
            float pos[3]; GetClientAbsOrigin(i, pos);
            TeleportEntity(client, pos);
            break;
        }
    }
    SetEntityMoveType(client, MOVETYPE_WALK);
    SetClientRenderNormal(client);
    return Plugin_Continue;
}

// !rcon sm plugins reload l4d2_ac130_remastered
