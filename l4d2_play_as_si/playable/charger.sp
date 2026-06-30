#if defined _pure_play_as_si_charger_included
 #endinput
#endif
#define _pure_play_as_si_charger_included

ConVar chargerHp;
ConVar chargerClawDmg;
ConVar chargerAbilityCooldown;
ConVar chargerImpactDmg;
ConVar chargerImpactRadius;
ConVar chargerHealPoint;

bool isChargerTouchHooked[MAXPLAYERS + 1];
Handle chargerSweeperTimer[MAXPLAYERS + 1]; // Timer para limpiar el camino

void AddChargerConVars()
{
    char desc[64];
    Format(desc, 64, "%t", "ConVar Charger HP");
    chargerHp = CreateConVar("l4d2_play_as_si_charger_hp", "400", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Charger Claw Damage");
    chargerClawDmg = CreateConVar("l4d2_play_as_si_charger_claw_dmg", "100", desc, 0, true, 10.0);
    Format(desc, 64, "%t", "ConVar Charger Ability Cooldown");
    chargerAbilityCooldown = CreateConVar("l4d2_play_as_si_charger_ability_cooldown", "3.0", desc, 0, true, 1.0);
    Format(desc, 64, "%t", "ConVar Charger Impact Damage");
    chargerImpactDmg = CreateConVar("l4d2_play_as_si_charger_impact_dmg", "500.0", desc, 0, true, 100.0);
    Format(desc, 64, "%t", "ConVar Charger Impact Radius");
    chargerImpactRadius = CreateConVar("l4d2_play_as_si_charger_impact_radius", "500.0", desc, 0, true, 50.0);
    Format(desc, 64, "%t", "ConVar Charger Heal");
    chargerHealPoint = CreateConVar("l4d2_play_as_si_charger_heal_point", "200.0", desc, 0, true, 100.0);

    // Necesitamos detectar cuando termina la carga para apagar el sweeper
    HookEvent("charger_charge_end", OnChargerChargeEnd);
}

public void OnChargerSuccess(int client)
{
    SetEntProp(client, Prop_Data, "m_iHealth", GetConVarInt(chargerHp));
    SetEntProp(client, Prop_Data, "m_iMaxHealth", GetConVarInt(chargerHp));
}

// Se llama cuando el Charger termina de cargar (ya sea por tiempo o impacto contra pared)
public void OnChargerChargeEnd(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(!IsSurvivor(client) || !(playerStatus[client] == PLAYABLE_CHARGER))
        return;
    
    UnhookTouchCharger(client);
    SetAbilityCooldown(client, GetConVarFloat(chargerAbilityCooldown));
    
    // IMPORTANTE: Detener el Sweeper para ahorrar recursos
    KillTimerSafety(chargerSweeperTimer[client]);
}

public void OnChargerAbilityUse(int client)
{
    HookTouchCharger(client);
    
    // Iniciar el Sweeper (Barredora de obstáculos)
    // Se ejecuta cada 0.1s para limpiar el camino antes de que ocurra la colisión física
    KillTimerSafety(chargerSweeperTimer[client]);
    chargerSweeperTimer[client] = CreateTimer(0.1, Timer_ChargerSweeper, client, TIMER_REPEAT);
}

public void OnPlayerChargerDeath(int client)
{
    UnhookTouchCharger(client);
    KillTimerSafety(chargerSweeperTimer[client]);
}

void HookTouchCharger(int client)
{
    if(!isChargerTouchHooked[client])
    {
        isChargerTouchHooked[client] = true;
        SDKHook(client, SDKHook_StartTouch, OnStartTouchCharger);
    }
}

void UnhookTouchCharger(int client)
{
    SDKUnhook(client, SDKHook_StartTouch, OnStartTouchCharger);
    isChargerTouchHooked[client] = false;
}

// --------------------------------------------------------------------------------
// SISTEMA IMPARABLE (Sweeper)
// --------------------------------------------------------------------------------
Action Timer_ChargerSweeper(Handle timer, int client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client))
    {
        chargerSweeperTimer[client] = null;
        return Plugin_Stop;
    }

    // Calcular vector hacia adelante (Zona de barrido)
    float origin[3], angles[3], fwd[3], end[3];
    GetClientAbsOrigin(client, origin);
    origin[2] += 40.0; // Altura del pecho
    GetClientEyeAngles(client, angles);
    GetAngleVectors(angles, fwd, NULL_VECTOR, NULL_VECTOR);
    NormalizeVector(fwd, fwd);
    ScaleVector(fwd, 200.0); // Rango de 200 unidades al frente
    AddVectors(origin, fwd, end);

    // Definir el tamaño del Charger (Hull)
    float mins[3] = {-20.0, -20.0, -20.0};
    float maxs[3] = {20.0, 20.0, 20.0};

    // Lanzar un trazado que procese todo lo que toque (Filtro personalizado)
    // CORRECCION: Usamos MASK_PLAYERSOLID que incluye CONTENTS_MOVEABLE (autos/props)
    TR_TraceHullFilter(origin, end, mins, maxs, MASK_PLAYERSOLID | MASK_NPCSOLID, ChargerSweeperFilter, client);

    return Plugin_Continue;
}

