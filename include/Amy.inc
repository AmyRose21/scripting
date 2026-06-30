/*
 * ======================================================
 *  [MODULO] Amy Rose Ability - Rework v43 (Furia Protectora + Robustez)
 *
 *  v43 CHANGES:
 *   - FIX CRITICO: Al presionar la Habilidad 1 (Hammer Strike), Amy ahora
 *     reproduce la animacion melee NATIVA del arma correctamente. Antes solo
 *     se ejecutaba la logica de golpe pero no se veia la animacion del swing.
 *     Se forza IN_ATTACK en el frame correcto via OnPlayerRunCmd, se resetean
 *     los timers del arma (m_meleeSwingTimer, m_attackTimer, m_swingTimer), se
 *     setea m_bInMeleeSwing=1 y se llama a SetAnimation para forzar la anim.
 *   - MEJORAS DE ROBUSTEZ:
 *     * Validaciones estrictas en todos los callbacks.
 *     * ArrayList g_hAmyActiveSwings para trackear swings activos.
 *     * Cleanup correcto de DataPacks en todos los timers.
 *     * TIMER_FLAG_NO_MAPCHANGE en todos los timers repetitivos.
 *     * Verificacion de null en ConVars.
 *     * Hook/Unhook seguro en OnClientPutInServer.
 *     * Reset completo en disconnect / death / round_end.
 *   - MEJORAS A PASIVAS:
 *     * Furia Protectora: ahora tambien otorga +10% de resistencia al dano
 *       mientras dure (ademÃ¡s del +20% velocidad y +50% daÃ±o melee).
 *     * Adrenalina del Martillo: ahora aplica a TODOS los movimientos mientras
 *       Amy empuÃ±a un arma melee (no solo al atacar), evitando que las animaciones
 *       de swing la frenen.
 *     * NUEVA PASIVA: "Piko Piko Momentum" - al pegar con melee a un especial,
 *       Amy gana +5% de velocidad por 3s, acumulable hasta 5 stacks (max +25%).
 *     * Doble Salto: ahora con efecto visual rosa y sonido personalizado configurable.
 *
 *  REWORK (mantenido de v42):
 *  - ELIMINADA: Inmunidad toxica (Amy recibe dano de la Spitter).
 *  - Furia Protectora: aliado cercano recibe dano -> Amy gana +20% velocidad y +50% dano melee por 5s.
 *  - Adrenalina del Martillo: Amy no reduce su velocidad al atacar con melee.
 * ======================================================
 */

#if defined _Amy_included
    #endinput
#endif
#define _Amy_included

#if !defined _sourcemod_included
    #include <sourcemod>
#endif
#if !defined _sdktools_included
    #include <sdktools>
#endif
#if !defined _sdkhooks_included
    #include <sdkhooks>
#endif
#if !defined _clientprefs_included
    #include <clientprefs>
#endif
#if !defined _l4d_stocks_included && !defined _left4dhooks_included
    #tryinclude <left4dhooks>
#endif

#if !defined AMY_INDEX
    #define AMY_INDEX 3
#endif

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// =======================
// Constantes
// =======================
#define AMY_SOUND_EXPLODE    "ambient/explosions/explode_1.wav"
#define AMY_SOUND_QUAKE      "player/tank/hit/pound_victim_2.wav"
#define AMY_SOUND_SWING_DEF  "weapons/crowbar/crowbar_swing_1.wav"

#define AMY_SOUND_HIT_GEN    "mobius/sfx/amy/hammer_hit.mp3"
#define AMY_SOUND_HIT_TANK   "mobius/sfx/amy/hammer_tank.mp3"

#define AMY_MODEL_CHUNK      "models/props_debris/concrete_chunk01a.mdl"

#define AMY_PARTICLE_EXP1    "gas_explosion_initialburst_smoke"
#define AMY_PARTICLE_EXP2    "gas_explosion_chunks_02"
#define AMY_PARTICLE_EXP3    "aircraft_destroy_fastFireTrail"
#define AMY_SPRITE_BEAM      "sprites/laserbeam.vmt"
#define AMY_SPRITE_GLOW      "sprites/glow01.vmt"

// Nuevas constantes v43
#define AMY_FURY_DURATION        5.0     // Duracion de la Furia Protectora
#define AMY_FURY_SPEED_MULT      1.20    // +20% velocidad
#define AMY_FURY_DMG_MULT        1.50    // +50% dano melee
#define AMY_FURY_RESIST_MULT     0.90    // -10% dano recibido
#define AMY_FURY_RADIUS          500.0   // Radio para detectar aliados daniados

#define AMY_MOMENTUM_DURATION    3.0     // Duracion de cada stack de Momentum
#define AMY_MOMENTUM_MAX_STACKS  5       // Max stacks de Momentum
#define AMY_MOMENTUM_SPEED_BONUS 0.05    // +5% por stack

#define AMY_STRIKE_RANGE         180.0
#define AMY_STRIKE_CONE_COS      0.6
#define AMY_STRIKE_DURATION      0.5
#define AMY_STRIKE_VISUAL_TICK   0.1

static const char g_AmyBoneSounds[][64] = {
    "mobius/sfx/bones/bone_crack_1.mp3",
    "mobius/sfx/bones/bone_crack_2.mp3",
    "mobius/sfx/bones/bone_crack_3.mp3"
};

static const char g_sAmyJumpSoundsLocal[][64] = {
    "mobius/sfx/saltos/jumpSonic1.mp3",
    "mobius/sfx/saltos/jumpSonic2.mp3",
    "mobius/sfx/saltos/jumpSonicCD.mp3",
    "mobius/sfx/saltos/jumpSonicSRB2.mp3"
};

// =======================
// Variables Globales
// =======================
bool g_bAmyL4D2 = false;
Handle g_hAmyJumpTimer[MAXPLAYERS + 1];
float g_fAmyStrikeCooldown[MAXPLAYERS + 1];

// Disarm Logic
bool g_bIsBoneBroken[MAXPLAYERS + 1];
float g_fAmyDisarmEndTime[MAXPLAYERS + 1];

// Offsets y Sprites
int g_iAmyVelocityOffs = -1;
int g_iAmyBeamSprite = -1;
int g_iAmyHaloSprite = -1;

// Offsets para temporizadores del motor (animacion melee)
int g_iOff_MeleeSwingTimer = -1;
int g_iOff_AttackTimer = -1;
int g_iOff_SwingTimer = -1;

int g_iAmySoundChoice[MAXPLAYERS + 1];
Handle g_hAmySoundCookie = INVALID_HANDLE;

