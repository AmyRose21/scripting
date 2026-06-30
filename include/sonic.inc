/*
 * ======================================================
 *  [MODULO] Sonic The Hedgehog - Lore & Gameplay Overhaul v5.0
 *  
 *  REWORK MASIVO & QoL:
 *  - Checkpoint ELIMINADO. Reemplazado por 'Sonic Wind' (Tornado a distancia).
 *  - Sonic Wind suspende a Sonic en el aire brevemente para mejor movilidad (QoL).
 *  - Inmunidad de Fuego Amigo habilitada mientras se usa Homing Attack/Spin Dash (QoL).
 *  - Doble salto pasivo: Insta-Shield.
 *  - Caidas: Drop Dash explosivo automatico para salvarse.
 *  
 *  NUEVO V5.0 (PHYSICS REWORK):
 *  - Homing Attack ahora usa MOVETYPE_FLY para vuelo recto sin gravedad.
 *  - El ataque es AUTO-GUIADO en tiempo real persiguiendo al objetivo.
 *  - Hitbox por distancia (110 units) en vez de OnTouch para evitar "túnel" de colisión.
 *  - Retroceso con "flote" de 0.35s antes de restaurar la gravedad normal.
 * ======================================================
 */

#if defined SONIC_INCLUDED
    #endinput
#endif
#define SONIC_INCLUDED

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

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif

#if !defined SONIC_INDEX
    #define SONIC_INDEX 0
#endif

// =======================
// [SWITCHES DE ADMINISTRACION]
// false = Apagadas de fabrica, habilitar manual en codigo.
// =======================
bool g_bSonicInstinct_Enable = false; 
bool g_bSonicRevive_Enable   = false;

// =======================
// Trackers e identificadores Visuales
// =======================
int g_iSonicRevives[MAXPLAYERS + 1];

int g_iSonicJumps[MAXPLAYERS + 1];
int g_iSonicLastButtons[MAXPLAYERS + 1];
float g_fSonicAirDashNext[MAXPLAYERS + 1];

// Rework Homing Attack
bool g_bSonicHoming[MAXPLAYERS + 1];
int g_iSonicTarget[MAXPLAYERS + 1];
float g_fSonicDashTime[MAXPLAYERS + 1];
float g_fSonicActionCD[MAXPLAYERS + 1];
float g_fSonicWindCD[MAXPLAYERS + 1];

int g_iSonicBeamSprite = -1;
int g_iSonicGlowSprite = -1;

#define SONIC_EXPLOSION_CHANCE 0.35
#define SONIC_AIR_DASH_CD      0.5
#define SONIC_REVIVE_LIMIT     2

#define Sonic_IsValidClient(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1))

public void Sonic_OnMapStart()
{
    PrecacheSound("mobius/sfx/spring.mp3", true);
    PrecacheSound("mobius/sfx/instinct.mp3", true);
    PrecacheSound("mobius/sfx/boom.mp3", true);
    PrecacheSound("mobius/sfx/revive.mp3", true);

    g_iSonicBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    g_iSonicGlowSprite = PrecacheModel("materials/sprites/glow01.vmt", true);

    for (int i = 1; i <= MaxClients; i++) g_iSonicRevives[i] = 0;
}

public void Sonic_OnRoundStart()
{
    for (int i = 1; i <= MaxClients; i++) g_iSonicRevives[i] = 0;
}

public void Sonic_OnClientPutInServer(int client)
{
    g_iSonicRevives[client] = 0;
    g_iSonicJumps[client] = 0;
    
    Sonic_CancelHoming(client);
    
    g_fSonicDashTime[client] = 0.0;
    g_fSonicActionCD[client] = 0.0;
    g_fSonicWindCD[client] = 0.0;
    g_iSonicLastButtons[client] = 0;
    g_fSonicAirDashNext[client] = 0.0;
    
    SDKUnhook(client, SDKHook_OnTakeDamage, Sonic_OnTakeDamage_Combat);
    SDKUnhook(client, SDKHook_OnTakeDamage, Sonic_OnTakeDamage_Fall);
    SDKUnhook(client, SDKHook_PreThink, Sonic_PreThink);
    SDKUnhook(client, SDKHook_Touch, Sonic_OnTouch);
    
    SDKHook(client, SDKHook_OnTakeDamage, Sonic_OnTakeDamage_Combat);
    SDKHook(client, SDKHook_OnTakeDamage, Sonic_OnTakeDamage_Fall);
    SDKHook(client, SDKHook_PreThink, Sonic_PreThink);
    SDKHook(client, SDKHook_Touch, Sonic_OnTouch);
}

