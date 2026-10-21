/*
 * ======================================================
 *  [MODULO] Sage — CLASE EXCLUSIVA DE ADMINS v2.1 (R28.1)
 *
 *  v2.1 - RONDA 28.1 "PEQUEOs FIXES": pedido del owner:
 *  "3 el change de habilidades no tendrá CD en si".
 *  - Sage_SwapSet (tecla C / sm_sageset) SIN anti-spam: el CD
 *    de 3s se retira junto a su estado (g_fSageSwapNext /
 *    SAGE_SWAP_CD). Ciclar sets rápido es intencional — mismo
 *    criterio v3.61 del cambio de modo de Amy: "es preferencia,
 *    no ataque".
 *  - FIX sonido (junto a Sally v6.1): Sage_CastTeamShield ya NO
 *    re-emite el FIRE_START/WATER_START desde Sage — ella TAMBIÉN
 *    recibe su escudo en el reparto (t == client) y el doble-emit
 *    apilaba 2 instancias del mismo sample: una sobrevivia al
 *    StopSound y "el sonido del escudo seguía sonando" tras
 *    romperse/expirar. Cada receptor (Sage incluida) emite el suyo
 *    UNA vez vía Sally_EffectStart/BubbleStart en el canal propio.
 *
 *  v2 - RONDA 28 "SETS SALLY Y ROUGE": pedido del owner:
 *  "podriamos colocar que sage si usa a sally ella puede darle
 *  escudos de agua o escudos fuegos a todo el equipo (obiamente
 *  duraran un tiempo como siempre ha durado) la de ella durara 5 seg
 *  más antes de desaparecer. Se añadira el estilo rouge con sus
 *  granadas."
 *
 *  - SAGE_SETS 2 -> 4. La C cicla: AMY -> CREAM -> SALLY -> ROUGE.
 *  - SET SALLY: Z = ESCUDO DE AGUA a todo el equipo | X = ESCUDO DE
 *    FUEGO. Duración estándar (la "de siempre", legacy Sally: agua
 *    15s / fuego 20s) y el de la PROPIA SAGE dura +5s. La Sally real
 *    queda fuera del reparto (sus escudos propios ya son permanentes)
 *    y nadie puede tener 2 escudos a la vez (XOR de Sally).
 *    Activación = mismo estado interno de Sally.inc v6 (absorb,
 *    regen, aura de dano/quemado, dash, caida rebotona, explosión al
 *    romperse); expiración por el timer propio de este modulo.
 *  - SET ROUGE: Z = CEBO QUIMICO | X = BAT BOMB SPRAY. Rouge.inc
 *    acepta a Sage con set ROUGE en sus 2 comandos de granada. Las
 *    pasivas de Rouge (evasión, planeo, no-caida) NO se prestan.
 *  - ConVars: sagesally_water_cd (20) / sagesally_fire_cd (35) /
 *    sagesally_water_dur (15) / sagesally_fire_dur (20) /
 *    sagesally_sage_bonus (5).
 *
 *  v1 - LA CLASE SAGE (ronda 26, pedido del owner): "Sage es una
 *  clase exclusiva de ADM por lo que se me ocurrio la idea de
 *  Extender las habilidades de 2 a 4 movimientos (ojo aún todos
 *  usaran sus movimientos 2 pero sage por el momento tendrá 3.
 *  Ahora que hace el 3? su habilidad 3 le permite cambiar sus 2
 *  habilidades por otro set diferente. sage tendrá La habilidad
 *  de usar el set de movimientos de los personajes más fuertes
 *  que por el momento la que tiene eso es Amy (quizás sonic no
 *  se o sally)".
 *
 *  ESTRUCTURA (marco de 4 slots, hoy usa 3):
 *   - SLOT 1 (Z): el del set activo.
 *   - SLOT 2 (X): el del set activo.
 *   - SLOT 3 (C): CAMBIO DE SET (sm_sjs_ability3 / sm_sageset):
 *     cicla el set prestado. Hoy: AMY y CREAM (soporte); el marco
 *     está listo para colgar SONIC/SALLY cuando existan.
 *   - SLOT 4 (V): RESERVADO — "después haremos su modo propio
 *     (que tendrá las 4 habilidades slot anteriormente dichas)".
 *
 *  SET AMY (default — "los personajes más fuertes"):
 *   - Z: GOLPE EN ÁREA de martillo (AOE 360). "únicamente el golpe
 *     en área de martillo y NO el impulso": la embestida de Amy NO
 *     viaja con Sage (modo clavado a 1 en Amy.inc v89).
 *   - X: CARTAS DEL TAROT (Command_RandomPower de Amy, con el
 *     anti-FF de siempre: SetAmyMode + ventana de 12s).
 *   - La aura de objetos (v89) la ENCIENDE y la VE (clones de aura
 *     transmitidos solo a Amy/Sage).
 *
 *  SET CREAM — "el apartado de soporte" (Cream v6):
 *   - Z: CURA de área MEJORADA (móvil, sin interrupción).
 *   - X: REVIVIR con cooldown de 30s ("Para sage ella solo esperara
 *     30 seg"; Cream espera 120).
 *   - REGENERACION pasiva (1 HP / 2s — vive en Cream_PreThink).
 *
 *  ANTI-FF DEL SET PRESTADO: el tracker de props de Amy atribuye
 *  "AMY" a CUALQUIER lanzador del kit (Amy_PropTrack) — lo que
 *  lanza Sage NO lastima survivors. El vscript del martillo se
 *  parchea aparte (::SonicSageIdx, Lanzamiento de martillo v4).
 *
 *  SELECCION: solo ADMINS (menú del manager, gate
 *  IsClientSageAllowed == CheckCommandAccess "sj_sage").
 * ======================================================
 */

