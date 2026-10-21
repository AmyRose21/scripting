/*
 * =====================================================================
 *  [MODULO] KOLOSSOS — El Coloso de OutComeMemories v1.0-OM
 *  PERSONAJE 14 DEL SUITE (KOLOSSOS_INDEX 13)
 *
 *  Port directo de "Lua de OM de Gmod/autorun/include/killer/
 *  noodles_om_pills_killer_kolossos.lua" (by noodles) — el killer
 *  colosal del pack OM pills, traido a L4D2 como personaje jugable.
 *
 *  SIN CUERPO CST (no existe un survivor model de Kolossos): el
 *  AVATAR ESPEJO (patron Blaze v2.11 / sonic.inc v6.30 — doble copia
 *  R/L + modo TP + pulso de pausa + FSM de animacion) se monta sobre
 *  el survivor que el jugador tenga puesto en ese momento. El modelo
 *  vive en kolossos_model (convar); sin el archivo el personaje
 *  funciona igual, solo sin espejo (g_bKolModelOK, patron Blaze).
 *
 *  KIT GMod (registro oficial om_survivors_register_noodles_kolossos):
 *   [Z] CHARGE    — windup 0.8s (suspiro -> rumble -> rugido) y
 *                   avalancha a velocidad de embestida que EMPALA a
 *                   todo lo que toca (esfera 90u): dano + extension
 *                   +3.75s por victima nueva; al terminar, las
 *                   victimas vivas salen VOLANDAS. Pared = tope seco
 *                   (Kol wall bump). CD 22s.
 *                   GMod: OUTCOMEMEMORIES_N_Kolosssos_Charge* (22/7/25/3.75).
 *                   Receta de movimiento: la del Destructive Charge de
 *                   Metal v5.0 — slot del stack (m_flMaxspeed) +
 *                   auto-forward del RunCmd (vel[0] saturado) + DEBRIS.
 *   [X] GRAB      — lunge 0.6s; el primer infectado de la esfera 90u
 *                   queda AGARRADO en vilo (max 10s): Z = puo (15),
 *                   3 puos y sale volando (kol sting and pull out);
 *                   X de nuevo lo suelta (kolossos_grab_cancel 0 = off,
 *                   default GMod). CD 25s (2s si la victima muere sola).
 *                   GMod: GrabCooldown 25 / PunchesLeft 3 / slamDamage 15.
 *   [C] INDICATOR — 5s de "peek": todos los infectados vivos en radio
 *                   llevan un glow rojo sobre la cabeza + ping cada 1s
 *                   (susurro al activar). CD 14s.
 *                   GMod: IndicatorDuration 5 / Cooldown 14 (wallhack).
 *   [B] BLOCK     — 3.5s inmune al dano de infectados (movimiento
 *                   bloqueado); el primer golpe que absorbe CONSUME el
 *                   bloqueo y dispara el CONTRAGOLPE: gira hacia el
 *                   atacante y le devuelve una ROCA en arco (granito
 *                   3x, 35 dano al tocar). CD 14s.
 *                   GMod: BlockDuration 3.5 / BlockProjectile + roca
 *                   rockgranite03b.mdl scale 3 del counter.
 *
 *  PASIVAS: vida max 670 (kolossos_health, receta Metal_ApplyMaxHealth,
 *  vuelta a 100 al dejar el personaje) + resistencia de dano
 *  (kolossos_resistance 100 = neutro; 50 = mitad de dano recibido).
 *  NO portado a v1: el M1 melee de puos (L4D2 pelea con armas, el kit
 *  vive en las 4 teclas) y el Climb de paredes (posible v1.1).
 *
 *  SONIDOS: sound/om/kolossos/ (27 wavs del killer) copiados del addon GMod. Cada uno se chequea con FileExists: sin el archivo
 *  cae al fallback nativo HL2/L4D2 (patron g_bMetalSnd* de Metal.inc)
 *  — CERO dependencia dura.
 *
 *  INTEGRACION (manager 3.77.94): MAX_CHARS 14, KOLOSSOS_INDEX 13,
 *  fila de binds Z/X/C + B (precedente Rouge), dispatcher de las 4
 *  habilidades, OnPlayerRunCmd (auto-forward del charge),
 *  CleanupCharModuleState y banner sm_sjsver. ESTE modulo se auto-
 *  engancha sus eventos (player_spawn/player_death/round_start) —
 *  cero cableado extra en el manager.
 *
 *  CERO codigo FX de otros modulos tocado. Cero sistemas de bots.
 * =====================================================================
 */

#define KOLOSSOS_INC_VERSION "1.0-OM"

// ------------------------- CONSTANTES KIT ---------------------------
// (defaults = registro oficial GMod om_survivors_register_noodles_kolossos;
//  velocidad L4D2 calibrada al Destructive Charge de Metal v5.0: 750)
#define KOL_SND_LEVEL              87      // GMod: soundLevel 87 del killer
#define KOL_CHG_WINDUP_T          0.8     // chargestart_Kolossos = +0.8s (duracion del windup)
#define KOL_CHG_WINDUP_SIGH        0.15    // kol sigh i think.wav
#define KOL_CHG_WINDUP_RUMBLE      0.35    // kol charge start ground rumble
#define KOL_CHG_WINDUP_ROAR        0.75    // KolossosChargeRoar.wav
#define KOL_CHG_LAUNCH_MIN         300.0   // impulso de arranque (min)
#define KOL_CHG_FOV                105     // camara abierta (receta Metal)
#define KOL_CHG_COLGROUP           2       // DEBRIS durante la avalancha
#define KOL_CHG_STUCK_TIME         0.6     // watchdog: <80 u/s este tiempo = tope
#define KOL_CHG_STUCK_MINVEL       80.0
#define KOL_CHG_FLING_FWD          500.0   // lanzamiento de victimas al final
#define KOL_CHG_FLING_UP           300.0
#define KOL_GRAB_HOLD_DIST         55.0    // la victima viaja a 55u delante
#define KOL_GRAB_HOLD_Z            12.0
#define KOL_GRAB_FLING_FWD         500.0
#define KOL_GRAB_FLING_UP          300.0
#define KOL_IND_PING_EVERY         1.0     // heartbeat del indicator
#define KOL_ROCK_LIFETIME          3.0     // la roca muere sola si no toca nada
#define KOL_ROCK_ARC_TIME          0.5     // GMod: travelTime 0.5
#define KOL_ROCK_ARC_PEAK          150.0   // GMod: peakHeight 150
#define KOL_ROCK_TOUCH_RADIUS      100.0   // AoE del impacto de la roca
#define KOL_DASH_VEL_INJECT        900.0   // vel[0] saturado (receta Metal)
#define KOL_MAXENT                 2048    // sprites del indicator (por indice)

// ------------------------- ESTADOS ----------------------------------
#define KOL_CHG_IDLE               0
#define KOL_CHG_WINDUP             1
#define KOL_CHG_DASH               2

// FSM de animacion del avatar (nombres de secuencia del Kolossos.mdl
// GMod: idle/run/walk/jump/fall — el registro anims del killer Lua)
#define KOL_ST_IDLE                0
#define KOL_ST_WALK                1
#define KOL_ST_RUN                 2
#define KOL_ST_JUMP                3
#define KOL_ST_FALL                4
#define KOL_ST_COUNT               5

// ------------------------- CONVARS ----------------------------------
ConVar g_cvKolEnabled;
ConVar g_cvKolModel;
ConVar g_cvKolAvatar;
ConVar g_cvKolHealth;
ConVar g_cvKolResist;
ConVar g_cvKolChgSpeed;
ConVar g_cvKolChgDur;
ConVar g_cvKolChgMaxDur;
ConVar g_cvKolChgDmg;
ConVar g_cvKolChgAdd;
ConVar g_cvKolChgCd;
ConVar g_cvKolChgRadius;
ConVar g_cvKolGrabCd;
ConVar g_cvKolGrabWindow;
ConVar g_cvKolGrabHold;
ConVar g_cvKolGrabPunches;
ConVar g_cvKolGrabPunchDmg;
ConVar g_cvKolGrabCancel;
ConVar g_cvKolIndCd;
ConVar g_cvKolIndDur;
ConVar g_cvKolIndRadius;
ConVar g_cvKolBlockCd;
ConVar g_cvKolBlockDur;
ConVar g_cvKolRockDmg;
ConVar g_cvKolRockScale;

// ------------------------- ESTADO POR JUGADOR -----------------------
int    g_iKolChargeState[MAXPLAYERS + 1];   // KOL_CHG_*
float  g_fKolChargeEnd[MAXPLAYERS + 1];     // fin del DASH (extensible)
float  g_fKolChargeCdUntil[MAXPLAYERS + 1];
float  g_fKolWindupStart[MAXPLAYERS + 1];
float  g_fKolStuckSince[MAXPLAYERS + 1];
int    g_iKolSavedColGroup[MAXPLAYERS + 1]; // DEBRIS enter/exit
ArrayList g_hKolHitList[MAXPLAYERS + 1];    // EntRefs empalados (fling final)

int    g_iKolGrabVictim[MAXPLAYERS + 1];    // EntRef del agarrado
int    g_iKolGrabPunches[MAXPLAYERS + 1];
int    g_iKolGrabMoveType[MAXPLAYERS + 1];  // movetype a restaurar (commons)
float  g_fKolLungeUntil[MAXPLAYERS + 1];    // ventana del lunge 0.6s
float  g_fKolGrabHoldEnd[MAXPLAYERS + 1];   // max 10s en vilo
float  g_fKolGrabCdUntil[MAXPLAYERS + 1];
bool   g_bKolGrabLunged[MAXPLAYERS + 1];    // el impulso del lunge ya salio

float  g_fKolBlockUntil[MAXPLAYERS + 1];
float  g_fKolBlockCdUntil[MAXPLAYERS + 1];
bool   g_bKolBlockCountered[MAXPLAYERS + 1]; // el parry ya disparo la roca

float  g_fKolIndUntil[MAXPLAYERS + 1];
float  g_fKolIndCdUntil[MAXPLAYERS + 1];
float  g_fKolIndNextPing[MAXPLAYERS + 1];