// Filtro que decide qué hacer con lo que encontramos en el camino
public bool ChargerSweeperFilter(int entity, int contentsMask, int client)
{
    if (entity == client) return false;
    if (!IsValidEntity(entity)) return false;

    // Si choca con el mundo (paredes, suelo), detener el trace
    if (entity == 0) return true; 

    char classname[64];
    GetEntityClassname(entity, classname, sizeof(classname));

    // 1. ELIMINAR INFECTADOS COMUNES (Para que no frenen la carga)
    if (StrEqual(classname, "infected", false))
    {
        // Matar instantáneamente antes de tocarlo
        SDKHooks_TakeDamage(entity, client, client, 1000.0, DMG_SLASH);
        return false; // Retornar false para que el rayo siga atravesando y busque más enemigos detrás
    }

    // 2. MOVER OBJETOS FÍSICOS (Autos, Cajas, Props)
    if (StrContains(classname, "prop_physics") != -1 || StrContains(classname, "prop_car") != -1)
    {
        // Calcular fuerza tipo Tank
        float vel[3], ang[3];
        GetClientEyeAngles(client, ang);
        GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
        NormalizeVector(vel, vel);
        ScaleVector(vel, 1200.0); // Fuerza de empuje masiva
        vel[2] = 300.0; // Un poco de elevación para que vuele

        // Forzar movimiento
        AcceptEntityInput(entity, "EnableMotion"); // Despertar objeto si está dormido
        TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vel);
        
        // --- CLAVE DEL ÉXITO ---
        // Cambiar grupo de colisión a "DEBRIS" (1) temporalmente.
        // Esto hace que el Charger lo atraviese como un fantasma mientras el objeto sale volando.
        // Evita el "Stumble" (choque seco).
        SetEntProp(entity, Prop_Data, "m_CollisionGroup", 1);
        
        // Restaurar la colisión después de 1 segundo
        DataPack dp;
        CreateDataTimer(1.0, TimerRestoreCollision, dp);
        dp.WriteCell(entity);
        dp.WriteCell(0); // Restaurar a Default (0)
        
        return false; // Continuar trace (atravesar)
    }

    return false; // Ignorar cualquier otra cosa y seguir buscando
}

// Restaurar colisión del auto/objeto
Action TimerRestoreCollision(Handle timer, DataPack dp)
{
    dp.Reset();
    int entity = dp.ReadCell();
    int originalGroup = dp.ReadCell();

    if(IsValidEntity(entity))
    {
        SetEntProp(entity, Prop_Data, "m_CollisionGroup", originalGroup);
    }
    return Plugin_Stop;
}

// --------------------------------------------------------------------------------

Action OnStartTouchCharger(int entity, int other)
{
    // Lógica estándar de daño al tocar (backup por si el sweeper falla o es lateral)
    if(IsSpecialInfected(other))
    {
        EmitSoundToClient(entity, "player/charger/loud_chargerimpact_03.wav");
        SDKHooks_TakeDamage(other, entity, entity, GetConVarFloat(chargerImpactDmg));
    }
    else
    {
        if(IsValidEdict(other) && other > MaxClients)
        {
             char classname[32];
             GetEntityClassname(other, classname, 32);
             if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
             {
                 EmitSoundToClient(entity, "player/charger/loud_chargerimpact_03.wav");
                 SDKHooks_TakeDamage(other, entity, entity, GetConVarFloat(chargerImpactDmg));
             }
        }
    }
    return Plugin_Continue;
}

public void L4D2_OnChargerImpact(int client)
{
    if(!IsSurvivor(client) || !(playerStatus[client] == PLAYABLE_CHARGER))
        return;

    UnhookTouchCharger(client);
    float center[3];
    float target[3];
    GetAbsOrigin(client, center);
    
    // Daño de área al impactar contra pared (Impacto final)
    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsInfected(i) || !IsPlayerAlive(i))
            continue;

        GetAbsOrigin(i, target);
        if(GetVectorDistance(center, target) <= GetConVarFloat(chargerImpactRadius))
        {
            SDKHooks_TakeDamage(i, client, client, 1.0, DMG_BLAST, -1, NULL_VECTOR, NULL_VECTOR, false);
        }
    }

    for(int i = MAXPLAYERS + 1; i < GetMaxEntities(); i++)
    {
        if(!IsValidEntity(i)) continue;

        char classname[32];
        GetEntityClassname(i, classname, 32);
        
        if(StrEqual(classname, "infected", false) || StrEqual(classname, "witch", false))
        {
            GetAbsOrigin(i, target);
            if(GetVectorDistance(center, target)  <= GetConVarFloat(chargerImpactRadius))
            {
                SDKHooks_TakeDamage(i, client, client, 1.0, DMG_BLAST, -1, NULL_VECTOR, NULL_VECTOR, false);
            }
        }
    }
}