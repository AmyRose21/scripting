/*
 * ======================================================
 *  [MODULO] SI Stagger v1.0 - Stagger seguro con auto-recuperación
 *  (sistema compartido: lo usan Tails, Amy y Knuckles)
 *
 *  POR QUE ESTE MODULO (investigación del bug "los stagger no se
 *  levantan del suelo"):
 *   - El stagger del motor (CTerrorPlayer::OnStaggered, invocado por
 *     L4D_StaggerPlayer) mete al objetivo en el estado "stumble".
 *     Con jugadores humanos el motor lo limpia solo; con BOTS
 *     infectados (tank, smoker, etc) el estado a veces NUNCA se
 *     limpia: el bot se queda tirado en el suelo sin levantarse
 *     hasta que algo externo lo resetea (un shove, otra habilidad).
 *     El usuario lo reporto y tiene razón: es código del propio
 *     motor de L4D2, no de este plugin.
 *   - SOLUCION: después de cada stagger que causamos, programamos
 *     la recuperación con L4D_CancelStagger (CTerrorPlayer::
 *     CancelStagger del propio motor: es LA función que termina el
 *     estado). Si el bot ya se levanto solo, es un no-op inofensivo.
 *     Si se quedó atascado (el bug), se levanta garantizado.
 *   - Tiempos: SI 1.8s / Tank 3.0s (por ENCIMA de la duración real
 *     del stumble vanilla, así que JAMÁS corta un stun legitimo:
 *     solo actúa como red de seguridad).
 *
 *  SEGURIDAD:
 *   - L4D_CancelStagger es native OPCIONAL en left4dhooks (marcada
 *     con MarkNativeAsOptional): se comprueba en runtime con
 *     GetFeatureStatus. Versiones viejas sin ella = comportamiento
 *     anterior (sin red de seguridad), sin errores de nativa.
 *   - 1 timer máximo por victima: un re-stagger REEMPLAZA su cancel
 *     pendiente (nunca un cancel viejo corta un stagger nuevo).
 *   - El callback anula el slot SIEMPRE (aunque la victima haya
 *     desconectado: guarda slot+userid en el DataPack), así que el
 *     handle colgado "Invalid Handle" del próximo ocupante del slot
 *     no puede ocurrir.
 *   - SIN TIMER_FLAG_NO_MAPCHANGE a propositito: el timer siempre
 *     dispara (aunque sea en el mapa nuevo) y se limpia solo. Un
 *     timer NO_MAPCHANGE moriria en silencio y dejaría el handle
 *     del slot apuntando a basura.
 *
 *  API:
 *   - SIStagger_Auto(victim, sourceEnt, vecSource): stagger +
 *     auto-recuperación (elige el tiempo según la clase: tank
 *     3.0s, resto 1.8s).
 *   - SIStagger_Stagger(victim, sourceEnt, vecSource, recover):
 *     lo mismo con tiempo manual (0 = sin red de seguridad).
 *   - SIStagger_OnClientDisconnect(client): limpieza del slot.
 * ======================================================
 */

#if defined _si_stagger_included
    #endinput
#endif
#define _si_stagger_included

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
// Constantes
// =======================
#define SI_STAGGER_RECOVER_SI      1.8   // red de seguridad para especiales
#define SI_STAGGER_RECOVER_TANK    3.0   // el tank se tambalea más rato

// =======================
// Estado
// =======================
static Handle g_hSIStagCancel[MAXPLAYERS + 1];   // 1 cancel pendiente máximo
static bool   g_bSIStagChecked;                  // feature-check hecho?
static bool   g_bSIStagCancelOK;                 // L4D_CancelStagger disponible

// ============================================================
//  API PUBLICA
// ============================================================

