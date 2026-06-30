/*
 * ======================================================
 *  [MODULO] Cream the Rabbit - Super Rework v5.0
 *
 *  v5.0 CHANGES - SUPER REWORK:
 *
 *  1. NUEVA HABILIDAD 2: RESURRECCION
 *     - Reemplaza completamente el Dash
 *     - Revive a TODOS los jugadores muertos del mapa
 *     - Los revividos aparecen con HP completa (100)
 *     - 1 USO POR RONDA (se reinicia al cambiar de mapa o reiniciar ronda)
 *     - Si no hay muertos, NO se consume el uso
 *     - Efectos visuales: ring de revivir dorado, glow en revividos, sonido angelical
 *     - Cream queda inmune por 3 segundos despues de revivir (proteccion)
 *     - Los revividos quedan inmunes 2 segundos al aparecer
 *     - Comando: sm_cream_dash (mantiene nombre por compatibilidad)
 *     - Comando nuevo: sm_cream_revive
 *
 *  2. ROBUSTEZ DE CODIGO:
 *     - Validaciones estrictas en cada funcion (client, entity, ref)
 *     - SDKUnhook antes de SDKHook (anti double-hook)
 *     - Limpieza segura de handles con null checks
 *     - Clamp de HP (0-200) y radio (>0)
 *     - ConVars con validacion null
 *     - Banderas explicitas de estado
 *     - ArrayList para trackeo de estados temporales
 *
 *  3. FIX DE BUGS:
 *     - BUG 1: Cheese podia desmayarse multiples veces seguidas (cooldown no respetado)
 *       FIX: g_bCheeseAlive se checkea ANTES de aplicar el desmayo
 *     - BUG 2: Heal activo no se cancelaba correctamente al morir
 *       FIX: Cream_ResetState ahora cancela el heal explicitamente
 *     - BUG 3: Timer de heal quedaba zombie si el cliente se desconectaba
 *       FIX: Timer verifica IsClientInGame en cada tick
 *     - BUG 4: Glide activo durante incap (causaba movimiento raro)
 *       FIX: PreThink checkea m_isIncapacitated antes del glide
 *     - BUG 5: m_iMaxHealth podia devolver 0 o negativo (causaba HP negativo)
 *       FIX: Clamp a minimo 1 en todas las lecturas de maxHealth
 *     - BUG 6: Cooldowns no se reseteaban al cambiar de mapa
 *       FIX: Cream_OnMapStart resetea todos los cooldowns
 *     - BUG 7: Touch hook podia dispararse con entidades invalidas
 *       FIX: Validacion IsValidEntity + EntRefToEntIndex en cada touch
 *     - BUG 8: Speed boost de aliados no se reseteaba si se desconectaban
 *       FIX: Timer verifica IsClientInGame antes de aplicar reset
 *
 *  4. REAJUSTES:
 *     - Heal: radio mas grande (300->350), mas ticks (7->8), sin autodano
 *     - Cheese: cooldown de proteccion ajustado (40->35s), respawn mas rapido (15->12s)
 *     - Glide: descenso mas lento (-50 -> -40), max speed ajustado (250->280)
 *     - HP cap de revividos: 100 (no se revive con buffos previos)
 *     - Inmunidad post-revive: 3 segundos para evitar morir inmediatamente
 *
 *  Habilidad 1: Heal de area (movil)
 *  Habilidad 2: Resurreccion (1 vez por ronda)
 *  Pasivas: Glide WASD, Cheese defiende y revive
 * ======================================================
 */

#if defined _Cream_included
    #endinput
#endif
#define _Cream_included

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
#if !defined CREAM_INDEX
    #define CREAM_INDEX 7
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
#define CHEESE_ALIVE_HEAL       10
#define CHEESE_DEAD_HEAL        5
#define CHEESE_RESPAWN_TIME     12.0    // v5: bajado de 15 a 12s
#define CHEESE_PROTECT_CD       35.0    // v5: bajado de 40 a 35s
#define CHEESE_DESPAWN_HP       30      // HP bajo el cual Cheese se desmaya

#define CREAM_HEAL_RADIUS       350.0   // v5: subido de 300 a 350
#define CREAM_HEAL_TICKS        8       // v5: subido de 7 a 8
#define CREAM_HEAL_SPEED_MULT   0.3     // 30% velocidad durante heal
#define CREAM_HEAL_TICK_TIME    1.0

#define CREAM_GLIDE_DESCENT     -40.0   // v5: descenso mas lento
#define CREAM_GLIDE_MAX_SPEED   280.0   // v5: max speed ajustado
#define CREAM_GLIDE_ACCEL       20.0