#if defined _Sage_included
    #endinput
#endif
#define _Sage_included

#if !defined _sourcemod_included
    #include <sourcemod>
#endif
#if !defined _sdktools_included
    #include <sdktools>
#endif

#define SAGE_INC_VERSION   "v2.1"

// v2 (R28): 4 sets registrados. La tecla C (Sage_SwapSet) los cicla
// solos: AMY (fuerte) -> CREAM (soporte) -> SALLY (escudos) -> ROUGE
// (granadas) -> AMY.
#define SAGE_SETS          4
// v2.1 (R28.1) FIX 3: SAGE_SWAP_CD (3s anti-spam) ELIMINADO — pedido
// del owner: "el change de habilidades no tendrá CD en si".

// nombres de los sets (feedback al ciclar)
static const char g_sSageSetNames[SAGE_SETS][20] =
{
    "AMY (fuerte)",
    "CREAM (soporte)",
    "SALLY (escudos)",      // v2 (R28): escudos de agua/fuego al equipo
    "ROUGE (granadas)"      // v2 (R28): cebo quimico + bat bomb
};

bool  g_bSageHintShown[MAXPLAYERS + 1];      // pista de spawn (1 vez por sesión)

// =======================
// v2 (R28): SET SALLY — escudos de equipo regalados
// =======================
// Los flags de regalo en si (g_bSageGiftWater / g_bSageGiftFire /
// g_fSageGift*End) viven en el MANAGER (antes de los includes) porque
// Sally.inc los lee para relajar sus gates de escudo. Aquí viven los
// ConVars del cast, los CDs y el timer de expiración.
ConVar g_cvSageSallyWaterCD;
ConVar g_cvSageSallyFireCD;
ConVar g_cvSageSallyWaterDur;
ConVar g_cvSageSallyFireDur;
ConVar g_cvSageSallySageBonus;

float  g_fSageSallyWaterNext[MAXPLAYERS + 1];    // próximo cast de agua
float  g_fSageSallyFireNext[MAXPLAYERS + 1];     // próximo cast de fuego
Handle g_hSageGiftTimer = null;                  // expiración de regalos

#define Sage_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// INICIALIZACION
// =======================