// Limpia el estado de vuelo
void Sonic_CancelHoming(int client)
{
    g_bSonicHoming[client] = false;
    g_iSonicTarget[client] = -1;
    if (IsClientInGame(client))
    {
        SetEntityMoveType(client, MOVETYPE_WALK);
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 5); 
        SetEntProp(client, Prop_Send, "m_CollisionGroup", 5); 
    }
}

// =======================
// PRETHINK & AUTO-HOMING LOGIC
// =======================
public void Sonic_PreThink(int client)
{
    if (g_iPlayerCharIdx[client] != SONIC_INDEX || !Sonic_IsValidClient(client) || !IsPlayerAlive(client)) return;
    
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0 || GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0 || GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) 
    {
        if (g_bSonicHoming[client]) Sonic_CancelHoming(client);
        return;
    }

    // ==========================================
    // LOGICA DE AUTO-GUIADO DEL HOMING ATTACK
    // ==========================================
    if (g_bSonicHoming[client])
    {
        int target = g_iSonicTarget[client];
        
        // Validacion del objetivo
        bool valid = false;
        if (target > 0 && IsValidEntity(target))
        {
            if (target <= MaxClients) { if (IsClientInGame(target) && IsPlayerAlive(target)) valid = true; }
            else { valid = true; } // Witches u otros entes
        }
        
        // Si el objetivo murio o el tiempo expiro, cancelar vuelo y caer
        if (!valid || GetEngineTime() > g_fSonicDashTime[client])
        {
            Sonic_CancelHoming(client);
            return;
        }

        // Posiciones
        float sPos[3], tPos[3];
        GetClientAbsOrigin(client, sPos);
        
        if (target <= MaxClients) GetClientAbsOrigin(target, tPos);
        else GetEntPropVector(target, Prop_Data, "m_vecOrigin", tPos);
        
        tPos[2] += 40.0; // Apuntar al pecho, no a los pies
        sPos[2] += 20.0; // Centro de Sonic

        float dist = GetVectorDistance(sPos, tPos);
        
        // 1. HITBOX POR DISTANCIA (Impacto Seguro sin túnel de físicas)
        if (dist <= 110.0) 
        {
            Sonic_PerformHomingImpact(client, target, tPos);
        }
        // 2. VUELO RECTIFICADO (El misil teledirigido)
        else 
        {
            float vel[3];
            MakeVectorFromPoints(sPos, tPos, vel);
            NormalizeVector(vel, vel);
            ScaleVector(vel, 3000.0); // Velocidad agresiva constante
            
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        }
        
        return; // Salimos para no hacer calculos de saltos mientras vuela
    }

    // ==========================================
    // INSTA SHIELD & JUMP CORE
    // ==========================================
    int flags = GetEntityFlags(client);
    int buttons = GetClientButtons(client);
    
    if ((flags & FL_ONGROUND) || GetEntityMoveType(client) == MOVETYPE_LADDER) {
        g_iSonicJumps[client] = 0;
    } else {
        bool bNewAirJump = ((buttons & IN_JUMP) && !(g_iSonicLastButtons[client] & IN_JUMP));
        
        if (bNewAirJump && g_iSonicJumps[client] == 0) 
        {
            g_iSonicJumps[client] = 1;
            
            float now = GetEngineTime();
            if (now > g_fSonicAirDashNext[client]) 
            {
                g_fSonicAirDashNext[client] = now + SONIC_AIR_DASH_CD;

                float ang[3], fwd[3], pos[3];
                GetClientEyeAngles(client, ang);
                ang[0] = 0.0; 
                GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
                ScaleVector(fwd, 600.0); fwd[2] = 250.0; 
                
                float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
                vel[0] = fwd[0]; vel[1] = fwd[1]; 
                vel[2] = (vel[2] < 0.0) ? fwd[2] : (vel[2] + fwd[2]);  
                
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
                GetClientAbsOrigin(client, pos);
                
                EmitSoundToAll("mobius/sfx/spring.mp3", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.25);
                PrintCenterText(client, "[+] INSTA-SHIELD ACTIVO!");
                TE_SetupBeamRingPoint(pos, 10.0, 180.0, g_iSonicGlowSprite, g_iSonicGlowSprite, 0, 15, 0.2, 5.0, 1.0, {150, 200, 255, 180}, 0, 0);
                TE_SendToAll();
                
                Sonic_ApplyAreaStagger(client, pos, 180.0, 450.0);
            }
        }
    }
    g_iSonicLastButtons[client] = buttons;
}

