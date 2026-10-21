/*
 * ======================================================
 *  [MODULO] OM Stun v2.4 - EL STUN UNIFICADO DEL SUITE - Port del GMod
 *  [Pill Pack] Outcome Memories (noodles_om_pills_status.lua)
 *
 *  v2.4 (suite 3.77.85): FIX DEL MACRO OM_StunValid — el rango se
 *   escribía "1 <= %1 <= MaxClients" que en SourcePawn NO filtra
 *   NADA (asociatividad: (1 <= 464) = 1 -> 1 <= MaxClients = TRUE):
 *   cualquier llamada con un NPC (común/witch de entidad 400+,
 *   como hacia el Burning Javelin de Blaze v2.8-v2.9 con cada
 *   enganche a un común) pasaba el "chequeo de rango" y reventaba
 *   en IsClientInGame con el error nativo "Invalid client index
 *   464" CADA TICK del arrastre — el mismo 464/467/469 de los
 *   reportes de crash. Forma explícita: 1 <= %1 && %1 <= MaxClients.
 *   (Para los players el comportamiento es IDENTICO; para los NPCs
 *   ahora devuelve false en silencio, como siempre debio ser).
 *
 *  v2.3 (suite 3.77.73, pedido del owner 2026-10-15 — "El Stun de OM
 *   no produce stagger al enemigo? xq cuando amy le aplica ragdoll
 *   o alguien stunea como blaze simplemente no funciona. ejemplo el
 *   tank sigue lanzando la roca o el hunter aunque le pegues te puede
 *   agarrar igual"):
 *   - AUTOPSIA: el congelado (FL_FROZEN + lagged 0 + anim pausada)
 *   detiene el CUERPO del especial pero NO cancela su ACCION en
 *   curso. Las abilities de los SI (roca del tank, pounce del
 *   hunter, lengua del smoker, embestida del charger, jockey) corren
 *   por el SISTEMA DE ACCIONES del motor, que sigue vivo por debajo
 *   del congelado: la roca sale igual, el pounce completa el agarre.
 *   El stagger del v2.0 (OM_STUN_F_STAGGER) solo disparaba AL
 *   LIBERAR — o sea DESPUÉS de que el dano ya estaba hecho.
 *   - FIX: STAGGER AL ENTRAR. En la PRIMERA aplicación del stun (no
 *   en los re-stuns del arrastre), ANTES de congelar, se dispara
 *   SIStagger_Auto sobre la victima infectada:
 *   CTerrorPlayer::OnStaggered (L4D_StaggerPlayer) es LA rutina del
 *   motor que ABORTA la acción en curso — la roca del tank se le
 *   suelta de las manos, el hunter en pleno pounce cae al suelo, la
 *   lengua del smoker se libera, el charger frena en seco. DESPUÉS
 *   se congela (estatua como siempre). La red de seguridad del
 *   SI_Stagger (L4D_CancelStagger programado) limpia el stumble si
 *   el bot se atasca; un re-stagger (el de liberar del rayo, otro
 *   stun) REEMPLAZA el cancel pendiente — nunca un cancel viejo
 *   corta un stagger nuevo.
 *   - Guardas: solo equipo infectado VIVO (mismo guard que el
 *   stagger al liberar — jamás se tambalea a un superviviente ni a
 *   un cadaver) y solo en el primer stun del ciclo. La WITCH no es
 *   player y va por su propio sistema (Sonic_WitchStun): INTACTA.
 *   - Convar: om_stun_interrupt 1 (0 = comportamiento v2.2 exacto:
 *   congelar sin abortar, para comparar A/B).
 *   - CERO cambio en el amplificador v2.2 (suite_dmg_*): intacto.
 *
 *  v2.2 (suite 3.77.59, pedido del owner 2026-10-13): EL AMPLIFICADOR
 *   CENTRAL DE DANIO DEL SUITE. Reporte del owner: "hay que aumentar
 *   el dano de las habilidades de los personajes (xq?) o sea un tank
 *   tiene en experto 8000 de vida el ataque apenas le quita 130 150?
 *   joder incluso hasta las armas de los supervivientes pegan mucho
 *   más... meatwall 50k y scp 15k... el dano de los cuerpos de OM es
 *   una miseria. No busco que esten rotos pero deberían pegar algo".
 *   HIBRIDO (2 convars, ajustables en vivo + autoguardado):
 *     suite_dmg_scale    (2.0) multiplicador PLANO de todo el dano de
 *                        habilidad del suite (0-0.35 = nerf, 1 = igual)
 *     suite_dmg_boss_hp  (1000) umbral: objetivo con esta vida o más
 *                        cuenta como JEFE (tank 8000+, meatwall 50k,
 *                        scp 15k, witch 1000...)
 *     suite_dmg_boss_pct (0.035) % de la vida ACTUAL que se SUMA al
 *                        dano contra jefes: tank experto = +280 por
 *                        golpe, meatwall = +1750, scp = +525. Escala
 *                        SOLO contra sacos de vida.
 *   Punto de entrada: OM_AmpDamage(victim, base) calcula el dano
 *   final; OM_AbilityDamage(victim, attacker, base, dmgType) es el
 *   SDKHooks_TakeDamage del suite (misma firma corta). APLICADO:
 *   (1) al dano que VIAJA DENTRO de OM_Stun (choke point: Amy contra,
 *   puño de Knuckles, spindash, rayo de Tails, Metal...) y (2) los
 *   call-sites directos de habilidad re-cableados en sonic/Amy/
 *   Rouge/Knuckles. Lo que NO se toca: ejecuciones (9999), danio a
 *   props, autodano, FF y limpiezas — esos siguen en crudo.
 *
 *  v2.1 (suite 3.77.38, pedido del owner 2026-10-10): SECCION BOOMER
 *   FUSE al final del archivo — la mecha del boomer (Metal: el golpe
 *   LETAL de la embestida no se aplica, el boomer estalla cuando SU
 *   stun termina; Knuckles: el boomer empujado/smash-eado estalla al
 *   tocar el suelo tras volar). Sistema autocontenido: slots EntRef +
 *   timer 10 Hz que nace al marcar y muere solo sin mechas. CERO
 *   cambio en el stun clasico de Sonic/Amy/Metal/Tails.
 *
 *  v2.0 (pedido del owner 2026-10-09 — "no es mejor unificar ambos
 *   stun en un solo documento? ... en si tenemos ragdoll y el stun
 *   de congelamiento y empuje (tails) pero lo que no tiene el stun
 *   de tails es las estrellas ... mejor unifiquemos ese sistema para
 *   ir simplificando todo y no gastemos tanto código en la misma
 *   cosa"):
 *   - EL STUN UNIFICADO: el congelado del rayo de Tails
 *     (Tails_SIFreeze* — ~400 líneas paralelas del Tails.inc
 *     v5.22-v5.26) SE FUSIONA CON ESTE MODULO. Un solo documento para
 *     el stun de Sonic / Amy / Metal / Tails: mismas capas de freeze
 *     (martillo + lagged + pausa de animación), mismos slots por
 *     userid, mismo ticker 20 Hz, mismas estrellas.
 *   - EL RAYO GANA LAS ESTRELLAS (lo que le faltaba): el congelado
 *     por el laser orbita las 3 estrellas amarillas del stun común +
 *     chispas + zap del freeze (om_stun_effects lo apaga todo).
 *   - OPCIONES POR LLAMADA (flags; default 0 = el stun de siempre
 *     para Sonic/Amy/Metal, CERO cambio en ellos):
 *       OM_STUN_F_CYAN     tinte hielo (el rayo) en vez de rojo
 *       OM_STUN_F_PUSH     congelado EMPUJABLE: OM_Stun_Push() lo
 *                          arrastra por el haz (gravedad/terminal/
 *                          deslizamiento/reposo del suelo — receta
 *          Witch_Flight del Tails v5.22: la física del vuelo)
 *       OM_STUN_F_STAGGER  stagger SIEMPRE al liberar (SIStagger_Auto
 *                          con la red de seguridad de SI_Stagger.inc)
 *       OM_STUN_F_FIXED    duración FIJA: los re-stuns no apilan
 *       OM_STUN_F_NOIFRAME sin iframes al terminar (el rayo puede
 *                          re-congelar en caliente)
 *   - NUEVA API: OM_Stun_Push(victim, vel, src) — el rayo (o quien
 *     sea) sigue empujando al congelado SIN tocar el contador.
 *  v1.3 (pedido del owner 2026-10-09 — "si podemos hacer algo pausar
 *   la animación del infectado especial... literalmente es como poner
 *   una pausa en su animación obligándole a que quede congelado (como
 *   pasaría con el FL_Frozen)"):
 *   - PAUSA DE ANIMACION DEL SI CONGELADO (capa compartida): el
 *     FL_FROZEN apaga la IA de un NextBot (la witch queda ESTATUA)
 *     pero los especiales son BOTS DE PLAYER y su animstate sigue
 *     corriendo: congelados se les sigue viendo animar en el sitio.
 *     Nueva API OM_Stun_AnimPause / AnimTick / AnimResume: playback
 *     rate 0 + m_flFrozen (si el prop existe) + secuencia y ciclo
 *     clavados a los del momento de la captura, re-afirmados por el
 *     ticker (el motor pelea las anims igual que pelea el lagged y
 *     el movetype: misma receta del suite). Al liberar se devuelve el
 *     rate ORIGINAL y la IA retoma sus anims sola (el stagger/lo que
 *     toque manda — nunca se restaura la secuencia vieja).
 *   - GATE: solo bots del equipo infectado. Los humanos SI pelearian
 *     la pausa con su cliente, y los supervivientes de Metal siguen
 *     la paridad GMod (el stun del mod NO congela anims de players).
 *   - LA USA TAMBIÉN el congelado del rayo de Tails (v5.26): por eso
 *     el manager ahora incluye este modulo ANTES de Tails.inc (el
 *     #include que traía sonic.inc/Metal.inc queda en no-op por el
 *     guard).
 *  v1.2 (R36 - reporte del owner):
 *   - STUN DE VERDAD: martillo de la WITCH (FL_FROZEN + MOVETYPE_NONE, el
 *     mismo sistema del Witch_Flight/Rouge del suite que ya congela a la
 *     witch): la IA del bot se apaga y la física no integra nada. El
 *     lagged+botones+velocidad-0 queda como capa extra (GMod también
 *     pone SetVelocity 0). Restauración EXACTA al expirar: solo se retira
 *     lo que pusimos nosotros (patron Rouge_WaveRelease).
 *   - FIX ESTRELLAS (fuga): v1.1 creaba 3 sprites NUEVOS en cada re-stun
 *     (cada tick del arrastre) pisando las refs -> estrellas huerfanas
 *     estáticas acumuladas en el aire (por eso "no era circular" ni "no
 *     las elimina"). Ahora SOLO se crean en el primer stun del ciclo.
 *   - Orbita vía TeleportEntity (networking garantizado del env_sprite).
 *
 *  FUENTE (análisis del GMA 3640989797, extraido y auditado):
 *   - lua/autorun/noodles_om_pills_status.lua:
 *     * Mutaul_OMStunCode(DataTable)  -> OM_Stun() de este modulo
 *     * Mutual_OMCanStun()            -> OM_CanStun() de este modulo
 *     * DisablePlayerMovement_OM_stun -> g_fOMStunUntil[] (tiempo de fin)
 *     * SetupMove/CreateMove: forward/side/up = 0 + ClearButtons
 *       -> OM_Stun_OnPlayerRunCmd() (botones a 0, gate del manager)
 *     * StunLimitDuration (clamp 12s) y StunIframesDuration (anti
 *       cadena) -> convars om_stun_maxduration / om_stun_iframes
 *     * Efecto cliente "DizzyStarsEffect_OM_stunned": 3 ESTRELLAS
 *       amarillas girando sobre la cabeza (radio 22, rot time*4,
 *       bob sin(time*3+i)*2) + halo rojo -> ESTRELLAS vía glow
 *       sprites orbitando + tinte rojo + chispas + zap (aquí abajo).
 *   - Metal usa este sistema al ATRAPAR (1.6s), en cada TICK del
 *     arrastre (0.8s) y en cada GOLPE del wall slam (2s), igual que
 *     los convars GMod additionalstun_tic/additionalstun_slam.
 *
 *  QUE HACE (todo server-side, CERO descargas):
 *   1. FREEZE estilo GMod: m_flLaggedMovementValue 0 + botones
 *      limpios (sin ataque/salto/shove) + velocidad cancelada
 *      cada tick (0.1s). El jugador puede MIRAR pero no actuar,
 *      exactamente como DisablePlayerMovement_OM_stun.
 *   2. EFECTOS INCLUIDOS (lo que el owner pidió pasar al L4D2):
 *      - 3 estrellas girando sobre la cabeza (radio 22, GMod exacto)
 *      - chispas electricas periodicas sobre la victima
 *      - sonido zap eléctrico al caer el stun
 *      - tinte rojizo mientras dura (halo GMod aproximado)
 *      - screen shake para victimas humanas (convar, opcional)
 *   3. STACK + CLAMP + IFRAMES como el GMod: re-aturdir a alguien
 *      ya aturdido SUMA (stack), el total se clampa a
 *      om_stun_maxduration y al terminar quedan iframes de
 *      om_stun_iframes donde no puede volver a ser aturdido.
 *   4. DANO estilo DamageInfo del GMod: si damage > 0 se aplica
 *      SDKHooks_TakeDamage al aterrizar el stun (como el
 *      shouldstundamage de Mutaul_OMStunCode).
 *
 *  SEGURIDAD (recetas del suite):
 *   - 1 timer repetitivo por victima (0.1s) validado por USERID
 *     del slot: un ocupante nuevo del slot nunca hereda el stun.
 *   - Cero TIMER_FLAG_NO_MAPCHANGE a propósito (misma decisión que
 *     SI_Stagger.inc: el timer siempre dispara y se limpia solo).
 *   - OM_Stun_OnMapEnd() mata todos los timers y vacía los slots
 *     (cero callbacks con datos del mapa anterior).
 *   - El stun NO toca MOVETYPE (no pisa otros freezes del suite
 *     como el de Rouge): solo lagged + botones + velocidad.
 *   - Restauración total: lagged 1.0, tinte normal, iframes.
 *
 *  API PUBLICA:
 *   - OM_Stun(victim, duration, attacker, damage, dmgType, stack)
 *       -> bool: true si el stun aterrizo (no bloqueado)
 *   - OM_CanStun(victim, stack)  -> chequeo previo (iframes/stack)
 *   - OM_IsStunned(client)       -> sigue congelado?
 *   - OM_Stun_OnPlayerRunCmd(client, &buttons) -> bool: true si
 *      congelado (el manager limpia botones y corta habilidades)
 *   - OM_Stun_Clear(victim)      -> liberación inmediata (sin
 *      iframes: para muertes/cleanup, no combate)
 *   - OM_Stun_OnPluginStart / OnMapStart / OnMapEnd /
 *      OnClientDisconnect  -> cablearlos del manager
 *
 *  CONVARS (caen en sonic_jump_survivors.cfg):
 *   - om_stun_maxduration 12.0  (GMod StunLimitDuration)
 *   - om_stun_iframes     0.5   (GMod StunIframesDuration)
 *   - om_stun_effects     1     (estrellas+chispas+tinte on/off)
 *   - om_stun_shake       1     (screen shake en victimas humanas)
 * ======================================================
 */

