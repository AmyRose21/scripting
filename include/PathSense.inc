// ==================================================================
//  PathSense.inc v1.0 — «SENTIDO DE LA RUTA»: PASIVA PERMANENTE
//  del trazador de escape l4d_path_to_goal (gvazdas/zyiks v1.62).
// ==================================================================
//  [QUÉ ES] PUNTO DE CONTROL del Sonic Ability Manager para un
//  plugin INDEPENDIENTE (la misma filosofía de amy_fall_fix.sp:
//  no se fusiona ni se toca su código). l4d_path_to_goal.smx
//  dibuja con haces láser la ruta hacia el refugio/objetivo (y
//  hacia el vehículo de rescate en los finales, según su propia
//  configuración). Este include la convierte en PASIVA SIEMPRE
//  ACTIVA para quien corresponda:
//
//   1) PERSONAJES NATIVOS — lista configurable (cvar
//      pathsense_chars, por defecto «amy,sage,metal_sonic,tails»).
//      La temática del owner: Sage (IA), Metal Sonic (robot de
//      Eggman), Tails (sus experimentos) y Amy (la idea original).
//   2) ADMINISTRADORES — pathsense_admins 1: cualquier admin
//      lleva la pasiva activa sin importar su personaje.
//   3) TODOS — «sm_pathall»: la palanca de consola del admin para
//      colocar la pasiva en todo el server (persiste en el cvar
//      pathsense_all, auto-guardado en Sonic_Suite.cfg).
//   4) CONCESIÓN MANUAL — «sm_pathpassive <jugador> [0|1]»: el
//      admin la coloca o la retira a un jugador concreto (vale
//      hasta su desconexión).
//
//  [ACTIVACIÓN INSTANTÁNEA] FireCharSignal invoca
//  PathSense_OnCharSignal() EN EL MISMO FRAME en que el manager
//  detecta el personaje (menú, cookie al reconectar, freechars) —
//  el MISMO patrón de la señal CST: cero espera al siguiente tick.
//
//  [FUNCIONAMIENTO] Un temporizador de 1 s invoca la nativa
//  L4D_Path_To_Goal() para cada jugador con la pasiva. PTG impone
//  su propio enfriamiento tras cada trazo (= max(duración/2,
//  l4d_path_to_goal_cooldown)); el intervalo de refresco se
//  adapta SOLO a ese valor, así los haces se superponen y el
//  camino NUNCA desaparece («siempre activo»). Si PTG no está
//  instalado, la pasiva queda en silencio (nativa opcional): ni
//  errores ni spam; en cuanto el plugin se instale, revive sola.
//
//  [REGLAS DE DIBUJO DELEGADAS EN PTG] Los haces solo salen si el
//  mapa es «guiable», respetan sus cvars de equipo/estado de vida,
//  su lógica de finales (conexión al vehículo de rescate), su
//  presupuesto de CPU y su enfriamiento. Este include NO
//  re-implementa nada de navegación: solo decide QUIÉN lleva la
//  pasiva y CUÁNDO se traza.
//
//  [DEPENDENCIAS] Ninguna obligatoria. La nativa llega por el
//  .inc oficial en modo _NATIVE_ONLY (solo la declaración: el
//  manager no arrastra las ~2800 líneas del motor de navegación).
//  Requiere l4d_path_to_goal.smx instalado para dibujar de verdad.
// ==================================================================

#if defined _pathsense_inc_included
 #endinput
#endif
#define _pathsense_inc_included

#define PATHSENSE_VERSION "v1.1"

// ------------------------------------------------------------------
//  v3.77.59: la nativa del PTG en modo «solo declaración». El guard
//  _NATIVE_ONLY del propio .inc oficial corta la lectura justo
//  después de la firma + el SharedPlugin + el MarcadorOpcional — el
//  manager enlaza con el plugin independiente sin compilar su motor.
// ------------------------------------------------------------------
#define _NATIVE_ONLY
#include <l4d_path_to_goal>
#undef _NATIVE_ONLY

// ------------------------------------------------------------------
//  ESTADO
// ------------------------------------------------------------------

// ¿El personaje idx está en la lista nativa? (se reconstruye al
// parsear pathsense_chars; índices alineados con g_CharNames)
bool g_bPSNativeList[MAX_CHARS];

// Concesión manual del admin (sm_pathpassive): vale hasta la
// desconexión del jugador; encima de las reglas naturales.
bool  g_bPSGrant[MAXPLAYERS + 1];