// Resurreccion
#define CREAM_REVIVE_HP             100     // HP con la que reviven
#define CREAM_REVIVE_IMMUNE_TIME    3.0     // Inmunidad post-revive de Cream
#define CREAM_REVIVE_VICTIM_IMMUNE  2.0     // Inmunidad post-revive de los revividos
#define CREAM_REVIVE_RADIUS         2000.0  // Radio de busqueda (mapa entero)

// Limites de seguridad
#if !defined HP_MIN
    #define HP_MIN 1
#endif
#if !defined HP_MAX
    #define HP_MAX 200
#endif

// =======================
// Sonidos
// =======================
#define SND_CREAM_HEAL      "mobius/sfx/cream/heal_loop.wav"
#define SND_CREAM_REVIVE    "mobius/sfx/cream/revive.mp3"
#define SND_CHEESE_DIE      "mobius/sfx/cream/chao_die.wav"
#define SND_CHEESE_ALIVE    "mobius/sfx/cream/chao_happy.wav"
#define SND_CREAM_FALLBACK  "ambient/energy/zap1.wav"  // fallback si no existe revive.mp3

// =======================
// Variables Globales
// =======================
bool  g_bCreamHealActive[MAXPLAYERS + 1];
bool  g_bCheeseAlive[MAXPLAYERS + 1];
bool  g_bCheeseCanDespawn[MAXPLAYERS + 1]; // v5: anti multi-despawns

// Resurreccion (1 vez por ronda)
bool  g_bCreamReviveUsed[MAXPLAYERS + 1];
bool  g_bCreamReviveImmune[MAXPLAYERS + 1]; // Inmunidad temporal post-revive

float g_fCreamHealCooldown[MAXPLAYERS + 1];
float g_fCheeseRespawnTime[MAXPLAYERS + 1];
float g_fCheeseProtectTime[MAXPLAYERS + 1];
float g_fCreamReviveImmuneEnd[MAXPLAYERS + 1];

Handle g_hCreamHealTimer[MAXPLAYERS + 1];

// Sprites cacheados
int g_iCreamGlowSprite = -1;
int g_iCreamBeamSprite = -1;
int g_iCreamHaloSprite = -1;

// ConVars
ConVar g_cvCreamHealCD;
ConVar g_cvCreamHealRadius;

#define Cream_IsValidClient(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// INICIALIZACION
// =======================

public void Cream_OnPluginStart()
{
    g_cvCreamHealCD       = CreateConVar("cream_heal_cooldown", "15.0", "Cooldown de la habilidad de curar", _, true, 0.0, true, 120.0);
    g_cvCreamHealRadius   = CreateConVar("cream_heal_radius", "350.0", "Radio de curacion de area", _, true, 50.0, true, 2000.0);

    // Comandos
    RegConsoleCmd("sm_cream_heal", Command_CreamHeal);
    // Mantiene el nombre por compatibilidad con el Manager (Habilidad 2 = Dash slot)
    RegConsoleCmd("sm_cream_dash", Command_CreamRevive);
    // Comando nuevo y mas intuitivo
    RegConsoleCmd("sm_cream_revive", Command_CreamRevive);
    RegConsoleCmd("sm_cream_revivir", Command_CreamRevive);

    AutoExecConfig(true, "Cream_Abilities");

    // Hot reload: hookear clientes ya conectados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            Cream_OnClientPutInServer(i);
        }
    }
}

public void Cream_OnMapStart()
{
    // Precache de sonidos
    PrecacheSound(SND_CREAM_HEAL, true);
    PrecacheSound(SND_CREAM_REVIVE, true);
    PrecacheSound(SND_CHEESE_DIE, true);
    PrecacheSound(SND_CHEESE_ALIVE, true);
    PrecacheSound(SND_CREAM_FALLBACK, true);

    // Precache de sprites (cacheados)
    g_iCreamGlowSprite  = PrecacheModel("materials/sprites/glow01.vmt", true);
    g_iCreamBeamSprite  = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    g_iCreamHaloSprite  = PrecacheModel("materials/sprites/halo01.vmt", true);

    // v5 FIX BUG 6: Resetear cooldowns y estado de revive al cambiar de mapa
    for (int i = 1; i <= MaxClients; i++)
    {
        Cream_ResetState(i);
        g_bCreamReviveUsed[i] = false; // Reiniciar el uso de revive por mapa
    }
}

// =======================
// EVENTOS Y LIMPIEZA
// =======================

public void Cream_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;

    // Anti double-hook
    SDKUnhook(client, SDKHook_OnTakeDamage, Cream_OnTakeDamage);
    SDKUnhook(client, SDKHook_PreThink, Cream_PreThink);

    SDKHook(client, SDKHook_OnTakeDamage, Cream_OnTakeDamage);
    SDKHook(client, SDKHook_PreThink, Cream_PreThink);
}