#if defined _om_stun_included
    #endinput
#endif
#define _om_stun_included

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
    #include <SI_Stagger>   // v2.0: el stagger al liberar (OM_STUN_F_STAGGER)
#endif

// =======================
// Constantes (GMod parity)
// =======================
#define OM_STUN_FX_TICK        0.05   // v1.1: 20 Hz (órbita fluida como el GMod)
#define OM_STUN_STAR_RADIUS    22.0   // GMod DizzyStars: radius = 22
#define OM_STUN_STAR_HEIGHT    66.0   // sobre el origen (cabeza de un player 72)
#define OM_STUN_STAR_ROT       4.0    // GMod DizzyStars: angle = time*4
#define OM_STUN_STAR_COUNT     3      // GMod DizzyStars: starCount = 3
#define OM_STUN_SPRITE_LIFE    0.12   // vida del glow sprite (> tick: solapa suave)
#define OM_STUN_SPARK_EVERY    6      // chispas cada N ticks (0.3s al tick de 0.05)

// v2.0: física del ARRASTRE (OM_STUN_F_PUSH) — receta integra del
// congelado del rayo de Tails v5.22-v5.26 (que era la receta de la
// witch del Witch_Flight): gravedad manual, terminal, asentado en el
// suelo y deslizamiento por paredes con trace world-only.
#define OM_STUN_PUSH_TICK        0.05    // (= OM_STUN_FX_TICK: el ticker ya corre a 20 Hz)
#define OM_STUN_PUSH_GRAVITY     800.0   // = sv_gravity default (witch/beam usan lo mismo)
#define OM_STUN_PUSH_TERMINAL    1600.0  // velocidad de caida máxima (idem)
#define OM_STUN_PUSH_LIFT        32.0    // colocación sobre el suelo al aterrizar congelado
#define OM_STUN_PUSH_PAD         4.0     // margen anti-tunel (solo alarga el trace, NO mueve)
#define OM_STUN_PUSH_DAMP        0.85    // amortiguación al deslizar por pared/techo
#define OM_STUN_PUSH_NUDGE       16.0    // recolocación pegado al impacto, sin incrustarse
#define OM_STUN_PUSH_FLOOR_Z     0.65    // normal[2] que cuenta como SUELO
#define OM_STUN_PUSH_INCRUST     0.05    // fracción < esto = incrustado: liberar YA

// v2.0: opciones por llamada de OM_Stun() — default 0 = el stun de
// siempre (estrellas + tinte rojo + apilable + iframes, sin empuje).
#define OM_STUN_F_CYAN           (1 << 0)   // tinte hielo cyan (el rayo) en vez de rojo
#define OM_STUN_F_PUSH           (1 << 1)   // congelado empujable (OM_Stun_Push)
#define OM_STUN_F_STAGGER        (1 << 2)   // stagger SIEMPRE al liberar
#define OM_STUN_F_FIXED          (1 << 3)   // duración fija: re-stuns no apilan
#define OM_STUN_F_NOIFRAME       (1 << 4)   // sin iframes al terminar

#define DMG_OM_CLUB            (1 << 7)   // DMG_CLUB (default GMod del stun)

