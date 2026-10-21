/**
 * [L4D2] Pet Christmas — Rework v2.0
 * Autor original: GsiX. Rework completo: SonicChars QoL Team.
 *
 * NOVEDADES v2.0:
 *  - Adquisicion por asesinato de especiales DESACTIVADA por defecto (cvar l4d2_pet_giftmode).
 *    El pet ahora se INVOCA desde el "Menu de Mejoras" (sm_pet / !pet) con un boton.
 *  - 3 modos de disparo: Metralleta / Escopeta / Flamegun.
 *  - 10 tipos de misil: Teledirigido, Tiro Recto, Lluvia (rain), Cluster, Napalm,
 *    Perforante, MOAB, Laser Guiado, Enjambre y Onda Expansiva.
 *  - IA mejorada: prioridad de objetivos, linea de vision real (LOS), retargeteo,
 *    disciplina de tiro (no explota cerca de supervivientes) y 3 comportamientos
 *    (Agresivo / Normal / Defensivo).
 *  - Sintaxis moderna, entity refs (sin indices corruptos), dano via SDKHooks_TakeDamage,
 *    beams en vez de entidades de tracer, edict guard y watchdogs en misiles.
 *  - Natives (l4d2pet.inc) para invocar el pet desde cualquier otro menu del servidor.
 *
 * FIX v2.1 (BUGFIRE - la nave no disparaba):
 *  - CAUSA RAIZ: el filtro de linea de vision tenia invertido el criterio de
 *    retorno del trace (true=hit/false=ignorar), de modo que la traza 'golpeaba'
 *    al propio F18 y 'atravesaba' a los infectados y al mundo: el pet creia que
 *    siempre habia un muro delante, soltaba el objetivo y nunca disparaba nada.
 *  - Misiles ya no se retienen cerca del equipo salvo explosiones gigantes
 *    (MOAB / Onda Expansiva), cuyo daño de area real nunca golpea al equipo.
 *  - La lluvia de misiles respeta el techo real (no nace dentro del muro).
 *  - Sonidos de disparo emitidos desde el F18 visible.
 *
 * MEJORAS v2.2 (PERSISTENCIA + IA + GRANADAS):
 *  - CONFIGURACION PERSISTENTE: arma, tipo de misil, IA, ruta y granadas se
 *    guardan solas (clientprefs) y se recargan al reconectar.
 *  - IA GENERAL: flanqueo anti-muros (si el objetivo se esconde detras de una
 *    pared, la nave maniobra para recuperar la linea de tiro en vez de quedarse
 *    mirandola), vision ampliada (900u por defecto y escanea tambien desde su
 *    propia posicion de vuelo) y avisos de TANK/WITCH.
 *  - RUTAS DE VUELO variadas en reposo: orbita, balanceo, patrulla o aleatoria.
 *  - Estilos de ataque mejorados: metralleta por rachas de 3 balas, escopeta de
 *    9 perdigones con dano directo reforzado, flamegun de triple chorro y fuego
 *    mas duradero, y deriva lateral de esquiva mientras dispara.
 *  - Misiles ALEATORIOS: nueva seleccion "Aleatorio" (cada salva elige uno de
 *    los 10 tipos al azar).
 *  - LANZAGRANADAS: la nave suelta granadas reales (molotov / casera / bilis)
 *    que al detonar aplican un EFECTO ALEATORIO estilo grenade.sp: cura, bola
 *    de fuego, congelante, cadena electrica, cegadora, agujero negro,
 *    antigravedad, vaporizador, cluster de fuego o metralla.
 *  - Interaccion: menu ampliado + comandos rapidos (!petweapon, !petmissile,
 *  !petia, !petroute, !petgrenade, !petstatus).
 *
 * MEJORAS v2.3 (MENU UNIFICADO + NIVELES + ARSENAL COMPLETO):
 *  - MENU UNICO (!pet): arsenal, misiles, IA, rutas, granadas, progreso,
 *    control de la nave y manual en un solo hub con submenus coherentes
 *    (todos los !pet* abren su submenu con boton "Volver").
 *  - SISTEMA DE NIVEL 1-100 PERSISTENTE (SQLite): la nave gana XP con sus
 *    bajas (comun 3, especial 20, tank 250, witch 120) y sus curas (2 c/u).
 *    Cada nivel sube dano (+1%), cadencia y vision; 16 hitos desbloquean
 *    armas, habilidades y bombardeos. Se guarda solo y sobrevive reinicios.
 *  - 7 ARMAS NUEVAS (total 10): Francotirador (Nv 5), Minigun (Nv 15),
 *    Laser (Nv 25), Arco Tesla (Nv 35), Canon de Plasma (Nv 45),
 *    Railgun perforante (Nv 60) y Cohetera multiple (Nv 80).
 *  - GRANADAS: los 20 efectos del grenade.sp completos (suma: cluster,
 *    fuegos artificiales, humo, escudo, acido quimico, extintor, brillo,
 *    flak antiaereo, bombardeo aereo y arma sorpresa). La granada MEDICA
 *    se lanza dirigida al aliado herido (desde Nv 3).
 *  - IA: prioridad absoluta al especial que tiene ATRAPADA a la duena
 *    (hunter / smoker / jockey / charger) aunque este fuera de rango;
 *    disciplina de vision (no persigue lo que ya no ve: vuelve al lado de
 *    la duena); vision 1200 + bonus por nivel; pulso defensivo (Nv 30).
 *  - CONTROL DE LA NAVE: !petattack (ataca lo que miras), !petstay /
 *    !petfollow (modo espera en una zona), !petrecall, granada manual al
 *    objetivo, !petairstrike (Nv 10) y !petomega (Nv 70).
 *
 * MEJORAS v2.4 (ARSENAL TOTAL + LENGUA DE SMOKER + MINAS):
 *  - 12 ARMAS NUEVAS (total 22): Cañón Criogénico (Nv 8), Lanzagranadas
 *    (Nv 12), Rifle Gauss (Nv 18), Cañón Solar (Nv 22), Cañón de Pulso
 *    (Nv 28), Arco Cruzado (Nv 33), Cañón Cluster (Nv 38), Cañón
 *    Fragmentación (Nv 50), Cañón de Vacío (Nv 55), Buscadores (Nv 65),
 *    Cañón Antimateria (Nv 85) y Cañón Estelar (Nv 100, el definitivo).
 *    El menu del arsenal las ordena por nivel y pagina solo (7 por pagina).
 *  - XP DE LOS COMUNES: ahora tambien cuentan los comunes que mata la
 *    duena con sus propias armas (no solo los derribados por la nave).
 *  - 5 EFECTOS NUEVOS DE GRANADA (total 25): Meteoritos (lluvia real de
 *    meteoros), Nova de Plasma, Enjambre Buscador, Nube Toxica y MINI-NUKE.
 *  - LENGUA DE SMOKER (pasiva): la nave engancha y arrastra hacia ella al
 *    infectado al que esta atacando. Probabilidad 10% en Nv 1, +2.5% por
 *    nivel, tope 40% (se alcanza en Nv 13). Al soltarlo: latigazo de dano.
 *  - MINAS DE PROXIMIDAD (pasiva, Nv 6): en combate la nave deja caer
 *    objetos que parecen minas; estallan a los segundos o cuando detectan
 *    zombies cercanos. Toggle persistente (!petmines / menu Control).
 *  - FIX: la sonda de techo de la Lluvia de misiles miraba hacia abajo
 *    (pitch invertido); ahora respeta el techo real en interiores.
 *
 * MEJORAS v2.5 (LENGUA DE SMOKER AUTENTICA — tecnica del l4d2_play_as_si):
 *  - La lengua ahora usa la PARTICULA REAL del juego (smoker_tongue) con
 *    punta voladora (info_particle_target + cpoint1), no un laser verde.
 *  - La lengua VUELA desde la boca del F18 hasta la presa a 1500 u/s
 *    antes de enganchar; si no llega, se retrae y reintenta pronto.
 *
 * MEJORAS v2.6 (FIX LENGUA: AGARRA DE VERDAD + SIEMPRE DESAPARECE):
 *  - FIX 1 (no agarraba): la lengua se disparaba contra CUALQUIER enemigo
 *    (casi siempre comunes, que no son agarrables) y el agarre del engine
 *    (GrabVictimWithTongue) nunca se confirma contra zombies. AHORA: la
 *    lengua SOLO se dispara contra infectados ESPECIALES (vivos, sin
 *    ghost, no tank, no montando a nadie). Si la nave pelea con la horda,
 *    busca ella sola el especial cercano para engancharlo.
 *  - FIX 2 (agarre real visible): AGARRE MANUAL GARANTIZADO — la presa
 *    queda colgada de la lengua (congelada), es ARRastrada hasta la boca
 *    del F18 y muerde: dano por tick cada 0.5 s + latigazo final al
 *    llegar a la nave. Ya no depende de que el engine confirme nada.
 *  - FIX 3 (lengua eterna): fx y punta llevan AUTODESTRUCCION garantizada
 *    a los 4 s (output OnUser1 !self:Kill del propio engine): aunque algo
 *    falle, la lengua JAMAS puede quedar dibujada para siempre.
 *  - La lengua se CORTA si pierde la linea de vista con la nave (muro);
 *    si otro especial se cruza en el vuelo, la lengua lo engancha a EL
 *    (comportamiento del juego real: el tongue agarra al primero que toca).
 *  - Mientras arrastra a su presa, la nave NO la ametralla (la castiga la
 *    lengua: ticks + latigazo); los misiles/granadas siguen igual.
 *  - Suelta SIEMPRE la presa: al llegar, timeout, muerte de la presa,
 *    lengua cortada, despido del pet, fin de ronda o descarga del plugin.
 *
 * FIX v2.7 (EL NIVEL VOLVIA A 1 EN CADA CAMBIO DE MAPA):
 *  - CAUSA RAIZ: el progreso solo se cargaba en OnClientAuthorized, que
 *    dispara UNA vez por conexion. En L4D2 cada cambio de mapa de campana
 *    desconecta y reconecta a las jugadoras, y esa reconexion rapida NO
 *    vuelve a disparar OnClientAuthorized: el nivel quedaba en 1 (lo
 *    resetea OnClientDisconnect) y, al no estar marcado como cargado,
 *    TODO guardado se saltaba: el progreso real se estancaba en la base.
 *  - AHORA el progreso se carga en TODA reconexion: OnClientPutInServer +
 *    OnClientAuthorized + OnClientPostAdminCheck como red de seguridad,
 *    con anti-duplicado y tolerancia a autorizacion tardia.
 *  - El XP, las bajas y las curas ganados antes de que llegue la carga ya
 *    NO se pierden: se acumulan aparte y se suman al completarse la carga.
 *  - El arma preferida de la cookie ya no se degrada por validarse contra
 *    el nivel 1: al cargar el nivel real se revalida la cookie original.
 *  - Respaldo del progreso mucho mas robusto: subida de nivel + fin de
 *    ronda + desconexion + fin de mapa + autoguardado cada 60 s + descarga
 *    del plugin. Un changelevel sin round_end ya no pierde nada.
 *  - OnClientAuthorized ya no depende del cvar de encendido: el progreso
 *    se carga siempre aunque el pet este apagado en ese momento.
 *
 * MEJORAS v2.8 (XP MAS GENEROSO + LENGUA QUE SE RETIRA SIEMPRE):
 *  - XP POR COMUNES SIEMPRE Y VISIBLE: ya no exige tener la nave invocada
 *    (basta con que exista tu progreso) y cada 12 comunes la nave anuncia
 *    en el chat el XP acumulado de la horda ("Horda digerida: +N XP").
 *  - IMPULSO DE XP HASTA NIVEL 50: x3 hasta Nv 9, x2 hasta Nv 24, x1.5
 *    hasta Nv 49; desde Nv 50 todo vuelve a la progresion normal.
 *  - XP DE CAPITULO: al cerrar la ronda, cada superviviente viva gana
 *    "REFUGIO ALCANZADO" (150 base) mas el PUNTAJE del capitulo del equipo
 *    (comunes x3 + especiales x60 + tanks x500 + witches x150, tope 2000,
 *    pagado a 1 XP por cada 10 puntos). En el rescate final (finale_win)
 *    son 300 base. Matar especiales/witch con la nave tambien anuncia su XP.
 *  - FIX LENGUA (residuo tras la muerte de la presa): el engine deja el
 *    filamento del smoker_tongue dibujado cuando la presa muere colgada
 *    (bug documentado por el propio l4d2_play_as_si). Ahora la lengua se
 *    retira COMPLETA en el instante de la muerte de la presa y la limpieza
 *    copia el patron exacto de la referencia: Stop + ClearParent + tele-
 *    transporte al vacio + kill retardado (el residuo, si el engine lo
 *    dejara, cae fuera del mapa).
 *  - Autoreparacion: las cargas de progreso atascadas se reintentan solas
 *    cada 60 s y un error de query ya no bloquea la carga del jugador.
 *
 * MEJORAS v2.9 (COMPATIBILIDAD CON EL MODO SUPERVIVENCIA):
 *  - El modo se detecta solo al cargar cada mapa (mp_gamemode): los mapas
 *    de escape jugados en SUPERVIVENCIA ya cuentan para todo el sistema.
 *  - EL TIEMPO SE TRANSFORMA EN XP: en supervivencia, cada minuto vivo
 *    paga 15 XP base +1 por minuto aguantado (tope 60 XP/min) a cada
 *    superviviente viva. La preparacion previa al reloj no cuenta (sin
 *    infectados abatidos no hay XP) y el cronometro se congela cuando
 *    ya no queda nadie vivo.
 *  - PREMIO FINAL DE SUPERVIVENCIA: al cerrar la ronda (escape completado
 *    o ultima caida) se pagan 100 XP + 10 por minuto (tope 1000) mas el
 *    puntaje del equipo del capitulo, sin exigir llegar viva. En campana
 *    y versus los premios siguen exactamente igual (refugio/rescate).
 *
 * MEJORAS v3.0 (NAVE MAS LETAL Y RAPIDA + CURA ESCALABLE):
 *  - DANO GENERAL por nivel: el multiplicador pasa de +1% a +0.35 por
 *    nivel (balas, misiles, granadas, minas, bombardeos): +35% en Nv 1,
 *    x4.5 en Nv 10, x18.5 en Nv 50 — compensa el poco dano contra los
 *    infectados especiales.
 *  - LENGUA DE SMOKER: probabilidad tope 40% -> 65% y dano propio
 *    (+0.30 por nivel, independiente del dano general de la nave).
 *    Sigue agarrando SOLO especiales (nunca comunes) y el XP de sus
 *    bajas sigue siendo solo de especiales.
 *  - VELOCIDAD: motor de la nave al doble de rapido (0.2 s -> 0.1 s:
 *    reaccion y adquisicion de objetivos x2), cadencia de tiro mas
 *    rapida (hasta -45%) y movimiento +40%.
 *  - VIDA DE LA NAVE: 300 s -> 680 s (migracion automatica del cfg viejo).
 *  - GRANADA MEDICA: cura 10 HP en Nv 1, +0.2 por nivel (tope 35) y el
 *    sonido de curacion suena SOLO al curar de verdad a un superviviente.
 *  - COMPATIBILIDAD TOTAL DE MODOS: coop, realism, survival, scavenge y
 *    VERSUS — la lengua y el combate valen contra especiales humanos (se
 *    avisa a la presa jugadora de quien la engancho).
 *
 * FIXES v3.1 (PARPADEO DEL AVION EN COMBATE + LENGUA 75%):
 *  - FIX: el avion ya no aparece/desaparece intermitentemente de su lugar al
 *    entrar en combate. Causa raiz (doble): (a) el F18 visible cuelga del
 *    cuerpo fisico invisible 3000 u abajo (parenting) y varias rutas de
 *    vuelo le daban PITCH al cuerpo (hasta 60 grados = ~2600 u de
 *    desplazamiento instantaneo del avion visible); (b) el snap de
 *    recuperacion (>=1000 u de la duena) teleportaba la nave en pleno ciclo
 *    soltar/re-enganchar objetivo del borde de rango, ahora a 10 Hz por el
 *    motor de 0.1 s. v3.1: el cuerpo JAMAS picha (solo yaw), el vuelco
 *    visual se aplica al MODELO en angulos locales (cero desplazamiento),
 *    correccion vertical real en combate, histeresis de 0.3 s anti
 *    flip-flop y el snap solo tras 1.5 s sin objetivo.
 *  - LENGUA DE SMOKER: tope de probabilidad subido de 65% a 75%.
 */

#define PLUGIN_VERSION  "3.1.0"
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

// v2.6: left4dhooks es OPCIONAL y SOLO informativo — el agarre de la
// lengua es MANUAL GARANTIZADO (congelar + arrastrar + latigazo), ya no
// depende del engine ni de left4dhooks (el engine nunca confirmaba el
// GrabVictimWithTongue contra zombies).
#undef REQUIRE_PLUGIN
#include <left4dhooks>
#define REQUIRE_PLUGIN

#define PLUGIN_FCVAR                    FCVAR_NOTIFY
#define PLUGINS_NAME                    "[L4D2] Pet Christmas Rework"

#define MDL_JETF18                      "models/f18/f18_sb.mdl"
#define DMY_MISSILE                     "models/w_models/weapons/w_eq_molotov.mdl"
#define MDL_MISSILE                     "models/missiles/f18_agm65maverick.mdl"
#define MDL_GIFT                        "models/items/l4d_gift.mdl"
#define SRT_EXPLOTION                   "sprites/flamelet1.vmt"
#define SRT_BEAM                        "sprites/laserbeam.vmt"
#define MDL_BLOOD                       "sprites/blood.vmt"
#define MDL_BLOODSPRAY                  "sprites/bloodspray.vmt"

#define SND_AIRSTRIKE1                  "npc/soldier1/misc05.wav"
#define SND_AIRSTRIKE2                  "npc/soldier1/misc06.wav"
#define SND_AIRSTRIKE3                  "npc/soldier1/misc10.wav"
#define SND_JETPASS                     "animation/jets/jet_by_01_lr.wav"
#define SND_GATLING                     "weapons/machinegun_m60/gunfire/machinegun_fire_1_incendiary.wav"
#define SND_MISSILE1                    "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_1.wav"
#define SND_MISSILE2                    "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_2.wav"
#define SND_REWARD                      "level/gnomeftw.wav"

#define CHAT_PREFIX                     "\x04[\x05PET\x04]\x05"

#define PET_INCR_HEIGHT                 15.0
#define PET_MINDISTANCE                 50.0
#define BODY_HEIGHT                     3000.0
#define MAX_EDICTS_SAFE                 1900      // edict guard para salvas
#define MISSILE_HARD_CAP                40        // misiles vivos simultaneos
#define FIRE_HARD_CAP                   14        // env_fires simultaneos
#define MISSILE_LIFE                    6.0       // watchdog de vuelo
#define BOMBLET_LIFE                    3.0
#define PET_FLANK_TIME                  5.0       // segs de maniobra de flanqueo contra muros
#define GRENADE_FUSE                    3.0       // mecha maxima de la granada del pet
#define GRENADE_HARD_CAP                6         // granadas vivas simultaneas

// v2.4: minas de proximidad (pasiva Nv 6)
#define MINE_HARD_CAP                  12        // minas vivas simultaneas (global)
#define MINE_LIFE                      10.0      // segundos hasta estallar sola
#define MINE_TRIPRADIUS                130.0     // radio de deteccion de zombies
#define MINE_DMG                       65.0      // dano de la explosion de la mina
#define MINE_DMG_RADIUS                200.0     // radio de dano de la mina
#define GRENADE_SPEED                   550.0     // velocidad de lanzamiento
#define MDL_PIPEBOMB                    "models/w_models/weapons/w_eq_pipebomb.mdl"
#define MDL_BILEFLASK                   "models/w_models/weapons/w_eq_bile_flask.mdl"
#define SND_GLASS                       "physics/glass/glass_impact_bullet4.wav"
#define SND_SMOKER_TONGUE              "smoker/voice/smoker_tongueattack1.wav"   // con fallback si no existe

// v2.9: XP por tiempo de supervivencia (modo survival, pedido del usuario)
#define PET_SURV_XP_BASE               15    // XP base por minuto sobrevivido
#define PET_SURV_XP_RAMP               45    // tope del incremento: +1 XP/min aguantado

// rutas de vuelo en reposo (menu / !petroute)
#define PETROUTE_ORBITA                 0
#define PETROUTE_BALANCEO               1
#define PETROUTE_PATRULLA               2
#define PETROUTE_ALEATORIA              3

// ---------------------------------------------------------------------------
// Estilos de misil (10 seleccionables + 1 interno para bomblets de cluster)
// ---------------------------------------------------------------------------
#define MSTYLE_TELE     0
#define MSTYLE_RECTO    1
#define MSTYLE_LLUVIA   2
#define MSTYLE_CLUSTER  3
#define MSTYLE_NAPALM   4
#define MSTYLE_PERF     5
#define MSTYLE_MOAB     6
#define MSTYLE_LASER    7
#define MSTYLE_ENJAMBRE 8
#define MSTYLE_ONDA     9
#define MSTYLE_BOMBLET  10
#define MSTYLE_PLASMA   13        // interno: orbe del canon de plasma
#define MSTYLE_ROCKET   14        // interno: cohete de la cohetera
#define MSTYLE_SEEKER   15        // interno: mini-misiles guiados (Buscadores Nv 65)
#define MSTYLE_METEOR   16        // interno: meteoritos de la granada fx Meteoritos
#define MSTYLE_COUNT    17

// armas de la nave (v2.3: 10 metodos de disparo)
#define WPN_SMG          0
#define WPN_SHOTGUN      1
#define WPN_FLAME        2
#define WPN_SNIPER       3
#define WPN_MINIGUN      4
#define WPN_LASER        5
#define WPN_TESLA        6
#define WPN_PLASMA       7
#define WPN_RAILGUN      8
#define WPN_COHETERA     9
// v2.4: 12 metodos de disparo nuevos (el arsenal llega a 22)
#define WPN_CRYO         10        // Cañón Criogénico (Nv 8)
#define WPN_GRANADERO    11        // Lanzagranadas (Nv 12)
#define WPN_GAUSS        12        // Rifle Gauss (Nv 18)
#define WPN_SOLAR        13        // Cañón Solar (Nv 22)
#define WPN_PULSO        14        // Cañón de Pulso (Nv 28)
#define WPN_ARC2         15        // Arco Cruzado (Nv 33)
#define WPN_CLUSTERMG    16        // Cañón Cluster (Nv 38)
#define WPN_FRAG         17        // Cañón Fragmentación (Nv 50)
#define WPN_VACIO        18        // Cañón de Vacío (Nv 55)
#define WPN_SEEKERS      19        // Buscadores (Nv 65)
#define WPN_ANTIMAT      20        // Cañón Antimateria (Nv 85)
#define WPN_ESTELAR      21        // Cañón Estelar (Nv 100)
#define WEAP_COUNT       22

// granadas: 25 efectos (los 20 del l4d_grenades + 5 nuevos v2.4)
#define GRENADE_FX_COUNT  25
#define GRENADE_FX_MEDIC  0

// sistema de nivel (SQLite persistente)
#define PET_MAXLEVEL      100
#define UNLOCK_COUNT      30
#define MSTYLE_RANDOM   12        // seleccion "Aleatorio": cada salva elige 0-9

enum struct MissileStyle
{
    char name[26];
    char desc[60];
    int count;          // misiles por salva
    float interval;     // segs entre misiles de la salva
    float speed;        // u/s
    float gravity;
    bool homing;
    float turn;         // 0..1 fuerza de guiado por tick
    float damage;
    float radius;
    float cooldown;
    int expScale;       // escala del sprite de explosion
    bool napalm;
    bool cluster;       // se divide en bomblets al acercarse
    bool laser;         // hitscan instantaneo (sin entidad)
    bool shockwave;     // onda expansiva: empuja sin apenas dano
    bool rain;          // aparece sobre el objetivo y cae
    bool tiny;          // modelo reducido
}

MissileStyle g_Styles[MSTYLE_COUNT];

// ---------------------------------------------------------------------------
// Estado por jugador (entity refs, nunca indices crudos)
// ---------------------------------------------------------------------------
int g_PetBody[MAXPLAYERS + 1] = {-1, ...};
int g_PetModel[MAXPLAYERS + 1] = {-1, ...};
int g_PetExhaust[MAXPLAYERS + 1] = {-1, ...};
int g_PetTarget[MAXPLAYERS + 1] = {-1, ...};
int g_PetMissile[MAXPLAYERS + 1] = {MSTYLE_TELE, ...};
int g_PetWeapon[MAXPLAYERS + 1] = {0, ...};      // 0=Metralleta 1=Escopeta 2=Flamegun
int g_PetAIMode[MAXPLAYERS + 1] = {1, ...};      // 0=Agresivo 1=Normal 2=Defensivo
float g_PetLife[MAXPLAYERS + 1];
bool g_PetFollow[MAXPLAYERS + 1];
bool g_PetDirection[MAXPLAYERS + 1];
float g_NextBulletAt[MAXPLAYERS + 1];
float g_NextMissileAt[MAXPLAYERS + 1];
float g_TargetSince[MAXPLAYERS + 1];
float g_LastShotAt[MAXPLAYERS + 1];              // para sonido de escopeta
bool g_PetGrenade[MAXPLAYERS + 1] = {true, ...};  // lanzagranadas on/off (persistente)
int g_PetRoute[MAXPLAYERS + 1] = {PETROUTE_ALEATORIA, ...};   // ruta de vuelo (persistente)
float g_NextGrenadeAt[MAXPLAYERS + 1];
float g_FlankUntil[MAXPLAYERS + 1];               // maniobra de flanqueo activa hasta...
int g_FlankDir[MAXPLAYERS + 1] = {1, ...};        // sentido de giro del flanqueo
float g_StrafeUntil[MAXPLAYERS + 1];              // deriva lateral de combate
int g_StrafeDir[MAXPLAYERS + 1] = {1, ...};
int g_GunBurstLeft[MAXPLAYERS + 1];               // racha de metralleta en curso
float g_RoutePhase[MAXPLAYERS + 1];               // fase orbital de la ruta
int g_RouteSide[MAXPLAYERS + 1] = {1, ...};       // lado de balanceo/patrulla
float g_RouteFlipUntil[MAXPLAYERS + 1];
int g_RouteCur[MAXPLAYERS + 1];                   // ruta activa cuando es aleatoria
float g_RouteNextSwap[MAXPLAYERS + 1];
int g_AnnouncedRef[MAXPLAYERS + 1] = {-1, ...};   // ultimo TANK/WITCH anunciado
float g_LastHadTarget[MAXPLAYERS + 1];             // v3.1: ultimo tick con objetivo (gate del snap)

// ---------------------------------------------------------------------------
// v2.4: lengua de smoker / minas / arma solar (estado por jugador)
// ---------------------------------------------------------------------------
int g_TongueRef[MAXPLAYERS + 1] = {-1, ...};
float g_TongueUntil[MAXPLAYERS + 1];
float g_NextTongueAt[MAXPLAYERS + 1];
float g_NextTongueRollAt[MAXPLAYERS + 1];
// v2.5: lengua autentica (particula real smoker_tongue del juego)
int g_TongueTipRef[MAXPLAYERS + 1] = {-1, ...};   // info_particle_target (punta)
int g_TongueFxRef[MAXPLAYERS + 1] = {-1, ...};    // info_particle_system (fx)
int g_TonguePhase[MAXPLAYERS + 1];                // 0 = vuelo, 1 = arrastre
float g_TongueFlightEnd[MAXPLAYERS + 1];          // techo de la fase de vuelo
// v2.6: agarre MANUAL GARANTIZADO (el engine no confirma el tongue contra
// zombies): la presa se congela, cuelga del tip y es arrastrada a la nave
bool g_TongueManualGrab[MAXPLAYERS + 1];          // presa congelada por la lengua
MoveType g_TongueSavedMoveType[MAXPLAYERS + 1];    // movetype original de la presa
float g_TongueNextTickAt[MAXPLAYERS + 1];         // proximo dano de arrastre
float g_TongueDamageDone[MAXPLAYERS + 1];         // dano acumulado del agarre
bool g_bL4DH;                                     // left4dhooks disponible
bool g_bTongueFx;                                 // particula smoker_tongue ok
bool g_PetMines[MAXPLAYERS + 1] = {true, ...};    // minas on/off (persistente)
float g_NextMineAt[MAXPLAYERS + 1];
int g_SolarTargetRef[MAXPLAYERS + 1] = {-1, ...};
int g_SolarStack[MAXPLAYERS + 1];

// ---------------------------------------------------------------------------
// v2.3: nivel / progreso SQLite / control de la nave
// ---------------------------------------------------------------------------
int g_PetLevel[MAXPLAYERS + 1] = {1, ...};
int g_PetXP[MAXPLAYERS + 1];
int g_PetKills[MAXPLAYERS + 1];
int g_PetHeals[MAXPLAYERS + 1];
bool g_PetLevelLoaded[MAXPLAYERS + 1];
char g_PetSteam[MAXPLAYERS + 1][64];
// v2.7: carga en toda reconexion + banco de lo ganado antes de la carga
bool g_PetLevelLoading[MAXPLAYERS + 1];   // query de carga en vuelo
int g_PetPendingXP[MAXPLAYERS + 1];       // XP ganado antes de cargar
int g_PetPendingKills[MAXPLAYERS + 1];    // bajas de la nave antes de cargar
int g_PetPendingHeals[MAXPLAYERS + 1];    // curas de la nave antes de cargar
// v2.8: feedback del XP de la horda + premios de fin de capitulo
int g_PetCommonsSinceMsg[MAXPLAYERS + 1];     // comunes desde el ultimo aviso
int g_PetCommonsXPSinceMsg[MAXPLAYERS + 1];   // XP acumulado desde el aviso
int g_ChapCommons, g_ChapSpecials, g_ChapTanks, g_ChapWitches;   // puntaje del capitulo
bool g_bFinaleAwarded;                         // evita doble premio al final

// v2.9: compatibilidad con el modo SUPERVIVENCIA (el usuario corre mapas
// de escape en survival): el tiempo sobrevivido se convierte en XP
ConVar g_hGameModeCvar;                      // mp_gamemode (cache del modo)
bool g_bSurvivalMode;                        // el mapa actual es supervivencia
int g_SurvMinutes;                           // minutos aguantados de la ronda
Handle g_hPetSurvXP;                         // cronometro de XP por minuto
bool g_PetMedic[MAXPLAYERS + 1] = {true, ...};
bool g_PetHold[MAXPLAYERS + 1];
float g_PetHoldPos[MAXPLAYERS + 1][3];
float g_NextPulseAt[MAXPLAYERS + 1];
float g_NextAirstrikeAt[MAXPLAYERS + 1];
float g_NextOmegaAt[MAXPLAYERS + 1];
int g_PetHitOwner[2048] = {-1, ...};   // atribucion de bajas para el XP
float g_PetHitTime[2048];

int g_UnlockLevels[UNLOCK_COUNT] = {1, 3, 5, 6, 8, 10, 12, 15, 18, 20, 22, 25, 28, 30, 33,
    35, 38, 40, 45, 50, 50, 55, 60, 65, 70, 80, 85, 90, 100, 100};
char g_UnlockNames[UNLOCK_COUNT][44] = {
    "Lengua de Smoker (chance crece +2.5%/nv)", "Granada medica a aliados heridos",
    "Arma: Francotirador", "Minas de proximidad (pasiva)", "Arma: Cañón Criogénico",
    "Bombardeo aereo (!petairstrike)", "Arma: Lanzagranadas", "Arma: Minigun",
    "Arma: Rifle Gauss", "Radar ampliado (+150u vision)", "Arma: Cañón Solar",
    "Arma: Laser de combate", "Arma: Cañón de Pulso", "Pulso defensivo anti-horda",
    "Arma: Arco Cruzado", "Arma: Arco Tesla", "Arma: Cañón Cluster",
    "Granadas mas rapidas", "Arma: Cañón de Plasma", "Doble granada por tanda",
    "Arma: Cañón Fragmentación", "Arma: Cañón de Vacío", "Arma: Railgun perforante",
    "Arma: Buscadores multiples", "Bombardeo Omega (!petomega)", "Arma: Cohetera multiple",
    "Arma: Cañón Antimateria", "Torreta total (cadencia extrema)",
    "Arma: Cañón Estelar (el definitivo)", "MODO NAVIDAD TOTAL"};

Database g_hPetDB;
bool g_bPetDBOK;
Handle g_hPetAutosave;                     // v2.7: autoguardado periodico

// listas de efectos nuevos (humo / marca de brillo / acido)
ArrayList g_hSlowList;
float g_fSlowUntil;
Handle g_hSlowTimer;
ArrayList g_hMarkList;
float g_fMarkUntil;
Handle g_hMarkTimer;
float g_vAcidPos[3];
float g_fAcidUntil;
int g_iAcidOwner;
Handle g_hAcidTimer;

// ---------------------------------------------------------------------------
// Estado por misil (clave = index del cuerpo; se limpia al explotar)
// ---------------------------------------------------------------------------
int g_MissileStyle[2048] = {-1, ...};
int g_MissileTargetRef[2048] = {-1, ...};
int g_MissileModelRef[2048] = {-1, ...};
int g_MissileExhaustRef[2048] = {-1, ...};
float g_MissileLaunch[2048];
int g_iActiveMissiles;
int g_iActiveFires;

// estado por granada (clave = index de la entidad; se limpia al detonar)
int g_GrenadeOwner[2048] = {-1, ...};
int g_GrenadeFx[2048] = {-1, ...};   // -1 = aleatorio | 0..24 = forzado (medica)
float g_GrenadeLaunch[2048];
int g_iActiveGrenades;

// estado por mina (v2.4): clave = indice de la entidad
int g_MineOwner[2048] = {-1, ...};
float g_MineBoomAt[2048];
ArrayList g_hMineList;      // refs de minas vivas
Handle g_hMineTimer;
int g_iActiveMines;

// ---------------------------------------------------------------------------
// Globals / cvars
// ---------------------------------------------------------------------------
ConVar g_hPetEnable, g_hPetScan, g_hPetHeight, g_hPetLife, g_hGiftMode;
ConVar g_hChance, g_hGiftLife, g_hBulletDmg, g_hMissileCD;
ConVar g_hGrenadeOn, g_hGrenadeCD;

int g_enable;
bool g_bGiftMode;
float g_radius;
float g_petheight;
float g_petmaxlife;
bool g_bLifeMigrated;                        // v3.0: migracion unica 300 -> 680
float g_gifmaxlife;
int g_giftchance;
int g_bulletdmg;
float g_missilecdmul;
bool g_RoundEnd;
bool g_grenadesOn;
float g_grenadecd;

int g_sExplosion, g_sBeam, g_sBlood, g_sBloodSpray, g_sGlow;
bool g_bTongueSnd;   // el sonido de lengua precacheo bien?
int g_BloodColour[4] = {255, 15, 15, 255};

// objetivos ignorados temporalmente (perdidos por muro en medio)
int g_IgnoreTarget[MAXPLAYERS + 1] = {-1, ...};
float g_IgnoreUntil[MAXPLAYERS + 1];

// efectos de control de masas (congelar / flotar / agujero negro)
ArrayList g_hFreezeList;
float g_fFreezeUntil;
Handle g_hFreezeTimer;
ArrayList g_hFloatList;
float g_fFloatUntil;
Handle g_hFloatTimer;
ArrayList g_hPullList;
float g_fPullUntil;
Handle g_hPullTimer;
float g_vPullPos[3];
int g_iPullOwner;

// preferencias persistentes (clientprefs)
Cookie g_hCookWeapon, g_hCookMissile, g_hCookAI, g_hCookGrenade, g_hCookRoute, g_hCookMedic, g_hCookMines;

// punto de vista de escaneo del pet (amplia la vision)
float g_fScanPetPos[3];
float g_fScanEngage;

// globals temporales para el trace filter del LOS
int g_iTracePetBody, g_iTracePetModel, g_iTracePetExhaust;

public Plugin myinfo =
{
    name = PLUGINS_NAME,
    author = "GsiX (Rework v2.4)",
    description = "Pet bombardero invocable: 22 armas, misiles + aleatorio, 25 efectos de granada, minas, lengua de smoker, IA con prioridades, nivel 1-100 persistente",
    version = PLUGIN_VERSION,
    url = "n/a"
};

// ---------------------------------------------------------------------------
// Natives para otros plugins (menues externos)
// ---------------------------------------------------------------------------
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    CreateNative("L4D2Pet_Summon", Native_Summon);
    CreateNative("L4D2Pet_Dismiss", Native_Dismiss);
    CreateNative("L4D2Pet_IsActive", Native_IsActive);
    RegPluginLibrary("l4d2_pet_christmas");
    return APLRes_Success;
}

public any Native_Summon(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    if (!IsValidClient(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2 || g_enable == 0)
        return view_as<any>(false);
    return view_as<any>(CallPet(client));
}

public any Native_Dismiss(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    if (!IsValidClient(client) || !PetIsActive(client))
        return view_as<any>(false);
    TerminatePet(client, true);
    return view_as<any>(true);
}

public any Native_IsActive(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    if (!IsValidClient(client))
        return view_as<any>(false);
    return view_as<any>(PetIsActive(client));
}

// ---------------------------------------------------------------------------
// Plugin start
// ---------------------------------------------------------------------------
public void OnPluginStart()
{
    CreateConVar("l4d2_pet_version", PLUGIN_VERSION, "Plugin version", FCVAR_DONTRECORD);
    g_hPetEnable = CreateConVar("l4d2_pet_enabled", "1", "0:Off, 1:On. Activa o desactiva el plugin", PLUGIN_FCVAR);
    g_hPetScan   = CreateConVar("l4d2_pet_scan", "1200.0", "Radio maximo de escaneo/vision de enemigos (el nivel anade bonus)", PLUGIN_FCVAR);
    g_hPetHeight = CreateConVar("l4d2_pet_height", "60.0", "Altura del pet sobre el dueno", PLUGIN_FCVAR);
    g_hPetLife   = CreateConVar("l4d2_pet_petlife", "680.0", "Cuanto sigue el pet al dueno (segundos)", PLUGIN_FCVAR);
    g_hGiftMode  = CreateConVar("l4d2_pet_giftmode", "0", "0 (defecto): obtencion por kills DESACTIVADA, se invoca desde el menu. 1: los especiales sueltan regalo", PLUGIN_FCVAR);
    g_hChance    = CreateConVar("l4d2_pet_chance", "50", "Probabilidad (%) de que un especial suelte regalo (solo con giftmode 1)", PLUGIN_FCVAR);
    g_hGiftLife  = CreateConVar("l4d2_pet_giflife", "60.0", "Cuanto dura el regalo en el suelo (segundos)", PLUGIN_FCVAR);
    g_hBulletDmg = CreateConVar("l4d2_pet_bulletdamage", "10", "Dano por bala de metralleta", PLUGIN_FCVAR);
    g_hMissileCD = CreateConVar("l4d2_pet_missilecd", "1.0", "Multiplicador global de cooldowns de misil (menor = mas rapido)", PLUGIN_FCVAR);
    g_hGrenadeOn = CreateConVar("l4d2_pet_grenades", "1", "0/1: el pet lanza granadas de efectos aleatorios", PLUGIN_FCVAR);
    g_hGrenadeCD = CreateConVar("l4d2_pet_grenadecd", "12.0", "Segundos entre lanzamientos de granada (min 4)", PLUGIN_FCVAR);

    AutoExecConfig(true, "l4d2_pet_christmas");

    HookEvent("round_start",   EVENT_RoundStart);
    HookEvent("round_end",     EVENT_RoundEnd);
    HookEvent("player_death",  EVENT_PlayerDeath);
    HookEvent("player_spawn",  EVENT_PlayerSpawn);
    HookEvent("lunge_pounce",  EVENT_InfectedGrab);
    HookEvent("choke_start",   EVENT_InfectedGrab);
    HookEvent("jockey_ride",   EVENT_InfectedGrab);
    HookEvent("charger_pummel_start", EVENT_InfectedGrab);
    HookEvent("infected_death",  EVENT_InfectedDeath);
    HookEvent("witch_killed",    EVENT_WitchKilled);
    HookEvent("finale_win",      EVENT_FinaleWin);     // v2.8: XP del capitulo

    g_hPetEnable.AddChangeHook(OnCvarChanged);
    g_hPetScan.AddChangeHook(OnCvarChanged);
    g_hPetHeight.AddChangeHook(OnCvarChanged);
    g_hPetLife.AddChangeHook(OnCvarChanged);
    g_hGiftMode.AddChangeHook(OnCvarChanged);
    g_hChance.AddChangeHook(OnCvarChanged);
    g_hGiftLife.AddChangeHook(OnCvarChanged);
    g_hMissileCD.AddChangeHook(OnCvarChanged);
    g_hBulletDmg.AddChangeHook(OnCvarChanged);
    g_hGrenadeOn.AddChangeHook(OnCvarChanged);
    g_hGrenadeCD.AddChangeHook(OnCvarChanged);

    InitStyles();
    UpdateCvars();

    RegConsoleCmd("sm_pet", Cmd_PetMenu, "Menu unico del pet (invocar, arsenal, misiles, IA, rutas, granadas, progreso, control)");
    RegConsoleCmd("sm_petmenu", Cmd_PetMenu, "Alias del menu del pet");
    RegConsoleCmd("sm_petsummon", Cmd_PetSummon, "Invoca el pet directamente");
    RegConsoleCmd("sm_petdismiss", Cmd_PetDismiss, "Despide el pet directamente");
    RegConsoleCmd("sm_petweapon", Cmd_PetWeapon, "Arsenal del pet (menu unificado o !petweapon <id>)");
    RegConsoleCmd("sm_petmissile", Cmd_PetMissile, "Elige el tipo de misil (menu o !petmissile <0-9 | random>)");
    RegConsoleCmd("sm_petia", Cmd_PetAI, "Comportamiento de la IA (menu o !petia <0-2>)");
    RegConsoleCmd("sm_petroute", Cmd_PetRoute, "Ruta de vuelo (menu o !petroute <0-3>)");
    RegConsoleCmd("sm_petgrenade", Cmd_PetGrenade, "Activa/desactiva el lanzagranadas");
    RegConsoleCmd("sm_petmedic", Cmd_PetMedic, "Granada medica a aliados heridos on/off (Nv 3)");
    RegConsoleCmd("sm_petstatus", Cmd_PetStatus, "Muestra la configuracion y progreso del pet");
    RegConsoleCmd("sm_petattack", Cmd_PetAttack, "La nave ataca a lo que estas mirando");
    RegConsoleCmd("sm_petstay", Cmd_PetStay, "La nave se queda esperando en esta zona");
    RegConsoleCmd("sm_petfollow", Cmd_PetFollow, "La nave vuelve a seguirte");
    RegConsoleCmd("sm_petrecall", Cmd_PetRecall, "Teletransporta la nave a tu lado");
    RegConsoleCmd("sm_petlevel", Cmd_PetLevel, "Muestra tu nivel, XP y desbloqueos");
    RegConsoleCmd("sm_petairstrike", Cmd_PetAirstrike, "Bombardeo aereo donde miras (Nv 10)");
    RegConsoleCmd("sm_petomega", Cmd_PetOmega, "Bombardeo Omega donde miras (Nv 70)");
    RegConsoleCmd("sm_petmines", Cmd_PetMines, "Minas de proximidad on/off (Nv 6)");

    // preferencias persistentes del jugador (clientprefs)
    g_hCookWeapon  = RegClientCookie("l4d2_pet_weapon", "Arma preferida del pet", CookieAccess_Protected);
    g_hCookMissile = RegClientCookie("l4d2_pet_missile", "Tipo de misil preferido", CookieAccess_Protected);
    g_hCookAI      = RegClientCookie("l4d2_pet_ai", "Comportamiento IA preferido", CookieAccess_Protected);
    g_hCookGrenade = RegClientCookie("l4d2_pet_grenade", "Lanzagranadas on/off", CookieAccess_Protected);
    g_hCookRoute   = RegClientCookie("l4d2_pet_route", "Ruta de vuelo preferida", CookieAccess_Protected);
    g_hCookMedic   = RegClientCookie("l4d2_pet_medic", "Granada medica a aliados on/off", CookieAccess_Protected);
    g_hCookMines   = RegClientCookie("l4d2_pet_mines", "Minas de proximidad on/off", CookieAccess_Protected);

    InitPetDatabase();

    // v2.7: autoguardado del progreso cada 60 s (cubre caidas del servidor)
    g_hPetAutosave = CreateTimer(60.0, Timer_PetAutosave, _, TIMER_REPEAT);

    // v2.9: deteccion del modo de juego + cronometro de XP de supervivencia
    g_hGameModeCvar = FindConVar("mp_gamemode");
    PetRefreshGameMode();
    if (g_hGameModeCvar != null)
        g_hGameModeCvar.AddChangeHook(OnPetGameModeChanged);
    g_hPetSurvXP = CreateTimer(60.0, Timer_PetSurvivalXP, _, TIMER_REPEAT);

    // carga tardia: recoger prefs y progreso de quien ya este conectado
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || IsFakeClient(i)) continue;
        if (AreClientCookiesCached(i))
            LoadPetPrefs(i);
        if (g_bPetDBOK && g_PetSteam[i][0] == '\0')
        {
            char auth[64];
            if (GetClientAuthId(i, AuthId_Engine, auth, sizeof(auth)))
                PetDBLoad(i, auth);
        }
    }

    for (int i = 1; i <= MaxClients; i++)
        ResetClientState(i);

    PrintToServer("[%s] v%s cargado. Invoca el pet con !pet", PLUGINS_NAME, PLUGIN_VERSION);
}

// ---------------------------------------------------------------------------
// Tabla de estilos de misil
// ---------------------------------------------------------------------------
void StyleSet(int id, const char[] name, const char[] desc, int count, float interval, float speed,
              float gravity, bool homing, float turn, float damage, float radius, float cooldown,
              int expScale, bool napalm, bool cluster, bool laser, bool shockwave, bool rain, bool tiny)
{
    strcopy(g_Styles[id].name, sizeof(g_Styles[id].name), name);
    strcopy(g_Styles[id].desc, sizeof(g_Styles[id].desc), desc);
    g_Styles[id].count = count;
    g_Styles[id].interval = interval;
    g_Styles[id].speed = speed;
    g_Styles[id].gravity = gravity;
    g_Styles[id].homing = homing;
    g_Styles[id].turn = turn;
    g_Styles[id].damage = damage;
    g_Styles[id].radius = radius;
    g_Styles[id].cooldown = cooldown;
    g_Styles[id].expScale = expScale;
    g_Styles[id].napalm = napalm;
    g_Styles[id].cluster = cluster;
    g_Styles[id].laser = laser;
    g_Styles[id].shockwave = shockwave;
    g_Styles[id].rain = rain;
    g_Styles[id].tiny = tiny;
}

void InitStyles()
{
    //              id          nombre           desc                                        cnt  itvl  spd   grav  home turn  dmg   rad   cd    esc  nap  clu  las  sho  rai  tny
    StyleSet(MSTYLE_TELE,     "Teledirigido",  "misil que persigue al objetivo",             1, 0.10, 500.0, 0.01, true, 0.35, 80.0, 150.0, 3.0, 3, false, false, false, false, false, false);
    StyleSet(MSTYLE_RECTO,    "Tiro Recto",    "disparo directo veloz sin guiado",           1, 0.10, 1100.0, 0.00, false, 0.00, 100.0, 130.0, 2.0, 3, false, false, false, false, false, false);
    StyleSet(MSTYLE_LLUVIA,   "Lluvia",        "rain: 8 misiles caen sobre el objetivo",     8, 0.12, 450.0, 0.50, false, 0.00, 45.0, 100.0, 8.0, 2, false, false, false, false, true,  false);
    StyleSet(MSTYLE_CLUSTER,  "Cluster",       "se divide en 4 bombetas al acercarse",       1, 0.10, 600.0, 0.01, true, 0.25, 30.0, 120.0, 6.0, 2, false, true,  false, false, false, false);
    StyleSet(MSTYLE_NAPALM,   "Napalm",        "explosion que deja charco de fuego",         1, 0.10, 450.0, 0.01, true, 0.30, 50.0, 150.0, 7.0, 4, true,  false, false, false, false, false);
    StyleSet(MSTYLE_PERF,     "Perforante",    "velocisimo, dano masivo al directo",         1, 0.10, 1400.0, 0.00, false, 0.00, 300.0, 70.0, 5.0, 2, false, false, false, false, false, false);
    StyleSet(MSTYLE_MOAB,     "MOAB",          "bomba lenta de area gigante",                1, 0.10, 250.0, 0.05, false, 0.00, 200.0, 450.0, 15.0, 15, false, false, false, false, false, false);
    StyleSet(MSTYLE_LASER,    "Laser Guiado",  "rayo instantaneo de precision",              1, 0.10, 0.0,   0.00, false, 0.00, 120.0, 60.0, 4.0, 0, false, false, true,  false, false, false);
    StyleSet(MSTYLE_ENJAMBRE, "Enjambre",      "6 mini-misiles rapidos con guiado",          6, 0.07, 900.0, 0.00, true, 0.50, 15.0, 60.0, 6.0, 1, false, false, false, false, false, true);
    StyleSet(MSTYLE_ONDA,     "Onda Expansiva", "empuja y aturde sin apenas dano",           1, 0.10, 600.0, 0.01, true, 0.30, 5.0,  350.0, 9.0, 3, false, false, false, true,  false, false);
    StyleSet(MSTYLE_BOMBLET,  "Bombeta",       "(interno de cluster)",                       1, 0.00, 500.0, 0.40, false, 0.00, 40.0, 90.0, 0.0, 2, false, false, false, false, false, true);
    StyleSet(MSTYLE_PLASMA,   "Orbe Plasma",   "(interno del canon de plasma)",              1, 0.00, 800.0, 0.01, true, 0.30, 55.0, 120.0, 0.0, 3, false, false, false, false, false, true);
    StyleSet(MSTYLE_ROCKET,   "Cohete",        "(interno de la cohetera)",                   2, 0.18, 700.0, 0.00, true, 0.45, 35.0, 100.0, 0.0, 2, false, false, false, false, false, true);
    StyleSet(MSTYLE_SEEKER,   "Buscador",      "(interno: mini-misil guiado)",               3, 0.15, 620.0, 0.00, true, 0.50, 26.0, 85.0,  0.0, 1, false, false, false, false, false, true);
    StyleSet(MSTYLE_METEOR,   "Meteorito",     "(interno de la granada meteoros)",           1, 0.00, 900.0, 0.60, false, 0.00, 60.0, 180.0, 0.0, 5, false, false, false, false, false, false);
}

// ---------------------------------------------------------------------------
// Cvars
// ---------------------------------------------------------------------------
void OnCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    UpdateCvars();
}

void UpdateCvars()
{
    g_enable = g_hPetEnable.IntValue;
    g_bGiftMode = view_as<bool>(g_hGiftMode.BoolValue);
    g_radius = g_hPetScan.FloatValue;
    g_petheight = g_hPetHeight.FloatValue;
    g_giftchance = g_hChance.IntValue;
    g_petmaxlife = g_hPetLife.FloatValue;
    g_gifmaxlife = g_hGiftLife.FloatValue;
    g_bulletdmg = g_hBulletDmg.IntValue;
    g_missilecdmul = g_hMissileCD.FloatValue;
    if (g_missilecdmul < 0.2) g_missilecdmul = 0.2;
    else if (g_missilecdmul > 5.0) g_missilecdmul = 5.0;

    if (g_petmaxlife < 10.0) g_petmaxlife = 10.0;
    else if (g_petmaxlife > 1200.0) g_petmaxlife = 1200.0;   // v3.0: base 680 (mas margen)

    g_grenadesOn = view_as<bool>(g_hGrenadeOn.BoolValue);
    g_grenadecd = g_hGrenadeCD.FloatValue;
    if (g_grenadecd < 4.0) g_grenadecd = 4.0;
    else if (g_grenadecd > 60.0) g_grenadecd = 60.0;
}

// v3.0: el cfg viejo guarda todavia el 300.0 original — se migra solo al
// nuevo valor base 680 (una vez por sesion; para usar OTRO valor, ponlo en
// cfg/sourcemod/l4d2_pet_christmas.cfg distinto de 300)
public void OnConfigsExecuted()
{
    if (g_hPetLife != null && g_hPetLife.FloatValue == 300.0)
    {
        g_hPetLife.SetFloat(680.0);
        if (!g_bLifeMigrated)
        {
            g_bLifeMigrated = true;
            LogMessage("Vida base del pet migrada de 300 a 680 s (v3.0).");
        }
    }
}

// ---------------------------------------------------------------------------
// Mapa / cliente
// ---------------------------------------------------------------------------
public void OnMapStart()
{
    PrecacheModel(MDL_GIFT);
    PrecacheModel(MDL_JETF18);
    PrecacheModel(DMY_MISSILE);
    PrecacheModel(MDL_MISSILE);
    PrecacheSound(SND_AIRSTRIKE1, true);
    PrecacheSound(SND_AIRSTRIKE2, true);
    PrecacheSound(SND_AIRSTRIKE3, true);
    PrecacheSound(SND_MISSILE1, true);
    PrecacheSound(SND_MISSILE2, true);
    PrecacheSound(SND_JETPASS, true);
    PrecacheSound(SND_GATLING, true);
    PrecacheSound(SND_REWARD, true);
    g_sExplosion = PrecacheModel(SRT_EXPLOTION);
    g_sBeam = PrecacheModel(SRT_BEAM);
    g_sBlood = PrecacheModel(MDL_BLOOD);
    g_sBloodSpray = PrecacheModel(MDL_BLOODSPRAY);
    PrecacheModel(MDL_PIPEBOMB);
    PrecacheModel(MDL_BILEFLASK);
    PrecacheSound(SND_GLASS, true);
    // v2.4: glow rojo de las minas + sonido de lengua de smoker (con fallback)
    g_sGlow = PrecacheModel("sprites/glow01.vmt");
    g_bTongueSnd = PrecacheSound(SND_SMOKER_TONGUE, true);
    // v2.5: particula REAL de la lengua (tabla de strings del engine)
    g_bTongueFx = PetPrecacheParticle("smoker_tongue");
    // v2.6: log de carga — la lengua ya no depende de left4dhooks (agarre
    // manual garantizado), pero se informa de su presencia por consola
    LogMessage("v%s lista. Lengua de Smoker: particula=%s, agarre=MANUAL GARANTIZADO, left4dhooks=%s (solo informativo).",
        PLUGIN_VERSION, g_bTongueFx ? "OK" : "fallback", g_bL4DH ? "cargado" : "no cargado");

    // estado de minas del mapa anterior
    delete g_hMineList;
    g_hMineTimer = null;
    g_iActiveMines = 0;

    g_RoundEnd = false;
    // v2.8: contadores del capitulo (tambien para cargas tardias)
    g_ChapCommons = 0;
    g_ChapSpecials = 0;
    g_ChapTanks = 0;
    g_ChapWitches = 0;
    g_bFinaleAwarded = false;
    // v2.9: recargar el modo del mapa que entra + reiniciar el cronometro
    PetRefreshGameMode();
    g_SurvMinutes = 0;
    if (g_bSurvivalMode)
        LogMessage("Modo SUPERVIVENCIA detectado: cada minuto vivo paga XP (%d-%d) y el cierre de ronda premia el tiempo aguantado.",
            PET_SURV_XP_BASE, PET_SURV_XP_BASE + PET_SURV_XP_RAMP);
    g_iActiveMissiles = 0;
    g_iActiveFires = 0;
    for (int i = 1; i <= MaxClients; i++)
        ResetClientState(i);

    // limpia arrays de misiles/granadas de la partida anterior (indices reciclables)
    for (int e = 0; e < 2048; e++)
    {
        g_MissileStyle[e] = -1;
        g_MissileTargetRef[e] = -1;
        g_MissileModelRef[e] = -1;
        g_MissileExhaustRef[e] = -1;
        g_GrenadeOwner[e] = -1;
        g_GrenadeFx[e] = -1;
        g_PetHitOwner[e] = -1;
        g_MineOwner[e] = -1;
    }
    g_iActiveGrenades = 0;
    delete g_hFreezeList;
    delete g_hFloatList;
    delete g_hPullList;
    delete g_hSlowList;
    delete g_hMarkList;
    g_hFreezeTimer = null;
    g_hFloatTimer = null;
    g_hPullTimer = null;
    g_hSlowTimer = null;
    g_hMarkTimer = null;
    g_hAcidTimer = null;
}

// ---------------------------------------------------------------------------
// v2.6: left4dhooks es SOLO informativo (la lengua ya no depende de el:
// el agarre es manual garantizado) — se loguea al cargar el mapa
// ---------------------------------------------------------------------------
public void OnAllPluginsLoaded()
{
    UpdateL4DHStatus();
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "left4dhooks", false))
        UpdateL4DHStatus();
}

public void OnLibraryRemoved(const char[] name)
{
    if (StrEqual(name, "left4dhooks", false))
        UpdateL4DHStatus();
}

void UpdateL4DHStatus()
{
    g_bL4DH = LibraryExists("left4dhooks")
        && GetFeatureStatus(FeatureType_Native, "L4D_ForceSmokerVictim") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D_Smoker_ReleaseVictim") == FeatureStatus_Available;
}

public void OnMapEnd()
{
    // v2.7: respaldo del progreso antes de soltar el mapa (cubre tambien
    // los changelevel o cambios admin sin round_end previo)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_PetLevelLoaded[i])
            PetSaveProgress(i);
    }
    for (int i = 1; i <= MaxClients; i++)
        ResetClientState(i);
    g_iActiveMissiles = 0;
    g_iActiveFires = 0;
    delete g_hMineList;
    g_hMineTimer = null;
    g_iActiveMines = 0;
    for (int e = 0; e < 2048; e++)
    {
        g_MissileStyle[e] = -1;
        g_GrenadeOwner[e] = -1;
        g_GrenadeFx[e] = -1;
        g_PetHitOwner[e] = -1;
        g_MineOwner[e] = -1;
    }
    g_iActiveGrenades = 0;
    delete g_hFreezeList;
    delete g_hFloatList;
    delete g_hPullList;
    delete g_hSlowList;
    delete g_hMarkList;
    g_hFreezeTimer = null;
    g_hFloatTimer = null;
    g_hPullTimer = null;
    g_hSlowTimer = null;
    g_hMarkTimer = null;
    g_hAcidTimer = null;
}

public void OnClientDisconnect(int client)
{
    // v2.6: si la lengua de este jugador tenia a alguien colgado, soltarlo
    // ANTES de resetear el estado (si no, quedaria congelado para siempre)
    CleanupTongue(client);
    PetSaveProgress(client);
    ResetClientState(client);
    ResetPetPrefsDefaults(client);
    g_PetLevel[client] = 1;
    g_PetXP[client] = 0;
    g_PetKills[client] = 0;
    g_PetHeals[client] = 0;
    g_PetLevelLoaded[client] = false;
    g_PetLevelLoading[client] = false;
    g_PetPendingXP[client] = 0;
    g_PetPendingKills[client] = 0;
    g_PetPendingHeals[client] = 0;
    g_PetCommonsSinceMsg[client] = 0;
    g_PetCommonsXPSinceMsg[client] = 0;
    g_PetSteam[client][0] = '\0';
    g_PetMedic[client] = true;
    g_PetMines[client] = true;
}

void ResetClientState(int client)
{
    g_PetBody[client] = -1;
    g_PetModel[client] = -1;
    g_PetExhaust[client] = -1;
    g_PetTarget[client] = -1;
    g_PetLife[client] = 0.0;
    g_PetFollow[client] = false;
    g_PetDirection[client] = false;
    g_NextBulletAt[client] = 0.0;
    g_NextMissileAt[client] = 0.0;
    g_TargetSince[client] = 0.0;
    g_LastShotAt[client] = 0.0;
    // estado runtime nuevo (las preferencias se conservan: viven en cookies)
    g_FlankUntil[client] = 0.0;
    g_FlankDir[client] = 1;
    g_StrafeUntil[client] = 0.0;
    g_StrafeDir[client] = 1;
    g_GunBurstLeft[client] = 0;
    g_NextGrenadeAt[client] = 0.0;
    g_AnnouncedRef[client] = -1;
    g_PetHold[client] = false;
    g_NextPulseAt[client] = 0.0;
    g_NextAirstrikeAt[client] = 0.0;
    g_NextOmegaAt[client] = 0.0;
    // v2.4: lengua / minas / solar
    g_TongueRef[client] = -1;
    g_TongueUntil[client] = 0.0;
    g_NextTongueAt[client] = 0.0;
    g_NextTongueRollAt[client] = 0.0;
    // v2.5: lengua autentica (sin tocar entidades: los mapas las borran solos)
    g_TongueTipRef[client] = -1;
    g_TongueFxRef[client] = -1;
    g_TonguePhase[client] = 0;
    g_TongueFlightEnd[client] = 0.0;
    g_TongueManualGrab[client] = false;
    g_TongueSavedMoveType[client] = MOVETYPE_WALK;
    g_TongueNextTickAt[client] = 0.0;
    g_TongueDamageDone[client] = 0.0;
    g_NextMineAt[client] = 0.0;
    g_SolarTargetRef[client] = -1;
    g_SolarStack[client] = 0;
}

// ---------------------------------------------------------------------------
// Eventos
// ---------------------------------------------------------------------------
public void EVENT_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if (g_enable == 0) return;
    g_RoundEnd = false;
    // v2.8: contadores del capitulo (puntaje final por capitulo)
    g_ChapCommons = 0;
    g_ChapSpecials = 0;
    g_ChapTanks = 0;
    g_ChapWitches = 0;
    g_bFinaleAwarded = false;
    g_SurvMinutes = 0;   // v2.9: reinicio del cronometro de supervivencia
}

public void EVENT_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (g_enable == 0) return;
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client) && !IsFakeClient(client) && GetClientTeam(client) == 2)
    {
        // al reanimar/respawnear se limpia el pet viejo
        if (g_PetBody[client] != -1)
            TerminatePet(client, false);
        g_PetTarget[client] = -1;
    }
}

public void EVENT_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    if (g_enable == 0) return;
    g_RoundEnd = true;
    // v2.8: XP de fin de capitulo (refugio + puntaje) ANTES de guardar:
    // asi el bonus queda incluido en el respaldo de esta misma ronda
    if (!g_bFinaleAwarded)
        PetChapterAwards(false);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_PetBody[i] != -1)
            TerminatePet(i, false);
    }
    // respaldo del progreso de todos al cerrar la ronda
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_PetLevelLoaded[i])
            PetSaveProgress(i);
    }
    for (int e = 0; e < 2048; e++)
    {
        if (g_GrenadeOwner[e] != -1)
        {
            char gcls[32];
            if (e > 0 && IsValidEntity(e) && GetEntityClassname(e, gcls, sizeof(gcls))
                && StrEqual(gcls, "molotov_projectile"))
                AcceptEntityInput(e, "kill");
            g_GrenadeOwner[e] = -1;
        }
    }
    g_iActiveGrenades = 0;
    SweepAllMines();
}

public void EVENT_InfectedGrab(Event event, const char[] name, bool dontBroadcast)
{
    if (g_enable == 0) return;
    int victim = GetClientOfUserId(event.GetInt("victim"));
    int attacker = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(victim) && IsValidClient(attacker) && IsClientInGame(attacker))
    {
        // defensa de la duena: priorizar al especial que la agarro
        g_PetTarget[victim] = EntIndexToEntRef(attacker);
        g_TargetSince[victim] = GetGameTime();
        g_IgnoreTarget[victim] = -1;   // al que pinnea nunca se le ignora
        g_IgnoreUntil[victim] = 0.0;
    }
}

public void EVENT_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    if (g_enable == 0) return;
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    // ---- XP: baja de especial lograda por la nave (dano reciente) ---------
    if (victim > 0 && victim < 2048 && g_PetHitOwner[victim] > 0
        && IsValidClient(victim) && GetClientTeam(victim) == 3)
    {
        int owner = g_PetHitOwner[victim];
        if (owner != victim && IsValidClient(owner) && g_PetLevelLoaded[owner]
            && GetGameTime() - g_PetHitTime[victim] < 5.0)
        {
            PetCountKill(owner);
            int xp = 20;
            if (GetEntProp(victim, Prop_Send, "m_zombieClass") == 8)
                xp = 250;   // tank
            // v2.8: feedback visible del XP de la baja
            int granted = PetAddXP(owner, xp);
            char siName[16];
            PetSIName(victim, siName, sizeof(siName));
            if (granted > 0)
                PrintToChat(owner, "%s \x04+%d XP\x05 — \x04%s\x05 derribado por la nave.",
                    CHAT_PREFIX, granted, siName);
        }
        g_PetHitOwner[victim] = -1;
    }

    // v2.8: puntaje del capitulo — cualquier especial/tank abatido por el equipo
    if (IsValidClient(victim) && GetClientTeam(victim) == 3
        && IsValidClient(attacker) && GetClientTeam(attacker) == 2)
    {
        if (GetEntProp(victim, Prop_Send, "m_zombieClass") == 8) g_ChapTanks++;
        else g_ChapSpecials++;
    }

    // v2.8: si el especial que murio era la presa de una lengua activa,
    // retirar la lengua COMPLETA y AL INSTANTE (particula incluida). La
    // v2.6/v2.7 solo restauraban el movetype y dejaban que el timer
    // siguiera dibujando la lengua sobre el cadaver: el engine deja
    // residuo del smoker_tongue pegado a la presa muerta (bug que el
    // propio l4d2_play_as_si documenta: "when victim dead, the particle
    // effect will left in the world"). El timer de arrastre vera el ref
    // en -1 y se detendra solo en su siguiente tick.
    if (victim > 0 && victim <= MaxClients)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (g_TongueRef[i] == -1) continue;
            if (EntRefToEntIndex(g_TongueRef[i]) == victim)
            {
                ReleaseTongueVictim(i, victim);
                KillPetTongueEntities(i);
                g_TongueRef[i] = -1;
                g_TongueUntil[i] = 0.0;
                g_TonguePhase[i] = 0;
                break;
            }
        }
    }

    // regalo navideno (solo con giftmode 1)
    if (g_bGiftMode && IsValidClient(victim) && GetClientTeam(victim) == 3
        && IsValidClient(attacker) && GetClientTeam(attacker) == 2)
    {
        if (GetRandomInt(1, 100) <= g_giftchance)
            DropChristmasGift(victim);
    }
}

// XP: baja de comun causada por la nave... o por la duena (v2.4: los comunes
// que mata la jugadora con sus propias armas TAMBIEN cuentan para la nave;
// v2.8: no exige tener la nave invocada y el XP se anuncia en el chat)
public void EVENT_InfectedDeath(Event event, const char[] name, bool dontBroadcast)
{
    if (g_enable == 0) return;
    int victim = event.GetInt("victim");
    if (victim <= 0 || victim >= 2048) return;

    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    // v2.8: puntaje del capitulo — cualquier comun abatido por el equipo
    if (attacker > 0 && attacker != victim && IsValidClient(attacker) && GetClientTeam(attacker) == 2)
        g_ChapCommons++;

    int owner = 0;
    bool petKill = false;
    if (g_PetHitOwner[victim] > 0)
    {
        // derribado por el dano reciente de la nave (v2.8: basta con que el
        // progreso exista: la nave pudo despacharse justo tras lastimarlo)
        int petOwner = g_PetHitOwner[victim];
        if (IsValidClient(petOwner) && g_PetLevelLoaded[petOwner]
            && GetGameTime() - g_PetHitTime[victim] < 4.0)
        {
            owner = petOwner;
            petKill = true;
        }
    }
    if (owner == 0)
    {
        // v2.4/v2.8: los comunes abatidos por la duena alimentan el XP de la
        // nave aunque no la tenga invocada (basta con tener progreso)
        if (attacker > 0 && attacker != victim && IsValidClient(attacker) && g_PetLevelLoaded[attacker])
            owner = attacker;
    }

    if (owner > 0)
    {
        if (petKill) PetCountKill(owner);   // el contador de bajas es de la nave
        int granted = PetAddXP(owner, 3);

        // v2.8: feedback visible — cada 12 comunes se anuncia el XP de la
        // horda (antes el XP era silencioso y parecia que no llegaba)
        g_PetCommonsSinceMsg[owner]++;
        g_PetCommonsXPSinceMsg[owner] += granted;
        if (g_PetCommonsSinceMsg[owner] >= 12)
        {
            if (g_PetCommonsXPSinceMsg[owner] > 0 && IsValidClient(owner))
                PrintToChat(owner, "%s Horda digerida: \x04+%d XP\x05 (Nv %d — XP %d/%d).",
                    CHAT_PREFIX, g_PetCommonsXPSinceMsg[owner], g_PetLevel[owner],
                    g_PetXP[owner], PetXPToNext(g_PetLevel[owner]));
            g_PetCommonsSinceMsg[owner] = 0;
            g_PetCommonsXPSinceMsg[owner] = 0;
        }
    }
    g_PetHitOwner[victim] = -1;
}

// XP: baja de witch causada por la nave
public void EVENT_WitchKilled(Event event, const char[] name, bool dontBroadcast)
{
    if (g_enable == 0) return;
    g_ChapWitches++;   // v2.8: puntaje del capitulo
    int witch = event.GetInt("witchid");
    if (witch <= 0 || witch >= 2048 || g_PetHitOwner[witch] <= 0) return;

    int owner = g_PetHitOwner[witch];
    if (IsValidClient(owner) && g_PetLevelLoaded[owner] && GetGameTime() - g_PetHitTime[witch] < 5.0)
    {
        PetCountKill(owner);
        int granted = PetAddXP(owner, 120);
        if (granted > 0)
            PrintToChat(owner, "%s \x04+%d XP\x05 — \x04witch\x05 derribada por la nave.",
                CHAT_PREFIX, granted);
    }
    g_PetHitOwner[witch] = -1;
}

// v2.8: premios de fin de capitulo — XP por llegar al refugio (o completar
// el rescate) + el PUNTAJE del capitulo del equipo. En coop no hay marcador
// numerico, asi que el puntaje se computa con las bajas reales del capitulo
void PetChapterAwards(bool finale)
{
    g_bFinaleAwarded = true;

    int score = g_ChapCommons * 3 + g_ChapSpecials * 60 + g_ChapTanks * 500 + g_ChapWitches * 150;
    if (score > 2000) score = 2000;
    // v2.9: en supervivencia el premio final paga el TIEMPO aguantado (el
    // usuario corre los mapas de escape en survival: ahi no hay refugio)
    int bonus;
    if (g_bSurvivalMode)
    {
        bonus = 100 + g_SurvMinutes * 10;   // 100 base + 10 por minuto
        if (bonus > 1000) bonus = 1000;
        bonus += score / 10;
    }
    else
        bonus = (finale ? 300 : 150) + score / 10;

    char title[28];
    if (g_bSurvivalMode)
        strcopy(title, sizeof(title), "SUPERVIVENCIA TERMINADA");
    else if (finale)
        strcopy(title, sizeof(title), "RESCATE COMPLETADO");
    else
        strcopy(title, sizeof(title), "REFUGIO ALCANZADO");

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || IsFakeClient(i)) continue;
        if (GetClientTeam(i) != 2) continue;
        // campana: hay que llegar VIVA; v2.9 survival: la ronda la cierra la
        // ultima que cae (o el escape completado), tambien cuentan las caidas
        if (!g_bSurvivalMode && !IsPlayerAlive(i)) continue;
        if (!g_PetLevelLoaded[i]) continue;

        if (g_PetLevel[i] >= PET_MAXLEVEL)
        {
            PrintToChat(i, "%s %s — nivel maximo: sin bonus de XP.",
                CHAT_PREFIX, title);
            continue;
        }
        int granted = PetAddXP(i, bonus);
        PrintToChat(i, "%s \x04%s\x05: \x04+%d XP\x05 (puntaje del capitulo: \x04%d\x05).",
            CHAT_PREFIX, title, granted, score);
        if (g_bSurvivalMode)
            PrintToChat(i, "%s Tiempo aguantado: \x04%d min\x05. Equipo del capitulo: %d comunes, %d especiales, %d tanks, %d witches.",
                CHAT_PREFIX, g_SurvMinutes, g_ChapCommons, g_ChapSpecials, g_ChapTanks, g_ChapWitches);
        else
            PrintToChat(i, "%s Equipo del capitulo: %d comunes, %d especiales, %d tanks, %d witches.",
                CHAT_PREFIX, g_ChapCommons, g_ChapSpecials, g_ChapTanks, g_ChapWitches);
    }
}

// v2.8: el vehiculo de rescate se va — campana completada (bonus grande)
public void EVENT_FinaleWin(Event event, const char[] name, bool dontBroadcast)
{
    if (g_enable == 0) return;
    if (g_bFinaleAwarded) return;   // ya premiado: evita doble con round_end
    PetChapterAwards(true);
}

// ---------------------------------------------------------------------------
// v2.9: SUPERVIVENCIA — el tiempo se transforma en XP
// ---------------------------------------------------------------------------
void PetRefreshGameMode()
{
    g_bSurvivalMode = false;
    if (g_hGameModeCvar == null) g_hGameModeCvar = FindConVar("mp_gamemode");
    if (g_hGameModeCvar == null) return;   // fuera de L4D2 (no deberia pasar)
    char mode[24];
    g_hGameModeCvar.GetString(mode, sizeof(mode));
    if (StrContains(mode, "survival", false) == 0)
        g_bSurvivalMode = true;
}

// el modo puede cambiar sin recargar el plugin (voto o servidor)
public void OnPetGameModeChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    PetRefreshGameMode();
}

// v2.9: cada minuto de supervivencia paga XP a las supervivientes vivas.
// La preparacion previa al reloj no cuenta: sin infectados abatidos los
// contadores del capitulo siguen en 0 y el minuto no se paga. Con todas
// muertas (pantalla de resultados) el cronometro no avanza.
public Action Timer_PetSurvivalXP(Handle timer)
{
    if (g_enable == 0 || !g_bSurvivalMode || g_RoundEnd) return Plugin_Continue;
    if (g_ChapCommons + g_ChapSpecials + g_ChapTanks + g_ChapWitches <= 0) return Plugin_Continue;

    bool anyAlive = false;
    int extra = (g_SurvMinutes > PET_SURV_XP_RAMP) ? PET_SURV_XP_RAMP : g_SurvMinutes;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsFakeClient(i) || !IsClientInGame(i)) continue;
        if (GetClientTeam(i) != 2 || !IsPlayerAlive(i)) continue;
        anyAlive = true;
        if (!g_PetLevelLoaded[i]) continue;

        int granted = PetAddXP(i, PET_SURV_XP_BASE + extra);
        if (granted > 0)
            PrintToChat(i, "%s SUPERVIVENCIA (minuto \x04%d\x05): \x04+%d XP\x05 (Nv %d — XP %d/%d).",
                CHAT_PREFIX, g_SurvMinutes + 1, granted, g_PetLevel[i],
                g_PetXP[i], PetXPToNext(g_PetLevel[i]));
    }
    if (anyAlive) g_SurvMinutes++;
    return Plugin_Continue;
}

// ---------------------------------------------------------------------------
// MENU DE MEJORAS (invocacion, armas, misiles, IA)
// ---------------------------------------------------------------------------
char g_WeaponNames[WEAP_COUNT][26] = {"Metralleta", "Escopeta", "Flamegun", "Francotirador",
    "Minigun", "Laser", "Arco Tesla", "Plasma", "Railgun", "Cohetera",
    "Cañón Criogénico", "Lanzagranadas", "Rifle Gauss", "Cañón Solar", "Cañón de Pulso",
    "Arco Cruzado", "Cañón Cluster", "Cañón Fragmentación", "Cañón de Vacío", "Buscadores",
    "Cañón Antimateria", "Cañón Estelar"};
char g_WeaponDescs[WEAP_COUNT][52] = {"rachas de 3 balas", "cono anti-grupos", "triple chorro + charco",
    "tiro preciso y letal (criticos)", "chorro continuo infernal", "rayo continuo con area",
    "cadena electrica multiple", "orbes explosivos con area", "perfora todo lo alineado",
    "andanada de cohetes guiados",
    "congela y frena al objetivo", "proyectiles explosivos de area", "pesado con empujon devastador",
    "rayo que gana potencia al mantener", "onda de choque que despeja grupos",
    "doble haz electrico desde las alas", "mini-explosiones en cadena", "directo pesado + metralla radial",
    "implosion que agrupa y detona", "salva de mini-misiles guiados",
    "rayo devastador con area", "el definitivo: rayo + misiles + booms"};
int g_WeaponLevels[WEAP_COUNT] = {0, 0, 0, 5, 15, 25, 35, 45, 60, 80,
    8, 12, 18, 22, 28, 33, 38, 50, 55, 65, 85, 100};
// orden de presentacion del menu (por nivel de desbloqueo)
int g_WeaponOrder[WEAP_COUNT] = {0, 1, 2, 3, 10, 11, 4, 12, 13, 5, 14, 15, 6, 16, 7, 17, 18, 8, 19, 9, 20, 21};
char g_AINames[3][14] = {"Agresivo", "Normal", "Defensivo"};
char g_RouteNames[4][16] = {"Orbita", "Balanceo", "Patrulla", "Aleatoria"};
char g_GrenadeFxNames[GRENADE_FX_COUNT][26] = {"Medica (cura)", "Bola de fuego", "Cluster", "Fuegos artific.",
    "Humo cegador", "Agujero negro", "Cegadora", "Escudo", "Tesla (cadena)", "Quimica (acido)",
    "Congelante", "Vaporizador", "Extintor", "Brillo (marca)", "Antigravedad", "Cluster de fuego",
    "Balas (metralla)", "Flak antiaereo", "Bombardeo aereo", "Arma sorpresa",
    "Meteoritos", "Nova de plasma", "Enjambre buscador", "Nube toxica", "MINI-NUKE"};

// ---------------------------------------------------------------------------
// PREFERENCIAS PERSISTENTES (clientprefs): arma, misil, IA, ruta y granadas
// se guardan solas al cambiarlas y se recargan al reconectar
// ---------------------------------------------------------------------------
public void OnClientCookiesCached(int client)
{
    LoadPetPrefs(client);
}

void LoadPetPrefs(int client)
{
    if (!IsValidClient(client) || !IsClientInGame(client)) return;
    char buf[12];

    GetClientCookie(client, g_hCookWeapon, buf, sizeof(buf));
    if (buf[0] != '\0')
    {
        int v = StringToInt(buf);
        if (v < 0 || v >= WEAP_COUNT) v = 0;
        g_PetWeapon[client] = v;
        // si el nivel todavia no la desbloquea, se revalida al cargar el nivel
        if (v > 2 && g_PetLevel[client] < g_WeaponLevels[v])
            g_PetWeapon[client] = 0;
    }

    GetClientCookie(client, g_hCookMissile, buf, sizeof(buf));
    if (buf[0] != '\0')
    {
        int v = StringToInt(buf);
        if ((v >= 0 && v <= 9) || v == MSTYLE_RANDOM)
            g_PetMissile[client] = v;
    }

    GetClientCookie(client, g_hCookAI, buf, sizeof(buf));
    if (buf[0] != '\0')
    {
        int v = StringToInt(buf);
        if (v < 0 || v > 2) v = 1;
        g_PetAIMode[client] = v;
    }

    GetClientCookie(client, g_hCookGrenade, buf, sizeof(buf));
    if (buf[0] != '\0')
        g_PetGrenade[client] = (StringToInt(buf) != 0);

    GetClientCookie(client, g_hCookRoute, buf, sizeof(buf));
    if (buf[0] != '\0')
    {
        int v = StringToInt(buf);
        if (v < 0 || v > 3) v = 3;
        g_PetRoute[client] = v;
    }

    GetClientCookie(client, g_hCookMedic, buf, sizeof(buf));
    if (buf[0] != '\0')
        g_PetMedic[client] = (StringToInt(buf) != 0);

    GetClientCookie(client, g_hCookMines, buf, sizeof(buf));
    if (buf[0] != '\0')
        g_PetMines[client] = (StringToInt(buf) != 0);

    char styleName[26];
    PetStyleName(client, styleName, sizeof(styleName));
    PrintToChat(client, "%s Configuracion del pet cargada (\x04%s\x05 / \x04%s\x05 / IA \x04%s\x05).",
        CHAT_PREFIX, g_WeaponNames[g_PetWeapon[client]], styleName, g_AINames[g_PetAIMode[client]]);
}

void SavePetPrefs(int client)
{
    if (!IsValidClient(client) || !AreClientCookiesCached(client)) return;
    char buf[12];

    IntToString(g_PetWeapon[client], buf, sizeof(buf));
    SetClientCookie(client, g_hCookWeapon, buf);
    IntToString(g_PetMissile[client], buf, sizeof(buf));
    SetClientCookie(client, g_hCookMissile, buf);
    IntToString(g_PetAIMode[client], buf, sizeof(buf));
    SetClientCookie(client, g_hCookAI, buf);
    IntToString(g_PetGrenade[client] ? 1 : 0, buf, sizeof(buf));
    SetClientCookie(client, g_hCookGrenade, buf);
    IntToString(g_PetRoute[client], buf, sizeof(buf));
    SetClientCookie(client, g_hCookRoute, buf);
    IntToString(g_PetMedic[client] ? 1 : 0, buf, sizeof(buf));
    SetClientCookie(client, g_hCookMedic, buf);
    IntToString(g_PetMines[client] ? 1 : 0, buf, sizeof(buf));
    SetClientCookie(client, g_hCookMines, buf);
}

void ResetPetPrefsDefaults(int client)
{
    g_PetWeapon[client] = 0;
    g_PetMissile[client] = MSTYLE_TELE;
    g_PetAIMode[client] = 1;
    g_PetGrenade[client] = true;
    g_PetRoute[client] = PETROUTE_ALEATORIA;
    g_PetMedic[client] = true;
    g_PetMines[client] = true;
}



// ===========================================================================
// SISTEMA DE NIVEL Y PROGRESO (v2.3): la nave gana XP con sus bajas y curas,
// sube de nivel (1-100) y el progreso se guarda solo en SQLite
// (addons/sourcemod/data/sqlite/pet_christmas.sq3)
// ===========================================================================
int PetXPToNext(int level)
{
    return 50 + level * 10;
}

float PetDamageMult(int client)
{
    // v3.0: dano general aumentado (pedido: +0.35 por nivel) para
    // compensar el poco dano contra infectados especiales
    if (g_PetLevel[client] < 1) return 1.0;
    float m = 1.0 + float(g_PetLevel[client]) * 0.35;
    if (g_PetLevel[client] >= PET_MAXLEVEL) m += 0.25;
    return m;
}

// v3.0: dano creciente de la LENGUA (pedido: +0.30 por nivel) —
// separado del dano general de la nave para que cada uno escale a su
// propio ritmo
float PetTongueMult(int client)
{
    if (g_PetLevel[client] < 1) return 1.0;
    return 1.0 + float(g_PetLevel[client]) * 0.30;
}

float PetGunMult(int client)
{
    // v3.0: las balas suben al mismo ritmo que el dano general (+0.35/nivel)
    return 1.0 + float(g_PetLevel[client]) * 0.35;
}

float PetCDMult(int client)
{
    float m = g_missilecdmul * (1.0 - float(g_PetLevel[client]) * 0.002);
    if (m < 0.5) m = 0.5;
    return m;
}

float PetGunIntervalMult(int client)
{
    // v3.0: velocidad de ATAQUE aumentada (cadencia mas rapida)
    if (g_PetLevel[client] >= 90) return 0.50;   // torreta total
    float m = 1.0 - float(g_PetLevel[client]) * 0.0035;
    if (m < 0.55) m = 0.55;
    return m;
}

float PetVisionRange(int client)
{
    float v = g_radius + float(g_PetLevel[client]) * 2.0;
    if (g_PetLevel[client] >= 20) v += 150.0;    // radar ampliado
    if (v > g_radius + 350.0) v = g_radius + 350.0;
    return v;
}

float PetGrenadeCD(int client)
{
    float cd = g_grenadecd;
    if (g_PetLevel[client] >= 40) cd *= 0.7;     // granadas mas rapidas
    return cd;
}

// v2.4: probabilidad de la lengua de smoker: 10% en Nv 1, +2.5% por nivel
// v3.0: tope subido de 40% a 65% (pedido del usuario)
// v3.1: tope subido de 65% a 75% (pedido del usuario)
float PetTongueChance(int client)
{
    float c = 10.0 + float(g_PetLevel[client] - 1) * 2.5;
    if (c > 75.0) c = 75.0;   // v3.1: tope 75% (pedido del usuario)
    if (c < 0.0) c = 0.0;
    return c;
}

// v3.0: cura de la granada medica (pedido): 10 HP en Nv 1, +0.2 por nivel,
// tope 35 HP
float PetHealAmount(int client)
{
    float h = 10.0 + float(g_PetLevel[client] - 1) * 0.2;
    if (h > 35.0) h = 35.0;
    return h;
}

bool PetWeaponUnlocked(int client, int wpn)
{
    if (wpn < 0 || wpn >= WEAP_COUNT) return false;
    return (g_PetLevel[client] >= g_WeaponLevels[wpn]);
}

void InitPetDatabase()
{
    char err[256];
    g_hPetDB = SQLite_UseDatabase("pet_christmas", err, sizeof(err));
    if (g_hPetDB == null)
    {
        g_bPetDBOK = false;
        LogError("[PET] No se pudo abrir la base SQLite (el progreso no sera persistente): %s", err);
        return;
    }
    if (!SQL_FastQuery(g_hPetDB, "CREATE TABLE IF NOT EXISTS pet_progress (steam TEXT PRIMARY KEY, name TEXT NOT NULL DEFAULT '', level INTEGER NOT NULL DEFAULT 1, xp INTEGER NOT NULL DEFAULT 0, kills INTEGER NOT NULL DEFAULT 0, heals INTEGER NOT NULL DEFAULT 0, updated INTEGER NOT NULL DEFAULT 0);"))
    {
        g_bPetDBOK = false;
        LogError("[PET] No se pudo crear la tabla pet_progress (el progreso no sera persistente).");
        return;
    }
    g_bPetDBOK = true;
}

public void OnClientAuthorized(int client, const char[] auth)
{
    // v2.7: sin puerta de g_enable: el progreso debe cargar SIEMPRE. Es una
    // de las 3 vias de carga (PutInServer / Authorized / PostAdminCheck)
    // para que las reconexiones de cambio de mapa no dejen el nivel en 1
    if (auth[0] == 'B' && StrContains(auth, "BOT") == 0) return;   // bots sin progreso
    if (g_PetLevelLoaded[client] || g_PetLevelLoading[client]) return;
    PetDBLoad(client, auth);
}

// v2.7: via principal de carga — dispara en TODA reconexion. En L4D2 los
// cambios de mapa de campana desconectan y reconectan a las jugadoras y la
// reconexion rapida NO vuelve a disparar OnClientAuthorized.
public void OnClientPutInServer(int client)
{
    if (IsFakeClient(client)) return;
    g_PetPendingXP[client] = 0;
    g_PetPendingKills[client] = 0;
    g_PetPendingHeals[client] = 0;
    TryLoadPetProgress(client);
}

// v2.7: red de seguridad — SourceMod garantiza este forward en toda
// conexion: si la autorizacion tardo o su forward no llego, se carga aqui
public void OnClientPostAdminCheck(int client)
{
    if (IsFakeClient(client)) return;
    TryLoadPetProgress(client);
}

// v2.7: intento de carga con anti-duplicado y tolerancia a autorizacion
// pendiente: si el SteamID aun no esta disponible, no pasa nada, la via de
// OnClientAuthorized completara la carga mas tarde
void TryLoadPetProgress(int client)
{
    if (!g_bPetDBOK || !IsValidClient(client) || IsFakeClient(client)) return;
    if (g_PetLevelLoaded[client] || g_PetLevelLoading[client]) return;

    char auth[64];
    if (g_PetSteam[client][0] != '\0')
        strcopy(auth, sizeof(auth), g_PetSteam[client]);
    else if (!GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth)))
        return;
    if (StrContains(auth, "STEAM_ID_PENDING") == 0) return;
    if (auth[0] == 'B' && StrContains(auth, "BOT") == 0) return;
    PetDBLoad(client, auth);
}

void PetDBLoad(int client, const char[] auth)
{
    if (!g_bPetDBOK || !IsValidClient(client)) return;
    g_PetLevelLoading[client] = true;   // v2.7: query en vuelo (anti-duplicado)
    strcopy(g_PetSteam[client], sizeof(g_PetSteam[]), auth);

    char q[256];
    Format(q, sizeof(q), "SELECT level, xp, kills, heals FROM pet_progress WHERE steam = '%s';", auth);
    SQL_TQuery(g_hPetDB, PetDB_LoadCallback, q, GetClientUserId(client));
}

public void PetDB_LoadCallback(Handle owner, Handle hndl, const char[] error, any data)
{
    if (hndl == null || error[0] != '\0')
    {
        LogError("[PET] Error SQL al cargar progreso: %s", error);
        // v2.8: liberar el flag de query en vuelo para que el reintento
        // periodico (autoguardado) pueda volver a intentar la carga
        int ec = GetClientOfUserId(view_as<int>(data));
        if (ec > 0 && ec <= MaxClients)
            g_PetLevelLoading[ec] = false;
        return;
    }
    int client = GetClientOfUserId(view_as<int>(data));
    if (client <= 0 || !IsClientInGame(client)) return;
    g_PetLevelLoading[client] = false;   // v2.7: la query ya no esta en vuelo

    DBResultSet rs = view_as<DBResultSet>(hndl);
    if (rs.FetchRow())
    {
        g_PetLevel[client] = rs.FetchInt(0);
        g_PetXP[client] = rs.FetchInt(1);
        g_PetKills[client] = rs.FetchInt(2);
        g_PetHeals[client] = rs.FetchInt(3);
        if (g_PetLevel[client] < 1) g_PetLevel[client] = 1;
        if (g_PetLevel[client] > PET_MAXLEVEL) g_PetLevel[client] = PET_MAXLEVEL;
    }
    else
    {
        g_PetLevel[client] = 1;
        g_PetXP[client] = 0;
    }
    g_PetLevelLoaded[client] = true;

    // v2.7: aplicar el progreso ganado ANTES de que llegara la carga: las
    // reconexiones rapidas dejaban un hueco donde ese XP se perdia
    if (g_PetPendingXP[client] > 0 || g_PetPendingKills[client] > 0 || g_PetPendingHeals[client] > 0)
    {
        g_PetXP[client] += g_PetPendingXP[client];
        g_PetKills[client] += g_PetPendingKills[client];
        g_PetHeals[client] += g_PetPendingHeals[client];
        g_PetPendingXP[client] = 0;
        g_PetPendingKills[client] = 0;
        g_PetPendingHeals[client] = 0;
        while (g_PetLevel[client] < PET_MAXLEVEL && g_PetXP[client] >= PetXPToNext(g_PetLevel[client]))
        {
            g_PetXP[client] -= PetXPToNext(g_PetLevel[client]);
            g_PetLevel[client]++;
        }
    }

    // v2.7: el arma de la cookie pudo degradarse al validarse contra nivel
    // 1 (las cookies se cachean antes que el progreso): revalidar la
    // cookie original contra el nivel real recien cargado
    char wbuf[12];
    GetClientCookie(client, g_hCookWeapon, wbuf, sizeof(wbuf));
    if (wbuf[0] != '\0')
    {
        int wv = StringToInt(wbuf);
        if (wv >= 0 && wv < WEAP_COUNT && PetWeaponUnlocked(client, wv))
            g_PetWeapon[client] = wv;
    }

    // el arma guardada puede seguir bloqueada por nivel: retrocede a la metralleta
    if (g_PetWeapon[client] > 2 && !PetWeaponUnlocked(client, g_PetWeapon[client]))
        g_PetWeapon[client] = 0;

    PrintToChat(client, "%s Progreso cargado: \x04NIVEL %d\x05 (XP %d/%d) | %d bajas y %d curas de la nave (SQLite).",
        CHAT_PREFIX, g_PetLevel[client], g_PetXP[client], PetXPToNext(g_PetLevel[client]), g_PetKills[client], g_PetHeals[client]);
}

void PetSaveProgress(int client)
{
    if (!g_bPetDBOK || !IsValidClient(client)) return;
    if (g_PetSteam[client][0] == '\0' || !g_PetLevelLoaded[client]) return;

    char name[MAX_NAME_LENGTH];
    GetClientName(client, name, sizeof(name));
    char escName[MAX_NAME_LENGTH * 2 + 16];
    g_hPetDB.Escape(name, escName, sizeof(escName));

    char q[512];
    Format(q, sizeof(q),
        "INSERT OR REPLACE INTO pet_progress (steam, name, level, xp, kills, heals, updated) VALUES ('%s', '%s', %d, %d, %d, %d, %d);",
        g_PetSteam[client], escName, g_PetLevel[client], g_PetXP[client], g_PetKills[client], g_PetHeals[client], GetTime());
    SQL_TQuery(g_hPetDB, PetDB_SaveCallback, q, 0);
}

public void PetDB_SaveCallback(Handle owner, Handle hndl, const char[] error, any data)
{
    if (error[0] != '\0')
        LogError("[PET] Error SQL al guardar progreso: %s", error);
}

// v2.7: contadores a prueba de carga tardia: si el progreso aun no llego
// de la base, van al banco en vez de perderse
void PetCountKill(int client)
{
    if (g_PetLevelLoaded[client]) g_PetKills[client]++;
    else g_PetPendingKills[client]++;
}

void PetCountHeal(int client, int amount)
{
    if (g_PetLevelLoaded[client]) g_PetHeals[client] += amount;
    else g_PetPendingHeals[client] += amount;
}

// v2.7: autoguardado periodico del progreso de todas las jugadoras humanas
// v2.8: tambien reintenta solo las cargas de progreso que quedaron atascadas
public Action Timer_PetAutosave(Handle timer)
{
    if (!g_bPetDBOK) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsFakeClient(i) || !IsClientInGame(i)) continue;
        if (g_PetLevelLoaded[i])
            PetSaveProgress(i);
        else if (!g_PetLevelLoading[i])
            TryLoadPetProgress(i);   // v2.8: autoreparacion de cargas atascadas
    }
    return Plugin_Continue;
}

// v2.8: impulso de XP en niveles bajos (pedido del usuario): llegar al
// Nv 50 se siente rapido; desde ahi la progresion vuelve a ser la normal
float PetXPBoost(int client)
{
    int lv = g_PetLevel[client];
    if (lv >= 50) return 1.0;
    if (lv >= 25) return 1.5;
    if (lv >= 10) return 2.0;
    return 3.0;
}

// v2.8: devuelve el XP realmente otorgado (con impulso ya aplicado) para
// que los eventos puedan anunciarlo en el chat; 0 si no se otorgo nada
int PetAddXP(int client, int amount)
{
    if (!IsValidClient(client) || amount <= 0 || g_PetLevel[client] >= PET_MAXLEVEL) return 0;
    // v2.8: el impulso de niveles bajos se aplica antes de todo (tambien al
    // banco de pendientes, para que no se pierda nada)
    amount = RoundToCeil(float(amount) * PetXPBoost(client));
    // v2.7: progreso sin cargar todavia: acumular en el banco y aplicar al
    // completarse la carga; antes se perdia al sobreescribir el load
    if (!g_PetLevelLoaded[client])
    {
        g_PetPendingXP[client] += amount;
        return amount;
    }
    int before = g_PetLevel[client];
    g_PetXP[client] += amount;

    while (g_PetLevel[client] < PET_MAXLEVEL && g_PetXP[client] >= PetXPToNext(g_PetLevel[client]))
    {
        g_PetXP[client] -= PetXPToNext(g_PetLevel[client]);
        g_PetLevel[client]++;
    }

    if (g_PetLevel[client] != before)
    {
        EmitSoundToClient(client, SND_REWARD);
        if (g_PetLevel[client] >= PET_MAXLEVEL)
        {
            PrintToChat(client, "%s \x04NIVEL MAXIMO (100)!\x05 MODO NAVIDAD TOTAL. La nave es leyenda.", CHAT_PREFIX);
            PrintToChat(client, "%s Dano +%.0f%% | cadencia extrema | vision al maximo. Feliz Navidad, capitan.",
                CHAT_PREFIX, (PetDamageMult(client) - 1.0) * 100.0);
        }
        else
        {
            PrintToChat(client, "%s La nave subio a \x04NIVEL %d\x05 (dano +%.0f%%, vision +%.0f u). XP: %d/%d",
                CHAT_PREFIX, g_PetLevel[client], (PetDamageMult(client) - 1.0) * 100.0,
                PetVisionRange(client) - g_radius, g_PetXP[client], PetXPToNext(g_PetLevel[client]));
        }
        NotifyNewUnlocks(client, before, g_PetLevel[client]);
        PetSaveProgress(client);
    }
    return amount;
}

void NotifyNewUnlocks(int client, int before, int after)
{
    for (int u = 0; u < UNLOCK_COUNT; u++)
    {
        if (g_UnlockLevels[u] > before && g_UnlockLevels[u] <= after)
            PrintToChat(client, "%s \x04DESBLOQUEADO (Nv %d):\x05 %s", CHAT_PREFIX, g_UnlockLevels[u], g_UnlockNames[u]);
    }
}

void NextUnlockText(int client, char[] out, int maxlen)
{
    for (int u = 0; u < UNLOCK_COUNT; u++)
    {
        if (g_UnlockLevels[u] > g_PetLevel[client])
        {
            Format(out, maxlen, "%s (Nv %d)", g_UnlockNames[u], g_UnlockLevels[u]);
            return;
        }
    }
    strcopy(out, maxlen, "todo desbloqueado");
}

// ---------------------------------------------------------------------------
// Prioridades de la IA: especiales que tienen ATRAPADA a la duena
// ---------------------------------------------------------------------------
int PetPinningVictim(int si)
{
    if (si < 1 || si > MaxClients || !IsClientInGame(si) || GetClientTeam(si) != 3) return -1;
    int victim = -1;
    switch (GetEntProp(si, Prop_Send, "m_zombieClass"))
    {
        case 3: victim = GetEntPropEnt(si, Prop_Send, "m_pounceVictim");     // hunter
        case 1: victim = GetEntPropEnt(si, Prop_Send, "m_tongueVictim");     // smoker
        case 5: victim = GetEntPropEnt(si, Prop_Send, "m_jockeyVictim");     // jockey
        case 6:
        {
            victim = GetEntPropEnt(si, Prop_Send, "m_pummelVictim");         // charger
            if (victim == -1)
                victim = GetEntPropEnt(si, Prop_Send, "m_carryVictim");
        }
    }
    if (victim > 0 && victim <= MaxClients && IsClientInGame(victim) && GetClientTeam(victim) == 2)
        return victim;
    return -1;
}

int GetOwnerPinner(int client)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 3) continue;
        if (PetPinningVictim(i) == client)
            return i;
    }
    return -1;
}

void PetSIName(int si, char[] out, int maxlen)
{
    switch (GetEntProp(si, Prop_Send, "m_zombieClass"))
    {
        case 1: strcopy(out, maxlen, "smoker");
        case 2: strcopy(out, maxlen, "boomer");
        case 3: strcopy(out, maxlen, "hunter");
        case 4: strcopy(out, maxlen, "spitter");
        case 5: strcopy(out, maxlen, "jockey");
        case 6: strcopy(out, maxlen, "charger");
        case 8: strcopy(out, maxlen, "tank");
        default: strcopy(out, maxlen, "especial");
    }
}

// ---------------------------------------------------------------------------
// Apoyo del motor: aliados heridos, LOS a aliados, pulso defensivo, espera
// ---------------------------------------------------------------------------
int FindHurtAlly(int client, float range)
{
    int body = EntRefToEntIndex(g_PetBody[client]);
    if (body == -1 || !IsValidEntity(body)) return -1;
    float pPos[3];
    GetEntPropVector(body, Prop_Send, "m_vecOrigin", pPos);
    pPos[2] -= BODY_HEIGHT;

    int best = -1;
    int bestDeficit = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2) continue;
        int hp = GetClientHealth(i);
        int maxhp = GetEntProp(i, Prop_Data, "m_iMaxHealth");
        if (maxhp <= 0) maxhp = 100;
        if (hp >= maxhp - maxhp / 4) continue;   // solo si le falta mas del 25%
        float vPos[3];
        GetEntPropVector(i, Prop_Send, "m_vecOrigin", vPos);
        if (GetVectorDistance(pPos, vPos) > range) continue;
        int deficit = maxhp - hp;
        if (deficit > bestDeficit) { bestDeficit = deficit; best = i; }
    }
    return best;
}

bool PetLOSAlly(int client, int body, int ally)
{
    float start[3], end[3];
    GetEntPropVector(body, Prop_Send, "m_vecOrigin", start);
    start[2] -= BODY_HEIGHT;
    GetEntPropVector(ally, Prop_Send, "m_vecOrigin", end);
    end[2] += 40.0;

    float dir[3], ang[3];
    MakeVectorFromPoints(start, end, dir);
    GetVectorAngles(dir, ang);

    g_iTracePetBody = body;
    g_iTracePetModel = EntRefToEntIndex(g_PetModel[client]);
    g_iTracePetExhaust = EntRefToEntIndex(g_PetExhaust[client]);

    Handle trace = TR_TraceRayFilterEx(start, ang, MASK_SHOT, RayType_Infinite, TraceFilter_PetLOS, 0);
    bool blocked = false;
    if (TR_DidHit(trace))
    {
        float hitPos[3];
        TR_GetEndPosition(hitPos, trace);
        if (GetVectorDistance(start, hitPos) < GetVectorDistance(start, end) - 25.0)
            blocked = true;   // hay muro o prop antes de llegar al aliado
    }
    CloseHandle(trace);
    return !blocked;
}

void PetDefensivePulse(int client, const float pos[3])
{
    int ring[4] = {255, 240, 120, 230};
    TE_SetupBeamRingPoint(pos, 20.0, 260.0, g_sBeam, g_sBeam, 0, 80, 0.6, 20.0, 0.0, ring, 190, 0);
    TE_SendToAll();
    TE_SetupBeamRingPoint(pos, 20.0, 260.0, g_sBeam, g_sBeam, 0, 80, 0.5, 14.0, 0.0, ring, 160, 0);
    TE_SendToAll();

    ArrayList list = new ArrayList();
    PetCommonsInRadius(pos, 240.0, list);
    for (int i = 0; i < list.Length; i++)
    {
        int ent = EntRefToEntIndex(list.Get(i));
        if (ent == -1 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
        float vPos[3], dir[3], push[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        MakeVectorFromPoints(pos, vPos, dir);
        NormalizeVector(dir, dir);
        dir[2] += 0.7;
        NormalizeVector(dir, dir);
        push[0] = dir[0] * 420.0;
        push[1] = dir[1] * 420.0;
        push[2] = dir[2] * 420.0;
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
        PetDamage(ent, client, 6.0, DMG_BLAST);
    }
    delete list;
    EmitSoundToAll(SND_AIRSTRIKE3, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    PrintToChat(client, "%s \x04Pulso defensivo\x05: la horda alrededor fue despejada.", CHAT_PREFIX);
}

void HoldPosition(int client)
{
    int body = EntRefToEntIndex(g_PetBody[client]);
    if (body == -1 || !IsValidEntity(body)) return;

    float petPos[3];
    GetEntPropVector(body, Prop_Send, "m_vecOrigin", petPos);
    petPos[2] -= BODY_HEIGHT;

    // orbita lenta alrededor del punto de espera
    g_RoutePhase[client] += 0.10;
    float wp[3];
    wp[0] = g_PetHoldPos[client][0] + Cosine(g_RoutePhase[client]) * 160.0;
    wp[1] = g_PetHoldPos[client][1] + Sine(g_RoutePhase[client]) * 160.0;
    wp[2] = g_PetHoldPos[client][2] + g_petheight;

    float dir[3], vel[3], ang[3];
    MakeVectorFromPoints(petPos, wp, dir);
    float dist = GetVectorLength(dir);
    NormalizeVector(dir, dir);

    float speed = (dist < 90.0) ? 50.0 : 170.0;
    vel[0] = dir[0] * speed;
    vel[1] = dir[1] * speed;
    vel[2] = 0.0;
    float visPitch = 0.0;   // v3.1: vuelco VISUAL del F18 (el cuerpo nunca picha)
    if (dir[2] > 0.15) { vel[2] = 90.0; visPitch = -12.0; }
    else if (dir[2] < -0.15) { vel[2] = -90.0; visPitch = 12.0; }

    GetVectorAngles(vel, ang);
    ang[0] = 0.0;   // v3.1: cuerpo sin pitch (fix del parpadeo)
    TeleportEntity(body, NULL_VECTOR, ang, vel);
    SetPetBank(client, visPitch);
}

// ---------------------------------------------------------------------------
// Apuntado del dueno + bombardeos
// ---------------------------------------------------------------------------
bool GetAimTargetOrPoint(int client, int &enemy, float pos[3])
{
    enemy = -1;
    float eye[3], ang[3];
    GetClientEyePosition(client, eye);
    GetClientEyeAngles(client, ang);

    Handle tr = TR_TraceRayFilterEx(eye, ang, MASK_SHOT, RayType_Infinite, TraceFilter_Aim, 0);
    bool hit = TR_DidHit(tr);
    if (hit)
    {
        enemy = TR_GetEntityIndex(tr);
        TR_GetEndPosition(pos, tr);
    }
    else
    {
        GetAngleVectors(ang, pos, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(pos, 800.0);
        AddVectors(eye, pos, pos);
    }
    CloseHandle(tr);
    return hit;
}

public bool TraceFilter_Aim(int entity, int contentsMask, any data)
{
    if (entity > 0 && entity <= MaxClients)
        return (GetClientTeam(entity) == 3);   // solo los especiales bloquean la mirada
    return true;   // comunes, witch, mundo y props bloquean
}

void DoAirstrikeAt(int owner, const float pos[3], int count, float dmg, float radius)
{
    for (int i = 0; i < count; i++)
    {
        DataPack pack = new DataPack();
        pack.WriteFloat(pos[0] + GetRandomFloat(-260.0, 260.0));
        pack.WriteFloat(pos[1] + GetRandomFloat(-260.0, 260.0));
        pack.WriteFloat(pos[2]);
        pack.WriteCell(owner);
        pack.WriteFloat(radius);
        pack.WriteFloat(dmg);
        CreateTimer(0.30 + 0.28 * float(i), Timer_AirstrikeBoom, pack, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Timer_AirstrikeBoom(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    float pos[3];
    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();
    int owner = pack.ReadCell();
    float radius = pack.ReadFloat();
    float dmg = pack.ReadFloat();
    delete pack;
    if (owner <= 0) return Plugin_Stop;

    TE_SetupExplosion(pos, g_sExplosion, 6.0, 1, 0, RoundToFloor(radius), RoundToFloor(dmg));
    TE_SendToAll();
    if (GetRandomInt(1, 2) == 1)
        EmitSoundToAll(SND_MISSILE1, 0, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE);
    else
        EmitSoundToAll(SND_MISSILE2, 0, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE);
    PetExplosionDamage(owner, pos, radius, dmg, false);
    return Plugin_Stop;
}

public Action Timer_SecondGrenade(Handle timer, any data)
{
    int client = GetClientOfUserId(view_as<int>(data));
    if (!IsValidClient(client) || !PetIsActive(client)) return Plugin_Stop;

    int body = EntRefToEntIndex(g_PetBody[client]);
    int targetIdx = (g_PetTarget[client] != -1) ? EntRefToEntIndex(g_PetTarget[client]) : -1;
    if (body == -1 || !IsValidEntity(body) || targetIdx == -1 || !IsValidEntity(targetIdx) || !IsEnemyAlive(targetIdx))
        return Plugin_Stop;
    if (GetEntityCount() > MAX_EDICTS_SAFE) return Plugin_Stop;

    float tPos[3];
    GetEntPropVector(targetIdx, Prop_Send, "m_vecOrigin", tPos);
    LaunchGrenade(client, body, targetIdx, tPos, -1);
    return Plugin_Stop;
}

// ---------------------------------------------------------------------------
// COMANDOS: menu unico + ordenes directas de control
// ---------------------------------------------------------------------------
public Action Cmd_PetMenu(int client, int args)
{
    if (g_enable == 0)
    {
        ReplyToCommand(client, "%s El sistema de pets esta desactivado (l4d2_pet_enabled 0).", CHAT_PREFIX);
        return Plugin_Handled;
    }
    if (!IsValidClient(client) || GetClientTeam(client) != 2)
    {
        ReplyToCommand(client, "%s Solo los supervivientes pueden usar el menu del pet.", CHAT_PREFIX);
        return Plugin_Handled;
    }
    ShowPetMenu(client);
    return Plugin_Handled;
}

public Action Cmd_PetSummon(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2 || !IsPlayerAlive(client))
        return Plugin_Handled;
    if (!CallPet(client))
        ReplyToCommand(client, "%s No se pudo invocar el pet.", CHAT_PREFIX);
    return Plugin_Handled;
}

public Action Cmd_PetDismiss(int client, int args)
{
    if (!IsValidClient(client) || !PetIsActive(client))
        return Plugin_Handled;
    TerminatePet(client, true);
    return Plugin_Handled;
}

public Action Cmd_PetWeapon(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    if (args > 0)
    {
        char arg[8];
        GetCmdArg(1, arg, sizeof(arg));
        int id = StringToInt(arg);
        if (id < 0 || id >= WEAP_COUNT || !PetWeaponUnlocked(client, id))
        {
            ReplyToCommand(client, "%s Esa arma no esta disponible aun (bloqueada por nivel o invalida).", CHAT_PREFIX);
            return Plugin_Handled;
        }
        g_PetWeapon[client] = id;
        SavePetPrefs(client);
        ReplyToCommand(client, "%s Modo de disparo: \x04%s\x05.", CHAT_PREFIX, g_WeaponNames[id]);
    }
    ShowWeaponMenu(client);
    return Plugin_Handled;
}

public Action Cmd_PetMissile(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    if (args > 0)
    {
        char arg[16];
        GetCmdArg(1, arg, sizeof(arg));
        if (StrEqual(arg, "random", false) || StrEqual(arg, "aleatorio", false))
        {
            g_PetMissile[client] = MSTYLE_RANDOM;
        }
        else
        {
            int id = StringToInt(arg);
            if (id < 0 || id > 9)
            {
                ReplyToCommand(client, "%s Uso: \x04!petmissile <0-9 | random>\x05 (sin argumento abre el menu).", CHAT_PREFIX);
                return Plugin_Handled;
            }
            g_PetMissile[client] = id;
        }
        SavePetPrefs(client);
        char nm[26];
        PetStyleName(client, nm, sizeof(nm));
        ReplyToCommand(client, "%s Sistema de misiles: \x04%s\x05.", CHAT_PREFIX, nm);
    }
    ShowMissileMenu(client);
    return Plugin_Handled;
}

public Action Cmd_PetAI(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    if (args > 0)
    {
        char arg[8];
        GetCmdArg(1, arg, sizeof(arg));
        int id = StringToInt(arg);
        if (id < 0 || id > 2)
        {
            ReplyToCommand(client, "%s Uso: \x04!petia <0-2>\x05 (0 agresivo, 1 normal, 2 defensivo).", CHAT_PREFIX);
            return Plugin_Handled;
        }
        g_PetAIMode[client] = id;
        SavePetPrefs(client);
        ReplyToCommand(client, "%s Comportamiento IA: \x04%s\x05.", CHAT_PREFIX, g_AINames[id]);
    }
    ShowAIMenu(client);
    return Plugin_Handled;
}

public Action Cmd_PetRoute(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    if (args > 0)
    {
        char arg[8];
        GetCmdArg(1, arg, sizeof(arg));
        int id = StringToInt(arg);
        if (id < 0 || id > 3)
        {
            ReplyToCommand(client, "%s Uso: \x04!petroute <0-3>\x05 (orbita, balanceo, patrulla, aleatoria).", CHAT_PREFIX);
            return Plugin_Handled;
        }
        g_PetRoute[client] = id;
        g_RouteNextSwap[client] = 0.0;
        SavePetPrefs(client);
        ReplyToCommand(client, "%s Ruta de vuelo (en reposo): \x04%s\x05.", CHAT_PREFIX, g_RouteNames[id]);
    }
    ShowRouteMenu(client);
    return Plugin_Handled;
}

public Action Cmd_PetGrenade(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    g_PetGrenade[client] = !g_PetGrenade[client];
    SavePetPrefs(client);
    ReplyToCommand(client, "%s Lanzagranadas \x04%s\x05: granadas reales con 25 efectos al azar (regla grenade.sp).",
        CHAT_PREFIX, g_PetGrenade[client] ? "ON" : "OFF");
    return Plugin_Handled;
}

public Action Cmd_PetMedic(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    if (g_PetLevel[client] < 3)
    {
        ReplyToCommand(client, "%s La granada medica a aliados se desbloquea en \x04Nivel 3\x05 (vas por el %d).",
            CHAT_PREFIX, g_PetLevel[client]);
        return Plugin_Handled;
    }
    g_PetMedic[client] = !g_PetMedic[client];
    SavePetPrefs(client);
    ReplyToCommand(client, "%s Granada medica a aliados heridos: \x04%s\x05.", CHAT_PREFIX, g_PetMedic[client] ? "ON" : "OFF");
    return Plugin_Handled;
}

public Action Cmd_PetMines(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    if (g_PetLevel[client] < 6)
    {
        ReplyToCommand(client, "%s Las minas de proximidad se desbloquean en \x04Nivel 6\x05 (vas por el %d).",
            CHAT_PREFIX, g_PetLevel[client]);
        return Plugin_Handled;
    }
    g_PetMines[client] = !g_PetMines[client];
    SavePetPrefs(client);
    ReplyToCommand(client, "%s Minas de proximidad: \x04%s\x05 (la nave deja minas al suelo en combate).",
        CHAT_PREFIX, g_PetMines[client] ? "ON" : "OFF");
    return Plugin_Handled;
}

public Action Cmd_PetStatus(int client, int args)
{
    if (!IsValidClient(client)) return Plugin_Handled;
    char nm[26];
    char next[64];
    PetStyleName(client, nm, sizeof(nm));
    NextUnlockText(client, next, sizeof(next));

    ReplyToCommand(client, "%s ==== ESTADO DEL PET v%s ====", CHAT_PREFIX, PLUGIN_VERSION);
    if (g_PetLevel[client] >= PET_MAXLEVEL)
        ReplyToCommand(client, "%s Nivel: \x04%d (MAXIMO)\x05 | Bajas de la nave: %d | Curas: %d",
            CHAT_PREFIX, g_PetLevel[client], g_PetKills[client], g_PetHeals[client]);
    else
        ReplyToCommand(client, "%s Nivel: \x04%d\x05 (XP %d/%d) | Bajas de la nave: %d | Curas: %d",
            CHAT_PREFIX, g_PetLevel[client], g_PetXP[client], PetXPToNext(g_PetLevel[client]), g_PetKills[client], g_PetHeals[client]);
    if (PetIsActive(client))
        ReplyToCommand(client, "%s Pet: \x04ACTIVO\x05, energia restante %d s.", CHAT_PREFIX, RoundToCeil(g_petmaxlife - g_PetLife[client]));
    else
        ReplyToCommand(client, "%s Pet: no invocado (usa \x04!petsummon\x05).", CHAT_PREFIX);
    ReplyToCommand(client, "%s Arma: \x04%s\x05 | Misiles: \x04%s\x05 | IA: \x04%s\x05",
        CHAT_PREFIX, g_WeaponNames[g_PetWeapon[client]], nm, g_AINames[g_PetAIMode[client]]);
    ReplyToCommand(client, "%s Ruta: \x04%s\x05 | Granadas: \x04%s\x05 | Medica a aliados: \x04%s\x05",
        CHAT_PREFIX, g_RouteNames[g_PetRoute[client]], g_PetGrenade[client] ? "ON" : "OFF",
        (g_PetMedic[client] && g_PetLevel[client] >= 3) ? "ON" : "OFF");
    ReplyToCommand(client, "%s Lengua de Smoker: \x04%.0f%%\x05 (solo especiales) | Agarre: \x04MANUAL GARANTIZADO\x05 | Minas: \x04%s\x05",
        CHAT_PREFIX, PetTongueChance(client),
        (g_PetMines[client] && g_PetLevel[client] >= 6) ? "ON" : "OFF");
    if (g_bSurvivalMode)   // v2.9: confirmar que el modo detectado paga XP
        ReplyToCommand(client, "%s Modo: \x04SUPERVIVENCIA\x05 — cada minuto vivo paga XP (%d-%d) y el cierre premia el tiempo.",
            CHAT_PREFIX, PET_SURV_XP_BASE, PET_SURV_XP_BASE + PET_SURV_XP_RAMP);
    if (g_PetHold[client])
        ReplyToCommand(client, "%s Modo: \x04ESPERA\x05 en zona marcada (usa !petfollow para que te siga).", CHAT_PREFIX);
    ReplyToCommand(client, "%s Dano +%.0f%% | Vision %.0f u | Siguiente desbloqueo: %s",
        CHAT_PREFIX, (PetDamageMult(client) - 1.0) * 100.0, PetVisionRange(client), next);
    return Plugin_Handled;
}

public Action Cmd_PetLevel(int client, int args)
{
    if (!IsValidClient(client)) return Plugin_Handled;
    char next[64];
    NextUnlockText(client, next, sizeof(next));

    ReplyToCommand(client, "%s ==== PROGRESO DE LA NAVE ====", CHAT_PREFIX);
    if (g_PetLevel[client] >= PET_MAXLEVEL)
        ReplyToCommand(client, "%s Nivel: \x04%d (MAXIMO)\x05 | Bajas: %d | Curas: %d",
            CHAT_PREFIX, g_PetLevel[client], g_PetKills[client], g_PetHeals[client]);
    else
        ReplyToCommand(client, "%s Nivel: \x04%d\x05 | XP: %d/%d | Bajas: %d | Curas: %d",
            CHAT_PREFIX, g_PetLevel[client], g_PetXP[client], PetXPToNext(g_PetLevel[client]), g_PetKills[client], g_PetHeals[client]);
    ReplyToCommand(client, "%s Dano +%.0f%% | Vision +%.0f u | Recarga de misiles x%.2f",
        CHAT_PREFIX, (PetDamageMult(client) - 1.0) * 100.0, PetVisionRange(client) - g_radius, PetCDMult(client) / g_missilecdmul);
    ReplyToCommand(client, "%s Proximo desbloqueo: \x04%s\x05", CHAT_PREFIX, next);
    ReplyToCommand(client, "%s XP por baja: comun 3 (tuya o de la nave) | especial 20 | tank 250 | witch 120 | curas 2 c/u.", CHAT_PREFIX);
    return Plugin_Handled;
}

// ---------------------------------------------------------------------------
// Ordenes directas de control de la nave
// ---------------------------------------------------------------------------
void PetCmdAttack(int client)
{
    if (!PetIsActive(client))
    {
        PrintToChat(client, "%s La nave no esta activa (invocala con \x04!petsummon\x05).", CHAT_PREFIX);
        return;
    }
    int enemy = -1;
    float point[3];
    GetAimTargetOrPoint(client, enemy, point);
    if (enemy == -1 || !IsPetEnemy(enemy) || !IsEnemyAlive(enemy))
    {
        PrintToChat(client, "%s Apunta a un infectado para marcarlo como objetivo.", CHAT_PREFIX);
        return;
    }
    g_PetTarget[client] = EntIndexToEntRef(enemy);
    g_TargetSince[client] = GetGameTime();
    g_IgnoreTarget[client] = -1;
    g_IgnoreUntil[client] = 0.0;
    g_FlankUntil[client] = 0.0;
    MaybeAnnounceHighThreat(client, enemy);
    PrintToChat(client, "%s Objetivo marcado: \x04la nave va a por el\x05.", CHAT_PREFIX);
}

void PetCmdStay(int client)
{
    if (!PetIsActive(client))
    {
        PrintToChat(client, "%s La nave no esta activa.", CHAT_PREFIX);
        return;
    }
    int body = EntRefToEntIndex(g_PetBody[client]);
    if (body == -1 || !IsValidEntity(body)) return;
    GetEntPropVector(body, Prop_Send, "m_vecOrigin", g_PetHoldPos[client]);
    g_PetHoldPos[client][2] -= BODY_HEIGHT;
    g_PetHold[client] = true;
    g_PetFollow[client] = false;
    PrintToChat(client, "%s \x04Modo espera\x05: la nave defendera esta zona hasta que la llames (!petfollow).", CHAT_PREFIX);
}

void PetCmdFollow(int client)
{
    if (!PetIsValidControl(client)) return;
    g_PetHold[client] = false;
    g_PetFollow[client] = true;
    PrintToChat(client, "%s \x04Modo seguimiento\x05: la nave vuelve a tu lado.", CHAT_PREFIX);
}

void PetCmdRecall(int client)
{
    if (!PetIsValidControl(client)) return;
    int body = EntRefToEntIndex(g_PetBody[client]);
    if (body == -1 || !IsValidEntity(body)) return;
    float pos[3], ang[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    GetEntPropVector(client, Prop_Data, "m_angRotation", ang);
    pos[2] += BODY_HEIGHT + g_petheight;
    TeleportEntity(body, pos, ang, NULL_VECTOR);
    g_PetHold[client] = false;
    g_PetFollow[client] = true;
    EmitSoundToClient(client, SND_JETPASS);
    PrintToChat(client, "%s La nave regreso a tu lado.", CHAT_PREFIX);
}

void PetCmdGrenadeNow(int client)
{
    if (!PetIsValidControl(client)) return;
    if (GetGameTime() < g_NextGrenadeAt[client])
    {
        PrintToChat(client, "%s Lanzagranadas recargandose: faltan %d s.", CHAT_PREFIX,
            RoundToCeil(g_NextGrenadeAt[client] - GetGameTime()));
        return;
    }
    int targetIdx = (g_PetTarget[client] != -1) ? EntRefToEntIndex(g_PetTarget[client]) : -1;
    if (targetIdx == -1 || !IsValidEntity(targetIdx) || !IsEnemyAlive(targetIdx))
    {
        PrintToChat(client, "%s La nave no tiene objetivo aun (apunta y usa \x04!petattack\x05).", CHAT_PREFIX);
        return;
    }
    int body = EntRefToEntIndex(g_PetBody[client]);
    if (body == -1 || !IsValidEntity(body)) return;
    if (GetEntityCount() > MAX_EDICTS_SAFE) return;

    g_NextGrenadeAt[client] = GetGameTime() + PetGrenadeCD(client);
    float tPos[3];
    GetEntPropVector(targetIdx, Prop_Send, "m_vecOrigin", tPos);
    LaunchGrenade(client, body, targetIdx, tPos, -1);
    PrintToChat(client, "%s Granada lanzada al objetivo actual.", CHAT_PREFIX);
}

bool PetIsValidControl(int client)
{
    if (!PetIsActive(client))
    {
        PrintToChat(client, "%s La nave no esta activa (invocala con \x04!petsummon\x05).", CHAT_PREFIX);
        return false;
    }
    return true;
}

public Action Cmd_PetAttack(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    PetCmdAttack(client);
    return Plugin_Handled;
}

public Action Cmd_PetStay(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    PetCmdStay(client);
    return Plugin_Handled;
}

public Action Cmd_PetFollow(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    PetCmdFollow(client);
    return Plugin_Handled;
}

public Action Cmd_PetRecall(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    PetCmdRecall(client);
    return Plugin_Handled;
}

public Action Cmd_PetAirstrike(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    if (g_PetLevel[client] < 10)
    {
        ReplyToCommand(client, "%s El bombardeo aereo se desbloquea en \x04Nivel 10\x05 (vas por el %d).", CHAT_PREFIX, g_PetLevel[client]);
        return Plugin_Handled;
    }
    if (!PetIsValidControl(client)) return Plugin_Handled;
    if (GetGameTime() < g_NextAirstrikeAt[client])
    {
        ReplyToCommand(client, "%s Bombardeo recargandose: faltan %d s.", CHAT_PREFIX,
            RoundToCeil(g_NextAirstrikeAt[client] - GetGameTime()));
        return Plugin_Handled;
    }

    int enemy = -1;
    float point[3];
    GetAimTargetOrPoint(client, enemy, point);
    point[2] += 5.0;
    g_NextAirstrikeAt[client] = GetGameTime() + 45.0;

    PrintToChat(client, "%s \x04BOMBARDEO AEREO\x05 solicitado: la nave entra en la pasada...", CHAT_PREFIX);
    EmitSoundToAll(SND_AIRSTRIKE1, client, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER);
    DoAirstrikeAt(client, point, 8, 60.0, 190.0);
    return Plugin_Handled;
}

public Action Cmd_PetOmega(int client, int args)
{
    if (g_enable == 0 || !IsValidClient(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    if (g_PetLevel[client] < 70)
    {
        ReplyToCommand(client, "%s El bombardeo Omega se desbloquea en \x04Nivel 70\x05 (vas por el %d).", CHAT_PREFIX, g_PetLevel[client]);
        return Plugin_Handled;
    }
    if (!PetIsValidControl(client)) return Plugin_Handled;
    if (GetGameTime() < g_NextOmegaAt[client])
    {
        ReplyToCommand(client, "%s Omega recargandose: faltan %d s.", CHAT_PREFIX,
            RoundToCeil(g_NextOmegaAt[client] - GetGameTime()));
        return Plugin_Handled;
    }

    int enemy = -1;
    float point[3];
    GetAimTargetOrPoint(client, enemy, point);
    point[2] += 5.0;
    g_NextOmegaAt[client] = GetGameTime() + 120.0;

    PrintToChat(client, "%s \x04!! BOMBARDEO OMEGA !!\x05 Apaguen las luces.", CHAT_PREFIX);
    EmitSoundToAll(SND_AIRSTRIKE1, client, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER);
    EmitSoundToAll(SND_AIRSTRIKE3, client, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER);

    int ring[4] = {255, 220, 60, 240};
    TE_SetupBeamRingPoint(point, 30.0, 900.0, g_sBeam, g_sBeam, 0, 120, 1.6, 40.0, 0.0, ring, 220, 0);
    TE_SendToAll();
    TE_SetupExplosion(point, g_sExplosion, 15.0, 1, 0, 450, 200);
    TE_SendToAll();
    DoAirstrikeAt(client, point, 12, 90.0, 260.0);
    return Plugin_Handled;
}

// ---------------------------------------------------------------------------
// MENU UNIFICADO (!pet): hub central con submenus coherentes
// ---------------------------------------------------------------------------
void ShowPetMenu(int client)
{
    Menu menu = new Menu(MenuHandler_PetMain);
    menu.Pagination = MENU_NO_PAGINATION;

    char title[224];
    char status[48];
    if (PetIsActive(client))
        Format(status, sizeof(status), "ACTIVO (%d s)", RoundToCeil(g_petmaxlife - g_PetLife[client]));
    else
        strcopy(status, sizeof(status), "no invocado");

    char styleName[26];
    PetStyleName(client, styleName, sizeof(styleName));
    Format(title, sizeof(title),
        "Pet Navideño  [Nv %d | XP %d/%d]\nPet: %s  |  IA: %s\nArma: %s  |  Misil: %s\nRuta: %s  |  Granadas: %s\n ",
        g_PetLevel[client], g_PetXP[client], PetXPToNext(g_PetLevel[client]),
        status, g_AINames[g_PetAIMode[client]], g_WeaponNames[g_PetWeapon[client]], styleName,
        g_RouteNames[g_PetRoute[client]], g_PetGrenade[client] ? "ON" : "OFF");
    menu.SetTitle(title);

    if (PetIsActive(client))
        menu.AddItem("dismiss", "Despedir la nave");
    else
        menu.AddItem("summon", "Invocar la nave");

    menu.AddItem("weapons", "Arsenal (22 armas, por nivel)");
    menu.AddItem("missiles", "Sistema de misiles");
    menu.AddItem("ia", "Comportamiento de la IA");
    menu.AddItem("routes", "Rutas de vuelo");
    menu.AddItem("grenades", "Lanzagranadas (25 efectos)");
    menu.AddItem("progress", "Progreso y habilidades");
    menu.AddItem("control", "Control de la nave");
    menu.AddItem("help", "Manual de uso");

    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_PetMain(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action != MenuAction_Select) return 0;

    char info[16];
    menu.GetItem(item, info, sizeof(info));

    if (StrEqual(info, "summon"))
    {
        if (IsPlayerAlive(client))
            CallPet(client);
        else
            PrintToChat(client, "%s Debes estar vivo para invocar al pet.", CHAT_PREFIX);
        ShowPetMenu(client);
    }
    else if (StrEqual(info, "dismiss"))
    {
        TerminatePet(client, true);
        ShowPetMenu(client);
    }
    else if (StrEqual(info, "weapons")) ShowWeaponMenu(client);
    else if (StrEqual(info, "missiles")) ShowMissileMenu(client);
    else if (StrEqual(info, "ia")) ShowAIMenu(client);
    else if (StrEqual(info, "routes")) ShowRouteMenu(client);
    else if (StrEqual(info, "grenades")) ShowGrenadeMenu(client);
    else if (StrEqual(info, "progress")) ShowProgressMenu(client);
    else if (StrEqual(info, "control")) ShowControlMenu(client);
    else if (StrEqual(info, "help")) ShowPetHelp(client);
    return 0;
}

void ShowWeaponMenu(int client)
{
    Menu menu = new Menu(MenuHandler_Weapons);
    menu.Pagination = 7;   // 22 armas: paginado (7 por pagina, orden por nivel)
    char title[160];
    Format(title, sizeof(title), "Arsenal de la nave  [Nv %d]\n22 modos de disparo (se desbloquean con nivel):\n ",
        g_PetLevel[client]);
    menu.SetTitle(title);

    char display[96], info[8];
    char pre[4];
    for (int oi = 0; oi < WEAP_COUNT; oi++)
    {
        int w = g_WeaponOrder[oi];
        bool unlocked = PetWeaponUnlocked(client, w);
        if (w == g_PetWeapon[client]) strcopy(pre, sizeof(pre), "» ");
        else pre[0] = '\0';
        if (unlocked)
            Format(display, sizeof(display), "%s%s - %s", pre, g_WeaponNames[w], g_WeaponDescs[w]);
        else
            Format(display, sizeof(display), "%s%s - %s [Nv %d]", pre, g_WeaponNames[w], g_WeaponDescs[w], g_WeaponLevels[w]);
        IntToString(w, info, sizeof(info));
        menu.AddItem(info, display, unlocked ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    }
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Weapons(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Select)
    {
        char info[8];
        menu.GetItem(item, info, sizeof(info));
        int wpn = StringToInt(info);
        if (wpn >= 0 && wpn < WEAP_COUNT && PetWeaponUnlocked(client, wpn))
        {
            if (g_PetWeapon[client] != wpn)
            {
                g_PetWeapon[client] = wpn;
                SavePetPrefs(client);
                PrintToChat(client, "%s Modo de disparo: \x04%s\x05 - %s.", CHAT_PREFIX,
                    g_WeaponNames[wpn], g_WeaponDescs[wpn]);
            }
        }
        ShowWeaponMenu(client);
    }
    else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
        ShowPetMenu(client);
    return 0;
}

void ShowMissileMenu(int client)
{
    Menu menu = new Menu(MenuHandler_Missiles);
    menu.Pagination = 7;   // 11 opciones: paginado para no cortar la lista
    char title[160];
    Format(title, sizeof(title), "Sistema de Misiles  [Nv %d]\nEstilo de misil (recarga x%.2f segun nivel):\n ",
        g_PetLevel[client], PetCDMult(client));
    menu.SetTitle(title);

    char display[96];
    char info[4];
    for (int id = 0; id < 10; id++)
    {
        if (id == g_PetMissile[client])
            Format(display, sizeof(display), "» %s - %s", g_Styles[id].name, g_Styles[id].desc);
        else
            Format(display, sizeof(display), "%s - %s", g_Styles[id].name, g_Styles[id].desc);
        IntToString(id, info, sizeof(info));
        menu.AddItem(info, display);
    }
    if (g_PetMissile[client] == MSTYLE_RANDOM)
        Format(display, sizeof(display), "» Aleatorio - cada salva elige un tipo al azar");
    else
        Format(display, sizeof(display), "Aleatorio - cada salva elige un tipo al azar");
    menu.AddItem("R", display);
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Missiles(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Select)
    {
        char info[4];
        menu.GetItem(item, info, sizeof(info));
        if (StrEqual(info, "R"))
        {
            g_PetMissile[client] = MSTYLE_RANDOM;
            SavePetPrefs(client);
            PrintToChat(client, "%s Misiles: \x04Aleatorio\x05. Cada salva elige uno de los 10 tipos al azar.", CHAT_PREFIX);
        }
        else
        {
            int id = StringToInt(info);
            if (id >= 0 && id < 10)
            {
                g_PetMissile[client] = id;
                SavePetPrefs(client);
                PrintToChat(client, "%s Misil seleccionado: \x04%s\x05 (%s).", CHAT_PREFIX, g_Styles[id].name, g_Styles[id].desc);
                PrintToChat(client, "%s Recarga de ese estilo: cada \x04%.0f s\x05 (x%.2f global).", CHAT_PREFIX,
                    g_Styles[id].cooldown, PetCDMult(client));
            }
        }
        ShowMissileMenu(client);
    }
    else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
        ShowPetMenu(client);
    return 0;
}

void ShowAIMenu(int client)
{
    Menu menu = new Menu(MenuHandler_AI);
    menu.SetTitle("Comportamiento de la IA\nComo reacciona la nave en combate:\n ");
    char display[96], info[4];
    char pre[4];
    for (int id = 0; id < 3; id++)
    {
        if (id == g_PetAIMode[client]) strcopy(pre, sizeof(pre), "» ");
        else pre[0] = '\0';
        switch (id)
        {
            case 0: Format(display, sizeof(display), "%sAgresivo - vuela bajo y persigue mas lejos", pre);
            case 1: Format(display, sizeof(display), "%sNormal - equilibrio entre ataque y cobertura", pre);
            case 2: Format(display, sizeof(display), "%sDefensivo - vuela alto y se queda cerca de ti", pre);
        }
        IntToString(id, info, sizeof(info));
        menu.AddItem(info, display);
    }
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_AI(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Select)
    {
        char info[4];
        menu.GetItem(item, info, sizeof(info));
        int id = StringToInt(info);
        if (id >= 0 && id <= 2)
        {
            g_PetAIMode[client] = id;
            SavePetPrefs(client);
            PrintToChat(client, "%s Comportamiento IA: \x04%s\x05.", CHAT_PREFIX, g_AINames[id]);
        }
        ShowAIMenu(client);
    }
    else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
        ShowPetMenu(client);
    return 0;
}

void ShowRouteMenu(int client)
{
    Menu menu = new Menu(MenuHandler_Routes);
    menu.SetTitle("Rutas de vuelo (en reposo)\nComo vuela la nave cuando no hay enemigos:\n ");
    char display[96], info[4];
    char pre[4];
    for (int id = 0; id < 4; id++)
    {
        if (id == g_PetRoute[client]) strcopy(pre, sizeof(pre), "» ");
        else pre[0] = '\0';
        switch (id)
        {
            case 0: Format(display, sizeof(display), "%sOrbita - gira a tu alrededor a 300 u", pre);
            case 1: Format(display, sizeof(display), "%sBalanceo - va y viene a tus lados", pre);
            case 2: Format(display, sizeof(display), "%sPatrulla - pasa de delante a atras", pre);
            case 3: Format(display, sizeof(display), "%sAleatoria - combina las tres cada 10 s", pre);
        }
        IntToString(id, info, sizeof(info));
        menu.AddItem(info, display);
    }
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Routes(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Select)
    {
        char info[4];
        menu.GetItem(item, info, sizeof(info));
        int id = StringToInt(info);
        if (id >= 0 && id <= 3)
        {
            g_PetRoute[client] = id;
            g_RouteNextSwap[client] = 0.0;
            SavePetPrefs(client);
            PrintToChat(client, "%s Ruta de vuelo: \x04%s\x05.", CHAT_PREFIX, g_RouteNames[id]);
        }
        ShowRouteMenu(client);
    }
    else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
        ShowPetMenu(client);
    return 0;
}

void ShowGrenadeMenu(int client)
{
    Menu menu = new Menu(MenuHandler_Grenades);
    char title[160];
    Format(title, sizeof(title), "Lanzagranadas  [Nv %d]\n25 efectos al azar al detonar (regla grenade.sp)\n ",
        g_PetLevel[client]);
    menu.SetTitle(title);

    char display[96];
    Format(display, sizeof(display), "Lanzagranadas: %s", g_PetGrenade[client] ? "ON" : "OFF");
    menu.AddItem("toggle", display);
    if (g_PetLevel[client] >= 3)
        Format(display, sizeof(display), "Granada medica a aliados heridos: %s", g_PetMedic[client] ? "ON" : "OFF");
    else
        Format(display, sizeof(display), "Granada medica a aliados: [Nv 3]");
    menu.AddItem("medic", display, g_PetLevel[client] >= 3 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.AddItem("info1", "Granadas reales: molotov / casera / bilis", ITEMDRAW_DISABLED);
    menu.AddItem("info2", "Efectos: cura, HE, cluster, fuego, hielo...", ITEMDRAW_DISABLED);
    menu.AddItem("info3", "...humo, escudo, acido, flak, bombardeo, arma", ITEMDRAW_DISABLED);
    menu.AddItem("info4", "NUEVAS v2.4: meteoritos, nova de plasma,", ITEMDRAW_DISABLED);
    menu.AddItem("info5", "enjambre, nube toxica y MINI-NUKE", ITEMDRAW_DISABLED);
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Grenades(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Select)
    {
        char info[16];
        menu.GetItem(item, info, sizeof(info));
        if (StrEqual(info, "toggle"))
        {
            g_PetGrenade[client] = !g_PetGrenade[client];
            SavePetPrefs(client);
            PrintToChat(client, "%s Lanzagranadas \x04%s\x05.", CHAT_PREFIX, g_PetGrenade[client] ? "ON" : "OFF");
        }
        else if (StrEqual(info, "medic"))
        {
            g_PetMedic[client] = !g_PetMedic[client];
            SavePetPrefs(client);
            PrintToChat(client, "%s Granada medica a aliados heridos: \x04%s\x05.", CHAT_PREFIX, g_PetMedic[client] ? "ON" : "OFF");
        }
        ShowGrenadeMenu(client);
    }
    else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
        ShowPetMenu(client);
    return 0;
}

void ShowProgressMenu(int client)
{
    Menu menu = new Menu(MenuHandler_Progress);
    menu.Pagination = 7;   // 30 hitos: paginado para verlos todos
    char title[224];
    if (g_PetLevel[client] >= PET_MAXLEVEL)
        Format(title, sizeof(title), "Progreso: NIVEL MAXIMO\nBajas de la nave: %d | Curas: %d\n ",
            g_PetKills[client], g_PetHeals[client]);
    else
        Format(title, sizeof(title), "Progreso de la nave  [Nv %d]\nXP: %d / %d  |  Bajas: %d  |  Curas: %d\n ",
            g_PetLevel[client], g_PetXP[client], PetXPToNext(g_PetLevel[client]), g_PetKills[client], g_PetHeals[client]);
    menu.SetTitle(title);

    char display[96];
    for (int u = 0; u < UNLOCK_COUNT; u++)
    {
        if (g_PetLevel[client] >= g_UnlockLevels[u])
            Format(display, sizeof(display), "[OK]    Nv %d   %s", g_UnlockLevels[u], g_UnlockNames[u]);
        else
            Format(display, sizeof(display), "[----]  Nv %d   %s", g_UnlockLevels[u], g_UnlockNames[u]);
        menu.AddItem("u", display, ITEMDRAW_DISABLED);
    }
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Progress(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
        ShowPetMenu(client);
    return 0;
}

void ShowControlMenu(int client)
{
    Menu menu = new Menu(MenuHandler_Control);
    menu.SetTitle("Control de la nave  [Nv %d]\nOrdenes directas de vuelo y ataque:\n ", g_PetLevel[client]);
    menu.AddItem("attack", "Ataca a lo que estoy mirando");
    if (g_PetHold[client])
    {
        menu.AddItem("hold", "Quedate en esta zona (activo)", ITEMDRAW_DISABLED);
        menu.AddItem("follow", "Sigueme (cancela la espera)");
    }
    else
    {
        menu.AddItem("hold", "Quedate en esta zona (espera)");
        menu.AddItem("follow", "Sigueme (modo normal)", ITEMDRAW_DISABLED);
    }
    menu.AddItem("recall", "Regresa a mi (teletransporte)");
    menu.AddItem("grenade", "Lanzale una granada a mi objetivo");
    char md[96];
    if (g_PetLevel[client] >= 6)
        Format(md, sizeof(md), "Minas de proximidad: %s", g_PetMines[client] ? "ON" : "OFF");
    else
        Format(md, sizeof(md), "Minas de proximidad: [Nv 6]");
    menu.AddItem("mines", md, g_PetLevel[client] >= 6 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Control(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Select)
    {
        char info[16];
        menu.GetItem(item, info, sizeof(info));
        if (StrEqual(info, "attack")) PetCmdAttack(client);
        else if (StrEqual(info, "hold")) PetCmdStay(client);
        else if (StrEqual(info, "follow")) PetCmdFollow(client);
        else if (StrEqual(info, "recall")) PetCmdRecall(client);
        else if (StrEqual(info, "grenade")) PetCmdGrenadeNow(client);
        else if (StrEqual(info, "mines"))
        {
            if (g_PetLevel[client] >= 6)
            {
                g_PetMines[client] = !g_PetMines[client];
                SavePetPrefs(client);
                PrintToChat(client, "%s Minas de proximidad: \x04%s\x05 (la nave las suelta en combate).",
                    CHAT_PREFIX, g_PetMines[client] ? "ON" : "OFF");
            }
        }
        ShowControlMenu(client);
    }
    else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack)
        ShowPetMenu(client);
    return 0;
}

void ShowPetHelp(int client)
{
    PrintToChat(client, "%s La nave vuela junto a ti, escanea y ataca sola. Gana XP con sus bajas y curas (max \x04Nv 100\x05, SQLite).", CHAT_PREFIX);
    PrintToChat(client, "%s Cada nivel mejora dano/cadencia/vision. Hitos desbloquean armas y habilidades (!petlevel).", CHAT_PREFIX);
    PrintToChat(client, "%s Control: \x04!petattack\x05 (ataca lo que miras), \x04!petstay\x05 / \x04!petfollow\x05, \x04!petrecall\x05.", CHAT_PREFIX);
    PrintToChat(client, "%s Armas: sniper(5) criogenico(8) granadas(12) minigun(15) gauss(18) solar(22) laser(25).", CHAT_PREFIX);
    PrintToChat(client, "%s Pulso(28) arco cruzado(33) tesla(35) cluster(38) plasma(45) fragmentacion(50) vacio(55).", CHAT_PREFIX);
    PrintToChat(client, "%s Railgun(60) buscadores(65) cohetera(80) antimateria(85) y Cañon Estelar (Nv 100).", CHAT_PREFIX);
    PrintToChat(client, "%s Pasivas: \x04lengua de Smoker\x05 (chance sube con el nivel) y \x04minas\x05 (Nv 6, !petmines).", CHAT_PREFIX);
    PrintToChat(client, "%s Bombardeo aereo \x04!petairstrike\x05 (Nv 10) y Omega \x04!petomega\x05 (Nv 70).", CHAT_PREFIX);
    PrintToChat(client, "%s Granadas: 25 efectos al azar; la medica al aliado herido (Nv 3). Los comunes que matas dan XP. Config guardada sola.", CHAT_PREFIX);
    PrintToChat(client, "%s Todo desde el menu unico \x04!pet\x05. Prioridad maxima si un especial te atrapa.", CHAT_PREFIX);
    ShowPetMenu(client);
}

// ---------------------------------------------------------------------------
// Invocar / Despedir
// ---------------------------------------------------------------------------
bool PetIsActive(int client)
{
    if (g_PetBody[client] == -1) return false;
    int body = EntRefToEntIndex(g_PetBody[client]);
    return (body != -1 && IsValidEntity(body));
}

bool CallPet(int client)
{
    // si ya tiene pet: renovar energia
    if (PetIsActive(client))
    {
        g_PetLife[client] = 0.0;
        EmitSoundToClient(client, SND_REWARD);
        PrintToChat(client, "%s Energia del pet recargada (%.0f s).", CHAT_PREFIX, g_petmaxlife);
        return true;
    }

    float petPos[3];
    float petAng[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", petPos);
    GetEntPropVector(client, Prop_Data, "m_angRotation", petAng);
    petPos[2] += BODY_HEIGHT;

    // cuerpo fisico invisible del jet (a 3000 u, sin colisiones con el mundo)
    int body = CreateEntityByName("molotov_projectile");
    if (body == -1) return false;
    DispatchKeyValue(body, "model", DMY_MISSILE);
    DispatchKeyValueVector(body, "origin", petPos);
    DispatchKeyValueVector(body, "angles", petAng);
    SetEntPropFloat(body, Prop_Send, "m_flModelScale", 0.001);
    SetEntPropEnt(body, Prop_Data, "m_hOwnerEntity", client);
    SetEntityGravity(body, 0.01);
    DispatchSpawn(body);
    SDKHook(body, SDKHook_Touch, BlockPetTouch);
    SDKHook(body, SDKHook_OnTakeDamage, BlockPetDamage);

    petPos[2] -= BODY_HEIGHT;
    float flmOri[3] = {-7.0, 0.0, 0.0};
    float flmAng[3] = {0.0, 180.0, 0.0};
    flmOri[2] -= BODY_HEIGHT;

    // estela azul del jet
    char exaustName[48];
    Format(exaustName, sizeof(exaustName), "pettarget%d", body);
    int exaust = CreateEntityByName("env_steam");
    if (exaust != -1)
    {
        DispatchKeyValue(body, "targetname", exaustName);
        DispatchKeyValue(exaust, "SpawnFlags", "1");
        DispatchKeyValue(exaust, "Type", "0");
        DispatchKeyValue(exaust, "InitialState", "1");
        DispatchKeyValue(exaust, "Spreadspeed", "10");
        DispatchKeyValue(exaust, "Speed", "200");
        DispatchKeyValue(exaust, "Startsize", "5");
        DispatchKeyValue(exaust, "EndSize", "30");
        DispatchKeyValue(exaust, "Rate", "555");
        DispatchKeyValue(exaust, "RenderColor", "60 80 200");
        DispatchKeyValue(exaust, "JetLength", "20.0");
        DispatchKeyValue(exaust, "RenderAmt", "180");
        DispatchKeyValueVector(exaust, "origin", petPos);
        DispatchKeyValueVector(exaust, "angles", petAng);
        DispatchSpawn(exaust);
        SetVariantString(exaustName);
        AcceptEntityInput(exaust, "SetParent", exaust, exaust, 0);
        TeleportEntity(exaust, flmOri, flmAng, NULL_VECTOR);
        AcceptEntityInput(exaust, "TurnOn");
    }

    // el F18 visible, colgado del cuerpo fisico con offset -3000
    float caPos[3] = {0.0, 0.0, 0.0};
    float caAng[3] = {0.0, 0.0, 0.0};
    caPos[2] -= BODY_HEIGHT;
    int attch = CreateEntityByName("prop_dynamic_override");
    if (attch == -1)
    {
        AcceptEntityInput(body, "kill");
        if (exaust != -1) AcceptEntityInput(exaust, "kill");
        return false;
    }
    char namE[32];
    Format(namE, sizeof(namE), "petmissile%d", body);
    DispatchKeyValue(body, "targetname", namE);
    DispatchKeyValue(attch, "model", MDL_JETF18);
    DispatchKeyValue(attch, "parentname", namE);
    DispatchKeyValueFloat(attch, "fademindist", 10000.0);
    DispatchKeyValueFloat(attch, "fademaxdist", 20000.0);
    DispatchKeyValueFloat(attch, "fadescale", 0.0);
    DispatchKeyValueVector(attch, "origin", petPos);
    DispatchKeyValueVector(attch, "angles", petAng);
    SetVariantString(namE);
    AcceptEntityInput(attch, "SetParent", attch, attch, 0);
    SetEntPropFloat(attch, Prop_Send, "m_flModelScale", 1.0);
    DispatchSpawn(attch);
    TeleportEntity(attch, caPos, caAng, NULL_VECTOR);

    petPos[2] += (BODY_HEIGHT + 5.0);
    TeleportEntity(body, petPos, NULL_VECTOR, NULL_VECTOR);

    g_PetBody[client] = EntIndexToEntRef(body);
    g_PetModel[client] = (attch != -1) ? EntIndexToEntRef(attch) : -1;
    g_PetExhaust[client] = (exaust != -1) ? EntIndexToEntRef(exaust) : -1;
    g_PetLife[client] = 0.0;
    g_PetTarget[client] = -1;
    g_PetFollow[client] = false;
    g_LastHadTarget[client] = 0.0;   // v3.1: sin objetivo al invocar
    g_NextBulletAt[client] = 0.0;
    g_NextMissileAt[client] = GetGameTime() + 1.5;

    switch (GetRandomInt(1, 3))
    {
        case 1: EmitSoundToClient(client, SND_AIRSTRIKE1);
        case 2: EmitSoundToClient(client, SND_AIRSTRIKE2);
        case 3: EmitSoundToClient(client, SND_AIRSTRIKE3);
    }
    char styleName[26];
    PetStyleName(client, styleName, sizeof(styleName));
    PrintToChat(client, "%s Pet bombardero invocado: \x04NIVEL %d\x05 (\x04%s\x05 / misiles \x04%s\x05 / IA \x04%s\x05 / granadas \x04%s\x05).",
        CHAT_PREFIX, g_PetLevel[client], g_WeaponNames[g_PetWeapon[client]], styleName,
        g_AINames[g_PetAIMode[client]], g_PetGrenade[client] ? "ON" : "OFF");

    // v3.0: motor a 0.1 s (antes 0.2): el DOBLE de velocidad de reaccion —
    // adquiere objetivos, dispara y corrige el rumbo al doble de rapido
    CreateTimer(0.1, Timer_PetEngine, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    return true;
}

public Action BlockPetTouch(int entity, int other)
{
    return Plugin_Handled;   // el cuerpo nunca "aterriza": el juego no lo detona
}

public Action BlockPetDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    return Plugin_Handled;
}

void TerminatePet(int client, bool notify)
{
    // v2.5: soltar la lengua antes de despedir la nave (libera el agarre real)
    CleanupTongue(client);

    int body = (g_PetBody[client] != -1) ? EntRefToEntIndex(g_PetBody[client]) : -1;

    // despedida con estilo: acelera hacia el horizonte antes de borrar
    if (body != -1 && IsValidEntity(body))
    {
        float tAng[3];
        float tVol[3];
        GetEntPropVector(body, Prop_Data, "m_angRotation", tAng);
        tAng[0] = -20.0;
        GetAngleVectors(tAng, tVol, NULL_VECTOR, NULL_VECTOR);
        NormalizeVector(tVol, tVol);
        ScaleVector(tVol, 900.0);
        TeleportEntity(body, NULL_VECTOR, NULL_VECTOR, tVol);
        SetPetBank(client, -20.0);   // v3.1: trepando al horizonte (visual)

        int refs[3];
        refs[0] = g_PetBody[client];
        refs[1] = g_PetModel[client];
        refs[2] = g_PetExhaust[client];
        for (int i = 0; i < 3; i++)
        {
            int ent = (refs[i] != -1) ? EntRefToEntIndex(refs[i]) : -1;
            if (ent != -1 && IsValidEntity(ent))
                CreateTimer(0.3, Timer_KillEnt, refs[i], TIMER_FLAG_NO_MAPCHANGE);
        }
    }
    if (IsValidClient(client))
    {
        EmitSoundToClient(client, SND_JETPASS);
        if (notify)
            PrintToChat(client, "%s Pet retirado. Hasta la vista, capitan.", CHAT_PREFIX);
    }
    g_PetLife[client] = 0.0;
    g_PetBody[client] = -1;
    g_PetModel[client] = -1;
    g_PetExhaust[client] = -1;
    g_PetTarget[client] = -1;
    g_PetFollow[client] = false;
}

public Action Timer_KillEnt(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(ref);
    if (ent != -1 && IsValidEntity(ent))
        AcceptEntityInput(ent, "kill");
    return Plugin_Stop;
}

// ---------------------------------------------------------------------------
// Sistema de regalos (solo con l4d2_pet_giftmode 1)
// ---------------------------------------------------------------------------
void DropChristmasGift(int client)
{
    if (GetEntityCount() > MAX_EDICTS_SAFE) return;

    float gifPos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", gifPos);
    gifPos[2] += 10.0;

    int gift = CreateEntityByName("prop_dynamic_override");
    if (gift == -1) return;
    DispatchKeyValue(gift, "model", MDL_GIFT);
    DispatchKeyValueVector(gift, "origin", gifPos);
    DispatchKeyValue(gift, "solid", "0");
    SetEntPropFloat(gift, Prop_Send, "m_flModelScale", 1.0);
    DispatchSpawn(gift);

    int ref = EntIndexToEntRef(gift);
    CreateTimer(0.2, Timer_GiftLife, ref, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    // watchdog de vida: el regalo caduca solo
    if (g_gifmaxlife > 0.0)
        CreateTimer(g_gifmaxlife, Timer_KillEnt, ref, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_GiftLife(Handle timer, any ref)
{
    int gift = EntRefToEntIndex(ref);
    if (gift == -1 || !IsValidEntity(gift))
        return Plugin_Stop;

    if (g_RoundEnd || !g_bGiftMode)
    {
        AcceptEntityInput(gift, "kill");
        return Plugin_Stop;
    }

    RotateAdvance(gift, 15.0, 1);

    float gfPos[3];
    float myPos[3];
    GetEntPropVector(gift, Prop_Send, "m_vecOrigin", gfPos);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i) && !IsFakeClient(i) && GetClientTeam(i) == 2)
        {
            GetEntPropVector(i, Prop_Send, "m_vecOrigin", myPos);
            if (GetVectorDistance(myPos, gfPos) < 70.0)
            {
                if (CallPet(i))
                    PrintToChat(i, "%s Recogiste un regalo navideño: pet invocado!", CHAT_PREFIX);
                AcceptEntityInput(gift, "kill");
                return Plugin_Stop;
            }
        }
    }
    return Plugin_Continue;
}


// ---------------------------------------------------------------------------
// ENGINE DEL PET (tick 0.2s): IA, escaneo, LOS, movimiento y disciplina de tiro
// ---------------------------------------------------------------------------
public Action Timer_PetEngine(Handle timer, any data)
{
    int client = GetClientOfUserId(data);
    if (!IsValidClient(client) || !IsPlayerAlive(client) || g_RoundEnd || g_enable == 0)
    {
        if (IsValidClient(client) && PetIsActive(client))
            TerminatePet(client, false);
        return Plugin_Stop;
    }

    int body = EntRefToEntIndex(g_PetBody[client]);
    if (body == -1 || !IsValidEntity(body))
    {
        g_PetBody[client] = -1;
        g_PetTarget[client] = -1;
        return Plugin_Stop;
    }

    g_PetLife[client] += 0.1;   // v3.0: tick de 0.1 s (el tiempo corre igual)
    if (g_PetLife[client] > g_petmaxlife)
    {
        TerminatePet(client, false);
        return Plugin_Stop;
    }

    // radio de enganche: vision base (cvar) + bonus por nivel + radar del Nv 20
    float engage = PetVisionRange(client);
    if (g_PetAIMode[client] == 2) engage = engage * 0.6;

    // ---- prioridad absoluta: el especial que tiene ATRAPADA a la duena -------
    // (hunter que salta, smoker que estrangula, jockey montado, charger)
    int pinner = GetOwnerPinner(client);
    if (pinner != -1)
    {
        int pinRef = EntIndexToEntRef(pinner);
        if (g_PetTarget[client] != pinRef)
        {
            g_PetTarget[client] = pinRef;
            g_TargetSince[client] = GetGameTime();
            g_FlankUntil[client] = 0.0;
            g_IgnoreTarget[client] = -1;   // al que pinnea nunca se le ignora
            g_IgnoreUntil[client] = 0.0;
            char cls[24];
            PetSIName(pinner, cls, sizeof(cls));
            PrintToChat(client, "%s \x04!Un %s te tiene atrapada!\x05 Prioridad maxima: la nave ya va.", CHAT_PREFIX, cls);
            EmitSoundToClient(client, SND_AIRSTRIKE2);
        }
        // mientras la duena este atrapada, el rango de persecucion se amplifica
        engage *= 1.8;
    }

    // ---- mantenimiento del objetivo -----------------------------------
    int myEnemy = (g_PetTarget[client] != -1) ? EntRefToEntIndex(g_PetTarget[client]) : -1;
    bool enemyValid = (myEnemy != -1 && IsValidEntity(myEnemy) && IsEnemyAlive(myEnemy));
    if (enemyValid)
        g_LastHadTarget[client] = GetGameTime();   // v3.1: hubo objetivo este tick

    // v3.0: velocidad de REACCION — mejora de objetivo cada 0.75 s (antes 1.5)
    if (enemyValid && (GetGameTime() - g_TargetSince[client]) > 0.75)
    {
        // upgrade dinamico: si apuntamos a un comun/witch y hay un especial mejor, cambiamos
        if (myEnemy > MaxClients)
        {
            int better = ScanEnemy(client, myEnemy, engage);
            if (better != -1 && better != myEnemy && better <= MaxClients)
            {
                myEnemy = better;
                g_PetTarget[client] = EntIndexToEntRef(myEnemy);
                g_TargetSince[client] = GetGameTime();
                MaybeAnnounceHighThreat(client, myEnemy);
            }
        }
    }
    else if (!enemyValid)
    {
        g_AnnouncedRef[client] = -1;
        myEnemy = ScanEnemy(client, -1, engage);
        if (myEnemy != -1 && IsValidEntity(myEnemy))
        {
            g_PetTarget[client] = EntIndexToEntRef(myEnemy);
            g_TargetSince[client] = GetGameTime();
            g_LastHadTarget[client] = GetGameTime();   // v3.1: recien enganchado
            MaybeAnnounceHighThreat(client, myEnemy);
        }
        else
        {
            g_PetTarget[client] = -1;
        }
    }

    // ---- granada MEDICA automatica (Nv 3): si un aliado o la duena esta herida
    // (le falta mas del 25%), la nave le lanza una granada de cura dirigida ----
    if (g_PetGrenade[client] && g_grenadesOn && g_PetMedic[client] && g_PetLevel[client] >= 3
        && GetGameTime() >= g_NextGrenadeAt[client] && GetEntityCount() < MAX_EDICTS_SAFE)
    {
        int ally = FindHurtAlly(client, engage);
        if (ally != -1 && PetLOSAlly(client, body, ally))
        {
            g_NextGrenadeAt[client] = GetGameTime() + PetGrenadeCD(client) * 0.75;
            float aPos[3];
            GetEntPropVector(ally, Prop_Send, "m_vecOrigin", aPos);
            LaunchGrenade(client, body, ally, aPos, GRENADE_FX_MEDIC);
            PrintToChat(client, "%s \x04Granada MEDICA\x05 lanzada hacia \x05%N\x05.", CHAT_PREFIX, ally);
        }
    }

    // ---- pulso defensivo (Nv 30): aparta a la horda que rodea a la duena ----
    if (g_PetLevel[client] >= 30 && GetGameTime() >= g_NextPulseAt[client])
    {
        float pcPos[3];
        GetEntPropVector(client, Prop_Send, "m_vecOrigin", pcPos);
        ArrayList near = new ArrayList();
        PetCommonsInRadius(pcPos, 170.0, near);
        if (near.Length >= 3)
        {
            g_NextPulseAt[client] = GetGameTime() + 8.0;
            PetDefensivePulse(client, pcPos);
        }
        else
            g_NextPulseAt[client] = GetGameTime() + 1.0;
        delete near;
    }

    // ---- minas de proximidad (v2.4, Nv 6): suelta minas al suelo -----------
    MaybeDropMine(client, body, myEnemy);

    float _clPos[3], _clAng[3], _jtPos[3], _jtAng[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", _clPos);
    GetEntPropVector(client, Prop_Data, "m_angRotation", _clAng);
    GetEntPropVector(body, Prop_Send, "m_vecOrigin", _jtPos);
    GetEntPropVector(body, Prop_Data, "m_angRotation", _jtAng);
    _clPos[2] += g_petheight;
    _jtPos[2] -= BODY_HEIGHT;

    if (myEnemy != -1 && IsValidEntity(myEnemy) && IsEnemyAlive(myEnemy))
    {
        float _tgPos[3];
        GetEntPropVector(myEnemy, Prop_Send, "m_vecOrigin", _tgPos);
        if (GetVectorDistance(_tgPos, _jtPos) > engage)
        {
            // DISCIPLINA DE VISION (v2.3): si el objetivo salio del rango, la nave
            // NO se pierde persiguiendolo: lo suelta y vuelve al lado de la duena.
            // Excepcion: el especial que la tiene atrapada (se persigue siempre).
            if (PetPinningVictim(myEnemy) == client && g_PetAIMode[client] != 2)
            {
                FollowTarget(client, myEnemy);
            }
            else if (g_PetAIMode[client] == 2)
            {
                // v3.1: histeresis anti flip-flop — el objetivo soltado por
                // rango se ignora 0.3 s (antes re-enganchaba cada tick al
                // rondar el borde de engage, haciendo parpadear a la nave)
                g_IgnoreTarget[client] = g_PetTarget[client];
                g_IgnoreUntil[client] = GetGameTime() + 0.3;
                g_PetTarget[client] = -1;
                g_FlankUntil[client] = 0.0;
                FollowTarget(client, client);   // defensivo: nunca persigue
            }
            else
            {
                // v3.1: histeresis anti flip-flop (0.3 s) — misma razon que la
                // rama defensiva: sin esto el ciclo soltar/re-enganchar al
                // borde del rango corria a 10 Hz con el motor de 0.1 s
                g_IgnoreTarget[client] = g_PetTarget[client];
                g_IgnoreUntil[client] = GetGameTime() + 0.3;
                g_PetTarget[client] = -1;
                g_FlankUntil[client] = 0.0;
                if (g_PetHold[client])
                    HoldPosition(client);
                else
                    FollowTarget(client, client);
            }
        }
        else
        {
            // flanqueo activo: maniobra alrededor del muro en vez de mirarlo fijo
            if (g_FlankUntil[client] != 0.0)
                FlankMove(client, body, _tgPos);
            else
                AligntToTarget(client, myEnemy);
            int blocker = 0;
            if (PetLOS(client, body, myEnemy, blocker))
            {
                g_FlankUntil[client] = 0.0;   // linea de tiro recuperada: fin del flanqueo
                // ---- v2.6: mientras la lengua arrastra a una presa, la nave NO
                // la ametralla (la castiga la lengua: ticks + latigazo final);
                // misiles y granadas siguen funcionando con normalidad ------
                int tongueVictim = (g_TongueRef[client] != -1) ? EntRefToEntIndex(g_TongueRef[client]) : -1;

                // ---- disciplina de tiro --------------------------------
                if (tongueVictim != myEnemy)
                    FireWeaponByMode(client, body, myEnemy, _tgPos);

                // ---- lengua de smoker (v2.6): SOLO infectados especiales ----
                TrySmokerTongue(client, body, myEnemy);

                // ---- misiles automaticos -------------------------------
                if (GetGameTime() >= g_NextMissileAt[client])
                {
                    int styleId = g_PetMissile[client];
                    if (styleId == MSTYLE_RANDOM)
                        styleId = GetRandomInt(0, 9);   // Aleatorio: cada salva sorprende
                    float cd = g_Styles[styleId].cooldown * PetCDMult(client);
                    // vs Tank: cadencia doble
                    if (myEnemy <= MaxClients && IsClientInGame(myEnemy) && GetEntProp(myEnemy, Prop_Send, "m_zombieClass") == 8)
                        cd *= 0.5;
                    g_NextMissileAt[client] = GetGameTime() + cd;
                    // disciplina de tiro: solo las explosiones gigantes (radio >= 300)
                    // esperan a que el objetivo no este pegado a un compañero; el dano
                    // de area del pet nunca afecta al equipo, asi el resto dispara libre
                    if (g_Styles[styleId].laser
                        || g_Styles[styleId].radius < 300.0
                        || MissileSafeForTeam(_tgPos, g_Styles[styleId].radius * 0.5))
                        PetFireMissile(client, styleId, myEnemy);
                }

                // ---- granadas automaticas: efecto aleatorio al detonar ------
                if (g_PetGrenade[client] && g_grenadesOn
                    && GetGameTime() >= g_NextGrenadeAt[client]
                    && GetVectorDistance(_tgPos, _jtPos) > 120.0
                    && GetEntityCount() < MAX_EDICTS_SAFE)
                {
                    g_NextGrenadeAt[client] = GetGameTime() + PetGrenadeCD(client);
                    LaunchGrenade(client, body, myEnemy, _tgPos, -1);   // -1 = efecto aleatorio
                    if (g_PetLevel[client] >= 50)   // Nv 50: doble granada por tanda
                        CreateTimer(0.5, Timer_SecondGrenade, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
                    PrintToChat(client, "%s \x04Granada lanzada\x05: efecto sorpresa al detonar...", CHAT_PREFIX);
                }
            }
            else if (blocker != 0 && blocker != -1 && IsValidEntity(blocker) && IsPetEnemy(blocker) && IsEnemyAlive(blocker))
            {
                g_FlankUntil[client] = 0.0;
                // algo se interpone: si es un infectado, lo tomamos como nuevo objetivo
                g_PetTarget[client] = EntIndexToEntRef(blocker);
                g_TargetSince[client] = GetGameTime();
            }
            else
            {
                // muro en medio: MANIOBRA DE FLANQUEO en vez de quedarse mirando
                float nowT = GetGameTime();
                if (g_FlankUntil[client] == 0.0)
                {
                    // entra en flanqueo: orbita el objetivo buscando linea de tiro
                    g_FlankUntil[client] = nowT + PET_FLANK_TIME;
                    g_FlankDir[client] = (GetRandomInt(0, 1) == 1) ? 1 : -1;
                }
                else if (nowT > g_FlankUntil[client])
                {
                    // flanqueo agotado sin linea: soltar objetivo e ignorarlo 2s
                    g_IgnoreTarget[client] = EntIndexToEntRef(myEnemy);
                    g_IgnoreUntil[client] = nowT + 2.0;
                    g_PetTarget[client] = -1;
                    g_FlankUntil[client] = 0.0;
                }
                else
                {
                    FlankMove(client, body, _tgPos);
                }
            }
        }
        return Plugin_Continue;
    }

    // ---- sin enemigo: modo ESPERA o seguimiento de la duena ----------------
    float OurDist = GetVectorDistance(_clPos, _jtPos);

    // modo "quedate aqui" (!petstay): orbita el punto de espera; si la duena se
    // aleja demasiado lo cancela solo para no perderse jamas
    if (g_PetHold[client])
    {
        if (GetVectorDistance(_clPos, g_PetHoldPos[client]) > 1600.0)
        {
            g_PetHold[client] = false;
            PrintToChat(client, "%s Modo espera cancelado: te alejaste mucho, la nave regresa.", CHAT_PREFIX);
            FollowTarget(client, client);
        }
        else
        {
            HoldPosition(client);
        }
        return Plugin_Continue;
    }

    if (g_PetFollow[client])
    {
        if (OurDist < PET_MINDISTANCE)
            g_PetFollow[client] = false;
        FollowTarget(client, client);
    }
    else
    {
        if (OurDist >= 1000.0 && GetGameTime() - g_LastHadTarget[client] > 1.5)
        {
            // v3.1: recuperacion REAL — sin objetivo hace 1.5 s y a mas de
            // 1000 u: la nave estaba perdida de verdad. Unico teleport
            // permitido, siempre con el cuerpo a nivel (pitch 0)
            _clAng[0] = 0.0;
            SetPetBank(client, 0.0);
            TeleportEntity(body, _clPos, _clAng, NULL_VECTOR);
            return Plugin_Continue;
        }
        else if (OurDist >= 1000.0)
        {
            // v3.1: transicion de combate (acaba de soltar un objetivo en el
            // borde del rango): VUELA de vuelta junto a la duena en vez de
            // teletransportarse — fix del "aparece y desaparece"
            g_PetFollow[client] = true;
        }
        else if (OurDist > 650.0)
        {
            g_PetFollow[client] = true;
        }
        else
        {
            HooveringArea(client);
        }
    }
    return Plugin_Continue;
}

// ---------------------------------------------------------------------------
// Escaneo de enemigos con prioridades: Tank > Charger > Smoker > ... > Witch > comunes
// ---------------------------------------------------------------------------
int GetClassWeight(int client)
{
    switch (GetEntProp(client, Prop_Send, "m_zombieClass"))
    {
        case 8: return 90;   // tank
        case 6: return 70;   // charger
        case 1: return 60;   // smoker
        case 3: return 55;   // hunter
        case 4: return 50;   // spitter
        case 5: return 45;   // jockey
        case 2: return 40;   // boomer
    }
    return 30;
}

int ScanEnemy(int client, int currentEnemy, float engage)
{
    float wgPos[3], ddPos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", wgPos);

    // punto de vista del pet (vuela por delante del dueno): amplia la vision
    CopyVector(wgPos, g_fScanPetPos);
    g_fScanEngage = engage;
    int scanPet = (g_PetBody[client] != -1) ? EntRefToEntIndex(g_PetBody[client]) : -1;
    if (scanPet != -1 && IsValidEntity(scanPet))
    {
        GetEntPropVector(scanPet, Prop_Send, "m_vecOrigin", g_fScanPetPos);
        g_fScanPetPos[2] -= BODY_HEIGHT;
    }

    int best = -1;
    int bestScore = -100000;
    int score;
    float dist;

    // 1) infectados especiales (jugadores del equipo 3)
    int ignoreIdx = -1;
    if (g_IgnoreTarget[client] != -1 && GetGameTime() < g_IgnoreUntil[client])
        ignoreIdx = EntRefToEntIndex(g_IgnoreTarget[client]);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == ignoreIdx) continue;
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3
            && GetEntProp(i, Prop_Data, "m_iHealth") > 0)
        {
            GetEntPropVector(i, Prop_Send, "m_vecOrigin", ddPos);
            dist = EffectiveScanDist(ddPos, wgPos);
            if (dist <= engage)
            {
                score = GetClassWeight(i) * 10 - RoundToFloor(dist / 10.0);
                if (i == currentEnemy) score += 60;   // evita flip-flop
                if (PetPinningVictim(i) != -1) score += 500;   // tiene a alguien atrapado: prioridad
                if (score > bestScore) { bestScore = score; best = i; }
            }
        }
    }
    if (best != -1) return best;

    // 2) witch (por debajo de cualquier especial)
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent) || ent == ignoreIdx) continue;
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", ddPos);
        dist = EffectiveScanDist(ddPos, wgPos);
        if (dist <= engage)
        {
            score = 250 - RoundToFloor(dist / 10.0);
            if (ent == currentEnemy) score += 60;
            if (score > bestScore) { bestScore = score; best = ent; }
        }
    }
    if (best != -1) return best;

    // 3) comunes (el mas cercano)
    ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent) || ent == ignoreIdx) continue;
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", ddPos);
        dist = EffectiveScanDist(ddPos, wgPos);
        if (dist <= engage)
        {
            score = 100 - RoundToFloor(dist / 10.0);
            if (ent == currentEnemy) score += 60;
            if (score > bestScore) { bestScore = score; best = ent; }
        }
    }
    return best;
}

// ---------------------------------------------------------------------------
// LOS real: traza desde el F18 hasta el objetivo
// ---------------------------------------------------------------------------
bool PetLOS(int client, int body, int target, int &blocker)
{
    float start[3], end[3];
    GetEntPropVector(body, Prop_Send, "m_vecOrigin", start);
    start[2] -= BODY_HEIGHT;   // posicion del F18 visible
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", end);
    end[2] += (target <= MaxClients) ? 40.0 : 30.0;

    float dir[3], ang[3];
    MakeVectorFromPoints(start, end, dir);
    GetVectorAngles(dir, ang);

    g_iTracePetBody = body;
    g_iTracePetModel = EntRefToEntIndex(g_PetModel[client]);
    g_iTracePetExhaust = EntRefToEntIndex(g_PetExhaust[client]);

    Handle trace = TR_TraceRayFilterEx(start, ang, MASK_SHOT, RayType_Infinite, TraceFilter_PetLOS, 0);
    bool result = true;
    blocker = 0;
    if (TR_DidHit(trace))
    {
        blocker = TR_GetEntityIndex(trace);
        result = (blocker == target);
    }
    CloseHandle(trace);
    return result;
}

public bool TraceFilter_PetLOS(int entity, int contentsMask, any data)
{
    // OJO SourceMod: el filtro de traza devuelve TRUE = la entidad BLOQUEA la traza
    // (la traza impacta en ella) y FALSE = la traza la ignora y pasa de largo.
    // (v2.1: esta funcion estaba invertida y el pet nunca veia a sus objetivos)
    if (entity > 0 && entity <= MaxClients)
    {
        if (IsClientInGame(entity) && GetClientTeam(entity) == 2)
            return false;   // el dueno y los compañeros no bloquean la linea de tiro
        return true;        // infectados especiales: solidos
    }
    if (entity == g_iTracePetBody || entity == g_iTracePetModel || entity == g_iTracePetExhaust)
        return false;       // el propio pet (cuerpo, F18 visible y estela) nunca se interpone
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_PetBody[i] == -1) continue;
        int other = EntRefToEntIndex(g_PetBody[i]);
        if (other == -1) continue;
        if (entity == other) return false;
        if (g_PetModel[i] != -1 && EntRefToEntIndex(g_PetModel[i]) == entity) return false;
        if (g_PetExhaust[i] != -1 && EntRefToEntIndex(g_PetExhaust[i]) == entity) return false;
    }
    if (entity > 0 && entity < 2048 && g_MissileStyle[entity] != -1)
        return false;       // misiles en vuelo (de cualquier pet): la traza pasa
    if (entity > 0 && entity < 2048 && g_GrenadeOwner[entity] != -1)
        return false;       // granadas del pet en vuelo: tampoco la bloquean
    return true;            // comunes, witch, props y MUNDO: solidos (bloquean)
}

// ---------------------------------------------------------------------------
// Movimiento: perseguir / alinear / sobrevolar (adaptado con 3 comportamientos)
// ---------------------------------------------------------------------------
void GetAISpeeds(int client, float &chaseSpeed, float &turnSpeed)
{
    // v3.0: velocidad de movimiento aumentada (~+40%): la nave acompana
    // mejor a la duena y persigue mas rapido (pedido del usuario)
    switch (g_PetAIMode[client])
    {
        case 0: { chaseSpeed = 450.0; turnSpeed = 265.0; }   // agresivo
        case 2: { chaseSpeed = 210.0; turnSpeed = 125.0; }   // defensivo
        default: { chaseSpeed = 320.0; turnSpeed = 170.0; }  // normal
    }
}

void FollowTarget(int client, int target)
{
    int Pet_0 = EntRefToEntIndex(g_PetBody[client]);
    if (Pet_0 == -1 || !IsValidEntity(Pet_0)) return;
    if (target < 1 || (target != client && !IsValidEntity(target)))
        target = client;

    float hoverZ = g_petheight;
    if (g_PetAIMode[client] == 0) hoverZ = g_petheight * 0.7;   // agresivo vuela mas bajo
    if (g_PetAIMode[client] == 2) hoverZ = g_petheight * 1.3;   // defensivo vuela mas alto

    bool sSwitch = false;
    float visPitch = 0.0;   // v3.1: vuelco VISUAL del F18 (el cuerpo nunca picha)
    float mmOrg[3], mmAng[3], mmVel[3], mmBff[3], _mmBff[3];
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", mmBff);
    GetEntPropVector(Pet_0, Prop_Send, "m_vecOrigin", mmOrg);
    GetEntPropVector(Pet_0, Prop_Data, "m_angRotation", mmAng);
    mmOrg[2] -= BODY_HEIGHT;
    mmBff[2] += hoverZ;

    if (GetAngleBetweenVector(Pet_0, target) > 30.0)
    {
        if (g_PetDirection[client]) mmAng[1] += 20.0;
        else mmAng[1] -= 20.0;
        sSwitch = true;
    }
    else
    {
        if (GetVectorDistance(mmOrg, mmBff) > PET_MINDISTANCE)
        {
            MakeVectorFromPoints(mmOrg, mmBff, _mmBff);
            NormalizeVector(_mmBff, _mmBff);
            GetVectorAngles(_mmBff, mmAng);
        }
    }

    if (mmOrg[2] < mmBff[2])
    {
        mmAng[0] = -10.0;
        visPitch = -10.0;   // v3.1: trepando (visual)
        GetAngleVectors(mmAng, mmVel, NULL_VECTOR, NULL_VECTOR);
        NormalizeVector(mmVel, mmVel);
        mmAng[0] = 0.0;
    }
    else if (mmOrg[2] > (mmBff[2] + PET_INCR_HEIGHT))
    {
        mmAng[0] = 10.0;
        visPitch = 10.0;    // v3.1: descendiendo (visual)
        GetAngleVectors(mmAng, mmVel, NULL_VECTOR, NULL_VECTOR);
        NormalizeVector(mmVel, mmVel);
        mmAng[0] = 0.0;
    }
    else
    {
        mmAng[0] = 0.0;
        GetAngleVectors(mmAng, mmVel, NULL_VECTOR, NULL_VECTOR);
        NormalizeVector(mmVel, mmVel);
    }

    float chaseSpeed, turnSpeed;
    GetAISpeeds(client, chaseSpeed, turnSpeed);
    if (sSwitch) ScaleVector(mmVel, turnSpeed);
    else ScaleVector(mmVel, chaseSpeed);

    TeleportEntity(Pet_0, NULL_VECTOR, mmAng, mmVel);
    SetPetBank(client, visPitch);   // v3.1: vuelco visual en el MODELO
}

void AligntToTarget(int client, int target)
{
    int subject = EntRefToEntIndex(g_PetBody[client]);
    if (subject == -1 || !IsValidEntity(subject)) return;

    float subPos[3], cliPos[3], subAng[3], tarPos[3], tarVol[3], buFF[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", cliPos);
    GetEntPropVector(subject, Prop_Send, "m_vecOrigin", subPos);
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", tarPos);
    cliPos[2] += g_petheight;
    subPos[2] -= BODY_HEIGHT;

    MakeVectorFromPoints(subPos, tarPos, buFF);
    NormalizeVector(buFF, buFF);
    GetVectorAngles(buFF, subAng);

    float visPitch = 0.0;   // v3.1: vuelco VISUAL del F18 (el cuerpo nunca picha)
    if (subPos[2] < cliPos[2])
    {
        subAng[0] = -80.0;
        GetAngleVectors(subAng, tarVol, NULL_VECTOR, NULL_VECTOR);
        NormalizeVector(tarVol, tarVol);
        // v3.1: correccion vertical REAL (60 u/s; antes 10): la nave regresa
        // rapido a la banda de vuelo de 15 u en vez de rondar el borde
        ScaleVector(tarVol, 60.0);
        subAng[0] = 0.0;
        visPitch = -12.0;   // trepando hacia la banda (visual)
    }
    else if (subPos[2] > (cliPos[2] + PET_INCR_HEIGHT))
    {
        subAng[0] = 80.0;
        GetAngleVectors(subAng, tarVol, NULL_VECTOR, NULL_VECTOR);
        NormalizeVector(tarVol, tarVol);
        ScaleVector(tarVol, 60.0);   // v3.1: correccion vertical real
        subAng[0] = 0.0;
        visPitch = 12.0;    // bajando hacia la banda (visual)
    }
    else
    {
        subAng[0] = 0.0;
        GetAngleVectors(subAng, tarVol, NULL_VECTOR, NULL_VECTOR);
        NormalizeVector(tarVol, tarVol);
        ScaleVector(tarVol, 1.0);
    }

    // deriva lateral de combate: la nave esquiva mientras dispara
    if (GetGameTime() > g_StrafeUntil[client])
    {
        g_StrafeUntil[client] = GetGameTime() + 1.5;
        g_StrafeDir[client] = (GetRandomInt(0, 1) == 1) ? 1 : -1;
    }
    float rtRight[3];
    GetAngleVectors(subAng, NULL_VECTOR, rtRight, NULL_VECTOR);
    rtRight[2] = 0.0;
    NormalizeVector(rtRight, rtRight);
    ScaleVector(rtRight, 90.0 * float(g_StrafeDir[client]));
    AddVectors(tarVol, rtRight, tarVol);

    TeleportEntity(subject, NULL_VECTOR, subAng, tarVol);
    SetPetBank(client, visPitch);   // v3.1: vuelco visual en el MODELO
}


float GetAngleBetweenVector(int subject, int target)
{
    float ang[3], vec[3], targetPos[3], fwd[3];
    GetEntPropVector(subject, Prop_Data, "m_angRotation", ang);
    GetEntPropVector(subject, Prop_Send, "m_vecOrigin", vec);
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPos);
    ang[0] = 0.0;

    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
    vec[0] = targetPos[0] - vec[0];
    vec[1] = targetPos[1] - vec[1];
    vec[2] = 0.0;
    fwd[2] = 0.0;
    NormalizeVector(fwd, fwd);

    float dist = SquareRoot(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2]);
    if (dist == 0.0) dist = 0.1;
    ScaleVector(vec, 1.0 / dist);

    return RadToDeg(ArcCosine(vec[0] * fwd[0] + vec[1] * fwd[1] + vec[2] * fwd[2]));
}

void RotateAdvance(int ent, float value, int axis)
{
    if (IsValidEntity(ent))
    {
        float rotate_[3];
        GetEntPropVector(ent, Prop_Data, "m_angRotation", rotate_);
        rotate_[axis] += value;
        TeleportEntity(ent, NULL_VECTOR, rotate_, NULL_VECTOR);
    }
}

// ---------------------------------------------------------------------------
// RUTAS DE VUELO, FLANQUEO Y UTILIDADES DE IA
// ---------------------------------------------------------------------------
void PetStyleName(int client, char[] out, int maxlen)
{
    if (g_PetMissile[client] == MSTYLE_RANDOM)
    {
        strcopy(out, maxlen, "Aleatorio");
        return;
    }
    strcopy(out, maxlen, g_Styles[g_PetMissile[client]].name);
}

// distancia efectiva de escaneo: cuenta el punto de vista del pet (vuela adelante)
float EffectiveScanDist(const float ddPos[3], const float wgPos[3])
{
    float d = GetVectorDistance(wgPos, ddPos);
    if (d > g_fScanEngage)
    {
        float d2 = GetVectorDistance(g_fScanPetPos, ddPos);
        if (d2 < d) d = d2;
    }
    return d;
}

void MaybeAnnounceHighThreat(int client, int enemy)
{
    if (!IsValidClient(client) || enemy <= 0 || !IsValidEntity(enemy)) return;

    char threat[16];
    if (enemy <= MaxClients)
    {
        if (IsClientInGame(enemy) && GetEntProp(enemy, Prop_Send, "m_zombieClass") == 8)
            strcopy(threat, sizeof(threat), "TANK");
        else
            return;
    }
    else
    {
        char cls[16];
        GetEntityClassname(enemy, cls, sizeof(cls));
        if (StrEqual(cls, "witch")) strcopy(threat, sizeof(threat), "WITCH");
        else
            return;
    }

    int ref = EntIndexToEntRef(enemy);
    if (g_AnnouncedRef[client] == ref) return;
    g_AnnouncedRef[client] = ref;
    PrintToChat(client, "%s !\x04%s\x05 en la mira! Prioridad maxima.", CHAT_PREFIX, threat);
}

// maniobra de flanqueo: orbita el ultimo punto conocido buscando linea de tiro,
// en vez de quedarse plantado mirando el muro (fix del "se queda viendo no mas")
void FlankMove(int client, int body, const float lkp[3])
{
    float petPos[3];
    GetEntPropVector(body, Prop_Send, "m_vecOrigin", petPos);
    petPos[2] -= BODY_HEIGHT;

    // eje horizontal objetivo -> pet
    float axis[3];
    axis[0] = petPos[0] - lkp[0];
    axis[1] = petPos[1] - lkp[1];
    axis[2] = 0.0;
    float len = GetVectorLength(axis);
    if (len < 1.0)
    {
        axis[0] = 1.0;
        axis[1] = 0.0;
        axis[2] = 0.0;
        len = 1.0;
    }
    if (len < 160.0)
        g_FlankDir[client] = -g_FlankDir[client];

    ScaleVector(axis, 1.0 / len);

    // perpendicular: sentido de giro del flanqueo
    float perp[3];
    perp[0] = -axis[1] * float(g_FlankDir[client]);
    perp[1] =  axis[0] * float(g_FlankDir[client]);
    perp[2] = 0.0;

    // movimiento: lateral sobre el eje + acercamiento parcial al objetivo
    float move[3];
    move[0] = perp[0] - axis[0] * 0.35;
    move[1] = perp[1] - axis[1] * 0.35;
    move[2] = 0.0;
    NormalizeVector(move, move);

    float hoverZ = g_petheight;
    if (g_PetAIMode[client] == 0) hoverZ = g_petheight * 0.7;
    if (g_PetAIMode[client] == 2) hoverZ = g_petheight * 1.3;

    // gana algo de altura durante el flanqueo para ver por encima del muro
    float wantZ = lkp[2] + hoverZ + 50.0;
    float dz = wantZ - petPos[2];

    float chaseSpeed, turnSpeed;
    GetAISpeeds(client, chaseSpeed, turnSpeed);
    chaseSpeed *= 0.8;

    float vel[3], ang[3];
    vel[0] = move[0] * chaseSpeed;
    vel[1] = move[1] * chaseSpeed;
    vel[2] = 0.0;
    float visPitch = 0.0;   // v3.1: vuelco VISUAL del F18 (el cuerpo nunca picha)
    if (dz > 30.0) { vel[2] = 120.0; visPitch = -12.0; }
    else if (dz < -30.0) { vel[2] = -120.0; visPitch = 12.0; }

    GetVectorAngles(vel, ang);
    // v3.1 FIX DEL PARPADEO: el cuerpo fisico (con el F18 colgado 3000 u
    // abajo) JAMAS recibe pitch — el viejo clamp de +-60 desplazaba al avion
    // visible ~2600 u de golpe. El cuerpo solo gira en yaw.
    ang[0] = 0.0;
    TeleportEntity(body, NULL_VECTOR, ang, vel);
    SetPetBank(client, visPitch);
}

// ---------------------------------------------------------------------------
// RUTAS DE VUELO EN REPOSO (orbita / balanceo / patrulla / aleatoria)
// ---------------------------------------------------------------------------
void HooveringArea(int client)
{
    int Pet_0 = EntRefToEntIndex(g_PetBody[client]);
    if (Pet_0 == -1 || !IsValidEntity(Pet_0)) return;

    // ruta activa (la aleatoria rota sola cada 10 s)
    int route = g_PetRoute[client];
    if (route == PETROUTE_ALEATORIA)
    {
        float now = GetGameTime();
        if (now > g_RouteNextSwap[client])
        {
            g_RouteCur[client] = GetRandomInt(0, 2);
            g_RouteNextSwap[client] = now + 10.0;
        }
        route = g_RouteCur[client];
    }

    float oPos[3], oAng[3], fwd[3], right[3], petPos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", oPos);
    GetEntPropVector(client, Prop_Data, "m_angRotation", oAng);
    GetEntPropVector(Pet_0, Prop_Send, "m_vecOrigin", petPos);
    petPos[2] -= BODY_HEIGHT;

    oAng[0] = 0.0;
    GetAngleVectors(oAng, fwd, right, NULL_VECTOR);

    float hoverZ = g_petheight;
    if (g_PetAIMode[client] == 0) hoverZ = g_petheight * 0.7;
    if (g_PetAIMode[client] == 2) hoverZ = g_petheight * 1.3;

    float wp[3];
    switch (route)
    {
        case PETROUTE_ORBITA:
        {
            g_RoutePhase[client] += 0.12;   // ~0.6 rad/s: vuelta completa en 10 s
            wp[0] = oPos[0] + Cosine(g_RoutePhase[client]) * 300.0;
            wp[1] = oPos[1] + Sine(g_RoutePhase[client]) * 300.0;
            wp[2] = oPos[2] + hoverZ;
        }
        case PETROUTE_BALANCEO:
        {
            if (GetGameTime() > g_RouteFlipUntil[client])
            {
                g_RouteSide[client] = -g_RouteSide[client];
                g_RouteFlipUntil[client] = GetGameTime() + 1.6;
            }
            float side = float(g_RouteSide[client]);
            wp[0] = oPos[0] + fwd[0] * 180.0 + right[0] * side * 330.0;
            wp[1] = oPos[1] + fwd[1] * 180.0 + right[1] * side * 330.0;
            wp[2] = oPos[2] + hoverZ;
        }
        case PETROUTE_PATRULLA:
        {
            if (GetGameTime() > g_RouteFlipUntil[client])
            {
                g_RouteSide[client] = -g_RouteSide[client];
                g_RouteFlipUntil[client] = GetGameTime() + 2.6;
            }
            float ahead = (g_RouteSide[client] > 0) ? 560.0 : -220.0;
            wp[0] = oPos[0] + fwd[0] * ahead + right[0] * 60.0;
            wp[1] = oPos[1] + fwd[1] * ahead + right[1] * 60.0;
            wp[2] = oPos[2] + hoverZ;
        }
    }

    // virar hacia el waypoint de la ruta
    float dir[3], vel[3], ang[3];
    MakeVectorFromPoints(petPos, wp, dir);
    float dist = GetVectorLength(dir);
    NormalizeVector(dir, dir);

    float speed = 210.0;
    if (g_PetAIMode[client] == 0) speed = 260.0;
    else if (g_PetAIMode[client] == 2) speed = 150.0;
    if (dist < 80.0) speed = 60.0;   // cerca del waypoint: paseo suave

    vel[0] = dir[0] * speed;
    vel[1] = dir[1] * speed;
    vel[2] = 0.0;
    float visPitch = 0.0;   // v3.1: vuelco VISUAL del F18 (el cuerpo nunca picha)
    if (dir[2] > 0.15) { vel[2] = 100.0; visPitch = -12.0; }
    else if (dir[2] < -0.15) { vel[2] = -100.0; visPitch = 12.0; }

    GetVectorAngles(vel, ang);
    ang[0] = 0.0;   // v3.1: cuerpo sin pitch (fix del parpadeo)
    TeleportEntity(Pet_0, NULL_VECTOR, ang, vel);
    SetPetBank(client, visPitch);
}

// ---------------------------------------------------------------------------
// ARMAS: 0 Metralleta | 1 Escopeta | 2 Flamegun
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// ARMAS v2.3: 0 Metralleta | 1 Escopeta | 2 Flamegun | 3 Francotirador |
// 4 Minigun | 5 Laser | 6 Arco Tesla | 7 Plasma | 8 Railgun | 9 Cohetera
// (las 7 ultimas se desbloquean con nivel: 5/15/25/35/45/60/80)
// ---------------------------------------------------------------------------
void FireWeaponByMode(int client, int body, int target, const float targetPos[3])
{
    float now = GetGameTime();
    int mode = g_PetWeapon[client];

    float interval;
    switch (mode)
    {
        case WPN_SHOTGUN:  interval = 0.8;    // escopeta
        case WPN_FLAME:    interval = 0.4;    // flamegun
        case WPN_SNIPER:   interval = 1.4;    // francotirador
        case WPN_MINIGUN:  interval = 0.06;   // minigun
        case WPN_LASER:    interval = 0.16;   // laser continuo
        case WPN_TESLA:    interval = 0.5;    // arco tesla
        case WPN_PLASMA:   interval = 1.1;    // canon de plasma
        case WPN_RAILGUN:  interval = 2.2;    // railgun
        case WPN_COHETERA: interval = 1.6;    // cohetera
        case WPN_CRYO:      interval = 0.30;  // criogenico
        case WPN_GRANADERO: interval = 1.0;   // lanzagranadas
        case WPN_GAUSS:     interval = 1.8;   // rifle gauss
        case WPN_SOLAR:     interval = 0.22;  // canon solar
        case WPN_PULSO:     interval = 0.70;  // canon de pulso
        case WPN_ARC2:      interval = 0.42;  // arco cruzado
        case WPN_CLUSTERMG: interval = 1.30;  // canon cluster
        case WPN_FRAG:      interval = 1.50;  // fragmentacion
        case WPN_VACIO:     interval = 1.30;  // vacio
        case WPN_SEEKERS:   interval = 2.30;  // buscadores
        case WPN_ANTIMAT:   interval = 2.50;  // antimateria
        case WPN_ESTELAR:   interval = 2.00;  // estelar
        default:
        {
            // metralleta por rachas de 3 balas: cadencia realista y letal
            if (g_GunBurstLeft[client] > 0)
            {
                interval = 0.07;
                g_GunBurstLeft[client]--;
            }
            else
            {
                interval = 0.42;
                g_GunBurstLeft[client] = 2;
            }
        }
    }
    interval *= PetGunIntervalMult(client);
    if (now < g_NextBulletAt[client]) return;
    g_NextBulletAt[client] = now + interval;

    switch (mode)
    {
        case WPN_SHOTGUN:  FireShotgun(client, body, target, targetPos);
        case WPN_FLAME:    FireFlamegun(client, body, targetPos);
        case WPN_SNIPER:   FireSniper(client, body, target, targetPos);
        case WPN_MINIGUN:  FireMinigun(client, body, target, targetPos);
        case WPN_LASER:    FireLaserBeam(client, body, target, targetPos);
        case WPN_TESLA:    FireTeslaGun(client, body, target, targetPos);
        case WPN_PLASMA:   PetFireMissile(client, MSTYLE_PLASMA, target);
        case WPN_RAILGUN:  FireRailgun(client, body, targetPos);
        case WPN_COHETERA: PetFireMissile(client, MSTYLE_ROCKET, target);
        case WPN_CRYO:      FireCryo(client, body, target, targetPos);
        case WPN_GRANADERO: FireGrenadero(client, body, targetPos);
        case WPN_GAUSS:     FireGauss(client, body, target, targetPos);
        case WPN_SOLAR:     FireSolar(client, body, target, targetPos);
        case WPN_PULSO:     FirePulse(client, body, target, targetPos);
        case WPN_ARC2:      FireArc2(client, body, target, targetPos);
        case WPN_CLUSTERMG: FireClusterMG(client, body, targetPos);
        case WPN_FRAG:      FireFrag(client, body, target, targetPos);
        case WPN_VACIO:     FireVacio(client, body, target, targetPos);
        case WPN_SEEKERS:   FireSeekers(client, body, target);
        case WPN_ANTIMAT:   FireAntimateria(client, body, target, targetPos);
        case WPN_ESTELAR:   FireEstelar(client, body, target, targetPos);
        default:            FireBullet(client, body, target, targetPos);
    }
}

// ---------------------------------------------------------------------------
// FRANCOTIRADOR (Nv 5): tiro preciso de alto dano con criticos
// ---------------------------------------------------------------------------
void FireSniper(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    float dmg = 85.0 * PetGunMult(client);
    bool crit = (GetRandomInt(1, 100) <= 20);
    if (crit) dmg *= 2.0;

    int beam[4] = {150, 220, 255, 255};
    PetBeam(muzzle, tPos, beam, 2.5, 0.22);
    PetBloodAt(tPos);
    PetDamage(target, client, dmg, DMG_BULLET);

    if (crit && IsValidClient(client))
        PrintToChat(client, "%s \x04Impacto critico\x05 del francotirador (%.0f de dano).", CHAT_PREFIX, dmg);

    float ang[3];
    MakeVectorFromPoints(muzzle, tPos, ang);
    GetVectorAngles(ang, ang);
    TE_SetupMuzzleFlash(muzzle, ang, 2.0, 1);
    TE_SendToAll();
    EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.75, 140);
}

// ---------------------------------------------------------------------------
// MINIGUN (Nv 15): chorro continuo de balas
// ---------------------------------------------------------------------------
void FireMinigun(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;
    tPos[0] += GetRandomFloat(-35.0, 35.0);
    tPos[1] += GetRandomFloat(-35.0, 35.0);

    int color[4] = {255, 230, 140, 255};
    PetBeam(muzzle, tPos, color, 1.0, 0.06);
    PetBloodAt(tPos);
    PetDamage(target, client, 6.0 * PetGunMult(client), DMG_BULLET);

    // el sonido se limita para no saturar (el disparo es cada 0.06 s)
    float now = GetGameTime();
    if (now - g_LastShotAt[client] > 0.15)
    {
        g_LastShotAt[client] = now;
        EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.5, 80);
    }
}

// ---------------------------------------------------------------------------
// LASER (Nv 25): rayo continuo con dano de area alrededor del impacto
// ---------------------------------------------------------------------------
void FireLaserBeam(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    int core[4] = {255, 255, 255, 255};
    int beam[4] = {255, 60, 60, 255};
    PetBeam(muzzle, tPos, beam, 3.0, 0.16);
    PetBeam(muzzle, tPos, core, 1.0, 0.14);

    PetDamage(target, client, 16.0 * PetGunMult(client), DMG_BULLET);

    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(tPos, 70.0, enemies);
    for (int i = 0; i < enemies.Length; i++)
    {
        int victim = enemies.Get(i);
        if (victim != target)
            PetDamage(victim, client, 8.0 * PetGunMult(client), DMG_BULLET);
    }
    delete enemies;

    float now = GetGameTime();
    if (now - g_LastShotAt[client] > 0.3)
    {
        g_LastShotAt[client] = now;
        EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.35, 220);
    }
}

// ---------------------------------------------------------------------------
// ARCO TESLA (Nv 35): cadena electrica que salta hasta 4 enemigos
// ---------------------------------------------------------------------------
void FireTeslaGun(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(tPos, 300.0, enemies);
    if (target > 0 && IsValidEntity(target) && IsEnemyAlive(target))
    {
        bool hasTarget = false;
        for (int i = 0; i < enemies.Length; i++)
        {
            if (enemies.Get(i) == target) { hasTarget = true; break; }
        }
        if (!hasTarget) enemies.Push(target);
    }

    int color[4] = {160, 220, 255, 255};
    float prev[3], zapPos[3];
    CopyVector(muzzle, prev);
    int zapped = 0;

    while (zapped < 4 && enemies.Length > 0)
    {
        int best = -1, bestIdx = -1;
        float bestD = 999999.0;
        for (int i = 0; i < enemies.Length; i++)
        {
            int victim = enemies.Get(i);
            if (victim <= 0 || !IsValidEntity(victim) || !IsEnemyAlive(victim)) continue;
            float vPos[3];
            GetEntPropVector(victim, Prop_Send, "m_vecOrigin", vPos);
            float d = GetVectorDistance(prev, vPos);
            if (d < bestD) { bestD = d; best = victim; bestIdx = i; }
        }
        if (best == -1) break;

        GetEntPropVector(best, Prop_Send, "m_vecOrigin", zapPos);
        zapPos[2] += 40.0;
        PetBeam(prev, zapPos, color, 1.5, 0.14);
        PetBloodAt(zapPos);
        PetDamage(best, client, 26.0 * PetGunMult(client), DMG_BULLET);
        CopyVector(zapPos, prev);
        if (bestIdx >= 0) enemies.Erase(bestIdx);
        zapped++;
    }
    delete enemies;

    float now = GetGameTime();
    if (now - g_LastShotAt[client] > 0.25)
    {
        g_LastShotAt[client] = now;
        EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.55, 240);
    }
}

// ---------------------------------------------------------------------------
// RAILGUN (Nv 60): disparo perforante que atraviesa todo lo alineado
// ---------------------------------------------------------------------------
void FireRailgun(int client, int body, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    float dir[3];
    MakeVectorFromPoints(muzzle, tPos, dir);
    NormalizeVector(dir, dir);
    float end[3];
    end[0] = muzzle[0] + dir[0] * 2400.0;
    end[1] = muzzle[1] + dir[1] * 2400.0;
    end[2] = muzzle[2] + dir[2] * 2400.0;

    int beam[4] = {80, 255, 255, 255};
    int core[4] = {255, 255, 255, 255};
    PetBeam(muzzle, end, beam, 8.0, 0.45);
    PetBeam(muzzle, end, core, 2.5, 0.40);

    float ang[3];
    GetVectorAngles(dir, ang);
    TE_SetupMuzzleFlash(muzzle, ang, 3.0, 1);
    TE_SendToAll();

    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(muzzle, 2400.0, enemies);
    int hits = 0;
    for (int i = 0; i < enemies.Length && hits < 8; i++)
    {
        int en = enemies.Get(i);
        if (en <= 0 || !IsValidEntity(en)) continue;
        float vPos[3];
        GetEntPropVector(en, Prop_Send, "m_vecOrigin", vPos);
        vPos[2] += 40.0;

        // proyeccion del enemigo sobre la linea de tiro
        float rel[3], closest[3];
        rel[0] = vPos[0] - muzzle[0];
        rel[1] = vPos[1] - muzzle[1];
        rel[2] = vPos[2] - muzzle[2];
        float t = rel[0] * dir[0] + rel[1] * dir[1] + rel[2] * dir[2];
        if (t < 0.0 || t > 2400.0) continue;
        closest[0] = muzzle[0] + dir[0] * t;
        closest[1] = muzzle[1] + dir[1] * t;
        closest[2] = muzzle[2] + dir[2] * t;
        if (GetVectorDistance(vPos, closest) < 95.0)
        {
            PetBloodAt(vPos);
            PetDamage(en, client, 90.0 * PetGunMult(client), DMG_BULLET);
            hits++;
        }
    }
    delete enemies;

    float now = GetGameTime();
    if (now - g_LastShotAt[client] > 0.3)
    {
        g_LastShotAt[client] = now;
        EmitSoundToAll(SND_MISSILE2, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.5, 60);
    }
}


// ---------------------------------------------------------------------------
// v2.4: DOCE ARMAS NUEVAS (el arsenal llega a 22 metodos de disparo)
// ---------------------------------------------------------------------------

// CRIOGENICO (Nv 8): chorro que frena y danha sin parar al objetivo
void FireCryo(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    int beam[4] = {120, 220, 255, 255};
    int core[4] = {220, 245, 255, 255};
    PetBeam(muzzle, tPos, beam, 3.0, 0.12);
    PetBeam(muzzle, tPos, core, 1.0, 0.10);
    PetBloodAt(tPos);

    PetDamage(target, client, 13.0 * PetGunMult(client), DMG_BULLET);
    AddSlow(target, 2.5);

    float now = GetGameTime();
    if (now - g_LastShotAt[client] > 0.3)
    {
        g_LastShotAt[client] = now;
        EmitSoundToAll(SND_GLASS, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.4, 170);
    }
}

// LANZAGRANADAS (Nv 12): proyectil explosivo de area con retardo de vuelo
void FireGrenadero(int client, int body, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 30.0;
    tPos[0] += GetRandomFloat(-35.0, 35.0);
    tPos[1] += GetRandomFloat(-35.0, 35.0);

    int arc[4] = {255, 200, 120, 255};
    PetBeam(muzzle, tPos, arc, 2.0, 0.3);
    DoAirstrikeAt(client, tPos, 1, 42.0 * PetDamageMult(client), 150.0);
    EmitSoundToAll(SND_MISSILE2, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.6, 120);
}

// RIFLE GAUSS (Nv 18): disparo pesado con empujon devastador
void FireGauss(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    float dmg = 150.0 * PetGunMult(client);
    bool crit = (GetRandomInt(1, 100) <= 15);
    if (crit) dmg *= 1.5;

    int beam[4] = {160, 255, 255, 255};
    int core[4] = {255, 255, 255, 255};
    PetBeam(muzzle, tPos, beam, 5.0, 0.3);
    PetBeam(muzzle, tPos, core, 1.5, 0.26);
    PetBloodAt(tPos);

    float dir[3], ang[3];
    MakeVectorFromPoints(muzzle, tPos, dir);
    GetVectorAngles(dir, ang);
    TE_SetupMuzzleFlash(muzzle, ang, 3.0, 1);
    TE_SendToAll();

    PetDamage(target, client, dmg, DMG_BULLET);

    if (target > 0 && IsValidEntity(target))
    {
        float push[3];
        MakeVectorFromPoints(muzzle, tPos, push);
        NormalizeVector(push, push);
        push[2] += 0.5;
        NormalizeVector(push, push);
        ScaleVector(push, 350.0);
        TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, push);
    }

    EmitSoundToAll(SND_MISSILE2, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.8, 60);
    if (crit && IsValidClient(client))
        PrintToChat(client, "%s \x04Impacto critico\x05 del Rifle Gauss (%.0f de dano).", CHAT_PREFIX, dmg);
}

// SOLAR (Nv 22): rayo que gana potencia mientras mantiene el objetivo
void FireSolar(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    int tRef = EntIndexToEntRef(target);
    if (g_SolarTargetRef[client] != tRef)
    {
        g_SolarTargetRef[client] = tRef;
        g_SolarStack[client] = 0;
    }
    if (g_SolarStack[client] < 8) g_SolarStack[client]++;
    float dmg = (10.0 + 6.0 * float(g_SolarStack[client] - 1)) * PetGunMult(client);

    int beam[4] = {255, 200, 60, 255};
    int core[4] = {255, 250, 200, 255};
    PetBeam(muzzle, tPos, beam, 2.0 + 0.4 * float(g_SolarStack[client] - 1), 0.12);
    PetBeam(muzzle, tPos, core, 0.8, 0.10);
    PetBloodAt(tPos);

    PetDamage(target, client, dmg, DMG_BULLET);
    if (target > 0 && IsValidEntity(target))
        IgniteEntity(target, 2.0);

    float now = GetGameTime();
    if (now - g_LastShotAt[client] > 0.3)
    {
        g_LastShotAt[client] = now;
        EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.45, 160);
    }
}

// PULSO (Nv 28): descarga con onda de choque que despeja grupos
void FirePulse(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 30.0;

    int beam[4] = {180, 120, 255, 255};
    PetBeam(muzzle, tPos, beam, 2.5, 0.14);

    int ring[4] = {180, 120, 255, 220};
    TE_SetupBeamRingPoint(tPos, 10.0, 110.0, g_sBeam, g_sBeam, 0, 60, 0.35, 12.0, 0.0, ring, 180, 0);
    TE_SendToAll();

    PetDamage(target, client, 10.0 * PetGunMult(client), DMG_BULLET);
    PetExplosionDamage(client, tPos, 95.0, 18.0 * PetGunMult(client), true);

    EmitSoundToAll(SND_AIRSTRIKE3, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.6, 110);
}

// ARCO CRUZADO (Nv 33): doble haz electrico desde las dos alas
void FireArc2(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    float fwd[3], perp[3];
    MakeVectorFromPoints(muzzle, tPos, fwd);
    perp[0] = fwd[1];
    perp[1] = -fwd[0];
    perp[2] = 0.0;
    if (GetVectorLength(perp) < 0.01)
    {
        perp[0] = 1.0; perp[1] = 0.0; perp[2] = 0.0;
    }
    else
    {
        NormalizeVector(perp, perp);
    }

    float m1[3], m2[3];
    m1[0] = muzzle[0] + perp[0] * 45.0; m1[1] = muzzle[1] + perp[1] * 45.0; m1[2] = muzzle[2];
    m2[0] = muzzle[0] - perp[0] * 45.0; m2[1] = muzzle[1] - perp[1] * 45.0; m2[2] = muzzle[2];

    int zap[4] = {160, 220, 255, 255};
    PetBeam(m1, tPos, zap, 1.8, 0.13);
    PetBeam(m2, tPos, zap, 1.8, 0.13);
    PetBloodAt(tPos);
    PetDamage(target, client, 20.0 * PetGunMult(client), DMG_BULLET);

    // salto secundario al enemigo mas cercano al impacto
    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(tPos, 260.0, enemies);
    int best = -1;
    float bestD = 999999.0;
    for (int i = 0; i < enemies.Length; i++)
    {
        int en = enemies.Get(i);
        if (en <= 0 || !IsValidEntity(en) || en == target) continue;
        float vPos[3];
        GetEntPropVector(en, Prop_Send, "m_vecOrigin", vPos);
        float d = GetVectorDistance(tPos, vPos);
        if (d < bestD) { bestD = d; best = en; }
    }
    if (best != -1)
    {
        float bPos[3];
        GetEntPropVector(best, Prop_Send, "m_vecOrigin", bPos);
        bPos[2] += 40.0;
        int jump[4] = {190, 240, 255, 230};
        PetBeam(tPos, bPos, jump, 1.2, 0.12);
        PetDamage(best, client, 16.0 * PetGunMult(client), DMG_BULLET);
    }
    delete enemies;

    float now = GetGameTime();
    if (now - g_LastShotAt[client] > 0.25)
    {
        g_LastShotAt[client] = now;
        EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.5, 230);
    }
}

// CLUSTER (Nv 38): andanada de mini-explosiones retardadas sobre el objetivo
void FireClusterMG(int client, int body, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 30.0;

    int beam[4] = {255, 170, 90, 255};
    PetBeam(muzzle, tPos, beam, 2.0, 0.25);
    DoAirstrikeAt(client, tPos, 3, 36.0 * PetDamageMult(client), 105.0);
    EmitSoundToAll(SND_MISSILE1, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.5, 130);
}

// FRAGMENTACION (Nv 50): impacto directo pesado + metralla radial
void FireFrag(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    int beam[4] = {255, 240, 200, 255};
    PetBeam(muzzle, tPos, beam, 3.0, 0.22);
    PetBloodAt(tPos);
    PetDamage(target, client, 55.0 * PetGunMult(client), DMG_BULLET);

    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(tPos, 350.0, enemies);
    int frags = 0;
    for (int i = 0; i < enemies.Length && frags < 8; i++)
    {
        int en = enemies.Get(i);
        if (en <= 0 || !IsValidEntity(en) || en == target) continue;
        float vPos[3];
        GetEntPropVector(en, Prop_Send, "m_vecOrigin", vPos);
        vPos[2] += 40.0;
        int sh[4] = {255, 220, 160, 255};
        PetBeam(tPos, vPos, sh, 0.8, 0.12);
        PetDamage(en, client, 16.0 * PetGunMult(client), DMG_BULLET);
        frags++;
    }
    delete enemies;

    EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.6, 70);
}

// VACIO (Nv 55): implosion que agrupa a los enemigos y detona
void FireVacio(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 30.0;

    int beam[4] = {190, 90, 255, 255};
    PetBeam(muzzle, tPos, beam, 3.5, 0.2);
    PetDamage(target, client, 14.0 * PetGunMult(client), DMG_BULLET);

    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(tPos, 300.0, enemies);
    for (int i = 0; i < enemies.Length; i++)
    {
        int en = enemies.Get(i);
        if (en <= 0 || !IsValidEntity(en)) continue;
        float vPos[3], sPos[3], pull[3];
        GetEntPropVector(en, Prop_Send, "m_vecOrigin", vPos);
        CopyVector(vPos, sPos);
        sPos[2] += 40.0;
        int suck[4] = {190, 90, 255, 200};
        PetBeam(sPos, tPos, suck, 1.2, 0.18);
        MakeVectorFromPoints(vPos, tPos, pull);
        NormalizeVector(pull, pull);
        pull[2] += 0.2;
        NormalizeVector(pull, pull);
        ScaleVector(pull, 280.0);
        TeleportEntity(en, NULL_VECTOR, NULL_VECTOR, pull);
    }
    delete enemies;

    // detona hacia dentro un instante despues
    int ring[4] = {190, 90, 255, 230};
    TE_SetupBeamRingPoint(tPos, 260.0, 20.0, g_sBeam, g_sBeam, 0, 70, 0.5, 14.0, 0.0, ring, 190, 0);
    TE_SendToAll();
    DoAirstrikeAt(client, tPos, 1, 32.0 * PetDamageMult(client), 230.0);
    EmitSoundToAll(SND_JETPASS, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.7, 90);
}

// BUSCADORES (Nv 65): salva de mini-misiles guiados
void FireSeekers(int client, int body, int target)
{
    PetFireMissile(client, MSTYLE_SEEKER, target);
    EmitSoundToAll(SND_MISSILE1, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.5, 150);
}

// ANTIMATERIA (Nv 85): rayo devastador de un disparo con area
void FireAntimateria(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    int outer[4] = {200, 80, 255, 255};
    int core[4] = {255, 255, 255, 255};
    PetBeam(muzzle, tPos, outer, 9.0, 0.5);
    PetBeam(muzzle, tPos, core, 3.0, 0.45);

    TE_SetupExplosion(tPos, g_sExplosion, 7.0, 1, 0, 120, 200);
    TE_SendToAll();
    PetBloodAt(tPos);
    PetDamage(target, client, 200.0 * PetGunMult(client), DMG_BULLET);
    PetExplosionDamage(client, tPos, 120.0, 55.0 * PetGunMult(client), false);

    EmitSoundToAll(SND_MISSILE1, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_DISHWASHER, _, 0.8, 60);
    EmitSoundToAll(SND_MISSILE2, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_DISHWASHER, _, 0.8, 50);
}

// ESTELAR (Nv 100): el cañon definitivo: rayo + misiles guiados + doble explosion
void FireEstelar(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    int gold[4] = {255, 230, 130, 255};
    int core[4] = {255, 255, 255, 255};
    PetBeam(muzzle, tPos, gold, 11.0, 0.5);
    PetBeam(muzzle, tPos, core, 3.5, 0.45);

    int ring[4] = {255, 230, 130, 230};
    TE_SetupBeamRingPoint(tPos, 20.0, 300.0, g_sBeam, g_sBeam, 0, 90, 0.7, 22.0, 0.0, ring, 200, 0);
    TE_SendToAll();

    PetDamage(target, client, 140.0 * PetGunMult(client), DMG_BULLET);
    PetFireMissile(client, MSTYLE_SEEKER, target);
    DoAirstrikeAt(client, tPos, 2, 75.0 * PetDamageMult(client), 160.0);

    EmitSoundToAll(SND_MISSILE1, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_DISHWASHER);
    EmitSoundToAll(SND_REWARD, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.6, 130);
}

// (PLASMA Nv 45 y COHETERA Nv 80 disparan con el sistema de misiles interno:
//  MSTYLE_PLASMA = orbe explosivo de area, MSTYLE_ROCKET = andanada de 2
//  cohetes guiados; su dano escala con el nivel como el resto de misiles)

// posicion de boca del F18 visible
void GetPetMuzzle(int body, float out[3])
{
    GetEntPropVector(body, Prop_Send, "m_vecOrigin", out);
    out[2] -= BODY_HEIGHT;
}

// entidad desde la que suenan los disparos: el F18 visible (no el cuerpo a +3000)
int GetPetSoundEnt(int client, int body)
{
    int model = (g_PetModel[client] != -1) ? EntRefToEntIndex(g_PetModel[client]) : -1;
    if (model != -1 && IsValidEntity(model)) return model;
    return body;
}

// v3.1 FIX DEL PARPADEO: el F18 visible cuelga del cuerpo fisico invisible
// con offset local (0,0,-3000) — CUALQUIER pitch del cuerpo rota ese offset y
// desplaza al avion miles de unidades (pitch 60 = ~2600 u), que era el
// "aparece y desaparece" en combate. Desde v3.1 el cuerpo NUNCA se inclina
// (solo yaw) y el vuelco visual se aplica al MODELO en angulos LOCALES:
// rota sobre su propio origen, cero desplazamiento.
void SetPetBank(int client, float pitch)
{
    int model = (g_PetModel[client] != -1) ? EntRefToEntIndex(g_PetModel[client]) : -1;
    if (model == -1 || !IsValidEntity(model)) return;
    float bank[3];
    bank[0] = pitch;
    TeleportEntity(model, NULL_VECTOR, bank, NULL_VECTOR);
}

void PetBeam(const float start[3], const float end[3], const int color[4], float width, float life)
{
    TE_SetupBeamPoints(start, end, g_sBeam, g_sBeam, 0, 100, life, width, width, 0, 0.0, color, 100);
    TE_SendToAll();
}

void PetBloodAt(const float pos[3])
{
    float dir[3] = {0.0, 0.0, 90.0};
    TE_SetupBloodSprite(pos, dir, g_BloodColour, 3, g_sBloodSpray, g_sBlood);
    TE_SendToAll();
}

void PetDamage(int victim, int attacker, float damage, int dmgtype)
{
    if (victim > 0 && victim < 2048 && IsValidEntity(victim) && attacker > 0 && IsValidEntity(attacker))
    {
        // atribucion de bajas: el XP de la nave sabe quien lastimo a quien
        g_PetHitOwner[victim] = attacker;
        g_PetHitTime[victim] = GetGameTime();
        SDKHooks_TakeDamage(victim, attacker, attacker, damage, dmgtype);
    }
}

// recolecta enemigos vivos (SI clientes + comunes + witch) en radio
int PetEnemiesInRadius(const float pos[3], float radius, ArrayList list)
{
    float vPos[3];
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3)
        {
            GetEntPropVector(i, Prop_Send, "m_vecOrigin", vPos);
            if (GetVectorDistance(pos, vPos) <= radius) { list.Push(i); count++; }
        }
    }
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        if (GetVectorDistance(pos, vPos) <= radius) { list.Push(ent); count++; }
    }
    ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        if (GetVectorDistance(pos, vPos) <= radius) { list.Push(ent); count++; }
    }
    return count;
}

// ---------------------------------------------------------------------------
// METRALLETA: foco continuo sobre el objetivo con tracer
// ---------------------------------------------------------------------------
void FireBullet(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3], tPos[3], ang[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 40.0;

    int color[4] = {200, 220, 255, 255};
    PetBeam(muzzle, tPos, color, 1.2, 0.08);

    PetBloodAt(tPos);
    PetDamage(target, client, float(g_bulletdmg) * PetGunMult(client), DMG_BULLET);

    // fogonazo
    MakeVectorFromPoints(muzzle, tPos, ang);
    GetVectorAngles(ang, ang);
    TE_SetupMuzzleFlash(muzzle, ang, 1.5, 1);
    TE_SendToAll();

    EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.55, 100);
}

void CopyVector(const float src[3], float dest[3])
{
    dest[0] = src[0];
    dest[1] = src[1];
    dest[2] = src[2];
}

// ---------------------------------------------------------------------------
// ESCOPETA: cono de perdigones anti-grupos
// ---------------------------------------------------------------------------
void FireShotgun(int client, int body, int target, const float targetPos[3])
{
    float muzzle[3];
    GetPetMuzzle(body, muzzle);

    // 9 perdigones: cada uno golpea al objetivo o a un enemigo cercano al mismo
    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(targetPos, 220.0, enemies);

    int pellets = 9;
    int hitIndex;
    float hitPos[3], endPos[3];
    int color[4] = {255, 200, 100, 255};

    for (int p = 0; p < pellets; p++)
    {
        if (enemies.Length == 0)
            hitIndex = target;
        else
            hitIndex = enemies.Get(GetRandomInt(0, enemies.Length - 1));
        if (hitIndex <= 0 || !IsValidEntity(hitIndex)) hitIndex = target;
        if (hitIndex <= 0 || !IsValidEntity(hitIndex)) continue;

        GetEntPropVector(hitIndex, Prop_Send, "m_vecOrigin", hitPos);
        hitPos[2] += 40.0;
        // dispersion visual
        endPos[0] = hitPos[0] + GetRandomFloat(-25.0, 25.0);
        endPos[1] = hitPos[1] + GetRandomFloat(-25.0, 25.0);
        endPos[2] = hitPos[2] + GetRandomFloat(-15.0, 15.0);

        PetBeam(muzzle, endPos, color, 0.8, 0.08);
        PetBloodAt(endPos);
        float pelletDmg = (hitIndex == target) ? 20.0 : 15.0;
        pelletDmg *= PetGunMult(client);
        PetDamage(hitIndex, client, pelletDmg, DMG_BUCKSHOT);
    }
    delete enemies;

    float now = GetGameTime();
    if (now - g_LastShotAt[client] > 0.3)
    {
        g_LastShotAt[client] = now;
        EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.9, 60);
    }
}

// ---------------------------------------------------------------------------
// FLAMEGUN: chorro de fuego + charco + ignicion en area
// ---------------------------------------------------------------------------
void FireFlamegun(int client, int body, const float targetPos[3])
{
    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);

    // chorro naranja (2 pasadas para dar volumen)
    int color[4] = {255, 120, 20, 220};
    PetBeam(muzzle, tPos, color, 9.0, 0.25);
    int color2[4] = {255, 210, 60, 200};
    PetBeam(muzzle, tPos, color2, 5.0, 0.22);
    float sideA[3], sideB[3];
    sideA[0] = tPos[0] + 45.0; sideA[1] = tPos[1] + 45.0; sideA[2] = tPos[2];
    sideB[0] = tPos[0] - 45.0; sideB[1] = tPos[1] - 45.0; sideB[2] = tPos[2];
    PetBeam(muzzle, sideA, color2, 4.0, 0.20);
    PetBeam(muzzle, sideB, color2, 4.0, 0.20);

    // dano e ignicion en area
    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(tPos, 260.0, enemies);
    for (int i = 0; i < enemies.Length; i++)
    {
        int victim = enemies.Get(i);
        PetDamage(victim, client, 7.0 * PetGunMult(client), DMG_BURN);
        if (victim > 0 && IsValidEntity(victim))
            IgniteEntity(victim, 5.0);
    }
    delete enemies;

    // charco de fuego visual (limitado)
    if (g_iActiveFires < FIRE_HARD_CAP && GetEntityCount() < MAX_EDICTS_SAFE)
    {
        g_iActiveFires++;
        float fpos[3];
        fpos[0] = tPos[0] + GetRandomFloat(-40.0, 40.0);
        fpos[1] = tPos[1] + GetRandomFloat(-40.0, 40.0);
        fpos[2] = tPos[2] + 5.0;
        int fire = CreateEntityByName("env_fire");
        if (fire != -1)
        {
            char uniq[48];
            Format(uniq, sizeof(uniq), "petfire%d", fire);
            DispatchKeyValue(fire, "targetname", uniq);
            DispatchKeyValueVector(fire, "origin", fpos);
            DispatchKeyValue(fire, "firesize", "160");
            DispatchKeyValue(fire, "health", "6");
            DispatchKeyValue(fire, "fireattack", "4");
            DispatchKeyValue(fire, "damagescale", "0");
            DispatchKeyValue(fire, "ignitionpoint", "32");
            DispatchSpawn(fire);
            ActivateEntity(fire);
            AcceptEntityInput(fire, "StartFire");
            int ref = EntIndexToEntRef(fire);
            CreateTimer(5.0, Timer_FireDie, ref, TIMER_FLAG_NO_MAPCHANGE);
        }
        else
        {
            g_iActiveFires--;
        }
    }

    EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.30, 55);
}

public Action Timer_FireDie(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(ref);
    if (ent != -1 && IsValidEntity(ent))
        AcceptEntityInput(ent, "kill");
    if (g_iActiveFires > 0) g_iActiveFires--;
    return Plugin_Stop;
}

// ---------------------------------------------------------------------------
// SISTEMA DE MISILES: 10 estilos seleccionables desde el menu
// ---------------------------------------------------------------------------
bool MissileSafeForTeam(const float pos[3], float radius)
{
    float vPos[3];
    float check = radius + 120.0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
        {
            GetEntPropVector(i, Prop_Send, "m_vecOrigin", vPos);
            if (GetVectorDistance(pos, vPos) < check)
                return false;
        }
    }
    return true;
}

// despacha la salva completa (con retardo entre misiles si el estilo tiene count > 1)
void PetFireMissile(int client, int styleId, int targetIdx)
{
    if (styleId == MSTYLE_LASER)
    {
        PetLaserShot(client, targetIdx);
        return;
    }

    if (g_Styles[styleId].count <= 1)
    {
        LaunchMissile(client, styleId, targetIdx);
        return;
    }

    // salvas escalonadas: (userid << 4) | styleId empaquetado en un solo any
    for (int i = 0; i < g_Styles[styleId].count; i++)
    {
        int packed = (GetClientUserId(client) << 4) | (styleId & 0xF);
        CreateTimer(g_Styles[styleId].interval * float(i), Timer_FireSalvo,
            view_as<any>(packed), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Timer_FireSalvo(Handle timer, any packed)
{
    int styleId = view_as<int>(packed) & 0xF;
    int client = GetClientOfUserId(view_as<int>(packed) >> 4);
    if (!IsValidClient(client) || !PetIsActive(client)) return Plugin_Stop;

    int targetIdx = (g_PetTarget[client] != -1) ? EntRefToEntIndex(g_PetTarget[client]) : -1;
    if (targetIdx == -1 || !IsValidEntity(targetIdx) || !IsEnemyAlive(targetIdx)) return Plugin_Stop;

    LaunchMissile(client, styleId, targetIdx);
    return Plugin_Stop;
}

void LaunchMissile(int client, int styleId, int targetIdx)
{
    int targetRef = EntIndexToEntRef(targetIdx);

    float vel[3], ang[3], spawn[3], tPos[3];
    GetEntPropVector(targetIdx, Prop_Send, "m_vecOrigin", tPos);

    if (g_Styles[styleId].rain)
    {
        // aparece en el cielo sobre el objetivo y cae (rain);
        // indoor: sondea el techo real para no nacer dentro del muro
        float angUp[3] = {-90.0, 0.0, 0.0};   // v2.4: -90 mira ARRIBA (el +90 sondaba el suelo)
        float probe[3], trEnd[3];
        probe[0] = tPos[0]; probe[1] = tPos[1]; probe[2] = tPos[2] + 60.0;
        float topZ = tPos[2] + 1000.0;
        Handle tr = TR_TraceRayEx(probe, angUp, MASK_SOLID_BRUSHONLY, RayType_Infinite);
        if (tr != null)
        {
            if (TR_DidHit(tr))
            {
                TR_GetEndPosition(trEnd, tr);
                if (trEnd[2] < topZ)
                    topZ = trEnd[2] - 60.0;   // 60u por debajo del techo real
            }
            CloseHandle(tr);
        }
        if (topZ < tPos[2] + 100.0) topZ = tPos[2] + 100.0;  // pasillo bajo: llueve igual
        spawn[0] = tPos[0] + GetRandomFloat(-120.0, 120.0);
        spawn[1] = tPos[1] + GetRandomFloat(-120.0, 120.0);
        spawn[2] = topZ;
        vel[0] = GetRandomFloat(-60.0, 60.0);
        vel[1] = GetRandomFloat(-60.0, 60.0);
        vel[2] = -g_Styles[styleId].speed;
        ang[0] = 90.0; ang[1] = 0.0; ang[2] = 0.0;
        CreateMissileBody(client, styleId, spawn, ang, vel, targetRef, 4.0);
        return;
    }

    // lanzamiento desde el F18
    int body = EntRefToEntIndex(g_PetBody[client]);
    if (body == -1 || !IsValidEntity(body)) return;
    GetPetMuzzle(body, spawn);
    spawn[2] += 5.0;

    float aim[3];
    aim[0] = tPos[0]; aim[1] = tPos[1]; aim[2] = tPos[2] + 30.0;
    MakeVectorFromPoints(spawn, aim, vel);
    NormalizeVector(vel, vel);
    GetVectorAngles(vel, ang);
    ScaleVector(vel, g_Styles[styleId].speed);
    CreateMissileBody(client, styleId, spawn, ang, vel, targetRef, MISSILE_LIFE);
}

// crea cuerpo fisico + visual + estela + timers de un misil
int CreateMissileBody(int client, int styleId, const float pos[3], const float ang[3],
                      const float vel[3], int targetRef, float life)
{
    if (g_iActiveMissiles >= MISSILE_HARD_CAP) return -1;
    if (GetEntityCount() > MAX_EDICTS_SAFE) return -1;

    int body = CreateEntityByName("molotov_projectile");
    if (body == -1) return -1;
    if (body < 0 || body >= 2048) { AcceptEntityInput(body, "kill"); return -1; }

    DispatchKeyValue(body, "model", DMY_MISSILE);
    float dpos[3];
    CopyVector(pos, dpos);
    DispatchKeyValueVector(body, "origin", dpos);
    float dang[3];
    CopyVector(ang, dang);
    DispatchKeyValueVector(body, "angles", dang);
    SetEntPropFloat(body, Prop_Send, "m_flModelScale", 0.001);
    SetEntityGravity(body, g_Styles[styleId].gravity);
    SetEntPropEnt(body, Prop_Data, "m_hOwnerEntity", client);
    DispatchSpawn(body);

    g_MissileStyle[body] = styleId;
    g_MissileTargetRef[body] = targetRef;
    g_MissileLaunch[body] = GetGameTime();
    g_iActiveMissiles++;

    SDKHook(body, SDKHook_Touch, OnMissileTouch);
    TeleportEntity(body, NULL_VECTOR, NULL_VECTOR, vel);

    // modelo visible del misil
    int model = -1;
    if (GetEntityCount() < MAX_EDICTS_SAFE)
    {
        model = CreateMissileVisual(body, MDL_MISSILE, g_Styles[styleId].tiny ? 0.04 : 0.07);
        if (model != -1) g_MissileModelRef[body] = EntIndexToEntRef(model);
        else g_MissileModelRef[body] = -1;
    }
    else g_MissileModelRef[body] = -1;

    // estela solo para misiles individuales grandes
    g_MissileExhaustRef[body] = -1;
    if (styleId != MSTYLE_BOMBLET && !g_Styles[styleId].tiny && !g_Styles[styleId].rain
        && !g_Styles[styleId].laser && GetEntityCount() < MAX_EDICTS_SAFE)
    {
        int exaust = CreateExaust(body, 10);
        if (exaust != -1) g_MissileExhaustRef[body] = EntIndexToEntRef(exaust);
    }

    // watchdog de vuelo (explota si vuela demasiado)
    CreateTimer(life, Timer_MissileWatchdog, EntIndexToEntRef(body), TIMER_FLAG_NO_MAPCHANGE);

    // guiado continuo
    if (g_Styles[styleId].homing)
        CreateTimer(0.06, Timer_MissileGuide, EntIndexToEntRef(body), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    return body;
}

int CreateMissileVisual(int body, const char[] mdl, float scale)
{
    int attch = CreateEntityByName("prop_dynamic_override");
    if (attch == -1) return -1;

    char namE[32];
    Format(namE, sizeof(namE), "petmsl%d", body);
    DispatchKeyValue(body, "targetname", namE);
    DispatchKeyValue(attch, "model", mdl);
    DispatchKeyValue(attch, "parentname", namE);
    DispatchKeyValueFloat(attch, "fademindist", 10000.0);
    DispatchKeyValueFloat(attch, "fademaxdist", 20000.0);
    DispatchKeyValueFloat(attch, "fadescale", 0.0);
    DispatchSpawn(attch);
    SetVariantString(namE);
    AcceptEntityInput(attch, "SetParent", attch, attch, 0);
    SetEntPropFloat(attch, Prop_Send, "m_flModelScale", scale);
    float off[3] = {0.0, 0.0, 0.0};
    TeleportEntity(attch, off, NULL_VECTOR, NULL_VECTOR);
    return attch;
}

int CreateExaust(int ent, int length)
{
    float flmOri[3] = {0.0, 0.0, 0.0};
    float flmAng[3] = {0.0, 180.0, 0.0};

    char exaustName[48];
    Format(exaustName, sizeof(exaustName), "petexaust%d", ent);

    int exaust = CreateEntityByName("env_steam");
    if (exaust == -1) return -1;

    char lg[16];
    Format(lg, sizeof(lg), "%d.0", length);

    DispatchKeyValue(ent, "targetname", exaustName);
    DispatchKeyValue(exaust, "SpawnFlags", "1");
    DispatchKeyValue(exaust, "Type", "0");
    DispatchKeyValue(exaust, "InitialState", "1");
    DispatchKeyValue(exaust, "Spreadspeed", "10");
    DispatchKeyValue(exaust, "Speed", "200");
    DispatchKeyValue(exaust, "Startsize", "5");
    DispatchKeyValue(exaust, "EndSize", "30");
    DispatchKeyValue(exaust, "Rate", "555");
    DispatchKeyValue(exaust, "RenderColor", "255 180 80");
    DispatchKeyValue(exaust, "JetLength", lg);
    DispatchKeyValue(exaust, "RenderAmt", "180");
    DispatchSpawn(exaust);
    SetVariantString(exaustName);
    AcceptEntityInput(exaust, "SetParent", exaust, exaust, 0);
    TeleportEntity(exaust, flmOri, flmAng, NULL_VECTOR);
    AcceptEntityInput(exaust, "TurnOn");
    return exaust;
}

// ---------------------------------------------------------------------------
// Guiado de misiles (teledirigidos / enjambre / cluster)
// ---------------------------------------------------------------------------
public Action Timer_MissileGuide(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(ref);
    if (ent == -1 || ent >= 2048 || !IsValidEntity(ent) || g_MissileStyle[ent] == -1)
        return Plugin_Stop;

    int styleId = g_MissileStyle[ent];
    int target = (g_MissileTargetRef[ent] != -1) ? EntRefToEntIndex(g_MissileTargetRef[ent]) : -1;
    if (target == -1 || !IsValidEntity(target) || !IsEnemyAlive(target))
        return Plugin_Continue;   // sin objetivo: sigue recto

    float mPos[3], tPos[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", mPos);
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", tPos);

    // cluster: se divide al acercarse
    if (g_Styles[styleId].cluster)
    {
        if (GetVectorDistance(mPos, tPos) < 450.0)
        {
            ClusterSplit(ent);
            return Plugin_Stop;
        }
    }

    // steering hacia el objetivo
    float curVel[3], desired[3], newDir[3];
    GetEntPropVector(ent, Prop_Data, "m_vecVelocity", curVel);
    float speed = GetVectorLength(curVel);
    if (speed < 1.0) return Plugin_Continue;

    tPos[2] += 30.0;
    MakeVectorFromPoints(mPos, tPos, desired);
    NormalizeVector(desired, desired);
    NormalizeVector(curVel, curVel);

    float turn = g_Styles[styleId].turn;
    newDir[0] = curVel[0] * (1.0 - turn) + desired[0] * turn;
    newDir[1] = curVel[1] * (1.0 - turn) + desired[1] * turn;
    newDir[2] = curVel[2] * (1.0 - turn) + desired[2] * turn;
    NormalizeVector(newDir, newDir);
    ScaleVector(newDir, speed);
    TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, newDir);
    return Plugin_Continue;
}

// ---------------------------------------------------------------------------
// Cluster: division en 4 bombetas
// ---------------------------------------------------------------------------
void ClusterSplit(int parent)
{
    int client = GetEntPropEnt(parent, Prop_Data, "m_hOwnerEntity");
    int targetRef = g_MissileTargetRef[parent];
    float pos[3];
    GetEntPropVector(parent, Prop_Send, "m_vecOrigin", pos);

    TE_SetupExplosion(pos, g_sExplosion, 1.5, 1, 0, 20, 50);
    TE_SendToAll();

    // el padre muere en silencio (sin explosion de dano) y nacen las bombetas
    MissileDetach(parent, true);

    if (client <= 0 || !IsValidClient(client)) return;
    for (int i = 0; i < 4; i++)
    {
        float ang[3], vel[3];
        ang[0] = GetRandomFloat(-45.0, 15.0);
        ang[1] = GetRandomFloat(-180.0, 180.0);
        ang[2] = 0.0;
        GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(vel, 450.0);
        float spawn[3];
        spawn[0] = pos[0] + GetRandomFloat(-20.0, 20.0);
        spawn[1] = pos[1] + GetRandomFloat(-20.0, 20.0);
        spawn[2] = pos[2] + GetRandomFloat(0.0, 20.0);
        CreateMissileBody(client, MSTYLE_BOMBLET, spawn, ang, vel, targetRef, BOMBLET_LIFE);
    }
}

// ---------------------------------------------------------------------------
// Impacto / watchdog / explosion
// ---------------------------------------------------------------------------
public Action OnMissileTouch(int ent, int other)
{
    if (ent <= 0 || ent >= 2048) return Plugin_Continue;
    if (g_MissileStyle[ent] == -1) return Plugin_Continue;

    // misil contra misil propio: se cruzan sin detonar
    if (other > 0 && other < 2048 && g_MissileStyle[other] != -1)
        return Plugin_Handled;

    // misil contra granada del pet: pasan de largo
    if (other > 0 && other < 2048 && g_GrenadeOwner[other] != -1)
        return Plugin_Handled;

    // no detonar contra el pet de ningun dueno (cuerpo, modelo o estela)
    if (other > 0 && other < 2048)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (g_PetBody[i] == -1) continue;
            if (other == EntRefToEntIndex(g_PetBody[i])
                || other == EntRefToEntIndex(g_PetModel[i]))
                return Plugin_Handled;
        }
    }

    PetMissile_Explode(ent);
    return Plugin_Handled;   // bloquea la detonacion vanilla del molotov (sin fuego real)
}

public Action Timer_MissileWatchdog(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(ref);
    if (ent != -1 && ent < 2048 && IsValidEntity(ent) && g_MissileStyle[ent] != -1)
        PetMissile_Explode(ent);
    return Plugin_Stop;
}

void PetMissile_Explode(int ent)
{
    int styleId = g_MissileStyle[ent];
    if (styleId == -1) return;

    int client = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
    if (client <= 0 || !IsValidEntity(client)) client = 0;

    float pos[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);

    int expScale = g_Styles[styleId].expScale;
    float radius = g_Styles[styleId].radius;
    float damage = g_Styles[styleId].damage;
    if (client > 0 && IsValidClient(client))
        damage *= PetDamageMult(client);   // el nivel potencia todos los misiles
    bool shockwave = g_Styles[styleId].shockwave;
    bool napalm = g_Styles[styleId].napalm;

    // visual de explosion
    if (expScale > 0)
    {
        TE_SetupExplosion(pos, g_sExplosion, float(expScale), 1, 0,
            RoundToFloor(radius), RoundToFloor(damage));
        TE_SendToAll();
        if (expScale >= 10)
        {
            EmitSoundToAll(SND_MISSILE1, ent, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER);
            EmitSoundToAll(SND_MISSILE2, ent, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER);
        }
        else
        {
            if (GetRandomInt(1, 2) == 1) EmitSoundToAll(SND_MISSILE1, ent, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE);
            else EmitSoundToAll(SND_MISSILE2, ent, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE);
        }
    }

    // onda expansiva visual
    if (shockwave)
    {
        int ringColor[4] = {120, 190, 255, 230};
        TE_SetupBeamRingPoint(pos, 20.0, radius * 1.2, g_sBeam, g_sBeam, 0, 120, 0.7, 30.0, 0.0, ringColor, 180, 0);
        TE_SendToAll();
    }

    // dano en area
    if (damage > 0.0 && radius > 0.0 && client > 0)
        PetExplosionDamage(client, pos, radius, damage, shockwave);

    // napalm: charcos de fuego + ignicion amplia
    if (napalm)
    {
        for (int f = 0; f < 4; f++)
        {
            float fpos[3];
            fpos[0] = pos[0] + GetRandomFloat(-160.0, 160.0);
            fpos[1] = pos[1] + GetRandomFloat(-160.0, 160.0);
            fpos[2] = pos[2] + 5.0;
            CreateFirePit(fpos, 5.0);
        }
        if (client > 0)
        {
            ArrayList enemies = new ArrayList();
            PetEnemiesInRadius(pos, 300.0, enemies);
            for (int i = 0; i < enemies.Length; i++)
            {
                int victim = enemies.Get(i);
                if (victim > 0 && IsValidEntity(victim))
                    IgniteEntity(victim, 5.0);
            }
            delete enemies;
        }
    }

    MissileDetach(ent, true);
}

// limpia el rastro del misil (hijos, arrays, hook) y lo borra
void MissileDetach(int ent, bool killBody)
{
    if (ent <= 0 || ent >= 2048) return;
    int styleId = g_MissileStyle[ent];
    if (styleId == -1 && !killBody) return;

    g_MissileStyle[ent] = -1;
    g_MissileTargetRef[ent] = -1;
    if (g_iActiveMissiles > 0) g_iActiveMissiles--;

    SDKUnhook(ent, SDKHook_Touch, OnMissileTouch);

    int model = (g_MissileModelRef[ent] != -1) ? EntRefToEntIndex(g_MissileModelRef[ent]) : -1;
    if (model != -1 && IsValidEntity(model)) AcceptEntityInput(model, "kill");
    g_MissileModelRef[ent] = -1;

    int exaust = (g_MissileExhaustRef[ent] != -1) ? EntRefToEntIndex(g_MissileExhaustRef[ent]) : -1;
    if (exaust != -1 && IsValidEntity(exaust)) AcceptEntityInput(exaust, "kill");
    g_MissileExhaustRef[ent] = -1;

    if (killBody && ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "kill");
}

void PetExplosionDamage(int client, const float pos[3], float radius, float damage, bool shockwave)
{
    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(pos, radius, enemies);
    for (int i = 0; i < enemies.Length; i++)
    {
        int victim = enemies.Get(i);
        if (victim <= 0 || !IsValidEntity(victim)) continue;

        if (shockwave)
        {
            // empujon sin apenas dano
            PetDamage(victim, client, damage, DMG_BLAST);
            float vPos[3], dir[3], push[3];
            GetEntPropVector(victim, Prop_Send, "m_vecOrigin", vPos);
            MakeVectorFromPoints(pos, vPos, dir);
            NormalizeVector(dir, dir);
            dir[2] += 0.6;
            NormalizeVector(dir, dir);
            push[0] = dir[0] * 450.0; push[1] = dir[1] * 450.0; push[2] = dir[2] * 450.0;
            TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, push);
        }
        else
        {
            PetDamage(victim, client, damage, DMG_BLAST);
        }
    }
    delete enemies;
}

// charco de fuego (flamegun y napalm)
void CreateFirePit(const float pos[3], float life)
{
    if (g_iActiveFires >= FIRE_HARD_CAP) return;
    if (GetEntityCount() > MAX_EDICTS_SAFE) return;

    int fire = CreateEntityByName("env_fire");
    if (fire == -1) return;
    g_iActiveFires++;

    char uniq[48];
    Format(uniq, sizeof(uniq), "petfire%d", fire);
    DispatchKeyValue(fire, "targetname", uniq);
    float dpos[3];
    CopyVector(pos, dpos);
    DispatchKeyValueVector(fire, "origin", dpos);
    DispatchKeyValue(fire, "firesize", "200");
    DispatchKeyValue(fire, "health", "5");
    DispatchKeyValue(fire, "fireattack", "4");
    DispatchKeyValue(fire, "damagescale", "0");
    DispatchKeyValue(fire, "ignitionpoint", "32");
    DispatchSpawn(fire);
    ActivateEntity(fire);
    AcceptEntityInput(fire, "StartFire");
    int ref = EntIndexToEntRef(fire);
    CreateTimer(life + 0.5, Timer_FireDie, ref, TIMER_FLAG_NO_MAPCHANGE);
}

// ---------------------------------------------------------------------------
// SISTEMA DE GRANADAS (v2.3): la nave suelta granadas REALES (molotov / casera
// / bilis) y al detonar aplican uno de los 20 EFECTOS del grenade.sp: medica,
// bola de fuego, cluster, fuegos artificiales, humo, agujero negro, cegadora,
// escudo, tesla, quimica, congelante, vaporizador, extintor, brillo,
// antigravedad, cluster de fuego, metralla, flak, bombardeo aereo y arma
// sorpresa. Nunca dana al equipo. La MEDICA se lanza al aliado herido (Nv 3).
// ---------------------------------------------------------------------------
char g_GrenadeModels[3][64] = { DMY_MISSILE, MDL_PIPEBOMB, MDL_BILEFLASK };
char g_WeaponDropList[8][26] = { "weapon_autoshotgun", "weapon_rifle", "weapon_smg",
    "weapon_shotgun", "weapon_hunting_rifle", "weapon_rifle_ak47", "weapon_rifle_desert",
    "weapon_sniper_military" };

void LaunchGrenade(int client, int body, int targetIdx, const float targetPos[3], int forcedFx)
{
    if (GetEntityCount() > MAX_EDICTS_SAFE) return;
    if (g_iActiveGrenades >= GRENADE_HARD_CAP) return;
    if (targetIdx <= 0 || !IsValidEntity(targetIdx)) return;

    int nade = CreateEntityByName("molotov_projectile");
    if (nade == -1) return;
    if (nade < 0 || nade >= 2048)
    {
        AcceptEntityInput(nade, "kill");
        return;
    }

    float muzzle[3], tPos[3], dpos[3];
    GetPetMuzzle(body, muzzle);
    CopyVector(targetPos, tPos);
    tPos[2] += 30.0;
    CopyVector(muzzle, dpos);

    DispatchKeyValue(nade, "model", g_GrenadeModels[GetRandomInt(0, 2)]);
    DispatchKeyValueVector(nade, "origin", dpos);
    SetEntPropFloat(nade, Prop_Send, "m_flModelScale", 1.0);
    SetEntityGravity(nade, 0.35);
    SetEntPropEnt(nade, Prop_Data, "m_hOwnerEntity", client);
    DispatchSpawn(nade);

    g_GrenadeOwner[nade] = client;
    g_GrenadeFx[nade] = forcedFx;
    g_GrenadeLaunch[nade] = GetGameTime();
    g_iActiveGrenades++;

    float vel[3];
    MakeVectorFromPoints(muzzle, tPos, vel);
    NormalizeVector(vel, vel);
    ScaleVector(vel, GRENADE_SPEED);
    TeleportEntity(nade, NULL_VECTOR, NULL_VECTOR, vel);

    SDKHook(nade, SDKHook_Touch, OnGrenadeTouch);
    CreateTimer(GRENADE_FUSE, Timer_GrenadeFuse, EntIndexToEntRef(nade), TIMER_FLAG_NO_MAPCHANGE);
}

public Action OnGrenadeTouch(int ent, int other)
{
    if (ent <= 0 || ent >= 2048) return Plugin_Continue;
    if (g_GrenadeOwner[ent] == -1) return Plugin_Continue;

    // armado: no detona al rozar la propia nave en el lanzamiento
    if (GetGameTime() - g_GrenadeLaunch[ent] < 0.15) return Plugin_Handled;

    if (other > 0 && other < 2048)
    {
        // misiles y granadas del propio sistema: se cruzan sin detonar
        if (g_MissileStyle[other] != -1) return Plugin_Handled;
        if (g_GrenadeOwner[other] != -1) return Plugin_Handled;

        // el pet de nadie (cuerpo, F18 o estela) no la detona
        for (int i = 1; i <= MaxClients; i++)
        {
            if (g_PetBody[i] == -1) continue;
            if (other == EntRefToEntIndex(g_PetBody[i])
                || other == EntRefToEntIndex(g_PetModel[i])
                || other == EntRefToEntIndex(g_PetExhaust[i]))
                return Plugin_Handled;
        }

        // el equipo la atraviesa sin detonarla
        if (other <= MaxClients && IsClientInGame(other) && GetClientTeam(other) == 2)
            return Plugin_Handled;
    }

    GrenadeDetonate(ent);
    return Plugin_Handled;   // bloquea la detonacion vanilla del proyectil
}

public Action Timer_GrenadeFuse(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(ref);
    if (ent != -1 && ent < 2048 && IsValidEntity(ent) && g_GrenadeOwner[ent] != -1)
        GrenadeDetonate(ent);
    return Plugin_Stop;
}

void GrenadeDetonate(int ent)
{
    int client = g_GrenadeOwner[ent];
    if (client <= 0 || !IsValidClient(client) || !IsPlayerAlive(client))
        client = 0;

    float pos[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);

    int fx = g_GrenadeFx[ent];
    if (fx < 0 || fx >= GRENADE_FX_COUNT)
        fx = GetRandomInt(0, GRENADE_FX_COUNT - 1);   // efecto sorpresa
    GrenadeApplyEffect(fx, client, pos, ent);

    g_GrenadeOwner[ent] = -1;
    g_GrenadeFx[ent] = -1;
    if (g_iActiveGrenades > 0) g_iActiveGrenades--;
    SDKUnhook(ent, SDKHook_Touch, OnGrenadeTouch);
    AcceptEntityInput(ent, "kill");

    if (client > 0 && IsClientInGame(client))
        PrintToChat(client, "%s Granada detonada: efecto \x04%s\x05.", CHAT_PREFIX, g_GrenadeFxNames[fx]);
}

void GrenadeApplyEffect(int fx, int owner, const float pos[3], int sndEnt)
{
    switch (fx)
    {
        case 0: Gfx_Medic(owner, pos, sndEnt);
        case 1: Gfx_Fireball(owner, pos, sndEnt);
        case 2: Gfx_Cluster(owner, pos, sndEnt);
        case 3: Gfx_Firework(owner, pos, sndEnt);
        case 4: Gfx_Smoke(owner, pos, sndEnt);
        case 5: Gfx_BlackHole(owner, pos, sndEnt);
        case 6: Gfx_Flashbang(owner, pos, sndEnt);
        case 7: Gfx_Shield(owner, pos, sndEnt);
        case 8: Gfx_Tesla(owner, pos, sndEnt);
        case 9: Gfx_Chemical(owner, pos, sndEnt);
        case 10: Gfx_Freezer(owner, pos, sndEnt);
        case 11: Gfx_Vaporizer(owner, pos, sndEnt);
        case 12: Gfx_Extinguisher(pos, sndEnt);
        case 13: Gfx_Glow(pos, sndEnt);
        case 14: Gfx_Antigravity(owner, pos, sndEnt);
        case 15: Gfx_FireCluster(owner, pos, sndEnt);
        case 16: Gfx_Shrapnel(owner, pos, sndEnt);
        case 17: Gfx_Flak(owner, pos, sndEnt);
        case 18: Gfx_Airstrike(owner, pos, sndEnt);
        case 19: Gfx_Weapon(owner, pos, sndEnt);
        case 20: Gfx_Meteor(owner, pos, sndEnt);
        case 21: Gfx_PlasmaNova(owner, pos, sndEnt);
        case 22: Gfx_SeekerSwarm(owner, pos, sndEnt);
        case 23: Gfx_Toxic(owner, pos, sndEnt);
        case 24: Gfx_MiniNuke(owner, pos, sndEnt);
    }
}

// ---- EFECTO 0: MEDICA (cura al equipo y apaga el fuego) ---------------------
void Gfx_Medic(int owner, const float pos[3], int sndEnt)
{
    int ring[4] = {80, 255, 120, 230};
    TE_SetupBeamRingPoint(pos, 20.0, 620.0, g_sBeam, g_sBeam, 0, 110, 1.2, 25.0, 0.0, ring, 200, 0);
    TE_SendToAll();

    // v3.0: la cura escala con el nivel de la duena: 10 HP en Nv 1,
    // +0.2 por nivel, tope 35 (antes curaba 25 fijo)
    int healAmt = RoundToFloor(PetHealAmount(owner));
    int healed = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2) continue;
        float vPos[3];
        GetEntPropVector(i, Prop_Send, "m_vecOrigin", vPos);
        if (GetVectorDistance(pos, vPos) > 600.0) continue;

        int hp = GetClientHealth(i);
        int maxhp = GetEntProp(i, Prop_Data, "m_iMaxHealth");
        if (maxhp <= 0) maxhp = 100;
        if (hp < maxhp)
        {
            hp += healAmt;
            if (hp > maxhp) hp = maxhp;
            SetEntityHealth(i, hp);
            // v3.0: el sonido de curacion suena SOLO cuando se cura con
            // exito a un superviviente (antes sonaba por pasar por la nube
            // con la vida llena y contaba como cura sin curar nada)
            EmitSoundToClient(i, SND_REWARD);
            healed++;
        }
        ExtinguishEntity(i);
    }

    EmitSoundToAll(SND_MISSILE2, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.4, 180);
    if (owner > 0 && healed > 0 && IsClientInGame(owner))
    {
        PetCountHeal(owner, healed);
        PetAddXP(owner, healed * 2);   // curar tambien da progreso
        PrintToChat(owner, "%s La granada medica curo a %d companeros (+%d HP y apaga el fuego).", CHAT_PREFIX, healed, healAmt);
    }
}

// ---- EFECTO 1: BOLA DE FUEGO --------------------------------------------------
void Gfx_Fireball(int owner, const float pos[3], int sndEnt)
{
    TE_SetupExplosion(pos, g_sExplosion, 8.0, 1, 0, 260, 90);
    TE_SendToAll();
    int ring[4] = {255, 160, 60, 220};
    TE_SetupBeamRingPoint(pos, 30.0, 300.0, g_sBeam, g_sBeam, 0, 90, 0.6, 18.0, 0.0, ring, 180, 0);
    TE_SendToAll();
    EmitSoundToAll(SND_MISSILE1, sndEnt, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER);

    if (owner > 0)
        PetExplosionDamage(owner, pos, 260.0, 70.0, false);

    for (int f = 0; f < 4; f++)
    {
        float fpos[3];
        fpos[0] = pos[0] + GetRandomFloat(-150.0, 150.0);
        fpos[1] = pos[1] + GetRandomFloat(-150.0, 150.0);
        fpos[2] = pos[2] + 5.0;
        CreateFirePit(fpos, 5.0);
    }

    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(pos, 300.0, enemies);
    for (int i = 0; i < enemies.Length; i++)
    {
        int victim = enemies.Get(i);
        if (victim > 0 && IsValidEntity(victim))
            IgniteEntity(victim, 5.0);
    }
    delete enemies;
}

// ---- EFECTO 2: CONGELANTE -------------------------------------------------------
void Gfx_Freezer(int owner, const float pos[3], int sndEnt)
{
    ArrayList list = new ArrayList();
    PetCommonsInRadius(pos, 320.0, list);
    if (list.Length == 0)
    {
        EmitSoundToAll(SND_GLASS, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
        delete list;
        return;
    }

    if (g_hFreezeList == null) g_hFreezeList = new ArrayList();
    for (int i = 0; i < list.Length; i++)
    {
        int ent = EntRefToEntIndex(list.Get(i));
        if (ent == -1 || !IsValidEntity(ent)) continue;
        g_hFreezeList.Push(list.Get(i));
        SetEntityRenderColor(ent, 120, 200, 255, 230);
        if (owner > 0)
            PetDamage(ent, owner, 5.0, DMG_BULLET);   // mordisco del hielo
    }
    delete list;

    float now = GetGameTime();
    if (g_fFreezeUntil < now) g_fFreezeUntil = now;
    g_fFreezeUntil += 4.0;

    if (g_hFreezeTimer == null)
        g_hFreezeTimer = CreateTimer(0.2, Timer_FreezePulse, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    int ring[4] = {120, 200, 255, 230};
    TE_SetupBeamRingPoint(pos, 20.0, 340.0, g_sBeam, g_sBeam, 0, 100, 0.8, 20.0, 0.0, ring, 180, 0);
    TE_SendToAll();
    EmitSoundToAll(SND_GLASS, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
}

public Action Timer_FreezePulse(Handle timer)
{
    if (g_hFreezeList == null || GetGameTime() > g_fFreezeUntil)
    {
        if (g_hFreezeList != null)
        {
            for (int i = 0; i < g_hFreezeList.Length; i++)
            {
                int ent = EntRefToEntIndex(g_hFreezeList.Get(i));
                if (ent != -1 && IsValidEntity(ent))
                    SetEntityRenderColor(ent, 255, 255, 255, 255);
            }
            delete g_hFreezeList;
        }
        g_hFreezeTimer = null;
        return Plugin_Stop;
    }

    float zero[3] = {0.0, 0.0, 0.0};
    for (int i = g_hFreezeList.Length - 1; i >= 0; i--)
    {
        int ent = EntRefToEntIndex(g_hFreezeList.Get(i));
        if (ent == -1 || !IsValidEntity(ent) || !IsEnemyAlive(ent))
        {
            g_hFreezeList.Erase(i);
            continue;
        }
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, zero);
    }
    return Plugin_Continue;
}

// ---- EFECTO 3: ELECTRICA (cadena tesla) -------------------------------------------
void Gfx_Tesla(int owner, const float pos[3], int sndEnt)
{
    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(pos, 420.0, enemies);

    int color[4] = {160, 220, 255, 255};
    float prev[3], zapPos[3];
    CopyVector(pos, prev);
    int zapped = 0;

    while (zapped < 6 && enemies.Length > 0)
    {
        // el enemigo vivo mas cercano al punto anterior de la cadena
        int best = -1;
        int bestIdx = -1;
        float bestD = 999999.0;
        for (int i = 0; i < enemies.Length; i++)
        {
            int victim = enemies.Get(i);
            if (victim <= 0 || !IsValidEntity(victim) || !IsEnemyAlive(victim)) continue;
            float vPos[3];
            GetEntPropVector(victim, Prop_Send, "m_vecOrigin", vPos);
            float d = GetVectorDistance(prev, vPos);
            if (d < bestD) { bestD = d; best = victim; bestIdx = i; }
        }
        if (best == -1) break;

        GetEntPropVector(best, Prop_Send, "m_vecOrigin", zapPos);
        zapPos[2] += 40.0;
        PetBeam(prev, zapPos, color, 1.6, 0.12);
        if (owner > 0)
            PetDamage(best, owner, 35.0, DMG_BULLET);
        CopyVector(zapPos, prev);
        if (bestIdx >= 0) enemies.Erase(bestIdx);
        zapped++;
    }
    delete enemies;
    EmitSoundToAll(SND_GATLING, sndEnt, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.6, 240);
}

// ---- EFECTO 4: CEGADORA (aparta y aturde a la horda) -------------------------------
void Gfx_Flashbang(int owner, const float pos[3], int sndEnt)
{
    TE_SetupExplosion(pos, g_sExplosion, 3.0, 1, 0, 120, 40);
    TE_SendToAll();
    int ring[4] = {255, 255, 255, 240};
    TE_SetupBeamRingPoint(pos, 20.0, 420.0, g_sBeam, g_sBeam, 0, 60, 0.5, 30.0, 0.0, ring, 220, 0);
    TE_SendToAll();
    EmitSoundToAll(SND_AIRSTRIKE2, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    ArrayList list = new ArrayList();
    PetCommonsInRadius(pos, 380.0, list);
    for (int i = 0; i < list.Length; i++)
    {
        int ent = EntRefToEntIndex(list.Get(i));
        if (ent == -1 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;

        float vPos[3], dir[3], push[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        MakeVectorFromPoints(pos, vPos, dir);
        NormalizeVector(dir, dir);
        dir[2] += 0.8;
        NormalizeVector(dir, dir);
        push[0] = dir[0] * 380.0;
        push[1] = dir[1] * 380.0;
        push[2] = dir[2] * 380.0;
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
        if (owner > 0)
            PetDamage(ent, owner, 8.0, DMG_BLAST);
    }
    delete list;

    // a los especiales solo les molesta el destello: dano ligero sin empujon
    if (owner > 0)
    {
        ArrayList enemies = new ArrayList();
        PetEnemiesInRadius(pos, 380.0, enemies);
        for (int i = 0; i < enemies.Length; i++)
        {
            int victim = enemies.Get(i);
            if (victim > 0 && victim <= MaxClients)
                PetDamage(victim, owner, 15.0, DMG_BLAST);
        }
        delete enemies;
    }
}

// ---- EFECTO 5: AGUJERO NEGRO (succion + estallido final) ----------------------------
void Gfx_BlackHole(int owner, const float pos[3], int sndEnt)
{
    CopyVector(pos, g_vPullPos);
    g_iPullOwner = owner;

    ArrayList list = new ArrayList();
    PetCommonsInRadius(pos, 520.0, list);
    if (g_hPullList == null) g_hPullList = new ArrayList();
    for (int i = 0; i < list.Length; i++)
    {
        int ent = EntRefToEntIndex(list.Get(i));
        if (ent == -1 || !IsValidEntity(ent)) continue;
        g_hPullList.Push(list.Get(i));
    }
    delete list;

    float now = GetGameTime();
    if (g_fPullUntil < now) g_fPullUntil = now;
    g_fPullUntil += 3.0;

    if (g_hPullTimer == null)
        g_hPullTimer = CreateTimer(0.1, Timer_PullPulse, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    EmitSoundToAll(SND_MISSILE2, sndEnt, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER, _, 0.6, 90);
}

public Action Timer_PullPulse(Handle timer)
{
    if (g_hPullList == null || GetGameTime() > g_fPullUntil)
    {
        // estallido final del agujero negro
        if (g_iPullOwner > 0)
            PetExplosionDamage(g_iPullOwner, g_vPullPos, 320.0, 45.0, false);
        TE_SetupExplosion(g_vPullPos, g_sExplosion, 5.0, 1, 0, 200, 60);
        TE_SendToAll();
        delete g_hPullList;
        g_hPullTimer = null;
        g_iPullOwner = 0;
        return Plugin_Stop;
    }

    int ring[4] = {190, 90, 255, 200};
    TE_SetupBeamRingPoint(g_vPullPos, 180.0, 30.0, g_sBeam, g_sBeam, 0, 40, 0.12, 12.0, 0.0, ring, 150, 0);
    TE_SendToAll();

    for (int i = g_hPullList.Length - 1; i >= 0; i--)
    {
        int ent = EntRefToEntIndex(g_hPullList.Get(i));
        if (ent == -1 || !IsValidEntity(ent) || !IsEnemyAlive(ent))
        {
            g_hPullList.Erase(i);
            continue;
        }
        float vPos[3], dir[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        MakeVectorFromPoints(vPos, g_vPullPos, dir);
        NormalizeVector(dir, dir);
        ScaleVector(dir, 230.0);
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, dir);
    }
    return Plugin_Continue;
}

// ---- EFECTO 6: ANTIGRAVEDAD (la horda flota) ------------------------------------------
void Gfx_Antigravity(int owner, const float pos[3], int sndEnt)
{
    ArrayList list = new ArrayList();
    PetCommonsInRadius(pos, 350.0, list);

    if (g_hFloatList == null) g_hFloatList = new ArrayList();
    float up[3] = {0.0, 0.0, 260.0};
    for (int i = 0; i < list.Length; i++)
    {
        int ent = EntRefToEntIndex(list.Get(i));
        if (ent == -1 || !IsValidEntity(ent)) continue;
        g_hFloatList.Push(list.Get(i));
        SetEntityGravity(ent, 0.05);
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, up);
        if (owner > 0)
            PetDamage(ent, owner, 3.0, DMG_BULLET);   // tirón del despegue
    }
    delete list;

    float now = GetGameTime();
    if (g_fFloatUntil < now) g_fFloatUntil = now;
    g_fFloatUntil += 3.0;

    if (g_hFloatTimer == null)
        g_hFloatTimer = CreateTimer(0.25, Timer_FloatPulse, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    int ring[4] = {140, 220, 255, 200};
    TE_SetupBeamRingPoint(pos, 20.0, 380.0, g_sBeam, g_sBeam, 0, 90, 1.0, 15.0, 0.0, ring, 180, 0);
    TE_SendToAll();
    EmitSoundToAll(SND_JETPASS, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.5, 140);
}

public Action Timer_FloatPulse(Handle timer)
{
    if (g_hFloatList == null || GetGameTime() > g_fFloatUntil)
    {
        if (g_hFloatList != null)
        {
            for (int i = 0; i < g_hFloatList.Length; i++)
            {
                int ent = EntRefToEntIndex(g_hFloatList.Get(i));
                if (ent != -1 && IsValidEntity(ent))
                    SetEntityGravity(ent, 1.0);
            }
            delete g_hFloatList;
        }
        g_hFloatTimer = null;
        return Plugin_Stop;
    }

    // pequeño empujon extra cada pulso: flotan mas alto
    float up[3] = {0.0, 0.0, 120.0};
    for (int i = g_hFloatList.Length - 1; i >= 0; i--)
    {
        int ent = EntRefToEntIndex(g_hFloatList.Get(i));
        if (ent == -1 || !IsValidEntity(ent) || !IsEnemyAlive(ent))
        {
            g_hFloatList.Erase(i);
            continue;
        }
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, up);
    }
    return Plugin_Continue;
}

// ---- EFECTO 7: VAPORIZADOR (los comunes se esfuman) --------------------------------------
void Gfx_Vaporizer(int owner, const float pos[3], int sndEnt)
{
    ArrayList list = new ArrayList();
    PetCommonsInRadius(pos, 320.0, list);

    int ring[4] = {255, 255, 255, 250};
    TE_SetupBeamRingPoint(pos, 20.0, 360.0, g_sBeam, g_sBeam, 0, 60, 0.7, 25.0, 0.0, ring, 220, 0);
    TE_SendToAll();

    for (int i = 0; i < list.Length; i++)
    {
        int ent = EntRefToEntIndex(list.Get(i));
        if (ent == -1 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
        float vPos[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        PetBloodAt(vPos);
        if (owner > 0)
            PetDamage(ent, owner, 5000.0, DMG_BULLET);
    }
    delete list;
    EmitSoundToAll(SND_GATLING, sndEnt, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.7, 250);
}

// ---- EFECTO 8: CLUSTER DE FUEGO ------------------------------------------------------------
void Gfx_FireCluster(int owner, const float pos[3], int sndEnt)
{
    for (int f = 0; f < 6; f++)
    {
        float fpos[3];
        fpos[0] = pos[0] + GetRandomFloat(-300.0, 300.0);
        fpos[1] = pos[1] + GetRandomFloat(-300.0, 300.0);
        fpos[2] = pos[2] + 5.0;
        CreateFirePit(fpos, 6.0);
    }
    int ring[4] = {255, 120, 20, 220};
    TE_SetupBeamRingPoint(pos, 20.0, 620.0, g_sBeam, g_sBeam, 0, 90, 0.9, 22.0, 0.0, ring, 190, 0);
    TE_SendToAll();
    EmitSoundToAll(SND_MISSILE1, sndEnt, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER, _, 0.7, 120);

    if (owner > 0)
    {
        ArrayList enemies = new ArrayList();
        PetEnemiesInRadius(pos, 400.0, enemies);
        for (int i = 0; i < enemies.Length; i++)
        {
            int victim = enemies.Get(i);
            if (victim > 0 && IsValidEntity(victim))
                IgniteEntity(victim, 6.0);
        }
        delete enemies;
    }
}

// ---- EFECTO 9: METRALLA (lluvia de balas) ---------------------------------------------------
void Gfx_Shrapnel(int owner, const float pos[3], int sndEnt)
{
    float sky[3];
    sky[0] = pos[0];
    sky[1] = pos[1];
    sky[2] = pos[2] + 450.0;

    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(pos, 320.0, enemies);

    int color[4] = {255, 220, 120, 255};
    float hit[3];
    for (int s = 0; s < 10; s++)
    {
        if (enemies.Length > 0)
        {
            int victim = enemies.Get(GetRandomInt(0, enemies.Length - 1));
            if (victim > 0 && IsValidEntity(victim) && IsEnemyAlive(victim))
            {
                GetEntPropVector(victim, Prop_Send, "m_vecOrigin", hit);
                hit[2] += 40.0;
                hit[0] += GetRandomFloat(-20.0, 20.0);
                hit[1] += GetRandomFloat(-20.0, 20.0);
                PetBeam(sky, hit, color, 0.8, 0.10);
                if (owner > 0)
                    PetDamage(victim, owner, 12.0, DMG_BULLET);
                continue;
            }
        }
        // no quedan enemigos: metralla al suelo
        hit[0] = pos[0] + GetRandomFloat(-250.0, 250.0);
        hit[1] = pos[1] + GetRandomFloat(-250.0, 250.0);
        hit[2] = pos[2];
        PetBeam(sky, hit, color, 0.8, 0.10);
    }
    delete enemies;
    EmitSoundToAll(SND_GATLING, sndEnt, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.8, 130);
}

// (EFECTO 1 "Bola de fuego": usa la Gfx_Fireball del v2.2 - explosion de alto
//  calibre + charcos de fuego, el equivalente del BOMB del grenade.sp)

// ---- EFECTO 2: CLUSTER (se divide en 4 explosiones secundarias) --------------
void Gfx_Cluster(int owner, const float pos[3], int sndEnt)
{
    TE_SetupExplosion(pos, g_sExplosion, 3.0, 1, 0, 100, 30);
    TE_SendToAll();
    for (int i = 0; i < 4; i++)
    {
        DataPack pack = new DataPack();
        pack.WriteFloat(pos[0] + GetRandomFloat(-200.0, 200.0));
        pack.WriteFloat(pos[1] + GetRandomFloat(-200.0, 200.0));
        pack.WriteFloat(pos[2]);
        pack.WriteCell(owner);
        CreateTimer(0.25 + 0.2 * float(i), Timer_ClusterBoom, pack, TIMER_FLAG_NO_MAPCHANGE);
    }
    EmitSoundToAll(SND_MISSILE2, sndEnt, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.6, 160);
}

public Action Timer_ClusterBoom(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    float pos[3];
    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();
    int owner = pack.ReadCell();
    delete pack;
    if (owner <= 0) return Plugin_Stop;

    TE_SetupExplosion(pos, g_sExplosion, 4.0, 1, 0, 150, 45);
    TE_SendToAll();
    PetExplosionDamage(owner, pos, 150.0, 40.0, false);
    return Plugin_Stop;
}

// ---- EFECTO 3: FUEGOS ARTIFICIALES (lluvia de color y dano ligero) -----------
void Gfx_Firework(int owner, const float pos[3], int sndEnt)
{
    for (int i = 0; i < 14; i++)
    {
        float end[3];
        end[0] = pos[0] + GetRandomFloat(-60.0, 60.0);
        end[1] = pos[1] + GetRandomFloat(-60.0, 60.0);
        end[2] = pos[2] + GetRandomFloat(400.0, 750.0);
        int color[4];
        color[0] = GetRandomInt(100, 255);
        color[1] = GetRandomInt(80, 220);
        color[2] = GetRandomInt(80, 255);
        color[3] = 255;
        PetBeam(pos, end, color, 1.8, 0.5);
    }
    int ring[4] = {255, 120, 200, 230};
    TE_SetupBeamRingPoint(pos, 20.0, 420.0, g_sBeam, g_sBeam, 0, 90, 1.0, 20.0, 0.0, ring, 200, 0);
    TE_SendToAll();
    int ring2[4] = {120, 200, 255, 230};
    TE_SetupBeamRingPoint(pos, 20.0, 420.0, g_sBeam, g_sBeam, 0, 90, 0.8, 14.0, 0.0, ring2, 180, 0);
    TE_SendToAll();
    EmitSoundToAll(SND_AIRSTRIKE1, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    EmitSoundToAll(SND_AIRSTRIKE3, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    if (owner > 0)
        PetExplosionDamage(owner, pos, 260.0, 25.0, false);
}

// ---- EFECTO 4: HUMO CEGADOR (nube que frena a la horda) -----------------------
void Gfx_Smoke(int owner, const float pos[3], int sndEnt)
{
    int ring[4] = {180, 180, 180, 210};
    TE_SetupBeamRingPoint(pos, 20.0, 420.0, g_sBeam, g_sBeam, 0, 110, 2.5, 40.0, 0.0, ring, 160, 0);
    TE_SendToAll();
    TE_SetupBeamRingPoint(pos, 20.0, 300.0, g_sBeam, g_sBeam, 0, 110, 2.0, 30.0, 0.0, ring, 140, 0);
    TE_SendToAll();

    ArrayList list = new ArrayList();
    PetCommonsInRadius(pos, 360.0, list);
    if (g_hSlowList == null) g_hSlowList = new ArrayList();
    for (int i = 0; i < list.Length; i++)
    {
        int ent = EntRefToEntIndex(list.Get(i));
        if (ent == -1 || !IsValidEntity(ent)) continue;
        g_hSlowList.Push(list.Get(i));
        if (owner > 0)
            PetDamage(ent, owner, 4.0, DMG_BULLET);
    }
    delete list;

    float now = GetGameTime();
    if (g_fSlowUntil < now) g_fSlowUntil = now;
    g_fSlowUntil += 5.0;
    if (g_hSlowTimer == null)
        g_hSlowTimer = CreateTimer(0.15, Timer_SlowPulse, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    EmitSoundToAll(SND_JETPASS, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.4, 80);
}

public Action Timer_SlowPulse(Handle timer)
{
    if (g_hSlowList == null || GetGameTime() > g_fSlowUntil)
    {
        delete g_hSlowList;
        g_hSlowTimer = null;
        return Plugin_Stop;
    }
    for (int i = g_hSlowList.Length - 1; i >= 0; i--)
    {
        int ent = EntRefToEntIndex(g_hSlowList.Get(i));
        if (ent == -1 || !IsValidEntity(ent) || !IsEnemyAlive(ent))
        {
            g_hSlowList.Erase(i);
            continue;
        }
        float vel[3];
        GetEntPropVector(ent, Prop_Data, "m_vecVelocity", vel);
        ScaleVector(vel, 0.45);
        vel[2] = -20.0;
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, vel);
    }
    return Plugin_Continue;
}

// ---- EFECTO 7: ESCUDO (vida temporal para el equipo cercano) -------------------
void Gfx_Shield(int owner, const float pos[3], int sndEnt)
{
    int ring[4] = {0, 200, 255, 230};
    TE_SetupBeamRingPoint(pos, 20.0, 340.0, g_sBeam, g_sBeam, 0, 120, 1.4, 30.0, 0.0, ring, 210, 0);
    TE_SendToAll();

    int shielded = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2) continue;
        float vPos[3];
        GetEntPropVector(i, Prop_Send, "m_vecOrigin", vPos);
        if (GetVectorDistance(pos, vPos) > 320.0) continue;
        float buf = GetEntPropFloat(i, Prop_Send, "m_healthBuffer");
        SetEntPropFloat(i, Prop_Send, "m_healthBuffer", buf + 30.0);
        EmitSoundToClient(i, SND_REWARD);
        shielded++;
    }
    EmitSoundToAll(SND_AIRSTRIKE2, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    if (owner > 0 && shielded > 0 && IsClientInGame(owner))
        PrintToChat(owner, "%s \x04Escudo desplegado\x05: +30 de vida temporal a %d companeros.", CHAT_PREFIX, shielded);
}

// ---- EFECTO 9: QUIMICA (charco de acido con dano sostenido) -------------------
void Gfx_Chemical(int owner, const float pos[3], int sndEnt)
{
    CopyVector(pos, g_vAcidPos);
    g_iAcidOwner = owner;

    int ring[4] = {150, 255, 0, 220};
    TE_SetupBeamRingPoint(pos, 20.0, 280.0, g_sBeam, g_sBeam, 0, 100, 0.9, 18.0, 0.0, ring, 190, 0);
    TE_SendToAll();
    int ring2[4] = {80, 180, 0, 200};
    TE_SetupBeamRingPoint(pos, 20.0, 200.0, g_sBeam, g_sBeam, 0, 100, 1.6, 12.0, 0.0, ring2, 170, 0);
    TE_SendToAll();

    float now = GetGameTime();
    if (g_fAcidUntil < now) g_fAcidUntil = now;
    g_fAcidUntil += 5.0;
    if (g_hAcidTimer == null)
        g_hAcidTimer = CreateTimer(0.5, Timer_AcidPulse, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    EmitSoundToAll(SND_GLASS, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.8, 90);
}

public Action Timer_AcidPulse(Handle timer)
{
    if (GetGameTime() > g_fAcidUntil)
    {
        g_hAcidTimer = null;
        g_iAcidOwner = 0;
        return Plugin_Stop;
    }
    if (g_iAcidOwner > 0)
    {
        ArrayList enemies = new ArrayList();
        PetEnemiesInRadius(g_vAcidPos, 240.0, enemies);
        for (int i = 0; i < enemies.Length; i++)
        {
            int victim = enemies.Get(i);
            if (victim > 0 && IsValidEntity(victim))
                PetDamage(victim, g_iAcidOwner, 8.0, DMG_BURN);
        }
        delete enemies;
    }
    return Plugin_Continue;
}

// ---- EFECTO 12: EXTINTOR (apaga fuegos y quema cero) --------------------------
void Gfx_Extinguisher(const float pos[3], int sndEnt)
{
    int ring[4] = {120, 180, 255, 220};
    TE_SetupBeamRingPoint(pos, 20.0, 380.0, g_sBeam, g_sBeam, 0, 100, 0.8, 22.0, 0.0, ring, 190, 0);
    TE_SendToAll();
    TE_SetupBeamRingPoint(pos, 20.0, 260.0, g_sBeam, g_sBeam, 0, 100, 1.2, 30.0, 0.0, ring, 170, 0);
    TE_SendToAll();

    // apaga al equipo y compensa quemaduras leves
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2) continue;
        float vPos[3];
        GetEntPropVector(i, Prop_Send, "m_vecOrigin", vPos);
        if (GetVectorDistance(pos, vPos) > 380.0) continue;
        if (GetEntProp(i, Prop_Send, "m_fFlags") & FL_ONFIRE)
        {
            ExtinguishEntity(i);
            int hp = GetClientHealth(i);
            int maxhp = GetEntProp(i, Prop_Data, "m_iMaxHealth");
            if (maxhp <= 0) maxhp = 100;
            if (hp < maxhp) SetEntityHealth(i, hp + 8 > maxhp ? maxhp : hp + 8);
        }
    }

    // apaga los fuegos creados por el propio sistema (petfire*)
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "env_fire")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        char tn[48];
        GetEntPropString(ent, Prop_Data, "m_iName", tn, sizeof(tn));
        if (StrContains(tn, "petfire") == 0)
        {
            float fPos[3];
            GetEntPropVector(ent, Prop_Send, "m_vecOrigin", fPos);
            if (GetVectorDistance(pos, fPos) < 400.0)
                AcceptEntityInput(ent, "kill");
        }
    }

    // apaga a los comunes ardiendo
    ArrayList list = new ArrayList();
    PetCommonsInRadius(pos, 380.0, list);
    for (int i = 0; i < list.Length; i++)
    {
        int e = EntRefToEntIndex(list.Get(i));
        if (e != -1 && IsValidEntity(e))
            ExtinguishEntity(e);
    }
    delete list;
    EmitSoundToAll(SND_GLASS, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.6, 120);
}

// ---- EFECTO 13: BRILLO (ilumina y marca a los enemigos) -----------------------
void Gfx_Glow(const float pos[3], int sndEnt)
{
    int ring[4] = {255, 200, 80, 230};
    TE_SetupBeamRingPoint(pos, 20.0, 460.0, g_sBeam, g_sBeam, 0, 120, 1.2, 26.0, 0.0, ring, 200, 0);
    TE_SendToAll();
    TE_SetupGlowSprite(pos, g_sExplosion, 3.0, 160.0, 180);
    TE_SendToAll();

    // marca brillante a los enemigos cercanos
    ArrayList list = new ArrayList();
    PetCommonsInRadius(pos, 420.0, list);
    if (g_hMarkList == null) g_hMarkList = new ArrayList();
    for (int i = 0; i < list.Length; i++)
    {
        int ent = EntRefToEntIndex(list.Get(i));
        if (ent == -1 || !IsValidEntity(ent)) continue;
        g_hMarkList.Push(list.Get(i));
        SetEntityRenderColor(ent, 255, 200, 60, 255);
    }
    delete list;

    float now = GetGameTime();
    if (g_fMarkUntil < now) g_fMarkUntil = now;
    g_fMarkUntil += 10.0;
    if (g_hMarkTimer == null)
        g_hMarkTimer = CreateTimer(1.0, Timer_MarkPulse, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    EmitSoundToAll(SND_AIRSTRIKE3, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
}

public Action Timer_MarkPulse(Handle timer)
{
    if (g_hMarkList == null || GetGameTime() > g_fMarkUntil)
    {
        if (g_hMarkList != null)
        {
            for (int i = 0; i < g_hMarkList.Length; i++)
            {
                int ent = EntRefToEntIndex(g_hMarkList.Get(i));
                if (ent != -1 && IsValidEntity(ent))
                    SetEntityRenderColor(ent, 255, 255, 255, 255);
            }
            delete g_hMarkList;
        }
        g_hMarkTimer = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// ---- EFECTO 17: FLAK ANTIAEREO (metralla vertical en columna) ------------------
void Gfx_Flak(int owner, const float pos[3], int sndEnt)
{
    for (int s = 0; s < 12; s++)
    {
        float start[3], end[3];
        float ang = DegToRad(GetRandomFloat(0.0, 360.0));
        float rr = GetRandomFloat(60.0, 240.0);
        start[0] = pos[0] + Cosine(ang) * rr;
        start[1] = pos[1] + Sine(ang) * rr;
        start[2] = pos[2] + 10.0;
        end[0] = start[0] + GetRandomFloat(-80.0, 80.0);
        end[1] = start[1] + GetRandomFloat(-80.0, 80.0);
        end[2] = start[2] + GetRandomFloat(450.0, 800.0);
        int color[4] = {255, 120, 120, 255};
        PetBeam(start, end, color, 1.2, 0.35);
    }

    if (owner > 0)
    {
        ArrayList enemies = new ArrayList();
        PetEnemiesInRadius(pos, 300.0, enemies);
        for (int i = 0; i < enemies.Length; i++)
        {
            int victim = enemies.Get(i);
            if (victim <= 0 || !IsValidEntity(victim)) continue;
            float vPos[3];
            GetEntPropVector(victim, Prop_Send, "m_vecOrigin", vPos);
            float flat[3];
            flat[0] = vPos[0];
            flat[1] = vPos[1];
            flat[2] = pos[2];
            if (GetVectorDistance(flat, pos) < 260.0 && vPos[2] > pos[2] - 50.0 && vPos[2] < pos[2] + 700.0)
            {
                PetBloodAt(vPos);
                PetDamage(victim, owner, 30.0, DMG_BULLET);
            }
        }
        delete enemies;
    }
    EmitSoundToAll(SND_GATLING, sndEnt, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.8, 250);
}

// ---- EFECTO 18: BOMBARDEO AEREO (cadena de explosiones diferidas) --------------
void Gfx_Airstrike(int owner, const float pos[3], int sndEnt)
{
    // bengala roja de marcaje
    float flareEnd[3];
    flareEnd[0] = pos[0];
    flareEnd[1] = pos[1];
    flareEnd[2] = pos[2] + 500.0;
    int flare[4] = {255, 60, 60, 255};
    PetBeam(pos, flareEnd, flare, 3.0, 1.5);

    DoAirstrikeAt(owner, pos, 8, 55.0, 190.0);
    EmitSoundToAll(SND_AIRSTRIKE1, sndEnt, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER);
}

// ---- EFECTO 19: ARMA SORPRESA (suelta un arma de suministros) ------------------
void Gfx_Weapon(int owner, const float pos[3], int sndEnt)
{
    char cls[26];
    strcopy(cls, sizeof(cls), g_WeaponDropList[GetRandomInt(0, 7)]);

    int wpn = CreateEntityByName(cls);
    if (wpn != -1)
    {
        float wPos[3];
        CopyVector(pos, wPos);
        wPos[2] += 10.0;
        DispatchKeyValueVector(wpn, "origin", wPos);
        DispatchSpawn(wpn);
    }

    int ring[4] = {255, 255, 0, 230};
    TE_SetupBeamRingPoint(pos, 20.0, 300.0, g_sBeam, g_sBeam, 0, 90, 1.0, 20.0, 0.0, ring, 200, 0);
    TE_SendToAll();
    EmitSoundToAll(SND_REWARD, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    if (owner > 0 && IsClientInGame(owner))
        PrintToChat(owner, "%s \x04Arma sorpresa\x05: la granada solto un arma de suministros!", CHAT_PREFIX);
}


// ===========================================================================
// v2.4/v2.6: LENGUA DE SMOKER — la nave engancha y ARRASTRA a su presa
// Probabilidad: 10% en Nv 1, +2.5% por nivel, tope 40% (se alcanza en Nv 13)
// v2.6: SOLO infectados especiales (nunca comunes) + agarre manual GARANTIZADO
// (la presa cuelga congelada, es arrastrada a la boca del F18, muerde con
// danos por tick y suelta con latigazo) + autodestruccion de la particula a
// los 4 s: la lengua agarra DE VERDAD y SIEMPRE desaparece.
// ===========================================================================

// v2.6: presa valida para la lengua — solo especiales "agarrables"
bool IsTonguePreyValid(int owner, int si)
{
    if (si < 1 || si > MaxClients) return false;
    if (!IsClientInGame(si) || !IsPlayerAlive(si)) return false;
    if (GetClientTeam(si) != 3) return false;
    if (GetEntProp(si, Prop_Send, "m_zombieClass") == 8) return false;   // tank: no
    if (GetEntProp(si, Prop_Send, "m_isGhost")) return false;             // fantasma: no
    if (PetPinningVictim(si) != -1) return false;                         // montado sobre alguien: no
    // presa ya colgada de la lengua de otra nave: no se roba
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == owner || g_TongueRef[i] == -1) continue;
        if (EntRefToEntIndex(g_TongueRef[i]) == si) return false;
    }
    return true;
}

// v2.6: elige a quien enganchar — si la nave esta peleando con la horda
// (comunes), busca ella sola el especial cercano: la lengua NUNCA va tras
// un comun (los comunes no son agarrables)
int PickTonguePrey(int client, int body, int myEnemy)
{
    if (IsTonguePreyValid(client, myEnemy)) return myEnemy;

    float bPos[3];
    GetEntPropVector(body, Prop_Send, "m_vecOrigin", bPos);
    float best = 1500.0;                     // alcance maximo de la lengua
    int prey = -1;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsTonguePreyValid(client, i)) continue;
        float pPos[3];
        GetEntPropVector(i, Prop_Send, "m_vecOrigin", pPos);
        float d = GetVectorDistance(bPos, pPos);
        if (d < best) { best = d; prey = i; }
    }
    return prey;
}

void TrySmokerTongue(int client, int body, int target)
{
    if (g_TongueRef[client] != -1) return;   // ya hay una lengua activa

    // v2.6: la lengua SOLO va tras infectados especiales; si el objetivo
    // actual de la nave no lo es, se busca el especial cercano
    int prey = PickTonguePrey(client, body, target);
    if (prey == -1) return;                  // sin especial agarrable cerca

    // linea de tiro hasta la presa: la lengua no atraviesa muros...
    int blocker = 0;
    if (!PetLOS(client, body, prey, blocker))
    {
        // ...salvo que quien bloquee sea OTRO especial: el tongue del juego
        // engancha al primero que se cruza — esta lengua hace lo mismo
        if (!IsTonguePreyValid(client, blocker))
            return;
        prey = blocker;                      // redirigida al que se cruzo
    }

    float now = GetGameTime();
    if (now < g_NextTongueAt[client] || now < g_NextTongueRollAt[client]) return;
    g_NextTongueRollAt[client] = now + 1.2;   // tirada como maximo cada 1.2 s

    int chance = RoundToFloor(PetTongueChance(client));
    if (GetRandomInt(1, 100) > chance) return;

    // lengua autentica: la particula smoker_tongue DEL JUEGO vuela hasta la
    // presa, la engancha y la ARRASTRA hasta la boca de la nave
    if (!CreatePetTongue(client, body))
    {
        g_NextTongueAt[client] = now + 2.0;   // sin particula: reintento pronto
        return;
    }

    g_TongueRef[client] = EntIndexToEntRef(prey);
    g_TonguePhase[client] = 0;                // fase 0: vuelo hacia la presa
    g_TongueFlightEnd[client] = now + 1.2;    // techo del vuelo (1500 u/s)
    g_TongueUntil[client] = now + 3.6;        // vuelo (1.2) + arrastre (2.3)
    g_TongueDamageDone[client] = 0.0;
    g_NextTongueAt[client] = now + 7.0;

    int snd = GetPetSoundEnt(client, body);
    if (g_bTongueSnd)
        EmitSoundToAll(SND_SMOKER_TONGUE, snd, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 100);
    else
        EmitSoundToAll(SND_GLASS, snd, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.9, 60);

    CreateTimer(0.1, Timer_TongueDrag, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    if (IsValidClient(client))
    {
        char preyName[16];
        PetSIName(prey, preyName, sizeof(preyName));
        PrintToChat(client, "%s \x04Lengua de Smoker\x05: disparada contra un \x04%s\x05 (%d%%).",
            CHAT_PREFIX, preyName, chance);
    }
}

public Action Timer_TongueDrag(Handle timer, any data)
{
    int client = GetClientOfUserId(view_as<int>(data));
    if (!IsValidClient(client) || !IsPlayerAlive(client) || !PetIsActive(client) || g_TongueRef[client] == -1)
    {
        CleanupTongue(client);
        return Plugin_Stop;
    }

    int body = EntRefToEntIndex(g_PetBody[client]);
    int target = EntRefToEntIndex(g_TongueRef[client]);
    if (body == -1 || !IsValidEntity(body)
        || target == -1 || !IsValidEntity(target)
        || !IsEnemyAlive(target)
        || GetGameTime() > g_TongueUntil[client])
    {
        // timeout o presa muerta: si ya estaba agarrada, latigazo de salida
        FinishTongue(client, target, g_TonguePhase[client] == 1);
        return Plugin_Stop;
    }

    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", tPos);
    tPos[2] += 50.0;    // colgada a la altura del pecho

    int tip = EntRefToEntIndex(g_TongueTipRef[client]);

    // ---- fase 0: la lengua VUELA hasta la presa (1500 u/s) ----------------
    if (g_TonguePhase[client] == 0)
    {
        if (tip == -1 || !IsValidEntity(tip))
        {
            MissTongue(client);
            return Plugin_Stop;
        }

        // v2.6: si OTRO especial se cruzo en la trayectoria, la lengua lo
        // engancha a EL (el tongue real agarra al primero que toca);
        // si fue un muro/prop, la lengua se retrae sin latigazo
        int blocker = 0;
        if (!PetLOS(client, body, target, blocker) && blocker != target)
        {
            if (IsTonguePreyValid(client, blocker))
            {
                target = blocker;
                g_TongueRef[client] = EntIndexToEntRef(target);
                GetEntPropVector(target, Prop_Send, "m_vecOrigin", tPos);
                tPos[2] += 50.0;
            }
            else
            {
                MissTongue(client);
                return Plugin_Stop;
            }
        }

        float tipPos[3], step[3];
        GetEntPropVector(tip, Prop_Data, "m_vecOrigin", tipPos);
        MakeVectorFromPoints(tipPos, tPos, step);
        float dist = GetVectorLength(step);
        if (dist < 150.0)
        {
            TeleportEntity(tip, tPos, NULL_VECTOR, NULL_VECTOR);
            StartTongueGrab(client, target);       // contacto: engancha
        }
        else if (GetGameTime() > g_TongueFlightEnd[client])
        {
            MissTongue(client);                    // no llego: se retrae
            return Plugin_Stop;
        }
        else
        {
            ScaleVector(step, 150.0 / dist);
            AddVectors(tipPos, step, step);
            TeleportEntity(tip, step, NULL_VECTOR, NULL_VECTOR);
            return Plugin_Continue;
        }
    }

    // ---- fase 1: AGARRE — la presa cuelga y es arrastrada a la nave -------
    if (tip != -1 && IsValidEntity(tip))
        TeleportEntity(tip, tPos, NULL_VECTOR, NULL_VECTOR);

    // v2.6: la lengua se CORTA solo si el mundo/prop se interpuso entre la
    // nave y su presa (los infectados jamas la rompen: pasa entre ellos)
    int blocker2 = 0;
    if (!PetLOS(client, body, target, blocker2) && blocker2 != target)
    {
        bool passThrough = false;
        if (blocker2 > MaxClients && IsValidEntity(blocker2))
        {
            char bcls[24];
            if (GetEntityClassname(blocker2, bcls, sizeof(bcls))
                && StrEqual(bcls, "infected"))
                passThrough = true;    // un comun no corta la lengua
        }
        if (!passThrough)
        {
            FinishTongue(client, target, false);   // muro: cortada, sin latigazo
            return Plugin_Stop;
        }
    }

    // v2.6: mordida de la lengua mientras arrastra (cada 0.5 s)
    float now = GetGameTime();
    if (now >= g_TongueNextTickAt[client])
    {
        g_TongueNextTickAt[client] = now + 0.5;
        float tickDmg = 8.0 * PetTongueMult(client);   // v3.0: +0.30/nivel
        PetDamage(target, client, tickDmg, DMG_CLUB);
        g_TongueDamageDone[client] += tickDmg;
        PetBloodAt(tPos);
        if (!IsPlayerAlive(target))    // murio colgada: fuera
        {
            FinishTongue(client, target, false);
            return Plugin_Stop;
        }
    }

    if (GetVectorDistance(muzzle, tPos) < 95.0)
    {
        FinishTongue(client, target, true);        // llego a la nave: latigazo
        return Plugin_Stop;
    }

    // arrastre: la presa congela y es halada hacia la boca del F18 (420 u/s)
    float drag[3];
    MakeVectorFromPoints(tPos, muzzle, drag);
    NormalizeVector(drag, drag);
    ScaleVector(drag, 42.0);           // 42 u por tick de 0.1 s
    AddVectors(tPos, drag, drag);
    TeleportEntity(target, drag, NULL_VECTOR, NULL_VECTOR);
    return Plugin_Continue;
}

// v2.6: contacto de la lengua — la presa queda COLGANDO (agarre manual)
void StartTongueGrab(int client, int target)
{
    g_TonguePhase[client] = 1;
    g_TongueUntil[client] = GetGameTime() + 2.3;   // ventana de arrastre
    g_TongueNextTickAt[client] = GetGameTime() + 0.5;

    // AGARRE MANUAL GARANTIZADO: el engine nunca confirma el
    // GrabVictimWithTongue contra zombies, asi que la lengua de la nave
    // congela a la presa (cuelga del tip) y el timer la ARRASTRA hasta la
    // boca del F18 mordiendola (dano por tick) y soltandola con latigazo
    g_TongueSavedMoveType[client] = GetEntityMoveType(target);
    SetEntityMoveType(target, MOVETYPE_NONE);
    float stop[3];
    TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, stop);
    g_TongueManualGrab[client] = true;

    EmitSoundToAll(SND_GLASS, target, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.6, 110);
    if (IsValidClient(client))
    {
        char preyName[16];
        PetSIName(target, preyName, sizeof(preyName));
        PrintToChat(client, "%s \x04Lengua de Smoker\x05: engancho a un \x04%s\x05 — arrastrandolo.",
            CHAT_PREFIX, preyName);
    }

    // v3.0: compatibilidad con Vs — si la presa es una jugadora (infectado
    // humano), se le avisa de quien la engancho: no es un freeze misterioso,
    // es la lengua de la nave de su rival
    if (!IsFakeClient(target) && client > 0 && IsClientInGame(client))
        PrintToChat(target, "%s \x04Una lengua de la nave de %N te ha enganchado\x05 y te arrastra hacia ella.",
            CHAT_PREFIX, client);
}

// v2.6: suelta a la presa (restaura SIEMPRE su movimiento original)
void ReleaseTongueVictim(int client, int victim)
{
    if (client < 1 || client > MaxClients || !g_TongueManualGrab[client]) return;
    g_TongueManualGrab[client] = false;

    if (victim > 0 && victim <= MaxClients && IsClientInGame(victim) && IsPlayerAlive(victim))
        SetEntityMoveType(victim, g_TongueSavedMoveType[client]);
}

void FinishTongue(int client, int target, bool whip)
{
    ReleaseTongueVictim(client, target);
    KillPetTongueEntities(client);
    g_TongueRef[client] = -1;
    g_TongueUntil[client] = 0.0;
    g_TonguePhase[client] = 0;

    if (!whip) return;
    if (target == -1 || !IsValidEntity(target) || !IsEnemyAlive(target) || !PetIsActive(client)) return;

    float tPos[3];
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", tPos);
    tPos[2] += 40.0;
    PetBloodAt(tPos);

    int body = EntRefToEntIndex(g_PetBody[client]);
    if (body != -1 && IsValidEntity(body))
    {
        float muzzle[3];
        GetPetMuzzle(body, muzzle);
        int tongue[4] = {70, 140, 60, 255};
        PetBeam(muzzle, tPos, tongue, 3.0, 0.25);      // chasquido del latigazo
    }

    float dmg = 30.0 * PetTongueMult(client);   // v3.0: +0.30/nivel
    PetDamage(target, client, dmg, DMG_CLUB);
    g_TongueDamageDone[client] += dmg;
    EmitSoundToAll(SND_GLASS, target, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.8, 70);
    if (IsValidClient(client))
        PrintToChat(client, "%s La lengua solto al especial: \x04%d de dano\x05 (mordidas + latigazo).",
            CHAT_PREFIX, RoundToFloor(g_TongueDamageDone[client]));
}

// v2.6: la lengua no llego a la presa — se retrae sin latigazo
void MissTongue(int client)
{
    KillPetTongueEntities(client);
    g_TongueRef[client] = -1;
    g_TongueUntil[client] = 0.0;
    g_TonguePhase[client] = 0;
    g_NextTongueAt[client] = GetGameTime() + 2.5;      // reintento pronto
}

// v2.6: limpieza total de la lengua de un jugador (suelta SIEMPRE a la presa)
void CleanupTongue(int client)
{
    int target = -1;
    if (client >= 1 && client <= MaxClients && g_TongueRef[client] != -1)
        target = EntRefToEntIndex(g_TongueRef[client]);

    ReleaseTongueVictim(client, target);
    KillPetTongueEntities(client);

    if (client >= 1 && client <= MaxClients)
    {
        g_TongueRef[client] = -1;
        g_TongueUntil[client] = 0.0;
        g_TonguePhase[client] = 0;
    }
}

// v2.6: crea la lengua REAL de smoker (particula del juego + punta voladora)
bool CreatePetTongue(int client, int body)
{
    if (body <= 0 || !IsValidEntity(body)) return false;
    if (!g_bTongueFx) return false;                    // particula no disponible
    if (GetEntityCount() > MAX_EDICTS_SAFE - 4) return false;

    // punta de la lengua: la particula se dibuja entre el fx y este punto
    int tip = CreateEntityByName("info_particle_target");
    if (tip == -1) return false;
    char tipName[32];
    Format(tipName, sizeof(tipName), "pettongue%d_%d", tip, client);
    DispatchKeyValue(tip, "targetname", tipName);
    DispatchKeyValue(tip, "spawnflags", "0");
    DispatchSpawn(tip);
    // v2.6: AUTODESTRUCCION GARANTIZADA a los 4 s — la lengua JAMAS puede
    // quedar dibujada para siempre (aunque el plugin o su timer fallen)
    SetVariantString("OnUser1 !self:Kill::4.0:-1");
    AcceptEntityInput(tip, "AddOutput");
    AcceptEntityInput(tip, "FireUser1");

    // sistema de particulas con el efecto smoker_tongue DEL JUEGO
    int fx = CreateEntityByName("info_particle_system");
    if (fx == -1)
    {
        AcceptEntityInput(tip, "kill");
        return false;
    }
    char fxName[32];
    Format(fxName, sizeof(fxName), "pettonguefx%d_%d", fx, client);
    DispatchKeyValue(fx, "targetname", fxName);
    DispatchKeyValue(fx, "effect_name", "smoker_tongue");
    DispatchKeyValue(fx, "cpoint1", tipName);
    DispatchSpawn(fx);

    // la lengua nace en la boca del F18 y sigue a la nave mientras vuela
    float muzzle[3], bodyPos[3], rel[3];
    GetPetMuzzle(body, muzzle);
    GetEntPropVector(body, Prop_Send, "m_vecOrigin", bodyPos);
    MakeVectorFromPoints(bodyPos, muzzle, rel);
    TeleportEntity(tip, muzzle, NULL_VECTOR, NULL_VECTOR);
    SetVariantString("!activator");
    AcceptEntityInput(fx, "SetParent", body);
    TeleportEntity(fx, rel, NULL_VECTOR, NULL_VECTOR);
    ActivateEntity(fx);
    AcceptEntityInput(fx, "Start");
    // v2.6: mismo failsafe para el fx (4 s de vida maxima garantizada)
    SetVariantString("OnUser1 !self:Kill::4.0:-1");
    AcceptEntityInput(fx, "AddOutput");
    AcceptEntityInput(fx, "FireUser1");

    g_TongueTipRef[client] = EntIndexToEntRef(tip);
    g_TongueFxRef[client] = EntIndexToEntRef(fx);
    return true;
}

// v2.5/v2.6/v2.8: elimina fx + punta de la lengua. El failsafe de 4 s de
// la creacion cubre cualquier caso que esta limpieza no alcance.
static const float VOID_VECTOR[3] = {0.0, 0.0, 0.0};   // patron del l4d2_play_as_si

void KillPetTongueEntities(int client)
{
    int refs[2];
    refs[0] = g_TongueFxRef[client];
    refs[1] = g_TongueTipRef[client];
    g_TongueFxRef[client] = -1;
    g_TongueTipRef[client] = -1;

    for (int i = 0; i < 2; i++)
    {
        int ent = (refs[i] != -1) ? EntRefToEntIndex(refs[i]) : -1;
        if (ent <= 0 || !IsValidEntity(ent) || !IsValidEdict(ent)) continue;
        char cls[24];
        if (!GetEntityClassname(ent, cls, sizeof(cls))) continue;
        if (!StrEqual(cls, "info_particle_system", false)
            && !StrEqual(cls, "info_particle_target", false)) continue;

        // v2.8: patron EXACTO de la referencia (KillSmokerTongue): si la
        // particula muere pegada a la presa (o a su cadaver), el engine
        // deja el filamento dibujado en el aire. Se detiene la emision,
        // se desengancha del cuerpo de la nave, se MANDA AL VACIO y se
        // mata alli con retardo de 1.0 s — cualquier residuo cae
        // en el origen del mapa, nunca en mitad de la partida
        AcceptEntityInput(ent, "Stop");          // (solo el fx lo usa)
        AcceptEntityInput(ent, "ClearParent");
        TeleportEntity(ent, VOID_VECTOR, NULL_VECTOR, NULL_VECTOR);
        SetVariantString("OnUser1 !self:Kill::1.0:-1");
        AcceptEntityInput(ent, "AddOutput");
        AcceptEntityInput(ent, "FireUser1");
    }
}

// v2.5: registra un nombre de particula en la tabla de strings del engine
// (misma tecnica que usa el l4d2_play_as_si para la smoker_tongue)
bool PetPrecacheParticle(const char[] effectName)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE)
        table = FindStringTable("ParticleEffectNames");
    if (table == INVALID_STRING_TABLE)
        return false;
    bool save = LockStringTables(false);
    AddToStringTable(table, effectName);
    LockStringTables(save);
    return true;
}


// ===========================================================================
// v2.4: MINAS DE PROXIMIDAD (pasiva, Nv 6) — objetos que parecen minas;
// estallan a los segundos o cuando detectan zombies cercanos
// ===========================================================================
void MaybeDropMine(int client, int body, int myEnemy)
{
    if (g_PetLevel[client] < 6 || !g_PetMines[client]) return;
    float now = GetGameTime();
    if (now < g_NextMineAt[client]) return;
    g_NextMineAt[client] = now + 6.0;   // cadencia de soltado

    if (GetEntityCount() > MAX_EDICTS_SAFE) return;
    if (g_iActiveMines >= MINE_HARD_CAP) return;

    // solo con combate activo o horda rondando a la duena
    bool want = (myEnemy != -1);
    if (!want)
    {
        float cPos[3];
        GetEntPropVector(client, Prop_Send, "m_vecOrigin", cPos);
        ArrayList near = new ArrayList();
        PetCommonsInRadius(cPos, 450.0, near);
        want = (near.Length >= 2);
        delete near;
    }
    if (!want) return;

    // maximo 4 minas activas por duena
    int own = 0;
    if (g_hMineList != null)
    {
        for (int i = 0; i < g_hMineList.Length; i++)
        {
            int ent = EntRefToEntIndex(g_hMineList.Get(i));
            if (ent != -1 && ent < 2048 && g_MineOwner[ent] == client) own++;
        }
    }
    if (own >= 4) return;

    // punto de suelo bajo la nave (no deja minas en el vacio)
    float muzzle[3];
    GetPetMuzzle(body, muzzle);
    float angDown[3] = {90.0, 0.0, 0.0};
    Handle tr = TR_TraceRayEx(muzzle, angDown, MASK_SOLID_BRUSHONLY, RayType_Infinite);
    if (tr == null) return;
    if (!TR_DidHit(tr)) { CloseHandle(tr); return; }
    float mpos[3];
    TR_GetEndPosition(mpos, tr);
    CloseHandle(tr);
    mpos[2] += 8.0;
    if (GetVectorDistance(muzzle, mpos) > 500.0) return;

    DropMine(client, mpos);
}

void DropMine(int client, const float pos[3])
{
    int mine = CreateEntityByName("prop_dynamic_override");
    if (mine == -1) return;
    if (mine < 0 || mine >= 2048) { AcceptEntityInput(mine, "kill"); return; }

    char name[32];
    Format(name, sizeof(name), "petmine%d", mine);
    DispatchKeyValue(mine, "model", MDL_PIPEBOMB);
    DispatchKeyValue(mine, "targetname", name);
    DispatchKeyValue(mine, "solid", "0");
    float dpos[3];
    CopyVector(pos, dpos);
    DispatchKeyValueVector(mine, "origin", dpos);
    DispatchSpawn(mine);
    SetEntPropFloat(mine, Prop_Send, "m_flModelScale", 0.8);
    float ang[3];
    ang[0] = 0.0; ang[1] = GetRandomFloat(0.0, 360.0); ang[2] = 0.0;
    TeleportEntity(mine, NULL_VECTOR, ang, NULL_VECTOR);

    // luz roja de aviso pegada a la mina
    if (GetEntityCount() < MAX_EDICTS_SAFE && g_sGlow != 0)
    {
        int glow = CreateEntityByName("env_glow");
        if (glow != -1)
        {
            DispatchKeyValue(glow, "model", "sprites/glow01.vmt");
            DispatchKeyValue(glow, "parentname", name);
            DispatchKeyValue(glow, "rendercolor", "255 60 45");
            DispatchKeyValue(glow, "renderamt", "200");
            DispatchKeyValue(glow, "scale", "0.55");
            DispatchSpawn(glow);
            SetVariantString(name);
            AcceptEntityInput(glow, "SetParent", glow, glow, 0);
        }
    }

    g_MineOwner[mine] = client;
    g_MineBoomAt[mine] = GetGameTime() + MINE_LIFE;
    if (g_hMineList == null) g_hMineList = new ArrayList();
    g_hMineList.Push(EntIndexToEntRef(mine));
    g_iActiveMines++;

    if (g_hMineTimer == null)
        g_hMineTimer = CreateTimer(0.25, Timer_MinePulse, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    int ring[4] = {255, 90, 70, 200};
    TE_SetupBeamRingPoint(pos, 8.0, 90.0, g_sBeam, g_sBeam, 0, 40, 0.4, 6.0, 0.0, ring, 160, 0);
    TE_SendToAll();
}

public Action Timer_MinePulse(Handle timer)
{
    if (g_hMineList == null || g_hMineList.Length == 0)
    {
        g_hMineTimer = null;
        return Plugin_Stop;
    }

    static bool scanTick = false;
    scanTick = !scanTick;   // deteccion de proximidad cada 0.5 s

    float now = GetGameTime();
    for (int i = g_hMineList.Length - 1; i >= 0; i--)
    {
        int ent = EntRefToEntIndex(g_hMineList.Get(i));
        if (ent == -1 || ent >= 2048 || !IsValidEntity(ent) || g_MineOwner[ent] == -1)
        {
            ClearMineAt(i, false);
            continue;
        }

        // valida que el indice no se haya reciclado con otra entidad
        char cls[32], tname[32];
        if (!GetEntityClassname(ent, cls, sizeof(cls))
            || !StrEqual(cls, "prop_dynamic_override")
            || !GetEntPropString(ent, Prop_Data, "m_iName", tname, sizeof(tname))
            || StrContains(tname, "petmine") != 0)
        {
            ClearMineAt(i, false);
            continue;
        }

        // mecha agotada: estalla sola
        if (now >= g_MineBoomAt[ent])
        {
            DetonateMine(i, ent);
            continue;
        }

        // deteccion de zombies cercanos
        if (scanTick)
        {
            float mpos[3];
            GetEntPropVector(ent, Prop_Send, "m_vecOrigin", mpos);
            ArrayList near = new ArrayList();
            PetEnemiesInRadius(mpos, MINE_TRIPRADIUS, near);
            bool trip = (near.Length > 0);
            delete near;
            if (trip) DetonateMine(i, ent);
        }
    }
    return Plugin_Continue;
}

void DetonateMine(int slot, int ent)
{
    int owner = g_MineOwner[ent];
    float pos[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);

    TE_SetupExplosion(pos, g_sExplosion, 5.0, 1, 0, RoundToFloor(MINE_DMG_RADIUS), RoundToFloor(MINE_DMG));
    TE_SendToAll();
    int ring[4] = {255, 150, 60, 220};
    TE_SetupBeamRingPoint(pos, 15.0, 240.0, g_sBeam, g_sBeam, 0, 70, 0.5, 16.0, 0.0, ring, 190, 0);
    TE_SendToAll();
    EmitSoundToAll(SND_MISSILE1, ent, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE);

    if (owner > 0 && IsValidClient(owner))
        PetExplosionDamage(owner, pos, MINE_DMG_RADIUS, MINE_DMG * PetDamageMult(owner), false);

    ClearMineAt(slot, true);
}

void ClearMineAt(int slot, bool killEnt)
{
    if (g_hMineList == null || slot < 0 || slot >= g_hMineList.Length) return;
    int ent = EntRefToEntIndex(g_hMineList.Get(slot));
    if (ent != -1 && ent < 2048)
    {
        g_MineOwner[ent] = -1;
        // KillHierarchy se lleva encima el glow hijo
        if (killEnt && IsValidEntity(ent))
            AcceptEntityInput(ent, "KillHierarchy");
    }
    g_hMineList.Erase(slot);
    if (g_iActiveMines > 0) g_iActiveMines--;
}

void SweepAllMines()
{
    if (g_hMineList != null)
    {
        for (int i = 0; i < g_hMineList.Length; i++)
        {
            int ent = EntRefToEntIndex(g_hMineList.Get(i));
            if (ent != -1 && ent < 2048)
            {
                g_MineOwner[ent] = -1;
                if (IsValidEntity(ent))
                    AcceptEntityInput(ent, "KillHierarchy");
            }
        }
        delete g_hMineList;
    }
    g_hMineTimer = null;
    g_iActiveMines = 0;
}

// ===========================================================================
// v2.4: CINCO EFECTOS NUEVOS DE GRANADA (el lanzagranadas llega a 25)
// ===========================================================================

// ---- EFECTO 20: METEORITOS (lluvia real de meteoros) -------------------------
void Gfx_Meteor(int owner, const float pos[3], int sndEnt)
{
    for (int i = 0; i < 6; i++)
    {
        DataPack pack = new DataPack();
        pack.WriteFloat(pos[0] + GetRandomFloat(-260.0, 260.0));
        pack.WriteFloat(pos[1] + GetRandomFloat(-260.0, 260.0));
        pack.WriteFloat(pos[2]);
        pack.WriteCell(owner);
        CreateTimer(0.15 + 0.22 * float(i), Timer_MeteorDrop, pack, TIMER_FLAG_NO_MAPCHANGE);
    }
    EmitSoundToAll(SND_JETPASS, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.5, 110);
}

public Action Timer_MeteorDrop(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    float pos[3];
    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();
    int owner = pack.ReadCell();
    delete pack;
    if (owner <= 0) return Plugin_Stop;
    if (GetEntityCount() > MAX_EDICTS_SAFE) return Plugin_Stop;

    // techo real para no nacer dentro de un muro
    float probe[3];
    probe[0] = pos[0]; probe[1] = pos[1]; probe[2] = pos[2] + 40.0;
    float angUp[3] = {-90.0, 0.0, 0.0};
    float topZ = pos[2] + 700.0;
    Handle tr = TR_TraceRayEx(probe, angUp, MASK_SOLID_BRUSHONLY, RayType_Infinite);
    if (tr != null)
    {
        if (TR_DidHit(tr))
        {
            float trEnd[3];
            TR_GetEndPosition(trEnd, tr);
            if (trEnd[2] < topZ) topZ = trEnd[2] - 50.0;
        }
        CloseHandle(tr);
    }
    if (topZ < pos[2] + 120.0) topZ = pos[2] + 120.0;

    float spawn[3], vel[3], ang[3];
    spawn[0] = pos[0] + GetRandomFloat(-60.0, 60.0);
    spawn[1] = pos[1] + GetRandomFloat(-60.0, 60.0);
    spawn[2] = topZ;
    vel[0] = GetRandomFloat(-40.0, 40.0);
    vel[1] = GetRandomFloat(-40.0, 40.0);
    vel[2] = -900.0;
    ang[0] = 90.0; ang[1] = 0.0; ang[2] = 0.0;

    int msl = CreateMissileBody(owner, MSTYLE_METEOR, spawn, ang, vel, -1, 4.0);
    if (msl != -1)
    {
        int streak[4] = {255, 170, 80, 230};
        float tail[3];
        tail[0] = spawn[0]; tail[1] = spawn[1]; tail[2] = spawn[2] + 160.0;
        PetBeam(spawn, tail, streak, 3.0, 0.2);
    }
    return Plugin_Stop;
}

// ---- EFECTO 21: NOVA DE PLASMA -------------------------------------------------
void Gfx_PlasmaNova(int owner, const float pos[3], int sndEnt)
{
    int nova[4] = {170, 120, 255, 230};
    TE_SetupBeamRingPoint(pos, 20.0, 420.0, g_sBeam, g_sBeam, 0, 100, 0.9, 26.0, 0.0, nova, 210, 0);
    TE_SendToAll();
    TE_SetupBeamRingPoint(pos, 20.0, 300.0, g_sBeam, g_sBeam, 0, 100, 0.7, 20.0, 0.0, nova, 180, 0);
    TE_SendToAll();
    int nova2[4] = {230, 190, 255, 220};
    TE_SetupBeamRingPoint(pos, 20.0, 180.0, g_sBeam, g_sBeam, 0, 100, 0.5, 14.0, 0.0, nova2, 160, 0);
    TE_SendToAll();

    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(pos, 380.0, enemies);
    for (int i = 0; i < enemies.Length; i++)
    {
        int victim = enemies.Get(i);
        if (victim <= 0 || !IsValidEntity(victim)) continue;
        if (owner > 0) PetDamage(victim, owner, 38.0, DMG_BURN);
        IgniteEntity(victim, 3.0);
        AddSlow(victim, 3.0);
    }
    delete enemies;
    EmitSoundToAll(SND_MISSILE2, sndEnt, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER, _, 0.7, 140);
}

// ---- EFECTO 22: ENJAMBRE BUSCADOR ------------------------------------------------
void Gfx_SeekerSwarm(int owner, const float pos[3], int sndEnt)
{
    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(pos, 520.0, enemies);
    int launched = 0;
    for (int i = 0; i < enemies.Length && launched < 5; i++)
    {
        int en = enemies.Get(i);
        if (en <= 0 || !IsValidEntity(en) || !IsEnemyAlive(en)) continue;

        float spawn[3], vel[3], ang[3];
        spawn[0] = pos[0] + GetRandomFloat(-50.0, 50.0);
        spawn[1] = pos[1] + GetRandomFloat(-50.0, 50.0);
        spawn[2] = pos[2] + 30.0 + GetRandomFloat(0.0, 40.0);
        vel[0] = GetRandomFloat(-120.0, 120.0);
        vel[1] = GetRandomFloat(-120.0, 120.0);
        vel[2] = 260.0;
        ang[0] = -70.0; ang[1] = GetRandomFloat(-180.0, 180.0); ang[2] = 0.0;
        if (CreateMissileBody(owner, MSTYLE_SEEKER, spawn, ang, vel, EntIndexToEntRef(en), 3.5) != -1)
            launched++;
    }
    delete enemies;

    // sin enemigos cerca: se dispara al cielo y se apaga sola
    if (launched == 0)
    {
        float spawn[3], vel[3], ang[3];
        spawn[0] = pos[0]; spawn[1] = pos[1]; spawn[2] = pos[2] + 30.0;
        vel[0] = GetRandomFloat(-60.0, 60.0);
        vel[1] = GetRandomFloat(-60.0, 60.0);
        vel[2] = 300.0;
        ang[0] = -80.0; ang[1] = 0.0; ang[2] = 0.0;
        CreateMissileBody(owner, MSTYLE_SEEKER, spawn, ang, vel, -1, 2.0);
    }

    int ring[4] = {255, 120, 60, 220};
    TE_SetupBeamRingPoint(pos, 10.0, 120.0, g_sBeam, g_sBeam, 0, 60, 0.4, 10.0, 0.0, ring, 170, 0);
    TE_SendToAll();
    EmitSoundToAll(SND_MISSILE1, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.6, 160);
}

// ---- EFECTO 23: NUBE TOXICA (dano sostenido + lentitud) -------------------------
void Gfx_Toxic(int owner, const float pos[3], int sndEnt)
{
    CopyVector(pos, g_vAcidPos);
    g_iAcidOwner = owner;

    int tox[4] = {140, 255, 90, 210};
    TE_SetupBeamRingPoint(pos, 20.0, 340.0, g_sBeam, g_sBeam, 0, 110, 2.8, 34.0, 0.0, tox, 170, 0);
    TE_SendToAll();
    int tox2[4] = {90, 200, 60, 200};
    TE_SetupBeamRingPoint(pos, 20.0, 240.0, g_sBeam, g_sBeam, 0, 110, 2.2, 26.0, 0.0, tox2, 150, 0);
    TE_SendToAll();

    ArrayList list = new ArrayList();
    PetCommonsInRadius(pos, 300.0, list);
    for (int i = 0; i < list.Length; i++)
    {
        int ent = EntRefToEntIndex(list.Get(i));
        if (ent == -1 || !IsValidEntity(ent)) continue;
        AddSlow(ent, 5.0);
    }
    delete list;

    // el pulso de acido (compartido con la quimica) hace el dano por tick
    float now = GetGameTime();
    if (g_fAcidUntil < now) g_fAcidUntil = now;
    g_fAcidUntil += 6.0;
    if (g_hAcidTimer == null)
        g_hAcidTimer = CreateTimer(0.5, Timer_AcidPulse, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    EmitSoundToAll(SND_GLASS, sndEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.8, 70);
}

// ---- EFECTO 24: MINI-NUKE ----------------------------------------------------------
void Gfx_MiniNuke(int owner, const float pos[3], int sndEnt)
{
    TE_SetupExplosion(pos, g_sExplosion, 14.0, 1, 0, 400, 150);
    TE_SendToAll();
    int flash[4] = {255, 255, 255, 240};
    TE_SetupBeamRingPoint(pos, 20.0, 900.0, g_sBeam, g_sBeam, 0, 130, 1.1, 40.0, 0.0, flash, 240, 0);
    TE_SendToAll();
    int fire[4] = {255, 170, 60, 220};
    TE_SetupBeamRingPoint(pos, 30.0, 700.0, g_sBeam, g_sBeam, 0, 120, 0.9, 32.0, 0.0, fire, 200, 0);
    TE_SendToAll();

    EmitSoundToAll(SND_MISSILE1, sndEnt, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER, _, 1.0, 60);
    EmitSoundToAll(SND_MISSILE2, sndEnt, SNDCHAN_AUTO, SNDLEVEL_DISHWASHER, _, 1.0, 50);

    if (owner > 0)
    {
        PetExplosionDamage(owner, pos, 400.0, 130.0, false);
        DataPack pack = new DataPack();
        pack.WriteFloat(pos[0]);
        pack.WriteFloat(pos[1]);
        pack.WriteFloat(pos[2]);
        pack.WriteCell(owner);
        CreateTimer(0.45, Timer_NukeSecond, pack, TIMER_FLAG_NO_MAPCHANGE);
        if (IsClientInGame(owner))
            PrintToChat(owner, "%s \x04MINI-NUKE\x05: onda de choque desplegada.", CHAT_PREFIX);
    }
}

public Action Timer_NukeSecond(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    float pos[3];
    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();
    int owner = pack.ReadCell();
    delete pack;
    if (owner <= 0) return Plugin_Stop;

    int ring[4] = {255, 220, 130, 220};
    TE_SetupBeamRingPoint(pos, 60.0, 520.0, g_sBeam, g_sBeam, 0, 100, 0.6, 24.0, 0.0, ring, 200, 0);
    TE_SendToAll();
    PetExplosionDamage(owner, pos, 300.0, 60.0, false);
    return Plugin_Stop;
}

// lentitud compartida (criogenico, nova, toxica): reutiliza el pulso de humo
void AddSlow(int ent, float dur)
{
    if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent)) return;
    if (g_hSlowList == null) g_hSlowList = new ArrayList();
    int ref = EntIndexToEntRef(ent);
    if (g_hSlowList.FindValue(ref) == -1)
        g_hSlowList.Push(ref);
    float until = GetGameTime() + dur;
    if (g_fSlowUntil < until) g_fSlowUntil = until;
    if (g_hSlowTimer == null)
        g_hSlowTimer = CreateTimer(0.15, Timer_SlowPulse, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

// enemigos NPC (comunes + witch) en radio: guarda REFS (para efectos de control)
int PetCommonsInRadius(const float pos[3], float radius, ArrayList list)
{
    float vPos[3];
    int count = 0;
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        if (GetVectorDistance(pos, vPos) <= radius)
        {
            list.Push(EntIndexToEntRef(ent));
            count++;
        }
    }
    ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        if (GetVectorDistance(pos, vPos) <= radius)
        {
            list.Push(EntIndexToEntRef(ent));
            count++;
        }
    }
    return count;
}

// ---------------------------------------------------------------------------
// LASER GUIADO (hitscan instantaneo)
// ---------------------------------------------------------------------------
void PetLaserShot(int client, int targetIdx)
{
    int body = EntRefToEntIndex(g_PetBody[client]);
    if (body == -1 || !IsValidEntity(body)) return;

    float muzzle[3], tPos[3];
    GetPetMuzzle(body, muzzle);
    GetEntPropVector(targetIdx, Prop_Send, "m_vecOrigin", tPos);
    tPos[2] += 40.0;

    int core[4] = {255, 255, 255, 255};
    int beam[4] = {255, 60, 60, 255};
    PetBeam(muzzle, tPos, beam, 3.0, 0.18);
    PetBeam(muzzle, tPos, core, 1.0, 0.15);

    PetDamage(targetIdx, client, 120.0, DMG_BULLET);

    // dano colateral alrededor del impacto
    ArrayList enemies = new ArrayList();
    PetEnemiesInRadius(tPos, 60.0, enemies);
    for (int i = 0; i < enemies.Length; i++)
    {
        int victim = enemies.Get(i);
        if (victim != targetIdx)
            PetDamage(victim, client, 50.0, DMG_BULLET);
    }
    delete enemies;

    PetBloodAt(tPos);
    EmitSoundToAll(SND_GATLING, GetPetSoundEnt(client, body), SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.5, 210);
}

// ---------------------------------------------------------------------------
// Utilidades
// ---------------------------------------------------------------------------
bool IsValidClient(int client)
{
    if (client < 1 || client > MaxClients) return false;
    if (!IsClientConnected(client)) return false;
    if (!IsClientInGame(client)) return false;
    return true;
}

bool IsPetEnemy(int entity)
{
    if (entity <= 0 || !IsValidEntity(entity)) return false;
    if (entity <= MaxClients)
        return (IsClientInGame(entity) && GetClientTeam(entity) == 3);
    char cls[32];
    GetEntityClassname(entity, cls, sizeof(cls));
    return (StrContains(cls, "infected") != -1 || StrEqual(cls, "witch"));
}

bool IsEnemyAlive(int entity)
{
    if (entity <= 0 || !IsValidEntity(entity)) return false;
    if (entity <= MaxClients)
        return (IsClientInGame(entity) && IsPlayerAlive(entity) && GetClientTeam(entity) == 3);
    int hp = GetEntProp(entity, Prop_Data, "m_iHealth");
    return (hp > 0);
}

public void OnPluginEnd()
{
    // v2.7: parar el autoguardado y respaldar el progreso de todos antes
    // de descargar: un sm plugins reload ya no pierde nada
    if (g_hPetAutosave != null)
    {
        delete g_hPetAutosave;
    }
    // v2.9: parar tambien el cronometro de XP de supervivencia
    if (g_hPetSurvXP != null)
    {
        delete g_hPetSurvXP;
    }
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_PetLevelLoaded[i])
            PetSaveProgress(i);
    }
    // matar todo rastro para no dejar molotov sueltos que el juego detone
    SweepAllMines();
    // v2.5: liberar las lenguas activas (agarres del engine) antes de cerrar
    for (int i = 1; i <= MaxClients; i++)
        CleanupTongue(i);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_PetBody[i] != -1)
        {
            int body = EntRefToEntIndex(g_PetBody[i]);
            if (body != -1 && IsValidEntity(body)) AcceptEntityInput(body, "kill");
            int model = (g_PetModel[i] != -1) ? EntRefToEntIndex(g_PetModel[i]) : -1;
            if (model != -1 && IsValidEntity(model)) AcceptEntityInput(model, "kill");
            int exaust = (g_PetExhaust[i] != -1) ? EntRefToEntIndex(g_PetExhaust[i]) : -1;
            if (exaust != -1 && IsValidEntity(exaust)) AcceptEntityInput(exaust, "kill");
            g_PetBody[i] = -1;
            g_PetModel[i] = -1;
            g_PetExhaust[i] = -1;
        }
    }
    // granadas vivas + listas de efectos de control
    for (int ent = 0; ent < 2048; ent++)
    {
        if (g_GrenadeOwner[ent] != -1)
        {
            char gcls[32];
            if (ent > 0 && IsValidEntity(ent) && GetEntityClassname(ent, gcls, sizeof(gcls))
                && StrEqual(gcls, "molotov_projectile"))
                AcceptEntityInput(ent, "kill");
            g_GrenadeOwner[ent] = -1;
        }
    }
    g_iActiveGrenades = 0;
    delete g_hFreezeList;
    delete g_hFloatList;
    delete g_hPullList;
    delete g_hSlowList;
    delete g_hMarkList;

    for (int ent = 0; ent < 2048; ent++)
    {
        if (g_MissileStyle[ent] != -1)
        {
            if (IsValidEntity(ent)) AcceptEntityInput(ent, "kill");
            int model = (g_MissileModelRef[ent] != -1) ? EntRefToEntIndex(g_MissileModelRef[ent]) : -1;
            if (model != -1 && IsValidEntity(model)) AcceptEntityInput(model, "kill");
            int exaust = (g_MissileExhaustRef[ent] != -1) ? EntRefToEntIndex(g_MissileExhaustRef[ent]) : -1;
            if (exaust != -1 && IsValidEntity(exaust)) AcceptEntityInput(exaust, "kill");
            g_MissileStyle[ent] = -1;
        }
    }
}
