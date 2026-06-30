/*
 * ======================================================
 *  [MODULO] Shadow the Hedgehog - Ultimate Lifeform Rework v5.2 (Visuals Update)
 *  
 *  REWORK: Removido el modo pistola clunky por completo.
 *  FIX: Habilidad 1 (Z) ahora es Chaos Snap (Teleport) con mecánicas de "Chaos Control".
 *  FIX: Habilidad 2 (X) ahora es Chaos Blast (Explosión devastadora de 500 dmg con stagger y fuego).
 *  FIX: Pasiva "Hover Shoes" añade deslizamiento horizontal en gravedad cero con chispas de cohete.
 *  FIX: Pasiva "Inhibitor Rings" (Rage Mode) al bajar de 50 HP.
 *  NEW: Chaos Blast ahora DESINTEGRA a los infectados que mata.
 *  NEW: Efectos visuales mejorados (Luces dinámicas en Snap, anillos múltiples).
 * ======================================================
 */

#if defined _Shadow_included
    #endinput
#endif
#define _Shadow_included

#if !defined _sourcemod_included
    #include <sourcemod>
#endif
#if !defined _sdktools_included
    #include <sdktools>
#endif
#if !defined _sdkhooks_included
    #include <sdkhooks>
#endif
#if !defined _l4d_stocks_included && !defined _left4dhooks_included
    #tryinclude <left4dhooks>
#endif

// =======================
// Dependencias
// =======================
#if !defined SHADOW_INDEX
    #define SHADOW_INDEX 5
#endif

// =======================
// Constantes y Audio
// =======================
#define SHADOW_SOUND_DASH       "mobius/sfx/shadow/dash.mp3"
#define SHADOW_SOUND_SNAP       "mobius/sfx/shadow/chaos_snap.mp3"
#define SHADOW_SOUND_PARRY      "mobius/sfx/shadow/chaos_blast.mp3" 

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif

// =======================
// Variables Globales
// =======================
// --- Cooldowns ---
float g_fShadowSnapCD[MAXPLAYERS + 1];
float g_fShadowBlastCD[MAXPLAYERS + 1];
float g_fInhibitorReady[MAXPLAYERS + 1];
float g_fInhibitorEndTime[MAXPLAYERS + 1];
float g_fLastDamageTime[MAXPLAYERS + 1];

// --- Estados de Rage ---
bool  g_bInhibitorActive[MAXPLAYERS + 1];

#define Shadow_IsValidClient(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// Inicializacion
// =======================

public void Shadow_OnPluginStart()
{
    HookEvent("player_spawn", Shadow_Event_PlayerSpawn);
    HookEvent("player_death", Shadow_Event_PlayerDeath);
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            Shadow_OnClientPutInServer(i);
        }
    }
}

public void Shadow_OnMapStart()
{
    PrecacheSound(SHADOW_SOUND_DASH, true);
    PrecacheSound(SHADOW_SOUND_SNAP, true);
    PrecacheSound(SHADOW_SOUND_PARRY, true);
    
    PrecacheModel("materials/sprites/laserbeam.vmt", true);
    PrecacheModel("materials/sprites/glow01.vmt", true);

    for (int i = 1; i <= MaxClients; i++)
        Shadow_ResetState(i);
}

// =======================
// Gestion de Estado
// =======================

public void Shadow_OnClientPutInServer(int client)
{
    SDKUnhook(client, SDKHook_OnTakeDamage, Shadow_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Shadow_OnTakeDamage);
    
    SDKUnhook(client, SDKHook_PreThink, Shadow_PreThink);
    SDKHook(client, SDKHook_PreThink, Shadow_PreThink);
}

public void Shadow_Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && IsClientInGame(client))
    {
        if (g_iPlayerCharIdx[client] == SHADOW_INDEX)
        {
            Shadow_ResetState(client);
            SDKUnhook(client, SDKHook_OnTakeDamage, Shadow_OnTakeDamage);
            SDKHook(client, SDKHook_OnTakeDamage, Shadow_OnTakeDamage);
            SDKUnhook(client, SDKHook_PreThink, Shadow_PreThink);
            SDKHook(client, SDKHook_PreThink, Shadow_PreThink);
        }
    }
}

public void Shadow_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0) Shadow_ResetState(client);
}