// =======================
// HABILIDAD 1 (Z) - HOMING ATTACK / SPIN DASH
// =======================
public void HabilidadSonicSuperJump(int client)
{
    if (!Sonic_IsValidClient(client) || !IsPlayerAlive(client) || IsFakeClient(client)) return;
    
    float now = GetEngineTime();
    if (now < g_fSonicActionCD[client])
    {
        PrintCenterText(client, "Ataques Enfriandose... (%.1f segs restantes)", g_fSonicActionCD[client] - now);
        return;
    }

    float eyePos[3], eyeAng[3], fwd[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);
    GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);

    int bestTarget = -1;
    float bestDist = 1200.0;
    float dotScanCos = 0.90;

    // Escaneo Infectados Jugadores
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float targetEPos[3]; GetClientAbsOrigin(i, targetEPos); targetEPos[2] += 40.0;
            float currentDistCheck = GetVectorDistance(eyePos, targetEPos);
            if (currentDistCheck < bestDist) {
                float targetLockVectorDir[3]; MakeVectorFromPoints(eyePos, targetEPos, targetLockVectorDir); NormalizeVector(targetLockVectorDir, targetLockVectorDir);
                if (GetVectorDotProduct(fwd, targetLockVectorDir) > dotScanCos) {
                    bestDist = currentDistCheck;
                    bestTarget = i;
                }
            }
        }
    }

    // Escaneo Witches
    int nEntWitch = -1;
    while ((nEntWitch = FindEntityByClassname(nEntWitch, "witch")) != -1)
    {
        if (!IsValidEntity(nEntWitch)) continue;
        float witchT[3]; GetEntPropVector(nEntWitch, Prop_Send, "m_vecOrigin", witchT); witchT[2] += 40.0;
        float currWDist = GetVectorDistance(eyePos, witchT);
        if (currWDist < bestDist) {
            float witchWPDir[3]; MakeVectorFromPoints(eyePos, witchT, witchWPDir); NormalizeVector(witchWPDir, witchWPDir);
            if (GetVectorDotProduct(fwd, witchWPDir) > dotScanCos) {
                bestDist = currWDist;
                bestTarget = nEntWitch; 
            }
        }
    }

    if (bestTarget != -1) 
    {
        // TARGET ENCONTRADO - INICIAR VUELO TELEDIGIRIDO
        g_fSonicActionCD[client] = now + 4.5;
        g_bSonicHoming[client] = true;
        g_iSonicTarget[client] = bestTarget;
        g_fSonicDashTime[client] = now + 1.5; // Tiempo máximo permitido de vuelo
        
        // CONFIGURACION FISICA
        SetEntityMoveType(client, MOVETYPE_FLY); // Vuelo sin gravedad
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 2); // Atraviesa infectados comunes y objetos
        SetEntProp(client, Prop_Send, "m_CollisionGroup", 2); 
        
        EmitSoundToAll("mobius/sfx/spring.mp3", client);
        PrintCenterText(client, "[*] HOMING ATTACK FIJADO AL OBJETIVO!");
        TE_SetupBeamFollow(client, g_iSonicBeamSprite, 0, 0.4, 5.0, 5.0, 0, {200, 200, 255, 190}); TE_SendToAll();
    }
    else 
    {
        // NO HAY TARGET - SPIN DASH TERRESTRE (Mantiene físicas normales)
        g_fSonicActionCD[client] = now + 8.0;
        g_bSonicHoming[client] = false; 
        g_fSonicDashTime[client] = now + 0.4; 

        float baseVelSpindsh[3]; baseVelSpindsh = fwd;
        ScaleVector(baseVelSpindsh, 2000.0); 
        baseVelSpindsh[2] = (baseVelSpindsh[2] < 200.0) ? 200.0 : baseVelSpindsh[2];
        
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, baseVelSpindsh);
        EmitSoundToAll("mobius/sfx/boom.mp3", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.85);
        PrintCenterText(client, "[*] SPIN DASH BURST!");
        
        float pPos[3]; GetClientAbsOrigin(client, pPos);
        Sonic_ApplyAreaStagger(client, pPos, 300.0, 600.0);
        TE_SetupBeamFollow(client, g_iSonicGlowSprite, 0, 0.8, 12.0, 8.0, 0, {0, 0, 255, 180}); TE_SendToAll();
    }
}