// ------------------------- AVATAR ESPEJO ----------------------------
int    g_iKolAvatar[MAXPLAYERS + 1];        // EntRef copia R (0 = sin avatar)
int    g_iKolAvatarL[MAXPLAYERS + 1];       // EntRef copia L
int    g_iKolBodyRender[MAXPLAYERS + 1];    // render del cuerpo oculto
int    g_iKolAnimState[MAXPLAYERS + 1];
float  g_fKolJumpStart[MAXPLAYERS + 1];
float  g_fKolBodyYaw[MAXPLAYERS + 1];
float  g_fKolYawLastT[MAXPLAYERS + 1];
float  g_fKolSmLoc[MAXPLAYERS + 1][3];
float  g_fKolSmLocL[MAXPLAYERS + 1][3];
bool   g_bKolSmSnap[MAXPLAYERS + 1];
bool   g_bKolWelcomeSaid[MAXPLAYERS + 1];
bool   g_bKolHooked[MAXPLAYERS + 1];      // OnTakeDamage enganchado (auto-gestion FSM)
bool   g_bKolHpApplied[MAXPLAYERS + 1];   // vida max aplicada en esta vida

// ------------------------- ASSETS -----------------------------------
bool   g_bKolModelOK = false;              // kolossos.mdl montado (patron Blaze)
bool   g_bKolWarnedModel = false;
bool   g_bKolSeqsOK = false;
bool   g_bKolSeqOK[KOL_ST_COUNT];
char   g_sKolSeqName[KOL_ST_COUNT][24] = { "idle", "walk", "run", "jump", "fall" };

// sonidos del killer (sound/om/kolossos/) — fallback nativo si falta
bool   g_bKolSndSigh, g_bKolSndRumble, g_bKolSndRoar, g_bKolSndStartup;
bool   g_bKolSndImpacts, g_bKolSndLaugh, g_bKolSndWallBump;
bool   g_bKolSndGrabLunge, g_bKolSndGrabUse, g_bKolSndImpale;
bool   g_bKolSndPunch, g_bKolSndPullOut, g_bKolSndWhisper, g_bKolSndBlock;
bool   g_bKolSndPing;                      // om/metal/ping1.wav (ya del suite)
bool   g_bKolRockModel = false;            // rockgranite03b.mdl (nativo L4D2)

// sprites del indicator: g_iKolIndSprite[entidx] = EntRef del glow
int    g_iKolIndSprite[KOL_MAXENT + 1];

// ------------------------- TIMER FSM --------------------------------
Handle g_hKolThink = null;                 // 10 Hz (patron T_BlazeAvatarThink)

// =====================================================================
//  UTILIDADES
// =====================================================================

bool Kolossos_PlayerIs(int client)
{
    if (client < 1 || client > MaxClients) return false;
    if (!IsClientInGame(client)) return false;
    return g_iPlayerCharIdx[client] == KOLOSSOS_INDEX;
}

bool Kolossos_Valid(int client)
{
    if (!Kolossos_PlayerIs(client)) return false;
    return (IsPlayerAlive(client) && GetClientTeam(client) == 2);
}

float Kolossos_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// la direccion de movimiento (receta Metal_GetMoveDir: mirar no frena)
void Kolossos_GetMoveDir(int client, float dir[3])
{
    float ang[3];
    GetClientEyeAngles(client, ang);
    dir[0] = Cosine(DegToRad(ang[1]));
    dir[1] = Sine(DegToRad(ang[1]));
    dir[2] = 0.0;
}

void Kolossos_Emit(int client, bool has, const char[] real, const char[] fallback)
{
    if (has) EmitSoundToAll(real, client, _, KOL_SND_LEVEL);
    else if (fallback[0] != '\0') EmitSoundToAll(fallback, client, _, KOL_SND_LEVEL);
}

// =====================================================================
//  CICLO DE VIDA DEL MODULO
// =====================================================================

public void Kolossos_OnPluginStart()
{
    g_cvKolEnabled     = CreateConVar("kolossos_enabled", "1", "Kolossos: personaje activo (0 = kit apagado)", 0, true, 0.0, true, 1.0);
    g_cvKolModel       = CreateConVar("kolossos_model", "models/noodles/om/kolossos.mdl", "Kolossos: ruta del .mdl del avatar espejo (sin archivo = sin avatar, kit sigue)");
    g_cvKolAvatar      = CreateConVar("kolossos_avatar", "1", "Kolossos: avatar espejo montado sobre el survivor actual (0 = solo kit)", 0, true, 0.0, true, 1.0);
    g_cvKolHealth      = CreateConVar("kolossos_health", "670", "Kolossos: vida maxima al elegirlo (GMod 670; 0 = sin cambio)", 0, true, 0.0);
    g_cvKolResist      = CreateConVar("kolossos_resistance", "100", "Kolossos: % de dano recibido (100 = neutro, 50 = mitad)", 0, true, 1.0, true, 1000.0);

    g_cvKolChgSpeed    = CreateConVar("kolossos_charge_speed", "750", "Kolossos [Z] Charge: velocidad uu/s de la avalancha (GMod 1400; calibracion L4D2 tipo Metal)", 0, true, 100.0, true, 1400.0);
    g_cvKolChgDur      = CreateConVar("kolossos_charge_duration", "7", "Kolossos [Z] Charge: duracion base en s (GMod 7)", 0, true, 1.0, true, 30.0);
    g_cvKolChgMaxDur   = CreateConVar("kolossos_charge_maxduration", "20", "Kolossos [Z] Charge: tope total con extensiones por empale (anti-horda infinita)", 0, true, 5.0, true, 60.0);
    g_cvKolChgDmg      = CreateConVar("kolossos_charge_damage", "25", "Kolossos [Z] Charge: dano de empale por victima (GMod 25)", 0, true, 1.0);
    g_cvKolChgAdd      = CreateConVar("kolossos_charge_impale_add", "3.75", "Kolossos [Z] Charge: s extra por victima nueva (GMod 3.75)", 0, true, 0.0, true, 10.0);
    g_cvKolChgCd       = CreateConVar("kolossos_charge_cooldown", "22", "Kolossos [Z] Charge: cooldown s (GMod 22)", 0, true, 1.0);
    g_cvKolChgRadius   = CreateConVar("kolossos_charge_radius", "90", "Kolossos [Z] Charge: radio de empale u (GMod 90)", 0, true, 30.0, true, 250.0);

    g_cvKolGrabCd      = CreateConVar("kolossos_grab_cooldown", "25", "Kolossos [X] Grab: cooldown s (GMod 25)", 0, true, 1.0);
    g_cvKolGrabWindow  = CreateConVar("kolossos_grab_window", "0.6", "Kolossos [X] Grab: ventana del lunge s (GMod 0.6)", 0, true, 0.1, true, 3.0);
    g_cvKolGrabHold    = CreateConVar("kolossos_grab_hold", "10", "Kolossos [X] Grab: max s con la victima en vilo (GMod 10)", 0, true, 1.0, true, 30.0);
    g_cvKolGrabPunches = CreateConVar("kolossos_grab_punches", "3", "Kolossos [X] Grab: puos antes del lanzamiento (GMod 3)", 0, true, 1.0, true, 10.0);
    g_cvKolGrabPunchDmg= CreateConVar("kolossos_grab_punchdamage", "15", "Kolossos [X] Grab: dano por puo (GMod slamDamage 15)", 0, true, 1.0);
    g_cvKolGrabCancel  = CreateConVar("kolossos_grab_cancel", "0", "Kolossos [X] Grab: X de nuevo suelta a la victima (GMod CanCancelGrab=0)", 0, true, 0.0, true, 1.0);

    g_cvKolIndCd       = CreateConVar("kolossos_indicator_cooldown", "14", "Kolossos [C] Indicator: cooldown s (GMod 14)", 0, true, 1.0);
    g_cvKolIndDur      = CreateConVar("kolossos_indicator_duration", "5", "Kolossos [C] Indicator: duracion s (GMod 5)", 0, true, 1.0, true, 30.0);
    g_cvKolIndRadius   = CreateConVar("kolossos_indicator_radius", "3000", "Kolossos [C] Indicator: radio de deteccion u (0 = todo el mapa)", 0, true, 0.0);

    g_cvKolBlockCd     = CreateConVar("kolossos_block_cooldown", "14", "Kolossos [B] Block: cooldown s (GMod 14)", 0, true, 1.0);
    g_cvKolBlockDur    = CreateConVar("kolossos_block_duration", "3.5", "Kolossos [B] Block: duracion s (GMod 3.5)", 0, true, 0.5, true, 10.0);
    g_cvKolRockDmg     = CreateConVar("kolossos_rock_damage", "35", "Kolossos [B] Block: dano de la roca del contragolpe", 0, true, 1.0);
    g_cvKolRockScale   = CreateConVar("kolossos_rock_scale", "3", "Kolossos [B] Block: escala de la roca (GMod 3)", 0, true, 0.5, true, 6.0);

    RegConsoleCmd("sm_kolossos", Kolossos_CmdDebug, "Kolossos: estado del kit (debug)");

    HookEvent("player_spawn",   Kolossos_EventSpawn);
    HookEvent("player_death",   Kolossos_EventDeath);
    HookEvent("round_start",    Kolossos_EventRoundStart);

    for (int i = 1; i <= MaxClients; i++)
    {
        g_iKolSavedColGroup[i] = -1;
        g_iKolBodyRender[i]    = -1;
        g_iKolAnimState[i]     = -1;
        g_iKolGrabMoveType[i]  = -1;
        g_iKolGrabVictim[i]    = 0;
        g_hKolHitList[i]       = null;
    }
    for (int e = 0; e <= KOL_MAXENT; e++) g_iKolIndSprite[e] = 0;

    delete g_hKolThink;
    g_hKolThink = CreateTimer(0.1, T_KolossosThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void Kolossos_OnMapStart()
{
    // modelo del avatar (patron Blaze g_bBlazeModelOK)
    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));
    g_bKolModelOK = (mdl[0] != '\0') && FileExists(mdl, true);
    if (g_bKolModelOK)
    {
        PrecacheModel(mdl, true);
        g_bKolSeqsOK = false;   // se resuelven al nacer el primer avatar
    }
    else if (!g_bKolWarnedModel)
    {
        g_bKolWarnedModel = true;
        LogMessage("[Kolossos] Sin '%s' — avatar espejo OFF (el kit funciona igual). Copia el .mdl a esa ruta para activarlo.", mdl);
    }

    // la roca del contragolpe (nativa L4D2: models/props_wasteland/rockgranite03b.mdl)
    g_bKolRockModel = FileExists("models/props_wasteland/rockgranite03b.mdl", true);
    if (g_bKolRockModel) PrecacheModel("models/props_wasteland/rockgranite03b.mdl", true);

    // sonidos del killer: carpeta om/kolossos del addon GMod + fallbacks nativos
    g_bKolSndSigh      = FileExists("sound/om/kolossos/kol sigh i think.wav", true);
    g_bKolSndRumble    = FileExists("sound/om/kolossos/kol charge start ground rumble.wav", true);
    g_bKolSndRoar      = FileExists("sound/om/kolossos/KolossosChargeRoar.wav", true);
    g_bKolSndStartup   = FileExists("sound/om/kolossos/StartUpCharge.wav", true);
    g_bKolSndImpacts   = FileExists("sound/om/kolossos/Kol impacts.wav", true);
    g_bKolSndLaugh     = FileExists("sound/om/kolossos/Kol charge laugh impale.wav", true);
    g_bKolSndWallBump  = FileExists("sound/om/kolossos/Kol wall bump.wav", true);
    g_bKolSndGrabLunge = FileExists("sound/om/kolossos/kol grab lunge.wav", true);
    g_bKolSndGrabUse   = FileExists("sound/om/kolossos/Kol uses grab.wav", true);
    g_bKolSndImpale    = FileExists("sound/om/kolossos/Kol impales.wav", true);
    g_bKolSndPunch     = FileExists("sound/om/kolossos/kolossos punching.wav", true);
    g_bKolSndPullOut   = FileExists("sound/om/kolossos/kol sting and pull out.wav", true);
    g_bKolSndWhisper   = FileExists("sound/om/kolossos/kol whispers.wav", true);
    g_bKolSndBlock     = FileExists("sound/om/kolossos/kol block.wav", true);
    g_bKolSndPing      = FileExists("sound/om/metal/ping1.wav", true);   // ya lo usa Metal

    if (g_bKolSndSigh)      PrecacheSound("om/kolossos/kol sigh i think.wav", true);
    if (g_bKolSndRumble)    PrecacheSound("om/kolossos/kol charge start ground rumble.wav", true);
    if (g_bKolSndRoar)      PrecacheSound("om/kolossos/KolossosChargeRoar.wav", true);
    if (g_bKolSndStartup)   PrecacheSound("om/kolossos/StartUpCharge.wav", true);
    if (g_bKolSndImpacts)   PrecacheSound("om/kolossos/Kol impacts.wav", true);
    if (g_bKolSndLaugh)     PrecacheSound("om/kolossos/Kol charge laugh impale.wav", true);
    if (g_bKolSndWallBump)  PrecacheSound("om/kolossos/Kol wall bump.wav", true);
    if (g_bKolSndGrabLunge) PrecacheSound("om/kolossos/kol grab lunge.wav", true);
    if (g_bKolSndGrabUse)   PrecacheSound("om/kolossos/Kol uses grab.wav", true);
    if (g_bKolSndImpale)    PrecacheSound("om/kolossos/Kol impales.wav", true);
    if (g_bKolSndPunch)     PrecacheSound("om/kolossos/kolossos punching.wav", true);
    if (g_bKolSndPullOut)   PrecacheSound("om/kolossos/kol sting and pull out.wav", true);
    if (g_bKolSndWhisper)   PrecacheSound("om/kolossos/kol whispers.wav", true);
    if (g_bKolSndBlock)     PrecacheSound("om/kolossos/kol block.wav", true);
    if (g_bKolSndPing)      PrecacheSound("om/metal/ping1.wav", true);

    g_bKolWarnedModel = false;   // avisa 1 vez por mapa si falta el modelo
}

