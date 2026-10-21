/*
 * ======================================================
 *  [MODULO] Blaze the Cat - Avatar Espejo v2.11-OM
 *  (10o AVATAR DEL SUITE + SU KIT GMOD COMPLETO)

 *
 *  v2.11-OM (2026-10-17, manager 3.77.86): LA TABLA DE DAÑO
 *  AUMENTADA (pedido del owner: la patada con escalado de daño de
 *  200 a 550 — los comunes siguen muriendo de un ataque o patada o
 *  lanza; la witch recibe el doble de daño y su stun correspondiente;
 *  la lanza tambien la empuja aplicando su congelacion, ella x2; el
 *  sol dash aereo con area mas grande, entre 800 a 1650 de daño y
 *  dejando debilidad por 6 seg — todas las otras habilidades le
 *  pegan 1.5x):
 *   - KICK: daño ESCALADO 200 -> 550 con el meter Sol (0 = 200,
 *     100 = 550; convars blaze_kick_dmg_min/max). Los comunes siguen
 *     muriendo de UN golpe (200 base ya reventa al comun de 50HP).
 *   - SOL DASH AEREO: daño ESCALADO 800 -> 1650 con el meter Sol
 *     (blaze_dash_dmg_min/max) + AREA MAS GRANDE: la esfera del
 *     barrido sube de 100 a blaze_dash_hitradius (150) y la explosion
 *     de area del impacto escala por blaze_dash_aoescale (x1.5).
 *   - LA WITCH: x2 de daño de TODO el kit (blaze_witch_dmgmult 2.0)
 *     + el STUN correspondiente (kick/dash 4s, lanza 1s): FL_FROZEN =
 *     ESTATUA (la receta del suite para apagar su IA NextBot sin
 *     romperla — ver Witch_Flight/OM_Stun; se retira sola al expirar
 *     y JAMAS se roba el hielo de un vuelo activo del Witch_Flight).
 *   - LA LANZA: tambien EMPUJA a la witch (el arrastre del picon a
 *     3000 u/s) aplicando su CONGELACION (el mismo 1s que entra un
 *     player) + x2 de daño.
 *   - DEBILIDAD: la victima del DASH AEREO queda DEBIL 6s
 *     (blaze_weak_duration): TODAS las otras habilidades de Blaze le
 *     pegan x1.5 (blaze_weak_dmgmult). El dash NO se amplifica a si
 *     mismo — el es el ORIGEN de la debilidad.
 *   - Los convars del Lua blaze_kick/soldash_basedamage quedan
 *     DEPRECATED (registrados para no ensuciar el cfg, ya sin efecto).
 *
 *  v2.6-OM (2026-10-15, manager 3.77.80): LA BARRA DE LLAMA SOL — el
 *  HUD tipo Gmod que pidio el owner ("es posible crear una UI HUD a
 *  base de smx como hacia Gmod para ponerle a blaze su barra de calor?
 *  ya que actualmente no hay nada que le indique cuanto calor tiene").
 *  El Gmod la dibuja con Lua de CLIENTE (HUDPaint + surface); el smx
 *  vive en el SERVER y L4D2 no tiene cliente scriptable: el canal que
 *  SI existe es la entidad game_text del engine (Display SOLO al
 *  activador — cada Blaze ve SU barra). Think 4 Hz + celdas █/░ +
 *  color por nivel + tags de estado (DRAIN/FLAME/MODO SOL/VACIA) +
 *  convars sbar_* movibles en vivo (v2.7: el dibujado vive en el motor comun SBar). El numero del panel
 *  KeyHintText queda igual: la barra es su complemento visual.
 *
 *  v2.2-OM (con manager 3.77.73, pedido del owner 2026-10-15 —
 *  "el javelin no se ve y el flame tampoco se ve" + especificacion
 *  literal de efectos: "con la 1 habilidad kick Cuando impacte a un
 *  enemigo en el lugar del impacto causara el efecto
 *  molotov_explosion... el efecto de cuando prepara la patada es
 *  molotov_explosion_burst3 Ojo solo se aplicara al inicio de la
 *  habilidad... el grafico que remplazara a la que usa La Sol flame
 *  sera inferno_wall_occlusion... con sol dash usara
 *  inferno_wall_primary en el cuerpo de blaze durante el efecto y
 *  cuando impacte contra el enemigo usara al azar una de estas:
 *  molotov_explosion_burst, _burst2, _burst3, _cheap... no olvides
 *  remover el efecto de inferno a blaze cuando termine la habilidad"):
 *   - LOS EFECTOS REALES DEL MOTOR (particles/inferno.pcf stock):
 *     KICK: molotov_explosion_burst3 SOLO al iniciar la carga +
 *     molotov_explosion en el LUGAR del impacto. DASH (v2.4): el
 *     fuego que RODEA a Blaze = env_fire_medium (TORSO) +
 *     env_fire_small (PIES) PARENTADAS al cuerpo durante el vuelo
 *     (la inferno_wall_primary del pedido original es un muro de DOS
 *     puntos: dibuja ENTRE su origen y el cpoint1 — sola, parentada
 *     al cuerpo, no dibuja NADA, por eso el fuego era invisible;
 *     removidas SIEMPRE al terminar: impacto / fin de ventana /
 *     drain agotado / cancel / muerte / mapa) + al impactar una de
 *     las 4 molotov_burst AL AZAR sobre el enemigo. SOL FLAME:
 *     inferno_wall_occlusion por segmento a lo largo del cono (el
 *     grafico nuevo que reemplaza al anterior) con PITCH por convar
 *     blaze_fx_flame_pitch (default -90 = acostado al frente tipo
 *     lanzallamas; VERIFICAR con el fxtest.smx del kit — si las
 *     llamas siguen subiendo, poner 0). JAVELIN: molotov_trail
 *     (la estela del coctel del propio motor) PARENTADA al arpon.
 *   - EL JAVELIN YA NO ES INVISIBLE: el harpoon002a del Lua vive en
 *     el VPK del SERVER (FileExists lo ve) pero NO llega a los
 *     clientes (los archivos dentro de VPKs no se descargan) = un
 *     prop sin modelo client-side = INVISIBLE. La estela de fuego
 *     parentada lo hace visible SIEMPRE (las particulas renderizan
 *     aunque el modelo no exista en el cliente) + convar
 *     blaze_jav_model para forzar un modelo stock manualmente.
 *   - EL SOL FLAME YA NO ES INVISIBLE: tenia CERO grafico (solo
 *     sonidos + empuje + fuego por entidad). Ahora el cono se VIVE:
 *     muro de fuego inferno_wall_occlusion refrescado por segmento.
 *   - AOE A COMMONS ("todas las habilidades tendra dano aoe a commons
 *     incluso si impacta contra un SI la explosion tendra un efecto
 *     en area"): kick/dash/javelin explotan en el punto de impacto
 *     con dano en radio a comunes/witch (blaze_aoe_radius 250 /
 *     blaze_aoe_damage 80, amplificado por suite_dmg_scale como todo
 *     el suite) y el Sol Flame hace pasada de dano por swoosh
 *     (blaze_solflame_conedmg 20). ANTI-LAG ("el efecto de explosion
 *     solo sera Para el SI y no para los commons. si no habria lag
 *     de muerte"): cero particulas por common — la explosion visual
 *     existe UNA vez, en la victima golpeada; los commons del radio
 *     solo recibien el empujon + el dano.
 *   - El javelin ahora hace DAO al engancharse (blaze_javelin_damage
 *     45) + explosion visual + AoE (antes solo arrastraba).
 *
 *  v2.0-OM (con manager 3.77.71, orden del owner: "es hora de que
 *  les coloques las habilidades del Gmod que tiene pasivas y eso" —
 *  reenvio los 118 Lua del addon OM) — EL KIT COMPLETO del
 *  register_noodles_blaze.lua + survivors2.lua L46-1569, portado 1:1
 *  con las cifras del Lua (convars iguales que alla):
 *   - PASIVA «IFRAMES DE HABILIDAD»: mientras CUALQUIER estado de
 *     habilidad este activo (carga del kick/dash, ventana del vuelo,
 *     DrainDash, ExpellSolFlame) el dano entrante es 0 (el Lua:
 *     OM_Damage_Reduction 0 + iframes2 +0.75s). Hook propio
 *     OnTakeDamage: 0 hasta 0.75s despues del ultimo tick activo.
 *   - PASIVA «METER SOLFLAME» (0-100, arranca 0): se llena pegando
 *     (kick/dash +35, javelin +15; si ya vas >=50: +15) y se gasta
 *     (miss del kick -15 con sol>=50, DrainDash 5/s, ExpellSolFlame
 *     2.5/s). >=50 = MODO SOL: kick/javelin potenciados + QUEMA
 *     (IgniteEntity real: fuego del motor sobre el infectado).
 *   - Z EN TIERRA = ROUNDHOUSE KICK (Lua E suelo): carga 0.35s
 *     (0.6s en modo Sol) con beeps de tono ascendente, lanzamiento
 *     hacia adelante, ventana de golpeo 0.9s (esfera 100u a +50z):
 *     OM_Stun 4s + dano 25 + empujon al objetivo (600 / 1000 en Sol)
 *     + rebote propio atras-arriba; acierto = cd 17, fallo (toco
 *     suelo sin pegar) = anim Roll 0.5s + impulso 650 + cd 25.
 *   - Z EN EL AIRE = SOL DASH (Lua E aire): carga 0.6-0.7s CONGELADA
 *     en el sitio, disparo a 1400 u/s hacia la MIRA; sin Sol: ventana
 *     0.85s de golpes; con Sol>=50: DRAIN DASH sostenido que vuela
 *     donde mires mientras queme Sol (5/s) — pega al primer contacto.
 *   - X (sol<50) = BURNING JAVELIN (Lua R): arpon a 3000 u/s (harpoon
 *     del Lua, cadena FileExists -> katana -> gascan nativas) con
 *     trail; al DAR: +15 sol, lo PERFORA Y ARRASTRA 0.5s clavado al
 *     javelin (como el Lua: el Think lo arrastra) y lo suelta; el
 *     javelin se clava, se apaga y se va. cd 25.
 *   - X (sol>=50) = SOL FLAME (Lua R solflame): tras 0.45s de carga,
 *     CONO CONTINUO de 650u / 50 grados frente a la mira: quema
 *     (1.35s de fuego real), empuja radial (275 + levantada) y
 *     drena 2.5/s hasta vaciar el meter; al agotarse: cd 25.
 *     Anim propias IdleSolFlame/WalkSolFlame/RunSolFlame.
 *   - SONIDOS: exactamente los del Lua (om/blaze — blazebeep,
 *     blazekick, firestorm, burning javelin, blaze javelin hit,
 *     snd_impact, swoosh, roundhouse kick + om/knuckles/swing) —
 *     PROBE por FileExists al arrancar el mapa (sin el pack: la
 *     habilidad funciona igual, en silencio; una linea en el log).
 *   - GRAFICOS: tinte ROJO del avatar en las cargas (el glow del
 *     Lua), TE beams nativos del suite para las estelas (motor de
 *     slots de sonic.inc), IgniteEntity = el fuego REAL del motor.
 *     NADA inventado: los numeros son los del Lua.
 *
 *  v1.1-OM (con manager 3.77.70, orden del owner: "hace falta
 *  anadir a blaze y a silver en la lista de personajes
 *  seleccionables") — Blaze pasa de personaje CST de SOLO MODELO a
 *  PERSONAJE SELECCIONABLE del manager (BLAZE_INDEX 11, linea 12
 *  del menu sc). La seleccion dispara la señal CST y el guard
 *  embebido aplica blaze.cfg EN EL ACTO: el modelo CST entra solo y
 *  el avatar se monta por la deteccion de modelo de abajo. CERO
 *  cambios de logica en ESTE modulo — solo esta documentacion (la
 *  deteccion por modelo y el yield quedan exactamente igual: siguen
 *  cubriendo sm_blaze manual, mapa de slots CST y el caso
 *  personaje-con-avatar-propio + skin blaze encima).
 *
 *  v1.0-OM (con manager 3.77.69, orden del owner: "hay que anadir
 *  ahora el avatar de blaze silver y el dr eggman") — Blaze es un
 *  personaje CST DE MODELO (se aplica con sm_blaze o por el mapa de
 *  slots del CST), asi que su avatar vive en su propio modulo y se
 *  activa POR MODELO:
 *   - DETECCION: el survivor lleva un modelo "survivor_blaze*"
 *     (survivor_blaze.mdl / survivor_blaze_light.mdl del VPK CST)
 *     => el avatar espejo se monta solo, sin importar quien lo puso
 *     (sm_blaze manual, mapa de slots del CST o perfil aplicado por
 *     senal). Si el modelo se va (cambio de personaje con perfil
 *     propio), la FSM lo desmonta sola.
 *   - YIELD: si el jugador tiene seleccionado un personaje del
 *     manager CON AVATAR PROPIO (Sonic/Tails/Knuckles/Amy/Shadow/
 *     Rouge/Cream/Metal/Eggman), ese avatar manda — el personaje
 *     seleccionado ES la identidad (con sus habilidades); el modelo
 *     CST puesto encima es solo skin. Sally y Sage NO tienen avatar
 *     propio: con ellos (o "Sin personaje") el avatar de Blaze si
 *     se monta.
 *   - MODELO: models/Noodles/OM/blaze.mdl del VPK de recursos (el
 *     mismo pack OM de los otros 8 avatares — sonic/tails/knuckles/
 *     amy/rouge/shadow/metal/cream). Deteccion FileExists estilo
 *     star_stun: si el archivo no esta montado, TODO cae al
 *     survivor normal, CERO dependencia (y una linea en el log del
 *     server lo dice al arrancar el mapa).
 *   - Patron Cream v7.0-OM / Shadow v6.0 textual: copia R (la ven
 *     los demas) + copia L (la duena) + cuerpo oculto + FSM 10 Hz +
 *     ragdoll de muerte 15s + anti-corpse 2s + adopcion de huerfanos
 *     + pulso de pausa.
 *   - FSM POR PROBE (receta Amy v92): el .mdl no trae tabla
 *     documentada — cada estado tiene una CADENA de candidatos y
 *     gana el primer nombre que exista en el modelo; si falta, su
 *     estado base lo cubre (nunca T-pose). Estados: idle/walk/run/
 *     jump/fall + variantes lowhealth (HP<=40) + downed.
 *   - CERO gameplay: sin habilidades, sin hooks de dano, sin
 *     comandos — SOLO el avatar (el personaje es modelo CST puro).
 *     Convar unico: blaze_avatar 1.
 * ======================================================
 */

#if defined _Blaze_included
    #endinput
#endif
#define _Blaze_included

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
// Dependencias (defines del manager, disponibles antes de los includes)
// =======================
#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// =======================
// v1.0-OM: AVATAR ESPEJO BLAZE.MDL (10o avatar del suite)
// =======================
#define BLAZE_INC_VERSION    "v2.13-OM"   // v2.13: EL SOL DE LA EXPANSIVA (pedido del owner 2026-10-17): la carga de sol del ataque principal solo llegaba al comun del GOLPE DIRECTO ("solo le da la energia al common que recibe la patada pero no a los commons que mate la expansiva") — AHORA los comunes que el AOE del impacto (kick/dash aereo/enganche de la lanza) MATA tambien cargan su blaze_sol_charge_common (+2 cada uno, mismo convar del directo); CERO doble carga: el comun del directo entra al AOE como skipEnt (su sol ya lo conto el HitImpact/enganche) y la witch/tank NO cargan por la expansiva (su sol sigue siendo solo del directo); el premio vive en el bucle final de Blaze_FX_AoeCommons tras el daño, re-validado con Blaze_VictimAlive (regla v2.10) | v2.12: LA LANZA REWORK + EL NERF DEL SOL + EL CONO QUE ACUMULA + SEGURIDAD WITCH (pedido del owner 2026-10-17, ronda 2): (1) BURNING JAVELIN 45 -> 255-354 CON RUTA: el daño crece +75% al llegar a su distancia maxima (fraccion del vuelo de 6s; nacer = base pura, tope = x1.75) y al TOPE DE VUELO EXPLOTA (1100 al centro, -25% al tank) [blaze_javelin_dmg_min/max + blaze_javelin_ramp + blaze_javelin_expl_dmg/_tankmult/_radius]; (2) NERF DEL PODER DEL SOL: "ya golpear comunes no recargara 35" — el ataque principal ahora carga POR TIPO DE VICTIMA y SOLO con el golpe DIRECTO (el AOE del impacto NO carga: una patada a la horda no llena el meter de un soplo): comun MUERTO +2, especial +22, tank +30, witch +25 [blaze_sol_charge_common/_special/_tank/_witch]; los convars solflamemeter del Lua quedan DEPRECATED; (3) SOL FLAME ACUMULA DEBILIDAD: +1% por cada 0.5s que la victima lleva el daño de fuego del cono [la MISMA cadencia 0.5s de la quema], tope +150% [blaze_flameweak_max 1.5], decae -1%/0.5s sin fuego, y multiplica en Blaze_AbilityDamage APILADA con la x1.5 de la debilidad del dash; (4) SEGURIDAD v2.10-witch: la witch JAMAS recibe IgniteEntity de Blaze (kick/dash en Sol + cono), la quema del cono pasa a CADENCIA 0.5s por cuerpo [ignT 1.35s = ardiendo perpetuo, look identico] y kill-switch blaze_burn_enable [0 = CERO IgniteEntity desde Blaze, palanca de diagnostico]. TODO lo demas INTACTO (la tabla v2.11: kick 200-550 / dash aereo 800-1650 / witch x2 + estatua FL_FROZEN / debilidad 6s x1.5) | v2.11: LA TABLA DE DAÑO AUMENTADA (pedido del owner 2026-10-17: la patada con escalado de daño 200 a 550 — los comunes siguen muriendo de un ataque/patada/lanza; la witch el doble de daño + su stun correspondiente; la lanza tambien la empuja aplicando su congelacion, ella x2; el sol dash aereo con area mas grande, entre 800 a 1650 de daño, dejando debilidad por 6 seg y todas las otras habilidades causando 1.5x de daño aumentado): (1) KICK ESCALADO 200->550 por el meter Sol [blaze_kick_dmg_min/_max; sol 0 = 200, sol 100 = 550; los comunes siguen muriendo de UN golpe: 200 base ya reventa al comun de 50HP]; (2) SOL DASH AEREO ESCALADO 800->1650 [blaze_dash_dmg_min/_max] + AREA MAS GRANDE [esfera del barrido 100 -> blaze_dash_hitradius 150 + explosion de area del impacto x blaze_dash_aoescale 1.5]; (3) LA WITCH x2 de daño de TODO el kit [blaze_witch_dmgmult 2.0] + el STUN correspondiente [kick/dash = su basestun 4s; lanza = 1s]: FL_FROZEN = la ESTATUA del suite (apaga el gate DoThink de su IA NextBot sin romper su calendario — misma receta de Witch_Flight/OM_Stun), re-afirmado por tick y retirado al expirar, JAMAS robando el hielo de un vuelo activo del Witch_Flight [Blaze_WitchStun + slots BlazeDb]; (4) LA LANZA tambien EMPUJA a la witch [el arrastre del picon a 3000 u/s ya la lleva] aplicando su CONGELACION [el mismo OM stun 1s del player, en su version witch FL_FROZEN] + x2; (5) DEBILIDAD del dash aereo: la victima queda DEBIL blaze_weak_duration 6s y TODAS las otras habilidades le pegan x blaze_weak_dmgmult 1.5 [Blaze_AbilityDamage: x2 witch * x1.5 debilidad; el dash origen NO se auto-amplifica]; convars del Lua blaze_kick/soldash_basedamage DEPRECATED (registrados, sin efecto) | v2.10: CRASHPROOF — EL FIX DEL CRASH SILENCIOSO DE LA HORDA (reporte del owner: "el crash ocurre solamente en No Mercy al bajar apenas por los apartamentos, el juego se cierra sin mensajes de error ni nada"; autopsia del camino completo habilidad-vs-comunes que la v2.8 habia desbloqueado al arreglar el viejo "Invalid client index"): (1) MACRO ROTO OM_StunValid — "1 <= 464 <= MaxClients" NO filtra NADA en SourcePawn (asociatividad: (1<=464)=1 -> 1<=32=TRUE): el javelin llamaba OM_Stun(victima-comun) y reventaba en IsClientInGame "Invalid client index 464" CADA TICK del arrastre, abortando el think entero y re-escaneando al mismo comun 30 veces por segundo [fix v2.4 del OM_Stun.inc + gate explicito victim <= MaxClients en el enganche]; (2) ENTIDADES MUERTAS TRAS EL DAÑO — el HitImpact dañaba PRIMERO (OM_AbilityDamage amplificado x2 mata al comun de 50HP EN el frame, y su edict se libera AL INSTANTE en L4D2) y seguia operando el cadaver: TeleportEntity + IgniteEntity + GetEntPropVector "Invalid entity" en cadena tras cada patada a la horda [AHORA: la POSICION se captura ANTES del daño, push/stun/ignite solo con Blaze_VictimAlive, y el DAÑO VA AL FINAL]; (3) DAÑO DENTRO DEL FIND-ENTITY LOOP — el AOE (Blaze_FX_AoeCommons) y el swoosh del Sol Flame dañaban DENTRO del while(FindEntityByClassname): un comun muerto libera su edict en el mismo frame y la siguiente iteracion arrancaba desde un indice ya liberado = acceso a memoria liberada = EL CRASH SILENCIOSO DEL MOTOR sin escribir nada [AHORA: SNAPSHOT de todos los indices vivos en radio PRIMERO, daño DESPUES re-validando cada uno con Blaze_VictimAlive]; (4) el ARRASTRE del javelin solo acepta victimas VIVAS (muere de camino = la lanza sigue sola, jamas TeleportEntity sobre un edict reciclado) y si el daño de enganche mata, NO se arrastra nada | v2.9: LA BARRA AL CHAT CON colors.inc — la captura del owner mostro los <font> del hint impresos como TEXTO LITERAL (L4D2 NO parsea rich text en el HintText; reporte: "aparesen font y no creo que quede bn... la barra deberia aparecer mas abajo" + anotacion en pantalla señalando la esquina inferior izquierda = el chat): la Llama Sol vive ahora en el CHAT con la paleta L4D2 del colors.inc [lleno {green}=AMARILLO fuego / medio {lightgreen} / bajo {olive} / VACIA {red} parpadeando por impresion] via el nuevo g_iSBarChatColor del BarState + throttle sbar_chat_interval/_refresh + sbar_channel 1 = hint plano de fallback | v2.8: LA BARRA SE VE DE VERDAD + LA LANZA CON ALCANCE/CURSO/STUN — (1) BARRA: el motor comun SBar v2.0 migra de game_text a HINTTEXT (bug documentado del VDC: en la serie L4D el HudMessage de game_text se redirige a la 2a vista del splitscreen Y la fuente no esta definida en clientscheme.res = INVISIBLE en clientes vanilla — por eso "no se ve la barra" NI EN LA v3.77.80 NI EN LA .81; el HintText con rich text <font color size> es el canal del HUD de Furia de Amy, probado en este server: color por nivel + tamano sbar_size 24 + celdas ASCII #/-); (2) FIX DEL CRASH "Invalid client index 467": el OR de Blaze_HitImpact evaluaba IsPlayerAlive(victima-comun) ANTES del chequeo de rango -> 3 errores por patada a la horda (el think abortaba y el estado kick quedaba vivo); ahora el rango va PRIMERO; (3) LA LANZA: alcance honesto [el trace de pared era un rayo INFINITO que IGNORABA el mundo por el filtro -> o se clavaba al nacer ante cualquier func_ delante a cualquier distancia, o cruzaba las paredes del mapa: ahora se traza SOLO el segmento recorrido del tick y el filtro acepta el mundo] + radio de caza blaze_javelin_radius 120 [80 fijo antes] + blaze_javelin_pitch 90 [la lanza apunta AL FRENTE en el vuelo — el picon nace vertical] + los OBJETIVOS EMPUJADOS entran en OM stun 1s con stagger al liberar [OM_STUN_F_STAGGER; commons no son players: dano+arrastre igual] | v2.7: LA BARRA MIGRA AL MOTOR COMUN SBar del manager 3.77.81 (Blaze_BarState abajo; 2 lineas de 30 celdas; convars sbar_*, las blaze_bar_* retiradas) | v2.6: LA BARRA DE LLAMA SOL — HUD por game_text (pregunta del owner 2026-10-15: "es posible crear una UI HUD a base de smx como hacia Gmod para ponerle a blaze su barra de calor? ya que actualmente no hay nada que le indique cuanto calor tiene"; el Gmod la dibuja con Lua de CLIENTE [HUDPaint+surface] y L4D2 no tiene cliente scriptable — el canal SMX que SI existe es la entidad game_text; como y por que, en la seccion v2.6 del include y el changelog v3.77.80 del manager) | // v2.5: EL JAVELIN VUELA DE VERDAD + LA HITBOX ES EL RECORRIDO + EL REMBOLSO DEL KICK — (1) JAVELIN ("no lanza nada"): TRES causas juntas: el harpoon002a.mdl del Lua es contenido de HL2 que L4D2 NO trae (prop sin modelo en el cliente = invisible, y si no esta ni en el VPK el motor mata el prop al spawnear), la estela molotov_trail de la v2.2 NO existe en la lista de particulas de L4D2 (nombre invalido = render silencioso — misma clase de bug que las llamas inferno_wall_*), y el think leia m_vecVelocity del datamap del prop_physics_override que NO siempre refleja el vphysics (si leia 0 lo daba por muerto al instante); ADEMAS el javelin no tenia tope de vuelo: salia volando del mapa por el cielo y como nunca moria, el "uno vivo por jugador" BLOQUEABA la habilidad PARA SIEMPRE. AHORA: modelo = w_pitchfork.mdl del PROPIO L4D2 (The Sacrifice — TODO cliente lo tiene; decision del owner "usaremos es Pitchfork"), vuelo por DIRECCION guardada al disparar (cero lecturas de velocidad), estela = env_fire_small parentada (familia confirmada Sol Flame v2.3 / dash v2.4; convar blaze_fx_jav_name) y tope de vuelo 6s; (2) HITBOX = EL RECORRIDO ENTERO (pedido del owner "se activa muy tarde nada mas se activa al finalizar, deberia estar activo hasta que ella termine dicho movimiento"): la esfera 100 se media contra los PIES de las victimas mientras Blaze volaba con arco a +40 del suelo — a mitad del vuelo la distancia 3D pasaba de 100 y solo pegaba al caer AL FINAL; ahora se BARRE el segmento recorrido en cada tick (mata los huecos: a 1022u/s son 102u por tick de 10Hz, el javelin 100u por tick de 30Hz) y se compara contra el CENTRO del cuerpo (+40z) — kick, dash, drain dash y javelin; (3) REMBOLSO (pedido del owner "la patada regresara un 65% de enfriamiento"): al ACERTAR el kick se le DEVUELVE el 65% del cd de aterrizaje (blaze_kick_cdrefund 0.65: 17 -> 5.95s antes de blaze_cd_scale; el miss conserva su cd completo) | v2.4: EL FUEGO DEL SOL DASH VISIBLE — la inferno_wall_primary es un sistema de MURO de dos puntos (dibuja el tramo ENTRE su origen y el cpoint1): parentada SOLA al cuerpo no dibujaba NADA, por eso Blaze volaba sin fuego con la habilidad funcionando. Ahora el fuego que la RODEA = env_fire_medium (TORSO +40u) + env_fire_small (PIES +8u) parentadas en LOOP — fuegos ambientales de los mapas, solo CP0, SIEMPRE visibles (misma receta a prueba de balas del cono v2.3) — convars blaze_fx_dash_name / blaze_fx_dash_name2 — fix del reporte del owner 2026-10-15 "el sol dash le falta el fuego que deberia rodearla... tambien es invisible" | v2.3: EL CONO VISIBLE — la inferno_wall_occlusion del pedido existe en L4D2 pero es la CAPA DE OCLUSION (mascara tecnica) del muro del molotov: NO dibuja llamas por si sola, por eso el grafico era invisible con la habilidad funcionando. El cono ahora = env_fire_large (boca) + env_fire_medium (tramos 170/340/510/650u), las particulas de los fuegos ambientales de los mapas (solo CP0, SIEMPRE visibles), cada tramo con cpoint1 al punto siguiente (receta lengua pet_christmas v2.6: cualquier inferno_wall_* dibuja el tramo ENTRE los dos puntos) — convars blaze_fx_flame_name / blaze_fx_flame_mouth — fix del reporte del owner 2026-10-15 "la sol flame no aparece el grafico, sigue siendo invisible" | v2.2: efectos molotov/inferno del motor (kick burst3+explosion, dash inferno_wall_primary, burst al azar al impactar) + AOE a commons (visual SOLO en la victima, anti-lag) + javelin SIEMPRE visible (molotov_trail) y con dano
#define BLAZE_OM_MODEL       "models/Noodles/OM/blaze.mdl"
#define BLAZE_AVATAR_NAME    "blaze_avatar_om"
#define BLAZE_AVATAR_NAME_L  "blaze_avatar_om_l"