// IMPACTO Y RETROCESO FLOTANTE DEL HOMING ATTACK
void Sonic_PerformHomingImpact(int attacker, int victim, float targetPos[3])
{
    // Dano aumentado
    SDKHooks_TakeDamage(victim, attacker, attacker, 200.0, DMG_BLAST);
    
    // Identificar clase para empuje
    bool isWitch = false;
    char cls[32];
    if (victim > MaxClients) {
        GetEntityClassname(victim, cls, sizeof(cls));
        if (StrEqual(cls, "witch")) isWitch = true;
    }

    // Empuje basado en dirección
    float sRcd[3]; GetClientEyeAngles(attacker, sRcd); 
    GetAngleVectors(sRcd, sRcd, NULL_VECTOR, NULL_VECTOR);
    
    float pushFwd[3]; pushFwd = sRcd;
    ScaleVector(pushFwd, 800.0); pushFwd[2] += 400.0;

    if (victim <= MaxClients) {
        L4D_StaggerPlayer(victim, attacker, targetPos); 
        L4D2_CTerrorPlayer_Fling(victim, attacker, pushFwd);
    } else if (isWitch) {
        SetEntityMoveType(victim, MOVETYPE_FLY); 
        TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, pushFwd); 
    }

    // =====================================
    // RETROCESO (RECOIL) CON MOVETYPE_FLY
    // =====================================
    // Revertimos la dirección de la cámara de Sonic para el rebote
    sRcd[0] *= -500.0; 
    sRcd[1] *= -500.0; 
    sRcd[2] = 450.0; // Elevacion
    
    TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, sRcd); 

    // Limpieza de variables de Vuelo
    g_bSonicHoming[attacker] = false;
    g_iSonicTarget[attacker] = -1;
    
    EmitSoundToAll("mobius/sfx/spring.mp3", attacker, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.4);

    // Activar temporizador de caida elegante
    CreateTimer(0.35, T_SonicRestorePhysics, GetClientUserId(attacker), TIMER_FLAG_NO_MAPCHANGE);
}

// Devuelve la gravedad y colisiones tras el tiempo de "flote" del retroceso
public Action T_SonicRestorePhysics(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client))
    {
        SetEntityMoveType(client, MOVETYPE_WALK);
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 5); 
        SetEntProp(client, Prop_Send, "m_CollisionGroup", 5); 
    }
    return Plugin_Stop;
}

// =======================
// COMBATE CONTACTO TERRESTRE (SPIN DASH)
// =======================
public Action Sonic_OnTouch(int client, int other)
{
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return Plugin_Continue;

    // Solo se usa OnTouch para el Spin Dash (Ataque Terrestre que no usa homing)
    if (!g_bSonicHoming[client] && GetEngineTime() < g_fSonicDashTime[client] && other > 0 && IsValidEntity(other))
    {
        char targetCls[32]; GetEntityClassname(other, targetCls, sizeof(targetCls));
        bool SpecCheck = (other <= MaxClients && IsClientInGame(other) && GetClientTeam(other) == TEAM_INFECTED);
        bool wtCheck = StrEqual(targetCls, "witch");
        bool ctCheck = StrEqual(targetCls, "infected");

        if (SpecCheck || wtCheck || ctCheck) 
        {
            float targetPos[3];
            if (SpecCheck) GetClientAbsOrigin(other, targetPos); else GetEntPropVector(other, Prop_Send, "m_vecOrigin", targetPos);
            
            float fDashHitAng[3]; GetClientEyeAngles(client, fDashHitAng);
            GetAngleVectors(fDashHitAng, fDashHitAng, NULL_VECTOR, NULL_VECTOR);
            ScaleVector(fDashHitAng, 800.0); fDashHitAng[2] += 400.0;
            
            float dmg = (SpecCheck ? 150.0 : 400.0);
            SDKHooks_TakeDamage(other, client, client, dmg, DMG_CRUSH); 

            if (SpecCheck || wtCheck) {
               if (SpecCheck) { L4D_StaggerPlayer(other, client, targetPos); L4D2_CTerrorPlayer_Fling(other, client, fDashHitAng); }
               if (wtCheck) { SetEntityMoveType(other, MOVETYPE_FLY); TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, fDashHitAng); }
            } else {
                float fBodP[3]; fBodP[0] = fDashHitAng[0]*2.0; fBodP[1] = fDashHitAng[1]*2.0; fBodP[2] = 800.0;
                TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, fBodP);
            }

            float sRcd[3]; GetClientEyeAngles(client, sRcd); GetAngleVectors(sRcd, sRcd, NULL_VECTOR, NULL_VECTOR);
            sRcd[0] *= -450.0; sRcd[1] *= -450.0; sRcd[2] = 550.0; 
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, sRcd); 

            g_fSonicDashTime[client] = 0.0; 
            EmitSoundToAll("mobius/sfx/spring.mp3", client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.4);
            return Plugin_Handled; 
        }
    }
    return Plugin_Continue;
}