// v2.4: FIX DEL MACRO — "1 <= %1 <= MaxClients" NO filtra nada en
// SourcePawn (asociatividad: (1<=464)=1 -> 1<=32=TRUE): cualquier
// llamada con un NPC (común/witch/tank, entidad 400+) pasaba el
// "rango" y reventaba en IsClientInGame con "Invalid client index
// 464" (el error del reporte de No Mercy). Forma explícita:
#define OM_StunValid(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// Estado
// =======================
float   g_fOMStunUntil[MAXPLAYERS + 1];       // fin del stun (DisablePlayerMovement_OM_stun)
float   g_fOMStunIframeUntil[MAXPLAYERS + 1]; // iframes post-stun (stun_iframe1 GMod)
Handle  g_hOMStunTimer[MAXPLAYERS + 1];       // timer repetitivo de FX (1 por victima)
int     g_iOMStunUserId[MAXPLAYERS + 1];      // userid del slot aturdido (anti herencia)
int     g_iOMStunAttacker[MAXPLAYERS + 1];    // quien aturio (credito de dano)
int     g_iOMStunFXCount[MAXPLAYERS + 1];     // contador de ticks (chispas cada 3)

int     g_iOMStunGlow = 0;                    // glow01.vmt (fallback sin VPK)
bool    g_bOMStunAssets = false;              // v1.1: VPK con assets om_ montado
stock int     g_iOMStunStar = 0;                    // legacy: asignado pero nunca leido
int     g_iOMStunBeam = 0;                    // v1.1: om/beam_glow.vmt (rastro estrellas)
bool    g_bOMStunRealSnd = false;             // v1.1: om/sonic/stun.wav (mod)
int     g_iOMStunStarEnt[MAXPLAYERS + 1][3];  // v1.1: env_sprites de las 3 estrellas
float   g_fOMStunStart[MAXPLAYERS + 1];       // v1.1: inicio (fade in/out GMod Lerp 8x)
int     g_iOMStunTrailCount[MAXPLAYERS + 1];  // v1.1: re-envío del rastro ~0.9s
int     g_iOMStunOrigMT[MAXPLAYERS + 1];      // v1.2: movetype original (0 = sin captura)
bool    g_bOMStunHadFrozen[MAXPLAYERS + 1];   // v1.2: ya tenía FL_FROZEN al caer el stun
bool    g_bOMStunAnimPaused[MAXPLAYERS + 1];  // v1.3: pausa de animación activa (SI)
int     g_iOMStunAnimSeq[MAXPLAYERS + 1];     // v1.3: secuencia capturada al congelar
float   g_fOMStunAnimCycle[MAXPLAYERS + 1];   // v1.3: ciclo capturado al congelar
float   g_fOMStunAnimRate[MAXPLAYERS + 1];    // v1.3: playback rate original
int     g_iOMStunFlags[MAXPLAYERS + 1];       // v2.0: flags del ciclo vigente (CYAN/PUSH/STAGGER/FIXED/NOIFRAME)
float   g_vOMStunPushVel[MAXPLAYERS + 1][3];  // v2.0: velocidad MANUAL del arrastre (NONE no integra)
float   g_fOMStunPushLast[MAXPLAYERS + 1];    // v2.0: reloj del tick (dt real anti lag-spike)
bool    g_bOMStunPushRest[MAXPLAYERS + 1];    // v2.0: asentado en el suelo congelado (sin física)
float   g_vOMStunPushSrc[MAXPLAYERS + 1][3];  // v2.0: origen del empuje (dir del stagger final)

ConVar  g_cvOMStunMaxDur;
ConVar  g_cvOMStunIframes;
ConVar  g_cvOMStunFX;
ConVar  g_cvOMStunShake;
ConVar  g_cvOMStunInterrupt;              // v2.3: stagger al ENTRAR (aborta la acción en curso del SI)

// ============================================================
//  API PUBLICA
// ============================================================

// Sigue congelado?
bool OM_IsStunned(int client)
{
    return (1 <= client <= MaxClients) && IsClientInGame(client)
        && g_fOMStunUntil[client] > GetEngineTime();
}

// Chequeo previo estilo Mutual_OMCanStun:
//  - ya aturdido + stack=true -> SI (refresco, checkoutprevention GMod)
//  - dentro de iframes        -> NO (anti cadena)
//  - ya aturdido sin stack    -> NO
bool OM_CanStun(int victim, bool stack)
{
    if (!OM_StunValid(victim)) return false;

    float now = GetEngineTime();
    if (g_fOMStunUntil[victim] > now)
        return stack;                      // refrescar solo si puede stacear
    if (g_fOMStunIframeUntil[victim] > now)
        return false;                      // iframes post-stun
    return true;
}

// El corazon: port de Mutaul_OMStunCode. Devuelve true si aterrizo.
// v2.0: flags configura el ciclo (default 0 = el stun de siempre:
// estrellas + tinte rojo + apilable + iframes, sin empuje/stagger).
bool OM_Stun(int victim, float duration, int attacker = 0,
             float damage = 0.0, int dmgType = DMG_OM_CLUB, bool stack = true,
             int flags = 0)
{
    if (!OM_StunValid(victim)) return false;
    // v2.0: FIXED = duración inamovible (el rayo: "el rayo JAMÁS
    // reinicia el contador") — ni con stack=true un re-stun apila.
    if ((flags & OM_STUN_F_FIXED) != 0 && OM_IsStunned(victim)) return false;
    if (!OM_CanStun(victim, stack)) return false;

    float now = GetEngineTime();

    // GMod: stack (suma sobre el restante) + clamp a StunLimitDuration
    float until;
    if (g_fOMStunUntil[victim] > now)
        until = g_fOMStunUntil[victim] + duration;
    else
        until = now + duration;

    float maxDur = 12.0;
    if (g_cvOMStunMaxDur != null)
        maxDur = g_cvOMStunMaxDur.FloatValue;
    if (maxDur > 0.0 && (until - now) > maxDur)
        until = now + maxDur;

    bool wasStunned = (g_fOMStunUntil[victim] > now);
    g_fOMStunUntil[victim] = until;
    g_iOMStunAttacker[victim] = attacker;
    if (!wasStunned)
    {
        g_iOMStunUserId[victim] = GetClientUserId(victim);
        g_iOMStunFXCount[victim] = 0;

        // v1.2: capturar el estado ORIGINAL (solo la primera vez: los
        // re-stuns del arrastre no lo pisan) para la restauración exacta.
        g_iOMStunOrigMT[victim] = view_as<int>(GetEntityMoveType(victim));
        g_bOMStunHadFrozen[victim] = (GetEntityFlags(victim) & FL_FROZEN) != 0;

        // v2.3: STAGGER AL ENTRAR — ANTES del congelado. OnStaggered
        // (motor) ABORTA la acción en curso del especial: la roca del
        // tank se suelta, el pounce del hunter se corta en el aire, la
        // lengua del smoker se libera, el charger frena. Congelado ya
        // NO se puede: el sistema de acciones sigue vivo bajo FL_FROZEN
        // (por eso el tank terminaba lanzando la roca igual). Solo el
        // PRIMER stun del ciclo (un congelado no puede iniciar acciones)
        // y solo infectados vivos (mismo guard del stagger al liberar).
        OM_Stun_Interrupt(victim, attacker);

        OM_Stun_Freeze(victim);

        // v1.3: capturar la pose y pausar la ANIMACION (el gate de SI
        // bot vive dentro de AnimPause). Solo en el primer stun del
        // ciclo: los re-stuns del arrastre conservan la captura (mismo
        // patron del movetype/flag de arriba).
        OM_Stun_AnimPause(victim);

        // v2.0: flags del ciclo + estado del arrastre listo (mismo
        // "solo el primero captura": un re-stun NUNCA cambia la
        // configuración de un congelado en curso — el congelado manda).
        g_iOMStunFlags[victim] = flags;
        float pzero[3] = {0.0, 0.0, 0.0};
        g_vOMStunPushVel[victim] = pzero;   // vel manual: la integra el ticker si es PUSH
        g_bOMStunPushRest[victim] = false;  // despierto (no asentado)
        g_fOMStunPushLast[victim] = now;
        float psrc[3];
        GetClientAbsOrigin(victim, psrc);
        g_vOMStunPushSrc[victim] = psrc;    // dir del stagger final si nunca lo empujan
    }

    // ---- FREEZE (DisablePlayerMovement_OM_stun) ----
    SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", 0.0);
    float zero[3] = {0.0, 0.0, 0.0};
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, zero);

    // ---- EFECTOS DE ARRANQUE (los que trae el stun INCLUIDOS) ----
    // v1.1: sonido REAL del mod (OM/sonic/stun.wav); fallback zap1 de HL2
    if (g_bOMStunRealSnd)
        EmitSoundToAll("om/sonic/stun.wav", victim);
    else if (g_iOMStunGlow > 0)
        EmitSoundToAll("ambient/energy/zap1.wav", victim);

    // v1.1: estrellas = env_sprites con el ARTE REAL del GMod
    // (Material("icons/Skyxboxer_stareffect") tinte amarillo 255 255 0)
    g_fOMStunStart[victim] = GetEngineTime();
    g_iOMStunTrailCount[victim] = 0;
    // v1.2 FIX FUGA: estrellas SOLO en el primer stun del ciclo (en los
    // re-stuns del arrastre/slam ya existen y siguen orbitando; crearlas
    // de nuevo dejaba las viejas huerfanas en el aire para siempre).
    if (!wasStunned && g_bOMStunAssets)
        OM_Stun_CreateStars(victim);

    if (g_cvOMStunFX == null || g_cvOMStunFX.BoolValue)
    {
        if (flags & OM_STUN_F_CYAN)
            SetEntityRenderColor(victim, 150, 220, 255, 255);  // v2.0: hielo (el rayo)
        else
            SetEntityRenderColor(victim, 255, 90, 90, 255);   // halo rojizo GMod
    }

    // Screen shake solo para humanas (bots no lo necesitan)
    if (!IsFakeClient(victim))
        OM_Stun_DoShake(victim, 1.0);

    // ---- DANO estilo DamageInfo del GMod (shouldstundamage) ----
    // v2.2: AMPLIFICADO por el HIBRIDO del suite (choke point: todo el
    // dano que viaja dentro de un stun de habilidad pasa por aquí)
    if (damage > 0.0)
    {
        float ampDmg = OM_AmpDamage(victim, damage);
        if (attacker > 0 && IsClientInGame(attacker))
            SDKHooks_TakeDamage(victim, attacker, attacker, ampDmg, dmgType);
        else
            SDKHooks_TakeDamage(victim, victim, victim, ampDmg, dmgType);
    }

    // ---- TICKER DE FX (uno por victima) ----
    if (g_hOMStunTimer[victim] == null)
        g_hOMStunTimer[victim] = CreateTimer(OM_STUN_FX_TICK, T_OM_StunFX, victim, TIMER_REPEAT);

    return true;
}

