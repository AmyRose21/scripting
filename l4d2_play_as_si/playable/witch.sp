#if defined _pure_play_as_si_witch_included
 #endinput
#endif
#define _pure_play_as_si_witch_included
#include <LMCCore>
#include <LMCL4D2SetTransmit>
#include <LMCL4D2CDeathHandler>

int witchAnimationDucking = 4;
int witchAnimationDuckingAngry = 27;
int witchAnimationCrawl = 38;
int witchAnimationStandingAngry = 2;
int witchAnimationRun = 8; //8
int witchAnimationRunCrazy = 6;// 6,7
int witchAnimationWalk = 10; //10 ,11
int witchAnimationIdle = 10;
int witchAnimationJump = 58;
int witchAnimationFall = 54;
int witchAnimationThreaten = 31; // 31, 28, 29, 40, 7
int witchAnimationAttack1[2] = {17, 19}; //16 18  boold 17, 19 
int witchAnimationAttack2 = 32;
int witchAnimationLadderUp = 70;
int witchAnimationLadderDown = 70;
int witchAnimationLookAround = 5;

void PlayAnimation(int client, int sequence)
{
    // SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 1);
    SetEntProp(client, Prop_Send, "m_nSequence" ,sequence);
    SetEntPropFloat(client, Prop_Send, "m_flCycle", 0.0);
    SetEntPropFloat(client, Prop_Send, "m_flPlaybackRate", 1.0);
}

void OnWitchSuccess(int client)
{
    for(int i = 0; i < 5; i++)
    {
        int weapon = GetPlayerWeaponSlot(client, i);
        if(IsValidEntity(weapon))
        {
            RemoveEntity(weapon);
        }
    }
    // LMC_SetClientOverlayModel(client, "models/infected/witch.mdl");
    SetEntityModel(client, infectedModelNameTable[7]);
    // SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 1);
    // SetEntityMoveType(client, MOVETYPE_NONE);
}

void AddWitchConVars()
{
    PrecacheModel("models/infected/witch.mdl");
    // char desc[128];
    // Format(desc, 128, "%t", "ConVar Witch HP");
    // witchHp = CreateConVar("l4d2_play_as_si_witch_hp", "400", desc, 0, true, 100.0);
    // Format(desc, 128, "%t", "ConVar Witch Claw Damage");
    // witchClawDmg = CreateConVar("l4d2_play_as_si_witch_claw_dmg", "100.0", desc, 0, true, 10.0);
    // Format(desc, 128, "%t", "ConVar Witch Heal");
    // witchHealPoint = CreateConVar("l4d2_play_as_si_witch_heal_point", "400.0", desc, 0, true, 100.0);
}

public Action L4D_OnDoAnimationEvent(int client, int &event, int &variant_param)
{
    PrintToChatAll("L4D_OnDoAnimationEvent %N %d", client, event);
    if(playerStatus[client] == PLAYABLE_WITCH && event == PLAYERANIMEVENT_ATTACK_PRIMARY)
    {
        RequestFrame(WitchAttack, client);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

void WitchAttack(int client)
{
    PrintToChatAll("WitchAttack %N", client);
    PlayAnimation(client, witchAnimationAttack1[GetRandomInt(0, 1)]);
}
bool reset;
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if(buttons & IN_RELOAD)
    {
        reset = false;
    }
    if(playerStatus[client] == PLAYABLE_WITCH && (buttons & IN_ATTACK) && !reset)
    {
        // for(int i = 0; i < 5; i++)
        // {
        //     int weapon = GetPlayerWeaponSlot(client, i);
        //     if(IsValidEntity(weapon))
        //     {
        //         RemoveEntity(weapon);
        //     }
        // }
        reset = true;
        RequestFrame(WitchAttack, client);
        // int model = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
        // PrintToChatAll("witchAnimationAttack2");
        // PlayAnimation(client, witchAnimationAttack1[GetRandomInt(0, 1)]);
    }
    return Plugin_Continue;
}