// =======================
// HABILIDAD 2 (X) - SONIC WIND (Tornado a distancia)
// =======================
public void Sonic_ActivateSonicWind(int client)
{
    if (!Sonic_IsValidClient(client) || !IsPlayerAlive(client) || IsFakeClient(client)) return;
    
    float now = GetEngineTime();
    if (now < g_fSonicWindCD[client])
    {
        PrintCenterText(client, "Sonic Wind en enfriamiento (%.1f segs)", g_fSonicWindCD[client] - now);
        return;
    }
    g_fSonicWindCD[client] = now + 18.0;

    float eyePos[3], eyeAng[3], endPos[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);
    
    Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SOLID, RayType_Infinite, TraceFilter_IgnoreSelf, client);
    if (TR_DidHit(trace)) {
        TR_GetEndPosition(endPos, trace);
    } else {
        float fwd[3]; GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(fwd, 1200.0);
        AddVectors(eyePos, fwd, endPos);
    }
    delete trace;

    EmitSoundToAll("mobius/sfx/boom.mp3", client);
    PrintCenterText(client, "[Sonic] SONIC WIND!");

    for(int i = 0; i < 5; i++) {
        float tPos[3]; tPos = endPos; tPos[2] += (i * 40.0);
        TE_SetupBeamRingPoint(tPos, 10.0, 200.0, g_iSonicBeamSprite, g_iSonicGlowSprite, 0, 10, 0.6, 10.0, 1.0, {50, 150, 255, 200}, 15, 0);
        TE_SendToAll();
    }

    if (!(GetEntityFlags(client) & FL_ONGROUND)) {
        float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[2] = 200.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    }

    Sonic_ApplyAreaStagger_Tornado(client, endPos, 250.0, 600.0);
}

void Sonic_ApplyAreaStagger_Tornado(int attacker, float origin[3], float radius, float pushPower) 
{
    float radiusSq = radius * radius;
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED) {
            float ePos[3]; GetClientAbsOrigin(i, ePos);
            if (GetVectorDistance(origin, ePos, true) <= radiusSq) {
                float push[3];
                push[0] = 0.0;
                push[1] = 0.0;
                push[2] = pushPower; 
                L4D_StaggerPlayer(i, attacker, origin);
                L4D2_CTerrorPlayer_Fling(i, attacker, push);
                SDKHooks_TakeDamage(i, attacker, attacker, 150.0, DMG_BLAST);
            }
        }
    }
    static const char sEnemyClasses[][] = {"infected", "witch"};
    for (int clsIdx = 0; clsIdx < sizeof(sEnemyClasses); clsIdx++) {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, sEnemyClasses[clsIdx])) != -1) {
            if (!IsValidEntity(ent)) continue;
            float ePos[3]; GetEntPropVector(ent, Prop_Data, "m_vecOrigin", ePos);
            if (GetVectorDistance(origin, ePos, true) <= radiusSq) {
                float push[3];
                push[0] = 0.0;
                push[1] = 0.0;
                push[2] = pushPower * 1.5;
                if (clsIdx == 0) {
                    SDKHooks_TakeDamage(ent, attacker, attacker, 100.0, DMG_BLAST);
                    TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
                } else {
                    SetEntityMoveType(ent, MOVETYPE_FLY);
                    TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
                    SDKHooks_TakeDamage(ent, attacker, attacker, 250.0, DMG_BLAST);
                }
            }
        }
    }
}