// Gate del RunCmd (SetupMove/CreateMove del GMod): devuelve true si el
// jugador está congelado (el manager limpia botones y corta habilidades).
bool OM_Stun_OnPlayerRunCmd(int client, int &buttons)
{
    if (g_fOMStunUntil[client] <= GetEngineTime()) return false;
    buttons = 0;   // GMod: cmd:ClearButtons() — sin atacar/saltar/shove
    return true;
}

// v2.0: el arrastre del congelado (ex Tails_SIFreezePush). El rayo (o
// cualquier caller PUSH) actualiza la velocidad MANUAL que el ticker
// integra SIN tocar el contador del stun — "puede seguir empujando si
// pero el tiempo de stun no se reiniciara". Despierta al asentado.
// No-op si el slot no está congelado o no nació PUSH (p.ej. un
// congelado por Metal: el rayo no lo arrastra, lo respeta).
void OM_Stun_Push(int victim, const float vel[3], const float src[3])
{
    if (victim < 1 || victim > MaxClients) return;
    if (!OM_IsStunned(victim)) return;
    if ((g_iOMStunFlags[victim] & OM_STUN_F_PUSH) == 0) return;

    g_vOMStunPushVel[victim] = vel;    // SET: el haz lo CARGA (como a la witch)
    g_vOMStunPushSrc[victim] = src;    // el stagger final sale de la última dirección del empuje
    g_bOMStunPushRest[victim] = false; // despierta del reposo en el suelo
}

// Liberación inmediata SIN iframes (muertes, cleanup, desconexiones).
void OM_Stun_Clear(int victim)
{
    if (victim < 1 || victim > MaxClients) return;

    OM_Stun_Unfreeze(victim);
    OM_Stun_AnimResume(victim);   // v1.3: devolver la animación (no-op sin captura)
    OM_Stun_KillStars(victim);

    if (g_hOMStunTimer[victim] != null)
    {
        KillTimer(g_hOMStunTimer[victim]);
        g_hOMStunTimer[victim] = null;
    }

    g_fOMStunUntil[victim] = 0.0;
    g_fOMStunIframeUntil[victim] = 0.0;
    g_iOMStunUserId[victim] = 0;
    g_iOMStunAttacker[victim] = 0;
    g_iOMStunFXCount[victim] = 0;
    g_iOMStunFlags[victim] = 0;          // v2.0: configuración del ciclo fuera
    g_bOMStunPushRest[victim] = false;   // v2.0: despierto

    if (IsClientInGame(victim))
    {
        if (IsPlayerAlive(victim))
            SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntityRenderColor(victim, 255, 255, 255, 255);
    }
}

// ============================================================
//  v1.3: PAUSA DE ANIMACION DEL SI (capa compartida — la usan este
//  modulo y el congelado del rayo de Tails v5.26)
// ============================================================
//  El FL_FROZEN apaga la IA de un NextBot (la witch: estatua TOTAL)
//  pero los especiales son BOTS DE PLAYER: su animstate sigue
//  corriendo y congelados se les ve animar en el sitio. Receta:
//  playback rate 0 + m_flFrozen (si existe el prop) + secuencia y
//  ciclo clavados a los del momento de la captura, re-afirmados por
//  el ticker de cada sistema a 20 Hz — el motor pelea las anims
//  igual que pelea el lagged/movetype (misma receta del suite). Al
//  liberar: rate original; la IA retoma sus anims sola.

#define OM_STUN_SI_TEAM 3   // L4D2: equipo infectado

// Props de anim con fallback Send->Data (patron Sonic_PropSequence)
static int OM_Stun_AnimReadInt(int ent, const char[] prop, int def)
{
    if (HasEntProp(ent, Prop_Send, prop)) return GetEntProp(ent, Prop_Send, prop);
    if (HasEntProp(ent, Prop_Data, prop)) return GetEntProp(ent, Prop_Data, prop);
    return def;
}
static float OM_Stun_AnimReadFloat(int ent, const char[] prop, float def)
{
    if (HasEntProp(ent, Prop_Send, prop)) return GetEntPropFloat(ent, Prop_Send, prop);
    if (HasEntProp(ent, Prop_Data, prop)) return GetEntPropFloat(ent, Prop_Data, prop);
    return def;
}
static void OM_Stun_AnimWriteInt(int ent, const char[] prop, int val)
{
    if (HasEntProp(ent, Prop_Send, prop)) SetEntProp(ent, Prop_Send, prop, val);
    else if (HasEntProp(ent, Prop_Data, prop)) SetEntProp(ent, Prop_Data, prop, val);
}
static void OM_Stun_AnimWriteFloat(int ent, const char[] prop, float val)
{
    if (HasEntProp(ent, Prop_Send, prop)) SetEntPropFloat(ent, Prop_Send, prop, val);
    else if (HasEntProp(ent, Prop_Data, prop)) SetEntPropFloat(ent, Prop_Data, prop, val);
}

// Capturar la pose y clavar YA (la invoca cada sistema al congelar).
// GATE INTERNO: solo bots del equipo infectado — un humano SI pelearia
// la pausa con su cliente y un superviviente sigue la paridad GMod.
void OM_Stun_AnimPause(int victim)
{
    if (!OM_StunValid(victim)) return;
    if (!IsFakeClient(victim) || GetClientTeam(victim) != OM_STUN_SI_TEAM) return;

    g_iOMStunAnimSeq[victim]   = OM_Stun_AnimReadInt(victim, "m_nSequence", 0);
    g_fOMStunAnimCycle[victim] = OM_Stun_AnimReadFloat(victim, "m_flCycle", 0.0);
    g_fOMStunAnimRate[victim]  = OM_Stun_AnimReadFloat(victim, "m_flPlaybackRate", 1.0);
    g_bOMStunAnimPaused[victim] = true;

    OM_Stun_AnimTick(victim);   // clavar ya, sin esperar al ticker
}

// Re-afirmación (la invoca el ticker de cada sistema): rate 0 + frozen
// (si existe) + secuencia y ciclo de la captura. No-op sin captura.
void OM_Stun_AnimTick(int victim)
{
    if (victim < 1 || victim > MaxClients) return;
    if (!g_bOMStunAnimPaused[victim]) return;
    if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return;

    OM_Stun_AnimWriteFloat(victim, "m_flPlaybackRate", 0.0);
    if (HasEntProp(victim, Prop_Send, "m_flFrozen"))
        SetEntPropFloat(victim, Prop_Send, "m_flFrozen", 1.0);
    OM_Stun_AnimWriteInt(victim, "m_nSequence", g_iOMStunAnimSeq[victim]);
    OM_Stun_AnimWriteFloat(victim, "m_flCycle", g_fOMStunAnimCycle[victim]);
}

// Al liberar: devolver el rate ORIGINAL y limpiar la captura. Solo si
// vive (un cadaver no simula); la IA retoma sus anims sola — nunca se
// restaura la secuencia vieja (el stagger de siempre manda).
void OM_Stun_AnimResume(int victim)
{
    if (victim < 1 || victim > MaxClients) return;
    if (!g_bOMStunAnimPaused[victim]) return;

    if (IsClientInGame(victim) && IsPlayerAlive(victim))
    {
        OM_Stun_AnimWriteFloat(victim, "m_flPlaybackRate",
            g_fOMStunAnimRate[victim] > 0.0 ? g_fOMStunAnimRate[victim] : 1.0);
        if (HasEntProp(victim, Prop_Send, "m_flFrozen"))
            SetEntPropFloat(victim, Prop_Send, "m_flFrozen", 0.0);
    }
    g_bOMStunAnimPaused[victim] = false;
    g_iOMStunAnimSeq[victim] = 0;
    g_fOMStunAnimCycle[victim] = 0.0;
    g_fOMStunAnimRate[victim] = 0.0;
}