public void Sage_OnPluginStart()
{
    // comando manual (además de la tecla C vía sm_sjs_ability3 del manager)
    RegConsoleCmd("sm_sageset", Sage_CommandSet, "Sage: cicla el set de movimientos prestado (AMY / CREAM / SALLY / ROUGE)");
    RegConsoleCmd("sm_sage", Sage_CommandSet, "Alias corto de sm_sageset");

    // v2 (R28): set SALLY — escudos de equipo. Duraciones "como
    // siempre ha durado" = los legacy de Sally (agua 15s / fuego 20s)
    // y "la de ella durara 5 seg más" = sagesally_sage_bonus.
    g_cvSageSallyWaterCD   = CreateConVar("sagesally_water_cd",  "20.0", "Recarga del escudo de AGUA de equipo (set SALLY de Sage).", _, true, 1.0,  true, 300.0);
    g_cvSageSallyFireCD    = CreateConVar("sagesally_fire_cd",   "35.0", "Recarga del escudo de FUEGO de equipo (set SALLY de Sage).", _, true, 1.0,  true, 300.0);
    g_cvSageSallyWaterDur  = CreateConVar("sagesally_water_dur", "15.0", "Duración del escudo de AGUA regalado a cada compañero (legacy Sally).", _, true, 3.0,  true, 120.0);
    g_cvSageSallyFireDur   = CreateConVar("sagesally_fire_dur",  "20.0", "Duración del escudo de FUEGO regalado a cada compañero (legacy Sally).", _, true, 3.0,  true, 120.0);
    g_cvSageSallySageBonus = CreateConVar("sagesally_sage_bonus", "5.0", "Segundos extra del escudo de la PROPIA Sage (la de ella dura 5 seg más).", _, true, 0.0,  true, 60.0);
}

public void Sage_OnMapStart()
{
    // estado de slots a cero (mapa nuevo: sets se olvidan)
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iSageActiveSet[i] = SAGESET_NONE;
        g_bSageHintShown[i] = false;
        Sage_GiftClearClient(i);
    }

    // v2 (R28): muere el timer de expiración; los escudos activos los
    // apaga T_SallyThink al detectar muertos/equipos fuera de combate
    if (g_hSageGiftTimer != null)
    {
        KillTimer(g_hSageGiftTimer);
        g_hSageGiftTimer = null;
    }
}

public void Sage_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;
    g_iSageActiveSet[client] = SAGESET_NONE;
    g_bSageHintShown[client] = false;
    // v2 (R28): un cliente que se fue perdió su escudo (T_SallyThink
    // lo apaga); su bandera de regalo stale baja aquí
    Sage_GiftClearClient(client);
}

// =======================
// VSCRIPT: ::SonicSageIdx (el martillo lanzable reconoce a Sage)
// =======================
//  El addon "Lanzamiento de martillo v4" acepta a ::SonicAmyIdx O
//  ::SonicSageIdx como lanzadores legales de melees (skin-proof).
//  Publicar al spawn y anular al morir/cambiar (mismo patron que el
//  ::SonicAmyIdx de Amy: un índice reciclado no lanza nada).
void Sage_PublishScriptIdx(int client, bool isSage)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    int runner = Amy_FindScriptRunner();
    if (runner == -1 || !IsValidEntity(runner)) return;

    char code[96];
    if (isSage)
        Format(code, sizeof(code), "::SonicSageIdx <- %d", client);
    else
        Format(code, sizeof(code),
               "if(\"SonicSageIdx\" in getroottable() && ::SonicSageIdx == %d) ::SonicSageIdx <- -1",
               client);

    SetVariantString(code);
    AcceptEntityInput(runner, "RunScriptCode");
}

// =======================
// CICLO DE VIDA
// =======================

// spawn (llamado desde Event_PlayerSpawn del manager)
public void Sage_Event_PlayerSpawn(int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] != SAGE_INDEX) return;

    // set válido (NONE o corrupto -> AMY, el set "de los más fuertes")
    if (g_iSageActiveSet[client] < 0 || g_iSageActiveSet[client] >= SAGE_SETS)
        g_iSageActiveSet[client] = SAGESET_AMY;

    // la Z de Sage es GOLPE EN ÁREA FIJO (Amy.inc v89 lo reafirma en
    // cada pulsación; aquí se deja bien puesto desde el spawn)
    g_iAmyAbilityMode[client] = 1;

    // publicar el índice al vscript del martillo (independiente del
    // ::SonicAmyIdx de Amy: conviven sin pisarse)
    Sage_PublishScriptIdx(client, true);

    // el aura de objetos (v89) también se enciende con Sage viva
    Amy_VisionEnsureTimer();

    if (!g_bSageHintShown[client])
    {
        g_bSageHintShown[client] = true;
        PrintToChat(client, "\x04[SAGE]\x01 Clase de \x05ADM\x01. \x03C\x01 = CAMBIAR DE SET (Z/X cambian con el). El aura de objetos SOLO la ves tu (y Amy).");
        Sage_AnnounceSet(client);
    }
}