// FSM de animacion — los nombres se RESUELVEN contra el .mdl real por
// PROBE (receta Amy v92 / Shadow v6.0 / Cream v7.0): cada estado tiene
// una CADENA de candidatos y gana el primero que exista en el modelo;
// los que falten caen a su estado base (nunca T-pose)
#define BLAZE_ST_IDLE         0
#define BLAZE_ST_WALK         1
#define BLAZE_ST_RUN          2
#define BLAZE_ST_JUMP         3    // one-shot con ventana (receta Rouge)
#define BLAZE_ST_FALL         4
#define BLAZE_ST_IDLE_LOW     5    // lowhealth (HP <= 40)
#define BLAZE_ST_WALK_LOW     6
#define BLAZE_ST_RUN_LOW      7
#define BLAZE_ST_DOWNED_IDLE  8    // incap
#define BLAZE_ST_DOWNED_WALK  9
// v2.0-OM: estados de GAMEPLAY (nombres EXACTOS del Lua de Blaze)
#define BLAZE_ST_KICK         10   // pose mantenida del vuelo del kick
#define BLAZE_ST_SOLDASH      11   // dash aereo (fallback RUN)
#define BLAZE_ST_ROLL         12   // miss del kick (0.5s)
#define BLAZE_ST_THROW        13   // one-shot del javelin (0.5s)
#define BLAZE_ST_SOLF_IDLE    14   // ExpellSolFlame (fallback IDLE)
#define BLAZE_ST_SOLF_WALK    15
#define BLAZE_ST_SOLF_RUN     16
#define BLAZE_ANIM_COUNT      17
#define BLAZE_SEQ_MAX_CAND    6

#define BLAZE_LOWHP           40     // umbral de las variantes lowhealth

// cadena de candidatos por estado (nombres GMod + variantes)
static const char g_sBlazeSeqCand[BLAZE_ANIM_COUNT][BLAZE_SEQ_MAX_CAND][24] = {
    { "idle",            "Idle",           "idle01",       "",             "",       ""        },  // 0
    { "walk",            "Walk",           "walk01",       "",             "",       ""        },  // 1
    { "run",             "Run",            "run01",        "RunTopSpeed",  "",       ""        },  // 2
    { "jump",            "Jump",           "Jump2",        "jumpv",        "",       ""        },  // 3
    { "fall",            "Fall",           "glide",        "",             "",       ""        },  // 4
    { "idle_lowhealth",  "IdleLowHealth",  "idle_low",     "IdleLow",      "hurt",   ""        },  // 5
    { "walk_lowhealth",  "WalkLowHealth",  "walk_low",     "",             "",       ""        },  // 6
    { "run_lowhealth",   "RunLowHealth",   "run_low",      "",             "",       ""        },  // 7
    { "DownedIdle",      "downedidle",     "downed_idle",  "",             "",       ""        },  // 8
    { "DownedWalk",      "downedwalk",     "downed_walk",  "",             "",       ""        },  // 9
    // v2.0-OM: gameplay (nombres del Lua: survivors2.lua L156-165 + L772)
    { "Kick",            "kick",           "KickIdle",     "attack",       "punch",  "Attack"  },  // 10
    { "SolDash",         "soldash",        "Sol Dash",     "solasdash",    "dash",   "run"     },  // 11
    { "Roll",            "roll",           "rollidle",     "spindash",     "Spin",   ""        },  // 12
    { "throw",           "Throw",          "Throw1",       "throwing",     "",       ""        },  // 13
    { "IdleSolFlame",    "IdleSolflame",   "idle_solflame", "IdleSol",    "",       ""        },  // 14
    { "WalkSolFlame",    "WalkSolflame",   "walk_solflame", "WalkSol",    "",       ""        },  // 15
    { "RunSolFlame",     "RunSolflame",    "run_solflame",  "RunSol",     "",       ""        }   // 16
};

ConVar g_cvBlazeAvatar;
bool   g_bBlazeModelOK     = false;   // blaze.mdl en el VPK montado
bool   g_bBlazeSeqResolved = false;   // el probe ya corrio en este mapa
Handle g_hBlazeAvatarThink = null;    // FSM 10 Hz
int    g_iBlazeAvatar[MAXPLAYERS + 1];      // EntRef copia R (0 = sin avatar)
int    g_iBlazeAvatarL[MAXPLAYERS + 1];     // EntRef copia L
int    g_iBlazeBodyRender[MAXPLAYERS + 1];  // render ORIGINAL del survivor
int    g_iBlazeAnimState[MAXPLAYERS + 1];   // estado FSM actual
float  g_fBlazeJumpStart[MAXPLAYERS + 1];   // t0 de la ventana del jump
float  g_fBlazeBodyYaw[MAXPLAYERS + 1];     // yaw suavizado del avatar
float  g_fBlazeYawLastT[MAXPLAYERS + 1];
bool   g_bBlazeSmSnap[MAXPLAYERS + 1];
float  g_fBlazeSmLoc[MAXPLAYERS + 1][3];
float  g_fBlazeSmLocL[MAXPLAYERS + 1][3];
float  g_fBlazeDeathHideUntil[MAXPLAYERS + 1];   // ventana anti-corpse
float  g_vBlazeDeathOrigin[MAXPLAYERS + 1][3];
bool   g_bBlazeWelcomeSaid[MAXPLAYERS + 1];      // aviso 1 vez por mapa
char   g_sBlazeSeq[BLAZE_ANIM_COUNT][24];        // nombre RESUELTO por estado
bool   g_bBlazeSeqOK[BLAZE_ANIM_COUNT];          // el estado resolvo?

#define Blaze_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// INICIALIZACION
// =======================

// ------------------ convars del kit (defaults del Lua) ------------------
ConVar g_cvBlazeKickUse, g_cvBlazeKickStack, g_cvBlazeKickCdMiss, g_cvBlazeKickCdLand,
       g_cvBlazeKickStun, g_cvBlazeKickDmg,
       g_cvBlazeKickSolPen, g_cvBlazeKickBurn;
ConVar g_cvBlazeDashUse, g_cvBlazeDashStack, g_cvBlazeDashCdMiss, g_cvBlazeDashCdLand,
       g_cvBlazeDashStun, g_cvBlazeDashDmg,
       g_cvBlazeDashBurn, g_cvBlazeDashSpeed, g_cvBlazeDashDrain;
ConVar g_cvBlazeJavUse, g_cvBlazeJavCd, g_cvBlazeJavSol, g_cvBlazeJavSpeed;
ConVar g_cvBlazeJavRadius;   // v2.8: radio de caza de la lanza (80 fijo antes)
ConVar g_cvBlazeJavPitch;    // v2.8: giro del modelo al disparar (90 = al frente)
ConVar g_cvBlazeSolfUse, g_cvBlazeSolfCd, g_cvBlazeSolfDrain, g_cvBlazeSolfRange,
       g_cvBlazeSolfAngle, g_cvBlazeSolfIgnite, g_cvBlazeSolfPush;
ConVar g_cvBlazeMaxSol, g_cvBlazeSolOnSpawn;
ConVar g_cvBlazeCdScale;   // v2.1-OM: multiplicador de TODOS los cooldowns del kit (0.5 = -50%)

// ------------------ v2.7-OM: LA BARRA (motor comun SBar) ------------------
// El estado del dibujado vive en SBar.inc (v3.77.81): Blaze solo
// aporta Blaze_BarState (abajo, antes del HUDLine) — cero variables
// propias de HUD en este include desde la v2.7

// ------------------ sonidos del Lua (probe por mapa) ------------------
#define BLAZE_SND_BEEP      "om/blaze/blazebeep.wav"
#define BLAZE_SND_KICK      "om/blaze/blazekick.wav"
#define BLAZE_SND_FIRESTORM "om/blaze/firestorm.wav"
#define BLAZE_SND_SWING     "om/knuckles/swing.wav"        // el Lua lo usa igual (ya en el VPK OM)
#define BLAZE_SND_DASHGO    "om/blaze/roundhouse kick.wav"
#define BLAZE_SND_JAV       "om/blaze/burning javelin.wav"
#define BLAZE_SND_JAVHIT    "om/blaze/blaze javelin hit.wav"
#define BLAZE_SND_IMPACT    "om/blaze/snd_impact.wav"
#define BLAZE_SND_SWOOSH    "om/blaze/swoosh.wav"
#define BLAZE_SND_COUNT     9
static const char g_sBlazeSnd[BLAZE_SND_COUNT][] = {
    BLAZE_SND_BEEP, BLAZE_SND_KICK, BLAZE_SND_FIRESTORM, BLAZE_SND_SWING,
    BLAZE_SND_DASHGO, BLAZE_SND_JAV, BLAZE_SND_JAVHIT, BLAZE_SND_IMPACT,
    BLAZE_SND_SWOOSH
};
bool g_bBlazeSndOK[BLAZE_SND_COUNT];
char g_sBlazeSndUse[BLAZE_SND_COUNT][96];   // la ruta que existe (om/ o OM/)


// v2.0-OM: indices para Blaze_Snd (las rutas son las de arriba)
#define BLAZE_IDX_BEEP      0
#define BLAZE_IDX_KICK      1
#define BLAZE_IDX_FIRESTORM 2
#define BLAZE_IDX_SWING     3
#define BLAZE_IDX_DASHGO    4
#define BLAZE_IDX_JAV       5
#define BLAZE_IDX_JAVHIT    6
#define BLAZE_IDX_IMPACT    7
#define BLAZE_IDX_SWOOSH    8

// ------------------ estado por jugador ------------------
float g_fBlazeSol[MAXPLAYERS + 1];          // meter SolFlame 0..max
float g_fBlazeKickDashCd[MAXPLAYERS + 1];   // 'Kick/dash_cd'
float g_fBlazeJavFlameCd[MAXPLAYERS + 1];   // 'Javelin/flame_cd'
float g_fBlazeChargeEnd[MAXPLAYERS + 1];    // fin de la carga (kick o dash)
int   g_iBlazeChargeKind[MAXPLAYERS + 1];   // 0=nada 1=kick 2=dash
bool  g_bBlazeKickFly[MAXPLAYERS + 1];      // 'Blaze_kicking' (ventana de vuelo)
float g_fBlazeKickFlyEnd[MAXPLAYERS + 1];   // 'KickStarted' (corta el miss)
float g_fBlazeSolDashWin[MAXPLAYERS + 1];   // 'SolDashStun' (ventana del dash)
bool  g_bBlazeDashLived[MAXPLAYERS + 1];    // 'SolDashStun_e' (hubo ventana)
bool  g_bBlazeDrainDash[MAXPLAYERS + 1];    // dash sostenido sol>=50
float g_fBlazeCanDashUntil[MAXPLAYERS + 1]; // 'CanDash'
bool  g_bBlazeExpell[MAXPLAYERS + 1];       // ExpellSolFlame activo
float g_fBlazeExpellStart[MAXPLAYERS + 1];  // 0.45s de carga del solflame
float g_fBlazeRollUntil[MAXPLAYERS + 1];    // Roll del miss
float g_fBlazeThrowUntil[MAXPLAYERS + 1];   // one-shot throw
float g_fBlazeNextBeep[MAXPLAYERS + 1];
int   g_iBlazeBeepPitch[MAXPLAYERS + 1];    // 'BlazeAddupval'
float g_fBlazeNextSwoosh[MAXPLAYERS + 1];
float g_fBlazeIframeUntil[MAXPLAYERS + 1];  // 'iframes2' +0.75
int   g_iBlazeForceAnim[MAXPLAYERS + 1];    // anim de juego (-1 = FSM normal)
bool  g_bBlazeDmgHooked[MAXPLAYERS + 1];
bool  g_bBlazeLaggedZero[MAXPLAYERS + 1];   // congelo lagged (carga del dash)
bool  g_bBlazeTintOn[MAXPLAYERS + 1];      // el tinte rojo esta puesto
float g_vBlazeNoSpin[3] = { 0.0, 0.0, 0.0 };   // ang vel 0 para Sonic_PhysSetVel
// javelin vivo (1 por jugador, como el Lua)
int   g_iBlazeJavelin[MAXPLAYERS + 1];          // EntRef
int   g_iBlazeJavelinTarget[MAXPLAYERS + 1];    // EntRef del arrastrado
float g_fBlazeJavCarryUntil[MAXPLAYERS + 1];    // 0.5s de arrastre
float g_fBlazeJavDieAt[MAXPLAYERS + 1];         // fin del fade
bool  g_bBlazeJavStuck[MAXPLAYERS + 1];         // clavado (freno el vuelo)
char  g_sBlazeJavModel[96] = "models/weapons/melee/w_pitchfork.mdl";
Handle g_hBlazeJavelinThink = null;
// v2.5-OM: vuelo del javelin SIN leer velocidades del prop (el datamap
// m_vecVelocity del prop_physics_override no siempre refleja el vphysics:
// si leia 0 el think lo daba por muerto al instante = "no lanza nada")
float g_vBlazeJavDir[MAXPLAYERS + 1][3];        // direccion de tiro (fija; el Lua: sin gravedad)
float g_fBlazeJavPrev[MAXPLAYERS + 1][3];       // origen del javelin en el tick anterior (barrido)
float g_fBlazeKickPrev[MAXPLAYERS + 1][3];      // origen de Blaze en el tick anterior (barrido kick/dash)
int    g_iBlazeGlowSprite = 0;

// v2.2-OM: EFECTOS DEL FUEGO — nombres de particulas (todas stock del
// motor, particles/inferno.pcf: las trae el propio L4D2, cero descarga)
#define BLZ_FX_MOLLY_EXPL      "molotov_explosion"
#define BLZ_FX_MOLLY_BURST     "molotov_explosion_burst"
#define BLZ_FX_MOLLY_BURST2    "molotov_explosion_burst2"
#define BLZ_FX_MOLLY_BURST3    "molotov_explosion_burst3"
#define BLZ_FX_MOLLY_CHEAP     "molotov_explosion_cheap"
#define BLZ_FX_WALL_PRIMARY    "inferno_wall_primary"
#define BLZ_FX_WALL_OCCL       "inferno_wall_occlusion"
// v2.5-OM: BLZ_FX_MOLLY_TRAIL ("molotov_trail") ELIMINADA — no existe en
// la lista de particulas de L4D2: la estela era invisible en silencio
// (misma clase de bug que las llamas inferno_wall_*). El fuego del
// javelin ahora es env_fire_small parentada (familia confirmada v2.3/v2.4)
#define BLZ_FX_FIRE_MEDIUM     "env_fire_medium"   // v2.3: fuegos ambientales de los mapas — solo CP0, SIEMPRE visible
#define BLZ_FX_FIRE_LARGE      "env_fire_large"    // v2.3: idem, grande (la boca del cono)
#define BLZ_FX_FIRE_SMALL      "env_fire_small"    // v2.4: idem, chica (la capa baja del fuego del dash)
#define BLZ_FX_DASH_Z          8.0     // v2.4: la capa BAJA del fuego del dash (pies)
#define BLZ_FX_DASH_Z_TORSO    40.0    // v2.4: la capa ALTA del fuego del dash (torso: la llama la envuelve)

// v2.2-OM: estado de los efectos
int    g_iBlazeDashFxRef[MAXPLAYERS + 1];   // v2.4: fuego del dash capa TORSO (EntRef, 0 = sin)
int    g_iBlazeDashFxRef2[MAXPLAYERS + 1];  // v2.4: fuego del dash capa PIES (EntRef, 0 = sin)
int    g_iBlazeJavFxRef[MAXPLAYERS + 1];    // v2.5: fuego del javelin parentado (EntRef, 0 = sin)
float  g_fBlazeNextWallFx[MAXPLAYERS + 1];  // cadencia de los segmentos del sol flame
ConVar g_cvBlazeFXFlamePitch;               // pitch de las particulas del cono
ConVar g_cvBlazeFXFlameLife;
ConVar g_cvBlazeFXDashLife;
ConVar g_cvBlazeFXDashName;                 // v2.4: particula del fuego del dash (capa TORSO)
ConVar g_cvBlazeFXDashName2;                // v2.4: segunda capa del fuego del dash (PIES)
ConVar g_cvBlazeFXSolfCadence;
ConVar g_cvBlazeFXFlameName;                // v2.3: particula de los TRAMOS del cono
ConVar g_cvBlazeFXFlameMouth;               // v2.3: particula de la BOCA del cono
ConVar g_cvBlazeAoeRadius;
ConVar g_cvBlazeAoeDmg;
// v2.12-OM: la lanza rework + el nerf del Sol + el cono que acumula
ConVar g_cvBlazeJavDmgMin, g_cvBlazeJavDmgMax, g_cvBlazeJavRamp;
ConVar g_cvBlazeJavExplDmg, g_cvBlazeJavExplTank, g_cvBlazeJavExplRad;
ConVar g_cvBlazeSolChargeCommon, g_cvBlazeSolChargeSpecial;
ConVar g_cvBlazeSolChargeTank, g_cvBlazeSolChargeWitch;
ConVar g_cvBlazeFlameWeakMax, g_cvBlazeBurnEnable;
ConVar g_cvBlazeJavModelCfg;
ConVar g_cvBlazeKickRefund;                // v2.5: % del cd devuelto al acertar el kick
ConVar g_cvBlazeFXJavName;                 // v2.5: particula de fuego del javelin
ConVar g_cvBlazeSolfConeDmg;
// v2.11-OM: LA TABLA DE DAÑO AUMENTADA — escalado del kick y del dash
// aereo por el meter Sol, el x2 a la witch y la DEBILIDAD del dash
ConVar g_cvBlazeKickDmgMin, g_cvBlazeKickDmgMax, g_cvBlazeDashDmgMin, g_cvBlazeDashDmgMax,
       g_cvBlazeDashHitRad, g_cvBlazeDashAoeScale, g_cvBlazeWitchMult,
       g_cvBlazeWeakDur, g_cvBlazeWeakMult;