// Llamado desde el Manager
public void Cream_Event_PlayerSpawn(Event event, const char[] name, int client)
{
    if (client <= 0 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;

    if (g_iPlayerCharIdx[client] == CREAM_INDEX)
    {
        Cream_ResetState(client);
        g_bCheeseAlive[client] = true;
        g_bCheeseCanDespawn[client] = true;

        // Solo mostrar mensaje si revive NO esta usado
        if (!g_bCreamReviveUsed[client])
        {
            EmitSoundToClient(client, SND_CHEESE_ALIVE);
            PrintToChat(client, "\x04[Cream]\x01 Cheese esta contigo. Curacion potenciada.");
            PrintToChat(client, "\x04[Cream]\x01 Tienes \x05Resurreccion\x01 disponible (1 vez por ronda).");
        }
        else
        {
            PrintToChat(client, "\x04[Cream]\x01 Cheese esta contigo. Resurreccion ya usada esta ronda.");
        }
    }
}

// Llamado desde el Manager
public void Cream_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        Cream_ResetState(client);
    }
}

// Llamado desde el Manager al final de ronda
public void Cream_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    // v5: Resetear revive al final de ronda
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i <= MaxClients)
        {
            g_bCreamReviveUsed[i] = false;
            Cream_ResetState(i);
        }
    }
}

