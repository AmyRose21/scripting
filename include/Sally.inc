/*
 * ======================================================
 *  [MODULO] Sally Acorn Abilities - Super Rework v5.0
 *
 *  v5.0 CHANGES - SUPER REWORK DE ESCUDOS:
 *
 *  ESCUDO DE FUEGO (rework completo tipo Sonic clasico):
 *   - Sin limite de tiempo: permanente hasta que se destruya
 *   - HP del escudo: 300 (absorbe dano en vez de Sally)
 *   - Impulso aereo (dash): CD de 4 segundos, ejecuta dash frontal en el aire
 *   - Solo 1 escudo a la vez: no puede tener fire + water simultaneos
 *   - Muestra HP restante en pantalla via PrintHintText
 *   - Al destruirse: explosion que quema + retrocede infectados + dano
 *   - Ya no lanza aura de fuego alrededor (eliminado por bug visual)
 *   - Sally ya no cambia de color (mas sutil)
 *
 *  ESCUDO DE AGUA (rework):
 *   - Duracion permanente (sin timer de fin)
 *   - Ya no absorbe dano para curar (era OP)
 *   - Regenera 1 HP cada 1.5s (pasiva, hasta max health)
 *   - Resistencia: 250 HP (absorbe dano en vez de Sally)
 *   - Bounce FIX: ya no se puede spamear presionando CTRL (cooldown de 1s)
 *   - Al rebotar: el oponente (infectado) rebota como siempre
 *   - Al destruirse: cae normalmente sin explosion
 *
 *  FIX: Otros jugadores no pueden usar habilidades de Sally
 *       (check estricto de SALLY_INDEX en todos los comandos)
 *
 *  ROBUSTEZ DE CODIGO:
 *   - Validaciones estrictas en cada funcion
 *   - SDKUnhook antes de SDKHook (anti double-hook)
 *   - Limpieza segura de handles con null checks
 *   - Clamp de HP y dano absorbido
 *   - ConVars con validacion null
 *   - Banderas explicitas de estado
 *   - Sistema de HP de escudos separado de HP de Sally
 * ======================================================
 */

#if defined _Sally_included
    #endinput
#endif
#define _Sally_included

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
#if !defined SALLY_INDEX
    #define SALLY_INDEX 4
#endif

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// v5: Defines de red protegidos (evitan warnings de redefinicion)
#if !defined FL_EDICT_ALWAYS
    #define FL_EDICT_ALWAYS 2
#endif
#if !defined EF_BONEMERGE
    #define EF_BONEMERGE 1
#endif
#if !defined EF_BONEMERGE_FASTCULL
    #define EF_BONEMERGE_FASTCULL 8
#endif

// =======================
// Constantes
// =======================
#define SALLY_SND_FIRE_START    "mobius/sfx/shield_element/Sally_Acorn_fire_shield.mp3"
#define SALLY_SND_FIRE_STOP     "mobius/sfx/shield_element/Fire_shield_stop.mp3"
#define SALLY_SND_FIRE_BOOST    "mobius/sfx/shield_element/fire_boost.mp3"
#define SALLY_SND_FIRE_BREAK    "mobius/sfx/shield_element/fire_break.mp3"
#define SALLY_SND_WATER_START   "mobius/sfx/shield_element/Sally_Acorn_water_shield.mp3"
#define SALLY_SND_WATER_STOP    "mobius/sfx/shield_element/Sally_Acorn_water_shield_over.mp3"
#define SALLY_SND_WATER_REFLECT "mobius/sfx/shield_element/Sally_Acorn_water_shield_rebote.mp3"
#define SALLY_SND_BOUNCE        "mobius/sfx/shield_element/Sally_Acorn_water_shield_rebote.mp3"
#define SALLY_SND_FALLBACK      "ambient/energy/zap1.wav"  // fallback

#define SALLY_PARTICLE_RING     "materials/sprites/laserbeam.vmt"

// v5: Configuracion del Fire Shield (rework)
#define SALLY_FIRE_MAX_HP           300.0   // HP maximo del escudo de fuego
#define SALLY_FIRE_BOOST_CD         4.0     // CD del dash aereo
#define SALLY_FIRE_BOOST_FORCE      800.0   // Fuerza del dash aereo
#define SALLY_FIRE_EXPLOSION_RADIUS 400.0   // Radio de la explosion al romperse
#define SALLY_FIRE_EXPLOSION_DMG    150.0   // Dano de la explosion al romperse
#define SALLY_FIRE_EXPLOSION_IGNITE 5.0     // Tiempo de quemado de la explosion

// v5: Configuracion del Water Shield (rework)
#define SALLY_WATER_MAX_HP          250.0   // HP maximo del escudo de agua
#define SALLY_WATER_REGEN_AMOUNT    1       // HP regenerado por tick
#define SALLY_WATER_REGEN_INTERVAL  1.5     // Intervalo de regeneracion (segundos)
#define SALLY_WATER_BOUNCE_CD       1.0     // CD entre bounces (anti spam)
#define SALLY_WATER_BOUNCE_RADIUS   300.0   // Radio de la onda expansiva del bounce

// Limites de seguridad
#define HP_MIN 1
#define HP_MAX 500

// =======================
// Variables Globales
// =======================
Handle g_hSallyThinkTimer = INVALID_HANDLE;
bool g_bSallyMapActive = false;

// Estados de escudos
public bool g_bShieldActive[MAXPLAYERS + 1];   // Fire shield
public bool g_bBubbleActive[MAXPLAYERS + 1];   // Water shield

// v5: HP de los escudos (separado de HP de Sally)
float g_fFireShieldHP[MAXPLAYERS + 1];
float g_fWaterShieldHP[MAXPLAYERS + 1];