// ============================================================
//  v2.2 - EL AMPLIFICADOR HIBRIDO DEL SUITE
// ============================================================
//  Todo el dano de habilidad del suite se calcula aquí:
//    final = base x suite_dmg_scale
//            + (vida ACTUAL del objetivo x suite_dmg_boss_pct, SOLO
//               si su vida >= suite_dmg_boss_hp)
//  El % solo entra contra JEFES (tank/meatwall/scp/witch): la horda
//  no cambia (los comunes ya mueren de un golpe) y los especiales
//  solo notan el multiplicador plano. Convars en vivo + auto-guardado
//  en Sonic_Suite.cfg (v96: prefijos con sagrado — suite_ entra solo).

ConVar g_cvSuiteDmgScale, g_cvSuiteDmgBossHP, g_cvSuiteDmgBossPct;

float OM_AmpDamage(int victim, float base)
{
    float dmg = base;

    // (1) multiplicador plano
    if (g_cvSuiteDmgScale != null)
        dmg = base * g_cvSuiteDmgScale.FloatValue;

    // (2) % de vida ACTUAL contra jefes
    if (g_cvSuiteDmgBossPct != null && g_cvSuiteDmgBossPct.FloatValue > 0.0
        && victim > 0 && IsValidEntity(victim))
    {
        int hp = 0;
        if (victim <= MaxClients)
        {
            if (IsClientInGame(victim)) hp = GetClientHealth(victim);
        }
        else if (HasEntProp(victim, Prop_Data, "m_iHealth"))
        {
            hp = GetEntProp(victim, Prop_Data, "m_iHealth");
        }

        float th = (g_cvSuiteDmgBossHP != null) ? g_cvSuiteDmgBossHP.FloatValue : 1000.0;
        if (float(hp) >= th)
            dmg += float(hp) * g_cvSuiteDmgBossPct.FloatValue;
    }

    return dmg;
}

// v2.2: EL TakeDamage DEL SUITE — mismo atajo que usaban los includes
// (inflictor = atacante, dano amplificado). Reemplaza 1:1 los
// SDKHooks_TakeDamage de HABILIDAD (los de sistema/props/execute NO).
void OM_AbilityDamage(int victim, int attacker, float base, int dmgType = DMG_OM_CLUB)
{
    SDKHooks_TakeDamage(victim, attacker, attacker, OM_AmpDamage(victim, base), dmgType);
}

// ============================================================
//  CABLEADO DEL MANAGER
// ============================================================

public void OM_Stun_OnPluginStart()
{
    g_cvOMStunMaxDur  = CreateConVar("om_stun_maxduration", "12.0",
        "Duración máxima total del stun acumulado (GMod StunLimitDuration)",
        FCVAR_NOTIFY, true, 0.0);
    g_cvOMStunIframes = CreateConVar("om_stun_iframes", "0.5",
        "Segundos de inmunidad al terminar un stun (anti cadena, GMod StunIframesDuration)",
        FCVAR_NOTIFY, true, 0.0);
    g_cvOMStunFX      = CreateConVar("om_stun_effects", "1",
        "Efectos visuales del stun: estrellas + chispas + tinte (port GMod)", FCVAR_NOTIFY,
        true, 0.0, true, 1.0);
    g_cvOMStunShake   = CreateConVar("om_stun_shake", "1",
        "Screen shake para victimas humanas al ser aturdidas", FCVAR_NOTIFY,
        true, 0.0, true, 1.0);

    // v2.3: stagger al ENTRAR (aborta la acción en curso del SI)
    g_cvOMStunInterrupt = CreateConVar("om_stun_interrupt", "1",
        "v2.3: stagger al ENTRAR del stun — ABORTA la acción en curso del infectado (roca del tank, pounce del hunter, lengua del smoker, embestida del charger). 0 = comportamiento v2.2 (congelar sin abortar)",
        FCVAR_NOTIFY, true, 0.0, true, 1.0);

    // v2.2: EL AMPLIFICADOR HIBRIDO (pedido del owner: "el dano de los
    // cuerpos de OM es una miseria... no busco que esten rotos pero
    // deberían pegar algo")
    g_cvSuiteDmgScale  = CreateConVar("suite_dmg_scale", "2.0",
        "v2.2: multiplicador PLANO del dano de TODAS las habilidades del suite (1.0 = como antes; 2.0 = doble)",
        FCVAR_NOTIFY, true, 0.0, true, 10.0);
    g_cvSuiteDmgBossHP = CreateConVar("suite_dmg_boss_hp", "1000",
        "v2.2: umbral de JEFE: objetivos con esta vida (o más) reciben el % extra (tank 8000, meatwall 50k, scp 15k)",
        FCVAR_NOTIFY, true, 0.0);
    g_cvSuiteDmgBossPct = CreateConVar("suite_dmg_boss_pct", "0.035",
        "v2.2: % de la vida ACTUAL sumado al dano contra jefes (0.035 = 3.5%: +280 al tank experto, +1750 al meatwall)",
        FCVAR_NOTIFY, true, 0.0, true, 1.0);
}

public void OM_Stun_OnMapStart()
{
    // Sprites y sonidos en fase legitima de precache (v3.25: nunca lazy)
    g_iOMStunGlow = PrecacheModel("materials/sprites/glow01.vmt", true);
    PrecacheSound("ambient/energy/zap1.wav", true);

    // v1.1: ASSETS REALES del mod GMod (VPK "om_"). Gate por FileExists
    // (vía filesystem de Valve = ve los VPK montados): sin VPK montado en
    // el servidor TODO cae al fallback stock — el plugin NUNCA depende
    // del VPK para funcionar.
    g_bOMStunAssets = FileExists("materials/om/star_stun.vmt", true);
    if (g_bOMStunAssets)
    {
        g_iOMStunStar = PrecacheModel("materials/om/star_stun.vmt", true);
        g_iOMStunBeam = PrecacheModel("materials/om/beam_glow.vmt", true);
        g_bOMStunRealSnd = PrecacheSound("om/sonic/stun.wav", true);

        AddFileToDownloadsTable("materials/om/star_stun.vmt");
        AddFileToDownloadsTable("materials/om/star_stun.vtf");
        AddFileToDownloadsTable("materials/om/beam_glow.vmt");
        AddFileToDownloadsTable("materials/om/beam_glow.vtf");
        if (g_bOMStunRealSnd)
            AddFileToDownloadsTable("sound/om/sonic/stun.wav");
    }

    // Slots limpios para el mapa nuevo
    OM_Stun_OnMapEnd();
}

// Mata todos los timers y vacía los slots (cero datos heredados).
// v2.0: antes de vaciar, RESTAURAR a cualquier cliente vivo que llegue
// al fin del mapa con NUESTRO congelado puesto (ex Tails_SIFreezeClearAll:
// martillo/lagged/tint fuera antes de que el mapa nuevo lo note — en
// el OnMapStart del mapa nuevo los slots ya están limpios: no-op).
public void OM_Stun_OnMapEnd()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_fOMStunUntil[i] > 0.0 && IsClientInGame(i) && IsPlayerAlive(i))
        {
            OM_Stun_Unfreeze(i);
            OM_Stun_AnimResume(i);
            SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 1.0);
            SetEntityRenderColor(i, 255, 255, 255, 255);
        }
        OM_Stun_KillStars(i);
        if (g_hOMStunTimer[i] != null)
        {
            KillTimer(g_hOMStunTimer[i]);
            g_hOMStunTimer[i] = null;
        }
        g_fOMStunUntil[i] = 0.0;
        g_fOMStunIframeUntil[i] = 0.0;
        g_iOMStunUserId[i] = 0;
        g_iOMStunAttacker[i] = 0;
        g_iOMStunFXCount[i] = 0;
        g_iOMStunOrigMT[i] = 0;        // v1.2
        g_bOMStunHadFrozen[i] = false; // v1.2
        g_bOMStunAnimPaused[i] = false; // v1.3
        g_iOMStunAnimSeq[i] = 0;
        g_fOMStunAnimCycle[i] = 0.0;
        g_fOMStunAnimRate[i] = 0.0;
        g_iOMStunFlags[i] = 0;         // v2.0
        g_bOMStunPushRest[i] = false;  // v2.0
    }

    // v2.1: mechas del boomer fuera (refs del mapa viejo = inválidas)
    OM_BoomerFuseClearAll();
}

public void OM_Stun_OnClientDisconnect(int client)
{
    if (client < 1 || client > MaxClients) return;
    OM_Stun_Clear(client);
}