// Stagger con auto-recuperación y tiempo automático según clase.
void SIStagger_Auto(int victim, int sourceEnt, const float vecSource[3])
{
    float recover = SI_STAGGER_RECOVER_SI;

    if (victim > 0 && victim <= MaxClients && IsClientInGame(victim))
    {
        // 8 = ZC_TANK (mismo chequeo que ya usa el laser de Tails)
        if (GetEntProp(victim, Prop_Send, "m_zombieClass") == 8)
        {
            recover = SI_STAGGER_RECOVER_TANK;
        }
    }

    SIStagger_Stagger(victim, sourceEnt, vecSource, recover);
}

// Stagger + cancel programado. recover <= 0 = sin red de seguridad.
void SIStagger_Stagger(int victim, int sourceEnt, const float vecSource[3],
                       float recover)
{
    if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)
        || !IsPlayerAlive(victim))
    {
        return;
    }

    L4D_StaggerPlayer(victim, sourceEnt, vecSource);

    if (recover > 0.0)
    {
        SIStagger_ScheduleCancel(victim, recover);
    }
}

// Limpieza del slot (cablear al disconnect). El timer pendiente
// seguirá disparándose y se autolimpia (valida userid), pero así el
// slot queda libre YA para el próximo ocupante.
void SIStagger_OnClientDisconnect(int client)
{
    if (client <= 0 || client > MaxClients) return;

    if (g_hSIStagCancel[client] != null)
    {
        // KillTimer cierra el DataPack (TIMER_DATA_HNDL_CLOSE) y el
        // callback no volverá a dispararse para este handle.
        KillTimer(g_hSIStagCancel[client]);
        g_hSIStagCancel[client] = null;
    }
}

// ============================================================
//  NUCLEO: cancel programado
// ============================================================
static void SIStagger_ScheduleCancel(int victim, float delay)
{
    if (victim <= 0 || victim > MaxClients) return;

    // Comprobar UNA vez si el server tiene la native (es opcional
    // en left4dhooks: versiones viejas no la traen).
    SIStagger_EnsureFeature();
    if (!g_bSIStagCancelOK) return;

    // Re-stagger: reemplazar el cancel pendiente (nunca un cancel
    // viejo corta un stagger nuevo).
    if (g_hSIStagCancel[victim] != null)
    {
        KillTimer(g_hSIStagCancel[victim]);
        g_hSIStagCancel[victim] = null;
    }

    DataPack dp = new DataPack();
    dp.WriteCell(victim);                 // slot (para anular SIEMPRE)
    dp.WriteCell(GetClientUserId(victim)); // validez en el momento de disparar

    g_hSIStagCancel[victim] = CreateTimer(delay, T_SIStaggerCancel, dp,
                                          TIMER_DATA_HNDL_CLOSE);
}

// Inicializa perezosamente el feature-check (una sola vez).
static void SIStagger_EnsureFeature()
{
    if (g_bSIStagChecked) return;
    g_bSIStagChecked = true;

    g_bSIStagCancelOK = true;
    if (CanTestFeatures())
    {
        g_bSIStagCancelOK =
            (GetFeatureStatus(FeatureType_Native, "L4D_CancelStagger")
             == FeatureStatus_Available);
    }
}

public Action T_SIStaggerCancel(Handle timer, DataPack dp)
{
    dp.Reset();
    int slot   = dp.ReadCell();
    int userid = dp.ReadCell();
    int client = GetClientOfUserId(userid);

    // Anular el slot SIEMPRE (aunque la victima ya no este: el slot
    // venía guardado en el pack, no depende de resolver el userid).
    if (slot > 0 && slot <= MaxClients && g_hSIStagCancel[slot] == timer)
    {
        g_hSIStagCancel[slot] = null;
    }

    // Red de seguridad: si sigue vivo y sigue staggered, liberarlo.
    // Si el motor ya lo recupero solo, esto es un no-op inofensivo.
    if (client > 0 && client <= MaxClients && IsClientInGame(client)
        && IsPlayerAlive(client))
    {
        L4D_CancelStagger(client);
    }

    return Plugin_Stop;
}