public void Blaze_OnPluginStart()
{
    // v1.0-OM: avatar espejo (patron rouge_avatar / knux_avatar /
    // shadow_avatar / cream_avatar)
    g_cvBlazeAvatar = CreateConVar("blaze_avatar", "1", "Blaze OM: avatar espejo (blaze.mdl del VPK de recursos; se activa con el modelo blaze aplicado por el CST)", _, true, 0.0, true, 1.0);
    // v2.1-OM: el pedido del owner — "los enfriamientos de las habilidades
    // de blaze reducen un 50% (para poder limpiar zombies)". Escala TODOS
    // los cooldowns del kit (kick/dash/javelin/solflame); 1.0 = como el Lua.
    g_cvBlazeCdScale = CreateConVar("blaze_cd_scale", "0.5", "v2.1: multiplicador de TODOS los cooldowns de Blaze (0.5 = -50% pedido del owner; 1.0 = valores del Lua)", _, true, 0.1, true, 1.0);

    // v2.0-OM: EL KIT — convars con los DEFAULTS EXACTOS del Lua
    // (register_noodles_blaze.lua L6-47). Nombres blaze_* como alla.
    g_cvBlazeKickUse   = CreateConVar("blaze_kick_useable",        "1",   "Lua: kick_useable");
    g_cvBlazeKickStack = CreateConVar("blaze_kick_stunstack",      "0",   "Lua: kick_stunstack");
    g_cvBlazeKickCdMiss= CreateConVar("blaze_kick_cooldownmiss",   "25",  "Lua: kick_cooldownmiss");
    g_cvBlazeKickCdLand= CreateConVar("blaze_kick_cooldownland",   "17",  "Lua: kick_cooldownland");
    g_cvBlazeKickStun  = CreateConVar("blaze_kick_basestun",       "4",   "Lua: kick_basestun (seg)");
    g_cvBlazeKickDmg   = CreateConVar("blaze_kick_basedamage",      "25",  "DEPRECATED v2.11: reemplazado por blaze_kick_dmg_min/_max (escalado 200-550 por el meter Sol). Registrado para no ensuciar el Sonic_Suite.cfg — YA SIN EFECTO");
    CreateConVar("blaze_kick_solflamemeter",   "35",  "DEPRECATED v2.12: reemplazado por blaze_sol_charge_common/_special/_tank/_witch (el ataque principal carga POR TIPO DE VICTIMA). Registrado para no ensuciar el Sonic_Suite.cfg — YA SIN EFECTO");
    CreateConVar("blaze_kick_solflamemeterSolflame", "15", "DEPRECATED v2.12: ya sin efecto (ver blaze_sol_charge_*)");
    g_cvBlazeKickSolPen= CreateConVar("blaze_kick_solflamemeter_penalty", "15", "Lua: penal del miss con sol>=50");
    g_cvBlazeKickBurn  = CreateConVar("blaze_kick_canburn",        "1",   "Lua: kick_canburn (quemar en modo Sol)");
    // v2.5-OM: el reembolso del owner — "la patada regresara un 65% de
    // enfriamiento" AL ACERTAR: se le devuelve el 65% del cd de aterrizaje
    // (cd efectivo al pegar = cooldownland * (1-0.65) = 17 -> 5.95s, antes
    // de blaze_cd_scale). El miss conserva su cd completo (cooldownmiss).
    g_cvBlazeKickRefund = CreateConVar("blaze_kick_cdrefund", "0.65",
        "v2.5: % del enfriamiento que se DEVUELVE al acertar la patada (pedido del owner). 0.65 = espera solo el 35% (17s -> 5.95s antes de blaze_cd_scale); 1.0 = sin cd al pegar; 0 = como el Lua", _, true, 0.0, true, 1.0);
    g_cvBlazeDashUse   = CreateConVar("blaze_soldash_useable",     "1",   "Lua: SolDash_useable");
    g_cvBlazeDashStack = CreateConVar("blaze_soldash_stunstack",   "0",   "Lua: SolDash_stunstack");
    g_cvBlazeDashCdMiss= CreateConVar("blaze_soldash_cooldownmiss", "25", "Lua: SolDash_cooldownmiss");
    g_cvBlazeDashCdLand= CreateConVar("blaze_soldash_cooldownland", "17", "Lua: soldash_cooldownland");
    g_cvBlazeDashStun  = CreateConVar("blaze_soldash_basestun",    "4",   "Lua: SolDash_basestun (seg)");
    g_cvBlazeDashDmg   = CreateConVar("blaze_soldash_basedamage",   "25",  "DEPRECATED v2.11: reemplazado por blaze_dash_dmg_min/_max (escalado 800-1650 por el meter Sol). Registrado para no ensuciar el Sonic_Suite.cfg — YA SIN EFECTO");
    CreateConVar("blaze_soldash_solflamemeter", "35", "DEPRECATED v2.12: reemplazado por blaze_sol_charge_common/_special/_tank/_witch. Registrado para no ensuciar el Sonic_Suite.cfg — YA SIN EFECTO");
    CreateConVar("blaze_soldash_solflamemeterSolflame", "15", "DEPRECATED v2.12: ya sin efecto (ver blaze_sol_charge_*)");
    g_cvBlazeDashBurn  = CreateConVar("blaze_soldash_canburn",     "1",   "Lua: SolDash_canburn");
    g_cvBlazeDashSpeed = CreateConVar("blaze_soldashspeed",        "1400", "Lua: soldashspeed (u/s del dash)");
    g_cvBlazeDashDrain = CreateConVar("blaze_draindash_drain",     "5",   "DrainDash: sol por segundo (Lua: 0.5/tick)");
    g_cvBlazeJavUse    = CreateConVar("blaze_javelin_useable",      "1",   "Lua: javelin_useable");
    g_cvBlazeJavCd     = CreateConVar("blaze_javelin_cooldown",     "25",  "Lua: javelin_cooldown");
    g_cvBlazeJavSol    = CreateConVar("blaze_javelin_solflamemeter", "15", "Lua: javelin_solflamemeter");
    g_cvBlazeJavSpeed  = CreateConVar("blaze_javelin_speed",       "3000", "Lua: 10000 en GMod; 3000 = lo mas rapido fiable del tick de L4D2 (como el martillo de Amy)");
    g_cvBlazeJavRadius = CreateConVar("blaze_javelin_radius",       "120", "v2.8: radio de CAZA de la lanza en unidades (esfera alrededor del recorrido; 80 fijo antes — pedido del owner: mas alcance)");
    g_cvBlazeJavPitch  = CreateConVar("blaze_javelin_pitch",         "90", "v2.8: giro del modelo al disparar (90 = la lanza apunta AL FRENTE en vuelo; -90 si quedara al reves; 0 = vertical como antes)");
    g_cvBlazeSolfUse   = CreateConVar("blaze_solflame_useable",    "1",   "Lua: solflame_useable");
    g_cvBlazeSolfCd    = CreateConVar("blaze_solflame_cooldown",    "25",  "Lua: solflame_cooldown");
    g_cvBlazeSolfDrain = CreateConVar("blaze_solflame_drain",      "2.5", "SolFlame: sol por segundo (Lua: 0.25/tick)");
    g_cvBlazeSolfRange = CreateConVar("blaze_solflame_range",      "650", "Lua: FindInCone 650u");
    g_cvBlazeSolfAngle = CreateConVar("blaze_solflame_angle",      "50",  "Lua: cono 50 grados");
    g_cvBlazeSolfIgnite= CreateConVar("blaze_solflame_ignite",     "1.35", "Lua: OM_burntarget 1.35s (seg de fuego)");
    g_cvBlazeSolfPush  = CreateConVar("blaze_solflame_push",       "275", "Lua: NPC push 275");
    g_cvBlazeMaxSol    = CreateConVar("blaze_maxSolflame",          "100", "Lua: maxSolflame");
    g_cvBlazeSolOnSpawn=CreateConVar("blaze_SolfalemOnSapwn",      "0",   "Lua: SolfalemOnSapwn");

    // v2.2-OM: LOS EFECTOS DEL FUEGO (pedido del owner 2026-10-15)
    g_cvBlazeFXFlameName = CreateConVar("blaze_fx_flame_name", "env_fire_medium",
        "v2.3: particula de los TRAMOS del cono del Sol Flame. env_fire_medium = las llamas de los fuegos ambientales de los mapas (solo CP0: SIEMPRE visible). inferno_wall_primary = el muro del molotov (dibuja el tramo ENTRE punto y punto). La inferno_wall_occlusion del pedido original es la CAPA DE MASCARA del muro — por eso nunca se vio");
    g_cvBlazeFXFlameMouth = CreateConVar("blaze_fx_flame_mouth", "env_fire_large",
        "v2.3: particula de la BOCA del cono (la llama grande junto a Blaze)");
    g_cvBlazeFXFlamePitch = CreateConVar("blaze_fx_flame_pitch", "-90.0",
        "v2.3: PITCH de las particulas del cono (solo afecta a la familia inferno_wall_*; las env_fire_* arden hacia arriba siempre)", _, true, -180.0, true, 180.0);
    g_cvBlazeFXFlameLife = CreateConVar("blaze_fx_flame_life", "1.5",
        "v2.2: vida (seg) de cada segmento del muro de fuego del Sol Flame", _, true, 0.1, true, 10.0);
    g_cvBlazeFXDashLife = CreateConVar("blaze_fx_dash_life", "25.0",
        "v2.4: tope de seguridad (seg) de las particulas del fuego del cuerpo del Sol Dash (el Drain Dash puede durar hasta ~20s); la habilidad las remueve ANTES al terminar", _, true, 1.0, true, 30.0);
    g_cvBlazeFXDashName = CreateConVar("blaze_fx_dash_name", "env_fire_medium",
        "v2.4: particula del FUEGO DEL CUERPO del Sol Dash (capa TORSO). env_fire_medium = fuego ambiental de los mapas (solo CP0: SIEMPRE visible, en loop — la rodea entera). OJO: la inferno_wall_primary del pedido original es un muro de DOS puntos (dibuja ENTRE su origen y el cpoint1): parentada sola al cuerpo NO dibuja nada — por eso el fuego del dash era invisible");
    g_cvBlazeFXDashName2 = CreateConVar("blaze_fx_dash_name2", "env_fire_small",
        "v2.4: segunda capa del fuego del Sol Dash (PIES, env_fire_small). Vacio = solo la capa del torso");
    // v2.5-OM: el fuego del JAVELIN — la molotov_trail de la v2.2 no
    // existe en L4D2 (estela invisible en silencio). La familia env_fire_*
    // es la confirmada por el owner en el Sol Flame v2.3 y el dash v2.4.
    g_cvBlazeFXJavName = CreateConVar("blaze_fx_jav_name", "env_fire_small",
        "v2.5: particula de FUEGO del Burning Javelin (parentada al picon en vuelo). env_fire_small = fuego ambiental de los mapas (solo CP0: SIEMPRE visible — familia confirmada Sol Flame v2.3 / dash v2.4). Vacio = sin fuego, solo el picon");
    g_cvBlazeFXSolfCadence = CreateConVar("blaze_fx_solf_cadence", "0.35",
        "v2.2: cadencia (seg) de refresco de los segmentos del muro del Sol Flame", _, true, 0.1, true, 2.0);
    g_cvBlazeAoeRadius = CreateConVar("blaze_aoe_radius", "250",
        "v2.2: radio del dano en area a commons alrededor del impacto (kick/dash/javelin)", _, true, 0.0);
    g_cvBlazeAoeDmg = CreateConVar("blaze_aoe_damage", "80",
        "v2.2: dano base del AOE a commons (amplificado por suite_dmg_scale como todo el suite)", _, true, 0.0);
    CreateConVar("blaze_javelin_damage", "45",
        "v2.2: dano del Burning Javelin al ENGANCHAR a la victima (antes no hacia dano, solo arrastraba)", _, true, 0.0);
    g_cvBlazeJavModelCfg = CreateConVar("blaze_jav_model", "",
        "v2.5: modelo manual del javelin (vacio = cadena automatica pitchfork->katana->gascan). El pitchfork es del PROPIO L4D2 (The Sacrifice): TODO cliente lo tiene, siempre visible — decision del owner");
    g_cvBlazeSolfConeDmg = CreateConVar("blaze_solflame_conedmg", "20",
        "v2.2: dano por pasada (cada 0.5s) del Sol Flame a los commons en el cono", _, true, 0.0);

    // v2.11-OM: LA TABLA DE DAÑO AUMENTADA (pedido del owner 2026-10-17):
    // kick 200-550 y dash aereo 800-1650 ESCALANDO con el meter Sol (0 =
    // min, 100 = max; los comunes siguen muriendo de UN golpe: el minimo
    // de 200 base ya reventa al comun de 50HP), la WITCH x2 + su stun
    // correspondiente, la lanza la empuja aplicando su congelacion, y el
    // dash deja DEBILIDAD 6s (x1.5 todas las otras habilidades).
    g_cvBlazeKickDmgMin = CreateConVar("blaze_kick_dmg_min", "200",
        "v2.11: daño MINIMO de la patada (meter Sol en 0). Escala lineal hasta blaze_kick_dmg_max con el Sol lleno. Los comunes siguen muriendo de UN golpe", _, true, 0.0);
    g_cvBlazeKickDmgMax = CreateConVar("blaze_kick_dmg_max", "550",
        "v2.11: daño MAXIMO de la patada (meter Sol en 100 = 550). Reemplaza al blaze_kick_basedamage del Lua (deprecated)", _, true, 0.0);
    g_cvBlazeDashDmgMin = CreateConVar("blaze_dash_dmg_min", "800",
        "v2.11: daño MINIMO del Sol Dash aereo (meter Sol en 0). Escala lineal hasta blaze_dash_dmg_max con el Sol lleno", _, true, 0.0);
    g_cvBlazeDashDmgMax = CreateConVar("blaze_dash_dmg_max", "1650",
        "v2.11: daño MAXIMO del Sol Dash aereo (meter Sol en 100 = 1650). Reemplaza al blaze_soldash_basedamage del Lua (deprecated)", _, true, 0.0);
    g_cvBlazeDashHitRad = CreateConVar("blaze_dash_hitradius", "150",
        "v2.11: radio de la esfera del barrido del DASH AEREO (100 fijo antes = area mas grande; el kick conserva su 100 de siempre)", _, true, 40.0);
    g_cvBlazeDashAoeScale = CreateConVar("blaze_dash_aoescale", "1.5",
        "v2.11: multiplicador del radio del AOE del impacto del dash aereo (1.5 = 250u -> 375u; 1.0 = como kick/javelin)", _, true, 0.1);
    g_cvBlazeWitchMult = CreateConVar("blaze_witch_dmgmult", "2.0",
        "v2.11: multiplicador de daño de TODO el kit de Blaze contra la WITCH (2.0 = el doble, pedido del owner) + su stun correspondiente (kick/dash 4s, lanza 1s)", _, true, 0.1);
    g_cvBlazeWeakDur = CreateConVar("blaze_weak_duration", "6",
        "v2.11: segundos de DEBILIDAD que deja el dash aereo en su victima (mientras dure, todas las otras habilidades de Blaze le pegan x blaze_weak_dmgmult)", _, true, 0.0);
    g_cvBlazeWeakMult = CreateConVar("blaze_weak_dmgmult", "1.5",
        "v2.11: multiplicador de daño de las OTRAS habilidades contra objetivos DEBILES por el dash (el dash que origina la debilidad NO se amplifica a si mismo)", _, true, 0.1);

    // v2.12-OM: LA LANZA + EL SOL + EL CONO (ronda 2 del owner)
    g_cvBlazeJavDmgMin    = CreateConVar("blaze_javelin_dmg_min", "255",
        "v2.12: daño BASE del enganche del Burning Javelin (aleatorio min-max por enganche; antes 45 fijo)");
    g_cvBlazeJavDmgMax    = CreateConVar("blaze_javelin_dmg_max", "354",
        "v2.12: tope del aleatorio base del enganche (255-354)");
    g_cvBlazeJavRamp      = CreateConVar("blaze_javelin_ramp", "0.75",
        "v2.12: el daño crece +75% al llegar a su distancia maxima (fraccion del vuelo de 6s desde el disparo)", _, true, 0.0, true, 2.0);
    g_cvBlazeJavExplDmg   = CreateConVar("blaze_javelin_expl_dmg", "1100",
        "v2.12: al TOPE de vuelo (distancia maxima) la lanza EXPLOTA: daño al centro");
    g_cvBlazeJavExplTank  = CreateConVar("blaze_javelin_expl_tankmult", "0.75",
        "v2.12: la explosion de la lanza es -25% efectiva contra el tank");
    g_cvBlazeJavExplRad   = CreateConVar("blaze_javelin_expl_radius", "200",
        "v2.12: radio de la explosion de la lanza al tope de vuelo");
    g_cvBlazeSolChargeCommon = CreateConVar("blaze_sol_charge_common", "2",
        "v2.12: Sol por COMUN MUERTO con el golpe directo del ataque principal (antes +35 por golpe)");
    g_cvBlazeSolChargeSpecial= CreateConVar("blaze_sol_charge_special", "22",
        "v2.12: Sol por golpear a un especial (SI) con el ataque principal");
    g_cvBlazeSolChargeTank   = CreateConVar("blaze_sol_charge_tank", "30",
        "v2.12: Sol por golpear al tank con el ataque principal");
    g_cvBlazeSolChargeWitch  = CreateConVar("blaze_sol_charge_witch", "25",
        "v2.12: Sol por golpear a la witch con el ataque principal");
    g_cvBlazeFlameWeakMax = CreateConVar("blaze_flameweak_max", "1.5",
        "v2.12: tope del stack de DEBILIDAD del Sol Flame (+1% cada 0.5s de fuego del cono; 1.5 = +150%)");
    g_cvBlazeBurnEnable   = CreateConVar("blaze_burn_enable", "1",
        "v2.10-witch: kill-switch — 0 = CERO IgniteEntity desde Blaze (palanca de diagnostico)", _, true, 0.0, true, 1.0);

    // v1.0-OM: la MUERTE del avatar en el POST propio (leccion Rouge
    // v3.77.49: ni el PRE ni el POST del manager tocan el avatar)
    HookEvent("player_death", Blaze_Event_PlayerDeath);

    // v3.77.69: sin AutoExecConfig — config UNICA del suite
    // (Sonic_Suite.cfg, auto-guardada; ver manager)
}

public void Blaze_OnMapStart()
{
    // v1.0-OM: AVATAR — blaze.mdl del VPK (deteccion FileExists estilo
    // star_stun: ve los VPK montados; sin el archivo TODO cae al
    // survivor normal, CERO dependencia)
    g_bBlazeModelOK = FileExists(BLAZE_OM_MODEL, true);
    if (g_bBlazeModelOK) PrecacheModel(BLAZE_OM_MODEL, true);

    // diagnostico del arranque para el owner (una linea en el log)
    if (g_bBlazeModelOK)
        PrintToServer("[Blaze %s] blaze.mdl del VPK OK — avatar espejo listo (modelo blaze aplicado = avatar).", BLAZE_INC_VERSION);
    else
        PrintToServer("[Blaze %s] blaze.mdl NO encontrado (%s) — avatar DESACTIVADO este mapa (cero dependencia).", BLAZE_INC_VERSION, BLAZE_OM_MODEL);

    // v2.11-OM: aviso ONE-SHOT si el owner tenia personalizado algun
    // convar DEPRECATED del Lua (blaze_kick/soldash_basedamage ya no
    // hacen nada — el daño vive en los pares *_dmg_min/max nuevos).
    // Con el default del Lua (25) no imprime nada.
    if (g_cvBlazeKickDmg != null && g_cvBlazeKickDmg.IntValue != 25)
        PrintToServer("[Blaze %s] OJO: blaze_kick_basedamage = %d esta DEPRECATED (v2.11, ya sin efecto) — el daño de la patada ahora escala blaze_kick_dmg_min/max (200-550 por el meter Sol).", BLAZE_INC_VERSION, g_cvBlazeKickDmg.IntValue);
    if (g_cvBlazeDashDmg != null && g_cvBlazeDashDmg.IntValue != 25)
        PrintToServer("[Blaze %s] OJO: blaze_soldash_basedamage = %d esta DEPRECATED (v2.11, ya sin efecto) — el daño del Sol Dash aereo ahora escala blaze_dash_dmg_min/max (800-1650 por el meter Sol).", BLAZE_INC_VERSION, g_cvBlazeDashDmg.IntValue);

    // v2.0-OM: SONIDOS del kit — probe DUAL por FileExists: el Lua escribe
    // "OM/blaze/..."; el suite L4D2 ha usado om/ minuscula. Se emite el
    // que exista en el VPK montado. Sin pack: el kit funciona igual en
    // silencio; esta linea le dice al owner que falta.
    {
        char low[96], up[96], probe[128];
        int ok = 0;
        for (int s = 0; s < BLAZE_SND_COUNT; s++)
        {
            // minuscula om/ primero (como om/knuckles del suite)
            Format(probe, sizeof(probe), "sound/%s", g_sBlazeSnd[s]);
            strcopy(g_sBlazeSndUse[s], 96, g_sBlazeSnd[s]);
            g_bBlazeSndOK[s] = FileExists(probe, true);
            if (!g_bBlazeSndOK[s])
            {
                // luego la capital del Lua: OM/...
                strcopy(low, 96, g_sBlazeSnd[s]);
                if (strncmp(low, "om/", 3) == 0)
                {
                    Format(up, sizeof(up), "OM/%s", low[3]);
                    Format(probe, sizeof(probe), "sound/%s", up);
                    if (FileExists(probe, true))
                    {
                        strcopy(g_sBlazeSndUse[s], 96, up);
                        g_bBlazeSndOK[s] = true;
                    }
                }
            }
            if (g_bBlazeSndOK[s]) { PrecacheSound(g_sBlazeSndUse[s], true); ok++; }
        }
        if (ok < BLAZE_SND_COUNT)
            PrintToServer("[Blaze %s] sonidos om/blaze del VPK: %d/%d (los que faltan se saltan en silencio — el kit funciona igual).", BLAZE_INC_VERSION, ok, BLAZE_SND_COUNT);
    }

    // v2.5-OM: modelo del JAVELIN = PITCHFORK (decision del owner: el Lua
    // usa el harpoon002a.mdl de HL2, que L4D2 NO trae — y aunque el VPK
    // del server lo tenga, los clientes SIN el addon ven un prop sin
    // modelo = invisible, o el motor mata el prop al spawnear si el
    // modelo no existe ni en el server = "no lanza nada"). El picon de
    // horca (w_pitchfork.mdl, The Sacrifice) viene en el L4D2 BASE:
    // TODO cliente lo tiene. Cadena: pitchfork -> katana -> gas can.
    // v2.2-OM: convar blaze_jav_model = override MANUAL (si quieres el
    // harpoon del VPK ponlo aqui a mano)
    {
        char manual[96];
        if (g_cvBlazeJavModelCfg != null) g_cvBlazeJavModelCfg.GetString(manual, sizeof(manual));
        if (manual[0] != '\0' && FileExists(manual, true))
        {
            strcopy(g_sBlazeJavModel, sizeof(g_sBlazeJavModel), manual);
        }
        else
        {
            static const char sJavModels[][] = {
                "models/weapons/melee/w_pitchfork.mdl",
                "models/weapons/melee/w_katana.mdl",
                "models/props_junk/gascan001a.mdl"
            };
            strcopy(g_sBlazeJavModel, sizeof(g_sBlazeJavModel), sJavModels[0]);
            for (int m = 0; m < sizeof(sJavModels); m++)
            {
                if (FileExists(sJavModels[m], true))
                {
                    strcopy(g_sBlazeJavModel, sizeof(g_sBlazeJavModel), sJavModels[m]);
                    break;
                }
            }
        }
        PrecacheModel(g_sBlazeJavModel, true);
        // diagnostico para el owner (una linea en el log del server)
        PrintToServer("[Blaze %s] javelin: %s%s", BLAZE_INC_VERSION, g_sBlazeJavModel,
            (strncmp(g_sBlazeJavModel, "models/weapons/melee/w_pitchfork.mdl", 37) == 0)
            ? "  (picon del L4D2 base: SIEMPRE visible en todo cliente)"
            : "  (modelo manual: si algun cliente no lo ve, usa models/weapons/melee/w_pitchfork.mdl)");
    }

    // v2.2-OM: PARTICULAS DEL FUEGO — registro en la tabla del motor
    // (patron Knux_PrecacheParticle / Rouge v9). Todas stock de
    // particles/inferno.pcf (el propio L4D2 las trae); la mayoria ya
    // estan porque el sistema de fuego las precachea — esto es no-op
    // inocuo de seguro.
    Blaze_ParticlePrecache(BLZ_FX_MOLLY_EXPL);
    Blaze_ParticlePrecache(BLZ_FX_MOLLY_BURST);
    Blaze_ParticlePrecache(BLZ_FX_MOLLY_BURST2);
    Blaze_ParticlePrecache(BLZ_FX_MOLLY_BURST3);
    Blaze_ParticlePrecache(BLZ_FX_MOLLY_CHEAP);
    Blaze_ParticlePrecache(BLZ_FX_WALL_PRIMARY);
    Blaze_ParticlePrecache(BLZ_FX_WALL_OCCL);
    // v2.5: molotov_trail eliminada (no existe en L4D2 — estela invisible)
    // v2.3-OM: los fuegos ambientales de los mapas (el cono del Sol
    // Flame — las env_fire_* de la lista oficial de particulas L4D2)
    Blaze_ParticlePrecache(BLZ_FX_FIRE_MEDIUM);
    Blaze_ParticlePrecache(BLZ_FX_FIRE_LARGE);
    // v2.4-OM: la capa baja del fuego del dash + lo que el owner ponga
    // en los convars del dash (por si customiza el look en el cfg)
    Blaze_ParticlePrecache(BLZ_FX_FIRE_SMALL);
    char sBlzDashFxN[64], sBlzDashFxN2[64];
    if (g_cvBlazeFXDashName != null)
    {
        g_cvBlazeFXDashName.GetString(sBlzDashFxN, sizeof(sBlzDashFxN));
        if (sBlzDashFxN[0] != '\0') Blaze_ParticlePrecache(sBlzDashFxN);
    }
    if (g_cvBlazeFXDashName2 != null)
    {
        g_cvBlazeFXDashName2.GetString(sBlzDashFxN2, sizeof(sBlzDashFxN2));
        if (sBlzDashFxN2[0] != '\0') Blaze_ParticlePrecache(sBlzDashFxN2);
    }
    // v2.5-OM: el fuego del javelin (lo que el owner ponga en el convar)
    char sBlzJavFxN[64];
    if (g_cvBlazeFXJavName != null)
    {
        g_cvBlazeFXJavName.GetString(sBlzJavFxN, sizeof(sBlzJavFxN));
        if (sBlzJavFxN[0] != '\0') Blaze_ParticlePrecache(sBlzJavFxN);
    }
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iBlazeDashFxRef[i] = 0;
        g_iBlazeDashFxRef2[i] = 0;
        g_iBlazeJavFxRef[i]  = 0;
        g_fBlazeNextWallFx[i] = 0.0;
    }

    // v2.0-OM: glow sprite nativo + think del javelin (30 Hz) + estado
    g_iBlazeGlowSprite = PrecacheModel("materials/sprites/glow01.vmt", true);
    for (int i = 1; i <= MaxClients; i++) Blaze_ResetGameplay(i, true);
    delete g_hBlazeJavelinThink;
    g_hBlazeJavelinThink = CreateTimer(0.033, T_BlazeJavelinThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // v1.0-OM: FSM del avatar (10 Hz, patron T_RougeAvatarThink) + el
    // probe de secuencias se re-resuelve en cada mapa (el .mdl puede
    // cambiar entre VPKs)
    g_bBlazeSeqResolved = false;
    for (int s = 0; s < BLAZE_ANIM_COUNT; s++) g_bBlazeSeqOK[s] = false;
    delete g_hBlazeAvatarThink;
    g_hBlazeAvatarThink = CreateTimer(0.1, T_BlazeAvatarThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    for (int i = 1; i <= MaxClients; i++)
    {
        g_iBlazeAvatar[i]     = 0;
        g_iBlazeAvatarL[i]    = 0;
        g_iBlazeAnimState[i]  = -1;
        g_bBlazeWelcomeSaid[i] = false;
        g_fBlazeDeathHideUntil[i] = 0.0;
    }
}

// =====================================================================
// DETECCION DEL PERSONAJE — POR MODELO (v3.77.70: Blaze TAMBIEN es
// seleccionable en el menu — BLAZE_INDEX 11 — y el guard aplica
// blaze.cfg al seleccionarla, lo que deja el modelo survivor_blaze
// puesto: esta deteccion lo pesca igual. El avatar sigue al MODELO,
// no a la seleccion: da igual quien lo aplico (menu del manager,
// sm_blaze manual, mapa de slots del CST o perfil por senal).
// =====================================================================
bool Blaze_PlayerIs(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return false;

    // el modelo CST del personaje: survivor_blaze.mdl (y la variante
    // _light del mismo VPK — mismo personaje)
    char m[96];
    GetClientModel(client, m, sizeof(m));
    if (StrContains(m, "survivor_blaze", false) == -1) return false;

    // YIELD: un personaje del manager CON AVATAR PROPIO seleccionado
    // manda — su avatar es el legitimo (el personaje es la identidad
    // con sus habilidades; el modelo CST encima es solo skin). Sally
    // y Sage NO tienen avatar: con ellos (o "Sin personaje") el
    // avatar de Blaze SI se monta. Blaze seleccionada (BLAZE_INDEX)
    // NO entra en esta lista a proposito: es su propio personaje y
    // su avatar es este.
    int c = g_iPlayerCharIdx[client];
    if (c == SONIC_INDEX     || c == TAILS_INDEX    || c == KNUCKLES_INDEX
     || c == AMY_INDEX       || c == SHADOW_INDEX   || c == ROUGE_INDEX
     || c == CREAM_INDEX     || c == METALSONIC_INDEX || c == EGGMAN_INDEX)
        return false;

    return true;
}

// =====================================================================
// RESOLUCION DE SECUENCIAS POR PROBE (receta Amy v92 / Shadow v6.0 /
// Cream v7.0): SourcePawn no trae LookupSequence — se dispara
// SetAnimation(nombre) y se lee m_nSequence: si el indice CAMBIO, el
// nombre existe en el .mdl. Se resuelve UNA vez por mapa (al nacer el
// primer avatar, todo dentro del mismo frame).
// =====================================================================
void Blaze_ResolveTry(int av, int state, const char[] name)
{
    if (g_bBlazeSeqOK[state]) return;
    if (!HasEntProp(av, Prop_Send, "m_nSequence")) return;

    int before = GetEntProp(av, Prop_Send, "m_nSequence");
    SetVariantString(name);
    AcceptEntityInput(av, "SetAnimation");
    int after = GetEntProp(av, Prop_Send, "m_nSequence");

    if (after != before)
    {
        strcopy(g_sBlazeSeq[state], sizeof(g_sBlazeSeq[]), name);
        g_bBlazeSeqOK[state] = true;
    }
}

void Blaze_ResolveSeqs(int av)
{
    if (g_bBlazeSeqResolved) return;
    g_bBlazeSeqResolved = true;

    // cadena de candidatos por estado (nombres GMod + variantes)
    for (int st = 0; st < BLAZE_ANIM_COUNT; st++)
    {
        for (int c = 0; c < BLAZE_SEQ_MAX_CAND; c++)
        {
            if (g_sBlazeSeqCand[st][c][0] == '\0') break;
            Blaze_ResolveTry(av, st, g_sBlazeSeqCand[st][c]);
            if (g_bBlazeSeqOK[st]) break;
        }
    }

    // 2a pasada del idle (truco Amy v92: si el default del modelo YA
    // era idle, la primera prueba no movio el indice — ahora el actual
    // es otro y si "idle" existe, se registra)
    Blaze_ResolveTry(av, BLAZE_ST_IDLE, "idle");

    // fallbacks de las variantes que el modelo no traiga: la base
    // cubre el hueco (nunca T-pose)
    int fallbacks[BLAZE_ANIM_COUNT];
    for (int fb = 0; fb < BLAZE_ANIM_COUNT; fb++) fallbacks[fb] = -1;
    fallbacks[BLAZE_ST_IDLE_LOW]    = BLAZE_ST_IDLE;
    fallbacks[BLAZE_ST_WALK_LOW]    = BLAZE_ST_WALK;
    fallbacks[BLAZE_ST_RUN_LOW]     = BLAZE_ST_RUN;
    fallbacks[BLAZE_ST_DOWNED_IDLE] = BLAZE_ST_IDLE;
    fallbacks[BLAZE_ST_DOWNED_WALK] = BLAZE_ST_WALK;
    // v2.0-OM: los estados de juego caen a su base (nunca T-pose)
    fallbacks[BLAZE_ST_SOLDASH]     = BLAZE_ST_RUN;
    fallbacks[BLAZE_ST_ROLL]        = BLAZE_ST_IDLE;
    fallbacks[BLAZE_ST_SOLF_IDLE]   = BLAZE_ST_IDLE;
    fallbacks[BLAZE_ST_SOLF_WALK]   = BLAZE_ST_WALK;
    fallbacks[BLAZE_ST_SOLF_RUN]    = BLAZE_ST_RUN;

    for (int s = 0; s < BLAZE_ANIM_COUNT; s++)
    {
        if (g_bBlazeSeqOK[s] || fallbacks[s] < 0) continue;
        if (g_bBlazeSeqOK[fallbacks[s]])
        {
            strcopy(g_sBlazeSeq[s], sizeof(g_sBlazeSeq[]), g_sBlazeSeq[fallbacks[s]]);
            g_bBlazeSeqOK[s] = true;
        }
    }
}

// la secuencia a usar para un estado (con triple red de seguridad)
void Blaze_SeqFor(int state, char out[24])
{
    if (g_bBlazeSeqOK[state])
        strcopy(out, 24, g_sBlazeSeq[state]);
    else if (g_bBlazeSeqOK[BLAZE_ST_IDLE])
        strcopy(out, 24, g_sBlazeSeq[BLAZE_ST_IDLE]);
    else
        strcopy(out, 24, "idle");
}

// =====================================================================
// CREACION / MUERTE DE LAS COPIAS (receta Rouge v10.2 / Shadow v6.0 /
// Cream v7.0)
// =====================================================================
int Blaze_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
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
    g_fBlazeBodyYaw[client]  = ang[1];
    g_fBlazeYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fBlazeBodyYaw[client], loc);

    if (!tpMode)
    {
        // parentado (modo Tails default: el motor mueve la posicion,
        // cero delay de red, anims suaves; aqui solo se escriben angulos)
        SetVariantString("!activator");
        AcceptEntityInput(av, "SetParent", client);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", loc);
    }

    for (int k = 0; k < 3; k++)
    {
        g_fBlazeSmLoc[client][k]  = loc[k];
        g_fBlazeSmLocL[client][k] = loc[k];
    }
    g_bBlazeSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// v72-OM (adopcion): un prop con NUESTRO nombre que esta FSM no rastrea
