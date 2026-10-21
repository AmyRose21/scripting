/*
 * ============================================================================
 *  amy_meteor_test.sp  —  Test Plugin: Meteor Storm
 * ============================================================================
 *  Plugin independiente para testear la habilidad de Meteor Storm de Amy.
 *  No depende de Amy.inc ni del plugin principal.
 *
 *  Habilidad:
 *    Amy ejecuta sm_meteor_test.
 *    Cae una tormenta de meteoros alrededor de su posición durante 5 segundos.
 *    Cada meteoro crea una explosión AoE que daña infectados.
 *    Total: 15 meteoros en 5 segundos (3 por segundo).
 *
 *  Comandos:
 *    sm_meteor_test   —  Ejecuta el Meteor Storm centrado en Amy
 *    sm_meteortest    —  Alias
 *
 *  ConVars:
 *    amy_ms_meteor_count      15      Número total de meteoros
 *    amy_ms_duration          5.0     Duración del meteor storm (segundos)
 *    amy_ms_radius            500.0   Radio de caída de meteoros alrededor de Amy
 *    amy_ms_meteor_damage     200.0   Daño por meteoro
 *    amy_ms_meteor_radius     200.0   Radio de AoE de cada meteoro
 *    amy_ms_cooldown          30.0    Cooldown entre usos
 *
 *  Nota: Plugin de prueba. No se integra con Amy.inc todavía.
 * ============================================================================
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION  "1.0-test"
#define PLUGIN_PREFIX   "\x04[MeteorStorm]\x01"

#define TEAM_SURVIVOR   2
#define TEAM_INFECTED   3

// Colores del meteoro (rosa chillón)
#define COLOR_PINK_R   255
#define COLOR_PINK_G   20
#define COLOR_PINK_B   147

ConVar g_cvMeteorCount;
ConVar g_cvDuration;
ConVar g_cvRadius;
ConVar g_cvMeteorDamage;
ConVar g_cvMeteorRadius;
ConVar g_cvCooldown;

int g_iBeamSprite = -1;
int g_iHaloSprite = -1;
int g_iGlowSprite = -1;

// Trackeo de meteor storms activos
bool g_bStormActive[MAXPLAYERS + 1];
int g_iMeteorsRemaining[MAXPLAYERS + 1];
int g_iTotalMeteors[MAXPLAYERS + 1];
Handle g_hMeteorTimer[MAXPLAYERS + 1];
float g_fLastUse[MAXPLAYERS + 1];

public Plugin myinfo = {
    name        = "Amy Meteor Storm Test",
    author      = "Test",
    description = "Test plugin for Meteor Storm ability",
    version     = PLUGIN_VERSION,
    url         = ""
};

public void OnPluginStart() {
    g_cvMeteorCount   = CreateConVar("amy_ms_meteor_count", "15", "Numero total de meteoros", _, true, 1.0, true, 100.0);
    g_cvDuration      = CreateConVar("amy_ms_duration", "5.0", "Duracion del meteor storm (s)", _, true, 1.0, true, 30.0);
    g_cvRadius        = CreateConVar("amy_ms_radius", "500.0", "Radio de caida alrededor de Amy", _, true, 50.0, true, 2000.0);
    g_cvMeteorDamage  = CreateConVar("amy_ms_meteor_damage", "200.0", "Dano por meteoro", _, true, 10.0, true, 5000.0);
    g_cvMeteorRadius  = CreateConVar("amy_ms_meteor_radius", "200.0", "Radio AoE de cada meteoro", _, true, 50.0, true, 1000.0);
    g_cvCooldown      = CreateConVar("amy_ms_cooldown", "30.0", "Cooldown entre usos", _, true, 0.0, true, 300.0);

    AutoExecConfig(true, "amy_meteor_test");

    RegConsoleCmd("sm_meteor_test", Cmd_MeteorStorm, "Test: Meteor Storm ability");
    RegConsoleCmd("sm_meteortest", Cmd_MeteorStorm, "Test: Meteor Storm ability (alias)");
}

public void OnMapStart() {
    g_iBeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
    g_iHaloSprite = PrecacheModel("sprites/halo01.vmt", true);
    g_iGlowSprite = PrecacheModel("sprites/glow01.spr", true);

    PrecacheSound("ambient/explosions/explode_1.wav", true);
    PrecacheSound("ambient/explosions/explode_3.wav", true);
    PrecacheSound("player/tank/hit/pound_victim_2.wav", true);
    PrecacheSound("ambient/energy/force_field_loop1.wav", true);
}

public void OnClientDisconnect(int client) {
    StopMeteorStorm(client);
}

public void OnPluginEnd() {
    for (int i = 1; i <= MaxClients; i++) {
        StopMeteorStorm(i);
    }
}

// ============================================================================
//  COMANDO PRINCIPAL
// ============================================================================

Action Cmd_MeteorStorm(int client, int args) {
    if (!IsValidClient(client) || IsFakeClient(client)) {
        ReplyToCommand(client, "Solo jugadores reales pueden usar este comando.");
        return Plugin_Handled;
    }

    if (GetClientTeam(client) != TEAM_SURVIVOR) {
        ReplyToCommand(client, "Solo supervivientes pueden usar Meteor Storm.");
        return Plugin_Handled;
    }

    if (!IsPlayerAlive(client)) {
        ReplyToCommand(client, "Debes estar vivo para usar Meteor Storm.");
        return Plugin_Handled;
    }

    // Cooldown
    float now = GetEngineTime();
    float cd = g_cvCooldown.FloatValue;
    if (now - g_fLastUse[client] < cd) {
        float remaining = cd - (now - g_fLastUse[client]);
        PrintToChat(client, "%s Espera \x04%.1fs\x01 para usar Meteor Storm de nuevo.", PLUGIN_PREFIX, remaining);
        return Plugin_Handled;
    }

    if (g_bStormActive[client]) {
        PrintToChat(client, "%s Ya tienes un Meteor Storm activo.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }

    g_fLastUse[client] = now;

    // Iniciar Meteor Storm
    StartMeteorStorm(client);

    return Plugin_Handled;
}

// ============================================================================
//  LÓGICA DEL METEOR STORM
// ============================================================================

void StartMeteorStorm(int client) {
    int meteorCount = g_cvMeteorCount.IntValue;
    float duration = g_cvDuration.FloatValue;

    g_bStormActive[client] = true;
    g_iMeteorsRemaining[client] = meteorCount;
    g_iTotalMeteors[client] = meteorCount;

    // Intervalo entre meteoros
    float interval = duration / float(meteorCount);

    // Feedback inicial
    PrintHintText(client, "<font color='#FF1493' size='24'>>> METEOR STORM <<</font>\n<font color='#FF69B4'>Iniciando tormenta de %d meteoros...</font>", meteorCount);
    PrintToChat(client, "%s \x03Meteor Storm\x01 iniciado: \x04%d\x01 meteoros en \x04%.1fs\x01.", PLUGIN_PREFIX, meteorCount, duration);

    // Timer que spawnea meteoros cada `interval` segundos
    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteFloat(interval);

    g_hMeteorTimer[client] = CreateTimer(interval, Timer_SpawnMeteor, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_SpawnMeteor(Handle timer, DataPack pack) {
    pack.Reset();
    int userId = pack.ReadCell();
    float interval = pack.ReadFloat();

    int client = GetClientOfUserId(userId);

    // Verificar validez
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) {
        StopMeteorStorm(client);
        return Plugin_Stop;
    }

    // Verificar si ya no hay meteoros restantes
    if (g_iMeteorsRemaining[client] <= 0) {
        StopMeteorStorm(client);
        return Plugin_Stop;
    }

    // Spawnear un meteoro en posición aleatoria alrededor de Amy
    SpawnMeteor(client);

    g_iMeteorsRemaining[client]--;

    // Reset del pack para el siguiente tick
    pack.Reset();
    pack.WriteCell(userId);
    pack.WriteFloat(interval);

    return Plugin_Continue;
}

void StopMeteorStorm(int client) {
    if (client <= 0 || client > MaxClients) return;

    g_bStormActive[client] = false;
    g_iMeteorsRemaining[client] = 0;

    if (g_hMeteorTimer[client] != null) {
        KillTimer(g_hMeteorTimer[client]);
        g_hMeteorTimer[client] = null;
    }
}

// ============================================================================
//  SPAWN DE METEORO INDIVIDUAL
// ============================================================================

void SpawnMeteor(int caster) {
    if (!IsValidClient(caster) || !IsPlayerAlive(caster)) return;

    float casterPos[3];
    GetClientAbsOrigin(caster, casterPos);

    // Posición aleatoria dentro del radio
    float radius = g_cvRadius.FloatValue;
    float angle = GetRandomFloat(0.0, 2.0 * 3.14159);
    float dist = GetRandomFloat(50.0, radius);

    float meteorPos[3];
    meteorPos[0] = casterPos[0] + (Cosine(angle) * dist);
    meteorPos[1] = casterPos[1] + (Sine(angle) * dist);
    meteorPos[2] = casterPos[2];  // a la altura de Amy

    // Encontrar suelo (trace hacia abajo)
    float skyPos[3];
    skyPos = meteorPos;
    skyPos[2] += 1000.0;

    Handle trace = TR_TraceRayFilterEx(skyPos, meteorPos, MASK_SOLID, RayType_EndPoint, TraceFilter_NoPlayers, caster);
    if (trace != null && TR_DidHit(trace)) {
        TR_GetEndPosition(meteorPos, trace);
    }
    delete trace;

    meteorPos[2] += 20.0;  // un poco encima del suelo

    // Sky position (de dónde cae el meteoro)
    float fallFromPos[3];
    fallFromPos = meteorPos;
    fallFromPos[2] += 800.0;

    // 1. Beam de caída (rosa chillón)
    int color[4] = {COLOR_PINK_R, COLOR_PINK_G, COLOR_PINK_B, 255};
    TE_SetupBeamPoints(fallFromPos, meteorPos, g_iBeamSprite, 0, 0, 0, 0.5, 8.0, 8.0, 5, 0.0, color, 0);
    TE_SendToAll();

    // 2. Glow en la posición de impacto
    TE_SetupGlowSprite(meteorPos, g_iGlowSprite, 1.0, 3.0, 200);
    TE_SendToAll();

    // 3. Ring expansivo rosa
    TE_SetupBeamRingPoint(meteorPos, 10.0, g_cvMeteorRadius.FloatValue, g_iBeamSprite, g_iHaloSprite, 0, 15, 0.6, 8.0, 0.0, color, 0, 0);
    TE_SendToAll();

    // 4. Sonido de explosión
    EmitSoundToAll("ambient/explosions/explode_1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, meteorPos);

    // 5. Daño AoE a infectados
    ApplyMeteorDamage(caster, meteorPos, g_cvMeteorDamage.FloatValue, g_cvMeteorRadius.FloatValue);

    // 6. Screen shake local
    CreateScreenShake(meteorPos, 6.0, 300.0, 0.4);

    // 7. Partícula de explosión (nativa de L4D2)
    CreateParticle(meteorPos, "weapon_pipebomb_explosion", 1.5);
}

// Aplica daño AoE a todos los infectados en el radio
void ApplyMeteorDamage(int attacker, float center[3], float damage, float radius) {
    float radiusSq = radius * radius;

    // Dañar infectados especiales (players)
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float pos[3];
        GetClientAbsOrigin(i, pos);
        pos[2] += 40.0;

        if (GetVectorDistance(center, pos, true) <= radiusSq) {
            SDKHooks_TakeDamage(i, attacker, attacker, damage, DMG_BLAST);
        }
    }

    // Dañar commons
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1) {
        if (!IsValidEntity(entity)) continue;

        float pos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
        pos[2] += 40.0;

        if (GetVectorDistance(center, pos, true) <= radiusSq) {
            SDKHooks_TakeDamage(entity, attacker, attacker, damage, DMG_BLAST);
        }
    }

    // Dañar witches
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1) {
        if (!IsValidEntity(entity)) continue;

        float pos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
        pos[2] += 40.0;

        if (GetVectorDistance(center, pos, true) <= radiusSq) {
            SDKHooks_TakeDamage(entity, attacker, attacker, damage, DMG_BLAST);
        }
    }
}

// ============================================================================
//  EFECTOS VISUALES Y SONIDO
// ============================================================================

void CreateScreenShake(float pos[3], float amplitude, float radius, float duration) {
    int shake = CreateEntityByName("env_shake");
    if (!IsValidEntity(shake)) return;

    DispatchKeyValueFloat(shake, "amplitude", amplitude);
    DispatchKeyValueFloat(shake, "radius", radius);
    DispatchKeyValueFloat(shake, "duration", duration);
    DispatchKeyValueFloat(shake, "frequency", 255.0);
    DispatchKeyValue(shake, "spawnflags", "1");
    DispatchKeyValueVector(shake, "origin", pos);
    DispatchSpawn(shake);
    AcceptEntityInput(shake, "StartShake");

    char killOutput[64];
    Format(killOutput, sizeof(killOutput), "OnUser1 !self:Kill::%f:-1", duration + 0.5);
    SetVariantString(killOutput);
    AcceptEntityInput(shake, "AddOutput");
    AcceptEntityInput(shake, "FireUser1");
}

void CreateParticle(float pos[3], const char[] particleName, float life) {
    int particle = CreateEntityByName("info_particle_system");
    if (!IsValidEntity(particle)) return;

    DispatchKeyValue(particle, "effect_name", particleName);
    DispatchSpawn(particle);
    ActivateEntity(particle);
    TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(particle, "Start");

    char killOutput[64];
    Format(killOutput, sizeof(killOutput), "OnUser1 !self:Kill::%f:-1", life);
    SetVariantString(killOutput);
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");
}

// ============================================================================
//  HELPERS
// ============================================================================

public bool TraceFilter_NoPlayers(int entity, int contentsMask, int self) {
    if (entity == self) return false;
    if (1 <= entity && entity <= MaxClients) return false;
    return true;
}

bool IsValidClient(int client) {
    return 1 <= client && client <= MaxClients && IsClientInGame(client);
}