// v5: Sistema de dash aereo del Fire Shield
float g_fFireBoostNextUse[MAXPLAYERS + 1];
bool  g_bFireBoostActive[MAXPLAYERS + 1];
float g_fFireBoostEndTime[MAXPLAYERS + 1];

// v5: Sistema de regeneracion del Water Shield
float g_fWaterNextRegenTick[MAXPLAYERS + 1];

// Cooldowns
float g_fShieldNextUse[MAXPLAYERS + 1];
float g_fShieldNextTick[MAXPLAYERS + 1];
float g_fBubbleNextUse[MAXPLAYERS + 1];

// Mecanica de Rebote (Bubble)
bool  g_bBubbleDrop[MAXPLAYERS + 1];
int   g_iBubbleCombo[MAXPLAYERS + 1];
bool  g_bWasInAir[MAXPLAYERS + 1];
float g_fBubbleLastBounceTime[MAXPLAYERS + 1];  // v5: anti spam de bounces

// Visuales
int g_iSallyBubbleProp[MAXPLAYERS + 1] = { -1, ... };
int g_iSallyFireBarrierProp[MAXPLAYERS + 1] = { -1, ... };
int g_iSallyFireParticle[MAXPLAYERS + 1] = { -1, ... };

// ConVars
ConVar g_cvSallyEnable, g_cvSallyRadius, g_cvSallyDPS, g_cvSallyTick, g_cvSallyPushForce, g_cvSallyIgniteTime, g_cvSallyDuration, g_cvSallyCooldown, g_cvSallyOnlyHuman;
ConVar g_cvSallyBubbleEnable, g_cvSallyBubbleDuration, g_cvSallyBubbleCooldown, g_cvSallyBubbleReflect, g_cvSallyBubbleHeal, g_cvSallyBubbleAbsorb;
ConVar g_cvSallyBounceBase, g_cvSallyBounceDamage;

// v5: Nuevas ConVars para rework
ConVar g_cvSallyFireMaxHP, g_cvSallyFireBoostCD, g_cvSallyFireBoostForce;
ConVar g_cvSallyFireExplosionRadius, g_cvSallyFireExplosionDmg, g_cvSallyFireExplosionIgnite;
ConVar g_cvSallyWaterMaxHP, g_cvSallyWaterRegenAmount, g_cvSallyWaterRegenInterval;
ConVar g_cvSallyWaterBounceCD;

// Macros
#define IsValidSurvivor(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1) && GetClientTeam(%1) == 2)
#define IsValidInfected(%1) (1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1) && GetClientTeam(%1) == 3)

// =======================
// Utilidades de Particulas
// =======================
void Sally_PrecacheParticle(const char[] sEffectName)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE) table = FindStringTable("ParticleEffectNames");
    if (table == INVALID_STRING_TABLE) return;
    int index = FindStringIndex(table, sEffectName);
    if (index == INVALID_STRING_INDEX) {
        bool save = LockStringTables(false); AddToStringTable(table, sEffectName); LockStringTables(save);
    }
}

// v5: Helper para validar que el cliente es Sally
bool Sally_IsSally(int client)
{
    if (!IsValidSurvivor(client)) return false;
    if (g_iPlayerCharIdx[client] != SALLY_INDEX) return false;
    return true;
}

// v5: Helper para clamp de HP
int Sally_ClampHP(int hp)
{
    if (hp < HP_MIN) return HP_MIN;
    if (hp > HP_MAX) return HP_MAX;
    return hp;
}

// =======================
// Inicializacion
// =======================

public void Sally_OnPluginStart()
{
    // Fire Shield
    g_cvSallyEnable     = CreateConVar("sally_fire_enable", "1", "Habilita el escudo de fuego.");
    g_cvSallyRadius     = CreateConVar("sally_fire_radius", "400.0", "Radio del escudo.");
    g_cvSallyDPS        = CreateConVar("sally_fire_dps", "55.0", "Dano por pulso.");
    g_cvSallyTick       = CreateConVar("sally_fire_tick", "0.5", "Intervalo de pulsos.");
    g_cvSallyPushForce  = CreateConVar("sally_fire_push", "500.0", "Fuerza de empuje del pulso.");
    g_cvSallyIgniteTime = CreateConVar("sally_fire_ignite", "2.0", "Tiempo de quemado.");
    g_cvSallyDuration   = CreateConVar("sally_fire_duration", "20.0", "Duracion del escudo (legacy, no usado en v5).");
    g_cvSallyCooldown   = CreateConVar("sally_fire_cooldown", "35.0", "Enfriamiento.");
    g_cvSallyOnlyHuman  = CreateConVar("sally_only_human", "1", "Solo humanos.");

    // v5: Fire Shield rework
    g_cvSallyFireMaxHP          = CreateConVar("sally_fire_max_hp", "300.0", "HP maximo del escudo de fuego.", _, true, 50.0, true, 1000.0);
    g_cvSallyFireBoostCD        = CreateConVar("sally_fire_boost_cd", "4.0", "CD del dash aereo del Fire Shield.", _, true, 0.5, true, 30.0);
    g_cvSallyFireBoostForce     = CreateConVar("sally_fire_boost_force", "800.0", "Fuerza del dash aereo.", _, true, 100.0, true, 5000.0);
    g_cvSallyFireExplosionRadius= CreateConVar("sally_fire_explosion_radius", "400.0", "Radio de la explosion al romperse.", _, true, 50.0, true, 2000.0);
    g_cvSallyFireExplosionDmg   = CreateConVar("sally_fire_explosion_dmg", "150.0", "Dano de la explosion al romperse.", _, true, 0.0, true, 2000.0);
    g_cvSallyFireExplosionIgnite= CreateConVar("sally_fire_explosion_ignite", "5.0", "Tiempo de quemado de la explosion.", _, true, 0.0, true, 30.0);

    // Bubble Shield
    g_cvSallyBubbleEnable   = CreateConVar("sally_bubble_enable", "1", "Habilita el escudo burbuja.");
    g_cvSallyBubbleDuration = CreateConVar("sally_bubble_duration", "15.0", "Duracion del escudo burbuja (legacy, no usado en v5).");
    g_cvSallyBubbleCooldown = CreateConVar("sally_bubble_cooldown", "20.0", "Enfriamiento.");
    g_cvSallyBubbleReflect  = CreateConVar("sally_bubble_reflect", "400.0", "Fuerza del rebote al atacante.");
    g_cvSallyBubbleHeal     = CreateConVar("sally_bubble_healfactor", "1.0", "Factor de curacion (legacy, no usado en v5).");
    g_cvSallyBubbleAbsorb   = CreateConVar("sally_bubble_absorb", "1", "Absorber dano (legacy, no usado en v5).");

    // v5: Water Shield rework
    g_cvSallyWaterMaxHP         = CreateConVar("sally_water_max_hp", "250.0", "HP maximo del escudo de agua.", _, true, 50.0, true, 1000.0);
    g_cvSallyWaterRegenAmount   = CreateConVar("sally_water_regen_amount", "1", "HP regenerado por tick.", _, true, 1.0, true, 50.0);
    g_cvSallyWaterRegenInterval = CreateConVar("sally_water_regen_interval", "1.5", "Intervalo de regeneracion (segundos).", _, true, 0.5, true, 30.0);
    g_cvSallyWaterBounceCD      = CreateConVar("sally_water_bounce_cd", "1.0", "CD entre bounces (anti spam).", _, true, 0.5, true, 10.0);

    // Bubble Bounce Mechanic
    g_cvSallyBounceBase     = CreateConVar("sally_bounce_force", "600.0", "Fuerza base del salto al rebotar.");
    g_cvSallyBounceDamage   = CreateConVar("sally_bounce_damage", "100.0", "Dano de la onda expansiva al rebotar.");

    // Hooks
    HookEvent("player_death", E_SallyPlayerReset);
    HookEvent("player_disconnect", E_SallyPlayerReset);

    AutoExecConfig(true, "Sally_Abilities");
    Sally_ResetAll(true);
}