// muerte (llamado desde Event_PlayerDeath del manager): el set se
// CONSERVA (respawnea con su build); el índice vscript se anula
public void Sage_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != SAGE_INDEX) return;
    Sage_PublishScriptIdx(client, false);
}

// cambio de personaje / disconnect (CleanupCharModuleState): reset TOTAL
public void Sage_ResetState(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != SAGE_INDEX) return;
    Sage_PublishScriptIdx(client, false);
    g_iSageActiveSet[client] = SAGESET_NONE;
    g_bSageHintShown[client] = false;
}

// =======================
// HABILIDAD 3 (tecla C): CAMBIO DE SET
// =======================

public Action Sage_CommandSet(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Sage_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != SAGE_INDEX)
    {
        PrintToChat(client, "\x04[Sage]\x01 El cambio de set es exclusivo de la clase Sage (ADM).");
        return Plugin_Handled;
    }
    return Sage_SwapSet(client);
}

// el manager cablea sm_sjs_ability3 (tecla C) directamente aquí
Action Sage_SwapSet(int client)
{
    // v2.1 (R28.1) FIX 3 - pedido del owner: "el change de habilidades
    // no tendrá CD en si". El anti-spam de 3s y su estado se retiran:
    // ciclar rápido con la C es intencional (es preferencia, no
    // ataque — mismo criterio v3.61 del cambio de modo de Amy).
    int next = g_iSageActiveSet[client] + 1;
    if (next < 0 || next >= SAGE_SETS) next = SAGESET_AMY;
    g_iSageActiveSet[client] = next;

    // la Z prestada de Amy sigue siendo AOE FIJO en cualquier caso
    g_iAmyAbilityMode[client] = 1;

    Sage_AnnounceSet(client);
    return Plugin_Handled;
}

void Sage_AnnounceSet(int client)
{
    switch (g_iSageActiveSet[client])
    {
        case SAGESET_CREAM:
        {
            PrintToChat(client, "\x04[SAGE]\x01 SET \x05%s\x01: Z = \x03CURA\x01 (móvil, sin interrupción) | X = \x03REVIVIR\x01 (\x0530s\x01 de recarga) | \x03REGENERACION\x01 pasiva.", g_sSageSetNames[SAGESET_CREAM]);
        }
        case SAGESET_SALLY:
        {
            PrintToChat(client, "\x04[SAGE]\x01 SET \x05%s\x01: Z = \x03ESCUDO DE AGUA\x01 a TODO el equipo (\x05%.0fs\x01, el tuyo \x05+%.0fs\x01) | X = \x03ESCUDO DE FUEGO\x01 (\x05%.0fs\x01: aura que quema y empuja). La Sally real no recibe: los suyos son permanentes.",
                g_sSageSetNames[SAGESET_SALLY], g_cvSageSallyWaterDur.FloatValue, g_cvSageSallySageBonus.FloatValue, g_cvSageSallyFireDur.FloatValue);
        }
        case SAGESET_ROUGE:
        {
            PrintToChat(client, "\x04[SAGE]\x01 SET \x05%s\x01: Z = \x03CEBO QUIMICO\x01 (granada rosa + charco de acido, \x05%.0fs\x01) | X = \x03BAT BOMB SPRAY\x01 (abanico de 3 bombas, \x05%.0fs\x01). Sin la evasión pasiva de Rouge: solo sus granadas.",
                g_sSageSetNames[SAGESET_ROUGE], g_cvRougeBaitCD.FloatValue, g_cvRougeBombCD.FloatValue);
        }
        default:
        {
            PrintToChat(client, "\x04[SAGE]\x01 SET \x05%s\x01: Z = \x03GOLPE EN ÁREA\x01 (martillo 360, \x04SIN impulso\x01) | X = \x03CARTAS DEL TAROT\x01. El impulso/embestida es exclusivo de Amy.", g_sSageSetNames[SAGESET_AMY]);
        }
    }
}

// ======================================================================
// v2 (R28): SET SALLY — CAST DE ESCUDOS DE EQUIPO + EXPIRACION
// ======================================================================

