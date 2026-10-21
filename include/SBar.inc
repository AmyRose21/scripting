// =====================================================================
// SBar.inc — SBar v3.0-OM: LA BARRA AL CHAT CON colors.inc (v3.77.84)
// =====================================================================
// Reporte del owner sobre la v3.77.83 (con captura de pantalla y
// anotación manuscrita "La barra debe ir aquí" señalando la esquina
// INFERIOR IZQUIERDA — la zona del chat, ~x11% y86%): "puedes quizás
// usar el colors.inc para el tema de los colores xq aparesen font y no
// creo que quede bn y la barra debería aparecer más abajo".
//
// AUTOPSIA DEFINITIVA DEL CANAL DEL HINT: la captura muestra el mensaje
// de la barra con los <font color='#828282' size='24'> impresos como
// TEXTO LITERAL dentro de la caja negra. L4D2 NO PARSEA RICH TEXT en el
// HintText: el HTML del hint es cosa de TF2; en la familia L4D (y hasta
// en CS:GO — hilo AlliedMods "Font size and color are broken in CSGO
// HintText", t=319760) el parser no existe y los tags salen crudos. La
// "receta Amy" de la v2.1 era un espejismo: los hints "coloreados" de
// este server (Furia Protectora, Momentum, etc.) SIEMPRE mostraron los
// tags literales y nadie lo había reportado hasta que la barra lo puso
// en pantalla a 5 Hz.
//
// LA SOLUCION (la que pidió el owner, palabra por palabra): MIGRAR LA
// BARRA AL CHAT coloreada con la PALETA L4D2 del colors.inc v2.0.0-MC
// que ya vive en el tree del server. El chat es exactamente la esquina
// inferior-izquierda que el owner marco en la captura, y colors.inc es
// la biblioteca pensada para ese canal:
//   {default}    \x01               — blanco palido (labels y números)
//   {green}      \x04               — AMARILLO vivo en L4D2 (¡ojo: no
//                                     es verde! — documentado por exvel)
//   {lightgreen} \x03 autor server  — verde claro suave
//   {blue}       \x03 equipo 2      — azul (survivors: SIEMPRE hay)
//   {red}        \x03 equipo 3      — rojo (requiere un infectado en
//                                     juego — SI NO HAY, colors.inc lo
//                                     degrada a {green}: aceptado)
//   {olive}      \x05               — oliva apagado (el riel vacío)
// REGLA DURA del colors.inc: MÁXIMO UN color de equipo (\x03) por
// mensaje — usar dos lanza ThrowError. Por eso cada línea de barra
// lleva UN SOLO color de estado (el de las celdas llenas y el tag), y
// default/olive son libres porque no son de equipo.
//
// ANTI-SPAM (el chat no es un panel: cada línea se apila y las viejas
// suben y se apagan a los hud_saytext_time ~12s): el think SIGUE
// calculando a 5 Hz (transiciones al instante) pero SOLO ESCRIBE:
//   - cuando el CONTENIDO cambia (celdas/numeritos)  -> respetando
//     sbar_chat_interval (default 1.0s de distancia mínima);
//   - cuando cambia el TAG de estado (LEVITANDO! / VACÍA! / MODO SOL /
//     RECARGA / ESQUIVA!...) -> pasa antes (0.30s) porque ES el evento
//     que el jugador necesita ver al momento;
//   - cuando la barra esta QUIETA -> re-impresión de keep-alive cada
//     sbar_chat_refresh (default 12.0s = hud_saytext_time default: la
//     barra nunca desaparece; 0 = dejarla desvanecer en reposo).
// Colores por personaje (la identidad de la .81 traducida a la paleta):
//   BLAZE  LLAMA SOL: lleno {green}=AMARILLO fuego / medio
//          {lightgreen} / bajo {olive} / VACÍA {red} (parpadeo rojo
//          <-> oliva por impresión) — tags DRAIN!/FLAME!/MODO SOL
//   SILVER VUELO: volando {lightgreen} LEVITANDO! / RECARGA {green}
//          amarillo / poca carga {olive} / VACÍA {red}
//   SONIC  ANILLOS: lleno y medio {blue} AZUL (equipo survivor — su
//          color) / bajo {green} aviso / SIN ANILLOS! {red}
//
// CANAL ALTERNATIVO sbar_channel 1: la caja negra del hint con TEXTO
// PLANO (sin un solo <font> — nada de tags literales) para comparar o
// si el owner prefiere la caja. RETIRADO sbar_size (murió con el rich
// text del hint; línea muerta inofensiva en cfgs viejos).
// =====================================================================
#if defined _sbar_included
 #endinput