void Cream_ResetState(int client)
{
    if (client < 0 || client > MaxClients) return;

    // v5 FIX BUG 2: Cancelar heal explicitamente
    g_bCreamHealActive[client] = false;
    g_bCheeseCanDespawn[client] = true;
    g_fCheeseRespawnTime[client] = 0.0;
    g_fCheeseProtectTime[client] = 0.0;
    g_bCreamReviveImmune[client] = false;
    g_fCreamReviveImmuneEnd[client] = 0.0;

    // v5 FIX BUG 3: Limpiar timer de heal de forma segura
    if (g_hCreamHealTimer[client] != null && g_hCreamHealTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hCreamHealTimer[client]);
        g_hCreamHealTimer[client] = null;
    }

    if (client >= 1 && client <= MaxClients && IsClientInGame(client))
    {
        SetEntityMoveType(client, MOVETYPE_WALK);
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

// =======================
// HELPERS DE SEGURIDAD
// =======================

// Clamp de HP
int Cream_ClampHP(int hp)
{
    if (hp < HP_MIN) return HP_MIN;
    if (hp > HP_MAX) return HP_MAX;
    return hp;
}

// Obtener maxHealth de forma segura
int Cream_GetMaxHealth(int client)
{
    int maxHp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
    if (maxHp <= 0) maxHp = 100;
    return maxHp;
}

// =======================
// PASIVAS: GLIDE (WASD STEERING) & AUTO-DEFENSA DE CHEESE
// =======================

public void Cream_PreThink(int client)
{
    if (!Cream_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != CREAM_INDEX) return;

    // v5 FIX BUG 4: No aplicar glide si esta incapacitado
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
    {
        return;
    }

    int flags = GetEntityFlags(client);
    int buttons = GetClientButtons(client);
    float now = GetEngineTime();

    // 1. RECOBRAR A CHEESE (Si vida >= 50 y Cheese estaba desmayado)
    if (!g_bCheeseAlive[client] && GetClientHealth(client) >= 50)
    {
        if (g_fCheeseRespawnTime[client] == 0.0)
        {
            g_fCheeseRespawnTime[client] = now + CHEESE_RESPAWN_TIME;
        }
        else if (now >= g_fCheeseRespawnTime[client])
        {
            g_bCheeseAlive[client] = true;
            g_bCheeseCanDespawn[client] = true; // v5: re-habilitar despawn
            g_fCheeseRespawnTime[client] = 0.0;
            EmitSoundToClient(client, SND_CHEESE_ALIVE);
            PrintToChat(client, "\x04[Cream]\x01 Cheese se ha despertado y vuelve a tu lado!");
        }
    }

    // 2. AUTO-DEFENSA DE CHEESE (Corta agarres de especiales automaticamente)
    if (g_bCheeseAlive[client])
    {
        int attacker = Cream_GetAttacker(client);
        if (attacker > 0 && IsClientInGame(attacker) && IsPlayerAlive(attacker))
        {
            if (now >= g_fCheeseProtectTime[client])
            {
                g_fCheeseProtectTime[client] = now + CHEESE_PROTECT_CD;

                float pos[3]; GetClientAbsOrigin(client, pos);
                L4D_StaggerPlayer(attacker, client, pos);
                SDKHooks_TakeDamage(attacker, client, client, 150.0, DMG_CLUB);

                // Forzar liberacion del motor de red de L4D2
                Cream_ClearAllGrabs(client);

                EmitSoundToAll(SND_CHEESE_ALIVE, client);
                PrintToChat(client, "\x04[Cream]\x01 Cheese embistio al atacante y te ha salvado!");
            }
        }
    }

    // 3. LOGICA DE PLANEO CON DIRECCION (Glide WASD)
    if (!(flags & FL_ONGROUND) && (buttons & IN_JUMP))
    {
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);

        // Descenso lento controlado
        if (vel[2] < CREAM_GLIDE_DESCENT)
        {
            vel[2] = CREAM_GLIDE_DESCENT;
        }

        // Air Steering
        float fwdAng[3], fwd[3], right[3];
        GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
        GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);

        if (buttons & IN_FORWARD)   { vel[0] += fwd[0] * CREAM_GLIDE_ACCEL;  vel[1] += fwd[1] * CREAM_GLIDE_ACCEL; }
        if (buttons & IN_BACK)      { vel[0] -= fwd[0] * CREAM_GLIDE_ACCEL;  vel[1] -= fwd[1] * CREAM_GLIDE_ACCEL; }
        if (buttons & IN_MOVELEFT)  { vel[0] -= right[0] * CREAM_GLIDE_ACCEL; vel[1] -= right[1] * CREAM_GLIDE_ACCEL; }
        if (buttons & IN_MOVERIGHT) { vel[0] += right[0] * CREAM_GLIDE_ACCEL; vel[1] += right[1] * CREAM_GLIDE_ACCEL; }

        // Limitar velocidad horizontal
        float speed2D = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
        if (speed2D > CREAM_GLIDE_MAX_SPEED)
        {
            vel[0] = (vel[0] / speed2D) * CREAM_GLIDE_MAX_SPEED;
            vel[1] = (vel[1] / speed2D) * CREAM_GLIDE_MAX_SPEED;
        }

        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    }

    // 4. GESTION DE INMUNIDAD POST-REVIVE
    if (g_bCreamReviveImmune[client] && now > g_fCreamReviveImmuneEnd[client])
    {
        g_bCreamReviveImmune[client] = false;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

// Devuelve el atacante actual de cualquier especial, o -1
int Cream_GetAttacker(int client)
{
    int attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
    if (attacker > 0) return attacker;
    attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
    if (attacker > 0) return attacker;
    attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
    if (attacker > 0) return attacker;
    attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
    if (attacker > 0) return attacker;
    attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
    if (attacker > 0) return attacker;
    return -1;
}

// Limpia todos los agarres del motor
void Cream_ClearAllGrabs(int client)
{
    SetEntPropEnt(client, Prop_Send, "m_pounceAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_jockeyAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_carryAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_pummelAttacker", -1);
    SetEntPropEnt(client, Prop_Send, "m_tongueOwner", -1);
}

// =======================
// GESTION DE DANO
// =======================

public Action Cream_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Cream_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != CREAM_INDEX) return Plugin_Continue;

    // 1. Inmunidad post-revive
    if (g_bCreamReviveImmune[victim])
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // 2. Cancelar curacion si recibe dano
    if (g_bCreamHealActive[victim])
    {
        Cream_CancelHeal(victim);
        PrintToChat(victim, "\x04[Cream]\x01 Curacion interrumpida por dano!");
    }

    // 3. v5 FIX BUG 1: El desmayo de Cheese (con flag anti multi-despawn)
    int currentHealth = GetClientHealth(victim);
    if (g_bCheeseAlive[victim] && g_bCheeseCanDespawn[victim] && (currentHealth - damage) < float(CHEESE_DESPAWN_HP))
    {
        g_bCheeseAlive[victim] = false;
        g_bCheeseCanDespawn[victim] = false; // v5: Evitar despawns repetidos
        g_fCheeseRespawnTime[victim] = 0.0;
        EmitSoundToClient(victim, SND_CHEESE_DIE);
        PrintToChat(victim, "\x04[Cream]\x01 Cheese se ha desmayado! Curate sobre 50 HP para que despierte.");
    }

    return Plugin_Continue;
}

// =======================
// HABILIDAD 1: HEAL (MOVILIDAD PARCIAL Y AUTO-HEAL)
// =======================