// ============================================================
//  NUCLEO: ticker de efectos + fin automático del stun
// ============================================================
public Action T_OM_StunFX(Handle timer, int slot)
{
    // Timer viejo del slot (defensa: nunca debería pasar, los Clear matan)
    if (slot < 1 || slot > MaxClients) return Plugin_Stop;
    if (g_hOMStunTimer[slot] != timer) return Plugin_Stop;

    // Validar por USERID: el slot puede tener un ocupante NUEVO
    int client = GetClientOfUserId(g_iOMStunUserId[slot]);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
    {
        OM_Stun_Clear(slot);
        return Plugin_Stop;
    }

    // Si el slot mudo de cliente (imposible tras el userid check, defensa)
    if (g_fOMStunUntil[client] <= GetEngineTime())
    {
        OM_Stun_Finish(client);
        return Plugin_Stop;
    }

    // ---- RE-AFIRMAR EL FREEZE (GMod lo hace en Think cada frame) ----
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);

    // v1.2: re-affirmar el MARTILLO cada tick (patron Rouge v9.1: si algo
    // externo limpio el movetype o el flag, el congelado intenta
    // reactivarse en pleno stun). FL_FROZEN apaga la IA del bot +
    // MOVETYPE_NONE congela la física: estatua TOTAL, estilo witch.
    if (GetEntityMoveType(client) != MOVETYPE_NONE)
        SetEntityMoveType(client, MOVETYPE_NONE);
    if ((GetEntityFlags(client) & FL_FROZEN) == 0)
        SetEntityFlags(client, GetEntityFlags(client) | FL_FROZEN);

    // v1.3: re-afirmar la PAUSA DE ANIMACION del SI (no-op sin
    // captura: los supervivientes de Metal no la llevan — paridad
    // GMod; el motor pelea las anims igual que el movetype)
    OM_Stun_AnimTick(client);

    // v2.0: RAMA DE ARRASTRE (OM_STUN_F_PUSH — ex T_TailsSIFreezeTick
    // del rayo, receta Witch_Flight): integración MANUAL de la
    // velocidad de empuje con gravedad, trace world-only, asentado en
    // el suelo y deslizamiento por paredes. El congelado NO empujable
    // sigue con el veto de velocidad de toda la vida.
    if (g_iOMStunFlags[client] & OM_STUN_F_PUSH)
    {
        if (OM_Stun_PushTick(client))
            return Plugin_Stop;   // incrustado en geometria: liberado YA
    }
    else
    {
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[0] != 0.0 || vel[1] != 0.0 || vel[2] != 0.0)
        {
            float zero[3] = {0.0, 0.0, 0.0};
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, zero);
        }
    }

    // ---- EFECTOS (port del DizzyStarsEffect_OM_stunned) ----
    if (g_cvOMStunFX == null || g_cvOMStunFX.BoolValue)
    {
        float pos[3];
        GetClientAbsOrigin(client, pos);

        // 3 estrellas girando sobre la cabeza (radio 22, rot time*4,
        // bob vertical sin(time*3+i)*2 — MISMOS números que el GMod)
        float head[3];
        head[0] = pos[0];
        head[1] = pos[1];
        head[2] = pos[2] + OM_STUN_STAR_HEIGHT;

        float t = GetEngineTime();

        // v1.1: fade in/out (GMod: Lerp alpha 8x al aparecer/desaparecer)
        float tLeft  = g_fOMStunUntil[client] - t;
        float tSince = t - g_fOMStunStart[client];
        int starAlpha = 255;
        if (tSince < 0.25)      starAlpha = RoundToNearest(tSince / 0.25 * 255.0);
        else if (tLeft < 0.25)  starAlpha = RoundToNearest(tLeft / 0.25 * 255.0);
        if (starAlpha < 0)   starAlpha = 0;
        if (starAlpha > 255) starAlpha = 255;

        // v1.1: ESTRELLAS REALES — env_sprite con om/star_stun.vmt (arte del
        // GMod) tinte amarillo como Color(255,255,0) + rastro de luz (el
        // GMod dibuja 6 posiciones con fade; BeamFollow lo reproduce).
        // MISMOS números: radio 22, rot time*4, bob sin(time*3+i)*2.
        if (g_bOMStunAssets)
        {
            for (int i = 0; i < OM_STUN_STAR_COUNT; i++)
            {
                int star = EntRefToEntIndex(g_iOMStunStarEnt[client][i]);
                if (star > MaxClients && IsValidEntity(star))
                {
                    float ang = t * OM_STUN_STAR_ROT + (float(i) / float(OM_STUN_STAR_COUNT)) * 6.28318;
                    float sPos[3];
                    sPos[0] = head[0] + Cosine(ang) * OM_STUN_STAR_RADIUS;
                    sPos[1] = head[1] + Sine(ang) * OM_STUN_STAR_RADIUS;
                    sPos[2] = head[2] + Sine(t * 3.0 + float(i)) * 2.0;
                    // v1.2: TeleportEntity mueve el sprite de verdad
                    // (m_vecOrigin a mano no networkea el env_sprite).
                    TeleportEntity(star, sPos, NULL_VECTOR, NULL_VECTOR);
                    SetEntityRenderColor(star, 255, 255, 0, starAlpha);

                    if (g_iOMStunBeam != 0 && g_iOMStunTrailCount[client] >= 18)
                    {
                        int trailColor[4] = {255, 255, 0, 200};
                        TE_SetupBeamFollow(star, g_iOMStunBeam, 0, 1.0, 1.5, 0.4, 1, trailColor);
                        TE_SendToAll();
                        g_iOMStunTrailCount[client] = 0;
                    }
                }
            }
            g_iOMStunTrailCount[client]++;
        }
        else
        {
            // fallback v1.0 (sin VPK): glow01 TE como siempre
            for (int i = 0; i < OM_STUN_STAR_COUNT; i++)
            {
                float ang = t * OM_STUN_STAR_ROT + (float(i) / float(OM_STUN_STAR_COUNT)) * 6.28318;
                float sPos[3];
                sPos[0] = head[0] + Cosine(ang) * OM_STUN_STAR_RADIUS;
                sPos[1] = head[1] + Sine(ang) * OM_STUN_STAR_RADIUS;
                sPos[2] = head[2] + Sine(t * 3.0 + float(i)) * 2.0;

                TE_SetupGlowSprite(sPos, g_iOMStunGlow, OM_STUN_SPRITE_LIFE, 6.5, 255);
                TE_SendToAll();
            }
        }

        // Chispas electricas periodicas (StunstickImpact GMod)
        g_iOMStunFXCount[client]++;
        if (g_iOMStunFXCount[client] >= OM_STUN_SPARK_EVERY)
        {
            g_iOMStunFXCount[client] = 0;
            float sparkPos[3];
            sparkPos[0] = pos[0];
            sparkPos[1] = pos[1];
            sparkPos[2] = pos[2] + 40.0;
            TE_SetupSparks(sparkPos, NULL_VECTOR, 3, 2);
            TE_SendToAll();
        }
    }

    return Plugin_Continue;
}

// v2.3: STAGGER AL ENTRAR (el fix del "el tank sigue lanzando la
// roca"). El congelado detiene el CUERPO pero NO la ACCION: las
// abilities de los especiales corren por el action system del motor,
// que sigue vivo bajo FL_FROZEN. CTerrorPlayer::OnStaggered (lo que
// dispara L4D_StaggerPlayer) es LA rutina que aborta la acción en
// curso. La red de seguridad del SI_Stagger programa el CancelStagger
// y un re-stagger (el de liberar, el de otro stun) REEMPLAZA ese
// cancel pendiente — nunca un cancel viejo corta un stagger nuevo.
static void OM_Stun_Interrupt(int victim, int attacker)
{
    if (g_cvOMStunInterrupt != null && !g_cvOMStunInterrupt.BoolValue) return;

    // Mismo guard que el stagger al liberar: solo infectados vivos.
    // (Nunca se tambalea a un superviviente ni a un cadaver; la witch
    // no es player y va por Sonic_WitchStun.)
    if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return;
    if (GetClientTeam(victim) != OM_STUN_SI_TEAM) return;

    // Dirección del golpe para el stumble: desde el atacante si es
    // válido (el bot trastabilla ALEJANDOSE de quien lo stuneo).
    float src[3];
    if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
        GetClientAbsOrigin(attacker, src);
    else
        GetClientAbsOrigin(victim, src);

    SIStagger_Auto(victim, attacker, src);
}

// Fin natural del stun: restaurar TODO + iframes (GMod StunIframesAfterStun)
// v2.0: las flags del ciclo recien terminado deciden la salida —
// STAGGER tira el stagger del rayo SIEMPRE ("al terminar el
// congelamiento el infectado será stagger al descongelarse") y
// NOIFRAME se salta la ventana anti-cadena (re-congelable ya).
static void OM_Stun_Finish(int client)
{
    // capturar ANTES de limpiar (el stagger necesita atacante + dir)
    int   flags = g_iOMStunFlags[client];
    int   atk   = g_iOMStunAttacker[client];
    float src[3];
    src = g_vOMStunPushSrc[client];

    OM_Stun_Unfreeze(client);
    OM_Stun_AnimResume(client);   // v1.3: devolver la animación (no-op sin captura) — ANTES del stagger
    OM_Stun_KillStars(client);

    if (g_hOMStunTimer[client] != null)
    {
        KillTimer(g_hOMStunTimer[client]);
        g_hOMStunTimer[client] = null;
    }

    float iframes = 0.5;
    if ((flags & OM_STUN_F_NOIFRAME) != 0)
        iframes = 0.0;            // el rayo: re-congelable al toque siguiente
    else if (g_cvOMStunIframes != null)
        iframes = g_cvOMStunIframes.FloatValue;

    g_fOMStunUntil[client] = 0.0;
    g_fOMStunIframeUntil[client] = GetEngineTime() + iframes;
    g_iOMStunAttacker[client] = 0;
    g_iOMStunFXCount[client] = 0;
    g_iOMStunFlags[client] = 0;          // v2.0
    g_bOMStunPushRest[client] = false;   // v2.0

    if (IsClientInGame(client))
    {
        if (IsPlayerAlive(client))
        {
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            float zero[3] = {0.0, 0.0, 0.0};
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, zero);   // v2.0: el stagger arranca limpio (ex Tails)
        }
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }

    // v2.0: STAGGER AL LIBERAR (ex Tails_SIFrzRelease): con la red de
    // seguridad del SI_Stagger (L4D_CancelStagger levanta a los bots).
    // Solo vivos del equipo infectado — nunca se tambalea a un
    // superviviente ni a un cadaver.
    if ((flags & OM_STUN_F_STAGGER) != 0
        && IsClientInGame(client) && IsPlayerAlive(client)
        && GetClientTeam(client) == OM_STUN_SI_TEAM)
    {
        SIStagger_Auto(client, atk, src);

        float pos[3];
        GetClientAbsOrigin(client, pos);
        pos[2] += 30.0;
        TE_SetupExplosion(pos, g_iOMStunGlow, 10.0, 1, 0, 0, 0);
        TE_SendToAll();

        if (atk > 0 && IsClientInGame(atk))
            PrintHintText(atk, "<font color='#00FFFF' size='20'>>> DESCONGELADO: STAGGER! <<</font>");
    }
}