// es un huerfano por definicion — muere en el instante del montaje.
bool Blaze_IsMyAvatarRef(int ref)
{
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iBlazeAvatar[i] == ref) return true;
        if (g_iBlazeAvatarL[i] == ref) return true;
    }
    return false;
}

void Blaze_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "blaze_avatar_om", "blaze_avatar_om_l" };
    static const char sClasses[][] = { "prop_dynamic_override", "prop_dynamic" };
    int ghosts[8];
    int ng = 0;
    char nameBuf[64];

    // primero se recolecta, luego se mata — el FindEntityByClassname
    // tras un Kill a mitad de loop es tierra de nadie en L4D2
    for (int c = 0; c < sizeof(sClasses); c++)
    {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, sClasses[c])) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            GetEntPropString(ent, Prop_Data, "m_iName", nameBuf, sizeof(nameBuf));
            if (nameBuf[0] == '\0') continue;

            for (int n = 0; n < sizeof(sGhostNames); n++)
            {
                if (!StrEqual(nameBuf, sGhostNames[n], false)) continue;
                if (Blaze_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
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
        PrintToServer("[Blaze %s] Adopcion del montaje: %d huerfano(s) del avatar eliminado(s).", BLAZE_INC_VERSION, ng);
}

// Monta el avatar completo (R + L + cuerpo oculto). pulsePause SOLO para
// montajes de ciclo de vida (spawn/seleccion/reparacion tardia de la FSM).
void Blaze_CreateAvatar(int client, bool pulsePause = true)
{
    if (!g_bBlazeModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;

    // v72-OM (reemplazo limpio): si este cliente ya tenia un R o L vivo
    // (montaje doble por orden raro de eventos), muere AQUI enterito.
    {
        int oldR = EntRefToEntIndex(g_iBlazeAvatar[client]);
        if (g_iBlazeAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Blaze_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iBlazeAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iBlazeAvatarL[client]);
        if (g_iBlazeAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Blaze_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iBlazeAvatarL[client] = 0;
    }

    // v72-OM: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje.
    Blaze_KillGhostAvatarProps();

    int av = Blaze_CreateAvatarProp(client, BLAZE_OM_MODEL, BLAZE_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    // resolver las secuencias contra el .mdl REAL (probe Amy v92, UNA
    // vez por mapa — el primer avatar nace resolviendo para todos)
    Blaze_ResolveSeqs(av);

    char seqIdle[24];
    Blaze_SeqFor(BLAZE_ST_IDLE, seqIdle);
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");
    g_iBlazeAnimState[client] = 0;

    SDKHook(av, SDKHook_SetTransmit, Blaze_TransmitAvatarR);

    g_iBlazeAvatarL[client] = 0;
    Blaze_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iBlazeBodyRender[client] = view_as<int>(curMode);
    else if (g_iBlazeBodyRender[client] == -1)
        g_iBlazeBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    g_iBlazeAvatar[client] = EntIndexToEntRef(av);

    // per-tick: angulos locales (contra-rotacion del parent)
    SDKHook(client, SDKHook_PostThink, Blaze_AvatarFollow);

    // PULSO DE PAUSA en cada montaje de ciclo de vida (la misma infra
    // sv_pausable del suite; convar tails_pausefix manda para TODOS los
    // avatares — es UN solo sistema, 10o avatar del suite)
    if (pulsePause)
        Tails_PauseFix_Trigger(client);

    // aviso UNA vez por mapa (solo humanos — los bots con el modelo
    // blaze del mapa de slots del CST tambien tienen avatar, sin spam)
    if (!g_bBlazeWelcomeSaid[client] && !IsFakeClient(client))
    {
        g_bBlazeWelcomeSaid[client] = true;
        PrintToChat(client, "\x04[Blaze]\x01 Avatar espejo activo (\x05blaze.mdl\x01) — 10o avatar del suite.");
    }
}

void Blaze_CreateAvatarL(int client)
{
    if (!g_bBlazeModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iBlazeAvatar[client] == 0) return;

    int av = Blaze_CreateAvatarProp(client, BLAZE_OM_MODEL, BLAZE_AVATAR_NAME_L);
    if (av == 0) return;

    char seqIdle[24];
    Blaze_SeqFor(BLAZE_ST_IDLE, seqIdle);
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Blaze_TransmitAvatarL);

    g_iBlazeAvatarL[client] = EntIndexToEntRef(av);
}

void Blaze_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iBlazeAvatarL[client]);
    if (g_iBlazeAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Blaze_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iBlazeAvatarL[client] = 0;
}

// Mata las copias R+L y devuelve el cuerpo. SIN desenganchar el follow
// (lo hace Blaze_KillAvatar).
void Blaze_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    Blaze_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iBlazeAvatar[client]);
    if (g_iBlazeAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Blaze_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iBlazeAvatar[client] = 0;
    g_iBlazeAnimState[client] = -1;

    // devolver el cuerpo (spectate/revive/cambio de personaje)
    if (IsClientInGame(client) && g_iBlazeBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iBlazeBodyRender[client]));
        g_iBlazeBodyRender[client] = -1;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Blaze_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Blaze_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Blaze_AvatarFollow);
}

// Transmit filters (patron Rouge/Sonic/Metal/Shadow/Cream): la R no la
// ve su duena (tiene su L), la L la ve SOLO su duena.
public Action Blaze_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iBlazeAvatar[i] != 0 && EntRefToEntIndex(g_iBlazeAvatar[i]) == entity)
        {
            if (client == i && g_iBlazeAvatarL[i] != 0
                && EntRefToEntIndex(g_iBlazeAvatarL[i]) > 0)
                return Plugin_Handled;   // la duena tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

public Action Blaze_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iBlazeAvatarL[i] != 0 && EntRefToEntIndex(g_iBlazeAvatarL[i]) == entity)
        {
            if (client == i) return Plugin_Continue;   // la duena si
            return Plugin_Handled;                     // nadie mas
        }
    }
    return Plugin_Continue;
}

// FOLLOW PER-TICK (receta Rouge: yaw suave con deadband 3 grados,
// contra-rotacion amortiguada, reloj vivo, copia L contra los eye
// angles de la duena; la R por TP en modo tp).
public void Blaze_AvatarFollow(int client)
{
    if (g_iBlazeAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Blaze_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    // ---- yaw objetivo: direccion REAL del movimiento ----
    float yawObj = g_fBlazeBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fBlazeBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    // ---- giro suave hacia el objetivo (~900 grados/s) ----
    float now = GetEngineTime();
    float dt  = now - g_fBlazeYawLastT[client];
    g_fBlazeYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fBlazeBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fBlazeBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bBlazeSmSnap[client];
    GetClientAbsAngles(client, par);
    float yawPuppet = g_fBlazeBodyYaw[client];

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iBlazeAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        if (Tails_AvatarTPOn())
        {
            // R POR TP: TeleportEntity por tick en pose mundo + reloj
            // vivo, SIN EF_NOINTERP -> los clientes de los demas la
            // INTERPOLAN = suave sin depender de la pausa
            float posTP[3], angTP[3];
            GetClientAbsOrigin(client, posTP);
            angTP[0] = 0.0;                      // pitch NUNCA
            angTP[1] = yawPuppet;
            angTP[2] = 0.0;                      // roll NUNCA
            TeleportEntity(av, posTP, angTP, NULL_VECTOR);
            Tails_MarkInterp(av);
        }
        else
        {
            Tails_AvatarLocalAngles(par[0], par[1], yawPuppet, loc);
            loc[1] = Tails_UnwrapYaw(g_fBlazeSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fBlazeSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fBlazeSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }

    // ---- copia L: contra-rotada contra los EYE de la duena ----
    if (g_iBlazeAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iBlazeAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3], locL[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], yawPuppet, locL);
            locL[1] = Tails_UnwrapYaw(g_fBlazeSmLocL[client][1], locL[1]);
            Tails_ExpDamp(locL, g_fBlazeSmLocL[client], 0.05, dt, snap);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fBlazeSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
    g_bBlazeSmSnap[client] = false;
}

// FSM de 10 Hz: montaje / auto-reparacion / muerte del avatar (patron
// T_RougeAvatarThink / T_ShadowAvatarThink / T_CreamAvatarThink)
public Action T_BlazeAvatarThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Blaze_KillAvatar(i); continue; }

        bool esBlazeViva = (Blaze_PlayerIs(i)
                         && IsPlayerAlive(i) && GetClientTeam(i) == 2);

        // incap = fuera (defensa anti terceros — la FSM re-monta sola
        // al levantarla: la misma regla de Rouge/Shadow/Cream)
        if (esBlazeViva && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            esBlazeViva = false;

        // v2.0-OM: EL TICK DEL KIT — corre con o sin avatar montado (el
        // gameplay es del PERSONAJE, el avatar es visual). Downed o muerto
        // = cancel suave (el Lua bloquea las pulsaciones downed).
        if (IsPlayerAlive(i) && GetClientTeam(i) == 2)
        {
            if (GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0 || OM_IsStunned(i))
            {
                // downed o aturdido: cancel suave (no pelear contra el stun)
                if (g_iBlazeChargeKind[i] != 0 || g_bBlazeKickFly[i] || g_bBlazeDrainDash[i] || g_bBlazeExpell[i])
                    Blaze_CancelActive(i);
            }
            else
                Blaze_GameplayThink(i, now);
        }

        // ---- montaje ----
        if (g_iBlazeAvatar[i] == 0)
        {
            if (esBlazeViva && g_cvBlazeAvatar != null && g_cvBlazeAvatar.BoolValue
                && g_bBlazeModelOK)
            {
                Blaze_CreateAvatar(i);
            }
            continue;
        }

        // quitar avatar si dejo de ser una Blaze survivor viva de pie
        if (!esBlazeViva)
        {
            Blaze_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iBlazeAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iBlazeAvatar[i] = 0;
            g_iBlazeAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (el motor lo resetea al
        // cambiar de capitulo/rescue: fix Tails v5.4)
        if (g_iBlazeBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparacion de la copia L (montaje tardio: pulso tambien)
        if (g_iBlazeAvatarL[i] == 0 && g_iBlazeAvatar[i] != 0)
        {
            Blaze_CreateAvatarL(i);
            if (g_iBlazeAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // ---- FSM de animacion ----
        av = EntRefToEntIndex(g_iBlazeAvatar[i]);
        if (g_iBlazeAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Blaze_AvatarUpdate(i, av, now);
    }
    return Plugin_Continue;
}

// =====================================================================
// FSM DE ANIMACION — prioridades: incap (DownedIdle/DownedWalk) ->
// aire (jump subiendo / fall cayendo) -> suelo (idle/walk/run con
// variantes lowhealth de HP<=40).
// =====================================================================
void Blaze_AvatarUpdate(int client, int av, float now)
{
    int state;
    float rate = 1.0;

    // v2.0-OM: anim de juego forzada (Kick / SolDash / Roll / throw /
    // SolFlame) — manda sobre la FSM normal mientras dure el estado
    if (g_iBlazeForceAnim[client] >= 0)
    {
        state = g_iBlazeForceAnim[client];
    }
    else if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
    {
        // DownedIdle/DownedWalk
        state = (Blaze_Speed2D(client) > 40.0) ? BLAZE_ST_DOWNED_WALK : BLAZE_ST_DOWNED_IDLE;
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // AIRE: sube = jump; cae = fall — con la ventana del jump
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[2] > 40.0)
        {
            state = BLAZE_ST_JUMP;
        }
        else
        {
            bool jumpLive = false;
            if (g_iBlazeAnimState[client] == BLAZE_ST_JUMP)
            {
                float jt = now - g_fBlazeJumpStart[client];
                if (jt < 0.5)      jumpLive = true;
                else if (jt < 1.5 && !Blaze_JumpAnimDone(av)) jumpLive = true;
            }
            state = jumpLive ? BLAZE_ST_JUMP : BLAZE_ST_FALL;
        }
    }
    else if (g_iBlazeAnimState[client] == BLAZE_ST_JUMP && !Blaze_JumpAnimDone(av)
             && now - g_fBlazeJumpStart[client] < 0.5)
    {
        // FL_ONGROUND parpadea al saltar rozando escalones
        state = BLAZE_ST_JUMP;
    }
    else
    {
        // SUELO: idle/walk/run (lowhealth <= 40)
        bool low = (GetClientHealth(client) <= BLAZE_LOWHP);
        float s = Blaze_Speed2D(client);
        if (s < 40.0)
            state = low ? BLAZE_ST_IDLE_LOW : BLAZE_ST_IDLE;
        else if (s < 150.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = low ? BLAZE_ST_WALK_LOW : BLAZE_ST_WALK;
            rate = 1.0;   // rate 1 constante del framework GMod
        }
        else
        {
            state = low ? BLAZE_ST_RUN_LOW : BLAZE_ST_RUN;
            rate = 1.32 * (s / 450.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6)  rate = 3.6;
        }
    }

    if (state != g_iBlazeAnimState[client])
    {
        // el t0 del jump para su ventana (receta Rouge/Sonic/Knuckles)
        if (state == BLAZE_ST_JUMP) g_fBlazeJumpStart[client] = now;

        char seqUse[24];
        Blaze_SeqFor(state, seqUse);

        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iBlazeAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iBlazeAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                // el variant es de UN SOLO USO — re-armarlo
                SetVariantString(seqUse);
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iBlazeAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iBlazeAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iBlazeAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

float Blaze_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// el one-shot del jump termino? (m_flCycle del prop — la misma sonda
// del Rouge_JumpAnimDone / Knux_JumpAnimDone / Shadow_JumpAnimDone)
bool Blaze_JumpAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return true;
}

// =====================================================================
// v2.0-OM: EL KIT GMOD DE BLAZE (register_noodles_blaze.lua +
// survivors2.lua L46-1569). El gameplay es del PERSONAJE: corre con
// Blaze_PlayerIs (modelo blaze puesto), con o sin avatar montado.
// Los NUMEROS son los del Lua; las convars traen sus defaults.
// =====================================================================

// ------------------ helpers basicos ------------------
void Blaze_Snd(int idx, int ent)
{
    if (idx < 0 || idx >= BLAZE_SND_COUNT || !g_bBlazeSndOK[idx]) return;
    if (ent > 0 && IsValidEntity(ent)) EmitSoundToAll(g_sBlazeSndUse[idx], ent, SNDCHAN_AUTO, 90);
}

void Blaze_SndPitch(int idx, int ent, int pitch)
{
    if (idx < 0 || idx >= BLAZE_SND_COUNT || !g_bBlazeSndOK[idx]) return;
    if (pitch < 40) pitch = 40; if (pitch > 250) pitch = 250;
    if (ent > 0 && IsValidEntity(ent))
        EmitSoundToAll(g_sBlazeSndUse[idx], ent, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, pitch);
}

// meter SolFlame con tope (el Lua: clamp a SolFlameBar_max)
// v2.1-OM: el cooldown EFECTIVO de Blaze = base * blaze_cd_scale
// (pedido del owner: -50% en TODO el kit para limpiar hordas)
float Blaze_Cd(float base)
{
    if (g_cvBlazeCdScale != null) return base * g_cvBlazeCdScale.FloatValue;
    return base * 0.5;
}

void Blaze_AddSol(int client, float amount)
{
    float mx = (g_cvBlazeMaxSol != null) ? g_cvBlazeMaxSol.FloatValue : 100.0;
    g_fBlazeSol[client] += amount;
    if (g_fBlazeSol[client] > mx) g_fBlazeSol[client] = mx;
    if (g_fBlazeSol[client] < 0.0) g_fBlazeSol[client] = 0.0;
}

bool Blaze_SolMode(int client)
{
    return g_fBlazeSol[client] >= 50.0;   // el umbral del Lua (SolFlameBar >= 50)
}

// tinte ROJO del avatar (el glow 'sonic_glow_duration' del Lua) — la
// carga del kick/dash y el solflame lo encienden; 0 = restaurar
void Blaze_AvatarTint(int client, bool on)
{
    int av  = EntRefToEntIndex(g_iBlazeAvatar[client]);
    int avL = EntRefToEntIndex(g_iBlazeAvatarL[client]);
    if (on) {
        if (av  > 0 && IsValidEntity(av))  SetEntityRenderColor(av, 255, 90, 90, 255);
        if (avL > 0 && IsValidEntity(avL)) SetEntityRenderColor(avL, 255, 90, 90, 255);
    } else {
        if (av  > 0 && IsValidEntity(av))  SetEntityRenderColor(av, 255, 255, 255, 255);
        if (avL > 0 && IsValidEntity(avL)) SetEntityRenderColor(avL, 255, 255, 255, 255);
    }
}

// primer enemigo valido en esfera (el FindInSphere 100 del Lua): SI
// players (equipo 3) + comunes/witch/tank NPC vivos.
// v2.5-OM: se mide contra el CENTRO del cuerpo de la victima (+40z, no
// los pies) — el kick vuela con arco a +40 del suelo: midiendo contra
// los PIES la distancia 3D pasaba de 100 a mitad del vuelo y solo pegaba
// al caer al final ("la hitbox se activa muy tarde, nada mas al finalizar")
int Blaze_ScanEnemy(int client, const float center[3], float radius, float dirOut[3])
{
    // 1) especiales / tank jugados (players equipo 3)
    for (int t = 1; t <= MaxClients; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != TEAM_INFECTED) continue;
        float p[3];
        GetClientAbsOrigin(t, p);
        p[2] += 40.0;                     // centro del cuerpo, no los pies
        if (GetVectorDistance(center, p) > radius) continue;
        SubtractVectors(p, center, dirOut); NormalizeVector(dirOut, dirOut);
        return t;
    }
    // 2) NPCs del director: comunes / witch / tank
    static const char sNpc[][] = { "infected", "witch", "tank" };
    int ent = -1;
    for (int n = 0; n < sizeof(sNpc); n++)
    {
        ent = -1;
        while ((ent = FindEntityByClassname(ent, sNpc[n])) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            if (!HasEntProp(ent, Prop_Data, "m_iHealth")) continue;
            if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
            float p[3];
            GetEntPropVector(ent, Prop_Data, "m_vecOrigin", p);
            p[2] += 40.0;                 // centro del cuerpo, no los pies
            if (GetVectorDistance(center, p) > radius) continue;
            SubtractVectors(p, center, dirOut); NormalizeVector(dirOut, dirOut);
            return ent;
        }
    }
    return 0;
}

// v2.5-OM: LA HITBOX ES EL RECORRIDO — barre el segmento recorrido desde
// el tick anterior (pedido del owner: "deberia estar activo hasta que
// ella termine dicho movimiento"). Mata los huecos entre ticks: a 1022
// u/s el kick salta 102u por tick de 10Hz y el javelin 100u por tick de
// 30Hz — la esfera sola se colaba entre commons.
int Blaze_ScanEnemyPath(int client, const float from[3], const float to[3], float radius, float dirOut[3])
{
    float seg[3];
    SubtractVectors(to, from, seg);
    float len = NormalizeVector(seg, seg);
    float step = radius * 0.66;
    int steps = (len <= step) ? 1 : RoundToCeil(len / step);
    if (steps > 10) steps = 10;               // tope de seguridad
    float c[3];
    for (int s = 0; s < steps; s++)
    {
        float t = (steps > 1) ? float(s) / float(steps - 1) : 1.0;
        c[0] = from[0] + seg[0] * len * t;
        c[1] = from[1] + seg[1] * len * t;
        c[2] = from[2] + seg[2] * len * t;
        int victim = Blaze_ScanEnemy(client, c, radius, dirOut);
        if (victim > 0) return victim;
    }
    return 0;
}

// =====================================================================
// v2.2-OM: LA CAPA DE EFECTOS DEL FUEGO — todos stock del motor
// (particles/inferno.pcf), con las recetas probadas del suite:
// info_particle_system + auto-kill por OnUser1 (cero handles vivos,
// patron Knux_VFX_Particle / Rouge_BlackWaveParticle).
// =====================================================================

// registrar particula en la tabla del motor (patron Knuckles v63 /
// Rouge v9). Si ya esta (el sistema de fuego del juego la trae),
// esto es un no-op inocuo.
void Blaze_ParticlePrecache(const char[] name)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE) table = FindStringTable("ParticleEffectNames");
    if (table == INVALID_STRING_TABLE) return;
    if (FindStringIndex(table, name) == INVALID_STRING_INDEX)
    {
        bool save = LockStringTables(false);
        AddToStringTable(table, name);
        LockStringTables(save);
    }
}

// particula one-shot con auto-kill por OnUser1. CERO handles.
void Blaze_ParticleLife(const float pos[3], const float ang[3],
                        const char[] name, float life)
{
    int particle = CreateEntityByName("info_particle_system");
    if (particle <= 0 || !IsValidEntity(particle)) return;

    DispatchKeyValue(particle, "effect_name", name);
    DispatchSpawn(particle);
    ActivateEntity(particle);
    TeleportEntity(particle, pos, ang, NULL_VECTOR);
    AcceptEntityInput(particle, "Start");

    char io[96];
    Format(io, sizeof(io), "OnUser1 !self:kill::%.1f:1", life);
    SetVariantString(io);
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");
}

// v2.3-OM: TRAMO del cono del Sol Flame — particula + PUNTO DE CONTROL 1
// (info_particle_target en el FINAL del tramo — la receta de la lengua
// del pet_christmas v2.6 de ESTE server: cpoint1 ANTES del DispatchSpawn).
// Las env_fire_* (default) solo arden en su punto (CP0) e ignoran el CP1;
// las inferno_wall_* dibujan el muro ENTRE CP0 y CP1 — cualquier nombre
// que el owner ponga en blaze_fx_flame_name queda bien cableado. Doble
// auto-kill OnUser1 (particula Y punta), cero handles vivos.
void Blaze_FxFlameSeg(const float pos[3], const float end[3],
                      const float ang[3], const char[] name, float life)
{
    // guardia de edicts (patron pet_christmas): a pleno cono hay ~40
    // entidades de fx vivas — jamas acercarse al limite del mapa
    if (GetEntityCount() > 1980) return;

    int target = CreateEntityByName("info_particle_target");
    if (target <= 0 || !IsValidEntity(target)) return;
    char tname[32];
    Format(tname, sizeof(tname), "blzflametip%d", target);
    DispatchKeyValue(target, "targetname", tname);
    DispatchKeyValue(target, "spawnflags", "0");
    DispatchSpawn(target);
    TeleportEntity(target, end, NULL_VECTOR, NULL_VECTOR);
    char ioT[96];
    Format(ioT, sizeof(ioT), "OnUser1 !self:kill::%.1f:1", life);
    SetVariantString(ioT);
    AcceptEntityInput(target, "AddOutput");
    AcceptEntityInput(target, "FireUser1");

    int particle = CreateEntityByName("info_particle_system");
    if (particle <= 0 || !IsValidEntity(particle))
    {
        AcceptEntityInput(target, "Kill");
        return;
    }
    DispatchKeyValue(particle, "effect_name", name);
    DispatchKeyValue(particle, "cpoint1", tname);
    DispatchSpawn(particle);
    ActivateEntity(particle);
    TeleportEntity(particle, pos, ang, NULL_VECTOR);
    AcceptEntityInput(particle, "Start");

    char io[96];
    Format(io, sizeof(io), "OnUser1 !self:kill::%.1f:1", life);
    SetVariantString(io);
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");
}

// posicion de una victima player o NPC (para las explosiones)
void Blaze_FX_VictimPos(int victim, float pos[3])
{
    if (victim <= MaxClients) GetClientAbsOrigin(victim, pos);
    else                      GetEntPropVector(victim, Prop_Data, "m_vecOrigin", pos);
    pos[2] += 30.0;   // centro del cuerpo, no los pies
}

// SOL DASH: el FUEGO QUE RODEA A BLAZE durante el vuelo. v2.4: la
// inferno_wall_primary del pedido es un sistema de MURO — dibuja el
// fuego ENTRE su origen y su cpoint1 (un info_particle_target);
// parentada SOLA al cuerpo no tiene segundo punto y NO DIBUJABA NADA
// (por eso el dash volaba sin grafico con la habilidad funcionando).
// Ahora son DOS capas de los fuegos ambientales de los mapas
// (env_fire_*: solo CP0, SIEMPRE visibles, en LOOP): env_fire_medium
// al TORSO (la llama que la envuelve) + env_fire_small a los PIES.
// Removidas SIEMPRE al terminar (impacto / fin de ventana / drain
// agotado / cancel / muerte / mapa) + tope OnUser1 de seguridad.
void Blaze_FX_DashStart(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;

    // si quedaba una vieja (dash cortado sin pasar por el Stop), fuera YA
    Blaze_FX_DashStop(client);

    float cap = 25.0;
    if (g_cvBlazeFXDashLife != null) cap = g_cvBlazeFXDashLife.FloatValue;

    char name[64], name2[64];
    if (g_cvBlazeFXDashName != null)  g_cvBlazeFXDashName.GetString(name, sizeof(name));
    else                              strcopy(name, sizeof(name), BLZ_FX_FIRE_MEDIUM);
    if (g_cvBlazeFXDashName2 != null) g_cvBlazeFXDashName2.GetString(name2, sizeof(name2));
    else                              strcopy(name2, sizeof(name2), BLZ_FX_FIRE_SMALL);

    float pos[3], ang[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);

    // CAPA 1 — TORSO: la llama que RODEA a Blaze
    if (name[0] != '\0')
    {
        float pT[3];
        pT = pos;
        pT[2] += BLZ_FX_DASH_Z_TORSO;
        g_iBlazeDashFxRef[client] = Blaze_FxDashAttach(client, pT, ang, name, cap);
    }

    // CAPA 2 — PIES: la base del fuego hasta el suelo
    if (name2[0] != '\0')
    {
        float pF[3];
        pF = pos;
        pF[2] += BLZ_FX_DASH_Z;
        g_iBlazeDashFxRef2[client] = Blaze_FxDashAttach(client, pF, ang, name2, cap);
    }
}

// v2.4: UNA capa del fuego del cuerpo del dash — info_particle_system
// PARENTADA al player (mantiene su offset relativo al parentar: la
// receta v2.2 que ya segui­a el cuerpo) + auto-kill OnUser1 de
// seguridad. Devuelve EntRef (0 = no se pudo).
int Blaze_FxDashAttach(int client, const float pos[3], const float ang[3],
                       const char[] name, float cap)
{
    // guardia de edicts (patron Blaze_FxFlameSeg / pet_christmas)
    if (GetEntityCount() > 1980) return 0;

    int particle = CreateEntityByName("info_particle_system");
    if (particle <= 0 || !IsValidEntity(particle)) return 0;

    DispatchKeyValue(particle, "effect_name", name);
    DispatchSpawn(particle);
    ActivateEntity(particle);
    TeleportEntity(particle, pos, ang, NULL_VECTOR);

    // parentar al player: el fuego sigue el cuerpo de Blaze en el vuelo
    SetVariantString("!activator");
    AcceptEntityInput(particle, "SetParent", client);

    AcceptEntityInput(particle, "Start");

    char io[96];
    Format(io, sizeof(io), "OnUser1 !self:kill::%.1f:1", cap);
    SetVariantString(io);
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");

    return EntIndexToEntRef(particle);
}

// "no olvides remover el efecto de inferno a blaze cuando termine la
// habilidad" — FIN SIEMPRE (impacto / ventana / drain / cancel / muerte)
void Blaze_FX_DashStop(int client)
{
    if (client < 1 || client > MaxClients) return;

    if (g_iBlazeDashFxRef[client] != 0)
    {
        int particle = EntRefToEntIndex(g_iBlazeDashFxRef[client]);
        if (particle > MaxClients && IsValidEntity(particle))
        {
            AcceptEntityInput(particle, "Stop");
            AcceptEntityInput(particle, "Kill");
        }
        g_iBlazeDashFxRef[client] = 0;
    }

    if (g_iBlazeDashFxRef2[client] != 0)
    {
        int particle2 = EntRefToEntIndex(g_iBlazeDashFxRef2[client]);
        if (particle2 > MaxClients && IsValidEntity(particle2))
        {
            AcceptEntityInput(particle2, "Stop");
            AcceptEntityInput(particle2, "Kill");
        }
        g_iBlazeDashFxRef2[client] = 0;
    }
}

// impacto del dash: "usara al azar una de estas: molotov_explosion_
// burst, _burst2, _burst3, _cheap" — al azar de las 4 sobre el enemigo
void Blaze_FX_ImpactBurst(const float pos[3])
{
    float ang[3] = { 0.0, 0.0, 0.0 };

    switch (GetRandomInt(1, 4))
    {
        case 1: Blaze_ParticleLife(pos, ang, BLZ_FX_MOLLY_BURST,  2.5);
        case 2: Blaze_ParticleLife(pos, ang, BLZ_FX_MOLLY_BURST2, 2.5);
        case 3: Blaze_ParticleLife(pos, ang, BLZ_FX_MOLLY_BURST3, 2.5);
        case 4: Blaze_ParticleLife(pos, ang, BLZ_FX_MOLLY_CHEAP,  2.5);
    }
}

// v2.2-OM: EL AOE A COMMONS — "todas las habilidades tendra dano aoe
// a commons incluso si impacta contra un SI la explosion tendra un
// efecto en area... pero el efecto de explosion solo sera Para el SI
// y no para los commons (si no habria lag de muerte)". Dano en radio
// + empujon radial (patron Rouge v8.0); CERO particulas por common —
// la explosion visual vive UNA vez, en la victima golpeada.
// v2.13-OM: skipEnt = la victima del GOLPE DIRECTO de la misma llamada
// (su sol ya lo conto el HitImpact/enganche — jamas doble carga)
void Blaze_FX_AoeCommons(int attacker, const float pos[3], float radiusMul = 1.0, int skipEnt = 0)
{
    float radius = (g_cvBlazeAoeRadius != null) ? g_cvBlazeAoeRadius.FloatValue : 250.0;
    float dmg    = (g_cvBlazeAoeDmg    != null) ? g_cvBlazeAoeDmg.FloatValue    : 80.0;
    if (radius <= 0.0 || dmg <= 0.0) return;

    // v2.11-OM: EL AREA DEL DASH MAS GRANDE — el impacto del dash aereo
    // escala su radio por blaze_dash_aoescale (1.5 = 250u -> 375u); el
    // kick y el javelin llaman sin escala (1.0 = su radio de siempre)
    if (radiusMul > 0.0 && radiusMul != 1.0) radius *= radiusMul;

    // v2.10-OM CRASHPROOF: SNAPSHOT de las victimas ANTES del daño. El
    // loop viejo dañaba DENTRO del while(FindEntityByClassname): en
    // L4D2 un comun muerto libera su edict EN el mismo frame y la
    // siguiente iteracion arrancaba la busqueda desde un indice ya
    // liberado — el camino del crash SILENCIOSO del motor (el reporte
    // de No Mercy al reventar la horda bajando por los apartamentos:
    // el juego se cierra sin escribir nada). Ahora: primero se
    // recogen TODOS los indices vivos en radio (sin daño en medio) y
    // el daño va DESPUES, re-validando cada uno antes de tocarlo.
    int list[128];
    int count = 0;
    static const char sNpc[][] = { "infected", "witch", "tank" };
    for (int n = 0; n < sizeof(sNpc); n++)
    {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, sNpc[n])) != -1)
        {
            if (count >= sizeof(list)) break;
            if (!IsValidEntity(ent)) continue;
            if (!HasEntProp(ent, Prop_Data, "m_iHealth")) continue;
            if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;

            float p[3];
            GetEntPropVector(ent, Prop_Data, "m_vecOrigin", p);
            if (GetVectorDistance(pos, p) > radius) continue;
            list[count++] = ent;
        }
    }

    for (int k = 0; k < count; k++)
    {
        int ent = list[k];
        // murio con otro golpe de este mismo paquete (o con el daño
        // principal del hit): FUERA — nada de tocar edicts liberados
        if (!Blaze_VictimAlive(ent)) continue;

        // v2.13-OM: +sol si este AOE MATA un COMUN ("infected" — la
        // witch y el tank no cargan por la expansiva, su sol es del
        // directo). skipEnt = el comun del golpe directo, ya premiado.
        bool award = false;
        {
            char cn[12];
            GetEntityClassname(ent, cn, sizeof(cn));
            award = StrEqual(cn, "infected") && ent != skipEnt;
        }

        float p[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", p);

        // empujon desde el punto de impacto (el cuerpo sale
        // despedido del fuego — patron Rouge v8.0)
        float push[3];
        MakeVectorFromPoints(pos, p, push);
        push[2] = 0.0;
        if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; }
        NormalizeVector(push, push);
        ScaleVector(push, 500.0);
        push[2] = 180.0;
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);

        // dano del suite (amplificador v2.2 incluido)
        // v2.11-OM: por la TABLA NUEVA — x2 si es witch (+x1.5 si viene
        // debil del dash aereo)
        Blaze_AbilityDamage(ent, attacker, dmg, DMG_OM_CLUB, true);

        // v2.13-OM: EL SOL DE LA EXPANSIVA — el comun que el AOE mata
        // carga su blaze_sol_charge_common (+2), igual que el del golpe
        // directo. Blaze_VictimAlive re-valida tras el daño (regla
        // v2.10: jamas leer un edict recien liberado).
        if (award && !Blaze_VictimAlive(ent))
        {
            float gain = (g_cvBlazeSolChargeCommon != null) ? g_cvBlazeSolChargeCommon.FloatValue : 2.0;
            if (gain > 0.0 && attacker > 0 && attacker <= MaxClients) Blaze_AddSol(attacker, gain);
        }
    }
}

