/* 
    Amy.sp - Lógica optimizada para el personaje Amy Rose.
    Debe ser incluido en el plugin principal.
*/

#if !defined AMY_INDEX
    #define AMY_INDEX 3 
#endif

// Lista de sonidos de hueso roto
static const char g_BoneSounds[][64] = {
    "mobius/sfx/bones/bone_crack_1.mp3",
    "mobius/sfx/bones/bone_crack_2.mp3",
    "mobius/sfx/bones/bone_crack_3.mp3"
};

// ===================== CICLO DE VIDA =====================

public void Amy_OnPluginStart()
{
    // Hookeo tardío por si recargamos el plugin
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            SDKHook(i, SDKHook_OnTakeDamage, Amy_OnTakeDamage);
        }
    }
}

public void Amy_OnMapStart()
{
    for (int i = 0; i < sizeof(g_BoneSounds); i++)
    {
        PrecacheSound(g_BoneSounds[i], true);
    }
}

public void Amy_OnMapEnd()
{
    // Limpieza si fuera necesaria
}

public void Amy_Event_PlayerSpawn(Event event, const char[] name, int client)
{
    // Reasegurar hook al spawnear
    SDKHook(client, SDKHook_OnTakeDamage, Amy_OnTakeDamage);
}

// ===================== INMUNIDAD (SDKHOOKS) =====================
// Esta es la forma correcta de bloquear daño en Source.
public Action Amy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    // Verificar validez
    if (victim <= 0 || victim > MaxClients) return Plugin_Continue;

    // Verificar si es Amy usando la variable global del main
    if (g_iPlayerCharIdx[victim] == AMY_INDEX)
    {
        // Bloquear ácido (Spitter), veneno o radiación
        if ((damagetype & DMG_ACID) || (damagetype & DMG_POISON) || (damagetype & DMG_RADIATION))
        {
            damage = 0.0;
            return Plugin_Handled; // Bloquea el daño totalmente
        }
    }
    return Plugin_Continue;
}

// ===================== HABILIDAD MELEE (OPTIMIZADA) =====================

