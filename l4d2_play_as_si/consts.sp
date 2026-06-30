#if defined _pure_play_as_si_consts_included
 #endinput
#endif
#define _pure_play_as_si_consts_included

// Use it zombieClass
#define PLAYABLE_SMOKER 1
#define PLAYABLE_BOOMER 2
#define PLAYABLE_HUNTER 3
#define PLAYABLE_SPITTER 4
#define PLAYABLE_JOCKEY 5
#define PLAYABLE_CHARGER 6
#define PLAYABLE_WITCH 7 // Custom Define. Not m_zombieClass Number
#define PLAYABLE_TANK 8


#define TEAM_SPECTATOR 1
#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3

char infectedNameTable[][] =
{
    "InvalidInfectedName0",
    "Smoker",
    "Boomer",
    "Hunter",
    "Spitter",
    "Jockey",
    "Charger",
    "Witch",
    "Tank"
};

char infectedWeaponNameTable[][] =
{
    "InvalidInfectedWeapon0",
    "smoker_claw",
    "boomer_claw",
    "hunter_claw",
    "spitter_claw",
    "jockey_claw",
    "charger_claw",
    "InvalidInfectedWeapon7",
    "tank_claw"
};

char infectedAbilityTable[][] =
{
    "InvalidInfectedAbility0",
    "ability_tongue",
    "ability_vomit", // ability_selfdestruct
    "ability_lunge",
    "ability_spit",
    "ability_leap",
    "ability_charge",
    "InvalidInfectedAbility7",
    "ability_throw"
};

char infectedModelNameTable[][] =
{
    "InvalidInfectedModel0",
    "models/infected/smoker.mdl",
    "models/infected/boomer.mdl",
    "models/infected/hunter.mdl",
    "models/infected/spitter.mdl",
    "models/infected/jockey.mdl",
    "models/infected/charger.mdl",
    "models/infected/witch.mdl",
    "models/infected/hulk.mdl"
};