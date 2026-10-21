/*
 * ============================================================================
 *  amy_thunderzap_test.sp  —  Test Plugin: Thunder Zap Chain
 * ============================================================================
 *  Plugin independiente para testear la habilidad de Thunder Zap de Amy.
 *  No depende de Amy.inc ni del plugin principal.
 *
 *  Habilidad:
 *    Amy mira a un infectado y ejecuta sm_thunderzap_test.
 *    Un rayo cae sobre el objetivo, dañándolo.
 *    El daño salta a hasta 3 infectados cercanos (chain lightning).
 *
 *  Comandos:
 *    sm_thunderzap_test   —  Ejecuta el Thunder Zap en el infectado apuntado
 *    sm_tztest            —  Alias
 *
 *  ConVars:
 *    amy_tz_damage        150.0   Daño base del rayo inicial
 *    amy_tz_chain_count   3       Máximo de objetivos encadenados
 *    amy_tz_chain_range   400.0   Rango máximo entre objetivos del chain
 *    amy_tz_chain_falloff 0.6     Daño de cada salto = anterior × falloff
 *    amy_tz_cooldown      3.0     Cooldown entre usos
 *    amy_tz_range         1500.0  Rango máximo para el primer objetivo
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
#define PLUGIN_PREFIX   "\x04[ThunderZap]\x01"

#define TEAM_SURVIVOR   2
#define TEAM_INFECTED   3

#define MAX_CHAIN_TARGETS  10

// Colores del rayo (rosa chillón para Amy)
#define COLOR_PINK_R   255
#define COLOR_PINK_G   20
#define COLOR_PINK_B   147

ConVar g_cvDamage;
ConVar g_cvChainCount;
ConVar g_cvChainRange;
ConVar g_cvChainFalloff;
ConVar g_cvCooldown;
ConVar g_cvRange;

int g_iBeamSprite = -1;
int g_iHaloSprite = -1;
int g_iGlowSprite = -1;

float g_fLastUse[MAXPLAYERS + 1];

public Plugin myinfo = {
    name        = "Amy Thunder Zap Test",
    author      = "Test",
    description = "Test plugin for Thunder Zap chain ability",
    version     = PLUGIN_VERSION,
    url         = ""
};

public void OnPluginStart() {
    g_cvDamage      = CreateConVar("amy_tz_damage", "150.0", "Daño base del rayo inicial", _, true, 1.0, true, 5000.0);
    g_cvChainCount  = CreateConVar("amy_tz_chain_count", "3", "Max objetivos encadenados", _, true, 0.0, true, 10.0);
    g_cvChainRange  = CreateConVar("amy_tz_chain_range", "400.0", "Rango max entre chain targets", _, true, 50.0, true, 2000.0);
    g_cvChainFalloff = CreateConVar("amy_tz_chain_falloff", "0.6", "Falloff de dano por salto (0.6 = 60%)", _, true, 0.1, true, 1.0);
    g_cvCooldown    = CreateConVar("amy_tz_cooldown", "3.0", "Cooldown en segundos", _, true, 0.0, true, 60.0);
    g_cvRange       = CreateConVar("amy_tz_range", "1500.0", "Rango max para objetivo inicial", _, true, 100.0, true, 5000.0);

    AutoExecConfig(true, "amy_thunderzap_test");

    RegConsoleCmd("sm_thunderzap_test", Cmd_ThunderZap, "Test: Thunder Zap chain ability");
    RegConsoleCmd("sm_tztest", Cmd_ThunderZap, "Test: Thunder Zap chain ability (alias)");
}

public void OnMapStart() {
    g_iBeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
    g_iHaloSprite = PrecacheModel("sprites/halo01.vmt", true);
    g_iGlowSprite = PrecacheModel("sprites/glow01.spr", true);

    PrecacheSound("ambient/energy/force_field_loop1.wav", true);
    PrecacheSound("ambient/explosions/explode_1.wav", true);
    PrecacheSound("player/tank/hit/pound_victim_2.wav", true);
}

// ============================================================================
//  COMANDO PRINCIPAL
// ============================================================================

Action Cmd_ThunderZap(int client, int args) {
    if (!IsValidClient(client) || IsFakeClient(client)) {
        ReplyToCommand(client, "Solo jugadores reales pueden usar este comando.");
        return Plugin_Handled;
    }

    if (GetClientTeam(client) != TEAM_SURVIVOR) {
        ReplyToCommand(client, "Solo supervivientes pueden usar Thunder Zap.");
        return Plugin_Handled;
    }

    if (!IsPlayerAlive(client)) {
        ReplyToCommand(client, "Debes estar vivo para usar Thunder Zap.");
        return Plugin_Handled;
    }

    // Cooldown
    float now = GetEngineTime();
    float cd = g_cvCooldown.FloatValue;
    if (now - g_fLastUse[client] < cd) {
        float remaining = cd - (now - g_fLastUse[client]);
        PrintToChat(client, "%s Espera \x04%.1fs\x01 para usar Thunder Zap de nuevo.", PLUGIN_PREFIX, remaining);
        return Plugin_Handled;
    }
    g_fLastUse[client] = now;

    // Trace para encontrar el objetivo apuntado
    float eyePos[3], eyeAng[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);

    Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, TraceFilter_ThunderZap, client);
    if (trace == null) {
        PrintToChat(client, "%s Error al trazar rayo.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }

    if (!TR_DidHit(trace)) {
        PrintToChat(client, "%s No estas apuntando a ningun objetivo.", PLUGIN_PREFIX);
        delete trace;
        return Plugin_Handled;
    }

    int target = TR_GetEntityIndex(trace);
    float hitPos[3];
    TR_GetEndPosition(hitPos, trace);
    delete trace;

    // Verificar que sea un infectado valido
    if (target <= 0 || !IsValidInfected(target)) {
        PrintToChat(client, "%s No apuntas a un infectado valido.", PLUGIN_PREFIX);
        return Plugin_Handled;
    }

    // Verificar rango
    float targetPos[3];
    GetEntityAbsOrigin(target, targetPos);
    float dist = GetVectorDistance(eyePos, targetPos);
    if (dist > g_cvRange.FloatValue) {
        PrintToChat(client, "%s Objetivo demasiado lejos (%.0f / %.0f).", PLUGIN_PREFIX, dist, g_cvRange.FloatValue);
        return Plugin_Handled;
    }

    // Ejecutar Thunder Zap
    ExecuteThunderZap(client, target);

    return Plugin_Handled;
}

// ============================================================================
//  LÓGICA DEL THUNDER ZAP CON CHAIN
// ============================================================================

void ExecuteThunderZap(int attacker, int initialTarget) {
    if (!IsValidInfected(initialTarget)) return;

    float dmg = g_cvDamage.FloatValue;
    int maxChain = g_cvChainCount.IntValue;
    float chainRange = g_cvChainRange.FloatValue;
    float falloff = g_cvChainFalloff.FloatValue;

    // Arrays para trackear el chain
    ArrayList hitList = new ArrayList();
    hitList.Push(initialTarget);

    // Posición inicial del rayo (desde el cielo hacia el objetivo)
    float targetPos[3];
    GetEntityAbsOrigin(initialTarget, targetPos);
    targetPos[2] += 40.0;

    // 1. Rayo inicial desde el cielo
    float skyPos[3];
    skyPos = targetPos;
    skyPos[2] += 800.0;

    DrawBeam(skyPos, targetPos, 4.0, 0.3);

    // Glow en el objetivo inicial
    DrawGlow(targetPos, 0.5);

    // Daño al objetivo inicial
    ApplyZapDamage(initialTarget, attacker, dmg);

    // Sonido
    EmitSoundToAll("ambient/energy/force_field_loop1.wav", initialTarget, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    EmitSoundToAll("player/tank/hit/pound_victim_2.wav", initialTarget, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // 2. Chain lightning
    int currentTarget = initialTarget;
    float currentPos[3];
    currentPos = targetPos;

    for (int i = 0; i < maxChain; i++) {
        // Buscar siguiente objetivo cercano
        int nextTarget = FindNextChainTarget(currentTarget, currentPos, hitList, chainRange);
        if (nextTarget <= 0) break;

        // Posición del siguiente objetivo
        float nextPos[3];
        GetEntityAbsOrigin(nextTarget, nextPos);
        nextPos[2] += 40.0;

        // Beam del currentTarget al nextTarget
        DrawBeam(currentPos, nextPos, 3.0, 0.25);

        // Glow en el siguiente
        DrawGlow(nextPos, 0.4);

        // Daño con falloff
        dmg *= falloff;
        ApplyZapDamage(nextTarget, attacker, dmg);

        // Avanzar el chain
        currentTarget = nextTarget;
        currentPos = nextPos;
        hitList.Push(nextTarget);

        // Pequeño delay visual entre saltos (sonido)
        EmitSoundToAll("ambient/energy/force_field_loop1.wav", nextTarget, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    }

    // Feedback al atacante
    int totalTargets = hitList.Length;
    delete hitList;

    PrintToChat(attacker, "%s \x03Thunder Zap\x01 golpeo a \x04%d\x01 objetivo(s).", PLUGIN_PREFIX, totalTargets);
    PrintHintText(attacker, "<font color='#FF1493' size='20'>>> THUNDER ZAP <<</font>\n<font color='#FF69B4'>%d objetivo(s) impactados</font>", totalTargets);
}

// Busca el siguiente objetivo para el chain (infectado cercano no ya golpeado)
int FindNextChainTarget(int currentTarget, float currentPos[3], ArrayList hitList, float maxRange) {
    int bestTarget = -1;
    float bestDist = maxRange * maxRange;  // distancia al cuadrado

    // Buscar en infectados especiales (players)
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;
        if (i == currentTarget) continue;
        if (hitList.FindValue(i) != -1) continue;

        float pos[3];
        GetClientAbsOrigin(i, pos);
        pos[2] += 40.0;

        float distSq = GetVectorDistance(currentPos, pos, true);
        if (distSq < bestDist) {
            bestDist = distSq;
            bestTarget = i;
        }
    }

    // Buscar en commons
    if (bestTarget == -1) {
        int entity = -1;
        while ((entity = FindEntityByClassname(entity, "infected")) != -1) {
            if (!IsValidEntity(entity)) continue;
            if (entity == currentTarget) continue;
            if (hitList.FindValue(entity) != -1) continue;

            float pos[3];
            GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
            pos[2] += 40.0;

            float distSq = GetVectorDistance(currentPos, pos, true);
            if (distSq < bestDist) {
                bestDist = distSq;
                bestTarget = entity;
            }
        }
    }

    // Buscar en witches
    if (bestTarget == -1) {
        int entity = -1;
        while ((entity = FindEntityByClassname(entity, "witch")) != -1) {
            if (!IsValidEntity(entity)) continue;
            if (entity == currentTarget) continue;
            if (hitList.FindValue(entity) != -1) continue;

            float pos[3];
            GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
            pos[2] += 40.0;

            float distSq = GetVectorDistance(currentPos, pos, true);
            if (distSq < bestDist) {
                bestDist = distSq;
                bestTarget = entity;
            }
        }
    }

    return bestTarget;
}

// Aplica daño de zap (respeta team)
void ApplyZapDamage(int victim, int attacker, float damage) {
    if (!IsValidEntity(victim)) return;

    if (victim <= MaxClients) {
        if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return;
        SDKHooks_TakeDamage(victim, attacker, attacker, damage, DMG_SHOCK);
    } else {
        SDKHooks_TakeDamage(victim, attacker, attacker, damage, DMG_SHOCK);
    }
}

// ============================================================================
//  EFECTOS VISUALES
// ============================================================================

void DrawBeam(float start[3], float end[3], float width, float life) {
    if (g_iBeamSprite < 0) return;
    int color[4] = {COLOR_PINK_R, COLOR_PINK_G, COLOR_PINK_B, 255};
    TE_SetupBeamPoints(start, end, g_iBeamSprite, 0, 0, 0, life, width, width, 5, 0.0, color, 0);
    TE_SendToAll();
}

void DrawGlow(float pos[3], float life) {
    if (g_iGlowSprite < 0) return;
    TE_SetupGlowSprite(pos, g_iGlowSprite, life, 2.0, 150);
    TE_SendToAll();
}

// ============================================================================
//  HELPERS
// ============================================================================

public bool TraceFilter_ThunderZap(int entity, int contentsMask, int self) {
    if (entity == self) return false;
    if (1 <= entity && entity <= MaxClients) {
        if (!IsClientInGame(entity)) return false;
        if (GetClientTeam(entity) == TEAM_SURVIVOR) return false;  // ignorar survivors
    }
    return true;
}

bool IsValidClient(int client) {
    return 1 <= client && client <= MaxClients && IsClientInGame(client);
}

bool IsValidInfected(int entity) {
    if (entity <= 0 || !IsValidEntity(entity)) return false;

    if (entity <= MaxClients) {
        return IsClientInGame(entity) && IsPlayerAlive(entity) && GetClientTeam(entity) == TEAM_INFECTED;
    }

    char cls[32];
    GetEntityClassname(entity, cls, sizeof(cls));
    return StrEqual(cls, "infected", false) || StrEqual(cls, "witch", false);
}

void GetEntityAbsOrigin(int entity, float pos[3]) {
    if (entity <= MaxClients) {
        GetClientAbsOrigin(entity, pos);
    } else {
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
    }
}