// Screen shake para victimas humanas (opcional, convar om_stun_shake).
// Guardas dobles: el usermessage "Shake" existe en L4D2 (estándar de
// Source) pero se verifica por ID antes de escribir UN solo byte.
static void OM_Stun_DoShake(int client, float dur)
{
    if (g_cvOMStunShake != null && !g_cvOMStunShake.BoolValue) return;
    if (view_as<int>(GetUserMessageId("Shake")) == -1) return;

    Handle msg = StartMessageOne("Shake", client);
    if (msg == null) return;

    BfWriteByte(msg, 0);       // SHAKE_START
    BfWriteFloat(msg, 2.0);    // amplitud
    BfWriteFloat(msg, 10.0);   // frecuencia
    BfWriteFloat(msg, dur);    // duración
    EndMessage();
}

// ============================================================
//  v2.0: FÍSICA DEL ARRASTRE (ex cuerpo del T_TailsSIFreezeTick del
//  rayo de Tails v5.22-v5.26 — receta Witch_Flight, intacta)
// ============================================================

// v2.0: filtro world-only (patron Witch_Flight / Tails v5.22): el
// trace del arrastre SOLO se detiene en el mundo — players, props e
// infectados NUNCA bloquean al congelado en vuelo.
public bool OM_Stun_WorldOnly(int entity, int contentsMask)
{
    return false;
}

// v2.0: un tick de la física del arrastre. Devuelve true si el
// congelado quedó INCRUSTADO en geometria y hubo que liberarlo YA
// (el caller corta el timer — patron WF v2.4: nunca se teletransporta
// a nadie DENTRO de un muro).
static bool OM_Stun_PushTick(int client)
{
    // Reposo sobre el suelo (aterrizo congelado y el empuje lo solto):
    // cero física — evita el ciclo hundimiento-snap. El próximo
    // OM_Stun_Push lo despierta.
    if (g_bOMStunPushRest[client]) return false;

    // dt real protegido contra lag spikes
    float now = GetEngineTime();
    float dt = now - g_fOMStunPushLast[client];
    if (dt <= 0.0) dt = OM_STUN_PUSH_TICK;
    if (dt > 0.25) dt = 0.25;
    g_fOMStunPushLast[client] = now;

    // Gravedad manual (NONE no integra física) + terminal
    float vel[3];
    vel = g_vOMStunPushVel[client];
    vel[2] -= OM_STUN_PUSH_GRAVITY * dt;
    if (vel[2] < -OM_STUN_PUSH_TERMINAL) vel[2] = -OM_STUN_PUSH_TERMINAL;

    float origin[3];
    GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", origin);

    // Desplazamiento real del tick
    float move[3];
    move = vel;
    ScaleVector(move, dt);

    // Extremo del trace con margen anti-tunel (el margen SOLO alarga
    // el trace, NO mueve al congelado)
    float traceEnd[3];
    traceEnd = move;
    float len = GetVectorLength(move);
    if (len > 1.0)
    {
        float pad[3];
        pad = move;
        NormalizeVector(pad, pad);
        ScaleVector(pad, OM_STUN_PUSH_PAD);
        AddVectors(traceEnd, pad, traceEnd);
    }
    AddVectors(origin, traceEnd, traceEnd);

    // Colisión SOLO contra el mundo (mismo filtro del Witch_Flight)
    Handle trace = TR_TraceRayFilterEx(origin, traceEnd, MASK_SOLID,
                                       RayType_EndPoint,
                                       OM_Stun_WorldOnly, 0);

    if (TR_DidHit(trace) && TR_GetFraction(trace) < OM_STUN_PUSH_INCRUST)
    {
        // INCRUSTADO en geometria (patron WF v2.4): liberar YA con
        // stagger — nunca congelado dentro de un muro.
        delete trace;
        OM_Stun_Finish(client);
        return true;
    }

    if (TR_DidHit(trace))
    {
        float hitPos[3], normal[3];
        TR_GetEndPosition(hitPos, trace);
        TR_GetPlaneNormal(trace, normal);
        delete trace;

        if (normal[2] >= OM_STUN_PUSH_FLOOR_Z)
        {
            // SUELO: asentarlo congelado y a reposo (vel 0)
            float land[3];
            land = hitPos;
            land[2] += OM_STUN_PUSH_LIFT;
            TeleportEntity(client, land, NULL_VECTOR, NULL_VECTOR);
            float zeroV[3] = {0.0, 0.0, 0.0};
            g_vOMStunPushVel[client] = zeroV;
            g_bOMStunPushRest[client] = true;
        }
        else
        {
            // PARED/TECHO -> deslizar: quitar la componente que ENTRA
            // en la superficie + amortiguar (patron WF)
            float dot = GetVectorDotProduct(vel, normal);
            if (dot < 0.0)
            {
                float proj[3];
                proj = normal;
                ScaleVector(proj, dot);
                SubtractVectors(vel, proj, vel);
            }
            ScaleVector(vel, OM_STUN_PUSH_DAMP);
            g_vOMStunPushVel[client] = vel;

            // Recolocar pegado al impacto, sin incrustarse
            float nudge[3], safe[3];
            nudge = normal;
            ScaleVector(nudge, OM_STUN_PUSH_NUDGE);
            AddVectors(hitPos, nudge, safe);
            TeleportEntity(client, safe, NULL_VECTOR, NULL_VECTOR);
        }
    }
    else
    {
        // Vuelo libre: avanzar (origin + move, SIN el pad del trace)
        delete trace;
        g_vOMStunPushVel[client] = vel;
        float newOrigin[3];
        AddVectors(origin, move, newOrigin);
        TeleportEntity(client, newOrigin, NULL_VECTOR, NULL_VECTOR);
    }
    return false;
}

// ============================================================
//  v1.1: ESTRELLAS REALES DEL GMOD (env_sprite + VPK om_)
// ============================================================

// v1.2: EL MARTILLO (Witch_Flight v2.x / Rouge v9.1): dos capas, la misma
// receta que congela a la witch del suite:
//  1) FL_FROZEN: el gate del propio motor (la IA del bot no corre, un
//     player no puede moverse NI atacar).
//  2) MOVETYPE_NONE: la física del motor no integra nada.
static void OM_Stun_Freeze(int victim)
{
    SetEntityMoveType(victim, MOVETYPE_NONE);
    SetEntityFlags(victim, GetEntityFlags(victim) | FL_FROZEN);
}

// v1.2: restauración EXACTA (patron Rouge_WaveRelease): el movetype se
// devuelve SOLO si seguimos siendo nosotros quienes lo pusimos, y el flag
// FL_FROZEN se retira SOLO si el original no lo tenía (el freeze de otro
// sistema del suite nunca se pisa).
static void OM_Stun_Unfreeze(int victim)
{
    if (g_iOMStunOrigMT[victim] > 0 && IsClientInGame(victim))
    {
        if (GetEntityMoveType(victim) == MOVETYPE_NONE)
            SetEntityMoveType(victim, view_as<MoveType>(g_iOMStunOrigMT[victim]));
        if (!g_bOMStunHadFrozen[victim])
        {
            int flags = GetEntityFlags(victim);
            if (flags & FL_FROZEN)
                SetEntityFlags(victim, flags & ~FL_FROZEN);
        }
    }
    g_iOMStunOrigMT[victim] = 0;
    g_bOMStunHadFrozen[victim] = false;
}

// Crea las 3 estrellas sobre la cabeza (el ticker las orbita cada frame).
static void OM_Stun_CreateStars(int victim)
{
    float pos[3];
    GetClientAbsOrigin(victim, pos);
    pos[2] += OM_STUN_STAR_HEIGHT;

    for (int i = 0; i < OM_STUN_STAR_COUNT; i++)
    {
        g_iOMStunStarEnt[victim][i] = INVALID_ENT_REFERENCE;

        int ent = CreateEntityByName("env_sprite");
        if (ent == -1) continue;

        DispatchKeyValue(ent, "model", "materials/om/star_stun.vmt");
        DispatchKeyValue(ent, "rendercolor", "255 255 0");
        DispatchKeyValue(ent, "renderamt", "40");
        DispatchKeyValue(ent, "scale", "0.10");
        DispatchKeyValue(ent, "GlowProxySize", "0.0");
        DispatchSpawn(ent);
        TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);

        g_iOMStunStarEnt[victim][i] = EntIndexToEntRef(ent);
    }
}