// =====================================================================
//  EVENTOS (auto-enganchados — cero cableado en el manager)
// =====================================================================

public void Kolossos_EventSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!Kolossos_PlayerIs(client)) return;
    if (GetClientTeam(client) != 2) return;

    Kolossos_ResetState(client);

    // hook de dano (resistencia + block) — idempotente
    SDKUnhook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);

    // vida max (receta Metal_ApplyMaxHealth)
    Kolossos_ApplyMaxHealth(client);
}

public void Kolossos_EventDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client < 1 || client > MaxClients) return;

    // si era un agarrado por Kolossos: restaurar su movetype
    if (g_iPlayerCharIdx[client] != KOLOSSOS_INDEX)
    {
        for (int k = 1; k <= MaxClients; k++)
            if (g_iKolGrabVictim[k] != 0 && EntRefToEntIndex(g_iKolGrabVictim[k]) == client)
                Kolossos_GrabRelease(k, false, true);
        return;
    }

    // el Kolossos murio: cancelar todo (el avatar lo baja la FSM en 0.1s)
    Kolossos_ResetState(client);
    SDKUnhook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
    Kolossos_RestoreMaxHealth(client);
}

public void Kolossos_EventRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // barrido de arranque: huerfanos del mapa anterior fuera (patron Suite)
    Kolossos_KillGhostAvatarProps();
    Kolossos_KillAllIndSprites();

    for (int i = 1; i <= MaxClients; i++)
    {
        Kolossos_ResetState(i);
        g_bKolWelcomeSaid[i] = false;
    }
}

// =====================================================================
//  RESET / CLEANUP (manager: CleanupCharModuleState case KOLOSSOS_INDEX)
// =====================================================================

void Kolossos_ResetState(int client)
{
    // cancelar charge (restaura colision/velocidad/FOV/loop)
    if (g_iKolChargeState[client] != KOL_CHG_IDLE)
        Kolossos_ChargeEnd(client, false);

    // soltar al agarrado
    if (g_iKolGrabVictim[client] != 0)
        Kolossos_GrabRelease(client, false, false);

    g_fKolLungeUntil[client]   = 0.0;
    g_fKolGrabCdUntil[client]  = 0.0;
    g_fKolBlockUntil[client]   = 0.0;
    g_fKolBlockCdUntil[client] = 0.0;
    g_bKolBlockCountered[client] = false;
    g_fKolIndUntil[client]     = 0.0;
    g_fKolIndCdUntil[client]   = 0.0;
    g_fKolIndNextPing[client]  = 0.0;

    if (g_hKolHitList[client] != null)
    {
        delete g_hKolHitList[client];
        g_hKolHitList[client] = null;
    }
}

// limpieza total: cambio de personaje / disconnect (manager la llama;
// para disconnect el propio modulo la invoca desde la FSM)
void Kolossos_CleanupState(int client)
{
    Kolossos_ResetState(client);
    Kolossos_KillAvatar(client);
    Kolossos_RestoreMaxHealth(client);
    SDKUnhook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
    g_bKolHooked[client]     = false;   // el slot puede reutilizarse (disconnect)
    g_bKolHpApplied[client]  = false;
    g_bKolWelcomeSaid[client] = false;
    g_iKolAnimState[client]   = -1;
}

// =====================================================================
//  STATS (receta Metal_ApplyMaxHealth / RestoreMaxHealth)
// =====================================================================

void Kolossos_ApplyMaxHealth(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client) || GetClientTeam(client) != 2) return;

    int maxhp = g_cvKolHealth.IntValue;
    if (maxhp <= 0) return;

    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", maxhp);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", maxhp);

    if (IsPlayerAlive(client) && !GetEntProp(client, Prop_Send, "m_isIncapacitated"))
    {
        int hp = GetClientHealth(client);
        if (hp >= 100 && hp < maxhp)
            SetEntityHealth(client, maxhp);
    }
}

void Kolossos_RestoreMaxHealth(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] == KOLOSSOS_INDEX) return;   // sigue siendo Kolossos

    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", 100);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", 100);

    if (IsPlayerAlive(client) && GetClientHealth(client) > 100)
        SetEntityHealth(client, 100);
}

// =====================================================================
//  AVATAR ESPEJO (patron Blaze v2.11 / sonic.inc v6.30 — 14o avatar)
// =====================================================================

#define KOL_AVATAR_NAME   "kolossos_avatar_om"
#define KOL_AVATAR_NAME_L "kolossos_avatar_om_l"

int Kolossos_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
{
    int av = CreateEntityByName("prop_dynamic_override");
    if (av <= 0 || !IsValidEntity(av)) return 0;

    DispatchKeyValue(av, "model", model);
    DispatchKeyValue(av, "targetname", targetname);
    DispatchKeyValue(av, "solid", "0");
    DispatchKeyValue(av, "disableshadows", "1");
    DispatchSpawn(av);

    float pos[3], ang[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    ang[0] = 0.0;                          // pitch NUNCA
    ang[2] = 0.0;                          // roll NUNCA
    g_fKolBodyYaw[client]  = ang[1];
    g_fKolYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fKolBodyYaw[client], loc);

    if (!tpMode)
    {
        // parentado (modo default: el motor mueve la posicion)
        SetVariantString("!activator");
        AcceptEntityInput(av, "SetParent", client);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", loc);
    }

    for (int k = 0; k < 3; k++)
    {
        g_fKolSmLoc[client][k]  = loc[k];
        g_fKolSmLocL[client][k] = loc[k];
    }
    g_bKolSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// resolucion de secuencias contra el .mdl REAL (sonda del patron
// Blaze_ResolveTry: SetAnimation + m_nSequence — SIN LookupSequence,// que no existe en SM 1.12; una vez por mapa)
void Kolossos_ResolveTry(int av, int state, const char[] name)
{
    if (!HasEntProp(av, Prop_Send, "m_nSequence")) return;

    int before = GetEntProp(av, Prop_Send, "m_nSequence");
    SetVariantString(name);
    AcceptEntityInput(av, "SetAnimation");
    int after = GetEntProp(av, Prop_Send, "m_nSequence");

    if (after != before)
    {
        strcopy(g_sKolSeqName[state], 24, name);
        g_bKolSeqOK[state] = true;
    }
}

void Kolossos_ResolveSeqs(int av)
{
    if (g_bKolSeqsOK) return;
    g_bKolSeqsOK = true;

    // candidatos por estado: nombres GMod + variantes comunes
    char idleCands[][16] = { "idle", "Idle", "IDLE", "idle01" };
    char walkCands[][16] = { "walk", "Walk", "walk01", "WalkAll" };
    char runCands[][16]  = { "run", "Run", "run01", "RunAll" };
    char jumpCands[][16] = { "jump", "Jump", "jump01" };
    char fallCands[][16] = { "fall", "Fall", "glide", "fall01" };

    for (int c = 0; c < sizeof(idleCands); c++) { Kolossos_ResolveTry(av, KOL_ST_IDLE, idleCands[c]); if (g_bKolSeqOK[KOL_ST_IDLE]) break; }
    for (int c = 0; c < sizeof(walkCands); c++) { Kolossos_ResolveTry(av, KOL_ST_WALK, walkCands[c]); if (g_bKolSeqOK[KOL_ST_WALK]) break; }
    for (int c = 0; c < sizeof(runCands);  c++) { Kolossos_ResolveTry(av, KOL_ST_RUN,  runCands[c]);  if (g_bKolSeqOK[KOL_ST_RUN])  break; }
    for (int c = 0; c < sizeof(jumpCands); c++) { Kolossos_ResolveTry(av, KOL_ST_JUMP, jumpCands[c]); if (g_bKolSeqOK[KOL_ST_JUMP]) break; }
    for (int c = 0; c < sizeof(fallCands); c++) { Kolossos_ResolveTry(av, KOL_ST_FALL, fallCands[c]); if (g_bKolSeqOK[KOL_ST_FALL]) break; }

    // fallbacks: lo que falte cae a idle (nunca T-pose)
    for (int s = 1; s < KOL_ST_COUNT; s++)
    {
        if (!g_bKolSeqOK[s])
            strcopy(g_sKolSeqName[s], 24, g_sKolSeqName[KOL_ST_IDLE]);
    }
}

void Kolossos_SeqFor(int state, char[] out, int maxlen)
{
    strcopy(out, maxlen, g_sKolSeqName[state]);
}

// transmit: R la ven TODOS menos el dueno; L solo el dueno
public Action Kolossos_TransmitAvatarR(int entity, int client)
{
    if (Kolossos_PlayerIs(client)) return Plugin_Handled;
    return Plugin_Continue;
}

public Action Kolossos_TransmitAvatarL(int entity, int client)
{
    if (Kolossos_PlayerIs(client)) return Plugin_Continue;
    return Plugin_Handled;
}

void Kolossos_CreateAvatarL(int client)
{
    if (!g_bKolModelOK) return;
    if (!Kolossos_Valid(client)) return;
    if (g_iKolAvatar[client] == 0) return;

    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));
    int av = Kolossos_CreateAvatarProp(client, mdl, KOL_AVATAR_NAME_L);
    if (av == 0) return;

    char seqIdle[24];
    Kolossos_SeqFor(KOL_ST_IDLE, seqIdle, sizeof(seqIdle));
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Kolossos_TransmitAvatarL);
    g_iKolAvatarL[client] = EntIndexToEntRef(av);
}