public void Sally_OnMapStart()
{
    g_bSallyMapActive = false;

    PrecacheModel(SALLY_PARTICLE_RING, true);
    PrecacheModel("materials/sprites/glow01.vmt", true);
    PrecacheModel("models/props_unique/airport/atlas_break_ball.mdl", true);

    PrecacheSound(SALLY_SND_FIRE_START, true);
    PrecacheSound(SALLY_SND_FIRE_STOP, true);
    PrecacheSound(SALLY_SND_FIRE_BOOST, true);
    PrecacheSound(SALLY_SND_FIRE_BREAK, true);
    PrecacheSound(SALLY_SND_WATER_START, true);
    PrecacheSound(SALLY_SND_WATER_STOP, true);
    PrecacheSound(SALLY_SND_WATER_REFLECT, true);
    PrecacheSound(SALLY_SND_FALLBACK, true);

    Sally_PrecacheParticle("fire_medium_01");

    Sally_ResetAll(true);
    g_bSallyMapActive = true;

    if (g_hSallyThinkTimer != INVALID_HANDLE) { KillTimer(g_hSallyThinkTimer); g_hSallyThinkTimer = INVALID_HANDLE; }
    g_hSallyThinkTimer = CreateTimer(0.1, T_SallyThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void Sally_OnMapEnd()
{
    g_bSallyMapActive = false;
    Sally_ResetAll(true);
    if (g_hSallyThinkTimer != INVALID_HANDLE) { KillTimer(g_hSallyThinkTimer); g_hSallyThinkTimer = INVALID_HANDLE; }
}

// =======================
// Gestion de Estado y Audio
// =======================

void Sally_StopAllSounds(int client)
{
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        StopSound(client, SNDCHAN_AUTO, SALLY_SND_FIRE_START);
        StopSound(client, SNDCHAN_AUTO, SALLY_SND_WATER_START);
        StopSound(client, SNDCHAN_AUTO, SALLY_SND_FIRE_BOOST);
    }
}

void Sally_ResetState(int client, bool fullCooldown = false)
{
    if (client < 1 || client > MaxClients) return;

    if (g_bShieldActive[client]) Sally_EffectStop(client);
    if (g_bBubbleActive[client]) Sally_EffectBubbleStop(client);

    Sally_StopAllSounds(client);

    g_bShieldActive[client]   = false;
    g_bBubbleActive[client]   = false;

    g_bBubbleDrop[client]     = false;
    g_iBubbleCombo[client]    = 0;
    g_bWasInAir[client]       = false;

    // v5: Reset HP de escudos
    g_fFireShieldHP[client]   = 0.0;
    g_fWaterShieldHP[client]  = 0.0;
    g_fFireBoostNextUse[client] = 0.0;
    g_bFireBoostActive[client]  = false;
    g_fFireBoostEndTime[client] = 0.0;
    g_fWaterNextRegenTick[client] = 0.0;
    g_fBubbleLastBounceTime[client] = 0.0;

    float now = GetEngineTime();
    g_fShieldNextUse[client]  = fullCooldown ? (now + g_cvSallyCooldown.FloatValue) : 0.0;
    g_fBubbleNextUse[client]  = fullCooldown ? (now + g_cvSallyBubbleCooldown.FloatValue) : 0.0;

    DestroySallyBubbleBarrier(client);
    DestroySallyFireBarrier(client);
    DestroySallyFireAura(client);

    if (IsClientInGame(client))
    {
        SetEntityRenderMode(client, RENDER_NORMAL);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Sally_ResetAll(bool fullCooldown = false)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            Sally_ResetState(i, fullCooldown);
            SDKUnhook(i, SDKHook_OnTakeDamage, Sally_OnTakeDamage);
            SDKHook(i, SDKHook_OnTakeDamage, Sally_OnTakeDamage);
        }
    }
}