void Shadow_ResetState(int client)
{
    g_fShadowSnapCD[client] = 0.0;
    g_fShadowBlastCD[client] = 0.0;
    g_fInhibitorReady[client] = 0.0;
    g_fInhibitorEndTime[client] = 0.0;
    g_fLastDamageTime[client] = 0.0;
    g_bInhibitorActive[client] = false;
    
    if (IsClientInGame(client))
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

// ==============================================================
// HOVER SHOES (PASIVA DE MOVILIDAD) & INHIBITOR SPEED OVERRIDES
// ==============================================================

public void Shadow_PreThink(int client)
{
    if (!Shadow_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != SHADOW_INDEX) return;

    int flags = GetEntityFlags(client);
    int buttons = GetClientButtons(client);

    if (g_bInhibitorActive[client])
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.3);
        
        float pos[3]; GetClientAbsOrigin(client, pos);
        pos[0] += GetRandomFloat(-15.0, 15.0);
        pos[1] += GetRandomFloat(-15.0, 15.0);
        pos[2] += GetRandomFloat(5.0, 45.0);
        TE_SetupGlowSprite(pos, PrecacheModel("materials/sprites/glow01.vmt"), 0.2, 0.5, 255);
        TE_SendToAll();
    }

    if (!(flags & FL_ONGROUND))
    {
        if (buttons & IN_JUMP)
        {
            float vel[3]; 
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            
            if (vel[2] < -20.0) 
            {
                vel[2] = -20.0;
            }

            float fwdAng[3], fwd[3], right[3];
            GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
            GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);

            float accel = 20.0; 
            if (buttons & IN_FORWARD)  { vel[0] += fwd[0]*accel; vel[1] += fwd[1]*accel; }
            if (buttons & IN_BACK)     { vel[0] -= fwd[0]*accel; vel[1] -= fwd[1]*accel; }
            if (buttons & IN_MOVELEFT) { vel[0] -= right[0]*accel; vel[1] -= right[1]*accel; }
            if (buttons & IN_MOVERIGHT){ vel[0] += right[0]*accel; vel[1] += right[1]*accel; }

            float maxSpeed = 300.0;
            float speed2D = SquareRoot(vel[0]*vel[0] + vel[1]*vel[1]);
            if (speed2D > maxSpeed) {
                vel[0] = (vel[0]/speed2D) * maxSpeed;
                vel[1] = (vel[1]/speed2D) * maxSpeed;
            }

            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

            float feetPos[3]; GetClientAbsOrigin(client, feetPos);
            TE_SetupSparks(feetPos, view_as<float>({0.0,0.0,-1.0}), 5, 2);
            TE_SendToAll();
        }
    }
}

// ==============================================================
// PASIVA: ANILLOS INHIBIDORES (I-FRAMES & DETECCION DE DAÑO)
// ==============================================================

public Action Shadow_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Shadow_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != SHADOW_INDEX) return Plugin_Continue;

    g_fLastDamageTime[victim] = GetEngineTime();

    if (g_bInhibitorActive[victim])
    {
        damage *= 0.5;
        return Plugin_Changed;
    }

    int currentHealth = GetClientHealth(victim);
    float now = GetEngineTime();
    if ((currentHealth - damage) <= 50.0 && now >= g_fInhibitorReady[victim])
    {
        g_fInhibitorReady[victim] = now + 60.0; 
        g_fInhibitorEndTime[victim] = now + 15.0; 
        g_bInhibitorActive[victim] = true;

        PrintToChat(victim, "\x04[Shadow]\x01 ¡ANILLOS INHIBIDORES REMOVIDOS! Daño Recibido -50% | Velocidad +30% | Chaos Blast Potenciado.");
        EmitSoundToAll(SHADOW_SOUND_DASH, victim); 

        CreateTimer(15.0, T_EndInhibitors, GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
    }

    return Plugin_Continue;
}

public Action T_EndInhibitors(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0)
    {
        g_bInhibitorActive[client] = false;
        if (IsClientInGame(client))
        {
            PrintToChat(client, "\x04[Shadow]\x01 Anillos inhibidores colocados de nuevo. Modo normal.");
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        }
    }
    return Plugin_Stop;
}

// ==============================================================
// HABILIDAD 1: CHAOS SNAP (TELEPORT & PERFECT DODGE CHAOS CONTROL)
// ==============================================================