void Kolossos_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iKolAvatarL[client]);
    if (g_iKolAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Kolossos_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iKolAvatarL[client] = 0;
}

void Kolossos_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    Kolossos_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iKolAvatar[client]);
    if (g_iKolAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Kolossos_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iKolAvatar[client] = 0;
    g_iKolAnimState[client] = -1;

    // devolver el cuerpo (spectate/revive/cambio de personaje)
    if (IsClientInGame(client) && g_iKolBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iKolBodyRender[client]));
        g_iKolBodyRender[client] = -1;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Kolossos_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Kolossos_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Kolossos_AvatarFollow);
}

void Kolossos_CreateAvatar(int client)
{
    if (!Kolossos_Valid(client)) return;

    // limpieza del ciclo anterior (reemplazo limpio)
    Kolossos_KillAvatar(client);

    // adopcion: todo prop de ESTE modulo que la FSM no rastrea = huerfano
    Kolossos_KillGhostAvatarProps();

    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));
    int av = Kolossos_CreateAvatarProp(client, mdl, KOL_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    Kolossos_ResolveSeqs(av);

    char seqIdle[24];
    Kolossos_SeqFor(KOL_ST_IDLE, seqIdle, sizeof(seqIdle));
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");
    g_iKolAnimState[client] = KOL_ST_IDLE;

    SDKHook(av, SDKHook_SetTransmit, Kolossos_TransmitAvatarR);

    g_iKolAvatarL[client] = 0;
    Kolossos_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iKolBodyRender[client] = view_as<int>(curMode);
    else if (g_iKolBodyRender[client] == -1)
        g_iKolBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    g_iKolAvatar[client] = EntIndexToEntRef(av);

    // per-tick: angulos locales (contra-rotacion del parent)
    SDKHook(client, SDKHook_PostThink, Kolossos_AvatarFollow);

    // pulso de pausa en cada montaje (la infra del suite)
    Tails_PauseFix_Trigger(client);

    if (!g_bKolWelcomeSaid[client] && !IsFakeClient(client))
    {
        g_bKolWelcomeSaid[client] = true;
        PrintToChat(client, "\x04[Kolossos]\x01 Avatar espejo activo — 14o avatar del suite. Z Carga | X Agarre | C Indicator | B Bloqueo.");
    }
}

// (patron Blaze_IsMyAvatarRef — huerfanos por definicion)
bool Kolossos_IsMyAvatarRef(int ref)
{
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iKolAvatar[i] == ref) return true;
        if (g_iKolAvatarL[i] == ref) return true;
    }
    return false;
}