public void Sally_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;
    // Anti double-hook
    SDKUnhook(client, SDKHook_OnTakeDamage, Sally_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Sally_OnTakeDamage);
    Sally_ResetState(client, false);
}

public void E_SallyPlayerReset(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
        Sally_ResetState(client, true);
}

// =======================
// SISTEMA VISUAL BARRERAS
// =======================

void CreateSallyBubbleBarrier(int client)
{
    DestroySallyBubbleBarrier(client);
    int shield = CreateEntityByName("prop_dynamic_override");
    if (shield == -1) return;

    DispatchKeyValue(shield, "model", "models/props_unique/airport/atlas_break_ball.mdl");
    DispatchKeyValue(shield, "solid", "0");

    DispatchSpawn(shield);

    SetEntityRenderMode(shield, RENDER_TRANSCOLOR);
    SetEntityRenderColor(shield, 0, 255, 255, 120);

    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] -= 120.0;
    TeleportEntity(shield, pos, NULL_VECTOR, NULL_VECTOR);

    SetVariantString("!activator");
    AcceptEntityInput(shield, "SetParent", client, shield);

    SetEntProp(shield, Prop_Send, "m_fEffects", GetEntProp(shield, Prop_Send, "m_fEffects") | EF_BONEMERGE | EF_BONEMERGE_FASTCULL);
    SetEdictFlags(shield, FL_EDICT_ALWAYS);

    g_iSallyBubbleProp[client] = EntIndexToEntRef(shield);
}

void DestroySallyBubbleBarrier(int client)
{
    if (client < 1 || client > MaxClients) return;
    int ent = EntRefToEntIndex(g_iSallyBubbleProp[client]);
    if (ent > 0 && IsValidEntity(ent)) AcceptEntityInput(ent, "Kill");
    g_iSallyBubbleProp[client] = -1;
}

void CreateSallyFireBarrier(int client)
{
    DestroySallyFireBarrier(client);
    int shield = CreateEntityByName("prop_dynamic_override");
    if (shield == -1) return;

    DispatchKeyValue(shield, "model", "models/props_unique/airport/atlas_break_ball.mdl");
    DispatchKeyValue(shield, "solid", "0");

    DispatchSpawn(shield);

    SetEntityRenderMode(shield, RENDER_TRANSCOLOR);
    SetEntityRenderColor(shield, 255, 100, 30, 120);

    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] -= 120.0;
    TeleportEntity(shield, pos, NULL_VECTOR, NULL_VECTOR);

    SetVariantString("!activator");
    AcceptEntityInput(shield, "SetParent", client, shield);

    SetEntProp(shield, Prop_Send, "m_fEffects", GetEntProp(shield, Prop_Send, "m_fEffects") | EF_BONEMERGE | EF_BONEMERGE_FASTCULL);
    SetEdictFlags(shield, FL_EDICT_ALWAYS);

    g_iSallyFireBarrierProp[client] = EntIndexToEntRef(shield);
}

void DestroySallyFireBarrier(int client)
{
    if (client < 1 || client > MaxClients) return;
    int ent = EntRefToEntIndex(g_iSallyFireBarrierProp[client]);
    if (ent > 0 && IsValidEntity(ent)) AcceptEntityInput(ent, "Kill");
    g_iSallyFireBarrierProp[client] = -1;
}

// v5: Aura de fuego eliminada (era bug visual)
void CreateSallyFireAura(int client)
{
    // v5: No hacer nada - el aura de fuego causaba problemas visuales
    // El Fire Shield ahora solo tiene la barrera roja + particulas esporadicas
}

void DestroySallyFireAura(int client)
{
    if (client < 1 || client > MaxClients) return;
    int ent = EntRefToEntIndex(g_iSallyFireParticle[client]);
    if (ent > 0 && IsValidEntity(ent)) AcceptEntityInput(ent, "Kill");
    g_iSallyFireParticle[client] = -1;
}

void Sally_BubblePlop(float pos[3])
{
    TE_SetupEnergySplash(pos, NULL_VECTOR, true);
    TE_SendToAll();

    int sprite = PrecacheModel(SALLY_PARTICLE_RING);
    TE_SetupBeamRingPoint(pos, 10.0, 250.0, sprite, 0, 0, 0, 0.5, 10.0, 0.0, {0, 255, 255, 200}, 0, 0);
    TE_SendToAll();
}

// =======================
// Logica de Input (OnPlayerRunCmd)
// ======================================================================