#endif
#define _sbar_included

#define SBAR_INC_VERSION "v3.0-OM"

#define SBAR_REFRESH   0.20   // 5 Hz de CALCULO (transiciones al instante);
                              // la ESCRITURA del chat va throttled abajo

// ------------------ el estado a pintar ------------------
// Interfaz v2.x INTACTA: el <Char>_BarState del personaje lo llena
// ANTES de que el manager llame a SBar_Paint(client, true).
float g_fSBarFrac;            // 0..1 (fracción de relleno)
int   g_iSBarNum;             // numerador impreso ("14/20")
int   g_iSBarDen;             // denominador impreso
bool  g_bSBarBlink;           // true = VACÍA: alterna rojo/oliva
char  g_sSBarLabel[20];       // "LLAMA SOL" / "VUELO" / "ANILLOS"
char  g_sSBarTag[36];         // "MODO SOL" / "LEVITANDO!" / ...
int   g_iSBarChatColor;       // v3.0: color del CHAT (paleta colors.inc)
                             // (v2.x tenía g_iSBarR/G/B para el rich text
                             //  del hint: RETIRADOS con la autopsia — L4D2
                             //  no parsea <font> y nadie los leia ya)

// la paleta del chat (tags del colors.inc, perfil L4D2)
#define SBAR_CHAT_DEFAULT   0   // {default} \x01
#define SBAR_CHAT_GREEN     1   // {green}   \x04 = AMARILLO en L4D2
#define SBAR_CHAT_LIGHTGR   2   // {lightgreen} \x03(server)
#define SBAR_CHAT_BLUE      3   // {blue}    \x03(equipo 2 survivor)
#define SBAR_CHAT_OLIVE     4   // {olive}   \x05
#define SBAR_CHAT_RED       5   // {red}     \x03(equipo 3 infectado)

// ------------------ estado del motor ------------------
bool  g_bSBarShown[MAXPLAYERS + 1];      // canal hint: último paint visible
bool  g_bSBarBlinkPh[MAXPLAYERS + 1];    // fase del parpadeo VACÍA (por IMPRESION)
char  g_sSBarLastSig[MAXPLAYERS + 1][160];   // lo último ESCRITO en el chat (sin tags)
char  g_sSBarLastTag[MAXPLAYERS + 1][36];    // último tag escrito (transición = prioridad)
float g_fSBarLastPr[MAXPLAYERS + 1];         // cuando se escribio la última línea

ConVar g_cvSBarOn, g_cvSBarChannel, g_cvSBarCells, g_cvSBarLines,
       g_cvSBarChatIv, g_cvSBarChatRf, g_cvSBarFill, g_cvSBarEmpty;

// reset del estado compartido (cada BarState lo invoca primero)
void SBar_Clear()
{
    g_fSBarFrac = 0.0;
    g_iSBarNum  = 0;
    g_iSBarDen  = 0;
    g_bSBarBlink = false;
    g_sSBarLabel[0] = '\0';
    g_sSBarTag[0]   = '\0';
    g_iSBarChatColor = SBAR_CHAT_LIGHTGR;
}

// leer la celda de un convar (primer char); vacío/null -> fallback.
// ASCII por defecto: la fuente del chat garantiza "#" y "-"
void SBar_CellRead(char[] out, int maxlen, ConVar cv, const char[] fallback)
{
    out[0] = '\0';
    if (cv != null) cv.GetString(out, maxlen);
    if (out[0] == '\0') strcopy(out, maxlen, fallback);
}

// copiar una celda (1-4 bytes) al buffer; devuelve el nuevo n
int SBar_AppendCell(char[] out, int n, const char[] cell)
{
    for (int b = 0; b < 4 && cell[b] != '\0'; b++) { out[n] = cell[b]; n++; }
    out[n] = '\0';
    return n;
}

// nombre del tag colors.inc de un color de paleta
void SBar_ColName(int col, char[] out, int maxlen)
{
    switch (col)
    {
        case SBAR_CHAT_GREEN:   strcopy(out, maxlen, "green");
        case SBAR_CHAT_BLUE:    strcopy(out, maxlen, "blue");
        case SBAR_CHAT_OLIVE:   strcopy(out, maxlen, "olive");
        case SBAR_CHAT_RED:     strcopy(out, maxlen, "red");
        default:                strcopy(out, maxlen, "lightgreen");
    }
}

