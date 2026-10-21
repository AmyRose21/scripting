/* ============================================================
   KNUCKLES PARRY STATE  v2.0  (el puente de estado VScript->smx)
   ============================================================
   LA ARQUITECTURA NUEVA (la que pidió el owner): este .nut ya NO
   ejecuta nada de física ni auras. Solo AVISA al Parry.smx v2.0
   cuándo Knuckles está en ventana de parry (ON) y cuándo deja de
   estarlo (OFF = "la orden de apagado"). El plugin hace TODO el
   trabajo, nativo, con la lógica de proyectiles que ya tenía:

       VScript manda estado    ->  knxparry_state <jug> 1 [seg]
       VScript orden de apago  ->  knxparry_state <jug> 0

   Mientras la ventana esté abierta, el plugin devuelve todo
   proyectil HOSTIL que venga hacia Knuckles (receta Amy: solo lo
   que se mueve hacia él):
     - PIEDRA DEL TANK -> devuelta al tank + 500 de daño al llegar
     - SALIVA DEL SPITTER -> devuelta al spitter + cambio de dueño
       (el puddle pasa a ser tuyo y lastima a los SI)
     - PROPS CON VPHYS (coches puñeteados, barriles) -> al tank

   API (llámala desde TU parry en VScript, el super tank, un
   logic_script, o la consola):

       KnucklesParryWindow(player)          // ON, duración por convar
       KnucklesParryWindow(player, 3.0)     // ON por 3 segundos
       KnucklesParryWindow(player, 0.0)     // ON hasta la orden de apagado
       KnucklesParryEnd(player)             // OFF (la orden de apagado)
       KnucklesParryActive(player)          // true si sigue en ventana
       KnucklesParryAura(...)               // alias de Window (compat v1.x)

   Para probar desde consola (con el .nut cargado):
       script KnucklesParryWindow(Entities.GetByIndex(1))
   ...o SIN el .nut, directo:
       knxparry_state 1 1 2.0        (abre 2 s en el jugador 1)
       knxparry_state 1 0            (la orden de apagado)

   INSTALACIÓN: left4dead2/scripts/vscripts/knuckles_parry_state.nut
   Requiere Parry.smx v2.0+ (el del paquete). Si tenías el
   knuckles_parry_aura.nut viejo (v1.0), BÓRRALO: ya no se usa.
   ============================================================ */

// instala UNA vez por mapa (re-ejecutar el archivo es no-op)
if (!("KNX_PARITY_STATE_LOADED" in getroottable()))
{
    ::KNX_PARITY_STATE_LOADED <- true;

    ::KNX_STATE <-
    {
        windows = {}   // entIdx del player -> { until } (espejo local)
        debug   = false   // true = log en consola de cada comando enviado
    }

    // ---------------------- PUENTE --------------------------
    ::KNX_Send <- function(cmd)
    {
        local ok = true;
        try { SendToServerConsole(cmd); }
        catch (e)
        {
            ok = false;
            ::print("[KNX-STATE] ERROR: este VScript no tiene SendToServerConsole\n");
        }
        if (::KNX_STATE.debug) ::print("[KNX-STATE] -> " + cmd + (ok ? "" : " (FALLO)") + "\n");
    }

    // versión del plugin compañero ("" si no está)
    ::KNX_PluginVersion <- function()
    {
        try { return Convars.GetStr("uk_parry_version"); } catch (e) { return ""; }
    }

    // ---------------------- API PUBLICA ---------------------
    // abre la ventana de parry en un player (dur = null -> la del
    // convar uk_parry_window; dur = 0 -> hasta la orden de apagado)
    ::KnucklesParryWindow <- function(player, dur = null)
    {
        if (player == null || !player.IsValid()) return false;

        local idx = player.GetEntityIndex();

        if (dur == null)
        {
            local pd = 2.0;
            try { pd = Convars.GetFloat("uk_parry_window"); } catch (e) {}
            if (pd <= 0.0) pd = 2.0;
            ::KNX_Send(format("knxparry_state %d 1", idx));
            ::KNX_STATE.windows.rawset(idx, { until = Time() + pd });
        }
        else
        {
            local d = 0.0;
            try { d = dur.tofloat(); } catch (e) { d = 0.0; }
            if (d < 0.0) d = 0.0;
            ::KNX_Send(format("knxparry_state %d 1 %.2f", idx, d));
            ::KNX_STATE.windows.rawset(idx, { until = Time() + (d > 0.0 ? d : 30.0) });
        }

        if (::KNX_STATE.debug) ::print("[KNX-STATE] ventana abierta en ent " + idx + "\n");
        return true;
    }

    // la orden de apagado: cierra la ventana ya
    ::KnucklesParryEnd <- function(player)
    {
        if (player == null || !player.IsValid()) return false;

        local idx = player.GetEntityIndex();
        ::KNX_Send(format("knxparry_state %d 0", idx));
        if (::KNX_STATE.windows.rawin(idx)) ::KNX_STATE.windows.rawdelete(idx);

        if (::KNX_STATE.debug) ::print("[KNX-STATE] ventana cerrada en ent " + idx + "\n");
        return true;
    }

    // para que OTROS scripts (tu parry, el super tank) sepan si está
    ::KnucklesParryActive <- function(player)
    {
        if (player == null || !player.IsValid()) return false;
        local idx = player.GetEntityIndex();
        if (!::KNX_STATE.windows.rawin(idx)) return false;
        return (Time() < ::KNX_STATE.windows[idx].until);
    }

    // compat v1.x: el nombre que usaba el Parry.smx 1.5
    ::KnucklesParryAura <- ::KnucklesParryWindow;

    // ---------------------- BANNER --------------------------
    local pv = ::KNX_PluginVersion();
    if (typeof pv == "string" && pv.len() > 0 && pv[0] == '2')
        ::printl("[KNX] knuckles_parry_state.nut v2.0 listo (puente de estado -> Parry.smx " + pv + ")");
    else
        ::printl("[KNX] knuckles_parry_state.nut v2.0: Parry.smx v2.0+ NO detectado (uk_parry_version). El .nut avisa el estado; sin el plugin no hay quien ejecute.");
}