void Kolossos_KillGhostAvatarProps()
{
    int ent = -1;
    char name[32];
    while ((ent = FindEntityByClassname(ent, "prop_dynamic_override")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        GetEntPropString(ent, Prop_Data, "m_iName", name, sizeof(name));
        if (StrEqual(name, KOL_AVATAR_NAME) || StrEqual(name, KOL_AVATAR_NAME_L))
        {
            if (!Kolossos_IsMyAvatarRef(EntIndexToEntRef(ent)))
                AcceptEntityInput(ent, "Kill");   // huerfano
        }
    }
}

// per-tick: yaw suavizado 900 grados/s + TP/local del R + contra-rotacion L
public void Kolossos_AvatarFollow(int client)
{
    if (g_iKolAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Kolossos_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    float yawObj = g_fKolBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fKolBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    float now = GetEngineTime();
    float dt  = now - g_fKolYawLastT[client];
    g_fKolYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fKolBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fKolBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bKolSmSnap[client];
    GetClientAbsAngles(client, par);
    float yawPuppet = g_fKolBodyYaw[client];

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iKolAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        if (Tails_AvatarTPOn())
        {
            float posTP[3], angTP[3];
            GetClientAbsOrigin(client, posTP);
            angTP[0] = 0.0;
            angTP[1] = yawPuppet;
            angTP[2] = 0.0;
            TeleportEntity(av, posTP, angTP, NULL_VECTOR);
            Tails_MarkInterp(av);
        }
        else
        {
            Tails_AvatarLocalAngles(par[0], par[1], yawPuppet, loc);
            loc[1] = Tails_UnwrapYaw(g_fKolSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fKolSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fKolSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }
    g_bKolSmSnap[client] = false;

    // ---- copia L: contra-rotada contra los EYE del dueno ----
    if (g_iKolAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iKolAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            Tails_AvatarLocalAngles(par[0], par[1], yawPuppet, loc);
            loc[1] = Tails_UnwrapYaw(g_fKolSmLocL[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fKolSmLocL[client], 0.05, dt, false);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fKolSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
}

// anims del avatar (prioridades: aire -> suelo; receta Blaze_AvatarUpdate)
void Kolossos_AvatarUpdate(int client, int av, float now)
{
    int state;
    float rate = 1.0;

    if (g_iKolChargeState[client] == KOL_CHG_WINDUP)
    {
        state = KOL_ST_IDLE;   // el coloso planta los pies para arrancar
    }
    else if (g_iKolChargeState[client] == KOL_CHG_DASH)
    {
        state = KOL_ST_RUN;
        rate  = 1.6;
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        state = (vel[2] > 40.0) ? KOL_ST_JUMP : KOL_ST_FALL;
    }
    else if (g_iKolAnimState[client] == KOL_ST_JUMP
             && now - g_fKolJumpStart[client] < 0.5)
    {
        state = KOL_ST_JUMP;   // FL_ONGROUND parpadea en escalones
    }
    else
    {
        float s = Kolossos_Speed2D(client);
        if (s < 40.0)               state = KOL_ST_IDLE;
        else if (s < 150.0
                 || (GetClientButtons(client) & IN_DUCK)) state = KOL_ST_WALK;
        else
        {
            state = KOL_ST_RUN;
            rate  = 1.32 * (s / 450.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6)  rate = 3.6;
        }
    }

    if (state != g_iKolAnimState[client])
    {
        if (state == KOL_ST_JUMP) g_fKolJumpStart[client] = now;

        char seqUse[24];
        Kolossos_SeqFor(state, seqUse, sizeof(seqUse));

        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iKolAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iKolAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                SetVariantString(seqUse);   // el variant es de UN SOLO USO
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iKolAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iKolAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iKolAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

// =====================================================================
//  [Z] HABILIDAD 1 — CHARGE (la avalancha empaladora)
//  GMod l.2311-2397: windup 0.8 (suspiro 0.15 / rumble 0.35 / rugido
//  0.75) -> Charging_kolossos 7s a velocidad charge; esfera 90u:
//  ChargeImpaleDamage + HitList + extension 3.75s por victima; fling
//  final (fwd*5000+up*2000 en GMod = fwd*500+up*300 en L4D2).
//  Receta de movimiento: Metal v5.0 (stack + auto-forward + DEBRIS).
// =====================================================================

void Kolossos_Ability1(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    // puo durante un agarre = pegarle al agarrado (GMod l.2566)
    if (g_iKolGrabVictim[client] != 0)
    {
        Kolossos_GrabPunch(client);
        return;
    }

    if (g_iKolChargeState[client] != KOL_CHG_IDLE)
    {
        PrintCenterText(client, "Ya estas en avalancha.");
        return;
    }
    if (g_fKolLungeUntil[client] > now
        || g_fKolBlockUntil[client] > now
        || g_fKolIndUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolChargeCdUntil[client])
    {
        PrintCenterText(client, "Charge: %.1fs", g_fKolChargeCdUntil[client] - now);
        return;
    }

    g_fKolChargeCdUntil[client] = now + g_cvKolChgCd.FloatValue;

    // ---- WINDUP 0.8s: congelado, suspiro -> rumble -> rugido ----
    g_iKolChargeState[client]  = KOL_CHG_WINDUP;
    g_fKolWindupStart[client]  = now;
    g_fKolChargeEnd[client]    = now + KOL_CHG_WINDUP_T + g_cvKolChgDur.FloatValue;
    g_fKolStuckSince[client]   = 0.0;

    if (g_hKolHitList[client] == null)
        g_hKolHitList[client] = new ArrayList();
    else
        g_hKolHitList[client].Clear();

    // sonido de arranque + stages del windup (GMod timer.Simple;
    // codigo = userid*10 + stage — userids grandes ya no rompen el decode)
    Kolossos_Emit(client, g_bKolSndStartup, "om/kolossos/StartUpCharge.wav",
                  "npc/attack_helicopter/aheli_charge_up.wav");
    CreateTimer(KOL_CHG_WINDUP_SIGH, Kolossos_T_WindupStage, GetClientUserId(client) * 10 + 0);
    CreateTimer(KOL_CHG_WINDUP_RUMBLE, Kolossos_T_WindupStage, GetClientUserId(client) * 10 + 1);
    CreateTimer(KOL_CHG_WINDUP_ROAR, Kolossos_T_WindupStage, GetClientUserId(client) * 10 + 2);

    PrintCenterText(client, "Cargando la avalancha...");
}

// stages del windup: 0=suspiro 1=rumble 2=rugido (codigo = userid*10 + stage)
public Action Kolossos_T_WindupStage(Handle timer, int code)
{
    int stage = code % 10;
    int client = GetClientOfUserId(code / 10);
    if (client < 1 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (g_iKolChargeState[client] != KOL_CHG_WINDUP) return Plugin_Stop;

    switch (stage)
    {
        case 0: Kolossos_Emit(client, g_bKolSndSigh, "om/kolossos/kol sigh i think.wav", "");
        case 1: Kolossos_Emit(client, g_bKolSndRumble, "om/kolossos/kol charge start ground rumble.wav",
                              "ambient/machines/thumper_startup1.wav");
        case 2:
        {
            Kolossos_Emit(client, g_bKolSndRoar, "om/kolossos/KolossosChargeRoar.wav",
                          "npc/attack_helicopter/aheli_alert1.wav");
            // transicion WINDUP -> DASH (la FSM toma el control desde aqui)
            Kolossos_ChargeLaunch(client);
        }
    }
    return Plugin_Stop;
}

// el arranque de la avalancha (receta Metal v5.0: stack + impulso + DEBRIS)
void Kolossos_ChargeLaunch(int client)
{
    g_iKolChargeState[client] = KOL_CHG_DASH;

    // restaurar el lagged del windup y topear la velocidad por el stack
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    Kolossos_DashSpeedSet(client, g_cvKolChgSpeed.FloatValue);

    // DEBRIS: atraviesa cuerpos durante la avalancha (como el mod)
    if (g_iKolSavedColGroup[client] == -1)
    {
        g_iKolSavedColGroup[client] = GetEntProp(client, Prop_Data, "m_CollisionGroup");
        SetEntProp(client, Prop_Data, "m_CollisionGroup", KOL_CHG_COLGROUP);
    }

    // impulso de arranque (el tope ya alzado clampea el motor)
    float dir[3], vel[3];
    Kolossos_GetMoveDir(client, dir);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[0] = dir[0] * (KOL_CHG_LAUNCH_MIN < g_cvKolChgSpeed.FloatValue ? g_cvKolChgSpeed.FloatValue : KOL_CHG_LAUNCH_MIN);
    vel[1] = dir[1] * (KOL_CHG_LAUNCH_MIN < g_cvKolChgSpeed.FloatValue ? g_cvKolChgSpeed.FloatValue : KOL_CHG_LAUNCH_MIN);
    if (GetEntityFlags(client) & FL_ONGROUND)
        vel[2] = 0.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    // camara de velocidad (receta Metal)
    SetEntProp(client, Prop_Send, "m_iFOV", KOL_CHG_FOV);
    SetEntProp(client, Prop_Send, "m_iFOVStart", KOL_CHG_FOV);

    PrintCenterText(client, "AVALANCHA!");
}

// tope de velocidad via el stack del Speed_sonic (receta Metal_DashSpeedSet)
void Kolossos_DashSpeedSet(int client, float target)
{
    float base = Speed_GetBaseSpeed(client);
    if (base < 50.0) base = 220.0;
    float extra = target / base - 1.0;
    if (extra < 0.0) extra = 0.0;
    Speed_StackSet(client, SPEED_STACK_KOLOSSOS, extra);
}

// fin de la avalancha: timeout / pared / cancel / muerte
void Kolossos_ChargeEnd(int client, bool hitWall)
{
    if (g_iKolChargeState[client] == KOL_CHG_IDLE) return;

    // lagged del windup si quedo clavado en 0
    if (g_iKolChargeState[client] == KOL_CHG_WINDUP)
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);

    // fuera DEBRIS + slot del stack + frenado suave + FOV
    if (g_iKolSavedColGroup[client] > 0)
        SetEntProp(client, Prop_Data, "m_CollisionGroup", g_iKolSavedColGroup[client]);
    g_iKolSavedColGroup[client] = -1;
    Speed_StackSet(client, SPEED_STACK_KOLOSSOS, 0.0);

    if (IsClientInGame(client) && IsPlayerAlive(client))
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntProp(client, Prop_Send, "m_iFOV", 0);
        SetEntProp(client, Prop_Send, "m_iFOVStart", 0);

        float vel[3], endVel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        endVel[0] = vel[0] * 0.25;
        endVel[1] = vel[1] * 0.25;
        endVel[2] = vel[2];
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, endVel);
    }

    // fling de las victimas vivas de la HitList (el GMod las suelta volando)
    Kolossos_FlingHitList(client, hitWall);

    // tope de pared: sonido + bloqueo de ataque breve (GMod 3.65s AttackCooldown)
    if (hitWall && IsClientInGame(client) && IsPlayerAlive(client))
        Kolossos_Emit(client, g_bKolSndWallBump, "om/kolossos/Kol wall bump.wav",
                      "physics/concrete/concrete_break2.wav");

    g_iKolChargeState[client] = KOL_CHG_IDLE;
}

// las victimas empaladas que siguen vivas salen volando al final
void Kolossos_FlingHitList(int client, bool hitWall)
{
    if (g_hKolHitList[client] == null) return;

    float dir[3];
    Kolossos_GetMoveDir(client, dir);

    // contra la pared: direccion aleatoria (GMod l.1914-1931)
    if (hitWall)
    {
        switch (GetRandomInt(0, 2))
        {
            case 0: { dir[0] = 1.0;  dir[1] = 0.0; }   // derecha
            case 1: { dir[0] = -1.0; dir[1] = 0.0; }   // izquierda
            case 2: { /* sigue de frente */ }
        }
    }

    float push[3];
    push[0] = dir[0] * KOL_CHG_FLING_FWD;
    push[1] = dir[1] * KOL_CHG_FLING_FWD;
    push[2] = KOL_CHG_FLING_UP;

    int n = g_hKolHitList[client].Length;
    for (int i = 0; i < n; i++)
    {
        int ent = EntRefToEntIndex(g_hKolHitList[client].Get(i));
        if (ent <= 0 || !IsValidEntity(ent)) continue;

        if (ent > 0 && ent <= MaxClients)
        {
            if (!IsClientInGame(ent) || !IsPlayerAlive(ent)) continue;
            if (GetClientTeam(ent) != 3) continue;   // solo infectados
            TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
        }
        else
        {
            // commons: empuje fisico del cuerpo (si sigue vivo)
            if (GetEntProp(ent, Prop_Data, "m_iHealth") > 0 && HasEntProp(ent, Prop_Data, "m_vecVelocity"))
                TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
    g_hKolHitList[client].Clear();
}

// el tick del DASH (10 Hz): tope re-afirmado, impacto de empale, watchdog
void Kolossos_ChargeDashThink(int client, float now)
{
    // tope + FOV re-afirmados (auto-cura, receta Metal)
    Kolossos_DashSpeedSet(client, g_cvKolChgSpeed.FloatValue);
    SetEntProp(client, Prop_Send, "m_iFOV", KOL_CHG_FOV);
    SetEntProp(client, Prop_Send, "m_iFOVStart", KOL_CHG_FOV);

    // ---- impacto: esfera frontal, sin repetir victimas (HitList) ----
    // REGLA v3.77.85 (crash silencioso de la horda): el dano NUNCA va
    // dentro del FindEntityByClassname — SNAPSHOT de refs primero, dano
    // DESPUES re-validando (un comun muerto libera su edicto al instante).
    float pos[3], dir[3];
    GetClientAbsOrigin(client, pos);
    Kolossos_GetMoveDir(client, dir);
    pos[0] += dir[0] * 30.0;
    pos[1] += dir[1] * 30.0;
    pos[2] += 40.0;

    float radius = g_cvKolChgRadius.FloatValue;
    float dmg    = g_cvKolChgDmg.FloatValue;
    bool  newVictim = false;

    int   snapEnts[64];
    bool  snapIsSI[64];
    int   snapCount = 0;

    // 1) commons ("infected") — solo SNAPSHOT
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (GetVectorDistance(epos, pos) > radius) continue;
        if (Kolossos_OnHitList(client, ent)) continue;

        Kolossos_HitListAdd(client, ent);
        newVictim = true;
        snapEnts[snapCount] = ent;
        snapIsSI[snapCount] = false;
        snapCount++;
    }

    // 2) infectados especiales (clients team 3) + tank — solo SNAPSHOT
    for (int t = 1; t <= MaxClients && snapCount < 64; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (GetVectorDistance(tpos, pos) > radius) continue;
        if (Kolossos_OnHitList(client, t)) continue;

        Kolossos_HitListAdd(client, t);
        newVictim = true;
        snapEnts[snapCount] = t;
        snapIsSI[snapCount] = true;
        snapCount++;
    }

    // 3) witch (entidad, no client) — solo SNAPSHOT
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(w)) continue;
        if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
        float wpos[3];
        GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
        if (GetVectorDistance(wpos, pos) > radius) continue;
        if (Kolossos_OnHitList(client, w)) continue;

        Kolossos_HitListAdd(client, w);
        newVictim = true;
        snapEnts[snapCount] = w;
        snapIsSI[snapCount] = false;   // witch: dano puro, sin stun
        snapCount++;
    }

    // 4) EL DAÑO VA AQUI — fuera de los bucles, re-validando cada ref
    for (int k = 0; k < snapCount; k++)
    {
        int v = snapEnts[k];
        if (v <= 0 || !IsValidEntity(v)) continue;
        if (snapIsSI[k] && (v <= MaxClients))
        {
            if (!IsClientInGame(v) || !IsPlayerAlive(v)) continue;
            OM_AbilityDamage(v, client, dmg);
            OM_Stun(v, 1.0, client, 0.0, DMG_OM_CLUB, false);   // aturdido 1s
        }
        else if (v > MaxClients)
        {
            if (GetEntProp(v, Prop_Data, "m_iHealth") <= 0) continue;
            OM_AbilityDamage(v, client, dmg);
        }
    }

    if (newVictim)
    {
        Kolossos_Emit(client, g_bKolSndImpacts, "om/kolossos/Kol impacts.wav",
                      "physics/flesh/flesh_impact_hard4.wav");
        if (g_bKolSndLaugh && GetRandomInt(1, 3) == 1)
            EmitSoundToAll("om/kolossos/Kol charge laugh impale.wav", client, _, KOL_SND_LEVEL);

        // extension por victima nueva (GMod ImapleChargeDuration 3.75)
        float newEnd = g_fKolChargeEnd[client] + g_cvKolChgAdd.FloatValue;
        float maxEnd = g_fKolWindupStart[client] + KOL_CHG_WINDUP_T + g_cvKolChgMaxDur.FloatValue;
        if (newEnd > maxEnd) newEnd = maxEnd;
        g_fKolChargeEnd[client] = newEnd;
    }

    // ---- watchdog de atasco / tope de pared (receta Metal_StuckCheck) ----
    if (GetEntityFlags(client) & FL_ONGROUND)
    {
        if (Kolossos_Speed2D(client) < KOL_CHG_STUCK_MINVEL)
        {
            if (g_fKolStuckSince[client] == 0.0)
                g_fKolStuckSince[client] = now;
            else if (now - g_fKolStuckSince[client] >= KOL_CHG_STUCK_TIME)
            {
                Kolossos_ChargeEnd(client, true);   // tope seco
                return;
            }
        }
        else g_fKolStuckSince[client] = 0.0;
    }
    else g_fKolStuckSince[client] = 0.0;

    // ---- fin natural ----
    if (now >= g_fKolChargeEnd[client])
        Kolossos_ChargeEnd(client, false);
}

bool Kolossos_OnHitList(int client, int ent)
{
    if (g_hKolHitList[client] == null) return false;
    return g_hKolHitList[client].FindValue(EntIndexToEntRef(ent)) != -1;
}

void Kolossos_HitListAdd(int client, int ent)
{
    if (g_hKolHitList[client] == null) g_hKolHitList[client] = new ArrayList();
    g_hKolHitList[client].Push(EntIndexToEntRef(ent));
}

// =====================================================================
//  [X] HABILIDAD 2 — GRAB (lunge, agarre en vilo y combo de puos)
//  GMod l.2398-2479 (lunge 0.6s) + l.2041-2072 (esfera 90 -> agarrado,
//  PunchesLeft 3, max 10s) + l.2566-2630 (puos slamDamage 15).
// =====================================================================

void Kolossos_Ability2(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    // X de nuevo durante el agarre = soltar (CanCancelGrab, default off)
    if (g_iKolGrabVictim[client] != 0)
    {
        if (g_cvKolGrabCancel.BoolValue)
        {
            g_iKolGrabPunches[client] = 0;
            Kolossos_GrabRelease(client, true, false);
        }
        else PrintCenterText(client, "Puos: %d (Z)", g_iKolGrabPunches[client]);
        return;
    }

    if (g_iKolChargeState[client] != KOL_CHG_IDLE
        || g_fKolBlockUntil[client] > now
        || g_fKolIndUntil[client] > now
        || g_fKolLungeUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolGrabCdUntil[client])
    {
        PrintCenterText(client, "Grab: %.1fs", g_fKolGrabCdUntil[client] - now);
        return;
    }

    // ---- lunge: ventana de captura + impulso corto hacia delante ----
    g_fKolLungeUntil[client]  = now + g_cvKolGrabWindow.FloatValue;
    g_bKolGrabLunged[client]  = false;

    Kolossos_Emit(client, g_bKolSndGrabLunge, "om/kolossos/kol grab lunge.wav",
                  "ambient/wind/wind_hit1.wav");
    Kolossos_Emit(client, g_bKolSndGrabUse, "om/kolossos/Kol uses grab.wav", "");

    PrintCenterText(client, "Agarre!");
}

// el tick del lunge (10 Hz): impulso + esfera de captura
void Kolossos_GrabLungeThink(int client, float now)
{
    // impulso del lunge: UNA vez, al entrar (GMod velocidad grab 1750
    // durante la ventana — en L4D2: impulso unico + ventana de captura)
    if (!g_bKolGrabLunged[client])
    {
        g_bKolGrabLunged[client] = true;
        float dir[3], vel[3];
        Kolossos_GetMoveDir(client, dir);
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[0] += dir[0] * 400.0;
        vel[1] += dir[1] * 400.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    }

    // esfera frontal de captura (GMod FindInSphere 90u en el pecho)
    float pos[3], dir[3];
    GetClientAbsOrigin(client, pos);
    Kolossos_GetMoveDir(client, dir);
    pos[0] += dir[0] * 40.0;
    pos[1] += dir[1] * 40.0;
    pos[2] += 40.0;

    float radius = g_cvKolChgRadius.FloatValue;

    // commons primero (GMod: cualquier player/NPC/NextBot)
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (GetVectorDistance(epos, pos) > radius) continue;
        Kolossos_GrabBegin(client, ent);
        return;
    }

    // infectados especiales (no tank: demasiado grande para el puo)
    for (int t = 1; t <= MaxClients; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        if (GetEntProp(t, Prop_Send, "m_zombieClass") == 8) continue;   // tank fuera
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (GetVectorDistance(tpos, pos) > radius) continue;
        Kolossos_GrabBegin(client, t);
        return;
    }

    // ventana agotada sin nadie: CD completo (GMod l.2179)
    if (now >= g_fKolLungeUntil[client])
    {
        g_fKolLungeUntil[client] = 0.0;
        g_fKolGrabCdUntil[client] = now + g_cvKolGrabCd.FloatValue;
    }
}

// la victima queda en vilo delante del coloso
void Kolossos_GrabBegin(int client, int victim)
{
    g_fKolLungeUntil[client] = 0.0;
    g_iKolGrabVictim[client] = EntIndexToEntRef(victim);
    g_iKolGrabPunches[client] = g_cvKolGrabPunches.IntValue;
    g_fKolGrabHoldEnd[client] = GetEngineTime() + g_cvKolGrabHold.FloatValue;

    // congelar a la victima: commons por movetype, SI por OM_Stun
    if (victim > 0 && victim <= MaxClients)
    {
        float stunDur = g_cvKolGrabHold.FloatValue + 1.0;
        OM_Stun(victim, stunDur, client, 0.0, DMG_OM_CLUB, false);
    }
    else
    {
        g_iKolGrabMoveType[client] = GetEntProp(victim, Prop_Data, "movetype");
        SetEntProp(victim, Prop_Data, "movetype", MOVETYPE_NONE);
    }

    Kolossos_Emit(client, g_bKolSndImpale, "om/kolossos/Kol impales.wav",
                  "physics/flesh/flesh_break3.wav");

    PrintCenterText(client, "Agarrado! Puos restantes: %d (Z)", g_iKolGrabPunches[client]);
}

// el tick del agarre: victima en vilo delante + validacion + timeout
void Kolossos_GrabHoldThink(int client, float now)
{
    int victim = EntRefToEntIndex(g_iKolGrabVictim[client]);
    bool dead = false;

    if (victim <= 0 || !IsValidEntity(victim))
        dead = true;
    else if (victim <= MaxClients)
    {
        if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) dead = true;
    }
    else if (GetEntProp(victim, Prop_Data, "m_iHealth") <= 0) dead = true;

    if (dead)
    {
        // la victima murio sola: CD corto (GMod l.2026: grab_cd +2)
        Kolossos_GrabRelease(client, false, true);
        return;
    }

    // en vilo delante del coloso (GMod: ragdoll pegado a la mano derecha)
    float pos[3], dir[3];
    GetClientAbsOrigin(client, pos);
    Kolossos_GetMoveDir(client, dir);
    pos[0] += dir[0] * KOL_GRAB_HOLD_DIST;
    pos[1] += dir[1] * KOL_GRAB_HOLD_DIST;
    pos[2] += KOL_GRAB_HOLD_Z;
    TeleportEntity(victim, pos, NULL_VECTOR, NULL_VECTOR);

    // timeout del agarre (max 10s)
    if (now >= g_fKolGrabHoldEnd[client])
        Kolossos_GrabRelease(client, true, false);
}

// Z durante el agarre: puo (GMod l.2566-2630)
void Kolossos_GrabPunch(int client)
{
    int victim = EntRefToEntIndex(g_iKolGrabVictim[client]);
    if (victim <= 0 || !IsValidEntity(victim)) return;

    Kolossos_Emit(client, g_bKolSndPunch, "om/kolossos/kolossos punching.wav",
                  "physics/flesh/flesh_impact_hard3.wav");

    OM_AbilityDamage(victim, client, g_cvKolGrabPunchDmg.FloatValue);

    g_iKolGrabPunches[client]--;
    if (g_iKolGrabPunches[client] <= 0)
    {
        // combo completo: lanzamiento + pull out (GMod l.2623-2627)
        Kolossos_GrabRelease(client, true, false);
    }
    else
    {
        PrintCenterText(client, "Puo! Quedan %d", g_iKolGrabPunches[client]);
    }
}

// soltar: fling opcional + restaurar a la victima + CD
void Kolossos_GrabRelease(int client, bool fling, bool victimDied)
{
    int victim = EntRefToEntIndex(g_iKolGrabVictim[client]);
    g_iKolGrabVictim[client] = 0;

    if (victim > 0 && IsValidEntity(victim))
    {
        // restaurar movimiento
        if (victim <= MaxClients)
        {
            if (IsClientInGame(victim)) OM_Stun_Clear(victim);
        }
        else if (g_iKolGrabMoveType[client] > 0)
        {
            SetEntProp(victim, Prop_Data, "movetype", g_iKolGrabMoveType[client]);
        }

        // lanzamiento (fwd*500 + up*300 — la receta Rouge del suite)
        if (fling && IsClientInGame(client) && IsPlayerAlive(client))
        {
            float dir[3], push[3];
            Kolossos_GetMoveDir(client, dir);
            push[0] = dir[0] * KOL_GRAB_FLING_FWD;
            push[1] = dir[1] * KOL_GRAB_FLING_FWD;
            push[2] = KOL_GRAB_FLING_UP;
            TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, push);

            Kolossos_Emit(client, g_bKolSndPullOut, "om/kolossos/kol sting and pull out.wav",
                          "physics/flesh/flesh_impact_bullet1.wav");
        }
    }

    g_iKolGrabMoveType[client] = -1;

    float now = GetEngineTime();
    if (victimDied)
        g_fKolGrabCdUntil[client] = now + 2.0;                       // GMod: murio sola
    else
        g_fKolGrabCdUntil[client] = now + g_cvKolGrabCd.FloatValue;  // CD completo
}

// =====================================================================
//  [C] HABILIDAD 3 — INDICATOR (el peek: glow rojo sobre los infectados)
//  GMod l.458-549: durante IndicatorDuration todos los players/NPCs en
//  rango llevan el border indicator + pings; susurro al activar.
//  L4D2: sprites glow01 rojos sobre la cabeza, refresco a 10 Hz.
// =====================================================================

void Kolossos_Ability3(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    if (g_iKolChargeState[client] != KOL_CHG_IDLE
        || g_iKolGrabVictim[client] != 0
        || g_fKolLungeUntil[client] > now
        || g_fKolBlockUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolIndCdUntil[client])
    {
        PrintCenterText(client, "Indicator: %.1fs", g_fKolIndCdUntil[client] - now);
        return;
    }

    g_fKolIndUntil[client]    = now + g_cvKolIndDur.FloatValue;
    g_fKolIndCdUntil[client]  = now + g_cvKolIndCd.FloatValue;
    g_fKolIndNextPing[client] = now;

    // susurro del coloso (solo el jugador lo oye, como el GMod client-side)
    if (g_bKolSndWhisper)
        EmitSoundToClient(client, "om/kolossos/kol whispers.wav", client, _, KOL_SND_LEVEL);

    PrintCenterText(client, "INDICATOR!");
}

// el tick del indicator: mantener la nube de sprites sobre los vivos
void Kolossos_IndicatorThink(int client, float now)
{
    float pos[3];
    GetClientAbsOrigin(client, pos);
    float radius = g_cvKolIndRadius.FloatValue;

    // marcar quienes estan en rango (bitmap de este tick)
    static bool inRange[KOL_MAXENT + 1];
    for (int e = 1; e <= KOL_MAXENT; e++) inRange[e] = false;

    // 1) infectados especiales
    for (int t = 1; t <= MaxClients; t++)
    {
        if (!IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (radius > 0.0 && GetVectorDistance(tpos, pos) > radius) continue;
        inRange[t] = true;
    }

    // 2) commons
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (ent > KOL_MAXENT) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (radius > 0.0 && GetVectorDistance(epos, pos) > radius) continue;
        inRange[ent] = true;
    }

    // 3) witch
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (!IsValidEntity(w)) continue;
        if (w > KOL_MAXENT) continue;
        if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
        float wpos[3];
        GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
        if (radius > 0.0 && GetVectorDistance(wpos, pos) > radius) continue;
        inRange[w] = true;
    }

    // mantener la nube: crear/mover los que estan, matar los que salieron
    for (int e = 1; e <= KOL_MAXENT; e++)
    {
        if (!inRange[e])
        {
            if (g_iKolIndSprite[e] != 0)
            {
                int sp = EntRefToEntIndex(g_iKolIndSprite[e]);
                if (sp > 0 && IsValidEntity(sp)) AcceptEntityInput(sp, "Kill");
                g_iKolIndSprite[e] = 0;
            }
            continue;
        }

        float head[3];
        if (e <= MaxClients)
        {
            if (!IsClientInGame(e) || !IsPlayerAlive(e)) continue;
            GetClientAbsOrigin(e, head);
            head[2] += 72.0;
        }
        else
        {
            GetEntPropVector(e, Prop_Data, "m_vecOrigin", head);
            head[2] += 64.0;
        }

        int sp = EntRefToEntIndex(g_iKolIndSprite[e]);
        if (g_iKolIndSprite[e] != 0 && (sp <= 0 || !IsValidEntity(sp)))
        {
            g_iKolIndSprite[e] = 0;
            sp = -1;
        }

        if (sp <= 0)
            g_iKolIndSprite[e] = Kolossos_SpawnIndSprite(head);
        else
            SetEntPropVector(sp, Prop_Data, "m_vecOrigin", head);
    }

    // heartbeat del ping (cada 1s, solo para el coloso)
    if (now >= g_fKolIndNextPing[client])
    {
        g_fKolIndNextPing[client] = now + KOL_IND_PING_EVERY;
        if (g_bKolSndPing) EmitSoundToClient(client, "om/metal/ping1.wav", client, _, 60);
        else EmitSoundToClient(client, "buttons/button17.wav", client, _, 60);
    }
}