public void Sally_OnPlayerRunCmd(int client, int &buttons)
{
    // v5 FIX: Validacion estricta de que es Sally
    if (!Sally_IsSally(client)) return;

    // v5: Fire Shield - Dash aereo (presionar DUCK/CTRL en el aire)
    if (g_bShieldActive[client])
    {
        int flags = GetEntityFlags(client);
        bool onGround = (flags & FL_ONGROUND) != 0;

        // Dash aereo solo si esta en el aire y presiona DUCK
        if (!onGround && (buttons & IN_DUCK) && !g_bFireBoostActive[client])
        {
            float now = GetEngineTime();
            if (now >= g_fFireBoostNextUse[client])
            {
                Sally_PerformFireBoost(client);
            }
        }

        // Reset del flag de boost activo cuando termina
        if (g_bFireBoostActive[client] && GetEngineTime() > g_fFireBoostEndTime[client])
        {
            g_bFireBoostActive[client] = false;
        }
    }

    // v5: Water Shield - Bounce (presionar DUCK/CTRL en el aire)
    if (g_bBubbleActive[client])
    {
        int flags = GetEntityFlags(client);
        bool onGround = (flags & FL_ONGROUND) != 0;

        if (!onGround)
        {
            // v5 FIX: Anti spam de bounces (cooldown de 1s)
            if ((buttons & IN_DUCK) && !g_bBubbleDrop[client])
            {
                float now = GetEngineTime();
                if (now - g_fBubbleLastBounceTime[client] >= g_cvSallyWaterBounceCD.FloatValue)
                {
                    g_bBubbleDrop[client] = true;
                    float vel[3];
                    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
                    if (vel[2] > -900.0) vel[2] = -900.0;
                    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
                    PrintCenterText(client, "Caida Sonica de Burbuja!");
                }
            }
            g_bWasInAir[client] = true;
        }
        else
        {
            if (g_bWasInAir[client])
            {
                if (g_bBubbleDrop[client])
                {
                    Sally_PerformBounce(client);
                    g_fBubbleLastBounceTime[client] = GetEngineTime();
                }
                else
                {
                    if (g_iBubbleCombo[client] > 0)
                    {
                        g_iBubbleCombo[client] = 0;
                        PrintCenterText(client, "Combo Reiniciado.");
                    }
                }
            }
            g_bWasInAir[client] = false;
            g_bBubbleDrop[client] = false;
        }
    }
}

public void Sally_PreThink(int client) {}

// v5: Dash aereo del Fire Shield (tipo Sonic clasico)
void Sally_PerformFireBoost(int client)
{
    if (!Sally_IsSally(client)) return;
    if (!g_bShieldActive[client]) return;

    float now = GetEngineTime();
    g_fFireBoostNextUse[client] = now + g_cvSallyFireBoostCD.FloatValue;
    g_bFireBoostActive[client] = true;
    g_fFireBoostEndTime[client] = now + 0.3; // duracion del boost visual

    // Impulso frontal en la direccion que mira Sally
    float ang[3], fwd[3], vel[3];
    GetClientEyeAngles(client, ang);
    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);

    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[0] += fwd[0] * g_cvSallyFireBoostForce.FloatValue;
    vel[1] += fwd[1] * g_cvSallyFireBoostForce.FloatValue;
    vel[2] += 100.0; // pequeno impulso vertical

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    // Efectos visuales
    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 20.0;

    int sprite = PrecacheModel(SALLY_PARTICLE_RING);
    TE_SetupBeamRingPoint(pos, 10.0, 200.0, sprite, 0, 0, 0, 0.3, 5.0, 1.0, {255, 100, 30, 200}, 0, 0);
    TE_SendToAll();

    TE_SetupSparks(pos, fwd, 5, 3);
    TE_SendToAll();

    // Sonido (con fallback)
    EmitSoundToAll(SALLY_SND_FIRE_BOOST, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    EmitSoundToAll(SALLY_SND_FALLBACK, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5);

    PrintCenterText(client, "FIRE DASH!");
    PrintHintText(client, "Fire Shield HP: %.0f / %.0f\nDash CD: %.1fs",
        g_fFireShieldHP[client], g_cvSallyFireMaxHP.FloatValue, g_cvSallyFireBoostCD.FloatValue);
}

void Sally_PerformBounce(int client)
{
    if (!Sally_IsSally(client)) return;

    int combo = g_iBubbleCombo[client];
    if (combo > 7) combo = 7;

    float baseForce = g_cvSallyBounceBase.FloatValue;
    float finalForce = baseForce * (1.0 + (float(combo) * 0.1));

    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[2] = finalForce;

    float pos[3]; GetClientAbsOrigin(client, pos);
    pos[2] += 15.0;

    TeleportEntity(client, pos, NULL_VECTOR, vel);

    g_iBubbleCombo[client]++;
    EmitSoundToAll(SALLY_SND_BOUNCE, client);

    Sally_BubblePlop(pos);

    float damage = g_cvSallyBounceDamage.FloatValue + (combo * 10.0);

    int sprite = PrecacheModel(SALLY_PARTICLE_RING);
    TE_SetupBeamRingPoint(pos, 10.0, 300.0, sprite, 0, 0, 0, 0.5, 10.0, 0.0, {0, 255, 255, 200}, 0, 0);
    TE_SendToAll();

    float radius = SALLY_WATER_BOUNCE_RADIUS;

    // Infectados especiales
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidInfected(i))
        {
            float tPos[3]; GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(pos, tPos) <= radius)
            {
                SDKHooks_TakeDamage(i, client, client, damage, DMG_SHOCK);
                L4D_StaggerPlayer(i, client, pos);

                float push[3];
                MakeVectorFromPoints(pos, tPos, push);
                NormalizeVector(push, push);
                ScaleVector(push, 500.0);
                push[2] += 200.0;
                TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }

    // Infectados comunes
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(pos, zPos) <= radius)
            {
                SDKHooks_TakeDamage(entity, client, client, damage, DMG_BLAST);
                float push[3];
                MakeVectorFromPoints(pos, zPos, push);
                NormalizeVector(push, push);
                ScaleVector(push, 600.0);
                push[2] = 300.0;
                TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }

    PrintCenterText(client, "BOING! (Combo x%d)", g_iBubbleCombo[client]);
}

// =======================
// Think Timer
// =======================

