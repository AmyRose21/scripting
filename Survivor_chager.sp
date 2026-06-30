#include <sourcemod>
#include <sdktools>
#include <sdkhooks> // Necesario para TakeDamage

#define CHARGER_SPEED    1000.0
#define IMPACT_DAMAGE    50.0
#define IMPACT_PUSH      500.0
#define CHARGER_DURATION 1.5 // 3.0 es demasiado tiempo volando para L4D2

public Plugin myinfo = {
    name = "Charger Ability Simple",
    author = "TuNombre",
    description = "Habilidad simple de carga",
    version = "1.0",
    url = ""
};

public void OnPluginStart() {
    RegConsoleCmd("sm_charger_ability", Command_ChargerAbility);
}

// ----------- UTILIDADES ------------

bool IsClientInWater(int client) {
    return GetEntProp(client, Prop_Send, "m_nWaterLevel") > 1;
}

bool IsClientCrouching(int client) {
    return GetEntProp(client, Prop_Send, "m_bDucked") != 0;
}

// Unificamos la obtención de posición para clientes y entidades
void GetAbsOrigin(int entity, float pos[3]) {
    GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
}

void ApplyPushForce(int entity, float direction[3], float speed) {
    float velocity[3];
    // Copiamos la dirección para no modificar la original
    float tempDir[3];
    tempDir = direction;
    
    NormalizeVector(tempDir, velocity);
    ScaleVector(velocity, speed);
    
    // En L4D2, para empujar supervivientes a veces es mejor añadir a la velocidad actual
    // pero Teleport funciona para un "set" duro.
    TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, velocity);
}

// Encuentra jugadores en un cono frente al origen
int GetEntitiesInCone(float origin[3], float direction[3], float maxDist, float angleDeg, int entities[], int maxEntities) {
    int count = 0;
    float pos[3];
    float toTarget[3];
    
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || !IsPlayerAlive(i))
            continue;

        GetAbsOrigin(i, pos);

        SubtractVectors(pos, origin, toTarget); // Alternativa nativa a MakeVectorFromPoints

        float distance = GetVectorLength(toTarget);
        if (distance > maxDist || distance < 10.0) // Ignorar si está demasiado lejos o es el mismo punto
            continue;

        NormalizeVector(toTarget, toTarget);
        float dot = GetVectorDotProduct(direction, toTarget);
        
        // Evitar error de dominio en ArcCosine
        if (dot > 1.0) dot = 1.0;
        if (dot < -1.0) dot = -1.0;

        float angleRad = ArcCosine(dot); 

        if (RadToDeg(angleRad) < angleDeg / 2.0) {
            entities[count++] = i;
            if (count >= maxEntities)
                break;
        }
    }
    return count;
}

void ApplyDamage(int victim, int attacker, float damage) {
    if (!IsValidEntity(victim) || !IsClientInGame(victim)) return;

    // Usamos DMG_BLAST o DMG_CLUB para impacto físico
    SDKHooks_TakeDamage(victim, attacker, attacker, damage, DMG_CLUB); 
}

// ----------- HABILIDAD PRINCIPAL ------------

public Action Command_ChargerAbility(int client, int args) {
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) 
        return Plugin_Handled;

    if (IsClientInWater(client) || IsClientCrouching(client)) {
        PrintToChat(client, "No puedes usar esto en agua o agachado.");
        return Plugin_Handled;
    }

    // 1. Configurar vectores
    float viewAngles[3];
    GetClientEyeAngles(client, viewAngles);

    float forward[3];
    GetAngleVectors(viewAngles, forward, NULL_VECTOR, NULL_VECTOR);
    NormalizeVector(forward, forward);

    // 2. Aplicar movimiento al jugador (EL CHARGE)
    SetEntityMoveType(client, MOVETYPE_FLY); // Fly evita fricción con el suelo
    ApplyPushForce(client, forward, CHARGER_SPEED);
    
    // Timer para detener la carga
    CreateTimer(CHARGER_DURATION, EndCharge, client);

    // 3. Detección de impacto (Estilo "Shockwave" inmediato)
    // NOTA: Esto golpea instantáneamente en el momento de presionar la tecla.
    float origin[3];
    GetAbsOrigin(client, origin);

    int hitEntities[MAXPLAYERS+1];
    // CORRECCIÓN: sizeof sin dividir por 4
    int numHits = GetEntitiesInCone(origin, forward, 200.0, 60.0, hitEntities, sizeof(hitEntities));

    for (int i = 0; i < numHits; i++) {
        int enemy = hitEntities[i];
        
        // Evitar golpearse a uno mismo
        if (enemy == client) continue;
        
        // Fuego amigo: Si quieres evitar dañar compañeros, descomenta esto:
        // if (GetClientTeam(client) == GetClientTeam(enemy)) continue;

        float enemyPos[3];
        GetAbsOrigin(enemy, enemyPos);

        float dirToEnemy[3];
        SubtractVectors(enemyPos, origin, dirToEnemy);
        NormalizeVector(dirToEnemy, dirToEnemy);
        
        // Añadir un poco de componente vertical (Z) para levantarlos del suelo
        dirToEnemy[2] += 0.5;
        NormalizeVector(dirToEnemy, dirToEnemy);

        ApplyPushForce(enemy, dirToEnemy, IMPACT_PUSH);
        ApplyDamage(enemy, client, IMPACT_DAMAGE); // client es el atacante
    }

    return Plugin_Handled;
}

public Action EndCharge(Handle timer, any client) {
    if (IsClientInGame(client) && IsPlayerAlive(client)) {
        SetEntityMoveType(client, MOVETYPE_WALK);
        
        // Frenar al jugador al terminar
        float stop[3] = {0.0, 0.0, 0.0};
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, stop);
    }
    return Plugin_Stop;
}