int Kolossos_SpawnIndSprite(const float pos[3])
{
    // glow01: sprite nativo (cero dependencia de assets del mod)
    int sp = CreateEntityByName("env_sprite");
    if (sp <= 0 || !IsValidEntity(sp)) return 0;

    DispatchKeyValue(sp, "model", "sprites/glow01.vmt");
    DispatchKeyValue(sp, "rendercolor", "255 32 32");
    DispatchKeyValue(sp, "rendermode", "5");      // additive
    DispatchKeyValue(sp, "renderamt", "255");
    DispatchKeyValue(sp, "scale", "0.6");
    DispatchKeyValue(sp, "GlowProxySize", "16");
    DispatchSpawn(sp);

    TeleportEntity(sp, pos, NULL_VECTOR, NULL_VECTOR);
    return EntIndexToEntRef(sp);
}

// fin del indicator: barrido completo de la nube
void Kolossos_IndicatorStop()
{
    for (int e = 1; e <= KOL_MAXENT; e++)
    {
        if (g_iKolIndSprite[e] == 0) continue;
        int sp = EntRefToEntIndex(g_iKolIndSprite[e]);
        if (sp > 0 && IsValidEntity(sp)) AcceptEntityInput(sp, "Kill");
        g_iKolIndSprite[e] = 0;
    }
}