public bool TraceFilter_IgnoreSelf(int entity, int contentsMask, int data) { return entity != data; }


// =======================
// CAIDAS -> DROP DASH EXPLOSIVO
// =======================
public Action Sonic_OnTakeDamage_Fall(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return Plugin_Continue;

    if (damagetype & DMG_FALL)
    {
        damage = 0.0; 

        float fallDirC[3], sAHor[3]; GetClientEyeAngles(victim, sAHor); sAHor[0] = 0.0;
        GetAngleVectors(sAHor, fallDirC, NULL_VECTOR, NULL_VECTOR); ScaleVector(fallDirC, 1100.0); fallDirC[2] = 300.0; 
        TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, fallDirC);
        
        float vPos[3]; GetClientAbsOrigin(victim, vPos);
        Sonic_ApplyAreaStagger(victim, vPos, 280.0, 750.0);
        
        PrintCenterText(victim, "[+] SANO Y SALVO... DROP DASH AUTOMATICO EFECTUADO AL SUELO!");
        EmitSoundToAll("mobius/sfx/boom.mp3", victim, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.95);

        float rposz[3]; GetClientAbsOrigin(victim, rposz); rposz[2] += 20.0;
        TE_SetupBeamRingPoint(rposz, 50.0, 380.0, g_iSonicGlowSprite, g_iSonicGlowSprite, 0, 10, 0.45, 15.0, 1.0, {150, 150, 255, 180}, 20, 0); TE_SendToAll();
        return Plugin_Handled;
    }
    return Plugin_Continue;
}


// ============================
// NERVIOS DE ACERO INCAP MITIGATION & INMUNIDAD QoL
// ============================
public Action Sonic_OnTakeDamage_Combat(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return Plugin_Continue;
    if (damage <= 0.0) return Plugin_Continue;

    if (GetEngineTime() < g_fSonicDashTime[victim] || g_bSonicHoming[victim]) {
        if (attacker > 0 && attacker <= MaxClients && GetClientTeam(attacker) == 2) {
            damage = 0.0;
            return Plugin_Handled;
        }
        damage *= 0.3; 
        return Plugin_Changed;
    }

    if (!g_bSonicInstinct_Enable) return Plugin_Continue;

    int curHP = GetClientHealth(victim);
    if (damage >= curHP)
    {
        float LIFT[3] = {0.0, 0.0, 480.0};
        TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, LIFT);
        EmitSoundToClient(victim, "mobius/sfx/instinct.mp3");
        damage = 0.0;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

// ===============================
// SISTEMAS DE COMUNICACIONES
// ===============================
void Sonic_ApplyAreaStagger(int attacker, float origin[3], float radius, float pushPower)
{
    float radiusSq = radius * radius;

    for (int i = 1; i <= MaxClients; i++) 
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED) 
        {
            float iPos[3]; GetClientAbsOrigin(i, iPos);
            if (GetVectorDistance(origin, iPos, true) <= radiusSq) 
            {
                float dir[3]; MakeVectorFromPoints(origin, iPos, dir); NormalizeVector(dir, dir);
                ScaleVector(dir, pushPower); dir[2] += 250.0;
                
                L4D_StaggerPlayer(i, attacker, origin);
                L4D2_CTerrorPlayer_Fling(i, attacker, dir);
                SDKHooks_TakeDamage(i, attacker, attacker, 40.0, DMG_BLAST);
            }
        }
    }

    static const char sEnemyClasses[][] = {"infected", "witch"};
    for (int clsIdx = 0; clsIdx < sizeof(sEnemyClasses); clsIdx++) 
    {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, sEnemyClasses[clsIdx])) != -1) 
        {
            if (!IsValidEntity(ent)) continue;
            float ePos[3]; GetEntPropVector(ent, Prop_Data, "m_vecOrigin", ePos);
            
            if (GetVectorDistance(origin, ePos, true) <= radiusSq) 
            {
                float dir[3]; MakeVectorFromPoints(origin, ePos, dir); NormalizeVector(dir, dir);
                ScaleVector(dir, pushPower); dir[2] += GetRandomFloat(200.0, 450.0);
                
                if (clsIdx == 0) {
                    SDKHooks_TakeDamage(ent, attacker, attacker, 80.0, DMG_BLAST); TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, dir);
                } else {
                    SetEntityMoveType(ent, MOVETYPE_FLY); TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, dir); SDKHooks_TakeDamage(ent, attacker, attacker, 250.0, DMG_BLAST);
                }
            }
        }
    }
}