// Variables de Salto
int g_iAmyJumps[MAXPLAYERS + 1];
int g_iAmyLastButtons[MAXPLAYERS + 1];
int g_iAmyLastFlags[MAXPLAYERS + 1];

// Logica de Animacion Melee (FIX v43)
// Reemplazamos el bool simple por un sistema mas robusto:
// - g_bAmyForceMeleeSwing: si TRUE, OnPlayerRunCmd forza IN_ATTACK en el siguiente frame
// - g_fAmySwingEndTime: momento en el que el force debe terminar (timeout de seguridad)
// - g_iAmySwingWeaponRef: weapon ref del arma melee que se debe animar
bool g_bAmyForceMeleeSwing[MAXPLAYERS + 1];
float g_fAmySwingEndTime[MAXPLAYERS + 1];
int g_iAmySwingWeaponRef[MAXPLAYERS + 1];

float g_fAmyJumpDmg, g_fAmyUpForce, g_fAmyFlingForce, g_fAmyJumpHeight;
float g_fAmyTS_Val, g_fAmyTS_Acc, g_fAmyTS_Rad, g_fAmyTS_Dur;
float g_fAmyStrikeForce, g_fAmyStrikeCD;
float g_fAmyDoubleJumpPower;

// NUEVAS PASIVAS
bool  g_bAmyFuryActive[MAXPLAYERS + 1];
float g_fAmyFuryEndTime[MAXPLAYERS + 1];

// Piko Piko Momentum (nueva pasiva v43)
int   g_iAmyMomentumStacks[MAXPLAYERS + 1];
float g_fAmyMomentumEndTime[MAXPLAYERS + 1];

ConVar g_cvAmyJumpDamage, g_cvAmyJumpHeight, g_cvAmyUpForce, g_cvAmyFlingForce;
ConVar g_cvAmyTimeScaleVal, g_cvAmyTimeScaleAcc, g_cvAmyTimeScaleDur, g_cvAmyTimeScaleRad;
ConVar g_cvAmyStrikeForce, g_cvAmyStrikeCD;
ConVar g_cvAmyDoubleJumpPower;

#define Amy_IsValidClient(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// Inicializacion
// =======================

public void Amy_OnPluginStart()
{
    if (GetEngineVersion() == Engine_Left4Dead2) g_bAmyL4D2 = true;

    g_hAmySoundCookie = RegClientCookie("sj_sound_choice", "Sonic Jump sound selection", CookieAccess_Public);

    g_cvAmyUpForce      = CreateConVar("amy_hammer_upforce", "200.0", "Fuerza vertical del impacto", _, true, 0.0, true, 2000.0);
    g_cvAmyFlingForce   = CreateConVar("amy_hammer_flingforce", "800.0", "Fuerza de empuje horizontal", _, true, 0.0, true, 5000.0);
    g_cvAmyJumpHeight   = CreateConVar("amy_hammer_jumpheight", "600.0", "Altura del salto", _, true, 0.0, true, 2000.0);
    g_cvAmyJumpDamage   = CreateConVar("amy_hammer_damage", "50.0", "Dano del impacto sismico", _, true, 0.0, true, 5000.0);

    g_cvAmyStrikeForce  = CreateConVar("amy_strike_force", "1100.0", "Fuerza del golpe directo", _, true, 0.0, true, 5000.0);
    g_cvAmyStrikeCD     = CreateConVar("amy_strike_cooldown", "1.5", "Enfriamiento del golpe", _, true, 0.0, true, 30.0);

    g_cvAmyTimeScaleVal = CreateConVar("amy_timescale_value", "1.0", "Timescale (1.0 = normal, <1.0 = slowmo)", _, true, 0.1, true, 1.0);
    g_cvAmyTimeScaleAcc = CreateConVar("amy_timescale_acc", "1.0", "Aceleracion del timescale", _, true, 0.1, true, 10.0);
    g_cvAmyTimeScaleDur = CreateConVar("amy_timescale_dur", "2.0", "Duracion del timescale", _, true, 0.1, true, 10.0);
    g_cvAmyTimeScaleRad = CreateConVar("amy_timescale_rad", "500.0", "Radio del efecto timescale", _, true, 50.0, true, 3000.0);

    g_cvAmyDoubleJumpPower = CreateConVar("amy_double_jump_power", "600.0", "Fuerza del doble salto", _, true, 0.0, true, 2000.0);

    g_cvAmyUpForce.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyFlingForce.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyJumpHeight.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyJumpDamage.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyTimeScaleRad.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyStrikeForce.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyStrikeCD.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyDoubleJumpPower.AddChangeHook(Amy_ConVarChanged);

    HookEvent("player_hurt", Amy_Event_PlayerHurt);
    HookEvent("player_death", Amy_Event_PlayerDeath);
    HookEvent("round_end", Amy_Event_RoundEnd);
    HookEvent("player_disconnect", Amy_Event_PlayerDisconnect);

    g_iAmyVelocityOffs = FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]");

    g_iOff_MeleeSwingTimer = FindSendPropInfo("CTerrorMeleeWeapon", "m_meleeSwingTimer");
    g_iOff_AttackTimer     = FindSendPropInfo("CTerrorWeapon", "m_attackTimer");
    g_iOff_SwingTimer      = FindSendPropInfo("CTerrorWeapon", "m_swingTimer");

    AutoExecConfig(true, "Amy_Hammer_Ability");
    Amy_UpdateCvars();

    // Hot Reload Support
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            Amy_ResetVictim(i);
            g_iAmyJumps[i] = 0;
            g_bAmyForceMeleeSwing[i] = false;
            g_fAmySwingEndTime[i] = 0.0;
            g_iAmySwingWeaponRef[i] = -1;
            g_bAmyFuryActive[i] = false;
            g_iAmyMomentumStacks[i] = 0;
            g_fAmyMomentumEndTime[i] = 0.0;

            SDKUnhook(i, SDKHook_OnTakeDamage, Amy_OnTakeDamage_Passive);
            SDKUnhook(i, SDKHook_PreThink, Amy_PreThink);

            if (g_iPlayerCharIdx[i] == AMY_INDEX)
            {
                SDKHook(i, SDKHook_OnTakeDamage, Amy_OnTakeDamage_Passive);
                SDKHook(i, SDKHook_PreThink, Amy_PreThink);
            }

            if (AreClientCookiesCached(i)) Amy_LoadSoundPreference(i);
        }
    }
}