// ¿Tenía la pasiva en la última evaluación? (detección de borde
// para el anuncio: que hable UNA vez al ganarla/perderla, no en
// cada trazo)
bool  g_bPSHad[MAXPLAYERS + 1];

// Momento del próximo trazo permitido para ese jugador (el
// enfriamiento real lo lleva PTG; esto es el adaptador local).
float g_fPSNextDraw[MAXPLAYERS + 1];

ConVar g_cvPSEnable;      // pathsense_enable
ConVar g_cvPSChars;       // pathsense_chars
ConVar g_cvPSAdmins;      // pathsense_admins
ConVar g_cvPSAll;         // pathsense_all
ConVar g_cvPSDuration;    // pathsense_duration
ConVar g_cvPSJoin;        // pathsense_join
ConVar g_cvPSRefreshMin;  // pathsense_refresh_min
ConVar g_cvPSChat;        // pathsense_chat

// Handle del cvar de enfriamiento del PTG (perezoso: puede no
// existir aún cuando este plugin arranca antes que el PTG).
ConVar g_cvPS_PtgCooldown;

// ------------------------------------------------------------------
//  INICIALIZACIÓN (la invoca OnPluginStart del manager, ANTES del
//  bucle de late-load: ese bucle dispara FireCharSignal ->
//  PathSense_OnCharSignal y los cvars tienen que estar vivos)
// ------------------------------------------------------------------