// copia el tag SIN digitos ni puntos (para detectar TRANSICIONES de
// verdad: el "RECARGA 8s" de Silver cambia cada segundo y NO debe
// colarse como transición — sino el countdown imprimiria a 3 líneas/s)
void SBar_TagAlpha(const char[] tag, char[] out, int maxlen)
{
    int n = 0;
    for (int i = 0; tag[i] != '\0' && n < maxlen - 1; i++)
    {
        char c = tag[i];
        if (c == '.') continue;
        if (c >= '0' && c <= '9') continue;
        out[n] = c; n++;
    }
    out[n] = '\0';
}

// LA PINTADA. canal 0 (default) = CHAT con colors.inc, throttled;
// canal 1 = caja negra del hint con TEXTO PLANO (refresh por tick).
// Ocultar: el chat no se limpia (la línea se apaga sola), el hint si.
void SBar_Paint(int client, bool visible)
{
    bool chat = (g_cvSBarChannel == null || g_cvSBarChannel.IntValue == 0);

    // ---- ocultar ----
    if (!visible)
    {
        if (chat)
        {
            // reset del cache: al volver a haber barra se escribe fresca
            g_sSBarLastSig[client][0] = '\0';
            g_sSBarLastTag[client][0] = '\0';
            g_fSBarLastPr[client] = 0.0;
            return;
        }
        if (!g_bSBarShown[client]) return;   // no pintar blanks eternos
        PrintHintText(client, " ");
        g_bSBarShown[client] = false;
        return;
    }

    // ---- dimensiones vivas (convars, con clamp) ----
    int cells = (g_cvSBarCells != null) ? g_cvSBarCells.IntValue : 20;
    if (cells < 4)  cells = 4;
    if (cells > 26) cells = 26;   // chat: la línea completa no debe hacer wrap
    int rows = (g_cvSBarLines != null) ? g_cvSBarLines.IntValue : 1;
    if (rows < 1) rows = 1;
    if (rows > 2) rows = 2;       // SOLO canal hint; el chat es 1 línea

    // ---- celdas: llenas + vacías (convars; fallback ASCII) ----
    char cellFill[5], cellEmpty[5];
    SBar_CellRead(cellFill,  sizeof(cellFill),  g_cvSBarFill,  "#");
    SBar_CellRead(cellEmpty, sizeof(cellEmpty), g_cvSBarEmpty, "-");

    int fill = RoundToFloor(g_fSBarFrac * float(cells) + 0.001);
    if (fill > cells) fill = cells;
    if (fill < 0)    fill = 0;

    // ---- la fila de celdas PLANA (la firma de cambio) ----
    char bar[128];
    int nb = 0;
    bar[nb] = '['; nb++;
    for (int c2 = 0; c2 < cells; c2++)
    {
        if (c2 < fill) nb = SBar_AppendCell(bar, nb, cellFill);
        else           nb = SBar_AppendCell(bar, nb, cellEmpty);
    }
    bar[nb] = ']'; nb++;
    bar[nb] = '\0';

    // ---- la línea de texto: label + barra + numeritos + tag ----
    char txt[160];
    if (g_sSBarLabel[0] != '\0')
    {
        if (g_sSBarTag[0] != '\0')
            Format(txt, sizeof(txt), "%s %s %d/%d  %s", g_sSBarLabel, bar, g_iSBarNum, g_iSBarDen, g_sSBarTag);
        else
            Format(txt, sizeof(txt), "%s %s %d/%d", g_sSBarLabel, bar, g_iSBarNum, g_iSBarDen);
    }
    else
    {
        Format(txt, sizeof(txt), "%s %d/%d", bar, g_iSBarNum, g_iSBarDen);
    }

    // ================= CANAL 1: HINT PLANO =================
    // sin un solo <font> — texto plano, la caja negra de siempre pero
    // legible (nada de tags literales). Refresh por tick (el hint se
    // apaga solo a los ~7s si no se refresca)
    if (!chat)
    {
        char msg[256];
        strcopy(msg, sizeof(msg), txt);
        for (int l = 1; l < rows; l++)
            Format(msg, sizeof(msg), "%s\n%s", msg, bar);
        PrintHintText(client, "%s", msg);
        g_bSBarShown[client] = true;
        return;
    }

    // ================= CANAL 0: CHAT colors.inc =================
    // el color de estado: la VACÍA alterna rojo <-> oliva POR IMPRESION
    int col = g_iSBarChatColor;
    if (g_bSBarBlink) col = g_bSBarBlinkPh[client] ? SBAR_CHAT_RED : SBAR_CHAT_OLIVE;

    char colName[16], colTag[20];
    SBar_ColName(col, colName, sizeof(colName));
    Format(colTag, sizeof(colTag), "{%s}", colName);

    // la línea coloreada: {default}LABEL [{COLOR}llenas{olive}vacías
    // {default}] num/den {COLOR}tag — UN solo color de equipo por línea
    char line[224];
    int n = Format(line, sizeof(line), "{default}%s [{%s}", g_sSBarLabel, colTag);
    for (int c2 = 0; c2 < fill; c2++)
        n += Format(line[n], sizeof(line) - n, "%s", cellFill);
    n += Format(line[n], sizeof(line) - n, "{olive}");
    for (int c2 = fill; c2 < cells; c2++)
        n += Format(line[n], sizeof(line) - n, "%s", cellEmpty);
    n += Format(line[n], sizeof(line) - n, "{default}] %d/%d", g_iSBarNum, g_iSBarDen);
    if (g_sSBarTag[0] != '\0')
        Format(line[n], sizeof(line) - n, "  {%s}%s", colName, g_sSBarTag);

    // ---- el THROTTLE: decidir si esta línea se escribe o se calla ----
    float now = GetEngineTime();
    float iv  = (g_cvSBarChatIv != null) ? g_cvSBarChatIv.FloatValue : 1.0;
    float rf  = (g_cvSBarChatRf != null) ? g_cvSBarChatRf.FloatValue : 12.0;

    bool changed = !StrEqual(txt, g_sSBarLastSig[client], false);
    if (!changed)
    {
        // quieta: keep-alive para que no se apague del todo
        if (rf <= 0.0) return;
        if (now - g_fSBarLastPr[client] < rf) return;
    }
    else
    {
        // transición de TAG pasa antes que un cambio de celdas — pero
        // comparada SIN numeritos (el countdown de RECARGA cambia de
        // tag cada segundo: es un cambio de CONTENIDO, no transición)
        char tg[36], tgL[36];
        SBar_TagAlpha(g_sSBarTag, tg, sizeof(tg));
        SBar_TagAlpha(g_sSBarLastTag[client], tgL, sizeof(tgL));
        bool tagchg = !StrEqual(tg, tgL, false);
        float gap = tagchg ? 0.30 : iv;
        if (now - g_fSBarLastPr[client] < gap) return;
    }

    // ---- ESCRIBIR (colors.inc resuelve el autor del color de equipo) ----
    C_PrintToChat(client, "%s", line);
    strcopy(g_sSBarLastSig[client], sizeof(g_sSBarLastSig[]), txt);
    strcopy(g_sSBarLastTag[client], sizeof(g_sSBarLastTag[]), g_sSBarTag);
    g_fSBarLastPr[client] = now;
    if (g_bSBarBlink) g_bSBarBlinkPh[client] = !g_bSBarBlinkPh[client];
}

