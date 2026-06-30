#if defined _pure_ac130_variables_included
 #endinput
#endif
#define _pure_ac130_variables_included

InfectedManager infectedMgr;

float shootInterval[3];
int ammoMaxCnt[3];
float reloadDuration[3];
float smoothTick;

bool allow[MAXPLAYERS + 1];
int planes[MAXPLAYERS + 1];
float planeSmoothParam[MAXPLAYERS + 1];
int weaponId[MAXPLAYERS + 1];
float lastReloadTipTimes[MAXPLAYERS + 1];
float lastFireEmptyTipTimes[MAXPLAYERS + 1];
float lastSwitchTimes[MAXPLAYERS + 1];
float lastFireTimes[MAXPLAYERS + 1][3];
int weaponAmmoCnt[MAXPLAYERS + 1][3];
Handle reloadTimers[MAXPLAYERS + 1][3];
bool isMinigunFiring[MAXPLAYERS + 1];
char tips[][] = 
{
#if defined _pure_is_lazy_to_make_translation
    "Missile",
    "Grenade",
    "Minigun"        
#else
    "导弹",
    "榴弹",
    "机枪"
#endif
    
};

void InitVariables()
{
    infectedMgr.Init();
    shootInterval[0] = GetConVarFloat(missileShootInterval);
    shootInterval[1] = GetConVarFloat(grenadeShootInterval);
    shootInterval[2] = GetConVarFloat(bulletShootInterval);
    ammoMaxCnt[0] = GetConVarInt(missileAmmoMaxCnt);
    ammoMaxCnt[1] = GetConVarInt(grenadeAmmoMaxCnt);
    ammoMaxCnt[2] = GetConVarInt(bulletAmmoMaxCnt);
    reloadDuration[0] = GetConVarFloat(missileReloadDuration);
    reloadDuration[1] = GetConVarFloat(grenadeReloadDuration);
    reloadDuration[2] = GetConVarFloat(bulletReloadDuration);
    smoothTick = 0.05;
}