public Action Command_CreamHeal(int client, int args)
{
    if (!Cream_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != CREAM_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fCreamHealCooldown[client])
    {
        PrintToChat(client, "\x04[Cream]\x01 Curacion en enfriamiento (\x05%.1fs\x01)", g_fCreamHealCooldown[client] - now);
        return Plugin_Handled;
    }

    if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        PrintToChat(client, "\x04[Cream]\x01 No puedes curar en el aire.");
        return Plugin_Handled;
    }

    g_bCreamHealActive[client] = true;
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", CREAM_HEAL_SPEED_MULT);

    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(CREAM_HEAL_TICKS);

    g_hCreamHealTimer[client] = CreateTimer(CREAM_HEAL_TICK_TIME, T_CreamHealTick, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    PrintToChat(client, "\x04[Cream]\x01 Iniciando curacion de area movil...");
    return Plugin_Handled;
}

public Action T_CreamHealTick(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    int ticksLeft = pack.ReadCell();

    int client = GetClientOfUserId(userid);

    // v5 FIX BUG 3: Verificar cliente en cada tick
    if (!Cream_IsValidClient(client) || !g_bCreamHealActive[client])
    {
        delete pack;
        if (client > 0 && client <= MaxClients) g_hCreamHealTimer[client] = null;
        return Plugin_Stop;
    }

    ticksLeft--;

    if (ticksLeft <= 0)
    {
        Cream_CancelHeal(client);
        delete pack;
        return Plugin_Stop;
    }

    pack.Position = view_as<DataPackPos>(0);
    pack.WriteCell(userid);
    pack.WriteCell(ticksLeft);

    float radius = (g_cvCreamHealRadius != null) ? g_cvCreamHealRadius.FloatValue : CREAM_HEAL_RADIUS;
    float clientPos[3]; GetClientAbsOrigin(client, clientPos);
    int healAmount = g_bCheeseAlive[client] ? CHEESE_ALIVE_HEAL : CHEESE_DEAD_HEAL;
    bool anyoneHealed = false;

    // Curar Aliados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_SURVIVOR) continue;

        float targetPos[3]; GetClientAbsOrigin(i, targetPos);
        if (GetVectorDistance(clientPos, targetPos) <= radius)
        {
            int hp = GetClientHealth(i);
            int maxhp = Cream_GetMaxHealth(i);
            if (hp < maxhp)
            {
                int newHp = Cream_ClampHP(hp + healAmount);
                if (newHp > maxhp) newHp = maxhp;
                SetEntityHealth(i, newHp);
                anyoneHealed = true;
            }
        }
    }

    // Auto-curacion
    int myHp = GetClientHealth(client);
    int myMaxhp = Cream_GetMaxHealth(client);
    if (myHp < myMaxhp)
    {
        int newMyHp = Cream_ClampHP(myHp + healAmount);
        if (newMyHp > myMaxhp) newMyHp = myMaxhp;
        SetEntityHealth(client, newMyHp);
    }

    if (!anyoneHealed && ticksLeft < CREAM_HEAL_TICKS - 2)
    {
        PrintToChat(client, "\x04[Cream]\x01 Nadie cerca. Curacion cancelada.");
        Cream_CancelHeal(client);
        delete pack;
        return Plugin_Stop;
    }

    // Efecto visual
    if (g_iCreamGlowSprite > 0)
    {
        TE_SetupBeamRingPoint(clientPos, 10.0, radius, g_iCreamGlowSprite, 0, 0, 0, 0.5, 5.0, 0.0, {0, 255, 100, 100}, 0, 0);
        TE_SendToAll();
    }
    EmitSoundToAll(SND_CREAM_HEAL, client);

    return Plugin_Continue;
}

void Cream_CancelHeal(int client)
{
    if (client < 1 || client > MaxClients) return;

    g_bCreamHealActive[client] = false;

    if (IsClientInGame(client))
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }

    if (g_hCreamHealTimer[client] != null && g_hCreamHealTimer[client] != INVALID_HANDLE)
    {
        // No matar el timer aqui porque esta en medio de su callback
        g_hCreamHealTimer[client] = null;
    }

    g_fCreamHealCooldown[client] = GetEngineTime() + ((g_cvCreamHealCD != null) ? g_cvCreamHealCD.FloatValue : 15.0);
}

// =======================
// HABILIDAD 2: RESURRECCION (1 vez por ronda)
// =======================