// convars del motor — una sola barra para TODOS los personajes (un
// jugador es un personaje a la vez). NOTA v3.0: sbar_size RETIRADO
// (el rich text del hint murió con la autopsia de la v3.77.84; si
// quedó en el Sonic_Suite.cfg es una línea muerta inofensiva). Las
// sbar_x/_y/_dy/_channel de la era game_text siguen siendo inofensivas
// si quedan en cfgs viejos
void SBar_OnPluginStart()
{
    g_cvSBarOn      = CreateConVar("sbar_enable",  "1",  "v3.77.85: 1 = barras de recurso visibles (Llama Sol de Blaze / Vuelo de Silver / Anillos de Sonic / Combustible de Vuelo de Tails / Energía de Rouge)");
    g_cvSBarChannel = CreateConVar("sbar_channel", "0",  "v3.77.84: CANAL de la barra: 0 = CHAT abajo-izquierda con los colores del colors.inc (donde la pidió el owner) | 1 = la caja negra del hint con texto plano (sin color)", _, true, 0.0, true, 1.0);
    g_cvSBarCells   = CreateConVar("sbar_cells",   "20", "v3.77.84: segmentos de la barra (tope 26 = la línea del chat no hace wrap)", _, true, 4.0, true, 26.0);
    g_cvSBarLines   = CreateConVar("sbar_lines",   "1",  "v3.77.84: filas de la barra (SOLO el canal hint 1; el chat es UNA línea)", _, true, 1.0, true, 2.0);
    g_cvSBarChatIv  = CreateConVar("sbar_chat_interval", "1.0", "v3.77.84: seg mínimos entre líneas del chat cuando cambia el contenido (las transiciones de tag LEVITANDO!/VACÍA! pasan antes, 0.3s)", _, true, 0.30, true, 5.0);
    g_cvSBarChatRf  = CreateConVar("sbar_chat_refresh",  "12.0", "v3.77.84: re-impresión de la barra QUIETA para que no se apague (12 = hud_saytext_time default: siempre visible; 0 = dejarla desvanecer en reposo)", _, true, 0.0, true, 30.0);
    g_cvSBarFill    = CreateConVar("sbar_fill",   "#",  "v3.77.84: celda LLENA (ASCII seguro para la fuente del chat)");
    g_cvSBarEmpty   = CreateConVar("sbar_empty",  "-",  "v3.77.84: celda VACÍA");
}

