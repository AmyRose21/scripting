/*
 * ======================================================
 *  SonicJumpSurvivors - Manager Universal (v3.77.91 — LIMPIEZA TOTAL
 *  DE WARNINGS (18 -> 0) + LA BARRA DE ROUGE CABLEADA): [1] 8x warning
 *  213 (llamadas manuales a *_Event_PlayerSpawn con int donde iba bool
 *  dontBroadcast -> view_as<bool>, mismo valor); [2] 7 convars tombstone
 *  DEPRECATED siguen registrados (no ensucian el Sonic_Suite.cfg) pero sin
 *  handle muerto (warning 204); [3] g_hEggmanMinesTimer retirado (handle
 *  zombi de las minas pre-Zapper v5.2); [4] Rouge_PlayerIs/Rouge_BarState
 *  eran la barra de energia latch de Rouge HUERFANA del despachador
 *  SBar_Resolve desde v10.6/3.77.85 — cableada con el mismo patron
 *  Blaze/Silver/Sonic (PARED!/FRENO!/PLANEO!/AGOTADA!, energia 0-250).
 *  CERO FX tocados. Cero logica de gameplay alterada.
 *  (v3.77.90 — EL SOL DE LA
 *  EXPANSIVA (Blaze v2.13): pedido del owner 2026-10-17 — la carga de
 *  sol del ataque principal solo llegaba al comun del GOLPE DIRECTO
 *  ("solo le da la energia al common que recibe la patada pero no a
 *  los commons que mate la expansiva"). AHORA los comunes que el AOE
 *  del impacto (patada / dash aereo / enganche de la lanza) MATA
 *  tambien cargan su blaze_sol_charge_common (+2 cada uno): cero
 *  doble carga (el comun del directo entra al AOE como skipEnt) y la
 *  witch/tank no cargan por la expansion. Cero FX tocados.
 *  (v3.77.88 — FIX DEL "SEND
 *  RELIABLE STREAM OVERFLOW": el owner aislo al culpable en campo
 *  ("Encontre al culpable. es Sonicmanager"). Causa raiz: el
 *  PauseFix de Tails (v5.20.6) pedia el pulso de re-encaje del avatar
 *  con ClientCommand("pause"/"unpause") — stringcmd FIBLE
 *  server->cliente que el cliente ejecuta y devuelve como stringcmd
 *  fiable cliente->server, con el mundo pausado de verdad (sv_pausable
 *  FORZADO a 1 en arranque/mapa/ronda + re-refuerzo antes de cada
 *  pulso) y el canal sin drenar: el ping-pong palanca satura el stream
 *  fiable en ambas direcciones -> 39+ overflows en el listen server.
 *  FIX = Tails.inc v5.20.7 "ZERO-NET": (1) todo el ciclo del pulso
 *  pasa a FakeClientCommand server-side (CERO paquetes por la red,
 *  cero ClientCommand); (2) sv_pausable YA NO SE FUERZA — con 0 el
 *  pulso se omite y el re-encaje queda en EF_NOINTERP + MarkInterp
 *  (piezas 1-2 de la v5.20.5, ya existentes: el avatar sigue naciendo
 *  encajado). SIN TOCAR NINGUN EFECTO VISUAL: avatares, trails, FX y
 *  HUD intactos. Salto de version deliberado (3.77.86/87 ya usadas).
 *  (v3.77.54 - EL CST-GUARD VIVE AQUI: embebido como include + señal en el MISMO frame (v3.77.53 - LA SENAL "QUIEN ES QUIEN" PARA EL CST + antifall por avatar + balance de Metal + ragdoll con impulso real (v3.77.51 - ANTIFALL POR AVATAR + COMPLETA EL BALANCE DE METAL sobre SU arbol f4bf209: Anti caida v3 (avatar vivo = 0 dano de caida; sin avatar = -40%; re-check cada 0.1s con re-ajuste) | Metal v5.7.1 (el +25% de la embestida quedo incompleto en la fusion: golpe de pared 4.0625/1.5625) | sonic v6.32 / Rouge v10.3 / Knuckles v76 INTACTOS tal cual SU arbol | TODO lo demas = 3.77.50 intacto)
 *
 *  v3.77.54 - 2026-10-13 — EL CST-GUARD VIVE AQUI (include embebido)
 *          (pedido del owner: "Lo convertiras en un INC... en un include
 *          y vas a incluirlo en el manager. Con eso el guard estara
 *          tambien colocado y tambien el CST no crees?"). Causa raiz del
 *          reporte ("El Guard hace la vista gorda cuando ve lo que el
 *          plugin hace"): el guard era un plugin SEPARADO (cst_skinchange
 *          .smx) que solo se enteraba de quien es quien por sus capas
 *          L1-L4 (registro CST / nombre / modelo / slot) — este manager
 *          asigna personajes SIN tocar el modelo del jugador (avatar
 *          prop aparte), asi que para el guard suelto TODOS los cambios
 *          de personaje del manager eran invisibles hasta que el
 *          watchdog (30s) o un spawn lo pesaran de rebote. CUATRO
 *          piezas:
 *          (1) #include <cstguard> — TODO el CST-Guard + motor CST
 *              (cstguard.inc v3.0.0) compilado DENTRO de este plugin:
 *              sin natives, sin forwards globales, una sola vida. Cvars
 *              cstguard_* (su propio cfg cst_skinchange.cfg), comandos
 *              sm_cst* + sm_amy/sm_sonic/sm_rouge (del mapa de
 *              personajes), watchdog propio y eventos propios — todo se
 *              arranca solo con CSTGuard_Init() al final de
 *              OnPluginStart.
 *          (2) FireCharSignal alimenta al guard EN EL MISMO FRAME: cada
 *              commit de personaje (menu / cookie al reconectar /
 *              freechars / Rebuild) le dice a CSTGuard_Signal /
 *              CSTGuard_Clear QUIEN ES QUIEN en el instante exacto. El
 *              guard registra la identidad (L0, autoridad) y si el
 *              modelo no corresponde ejecuta el comando del personaje
 *              (sm_amy / sm_sonic / sm_rouge) en el contexto del jugador
 *              señalado. FIN DE LA VISTA GORDA: nada de lo que hace este
 *              manager vuelve a ser invisible para el guard.
 *          (3) CSTGuard_OnResyncRequested(): cuando el guard pide
 *              re-anuncio (arranque tardio, inicio de ronda +6s,
 *              sm_cstsync) este manager re-dispara FireCharSignal para
 *              TODOS los personajes activos.
 *          (4) El forward global Sonic_OnCharacterChanged sigue
 *              disparandose igual (otros oyentes, si algun dia los hay)
 *              y el native Sonic_GetPlayerCharIndex queda intacto.
 *          REGLA DE ORO: cst_skinchange.smx se BORRA del server — el
 *          guard ya vive aqui. Los dos juntos duplicarian los comandos
 *              (sm_amy se dispararia dos veces).
 *
 *  v3.77.53 - 2026-10-12 — LA SENAL "QUIEN ES QUIEN" PARA EL CST
 *          (pedido del owner: "colocar que el sonic manager mande una
 *          senal indicando Quien es quien y el Smx CST lo identificara
 *          y usara el cfg correspondiente"). Causa raiz del reporte
 *          ("estoy como yo (amy) y el CST no manda la senal de amy.cfg
 *          Nisiquiera cambiando"): el guardia v2.0 del cst_skinchange
 *          SOLO aplicaba un cfg si el MODELO del jugador era un stock
 *          mapeado por SLOT (coach=amy.cfg etc) — este manager asigna
 *          personajes SIN tocar el modelo, asi que el CST nunca se
 *          enteraba de quien era quien (estando en nick/zoey/bill/...
 *          no habia nada que mapear y amy.cfg jamas cargaba). TRES
 *          piezas, todas de solo-lectura:
 *          (1) FORWARD GLOBAL Sonic_OnCharacterChanged(client, charIdx):
 *              se dispara en CADA commit de personaje — menu (elegir /
 *              cambiar / "Sin personaje"), cookie al reconectar
 *              (LoadPlayerCharChoice, tambien via Rebuild), liberacion
 *              admin (freechars) y el caso "el personaje lo tiene otro"
 *              del Rebuild. ES LA SENAL LITERAL DEL PEDIDO.
 *          (2) RegPluginLibrary("sonic_ability_manager"): LibraryExists
 *              ya responde. El native Sonic_GetPlayerCharIndex (existente)
 *              queda como consulta — el cst_skinchange v2.1 lo pregunta en
 *              cada pasada del watchdog como red de seguridad (late load,
 *              reloads, senales perdidas: se autocura).
 *          (3) CERO cambios de logica de personajes/habilidades: la senal
 *              solo publica el indice que ya vivia en g_iPlayerCharIdx.
 *          Requiere cst_skinchange v2.1 (el lado que ESCUCHA). Con el
 *          v2.0 la senal no tiene oyente y todo sigue como antes.
 *
 *  v3.77.51 - 2026-10-12 — PEDIDO NUEVO DEL OWNER ("podrias ponerle
 *          el poder antifall al avatar por defecto? para los que
 *          tienen el avatar, y para los que no tienen el avatar, 40%
 *          de reduccion de dano de caida (checa cada 0.1s si tienen
 *          avatar; si no tienen o se lo quitaron, re-ajusta)").
 *          (1) ANTI CAIDA v2.1 -> v3.0: CON avatar vivo (prop con los
 *              targetnames del suite parentado al jugador) = dano de
 *              caida 0; SIN avatar = -40% (sm_falldmg_reduce 0.40).
 *              Chequeo cada 0.1s (sm_avatar_fall_check) con re-ajuste
 *              al vuelo y LogMessage al cambiar. Fix del fallback
 *              DMG_FALL de la v2 (1<<8 NO es caida; 1<<5 si).
 *              El plugin es 100% autocontenido: cero cambios en este
 *              manager para detectar el avatar (escanea entidades).
 *          (2) METAL v5.7 -> v5.7.1: la fusion del v5.7 en su arbol
 *              dejo fuera el GOLPE DE PARED de la embestida:
 *              METAL_WALL_SLAM_DMG 3.25 -> 4.0625 y LMS 1.25 -> 1.5625
 *              (mismo +25% del pedido; 3 hits = 12.1875 vs 9.75).
 *          (3) FIX DEL AGARRE del carry: YA ESTA completo en SU arbol
 *              (sonic v6.32: salto heredado + hueco bloqueado) — NO se
 *              toca. sonic.inc/Rouge.inc/Knuckles.inc = SUS archivos
 *              byte a byte.
 *          (4) VERSION de este manager: 3.77.50 -> 3.77.51 SOLO para
 *              que sm_sjsver confirme la instalacion (leccion de la
 *              3.77.46). Cero cambios de logica del manager.
 *
 *  v3.77.50 - 2026-10-11 — PATCH DE BALANCE, ESTA VEZ SOBRE EL ARBOL
 *          ACTUALIZADO DEL OWNER. Contexto: el primer intento (entregado
 *          como "3.77.26" sobre una base vieja) fue RECHAZADO ("No
 *          aceptare eso. Lo hiciste mal... aqui esta la base de datos
 *          actual") — esta build se hace sobre SU arbol (el scripting4
 *          TODO-APLICADO 3.77.49: Rouge v10.2 / Knuckles v75 / Metal
 *          v5.6 / sonic v6.31 / Shadow v6.0 / includes 1.12 limpias).
 *          Pedido literal: "buff a la habilidad 1 de rouge la patada
 *          baja ahora causara 50% mas de dano El counter causara 45%
 *          mas de dano y durara 7 seg) QoL La pantada baja ahora su Aoe
 *          aumentara un 25%. Knuckles recibira un buff reduccion de sus
 *          enfriamientos 4 seg menos. Metal aumento de dano a su
 *          embestida 25% reduccion de enfriamiento de 25% Sonic Su
 *          spindash ahora causara 35% mas de dano (en todas sus fases)
 *          El Peelout Reducira su enfriamiento 8 seg tanto su falla como
 *          su succes en rescatar Y Fix al agarre cuando agarra a un
 *          survivor hay una posibilidad que el survivor se suelte sin
 *          este hacer nada".
 *    (1) ROUGE v10.2 -> v10.3-OM: con el kit v10.2 el mapeo es LITERAL
 *        — la "habilidad 1 / patada baja" = su Z BARRIDO (Sweep Kick) y
 *        "el counter" = su X CONTRAGOLPE (los del pedido; en la base
 *        vieja el counter de Rouge no existia y se habia mapeado al de
 *        Knuckles — ya no): rouge_kick_damage 150 -> 225 (+50%),
 *        rouge_kick_radius 95 -> 118.75 (+25% AoE),
 *        rouge_parry_common_dmg 100 -> 145, rouge_parry_si_dmg
 *        200 -> 290 (+45%) y rouge_parry_duration 6 -> 7s.
 *    (2) KNUCKLES v75 -> v76-OM: enfriamientos -4s (Puno 15 -> 11,
 *        Postura 20 -> 16, H3 Meteoro 20 -> 16). Su counter (dano y
 *        duracion 8s) INTACTO — el buff de counter era para Rouge.
 *    (3) METAL v5.6 -> v5.7-OM: embestida +25% dano SOLO al enemigo
 *        (atrape 6.2 -> 7.75, tick 6.2 -> 7.75, estampado 15.1 ->
 *        18.875; auto-dano intacto) y -25% cd (17.5 -> 13.125 y
 *        cancelado 8.75 -> 6.5625). NOTA: v5.5 ya tenia +55% dano y
 *        v5.2 -30% cd — se aplica ENCIMA (documentado en el CAMBIOS).
 *    (4) SONIC v6.31 -> v6.32-OM: TODO el dano de la bola sale de los
 *        mismos 2 convars -> +35% cubre TODAS las fases de una vez
 *        (spin_damage 90 -> 121.5, spin_damage_tank 105 -> 141.75);
 *        peel -8s en AMBOS caminos (cd_rescue 25 -> 17 exito,
 *        cd_fail 45 -> 37 fallo/cancel); FIX DEL AGARRE del carry:
 *        (a) SALTO HEREDADO — el ESPACIO presionado al montarse ya no
 *        eyecta al pasajero (detector de flanco: solo un espacio NUEVO
 *        tras soltar, o 1.0s sostenido, baja a proposito) y
 *        (b) HUECO BLOQUEADO — con ambos asientos tapados el pasajero
 *        se ENROLLA al punto de Sonic (+12z) en vez de quedarse atras
 *        hasta que el check de distancia lo soltara "solo".
 *    (5) Cero funciones nuevas, cero cvars nuevos: SOLO defaults de
 *        convars, 5 constantes de Metal y la logica del fix del agarre
 *        dentro de funciones existentes (Scan/PreThink/Eject/ClearState).
 *        Compilado con spcomp 1.12.0.7253 (EL del owner) = 0 errores /
 *        0 warnings, misma linea base que la 3.77.49.
 *        OJO CFG: los defaults nuevos NO pisan lineas ya grabadas del
 *        Sonic_Suite.cfg — actualizarlas a mano o borrarlas (lista
 *        completa en CAMBIOS_37750_BALANCE.txt).
 *
 *  v3.77.49 - 2026-10-11 (orden del owner: "con que añadieras a
 *  shadow Om su avatar y demas cosas de Gmod" + "remuevas todos los
 *  warnings los 28 que siempre salen cuando compilas"):
 *    (1) SHADOW OM v6.0 — SU AVATAR (7o del suite, patron Rouge v10.2
 *        /Amy v95): shadow.mdl del VPK (FileExists: si no esta, CERO
 *        dependencia — survivor normal) + espejo R/L + cuerpo oculto
 *        + FSM 10 Hz con RESOLUCION DE SECUENCIAS POR PROBE (receta
 *        Amy v92: shadow.mdl no trae tabla documentada — cada estado
 *        prueba su cadena de nombres del lua GMod: idle/walk/run/
 *        jump/fall + lowhealth<=50 + downed + HOVER propio (SPACE en
 *        el aire) + one-shots SNAP/BLAST; si falta, su base lo cubre)
 *        + tinte ROJO con los Anillos Inhibidores + ragdoll de muerte
 *        15s + anti-corpse 2s + adopcion de huerfanos + nombres
 *        nuevos en OM_SweepOrphanAvatars + OM_IsTrackedAvatarRef +
 *        convar shadow_avatar 1 + Shadow_OnMapEnd/OnPlayerDeath
 *        cableados.
 *    (2) FIX RAGDOLL DE ROGUE (bug hallado en la revision): el
 *        Event_PlayerDeath PRE del manager llamaba Rouge_OnPlayerDeath
 *        -> Rouge_KillAvatar ANTES del hook POST propio de Rouge — el
 *        ragdoll rouge.mdl de la v10 JAMAS salio. MISMO FIX del Sonic
 *        v3.76.2: fuera del PRE; todo en el POST (ragdoll + ventana
 *        anti-corpse + reset). Rouge_OnPlayerDeath queda para el
 *        OnPluginEnd.
 *    (3) SUITE A 0 WARNINGS: los 22 del compilado (spcomp 1.12.0.7253,
 *        el MISMO del owner) eliminados con 'stock' en los simbolos no
 *        usados de Sally/Doll_System/Metal/OM_Stun/Speed_sonic (cero
 *        cambio de comportamiento: lo que se usa compila igual, y los
 *        CreateConVar legacy de Sally siguen creados para el cfg).
 *
 *  v3.77.48 - 2026-10-11 (orden del owner: "Ok es hora de incluir a
 *  shadow y otra cosa el vuelo no tiene limite de saltos de vuelo.
 *  Solo dependera es de la energia"):
 *    (1) SHADOW AL CLUB DEL AIR CONTROL — cuando el club nacio (la
 *        3.77.46) el owner dijo "por ahora solamente lo tendra rouge
 *        knuckles y amy y sonic y metal"; llego el turno de Shadow:
 *        OM_JumpImpulse (impulso hacia adelante al saltar) +
 *        OM_AirSteer (steering WASD aereo, accel 12 / tope 300).
 *        GUARD: mientras MANTIENE SPACE en el aire su pasiva Hover
 *        Shoes (Shadow_PreThink: caida suave + accel 20 + chispas de
 *        cohete) maneja el movimiento — el steering OM solo corre
 *        cuando NO esta usando el hover. Ayuda de seleccion nueva.
 *    (2) ROGUE v10.2 — VUELO SIN LIMITE: aleteo SIN tope de cantidad,
 *        SOLO ENERGIA (250/8 = ~31 por tanque): rouge_flap_max 0 =
 *        ilimitado (>0 = tope). Potencia PLENA en cada aleteo (fuera
 *        el decaimiento 7.5% del lua) y cd PLANO al aterrizar (era
 *        6s × aleteos = hasta 120s ocultos). OJO convar: si un
 *        Sonic_Suite.cfg viejo trae rouge_flap_max 3, ponerlo a 0.
 *
 *  v3.77.47 - 2026-10-11 (REINSTALACION COMPLETA — el paquete de la
 *  3.77.46 se entrego INCOMPLETO en la practica: el include/Rouge.inc
 *  v10.1-OM y los .nut del parry (chch_parrying v2.10 +
 *  knuckles_parry_state v2.1) no llegaron a la instalacion, y el
 *  manager 3.77.46 NO COMPILA contra el Rouge.inc v10-OM viejo (le
 *  faltan Rouge_ApplyMaxHealth / Rouge_RestoreMaxHealth /
 *  Rouge_CheckTankCounter) ni puede abrir ventanas en un nut v2.4.
 *  Esta version = CERO cambios de logica vs 3.77.46; TODO el kit en
 *  un solo paquete con manifiesto sha256 y LEEME de instalacion
 *  paso a paso (compilar tu mismo O instalar el smx directo).
 *
 *  v3.77.46 - 2026-10-10 (reporte del owner tras probar la 3.77.45 —
 *  6 puntos, Rouge.inc v10.1-OM):
 *    (1) ENERGIA DE VUELO 100 -> 250, consumo -50% (aleteo 8, agarre
 *        11.5/s, salto de pared 7.5).
 *    (2) REWORK DE LA PASIVA: planeo con SPACE MANTENIDO ("deja
 *        presionado el espacio ella puede planear"), aleteo al tap,
 *        SHIFT en el aire = FRENO LITERAL (gravedad 0 + decaimiento
 *        hasta quedar QUIETA — el hover), anims FlyIdle (quieta) y
 *        FlyRun (moviendose), agarre de pared IDENTICO al de Knuckles
 *        (salida por la NORMAL + 450 vertical + planeo auto + cd 0.5s).
 *    (3) FIX SLOT 4: "la granada esta que te dije no la pusiste en la
 *        4 habilidad la 4 esta sin usar" — CIERTO: la fila de binds
 *        hacia "unbind b" para todo el que no era Amy. FIX: B bindeada
 *        para Rouge. Y la 4 pasa a ser la ONDA NEGRA reintegrada
 *        ("la 4 habilidad lo ocupara el black wave que retiramos"); el
 *        Cebo+Flash queda en consola (sm_rouge_kick). Counter: sonido
 *        de ACTIVACION = om/knuckles/counter.wav (no el del flash).
 *    (4) OM AIR CONTROL ("el modo de knuckles... cada que salta le da
 *        un impulso hacia adelante y... puede cambiar de direccion en
 *        el aire... por ahora solamente lo tendra rouge knuckles y amy
 *        y sonic y metal"): impulso al saltar para los 5 + steering
 *        WASD aereo para Rouge/Amy/Sonic/Metal (Knuckles trae el
 *        propio desde el v67).
 *    (5) COUNTER = AL DE KNUCKLES (6s, devuelve tank/agarres/vomito,
 *        patada baja + punchstun al bloquear) + BARRIDO EN AREA
 *        (todos en la esfera, cd 6s, stun OM_Stun 2.5s APILABLE) +
 *        EVA como la de Sonic (agarres + vomito).
 *    (6) VIDA MAX 125 + reduccion por escalones 20/35/50% + Bat Bomb
 *        (la granada) cd 20 -> 13 (-35%).
 * ======================================================
 *  SonicJumpSurvivors - Manager Universal (v3.77.45 - ROUGE OM v10: EL KIT COMPLETO DEL GMOD — Barrido Z + Contragolpe X (con SU entrada ChCh_RougeNotify en el chch_parrying.nut v2.9, patron supertank) + Bat Bomb C + Cebo+Flash B (la granada quimica FUSIONADA con la Flash Bang del lua) + pasivas (energia/latch/flaps/reduccion) + avatar rouge.mdl espejo R/L con sync y FSM)
 *
 *  v3.77.45 - 2026-10-10 (orden del owner: "Aun tienes los Lua de Gmod?
 *  Si aun los tienes incluyelas con sus pasivas de rouge y habilidades
 *  (y si las otras 2 habilidades que ya tiene muevelas a la 3 y 4) [...]
 *  la habilidad de flash sera modificada se fucionada con la granada
 *  quimica en la habilidad 4 ella tendra tambien un Parry (tipo counter
 *  de knuckles pero un tanto mas debil pero aun asi podra activar la
 *  devolucion de proyectiles"). Los Lua SI estaban (pack 118 de la
 *  Task 25) — Rouge.inc v10-OM porta las mecanicas EXACTAS del
 *  redimated_om_pills_survivors_rouge.lua:
 *    - Z BARRIDO (Sweep Kick: carga 0.35 -> 550 con i-frames, primer
 *      golpe por touch: comun ragdoll volado / SI stagger / witch
 *      estatua; cd 28 hit / 15 miss; desde pared = lanzazo 1500)
 *    - X CONTRAGOLPE (counter estilo Knuckles PERO DEBIL: 4s vs 8s,
 *      devoluciones a media fuerza) -> llama DIRECTO a SU entrada
 *      ChCh_RougeNotify del .nut v2.9 (RunScriptCode, patron
 *      SetAmyMode) -> DEVOLUCION DE PROYECTILES COMPLETA
 *    - C BAT BOMB SPRAY (movida intacta desde la X)
 *    - B CEBO+FLASH (el Cebo Quimico movido desde la Z y FUSIONADO
 *      con la Flash Bang del lua: destello 400u con LOS -> comunes/
 *      witch estatua CYAN, SI stagger + lentitud x0.7 6s, tank lento)
 *    - PASIVAS: energia 30/100 (regen 1.2/s, alimenta todo), agarre
 *      de pared (2 por vuelo, drena, SPACE = lanzazo 700), aleteos
 *      (3 por vuelo, 16 c/u), reduccion pasiva al 90% + las de siempre
 *      (planeo SHIFT / caida / evasion instintiva). La Onda Negra
 *      queda FUERA de slots (reemplazada): sm_rouge_wave en consola.
 *    - AVATAR rouge.mdl (6o avatar del suite: R/L + sync + pausa +
 *      adopcion + FSM con las secuencias del lua + ragdoll de muerte)
 *  Sonidos del lua con guard + fallback: om/rouge/flap.wav,
 *  om/rouge/flashbomb.wav, om/blaze/blazekick.wav, om/knuckles/
 *  punchstart.wav, om/knuckles/swing.wav, om/knuckles/Latch.wav.
 * ======================================================
 *  SonicJumpSurvivors - Manager Universal (v3.77.44 - DIRECTO DEL SMX AL VSCRIPT: la postura de Knuckles llama a SU entrada ChCh_KnxNotify y la pose de Amy a SU entrada ChCh_AmyNotify, como el SetAmyMode del supertank — sin consola, sin registro de personajes, sin gates)
 *  v3.77.44 - 2026-10-10 (orden del owner tras la 3.77.43: "el ultimo
 *            cambio que hiciste solo hiciste que el Vscript jamas se
 *            enterara del tema este... No tienes que poner un
 *            identificador de personaje... sencillamente el parry este
 *            Vscript puede identificar si es knuckles o amy quien
 *            llama... se te hace tan dificil hacer algo como hiciste
 *            con el super tank?... una ventana abierta por 8 seg donde
 *            devuelve todo daño con dicho counter"):
 *            DIRECTO DEL SMX AL VSCRIPT — PATRON SUPERTANK
 *            (SetAmyMode). La cadena de la .43 (postura -> consola
 *            knxparry_state -> Parry.smx -> gate knxparry_chars ->
 *            gate uk_parry_chars del .nut) tenia 5 eslabones y el
 *            .nut rechazaba en silencio si CUALQUIERA faltaba (hasta
 *            la llamada directa de Amy moria en el gate uk_parry_chars
 *            porque ese convar solo lo mantenia el Parry.smx v2.4+).
 *            Ahora:
 *            (1) Knuckles.inc v75-OM: LA POSTURA LLAMA DIRECTO a la
 *                entrada ChCh_KnxNotify del chch_parrying.nut v2.8 por
 *                RunScriptCode (Knux_ParryNotifyNut, patron
 *                Amy_PublishScriptIdx/SetAmyMode) — fuera el
 *                ServerCommand knxparry_state en sus 3 sitios.
 *            (2) Amy.inc v104-OM: la pose de defensa de la Z llama a
 *                SU PROPIA entrada ChCh_AmyNotify (nueva en el .nut
 *                v2.8) — deja de compartir la entrada de Knuckles.
 *            (3) chch_parrying.nut v2.8: LA ENTRADA ES LA IDENTIDAD —
 *                la ventana guarda su bandera amy y KnxIsAmy la lee
 *                (antes: convars espejo uk_amy_chars/uk_parry_chars
 *                que solo mantenia el Parry.smx). BORRADOS los gates
 *                KnxCanShoveParry y toda lectura de esos convars.
 *            (4) ESTE MANAGER: BORRADO el REGISTRO DE PERSONAJES
 *                (OM_PublishParryChar + sus 10 llamadas — el
 *                identificador que el owner mando quitar). La
 *                exclusividad es estructural: las entradas SOLO las
 *                llaman los codigos de Knuckles y Amy.
 *            (5) Parry.smx v2.6: de watchdog + diagnostico (sus
 *                puentes de ventana murieron con el registro).
 *  v3.77.43 - 2026-10-10 (orden del owner tras la 3.77.42: "dime que
 *            le pusiste que cada que el knuckles activa su parry o amy
 *            su habilidad de martillo defensivo hace que la ventana
 *            entre en accion lo hace verdad?... y no con shove ni con
 *            IN_ATTACK2 cierto?"): EL SHOVE / IN_ATTACK2 YA NO PARREA
 *            — NI PARRY INSTANTANEO NI VENTANA. Parry.smx v2.5 borra
 *            ENTERO su OnPlayerRunCmd (el trigger del shove) y toda la
 *            cadena del parry instantaneo (PerformParry, CheckEnemies,
 *            ParryWitch, IsLookingAt... + 7 convars huerfanos);
 *            chch_parrying.nut v2.7 borra la deteccion de shove del
 *            loop (ShovingPlayerData/m_flNextShoveTime) y
 *            OleMateShoved. El shove de TODOS (Amy y Knuckles
 *            incluidos) es 100% vanilla. LA VENTANA LA ABRE SOLO LA
 *            HABILIDAD — la POSTURA de Knuckles (knxparry_state, ya lo
 *            hacia desde la .41) o la POSE DE DEFENSA de la Z de Amy
 *            (ChCh_KnxNotify directo, dura lo que dure la pose) — y
 *            sigue siendo exclusiva de ellos (knxparry_chars gatea la
 *            apertura en AMBOS lados). El manager CERO cambios de
 *            logica: solo version, changelog, sjsver y comentarios.
 *  v3.77.39 - 2026-10-10 (fix del reporte del owner tras la 3.77.38:
 *            "ya el vscript no bloquea auto la roca del tank", "el
 *            counter no hace el sonido de om/knuckles/punchstun.wav
 *            ni nada" y "aun aparece el Knuckles al iniciar la partida
 *            o reiniciar"):
 *            (1) BARRIDO ANTI-AVATAR REF-AWARE Y REPETIDO: la 3.77.38
 *            barria UNA vez en OnMapStart — demasiado temprano para
 *            los restores tardios de transicion/guardado de campaña
 *            (los huerfanos llegaban DESPUES del barrido = seguian
 *            apareciendo "al iniciar la partida o reiniciar"). Ahora
 *            el barrido corre en OnMapStart + retardado 0.5/2/5 s +
 *            round_start + cada 3 s EN CALIENTE, y es REF-AWARE: un
 *            prop con nombre de avatar solo muere si NO es un avatar
 *            vivo rastreado por alguna FSM (Knuckles/Sonic/bola/Amy/
 *            Metal/Tails, R y L) — los legitimos NUNCA se tocan y un
 *            huerfano vive maximo 3 s sin importar CUANDO ni DESDE
 *            DONDE aparezca (transicion, reinicio, save de campaña).
 *            (2) El fix de la roca/sonido vive en el Parry.smx v2.3 y
 *            el chch_parrying.nut v2.4 (loop con bootstrap al cargar
 *            + watchdog + escaneo nativo siempre + punchstun del
 *            counter) — el manager solo acompana la version.
 *  v3.77.40 - 2026-10-10 (orden del owner tras la 3.77.39: "tu barrido
 *            de avatares esta haciendo reiniciar mi avatar a cada
 *            rato... BUSCA OTRA MANERA"): FIN DEL BARRIDO EN CALIENTE.
 *            El repetidor de 3 s — y sus retardados 0.5/2/5 s, y el del
 *            round_start, y el del OnMapEnd — SE BORRA ENTERO: un avatar
 *            vivo rastreado vuelve a ser INTOCABLE para el suite. La
 *            doctrina nueva contra los huerfanos:
 *            (1) REEMPLAZO LIMPIO en el CreateAvatar de los 5 modulos:
 *                si un montaje doble encuentra un R/L viejo vivo, muere
 *                ENTERO antes de montar el nuevo (la fabrica de
 *                huerfanos del "ref = 0" sin Kill queda cerrada);
 *            (2) ADOPCION EN EL MONTAJE (X_KillGhostAvatarProps en
 *                Knuckles/sonic/Tails/Amy/Metal): cada FSM es la UNICA
 *                creadora de los props con su nombre de avatar — todo
 *                prop asi que ELLA no rastrea es huerfano por
 *                definicion y muere en el instante del montaje, no en
 *                un timer a ciegas que arriesga avatares vivos;
 *            (3) el UNICO barrido restante corre en OnMapStart (antes
 *                de que exista un solo avatar en el mapa) y ahora
 *                recolecta-antes-de-matar: jamas FindEntityByClassname
 *                sobre un handle recien muerto. Fix ademas del guard
 *                del OM_IsTrackedAvatarRef: un ref legitimo puede ser
 *                NEGATIVO (bit alto del serial) — el "ref <= 0" de la
 *                .39 era una trampa silenciosa.
 *  v3.77.42 - 2026-10-10 (fix del reporte del owner tras la 3.77.41:
 *            "Lo que no hisiste fue colocar los golpes normales y
 *            habilidades de los enemigos En el MANAGER!!! ... Osea si
 *            detecta un ataque debe counterearlo. Ya lo haces con los
 *            coomons xq no con los SI con el resto? ya lo haces con el
 *            tank en si" + "el Vscript aun se activa es con un Shove...
 *            Y NO DEBERIA SER GENERAL! ... Puso esa mrd para que
 *            cualquiera que haga una shove pueda repeler y no La cosa
 *            no es asi los unicos es amy y knuckles por el momento"):
 *            (1) Knuckles.inc v74-OM — EL COUNTER MANDA EN EL MANAGER:
 *                el basico de un especial ya no queda en "bloqueo
 *                bonito": Knuckles_CheckSpecialCounter COMPLETO (hard
 *                stop + stagger + empuje 800 + 200 de dano + 5s sin
 *                habilidad, la receta de los agarres) y la garra de la
 *                witch la deja ESTATUA congelada 2s + empujon (receta
 *                del wall-slam: Sonic_WitchStun; control de boss sin
 *                dano, como el counter del tank). Las habilidades
 *                (pounce/lengua/carga/slam/vomito) ya tenian SU
 *                counter por forwards — los basicos eran el hueco.
 *            (2) SHOVE-PARRY EXCLUSIVO — el jugador NO lleva el modelo
 *                OM (el avatar es un prop): el chequeo por modelo del
 *                .nut nunca matcheo (bug latente: la DEFENSA DE
 *                MARTILLO de Amy jamas disparaba). EL MANAGER ES LA
 *                FUENTE DE VERDAD: publica el personaje por el puente
 *                nuevo knxparry_chars <idx> <0|1|2> (al seleccionar,
 *                al restaurar cookie, en CADA spawn y en las
 *                limpiezas) -> Parry.smx v2.4 (flags + convars
 *                uk_parry_chars/uk_amy_chars) -> chch_parrying.nut
 *                v2.6 los lee. El shove de los demas es UN SHOVE
 *                NORMAL. Amy por fin es Amy de verdad (su contador
 *                aparte y su defensa de martillo disparan).
 *  v3.77.41 - 2026-10-10 (fix del parry de Knuckles, reporte del
 *            owner: "tenia que hacer un shove previo y luego activar
 *            el bloqueo... es un desproposito"; "el bloqueo del
 *            vscript no le avisa al SMX que fue bloqueado el ataque
 *            con knuckles por lo que nunca hace la animacion de
 *            bloqueo"; "el sonido de bloqueo no suena para cuando
 *            bloquea habilidades (en smx) de agarres y golpes de
 *            tank"; "el bloqueo debe bloquear ataques basicos tambien
 *            de otros infectados especiales"):
 *            (1) Knuckles.inc v73-OM: LA POSTURA ABRE LA VENTANA DEL
 *                PARRY SOLA — knxparry_state al activar/cerrar/reset;
 *                el Parry.smx v2.3 (SIN CAMBIOS) abre su ventana, avisa
 *                al chch_parrying.nut v2.5 y su escaneo nativo corre.
 *                Cero shove previo: la postura ES el bloqueo.
 *            (2) chch_parrying.nut v2.5: cada bloqueo de la ventana
 *                (proyectiles + enemigos) avisa al manager por
 *                knx_parry_blocked -> GESTO DE BLOQUEO del avatar
 *                (KNUX_ST_COUNTER_HIT) + pulso blanco (patron
 *                amyparry_strike, throttle 0.4 s).
 *            (3) Knux_CounterBlockFx: EL SONIDO DEL BLOQUEO es
 *                om/knuckles/punchstun.wav en TODO (agarres, tank,
 *                VScript, basicos) con respaldo de siempre.
 *            (4) Knux_OnTakeDamage: los basicos de los especiales (y
 *                la garra de la witch) ya se anulaban en silencio;
 *                ahora llevan gesto + pulso + punchstun + hint.
 *  v3.77.38 - 2026-10-10 (reporte del owner tras la 3.77.37):
 *          (1) BUG AVATAR DUPLICADO AL PASAR DE CAPITULO ("ya
 *          transformados en avatar aparece una copia del mismo avatar
 *          en un lugar del refugio... uno pegado a el pero tambien
 *          aparece otro basicamente pegado pero este huerfano no hace
 *          nada — no se limpio antes de iniciar o terminar"): los
 *          avatares OM son prop_dynamic_override PARENTADOS al
 *          jugador y los hijos de players CRUZAN el cambio de mapa de
 *          L4D2; llegan VIVOS pero SIN sus hooks (SetTransmit/
 *          PostThink no sobreviven) = copia huerfana que no hace nada
 *          pegada al jugador. FIX: OM_SweepOrphanAvatars() barre TODOS
 *          los props de avatar del suite en OnMapStart (antes de que
 *          las FSM re-creen) y en OnMapEnd (que no crucen siquiera);
 *          las FSM ven el ref invalido y montan copias frescas con sus
 *          hooks al primer tick.
 *          (2) suite: OM_Stun v2.1 (BOOMER FUSE: Metal v5.5 — el golpe
 *          letal de la embestida NO mata al boomer, estalla al
 *          terminar su stun; Knuckles v71 — el smash aereo lo lanza y
 *          estalla al tocar suelo), Metal v5.5 (+55% de dano de la
 *          embestida; 0 de dano real ya NO interrumpe reparacion/
 *          windup; la witch estampada queda ESTATUA contra la pared
 *          2.0s tras el slam como los SI), Amy v102 (PARRY DELEGADO:
 *          la pose de defensa de la Z abre su ventana de parry en el
 *          chch_parrying.nut v2.3 — contador aparte; proyectil en
 *          rango = defensa de martillo: ataque + aura), Parry.sp v2.2
 *          (uk_parry_window FIJO en 8.0s = la duracion del parry de
 *          Knuckles; el shove instantaneo ya no hace stagger ni dano:
 *          puro empuje) y chch_parrying.nut v2.3 (el shove del parry
 *          sin stagger y sin dano a distancia; SONIDO del bloqueo del
 *          salto de hunter/jockey/smoker; mecha del boomer en el
 *          empuje de la ventana).
 *  v3.77.37 - 2026-10-10 (con Knuckles.inc v70-OM): pedido del owner
 *          ("le quites el parry toggle pues la idea era como te
 *          plantee delegar el parry al vscript, solo el SMX le
 *          avisara que esta activo su shove parry, la ventana quedara
 *          abierta hasta que el smx le diga que knux termino parry"):
 *          TODO el parry de proyectiles del manager SE ELIMINA
 *          (Knux_ParryScan/Reflect/WatchRock, lista de spits, hook
 *          spit_burst + boom diferido, explosion del parry, las 4
 *          convars knux_parry_* y sus defines — el camino del crash
 *          del charco acido muere de raiz). ARQUITECTURA FINAL: el
 *          ejecutor es el VSCRIPT chch_parrying.nut v2.2 (universal +
 *          cono + granadas + props + enemigos con cooldown); el
 *          Parry.smx v2.1 detecta el shove-parry, hace el parry
 *          instantaneo de siempre y AVISA al nut (ChCh_KnxNotify
 *          idx,1,dur = "Knuckles esta en parry"); la ventana queda
 *          ABIERTA toda la duracion y se cierra con la orden de
 *          apagado (idx,0 = "knux termino parry": expiry, muerte,
 *          cambio de equipo, disconnect). La postura (sm_knux_counter)
 *          vuelve a ser SOLO el counter de golpes fisicos de siempre.
 *          Instalacion: manager smx + Parry.smx v2.1 + el
 *          chch_parrying.nut v2.2 en scripts/vscripts/ + cambio de
 *          mapa. Convars del lado VScript: uk_parry_window (duracion
 *          de la ventana que abre el shove) y Knx_Window_* dentro del
 *          propio .nut.
 *  v3.77.34 - 2026-10-10 (con Knuckles.inc v69-OM): aclaracion del
 *          owner ("ES A KNUCKLES! EL CODIGO ERA PARA QUE VIERAS COMO
 *          SE HACE" — el chch_parrying.nut era MATERIAL DE REFERENCIA
 *          del parry, no un mod aparte que el corra) + pedido: "PON UN
 *          COMANDO QUE PUEDA PERMITIR SI KNUCKLES PUEDE PARRY
 *          PROYECTILES (spiter y tank) A SOLAMENTE PARRYEAR GOLPES
 *          FISICOS COMO SIEMPRE". NUEVA PALANCA MAESTRA
 *          knux_parry_projectiles (default 1; console:
 *          knux_parry_projectiles 0): 0 = la postura de Knuckles NO
 *          devuelve NINGUN proyectil (ni spit ni rocas: escaneo y boom
 *          del spit_burst congelados) y queda parrynado GOLPES FISICOS
 *          como siempre (counter/bloqueo melee intacto); 1 =
 *          comportamiento .31-.33 (knux_parry_spit/knux_parry_rocks
 *          siguen finas debajo de la maestra). ADEMAS muere el vector
 *          de crash que QUEDABA vivo tras la v68 (forense del nut,
 *          condicion [C]): el reflect le ponia m_hThrower =
 *          superviviente al SPIT devuelto — el charco acido nace con
 *          la propiedad corrupta y el motor crashea al procesarlo.
 *          v69: al spit NUNCA se le toca el thrower (credito del boom
 *          via la lista de slots); la roca lo conserva (nunca
 *          crasheo). Cvar nuevo auto-agregado al Sonic_Suite.cfg.
 *          Instalacion: SOLO reemplazar el smx + cambio de mapa.
 *  v3.77.33 - 2026-10-10 (con Knuckles.inc v68-OM): el owner reporto
 *          que el crash del counter sobre el spit PERSISTIA tras la
 *          .32 ("todavia se sigue crasheando el left. Analiza bn el
 *          VSCRIPT para poder saber"). Forense completo del
 *          chch_parrying.nut v2.1 (630 lineas): el VScript NUNCA corre
 *          su explosion dentro del codigo del juego — sus callbacks
 *          OnGameEvent_* van a la COLA del script VM (siguiente ciclo)
 *          y su Explode pasa por la COLA de entity I/O
 *          (EntFireByHandle delay 0 = siguiente frame). El HookEvent de
 *          SourceMod es SINCRONO: la v67 ejecutaba la explosion
 *          (CreateEntity + Explode inmediato + SDKHooks_TakeDamage
 *          DMG_BLAST a props/witch/infectados) DENTRO del stack del
 *          spitter_projectile reventando — con vphysics en plena
 *          colision = crash. PRUEBA: la roca (misma explosion pero
 *          desde TIMER) nunca crasheo; solo el spit (desde el evento)
 *          crasheaba. FIX: Knux_Event_SpitBurst queda de SOLO LECTURA
 *          (detecta el spit devuelto a <=16u del subject, captura
 *          posicion + userid, limpia el slot) y TODA la explosion se
 *          difiere a un timer de 0.0s = siguiente frame = la semantica
 *          EXACTA del nut (250/150u solo infectados, JAMAS al equipo).
 *          Paridad nut extra en la explosion: env_explosion spawnflags=1
 *          (NODAMAGE, visual) + rendermode 5 + func_breakable entre los
 *          objetivos del dano manual (targets l.549 del nut). El latch
 *          orientado, el fuego de los puños, el watchdog de rocas y
 *          todo lo demas de la v67 INTACTOS.
 *  v3.77.32 - 2026-10-10 (con Knuckles.inc v67-OM): tres arreglos del
 *          owner. (1) AGARRE DE PARED ORIENTADO ("fix el agarre de
 *          pared si vez el lua este cambia la orientacion de knuckles
 *          al lado contrario a la pared — lo dice el lua"): al
 *          engancharse el avatar queda MIRANDO al lado contrario de la
 *          pared (pill_assignedangle = normal:Angle() del lua
 *          l.767-792, gate |normal.z|<0.5 de solo-paredes l.761) y el
 *          salto de salida sale por la NORMAL de la pared (l.700)
 *          en vez de por la camara — saltar ya no te lanza contra la
 *          pared que dejaste atras. (2) FUEGO REAL EN LOS PUÑOS de la
 *          fase 3 ("puedes colocarle 2 efectos de fuego en los puños
 *          — lo dice el propio lua de gmod"): la espiral
 *          Knuckles_FireOrb exacta del effects lua (radio 35->0, 2
 *          vueltas, ciclo 0.9s, onda 18 Hz) dibujada con beams TE con
 *          material NUEVO om_knux_flame (blaze flame del pack OM) en
 *          CADA PUÑO + nucleo de llama por mano + el anillo
 *          Knuckles_firering al llenar el nivel 3; fallback glow01 si
 *          el material no esta montado (patron om_bluesmoke), palanca
 *          knux_fist_fire (2 archivos nuevos en materials/icons). (3)
 *          FIX DEL CRASH al hacer counter sobre el spit de la spitter
 *          ("en vez de devolverse como hace en Vscript el juego se
 *          muere y se cierra"): la v66 hookeaba el Touch del
 *          spitter_projectile y lo mataba con Kill — el juego revienta
 *          el spit por DENTRO de su propio touch y el doble-manejo lo
 *          tumbaba. Ahora nut-faithful: el spit SOLO se devuelve
 *          (velocidad + m_hThrower + lista propia de refs) y la
 *          explosion la pone el evento spit_burst del juego (el mismo
 *          camino del ChCh_Parrying, explosion 250/150u solo
 *          infectados); las rocas pierden el touch hook (quedan con el
 *          watchdog de velocidad del nut, vel<=100 o 5s) y el boom de
 *          ambas pasa a los explode_1-3 del original.
 *  v3.77.31 - 2026-10-09 (con Knuckles.inc v66-OM): tres arreglos del
 *          owner sobre el Knuckles + la mejora del parry. (1) LA CARGA
 *          DEL PUÑO DE 3 NIVELES que faltaba ("el puño se puede cargar,
 *          el lua lo dice todo"): nivel 2 a los 4.5s (knux_charge_t1,
 *          phase1.wav + pulso rojo), nivel 3 a los 9s (knux_charge_t2,
 *          phase3.wav) con las ORBES DE FUEGO en los puños desde 0.6s
 *          antes (Knuckles_FireOrb del lua) — y el golpe escala como el
 *          original: dano x1.15/x1.30, stun de ESTATUA OM_Stun
 *          4/5/6s EMPUJABLE (la estatua vuela y desliza como el rayo
 *          de Tails), lanzon x1/x2/x3, QUEMA 8s al nivel 3; el CLICK
 *          suelta Slam1-4.wav y el cancel con [R] cobra el cooldown
 *          corto del original (knux_punch_cd_cancel 5s). (2) LAS
 *          ANIMACIONES DEL BLOQUEO que no salian ("no hace su
 *          animacion de golpe ni de preparacion"): preparacion
 *          'counter' al activar la postura (gesture RANGE_ATTACK1 del
 *          lua) y golpe 'counter_hit' al bloquear (RANGE_ATTACK2) +
 *          FIX DE FACING: esas secuencias miran a la DERECHA en el mdl
 *          (aviso del owner) — el avatar gira +90 durante el one-shot
 *          (KNUX_COUNTER_YAW_FIX, 1 linea si hay que invertirlo).
 *          (3) PARRY DE PROYECTILES en la postura (receta
 *          ChCh_Parrying v2.1 que el owner paso): escupitajos del
 *          spitter y ROCAS DEL TANK devueltos hacia donde apunta el
 *          Knuckles (cono dot 0.30 + emergencia 100u + piso 900 uu/s,
 *          roca a x1.5, credito m_hThrower) que DETONAN al aterrizar
 *          o tocar a un infectado (roca 500/250u, spit 250/150u, dano
 *          SOLO a infectados — jamas al equipo). Reemplaza el reflejo
 *          tosco v58 (Kill + respawn de grenade_launcher). Convars
 *          knux_parry_spit / knux_parry_rocks / knux_parry_radius.
 *  v3.77.30 - 2026-10-09 (con Knuckles.inc v65-OM): DOS pedidos del
 *          owner en uno. (1) FIX DE LAS RANURAS AL CAMBIAR DE
 *          PERSONAJE ("si cambio ejemplo metal la habilidad que iba
 *          en la 3 pareciera irse a la 4 y la 3 queda como una
 *          habilidad que amy poseia y sale un mensaje que no se puede
 *          usar"): causa raiz — OnPlayerSelectCharacter solo bindeaba
 *          Z/X para todos; la C se bindeaba SOLO para Sonic/Tails/
 *          Sage/Amy, asi que Knuckles/Rouge/Metal JAMAS recibian su
 *          bind de la habilidad 3, y quien viniendo de Amy conservaba
 *          c=sm_amymodo (el "no se puede usar"), v=ability3 (por eso
 *          la 3 "se iba a la 4") y b=ability4 pegados. FIX: fila de
 *          binds COMPLETA e IDEMPOTENTE en cada seleccion — Z/X
 *          siempre, C=ability3 para TODOS menos Amy (c=amymodo +
 *          v=ability3 + b=ability4), y V/B devueltos a su estado
 *          neutral (unbind) fuera de Amy para que no queden apuntando
 *          a comandos de otro personaje. (2) EL AVATAR DE KNUCKLES
 *          (5o avatar del suite, models/Noodles/OM/knuckles.mdl del
 *          VPK om_): patron Metal v5.4 — doble copia R/L + modo TP
 *          tails_avatar_tp + pulso de pausa + FSM 10 Hz con las 15
 *          secuencias del knuckles.mdl que usa el lua GMod (idle/
 *          walk/run/jump/fall + glide/latch/FallAttack + one-shots
 *          PunchAnim/GroundSmash/attack/LatchOff + variantes
 *          lowhealth HP<=60), tintes del knuckles_ui_om.lua (pulso
 *          ROJO de carga con el fade simetrico exacto 0.25s, BLANCO
 *          de bloqueo de contra, VERDE de cancelacion, postura azul
 *          200,200,255), sonidos autenticos om/knuckles/ del VPK
 *          con fallback stock (punchstart/swing/punchstun/counter/
 *          CounterBounce/Latch/KnucklesCancel), ragdoll de muerte
 *          prop_ragdoll + ventana anti-corpse 2s/200u y cvar
 *          knux_avatar 1. Cero materiales nuevos.
 *  v3.77.29 - 2026-10-09 (con Metal.inc v5.4-OM): FIX DEL FROZEN DE LA
 *          WITCH (cuarta ronda del owner): "la witch no se congela (no
 *          se le aplica el freeze para Nextbot)... el stun normal sirve
 *          pero el frozen no esta sirviendo para la witch... Tails y Amy
 *          aplican el frozen incluso Sonic pero Metal no". Causa raiz:
 *          la 3.77.28 congelaba a la witch SOLO con MOVETYPE_NONE (la
 *          fisica quieta) — su IA seguia VIVA (se animaba y podia
 *          zarpear en el sitio); el congelado de verdad del suite
 *          (Tails/Amy/Sonic via Sonic_WitchStun) usa DOS capas:
 *          FL_FROZEN (apaga su IA = ESTATUA) + MOVETYPE_NONE. Metal.inc
 *          v5.4: Metal_WitchFreeze (FL_FROZEN propio + Sonic_WitchStun
 *          con estrellas) re-afirmado en catch/arrastre/golpes del
 *          estampado, suelta limpia (slot de Sonic liberado + solo el
 *          flag que pusimos nosotros) y la EXPLOSION DE MUERTE ahora
 *          tambien congela a la witch del radio (estatua 5.5s + ragdoll
 *          volador, receta Amy). Cero cvars nuevos, cero materiales.
 *  v3.77.28 - 2026-10-09 (con Metal.inc v5.3-OM): QUINTETO de la
 *          tercera ronda del owner (2026-10-09):
 *          (1) FIX CRITICO — LA INMUNIDAD ANTI-CONTROL DE METAL ESTABA
 *          MUERTA: los guards de la 3.77.27 estaban cableados en ESTE
 *          manager a 6 FORWARDS FANTASMA que left4dhooks NUNCA invoca
 *          (compilan, jamas se llaman — por eso "un smoker me pudo
 *          agarrar con la lengua durante la carga"). Los forwards
 *          REALES viven en Knuckles.inc (lengua/carry/fling) y
 *          sonic.inc (pounce/jockey) con sus guards de siempre: los
 *          guards de Metal ahora van ALLI (Metal_ControlImmune en las
 *          5 entradas reales) + L4D2_OnStagger (que NO existia en
 *          ningun lado — solo el _Post de Tails) se implementa NUEVO
 *          en este manager. De paso REVIVEN pedidos viejos del owner
 *          que solo vivian en los fantasmas: la contra de lengua de
 *          Amy v64 (rompe la lengua al instante) en el forward real
 *          de la lengua, y Amy_GrabCounter/Knuckles_CheckSpecialCounter
 *          en pounce/jockey (ya corrian en el carry).
 *          (2-5) Metal.inc v5.3: avalancha de comunes + witch
 *          embestible + anti-atasco (DEBRIS en el arrastrado, teleport
 *          detras al atasco) + vida maxima 175 al escogerlo (hook de
 *          seleccion: Metal_ApplyMaxHealth YA, sin esperar spawn).
 *  v3.76.3 - 2026-10-07 (con sonic.inc v6.3-OM): SPINDASH SIN RE-MONTAJE
 *          (diseno del dueno, 3.a ronda): "haremos invisible a sonic (no
 *          lo destruiremos) durante toda la secuencia; cuando el spin
 *          termine lo hacemos visible otra vez". El retorno de la bola ya
 *          NO re-monta el avatar: Sonic_CreateBall OCULTA el avatar R+L
 *          (RENDER_NONE, entidades vivas) mientras rueda, y EndRoll /
 *          OM_Cancel solo devuelven visibilidad + snap de smoothing.
 *          Cero "como si hicieramos sc" por spindash, cero pausas en
 *          combate. Blindajes: la FSM no repara la copia L en pleno ROLL
 *          (montarla ahi dispararia el pulso); fallback sin pulso si el
 *          avatar murio a mitad de bola; des-ocultado inmediato si la
 *          bola no nace; el EndRoll ahora respeta sonicom_avatar 0.
 *          ESTE manager no cambia codigo: solo version (todo vive en
 *          sonic.inc).
 *  v3.76.2 - 2026-10-07 (con sonic.inc v6.2-OM): TRIPLE FIX de la segunda
 *          prueba de campo del owner ("por ahora bn pero al morir
 *          aparece el cuerpo del personaje y 2 ragdolls... cuando sonic
 *          usa el spindash xq se genera denuevo la broma de pausa?"):
 *          (1) CRASH "Property m_Local.m_flFallVelocity not found" en
 *          Sonic_OM_Spindash: la propiedad no existe como Prop_Send en
 *          L4D2 (en el v5.4 el homing que la usaba era codigo muerto).
 *          Fix en sonic.inc: helper Sonic_ResetFallVelocity con guard
 *          HasEntProp (los 3 call-sites cubiertos).
 *          (2) MUERTE SUCIA (survivor visible + ragdoll doble): la
 *          muerte de Sonic corria en el hook PRE de ESTE manager —
 *          antes de que el motor procesara la muerte — y el restore
 *          del cuerpo dejaba ver el corpse. Fix: Sonic engancha su
 *          PROPIO player_death POST (paridad Tails_Event_PlayerDeath)
 *          y este manager YA NO lo llama desde el PRE (bloque
 *          retirado de Event_PlayerDeath).
 *          (3) PAUSA TRAS CADA SPINDASH: el pulso sv_pausable
 *          (Tails_PauseFix_Trigger) disparaba en el re-montaje del
 *          avatar al terminar la bola. Fix: Sonic_CreateAvatar gana
 *          pulsePause; el re-montaje post-bola (EndRoll/OM_Cancel) no
 *          pulsa. El pulso queda solo en spawn/seleccion/FSM-repair
 *          (como Tails).
 *  v3.76.1 - 2026-10-07 (con sonic.inc v6.1-OM): HOTFIX de la primera
 *          prueba de campo del owner ("selecciono a sonic y no
 *          aparece el avatar ni sus comandos... al cambiar aparece
 *          solamente el ragdoll de sonic"). DOS bugs de integracion:
 *          (1) ARRANQUE: el slot de Sonic en OnPluginStart seguia
 *          llamando Sonic_OnMapStart() (herencia del v5.4, que no
 *          tenia Sonic_OnPluginStart) — el Sonic OM v6.0 NUNCA se
 *          inicializaba: 0 convars sonicom_* (=> "Invalid convar
 *          handle 0" en CADA OnClientPutInServer, que ademas abortaba
 *          los SDKHooks), 0 comandos y FSM del avatar muerta. FIX:
 *          Sonic_OnPluginStart() cableado (los 18 convars + los 5
 *          comandos + el timer de 10Hz) + Sonic_OnMapStart() extra
 *          para late-load (precarga si el plugin carga a mitad de
 *          mapa, igual que el pristino).
 *          (2) RAGDOLL EN CAMBIO: CleanupCharModuleState limpiaba a
 *          Sonic con Sonic_Event_PlayerDeath, que desde v6.0 spawnea
 *          el ragdoll de muerte => cambiar de Sonic a otro personaje
 *          (o desconectar) dejaba el ragdoll OM tirado. FIX: nueva
 *          Sonic_CleanupState (limpieza pura SIN ragdoll, patron
 *          Tails_OnPlayerDeath) para el cleanup; la muerte real
 *          sigue por Sonic_Event_PlayerDeath con su ragdoll y su
 *          ventana anti-ragdoll intactos.
 *  v3.76.0 - 2026-10-07 (con sonic.inc v6.0-OM): EL SONIC DE GMOD OM
 *          LLEGA AL SUITE ("es hora de incluir a sonic... spindash/
 *          dropdash y peel out... solo seria un trabajo de inclusion
 *          y prueba debido a que como dije nuestro sistema ya esta bn
 *          armado"). Fuente: noodles_om_pills_survivors_sonic.lua del
 *          pack del owner + sonic.mdl/sonicball.mdl del models.zip.
 *          Portado con el PATRON TAILS (el sistema ya probado):
 *          - Z = SPINDASH (suelo; brinco + windup 0.65s -> BOLA
 *            sonicball.mdl que arrasa golpeando/stuneando/empujando,
 *            invulnerable mientras rueda, +anillos por golpe) /
 *            DROPDASH (aire: picoada que aterriza en bola). Al 3er
 *            golpe (maxhits GMod): FINAL con drill + explosion de
 *            area + rebote. COMBO: Z durante la carrera del Peel
 *            convierte el resto en bola (GMod DropdashPeelout).
 *          - X = PEEL OUT: carga 3s clavado (PeelOutStart frenando a
 *            0) -> carrera 800 uu/s guiada con el mouse + "I'm outta
 *            here" sin enemigos + RESCATE: tocar a un companion
 *            incapacitado lo LEVANTA (CD corto si rescato / largo si
 *            no, GMod success/fail) + Braking al terminar.
 *          - C = HOMING ATTACK v5.4 ENCADENABLE MIGRADO INTACTO de la
 *            Z (nada se pierde, solo se muda). Sonic Wind queda como
 *            sm_sonicwind (sin tecla).
 *          - ANILLOS (GMod Dodgemeter): el dano directo se absorbe en
 *            anillos (50; +10 por golpe de bola; DoT excluido igual
 *            que GMod) con la anim de esquiva Dodge1-4.
 *          - AVATAR sonic.mdl (patron Tails v5.24): 20 anims (idle/
 *            walk/run/jump/fall/Spindash/dive/PeelOut/PeelOutStart/
 *            Braking/roll/Downed/lowhealth/Dodge1-4), copia R + L del
 *            dueno, EF_NOINTERP al nacer, PULSO DE PAUSA reusando la
 *            infra de Tails (un solo sistema sv_pausable), FSM 10Hz
 *            auto-reparable, cuerpo del survivor oculto.
 *          - Convars NUEVOS sonicom_* (18) en la CONFIG UNICA (prefijo
 *            agregado a g_sSuitePrefixes). #include <sonic> se mueve
 *            DESPUES de <Tails> (reusa sus helpers de avatar).
 *          - SE CONSERVA del v5.4: Insta-Shield doble salto, inmunidad
 *            de caida + dropdash automatico salvavidas, explosion de
 *            kill melee, revive "nervios de acero" (switch admin),
 *            homing encadenable completo (en C).
 *  v3.75.4 - 2026-10-07 (con Tails v5.24): dos pedidos del owner.
 *          (1) RESTAURAR el pulso de pausa en CADA montaje del avatar
 *          ("yo no te pedi que le quitaras lo del respawn sc y demas
 *          todo eso estaba bn RESTAURALOS"): el gate "solo al iniciar
 *          la ronda" de la v3.75.3 se retira ENTERO — el pulso vuelve
 *          a dispararse en !sc, respawn y auto-reparacion de la FSM,
 *          exactamente como en la v5.22/v5.20.6.
 *          (2) FIX del congelado de especiales ("dime xq el stun frozen
 *          especial de la witch no funciona con los otros especiales"):
 *          la witch es un NPC NextBot (FL_FROZEN le corta TODO) pero
 *          los especiales son bots de PLAYER — con solo el martillo
 *          su simulacion seguia viva. Se portan las capas de OM_Stun
 *          (el stun probado del suite contra SI, lo usa Metal):
 *          m_flLaggedMovementValue = 0 re-afirmado cada tick + tinte
 *          cyan de hielo (restauracion exacta al liberar).
 *  v3.75.1 - 2026-10-06 (con Tails v5.20.6): PULSO DE PAUSA REAL.
 *          Pedido del owner tras su hallazgo de campo (pause con
 *          sv_pausable 1 cura el tilt del avatar toda la partida):
 *          cada vez que se monta el avatar de Tails el servidor hace
 *          UNA pausa momentanea (0.1s, imperceptible) que re-encaja
 *          el estado del cliente automaticamente. sv_pausable queda
 *          forzado a 1 (config obligatoria). La FSM del pulso corre
 *          en el OnGameFrame de este manager (primera linea). Cvars:
 *          tails_pausefix / _delay / _duration.
 *  v3.75.0 - CONFIG UNICA AUTO-GUARDADA (rediseño del owner,
 *          2026-10-06: "deberia haber un solo archivo que maneje
 *          todos los cvars, y lo que coloques en el server reemplace
 *          directamente el cfg — un auto guardado... tener mas de un
 *          archivo que maneje los mismos cvars es malo, innecesario e
 *          inutil"). FIN de los 9 AutoExecConfig por modulo: ahora UN
 *          SOLO archivo (cfg/sourcemod/Sonic_Suite.cfg) con los 145
 *          cvars del suite, creado la 1ra vez con los defaults del smx,
 *          ejecutado en cada mapa, y AUTO-GUARDADO: cualquier cambio
 *          hecho en el server (sm_cvar etc.) se escribe en el archivo
 *          ~1s despues. Los archivos viejos (Tails_Abilities.cfg,
 *          Speed_Sonic.cfg, sonic_jump_survivors.cfg, Knuckles/.
 *          Amy_/Sally_/Rouge_/Cream_/Eggman_Abilities.cfg) quedan
 *          MUERTOS: nada los vuelve a ejecutar. Esto cura el bug del
 *          "canon en 45s que nunca cambia": esos archivos se habian
 *          generado con defaults VIEJOS y pisaban los nuevos en cada
 *          mapa (y los cambios por consola no se guardaban en nada).
 *          Tambien: tails_follow default 0 (pedido del owner: "el
 *          follow debe ser 0 en vez de 1 como predeterminado para
 *          TODO") y nuevo comando sm_tailscd (sonda de valores
 *          vivos vs default de fabrica). Requiere Tails.inc v5.20.3.
 *
 *  v3.74.0 - OM-TAILS R6 (veredicto del owner, 2026-10-06: "es inutil
 *          el pitch es el unico metodo que permite al model moverse
 *          sin esos molestos mini tirones... pero bueno... ponle de
 *          item una bomba de bilis xq esa no tiene efecto de llamas"):
 *          ROLLBACK al seguimiento PARENTADO del v5.7 (el "metodo del
 *          pitch": el UNICO sin mini tirones — el motor de cada
 *          cliente mueve al avatar junto al survivor). Se retira el
 *          carrier de la v5.8 (stepping que ni la v5.9/v5.9.1
 *          arrancaron) y el approach ornament de la v5.10 (parpadeo
 *          del survivor + "cadaver" de Tails al morir). El tilt
 *          momentaneo al apuntar arriba/abajo vuelve y el owner lo
 *          ACEPTA ("pero bueno"). NUEVO: el item del modo ORBS es la
 *          BOMBA DE BILIS real de L4D2 (w_eq_bile_flask.mdl, ruta
 *          verificada: sin llama, sin parpadeo, fisica nativa de
 *          throwable — nada de "Can't create physics object").
 *          Laser v5.7 al centro de la mira: INTACTO. Requiere
 *          Tails.inc v5.11.
 *
 *  v3.72.0 - OM-TAILS R3 (fix del owner, 2026-10-05: "tails se tumba
 *          con la mira como la linterna de L4D2: apuntas arriba/abajo
 *          y el cuerpo se acuesta y se vuelve a parar; desactiva la
 *          inclinacion"): el avatar de Tails ya NO se parenta al
 *          survivor (en L4D2 el transform del player lleva la camara
 *          encima) sino a un CARRIER invisible con angulos SIEMPRE
 *          (0, yaw, 0): el cuerpo queda vertical SIEMPRE, en todos
 *          los clientes, sin carreras de timing (la contra-rotacion
 *          local de la v5.6/v5.7 llegaba tarde al cliente y por eso
 *          el cuerpo se tumbaba y se recuperaba). MISMA suavidad de
 *          posicion/anims del v5.7 (lead del lerp intacto, avatar sin
 *          writes por tick) y el FIX del laser (v5.7: rayo al centro
 *          de la mira) intacto. Requiere Tails.inc v5.8.
 *
 *  v3.73.0 - OM-TAILS R4 (fix del owner, 2026-10-05: "se nota un
 *          pequeno desfase en forma de tick; si asi se comporta en el
 *          online sera malo xq el retrazo seria muy evidente"): FIX
 *          DEL STEPPING del avatar de Tails (v5.9). El CARRIER invisible
 *          de la v5.8 se movia por tick con TeleportEntity desde el
 *          server, pero un prop que nunca simula NO avanza
 *          m_flSimulationTime -> el cliente recibia todos los snapshots
 *          con la misma marca de tiempo y NO interpolaba: el avatar
 *          avanzaba CONGELADO 3-4 frames y BRINCABA (analisis frame a
 *          frame del video del owner: deltas 0.00px exactos + saltos de
 *          4-14px). FIX: despues de cada TeleportEntity se estampa
 *          m_flSimulationTime = GetGameTime() (Tails_MarkInterp): la
 *          linea de tiempo del cliente vuelve a avanzar -> el carrier se
 *          interpola SUAVE por frame en TODOS los clientes, online
 *          incluido (misma maquinaria de interpolacion que los players
 *          remotos: nada de interp 0, nada de saltos). Cuerpo vertical
 *          (v5.8), laser al centro de la mira (v5.7), vuelo y canon 4
 *          modos: INTACTOS. Requiere Tails.inc v5.9.
 *
 *  v3.73.1 - OM-TAILS R5 (HOTFIX del log del owner, 2026-10-05:
 *          "[SM] Exception reported: SendProp m_flSimulationTime
 *          type is not float (0 != 1)" repetido en cada tick,
 *          blaming Tails::Tails_MarkInterp): en L4D2
 *          m_flSimulationTime NO viaja como float: el SendProp es
 *          ENTERO (DPT_Int) y guarda el TICKCOUNT del server. El
 *          write de la v5.9 con SetEntPropFloat lanzaba EXCEPCION
 *          EN CADA TICK -> la estampa del fix del stepping NUNCA
 *          se aplico (y el spam abortaba el callback cada tick,
 *          ~20 excepciones/s). CORRECCION: SetEntProp entero con
 *          GetGameTickCount() = el mismo valor que estampa el
 *          motor al simular -> la interpolacion del carrier
 *          ahora SI corre de verdad y desaparece el spam. Laser
 *          v5.7, pitch cero v5.8, 3 reglas de yaw, vuelo y
 *          canon: INTACTOS. Requiere Tails.inc v5.9.1.
 *
 *  v3.71.0 - OM-TAILS R2 (pedido del owner: "lo del tailscannon mejor
 *          colocala como su habilidad 3 para cambiar su tipo (una
 *          habilidad sin CD)"): la HABILIDAD 3 (tecla C) de Tails =
 *          CAMBIO DE MODO DEL CAÑÓN (Laser -> Burst -> Orbs ->
 *          Shockwave), SIN cooldown (solo anti-spam 0.5s del GMod,
 *          convar tails_togglecd). Bind C al elegir a Tails + anuncio.
 *          sm_sjsver ahora reporta Tails %s. Requiere Tails.inc v5.1
 *          (tint laserswap del avatar con colores exactos GMod).
 *
 *  v3.70.0 - OM-TAILS: spawn de Tails crea el avatar espejo OM (tails.mdl,
 *  VPK de recursos) + hook de cancel por dano (vuelo/cañón interrumpidos,
 *  igual que el pill de GMod). Requiere Tails.inc v5.0.
 *
 *  v3.66 - KNUCKLES v64 "METEORO FIX" (ronda 32). Reporte del owner:
 *          "al presionar la c explota en el aire y no deberia ser...
 *          deberia ser impulsado a la direccion donde el seleccione y
 *          caera por gravedad... la explosion sucede despues de que
 *          este impacte en el suelo... la roca tambien deberia no estar
 *          muy separado... deberia ir a la direccion de donde el
 *          apunte... fix al contacto con una pared suelo o algo ya que
 *          esta las ignora y explota con tiempo". Causa raiz (2 bugs
 *          gemelos): KNUX_SKY_DIVE_MINUP / KNUX_SKY_BALL_MINUP
 *          forzaban +150 vertical (la picada/esfera salian hacia
 *          ARRIBA al apuntar abajo) y el think re-afirmaba la velocidad
 *          de la picada cada frame (la gravedad se borraba -> flotaba
 *          hasta detonar en el aire). FIX: velocidad = mira EXACTA, un
 *          solo impulso, vuelo con gravedad real, explosion al IMPACTAR
 *          (suelo por ONGROUND / muro por trace horizontal / tapa 3s);
 *          esfera pegada al cuerpo (35u) hacia donde apuntas con trace
 *          de contacto + pad anti-tunel (timer 2.5s solo de respaldo).
 *          sm_sjsver: "Knuckles v64 (props + H3 Meteoro v64)".
 *          Archivos que cambian: Knuckles.inc (v64) + este .sp
 *          (+ .smx). Rouge v9.1/Amy/Sally y demas INTACTOS.
 *
 *  v3.65 - ROUGE v9.1 "ONDA NEGRA: FIX + CINEMATICA" (ronda 31).
 *          Reporte del owner: "la habilidad de rouge esta malisima...
 *          los commons quedan congelados... la witch queda congelada
 *          nunca muere nunca es atraida... solos ale una onda que sale
 *          y vuelve". Causa raiz en Rouge.inc: Rouge_WaveGrab congelaba
 *          a la victima pero NUNCA registraba su ref en el pool ->
 *          T_RougeWaveTick veia active == 0 y se apagaba en su primer
 *          tick -> estatuas congeladas eternas sin arrastre ni dano.
 *          FIX: g_iRWWRef[slot] = ref (el pool SI registra).
 *          CINEMATICA NUEVA: NUCLEO DE ONDA (esfera negro-magenta del
 *          modelo del escudo de Sally) en el punto de convergencia
 *          elevado — las victimas se succionan hacia el corazon de la
 *          esfera y al llegar (0.75s) COLAPSA: kill + anillo de
 *          implosion + particula + boom. Trace anti-muro +2u (el piso
 *          ya no dispara falsos muros). sm_sjsver: "Rouge v9.1 (Onda
 *          Negra FIX)". Archivos que cambian: Rouge.inc (v9.1) + este
 *          .sp (+ .smx). Knuckles/Amy/Sally/Sage y demas INTACTOS.
 *
 *  v3.64 - KNUCKLES v63 (ronda 30): pedido del owner: "su golpe ahora
 *          tanto su lanzamiento hacia adelante como su golpe al suelo
 *          en area ahora Puede empujar Objetos (props) autos y demas
 *          Con el mismo tipo de sistema que amy (sin la parte de
 *          convertir objetos en V) y como 3 habilidad Tendra 2
 *          variaciones si esta en el aire este se elevara... y causara
 *          una mega explosion... Los especiales tambien son mandados a
 *          volar (execto al tank)... el Boomer si es mandado a volar no
 *          explotara de inmediato... la 2 variacion es en tierra este
 *          lanzara Una (esfera como... el escudo de sally) pero este
 *          seria un proyectil que al impactar al suelo estallara".
 *          - TECLA C con Knuckles (sm_sjs_ability3 / sm_knux_sky):
 *            H3 "METEOR STRIKE", recarga 20s (knux_sky_cooldown).
 *            * VARIACION AEREA: elevacion (300u) -> apuntado -> 2a
 *              pulsacion de C -> picada 1800 u/s -> MEGA EXPLOSION
 *              estilo "detonador" (NATIVA de Knuckles.inc: el VScript
 *              del Super Tank va INTACTO) SIN TEMBLOR.
 *            * VARIACION TERRESTRE: ESFERA DE FUEGO (atlas_break_ball,
 *              la del escudo de Sally, en pequeno y naranja) como
 *              proyectil: estalla al impactar suelo/muro/infectado.
 *          - LA EXPLOSION: comunes y WITCH volando (WitchFlight),
 *            especiales por PESO deducido (Jockey 1.25 ... Charger 0.70)
 *            EXCEPTO el tank (solo dano), BOOMER con mecha diferida
 *            (patron Amy v64: empujado -> explota tiempo despues),
 *            y PROPS/AUTOS con V activo (receta Amy SIN conversion).
 *          - AJUSTE 1: el DASH PUNCH y el GROUND SLAM del Meteor Smash
 *            empujan props/autos con V (VPHYSICS) — receta del martillo
 *            de Amy (golpe real + despertador env_physexplosion +
 *            aventon), sin conversion de decorativos.
 *          - sm_sjsver: "Knuckles v63 (H3 Meteoro + props)".
 *            ConVars: knux_sky_* (13) + knux_prop_force/blast +
 *            knux_boomer_fuse. Archivos que cambian: Knuckles.inc (v63)
 *            + este .sp (+ .smx). El resto INTACTO.
 *
 *  v3.63 - ROUGE v9 "HABILIDAD 3: ONDA NEGRA" (ronda 29): pedido del
 *          owner: "La 1 que dijiste esta destructora. Pero quitale el
 *          temblor (para evitar mareos por usos constantes y demas).
 *          Tambien colocale que pueda jalar a la witch pero para eso
 *          se nesesita aplicar el metodo que se uso con el golpe de
 *          martillo de amy que apaga su Nextbot y la congela como tal
 *          para que esta pueda comportarse igual. Tambien haslo con
 *          los commons: osea apagarles el cerebro y congelarlos para
 *          que ellos tambien puedan ser jalados".
 *          - TECLA C con Rouge (sm_sjs_ability3 / sm_rouge_wave):
 *            BLACK WAVE, el concepto A "la destructora": onda
 *            expansiva negra de rango S (1000u, rouge_wave_radius),
 *            recarga 17s (rouge_wave_cooldown). Anillos negro-magenta
 *            que se EXPANDEN y CONTRAEN (implosion) + particula de
 *            suelo gas_explosion_ground_wave (la del agujero negro
 *            del Super Tank, precacheada por nosotros). SIN TEMBLOR:
 *            cero env_shake / ScreenShake (pedido literal: evitar
 *            mareos por usos constantes).
 *          - JALON (el corazon del pedido):
 *            * ESPECIALES/TANK: succion por velocidad + stagger
 *              seguro (SIStagger_Auto) + dano inmediato.
 *            * COMUNES y WITCH: EL METODO DEL MARTILLO DE AMY
 *              (Witch_Flight v2.x): FL_FROZEN apaga su cerebro
 *              NextBot + MOVETYPE_NONE congela su cuerpo -> el sistema
 *              los ARRASTRA por teleports (20 Hz) hasta 80u de Rouge,
 *              con trace brush-only por paso (anti-muro). Llegada
 *              (0.75s): restauracion EXACTA + dano (comunes x2) y la
 *              witch llega ENFADADA (m_rage=1.0, patron
 *              WitchFlight_Landing). NO se edito el VScript del Super
 *              Tank: la onda es NATIVA de Rouge.inc (v9).
 *          - La H3 es EXCLUSIVA de la Rouge real (las granadas Z/X se
 *            prestan al set ROUGE de Sage; la onda es su firma, como
 *            evasion/planeo). Fallback de la C actualizado.
 *          - sm_sjsver: "Rouge v9 (granadas + H3 Onda Negra)".
 *            ConVars: rouge_wave_cooldown 17 / rouge_wave_radius 1000
 *            / rouge_wave_damage 400 (comunes x2 al llegar).
 *          Archivos que cambian: Rouge.inc (v9) + este .sp (+ .smx).
 *          Amy.inc/Cream.inc/Sally.inc/Sage.inc/Metal.inc/Eggman.inc/
 *          sonic.inc/Speed_sonic.inc/nut INTACTOS.
 *
 *  v3.62.1 - SALLY v6.1 + SAGE v2.1 "PEQUEos FIXES" (ronda 28.1):
 *          pedido del owner: "Nesesitamos un peqeuo fix 1 el rebote
 *          del escudo de agua no deberia destruirse apenas se use
 *          2 el escudo de fuego aun cuando se destruye el escudo el
 *          sonido de el escudo de fuego sigue sonando y 3 el change
 *          de habilidades no tendra CD en si".
 *          - FIX 1 (Sally v6.1): la burbuja acolcha TODAS las caidas
 *            mientras este activa (DMG_FALL negado completo, SIN tocar
 *            el HP del escudo). Antes la caida rebotona (freno a -900)
 *            aplicaba dano de caida que el propio escudo absorbia y lo
 *            rompia en 1-2 rebotes. Vale igual para la Sally real y
 *            los regalos de Sage.
 *          - FIX 2 (Sally v6.1 + Sage v2.1): sonidos de escudo en canal
 *            propio (SALLY_SHIELD_SNDCHAN = SNDCHAN_STATIC) con corte
 *            reforzado en Sally_StopAllSounds (canal propio + AUTO, 2
 *            pasadas anti-apilado) + el jingle STOP/BREAK desaloja el
 *            slot del loop + sin doble-emit en Sage_CastTeamShield
 *            (Sage tambien recibe escudo: 2 emisiones apiladas del
 *            mismo sample = una sobrevivia al StopSound).
 *          - FIX 3 (Sage v2.1): Sage_SwapSet (tecla C) SIN cooldown —
 *            SAGE_SWAP_CD/g_fSageSwapNext eliminados. "El change de
 *            habilidades no tendra CD en si" (mismo criterio v3.61
 *            del cambio de modo de Amy).
 *          Archivos que cambian: Sally.inc (v6.1), Sage.inc (v2.1) +
 *          este .sp (+ .smx). Rouge.inc/Amy.inc/Cream.inc/Metal.inc/
 *          Eggman.inc/sonic.inc/Speed_sonic.inc/nut INTACTOS.
 *
 *  v3.62 - SAGE v2 + SALLY v6 "SETS SALLY Y ROUGE" (ronda 28): pedido
 *          del owner: "podriamos colocar que sage si usa a sally
 *          ella puede darle escudos de agua o escudos fuegos a todo
 *          el equipo (obiamente duraran un tiempo como siempre ha
 *          durado) la de ella durara 5 seg mas antes de desaparecer.
 *          Se añadira el estilo rouge con sus granadas".
 *          - SET SALLY (nuevo; la C cicla entre 4 sets): Z = ESCUDO
 *            DE AGUA a TODO el equipo (absorb 250 + regen 1HP/1.5s +
 *            caida rebotona; 15s "como siempre") | X = ESCUDO DE
 *            FUEGO (absorb 300 + aura de dano/quemado/empuje + dash;
 *            20s). El escudo de la PROPIA SAGE dura +5s. La Sally
 *            real queda fuera del reparto (sus escudos propios son
 *            permanentes). XOR de Sally: no se apilan escudos.
 *          - SET ROUGE (nuevo): Z = CEBO QUIMICO | X = BAT BOMB
 *            SPRAY. Rouge.inc acepta a Sage con set ROUGE solo en sus
 *            2 comandos de granada (evasion/planeo NO se prestan).
 *          - SALLY.inc v6: gates de logica Sally_IsSally ->
 *            Sally_ShieldSubject (Sally real O receptor de regalo) en
 *            RunCmd/Boost/Bounce/Regen/Explosion/Pulse; el ABSORB de
 *            Sally_OnTakeDamage cubre a los receptores; la inmunidad
 *            a acido/veneno/radiacion sigue siendo SOLO de la Sally
 *            real. Comandos sm_ de Sally intactos (exclusivos).
 *          - RunCmd: cualquier personaje con escudo regalado recibe
 *            la logica dash/bounce de Sally. TankClaw/KnockedDown:
 *            el burbuja regalado protege igual al receptor.
 *          - Flags de regalo (g_bSageGiftWater/Fire + ends) viven
 *            AQUI, antes de los includes: Sally.inc los lee y
 *            Sage.inc los administra con su timer de expiracion.
 *          - ConVars: sagesally_water_cd 20 / sagesally_fire_cd 35 /
 *            sagesally_water_dur 15 / sagesally_fire_dur 20 /
 *            sagesally_sage_bonus 5. sm_sjsver reporta Sally v6.
 *          Archivos que cambian: Sage.inc (v2), Sally.inc (v6),
 *          Rouge.inc (gates de granadas) + este .sp (+ .smx).
 *          Amy.inc/Cream.inc/Metal.inc/Eggman.inc/sonic.inc/
 *          Speed_sonic.inc/nut INTACTOS.
 *
 *  v3.61 - AMY v90 "HABILIDAD 3 = CAMBIO DE MODO" (ronda 27): pedido
 *          del owner: "si vamos a colocar el boton te 3 habilidad
 *          pongamos el comando de una vez de habilidad 3... el comando
 *          de amy especial para cambiar pasara a ser su habilidad 3
 *          direcrtamente (obiamente no tendra cd...) con sage sera =
 *          la 3 ahabilidad es para cambiar el set de habilidades (el
 *          resto del elenco seguira con 2)".
 *          - La HABILIDAD 3 (tecla C = sm_sjs_ability3) pasa a ser un
 *            comando UNICO del suite: AMY -> cambio de MODO Z
 *            (IMPULSO/embestida <-> GOLPE AOE/martillo 360) SIN
 *            cooldown (es preferencia, no ataque; "si no, no tendria
 *            sentido si quiere cambiar de modo salto o modo area");
 *            SAGE -> cambio de SET (R26 intacto, anti-spam 3s);
 *            DEMAS -> aviso: siguen con 2 habilidades (Z/X).
 *          - bind c sm_sjs_ability3 ahora TAMBIEN al elegir a Amy
 *            (antes solo Sage; el hint viejo "bind c sm_amymodo" fuera).
 *          - sm_amymodo/sm_amymode (Amy.inc) siguen como alias directos
 *            de la misma funcion: los binds viejos de los jugadores no
 *            se rompen. Archivos que cambian: Amy.inc (v90) + este .sp
 *            (+ .smx recompilado). Sage.inc/Cream.inc/nut INTACTOS.
 *
 *  v3.60 - AMY v89 "AURA PRIVADA" + SAGE v1 + CREAM v6 (ronda 26, "LA
 *          CLASE SAGE"): pedido del owner: "1 que todo el radio de
 *          deteccion de objetos reducira a 700. 2 Esto solo la puede
 *          notar amy (o sage ya que en si crearemos ahora la clase
 *          sage)... Sage es una clase exclusiva de ADM... extender
 *          las habilidades de 2 a 4 movimientos (ojo aun todos usaran
 *          sus movimientos 2 pero sage por el momento tendra 3".
 *          - SAGE (11o personaje, SOLO ADMINS — gate del menu con
 *            CheckCommandAccess "sj_sage"): marco de 4 slots, hoy 3.
 *            Z/X = el set activo; C (sm_sjs_ability3 / sm_sageset) =
 *            CAMBIO DE SET. Sets: AMY (default: Z = GOLPE EN AREA SIN
 *            impulso, X = CARTAS DEL TAROT) y CREAM-soporte (Z = CURA,
 *            X = REVIVIR con CD de 30s + regeneracion pasiva). El slot
 *            4 (sm_sjs_ability4) queda registrado/reservado para su
 *            "modo propio" futuro.
 *          - AMY v89: el aura VERDE/ROJO pasa a CLONES invisibles
 *            parentados al objeto (filtro SDKHook_SetTransmit): SOLO
 *            Amy y Sage las ven — "Esto solo la puede notar amy (o
 *            sage)". El objeto real queda virgen (nada que restaurar).
 *            RADIO 1000 -> 700. El escaner vive con una Amy O Sage.
 *          - CREAM v6 "el apartado de soporte": regeneracion +1HP/2s,
 *            cura SIN interrupcion por dano y MOVIL (sin slow 0.3 ni
 *            requisito de suelo), resurreccion con CD en vez de
 *            1-uso-por-ronda (120s Cream / 30s Sage del set prestado).
 *          - VSCRIPT "Lanzamiento de martillo" v4: acepta
 *            ::SonicSageIdx ademas de ::SonicAmyIdx (Sage lanza melees:
 *            "debes anadir a sage" a la deteccion de quien las lanza).
 *          - sm_sjsver reporta "Amy v89 | Sage v1". Archivos que
 *            cambian vs v3.59: Amy.inc + Cream.inc + Sage.inc (NUEVO)
 *            + este .sp + director_base_addon.nut (+ .smx recompilado).
 *  v3.59 - AMY v88 "AURA LUMINOSA (glow de objetivos)":
 *          - Aclaracion del owner: "No me referia a que la textura
 *            tubiera que cambiar de color. Me refiero a que sea rodeada
 *            por Un aura luminosa... (asi como cuando vez un objetivo que
 *            se ve de color azul? o los companeros en campanas no
 *            realistas? asi mismo)". El tinte de RENDER (m_clrRender) de
 *            v86/v87 se RETIRA: la textura JAMAS se toca. En su lugar, el
 *            GLOW del MOTOR de L4D2 — el MISMO sistema del outline AZUL
 *            de los objetivos y de los compis en campañas no realistas:
 *            m_iGlowType=3 (solido) + m_glowColorOverride (VERDE puro =
 *            inyectable / ROJO puro = empujable) + m_nGlowRange (= radio
 *            de vision, 1000). El aura se dibuja ALREDEDOR del modelo y
 *            ATRAVIESA paredes dentro del rango.
 *          - El glow ORIGINAL (type/color/range/rangeMin/team) se guarda
 *            y se restaura EXACTO (salir del radio, morir, cerrar ronda).
 *            Entidades con glow PROPIO del mapa (objetivos, items) NO se
 *            tocan. m_iGlowType se resuelve por send table o datamap
 *            (segun la rama del engine): sin glow en el mod, vision
 *            inerte sin romper nada. Todo lo demas de v87 igual:
 *            automatica, radio 1000, slots 128.
 *          - sm_sjsver reporta "Amy v88". Archivos que cambian vs
 *            v3.58: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.58 - AMY v87 "OJOS AUTOMATICOS (vision 1000)":
 *          - Pedido del owner: "no puedes colocarla que sea
 *            automaticamente? xq todo debe ser de activacion? lo que
 *            este a un rango de 1000 de amy se vera. y punto listo".
 *            La vision VERDE/ROJO de la v86 se vuelve 100% AUTOMATICA:
 *            comandos sm_amyvision / sm_amyojos y flag por-jugador de
 *            "ojos cerrados" RETIRADOS — nada que activar, bind o
 *            recordar. Mientras una Amy viva exista, el escaner esta
 *            encendido: VERDE = inyectable (sm_amyfisica), ROJO =
 *            empujable (con V: martillo/embestida) y el tinte entra/sale
 *            solo con la distancia.
 *          - RADIO por defecto 700 -> 1000 (convar amy_vision_radius):
 *            "lo que este a un rango de 1000 de Amy se vera". Slots del
 *            registro 96 -> 128 (mas props a la vez en 1000 unidades;
 *            registro lleno = degradacion silenciosa, nunca error).
 *            amy_vision (default 1) queda como master switch de ADMIN.
 *            El nucleo del tinte v86 (offsets byte a byte, restauro
 *            EXACTO, RENDER_NONE intocable) queda INTACTO.
 *          - sm_sjsver reporta "Amy v87". Archivos que cambian vs
 *            v3.57: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.57 - AMY v86 "OJOS DE AMY (vision de objetos)":
 *          - Pedido del owner: "Amy podra ver que objetos son
 *            inyectables (apareceran resaltados en color verde) y
 *            estaran en color rojo los que pueden ser empujados (con
 *            V)". La vision tiñe el COLOR DE RENDER de los objetos del
 *            mapa dentro del radio de Amy: VERDE = decorativo al que
 *            sm_amyfisica le puede INYECTAR fisica (vehiculo,
 *            montacargas, dumpster); ROJO = objeto con V (VPHYSICS)
 *            que el martillo/la embestida EMPUJAN (piedra del tank
 *            incluida). El tinte lo ve todo el equipo (informacion
 *            util) y se alimenta del ciclo: verde -> sm_amyfisica ->
 *            nace con V -> rojo -> martillazo.
 *          - El color ORIGINAL se guarda byte a byte y se restaura
 *            EXACTO (salir del radio, morir el objeto, cerrar la
 *            ronda). Registro estatico de 96 slots + UN timer
 *            NO_MAPCHANGE (0.6s) que se apaga solo cuando ninguna Amy
 *            mira. Toggle bindeable: sm_amyvision (pista 1 vez al
 *            spawn). Convars: amy_vision (1) y amy_vision_radius
 *            (700). Cero interaccion con el nucleo v73-v85.
 *          - sm_sjsver reporta "Amy v86". Archivos que cambian vs
 *            v3.56: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.56 - AMY v85 "EL EMPUJE COMPLETO (revertida la reduccion)":
 *          - El owner reexplico el pedido de la ronda 21 ("reverti
 *            todo: lo unico que dije es (1) que no tenga empujones
 *            adicionales, o sea 0, SOLO EL EMPUJE PRINCIPAL, y (2) que
 *            el empuje de autos y cosas sea COMPATIBLE con el
 *            deslizamiento, la habilidad alternativa"). La reduccion
 *            v84 se revierte COMPLETA: el objeto que la EMBESTIDA
 *            golpea sale otra vez con la MISMA receta del martillo —
 *            fuerza completa amy_proplaunch_force (el convar
 *            amy_propdash_scale queda RETIRADO), despertador nativo
 *            radio 130-300, metralla de comunes radio 80 y volteo
 *            lleno. Ningun radio/area de ninguna habilidad se toco.
 *          - Lo UNICO que queda (el pedido de verdad): el objeto
 *            EMPUJADO por la embestida recibe 0 re-impulsos — un solo
 *            empuje, sin empujones adicionales (el martillo Z conserva
 *            su unico rebote de la R20). Mira v83, custodia v83 y
 *            regla del tank intactas.
 *          - sm_sjsver reporta "Amy v85". Archivos que cambian vs
 *            v3.55: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.55 - AMY v84 "EL EMPUJON CORTO (embestida)":
 *          - Pedido del owner tras confirmar el rebote unico (v83):
 *            "el impulso (la habilidad que lanza a Amy hacia adelante)
 *            puede empujar ahora, pero en un rango MAS REDUCIDO (no
 *            tendra la misma hitbox de impacto)". El objeto que la
 *            EMBESTIDA golpea de frente ya NO sale con la receta
 *            COMPLETA del martillo: es un EMPUJON de rango corto —
 *            fuerza al 45% de amy_proplaunch_force (nuevo convar
 *            amy_propdash_scale, 0.05..1.0), despertador con radio
 *            APRETADO (70 en vez de hasta 300: solo el embestido +
 *            vecinos inmediatos), 0 re-impulsos de insistencia,
 *            metralla de comunes radio 45 (vs 80) y volteo a la mitad.
 *          - El MARTILLO Z queda INTACTO (receta completa al 100%, un
 *            rebote, mira v83). El nucleo de fiabilidad de la embestida
 *            NO se toca (golpe real + magnitud escalada por masa: el
 *            objeto embestido SI despierta y SI sale). Proteccion y
 *            custodia v83 cubren tambien el objeto EMPUJADO (no lastima
 *            survivors/Amy; si el TANK lo golpea, vuelve a lastimar).
 *          - sm_sjsver reporta "Amy v84". Archivos que cambian vs
 *            v3.54: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.54 - AMY v83 "LA MIRA MANDA (rebote unico)":
 *          - Tres pedidos del owner tras probar v82:
 *          1) FIX "el auto aun me lastima a MI durante los rebotes":
 *             DOS hoyos cerrados: (a) el tracker soltaba el objeto a
 *             los 4s o cuando la velocidad HORIZONTAL bajaba de 60
 *             (rebote vertical = spd 0 = sin proteccion en pleno
 *             rebote); (b) la red B volteaba el lanzador a TANK por
 *             un m_hPhysicsAttacker VIEJO (punetazo anterior al
 *             lanzamiento = proteccion desarmada). Ahora: CUSTODIA
 *             de 8s tras el vuelo (proteccion + atribucion vivas
 *             hasta el final de TODOS los rebotes) + velocidad 3D +
 *             red B con FRESCURA (el golpe del tank solo cuenta si
 *             es POSTERIOR al lanzamiento de Amy).
 *          2) UN SOLO REBOTE: re-impulsos 5 -> 1 (el auto ya no
 *             "rebota tantas veces").
 *          3) LA MIRA MANDA (como el tank en VS): el objeto sale
 *             hacia donde APUNTA Amy — DIRECCION y ALTURA de la mira
 *             (arriba = arco alto; recto = raso con pisito de arco
 *             150; abajo = rasante). El dano del auto lo produce el
 *             MOTOR por aplastamiento (confirmado por el owner); el
 *             filtro lo intercepta en la victima.
 *          - sm_sjsver reporta "Amy v83". Archivos que cambian vs
 *            v3.53: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.53 - AMY v82 "EL MAPA MANDA (fisica manual + props amigos)":
 *          - Peticion del owner (3 reglas) tras descubrir que el
 *            bus que hace de ESCALERA en The Parish "simplemente
 *            desaparecia" al convertirse automaticamente:
 *          1) FUERA LA CONVERSION AUTOMATICA: el martillo/la
 *             embestida SOLO mueven objetos con V (VPHYSICS)
 *             incorporado de fabrica. Todo lo demas queda COMO
 *             ANTES, exacto como lo puso el mapa. La fisica se
 *             inyecta A MANO con sm_amyfisica [masa] (v81).
 *          2) PROPS AMIGOS: los objetos que LANZA Amy no lastiman
 *             a los survivors NI a ella misma. Protege SOLO el
 *             golpe de Amy: si el TANK golpea el objeto (aunque
 *             Amy le haya pegado antes), el dano a survivors
 *             VUELVE (atribucion por 3 redes: dano recibido por el
 *             prop, m_hPhysicsAttacker y atacante de la victima).
 *          3) METRALLA DE COMUNES: los objetos lanzados por Amy
 *             barren la horda a su paso (oneshot 500, cooldown
 *             0.5s por comun, empujon incluido) — el motor no les
 *             aplica dano de aplastamiento a los comunes.
 *          - sm_sjsver reporta "Amy v82". Archivos que cambian vs
 *            v3.52: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.52 - AMY v81 "LA FISICA A MANO (EL INYECTOR)":
 *          - Peticion del owner: "habra alguna posibilidad de darle
 *            fisica a objetos que no tienen fisicas?" (ej: el bus
 *            prop_dynamic bus01_2 "SIN FISICA").
 *          - NUEVO COMANDO sm_amyfisica (alias sm_amyfis): mira el
 *            decorativo y escribe el comando -> nace un cuerpo
 *            fisico NUEVO (prop_physics_override, ACEPTA modelos
 *            sin datos de fisica propios) en el mismo sitio, mismo
 *            modelo/angulo/skin, despierto de fabrica. Masa
 *            opcional en kg: sm_amyfisica 50 (vuela) / 800 (pesado);
 *            defecto 100 = peso hittable.
 *          - Por que el bus no se convertia solo: el auto-convertidor
 *            v79 es CAUTELOSO (solo vehiculos sin nombre/padre: la
 *            logica del mapa intacta). El manual es decision del
 *            owner: AVISA si el prop tenia nombre o padre (no
 *            bloquea).
 *          - sm_amypropinfo ahora lo ensena: el veredicto
 *            "decorativo con logica de mapa" dice la salida manual.
 *          - El nucleo de conversion es COMPARTIDO
 *            (Amy_ConvertToPhysics): via automatica intacta (v79),
 *            via manual con override.
 *          - sm_sjsver reporta "Amy v81". Archivos que cambian vs
 *            v3.51: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.51 - AMY v80 "EL MURO FANTASMA" (los autos responden SIN
 *          necesidad del tank):
 *          - Evidencia decisiva del owner (c5m5, el puente): el
 *            auto (prop_physics cara_84sedan) sale "EN RADIO pero
 *            muro de por medio" y la Z no lo mueve... PERO en
 *            cuanto el TANK le da el primer golpe, desde ahi la Z
 *            SI lo mueve siempre. Conclusion: el muro NO existe —
 *            el rayo anti-muro chocaba contra algo que no es pared
 *            (auto vecino apiñado en fila, borda, rasante) o
 *            apuntaba demasiado bajo (origen+40 = altura del capo).
 *            El golpe del tank desplaza el auto a terreno limpio
 *            y ahi el rayo por fin llega.
 *          - FIX 1 (FILTRO v80 — UN PROP NO ES UN MURO): el rayo
 *            LOS atraviesa CUALQUIER prop_* (salvo puertas),
 *            func_physbox y cuerpos VPHYSICS. Solo el mundo y los
 *            solidos de verdad descartan. (v77 ignoro al objetivo;
 *            v80 ignora TAMBIEN a los vecinos apiñados en filas.)
 *          - FIX 2 (MUESTREO A 2 ALTURAS): el rayo va al punto de
 *            siempre (origen+40) Y a la parte alta (origen+72: el
 *            techo del auto asoma sobre capos y bordas). Si
 *            cualquiera de los 2 llega, el golpe entra.
 *          - DIAGNOSTICO NUEVO: si aun falla, el log nombra al
 *            culpable: "[PROPS v80] prop N RECHAZADO: bloquea
 *            ent=X cls=Y" (o "bloquea el MUNDO"). Se acabo adivinar.
 *          - sm_amypropinfo: masa unificada con el mensaje del
 *            martillo (L4D2 reporta m_iMass=0 en muchos hittables:
 *            ambos muestran el fallback 100 — se acabo el "0 antes
 *            / 100 despues").
 *          - sm_sjsver reporta "Amy v80". Archivos que cambian vs
 *            v3.50: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.50 - AMY v79 "TODOS LOS AUTOS (LA CONVERSION)" (los autos
 *          decorativos ahora vuelan):
 *          - Reporte del owner tras R15: "puedo mover las montacargas
 *            de dark carnival, las bolsas, los cauchos, muchos props,
 *            menos los autos todavia".
 *          - CONCLUSION: la cadena fisica R11-R15 FUNCIONA (todo lo
 *            que es prop_physics vuela: montacargas, bolsas, cauchos).
 *            Los autos que no se mueven son otra cosa: MUCHOS autos
 *            de mapa NO son prop_physics — son DECORACION prop_dynamic
 *            (sin cuerpo fisico: jamas se moverian por si solos).
 *          - FIX 1 (LA CONVERSION): el auto "pintado" (prop_dynamic
 *            de vehiculo, sin padre/targetname) se RE-SPAWNEA al
 *            instante como prop_physics (mismo modelo/posicion/
 *            angulo/skin; cuerpo NUEVO = DESPIERTO de fabrica: el
 *            teleport SI aplica) y sale lanzado por el camino normal.
 *          - FIX 2 (ESCANEO AGNOSTICO 4c + embestida): el martillo ve
 *            CUALQUIER "prop_*" con movetype VPHYSICS (classname raro
 *            ya no invisible) + los decorativos convertibles.
 *          - FIX 3 (DESPERTADOR POR MASA): env_physexplosion magnitude
 *            = base x (masa/100), nunca menor que la base, tope 25000:
 *            un auto de 1500 kg recibe el mismo empujon real que un
 *            bolso de 20 (antes: 300 fijo para ambos = el auto ni se
 *            enteraba). Radio crece con la masa (tope 300).
 *          - NUEVO sm_amypropinfo: apunta a cualquier objeto y dice
 *            QUE es (clase/modelo/movetype/masa + veredicto: fisica
 *            real / decorativo convertible / geometria del mapa).
 *          - sm_sjsver ahora reporta "Amy v79". Unicos archivos que
 *            cambian vs v3.49: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.49 - AMY v78 "LA EMBESTIDA DEL CHARGER" (fix del modo por
 *          DEFECTO + diagnostico visible):
 *          - Reporte del owner tras R14: "el ataque no despierta ni
 *            mueve los autos (no sale tampoco el mensaje que intentara
 *            mover el prop)".
 *          - CAUSA RAIZ (la que explicaba el reporte COMPLETO): el modo
 *            por DEFECTO de Amy es IMPULSO/EMBESTIDA (g_iAmyAbilityMode
 *            = 0) y TODO el codigo de props vivia SOLO en el modo
 *            martillo/AOE (sm_amymodo aoe). Probando con el defecto, el
 *            press embiste... y la deteccion de pared de la embestida
 *            (Amy_ImpulseWallAhead) consideraba "pared" CUALQUIER
 *            entidad solida (hitEnt > 0): la embestida MORIA contra el
 *            auto SIN tocarlo. Cero launch, cero mensaje, cero dano al
 *            auto. (El fix v77 del escaneo AOE era real pero el owner
 *            estaba probando el MODO que no tenia codigo de props.)
 *          - FIX (la receta del charger del owner, l4d2_charger_power):
 *            Amy_ImpulseWallAhead ahora devuelve QUE hay delante
 *            (-1 sigue / 0 muro / >0 entidad). Un prop con fisica
 *            delante YA NO ES PARED: se REVENTA con la receta completa
 *            del martillo (despertador nativo env_physexplosion + golpe
 *            real + aventon + volteo + monitor) y la embestida
 *            ATRAVIESA. Puertas, props sin fisica y muros siguen
 *            frenando. 1 golpe por objeto por embestida (registro del
 *            impulso). func_physbox anadido a las clases lanzables.
 *          - DIAGNOSTICO VISIBLE (amy_propdebug, 1 por defecto): pista
 *            de modo 1 vez por sesion al embestir ("autos delante salen
 *            REVENTADOS; golpe 360: sm_amymodo aoe") + en el primer
 *            tick del AOE, si el escaneo no ve nada:
 *            "[MARTILLO] 0 objetos con fisica en radio 220". Adios a
 *            adivinar que vio el escaneo. Silencio: sm_cvar
 *            amy_propdebug 0.
 *          - sm_sjsver ahora reporta "Amy v78". Unicos archivos que
 *            cambian vs v3.48: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.48 - AMY v77 "EL MURO INVISIBLE" (fix del escaneo de props):
 *          - Reporte del owner tras R13: "el ataque no despierta ni
 *            mueve los autos (no sale tampoco el mensaje que intentara
 *            mover el prop)".
 *          - CAUSA RAIZ DEFINITIVA (presente desde v73): el chequeo
 *            anti-muro del barrido del martillo (Amy_HasLineOfSight)
 *            usa un filtro de trace donde TODO prop es solido. El
 *            rayo va de los ojos de Amy al origen DEL PROPIO AUTO:
 *            el auto se BLOQUEA A SI MISMO -> "sin linea de vision"
 *            -> continue -> descartado en el ESCANEO, ANTES de
 *            cualquier launch. Por eso no despertaba, no se movia y
 *            NO SALIA el mensaje: Amy_LaunchMapProp (con todo el fix
 *            fisico R11-R13: inputs + golpe real + env_physexplosion)
 *            nunca llego a correr para el objetivo. La piedra del
 *            tank (4a) sufre el mismo auto-bloqueo: la redireccion
 *            jamas disparo.
 *          - FIX (Amy.inc v77): filtro nuevo Amy_TraceFilter_PropLOS
 *            + helper Amy_HasLineOfSightToProp — el rayo ATRAVIESA al
 *            objetivo mismo (y a las piedras del tank en vuelo);
 *            muros, puertas y OTROS props siguen bloqueando (= solo
 *            una pared REAL descarta). Secciones 4a (piedra) y 4b
 *            (props) del barrido migradas + log de "en radio pero
 *            muro de por medio".
 *          - El ataque SIEMPRE estuvo diseñado para los props
 *            golpeables (v73): ahora el camino hasta ellos existe de
 *            verdad. Toda la fisica R13 queda INTACTA.
 *          - sm_sjsver ahora reporta "Amy v77". Unicos archivos que
 *            cambian vs v3.47: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.47 - AMY v76 "EL DESPERTADOR NATIVO" (env_physexplosion, la
 *          receta del plugin de autos explosivos del propio server):
 *          - Reporte del owner tras R12: "no esta funcionando... el
 *            comando no esta haciendo nada de nada".
 *          - Auditoria completa del R12: .smx del paquete verificado
 *            byte a byte (identico al build, 0 errores de compilacion,
 *            baseline de 25 warnings intacto, CERO natives nuevos)
 *            — no quedo nada roto. Dos causas reales encontradas:
 *            (1) TECNICA: el "golpe real" de v75 confiaba en la fuerza
 *            del dano, pero la doc oficial de SDKHooks advierte "Force
 *            application is dependent on game and damage type(s)":
 *            el motor L4D2 puede IGNORAR la fuerza de un DMG_CLUB ->
 *            el auto dormido seguia dormido -> "no hace nada".
 *            (2) DE PROCESO: el changelog R12 decia "cambiar de mapa o
 *            reiniciar el servidor" — PERO CAMBIAR DE MAPA NO RECARGA
 *            EL .SMX: el plugin vive en memoria mientras el server
 *            corra. Solo "sm plugins reload Sonic_ability_manager" o
 *            reinicio completo cargan el binario nuevo. Es posible que
 *            el R12 nunca llego a correr en el server del owner.
 *          - FIX DEFINITIVO (Amy.inc v76): Amy_PropBlastWake —
 *            env_physexplosion sobre el objeto golpeado (EXACTAMENTE la
 *            receta del l4d_explosive_cars que corre en este server:
 *            magnitude 300, probada en vivo): el motor aplica la fuerza
 *            de explosion DIRECTO al cuerpo vphysics dormido y lo
 *            DESPIERTA. Centro detras-abajo del objeto: empuje radial
 *            hacia adelante+arriba ("levantarlo y aventarlo").
 *            Convar amy_propwake_blast (300.0; 0 = desactivado).
 *          - Feedback visible: golpear un prop escribe en chat
 *            "[MARTILLO] <clase>: despertador nativo (masa X) + lanzado"
 *            (solo el primer prop del tick: cero spam).
 *          - NUEVO COMANDO sm_sjsver: sonda de version — imprime el
 *            build cargado EN MEMORIA (manager + Amy). Para verificar
 *            una actualizacion en 2 segundos (ver INSTALACION).
 *          - El re-impulso del monitor repite la receta completa
 *            (despertador + teleport de la meta). El dano canonico de
 *            la alarma se mantiene. La EMBESTIDA queda INTACTA.
 *            Unicos archivos que cambian vs v3.46: Amy.inc + este .sp
 *            (+ .smx recompilado).
 *  v3.46 - *  v3.46 - AMY v75 "EL GOLPE REAL" (DANO CON FUERZA = RECETA DEL
 *          TANK):
 *          - Reporte del owner tras R11: "no, aun sigue sin despertar
 *            a los autos: literalmente si el tank no lo golpea el
 *            objeto no despierta en si". Referencia del owner:
 *            l4d2_charger_power.sp (DJ_WEST): el charger mueve coches
 *            con TeleportEntity 500 PERO SOLO tras embestirlos
 *            FISICAMENTE (el contacto fisico es el evento que
 *            despierta al cuerpo vphysics).
 *          - Conclusion tecnica: EnableMotion/EnablePhysics/Wake solo
 *            tocan banderas del ENT; la velocidad del TeleportEntity
 *            vive en m_vecVelocity y el cuerpo vphysics dormido la
 *            IGNORA. El UNICO camino que empuja el cuerpo fisico de
 *            verdad es el DANO CON FUERZA (lo que hace el punetazo del
 *            tank): el motor la aplica al objeto vphysics
 *            (ApplyForceOffset) y eso DESPIERTA al dormido.
 *          - Amy_PropRealHit: SDKHooks_TakeDamage al prop con fuerza
 *            ESCALADA POR MASA (amy_propwake_force 200 u/s de empujon
 *            real para CUALQUIER objeto, auto o barril) + dano
 *            amy_propwake_dmg (10; 0 = golpe desactivado). Orden del
 *            lanzamiento: GOLPE REAL (despierta) -> TeleportEntity
 *            (aventon arcade 700 + arco 400 + volteo).
 *          - Monitor: re-impulso dispara por velocidad O por
 *            DESPLAZAMIENTO REAL (m_vecVelocity puede mentir en un
 *            cuerpo dormido) y repite el golpe real completo hasta 5
 *            veces (0.5s de insistencia "tank").
 *          - BUG LATENTE R11 corregido: el volteo del re-impulso v74
 *            escribia "m_angAngularVelocity" (propiedad inexistente;
 *            la valida es "m_angVelocity") = error de runtime si
 *            disparaba. Corregido.
 *          - Canon L4D2: golpear un auto con alarma la ACTIVA (igual
 *            que el punetazo del tank). La EMBESTIDA (modo 0) queda
 *            INTACTA (fisica R8/R9). Requiere: Amy.inc v75 (incluido).
 *            Unicos archivos que cambian vs v3.45: Amy.inc + este .sp
 *            (+ .smx recompilado).
 *  v3.45 - AMY v74 "DESPERTAR DEL MOTOR" (FIX DEL AUTO ESTACIONADO):
 *          - Reporte del owner (hallazgo en vivo): "cuando el auto
 *            esta en el aire el impacto es repelido osea lanzado a otra
 *            parte pero si trato de mover el auto como tal no pasa
 *            nada... el objeto debe estar en el aire para que se mueva
 *            o la friccion del motor no lo deja moverse".
 *          - Causa raiz: un prop quieto (Auto estacionado) tiene su
 *            cuerpo fisico DORMIDO (vphysics sleep) y el motor
 *            DESCARTA la velocidad del TeleportEntity sobre un cuerpo
 *            dormido. El punetazo del tank funciona porque su dano
 *            DESPIERTA la fisica y LEVANTA el objeto antes de
 *            aventarlo (por eso el auto volcado o en el aire SI
 *            reaccionaba al martillo).
 *          - Fix de 3 capas en Amy.inc: (1) input WAKE (+ EnableMotion
 *            + EnablePhysics) antes de teleportar la velocidad en
 *            Amy_LaunchMapProp — "Wake" era EL input que faltaba;
 *            (2) la velocidad objetivo queda guardada por slot en el
 *            tracker (g_vecAmyPropVel); (3) el monitor de 10 Hz
 *            re-despierta y re-aplica el impulso hasta 5 veces (0.5s)
 *            si el objeto no alcanzo el 60% de la meta (friccion del
 *            suelo / re-sueno): "levantarlo del suelo y luego
 *            aventarlo", igual que el tank.
 *          - La piedra del tank NO se re-impulsa (proyectil siempre
 *            despierto). La EMBESTIDA (modo 0) queda INTACTA (fisica
 *            R8/R9). Tunables: AMY_PROP_REBOOSTS (5) y
 *            AMY_PROP_REBOOST_RATIO (0.6) en Amy.inc. Requiere:
 *            Amy.inc v74 (incluido). Unicos archivos que cambian vs
 *            v3.44: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.44 - AMY v73 "MARTILLO PESADO" (LANZA + REDIRIGE):
 *          - Peticion del owner: "Mejora para las habilidades de amy
 *            ahora los golpes de martillo Ahora puede lanzar Auto y
 *            objetos del mapa (como el tank) y redirigir eso en caso
 *            si es que el tank los lanza)."
 *          - El GOLPE AOE del martillo (modo 1 de la tecla Z, "GOLPE
 *            PIKO PIKO") gana su seccion 4 del barrido 360: props con
 *            fisica (prop_physics, _multiplayer, _override,
 *            prop_car_alarm) y la PIEDRA del tank (tank_rock) entran
 *            al golpe con LOS real MASK_SHOT + registro por golpe
 *            (nada se lanza dos veces ni a traves de paredes).
 *          - OBJETO QUIETO = LANZADO "como el tank": EnableMotion +
 *            700 u/s (amy_proplaunch_force) + arco 400 + volteo
 *            (m_angVelocity). El Auto sale volando con arco de
 *            punetazo de Tank.
 *          - PIEDRA DEL TANK / OBJETO ENTRANTE (>250 u/s viniendo
 *            hacia Amy: punetazo de tank a un coche) = REDIRIGIDO al
 *            tank vivo mas cercano a 1100 u/s (amy_propredirect_speed;
 *            sin tank vivo: a la mirada de Amy). La piedra pasa a ser
 *            de Amy (m_hThrower / m_hOwnerEntity): devolucion.
 *          - DANO DEL OBJETO VOLADOR (4s de seguimiento): comunes 500;
 *            especiales/witch amy_prophit_dmg (150); tank = x2
 *            escalado por el Verdugo (hasta x4 = 1200); la piedra
 *            DEVUELTA hace amy_rockhit_dmg (500) x Verdugo (hasta
 *            2000). El dano SIEMPRE desde el monitor de timer (fuera
 *            de todo hook del motor, receta v70): el toque solo anota.
 *            Cero friendly fire.
 *          - Anti-crash canonico: EntRefs en arrays estaticos (cero
 *            handles), UN timer global NO_MAPCHANGE, validacion de ref
 *            en cada uso, slots reciclables, reset total en
 *            OnPluginStart/OnMapStart/OnMapEnd, sonidos/particulas
 *            SOLO de la lista precacheada (cero assets nuevos).
 *          - La EMBESTIDA (modo 0) queda INTACTA (su HitWall sigue
 *            frenando en coches: esa es su fisica R8/R9). Requiere:
 *            Amy.inc v73 (incluido). Unicos archivos que cambian vs
 *            v3.43: Amy.inc + este .sp (+ .smx recompilado).
 *  v3.43 - METAL v3.6 (OVERDRIVE = DANO + VELOCIDAD REAL) +
 *          SPEED v3.2 (STACK ADITIVO + ADRENALINA):
 *          - Correccion del owner: "no era al max over, era a la 1
 *            habilidad, la embestida!!! el MAX SOLO SERVIA COMO DANO
 *            Y VELOCIDAD EN SI: DEBERIA AUMENTAR LA VELOCIDAD (pero
 *            no debe hacer conflicto con speed: si se usa uno y otro
 *            la velocidad SUMA; tambien haz que la velocidad sume la
 *            del chute de adrenalina)".
 *          - EMBESTIDA (hab. 1): conserva INTACTO su modo aereo
 *            FLYGRAVITY de v3.5 (impulso unico 1500/1000, momentum,
 *            step-assist, DEBRIS, HitWall Amy v62): el "air con
 *            gravedad" era para ELLA, no para el Overdrive.
 *          - OVERDRIVE (hab. 2): revertido a buff estilo v3.4 (aura
 *            de dano + velocidad) pero con VELOCIDAD REAL +30%
 *            (METAL_OVERDRIVE_SPEED_MULT 1.3, cero lagged / cero
 *            FLYGRAVITY / cero DEBRIS / cero arranque) registrada en
 *            el STACK ADITIVO del Speed_sonic. Fin natural 5s =
 *            sobrecalentamiento canonico (1.5s inmovil).
 *          - SPEED_SONIC v3.2 = AUTORIDAD UNICA de m_flMaxspeed (una
 *            sola escritura por tick que SUMA todas las fuentes):
 *            target = base x (1 + extra_sonic + extras_externos) +
 *            adrenalina. API publica Speed_StackSet (SLOT 0 = Metal).
 *            !speed x3.5 + Overdrive x1.3 = 836 uu/s SUMADOS (con
 *            chute de adrenalina: +40 = 876 uu/s).
 *          - ADRENALINA: m_bAdrenalineActive (netprop real, el mismo
 *            de la lux library de left4dhooks) -> +40 uu/s sumados
 *            mientras el writer este activo (antes el write por tick
 *            absorbia el bono del motor: el chute "no daba nada").
 *            Snapshot anti doble-cuenta al activar !speed.
 *          - Watchdog 2/3/4 re-escrito para fuente multiple; stack
 *            limpio en death/disconnect/spawn (indices reciclables).
 *          - Unicos archivos que cambian vs v3.42: Metal.inc +
 *            Speed_sonic.inc + este .sp (sonic/Amy/martillo/Super
 *            Tank intactos).
 *  v3.42 - METAL v3.5 (MODO AIRE REAL FLYGRAVITY) + SPEED 3.5:
 *          - Feedback del owner: "el max overdrive no sirve, no
 *            funciona... se me ocurrio: restaura el impulso de
 *            metal a como estaba pero aqui esta el truco: en vez
 *            de dejarlo con una velocidad de suelo y una de aire
 *            usaremos... ese tipo de air, o air con gravedad: si
 *            el movimiento es air la velocidad no es limitada por
 *            el suelo, pudiendo usar el impulso aereo sin jodernos
 *            con tierra y lo del Speed".
 *          - CAUSA del "no funciona": el Overdrive usaba
 *            m_flLaggedMovementValue = 1.3 (escala de tiempo, el
 *            metodo descartado en R7): cliente predice a 1x,
 *            servidor a 1.3x -> rubber-band -> velocidad invisible.
 *          - METODO NUEVO (el "air con gravedad" = MOVETYPE_FLYGRAVITY,
 *            la MISMA receta probada de la embestida de Amy
 *            v63/v66): durante Overdrive y DASH Metal corre en
 *            fisica de vuelo con gravedad: SIN friccion de suelo y
 *            SIN clampeo a m_flMaxspeed (el impulso escrito es el
 *            que integra el motor en tierra y aire) y gravedad
 *            normal. Grupo DEBRIS (atraviesa cuerpos), reafirmacion
 *            del movetype cada tick, tope de seguridad, y
 *            restauracion TOTAL en TODOS los caminos de fin.
 *          - OVERDRIVE v2: arranque 1500 + piso 1000 con
 *            conservacion de momentum, direccion a la mirada,
 *            step-assist de escalones, fin por pared de verdad (sin
 *            sobrecalentamiento) o incap; cero lagged.
 *          - DASH: modo dual v3.4 ELIMINADO: un solo impulso (el
 *            aereo, "como estaba" en v3.3: 1500/1000) en tierra y
 *            aire. Metal_HitWall receta Amy v62: criaturas y rampas
 *            transitables ya no cuentan como pared.
 *          - SPEED_SONIC v3.1: multiplicador 2.5 -> 3.5 (770 uu/s
 *            reales; cvar sm_sonic_speedmult sigue vivo 1.1-8.0).
 *          - Unicos archivos que cambian vs v3.41: Metal.inc +
 *            Speed_sonic.inc + este .sp (sonic/Amy/martillo/Super
 *            Tank intactos).
 *  v3.41 - SPEED_SONIC v3.0 (CAMBIO DE METODO: MAXSPEED REAL):
 *          - Feedback del owner: "cambiemos el metodo, usaremos
 *            maxspeed; aun con 2.5 se siente debil y si salto llego
 *            literalmente a la pared en 0.000001 s". Causa fisica:
 *            m_flLaggedMovementValue ESCALA EL TIEMPO -> el servidor
 *            simula 2.5x pero la prediccion del cliente corre a 1x
 *            (rubber-band: se siente "debil") y el arco del salto se
 *            reproduce en fast-forward (de ahi la "pared en un
 *            instante").
 *          - NUEVO METODO: m_flMaxspeed = velocidad natural x mult
 *            (220 x 2.5 = 550 uu/s), re-aplicado cada tick en
 *            SDKHook_PreThinkPost (despues de la recomputacion de
 *            velocidad del juego, antes del movimiento del tick).
 *            Tiempo a 1x: salto 100% vanilla (misma altura y arco),
 *            gravedad intacta, prediccion perfecta -> suave y
 *            controlable en suelo y aire.
 *          - BONUS robustez: al no tocar el lagged, desaparece el
 *            conflicto con Amy (1.35), Shadow (1.3), Knuckles (0.7),
 *            Metal (windup 0.0) y el Super Tank (tanques).
 *          - Snapshots nuevos (g_fBaseMaxspeed), watchdog re-escrito
 *            (re-aplica maxspeed si el juego lo resetea; NUNCA
 *            normaliza lagged ajeno), higiene en player_spawn.
 *          - DEPRECATED: sm_sonic_gravity y sm_sonic_restore_lagged
 *            (mantenidos por compatibilidad de cfg);
 *            sm_sonic_speedmult ampliado hasta 8.0.
 *          - Unicos archivos que cambian vs v3.40: Speed_sonic.inc +
 *            este .sp (Sonic/Metal/Amy/martillo/SuperTank intactos).
 *  v3.40 - SONIC v5.4 (HOMING ENCADENABLE, referencias del addon
 *          "Jump-Kick Script" de Andy Bungus del Workshop):
 *          - CHAIN WINDOW: tras cada impacto del Homing Attack hay
 *            2.5s para encadenar otro homing SIN cooldown (cono
 *            abierto + vuelo +400); hasta 3 encadenados (4 impactos
 *            por secuencia). CD completo al cerrar la cadena, CD
 *            suave (2s) si la ventana expira sola.
 *          - RE-ADQUISICION EN VUELO: si el objetivo muere a mitad
 *            de vuelo, Sonic re-escanea y se redirige (antes caia
 *            plano con el CD gastado).
 *          - LOS en la adquisicion: ya no se fijan objetivos tras
 *            paredes/puertas (mundo/puertas bloquean; hordas no).
 *          - Reset de m_Local.m_flFallVelocity al lanzar y al
 *            rebotar (tecnica del Jump-Kick: sin dano de caida
 *            fantasma tras el vuelo).
 *          - Referencias investigadas: "(Vscript) Sonic Movement"
 *            (lagged 5.0 + sv_gravity 100: nuestro Speed_sonic ya
 *            es la version segura por-jugador de esa misma tecnica).
 *  v3.39 - METAL v3.4 (embestida en MODO DUAL tierra/aire):
 *          - Metal.inc v3.4: pedido del owner tras confirmar que la
 *            mejora v3.3 funciona: "el empuje de tierra mas poderoso
 *            (2.5 de fuerza) pero al pasar al aire esa velocidad se
 *            detenga y cambie a modo aereo (el impulso aereo) para que
 *            no se vaya de plano volando".
 *          - MODO TIERRA: fuerza continua x2.5 (2500 uu/s renovados
 *            cada frame; la friccion del piso no la mata).
 *          - MODO AEREO: al despegar, la velocidad 2.5x se frena en seco
 *            y se cambia al impulso aereo (1500) con piso de 1000 y
 *            gravedad normal: la fuerza del piso nunca lo lanza volando.
 *          - Aterrizar a mitad del dash reactiva la fuerza 2.5x (no se
 *            pierde fuerza ni en aire ni en tierra).
 *          - Unicos archivos que cambian vs v3.38: Metal.inc + este .sp
 *            (los .nut del martillo v3 y SuperTank v7.5 quedan intactos).
 *  v3.38 - METAL v3.3 (rework de la embestida) + Martillo v3 + SuperTank v7.5:
 *          - Metal.inc v3.3: FIX CRITICO del Destructive Charge: el WINDUP
 *            congela con m_flLaggedMovementValue = 0 y la transicion a DASH
 *            JAMAS lo restauraba -> la simulacion de movimiento corria a
 *            0x durante todo el dash ("el impulso muere en tierra y no se
 *            desactiva"). Ahora se restaura a 1.0 al entrar en DASH y la
 *            embestida es de FUERZA CONTINUA (tecnica de la atraccion del
 *            Super Tank: re-aplicar velocidad cada frame, en tierra igual
 *            que en el aire) + trail de chispas visible.
 *          - Addon "Lanzamiento de martillo" v3: homing ELIMINADO (con
 *            skins ninguna arma se llama "martillo": la deteccion nunca
 *            disparaba). La restriccion ahora es por PERSONAJE: solo Amy
 *            lanza melees (MeleeThrowAmyOnly 1, configurable).
 *          - Super Tank v7.5 (VScript aparte): ataques de Amy mas largos
 *            (Hyperdrive 8s, Reflect 12s, Hydro 14s, Vomit 12s, Campo
 *            3.5s) + variaciones de movimiento (dash de salida, planeo,
 *            blink-dash, onda doble).
 *  v3.37 - AMY v72 (puente VScript del martillo):
 *          - Amy.inc v72 publica ::SonicAmyIdx (indice de entidad de
 *            la Amy viva) en el root de VScript en cada spawn y lo
 *            limpia en muerte/desconect/cambio de personaje.
 *          - Lo usa el addon "Lanzamiento de martillo v3 (Amy Edition)":
 *            solo Amy puede lanzar melees (gate por personaje, skin-proof).
 *          - Requiere: Amy.inc v72 (incluido en este build).
 *  v3.36 - EGGMAN v3.0 (REWORK COMPLETO, pedido del owner):
 *          - ELIMINADO el avion C-130 "Air Support": texturas
 *            rotas, 100% visual (nada util), 1 entidad + TeleportEntity
 *            en PreThink cada frame. El hook PreThink se elimina entero.
 *          - ELIMINADA la penalizacion -10% velocidad permanente:
 *            desventaja neta que ademas pisaba m_flLaggedMovementValue
 *            cada frame (chocaba con Speed_sonic/Sonic Hero/staggers).
 *          - NUEVA PASIVA "EGGMOBILE JET": doble salto real (pulsar
 *            SALTO en el aire), impulso +320 + empuje frontal, cooldown
 *            3s, FX de energia/chispas/anillo + guardas anti-abuso.
 *            ConVars: eggman_jet_enable/force/forward/cd.
 *          - MINAS v2: glow rojo visible parentado + DisableMotion
 *            (plantadas) + UN timer global de deteccion (antes 1 timer
 *            + DataPack POR mina) + ArrayList por bloques + witch ahora
 *            recibe el dano de mina.
 *          - LASER v2: telegrafo de 2s (anillo pulsante + haz vertical
 *            + blips 3D) marcando la zona de impacto antes del disparo.
 *          - FIX manager: GetClientSteamID(steam[64]) vs callers[32]
 *            (error 047 en compiladores 1.11+); Eggman_OnMapEnd()
 *            ahora SI se llama (las listas de minas/fuegos quedaban
 *            con refs del mapa anterior).
 *  v3.35 - v25: Witch_Flight v2.6 - FIX "la witch aterriza y no recibe
 *          el dano ni reacciona": el timer del vuelo se apagaba en el
 *          tick del aterrizaje (rama sin active++) y el FL_FROZEN del
 *          stun nunca se quitaba (witch estatua); + CHOQUE contra
 *          pared/techo con dano de impacto (tocar superficie = dano) +
 *          m_rage forzado al tocar suelo (se levanta ENFADADA y
 *          persigue) + anti-spam de 1 impacto/s. Beneficia a TODOS los
 *          que lanzan witches: Amy (impulso/martillo y AOE), Knuckles
 *          (puno/slam), Tails (laser), Sonic (dash/homing) y Rouge.
 *          Amy.inc SIN cambios (sigue v71); nada mas cambia vs v24.
 *  v3.34 - v24: Amy v71 (tarot 100% funcional: anti-FF inteligente, los
 *          escudos del Poder 2 reaccionan contra infectados especiales;
 *          requiere el addon VScript "Amy-Aligned v7.3" del mismo paquete)
 *  v3.33 AMY v70 "CONTRA DE VÓMITO A PRUEBA DE CRASH" (bug reportado:
 *  "cuando el boomer lanza su vómito pero el contraataque se lo
 *  devuelve, en ocasiones causa crash"): la contra mataba al boomer
 *  (100 ácido) DENTRO del hook L4D_OnVomitedUpon, en medio del propio
 *  spray del boomer; su explosión re-entraba en OnVomitedUpon y mutaba
 *  el estado del juego con el spray en la pila (crash ocasional). FIX:
 *  el hook solo decide (bloquea la bilis), los efectos van diferidos
 *  0.1s en timer userid+NO_MAPCHANGE+DATA_HNDL_CLOSE fuera de todo
 *  hook; solo dispara contra BOOMER VIVO infectado (las jars de bilis
 *  de compañeros ya no lanzan/dañan al aliado: fix de FF); ventana de
 *  1s tras reflejar (la explosión del boomer contrado no ciega a
 *  Amy). Knuckles v70: su contra de vómito, mismo hardening. Nada más
 *  cambia (v69/menú Mastery intactos).
 *
 *  v3.32 AMY v69 "ANTI-VÓMITO ACTIVABLE": la contra de bilis del boomer
 *         pasa al menú Mastery (Doll_System) como poder "Anti-Vómito
 *         (reflejo)": ON por defecto (= mismo comportamiento de siempre,
 *         la cookie vieja lo respeta) y OFF = el vómito le afecta normal.
 *         La contra de lengua del smoker sigue siempre activa. La
 *         preferencia persiste en cookie. Nada más cambia (v68 intacto).
 *
 *  v3.31 AMY v66 "MODO ELEGIBLE: IMPULSO O GOLPE AOE" - el crash del
 *         capitulo 2 era el PRECACHE abortado (fix v3.30), NO el ataque
 *         en area: el martillo vuelve como MODO alternativo elegible:
 *         - sm_amymodo (alias sm_amymode): alterna/fija el estilo de Z
 *           por jugador ("impulso" | "aoe"). Bindeable (bind c sm_amymodo).
 *         - MODO 0 IMPULSO (defecto): la embestida tipo Charger v64,
 *           sin ningun cambio.
 *         - MODO 1 GOLPE AOE: el golpe circular 360 del viejo martillo
 *           (radio 220, 0.5s de barrido, LOS real) restaurado del v12,
 *           con el nucleo v64 (Amy_ImpulseHit): witch flight, Verdugo
 *           del tank, boomer burst, rompe-huesos de pared, desarme,
 *           sonidos + burst rosa. Cooldown compartido
 *           (amy_strike_cooldown) y misma fuerza (amy_strike_force).
 *         - Patrones anti-crash intactos: arrays estaticos, timer
 *           userid + NO_MAPCHANGE, snapshot-then-strike, tope/tick.
 *         - Panel de seleccion: "Impulso / Golpe AOE" + hint del
 *           comando al elegir a Amy.
 *
 *  v3.30 FIX CRITICO - CAUSA RAIZ DEL "CRASH DEL CAPITULO 2":
 *         La excepcion "Invalid timer handle" del KillTimer del watchdog
 *         de Speed_sonic (handle muerto: SM mata solo los timers
 *         NO_MAPCHANGE al cambiar de mapa) abortaba ESTE OnMapStart a
 *         mitad: los 10 personajes se quedaban SIN precache ni reset en
 *         el mapa 2+ y el golpe del impulso de Amy usaba recursos con
 *         indices obsoletos del mapa anterior -> el juego se cerraba al
 *         golpear zombies en el capitulo 2 (evidencia: informes de
 *         09/04/2026 - excepcion a las 15:02:30, cierre a las 15:03:33).
 *         - Speed_sonic v2.4: sin KillTimer en OnMapStart (creacion
 *           incondicional) + nuevo Speed_OnMapEnd que olvida handles.
 *         - BLINDAJE: Speed_OnMapStart pasa a llamarse AL FINAL de este
 *           OnMapStart (ninguna excepcion futura suya puede dejar a los
 *           demas modulos sin inicializar) y Speed_OnMapEnd se cablea
 *           en OnMapEnd.
 *         - Amy v65: precache del burst del golpe restaurado.

 *  FIX: Checkpoint removed, replaced with Sonic Wind.
 *  FIX: Duplicated L4D2 native events removed from Sally, centralized here.
 *  FIX: UTF-8 Warnings purged entirely (No emojis or accents).
 *  NEW: Metal Sonic and Dr. Eggman integrated.
 *  v3.29: AMY v64 "CONTROL TOTAL + JUGO DEL MARTILLO" - a peticion del
 *         usuario tras probar la v15/v63 (el problema de velocidad era
 *         un conflicto de mods del server, resuelto reinstalando SM):
 *         - CONTROL: velocidad 900->700, embestida que SIGUE LA MIRADA,
 *           2a pulsacion de Z frena en seco y seguro de vacio en bordes.
 *         - IMPARABLE total: grupo de colision DEBRIS durante la
 *           embestida (atraviesa cuerpos: la horda no la frena),
 *           radio 130->180, tope 40 comunes/tick y ARIETE (tank y
 *           especiales delante siguen siendo empujados cada tick).
 *         - BOOMER: sin dano al pegarle: sale volando y estalla con
 *           bilis (pop real + frasco de vomito: comunes al charco).
 *         - JUGO del martillo original restaurado: sonidos de impacto,
 *           burst rosa del golpe, rompe-huesos contra pared y desarme.
 *         - CONTRA INSTANTANEA estilo Knuckles: lengua y vomito
 *           SIEMPRE (nunca le afectan); pinza/montura/carga/garra/
 *           empujones: durante la embestida, bloqueados ANTES.
 *  v3.28: AMY v61 "IMPULSO DE IMPACTO" - CAMBIO DEFINITIVO a peticion del
 *         usuario: el Hammer Attack fue RETIRADO y sustituido por una
 *         embestida tipo Charger SIN VFX que mata y empuja todo lo que
 *         este a su paso (sea lo que sea) y es IMPARABLE durante el
 *         impulso (agarres de hunter/smoker/jockey/charger, golpes de
 *         Tank, tropiezos). El crash "al usar la habilidad tras pasar de
 *         capitulo" sobrevivio a v49-v60 (6 fixes de causa-raiz): el
 *         martillo compartia piezas imposibles de auditar (animacion del
 *         arma, VFX del strike, WitchFlight). El impulso NO USA NINGUNA:
 *         la activacion entera es TeleportEntity + timer userid-only +
 *         trazos de rayo + SDKHooks_TakeDamage. Cero VFX, cero sonidos,
 *         cero escrituras al arma, cero WitchFlight en la habilidad 1,
 *         cero handles. Convars nuevas: amy_impulse_speed/duration/
 *         maxdist/radius/push_teammates/dmg_common/dmg_special/dmg_witch/
 *         dmg_tank. Tecla Z (Command_ImpulseCharge), mismo cooldown
 *         (amy_strike_cooldown) y misma fuerza de empuje (amy_strike_force).
 *         Log de diagnostico: logs/amy_impulse_debug.log (sm_amydbg).
 *  v3.27: AMY v60 "HAMMER REBORN" - RECONSTRUCCION TOTAL del martillo a
 *         peticion del usuario (el crash al usar la habilidad tras pasar
 *         de capitulo sobrevivio a v49-v53):
 *         - La activacion YA NO TOCA EL ARMA: eliminadas TODAS las
 *           escrituras al estado interno del arma (m_flNextPrimaryAttack,
 *           m_flTimeWeaponIdle, m_iNextPrimaryAttackIndex, timers
 *           Countdown) y el IN_ATTACK forzado pasa a ser opcional via
 *           convar amy_hammer_anim (0 por defecto = desactivado). El
 *           motor solo recibe IN_ATTACK del jugador si el usuario lo
 *           activa explicitamente (equivale a un clic izquierdo).
 *         - El barrido YA NO USA HANDLES: el timer recibe solo el userid
 *           (int) y el registro de golpeados es un array estatico por
 *           cliente. Cero ArrayList / DataPack / TIMER_DATA_HNDL_CLOSE.
 *         - El golpe YA NO CREA TIMERS PROPIOS: eliminados el monitor de
 *           pared repetitivo y el cleave; el "rompe-huesos contra pared"
 *           se decide con una comprobacion instantanea en el momento del
 *           golpe (un rayo de colision).
 *         - Gameplay conservado: 360 con LOS, witch voladora (WitchFlight
 *           v2.4), dash del Tank, stagger seguro, desarme/vulnerabilidad,
 *           VFX/sonidos identicos. El log de diagnostico sigue activo.
 *  v3.26: FIX DEFINITIVO del "crash del capitulo siguiente" (al usar el
 *         martillo al inicio del capitulo nuevo, sin pegarle a nadie,
 *         el juego se cerraba solo):
 *         - CAUSA RAIZ: desde v48 el golpe del martillo es 360 grados
 *           SIN linea de vision. Los plugins de boss del servidor
 *           (l4d2_boss_spawn: 2 witches por mapa, permitidas desde el
 *           inicio del capitulo, al ~10-30% del flow) colocan witches
 *           DETRAS de la pared del safe room de arranque, a menos de
 *           220 unidades del jugador. El swing las golpeaba SIN QUE EL
 *           USUARIO LAS VIERA ("sin pegarle a nadie") -> la rama witch
 *           -> WitchFlight congelaba su IA (FL_FROZEN+MOVETYPE_NONE) y
 *           la teletransportaba a 900 u/s con tick de 20 Hz en plena
 *           transicion de spawn -> CRASH del motor. v1 no crasheaba
 *           porque su rama witch era un simple empuje MOVETYPE_FLY
 *           (el viejo bug "la witch flota": inocuo). Los crashes
 *           comenzaron con la version que introdujo WitchFlight.
 *         - AMY v53: el swing exige LINEA DE VISION real (MASK_SHOT,
 *           el filtro de las balas) para SI, comunes y witches: nada
 *           se golpea a traves de paredes. Tambien en terremoto y
 *           cleave. ResetMeleeWeaponState escribe los timers del arma
 *           por el SISTEMA DE PROPS (metodo del propio left4dhooks):
 *           eliminados los SetEntDataFloat con offsets crudos.
 *         - WITCH_FLIGHT v2.4: guard de salud en el lanzamiento +
 *           deteccion/restauracion inmediata de entidad incrustada en
 *           geometria durante el vuelo.
 *         - Los logs de diagnostico (amy_hammer_debug.log) siguen
 *           activos: si algo volviera a cerrar el juego, la ultima
 *           linea del log nombra la llamada culpable.
 *  v3.25: BUILD DE DIAGNOSTICO (el crash del martillo en el capitulo
 *         siguiente PERSISTIO tras v3.22/v3.23/v3.24; comparacion
 *         completa contra la v1 original hecha a pedido del usuario:
 *         el camino directo del press es identico o mas seguro, el
 *         crash sobrevivio a 3 causas-raiz distintas):
 *         - AMY v52: logging PASO A PASO de cada nativa del martillo a
 *           logs/amy_hammer_debug.log. La ULTIMA linea antes del cierre
 *           del juego nombra la llamada culpable. Convars de biseccion:
 *           amy_dbg_log/skip_vfx/skip_shake/skip_anim/skip_sound/
 *           skip_loop/safe + comando sm_amydbg (confirma la build
 *           activa y los offsets del arma).
 *         - WITCH_FLIGHT v2.3: eliminado el PrecacheModel "lazy" en pleno
 *           gameplay (vector conocido de inestabilidad del motor): el
 *           sprite del ring se precachea una vez por mapa via
 *           WitchFlight_OnMapStart (cableada AQUI, en OnMapStart).
 *         - Manager: ninguna otra logica cambia.
 *  v3.24: FIX - estado residual entre rondas (reporte: "use la habilidad
 *         de martillo en la siguiente parte de la campana y el left
 *         termino cerrandose solo"). Auditoria cruzada completa de TODO
 *         el estado que sobrevive a un cambio de mapa:
 *         - Event_PlayerSpawn YA LLAMA a Amy_Event_PlayerSpawn: la
 *           funcion existia desde v45 pero NADIE la llamaba (los resets
 *           por spawn y el ciclo de SDKHooks OnTakeDamage/PreThink de
 *           Amy solo se aplicaban con el hot-reload del plugin-load).
 *         - OnMapEnd ahora llama a WitchFlight_OnMapEnd (v2.2): mata el
 *           tick de vuelo y vacia los 4 slots EN el fin de mapa, en vez
 *           de dejar que se autolimpie "al primer tick del mapa nuevo".
 *         - AMY v51: reset TOTAL en round_start (nuevo capitulo = round_end
 *           + cambio de mapa + round_start), filtro anti-FF global fuera,
 *           OnMapEnd sin doble-muerte de timers NO_MAPCHANGE, DataPacks
 *           con TIMER_DATA_HNDL_CLOSE y runner VScript PROPIO (etiquetado
 *           "amy_p2_runner": ya no se secuestra el logic_script del mapa
 *           para ejecutar los poderes del Super Tank).
 *  v3.23: FIX CRITICO - el crash del martillo de Amy PERSISTIA tras v3.22
 *         ("aun al presionar la habilidad del martillo el left se me
 *         cerro otra vez"):
 *         - CAUSA RAIZ REAL: Pin_Release liberaba los agarres escribiendo
 *           -1 A MANO en los enlaces (m_pounceVictim del hunter,
 *           m_jockeyVictim del jockey, m_tongueVictim del smoker,
 *           m_pummelVictim/m_carryVictim del charger). El motor NUNCA
 *           ejecutaba su camino de "fin de agarre": el infectado quedaba
 *           DENTRO de su estado (pounce/ride/drag/pummel) con puntero de
 *           victima NULL -> en su siguiente think, la maquina de estados
 *           desreferenciaba NULL -> CRASH del engine (el juego se cierra
 *           solo). "Ciertas ocasiones" = Amy AGARRADA al pulsar el
 *           martillo (el hard-stop llama PinRelease_Cleanse) o golpeando
 *           al especial que la agarra. El fix del Fling (v3.22) no basto
 *           porque esta era la causa real.
 *         - FIX: PIN_RELEASE v2.0 libera con las funciones del PROPIO
 *           MOTOR (via left4dhooks, feature-check en runtime):
 *           L4D_Hunter_ReleaseVictim, L4D_Smoker_ReleaseVictim,
 *           L4D2_Jockey_EndRide, L4D2_Charger_EndPummel y
 *           L4D2_Charger_EndCarry. Ejecutan el camino completo: desmonta,
 *           corta animaciones, limpia ambos lados, restaura el
 *           movimiento y termina las cues de musica. Fallback: stagger
 *           del atacante (el interrupt vanilla del Tank). JAMAS se
 *           escribe -1 en los enlaces: cero superficie de crash.
 *         - AMY v50: comentarios/changelog de la ruta actualizados.
 *  v3.22: FIX CRITICO - crash del juego al usar el martillo de Amy ("en
 *         ciertas ocasiones el left se cierra solo"):
 *         - CAUSA RAIZ: L4D2_CTerrorPlayer_Fling es un SDKCall crudo a
 *           CTerrorPlayer::Fling del motor con anim 76 + incapTime 3.0
 *           hardcodeados (contexto EXCLUSIVO del golpe de carga del
 *           Charger). El hard-stop del martillo la llamaba sobre Tank
 *           y especiales justo tras tambalearlos con SIStagger en el
 *           MISMO frame (y sobre hunter saltando / jockey montando /
 *           charger cargando): crash documentado del motor (AlliedMods:
 *           "you will probably crash the server"). Solo crasheaba cuando
 *           el golpe CONECTA con Tank/SI (comunes y witch usan otras
 *           rutas) - de ahi el "ciertas ocasiones".
 *         - FIX: eliminadas las 10 llamadas a L4D2_CTerrorPlayer_Fling
 *           en TODO el proyecto (Amy v49: hard-stop y fallback;
 *           Knuckles v61: puno, counter de vomito, counter de tank,
 *           hard-stop del charger; Sonic v5.2: homing, spin dash,
 *           tornado, drop dash). Lanzamiento manual TeleportEntity +
 *           SIStagger_Auto: mismo vuelo y derribe visual, cero riesgo.
 *         - AMY v49 ademas: ResetMeleeWeaponState escribia 4 bytes
 *           PASADO el struct del timer de swing del arma (corrupcion de
 *           memoria en CADA pulsacion -> crashes aleatorios diferidos);
 *           swing/cleave/terremoto ya no matan entidades mientras iteran
 *           la lista del motor (snapshot-then-strike, tope 24/tick);
 *           witch muerta en vuelo se restaura al instante.
 *         - PIN_RELEASE v1.1: early-out si no hay agarre real (antes
 *           hacia 24 SDKCalls L4D_StopMusic + MOVETYPE_WALK en CADA
 *           golpe a un especial, aunque Amy no estuviera agarrada).
 *         - WITCH_FLIGHT v2.1: nueva API WitchFlight_CheckDead.
 *         - SONIC v5.2: ademas del crash, tenia 3 witches con
 *           MOVETYPE_FLY sin restaurar JAMAS (el mismo bug de la witch
 *           flotante que sufria Amy v45) y 4 staggers crudos (bug de
 *           "no se levantan"): todo convertido a WitchFlight/SIStagger.
 *  v3.21: AMY v48 + ROUGE v8.0 + TAILS v4.4 + WITCH FLIGHT v2.0 + PIN_RELEASE:
 *         - WITCH FLIGHT v2.0 (fix del bug "la witch no es levantada del
 *           suelo, sigue activa"): v1.x solo ponia MOVETYPE_NONE, pero la
 *           IA NextBot de la witch corre por su DoThink cada tick y su
 *           locomocion re-escribia la posicion encima de nuestros
 *           teleports. Ahora se congela su IA con FL_FROZEN (el gate del
 *           propio motor: DoThink solo hace Update() si no esta frozen,
 *           equivalente local del nb_stop) + re-afirmacion cada tick.
 *           La witch vuela de verdad y no ataca en el aire.
 *         - NUEVO include Pin_Release.inc (fix del bug "la musica del
 *           agarre sigue sonando tras liberarme de hunter/jockey/smoker"):
 *           las liberaciones por props nunca ejecutaban el camino de
 *           "fin de agarre" del motor, asi que las cues de musica
 *           (Event.Exenteration / Vassalation / Tonguetied /
 *           Asphyxiation / Mortification) le seguian sonando en loop a
 *           la victima. PinRelease_Cleanse corta esas cues con
 *           L4D_StopMusic, limpia AMBOS lados del enlace y aturde al
 *           atacante con stagger seguro. Cableado en Amy (counter Diva),
 *           Sally (cintura + escudo de agua) y Cream (Cheese).
 *         - AMY v48: golpe de martillo CIRCULAR 360 (adelante y atras
 *           del objetivo), textos/paneles reescritos (espanol consistente,
 *           datos reales: el viejo de Momentum decia +5% cuando es +8%).
 *         - ROUGE v8.0: planeo reparado (el cap de caida solo se aplicaba
 *           en el frame de activacion: no planeaba), Evasion Instintiva
 *           (30% de evadir + aturdir al atacante; reemplaza la Treasure
 *           Vision), bombas dañan y lanzan a la witch, comunes con empuje
 *           antes del dano, stagger de area seguro (SIStagger_Auto).
 *         - TAILS v4.4: fix de la pasiva de curacion (tambien via el
 *           forward L4D2_OnStartUseAction_Post: las props de la barra ya
 *           estan garantizadas; la version de heal_begin se saltaba el
 *           boost en silencio si llegaban a 0).
 *         - STAGGERS SEGUROS en TODOS los modulos: Rouge, Sally, Metal y
 *           Cream ya no llaman L4D_StaggerPlayer crudo (quedaban tirados
 *           sin levantarse por el bug del motor con bots).
 *  v3.9:  Metal_OnPlayerDeath hook + Metal v3.0 (canonical Destructive Charge).
 *  v3.10: Rouge_OnPlayerDeath hook + Rouge v7.0 (real acid pool damage).
 *  v3.11: Amy_OnPlayerDeath hook + Amy v43 (melee animation fix + robustness).
 *  v3.12: Cream_OnPlayerDeath hook + Cream v5.0 (Resurrection, 1 use per round).
 *  v3.13: Sally_OnPlayerDeath hook + Sally v5.0 (Fire/Water shield rework).
 *  v3.14: ROBUSTEZ GENERAL - validaciones estrictas, OnPluginEnd, fix de macros,
 *         limpieza de timers en disconnect, logging de errores, proteccion anti-crash.
 *  v3.15: Eggman_OnPlayerSpawn/Death/Disconnect hooks + Eggman v2.0 (Air Support).
 *  v3.16: Speed v2.2 (QoL, sin FOV) + Cream v5.1 (fixes de bugs y logica)
 *         + Metal v3.1 (pasivas Sin-Incap/Explota-al-morir implementadas,
 *         reset defensivo al spawn, detonacion segura diferida).
 *  v3.17: Sonic v5.1 + Tails v4.2 + Rouge v7.2 + Cream v5.2:
 *         - Sonic_Event_PlayerDeath/Spawn cableados (antes eran codigo
 *           muerto: cancelan el Homing al morir/spawnear y restauran
 *           movetype/colision al instante, sin depender del timer de 0.35s).
 *         - Tails_OnClientPutInServer cableado (reset total del slot al
 *           conectar: mata handles colgados del cliente anterior).
 *         - CleanupCharModuleState ahora tambien limpia SONIC y TAILS
 *           (cambiar de personaje con vuelo/laser/homing activo ya no
 *           deja estado residual).
 *         - Rouge v7.2: guard de muerte, flicker/glow residual arreglados,
 *           bat bombs ya no explotan contra el suelo, leak de DataPacks,
 *           warning 203 eliminado.
 *  v3.20: TAILS v4.3 (laser vs witch) + STAGGER SEGURO (Amy v47 +
 *         Knuckles v60):
 *         - Nuevo include SI_Stagger.inc (sistema compartido): fix del
 *           bug "los enemigos con stagger no se levantan del suelo"
 *           (tank, smoker, etc). Es un bug del estado del propio motor
 *           (OnStaggered no se limpia solo en bots infectados). Tras
 *           cada stagger del plugin se programa L4D_CancelStagger a los
 *           1.8s (SI) / 3.0s (Tank): si ya se levanto, es no-op; si se
 *           quedo atascado, se levanta garantizado.
 *         - Tails v4.3: el laser ahora SI empuja a la witch aunque este
 *           enojada y cargando (empuje via Witch_Flight: su IA queda
 *           suspendida mientras el rayo la mantiene → el laser gana a
 *           su locomocion NextBot) y a los 1.5s de rayo continuo le da
 *           el golpe de stagger (unico de 75 DMG_BLAST ≥ 50: dispara
 *           su stumble NATIVO de vanilla + lanzamiento fuerte).
 *         - Witch_Flight v1.1: ring de despegue solo en lanzamientos
 *           nuevos (el laser relanza 10 veces/s: antes 10 rings/s).
 *  v3.19: WITCH FLIGHT (Amy v46 + Knuckles v59):
 *         - Nuevo include Witch_Flight.inc (sistema compartido): la
 *           witch es un NPC NextBot (no CTerrorPlayer) cuya locomocion
 *           anula cualquier empuje externo y sin estado
 *           knockdown/stagger. Para poder levantarla y lanzarla como a
 *           los tanks se suspende su IA (MOVETYPE_NONE), se integra el
 *           vuelo a mano (gravedad, colision solo contra el mundo,
 *           deslizamiento en paredes) y se restauran su movetype y su IA
 *           al aterrizar (dano de impacto) / a los 4s / si muere en vuelo.
 *         - Amy v46: Hammer Strike y terremoto lanzan a la witch con
 *           WitchFlight_Launch (dano despues del lanzamiento).
 *         - Knuckles v59: puno y ground slam lanzan a la witch con
 *           WitchFlight_Launch; los comunes del puno reciben el empuje
 *           ANTES del dano (ragdolls volando, como el martillo de Amy).
 *  v3.18: KNUCKLES v58 + AMY v45 (QoL & Fixes):
 *         - KNUCKLES entra en CleanupCharModuleState: cambiar de personaje
 *           (o desconectar) con Carga/Counter/Agarre de pared/Meteor Smash
 *           activos ya no deja estado residual (MOVETYPE_NONE = congelado
 *           para siempre, tinte azul, LaggedMovement 0.5 o god-mode).
 *         - Knuckles v58: out-of-bounds del Dash corregido (sistema epoch),
 *           leak del DataPack del sweep, fling de witch restaurable, QoL.
 *         - Amy v45: Hammer Strike ya LEVANTA a los comunes (empuje antes
 *           del dano: el ragdoll hereda el impulso), witch sin MOVETYPE_FLY
 *           permanente (restauracion automatica), handles colgados en
 *           disconnect, 9 warnings eliminados, QoL de cooldown visible.
 * ======================================================
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <left4dhooks>
#include <sdktools_trace>
#include <OM_Stun>   // v3.77.24: EL STUN UNIFICADO — OM_Stun v2.0 trae el congelado del rayo de Tails (flags CYAN/PUSH/STAGGER/FIXED/NOIFRAME + OM_Stun_Push; incluye <SI_Stagger> para el stagger al liberar) y sigue siendo la capa de pausa de animacion de TODOS los congelados; sube ANTES de los personajes (el #include que traia sonic.inc queda en no-op por el guard)

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME "SonicJumpSurvivors - Universal"
// v3.77.11 (con sonic.inc v6.18-OM + Amy v100-OM): FIX DE VISIBILIDAD
//   DE LOS TRAILS — reporte del owner: "ni el nativo ni ese parecen
//   ser visibles": el env_spritetrail NO renderiza en L4D2 (el
//   cliente no dibuja esa entidad; invisible con cualquier material
//   y con el parent ya bien puesto en la bola). Migracion al motor TE
//   del Source que este server ya demuestra (BeamFollow del trail de
//   colores del speed / BeamPoints del laser de Tails): motor de
//   slots con latido 0.2s — bola = 3 capas GMod-exactas
//   (blue_2ndlayer 70->40 + blue 40->1 + blue 40->1 magenta), peel =
//   blue2 16->1 sobre el avatar R/L con split dueno/demas + 2
//   Sonicred de pies encadenadas, martillo de Amy al mismo motor.
//   Diseno v6.17 intacto (FileExists -> fallback laserbeam, convars
//   sonicom_trails / sonicom_trails_mat). Historial 3.77.10-: abajo.
// v3.77.27 (con Metal.inc v5.2-OM): AJUSTES 2-10 DEL AVATAR DE METAL —
//   segunda ronda de la revision 8.5/10 (9 puntos en un pedido, tras
//   el ajuste 1 = FX de cura de la 3.77.26):
//   (1) ATASCOS ("metal puede quedarse atascado en ciertos escenarios
//       o lugares debido al tamano del enemigo"): watchdog en DASH y
//       DRAGGING — la embestida va a 750; si no supera 80 uu/s de
//       forma CONTINUA durante 0.6s, la carga se LIBERA limpia (fin
//       natural con frenado suave) en vez de quedarse pegado los 8s.
//   (2) SONIDOS MAS FUERTES: todos los sonidos de habilidad del Metal
//       suben al soundLevel 87 del AdvancedPillSound del lua (el port
//       usaba el default 75 = se oian flojos). Loop, chargeup, ping,
//       elec, slam, punch, bump, end, heal y explosion incluidos.
//   (3) COOLDOWNS -30% (pedido literal): embestida 25 -> 17.5 (cancel
//       12.5 -> 8.75), Overdrive 30 -> 21, Self Repair 24 -> 16.8.
//   (4) OVERDRIVE SIN INMOVILIZAR: fuera el "reactor sobrecalentado"
//       con MOVETYPE_NONE 1.5s al terminar — el buff expira y Metal
//       sigue moviendose.
//   (5) ANIMACIONES + BLINDAJE: (a) SALTO con la ventana del one-shot
//       de Sonic (el jump del metal.mdl ya no se corta "a veces" —
//       vive hasta 0.5s o hasta que el ciclo termine, y el
//       FL_ONGROUND que parpadea rozando escalones ya no lo pisa);
//       (b) WALK al rate 1.0 CONSTANTE del GMod (Metal NO define
//       animrates en su lua — "la animacion de caminar es bastante
//       rapida a comparacion de los demas" porque el v5.0 la jugaba a
//       1.8x escala sonic); (c) durante TODA la embestida Metal NO
//       puede ser aturdido NI agarrado ("stagger de ningun tipo ni
//       agarrado ni nada"): Metal_ControlImmune en los 8 forwards
//       anti-control de ESTE manager (puno del tank, roca, fling,
//       stagger, pounce del hunter, ride del jockey, charger, tongue).
//   (6) SELF REPAIR HEREDADO AL AURA DE SOPORTE ("la reparacion esta
//       heredado a curarse mas rapido si esta con eggman o tails
//       no?"): con un Tails o un Eggman VIVO a 250u (el radio del
//       tails_heal_boost), el tick de reparacion corre x2 de rapido
//       (cada 1s en vez de 2s).
//   (7) EMBESTIDA LIBERA EL CONTROL (bug del jockey: "metal se ha
//       llevado a un jokey de un survivor y aunque se lo llevo este
//       siguio montado aun si no estaba su cuerpo"): el catch ahora
//       STAGGERA al oponente y si tenia a alguien agarrado lo libera
//       POR EL CAMINO DEL MOTOR (PinRelease_Cleanse: L4D2_Jockey_
//       EndRide etc. — desmonta de verdad, corta la musica, sin
//       "montado fantasma"); despues el OM_Stun lo congela quieto.
//   (8) OVERDRIVE LEVITA E INTERACTUA CON LA EMBESTIDA: Espacio
//       mantenido con la C activa = levitar (vel[2] 220); la embestida
//       en el aire ahora escribe la componente horizontal dir*750
//       conservando la Z — C + Espacio + Z = DASH AEREO. Bloqueo
//       mutuo C<->Z retirado.
//   (9) 1 VIDA + AUTO-DESTRUCCION GMod (l.756+): la Sin-Incap ya
//       existia (v3.1); la explosion ahora SI es la del lua: radio
//       230 (antes 500), dano 50 por victima (antes 0), stun 5.5s
//       ("5seg y medio" del owner; GMod usa 7) y RAGDOLL VOLADOR por
//       cada especial (Sonic_SpawnFlingRagdoll v6.11: doble con
//       vphysics + onda; al pasar el stun reaparece donde cayo el
//       doble) + los 3 sonidos del lua (ExplodeSfx + Explosion +
//       MetalBloodSound).
// v3.77.26 (con Metal.inc v5.1-OM): FX DEL SELF REPAIR AL ORIGINAL DEL
//   GMOD — revision del owner de la 3.77.25 (8.5/10), ajuste 1: "el
//   efecto de cura revisaste bn el efecto que usa metal en Gmod? el
//   original". El v5.0 ponia un sprite glow01 verde flotante — el mod
//   NO hace eso. Cada tick de +7 HP reproduce las DOS senales del lua
//   (noodles_om_pills_survivors_metalsonic.lua l.987-988, ventana
//   0.5*0.5 = 0.25s): (1) MetalSonicHeal_highlight -> TINTE VERDE del
//   avatar con el fade EXACTO del UI (l.94-112: 0->1 en 0.125s + 1->0
//   en 0.125s, Color(0,255,0,255*alpha)) animado cada FRAME sobre las
//   copias R/L + DLIGHT VERDE de verdad (l.1583-1596: r=0 g=255 b=0,
//   brightness 3, Size 200) — light_dynamic verde parentada al player
//   (receta Sonic_MakeBlueLight v6.20), nace OFF y TurnOn solo en la
//   ventana. (2) metalsonic_ability_outline -> halo blanco fino (UI
//   l.135-148, om_halo blur 1) — outline no portable: anillo TE blanco
//   8->48u en el pecho, 0.25s. FUERA el glow01 flotante. Limpieza
//   total: luz muerta en StopHeal Y ResetState (nunca huerfana). Cero
//   cambios de logica del heal (tick/tope/CD/invulnerable-cancela
//   intactos), cero cvars nuevos.
// v3.77.25 (con Metal.inc v5.0-OM): AVATAR DE METAL SONIC + TRIO DE
//   HABILIDADES GMOD — decimo pedido del owner (2026-10-09): "Es tiepo
//   del avatar de metal Sonic. Ya sabes que hacer... mover la habilidad
//   que tiene metal actualmente que es esa aura electrica a la habilidad
//   3 y la curacion seria en la X y para su habilidad Z que es la
//   embestida (te lo dira el lua de Gmod) usaremos el truco que usamos
//   con sonic (lo de desplazarse por el suelo ya que actualmente la
//   embestida de metal usa algo diferente)":
//   (1) AVATAR: 4o avatar del suite (models/Noodles/OM/metal.mdl del
//       VPK om_) con el patron Sonic v6.30 COMPLETO — doble copia R/L,
//       modo TP (tails_avatar_tp), pulso de pausa (tails_pausefix: UN
//       solo sistema), transmit filters, cuerpo RENDER_NONE, follow
//       PostThink con yaw suave, FSM de anims del metal.mdl (idle/walk/
//       run/jump/fall + charge + heal + one-shots ChargeUp/Slam1-2/
//       HealToIldle), ragdoll de muerte + ventana anti-corpse 2s/200u
//       (la muerte del avatar en player_death POST propio, receta Sonic
//       v3.76.2). Convar metalom_avatar 1 (auto-agregado al cfg).
//   (2) EMBESTIDA (Z) POR EL SUELO: FUERA el FLYGRAVITY de la v3.5
//       (re-escritura de velocidad por frame, receta Amy v63); DENTRO
//       el truco del spindash — SLOT 2 nuevo del stack del Speed_sonic
//       (SPEED_STACK_SLOTS 2->3) alza m_flMaxspeed a 750 y el
//       auto-forward se inyecta en OnPlayerRunCmd (vel[0] saturado = el
//       OM_MoveForward del GMod): EL MOTOR lo mueve con fisica de
//       caminar — escalones, rampas, gravedad normal, nunca despega.
//       DEBRIS durante el dash y frenado suave a la salida: intactos.
//   (3) X = SELF REPAIR (nueva, port del selfheal del lua: alla T):
//       toggle, tick 2s: +7 HP / +7 acumulado, para a 150 HP o 70
//       acumulado, CONGELADO mientras (NoMovement 6.7s/tick), el dano
//       la CANCELA bloqueandose (invulnerable mientras repara, igual
//       que el OM_Damage_Reduction=1 del lua), cooldown 24s, sonidos
//       reales del VPK (activation/Heal/healfinished) + glow verde.
//   (4) C = V. MAXIMUM OVERDRIVE: la aura electrica se MUEVE de la X a
//       la C (pedido literal). Cero cambio de logica.
//   (5) INTEGRACION: #include <Metal> se mueve ANTES de <Rouge> (el
//       OnEntityCreated central de Rouge despacha al filtro anti-ragdoll
//       del Metal) + Metal_OnPlayerRunCmd gana el parametro vel[] y el
//       manager traduce su true a Plugin_Changed (el usercmd modificado
//       llega al motor).
// v3.77.24 (con Tails v5.27-B + OM_Stun v2.0): STUN UNIFICADO —
//   pedido del owner (2026-10-09): "no es mejor unificar ambos stun
//   en un solo documento? si viene la misma cosa. ya que en si
//   tenemos ragdoll y el stun de congelamiento y empuje (tails) pero
//   lo que no tiene el stun de tails es las estrellas. ese es el
//   problme por eos mejor unifiquemos ese sistema para ir
//   simplificando todo yno gastemos tanto codigo en la misma cosa".
//   El congelado del rayo de Tails (Tails_SIFreeze*: ~400 lineas
//   paralelas del v5.22-v5.26 — su propio freeze, su propio ticker,
//   sus propios 10 arrays de estado) SE FUSIONA con el OM_Stun v2.0,
//   el documento UNICO del stun del suite (Sonic/Amy/Metal/Tails):
//   mismas capas (martillo + lagged + pausa de animacion), mismos
//   slots por userid, mismo ticker 20 Hz. El rayo llama OM_Stun con
//   flags nuevos (CYAN hielo / PUSH empujable / STAGGER al liberar /
//   FIXED sin apilado / NOIFRAME) + OM_Stun_Push en cada tick que lo
//   golpea; la fisica del arrastre (gravedad 800, terminal 1600,
//   deslizamiento por paredes, reposo en el suelo, anti-tunel) vive
//   ahora en OM_Stun_PushTick — receta Witch_Flight intacta. EL RAYO
//   GANA LAS ESTRELLAS (lo que le faltaba): 3 estrellas amarillas
//   orbitando + chispas + zap (om_stun_effects apaga todo). Los
//   llamadores de siempre (bola del Sonic, contra/lanzamiento de
//   Amy, catch/drag/slam de Metal) quedan a CERO cambio (flags
//   default 0 = stun clasico). Bonus de higiene: el OM_Stun_OnMapEnd
//   ahora RESTAURA a cualquier vivo que llegue al fin de mapa
//   congelado (ex Tails_SIFreezeClearAll) y el stagger de liberacion
//   nunca alcanza a un no-infectado. Cero cvars nuevos. Historial
//   3.77.23-: abajo.
// v3.77.23 (con sonic.inc v6.30-OM + Tails v5.26-B + OM_Stun v1.3):
//   ESTATUA SI + TANK NO ATURDE A SONIC — pedido del owner
//   (2026-10-09): (A) "es verdad que el FL_Frozen no sirve con SI xq
//   no son nextbots pero si podemos hacer algo pausar la animacion
//   del infectado especial... literalmente es como poner una pausa en
//   su animacion obligandole a que quede congelado (como pasaria con
//   el FL_Frozen)": nueva capa compartida OM_Stun v1.3
//   (OM_Stun_AnimPause/Tick/Resume — playback rate 0 + m_flFrozen si
//   existe el prop + secuencia y ciclo de la captura re-afirmados a
//   20 Hz) que usan TODOS los congelados de SI del suite: el stun de
//   la bola del Sonic y los martillos de Amy (OM_Stun) y el congelado
//   del rayo de Tails (v5.26) — el SI bot deja de animar en el sitio
//   y queda ESTATUA como la witch; al liberar, rate original y la IA
//   retoma sola (el stagger del descongelado se ve a full). Gate:
//   solo bots del equipo infectado (humanos SI y supervivientes de
//   Metal intactos — paridad GMod). El manager sube el #include
//   <OM_Stun> ANTES de Tails.inc para compartir la capa (el que traia
//   sonic.inc queda en no-op por el guard).
//   (B) "la evasion evitara el stun del tank y el stun de la roca del
//   mismo y tambien el spindash (ya que como dije no tiene sentido
//   que lo aturdan en spindash)" — receta del l4d_block_stumble 2.1
//   de Silvers (el smx que el owner paso de referencia): entrada
//   SONIC en el forward L4D_OnKnockedDown del manager con reason
//   KNOCKDOWN_TANK (la roca) + Sonic_TankKnockImmune (evasión activa
//   0.5s + gracia 1.5s + bola con la palanca de siempre
//   sonicom_spin_grabguard default 1) y la evasión ACTIVA entra al
//   FlingGuard (cubre el dodge del vomito, que no abre gracia de
//   1.5s). El daño/fling/stagger ya estaban cubiertos por
//   OnTakeDamage_Combat (bola invulnerable) + FlingGuard +
//   StaggerGuard: la roca era el hueco que faltaba. Cero cvars
//   nuevos. Amy/Sally/Cream/Eggman/Speed sin cambios. Historial
//   3.77.22-: abajo.
// v3.77.22 (con sonic.inc v6.29-OM): NUBE POR DEFECTO + BOLA TP +
//   EVASION PRIORITARIA — septimo reporte del owner (2026-10-09):
//   (1) "sigue sin salir es mejor que le dejes el plan de respaldo
//   sonicom_peel_nube 1 por defecto activado" — el humo azulado de la
//   bateria nunca se dejo ver en su server (dos iteraciones densas
//   cayeron en vacio): sonicom_peel_nube DEFAULT 1 = el BeamFollow
//   nativo del Speed nace del TORSO desde el arranque de cada carrera
//   del peel. OJO: la reconciliacion NO pisa lineas existentes — si
//   su Sonic_Suite.cfg ya grabo sonicom_peel_nube 0 (corriendo la
//   3.77.21), hay que ponerlo en 1 a mano o borrar la linea.
//   (2) BOLA DEL SPINDASH EN MODO TP ("el modo TP no muestra bn el
//   spindash... cuando el jugador esta cambiando de direccion la bola
//   no cambia su orientacion, el cuerpo si"): la bola quedaba
//   PARENTADA al jugador y su yaw dependia de la composicion
//   parent-rotation x angulos locales — en el campo no giraba con los
//   cambios de rumbo. Ahora en modo TP (tails_avatar_tp 1) la bola
//   viaja POR TELEPORT como la copia R humana: TeleportEntity por
//   tick con angulos de MUNDO directos (pitch = spin, yaw = bodyYaw =
//   direccion REAL del movimiento) + reloj vivo, SIN EF_NOINTERP =
//   todos los clientes la interpolan suave (el puppet de GMod se
//   mueve igual: por red, para todos). La orientacion sigue al rumbo
//   POR CONSTRUCCION. Modo parentado (tp 0): intacto.
//   (3) EVASION PRIORITARIA A COMPLETAR EN LA COPIA R ("la animacion
//   de la evasion nunca se llega a ver... deberia ser prioritaria por
//   encima de cualquier otra... debe concretar hasta que la animacion
//   acabe... el problema no es el local, el lo ve, sino el R"): el
//   lock fijo de 0.5s le cortaba la cola y cualquier pisada de
//   secuencia en la R la mataba en silencio. Ahora: el lock se ESTIRA
//   tick a tick mientras la secuencia DodgeX siga viva en el modelo
//   (m_flCycle < 0.95, el patron del jump) con tope duro 1.2s, y
//   SELF-HEAL: cada latido se verifica el m_nSequence de la R contra
//   el indice real aprendido al disparar (sonda SetAnimation +
//   readback, patron del resolvedor de Amy v91) — si algo lo piso, se
//   RE-DISPARA en el acto en R y L. La eva corre ENTERA y encima de
//   cualquier estado (peelout incluido); al acabar, la FSM devuelve
//   la animacion que toque. Cero cvars nuevos. Amy/Tails/Sally/
//   Cream/Eggman/Speed sin cambios. Historial 3.77.21-: abajo.
// v3.77.21 (con sonic.inc v6.28-OM): HUMO DENSO + BOTAS AL SUELO +
//   sonicom_trails_mat FUERA — sexto reporte del owner (probando la
//   3.77.20, 2 videos): "las esferitas si aparecieron... el unico peo
//   que queda es el humo azulado que no se ve" + "mira como se ven las
//   botas el grafico rojo en Gmod y mira como se ve en L4d2" + "en el
//   video de Gmod se ven un poco mas florecentes con brillo" + "ya
//   quita la opcion de sonicom_trails_mat... el parche lo arreglo.
//   osea siempre usara los materiales originales (no los vanilla del
//   l4d2)" + "si el humo sigue sin salir ponme un comando que me
//   permita que este cambie por el Beam nativo que usa el speed para
//   complementar la falta (necera desde el torso)". ANALISIS VLM de
//   ambos videos con mediciones NORMALIZADAS por altura de personaje.
//   CAMBIOS: (1) AUTENTICO SIEMPRE — la cvar sonicom_trails_mat
//   ELIMINADA: blue2/Sonicred/blue_2ndlayer/blue via env_spritetrail
//   + fix fbef0102 siempre que los archivos existan (gate FileExists
//   interno), TE nativo solo como fallback. Nota: si el Sonic_Suite.cfg
//   guardo sonicom_trails_mat 0, esa linea queda huerfana (inofensiva —
//   la cvar ya no existe, SourceMod la ignora al recargar). (2) BOTAS
//   ROJAS como el GMod: z+8 -> z+2 (RAS DEL SUELO — la .20 flotaba al
//   doble de altura), ancho 6->1 -> 7->3.5 (cinta gruesa tipo huella
//   de neumatico, sin dejar el 90% del largo en 1-3u de linea laser),
//   fade 0 -> 1 (cola suave minima; el stock TE declara FadeLength INT)
//   y el chip Sonicred
//   SOLIDO siempre (la cinta opaca del video GMod vs el degradado
//   translucido del laserbeam). (3) HUMO DENSO: la bateria 5->9
//   sprites por latido — 5 humos om_bluesmoke 45-62u "110 160 255"
//   con sesgo ATRAS (la cape/wake que envuelve espalda y piernas) +
//   4 glows cian-blanco 34-46u "170 210 255" alrededor (nucleo
//   brillante) + moon. (4) ESFERITAS mas florecentes: glow01 tintado
//   "224 240 255" (#E0F0FF del video GMod) alpha 150->200 y velocidad
//   30-80 -> 10-28 uu/s (el air resistance 40 del Lua las frena
//   enseguida alla; a 30-80 constantes se regaban por el pasillo):
//   quedan como enjambre brillante PULSANDO alrededor del torso. (5)
//   NUEVA CVAR sonicom_peel_nube (0 default): 1 = LA FALTA DEL HUMO
//   la cubre EL BEAM NATIVO DEL SPEED — BeamFollow laserbeam 0.6s
//   10->1 fade 3 azul "125 185 255" desde el TORSO (el mismo
//   info_target +20z del trail principal), cambio EN VIVO al latido
//   siguiente sin reiniciar el peel. Amy/Tails/Sally/Cream/Eggman/
//   Metal/OM_Stun/Speed_sonic INTACTOS. Cero gameplay. Cvars: 208
//   (-1 sonicom_trails_mat +1 sonicom_peel_nube).
// v3.77.20 (con sonic.inc v6.27-OM): LAS ESFERITAS BLANCAS — quinto
//   reporte del owner (probando la 3.77.19): "weon y las cositas blancas
//   que habia antes?... que las hiciste desaparecieron" + "las esferitas
//   blancas que desapareciste nacen de Torso tambien y se dispersan
//   aleatoriamente y CAMBIAN el humo blanco (lo dice el lua de Gmod no
//   mms...)". El owner aporta el QC del modelo (Noodles/OM/Sonic.mdl):
//   $attachment "Trail" (bone Trail a +19.08z, secuencia autoplay
//   "attatchfix" que lo deja FIJO pegado al cuerpo — donde nace y se
//   enlaza la linea del cuerpo: nuestro info_target +20z ya estaba ahi),
//   "LeftFootTrail"/"RightFootTrail" (los attachments 2/3 donde el Lua
//   cuelga las Sonicred de los zapatos) y el bone "Torso" (la pieza del
//   cuerpo). Las esferitas = el OM_tinyball_fleetway del pack (effects
//   lua L657-742): bolitas BLANCAS (255,255,255, alpha 150) con la
//   textura icons/Fleetways_tiny_balls.png (estrellita crema), nacen del
//   bone "Torso" ±12u, velocidad aleatoria 30-80 uu/s (VectorRand),
//   vida 1.2-2.5s, gravedad suave +z. PORTADO: Sonic_PeelTinyBall (2-3
//   por latido 10 Hz ~25/s — alla 67/s eran particulas de cliente, aqui
//   edicts) + Sonic_SpawnPeelBall (env_sprite aditivo + SetEntityMoveType
//   MOVETYPE_FLY + velocity => el ENGINE las dispersa de verdad, sin
//   timers) + MATERIAL NUEVO fleetways_tiny_balls.vmt/.vtf (convertido
//   del PNG autentico del pack del owner, 70x72->64x64 RGBA8888 VTF 7.2,
//   gate FileExists + downloads, fallback glow01 blanco) + los 5 HUMOS
//   "135 185 255" de la carrera FUERA ("las esferitas CAMBIAN el humo
//   blanco"): la nube ahora = esferitas blancas + glows 125,125,175 +
//   moon. INTACTOS por orden del owner: linea roja ("ya dejalo asi"),
//   aspa azul ("esta bn xq en el Gmod original tambien sale"), beam
//   azul (+20z = attachment Trail del QC), polvo de carga. Cero gameplay,
//   cero cvars, 1 material nuevo (en el zip de la suite).
// v3.77.19 (con sonic.inc v6.26-OM): LA COSA NEGRA — cuarto reporte
//   del owner (probando la 3.77.18, video 13-20-15): "OK ESTAS CERCA" —
//   el peel por fin lee como el GMod pero (1) "la cosa esta negra":
//   CUADROS NEGROS de bordes duros flotando alrededor del corredor;
//   (2) las lineas rojas todavia a segmentos ("debes aumentar su hz...
//   el del spindash siempre estuvo pegado, funcionaba a la perfeccion");
//   (3) "el laser azul que falta... el que antes aparecia a espaldas de
//   sonic... se perdio en los cambios". Diagnosticos 1-a-1 con VLM
//   sobre su video: (1) los cuadros negros eran los HUMOS de la nube —
//   el UNICO env_sprite que no iba en aditivo: el rendermode 0
//   (kRenderNormal) dibuja el quad OPAOCO y los texeles transparentes
//   de glow01/om_bluesmoke (RGB 0) pintan NEGRO con nucleo blanco =
//   "glow sprite that failed to blend". FIX: SpawnPeelPuff SIEMPRE
//   aditivo (todo lo que este server dibuja bien es rendermode 5),
//   humos recalibrados alpha 220->120 / escala 0.14-0.21 (el aditivo
//   apila: la masa queda densa sin lavarse). (2) SONIC_TE_TICK 0.05 ->
//   0.01 = el latido dispara CADA FOTOGRAMA del server (30 Hz a 30
//   tick / 60 Hz con su TickrateEnabler) = el regimen de muestreo del
//   BeamFollow nativo del spindash: segmentos de 13-27u a 800 uu/s =
//   curva continua "siempre pegada". (3) el beam 3-capas v6.25 era
//   esbelto (28->14 + 15->1) y no se leia: SUBE a la GEOMETRIA EXACTA
//   del trail de la BOLA (halo 34->19 + nucleo 24->1 + acento azul
//   profundo 24->1, alfas 190-220) sobre el mismo info_target +20z del
//   Lua. Cero gameplay, cero cvars, cero materiales nuevos.
// v3.77.18 (con sonic.inc v6.25-OM): TODOS MECANISMOS PROBADOS —
//   tercer reporte del owner (probando la 3.77.17): "todavia siguen
//   saliendo esas aspas azules solas sin las nubes de particulas ni el
//   Beam azul (que se parece un poco a la de spindash) y las botas de
//   lineas rojas que tenia antes... cada vez estas alejando mas".
//   Autopsia: (a) el env_steam NO dibuja en el cliente L4D2 -> las 3
//   nieblas de la .17 (aura, estela y polvo de carga) INVISIBLES;
//   (b) los BeamFollow de pies sobre info_targets laterales no se veian
//   (las polylineas de la .16 SI se veian); (c) el trail laserbeam
//   unico de width 16 + los moons ESTATICOS gigantes (77-140u nacendo
//   detras) = las "aspas azules". Reconstruccion 1-a-1 del Lua con el
//   mecanismo que ya funciona en su server para CADA pieza: NUBE =
//   bateria env_sprite (5 humos alpha-blend 135,185,255 + 5 glows
//   aditivos 125,125,175 por latido 0.1s, vida 0.4-1.0s — la masa
//   densa del video GMod), MOONS = 1 arco por latido nacendo EN el
//   cuerpo +35z creciendo 35-46->112u y abandonado por el corredor,
//   PIES ROJOS = polylineas CHAIN de vuelta pero a 0.05s (segmentos de
//   40u = curva suave, no poligonos) 6->1 / 0.75s {235,60,60}, BEAM
//   AZUL = 3 CAPAS estilo spindash (halo 28->14 + nucleo 15->1 +
//   acento 15->1 sobre el info_target +20z — "se parece un poco a la de
//   spindash", pedido literal), POLVO DE CARGA de vuelta a bateria (6
//   puffs/0.15s). env_steam/MakeSteam/MakeFootTarget eliminados. Cero
//   gameplay, cero cvars, cero materiales nuevos.
// v3.77.17 (con sonic.inc v6.24-OM): EL PEEL DE VERDAD — segundo
//   reporte del owner con video de prueba (05:50, testeando la
//   3.77.16): "tu prueba... Esta igual... No se parece a la de Gmod
//   ni bueno en nada". Analisis fotograma a fotograma contra su video
//   del GMod (dash t=2.75-4.25): 3 causas raiz corregidas — (1) la
//   BANDA AZUL PLANA: el chip blue2 en el renderer TE = banda
//   rectangular saturada de borde duro; el nativo vuelve al LASERBEAM
//   radial suave tintado con el azul hielo del blue2 real (204 230
//   255) + fade 200 (cola que se apaga gradual); el chip queda SOLO
//   para el autentico. (2) LOS POLIGONOS ROJOS RIGIDOS: las estelas de
//   pies encadenadas (segmentos BeamPoints RECTOS de 160u a 800 uu/s)
//   mueren: 2 info_targets parentados a los PIES (+-8 lat, +8z, split
//   R/L) con BeamFollow laserbeam rojo = curva suave por fotograma.
//   (3) LA NUBE QUE NO SALIA: su server NO tenia om_bluesmoke.vmt
//   (mats v3) = masa invisible; la niebla ahora son 2 env_steam STOCK
//   (aura que sube + estela hacia atras, color GMod 135 185 255 — CERO
//   material) + la carga gana su nube gris con el mismo env_steam a
//   los pies. BUGFIX: el combo peel->spin dejaba las entidades del
//   trail VIVAS PARA SIEMPRE (fase 0 sin KillPeelTrail). Los 4
//   archivos icons/ van ahora DENTRO del zip de la suite. Cero
//   gameplay, cero cvars.
// v3.77.16 (con sonic.inc v6.23-OM): LOOK DEL PEEL AL ESTILO GMOD —
//   feedback del owner con capturas del 04:50 + video del GMod:
//   "efectos incorrectos (l4d2) peelout ... el Gmod esta hecho de
//   diferente manera — debes revisar los lua de Gmod". Diagnostico:
//   la "nube gigante uniforme" que flotaba detras/arriba del personaje
//   = (a) glows a 60-85u (alla 45-55u), (b) flash blanco de 160u y
//   (c) light_dynamic radio 220 / brightness 2 / +40z lavando de azul
//   la niebla (en GMod la "luz" de la carrera son los glow PARTICLES
//   aditivos — NO hay dlight). Correcciones a valores GMod EXACTOS:
//   glows 0.45-0.55 x5 + humos 0.20-0.25 x8 por latido (densidad de
//   chaparron), MOON creciendo x2.2 y volando DETRAS (-fwd*20-60,
//   back-offset 0->80 del effects lua), flash 1.6->0.45, luz del peel
//   150/1/+20z (la bola conserva su 220/2), puffs con desvanecido
//   Alpha->0 + salto de escala por I/O, polvo de carga creciente
//   (3-6->10-20 alla), y el TRAIL PRINCIPAL NATIVO usa la textura REAL
//   blue2.vmt tintada blanca cuando el pack esta en el server (chip 2x2
//   plano = inmune al mapeo U/V de los beams — el "look bugeado" del
//   v6.17 era de las texturas de PERFIL) + Sonicred en los pies igual.
//   Cero gameplay, cero cvars nuevos.
// v3.77.15 (con sonic.inc v6.22-OM): NUBE AZUL DEL PEEL OUT + 3a
//   CAPA AZUL — feedback del owner (2026-10-08): "falta el efecto y
//   demas cosas que tenia el Peelout en el original de Gmod — el peel
//   tenia el efecto rojo de los pies y la luz, ambos y muchos efectos
//   de estela" + "ese efecto no deberia ser morado deberia ser azul
//   (el del spindash y el peelout)". (1) 3a CAPA DE LA BOLA: el tinte
//   magenta {255,0,255} (el Color(255,0,255) del Lua, que en GMod cae
//   sobre textura azul y se lee azul-violeta) pasa a AZUL PROFUNDO
//   {35,90,255} en las 3 ramas (nativo TE / autentico / fallback) —
//   sobre el laserbeam blanco se leia ROSA. (2) NUBE DE LA CARRERA:
//   port del bloque Think L1588-1662 del sonic.lua que faltaba —
//   cada 0.1s alrededor del corredor: 3 HUMOS AZULES (Color
//   (135,185,255) alla; textura propia om_bluesmoke generada 128x128,
//   fallback glow01 tenue) + 2 GLOWS (125,125,175) + 1 MOON
//   (sonic_peelout_moons: sonic_dashing_effect del pack ORIGINAL
//   512x512 DXT5 tal cual). Bateria de env_sprites efimeros SIN
//   parent en posicion de mundo + Kill diferido por I/O: la nube
//   queda detras sola mientras el corredor se aleja, CERO riesgo del
//   bug del cielo v6.21. (3) POLVO GRIS de la carga (peeloutdust2_OM
//   L795-807) y (4) FLASH BLANCO de arranque/suelta (glow_duration_
//   white L1701/L1778). Materiales nuevos con gates FileExists +
//   precache + descargas (om_bluesmoke + sonic_dashing_effect —
//   mini-pack v3). Descartados con evidencia: sonic_sparkle_OM
//   (COMENTADO en el Lua L1487) y SonicTrail_OM (sin disparador =
//   codigo muerto). Cero gameplay, cero cvars. Amy/Tails/Sally/
//   Cream/Eggman/Speed sin cambios. Historial 3.77.14-: abajo.
// v3.77.14 (con sonic.inc v6.21-OM): FIX DEL "TRAIL EN EL CIELO
//   LEJANO" — reporte del owner con capturas (2026-10-08): "los
//   sprites que deberian salir en Sonic durante el spindash aparecen
//   alla a lo lejos" (haces cruzando el cielo + una estructura magenta
//   gigante). El fix del env_spritetrail (fbef0102) FUNCIONO — las
//   estelas autenticas se dibujan por primera vez — pero nacian en el
//   lugar equivocado: la receta avatar (world-pos -> SetParent) leia
//   m_vecOrigin del padre, que para la BOLA y las copias R/L del avatar
//   (props PARENTADOS al survivor) es la origin LOCAL (~{0,0,15}), NO
//   la de mundo: los hijos nacian en el (0,0,15) DEL MAPA y el SetParent
//   re-basaba un offset de miles de unidades que GIRABA con el yaw.
//   FIX: Sonic_WorldOrigin (m_vecAbsOrigin / GetClientAbsOrigin) en las
//   5 lecturas (MakeSpriteTrail / MakeTrailTarget / MakeBlueLight /
//   MakeBallGlow / anillo del pulso del golpe). Solo afectaba el modo
//   AUTENTICO (mat 1); el nativo TE (default) no sufria el bug. Cero
//   gameplay, cero cvars. Amy/Sally/Cream/Eggman/Tails sin cambios.
//   Historial 3.77.13-: abajo.
// v3.77.13 (sonic.inc v6.20-OM + Amy.inc v101-OM + Speed_sonic v3.3):
//   PULIDO DEL LOOK + EFECTO DE GOLPE + AUTENTICO env_spritetrail
//   REVIVIDO — lote de feedback del owner (2026-10-08) + su hallazgo
//   del smd_spritetrail_fix de fbef0102 (original FrozDark): la
//   estela del env_spritetrail en L4D2 SI se dibuja pero se congela
//   a los ~1 s; un SetScale diferido por FireUser1 la revive. El
//   MODO AUTENTICO (sonicom_trails_mat 1) vuelve a env_spritetrail
//   + fix = el MISMO renderer del SpriteTrail de GMod con los .vmt
//   originales. CAMBIOS: (1) pies ROJOS del peel visibles — el trail
//   principal sube a +20z en un info_target (receta trailOrigin del
//   GMod; antes al ras del suelo se los tragaba) y los pies pasan a
//   6->1 / 0.75s GMod exactos; (2) azul MAS POTENTE (alpha 250, vida
//   0.75) + BRILLO AZUL EN LA OSCURIDAD: light_dynamic azul en la
//   bola (spin) y en el player (peel) + glow01 azul en la bola;
//   (3) trail de la bola REESCALADO (~32u real: halo 34->19, nucleo
//   y magenta 24->1 — antes 70/40 gigante); (4) EFECTO DE GOLPE del
//   spindash (sonic_spindashhit del GMod): flash sonic_drop_impact
//   (PNG del pack convertido a VTF+VMT) + anillo 10->165/0.45s +
//   chispas + pulso de la bola; (5) AMY v101: trail del martillo a
//   color ROSA; (6) SPEED v3.3: SIN AURA — glow outline retirado del
//   survivor oculto y del avatar, solo queda el trail. Cero cvars
//   nuevos. Historial 3.77.12-: abajo.
// v3.77.12 (con sonic.inc v6.19-OM): TRAILS A MATERIAL NATIVO
//   (default) — el owner trajo el pack de MATERIALES ORIGINALES
//   del OM y reporto que los sprites del sonicball 'aparecen
//   bugeados' en L4D2. Analisis forense: los .vmt son legítimos
//   (UnlitGeneric, VTF 7.2) pero sus texturas estan disenadas
//   para el SpriteTrail de GMOD (bluetrail = barra vertical de
//   perfil transversal; bluestartrail2 = 98% transparente con
//   destellos; blue2/Sonicred = chips 2x2) y en los TE beams de
//   L4D2 el mapeo queda al reves = bugeado. El laserbeam radial
//   nativo es inmune. NATIVO pasa a ser el DEFAULT con la
//   geometria 3-capas del GMod completa (halo 70->40 azul + nucleo
//   40->1 + magenta 40->1, aditivas como en el Lua) y el peel gana
//   los 2 pies rojos nativos (Sonicred = chip rojo plano).
//   FIX descargas: se encola el $basetexture REAL de cada .vmt
//   (blue.vmt -> bluetrail.vtf; el v6.17 encolaba un blue.vtf
//   inexistente = damero en clientes sin instalacion manual).
//   sonicom_trails_mat default 0 (1 = autenticos opt-in). Nota:
//   si el Sonic_Suite.cfg ya guardo sonicom_trails_mat 1, hay que
//   ponerlo a 0 a mano (la reconciliacion no toca lo guardado).
//   Amy sin cambios (v100-OM: su martillo ya iba en laserbeam
//   nativo — por eso a ella nunca se le vio malo). Historial
//   3.77.11-: abajo.
// v3.77.84 (2026-10-15) — LA BARRA AL CHAT CON colors.inc (SBar
//   v3.0-OM / Blaze v2.9-OM / Silver v2.3-OM / sonic v6.37-OM).
//   Reporte del owner sobre la .83 con DOS capturas: "puedes quizas
//   usar el colors.inc para el tema de los colores xq aparesen font y
//   no creo que quede bn y la barra deberia aparecer mas abajo" + la
//   anotacion manuscrita en pantalla "La barra debe ir aqui" con una
//   flecha señalando la esquina INFERIOR IZQUIERDA (la zona del chat,
//   ~x11% y86%). AUTOPSIA DEFINITIVA DEL CANAL: la captura muestra el
//   mensaje de la barra con los <font color='#828282' size='24'>
//   impresos como TEXTO LITERAL dentro de la caja negra — L4D2 NO
//   PARSEA RICH TEXT en el HintText (el HTML del hint es cosa de TF2;
//   en toda la familia L4D — y hasta CS:GO, hilo AlliedMods t=319760 —
//   el parser no existe y los tags salen crudos). La "receta Amy" de
//   la v2.1 era un espejismo: los hints "coloreados" de este server
//   siempre mostraron los tags literales y nadie lo reporto hasta que
//   la barra lo puso en pantalla a 5 Hz.
//   FIX DE RAIZ (el que el owner pidio palabra por palabra): la barra
//   MIGRA AL CHAT — el canal de la esquina que marco en la captura —
//   coloreada con la PALETA L4D2 del colors.inc v2.0.0-MC que ya vive
//   en el tree del server: {green} = AMARILLO vivo en L4D2 / {blue} =
//   azul del equipo survivor (el de Sonic, SIEMPRE disponible: el
//   propio jugador) / {lightgreen} = verde claro de autor server /
//   {olive} = oliva apagado / {red} = rojo del equipo infectado (si no
//   hay ningun infectado en juego, colors.inc lo degrada a amarillo —
//   aceptado y documentado). REGLA del colors.inc: maximo UN color de
//   equipo por mensaje — por eso cada linea lleva UN solo color de
//   estado (celdas llenas + tag), con default/olive libres.
//   ANTI-SPAM: el think calcula a 5 Hz pero el chat se escribe
//   THROTTLED — linea nueva SOLO al cambiar el contenido (tope
//   sbar_chat_interval, default 1.0s), las TRANSICIONES de tag
//   (LEVITANDO! / VACIA! / MODO SOL / RECARGA / ESQUIVA!) pasan antes
//   (0.3s) y la barra QUIETA se re-imprime cada sbar_chat_refresh
//   (12.0s = hud_saytext_time default: siempre visible sin apilar; 0
//   = dejarla desvanecer en reposo).
//   Colores por personaje: BLAZE amarillo fuego lleno / verde claro
//   medio / oliva bajo / rojo VACIA parpadeando; SILVER verde claro
//   LEVITANDO! / amarillo RECARGA / oliva poca carga / rojo VACIA;
//   SONIC AZUL survivor (su color) / amarillo bajo / rojo SIN ANILLOS!.
//   sbar_channel 1 = la caja negra del hint con TEXTO PLANO (sin un
//   solo <font>: fallback de comparacion); sbar_cells tope 26 (la
//   linea del chat no hace wrap); RETIRADO sbar_size (murio con el
//   rich text del hint). sm_sbarprobe REESCRITO: 1 chat lightgreen /
//   2 chat green (amarillo) / 3 chat red / 4 chat blue / 5 hint plano
//   / 6 barra real.
// v3.77.83 (2026-10-15) — LA BARRA ESCRIBE (FIX DEL "NADA ESCRITA")
//   Reporte del owner sobre la v3.77.82: "ok aparece la barra negra esa
//   pero no hay nada escrita en ella en si". AUTOPSIA: el panel HintText
//   SI llegaba (la caja negra abajo-centro ES el propio panel), pero el
//   contenido no renderizaba. Causa: la v2.0 armaba el mensaje con
//   size='24' en el <font> de TODAS las lineas — y en TODO el codigo de
//   este server, los hints que el owner ve funcionando a diario (Furia
//   Protectora y Momentum de Amy, cintura de Sally, DESCONGELADO del
//   OM_Stun, DODGE de Sally, DIVA BODY...) llevan size= UNICAMENTE en el
//   tag de la PRIMERA linea; las lineas 2+ van con COLOR SOLO. El parser
//   de rich text del hint de L4D2 no tolera size en las lineas de
//   cuerpo: un solo tag fuera de la receta y muere el render del mensaje
//   ENTERO — caja negra vacia, exactamente el sintoma reportado.
//   FIX (SBar v2.1-OM): el mensaje se arma con la receta PROBADA byte a
//   byte en estructura: <font color='#RRGGBB' size='N'> en la linea 1
//   (label + numeritos + tag) y <font color='#RRGGBB'> COLOR SOLO en las
//   filas de celdas. Ademas: sbar_cells con tope 30 (el mensaje queda en
//   169..191 bytes, SIEMPRE bajo el techo de ~206 bytes verificado en
//   produccion con el HUD de Furia) y NUEVO sm_sbarprobe <1..6>: sonda
//   del canal que mantiene 12s una variante de prueba (1 = receta Amy
//   clonada, 2 = receta v2.1, 3 = receta v2.0 rota, 4 = texto plano,
//   5 = celdas sin corchetes, 6 = barra real) — si algo vuelve a fallar,
//   un comando diagnostica que caracteristica mato el canal sin otra
//   vuelta de compilacion.
// v3.77.82 (2026-10-15) — LA BARRA SE VE DE VERDAD + LA LANZA CON
//   ALCANCE / CURSO / STUN (SBar v2.0-OM / Blaze v2.8-OM). Reporte
//   del owner sobre la .81: (1) crash "Invalid client index 467" x3
//   (Blazing: Sonic_ability_manager.smx / IsPlayerAlive <-
//   Blaze_HitImpact <- Blaze_GameplayThink <- T_BlazeAvatarThink):
//   el OR de Blaze_HitImpact evaluaba IsPlayerAlive ANTES del chequeo
//   de rango — un comun (entidad 400+) reventaba el native, el think
//   abortaba con el estado del kick vivo y el resto del tick (avatar,
//   sol de la patada, rebote, sonido) se perdia; ahora el rango va
//   PRIMERO (victim > MaxClients || IsClientInGame && IsPlayerAlive).
//   (2) "y no se ve la barra": LA BARRA NUNCA SE HABIA VISTO — ni en
//   la v3.77.80 ni en la .81 — porque game_text esta ROTO en toda la
//   serie L4D (bug documentado en la wiki de Valve: el HudMessage se
//   redirige a la 2a vista del splitscreen Y la fuente no esta
//   definida en clientscheme.res = invisible en clientes vanilla;
//   por eso el owner nunca la vio y su "texto chiquito" era el panel
//   KeyHintText v3.77.72). SBar v2.0: migracion al HintText con RICH
//   TEXT (el canal del HUD de Furia de Amy — probado en este server):
//   <font color size> por linea, barra GRUESA de celdas ASCII + linea
//   de texto con label/numeritos/tags, color por nivel RESTAURADO,
//   parpadeo VACIA, tamano sbar_size 24 (el "mas grande" pedido,
//   resuelto de verdad), 3 lineas (tope del canal), cero entidades
//   (OnMapEnd/pool/game_text fuera). Convars: sbar_enable/_cells 20/
//   _lines 2/_size 24/_fill #/_empty -; sbar_x/_y/_dy/_channel
//   retiradas (el HintText pinta donde el HUD del cliente lo pone).
//   (3) "la lanza deberia tener mas alcanze": doble bug del trace de
//   pared — rayo INFINITO (cualquier func_ delante a CUALQUIER
//   distancia la clavaba AL NACER) + filtro que excluya el MUNDO
//   (atravesaba las paredes del mapa); ahora se traza SOLO el segmento
//   recorrido del tick (prev -> jp) con el filtro aceptando el mundo,
//   y la lanza se clava EN el punto de contacto. Radio de caza
//   blaze_javelin_radius 120 (80 fijo antes). (4) "la lanza debe
//   mirar 90 grados hacia el frente": blaze_javelin_pitch 90 — el
//   picon w_pitchfork nace vertical, +90 de pitch lo pone apuntando
//   a lo largo del vuelo (-90 si quedara al reves, 0 = como antes).
//   (5) "los objetivos empujados entraran en OM stun por 1 seg (osea
//   aplicando tambien el stagger)": el javelin NO aplicaba stun
//   ninguno — ahora OM_Stun 1s con OM_STUN_F_STAGGER al enganchar
//   (stagger al liberar + interrupt al entrar via om_stun_interrupt;
//   stack=false = stun fresco por acierto; commons no son players,
//   siguen con dano + arrastre). Blaze v2.8-OM.
// v3.77.81 (2026-10-15) — LAS BARRAS DE RECURSO PARA TODOS + MAS
//   GRANDES (SBar v1.0-OM / Blaze v2.7-OM / Silver v2.2-OM /
//   sonic v6.36-OM). Pedido del owner: "ese mismo tipo de barra
//   deberia salir para sonic y todos aquellos que lo usan (silver
//   para su vuelo sonic para su evasion. y puedes hacer que el
//   texto sea no se... mas grande? osea se note mejor xq en si es
//   dificil de leer por lo chiquito que es".
//   [1] EL MOTOR SE HACE COMUN (include/SBar.inc NUEVO): la Llama
//       Sol de Blaze, la flyingBar de VUELO de Silver (la
//       OM_Fleetway_flyingBar 0-20 del Lua: drena 9.4/s levitando,
//       se recarga en el suelo, al vaciarse deja 8s de cd) y los
//       ANILLOS de Sonic (su EVA — el Dodgemeter 0-50 del GMod)
//       comparten un solo think de 5 Hz + pool de game_text. Cada
//       include expone su <Char>_BarState(client) que llena el
//       estado compartido; SBar_Resolve (aqui, tras los includes)
//       despacha por personaje. La tecnica NO cambia: game_text del
//       engine, Display SOLO al activador (cada jugador ve SU
//       barra), keyvalues vivos por tick (movible en vivo) — la
//       receta v3.77.80 ya probada en server.
//   [2] MAS GRANDE (el "se note mejor"): la fuente de game_text es
//       fija (la del HUD del engine) — lo que se apila ES LA LINEA:
//       sbar_lines 2 (default) dibuja la MISMA cadena en 2 lineas
//       consecutivas (y + dy*l, canales consecutivos) = barra el
//       DOBLE de gruesa y texto "en negrita" (2 copias alineadas);
//       sbar_lines 3 = triple. Ademas sbar_cells 20 -> 30 (50% mas
//       larga) y refresco 4 -> 5 Hz.
//   [3] SONIC (v6.36): Sonic_PlayerIs (nuevo) + Sonic_BarState —
//       anillos 0..sonicom_rings_max, celeste lleno / naranja bajo /
//       parpadeo SIN ANILLOS; tag ESQUIVA! en la ventana del
//       dodge/gracia. El hint "Anillos: x/y" se RETIRA (la barra lo
//       reemplaza en vivo). Con sonicom_rings 0 no hay barra.
//   [4] SILVER (v2.2): Silver_BarState — VUELO 0..silver_fly_bar,
//       cian vivo LEVITANDO!, amarillo en RECARGA Xs (el cd de 8s),
//       parpadeo VACIA!. El panel KeyHintText sigue con la ENERGIA
//       (0-100): la barra es del VUELO (pedido literal del owner).
//   [5] BLAZE (v2.7): la logica v2.6 (frac/colores/tags DRAIN/FLAME/
//       MODO SOL/VACIA) INTACTA en Blaze_BarState — solo cambia
//       QUIEN la dibuja. Las convars blaze_bar_* (v3.77.80) se
//       RETIRAN y manda sbar_* (una geometria para todos; defaults
//       nuevos: x 0.32 / y 0.86 / cells 30 / lines 2 / channel 3).
//       Si el Sonic_Suite.cfg guardo blaze_bar_*, quedan como
//       lineas muertas que el motor ignora (borrables a mano).
//   [6] MODO SOLO: el think NO filtra IsFakeClient — el host local
//       (cliente fake) TAMBIEN ve su barra (capa v3.77.79); un bot
//       con modelo de personaje en dedicado solo recibe un Display
//       que nadie ve (cero costo).
// v3.77.80 (2026-10-15) — LA BARRA DE LLAMA SOL DE BLAZE, HUD POR
//   game_text (Blaze v2.6-OM). Pregunta del owner: "es posible crear
//   una UI HUD a base de smx como hacia Gmod para ponerle a blaze su
//   barra de calor? ya que actualmente no hay nada que le indique
//   cuanto calor tiene... me hiso recordar cuando tienes efectos
//   ejemplo como la arenalina que la pantalla se nota con ese efecto
//   asi como rojo o cuando estas en llamas yo me di cuenta que era
//   PCF". LA RESPUESTA COMPLETA: [a] Gmod dibuja esa barra con Lua de
//   CLIENTE (hook HUDPaint + surface.DrawRect): L4D2 no tiene cliente
//   scriptable, un .smx vive SOLO en el server y un panel VGUI nuevo a
//   lo Gmod es IMPOSIBLE (empaquetar un HUD custom obliga a tocar el
//   cliente, que VAC no deja); [b] lo que el owner recordaba
//   (adrenalina roja / pantalla en llamas) es POST-PROCESO del CLIENTE
//   (shader/PCF): no se puede disparar a voluntad desde un plugin —
//   por eso el PCF de las particulas SI nos sirve (los efectos del kit
//   ya lo usan) pero NO sirve para dibujar barras; [c] el canal que SI
//   existe desde el server = la entidad game_text del ENGINE: texto
//   COLOREADO en una posicion fija de la pantalla, y con spawnflag
//   "All Players" = 0 el Display se muestra SOLO al jugador que lo
//   activa (cada Blaze ve su barra, como el HUD del Gmod que es por
//   jugador) — la misma tecnica con la que los mods competitivos
//   pintan sus HUD. IMPLEMENTACION (Blaze v2.6-OM): think 4 Hz
//   (0.25s) + holdtime 0.6 = barra VIVA que nunca parpadea por
//   refresco; pinta el meter SOLFLAME 0..blaze_maxSolflame con celdas
//   █/░ [UTF-8 multi-byte: no caben en un char de SourcePawn, se
//   copian byte a byte]; COLOR por nivel: >=50% naranja llama [MODO
//   SOL] / >=20% amarillo / <20% rojo aviso / VACIA (0) parpadea
//   rojo-gris cada tick; tags de estado: DRAIN! / FLAME! / MODO SOL /
//   VACIA!; formato "SOL [██████████░░░░░░░░] 55/100  MODO SOL".
//   CONVARS: blaze_bar_enable 1 / _x 0.40 / _y 0.87 / _cells 20 /
//   _channel 4 / _fill █ / _empty ░ — x/y/canal se re-aplican por
//   tick con AddOutput = la barra se MUEVE EN VIVO a media partida;
//   _fill/_empty existen por si la fuente del HUD de un cliente no
//   dibuja los blocks (fallback ASCII: blaze_bar_fill | y
//   blaze_bar_empty . ). CICLO DE VIDA: una game_text por Blaze por
//   mapa (max 4 entidades, creacion perezosa y re-uso); muerta / cambio
//   de personaje / convar off = mensaje vacio con holdtime corto
//   (limpia ya); desconectado = Kill de la entidad; fin de mapa = refs
//   a 0 (las entidades mueren con el). MODO SOLO: el think NO filtra
//   IsFakeClient — el host local (fake) ve su barra igual (capa
//   v3.77.79); en dedicado, un bot con modelo blaze solo recibe un
//   Display que nadie ve (cero costo). El panel KeyHintText de la
//   v3.77.72 (LLAMA SOL 37/100) sigue igual: la barra es su complemento
//   visual — el NUMERO en el panel de la derecha, la BARRA abajo.
// v3.77.78 (2026-10-15) — EL JAVELIN VUELA DE VERDAD + LA HITBOX ES EL
//   RECORRIDO + EL REMBOLSO DEL KICK (Blaze v2.5-OM). Tres pedidos del
//   owner en un solo paquete:
//   [1] "La 2 habilidad la lanza aun no funciona no lanza nada" — el
//   Lua del Gmod usa models/props_junk/harpoon002a.mdl (arpon de HL2):
//   L4D2 NO lo trae. El owner decidio: "usaremos es Pitchfork" —
//   w_pitchfork.mdl (The Sacrifice) viene en el L4D2 base, TODO cliente
//   lo tiene. AUTOPSIA COMPLETA (3 causas + 1 bloqueo): (a) modelo HL2
//   inexistente en L4D2 = prop invisible o muerto al spawnear; (b) la
//   estela molotov_trail de la v2.2 NO existe en la lista de particulas
//   de L4D2 = render silencioso (3er caso de la familia de nombres
//   invalidos: invisible sin error); (c) el think leia m_vecVelocity
//   del datamap del prop_physics_override que NO siempre refleja el
//   vphysics — si leia 0 lo daba por muerto al instante; (d) SIN tope
//   de vuelo: el javelin que no tocaba nada salia del mapa por el cielo
//   y NUNCA moria — el "uno vivo por jugador" bloqueaba la habilidad
//   PARA SIEMPRE (la X no hacia nada, sin mensaje). FIX: pitchfork +
//   fuego env_fire_small parentado (familia confirmada Sol Flame v2.3 /
//   dash v2.4; convar blaze_fx_jav_name) + vuelo por DIRECCION guardada
//   al disparar (cero lecturas al prop, como el Lua que arrastra el
//   Think) + tope de vuelo 6s + nace a la altura de la mano (ojo+30,
//   no +40 sobre la cabeza).
//   [2] "la hitbox para commons se activa muy tarde nada mas se activa
//   al finalizar cuando deberia estar activo hasta que ella termine
//   dicho movimiento" — la esfera 100 se media contra los PIES de las
//   victimas mientras Blaze vuela con arco a +40 del suelo: a mitad del
//   vuelo la distancia 3D pasaba de 100 y solo conectaba al caer AL
//   FINAL. FIX: Blaze_ScanEnemyPath — se BARRE el segmento recorrido en
//   cada tick (mata los huecos: 102u por tick de 10Hz a 1022 u/s; el
//   javelin 100u por tick de 30Hz) y se compara contra el CENTRO del
//   cuerpo (+40z). Aplica a kick, dash (ventana y drain) y javelin.
//   [3] "la patada regresara un 65% de enfriamiento" por acierto —
//   convar blaze_kick_cdrefund 0.65: al ACERTAR el kick el cd de
//   aterrizaje se reduce al 35% (17 -> 5.95s antes de blaze_cd_scale);
//   el fallo conserva su cd completo. Solo la patada (el dash no).
// v3.77.77 (2026-10-15) — EL FUEGO DEL SOL DASH SE VE
//   Reporte del owner tras la .76 (el cono del Sol Flame ya visible):
//   "el sol dash le falta el fuego que deberia rodearla a blaze cuando
//   hace la habilidad... tambien es invisible". AUTOPSIA: mismo patron
//   familiar que la _occlusion pero mecanismo DISTINTO — la
//   inferno_wall_primary SI es la capa de llamas del muro del molotov,
//   PERO es un sistema de MURO: dibuja el fuego ENTRE su punto de
//   origen (CP0) y un SEGUNDO punto (cpoint1 = info_particle_target).
//   La v2.2 la parentaba SOLA al cuerpo de Blaze — sin segundo punto
//   el muro no tiene tramo que dibujar y NO renderiza NADA (el cono
//   v2.3 se salvo justamente cableando el cpoint1 tramo a tramo).
//   FIX Blaze v2.4-OM: el fuego del cuerpo ahora son DOS capas de los
//   fuegos ambientales de los mapas (env_fire_*: solo CP0, SIEMPRE
//   visibles, en LOOP — la misma receta a prueba de balas del cono):
//   env_fire_medium al TORSO (+40u, la llama que la envuelve) +
//   env_fire_small a los PIES (+8u, la base hasta el suelo), ambas
//   parentadas a Blaze durante todo el vuelo y removidas SIEMPRE al
//   terminar (impacto / ventana / drain / cancel / muerte / mapa /
//   tope OnUser1 25s). Convars nuevos: blaze_fx_dash_name
//   (env_fire_medium) / blaze_fx_dash_name2 (env_fire_small; vacio =
//   solo torso). Cero cambios de logica: el dash (velocidad / dano /
//   stun / quema / drain / cooldowns) queda INTACTO.
// v3.77.76 (2026-10-15) — LA LLAMARADA DEL SOL FLAME SE VE
//   Reporte del owner tras la .75: "la sol flame no aparece el grafico
//   que pedi... sigue siendo invisible" (el juego ya entraba normal:
//   el fix del Engine Error funciono). AUTOPSIA: la v2.2 cableaba el
//   cono con inferno_wall_occlusion — el nombre EXISTE en L4D2 (esta en
//   la lista oficial de particulas del VDC/AM) pero es la CAPA DE
//   OCLUSION del muro de fuego del molotov: la mascara tecnica que
//   oculta la geometria DETRAS del fuego, no las llamas (familia
//   completa: inferno_wall_primary = llamas / _smoke = humo /
//   _refraction = distorsion de calor / _occlusion = mascara / _low /
//   _tiled = variantes). Por eso la habilidad funcionaba (dano, empuje,
//   quema) sin ningun grafico. FIX Blaze v2.3-OM: el cono ahora son 4
//   tramos (boca/170/340/510/650u) con env_fire_large (boca) +
//   env_fire_medium (tramos) — las particulas de los fuegos ambientales
//   de los mapas: solo dependen de CP0, SIEMPRE visibles — y cada tramo
//   lleva cpoint1 al punto siguiente (la receta de la lengua del
//   pet_christmas v2.6 de este server), de modo que poner
//   blaze_fx_flame_name inferno_wall_primary dibuja el MURO entero
//   entre punto y punto si el owner prefiere ese look. Convars nuevos:
//   blaze_fx_flame_name (env_fire_medium) + blaze_fx_flame_mouth
//   (env_fire_large). Cero cambios de logica: cono/dano/quema intactos.
// v3.77.75 (2026-10-15) — FIX DEL ENGINE ERROR "UserMessageBegin"
//   Reporte del owner (captura 2026-10-14): dialogo del motor
//   "UserMessageBegin: New message started before matching call to
//   EndMessage" + "a veces el left parece crashear". AUTOPSIA: el
//   panel de estados de la v3.77.72 (sm_omhud) escribia el KeyHintText
//   con PbSetString — la API de PROTOBUF de CS:GO. L4D2 usa
//   usermessages de BITBUFFER (BfWrite, como todos los plugins de este
//   server: el Shake del OM_Stun, el VGUIMenu del bot_takeover, el
//   SayText2 del survivor_chat_select...). Resultado: error nativo en
//   runtime -> el callback abortaba ANTES del EndMessage() -> el
//   mensaje quedaba ABIERTO en el motor -> el SIGUIENTE usermessage de
//   cualquier plugin o del propio juego (chat, menus, hints) dispara
//   EXACTAMENTE ese error del motor. Se disparaba en el primer tick
//   del timer (0.5s) al jugar Sonic/Blaze/Silver/Cream/Eggman (los
//   unicos con linea de panel). FIX: OM_SendKeyHint ahora escribe
//   BfWriteString (la receta del PrintHintText del halflife.inc
//   oficial) + EndMessage. El panel queda identico (persistente,
//   sm_omhud 0 lo apaga) — solo cambia COMO se escribe el mensaje.
//   Nota: este bug venia HEREDADO de la base 3.77.72 en TODAS las
//   builds anteriores (3.77.73/3.77.74 incluidas) — esta lo corrige.
// v3.77.74 (2026-10-15) — LA TORMENTA ELECTRICA DE METAL
//   Pedido del owner: "ok ahora falta algo para que acompañe al efecto
//   de metal sonic... aparte del efecto que ya tiene se le añadira los
//   efectos: mientras lleva a la victima efx_arc_new1, efx_arc_new1_XXL
//   y efx_arc_new1_XXL2; cuando este impacte a la pared con el enemigo
//   generara el efecto electrical_arc_01_system; y cuando metal
//   empieze a moverse con su destructive en su Torso nasera el efecto
//   flame_blue — y ya sabes el efecto terminara cuando metal se detenga
//   o tecnicamente estrelle a la victima hacia la pared". Metal.inc
//   v5.9-OM -> v6.0-OM, LA CAPA DE PARTICULAS del Destructive Charge:
//   [F1] flame_blue PARENTADA al torso de Metal (z +40 — el patron del
//   flame_blue del airstrike de ESTE server, parentado al proyectil en
//   vuelo) desde que DESPEGA la embestida (transicion WINDUP->DASH =
//   "cuando empiece a moverse") hasta que SE DETIENE: estampado contra
//   pared, rebote sin infectado, drop por cap de dano (especial y
//   witch), timeout del reloj y muerte/desconexion/mapa (ResetState);
//   si el arrastrado MUERE en sus manos la embestida CONTINUA (v5.8) y
//   la llama TAMBIEN. [F2] efx_arc_new1 + efx_arc_new1_XXL +
//   efx_arc_new1_XXL2, las TRES PARENTADAS a la VICTIMA (cliente
//   especial o witch) durante TODO el arrastre; mueren en la suelta
//   UNIVERSAL (Metal_ReleaseGrabbed: drop, cancel, muerte del
//   objetivo, atasco, timeout, slam-end) y al ARRANCAR el estampado.
//   [F3] electrical_arc_01_system one-shot en el punto de impacto con
//   la pared (hitPos + normal x 12, mirando HACIA FUERA del muro) al
//   iniciar el WALL_SLAM — la particula del pet_fusion v48 de este
//   server, ya montada y comprobada. Receta info_particle_system +
//   auto-kill por OnUser1 (cero handles vivos, patron Blaze_FX v2.2 /
//   Knux v63) + registro de nombres en ParticleEffectNames (no-op para
//   las stock). Kill-switch metalom_fx_charge 1 (0 = v5.9 exacto,
//   cero entidades nuevas; metalom_ = auto-guardado en Sonic_Suite.cfg).
//   CERO cambios de logica de la FSM: mismos estados, mismos timings,
//   mismos daños — solo la capa visual. UNICO archivo de logica que
//   cambia: include/Metal.inc (v6.0-OM).
// v3.77.73 (2026-10-15) — EL FUEGO SE VE + EL STUN INTERRUMPE
//   Pedido del owner: (1) "el javelin no se ve y el flame tampoco se
//   ve" — autopsia: el harpoon002a del Lua vive en el VPK del SERVER
//   (FileExists lo ve) pero los archivos dentro de VPKs NO se
//   descargan a los clientes = prop SIN modelo client-side = INVISIBLE;
//   y el Sol Flame tenia CERO grafico (solo sonidos + empuje + fuego
//   por entidad). (2) La especificacion LITERAL de efectos del owner:
//   kick = molotov_explosion_burst3 SOLO al iniciar la carga +
//   molotov_explosion en el LUGAR del impacto; Sol Dash =
//   inferno_wall_primary PARENTADA al cuerpo durante el efecto (con
//   remocion garantizada al terminar: impacto / fin de ventana / drain
//   agotado / cancel / muerte / mapa) + al impactar una de las 4
//   molotov_burst AL AZAR sobre el enemigo; Sol Flame =
//   inferno_wall_occlusion por segmento a lo largo del cono (pitch por
//   convar blaze_fx_flame_pitch -90 = acostado al frente; VERIFICAR
//   con el fxtest.smx); javelin = molotov_trail (la estela del coctel
//   del motor) PARENTADA al arpon = SIEMPRE visible aunque el modelo
//   no llegue al cliente. (3) "todas las habilidades tendra dano aoe a
//   commons incluso si impacta contra un SI la explosion tendra un
//   efecto en area (pero el efecto de explosion solo sera Para el SI y
//   no para los commons — si no habria lag de muerte)": kick/dash/
//   javelin explotan con dano en radio a commons/witch (blaze_aoe_
//   radius 250 / blaze_aoe_damage 80, via OM_AbilityDamage = el
//   amplificador del suite incluido) + pasada de dano por swoosh del
//   Sol Flame (blaze_solflame_conedmg 20); CERO particulas por common
//   — la explosion visual vive UNA vez, en la victima. (4) El javelin
//   ahora hace DAO al engancharse (blaze_javelin_damage 45; antes solo
//   arrastraba). (5) "El Stun de OM no produce stagger al enemigo? ...
//   el tank sigue lanzando la roca o el hunter aunque le pegues te
//   puede agarrar igual" — OM_Stun v2.3: el congelado detiene el
//   CUERPO pero NO la ACCION en curso (el action system del motor
//   sigue vivo bajo FL_FROZEN); STAGGER AL ENTRAR: en la primera
//   aplicacion, ANTES de congelar, L4D_StaggerPlayer (OnStaggered =
//   LA rutina que ABORTA la accion: la roca se suelta, el pounce se
//   corta en el aire, la lengua se libera, el charger frena) + la red
//   de seguridad del SI_Stagger; convar om_stun_interrupt 1 (0 =
//   comportamiento v2.2). Blaze v2.2-OM + OM_Stun v2.3 + fxtest.smx
//   (plugin aparte: sm_fxt <efecto> [pitch] [vida] para verificar el
//   cono a 90 grados en el server del owner).
// v3.77.72 (2026-10-14) — EL PANEL DE ESTADOS + EL ESCUDO QUE BLOQUEA + EL BOOST A 650
//   Pedido del owner: (1) "a veces el left parece crashear despues de la
//   ultima update" — AUDITORIA del kit 3.77.71: el stun del escudo de
//   Eggman se disparaba DENTRO del hook de dano (OM_Stun dispara
//   SDKHooks_TakeDamage y re-entraba al sistema de dano — la misma clase
//   de bug que la leccion Amy v106); ahora DIFERIDO con RequestFrame al
//   frame siguiente + Silver_RayFilter valida IsClientInGame antes de
//   GetClientTeam (slots conectando podian entrar al trazado).
//   (2) "la habilidad del escudo no esta sirviendo como 4 habilidad" —
//   FIX REAL: L4D2 manda la garra del comun y varios basicos de los
//   especiales con damagetype VACIO (0) — en GMod si vienen clasificados
//   como DMG_CLUB/SLASH/CRUSH. El bloqueo ahora cubre los 3 tipos fisicos
//   del Lua + EL CUERPO A CUERPO REAL de L4D2 (atacante del equipo
//   infectado cuyo inflictor es el mismo atacante); proyectiles y fuego
//   quedan fuera, como el cuerpo a cuerpo del Lua. Feedback "¡BLOQUEADO!".
//   (3) "la habilidad de velocidad de egman deberia aumentar la velocidad
//   asi como el Speed aumentar su velocidad a 650" — BOOST a 650 u/s de
//   VELOCIDAD OBJETIVO (convar eggman_boost_target; el multiplicador
//   lagged se calcula SOLO contra la velocidad max real del survivor).
//   (4) "el doble salto debe ganar mas postencia ya pasivamente" — vz
//   400 -> 550 (eggman_jet_force) en el Eggmobile Jet de Eggman.
//   (5) "los enfriamientos de la habilidades de blaze reducen un 50%
//   (para poder limpiar sombies)" — convar blaze_cd_scale 0.5 aplicada
//   a TODO el kit de Blaze (kick/dash/javelin/solflame).
//   (6) "los enfriamientos de cream blaze eggman y bueno silver deben
//   verse ya que no se ven" + "mejor interfaz gui y demas que puedan
//   mostrar los estados. Ejemplo la evasion de sonic que esa ventana
//   sea siempre visible para que se pueda ver la eva del mismo. o
//   cuandta llama de blaze lleva acumulada y cosas asi" — OM STATUS
//   HUD: panel KeyHintText SIEMPRE VISIBLE (sm_omhud, 0.5s) con las
//   pasivas y cooldowns del personaje ACTIVO — Sonic: EVA (anillos +
//   gracia + dodge), Blaze: LLAMA SOL + Z/X, Silver: ENERGIA + Z/X/C +
//   barra de levitacion, Cream: Z/X/C, Eggman: Z/X/C/B + doble salto.
//   Ademas: feedback de recarga en el centro de la pantalla al pulsar
//   una habilidad en enfriamiento (patron Chaos Snap de Shadow).
// v3.77.71 (2026-10-14) — EL KIT GMOD DE BLAZE, SILVER, CREAM Y EGGMAN
//  (pedido del owner: "es hora de que les coloques las habilidades del
//  Gmod que tiene pasivas y eso" + "lo de los graficos debes conservar
//  las que el codigo dice ya que en si existen las tengo en mi pack de
//  texturas" — con los 118 Lua del addon OM reenviados por transfer).
//  FUENTE: register_noodles_blaze.lua (870L) + survivors2.lua L46-1569
//  (Blaze) + L1620-2316 (Cream) + register_noodles_silver.lua +
//  pills_survivors_silver.lua (1612L) + survivors2_eggman.lua (699L).
//  Todos los NUMEROS son los del Lua; convars con sus defaults.
//  (1) BLAZE v2.0-OM: pasivas METER SOLFLAME 0-100 [+35 kick/dash,
//      +15 javelin; >=50 = modo Sol con QUEMA real (IgniteEntity)]
//      + IFRAMES mientras cualquier estado activo (el OM_Damage_
//      Reduction 0 + iframes2 +0.75 del Lua). Z tierra = Roundhouse
//      Kick (carga beeps, vuelo, esfera 100, stun 4s + 25, empujon
//      600/1000, rebote propio; acierto cd 17 / fallo Roll + cd 25);
//      Z aire = Sol Dash (carga congelada, 1400 u/s a la mira; con
//      Sol>=50 = DrainDash sostenido); X = Burning Javelin (harpoon
//      3000 u/s que ARRASTRA al objetivo 0.5s — el Think del Lua) /
//      Sol Flame (cono 650u/50 grados que quema 1.35s y empuja,
//      drena 2.5/s). Javelin con think 30 Hz propio.
//  (2) SILVER v2.0-OM: pasivas ENERGIA 0-100 (regen 5/s) + VIDA MAX
//      105 (receta Rouge). Z = Suspension en ciclo (hover -> AGARRE
//      telekinetico [colgado +70z congelado, tinte CYAN, drena 6/s]
//      -> lanzamiento aim*2000, cd 17); X = Rocks (hasta 3 orbitando,
//      throw 2500, stagger por acierto, 3er = stun 3s+15, cd
//      15+5*aciertos); C = Time Reversal (10 registros, -10/tick,
//      rebobinado 0.09s/salto, cancel por dano cd 25 / completo cd
//      15); SPACE aire = LEVITACION (barra 20, 9.4/s, cd 8). Think
//      de la roca lanzada 30 Hz propio.
//  (3) CREAM v7.1-OM: C = EL DASH DEL LUA (la T que faltaba): impulso
//      500+145, esfera 90, knockback dir*900+200z, rebote propio,
//      +5s speed boost 1.6x, COSTE 20 de dano propio, pared = rebote
//      + Wallhit. Heal alineado al Lua: radio 90 (era 350) y 7 ticks.
//  (4) EGGMAN v5.0-OM: C = JETPACK BOOST (3.75s a 2.0x, cd 22 — la E
//      del Lua) + B = SOAPY SHIELD (5s bloqueando CLUB/SLASH/CRUSH,
//      atacante 1s de stun, +0.25s por bloqueo, cd 26/35 popped — la
//      T del Lua) + doble salto alineado (vz 400 conservando la
//      horizontal, cd 10 — antes 320/+200/cd 2) + VOICELINES del fin
//      de persecucion (1 de 9 al azar, la 700u del Lua).
//  SONIDOS: los EXACTOS del Lua (om/blaze, om/silver, om/cream,
//  om/eggman) con PROBE DUAL por FileExists (om/ minuscula primero,
//  luego OM/ como escribe el Lua) — sin pack: el kit funciona igual
//  en silencio y el log del server lo dice al arrancar el mapa.
//  GRAFICOS (conservados como el codigo los pide): tinte ROJO (Blaze)
//  y CYAN (Silver/Eggman-shield) sobre el avatar = el glow del Lua;
//  QUEMA = IgniteEntity (el fuego REAL del motor); rocas/javelin con
//  los modelos del Lua en cadena FileExists -> nativas de L4D2;
//  concrete_break2 del motor en el impacto de las rocas (el mismo
//  que usa el Lua); glow nativo del suite para las pulsaciones.
//  INTEGRACION: manager Z/X/C/B dispatch (Blaze/Silver/Cream/Eggman),
//  CleanupCharModuleState + reset de kit en muerte/cambio, textos de
//  seleccion, sm_sjsver reescrito (14 %s / 14 args verificado).
// v3.77.70 (2026-10-14) — BLAZE Y SILVER AL MENU DE PERSONAJES
//  (pedido del owner: "hace falta anadir a blaze y a silver en la
//  lista de personajes seleccionables") — de personajes CST de SOLO
//  MODELO a personajes COMPLETOS del manager: 13 lineas en el menu
//  (sc / sm_sonicmenu).
//  (A) INDICES SEGUROS: BLAZE_INDEX 11 y SILVER_INDEX 12 se ANEXAN
//      despues de Sage — NINGUN indice existente se mueve, asi las
//      cookies de personaje de todos los jugadores siguen validas
//      (un Sage guardado como 10 sigue siendo Sage; nadie amanece
//      con el personaje cambiado). MAX_CHARS 11 -> 13.
//  (B) LA CADENA COMPLETA YA EXISTIA: seleccionar = MenuHandler_Char
//      -> OnPlayerSelectCharacter -> FireCharSignal -> la clave CST
//      de g_sCstCharKeys ("blaze"/"silver") -> el guard embebido
//      aplica blaze.cfg / silver.cfg EN EL ACTO (LLAMADA DIRECTA
//      v3.77.55) -> el modelo CST entra -> el avatar espejo se monta
//      solo por deteccion de modelo (FSM 10 Hz de su modulo). CERO
//      logica nueva: era poner la linea en el menu y la clave en la
//      tabla. Los avatares siguen siendo el 10o y 11o del suite.
//  (C) LO QUE NO CAMBIA: la deteccion POR MODELO de Blaze/Silver
//      sigue intacta (sm_blaze / sm_silver manual o mapa de slots
//      CST montan el avatar igual, con o sin linea de menu) y la
//      REGLA DE YIELD tambien (otro personaje del manager con avatar
//      propio + modelo blaze/silver puesto encima = manda el avatar
//      del personaje seleccionado; Blaze/Silver seleccionados NO
//      ceden — son la identidad). Exclusividad de slot igual que los
//      demas: un Blaze y un Silver por server via menu (el modelo CST
//      manual sigue siendo ilimitado como siempre).
//  (D) GAMEPLAY: CERO habilidades (personajes de modelo puro): Z/X/C
//      responden con un aviso claro en vez del mensaje generico;
//      CleanupCharModuleState baja su avatar EN EL ACTO al cambiar
//      de personaje o desconectar (antes esperaba al tick de la FSM).
//      Cookie persistente y reconexion igual que los otros 11.
//  (E) INTEGRACION: AvatarHide v1.4 (la señal de personaje ahora
//      oculta el equipo AL INSTANTE para CREAM/EGGMAN/BLAZE/SILVER —
//      antes solo entraban por el estado real del prop del timer de
//      0.2s; el timer se AUTO-CORRIGE si el .mdl no esta y el avatar
//      nunca monta, tras 1.5s de gracia); PathSense acepta blaze y
//      silver como claves de pathsense_chars (auto-adaptado por
//      MAX_CHARS); el guard ya los traia en su mapa oficial de 14
//      perfiles (blaze.cfg / silver.cfg).
//      Blaze.inc / Silver.inc v1.1-OM: SOLO comentarios y version
//      (documentan la linea de menu nueva); cero cambios de logica.
// v3.77.69 (2026-10-14) — LOS AVATARES DE BLAZE, SILVER Y DR. EGGMAN
//  (pedido del owner: "hay que anadir ahora el avatar de baze silver
//  y el dr eggman") — 3 avatares nuevos de un tiron: el suite pasa de
//  8 a 11 avatares.
//  (1) EGGMAN v4.0-OM (9o avatar, patron Cream v7.0-OM textual sobre
//      su modulo existente): eggman.mdl espejo R/L + FSM 10 Hz POR
//      PROBE (idle/walk/run/jump/fall + lowhealth<=40 + downed) +
//      ONE-SHOTS propios: el JET del doble salto (hover/jet si el
//      .mdl los trae), el despliegue de MINAS y el LASER con lock
//      2.2s que cubre la carga del telegrafo (2s) + disparo. La
//      MUERTE del avatar en el POST propio (Eggman_Event_PlayerDeath;
//      Eggman_OnPlayerDeath queda en puro reset — leccion Rouge
//      v3.77.49). #include <Eggman> MOVIDO antes de <Rouge> para que
//      el OnEntityCreated central lo despache (cero refs cruzadas
//      Rouge/Sage<->Eggman verificadas). Convar eggman_avatar 1.
//  (2) BLAZE v1.0-OM (10o avatar, MODULO NUEVO): Blaze es un
//      personaje CST DE MODELO (sin linea en el menu del manager: se
//      aplica con sm_blaze o el mapa de slots del CST) — deteccion
//      POR MODELO (survivor_blaze*.mdl aplicado => avatar espejo,
//      sin importar quien lo aplico) + YIELD: si el jugador tiene un
//      personaje del manager CON AVATAR propio seleccionado (Sonic/
//      Tails/Knuckles/Amy/Shadow/Rouge/Cream/Metal/Eggman), ese
//      avatar manda — el personaje seleccionado es la identidad; el
//      modelo CST encima es solo skin. Sally y Sage NO tienen avatar:
//      con ellos (o "Sin personaje") el avatar de Blaze SI sale.
//      blaze.mdl espejo R/L + FSM 10 Hz POR PROBE (idle/walk/run/
//      jump/fall + lowhealth<=40 + downed) + ragdoll de muerte 15s +
//      anti-corpse + adopcion + pulso de pausa + aviso 1 vez por
//      mapa. CERO gameplay (el personaje es modelo CST puro).
//      Convar blaze_avatar 1.
//  (3) SILVER v1.0-OM (11o avatar, MODULO NUEVO): idem Blaze con
//      survivor_silver.mdl / silver.mdl. Convar silver_avatar 1.
//  INTEGRACION (los 3): Rouge.inc despacha sus OnEntityCreated
//  (anti-corpse); AvatarHide v1.3 (los 3 con avatar = equipo
//  oculto); Anti caida v3.3 (los 6 targetnames nuevos: avatar vivo
//  = 0 dano de caida); OM_SweepOrphanAvatars + OM_IsTrackedAvatarRef
//  registran los 6 nombres nuevos — GAP FIX: Cream faltaba en
//  ambos desde la 3.77.68 (la adopcion propia lo cubria en
//  caliente, pero el barrido del arranque de mapa no la veia);
//  OnPluginStart/OnMapStart/OnMapEnd/OnPluginEnd cableados. Los
//  modelos viven en models/Noodles/OM/ (el mismo pack OM de los
//  otros avatares): FileExists — sin los archivos TODO cae al
//  survivor normal, CERO dependencia, y una linea en el log del
//  server al arrancar cada mapa dice si cada .mdl esta o no.
//  REQUISITO: eggman.mdl / blaze.mdl / silver.mdl en el VPK OM.
// v3.77.68 (2026-10-14) — EL AVATAR DE CREAM (8o avatar del suite).
//  Pedido del owner: "el siguiente avatar es Cream". Cream.inc v6.1
//  -> v7.0-OM: cream.mdl espejo R/L (models/Noodles/OM/ del VPK,
//  FileExists: sin el archivo TODO cae al survivor normal, CERO
//  dependencia) + FSM 10 Hz POR PROBE (receta Amy v92/Shadow v6.0:
//  idle/walk/run/jump/fall + FLY DE OREJAS [el glide de SPACE, su
//  pasiva existente] + lowhealth<=30 [el umbral de Cheese desmayado]
//  + downed + one-shots CURA/RESURRECCION sobre las DOS copias) +
//  ragdoll de muerte 15s + ventana anti-corpse 2s + adopcion de
//  huerfanos + pulso de pausa + tinte DORADO del avatar en la
//  inmunidad post-resurreccion (el tinte del survivor era invisible:
//  el cuerpo esta RENDER_NONE con el avatar montado).
//  INTEGRACION: (1) la MUERTE vive en el POST propio del modulo
//  (Cream_Event_PlayerDeath — leccion Rouge v3.77.49: ni el PRE ni
//  el POST del manager tocan el avatar; Cream_OnPlayerDeath queda en
//  puro reset; NUEVO Cream_OnPluginEnd para el restore del cuerpo al
//  descargar); (2) Cream_OnEntityCreated en el despacho central de
//  Rouge.inc (include de Cream movido ANTES de Rouge por eso);
//  (3) AvatarHide v1.2: Cream con avatar = equipo oculto (la regla
//  del owner); (4) Anti caida v3.2: cream_avatar_om/_l en su lista
//  de nombres (avatar vivo = 0 dano de caida); (5) Cream_OnMapEnd.
//  Convar cream_avatar 1 (auto-guardada en Sonic_Suite.cfg).
// v3.77.67 (2026-10-14) — FIX DEL SPAM DE ERRORES DEL PATHSENSE
//  (log del server: «Exception reported: Client 2 is not connected
//  / [0] IsFakeClient / [1] Line 312, PathSense.inc::T_PathSenseTick»
//  repetido CADA SEGUNDO tras desconectarse un jugador — un tick
//  por segundo, para siempre). ROOT CAUSE: el latido de 1 s del
//  PathSense validaba al cliente en el orden INVERSO —
//  IsFakeClient(i) ANTES de IsClientInGame(i) — e IsFakeClient
//  EXIGE cliente conectado: cualquier slot vacío o recién
//  desconectado (los bots SÍ cuentan como conectados) lanzaba la
//  excepción en CADA tick del timer; lo mismo en el hook de cvars
//  (PS_OnCvarChanged). FIX: el mismo orden seguro que TODO el
//  resto del suite (!IsClientInGame || IsFakeClient —
//  cortocircuito: si no está en juego, IsFakeClient ni se evalúa).
//  PathSense v1.0 -> v1.1 + sonda propia en sm_sjsver. CERO lógica
//  nueva.
// v3.77.66 (2026-10-14) — DOS FIXES DEL OWNER EN UNA RONDA (CERO
//  lógica nueva del manager: versión, changelog, sonda del Music
//  Director actualizada a la 1.5.0 y sonda nueva del AvatarHide).
//  [A] MUSIC DIRECTOR v1.5.0 (ACOMPAÑA esta build): "cuando se coloca
//      una musica en el reproductor por alguna razon dispara la musica
//      del tank y luego el watchdog lo quita pero despues lo vuelve a
//      poner, lo quita y asi; y cuando le doy para a la musica queda
//      sonando la que puse y no para". ROOT CAUSE: el RADAR de sonido
//      abria la etapa TANK a ciegas (solo por OIR un sample nativo del
//      tank, sin tank vivo real) → el watchdog la cerraba a los ~2s →
//      el anti-rebote del radar (3s) la volvia a abrir → loop eterno
//      tank→cancion→tank. FIX: TriggerTankStage EXIGE tank VIVO
//      (re-check diferido 1.5s por si la musica precede al spawn del
//      bot; sm_playtank/sm_nexttank exentos) + "Detener la musica
//      para todos" mata tambien pausa/reanudacion (stop-global fuera
//      del resume) + cancion NUEVA descarta la pausa de la vieja.
//  [B] AVATARHIDE v1.1 (embebido — reemplazo de include y
//      recompilacion): "cuando el jugador recoje un arma del suelo sea
//      la que sea esa arma es visible y si cambio de arma esta vuelve
//      a ser invisible". ROOT CAUSE: el pickup EQUIPA Y DESPLIEGA el
//      arma en el MISMO frame y el cliente resuelve el world model
//      justo ahi; el timer de 0.2s ocultaba TARDE y el cliente no
//      re-lee m_iWorldModelIndex hasta el proximo deploy. FIX: hooks
//      WeaponEquipPost + WeaponSwitchPost por cliente (mismo frame del
//      equip/deploy — la receta del propio Anti_Pose del owner) +
//      re-ocultacion al frame siguiente; el timer queda de red de
//      seguridad.
// v3.77.65 (2026-10-14) — PATHSENSE + CFG POR CATEGORÍAS, REINTEGRADAS
//  ENCIMA DE LA 3.77.64. Contexto: el árbol local avanzó de la 3.77.58
//  a la 3.77.64 (sm_defensas, Amy v107/v108, Rouge v10.5, Knuckles v77,
//  Metal v5.8/v5.9, OM_Stun v2.2, sonic.inc v6.35 con las DOS COMPARTIDAS
//  y la sonda del Music Director v1.4.0) sobre una base ANTERIOR a la
//  3.77.59 de este lado, y en ese salto se quedaron fuera DOS capas que
//  la 3.77.59 había instalado en el manager. Esta versión las reintegra
//  SIN tocar nada de la 3.77.64 (CERO retroceso: TODO lo de la 3.77.64
//  va intacto; la 3.77.64 ya compila sola — las dos compartidas viven en
//  el sonic.inc v6.35 del propio árbol):
//    (1) PATHSENSE, «Sentido de la Ruta» (pasiva de camino al refugio u
//        objetivo): #include <PathSense> + PathSense_Init() en
//        OnPluginStart ANTES del AutoExecConfig y del enganche del
//        auto-guardado (así pathsense_* nace dentro del Sonic_Suite.cfg)
//        + PathSense_OnCharSignal en el MISMO FRAME de la señal CST +
//        PathSense_OnMapStart/OnClientDisconnect + bloque PathSense en
//        el sm_sjsver. g_sCstCharKeys pasa de static a public
//        (PathSense.inc lee las mismas claves). Requiere
//        l4d_path_to_goal.smx (independiente, ya está en el server).
//    (2) CFG ORDENADO POR CATEGORÍAS: SuiteCfg_Save reescrito (13
//        secciones en orden de menú + PATHSENSE + UTILIDADES; cada
//        cabecera dice a quién pertenece, qué hace y SUS comandos;
//        sección [?] final para prefijos nuevos; secciones vacías no se
//        escriben) y SuiteCfg_Reconcile delega en Save (el archivo se
//        reorganiza AL CARGAR sin perder los valores editados a mano).
//    (3) FIX del auto-guardado que la 3.77.58 arrastraba: los prefijos
//        shadow_ / metalom_ / om_air / pathsense_ NUNCA se auto-guardaban.
//        Y los NUEVOS de este árbol ya tienen sección: knu_ (counter v77
//        de Knuckles) y suite_ (amplificador suite_dmg_* de OM_Stun v2.2).
// v3.77.64 (CERO logica del manager — solo version, changelog y la
//  sonda del sm_sjsver) — ACOMPANA a l4d_MusicDirector.smx v1.4.0, el
//  SILENCIO QUIRURGICO (pedido del owner 2026-10-14: "quizas si anulamos el
//  metodo del music 0 podamos hacer un trabajo mas limpio ya que music 0
//  aunque sea una solucion viable temporal no es definitiva pues si la
//  musica empieza a sonar al menos por una fraccion de segundo y luego el
//  music 0 se activa entonses la musica nativa no podra ser detenida" +
//  "No deberia ser remplazada por la del tank ... la musica que suena para
//  todos se pausara o se reducira ... y cuando termine dejara la musica
//  anterior seguir como estaba" + "Nesesita mas opciones en su menu como
//  detener la musica para todos si se coloco una musica global" + "habia un
//  pequeno respeto por la musica del vomito de boomer eso en el tank wave
//  original lo respetaba, algo que con music 0 no se puede hacer").
//  RESUMEN v1.4 PARA EL OWNER:
//   (1) MUSIC 0 ANULADO (md_music_manager 0 default): el cvar solo apaga el
//       DESPACHADOR server-side — una pista nativa que arranque una
//       fraccion de segundo antes NO PUEDE SER DETENIDA y queda sonando
//       encima (el bug del rescate). Nunca mas se toca: en su lugar, EL
//       METODO DEL TANKWAVE GENERALIZADO. md_music_manager 1 = rollback.
//   (2) BLOQUEO PER-CLIENTE POR CATEGORIAS (TANK / HORDA / EVENTO / BOOMER):
//       mientras un cliente oye musica custom, la nativa de las categorias
//       activas NO LE LLEGA (se le quita de la lista de destinatarios); el
//       que no oye custom sigue oyendo al juego. El VOMITO DEL BOOMER SE
//       RESPETA como el tankwave original (md_respect_boomer) — el detalle
//       que con music 0 era imposible.
//   (3) CORTE PREVIO (MD_PreClearNative): antes de emitir una custom se mata
//       lo nativo que YA este sonando para ese cliente — la pieza que le
//       faltaba al MusicMapStart original (solo cortaba rutas del tank).
//   (4) ASEDIO DE 1s GENERALIZADO con dos perfiles: COMPLETO (tank/escape/
//       LMS: receta original intacta con truco del boomer) y QUIRURGICO
//       (menu/arranque/personal: solo stops por nombre, el boomer real no
//       se toca).
//   (5) PAUSA/REANUDACION DE LA MUSICA PARA TODOS: al llegar el tank (o
//       escape/LMS), la cancion puesta para todos se PAUSA y al morir el
//       ultimo tank VUELVE con el tiempo que le quedaba (md_menu_resume 1;
//       md_menu_resume_full 1 = vuelve completa). Honestidad de engine: no
//       hay seek en EmitSound (la cancion vuelve desde el principio) ni
//       ducking (el volumen se fija en la emision) — por eso lo honesto es
//       PAUSAR.
//   (6) MENU: nueva opcion "Detener la musica para todos" (activa o en
//       pausa; en pausa cancela la vuelta). sm_mdstatus muestra la pausa.
//   (7) md_native_debug 1: log de cada sample nativo para afinar la tabla
//       de horda/eventos con datos REALES del server (los nombres de evento
//       inexistentes son no-op gratis).
// v3.77.63 (CERO logica del manager — solo version, changelog y la
//  sonda del sm_sjsver) — ACOMPANA a l4d_MusicDirector.smx v1.3.0 (la
//  entrega del finale: musicas nuevas del escape normalizadas a -10
//  LUFS sin clipping + seleccion del escape SIN repetir la del final
//  anterior + anuncio de la cancion en el chat + md_volume_master).
//  El cambio real vive en el MusicDirector y en los MP3 normalizados;
//  el manager solo actualiza la expectativa de la sonda: esperado
//  1.3.0-unificado (era 1.2.0).
// v3.77.62 (Metal.inc v5.9-OM; CERO logica nueva del manager — solo
//  version, changelog y el texto de sm_sjsver) — FIX DEL LOOP ZOMBIE DEL
//  DASH DE METAL (reporte del owner 2026-10-13: "cuando la habilidad del
//  dash que tiene en la 1 habilidad termina el sonido del deslizamiento
//  sigue sonando no se detiene (esto no ocurre si este impacta contra
//  algo)"). AUTOPSIA: el StopSound del loop electrico ya corria en TODOS
//  los caminos de fin (timeout/rebote/estampado/drop/muerte/reset) — el
//  culpable era el WATCHDOG que re-emitia el metalchargeloopsound.wav
//  cada 3s "a ciegas": un wav con cue de loop horneada re-emitido sobre
//  el mismo canal NO siempre reemplaza a la instancia anterior en el
//  cliente, se APILAN copias, y cada resto solo muere con su propio
//  SND_STOP. Con impacto temprano (0-1 latidos) el stop final mataba la
//  unica instancia = todo bien; al agotarse los 8s (2-3 latidos
//  acumulados) quedaba loop zombie sonando para siempre. FIX EN 3 CAPAS
//  (Metal.inc v5.9): (1) watchdog STOP+EMIT — cada latido corta la
//  instancia viva y luego emite la nueva: el canal siempre tiene
//  EXACTAMENTE una; (2) arranque STOP+EMIT — la transicion WINDUP->DASH
//  limpia restos de una carga anterior antes de emitir, y el fallback
//  electric_loop.wav pasa de SNDCHAN_AUTO (0 = el motor elige canal: el
//  stop sobre 0 podia no apuntar al canal real) a SNDCHAN_STATIC
//  explicito; (3) doble golpe diferido — Metal_StopLoopSound re-stoppa
//  todo a los 0.25s (timer T_MetalLoopRestop con guard de estado) +
//  refuerzo per-cliente con SND_STOP explicito (no-op silencioso si ya
//  no suena: reintentar es gratis).
// v3.77.61 (CERO logica del manager — solo version, changelog y la sonda
//  del Music Director en sm_sjsver; EL CAMBIO REAL VIVE EN
//  l4d_MusicDirector.smx v1.1.0) — FIXES DE MUSICA pedidos por el owner
//  tras la primera ronda del director (2026-10-13):
//   (1) LOOP DEL TANK: la cancion del tank se re-emite SOLA al terminar
//       (antes quedaba silencio hasta que muriera el tank). Duracion
//       exacta por cancion con el formato OPCIONAL
//       "ruta.mp3 TAG- Nombre-segundos" en tank_wave_sounds.txt (el mismo
//       de music_mapstart.txt; la lista actual tal cual sigue valiendo);
//       sin TAG- usa md_loop_fallback (120s de fabrica — subelo si la
//       cancion se corta, bajalo si queda silencio entre vueltas);
//       md_tank_loop 0 = modo viejo. El loop tambien cubre escape y LMS
//       con cancion (no tienen fin natural de etapa).
//   (2) JERARQUIA FINAL: LMS (MDST_LMS, prio 55) POR ENCIMA del escape
//       (50) y POR DEBAJO de la victoria (60) — el LMS reemplaza al
//       escape, la victoria reemplaza al LMS. Etapa nativa nueva (8) +
//       sm_musicstage 8 + MD_PRIO_LMS en MusicDirector.inc.
//   (3) ESCAPE EXCLUSIVO: mientras suena el escape NO suena nada mas —
//       ni un tank nuevo (etapa rechazada por prioridad) ni la musica
//       NATIVA del juego (el silenciador de 1s + bloqueo de samples del
//       tank corren tambien en ESCAPE y LMS). Solo LMS o victoria
//       reemplazan al escape. Las musicas personales se cortan al entrar
//       cualquier etapa global.
//   (4) DETECCION MEJORADA: radar de TANK por sonido (la musica nativa
//       delata un tank aunque el evento tank_spawn se pierda — spawns por
//       vscript; md_tank_radar), watchdog del tank (etapa viva sin tanks
//       = cierre con fade en ~2s), victoria por finale_vehicle_leaving
//       ademas de finale_win, escape por gauntlet_finale_start (los
//       finales gauntlet: atrio/milltown/bridge/port), y los handles de
//       los timers NO_MAPCHANGE se sueltan en OnMapEnd (matar un handle
//       cerrado por el motor era un error latente).
//  sm_sjsver ahora reporta la version REAL del Music Director cargado
//  (via l4d_musicdirector_version) — debe decir 1.1.0-unificado.
// v3.77.60 (Amy.inc v108-OM; Metal.inc v5.8-OM; Sonic_ability_manager;
//  SIN CAMBIOS en Rouge/Knuckles/sonic/cstguard; + NUEVO MusicDirector.sp
//  aparte) — LA B DECIDE, EL BUMERAN GIRA DE VERDAD, METAL NO FRENA Y EL
//  CUADRO DE DEFENSAS (6 pedidos del owner 2026-10-13):
//   (1) LA B DE AMY (sm_sjs_ability4) YA NO ES DE LAS CARTAS DEL SUPER
//   TANK: ahora ALTERNA POR JUGADOR entre modo BUMERAN y modo COMUN del
//   martillo lanzado (sin cooldown: preferencia como la C; sobrevive
//   respawns; amyom_boom_mode queda como default de fabrica). Las cartas
//   del super tank siguen vivas en consola (sm_amysupertank). El ataque
//   impulso/area de la C queda INTACTO.
//   (2) TIPO DE DANO: el martillo en modo BUMERAN pega DMG_SLASH (CORTE)
//   en especiales/tank y comunes; el tiro clasico conserva DMG_CLUB.
//   (3) BUFF A METAL: si el objetivo ARRASTRADO muere en sus manos, la
//   embestida YA NO SE CANCELA — vuelve al estado DASH puro (misma
//   velocidad, puede atrapar OTRO objetivo, rebota en pared, termina al
//   agotar su reloj). NO aplica tras estrellarlo contra la pared: el
//   WALL_SLAM (modo embiste final) sigue su curso de siempre. Vale para
//   especiales y para la witch.
//   (4) ROTACION REAL DEL BUMERAN + ALCANCE +55%: la ida gira con la
//   receta del RETORNO (TeleportEntity con yaw avanzando a
//   amyom_boom_spin deg/s — el motor hace pPhys->SetPosition: el angulo
//   ESCRITO es el que se ve; cero dependencia del SDKCall) y la velocidad
//   re-afirmada en el mismo call. amyom_boom_dist 1500 -> 2325 de fabrica
//   (si tu cfg guardo el 1500, actualizalo a mano).
//   (5) CARTAS DE AMY SIN MENTIRAS: cada carta describe EXACTAMENTE lo
//   que hace (la Luna muestra su tirada CONCRETA de ese robo; el Sol
//   detalla cura/radio/tope; Fuerza/Emperador/Loco dicen stun + dano
//   RECIBIDO + velocidad reales), en cooldown la X re-muestra la mano
//   vigente, y el announce apunta al cuadro nuevo.
//   (6) NUEVO sm_defensas: el CUADRO que muestra la REDUCCION DE DANO
//   de TODOS los supervivientes vivos (Amy: cartas + Furia; Metal:
//   pasiva 50% / INMUNE durante embestida; Rouge: escalones 20/35/50%
//   segun vida; Shadow: anillos inhibidores; Knuckles: cargando; el
//   resto sin reduccion). Ademas: MusicDirector.sp (ENTREGA APARTE)
//   unifica l4d_tank_wave_sound + l4d_MusicMapStart con etapas de
//   combate y API para el futuro LMS.
// v3.77.59 (Amy.inc v107-OM; Rouge.inc v10.5-OM; Knuckles.inc v77-OM;
//  sonic.inc v6.35-OM; OM_Stun.inc v2.2; SIN CAMBIOS en cstguard) — EL
//  BUMERAN, LOS AUTOS, EL GOLPE QUE LANZA Y EL AMPLIFICADOR (pedido del
//  owner 2026-10-13): (1) BOOMERANG HAMMER — la V de Amy gira plano,
//  mantiene el rumbo y vuelve sola al llegar a amyom_boom_dist (golpea
//  en ida Y vuelta; amyom_boom_mode 0 = tiro recto clasico); (2) AUTOS —
//  el martillo mueve objetos con V (receta del aura) y un auto en
//  movimiento que roza un especial lo ragdollea 4s / tank 3s, 1 vez por
//  auto por lanzamiento; (3) CONTRA VERTICAL de Amy + STUN-RAGDOLL en las
//  contras de Rouge (patada baja) y Knuckles (uppercut) — cada una con
//  direccion propia y convars de fuerza; (4) AMPLIFICADOR HIBRIDO de
//  dano del suite (suite_dmg_scale x2 + suite_dmg_boss_pct 3.5% vs
//  +1000hp: tank/meatwall/scp) via OM_AbilityDamage; (5) LIMPIEZA: 25+
//  funciones muertas retiradas (auditoria de 1-aparicion, 7 includes).
// v3.77.58 (Amy.inc v106-OM; sonic.inc v6.34-OM y cstguard.inc v3.0.4
// SIN CAMBIOS) — EL VUELO REAL DEL IMPACTO DEL MARTILLO (reporte del
// owner 2026-10-13: "el empuje del martillo aun sigue siendo = la fuerza
// no lanza al oponente... el enemigo no sale volando hacia atras ni
// tampoco pareciera reaccionar como deberia cuando el martillo le pega
// estando inmovil"). Autopsia del v105 — el impulso se moria por DOS
// caminos independientes, ambos cerrados en Amy.inc v106:
//   (A) COMUNES: el v105 hacia TakeDamage(500) + TeleportEntity(vel) al
//   cuerpo YA MUERTO — pero el ragdoll de muerte de un comun de L4D2
//   es DEL LADO CLIENTE: esa velocidad no la hereda nadie y el comun
//   se desploma normal. Ahora usan la RECETA ROUGE v10.4 (la que el
//   owner ya ve volar comunes con el Barrido): copia prop_ragdoll del
//   cuerpo LANZADA con el impulso direccional GMod (Sonic_RagPhysLaunch
//   por hueso; plan B Sonic_RagFlingEngine) + BecomeRagdoll en el comun
//   real + limpieza de la copia a los 3s. Sobrevive al dano: empujon.
//   (B) ESPECIALES/TANK/WITCH: el impacto se procesaba INLINE dentro del
//   callback del SDKHook_Touch del prop — que corre DENTRO de la
//   simulacion vphysics — y ahi el spawn+wake+launch del ragdoll falso
//   nunca despega (stun si, vuelo nunca; por eso NINGUNA habilidad del
//   suite lanza ragdolls desde un touch fisico). FIX: el Touch solo
//   ENCOLA (Amy_OM_HammerHitQueue, lista de blandos compartida con el
//   scan) y un RequestFrame (Amy_OM_HammerHitFlush) lo procesa el frame
//   siguiente, fuera de la simulacion — el MISMO contexto de timer del
//   spindash y el Barrido. El scan 30 Hz sigue igual (ya era contexto
//   seguro).
//   (C) DANO FUERA DE OM_Stun (orden Rouge): primero TakeDamage; si el
//   objetivo SOBREVIVE -> stun + ragdoll falso del spindash; si el golpe
//   LO MATA -> copia Rouge volada (el watcher del stun mataba al doble
//   de una victima muerta a los 0.1s = vuelo invisible). Iframes del
//   OM: solo resisten el stun, el dano se paga siempre.
// v3.77.57 (Amy.inc v105-OM + sonic.inc v6.34-OM + cstguard.inc v3.0.4) —
// EL MARTILLO DE AMY CON FISICA REAL (pedido del owner 2026-10-13: "es
// hora de modificar el ataque de martillo... osea el lanzamiento no el
// golpe de defensa"): (1) IMPULSO DIRECCIONAL GMOD a TODO lo que golpea
// el martillo lanzado — los COMUNES ahora vuelan (el "tratamiento del
// spindash" que faltaba: dano + velocidad, la receta del barrido de la
// bola; el ragdoll de muerte hereda la velocidad). La direccion depende
// de DONDE recibe el golpe: desde abajo = hacia ARRIBA; desde arriba =
// hacia ABAJO; si la victima esta EN EL SUELO = DIRECCION CONTRARIA (la
// Z se niega: rebota) + impulso que la ELEVA. Especiales/witch heredan
// las mismas reglas en su ragdoll falso. Convar amyom_throw_fling 550.
// (2) CERO DANO DE COLISION FISICA VANILLA AL EQUIPO ("el dano de
// colision amy se dano cuando lanza el martillo en si"): cinturon 1 =
// m_impactEnergyScale 0.0 al nacer (el campo REAL del physdamagescale,
// que el KV no siempre pega en prop_physics_override); cinturon 2 = el
// hook PROPS AMIGOS v82 reconoce el prop del martillo (crash damage a
// CUALQUIER survivor = bloqueado); cinturon 3 = el Touch de juego vs
// survivors devuelve Handled (el rebote fisico lo resuelve el vphysics
// igual). (3) TUMBLE REAL en vuelo ("el martillo esta siempre tieso...
// hasta un auto cuando le pega el tank este puede girar"): el giro va
// DIRECTO al IPhysicsObject via Sonic_PhysSetVel (wrapper publico
// NUEVO de sonic.inc v6.34 sobre el SDKCall SetVelocity(lineal,angular)
// del motor v6.33 — el m_angVelocity del datamap lo mataba el vphysics
// cada tick, la misma leccion del doble v6.9): CARTWHEEL alrededor del
// eje derecho del rumbo + WOBBLE random (+-20%) en los otros ejes.
// Convar amyom_throw_spin 700. cstguard v3.0.4: rouge REINTEGRADO al
// mapa oficial ("rouge rouge_r.cfg si existe solo que se paso
// colocarla") = 14 perfiles de fabrica; el data/cst_skinchange_maps.txt
// del server (que ya tenia la linea a mano + marcador) manda igual.
// v3.77.56 (con cstguard.inc v3.0.3) — EL MAPA OFICIAL DE LOS 13. El
// owner mando la lista definitiva de los modelos CST instalados en el
// server (VPK *_cst.vpk): sonic tails knuckles amy big blaze cream eggman
// knuckles metal omega sage shadow silver — "metal esta hay y bueno ya
// sabes que hacer". cstguard v3.0.3: (1) MAPA OFICIAL de 13 perfiles
// (cada VPK trae su ems/custom_survivor_takeover/profiles/<clave>.cfg):
// los 9 personajes del manager con modelo quedan cableados de fabrica
// (seleccion/recuerdo = perfil EN EL ACTO, metal_sonic->metal por frontera)
// + big/blaze/omega/silver con sm_<clave> manual; (2) UPGRADE INTELIGENTE
// del data/cst_skinchange_maps.txt: archivo viejo (seed amy/rouge/sonic o
// + agregas oficiales) se RE-SIEMBRA solo a los 13; archivo custom se
// CONSERVA y se completan los oficiales; desde el marcador [MAPA-OFICIAL]
// el archivo manda tal cual (editar/borrar lineas se respeta); (3) sally y
// rouge SIN modelo = sin linea (seleccion no toca el stock; rouge_r.cfg
// retirado, se recupera con una linea); (4) sm_sage NO se registra (Sage.inc
// ya es duena de ese comando = ciclar sets; sage.cfg se aplica por senal o
// sm_cstapply); CSTG_MAX_CHARS 12->20. CERO cambios de logica del manager.
// v3.77.55 (con cstguard.inc v3.0.2) — LA LLAMADA DIRECTA. Reporte del
// owner: "señal: Amy Rose ES 'sonic' -> sonic.cfg... el guard si reconoce
// la señal de quien soy pero no aplica el cfg". Autopsia: el gate de la
// señal (signal && auto && bCstReady) moria SIEMPRE en bCstReady=0 — el
// write-back del probe y del who-query usaba DirectorScript.Convars,
// que NO EXISTE en el VM (Convars es un GLOBAL RAIZ, como lo llama el
// propio CST en su yeoh_survivor_model_changer.nut): el script reventaba
// en silencio, cstguard_probe jamas se escribia y TODO lo automatico
// (señal / watchdog / sweeps / who) quedaba muerto mientras los comandos
// manuales seguian vivos — ESA era la "vista gorda" desde la v2.2. FIX
// cstguard v3.0.2: (1) probe y who con Convars RAIZ -> bCstReady confirma
// de verdad; (2) LA SEÑAL EJECUTA EL COMANDO EN EL ACTO, sin gates:
// seleccion o recuerdo = sm_<cfg disponible> (sm_amy / sm_sonic /
// sm_rouge / ...) directo en el contexto del jugador — pedido literal del
// owner; el skip "ya lleva el modelo" pasa a log VISIBLE; (3) la señal se
// registra TAMBIEN si el cliente aun no esta in-game (cookie al
// reconectar) y aplica en su primer spawn; (4) probe transicion no->si
// pide re-anuncio inmediato (lo que llego antes del montaje se aplica ya).
// v3.77.102 (2026-10-21): KOLOSSOS v1.7-OM — VEREDICTO FINAL DE LAS CAPAS + FIX DEL VOLTEO DEL AGARRE (reporte del owner con la v1.6.1 en vivo: "host commentary_dummy pero sigue sin hacer las animaciones correctamente... cuando agarra el cuerpo de kolossos queda volteado al lado inverso, la mitad del cuerpo que deberia controlar el overlay... al caminar no aparecen las 2 animaciones a la vez"): [1] VEREDICTO EN VIVO del canal de capas: con el host dummy perfecto (vivo + nuestro modelo) la sonda multi-forma dio m_AnimOverlay=no m_animLayers=no en TODAS las formas — L4D2 NO networka el array de capas de NINGUNA entidad tipo prop (a diferencia de TF2/CS:GO/GMod): el dummy hereda la CLASE overlay pero sin send table no hay nada que el cliente pueda ver — ni netprops ni SDKCall lo arreglan. Motor de capas RETIRADO del camino de ejecucion (LayersActive() siempre false; la sonda queda como diagnostico y ahora SIEMPRE pruebea el player — la v1.6.1 volvia antes y la matriz quedaba coja con "player sin sonda"). LA VIA REAL ES Y ERA LA FUSION v1.5 (12 compuestas). [2] FIX DEL VOLTEO (forense SMD hueso por hueso): los 4 gestures del grab (Grab/GrabIdle/GrabPunch/GrabThrow) traen el hueso Root con un roll extra de -90 grados en TODOS los frames (euler (90,0,-90) vs referencia (90,0,0)); en GMod eran capas con weightlist (Root peso 0 = enmascarado, invisible) pero como secuencia MAIN el Root SE APLICA = el cuerpo entero gira de lado, el "volteado al lado inverso". FIX DOBLE: (a) pack v1.5.1 con el Root neutralizado en los 4 SMD + carpeta de compilacion COMPLETA (cuerpo + fisica + 56 SMD: nada que mezclar con archivos locales del usuario); (b) el plugin JAMAS pone un gesture crudo como main — sin fusion el agarre queda en LOCOMOCION PURA (la victima en vilo delante es la senal), los one-shots solo disparan compuestas nativas y los fallbacks de las compuestas caen a su loco (nunca al gesture). Las 12 compuestas ya estaban limpias (su Root viene de la locomocion — verificado hueso por hueso) y el Kill ya venia limpio. [3] LA VICTIMA DONDE LA MANO: forense del GrabIdle — la mano derecha sujeta a 38u delante y 72 de alto (model space); el agarre viejo la ponia a 55u delante y 12 de alto = arrastrada a la altura de las rodillas ("el agarre se comporta raro"): KOL_GRAB_HOLD 55/12 -> 38/62, la victima cuelga debajo de la mano que la sostiene. HUD v1.7: linea "Capas: NO EXISTEN EN L4D2 (canal no networkado — la via es Fusion)", matriz CanalCapas completa (player siempre probado), linea nueva "Modelo avatar: <m_ModelName>" (que .mdl corre de verdad) y la linea Fusion apunta al pack v1.5.1 COMPLETO. CERO FX tocados.
// v3.77.105 (2026-10-22): KOLOSSOS v2.0-OM — EL PIN GMOD DE VERDAD + EL SWING FUSIONADO + LA LISTA + EL ARMA CALLADA (reporte del owner con la v1.9 en vivo: "el ragdoll no queda aderido al brazo de kolossos mientras este lo lleva y cuando grab el cuerpo aparece cuando da el golpe luego desaparece... cuando uso la embestida el ragdoll se va hasta el fondo del mapa osea literalmente el cuerpo real se queda en el sitio invisible" + "la animacion de los ataques el usa la animacion swing es la animacion que faltaba que fusionaras con la de caminar y correr" + "el grab_ragdoll no aparece en la lista" + "el arma aun sigue (visualmente disparando) aunque no gasta balas ni hace dano"). FIXES: [1] PIN POR FRAME estilo GMod (sonic.inc v6.38 Sonic_RagPhysPin: SDKCall SetPosition + velocidad CERO sobre el hueso RAIZ del doble, indices contados del vphysics_interface.h l4d2 — JAMAS SetParent sobre un prop_ragdoll con vphysics despierto: el padre a 750u/s de la embestida acumulaba velocidad fantasma y el doble salia DISPARADO al fondo del mapa): el pin corre CADA TICK en T_Kol_LayerThink leyendo la MANO ANIMADA de un info_target pegado al attachment grabhand (m_vecAbsOrigin); sacudida del puno = pausa del pin 0.4s + impulso; plan B TeleportEntity con velocidad cero; [2] el original oculto de la EMBESTIDA ahora SIGUE al doble (VictRagThink: follow congruente en TODOS los modos, antes solo el vuelo) — "el cuerpo real se queda en el sitio invisible" fuera; [3] LA FUSION DEL SWING (pack modelo v1.5.3): walk_swing/run_swing/idle_swing = piernas de la loco + brazos+UpperTorso+Head de swingsub.smd (forense: brazos == swing.smd exacto a 0.0 grados + el torso 80 del addlayer) — el M1 dispara la serie swing (el ACT_MELEE_ATTACK_SWING_GESTURE del Lua l.2638), fallback a la serie punch v1.9, sm_kolossos reporta "d/12 grab + d/3 swing"; [4] Sonic_Suite.cfg: prefijos blaze_/silver_/kolossos_ agregados a g_sSuitePrefixes + 3 secciones nuevas (los 35 kolossos_* incluido kolossos_grab_ragdoll NUNCA se auto-guardaban); [5] M1: m_flNextPrimaryAttack del arma activa slot 0/1 congelado por RunCmd (campo networkado Y prediciado: la prediccion del cliente ya no dibuja el fogonazo; recarga intacta por gate m_bInReload). | // v3.77.104 (2026-10-21): KOLOSSOS v1.9-OM — EL RAGDOLL DEL AGARRE + M1 AL CLICK + COUNTER AMPLIADO (reporte del owner con VIDEO de la v1.8: "hace la animacion de que lo agarro mas de una vez" + "no aparece un ragdoll en la parte del brazo" + "al soltarlo no tira un ragdoll al suelo... el cuerpo oculto debe moverse a la posicion del ragdoll literalmente a donde se mueva este" + "la embestida tambien puede enganchar al enemigo (verifica el LUA original)" + "el counter ahora puede counterar ataques basicos de otros infectados habilidades y demas (menos commons... asi la witch tambien)... el counter lanza al enemigo en estado ragdoll... lanzara una roca de tank mucho mas fuerte que la del propio tank (smoker/spitter/roca del tank la disparan)" + "el ataque basico deberia hacerse con el click... el click de disparo pisado por el de ataque de kolossos (solo ramas primarias y secundarias; granadas/botiquines igual)"). FIXES/FEATURES: [1] SISTEMA DE RAGDOLLOS propio (receta Sonic v6.33/Amy v106): doble prop_ragdoll + original RENDER_NONE + follow congruente por tick + restauracion donde cae — el FIX DE FONDO del agarre multiple era la v1.8 re-assertando parent+tilt por tick sobre la victima VIVA (el engine suelta parents de players -> re-snap visible); [2] grab: doble colgado de la mano (attachment grabhand, beat de fisica para el pose), sacudida por puno, lanzamiento con impulso por hueso (Sonic_RagPhysLaunch) y la victima queda TIRADA en ragdoll hasta revivir donde cayo; [3] embestida LLEVA POR DELANTE (Lua l.1785-1957): especiales ocultos con doble clavado fwd*40+up*40, commons/witch arrastrados visibles parentados al avatar; [4] counter: solo ESPECIALES (team 3, cualquier ataque/habilidad) disparan contra — commons/witch absorbidos sin contra; melee <300u = el atacante sale en ragdoll stun volando (fling propio con follow); fuentes proyectil (smoker/spitter/tank_rock) o >=300u = la ROCA reforzada (75 dano + 1s stun al area); [5] M1: click izq con arma primaria/secundaria PISADO (IN_ATTACK fuera) = puno basico (65u, dano convar, CD 1.65) o puno del combo; slots 2/3/4 intactos. Convars nuevos: kolossos_m1/_m1_damage/_grab_ragdoll/_charge_carry/_counter_ragdoll/_rock_stun (rock_damage 35->75).
#define PLUGIN_VERSION "3.77.105"   // v3.77.103 (2026-10-21): KOLOSSOS v1.8-OM — LA VICTIMA PEGADA AL BRAZO (reporte del owner con la v1.7.1 en vivo, el ya compilo el .mdl: "la animacion de grab esta bn no te negare eso PERO el cuerpo del enemigo deberia estar pegado al brazo en si, no en donde la camara este viendo, y deberia estar orientado mas que todo a donde mire kolossos no el survivor invisible... el brazo espina, o sea el derecho, no este tan separado: el original se veia mejor, solo que se veia el mirando hacia arriba — lo unico que debias hacer era BAJAR LA ORIENTACION HACIA ABAJO" + "el agarre inicial no esta funcionando, sigue haciendo la animacion de correr pero no de agarrar"). FORENSE FINAL: TODO el material del grab (raw + deltas addlayer + fusionados) esta a <=1.6 grados de la referencia — los clips del .mdl original NO traen pose; el look del GMod era la VICTIMA parentada a la mano por el Lua, tal cual el owner lo describio ("el brazo como en si no se puede mover"). FIXES: [1] modelo v1.5.2: $attachment "grabhand" hueso RightHand (unica linea nueva del QC, 56 SMD intactos); [2] plugin: Kolossos_GrabVictimGlue — SetParent al avatar R (verdad de mundo) + SetParentAttachment "grabhand" (snap a la mano animada) + tilt afinable (kolossos_grab_tilt, default -35); [3] GrabHoldThink: pegada re-assert por tick (sobrevive re-montajes), fallback offset v1.7; [4] GrabRelease: unparent ANTES del fling. Cadena: attachment (mdl v1.5.2) > parent-follow (mdl viejo) > offset v1.7. CERO FX tocados.
// v3.77.101 (2026-10-21): KOLOSSOS v1.6.1-OM — FIX DEL HOST DEL DUMMY (reporte del owner con la v1.6 en vivo: "Capas: no disponibles | host prop_dynamic_override | 0 slots" — caia al prop SIEMPRE): la verificacion v1.6 del host exigia resolver el canal de capas como "m_animLayers.m_nSequence" y esa forma de nombrar un array de datatables NO existe para el nucleo de SourceMod (leido el fuente del core, HalfLife2.cpp / UTIL_FindInSendTable: las props "inside array" se SALTA; la unica ruta es la punteada con el indice del elemento DENTRO del nombre — "m_AnimOverlay.001.m_nSequence", el formato del sm_dump_netprops) — el dummy perfecto spawnneaba, pasaba vivo y con nuestro modelo, y lo killabamos por un check imposible. FIXES: [1] el host ya NO depende del canal (dummy = spawnnea vivo + NUESTRO modelo; las capas las decide la sonda aparte) + reason codes granulares reportados en sm_kolossos (clase no registrada / murio al spawnear / rechazo el modelo y cual quedo); [2] SONDA MULTI-FORMA: 2 tablas (m_AnimOverlay / m_animLayers) x 3 formas de direccionar (%03d punteada / sin pad / element con test de bounds) — gana la primera que resuelva Y se deje escribir el slot 2 (write/read/restore de m_nSequence + m_flCycle, y m_flWeight pasa a campo guardado); [3] linea nueva de sm_kolossos "CanalCapas: host ... | player ..." con la matriz de descubrimiento del canal (el oraculo del debug: si el player resuelve y el host no, el host no networka overlay; si ninguno, es la version del SM); [4] ActivateEntity tras el spawn del dummy (receta de los clones de emotes). Mismo fallback completo (capas reales > fusion v1.5 > monocapa v1.3) y CERO FX tocados.
// v3.77.100 (2026-10-21): KOLOSSOS v1.6-OM — LAS CAPAS REALES POR COMMENTARY_DUMMY (el owner remato la investigacion con el hilo de AlliedMods + la pagina oficial de Valve: en L4D2 NINGUN prop soporta m_AnimOverlay porque CDynamicProp hereda de CBaseAnimating a secas, PERO commentary_dummy — el muneco del modo comentario — SI: CCommentaryDummy -> CBaseCombatCharacter -> CBaseFlex -> CBaseAnimatingOverlay -> CBaseAnimating -> CBaseEntity, la UNICA entidad spawnable como prop con el array de capas networkado m_animLayers[15], y ademas con keyvalue "model", input "SetAnimation" por nombre y StartingAnim/StartingWeapons documentados). EL TRUCO: el avatar espejo se monta en un COMMENTARY_DUMMY con AUTO-VERIFICACION tras el spawn (vivo + modelo propio puesto + canal de capas presente; si la fabrica lo rechaza o se rompe solo, cae al prop_dynamic_override clasico sin romper nada) + blindaje de combat character (m_takedamage 0, collision group 0, no solido, sin sombra, LookAtPlayers 0 — cuelga del player intocable como un prop). El motor de capas de la v1.4 VUELVE COMPLETO y ahora tiene host: pose GrabIdle sostenida en la CAPA 1 (el ACT_HOVER del GMod, re-afirmada per-tick para sobrevivir a re-montajes) + reach/puno/lanzamiento como one-shots en la CAPA 2 (ciclo 0->1.0 empujado por el server con driver per-tick T_Kol_LayerThink re-creado en cada OnMapStart y soltado en OnMapEnd, duracion completa medida en vivo por el calibrador), mientras el main queda en PURA locomocion — brazos y piernas INDEPENDIENTES, el sistema exacto del GMod y de los survivors al cambiar arma. Sonda DUAL de tabla (m_animLayers / m_AnimOverlay, el nombre que exista) con test de escritura por mapa, la sonda de secuencias ahora captura el INDICE (las capas usan indice, no nombre), FSM branch [3] con capas = main locomocion pura, GrabBegin enciende la pose / GrabRelease la apaga (+clear del one-shot sin fling), ResetState apaga ambas idempotente, barrido de huerfanos en AMBOS hosts (commentary_dummy + prop_dynamic_override) y sm_kolossos muestra "Capas: ACTIVAS | host commentary_dummy | 15 slots | tabla m_animLayers". Cadena de fallback completa: CAPAS REALES > fusion v1.5 (12 compuestas) > monocapa v1.3, misma duracion y prioridad en los tres mundos. EL .MDL NO CAMBIA: las capas usan las secuencias Grab* ORIGINALES del modelo actual (ya autoradas como gestures: weightlist weights_swing = brazos a 1, todo lo demas a 0). CERO FX tocados.
// v3.77.99 (2026-10-21): KOLOSSOS v1.5-OM — LA SERIE GRAB FUSIONADA (reporte del owner con la v1.4 en vivo: "Capas: NO DISPONIBLES (fallback monocapa) (slots 0)"; el owner tambien paso la pagina oficial de VScript de Valve como referencia): VEREDICTO TECNICO sellado por dos fuentes — [a] la sonda en vivo: un prop_dynamic de L4D2 NO lleva m_AnimOverlay (la clase CDynamicProp no hereda de CBaseAnimatingOverlay: solo players/NPCs networkan overlays, por eso el Tank lanza rocas con los brazos mientras camina), y [b] la pagina oficial de VScript: la API de entidades de L4D2 trae SetSequence/ResetSequence/LookupSequence/GetSequenceDuration y NI UNA funcion de capas o gestos — no existe canal de layers para un prop, ni por netprops ni por Squirrel. LA VIA REAL del port: las 12 SECUENCIAS COMPUESTAS del .mdl recompilado (piernas de la locomocion + brazos del grab fundidos en UNA seq: idle/walk/run x hold/reach/punch/throw, generadas del weightlist weights_swing del kolossos.qc — misma $modelname, drop-in con Crowbar). EL PLUGIN: la FSM con victima en vilo pasa el main a *_hold (PIERNAS ANDANDO con los brazos sujetando — exactamente lo que pedia el owner), los one-shots de la serie eligen su variante por locomocion del instante (reach/puo/lanzamiento caminando/corriendo/plantado; el LANZAMIENTO sigue siendo KOL_SHOT_MAX de duracion completa medida en vivo), sonda de las 12 compuestas + g_bKolFusedNative por pieza con fallback TOTAL a la monocapa con el modelo viejo (cero rotura: sin recompilar funciona igual), el motor m_AnimOverlay de la v1.4 sale COMPLETO (0 slots en la realidad = codigo muerto fuera) y kolossos_grab_layers queda como el switch de la fusion; sm_kolossos ahora muestra "Fusion: ACTIVA (12/12 compuestas)". Pack v1.5 = smx + fuentes + carpeta modelo/ (kolossos.qc v1.5 + los 12 SMD fusionados; el mesh Kolossos.smd, kolossos_physics.smd y los materiales viven en la carpeta de decompilacion del owner). CERO FX tocados. | v3.77.98 (2026-10-21): KOLOSSOS v1.4-OM — LAS CAPAS DEL GRAB + AGARRAR ESPECIALES (reporte del owner tras probar la v1.3: "la animacion grab nunca se logra apresiar es pisoteada por la animacion de caminar" + "No agarra a especiales (al tank no lo agarra. tampoco)" + "la animacion por capas si es compatible con l4d2, por que no se le esta aplicando?"). [1] MOTOR DE CAPAS REAL (m_AnimOverlay) sobre el avatar: el kolossos.qc del zip del owner confirma que Grab/GrabIdle/GrabPunch/GrabThrow estan compiladas con weightlist "weights_swing" (SOLO animan brazos) + addlayer delta + fps 60 — fueron autoradas como GESTURES DE CAPA (el AddGesture del GMod), y al ponerlas como secuencia PRINCIPAL del prop (motor monocapa v1.3) los huesos peso-0 caen a pose de referencia = el "pisoteada por caminar" que veia. AHORA: slot 1 = pose GrabIdle sostenida (el ACT_HOVER), slot 2 = reach/puo/lanzamiento con ciclo COMPLETO empujado per-tick por el server, SOBRE el main en locomocion — las PIERNAS SIGUEN ANDANDO mientras los brazos agarran, exactamente el sistema de los survivors al cambiar arma que pedia el owner. Sonda HasEntProp+GetEntPropArraySize por mapa, convar kolossos_grab_layers (1 auto / 0 = monocapa v1.3), diagnostico en sm_kolossos; [2] DURACIONES corregidas al fps 60 REAL del QC: reach 0.52s / puo 0.85s / lanzamiento 1.02s (v1.3 asumia 30fps = el doble); [3] FIX AGARRAR ESPECIALES: el tank estaba EXPLICITAMENTE vetado desde la v1.0 y los SI perdian contra cualquier comun en la esfera (commons primero con return) — ahora los ESPECIALES tienen PRIORIDAD (el mas cercano), TANK por kolossos_grab_tank (default 1, ya se puede agarrar y lanzar al tank) y WITCH por kolossos_grab_witch (default 1). CERO FX tocados. | v3.77.97 (2026-10-21): KOLOSSOS v1.3-OM — LAS ANIMACIONES DEL GRAB (reporte del owner con los SMD del .mdl: "faltaron las animaciones de grab; la del lanzamiento debe ser PRIORITARIA y durar lo que debe durar; las grab son de solo torso y las piernas tienen que seguir andando como los survivors al cambiar arma"): [1] la serie completa del grab cableada a la FSM del avatar — KOL_ST_GRABREACH (el "Grab" 31f, one-shot al enganchar la victima), KOL_ST_GRABHOLD (la pose "GrabIdle" plantado sujetando — el ACT_HOVER del GMod), KOL_ST_GRABPUNCH (51f por puo, el gesture MELEE_ATTACK2) y KOL_ST_GRABTHROW (61f, EL LANZAMIENTO); [2] sistema de PRIORIDADES en Kolossos_AnimShot (KOL_SHOT_ACT 1 < KOL_SHOT_GRAB 2 < KOL_SHOT_MAX 3): un one-shot solo puede ser pisado por uno de igual o mayor categoria — el LANZAMIENTO y la EJECUCION (Kill) no los corta NI el stun ni la locomocion, "debe durar lo que debe durar"; [3] CALIBRADOR de duraciones EN VIVO: prop desechable + m_bClientSideAnimation 0 midiendo cuando m_flCycle se clava en 1.0 — las 3 anims one-shot duran lo que el .mdl REAL dicta (no el corte a 0.9s con fade del GMod ni un guess de 30fps: el Kill del Lua dura 1.65s con 276 frames); [4] regla "las piernas nunca se congelan" mientras sostiene (el prop es monocapa y los grab del .mdl son solo-torso): en el suelo moviendose = WALK, en el aire = JUMP/FALL, solo plantado = pose GrabIdle; [5] combo encadenado 3er puo -> lanzamiento (GMod l.2617 duration+1.75) y la victima vuela a +0.3s del arranque de la anim (GMod l.2154, antes salia instantanea). CERO FX tocados. | v3.77.96 (2026-10-21): KOLOSSOS v1.2-OM — FIX "AL ELEGIRLO NO SALE EL AVATAR" (reporte del owner tras probar la v1.1): la FSM de 10 Hz del modulo (T_KolossosThink) llevaba TIMER_FLAG_NO_MAPCHANGE pero se creaba UNA SOLA VEZ en Kolossos_OnPluginStart — al PRIMER cambio de mapa el timer moria y nunca se re-creaba: sin FSM no hay montaje (Kolossos_CreateAvatar SOLO la llama la FSM), no hay auto-reparacion de la copia L y no hay tick del kit (avalancha/agarre/bloqueo/indicator). Por eso la v1.0 parecia funcionar (probada en el primer mapa tras instalar) y en el mapa 2+ el coloso ya no salia. FIX = receta canon del suite (Rouge v10 / Blaze v2.11 / Silver v2.0): [1] el timer se re-crea en Kolossos_OnMapStart (cada arranque de mapa); [2] NUEVO Kolossos_OnMapEnd cableado en la cadena del manager (suelta el handle mientras sigue vivo + kit/refs a cero — la leccion del crash del capitulo 2 v3.30); [3] FIX secundario: el ref de la copia R se asigna ANTES de crear la L (CreateAvatarL valida que la R exista; antes la L nacia 0.1s tarde por la auto-reparacion, con el cuerpo ya en RENDER_NONE = una decima de invisibilidad total en cada montaje). CERO FX tocados. | v3.77.95 (2026-10-21): KOLOSSOS v1.1-OM — LAS ANIMACIONES COMPLETAS + EL FIX DEL DOBLADO (reporte del owner: "Las animaciones de kolossos faltaron" + "si yo muevo la camara el personaje se dobla a mirar, un error viejo de cuando probabamos a Tails"): [1] FIX DOBLADO: la copia L del avatar (la que ve el dueno) ahora contra-rota contra los EYE angles (receta Tails v5.17-B / Blaze — el bug era exactamente el v5.4 "cuerpo inclinado con la mira"): el cliente del dueno arma el parent con el cuerpo PREDICHO = camara completa, y sin cancelar el pitch de la mirada el coloso se inclinaba con la camara y quedaba doblado al pausar; AHORA vertical SIEMPRE en su pantalla, ergido tambien al pausar, como Amy y los demas. [2] ANIMS: la FSM del avatar pasa de 5 estados base a las 15 del registro del Lua (noodles_om_pills_killer_kolossos): chargestart (windup de la Z), charge_notimpaled / Charge_impaled (avalancha segun empalados, rate 1.2 del animrates), BlockStart + BlockPos (bloqueo B), BlockProjectile / BlackCounterMelee (counter segun distancia <300u), slaminwall (tope de pared con empalados: 1.3s + Sound.mp3), Kill (ejecucion del agarre cuando un puo mata: 1.65s + la risa a +1s), stun (ShouldAlternate), walk con la victima en vilo (run->walk) y paso a 3x en el lunge del grab; todas resueltas por SONDA contra el .mdl real con cadena de fallbacks (nunca T-pose). CERO FX tocados. | v3.77.94 (2026-10-21): KONOSSO EL COLOSAL DE OM — 14o personaje del suite (KOLOSSOS_INDEX 13, Kolossos.inc v1.0-OM): port del killer noodles_om_pills_killer_kolossos.lua del repo del owner. SIN cuerpo CST: el AVATAR ESPEJO (patron Blaze v2.11, doble copia R/L + modo TP + pulso de pausa) se monta sobre el survivor actual (kolossos_model). Kit: Z = AVALANCHA EMPALADORA (windup 0.8s suspiro->rumble->rugido, velocidad por stack del Speed_sonic + auto-forward + DEBRIS como el Destructive Charge de Metal, empala esfera 90u con extension +3.75s por victima, fling final, watchdog de pared) | X = AGARRE (lunge 0.6s, victima en vilo max 10s, Z = puos 15d, 3 puos y sale volando; CD 25s/2s) | C = INDICATOR (5s de glow rojo sobre todos los infectados en radio + ping/susurro; CD 14s) | B = BLOQUEO (3.5s inmune al dano de infectados, primer golpe consuma y CONTRAGOLPEA con roca rockgranite03b 3x en arco 35d AoE; CD 14s). Pasivas: vida 670 (kolossos_health, receta Metal) + resistencia (kolossos_resistance). Sonidos om/kolossos (carpeta) con fallbacks nativos (cero dependencia). Speed_sonic.inc: +1 slot del stack (SPEED_STACK_KOLOSSOS). CERO FX tocados. | v3.77.91 (2026-10-18): LIMPIEZA TOTAL DE WARNINGS (18 -> 0) + LA BARRA DE ROUGE CABLEADA — [1] los 8x warning 213 de las llamadas manuales a *_Event_PlayerSpawn (view_as<bool>: mismo valor, cero tag mismatch); [2] los 7 convars tombstone DEPRECATED (blaze_kick/soldash_solflamemeter*, blaze_javelin_damage, rouge_kick_damage, silver_rocks_basedamage_perrock) siguen REGISTRADOS para no ensuciar el Sonic_Suite.cfg pero ya sin handle muerto (warning 204); [3] el handle muerto g_hEggmanMinesTimer retirado (las minas son Zapper desde v5.2: escrito 4 veces, leido 0); [4] Rouge_PlayerIs/Rouge_BarState (2x warning 203) eran la barra de energia de Rouge HUERFANA desde la v10.6/3.77.85: cableada en SBar_Resolve con el mismo patron Blaze/Silver/Sonic. CERO FX tocados. Cero logica de gameplay alterada. | v3.77.90 (2026-10-17): EL SOL DE LA EXPANSIVA (Blaze v2.13) — pedido del owner: la carga de sol del ataque principal solo llegaba al comun del GOLPE DIRECTO ("solo le da la energia al common que recibe la patada pero no a los commons que mate la expansiva") — AHORA los comunes que el AOE del impacto (patada / dash aereo / enganche de la lanza) MATA tambien cargan su blaze_sol_charge_common (+2 cada uno, el mismo convar del directo); CERO doble carga: el comun del directo entra al AOE como skipEnt (su +2 ya lo conto el HitImpact) y la witch/tank NO cargan por la expansion (su sol sigue siendo solo del directo); premio otorgado en el bucle final de Blaze_FX_AoeCommons re-validando Blaze_VictimAlive tras el daño (regla v2.10); cero FX tocados | v3.77.89 (2026-10-18): OPTIMIZACION FUERTE + SC PAUSA — cstguard v3.1.0 (cache de perfiles: cero I/O de disco al evaluar + barrido inteligente: cero VScript en reposo), Tails v5.21 (rate limiter del pulso anti-flicker + fix del trigger L incondicional + backoff de auto-montaje), HUD con cache de contenido e intervalo configurable (sm_omhud_interval), sistema SC PAUSA (salida del saferoom + conexion a mitad + sm_scpausa), sm_omdiag
// v3.77.52 (con sonic.inc v6.33-OM + Rouge v10.4-OM): EL RAGDOLL FALSO
// POR FIN HEREDA EL IMPULSO — reporte del owner: "el ragdoll falso no
// hereda ningun impulso, ni en el aire ni en el piso; la fuerza del golpe
// final de Sonic, el martillo de Amy y la autodestruccion de Metal
// deberian empujarlo como empujan los autos". Autopsia con el fuente del
// motor (hl2sdk branch l4d2) en la mano: la onda env_physexplosion v6.11
// mete su fuerza por CBaseEntity::VPhysicsTakeDamage -> ApplyForceOffset
// SOLO al hueso raiz, tras la licuadora de CalculateExplosiveDamageForce
// (clamp 30000 x phys_pushscale x Damage_NoPhysicsForce) — en este server
// el embudo termina en CERO. FIX (la receta GMod LITERAL): SetVelocity
// POR HUESO directo al simulador vphysics via SDKCall_Raw contra la
// interfaz publica IPhysicsObject, con los punteros de los huesos leidos
// del DATAMAP (m_pPhysicsObject = hueso 0, m_ragdoll.list[i].pObject =
// huesos 1..23 — DEFINE_PHYSPTR del CRagdollProp publico). Blindaje:
// L4D_GetServerOS (left4dhooks ya requerido) elige la vtable (+1 en
// Linux), CUATRO sondas semanticas validan la mesa antes de tocar nada
// (IsMotionEnabled==1, IsMoveable==1, IsAsleep en {0,1}, GetMass en
// [0.05,10000]) y si algo no cuadra cae al plan B motor puro
// (Sonic_RagFlingEngine: TeleportEntity-vel = SetVelocity del hueso
// raiz por la ruta del motor, baseentity.cpp L4296 — la misma que ya
// vuela los cuerpos del Barrido de Rouge en este server; sin
// left4dhooks tambien cae ahi). La ONDA v6.11 se RETIRO completa:
// su fuerza jamas llego al doble en este server. Cubre los 4 flingers:
// golpe final de Sonic, martillo de Amy, self-destruct de Metal, ritual
// de la witch (mismo embudo sonic.inc) + el Barrido de Rouge contra
// comunes (antes TeleportEntity-vel, que los huesos ignoran desde siempre).
// sonicom_ragblast cambia de significado: ahora es la VELOCIDAD de
// lanzamiento en u/s (700 = el SetVelocity*700 del GMod, en ambas capas).
// MAS INDEPENDIENTE de la
// masa: todo cuerpo vuela igual (el "escalado por masa" v6.11 leia
// m_iMass, campo que prop_ragdoll NO TIENE — nunca funciono, RIP).
// v3.77.10 (con sonic.inc v6.17-OM): TRAILS CON MATERIALES AUTENTICOS DEL GMOD — el owner verifico que tiene los .vmt del sonicball del pack OM y pregunto si los usabamos: NO los usabamos (el v6.6 habia traducido el look a laserbeam.vmt nativo). Ahora el spindash usa las TRES capas EXACTAS del fadeeiie del sonic.lua (blue_2ndlayer.vmt ancha 70->40 + blue.vmt 40->0 + blue.vmt 40->0 con tinte MAGENTA) y el peel el blue2.vmt 16->1 + los DOS trails de pies ROJOS Sonicred.vmt (alla en attachments 2/3 del puppet; aqui offsets fijos al tobillo — el env_spritetrail no sigue huesos). Deteccion FileExists estilo star_stun (ve los VPK montados): sin los archivos TODO cae al laserbeam nativo, CERO dependencia. Palanca: sonicom_trails_mat 1 (0 = nativo). Cvar auto-agregado al Sonic_Suite.cfg por la reconciliacion de la 3.77.4. v3.77.9 (con sonic.inc v6.16-OM): BOLA A ALTURA GMOD — fix visual del owner ("el modelo de la bola aparece media undida en el suelo"): sonicball.mdl es una esfera CENTRADA en su origen (~13u de radio) y el origen del survivor esta a los PIES, asi que parentada con offset (0,0,0) su centro caia a nivel del suelo = media hundida. El ent_om_hedgehog_dropballs.lua de GMod nunca la puso en el origen: hacia ply:GetPos()+Vector(0,0,15) por tick y SetModelScale(1.25) — los 2 ajustes que el port v6.0 no llevaba. Ahora convars sonicom_ball_z 15 / sonicom_ball_scale 1.25 (aplican al nacer la bola; 0/1 = look viejo). SOLO la bola: avatares humanos R/L y trails intactos. Cvars nuevos auto-agregados al Sonic_Suite.cfg por la reconciliacion de la 3.77.4. v3.77.8 (Sally v6.2 + Cream v6.1 + Eggman v3.1): FIN de la auto-generacion individual de cfgs — pedido del owner: "sally amy cream eggman se siguen auto generando con la misma lista que tiene el suite... lo mejor es matar de raiz su auto generacion individual". Causa: cada AutoExecConfig de un modulo escribia TODOS los cvars del PLUGIN entero ("ConVars for plugin Sonic_ability_manager.smx") = cada archivo individual era un duplicado de la lista completa del suite. Eliminados los ULTIMOS 3 con llamada viva (Sally_Abilities/Cream_Abilities/Eggman_Abilities; Tails/Speed/sonic_jump/Knuckles/Amy/Rouge ya muertos desde la v3.75) + SANEADOR SuiteCfg_DeleteLegacyFiles: al cargar/recargar el plugin BORRA del server los 9 cfg individuales residuales. Unica config: Sonic_Suite.cfg (auto-guardada + reconciliada). Sin cambios de cvars ni de gameplay. v3.77.7 (Tails v5.25-B + sonic v6.15-OM + Amy v98-OM): AVATAR REMOTO POR TP — pedido del owner: "los avatares DE OTROS al sistema del tails follow (modo TP); localmente igual (con su pausa)". La copia R (la que ven los demas) de los 3 avatares viaja por teleport por tick + reloj vivo SIN EF_NOINTERP (tails_avatar_tp 1 default; 0 = como antes): los demas la INTERPOLAN = suave sin depender de la pausa (solo re-encaja la vista del dueno). La copia L queda INTACTA (parentada+pulso). La bola del spin queda parentada y su R oculta viaja pegada. v3.77.6 (con sonic.inc v6.14-OM): PEEL OUT LLEVA JUGADORES (pedido: "el peel out segun los lua de GMod puede llevar supervivientes = otros jugadores"): durante la carrera del peel, tocar a un companion SANO lo MONTA detras de Sonic (hasta 3 asientos; sonicom_peel_carry / _carry_max) — viaja pegado a su estela a la velocidad de la carrera (arrastre por frame desde el PreThink), dispara montado y salta para bajarse; desembarco al frenar, suelta de emergencia si Sonic es interrumpido o el pasajero queda atras. El rescate de incap queda INTACTO (incap = levantar, sano = llevar). Cvars nuevos auto-agregados al cfg por la reconciliacion de la 3.77.4.
#define PLUGIN_VERSION_PREV_37613 "3.76.13"   // v3.76.13 (con sonic.inc v6.13-OM): el owner reenvio los Lua del GMod OM ("los lua de gmod por si acaso lo perdiste") — se releieron completos para responder de una vez por todas su pregunta "¿como mueve GMod a los ragdolls falsos? no existe algo que genere un impulso 1 vez y el motor se encargue del resto?". RESPUESTA (sonic.lua L435-485 + status.lua L85-394): GMod SI aplica un impulso UNA SOLA VEZ (SetVelocity 700 + AddAngleVelocity por hueso del prop_ragdoll) y el vphysics hace el resto — eso ya era la v5.36/v5.37 nuestra (onda env_physexplosion = mismo camino interno). LO QUE FALTO y se porto: el OM NUNCA re-aparece a la victima pegada a una pared — busca un HUECO (TraceHull) y ESPIRALA alrededor (status.lua L245-287): v6.13 Sonic_RagSafeSpot = victima/witch del ritual despiertan en el hueco valido mas cercano (fallback: el punto tal cual). v6.13: Sonic_RagSafeSpot puerto textual para la victima del golpe final y la witch del ritual — si el doble cayo contra una pared/escalera/rincon, la victima despierta en el hueco valido mas cercano en vez de atascada en la geometria. Fallback si no hay hueco en 96u: el punto tal cual (v6.12 = mismo fallback del GMod). El vuelo (onda), el rebote (-450/+500) y el fix anti-atasco (DEBRIS) quedan INTACTOS.

#define MAX_SOUNDS 4
#define INVALID_SOUND_INDEX -1

#define MAX_CHARS 14
#define INVALID_CHAR_INDEX -1

#define SONIC_INDEX      0
#define TAILS_INDEX      1
#define KNUCKLES_INDEX   2
#define AMY_INDEX        3
#define SALLY_INDEX      4
#define SHADOW_INDEX     5
#define ROUGE_INDEX      6
#define CREAM_INDEX      7
#define METALSONIC_INDEX 8
#define EGGMAN_INDEX     9
#define SAGE_INDEX       10     // v3.60 (R26): clase exclusiva de ADM (gate sj_sage en el menu)
#define BLAZE_INDEX       11     // v3.77.70: personaje SELECCIONABLE (modelo CST + avatar espejo)
#define SILVER_INDEX      12     // v3.77.70: idem Silver
#define KOLOSSOS_INDEX    13     // v3.77.94: el colosal de OM — avatar espejo sobre el survivor actual (sin cuerpo CST)

// v3.60 (R26): sets prestados de SAGE (el slot 3 / tecla C los cicla).
// El estado vive AQUI (antes de los includes) para que Amy.inc,
// Cream.inc y Sage.inc lo vean por igual.
#define SAGESET_NONE     -1     // sin personaje / reset de slot
#define SAGESET_AMY      0      // "los personajes mas fuertes": golpe en area + tarot
#define SAGESET_CREAM    1      // "el apartado de soporte": cura + revivir 30s + regeneracion
#define SAGESET_SALLY    2      // v3.62 (R28): escudos de agua/fuego para TODO el equipo (+5s el de Sage)
#define SAGESET_ROUGE    3      // v3.62 (R28): el estilo Rouge con sus granadas (cebo + bat bomb)


public char g_SoundPaths[MAX_SOUNDS][PLATFORM_MAX_PATH] = {
    "mobius/sfx/saltos/jumpSonic1.mp3",
    "mobius/sfx/saltos/jumpSonic2.mp3",
    "mobius/sfx/saltos/jumpSonicCD.mp3",
    "mobius/sfx/saltos/jumpSonicSRB2.mp3"
};
static const char g_SoundNames[MAX_SOUNDS][] = { "Sonic 1", "Sonic 2", "Sonic CD", "Sonic SRB2" };

public char g_CharNames[MAX_CHARS][] = {
    "Sonic", "Tails", "Knuckles", "Amy", "Sally", "Shadow", "Rouge", "Cream", "Metal Sonic", "Dr. Eggman", "Sage (ADM)", "Blaze", "Silver", "Kolossos"
};

// v3.77.54 — clave de señal CST por personaje (MISMO orden que g_CharNames).
// El guard la normaliza solo (lowercase / espacios->'_'); la coincidencia
// por frontera de palabra permite "metal_sonic" -> "metal" si algun dia se
// mapea. Personajes SIN cfg en el mapa (solo amy/rouge/sonic lo traen por
// defecto) quedan como identidad registrada L0 y el guard NO toca su modelo.
// v3.77.65 (= 3.77.59 de este lado): pasa de static a public —
// PathSense.inc la lee para sembrar su lista nativa de personajes
// (pathsense_chars usa LAS MISMAS claves).
public const char g_sCstCharKeys[MAX_CHARS][] = {
    "sonic", "tails", "knuckles", "amy", "sally", "shadow", "rouge",
    "cream", "metal_sonic", "eggman", "sage", "blaze", "silver", "kolossos"
};

public int g_iPlayerCharIdx[MAXPLAYERS + 1];
public int g_iSageActiveSet[MAXPLAYERS + 1];   // v3.60 (R26): set prestado de Sage (SAGESET_*)

// v3.62 (R28): escudos de Sally REGALADOS por Sage (set SALLY). Viven
// AQUI (antes de los includes) porque Sally.inc los LEE para relajar
// sus gates de escudo (Sally_ShieldSubject) y Sage.inc los ADMINISTRA
// (cast + timer de expiracion). true = ese cliente lleva un escudo de
// Sally que NO se activo el solo: llego por regalo de Sage.
public bool  g_bSageGiftWater[MAXPLAYERS + 1];
public bool  g_bSageGiftFire[MAXPLAYERS + 1];
public float g_fSageGiftWaterEnd[MAXPLAYERS + 1];   // expiracion del regalo de agua
public float g_fSageGiftFireEnd[MAXPLAYERS + 1];    // expiracion del regalo de fuego
public int g_iPlayerSoundIdx[MAXPLAYERS + 1];
bool g_bSonicHeroMode[MAXPLAYERS + 1];

ConVar g_cvSJEnable, g_cvSJVolume, g_cvSJCooldown, g_cvSonicBoost, g_cvVelZMin;
ConVar g_cvOMAirControl, g_cvOMAirImpulse, g_cvOMAirAccel, g_cvOMAirMax;   // v3.77.46
float g_flNextAllowed[MAXPLAYERS + 1];
int g_iCharTakenBy[MAX_CHARS];

Handle g_hSoundCookie;
Handle g_hCharCookie;
StringMap g_mCharOwner;
char g_sOwnersFile[PLATFORM_MAX_PATH];

// v3.77.53 — LA SENAL "QUIEN ES QUIEN": forward global que publica cada
// cambio de personaje (menu / cookie al reconectar / liberacion admin).
// El cst_skinchange v2.1 la escucha (Sonic_OnCharacterChanged) y aplica el
// cfg CST del personaje aunque el jugador este en un slot stock sin mapear.
GlobalForward g_fwdOnCharacterChanged;

int g_iOff_Incapacitated = -1;
int g_iOff_PounceAttacker = -1;
int g_iOff_TongueOwner = -1;
int g_iOff_JockeyAttacker = -1;
int g_iOff_PummelAttacker = -1;
int g_iOff_CarryAttacker = -1;
int g_iOff_LaggedMovement = -1;
int g_iOff_Velocity = -1;

// ============================================================================
// v3.77.79 — CAPA DE COMPATIBILIDAD MODO SOLO / JUEGO LOCAL
// ============================================================================
// Reporte del owner: "los comandos de consola en modo solo no funcionan
// (solo cuando creo partida en un lobby es que lo acepta)".
//
// POR QUE PASABA: en L4D2 el jugador local de una partida SINGLE PLAYER no
// es un cliente de red como en la del lobby — el motor lo monta como
// cliente FAKE (el takeover del bot que posee) y los comandos que tipea
// en consola le llegan al servidor o como CONSOLA (client 0) o con ese
// indice fake. El macro IsValidClient (que trae !IsFakeClient) los
// rechazaba EN SILENCIO: por eso Z/X/C/B, sc, js y compania no hacian
// NADA en modo solo y en la del lobby (cliente real) si. Referencia del
// ecosistema: Marttt (autor del left4dhooks) publico "[ANY] Console Cmd
// As Host (Listen Server Only)" para este mismo problema de L4D2 — y el
// host local ni siquiera es admin por defecto en este juego.
//
// LA CAPA (3 piezas):
//  [1] RESOLVER: Sonic_SoloClient(client) es la PRIMERA LINEA de CADA
//      comando del suite — la consola (client 0) se redirige al jugador
//      local; un cliente fake se acepta SOLO en partida sin clientes
//      reales (solo puro: ningun bot tipea comandos, asi que si un fake
//      llega por ahi ES el humano). En servidor DEDICADO y en listen con
//      gente conectada el comportamiento queda EXACTAMENTE igual que
//      siempre (los bots siguen bloqueados).
//  [2] MACRO: IsValidClient ahora deja pasar al host local
//      (Sonic_IsSoloHost) — con eso TODOS los guards internos del suite
//      (los 16 includes incluidos) aceptan al jugador de solo: menus,
//      HUD, prints, cooldowns...
//  [3] ADMIN: el host local recibe ROOT automatico (L4D2 no se lo da:
//      ni por admins.cfg —no hay SteamID que case en local— ni de
//      fabrica). Con eso Amy/Sage (CheckCommandAccess), sm_setsound,
//      freechars y los comandos del CST guard quedan desbloqueados en
//      local igual que en el server dedicado.
// ============================================================================
int g_iSoloHostClient = -1;               // cache del jugador humano local
AdminId g_iSoloAdminId = INVALID_ADMIN_ID;

// ¿hay ALGUN cliente real conectado? (modo solo puro: ninguno)
bool Sonic_AnyRealClient()
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && !IsFakeClient(i))
            return true;
    return false;
}

// ¿partida local SIN ningun cliente real? (single player puro)
bool Sonic_IsSoloGame()
{
    return !IsDedicatedServer() && !Sonic_AnyRealClient();
}

// ¿el host humano local tiene este indice? (check BARATO: para el macro)
bool Sonic_IsSoloHost(int client)
{
    return (!IsDedicatedServer() && client > 0 && client <= MaxClients
            && client == g_iSoloHostClient && IsClientInGame(client));
}

// Busca al jugador humano LOCAL por capas:
//  (1) cliente REAL conectado por loopback (host de listen / lobby local)
//  (2) el peon fake recordado (takeover / watchdog / resolver previo)
//  (3) heuristica de solo puro: el superviviente fake de MENOR userid
//      (el motor crea al jugador local ANTES que a los bots companeros)
int Sonic_FindLocalHostClient()
{
    if (IsDedicatedServer()) return -1;

    // (1) host real por loopback (listen / lobby local)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
        char ip[40];
        if (GetClientIP(i, ip, sizeof(ip))
            && (StrEqual(ip, "loopback") || StrEqual(ip, "local")
                || StrEqual(ip, "localhost") || StrContains(ip, "127.0.") == 0))
            return i;
        char auth[64];
        if (GetClientAuthId(i, AuthId_Engine, auth, sizeof(auth))
            && (StrEqual(auth, "LOOPBACK") || StrEqual(auth, "LOCAL")))
            return i;
    }

    // (2) peon recordado y todavia valido
    if (g_iSoloHostClient > 0 && g_iSoloHostClient <= MaxClients
        && IsClientInGame(g_iSoloHostClient))
        return g_iSoloHostClient;

    // (3) heuristica de solo puro: superviviente fake de menor userid
    int best = -1, bestUid = 0x7FFFFFFF;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsFakeClient(i)) continue;
        if (GetClientTeam(i) != 2) continue;   // supervivientes
        int uid = GetClientUserId(i);
        if (uid > 0 && uid < bestUid) { bestUid = uid; best = i; }
    }
    if (best > 0) return best;

    // (3b) ni supervivientes todavia (transicion): cualquier fake
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && IsFakeClient(i))
            return i;
    return -1;
}

// v3.77.79 — pieza [1]: RESOLVER DE COMANDO. Primera linea de cada
// callback del suite. Devuelve el cliente que ejecuta o 0 (los guards
// de siempre lo descartan igual que antes).
int Sonic_SoloClient(int client)
{
    // cliente valido de siempre: ni tocarlo (cero overhead en el server)
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        if (!IsFakeClient(client)) return client;
        // fake: SOLO en partida sin clientes reales (solo puro) puede ser
        // el humano (ningun bot tipea). El motor acaba de decirnos quien
        // es: se registra para el HUD/admin. En listen con gente o en
        // dedicado se bloquea como siempre.
        if (!IsDedicatedServer() && !Sonic_AnyRealClient())
        {
            g_iSoloHostClient = client;
            return client;
        }
        return 0;
    }

    // consola (client 0) o slot raro: en local se redirige al humano
    if (client == 0 && !IsDedicatedServer())
        return Sonic_FindLocalHostClient();
    return 0;
}

// v3.77.79 — pieza [3]: root automatico para el host local (L4D2 no lo da)
void Sonic_SoloGrantRoot(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    AdminId aid = GetUserAdmin(client);
    if (aid != INVALID_ADMIN_ID)
    {
        if (!GetAdminFlag(aid, Admin_Root, Access_Effective))
            SetAdminFlag(aid, Admin_Root, true);
        return;
    }
    if (g_iSoloAdminId == INVALID_ADMIN_ID)
        g_iSoloAdminId = CreateAdmin("sonic_solohost");
    if (g_iSoloAdminId != INVALID_ADMIN_ID)
        SetUserAdmin(client, g_iSoloAdminId, true);
}

// v3.77.79 — cookies a prueba de modo solo: el peon fake puede no tener
// cookies en cache (sin SteamID); sin el check SetClientCookie reventaba
// en pleno menu. En solo la eleccion vive la sesion (no persiste) — igual
// que cualquier preferencia local sin SteamID.
void Sonic_SafeSetCookie(int client, Handle cookie, const char[] value)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    if (!AreClientCookiesCached(client)) return;
    SetClientCookie(client, cookie, value);
}

// v3.77.79 — watchdog del host local: mantiene fresco g_iSoloHostClient y
// su root. Solo corre en servidor local (en dedicado se muere solo).
public Action T_SonicSoloWatchdog(Handle timer)
{
    if (IsDedicatedServer()) return Plugin_Stop;

    if (g_iSoloHostClient < 1 || g_iSoloHostClient > MaxClients
        || !IsClientInGame(g_iSoloHostClient))
        g_iSoloHostClient = Sonic_FindLocalHostClient();

    if (g_iSoloHostClient > 0) Sonic_SoloGrantRoot(g_iSoloHostClient);
    return Plugin_Continue;
}

// v3.77.79 — takeover registrado: en solo puro, cuando el motor re-asigna
// el peon, el "player" de player_bot_replace es el cliente local humano.
public void Event_SoloPlayerBotReplace(Event event, const char[] name, bool dontBroadcast)
{
    if (IsDedicatedServer() || Sonic_AnyRealClient()) return;
    int pl = GetClientOfUserId(event.GetInt("player"));
    if (pl > 0 && pl <= MaxClients && IsClientInGame(pl) && IsFakeClient(pl))
    {
        g_iSoloHostClient = pl;
        Sonic_SoloGrantRoot(pl);
        return;
    }
    int bot = GetClientOfUserId(event.GetInt("bot"));
    if (bot > 0 && bot <= MaxClients && IsClientInGame(bot) && IsFakeClient(bot))
    {
        g_iSoloHostClient = bot;
        Sonic_SoloGrantRoot(bot);
    }
}

public void OnClientConnected(int client)
{
    // v3.77.79 — slot del host re-usado: invalidar, el watchdog repone
    if (g_iSoloHostClient == client) g_iSoloHostClient = -1;
}

public void OnClientPostAdminCheck(int client)
{
    // v3.77.79 — mantener el cache del host local fresco mientras los
    // supervivientes conectan (el root solo lo usa quien tipea, y el
    // resolver lo corrige con el primer comando real del humano)
    if (!IsDedicatedServer() && IsFakeClient(client) && !Sonic_AnyRealClient())
    {
        if (g_iSoloHostClient < 1 || g_iSoloHostClient > MaxClients
            || !IsClientInGame(g_iSoloHostClient))
            g_iSoloHostClient = Sonic_FindLocalHostClient();
        if (g_iSoloHostClient > 0) Sonic_SoloGrantRoot(g_iSoloHostClient);
    }
}

// v3.77.79 — el macro ahora acepta al host local (pieza [2]): en cliente
// dedicado y en listen con gente, Sonic_IsSoloHost es siempre false y el
// comportamiento es IDENTICO al de toda la vida del suite.
#define IsValidClient(%1) (%1 > 0 && %1 <= MaxClients && IsClientInGame(%1) && (!IsFakeClient(%1) || Sonic_IsSoloHost(%1)))
#define IsSurvivor(%1) (GetClientTeam(%1) == 2)

public void AddSoundToDownloadsAndPrecache(const char[] soundPath)
{
    char fullPath[PLATFORM_MAX_PATH];
    Format(fullPath, sizeof(fullPath), "sound/%s", soundPath);
    if (FileExists(fullPath, true)) 
    {
        AddFileToDownloadsTable(fullPath);
    }
    PrecacheSound(soundPath, true);
}

// Includes completos
#include <colors>   // v3.77.84: LA PALETA DEL CHAT (colors.inc v2.0.0-MC del propio tree: {green}=AMARILLO en L4D2 / {lightgreen} verde claro / {blue} azul survivor / {olive} apagado / {red} rojo infectado) — ANTES de <SBar>: el motor de barras pinta por C_PrintToChat
#include <SBar>     // v3.77.84: EL MOTOR DE BARRAS v3.0-OM — LA BARRA AL CHAT con colors.inc (Llama Sol de Blaze / Vuelo de Silver / Anillos de Sonic), throttled — PRIMERO de los personajes: declara el estado compartido que los <Char>_BarState de los includes llenan
#include <Speed_sonic>
#include <Tails>  
#include <sonic>   // v3.76 (OM-SONIC): DESPUES de Tails — sonic.inc reusa los helpers compartidos del avatar (Tails_AvatarLocalAngles / Tails_ExpDamp / Tails_UnwrapYaw / Tails_MarkInterp / Tails_PauseFix_Trigger)

// v3.77.25: <Metal> SUBE de sitio (antes iba despues de Sage): su filtro
// anti-ragdoll del avatar (Metal_OnEntityCreated) lo despacha el
// OnEntityCreated central de Rouge.inc, que se incluye ABAJO — el
// simbolo tiene que existir antes de la llamada. Metal solo depende de
// OM_Stun/Speed_sonic/Tails (todos arriba): el move es seguro.
#include <Metal>

#include <Witch_Flight>
#include <SI_Stagger>
#include <Knuckles>
#include <Amy>
#include <Sally>
#include <Shadow>
// v3.77.71: helper de vectores compartido por los kits del Lua
// (SourcePawn no trae CopyVector nativo; una sola definicion para
// Blaze/Silver/Cream/Eggman — declarada ANTES de sus includes)
stock void OM_KitCopyVector(const float src[3], float dst[3])
{
    dst[0] = src[0]; dst[1] = src[1]; dst[2] = src[2];
}
#define CopyVector OM_KitCopyVector

#include <Cream>     // v3.77.68: ANTES de Rouge — el OnEntityCreated central de Rouge.inc despacha a Cream_OnEntityCreated
#include <Eggman>    // v3.77.69: MOVIDO desde despues de Sage — ANTES de Rouge (su OnEntityCreated central despacha a Eggman_OnEntityCreated; cero refs cruzadas Rouge/Sage<->Eggman verificadas)
#include <Blaze>     // v3.77.69: NUEVO 10o avatar (Blaze, modelo CST) — ANTES de Rouge (despacho OnEntityCreated)
#include <Silver>    // v3.77.69: NUEVO 11o avatar (Silver, modelo CST) — ANTES de Rouge (despacho OnEntityCreated)
#include <Kolossos>  // v3.77.94: 14o avatar (Kolossos de OM, sin cuerpo CST — espejo sobre el survivor actual) — DESPUES de Silver/Tails (usa helpers de avatar de Tails), ANTES de Rouge
#include <Rouge>
#include <Sage>      // v3.62 (R28): la clase ADM (4 sets: Amy/Cream/Sally/Rouge)
#include <Doll_System>

// v3.77.54 — EL CST-GUARD VIVE AQUI: todo el guard + motor CST (identidad
// por señal L0, auto-guard ronda/spawn/AFK/defib/rescate, watchdog, motor
// VScript con reintentos, comandos sm_amy / sm_sonic / sm_rouge / sm_cst*,
// mapa personaje->cfg persistente) embebido como include. Se arranca solo
// con CSTGuard_Init() al final de OnPluginStart; la señal le llega EN EL
// MISMO FRAME desde FireCharSignal (fin de la "vista gorda" del guard
// suelto que no veia lo que este manager hace). El forward global
// Sonic_OnCharacterChanged y el native Sonic_GetPlayerCharIndex siguen
// vivos para terceros.
#include <cstguard>

// v3.77.65 (= 3.77.59): PATHSENSE («Sentido de la Ruta»): el punto de
// control de la pasiva de ruta. Enlaza la nativa del plugin
// INDEPENDIENTE l4d_path_to_goal.smx (modo _NATIVE_ONLY: solo la
// declaración) y decide QUIÉN lleva la pasiva siempre activa
// (personajes nativos / admins / todos / concesión manual). Se arranca
// con PathSense_Init() en OnPluginStart y la señal le llega EN EL
// MISMO FRAME desde FireCharSignal (igual que el guard CST).
//
// v3.77.65 + AVATARHIDE: ocultacion de armas/equipo LIGADA AL AVATAR
// REAL. Regla del owner: quien lleva un avatar OM montado (Sonic /
// Tails / Knuckles / Amy / Shadow / Rouge / Metal o la bola de Sonic)
// NO muestra armas ni objetos del cuerpo; quien no (sin personaje,
// CST puro, Sally/Cream/Sage/Eggman) las ve normales. Deteccion =
// estado REAL de los props de avatar (AvatarHide_PlayerHasAvatar),
// efecto instantaneo por la misma senal de FireCharSignal y un latido
// de 0.2s que auto-corrige todo (respawns, muertes, cambios).
#include <PathSense>
#include <AvatarHide>

// =====================================================================
// v3.77.81: EL DESPACHADOR DE BARRAS SBar — quien es cada jugador
// decide QUE recurso se le pinta: la LLAMA SOL de Blaze, la flyingBar
// de VUELO de Silver o los ANILLOS de Sonic (su EVA). Un jugador es
// UN personaje a la vez: el orden del if no cambia nada. Cada
// <Char>_BarState llena el estado compartido del motor (SBar.inc) y
// T_SBarThink lo pinta (v3.77.84: al CHAT con colors.inc, THROTTLED
// — el canal que el owner marco en su captura). MODO SOLO: sin filtro IsFakeClient — el host local es
// cliente fake y TAMBIEN ve su barra (capa v3.77.79); un bot con
// modelo de personaje en dedicado solo recibe un Display que nadie
// ve (cero costo).
// =====================================================================
bool SBar_Resolve(int client)
{
    if (Blaze_PlayerIs(client))
    {
        if (!IsPlayerAlive(client)) return false;
        return Blaze_BarState(client);      // v2.7-OM: la Llama Sol
    }
    if (Silver_PlayerIs(client))
    {
        if (!IsPlayerAlive(client)) return false;
        return Silver_BarState(client);     // v2.2-OM: la flyingBar de VUELO
    }
    if (Sonic_PlayerIs(client))
    {
        if (!IsPlayerAlive(client)) return false;
        return Sonic_BarState(client);      // v6.36: los ANILLOS (su EVA)
    }
    // v3.77.91: LA BARRA DE ROUGE CABLEADA POR FIN — Rouge_BarState existia
    // desde la v10.6 (manager 3.77.85: "la rouge_latchbar vive ahora en el
    // motor comun SBar via Rouge_BarState + el despachador SBar_Resolve")
    // pero la rama NUNCA se agrego aqui: la barra quedo muerta y el compilador
    // avisaba con 2x warning 203 (simbolo nunca usado). MISMO patron
    // Blaze/Silver/Sonic: la energia latch 0-250 con PARED!/FRENO!/PLANEO!/
    // AGOTADA! ya esta implementada en Rouge_BarState.
    if (Rouge_PlayerIs(client))
    {
        if (!IsPlayerAlive(client)) return false;
        return Rouge_BarState(client);      // v10.6: la ENERGIA latch (0-250)
    }
    return false;
}

// 5 Hz: el latido de TODAS las barras (SIN NO_MAPCHANGE: sobrevive
// cambios de mapa — v3.0: sin entidades que limpiar; el CALCULO va a
// 5 Hz pero la ESCRITURA del chat sale throttled dentro de SBar_Paint
// [sbar_chat_interval/_refresh] — este think no spamea nada)
public Action T_SBarThink(Handle timer)
{
    bool on = (g_cvSBarOn != null && g_cvSBarOn.BoolValue);
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i))
        {
            g_bSBarShown[i] = false;        // sin pool: solo reset del flag
            g_sSBarLastSig[i][0] = '\0';    // v3.77.84: cache del chat tambien (slot re-usable)
            g_sSBarLastTag[i][0] = '\0';
            g_fSBarLastPr[i] = 0.0;
            continue;
        }
        // v3.77.84: ventana de probe — sm_sbarprobe 1..5 toma el canal
        // 12s (el 6 = grupo de control: cae al pintado normal de abajo)
        if (now < g_fSBarProbeUntil[i] && g_iSBarProbeMode[i] >= 1 && g_iSBarProbeMode[i] <= 5)
        {
            SBar_SendProbe(i);
            continue;
        }
        if (on && SBar_Resolve(i)) SBar_Paint(i, true);
        else                       SBar_Paint(i, false);
    }
    return Plugin_Continue;
}

public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "Author",
    description = "Universal Sonic Abilities Manager",
    version = PLUGIN_VERSION,
    url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    CreateNative("Sonic_GetPlayerCharIndex", Native_GetPlayerCharIndex);

    // v3.77.53 — LA SENAL: forward global Sonic_OnCharacterChanged(client,
    // charIdx). charIdx = 0..12 o INVALID_CHAR_INDEX (-1) si lo perdio.
    // Firers: MenuHandler_Char (elegir/cambiar/"Sin personaje"),
    // LoadPlayerCharChoice (cookie), freechars, Rebuild (personaje robado).
    g_fwdOnCharacterChanged = new GlobalForward("Sonic_OnCharacterChanged", ET_Ignore, Param_Cell, Param_Cell);

    // v3.77.53: biblioteca registrada — LibraryExists("sonic_ability_manager")
    // responde de verdad (el native Sonic_GetPlayerCharIndex ya existia, pero
    // sin library no habia forma limpia de sondear la presencia del manager).
    RegPluginLibrary("sonic_ability_manager");
    return APLRes_Success;
}

public int Native_GetPlayerCharIndex(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    if (!IsValidClient(client)) return -1;
    return g_iPlayerCharIdx[client];
}

// =====================================================================
// v3.77.72 — OM STATUS HUD: EL PANEL DE ESTADOS SIEMPRE VISIBLE
// Pedido del owner: "mejor interfaz gui y demas que puedan mostrar los
// estados. Ejemplo la evasion de sonic que esa ventana sea siempre
// visible para que se pueda ver la eva del mismo. o cuanta llama de
// blaze lleva acumulada y cosas asi" + "los enfriamientos de cream
// blaze eggman y bueno silver deben verse ya que no se ven".
// Un KeyHintText por jugador (tick 0.5s) con las pasivas y los
// cooldowns del personaje ACTIVO: Sonic (EVA: anillos + gracia),
// Blaze (llama SOL + Z/X), Silver (energia + Z/X/C + SPACE), Cream
// (Z/X/C), Eggman (Z/X/C/B + doble salto). El KeyHintText persiste
// en pantalla hasta que otro lo reemplace — exactamente la "ventana
// siempre visible" que pidio. Al cambiar de personaje/morir se LIMPIA
// para que no quede congelado el panel del personaje viejo.
// =====================================================================
ConVar g_cvOMHud;
bool   g_bOMHudSent[MAXPLAYERS + 1];   // true = ya tiene panel en pantalla
ConVar g_cvOMHudInterval;              // v3.77.89: intervalo del panel (0.25-2.0s)
Handle g_hOMHudTimer = null;           // v3.77.89: handle para recrearlo al cambiar el intervalo
char   g_sOMHudLast[MAXPLAYERS + 1][256]; // v3.77.89: cache de contenido (solo enviar al CAMBIAR)
int    g_iOMHudTick = 0;               // v3.77.89: contador de ticks (keepalive cada 6)

// envia un KeyHintText persistente (vacio = limpiar la ventana)
// v3.77.75 FIX ENGINE ERROR: L4D2 escribe sus usermessages con
// BITBUFFER (BfWrite) — la v3.77.72 usaba PbSetString (la API protobuf
// de CS:GO): error nativo en runtime -> EndMessage() NUNCA se
// ejecutaba -> el mensaje quedaba ABIERTO en el motor ->
// "UserMessageBegin: New message started before matching call to
// EndMessage" (el crasheo reportado). Receta exacta del PrintHintText
// del halflife.inc oficial: BfWriteString + EndMessage SIEMPRE.
void OM_SendKeyHint(int client, const char[] text)
{
    Handle msg = StartMessageOne("KeyHintText", client);
    if (msg == null) return;
    BfWriteString(msg, text);
    EndMessage();
}

// SONIC: la EVASION siempre visible — anillos (el escudo que come el
// dano antes que la vida) + la gracia post-esquiva + el dodge ON/OFF
void OM_HudSonic(int client, char[] out, int maxlen, float now)
{
    int n = 0;
    bool rings = (g_cvSonicRings != null && g_cvSonicRings.BoolValue);
    bool dodge = (g_cvSonicDodge != null && g_cvSonicDodge.BoolValue);

    if (rings)
    {
        int mx = (g_cvSonicRingsMax != null) ? g_cvSonicRingsMax.IntValue : 50;
        n += Format(out[n], maxlen - n, "SONIC  EVA — Anillos %d/%d", g_iSonicRings[client], mx);
    }
    else
        n += Format(out[n], maxlen - n, "SONIC  EVA");

    if (dodge && n < maxlen - 14)
        n += Format(out[n], maxlen - n, "  [dodge ON]");
    if (now < g_fSonicDodgeGraceUntil[client] && n < maxlen - 34)
        n += Format(out[n], maxlen - n, "\nGRACIA DE ESQUIVA: %.1fs", g_fSonicDodgeGraceUntil[client] - now);
    if (n < maxlen - 60)
        n += Format(out[n], maxlen - n, "\nCon anillos: el dano golpea los anillos primero");
}

public Action T_OMStatusHUD(Handle timer)
{
    // si apagan sm_omhud en caliente: limpiar el panel de TODAS las
    // pantallas UNA vez (sin esto la ultima ventana quedaria congelada)
    static bool sHudWasOn = true;
    bool hudOn = (g_cvOMHud != null && g_cvOMHud.BoolValue);
    if (!hudOn && sHudWasOn)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            // v3.77.79: el host de modo solo es fake pero SI ve el HUD
            if (IsClientInGame(i) && (!IsFakeClient(i) || Sonic_IsSoloHost(i)) && g_bOMHudSent[i])
            {
                OM_SendKeyHint(i, "");
                g_bOMHudSent[i] = false;
            }
        }
    }
    sHudWasOn = hudOn;
    if (!hudOn) return Plugin_Continue;
    g_iOMHudTick++;   // v3.77.89: contador del keepalive

    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        // v3.77.79: el host de modo solo es fake pero SI ve el HUD
        if (!IsClientInGame(i) || (IsFakeClient(i) && !Sonic_IsSoloHost(i))) continue;

        char txt[256];
        txt[0] = '\0';
        int idx = g_iPlayerCharIdx[i];

        if (IsPlayerAlive(i) && idx >= 0 && idx < MAX_CHARS)
        {
            switch (idx)
            {
                case SONIC_INDEX:   OM_HudSonic(i, txt, sizeof(txt), now);
                case BLAZE_INDEX:   Blaze_HUDLine(i, txt, sizeof(txt), now);
                case SILVER_INDEX:  Silver_HUDLine(i, txt, sizeof(txt), now);
                case CREAM_INDEX:   Cream_HUDLine(i, txt, sizeof(txt), now);
                case EGGMAN_INDEX:  Eggman_HUDLine(i, txt, sizeof(txt), now);
            }
        }

        if (txt[0] != '\0')
        {
            // v3.77.89 OPTIMIZACION: solo enviar si el CONTENIDO cambio (o
            // keepalive cada 6 ticks ~3s: otro plugin pudo pisar la ventana
            // y hay que reafirmarla). El panel persiste en el cliente hasta
            // que otro hint lo reemplace — re-enviar el mismo texto cada
            // tick era puro overhead de usermessage (2/s por jugador).
            if (strcmp(g_sOMHudLast[i], txt) != 0 || (g_iOMHudTick % 6) == 0)
            {
                OM_SendKeyHint(i, txt);
                strcopy(g_sOMHudLast[i], sizeof(g_sOMHudLast[]), txt);
            }
            g_bOMHudSent[i] = true;
        }
        else if (g_bOMHudSent[i])
        {
            // cambio de personaje / murio / sin panel: LIMPIAR la
            // ventana para que no quede congelada la del anterior
            OM_SendKeyHint(i, "");
            g_bOMHudSent[i] = false;
            g_sOMHudLast[i][0] = '\0';   // v3.77.89: cache fuera tambien
        }
    }
    return Plugin_Continue;
}

// =====================================================================
// v3.77.89 — SC PAUSA: EL SISTEMA DE PETICIONES DE PAUSA DEL OWNER
// Pedido: "SC necesita opcion de peticion/disparador de pausa: al salir
// del saferoom u otras ocasiones; al atravesar modelos se desincronizan
// los locales y queda chueco el cuerpo; en conexiones a mitad la pausa
// debe conservarse". Motor = PauseFix Zero-Net de Tails v5.21 (100%
// server-side: CERO ClientCommand, respeta sv_pausable, rate limiter
// anti-flicker). Tres disparadores + manual:
//   [1] sc_pausa_salida   — el equipo sale del saferoom (todos apiñados
//                           en la puerta = el momento clave de atravesar
//                           modelos): player_left_start_area/checkpoint.
//   [2] sc_pausa_conexion — primer spawn de quien entra con la ronda ya
//                           andando (conexion/reconexion a mitad): su
//                           vista y cuerpo aun no estan encajados.
//   [3] sm_scpausa        — MANUAL: cualquiera (o consola -> host en modo
//                           solo) pide el pulso YA, para cuando el cuerpo
//                           se vea chueco en cualquier otro momento.
// Cada peticion pasa por el rate limiter del motor (tails_pausefix_spacing)
// + un spacing propio del sistema (sc_pausa_min).
// =====================================================================
ConVar g_cvSCPausa;
ConVar g_cvSCPausaSalida;
ConVar g_cvSCPausaConexion;
ConVar g_cvSCPausaMin;
ConVar g_cvSCPausaAviso;
bool   g_bSCLeftStart   = false;   // ya salieron del saferoom esta ronda
float  g_fSCLastSCPulse = -100.0;  // ultima peticion SC aceptada (spacing propio)
bool   g_bSCConnPulsed[MAXPLAYERS + 1];   // ya se le dio el pulso de entrada esta ronda

// Envia la peticion al motor de pulsos (con gates propios del sistema SC)
void SC_Pause_Request(int client, const char[] reason, bool manual)
{
    if (g_cvSCPausa == null || !g_cvSCPausa.BoolValue) return;
    if (client < 1 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client)) return;

    // spacing propio del sistema SC (independiente del spacing del motor:
    // dos capas anti-spam)
    float now = GetEngineTime();
    float smin = (g_cvSCPausaMin != null) ? g_cvSCPausaMin.FloatValue : 6.0;
    if (now - g_fSCLastSCPulse < smin)
    {
        if (manual)
            PrintToChat(client, "\x01[\x04SC\x01] Pausa pedida hace poco (minimo %.0fs entre peticiones).", smin);
        return;
    }
    g_fSCLastSCPulse = now;

    if (manual && g_cvSCPausaAviso != null && g_cvSCPausaAviso.BoolValue)
        PrintToChatAll("\x01[\x04SC\x01] Pausa de re-sincronizacion pedida (\x03%s\x01)...", reason);

    LogMessage("[SC-PAUSA] peticion: %s (cliente %d, %s)", reason, client, manual ? "manual" : "automatica");
    Tails_PF_RequestPulse(client, reason);
}

// [1] salida del saferoom: el primer survivor que cruza dispara el pulso
public void Event_SCLeftStart(Event event, const char[] name, bool dontBroadcast)
{
    g_bSCLeftStart = true;
    if (g_cvSCPausaSalida == null || !g_cvSCPausaSalida.BoolValue) return;

    // resolver a quien: el humano del evento, o el primer humano en juego
    int target = GetClientOfUserId(event.GetInt("userid"));
    if (target < 1 || target > MaxClients || !IsClientInGame(target) || IsFakeClient(target))
    {
        for (int i = 1; i <= MaxClients; i++)
            if (IsClientInGame(i) && !IsFakeClient(i)) { target = i; break; }
    }
    if (target > 0)
        SC_Pause_Request(target, "salida del saferoom", false);
}

// [3] manual: sm_scpausa / sm_pausa
public Action Cmd_SCPausa(int client, int args)
{
    client = Sonic_SoloClient(client);   // consola/fake -> tu jugador (modo solo)
    if (client < 1 || client > MaxClients || !IsClientInGame(client))
    {
        ReplyToCommand(client, "[SC] No hay jugador para pedir la pausa.");
        return Plugin_Handled;
    }
    SC_Pause_Request(client, "manual (sm_scpausa)", true);
    return Plugin_Handled;
}

// v3.77.89 — reset por ronda (round_start) y por mapa (OnMapStart)
void SC_Pause_RoundReset()
{
    g_bSCLeftStart = false;
    for (int i = 1; i <= MaxClients; i++)
        g_bSCConnPulsed[i] = false;
}

// la ronda cerro: la proxima arranca fresca (sin salida ni pulsos de entrada)
public void Event_SCRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    SC_Pause_RoundReset();
}

// v3.77.89 — recrear el timer del HUD al cambiar el intervalo en caliente
public void CvarChanged_OMHudInterval(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (g_hOMHudTimer != null)
    {
        KillTimer(g_hOMHudTimer);
        g_hOMHudTimer = null;
    }
    // cache de contenido fuera: el proximo tick re-envia todo
    for (int i = 1; i <= MaxClients; i++)
        g_sOMHudLast[i][0] = '\0';
    g_hOMHudTimer = CreateTimer(g_cvOMHudInterval.FloatValue, T_OMStatusHUD, _, TIMER_REPEAT);
}

// =====================================================================
// v3.77.89 — sm_omdiag: RADIOGRAFIA DE RENDIMIENTO DEL SUITE
// Un solo comando de diagnostico (nada de esto corre periodicamente):
// presupuesto de entidades, avatares vivos, estado del motor de pulsos,
// barrido del CST-Guard y config del HUD + tips de ajuste.
// =====================================================================
public Action Cmd_OMDiag(int client, int args)
{
    client = Sonic_SoloClient(client);   // consola/fake -> tu jugador (modo solo)

    // presupuesto de entidades (L4D2: tope duro ~2048 edicts)
    int ent = GetEntityCount();
    ReplyToCommand(client, "[OM-DIAG] entidades activas: %d%s", ent,
                   ent > 1800 ? "  (!) CERCA DEL TOPE: el spawn de props/avatares puede fallar" : "");

    // avatares OM vivos (barrido unico de diagnostico)
    int avatars = 0;
    int e = -1;
    char tn[64];
    while ((e = FindEntityByClassname(e, "prop_dynamic_override")) != -1)
    {
        GetEntPropString(e, Prop_Data, "m_iName", tn, sizeof(tn));
        if (StrContains(tn, "avatar") != -1)
            avatars++;
    }

    char pf[192], cg[192];
    Tails_PF_Diag(pf, sizeof(pf));
    CSTGuard_Diag(cg, sizeof(cg));

    ReplyToCommand(client, "[OM-DIAG] avatares OM vivos: %d (copias R + L de todos los personajes)", avatars);
    ReplyToCommand(client, "[OM-DIAG] motor de pulsos (Tails v5.21): %s", pf);
    ReplyToCommand(client, "[OM-DIAG] CST-Guard v3.1.0: %s", cg);
    ReplyToCommand(client, "[OM-DIAG] HUD: %s | intervalo %.2fs (sm_omhud_interval)",
                   (g_cvOMHud != null && g_cvOMHud.BoolValue) ? "ON" : "OFF",
                   (g_cvOMHudInterval != null) ? g_cvOMHudInterval.FloatValue : 0.5);
    ReplyToCommand(client, "[OM-DIAG] SC pausa: %s | salida=%s | conexion=%s | min=%.0fs",
                   (g_cvSCPausa != null && g_cvSCPausa.BoolValue) ? "ON" : "OFF",
                   (g_cvSCPausaSalida != null && g_cvSCPausaSalida.BoolValue) ? "ON" : "OFF",
                   (g_cvSCPausaConexion != null && g_cvSCPausaConexion.BoolValue) ? "ON" : "OFF",
                   (g_cvSCPausaMin != null) ? g_cvSCPausaMin.FloatValue : 6.0);
    ReplyToCommand(client, "[OM-DIAG] tips: sm_omhud 0 apaga el panel | sm_omhud_interval 1.0 reduce a la mitad los refrescos | sc_pausa_min mas alto = menos pausas | sv_pausable 1 es NECESARIO para que el pulso exista");
    return Plugin_Handled;
}

public void OnPluginStart()
{
    g_iOff_Incapacitated  = FindSendPropInfo("CTerrorPlayer", "m_isIncapacitated");
    g_iOff_PounceAttacker = FindSendPropInfo("CTerrorPlayer", "m_pounceAttacker");
    g_iOff_TongueOwner    = FindSendPropInfo("CTerrorPlayer", "m_tongueOwner");
    g_iOff_JockeyAttacker = FindSendPropInfo("CTerrorPlayer", "m_jockeyAttacker");
    g_iOff_PummelAttacker = FindSendPropInfo("CTerrorPlayer", "m_pummelAttacker");
    g_iOff_CarryAttacker  = FindSendPropInfo("CTerrorPlayer", "m_carryAttacker");
    g_iOff_LaggedMovement = FindSendPropInfo("CTerrorPlayer", "m_flLaggedMovementValue");
    g_iOff_Velocity       = FindSendPropInfo("CBasePlayer",   "m_vecVelocity[0]");

    g_cvSJEnable   = CreateConVar("sj_enable", "1", "Habilita el plugin", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvSJVolume   = CreateConVar("sj_volume", "1.0", "Volumen global", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvSJCooldown = CreateConVar("sj_cooldown", "0.15", "Cooldown salto", FCVAR_NOTIFY, true, 0.0, true, 5.0);
    g_cvSonicBoost = CreateConVar("sj_sonicboost", "1.0", "Multiplicador impulso", FCVAR_NOTIFY);
    g_cvVelZMin    = CreateConVar("sj_velzmin", "200.0", "Velocidad Z minima", FCVAR_NOTIFY);

    // v3.77.46: OM AIR CONTROL (impulso de salto + steering aereo)
    g_cvOMAirControl  = CreateConVar("om_aircontrol", "1", "v3.77.46: impulso al saltar + steering aereo para Rouge/Knuckles/Amy/Sonic/Metal", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvOMAirImpulse  = CreateConVar("om_air_impulse", "160.0", "v3.77.46: impulso hacia adelante al saltar (0 = off)", FCVAR_NOTIFY, true, 0.0, true, 1000.0);
    g_cvOMAirAccel    = CreateConVar("om_air_accel", "12.0", "v3.77.46: aceleracion WASD en el aire (receta Knuckles)", FCVAR_NOTIFY, true, 0.0, true, 100.0);
    g_cvOMAirMax      = CreateConVar("om_air_maxspeed", "300.0", "v3.77.46: tope de velocidad horizontal del steering aereo", FCVAR_NOTIFY, true, 0.0, true, 1000.0);

    HookEvent("player_jump", Event_PlayerJump, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
    HookEvent("round_start", OnRoundStart);
    HookEvent("player_spawn", Event_PlayerSpawn);

    // v3.77.79 — MODO SOLO: takeover del host local + watchdog que mantiene
    // fresco el cache y su root (en servidor dedicado el timer se muere solo
    // en el primer latido: cero overhead para el server de siempre).
    HookEvent("player_bot_replace", Event_SoloPlayerBotReplace, EventHookMode_Post);
    CreateTimer(2.0, T_SonicSoloWatchdog, _, TIMER_REPEAT);

    RegConsoleCmd("sm_sjs_ability1", Command_Ability1, "Habilidad Primaria (Tecla Z)");
    RegConsoleCmd("sm_sjs_ability2", Command_Ability2, "Habilidad Secundaria (Tecla X)");
    // v3.61 (R27): la HABILIDAD 3 es comando UNICO del suite (tecla C):
    // Amy = cambio de MODO (impulso <-> AOE, SIN cd), Sage = cambio de
    // SET (R26). La 4 sigue reservada para el "modo propio" de Sage.
    RegConsoleCmd("sm_sjs_ability3", Command_Ability3, "Habilidad 3 (Sonic: Homing | Tails: modo canon | Rouge: Bat Bomb | Knuckles: Meteoro | Sage: set | Amy: LANZAMIENTO en la tecla V)");
    RegConsoleCmd("sm_sjs_ability4", Command_Ability4, "Habilidad 4 (Tecla B) - Amy: ALTERNA MODO DEL MARTILLO (bumeran <-> comun) | Rouge: ONDA NEGRA | Sage: cartas del super tank (set AMY prestado)");

    // v3.77.60: EL CUADRO DE DEFENSAS — pedido del owner: "debe haber un
    // cuadro que muestre la reduccion de dano general para todos los
    // supervivientes". Muestra la reduccion ACTUAL de cada superviviente
    // vivo con su fuente (cartas de Amy, Furia, pasivas de personaje,
    // anillos, estados de carga). Dos alias + version por consola.
    RegConsoleCmd("sm_defensas", Command_Defensas, "Muestra el cuadro de reduccion de dano de TODO el equipo (v3.77.60)");
    RegConsoleCmd("sm_reducciones", Command_Defensas, "Alias de sm_defensas");

    // v3.77.72: OM STATUS HUD — el panel de estados SIEMPRE visible
    // (KeyHintText: evasion de Sonic, llama SOL de Blaze, energia
    // de Silver, cooldowns Z/X/C/B de los kits). sm_omhud 0 lo apaga.
    // v3.77.89 OPTIMIZACION: intervalo configurable (sm_omhud_interval,
    // default 0.5) + cache de contenido (solo envia cuando el texto
    // cambia; keepalive cada 6 ticks por si otro plugin pisa la ventana).
    g_cvOMHud = CreateConVar("sm_omhud", "1", "v3.77.72: panel de estados SIEMPRE visible en pantalla (EVA de Sonic con anillos y gracia, LLAMA SOL de Blaze, ENERGIA de Silver, cooldowns Z/X/C/B de Cream/Blaze/Eggman/Silver)", _, true, 0.0, true, 1.0);
    g_cvOMHudInterval = CreateConVar("sm_omhud_interval", "0.5", "v3.77.89: segundos entre refrescos del panel de estados (0.25 = mas fluido / 1.0-2.0 = la mitad o menos de usermessages: subelo si el server va cargado)", _, true, 0.25, true, 2.0);
    g_cvOMHudInterval.AddChangeHook(CvarChanged_OMHudInterval);
    g_hOMHudTimer = CreateTimer(g_cvOMHudInterval.FloatValue, T_OMStatusHUD, _, TIMER_REPEAT);

    // =====================================================================
    // v3.77.89 — SC PAUSA: peticiones de pausa del owner (ver bloque
    // completo antes de OnPluginStart). Motor = PauseFix Zero-Net de
    // Tails v5.21 (100% server-side, respeta sv_pausable, rate limiter).
    // =====================================================================
    g_cvSCPausa          = CreateConVar("sc_pausa", "1", "v3.77.89: sistema de peticiones de pausa de re-sincronizacion (salida del saferoom / conexion a mitad de ronda / sm_scpausa manual)", _, true, 0.0, true, 1.0);
    g_cvSCPausaSalida    = CreateConVar("sc_pausa_salida", "1", "v3.77.89: pulso de re-sincronizacion al salir del saferoom (el momento de apiñarse en la puerta y atravesar modelos)", _, true, 0.0, true, 1.0);
    g_cvSCPausaConexion  = CreateConVar("sc_pausa_conexion", "1", "v3.77.89: pulso en el primer spawn de quien entra con la ronda ya andando (conexion/reconexion a mitad)", _, true, 0.0, true, 1.0);
    g_cvSCPausaMin       = CreateConVar("sc_pausa_min", "6.0", "v3.77.89: minimo de segundos entre peticiones SC (ademas del spacing del motor tails_pausefix_spacing)", _, true, 1.0, true, 60.0);
    g_cvSCPausaAviso     = CreateConVar("sc_pausa_aviso", "1", "v3.77.89: linea de chat al pedir la pausa manual (sm_scpausa)", _, true, 0.0, true, 1.0);
    HookEvent("player_left_start_area",  Event_SCLeftStart);
    HookEvent("player_left_checkpoint",  Event_SCLeftStart);
    HookEvent("round_end",               Event_SCRoundEnd);
    RegConsoleCmd("sm_scpausa", Cmd_SCPausa, "Pide una pausa de re-sincronizacion YA (arregla el cuerpo chueco / desync al atravesar modelos)");
    RegConsoleCmd("sm_pausa",  Cmd_SCPausa, "Alias de sm_scpausa");

    // v3.77.89: diagnostico de rendimiento del suite
    RegConsoleCmd("sm_omdiag", Cmd_OMDiag, "Diagnostico de rendimiento: entidades, avatares, motor de pulsos, barrido CST, HUD (v3.77.89)");

    RegConsoleCmd("js", Cmd_OpenSoundMenu);
    RegConsoleCmd("sc", Cmd_OpenCharMenu);
    RegConsoleCmd("cinfo", Cmd_ShowCharInfo);
    RegConsoleCmd("sm_forceragdoll", Cmd_CreateRagdoll);
    RegConsoleCmd("sm_sjsver", Cmd_ShowSuiteVersion, "Version del suite cargada EN MEMORIA (manager + Amy)");
    RegConsoleCmd("sm_sbarprobe", SBar_ProbeCmd, "v3.77.84: sonda del canal de la barra (1=chat lightgreen | 2=chat green-amarillo | 3=chat red | 4=chat blue | 5=hint plano | 6=barra real)");

    RegAdminCmd("sm_setsound", Cmd_OpenSoundMenu, ADMFLAG_GENERIC);
    RegAdminCmd("freechars", Cmd_FreeAllChars, ADMFLAG_GENERIC);

    g_hSoundCookie = RegClientCookie("sj_sound_choice", "Sonic Sound", CookieAccess_Public);
    g_hCharCookie  = RegClientCookie("sj_char_choice", "Sonic Char", CookieAccess_Public);

    for (int i = 0; i < MAX_CHARS; i++) g_iCharTakenBy[i] = 0;
    for (int i = 1; i <= MaxClients; i++) g_iPlayerCharIdx[i] = INVALID_CHAR_INDEX;

    g_mCharOwner = new StringMap();
    BuildPath(Path_SM, g_sOwnersFile, sizeof(g_sOwnersFile), "data/sonic_jump_survivors_owners.cfg");
    LoadOwnersFromFile();

    Speed_OnPluginStart();
    // v3.76.1 FIX ARRANQUE SONIC: este slot llamaba Sonic_OnMapStart()
    // (herencia del v5.4, que NO tenia Sonic_OnPluginStart) y el v6.0-OM
    // NUNCA se inicializaba: 0 convars sonicom_* (Invalid convar handle 0
    // en cada OnClientPutInServer), 0 comandos y FSM del avatar muerta.
    // Ahora SI se cablea el OnPluginStart (convars+comandos+timer 10Hz).
    Sonic_OnPluginStart();
    Sonic_OnMapStart();   // late-load pristino: precache si carga a mitad de mapa
    Tails_OnPluginStart();
    Knuckles_OnPluginStart();
    Amy_OnPluginStart();
    Sally_OnPluginStart();
    Doll_OnPluginStart();
    RegConsoleCmd("sm_dollcontrol", Doll_CommandControl, "Amy controla a Sally (Doll)");
    RegConsoleCmd("sm_resize", Doll_CommandResize, "Cambiar tamano de Sally (Doll)");
    RegConsoleCmd("sm_dolldebug", Doll_CommandDebug, "Estado del sistema Doll (debug)");
    Shadow_OnPluginStart();
    Rouge_OnPluginStart();
    Cream_OnPluginStart();
    SBar_OnPluginStart();    // v3.77.84: EL MOTOR DE BARRAS v3.0 (CHAT con colors.inc + throttle anti-spam: Llama Sol de Blaze / Vuelo de Silver / Anillos de Sonic)
    CreateTimer(SBAR_REFRESH, T_SBarThink, _, TIMER_REPEAT);   // v3.77.81: latido 5 Hz — SIN NO_MAPCHANGE: cruza cambios de mapa
    Blaze_OnPluginStart();    // v3.77.69: avatar espejo Blaze (10o, modelo CST)    Blaze_OnPluginStart();    // v3.77.69: avatar espejo Blaze (10o, modelo CST)
    Silver_OnPluginStart();   // v3.77.69: avatar espejo Silver (11o, modelo CST)
    Kolossos_OnPluginStart(); // v3.77.94: el colosal de OM (14o avatar, kit de 4 habilidades)
    Sage_OnPluginStart();   // v3.60 (R26): comandos de la clase ADM
    Metal_OnPluginStart();
    // v3.76.4: ciclo de vida del OM_Stun CABLEADO por fin. Existia desde
    // Metal v4.0 pero NADIE llamaba estas funciones: sin OnPluginStart no
    // existian los convars om_stun_*, y sin OnMapStart nunca se detectaba
    // el VPK (g_bOMStunAssets false + glow 0) -> el stun congelaba y
    // tintaba pero SIN estrellas y SIN sonido zap. Con Sonic v6.4 usando
    // el mismo sistema, queda arreglado para los dos.
    OM_Stun_OnPluginStart();
    Eggman_OnPluginStart();

    // Sistema Doll Modular (por SteamID + menú de poderes)
    DollSys_OnPluginStart();

    // v3.77.65 (= 3.77.59): PATHSENSE («Sentido de la Ruta»): el punto
    // de control de la pasiva de ruta (l4d_path_to_goal). Va ANTES del
    // AutoExecConfig Y del SuiteCfg_CollectAndHook A PROPÓSITO: así sus
    // cvars pathsense_* nacen ANTES de que se enganchen al auto-guardado
    // del Sonic_Suite.cfg (y de que el archivo auto-generado se escriba).
    // Y también antes del bucle de late-load, por la MISMA razón que el
    // guard: ese bucle dispara LoadPlayerCharChoice -> FireCharSignal ->
    // PathSense_OnCharSignal y cvars/comandos tienen que existir ya.
    PathSense_Init();

    // AVATARHIDE: mismo patron que PathSense — ANTES del AutoExecConfig
    // para que avatarhide_enable / avatarhide_viewmodel nazcan dentro
    // del Sonic_Suite.cfg auto-guardado, y antes del bucle de late-load
    // porque FireCharSignal -> AvatarHide_OnCharSignal necesita los
    // cvars vivos.
    AvatarHide_Init();

    // v3.75 CONFIG UNICA: UN solo archivo para TODOS los cvars del
    // suite (los 145) + auto-guardado (ver bloque SuiteCfg_* abajo).
    // Los 9 AutoExecConfig por modulo (Tails_Abilities.cfg,
    // Speed_Sonic.cfg, sonic_jump_survivors.cfg, ...) quedaron
    // ELIMINADOS: ese enjambre de archivos que se pisaban entre si
    // era la causa del "canon en 45s que nunca cambia".
    // v3.77.8: eliminacion COMPLETA — Sally/Cream/Eggman eran los
    // ultimos 3 modulos con llamada viva (por eso sus cfg seguian
    // regenerandose con la lista completa del plugin). Ademas el
    // saneador SuiteCfg_DeleteLegacyFiles BORRA del server los 9
    // archivos residuales.
    AutoExecConfig(true, "Sonic_Suite");
    SuiteCfg_CollectAndHook();
    SuiteCfg_DeleteLegacyFiles();

    // v3.77.54 — EL GUARD ARRANCA ANTES del bucle de late-load A PROPOSITO:
    // ese bucle llama LoadPlayerCharChoice -> FireCharSignal -> CSTGuard_Signal,
    // asi que el guard ya tiene que estar vivo (cvars creadas, StringMaps y
    // comandos registrados, eventos hookeados con prefijo CSTG_*: cero
    // colision con los de este manager, watchdog y probe del CST lanzados).
    // A partir de aqui, FireCharSignal le habla DIRECTO (mismo frame).
    CSTGuard_Init();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && AreClientCookiesCached(i))
        {
            LoadPlayerSoundChoice(i);
            LoadPlayerCharChoice(i);
            MaybePromptMenus(i);
        }
    }
}

// ============================================================
//  v3.75: CONFIG UNICA AUTO-GUARDADA (Sonic_Suite.cfg)
// ============================================================
//  UN archivo manda sobre TODOS los cvars del suite:
//   - cfg/sourcemod/Sonic_Suite.cfg: creado la 1ra vez con los
//     defaults del smx, ejecutado en cada mapa (GANA a server.cfg).
//   - AUTO-GUARDADO: cualquier cambio de un cvar del suite hecho en
//     el server (sm_cvar, consola, otro plugin) se escribe en el
//     archivo ~1s despues (debounce). No hay que editar nada a mano
//     ni pedirle nada a nadie.
//   - Editar el archivo a mano sigue valiendo: aplica al proximo
//     mapa (y el auto-guardado respeta lo que haya en el).
//   - Los archivos viejos por modulo quedan MUERTOS (nada los
//     ejecuta). Se pueden borrar del server sin riesgo.
//
//  Identificacion de los cvars del suite: prefijos de nombre (los
//  145 cvars del plugin usan exactamente estos 11 prefijos). Si
//  algun dia se agrega un cvar con un prefijo NUEVO, agregarlo a
//  g_sSuitePrefixes (si no, simplemente no se auto-guardara).

static const char g_sSuitePrefixes[][] = {
    "sj_", "sm_sonic_", "sonicom_", "tails_", "knux_", "knu_", "amy_", "amyom_", "sally_",
    "sagesally_", "rouge_", "cream_", "eggman_", "om_stun_", "suite_",
    // v3.77.65 (= 3.77.59): los que FALTABAN — shadow_avatar y
    // metalom_avatar nunca se auto-guardaban y el control aéreo om_air*
    // tampoco. Más el prefijo de la pasiva de ruta. knu_ (counter v77)
    // y suite_ (suite_dmg_* de OM_Stun v2.2) son los nuevos de ESTE árbol.
    "shadow_", "metalom_", "om_air", "pathsense_",
    // v3.77.105: los TRES personajes que nunca entraron a la lista —
    // reporte del owner con la v1.9: "el grab_ragdoll no aparece en la
    // lista" (los 35 kolossos_* — y con ellos los blaze_* y silver_*,
    // que llevaban el mismo agujero desde la v3.77.70) NO se auto-
    // guardaban en Sonic_Suite.cfg: SuiteCfg_IsOurs los rechazaba.
    "blaze_", "silver_", "kolossos_"
};


// v3.77.59 — LAS CATEGORÍAS DEL CFG: cada sección del Sonic_Suite.cfg
// agrupa los cvars por personaje o sistema. (A) títulos en orden de
// escritura (el orden del menú de personajes + los sistemas al final);
// (B) la ficha de cada sección (comandos + resumen; \n = línea nueva);
// (C) prefijos -> sección. Un cvar cuyo prefijo no figure en (C) cae a
// la sección final «SIN CATEGORÍA»: nunca se pierde.
static const char g_SuiteCatTitles[][] = {
    "SONIC — Movilidad OM (spindash / peel out / homing / anillos / avatar)",
    "TAILS — Vuelo / Cañón omnidireccional / Avatar remoto",
    "KNUCKLES — Puño prop / Postura counter / Meteoro H3",
    "AMY — Martillo con física real / Parry / Tarot",
    "SALLY — Escudos de fuego y agua",
    "SHADOW — Avatar / Chaos Snap / Chaos Blast",
    "ROUGE — Vuelo con energía / Barrido / Counter / Bat Bomb / Onda",
    "CREAM — Curación / Dash / Revivir",
    "METAL SONIC — Embestida / Overdrive / Self Repair",
    "DR. EGGMAN — Minas / Láser / Jet",
    "SAGE — Sets prestados (clase ADM)",
    "BLAZE — Patada / Lanza Solar / Meteoro / Avatar",
    "SILVER — Rocas / Vuelo psíquico / Avatar",
    "KOLOSSOS — El Coloso de OM (Avalancha / Agarre ragdoll / Indicator / Bloqueo)",
    "PATHSENSE — «Sentido de la Ruta» (pasiva Path To Goal)",
    "UTILIDADES — Salto base / Stun OM unificado / menús y sistema"
};

static const char g_SuiteCatInfo[][] = {
    /* SONIC */
    "Comandos: sm_sonicspindash | sm_sonicpeelout | sm_sonichoming |\nsm_sonicwind | sm_soniccd (teclas Z/X/C/V del manager) |\nsm_sonic (velocidad base) | sm_sonicmenu.\nSpindash y dropdash, peel out con pasajeros, homing, anillos, avatar R/L\na prueba de reinicio, trails, esquivas y control aéreo (om_air*).",
    /* TAILS */
    "Comandos: sm_tailscannon (cañón, tecla X) | sm_tailslock | sm_tailscd.\nVuelo con SPACE, cañón omnidireccional de 4 modos, avatar remoto por TP,\ncongelado de SI (capa OM_Stun).",
    /* KNUCKLES */
    "Comandos: sm_knux_punch (puño) | sm_knux_counter (postura) |\nsm_knux_sky (meteoro H3).\nPuño y slam a props, postura = counter físico y de especiales (uppercut v77: la contra aplica stun +\nragdoll volador; la garra de la witch la congela), meteoro, planeo y\nagarre de pared, avatar\nknuckles.mdl con FSM.",
    /* AMY */
    "Comandos: sm_amythrow (martillo V) | sm_amymodo | sm_amycartas |\nsm_amyprop | sm_amyfisica | sm_amysupertank (depuración: sm_amydbg).\nMartillo con física real (lanzamiento V con impulso direccional GMod y\ntumble), B alterna bumerán <-> común por jugador (v108), parry en pose,\ntarot, AOE de la Z, prop-wake. Reducciones del equipo: sm_defensas.",
    /* SALLY */
    "Sin comando directo (teclas del manager; Sage los regala con +5 s).\nEscudo de fuego (aura + explosión) y de agua (burbuja que refleja,\nabsorbe y cura).",
    /* SHADOW */
    "Sin comando directo (Z/X/C del manager + SPACE para el hover).\nChaos Snap (Z), Chaos Blast (X), hover con Anillos Inhibidores; avatar\nshadow.mdl espejo R/L + ragdoll de muerte.",
    /* ROUGE */
    "Comandos: sm_rouge_kick (patada baja) | sm_rouge_bomb (bat bomb) |\nsm_rouge_wave (onda negra) | sm_rouge_sweep (barrido) |\nsm_rouge_counter (contragolpe).\nVuelo real con energía, planeo, agarre de pared, counter con\ndevoluciones (patada baja v10.5: la contra aplica stun + ragdoll\nvolador), cebo + flash, avatar rouge.mdl con FSM.",
    /* CREAM */
    "Comandos: sm_cream_heal | sm_cream_dash | sm_cream_revive.\nCuración en área, dash y revivir (1 por ronda).",
    /* METAL SONIC */
    "Comandos: sm_metal_charge (embestida Z) | sm_metal_overdrive (C) |\nsm_metal_heal (Self Repair X).\nEmbestida por suelo con anti-atasco y liberación de agarres, overdrive\ncon levitación, self repair con aura de soporte; vida máx. 175.",
    /* EGGMAN */
    "Comandos: sm_eggman_mines (minas) | sm_eggman_laser (láser).\nJet integrado (eggman_jet_*).",
    /* SAGE */
    "Comando: sm_sageset (cicla los sets prestados: Amy | Cream | Sally |\nRouge; clase exclusiva ADM).\nLos sagesally_* ajustan los escudos que Sage regala con el set SALLY.",
    /* BLAZE */
    "Sin comando directo (Z patada / X lanza solar / C dash / B meteoro).\nPatada empinada con carga de sol (barra SBar), lanza solar, dash\nde fuego, meteoro H3; avatar blaze.mdl espejo R/L. blaze_cd_scale\nescala TODOS los cooldowns.",
    /* SILVER */
    "Sin comando directo (Z rocas / X agarre psíquico / C vuelo).\nLas rocas psíquicas (daño por roca + cantidad), el vuelo con control\naéreo y el avatar silver.mdl espejo R/L; silver_rocks_* ajustan la\nlluvia de rocas del meteoro.",
    /* KOLOSSOS */
    "Comando: sm_kolossos (estado del kit en consola).\nZ = Avalancha empaladora (kolossos_charge_*), X = Agarre con la\nvíctima en ragdoll colgada del puño (kolossos_grab_*: ragdoll, tilt,\npuños, tank/witch), C = Indicator (glow rojo), B = Bloqueo con\ncontragolpe de roca (kolossos_rock_*), click izq = puño básico\n(kolossos_m1) con el arma congelada. kolossos_grab_ragdoll y\nkolossos_charge_carry son los switches del sistema de ragdolls.",
    /* PATHSENSE */
    "Comandos: sm_pathall [0|1] (la pasiva para TODOS) |\nsm_pathpassive <jugador> [0|1] (concesión manual).\nLa pasiva «Sentido de la Ruta» traza SIEMPRE el camino al refugio u\nobjetivo (plugin independiente l4d_path_to_goal). Nativos por defecto:\nAmy, Sage, Metal Sonic y Tails (pathsense_chars); los admins la llevan\ncon pathsense_admins 1. Requiere l4d_path_to_goal.smx instalado.",
    /* UTILIDADES */
    "Comandos: js | sc (binds) | sm_setsound | freechars | sm_sjsver\n(diagnóstico) | sm_dollcontrol | sm_resize (muñecas).\nsj_* = salto sónico base + sonidos; om_stun_* = el congelado unificado\n(capas de freeze, estrellas, iframes, BOOMER FUSE); suite_dmg_* = el\namplificador híbrido de daño del suite (OM_Stun v2.2)."
};

// (C) prefijos -> sección (mismo índice que g_SuiteCatTitles)
static const char g_SuiteCatPrefixes[][] = {
    "sonicom_", "sm_sonic_", "om_air",
    "tails_",
    "knux_", "knu_",
    "amy_", "amyom_",
    "sally_",
    "shadow_",
    "rouge_",
    "cream_",
    "metalom_",
    "eggman_",
    "sagesally_",
    "blaze_",
    "silver_",
    "kolossos_",
    "pathsense_",
    "sj_", "om_stun_", "suite_"
};
static const int g_SuiteCatOf[] = {
    0, 0, 0,
    1,
    2, 2,
    3, 3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,        // blaze_
    12,        // silver_
    13,        // kolossos_
    14,        // pathsense_
    15, 15, 15
};

// ¿A qué sección pertenece un cvar? -1 = sin categoría (va al final).
int SuiteCfg_CategoryOf(const char[] name)
{
    for (int i = 0; i < sizeof(g_SuiteCatPrefixes); i++)
    {
        int len = strlen(g_SuiteCatPrefixes[i]);
        if (strncmp(name, g_SuiteCatPrefixes[i], len) == 0)
            return g_SuiteCatOf[i];
    }
    return -1;
}

bool   g_bSuiteCfgLoading   = true;   // fase de configs: suprime el auto-guardado (el archivo se esta aplicando a si mismo)
Handle g_hSuiteCfgSaveTimer = null;  // debounce de 1s del auto-guardado

bool SuiteCfg_IsOurs(const char[] name)
{
    for (int i = 0; i < sizeof(g_sSuitePrefixes); i++)
    {
        int len = strlen(g_sSuitePrefixes[i]);
        if (strncmp(name, g_sSuitePrefixes[i], len) == 0)
            return true;
    }
    return false;
}

// Hookea TODOS los cvars vivos del suite para el auto-guardado. Se
// llama al final de OnPluginStart: todos los modulos ya crearon los
// suyos (orden de llamadas: 1444-1459, antes del AutoExecConfig).
void SuiteCfg_CollectAndHook()
{
    char name[64];
    bool isCmd; int flags;

    Handle search = FindFirstConCommand(name, sizeof(name), isCmd, flags);
    if (search == INVALID_HANDLE) return;

    int hooked = 0;
    do {
        if (isCmd) continue;
        if (!SuiteCfg_IsOurs(name)) continue;

        ConVar cv = FindConVar(name);
        if (cv != null)
        {
            HookConVarChange(cv, OnSuiteCvarChanged);
            hooked++;
        }
    } while (FindNextConCommand(search, name, sizeof(name), isCmd, flags));
    CloseHandle(search);

    LogMessage("[Suite] Config unica Sonic_Suite.cfg: %d cvars bajo auto-guardado", hooked);
}

// v3.77.8: SANEADOR DE CFG LEGACY. Los AutoExecConfig por modulo ya
// estan TODOS muertos (v3.75 mato Tails/Speed/sonic_jump/Knuckles/
// Amy/Sally/Rouge; v3.77.8 mato los ultimos 3 vivos: Sally/Cream/
// Eggman), pero los archivos residuales generados por versiones
// viejas siguen tirados en cfg/sourcemod/ del servidor y SEGUian
// "apareciendo" porque cada AutoExecConfig de un modulo escribia
// TODOS los cvars del PLUGIN entero ("ConVars for plugin
// Sonic_ability_manager.smx") — por eso cada archivo individual
// traia "la misma lista" que Sonic_Suite.cfg: puro duplicado muerto
// que ademas pisaba valores al ejecutarse. Esto los borra de raiz:
// se llama al cargar/recargar el plugin (OnPluginStart).
static const char g_sSuiteLegacyCfgs[][] = {
    "cfg/sourcemod/Tails_Abilities.cfg",
    "cfg/sourcemod/Speed_Sonic.cfg",
    "cfg/sourcemod/sonic_jump_survivors.cfg",
    "cfg/sourcemod/Knuckles_Abilities.cfg",
    "cfg/sourcemod/Amy_Abilities.cfg",
    "cfg/sourcemod/Sally_Abilities.cfg",
    "cfg/sourcemod/Rouge_Abilities.cfg",
    "cfg/sourcemod/Cream_Abilities.cfg",
    "cfg/sourcemod/Eggman_Abilities.cfg"
};

void SuiteCfg_DeleteLegacyFiles()
{
    int removed = 0;
    char first[128];
    for (int i = 0; i < sizeof(g_sSuiteLegacyCfgs); i++)
    {
        if (!FileExists(g_sSuiteLegacyCfgs[i]))
            continue;

        if (DeleteFile(g_sSuiteLegacyCfgs[i]))
        {
            if (removed == 0)
                strcopy(first, sizeof(first), g_sSuiteLegacyCfgs[i]);
            removed++;
        }
        else
        {
            LogMessage("[Suite] v3.77.8 WARNING: no se pudo borrar %s (permisos? abierto?)", g_sSuiteLegacyCfgs[i]);
        }
    }

    if (removed > 0)
        LogMessage("[Suite] v3.77.8: %d cfg individuales residuales BORRADOS del server (ej. %s). Unica config: Sonic_Suite.cfg", removed, first);
}

public void OnSuiteCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    // Durante la fase de configs (carga del mapa) el propio archivo
    // se esta ejecutando: esos cambios no disparan el auto-guardado.
    if (g_bSuiteCfgLoading) return;

    // Debounce: el primer cambio arma el timer de 1s; los cambios
    // siguientes dentro de la ventana se absorben. Al disparar se
    // graba el archivo COMPLETO con los valores ya definitivos.
    if (g_hSuiteCfgSaveTimer == null)
        g_hSuiteCfgSaveTimer = CreateTimer(1.0, T_SuiteCfgSave);
}

public Action T_SuiteCfgSave(Handle timer)
{
    g_hSuiteCfgSaveTimer = null;
    SuiteCfg_Save();
    return Plugin_Stop;
}

// v3.77.59 — Reescribe COMPLETO el archivo unico con los valores VIVOS
// de todos los cvars del suite, AGRUPADOS POR CATEGORIAS: cada seccion
// lleva su cabecera (a quien pertenece, que hace y SUS comandos) y los
// cvars con su descripcion de referencia. La usa el auto-guardado (cual
//quier cambio ~1 s despues) y la reconciliacion de OnConfigsExecuted.
void SuiteCfg_Save()
{
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "../../cfg/sourcemod/Sonic_Suite.cfg");

    File f = OpenFile(path, "w");
    if (f == null)
    {
        LogMessage("[Suite] ERROR: no pude escribir %s (auto-guardado omitido)", path);
        return;
    }

    f.WriteLine("// ==================================================================");
    f.WriteLine("//  SONIC SUITE - CONFIG UNICA (v3.77.65: organizada por categorias)");
    f.WriteLine("//  - Cada seccion agrupa los cvars de un personaje o sistema; la");
    f.WriteLine("//    cabecera dice a quien pertenece, que hace y sus comandos.");
    f.WriteLine("//  - Cambiar algo EN EL SERVER (ej: sm_cvar tails_laser_cooldown 10)");
    f.WriteLine("//    se guarda SOLO en este archivo ~1 segundo despues (misma seccion).");
    f.WriteLine("//  - Editar un valor AQUI -> aplica en el proximo mapa.");
    f.WriteLine("//  - Este archivo gana a server.cfg (se ejecuta despues).");
    f.WriteLine("//  - La ultima seccion recoge cvars de prefijos nuevos que todavia");
    f.WriteLine("//    no tienen categoria asignada (nunca se pierden).");
    f.WriteLine("// ==================================================================");

    char name[64], value[96], desc[96];
    bool isCmd; int flags;

    // Una pasada por categoria: cabecera + sus cvars. Las categorias sin
    // cvars vivos no se escriben (nada de secciones vacias).
    for (int cat = 0; cat < sizeof(g_SuiteCatTitles); cat++)
    {
        Handle search = FindFirstConCommand(name, sizeof(name), isCmd, flags);
        if (search == INVALID_HANDLE) continue;

        int written = 0;
        do {
            if (isCmd) continue;
            if (!SuiteCfg_IsOurs(name)) continue;
            if (SuiteCfg_CategoryOf(name) != cat) continue;

            if (written == 0)
            {
                f.WriteLine("");
                f.WriteLine("// ==================================================================");
                f.WriteLine("//  [%d] %s", cat + 1, g_SuiteCatTitles[cat]);

                // la ficha de la seccion (comandos + resumen): \n = linea
                char line[176];
                int len = strlen(g_SuiteCatInfo[cat]);
                int li = 0;
                for (int p = 0; p <= len; p++)
                {
                    int ch = 10;
                    if (p < len) ch = g_SuiteCatInfo[cat][p];
                    if (ch == '\n')
                    {
                        line[li] = '\0';
                        if (li > 0) f.WriteLine("//  %s", line);
                        li = 0;
                    }
                    else if (li < sizeof(line) - 1) { line[li] = ch; li++; }
                }

                f.WriteLine("// ==================================================================");
            }

            ConVar cv = FindConVar(name);
            if (cv == null) continue;

            cv.GetString(value, sizeof(value));
            cv.GetDescription(desc, sizeof(desc));

            // descripciones de varias lineas: cortar en el primer \n
            int nl = FindCharInString(desc, '\n');
            if (nl >= 0) desc[nl] = 0;

            if (desc[0] != 0)
                f.WriteLine("// %s", desc);
            f.WriteLine("%s \"%s\"", name, value);
            written++;
        } while (FindNextConCommand(search, name, sizeof(name), isCmd, flags));
        CloseHandle(search);
    }

    // v3.77.59: cvars del suite SIN categoria (prefijos nuevos de futuras
    // versiones): nunca se pierden, van al final con su aviso.
    Handle search = FindFirstConCommand(name, sizeof(name), isCmd, flags);
    if (search != INVALID_HANDLE)
    {
        int extra = 0;
        do {
            if (isCmd) continue;
            if (!SuiteCfg_IsOurs(name)) continue;
            if (SuiteCfg_CategoryOf(name) != -1) continue;

            if (extra == 0)
            {
                f.WriteLine("");
                f.WriteLine("// ==================================================================");
                f.WriteLine("//  [?] SIN CATEGORIA — cvars de prefijos nuevos sin seccion asignada");
                f.WriteLine("// ==================================================================");
            }

            ConVar cv = FindConVar(name);
            if (cv == null) continue;

            cv.GetString(value, sizeof(value));
            cv.GetDescription(desc, sizeof(desc));
            int nl = FindCharInString(desc, '\n');
            if (nl >= 0) desc[nl] = 0;

            if (desc[0] != 0)
                f.WriteLine("// %s", desc);
            f.WriteLine("%s \"%s\"", name, value);
            extra++;
        } while (FindNextConCommand(search, name, sizeof(name), isCmd, flags));
        CloseHandle(search);
    }

    delete f;
}

// v3.77.59 — RECONCILIACION REORGANIZADA. El pedido original de la
// v3.77.4 ("cada que inicie el juego... los nuevos datos cvars que no
// existan en el documento apareceran, añadiendose (no sobrescribira
// el antiguo)") SE CUMPLE igual, pero ahora el archivo se reescribe
// ENTERO en formato CATEGORIZADO al cargar. Es seguro porque esto
// corre en OnConfigsExecuted: el Sonic_Suite.cfg ACABA de aplicarse,
// asi que los valores VIVOS == los valores del archivo (lo que el
// owner edito a mano ya vive dentro de los cvars) y lo que faltaba
// entra con su valor vivo directamente EN SU SECCION (antes iba al
// final sin orden).
void SuiteCfg_Reconcile()
{
    SuiteCfg_Save();
    LogMessage("[Suite] v3.77.65: Sonic_Suite.cfg reescrito organizado por categorias (%d secciones)", sizeof(g_SuiteCatTitles));
}

// v3.14: Limpieza al descargar el plugin (evita fugas de hooks y timers)
public void OnPluginEnd()
{
    // Limpiar estado de todos los clientes activos
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i <= MaxClients && IsClientInGame(i))
        {
            // Forzar reset de cada modulo
            Speed_OnPlayerDeath(i);
            Metal_OnPlayerDeath(i);
            Rouge_OnPlayerDeath(i);
            Shadow_OnPlayerDeath(i);   // v3.77.49: mata el avatar y devuelve el cuerpo
            Amy_OnPlayerDeath(i);
            Cream_OnPluginEnd(i);   // v3.77.68: avatar fuera + restore del cuerpo (la MUERTE vive en el POST propio de Cream.inc — leccion Rouge v3.77.49)
            Eggman_OnPluginEnd(i);   // v3.77.69: idem Eggman (9o avatar)
            Blaze_OnPluginEnd(i);    // v3.77.69: idem Blaze (10o avatar)
            Silver_OnPluginEnd(i);   // v3.77.69: idem Silver (11o avatar)
            Sally_OnPlayerDeath(i);
        }
    }

    // v3.75: flush del auto-guardado de la config unica (si hubo un
    // cambio hace menos de 1s, se graba antes de morir)
    if (g_hSuiteCfgSaveTimer != null)
    {
        KillTimer(g_hSuiteCfgSaveTimer);
        g_hSuiteCfgSaveTimer = null;
        SuiteCfg_Save();
    }

    // Guardar owners antes de salir
    SaveOwnersToFile();

    PrintToServer("[SonicJumpSurvivors] Plugin descargado. Estado limpiado.");
}

// =====================================================================
// v3.77.46 — OM AIR CONTROL: "el modo de knuckles... cada que salta le
// da un impulso hacia adelante y aparte parece que eso le da full
// control... puede cambiar de direccion en el aire... por ahora
// solamente lo tendra rouge knuckles y amy y sonic y metal".
//   - OM_JumpImpulse (Event_PlayerJump): impulso hacia adelante al
//     saltar — para los CINCO (Knuckles incluido) + SHADOW (v3.77.48).
//   - OM_AirSteer (OnPlayerRunCmd): steering WASD aereo para los
//     CUATRO que no son Knuckles (el trae el propio en Knux_PreThink
//     desde el v67: accel 12 / tope 300 — receta exacta de aqui)
//     + SHADOW (v3.77.48, con guard: su Hover Shoes manda si mantiene
//     SPACE en el aire).
// =====================================================================
void OM_JumpImpulse(int client)
{
    if (g_cvOMAirControl == null || !g_cvOMAirControl.BoolValue) return;
    if (!IsSurvivor(client)) return;

    int c = g_iPlayerCharIdx[client];
    // v3.77.48: Shadow entra al club del air control
    if (c != ROUGE_INDEX && c != KNUCKLES_INDEX && c != AMY_INDEX
        && c != SONIC_INDEX && c != METALSONIC_INDEX
        && c != SHADOW_INDEX) return;

    float imp = g_cvOMAirImpulse.FloatValue;
    if (imp <= 0.0) return;

    // NOTA: el evento player_jump se dispara cuando el salto YA se aplico
    // (el boost vertical de Sonic lee vel[2] >= 200 aqui mismo) — NO
    // chequear FL_ONGROUND (ya viene limpio). El evento en si ES la
    // garantia de salto real de suelo; solo se filtra el agua.
    if (GetEntityFlags(client) & FL_INWATER) return;

    float a[3], fwd[3], vel[3];
    GetClientEyeAngles(client, a); a[0] = 0.0; a[2] = 0.0;
    GetAngleVectors(a, fwd, NULL_VECTOR, NULL_VECTOR);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[0] += fwd[0] * imp;
    vel[1] += fwd[1] * imp;

    // tope horizontal (no romper el salto del motor)
    float s2 = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
    if (s2 > 420.0) { float k = 420.0 / s2; vel[0] *= k; vel[1] *= k; }

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
}

void OM_AirSteer(int client, int buttons)
{
    if (g_cvOMAirControl == null || !g_cvOMAirControl.BoolValue) return;
    if (buttons == 0) return;

    int c = g_iPlayerCharIdx[client];
    // v3.77.48: Shadow entra al club (guard del Hover Shoes abajo)
    if (c != ROUGE_INDEX && c != AMY_INDEX && c != SONIC_INDEX && c != METALSONIC_INDEX
        && c != SHADOW_INDEX) return;

    int flags = GetEntityFlags(client);
    if (flags & FL_ONGROUND) return;
    if (flags & FL_INWATER) return;   // v3.77.46: FL_INWATER (entity_prop_stocks)
    if (GetEntityMoveType(client) != MOVETYPE_WALK) return;   // latch/levitaciones/etc
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0
        || GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0
        || GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0
        || GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0
        || GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0) return;
    if (OM_IsStunned(client)) return;

    // los estados que manejan SU velocidad ese frame
    if (c == ROUGE_INDEX)
    {
        if (g_bRougeGliding[client] || g_bRougeLatched[client]
            || g_iRougeKickPhase[client] != ROUGE_KICK_NONE) return;
        // frenando (hover) el steering SI corre: moverse frenada = FlyRun
    }
    else if (c == SONIC_INDEX)
    {
        if (g_iSonicSpinPhase[client] != SONIC_SPIN_NONE) return;   // bola/dropdash
        if (g_bSonicHoming[client]) return;                          // homing
        if (GetEngineTime() < g_fSonicDodgeEnd[client]) return;      // eva activa
    }
    else if (c == METALSONIC_INDEX)
    {
        if (Metal_ControlImmune(client)) return;                     // embestida
    }
    else if (c == AMY_INDEX)
    {
        if (Amy_IsImpulseImmune(client)) return;                     // embestida
    }
    else if (c == SHADOW_INDEX)
    {
        // v3.77.48: manteniendo SPACE en el aire su pasiva Hover Shoes
        // (Shadow_PreThink: caida suave + accel 20 + chispas de cohete)
        // maneja el movimiento — el steering OM solo cuando NO la usa
        if (buttons & IN_JUMP) return;
    }

    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);

    float fwdAng[3], fwd[3], right[3];
    GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
    GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);

    float accel = g_cvOMAirAccel.FloatValue;
    float maxSpeed = g_cvOMAirMax.FloatValue;
    bool apply = false;

    if (buttons & IN_FORWARD)   { vel[0] += fwd[0]*accel;   vel[1] += fwd[1]*accel;   apply = true; }
    if (buttons & IN_BACK)      { vel[0] -= fwd[0]*accel;   vel[1] -= fwd[1]*accel;   apply = true; }
    if (buttons & IN_MOVELEFT)  { vel[0] -= right[0]*accel; vel[1] -= right[1]*accel; apply = true; }
    if (buttons & IN_MOVERIGHT) { vel[0] += right[0]*accel; vel[1] += right[1]*accel; apply = true; }

    if (apply)
    {
        float speed2D = SquareRoot(vel[0]*vel[0] + vel[1]*vel[1]);
        if (speed2D > maxSpeed)
        {
            vel[0] = (vel[0]/speed2D) * maxSpeed;
            vel[1] = (vel[1]/speed2D) * maxSpeed;
        }
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    }
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Continue;

    // v3.76.4: gate del STUN OM (port del CreateMove GMod: la victima
    // congelada solo puede MIRAR — botones a 0, sin atacar/saltar/shove).
    // Corre para TODOS: lo disparan la bola de Sonic y los golpes de Metal.
    OM_Stun_OnPlayerRunCmd(client, buttons);

    int charIdx = g_iPlayerCharIdx[client];

    // La lógica de personajes solo se ejecuta si hay un personaje válido
    if (charIdx >= 0 && charIdx < MAX_CHARS)
    {
        if (charIdx == AMY_INDEX)
        {
            Amy_OnPlayerRunCmd(client, buttons);
        }
        else if (charIdx == SALLY_INDEX)
        {
            Sally_OnPlayerRunCmd(client, buttons);
            Doll_OnPlayerRunCmd(client, buttons);
            Doll_PreThink(client);
        }
        else if (charIdx == SHADOW_INDEX)
        {
            Shadow_OnPlayerRunCmd_Proxy(client, buttons);
        }
        else if (charIdx == METALSONIC_INDEX)
        {
            // v3.77.25: el RunCmd del Metal ahora INYECTA el auto-forward
            // de la embestida (vel[0] saturado — el OM_MoveForward del
            // GMod): true = el usercmd cambio y hay que devolver
            // Plugin_Changed para que el motor lo reciba.
            if (Metal_OnPlayerRunCmd(client, buttons, vel))
                return Plugin_Changed;
        }
        else if (charIdx == EGGMAN_INDEX)
        {
            Eggman_OnPlayerRunCmd(client, buttons);
        }
        else if (charIdx == KOLOSSOS_INDEX)
        {
            // v3.77.94: auto-forward de la AVALANCHA (vel[0] saturado —
            // la misma receta del Destructive Charge de Metal v5.0)
            if (Kolossos_OnPlayerRunCmd(client, buttons, vel))
                return Plugin_Changed;
        }

        // v3.62 (R28): escudos REGALADOS por Sage (set SALLY) —
        // cualquier personaje que haya recibido un escudo entra a la
        // logica de Sally: dash aereo (fuego) / caida rebotona
        // (agua). La Sally real ya entro por su case de arriba.
        if (charIdx != SALLY_INDEX && (g_bSageGiftWater[client] || g_bSageGiftFire[client]))
        {
            Sally_OnPlayerRunCmd(client, buttons);
        }
    }

    // v3.77.46: OM AIR CONTROL — steering WASD en el aire (el impulso
    // del salto vive en Event_PlayerJump; Knuckles trae el suyo propio)
    OM_AirSteer(client, buttons);

    if (g_bIsBoneBroken[client])
    {
        Amy_OnPlayerRunCmd_Victim(client, buttons);
    }

    // =====================================================================
    // SISTEMA DOLL MODULAR (independiente del personaje)
    // Se ejecuta para cualquier player que tenga SteamID autorizado en Doll_System
    // =====================================================================
    DollSys_PreThink(client);
    DollSys_OnPlayerRunCmd(client, buttons);
    
    return Plugin_Continue;
}

// v3.47: sonda de version del suite. OJO: "cambiar de mapa" NO
// recarga el .smx nuevo (el plugin vive en memoria mientras el server
// corra): tras actualizar hay que usar "sm plugins reload
// Sonic_ability_manager" (o reinicio completo). Este comando imprime
// el build cargado DE VERDAD para verificarlo en 2 segundos.
public Action Cmd_ShowSuiteVersion(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    ReplyToCommand(client, "[Sonic Suite] Manager %s (CONFIG UNICA: cfg/sourcemod/Sonic_Suite.cfg, auto-guardada | v3.77.105: KOLOSSOS v2.0-OM EL PIN GMOD DE VERDAD (el ragdoll del agarre cuelga de la MANO por frame via SDKCall SetPosition+velocidad CERO del hueso raiz — JAMAS SetParent: la embestida a 750u/s acumulaba velocidad fantasma y el doble salia al fondo del mapa; el original oculto SIGUE al doble en todos los modos) + LA FUSION DEL SWING (pack modelo v1.5.3: walk/run/idle_swing — el M1 es el ACT_MELEE_ATTACK_SWING_GESTURE del GMod; fallback a la serie punch) + Sonic_Suite.cfg: secciones BLAZE/SILVER/KOLOSSOS (los kolossos_* nunca se auto-guardaban — «el grab_ragdoll no aparece en la lista») + M1: arma de slot 0/1 CONGELADA visualmente (m_flNextPrimaryAttack prediciado — cero fogonazo del cliente) ;  LIMPIEZA DE WARNINGS (18->0) + barra de Rouge por fin cableada en SBar (quedo huerfana desde v10.6) | v3.77.90: EL SOL DE LA EXPANSIVA (Blaze v2.13) — pedido del owner: la carga de sol solo llegaba al comun del golpe directo; AHORA los comunes que el AOE del impacto (patada/dash aereo/enganche de la lanza) mata tambien cargan su blaze_sol_charge_common [+2 cada uno, convar ajustable] — cero doble carga: el comun del directo ya conto el suyo y la witch no carga por el AOE [su +25 sigue siendo del directo]; PRUEBA: meter bajo + patada al centro de una horda = la barra sube por CADA comun reventado, no solo por el pateado ; v3.77.89: OPTIMIZACION FUERTE + SC PAUSA — [OPTIMIZACION] cstguard v3.1.0: CACHE de perfiles [CSTG_ParseProfile leia el .cfg del DISCO en cada evaluacion: cada señal, cada spawn-check y cada who-query del watchdog = I/O de disco periodico en el hilo del server = microstutters \"sin razon aparente\"; ahora parsea 1 vez por archivo y valida por mtime — editar un cfg en caliente se detecta solo] + BARRIDO INTELIGENTE [cstguard_sweepmode 1: el watchdog ya NO ejecuta la consulta who (Squirrel) cada 30s porque si: solo cuando algo cambio desde el ultimo barrido limpio = CERO VScript en reposo; el guard sigue verificando EN EL ACTO en cada evento real: spawn, señal, defib, rescate, reemplazo bot<->player] ; Tails v5.21: RATE LIMITER del pulso de pausa [tails_pausefix_spacing 2.0s: separacion minima entre INICIOS de pulso — una cadena de montajes ya no genera pause/unpause en rafaga, la causa raiz del \"el l4 se pause en multiples ocasiones\"] + FIX del trigger de la copia L [pedia el pulso CADA 0.1s aunque el montaje FALLARA = tormenta de pulsos; ahora solo al exito, como ya hacian Amy/Blaze] + BACKOFF de auto-montaje [0.1s*fallos con tope 1s: un spawn rechazado ya no revienta a 10 Hz para siempre] ; HUD: cache de contenido [solo envia el KeyHintText cuando el texto cambia; keepalive 3s] + intervalo configurable [sm_omhud_interval 0.25-2.0: 1.0 = mitad de usermessages] ; [SC PAUSA] pedido del owner: la pausa re-sincroniza los locales cuando el cuerpo queda chueco al atravesar modelos — ahora se puede PEDIR: sc_pausa_salida [pulso al salir del saferoom: el momento de apiñarse en la puerta], sc_pausa_conexion [primer spawn de quien entra con la ronda andando: conexion/reconexion a mitad], sm_scpausa [MANUAL, alias sm_pausa — para cualquier otro momento] — todo por el motor Zero-Net v5.20.7 (cero ClientCommand, respeta sv_pausable 1, doble anti-spam: sc_pausa_min 6s + tails_pausefix_spacing) ; NUEVO sm_omdiag [radiografia del suite: entidades activas, avatares vivos, estado del motor de pulsos, barrido CST, config del HUD + tips] | v3.77.85: EL FIX DEL CRASH SILENCIOSO DE LA HORDA — reporte del owner: \"el crash ocurre solamente en No Mercy al bajar apenas por los apartamentos, el juego se cierra sin mensajes de error ni nada\"; AUTOPSIA del camino habilidad-vs-comunes que la v2.8 desbloqueo al arreglar el viejo \"Invalid client index\": el crash siempre fue al REVIENTAR HORDAS con kick/javelin/dash (por eso solo al bajar por los apartamentos = la primera zona de la campana con comunes en masa) y tenia TRES fuentes: (1) MACRO ROTO OM_StunValid — \"1 <= 464 <= MaxClients\" NO filtra NADA en SourcePawn (asociatividad: (1<=464)=1 -> 1<=32=TRUE): el Burning Javelin llamaba OM_Stun(victima-comun) con cada enganche y reventaba en IsClientInGame \"Invalid client index 464\" CADA TICK, abortando el think entero y re-escaneando al mismo comun 30 veces por segundo [OM_Stun v2.4: macro con forma explicita 1 <= %1 && %1 <= MaxClients + gate victim <= MaxClients en el enganche]; (2) ENTIDADES MUERTAS TRAS EL DAÑO — el HitImpact dañaba PRIMERO (OM_AbilityDamage x2 mata al comun de 50HP EN el frame y su edict se libera AL INSTANTE en L4D2) y seguia operando el cadaver: TeleportEntity + IgniteEntity + GetEntPropVector \"Invalid entity\" en cadena tras cada patada [Blaze v2.10: la POSICION se captura ANTES del daño, push/stun/ignite SOLO con Blaze_VictimAlive, y el DAÑO VA AL FINAL]; (3) DAÑO DENTRO DEL FIND-ENTITY LOOP — el AOE (Blaze_FX_AoeCommons) y el swoosh del Sol Flame dañaban DENTRO del while(FindEntityByClassname): la siguiente iteracion arrancaba desde un edict recien liberado = acceso a memoria liberada = EL CRASH SILENCIOSO del motor sin escribir NADA [AHORA: SNAPSHOT de todos los vivos en radio PRIMERO + daño DESPUES re-validando]; ademas el ARRASTRE del javelin solo acepta victimas VIVAS (muere de camino o con el daño de enganche = la lanza sigue sola, jamas TeleportEntity sobre un edict reciclado); el mismo bug de asociatividad se corrigio en los 16 macros IsValidClient del suite (Blaze/Sonic/Silver/Amy/Knuckles/Metal/Rouge/Shadow/Sage/Tails/Cream/Sally/Eggman/Speed_sonic) | v3.77.84: LA BARRA AL CHAT CON colors.inc — reporte del owner con captura (\"puedes quizas usar el colors.inc para el tema de los colores xq aparesen font y no creo que quede bn y la barra deberia aparecer mas abajo\" + anotacion en pantalla \"La barra debe ir aqui\" señalando la esquina inferior izquierda): la captura mostro los <font> del hint impresos como TEXTO LITERAL — L4D2 NO PARSEA RICH TEXT en el HintText (el HTML del hint es cosa de TF2; roto en toda la familia L4D y hasta CS:GO), SBar v3.0-OM MIGRA LA BARRA AL CHAT [donde el owner la marco] coloreada con la paleta L4D2 del colors.inc v2.0.0-MC del propio tree: {green} = AMARILLO en L4D2 / {lightgreen} verde claro / {blue} azul survivor [el de Sonic] / {olive} apagado / {red} rojo si hay infectados en juego; ANTI-SPAM: el think calcula a 5 Hz pero el chat se escribe THROTTLED [linea nueva solo al cambiar el contenido, sbar_chat_interval 1.0s; transiciones de tag LEVITANDO!/VACIA! a 0.3s; keep-alive de la barra quieta cada sbar_chat_refresh 12s para que no desvanezca]; identidad por personaje [Blaze amarillo fuego / Silver verde claro volando + amarillo RECARGA / Sonic AZUL]; sbar_channel 1 = la caja del hint en TEXTO PLANO de fallback; RETIRADO sbar_size; sm_sbarprobe reescrito [1 lightgreen / 2 green-amarillo / 3 red / 4 blue / 5 hint plano / 6 barra real] | v3.77.83: LA BARRA ESCRIBE — fix del reporte \"aparece la barra negra pero no hay nada escrita\": la v2.0 ponia size= en el font de TODAS las lineas del hint y el parser de L4D2 mata el render del mensaje ENTERO con un size en las lineas de cuerpo [caja negra vacia]; SBar v2.1-OM copia la receta EXACTA de los hints que ya funcionan en este server [size SOLO en la 1a linea, color en las filas de celdas — la de la Furia de Amy]; sbar_cells tope 30 [mensaje siempre bajo el techo de ~206 bytes del canal]; NUEVO sm_sbarprobe 1-6 [sonda del canal: manda variantes de prueba, diagnostica que caracteristica lo mata] | v3.77.82: LA BARRA SE VE DE VERDAD + LA LANZA CON ALCANCE/CURSO/STUN — reporte del owner sobre la .81: el crash \"Invalid client index 467\" era el OR de Blaze_HitImpact evaluando IsPlayerAlive ANTES del rango (un comun = entidad 400+ reventaba el native y abortaba el think con el kick vivo; ahora el rango va primero) Y \"no se ve la barra\" porque game_text esta ROTO en toda la serie L4D (bug documentado de la wiki de Valve: el HudMessage se redirige a la 2a vista del splitscreen y la fuente no existe en clientscheme.res = INVISIBLE en clientes vanilla — la barra NUNCA se habia visto, ni en la .80 ni en la .81; el \"texto chiquito\" del pedido era el panel KeyHintText): SBar v2.0-OM migra al HINTTEXT CON RICH TEXT [el canal del HUD de Furia de Amy, probado en este server] — barra gruesa de celdas ASCII + linea de texto, COLOR por nivel restaurado, parpadeo VACIA, tamano sbar_size 24 [el \"mas grande\" resuelto de verdad], 3 lineas [tope del canal], cero entidades; convars sbar_enable/_cells 20/_lines 2/_size 24/_fill #/_empty - [x/_y/_dy/_channel retiradas: el hint pinta donde el HUD del cliente lo pone] | LA LANZA: alcance honesto [el trace de pared era un rayo INFINITO que clavaba la lanza al nacer ante cualquier func_ delante, y el filtro excluya el MUNDO por lo que cruzaba las paredes del mapa: ahora se traza SOLO el segmento recorrido del tick y se clava EN el punto de contacto] + radio de caza blaze_javelin_radius 120 [80 fijo antes] + blaze_javelin_pitch 90 [\"la lanza debe mirar 90 grados hacia el frente\": el picon w_pitchfork nace vertical, +90 de pitch lo apunta a lo largo del vuelo; -90 si quedara al reves] + los OBJETIVOS EMPUJADOS entran en OM stun 1s con STAGGER al liberar [OM_STUN_F_STAGGER; stack=false por acierto; commons siguen con dano+arrastre] | v3.77.81: LAS BARRAS DE RECURSO PARA TODOS + MAS GRANDES — pedido del owner: \"ese mismo tipo de barra deberia salir para sonic y todos aquellos que lo usan (silver para su vuelo sonic para su evasion) y puedes hacer que el texto sea mas grande?\": NUEVO motor comun SBar v1.0-OM — la LLAMA SOL de Blaze, el VUELO de Silver [la flyingBar 0-20 del Lua] y los ANILLOS de Sonic [su EVA, el Dodgemeter 0-50 del GMod] en la MISMA barra; y MAS GRANDE: la fuente de game_text es fija, lo que se apila es LA LINEA — 2 LINEAS de 30 celdas [sbar_lines 1..3 = doble/triple grosor; sbar_cells; sbar_dy] = barra el doble de gruesa, 50%% mas larga y texto en negrita; convars sbar_enable/_x/_y/_dy/_cells/_lines/_channel/_fill/_empty [las blaze_bar_* de la v3.77.80 quedan reemplazadas; cada jugador ve SOLO la suya; dedicado/listen/MODO SOLO] | v3.77.80: LA BARRA DE LLAMA SOL — HUD tipo Gmod por SMX (pregunta del owner: \"es posible crear una UI HUD a base de smx como hacia Gmod para ponerle a blaze su barra de calor? ya que actualmente no hay nada que le indique cuanto calor tiene\"; el recordatorio de la adrenalina/llamas en pantalla = post-proceso del CLIENTE [PCF], no disparable desde un plugin; el Lua de Gmod dibuja su HUD en el CLIENTE con HUDPaint+surface y L4D2 no tiene cliente scriptable — el canal que SI existe es la entidad game_text del engine: texto COLOREADO en posicion fija, Display SOLO al activador [cada Blaze ve SU barra]; think 4 Hz + celdas █/░ + color por nivel [>=50%% naranja MODO SOL / >=20 amarillo / <20 rojo / VACIA parpadea rojo-gris] + tags DRAIN/FLAME; convars blaze_bar_enable/_x/_y/_cells/_channel/_fill/_empty [x/y/canal se re-aplican por tick = barra MOVIBLE EN VIVO; si tu fuente no dibuja los blocks: blaze_bar_fill | y blaze_bar_empty . ]) | v3.77.79: MODO SOLO COMPATIBLE — pedido del owner: \"los comandos de consola en modo solo no funcionan, solo cuando creo partida en un lobby es que lo acepta\"; en L4D2 el jugador local del single player NO es un cliente de red: el motor lo monta como cliente FAKE (takeover del bot) y sus comandos llegaban como consola (client 0) o con ese indice fake — el macro IsValidClient (con !IsFakeClient) los rechazaba EN SILENCIO, por eso Z/X/C/B, sc, js y todos los sm_* no hacian nada en solo y en lobby (cliente real) si; AHORA: [1] Sonic_SoloClient resuelve el invocador al ENTRAR de cada comando del suite (consola -> tu jugador; fake aceptado SOLO en partida sin clientes reales, porque ningun bot tipea), [2] el macro IsValidClient deja pasar al host local (menus, HUD, cooldowns y prints funcionan en solo), [3] ROOT automatico para el host local (L4D2 no lo da de fabrica: sin esto Amy/Sage/sm_setsound/CST quedaban bloqueados en local) — en el server DEDICADO y en listen con gente conectada el comportamiento es IDENTICO al de siempre, los bots siguen bloqueados | v3.77.78: EL JAVELIN VUELA DE VERDAD + LA HITBOX ES TODO EL RECORRIDO + EL KICK DEVUELVE 65% DEL CD — el Burning Javelin tenia TRES bugs juntos [modelo harpoon de HL2 que L4D2 no trae; estela molotov_trail inexistente; el think leia una velocidad que el prop no expone = moria al instante] y ADEMAS sin tope de vuelo el primer javelin perdido bloqueaba la habilidad para siempre; ahora = picon w_pitchfork del propio L4D2 + fuego env_fire_small parentado [familia confirmada] + vuelo por direccion fija + tope 6s; LA HITBOX de kick/dash/javelin ahora barre TODO el segmento recorrido en cada tick y compara contra el CENTRO del cuerpo [antes solo pegaba al caer al final]; al ACERTAR la patada se le DEVUELVE el 65% del cd [blaze_kick_cdrefund] | v3.77.77: EL FUEGO DEL SOL DASH SE VE — la inferno_wall_primary pedida es un muro de DOS puntos (dibuja ENTRE su origen y el cpoint1): parentada sola al cuerpo no dibujaba NADA, por eso Blaze volaba sin fuego; ahora la envuelven env_fire_medium (torso) + env_fire_small (pies) en loop durante el dash [mira blaze_fx_dash_name / blaze_fx_dash_name2] | v3.77.76: LA LLAMARADA DEL SOL FLAME SE VE — el cono ahora usa env_fire_large + env_fire_medium [las particulas de los fuegos ambientales de los mapas: SIEMPRE visibles] con cpoint1 por tramo; la inferno_wall_occlusion pedida era la CAPA DE MASCARA tecnica del muro del molotov [por eso invisible] — mira blaze_fx_flame_name / blaze_fx_flame_mouth | v3.77.75: FIX DEL ENGINE ERROR UserMessageBegin — el panel de estados usaba la API protobuf de CS:GO en el L4D2 de bitbuffer: el mensaje quedaba ABIERTO y el motor crasheaba al mandar el siguiente; ahora escribe BfWriteString y sm_omhud vuelve a ser seguro | v3.77.74: LA TORMENTA ELECTRICA DE METAL — flame_blue en el torso durante la embestida + efx_arc_new1/XXL/XXL2 sobre la victima arrastrada + electrical_arc_01_system al estrellarla contra la pared [metalom_fx_charge] | v3.77.73: EL FUEGO SE VE — efectos molotov/inferno REALES del motor en todo el kit de Blaze [kick: burst3 al preparar + molotov_explosion en el impacto; dash: inferno_wall_primary en el cuerpo + burst al azar al pegar; solflame: muro inferno_wall_occlusion; javelin: estela molotov_trail SIEMPRE visible] + AOE a commons con visual SOLO en la victima [anti-lag] + OM_Stun v2.3 [stagger al ENTRAR: el tank YA NO suelta la roca, el hunter YA NO completa el pounce] | v3.77.72: PANEL DE ESTADOS SIEMPRE VISIBLE [sm_omhud] — EVA de Sonic, LLAMA de Blaze, ENERGIA de Silver y cooldowns Z/X/C/B en pantalla) | Sonic %s (OM: spindash/dropdash + peel out + homing C + anillos + avatar + RAGDOLL CON IMPULSO REAL: SetVelocity POR HUESO directo al vphysics — golpe final/martillo/selfdestruct/ritual witch + plan B motor puro; v6.37: LA BARRA AL CHAT [AZUL survivor — su color; ESQUIVA!/SIN ANILLOS!; paleta colors.inc] | v6.36: BARRA DE ANILLOS [su EVA en barra grafica con el motor SBar — reemplaza el hint \"Anillos: x/y\"; tags ESQUIVA!/SIN ANILLOS; con sonicom_rings 0 no hay barra] | v6.35: SpawnFlingRagdollEx [velocidad explicita por habilidad] + DeadFlingCopy [cadaver volador compartido]) | Amy %s (v108-OM: LA B DECIDE Y EL BUMERAN GIRA DE VERDAD — [1] LA B [sm_sjs_ability4] ALTERNA POR JUGADOR entre modo BUMERAN y modo COMUN del martillo [preferencia sin cooldown que sobrevive respawns; amyom_boom_mode = default de fabrica; cartas del super tank -> consola sm_amysupertank]; [2] el martillo en modo BUMERAN pega tipo DMG_SLASH [CORTE] en especiales/tank y comunes, el clasico conserva DMG_CLUB; [3] ROTACION REAL en vuelo: la ida gira con la receta del RETORNO [TeleportEntity con yaw avanzando amyom_boom_spin deg/s — el motor hace pPhys->SetPosition: el angulo escrito es el que SE VE; cero SDKCall] y la velocidad re-afirmada en el mismo call; [4] ALCANCE +55% [amyom_boom_dist 1500 -> 2325]; [5] CARTAS SIN MENTIRAS: descripcion exacta carta por carta con la tirada concreta de la Luna, la X en cooldown re-muestra la mano, y el announce apunta a sm_defensas [EL CUADRO de reducciones de TODO el equipo: Amy cartas+Furia, Metal pasiva/inmune, Rouge escalones, Shadow inhibidores, Knuckles cargando, Sonic anillos]; v107: bumeran+autos+contra vertical; v106: EL VUELO REAL DEL IMPACTO — el Touch fisico SOLO ENCOLA y un RequestFrame lo procesa FUERA de la simulacion vphysics [contexto del spindash: procesado inline dentro del touch, el ragdoll falso nunca despegaba = stun si, vuelo nunca]; COMUNES con la RECETA ROUGE v10.4 [copia prop_ragdoll del cuerpo VOLADA con el impulso GMod direccional + BecomeRagdoll + limpieza 3s — el ragdoll de muerte de un comun es DEL CLIENTE en L4D2 y no hereda velocidad del server, por eso el v105 empujaba en vacio; reglas GMod: desde abajo = arriba, en suelo = contraria + eleva]; dano FUERA de OM_Stun [sobrevive = stun + doble del spindash; muere con el golpe = copia Rouge volada; iframes solo resisten el stun]; v105: TUMBLE REAL del martillo en vuelo [cartwheel + wobble via Sonic_PhysSetVel, amyom_throw_spin/fling] + cero dano de colision al equipo; v104: parry con entrada propia ChCh_AmyNotify del chch_parrying.nut v2.8; proyectil en rango = ataque + aura; pose fuera = parry fuera) | Sage %s | Cream %s (v7.2-OM: PANEL DE ESTADOS [cooldowns Z/X/C siempre visibles] + SU AVATAR + EL DASH DEL LUA — cream.mdl espejo R/L + FSM POR PROBE [idle/walk/run/jump/fall + FLY DE OREJAS con el glide de SPACE + lowhealth<=30 cuando Cheese esta desmayado + downed] + ragdoll de muerte 15s + tinte DORADO post-resurreccion | Z cura de area [radio 90 = el Lua] + X resurreccion CD 120s + C EL DASH DEL LUA: impulso 500+145, knockback dir*900 al que das, rebote propio, +5s de speed boost 1.6x y el COSTE del Lua: 20 de dano a una misma; pared = rebote + Wallhit | regeneracion +1HP/2s + glide WASD con SPACE + Cheese corta agarres) | Sally %s | Rouge %s (v10.5: LA PATADA BAJA MANDA A VOLAR — el contragolpe aplica STUN+RAGDOLL con la direccion de la patada [horizontal alejando + elevacion corta; dano hibrido primero; letal = cadaver volando; sobrevive = OM_Stun + doble volador; rouge_parry_ragdoll 3.0 / rouge_parry_fling 600]; v10.4: RAGDOLL DEL BARRIDO CON IMPULSO REAL (mismo motor v6.33: SetVelocity por hueso); v10.3-OM: BALANCE — patada baja (Barrido Z) dano x1.5 y radio x1.25, counter devolucion x1.45 (145/290) y 7s; v10.2: REWORK DEL VUELO — energia 250, ALETEO SIN LIMITE (solo energia), planeo con SPACE mantenido + aleteo al tap + FRENO SHIFT en el aire (gravedad 0 hasta quedarte quieta) + agarre de pared estilo Knuckles (salida por la normal + planeo auto) + anims FlyIdle/FlyRun | Z Barrido EN AREA [todos en la esfera, cd 6s, SI = OM_Stun 2.5s APILABLE] | X Contragolpe 7s = AL DE KNUCKLES [activacion counter.wav + bloqueo punchstun.wav + anim de PATADA BAJA; garra del tank con desarme 5s, agarres, vomito reflejado, devoluciones 145/290/800, cd 55% al fallar / 85% al triunfar] | C Bat Bomb [cd 13] | B ONDA NEGRA REINTEGRADA [fix del bind: la 4 estaba sin usar] | vida max 125 + reduccion 20/35/50%% + eva de agarres y vomitos | Cebo+Flash -> consola sm_rouge_kick | avatar rouge.mdl R/L con FSM [latch/flap/SweepKick/FlyIdle/FlyRun/lowhealth/downed] + ragdoll de muerte) | Knuckles %s (v77-OM: EL UPPERCUT VUELA — la contra aplica STUN+RAGDOLL mayormente HACIA ARRIBA [dano hibrido primero; letal = cadaver volando; sobrevive = OM_Stun + doble vertical; knu_counter_ragdoll 3.0 / knu_counter_fling 700; tank incluido con su desarme]; v76-OM: enfriamientos -4s — puno 11 / postura 16 / meteoro 16; v75: AVATAR knuckles.mdl + FSM del lua GMod con glide/latch/FallAttack y lowhealth; parry de proyectiles DELEGADO AL VSCRIPT chch_parrying.nut v2.8 (LA POSTURA LLAMA DIRECTO a SU entrada ChCh_KnxNotify por RunScriptCode — patron SetAmyMode del supertank, sin consola y sin gates; cero shove previo; cada bloqueo del .nut avisa al SMX -> knx_parry_blocked -> ANIMACION de bloqueo del avatar; el shove ya NO parrea); postura = COUNTER de golpes fisicos Y de los basicos de los especiales (garreado = contraataque completo en seco) y la garra de la witch la CONGELA en seco; EL SONIDO DEL BLOQUEO es om/knuckles/punchstun.wav en TODO (agarres, tank, VScript, basicos); smash aereo vs BOOMER = mecha: estalla al tocar suelo tras volar; tintes carga/bloqueo/cancel; sonidos om/knuckles del VPK; ragdoll al morir | puno/slam props + H3 Meteoro v64) | Tails %s (OM: vuelo + cañón 4 modos; H3 = modo; parentado suave, item bomba de bilis) | Metal v6.0-OM (LA TORMENTA ELECTRICA DEL DESTRUCTIVE: flame_blue PARENTADA al torso desde que Metal DESPEGA la embestida hasta que se DETIENE o estrella a la victima contra la pared [muere en TODOS los caminos de fin: estampado / rebote / drop por cap / timeout / muerte; si el arrastrado muere en sus manos la embestida y la llama SIGUEN]; mientras ARRASTRA: efx_arc_new1 + _XXL + _XXL2 sobre la victima; el impacto contra la pared: electrical_arc_01_system en el punto de estampado [la del pet_fusion de este server]; metalom_fx_charge 1 = kill-switch; v5.9: ADIOS LOOP ZOMBIE: cuando el dash TERMINA por tiempo el sonido electrico del deslizamiento YA NO queda sonando [reporte del owner: sigue sonando no se detiene, no ocurre si impacta contra algo — el watchdog re-emitia el loop cada 3s y en algunos clientes las copias se apilaban: con impacto temprano habia una sola y el stop la mataba, a los 8s quedaban restos; ahora cada latido hace STOP+EMIT (una sola instancia viva SIEMPRE), el arranque limpia restos de la carga anterior, el fallback electric_loop va en canal STATIC explicito y hay re-stop diferido a los 0.25s]; v5.8: LA EMBESTIDA NO SE DETIENE: si el objetivo ARRASTRADO muere en sus manos — especial o witch — la carga vuelve al ESTADO DASH y SIGUE [misma velocidad, puede atrapar OTRO objetivo, rebota en pared, termina al agotar su reloj; NO aplica tras estrellarlo contra la pared: el WALL_SLAM/embiste final sigue su curso]; v5.7.1: BALANCE 3.77.50/51 — embestida dano x1.25 [atrape 7.75 / tick 7.75 / estampado 18.875 / golpe de pared 4.0625] y cd x0.75 [13.125 / cancel 6.5625]; v5.6: avatar metal.mdl + Z embestida por suelo con liberacion de agarres + X Self Repair con aura de soporte Tails/Eggman + C Overdrive con levitacion; ronda 5: dano de la embestida +55% (hasta 6.2/6.2/15.1; 3.77.50: 7.75/7.75/18.875), golpe de 0 de dano real YA NO interrumpe reparacion ni windup, BOOMER FUSE (el golpe letal no lo mata: mecha y estalla al terminar SU stun) y la WITCH ESTAMPADA queda estatua contra la pared 2.0s tras el slam como los SI; ronda 3-4: anti-control con forwards REALES del left4dhooks, avalancha que mata commons, witch embestible con estatua FL_FROZEN de verdad, anti-atasco en pasillos y vida maxima 175) | Shadow %s (v6.0-OM: AVATAR shadow.mdl espejo R/L + FSM resuelta POR PROBE [idle/walk/run/jump/fall + HOVER propio con SPACE + lowhealth<=50 + downed + one-shots SNAP/BLAST] + ragdoll de muerte + tinte ROJO con Anillos Inhibidores + shadow_avatar 1 | Z CHAOS SNAP + X CHAOS BLAST + Hover Shoes + Anillos + AIR CONTROL v3.77.48) | Eggman %s (v5.1-OM: EL ESCUDO BLOQUEA DE VERDAD [L4D2 manda muchas garras con damagetype 0 — ahora cubre el melee real; stun del atacante diferido a prueba de crasheo] + BOOST A 650 U/S DE VELOCIDAD OBJETIVO [eggman_boost_target, como el Speed] + DOBLE SALTO vz 550 [mas potencia pasiva] + SU AVATAR — eggman.mdl espejo R/L + FSM POR PROBE [idle/walk/run/jump/fall + JET del doble salto + lowhealth<=40 + downed + BOOST sostenido] + ragdoll de muerte 15s | Z Badnik Mines + X Death Egg Laser + C JETPACK BOOST [3.75s a 2.0x, cd 22 — la E del Lua] + B SOAPY SHIELD [5s: bloquea el cuerpo a cuerpo, el atacante recibe 1s de stun, +0.25s por bloqueo; cd 26/35 si para un golpe — la T del Lua] + pasiva Eggmobile Jet [doble salto vz 400, cd 10 — el Lua] + VOICELINES del fin de persecucion [1 de 9 al azar] + inmune a caidas/acido) | Blaze %s (v2.10-OM: CRASHPROOF — EL FIX DEL CRASH SILENCIOSO DE LA HORDA: (1) OM_Stun SOLO players en el enganche del javelin [el macro OM_StunValid v2.4 arreglado: \"1 <= 464 <= MaxClients\" no filtraba NPC y reventaba \"Invalid client index 464\" cada tick]; (2) el DAÑO VA AL FINAL del HitImpact [antes mataba al comun y el push/ignite/fx operaban el cadaver]; (3) AOE y swoosh con SNAPSHOT [antes dañaban DENTRO del FindEntityByClassname = crash silencioso del motor]; (4) ARRASTRE solo de victimas VIVAS | v2.9-OM: LA BARRA AL CHAT CON colors.inc — la captura del owner mostro los <font> del hint como TEXTO LITERAL (L4D2 no parsea rich text en el HintText): la Llama Sol vive en el CHAT abajo-izquierda [amarillo lleno / verde claro medio / oliva bajo / rojo VACIA parpadeando] con throttle sbar_chat_interval 1.0s + transiciones de tag 0.3s + keep-alive sbar_chat_refresh 12s | v2.8-OM: LA BARRA SE VE DE VERDAD + LA LANZA CON ALCANCE/CURSO/STUN — barra por HintText rich text [color por nivel + sbar_size 24, el canal de la Furia de Amy]; FIX del crash \"Invalid client index\" [el rango va antes que IsPlayerAlive]; lanza: trace del SEGMENTO recorrido + filtro con mundo [alcance honesto] + blaze_javelin_radius 120 + blaze_javelin_pitch 90 [apunta al frente] + OM stun 1s con stagger al enganchar] | v2.7-OM: LA BARRA MIGRA AL MOTOR COMUN SBar [misma Llama Sol, ahora 2 lineas de 30 celdas; convars sbar_* — las blaze_bar_* retiradas] | v2.6-OM: LA BARRA DE LLAMA SOL — HUD game_text tipo Gmod [celdas █/░ + color por nivel + tags DRAIN/FLAME/MODO SOL + VACIA parpadeando; convars blaze_bar_enable/_x/_y/_cells/_channel/_fill/_empty — x/y movibles EN VIVO] | v2.5-OM: EL JAVELIN VUELA + HITBOX DEL RECORRIDO + REMBOLSO DEL KICK — Burning Javelin [PICON w_pitchfork.mdl del propio L4D2: TODO cliente lo ve, decision del owner; fuego env_fire_small parentado al vuelo — mira blaze_fx_jav_name; vuelo por DIRECCION fija a 3000 u/s sin leer velocidades del prop + tope 6s: nunca mas queda bloqueada la habilidad] | LA HITBOX ES EL RECORRIDO: kick/dash/javelin barren TODO el segmento recorrido en cada tick y comparan contra el CENTRO del cuerpo de las victimas [+40z] — pegan durante TODO el vuelo, no solo al final | AL ACERTAR la patada se DEVUELVE el 65% del enfriamiento [blaze_kick_cdrefund 0.65: 17 -> 5.95s antes de blaze_cd_scale; el fallo conserva su cd] | v2.4-OM: LA LLAMARADA Y EL FUEGO DEL DASH SE VEN — Sol Flame [cono 170/340/510/650u con env_fire_large en la boca + env_fire_medium en los tramos: las particulas de los fuegos ambientales de los mapas, SIEMPRE visibles — la inferno_wall_occlusion del pedido original es la CAPA DE MASCARA del muro del molotov, por eso era invisible; look alternativo: blaze_fx_flame_name inferno_wall_primary = muro dibujado ENTRE punto y punto por tramo], kick [molotov_explosion_burst3 SOLO al preparar + molotov_explosion en el LUGAR del impacto], Sol Dash [env_fire_medium al TORSO + env_fire_small a los PIES parentadas a Blaze durante el vuelo en LOOP — la rodean entera; la inferno_wall_primary del pedido es un muro de 2 puntos que sin cpoint1 no dibuja nada, por eso el fuego era invisible; removidas SIEMPRE al terminar, mira blaze_fx_dash_name / blaze_fx_dash_name2 + una de las 4 molotov_burst AL AZAR sobre el enemigo al impactar], Burning Javelin [molotov_trail del propio motor PARENTADA al arpon: SIEMPRE visible aunque el harpoon del VPK no llegue al cliente + dano al enganchar blaze_javelin_damage 45] + AOE A COMMONS en kick/dash/javelin [dano en radio blaze_aoe_radius/damage 250/80 via OM_AbilityDamage + pasada por swoosh del solflame; el EFECTO VISUAL solo en la victima — cero particulas por common, anti lag de muerte]; v2.1: ENFRIAMIENTOS -50% [blaze_cd_scale 0.5] + PANEL DE ESTADOS [llama SOL siempre visible] + SU AVATAR + SU KIT GMOD — blaze.mdl espejo R/L + FSM POR PROBE [idle/walk/run/jump/fall + Kick/SolDash/Roll/throw/SolFlame del Lua] + ragdoll de muerte 15s | PASIVAS: meter SOLFLAME 0-100 [se llena pegando: +35 kick/dash, +15 javelin; >=50 = MODO SOL con QUEMA real del motor] + IFRAMES mientras cualquier habilidad este activa | Z EN TIERRA = Roundhouse Kick [carga 0.35s con beeps, vuelo, esfera 100: stun 4s + 25 dano + empujon 600/1000 + rebote propio; acierto cd 17 *0.35 = 5.95s con el reembolso del 65% / fallo Roll 0.5s + cd 25] | Z EN EL AIRE = Sol Dash [carga congelada 0.6-0.7s, disparo 1400 u/s a la mira; con Sol>=50 = DRAIN DASH sostenido que quema 5/s] | X = Burning Javelin [sol<50: PICON de horca en llamas a 3000 u/s que PERFORA Y ARRASTRA al objetivo 0.5s, +15 sol, cd 25] / Sol Flame [sol>=50: CONO 650u/50 grados que quema 1.35s + empuja, drena 2.5/s hasta vaciar, cd 25] — convars con los defaults EXACTOS del Lua + sonidos om/blaze con probe) | Silver %s (v2.3-OM: LA BARRA AL CHAT [verde claro LEVITANDO! / amarillo RECARGA / oliva poca carga / rojo VACIA — paleta colors.inc] | v2.2-OM: BARRA DE VUELO [la flyingBar 0-20 del Lua en pantalla, cian; LEVITANDO!/RECARGA Xs/VACIA!; el panel KeyHintText sigue con la ENERGIA 0-100] | v2.1-OM: PANEL DE ESTADOS [energia/levitacion/cooldowns siempre visibles] + SU AVATAR + SU KIT GMOD — silver.mdl espejo R/L + FSM POR PROBE [idle/walk/run/jump/fall + abilityhover/suspension loop/FlyIdle del Lua] + ragdoll de muerte 15s | PASIVAS: ENERGIA 0-100 [regen 5/s en reposo] + VIDA MAXIMA 105 | Z = SUSPENSION en ciclo de 3 [1: hover cd 5; 2: AGARRE telekinetico a la mira — el objetivo queda colgado +70z congelado con tinte CYAN drenando 6/s; 3: LANZAMIENTO aim*2000, cd 17] | X = ROCKS [invoca hasta 3 orbitando detras (50 atras, 60 entre ellas), la siguiente X lanza la 1a a 2500: stagger 0.5s por acierto y el 3er acierto = stun 3s + 15; al irse la ultima: cd 15+5*aciertos — el cd del Lua] | C = TIME REVERSAL [graba cada 1s hasta 10 registros, -10 energia por tick; 2a pulsacion = REBOBINAR por los registros; dano durante la grabacion = cancel cd 25; completo cd 15] | SPACE EN EL AIRE = LEVITACION [vuelo hacia la mira, SHIFT = rapido; barra 20 que drena 9.4/s y se recarga en el suelo; vacia = cd 8] — convars con los defaults EXACTOS del Lua + sonidos om/silver con probe) | OM_Stun v2.4 (v2.4: FIX DEL MACRO OM_StunValid — el rango \"1 <= %1 <= MaxClients\" no filtraba NPCs en SourcePawn y el javelin reventaba en \"Invalid client index 464\" con cada enganche a un comun; forma explicita 1 <= %1 && %1 <= MaxClients; v2.3: EL STAGGER AL ENTRAR: el congelado detenia el CUERPO pero NO la ACCION — la roca del tank salia igual, el hunter completaba el pounce; ahora L4D_StaggerPlayer ANTES de congelar ABORTA la accion en curso [om_stun_interrupt 1] + EL AMPLIFICADOR HIBRIDO: suite_dmg_scale 2.0 x plano + suite_dmg_boss_pct 3.5% de la vida ACTUAL vs +1000hp [tank experto +280/golpo, meatwall +1750, scp +525 — suite_dmg_boss_hp ajustable]; BOOMER FUSE compartido) | Avatares A PRUEBA DE REINICIO y SIN barrido en caliente (reemplazo limpio + adopcion de huerfanos en el montaje de cada FSM; unico barrido restante = arranque del mapa) | Parry directo como el supertank (nut v2.8 + Parry.smx v2.6 watchdog: LA VENTANA LA ABRE LA HABILIDAD LLAMANDO DIRECTO A LAS ENTRADAS DEL VSCRIPT — postura de Knuckles -> ChCh_KnxNotify / pose Z de Amy -> ChCh_AmyNotify — sin consola, sin registro de personajes, sin gates; el SHOVE/IN_ATTACK2 YA NO PARREA NI ABRE VENTANA; knx_parry_status diagnostica) | Anti caida v3-OM (ANTIFALL POR AVATAR: avatar vivo = 0 dano de caida; sin avatar = -40% [sm_falldmg_reduce]; re-check cada 0.1s [sm_avatar_fall_check] con re-ajuste al vuelo) | SENAL CST v3.77.53: forward Sonic_OnCharacterChanged(client, charIdx) en CADA cambio de personaje — menu, cookie al reconectar, freechars — mas RegPluginLibrary(sonic_ability_manager) + native Sonic_GetPlayerCharIndex; el cst_skinchange v2.1 escucha la senal y aplica el cfg del personaje (3=amy.cfg etc) aunque el slot stock no este mapeado (build cargado en memoria) | PathSense %s (PASIVA «SENTIDO DE LA RUTA»: activación AL INSTANTE por señal — nativos amy/sage/metal_sonic/tails [pathsense_chars] + admins [pathsense_admins] + TODOS [sm_pathall] + sm_pathpassive <jugador>; el camino al refugio/objetivo SIEMPRE visible; requiere el plugin INDEPENDIENTE l4d_path_to_goal.smx; CFG del suite ahora ORDENADO POR CATEGORIAS)", PLUGIN_VERSION, SONIC_OM_VERSION, AMY_INC_VERSION, SAGE_INC_VERSION, CREAM_INC_VERSION, SALLY_INC_VERSION, ROUGE_INC_VERSION, KNUCKLES_INC_VERSION, TAILS_INC_VERSION, SHADOW_INC_VERSION, EGGMAN_INC_VERSION, BLAZE_INC_VERSION, SILVER_INC_VERSION, KOLOSSOS_INC_VERSION, PATHSENSE_VERSION);

    // v3.77.57: linea de verificacion del GUARD EMBEBIDO — si NO dice
    // "v3.1.0 (build 2026-10-18a)", el smx cargado en el server es VIEJO
    // (regla de oro anti-smx-viejo). CST montado = el probe (arreglado)
    // responde de verdad.
    ConVar wd = FindConVar("cstguard_watchdog_sec");
    ConVar sw = FindConVar("cstguard_sweepmode");
    ReplyToCommand(client, "[Sonic Suite] CST-Guard %s (build %s) EMBEBIDO en el manager v%s — MAPA OFICIAL de 14 perfiles CST (sonic tails knuckles amy shadow rouge cream metal eggman sage big blaze omega silver): seleccion/recuerdo aplica el perfil EN EL ACTO (metal_sonic->metal por frontera); rouge de vuelta via rouge_r.cfg; sally sin modelo = stock intacto; sm_sage queda para Sage.inc (sets); v3.1.0 OPTIMIZACION: cache de perfiles (cero lectura de disco al evaluar) + barrido %s (solo consulta si algo cambio = cero VScript en reposo); watchdog cada %.0fs, re-anuncio cada ronda y al montar el CST | CST (VScript) montado: %s | sm_amy / sm_metal / sm_rouge / sm_silver / sm_cstcheck viven AQUI — cst_skinchange.smx debe estar FUERA del server",
        CSTG_VERSION, CSTG_BUILD, PLUGIN_VERSION, (sw != null && sw.IntValue == 1) ? "INTELIGENTE" : "clasico", (wd != null) ? wd.FloatValue : 30.0, CSTGuard_IsReady() ? "SI" : "todavia no (espera el probe)");

    // v3.77.61: sonda del MUSIC DIRECTOR (entrega aparte) — lee la version
    // REAL cargada en memoria. Si no dice "1.5.0-unificado", el
    // l4d_MusicDirector.smx del server es VIEJO (regla anti-smx-viejo;
    // v3.77.62: 1.2.0 del fix del precache;
    // v3.77.63: 1.3.0 de la entrega del finale;
    // v3.77.64: 1.4.0 del silencio quirurgico;
    // v3.77.66: 1.5.0 del blindaje anti-loop del tank).
    ConVar mdver = FindConVar("l4d_musicdirector_version");
    char mdbuf[64];
    if (mdver != null) mdver.GetString(mdbuf, sizeof(mdbuf));
    else strcopy(mdbuf, sizeof(mdbuf), "NO CARGADO (falta l4d_MusicDirector.smx)");
    ReplyToCommand(client, "[Sonic Suite] Music Director: %s (esperado 1.5.0-unificado: v1.5 BLINDAJE ANTI-LOOP DEL TANK — [1] el RADAR de sonido YA NO abre la etapa TANK sin un tank VIVO de verdad: re-check diferido 1.5s y si el tank no aparece no se abre nada — fin del loop tank->watchdog->tank que interrumpia la cancion del reproductor cada pocos segundos; el sample fantasma queda en el log; [2] DETENER LA MUSICA PARA TODOS detiene DE VERDAD: el stop mata tambien la pausa y la reanudacion pendiente — la cancion anterior ya no puede resucitar; [3] poner una cancion NUEVA para todos descarta la pausa de la vieja; v1.4: silencio quirurgico per-cliente + corte previo + asedio 1s + pausa/reanudacion + md_native_debug)", mdbuf);

    // v3.77.66: sonda del AVATARHIDE (modulo embebido en el manager) —
    // la version del include compilado DENTRO de este smx. Si no dice
    // v1.2, el smx del server es viejo (sin la deteccion del avatar de
    // Cream — el 8o avatar).
    ReplyToCommand(client, "[Sonic Suite] AvatarHide %s (equipo del cuerpo oculto SOLO con avatar OM real: espalda/cinturon via m_iAddonBits + arma en mano via m_iWorldModelIndex; v1.2: +CREAM [8o avatar] — quien lleva el avatar de Cream tambien juega sin armas visibles; v1.1 FIX PICKUP: el arma recogida del suelo se oculta EN EL MISMO FRAME del equip — hooks WeaponEquipPost/WeaponSwitchPost por cliente + refuerzo al frame siguiente; sm_avatarhide = tabla de estado)", AVATARHIDE_VERSION);

    // v3.77.67: sonda del PATHSENSE (modulo embebido en el manager) —
    // si no dice v1.1, el smx del server es VIEJO (seguira spameando
    // «Client N is not connected» cada segundo al desconectarse
    // alguien).
    ReplyToCommand(client, "[Sonic Suite] PathSense %s (Sentido de la Ruta: el camino al refugio/objetivo SIEMPRE visible — nativos [pathsense_chars] + admins [pathsense_admins] + TODOS [sm_pathall] + sm_pathpassive; requiere l4d_path_to_goal.smx aparte; v1.1 FIX: FIN DEL SPAM «Client N is not connected» del log — el latido de 1 s validaba IsFakeClient ANTES de IsClientInGame y cualquier slot desconectado lanzaba la excepcion en CADA tick)", PATHSENSE_VERSION);
    return Plugin_Handled;
}

public Action Command_Ability1(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;
    if (!g_cvSJEnable.BoolValue) return Plugin_Handled;

    int charIdx = g_iPlayerCharIdx[client];
    if (charIdx < 0 || charIdx >= MAX_CHARS) return Plugin_Handled;

    switch (charIdx)
    {
        case SONIC_INDEX:      Sonic_OM_Spindash(client);   // v3.76 OM: Z = Spindash/DropDash (GMod E)
        case TAILS_INDEX:      Command_TailsLaser(client, 0);
        case KNUCKLES_INDEX:   Command_KnuxPunch(client, 0);
        case AMY_INDEX:        Command_ImpulseCharge(client, 0);   // v92-OM: swing FUSIONADO (AOE + ventana de defensa/contra) | dash por modo
        case SALLY_INDEX:      Cmd_ToggleShield(client, 0);
        case SHADOW_INDEX:     Command_ShadowAbility(client, 0);
        case ROUGE_INDEX:      Command_RougeSweepKick(client, 0);   // v3.77.46: Z = BARRIDO EN AREA (cd 6s); el Cebo Quimico pasa a consola (sm_rouge_kick)
        case CREAM_INDEX:      Command_CreamHeal(client, 0);
        case METALSONIC_INDEX: Command_MetalCharge(client, 0);
        case EGGMAN_INDEX:     Command_EggmanMines(client, 0);
        // v3.77.71: EL KIT GMOD — Blaze: Z en tierra = Roundhouse Kick /
        // en el aire = Sol Dash (survivors2.lua L1204+). Silver: Z = el
        // ciclo de la Suspension (Lua E + LMB en un solo boton).
        case BLAZE_INDEX:      Blaze_Ability1(client);
        case SILVER_INDEX:     Silver_Ability1(client);
        // v3.77.94: Z de KOLOSSOS = AVALANCHA (si hay agarrado: PUO — GMod l.2566)
        case KOLOSSOS_INDEX:   Kolossos_Ability1(client);
        // v3.60 (R26): la Z de Sage depende del set prestado.
        // v3.62 (R28): SALLY -> escudo de AGUA de equipo | ROUGE -> cebo quimico
        case SAGE_INDEX:
        {
            if (g_iSageActiveSet[client] == SAGESET_CREAM)      Command_CreamHeal(client, 0);
            else if (g_iSageActiveSet[client] == SAGESET_SALLY) Sage_CastTeamShield(client, false);
            else if (g_iSageActiveSet[client] == SAGESET_ROUGE) Command_RougeKick(client, 0);   // v3.77.45: el set de Sage SIGUE con el cebo (sus granadas)
            else                                                 Command_ImpulseCharge(client, 0);
        }
        default: PrintCenterText(client, "[X] Personaje sin Habilidad 1 definida");
    }
    return Plugin_Handled;
}

public Action Command_Ability2(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;
    if (!g_cvSJEnable.BoolValue) return Plugin_Handled;

    int charIdx = g_iPlayerCharIdx[client];
    if (charIdx < 0 || charIdx >= MAX_CHARS) return Plugin_Handled;

    switch (charIdx)
    {
        case SONIC_INDEX:      Sonic_OM_PeelOut(client);     // v3.76 OM: X = Peel Out (GMod T)
        case TAILS_INDEX:      Command_TailsFly(client, 0);
        case KNUCKLES_INDEX:   Command_KnuxCounter(client, 0);
        case AMY_INDEX:        Amy_OM_CmdTarot(client, 0);    // v92-OM: X = CARTAS DEL TAROT nuevas (el viejo poder pasa a la ranura 4)
        case SALLY_INDEX:      Cmd_ToggleBubble(client, 0);
        case SHADOW_INDEX:     Command_ShadowDash(client, 0);
        case ROUGE_INDEX:      Command_RougeCounter(client, 0);   // v3.77.45: X = CONTRAGOLPE (la Bat Bomb vive ahora en la C)
        case CREAM_INDEX:      Command_CreamRevive(client, 0);
        case METALSONIC_INDEX: Command_MetalHeal(client, 0);   // v3.77.25: X = SELF REPAIR (port del toggle T del lua GMod; el Overdrive pasa a la C)
        case EGGMAN_INDEX:     Command_EggmanLaser(client, 0);
        // v3.77.71: EL KIT GMOD — Blaze: X = Burning Javelin (sol<50) /
        // Sol Flame (sol>=50). Silver: X = Rocks (invocar / lanzar la 1a).
        case BLAZE_INDEX:      Blaze_Ability2(client);
        case SILVER_INDEX:     Silver_Ability2(client);
        // v3.77.94: X de KOLOSSOS = AGARRE (o cancel del agarre si grab_cancel 1)
        case KOLOSSOS_INDEX:   Kolossos_Ability2(client);
        // v3.60 (R26): la X de Sage depende del set prestado.
        // v3.62 (R28): SALLY -> escudo de FUEGO de equipo | ROUGE -> bat bomb
        case SAGE_INDEX:
        {
            if (g_iSageActiveSet[client] == SAGESET_CREAM)      Command_CreamRevive(client, 0);
            else if (g_iSageActiveSet[client] == SAGESET_SALLY) Sage_CastTeamShield(client, true);
            else if (g_iSageActiveSet[client] == SAGESET_ROUGE) Command_RougeBomb(client, 0);   // v3.77.45: el set de Sage SIGUE con la bomba
            else                                                 Command_RandomPower(client, 0);
        }
        default: PrintCenterText(client, "[X] Personaje sin Habilidad 2 definida");
    }
    return Plugin_Handled;
}

// v3.61 (R27): HABILIDAD 3 (tecla C) — comando UNICO: "el resto del
// elenco seguira con 2". AMY: "el comando de amy especial para cambiar
// pasara a ser su habilidad 3 direcrtamente (obiamente no tendra cd si
// no no tendria sentido si quiere camiar de modo salto o modo area)".
// SAGE: la 3 sigue siendo el CAMBIO DE SET ("con sage sera = la 3
// ahabilidad es para cambiar el set de habilidades", R26 intacto).
public Action Command_Ability3(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;
    if (!g_cvSJEnable.BoolValue) return Plugin_Handled;

    int charIdx = g_iPlayerCharIdx[client];
    if (charIdx < 0 || charIdx >= MAX_CHARS) return Plugin_Handled;

    // v3.76 (OM-SONIC): la 3a de SONIC = HOMING ATTACK encadenable (el
    // v5.4 MIGRADO de la Z intacto: su lugar lo ocupa el Spindash OM).
    if (charIdx == SONIC_INDEX) { HabilidadSonicSuperJump(client); return Plugin_Handled; }

    // v3.71 (OM-TAILS R2): la 3a de TAILS = CAMBIO DE MODO DEL CAÑÓN
    // (la T de GMod): Laser -> Burst -> Orbs -> Shockwave. SIN
    // cooldown: es preferencia, no ataque (solo anti-spam 0.5s =
    // convar tails_togglecd). El disparo sigue en la Z.
    if (charIdx == TAILS_INDEX) return Command_TailsCannon(client, args);

    // v3.77 (AMY OM): la 3a de AMY = LANZAMIENTO DE MARTILLO (el Throw
    // del GMod: 1a pulsacion arma, 2a lanza el martillo que vuela y
    // MANDA A VOLAR al que impacta con ragdoll falso + onda fisica).
    // El CAMBIO DE MODO (Z area <-> Z dash) vuelve a ser el bind
    // directo sm_amymodo en la tecla C ("La c permite cambiar entre el
    // ataque en area y el dash hammer" — owner) — como antes de v3.61.
    if (charIdx == AMY_INDEX) return Amy_OM_HammerThrow(client, args);

    if (charIdx == SAGE_INDEX) return Sage_SwapSet(client);

    // v3.63 (R29): la 3a de ROUGE = ONDA NEGRA (Black Wave): onda
    // expansiva negra SIN TEMBLOR que JALA (comunes y witch con el
    // metodo del martillo de Amy: cerebro apagado + congelados) hacia
    // v3.77.45: la C de Rouge = BAT BOMB SPRAY (movida intacta desde
    // la X — el owner: "las otras 2 habilidades que ya tiene muevelas
    // a la 3 y 4"). La ONDA NEGRA fue REEMPLAZADA por el kit GMod y
    // queda accesible SOLO por consola (sm_rouge_wave).
    if (charIdx == ROUGE_INDEX) return Command_RougeBomb(client, args);

    // v3.64 (R30): la 3a de KNUCKLES = METEOR STRIKE: en el AIRE se
    // eleva, apunta y con la 2a pulsacion de C se lanza en picada con
    // MEGA EXPLOSION (nativa, estilo "detonador" del Super Tank, SIN
    // tocar su VScript); EN TIERRA lanza la ESFERA DE FUEGO (la del
    // escudo de Sally) como proyectil que estalla al impactar. Todo lo
    // golpeado vuela: comunes, WITCH (WitchFlight), especiales por
    // PESO (excepto el tank), BOOMER con mecha diferida (patron Amy)
    // y PROPS/AUTOS con V activo (receta Amy sin conversion).
    if (charIdx == KNUCKLES_INDEX) return Command_KnuxSkyStrike(client, args);

    // v3.77.25 (Metal v5.0): la 3a de METAL SONIC = V. MAXIMUM OVERDRIVE
    // — la aura electrica + velocidad real se MUEVE de la X a la C
    // (pedido literal del owner: "mover la habilidad que tiene metal
    // actualmente que es esa aura electrica a la habilidad 3").
    // Cero cambio de logica: es la misma de siempre en su nueva tecla.
    if (charIdx == METALSONIC_INDEX) return Command_MetalOverdrive(client, args);

    // v3.77.71: la 3a de SILVER = TIME REVERSAL (la T del Lua); la de
    // CREAM = el DASH que faltaba (la T del Lua); la de EGGMAN = el
    // JETPACK BOOST (la E del Lua). Blaze queda con sus 2 (el Lua trae
    // 2 teclas: el kick/dash y el javelin/solflame).
    if (charIdx == SILVER_INDEX)  { Silver_Ability3(client); return Plugin_Handled; }
    // v3.77.94: la C de KOLOSSOS = INDICATOR (el peek del Lua: glow rojo
    // sobre todos los infectados en radio + pings, 5s)
    if (charIdx == KOLOSSOS_INDEX) { Kolossos_Ability3(client); return Plugin_Handled; }
    if (charIdx == CREAM_INDEX)   { Cream_Ability3(client);  return Plugin_Handled; }
    if (charIdx == EGGMAN_INDEX)  { Eggman_Ability3(client); return Plugin_Handled; }
    if (charIdx == BLAZE_INDEX)
    {
        PrintCenterText(client, "[Blaze] Z = Kick (suelo) / Sol Dash (aire) | X = Javelin / Sol Flame (según el meter SolFlame)");
        return Plugin_Handled;
    }

    PrintCenterText(client, "[X] Habilidad 3: solo Sonic (Homing Attack), Tails (modo del cañón), Amy (Lanzamiento — tecla V), Sage (cambio de set), Rouge (Bat Bomb), Knuckles (Meteoro) y Metal (Overdrive). Tu personaje sigue con 2 (Z/X)");
    return Plugin_Handled;
}

// v3.77 (AMY OM): HABILIDAD 4 = CARTAS DEL SUPER TANK de Amy (el viejo
// poder aleatorio de la X, INTACTO — "las cartas actuales de super tank
// pasaran a ser la habilidad 4"). Sage sigue con su reservada.
public Action Command_Ability4(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Handled;
    if (!g_cvSJEnable.BoolValue) return Plugin_Handled;

    int charIdx = g_iPlayerCharIdx[client];
    if (charIdx == AMY_INDEX)
        return Amy_OM_CmdPower4(client, args);
    // v3.77.71: la B de EGGMAN = SOAPY SHIELD (la T del Lua: bloquea el
    // cuerpo a cuerpo 5s, el atacante recibe 1s de stun)
    if (charIdx == EGGMAN_INDEX)
        { Eggman_Ability4(client); return Plugin_Handled; }
    // v3.77.94: la B de KOLOSSOS = BLOQUEO (parry total + contragolpe de roca)
    if (charIdx == KOLOSSOS_INDEX)
        { Kolossos_Ability4(client); return Plugin_Handled; }
    // v3.77.46: la B de Rouge = ONDA NEGRA REINTEGRADA ("la 4
    // habilidad lo ocupara el black wave que retiramos. lo
    // reintegraremos") — y con el FIX del bind de arriba por fin
    // responde a la tecla. El Cebo+Flash pasa a consola (sm_rouge_kick),
    // igual que estuvo la onda en la 3.77.45.
    if (charIdx == ROUGE_INDEX)
        return Command_RougeBlackWave(client, args);
    if (charIdx == SAGE_INDEX)
        PrintCenterText(client, "[SAGE] Habilidad 4: CARTAS DEL SUPER TANK (set AMY prestado)");
    else
        PrintCenterText(client, "[X] Habilidad 4: solo Amy (B = alterna modo del martillo: bumeran <-> comun) y Rouge (Onda Negra)");
    return Plugin_Handled;
}

// ===================================================================================
// v3.77.60: EL CUADRO DE DEFENSAS DEL EQUIPO (sm_defensas / sm_reducciones)
// Pedido del owner: "Tambien debe haber un cuadro que muestre la reduccion
// de dano general para todos los supervivientes". Recorre los supervivientes
// VIVOS y calcula su multiplicador de dano entrante ACTUAL con las mismas
// reglas que aplican los hooks reales de cada personaje:
//   - Amy: cartas del tarot (Amy_OM_TarotDmgMult) x Furia Protectora (0.70)
//   - Metal: INMUNE durante la embestida (damage = 0 en dash/drag/slam/
//     bounce); el resto de la vida pasiva x0.50
//   - Rouge: escalones por vida (x0.80 alto / x0.65 al 50% / x0.50 al 25%)
//   - Shadow: anillos inhibidores x0.50 mientras estan activos (15s)
//   - Knuckles: x0.25 mientras carga el puno (knux_damage_reduction)
//   - Sonic: los anillos ABSORBEN el dano antes que la vida (muestra el
//     contador — no es una reduccion %, es un escudo de N golpes)
//   - El resto: sin reduccion activa
// Se imprime como PANEL (el "cuadro") y en CONSOLA (detalle completo).
// ===================================================================================
public Action Command_Defensas(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;

    Panel panel = new Panel();
    panel.SetTitle("DEFENSAS DEL EQUIPO");
    panel.DrawText("Dano que recibe cada superviviente");
    panel.DrawText("------------------------");

    int vivos = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != 2) continue;   // solo supervivientes
        vivos++;

        char nombre[MAX_NAME_LENGTH];
        GetClientName(i, nombre, sizeof(nombre));
        int charIdx = g_iPlayerCharIdx[i];

        char linea[96];
        char fuente[64];
        float mult = Suite_GetDmgMult(i, charIdx, fuente, sizeof(fuente));

        if (mult <= 0.0)
            Format(linea, sizeof(linea), "%s: INMUNE (%s)", nombre, fuente);
        else if (mult < 1.0)
            Format(linea, sizeof(linea), "%s: -%.0f%% (%s)", nombre, (1.0 - mult) * 100.0, fuente);
        else if (charIdx == SONIC_INDEX && g_iSonicRings[i] > 0)
            Format(linea, sizeof(linea), "%s: %d anillos (absorben)", nombre, g_iSonicRings[i]);
        else
            Format(linea, sizeof(linea), "%s: sin reduccion", nombre);

        panel.DrawText(linea);

        // version consola con el personaje y el desglose
        PrintToConsole(client, "[Defensas] %s (%s): %s", nombre,
                       (charIdx >= 0 && charIdx < sizeof(g_CharNames)) ? g_CharNames[charIdx] : "superviviente",
                       linea);
    }

    if (vivos == 0)
        panel.DrawText("(nadie vivo)");

    panel.DrawText("------------------------");
    panel.DrawText("Cartas de Amy: solo a ella.");
    panel.DrawText("Detalle completo en consola.");
    panel.DrawItem("Cerrar");
    panel.Send(client, DefensasPanelHandler, 20);
    delete panel;

    return Plugin_Handled;
}

public int DefensasPanelHandler(Menu menu, MenuAction action, int param1, int param2)
{
    return 0;
}

// v3.77.60: el multiplicador de dano entrante ACTUAL de un superviviente
// segun su personaje y estado (las MISMAS reglas de los hooks reales; si
// devuelve <= 0.0 es INMUNE). fuente recibe el texto del porque.
float Suite_GetDmgMult(int i, int charIdx, char fuente[64], int maxlen)
{
    switch (charIdx)
    {
        case AMY_INDEX:
        {
            float mult = Amy_OM_TarotDmgMult(i);
            fuente[0] = '\0';
            if (mult != 1.0)
                Format(fuente, maxlen, "cartas x%.2f", mult);
            if (g_bAmyFuryActive[i])
            {
                mult *= AMY_FURY_RESIST_MULT;
                if (fuente[0] != '\0') Format(fuente, maxlen, "%s + Furia -30%%", fuente);
                else                   Format(fuente, maxlen, "Furia -30%%");
            }
            if (fuente[0] == '\0') Format(fuente, maxlen, "sin cartas activas");
            return mult;
        }
        case METALSONIC_INDEX:
        {
            if (g_iMetalChargeState[i] == METAL_STATE_DASH
                || g_iMetalChargeState[i] == METAL_STATE_DRAGGING
                || g_iMetalChargeState[i] == METAL_STATE_WALL_SLAM
                || g_iMetalChargeState[i] == METAL_STATE_BOUNCE)
            {
                Format(fuente, maxlen, "embestida en curso");
                return 0.0;   // damage = 0 en el hook real
            }
            Format(fuente, maxlen, "pasiva de Metal");
            return 0.5;
        }
        case ROUGE_INDEX:
        {
            float hpMax = 100.0;
            if (HasEntProp(i, Prop_Send, "m_iMaxHealth"))
                hpMax = float(GetEntProp(i, Prop_Send, "m_iMaxHealth"));
            if (hpMax <= 0.0) hpMax = 100.0;
            float frac = float(GetClientHealth(i)) / hpMax;
            if (frac <= 0.25)
            {
                Format(fuente, maxlen, "pasiva vida<=25%%");
                return (g_cvRougePassiveRedLow != null) ? g_cvRougePassiveRedLow.FloatValue : 0.50;
            }
            if (frac <= 0.50)
            {
                Format(fuente, maxlen, "pasiva vida<=50%%");
                return (g_cvRougePassiveRedMid != null) ? g_cvRougePassiveRedMid.FloatValue : 0.65;
            }
            Format(fuente, maxlen, "pasiva vida alta");
            return (g_cvRougePassiveRed != null) ? g_cvRougePassiveRed.FloatValue : 0.80;
        }
        case SHADOW_INDEX:
        {
            if (g_bInhibitorActive[i])
            {
                Format(fuente, maxlen, "anillos inhibidores");
                return 0.5;
            }
            Format(fuente, maxlen, "inhibidores en recarga");
            return 1.0;
        }
        case KNUCKLES_INDEX:
        {
            if (g_bKnuxCharging[i])
            {
                Format(fuente, maxlen, "cargando el puno");
                return (g_cvKnuxDamageReduc != null) ? g_cvKnuxDamageReduc.FloatValue : 0.25;
            }
            Format(fuente, maxlen, "sin reduccion");
            return 1.0;
        }
        case SONIC_INDEX:
        {
            // los anillos absorben el dano ANTES que la vida: no es un
            // multiplicador fijo — el cuadro muestra el contador aparte
            Format(fuente, maxlen, "anillos");
            return 1.0;
        }
        default:
        {
            Format(fuente, maxlen, "sin reduccion");
            return 1.0;
        }
    }
}

public void OnGameFrame()
{
    // v5.20.6 (Tails): FSM del PULSO DE PAUSA — PRIMERA linea y
    // ANTES de cualquier early-return: si un pulso quedara a medias
    // (server EN PAUSA) y el suite se apagara justo en ese instante,
    // la pausa quedaria huerfana. En reposo cuesta una comparacion
    // de int por frame (early-out inmediato).
    Tails_PausePulse_Frame();

    // v3.14: Validacion de ConVar antes de continuar
    if (g_cvSJEnable == null || !g_cvSJEnable.BoolValue) return;

    // v3.14: Validar offsets antes de usarlos (anti-crash)
    if (g_iOff_Incapacitated == -1 || g_iOff_LaggedMovement == -1) return;

    bool amyInDanger = false;
    bool amyExists = false;
    if (g_iCharTakenBy[AMY_INDEX] != 0 && g_iCharTakenBy[AMY_INDEX] > 0
        && g_iCharTakenBy[AMY_INDEX] <= MaxClients
        && IsClientInGame(g_iCharTakenBy[AMY_INDEX]))
    {
        amyExists = true;
    }

    if (amyExists)
    {
        int i = g_iCharTakenBy[AMY_INDEX];
        if (IsPlayerAlive(i))
        {
            if (GetEntData(i, g_iOff_Incapacitated, 1) > 0 ||
                SafeGetEntDataEnt(i, g_iOff_PounceAttacker) > 0 ||
                SafeGetEntDataEnt(i, g_iOff_TongueOwner) > 0 ||
                SafeGetEntDataEnt(i, g_iOff_JockeyAttacker) > 0 ||
                SafeGetEntDataEnt(i, g_iOff_PummelAttacker) > 0 ||
                SafeGetEntDataEnt(i, g_iOff_CarryAttacker) > 0)
            {
                amyInDanger = true;
            }
        }
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || !IsSurvivor(i)) continue;

        int charIdx = g_iPlayerCharIdx[i];

        if (charIdx == SONIC_INDEX)
        {
            if (amyInDanger)
            {
                if (!g_bSonicHeroMode[i])
                {
                    g_bSonicHeroMode[i] = true;
                    PrintCenterText(i, "[+] AMY ESTA EN PELIGRO! MODO IMPARABLE ACTIVADO!");
                    EmitSoundToClient(i, "mobius/sfx/boost.mp3");
                }
                Sonic_PushCommons(i);
                float currentLag = GetEntDataFloat(i, g_iOff_LaggedMovement);
                if (currentLag < 1.5) SetEntDataFloat(i, g_iOff_LaggedMovement, 1.5);
            }
            else
            {
                if (g_bSonicHeroMode[i])
                {
                    g_bSonicHeroMode[i] = false;
                    SetEntDataFloat(i, g_iOff_LaggedMovement, 1.0);
                    PrintCenterText(i, "Peligro neutralizado. Modo normal.");
                }
            }
        }

        if (charIdx == SHADOW_INDEX)
        {
            int buttons = GetClientButtons(i);
            Shadow_OnPlayerRunCmd_Proxy(i, buttons);
        }
    }
}

void Sonic_PushCommons(int client)
{
    float pos[3]; GetClientAbsOrigin(client, pos);
    float radius = 120.0;

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(pos, zPos) <= radius)
        {
            float push[3]; MakeVectorFromPoints(pos, zPos, push); NormalizeVector(push, push); ScaleVector(push, 300.0); push[2] = 150.0;
            TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
}

// ===================================================================================
// EVENTOS L4D & HOOKS CENTRALES
// ===================================================================================

public Action L4D_TankClaw_OnPlayerHit_Pre(int tank, int claw, int player)
{
    if (IsValidClient(player))
    {
        // v3.77.27 (ajuste 5): durante TODA la embestida, Metal es inmune
        // al control ("stagger de ningun tipo ni agarrado ni nada")
        if (g_iPlayerCharIdx[player] == METALSONIC_INDEX && Metal_ControlImmune(player)) return Plugin_Handled;
        if (g_iPlayerCharIdx[player] == KNUCKLES_INDEX && Knuckles_CheckTankCounter(tank, player)) return Plugin_Handled;
        if (g_iPlayerCharIdx[player] == AMY_INDEX && Amy_TankClawCounter(tank, player)) return Plugin_Handled;
        // v3.77.46 (Rouge v10.1): su counter = al de Knuckles — la garra
        // del tank se bloquea y el tank queda DESARMADO 5s
        if (g_iPlayerCharIdx[player] == ROUGE_INDEX && Rouge_CheckTankCounter(tank, player)) return Plugin_Handled;
        if (g_iPlayerCharIdx[player] == SONIC_INDEX && g_bSonicHeroMode[player]) return Plugin_Handled;
        if (g_iPlayerCharIdx[player] == SALLY_INDEX && Sally_IsBubbleActive(player)) return Plugin_Handled;
        // v3.62 (R28): el burbuja REGALADO de Sage protege igual
        if (g_bSageGiftWater[player]) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnKnockedDown(int client, int reason)
{
    if (IsValidClient(client))
    {
        // v3.77.27 (ajuste 5): cualquier razon de knockdown (puno/roca del
        // tank, charger...) no tumba a un Metal en plena embestida
        if (g_iPlayerCharIdx[client] == METALSONIC_INDEX && Metal_ControlImmune(client)) return Plugin_Handled;
        if (g_iPlayerCharIdx[client] == KNUCKLES_INDEX && Knuckles_IsPhysicsImmune(client)) return Plugin_Handled;
        if (g_iPlayerCharIdx[client] == AMY_INDEX && Amy_IsImpulseImmune(client)) return Plugin_Handled;
        if (g_iPlayerCharIdx[client] == SALLY_INDEX && Sally_IsBubbleActive(client)) return Plugin_Handled;
        // v3.77.46 (Rouge v10.1): la roca/el puno del tank NO la tumban
        // durante SU ventana de Contragolpe (= al de Knuckles)
        if (g_iPlayerCharIdx[client] == ROUGE_INDEX && g_bRougeCountering[client]) return Plugin_Handled;
        // v3.62 (R28): el burbuja REGALADO de Sage protege igual
        if (g_bSageGiftWater[client]) return Plugin_Handled;
        // v3.77.23 (pedido del owner 2026-10-09): la ROCA del tank
        // (KNOCKDOWN_TANK, reason 2 — la receta del l4d_block_stumble
        // 2.1 de Silvers que el owner paso de referencia) no tumba a
        // un Sonic en evasión (ventana activa o gracia) ni en
        // bola/spindash ("no tiene sentido que lo aturdan en
        // spindash") — mismo criterio del "el tank empuja"
        // (sonicom_spin_grabguard, default 1).
        if (reason == KNOCKDOWN_TANK
            && g_iPlayerCharIdx[client] == SONIC_INDEX
            && Sonic_TankKnockImmune(client)) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnStagger(int client, int source)
{
    // v3.77.28: forward REAL de left4dhooks que ESTE manager no tenia
    // (existia un "L4D_OnStagger" fantasma que nunca se disparaba — y
    // el _Post solo lo usa Tails). PRIMERA implementacion viva: stagger
    // de ningun tipo durante la embestida de Metal (y las inmunidades
    // fisicas de siempre de Knuckles/Amy que tampoco corrian aqui).
    if (IsValidClient(client))
    {
        if (g_iPlayerCharIdx[client] == METALSONIC_INDEX && Metal_ControlImmune(client)) return Plugin_Handled;
        if (g_iPlayerCharIdx[client] == KNUCKLES_INDEX && Knuckles_IsPhysicsImmune(client)) return Plugin_Handled;
        if (g_iPlayerCharIdx[client] == AMY_INDEX && Amy_IsImpulseImmune(client)) return Plugin_Handled;
        // v3.77.46 (Rouge v10.1): ningun stagger durante su Contragolpe
        if (g_iPlayerCharIdx[client] == ROUGE_INDEX && g_bRougeCountering[client]) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action Cmd_CreateRagdoll(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    CreateSonicRagdoll(client);
    return Plugin_Handled;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int inflictor = 0;

    Speed_Event_PlayerDeath(event, name, dontBroadcast);

    // v3.9: Limpieza de estado de Metal Sonic al morir (libera infectado agarrado, resetea carga)
    // v3.16: Metal v3.1 — usar el hook de muerte REAL (detona la explosion final
    // de la pasiva "Explota al morir" y luego limpia el estado)
    if (victim > 0 && IsClientInGame(victim))
    {
        Metal_Event_PlayerDeath(victim);
    }

    // v3.17/v3.76.2: Sonic ya NO se limpia aqui. Su muerte corre en su
    // PROPIO hook player_death POST (Sonic_OnPluginStart -> HookEvent,
    // paridad exacta con Tails_Event_PlayerDeath): el PRE del manager
    // corria ANTES de que el motor procesara la muerte, y el restore
    // del cuerpo que hace Sonic_KillAvatar dejaba ver el corpse del
    // survivor (cuerpo + ragdolls dobles en pantalla, reporte del
    // owner). En POST el orden es el mismo probado de Tails.

    // v3.77.49: la Rouge ya NO se limpia aqui (paridad exacta con el
    // fix del Sonic v3.76.2): este PRE corria ANTES del hook POST
    // propio de Rouge y su Rouge_KillAvatar mataba el avatar ANTES de
    // que Rouge_Event_PlayerDeath pudiera soltar el ragdoll rouge.mdl
    // de la v10 — el ragdoll JAMAS salio y el cuerpo revivia para el
    // corpse del survivor. TODO pasa en el POST propio: ragdoll +
    // ventana anti-corpse + reset. (Rouge_OnPlayerDeath queda vivo
    // para el OnPluginEnd.)

    // v3.11: Limpieza de estado de Amy al morir (reset fury, momentum, disarm, timers)
    if (victim > 0 && IsClientInGame(victim))
    {
        Amy_OnPlayerDeath(victim);
    }

    // v3.12: Limpieza de estado de Cream al morir (cancela heal, libera timers)
    if (victim > 0 && IsClientInGame(victim))
    {
        Cream_OnPlayerDeath(victim);
    }

    // v3.60 (R26): Sage al morir: anula el ::SonicSageIdx del vscript
    // (el set se CONSERVA para su respawn)
    if (victim > 0 && IsClientInGame(victim))
    {
        Sage_OnPlayerDeath(victim);
    }

    // v3.13: Limpieza de estado de Sally al morir (reset escudos, barreras, cooldowns)
    if (victim > 0 && IsClientInGame(victim))
    {
        Sally_OnPlayerDeath(victim);
    }

    // v3.15: Limpieza de estado de Eggman al morir (remover avion de Air Support)
    if (victim > 0 && IsClientInGame(victim))
    {
        Eggman_OnPlayerDeath(victim);
    }

    if (!IsValidClient(victim)) return Plugin_Continue;

    float damage = 9999.0;
    int dmgType = 0;

    return Sonic_OnPlayerDeath(victim, attacker, inflictor, damage, dmgType);
}

// =====================================================================
// =====================================================================
// v3.77.40: AVATARES SIN BARRIDO EN CALIENTE — ADOPCION EN EL MONTAJE.
//
// La 3.77.39 puso un repetidor cada 3 s "ref-aware": en el papel solo
// debian morir huerfanos; en el server del owner reiniciaba avatares
// VIVOS (reporte 2026-10-10). El calendario completo SE BORRA y los
// huerfanos pasan a morir en su ORIGEN:
//   - REEMPLAZO LIMPIO + ADOPCION en el montaje de cada FSM (ver los
//     X_KillGhostAvatarProps de Knuckles/sonic/Tails/Amy/Metal): una
//     FSM es la UNICA creadora de los props con su nombre de avatar —
//     un prop asi que nadie rastrea es huerfano por definicion.
//   - Este barrido queda SOLO para el arranque del mapa (OnMapStart):
//     en ese instante no existe NINGUN avatar legitimo (las FSM aun no
//     han montado nada) y los refs serializados del mapa anterior
//     jamas colisionan con los de props vivos. Ademas recolecta
//     primero y mata despues — nunca FindEntityByClassname sobre un
//     handle recien muerto.
// =====================================================================
bool OM_IsTrackedAvatarRef(int ref)
{
    // v3.77.40: un ref LEGITIMO puede ser negativo (bit alto del
    // serial del handle) — el "ref <= 0" de la .39 podia desrastrear
    // un avatar vivo frente al barrido. Solo el 0 es "sin avatar".
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iKnuxAvatar[i]  == ref || g_iKnuxAvatarL[i]  == ref) return true;
        if (g_iSonicAvatar[i] == ref || g_iSonicAvatarL[i] == ref) return true;
        if (g_iSonicBall[i]   == ref) return true;
        if (g_iAmyOMAvatar[i] == ref || g_iAmyOMAvatarL[i] == ref) return true;
        if (g_iMetalAvatar[i] == ref || g_iMetalAvatarL[i] == ref) return true;
        if (g_iTailsAvatar[i] == ref || g_iTailsAvatarL[i] == ref) return true;
        if (g_iRougeAvatar[i] == ref || g_iRougeAvatarL[i] == ref) return true;   // v3.77.45: Rouge OM
        if (g_iShadowAvatar[i] == ref || g_iShadowAvatarL[i] == ref) return true; // v3.77.49: Shadow OM
        if (g_iCreamAvatar[i] == ref || g_iCreamAvatarL[i] == ref) return true;   // v3.77.69: Cream (gap fix — la 3.77.68 no lo registro)
        if (g_iEggmanAvatar[i] == ref || g_iEggmanAvatarL[i] == ref) return true; // v3.77.69: Eggman (9o)
        if (g_iBlazeAvatar[i] == ref || g_iBlazeAvatarL[i] == ref) return true;   // v3.77.69: Blaze (10o)
        if (g_iSilverAvatar[i] == ref || g_iSilverAvatarL[i] == ref) return true; // v3.77.69: Silver (11o)
    }
    return false;
}

void OM_SweepOrphanAvatars()
{
    // nombres EXACTOS de todos los avatares que el suite crea (actuales
    // R/L + bola del spin, y legacy de versiones viejas por si quedaron
    // en un save de campaña — esos no los rastrea nadie: siempre mueren)
    static const char sAvatarNames[][] = {
        "knuckles_avatar_om",   "knuckles_avatar_om_l",
        "sonic_avatar_om",      "sonic_avatar_om_l",
        "sonic_ball_om",
        "amy_avatar_om",        "amy_avatar_om_l",
        "metal_avatar_om",      "metal_avatar_om_l",
        "tails_avatar_om",      "tails_avatar_om_l",
        "rouge_avatar_om",      "rouge_avatar_om_l",
        "shadow_avatar_om",     "shadow_avatar_om_l",
        "cream_avatar_om",      "cream_avatar_om_l",   // v3.77.69: gap fix (la 3.77.68 lo dejo fuera del barrido)
        "eggman_avatar_om",     "eggman_avatar_om_l",  // v3.77.69: 9o avatar
        "blaze_avatar_om",      "blaze_avatar_om_l",   // v3.77.69: 10o avatar (modelo CST)
        "silver_avatar_om",     "silver_avatar_om_l",  // v3.77.69: 11o avatar (modelo CST)
        "tails_avatar",         "tails_avatar_tp",
        "knux_avatar",          "sonicom_avatar",
        "metalom_avatar",       "amyom_avatar"
    };
    static const char sPropClasses[][] = {
        "prop_dynamic_override", "prop_dynamic"
    };

    int ghosts[32];
    int ng = 0;
    char nameBuf[64];

    // v3.77.40: PRIMERO se recolecta, LUEGO se mata. El .39 mataba con
    // el FindEntityByClassname en plena marcha — iterar desde un handle
    // recien muerto es tierra de nadie en L4D2. Este barrido ademas YA
    // SOLO corre en el arranque del mapa (en caliente no existe mas).
    for (int c = 0; c < sizeof(sPropClasses); c++)
    {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, sPropClasses[c])) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            GetEntPropString(ent, Prop_Data, "m_iName", nameBuf, sizeof(nameBuf));
            if (nameBuf[0] == '\0') continue;

            for (int n = 0; n < sizeof(sAvatarNames); n++)
            {
                if (!StrEqual(nameBuf, sAvatarNames[n], false)) continue;

                // REF-AWARE: un avatar VIVO rastreado por alguna FSM es
                // legitimo y NO se toca. El resto es huerfano de verdad.
                if (OM_IsTrackedAvatarRef(EntIndexToEntRef(ent))) break;

                if (ng < sizeof(ghosts)) ghosts[ng++] = EntIndexToEntRef(ent);
                break;
            }
        }
    }

    for (int g = 0; g < ng; g++)
    {
        int e = EntRefToEntIndex(ghosts[g]);
        if (e > 0 && IsValidEntity(e)) AcceptEntityInput(e, "Kill");
    }

    if (ng > 0)
        PrintToServer("[Suite 3.77.43] Barrido del ARRANQUE DE MAPA: %d huerfano(s) eliminado(s) (en caliente YA NO hay barrido: reemplazo limpio + adopcion en cada montaje).", ng);
}

public void OnMapStart()
{
    // v3.77.40: EL UNICO BARRIDO QUE QUEDA — arranque del mapa, ANTES
    // de que cualquier FSM monte un avatar. EN CALIENTE YA NO EXISTE
    // BARRIDO (orden del owner 2026-10-10: el repetidor de 3 s de la
    // .39 reiniciaba avatares vivos). Los huerfanos mueren en su
    // ORIGEN ahora: reemplazo limpio + adopcion de fantasmas en el
    // montaje de cada FSM (X_KillGhostAvatarProps en Knuckles/sonic/
    // Tails/Amy/Metal) — nada vuelve a tocar un avatar vivo.
    OM_SweepOrphanAvatars();

    // v3.77.89 — SC PAUSA: estado fresco por mapa (round_start tambien lo
    // resetea, pero un mapa nuevo sin ronda todavia no debe creer que ya
    // salieron del saferoom)
    SC_Pause_RoundReset();

    // v3.75: arranca la fase de configs del mapa; hasta
    // OnConfigsExecuted, los cambios de cvars son la carga del propio
    // Sonic_Suite.cfg y NO disparan el auto-guardado.
    g_bSuiteCfgLoading = true;

    PrecacheAndAddToDownloads();
    LoadOwnersFromFile();
    RebuildCharOccupancyFromPlayers();

    // v3.25: el sprite del ring del vuelo de witches se precachea AQUI
    // (una vez por mapa, en fase de precache legitima). v2.2-viejo lo
    // hacia "lazy" en pleno gameplay: vector de inestabilidad del motor.
    WitchFlight_OnMapStart();

    Sonic_OnMapStart();
    Tails_OnMapStart();
    Knuckles_OnMapStart();
    Amy_OnMapStart();
    Sally_OnMapStart();
    Shadow_OnMapStart();
    Rouge_OnMapStart();
    Cream_OnMapStart();
    Blaze_OnMapStart();    // v3.77.69: avatar Blaze (10o)
    Silver_OnMapStart();   // v3.77.69: avatar Silver (11o)
    Kolossos_OnMapStart(); // v3.77.94: modelo/avatar + sonidos om/kolossos + roca nativa
    Sage_OnMapStart();      // v3.60 (R26): reset de sets/CDs de cambio
    Metal_OnMapStart();
    OM_Stun_OnMapStart();   // v3.76.4: precache estrellas/zap + deteccion del VPK om_
    Eggman_OnMapStart();
    PathSense_OnMapStart();   // v3.77.65 (= 3.77.59): reset de sellos de tiempo (el GameTime renace con cada mapa)

    // v3.30 BLINDAJE: Speed AL FINAL. Si un modulo lanza una excepcion,
    // SourceMod ABORTA toda la cadena de llamadas y los modulos posteriores
    // NO corren (fue la causa del crash del capitulo 2: la excepcion del
    // KillTimer de Speed dejo a los 10 personajes sin precache en el mapa
    // 2+). Con Speed al final, ningun fallo suyo puede dejar a los demas
    // sin inicializar. Speed v2.4 ya no puede lanzar excepciones, pero el
    // blindaje se queda por si el futuro trae otra.
    Speed_OnMapStart();
}

public void OnMapEnd()
{
    // v3.30: PRIMERO Speed (cero nativas: solo asigna nulls, no puede
    // lanzar excepciones ni abortar esta cadena). Los timers NO_MAPCHANGE
    // mueren solos al cerrar el nivel; sin olvidar los handles aqui, el
    // OnMapStart del mapa siguiente encontraba handles muertos y el
    // KillTimer del watchdog lanzaba la excepcion que abortaba TODA la
    // inicializacion de los 10 personajes (crash del capitulo 2).
    Speed_OnMapEnd();

    // v3.24: el vuelo de witches (mata el tick de 33 Hz y vacia los slots
    // por referencia: garantia de CERO callbacks con datos del mapa
    // anterior en el mapa nuevo, sin esperar al autolimpieza).
    WitchFlight_OnMapEnd();

    // v3.36: Eggman ahora tambien limpia su estado en OnMapEnd
    // (antes esta funcion EXISTIA en Eggman.inc pero nadie la llamaba:
    // los ArrayLists de minas/fuegos quedaban con refs del mapa viejo)
    Eggman_OnMapEnd();

    Sally_OnMapEnd();
    Amy_OnMapEnd();
    Rouge_OnMapEnd();
    Shadow_OnMapEnd();     // v3.77.49: FSM + refs del avatar a cero
    Cream_OnMapEnd();      // v3.77.68: idem Cream (8o avatar)
    Blaze_OnMapEnd();      // v3.77.69: idem Blaze (10o avatar)
    Silver_OnMapEnd();     // v3.77.69: idem Silver (11o avatar)
    Kolossos_OnMapEnd();   // v3.77.96: idem Kolossos (14o avatar, v1.2) — suelta el
                           // handle del FSM de 10Hz + kit/refs a cero: sin esto el
                           // OnMapStart del mapa siguiente heredaba un handle
                           // muerto (la leccion del crash del capitulo 2, v3.30)

    // v3.76.4: stun OM — timers/slots del sistema (Metal) + ragdolls
    // falsos y witch stun de la bola de Sonic (v6.4)
    OM_Stun_OnMapEnd();
    Sonic_OM_StunOnMapEnd();

    // v3.75: flush del auto-guardado pendiente ANTES de que muera el
    // mapa. Si se dejara solo al timer, la re-ejecucion del archivo
    // en el mapa siguiente pisaria ese ultimo cambio con el valor
    // viejo (ventana perdida de 1s).
    if (g_hSuiteCfgSaveTimer != null)
    {
        KillTimer(g_hSuiteCfgSaveTimer);
        g_hSuiteCfgSaveTimer = null;
        SuiteCfg_Save();
    }
}

public void OnConfigsExecuted()
{
    // v3.75: las configs del mapa terminaron de ejecutarse (el
    // Sonic_Suite.cfg ya se aplico). Desde aqui, cualquier cambio de
    // un cvar del suite dispara el auto-guardado.
    g_bSuiteCfgLoading = false;

    // v3.77.4 (v96-OM): reconciliar el documento — agregar al final los
    // cvars del suite que falten (recarga/actualizacion del plugin),
    // sin sobrescribir las lineas que ya existen
    SuiteCfg_Reconcile();
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // v3.77.40: AQUI YA NO SE BARRE NADA. En el arranque de ronda las
    // FSM estan justo montando avatares frescos (player_spawn llega
    // pegado al round_start) — barrer en este momento era apostar a un
    // orden de eventos que no existe. Los huerfanos reales mueren en
    // el montaje de su propia FSM (adopcion), no aqui.
    Sonic_OnRoundStart();
    Tails_Event_RoundStart(event, name, dontBroadcast);
    Knux_Event_RoundEnd(event, name, dontBroadcast);

    // v3.12: Resetear el uso de Resurreccion de Cream al iniciar nueva ronda
    Cream_Event_RoundEnd(event, name, dontBroadcast);

    // v3.77.89 — SC PAUSA: la ronda arranca fresca (nadie ha salido del
    // saferoom, sin pulsos de entrada consumidos)
    SC_Pause_RoundReset();
}

public void OnClientPutInServer(int client)
{
    g_flNextAllowed[client] = 0.0;
    g_iPlayerSoundIdx[client] = INVALID_SOUND_INDEX;
    g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX;
    g_bSonicHeroMode[client] = false;

    Sonic_OnClientPutInServer(client);
    Tails_OnClientPutInServer(client); // v3.17: reset TOTAL del slot (handles colgados del cliente anterior)
    Knuckles_OnClientPutInServer(client);
    Sally_OnClientPutInServer(client);
    Shadow_OnClientPutInServer(client);
    Rouge_OnClientPutInServer(client);
    Cream_OnClientPutInServer(client);
    Sage_OnClientPutInServer(client);    // v3.60 (R26): reset del slot
    Metal_OnClientPutInServer(client);
    Eggman_OnClientPutInServer(client);

    if (AreClientCookiesCached(client))
    {
        LoadPlayerSoundChoice(client);
        LoadPlayerCharChoice(client);
        MaybePromptMenus(client); 
    }
}

public void OnClientCookiesCached(int client)
{
    LoadPlayerSoundChoice(client);
    LoadPlayerCharChoice(client);
    RebuildCharOccupancyFromPlayers();
    MaybePromptMenus(client);
    Speed_OnClientCookiesCached(client);
    // Doll System: recargar preferencias de poderes cuando la cookie ya está en caché
    DollSys_OnClientCookiesCached(client);
}

public void OnClientDisconnect(int client)
{
    if (client < 1 || client > MaxClients) return;

    // v3.77.79 — modo solo: el cache del host local muere con el slot (el
    // watchdog/ el siguiente comando lo repone)
    if (g_iSoloHostClient == client) g_iSoloHostClient = -1;

    // Doll System: limpiar estado del jugador antes de liberar el slot
    DollSys_OnClientDisconnect(client);

    // v3.20: liberar el cancel de stagger pendiente del slot (red de
    // seguridad del fix "no se levantan": el slot queda libre YA)
    SIStagger_OnClientDisconnect(client);

    // v3.76.4: liberar el stun OM del slot (timers de FX/estrellas)
    OM_Stun_OnClientDisconnect(client);

    // v3.77.65 (= 3.77.59): la concesión manual de la pasiva de ruta
    // muere con el slot (la nativa revive sola con la señal del
    // personaje)
    PathSense_OnClientDisconnect(client);

    // Liberar personaje asignado
    int cur = g_iPlayerCharIdx[client];
    if (cur >= 0 && cur < MAX_CHARS && g_iCharTakenBy[cur] == client)
        g_iCharTakenBy[cur] = 0;

    // v3.16 FIX: limpiar el estado de los modulos ANTES de invalidar el indice
    // de personaje. Desde v3.14 esta limpieza corria DESPUES de poner
    // g_iPlayerCharIdx = INVALID, y los guards internos de cada modulo
    // (g_iPlayerCharIdx[client] != X_INDEX) rechazaban la llamada: la
    // "limpieza forzada" de disconnect era un no-op silencioso.
    CleanupCharModuleState(client, cur);

    // v3.77.44: la ventana de parry del slot muere sola en el .nut
    // (validez del jugador + duracion); no hay registro que limpiar.

    // Speed_sonic se limpia solo via Event_PlayerDisconnect, pero forzamos aqui tambien
    Speed_OnPlayerDeath(client);

    g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX;
    g_bSonicHeroMode[client] = false;
    g_iPlayerSoundIdx[client] = INVALID_SOUND_INDEX;
    g_flNextAllowed[client] = 0.0;
}

// v3.77.44 — EL REGISTRO DE PERSONAJES DEL PARRY MURIO (OM_PublishParryChar
// + knxparry_chars + los convars espejo uk_parry_chars/uk_amy_chars):
// era la mitad de la torre de naipes que hacia que "el Vscript jamas se
// enterara" (orden del owner: "No tienes que poner un identificador de
// personaje... sencillamente el parry este Vscript puede identificar si
// es knuckles o amy quien llama"). LA ENTRADA ES LA IDENTIDAD — patron
// SetAmyMode del supertank: el codigo de Knuckles llama a ChCh_KnxNotify,
// el codigo de Amy llama a ChCh_AmyNotify (ambas en el chch_parrying.nut
// v2.8, por RunScriptCode). Nadie mas las llama; nada hay que publicar.

// v3.16: limpia el estado del modulo del personaje indicado. Se usa al
// desconectar y al CAMBIAR de personaje: antes el cambio de clase via menu
// no limpiaba NADA (quedabas congelado/teñido/velocidad alterada si cambiabas
// con una habilidad activa, p.ej. Metal a mitad de un WALL_SLAM).
void CleanupCharModuleState(int client, int charIdx)
{
    switch (charIdx)
    {
        // v3.17: SONIC y TAILS entran en la limpieza centralizada: cambiar de
        // personaje (o desconectar) con homing/vuelo/laser activos ya no deja
        // estado residual (movetype, colision, timers de laser colgados).
        // v3.18: KNUCKLES tambien (Carga/Counter/Agarre de pared/Meteor Smash:
        // restaurar MOVETYPE/LaggedMovement/gravedad/tinte/takedamage).
        // v3.76.1: Sonic pasa a Sonic_CleanupState (limpieza SIN ragdoll,
        // patron Tails_OnPlayerDeath). Antes llamaba Sonic_Event_PlayerDeath
        // y cada cambio de personaje/disconnect dejaba el ragdoll OM tirado.
        case SONIC_INDEX:      Sonic_CleanupState(client);
        case TAILS_INDEX:      Tails_OnPlayerDeath(client);
        case KNUCKLES_INDEX:   Knuckles_OnPlayerDeath(client);   // v3.77.30: + avatar fuera (sin ragdoll — no murio)
        case METALSONIC_INDEX: Metal_OnPlayerDeath(client);
        case ROUGE_INDEX:      Rouge_OnPlayerDeath(client);
        case AMY_INDEX:        Amy_OM_CleanupState(client);   // v3.77: limpieza OM (avatar/hammer) + la clasica
        case CREAM_INDEX:      Cream_OnPlayerDeath(client);
        case SALLY_INDEX:      Sally_OnPlayerDeath(client);
        case EGGMAN_INDEX:     Eggman_OnClientDisconnect(client);
        case SAGE_INDEX:       Sage_ResetState(client);   // v3.60 (R26): set + idx vscript
        // v3.77.70: Blaze/Silver seleccionables — avatar fuera EN EL ACTO al
        // cambiar de personaje o desconectar (antes esperaba al proximo tick
        // de su FSM; la FSM igual lo baja sola si algo se escapa)
        case BLAZE_INDEX:      { Blaze_ResetGameplay(client, true); Blaze_KillAvatar(client); }
        case SILVER_INDEX:     { Silver_ResetGameplay(client, true); Silver_KillAvatar(client); }
        // v3.77.94: cancela kit + avatar + vida 670 fuera (receta Metal)
        case KOLOSSOS_INDEX:   Kolossos_CleanupState(client);
    }
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        char clientName[64]; GetClientName(client, clientName, sizeof(clientName));

        // v3.77.91: el 3er param de estos handlers es bool dontBroadcast
        // (firma de evento) — view_as<bool> = mismo valor, cero warning 213.
        Speed_Event_PlayerSpawn(event, clientName, view_as<bool>(client));
        Knux_Event_PlayerSpawn(event, clientName, view_as<bool>(client));
        Shadow_Event_PlayerSpawn(event, clientName, view_as<bool>(client));
        Rouge_Event_PlayerSpawn(event, clientName, view_as<bool>(client));
        Cream_Event_PlayerSpawn(event, clientName, client);
        Sage_Event_PlayerSpawn(client);          // v3.60 (R26): set + aura + idx vscript

        // v3.24: Amy FALTABA aqui. Amy_Event_PlayerSpawn existe desde v45
        // pero nadie la llamaba: los resets por spawn (cooldown del strike,
        // victim state, saltos) y el ciclo de SDKHooks (OnTakeDamage pasivo
        // + PreThink, unhook+rehook limpio) solo corrian si el jugador ya
        // estaba conectado al cargar el plugin. En un server normal (plugin
        // carga sin gente), esos hooks/state quedaban SIN aplicar hasta el
        // hot-reload siguiente.
        Amy_Event_PlayerSpawn(event, name, client);

        // v3.16: reset defensivo de Metal Sonic al spawn (por si quedo estado
        // residual de la vida anterior: congelado, teñido de rojo, etc.)
        Metal_Event_PlayerSpawn(event, clientName, client);

        // v3.77.44: sin re-publicacion de personaje — el registro murio
        // (la entrada del parry la llama el codigo de cada habilidad).

        // v3.17: reset defensivo de Sonic al spawn (MOVETYPE_FLY/colision del
        // homing, contador de saltos del Insta-Shield)
        Sonic_Event_PlayerSpawn(event, name, client);

        // v3.15: Hook de Eggman spawn (invoca avion de Air Support)
        if (g_iPlayerCharIdx[client] == EGGMAN_INDEX)
        {
            Eggman_OnPlayerSpawn(client);
        }

        // v3.70 (OM-TAILS): avatar espejo OM de Tails (tails.mdl del VPK
        // de recursos) + hook de cancel por dano (paridad GMod OM)
        if (g_iPlayerCharIdx[client] == TAILS_INDEX)
        {
            Tails_Event_PlayerSpawn(client);
        }

        // v3.77.89 — SC PAUSA [2]: primer spawn de quien entra con la ronda
        // ya andando (conexion/reconexion a mitad): pulso de re-sincronizacion
        // UNA vez por ronda por jugador (su vista/cuerpo aun no estan
        // encajados — el momento exacto del "queda chueco el cuerpo").
        // Los spawns del arranque de ronda NO disparan (g_bSCLeftStart aun
        // false); los respawns posteriores si (cuerpo nuevo que re-encajar).
        if (g_cvSCPausaConexion != null && g_cvSCPausaConexion.BoolValue
            && g_bSCLeftStart && !g_bSCConnPulsed[client] && !IsFakeClient(client))
        {
            g_bSCConnPulsed[client] = true;
            SC_Pause_Request(client, "spawn a mitad de ronda", false);
        }
    }
}

void PrecacheAndAddToDownloads()
{
    for (int i = 0; i < MAX_SOUNDS; i++)
    {
        AddSoundToDownloadsAndPrecache(g_SoundPaths[i]);
    }
}

public Action Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
    // v3.14: Validacion de ConVar null
    if (g_cvSJEnable == null || !g_cvSJEnable.BoolValue) return Plugin_Continue;

    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!IsValidClient(client) || !IsSurvivor(client)) return Plugin_Continue;

    // v3.14: Validar g_bTailsFlying antes de acceder
    if (g_iPlayerCharIdx[client] == TAILS_INDEX)
    {
        if (g_bTailsFlying[client]) return Plugin_Continue;
    }

    PlayJumpSound(client);
    TryApplySonicBoostOnJump(client);

    // v3.77.46: OM AIR CONTROL — el impulso hacia adelante al saltar
    // (Rouge/Knuckles/Amy/Sonic/Metal; el steering vive en RunCmd)
    OM_JumpImpulse(client);
    return Plugin_Continue;
}

void PlayJumpSound(int client)
{
    if (client < 1 || client > MaxClients) return;

    int idx = g_iPlayerSoundIdx[client];
    if (idx < 0 || idx >= MAX_SOUNDS) return;

    // v3.14: Validar ConVars antes de usar
    if (g_cvSJCooldown == null || g_cvSJVolume == null) return;

    float now = GetEngineTime();
    if (now < g_flNextAllowed[client]) return;

    g_flNextAllowed[client] = now + g_cvSJCooldown.FloatValue;
    EmitSoundToAll(g_SoundPaths[idx], client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, g_cvSJVolume.FloatValue);
}

void TryApplySonicBoostOnJump(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;

    // v3.14: Validar offsets y ConVars
    if (g_iOff_Velocity == -1) return;
    if (g_cvVelZMin == null || g_cvSonicBoost == null) return;

    float vel[3];
    GetEntDataVector(client, g_iOff_Velocity, vel);

    if (vel[2] >= g_cvVelZMin.FloatValue)
    {
        float mult = g_cvSonicBoost.FloatValue;
        // v3.14: Validar que el multiplicador sea positivo
        if (mult <= 0.0) mult = 1.0;
        vel[2] *= mult;
        SetEntDataVector(client, g_iOff_Velocity, vel);
    }
}

public void OnPlayerSelectCharacter(int client)
{
    if (!IsClientInGame(client)) return;

    int charIdx = g_iPlayerCharIdx[client];
    if (charIdx < 0 || charIdx >= MAX_CHARS) return;

    // v3.77.53: LA SENAL — el CST (y quien escuche) sabe YA quien es quien.
    // Se dispara AQUI (commit del menu) y tambien en LoadPlayerCharChoice
    // (cookie al reconectar), freechars y el strip del Rebuild.
    FireCharSignal(client, charIdx);

    // v3.77.44: sin publicacion de personaje (registro fuera; la
    // entrada del parry la llama la habilidad de cada quien).

    // v3.77.30: FILA DE BINDS COMPLETA E IDEMPOTENTE — fix del
    // desalineado de ranuras al cambiar de personaje (reporte del
    // owner: viniendo de Amy, la C quedaba en sm_amymodo y la
    // habilidad 3 "se iba a la 4" via el bind V heredado; y
    // Knuckles/Rouge/Metal nunca recibian su bind de la C).
    // Regla unica: Z/X SIEMPRE; C = habilidad 3 para TODOS excepto
    // Amy (su fila propia c/v/b); V/B fuera de Amy vuelven a su
    // estado neutral (unbind) para que no queden apuntando a
    // comandos de otro personaje.
    ClientCommand(client, "bind z sm_sjs_ability1");
    ClientCommand(client, "bind x sm_sjs_ability2");
    if (charIdx == AMY_INDEX)
    {
        ClientCommand(client, "bind c sm_amymodo");
        ClientCommand(client, "bind v sm_sjs_ability3");
        ClientCommand(client, "bind b sm_sjs_ability4");
    }
    else
    {
        ClientCommand(client, "bind c sm_sjs_ability3");
        ClientCommand(client, "unbind v");
        // v3.77.46 — EL FIX DEL "la 4 esta sin usar": la fila hacia
        // "unbind b" para todo el que no era Amy, y la B de Rouge
        // (Cebo+Flash en la 3.77.45, Onda Negra ahora) NUNCA se bindeo.
        // v3.77.94: KOLOSSOS tambien usa la B (Bloqueo — kit de 4)
        if (charIdx == ROUGE_INDEX || charIdx == KOLOSSOS_INDEX)
            ClientCommand(client, "bind b sm_sjs_ability4");
        else
            ClientCommand(client, "unbind b");
    }

    char ability1[32], ability2[32];

    switch (charIdx)
    {
        case SONIC_INDEX:      { ability1 = "Spindash / DropDash"; ability2 = "Peel Out"; }   // v3.76 OM
        case TAILS_INDEX:      { ability1 = "Laser";         ability2 = "Vuelo"; }
        case KNUCKLES_INDEX:   { ability1 = "Puno";          ability2 = "Counter"; }
        case AMY_INDEX:        { ability1 = "Golpe AOE + Defensa / Dash"; ability2 = "Cartas del Tarot"; }   // v3.77 OM (V = lanzamiento, B = super tank)
        case SALLY_INDEX:      { ability1 = "Escudo Fuego";  ability2 = "Escudo Burbuja"; }
        case SHADOW_INDEX:     { ability1 = "Chaos Snap";    ability2 = "Chaos Blast"; }
        case ROUGE_INDEX:      { ability1 = "Barrido";       ability2 = "Contragolpe"; }   // v3.77.46
        case CREAM_INDEX:      { ability1 = "Curar";         ability2 = "Revivir"; }
        case METALSONIC_INDEX: { ability1 = "Destructive Charge"; ability2 = "V. Maximum Overdrive"; }
        case EGGMAN_INDEX:     { ability1 = "Badnik Mines";  ability2 = "Death Egg Laser"; }
        case SAGE_INDEX:       { ability1 = "Set activo (Z)"; ability2 = "Set activo (X)"; }   // v3.60: nombres dinamicos abajo
        // v3.77.70: personajes CST de modelo puro — su "poder" es el modelo
        // (el guard aplica el cfg CST al instante) + el avatar espejo
        case BLAZE_INDEX:      { ability1 = "(modelo CST)";  ability2 = "(sin habilidades)"; }
        case SILVER_INDEX:     { ability1 = "(modelo CST)";  ability2 = "(sin habilidades)"; }
        // v3.77.94: el colosal — kit completo de 4 (fila Z X C B)
        case KOLOSSOS_INDEX:   { ability1 = "Avalancha";     ability2 = "Agarre"; }
    }

    PrintToChat(client, "[SonicJump] Personaje: %s", g_CharNames[charIdx]);
    PrintToChat(client, "[Controles] Z: %s | X: %s", ability1, ability2);

    // v3.77.28 (Metal v5.3): al ESCOGER a Metal su tope de vida pasa a
    // 175 YA (no espera al proximo spawn): con vida llena (100) arranca
    // directamente a 175; herido conserva su vida actual. El spawn y el
    // re-afirmador del PreThink lo sostienen despues.
    if (charIdx == METALSONIC_INDEX)
        Metal_ApplyMaxHealth(client);

    // v3.77.46 (Rouge v10.1): vida max 125 al escogerla (receta Metal
    // 175) y camino de vuelta al 100 para quien deje de ser Rouge
    if (charIdx == ROUGE_INDEX)
        Rouge_ApplyMaxHealth(client);
    else if (g_bRougeMaxHpApplied[client])
        Rouge_RestoreMaxHealth(client);

    // v3.76 (OM-SONIC): la 3a de Sonic = HOMING ATTACK encadenable
    if (charIdx == SONIC_INDEX)
    {
        PrintToChat(client, "[Sonic] Z = SPINDASH en suelo (bola que arrasa) / DROPDASH en el aire (picoada que aterriza en bola). X = PEEL OUT (carga 3s -> carrera turbo; toca a un caidor para levantarlo). C = HOMING ATTACK encadenable.");
        PrintToChat(client, "[Sonic] Anillos: el dano se gasta en anillos antes que en vida (se recargan golpeando con la bola). Ajustes: sm_soniccd");
    }

    // v3.77 (AMY OM): la Amy de las 4 RANURAS — fila Z X C V B:
    //   Z = swing fusionado (area + ventana de defensa/contra)
    //   X = cartas del tarot nuevas
    //   C = cambio de modo (area <-> dash), bind directo sm_amymodo
    //   V = habilidad 3: lanzamiento de martillo (sm_sjs_ability3)
    //   B = habilidad 4: ALTERNA MODO DEL MARTILLO bumeran <-> comun
    //       (v3.77.60 — antes eran las cartas del super tank: esas
    //       siguen en consola sm_amysupertank)
    // (v3.77.30: los binds c/v/b los pone la fila COMPLETA de arriba —
    // lo que sigue es solo la explicacion)
    if (charIdx == AMY_INDEX)
    {
        PrintToChat(client, "[Amy OM] Z = GOLPE EN AREA + DEFENSA (el que te toque en %.1fs queda aturdido sin ragdoll) | C = alterna AREA <-> DASH | V = LANZAR MARTILLO (2 veces: arma y lanza) | B = ALTERNA MODO DEL MARTILLO: BUMERAN <-> COMUN", 2.0);
        PrintToChat(client, "[Amy OM] X = CARTAS DEL TAROT (2 de 6 — la X en cooldown te re-muestra la mano y sus efectos exactos) | BUMERAN: gira de verdad, alcance %.0fu, dano tipo CORTE, golpea en ida y vuelta | COMUN: tiro recto clasico | Cartas del super tank: sm_amysupertank | Reducciones del equipo: sm_defensas", 2325.0);
    }

    // v3.71 (OM-TAILS R2): la 3a de Tails = CAMBIO DE MODO DEL CAÑÓN
    if (charIdx == TAILS_INDEX)
    {
        PrintToChat(client, "[Tails] C (habilidad 3) = CAMBIAR EL MODO DEL CAÑÓN: Laser -> Burst -> Orbs -> Shockwave. Sin cooldown (tambien: sm_tailscannon). El disparo sigue en la Z.");
    }

    // v3.60 (R26): Sage tiene 3 slots — la C es el CAMBIO DE SET y se
    // anuncia el set activo (la Z y la X dependen de el)
    if (charIdx == SAGE_INDEX)
    {
        PrintToChat(client, "[Sage] C = CAMBIAR DE SET (tambien: sm_sageset). Slot 4 reservado para tu modo propio.");
        Sage_AnnounceSet(client);
    }

    // v3.77.30 (Knuckles v65-OM): anuncio de la 3a + el avatar nuevo
    if (charIdx == KNUCKLES_INDEX)
    {
        PrintToChat(client, "[Knuckles] C (habilidad 3) = METEOR STRIKE: en el AIRE te elevas, apuntas y con la 2a pulsacion de C te lanzas en picada con MEGA EXPLOSION; EN TIERRA lanzas la ESFERA DE FUEGO. Z = carga del puno (suelta con CLICK, [R] cancela). X = POSTURA DEFENSIVA (contra). En el aire planeas y te agarras de las paredes (salto para soltarte).");
        PrintToChat(client, "[Knuckles OM] Avatar knuckles.mdl activo (knux_avatar 1): te ves como el Knuckles real, con planeo, agarre de pared, tintes de carga/bloqueo y ragdoll al morir.");
    }

    // v3.77.30: los de la C que no tenian anuncio propio
    if (charIdx == METALSONIC_INDEX)
        PrintToChat(client, "[Metal] C (habilidad 3) = V. MAXIMUM OVERDRIVE (aura electrica + velocidad; Espacio = levitar). Z = embestida | X = Self Repair.");
    if (charIdx == ROUGE_INDEX)
    {
        PrintToChat(client, "[Rouge v10.2] Z = BARRIDO en AREA (cd 6s, stun 2.5s apilable) | X = CONTRAGOLPE 6s (= al de Knuckles: tank, agarres, vomito, proyectiles) | C = BAT BOMB (cd 13s) | B = ONDA NEGRA (reintegrada).");
        PrintToChat(client, "[Rouge v10.2] VUELO: mantén SPACE para planear, tap = ALETEO SIN LÍMITE (solo depende de la ENERGÍA), SHIFT en el aire FRENA hasta quedarte quieta (FlyIdle; WASD = FlyRun), pared = agarrarse (SPACE = lanzarse). Vida 125 + reducción 20/35/50%% + evasión de agarres y vómitos.");
    }

    // v3.77.48: Shadow explica su kit + el air control nuevo
    if (charIdx == SHADOW_INDEX)
    {
        PrintToChat(client, "[Shadow] Z = CHAOS SNAP (teleport; golpea al especial en la trayectoria) | X = CHAOS BLAST (explosión devastadora) | bajo 50 HP = ANILLOS INHIBIDORES (daño -50%%, velocidad +30%%).");
        PrintToChat(client, "[Shadow] Movilidad: salto con IMPULSO hacia adelante + steering aéreo WASD; mantén SPACE en el aire = HOVER SHOES (caída lenta + deslizamiento con chispas).");
        if (g_bShadowModelOK && g_cvShadowAvatar != null && g_cvShadowAvatar.BoolValue)
            PrintToChat(client, "[Shadow] Avatar shadow.mdl activo (shadow_avatar 1): te ves como el Shadow real, con FSM de anims, tinte rojo en rage y ragdoll al morir.");
    }

    // v3.36: Eggman explica su pasiva nueva al elegirlo
    if (charIdx == EGGMAN_INDEX)
    {
        PrintToChat(client, "[Eggman] Pasiva EGGMOBILE JET: salta de nuevo en el aire para propulsarte. Inmune a caidas y acido.");
    }

    // v3.77.70: Blaze/Silver ya son SELECCIONABLES — su seleccion dispara
    // la señal CST (mismo frame) y el guard embebido aplica blaze.cfg /
    // silver.cfg EN EL ACTO: el modelo CST entra solo y con el el avatar
    // espejo se monta por deteccion de modelo (0.1-0.2s). CERO habilidades
    // activas: son personajes de modelo puro (por ahora).
    if (charIdx == BLAZE_INDEX || charIdx == SILVER_INDEX)
    {
        PrintToChat(client, "[%s] El guard aplica tu modelo \x05%s.cfg\x01 al instante y tu avatar espejo se monta solo (blaze.mdl / silver.mdl del VPK OM).", g_CharNames[charIdx], g_sCstCharKeys[charIdx]);
        PrintToChat(client, "[%s] \x04Z\x01 kick/sol dash + \x04X\x01 javelin/solflame (Blaze) | \x04Z\x01 suspension + \x04X\x01 rocas + \x04C\x01 rebobinado + \x04SPACE\x01 levitacion (Silver) — el kit del GMod. Dano de caida 0 con el avatar montado (Anti caida v3.3).", g_CharNames[charIdx]);
    }
}

bool GetClientSteamID(int client, char steam[32])
{
    if (!IsClientAuthorized(client)) return false;
    return GetClientAuthId(client, AuthId_Steam2, steam, sizeof(steam), true);
}

void CharIdxToKey(int idx, char key[8]) { IntToString(idx, key, sizeof(key)); }

bool GetCharOwnerSteam(int idx, char steam[32])
{
    char key[8]; CharIdxToKey(idx, key);
    return g_mCharOwner.GetString(key, steam, sizeof(steam));
}

void SetCharOwnerSteam(int idx, int client)
{
    char steam[32];
    if (!GetClientSteamID(client, steam)) return;
    char key[8]; CharIdxToKey(idx, key);
    g_mCharOwner.SetString(key, steam);
}

void RemoveCharOwner(int idx)
{
    char key[8]; CharIdxToKey(idx, key);
    g_mCharOwner.Remove(key);
}

void ClearAllCharOwners() 
{ 
    g_mCharOwner.Clear(); 
}

bool IsCharAvailableForClient(int idx, int client)
{
    // v3.77.79 — MODO SOLO: jugando solo no hay con quien competir por el
    // personaje (el archivo local de duenos no aplica sin SteamID)
    if (Sonic_IsSoloGame()) return true;
    if (g_iCharTakenBy[idx] != 0 && g_iCharTakenBy[idx] != client) return false;
    char ownerSteam[32], clientSteam[32];
    if (GetCharOwnerSteam(idx, ownerSteam)) {
        if (!GetClientSteamID(client, clientSteam)) return false;
        if (!StrEqual(ownerSteam, clientSteam)) return false;
    }
    return true;
}

void LoadOwnersFromFile()
{
    KeyValues kv = new KeyValues("SonicJumpOwners");
    if (!kv.ImportFromFile(g_sOwnersFile)) { delete kv; return; }
    
    ClearAllCharOwners();
    
    if (kv.GotoFirstSubKey(false)) {
        do {
            char key[8]; kv.GetSectionName(key, sizeof(key));
            char steam[32]; kv.GetString("steam64", steam, sizeof(steam), "");
            if (steam[0]) g_mCharOwner.SetString(key, steam);
        } while (kv.GotoNextKey(false));
    }
    delete kv;
}

void SaveOwnersToFile()
{
    KeyValues kv = new KeyValues("SonicJumpOwners");
    for (int i = 0; i < MAX_CHARS; i++) {
        char key[8], steam[32]; CharIdxToKey(i, key);
        if (g_mCharOwner.GetString(key, steam, sizeof(steam))) {
            kv.JumpToKey(key, true); kv.SetString("steam64", steam); kv.GoBack();
        }
    }
    kv.ExportToFile(g_sOwnersFile);
    delete kv;
}

bool IsClientAmyAllowed(int client) { return CheckCommandAccess(client, "sj_amy", ADMFLAG_GENERIC, true); }
bool IsClientSageAllowed(int client) { return CheckCommandAccess(client, "sj_sage", ADMFLAG_GENERIC, true); }   // v3.60 (R26)

void AssignCharacterToClient(int charIdx, int client) { if (!(0 <= charIdx < MAX_CHARS)) return; g_iCharTakenBy[charIdx] = client; }

// v3.77.53 — LA SENAL: publica (client, charIdx) a todos los oyentes.
// v3.77.54 — EL GUARD VIVE AQUI: primero se le avisa AL GUARD EMBEBIDO
// (misma llamada, MISMO FRAME — sin forward ni native de por medio; es el
// fin de la "vista gorda": el guard se entera de cada cambio de personaje
// en el instante exacto en que este manager lo comete) y despues se publica
// el forward global como siempre para cualquier otro oyente.
// v3.77.55 — LLAMADA DIRECTA (cstguard v3.0.2): CSTGuard_Signal ejecuta
// sm_<cfg disponible> EN EL ACTO, sin esperar probe ni watchdog. Pedido
// literal del owner: "cuando se seleccione un personaje se llamara
// directamente el sm_(cfg que tengamos disponible)".
void FireCharSignal(int client, int charIdx)
{
    // v3.77.54: señal directa al guard embebido. charIdx < 0 = "sin
    // personaje" (freechars / menu reset / Rebuild) -> el guard olvida la
    // identidad y deja de re-aplicar su cfg. Personaje valido -> registra
    // la identidad L0 (la autoridad) y v3.77.55 EJECUTA el comando del
    // personaje (sm_amy / sm_sonic / sm_rouge / ...) EN EL CONTEXTO del
    // jugador señalado, EN EL ACTO (seleccion o recuerdo, mismo frame;
    // si aun no esta in-game, la identidad queda registrada y la llamada
    // sale en su primer spawn).
    if (charIdx < 0 || charIdx >= MAX_CHARS)
        CSTGuard_Clear(client);
    else
        CSTGuard_Signal(client, g_sCstCharKeys[charIdx]);

    // v3.77.65 (= 3.77.59) — PATHSENSE en el MISMO FRAME: la pasiva
    // «Sentido de la Ruta» se activa AL INSTANTE al detectar el
    // personaje (pedido literal: "que se activara al instante se
    // detecte dicho personaje"). charIdx < 0 = sin personaje: evalúa
    // igual (podría tener concesión manual o ser admin) y el anuncio
    // de borde hace el resto.
    PathSense_OnCharSignal(client, charIdx);

    // AVATARHIDE en el MISMO FRAME: personaje con avatar-prop OM ->
    // equipo oculto YA (con periodo de gracia mientras la FSM monta el
    // prop); personaje CST / sin personaje -> equipo visible YA.
    AvatarHide_OnCharSignal(client, charIdx);

    if (g_fwdOnCharacterChanged == null) return;
    Call_StartForward(g_fwdOnCharacterChanged);
    Call_PushCell(client);
    Call_PushCell(charIdx);
    Call_Finish();
}

// v3.77.54 — el guard embebido pide re-anuncio (arranque tardio, inicio de
// ronda +6s, sm_cstsync): se re-dispara FireCharSignal para TODOS los
// personajes activos. Como FireCharSignal ya le habla directo al guard,
// ESTE barrido ES el re-anuncio (ademas re-publica el forward global).
public void CSTGuard_OnResyncRequested()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        int idx = g_iPlayerCharIdx[i];
        if (!(0 <= idx < MAX_CHARS)) continue;
        FireCharSignal(i, idx);
        count++;
    }
    LogMessage("[Sonic Manager] re-anuncio CST: %d personaje(s) re-señalado(s) al guard embebido", count);
}

void RebuildCharOccupancyFromPlayers()
{
    for (int client = 1; client <= MaxClients; client++) {
        if (!IsValidClient(client)) continue;
        int idx = g_iPlayerCharIdx[client];
        
        if (!(0 <= idx < MAX_CHARS) && AreClientCookiesCached(client)) {
            LoadPlayerCharChoice(client); idx = g_iPlayerCharIdx[client];
        }
        
        if (!(0 <= idx < MAX_CHARS)) continue;
        
        if (g_iCharTakenBy[idx] == client) continue; 

        if (IsCharAvailableForClient(idx, client)) {
            AssignCharacterToClient(idx, client); SetCharOwnerSteam(idx, client);
        } else {
            if (g_iCharTakenBy[idx] != 0 && IsClientInGame(g_iCharTakenBy[idx])) {
                g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX;
                FireCharSignal(client, INVALID_CHAR_INDEX);   // v3.77.53: se lo quitaron
            } else {
                AssignCharacterToClient(idx, client); SetCharOwnerSteam(idx, client);
            }
        }
    }
    SaveOwnersToFile();
}

public Action Cmd_OpenSoundMenu(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!IsValidClient(client)) return Plugin_Handled;
    ShowJumpSoundMenu(client);
    return Plugin_Handled;
}

void ShowJumpSoundMenu(int client)
{
    Menu menu = new Menu(MenuHandler_JumpSound);
    menu.SetTitle("Selecciona sonido de salto");
    char info[8], display[64];
    for (int i = 0; i < MAX_SOUNDS; i++) {
        IntToString(i, info, sizeof(info));
        Format(display, sizeof(display), "%s%s", g_SoundNames[i], (g_iPlayerSoundIdx[client] == i) ? " [Actual]" : "");
        menu.AddItem(info, display);
    }
    menu.AddItem("nosound", "Sin sonido");
    menu.ExitButton = true;
    menu.Display(client, 15);
}

public int MenuHandler_JumpSound(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) delete menu;
    else if (action == MenuAction_Select) {
        char info[16]; menu.GetItem(item, info, sizeof(info));
        if (StrEqual(info, "nosound")) {
            g_iPlayerSoundIdx[client] = INVALID_SOUND_INDEX;
            Sonic_SafeSetCookie(client, g_hSoundCookie, "");   // v3.77.79: a prueba de modo solo
            PrintToChat(client, "[SonicJump] Sonido desactivado.");
            ShowJumpSoundMenu(client); return 0;
        }
        int idx = StringToInt(info);
        g_iPlayerSoundIdx[client] = idx;
        char cookieVal[8]; IntToString(idx, cookieVal, sizeof(cookieVal));
        Sonic_SafeSetCookie(client, g_hSoundCookie, cookieVal);   // v3.77.79: a prueba de modo solo
        PrintToChat(client, "[SonicJump] Sonido: %s", g_SoundNames[idx]);
        if (g_iPlayerCharIdx[client] == INVALID_CHAR_INDEX) ShowCharMenu(client);
        else ShowJumpSoundMenu(client);
    }
    return 0;
}

public Action Cmd_OpenCharMenu(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!IsValidClient(client)) return Plugin_Handled;
    ShowCharMenu(client);
    return Plugin_Handled;
}

void ShowCharMenu(int client)
{
    Menu menu = new Menu(MenuHandler_Char);
    menu.SetTitle("Selecciona tu personaje");
    char info[8], display[96];
    char ownerSteam[32], clientSteam[32]; GetClientSteamID(client, clientSteam);

    for (int i = 0; i < MAX_CHARS; i++) {
        IntToString(i, info, sizeof(info));
        bool amy = (i == AMY_INDEX), allowedAmy = IsClientAmyAllowed(client);
        bool sage = (i == SAGE_INDEX), allowedSage = IsClientSageAllowed(client);   // v3.60 (R26)
        bool takenByOther = (g_iCharTakenBy[i] != 0 && g_iCharTakenBy[i] != client);
        bool ownedByOther = false;
        // v3.77.79 — MODO SOLO: sin SteamID que case (y sin mas jugadores)
        // el dueno registrado del archivo NO bloquea el menu local
        if (!Sonic_IsSoloGame() && GetCharOwnerSteam(i, ownerSteam)) {
            if (!clientSteam[0] || !StrEqual(ownerSteam, clientSteam)) ownedByOther = true;
        }
        bool disabled = takenByOther || ownedByOther || (amy && !allowedAmy) || (sage && !allowedSage);
        char status[48] = "";
        if (disabled) strcopy(status, sizeof(status), " (No disponible)");
        else if (g_iPlayerCharIdx[client] == i) strcopy(status, sizeof(status), " [Actual]");
        Format(display, sizeof(display), "%s%s", g_CharNames[i], status);
        menu.AddItem(info, display, disabled ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }
    menu.AddItem("nochar", "Sin personaje");
    menu.ExitButton = true;
    menu.Display(client, 20);
}

public int MenuHandler_Char(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) delete menu;
    else if (action == MenuAction_Select) {
        char info[16]; menu.GetItem(item, info, sizeof(info));
        if (StrEqual(info, "nochar")) {
            int prev = g_iPlayerCharIdx[client];
            if (0 <= prev < MAX_CHARS) {
                if (g_iCharTakenBy[prev] == client) g_iCharTakenBy[prev] = 0;
                char ownerSteam[32], clientSteam[32];
                if (GetCharOwnerSteam(prev, ownerSteam) && GetClientSteamID(client, clientSteam) && StrEqual(ownerSteam, clientSteam)) {
                    RemoveCharOwner(prev); SaveOwnersToFile();
                }
            }
            g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX;
            Sonic_SafeSetCookie(client, g_hCharCookie, "");   // v3.77.79: a prueba de modo solo
            FireCharSignal(client, INVALID_CHAR_INDEX);   // v3.77.53: senal de "sin personaje"
            PrintToChat(client, "[SonicJump] Personaje desactivado.");
            if (g_iPlayerSoundIdx[client] == INVALID_SOUND_INDEX) ShowJumpSoundMenu(client);
            else ShowCharMenu(client);
            return 0;
        }
        int idx = StringToInt(info);
        if (idx == AMY_INDEX && !IsClientAmyAllowed(client)) {
            PrintToChat(client, "[SonicJump] Amy es exclusiva."); ShowCharMenu(client); return 0;
        }
        // v3.60 (R26): "Sage es una clase exclusiva de ADM"
        if (idx == SAGE_INDEX && !IsClientSageAllowed(client)) {
            PrintToChat(client, "[SonicJump] Sage es exclusiva de administradores."); ShowCharMenu(client); return 0;
        }
        if (!IsCharAvailableForClient(idx, client)) {
            PrintToChat(client, "[SonicJump] %s no disponible.", g_CharNames[idx]); ShowCharMenu(client); return 0;
        }
        int prev = g_iPlayerCharIdx[client];
        if (0 <= prev < MAX_CHARS && g_iCharTakenBy[prev] == client) g_iCharTakenBy[prev] = 0;

        // v3.16 FIX: limpiar el estado del personaje ANTERIOR antes de asignar
        // el nuevo (antes no se hacia nada al cambiar de clase)
        CleanupCharModuleState(client, prev);

        AssignCharacterToClient(idx, client);
        g_iPlayerCharIdx[client] = idx;
        char cookie[8]; IntToString(idx, cookie, sizeof(cookie));
        Sonic_SafeSetCookie(client, g_hCharCookie, cookie);   // v3.77.79: a prueba de modo solo
        SetCharOwnerSteam(idx, client); SaveOwnersToFile();

        OnPlayerSelectCharacter(client);

        if (g_iPlayerSoundIdx[client] == INVALID_SOUND_INDEX) ShowJumpSoundMenu(client);
        else ShowCharMenu(client);
    }
    return 0;
}

public Action Cmd_FreeAllChars(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    ClearAllCharOwners(); SaveOwnersToFile();
    for (int i = 0; i < MAX_CHARS; i++) g_iCharTakenBy[i] = 0;
    for (int i = 1; i <= MaxClients; i++) {
        // v3.77.79 — el host de modo solo es fake: tambien queda libre
        if (!IsClientInGame(i) || (IsFakeClient(i) && !Sonic_IsSoloHost(i))) continue;
        g_iPlayerCharIdx[i] = INVALID_CHAR_INDEX;
        FireCharSignal(i, INVALID_CHAR_INDEX);   // v3.77.53: todos sin personaje
    }
    PrintToChatAll("[SonicJump] Personajes liberados.");
    return Plugin_Handled;
}

void LoadPlayerSoundChoice(int client)
{
    if (!IsValidClient(client)) return;
    char buf[8]; GetClientCookie(client, g_hSoundCookie, buf, sizeof(buf));
    if (!buf[0]) return;
    int idx = StringToInt(buf);
    g_iPlayerSoundIdx[client] = (0 <= idx < MAX_SOUNDS) ? idx : INVALID_SOUND_INDEX;
}

void LoadPlayerCharChoice(int client)
{
    if (!IsValidClient(client)) return;
    char buf[8]; GetClientCookie(client, g_hCharCookie, buf, sizeof(buf));
    if (!buf[0]) return;
    int idx = StringToInt(buf);
    if (!(0 <= idx < MAX_CHARS)) { g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX; return; }
    if (idx == AMY_INDEX && !IsClientAmyAllowed(client)) {
        g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX; SetClientCookie(client, g_hCharCookie, ""); return;
    }
    // v3.60 (R26): cookie de Sage sin admin -> reset silencioso
    if (idx == SAGE_INDEX && !IsClientSageAllowed(client)) {
        g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX; SetClientCookie(client, g_hCharCookie, ""); return;
    }
    if (!IsCharAvailableForClient(idx, client)) {
        g_iPlayerCharIdx[client] = INVALID_CHAR_INDEX; return;
    }
    AssignCharacterToClient(idx, client);
    g_iPlayerCharIdx[client] = idx;
    SetCharOwnerSteam(idx, client); SaveOwnersToFile();

    // v3.77.53: cookie cargada = personaje confirmado. El cliente puede no
    // estar in-game todavia: el oyente se cuida solo (y el watchdog del CST
    // lo pesca al primer spawn de todos modos).
    FireCharSignal(client, idx);
}

void MaybePromptMenus(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] == INVALID_CHAR_INDEX) { ShowCharMenu(client); return; }
    if (g_iPlayerSoundIdx[client] == INVALID_SOUND_INDEX) { ShowJumpSoundMenu(client); return; }
}

public Action Cmd_ShowCharInfo(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    char steam[32]; GetClientSteamID(client, steam);
    PrintToChat(client, "[SonicJump] ID: %s | Snd: %d | Char: %d", steam, g_iPlayerSoundIdx[client], g_iPlayerCharIdx[client]);
    return Plugin_Handled;
}

public Action L4D_OnEntityKilled(int victim, int attacker, int inflictor)
{
    if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker)) {
        if (g_iPlayerCharIdx[attacker] == SONIC_INDEX) Sonic_OnKillInfected_Explosion(attacker, victim);
    }
    return Plugin_Continue;
}

public void CreateSonicRagdoll(int client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos); GetClientAbsAngles(client, ang); GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    char model[PLATFORM_MAX_PATH]; GetClientModel(client, model, sizeof(model));
    int ent = CreateEntityByName("prop_ragdoll");
    if (ent == -1) return;
    DispatchKeyValue(ent, "model", model); DispatchKeyValue(ent, "spawnflags", "4");
    DispatchSpawn(ent); TeleportEntity(ent, pos, ang, vel);
    SetEntityRenderColor(ent, 255, 255, 255, 255); SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
    SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
    SetVariantString("OnUser1 !self:kill::15.0:1"); AcceptEntityInput(ent, "AddOutput"); AcceptEntityInput(ent, "FireUser1");
}

int SafeGetEntDataEnt(int entity, int offset)
{
    if (offset == -1) return -1;
    return GetEntDataEnt2(entity, offset);
}