public Action T_SallyThink(Handle timer)
{
    if (!g_bSallyMapActive) return Plugin_Continue;
    if (g_cvSallyEnable == null && g_cvSallyBubbleEnable == null) return Plugin_Continue;

    float now = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2)
        {
            if (i <= MaxClients && g_bShieldActive[i]) Sally_StopShield(i);
            if (i <= MaxClients && g_bBubbleActive[i]) Sally_StopBubble(i);
            continue;
        }

        // v5: Fire Shield - logica permanente (sin timer de fin)
        if (g_bShieldActive[i])
        {
            float pos[3]; GetClientAbsOrigin(i, pos);
            pos[0] += GetRandomFloat(-20.0, 20.0);
            pos[1] += GetRandomFloat(-20.0, 20.0);
            pos[2] += GetRandomFloat(10.0, 50.0);
            TE_SetupSparks(pos, view_as<float>({0.0, 0.0, 50.0}), 2, 1);
            TE_SendToAll();

            // Pulso de dano periodico (cada tick)
            if (now >= g_fShieldNextTick[i])
            {
                // Actualizar tiempo del proximo tick
                g_fShieldNextTick[i] = now + ((g_cvSallyTick != null) ? g_cvSallyTick.FloatValue : 0.5);
                Sally_ApplyShieldPulse(i);
            }

            // Mostrar HP en pantalla cada 0.5s
            if (now >= g_fFireBoostEndTime[i] + 0.5)
            {
                PrintHintText(i, "Fire Shield HP: %.0f / %.0f",
                    g_fFireShieldHP[i], g_cvSallyFireMaxHP.FloatValue);
            }
        }

        // v5: Water Shield - logica permanente + regeneracion
        if (g_bBubbleActive[i])
        {
            // v5: Regeneracion de HP cada 1.5s
            if (now >= g_fWaterNextRegenTick[i])
            {
                g_fWaterNextRegenTick[i] = now + g_cvSallyWaterRegenInterval.FloatValue;
                Sally_WaterRegenTick(i);
            }

            // Mostrar HP en pantalla cada 0.5s
            if (now >= g_fWaterNextRegenTick[i] - 0.5)
            {
                PrintHintText(i, "Water Shield HP: %.0f / %.0f",
                    g_fWaterShieldHP[i], g_cvSallyWaterMaxHP.FloatValue);
            }

            // Efectos visuales esporadicos
            if (now >= g_fBubbleLastBounceTime[i] + 0.2)
            {
                float bPos[3]; GetClientAbsOrigin(i, bPos);
                bPos[0] += GetRandomFloat(-40.0, 40.0);
                bPos[1] += GetRandomFloat(-40.0, 40.0);
                bPos[2] += GetRandomFloat(10.0, 80.0);

                int sprite = PrecacheModel("materials/sprites/glow01.vmt");
                TE_SetupGlowSprite(bPos, sprite, 0.5, 0.3, 80);
                TE_SendToAll();
            }
        }
    }
    return Plugin_Continue;
}

// v5: Regeneracion de HP del Water Shield
void Sally_WaterRegenTick(int client)
{
    if (!Sally_IsSally(client)) return;
    if (!g_bBubbleActive[client]) return;

    int hp = GetClientHealth(client);
    int maxHp = GetEntProp(client, Prop_Data, "m_iMaxHealth");
    if (maxHp <= 0) maxHp = 100;

    if (hp < maxHp)
    {
        int regenAmount = g_cvSallyWaterRegenAmount.IntValue;
        int newHp = hp + regenAmount;
        if (newHp > maxHp) newHp = maxHp;
        SetEntityHealth(client, Sally_ClampHP(newHp));
    }
}

// =======================
// Logica Escudo Fuego (v5 rework)
// =======================

public Action Cmd_ToggleShield(int client, int args)
{
    // v5 FIX: Validacion estricta de que es Sally
    if (!Sally_IsSally(client)) return Plugin_Handled;
    if (g_cvSallyEnable == null || !g_cvSallyEnable.BoolValue) return Plugin_Handled;
    if (g_cvSallyOnlyHuman != null && g_cvSallyOnlyHuman.BoolValue && IsFakeClient(client)) return Plugin_Handled;

    // Si ya tiene el escudo activo, desactivarlo
    if (g_bShieldActive[client])
    {
        Sally_StopShield(client, false); // false = no explosion, solo apagar
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fShieldNextUse[client])
    {
        PrintToChat(client, "\x04[Sally]\x01 Enfriamiento: \x05%.1fs\x01", g_fShieldNextUse[client] - now);
        return Plugin_Handled;
    }

    // v5: No se pueden tener 2 escudos a la vez
    if (g_bBubbleActive[client])
    {
        PrintToChat(client, "\x04[Sally]\x01 Ya tienes el escudo de agua activo. Desactivalo primero.");
        return Plugin_Handled;
    }

    // Activar Fire Shield
    g_bShieldActive[client] = true;

    // v5: HP del escudo = maximo configurado
    g_fFireShieldHP[client] = g_cvSallyFireMaxHP.FloatValue;
    g_fShieldNextTick[client] = 0.0;
    g_fFireBoostNextUse[client] = 0.0;
    g_bFireBoostActive[client] = false;

    // v5: Ya no cambia el color de Sally (mas sutil)
    CreateSallyFireBarrier(client);
    Sally_EffectStart(client);
    PrintToChat(client, "\x04[Sally]\x05 Escudo de Fuego activado!\x01 HP: %.0f | Dash: presiona CTRL en el aire",
        g_fFireShieldHP[client]);
    return Plugin_Handled;
}

// v5: Detener el Fire Shield (puede ser con explosion o sin)
// withExplosion = false por defecto (para llamadas con 1 solo argumento)
void Sally_StopShield(int client, bool withExplosion = false)
{
    if (!g_bShieldActive[client]) return;
    g_bShieldActive[client] = false;
    g_fShieldNextUse[client] = GetEngineTime() + g_cvSallyCooldown.FloatValue;

    DestroySallyFireBarrier(client);
    DestroySallyFireAura(client);
    Sally_EffectStop(client);
    Sally_StopAllSounds(client);

    if (IsClientInGame(client))
    {
        SetEntityRenderMode(client, RENDER_NORMAL);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }

    // v5: Explosion al romperse (solo si withExplosion = true)
    if (withExplosion && IsClientInGame(client) && IsPlayerAlive(client))
    {
        Sally_FireShieldExplosion(client);
        PrintToChat(client, "\x04[Sally]\x01 Escudo destruido! Explosion liberada.");
    }
    else
    {
        PrintToChat(client, "\x04[Sally]\x01 Escudo de Fuego desactivado.");
    }
}