// =====================================================================
// v3.77.84: LA SONDA DEL CANAL — sm_sbarprobe <1..6>, REESCRITA para el
// canal nuevo. Mantiene 12s la variante (el chat a cadencia 2s = 6
// líneas; el hint por tick). Diagnostico de un vistazo:
//   1 = CHAT lightgreen  (la paleta base — autor server: SIEMPRE sale)
//   2 = CHAT green       (en L4D2 sale AMARILLO — el "verde" del
//                         colors.inc ES amarillo en este juego)
//   3 = CHAT red         (color de EQUIPO: si sale amarillo es que no
//                         hay ningún infectado en juego en ese momento)
//   4 = CHAT blue        (equipo survivor — el azul de Sonic: SIEMPRE
//                         hay un survivor: el propio jugador)
//   5 = HINT PLANO       (la caja negra con texto plano, sin tags)
//   6 = LA BARRA REAL    (grupo de control: cae al pintado normal)
// =====================================================================
float g_fSBarProbeUntil[MAXPLAYERS + 1];
int   g_iSBarProbeMode[MAXPLAYERS + 1];
float g_fSBarProbeNext[MAXPLAYERS + 1];

// lo invoca T_SBarThink cuando el cliente está en ventana de probe (el
// modo 6 NO llega aquí: es el grupo de control — el think pinta la barra
// real como si no hubiera probe, allí mismo en el manager)
void SBar_SendProbe(int client)
{
    float now = GetEngineTime();
    if (now < g_fSBarProbeNext[client]) return;   // chat: cadencia 2s
    g_fSBarProbeNext[client] = now + 2.0;

    switch (g_iSBarProbeMode[client])
    {
        case 1:
            C_PrintToChat(client, "{lightgreen}PRUEBA 1 [##########{olive}----------{default}] 10/20 {lightgreen}lightgreen = verde claro (autor server, SIEMPRE)");
        case 2:
            C_PrintToChat(client, "{green}PRUEBA 2 [##########{olive}----------{default}] 10/20 {green}green = AMARILLO en L4D2");
        case 3:
            C_PrintToChat(client, "{red}PRUEBA 3 [##########{olive}----------{default}] 10/20 {red}red (si sale AMARILLO no hay infectados en juego)");
        case 4:
            C_PrintToChat(client, "{blue}PRUEBA 4 [##########{olive}----------{default}] 10/20 {blue}blue = azul survivor (el de Sonic)");
        case 5:
            PrintHintText(client, "PRUEBA 5: HINT PLANO\n[##########----------]\nsin tags ni colores — la caja negra de siempre");
    }
}

// sm_sbarprobe <1..6> — consola del owner (MODO SOLO incluido)
public Action SBar_ProbeCmd(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO
    if (client <= 0)
    {
        ReplyToCommand(client, "[SBar] no se a quien mandarle el probe (conectate y usalo en juego)");
        return Plugin_Handled;
    }
    int mode = 1;
    if (args >= 1) mode = GetCmdArgInt(1);
    if (mode < 1 || mode > 6) mode = 1;
    g_iSBarProbeMode[client]  = mode;
    g_fSBarProbeUntil[client] = GetEngineTime() + 12.0;
    g_fSBarProbeNext[client]  = 0.0;
    ReplyToCommand(client, "[SBar] PROBE %d al aire por 12s — mira el CHAT abajo-izquierda (5 = la caja del hint; 6 = barra real)", mode);
    return Plugin_Handled;
}