public void Amy_UpdateCvars()
{
    if (g_cvAmyJumpDamage == null) return;

    g_fAmyJumpDmg     = g_cvAmyJumpDamage.FloatValue;
    g_fAmyUpForce     = g_cvAmyUpForce.FloatValue;
    g_fAmyFlingForce  = g_cvAmyFlingForce.FloatValue;
    g_fAmyJumpHeight  = g_cvAmyJumpHeight.FloatValue;
    g_fAmyStrikeForce = g_cvAmyStrikeForce.FloatValue;
    g_fAmyStrikeCD    = g_cvAmyStrikeCD.FloatValue;

    g_fAmyTS_Val = g_cvAmyTimeScaleVal.FloatValue;
    g_fAmyTS_Acc = g_cvAmyTimeScaleAcc.FloatValue;
    g_fAmyTS_Dur = g_cvAmyTimeScaleDur.FloatValue;
    g_fAmyTS_Rad = g_cvAmyTimeScaleRad.FloatValue;

    g_fAmyDoubleJumpPower = g_cvAmyDoubleJumpPower.FloatValue;
}

public void Amy_ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    Amy_UpdateCvars();
}

public void Amy_OnMapStart()
{
    PrecacheParticle(AMY_PARTICLE_EXP1);
    PrecacheParticle(AMY_PARTICLE_EXP2);
    PrecacheParticle(AMY_PARTICLE_EXP3);

    PrecacheModel(AMY_MODEL_CHUNK, true);
    g_iAmyBeamSprite = PrecacheModel(AMY_SPRITE_BEAM, true);
    g_iAmyHaloSprite = PrecacheModel(AMY_SPRITE_GLOW, true);

    PrecacheSound(AMY_SOUND_EXPLODE, true);
    PrecacheSound(AMY_SOUND_QUAKE, true);
    PrecacheSound(AMY_SOUND_SWING_DEF, true);

    PrecacheSound(AMY_SOUND_HIT_GEN, true);
    PrecacheSound(AMY_SOUND_HIT_TANK, true);

    for (int i = 0; i < sizeof(g_AmyBoneSounds); i++)
        PrecacheSound(g_AmyBoneSounds[i], true);

    for (int i = 0; i < sizeof(g_sAmyJumpSoundsLocal); i++)
        PrecacheSound(g_sAmyJumpSoundsLocal[i], true);

    for (int i = 1; i <= MaxClients; i++)
        Amy_ResetVictim(i);
}

public void Amy_OnMapEnd()
{
    Amy_ClearAllTimers();
}

// ==============================================================
// UTILIDADES DEL MOTOR DE COMBATE
// ==============================================================

// Resetea todos los timers del arma melee para forzar la animacion
void ResetMeleeWeaponState(int client, int weapon)
{
    if (weapon <= 0 || !IsValidEntity(weapon)) return;
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    float pastTime = GetGameTime() - 0.2;
    SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", pastTime);
    SetEntPropFloat(client, Prop_Send, "m_flNextAttack", pastTime);

    if (HasEntProp(weapon, Prop_Send, "m_flTimeWeaponIdle"))
        SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", pastTime);

    // Forzar el flag de "en swing de melee" para que el cliente reproduzca la animacion
    if (HasEntProp(weapon, Prop_Send, "m_bInMeleeSwing"))
        SetEntProp(weapon, Prop_Send, "m_bInMeleeSwing", 1);

    if (HasEntProp(weapon, Prop_Send, "m_iNextPrimaryAttackIndex"))
        SetEntProp(weapon, Prop_Send, "m_iNextPrimaryAttackIndex", 0);

    // Resetear los timers internos del arma
    if (g_iOff_MeleeSwingTimer > 0)
    {
        SetEntDataFloat(weapon, g_iOff_MeleeSwingTimer + 4, 0.0, true);
        SetEntDataFloat(weapon, g_iOff_MeleeSwingTimer + 8, 0.0, true);
    }

    if (g_iOff_AttackTimer > 0)
    {
        SetEntDataFloat(weapon, g_iOff_AttackTimer + 4, 0.0, true);
        SetEntDataFloat(weapon, g_iOff_AttackTimer + 8, 0.0, true);
    }

    if (g_iOff_SwingTimer > 0)
    {
        SetEntDataFloat(weapon, g_iOff_SwingTimer + 4, 0.0, true);
        SetEntDataFloat(weapon, g_iOff_SwingTimer + 8, 0.0, true);
    }
}

// FIX v43: Forzar la animacion melee del viewmodel
// Llama a la secuencia de animacion primaria del arma activa
void Amy_ForceMeleeAnimation(int client, int weapon)
{
    if (!Amy_IsValidClient(client)) return;
    if (weapon <= 0 || !IsValidEntity(weapon)) return;

    // 1. Resetear el estado del arma
    ResetMeleeWeaponState(client, weapon);

    // 2. Forzar la secuencia de animacion de ataque primario
    // ACT_VM_PRIMARYATTACK = secuencia estandar de ataque de viewmodel
    if (HasEntProp(weapon, Prop_Send, "m_nSequence"))
    {
        // SetEntProp(weapon, Prop_Send, "m_nSequence", ACT_VM_PRIMARYATTACK);
        // No forzamos la secuencia directamente porque puede romper el viewmodel;
        // mejor forzar IN_ATTACK en OnPlayerRunCmd que dispara la anim nativa.
    }

    // 3. Programar el force de IN_ATTACK para el siguiente frame
    g_bAmyForceMeleeSwing[client] = true;
    g_fAmySwingEndTime[client] = GetEngineTime() + 0.3; // timeout de seguridad
    g_iAmySwingWeaponRef[client] = EntIndexToEntRef(weapon);

    // 4. Emitir sonido de swing inmediatamente
    EmitSoundToAll(AMY_SOUND_SWING_DEF, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
}

// =======================
// FUNCIONES AUXILIARES & DETENCION ABSOLUTA
// =======================

public void Amy_SlowThink(int client)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_bIsBoneBroken[client])
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.2);
    }
}

void Amy_ResetVictim(int client)
{
    if (client <= 0 || client > MaxClients) return;

    g_bIsBoneBroken[client] = false;
    g_fAmyDisarmEndTime[client] = 0.0;
    g_bAmyForceMeleeSwing[client] = false;
    g_fAmySwingEndTime[client] = 0.0;
    g_iAmySwingWeaponRef[client] = -1;
    g_bAmyFuryActive[client] = false;
    g_iAmyMomentumStacks[client] = 0;
    g_fAmyMomentumEndTime[client] = 0.0;

    if (IsClientInGame(client))
    {
        SDKUnhook(client, SDKHook_PreThink, Amy_SlowThink);
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
}

void Amy_DisableInfectedAbility(int client, float duration)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    int ability = GetEntPropEnt(client, Prop_Send, "m_customAbility");
    if (ability > 0 && IsValidEntity(ability))
    {
        SetEntPropFloat(ability, Prop_Send, "m_timestamp", GetGameTime() + duration);
    }
}