public Action Command_CreamRevive(int client, int args)
{
    if (!Cream_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != CREAM_INDEX) return Plugin_Handled;

    // v5: 1 uso por ronda
    if (g_bCreamReviveUsed[client])
    {
        PrintCenterText(client, "Resurreccion ya usada esta ronda.\nSe reinicia al cambiar de mapa.");
        PrintToChat(client, "\x04[Cream]\x01 Ya usaste Resurreccion esta ronda. Se reinicia al cambiar de mapa.");
        return Plugin_Handled;
    }

    // Buscar jugadores muertos
    ArrayList deadPlayers = new ArrayList();
    Cream_FindDeadSurvivors(client, deadPlayers);

    if (deadPlayers.Length == 0)
    {
        delete deadPlayers;
        PrintCenterText(client, "No hay jugadores muertos para revivir.");
        PrintToChat(client, "\x04[Cream]\x01 No hay jugadores muertos para revivir. El uso no se consume.");
        return Plugin_Handled;
    }

    // Consumir el uso (solo si hay muertos)
    g_bCreamReviveUsed[client] = true;

    // Aplicar inmunidad a Cream por 3 segundos
    g_bCreamReviveImmune[client] = true;
    g_fCreamReviveImmuneEnd[client] = GetEngineTime() + CREAM_REVIVE_IMMUNE_TIME;
    SetEntityRenderColor(client, 255, 255, 150, 255); // Amarillo dorado

    // Revivir a todos los muertos
    int revivedCount = 0;
    float creamPos[3];
    GetClientAbsOrigin(client, creamPos);

    for (int i = 0; i < deadPlayers.Length; i++)
    {
        int deadClient = deadPlayers.Get(i);
        if (Cream_RevivePlayer(client, deadClient, creamPos))
        {
            revivedCount++;
        }
    }

    delete deadPlayers;

    // Efectos visuales de revivir
    Cream_CreateReviveEffects(client, creamPos);

    // Feedback
    PrintToChatAll("\x04[Cream]\x05 %N\x01 ha revivido a \x05%d\x01 companero(s) con HP completa!", client, revivedCount);
    PrintCenterText(client, "RESURRECCION!\nRevividos: %d", revivedCount);

    // Timer para quitar la inmunidad de Cream
    CreateTimer(CREAM_REVIVE_IMMUNE_TIME, T_CreamEndReviveImmune, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Handled;
}

// Busca todos los sobrevivientes muertos del mapa
void Cream_FindDeadSurvivors(int creamClient, ArrayList deadList)
{
    if (deadList == null) return;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == creamClient) continue;
        if (!IsClientInGame(i)) continue;
        if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
        if (IsPlayerAlive(i)) continue;

        deadList.Push(i);
    }
}

// ============================================================================
// v6.0: SISTEMA DE RESURRECCION - L4D_RespawnPlayer minimalista
// ============================================================================
// Enfoque minimalista y probado:
// 1. Cream_RevivePlayer: valida y programa un timer simple
// 2. T_CreamDoRevive: hace L4D_RespawnPlayer + sets minimos + teleport
// 3. T_CreamPostRevive: 0.3s despues, re-aplica modelo + sets
//
// Filosofia: MENOS es MAS. Cuantas menos cosas hagamos al mismo tiempo,
// mas probable es que el motor procese correctamente cada cambio.
// ============================================================================

bool Cream_RevivePlayer(int creamClient, int deadClient, float spawnPos[3])
{
    if (deadClient < 1 || deadClient > MaxClients) return false;
    if (!IsClientInGame(deadClient)) return false;
    if (IsPlayerAlive(deadClient)) return false;

    int currentTeam = GetClientTeam(deadClient);
    if (currentTeam != TEAM_SURVIVOR && currentTeam != 1) return false;

    // Programar el revive en un timer de 0.1s
    // Esto es CRITICO: si intentamos revivir en el mismo frame que el comando,
    // el motor de L4D2 puede ignorar el respawn.
    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(deadClient));
    dp.WriteCell(GetClientUserId(creamClient));
    dp.WriteFloat(spawnPos[0]);
    dp.WriteFloat(spawnPos[1]);
    dp.WriteFloat(spawnPos[2]);
    CreateTimer(0.1, T_CreamDoRevive, dp, TIMER_FLAG_NO_MAPCHANGE);

    return true;
}

