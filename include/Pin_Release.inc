/*
 * ======================================================
 *  [MODULO] Pin Release v2.0 - Liberación SEGURA de agarres
 *  (sistema compartido: lo usan Amy [martillo + counter],
 *   Sally [cintura + escudo] y Cream [ClearAllGrabs])
 *
 *  v2.0 - FIX CRITICO (crash del juego al usar el martillo
 *  estando agarrada, v2.1 del fix anterior no bastaba):
 *   - v1.x liberaba escribiendo -1 A MANO en los enlaces
 *     (m_pounceVictim del hunter, m_jockeyVictim del jockey,
 *     m_tongueVictim del smoker, m_pummelVictim/m_carryVictim
 *     del charger). Eso separa los EHANDLEs a nivel red, pero
 *     el motor NUNCA ejecuta su camino de "fin de agarre":
 *     el atacante queda DENTRO de su estado (pounce activo,
 *     ride activo, tongue en drag, pummel en curso) con un
 *     puntero de victima NULL. En su siguiente think, la
 *     maquina de estados del infectado especial desreferencia
 *     ese NULL -> crash del engine (el juego se cierra solo).
 *     Por eso el crash era "en ciertas ocasiones": solo cuando
 *     Amy estaba agarrada (o golpeaba al especial que la
 *     tenía agarrada) al pulsar el martillo.
 *   - SOLUCION: USAR LAS FUNCIONES DEL PROPIO MOTOR. L4D2 las
 *     expone y left4dhooks las envuelve como nativas (todas
 *     L4D2-only y opcionales, feature-check en runtime):
 *       Hunter   -> L4D_Hunter_ReleaseVictim(victim, attacker)
 *       Smoker   -> L4D_Smoker_ReleaseVictim(victim, attacker)
 *       Jockey   -> L4D2_Jockey_EndRide(victim, attacker)
 *       Charger  -> L4D2_Charger_EndPummel(victim, attacker)
 *       Charger  -> L4D2_Charger_EndCarry(victim, attacker)
 *     Estas ejecutan el camino COMPLETO del motor: desmonta,
 *     corta animaciones, limpia los enlaces de AMBOS lados,
 *     restaura el movimiento de la victima y termina sus cues
 *     de música correctamente.
 *   - FALLBACK (left4dhooks viejo sin las nativas): SIStagger
 *     del atacante (CTerrorPlayer::OnStaggered = el interrupt
 *     vanilla del golpe de Tank: el propio motor corta el
 *     agarre al tambalear al atacante). NUNCA se vuelve a
 *     escribir -1 en los enlaces: cero superficie de crash.
 *   - Eliminado el SetEntityMoveType(MOVETYPE_WALK) manual:
 *     el camino del motor restaura el movimiento solo y la
 *     escritura cruda pisaba estados legitimos (escaleras).
 *
 *  v1.1 - FIX (crash-surface + correcto):
 *   - PinRelease_Cleanse hacia TODO su trabajo (cortar 24 cues de
 *     música vía 24 llamadas SDKCall L4D_StopMusic + forzar
 *     MOVETYPE_WALK) aunque la victima NO tuviera NINGÚN agarre
 *     activo. Se le llamaba desde el hard-stop del martillo de Amy en
 *     CADA golpe a un especial -> 24 SDKCalls innecesarias por golpe.
 *     Ahora: early-out si no hay ningún agarre real que liberar.
 *
 *  v1.0 - POR QUE ESTE MODULO (bug reportado: "cuando me libera de un
 *  hunter/jockey/smoker la música de 'estar agarrado' sigue
 *  sonando como si siguiera bajo ese estado"):
 *   - La música de agarre son cues del sistema de música del motor
 *     (game_sounds_music.txt), reproducidas en la victima al ser
 *     agarrada:
 *     Hunter = "Event.Exenteration" / Jockey = "Event.Vassalation"
 *     Smoker = "Event.Asphyxiation" y "Event.Tonguetied"
 *     Charger = "Event.Mortification" / "Event.Contusión"
 *     (nombres confirmados en la wiki de Left 4 Dead: Audio Cues).
 *     NO son sonidos de entidad: StopSound común no las corta.
 *   - Se cortan con L4D_StopMusic (CMusic::StopPlaying del motor,
 *     vía left4dhooks) directamente en el cliente de la victima.
 *     Se intentan todas las variantes de nombre: cortar una cue
 *     que no está sonando es un no-op inofensivo. Con el camino
 *     del motor de v2.0 las cues ya terminan solas, pero se
 *     mantiene como red de seguridad por si el host las dejo
 *     colgadas de un agarre anterior.
 *
 *  EXTRAS:
 *   - El atacante recibe un stagger SEGURO (SIStagger_Auto: el
 *     propio stagger + recuperación garantizada a los 1.8s). Así no
 *     puede re-agarrar en el mismo instante y nunca queda tirado
 *     "sin levantarse". El stagger también es el FALLBACK cuando
 *     las nativas de liberación no están disponibles.
 *   - Todas las nativas usadas son OPCIONALES (MarkNativeAsOptional
 *     en left4dhooks): feature-check en runtime. Sin left4dhooks
 *     moderno, la liberación vía stagger funciona igual.
 *
 *  API (sin cambios para los callers):
 *   - PinRelease_Cleanse(victim): libera TODOS los agarres activos
 *     sobre la victima por el camino del MOTOR (hunter, smoker,
 *     charger pummel/carry, jockey), corta su música y aturde a
 *     los atacantes para que no re-agarren al instante.
 *   - PinRelease_StopPinMusic(victim): SOLO la parte de música
 *     (por si otro modulo libera por su cuenta).
 * ======================================================
 */