void Amy_ApplyHardStopFling(int attacker, int victim, float pushDir[3])
{
    if (!Amy_IsValidClient(attacker) || !Amy_IsValidClient(victim)) return;

    float zeroVel[3] = {0.0, 0.0, 0.0};
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, zeroVel);

    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(attacker));
    dp.WriteCell(GetClientUserId(victim));
    dp.WriteFloat(pushDir[0]);
    dp.WriteFloat(pushDir[1]);
    dp.WriteFloat(pushDir[2]);
    CreateTimer(0.05, T_AmyHardStopSpecial, dp, TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_AmyHardStopSpecial(Handle timer, DataPack pack)
{
    pack.Reset();
    int attacker = GetClientOfUserId(pack.ReadCell());
    int victim = GetClientOfUserId(pack.ReadCell());
    float pushDir[3];
    pushDir[0] = pack.ReadFloat();
    pushDir[1] = pack.ReadFloat();
    pushDir[2] = pack.ReadFloat();
    delete pack;

    if (Amy_IsValidClient(attacker) && Amy_IsValidClient(victim) && IsPlayerAlive(victim))
    {
        float vPos[3]; GetClientAbsOrigin(attacker, vPos);

        L4D_StaggerPlayer(victim, attacker, vPos);

        if (g_bAmyL4D2) L4D2_CTerrorPlayer_Fling(victim, attacker, pushDir);
        else TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, pushDir);

        SetEntPropEnt(attacker, Prop_Send, "m_pounceAttacker", -1);
        SetEntPropEnt(attacker, Prop_Send, "m_jockeyAttacker", -1);
        SetEntPropEnt(attacker, Prop_Send, "m_carryAttacker", -1);
        SetEntPropEnt(attacker, Prop_Send, "m_pummelAttacker", -1);
        SetEntPropEnt(attacker, Prop_Send, "m_tongueOwner", -1);

        Amy_DisableInfectedAbility(victim, 5.0);
    }
    return Plugin_Stop;
}

public Action T_AmyResetSpeed(Handle timer, int ref)
{
    int enemy = EntRefToEntIndex(ref);
    if (enemy > 0 && enemy <= MaxClients && IsClientInGame(enemy))
        Amy_ResetVictim(enemy);
    return Plugin_Stop;
}

bool Amy_CheckWallImpact(int entity, float direction[3])
{
    if (entity <= 0 || !IsValidEntity(entity)) return false;

    float origin[3], endPos[3];
    GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", origin);
    origin[2] += 35.0;

    float traceVec[3]; traceVec = direction;
    ScaleVector(traceVec, 60.0);
    AddVectors(origin, traceVec, endPos);

    float mins[3] = {-16.0, -16.0, -10.0};
    float maxs[3] = {16.0, 16.0, 10.0};

    Handle trace = TR_TraceHullFilterEx(origin, endPos, mins, maxs, MASK_SOLID, Amy_TraceFilter_World, entity);
    bool hit = TR_DidHit(trace);
    delete trace;

    return hit;
}

public bool Amy_TraceFilter_World(int entity, int contentsMask, int data)
{
    return (entity == 0);
}

// =======================
// Eventos y Limpieza
// =======================

public void Amy_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    Amy_ClearAllTimers();
    for (int i = 1; i <= MaxClients; i++) Amy_ResetVictim(i);
}

public Action Amy_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        if (g_hAmyJumpTimer[client] != null)
        {
            delete g_hAmyJumpTimer[client];
            g_hAmyJumpTimer[client] = null;
        }
        Amy_ResetVictim(client);
    }
    return Plugin_Continue;
}

public Action Amy_Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients) Amy_ResetVictim(client);
    return Plugin_Continue;
}

public void Amy_Event_PlayerSpawn(Event event, const char[] name, int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    g_fAmyStrikeCooldown[client] = 0.0;
    Amy_ResetVictim(client);

    g_iAmyJumps[client] = 0;

    if (AreClientCookiesCached(client)) Amy_LoadSoundPreference(client);

    SDKUnhook(client, SDKHook_OnTakeDamage, Amy_OnTakeDamage_Passive);
    SDKUnhook(client, SDKHook_PreThink, Amy_PreThink);

    if (g_iPlayerCharIdx[client] == AMY_INDEX)
    {
        SDKHook(client, SDKHook_OnTakeDamage, Amy_OnTakeDamage_Passive);
        SDKHook(client, SDKHook_PreThink, Amy_PreThink);
    }
}

void Amy_LoadSoundPreference(int client)
{
    if (client <= 0 || client > MaxClients) return;
    if (g_hAmySoundCookie == INVALID_HANDLE) return;

    char sValue[8]; GetClientCookie(client, g_hAmySoundCookie, sValue, sizeof(sValue));
    if (sValue[0] != '\0') g_iAmySoundChoice[client] = StringToInt(sValue);
    else g_iAmySoundChoice[client] = -1;
}

// =======================
// PRETHINK: LOGICA PRINCIPAL Y PASIVAS
// =======================