public void LaunchPowerfulMelee(int attacker)
{
    // 1. Verificar identidad
    if (g_iPlayerCharIdx[attacker] != AMY_INDEX) return;

    // 2. Obtener vectores
    float origin[3], angles[3], forward[3], endPos[3];
    GetClientEyePosition(attacker, origin); // Usar ojos, no pies, para mejor puntería
    GetClientEyeAngles(attacker, angles);
    
    GetAngleVectors(angles, forward, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(forward, 150.0); // Rango de alcance
    AddVectors(origin, forward, endPos);

    // 3. Animación (Resetear fatiga de shove para simular golpe fuerte)
    SetEntPropFloat(attacker, Prop_Send, "m_flNextShoveTime", GetGameTime() + 1.0);
    // Nota: "SetPlayerMeleeAnimation" depende del modelo, si no existe la animación, crashea. 
    // Lo seguro es manipular el shove penalty.

    // 4. RayTracing Eficiente
    TR_TraceRayFilter(origin, endPos, MASK_SHOT_HULL, RayType_EndPoint, TraceFilter_HitEnemy, attacker);
    
    if (TR_DidHit())
    {
        int entity = TR_GetEntityIndex();
        
        // Validar que golpeamos un infectado
        if (entity > 0 && IsValidEntity(entity) && Amy_IsInfected(entity))
        {
            ApplyAmyDamage(attacker, entity);
            
            // Check impacto pared retardado
            DataPack pack = new DataPack();
            pack.WriteCell(EntIndexToEntRef(entity)); // Usar referencias para seguridad
            CreateTimer(0.3, Timer_CheckImpact, pack); // 0.3s es más realista para impacto inmediato
        }
    }
}

public bool TraceFilter_HitEnemy(int entity, int contentsMask, int attacker)
{
    return (entity != attacker); // Ignorarnos a nosotros mismos
}

// ===================== DAÑO Y FISICAS =====================

void ApplyAmyDamage(int attacker, int enemy)
{
    // Aplicar daño real
    SDKHooks_TakeDamage(enemy, attacker, attacker, 350.0, DMG_CLUB);
    
    if (IsValidEntity(enemy))
    {
        // Empuje físico
        float enemyOrigin[3], attackerOrigin[3], pushDir[3];
        GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", enemyOrigin);
        GetClientAbsOrigin(attacker, attackerOrigin);
        
        MakeVectorFromPoints(attackerOrigin, enemyOrigin, pushDir);
        NormalizeVector(pushDir, pushDir);
        ScaleVector(pushDir, 1100.0);
        pushDir[2] += 200.0; // Levantar un poco
        
        TeleportEntity(enemy, NULL_VECTOR, NULL_VECTOR, pushDir);
    }
}

// ===================== LOGICA DE PARED Y HUESOS =====================

public Action Timer_CheckImpact(Handle timer, DataPack pack)
{
    pack.Reset();
    int ref = pack.ReadCell();
    delete pack;

    int enemy = EntRefToEntIndex(ref);
    if (enemy == INVALID_ENT_REFERENCE || !IsValidEntity(enemy)) return Action_Stop;

    // Verificar si sigue vivo (si murió por el golpe, no suena hueso)
    bool isAlive = false;
    if (enemy <= MaxClients) isAlive = IsPlayerAlive(enemy);
    else isAlive = (GetEntProp(enemy, Prop_Data, "m_iHealth") > 0);

    if (isAlive)
    {
        if (ImpactAgainstWall(enemy)) ApplyBoneCrackEffect(enemy, true);
        else ApplyBoneCrackEffect(enemy, false);
    }
    return Action_Stop;
}

bool ImpactAgainstWall(int enemy)
{
    float origin[3], vel[3], endPos[3];
    GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", origin);
    GetEntPropVector(enemy, Prop_Data, "m_vecVelocity", vel);
    
    // Si la velocidad es muy baja, no chocó fuerte
    if (GetVectorLength(vel) < 100.0) return false;

    // Predecir posición futura
    NormalizeVector(vel, vel);
    ScaleVector(vel, 50.0);
    AddVectors(origin, vel, endPos);
    
    // RayTrace solo contra el mundo (paredes)
    TR_TraceRayFilter(origin, endPos, MASK_SOLID, RayType_EndPoint, TraceFilter_WorldOnly, enemy);
    return TR_DidHit();
}

public bool TraceFilter_WorldOnly(int entity, int contentsMask, int data)
{
    return (entity == 0); // 0 es el mundo (WorldSpawn)
}

void ApplyBoneCrackEffect(int enemy, bool hitWall)
{
    int rnd = GetRandomInt(0, sizeof(g_BoneSounds) - 1);
    EmitSoundToAll(g_BoneSounds[rnd], enemy);

    if (hitWall)
    {
        // Ralentizar usando LaggedMovementValue (propiedad neta de L4D2)
        SetEntPropFloat(enemy, Prop_Send, "m_flLaggedMovementValue", 0.2);
        CreateTimer(5.0, Timer_ResetSpeed, EntIndexToEntRef(enemy));
    }
    else
    {
        SetEntPropFloat(enemy, Prop_Send, "m_flLaggedMovementValue", 0.5);
        CreateTimer(3.0, Timer_ResetSpeed, EntIndexToEntRef(enemy));
    }
}

public Action Timer_ResetSpeed(Handle timer, int ref)
{
    int enemy = EntRefToEntIndex(ref);
    if (enemy != INVALID_ENT_REFERENCE && IsValidEntity(enemy))
    {
        SetEntPropFloat(enemy, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
    return Action_Stop;
}

// Helper para detectar infectados (Comunes y Especiales)
bool Amy_IsInfected(int entity)
{
    if (entity > 0 && entity <= MaxClients)
    {
        return IsClientInGame(entity) && GetClientTeam(entity) == 3;
    }
    else if (entity > MaxClients)
    {
        char cls[32];
        GetEntityClassname(entity, cls, sizeof(cls));
        return (StrEqual(cls, "infected") || StrEqual(cls, "witch"));
    }
    return false;
}