void Kolossos_KillAllIndSprites() { Kolossos_IndicatorStop(); }

// =====================================================================
//  [B] HABILIDAD 4 — BLOCK (el parry del coloso + contragolpe de roca)
//  GMod l.2500-2536 (activacion: inmune + sin moverse 3.5s) + l.1253-
//  1271 (dano a 0 mientras bloquea) + l.1274+ (OM_AfterStunBlock: el
//  bloqueo se CONSUME con el golpe, gira al atacante y le devuelve
//  la roca rockgranite03b scale 3 en arco).
// =====================================================================

void Kolossos_Ability4(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    if (g_iKolChargeState[client] != KOL_CHG_IDLE
        || g_iKolGrabVictim[client] != 0
        || g_fKolLungeUntil[client] > now
        || g_fKolIndUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolBlockCdUntil[client])
    {
        PrintCenterText(client, "Block: %.1fs", g_fKolBlockCdUntil[client] - now);
        return;
    }

    float dur = g_cvKolBlockDur.FloatValue;
    g_fKolBlockUntil[client]     = now + dur;
    g_fKolBlockCdUntil[client]   = now + g_cvKolBlockCd.FloatValue;
    g_bKolBlockCountered[client] = false;

    // planta los pies (GMod: OM_NoMovement durante el bloqueo)
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);

    Kolossos_Emit(client, g_bKolSndBlock, "om/kolossos/kol block.wav",
                  "physics/metal/metal_solid_impact_bullet4.wav");

    PrintCenterText(client, "BLOQUEO!");
}

// fin del bloqueo (consumido por el counter o expirado)
void Kolossos_BlockEnd(int client)
{
    if (g_fKolBlockUntil[client] == 0.0) return;
    g_fKolBlockUntil[client] = 0.0;

    if (IsClientInGame(client) && IsPlayerAlive(client))
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
}

// el contragolpe: gira al atacante y devuelve la ROCA en arco
void Kolossos_BlockCounter(int client, int attacker)
{
    g_bKolBlockCountered[client] = true;

    if (!IsClientInGame(attacker) || !IsPlayerAlive(client)) return;

    // girar hacia el atacante (GMod l.1306-1309: angulo asignado)
    float apos[3], mpos[3], ang[3];
    GetClientAbsOrigin(attacker, apos);
    GetClientAbsOrigin(client, mpos);
    ang[0] = 0.0;
    ang[1] = RadToDeg(ArcTangent2(apos[1] - mpos[1], apos[0] - mpos[0]));
    ang[2] = 0.0;
    TeleportEntity(client, NULL_VECTOR, ang, NULL_VECTOR);

    Kolossos_SpawnCounterRock(client, apos);
}

// la roca: prop_physics con velocidad balistica (travelTime 0.5, peak 150)
void Kolossos_SpawnCounterRock(int client, const float targetPos[3])
{
    if (!g_bKolRockModel)
    {
        // sin la roca nativa: dano directo al atacante (fallback honesto)
        return;
    }

    int rock = CreateEntityByName("prop_physics_override");
    if (rock <= 0 || !IsValidEntity(rock)) return;

    char scaleStr[8];
    FloatToString(g_cvKolRockScale.FloatValue, scaleStr, sizeof(scaleStr));

    DispatchKeyValue(rock, "model", "models/props_wasteland/rockgranite03b.mdl");
    DispatchKeyValue(rock, "targetname", "kolossos_rock_om");
    DispatchKeyValue(rock, "modelscale", scaleStr);
    DispatchSpawn(rock);

    // origen: a los pies del coloso (GMod l.1461: GetPos() - 30z)
    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] -= 30.0;
    TeleportEntity(rock, pos, NULL_VECTOR, NULL_VECTOR);

    // velocidad balistica: t=0.5s, gravedad 800 (GMod travelTime/peakHeight)
    float t = KOL_ROCK_ARC_TIME;
    float g = 800.0;
    float dz = (targetPos[2] + 20.0) - pos[2] + KOL_ROCK_ARC_PEAK;
    float vel[3];
    vel[0] = (targetPos[0] - pos[0]) / t;
    vel[1] = (targetPos[1] - pos[1]) / t;
    vel[2] = dz / t + 0.5 * g * t;
    TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, vel);

    // al tocar: dano en area alrededor del punto de impacto
    SDKHook(rock, SDKHook_StartTouch, Kolossos_RockTouch);

    // watchdog: si no toco nada en 3s, muere sola
    CreateTimer(KOL_ROCK_LIFETIME, Kolossos_T_RockKill, EntIndexToEntRef(rock));

    Kolossos_Emit(client, g_bKolSndRumble, "om/kolossos/kol charge start ground rumble.wav",
                  "ambient/machines/thumper_hit.wav");
}