public Action Command_ShadowAbility(int client, int args)
{
    if (!Shadow_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != SHADOW_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fShadowSnapCD[client])
    {
        PrintCenterText(client, "Chaos Snap Cooldown: %.1f", g_fShadowSnapCD[client] - now);
        return Plugin_Handled;
    }

    g_fShadowSnapCD[client] = now + 12.0;
    Shadow_PerformChaosSnap(client);

    return Plugin_Handled;
}

void Shadow_PerformChaosSnap(int client)
{
    float origin[3], angles[3], endPos[3];
    GetClientEyePosition(client, origin);
    GetClientEyeAngles(client, angles);
    
    float range = 600.0; 
    
    Handle trace = TR_TraceRayFilterEx(origin, angles, MASK_SOLID, RayType_Infinite, TraceFilter_ShadowNoSelf, client);
    if (TR_DidHit(trace))
    {
        float impact[3];
        TR_GetEndPosition(impact, trace);
        
        float dist = GetVectorDistance(origin, impact);
        if (dist > range)
        {
            float vec[3];
            MakeVectorFromPoints(origin, impact, vec);
            NormalizeVector(vec, vec);
            ScaleVector(vec, range);
            AddVectors(origin, vec, endPos);
        }
        else
        {
            endPos = impact;
        }
    }
    else
    {
        float fwd[3];
        GetAngleVectors(angles, fwd, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(fwd, range);
        AddVectors(origin, fwd, endPos);
    }
    delete trace;

    SetEntPropEnt(client, Prop_Send, "m_pounceAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_jockeyAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_carryAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_pummelAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_tongueOwner", -1);

    TeleportEntity(client, endPos, NULL_VECTOR, NULL_VECTOR);
    EmitSoundToAll(SHADOW_SOUND_SNAP, client);

    // --- MEJORAS VISUALES (SNAP) ---
    int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
    int glow = PrecacheModel("materials/sprites/glow01.vmt");
    
    int colorBeam[4] = {150, 0, 255, 200};
    int colorRing[4] = {150, 0, 255, 200};
    
    // 1. Estela de distorsión morada brillante
    TE_SetupBeamPoints(origin, endPos, beam, 0, 0, 0, 0.4, 15.0, 15.0, 0, 0.0, colorBeam, 0);
    TE_SendToAll();
    
    // 2. Luz dinámica morada en el destino
    Shadow_CreateTempLight(endPos, 150, 0, 255, 0.5, 400.0);
    
    // 3. Anillo de choque en el destino
    TE_SetupBeamRingPoint(endPos, 10.0, 250.0, beam, glow, 0, 15, 0.3, 20.0, 0.0, colorRing, 0, 0);
    TE_SendToAll();
    
    // 4. Chispas eléctricas en el destino
    TE_SetupSparks(endPos, NULL_VECTOR, 5, 3);
    TE_SendToAll();

    float now = GetEngineTime();
    if (now - g_fLastDamageTime[client] <= 1.2)
    {
        TriggerChaosControl(client);
    }
}

void TriggerChaosControl(int client)
{
    int timescale = CreateEntityByName("func_timescale");
    if (timescale != -1)
    {
        DispatchKeyValueFloat(timescale, "desiredTimescale", 0.25); 
        DispatchKeyValueFloat(timescale, "acceleration", 4.0);
        DispatchKeyValueFloat(timescale, "minBlendRate", 1.0);
        DispatchKeyValueFloat(timescale, "blendDeltaMultiplier", 3.0);
        DispatchSpawn(timescale);
        AcceptEntityInput(timescale, "Start");

        EmitSoundToAll(SHADOW_SOUND_SNAP, client);
        PrintToChatAll("\x04[Shadow]\x01 ¡CHAOS CONTROL! El tiempo global se ha ralentizado.");

        float pos[3]; GetClientAbsOrigin(client, pos);
        int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
        int glow = PrecacheModel("materials/sprites/glow01.vmt");
        int colorCtrl[4] = {0, 255, 255, 100};
        
        TE_SetupBeamRingPoint(pos, 10.0, 1000.0, beam, glow, 0, 0, 0.5, 10.0, 0.0, colorCtrl, 0, 0);
        TE_SendToAll();

        CreateTimer(3.0, T_EndChaosControl, EntIndexToEntRef(timescale), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action T_EndChaosControl(Handle timer, int ref)
{
    int entity = EntRefToEntIndex(ref);
    if (entity != INVALID_ENT_REFERENCE && IsValidEntity(entity))
    {
        AcceptEntityInput(entity, "Stop");
        AcceptEntityInput(entity, "Kill");
    }
    return Plugin_Stop;
}

// ==============================================================
// HABILIDAD 2: CHAOS BLAST (COLOSAL ONDA DE CHOQUE)
// ==============================================================

public Action Command_ShadowDash(int client, int args)
{
    if (!Shadow_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != SHADOW_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fShadowBlastCD[client])
    {
        PrintCenterText(client, "Chaos Blast Cooldown: %.1f", g_fShadowBlastCD[client] - now);
        return Plugin_Handled;
    }

    g_fShadowBlastCD[client] = now + 30.0; 
    TriggerChaosBlast(client);

    return Plugin_Handled;
}

void TriggerChaosBlast(int client)
{
    float pos[3]; GetClientAbsOrigin(client, pos);
    
    float vel[3]; vel[0] = 0.0; vel[1] = 0.0; vel[2] = 200.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    EmitSoundToAll(SHADOW_SOUND_PARRY, client); 

    float radius = 450.0;
    float damage = 500.0;

    // --- MEJORAS VISUALES (BLAST) ---
    int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
    int glow = PrecacheModel("materials/sprites/glow01.vmt");
    
    int colorRed[4] = {255, 0, 0, 255};
    int colorOrange[4] = {255, 100, 0, 255};
    
    if (g_bInhibitorActive[client])
    {
        damage = 750.0;
        radius = 600.0;
        TE_SetupBeamRingPoint(pos, 10.0, 600.0, beam, glow, 0, 15, 0.8, 30.0, 0.0, colorOrange, 0, 0); TE_SendToAll();
        CreateTimer(0.1, T_ShadowBlastRing2, EntIndexToEntRef(client));
        CreateTimer(0.2, T_ShadowBlastRing3, EntIndexToEntRef(client));
    }
    else
    {
        TE_SetupBeamRingPoint(pos, 10.0, 450.0, beam, glow, 0, 15, 0.6, 25.0, 0.0, colorRed, 0, 0); TE_SendToAll();
        CreateTimer(0.1, T_ShadowBlastRing2, EntIndexToEntRef(client));
        CreateTimer(0.2, T_ShadowBlastRing3, EntIndexToEntRef(client));
    }
    
    TE_SetupSparks(pos, NULL_VECTOR, 50, 20);
    TE_SendToAll();
    TE_SetupExplosion(pos, glow, 10.0, 1, 0, 0, 0); TE_SendToAll();

    // EL TEMBLOR DE CÁMARA (env_shake) HA SIDO ELIMINADO A PETICIÓN TUYA.

    // --- DAÑO Y DESINTEGRACIÓN ---
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float tPos[3]; GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(pos, tPos) <= radius)
            {
                int healthBefore = GetClientHealth(i);
                SDKHooks_TakeDamage(i, client, client, damage, DMG_BLAST);
                L4D_StaggerPlayer(i, client, pos);

                if (GetClientHealth(i) <= 0 && healthBefore > 0) {
                    Shadow_DissolveEntity(i);
                }

                float push[3]; MakeVectorFromPoints(pos, tPos, push);
                NormalizeVector(push, push);
                ScaleVector(push, 800.0);
                push[2] += 300.0;
                TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(pos, zPos) <= radius)
            {
                int healthBefore = GetEntProp(entity, Prop_Data, "m_iHealth");
                SDKHooks_TakeDamage(entity, client, client, 1000.0, DMG_BLAST);
                IgniteEntity(entity, 3.0);

                if (GetEntProp(entity, Prop_Data, "m_iHealth") <= 0 && healthBefore > 0) {
                    Shadow_DissolveEntity(entity);
                }
            }
        }
    }

    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (IsValidEntity(witch))
        {
            float wPos[3]; GetEntPropVector(witch, Prop_Send, "m_vecOrigin", wPos);
            if (GetVectorDistance(pos, wPos) <= radius)
            {
                int healthBefore = GetEntProp(witch, Prop_Data, "m_iHealth");
                SDKHooks_TakeDamage(witch, client, client, damage, DMG_BLAST);
                
                if (GetEntProp(witch, Prop_Data, "m_iHealth") <= 0 && healthBefore > 0) {
                    Shadow_DissolveEntity(witch);
                }
                
                float push[3]; MakeVectorFromPoints(pos, wPos, push);
                NormalizeVector(push, push); ScaleVector(push, 800.0); push[2] = 300.0;
                TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }
}

// Timers para los anillos escalonados
public Action T_ShadowBlastRing2(Handle timer, int clientRef)
{
    int client = EntRefToEntIndex(clientRef);
    if (client > 0 && IsValidEntity(client))
    {
        float pos[3]; GetClientAbsOrigin(client, pos);
        int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
        int glow = PrecacheModel("materials/sprites/glow01.vmt");
        
        int colorO2[4] = {255, 150, 0, 255};
        int colorR2[4] = {150, 0, 0, 255};
        
        if (g_bInhibitorActive[client])
            TE_SetupBeamRingPoint(pos, 10.0, 400.0, beam, glow, 0, 15, 0.6, 25.0, 0.0, colorO2, 0, 0);
        else
            TE_SetupBeamRingPoint(pos, 10.0, 300.0, beam, glow, 0, 15, 0.6, 25.0, 0.0, colorR2, 0, 0);
        TE_SendToAll();
    }
    return Plugin_Stop;
}

public Action T_ShadowBlastRing3(Handle timer, int clientRef)
{
    int client = EntRefToEntIndex(clientRef);
    if (client > 0 && IsValidEntity(client))
    {
        float pos[3]; GetClientAbsOrigin(client, pos);
        int beam = PrecacheModel("materials/sprites/laserbeam.vmt");
        int glow = PrecacheModel("materials/sprites/glow01.vmt");
        
        int colorO3[4] = {255, 200, 0, 255};
        int colorR3[4] = {100, 0, 0, 255};
        
        if (g_bInhibitorActive[client])
            TE_SetupBeamRingPoint(pos, 10.0, 200.0, beam, glow, 0, 15, 0.4, 20.0, 0.0, colorO3, 0, 0);
        else
            TE_SetupBeamRingPoint(pos, 10.0, 150.0, beam, glow, 0, 15, 0.4, 20.0, 0.0, colorR3, 0, 0);
        TE_SendToAll();
    }
    return Plugin_Stop;
}

// ==============================================================
// FUNCIÓN DE DESINTEGRACIÓN (Vaporizer Effect)
// ==============================================================

void Shadow_DissolveEntity(int victim)
{
    if (!IsValidEntity(victim)) return;
    
    int dissolver = CreateEntityByName("env_entity_dissolver");
    if (dissolver == -1) return;
    
    DispatchKeyValue(dissolver, "target", "shadow_dissolve_targ");
    DispatchKeyValue(dissolver, "magnitude", "220");
    DispatchKeyValue(dissolver, "speed", "3");
    DispatchSpawn(dissolver);
    
    DispatchKeyValue(victim, "targetname", "shadow_dissolve_targ");
    AcceptEntityInput(dissolver, "Dissolve", victim, victim);
    
    SetVariantString("OnUser1 !self:Kill::1.0:-1");
    AcceptEntityInput(dissolver, "AddOutput");
    AcceptEntityInput(dissolver, "FireUser1");
}

// Función para crear luces dinámicas temporales
void Shadow_CreateTempLight(float pos[3], int r, int g, int b, float duration, float distance)
{
    int light = CreateEntityByName("light_dynamic");
    if (light == -1) return;
    
    char sColor[16];
    Format(sColor, sizeof(sColor), "%i %i %i 255", r, g, b);
    DispatchKeyValue(light, "_light", sColor);
    DispatchKeyValueFloat(light, "distance", distance);
    DispatchKeyValueFloat(light, "spotlight_radius", 200.0);
    DispatchKeyValue(light, "style", "6"); // Estilo pulsante
    DispatchSpawn(light);
    TeleportEntity(light, pos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(light, "TurnOn");
    
    char input[64];
    Format(input, sizeof(input), "OnUser1 !self:TurnOff::%f:-1", duration - 0.1);
    SetVariantString(input); AcceptEntityInput(light, "AddOutput");
    Format(input, sizeof(input), "OnUser1 !self:Kill::%f:-1", duration);
    SetVariantString(input); AcceptEntityInput(light, "AddOutput");
    AcceptEntityInput(light, "FireUser1");
}

// ==============================================================
// PUENTES DE COMPATIBILIDAD CON EL MANAGER GENERAL (NO TOCAR)
// ==============================================================

public bool TraceFilter_ShadowNoSelf(int entity, int contentsMask, int data)
{
    return (entity != data);
}

public void Shadow_OnPlayerRunCmd_Proxy(int client, int &buttons)
{
}