// v2.10-OM CRASHPROOF: ¿la victima (player o NPC) sigue viva y tocable?
// El daño de la propia habilidad (OM_AbilityDamage) puede MATARLA en el
// mismo frame — en L4D2 un comun muerto libera su edict AL INSTANTE y
// toda operacion posterior (TeleportEntity / IgniteEntity /
// GetEntPropVector) sobre ese indice es una entidad muerta: error
// nativo en cadena y, en el peor caso, acceso a memoria ya liberada.
// TODO lo que toca a una victima DESPUES de un daño pasa por aqui.
bool Blaze_VictimAlive(int victim)
{
    if (victim <= 0) return false;
    if (victim <= MaxClients)
        return IsClientInGame(victim) && IsPlayerAlive(victim);
    if (!IsValidEntity(victim)) return false;
    if (!HasEntProp(victim, Prop_Data, "m_iHealth")) return false;
    return GetEntProp(victim, Prop_Data, "m_iHealth") > 0;
}

// =====================================================================
// v2.11-OM: LA WITCH (x2 + STUN) Y LA DEBILIDAD DEL DASH (x1.5)
// =====================================================================
//  EL STUN DE LA WITCH: la witch NO es un CTerrorPlayer como el tank o
//  los especiales — es un NPC con IA NextBot propia, sin estado
//  "knocked down" ni "stagger" (inmune al sistema de tropiezos del
//  juego; ni el lanzagranadas la tambalea — ver Witch_Flight.inc). El
//  STUN "correspondiente" del pedido se implementa con la receta
//  probada del suite para congelarla SIN romperla: FL_FROZEN apaga el
//  gate del propio motor (DoThink solo llama Update() si el flag NO
//  esta) = la witch queda ESTATUA pero viva, y al retirar el flag su
//  IA se reactiva al instante, sin estado residual. Se RE-AFIRMA por
//  tick (si otro sistema le limpia el flag) y se JAMAS se retira el
//  hielo de un vuelo activo del Witch_Flight (guard WitchFlight_IsFlying
//  al expirar — el vuelo tiene su propia restauracion).
//
//  LA DEBILIDAD: la victima del DASH AEREO queda DEBIL 6s — mientras
//  dure, TODAS las otras habilidades de Blaze le pegan x1.5 (el dash
//  que la origina NO se amplifica a si mismo). Vale para players,
//  comunes, tank y por supuesto la witch (x2 * x1.5 = x3 en tablas).
//
//  Slots por EntRef (nada de indices pelados: un edict reciclado nunca
//  hereda el debuff). El timer compartido 0.25s se apaga solo cuando
//  no queda nada activo — cero coste con Blaze quieta.
// =====================================================================
#define BLAZE_DEBUFF_SLOTS 12

static int    g_iBlzDbRef[BLAZE_DEBUFF_SLOTS];        // EntRef de la victima (0 = slot libre)
static float  g_fBlzDbStunUntil[BLAZE_DEBUFF_SLOTS];  // fin del congelado de witch (IA off)
static float  g_fBlzDbWeakUntil[BLAZE_DEBUFF_SLOTS];  // fin de la DEBILIDAD del dash
static float  g_fBlzDbFlame[BLAZE_DEBUFF_SLOTS];      // v2.12: stack de DEBILIDAD del Sol Flame (en %: 0..blaze_flameweak_max*100)
static float  g_fBlzDbFlameNext[BLAZE_DEBUFF_SLOTS];  // v2.12: proxima re-ignicion del cono (cadencia 0.5s por cuerpo)
static Handle g_hBlzDbTick = null;                    // timer compartido (0 = apagado)

// v2.12-OM: EL KILL-SWITCH DEL FUEGO (v2.10-witch) — TODO el IgniteEntity
// de Blaze pasa por aqui. blaze_burn_enable 0 = CERO fuego desde Blaze
// (palanca de diagnostico). La witch JAMAS recibe fuego de Blaze (regla
// del suite v2.10: solo daño + estatua/vuelo — nunca IgniteEntity).
void Blaze_Burn(int victim, float dur)
{
    if (victim <= 0) return;
    if (Blaze_IsWitch(victim)) return;
    if (g_cvBlazeBurnEnable != null && !g_cvBlazeBurnEnable.BoolValue) return;
    IgniteEntity(victim, dur);
}

// v2.12-OM: LA QUEMA DEL CONO — cadencia 0.5s por cuerpo (v2.10-witch:
// de 10 IgniteEntity/s apilados a re-ignicion cada 0.5s; ignT 1.35s =
// ardiendo perpetuo, look identico). Cada cuerpo que recibe el fuego
// acumula +1% de DEBILIDAD ("sol flame producira debilidad acumulable
// a daño de llamas: 1% por cada 0.5 seg recibiendo el daño de blaze,
// hasta un max de 150%") — multiplica en Blaze_AbilityDamage, apilada
// con la x1.5 de la debilidad del dash. La witch JAMAS se quema.
void Blaze_ConeBurn(int victim, float ignT)
{
    if (victim <= 0) return;
    if (Blaze_IsWitch(victim)) return;
    if (!Blaze_VictimAlive(victim)) return;
    if (g_cvBlazeBurnEnable != null && !g_cvBlazeBurnEnable.BoolValue) return;

    int s = BlazeDb_Slot(victim, true);
    if (s < 0) { IgniteEntity(victim, ignT); return; }   // sin slot: la quema clasica

    float now = GetEngineTime();
    if (now >= g_fBlzDbFlameNext[s])
    {
        IgniteEntity(victim, ignT);
        g_fBlzDbFlameNext[s] = now + 0.5;        // cadencia 0.5s por cuerpo
        float cap = (g_cvBlazeFlameWeakMax != null) ? g_cvBlazeFlameWeakMax.FloatValue : 1.5;
        if (cap < 0.0) cap = 0.0;
        g_fBlzDbFlame[s] += 1.0;                // +1% por cada 0.5s de fuego
        if (g_fBlzDbFlame[s] > cap * 100.0) g_fBlzDbFlame[s] = cap * 100.0;
        BlazeDb_EnsureTick();
    }
}

// v2.12-OM: el multiplicador del stack del Sol Flame (1.0 = sin stack)
float Blaze_FlameMult(int victim)
{
    if (victim <= 0) return 1.0;
    int s = BlazeDb_Slot(victim, false);
    if (s < 0 || g_fBlzDbFlame[s] <= 0.0) return 1.0;
    return 1.0 + g_fBlzDbFlame[s] / 100.0;
}

// v2.12-OM: LA EXPLOSION DE LA LANZA AL TOPE DE VUELO — "al llegar a
// su distancia maxima explotara (max 1100 de daño, 25% menos de
// efectividad al tank)": snapshot del suite (recolectar vivos primero,
// daño despues — nunca dentro del FindEntityByClassname) + FX en el
// punto. El daño pasa por Blaze_AbilityDamage (x2 witch + x1.5 debil
// + el stack del Sol Flame).
void Blaze_JavelinExplode(int owner, int jav)
{
    float pos[3];
    if (jav > 0 && IsValidEntity(jav))
        GetEntPropVector(jav, Prop_Data, "m_vecOrigin", pos);
    else return;

    float rad = (g_cvBlazeJavExplRad != null) ? g_cvBlazeJavExplRad.FloatValue : 200.0;
    float base = (g_cvBlazeJavExplDmg != null) ? g_cvBlazeJavExplDmg.FloatValue : 1100.0;
    float tankM = (g_cvBlazeJavExplTank != null) ? g_cvBlazeJavExplTank.FloatValue : 0.75;

    // FX de la explosion
    float zang[3] = { 0.0, 0.0, 0.0 };
    Blaze_ParticleLife(pos, zang, BLZ_FX_MOLLY_EXPL, 2.5);

    // 1) SI players (incluye tank: x0.75)
    int slist[128]; int scount = 0;
    for (int t = 1; t <= MaxClients; t++)
    {
        if (scount >= sizeof(slist)) break;
        if (!IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != TEAM_INFECTED) continue;
        float p[3]; GetClientAbsOrigin(t, p);
        if (GetVectorDistance(pos, p, true) > rad * rad) continue;
        slist[scount++] = t;
    }
    for (int k = 0; k < scount; k++)
    {
        if (!Blaze_VictimAlive(slist[k])) continue;
        float d = base;
        if (GetEntProp(slist[k], Prop_Send, "m_zombieClass") == 8) d *= tankM;   // tank: -25%
        Blaze_AbilityDamage(slist[k], owner, d, DMG_BLAST, true);
    }

    // 2) comunes (snapshot) + 3) witches
    for (int pass = 0; pass < 2; pass++)
    {
        int zcount = 0;
        int zlist[96];
        int ent = -1;
        static const char sNpc[][] = { "infected", "witch" };
        while ((ent = FindEntityByClassname(ent, sNpc[pass])) != -1)
        {
            if (zcount >= sizeof(zlist)) break;
            if (!IsValidEntity(ent)) continue;
            if (!Blaze_VictimAlive(ent)) continue;
            float p[3];
            GetEntPropVector(ent, Prop_Data, "m_vecOrigin", p);
            if (GetVectorDistance(pos, p, true) > rad * rad) continue;
            zlist[zcount++] = ent;
        }
        for (int k = 0; k < zcount; k++)
            Blaze_AbilityDamage(zlist[k], owner, base, DMG_BLAST, true);
    }
}

// ¿la entidad es una witch del director? (por classname — la unica
// fuente de verdad; un edict reciclado de otra clase jamas matchea)
bool Blaze_IsWitch(int ent)
{
    if (ent <= MaxClients || ent >= 2048) return false;
    if (!IsValidEntity(ent)) return false;
    static char cls[16];
    GetEntityClassname(ent, cls, sizeof(cls));
    return StrEqual(cls, "witch", false);
}

// slot de la victima (busca el suyo; create=true reserva uno nuevo)
int BlazeDb_Slot(int victim, bool create)
{
    int free = -1;
    for (int s = 0; s < BLAZE_DEBUFF_SLOTS; s++)
    {
        if (g_iBlzDbRef[s] == 0) { if (free < 0) free = s; continue; }
        if (EntRefToEntIndex(g_iBlzDbRef[s]) == victim) return s;
    }
    if (!create || free < 0) return -1;
    g_iBlzDbRef[free]      = EntIndexToEntRef(victim);
    g_fBlzDbStunUntil[free] = 0.0;
    g_fBlzDbWeakUntil[free] = 0.0;
    g_fBlzDbFlame[free]     = 0.0;     // v2.12: stack del Sol Flame
    g_fBlzDbFlameNext[free] = 0.0;     // v2.12: cadencia de la quema del cono
    return free;
}

void BlazeDb_EnsureTick()
{
    if (g_hBlzDbTick == null)
        g_hBlzDbTick = CreateTimer(0.25, Blaze_DbTick, _, TIMER_REPEAT);
}

// LA WITCH EN ESTATUA — el stun correspondiente del pedido: la misma
// duracion que le tocaria a un player (kick/dash = su basestun 4s;
// lanza = 1s). Apila como el OM_Stun de los players (suma sobre lo
// restante). viva = la congelamos; muerta = ni la tocamos.
void Blaze_WitchStun(int witch, float duration)
{
    if (duration <= 0.0) return;
    if (!Blaze_IsWitch(witch)) return;
    if (!Blaze_VictimAlive(witch)) return;
    int s = BlazeDb_Slot(witch, true);
    if (s < 0) return;                       // sin slots: el daño sigue, el stun se pierde
    float now = GetEngineTime();
    g_fBlzDbStunUntil[s] = (g_fBlzDbStunUntil[s] > now ? g_fBlzDbStunUntil[s] : now) + duration;
    if ((GetEntityFlags(witch) & FL_FROZEN) == 0)
        SetEntityFlags(witch, GetEntityFlags(witch) | FL_FROZEN);
    BlazeDb_EnsureTick();
}

// LA DEBILIDAD DEL DASH AEREO — 6s de x1.5 para las OTRAS habilidades
void Blaze_ApplyWeak(int victim, float duration)
{
    if (duration <= 0.0 || victim <= 0) return;
    if (victim <= MaxClients)
    {
        if (!IsClientInGame(victim)) return;
    }
    else if (!IsValidEntity(victim)) return;
    int s = BlazeDb_Slot(victim, true);
    if (s < 0) return;
    float now = GetEngineTime();
    g_fBlzDbWeakUntil[s] = (g_fBlzDbWeakUntil[s] > now ? g_fBlzDbWeakUntil[s] : now) + duration;
    BlazeDb_EnsureTick();
}

// ¿esta DEBIL por el dash? (consulta de daño — barata, sin alocar)
bool Blaze_IsWeak(int victim)
{
    if (victim <= 0) return false;
    int s = BlazeDb_Slot(victim, false);
    return (s >= 0 && g_fBlzDbWeakUntil[s] > GetEngineTime());
}