// Mata las 3 estrellas (fin natural / clear / mapend / disconnect).
static void OM_Stun_KillStars(int victim)
{
    if (victim < 1 || victim > MaxClients) return;

    for (int i = 0; i < OM_STUN_STAR_COUNT; i++)
    {
        int ent = EntRefToEntIndex(g_iOMStunStarEnt[victim][i]);
        if (ent > MaxClients && IsValidEntity(ent))
            AcceptEntityInput(ent, "Kill");
        g_iOMStunStarEnt[victim][i] = INVALID_ENT_REFERENCE;
    }
}


// ============================================================
//  v2.1: BOOMER FUSE — la mecha del boomer (suite 3.77.38)
//  Pedido del owner: "el boomer al recibir el golpe de metal la
//  embestida, si detecta que algún golpe lo matara, le colocara como
//  una especie de contador; cuando el stun termine (éspecificamente
//  termine en el boomer) este estallara solo. Esto evitando que el
//  boomer le explote encima a metal. Así ocurrirá con Knuckles
//  también que empujara al boomer y cuando este toque el suelo
//  después de volar estallara (también cuenta su ataque aéreo)".
//  DOS modos:
//   - OM_BOOMER_FUSE_STUN   (Metal): el golpe LETAL de la embestida
//     NO se aplica; el boomer sigue congelado y ESTALLA en cuanto su
//     stun termina (ya lejos de Metal — nunca encima de el).
//   - OM_BOOMER_FUSE_GROUND (Knuckles): el boomer sale volando y
//     ESTALLA al tocar el suelo (la ventana del parry VScript y el
//     smash aéreo marcan este modo).
//  Autocontenido: 8 slots por EntRef + timer 10 Hz perezoso (nace al
//  marcar la primera mecha, muere solo cuando no queda ninguna).
// ============================================================
#define OM_BOOMER_FUSE_MAX     8
#define OM_BOOMER_FUSE_GROUND  0
#define OM_BOOMER_FUSE_STUN    1
#define OM_BOOMER_FUSE_TIMEOUT 10.0
#define OM_BOOMER_FUSE_TICK    0.1

int    g_iOMBoomRef[OM_BOOMER_FUSE_MAX];    // EntRef del boomer (0 = libre)
int    g_iOMBoomAtk[OM_BOOMER_FUSE_MAX];    // userid del atacante (credito)
int    g_iOMBoomMode[OM_BOOMER_FUSE_MAX];   // GROUND | STUN
bool   g_bOMBoomAir[OM_BOOMER_FUSE_MAX];    // GROUND: ya despego del suelo
float  g_fOMBoomUntil[OM_BOOMER_FUSE_MAX];  // valvula de seguridad
Handle g_hOMBoomTimer = null;

// marca la mecha de un boomer. mode = OM_BOOMER_FUSE_GROUND/STUN.
// devuelve false si no es un boomer infectado vivo.
bool OM_BoomerFuseMark(int boomer, int attacker, int mode)
{
    if (boomer < 1 || boomer > MaxClients || !IsClientInGame(boomer)) return false;
    if (!IsPlayerAlive(boomer) || GetClientTeam(boomer) != 3) return false;
    if (GetEntProp(boomer, Prop_Send, "m_zombieClass") != 2) return false;  // 2 = boomer

    // ya tiene mecha: refrescarla (no duplicar slots)
    int slot = -1;
    for (int i = 0; i < OM_BOOMER_FUSE_MAX; i++)
        if (EntRefToEntIndex(g_iOMBoomRef[i]) == boomer) { slot = i; break; }
    if (slot == -1)
        for (int i = 0; i < OM_BOOMER_FUSE_MAX; i++)
            if (g_iOMBoomRef[i] == 0 || EntRefToEntIndex(g_iOMBoomRef[i]) <= MaxClients)
                { slot = i; break; }
    if (slot == -1) return false;   // 8 boomers a la vez no pasa

    g_iOMBoomRef[slot]  = EntIndexToEntRef(boomer);
    g_iOMBoomAtk[slot]  = (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
                          ? GetClientUserId(attacker) : 0;
    g_iOMBoomMode[slot] = mode;
    g_bOMBoomAir[slot]  = false;
    g_fOMBoomUntil[slot] = GetEngineTime() + OM_BOOMER_FUSE_TIMEOUT;
    OM_BoomerFuseEnsure();
    return true;
}

// true si el boomer ya tiene una mecha pendiente
bool OM_BoomerFusePending(int boomer)
{
    if (boomer < 1 || boomer > MaxClients) return false;
    for (int i = 0; i < OM_BOOMER_FUSE_MAX; i++)
        if (g_iOMBoomRef[i] != 0 && EntRefToEntIndex(g_iOMBoomRef[i]) == boomer)
            return true;
    return false;
}

void OM_BoomerFuseEnsure()
{
    if (g_hOMBoomTimer == null)
        g_hOMBoomTimer = CreateTimer(OM_BOOMER_FUSE_TICK, T_OM_BoomerFuseTick, _, TIMER_REPEAT);
}

// vacía TODOS los slots y mata el timer (map end / limpieza)
void OM_BoomerFuseClearAll()
{
    for (int i = 0; i < OM_BOOMER_FUSE_MAX; i++)
    {
        g_iOMBoomRef[i]   = 0;
        g_iOMBoomAtk[i]   = 0;
        g_iOMBoomMode[i]  = OM_BOOMER_FUSE_GROUND;
        g_bOMBoomAir[i]   = false;
        g_fOMBoomUntil[i] = 0.0;
    }
    if (g_hOMBoomTimer != null)
    {
        KillTimer(g_hOMBoomTimer);
        g_hOMBoomTimer = null;
    }
}

void OM_BoomerFuseClearSlot(int slot)
{
    g_iOMBoomRef[slot]   = 0;
    g_iOMBoomAtk[slot]   = 0;
    g_iOMBoomMode[slot]  = OM_BOOMER_FUSE_GROUND;
    g_bOMBoomAir[slot]   = false;
    g_fOMBoomUntil[slot] = 0.0;
}

// el estallon: el boomer muere AQUÍ (su muerte = explosión de bilis
// donde este, ya lejos de quien lo lanzo). Credito al atacante.
void OM_BoomerFuseDetonate(int slot)
{
    int boomer = EntRefToEntIndex(g_iOMBoomRef[slot]);
    int atk = GetClientOfUserId(g_iOMBoomAtk[slot]);
    OM_BoomerFuseClearSlot(slot);

    if (boomer < 1 || boomer > MaxClients || !IsClientInGame(boomer) || !IsPlayerAlive(boomer))
        return;
    if (atk <= 0) atk = boomer;   // credito caido: autocidio (mundo)

    SDKHooks_TakeDamage(boomer, atk, atk, 9999.0, DMG_CLUB);
}

public Action T_OM_BoomerFuseTick(Handle timer)
{
    if (g_hOMBoomTimer != timer) return Plugin_Stop;   // defensa

    float now = GetEngineTime();
    bool any = false;

    for (int i = 0; i < OM_BOOMER_FUSE_MAX; i++)
    {
        if (g_iOMBoomRef[i] == 0) continue;
        int boomer = EntRefToEntIndex(g_iOMBoomRef[i]);

        // murió por otra vía / inválido: la mecha muere con el
        if (boomer < 1 || boomer > MaxClients || !IsClientInGame(boomer) || !IsPlayerAlive(boomer))
        {
            OM_BoomerFuseClearSlot(i);
            continue;
        }

        // valvula de seguridad (stun eterno por re-stuns ajenos, etc.)
        if (now > g_fOMBoomUntil[i])
        {
            if (g_iOMBoomMode[i] == OM_BOOMER_FUSE_STUN)
            {
                OM_BoomerFuseDetonate(i);   // la promesa se cumple igual
                continue;
            }
            OM_BoomerFuseClearSlot(i);      // nunca despego: mecha muerta
            continue;
        }

        if (g_iOMBoomMode[i] == OM_BOOMER_FUSE_STUN)
        {
            // Metal: "cuando el stun termine (éspecificamente termine
            // en el boomer) este estallara solo"
            if (!OM_IsStunned(boomer))
            {
                OM_BoomerFuseDetonate(i);
                continue;
            }
        }
        else
        {
            // Knuckles: "cuando este toque el suelo después de volar
            // estallara" — primero despegar, luego aterrizar
            bool onGround = (GetEntityFlags(boomer) & FL_ONGROUND) != 0;
            if (!g_bOMBoomAir[i])
            {
                if (!onGround) g_bOMBoomAir[i] = true;
            }
            else if (onGround)
            {
                OM_BoomerFuseDetonate(i);
                continue;
            }
        }
        any = true;
    }

    if (!any)
    {
        g_hOMBoomTimer = null;
        return Plugin_Stop;   // sin mechas: el timer muere solo
    }
    return Plugin_Continue;
}