// activa el escudo de Sally en un receptor SIN pasar por los comandos
// exclusivos de ella: mismo estado interno -> mismo comportamiento
// (absorb en OnTakeDamage, regen/aura por T_SallyThink, dash/bounce
// por Sally_OnPlayerRunCmd, explosión al romperse). Devuelve true si
// el escudo quedó activo (Sage.inc lo usa para contar entregados).
bool Sage_GiveShieldTo(int target, bool fire, float duration)
{
    if (fire)
    {
        g_bShieldActive[target] = true;
        g_fFireShieldHP[target] = g_cvSallyFireMaxHP.FloatValue;
        g_fShieldNextTick[target] = 0.0;
        g_fFireBoostNextUse[target] = 0.0;
        g_bFireBoostActive[target] = false;
        CreateSallyFireBarrier(target);
        Sally_EffectStart(target);
        g_bSageGiftFire[target] = true;
        g_fSageGiftFireEnd[target] = GetEngineTime() + duration;

        PrintToChat(target, "\x04[Sage]\x05 Escudo de FUEGO regalado\x01 (\x05%.0fs\x01): absorbe \x04%.0f\x01 + aura que quema/empuja. CTRL en el aire = dash.",
            duration, g_fFireShieldHP[target]);
    }
    else
    {
        g_bBubbleActive[target] = true;
        g_fWaterShieldHP[target] = g_cvSallyWaterMaxHP.FloatValue;
        g_fWaterNextRegenTick[target] = GetEngineTime() + g_cvSallyWaterRegenInterval.FloatValue;
        g_iBubbleCombo[target] = 0;
        g_bBubbleDrop[target] = false;
        g_fBubbleLastBounceTime[target] = 0.0;
        CreateSallyBubbleBarrier(target);
        Sally_EffectBubbleStart(target);
        g_bSageGiftWater[target] = true;
        g_fSageGiftWaterEnd[target] = GetEngineTime() + duration;

        PrintToChat(target, "\x04[Sage]\x05 Escudo de AGUA regalado\x01 (\x05%.0fs\x01): absorbe \x04%.0f\x01 + regen \x04+%d HP/%.1fs\x01. CTRL en el aire = caida rebotona.",
            duration, g_fWaterShieldHP[target], g_cvSallyWaterRegenAmount.IntValue, g_cvSallyWaterRegenInterval.FloatValue);
    }
    return true;
}