// el tick compartido: re-afirma el hielo, retira lo expirado, libera
// slots muertos y SE APAGA SOLO cuando no queda nada activo
public Action Blaze_DbTick(Handle timer)
{
    float now = GetEngineTime();
    bool any = false;
    for (int s = 0; s < BLAZE_DEBUFF_SLOTS; s++)
    {
        if (g_iBlzDbRef[s] == 0) continue;
        int ent = EntRefToEntIndex(g_iBlzDbRef[s]);

        // entidad muerta / edict reciclado / fin de mapa: slot fuera
        // (Blaze_VictimAlive cubre players InGame+Alive y NPC con vida)
        if (ent <= 0 || !Blaze_VictimAlive(ent))
        {
            g_iBlzDbRef[s] = 0;
            g_fBlzDbStunUntil[s] = 0.0;
            g_fBlzDbWeakUntil[s] = 0.0;
            g_fBlzDbFlame[s] = 0.0;
            g_fBlzDbFlameNext[s] = 0.0;
            continue;
        }

        bool keep = false;

        // stun de la witch: re-afirmar mientras dure / retirar al expirar
        if (g_fBlzDbStunUntil[s] > 0.0)
        {
            if (Blaze_IsWitch(ent))
            {
                if (g_fBlzDbStunUntil[s] > now)
                {
                    // re-afirma (otro sistema pudo limpiarle el flag)
                    if ((GetEntityFlags(ent) & FL_FROZEN) == 0)
                        SetEntityFlags(ent, GetEntityFlags(ent) | FL_FROZEN);
                    keep = true;
                }
                else
                {
                    // NUNCA robar el hielo de un vuelo activo del
                    // Witch_Flight (ese slot tiene su propia restauracion)
                    if (!WitchFlight_IsFlying(ent) && (GetEntityFlags(ent) & FL_FROZEN) != 0)
                        SetEntityFlags(ent, GetEntityFlags(ent) & ~FL_FROZEN);
                    g_fBlzDbStunUntil[s] = 0.0;
                }
            }
            else g_fBlzDbStunUntil[s] = 0.0;   // dejo de ser witch: fuera
        }

        if (g_fBlzDbWeakUntil[s] > now) keep = true;

        // v2.12-OM: el stack del Sol Flame — decae -1% cada 0.5s SIN
        // fuego del cono (g_fBlzDbFlameNext pasa de moda) y mantiene el
        // slot vivo mientras quede algo de stack
        if (g_fBlzDbFlame[s] > 0.0)
        {
            if (now >= g_fBlzDbFlameNext[s] + 0.5)
            {
                g_fBlzDbFlame[s] -= 1.0;
                if (g_fBlzDbFlame[s] < 0.0) g_fBlzDbFlame[s] = 0.0;
                g_fBlzDbFlameNext[s] = now;      // re-ancla el proximo decay
            }
            if (g_fBlzDbFlame[s] > 0.0) keep = true;
        }

        if (keep) { any = true; continue; }

        // todo expirado: liberar el slot
        g_iBlzDbRef[s] = 0;
        g_fBlzDbStunUntil[s] = 0.0;
        g_fBlzDbWeakUntil[s] = 0.0;
        g_fBlzDbFlame[s] = 0.0;
        g_fBlzDbFlameNext[s] = 0.0;
    }

    if (!any)
    {
        g_hBlzDbTick = null;      // cero slots activos: el timer se apaga
        return Plugin_Stop;       // solo (revive al proximo uso)
    }
    return Plugin_Continue;
}

// v2.11-OM: EL DAÑO CON LA TABLA NUEVA — x2 a la WITCH (todo el kit)
// y x1.5 si la victima viene DEBIL del dash (solo las OTRAS habilidades:
// el dash origen no se auto-amplifica). El amplificador hibrido del
// suite (suite_dmg_scale + % de vida vs jefes) sigue aplicando COMO
// SIEMPRE dentro de OM_AbilityDamage — esta capa es SOLO la tabla
// nueva de Blaze.
void Blaze_AbilityDamage(int victim, int attacker, float base, int dmgType, bool countWeak = true)
{
    float mult = 1.0;
    if (g_cvBlazeWitchMult != null && Blaze_IsWitch(victim))
        mult *= g_cvBlazeWitchMult.FloatValue;          // la witch: x2 de TODO
    if (countWeak && g_cvBlazeWeakMult != null && Blaze_IsWeak(victim))
        mult *= g_cvBlazeWeakMult.FloatValue;           // debil del dash: x1.5
    mult *= Blaze_FlameMult(victim);                    // v2.12: el stack del Sol Flame (hasta +1.5)
    OM_AbilityDamage(victim, attacker, base * mult, dmgType);
}

// el IMPACTO compartido de kick y dash (el StunEffect del Lua — los
// numeros son identicos en ambas variantes; cambia el convar set)
void Blaze_HitImpact(int client, int victim, bool dash)
{
    bool sol = Blaze_SolMode(client);
    bool stack = dash
        ? (g_cvBlazeDashStack != null && g_cvBlazeDashStack.BoolValue)
        : (g_cvBlazeKickStack != null && g_cvBlazeKickStack.BoolValue);
    float stun  = dash ? g_cvBlazeDashStun.FloatValue  : g_cvBlazeKickStun.FloatValue;
    // v2.11-OM: LA TABLA DE DAÑO AUMENTADA — el daño del kick (200-550)
    // y del dash aereo (800-1650) ESCALA con el meter Sol (0..100):
    // vacia = minimo, llena = maximo (blaze_kick_dmg_min/max y
    // blaze_dash_dmg_min/max). Los comunes siguen muriendo de UN golpe:
    // el minimo 200 base ya reventa al comun de 50HP amplificado.
    float dmgMin = dash
        ? ((g_cvBlazeDashDmgMin != null) ? g_cvBlazeDashDmgMin.FloatValue : 800.0)
        : ((g_cvBlazeKickDmgMin != null) ? g_cvBlazeKickDmgMin.FloatValue : 200.0);
    float dmgMax = dash
        ? ((g_cvBlazeDashDmgMax != null) ? g_cvBlazeDashDmgMax.FloatValue : 1650.0)
        : ((g_cvBlazeKickDmgMax != null) ? g_cvBlazeKickDmgMax.FloatValue : 550.0);
    if (dmgMax < dmgMin) dmgMax = dmgMin;
    float solMax = (g_cvBlazeMaxSol != null) ? g_cvBlazeMaxSol.FloatValue : 100.0;
    float solv   = (solMax > 0.0) ? (g_fBlazeSol[client] / solMax) : 0.0;
    if (solv < 0.0) solv = 0.0;
    if (solv > 1.0) solv = 1.0;
    float dmg = dmgMin + (dmgMax - dmgMin) * solv;
    bool   burn = dash ? g_cvBlazeDashBurn.BoolValue   : g_cvBlazeKickBurn.BoolValue;
    // v2.12-OM: el NERF DEL SOL mato el +35-por-golpe: la carga ahora
    // es POR TIPO DE VICTIMA y se aplica abajo, DESPUES del daño (el
    // comun solo carga si el golpe lo MATO). Ver "sol al acierto".

    // v2.10-OM CRASHPROOF: la POSICION de la victima se captura ANTES
    // de cualquier daño. OM_AbilityDamage puede matar al comun EN este
    // mismo frame (amplificado x2: 50+ de daño vs 50 HP del comun) y
    // liberar su edict — la v2.9 operaba DESPUES del daño sobre la
    // entidad ya muerta (TeleportEntity / IgniteEntity /
    // GetEntPropVector "Invalid entity" en cadena tras cada patada a
    // la horda: el camino del crash silencioso reportado en No Mercy
    // al bajar por los apartamentos).
    float vpos[3];
    Blaze_FX_VictimPos(victim, vpos);

    // empujon al objetivo: en la direccion del vuelo de Blaze (el Lua:
    // GetVelocity normalizada — 600 / 1000 en modo Sol)
    float vdir[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vdir);
    float vlen = NormalizeVector(vdir, vdir);
    if (vlen < 50.0)
    {
        GetClientEyeAngles(client, vdir);
        GetAngleVectors(vdir, vdir, NULL_VECTOR, NULL_VECTOR);
        NormalizeVector(vdir, vdir);
    }
    float push = sol ? 1000.0 : 600.0;
    ScaleVector(vdir, push);

    if (victim > MaxClients)
    {
        // NPC: empujon directo (los comunes no tienen player-movement)
        if (Blaze_VictimAlive(victim))
            TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vdir);
    }

    // stun (si sobrevive) + el push del congelado — SOLO players reales
    // (v2.8: el rango va PRIMERO; IsPlayerAlive solo corre para players
    // in-game — fix del viejo "Invalid client index 467")
    if (victim <= MaxClients && Blaze_VictimAlive(victim))
    {
        if (OM_Stun(victim, stun, client, 0.0, DMG_OM_CLUB, stack))
        {
            float srcPos[3];
            GetClientAbsOrigin(client, srcPos);
            OM_Stun_Push(victim, vdir, srcPos);
        }
    }

    // v2.11-OM: LA WITCH Y SU STUN CORRESPONDIENTE — la misma duracion
    // que le tocaria a un player (kick/dash = su basestun): FL_FROZEN =
    // ESTATUA (su IA NextBot apagada sin romperse; se retira sola).
    // ANTES del daño como el stun de los players: si el golpe la mata,
    // el slot muerto se limpia solo en el tick siguiente.
    if (victim > MaxClients && Blaze_IsWitch(victim) && Blaze_VictimAlive(victim))
        Blaze_WitchStun(victim, stun);

    // QUEMA en modo Sol (el OM_burntarget del Lua): fuego REAL del motor
    // v2.12-OM: la witch JAMAS recibe IgniteEntity de Blaze (regla
    // v2.10-witch) + kill-switch blaze_burn_enable para todo el fuego
    if (sol && burn && Blaze_VictimAlive(victim)) Blaze_Burn(victim, 5.0);

    // v2.10-OM: EL DAÑO VA AL FINAL de todo lo que toca a la victima —
    // es la UNICA operacion que puede matarla y liberar su entidad en
    // este frame. El orden original (daño primero) era el que dejaba el
    // resto del impacto operando sobre un cadaver.
    // v2.11-OM: por la TABLA NUEVA — x2 a la witch; el x1.5 de la
    // DEBILIDAD entra SOLO en las otras habilidades (countWeak=!dash:
    // el dash que ORIGINA la debilidad no se amplifica a si mismo).
    Blaze_AbilityDamage(victim, client, dmg, DMG_OM_CLUB, !dash);

    // LA EXPLOSION VISUAL en el LUGAR del impacto — con la POSICION YA
    // CAPTURADA (vpos): cero acceso a la entidad, viva o muerta da
    // igual (kick = molotov_explosion; dash = una de las 4 bursts AL
    // AZAR) + el AOE a commons alrededor (visual SOLO en la victima
    // — los commons sin fx, anti lag de muerte)...
    {
        if (dash) Blaze_FX_ImpactBurst(vpos);
        else
        {
            float zang[3] = { 0.0, 0.0, 0.0 };
            Blaze_ParticleLife(vpos, zang, BLZ_FX_MOLLY_EXPL, 2.5);
        }
        // v2.11-OM: EL AREA DEL DASH MAS GRANDE — el AOE del impacto del
        // dash aereo escala por blaze_dash_aoescale (1.5 default = el
        // radio del pedido "mas grande"); kick y javelin sin cambio
        float aoeMul = 1.0;
        if (dash && g_cvBlazeDashAoeScale != null) aoeMul = g_cvBlazeDashAoeScale.FloatValue;
        Blaze_FX_AoeCommons(client, vpos, aoeMul, victim);   // v2.13: el directo ya cuenta su sol — sin doble carga
    }

    // v2.11-OM: LA DEBILIDAD DEL DASH AEREO — la victima queda DEBIL
    // blaze_weak_duration (6s): TODAS las otras habilidades de Blaze le
    // pegan x blaze_weak_dmgmult (1.5) mientras dure. DESPUES del daño
    // y del AOE: el propio dash no se beneficia de lo que origina.
    if (dash && victim > 0)
    {
        float wDur = (g_cvBlazeWeakDur != null) ? g_cvBlazeWeakDur.FloatValue : 6.0;
        if (wDur > 0.0) Blaze_ApplyWeak(victim, wDur);
    }

    // ...y si esto fue un dash, el fuego del cuerpo SE APAGA ("no
    // olvides remover el efecto de inferno a blaze cuando termine la
    // habilidad")
    if (dash) Blaze_FX_DashStop(client);

    // v2.12-OM: SOL AL ACIERTO — NERF DEL PODER DEL SOL: "ya golpear
    // comunes no recargara 35 de poder del sol". El ataque principal
    // (kick/dash) ahora carga POR TIPO DE VICTIMA y SOLO con el golpe
    // DIRECTO (el AOE del impacto NO carga: una patada a la horda no
    // llena el meter de un soplo). Comun: +2 SOLO si el golpe lo mato
    // ("2 por cada infectado comun muerto en el ataque"); especial:
    // +22; tank: +30; witch: +25.
    {
        float gain = 0.0;
        if (Blaze_IsWitch(victim))
            gain = (g_cvBlazeSolChargeWitch != null) ? g_cvBlazeSolChargeWitch.FloatValue : 25.0;
        else if (victim > MaxClients)
        {
            if (!Blaze_VictimAlive(victim))   // comun muerto por el golpe
                gain = (g_cvBlazeSolChargeCommon != null) ? g_cvBlazeSolChargeCommon.FloatValue : 2.0;
        }
        else if (Blaze_VictimAlive(victim))
        {
            int zc = GetEntProp(victim, Prop_Send, "m_zombieClass");
            if (zc == 8)   // tank
                gain = (g_cvBlazeSolChargeTank != null) ? g_cvBlazeSolChargeTank.FloatValue : 30.0;
            else
                gain = (g_cvBlazeSolChargeSpecial != null) ? g_cvBlazeSolChargeSpecial.FloatValue : 22.0;
        }
        if (gain > 0.0) Blaze_AddSol(client, gain);
    }

    // rebote propio atras-arriba (el Lua: -fwd*500 + up*300)
    float self[3], eye[3];
    GetClientEyeAngles(client, eye);
    GetAngleVectors(eye, self, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(self, -500.0);
    self[2] = 300.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, self);

    Blaze_Snd(BLAZE_IDX_KICK, client);   // blazekick.wav (impacto, como el Lua)
}

// ------------------ entry points (manager: Z y X) ------------------
void Blaze_Ability1(int client)   // Z: Roundhouse Kick (suelo) / Sol Dash (aire)
{
    if (!Blaze_PlayerIs(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2) return;
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    float now = GetEngineTime();

    // locks del Lua (keybinds L1204-1222): cd, ventanas activas, roll, throw
    if (now < g_fBlazeKickDashCd[client])
    {
        PrintCenterText(client, "[Blaze] %s en enfriamiento: %.1fs", (GetEntityFlags(client) & FL_ONGROUND) != 0 ? "Roundhouse Kick" : "Sol Dash", g_fBlazeKickDashCd[client] - now);
        return;
    }
    if (g_iBlazeChargeKind[client] != 0) return;
    if (g_bBlazeKickFly[client] || g_bBlazeExpell[client] || g_bBlazeDrainDash[client]) return;
    if (now < g_fBlazeSolDashWin[client] || now < g_fBlazeCanDashUntil[client]) return;
    if (now < g_fBlazeRollUntil[client] || now < g_fBlazeThrowUntil[client]) return;

    bool sol = Blaze_SolMode(client);
    g_iBlazeBeepPitch[client] = 0;
    g_fBlazeNextBeep[client]  = 0.0;

    if (GetEntityFlags(client) & FL_ONGROUND)
    {
        if (g_cvBlazeKickUse != null && !g_cvBlazeKickUse.BoolValue) return;
        // carga 0.35s / 0.6s en Sol (el Lua L1234-1244)
        g_iBlazeChargeKind[client] = 1;
        g_fBlazeChargeEnd[client] = now + (sol ? 0.6 : 0.35);

        // v2.2-OM: EFECTO DE PREPARACION — "el efecto de cuando prepara
        // la patada es esta molotov_explosion_burst3 Ojo solo se
        // aplicara al inicio de la habilidad": UNA vez, al arrancar la
        // carga del kick (no en el lanzamiento, no en el vuelo).
        {
            float kpos[3], kang[3];
            GetClientAbsOrigin(client, kpos);
            GetClientAbsAngles(client, kang);
            Blaze_ParticleLife(kpos, kang, BLZ_FX_MOLLY_BURST3, 2.0);
        }
    }
    else
    {
        if (g_cvBlazeDashUse != null && !g_cvBlazeDashUse.BoolValue) return;
        // carga 0.7s / 0.6s CONGELADA en el sitio (el Lua L1250-1254)
        g_iBlazeChargeKind[client] = 2;
        g_fBlazeChargeEnd[client] = now + (sol ? 0.7 : 0.6);
        g_bBlazeLaggedZero[client] = true;
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0001);
        float zero[3] = { 0.0, 0.0, 0.0 };
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, zero);
    }

    // tinte ROJO del avatar durante la carga (el glow del Lua)
    Blaze_AvatarTint(client, true);
}