void PathSense_Init()
{
    g_cvPSEnable = CreateConVar("pathsense_enable", "1",
        "0=OFF, 1=ON. Pasiva «Sentido de la Ruta»: traza SIEMPRE el camino al refugio/objetivo (l4d_path_to_goal) para quien corresponda.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

    g_cvPSChars = CreateConVar("pathsense_chars", "amy,sage,metal_sonic,tails",
        "Personajes con la pasiva NATIVA (claves separadas por coma: sonic tails knuckles amy sally shadow rouge cream metal_sonic eggman sage). Se activa AL INSTANTE al detectar el personaje. Acepta alias por frontera: «metal» = metal_sonic.");
    g_cvPSChars.AddChangeHook(PS_OnCvarChanged);

    g_cvPSAdmins = CreateConVar("pathsense_admins", "1",
        "0=OFF, 1=ON. Los administradores llevan la pasiva activa sin importar su personaje.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvPSAdmins.AddChangeHook(PS_OnCvarChanged);

    g_cvPSAll = CreateConVar("pathsense_all", "0",
        "0=OFF, 1=ON. La pasiva para TODOS los jugadores (la palanca de sm_pathall; auto-guardado aquí).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvPSAll.AddChangeHook(PS_OnCvarChanged);

    g_cvPSDuration = CreateConVar("pathsense_duration", "10.0",
        "Vida de los haces en cada trazo (segundos). El refresco se adapta solo (duración/2) para que el camino nunca desaparezca.", FCVAR_NOTIFY, true, 2.0, true, 60.0);
    g_cvPSDuration.AddChangeHook(PS_OnCvarChanged);

    g_cvPSJoin = CreateConVar("pathsense_join", "1",
        "0=OFF, 1=ON. Unir visualmente al jugador con el punto más cercano de la ruta (más claro, algo más caro).", FCVAR_NOTIFY, true, 0.0, true, 1.0);

    g_cvPSRefreshMin = CreateConVar("pathsense_refresh_min", "1.5",
        "Suelo de seguridad entre trazos por jugador (segundos). El intervalo real = max(duración/2, enfriamiento del PTG, esto).", FCVAR_NOTIFY, true, 0.5, true, 30.0);

    g_cvPSChat = CreateConVar("pathsense_chat", "1",
        "0=OFF, 1=ON. Avisar en el chat al jugador cuando la pasiva se activa o se desactiva para él.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvPSChat.AddChangeHook(PS_OnCvarChanged);

    g_cvPSEnable.AddChangeHook(PS_OnCvarChanged);

    PS_ParseChars();

    // La palanca de consola del admin (pedido literal: "también
    // estaría una opción de consola de administrador si deseo
    // colocarla para todos") + la concesión individual.
    RegAdminCmd("sm_pathall", Cmd_PathAll, ADMFLAG_GENERIC,
        "sm_pathall [0|1] — la pasiva «Sentido de la Ruta» (l4d_path_to_goal) para TODOS los jugadores. Persiste en pathsense_all (auto-guardado en Sonic_Suite.cfg).");
    RegAdminCmd("sm_pathpassive", Cmd_PathPassive, ADMFLAG_GENERIC,
        "sm_pathpassive <jugador|#userid> [0|1] — coloca o retira la pasiva de ruta a un jugador concreto (vale hasta su desconexión).");

    // El latido de la pasiva: 1 s por servidor (no por jugador).
    CreateTimer(1.0, T_PathSenseTick, _, TIMER_REPEAT);

    // Qué quedó sembrado de verdad (para el log, con nombres del roster)
    char nativos[96];
    int n = 0;
    for (int c = 0; c < MAX_CHARS; c++)
        if (g_bPSNativeList[c])
            n += Format(nativos[n], sizeof(nativos) - n, "%s%s", n ? " " : "", g_CharNames[c]);

    LogMessage("[PathSense] %s — «Sentido de la Ruta» listo: nativos [%s] | admins %s | sm_pathall %s | PTG %s",
        PATHSENSE_VERSION, n ? nativos : "(ninguno)",
        g_cvPSAdmins.BoolValue ? "SÍ" : "no",
        g_cvPSAll.BoolValue ? "SÍ" : "no",
        PS_NativeAvailable() ? "detectado" : "no instalado (la pasiva espera en silencio)");
}

// ------------------------------------------------------------------
//  CICLO DE VIDA (invocados por el manager)
// ------------------------------------------------------------------

// OnMapStart: el GameTime se reinicia con el mapa; los sellos de
// tiempo del mapa anterior bloquearían el primer trazo. PTG además
// resetea SUS enfriamientos en su propio OnMapStart.
void PathSense_OnMapStart()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        g_fPSNextDraw[i] = 0.0;
        // g_bPSHad se conserva a propósito: el jugador que ya tenía
        // la pasiva no recibe otro anuncio por cambio de mapa.
    }
}

// OnClientDisconnect: la concesión manual y el estado de borde
// mueren con el slot (la pasiva NATIVA revive sola por señal).
void PathSense_OnClientDisconnect(int client)
{
    g_bPSGrant[client]      = false;
    g_bPSHad[client]        = false;
    g_fPSNextDraw[client]   = 0.0;
}

// FireCharSignal: la señal de personaje DEL MANAGER (mismo frame
// que la señal CST). charIdx < 0 = «sin personaje».
void PathSense_OnCharSignal(int client, int charIdx)
{
    // Nota: charIdx llega por parámetro pero la fuente de verdad
    // sigue siendo g_iPlayerCharIdx (FireCharSignal lo actualiza
    // ANTES de disparar; se recibe por claridad documental y para
    // futuras extensiones que discriminen por índice).
    #pragma unused charIdx

    PS_Evaluate(client, true);
}

// ------------------------------------------------------------------
//  NÚCLEO: ¿quién lleva la pasiva?
// ------------------------------------------------------------------

bool PS_ShouldHave(int client)
{
    if (g_cvPSEnable == null || !g_cvPSEnable.BoolValue) return false;
    if (!IsValidClient(client)) return false;   // en juego + humano

    if (g_cvPSAll.BoolValue)   return true;     // todos (sm_pathall)
    if (g_bPSGrant[client])    return true;     // concesión manual

    int idx = g_iPlayerCharIdx[client];
    if (idx >= 0 && idx < MAX_CHARS && g_bPSNativeList[idx])
        return true;                            // personaje nativo

    if (g_cvPSAdmins.BoolValue && PS_IsAdmin(client))
        return true;                            // administrador

    return false;
}

// Admin según los permisos reales del server (mismo mecanismo de
// los RegAdminCmd; el nombre solo sirve de consulta de permisos).
bool PS_IsAdmin(int client)
{
    return CheckCommandAccess(client, "pathsense_admin_passive", ADMFLAG_GENERIC);
}

// Detección de borde + anuncio + trazo opcional inmediato.
void PS_Evaluate(int client, bool drawNow)
{
    bool want = PS_ShouldHave(client);

    if (want && !g_bPSHad[client])
    {
        g_bPSHad[client] = true;
        if (g_cvPSChat != null && g_cvPSChat.BoolValue) PS_AnnounceOn(client);
    }
    else if (!want && g_bPSHad[client])
    {
        g_bPSHad[client] = false;
        if (g_cvPSChat != null && g_cvPSChat.BoolValue) PS_AnnounceOff(client);
    }

    if (want && drawNow) PS_DrawNow(client);
}

// El trazo: invoca la nativa del PTG respetando el adaptador local
// de enfriamiento. Si PTG no está, no hace nada (silencio).
void PS_DrawNow(int client)
{
    if (!PS_NativeAvailable()) return;
    if (GetGameTime() < g_fPSNextDraw[client]) return;

    // Regla del propio PTG: los no supervivientes ven la ruta
    // INVERSA (CmdRequestGuide usa el mismo criterio de equipo).
    bool backward = !IsSurvivor(client);

    L4D_Path_To_Goal(client, g_cvPSDuration.FloatValue, backward, g_cvPSJoin.BoolValue);

    g_fPSNextDraw[client] = GetGameTime() + PS_RefreshInterval();
}

// Intervalo adaptado al enfriamiento REAL del PTG: tras un trazo
// de duración D, PTG bloquea max(D/2, su cvar de enfriamiento).
// Refrescar antes es un no-op silencioso; refrescar a este ritmo
// hace que los haces se superpongan (camino continuo).
float PS_RefreshInterval()
{
    float interval = g_cvPSDuration.FloatValue / 2.0;

    if (g_cvPS_PtgCooldown == null)
        g_cvPS_PtgCooldown = FindConVar("l4d_path_to_goal_cooldown");

    if (g_cvPS_PtgCooldown != null && g_cvPS_PtgCooldown.FloatValue > interval)
        interval = g_cvPS_PtgCooldown.FloatValue;

    if (g_cvPSRefreshMin.FloatValue > interval)
        interval = g_cvPSRefreshMin.FloatValue;

    return interval;
}

// ¿La nativa del PTG está disponible? (el plugin puede cargarse
// o descargarse en caliente; sondeo barato en cada trazo)
bool PS_NativeAvailable()
{
    return GetFeatureStatus(FeatureType_Native, "L4D_Path_To_Goal") == FeatureStatus_Available;
}

// ------------------------------------------------------------------
//  EL LATIDO: 1 s — cubre a quien gana la pasiva SIN señal de
//  personaje (admin que entra a mitad de mapa, sm_pathall,
//  PTG que se carga tarde) y redibuja a los que ya la tienen.
// ------------------------------------------------------------------

public Action T_PathSenseTick(Handle timer)
{
    if (g_cvPSEnable == null || !g_cvPSEnable.BoolValue) return Plugin_Continue;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
        if (GetGameTime() < g_fPSNextDraw[i]) continue;
        PS_Evaluate(i, true);
    }
    return Plugin_Continue;
}

// ------------------------------------------------------------------
//  PARSEO DE LA LISTA NATIVA (pathsense_chars)
//  Separadores aceptados: coma, punto y coma y espacio (así valen
//  «amy,sage,metal_sonic,tails», «amy sage metal_sonic tails» o
//  cualquier mezcla).
// ------------------------------------------------------------------

void PS_ParseChars()
{
    for (int i = 0; i < MAX_CHARS; i++) g_bPSNativeList[i] = false;

    char raw[192], token[32], key[32];
    g_cvPSChars.GetString(raw, sizeof(raw));

    int len   = strlen(raw);
    int ti    = 0;   // cursor de escritura del token
    int count = 0;   // suelo de sanidad: 24 claves como máximo

    for (int i = 0; i <= len && count <= 24; i++)
    {
        int ch = 0;
        if (i < len) ch = raw[i];

        if (ch == ',' || ch == ';' || ch == ' ' || ch == '\0')
        {
            if (ti == 0) continue;   // separadores repetidos / vacíos

            token[ti] = '\0';
            PS_Normalize(token, sizeof(token));

            bool matched = false;
            for (int c = 0; c < MAX_CHARS; c++)
            {
                PS_NormalizeKey(g_sCstCharKeys[c], key, sizeof(key));
                if (PS_KeyMatch(token, key)) { g_bPSNativeList[c] = true; matched = true; break; }
            }

            if (!matched)
                LogMessage("[PathSense] WARNING: la clave «%s» de pathsense_chars no corresponde a ningún personaje (válidas: sonic tails knuckles amy sally shadow rouge cream metal_sonic eggman sage blaze silver) — se ignora.", token);

            count++;
            ti = 0;
            continue;
        }

        if (ti < sizeof(token) - 1) { token[ti] = ch; ti++; }
    }
}

// Normalización de un token del cvar: minúsculas + espacios->'_'.
void PS_Normalize(char[] s, int maxlen)
{
    for (int i = 0; i < maxlen && s[i] != '\0'; i++)
    {
        if (s[i] == ' ' || s[i] == '\t') s[i] = '_';
        else s[i] = CharToLower(s[i]);
    }
}

// Copia normalizada de una clave de personaje (g_sCstCharKeys ya
// viene en minúsculas, pero se normaliza igual por si el roster
// crece con nombres nuevos).
void PS_NormalizeKey(const char[] src, char[] dst, int maxlen)
{
    strcopy(dst, maxlen, src);
    PS_Normalize(dst, maxlen);
}

// Coincidencia exacta O por frontera de palabra (el mismo criterio
// del mapa CST): «metal» casa con «metal_sonic» porque el carácter
// siguiente es '_'; «s» NO casa con «sonic» porque sigue una letra.
bool PS_KeyMatch(const char[] token, const char[] key)
{
    if (StrEqual(token, key)) return true;

    int lt = strlen(token);
    if (lt > 0 && strlen(key) > lt && key[lt] == '_')
        return (strncmp(token, key, lt) == 0);

    return false;
}

// ------------------------------------------------------------------
//  ANUNCIOS
// ------------------------------------------------------------------

void PS_AnnounceOn(int client)
{
    int idx = g_iPlayerCharIdx[client];
    if (idx >= 0 && idx < MAX_CHARS)
        PrintToChat(client, "\x04[PathSense]\x01 Sentido de la ruta \x05ACTIVO\x01: %s siempre traza el camino al objetivo (pasiva).",
            g_CharNames[idx]);
    else
        PrintToChat(client, "\x04[PathSense]\x01 Sentido de la ruta \x05ACTIVO\x01: el camino al objetivo siempre visible (pasiva).");
}

void PS_AnnounceOff(int client)
{
    PrintToChat(client, "\x04[PathSense]\x01 Sentido de la ruta \x01desactivado.");
}

// ------------------------------------------------------------------
//  COMANDOS
// ------------------------------------------------------------------

// sm_pathall [0|1] — la palanca de admin: la pasiva para TODOS.
// Persiste en pathsense_all (auto-guardado en Sonic_Suite.cfg).
Action Cmd_PathAll(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    bool nuevo;
    if (args > 0)
    {
        char arg[8];
        GetCmdArg(1, arg, sizeof(arg));
        nuevo = (StringToInt(arg) != 0);
    }
    else nuevo = !g_cvPSAll.BoolValue;

    g_cvPSAll.BoolValue = nuevo;   // el hook re-evalúa a todos

    ReplyToCommand(client, "[PathSense] Pasiva de ruta para TODOS: %s (pathsense_all=%d, se guarda solo en Sonic_Suite.cfg)",
        nuevo ? "ACTIVADA" : "DESACTIVADA", nuevo ? 1 : 0);
    return Plugin_Handled;
}

// sm_pathpassive <jugador> [0|1] — concesión/retiro manual.
Action Cmd_PathPassive(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (args < 1)
    {
        ReplyToCommand(client, "[PathSense] Uso: sm_pathpassive <jugador|#userid> [0|1] — coloca o retira la pasiva de ruta a un jugador (vale hasta su desconexión).");
        return Plugin_Handled;
    }

    char arg[64];
    GetCmdArg(1, arg, sizeof(arg));

    int target = FindTarget(client, arg, false, false);
    if (target == -1) return Plugin_Handled;   // FindTarget ya informó el error

    bool nuevo;
    if (args > 1)
    {
        GetCmdArg(2, arg, sizeof(arg));
        nuevo = (StringToInt(arg) != 0);
    }
    else nuevo = !g_bPSGrant[target];

    g_bPSGrant[target] = nuevo;
    PS_Evaluate(target, true);   // anuncio + trazo inmediato si la gana

    ReplyToCommand(client, "[PathSense] Pasiva de ruta para %N: %s (concesión manual).",
        target, nuevo ? "COLOCADA" : "RETIRADA");
    return Plugin_Handled;
}

// ------------------------------------------------------------------
//  REACCIÓN A LOS CVARS (re-evaluación inmediata con anuncios de
//  borde: cambiar la lista/los admins/la palanca habla UNA vez por
//  jugador afectado, no en cada trazo)
// ------------------------------------------------------------------

public void PS_OnCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (convar == g_cvPSChars) PS_ParseChars();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
        PS_Evaluate(i, true);
    }
}