// impacto de la roca: dano en radio a lo que este cerca
// (REGLA v3.77.85: SNAPSHOT primero, dano fuera de los bucles)
public void Kolossos_RockTouch(int rock, int other)
{
    float pos[3];
    GetEntPropVector(rock, Prop_Data, "m_vecOrigin", pos);
    float dmg = g_cvKolRockDmg.FloatValue;

    // buscar al Kolossos dueno de la roca (por targetname es suya toda)
    int owner = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (Kolossos_PlayerIs(i)) { owner = i; break; }
    }

    int   snapEnts[64];
    bool  snapIsSI[64];
    int   snapCount = 0;

    // commons — snapshot
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(ent) || ent == other) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (GetVectorDistance(epos, pos) > KOL_ROCK_TOUCH_RADIUS) continue;
        snapEnts[snapCount] = ent;
        snapIsSI[snapCount] = false;
        snapCount++;
    }

    // infectados especiales — snapshot
    for (int t = 1; t <= MaxClients && snapCount < 64; t++)
    {
        if (t == owner || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (GetVectorDistance(tpos, pos) > KOL_ROCK_TOUCH_RADIUS) continue;
        snapEnts[snapCount] = t;
        snapIsSI[snapCount] = true;
        snapCount++;
    }

    // witch — snapshot
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(w)) continue;
        if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
        float wpos[3];
        GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
        if (GetVectorDistance(wpos, pos) > KOL_ROCK_TOUCH_RADIUS) continue;
        snapEnts[snapCount] = w;
        snapIsSI[snapCount] = false;
        snapCount++;
    }

    // EL DAÑO VA AQUI — fuera de los bucles, re-validando
    for (int k = 0; k < snapCount; k++)
    {
        int v = snapEnts[k];
        if (v <= 0 || !IsValidEntity(v)) continue;
        if (snapIsSI[k] && v <= MaxClients)
        {
            if (!IsClientInGame(v) || !IsPlayerAlive(v)) continue;
        }
        else if (v > MaxClients)
        {
            if (GetEntProp(v, Prop_Data, "m_iHealth") <= 0) continue;
        }
        SDKHooks_TakeDamage(v, owner, owner, dmg, DMG_CLUB);
    }

    AcceptEntityInput(rock, "Kill");
}

public Action Kolossos_T_RockKill(Handle timer, int ref)
{
    int rock = EntRefToEntIndex(ref);
    if (rock > 0 && IsValidEntity(rock))
    {
        SDKUnhook(rock, SDKHook_StartTouch, Kolossos_RockTouch);
        AcceptEntityInput(rock, "Kill");
    }
    return Plugin_Stop;
}

// =====================================================================
//  DAÑO ENTRANTE: resistencia pasiva + inmunidad del bloqueo + counter
// =====================================================================

public Action Kolossos_OnTakeDamage(int victim, int &attacker, int &inflictor,
                                    float &damage, int &damagetype, int &weapon,
                                    float damageForce[3], float damagePosition[3],
                                    int damagecustom)
{
    if (!Kolossos_PlayerIs(victim)) return Plugin_Continue;

    // ---- bloqueo activo: dano de infectados a CERO (GMod l.1256-1261) ----
    if (g_fKolBlockUntil[victim] > GetEngineTime())
    {
        bool infectedAttacker = false;
        if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
            infectedAttacker = (GetClientTeam(attacker) == 3);
        else if (attacker > MaxClients && IsValidEntity(attacker))
        {
            char cls[16];
            GetEntityClassname(attacker, cls, sizeof(cls));
            infectedAttacker = (StrEqual(cls, "infected") || StrEqual(cls, "witch"));
        }

        if (infectedAttacker)
        {
            damage = 0.0;

            // el PRIMER golpe consuma el bloqueo y dispara el counter
            if (!g_bKolBlockCountered[victim] && attacker > 0)
            {
                Kolossos_BlockEnd(victim);
                Kolossos_BlockCounter(victim, attacker);
            }
            return Plugin_Changed;
        }
    }

    // ---- resistencia pasiva (kolossos_resistance 100 = neutro) ----
    float resist = g_cvKolResist.FloatValue;
    if (resist < 99.5 && resist > 0.0)
    {
        damage *= resist / 100.0;
        return Plugin_Changed;
    }

    return Plugin_Continue;
}

// =====================================================================
//  RUNCMD: auto-forward de la avalancha (receta Metal v5.0)
// =====================================================================

public bool Kolossos_OnPlayerRunCmd(int client, int &buttons, float vel[3])
{
    if (!Kolossos_PlayerIs(client)) return false;
    if (!IsPlayerAlive(client)) return false;

    // durante el WINDUP: clavado en el sitio
    if (g_iKolChargeState[client] == KOL_CHG_WINDUP)
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);
        return false;
    }

    if (g_iKolChargeState[client] != KOL_CHG_DASH) return false;

    // forwardmove saturado (el engine clampea al m_flMaxspeed del stack)
    vel[0] = KOL_DASH_VEL_INJECT;
    vel[1] = 0.0;
    if (vel[2] < 0.0) vel[2] = 0.0;
    return true;
}

// =====================================================================
//  FSM CENTRAL (10 Hz — patron T_BlazeAvatarThink)
// =====================================================================

public Action T_KolossosThink(Handle timer)
{
    float now = GetEngineTime();

    // el indicator es global (una sola nube a la vez por simplicidad):
    // buscar al Kolossos que lo tiene activo
    int indOwner = 0;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Kolossos_KillAvatar(i); continue; }

        bool esKolViva = (Kolossos_PlayerIs(i) && IsPlayerAlive(i)
                          && GetClientTeam(i) == 2);

        // incap = cancel suave (la FSM re-monta al levantarse)
        if (esKolViva && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            esKolViva = false;

        // ---- EL TICK DEL KIT ----
        if (esKolViva)
        {
            if (OM_IsStunned(i))
            {
                // aturdido: cancelar todo (no pelear contra el stun)
                if (g_iKolChargeState[i] != KOL_CHG_IDLE) Kolossos_ChargeEnd(i, false);
                if (g_iKolGrabVictim[i] != 0) Kolossos_GrabRelease(i, false, false);
                if (g_fKolBlockUntil[i] > 0.0) Kolossos_BlockEnd(i);
            }
            else
            {
                // auto-gestion: hook de dano + vida max UNA vez por vida
                // (cubre tambien la eleccion a mitad de ronda via menu)
                if (!g_bKolHooked[i])
                {
                    g_bKolHooked[i] = true;
                    SDKUnhook(i, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
                    SDKHook(i, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
                }
                if (!g_bKolHpApplied[i])
                {
                    g_bKolHpApplied[i] = true;
                    Kolossos_ApplyMaxHealth(i);
                }

                // charge: windup (lagged 0) / dash (impacto + watchdog)
                if (g_iKolChargeState[i] == KOL_CHG_DASH)
                    Kolossos_ChargeDashThink(i, now);
                else if (g_iKolChargeState[i] == KOL_CHG_WINDUP
                         && now >= g_fKolWindupStart[i] + KOL_CHG_WINDUP_T)
                {
                    // safety: los timers del windup se perdieron (mapchange)
                    Kolossos_ChargeLaunch(i);
                }

                // grab: ventana del lunge / victima en vilo
                if (g_fKolLungeUntil[i] > now)
                    Kolossos_GrabLungeThink(i, now);
                else if (g_iKolGrabVictim[i] != 0)
                    Kolossos_GrabHoldThink(i, now);

                // block: expiracion natural
                if (g_fKolBlockUntil[i] > 0.0 && now >= g_fKolBlockUntil[i])
                    Kolossos_BlockEnd(i);

                // indicator
                if (g_fKolIndUntil[i] > now) indOwner = i;
            }
        }
        else
        {
            // no es Kolossos vivo: limpiar estado si quedo algo
            if (g_iKolChargeState[i] != KOL_CHG_IDLE) Kolossos_ChargeEnd(i, false);
            if (g_iKolGrabVictim[i] != 0) Kolossos_GrabRelease(i, false, false);
            if (g_fKolBlockUntil[i] > 0.0) Kolossos_BlockEnd(i);
            if (g_fKolIndUntil[i] > 0.0)   g_fKolIndUntil[i] = 0.0;
        }

        // ---- montaje del avatar ----
        if (g_iKolAvatar[i] == 0)
        {
            if (esKolViva && g_cvKolAvatar != null && g_cvKolAvatar.BoolValue
                && g_bKolModelOK)
            {
                Kolossos_CreateAvatar(i);
            }
            continue;
        }

        if (!esKolViva)
        {
            Kolossos_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iKolAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iKolAvatar[i] = 0;
            g_iKolAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (fix Tails v5.4)
        if (g_iKolBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparacion de la copia L
        if (g_iKolAvatarL[i] == 0 && g_iKolAvatar[i] != 0)
        {
            Kolossos_CreateAvatarL(i);
            if (g_iKolAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // FSM de animacion
        av = EntRefToEntIndex(g_iKolAvatar[i]);
        if (g_iKolAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Kolossos_AvatarUpdate(i, av, now);
    }

    // la nube del indicator vive mientras su dueno la tenga activa
    if (indOwner != 0)
        Kolossos_IndicatorThink(indOwner, now);
    else
        Kolossos_IndicatorStop();

    return Plugin_Continue;
}

// =====================================================================
//  DEBUG
// =====================================================================

public Action Kolossos_CmdDebug(int client, int args)
{
    client = Sonic_SoloClient(client);
    if (!IsValidClient(client)) return Plugin_Handled;

    float now = GetEngineTime();
    PrintToConsole(client, "=== Kolossos v%s ===", KOLOSSOS_INC_VERSION);
    PrintToConsole(client, "Personaje: %s | Vida: %d/%d",
                   Kolossos_PlayerIs(client) ? "SI" : "NO",
                   GetClientHealth(client),
                   GetEntProp(client, Prop_Data, "m_iMaxHealth"));
    PrintToConsole(client, "Modelo: %s | Avatar R: %s | L: %s",
                   g_bKolModelOK ? "OK" : "FALTA",
                   g_iKolAvatar[client] != 0 ? "vivo" : "-",
                   g_iKolAvatarL[client] != 0 ? "vivo" : "-");
    PrintToConsole(client, "Charge: estado %d | fin %.1f | CD %.1f",
                   g_iKolChargeState[client],
                   g_fKolChargeEnd[client] - now,
                   g_fKolChargeCdUntil[client] - now);
    PrintToConsole(client, "Grab: victima %d | puos %d | lunge %.1f | CD %.1f",
                   g_iKolGrabVictim[client] != 0 ? EntRefToEntIndex(g_iKolGrabVictim[client]) : -1,
                   g_iKolGrabPunches[client],
                   g_fKolLungeUntil[client] - now,
                   g_fKolGrabCdUntil[client] - now);
    PrintToConsole(client, "Block: %.1f | Indicator: %.1f",
                   g_fKolBlockUntil[client] - now,
                   g_fKolIndUntil[client] - now);
    PrintToChat(client, "\x04[Kolossos]\x01 Estado en consola (sm_kolossos).");
    return Plugin_Handled;
}