void Blaze_Ability2(int client)   // X: Burning Javelin (sol<50) / Sol Flame (sol>=50)
{
    if (!Blaze_PlayerIs(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2) return;
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    float now = GetEngineTime();
    if (now < g_fBlazeJavFlameCd[client])
    {
        PrintCenterText(client, "[Blaze] %s en enfriamiento: %.1fs", Blaze_SolMode(client) ? "Sol Flame" : "Burning Javelin", g_fBlazeJavFlameCd[client] - now);
        return;
    }
    if (g_iBlazeChargeKind[client] != 0 || g_bBlazeKickFly[client]) return;
    if (g_bBlazeExpell[client] || g_bBlazeDrainDash[client]) return;
    if (now < g_fBlazeSolDashWin[client] || now < g_fBlazeCanDashUntil[client]) return;
    if (now < g_fBlazeRollUntil[client]) return;

    if (Blaze_SolMode(client))
    {
        // ---- SOL FLAME (el Lua L1270-1273) ----
        if (g_cvBlazeSolfUse != null && !g_cvBlazeSolfUse.BoolValue) return;
        g_bBlazeExpell[client]       = true;
        g_fBlazeExpellStart[client]  = now + 0.45;   // los 0.45s de 'BlazeBeepingsfx'
        g_fBlazeNextSwoosh[client]   = 0.0;
        g_iBlazeBeepPitch[client]    = 0;
        Blaze_AvatarTint(client, true);
        return;
    }

    // ---- BURNING JAVELIN (el Lua L1288-1317) ----
    if (g_cvBlazeJavUse != null && !g_cvBlazeJavUse.BoolValue) return;
    if (g_iBlazeJavelin[client] != 0) return;   // uno vivo por jugador (como el Lua)
    g_fBlazeJavFlameCd[client] = now + Blaze_Cd((g_cvBlazeJavCd != null) ? g_cvBlazeJavCd.FloatValue : 25.0);
    g_fBlazeThrowUntil[client] = now + 0.5;     // one-shot del gesto
    g_iBlazeForceAnim[client]  = BLAZE_ST_THROW;
    Blaze_Snd(BLAZE_IDX_JAV, client);
    CreateTimer(0.45, T_BlazeJavelinFire, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_BlazeJavelinFire(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (!Blaze_PlayerIs(client)) return Plugin_Stop;
    if (g_iBlazeJavelin[client] != 0) return Plugin_Stop;

    float fwd[3];
    float pos[3], ang[3];
    GetClientEyePosition(client, pos);
    GetClientEyeAngles(client, ang);
    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);

    int jav = CreateEntityByName("prop_physics_override");
    if (jav <= 0 || !IsValidEntity(jav)) return Plugin_Stop;
    DispatchKeyValue(jav, "model", g_sBlazeJavModel);
    DispatchKeyValue(jav, "targetname", "blaze_javelin_om");
    DispatchSpawn(jav);

    // v2.5-OM: nace a la altura de la MANO de tiro (ojo + 30 al frente),
    // no +40 sobre la cabeza — y CON la velocidad puesta desde el mismo
    // Teleport: no hay tick huerfano entre el spawn y el primer think
    float spd = (g_cvBlazeJavSpeed != null) ? g_cvBlazeJavSpeed.FloatValue : 3000.0;
    float vel[3];
    CopyVector(fwd, vel); ScaleVector(vel, spd);
    pos[0] += fwd[0] * 30.0; pos[1] += fwd[1] * 30.0; pos[2] += 10.0;
    GetVectorAngles(fwd, ang);
    // v2.8: LA LANZA MIRA AL FRENTE (pedido del owner: "la lanza debe
    // mirar 90 grados hacia el frente") — el picon w_pitchfork nace
    // vertical; +90 de pitch pone su eje largo a lo largo del vuelo
    // (apuntando a donde va). blaze_javelin_pitch -90 si el modelo
    // quedara al reves; 0 = vertical como antes.
    ang[0] += (g_cvBlazeJavPitch != null) ? g_cvBlazeJavPitch.FloatValue : 90.0;
    TeleportEntity(jav, pos, ang, vel);

    // v2.5-OM: el vuelo ya NO lee velocidades del prop — la DIRECCION
    // queda guardada AQUI (el Lua: EnableDrag/Gravity false + el Think
    // lo arrastra; el m_vecVelocity del datamap del prop_physics_override
    // no siempre refleja el vphysics y si leia 0 el javelin moria al
    // instante = "no lanza nada"). El think la sostiene cada tick.
    // TOPE DE VUELO 6s: antes, si no tocaba nada, salia del mapa por el
    // cielo y NUNCA moria — el "uno vivo por jugador" bloqueaba la
    // habilidad para siempre.
    g_iBlazeJavelin[client]          = EntIndexToEntRef(jav);
    g_iBlazeJavelinTarget[client]    = 0;
    g_fBlazeJavCarryUntil[client]    = 0.0;
    g_fBlazeJavDieAt[client]         = GetEngineTime() + 6.0;   // tope de vuelo
    g_bBlazeJavStuck[client]         = false;
    g_vBlazeJavDir[client][0]        = fwd[0];
    g_vBlazeJavDir[client][1]        = fwd[1];
    g_vBlazeJavDir[client][2]        = fwd[2];
    g_fBlazeJavPrev[client][0]       = pos[0];
    g_fBlazeJavPrev[client][1]       = pos[1];
    g_fBlazeJavPrev[client][2]       = pos[2];

    // v2.5-OM: EL FUEGO DEL JAVELIN — la estela molotov_trail de la v2.2
    // NO existe en L4D2 (nombre invalido = particula que nunca renderiza,
    // la misma clase de bug de las llamas invisibles). Ahora: env_fire_small
    // PARENTADA al picon (familia de los fuegos ambientales de los mapas,
    // la confirmada por el owner en el Sol Flame v2.3 y el dash v2.4) +
    // el picon w_pitchfork.mdl del L4D2 base = TODO cliente lo ve.
    // Look intercambiable: blaze_fx_jav_name (vacio = sin fuego).
    {
        char sJavFx[64];
        sJavFx[0] = '\0';
        if (g_cvBlazeFXJavName != null) g_cvBlazeFXJavName.GetString(sJavFx, sizeof(sJavFx));
        if (sJavFx[0] == '\0') strcopy(sJavFx, sizeof(sJavFx), BLZ_FX_FIRE_SMALL);
        int trail = CreateEntityByName("info_particle_system");
        if (trail > 0 && IsValidEntity(trail))
        {
            DispatchKeyValue(trail, "effect_name", sJavFx);
            DispatchSpawn(trail);
            ActivateEntity(trail);
            TeleportEntity(trail, pos, NULL_VECTOR, NULL_VECTOR);
            SetVariantString("!activator");
            AcceptEntityInput(trail, "SetParent", jav);
            AcceptEntityInput(trail, "Start");
            // tope de seguridad (muere con el javelin via el cleanup de
            // abajo; esto cubre el caso de un javelin huerfano raro)
            char tio[96];
            Format(tio, sizeof(tio), "OnUser1 !self:kill::8.0:1");
            SetVariantString(tio);
            AcceptEntityInput(trail, "AddOutput");
            AcceptEntityInput(trail, "FireUser1");
            g_iBlazeJavFxRef[client] = EntIndexToEntRef(trail);
        }
    }

    // impulso inicial por hueso (el motor del suite) + el think lo sostiene
    Sonic_PhysSetVel(jav, vel, g_vBlazeNoSpin);

    // glow del disparo (grafico nativo: glow sprite del suite)
    if (g_iBlazeGlowSprite > 0)
    {
        TE_SetupGlowSprite(pos, g_iBlazeGlowSprite, 0.4, 1.2, 180);
        TE_SendToAll();
    }
    return Plugin_Stop;
}

// =====================================================================
// v2.0-OM: EL TICK DEL KIT — llamado desde T_BlazeAvatarThink (10 Hz).
// Todo el arbol de estados del Lua en un solo lugar: carga (beeps),
// ventana del kick, drain dash, ventana del dash, sol flame.
// =====================================================================
void Blaze_GameplayThink(int client, float now)
{
    if (!Blaze_PlayerIs(client)) return;

    // hook de dano perezoso (una vez por cliente)
    if (!g_bBlazeDmgHooked[client])
    {
        SDKHook(client, SDKHook_OnTakeDamage, Blaze_OnTakeDamage);
        g_bBlazeDmgHooked[client] = true;
    }

    bool busy = false;
    bool sol  = Blaze_SolMode(client);

    // ------------------ CARGA (kick o dash) ------------------
    if (g_iBlazeChargeKind[client] != 0)
    {
        busy = true;
        if (now >= g_fBlazeNextBeep[client])
        {
            g_fBlazeNextBeep[client] = now + 0.1;
            Blaze_SndPitch(BLAZE_IDX_BEEP, client, 90 + g_iBlazeBeepPitch[client]);
            g_iBlazeBeepPitch[client] += 8;   // ~+25 al final de la carga, como el Lua
        }
        if (g_iBlazeChargeKind[client] == 2)
        {
            // carga del dash: CLAVADA en el sitio (el Lua L893-898)
            float z[3] = { 0.0, 0.0, 0.0 };
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, z);
        }
        if (now >= g_fBlazeChargeEnd[client])
        {
            int kind = g_iBlazeChargeKind[client];
            g_iBlazeChargeKind[client] = 0;
            if (g_bBlazeLaggedZero[client])
            {
                g_bBlazeLaggedZero[client] = false;
                SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            }

            if (kind == 1)
            {
                // === LANZAMIENTO DEL KICK (Lua L710-787) ===
                if (sol) Blaze_Snd(BLAZE_IDX_FIRESTORM, client);
                Blaze_Snd(BLAZE_IDX_SWING, client);
                float eye[3], fwd[3], vel[3], p[3];
                GetClientEyeAngles(client, eye);
                GetAngleVectors(eye, fwd, NULL_VECTOR, NULL_VECTOR);
                // Lua: sol>=50 fwd*365*3 + up*135*2.1 | sol<50 fwd*365*2.8 + up*135*1.8
                if (sol) { CopyVector(fwd, vel); ScaleVector(vel, 1095.0); vel[2] = 283.0; }
                else     { CopyVector(fwd, vel); ScaleVector(vel, 1022.0); vel[2] = 243.0; }
                GetClientAbsOrigin(client, p);
                p[2] += 15.0;                     // el despegue +15z del Lua
                TeleportEntity(client, p, NULL_VECTOR, vel);

                // v2.5: la hitbox arranca AQUI — el recorrido cuenta
                // desde el despegue (el primer tick de vuelo no tiene
                // hueco con la carga)
                g_fBlazeKickPrev[client][0] = p[0];
                g_fBlazeKickPrev[client][1] = p[1];
                g_fBlazeKickPrev[client][2] = p[2] + 50.0;

                g_bBlazeKickFly[client]      = true;
                g_fBlazeKickFlyEnd[client]   = now + 0.25;   // 'KickStarted' +0.25
                g_iBlazeForceAnim[client]    = BLAZE_ST_KICK;
            }
            else
            {
                // === LANZAMIENTO DEL DASH (Lua L900-929) ===
                Blaze_Snd(BLAZE_IDX_DASHGO, client);

                // v2.5: la hitbox del dash tambien es el recorrido
                float dprev[3];
                GetClientAbsOrigin(client, dprev);
                dprev[2] += 50.0;
                CopyVector(dprev, g_fBlazeKickPrev[client]);

                // v2.2-OM: "con sol dash usara inferno_wall_primary en el
                // cuerpo de blaze durante el efecto" — la pared de fuego
                // parentada al cuerpo desde el despegue (ambas variantes:
                // ventana y DrainDash; se remueve en TODOS los fines)
                Blaze_FX_DashStart(client);

                if (sol)
                {
                    g_bBlazeDrainDash[client] = true;        // 'DrainDash'
                    g_iBlazeForceAnim[client] = BLAZE_ST_SOLDASH;
                }
                else
                {
                    g_fBlazeSolDashWin[client] = now + 0.85; // 'SolDashStun' 0.85s
                    g_bBlazeDashLived[client] = true;
                    float deye[3], dvel[3];
                    GetClientEyeAngles(client, deye);
                    GetAngleVectors(deye, dvel, NULL_VECTOR, NULL_VECTOR);
                    float dSpd = (g_cvBlazeDashSpeed != null) ? g_cvBlazeDashSpeed.FloatValue : 1400.0;
                    ScaleVector(dvel, dSpd);
                    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, dvel);
                    g_iBlazeForceAnim[client] = BLAZE_ST_SOLDASH;
                }
            }
        }
    }
    else if (g_bBlazeKickFly[client])
    {
        // ------------------ VENTANA DEL KICK (Lua L789-836) ------------------
        // v2.5-OM: LA HITBOX ES EL RECORRIDO ENTERO — se barre el segmento
        // del tick anterior al actual (esfera 100 por muestra, contra el
        // CENTRO de las victimas): pega desde que despega hasta que
        // termina el movimiento, no solo al caer al final.
        busy = true;
        float c[3];
        GetClientAbsOrigin(client, c);
        c[2] += 50.0;                              // centro de Blaze a +50z
        float dir[3];
        int victim = Blaze_ScanEnemyPath(client, g_fBlazeKickPrev[client], c, 100.0, dir);
        g_fBlazeKickPrev[client][0] = c[0];
        g_fBlazeKickPrev[client][1] = c[1];
        g_fBlazeKickPrev[client][2] = c[2];
        if (victim > 0)
        {
            Blaze_HitImpact(client, victim, false);
            g_bBlazeKickFly[client]    = false;     // cierra la ventana
            g_iBlazeForceAnim[client]  = -1;        // el Lua pasa a jump2
            // v2.5-OM: EL REMBOLSO DEL OWNER — "la patada regresara un
            // 65% de enfriamiento" al acertar: devuelve el 65% del cd de
            // aterrizaje (17 -> 5.95s antes de blaze_cd_scale; el miss
            // conserva su cd completo)
            float refund = (g_cvBlazeKickRefund != null) ? g_cvBlazeKickRefund.FloatValue : 0.65;
            float cdHit  = Blaze_Cd((g_cvBlazeKickCdLand != null) ? g_cvBlazeKickCdLand.FloatValue : 17.0) * (1.0 - refund);
            g_fBlazeKickDashCd[client] = now + cdHit;
            g_fBlazeKickFlyEnd[client] = now + 1.0; // blindar el miss
        }
        else if ((GetEntityFlags(client) & FL_ONGROUND) != 0 && now >= g_fBlazeKickFlyEnd[client])
        {
            // === MISS (Lua L819-836): Roll + impulso + cd miss + penal ===
            g_bBlazeKickFly[client]    = false;
            g_fBlazeRollUntil[client]  = now + 0.5;
            g_iBlazeForceAnim[client]  = BLAZE_ST_ROLL;
            float eye[3], fwd[3], rv[3];
            GetClientEyeAngles(client, eye);
            GetAngleVectors(eye, fwd, NULL_VECTOR, NULL_VECTOR);
            CopyVector(fwd, rv);
            ScaleVector(rv, 650.0);                 // 'RollDir' fwd*650
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, rv);
            g_fBlazeKickDashCd[client] = now + Blaze_Cd((g_cvBlazeKickCdMiss != null) ? g_cvBlazeKickCdMiss.FloatValue : 25.0);
            if (sol) Blaze_AddSol(client, -((g_cvBlazeKickSolPen != null) ? g_cvBlazeKickSolPen.FloatValue : 15.0));
        }
    }
    else if (g_bBlazeDrainDash[client])
    {
        // ------------------ DRAIN DASH SOSTENIDO (Lua L965-1020) ------------------
        busy = true;
        float dr = (g_cvBlazeDashDrain != null) ? g_cvBlazeDashDrain.FloatValue : 5.0;
        Blaze_AddSol(client, -dr * 0.1);           // por tick de 0.1s
        if (g_fBlazeSol[client] <= 0.0)
        {
            // sin sol: caida con ventana corta (Lua L1015-1019)
            g_bBlazeDrainDash[client] = false;
            g_fBlazeSolDashWin[client] = now + 0.5;
            g_bBlazeDashLived[client]  = true;
            g_fBlazeKickDashCd[client] = now + Blaze_Cd((g_cvBlazeDashCdMiss != null) ? g_cvBlazeDashCdMiss.FloatValue : 25.0);
            g_iBlazeForceAnim[client] = -1;
            Blaze_FX_DashStop(client);   // v2.2: el fuego del cuerpo se apaga
        }
        else
        {
            // vuelo hacia la MIRA (Lua: EyeAngles fwd * soldashspeed)
            float deye[3], dvel[3];
            GetClientEyeAngles(client, deye);
            GetAngleVectors(deye, dvel, NULL_VECTOR, NULL_VECTOR);
            float dSpd = (g_cvBlazeDashSpeed != null) ? g_cvBlazeDashSpeed.FloatValue : 1400.0;
            ScaleVector(dvel, dSpd);
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, dvel);

            // v2.5: hitbox = el recorrido (mismo barrido del kick)
            // v2.11-OM: EL AREA DEL DASH MAS GRANDE — la esfera del
            // barrido del DASH AEREO sube de 100 a blaze_dash_hitradius
            // (150 default); el kick conserva su 100 de siempre
            float c[3];
            GetClientAbsOrigin(client, c);
            c[2] += 50.0;
            float dRad = (g_cvBlazeDashHitRad != null) ? g_cvBlazeDashHitRad.FloatValue : 150.0;
            if (dRad < 40.0) dRad = 40.0;
            float dir[3];
            int victim = Blaze_ScanEnemyPath(client, g_fBlazeKickPrev[client], c, dRad, dir);
            g_fBlazeKickPrev[client][0] = c[0];
            g_fBlazeKickPrev[client][1] = c[1];
            g_fBlazeKickPrev[client][2] = c[2];
            if (victim > 0)
            {
                Blaze_HitImpact(client, victim, true);
                g_bBlazeDrainDash[client] = false;
                g_iBlazeForceAnim[client] = -1;
                g_fBlazeKickDashCd[client] = now + Blaze_Cd((g_cvBlazeDashCdLand != null) ? g_cvBlazeDashCdLand.FloatValue : 17.0);
            }
        }
    }
    else if (now < g_fBlazeSolDashWin[client])
    {
        // ------------------ VENTANA DEL DASH (Lua L931-963) ------------------
        busy = true;
        // v2.5: hitbox = el recorrido (mismo barrido del kick)
        // v2.11-OM: EL AREA DEL DASH MAS GRANDE — esfera del barrido por
        // blaze_dash_hitradius (150; antes 100 fijo)
        float c[3];
        GetClientAbsOrigin(client, c);
        c[2] += 50.0;
        float dRad = (g_cvBlazeDashHitRad != null) ? g_cvBlazeDashHitRad.FloatValue : 150.0;
        if (dRad < 40.0) dRad = 40.0;
        float dir[3];
        int victim = Blaze_ScanEnemyPath(client, g_fBlazeKickPrev[client], c, dRad, dir);
        g_fBlazeKickPrev[client][0] = c[0];
        g_fBlazeKickPrev[client][1] = c[1];
        g_fBlazeKickPrev[client][2] = c[2];
        if (victim > 0)
        {
            Blaze_HitImpact(client, victim, true);
            g_fBlazeSolDashWin[client] = 0.0;
            g_bBlazeDashLived[client]  = false;
            g_iBlazeForceAnim[client]  = -1;
            g_fBlazeKickDashCd[client] = now + Blaze_Cd((g_cvBlazeDashCdLand != null) ? g_cvBlazeDashCdLand.FloatValue : 17.0);
        }
        else if ((GetEntityFlags(client) & FL_ONGROUND) != 0)
        {
            g_fBlazeSolDashWin[client] = 0.0;       // el suelo corta la ventana
            Blaze_FX_DashStop(client);              // v2.2: y apaga el fuego del cuerpo
        }
    }
    else if (g_bBlazeDashLived[client] && now >= g_fBlazeSolDashWin[client])
    {
        // la ventana expiro sin tocar a nadie (Lua L954-958): cd miss
        g_bBlazeDashLived[client]  = false;
        g_fBlazeKickDashCd[client] = now + Blaze_Cd((g_cvBlazeDashCdMiss != null) ? g_cvBlazeDashCdMiss.FloatValue : 25.0);
        if (g_iBlazeForceAnim[client] == BLAZE_ST_SOLDASH) g_iBlazeForceAnim[client] = -1;
        Blaze_FX_DashStop(client);                  // v2.2: fin del dash = fuego fuera
    }
    else if (g_bBlazeExpell[client])
    {
        // ------------------ SOL FLAME (Lua L1023-1189) ------------------
        busy = true;
        if (now < g_fBlazeExpellStart[client])
        {
            // los 0.45s de carga: beep con tono DESCENDENTE (Lua L663-676)
            if (now >= g_fBlazeNextBeep[client])
            {
                g_fBlazeNextBeep[client] = now + 0.1;
                Blaze_SndPitch(BLAZE_IDX_BEEP, client, 80 + g_iBlazeBeepPitch[client]);
                g_iBlazeBeepPitch[client] -= 9;
            }
        }
        else
        {
            // anims SolFlame segun como se mueva
            float s2 = Blaze_Speed2D(client);
            if (s2 < 40.0)        g_iBlazeForceAnim[client] = BLAZE_ST_SOLF_IDLE;
            else if (s2 < 150.0)  g_iBlazeForceAnim[client] = BLAZE_ST_SOLF_WALK;
            else                  g_iBlazeForceAnim[client] = BLAZE_ST_SOLF_RUN;

            // CONO 650u / 50 grados frente a la mira (el FindInCone del Lua)
            float eye[3], fwd[3], origin[3];
            GetClientEyeAngles(client, eye);
            GetAngleVectors(eye, fwd, NULL_VECTOR, NULL_VECTOR);
            GetClientAbsOrigin(client, origin);
            origin[2] += 35.0;
            origin[0] -= fwd[0] * 20.0;
            origin[1] -= fwd[1] * 20.0;

            float range  = (g_cvBlazeSolfRange  != null) ? g_cvBlazeSolfRange.FloatValue  : 650.0;
            float maxDeg = (g_cvBlazeSolfAngle  != null) ? g_cvBlazeSolfAngle.FloatValue  : 50.0;
            float push   = (g_cvBlazeSolfPush   != null) ? g_cvBlazeSolfPush.FloatValue   : 275.0;
            float ignT   = (g_cvBlazeSolfIgnite != null) ? g_cvBlazeSolfIgnite.FloatValue : 1.35;
            float cosLim = Cosine(DegToRad(maxDeg));

            // (1) SI players (equipo 3): empujon 175 + quema (Lua L1130-1163)
            for (int t = 1; t <= MaxClients; t++)
            {
                if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
                if (GetClientTeam(t) != TEAM_INFECTED) continue;
                float p[3], to[3];
                GetClientAbsOrigin(t, p);
                SubtractVectors(p, origin, to);
                float dist = NormalizeVector(to, to);
                if (dist > range) continue;
                if (GetVectorDotProduct(to, fwd) < cosLim) continue;

                if ((GetEntityFlags(t) & FL_ONGROUND) != 0)
                {
                    p[2] += 15.0;
                    TeleportEntity(t, p, NULL_VECTOR, NULL_VECTOR);   // la levantada del Lua
                }
                float pv[3];
                CopyVector(to, pv); ScaleVector(pv, 175.0);
                TeleportEntity(t, NULL_VECTOR, NULL_VECTOR, pv);
                Blaze_ConeBurn(t, ignT);   // v2.12: cadencia 0.5s + stack de debilidad
            }

            // (2) NPCs (comunes/witch/tank): empujon 275 + quema
            static const char sNpc[][] = { "infected", "witch", "tank" };
            for (int n = 0; n < sizeof(sNpc); n++)
            {
                int ent = -1;
                while ((ent = FindEntityByClassname(ent, sNpc[n])) != -1)
                {
                    if (!IsValidEntity(ent)) continue;
                    if (!HasEntProp(ent, Prop_Data, "m_iHealth")) continue;
                    if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
                    float p[3], to[3];
                    GetEntPropVector(ent, Prop_Data, "m_vecOrigin", p);
                    SubtractVectors(p, origin, to);
                    float dist = NormalizeVector(to, to);
                    if (dist > range) continue;
                    if (GetVectorDotProduct(to, fwd) < cosLim) continue;

                    if ((GetEntityFlags(ent) & FL_ONGROUND) != 0)
                    {
                        p[2] += 15.0;
                        TeleportEntity(ent, p, NULL_VECTOR, NULL_VECTOR);
                    }
                    float pv[3];
                    CopyVector(to, pv); ScaleVector(pv, push);
                    TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, pv);
                    Blaze_ConeBurn(ent, ignT);   // v2.12: cadencia + stack (la witch JAMAS se quema)
                }
            }

            // (3) PROPS del cono: empujon fisico (Lua: ApplyForceCenter 2500)
            int pr = -1;
            while ((pr = FindEntityByClassname(pr, "prop_physics")) != -1)
            {
                if (!IsValidEntity(pr)) continue;
                float p[3], to[3];
                GetEntPropVector(pr, Prop_Data, "m_vecOrigin", p);
                SubtractVectors(p, origin, to);
                float dist = NormalizeVector(to, to);
                if (dist > range) continue;
                if (GetVectorDotProduct(to, fwd) < cosLim) continue;
                float pv[3];
                CopyVector(to, pv);
                pv[2] += 0.1;
                ScaleVector(pv, 2500.0);
                Sonic_PhysSetVel(pr, pv, g_vBlazeNoSpin);
            }

            // v2.2-OM: EL GRAFICO DEL CONO — "el grafico que remplazara
            // a la que usa La Sol flame sera inferno_wall_occlusion":
            // muro de fuego por SEGMENTO a lo largo del cono, refrescado
            // por cadencia (blaze_fx_solf_cadence). El PITCH lo manda
            // blaze_fx_flame_pitch (default -90 = acostado al frente tipo
            // lanzallamas —PENDIENTE de verificar con el fxtest.smx: si
            // las llamas siguen subiendo, poner 0 = muro vertical).
            if (now >= g_fBlazeNextWallFx[client])
            {
                float cad = (g_cvBlazeFXSolfCadence != null) ? g_cvBlazeFXSolfCadence.FloatValue : 0.35;
                g_fBlazeNextWallFx[client] = now + cad;

                float wAng[3];
                wAng[0] = (g_cvBlazeFXFlamePitch != null) ? g_cvBlazeFXFlamePitch.FloatValue : -90.0;
                wAng[1] = eye[1];
                wAng[2] = 0.0;

                float wLife = (g_cvBlazeFXFlameLife != null) ? g_cvBlazeFXFlameLife.FloatValue : 1.5;

                // v2.3-OM: EL CONO VISIBLE. La v2.2 usaba
                // inferno_wall_occlusion — el nombre EXISTE en L4D2
                // (lista oficial de particulas) pero es la CAPA DE
                // OCLUSION: la mascara tecnica del muro del molotov
                // que TAPA la geometria DETRAS del fuego — NO dibuja
                // llamas por si sola (la familia: _primary = llamas /
                // _smoke = humo / _refraction = distorsion / _occlusion
                // = mascara). Por eso el grafico era invisible con la
                // habilidad funcionando (dano/empuje/quema SI llegaban).
                // Ahora: BOCA = env_fire_large + TRAMOS a 170/340/510/650u
                // con env_fire_medium (los fuegos ambientales de los
                // mapas: solo CP0, SIEMPRE visibles), cada tramo con
                // cpoint1 al punto siguiente — si se cambia el nombre
                // por convar a inferno_wall_primary, el muro dibuja el
                // tramo entero entre punto y punto.
                char segName[64], mouthName[64];
                segName[0] = '\0'; mouthName[0] = '\0';
                if (g_cvBlazeFXFlameName != null)  g_cvBlazeFXFlameName.GetString(segName, sizeof(segName));
                if (g_cvBlazeFXFlameMouth != null) g_cvBlazeFXFlameMouth.GetString(mouthName, sizeof(mouthName));
                if (segName[0] == '\0')   strcopy(segName,  sizeof(segName),  BLZ_FX_FIRE_MEDIUM);
                if (mouthName[0] == '\0') strcopy(mouthName, sizeof(mouthName), BLZ_FX_FIRE_LARGE);

                float p1[3], p2[3], p3[3], pE[3];
                p1[0] = origin[0] + fwd[0] * 170.0; p1[1] = origin[1] + fwd[1] * 170.0; p1[2] = origin[2] + fwd[2] * 170.0;
                p2[0] = origin[0] + fwd[0] * 340.0; p2[1] = origin[1] + fwd[1] * 340.0; p2[2] = origin[2] + fwd[2] * 340.0;
                p3[0] = origin[0] + fwd[0] * 510.0; p3[1] = origin[1] + fwd[1] * 510.0; p3[2] = origin[2] + fwd[2] * 510.0;
                pE[0] = origin[0] + fwd[0] * 650.0; pE[1] = origin[1] + fwd[1] * 650.0; pE[2] = origin[2] + fwd[2] * 650.0;

                Blaze_FxFlameSeg(origin, p1, wAng, mouthName, wLife);
                Blaze_FxFlameSeg(p1, p2, wAng, segName, wLife);
                Blaze_FxFlameSeg(p2, p3, wAng, segName, wLife);
                Blaze_FxFlameSeg(p3, pE, wAng, segName, wLife);
            }

            // swoosh cada 0.5s (Lua L1141-1163) + v2.2: pasada de dano a
            // los commons del cono ("todas las habilidades tendra dano
            // aoe a commons") — sin fx por common, solo el empuje que ya
            // hace el cono de arriba + este dano por pasada
            if (now >= g_fBlazeNextSwoosh[client])
            {
                g_fBlazeNextSwoosh[client] = now + 0.5;
                Blaze_Snd(BLAZE_IDX_SWOOSH, client);

                float coneDmg = (g_cvBlazeSolfConeDmg != null) ? g_cvBlazeSolfConeDmg.FloatValue : 20.0;
                if (coneDmg > 0.0)
                {
                    // v2.10-OM CRASHPROOF: SNAPSHOT antes del daño (el
                    // mismo patron del AoeCommons: dañar DENTRO del
                    // FindEntityByClassname arranca la siguiente
                    // iteracion desde un edict que pudo liberarse en
                    // este mismo frame — crash silencioso del motor)
                    int slist[96];
                    int scount = 0;
                    int ent = -1;
                    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
                    {
                        if (scount >= sizeof(slist)) break;
                        if (!IsValidEntity(ent)) continue;
                        if (!HasEntProp(ent, Prop_Data, "m_iHealth")) continue;
                        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
                        float p[3], to[3];
                        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", p);
                        SubtractVectors(p, origin, to);
                        float dist = NormalizeVector(to, to);
                        if (dist > range) continue;
                        if (GetVectorDotProduct(to, fwd) < cosLim) continue;
                        slist[scount++] = ent;
                    }
                    for (int k = 0; k < scount; k++)
                        if (Blaze_VictimAlive(slist[k]))
                            // v2.12: pasa por el wrapper — el stack del
                            // Sol Flame amplifica esta pasada de daño
                            Blaze_AbilityDamage(slist[k], client, coneDmg, DMG_OM_CLUB, true);
                }
            }

            // drena 2.5/s hasta vaciar (Lua L1177-1183)
            float drn = (g_cvBlazeSolfDrain != null) ? g_cvBlazeSolfDrain.FloatValue : 2.5;
            Blaze_AddSol(client, -drn * 0.1);
            if (g_fBlazeSol[client] <= 0.0)
            {
                g_bBlazeExpell[client]      = false;
                g_iBlazeForceAnim[client]  = -1;
                g_fBlazeJavFlameCd[client] = now + Blaze_Cd((g_cvBlazeSolfCd != null) ? g_cvBlazeSolfCd.FloatValue : 25.0);
            }
        }
    }

    // ------------------ one-shots + tinte + iframes ------------------
    if (!busy)
    {
        if (g_iBlazeForceAnim[client] == BLAZE_ST_ROLL  && now >= g_fBlazeRollUntil[client])  g_iBlazeForceAnim[client] = -1;
        if (g_iBlazeForceAnim[client] == BLAZE_ST_THROW && now >= g_fBlazeThrowUntil[client]) g_iBlazeForceAnim[client] = -1;
        if (g_bBlazeTintOn[client]) { Blaze_AvatarTint(client, false); g_bBlazeTintOn[client] = false; }
    }
    else if (!g_bBlazeTintOn[client]) { Blaze_AvatarTint(client, true); g_bBlazeTintOn[client] = true; }

    // la pasiva del Lua: iframes2 +0.75 mientras CUALQUIER estado activo
    if (busy) g_fBlazeIframeUntil[client] = now + 0.75;
}