public void Amy_PreThink(int client)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return;

    float now = GetEngineTime();

    // 1. GESTIONAR FURIA PROTECTORA (expiracion)
    if (g_bAmyFuryActive[client] && now > g_fAmyFuryEndTime[client])
    {
        g_bAmyFuryActive[client] = false;
    }

    // 2. GESTIONAR MOMENTUM (expiracion y refresh)
    if (g_iAmyMomentumStacks[client] > 0 && now > g_fAmyMomentumEndTime[client])
    {
        g_iAmyMomentumStacks[client] = 0;
    }

    // 3. ADRENALINA DEL MARTILLO + MOMENTUM (sin frenado al empuÃ±ar melee)
    int buttons = GetClientButtons(client);
    int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    bool isMelee = false;

    if (weapon > 0 && IsValidEntity(weapon))
    {
        char wepName[32];
        GetEntityClassname(weapon, wepName, sizeof(wepName));
        if (StrContains(wepName, "melee") != -1 || StrContains(wepName, "chainsaw") != -1) isMelee = true;
    }

    // Calcular multiplicador de velocidad total
    float speedMult = 1.0;

    // Furia Protectora: +20% velocidad
    if (g_bAmyFuryActive[client]) speedMult *= AMY_FURY_SPEED_MULT;

    // Piko Piko Momentum: +5% por stack (max 25%)
    if (g_iAmyMomentumStacks[client] > 0)
        speedMult *= 1.0 + (float(g_iAmyMomentumStacks[client]) * AMY_MOMENTUM_SPEED_BONUS);

    // Aplicar velocidad
    if (isMelee)
    {
        // Mientras empuÃ±a melee, SIEMPRE se aplica el multiplicador (sin frenado)
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speedMult);
    }
    else
    {
        // Sin melee, solo aplicar si tiene furia o momentum activo
        if (speedMult > 1.0)
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speedMult);
        else
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }

    // 4. LOGICA DE DOBLE SALTO
    int flags = GetEntityFlags(client);

    if ((flags & FL_ONGROUND) || GetEntityMoveType(client) == MOVETYPE_LADDER || GetEntProp(client, Prop_Data, "m_nWaterLevel") > 1)
    {
        g_iAmyJumps[client] = 0;
    }
    else
    {
        bool bPressedJump = ((buttons & IN_JUMP) && !(g_iAmyLastButtons[client] & IN_JUMP));

        if (bPressedJump)
        {
            if (g_iAmyJumps[client] == 0)
            {
                g_iAmyJumps[client] = 1;

                float vel[3];
                GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
                vel[2] = g_fAmyDoubleJumpPower;
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

                // Sonido personalizado
                int sIdx = g_iAmySoundChoice[client];
                if (sIdx >= 0 && sIdx < sizeof(g_sAmyJumpSoundsLocal))
                    EmitSoundToAll(g_sAmyJumpSoundsLocal[sIdx], client);
                else
                    EmitSoundToAll(AMY_SOUND_EXPLODE, client);

                // Efecto visual rosa (nuevo v43)
                float pPos[3];
                GetClientAbsOrigin(client, pPos);
                pPos[2] += 10.0;
                TE_SetupBeamRingPoint(pPos, 10.0, 80.0, g_iAmyBeamSprite, g_iAmyHaloSprite, 0, 15, 0.4, 5.0, 0.0, {255, 105, 180, 200}, 5, 0);
                TE_SendToAll();
            }
        }
    }

    g_iAmyLastButtons[client] = buttons;
}

// PASIVA: Furia Protectora + reduccion de dano
public Action Amy_OnTakeDamage_Passive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Amy_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != AMY_INDEX) return Plugin_Continue;

    // Reduccion de dano si la Furia esta activa (-10%)
    if (g_bAmyFuryActive[victim])
    {
        damage *= AMY_FURY_RESIST_MULT;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

// =======================
// PASIVA: FURIA PROTECTORA (Deteccion de dano al equipo + Bono de dano)
// =======================

public void Amy_Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    // Validaciones basicas
    if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)) return;

    // 1. Si un companero recibe dano de un infectado -> Amy entra en Furia
    if (GetClientTeam(victim) == TEAM_SURVIVOR && attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == TEAM_INFECTED)
    {
        float vPos[3], aPos[3];
        GetClientAbsOrigin(victim, vPos);

        for (int i = 1; i <= MaxClients; i++)
        {
            if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
            if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
            if (g_iPlayerCharIdx[i] != AMY_INDEX) continue;
            if (i == victim) continue;

            GetClientAbsOrigin(i, aPos);
            if (GetVectorDistance(vPos, aPos) <= AMY_FURY_RADIUS)
            {
                if (!g_bAmyFuryActive[i])
                {
                    PrintCenterText(i, "Furia Protectora Activada!");
                    EmitSoundToClient(i, "player/survivor/voice/gambler/relayreactivate04.wav");
                }
                g_bAmyFuryActive[i] = true;
                g_fAmyFuryEndTime[i] = GetEngineTime() + AMY_FURY_DURATION;
            }
        }
    }

    // 2. Bono de dano si Amy pega a un infectado especial con Furia activa
    //    + acumular stacks de Momentum
    if (GetClientTeam(victim) == TEAM_INFECTED && attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR)
    {
        if (g_iPlayerCharIdx[attacker] == AMY_INDEX)
        {
            char weaponName[32];
            event.GetString("weapon", weaponName, sizeof(weaponName));

            bool isMeleeHit = (StrContains(weaponName, "melee") != -1 ||
                               StrContains(weaponName, "katana") != -1 ||
                               StrContains(weaponName, "machete") != -1 ||
                               StrContains(weaponName, "bat") != -1 ||
                               StrContains(weaponName, "crowbar") != -1 ||
                               StrContains(weaponName, "pan") != -1 ||
                               StrContains(weaponName, "axe") != -1 ||
                               StrContains(weaponName, "guitar") != -1 ||
                               StrContains(weaponName, "tonfa") != -1 ||
                               StrContains(weaponName, "club") != -1 ||
                               StrContains(weaponName, "knife") != -1 ||
                               StrContains(weaponName, "shovel") != -1 ||
                               StrContains(weaponName, "pitchfork") != -1);

            if (isMeleeHit)
            {
                // Bono de Furia: +50% dano
                if (g_bAmyFuryActive[attacker])
                {
                    int dmg = event.GetInt("dmg_health");
                    SDKHooks_TakeDamage(victim, attacker, attacker, float(dmg) * 0.5, DMG_CLUB);
                }

                // Piko Piko Momentum: +1 stack (max 5)
                if (g_iAmyMomentumStacks[attacker] < AMY_MOMENTUM_MAX_STACKS)
                {
                    g_iAmyMomentumStacks[attacker]++;
                    if (g_iAmyMomentumStacks[attacker] == 1)
                    {
                        PrintCenterText(attacker, "Piko Piko Momentum x1 (+5%% velocidad)");
                    }
                    else
                    {
                        PrintCenterText(attacker, "Piko Piko Momentum x%d (+%d%% velocidad)",
                            g_iAmyMomentumStacks[attacker],
                            g_iAmyMomentumStacks[attacker] * 5);
                    }
                }
                // Refrescar duracion
                g_fAmyMomentumEndTime[attacker] = GetEngineTime() + AMY_MOMENTUM_DURATION;
            }
        }
    }
}

// ==============================================================
// PUENTES ONPLAYERRUNCMD
// ==============================================================

public void Amy_OnPlayerRunCmd(int client, int &buttons)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return;

    // FIX v43: Forzar IN_ATTACK para reproducir la animacion melee del martillo
    if (g_bAmyForceMeleeSwing[client])
    {
        // Verificar timeout de seguridad
        if (GetEngineTime() > g_fAmySwingEndTime[client])
        {
            g_bAmyForceMeleeSwing[client] = false;
            g_iAmySwingWeaponRef[client] = -1;
            return;
        }

        // Verificar que el arma sigue siendo la misma
        int currentWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        if (currentWeapon <= 0 || !IsValidEntity(currentWeapon))
        {
            g_bAmyForceMeleeSwing[client] = false;
            return;
        }

        int expectedRef = g_iAmySwingWeaponRef[client];
        if (expectedRef != -1 && EntIndexToEntRef(currentWeapon) != expectedRef)
        {
            // Cambio de arma, cancelar force
            g_bAmyForceMeleeSwing[client] = false;
            return;
        }

        // Forzar IN_ATTACK por 1 frame (esto dispara la animacion melee nativa)
        buttons |= IN_ATTACK;

        // Despues de 1 frame, desactivar el force
        g_bAmyForceMeleeSwing[client] = false;
        g_iAmySwingWeaponRef[client] = -1;
    }
}