#if defined _pin_release_included
    #endinput
#endif
#define _pin_release_included

#if !defined _sourcemod_included
    #include <sourcemod>
#endif
#if !defined _sdktools_included
    #include <sdktools>
#endif
#if !defined _sdkhooks_included
    #include <sdkhooks>
#endif
#if !defined _si_stagger_included
    #include <SI_Stagger>
#endif
#if !defined _l4d_stocks_included && !defined _left4dhooks_included
    #tryinclude <left4dhooks>
#endif

// =======================
// Estado
// =======================
static bool g_bPinRelChecked;      // feature-check hecho?
static bool g_bPinRelStopMusicOK;  // L4D_StopMusic disponible?
static bool g_bPinRelHunterOK;     // L4D_Hunter_ReleaseVictim?
static bool g_bPinRelSmokerOK;     // L4D_Smoker_ReleaseVictim?
static bool g_bPinRelJockeyOK;     // L4D2_Jockey_EndRide?
static bool g_bPinRelChgPummelOK;  // L4D2_Charger_EndPummel?
static bool g_bPinRelChgCarryOK;   // L4D2_Charger_EndCarry?

// Cues de música de agarre (game_sounds_music.txt). Se cortan TODAS
// en la victima al liberar: cortar una que no suena es inofensivo y
// así no dependemos de que el motor usara la variante exacta.
static const char g_sPinMusics[][] = {
    // Hunter (pounce)
    "Event.Exenteration", "Exenteration",
    "Event.Exenterationhit", "Event.ExenterationHit",
    // Jockey (ride)
    "Event.Vassalation", "Vassalation",
    "Event.Vassalationhit", "VassalationHit",
    // Smoker (tongue drag + choke)
    "Event.Tonguetied", "Tonguetied",
    "Event.Tonguetiedhit", "TonguetiedHit",
    "Event.Asphyxiation", "Asphyxiation",
    "Event.Asphyxiationhit", "AsphyxiationHit",
    // Charger (pummel/carry)
    "Event.Mortification", "Mortification",
    "Event.Mortificationhit", "Event.MortificationHit",
    "Event.Contusión", "Contusión",
    "Event.Contusionhit", "ContusionHit"
};

// ============================================================
//  API PUBLICA
// ============================================================