public void Sonic_OnKillInfected_Explosion(int attacker, int victim)
{
    if (g_iPlayerCharIdx[attacker] != SONIC_INDEX) return;
    if (GetRandomFloat(0.0, 1.0) > SONIC_EXPLOSION_CHANCE) return;

    char wepName[64]; GetClientWeapon(attacker, wepName, sizeof(wepName));
    if (!Sonic_IsWeaponMelee(wepName)) return;

    float pPos[3]; GetClientAbsOrigin(attacker, pPos);
    Sonic_ApplyAreaStagger(attacker, pPos, 280.0, 500.0);
    EmitSoundToAll("mobius/sfx/boom.mp3", attacker);
    
    float vPos[3]; GetClientAbsOrigin(victim, vPos);
    TE_SetupBeamRingPoint(vPos, 30.0, 300.0, g_iSonicBeamSprite, g_iSonicGlowSprite, 0, 15, 0.4, 6.0, 0.0, {50, 150, 255, 120}, 10, 0); TE_SendToAll();
}

bool Sonic_IsWeaponMelee(const char[] wpName) {
    if (StrContains(wpName, "melee") != -1) return true;
    if (StrContains(wpName, "chainsaw") != -1) return true;
    if (StrContains(wpName, "pan") != -1) return true;
    if (StrContains(wpName, "axe") != -1) return true;
    if (StrContains(wpName, "bat") != -1) return true;
    if (StrContains(wpName, "sword") != -1) return true;
    if (StrContains(wpName, "katana") != -1) return true;
    if (StrContains(wpName, "machete") != -1) return true;
    if (StrContains(wpName, "tonfa") != -1) return true;
    if (StrContains(wpName, "guitar") != -1) return true;
    if (StrContains(wpName, "crowbar") != -1) return true;
    if (StrContains(wpName, "club") != -1) return true;
    if (StrContains(wpName, "shovel") != -1) return true;
    if (StrContains(wpName, "knife") != -1) return true;
    if (StrContains(wpName, "pitchfork") != -1) return true; return false;
}

public Action Sonic_OnPlayerDeath(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Sonic_IsValidClient(victim) || IsFakeClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return Plugin_Continue;
    if (GetEntProp(victim, Prop_Send, "m_isIncapacitated")) return Plugin_Continue;

    if (!g_bSonicRevive_Enable) return Plugin_Continue; 
    if (g_iSonicRevives[victim] >= SONIC_REVIVE_LIMIT) return Plugin_Continue;

    g_iSonicRevives[victim]++;
    CreateTimer(0.5, Timer_SonicRevive, GetClientUserId(victim));

    PrintToChatAll("[SonicJump] Sonic revive gracias a sus nervios de acero (%d/%d)", g_iSonicRevives[victim], SONIC_REVIVE_LIMIT);
    EmitSoundToAll("mobius/sfx/revive.mp3", victim, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
    damage = 0.0; return Plugin_Changed;
}

public Action Timer_SonicRevive(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (!Sonic_IsValidClient(client) || IsPlayerAlive(client)) return Plugin_Stop;

    int rdFind = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
    if (rdFind > 0 && IsValidEntity(rdFind)) AcceptEntityInput(rdFind, "Kill");

    if (!L4D2_VScriptWrapper_ReviveByDefib(client)) L4D_RespawnPlayer(client);
    SetEntityHealth(client, 100);

    float lift[3] = {0.0, 0.0, 250.0};
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, lift); 
    EmitSoundToAll("mobius/sfx/revive.mp3", client);

    PrintToChatAll("[SonicJump] Sonic ha vuelto a la accion!"); return Plugin_Stop;
}