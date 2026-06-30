#if defined _pure_ac130_consts_included
 #endinput
#endif
#define _pure_ac130_consts_included
#define _pure_is_lazy_to_make_translation  // Comment this to print Chinese

#define ZERO_VECTOR view_as<float>({0.0, 0.0, 0.0})

#define MIN_OFFSET_HEIGHT 400.0
#define MAX_OFFSET_HEIGHT 1000.0

#define TEAM_SPECTATOR 1
#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3
#define ID_SMOKER 1
#define ID_BOOMER 2
#define ID_HUNTER 3
#define ID_SPITTER 4
#define ID_JOCKEY 5
#define ID_CHARGER 6
#define ID_WITCH 7
#define ID_TANK 8
#define ID_Common 9

#define SOUND_MISSILE_FLY "animation/jets/jet_by_01_mono.wav"
#define SOUND_MISSILE_EXPLODE "ambient/explosions/explode_1.wav"
#define SOUND_MINIGUN_FIRE "weapons/minigun/gunfire/minigun_fire.wav"
#define SOUND_GRENADE_LAUNCHER_FIRE "weapons/grenade_launcher/grenadefire/grenade_launcher_fire_1.wav"
#define SOUND_MINIGUN_HIT_ENEMY "physics/flesh/flesh_impact_bullet1.wav"  
#define SOUND_MINIGUN_HIT_FLOOR "physics/concrete/concrete_impact_bullet1.wav"  

#define PARTICLE_GENERIC_MILITARY "particles/military_artillery_impacts.pcf"
#define PARTICLE_GENERIC_WEAPON "particles/weapon_fx.pcf"
#define PARTICLE_GENERIC_BLOOD "particles/blood_fx.pcf"
#define PARTICLE_MISSILE_TRAIL "missile_smoke_trail"
#define PARTICLE_MISSILE_EXPLODE "explosion_huge"
#define PARTICLE_MISSILE_FIRE "weapon_explosion_grenade"
#define PARTICLE_GRENADE_PROJECTILE_TRAIL "weapon_grenadelauncher_trail"
#define PARTICLE_MUZZLE_FLASH "weapon_muzzle_flash_autoshotgun"  
#define PARTICLE_WEAPON_TRACER "weapon_tracers" 
#define PARTICLE_WEAPON_TRACER2	"weapon_tracers_50cal"
#define PARTICLE_BLOOD "blood_impact_red_01"
#define PARTICLE_BLOOD_HEADSHOT "blood_impact_headshot_01"

#define MODEL_AC130 "models/props_vehicles/helicopter_rescue.mdl"
#define MODEL_MISSILE "models/missiles/f18_agm65maverick.mdl"
#define MODEL_GRENADE_PROJECTILE "models/w_models/weapons/w_he_grenade.mdl"