// v5: Explosion del Fire Shield al romperse
void Sally_FireShieldExplosion(int client)
{
    if (!Sally_IsSally(client)) return;

    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 20.0;

    float radius = g_cvSallyFireExplosionRadius.FloatValue;
    float damage = g_cvSallyFireExplosionDmg.FloatValue;
    float igniteTime = g_cvSallyFireExplosionIgnite.FloatValue;

    // Efectos visuales
    int sprite = PrecacheModel(SALLY_PARTICLE_RING);
    TE_SetupBeamRingPoint(pos, 10.0, radius, sprite, 0, 0, 0, 0.5, 15.0, 2.0, {255, 100, 30, 255}, 0, 0);
    TE_SendToAll();

    TE_SetupSparks(pos, NULL_VECTOR, 20, 10);
    TE_SendToAll();

    // Sonido de explosion
    EmitSoundToAll(SALLY_SND_FIRE_BREAK, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);
    EmitSoundToAll(SALLY_SND_FALLBACK, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.8);

    // Dano + quemado + retroceso a infectados especiales
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidInfected(i)) continue;

        float tPos[3]; GetClientAbsOrigin(i, tPos);
        if (GetVectorDistance(pos, tPos) <= radius)
        {
            SDKHooks_TakeDamage(i, client, client, damage, DMG_BURN);
            IgniteEntity(i, igniteTime);
            L4D_StaggerPlayer(i, client, pos);

            float push[3];
            MakeVectorFromPoints(pos, tPos, push);
            NormalizeVector(push, push);
            ScaleVector(push, 800.0);
            push[2] += 300.0;
            TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
        }
    }

    // Dano + quemado a infectados comunes
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(pos, zPos) <= radius)
        {
            SDKHooks_TakeDamage(entity, client, client, damage * 2.0, DMG_BURN);
            IgniteEntity(entity, igniteTime);

            float push[3];
            MakeVectorFromPoints(pos, zPos, push);
            NormalizeVector(push, push);
            ScaleVector(push, 1000.0);
            push[2] = 400.0;
            TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
}

void Sally_ApplyShieldPulse(int owner)
{
    if (!Sally_IsSally(owner)) return;

    float origin[3]; GetClientAbsOrigin(owner, origin);
    float radius = g_cvSallyRadius.FloatValue;
    float push = g_cvSallyPushForce.FloatValue;
    float ignite = g_cvSallyIgniteTime.FloatValue;
    float damage = g_cvSallyDPS.FloatValue * g_cvSallyTick.FloatValue;

    int sprite = PrecacheModel(SALLY_PARTICLE_RING);
    TE_SetupBeamRingPoint(origin, 10.0, radius, sprite, 0, 0, 0, 0.2, 4.0, 2.0, {255, 100, 30, 100}, 0, 0);
    TE_SendToAll();

    TE_SetupSparks(origin, NULL_VECTOR, 10, 5);
    TE_SendToAll();

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity)) Sally_ProcessEntity(owner, entity, origin, radius * radius, damage, push, ignite);
    }
    for (int j = 1; j <= MaxClients; j++)
    {
        if (IsValidInfected(j)) Sally_ProcessEntity(owner, j, origin, radius * radius, damage, push, ignite);
    }
}

void Sally_ProcessEntity(int owner, int ent, const float origin[3], float radiusSq, float damage, float push, float ignite)
{
    if (!IsValidEntity(ent)) return;

    float pos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
    if (GetVectorDistance(origin, pos, true) > radiusSq) return;

    float dir[3];
    MakeVectorFromPoints(origin, pos, dir);
    NormalizeVector(dir, dir);
    ScaleVector(dir, push);
    dir[2] += 200.0;

    TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, dir);

    SDKHooks_TakeDamage(ent, owner, owner, damage, DMG_BURN);
    IgniteEntity(ent, ignite);
}

// =======================
// Logica Escudo Burbuja (v5 rework)
// =======================

public Action Cmd_ToggleBubble(int client, int args)
{
    // v5 FIX: Validacion estricta de que es Sally
    if (!Sally_IsSally(client)) return Plugin_Handled;
    if (g_cvSallyBubbleEnable == null || !g_cvSallyBubbleEnable.BoolValue) return Plugin_Handled;
    if (g_cvSallyOnlyHuman != null && g_cvSallyOnlyHuman.BoolValue && IsFakeClient(client)) return Plugin_Handled;

    // Si ya tiene el escudo activo, desactivarlo
    if (g_bBubbleActive[client])
    {
        Sally_StopBubble(client);
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fBubbleNextUse[client])
    {
        PrintToChat(client, "\x04[Sally]\x01 Enfriamiento: \x05%.1fs\x01", g_fBubbleNextUse[client] - now);
        return Plugin_Handled;
    }

    // v5: No se pueden tener 2 escudos a la vez
    if (g_bShieldActive[client])
    {
        PrintToChat(client, "\x04[Sally]\x01 Ya tienes el escudo de fuego activo. Desactivalo primero.");
        return Plugin_Handled;
    }

    // Activar Water Shield
    g_bBubbleActive[client] = true;

    // v5: HP del escudo = maximo configurado
    g_fWaterShieldHP[client] = g_cvSallyWaterMaxHP.FloatValue;
    g_fWaterNextRegenTick[client] = now + g_cvSallyWaterRegenInterval.FloatValue;

    g_iBubbleCombo[client] = 0;
    g_bBubbleDrop[client] = false;
    g_fBubbleLastBounceTime[client] = 0.0;

    CreateSallyBubbleBarrier(client);
    Sally_EffectBubbleStart(client);
    PrintToChat(client, "\x04[Sally]\x05 Escudo de Agua activado!\x01 HP: %.0f | Regen: +%d HP/%.1fs\nPresiona CTRL en el aire para rebotar",
        g_fWaterShieldHP[client], g_cvSallyWaterRegenAmount.IntValue, g_cvSallyWaterRegenInterval.FloatValue);
    return Plugin_Handled;
}