// =====================================================================
// v2.0-OM: THINK DEL JAVELIN (30 Hz) — el setvelocityofphysics del Lua
// (Think hook): sostiene el vuelo, busca objetivo (esfera 80), lo
// ARRASTRA 0.5s clavado al javelin y lo suelta; si toca pared se
// clava, suena y se apaga.
// =====================================================================
public Action T_BlazeJavelinThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iBlazeJavelin[i] == 0) continue;

        int jav = EntRefToEntIndex(g_iBlazeJavelin[i]);
        if (jav <= 0 || !IsValidEntity(jav))
        {
            Blaze_JavelinCleanup(i);
            continue;
        }
        float jp[3];
        GetEntPropVector(jav, Prop_Data, "m_vecOrigin", jp);

        // ---- clavado: fade y fuera ----
        if (g_bBlazeJavStuck[i])
        {
            if (now >= g_fBlazeJavDieAt[i])
            {
                AcceptEntityInput(jav, "Kill");
                Blaze_JavelinCleanup(i);
            }
            continue;
        }

        // ---- arrastrando a la victima: pin al javelin (Lua L1386-1416) ----
        if (g_iBlazeJavelinTarget[i] != 0)
        {
            int tgt = EntRefToEntIndex(g_iBlazeJavelinTarget[i]);
            // v2.10-OM: ademas de entidad valida tiene que seguir VIVA —
            // si el fuego (o cualquier otra cosa) la mato a mitad del
            // arrastre, su edict ya pudo liberarse y reciclarse:
            // TeleportEntity sobre un cadaver reciclado es exactly el
            // tipo de acceso que tumba el motor sin decir nada
            if (tgt > 0 && Blaze_VictimAlive(tgt))
            {
                if (now < g_fBlazeJavCarryUntil[i])
                {
                    // sigue volando LLEVANDOSELO — v2.5: velocidad desde
                    // la DIRECCION guardada (cero lecturas al prop)
                    float spd = (g_cvBlazeJavSpeed != null) ? g_cvBlazeJavSpeed.FloatValue : 3000.0;
                    float v[3];
                    v[0] = g_vBlazeJavDir[i][0] * spd;
                    v[1] = g_vBlazeJavDir[i][1] * spd;
                    v[2] = g_vBlazeJavDir[i][2] * spd;
                    Sonic_PhysSetVel(jav, v, g_vBlazeNoSpin);
                    TeleportEntity(jav, NULL_VECTOR, NULL_VECTOR, v);
                    float z[3] = { 0.0, 0.0, 0.0 };
                    TeleportEntity(tgt, jp, NULL_VECTOR, z);   // clavado al javelin
                    continue;
                }
                // soltarlo: queda en el sitio (Lua L1461-1468: vel 0)
                float z2[3] = { 0.0, 0.0, 0.0 };
                TeleportEntity(tgt, NULL_VECTOR, NULL_VECTOR, z2);
                g_iBlazeJavelinTarget[i] = 0;
                Blaze_Snd(BLAZE_IDX_IMPACT, jav);
                g_bBlazeJavStuck[i]  = true;      // el javelin se clava
                g_fBlazeJavDieAt[i]  = now + 0.35;
                continue;
            }
            g_iBlazeJavelinTarget[i] = 0;         // murio de camino: sigue
        }

        // ---- en vuelo: direccion fija + pared + objetivo (esfera 80) ----
        // v2.5-OM: CERO lecturas de velocidad del prop — la direccion es
        // la guardada al disparar (el Lua arrastra el Think igual); la
        // hitbox es el RECORRIDO del tick (barrido, no esfera suelta).
        {
            // tope de vuelo (v2.5): si no toco nada en 6s (cielo/mapa
            // abierto) se clava donde este y se apaga — ANTES volaba
            // fuera del mapa para siempre y bloqueaba la habilidad
            // ("uno vivo por jugador" que nunca moria)
            if (now >= g_fBlazeJavDieAt[i])
            {
                // v2.12-OM: AL LLEGAR A SU DISTANCIA MAXIMA EXPLOTA —
                // 1100 al centro (x0.75 al tank) en radio
                // blaze_javelin_expl_radius (snapshot del suite)
                Blaze_JavelinExplode(i, jav);

                float zq[3] = { 0.0, 0.0, 0.0 };
                Sonic_PhysSetVel(jav, zq, g_vBlazeNoSpin);
                TeleportEntity(jav, NULL_VECTOR, NULL_VECTOR, zq);
                g_bBlazeJavStuck[i] = true;
                g_fBlazeJavDieAt[i] = now + 0.35;
                continue;
            }

            // pared delante? (el PhysicsCollide del Lua)
            // v2.8: EL SEGMENTO RECORRIDO, no un rayo infinito. El bug
            // doble de la v2.5-2.7: (a) el filtro devolvia false para el
            // MUNDO -> la lanza atravesaba las paredes del mapa; (b) el
            // rayo era INFINITO -> cualquier func_ (puerta/barrera) en
            // la linea a CUALQUIER distancia clavaba la lanza AL NACER
            // (un rayo infinito siempre encuentra algo delante). Ahora:
            // se traza SOLO lo recorrido en este tick (prev -> jp) con el
            // filtro aceptando el mundo -> la lanza vuela hasta pegarle
            // DE VERDAD a la pared que cruza (el "mas alcanze" pedido).
            float jdir[3];
            jdir[0] = g_vBlazeJavDir[i][0];
            jdir[1] = g_vBlazeJavDir[i][1];
            jdir[2] = g_vBlazeJavDir[i][2];
            float wallEnd[3];
            bool hitWorld = false;
            Handle tr = TR_TraceRayFilterEx(g_fBlazeJavPrev[i], jp, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Blaze_JavTraceFilter, jav);
            if (TR_DidHit(tr))
            {
                int hitEnt = TR_GetEntityIndex(tr);
                if (hitEnt == 0 || hitEnt > MaxClients)
                {
                    hitWorld = true;
                    TR_GetEndPosition(wallEnd, tr);
                }
            }
            delete tr;

            // v2.8: radio de caza por convar (80 fijo antes — pedido del
            // owner de MAS ALCANCE) y el barrido solo hasta la pared: si
            // la lanza ya atraveso muro en este tick, detras del muro no
            // hay caza.
            float dir[3];
            float scanEnd[3];
            if (hitWorld) CopyVector(wallEnd, scanEnd);
            else           CopyVector(jp, scanEnd);
            float jrad = (g_cvBlazeJavRadius != null) ? g_cvBlazeJavRadius.FloatValue : 120.0;
            int victim = Blaze_ScanEnemyPath(i, g_fBlazeJavPrev[i], scanEnd, jrad, dir);
            g_fBlazeJavPrev[i][0] = jp[0];
            g_fBlazeJavPrev[i][1] = jp[1];
            g_fBlazeJavPrev[i][2] = jp[2];
            if (victim > 0)
            {
                // DAR: +sol (Lua L1425-1429) y se lo lleva
                float solg = (g_cvBlazeJavSol != null) ? g_cvBlazeJavSol.FloatValue : 15.0;
                Blaze_AddSol(i, solg);
                Blaze_Snd(BLAZE_IDX_JAVHIT, jav);

                // v2.10-OM CRASHPROOF: la POSICION de la victima ANTES
                // del daño — el daño de enganche (45 x amplificador)
                // mata al comun EN este frame y libera su edict; el
                // bloque de abajo solo usa la posicion ya capturada
                float vpos[3];
                Blaze_FX_VictimPos(victim, vpos);

                // v2.2-OM: el javelin ahora hace DAO al engancharse
                // (antes solo arrastraba) + explosion visual EN LA
                // VICTIMA + AOE a commons alrededor (visual solo en
                // la victima — anti lag, la regla del owner)
                // v2.11-OM: por la TABLA NUEVA — x2 si es WITCH (+x1.5
                // si viene debil del dash aereo): la lanza es una de
                // las "otras habilidades" para la debilidad
                // v2.12-OM: BURNING JAVELIN 45 -> 255-354 CON RUTA: el
                // daño crece +blaze_javelin_ramp (75%) al llegar a su
                // distancia maxima — la fraccion del vuelo de 6s desde
                // el disparo (nacer = base pura; tope = x1.75)
                float jDmgMin = (g_cvBlazeJavDmgMin != null) ? g_cvBlazeJavDmgMin.FloatValue : 255.0;
                float jDmgMax = (g_cvBlazeJavDmgMax != null) ? g_cvBlazeJavDmgMax.FloatValue : 354.0;
                if (jDmgMax < jDmgMin) jDmgMax = jDmgMin;
                float jRamp = (g_cvBlazeJavRamp != null) ? g_cvBlazeJavRamp.FloatValue : 0.75;
                if (jRamp < 0.0) jRamp = 0.0;
                if (jRamp > 2.0) jRamp = 2.0;
                float jFrac = 1.0 - (g_fBlazeJavDieAt[i] - now) / 6.0;
                if (jFrac < 0.0) jFrac = 0.0;
                if (jFrac > 1.0) jFrac = 1.0;
                float jDmg = GetRandomFloat(jDmgMin, jDmgMax) * (1.0 + jRamp * jFrac);
                if (jDmg > 0.0) Blaze_AbilityDamage(victim, i, jDmg, DMG_OM_CLUB, true);

                // v2.10-OM: FIX DEL CRASH — el OM_Stun es SOLO para
                // players. Un comun/witch (entidad 400+) enganchado
                // hacia saltar el rango de OM_StunValid (el bug de
                // asociatividad "1 <= 464 <= MaxClients") y reventaba
                // en "Invalid client index 464" CADA TICK que la lanza
                // lo tenia enganchado — abortaba el think entero y el
                // javelin re-escaneaba al mismo comun 30 veces por
                // segundo. Con la macro arreglada (v2.4 del OM_Stun)
                // esto ya no truena; el gate explicito lo documenta.
                // Commons: no son players — siguen con dano + arrastre
                // como siempre.
                if (victim <= MaxClients)
                    OM_Stun(victim, 1.0, i, 0.0, DMG_OM_CLUB, false, OM_STUN_F_STAGGER);
                else if (Blaze_IsWitch(victim) && Blaze_VictimAlive(victim))
                {
                    // v2.11-OM: LA WITCH DE LA LANZA — el pedido del
                    // owner: la lanza tambien la EMPUJA (el arrastre del
                    // picon a 3000 u/s ya se la lleva) aplicando su
                    // CONGELACION (el mismo 1s que entra un player, en
                    // su version witch FL_FROZEN: queda ESTATUA clavada
                    // mientras la arrastra y un instante despues)
                    Blaze_WitchStun(victim, 1.0);
                }

                // FX en la POSICION capturada + AOE (checks propios)
                {
                    float zang[3] = { 0.0, 0.0, 0.0 };
                    Blaze_ParticleLife(vpos, zang, BLZ_FX_MOLLY_EXPL, 2.5);
                    Blaze_FX_AoeCommons(i, vpos, 1.0, victim);   // v2.13: el engancho ya dio su +15 — los demas comunes que muera el AOE cargan +2 cada uno
                }

                // v2.10-OM: si el daño de enganche mato a la victima
                // NO se arrastra nada (el ref apuntaria a un edict
                // liberado/reciclado) — la lanza sigue su vuelo sola,
                // igual que cuando el objetivo muere de camino
                if (Blaze_VictimAlive(victim))
                {
                    g_iBlazeJavelinTarget[i] = EntIndexToEntRef(victim);
                    g_fBlazeJavCarryUntil[i] = now + 0.5;
                }
                continue;
            }
            if (hitWorld)
            {
                // clavarse en la pared (Lua L1489-1531)
                // v2.8: EN el punto de contacto del segmento (retroceso
                // de 8u por el grueso del picon — antes se quedaba en la
                // posicion del tick, dentro de la pared)
                float stick[3];
                stick[0] = wallEnd[0] - jdir[0] * 8.0;
                stick[1] = wallEnd[1] - jdir[1] * 8.0;
                stick[2] = wallEnd[2] - jdir[2] * 8.0;
                TeleportEntity(jav, stick, NULL_VECTOR, NULL_VECTOR);
                float z[3] = { 0.0, 0.0, 0.0 };
                Sonic_PhysSetVel(jav, z, g_vBlazeNoSpin);
                Blaze_Snd(BLAZE_IDX_IMPACT, jav);
                g_bBlazeJavStuck[i] = true;
                g_fBlazeJavDieAt[i] = now + 0.35;
                continue;
            }
            // sostener el vuelo: dir fija * speed (setvelocityofphysics cada tick)
            float spd = (g_cvBlazeJavSpeed != null) ? g_cvBlazeJavSpeed.FloatValue : 3000.0;
            float v[3];
            v[0] = jdir[0] * spd;
            v[1] = jdir[1] * spd;
            v[2] = jdir[2] * spd;
            Sonic_PhysSetVel(jav, v, g_vBlazeNoSpin);
            TeleportEntity(jav, NULL_VECTOR, NULL_VECTOR, v);
        }
    }
    return Plugin_Continue;
}

public bool Blaze_JavTraceFilter(int entity, int contentsMask, any data)
{
    // v2.8: el MUNDO (entity 0) ya cuenta — antes se excluyo (entity != 0)
    // y el unico trace de la lanza solo veia func_*: cruzaba las paredes
    // del mapa. Ahora el rayo se limita al SEGMENTO recorrido del tick y
    // el mundo vuelve a ser solido para ella.
    return entity != view_as<int>(data);
}

void Blaze_JavelinCleanup(int client)
{
    // v2.2: la estela de fuego muere CON el javelin (todos los caminos
    // de fin pasan por aqui: clavado, cancel, muerte, mapa)
    if (g_iBlazeJavFxRef[client] != 0)
    {
        int trail = EntRefToEntIndex(g_iBlazeJavFxRef[client]);
        if (trail > MaxClients && IsValidEntity(trail))
        {
            AcceptEntityInput(trail, "Stop");
            AcceptEntityInput(trail, "Kill");
        }
        g_iBlazeJavFxRef[client] = 0;
    }

    g_iBlazeJavelin[client]       = 0;
    g_iBlazeJavelinTarget[client] = 0;
    g_fBlazeJavCarryUntil[client] = 0.0;
    g_fBlazeJavDieAt[client]      = 0.0;
    g_bBlazeJavStuck[client]      = false;
    g_vBlazeJavDir[client][0]     = 0.0;
    g_vBlazeJavDir[client][1]     = 0.0;
    g_vBlazeJavDir[client][2]     = 0.0;
    g_fBlazeJavPrev[client][0]    = 0.0;
    g_fBlazeJavPrev[client][1]    = 0.0;
    g_fBlazeJavPrev[client][2]    = 0.0;
}

// =====================================================================
// v2.0-OM: IFRAMES DE HABILIDAD (la pasiva del Lua: OM_Damage_Reduction
// 0 + DisablePlayerMovement_OM_stun_iframe2 +0.75). Mientras CUALQUIER
// estado del kit este activo (o hasta 0.75s despues del ultimo), el
// dano que entra a Blaze es 0.
// =====================================================================
public Action Blaze_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)) return Plugin_Continue;
    if (g_fBlazeIframeUntil[victim] <= 0.0) return Plugin_Continue;
    if (!Blaze_PlayerIs(victim)) return Plugin_Continue;
    if (GetEngineTime() < g_fBlazeIframeUntil[victim])
    {
        damage = 0.0;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

// =====================================================================
// v2.0-OM: RESET del kit — muerte (full: sol a on-spawn) o cambio de
// personaje (full tambien: el meter es de la identidad Blaze).
// Incap = cancel suave (ventanas fuera, lagged 1.0, tinte off).
// =====================================================================
void Blaze_CancelActive(int client)
{
    g_iBlazeChargeKind[client] = 0;
    g_bBlazeKickFly[client]    = false;
    g_bBlazeDrainDash[client]  = false;
    g_bBlazeExpell[client]     = false;
    g_fBlazeSolDashWin[client] = 0.0;
    g_bBlazeDashLived[client]  = false;
    g_iBlazeForceAnim[client]  = -1;
    Blaze_FX_DashStop(client);        // v2.2: el fuego del cuerpo FUERA
    if (g_bBlazeLaggedZero[client])
    {
        g_bBlazeLaggedZero[client] = false;
        if (IsClientInGame(client) && HasEntProp(client, Prop_Send, "m_flLaggedMovementValue"))
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
    if (g_bBlazeTintOn[client]) { Blaze_AvatarTint(client, false); g_bBlazeTintOn[client] = false; }
    // javelin a la basura
    if (g_iBlazeJavelin[client] != 0)
    {
        int jav = EntRefToEntIndex(g_iBlazeJavelin[client]);
        if (jav > 0 && IsValidEntity(jav))
        {
            int tgt = EntRefToEntIndex(g_iBlazeJavelinTarget[client]);
            if (tgt > 0 && IsValidEntity(tgt))
            {
                float z[3] = { 0.0, 0.0, 0.0 };
                TeleportEntity(tgt, NULL_VECTOR, NULL_VECTOR, z);
            }
            AcceptEntityInput(jav, "Kill");
        }
        Blaze_JavelinCleanup(client);
    }
}

void Blaze_ResetGameplay(int client, bool death)
{
    Blaze_CancelActive(client);
    g_fBlazeKickDashCd[client]   = 0.0;
    g_fBlazeJavFlameCd[client]   = 0.0;
    g_fBlazeRollUntil[client]    = 0.0;
    g_fBlazeThrowUntil[client]   = 0.0;
    g_fBlazeIframeUntil[client]  = 0.0;
    if (death)
    {
        float onSpawn = (g_cvBlazeSolOnSpawn != null) ? g_cvBlazeSolOnSpawn.FloatValue : 0.0;
        g_fBlazeSol[client] = onSpawn;
    }
}

// =====================================================================
// v2.0-OM: MUERTE DEL AVATAR — ragdoll blaze.mdl + filtro anti-corpse
// (receta Rouge v10.2 / Knuckles v75 / Metal v5.0 / Shadow v6.0 /
// Cream v7.0)
// =====================================================================
void Blaze_SpawnDeathRagdoll(int client)
{
    if (!g_bBlazeModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", BLAZE_OM_MODEL);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    CreateTimer(15.0, T_BlazeDeathRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_BlazeDeathRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Filtro anti-ragdoll (patron Rouge/Sonic/Knuckles/Shadow/Cream —
// enrutado por el OnEntityCreated central de Rouge.inc, que despacha
// a este modulo)
public void Blaze_CheckDeathRagdoll(any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent <= 0 || !IsValidEntity(ent)) return;

    char model[96];
    GetEntPropString(ent, Prop_Data, "m_ModelName", model, sizeof(model));
    if (strncmp(model, "models/survivors/", 17) != 0) return;

    float now = GetEngineTime();
    float o[3];
    GetEntPropVector(ent, Prop_Data, "m_vecOrigin", o);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_fBlazeDeathHideUntil[i] == 0.0 || now >= g_fBlazeDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_vBlazeDeathOrigin[i]) < 200.0)
        {
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}

// v3.77.69: dispatch del OnEntityCreated central de Rouge.inc — la
// ventana anti-corpse de las muertes de la Blaze con avatar
public void Blaze_OnEntityCreated(int entity, const char[] classname)
{
    if (StrEqual(classname, "prop_ragdoll")
        || StrEqual(classname, "prop_physics")
        || StrEqual(classname, "prop_physics_override")
        || StrEqual(classname, "prop_dynamic")
        || StrEqual(classname, "prop_dynamic_override")
        || StrEqual(classname, "cs_ragdoll")
        || StrEqual(classname, "survivor_death_model"))
    {
        float nowOM = GetEngineTime();
        for (int i = 1; i <= MaxClients; i++)
        {
            if (g_fBlazeDeathHideUntil[i] == 0.0 || nowOM >= g_fBlazeDeathHideUntil[i])
                continue;
            RequestFrame(Blaze_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }
}

// LA MUERTE DEL AVATAR (hook POST propio — la leccion Rouge v3.77.49:
// ni el PRE ni el POST del manager tocan el avatar de Blaze; TODO pasa
// aqui: ragdoll + ventana anti-corpse + KillAvatarOnly. La leccion
// Sonic v3.76.2: en PRE el restore dejaba ver el corpse del survivor.)
public void Blaze_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0) return;

    if (Blaze_PlayerIs(client))
    {
        // v2.0-OM: el kit se resetea con la muerte (sol al on-spawn)
        Blaze_ResetGameplay(client, true);

        if (g_iBlazeAvatar[client] != 0)
        {
            Blaze_SpawnDeathRagdoll(client);
            g_fBlazeDeathHideUntil[client] = GetEngineTime() + 2.0;
            GetClientAbsOrigin(client, g_vBlazeDeathOrigin[client]);
            Blaze_KillAvatarOnly(client);   // el cuerpo vuelve a verse para el spectate/revive
        }
    }
}

// v1.0-OM: limpieza al DESCARGAR el plugin (OnPluginEnd del manager) —
// aqui SI se mata el avatar con restore del cuerpo (no murio nadie: el
// plugin se va). SIN ragdoll.
public void Blaze_OnPluginEnd(int client)
{
    if (client < 1 || client > MaxClients) return;
    Blaze_KillAvatar(client);
}

// v1.0-OM: refs a cero al cerrar el mapa (las entidades murieron con el;
// el timer de la FSM es NO_MAPCHANGE y muere solo)
public void Blaze_OnMapEnd()
{
    delete g_hBlazeAvatarThink;
    delete g_hBlazeJavelinThink;   // v2.0-OM: el think del javelin tambien
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iBlazeAvatar[i] = 0;
        g_iBlazeAvatarL[i] = 0;
        g_iBlazeAnimState[i] = -1;
        g_fBlazeDeathHideUntil[i] = 0.0;
        // v2.0-OM: el kit entero a cero
        Blaze_JavelinCleanup(i);
        g_iBlazeDashFxRef[i]   = 0;   // v2.2: las entidades murieron con el
        g_iBlazeDashFxRef2[i]  = 0;   // v2.4: idem, capa pies
        g_iBlazeJavFxRef[i]    = 0;   // mapa — solo soltar los refs
        g_fBlazeNextWallFx[i]  = 0.0;
        g_fBlazeSol[i] = 0.0;
        g_iBlazeChargeKind[i] = 0;
        g_bBlazeKickFly[i] = false;
        g_bBlazeDrainDash[i] = false;
        g_bBlazeExpell[i] = false;
        g_fBlazeSolDashWin[i] = 0.0;
        g_bBlazeDashLived[i] = false;
        g_iBlazeForceAnim[i] = -1;
        g_fBlazeKickDashCd[i] = 0.0;
        g_fBlazeJavFlameCd[i] = 0.0;
        g_fBlazeIframeUntil[i] = 0.0;
        g_bBlazeLaggedZero[i] = false;
        g_bBlazeTintOn[i] = false;
    }
}

// =====================================================================
// v2.7-OM: EL ESTADO DE LA BARRA para el motor comun SBar (v3.77.81).
// La logica de la v2.6 llega INTACTA (frac, color por nivel, tags
// DRAIN/FLAME/MODO SOL/VACIA) — solo cambia QUIEN la dibuja: SBar.inc
// la pinta en lineas apiladas de 30 celdas (el "texto mas grande" del
// owner) y el despachador SBar_Resolve del manager la llama.
// =====================================================================
bool Blaze_BarState(int client)
{
    float mx = (g_cvBlazeMaxSol != null) ? g_cvBlazeMaxSol.FloatValue : 100.0;
    if (mx < 1.0) mx = 100.0;
    float sol = g_fBlazeSol[client];
    if (sol < 0.0) sol = 0.0;
    if (sol > mx) sol = mx;
    float pct = sol / mx;

    SBar_Clear();
    g_fSBarFrac = pct;
    g_iSBarNum  = RoundToFloor(sol);
    g_iSBarDen  = RoundToFloor(mx);
    strcopy(g_sSBarLabel, sizeof(g_sSBarLabel), "LLAMA SOL");

    bool empty = (sol < 0.5);   // por debajo de medio punto = 0 real
    if (empty)              g_bSBarBlink = true;                          // VACIA: rojo-gris
    else if (pct >= 0.5)  { g_iSBarChatColor = SBAR_CHAT_GREEN;   }   // MODO SOL listo — chat: AMARILLO L4D2 (fuego)
    else if (pct >= 0.2)  { g_iSBarChatColor = SBAR_CHAT_LIGHTGR; }   // medio — chat: verde claro
    else                  { g_iSBarChatColor = SBAR_CHAT_OLIVE;   }   // bajo — chat: oliva (quedando poco)

    if (g_bBlazeDrainDash[client])   strcopy(g_sSBarTag, sizeof(g_sSBarTag), "DRAIN!");
    else if (g_bBlazeExpell[client]) strcopy(g_sSBarTag, sizeof(g_sSBarTag), "FLAME!");
    else if (Blaze_SolMode(client))  strcopy(g_sSBarTag, sizeof(g_sSBarTag), "MODO SOL");
    else                             g_sSBarTag[0] = '\0';
    if (empty)
    {
        int n2 = strlen(g_sSBarTag);
        if (n2 > 0) Format(g_sSBarTag[n2], sizeof(g_sSBarTag) - n2, "  VACIA!");
        else        strcopy(g_sSBarTag, sizeof(g_sSBarTag), "VACIA!");
    }
    return true;
}

// =====================================================================
// v2.1-OM: LINEA DEL PANEL DE ESTADOS — el manager 3.77.72 la pinta en
// el KeyHintText SIEMPRE VISIBLE (pedido del owner: "cuanta llama de
// blaze lleva acumulada y cosas asi"). Muestra el meter SOL, el modo
// activo y los cooldowns Z/X tal como los vive el jugador.
// =====================================================================
void Blaze_HUDLine(int client, char[] out, int maxlen, float now)
{
    int n = 0;
    float mx = (g_cvBlazeMaxSol != null) ? g_cvBlazeMaxSol.FloatValue : 100.0;
    bool sol = Blaze_SolMode(client);

    n += Format(out[n], maxlen - n, "BLAZE  LLAMA SOL %d/%d%s",
                RoundToFloor(g_fBlazeSol[client]), RoundToFloor(mx),
                sol ? "  [MODO SOL]" : "");
    if (g_bBlazeExpell[client] && n < maxlen - 24)
        n += Format(out[n], maxlen - n, "  [SOL FLAME!]");
    if (g_bBlazeDrainDash[client] && n < maxlen - 20)
        n += Format(out[n], maxlen - n, "  [DRAIN DASH!]");

    if (n < maxlen - 40)
    {
        n += Format(out[n], maxlen - n, "\nZ %s: ",
                    (GetEntityFlags(client) & FL_ONGROUND) != 0 ? "Kick" : "Sol Dash");
        if (now < g_fBlazeKickDashCd[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fBlazeKickDashCd[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTA");
    }
    if (n < maxlen - 40)
    {
        n += Format(out[n], maxlen - n, "\nX %s: ", sol ? "Sol Flame" : "Javelin");
        if (now < g_fBlazeJavFlameCd[client])
            n += Format(out[n], maxlen - n, "%.1fs", g_fBlazeJavFlameCd[client] - now);
        else
            n += Format(out[n], maxlen - n, "LISTA");
    }
    if (n < maxlen - 56)
        n += Format(out[n], maxlen - n, "\nPasiva: iframes al usar habilidades");
}