// cast principal del set SALLY (Z = agua, X = fuego; el manager rutea)
Action Sage_CastTeamShield(int client, bool fire)
{
    if (!Sage_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != SAGE_INDEX) return Plugin_Handled;
    if (g_iSageActiveSet[client] != SAGESET_SALLY)
    {
        PrintCenterText(client, "Escudos de equipo: requieren el set SALLY (C = cambiar set).");
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    float cd  = fire ? g_fSageSallyFireNext[client] : g_fSageSallyWaterNext[client];
    if (now < cd)
    {
        char tipo[8];
        if (fire) strcopy(tipo, sizeof(tipo), "FUEGO");
        else      strcopy(tipo, sizeof(tipo), "AGUA");
        PrintCenterText(client, "ESCUDO %s: recarga %.1fs", tipo, cd - now);
        return Plugin_Handled;
    }

    int given = 0, skipped = 0;
    for (int t = 1; t <= MaxClients; t++)
    {
        if (!IsClientInGame(t) || !IsPlayerAlive(t) || GetClientTeam(t) != 2) continue;

        // la Sally real administra sus escudos propios (permanentes):
        // fuera del reparto para no pisarle cooldowns ni toggles
        if (g_iPlayerCharIdx[t] == SALLY_INDEX) { skipped++; continue; }

        // XOR de Sally: con CUALQUIER escudo activo (propio o regalo
        // anterior sin expirar) la persona se salta. No se apilan.
        if (g_bShieldActive[t] || g_bBubbleActive[t]) { skipped++; continue; }

        float dur = (fire ? g_cvSageSallyFireDur.FloatValue : g_cvSageSallyWaterDur.FloatValue)
                  + ((t == client) ? g_cvSageSallySageBonus.FloatValue : 0.0);

        if (Sage_GiveShieldTo(t, fire, dur)) given++;
    }

    // feedback visual del cast (la onda sale de Sage)
    // v2.1 (R28.1) FIX sonido: SIN EmitSound del START desde Sage —
    // ella TAMBIÉN recibe escudo en el reparto (t == client) y cada
    // receptor ya emite su Sally_EffectStart/BubbleStart en el canal
    // propio. El doble-emit apilaba 2 instancias y una sobrevivia al
    // StopSound ("el sonido del escudo seguía sonando").
    float pos[3]; GetClientAbsOrigin(client, pos);
    int ring = PrecacheModel(SALLY_PARTICLE_RING);
    int ringColor[4];
    if (fire) { ringColor[0] = 255; ringColor[1] = 100; ringColor[2] = 30;  ringColor[3] = 255; }
    else      { ringColor[0] = 0;   ringColor[1] = 255; ringColor[2] = 255; ringColor[3] = 255; }
    TE_SetupBeamRingPoint(pos, 10.0, 600.0, ring, 0, 0, 0, 0.6, 18.0, 0.0, ringColor, 0, 0);
    TE_SendToAll();

    if (given <= 0)
    {
        // cast fallido (todos con escudo o fuera de combate): sin CD
        PrintToChat(client, "\x04[SAGE]\x01 Nadie pudo recibir el escudo (todos con escudo activo o fuera de combate). \x05Sin recarga consumida\x01.");
        return Plugin_Handled;
    }

    if (fire) g_fSageSallyFireNext[client]  = now + g_cvSageSallyFireCD.FloatValue;
    else      g_fSageSallyWaterNext[client] = now + g_cvSageSallyWaterCD.FloatValue;

    Sage_GiftEnsureTimer();

    char tipo2[12];
    if (fire) strcopy(tipo2, sizeof(tipo2), "de FUEGO");
    else      strcopy(tipo2, sizeof(tipo2), "de AGUA");
    PrintToChat(client, "\x04[SAGE]\x05 Escudo %s de EQUIPO\x01: \x03%d\x01 lo reciben (\x05%.0fs\x01 cada uno; el tuyo \x05%.0fs\x01). Saltados: \x05%d\x01.",
        tipo2, given,
        fire ? g_cvSageSallyFireDur.FloatValue : g_cvSageSallyWaterDur.FloatValue,
        (fire ? g_cvSageSallyFireDur.FloatValue : g_cvSageSallyWaterDur.FloatValue) + g_cvSageSallySageBonus.FloatValue,
        skipped);
    return Plugin_Handled;
}

// el timer de expiración vive mientras haya regalos pendientes
void Sage_GiftEnsureTimer()
{
    if (g_hSageGiftTimer == null)
        g_hSageGiftTimer = CreateTimer(1.0, T_SageGiftTick, _, TIMER_REPEAT);
}

// 1s: apaga los escudos regalados al vencer su tiempo. Si el escudo
// ya se apago solo (roto por dano, toggleado por la Sally real o el
// jugador murió), solo baja la bandera. Los escudos de la SALLY REAL
// nunca pasan por aquí (no llevan bandera de regalo).
public Action T_SageGiftTick(Handle timer)
{
    bool any = false;
    float now = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_bSageGiftWater[i])
        {
            if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2 || !g_bBubbleActive[i])
            {
                g_bSageGiftWater[i] = false;
            }
            else if (now >= g_fSageGiftWaterEnd[i])
            {
                Sally_StopBubble(i);
                g_bSageGiftWater[i] = false;
                if (IsClientInGame(i)) PrintToChat(i, "\x04[Sage]\x01 Tu escudo de \x05AGUA\x01 regalo ha expirado.");
            }
            else any = true;
        }

        if (g_bSageGiftFire[i])
        {
            if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2 || !g_bShieldActive[i])
            {
                g_bSageGiftFire[i] = false;
            }
            else if (now >= g_fSageGiftFireEnd[i])
            {
                Sally_StopShield(i, false);   // expiración limpia: sin explosión
                g_bSageGiftFire[i] = false;
                if (IsClientInGame(i)) PrintToChat(i, "\x04[Sage]\x01 Tu escudo de \x05FUEGO\x01 regalo ha expirado.");
            }
            else any = true;
        }
    }

    if (!any)
    {
        g_hSageGiftTimer = null;
        return Plugin_Stop;   // sin regalos vivos: el timer se apaga solo
    }
    return Plugin_Continue;
}

// limpieza de banderas de un cliente (rejoin / mapa nuevo)
void Sage_GiftClearClient(int client)
{
    if (client < 1 || client > MaxClients) return;
    g_bSageGiftWater[client] = false;
    g_bSageGiftFire[client] = false;
    g_fSageGiftWaterEnd[client] = 0.0;
    g_fSageGiftFireEnd[client] = 0.0;
}