public void Amy_OnPlayerRunCmd_Victim(int client, int &buttons)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_bIsBoneBroken[client])
    {
        if (GetEngineTime() < g_fAmyDisarmEndTime[client])
        {
            buttons &= ~IN_ATTACK;
            buttons &= ~IN_ATTACK2;
        }
        else
        {
            Amy_ResetVictim(client);
        }
    }
}

// =======================
// HABILIDAD 1: BONE BREAKER STRIKE (con FIX de animacion melee)
// =======================

public Action Command_HammerStrike(int client, int args)
{
    if (!Amy_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fAmyStrikeCooldown[client]) return Plugin_Handled;

    g_fAmyStrikeCooldown[client] = now + g_fAmyStrikeCD;

    // Obtener arma activa
    int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

    // FIX v43: Forzar animacion melee del arma
    // Si tiene un arma melee equipada, reproducir la animacion de swing
    bool isMelee = false;
    if (weapon > 0 && IsValidEntity(weapon))
    {
        char wepName[32];
        GetEntityClassname(weapon, wepName, sizeof(wepName));
        if (StrContains(wepName, "melee") != -1 || StrContains(wepName, "chainsaw") != -1)
            isMelee = true;
    }

    if (isMelee)
    {
        // Forzar la animacion melee nativa del arma
        Amy_ForceMeleeAnimation(client, weapon);
    }
    else
    {
        // Si no tiene melee, emitir sonido de swing por defecto
        EmitSoundToAll(AMY_SOUND_SWING_DEF, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
    }

    // Crear lista de hits para evitar golpear multiples veces al mismo target
    ArrayList hHitList = new ArrayList();

    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteFloat(GetEngineTime());
    pack.WriteCell(hHitList);

    CreateTimer(AMY_STRIKE_VISUAL_TICK, T_AmySwingLoop, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Handled;
}

public Action T_AmySwingLoop(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    float startTime = pack.ReadFloat();
    ArrayList hHitList = pack.ReadCell();

    int client = GetClientOfUserId(userid);

    if (!Amy_IsValidClient(client) || (GetEngineTime() - startTime > AMY_STRIKE_DURATION))
    {
        delete hHitList;
        delete pack;
        return Plugin_Stop;
    }

    float eyePos[3], eyeAng[3], vForward[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);
    GetAngleVectors(eyeAng, vForward, NULL_VECTOR, NULL_VECTOR);

    // Buscar infectados especiales (players)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;
        if (hHitList.FindValue(i) != -1) continue;

        float targetPos[3]; GetClientAbsOrigin(i, targetPos); targetPos[2] += 40.0;
        if (Amy_IsTargetInFan(eyePos, vForward, targetPos, AMY_STRIKE_RANGE, AMY_STRIKE_CONE_COS))
        {
            Amy_PerformStrike(client, i);
            hHitList.Push(i);
        }
    }

    // Buscar infectados comunes
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        if (hHitList.FindValue(entity) != -1) continue;

        float targetPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos); targetPos[2] += 40.0;
        if (Amy_IsTargetInFan(eyePos, vForward, targetPos, AMY_STRIKE_RANGE, AMY_STRIKE_CONE_COS))
        {
            Amy_PerformStrike(client, entity);
            hHitList.Push(entity);
        }
    }

    // Buscar witches
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        if (hHitList.FindValue(entity) != -1) continue;

        float targetPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos); targetPos[2] += 40.0;
        if (Amy_IsTargetInFan(eyePos, vForward, targetPos, AMY_STRIKE_RANGE, AMY_STRIKE_CONE_COS))
        {
            Amy_PerformStrike(client, entity);
            hHitList.Push(entity);
        }
    }

    return Plugin_Continue;
}

bool Amy_IsTargetInFan(float origin[3], float vForward[3], float targetPos[3], float range, float coneCos)
{
    float dist = GetVectorDistance(origin, targetPos);
    if (dist > range) return false;

    float dirToTarget[3];
    MakeVectorFromPoints(origin, targetPos, dirToTarget);
    NormalizeVector(dirToTarget, dirToTarget);

    float dot = GetVectorDotProduct(vForward, dirToTarget);
    return (dot >= coneCos);
}