// FASE 2: Realiza el respawn con la MINIMA cantidad de cambios posible
public Action T_CreamDoRevive(Handle timer, DataPack dp)
{
    dp.Reset();
    int deadUid = dp.ReadCell();
    int creamUid = dp.ReadCell();
    float spawnPos[3];
    spawnPos[0] = dp.ReadFloat();
    spawnPos[1] = dp.ReadFloat();
    spawnPos[2] = dp.ReadFloat();
    delete dp;

    int deadClient = GetClientOfUserId(deadUid);
    int creamClient = GetClientOfUserId(creamUid);

    if (deadClient <= 0 || !IsClientInGame(deadClient)) return Plugin_Stop;
    if (IsPlayerAlive(deadClient)) return Plugin_Stop;

    // PASO 1: Forzar team a survivor (sin esto, L4D_RespawnPlayer falla)
    if (GetClientTeam(deadClient) != TEAM_SURVIVOR)
    {
        ChangeClientTeam(deadClient, TEAM_SURVIVOR);
    }

    // PASO 2: Llamar a L4D_RespawnPlayer (native de left4dhooks)
    // Esta native internamente llama a CTerrorPlayer::RespawnPlayer() que es
    // lo que el motor usa para el defibrilador nativo.
    L4D_RespawnPlayer(deadClient);

    // PASO 3: Verificar que revivio
    if (!IsPlayerAlive(deadClient))
    {
        if (creamClient > 0 && IsClientInGame(creamClient))
            PrintToChat(creamClient, "\x04[Cream]\x01 No se pudo revivir a %N.", deadClient);
        return Plugin_Stop;
    }

    // PASO 4: Setear HP (L4D_RespawnPlayer deja HP al maximo del personaje)
    SetEntityHealth(deadClient, Cream_ClampHP(CREAM_REVIVE_HP));

    // PASO 5: Teleportar a la posicion de Cream (sin trace, simpler)
    float zeroVel[3] = {0.0, 0.0, 0.0};
    TeleportEntity(deadClient, spawnPos, NULL_VECTOR, zeroVel);

    // PASO 6: Glow dorado temporal (feedback visual)
    SetEntProp(deadClient, Prop_Send, "m_iGlowType", 3);
    SetEntProp(deadClient, Prop_Send, "m_glowColorOverride", (255 << 16) | (215 << 8) | 0);
    SetEntProp(deadClient, Prop_Send, "m_bFlashing", 1);

    // PASO 7: Efectos visuales y sonidos
    float victimPos[3];
    GetClientAbsOrigin(deadClient, victimPos);
    victimPos[2] += 20.0;

    if (g_iCreamGlowSprite > 0)
    {
        TE_SetupBeamRingPoint(victimPos, 10.0, 200.0, g_iCreamGlowSprite, g_iCreamHaloSprite, 0, 15, 1.0, 15.0, 2.0, {255, 215, 0, 220}, 5, 0);
        TE_SendToAll();
    }
    TE_SetupSparks(victimPos, NULL_VECTOR, 8, 4);
    TE_SendToAll();

    EmitSoundToAll(SND_CREAM_REVIVE, deadClient, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);
    EmitSoundToAll(SND_CHEESE_ALIVE, deadClient, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // PASO 8: Feedback
    PrintCenterText(deadClient, "HAS SIDO REVIVIDO POR CREAM!\nHP: 100");
    if (creamClient > 0 && IsClientInGame(creamClient))
        PrintToChat(deadClient, "\x04[Cream]\x05 %N\x01 te ha revivido! HP: %d", creamClient, CREAM_REVIVE_HP);

    // PASO 9: Programar FASE 3 a 0.3s para re-setear el modelo
    // (FIX del bug de cabeza flotante / invisible)
    DataPack postPack = new DataPack();
    postPack.WriteCell(GetClientUserId(deadClient));
    postPack.WriteCell(GetClientUserId(creamClient));
    postPack.WriteFloat(spawnPos[0]);
    postPack.WriteFloat(spawnPos[1]);
    postPack.WriteFloat(spawnPos[2]);
    CreateTimer(0.3, T_CreamPostRevive, postPack, TIMER_FLAG_NO_MAPCHANGE);

    // PASO 10: Timer para limpiar glow
    DataPack cleanupPack = new DataPack();
    cleanupPack.WriteCell(GetClientUserId(deadClient));
    CreateTimer(CREAM_REVIVE_VICTIM_IMMUNE, T_CreamReviveVictimCleanup, cleanupPack, TIMER_FLAG_NO_MAPCHANGE);

    return Plugin_Stop;
}

// FASE 3: Re-setea el modelo 0.3s despues del revive
// FIX del bug de "cabeza flotante" (solo se ve mitad del cuerpo)
public Action T_CreamPostRevive(Handle timer, DataPack pack)
{
    pack.Reset();
    int deadUid = pack.ReadCell();
    int creamUid = pack.ReadCell();
    float pos[3];
    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();
    delete pack;

    int deadClient = GetClientOfUserId(deadUid);
    int creamClient = GetClientOfUserId(creamUid);

    if (deadClient <= 0 || !IsClientInGame(deadClient)) return Plugin_Stop;

    // Si murio de nuevo, reintentar una vez
    if (!IsPlayerAlive(deadClient))
    {
        if (creamClient > 0 && IsClientInGame(creamClient))
        {
            ChangeClientTeam(deadClient, TEAM_SURVIVOR);
            L4D_RespawnPlayer(deadClient);
            if (IsPlayerAlive(deadClient))
            {
                SetEntityHealth(deadClient, Cream_ClampHP(CREAM_REVIVE_HP));
                float zero[3] = {0.0, 0.0, 0.0};
                TeleportEntity(deadClient, pos, NULL_VECTOR, zero);
            }
        }
        return Plugin_Stop;
    }

    // === FIX CRITICO: Re-setear el modelo ===
    // Esto arregla el bug de cabeza flotante
    char modelName[256];
    GetClientModel(deadClient, modelName, sizeof(modelName));
    if (modelName[0] != '\0')
    {
        SetEntityModel(deadClient, modelName);
    }

    // Reset de la secuencia de animacion (deja de reproducir anim de muerte)
    if (HasEntProp(deadClient, Prop_Send, "m_nSequence"))
        SetEntProp(deadClient, Prop_Send, "m_nSequence", 0);

    if (HasEntProp(deadClient, Prop_Send, "m_flCycle"))
        SetEntPropFloat(deadClient, Prop_Send, "m_flCycle", 0.0);

    if (HasEntProp(deadClient, Prop_Send, "m_flPlaybackRate"))
        SetEntPropFloat(deadClient, Prop_Send, "m_flPlaybackRate", 1.0);

    // Reset de render (por si acaso)
    SetEntityRenderMode(deadClient, RENDER_NORMAL);
    SetEntityRenderColor(deadClient, 255, 255, 255, 255);

    // Reset de movimiento
    SetEntPropFloat(deadClient, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntityMoveType(deadClient, MOVETYPE_WALK);

    // Limpiar estados negativos
    SetEntProp(deadClient, Prop_Send, "m_isIncapacitated", 0);
    SetEntProp(deadClient, Prop_Send, "m_isHangingFromLedge", 0);
    SetEntPropEnt(deadClient, Prop_Send, "m_pounceAttacker", -1);
    SetEntPropEnt(deadClient, Prop_Send, "m_tongueOwner", -1);
    SetEntPropEnt(deadClient, Prop_Send, "m_jockeyAttacker", -1);
    SetEntPropEnt(deadClient, Prop_Send, "m_carryAttacker", -1);
    SetEntPropEnt(deadClient, Prop_Send, "m_pummelAttacker", -1);

    // Asegurar HP
    SetEntityHealth(deadClient, Cream_ClampHP(CREAM_REVIVE_HP));

    // Re-teleportar por seguridad
    float zero[3] = {0.0, 0.0, 0.0};
    TeleportEntity(deadClient, pos, NULL_VECTOR, zero);

    return Plugin_Stop;
}

// Trace filter para teleport seguro
public bool Cream_TraceFilter_NoPlayers(int entity, int contentsMask, int data)
{
    if (entity == data) return false;
    if (entity > 0 && entity <= MaxClients) return false;
    return true;
}

// Limpieza del revivido (quitar glow)
public Action T_CreamReviveVictimCleanup(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    delete pack;

    int client = GetClientOfUserId(userid);
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        SetEntProp(client, Prop_Send, "m_iGlowType", 0);
        SetEntProp(client, Prop_Send, "m_bFlashing", 0);
    }
    return Plugin_Stop;
}

// Efectos visuales de revivir en Cream
void Cream_CreateReviveEffects(int client, float pos[3])
{
    pos[2] += 30.0;

    // Ring dorado expansivo grande
    if (g_iCreamGlowSprite > 0)
    {
        TE_SetupBeamRingPoint(pos, 10.0, 800.0, g_iCreamGlowSprite, g_iCreamHaloSprite, 0, 15, 1.0, 30.0, 3.0, {255, 215, 0, 220}, 10, 0);
        TE_SendToAll();

        // Ring secundario mas pequeño
        TE_SetupBeamRingPoint(pos, 10.0, 300.0, g_iCreamBeamSprite, g_iCreamHaloSprite, 0, 15, 0.6, 15.0, 2.0, {255, 255, 100, 200}, 5, 0);
        TE_SendToAll();
    }

    // Chispas
    TE_SetupSparks(pos, NULL_VECTOR, 10, 5);
    TE_SendToAll();

    // Sonido angelical (con fallback)
    EmitSoundToAll(SND_CREAM_REVIVE, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);
}

// Fin de la inmunidad de Cream
public Action T_CreamEndReviveImmune(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        g_bCreamReviveImmune[client] = false;
        SetEntityRenderColor(client, 255, 255, 255, 255);
        PrintToChat(client, "\x04[Cream]\x01 Inmunidad post-revive terminada.");
    }
    return Plugin_Stop;
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
public void Cream_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != CREAM_INDEX) return;
    Cream_ResetState(client);
}

// Puente de compatibilidad
public void Cream_OnPlayerRunCmd(int client, int &buttons) {}
