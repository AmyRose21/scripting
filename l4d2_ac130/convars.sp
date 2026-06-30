#if defined _pure_ac130_convars_included
 #endinput
#endif
#define _pure_ac130_convars_included


ConVar missileReloadDuration;
ConVar grenadeReloadDuration;
ConVar bulletReloadDuration;

ConVar missileShootInterval;
ConVar grenadeShootInterval;
ConVar bulletShootInterval;

ConVar missileAmmoMaxCnt;
ConVar grenadeAmmoMaxCnt;
ConVar bulletAmmoMaxCnt;


ConVar missileExplodeDamage;
ConVar missileExplodeTeamDamage;
ConVar missileExplodeRadius;
ConVar missileExplodeForce;
ConVar missileExplodeShakeAmplitude;
ConVar missileExplodeShakeDuration;


ConVar bulletHitDamage;


void InitConvars()
{
#if defined _pure_is_lazy_to_make_translation
    missileReloadDuration = CreateConVar("l4d2_ac130_missile_reload_time", "10.0", "Missile Reloading Time");
    grenadeReloadDuration = CreateConVar("l4d2_ac130_grenade_reload_time", "5.0", "Grenade Reloading Time");
    bulletReloadDuration = CreateConVar("l4d2_ac130_minigun_reload_time", "5.0", "Minigun Reloading Time");
    
    missileShootInterval = CreateConVar("l4d2_ac130_missile_shoot_interval", "10.0", "Shoot Interval of Missile");
    grenadeShootInterval = CreateConVar("l4d2_ac130_grenade_shoot_interval", "1.0", "Shoot Interval of Grenade");
    bulletShootInterval = CreateConVar("l4d2_ac130_minigun_shoot_interval", "0.05", "Shoot Interval of Minigun");
    
    missileAmmoMaxCnt = CreateConVar("l4d2_ac130_missile_max_ammo", "1", "Max Ammo of Missile");
    grenadeAmmoMaxCnt = CreateConVar("l4d2_ac130_grenade_max_ammo", "5", "Max Ammo of Grenade");
    bulletAmmoMaxCnt = CreateConVar("l4d2_ac130_minigun_max_ammo", "150", "Max Ammo of Minigun");
    
    
    missileExplodeDamage = CreateConVar("l4d2_ac130_missile_explode_dmg", "1000.0", "Explosion Damage of Missile to Infected");
    missileExplodeTeamDamage = CreateConVar("l4d2_ac130_missile_explode_dmg_team", "10.0", "Explosion Damage of Missile to Teammates");
    missileExplodeRadius = CreateConVar("l4d2_ac130_missile_explode_radius", "1000.0", "Explosion Radius of Missile");
    missileExplodeForce = CreateConVar("l4d2_ac130_missile_explode_force", "500.0", "Explosion Force of Missile");
    missileExplodeShakeAmplitude = CreateConVar("l4d2_ac130_missile_explode_shake_amplitude", "150.0", "Explosion Shake Amplitude of Missile");
    missileExplodeShakeDuration = CreateConVar("l4d2_ac130_missile_explode_shake_time", "5.0", "Explosion Shake Duration of Missile");
    
    bulletHitDamage = CreateConVar("l4d2_ac130_minigun_dmg", "20.0", "Minigun Damage");
#else
    missileReloadDuration = CreateConVar("l4d2_ac130_missile_reload_time", "10.0", "导弹装填时间");
    grenadeReloadDuration = CreateConVar("l4d2_ac130_grenade_reload_time", "5.0", "榴弹装填时间");
    bulletReloadDuration = CreateConVar("l4d2_ac130_minigun_reload_time", "5.0", "机枪装填时间");
    
    missileShootInterval = CreateConVar("l4d2_ac130_missile_shoot_interval", "10.0", "导弹发射间隔");
    grenadeShootInterval = CreateConVar("l4d2_ac130_grenade_shoot_interval", "1.0", "榴弹发射间隔");
    bulletShootInterval = CreateConVar("l4d2_ac130_minigun_shoot_interval", "0.05", "机枪开火间隔");
    
    missileAmmoMaxCnt = CreateConVar("l4d2_ac130_missile_max_ammo", "1", "导弹最大装填数量");
    grenadeAmmoMaxCnt = CreateConVar("l4d2_ac130_grenade_max_ammo", "5", "榴弹最大装填数量");
    bulletAmmoMaxCnt = CreateConVar("l4d2_ac130_minigun_max_ammo", "150", "机枪最大装填数量");
    
    
    missileExplodeDamage = CreateConVar("l4d2_ac130_missile_explode_dmg", "1000.0", "导弹爆炸对感染者的伤害");
    missileExplodeTeamDamage = CreateConVar("l4d2_ac130_missile_explode_dmg_team", "10.0", "导弹爆炸对队友的伤害");
    missileExplodeRadius = CreateConVar("l4d2_ac130_missile_explode_radius", "1000.0", "导弹爆炸半径");
    missileExplodeForce = CreateConVar("l4d2_ac130_missile_explode_force", "500.0", "导弹爆炸力");
    missileExplodeShakeAmplitude = CreateConVar("l4d2_ac130_missile_explode_shake_amplitude", "150.0", "导弹爆炸产生震动的幅度");
    missileExplodeShakeDuration = CreateConVar("l4d2_ac130_missile_explode_shake_time", "5.0", "导弹爆炸产生震动的持续时间");
    
    bulletHitDamage = CreateConVar("l4d2_ac130_minigun_dmg", "20.0", "机枪伤害");
#endif
    AutoExecConfig(true, "l4d2_ac130");
}