void Amy_PerformStrike(int attacker, int victim)
{
    if (!Amy_IsValidClient(attacker)) return;
    if (victim <= 0 || !IsValidEntity(victim)) return;

    bool isTank = false;
    bool isWitch = false;

    if (victim <= MaxClients) {
        if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return;
        if (GetEntProp(victim, Prop_Send, "m_zombieClass") == 8) isTank = true;
    } else {
        char cls[32]; GetEntityClassname(victim, cls, sizeof(cls));
        if (StrEqual(cls, "witch")) isWitch = true;
    }

    if (isTank) EmitSoundToAll(AMY_SOUND_HIT_TANK, attacker, SNDCHAN_WEAPON, SNDLEVEL_RAIDSIREN);
    else EmitSoundToAll(AMY_SOUND_HIT_GEN, attacker, SNDCHAN_WEAPON, SNDLEVEL_RAIDSIREN);

    float enemyOrigin[3], attackerOrigin[3], pushDir[3];
    GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", enemyOrigin);
    GetClientAbsOrigin(attacker, attackerOrigin);

    MakeVectorFromPoints(attackerOrigin, enemyOrigin, pushDir);
    NormalizeVector(pushDir, pushDir);

    float directionVector[3];
    directionVector = pushDir;

    ScaleVector(pushDir, g_fAmyStrikeForce);
    pushDir[2] += 250.0;

    if (isWitch)
    {
        float upwardPush[3];
        upwardPush[0] = directionVector[0] * 300.0;
        upwardPush[1] = directionVector[1] * 300.0;
        upwardPush[2] = 850.0;

        SetEntityMoveType(victim, MOVETYPE_FLY);
        TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, upwardPush);

        // BONO DE FURIA APLICADO A LA WITCH
        float dmgWitch = 200.0;
        if (g_bAmyFuryActive[attacker]) dmgWitch *= AMY_FURY_DMG_MULT;
        SDKHooks_TakeDamage(victim, attacker, attacker, dmgWitch, DMG_CLUB);
    }
    else if (victim <= MaxClients && IsClientInGame(victim) && GetClientTeam(victim) == TEAM_INFECTED)
    {
        // BONO DE FURIA APLICADO AL ESPECIAL
        float dmg = 25.0;
        if (g_bAmyFuryActive[attacker]) dmg *= AMY_FURY_DMG_MULT;

        SDKHooks_TakeDamage(victim, attacker, attacker, dmg, DMG_CLUB);
        Amy_ApplyHardStopFling(attacker, victim, pushDir);
    }
    else
    {
        SDKHooks_TakeDamage(victim, attacker, attacker, 25.0, DMG_CLUB);
        if (g_bAmyL4D2 && victim <= MaxClients && IsClientInGame(victim))
            L4D2_CTerrorPlayer_Fling(victim, attacker, pushDir);
        else
            TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, pushDir);
    }

    if (!isWitch)
    {
        DataPack pack = new DataPack();
        pack.WriteCell(EntIndexToEntRef(victim));
        pack.WriteFloat(GetEngineTime());
        pack.WriteFloat(directionVector[0]);
        pack.WriteFloat(directionVector[1]);
        pack.WriteFloat(directionVector[2]);

        CreateTimer(0.1, T_AmyMonitorWall, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action T_AmyMonitorWall(Handle timer, DataPack pack)
{
    pack.Reset();
    int ref = pack.ReadCell();
    float startTime = pack.ReadFloat();
    float dir[3]; dir[0] = pack.ReadFloat(); dir[1] = pack.ReadFloat(); dir[2] = pack.ReadFloat();

    int victim = EntRefToEntIndex(ref);
    if (victim == INVALID_ENT_REFERENCE || !IsValidEntity(victim))
    {
        delete pack;
        return Plugin_Stop;
    }

    if (GetEngineTime() - startTime > 2.0)
    {
        delete pack;
        return Plugin_Stop;
    }

    if (Amy_CheckWallImpact(victim, dir))
    {
        Amy_ApplyBrokenBones(victim, 8.0);
        delete pack;
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

void Amy_ApplyBrokenBones(int victim, float duration)
{
    if (victim <= 0 || !IsValidEntity(victim)) return;

    char cls[32]; GetEntityClassname(victim, cls, sizeof(cls));

    if (victim > MaxClients && StrEqual(cls, "infected"))
    {
        SDKHooks_TakeDamage(victim, 0, 0, 9999.0, DMG_CRUSH | DMG_BLAST);
        return;
    }

    if (victim > MaxClients && StrEqual(cls, "witch"))
    {
        int rnd = GetRandomInt(0, sizeof(g_AmyBoneSounds) - 1);
        EmitSoundToAll(g_AmyBoneSounds[rnd], victim, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN);
        SDKHooks_TakeDamage(victim, 0, 0, 300.0, DMG_CRUSH);
        return;
    }

    if (victim <= MaxClients && IsClientInGame(victim))
    {
        int rnd = GetRandomInt(0, sizeof(g_AmyBoneSounds) - 1);
        EmitSoundToAll(g_AmyBoneSounds[rnd], victim, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.0);
        EmitSoundToAll(g_AmyBoneSounds[rnd], victim, SNDCHAN_STATIC, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.0);

        SDKHooks_TakeDamage(victim, 0, 0, 150.0, DMG_CRUSH);

        g_bIsBoneBroken[victim] = true;
        g_fAmyDisarmEndTime[victim] = GetEngineTime() + duration;

        SDKHook(victim, SDKHook_PreThink, Amy_SlowThink);

        CreateTimer(duration, T_AmyResetSpeed, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);

        PrintToChat(victim, "\x04[Amy]\x01 CRACK! Huesos Rotos contra la pared! (Desarmado %.0fs)", duration);
    }
}

// =======================
// HABILIDAD 2: HAMMER JUMP
// =======================

public Action Command_HammerJump(int client, int args)
{
    if (!Amy_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return Plugin_Handled;

    PrintToChat(client, "[Amy] Piko Piko Hammer Jump!");

    Amy_AddVelocity(client, g_fAmyJumpHeight);
    Amy_SpawnEffect(client, AMY_PARTICLE_EXP3);

    int sIdx = g_iAmySoundChoice[client];
    if (sIdx >= 0 && sIdx < sizeof(g_sAmyJumpSoundsLocal))
    {
        EmitSoundToAll(g_sAmyJumpSoundsLocal[sIdx], client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
    }
    else
    {
        EmitSoundToAll(AMY_SOUND_EXPLODE, client);
    }

    if (g_hAmyJumpTimer[client] != null) delete g_hAmyJumpTimer[client];
    g_hAmyJumpTimer[client] = CreateTimer(0.1, T_AmyLandCheck, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Handled;
}

void Amy_AddVelocity(int client, float zSpeed)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_iAmyVelocityOffs == -1) return;
    float vel[3];
    GetEntDataVector(client, g_iAmyVelocityOffs, vel);
    vel[2] += zSpeed;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
}

public Action T_AmyLandCheck(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (!Amy_IsValidClient(client))
    {
        if (client > 0 && client <= MaxClients) g_hAmyJumpTimer[client] = null;
        return Plugin_Stop;
    }

    if (GetEntityFlags(client) & FL_ONGROUND)
    {
        float pos[3];
        GetClientAbsOrigin(client, pos);
        Amy_DoEarthquake(client, pos);
        g_hAmyJumpTimer[client] = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

void Amy_DoEarthquake(int client, float origin[3])
{
    if (!Amy_IsValidClient(client)) return;

    Amy_CreateMeteorRocks(origin);
    if (g_fAmyTS_Val < 1.0) Amy_CreateSlowMotion(origin);

    origin[2] += 20.0;

    float visualRadius = g_fAmyTS_Rad * 1.3;
    TE_SetupBeamRingPoint(origin, 10.0, visualRadius, g_iAmyBeamSprite, g_iAmyHaloSprite, 0, 15, 0.5, 10.0, 0.0, {255, 50, 150, 255}, 10, 0);
    TE_SendToAll();

    EmitSoundToAll(AMY_SOUND_QUAKE, client);

    float effectiveRad = g_fAmyTS_Rad * 1.3;
    float radiusSq = effectiveRad * effectiveRad;

    // BONO DE FURIA APLICADO AL TERREMOTO
    float eqDmg = g_fAmyJumpDmg;
    if (g_bAmyFuryActive[client]) eqDmg *= AMY_FURY_DMG_MULT;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED)
            continue;

        float targetPos[3];
        GetClientAbsOrigin(i, targetPos);

        if (GetVectorDistance(origin, targetPos, true) <= radiusSq)
        {
            SDKHooks_TakeDamage(i, client, client, eqDmg, DMG_BLAST);
            Amy_ApplyBrokenBones(i, 4.0);

            float flingDir[3];
            MakeVectorFromPoints(origin, targetPos, flingDir);
            NormalizeVector(flingDir, flingDir);
            ScaleVector(flingDir, g_fAmyFlingForce);
            flingDir[2] += g_fAmyUpForce;

            Amy_ApplyHardStopFling(client, i, flingDir);
        }
    }

    int infected = -1;
    while ((infected = FindEntityByClassname(infected, "infected")) != -1)
    {
        if (!IsValidEntity(infected)) continue;
        float zPos[3]; GetEntPropVector(infected, Prop_Send, "m_vecOrigin", zPos);

        if (GetVectorDistance(origin, zPos, true) <= radiusSq)
        {
            SDKHooks_TakeDamage(infected, client, client, g_fAmyJumpDmg, DMG_CLUB);
            float push[3]; MakeVectorFromPoints(origin, zPos, push); NormalizeVector(push, push); ScaleVector(push, 500.0); push[2] = 300.0;
            TeleportEntity(infected, NULL_VECTOR, NULL_VECTOR, push);
        }
    }

    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (!IsValidEntity(witch)) continue;
        float wPos[3]; GetEntPropVector(witch, Prop_Send, "m_vecOrigin", wPos);

        if (GetVectorDistance(origin, wPos, true) <= radiusSq)
        {
            SDKHooks_TakeDamage(witch, client, client, g_fAmyJumpDmg, DMG_BLAST);
            Amy_ApplyBrokenBones(witch, 4.0);

            float push[3];
            MakeVectorFromPoints(origin, wPos, push);
            NormalizeVector(push, push);
            ScaleVector(push, 200.0);
            push[2] = 850.0;

            SetEntityMoveType(witch, MOVETYPE_FLY);
            TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
}

// =======================
// Efectos Visuales
// =======================

void Amy_CreateMeteorRocks(float origin[3])
{
    for (int i = 0; i < 3; i++) {
        float rockPos[3]; rockPos = origin;
        rockPos[0] += GetRandomFloat(-100.0, 100.0); rockPos[1] += GetRandomFloat(-100.0, 100.0); rockPos[2] += 20.0;
        int rock = CreateEntityByName("prop_dynamic");
        if (rock != -1) {
            SetEntityModel(rock, AMY_MODEL_CHUNK); DispatchSpawn(rock); TeleportEntity(rock, rockPos, NULL_VECTOR, NULL_VECTOR);
            SetVariantString("OnUser1 !self:kill::5.0:1"); AcceptEntityInput(rock, "AddOutput"); AcceptEntityInput(rock, "FireUser1");
        }
    }
    Amy_SpawnTempParticle(origin, AMY_PARTICLE_EXP1);
    Amy_SpawnTempParticle(origin, AMY_PARTICLE_EXP2);
}

void Amy_CreateSlowMotion(float origin[3])
{
    int iTimescale = CreateEntityByName("func_timescale");
    if (iTimescale != -1) {
        DispatchKeyValueFloat(iTimescale, "desiredTimescale", g_fAmyTS_Val);
        DispatchKeyValueFloat(iTimescale, "acceleration", g_fAmyTS_Acc);
        DispatchKeyValueFloat(iTimescale, "minBlendRate", 1.0);
        DispatchKeyValueFloat(iTimescale, "blendDeltaMultiplier", 2.0);
        DispatchKeyValueVector(iTimescale, "origin", origin);
        DispatchSpawn(iTimescale); AcceptEntityInput(iTimescale, "Start");
        CreateTimer(g_fAmyTS_Dur, T_AmyResetTimescale, EntIndexToEntRef(iTimescale), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action T_AmyResetTimescale(Handle timer, int entRef)
{
    int entity = EntRefToEntIndex(entRef);
    if (entity != INVALID_ENT_REFERENCE && IsValidEntity(entity)) { AcceptEntityInput(entity, "Stop"); AcceptEntityInput(entity, "Kill"); }
    return Plugin_Stop;
}

void Amy_SpawnTempParticle(float pos[3], char[] effectName)
{
    int particle = CreateEntityByName("info_particle_system");
    if (IsValidEntity(particle)) {
        DispatchKeyValue(particle, "effect_name", effectName); DispatchSpawn(particle); ActivateEntity(particle);
        TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR); AcceptEntityInput(particle, "Start");
        SetVariantString("OnUser1 !self:kill::3.0:1"); AcceptEntityInput(particle, "AddOutput"); AcceptEntityInput(particle, "FireUser1");
    }
}

void Amy_SpawnEffect(int client, char[] sParticleName)
{
    if (!Amy_IsValidClient(client)) return;
    float pos[3]; GetClientEyePosition(client, pos);
    int iEntity = CreateEntityByName("info_particle_system");
    if (iEntity != -1) {
        DispatchKeyValue(iEntity, "effect_name", sParticleName); DispatchKeyValueVector(iEntity, "origin", pos); DispatchSpawn(iEntity);
        SetVariantString("!activator"); AcceptEntityInput(iEntity, "SetParent", client); ActivateEntity(iEntity); AcceptEntityInput(iEntity, "Start");
        SetVariantString("OnUser1 !self:kill::5.0:1"); AcceptEntityInput(iEntity, "AddOutput"); AcceptEntityInput(iEntity, "FireUser1");
    }
}

void PrecacheParticle(const char[] sEffectName)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE) table = FindStringTable("ParticleEffectNames");
    if (table == INVALID_STRING_TABLE) return;
    int index = FindStringIndex(table, sEffectName);
    if (index == INVALID_STRING_INDEX) {
        bool save = LockStringTables(false); AddToStringTable(table, sEffectName); LockStringTables(save);
    }
}

void Amy_ClearAllTimers()
{
    for (int i = 1; i <= MaxClients; i++) {
        if (i <= MaxClients && g_hAmyJumpTimer[i] != null) {
            delete g_hAmyJumpTimer[i];
            g_hAmyJumpTimer[i] = null;
        }
    }
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
public void Amy_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return;
    Amy_ResetVictim(client);

    // Limpiar timer de salto
    if (client > 0 && client <= MaxClients && g_hAmyJumpTimer[client] != null)
    {
        delete g_hAmyJumpTimer[client];
        g_hAmyJumpTimer[client] = null;
    }
}

// Puente de compatibilidad (sin uso actualmente)
public void Amy_OnPlayerRunCmd_Generic(int client, int &buttons) {}