void Sally_StopBubble(int client)
{
    if (!g_bBubbleActive[client]) return;
    g_bBubbleActive[client] = false;
    g_fBubbleNextUse[client] = GetEngineTime() + g_cvSallyBubbleCooldown.FloatValue;

    Sally_EffectBubbleStop(client);
    Sally_StopAllSounds(client);

    float pos[3]; GetClientAbsOrigin(client, pos);
    pos[2] += 20.0;
    Sally_BubblePlop(pos);

    DestroySallyBubbleBarrier(client);

    if (IsClientInGame(client))
    {
        SetEntityRenderMode(client, RENDER_NORMAL);
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
    PrintToChat(client, "\x04[Sally]\x01 Escudo de Agua desactivado.");
}

// =======================
// Gestion de Dano (v5: escudos absorben dano)
// =======================

public Action Sally_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (victim < 1 || victim > MaxClients) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != SALLY_INDEX) return Plugin_Continue;
    if (!IsValidSurvivor(victim)) return Plugin_Continue;

    // Inmunidad a dano toxico/acido/radiacion (pasiva de Sally)
    if ((damagetype & DMG_ACID) || (damagetype & DMG_POISON) || (damagetype & DMG_RADIATION))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // v5: Fire Shield absorbe dano
    if (g_bShieldActive[victim])
    {
        // El escudo absorbe todo el dano
        g_fFireShieldHP[victim] -= damage;
        damage = 0.0; // Sally no recibe dano

        // Efecto visual de absorcion
        float vPos[3]; GetClientAbsOrigin(victim, vPos);
        vPos[2] += 20.0;
        TE_SetupSparks(vPos, NULL_VECTOR, 3, 2);
        TE_SendToAll();

        // Mostrar HP restante
        PrintHintText(victim, "Fire Shield HP: %.0f / %.0f",
            g_fFireShieldHP[victim] > 0 ? g_fFireShieldHP[victim] : 0.0,
            g_cvSallyFireMaxHP.FloatValue);

        // Si el escudo se rompio, explosion!
        if (g_fFireShieldHP[victim] <= 0.0)
        {
            Sally_StopShield(victim, true); // true = con explosion
        }

        return Plugin_Handled;
    }

    // v5: Water Shield absorbe dano + rebate al atacante
    if (g_bBubbleActive[victim])
    {
        // El escudo absorbe todo el dano
        g_fWaterShieldHP[victim] -= damage;
        damage = 0.0; // Sally no recibe dano

        // Efecto visual de absorcion
        float vPos[3]; GetClientAbsOrigin(victim, vPos);
        vPos[2] += 20.0;
        TE_SetupSparks(vPos, NULL_VECTOR, 3, 2);
        TE_SendToAll();

        // Rebote del atacante (igual que antes)
        if (IsValidInfected(attacker))
        {
            float push = g_cvSallyBubbleReflect.FloatValue;
            Sally_ProcessEntity(victim, attacker, vPos, 99999.9, 0.0, push, 0.0);
            EmitSoundToAll(SALLY_SND_WATER_REFLECT, victim);

            SetEntPropEnt(victim, Prop_Send, "m_pounceAttacker", -1);
            SetEntPropEnt(victim, Prop_Send, "m_jockeyAttacker", -1);
            SetEntPropEnt(victim, Prop_Send, "m_carryAttacker", -1);
            SetEntPropEnt(victim, Prop_Send, "m_pummelAttacker", -1);
            SetEntPropEnt(victim, Prop_Send, "m_tongueOwner", -1);

            L4D_StaggerPlayer(attacker, victim, vPos);
        }

        // Mostrar HP restante
        PrintHintText(victim, "Water Shield HP: %.0f / %.0f",
            g_fWaterShieldHP[victim] > 0 ? g_fWaterShieldHP[victim] : 0.0,
            g_cvSallyWaterMaxHP.FloatValue);

        // Si el escudo se rompio, caer
        if (g_fWaterShieldHP[victim] <= 0.0)
        {
            Sally_StopBubble(victim);
        }

        return Plugin_Handled;
    }

    return Plugin_Continue;
}

bool Sally_IsBubbleActive(int client)
{
    if (client < 1 || client > MaxClients) return false;
    return g_bBubbleActive[client];
}

// =======================
// Utilidades de Chat y Audio
// =======================

void Sally_EffectStart(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    EmitSoundToAll(SALLY_SND_FIRE_START, client);
}

void Sally_EffectStop(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    EmitSoundToAll(SALLY_SND_FIRE_STOP, client);
}

void Sally_EffectBubbleStart(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    EmitSoundToAll(SALLY_SND_WATER_START, client);
}

void Sally_EffectBubbleStop(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    EmitSoundToAll(SALLY_SND_WATER_STOP, client);
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
public void Sally_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != SALLY_INDEX) return;
    Sally_ResetState(client, false);
}

// Puente de compatibilidad
public void Sally_OnPlayerRunCmd_Generic(int client, int &buttons) {}