// Libera todos los agarres activos sobre la victima POR EL CAMINO
// DEL MOTOR (nativas de liberación de left4dhooks). v2.0: jamás se
// escriben los enlaces a -1 a mano (la maquina de estados del
// atacante quedaba rota -> crash del engine). v1.1: si no hay
// ningún agarre activo, no hace NADA (ni música ni SDKCalls).
void PinRelease_Cleanse(int victim)
{
    if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)
        || !IsPlayerAlive(victim))
    {
        return;
    }

    PinRelease_EnsureFeature();

    bool released = false;
    float vPos[3];
    GetClientAbsOrigin(victim, vPos);

    // --- HUNTER (pounce) ---
    int attacker = GetEntPropEnt(victim, Prop_Send, "m_pounceAttacker");
    if (PinRelease_IsValidSI(attacker))
    {
        if (g_bPinRelHunterOK)
        {
            // Camino COMPLETO del motor: corta ambos lados, animación
            // de recuperación del hunter y estado de la victima.
            L4D_Hunter_ReleaseVictim(victim, attacker);
        }
        // Stagger del atacante: fallback del motor (OnStaggered corta
        // el pounce, como el golpe de Tank en vanilla) + anti re-grab.
        SIStagger_Auto(attacker, victim, vPos);
        released = true;
    }

    // --- SMOKER (tongue) ---
    attacker = GetEntPropEnt(victim, Prop_Send, "m_tongueOwner");
    if (PinRelease_IsValidSI(attacker))
    {
        if (g_bPinRelSmokerOK)
        {
            // Corta la lengua por el camino del motor (drag/choke
            // terminan bien; sin desync del CTongue).
            L4D_Smoker_ReleaseVictim(victim, attacker);
        }
        SIStagger_Auto(attacker, victim, vPos);
        released = true;
    }

    // --- CHARGER (pummel) ---
    attacker = GetEntPropEnt(victim, Prop_Send, "m_pummelAttacker");
    if (PinRelease_IsValidSI(attacker))
    {
        if (g_bPinRelChgPummelOK)
        {
            L4D2_Charger_EndPummel(victim, attacker);
        }
        SIStagger_Auto(attacker, victim, vPos);
        released = true;
    }

    // --- CHARGER (carry) ---
    attacker = GetEntPropEnt(victim, Prop_Send, "m_carryAttacker");
    if (PinRelease_IsValidSI(attacker))
    {
        if (g_bPinRelChgCarryOK)
        {
            L4D2_Charger_EndCarry(victim, attacker);
        }
        SIStagger_Auto(attacker, victim, vPos);
        released = true;
    }

    // --- JOCKEY (ride) ---
    attacker = GetEntPropEnt(victim, Prop_Send, "m_jockeyAttacker");
    if (PinRelease_IsValidSI(attacker))
    {
        if (g_bPinRelJockeyOK)
        {
            // Desmonta al jockey por el camino del motor (sin dejarlo
            // montado con victima NULL: eso crasheaba el engine).
            L4D2_Jockey_EndRide(victim, attacker);
        }
        SIStagger_Auto(attacker, victim, vPos);
        released = true;
    }

    // v1.1: sin agarre real no hay NADA que limpiar (la música de
    // agarre no está sonando y ningún pin tocó el estado).
    if (!released) return;

    // Red de seguridad para el bug del "loop de música que sigue
    // sonando": el camino del motor ya termina sus cues, pero si una
    // quedó colgada de un agarre anterior, aquí se corta.
    PinRelease_StopPinMusic(victim);

    // NOTA v2.0: ya NO se fuerza MOVETYPE_WALK. El camino del motor
    // restaura el movimiento de la victima por si mismo, y la
    // escritura cruda pisaba estados legitimos (escaleras).
}

// Corta en la victima todas las cues de música de agarre.
void PinRelease_StopPinMusic(int victim)
{
    if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)) return;

    PinRelease_EnsureFeature();
    if (!g_bPinRelStopMusicOK) return;

    for (int i = 0; i < sizeof(g_sPinMusics); i++)
    {
        L4D_StopMusic(victim, g_sPinMusics[i]);
    }
}

// ============================================================
//  HELPERS
// ============================================================

static bool PinRelease_IsValidSI(int ent)
{
    if (ent <= 0 || ent > MaxClients) return false;
    if (!IsClientInGame(ent) || !IsPlayerAlive(ent)) return false;
    if (GetClientTeam(ent) != 3) return false;   // TEAM_INFECTED
    return true;
}

// Feature-check perezoso de las 6 nativas opcionales (música + 5
// liberaciones del motor). Sin left4dhooks moderno, la liberación
// funciona vía stagger (el interrupt vanilla del Tank).
static void PinRelease_EnsureFeature()
{
    if (g_bPinRelChecked) return;
    g_bPinRelChecked = true;

    // Por defecto true (SourcePawn puro sin CanTestFeatures):
    // si el server no puede testear features, se asume que el
    // left4dhooks cargado trae las nativas (las marcamos optional
    // para que el plugin cargue igual si faltan; el SDKCall nativo
    // lanzaria un error visible en logs, no un crash).
    g_bPinRelStopMusicOK = true;
    g_bPinRelHunterOK    = true;
    g_bPinRelSmokerOK    = true;
    g_bPinRelJockeyOK    = true;
    g_bPinRelChgPummelOK = true;
    g_bPinRelChgCarryOK  = true;

    if (CanTestFeatures())
    {
        g_bPinRelStopMusicOK =
            (GetFeatureStatus(FeatureType_Native, "L4D_StopMusic")
             == FeatureStatus_Available);
        g_bPinRelHunterOK =
            (GetFeatureStatus(FeatureType_Native, "L4D_Hunter_ReleaseVictim")
             == FeatureStatus_Available);
        g_bPinRelSmokerOK =
            (GetFeatureStatus(FeatureType_Native, "L4D_Smoker_ReleaseVictim")
             == FeatureStatus_Available);
        g_bPinRelJockeyOK =
            (GetFeatureStatus(FeatureType_Native, "L4D2_Jockey_EndRide")
             == FeatureStatus_Available);
        g_bPinRelChgPummelOK =
            (GetFeatureStatus(FeatureType_Native, "L4D2_Charger_EndPummel")
             == FeatureStatus_Available);
        g_bPinRelChgCarryOK =
            (GetFeatureStatus(FeatureType_Native, "L4D2_Charger_EndCarry")
             == FeatureStatus_Available);
    }
}
