/*
 * =====================================================================
 *  [MODULO] KOLOSSOS — El Coloso de OutComeMemories v2.2-OM
 *  PERSONAJE 14 DEL SUITE (KOLOSSOS_INDEX 13)
 *
 *  Port directo de "Lua de OM de Gmod/autorun/include/killer/
 *  noodles_om_pills_killer_kolossos.lua" (by noodles) — el killer
 *  colosal del pack OM pills, traido a L4D2 como personaje jugable.
 *
 *  v2.2 (manager 3.77.107) — EL STUN NATIVO + LA ROCA QUE SALE + LOS
 *  M1 PRECACHEADOS. Reporte del owner con la v2.1 en vivo: [R1] la
 *  consola escupe "SV_StartSound: om/kolossos/kol m1 (1).wav not
 *  precached (0)" (y el (2)) en cada basico; [R2] "cuando kolosos
 *  este stuneado (stagger agarrado o demas (ya sabes los stun
 *  posibles de L4d2) el reproducira su animacion de stuneado y el
 *  sonido (esta en los lua de Gmod)"; [R3] "la piedra todavia no
 *  sale?... el stun de cerca esta bn pero el objeto que debe
 *  lanzarle al enemigo no aparece aun".
 *  FIXES: [R1] los 4 "kol m1 (N).wav" se chequeaban SOLO con el (1)
 *  y NINGUNO se precacheaba (la linea simplemente no existia en el
 *  bloque de precache) — ahora cada archivo se comprueba y se
 *  precachea POR SEPARADO y el M1 elige al azar SOLO entre los que
 *  existen (si el pack trae 2, suena uno de esos 2); [R2] EL STUN
 *  NATIVO DE L4D2: los mismos 5 punteros de control que rompe el
 *  bloqueo (m_pounceAttacker/m_tongueOwner/m_carryAttacker/
 *  m_pummelAttacker/m_jockeyAttacker) + la ventana que marcan los
 *  forwards del manager (L4D2_OnStagger / L4D_OnKnockedDown — el
 *  stagger y el tumbon que el bloqueo NO absorbe) + el OM_IsStunned
 *  de siempre: con cualquiera de ellos la FSM pasa a KOL_ST_STUN (la
 *  seq "stun" del ShouldAlternate del Lua) y el FLANCO de entrada
 *  suena con uno de los 4 "kol stun N (1).wav" del Lua l.1520-1523
 *  (al EMPEZAR el stun, nunca durante — mismo criterio GMod);
 *  [R3] LA ROCA: rockgranite03b.mdl es un modelo de HL2 que L4D2 NO
 *  trae — el FileExists daba false y SpawnCounterRock salia en
 *  silencio: NI roca NI dano, solo la anim (por eso "todavia no
 *  sale" desde la v1.9). Ahora la CADENA de Silver v2.0: la del GMod
 *  si esta montada -> el chunk de Amy (concrete_chunk01a, probado en
 *  este server) -> la gascan nativa de L4D2; escala por
 *  m_flModelScale (la receta de la bola de Knuckles / esfera de
 *  Rouge — el KV "modelscale" no aplica en prop_physics_override) +
 *  grupo de colision DEBRIS (solo mundo: igual que el MOVETYPE_NONE
 *  del Lua, la roca del GMod no empuja a nadie — el dano lo hace el
 *  barrido del vuelo) + si la cadena quedara vacia (imposible con la
 *  gascan nativa) el counter a distancia NO se queda en nada: la
 *  detonacion cae DIRECTO sobre el atacante. sm_kolossos reporta el
 *  modelo activo de la roca y cuantos wavs de stun hay.
 *
 *  v2.1 (manager 3.77.106) — LA WITCH COLGADA + LA PUERTA DEL COMBO +
 *  EL BLOQUEO QUE DETECTA ESTADOS + LA ROCA LANZA. Reporte del owner
 *  con la v2.0 en vivo: la lluvia de "Data field m_hMoveParent is not
 *  an integer (13)" en cada fin de avalancha + "la witch tiene una
 *  interaccion extrana su ragdoll no es llevada y cuando la lleva
 *  literalmente no aparece despues de soltarla" + "aunque los golpes
 *  tienen un time el juego sigue tomando la pulsacion como golpes
 *  fuera de los 3 permitidos" + el rebalanceo (punos 550 + 1.75% de
 *  la vida actual, basicos 350-450, stun del bloqueo +2s) + "ahora
 *  podra detectar estados al instante... charger hunter smoker y
 *  jockey... y el anti stagger del tank... y un arreglo a la roca de
 *  kolossos usara el mismo tipo de roca... siguiendo las pautas de la
 *  habilidad original de como esta la lanza. esta roca producira el
 *  stun ragdoll al impactar".
 *  FIXES: [1] m_hMoveParent es un EHANDLE: el GetEntProp crudo de
 *  Kolossos_FlingHitList reventaba con excepcion en CADA victima
 *  entidad del fling final (commons arrastrados), el abort cortaba
 *  ChargeEnd ANTES del "= IDLE" de ultima linea y el FSM re-llamaba
 *  ChargeEnd cada tick = el spam del log + commons parentados para
 *  siempre. Va GetEntPropEnt (como el resto del file) y la SALIDA del
 *  estado sube a lo PRIMERO de ChargeEnd (anti-wedge para siempre);
 *  [2] LA WITCH: parentar la entidad witch viva la vuelve INVISIBLE
 *  en L4D2 (el motor no la recupera al soltarla) — JAMAS se parenta:
 *  viaja como RAGDOLL DOBLE (prop_ragdoll con su modelo, pineado por
 *  frame a la mano del marker, sacudida por puno) igual que los
 *  especiales, la original RENDER_NONE + FL_FROZEN (la estatua del
 *  suite) + colision fantasma, y al soltarla/lanzarla revive DONDE
 *  QUEDO el doble (follow congruente 10 Hz); si muere agarrada el
 *  doble queda de cadaver y ella vuelve a verse. La embestida TAMPOCO
 *  la parenta (solo commons arrastrados); [3] LA PUERTA DEL COMBO:
 *  el M1/Z durante el agarre no pasaba por NINGUN gate (3 clicks en 3
 *  frames = combo entero + punos extra re-triggereando la anim y
 *  re-agendando el lanzamiento) — ahora sin cargas no hay puno y
 *  entre punos tiene que pasar KOL_PUNCH_GATE (0.45s, la mitad del
 *  anim); [4] REBALANCEO: punos 550 (kolossos_grab_punchdamage) +
 *  kolossos_grab_punchhpdmg 1.75% de la vida ACTUAL, basicos 350-450
 *  (kolossos_m1_damage/_max), KOL_CNT_STUN 2.5 -> 4.5s (+2s el stun
 *  del bloqueo); [5] ESTADOS AL INSTANTE: ramas Kolossos en los
 *  forwards reales (lengua/carry/slam en Knuckles.inc, pounce/jockey
 *  en sonic.inc, garra del tank en el TankClaw del manager — contra
 *  inmediata + Handled) + Kolossos_BlockStateThink cada frame rompe
 *  los punteros de control (m_pounceAttacker/m_jockeyAttacker/
 *  m_carryAttacker/m_pummelAttacker a -1, receta T_KnuxHardStop)
 *  cuando un control ya estaba agarrado al apretar B + LA VENTANA
 *  ANTI-EMPUJE (Kolossos_BlockGuard: 1.5s tras el counter, ningun
 *  fling/knockdown/stagger del motor lo mueve — el anti stagger del
 *  tank, receta Knuckles con el clavado MOVETYPE_NONE 0.2s);
 *  [6] LA ROCA ESTILO LANZA: vuelo RECTO por direccion guardada (la
 *  receta del javelin de Blaze v2.5) con hitbox de segmento barrido
 *  (v2.8), pared por trace del segmento, tope 2.5s, y al impactar
 *  STUN-RAGDOLL del TIEMPO DEL COUNTER MELEE (KOL_CNT_STUN) con el
 *  doble volando + follow (los especiales que sobreviven salen en
 *  ragdoll stun, "el mismo tiempo de stun que el original que hace a
 *  melee"). CERO FX tocados.
 *
 *  v1.8 (manager 3.77.103) — LA VICTIMA PEGADA AL BRAZO. Reporte
 *  del owner con la v1.7.1 en vivo (el compilo el .mdl y el grab se
 *  ve): "la animacion de grab esta bn no te negare eso PERO el cuerpo
 *  del enemigo deberia estar pegado al brazo en si, no en donde la
 *  camara este viendo, y deberia estar orientado mas que todo a donde
 *  mire kolossos no el survivor invisible... el brazo espina que
 *  tiene, o sea el derecho, este mas ubicado, no este tan separado:
 *  el original se veia mejor, solo que se veia el mirando hacia
 *  arriba — lo unico que debias hacer era bajar la orientacion hacia
 *  abajo... el resto de la animacion podia seguir igual xq ya era
 *  perfecta asi (solo añadiendo la animacion de correr obviamente)" +
 *  "el Grab el agarre inicial no esta funcionando, sigue aun haciendo
 *  la animacion de correr pero no de agarrar".
 *  FORENSE FINAL DEL MATERIAL DEL GRAB (Scripts, hueso por hueso,
 *  raw + deltas + fusionados): TODO esta a <=1.6 grados de la pose de
 *  referencia — los clips del grab del .mdl original NO traen pose
 *  (ni brazos ni torso: los deltas del addlayer estan vacios a ±1.5
 *  grados y traian el mismo Root volteado). CONSECUENCIA: el look del
 *  GMod NUNCA fue animacion de brazo — era la VICTIMA parentada a la
 *  mano por el Lua ("ragdoll pegado a la mano derecha"), tal como el
 *  owner lo describio sin saberlo ("el brazo como en si no se puede
 *  mover"). El "agarre inicial" que faltaba era el SNAP de la victima
 *  al brazo, no un clip.
 *  FIX: [1] modelo v1.5.2 — $attachment "grabhand" hueso RightHand
 *  (la unica linea nueva del QC; los 56 SMD intactos); [2] plugin —
 *  Kolossos_GrabVictimGlue: SetParent al avatar (la copia R = verdad
 *  de mundo, NO el survivor invisible) + SetParentAttachment
 *  "grabhand" (snap a la mano animada) + tilt afinable en vivo
 *  (kolossos_grab_tilt, default -35 = "bajar la orientacion hacia
 *  abajo"); [3] GrabHoldThink — pegada al brazo re-assert por tick
 *  (sobrevive re-montajes), fallback al offset v1.7 si no hay parent;
 *  [4] GrabRelease — despegarla ANTES del fling (con parent el avatar
 *  la clavaria y no volaria). Cadena: attachment (mdl v1.5.2) >
 *  parent-follow (mdl viejo: sigue a Kolossos) > offset v1.7.
 *
 *  v1.7 (manager 3.77.102) — VEREDICTO FINAL DE LAS CAPAS + FIX DEL
 *  VOLTEO DEL AGARRE. Reporte del owner con la v1.6.1 en vivo:
 *  "host commentary_dummy pero sigue sin hacer las animaciones
 *  correctamente... cuando agarra el cuerpo de kolossos queda
 *  volteado al lado inverso, la mitad del cuerpo que deberia
 *  controlar el overlay... al caminar no aparecen las 2 animaciones
 *  a la vez".
 *  [1] VEREDICTO DE LAS CAPAS (definitivo, en vivo): la sonda
 *  multi-forma de la v1.6.1 consiguio el host perfecto
 *  (commentary_dummy vivo + nuestro modelo) y el canal NO EXISTE:
 *  m_AnimOverlay=no m_animLayers=no en TODAS las formas — L4D2 NO
 *  networka el array de capas de NINGUNA entidad tipo prop (a
 *  diferencia de TF2/CS:GO/GMod). El dummy hereda la CLASE overlay
 *  pero sin send table no hay nada que el cliente pueda ver: ni
 *  netprops ni SDKCall lo arreglan. El motor de capas queda RETIRADO
 *  del camino de ejecucion (LayersActive() siempre false; la sonda
 *  vive como diagnostico y ahora SIEMPRE pruebea el player para
 *  completar la matriz de sm_kolossos). LA VIA REAL DEL PORT ES Y
 *  ERA LA FUSION: las 12 compuestas del pack v1.5.
 *  [2] FIX DEL VOLTEO (forense SMD hueso por hueso): los 4 gestures
 *  del grab (Grab/GrabIdle/GrabPunch/GrabThrow) traen el hueso Root
 *  con un roll extra de -90 grados en TODOS los frames (euler
 *  (90,0,-90) vs referencia (90,0,0)). En GMod eran capas con
 *  weightlist (Root peso 0 = enmascarado, invisible); como
 *  secuencia MAIN el Root SE APLICA y el cuerpo entero gira de lado
 *  — el "volteado al lado inverso". FIX DOBLE: (a) pack v1.5.1 con
 *  el Root neutralizado en los 4 SMD + la carpeta de compilacion
 *  COMPLETA (cuerpo + fisica + 56 SMD: nada que mezclar con archivos
 *  locales del usuario); (b) el plugin JAMAS pone un gesture crudo
 *  como main: sin fusion el agarre queda en LOCOMOCION PURA (la
 *  victima en vilo delante es la senal) y los one-shots solo
 *  disparan compuestas nativas. Las 12 compuestas ya estaban
 *  limpias (su Root viene de la locomocion) — verificado hueso por
 *  hueso. El Kill sigue igual (su Root ya venia limpio).
 *  [3] LA VICTIMA DONDE LA MANO: forense del GrabIdle — la mano
 *  derecha sujeta a 38u delante y 72 de alto (model space); el agarre
 *  viejo la ponia a 55u delante y 12 de alto = arrastrada a la altura
 *  de las rodillas ("el agarre se comporta raro"). KOL_GRAB_HOLD
 *  38/62: cuelga justo debajo de la mano que la sostiene.
 *  Cadena final: FUSION v1.5.1 (12 compuestas) > locomocion pura
 *  (sin modelo recompilado NUNCA mas gestures crudos como main).
 *  CERO FX tocados.
 *
 *  v1.6.1 (manager 3.77.101) — FIX DEL HOST: EL DUMMY NUNCA LLEGO A
 *  SER HOST PORQUE LO MATAMOS NOSOTROS. Reporte del owner con la v1.6
 *  en vivo: "Capas: no disponibles | host prop_dynamic_override | 0
 *  slots" — caia al prop SIEMPRE. AUTOPSIA: la verificacion v1.6 del
 *  host exigia resolver el canal de capas con UNA sola forma de
 *  nombrarlo ("m_animLayers.m_nSequence" / "m_AnimOverlay.m_nSequence")
 *  y esa forma NO es como el nucleo de SourceMod direcciona un array
 *  de datatables: leido el fuente del core (HalfLife2.cpp,
 *  UTIL_FindInSendTable) — las props "inside array" (los elementos
 *  crudos del array) las SALTA, y la unica ruta es la punteada con el
 *  indice del elemento DENTRO del nombre
 *  ("m_AnimOverlay.001.m_nSequence", el formato del sm_dump_netprops).
 *  La forma v1.6 no existia para NADIE: el dummy perfecto spawnneaba,
 *  pasaba vivo y con nuestro modelo... y lo killabamos por un check
 *  imposible. FIXES: [1] el host ya NO depende del canal — dummy si
 *  spawnnea vivo y con NUESTRO modelo (las capas las decide la sonda
 *  aparte) + reason codes granulares (clase no registrada / murio al
 *  spawnear / rechazo el modelo y cual quedo) reportados en sm_kolossos;
 *  [2] SONDA MULTI-FORMA: 2 tablas (m_AnimOverlay / m_animLayers) x 3
 *  formas (%03d punteada / sin pad / element con test de bounds) — gana
 *  la primera que resuelva Y se deje escribir el slot 2 (write/read/
 *  restore de m_nSequence + m_flCycle); [3] matriz de descubrimiento en
 *  sm_kolossos ("CanalCapas: host ... | player ...") — el oraculo del
 *  debug: si el player resuelve y el host no, el host no networka
 *  overlay; si ninguno, es la version del SM; [4] ActivateEntity tras
 *  el spawn (receta de los clones de emotes). Mismo fallback (fusion
 *  v1.5 > monocapa v1.3) y CERO FX tocados.
 *
 *  v1.6 (manager 3.77.100) — LAS CAPAS REALES POR COMMENTARY_DUMMY.
 *  El owner remato la investigacion (hilo de AlliedMods + pagina
 *  oficial de Valve): en L4D2 NINGUN prop soporta m_AnimOverlay
 *  (prop_dynamic/physics/static heredan de CBaseAnimating a secas),
 *  PERO commentary_dummy — el muneco del modo comentario — SI hereda
 *  de CBaseAnimatingOverlay: CCommentaryDummy -> CBaseCombatCharacter
 *  -> CBaseFlex -> CBaseAnimatingOverlay -> CBaseAnimating ->
 *  CBaseEntity. Es la UNICA entidad "spawnable como un prop" de L4D2
 *  con el array de capas networkado (m_animLayers[15]) y ademas trae
 *  keyvalue "model", input "SetAnimation" por nombre, "StartingAnim"
 *  y hasta "StartingWeapons" (documentacion oficial de Valve).
 *  EL TRUCO: el avatar espejo se monta en un COMMENTARY_DUMMY en vez
 *  de un prop_dynamic_override (auto-verificado tras el spawn: modelo
 *  propio puesto + canal de capas presente; si la fabrica lo rechaza
 *  o se rompe solo, cae al prop clasico SIN romper nada). El motor de
 *  capas de la v1.4 VUELVE COMPLETO y ahora tiene donde vivir: pose
 *  GrabIdle sostenida en la CAPA 1 (el ACT_HOVER del GMod) + reach /
 *  puno / lanzamiento como one-shots en la CAPA 2 (ciclo empujado por
 *  el server per-tick), mientras el main queda en PURA locomocion —
 *  brazos y piernas INDEPENDIENTES, el sistema exacto del GMod y de
 *  los survivors al cambiar arma. La sonda probea AMBOS nombres de
 *  tabla (m_animLayers / m_AnimOverlay) y sm_kolossos reporta host +
 *  slots + tabla encontrada. Cadena de fallback completa: CAPAS
 *  REALES > fusion v1.5 (12 compuestas) > monocapa v1.3 — misma
 *  duracion y prioridad en los tres mundos. El .mdl NO cambia: las
 *  capas usan las secuencias Grab* ORIGINALES del modelo actual (ya
 *  autoradas como gestures: weightlist weights_swing, brazos=1 y lo
 *  demas=0). CERO FX tocados.
 *
 *  v1.5 (manager 3.77.99) — LA SERIE GRAB FUSIONADA: "hay que resolver
 *  el tema de las capas". Reporte del owner con la v1.4 en vivo:
 *  "Capas: NO DISPONIBLES (fallback monocapa) (slots 0)" — la sonda de
 *  m_AnimOverlay por netprop NO pasa en L4D2. VEREDICTO TECNICO (probado
 *  contra el engine y confirmado por la sonda en vivo): en L4D2 la
 *  animacion de entidades la computa el CLIENTE (CSkeletonInstance) y
 *  m_AnimOverlay NO viaja en la tabla de red de un prop (a diferencia de
 *  TF2/GMod) — NO existe canal por el que un plugin le diga al cliente
 *  "pon esta seq en un layer de ese prop". Las capas que cita Google
 *  existen de verdad, pero para PLAYERS (el engine las computa
 *  client-side: el Tank lanza rocas con los brazos mientras camina) y
 *  para models de Valve compilados con $gesture. La via REAL de L4D2
 *  (la que usan los mods con models animados): SECUENCIAS COMPUESTAS
 *  pre-fusionadas en el .mdl — piernas de la locomocion + brazos de la
 *  serie grab en UNA sola secuencia, generadas con el weightlist
 *  "weights_swing" del kolossos.qc (el modelo SI estaba bien compilado
 *  para capas: huesos de brazo a 1, todo lo demas a 0 — lo que faltaba
 *  era el canal, y ese no existe en L4D2 para props). El pack v1.5 trae
 *  los 12 SMD fusionados (idle/walk/run x hold/reach/punch/throw,
 *  generados por scripts/fusion_smd_kolossos.py del repo) + el
 *  kolossos.qc listo para recompilar con Crowbar (misma $modelname:
 *  drop-in). El plugin los usa por SONDA: si el .mdl los trae, la FSM
 *  con victima en vilo pasa a *_hold (PIERNAS ANDANDO con los brazos
 *  sujetando — exactamente lo que pedia el owner) y los one-shots
 *  eligen *_reach, *_punch o *_throw segun la locomocion del instante (el
 *  LANZAMIENTO sigue siendo KOL_SHOT_MAX de duracion completa); si el
 *  modelo es el viejo, la cadena de fallbacks cae a la monocapa v1.3
 *  SIN ROMPER NADA. El motor m_AnimOverlay de la v1.4 sale completo
 *  (0 slots en la realidad = codigo muerto fuera) y el convar
 *  kolossos_grab_layers queda como el switch de la fusion.
 *
 *  v1.4 (manager 3.77.98) — LAS CAPAS DEL GRAB + AGARRAR ESPECIALES
 *  (reporte del owner tras probar la v1.3: "la animacion grab nunca se
 *  logra apresiar es pisoteada por la animacion de caminar" y "No agarra
 *  a especiales (al tank no lo agarra. tampoco)"; "la animacion por
 *  capas si es compatible con l4d2, por que no se le esta aplicando?").
 *  RAIZ del bug 1 (el kolossos.qc del zip del owner lo confirma): las
 *  secuencias Grab/GrabIdle/GrabPunch/GrabThrow estan compiladas con
 *  weightlist "weights_swing" (SOLO animan los 15 huesos de brazos) +
 *  addlayer delta de torso + fps 60 — fueron autoradas EXCLUSIVAMENTE
 *  como gestures de CAPA (el AddGesture del GMod las reproduce asi:
 *  brazos encima de la locomocion, piernas vivas). Ponerlas como
 *  secuencia PRINCIPAL del prop (motor monocapa v1.3) deja los huesos
 *  peso-0 en pose de referencia = un vistazo de nada "pisoteado por
 *  caminar". FIX: MOTOR DE CAPAS REAL — m_AnimOverlay (L4D2 lo lleva en
 *  CBaseAnimating, compatible con props): slot 1 = pose GrabIdle
 *  sostenida (ACT_HOVER), slot 2 = reach/puño/lanzamiento (one-shots de
 *  duracion COMPLETA), SOBRE la locomocion main (walk/run/idle) — las
 *  PIERNAS SIGUEN ANDANDO mientras los brazos agarran, exactamente el
 *  sistema de los survivors al cambiar arma que pedia el owner. Sonda
 *  HasEntProp + GetEntPropArraySize por mapa, convar
 *  kolossos_grab_layers (1 = capas auto, 0 = fallback monocapa v1.3),
 *  driver per-tick del m_flCycle y duraciones corregidas al fps 60 REAL
 *  del QC (reach 0.52s / puño 0.85s / lanzamiento 1.02s — v1.3 asumía
 *  30fps: el doble). FIX del bug 2: el tank estaba EXPLICITAMENTE
 *  excluido en la v1.0 ("demasiado grande para el puño") y los demas
 *  especiales perdian contra cualquier comun en la esfera (los commons
 *  se chequeaban primero con return): ahora los ESPECIALES tienen
 *  PRIORIDAD (se chequean primero, el mas cercano), el TANK entra por
 *  convar kolossos_grab_tank (default 1) y la WITCH por
 *  kolossos_grab_witch (default 1, via movetype como los commons).
 *
 *  v1.3 (manager 3.77.97) — LAS ANIMACIONES DEL GRAB (reporte del
 *  owner con los SMD decompilados del .mdl: "faltaron las animaciones
 *  de grab; la del lanzamiento debe ser PRIORITARIA y durar lo que
 *  debe durar; las grab son de solo torso y las piernas tienen que
 *  seguir andando, como los survivors cuando cambian arma"). Analisis
 *  de los SMD: Grab 31f / GrabPunch 51f / GrabThrow 61f animan SOLO
 *  brazos+torso (cero piernas) y GrabIdle es una pose de 1 frame — en
 *  GMod son GESTURES (ACT_HOVER sostiene, ACT_DISARM lanza cortado a
 *  0.9s con fade, MELEE_ATTACK2 puÿea) sobre la locomocion base. El
 *  prop de L4D2 es MONOCAPA (sin overlay), asi que la serie se cablea
 *  con la regla "las piernas nunca se congelan": [a] KOL_ST_GRABREACH
 *  al enganchar (el reach, one-shot), [b] KOL_ST_GRABHOLD plantado
 *  (pose GrabIdle) y WALK en el suelo moviÿendose / JUMP-FALL en el
 *  aire (la locomocion MANDA sobre la pose mientras haya movimiento),
 *  [c] KOL_ST_GRABPUNCH por puÿo, [d] KOL_ST_GRABTHROW al lanzar:
 *  prioridad MAXIMA (KOL_SHOT_MAX: ni el stun ni otra acciÿn la
 *  cortan) y DURACION COMPLETA medida EN VIVO contra el .mdl real
 *  (calibrador m_flCycle con prop desechable — el fps del .mdl no es
 *  30: el Kill del Lua dura 1.65s con 276 frames) + la victima sale
 *  volando a +0.3s del arranque (GMod l.2154). El combo 3er puÿo ->
 *  lanzamiento queda encadenado (GMod l.2617: duration+1.75).
 *
 *  v1.2 (manager 3.77.96) — FIX "AL ELEGIRLO NO SALE EL AVATAR"
 *  (reporte del owner tras probar la v1.1): la FSM de 10 Hz llevaba
 *  TIMER_FLAG_NO_MAPCHANGE pero se creaba UNA SOLA VEZ en
 *  OnPluginStart — al primer cambio de mapa el timer moria y NUNCA se
 *  re-creaba: sin T_KolossosThink no hay montaje (Kolossos_CreateAvatar
 *  SOLO la llama la FSM), no hay auto-reparacion de la copia L y no hay
 *  tick del kit (avalancha/agarre/bloqueo/indicator). Por eso la v1.0
 *  parecia funcionar (se probO en el primer mapa tras instalar) y en el
 *  mapa 2+ el coloso ya no salia. Receta canon del suite (Rouge v10 /
 *  Blaze v2.11 / Silver v2.0): re-crear el timer en OnMapStart + nuevo
 *  Kolossos_OnMapEnd que suelta el handle mientras sigue vivo (la
 *  leccion del "crash del capitulo 2" del manager v3.30). FIX
 *  secundario incluido: el ref de la copia R ahora se asigna ANTES de
 *  crear la L (CreateAvatarL valida que la R exista; en v1.0/v1.1 la L
 *  nacia solo por la auto-reparacion 0.1s tarde, con el cuerpo ya en
 *  RENDER_NONE = una decima de invisibilidad total en cada montaje).
 *
 *  v1.1 (manager 3.77.95) — LAS ANIMACIONES COMPLETAS + EL FIX DEL
 *  DOBLADO, reporte del owner: "Las animaciones de kolossos faltaron" y
 *  "si yo muevo la camara el personaje se dobla a mirar, un error viejo
 *  de cuando probabamos a Tails". [1] FIX DOBLADO: la copia L (la que
 *  ve el dueño) ahora contra-rota contra los EYE angles (receta Tails
 *  v5.17-B / Blaze — el bug v5.4 "cuerpo inclinado con la mira" era
 *  exactamente este): SU cliente arma el parent con el cuerpo PREDICHO
 *  = camara completa, y cancelando el pitch de la mirada el coloso
 *  queda vertical SIEMPRE en su pantalla, ergido tambien al pausar.
 *  [2] ANIMS: la FSM pasa de 5 estados base a las 15 del registro del
 *  Lua: chargestart (windup), charge_notimpaled / Charge_impaled
 *  (avalancha segun HitList, rate 1.2 del animrates), BlockStart +
 *  BlockPos (bloqueo), BlockProjectile / BlackCounterMelee (counters
 *  segun distancia <300u), slaminwall (tope de pared con empalados,
 *  1.3s + Sound.mp3), Kill (ejecucion del agarre cuando un puo mata,
 *  1.65s + la risa a +1s), stun (ShouldAlternate), walk con la victima
 *  en vilo (run->walk) y paso a 3x durante el lunge del grab. Todas se
 *  resuelven por SONDA contra el .mdl real (SetAnimation + m_nSequence)
 *  con cadena de fallbacks: nunca T-pose aunque falte una secuencia.
 *
 *  SIN CUERPO CST (no existe un survivor model de Kolossos): el
 *  AVATAR ESPEJO (patron Blaze v2.11 / sonic.inc v6.30 — doble copia
 *  R/L + modo TP + pulso de pausa + FSM de animacion) se monta sobre
 *  el survivor que el jugador tenga puesto en ese momento. El modelo
 *  vive en kolossos_model (convar); sin el archivo el personaje
 *  funciona igual, solo sin espejo (g_bKolModelOK, patron Blaze).
 *
 *  KIT GMod (registro oficial om_survivors_register_noodles_kolossos):
 *   [Z] CHARGE    — windup 0.8s (suspiro -> rumble -> rugido) y
 *                   avalancha a velocidad de embestida que EMPALA a
 *                   todo lo que toca (esfera 90u): dano + extension
 *                   +3.75s por victima nueva; al terminar, las
 *                   victimas vivas salen VOLANDAS. Pared = tope seco
 *                   (Kol wall bump). CD 22s.
 *                   GMod: OUTCOMEMEMORIES_N_Kolosssos_Charge* (22/7/25/3.75).
 *                   Receta de movimiento: la del Destructive Charge de
 *                   Metal v5.0 — slot del stack (m_flMaxspeed) +
 *                   auto-forward del RunCmd (vel[0] saturado) + DEBRIS.
 *   [X] GRAB      — lunge 0.6s; el primer infectado de la esfera 90u
 *                   queda AGARRADO en vilo (max 10s): Z = puo (15),
 *                   3 puos y sale volando (kol sting and pull out);
 *                   X de nuevo lo suelta (kolossos_grab_cancel 0 = off,
 *                   default GMod). CD 25s (2s si la victima muere sola).
 *                   GMod: GrabCooldown 25 / PunchesLeft 3 / slamDamage 15.
 *   [C] INDICATOR — 5s de "peek": todos los infectados vivos en radio
 *                   llevan un glow rojo sobre la cabeza + ping cada 1s
 *                   (susurro al activar). CD 14s.
 *                   GMod: IndicatorDuration 5 / Cooldown 14 (wallhack).
 *   [B] BLOCK     — 3.5s inmune al dano de infectados (movimiento
 *                   bloqueado); el primer golpe que absorbe CONSUME el
 *                   bloqueo y dispara el CONTRAGOLPE: gira hacia el
 *                   atacante y le devuelve una ROCA en arco (granito
 *                   3x, 35 dano al tocar). CD 14s.
 *                   GMod: BlockDuration 3.5 / BlockProjectile + roca
 *                   rockgranite03b.mdl scale 3 del counter.
 *
 *  PASIVAS: vida max 670 (kolossos_health, receta Metal_ApplyMaxHealth,
 *  vuelta a 100 al dejar el personaje) + resistencia de dano
 *  (kolossos_resistance 100 = neutro; 50 = mitad de dano recibido).
 *  v1.9 (2026-10-21, reporte del owner con video de la v1.8 en vivo):
 *   [M1] EL PUO AL CLICK — "el ataque basico se deberia hacer con el
 *        click (orden de propio Gmod) pero click izq es disparar":
 *        mientras el arma activa es PRIMARIA o SECUNDARIA el IN_ATTACK
 *        se PISA (el arma no dispara) y el flanco del click = PUO
 *        basico (esfera 65u, 35, CD 1.65 = AttackCooldown del GMod) o
 *        puo al agarrado si hay victima. Granadas/botiquines/pastillas
 *        (slots 2/3/4) quedan INTACTOS: su click izq sigue normal.
 *   [GRAB-RAGDOLL] la victima agarrada ahora es un RAGDOLL DE VERDAD:
 *        doble prop_ragdoll congelado por parent al attachment
 *        "grabhand" (la receta Amy/Sonic: original oculto RENDER_NONE +
 *        restauracion vigilada), cada puo SACUDE el cuerpo (unpin +
 *        impulso + re-pin), y al LANZARLA el doble sale volando con
 *        impulso por hueso (Sonic_RagPhysLaunch) mientras el original
 *        oculto LO SIGUE tick a tick (congruencia: los bots y el dano
 *        le pegan donde esta el ragdoll) y revive DONDE CAYO — "al
 *        tirar al enemigo estos quedan en ragdoll", tal cual el GMod.
 *        FIX de fondo del "agarro mas de una vez": la v1.8 re-assertaba
 *        parent+tilt por tick sobre la victima VIVA (el engine suelta
 *        parents de players a cada rato -> re-snap visible = la
 *        animacion del agarre repetida); ahora la victima ni tiene
 *        parent: la arrastra el teleport congruente y el parent vive
 *        en el RAGDOLL (una entidad prop: parent estable de verdad).
 *   [CHARGE-CARRY] la embestida LLEVA POR DELANTE (Lua l.1785-1957):
 *        los especiales enganchados van ocultos con su doble pegado
 *        DELANTE del coloso (fwd*40+up*40, el pin del Lua) y los
 *        comunes van arrastrados VISIBLES parentados al avatar; al
 *        tope de pared o al terminar, todos salen volando (los dobles
 *        con impulso por hueso + follow congruente).
 *   [COUNTER] el bloqueo ahora contrarresta ataques de INFECTADOS
 *        ESPECIALES y sus habilidades (tongue del smoker, acido de la
 *        spitter, roca del tank — todo lo que venga de un cliente team
 *        3), PERO commons y witch NO cuentan (siguen absorvidos sin
 *        disparar contra). Respuesta melee (<300u): el ATACANTE sale
 *        en RAGDOLL stun volando (Sonic_SpawnFlingRagdollEx — "el
 *        counter lanza al enemigo en estado ragdoll"). Respuesta
 *        roca (>=300u o fuente smoker/spitter/tank_rock): la ROCA DE
 *        TANK reforzada (75 de dano + 1s de stun al area — "mucho mas
 *        fuerte que la del propio tank").
 *  v2.0 (2026-10-22, reporte del owner con la v1.9 en vivo) — EL PIN
 *  GMOD DE VERDAD + EL SWING FUSIONADO + LA LISTA + EL ARMA CALLADA.
 *   [P1] "el ragdoll no queda aderido al brazo de kolossos mientras
 *        este lo lleva y cuando grab el cuerpo aparece cuando da el
 *        golpe luego desaparece... y cuando uso la embestida el ragdoll
 *        se va hasta el fondo del mapa, el cuerpo real se queda en el
 *        sitio invisible": AUTOPSIA — la v1.9 colgaba el doble con
 *        SetParent + SetParentAttachment, pero un prop_ragdoll con
 *        vphysics DESPIERTO contra un padre que se mueve es dinamita:
 *        la fisica pelea el parent (cuerpo deformado/invisible en el
 *        agarre lento) y a 750 u/s (embestida) acumula velocidad
 *        fantasma hasta que sale DISPARADO al fondo del mapa. El Lua
 *        original NUNCA parenta: su shoulddocustomfunction corre CADA
 *        TICK y hace headPhys:SetPos(mano) + SetAngles +
 *        SetVelocityInstantaneous(vector_origin) (l.2160-2169 grab,
 *        l.1899-1905 carry). FIX = LA RECETA LITERAL:
 *        sonic.inc v6.38 Sonic_RagPhysPin (SDKCall SetPosition +
 *        velocidad CERO sobre el hueso RAIZ, indices contados del
 *        vphysics_interface.h l4d2) llamado POR FRAME desde
 *        T_Kol_LayerThink (timer 0.0 = cada tick) — cero SetParent
 *        sobre el doble, el resto del cuerpo cuelga por fisica (el
 *        look "limp" del GMod) y la velocidad fantasma NUNCA se
 *        acumula. La mano se lee de un info_target pegado al
 *        attachment "grabhand" (m_vecAbsOrigin por frame). Plan B sin
 *        SDKCall: TeleportEntity con velocidad cero (la via engine).
 *        [b] el original oculto de la embestida ahora SIGUE al doble
 *        (VictRagThink 10 Hz, el follow congruente que ya hacia el
 *        grab) — antes se quedaba congelado en el sitio del impacto.
 *   [P2] "la animacion de los ataques el usa la animacion swing es la
 *        animacion que faltaba que fusionaras con caminar y correr":
 *        el M1 basico del GMod es ACT_MELEE_ATTACK_SWING_GESTURE
 *        (l.2638), NO el GrabPunch. Forense SMD: swing.smd trae los
 *        brazos de verdad (RightLowerArm 137°, RightUpperArm 84°) y
 *        swingsub.smd es el swing COMPLETO (brazos identicos a swing
 *        + torso 80° + cabeza 71° — el delta del addlayer ya
 *        aplicado). Fusion 13-15: walk_swing / run_swing /
 *        idle_swing = piernas+Root+LowerTorso de la locomocion +
 *        brazos+UpperTorso+Head+ojos de swingsub (pack v1.5.3, 23
 *        frames @ 60fps = 0.38s). Sin recompilar, el M1 cae a la
 *        serie punch de la v1.9 (fallback en cadena).
 *   [P3] "el grab_ragdoll no aparece en la lista": los 35 kolossos_*
 *        (y con ellos TODOS los blaze_* y silver_*) NO entraban a
 *        g_sSuitePrefixes del manager = jamas se auto-guardaban en
 *        Sonic_Suite.cfg. Fix manager 3.77.105: prefijos + 3 secciones
 *        nuevas (BLAZE / SILVER / KOLOSSOS, en el orden del menu).
 *   [P4] "el arma aun sigue visualmente disparando aunque no gasta
 *        balas ni hace dano": el pisado del IN_ATTACK mataba el
 *        disparo del SERVER, pero la PREDICCION del cliente ya habia
 *        dibujado el fogonazo. Fix: mientras el arma activa es slot
 *        0/1 se le congela m_flNextPrimaryAttack (campo networkado Y
 *        predicado: el cliente tampoco predice el disparo = cero
 *        fogonazo, cero retroceso visual). Recarga intacta (no se
 *        toca durante m_bInReload); granadas/botiquin/pastillas siguen
 *        normales.
 *  NO portado: el Climb de paredes (posible v2.1).
 *
 *  SONIDOS: sound/om/kolossos/ (27 wavs del killer) copiados del addon GMod. Cada uno se chequea con FileExists: sin el archivo
 *  cae al fallback nativo HL2/L4D2 (patron g_bMetalSnd* de Metal.inc)
 *  — CERO dependencia dura.
 *
 *  INTEGRACION (manager 3.77.94): MAX_CHARS 14, KOLOSSOS_INDEX 13,
 *  fila de binds Z/X/C + B (precedente Rouge), dispatcher de las 4
 *  habilidades, OnPlayerRunCmd (auto-forward del charge),
 *  CleanupCharModuleState y banner sm_sjsver. ESTE modulo se auto-
 *  engancha sus eventos (player_spawn/player_death/round_start) —
 *  cero cableado extra en el manager.
 *
 *  CERO codigo FX de otros modulos tocado. Cero sistemas de bots.
 * =====================================================================
 */

#define KOLOSSOS_INC_VERSION "2.2-OM"   // v2.2: stun nativo L4D2 + roca con cadena de modelo + M1 precacheados (2.1 nunca se anoto aqui: la macro quedo en 2.0)

// ------------------------- CONSTANTES KIT ---------------------------
// (defaults = registro oficial GMod om_survivors_register_noodles_kolossos;
//  velocidad L4D2 calibrada al Destructive Charge de Metal v5.0: 750)
#define KOL_SND_LEVEL              87      // GMod: soundLevel 87 del killer
#define KOL_CHG_WINDUP_T          0.8     // chargestart_Kolossos = +0.8s (duracion del windup)
#define KOL_CHG_WINDUP_SIGH        0.15    // kol sigh i think.wav
#define KOL_CHG_WINDUP_RUMBLE      0.35    // kol charge start ground rumble
#define KOL_CHG_WINDUP_ROAR        0.75    // KolossosChargeRoar.wav
#define KOL_CHG_LAUNCH_MIN         300.0   // impulso de arranque (min)
#define KOL_CHG_FOV                105     // camara abierta (receta Metal)
#define KOL_CHG_COLGROUP           2       // DEBRIS durante la avalancha
#define KOL_CHG_STUCK_TIME         0.6     // watchdog: <80 u/s este tiempo = tope
#define KOL_CHG_STUCK_MINVEL       80.0
#define KOL_CHG_FLING_FWD          500.0   // lanzamiento de victimas al final
#define KOL_CHG_FLING_UP           300.0
#define KOL_GRAB_HOLD_DIST         38.0    // v1.7: la mano del GrabIdle sujeta a 38u delante (forense SMD)
#define KOL_GRAB_HOLD_Z            62.0    // v1.7: y a ~72 de alto — la victima cuelga debajo de la mano
#define KOL_GRAB_FLING_FWD         500.0
#define KOL_GRAB_FLING_UP          300.0
#define KOL_GRAB_FLING_DELAY       0.3     // v1.3: GMod l.2154 — la victima vuela a +0.3s del arranque del throw
#define KOL_GRAB_THROW_AT          1.4     // v1.3: 3er puo -> lanzamiento encadenado (GMod duration+1.75 con la anim de por medio)

// v1.3: prioridades del one-shot (un disparo nuevo solo pisa al activo
// si su prioridad es igual o mayor — el LANZAMIENTO no lo corta nadie)
#define KOL_SHOT_ACT               1       // counters / blockstart / slaminwall
#define KOL_SHOT_GRAB              2       // grab reach / puo
#define KOL_SHOT_MAX               3       // Kill / GrabThrow — prioridad total

// v1.4: fallbacks fps 60 del QC del owner (kolossos.qc: TODAS las grab
// van a fps 60, no 30 — Grab 31f/60 = 0.52s, GrabPunch 51f/60 = 0.85s,
// GrabThrow 61f/60 = 1.02s; v1.3 asumía 30fps = el doble de largo)
#define KOL_DUR_GRABREACH          0.52    // Grab.smd 31 frames @ 60fps
#define KOL_DUR_GRABPUNCH          0.85    // GrabPunch.smd 51 frames @ 60fps
#define KOL_DUR_GRABTHROW          1.02    // GrabThrow.smd 61 frames @ 60fps

// v2.0: el SWING del M1 — swing.smd 23 frames @ 60fps = 0.383s de barrido
// (la duracion exacta del clip; el GMod le ponia fade desde 0.15s y
// quitaba la capa a 0.9s, pero el MOVIMIENTO son estos 23 frames)
#define KOL_DUR_SWING              0.38

// v2.0: EL PIN — el doble cuelga con la RAIZ (pelvis) un poco DEBAJO de
// la mano: el cuerpo se lee colgando del puño (el GMod clavaba el HUESO
// CABEZA a la mano; la raiz es el hueso siempre presente y sondado del
// motor v6.33 — mismo look, ancla al centro de masa)
#define KOL_RAG_HANG_Z             25.0
#define KOL_HANDMARK_NAME  "kol_grabhand_om"   // info_target pegado al attachment

// v1.6: slots del MOTOR DE CAPAS REALES (m_animLayers) — el avatar se
// monta en commentary_dummy, la UNICA entidad "tipo prop" de L4D2 cuya
// clase hereda de CBaseAnimatingOverlay (jerarquia oficial de Valve:
// CCommentaryDummy -> CBaseCombatCharacter -> CBaseFlex ->
// CBaseAnimatingOverlay -> CBaseAnimating). Slot 1 = pose GrabIdle
// sostenida (el ACT_HOVER del GMod), slot 2 = los one-shots de la serie
// (reach / puno / lanzamiento). El 0 queda libre.
#define KOL_LAYER_HOLD             1       // pose de sujetar (ACT_HOVER)
#define KOL_LAYER_SHOT             2       // one-shots de la serie grab
#define KOL_LAYER_MIN_SIZE         3       // hacen falta >= 3 slots
#define KOL_EF_NOSHADOW            (1<<10) // EF_NOSHADOW del SDK (no esta en los includes SM)

// v1.6.1: formas de direccionar un elemento del array de capas. En la
// tabla de red el overlay viaja como m_AnimOverlay[15] (array de
// datatables CAnimationLayer) y el nucleo de SM SALTA las props "inside
// array" — la ruta viable es la PUNTEADA con el indice del elemento
// dentro del nombre (el formato del sm_dump_netprops). La sonda prueba
// las 3 formas y gana la primera que resuelva y se deje escribir el
// slot 2. La forma ELEMENT (la unica que conocia la v1.6) queda de
// ultimo candidato: si el path baja por el primer elemento, el leaf
// ve solo 1 elemento y el parametro no alcanza los slots 1/2.
#define KOL_LAY_FORM_PAD3          0       // "m_AnimOverlay.001.m_nSequence" (%03d — la del dump)
#define KOL_LAY_FORM_PLAIN         1       // "m_AnimOverlay.1.m_nSequence"   (sin pad)
#define KOL_LAY_FORM_ELEMENT       2       // "m_AnimOverlay.m_nSequence" + parametro element

// v1.5: LA SERIE FUSIONADA — el fallback intermedio cuando no hay canal
// de capas (avatar en prop_dynamic): las 12 secuencias compuestas del
// .mdl v1.5 (piernas de locomocion + brazos del grab en una sola seq,
// generadas del weightlist weights_swing del kolossos.qc). Sin
// recompilar el modelo todo cae a la monocapa v1.3 sin romper nada.
#define KOL_IND_PING_EVERY         1.0     // heartbeat del indicator
#define KOL_ROCK_LIFETIME          3.0     // la roca muere sola si no toca nada
#define KOL_ROCK_ARC_TIME          0.5     // GMod: travelTime 0.5 (LEGADO v1.9: la roca ya vuela recta estilo lanza)
#define KOL_ROCK_ARC_PEAK          150.0   // GMod: peakHeight 150 (LEGADO v1.9)
#define KOL_ROCK_TOUCH_RADIUS      100.0   // AoE del impacto de la roca
#define KOL_ROCK_SPEED             2200.0  // v2.1: vuelo RECTO de la roca (estilo lanza/javelin)
#define KOL_ROCK_FLIGHT_MAX        2.5     // v2.1: tope de vuelo de la roca (s)
#define KOL_ROCK_CATCH_RADIUS      90.0    // v2.1: radio de caza del segmento barrido
#define KOL_ROCK_SPAWN_FWD         25.0    // v2.1: nace al frente del pecho del coloso
#define KOL_ROCK_SPAWN_UP          55.0    // v2.1: ...y a la altura del puno
// v2.2: el grupo de colision DEBRIS del motor (enum Collision_Group:
// 1 = DEBRIS = solo choca con el mundo) — no viene en los includes
// core del SM 1.12 y es el equivalente exacto del MOVETYPE_NONE del
// Lua l.1458: la roca del GMod atraviesa sin empujar a nadie
#define KOL_ROCK_COLGROUP          1
#define KOL_COUNTER_SAFE           1.5     // v2.1: ventana anti-empuje tras el counter (fling/knockdown/stagger fuera)
#define KOL_PUNCH_GATE             0.45    // v2.1: ritmo minimo entre punos del combo (la mitad del anim 0.85)
#define KOL_WITCH_RAG_FLY_MAX      3.25    // v2.1: vuelo maximo del doble de la witch antes de restaurarla
#define KOL_DASH_VEL_INJECT        900.0   // vel[0] saturado (receta Metal)
#define KOL_MAXENT                 2048    // sprites del indicator (por indice)

// v1.9: EL SISTEMA DE RAGDOLLS DEL GRAB/CARRY/COUNTER (receta Sonic
// v6.33/Amy v106: doble prop_ragdoll + original oculto + follow
// congruente + restauracion vigilada)
#define KOL_RAG_PIN_DELAY          0.25    // beat de fisica antes de parentar (el doble se desploma y ESE es el pose)
#define KOL_RAG_JOLT_UP            260.0   // sacudida del cuerpo por puo (unpin + impulso)
#define KOL_RAG_JOLT_REPIN         0.40    // ...y re-pin tras el golpe
#define KOL_RAG_THROW_FWD          700.0   // lanzamiento del doble (GMod l.2153: fwd*700)
#define KOL_RAG_THROW_LIFT         0.45    // fraccion extra en Z del lanzamiento
#define KOL_RAG_THROW_TUMBLE       700.0   // giro por hueso
#define KOL_RAG_THROW_STUN         2.5     // la victima queda tirada (stun) hasta restaurar
#define KOL_RAG_RESTORE_Z          12.0    // nace/restaura despegada del piso
#define KOL_CHG_CARRY_F            40.0    // Lua l.1902: el doble delante del coloso fwd*40
#define KOL_CHG_CARRY_U            40.0    // ...y up*40 (el pin del carry del GMod)
#define KOL_CNT_FLING              700.0   // counter melee: el atacante vuela (GMod 3000 escalado)
#define KOL_CNT_LIFT               0.55    // fraccion Z del counter
#define KOL_CNT_TUMBLE             900.0   // giro por hueso del counter
#define KOL_CNT_STUN               4.5     // stun del atacante countered (v2.1: 2.5 + 2s — pedido del owner: "el bloqueo su aturdimiento durara 2 seg mas")
#define KOL_M1_CD                  1.65    // GMod l.2664: AttackCooldown del M1
#define KOL_M1_RANGE               65.0    // esfera del puo basico (hull frontal del charge)

// modos del registro de victimas con ragdoll (g_iKolVictRagMode)
#define KOL_RAGMODE_NONE           0
#define KOL_RAGMODE_GRABPIN        1       // doble clavado a la mano del avatar (agarre)
#define KOL_RAGMODE_CHARGEPIN      2       // doble clavado DELANTE del avatar (embestida)
#define KOL_RAGMODE_FLIGHT         3       // doble volando: el original lo sigue (congruencia) y revive donde cae

// ------------------------- ESTADOS ----------------------------------
#define KOL_CHG_IDLE               0
#define KOL_CHG_WINDUP             1
#define KOL_CHG_DASH               2

// FSM de animacion del avatar — v1.1: EL REGISTRO COMPLETO del killer Lua.
// anims.default (L134-145): idle/run/walk/jump(jump2)/fall(glide)/
// slaminwall/BlockStart/BlackCounterMelee/BlockProjectile/Kill.
// ShouldAlternate (L322-395): stun/climb/BlockPos/chargestart/
// charge_notimpaled/Charge_impaled (+run->walk con victima en vilo).
// animrates (L404-439): charge 1.2 | lunge del grab 3 | run base 1.05.
#define KOL_ST_IDLE                0
#define KOL_ST_WALK                1
#define KOL_ST_RUN                 2
#define KOL_ST_JUMP                3
#define KOL_ST_FALL                4
#define KOL_ST_STUN                5    // ShouldAlternate: stun
#define KOL_ST_CHARGESTART         6    // windup de la avalancha
#define KOL_ST_CHARGE              7    // avalancha sin empalados
#define KOL_ST_CHARGE_IMP          8    // avalancha CON empalados
#define KOL_ST_BLOCKSTART          9    // arranque del bloqueo (one-shot)
#define KOL_ST_BLOCK               10   // pose de bloqueo (BlockPos)
#define KOL_ST_BLOCKPROJ           11   // counter a distancia (one-shot)
#define KOL_ST_COUNTER             12   // counter melee (one-shot)
#define KOL_ST_SLAMINWALL          13   // tope de pared con empalados (one-shot)
#define KOL_ST_KILL                14   // ejecucion del agarre (one-shot)
#define KOL_ST_GRABREACH           15   // v1.3: el reach al enganchar la victima (one-shot)
#define KOL_ST_GRABHOLD            16   // v1.3: plantado sujetando (pose GrabIdle)
#define KOL_ST_GRABPUNCH           17   // v1.3: puo al agarrado (one-shot)
#define KOL_ST_GRABTHROW           18   // v1.3: EL LANZAMIENTO (one-shot prioridad maxima)
// v1.5: LA SERIE FUSIONADA — piernas Y brazos en una sola secuencia (el
// .mdl v1.5 recompilado las trae; sin ellas la cadena de fallbacks cae
// a la monocapa de arriba y el kit funciona igual)
#define KOL_ST_HOLD_WALK           19   // sujetando mientras camina (walk_hold, loop)
#define KOL_ST_HOLD_RUN            20   // sujetando mientras corre  (run_hold, loop)
#define KOL_ST_HOLD_IDLE           21   // sujetando plantado        (idle_hold, loop)
#define KOL_ST_REACH_WALK          22   // el reach enganchando mientras camina
#define KOL_ST_REACH_RUN           23   // el reach enganchando mientras corre
#define KOL_ST_REACH_IDLE          24   // el reach plantado
#define KOL_ST_PUNCH_WALK          25   // el puño mientras camina
#define KOL_ST_PUNCH_RUN           26   // el puño mientras corre
#define KOL_ST_PUNCH_IDLE          27   // el puño plantado
#define KOL_ST_THROW_WALK          28   // EL LANZAMIENTO mientras camina
#define KOL_ST_THROW_RUN           29   // EL LANZAMIENTO mientras corre
#define KOL_ST_THROW_IDLE          30   // EL LANZAMIENTO plantado
// v2.0: LA FUSION DEL SWING — el M1 basico (ACT_MELEE_ATTACK_SWING_GESTURE
// del Lua l.2638) con las piernas de la locomocion; brazos+torso del
// swingsub (pack v1.5.3). Sin ellas cae a la serie punch de la v1.9
#define KOL_ST_SWING_WALK          31   // el swing caminando
#define KOL_ST_SWING_RUN           32   // el swing corriendo
#define KOL_ST_SWING_IDLE          33   // el swing plantado
#define KOL_ST_COUNT               34

// ------------------------- CONVARS ----------------------------------
ConVar g_cvKolEnabled;
ConVar g_cvKolModel;
ConVar g_cvKolAvatar;
ConVar g_cvKolHealth;
ConVar g_cvKolResist;
ConVar g_cvKolChgSpeed;
ConVar g_cvKolChgDur;
ConVar g_cvKolChgMaxDur;
ConVar g_cvKolChgDmg;
ConVar g_cvKolChgAdd;
ConVar g_cvKolChgCd;
ConVar g_cvKolChgRadius;
ConVar g_cvKolGrabCd;
ConVar g_cvKolGrabWindow;
ConVar g_cvKolGrabHold;
ConVar g_cvKolGrabPunches;
ConVar g_cvKolGrabPunchDmg;
ConVar g_cvKolGrabCancel;
ConVar g_cvKolGrabLayers;                       // v1.4: motor de capas del grab
ConVar g_cvKolGrabTilt;                        // v1.8: pitch de la victima pegada a la mano (el "bajar la orientacion")
ConVar g_cvKolGrabTank;                         // v1.4: agarrar al tank
ConVar g_cvKolGrabWitch;                        // v1.4: agarrar a la witch
ConVar g_cvKolIndCd;
ConVar g_cvKolIndDur;
ConVar g_cvKolIndRadius;
ConVar g_cvKolBlockCd;
ConVar g_cvKolBlockDur;
ConVar g_cvKolRockDmg;
ConVar g_cvKolRockScale;
ConVar g_cvKolRockStun;    // v1.9: stun al area del impacto de la roca
ConVar g_cvKolM1;          // v1.9: click izq = puo (slots 0/1 pisados)
ConVar g_cvKolM1Dmg;       // v2.1: dano MINIMO del puo basico (el max: kolossos_m1_damage_max)
ConVar g_cvKolM1DmgMax;    // v2.1: dano MAXIMO del puo basico (tirada aleatoria 350-450)
ConVar g_cvKolGrabRag;     // v1.9: la victima del grab viaja como ragdoll
ConVar g_cvKolChgCarry;    // v1.9: la embestida lleva por delante
ConVar g_cvKolCntRag;      // v1.9: el counter manda al atacante en ragdoll
ConVar g_cvKolGrabHpDmg;   // v2.1: % de la vida ACTUAL del agarrado que cada puno quita (1.75)

// ------------------------- ESTADO POR JUGADOR -----------------------
int    g_iKolChargeState[MAXPLAYERS + 1];   // KOL_CHG_*
float  g_fKolChargeEnd[MAXPLAYERS + 1];     // fin del DASH (extensible)
float  g_fKolChargeCdUntil[MAXPLAYERS + 1];
float  g_fKolWindupStart[MAXPLAYERS + 1];
float  g_fKolStuckSince[MAXPLAYERS + 1];
int    g_iKolSavedColGroup[MAXPLAYERS + 1]; // DEBRIS enter/exit
ArrayList g_hKolHitList[MAXPLAYERS + 1];    // EntRefs empalados (fling final)

int    g_iKolGrabVictim[MAXPLAYERS + 1];    // EntRef del agarrado
int    g_iKolGrabPunches[MAXPLAYERS + 1];
int    g_iKolGrabMoveType[MAXPLAYERS + 1];  // movetype a restaurar (commons)
float  g_fKolLungeUntil[MAXPLAYERS + 1];    // ventana del lunge 0.6s
float  g_fKolGrabHoldEnd[MAXPLAYERS + 1];   // max 10s en vilo
float  g_fKolGrabCdUntil[MAXPLAYERS + 1];
bool   g_bKolGrabLunged[MAXPLAYERS + 1];    // el impulso del lunge ya salio

// v2.1: LA WITCH VIAJA COMO RAGDOLL — la v1.8 pegaba la witch VIVA con
// SetParent+SetParentAttachment y el motor la volvia INVISIBLE (el bug
// del owner: "cuando la lleva literalmente no aparece despues de
// soltarla"): la witch ya no se parenta NUNCA — viaja con su DOBLE
// prop_ragdoll pineado a la mano (la misma receta de los clientes) y la
// original queda RENDER_NONE + FL_FROZEN hasta soltarla. Registro por
// AGARRADOR (solo hay una witch agarrada por Kolossos a la vez).
int    g_iKolWitchRag[MAXPLAYERS + 1];        // EntRef del doble de la witch agarrada
int    g_iKolWitchRagVictim[MAXPLAYERS + 1];  // EntRef de la WITCH agarrada (vive mas que el grab)
int    g_iKolWitchRagRender[MAXPLAYERS + 1];  // render original de la witch
int    g_iKolWitchRagCol[MAXPLAYERS + 1];     // collision group original
bool   g_bKolWitchRagJolt[MAXPLAYERS + 1];    // sacudida del puno en curso
float  g_fKolWitchRagRepinAt[MAXPLAYERS + 1]; // fin de la pausa de la sacudida
float  g_fKolWitchRagPinDelay[MAXPLAYERS + 1];// beat de fisica del spawn
bool   g_bKolWitchRagFlying[MAXPLAYERS + 1];  // lanzada: el doble vuela y la original lo sigue
float  g_fKolWitchRagFlyEnd[MAXPLAYERS + 1];  // fin del vuelo (restauracion donde caiga)
bool   g_bKolGrabIsWitch[MAXPLAYERS + 1];     // v2.1: el agarrado actual es la witch

// v2.1: LA PUERTA DEL COMBO — el spam del boton ya no fabrica golpes
// fuera de los 3 permitidos (el M1 durante el agarre no pasaba por NINGUN
// cooldown: 3 clicks en 3 frames = combo entero + punos extra re-triggereando
// la anim y re-agendando el lanzamiento)
float  g_fKolGrabNextPunchAt[MAXPLAYERS + 1]; // v2.1: proximo puno permitido

// v2.1: LA ROCA ESTILO LANZA — vuelo RECTO por direccion (la receta del
// javelin de Blaze v2.5/v2.8: cero arco balistico, hitbox = segmento
// recorrido del tick, tope de vuelo) + detonacion en stun-ragdoll. Y la
// ventana ANTI-EMPUJE del counter (la receta Knuckles: el tank no puede
// empujar a Kolossos mientras contraataca).
int    g_iKolRockFlying[MAXPLAYERS + 1];      // EntRef de la roca en vuelo
float  g_fKolRockDieAt[MAXPLAYERS + 1];       // tope de vuelo de la roca
float  g_vKolRockDir[MAXPLAYERS + 1][3];      // direccion guardada al disparar
float  g_vKolRockPrev[MAXPLAYERS + 1][3];     // posicion del tick anterior (hitbox barrida)
float  g_fKolCounterSafeUntil[MAXPLAYERS + 1];// v2.1: anti-push del counter (fling/knockdown/stagger fuera)

float  g_fKolBlockUntil[MAXPLAYERS + 1];
float  g_fKolBlockCdUntil[MAXPLAYERS + 1];
bool   g_bKolBlockCountered[MAXPLAYERS + 1]; // el parry ya disparo la roca

float  g_fKolIndUntil[MAXPLAYERS + 1];
float  g_fKolIndCdUntil[MAXPLAYERS + 1];
float  g_fKolIndNextPing[MAXPLAYERS + 1];

// ------------------------- AVATAR ESPEJO ----------------------------
int    g_iKolAvatar[MAXPLAYERS + 1];        // EntRef copia R (0 = sin avatar)
int    g_iKolAvatarL[MAXPLAYERS + 1];       // EntRef copia L
int    g_iKolBodyRender[MAXPLAYERS + 1];    // render del cuerpo oculto
int    g_iKolAnimState[MAXPLAYERS + 1];
int    g_iKolAnimShotState[MAXPLAYERS + 1];  // v1.1: one-shot activo (-1 = ninguno)
float  g_fKolAnimShotUntil[MAXPLAYERS + 1];  // v1.1: fin del one-shot
int    g_iKolAnimShotTier[MAXPLAYERS + 1];   // v1.3: prioridad del one-shot activo (KOL_SHOT_*)
float  g_fKolGrabThrowAt[MAXPLAYERS + 1];    // v1.3: lanzamiento encadenado tras el 3er puo (0 = off)
int    g_iKolGrabFlingRef[MAXPLAYERS + 1];   // v1.3: victima del fling demorado (+0.3s, EntRef)
float  g_fKolSeqDur[KOL_ST_COUNT];           // v1.3: duraciones REALES medidas al .mdl (0 = fallback)

bool   g_bKolFusionOK = false;                // v1.5: el .mdl trae la serie fusionada (sonda por mapa)
bool   g_bKolFusedNative[KOL_ST_COUNT];       // v1.5: cada compuesta vino NATIVA en el .mdl (pre-fallback)

// ------------------------- v1.6: MOTOR DE CAPAS ---------------------
// El avatar commentary_dummy networka m_animLayers[15]: brazos del grab
// en CAPAS (slot 1 pose / slot 2 one-shots) con el main en locomocion.
int    g_iKolSeqIdx[KOL_ST_COUNT];            // INDICE de cada seq (las capas usan indice, no nombre)
bool   g_bKolLayersOK = false;                // la sonda paso: la tabla existe y se deja escribir
int    g_iKolLayerSize = 0;                   // slots disponibles (15 esperados)
bool   g_bKolDummyHost = false;                // el avatar de este mapa es commentary_dummy
char   g_sKolLayPrefix[20] = "m_AnimOverlay";  // tabla ganadora de la sonda (m_AnimOverlay / m_animLayers)
int    g_iKolLayForm = -1;                     // v1.6.1: forma ganadora (-1 = ninguna resolvio)
int    g_iKolDummyFail = 0;                    // v1.6.1: 0 = dummy OK o sin intentar; 1 clase, 2 murio, 3 modelo
char   g_sKolDummyFailInfo[PLATFORM_MAX_PATH]; // v1.6.1: detalle del fallo (p.ej. el modelo que quedo)
char   g_sKolLayDiagDummy[96];                 // v1.6.1: matriz de descubrimiento del canal (host)
char   g_sKolLayDiagPlayer[96];                // v1.6.1: idem en un player vivo (el oraculo)
int    g_iKolLayShotState[MAXPLAYERS + 1];    // one-shot de capa activo (-1 = ninguno)
float  g_fKolLayShotStart[MAXPLAYERS + 1];
float  g_fKolLayShotDur[MAXPLAYERS + 1];
bool   g_bKolLayHoldOn[MAXPLAYERS + 1];       // la pose de sujetar esta encendida
Handle g_hKolLayThink = null;                 // driver per-tick del m_flCycle de capas
bool   g_bKolCalibDone = false;              // v1.3: el calibrador ya corrio en este mapa
int    g_iKolCalibProp = INVALID_ENT_REFERENCE; // v1.3: prop desechable del calibrador
int    g_iKolCalibStage = 0;                 // v1.3: 0=reach 1=punch 2=throw
float  g_fKolCalibStart = 0.0;               // v1.3: arranque del stage actual
float  g_fKolCalibLastCycle = -1.0;          // v1.3: ultimo m_flCycle leido
float  g_fKolJumpStart[MAXPLAYERS + 1];
float  g_fKolBodyYaw[MAXPLAYERS + 1];
float  g_fKolYawLastT[MAXPLAYERS + 1];
float  g_fKolSmLoc[MAXPLAYERS + 1][3];
float  g_fKolSmLocL[MAXPLAYERS + 1][3];
bool   g_bKolSmSnap[MAXPLAYERS + 1];
bool   g_bKolWelcomeSaid[MAXPLAYERS + 1];
bool   g_bKolHooked[MAXPLAYERS + 1];      // OnTakeDamage enganchado (auto-gestion FSM)
bool   g_bKolHpApplied[MAXPLAYERS + 1];   // vida max aplicada en esta vida

// v1.9: REGISTRO DE RAGDOLLS POR VICTIMA (clientes SI): el doble + el
// original oculto + el modo. Un ragdoll por victima a la vez — el de
// Sonic (Sonic_SpawnFlingRagdollEx) para el counter (restauracion
// vigilada por su T_SonicStunWatch), el de aqui para grab/carry.
int    g_iKolVictRag[MAXPLAYERS + 1];        // EntRef del doble (0 = sin)
int    g_iKolVictRagMode[MAXPLAYERS + 1];    // KOL_RAGMODE_*
int    g_iKolVictRagOwner[MAXPLAYERS + 1];   // el Kolossos responsable
int    g_iKolVictRagRender[MAXPLAYERS + 1];  // render mode original de la victima
bool   g_bKolVictRagJolted[MAXPLAYERS + 1];  // sacudida en vuelo (re-pin pendiente)
float  g_fKolVictRagRepinAt[MAXPLAYERS + 1]; // hora del re-pin tras el jolt
float  g_fKolVictRagPinDelay[MAXPLAYERS + 1]; // hora del pin inicial (beat de fisica)
int    g_iKolLastButtons[MAXPLAYERS + 1];    // v1.9: flanco del M1 (edge del IN_ATTACK)
float  g_fKolM1CdUntil[MAXPLAYERS + 1];      // v1.9: CD del puo basico
int    g_iKolHandMark[MAXPLAYERS + 1];        // v2.0: EntRef del info_target de la MANO (pin por frame)

// ------------------------- ASSETS -----------------------------------
bool   g_bKolModelOK = false;              // kolossos.mdl montado (patron Blaze)
bool   g_bKolWarnedModel = false;
bool   g_bKolSeqsOK = false;
bool   g_bKolSeqOK[KOL_ST_COUNT];
char   g_sKolSeqName[KOL_ST_COUNT][24] = { "idle", "walk", "run", "jump", "fall",
                                            "idle", "idle", "run", "run", "idle",
                                            "idle", "idle", "idle", "idle", "idle",
                                            // v1.3: la serie del grab (defaults = nombres de los SMD)
                                            "Grab", "GrabIdle", "GrabPunch", "GrabThrow",
                                            // v1.5: la SERIE FUSIONADA (defaults = nombres del .qc v1.5)
                                            "walk_hold", "run_hold", "idle_hold",
                                            "walk_reach", "run_reach", "idle_reach",
                                            "walk_punch", "run_punch", "idle_punch",
                                            "walk_throw", "run_throw", "idle_throw",
                                            // v2.0: EL SWING DEL M1 (defaults = nombres del .qc v1.5.3)
                                            "walk_swing", "run_swing", "idle_swing" };

// sonidos del killer (sound/om/kolossos/) — fallback nativo si falta
bool   g_bKolSndSigh, g_bKolSndRumble, g_bKolSndRoar, g_bKolSndStartup;
bool   g_bKolSndImpacts, g_bKolSndLaugh, g_bKolSndWallBump;
bool   g_bKolSndGrabLunge, g_bKolSndGrabUse, g_bKolSndImpale;
bool   g_bKolSndPunch, g_bKolSndPullOut, g_bKolSndWhisper, g_bKolSndBlock;
bool   g_bKolSndPing;                      // om/metal/ping1.wav (ya del suite)
bool   g_bKolSndSlam;                       // v1.1: Sound.mp3 (slam con empalados)
bool   g_bKolSndLaughKill;                  // v1.1: Kolossos laughing.wav (Kill)
bool   g_bKolSndM1;                         // v1.9: kol m1 (1..4).wav (el basico de click)
char   g_sKolLaughPath[PLATFORM_MAX_PATH];  // v1.1: ruta real (carpeta Kolossos/kolossos)
bool   g_bKolRockModel = false;             // v2.2: la cadena resolvio un modelo de roca
// v2.2 [R1]: los 4 kol m1 REALES, uno por archivo — el pack puede traer
// menos de 4 y el FileExists solo miraba el (1): compactados aqui al
// arrancar el mapa (solo los que existen) para que el M1 elija al azar
// ENTRE LOS QUE HAY, todos ya precacheados (el bug del "not precached")
char   g_sKolM1Wavs[4][56];
int    g_iKolSndM1Count = 0;
// v2.2 [R2]: los 4 "kol stun N (1).wav" del Lua l.1520-1523 — suenan al
// ENTRAR en cualquier stun (nativo L4D2 o del suite), misma compactacion
char   g_sKolStunWavs[4][56];
int    g_iKolSndStunCount = 0;
// v2.2 [R2]: la ventana del stun NATIVO (stagger/knockdown marcados por
// los forwards del manager) + el flanco para el sonido de entrada
float  g_fKolNativeStunUntil[MAXPLAYERS + 1];
bool   g_bKolWasStunned[MAXPLAYERS + 1];
// v2.2 [R3]: el modelo ACTIVO de la roca (la cadena rockgranite03b ->
// chunk de Amy -> gascan nativa; vacio = cadena vacia, dano directo)
char   g_sKolRockModel[96];

// sprites del indicator: g_iKolIndSprite[entidx] = EntRef del glow
int    g_iKolIndSprite[KOL_MAXENT + 1];

// ------------------------- TIMER FSM --------------------------------
Handle g_hKolThink = null;                 // 10 Hz (patron T_BlazeAvatarThink)

// =====================================================================
//  UTILIDADES
// =====================================================================

bool Kolossos_PlayerIs(int client)
{
    if (client < 1 || client > MaxClients) return false;
    if (!IsClientInGame(client)) return false;
    return g_iPlayerCharIdx[client] == KOLOSSOS_INDEX;
}

bool Kolossos_Valid(int client)
{
    if (!Kolossos_PlayerIs(client)) return false;
    return (IsPlayerAlive(client) && GetClientTeam(client) == 2);
}

float Kolossos_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// la direccion de movimiento (receta Metal_GetMoveDir: mirar no frena)
void Kolossos_GetMoveDir(int client, float dir[3])
{
    float ang[3];
    GetClientEyeAngles(client, ang);
    dir[0] = Cosine(DegToRad(ang[1]));
    dir[1] = Sine(DegToRad(ang[1]));
    dir[2] = 0.0;
}

void Kolossos_Emit(int client, bool has, const char[] real, const char[] fallback)
{
    if (has) EmitSoundToAll(real, client, _, KOL_SND_LEVEL);
    else if (fallback[0] != '\0') EmitSoundToAll(fallback, client, _, KOL_SND_LEVEL);
}

// =====================================================================
//  CICLO DE VIDA DEL MODULO
// =====================================================================

public void Kolossos_OnPluginStart()
{
    g_cvKolEnabled     = CreateConVar("kolossos_enabled", "1", "Kolossos: personaje activo (0 = kit apagado)", 0, true, 0.0, true, 1.0);
    g_cvKolModel       = CreateConVar("kolossos_model", "models/noodles/om/kolossos.mdl", "Kolossos: ruta del .mdl del avatar espejo (sin archivo = sin avatar, kit sigue)");
    g_cvKolAvatar      = CreateConVar("kolossos_avatar", "1", "Kolossos: avatar espejo montado sobre el survivor actual (0 = solo kit)", 0, true, 0.0, true, 1.0);
    g_cvKolHealth      = CreateConVar("kolossos_health", "670", "Kolossos: vida maxima al elegirlo (GMod 670; 0 = sin cambio)", 0, true, 0.0);
    g_cvKolResist      = CreateConVar("kolossos_resistance", "100", "Kolossos: % de dano recibido (100 = neutro, 50 = mitad)", 0, true, 1.0, true, 1000.0);

    g_cvKolChgSpeed    = CreateConVar("kolossos_charge_speed", "750", "Kolossos [Z] Charge: velocidad uu/s de la avalancha (GMod 1400; calibracion L4D2 tipo Metal)", 0, true, 100.0, true, 1400.0);
    g_cvKolChgDur      = CreateConVar("kolossos_charge_duration", "7", "Kolossos [Z] Charge: duracion base en s (GMod 7)", 0, true, 1.0, true, 30.0);
    g_cvKolChgMaxDur   = CreateConVar("kolossos_charge_maxduration", "20", "Kolossos [Z] Charge: tope total con extensiones por empale (anti-horda infinita)", 0, true, 5.0, true, 60.0);
    g_cvKolChgDmg      = CreateConVar("kolossos_charge_damage", "25", "Kolossos [Z] Charge: dano de empale por victima (GMod 25)", 0, true, 1.0);
    g_cvKolChgAdd      = CreateConVar("kolossos_charge_impale_add", "3.75", "Kolossos [Z] Charge: s extra por victima nueva (GMod 3.75)", 0, true, 0.0, true, 10.0);
    g_cvKolChgCd       = CreateConVar("kolossos_charge_cooldown", "22", "Kolossos [Z] Charge: cooldown s (GMod 22)", 0, true, 1.0);
    g_cvKolChgRadius   = CreateConVar("kolossos_charge_radius", "90", "Kolossos [Z] Charge: radio de empale u (GMod 90)", 0, true, 30.0, true, 250.0);

    g_cvKolGrabCd      = CreateConVar("kolossos_grab_cooldown", "25", "Kolossos [X] Grab: cooldown s (GMod 25)", 0, true, 1.0);
    g_cvKolGrabWindow  = CreateConVar("kolossos_grab_window", "0.6", "Kolossos [X] Grab: ventana del lunge s (GMod 0.6)", 0, true, 0.1, true, 3.0);
    g_cvKolGrabHold    = CreateConVar("kolossos_grab_hold", "10", "Kolossos [X] Grab: max s con la victima en vilo (GMod 10)", 0, true, 1.0, true, 30.0);
    g_cvKolGrabPunches = CreateConVar("kolossos_grab_punches", "3", "Kolossos [X] Grab: puos antes del lanzamiento (GMod 3)", 0, true, 1.0, true, 10.0);
    g_cvKolGrabPunchDmg= CreateConVar("kolossos_grab_punchdamage", "550", "Kolossos [X] Grab: dano base por puo (v2.1: 550 — pedido del owner, antes 15; se suma kolossos_grab_punchhpdmg)", 0, true, 1.0);
    g_cvKolGrabHpDmg  = CreateConVar("kolossos_grab_punchhpdmg", "1.75", "Kolossos [X] Grab: % de la VIDA ACTUAL del agarrado que cada puo quita ademas del dano base (v2.1; 0 = solo el base)", 0, true, 0.0, true, 100.0);
    g_cvKolGrabCancel  = CreateConVar("kolossos_grab_cancel", "0", "Kolossos [X] Grab: X de nuevo suelta a la victima (GMod CanCancelGrab=0)", 0, true, 0.0, true, 1.0);
    // v1.6: el switch de la SERIE GRAB por CAPAS REALES — el avatar se
    // monta en commentary_dummy (la unica entidad tipo prop que hereda
    // de CBaseAnimatingOverlay): pose de sujetar en capa 1 + one-shots
    // en capa 2, piernas vivas en el main (el sistema del GMod). Si el
    // host cae a prop_dynamic: fusion v1.5; modelo viejo: monocapa v1.3.
    g_cvKolGrabLayers  = CreateConVar("kolossos_grab_layers", "1", "Kolossos [X] Grab: 1 = fusion v1.5 (12 compuestas del .mdl recompilado; sin ellas el agarre queda en locomocion pura — los gestures crudos traen el Root volteado y jamas van como main), 0 = locomocion pura siempre", 0, true, 0.0, true, 1.0);
    g_cvKolGrabTilt    = CreateConVar("kolossos_grab_tilt", "-35", "Kolossos [X] Grab: pitch en grados de la victima PEGADA a la mano (relativo al frame de la mano; -35 = mirando hacia abajo como el original que la llevaba mirando arriba; 0 = frame de la mano tal cual)", 0, true, -90.0, true, 90.0);
    g_cvKolGrabTank    = CreateConVar("kolossos_grab_tank", "1", "Kolossos [X] Grab: 1 = TAMBIEN agarra al tank (v1.4: el veto de la v1.0 fuera)", 0, true, 0.0, true, 1.0);
    g_cvKolGrabWitch   = CreateConVar("kolossos_grab_witch", "1", "Kolossos [X] Grab: 1 = tambien agarra a la witch", 0, true, 0.0, true, 1.0);

    g_cvKolIndCd       = CreateConVar("kolossos_indicator_cooldown", "14", "Kolossos [C] Indicator: cooldown s (GMod 14)", 0, true, 1.0);
    g_cvKolIndDur      = CreateConVar("kolossos_indicator_duration", "5", "Kolossos [C] Indicator: duracion s (GMod 5)", 0, true, 1.0, true, 30.0);
    g_cvKolIndRadius   = CreateConVar("kolossos_indicator_radius", "3000", "Kolossos [C] Indicator: radio de deteccion u (0 = todo el mapa)", 0, true, 0.0);

    g_cvKolBlockCd     = CreateConVar("kolossos_block_cooldown", "14", "Kolossos [B] Block: cooldown s (GMod 14)", 0, true, 1.0);
    g_cvKolBlockDur    = CreateConVar("kolossos_block_duration", "3.5", "Kolossos [B] Block: duracion s (GMod 3.5)", 0, true, 0.5, true, 10.0);
    g_cvKolRockDmg     = CreateConVar("kolossos_rock_damage", "75", "Kolossos [B] Block: dano de la roca del contragolpe (v1.9: 75 — 'mucho mas fuerte que la del propio tank', la del tank ~24)", 0, true, 1.0);
    g_cvKolRockScale   = CreateConVar("kolossos_rock_scale", "3", "Kolossos [B] Block: escala de la roca (GMod 3)", 0, true, 0.5, true, 6.0);
    g_cvKolRockStun    = CreateConVar("kolossos_rock_stun", "1", "Kolossos [B] Block: stun s al area del impacto de la roca (0 = solo dano)", 0, true, 0.0, true, 5.0);

    // v1.9: M1 al click + ragdolls + carry del counter/embestida
    g_cvKolM1          = CreateConVar("kolossos_m1", "1", "Kolossos: click izq con arma PRIMARIA/SECUNDARIA = PUO basico (el disparo queda pisado; granadas/botiquines/pastillas intactos)", 0, true, 0.0, true, 1.0);
    g_cvKolM1Dmg       = CreateConVar("kolossos_m1_damage", "350", "Kolossos [M1]: dano MINIMO del puo basico (v2.1: tirada aleatoria 350-450 con kolossos_m1_damage_max; antes 125)", 0, true, 1.0);
    g_cvKolM1DmgMax    = CreateConVar("kolossos_m1_damage_max", "450", "Kolossos [M1]: dano MAXIMO del puo basico (la tirada sale entre kolossos_m1_damage y este)", 0, true, 1.0);
    g_cvKolGrabRag     = CreateConVar("kolossos_grab_ragdoll", "1", "Kolossos [X] Grab: la victima viaja como RAGDOLL (doble ocultando al original, sacudida por puo, lanzamiento con follow congruente; 0 = pegado vivo v1.8)", 0, true, 0.0, true, 1.0);
    g_cvKolChgCarry    = CreateConVar("kolossos_charge_carry", "1", "Kolossos [Z] Charge: la embestida LLEVA POR DELANTE a quienes engancha (especiales como ragdoll delante, comunes arrastrados; Lua l.1785+)", 0, true, 0.0, true, 1.0);
    g_cvKolCntRag      = CreateConVar("kolossos_counter_ragdoll", "1", "Kolossos [B] Block: el counter melee manda al atacante en RAGDOLL stun volando (0 = solo el fling)", 0, true, 0.0, true, 1.0);

    RegConsoleCmd("sm_kolossos", Kolossos_CmdDebug, "Kolossos: estado del kit (debug)");

    HookEvent("player_spawn",   Kolossos_EventSpawn);
    HookEvent("player_death",   Kolossos_EventDeath);
    HookEvent("round_start",    Kolossos_EventRoundStart);

    for (int i = 1; i <= MaxClients; i++)
    {
        g_iKolSavedColGroup[i] = -1;
        g_iKolBodyRender[i]    = -1;
        g_iKolAnimState[i]     = -1;
        g_iKolAnimShotState[i] = -1;
        g_fKolAnimShotUntil[i] = 0.0;
        g_iKolGrabMoveType[i]  = -1;
        g_iKolGrabVictim[i]    = 0;
        g_hKolHitList[i]       = null;
        g_iKolLayShotState[i]  = -1;    // v1.6: sin one-shot de capa
        g_fKolLayShotStart[i]  = 0.0;
        g_fKolLayShotDur[i]    = 0.2;
        g_bKolLayHoldOn[i]     = false;
        // v1.9: registro de ragdolls + M1
        g_iKolVictRag[i]       = 0;
        g_iKolVictRagMode[i]   = KOL_RAGMODE_NONE;
        g_iKolVictRagOwner[i]  = 0;
        g_iKolVictRagRender[i] = -1;
        g_bKolVictRagJolted[i] = false;
        g_fKolVictRagRepinAt[i] = 0.0;
        g_fKolVictRagPinDelay[i] = 0.0;
        g_iKolLastButtons[i]   = 0;
        g_fKolM1CdUntil[i]     = 0.0;
        g_iKolHandMark[i]      = 0;    // v2.0: sin marcador de mano
    }
    for (int e = 0; e <= KOL_MAXENT; e++) g_iKolIndSprite[e] = 0;
    for (int s = 0; s < KOL_ST_COUNT; s++) g_iKolSeqIdx[s] = -1;   // v1.6

    delete g_hKolThink;
    g_hKolThink = CreateTimer(0.1, T_KolossosThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // v1.6: el driver per-tick de las capas — empuja el m_flCycle del
    // one-shot y re-afirma la pose de sujetar (el cliente NO avanza
    // overlays de entidades no-player: sin esto la capa quedaria clavada)
    delete g_hKolLayThink;
    g_hKolLayThink = CreateTimer(0.0, T_Kol_LayerThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void Kolossos_OnMapStart()
{
    // v1.2 FIX "AL ELEGIRLO NO SALE EL AVATAR" — la FSM de 10 Hz llevaba
    // TIMER_FLAG_NO_MAPCHANGE pero solo se creaba en OnPluginStart: al
    // primer cambio de mapa moria y ya nunca revivia (sin FSM no hay
    // montaje del avatar, ni auto-reparacion de la L, ni tick del kit).
    // Receta canon del suite (Rouge v10 L786 / Blaze v2.11 L755 / Silver
    // v2.0): re-crear el timer AQUI, en CADA arranque de mapa.
    delete g_hKolThink;
    g_hKolThink = CreateTimer(0.1, T_KolossosThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // v1.6: idem el driver de capas (misma receta v1.2: re-crear en CADA
    // arranque de mapa o muere para siempre)
    delete g_hKolLayThink;
    g_hKolLayThink = CreateTimer(0.0, T_Kol_LayerThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // modelo del avatar (patron Blaze g_bBlazeModelOK)
    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));
    g_bKolModelOK = (mdl[0] != '\0') && FileExists(mdl, true);
    if (g_bKolModelOK)
    {
        PrecacheModel(mdl, true);
        g_bKolSeqsOK = false;   // se resuelven al nacer el primer avatar
        g_bKolCalibDone = false;   // v1.3: las duraciones se miden de nuevo (prop nuevo)
        g_bKolFusionOK = false;    // v1.5: la sonda de fusion corre de nuevo
        g_bKolLayersOK = false;    // v1.6: la sonda de capas corre de nuevo
        g_iKolLayerSize = 0;
        g_bKolDummyHost = false;
        g_sKolLayPrefix[0] = '\0';
        g_iKolLayForm = -1;        // v1.6.1: la sonda multi-forma corre de nuevo
        g_iKolDummyFail = 0;       // v1.6.1: el veredicto del dummy se re-abre por mapa
        g_sKolDummyFailInfo[0] = '\0';
        g_sKolLayDiagDummy[0] = '\0';
        g_sKolLayDiagPlayer[0] = '\0';
        for (int s = 0; s < KOL_ST_COUNT; s++)
        {
            g_fKolSeqDur[s] = 0.0;
            g_iKolSeqIdx[s] = -1;   // v1.6: indices re-resueltos contra el .mdl
        }
    }
    else if (!g_bKolWarnedModel)
    {
        g_bKolWarnedModel = true;
        LogMessage("[Kolossos] Sin '%s' — avatar espejo OFF (el kit funciona igual). Copia el .mdl a esa ruta para activarlo.", mdl);
    }

    // v2.2 [R3]: LA CADENA DE LA ROCA — rockgranite03b.mdl es un modelo
    // de HL2 que L4D2 NO trae de fabrica: el FileExists crudo daba false
    // desde la v1.9 y SpawnCounterRock salia en silencio (sin roca y sin
    // dano — el "la piedra todavia no sale" del owner). Receta de la
    // cadena de Silver v2.0: la del GMod si esta montada -> el chunk de
    // concreto de Amy (probado en este server) -> la gascan nativa.
    {
        static const char sKolRockModels[][] = {
            "models/props_wasteland/rockgranite03b.mdl",   // la del Lua l.1451
            "models/props_debris/concrete_chunk01a.mdl",   // la de Amy (AMY_MODEL_CHUNK)
            "models/props_junk/gascan001a.mdl"             // nativa 100% L4D2
        };
        g_sKolRockModel[0] = '\0';
        g_bKolRockModel = false;
        for (int m = 0; m < sizeof(sKolRockModels); m++)
        {
            if (FileExists(sKolRockModels[m], true))
            {
                strcopy(g_sKolRockModel, sizeof(g_sKolRockModel), sKolRockModels[m]);
                PrecacheModel(g_sKolRockModel, true);
                g_bKolRockModel = true;
                break;
            }
        }
        if (!g_bKolRockModel)
            LogMessage("[Kolossos] Sin NINGUN modelo de roca (ni rockgranite03b ni concrete_chunk01a ni gascan001a) — el counter a distancia cae como dano directo sin roca visible.");
    }

    // sonidos del killer: carpeta om/kolossos del addon GMod + fallbacks nativos
    g_bKolSndSigh      = FileExists("sound/om/kolossos/kol sigh i think.wav", true);
    g_bKolSndRumble    = FileExists("sound/om/kolossos/kol charge start ground rumble.wav", true);
    g_bKolSndRoar      = FileExists("sound/om/kolossos/KolossosChargeRoar.wav", true);
    g_bKolSndStartup   = FileExists("sound/om/kolossos/StartUpCharge.wav", true);
    g_bKolSndImpacts   = FileExists("sound/om/kolossos/Kol impacts.wav", true);
    g_bKolSndLaugh     = FileExists("sound/om/kolossos/Kol charge laugh impale.wav", true);
    g_bKolSndWallBump  = FileExists("sound/om/kolossos/Kol wall bump.wav", true);
    // v2.2 [R1]: LOS 4 M1 DE VERDAD — el FileExists solo miraba el (1)
    // y NINGUNO se precacheaba: "SV_StartSound: om/kolossos/kol m1 (1).wav
    // not precached (0)" en cada basico. Cada archivo se comprueba, se
    // PRECACHEA y se compacta; el M1 elige al azar SOLO entre los que hay.
    {
        static const char sKolM1List[][] = {
            "om/kolossos/kol m1 (1).wav", "om/kolossos/kol m1 (2).wav",
            "om/kolossos/kol m1 (3).wav", "om/kolossos/kol m1 (4).wav"
        };
        g_iKolSndM1Count = 0;
        char sndPath[72];
        for (int w = 0; w < 4; w++)
        {
            Format(sndPath, sizeof(sndPath), "sound/%s", sKolM1List[w]);
            if (!FileExists(sndPath, true)) continue;
            strcopy(g_sKolM1Wavs[g_iKolSndM1Count], 56, sKolM1List[w]);
            PrecacheSound(sKolM1List[w], true);
            g_iKolSndM1Count++;
        }
        g_bKolSndM1 = (g_iKolSndM1Count > 0);
    }
    // v2.2 [R2]: LOS 4 STUN DEL LUA (l.1520-1523) — suenan al ENTRAR en
    // cualquier stun (los nativos de L4D2 y los del suite), misma receta
    {
        static const char sKolStunList[][] = {
            "om/kolossos/kol stun 1 (1).wav", "om/kolossos/kol stun 2 (1).wav",
            "om/kolossos/kol stun 3 (1).wav", "om/kolossos/kol stun 4 (1).wav"
        };
        g_iKolSndStunCount = 0;
        char stunPath[72];
        for (int w = 0; w < 4; w++)
        {
            Format(stunPath, sizeof(stunPath), "sound/%s", sKolStunList[w]);
            if (!FileExists(stunPath, true)) continue;
            strcopy(g_sKolStunWavs[g_iKolSndStunCount], 56, sKolStunList[w]);
            PrecacheSound(sKolStunList[w], true);
            g_iKolSndStunCount++;
        }
    }
    g_bKolSndGrabLunge = FileExists("sound/om/kolossos/kol grab lunge.wav", true);
    g_bKolSndGrabUse   = FileExists("sound/om/kolossos/Kol uses grab.wav", true);
    g_bKolSndImpale    = FileExists("sound/om/kolossos/Kol impales.wav", true);
    g_bKolSndPunch     = FileExists("sound/om/kolossos/kolossos punching.wav", true);
    g_bKolSndPullOut   = FileExists("sound/om/kolossos/kol sting and pull out.wav", true);
    g_bKolSndWhisper   = FileExists("sound/om/kolossos/kol whispers.wav", true);
    g_bKolSndBlock     = FileExists("sound/om/kolossos/kol block.wav", true);
    g_bKolSndPing      = FileExists("sound/om/metal/ping1.wav", true);   // ya lo usa Metal
    // v1.1: el slam con empalados ("Sound.mp3" literal del Lua l.1735) y
    // la risa de la ejecucion (carpeta con K mayuscula en el Lua l.1225:
    // "OM/Kolossos/Kolossos laughing.wav" — se prueban ambas mayusculas)
    g_bKolSndSlam      = FileExists("sound/om/kolossos/Sound.mp3", true);
    g_bKolSndLaughKill = (FileExists("sound/om/Kolossos/Kolossos laughing.wav", true)
                       || FileExists("sound/om/kolossos/Kolossos laughing.wav", true));
    g_sKolLaughPath[0] = '\0';
    if (g_bKolSndLaughKill)
    {
        if (FileExists("sound/om/Kolossos/Kolossos laughing.wav", true))
            strcopy(g_sKolLaughPath, PLATFORM_MAX_PATH, "om/Kolossos/Kolossos laughing.wav");
        else
            strcopy(g_sKolLaughPath, PLATFORM_MAX_PATH, "om/kolossos/Kolossos laughing.wav");
    }

    if (g_bKolSndSigh)      PrecacheSound("om/kolossos/kol sigh i think.wav", true);
    if (g_bKolSndRumble)    PrecacheSound("om/kolossos/kol charge start ground rumble.wav", true);
    if (g_bKolSndRoar)      PrecacheSound("om/kolossos/KolossosChargeRoar.wav", true);
    if (g_bKolSndStartup)   PrecacheSound("om/kolossos/StartUpCharge.wav", true);
    if (g_bKolSndImpacts)   PrecacheSound("om/kolossos/Kol impacts.wav", true);
    if (g_bKolSndLaugh)     PrecacheSound("om/kolossos/Kol charge laugh impale.wav", true);
    if (g_bKolSndWallBump)  PrecacheSound("om/kolossos/Kol wall bump.wav", true);
    if (g_bKolSndGrabLunge) PrecacheSound("om/kolossos/kol grab lunge.wav", true);
    if (g_bKolSndGrabUse)   PrecacheSound("om/kolossos/Kol uses grab.wav", true);
    if (g_bKolSndImpale)    PrecacheSound("om/kolossos/Kol impales.wav", true);
    if (g_bKolSndPunch)     PrecacheSound("om/kolossos/kolossos punching.wav", true);
    if (g_bKolSndPullOut)   PrecacheSound("om/kolossos/kol sting and pull out.wav", true);
    if (g_bKolSndWhisper)   PrecacheSound("om/kolossos/kol whispers.wav", true);
    if (g_bKolSndBlock)     PrecacheSound("om/kolossos/kol block.wav", true);
    if (g_bKolSndPing)      PrecacheSound("om/metal/ping1.wav", true);
    if (g_bKolSndSlam)      PrecacheSound("om/kolossos/Sound.mp3", true);
    if (g_bKolSndLaughKill) PrecacheSound(g_sKolLaughPath, true);

    g_bKolWarnedModel = false;   // avisa 1 vez por mapa si falta el modelo
}

// v1.2: la mitad que faltaba del ciclo de vida (patron Rouge_OnMapEnd /
// Blaze_OnMapEnd / Silver_OnMapEnd): soltar el handle del timer AQUI,
// mientras sigue vivo, para que el OnMapStart del mapa siguiente no
// herede un handle muerto (la leccion del "crash del capitulo 2" del
// manager v3.30) — y el estado del kit a cero porque las entidades
// (avatares, sprites del indicator, rocas) murieron con el mapa. La
// limpieza PROFUNDA del gameplay la hace round_start del mapa nuevo.
public void Kolossos_OnMapEnd()
{
    delete g_hKolThink;
    delete g_hKolLayThink;   // v1.6: idem el driver de capas

    // v1.6: el canal de capas se re-sonda en el mapa nuevo (host nuevo)
    g_bKolLayersOK  = false;
    g_iKolLayerSize = 0;
    g_bKolDummyHost = false;
    g_sKolLayPrefix[0] = '\0';
    g_iKolLayForm = -1;           // v1.6.1: sonda multi-forma de nuevo en el mapa nuevo
    g_iKolDummyFail = 0;
    g_sKolDummyFailInfo[0] = '\0';
    g_sKolLayDiagDummy[0] = '\0';
    g_sKolLayDiagPlayer[0] = '\0';

    // v1.3: el prop del calibrador y sus medidas mueren con el mapa
    int cp = EntRefToEntIndex(g_iKolCalibProp);
    if (cp > 0 && IsValidEntity(cp)) AcceptEntityInput(cp, "Kill");
    g_iKolCalibProp   = INVALID_ENT_REFERENCE;
    g_bKolCalibDone   = false;
    g_iKolCalibStage  = 0;
    g_fKolCalibStart  = 0.0;
    g_fKolCalibLastCycle = -1.0;
    for (int s = 0; s < KOL_ST_COUNT; s++) g_fKolSeqDur[s] = 0.0;

    for (int i = 1; i <= MaxClients; i++)
    {
        // avatares y anims: las entidades murieron con el mapa
        g_iKolAvatar[i]        = 0;
        g_iKolAvatarL[i]       = 0;
        g_iKolHandMark[i]      = 0;    // v2.0: el marcador de la mano murio con el mapa
        g_iKolAnimState[i]     = -1;
        g_iKolAnimShotState[i] = -1;
        g_fKolAnimShotUntil[i] = 0.0;
        g_iKolAnimShotTier[i]  = KOL_SHOT_ACT;
        g_fKolGrabThrowAt[i]   = 0.0;
        g_iKolGrabFlingRef[i]  = 0;
        g_iKolLayShotState[i]  = -1;    // v1.6: las capas mueren con el mapa
        g_fKolLayShotStart[i]  = 0.0;
        g_bKolLayHoldOn[i]     = false;
        g_iKolBodyRender[i]    = -1;
        g_bKolSmSnap[i]        = false;

        // el kit a cero (refs y ventanas del mapa viejo)
        g_iKolChargeState[i]    = KOL_CHG_IDLE;
        g_fKolChargeEnd[i]      = 0.0;
        g_fKolWindupStart[i]    = 0.0;
        g_fKolChargeCdUntil[i]  = 0.0;
        g_fKolStuckSince[i]     = 0.0;
        g_iKolSavedColGroup[i]  = -1;
        g_iKolGrabVictim[i]     = 0;
        g_iKolGrabPunches[i]    = 0;
        g_iKolGrabMoveType[i]   = -1;
        g_fKolLungeUntil[i]     = 0.0;
        g_fKolGrabHoldEnd[i]    = 0.0;
        g_fKolGrabCdUntil[i]    = 0.0;
        g_bKolGrabLunged[i]     = false;
        g_iKolWitchRag[i]       = 0;     // v2.1: registro de la witch
        g_iKolWitchRagVictim[i] = 0;
        g_iKolWitchRagRender[i] = -1;
        g_iKolWitchRagCol[i]    = -1;
        g_bKolWitchRagJolt[i]   = false;
        g_fKolWitchRagRepinAt[i]= 0.0;
        g_fKolWitchRagPinDelay[i] = 0.0;
        g_bKolWitchRagFlying[i] = false;
        g_fKolWitchRagFlyEnd[i] = 0.0;
        g_bKolGrabIsWitch[i]    = false;
        g_fKolGrabNextPunchAt[i]= 0.0;   // v2.1: puerta del combo
        g_iKolRockFlying[i]     = 0;     // v2.1: roca en vuelo
        g_fKolRockDieAt[i]      = 0.0;
        g_fKolCounterSafeUntil[i] = 0.0; // v2.1: anti-empuje del counter
        g_fKolNativeStunUntil[i] = 0.0;  // v2.2: ventana del stun nativo
        g_bKolWasStunned[i]      = false;// v2.2: flanco del kol stun N
        g_fKolBlockUntil[i]     = 0.0;
        g_fKolBlockCdUntil[i]   = 0.0;
        g_bKolBlockCountered[i] = false;
        g_fKolIndUntil[i]       = 0.0;
        g_fKolIndCdUntil[i]     = 0.0;
        g_fKolIndNextPing[i]    = 0.0;

        // flags de auto-gestion de la FSM: el mapa nuevo arranca limpio
        g_bKolHooked[i]    = false;
        g_bKolHpApplied[i] = false;

        if (g_hKolHitList[i] != null)
        {
            delete g_hKolHitList[i];
            g_hKolHitList[i] = null;
        }
    }

    // los sprites del indicator murieron con el mapa
    for (int e = 0; e <= KOL_MAXENT; e++) g_iKolIndSprite[e] = 0;
}

// =====================================================================
//  EVENTOS (auto-enganchados — cero cableado en el manager)
// =====================================================================

public void Kolossos_EventSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!Kolossos_PlayerIs(client)) return;
    if (GetClientTeam(client) != 2) return;

    Kolossos_ResetState(client);

    // hook de dano (resistencia + block) — idempotente
    SDKUnhook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);

    // vida max (receta Metal_ApplyMaxHealth)
    Kolossos_ApplyMaxHealth(client);
}

public void Kolossos_EventDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client < 1 || client > MaxClients) return;

    // si era un agarrado por Kolossos: restaurar su movetype
    if (g_iPlayerCharIdx[client] != KOLOSSOS_INDEX)
    {
        for (int k = 1; k <= MaxClients; k++)
            if (g_iKolGrabVictim[k] != 0 && EntRefToEntIndex(g_iKolGrabVictim[k]) == client)
                Kolossos_GrabRelease(k, false, true);
        return;
    }

    // el Kolossos murio: cancelar todo (el avatar lo baja la FSM en 0.1s)
    Kolossos_ResetState(client);
    SDKUnhook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
    Kolossos_RestoreMaxHealth(client);
}

public void Kolossos_EventRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // barrido de arranque: huerfanos del mapa anterior fuera (patron Suite)
    Kolossos_KillGhostAvatarProps();
    Kolossos_KillAllIndSprites();

    for (int i = 1; i <= MaxClients; i++)
    {
        Kolossos_ResetState(i);
        g_bKolWelcomeSaid[i] = false;
    }
}

// =====================================================================
//  RESET / CLEANUP (manager: CleanupCharModuleState case KOLOSSOS_INDEX)
// =====================================================================

void Kolossos_ResetState(int client)
{
    // cancelar charge (restaura colision/velocidad/FOV/loop)
    if (g_iKolChargeState[client] != KOL_CHG_IDLE)
        Kolossos_ChargeEnd(client, false);

    // soltar al agarrado
    if (g_iKolGrabVictim[client] != 0)
        Kolossos_GrabRelease(client, false, false);

    g_fKolLungeUntil[client]   = 0.0;
    g_fKolGrabCdUntil[client]  = 0.0;
    g_fKolBlockUntil[client]   = 0.0;
    g_fKolBlockCdUntil[client] = 0.0;
    g_bKolBlockCountered[client] = false;
    g_iKolAnimShotState[client] = -1;   // v1.1: sin one-shot
    g_fKolAnimShotUntil[client] = 0.0;
    g_iKolAnimShotTier[client]  = KOL_SHOT_ACT;   // v1.3
    Kolossos_LayerHold(client, false);            // v1.6: pose de capa fuera (idempotente)
    Kolossos_LayerClearShot(client);              // v1.6: one-shot de capa fuera (idempotente)
    g_fKolGrabThrowAt[client]   = 0.0;            // v1.3: sin lanzamiento pendiente
    g_iKolGrabFlingRef[client]  = 0;              // v1.3 (anula el fling demorado si habia)
    g_fKolIndUntil[client]     = 0.0;
    g_fKolIndCdUntil[client]   = 0.0;
    g_fKolIndNextPing[client]  = 0.0;

    // v1.9: liberar los ragdolls de victimas propias (grab/carry/counter)
    // — el doble muere, el original revive visible donde quedo
    for (int v = 1; v <= MaxClients; v++)
    {
        if (g_iKolVictRag[v] != 0 && g_iKolVictRagOwner[v] == client)
            Kolossos_VictRagEnd(v, true);
    }

    // v2.1: la WITCH propia — su doble muere y la original revive
    // visible/andante donde quedo (nunca dejarla invisible/helada)
    if (g_iKolWitchRag[client] != 0)
        Kolossos_WitchRagEnd(client, true);

    // v2.1: la roca en vuelo propia muere con el reset
    if (g_iKolRockFlying[client] != 0)
    {
        int rockK = EntRefToEntIndex(g_iKolRockFlying[client]);
        if (rockK > 0 && IsValidEntity(rockK)) AcceptEntityInput(rockK, "Kill");
        g_iKolRockFlying[client] = 0;
    }
    g_fKolCounterSafeUntil[client] = 0.0;   // v2.1
    g_fKolGrabNextPunchAt[client] = 0.0;    // v2.1
    g_bKolGrabIsWitch[client]     = false;  // v2.1

    if (g_hKolHitList[client] != null)
    {
        // v1.9: cualquier comun/witch todavia ARRASTRADO (parentado al
        // avatar) se despega antes de tirar la lista
        int nH = g_hKolHitList[client].Length;
        for (int i = 0; i < nH; i++)
        {
            int ent = EntRefToEntIndex(g_hKolHitList[client].Get(i));
            if (ent > MaxClients && IsValidEntity(ent)
                && GetEntPropEnt(ent, Prop_Data, "m_hMoveParent") != -1)
            {
                SetVariantString("");
                AcceptEntityInput(ent, "SetParent", ent, ent);
            }
        }
        delete g_hKolHitList[client];
        g_hKolHitList[client] = null;
    }
}

// limpieza total: cambio de personaje / disconnect (manager la llama;
// para disconnect el propio modulo la invoca desde la FSM)
void Kolossos_CleanupState(int client)
{
    Kolossos_ResetState(client);
    Kolossos_KillAvatar(client);
    Kolossos_RestoreMaxHealth(client);
    SDKUnhook(client, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
    g_bKolHooked[client]     = false;   // el slot puede reutilizarse (disconnect)
    g_bKolHpApplied[client]  = false;
    g_bKolWelcomeSaid[client] = false;
    g_iKolAnimState[client]   = -1;
    g_iKolAnimShotState[client] = -1;
    g_fKolAnimShotUntil[client] = 0.0;
    g_iKolAnimShotTier[client]  = KOL_SHOT_ACT;   // v1.3
    g_fKolGrabThrowAt[client]   = 0.0;            // v1.3
    g_iKolGrabFlingRef[client]  = 0;              // v1.3
}

// =====================================================================
//  STATS (receta Metal_ApplyMaxHealth / RestoreMaxHealth)
// =====================================================================

void Kolossos_ApplyMaxHealth(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client) || GetClientTeam(client) != 2) return;

    int maxhp = g_cvKolHealth.IntValue;
    if (maxhp <= 0) return;

    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", maxhp);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", maxhp);

    if (IsPlayerAlive(client) && !GetEntProp(client, Prop_Send, "m_isIncapacitated"))
    {
        int hp = GetClientHealth(client);
        if (hp >= 100 && hp < maxhp)
            SetEntityHealth(client, maxhp);
    }
}

void Kolossos_RestoreMaxHealth(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] == KOLOSSOS_INDEX) return;   // sigue siendo Kolossos

    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", 100);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", 100);

    if (IsPlayerAlive(client) && GetClientHealth(client) > 100)
        SetEntityHealth(client, 100);
}

// =====================================================================
//  AVATAR ESPEJO (patron Blaze v2.11 / sonic.inc v6.30 — 14o avatar)
// =====================================================================

#define KOL_AVATAR_NAME   "kolossos_avatar_om"
#define KOL_AVATAR_NAME_L "kolossos_avatar_om_l"

int Kolossos_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
{
    // v1.6: COMMENTARY_DUMMY PRIMERO — el owner encontro la pieza que
    // faltaba del rompecabezas de las capas: en L4D2 la UNICA entidad
    // "spawnable como un prop" cuya clase hereda de CBaseAnimatingOverlay
    // es commentary_dummy (pagina oficial de Valve: CCommentaryDummy ->
    // CBaseCombatCharacter -> CBaseFlex -> CBaseAnimatingOverlay ->
    // CBaseAnimating -> CBaseEntity). Los props de verdad (prop_dynamic,
    // prop_physics, prop_static) son CBaseAnimating puro: SIN overlay. El
    // dummy trae keyvalue "model" e input "SetAnimation" por nombre.
    // v1.7 VEREDICTO (sonda en vivo de la v1.6.1 en el server del owner):
    // la clase overlay existe pero L4D2 NO networka el array —
    // m_AnimOverlay=no m_animLayers=no en todas las formas de la sonda.
    // El dummy queda como host (spawnnea vivo, toma el modelo, ya esta
    // whitelisteado en los plugins de limpieza) PERO sin capas: la via
    // del grab es la FUSION v1.5. Si la
    // fabrica no lo da o se rompe solo (p.ej. sin el modo comentario),
    // se cae al prop_dynamic_override clasico (fusion v1.5 / monocapa).
    bool dummy = false;
    int av = CreateEntityByName("commentary_dummy");
    if (av <= 0 || !IsValidEntity(av))
    {
        // v1.6.1: diagnostico granular — la fabrica no conoce la clase
        // en este servidor (build raro / entidad retirada)
        g_iKolDummyFail = 1;
        strcopy(g_sKolDummyFailInfo, sizeof(g_sKolDummyFailInfo),
                "CreateEntityByName no la dio");
        av = -1;
    }
    else
    {
        DispatchKeyValue(av, "model", model);
        DispatchKeyValue(av, "targetname", targetname);
        DispatchKeyValue(av, "LookAtPlayers", "0");   // no mira a nadie
        DispatchSpawn(av);
        ActivateEntity(av);   // v1.6.1: receta de los clones de emotes

        // v1.6.1: EL HOST YA NO DEPENDE DEL CANAL DE CAPAS — la
        // verificacion v1.6 exigia resolver "m_animLayers.m_nSequence",
        // una forma que el nucleo de SM NO resuelve para un array de
        // datatables (los elementos viajan como "m_AnimOverlay.000"...
        // ".014" y las props "inside array" se saltan), asi que el dummy
        // perfecto era muerto en cada mapa y caiamos SIEMPRE al prop.
        // Host = vivo + NUESTRO modelo; las capas las decide la sonda
        // multi-forma (Kolossos_LayerProbe). Si algo fallo queda
        // registrado el POR QUE para sm_kolossos.
        char got[PLATFORM_MAX_PATH];
        if (!IsValidEntity(av))
        {
            g_iKolDummyFail = 2;   // se destruyo solo al spawnear
            strcopy(g_sKolDummyFailInfo, sizeof(g_sKolDummyFailInfo),
                    "invalido tras DispatchSpawn");
        }
        else if (!HasEntProp(av, Prop_Data, "m_ModelName"))
        {
            g_iKolDummyFail = 3;
            strcopy(g_sKolDummyFailInfo, sizeof(g_sKolDummyFailInfo),
                    "sin m_ModelName");
        }
        else
        {
            GetEntPropString(av, Prop_Data, "m_ModelName", got, sizeof(got));
            if (got[0] != '\0' && StrEqual(got, model, false))
            {
                dummy = true;
                g_iKolDummyFail = 0;
                g_sKolDummyFailInfo[0] = '\0';

                // blindaje del combat character (no dano, no solido, no sombra):
                // es un CBaseCombatCharacter y por defecto podria recibir
                // dano/sangrar — colgado del player e intocable queda igual
                // que un prop
                if (HasEntProp(av, Prop_Data, "m_takedamage"))
                    SetEntProp(av, Prop_Data, "m_takedamage", 0);
                if (HasEntProp(av, Prop_Data, "m_CollisionGroup"))
                    SetEntProp(av, Prop_Data, "m_CollisionGroup", 0);
                if (HasEntProp(av, Prop_Send, "m_nSolidType"))
                    SetEntProp(av, Prop_Send, "m_nSolidType", 0);
                if (HasEntProp(av, Prop_Send, "m_fEffects"))
                    SetEntProp(av, Prop_Send, "m_fEffects",
                               GetEntProp(av, Prop_Send, "m_fEffects") | KOL_EF_NOSHADOW);
            }
            else
            {
                g_iKolDummyFail = 3;   // rechazo el modelo — registrar cual quedo
                Format(g_sKolDummyFailInfo, sizeof(g_sKolDummyFailInfo),
                       "modelo quedo '%s'", got);
            }
        }

        if (!dummy && IsValidEntity(av))
        {
            AcceptEntityInput(av, "Kill");   // host invalido: fuera
            av = -1;
        }
    }

    if (!dummy)
    {
        av = CreateEntityByName("prop_dynamic_override");
        if (av <= 0 || !IsValidEntity(av)) return 0;

        DispatchKeyValue(av, "model", model);
        DispatchKeyValue(av, "targetname", targetname);
        DispatchKeyValue(av, "solid", "0");
        DispatchKeyValue(av, "disableshadows", "1");
        DispatchSpawn(av);
    }

    g_bKolDummyHost = dummy;   // telemetria de sm_kolossos (host del mapa)

    float pos[3], ang[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    ang[0] = 0.0;                          // pitch NUNCA
    ang[2] = 0.0;                          // roll NUNCA
    g_fKolBodyYaw[client]  = ang[1];
    g_fKolYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fKolBodyYaw[client], loc);

    if (!tpMode)
    {
        // parentado (modo default: el motor mueve la posicion)
        SetVariantString("!activator");
        AcceptEntityInput(av, "SetParent", client);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", loc);
    }

    for (int k = 0; k < 3; k++)
    {
        g_fKolSmLoc[client][k]  = loc[k];
        g_fKolSmLocL[client][k] = loc[k];
    }
    g_bKolSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// resolucion de secuencias contra el .mdl REAL (sonda del patron
// Blaze_ResolveTry: SetAnimation + m_nSequence — SIN LookupSequence,// que no existe en SM 1.12; una vez por mapa)
void Kolossos_ResolveTry(int av, int state, const char[] name)
{
    if (!HasEntProp(av, Prop_Send, "m_nSequence")) return;

    int before = GetEntProp(av, Prop_Send, "m_nSequence");
    SetVariantString(name);
    AcceptEntityInput(av, "SetAnimation");
    int after = GetEntProp(av, Prop_Send, "m_nSequence");

    if (after != before)
    {
        strcopy(g_sKolSeqName[state], 24, name);
        g_bKolSeqOK[state] = true;
        g_iKolSeqIdx[state] = after;   // v1.6: el INDICE — las capas usan indice, no nombre
    }
}

void Kolossos_ResolveSeqs(int av)
{
    if (g_bKolSeqsOK) return;
    g_bKolSeqsOK = true;

    // candidatos por estado: nombres literales del registro anims del
    // killer Lua + variantes comunes por si el .mdl difiere
    char idleCands[][16]  = { "idle", "Idle", "IDLE", "idle01" };
    char walkCands[][16]  = { "walk", "Walk", "walk01", "WalkAll" };
    char runCands[][16]   = { "run", "Run", "run01", "RunAll" };
    char jumpCands[][16]  = { "jump", "Jump", "jump01" };
    char fallCands[][16]  = { "fall", "Fall", "glide", "fall01" };
    char stunCands[][16]  = { "stun", "Stun" };
    char chgStCands[][22] = { "chargestart", "ChargeStart", "charge_start" };
    char chgCands[][22]   = { "charge_notimpaled", "charge", "Charge" };
    char chgImpCands[][22]= { "Charge_impaled", "charge_impaled", "ChargeImpaled" };
    char blkStCands[][22] = { "BlockStart", "blockstart" };
    char blkCands[][22]   = { "BlockPos", "blockpos", "Block" };
    char blkPrCands[][22] = { "BlockProjectile", "blockprojectile" };
    char ctrCands[][22]   = { "BlackCounterMelee", "blackcountermelee", "CounterMelee" };
    char slamCands[][22]  = { "slaminwall", "SlamInWall", "slam_in_wall" };
    char killCands[][22]  = { "Kill", "kill", "Execution" };
    // v1.3: la serie del grab — nombres literales de los SMD del .mdl
    // (Grab 31f / GrabIdle pose / GrabPunch 51f / GrabThrow 61f)
    char grabRcCands[][22] = { "Grab", "grab", "Grab_reach", "Reach" };
    char grabHdCands[][22] = { "GrabIdle", "grabidle", "Grab_Idle", "grab_idle", "IdleGrab" };
    char grabPnCands[][22] = { "GrabPunch", "grabpunch", "Grab_Punch", "Punch" };
    char grabThCands[][22] = { "GrabThrow", "grabthrow", "Grab_Throw", "Throw" };
    // v1.5: la SERIE FUSIONADA — las 12 compuestas del .mdl recompilado
    // con el pack v1.5 (nombres literales del kolossos.qc v1.5 + variantes)
    char holdWC[][24] = { "walk_hold", "WalkHold", "walkhold" };
    char holdRC[][24] = { "run_hold", "RunHold", "runhold" };
    char holdIC[][24] = { "idle_hold", "IdleHold", "idlehold" };
    char rchWC[][24]  = { "walk_reach", "WalkReach", "walkreach" };
    char rchRC[][24]  = { "run_reach", "RunReach", "runreach" };
    char rchIC[][24]  = { "idle_reach", "IdleReach", "idlereach" };
    char pchWC[][24]  = { "walk_punch", "WalkPunch", "walkpunch" };
    char pchRC[][24]  = { "run_punch", "RunPunch", "runpunch" };
    char pchIC[][24]  = { "idle_punch", "IdlePunch", "idlepunch" };
    char thrWC[][24]  = { "walk_throw", "WalkThrow", "walkthrow" };
    char thrRC[][24]  = { "run_throw", "RunThrow", "runthrow" };
    char thrIC[][24]  = { "idle_throw", "IdleThrow", "idlethrow" };
    // v2.0: LA FUSION DEL SWING (pack v1.5.3)
    char swgWC[][24]  = { "walk_swing", "WalkSwing", "walkswing" };
    char swgRC[][24]  = { "run_swing", "RunSwing", "runswing" };
    char swgIC[][24]  = { "idle_swing", "IdleSwing", "idleswing" };

    for (int c = 0; c < sizeof(idleCands); c++) { Kolossos_ResolveTry(av, KOL_ST_IDLE, idleCands[c]); if (g_bKolSeqOK[KOL_ST_IDLE]) break; }
    for (int c = 0; c < sizeof(walkCands); c++) { Kolossos_ResolveTry(av, KOL_ST_WALK, walkCands[c]); if (g_bKolSeqOK[KOL_ST_WALK]) break; }
    for (int c = 0; c < sizeof(runCands);  c++) { Kolossos_ResolveTry(av, KOL_ST_RUN,  runCands[c]);  if (g_bKolSeqOK[KOL_ST_RUN])  break; }
    for (int c = 0; c < sizeof(jumpCands); c++) { Kolossos_ResolveTry(av, KOL_ST_JUMP, jumpCands[c]); if (g_bKolSeqOK[KOL_ST_JUMP]) break; }
    for (int c = 0; c < sizeof(fallCands); c++) { Kolossos_ResolveTry(av, KOL_ST_FALL, fallCands[c]); if (g_bKolSeqOK[KOL_ST_FALL]) break; }
    for (int c = 0; c < sizeof(stunCands); c++) { Kolossos_ResolveTry(av, KOL_ST_STUN, stunCands[c]); if (g_bKolSeqOK[KOL_ST_STUN]) break; }
    for (int c = 0; c < sizeof(chgStCands); c++) { Kolossos_ResolveTry(av, KOL_ST_CHARGESTART, chgStCands[c]); if (g_bKolSeqOK[KOL_ST_CHARGESTART]) break; }
    for (int c = 0; c < sizeof(chgCands); c++)   { Kolossos_ResolveTry(av, KOL_ST_CHARGE, chgCands[c]);      if (g_bKolSeqOK[KOL_ST_CHARGE]) break; }
    for (int c = 0; c < sizeof(chgImpCands); c++){ Kolossos_ResolveTry(av, KOL_ST_CHARGE_IMP, chgImpCands[c]);if (g_bKolSeqOK[KOL_ST_CHARGE_IMP]) break; }
    for (int c = 0; c < sizeof(blkStCands); c++) { Kolossos_ResolveTry(av, KOL_ST_BLOCKSTART, blkStCands[c]); if (g_bKolSeqOK[KOL_ST_BLOCKSTART]) break; }
    for (int c = 0; c < sizeof(blkCands); c++)   { Kolossos_ResolveTry(av, KOL_ST_BLOCK, blkCands[c]);        if (g_bKolSeqOK[KOL_ST_BLOCK]) break; }
    for (int c = 0; c < sizeof(blkPrCands); c++) { Kolossos_ResolveTry(av, KOL_ST_BLOCKPROJ, blkPrCands[c]);  if (g_bKolSeqOK[KOL_ST_BLOCKPROJ]) break; }
    for (int c = 0; c < sizeof(ctrCands); c++)   { Kolossos_ResolveTry(av, KOL_ST_COUNTER, ctrCands[c]);      if (g_bKolSeqOK[KOL_ST_COUNTER]) break; }
    for (int c = 0; c < sizeof(slamCands); c++)  { Kolossos_ResolveTry(av, KOL_ST_SLAMINWALL, slamCands[c]);  if (g_bKolSeqOK[KOL_ST_SLAMINWALL]) break; }
    for (int c = 0; c < sizeof(killCands); c++)  { Kolossos_ResolveTry(av, KOL_ST_KILL, killCands[c]);        if (g_bKolSeqOK[KOL_ST_KILL]) break; }
    for (int c = 0; c < sizeof(grabRcCands); c++) { Kolossos_ResolveTry(av, KOL_ST_GRABREACH, grabRcCands[c]); if (g_bKolSeqOK[KOL_ST_GRABREACH]) break; }
    for (int c = 0; c < sizeof(grabHdCands); c++) { Kolossos_ResolveTry(av, KOL_ST_GRABHOLD, grabHdCands[c]);  if (g_bKolSeqOK[KOL_ST_GRABHOLD]) break; }
    for (int c = 0; c < sizeof(grabPnCands); c++) { Kolossos_ResolveTry(av, KOL_ST_GRABPUNCH, grabPnCands[c]); if (g_bKolSeqOK[KOL_ST_GRABPUNCH]) break; }
    for (int c = 0; c < sizeof(grabThCands); c++) { Kolossos_ResolveTry(av, KOL_ST_GRABTHROW, grabThCands[c]); if (g_bKolSeqOK[KOL_ST_GRABTHROW]) break; }
    // v1.5: la serie fusionada
    for (int c = 0; c < sizeof(holdWC); c++) { Kolossos_ResolveTry(av, KOL_ST_HOLD_WALK, holdWC[c]);  if (g_bKolSeqOK[KOL_ST_HOLD_WALK]) break; }
    for (int c = 0; c < sizeof(holdRC); c++) { Kolossos_ResolveTry(av, KOL_ST_HOLD_RUN, holdRC[c]);   if (g_bKolSeqOK[KOL_ST_HOLD_RUN]) break; }
    for (int c = 0; c < sizeof(holdIC); c++) { Kolossos_ResolveTry(av, KOL_ST_HOLD_IDLE, holdIC[c]);  if (g_bKolSeqOK[KOL_ST_HOLD_IDLE]) break; }
    for (int c = 0; c < sizeof(rchWC); c++)  { Kolossos_ResolveTry(av, KOL_ST_REACH_WALK, rchWC[c]); if (g_bKolSeqOK[KOL_ST_REACH_WALK]) break; }
    for (int c = 0; c < sizeof(rchRC); c++)  { Kolossos_ResolveTry(av, KOL_ST_REACH_RUN, rchRC[c]);  if (g_bKolSeqOK[KOL_ST_REACH_RUN]) break; }
    for (int c = 0; c < sizeof(rchIC); c++)  { Kolossos_ResolveTry(av, KOL_ST_REACH_IDLE, rchIC[c]); if (g_bKolSeqOK[KOL_ST_REACH_IDLE]) break; }
    for (int c = 0; c < sizeof(pchWC); c++)  { Kolossos_ResolveTry(av, KOL_ST_PUNCH_WALK, pchWC[c]); if (g_bKolSeqOK[KOL_ST_PUNCH_WALK]) break; }
    for (int c = 0; c < sizeof(pchRC); c++)  { Kolossos_ResolveTry(av, KOL_ST_PUNCH_RUN, pchRC[c]);  if (g_bKolSeqOK[KOL_ST_PUNCH_RUN]) break; }
    for (int c = 0; c < sizeof(pchIC); c++)  { Kolossos_ResolveTry(av, KOL_ST_PUNCH_IDLE, pchIC[c]); if (g_bKolSeqOK[KOL_ST_PUNCH_IDLE]) break; }
    for (int c = 0; c < sizeof(thrWC); c++)  { Kolossos_ResolveTry(av, KOL_ST_THROW_WALK, thrWC[c]); if (g_bKolSeqOK[KOL_ST_THROW_WALK]) break; }
    for (int c = 0; c < sizeof(thrRC); c++)  { Kolossos_ResolveTry(av, KOL_ST_THROW_RUN, thrRC[c]);  if (g_bKolSeqOK[KOL_ST_THROW_RUN]) break; }
    for (int c = 0; c < sizeof(thrIC); c++)  { Kolossos_ResolveTry(av, KOL_ST_THROW_IDLE, thrIC[c]); if (g_bKolSeqOK[KOL_ST_THROW_IDLE]) break; }
    // v2.0: la serie swing
    for (int c = 0; c < sizeof(swgWC); c++)  { Kolossos_ResolveTry(av, KOL_ST_SWING_WALK, swgWC[c]); if (g_bKolSeqOK[KOL_ST_SWING_WALK]) break; }
    for (int c = 0; c < sizeof(swgRC); c++)  { Kolossos_ResolveTry(av, KOL_ST_SWING_RUN, swgRC[c]);  if (g_bKolSeqOK[KOL_ST_SWING_RUN]) break; }
    for (int c = 0; c < sizeof(swgIC); c++)  { Kolossos_ResolveTry(av, KOL_ST_SWING_IDLE, swgIC[c]); if (g_bKolSeqOK[KOL_ST_SWING_IDLE]) break; }

    // v1.5: LA SONDA DE FUSION — walk_hold & co solo existen en el .mdl
    // recompilado con el pack v1.5. Se captura ANTES de la cadena de
    // fallbacks (que despues rellena los huecos con nombres base y ya
    // no se podria distinguir). Si falta una pieza clave: fusion OFF y
    // todo cae a la monocapa (consistencia total)
    g_bKolFusionOK = (g_bKolSeqOK[KOL_ST_HOLD_WALK] && g_bKolSeqOK[KOL_ST_HOLD_RUN]
                   && g_bKolSeqOK[KOL_ST_HOLD_IDLE] && g_bKolSeqOK[KOL_ST_REACH_WALK]
                   && g_bKolSeqOK[KOL_ST_PUNCH_WALK] && g_bKolSeqOK[KOL_ST_THROW_WALK]);

    // v1.5: se recuerda cuales compuestas vinieron NATIVAS (antes de
    // que la cadena de fallbacks rellene los huecos): el dispatcher
    // solo dispara la fusion si ESA pieza existe de verdad en el .mdl
    for (int s = KOL_ST_HOLD_WALK; s <= KOL_ST_THROW_IDLE; s++)
        g_bKolFusedNative[s] = g_bKolSeqOK[s];
    // v2.0: idem la serie swing (rango propio, despues del THROW_IDLE)
    for (int s = KOL_ST_SWING_WALK; s <= KOL_ST_SWING_IDLE; s++)
        g_bKolFusedNative[s] = g_bKolSeqOK[s];

    // cadena de fallbacks (nunca T-pose; cada hueco cae a su par visual
    // mas cercano: la avalancha sin anim dedicada corre, el bloqueo sin
    // pose se planta, los one-shot raros caen a idle)
    if (!g_bKolSeqOK[KOL_ST_CHARGE])
        Kolossos_FallbackTo(KOL_ST_CHARGE, KOL_ST_RUN);
    if (!g_bKolSeqOK[KOL_ST_CHARGE_IMP])
        Kolossos_FallbackTo(KOL_ST_CHARGE_IMP, g_bKolSeqOK[KOL_ST_CHARGE] ? KOL_ST_CHARGE : KOL_ST_RUN);
    if (!g_bKolSeqOK[KOL_ST_BLOCK])
        Kolossos_FallbackTo(KOL_ST_BLOCK, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_BLOCKSTART])
        Kolossos_FallbackTo(KOL_ST_BLOCKSTART, KOL_ST_BLOCK);
    if (!g_bKolSeqOK[KOL_ST_BLOCKPROJ])
        Kolossos_FallbackTo(KOL_ST_BLOCKPROJ, KOL_ST_BLOCK);
    if (!g_bKolSeqOK[KOL_ST_COUNTER])
        Kolossos_FallbackTo(KOL_ST_COUNTER, KOL_ST_BLOCK);
    if (!g_bKolSeqOK[KOL_ST_STUN])
        Kolossos_FallbackTo(KOL_ST_STUN, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_CHARGESTART])
        Kolossos_FallbackTo(KOL_ST_CHARGESTART, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_SLAMINWALL])
        Kolossos_FallbackTo(KOL_ST_SLAMINWALL, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_KILL])
        Kolossos_FallbackTo(KOL_ST_KILL, KOL_ST_IDLE);

    // v1.3: la serie del grab — cada hueco cae a su par visual mas cercano
    // (sujetando sin pose = plantado normal; sin reach/puo/throw caen por
    // la cadena hasta idle — nunca T-pose)
    if (!g_bKolSeqOK[KOL_ST_GRABHOLD])
        Kolossos_FallbackTo(KOL_ST_GRABHOLD, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_GRABREACH])
        Kolossos_FallbackTo(KOL_ST_GRABREACH, g_bKolSeqOK[KOL_ST_GRABHOLD] ? KOL_ST_GRABHOLD : KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_GRABPUNCH])
        Kolossos_FallbackTo(KOL_ST_GRABPUNCH, g_bKolSeqOK[KOL_ST_GRABREACH] ? KOL_ST_GRABREACH : KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_GRABTHROW])
        Kolossos_FallbackTo(KOL_ST_GRABTHROW, g_bKolSeqOK[KOL_ST_GRABPUNCH] ? KOL_ST_GRABPUNCH : (g_bKolSeqOK[KOL_ST_GRABREACH] ? KOL_ST_GRABREACH : KOL_ST_IDLE));

    // v1.5: la serie fusionada — sin el .mdl recompilado cada compuesta
    // cae a SU LOCOMOCION (v1.7: nunca a los gestures crudos): el
    // plugin funciona IGUAL con el modelo viejo, solo sin la fusion
    if (!g_bKolSeqOK[KOL_ST_HOLD_WALK])  Kolossos_FallbackTo(KOL_ST_HOLD_WALK,  KOL_ST_WALK);
    if (!g_bKolSeqOK[KOL_ST_HOLD_RUN])   Kolossos_FallbackTo(KOL_ST_HOLD_RUN,   KOL_ST_RUN);
    // v1.7: los huecos de las compuestas caen a SU LOCO (nunca a los
    // gestures crudos: traen el Root volteado y jamas van como main)
    if (!g_bKolSeqOK[KOL_ST_HOLD_IDLE])  Kolossos_FallbackTo(KOL_ST_HOLD_IDLE,  KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_REACH_WALK]) Kolossos_FallbackTo(KOL_ST_REACH_WALK, KOL_ST_WALK);
    if (!g_bKolSeqOK[KOL_ST_REACH_RUN])  Kolossos_FallbackTo(KOL_ST_REACH_RUN,  KOL_ST_RUN);
    if (!g_bKolSeqOK[KOL_ST_REACH_IDLE]) Kolossos_FallbackTo(KOL_ST_REACH_IDLE, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_PUNCH_WALK]) Kolossos_FallbackTo(KOL_ST_PUNCH_WALK, KOL_ST_WALK);
    if (!g_bKolSeqOK[KOL_ST_PUNCH_RUN])  Kolossos_FallbackTo(KOL_ST_PUNCH_RUN,  KOL_ST_RUN);
    if (!g_bKolSeqOK[KOL_ST_PUNCH_IDLE]) Kolossos_FallbackTo(KOL_ST_PUNCH_IDLE, KOL_ST_IDLE);
    if (!g_bKolSeqOK[KOL_ST_THROW_WALK]) Kolossos_FallbackTo(KOL_ST_THROW_WALK, KOL_ST_WALK);
    if (!g_bKolSeqOK[KOL_ST_THROW_RUN])  Kolossos_FallbackTo(KOL_ST_THROW_RUN,  KOL_ST_RUN);
    if (!g_bKolSeqOK[KOL_ST_THROW_IDLE]) Kolossos_FallbackTo(KOL_ST_THROW_IDLE, KOL_ST_IDLE);
    // v2.0: la serie swing — sin el pack v1.5.3 el M1 cae a la SERIE
    // PUNCH de la v1.9 (lo que el owner ya conoce); y el punch ya cayo
    // a su locomocion si el .mdl es el viejo (cadena de dos eslabones)
    if (!g_bKolSeqOK[KOL_ST_SWING_WALK]) Kolossos_FallbackTo(KOL_ST_SWING_WALK, KOL_ST_PUNCH_WALK);
    if (!g_bKolSeqOK[KOL_ST_SWING_RUN])  Kolossos_FallbackTo(KOL_ST_SWING_RUN,  KOL_ST_PUNCH_RUN);
    if (!g_bKolSeqOK[KOL_ST_SWING_IDLE]) Kolossos_FallbackTo(KOL_ST_SWING_IDLE, KOL_ST_PUNCH_IDLE);

    // locomocion base: lo que falte cae a idle (regla v1.0)
    for (int s = 1; s <= KOL_ST_FALL; s++)
    {
        if (!g_bKolSeqOK[s])
            Kolossos_FallbackTo(s, KOL_ST_IDLE);
    }
}

// v1.1: copia el nombre resuelto de un estado a otro (fallback en cadena)
void Kolossos_FallbackTo(int dst, int src)
{
    strcopy(g_sKolSeqName[dst], 24, g_sKolSeqName[src]);
    g_bKolSeqOK[dst] = g_bKolSeqOK[src];
}

void Kolossos_SeqFor(int state, char[] out, int maxlen)
{
    strcopy(out, maxlen, g_sKolSeqName[state]);
}

// =====================================================================
//  v1.3: CALIBRADOR DE DURACIONES — "debe durar lo que debe durar".
//  Los SMD dicen 31/51/61 frames, pero el fps REAL lo decide el .mdl
//  compilado (el Kill del Lua dura 1.65s con 276 frames — NO es 30fps).
//  En vez de adivinar: se mide EN VIVO con un prop desechable —
//  SetAnimation + m_bClientSideAnimation 0 (el SERVER avanza m_flCycle)
//  y se cuenta cuanto tarda el ciclo en clavarse en 1.0 (fin de un
//  one-shot no loopeado). Una sola vez por mapa, al primer montaje.
// =====================================================================

int Kolossos_CalibStateOf(int stage)
{
    if (stage <= 0) return KOL_ST_GRABREACH;
    if (stage == 1) return KOL_ST_GRABPUNCH;
    return KOL_ST_GRABTHROW;
}

void Kolossos_CalibStart()
{
    if (g_bKolCalibDone || !g_bKolModelOK) return;

    // sin ninguna secuencia de la serie no hay nada que medir
    if (!g_bKolSeqOK[KOL_ST_GRABREACH] && !g_bKolSeqOK[KOL_ST_GRABPUNCH]
        && !g_bKolSeqOK[KOL_ST_GRABTHROW])
    {
        g_bKolCalibDone = true;
        return;
    }

    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));

    int cp = CreateEntityByName("prop_dynamic_override");
    if (cp <= 0 || !IsValidEntity(cp))
    {
        g_bKolCalibDone = true;   // sin prop: fallbacks 30fps y listo
        return;
    }
    DispatchKeyValue(cp, "model", mdl);
    DispatchKeyValue(cp, "targetname", "kolossos_calib_om");
    DispatchKeyValue(cp, "solid", "0");
    DispatchKeyValue(cp, "disableshadows", "1");
    DispatchSpawn(cp);

    // invisible y lejos: solo el SERVER lo anima (asi m_flCycle avanza
    // de verdad y se puede medir)
    SetEntityRenderMode(cp, RENDER_NONE);
    if (HasEntProp(cp, Prop_Send, "m_bClientSideAnimation"))
        SetEntProp(cp, Prop_Send, "m_bClientSideAnimation", 0);

    float far[3] = { 0.0, 0.0, -16000.0 };
    TeleportEntity(cp, far, NULL_VECTOR, NULL_VECTOR);

    g_iKolCalibProp      = EntIndexToEntRef(cp);
    g_iKolCalibStage     = 0;
    g_fKolCalibStart     = 0.0;
    g_fKolCalibLastCycle = -1.0;

    CreateTimer(0.1, Kolossos_T_Calib, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

// el tick del calibrador (10 Hz): stage actual -> anim -> esperar el clavado
public Action Kolossos_T_Calib(Handle timer)
{
    // el prop murio (fin de mapa): se re-calibrara en el proximo montaje
    int cp = EntRefToEntIndex(g_iKolCalibProp);
    if (cp <= 0 || !IsValidEntity(cp))
    {
        g_bKolCalibDone = false;
        return Plugin_Stop;
    }

    float now = GetEngineTime();

    // arrancar el stage actual si falta (saltando los no resueltos)
    if (g_fKolCalibStart == 0.0)
    {
        while (g_iKolCalibStage < 3 && !g_bKolSeqOK[Kolossos_CalibStateOf(g_iKolCalibStage)])
            g_iKolCalibStage++;

        if (g_iKolCalibStage >= 3) return Kolossos_CalibFinish(cp);

        char seq[24];
        Kolossos_SeqFor(Kolossos_CalibStateOf(g_iKolCalibStage), seq, sizeof(seq));
        SetVariantString(seq);
        AcceptEntityInput(cp, "SetAnimation");
        if (HasEntProp(cp, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(cp, Prop_Data, "m_flPlaybackRate", 1.0);

        g_fKolCalibStart     = now;
        g_fKolCalibLastCycle = -1.0;
        return Plugin_Continue;
    }

    float cycle = 0.0;
    if (HasEntProp(cp, Prop_Send, "m_flCycle"))
        cycle = GetEntPropFloat(cp, Prop_Send, "m_flCycle");

    int st = Kolossos_CalibStateOf(g_iKolCalibStage);

    // one-shot no loopeado: el ciclo se clava en ~1.0 al terminar
    if (cycle >= 0.999)
    {
        float dur = now - g_fKolCalibStart + 0.05;   // gracia de cierre
        if (dur < 0.2)  dur = 0.2;
        if (dur > 4.0)  dur = 0.0;    // absurdo: fallback 30fps
        g_fKolSeqDur[st] = dur;

        g_iKolCalibStage++;
        g_fKolCalibStart = 0.0;
        if (g_iKolCalibStage >= 3) return Kolossos_CalibFinish(cp);
    }
    // el ciclo dejo de avanzar: fin legitimo SOLO si ya iba avanzado
    // (cerca del 1.0); si sigue en el arranque es que el SERVER no
    // anima este prop -> calibracion imposible: fallbacks 30fps
    else if (g_fKolCalibLastCycle >= 0.0 && cycle <= g_fKolCalibLastCycle)
    {
        if (cycle < 0.5) return Kolossos_CalibGiveUp(cp);

        float dur2 = now - g_fKolCalibStart + 0.05;
        if (dur2 < 0.2) dur2 = 0.2;
        if (dur2 > 4.0) dur2 = 0.0;
        g_fKolSeqDur[st] = dur2;

        g_iKolCalibStage++;
        g_fKolCalibStart = 0.0;
        if (g_iKolCalibStage >= 3) return Kolossos_CalibFinish(cp);
    }
    else if (now - g_fKolCalibStart > 4.5)
    {
        // loopeado o algo raro: fallback 30fps para este y seguir
        g_fKolSeqDur[st] = 0.0;
        g_iKolCalibStage++;
        g_fKolCalibStart = 0.0;
        if (g_iKolCalibStage >= 3) return Kolossos_CalibFinish(cp);
    }
    else g_fKolCalibLastCycle = cycle;

    return Plugin_Continue;
}

// el server no anima el prop (client-side anim real): nada se puede
// medir en vivo — fallbacks 30fps de los SMD y fuera
Action Kolossos_CalibGiveUp(int cp)
{
    for (int s = 0; s < KOL_ST_COUNT; s++) g_fKolSeqDur[s] = 0.0;
    return Kolossos_CalibFinish(cp);
}

Action Kolossos_CalibFinish(int cp)
{
    AcceptEntityInput(cp, "Kill");
    g_iKolCalibProp = INVALID_ENT_REFERENCE;
    g_bKolCalibDone = true;
    return Plugin_Stop;
}

// =====================================================================
//  v1.6: MOTOR DE CAPAS REALES — m_animLayers sobre el avatar ESPEJO
//  (commentary_dummy), resucitado de la v1.4 ahora que tiene host.
//  Es EL sistema que pedia el owner desde la v1.3: "las grab son de
//  solo torso y las piernas tienen que seguir andando, como los
//  survivors cuando cambian arma". Las secuencias grab del .mdl estan
//  autoradas como gestures (weightlist weights_swing = SOLO brazos +
//  addlayer delta de torso): en una CAPA solo contribuyen sus huesos
//  con peso > 0, asi que los BRAZOS agarran mientras las PIERNAS
//  siguen andando en el main (idle/walk/run) — el mismo sistema de los
//  survivors al cambiar arma. El cliente no avanza el ciclo de un
//  overlay de entidad no-player: el SERVER lo empuja (driver per-tick
//  T_Kol_LayerThink).
// =====================================================================

// la sonda v1.6.1: MULTI-FORMA. La tabla de capas viaja en la red como
// un ARRAY de datatables (m_AnimOverlay[15] de CAnimationLayer, la
// herencia CBaseAnimatingOverlay del dummy) y cada elemento se nombra
// "m_AnimOverlay.000" ... ".014" — el formato del sm_dump_netprops.
// El nucleo de SourceMod SALTA las props "inside array" (los elementos
// crudos), asi que la unica ruta viable es la PUNTEADA con el indice
// del elemento DENTRO del nombre; la forma v1.6 ("<tabla>.m_nSequence"
// + parametro element) no existia para nadie y mataba el dummy perfecto
// en cada mapa. La sonda probea 2 nombres de tabla x 3 formas, valida
// que el slot 2 se deje escribir de verdad (write/read/restore) y
// construye la MATRIZ de descubrimiento (host + player vivo) para
// sm_kolossos — el oraculo del debug remoto.
static const char g_sKolLayTables[][] = { "m_AnimOverlay", "m_animLayers" };

// construye el nombre completo de un campo de capa con la forma ganadora
void Kolossos_LayPath(char[] out, int maxlen, int slot, const char[] field)
{
    if (g_iKolLayForm == KOL_LAY_FORM_PAD3)
        Format(out, maxlen, "%s.%03d.%s", g_sKolLayPrefix, slot, field);
    else if (g_iKolLayForm == KOL_LAY_FORM_PLAIN)
        Format(out, maxlen, "%s.%d.%s", g_sKolLayPrefix, slot, field);
    else
        Format(out, maxlen, "%s.%s", g_sKolLayPrefix, field);
}

// el parametro element: SOLO la forma v1.6 lo usa (en las punteadas el
// indice ya va DENTRO del nombre)
int Kolossos_LayElem(int slot)
{
    return (g_iKolLayForm == KOL_LAY_FORM_ELEMENT) ? slot : 0;
}

// descubre que resuelve un host: devuelve la forma ganadora (-1 = nada),
// deja en tableOut el nombre ganador y en diag la matriz compacta
// "m_AnimOverlay=si(.001) m_animLayers=no" (solo HasEntProp: en players
// JAMAS se escribe)
int Kolossos_LayDiscover(int ent, char[] tableOut, int tableLen, char[] diag, int diagLen)
{
    diag[0] = '\0';
    tableOut[0] = '\0';
    int winner = -1;

    char prop[56], hit[8];
    for (int t = 0; t < 2; t++)
    {
        bool any = false;
        hit[0] = '\0';

        // forma A: %03d — la del dump ("m_AnimOverlay.001.m_nSequence")
        Format(prop, sizeof(prop), "%s.001.m_nSequence", g_sKolLayTables[t]);
        if (HasEntProp(ent, Prop_Send, prop))
        {
            any = true;
            strcopy(hit, sizeof(hit), ".001");
            if (winner < 0)
            {
                winner = KOL_LAY_FORM_PAD3;
                strcopy(tableOut, tableLen, g_sKolLayTables[t]);
            }
        }

        // forma B: sin pad ("m_AnimOverlay.1.m_nSequence")
        if (!any)
        {
            Format(prop, sizeof(prop), "%s.1.m_nSequence", g_sKolLayTables[t]);
            if (HasEntProp(ent, Prop_Send, prop))
            {
                any = true;
                strcopy(hit, sizeof(hit), ".1");
                if (winner < 0)
                {
                    winner = KOL_LAY_FORM_PLAIN;
                    strcopy(tableOut, tableLen, g_sKolLayTables[t]);
                }
            }
        }

        // forma C: la v1.6 ("<tabla>.m_nSequence" + parametro element)
        if (!any)
        {
            Format(prop, sizeof(prop), "%s.m_nSequence", g_sKolLayTables[t]);
            if (HasEntProp(ent, Prop_Send, prop))
            {
                any = true;
                strcopy(hit, sizeof(hit), "elem");
                if (winner < 0)
                {
                    winner = KOL_LAY_FORM_ELEMENT;
                    strcopy(tableOut, tableLen, g_sKolLayTables[t]);
                }
            }
        }

        if (diag[0] != '\0') StrCat(diag, diagLen, " ");
        StrCat(diag, diagLen, g_sKolLayTables[t]);
        StrCat(diag, diagLen, any ? "=si(" : "=no");
        if (any)
        {
            StrCat(diag, diagLen, hit);
            StrCat(diag, diagLen, ")");
        }
    }

    return winner;
}

// v1.6.1: el POR QUE cayo el dummy (linea Capas: de sm_kolossos)
void Kolossos_DummyFailText(char[] out, int maxlen)
{
    switch (g_iKolDummyFail)
    {
        case 1:  Format(out, maxlen, "clase no registrada — %s", g_sKolDummyFailInfo);
        case 2:  Format(out, maxlen, "murio al spawnear — %s", g_sKolDummyFailInfo);
        case 3:  Format(out, maxlen, "rechazo el modelo — %s", g_sKolDummyFailInfo);
        default: strcopy(out, maxlen, "-");
    }
}

void Kolossos_LayerProbe(int av)
{
    g_bKolLayersOK  = false;
    g_iKolLayerSize = 0;
    g_sKolLayPrefix[0] = '\0';
    g_iKolLayForm = -1;

    if (av <= 0 || !IsValidEntity(av)) return;

    // v1.7: el player SIEMPRE se pruebea (la v1.6.1 volvia antes si el
    // host fallaba y la matriz quedaba coja — "player sin sonda"):
    // asi el veredicto queda completo en sm_kolossos (host=no player=no
    // = L4D2 no networka capas para nadie; host=no player=si = el host
    // en concreto no las lleva)
    g_sKolLayDiagPlayer[0] = '\0';
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        char tblP[16];
        Kolossos_LayDiscover(i, tblP, sizeof(tblP),
                             g_sKolLayDiagPlayer, sizeof(g_sKolLayDiagPlayer));
        break;
    }

    // el host...
    char table[16];
    int form = Kolossos_LayDiscover(av, table, sizeof(table),
                                    g_sKolLayDiagDummy, sizeof(g_sKolLayDiagDummy));
    if (form < 0) return;   // sin canal de capas: fusion (veredicto v1.7)
    if (g_sKolLayDiagPlayer[0] == '\0')
        strcopy(g_sKolLayDiagPlayer, sizeof(g_sKolLayDiagPlayer), "sin player conectado");

    strcopy(g_sKolLayPrefix, sizeof(g_sKolLayPrefix), table);
    g_iKolLayForm = form;

    // los slots: el tamano real si la tabla lo expone; si no, se asume
    // MAX_OVERLAYS del engine (15 — se valida abajo con el write test)
    char prop[56];
    int size = 0;
    if (form == KOL_LAY_FORM_ELEMENT)
    {
        Format(prop, sizeof(prop), "%s.m_nSequence", g_sKolLayPrefix);
        size = GetEntPropArraySize(av, Prop_Send, prop);
    }
    else if (HasEntProp(av, Prop_Send, g_sKolLayPrefix))
    {
        size = GetEntPropArraySize(av, Prop_Send, g_sKolLayPrefix);
    }
    if (size < KOL_LAYER_MIN_SIZE) size = 15;

    // verificacion de escritura en el slot 2: el canal acepta, devuelve
    // y restaura (m_nSequence + m_flCycle — los dos campos que el motor
    // escribe sin guarda)
    int elem = Kolossos_LayElem(KOL_LAYER_SHOT);

    Kolossos_LayPath(prop, sizeof(prop), KOL_LAYER_SHOT, "m_nSequence");
    int before   = GetEntProp(av, Prop_Send, prop, _, elem);
    SetEntProp(av, Prop_Send, prop, 0, _, elem);
    int readBack = GetEntProp(av, Prop_Send, prop, _, elem);
    SetEntProp(av, Prop_Send, prop, before, _, elem);
    if (readBack != 0) return;               // el slot no se deja escribir

    Kolossos_LayPath(prop, sizeof(prop), KOL_LAYER_SHOT, "m_flCycle");
    if (!HasEntProp(av, Prop_Send, prop)) return;
    float cBefore = GetEntPropFloat(av, Prop_Send, prop, elem);
    SetEntPropFloat(av, Prop_Send, prop, 0.0, elem);
    float cBack   = GetEntPropFloat(av, Prop_Send, prop, elem);
    SetEntPropFloat(av, Prop_Send, prop, cBefore, elem);
    if (cBack != 0.0) return;

    g_iKolLayerSize = size;
    g_bKolLayersOK  = true;
}

// ¿el motor de capas esta operativo? v1.7: VEREDICTO FINAL — NUNCA.
// La sonda en vivo de la v1.6.1 lo confirmo en el server del owner:
// commentary_dummy hereda la CLASE overlay pero L4D2 no networka el
// array (m_AnimOverlay=no m_animLayers=no en las 6 formas de la
// sonda) — sin send table no hay canal: ni netprops ni SDKCall
// hacen visible una capa para el cliente. El motor queda retirado
// del camino de ejecucion; la sonda vive solo como diagnostico (la
// matriz CanalCapas de sm_kolossos documenta el veredicto por mapa).
bool Kolossos_LayersActive()
{
    return false;
}

// escribe un slot de capa en UN host (todo con guarda: si el .mdl o el
// host no soporta un campo, se escribe lo que haya). v1.6.1: el nombre
// de cada campo se arma con la forma que gano la sonda (en las formas
// punteadas el indice del slot va DENTRO del nombre — la leccion del
// "host prop_dynamic_override")
void Kolossos_LayerWrite(int av, int slot, int seqIdx, float cycle, float weight, int order)
{
    if (av <= 0 || !IsValidEntity(av)) return;

    char prop[56];
    int elem = Kolossos_LayElem(slot);

    Kolossos_LayPath(prop, sizeof(prop), slot, "m_nSequence");
    SetEntProp(av, Prop_Send, prop, seqIdx, _, elem);
    Kolossos_LayPath(prop, sizeof(prop), slot, "m_flCycle");
    SetEntPropFloat(av, Prop_Send, prop, cycle, elem);
    Kolossos_LayPath(prop, sizeof(prop), slot, "m_flPrevCycle");
    if (HasEntProp(av, Prop_Send, prop))
        SetEntPropFloat(av, Prop_Send, prop, cycle, elem);
    Kolossos_LayPath(prop, sizeof(prop), slot, "m_flPlaybackRate");
    if (HasEntProp(av, Prop_Send, prop))
        SetEntPropFloat(av, Prop_Send, prop, 1.0, elem);
    Kolossos_LayPath(prop, sizeof(prop), slot, "m_flWeight");
    if (HasEntProp(av, Prop_Send, prop))
        SetEntPropFloat(av, Prop_Send, prop, weight, elem);
    Kolossos_LayPath(prop, sizeof(prop), slot, "m_flWeightDeltaRate");
    if (HasEntProp(av, Prop_Send, prop))
        SetEntPropFloat(av, Prop_Send, prop, 0.0, elem);   // sin auto-fade del cliente
    Kolossos_LayPath(prop, sizeof(prop), slot, "m_nOrder");
    if (HasEntProp(av, Prop_Send, prop))
        SetEntProp(av, Prop_Send, prop, order, _, elem);
}

// escribe el mismo slot en las DOS copias del avatar (R + L)
void Kolossos_LayerWriteBoth(int client, int slot, int seqIdx, float cycle, float weight, int order)
{
    int av = EntRefToEntIndex(g_iKolAvatar[client]);
    if (av > 0 && IsValidEntity(av))
        Kolossos_LayerWrite(av, slot, seqIdx, cycle, weight, order);
    if (g_iKolAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iKolAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
            Kolossos_LayerWrite(avL, slot, seqIdx, cycle, weight, order);
    }
}

// lanza un ONE-SHOT de la serie grab en la CAPA 2 (brazos) — el main
// sigue en locomocion (piernas). Devuelve false si hay que caer a la
// fusion v1.5 / monocapa (sin capas / secuencia sin resolver)
bool Kolossos_LayerShot(int client, int state, float dur)
{
    if (!Kolossos_LayersActive()) return false;
    if (state < 0 || state >= KOL_ST_COUNT) return false;
    if (g_iKolSeqIdx[state] < 0) return false;   // la sonda no la resolvio

    Kolossos_LayerWriteBoth(client, KOL_LAYER_SHOT, g_iKolSeqIdx[state], 0.0, 1.0, 2);
    g_iKolLayShotState[client] = state;
    g_fKolLayShotStart[client] = GetEngineTime();
    g_fKolLayShotDur[client]   = (dur > 0.15) ? dur : 0.2;
    return true;
}

// apaga la capa del one-shot
void Kolossos_LayerClearShot(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iKolLayShotState[client] < 0) return;
    g_iKolLayShotState[client] = -1;
    Kolossos_LayerWriteBoth(client, KOL_LAYER_SHOT, 0, 0.0, 0.0, 0);
}

// la POSE de sujetar (GrabIdle, el ACT_HOVER del GMod) en la CAPA 1:
// 1 frame congelado — brazos sujetando mientras el main camina/corre.
// Sin resolver GrabIdle: se queda en locomocion pura (degradacion fina)
void Kolossos_LayerHold(int client, bool on)
{
    if (client < 1 || client > MaxClients) return;
    if (on == g_bKolLayHoldOn[client]) return;
    if (!on)
    {
        g_bKolLayHoldOn[client] = false;
        Kolossos_LayerWriteBoth(client, KOL_LAYER_HOLD, 0, 0.0, 0.0, 0);
        return;
    }
    if (!Kolossos_LayersActive()) return;
    if (g_iKolSeqIdx[KOL_ST_GRABHOLD] < 0) return;

    g_bKolLayHoldOn[client] = true;
    Kolossos_LayerWriteBoth(client, KOL_LAYER_HOLD, g_iKolSeqIdx[KOL_ST_GRABHOLD], 0.0, 1.0, 1);
}

// driver per-tick: empuja el m_flCycle de la capa one-shot (el cliente
// NO avanza overlays de entidades no-player — sin esto la capa quedaria
// clavada en 0) y re-afirma la pose de sujetar (sobrevive a la
// reparacion de la copia L y a cualquier re-montaje del avatar R)
public Action T_Kol_LayerThink(Handle timer)
{
    // v2.0: EL PIN DEL RAGDOLL POR FRAME — antes de cualquier gate: el
    // timer es 0.0 (cada tick) y este es el latido del agarre/carry (el
    // 10 Hz de T_KolossosThink es demasiado grueso a 750 u/s: 75u por
    // tick; a 66 Hz son ~11u — el doble pegado al brazo de verdad)
    float nowLay = GetEngineTime();
    Kolossos_VictRagPinThink(nowLay);

    // v2.1: el pin de la WITCH agarrada (misma receta, otro registro) +
    // el vuelo de la ROCA del counter (direccion fija, hitbox barrida) +
    // el bloqueo DETECTA estados al instante (el suyo y el del enemigo)
    Kolossos_WitchRagPinThink(nowLay);
    Kolossos_RockFlightThink(nowLay);
    Kolossos_BlockStateThink(nowLay);

    if (!Kolossos_LayersActive()) return Plugin_Continue;

    float now = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        // la pose de sujetar se re-afirma cada tick mientras este activa
        if (g_bKolLayHoldOn[i] && g_iKolSeqIdx[KOL_ST_GRABHOLD] >= 0)
            Kolossos_LayerWriteBoth(i, KOL_LAYER_HOLD, g_iKolSeqIdx[KOL_ST_GRABHOLD], 0.0, 1.0, 1);

        if (g_iKolLayShotState[i] < 0) continue;

        int av = EntRefToEntIndex(g_iKolAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iKolLayShotState[i] = -1;   // avatar muerto: tracking fuera
            continue;
        }

        float t = (now - g_fKolLayShotStart[i]) / g_fKolLayShotDur[i];
        if (t < 0.0) t = 0.0;
        if (t > 1.0) t = 1.0;

        // el LANZAMIENTO y el REACH duran lo que deben durar: el ciclo
        // llega a 1.0 y la capa se apaga recien ahi (nadie la corta)
        if (t >= 1.0)
        {
            Kolossos_LayerClearShot(i);
            continue;
        }

        Kolossos_LayerWriteBoth(i, KOL_LAYER_SHOT, g_iKolSeqIdx[g_iKolLayShotState[i]], t, 1.0, 2);
    }

    return Plugin_Continue;
}

// =====================================================================
//  v1.5: LA SERIE FUSIONADA — el fallback INTERMEDIO del grab cuando
//  no hay canal de capas (avatar en prop_dynamic_override): la sonda
//  en vivo del owner reporto
//  "Capas: NO DISPONIBLES (slots 0)" — un prop_dynamic de L4D2 NO
//  lleva overlay (CDynamicProp no hereda de CBaseAnimatingOverlay:
//  solo players/NPCs networkan m_AnimOverlay, por eso el Tank lanza
//  rocas con los brazos mientras camina). Y la pagina oficial de
//  VScript que paso el owner lo sella: la API de entidades trae
//  SetSequence / ResetSequence / LookupSequence / GetSequenceDuration
//  y NI UNA funcion de capas o gestos — no existe canal de layers
//  para un prop, ni por netprops ni por Squirrel. LA VIA REAL del
//  port: las 12 secuencias COMPUESTAS del .mdl recompilado con el
//  pack v1.5 (piernas de la locomocion + brazos del grab fundidos en
//  UNA sola seq, mismas fps 60 y mismos frames que la serie base —
//  las duraciones que mide el calibrador aplican igual).
// =====================================================================

// ¿la fusion esta operativa? (convar + las 12 compuestas del .mdl)
bool Kolossos_FusionActive()
{
    return g_cvKolGrabLayers != null && g_cvKolGrabLayers.BoolValue && g_bKolFusionOK;
}

// la locomocion del instante — la misma regla de la FSM (branch [7]):
// plantado < 40 | camina < 150 o en duck | corre por encima
int Kolossos_LocoNow(int client)
{
    float s = Kolossos_Speed2D(client);
    if (s < 40.0)  return KOL_ST_IDLE;
    if (s < 150.0 || (GetClientButtons(client) & IN_DUCK)) return KOL_ST_WALK;
    return KOL_ST_RUN;
}

// un one-shot de la serie grab elige su variante FUSIONADA segun la
// locomocion del instante: el reach / puo / lanzamiento CAMINANDO,
// CORRIENDO o PLANTADO (piernas y brazos en la MISMA seq). Si esa
// pieza en particular no vino nativa en el .mdl, cae al one-shot base
// de la v1.3 — la degradacion es solo visual, la FSM no se entera
int Kolossos_FusedVariant(int client, int state)
{
    if (!Kolossos_FusionActive()) return state;

    int loco = Kolossos_LocoNow(client);
    int fused = state;

    switch (state)
    {
        case KOL_ST_GRABREACH:
            fused = (loco == KOL_ST_RUN)  ? KOL_ST_REACH_RUN
                  : ((loco == KOL_ST_WALK) ? KOL_ST_REACH_WALK : KOL_ST_REACH_IDLE);
        case KOL_ST_GRABPUNCH:
            fused = (loco == KOL_ST_RUN)  ? KOL_ST_PUNCH_RUN
                  : ((loco == KOL_ST_WALK) ? KOL_ST_PUNCH_WALK : KOL_ST_PUNCH_IDLE);
        case KOL_ST_GRABTHROW:
            fused = (loco == KOL_ST_RUN)  ? KOL_ST_THROW_RUN
                  : ((loco == KOL_ST_WALK) ? KOL_ST_THROW_WALK : KOL_ST_THROW_IDLE);
        default:
            return state;   // no es de la serie: tal cual
    }

    return g_bKolFusedNative[fused] ? fused : state;
}

// el dispatcher de la serie grab (v1.7: SOLO COMPUESTAS — sin fusion
// el agarre queda en locomocion pura, los gestures crudos jamas van
// como main por el Root volteado). La DURACION que llega es la de la
// serie BASE y aplica igual: las compuestas traen los mismos frames
// del grab (31/51/61 @ 60fps del .qc v1.5)
void Kolossos_GrabShot(int client, int state, float dur, int tier)
{
    // v1.7: SOLO COMPUESTAS. Los gestures crudos del grab traen el Root
    // volteado (-90 de roll en todos los frames: en GMod vivian en una
    // capa con weightlist que lo enmascaraba) — puestos como main el
    // cuerpo entero gira de lado ("volteado al lado inverso"). Sin
    // fusion no se dispara ningun one-shot: el agarre queda en
    // locomocion pura y la victima en vilo delante es la senal visual
    if (Kolossos_LayerShot(client, state, dur)) return;   // inerte (veredicto v1.7)
    if (!Kolossos_FusionActive()) return;

    int fused = Kolossos_FusedVariant(client, state);
    if (fused == state) return;   // la compuesta de esta loco no vino nativa: NADA crudo

    Kolossos_AnimShot(client, fused, dur, tier);
}

// transmit: R la ven TODOS menos el dueno; L solo el dueno
public Action Kolossos_TransmitAvatarR(int entity, int client)
{
    if (Kolossos_PlayerIs(client)) return Plugin_Handled;
    return Plugin_Continue;
}

public Action Kolossos_TransmitAvatarL(int entity, int client)
{
    if (Kolossos_PlayerIs(client)) return Plugin_Continue;
    return Plugin_Handled;
}

void Kolossos_CreateAvatarL(int client)
{
    if (!g_bKolModelOK) return;
    if (!Kolossos_Valid(client)) return;
    if (g_iKolAvatar[client] == 0) return;

    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));
    int av = Kolossos_CreateAvatarProp(client, mdl, KOL_AVATAR_NAME_L);
    if (av == 0) return;

    char seqIdle[24];
    Kolossos_SeqFor(KOL_ST_IDLE, seqIdle, sizeof(seqIdle));
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Kolossos_TransmitAvatarL);
    g_iKolAvatarL[client] = EntIndexToEntRef(av);
}

void Kolossos_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iKolAvatarL[client]);
    if (g_iKolAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Kolossos_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iKolAvatarL[client] = 0;
}

void Kolossos_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    // v1.9: los dobles PINNEADOS a este avatar se caen con el — liberar
    // (los FLIGHT siguen su vuelo: no estan parenteados). El grab cae
    // al pegado v1.8 en el proximo tick y el carry los suelta
    for (int v = 1; v <= MaxClients; v++)
    {
        if (g_iKolVictRag[v] != 0 && g_iKolVictRagOwner[v] == client
            && g_iKolVictRagMode[v] != KOL_RAGMODE_FLIGHT)
            Kolossos_VictRagEnd(v, true);
    }

    Kolossos_HandMarkKill(client);   // v2.0: el marcador de la mano muere con el avatar

    Kolossos_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iKolAvatar[client]);
    if (g_iKolAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Kolossos_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iKolAvatar[client] = 0;
    g_iKolAnimState[client] = -1;

    // devolver el cuerpo (spectate/revive/cambio de personaje)
    if (IsClientInGame(client) && g_iKolBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iKolBodyRender[client]));
        g_iKolBodyRender[client] = -1;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Kolossos_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Kolossos_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Kolossos_AvatarFollow);
}

void Kolossos_CreateAvatar(int client)
{
    if (!Kolossos_Valid(client)) return;

    // limpieza del ciclo anterior (reemplazo limpio)
    Kolossos_KillAvatar(client);

    // adopcion: todo prop de ESTE modulo que la FSM no rastrea = huerfano
    Kolossos_KillGhostAvatarProps();

    char mdl[PLATFORM_MAX_PATH];
    g_cvKolModel.GetString(mdl, sizeof(mdl));
    int av = Kolossos_CreateAvatarProp(client, mdl, KOL_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    Kolossos_ResolveSeqs(av);
    // (v1.5: la sonda de fusion ya corrio dentro de ResolveSeqs —
    // walk_hold & co solo existen si el .mdl fue recompilado con el
    // pack v1.5; sin ellas todo cae a la monocapa sin romper nada)

    // v1.6: la sonda de CAPAS — una vez por mapa, antes de animar nada
    // (v1.6.1: MULTI-FORMA — el indice del elemento del array va DENTRO
    // del nombre de la prop "m_AnimOverlay.001.m_nSequence", la leccion
    // del "host prop_dynamic_override")
    if (!g_bKolLayersOK)
        Kolossos_LayerProbe(av);

    // v1.3: medir las duraciones reales de la serie del grab contra el
    // .mdl ("debe durar lo que debe durar") — una vez por mapa
    Kolossos_CalibStart();

    char seqIdle[24];
    Kolossos_SeqFor(KOL_ST_IDLE, seqIdle, sizeof(seqIdle));
    SetVariantString(seqIdle);
    AcceptEntityInput(av, "SetAnimation");
    g_iKolAnimState[client] = KOL_ST_IDLE;

    SDKHook(av, SDKHook_SetTransmit, Kolossos_TransmitAvatarR);

    // v1.2: el ref de la R ANTES de crear la L — CreateAvatarL valida que
    // la R exista, y en v1.0/v1.1 este ref se asignaba DESPUES: la copia
    // L (la que ve el DUENO) nacia solo por la auto-reparacion de la FSM
    // 0.1s tarde, con el cuerpo ya en RENDER_NONE = una decima de
    // invisibilidad total en cada montaje. Ahora nace en el mismo tick.
    g_iKolAvatar[client] = EntIndexToEntRef(av);

    g_iKolAvatarL[client] = 0;
    Kolossos_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iKolBodyRender[client] = view_as<int>(curMode);
    else if (g_iKolBodyRender[client] == -1)
        g_iKolBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    // per-tick: angulos locales (contra-rotacion del parent)
    SDKHook(client, SDKHook_PostThink, Kolossos_AvatarFollow);

    // pulso de pausa en cada montaje (la infra del suite)
    Tails_PauseFix_Trigger(client);

    if (!g_bKolWelcomeSaid[client] && !IsFakeClient(client))
    {
        g_bKolWelcomeSaid[client] = true;
        PrintToChat(client, "\x04[Kolossos]\x01 Avatar espejo activo — 14o avatar del suite. Z Carga | X Agarre | C Indicator | B Bloqueo.");
    }
}

// (patron Blaze_IsMyAvatarRef — huerfanos por definicion)
bool Kolossos_IsMyAvatarRef(int ref)
{
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iKolAvatar[i] == ref) return true;
        if (g_iKolAvatarL[i] == ref) return true;
    }
    return false;
}

void Kolossos_KillGhostAvatarProps()
{
    // v1.6: se barren AMBOS hosts — el avatar puede ser commentary_dummy
    // (nuevo) o prop_dynamic_override (fallback); un huerfano de cualquiera
    // de las dos clases con nuestro targetname va a la basura
    char name[32];
    for (int cls = 0; cls < 2; cls++)
    {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, cls == 0 ? "prop_dynamic_override" : "commentary_dummy")) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            GetEntPropString(ent, Prop_Data, "m_iName", name, sizeof(name));
            if (StrEqual(name, KOL_AVATAR_NAME) || StrEqual(name, KOL_AVATAR_NAME_L))
            {
                if (!Kolossos_IsMyAvatarRef(EntIndexToEntRef(ent)))
                    AcceptEntityInput(ent, "Kill");   // huerfano
            }
        }
    }

    // v2.0: el marcador de la mano (info_target pegado al attachment) —
    // mismo barrido anti-huerfanos: si nadie lo reclama, fuera
    int mk = -1;
    while ((mk = FindEntityByClassname(mk, "info_target")) != -1)
    {
        if (!IsValidEntity(mk)) continue;
        GetEntPropString(mk, Prop_Data, "m_iName", name, sizeof(name));
        if (!StrEqual(name, KOL_HANDMARK_NAME)) continue;
        if (EntRefToEntIndex(g_iKolHandMark[Kolossos_MarkOwnerOf(mk)]) != mk)
            AcceptEntityInput(mk, "Kill");
    }
}

// quien es el dueno de este marcador (para el barrido de huerfanos)
int Kolossos_MarkOwnerOf(int mk)
{
    for (int i = 1; i <= MaxClients; i++)
        if (g_iKolHandMark[i] != 0 && EntRefToEntIndex(g_iKolHandMark[i]) == mk)
            return i;
    return 0;
}

// per-tick: yaw suavizado 900 grados/s + TP/local del R + contra-rotacion L
public void Kolossos_AvatarFollow(int client)
{
    if (g_iKolAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Kolossos_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    float yawObj = g_fKolBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fKolBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    float now = GetEngineTime();
    float dt  = now - g_fKolYawLastT[client];
    g_fKolYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fKolBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fKolBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bKolSmSnap[client];
    GetClientAbsAngles(client, par);
    float yawPuppet = g_fKolBodyYaw[client];

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iKolAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        if (Tails_AvatarTPOn())
        {
            float posTP[3], angTP[3];
            GetClientAbsOrigin(client, posTP);
            angTP[0] = 0.0;
            angTP[1] = yawPuppet;
            angTP[2] = 0.0;
            TeleportEntity(av, posTP, angTP, NULL_VECTOR);
            Tails_MarkInterp(av);
        }
        else
        {
            Tails_AvatarLocalAngles(par[0], par[1], yawPuppet, loc);
            loc[1] = Tails_UnwrapYaw(g_fKolSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fKolSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fKolSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }
    g_bKolSmSnap[client] = false;

    // ---- copia L: contra-rotada contra los EYE del dueno ----
    // v1.1 FIX DEL DOBLADO (reporte del owner: "si muevo la camara el
    // personaje se dobla a mirar" — el bug v5.4 de la era Tails): la
    // copia L es la que ve el DUEÑO, y SU cliente arma el parent con el
    // cuerpo PREDICHO = camara completa (pitch incluido). Contra-rotar
    // contra los ABS angles (lo que hizo la v1.0) deja el pitch de la
    // mirada SIN cancelar en su pantalla -> el coloso se inclina con la
    // camara y al pausar queda doblado. La receta correcta es la del
    // Tails v5.17-B / Blaze: GetClientEyeAngles + Tails_AvatarLocalAngles
    // -> vertical SIEMPRE en la pantalla del dueno (ergido tambien al
    // pausar: la ultima escritura cancela el ultimo pitch de la camara).
    if (g_iKolAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iKolAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], yawPuppet, loc);
            loc[1] = Tails_UnwrapYaw(g_fKolSmLocL[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fKolSmLocL[client], 0.05, dt, false);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fKolSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
}

// v1.1: lanza una animacion ONE-SHOT (Kill / slaminwall / counters /
// BlockStart) que bloquea la FSM hasta su fin — el equivalente del
// PillAnim directo del GMod para las anims que no son estados continuos.
// v1.3: + PRIORIDAD (tier): un disparo nuevo solo pisa al activo si es
// de igual o mayor categoria — el LANZAMIENTO (KOL_SHOT_MAX) no lo
// corta nadie, como pidio el owner ("debe durar lo que debe durar")
void Kolossos_AnimShot(int client, int state, float dur, int tier)
{
    if (client < 1 || client > MaxClients) return;

    float now = GetEngineTime();
    if (g_iKolAnimShotState[client] >= 0 && now < g_fKolAnimShotUntil[client]
        && tier < g_iKolAnimShotTier[client])
        return;   // uno de mayor prioridad esta sonando: NO se pisa

    g_iKolAnimShotState[client] = state;
    g_fKolAnimShotUntil[client] = now + dur;
    g_iKolAnimShotTier[client]  = tier;
}

// v1.3: duracion de un one-shot de la serie grab — la medida EN VIVO
// contra el .mdl si el calibrador pudo correr; si no, el fallback 30fps
// de los SMD (31/51/61 frames)
float Kolossos_ShotDur(int state, float fallback)
{
    if (g_fKolSeqDur[state] > 0.15) return g_fKolSeqDur[state];
    return fallback;
}

// anims del avatar — v1.1: EL ARBOL COMPLETO de prioridades del Lua.
// ShouldAlternate manda el orden: stun > agarre (run->walk) > bloqueo >
// chargestart > charge (impaled/no) ; los one-shot por encima de todo;
// animrates: charge 1.2 | lunge del grab 3x | curva L4D2 para el run
void Kolossos_AvatarUpdate(int client, int av, float now)
{
    int state;
    float rate = 1.0;

    // ---- [1] one-shot activo (Kill / slaminwall / counter / BlockStart) ----
    if (g_iKolAnimShotState[client] >= 0 && now < g_fKolAnimShotUntil[client])
    {
        state = g_iKolAnimShotState[client];
    }
    else
    {
        if (g_iKolAnimShotState[client] >= 0)
        {
            g_iKolAnimShotState[client] = -1;
            g_iKolAnimShotTier[client]  = KOL_SHOT_ACT;   // v1.3
        }

        // ---- [2] aturdido (ShouldAlternate: "stun" en todos los estados) ----
        // v2.2: el stun NATIVO de L4D2 tambien cuenta — pounce/lengua/
        // carry/pummel/jockey (los 5 punteros) + stagger/knockdown (la
        // ventana del manager) + el OM_Stun del suite de siempre
        if (Kolossos_AnyStun(client))
        {
            state = KOL_ST_STUN;
        }
        // ---- [3] victima en vilo — v1.6 CAPAS REALES / v1.5 FUSION ----
        //      Con el avatar en commentary_dummy (kolossos_grab_layers
        //      1): el main es SOLO locomocion y la pose de sujetar vive
        //      en la CAPA 1 — brazos y piernas INDEPENDIENTES, el
        //      sistema exacto del GMod (AddGesture ACT_HOVER sobre la
        //      locomocion). Si no hay canal de capas: la fusion v1.5
        //      (walk_hold / run_hold / idle_hold, piernas y brazos en
        //      la MISMA seq). En el aire: jump/fall (regla "piernas
        //      nunca se congelan"). Con el modelo viejo: monocapa v1.3.
        else if (g_iKolGrabVictim[client] != 0)
        {
            if (!(GetEntityFlags(client) & FL_ONGROUND))
            {
                float hvel[3];
                GetEntPropVector(client, Prop_Data, "m_vecVelocity", hvel);
                state = (hvel[2] > 40.0) ? KOL_ST_JUMP : KOL_ST_FALL;
            }
            else if (Kolossos_LayersActive())
            {
                // v1.6: el main queda en PURA locomocion — la pose de
                // sujetar esta en la capa 1 (LayerHold) y los one-shots
                // en la capa 2 (LayerShot): PIERNAS VIVAS siempre
                int loco = Kolossos_LocoNow(client);
                state = (loco == KOL_ST_RUN)  ? KOL_ST_RUN
                      : ((loco == KOL_ST_WALK) ? KOL_ST_WALK : KOL_ST_IDLE);
            }
            else if (Kolossos_FusionActive())
            {
                int loco = Kolossos_LocoNow(client);
                state = (loco == KOL_ST_RUN)  ? KOL_ST_HOLD_RUN
                      : ((loco == KOL_ST_WALK) ? KOL_ST_HOLD_WALK : KOL_ST_HOLD_IDLE);
            }
            else
            {
                // v1.7: sin fusion = LOCOMOCION PURA. El GrabIdle crudo
                // como main trae el Root volteado (forense SMD: -90 de
                // roll en todos los frames del gesture) — JAMAS un
                // gesture crudo como secuencia principal; la victima en
                // vilo delante es la senal del agarre
                state = (Kolossos_Speed2D(client) > 40.0) ? KOL_ST_WALK : KOL_ST_IDLE;
            }
        }
        // ---- [4] bloqueo en pie (ShouldAlternate: "BlockPos") ----
        else if (g_fKolBlockUntil[client] > now)
        {
            state = KOL_ST_BLOCK;
        }
        // ---- [5] windup de la avalancha (ShouldAlternate: "chargestart") ----
        else if (g_iKolChargeState[client] == KOL_CHG_WINDUP)
        {
            state = KOL_ST_CHARGESTART;
        }
        // ---- [6] avalancha: impalados o no (rate 1.2 del animrates) ----
        else if (g_iKolChargeState[client] == KOL_CHG_DASH)
        {
            bool imp = (g_hKolHitList[client] != null && g_hKolHitList[client].Length > 0);
            state = imp ? KOL_ST_CHARGE_IMP : KOL_ST_CHARGE;
            rate  = 1.2;
        }
        else
        {
            bool lunge = (g_fKolLungeUntil[client] > now);

            // ---- [7] aire (jump2="jump" / glide="fall") ----
            if (!(GetEntityFlags(client) & FL_ONGROUND))
            {
                float vel[3];
                GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
                state = (vel[2] > 40.0) ? KOL_ST_JUMP : KOL_ST_FALL;
            }
            else if (g_iKolAnimState[client] == KOL_ST_JUMP
                     && now - g_fKolJumpStart[client] < 0.5)
            {
                state = KOL_ST_JUMP;   // FL_ONGROUND parpadea en escalones
            }
            else
            {
                float s = Kolossos_Speed2D(client);
                if (s < 40.0)               state = KOL_ST_IDLE;
                else if (s < 150.0
                         || (GetClientButtons(client) & IN_DUCK)) state = KOL_ST_WALK;
                else
                {
                    state = KOL_ST_RUN;
                    rate  = 1.32 * (s / 450.0);   // curva L4D2 (GMod base 1.05)
                    if (rate < 0.72) rate = 0.72;
                    if (rate > 3.6)  rate = 3.6;
                }
            }

            // ---- [8] lunge del grab: paso a 3x (animrates walk/run=3) ----
            if (lunge && (state == KOL_ST_WALK || state == KOL_ST_RUN)) rate = 3.0;
        }
    }

    if (state != g_iKolAnimState[client])
    {
        if (state == KOL_ST_JUMP) g_fKolJumpStart[client] = now;

        char seqUse[24];
        Kolossos_SeqFor(state, seqUse, sizeof(seqUse));

        SetVariantString(seqUse);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iKolAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iKolAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                SetVariantString(seqUse);   // el variant es de UN SOLO USO
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iKolAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iKolAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iKolAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

// =====================================================================
//  [Z] HABILIDAD 1 — CHARGE (la avalancha empaladora)
//  GMod l.2311-2397: windup 0.8 (suspiro 0.15 / rumble 0.35 / rugido
//  0.75) -> Charging_kolossos 7s a velocidad charge; esfera 90u:
//  ChargeImpaleDamage + HitList + extension 3.75s por victima; fling
//  final (fwd*5000+up*2000 en GMod = fwd*500+up*300 en L4D2).
//  Receta de movimiento: Metal v5.0 (stack + auto-forward + DEBRIS).
// =====================================================================

void Kolossos_Ability1(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    // puo durante un agarre = pegarle al agarrado (GMod l.2566)
    if (g_iKolGrabVictim[client] != 0)
    {
        Kolossos_GrabPunch(client);
        return;
    }

    if (g_iKolChargeState[client] != KOL_CHG_IDLE)
    {
        PrintCenterText(client, "Ya estas en avalancha.");
        return;
    }
    if (g_fKolLungeUntil[client] > now
        || g_fKolBlockUntil[client] > now
        || g_fKolIndUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolChargeCdUntil[client])
    {
        PrintCenterText(client, "Charge: %.1fs", g_fKolChargeCdUntil[client] - now);
        return;
    }

    g_fKolChargeCdUntil[client] = now + g_cvKolChgCd.FloatValue;

    // ---- WINDUP 0.8s: congelado, suspiro -> rumble -> rugido ----
    g_iKolChargeState[client]  = KOL_CHG_WINDUP;
    g_fKolWindupStart[client]  = now;
    g_fKolChargeEnd[client]    = now + KOL_CHG_WINDUP_T + g_cvKolChgDur.FloatValue;
    g_fKolStuckSince[client]   = 0.0;

    if (g_hKolHitList[client] == null)
        g_hKolHitList[client] = new ArrayList();
    else
        g_hKolHitList[client].Clear();

    // sonido de arranque + stages del windup (GMod timer.Simple;
    // codigo = userid*10 + stage — userids grandes ya no rompen el decode)
    Kolossos_Emit(client, g_bKolSndStartup, "om/kolossos/StartUpCharge.wav",
                  "npc/attack_helicopter/aheli_charge_up.wav");
    CreateTimer(KOL_CHG_WINDUP_SIGH, Kolossos_T_WindupStage, GetClientUserId(client) * 10 + 0);
    CreateTimer(KOL_CHG_WINDUP_RUMBLE, Kolossos_T_WindupStage, GetClientUserId(client) * 10 + 1);
    CreateTimer(KOL_CHG_WINDUP_ROAR, Kolossos_T_WindupStage, GetClientUserId(client) * 10 + 2);

    PrintCenterText(client, "Cargando la avalancha...");
}

// stages del windup: 0=suspiro 1=rumble 2=rugido (codigo = userid*10 + stage)
public Action Kolossos_T_WindupStage(Handle timer, int code)
{
    int stage = code % 10;
    int client = GetClientOfUserId(code / 10);
    if (client < 1 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (g_iKolChargeState[client] != KOL_CHG_WINDUP) return Plugin_Stop;

    switch (stage)
    {
        case 0: Kolossos_Emit(client, g_bKolSndSigh, "om/kolossos/kol sigh i think.wav", "");
        case 1: Kolossos_Emit(client, g_bKolSndRumble, "om/kolossos/kol charge start ground rumble.wav",
                              "ambient/machines/thumper_startup1.wav");
        case 2:
        {
            Kolossos_Emit(client, g_bKolSndRoar, "om/kolossos/KolossosChargeRoar.wav",
                          "npc/attack_helicopter/aheli_alert1.wav");
            // transicion WINDUP -> DASH (la FSM toma el control desde aqui)
            Kolossos_ChargeLaunch(client);
        }
    }
    return Plugin_Stop;
}

// el arranque de la avalancha (receta Metal v5.0: stack + impulso + DEBRIS)
void Kolossos_ChargeLaunch(int client)
{
    g_iKolChargeState[client] = KOL_CHG_DASH;

    // restaurar el lagged del windup y topear la velocidad por el stack
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    Kolossos_DashSpeedSet(client, g_cvKolChgSpeed.FloatValue);

    // DEBRIS: atraviesa cuerpos durante la avalancha (como el mod)
    if (g_iKolSavedColGroup[client] == -1)
    {
        g_iKolSavedColGroup[client] = GetEntProp(client, Prop_Data, "m_CollisionGroup");
        SetEntProp(client, Prop_Data, "m_CollisionGroup", KOL_CHG_COLGROUP);
    }

    // impulso de arranque (el tope ya alzado clampea el motor)
    float dir[3], vel[3];
    Kolossos_GetMoveDir(client, dir);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[0] = dir[0] * (KOL_CHG_LAUNCH_MIN < g_cvKolChgSpeed.FloatValue ? g_cvKolChgSpeed.FloatValue : KOL_CHG_LAUNCH_MIN);
    vel[1] = dir[1] * (KOL_CHG_LAUNCH_MIN < g_cvKolChgSpeed.FloatValue ? g_cvKolChgSpeed.FloatValue : KOL_CHG_LAUNCH_MIN);
    if (GetEntityFlags(client) & FL_ONGROUND)
        vel[2] = 0.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    // camara de velocidad (receta Metal)
    SetEntProp(client, Prop_Send, "m_iFOV", KOL_CHG_FOV);
    SetEntProp(client, Prop_Send, "m_iFOVStart", KOL_CHG_FOV);

    PrintCenterText(client, "AVALANCHA!");
}

// tope de velocidad via el stack del Speed_sonic (receta Metal_DashSpeedSet)
void Kolossos_DashSpeedSet(int client, float target)
{
    float base = Speed_GetBaseSpeed(client);
    if (base < 50.0) base = 220.0;
    float extra = target / base - 1.0;
    if (extra < 0.0) extra = 0.0;
    Speed_StackSet(client, SPEED_STACK_KOLOSSOS, extra);
}

// fin de la avalancha: timeout / pared / cancel / muerte
void Kolossos_ChargeEnd(int client, bool hitWall)
{
    if (g_iKolChargeState[client] == KOL_CHG_IDLE) return;

    // v2.1: LA SALIDA PRIMERO — la v2.0 dejaba el "= IDLE" de ULTIMA
    // linea y una excepcion en el fling (el GetEntProp del
    // m_hMoveParent) abortaba ChargeEnd ANTES de llegar ahi: el estado
    // quedaba en DASH para siempre y el FSM re-llamaba ChargeEnd cada
    // tick = la lluvia de "Data field m_hMoveParent is not an integer"
    // del log. Con la salida arriba, NADA de lo que pase despues puede
    // volver a clavar la avalancha.
    int chgState = g_iKolChargeState[client];
    g_iKolChargeState[client] = KOL_CHG_IDLE;

    // lagged del windup si quedo clavado en 0
    if (chgState == KOL_CHG_WINDUP)
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);

    // fuera DEBRIS + slot del stack + frenado suave + FOV
    if (g_iKolSavedColGroup[client] > 0)
        SetEntProp(client, Prop_Data, "m_CollisionGroup", g_iKolSavedColGroup[client]);
    g_iKolSavedColGroup[client] = -1;
    Speed_StackSet(client, SPEED_STACK_KOLOSSOS, 0.0);

    if (IsClientInGame(client) && IsPlayerAlive(client))
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntProp(client, Prop_Send, "m_iFOV", 0);
        SetEntProp(client, Prop_Send, "m_iFOVStart", 0);

        float vel[3], endVel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        endVel[0] = vel[0] * 0.25;
        endVel[1] = vel[1] * 0.25;
        endVel[2] = vel[2];
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, endVel);
    }

    // fling de las victimas vivas de la HitList (el GMod las suelta volando)
    // v1.1: capturar ANTES si habia empalados (FlingHitList vacia la lista)
    bool hadImpaled = (g_hKolHitList[client] != null && g_hKolHitList[client].Length > 0);
    Kolossos_FlingHitList(client, hitWall);

    // tope de pared: slaminwall con empalados (anim 1.3s + Sound.mp3) o
    // el wall bump seco sin ellos (GMod l.1729-1747); CD 3.65s en ambos
    if (hitWall && IsClientInGame(client) && IsPlayerAlive(client))
    {
        if (hadImpaled)
        {
            Kolossos_AnimShot(client, KOL_ST_SLAMINWALL, 1.3, KOL_SHOT_ACT);
            Kolossos_Emit(client, g_bKolSndSlam, "om/kolossos/Sound.mp3",
                          "physics/concrete/concrete_break2.wav");
        }
        else
        {
            Kolossos_Emit(client, g_bKolSndWallBump, "om/kolossos/Kol wall bump.wav",
                          "physics/concrete/concrete_break2.wav");
        }
    }
}

// las victimas empaladas que siguen vivas salen volando al final
void Kolossos_FlingHitList(int client, bool hitWall)
{
    if (g_hKolHitList[client] == null) return;

    float dir[3];
    Kolossos_GetMoveDir(client, dir);

    // contra la pared: direccion aleatoria (GMod l.1914-1931)
    if (hitWall)
    {
        switch (GetRandomInt(0, 2))
        {
            case 0: { dir[0] = 1.0;  dir[1] = 0.0; }   // derecha
            case 1: { dir[0] = -1.0; dir[1] = 0.0; }   // izquierda
            case 2: { /* sigue de frente */ }
        }
    }

    float push[3];
    push[0] = dir[0] * KOL_CHG_FLING_FWD;
    push[1] = dir[1] * KOL_CHG_FLING_FWD;
    push[2] = KOL_CHG_FLING_UP;

    int n = g_hKolHitList[client].Length;
    for (int i = 0; i < n; i++)
    {
        int ent = EntRefToEntIndex(g_hKolHitList[client].Get(i));
        if (ent <= 0 || !IsValidEntity(ent)) continue;

        if (ent > 0 && ent <= MaxClients)
        {
            if (!IsClientInGame(ent) || !IsPlayerAlive(ent)) continue;
            if (GetClientTeam(ent) != 3) continue;   // solo infectados

            // v1.9: con doble ragdoll el que VUELA es el doble (impulso
            // por hueso + follow congruente — la victima revive donde
            // caiga); sin doble, el empujon directo de siempre
            if (Kolossos_VictRagActive(ent))
            {
                float ldir[3];
                ldir[0] = push[0]; ldir[1] = push[1]; ldir[2] = 0.0;
                NormalizeVector(ldir, ldir);
                Kolossos_VictRagLaunch(client, ent, ldir, KOL_CHG_FLING_FWD);
            }
            else
                TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
        }
        else
        {
            // commons/witch arrastrados: DESPEGARLOS del avatar y volar
            // v2.1: m_hMoveParent es un EHANDLE — GetEntProp crudo
            // reventaba con "Data field m_hMoveParent is not an integer
            // (13)" en CADA victima entidad (el bug del log 19:27): va
            // con GetEntPropEnt como TODAS las demas lecturas del file
            if (GetEntPropEnt(ent, Prop_Data, "m_hMoveParent") != -1)
            {
                SetVariantString("");
                AcceptEntityInput(ent, "SetParent", ent, ent);
            }
            if (GetEntProp(ent, Prop_Data, "m_iHealth") > 0 && HasEntProp(ent, Prop_Data, "m_vecVelocity"))
                TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
    g_hKolHitList[client].Clear();
}

// el tick del DASH (10 Hz): tope re-afirmado, impacto de empale, watchdog
void Kolossos_ChargeDashThink(int client, float now)
{
    // tope + FOV re-afirmados (auto-cura, receta Metal)
    Kolossos_DashSpeedSet(client, g_cvKolChgSpeed.FloatValue);
    SetEntProp(client, Prop_Send, "m_iFOV", KOL_CHG_FOV);
    SetEntProp(client, Prop_Send, "m_iFOVStart", KOL_CHG_FOV);

    // ---- impacto: esfera frontal, sin repetir victimas (HitList) ----
    // REGLA v3.77.85 (crash silencioso de la horda): el dano NUNCA va
    // dentro del FindEntityByClassname — SNAPSHOT de refs primero, dano
    // DESPUES re-validando (un comun muerto libera su edicto al instante).
    float pos[3], dir[3];
    GetClientAbsOrigin(client, pos);
    Kolossos_GetMoveDir(client, dir);
    pos[0] += dir[0] * 30.0;
    pos[1] += dir[1] * 30.0;
    pos[2] += 40.0;

    float radius = g_cvKolChgRadius.FloatValue;
    float dmg    = g_cvKolChgDmg.FloatValue;
    bool  newVictim = false;

    int   snapEnts[64];
    bool  snapIsSI[64];
    int   snapCount = 0;

    // 1) commons ("infected") — solo SNAPSHOT
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (GetVectorDistance(epos, pos) > radius) continue;
        if (Kolossos_OnHitList(client, ent)) continue;

        Kolossos_HitListAdd(client, ent);
        newVictim = true;
        snapEnts[snapCount] = ent;
        snapIsSI[snapCount] = false;
        snapCount++;
    }

    // 2) infectados especiales (clients team 3) + tank — solo SNAPSHOT
    for (int t = 1; t <= MaxClients && snapCount < 64; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (GetVectorDistance(tpos, pos) > radius) continue;
        if (Kolossos_OnHitList(client, t)) continue;

        Kolossos_HitListAdd(client, t);
        newVictim = true;
        snapEnts[snapCount] = t;
        snapIsSI[snapCount] = true;
        snapCount++;
    }

    // 3) witch (entidad, no client) — solo SNAPSHOT
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(w)) continue;
        if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
        float wpos[3];
        GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
        if (GetVectorDistance(wpos, pos) > radius) continue;
        if (Kolossos_OnHitList(client, w)) continue;

        Kolossos_HitListAdd(client, w);
        newVictim = true;
        snapEnts[snapCount] = w;
        snapIsSI[snapCount] = false;   // witch: dano puro, sin stun
        snapCount++;
    }

    // 4) EL DAÑO VA AQUI — fuera de los bucles, re-validando cada ref
    for (int k = 0; k < snapCount; k++)
    {
        int v = snapEnts[k];
        if (v <= 0 || !IsValidEntity(v)) continue;
        if (snapIsSI[k] && (v <= MaxClients))
        {
            if (!IsClientInGame(v) || !IsPlayerAlive(v)) continue;
            OM_AbilityDamage(v, client, dmg);
            OM_Stun(v, 1.0, client, 0.0, DMG_OM_CLUB, false);   // aturdido 1s

            // v1.9: LLEVAR POR DELANTE — el especial viaja OCULTO con su
            // doble ragdoll clavado DELANTE del coloso (Lua l.1850+: el
            // CreateRagdolLCharacter_OM con el pin fwd*40+up*40)
            if (g_cvKolChgCarry != null && g_cvKolChgCarry.BoolValue
                && !Kolossos_VictRagActive(v))
                Kolossos_VictRagSpawn(client, v, KOL_RAGMODE_CHARGEPIN);
        }
        else if (v > MaxClients)
        {
            if (GetEntProp(v, Prop_Data, "m_iHealth") <= 0) continue;
            OM_AbilityDamage(v, client, dmg);

            // v1.9: commons ARRASTRADOS — pegados al frente del avatar
            // (entidades: parent estable), visibles luchando contra la
            // avalancha, tal cual el "llevar por delante".
            // v2.1: LA WITCH NO SE PARENTA JAMAS — el motor la vuelve
            // invisible con el parent (mismo bug del grab): ella solo
            // recibe el empujon del fling final
            if (g_cvKolChgCarry != null && g_cvKolChgCarry.BoolValue
                && !Kolossos_IsWitchEnt(v))
            {
                int avC = EntRefToEntIndex(g_iKolAvatar[client]);
                if (avC > 0 && IsValidEntity(avC)
                    && GetEntPropEnt(v, Prop_Data, "m_hMoveParent") == -1)
                {
                    float avPos[3], cdir[3], cspot[3];
                    GetClientAbsOrigin(client, avPos);
                    Kolossos_GetMoveDir(client, cdir);
                    cspot[0] = avPos[0] + cdir[0] * KOL_CHG_CARRY_F;
                    cspot[1] = avPos[1] + cdir[1] * KOL_CHG_CARRY_F;
                    cspot[2] = avPos[2] + KOL_CHG_CARRY_U;
                    TeleportEntity(v, cspot, NULL_VECTOR, NULL_VECTOR);
                    SetVariantString("!activator");
                    AcceptEntityInput(v, "SetParent", avC, avC);
                }
            }
        }
    }

    if (newVictim)
    {
        Kolossos_Emit(client, g_bKolSndImpacts, "om/kolossos/Kol impacts.wav",
                      "physics/flesh/flesh_impact_hard4.wav");
        if (g_bKolSndLaugh && GetRandomInt(1, 3) == 1)
            EmitSoundToAll("om/kolossos/Kol charge laugh impale.wav", client, _, KOL_SND_LEVEL);

        // extension por victima nueva (GMod ImapleChargeDuration 3.75)
        float newEnd = g_fKolChargeEnd[client] + g_cvKolChgAdd.FloatValue;
        float maxEnd = g_fKolWindupStart[client] + KOL_CHG_WINDUP_T + g_cvKolChgMaxDur.FloatValue;
        if (newEnd > maxEnd) newEnd = maxEnd;
        g_fKolChargeEnd[client] = newEnd;
    }

    // ---- watchdog de atasco / tope de pared (receta Metal_StuckCheck) ----
    if (GetEntityFlags(client) & FL_ONGROUND)
    {
        if (Kolossos_Speed2D(client) < KOL_CHG_STUCK_MINVEL)
        {
            if (g_fKolStuckSince[client] == 0.0)
                g_fKolStuckSince[client] = now;
            else if (now - g_fKolStuckSince[client] >= KOL_CHG_STUCK_TIME)
            {
                Kolossos_ChargeEnd(client, true);   // tope seco
                return;
            }
        }
        else g_fKolStuckSince[client] = 0.0;
    }
    else g_fKolStuckSince[client] = 0.0;

    // ---- fin natural ----
    if (now >= g_fKolChargeEnd[client])
        Kolossos_ChargeEnd(client, false);
}

bool Kolossos_OnHitList(int client, int ent)
{
    if (g_hKolHitList[client] == null) return false;
    return g_hKolHitList[client].FindValue(EntIndexToEntRef(ent)) != -1;
}

void Kolossos_HitListAdd(int client, int ent)
{
    if (g_hKolHitList[client] == null) g_hKolHitList[client] = new ArrayList();
    g_hKolHitList[client].Push(EntIndexToEntRef(ent));
}

// =====================================================================
//  v1.9: EL SISTEMA DE RAGDOLLS DE VICTIMAS (la receta Sonic v6.33 /
//  Amy v106 aplicada al grab/carry: doble prop_ragdoll + original
//  oculto + follow congruente + restauracion vigilada).
//  LA LECCION DEL VIDEO DEL OWNER (v1.8): la v1.8 parentaba a la victima
//  VIVA (un player) y re-assertaba parent+tilt por tick — el engine suelta
//  los parents de players a cada rato, y cada re-assert era un SNAP
//  visible ("hace la animacion de que lo agarro mas de una vez").
//  LA LECCION DEL CAMPO (v1.9 -> v2.0): parentarle el DOBLE tampoco
//  sirve — un prop_ragdoll con vphysics DESPIERTO contra un padre que
//  se mueve es dinamita (cuerpo deformado en el agarre lento, doble
//  DISPARADO al fondo del mapa en la embestida a 750 u/s). EL LUA
//  ORIGINAL NUNCA PARENTA: su shoulddocustomfunction corre CADA TICK y
//  hace headPhys:SetPos(mano) + SetAngles + SetVelocityInstantaneous
//  (vector_origin) — el hueso ancla en la mano y el resto cuelga por
//  fisica. ESO ES EL PIN v2.0: Sonic_RagPhysPin (sonic v6.38, SDKCall
//  SetPosition + velocidad CERO sobre el hueso RAIZ) llamado POR FRAME
//  desde T_Kol_LayerThink. La mano se lee de un info_target pegado al
//  attachment "grabhand" del avatar R. Cada puo pausa el pin 0.4s (la
//  sacudida) y el lanzamiento lo manda con impulso POR HUESO
//  (Sonic_RagPhysLaunch) mientras el original oculto LO SIGUE — y
//  revive DONDE CAYO, tal cual el GMod (CreateRagdolLCharacter_OM).
// =====================================================================

bool Kolossos_VictRagActive(int victim)
{
    if (victim < 1 || victim > MaxClients) return false;
    return g_iKolVictRag[victim] != 0;
}

// el doble de la victima (0 si no esta / murio)
int Kolossos_VictRagOf(int victim)
{
    if (victim < 1 || victim > MaxClients) return 0;
    int rag = EntRefToEntIndex(g_iKolVictRag[victim]);
    if (rag <= MaxClients || !IsValidEntity(rag)) return 0;
    return rag;
}

// spawn del doble + original oculto. mode = GRABPIN / CHARGEPIN.
// La victima debe ser un cliente (SI) vivo; el pin sale diferido
// (KOL_RAG_PIN_DELAY: el beat de fisica que le da el pose colgado).
bool Kolossos_VictRagSpawn(int client, int victim, int mode)
{
    if (victim < 1 || victim > MaxClients) return false;
    if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return false;
    if (Kolossos_VictRagActive(victim)) return true;   // ya tiene uno

    char mdl[PLATFORM_MAX_PATH];
    GetClientModel(victim, mdl, sizeof(mdl));
    if (mdl[0] == '\0') return false;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return false;

    DispatchKeyValue(rag, "model", mdl);
    DispatchSpawn(rag);

    // despertar el vphysics YA (receta sonic v6.6 — ragdoll dormido = clavado)
    AcceptEntityInput(rag, "EnableMotion");
    AcceptEntityInput(rag, "Wake");

    float pos[3], ang[3];
    GetClientAbsOrigin(victim, pos);
    GetClientAbsAngles(victim, ang);
    pos[2] += KOL_RAG_RESTORE_Z;
    TeleportEntity(rag, pos, ang, NULL_VECTOR);
    Sonic_RagMakePassable(rag);   // DEBRIS: el doble no traba contra nada

    // el original FUERA de la vista (el doble es la verdad de mundo)
    g_iKolVictRagRender[victim] = view_as<int>(GetEntityRenderMode(victim));
    SetEntityRenderMode(victim, RENDER_NONE);

    g_iKolVictRag[victim]       = EntIndexToEntRef(rag);
    g_iKolVictRagMode[victim]   = mode;
    g_iKolVictRagOwner[victim]  = client;
    g_bKolVictRagJolted[victim] = false;
    g_fKolVictRagRepinAt[victim] = 0.0;
    g_fKolVictRagPinDelay[victim] = GetEngineTime() + KOL_RAG_PIN_DELAY;
    return true;
}

// v2.0: EL MARCADOR DE LA MANO — un info_target pegado al attachment
// "grabhand" del avatar R ($attachment v1.5.2, hueso RightHand): su
// m_vecAbsOrigin es la posicion MUNDIAL de la mano ANIMADA frame a
// frame (el parent con attachment lo evalua el motor cada tick, gratis
// para nosotros). El pin lo lee POR FRAME. Si el .mdl es el viejo (sin
// attachment) el SetParentAttachment falla y el marcador queda pegado
// al origen del avatar = el doble cuelga de Kolossos (el parent-follow
// v1.8 como fallback, nunca la camara).
int Kolossos_HandMarkGet(int client)
{
    int mk = EntRefToEntIndex(g_iKolHandMark[client]);
    if (mk > 0 && IsValidEntity(mk)) return mk;

    int av = EntRefToEntIndex(g_iKolAvatar[client]);
    if (av <= 0 || !IsValidEntity(av)) return 0;

    mk = CreateEntityByName("info_target");
    if (mk <= 0 || !IsValidEntity(mk)) return 0;
    DispatchKeyValue(mk, "targetname", KOL_HANDMARK_NAME);
    DispatchSpawn(mk);

    SetVariantString("!activator");
    AcceptEntityInput(mk, "SetParent", av, av);
    SetVariantString("grabhand");
    AcceptEntityInput(mk, "SetParentAttachment", av, av);

    g_iKolHandMark[client] = EntIndexToEntRef(mk);
    return mk;
}

void Kolossos_HandMarkKill(int client)
{
    if (client < 1 || client > MaxClients) return;
    int mk = EntRefToEntIndex(g_iKolHandMark[client]);
    if (g_iKolHandMark[client] != 0 && mk > 0 && IsValidEntity(mk))
        AcceptEntityInput(mk, "Kill");
    g_iKolHandMark[client] = 0;
}

// v2.0: EL PIN POR FRAME (la receta literal del Lua l.2160-2169 /
// l.1899-1905) — corre en T_Kol_LayerThink (timer 0.0 = CADA TICK):
// cada doble en modo GRABPIN/CHARGEPIN recibe Sonic_RagPhysPin sobre
// su hueso RAIZ (SetPosition + velocidad CERO) al punto de la MANO
// (agarre) o DELANTE del coloso (embestida). El resto del cuerpo
// cuelga por fisica y la velocidad fantasma NUNCA se acumula (eso era
// lo que disparaba al doble "al fondo del mapa"). Plan B sin SDKCall:
// TeleportEntity con velocidad cero (la via engine, mismo efecto en el
// raiz).
void Kolossos_VictRagPinThink(float now)
{
    for (int v = 1; v <= MaxClients; v++)
    {
        if (g_iKolVictRag[v] == 0) continue;
        int mode = g_iKolVictRagMode[v];
        if (mode != KOL_RAGMODE_GRABPIN && mode != KOL_RAGMODE_CHARGEPIN) continue;

        // el beat de fisica del spawn (el pose colgado) y la pausa de
        // la sacudida del puo: hoy no se clava
        if (g_fKolVictRagPinDelay[v] > 0.0 && now < g_fKolVictRagPinDelay[v]) continue;
        if (g_bKolVictRagJolted[v])
        {
            if (now < g_fKolVictRagRepinAt[v]) continue;
            g_bKolVictRagJolted[v] = false;   // la sacudida termino: re-pin
        }

        int rag = Kolossos_VictRagOf(v);
        if (rag == 0) continue;   // el 10 Hz (VictRagThink) barre huerfanos

        int client = g_iKolVictRagOwner[v];
        if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))
            continue;

        // ---- EL PUNTO DEL PIN ----
        float pinPos[3];
        if (mode == KOL_RAGMODE_GRABPIN)
        {
            // la MANO ANIMADA del avatar (marker pegado al attachment)
            int mk = Kolossos_HandMarkGet(client);
            if (mk > 0 && HasEntProp(mk, Prop_Data, "m_vecAbsOrigin"))
            {
                GetEntPropVector(mk, Prop_Data, "m_vecAbsOrigin", pinPos);
                pinPos[2] -= KOL_RAG_HANG_Z;   // el cuerpo cuelga DEBAJO del puno
            }
            else
            {
                // sin marker (sin avatar): el offset v1.7 de ultima instancia
                float pos[3], dir[3];
                GetClientAbsOrigin(client, pos);
                Kolossos_GetMoveDir(client, dir);
                pinPos[0] = pos[0] + dir[0] * KOL_GRAB_HOLD_DIST;
                pinPos[1] = pos[1] + dir[1] * KOL_GRAB_HOLD_DIST;
                pinPos[2] = pos[2] + KOL_GRAB_HOLD_Z;
            }
        }
        else
        {
            // carry de la embestida: DELANTE del coloso (Lua l.1902:
            // GetPos() + forward*40 + up*40)
            float avPos[3], dir[3];
            GetClientAbsOrigin(client, avPos);
            Kolossos_GetMoveDir(client, dir);
            pinPos[0] = avPos[0] + dir[0] * KOL_CHG_CARRY_F;
            pinPos[1] = avPos[1] + dir[1] * KOL_CHG_CARRY_F;
            pinPos[2] = avPos[2] + KOL_CHG_CARRY_U;
        }

        // ---- LOS ANGULOS: conservar la orientacion que la fisica le
        // dio + el tilt del owner (kolossos_grab_tilt) ----
        float pinAng[3], tmpPos[3];
        if (!Sonic_RagPhysGet(rag, tmpPos, pinAng))
        {
            // plan B de lectura: los angulos actuales de la entidad
            GetEntPropVector(rag, Prop_Data, "m_angAbsRotation", pinAng);
        }
        if (g_cvKolGrabTilt != null && g_cvKolGrabTilt.FloatValue != 0.0)
            pinAng[0] += g_cvKolGrabTilt.FloatValue;

        // ---- EL PIN (receta Lua) ----
        if (!Sonic_RagPhysPin(rag, pinPos, pinAng))
        {
            // plan B engine: TeleportEntity con velocidad CERO mueve el
            // ragdoll entero por el delta — rigido pero anclado igual
            float zero[3];
            TeleportEntity(rag, pinPos, NULL_VECTOR, zero);
        }
    }
}

// el PUO al cuerpo colgado: impulso + pausa del pin (la sacudida — el
// pin se reanuda solo al terminar KOL_RAG_JOLT_REPIN)
void Kolossos_VictRagJolt(int victim)
{
    int rag = Kolossos_VictRagOf(victim);
    if (rag == 0) return;
    AcceptEntityInput(rag, "EnableMotion");
    AcceptEntityInput(rag, "Wake");
    float vel[3];
    vel[0] = GetRandomFloat(-80.0, 80.0);
    vel[1] = GetRandomFloat(-80.0, 80.0);
    vel[2] = KOL_RAG_JOLT_UP;
    TeleportEntity(rag, NULL_VECTOR, NULL_VECTOR, vel);
    g_bKolVictRagJolted[victim] = true;
    g_fKolVictRagRepinAt[victim] = GetEngineTime() + KOL_RAG_JOLT_REPIN;
}

// EL LANZAMIENTO: el doble vuela con impulso POR HUESO (Sonic v6.33),
// el original queda oculto siguiendolo — y revive donde cae
void Kolossos_VictRagLaunch(int client, int victim, const float dir[3], float speed)
{
    int rag = Kolossos_VictRagOf(victim);
    if (rag == 0) return;

    AcceptEntityInput(rag, "EnableMotion");
    AcceptEntityInput(rag, "Wake");

    if (!Sonic_RagPhysLaunch(rag, dir, speed, speed * KOL_RAG_THROW_LIFT, KOL_RAG_THROW_TUMBLE))
        Sonic_RagFlingEngine(rag, dir, speed, speed * KOL_RAG_THROW_LIFT);

    g_iKolVictRagMode[victim] = KOL_RAGMODE_FLIGHT;

    // la victima queda TIRADA mientras el doble vuela/rueda (el stun
    // del OM la mantiene fuera de combate — restauracion al despertar)
    OM_Stun(victim, KOL_RAG_THROW_STUN, client, 0.0, DMG_OM_CLUB, true);
}

// counter: spawn + vuelo INMEDIATO en NUESTRO registro (la receta del
// fling de Sonic v6.35 pero con follow congruente por tick: el original
// oculto persigue al doble y revive donde cae)
bool Kolossos_VictRagFling(int client, int victim, const float dir[3], float speed)
{
    if (!Kolossos_VictRagSpawn(client, victim, KOL_RAGMODE_FLIGHT)) return false;
    int rag = Kolossos_VictRagOf(victim);
    if (rag == 0) return false;
    if (!Sonic_RagPhysLaunch(rag, dir, speed, speed * KOL_CNT_LIFT, KOL_CNT_TUMBLE))
        Sonic_RagFlingEngine(rag, dir, speed, speed * KOL_CNT_LIFT);
    return true;
}

// la victima murio con el doble puesto: soltarlo como CADaver (cae
// donde este, se limpia a los 3s — patron Sonic_DeadFlingCopy) y
// liberar el registro sin teleports
void Kolossos_VictRagCorpse(int victim)
{
    if (victim < 1 || victim > MaxClients) return;
    if (g_iKolVictRag[victim] == 0) return;

    int rag = Kolossos_VictRagOf(victim);
    if (rag != 0)
    {
        AcceptEntityInput(rag, "EnableMotion");
        AcceptEntityInput(rag, "Wake");
        CreateTimer(3.0, Kolossos_T_VictRagCorpseClean, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
    }

    g_iKolVictRag[victim]       = 0;
    g_iKolVictRagMode[victim]   = KOL_RAGMODE_NONE;
    g_iKolVictRagOwner[victim]  = 0;
    g_bKolVictRagJolted[victim] = false;
    g_fKolVictRagRepinAt[victim] = 0.0;
    g_fKolVictRagPinDelay[victim] = 0.0;

    if (IsClientInGame(victim) && g_iKolVictRagRender[victim] != -1)
    {
        SetEntityRenderMode(victim, view_as<RenderMode>(g_iKolVictRagRender[victim]));
        g_iKolVictRagRender[victim] = -1;
    }
}

public Action Kolossos_T_VictRagCorpseClean(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// fin del ciclo: matar el doble, devolverle el render al original y
// (si pidieron) revivirlo DONDE quedo el doble (la congruencia final)
void Kolossos_VictRagEnd(int victim, bool teleportToRag)
{
    if (victim < 1 || victim > MaxClients) return;
    if (g_iKolVictRag[victim] == 0) return;

    int rag = Kolossos_VictRagOf(victim);

    if (teleportToRag && rag != 0 && IsClientInGame(victim) && IsPlayerAlive(victim))
    {
        float ragPos[3];
        GetEntPropVector(rag, Prop_Data, "m_vecOrigin", ragPos);
        ragPos[2] += KOL_RAG_RESTORE_Z;
        TeleportEntity(victim, ragPos, NULL_VECTOR, NULL_VECTOR);
    }

    if (rag != 0) AcceptEntityInput(rag, "Kill");

    g_iKolVictRag[victim]       = 0;
    g_iKolVictRagMode[victim]   = KOL_RAGMODE_NONE;
    g_iKolVictRagOwner[victim]  = 0;
    g_bKolVictRagJolted[victim] = false;
    g_fKolVictRagRepinAt[victim] = 0.0;
    g_fKolVictRagPinDelay[victim] = 0.0;

    if (IsClientInGame(victim) && g_iKolVictRagRender[victim] != -1)
    {
        SetEntityRenderMode(victim, view_as<RenderMode>(g_iKolVictRagRender[victim]));
        g_iKolVictRagRender[victim] = -1;
    }
}

// el latido del registro (10 Hz, desde T_Kolossos): follow congruente
// del original (vuelo Y pins — v2.0: la embestida ya no deja al cuerpo
// real congelado en el sitio invisible) y limpieza de huerfanos (avatar
// muerto / victima liberada / mapa). EL PIN en si vive POR FRAME en
// T_Kol_LayerThink (Kolossos_VictRagPinThink)
void Kolossos_VictRagThink()
{
    for (int v = 1; v <= MaxClients; v++)
    {
        if (g_iKolVictRag[v] == 0) continue;

        int rag = Kolossos_VictRagOf(v);

        // huerfanos: doble muerto o victima fuera de juego -> restaurar
        if (rag == 0 || !IsClientInGame(v))
        {
            Kolossos_VictRagEnd(v, true);
            continue;
        }

        // la victima murio con el doble puesto (la mato otro, no el
        // combo): el doble queda de cadaver donde este
        if (!IsPlayerAlive(v) && g_iKolVictRagMode[v] != KOL_RAGMODE_FLIGHT)
        {
            Kolossos_VictRagCorpse(v);
            continue;
        }

        // v2.0: FOLLOW CONGRUENTE en TODOS los modos — el original
        // oculto se mueve a donde este el doble (tick a tick: los bots
        // y el dano le pegan donde esta el cuerpo que se VE). Antes
        // solo el FLIGHT lo hacia: el original de la EMBESTIDA se
        // quedaba congelado en el sitio del impacto ("el cuerpo real
        // se queda en el sitio invisible" — reporte v1.9)
        if (g_iKolVictRagMode[v] == KOL_RAGMODE_FLIGHT)
        {
            if (!IsPlayerAlive(v))
            {
                Kolossos_VictRagCorpse(v);
                continue;
            }
            if (!OM_IsStunned(v))
            {
                Kolossos_VictRagEnd(v, true);
                continue;
            }
        }

        if (g_iKolVictRagMode[v] != KOL_RAGMODE_NONE && IsPlayerAlive(v))
        {
            float ragPos[3];
            GetEntPropVector(rag, Prop_Data, "m_vecOrigin", ragPos);
            TeleportEntity(v, ragPos, NULL_VECTOR, NULL_VECTOR);
        }
    }

    // v2.1: la WITCH lanzada — su doble vuela y la original (oculta)
    // lo sigue; a los KOL_WITCH_RAG_FLY_MAX revive donde caiga
    Kolossos_WitchRagFollow();
}

// =====================================================================
//  v2.1: LA WITCH DEL GRAB VIAJA COMO RAGDOLL — mismo trato que los
//  clientes. La witch VIVA nunca mas se parenta (SetParent sobre la
//  entidad witch la vuelve INVISIBLE en el motor de L4D2 y a veces no
//  se recupera al soltarla — el reporte del owner): nace su DOBLE
//  prop_ragdoll pineado por frame a la mano (Kolossos_WitchRagPinThink
//  en T_Kol_LayerThink), la original queda RENDER_NONE + FL_FROZEN
//  (la estatua del suite: su IA apagada sin romper su calendario),
//  los punos la sacuden igual que a los SI, el lanzamiento vuela el
//  DOBLE con impulso por hueso y la witch reaparece DONDE CAYO. Si
//  muere agarrada, el doble queda de cadaver (patron VictRagCorpse)
//  y la restauracion la devuelve visible para su muerte normal.
// =====================================================================

// la entidad es una witch viva?
bool Kolossos_IsWitchEnt(int ent)
{
    if (ent <= MaxClients || !IsValidEntity(ent)) return false;
    char cls[16];
    GetEntityClassname(ent, cls, sizeof(cls));
    return StrEqual(cls, "witch", false);
}

int Kolossos_WitchRagOf(int client)
{
    if (client < 1 || client > MaxClients) return 0;
    if (g_iKolWitchRag[client] == 0) return 0;
    int rag = EntRefToEntIndex(g_iKolWitchRag[client]);
    if (rag <= MaxClients || !IsValidEntity(rag)) return 0;
    return rag;
}

bool Kolossos_WitchRagActive(int client)
{
    return Kolossos_WitchRagOf(client) != 0;
}

// spawn del doble + witch congelada/invisible (el pin sale diferido como
// los clientes: el beat de fisica que da el pose colgado)
bool Kolossos_WitchRagSpawn(int client, int witch)
{
    if (client < 1 || client > MaxClients) return false;
    if (!Kolossos_IsWitchEnt(witch)) return false;
    if (Kolossos_WitchRagActive(client)) return true;

    char mdl[PLATFORM_MAX_PATH];
    GetEntPropString(witch, Prop_Data, "m_ModelName", mdl, sizeof(mdl));
    if (mdl[0] == '\0') return false;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return false;

    DispatchKeyValue(rag, "model", mdl);
    DispatchSpawn(rag);
    AcceptEntityInput(rag, "EnableMotion");
    AcceptEntityInput(rag, "Wake");

    float pos[3], ang[3];
    GetEntPropVector(witch, Prop_Data, "m_vecOrigin", pos);
    GetEntPropVector(witch, Prop_Data, "m_angRotation", ang);
    pos[2] += KOL_RAG_RESTORE_Z;
    TeleportEntity(rag, pos, ang, NULL_VECTOR);
    Sonic_RagMakePassable(rag);   // DEBRIS: el doble no traba contra nada

    // la witch FUERA de la vista y CONGELADA (FL_FROZEN = la estatua del
    // suite, receta Sonic_WitchStun: apaga su IA NextBot de raiz)
    g_iKolWitchRagRender[client] = view_as<int>(GetEntityRenderMode(witch));
    SetEntityRenderMode(witch, RENDER_NONE);
    Sonic_RagGhostCollision(witch, g_iKolWitchRagCol[client]);
    SetEntityFlags(witch, GetEntityFlags(witch) | FL_FROZEN);

    g_iKolWitchRag[client]        = EntIndexToEntRef(rag);
    g_iKolWitchRagVictim[client]  = EntIndexToEntRef(witch);
    g_bKolWitchRagJolt[client]    = false;
    g_fKolWitchRagRepinAt[client] = 0.0;
    g_fKolWitchRagPinDelay[client] = GetEngineTime() + KOL_RAG_PIN_DELAY;
    g_bKolWitchRagFlying[client]  = false;
    g_fKolWitchRagFlyEnd[client]  = 0.0;
    return true;
}

// el pin por frame de la witch agarrada (corre en T_Kol_LayerThink junto
// a Kolossos_VictRagPinThink — MISMA receta: hueso raiz a la MANO
// animada del marker, velocidad CERO, tilt del convar, plan B engine)
void Kolossos_WitchRagPinThink(float now)
{
    for (int c = 1; c <= MaxClients; c++)
    {
        if (g_iKolWitchRag[c] == 0 || g_bKolWitchRagFlying[c]) continue;

        int rag = Kolossos_WitchRagOf(c);
        if (rag == 0) continue;   // el follow barre huerfanos

        if (!IsClientInGame(c) || !IsPlayerAlive(c)) continue;

        // el beat de fisica del spawn y la pausa de la sacudida
        if (g_fKolWitchRagPinDelay[c] > 0.0 && now < g_fKolWitchRagPinDelay[c]) continue;
        if (g_bKolWitchRagJolt[c])
        {
            if (now < g_fKolWitchRagRepinAt[c]) continue;
            g_bKolWitchRagJolt[c] = false;
        }

        // la MANO ANIMADA (el marker del attachment grabhand del avatar)
        float pinPos[3];
        int mk = Kolossos_HandMarkGet(c);
        if (mk > 0 && HasEntProp(mk, Prop_Data, "m_vecAbsOrigin"))
        {
            GetEntPropVector(mk, Prop_Data, "m_vecAbsOrigin", pinPos);
            pinPos[2] -= KOL_RAG_HANG_Z;
        }
        else
        {
            float pos[3], dir[3];
            GetClientAbsOrigin(c, pos);
            Kolossos_GetMoveDir(c, dir);
            pinPos[0] = pos[0] + dir[0] * KOL_GRAB_HOLD_DIST;
            pinPos[1] = pos[1] + dir[1] * KOL_GRAB_HOLD_DIST;
            pinPos[2] = pos[2] + KOL_GRAB_HOLD_Z;
        }

        float pinAng[3], tmpPos[3];
        if (!Sonic_RagPhysGet(rag, tmpPos, pinAng))
            GetEntPropVector(rag, Prop_Data, "m_angAbsRotation", pinAng);
        if (g_cvKolGrabTilt != null && g_cvKolGrabTilt.FloatValue != 0.0)
            pinAng[0] += g_cvKolGrabTilt.FloatValue;

        if (!Sonic_RagPhysPin(rag, pinPos, pinAng))
        {
            float zero[3];
            TeleportEntity(rag, pinPos, NULL_VECTOR, zero);
        }
    }
}

// la sacudida del puno (identica a la de los SI: impulso + pausa del pin)
void Kolossos_WitchRagJolt(int client)
{
    int rag = Kolossos_WitchRagOf(client);
    if (rag == 0) return;
    AcceptEntityInput(rag, "EnableMotion");
    AcceptEntityInput(rag, "Wake");
    float vel[3];
    vel[0] = GetRandomFloat(-80.0, 80.0);
    vel[1] = GetRandomFloat(-80.0, 80.0);
    vel[2] = KOL_RAG_JOLT_UP;
    TeleportEntity(rag, NULL_VECTOR, NULL_VECTOR, vel);
    g_bKolWitchRagJolt[client] = true;
    g_fKolWitchRagRepinAt[client] = GetEngineTime() + KOL_RAG_JOLT_REPIN;
}

// la witch murio agarrada: el doble queda de CADaver donde cuelga (se
// limpia a los 3s) y la witch vuelve a verse para su muerte normal
void Kolossos_WitchRagCorpse(int client)
{
    int rag = Kolossos_WitchRagOf(client);
    if (rag != 0)
    {
        AcceptEntityInput(rag, "EnableMotion");
        AcceptEntityInput(rag, "Wake");
        float drop[3];
        drop[0] = GetRandomFloat(-60.0, 60.0);
        drop[1] = GetRandomFloat(-60.0, 60.0);
        drop[2] = -80.0;
        TeleportEntity(rag, NULL_VECTOR, NULL_VECTOR, drop);
        CreateTimer(3.0, Kolossos_T_VictRagCorpseClean, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
    }

    // registro libre y la witch visible de nuevo (si el motor todavia no
    // la retiro): su anim de muerte se ve, el doble es el cadaver que cae
    int witch = EntRefToEntIndex(g_iKolWitchRagVictim[client]);
    bool wasWitch = (witch > MaxClients && IsValidEntity(witch) && Kolossos_IsWitchEnt(witch));

    g_iKolWitchRag[client]       = 0;
    g_iKolWitchRagVictim[client] = 0;
    g_bKolWitchRagFlying[client] = false;
    g_fKolWitchRagFlyEnd[client] = 0.0;
    g_bKolWitchRagJolt[client]   = false;

    if (wasWitch)
    {
        SetEntityRenderMode(witch, view_as<RenderMode>(g_iKolWitchRagRender[client]));
        Sonic_RagRestoreCollision(witch, g_iKolWitchRagCol[client]);
        SetEntityFlags(witch, GetEntityFlags(witch) & ~FL_FROZEN);
    }
    g_iKolWitchRagRender[client] = -1;
    g_iKolWitchRagCol[client]    = -1;
}

// el LANZAMIENTO de la witch: el doble vuela con impulso por hueso, la
// original queda oculta siguiendolo (WitchRagFollow) y revive donde caiga
void Kolossos_WitchRagLaunch(int client, const float dir[3], float speed)
{
    int rag = Kolossos_WitchRagOf(client);
    if (rag == 0) return;

    AcceptEntityInput(rag, "EnableMotion");
    AcceptEntityInput(rag, "Wake");

    if (!Sonic_RagPhysLaunch(rag, dir, speed, speed * KOL_RAG_THROW_LIFT, KOL_RAG_THROW_TUMBLE))
        Sonic_RagFlingEngine(rag, dir, speed, speed * KOL_RAG_THROW_LIFT);

    g_bKolWitchRagFlying[client] = true;
    g_fKolWitchRagFlyEnd[client] = GetEngineTime() + KOL_WITCH_RAG_FLY_MAX;
}

// el follow del vuelo (10 Hz, colgado de Kolossos_VictRagThink): la witch
// original oculta persigue al doble y al terminar revive donde quedo
void Kolossos_WitchRagFollow()
{
    float now = GetEngineTime();
    for (int c = 1; c <= MaxClients; c++)
    {
        if (g_iKolWitchRag[c] == 0) continue;

        int rag = Kolossos_WitchRagOf(c);
        if (rag == 0)
        {
            // doble muerto en pleno vuelo: restaurar ya
            Kolossos_WitchRagEnd(c, false);
            continue;
        }
        if (!g_bKolWitchRagFlying[c]) continue;

        int witch = EntRefToEntIndex(g_iKolWitchRagVictim[c]);
        bool witchGone = (witch <= 0 || !IsValidEntity(witch) || !Kolossos_IsWitchEnt(witch));

        // el motor retiro a la witch (muerta/cleanup): el doble cae solo
        if (witchGone)
        {
            g_bKolGrabIsWitch[c] = false;
            AcceptEntityInput(rag, "EnableMotion");
            CreateTimer(3.0, Kolossos_T_VictRagCorpseClean, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
            g_iKolWitchRag[c] = 0;
            g_iKolWitchRagVictim[c] = 0;
            g_bKolWitchRagFlying[c] = false;
            continue;
        }

        // follow congruente: la original invisible viaja con el doble
        float ragPos[3];
        GetEntPropVector(rag, Prop_Data, "m_vecOrigin", ragPos);
        TeleportEntity(witch, ragPos, NULL_VECTOR, NULL_VECTOR);

        if (now >= g_fKolWitchRagFlyEnd[c])
            Kolossos_WitchRagEnd(c, true);
    }
}

// fin del ciclo de la witch: doble muerto + original restaurada (render,
// colision y IA) donde quedo el doble — o donde este si el doble ya no existe
void Kolossos_WitchRagEnd(int client, bool teleportToRag)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iKolWitchRag[client] == 0) return;

    int rag = Kolossos_WitchRagOf(client);
    int witch = EntRefToEntIndex(g_iKolWitchRagVictim[client]);

    if (witch > MaxClients && IsValidEntity(witch) && Kolossos_IsWitchEnt(witch))
    {
        if (teleportToRag && rag != 0)
        {
            float ragPos[3];
            GetEntPropVector(rag, Prop_Data, "m_vecOrigin", ragPos);
            ragPos[2] += KOL_RAG_RESTORE_Z;
            TeleportEntity(witch, ragPos, NULL_VECTOR, NULL_VECTOR);
        }
        SetEntityRenderMode(witch, view_as<RenderMode>(g_iKolWitchRagRender[client]));
        Sonic_RagRestoreCollision(witch, g_iKolWitchRagCol[client]);
        SetEntityFlags(witch, GetEntityFlags(witch) & ~FL_FROZEN);
    }

    if (rag != 0) AcceptEntityInput(rag, "Kill");

    g_iKolWitchRag[client]        = 0;
    g_iKolWitchRagVictim[client]  = 0;
    g_iKolWitchRagRender[client]  = -1;
    g_iKolWitchRagCol[client]     = -1;
    g_bKolWitchRagJolt[client]    = false;
    g_fKolWitchRagRepinAt[client] = 0.0;
    g_fKolWitchRagPinDelay[client] = 0.0;
    g_bKolWitchRagFlying[client]  = false;
    g_fKolWitchRagFlyEnd[client]  = 0.0;
}

// =====================================================================
//  [X] HABILIDAD 2 — GRAB (lunge, agarre en vilo y combo de puos)
//  GMod l.2398-2479 (lunge 0.6s) + l.2041-2072 (esfera 90 -> agarrado,
//  PunchesLeft 3, max 10s) + l.2566-2630 (puos slamDamage 15).
// =====================================================================

void Kolossos_Ability2(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    // X de nuevo durante el agarre = soltar (CanCancelGrab, default off)
    if (g_iKolGrabVictim[client] != 0)
    {
        if (g_cvKolGrabCancel.BoolValue)
        {
            g_iKolGrabPunches[client] = 0;
            Kolossos_GrabRelease(client, true, false);
        }
        else PrintCenterText(client, "Puos: %d (Z)", g_iKolGrabPunches[client]);
        return;
    }

    if (g_iKolChargeState[client] != KOL_CHG_IDLE
        || g_fKolBlockUntil[client] > now
        || g_fKolIndUntil[client] > now
        || g_fKolLungeUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolGrabCdUntil[client])
    {
        PrintCenterText(client, "Grab: %.1fs", g_fKolGrabCdUntil[client] - now);
        return;
    }

    // ---- lunge: ventana de captura + impulso corto hacia delante ----
    g_fKolLungeUntil[client]  = now + g_cvKolGrabWindow.FloatValue;
    g_bKolGrabLunged[client]  = false;

    Kolossos_Emit(client, g_bKolSndGrabLunge, "om/kolossos/kol grab lunge.wav",
                  "ambient/wind/wind_hit1.wav");
    Kolossos_Emit(client, g_bKolSndGrabUse, "om/kolossos/Kol uses grab.wav", "");

    PrintCenterText(client, "Agarre!");
}

// el tick del lunge (10 Hz): impulso + esfera de captura
void Kolossos_GrabLungeThink(int client, float now)
{
    // impulso del lunge: UNA vez, al entrar (GMod velocidad grab 1750
    // durante la ventana — en L4D2: impulso unico + ventana de captura)
    if (!g_bKolGrabLunged[client])
    {
        g_bKolGrabLunged[client] = true;
        float dir[3], vel[3];
        Kolossos_GetMoveDir(client, dir);
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[0] += dir[0] * 400.0;
        vel[1] += dir[1] * 400.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    }

    // esfera frontal de captura (GMod FindInSphere 90u en el pecho)
    float pos[3], dir[3];
    GetClientAbsOrigin(client, pos);
    Kolossos_GetMoveDir(client, dir);
    pos[0] += dir[0] * 40.0;
    pos[1] += dir[1] * 40.0;
    pos[2] += 40.0;

    float radius = g_cvKolChgRadius.FloatValue;

    // v1.4 — ESPECIALES PRIMERO (reporte del owner: "No agarra a
    // especiales (al tank no lo agarra. tampoco)"). En la v1.0-1.3 los
    // commons se chequeaban primero con return: cualquier comun en la
    // esfera se robaba el agarre y el TANK estaba explicitamente vetado
    // ("demasiado grande para el puño") — el unico especial que SE ACERCA
    // era inagarrable. Ahora: [1] SI+TANK (clientes team 3, el mas
    // cercano), [2] commons, [3] witch (via movetype, como los commons)
    int bestSI = 0;
    float bestSIDist = radius;
    for (int t = 1; t <= MaxClients; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        // v1.4: el tank entra por convar (el veto de la v1.0 fuera)
        if (GetEntProp(t, Prop_Send, "m_zombieClass") == 8
            && !g_cvKolGrabTank.BoolValue) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        float d = GetVectorDistance(tpos, pos);
        if (d > bestSIDist) continue;
        bestSI = t;
        bestSIDist = d;
    }
    if (bestSI != 0)
    {
        Kolossos_GrabBegin(client, bestSI);
        return;
    }

    // commons (GMod: cualquier player/NPC/NextBot) — el MAS CERCANO
    int bestCm = 0;
    float bestCmDist = radius;
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        float d = GetVectorDistance(epos, pos);
        if (d > bestCmDist) continue;
        bestCm = ent;
        bestCmDist = d;
    }
    if (bestCm != 0)
    {
        Kolossos_GrabBegin(client, bestCm);
        return;
    }

    // v1.4: la WITCH (convar) — entidad como los commons: congelada por
    // movetype, en vilo por la FSM, y los puños le pegan igual
    if (g_cvKolGrabWitch.BoolValue)
    {
        int w = -1;
        int bestW = 0;
        float bestWDist = radius;
        while ((w = FindEntityByClassname(w, "witch")) != -1)
        {
            if (!IsValidEntity(w)) continue;
            if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
            float wpos[3];
            GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
            float d = GetVectorDistance(wpos, pos);
            if (d > bestWDist) continue;
            bestW = w;
            bestWDist = d;
        }
        if (bestW != 0)
        {
            Kolossos_GrabBegin(client, bestW);
            return;
        }
    }

    // ventana agotada sin nadie: CD completo (GMod l.2179)
    if (now >= g_fKolLungeUntil[client])
    {
        g_fKolLungeUntil[client] = 0.0;
        g_fKolGrabCdUntil[client] = now + g_cvKolGrabCd.FloatValue;
    }
}

// la victima queda en vilo delante del coloso
// v1.8: LA VICTIMA PEGADA AL BRAZO — el fix literal del owner: "el
// cuerpo del enemigo deberia estar pegado al brazo EN SI, no en donde
// la camara este viendo, y orientado mas que todo a donde mire
// KOLOSSOS, no el survivor invisible". El truco del GMod original (su
// Lua: ragdoll pegado a la mano derecha) a la engine de L4D2:
//   [1] SetParent al avatar R (la copia que ve el mundo — el survivor
//       invisible queda fuera del circuito para siempre);
//   [2] SetParentAttachment "grabhand" — snap a la MANO animada: pos
//       Y angulos del hueso RightHand del .mdl v1.5.2 ($attachment);
//   [3] tilt afinable (kolossos_grab_tilt) — el original la llevaba
//       "mirando hacia arriba" y el owner pidio bajarla: pitch
//       relativo al frame de la mano, default -35.
// Retorna true si quedo pegada (a este avatar o antes). Con el .mdl
// viejo (sin $attachment) el snap falla pero el SetParent vive: queda
// parent-follow (sigue a KOLOSSOS, no a la camara); si tampoco hay
// parent, GrabHoldThink cae al offset v1.7 como siempre.
bool Kolossos_GrabVictimGlue(int client, int victim)
{
    if (victim <= 0 || !IsValidEntity(victim)) return false;
    int av = EntRefToEntIndex(g_iKolAvatar[client]);
    if (av <= 0 || !IsValidEntity(av)) return false;

    // ya esta pegada a ESTE avatar: el parent hace todo el trabajo
    if (GetEntPropEnt(victim, Prop_Data, "m_hMoveParent") == av) return true;

    // pegarla al avatar (activator = av — la receta del montaje v1.0)
    SetVariantString("!activator");
    AcceptEntityInput(victim, "SetParent", av, av);

    // y de la MANO: el snap al attachment la clava al hueso RightHand
    SetVariantString("grabhand");
    AcceptEntityInput(victim, "SetParentAttachment", av, av);

    // el tilt del owner: pitch relativo al frame de la mano (una sola
    // vez por pegado — el convar se lee al enganchar, re-grabar para
    // cambiarlo en vivo)
    if (g_cvKolGrabTilt != null && g_cvKolGrabTilt.FloatValue != 0.0
        && HasEntProp(victim, Prop_Send, "m_angRotation"))
    {
        float ang[3];
        GetEntPropVector(victim, Prop_Send, "m_angRotation", ang);
        ang[0] += g_cvKolGrabTilt.FloatValue;
        TeleportEntity(victim, NULL_VECTOR, ang, NULL_VECTOR);
    }
    return true;
}

// v1.8: despegar (unparent) — GrabRelease lo llama ANTES de soltarla:
// con el parent puesto el avatar la clavaria en el aire y el fling del
// +0.3s no volaria nunca
void Kolossos_GrabVictimUnGlue(int victim)
{
    if (victim <= 0 || !IsValidEntity(victim)) return;
    if (GetEntPropEnt(victim, Prop_Data, "m_hMoveParent") == -1) return;
    SetVariantString("");
    AcceptEntityInput(victim, "SetParent", victim, victim);
}

void Kolossos_GrabBegin(int client, int victim)
{
    g_fKolLungeUntil[client] = 0.0;
    g_iKolGrabVictim[client] = EntIndexToEntRef(victim);
    g_iKolGrabPunches[client] = g_cvKolGrabPunches.IntValue;
    g_fKolGrabHoldEnd[client] = GetEngineTime() + g_cvKolGrabHold.FloatValue;
    g_bKolGrabIsWitch[client] = Kolossos_IsWitchEnt(victim);   // v2.1
    g_fKolGrabNextPunchAt[client] = 0.0;                        // v2.1: combo fresco

    // congelar a la victima: commons por movetype, SI por OM_Stun
    if (victim > 0 && victim <= MaxClients)
    {
        float stunDur = g_cvKolGrabHold.FloatValue + 1.0;
        OM_Stun(victim, stunDur, client, 0.0, DMG_OM_CLUB, false);
    }
    else
    {
        g_iKolGrabMoveType[client] = GetEntProp(victim, Prop_Data, "movetype");
        SetEntProp(victim, Prop_Data, "movetype", MOVETYPE_NONE);
    }

    // v1.9: LA VICTIMA VIAJA COMO RAGDOLL — doble prop_ragdoll que se
    // desploma un beat y se clava a la MANO (attachment grabhand);
    // el original queda RENDER_NONE y pegado al doble por teleport
    // congruente (el fix del video: la v1.8 parentaba al PLAYER vivo y
    // re-assertaba cada tick = el SNAP repetido "del agarre mas de una
    // vez"). v2.1: LA WITCH TAMBIEN — parentar la witch viva la volvia
    // INVISIBLE en el motor ("cuando la lleva literalmente no aparece
    // despues de soltarla"): ahora viaja con doble pineado igual que
    // los SI. Commons o convar off: pegado v1.8
    bool ragdolled = false;
    if (g_cvKolGrabRag != null && g_cvKolGrabRag.BoolValue)
    {
        if (victim > 0 && victim <= MaxClients)
            ragdolled = Kolossos_VictRagSpawn(client, victim, KOL_RAGMODE_GRABPIN);
        else if (g_bKolGrabIsWitch[client])
            ragdolled = Kolossos_WitchRagSpawn(client, victim);
    }

    // v1.8: LA VICTIMA PEGADA AL BRAZO DESDE EL INSTANTE DEL AGARRE — el
    // snap al attachment ES el "agarre inicial" visible que faltaba (el
    // material del grab del .mdl esta vacio: el pegado a la mano era
    // TODO el look del original, tal cual el Lua de GMod)
    if (!ragdolled)
        Kolossos_GrabVictimGlue(client, victim);

    Kolossos_Emit(client, g_bKolSndImpale, "om/kolossos/Kol impales.wav",
                  "physics/flesh/flesh_break3.wav");

    // v1.6: la POSE de sujetar a la CAPA 1 (el ACT_HOVER del GMod) —
    // brazos sujetando mientras el main SIGUE SIENDO locomocion pura
    // (piernas vivas). Sin capas disponibles no hace nada y la FSM usa
    // la fusion v1.5 o la monocapa v1.3 como antes
    Kolossos_LayerHold(client, true);

    // v1.3: el REACH — la serie del grab arranca con el enganche (el
    // "Grab" 31f de los SMD; en GMod el reach es el gesture del lunge
    // MELEE_ATTACK1, pero aca el lunge va a 3x con las piernas vivas:
    // el lugar natural del reach es JUSTO al enganchar)
    // v1.5: fusionado — el reach CAMINANDO / CORRIENDO / PLANTADO segun
    // la locomocion del enganche; modelo viejo = one-shot base v1.3
    Kolossos_GrabShot(client, KOL_ST_GRABREACH,
                      Kolossos_ShotDur(KOL_ST_GRABREACH, KOL_DUR_GRABREACH),
                      KOL_SHOT_GRAB);

    PrintCenterText(client, "Agarrado! Puos restantes: %d (Z)", g_iKolGrabPunches[client]);
}

// el tick del agarre: victima en vilo delante + validacion + timeout
void Kolossos_GrabHoldThink(int client, float now)
{
    int victim = EntRefToEntIndex(g_iKolGrabVictim[client]);
    bool dead = false;

    if (victim <= 0 || !IsValidEntity(victim))
        dead = true;
    else if (victim <= MaxClients)
    {
        if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) dead = true;
    }
    else if (GetEntProp(victim, Prop_Data, "m_iHealth") <= 0) dead = true;

    if (dead)
    {
        // la victima murio sola: CD corto (GMod l.2026: grab_cd +2)
        Kolossos_GrabRelease(client, false, true);
        return;
    }

    // v2.0: en modo ragdoll el original lo sigue VictRagThink (10 Hz,
    // el mismo follow para grab/carry/vuelo). v2.1: la WITCH con doble
    // tampoco se toca aqui (el pin por frame es su verdad de mundo —
    // JAMAS parentar la witch). Sin doble (commons o convar off): la
    // v1.8 — pegada al brazo con parent (re-assert solo si se solto) o
    // el offset v1.7 de ultima instancia
    bool witchPinned = (g_bKolGrabIsWitch[client] && Kolossos_WitchRagActive(client));
    if (!witchPinned && !Kolossos_VictRagActive(victim) && !Kolossos_GrabVictimGlue(client, victim))
    {
        float pos[3], dir[3];
        GetClientAbsOrigin(client, pos);
        Kolossos_GetMoveDir(client, dir);
        pos[0] += dir[0] * KOL_GRAB_HOLD_DIST;
        pos[1] += dir[1] * KOL_GRAB_HOLD_DIST;
        pos[2] += KOL_GRAB_HOLD_Z;
        TeleportEntity(victim, pos, NULL_VECTOR, NULL_VECTOR);
    }

    // v1.3: lanzamiento encadenado tras el 3er puo (GMod l.2617-2623:
    // duration+1.75 — el throw sale DESPUES de la anim del puo, no
    // instantaneo)
    if (g_fKolGrabThrowAt[client] > 0.0 && now >= g_fKolGrabThrowAt[client])
    {
        g_fKolGrabThrowAt[client] = 0.0;
        Kolossos_GrabRelease(client, true, false);
        return;
    }

    // timeout del agarre (max 10s)
    if (now >= g_fKolGrabHoldEnd[client])
        Kolossos_GrabRelease(client, true, false);
}

// Z durante el agarre: puo (GMod l.2566-2630)
// v1.1: si el puo MATA a la victima -> la EJECUCION del GMod (l.1137-
// 1142): PillAnim("Kill") por la duracion de la secuencia (1.65s en el
// registro) + la risa "Kolossos laughing" un segundo despues (l.1220-1228)
void Kolossos_GrabPunch(int client)
{
    int victim = EntRefToEntIndex(g_iKolGrabVictim[client]);
    if (victim <= 0 || !IsValidEntity(victim)) return;

    float now = GetEngineTime();

    // v2.1: LA PUERTA DEL COMBO — "aunque los golpes tienen un time el
    // juego sigue tomando la pulsacion como golpes fuera de los 3
    // permitidos": el M1/Z durante el agarre no pasaba por NINGUN gate,
    // cada click era un puo (3 clicks en 3 frames = combo entero) y los
    // extra seguan re-triggereando la anim y re-agendando el
    // lanzamiento. AHORA: sin cargas no hay puo (el lanzamiento ya esta
    // agendado) y entre puo y puo tiene que pasar KOL_PUNCH_GATE
    if (g_iKolGrabPunches[client] <= 0) return;
    if (now < g_fKolGrabNextPunchAt[client]) return;
    g_fKolGrabNextPunchAt[client] = now + KOL_PUNCH_GATE;

    Kolossos_Emit(client, g_bKolSndPunch, "om/kolossos/kolossos punching.wav",
                  "physics/flesh/flesh_impact_hard3.wav");

    // v2.1: EL DANO DEL PUO — base 550 (pedido del owner, antes 15)
    // + 1.75% de la VIDA ACTUAL del agarrado (kolossos_grab_punchhpdmg:
    // al tank le duela de verdad, el % escala con lo que le quede)
    float punchDmg = (g_cvKolGrabPunchDmg != null) ? g_cvKolGrabPunchDmg.FloatValue : 550.0;
    float hpPct = (g_cvKolGrabHpDmg != null) ? g_cvKolGrabHpDmg.FloatValue : 0.0;
    if (hpPct > 0.0)
    {
        int hp = 0;
        if (victim <= MaxClients)
        {
            if (IsClientInGame(victim) && IsPlayerAlive(victim))
                hp = GetEntProp(victim, Prop_Data, "m_iHealth");
        }
        else if (HasEntProp(victim, Prop_Data, "m_iHealth"))
            hp = GetEntProp(victim, Prop_Data, "m_iHealth");
        if (hp > 0) punchDmg += float(hp) * hpPct / 100.0;
    }
    OM_AbilityDamage(victim, client, punchDmg);

    // ?murio con ese puo? (SI: cliente muerto / comun sin vida)
    bool killed = false;
    if (victim <= MaxClients)
        killed = (!IsClientInGame(victim) || !IsPlayerAlive(victim));
    else
        killed = (!IsValidEntity(victim) || GetEntProp(victim, Prop_Data, "m_iHealth") <= 0);

    if (killed)
    {
        // v1.3: la ejecucion ahora es prioridad MAXIMA (nadie la corta)
        Kolossos_AnimShot(client, KOL_ST_KILL, 1.65, KOL_SHOT_MAX);
        if (g_bKolSndLaughKill)
            CreateTimer(1.0, Kolossos_T_KillLaugh, GetClientUserId(client));

        // v1.3: ejecucion pura — sin lanzamiento (el Kill ES el payoff)
        g_iKolGrabPunches[client] = 0;
        Kolossos_GrabRelease(client, false, true);
        return;
    }

    // v1.3: el puo tiene su animacion (el gesture MELEE_ATTACK2 del GMod
    // = GrabPunch 51f de los SMD) — prioridad GRAB: la locomocion no la
    // corta, solo el lanzamiento/ejecucion
    // v1.5: fusionado — el puo CAMINANDO / CORRIENDO / PLANTADO segun la
    // locomocion (piernas y brazo en la MISMA seq)
    Kolossos_GrabShot(client, KOL_ST_GRABPUNCH,
                      Kolossos_ShotDur(KOL_ST_GRABPUNCH, KOL_DUR_GRABPUNCH),
                      KOL_SHOT_GRAB);

    // v1.9: el cuerpo colgado SACUDE con el puo (unpin + impulso +
    // re-pin) — el golpe se VE en la victima, una vez por puo
    // v2.1: la witch colgada sacude igual (su doble cuelga de la mano)
    if (Kolossos_VictRagActive(victim))
        Kolossos_VictRagJolt(victim);
    else if (g_bKolGrabIsWitch[client] && Kolossos_WitchRagActive(client))
        Kolossos_WitchRagJolt(client);

    g_iKolGrabPunches[client]--;
    if (g_iKolGrabPunches[client] <= 0)
    {
        // v1.3: combo completo ENCADENADO (GMod l.2617-2623: al 3er puo
        // duration+1.75): el lanzamiento sale cuando la anim del puo
        // TERMINA — cada anim dura lo que debe durar
        float punchDur = Kolossos_ShotDur(KOL_ST_GRABPUNCH, KOL_DUR_GRABPUNCH);
        g_fKolGrabThrowAt[client] = now + punchDur + 0.1;
        g_fKolGrabHoldEnd[client] = now + punchDur + 1.0;
        PrintCenterText(client, "TERCER PUO — lanzamiento!");
    }
    else
    {
        PrintCenterText(client, "Puo! Quedan %d", g_iKolGrabPunches[client]);
    }
}

// v1.1: la risa de la ejecucion (GMod l.1220-1228: laughing 1s tras el Kill)
public Action Kolossos_T_KillLaugh(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (!Kolossos_PlayerIs(client)) return Plugin_Stop;
    if (g_sKolLaughPath[0] != '\0')
        EmitSoundToAll(g_sKolLaughPath, client, _, KOL_SND_LEVEL);
    return Plugin_Stop;
}

// v1.3: LA VICTIMA VUELA A +0.3s DEL ARRANQUE DE LA ANIM (GMod
// l.2154: timer.Simple(0.3) -> phys:SetVelocityInstantaneous(fwd*700))
// — el brazo empuja al frente cuando la anim llega al envion
public Action Kolossos_T_GrabFling(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client < 1 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (!Kolossos_PlayerIs(client)) return Plugin_Stop;

    int victim = EntRefToEntIndex(g_iKolGrabFlingRef[client]);
    g_iKolGrabFlingRef[client] = 0;
    if (victim <= 0 || !IsValidEntity(victim)) return Plugin_Stop;

    float dir[3], push[3];
    Kolossos_GetMoveDir(client, dir);
    push[0] = dir[0] * KOL_GRAB_FLING_FWD;
    push[1] = dir[1] * KOL_GRAB_FLING_FWD;
    push[2] = KOL_GRAB_FLING_UP;
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, push);
    return Plugin_Stop;
}

// soltar: fling opcional + restaurar a la victima + CD
void Kolossos_GrabRelease(int client, bool fling, bool victimDied)
{
    int victim = EntRefToEntIndex(g_iKolGrabVictim[client]);
    g_iKolGrabVictim[client] = 0;
    g_fKolGrabThrowAt[client] = 0.0;    // v1.3: sin lanzamiento pendiente
    g_iKolGrabFlingRef[client] = 0;     // v1.3: anula un fling demorado previo

    // v1.8: despegarla del brazo ANTES de restaurarla — con el parent
    // puesto el avatar la clavaria y el fling del +0.3s no volaria
    Kolossos_GrabVictimUnGlue(victim);

    // v1.6: capas fuera — la pose de sujetar se apaga y, si NO hay
    // lanzamiento, tambien el one-shot en vuelo (con fling, el GrabShot
    // de abajo re-arma la capa 2 con el lanzamiento de duracion completa)
    Kolossos_LayerHold(client, false);
    if (!fling)
        Kolossos_LayerClearShot(client);

    if (victim > 0 && IsValidEntity(victim))
    {
        bool ragMode = Kolossos_VictRagActive(victim);

        // v1.9: la victima murio agarrada — el doble queda de cadaver
        if (ragMode && victimDied && victim <= MaxClients)
        {
            Kolossos_VictRagCorpse(victim);
            ragMode = false;
        }

        // v2.1: LA WITCH — murio agarrada: el doble queda de cadaver y
        // ella vuelve a verse para su muerte; la sueltan SIN lanzamiento
        // (drop/timeout): reaparece DONDE CUELGA el doble; con
        // lanzamiento: el doble vuela y el follow la restaura donde caiga
        bool witchRag = (victim > MaxClients && Kolossos_IsWitchEnt(victim)
                         && Kolossos_WitchRagActive(client));
        if (witchRag && victimDied)
        {
            Kolossos_WitchRagCorpse(client);
            witchRag = false;
        }
        else if (witchRag && !fling)
        {
            Kolossos_WitchRagEnd(client, true);
            witchRag = false;
        }

        // restaurar movimiento
        if (victim <= MaxClients)
        {
            // v1.9: en modo ragdoll el LANZAMIENTO la deja TIRADA (stun):
            // el stun lo administra VictRagThink hasta que caiga el doble
            if (!ragMode || !fling)
            {
                if (IsClientInGame(victim)) OM_Stun_Clear(victim);
            }
            if (!ragMode)
                Kolossos_VictRagEnd(victim, true);
        }
        else if (g_iKolGrabMoveType[client] > 0)
        {
            SetEntProp(victim, Prop_Data, "movetype", g_iKolGrabMoveType[client]);
        }

        // v1.3: EL LANZAMIENTO — la anim PRIORITARIA de duracion COMPLETA
        // (en GMod era el gesture ACT_DISARM cortado a 0.9s con fade; aca
        // manda sobre todo: KOL_SHOT_MAX nadie la corta y la duracion la
        // midio el calibrador contra el .mdl real) + la victima vuela a
        // +0.3s del arranque (GMod l.2154)
        // v1.5: fusionado — el lanzamiento CAMINANDO / CORRIENDO /
        // PLANTADO segun la locomocion, ciclo COMPLETO, nadie lo corta
        // v1.9: en modo ragdoll el que VUELA es el DOBLE (impulso por
        // hueso, GMod l.2153 fwd*700) y el original lo sigue oculto —
        // "al tirar al enemigo estos quedan en ragdoll"
        if (fling && IsClientInGame(client) && IsPlayerAlive(client))
        {
            Kolossos_GrabShot(client, KOL_ST_GRABTHROW,
                              Kolossos_ShotDur(KOL_ST_GRABTHROW, KOL_DUR_GRABTHROW),
                              KOL_SHOT_MAX);

            if (ragMode)
            {
                float dir[3];
                Kolossos_GetMoveDir(client, dir);
                Kolossos_VictRagLaunch(client, victim, dir, KOL_RAG_THROW_FWD);
            }
            else if (witchRag)
            {
                // v2.1: la witch lanzada — vuela el DOBLE con impulso por
                // hueso y la original (oculta/frozen) lo sigue hasta caer
                float dir[3];
                Kolossos_GetMoveDir(client, dir);
                Kolossos_WitchRagLaunch(client, dir, KOL_RAG_THROW_FWD);
            }
            else
            {
                g_iKolGrabFlingRef[client] = EntIndexToEntRef(victim);
                CreateTimer(KOL_GRAB_FLING_DELAY, Kolossos_T_GrabFling, GetClientUserId(client));
            }

            Kolossos_Emit(client, g_bKolSndPullOut, "om/kolossos/kol sting and pull out.wav",
                          "physics/flesh/flesh_impact_bullet1.wav");
        }
    }

    g_iKolGrabMoveType[client] = -1;
    g_bKolGrabIsWitch[client] = false;   // v2.1 (el ref de la witch lo administra su registro)
    g_fKolGrabNextPunchAt[client] = 0.0; // v2.1

    float now = GetEngineTime();
    if (victimDied)
        g_fKolGrabCdUntil[client] = now + 2.0;                       // GMod: murio sola
    else
        g_fKolGrabCdUntil[client] = now + g_cvKolGrabCd.FloatValue;  // CD completo
}

// =====================================================================
//  [C] HABILIDAD 3 — INDICATOR (el peek: glow rojo sobre los infectados)
//  GMod l.458-549: durante IndicatorDuration todos los players/NPCs en
//  rango llevan el border indicator + pings; susurro al activar.
//  L4D2: sprites glow01 rojos sobre la cabeza, refresco a 10 Hz.
// =====================================================================

void Kolossos_Ability3(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    if (g_iKolChargeState[client] != KOL_CHG_IDLE
        || g_iKolGrabVictim[client] != 0
        || g_fKolLungeUntil[client] > now
        || g_fKolBlockUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolIndCdUntil[client])
    {
        PrintCenterText(client, "Indicator: %.1fs", g_fKolIndCdUntil[client] - now);
        return;
    }

    g_fKolIndUntil[client]    = now + g_cvKolIndDur.FloatValue;
    g_fKolIndCdUntil[client]  = now + g_cvKolIndCd.FloatValue;
    g_fKolIndNextPing[client] = now;

    // susurro del coloso (solo el jugador lo oye, como el GMod client-side)
    if (g_bKolSndWhisper)
        EmitSoundToClient(client, "om/kolossos/kol whispers.wav", client, _, KOL_SND_LEVEL);

    PrintCenterText(client, "INDICATOR!");
}

// el tick del indicator: mantener la nube de sprites sobre los vivos
void Kolossos_IndicatorThink(int client, float now)
{
    float pos[3];
    GetClientAbsOrigin(client, pos);
    float radius = g_cvKolIndRadius.FloatValue;

    // marcar quienes estan en rango (bitmap de este tick)
    static bool inRange[KOL_MAXENT + 1];
    for (int e = 1; e <= KOL_MAXENT; e++) inRange[e] = false;

    // 1) infectados especiales
    for (int t = 1; t <= MaxClients; t++)
    {
        if (!IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (radius > 0.0 && GetVectorDistance(tpos, pos) > radius) continue;
        inRange[t] = true;
    }

    // 2) commons
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (ent > KOL_MAXENT) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (radius > 0.0 && GetVectorDistance(epos, pos) > radius) continue;
        inRange[ent] = true;
    }

    // 3) witch
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (!IsValidEntity(w)) continue;
        if (w > KOL_MAXENT) continue;
        if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
        float wpos[3];
        GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
        if (radius > 0.0 && GetVectorDistance(wpos, pos) > radius) continue;
        inRange[w] = true;
    }

    // mantener la nube: crear/mover los que estan, matar los que salieron
    for (int e = 1; e <= KOL_MAXENT; e++)
    {
        if (!inRange[e])
        {
            if (g_iKolIndSprite[e] != 0)
            {
                int sp = EntRefToEntIndex(g_iKolIndSprite[e]);
                if (sp > 0 && IsValidEntity(sp)) AcceptEntityInput(sp, "Kill");
                g_iKolIndSprite[e] = 0;
            }
            continue;
        }

        float head[3];
        if (e <= MaxClients)
        {
            if (!IsClientInGame(e) || !IsPlayerAlive(e)) continue;
            GetClientAbsOrigin(e, head);
            head[2] += 72.0;
        }
        else
        {
            GetEntPropVector(e, Prop_Data, "m_vecOrigin", head);
            head[2] += 64.0;
        }

        int sp = EntRefToEntIndex(g_iKolIndSprite[e]);
        if (g_iKolIndSprite[e] != 0 && (sp <= 0 || !IsValidEntity(sp)))
        {
            g_iKolIndSprite[e] = 0;
            sp = -1;
        }

        if (sp <= 0)
            g_iKolIndSprite[e] = Kolossos_SpawnIndSprite(head);
        else
            SetEntPropVector(sp, Prop_Data, "m_vecOrigin", head);
    }

    // heartbeat del ping (cada 1s, solo para el coloso)
    if (now >= g_fKolIndNextPing[client])
    {
        g_fKolIndNextPing[client] = now + KOL_IND_PING_EVERY;
        if (g_bKolSndPing) EmitSoundToClient(client, "om/metal/ping1.wav", client, _, 60);
        else EmitSoundToClient(client, "buttons/button17.wav", client, _, 60);
    }
}

int Kolossos_SpawnIndSprite(const float pos[3])
{
    // glow01: sprite nativo (cero dependencia de assets del mod)
    int sp = CreateEntityByName("env_sprite");
    if (sp <= 0 || !IsValidEntity(sp)) return 0;

    DispatchKeyValue(sp, "model", "sprites/glow01.vmt");
    DispatchKeyValue(sp, "rendercolor", "255 32 32");
    DispatchKeyValue(sp, "rendermode", "5");      // additive
    DispatchKeyValue(sp, "renderamt", "255");
    DispatchKeyValue(sp, "scale", "0.6");
    DispatchKeyValue(sp, "GlowProxySize", "16");
    DispatchSpawn(sp);

    TeleportEntity(sp, pos, NULL_VECTOR, NULL_VECTOR);
    return EntIndexToEntRef(sp);
}

// fin del indicator: barrido completo de la nube
void Kolossos_IndicatorStop()
{
    for (int e = 1; e <= KOL_MAXENT; e++)
    {
        if (g_iKolIndSprite[e] == 0) continue;
        int sp = EntRefToEntIndex(g_iKolIndSprite[e]);
        if (sp > 0 && IsValidEntity(sp)) AcceptEntityInput(sp, "Kill");
        g_iKolIndSprite[e] = 0;
    }
}

void Kolossos_KillAllIndSprites() { Kolossos_IndicatorStop(); }

// =====================================================================
//  [B] HABILIDAD 4 — BLOCK (el parry del coloso + contragolpe de roca)
//  GMod l.2500-2536 (activacion: inmune + sin moverse 3.5s) + l.1253-
//  1271 (dano a 0 mientras bloquea) + l.1274+ (OM_AfterStunBlock: el
//  bloqueo se CONSUME con el golpe, gira al atacante y le devuelve
//  la roca rockgranite03b scale 3 en arco).
// =====================================================================

void Kolossos_Ability4(int client)
{
    if (!g_cvKolEnabled.BoolValue) return;
    if (!Kolossos_Valid(client)) return;

    float now = GetEngineTime();

    if (g_iKolChargeState[client] != KOL_CHG_IDLE
        || g_iKolGrabVictim[client] != 0
        || g_fKolLungeUntil[client] > now
        || g_fKolIndUntil[client] > now)
    {
        PrintCenterText(client, "[Kolossos] Otra habilidad activa.");
        return;
    }
    if (now < g_fKolBlockCdUntil[client])
    {
        PrintCenterText(client, "Block: %.1fs", g_fKolBlockCdUntil[client] - now);
        return;
    }

    float dur = g_cvKolBlockDur.FloatValue;
    g_fKolBlockUntil[client]     = now + dur;
    g_fKolBlockCdUntil[client]   = now + g_cvKolBlockCd.FloatValue;
    g_bKolBlockCountered[client] = false;

    // v1.1: anim de arranque del bloqueo (GMod l.2520: PillAnim(BlockStart))
    // — la FSM sostiene BlockPos durante toda la ventana
    Kolossos_AnimShot(client, KOL_ST_BLOCKSTART, 0.5, KOL_SHOT_ACT);

    // planta los pies (GMod: OM_NoMovement durante el bloqueo)
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);

    Kolossos_Emit(client, g_bKolSndBlock, "om/kolossos/kol block.wav",
                  "physics/metal/metal_solid_impact_bullet4.wav");

    PrintCenterText(client, "BLOQUEO!");
}

// fin del bloqueo (consumido por el counter o expirado)
void Kolossos_BlockEnd(int client)
{
    if (g_fKolBlockUntil[client] == 0.0) return;
    g_fKolBlockUntil[client] = 0.0;

    if (IsClientInGame(client) && IsPlayerAlive(client))
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
}

// v2.1: LA VENTANA DEL GUARDIA — el bloqueo activo O los KOL_COUNTER_SAFE
// segundos posteriores al counter (la receta Knuckles: durante su contra
// NINGUN empujon del motor lo mueve — "el anti stagger del tank para
// evitar que durante el counter el tank pueda empujar a kolossos")
bool Kolossos_BlockGuard(int client)
{
    if (client < 1 || client > MaxClients) return false;
    float now = GetEngineTime();
    return (g_fKolBlockUntil[client] > now || g_fKolCounterSafeUntil[client] > now);
}

// v2.1: el bloqueo puro ACTIVO (sin la ventana del counter) — el getter
// para los forwards que viven en OTROS includes (Knuckles va ANTES que
// Kolossos en el manager: los globals no se ven ahi, las funciones si)
bool Kolossos_BlockActive(int client)
{
    if (client < 1 || client > MaxClients) return false;
    return g_fKolBlockUntil[client] > GetEngineTime();
}

// =====================================================================
//  v2.2: EL STUN NATIVO DE L4D2 — "cuando kolosos este stuneado
//  (stagger agarrado o demas (ya sabes los stun posibles de L4d2) el
//  reproducira su animacion de stuneado y el sonido (esta en los lua
//  de Gmod)". El Lua (l.1517-1530) dispara los 4 "kol stun N (1).wav"
//  al ENTRAR en DisablePlayerMovement_OM_stun y el ShouldAlternate
//  (L322-395) fuerza la seq "stun" sobre CUALQUIER locomocion. Aqui el
//  equivalente L4D2 completo: los CONTROLES de infectados (pounce del
//  hunter / lengua del smoker / carry y pummel del charger / monta del
//  jockey — los mismos 5 punteros que rompe el bloqueo) + el stagger y
//  el tumbon del motor (ventana marcada por L4D2_OnStagger /
//  L4D_OnKnockedDown del manager cuando el bloqueo NO los absorbe) +
//  el OM_IsStunned de siempre: con cualquiera de ellos la FSM pasa a
//  KOL_ST_STUN y el flanco de entrada suena UNO de los 4 wavs al azar.
// =====================================================================

// algun control de especial agarrado? (los 5 punteros del BlockStateThink)
bool Kolossos_SIControlled(int client)
{
    if (client < 1 || client > MaxClients) return false;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return false;
    // con el bloqueo activo los punteros se rompen el MISMO frame que
    // entran (Kolossos_BlockStateThink): ni un tick de anim de stun
    if (Kolossos_BlockGuard(client)) return false;

    static const char sKolCtlProps[5][20] = {
        "m_pounceAttacker", "m_tongueOwner", "m_carryAttacker",
        "m_pummelAttacker", "m_jockeyAttacker"
    };
    for (int p = 0; p < 5; p++)
    {
        int a = GetEntPropEnt(client, Prop_Send, sKolCtlProps[p]);
        if (a > 0 && a <= MaxClients) return true;
    }
    return false;
}

// el stun TOTAL: suite (OM_Stun) + controles de SI + ventana nativa
bool Kolossos_AnyStun(int client)
{
    if (client < 1 || client > MaxClients) return false;
    if (OM_IsStunned(client)) return true;
    if (g_fKolNativeStunUntil[client] > GetEngineTime()) return true;
    return Kolossos_SIControlled(client);
}

// el manager marca aqui el stagger/knockdown que el bloqueo NO absorbe
// (L4D2_OnStagger / L4D_OnKnockedDown devolviendo Continue: el golpe
// pasa, el coloso lo sufre — y su avatar lo DEMUESTRA)
void Kolossos_NativeStunMark(int client, float dur)
{
    if (client < 1 || client > MaxClients) return;
    if (!Kolossos_PlayerIs(client)) return;
    float now = GetEngineTime();
    if (g_fKolNativeStunUntil[client] < now + dur)
        g_fKolNativeStunUntil[client] = now + dur;
}

// uno de los 4 "kol stun N (1).wav" al azar (solo los que existen; sin
// la carpeta: solo la anim, igual que el Lua sin los wavs)
void Kolossos_StunSound(int client)
{
    if (g_iKolSndStunCount <= 0) return;
    int pick = GetRandomInt(0, g_iKolSndStunCount - 1);
    EmitSoundToAll(g_sKolStunWavs[pick], client, _, KOL_SND_LEVEL);
}

// el flanco de entrada al stun (10 Hz en T_KolossosThink): el sonido
// al EMPEZAR el stun, nunca durante (GMod l.1517: solo la transicion)
void Kolossos_StunEdgeThink(int client)
{
    bool st = Kolossos_AnyStun(client);
    if (st && !g_bKolWasStunned[client]) Kolossos_StunSound(client);
    g_bKolWasStunned[client] = st;
}

// v2.1: EL BLOQUEO DETECTA ESTADOS AL INSTANTE — "ahora podra detectar
// estados al instante... detectando el estado del enemigo y el suyo
// charger hunter smoker y jockey". El estado DEL ENEMIGO lo cazan los
// forwards del manager (tongue/carry/pounce/jockey/slam: la contra sale
// ANTES de que el control empiece — Handled). El SUYO lo barre este
// think CADA FRAME: si un control ya estaba agarrado cuando el bloqueo
// empezo (el B se apreto tarde), los punteros de control se rompen en
// seco (la receta T_KnuxHardStopAttacker: m_pounceAttacker/
// m_jockeyAttacker/m_carryAttacker/m_pummelAttacker a -1) y el
// atacante se come el counter completo
void Kolossos_BlockStateThink(float now)
{
    for (int c = 1; c <= MaxClients; c++)
    {
        if (g_fKolBlockUntil[c] <= now) continue;   // solo con el bloqueo ACTIVO
        if (!Kolossos_PlayerIs(c)) continue;
        if (!IsClientInGame(c) || !IsPlayerAlive(c)) continue;

        // su estado: algun control enemigo agarrado?
        int attacker = 0;
        if (attacker == 0)
        {
            int a = GetEntPropEnt(c, Prop_Send, "m_pounceAttacker");
            if (a > 0) attacker = a;
        }
        if (attacker == 0)
        {
            int a = GetEntPropEnt(c, Prop_Send, "m_tongueOwner");
            if (a > 0) attacker = a;
        }
        if (attacker == 0)
        {
            int a = GetEntPropEnt(c, Prop_Send, "m_carryAttacker");
            if (a > 0) attacker = a;
        }
        if (attacker == 0)
        {
            int a = GetEntPropEnt(c, Prop_Send, "m_pummelAttacker");
            if (a > 0) attacker = a;
        }
        if (attacker == 0)
        {
            int a = GetEntPropEnt(c, Prop_Send, "m_jockeyAttacker");
            if (a > 0) attacker = a;
        }
        if (attacker <= 0 || attacker > MaxClients) continue;
        if (!IsClientInGame(attacker) || !IsPlayerAlive(attacker)) continue;
        if (GetClientTeam(attacker) != 3) continue;

        // romper TODOS los punteros de control (desvinculacion absoluta)
        SetEntPropEnt(c, Prop_Send, "m_pounceAttacker", -1);
        SetEntPropEnt(c, Prop_Send, "m_jockeyAttacker", -1);
        SetEntPropEnt(c, Prop_Send, "m_carryAttacker", -1);
        SetEntPropEnt(c, Prop_Send, "m_pummelAttacker", -1);

        // y el counter completo (consume el bloqueo + ventana anti-empuje)
        Kolossos_BlockEnd(c);
        Kolossos_BlockCounter(c, attacker, attacker);
        PrintCenterText(c, "BLOQUEO! Estado roto al instante");
    }
}

// v2.1: LA GARRA DEL TANK CONTRA EL BLOQUEO — la receta Knuckles del
// CheckTankCounter: cero velocidad + MOVETYPE_NONE 0.2s (el puno del
// tank NO lo desplaza ni un paso — el anti stagger pedido) + la ventana
// anti-empuje + el counter (al tank le sale la ROCA: es fuente pesada)
bool Kolossos_BlockTankClaw(int tank, int player)
{
    if (!Kolossos_PlayerIs(player)) return false;
    if (g_fKolBlockUntil[player] <= GetEngineTime()) return false;

    // clavarlo: ni el knockback del claw lo mueve (receta Knuckles)
    float zeroVel[3] = { 0.0, 0.0, 0.0 };
    TeleportEntity(player, NULL_VECTOR, NULL_VECTOR, zeroVel);
    SetEntityMoveType(player, MOVETYPE_NONE);
    CreateTimer(0.2, Kolossos_T_CounterUnfreeze, GetClientUserId(player), TIMER_FLAG_NO_MAPCHANGE);

    // la contra (consume el bloqueo, abre la ventana anti-empuje)
    Kolossos_BlockEnd(player);
    Kolossos_BlockCounter(player, tank, tank);
    return true;
}

// v2.1: devolverle el movimiento tras la inmovilidad del counter
public Action Kolossos_T_CounterUnfreeze(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
        SetEntityMoveType(client, MOVETYPE_WALK);
    return Plugin_Stop;
}

// el contragolpe: gira al atacante y responde SEGUN LA FUENTE
// v1.1: la anim del counter segun la distancia del atacante (GMod
// l.1347-1355: <300u = BlackCounterMelee cuerpo a cuerpo / si no =
// BlockProjectile a distancia, l.1438-1443)
// v1.9 (owner): [1] las fuentes PROYECTIL — tongue del smoker, acido
// de la spitter, roca del tank — responden SIEMPRE con la ROCA;
// [2] el counter melee MANDA AL ATACANTE en ragdoll stun volando
// ("el counter lanza al enemigo en estado ragdoll" — el
// CreateRagdolLCharacter_OM + dir*3000 del Lua, escalado a L4D2)
void Kolossos_BlockCounter(int client, int attacker, int inflictor)
{
    g_bKolBlockCountered[client] = true;

    // v2.1: LA VENTANA ANTI-EMPUJE — durante el counter (y 1.5s despues)
    // NINGUN fling/knockdown/stagger del motor mueve a Kolossos (la
    // receta Knuckles: "el tank no puede empujarlo durante el counter")
    g_fKolCounterSafeUntil[client] = GetEngineTime() + KOL_COUNTER_SAFE;

    if (!IsClientInGame(attacker) || !IsPlayerAlive(client)) return;

    // girar hacia el atacante (GMod l.1306-1309: angulo asignado)
    float apos[3], mpos[3], ang[3];
    GetClientAbsOrigin(attacker, apos);
    GetClientAbsOrigin(client, mpos);
    ang[0] = 0.0;
    ang[1] = RadToDeg(ArcTangent2(apos[1] - mpos[1], apos[0] - mpos[0]));
    ang[2] = 0.0;
    TeleportEntity(client, NULL_VECTOR, ang, NULL_VECTOR);

    // fuente proyectil? (roca del tank por inflictor, o el propio
    // atacante es smoker/spitter/tank — sus golpes vienen de lejos)
    bool rockSource = false;
    if (inflictor > MaxClients && IsValidEntity(inflictor))
    {
        char icls[24];
        GetEntityClassname(inflictor, icls, sizeof(icls));
        if (StrEqual(icls, "tank_rock")) rockSource = true;
    }
    if (!rockSource)
    {
        int zc = GetEntProp(attacker, Prop_Send, "m_zombieClass");
        if (zc == 1 || zc == 4 || zc == 8) rockSource = true;   // smoker/spitter/tank
    }

    bool meleeRange = (GetVectorDistance(apos, mpos) < 300.0);

    if (rockSource || !meleeRange)
    {
        // LA ROCA DE TANK reforzada (GMod l.1448+: BlockProjectile + el
        // arco scripted — v1.9: 75 de dano + stun al area)
        Kolossos_AnimShot(client, KOL_ST_BLOCKPROJ, 1.0, KOL_SHOT_ACT);
        Kolossos_SpawnCounterRock(client, apos);
        return;
    }

    // counter melee: anim + el atacante sale en RAGDOLL stun volando
    Kolossos_AnimShot(client, KOL_ST_COUNTER, 1.0, KOL_SHOT_ACT);

    float dir[3];
    MakeVectorFromPoints(mpos, apos, dir);
    dir[2] = 0.0;
    NormalizeVector(dir, dir);

    if (g_cvKolCntRag != null && g_cvKolCntRag.BoolValue
        && OM_Stun(attacker, KOL_CNT_STUN, client, 0.0, DMG_OM_CLUB, true))
    {
        // el doble vuela con impulso por hueso; el original oculto lo
        // sigue (congruencia) y revive donde cae (2.5s de castigo)
        Kolossos_VictRagFling(client, attacker, dir, KOL_CNT_FLING);
    }
    else
    {
        // sin ragdolls (convar off): el fling directo
        float push[3];
        push[0] = dir[0] * KOL_CNT_FLING;
        push[1] = dir[1] * KOL_CNT_FLING;
        push[2] = KOL_CNT_FLING * KOL_CNT_LIFT;
        TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, push);
    }

    Kolossos_Emit(client, g_bKolSndPunch, "om/kolossos/kolossos punching.wav",
                  "physics/flesh/flesh_impact_hard3.wav");
}

// v2.1: LA ROCA ESTILO LANZA — "usara el mismo tipo de roca... siguiendo
// las pautas de la habilidad original de como esta la lanza": la roca
// VUELA RECTA por DIRECCION guardada al disparar (la receta del javelin
// de Blaze v2.5: cero arco balistico, cero lecturas de velocidad) con
// la HITBOX del segmento recorrido del tick (v2.8: el barrido que mato
// los huecos) y al IMPACTAR produce el STUN RAGDOLL con el MISMO tiempo
// del counter melee (KOL_CNT_STUN): dano en area + los especiales que
// sobreviven salen en ragdoll stun volando (VictRagFling). Tope 2.5s.
// v2.2: EL MODELO YA NO ES rockgranite03b A CIEGAS — es un modelo de
// HL2 que L4D2 no trae: el FileExists daba false y esta funcion salia
// en silencio (NI roca NI dano desde la v1.9 — "la piedra todavia no
// sale"). Ahora vuela con el modelo que resolvio la CADENA del
// OnMapStart (rockgranite03b del GMod si esta montada -> el chunk de
// concreto de Amy -> la gascan nativa), la escala va por m_flModelScale
// (la receta de la bola de Knuckles: el KV "modelscale" no aplica en
// prop_physics_override) y la colision es DEBRIS — solo mundo, igual
// que el MOVETYPE_NONE del Lua l.1458 (la roca del GMod no empuja a
// nadie: el dano lo hace el barrido del vuelo, no el vphysics).
void Kolossos_SpawnCounterRock(int client, const float targetPos[3])
{
    if (!g_bKolRockModel)
    {
        // v2.2: cadena vacia (con la gascan nativa es casi imposible,
        // pero HONESTO): el counter a distancia NO se queda en nada —
        // la detonacion cae DIRECTO sobre el atacante, sin roca visible
        float tp[3];
        tp[0] = targetPos[0]; tp[1] = targetPos[1]; tp[2] = targetPos[2] + 20.0;

        // la direccion del stun-ragdoll de RockBlast sale de
        // g_vKolRockDir: apuntarla al blanco ANTES (sin roca que la
        // fije en el vuelo, quedaria la de la roca anterior)
        float cpos[3], aim[3];
        GetClientAbsOrigin(client, cpos);
        MakeVectorFromPoints(cpos, tp, aim);
        if (NormalizeVector(aim, aim) < 1.0)
        {
            aim[0] = 1.0; aim[1] = 0.0; aim[2] = 0.0;
        }
        g_vKolRockDir[client][0] = aim[0];
        g_vKolRockDir[client][1] = aim[1];
        g_vKolRockDir[client][2] = aim[2];

        EmitSoundToAll("physics/concrete/concrete_break2.wav", client, _, KOL_SND_LEVEL);
        Kolossos_RockBlast(client, tp);
        return;
    }

    // una roca en vuelo por Kolossos (patron Silver/Blaze)
    if (g_iKolRockFlying[client] != 0)
    {
        int old = EntRefToEntIndex(g_iKolRockFlying[client]);
        if (old > 0 && IsValidEntity(old)) AcceptEntityInput(old, "Kill");
        g_iKolRockFlying[client] = 0;
    }

    int rock = CreateEntityByName("prop_physics_override");
    if (rock <= 0 || !IsValidEntity(rock)) return;

    DispatchKeyValue(rock, "model", g_sKolRockModel);
    DispatchKeyValue(rock, "targetname", "kolossos_rock_om");
    DispatchSpawn(rock);

    // v2.2: escala por m_flModelScale (bola de Knuckles / esfera de
    // Rouge — el KV "modelscale" no vive en prop_physics_override) y
    // colision DEBRIS = solo mundo (la receta MOVETYPE_NONE del Lua:
    // la roca atraviesa sin empujar, el dano lo pone el barrido)
    if (HasEntProp(rock, Prop_Send, "m_flModelScale"))
        SetEntPropFloat(rock, Prop_Send, "m_flModelScale", g_cvKolRockScale.FloatValue);
    SetEntProp(rock, Prop_Data, "m_CollisionGroup", KOL_ROCK_COLGROUP);

    // nace al frente del PECHO del coloso (el puno que la lanza)
    float pos[3], dir[3];
    GetClientAbsOrigin(client, pos);
    Kolossos_GetMoveDir(client, dir);
    pos[0] += dir[0] * KOL_ROCK_SPAWN_FWD;
    pos[1] += dir[1] * KOL_ROCK_SPAWN_FWD;
    pos[2] += KOL_ROCK_SPAWN_UP;
    TeleportEntity(rock, pos, NULL_VECTOR, NULL_VECTOR);

    // DIRECCION FIJA al blanco (la pauta de la lanza: recta, sin arco)
    float aim[3];
    aim[0] = targetPos[0] - pos[0];
    aim[1] = targetPos[1] - pos[1];
    aim[2] = (targetPos[2] + 20.0) - pos[2];
    if (NormalizeVector(aim, aim) < 1.0)
    {
        // blanco encima: sale al frente
        aim[0] = dir[0]; aim[1] = dir[1]; aim[2] = 0.1;
        NormalizeVector(aim, aim);
    }
    g_vKolRockDir[client][0] = aim[0];
    g_vKolRockDir[client][1] = aim[1];
    g_vKolRockDir[client][2] = aim[2];
    g_vKolRockPrev[client][0] = pos[0];
    g_vKolRockPrev[client][1] = pos[1];
    g_vKolRockPrev[client][2] = pos[2];

    float vel[3];
    vel[0] = aim[0] * KOL_ROCK_SPEED;
    vel[1] = aim[1] * KOL_ROCK_SPEED;
    vel[2] = aim[2] * KOL_ROCK_SPEED;
    TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, vel);

    g_iKolRockFlying[client] = EntIndexToEntRef(rock);
    g_fKolRockDieAt[client]  = GetEngineTime() + KOL_ROCK_FLIGHT_MAX;

    Kolossos_Emit(client, g_bKolSndRumble, "om/kolossos/kol charge start ground rumble.wav",
                  "ambient/machines/thumper_hit.wav");
}

// el vuelo de la roca (cada tick en T_Kol_LayerThink): direccion fija,
// hitbox = segmento recorrido (barrido, receta Blaze v2.8), pared = impacto
void Kolossos_RockFlightThink(float now)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iKolRockFlying[i] == 0) continue;

        int rock = EntRefToEntIndex(g_iKolRockFlying[i]);
        if (rock <= 0 || !IsValidEntity(rock))
        {
            g_iKolRockFlying[i] = 0;
            continue;
        }

        // tope de vuelo (cielo/mapa abierto): detona donde este
        if (now >= g_fKolRockDieAt[i])
        {
            Kolossos_RockDetonate(i, rock);
            continue;
        }

        float rp[3];
        GetEntPropVector(rock, Prop_Data, "m_vecOrigin", rp);

        // ---- pared delante? SOLO el segmento recorrido del tick ----
        float segEnd[3], rockDir[3];
        rockDir[0] = g_vKolRockDir[i][0];
        rockDir[1] = g_vKolRockDir[i][1];
        rockDir[2] = g_vKolRockDir[i][2];
        segEnd[0] = rp[0] + rockDir[0] * 60.0;   // un paso de proyeccion
        segEnd[1] = rp[1] + rockDir[1] * 60.0;
        segEnd[2] = rp[2] + rockDir[2] * 60.0;

        Handle tr = TR_TraceRayFilterEx(g_vKolRockPrev[i], segEnd, MASK_SOLID_BRUSHONLY,
                                        RayType_EndPoint, Kolossos_RockTraceFilter, rock);
        bool hitWorld = false;
        if (TR_DidHit(tr)) hitWorld = true;   // el filtro solo deja pasar el mundo
        delete tr;
        if (hitWorld)
        {
            Kolossos_RockDetonate(i, rock);
            continue;
        }

        // ---- caza en el segmento (barrido como el javelin) ----
        int victim = Kolossos_RockScanPath(i, g_vKolRockPrev[i], rp);
        g_vKolRockPrev[i][0] = rp[0];
        g_vKolRockPrev[i][1] = rp[1];
        g_vKolRockPrev[i][2] = rp[2];
        if (victim > 0)
        {
            Kolossos_RockDetonate(i, rock);
            continue;
        }

        // ---- sostener el vuelo: dir fija * velocidad (vphysics + belt) ----
        float v[3];
        v[0] = rockDir[0] * KOL_ROCK_SPEED;
        v[1] = rockDir[1] * KOL_ROCK_SPEED;
        v[2] = rockDir[2] * KOL_ROCK_SPEED;
        float noSpin[3] = { 0.0, 0.0, 0.0 };
        if (!Sonic_PhysSetVel(rock, v, noSpin))
            TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, v);
    }
}

// filtro del trace de pared: SOLO el mundo cuenta (la roca y las
// entidades vivas no la frenan — estas se cazan por el barrido)
public bool Kolossos_RockTraceFilter(int entity, int contentsMask, any data)
{
    if (entity == view_as<int>(data)) return false;
    if (entity > 0 && entity <= MaxClients) return false;
    char cls[20];
    if (entity > MaxClients && IsValidEntity(entity))
    {
        GetEntityClassname(entity, cls, sizeof(cls));
        if (StrContains(cls, "prop_") == 0 || StrContains(cls, "infected") == 0
            || StrContains(cls, "witch") == 0) return false;
    }
    return true;   // el mundo (y lo demas solido) frena la roca
}

// el barrido del segmento (receta Blaze_ScanEnemyPath): muestreo del
// tramo recorrido contra commons/especiales/witch
int Kolossos_RockScanPath(int client, const float from[3], const float to[3])
{
    float seg[3];
    SubtractVectors(to, from, seg);
    float len = NormalizeVector(seg, seg);
    float step = KOL_ROCK_CATCH_RADIUS * 0.66;
    int steps = (len <= step) ? 1 : RoundToCeil(len / step);
    if (steps > 10) steps = 10;
    float c[3];
    for (int s = 0; s < steps; s++)
    {
        float t = (steps > 1) ? float(s) / float(steps - 1) : 1.0;
        c[0] = from[0] + seg[0] * len * t;
        c[1] = from[1] + seg[1] * len * t;
        c[2] = from[2] + seg[2] * len * t;

        int victim = Kolossos_RockScanSphere(client, c);
        if (victim > 0) return victim;
    }
    return 0;
}

// esfera de caza puntual: commons -> especiales -> witch
int Kolossos_RockScanSphere(int client, const float c[3])
{
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (GetVectorDistance(epos, c) <= KOL_ROCK_CATCH_RADIUS) return ent;
    }
    for (int t = 1; t <= MaxClients; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        tpos[2] += 40.0;   // centro del cuerpo
        if (GetVectorDistance(tpos, c) <= KOL_ROCK_CATCH_RADIUS) return t;
    }
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (!IsValidEntity(w)) continue;
        if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
        float wpos[3];
        GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
        if (GetVectorDistance(wpos, c) <= KOL_ROCK_CATCH_RADIUS) return w;
    }
    return 0;
}

// v2.1: LA DETONACION — "esta roca producira el stun ragdoll al impactar
// (tendra el mismo tiempo de stun que el original, que hace a melee)":
// dano en radio (REGLA v3.77.85: SNAPSHOT primero, dano fuera de los
// bucles) + los ESPECIALES que sobreviven salen en RAGDOLL stun con
// KOL_CNT_STUN (el mismo del counter melee, 4.5s) volando en la
// direccion del vuelo. Commons/witch: dano (ellos mueren solos).
void Kolossos_RockDetonate(int client, int rock)
{
    float pos[3];
    GetEntPropVector(rock, Prop_Data, "m_vecOrigin", pos);

    // el estruendo del impacto ANTES de matarla (la roca del coloso
    // revienta el suelo — el sonido necesita la entidad viva)
    EmitSoundToAll("physics/concrete/concrete_break2.wav", rock, _, KOL_SND_LEVEL);

    g_iKolRockFlying[client] = 0;
    AcceptEntityInput(rock, "Kill");

    Kolossos_RockBlast(client, pos);
}

// v2.2: el AREA DEL IMPACTO separada de la entidad — la misma detonacion
// de la v2.1 (snapshot primero, dano fuera de los bucles) reutilizable
// por el fallback sin modelo de SpawnCounterRock (la cadena vacia:
// el counter a distancia cae DIRECTO sobre el atacante)
void Kolossos_RockBlast(int client, const float pos[3])
{
    float dmg = g_cvKolRockDmg.FloatValue;

    int   snapEnts[64];
    bool  snapIsSI[64];
    int   snapCount = 0;

    // commons — snapshot
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (GetVectorDistance(epos, pos) > KOL_ROCK_TOUCH_RADIUS) continue;
        snapEnts[snapCount] = ent;
        snapIsSI[snapCount] = false;
        snapCount++;
    }

    // infectados especiales — snapshot
    for (int t = 1; t <= MaxClients && snapCount < 64; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (GetVectorDistance(tpos, pos) > KOL_ROCK_TOUCH_RADIUS) continue;
        snapEnts[snapCount] = t;
        snapIsSI[snapCount] = true;
        snapCount++;
    }

    // witch — snapshot
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (snapCount >= 64) break;
        if (!IsValidEntity(w)) continue;
        if (GetEntProp(w, Prop_Data, "m_iHealth") <= 0) continue;
        float wpos[3];
        GetEntPropVector(w, Prop_Data, "m_vecOrigin", wpos);
        if (GetVectorDistance(wpos, pos) > KOL_ROCK_TOUCH_RADIUS) continue;
        snapEnts[snapCount] = w;
        snapIsSI[snapCount] = false;
        snapCount++;
    }

    // EL DAÑO VA AQUI — fuera de los bucles, re-validando
    float dir[3];
    dir[0] = g_vKolRockDir[client][0];
    dir[1] = g_vKolRockDir[client][1];
    dir[2] = g_vKolRockDir[client][2];

    for (int k = 0; k < snapCount; k++)
    {
        int v = snapEnts[k];
        if (v <= 0 || !IsValidEntity(v)) continue;
        if (snapIsSI[k] && v <= MaxClients)
        {
            if (!IsClientInGame(v) || !IsPlayerAlive(v)) continue;
        }
        else if (v > MaxClients)
        {
            if (GetEntProp(v, Prop_Data, "m_iHealth") <= 0) continue;
        }
        SDKHooks_TakeDamage(v, client, client, dmg, DMG_CLUB);

        // v2.1: EL STUN RAGDOLL del impacto — el mismo tratamiento del
        // counter melee (KOL_CNT_STUN de stun + doble volando con follow
        // congruente); los que mueren con el golpe caen solos
        if (snapIsSI[k] && v <= MaxClients && IsClientInGame(v) && IsPlayerAlive(v))
        {
            if (g_cvKolCntRag != null && g_cvKolCntRag.BoolValue)
            {
                if (OM_Stun(v, KOL_CNT_STUN, client, 0.0, DMG_OM_CLUB, true))
                    Kolossos_VictRagFling(client, v, dir, KOL_CNT_FLING);
            }
            else if (g_cvKolRockStun != null && g_cvKolRockStun.FloatValue > 0.0)
                OM_Stun(v, g_cvKolRockStun.FloatValue, client, 0.0, DMG_OM_CLUB, false);
        }
    }
}

// =====================================================================
//  DAÑO ENTRANTE: resistencia pasiva + inmunidad del bloqueo + counter
// =====================================================================

public Action Kolossos_OnTakeDamage(int victim, int &attacker, int &inflictor,
                                    float &damage, int &damagetype, int &weapon,
                                    float damageForce[3], float damagePosition[3],
                                    int damagecustom)
{
    if (!Kolossos_PlayerIs(victim)) return Plugin_Continue;

    // ---- bloqueo activo: dano de infectados a CERO (GMod l.1256-1261) ----
    // v1.9 (owner): el COUNTER solo lo disparan los ESPECIALES y sus
    // habilidades ("el counter ahora puede counterar ataques basicos de
    // otros infectados habilidades y demas — menos a los commons, ellos
    // siguen sin contar, asi la witch tambien"): commons/witch y el FF
    // de survivors quedan ABSORVIDOS (dano 0) pero sin contra.
    if (g_fKolBlockUntil[victim] > GetEngineTime())
    {
        bool siAttacker = false;    // cliente team 3: cuenta para el counter
        bool absorb = false;        // absorbe sin contra (commons/witch/FF/otros)

        if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
        {
            if (GetClientTeam(attacker) == 3) siAttacker = true;
            else absorb = true;
        }
        else absorb = true;   // commons (attacker entidad), witch, cualquier otra fuente

        if (siAttacker || absorb)
        {
            damage = 0.0;

            // el PRIMER golpe de un ESPECIAL consume el bloqueo y dispara el counter
            if (siAttacker && !g_bKolBlockCountered[victim] && attacker > 0)
            {
                Kolossos_BlockEnd(victim);
                Kolossos_BlockCounter(victim, attacker, inflictor);
            }
            return Plugin_Changed;
        }
    }

    // ---- resistencia pasiva (kolossos_resistance 100 = neutro) ----
    float resist = g_cvKolResist.FloatValue;
    if (resist < 99.5 && resist > 0.0)
    {
        damage *= resist / 100.0;
        return Plugin_Changed;
    }

    return Plugin_Continue;
}

// =====================================================================
//  v1.9: EL PUO BASICO AL CLICK — "se supone que el ataque basico se
//  deberia hacer con el click (orden de propio Gmod) pero click izq es
//  disparar, por lo que necesitamos que haya algo que pueda bloquear
//  los disparos del arma... el click de disparo PISADO por el de
//  ataque de Kolossos (ojo solo para las ramas primarias y
//  secundarias; para las granadas o botiquines seguiran igual el click
//  izq podra funcionar en ellas)" — el owner, literal.
// =====================================================================

// el pisado: arma activa en slot 0/1 -> IN_ATTACK fuera (el arma NO
// dispara) y el flanco de bajada del click = el puo. Devuelve true si
// los buttons cambiaron (el manager devuelve Plugin_Changed)
// v2.0: ADEMAS se congela el m_flNextPrimaryAttack del arma MIENTRAS
// sea la activa de slot 0/1 — reporte del owner: "el arma aun sigue
// (visualmente disparando) aunque no gasta balas ni hace dano". El
// pisado del IN_ATTACK mataba el disparo del SERVER, pero la
// PREDICCION del cliente ya habia dibujado el fogonazo y el
// retroceso del viewmodel: m_flNextPrimaryAttack es un campo
// NETWORKADO y PREDICIDO — congelandolo por delante (se refresca en
// CADA RunCmd, incluso sin click), la prediccion del cliente ve "aun
// no puede disparar" y no dibuja NADA. La recarga no se toca (si
// m_bInReload esta activo no se escribe: el bombeo/insert de las
// escopetas se timed por este campo) y al soltar el arma el freeze
// caduca solo (<=0.3s).
bool Kolossos_M1Gate(int client, int &buttons)
{
    if (g_cvKolM1 == null || !g_cvKolM1.BoolValue) return false;

    int wep = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if (wep <= 0 || !IsValidEntity(wep)) return false;

    // SOLO primaria (0) y secundaria (1): granadas (2), botiquin (3) y
    // pastillas (4) quedan INTACTOS — su click izq funciona normal
    bool slot01 = false;
    for (int s = 0; s <= 1; s++)
        if (GetPlayerWeaponSlot(client, s) == wep) { slot01 = true; break; }
    if (!slot01) return false;

    // v2.0: EL FREEZE DE LA PREDICCION — refrescado en cada cmd (sin
    // click tambien: cuando el jugador apriete, el cliente YA ve el
    // arma fria). No durante la recarga.
    if (HasEntProp(wep, Prop_Send, "m_flNextPrimaryAttack")
        && (!HasEntProp(wep, Prop_Send, "m_bInReload")
            || GetEntProp(wep, Prop_Send, "m_bInReload") == 0))
    {
        float nxt = GetEntPropFloat(wep, Prop_Send, "m_flNextPrimaryAttack");
        float horizon = GetGameTime() + 0.3;
        if (nxt < horizon)
            SetEntPropFloat(wep, Prop_Send, "m_flNextPrimaryAttack", horizon);
    }

    if (!(buttons & IN_ATTACK)) return false;

    bool rising = !(g_iKolLastButtons[client] & IN_ATTACK);   // un dano por click

    buttons &= ~IN_ATTACK;
    if (rising) Kolossos_M1(client);
    return true;
}

// =====================================================================
//  v2.1: EL BLOQUEO DETECTA EL ESTADO DEL ENEMIGO — las ramas Kolossos
//  de los forwards reales (lengua del smoker / carry+slam del charger
//  en Knuckles.inc; pounce del hunter y monta del jockey en sonic.inc;
//  garra del tank en el L4D_TankClaw_OnPlayerHit_Pre del manager): con
//  el bloqueo activo el control NUNCA empieza (Handled) y el atacante
//  se come el counter completo. El estado PROPIO (un control que ya
//  estaba agarrado al apretar B) lo rompe Kolossos_BlockStateThink
//  cada frame (T_Kol_LayerThink).
// =====================================================================

// el M1 (GMod l.2541-2675, attack.mode 'trigger'): con victima
// agarrada = el puo del combo; sin ella = el basico (esfera 65u al
// frente, dano kolossos_m1_damage, CD 1.65 = AttackCooldown del Lua)
void Kolossos_M1(int client)
{
    float now = GetEngineTime();

    // con victima en vilo: el mismo puo del combo (GMod l.2566)
    if (g_iKolGrabVictim[client] != 0)
    {
        Kolossos_GrabPunch(client);
        return;
    }

    // gates del Lua l.2558-2565 (nada de pegar en windup/dash/etc)
    if (g_iKolChargeState[client] != KOL_CHG_IDLE) return;
    if (g_fKolLungeUntil[client] > now) return;
    if (g_fKolBlockUntil[client] > now) return;
    if (g_fKolIndUntil[client] > now) return;
    // v2.2: el gate tambien cuenta el stun NATIVO (pounce/lengua/carry/
    // pummel/jockey/stagger/knockdown) — un coloso ensartado no pega
    if (Kolossos_AnyStun(client)) return;
    if (now < g_fKolM1CdUntil[client]) return;
    g_fKolM1CdUntil[client] = now + KOL_M1_CD;

    // sonido (kol m1 1-4 del killer, fallback nativo)
    // v2.2: SOLO entre los que EXISTEN y ya estan precacheados (la lista
    // compactada del OnMapStart) — antes elegia 1-4 a ciegas y solo el
    // (1) se habia comprobado: de ahi el "not precached" del (2)/(3)/(4)
    if (g_bKolSndM1)
    {
        EmitSoundToAll(g_sKolM1Wavs[GetRandomInt(0, g_iKolSndM1Count - 1)],
                       client, _, KOL_SND_LEVEL);
    }
    else
        EmitSoundToAll("physics/flesh/flesh_impact_hard4.wav", client, _, KOL_SND_LEVEL);

    // la esfera del golpe (la misma geometria frontal del empale)
    float pos[3], dir[3];
    GetClientAbsOrigin(client, pos);
    Kolossos_GetMoveDir(client, dir);
    pos[0] += dir[0] * 40.0;
    pos[1] += dir[1] * 40.0;
    pos[2] += 40.0;

    // v2.1: LA TIRADA 350-450 (pedido del owner: "los ataques basicos
    // aumentaran su dano de 125 a 350-450") — cada swing sale entre
    // kolossos_m1_damage y kolossos_m1_damage_max
    float dmg = (g_cvKolM1Dmg != null) ? g_cvKolM1Dmg.FloatValue : 350.0;
    float dmgMax = (g_cvKolM1DmgMax != null) ? g_cvKolM1DmgMax.FloatValue : 450.0;
    if (dmgMax < dmg) dmgMax = dmg;
    dmg = GetRandomFloat(dmg, dmgMax);

    // SNAPSHOT primero, dano despues (REGLA v3.77.85)
    int   m1Ents[32];
    bool  m1IsSI[32];
    int   m1Count = 0;

    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (m1Count >= 32) break;
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        if (GetVectorDistance(epos, pos) > KOL_M1_RANGE) continue;
        m1Ents[m1Count] = ent; m1IsSI[m1Count] = false; m1Count++;
    }
    for (int t = 1; t <= MaxClients && m1Count < 32; t++)
    {
        if (t == client || !IsClientInGame(t) || !IsPlayerAlive(t)) continue;
        if (GetClientTeam(t) != 3) continue;
        float tpos[3];
        GetClientAbsOrigin(t, tpos);
        if (GetVectorDistance(tpos, pos) > KOL_M1_RANGE) continue;
        m1Ents[m1Count] = t; m1IsSI[m1Count] = true; m1Count++;
    }

    for (int k = 0; k < m1Count; k++)
    {
        int v = m1Ents[k];
        if (v <= 0 || !IsValidEntity(v)) continue;
        if (m1IsSI[k] && v <= MaxClients)
        {
            if (!IsClientInGame(v) || !IsPlayerAlive(v)) continue;
        }
        else if (v > MaxClients)
        {
            if (GetEntProp(v, Prop_Data, "m_iHealth") <= 0) continue;
        }
        OM_AbilityDamage(v, client, dmg);
    }

    if (m1Count > 0)
        Kolossos_Emit(client, g_bKolSndImpacts, "om/kolossos/Kol impacts.wav",
                      "physics/flesh/flesh_impact_hard4.wav");

    // v2.0: EL SWING — el M1 basico del GMod es el gesture
    // ACT_MELEE_ATTACK_SWING_GESTURE (Lua l.2638), NO el GrabPunch: la
    // serie swing fusionada con la locomocion del instante (pack
    // v1.5.3). Sin ella cae a la serie punch de la v1.9
    Kolossos_SwingShot(client, KOL_DUR_SWING, KOL_SHOT_GRAB);
}

// v2.0: EL SWING FUSIONADO — el M1 con las piernas andando: brazos +
// torso del swingsub (el swing completo del .mdl: brazos == swing.smd
// exacto + UpperTorso 80 grados + Head 71 del addlayer ya aplicado) y
// Root/piernas de la locomocion. Si el .mdl no trae la serie (pack
// v1.5.3), cae a la SERIE PUNCH de la v1.9 — y si tampoco hay fusion,
// al nothing crudo de siempre (veredicto v1.7)
void Kolossos_SwingShot(int client, float dur, int tier)
{
    // fallback v1.9: la serie punch con SU duracion (el swing es 0.38s,
    // el punch 0.85 — recortarlo se veria raro)
    if (!Kolossos_FusionActive())
    {
        Kolossos_GrabShot(client, KOL_ST_GRABPUNCH,
                          Kolossos_ShotDur(KOL_ST_GRABPUNCH, KOL_DUR_GRABPUNCH) * 0.6,
                          tier);
        return;
    }

    int loco = Kolossos_LocoNow(client);
    int fused = (loco == KOL_ST_RUN)  ? KOL_ST_SWING_RUN
              : ((loco == KOL_ST_WALK) ? KOL_ST_SWING_WALK : KOL_ST_SWING_IDLE);

    if (!g_bKolFusedNative[fused])
    {
        Kolossos_GrabShot(client, KOL_ST_GRABPUNCH,
                          Kolossos_ShotDur(KOL_ST_GRABPUNCH, KOL_DUR_GRABPUNCH) * 0.6,
                          tier);
        return;
    }

    Kolossos_AnimShot(client, fused, dur, tier);
}

public bool Kolossos_OnPlayerRunCmd(int client, int &buttons, float vel[3])
{
    if (!Kolossos_PlayerIs(client) || !IsPlayerAlive(client))
    {
        g_iKolLastButtons[client] = buttons;
        return false;
    }

    // v1.9: el click izq pisado en slots 0/1 = EL PUO (el arma no dispara)
    bool changed = Kolossos_M1Gate(client, buttons);
    g_iKolLastButtons[client] = buttons;

    // durante el WINDUP: clavado en el sitio
    if (g_iKolChargeState[client] == KOL_CHG_WINDUP)
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);
        return changed;
    }

    if (g_iKolChargeState[client] != KOL_CHG_DASH) return changed;

    // forwardmove saturado (el engine clampea al m_flMaxspeed del stack)
    vel[0] = KOL_DASH_VEL_INJECT;
    vel[1] = 0.0;
    if (vel[2] < 0.0) vel[2] = 0.0;
    return true;
}

// =====================================================================
//  FSM CENTRAL (10 Hz — patron T_BlazeAvatarThink)
// =====================================================================

public Action T_KolossosThink(Handle timer)
{
    float now = GetEngineTime();

    // v1.9: el latido del registro de ragdolls (follow congruente de
    // TODOS los modos + restauracion y limpieza de huerfanos; el PIN por
    // frame vive en T_Kol_LayerThink)
    Kolossos_VictRagThink();

    // el indicator es global (una sola nube a la vez por simplicidad):
    // buscar al Kolossos que lo tiene activo
    int indOwner = 0;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Kolossos_KillAvatar(i); continue; }

        bool esKolViva = (Kolossos_PlayerIs(i) && IsPlayerAlive(i)
                          && GetClientTeam(i) == 2);

        // incap = cancel suave (la FSM re-monta al levantarse)
        if (esKolViva && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            esKolViva = false;

        // ---- EL TICK DEL KIT ----
        if (esKolViva)
        {
            // v2.2: el stun NATIVO tambien cancela el kit (el Lua
            // l.935/l.1012: nada de habilidades con el stun puesto)
            if (Kolossos_AnyStun(i))
            {
                // aturdido: cancelar todo (no pelear contra el stun)
                if (g_iKolChargeState[i] != KOL_CHG_IDLE) Kolossos_ChargeEnd(i, false);
                if (g_iKolGrabVictim[i] != 0) Kolossos_GrabRelease(i, false, false);
                if (g_fKolBlockUntil[i] > 0.0) Kolossos_BlockEnd(i);
            }
            else
            {
                // auto-gestion: hook de dano + vida max UNA vez por vida
                // (cubre tambien la eleccion a mitad de ronda via menu)
                if (!g_bKolHooked[i])
                {
                    g_bKolHooked[i] = true;
                    SDKUnhook(i, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
                    SDKHook(i, SDKHook_OnTakeDamage, Kolossos_OnTakeDamage);
                }
                if (!g_bKolHpApplied[i])
                {
                    g_bKolHpApplied[i] = true;
                    Kolossos_ApplyMaxHealth(i);
                }

                // charge: windup (lagged 0) / dash (impacto + watchdog)
                if (g_iKolChargeState[i] == KOL_CHG_DASH)
                    Kolossos_ChargeDashThink(i, now);
                else if (g_iKolChargeState[i] == KOL_CHG_WINDUP
                         && now >= g_fKolWindupStart[i] + KOL_CHG_WINDUP_T)
                {
                    // safety: los timers del windup se perdieron (mapchange)
                    Kolossos_ChargeLaunch(i);
                }

                // grab: ventana del lunge / victima en vilo
                if (g_fKolLungeUntil[i] > now)
                    Kolossos_GrabLungeThink(i, now);
                else if (g_iKolGrabVictim[i] != 0)
                    Kolossos_GrabHoldThink(i, now);

                // block: expiracion natural
                if (g_fKolBlockUntil[i] > 0.0 && now >= g_fKolBlockUntil[i])
                    Kolossos_BlockEnd(i);

                // v2.2: el flanco del stun (nativo o suite) — el sonido
                // de entrada "kol stun N" al EMPEZAR el stun (10 Hz,
                // corre con o sin avatar: el kit entero lo escucha)
                Kolossos_StunEdgeThink(i);

                // indicator
                if (g_fKolIndUntil[i] > now) indOwner = i;
            }
        }
        else
        {
            // no es Kolossos vivo: limpiar estado si quedo algo
            if (g_iKolChargeState[i] != KOL_CHG_IDLE) Kolossos_ChargeEnd(i, false);
            if (g_iKolGrabVictim[i] != 0) Kolossos_GrabRelease(i, false, false);
            if (g_fKolBlockUntil[i] > 0.0) Kolossos_BlockEnd(i);
            if (g_fKolIndUntil[i] > 0.0)   g_fKolIndUntil[i] = 0.0;
        }

        // ---- montaje del avatar ----
        if (g_iKolAvatar[i] == 0)
        {
            if (esKolViva && g_cvKolAvatar != null && g_cvKolAvatar.BoolValue
                && g_bKolModelOK)
            {
                Kolossos_CreateAvatar(i);
            }
            continue;
        }

        if (!esKolViva)
        {
            Kolossos_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iKolAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iKolAvatar[i] = 0;
            g_iKolAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (fix Tails v5.4)
        if (g_iKolBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparacion de la copia L
        if (g_iKolAvatarL[i] == 0 && g_iKolAvatar[i] != 0)
        {
            Kolossos_CreateAvatarL(i);
            if (g_iKolAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // FSM de animacion
        av = EntRefToEntIndex(g_iKolAvatar[i]);
        if (g_iKolAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Kolossos_AvatarUpdate(i, av, now);
    }

    // la nube del indicator vive mientras su dueno la tenga activa
    if (indOwner != 0)
        Kolossos_IndicatorThink(indOwner, now);
    else
        Kolossos_IndicatorStop();

    return Plugin_Continue;
}

// =====================================================================
//  DEBUG
// =====================================================================

public Action Kolossos_CmdDebug(int client, int args)
{
    client = Sonic_SoloClient(client);
    if (!IsValidClient(client)) return Plugin_Handled;

    float now = GetEngineTime();
    PrintToConsole(client, "=== Kolossos v%s ===", KOLOSSOS_INC_VERSION);
    PrintToConsole(client, "Personaje: %s | Vida: %d/%d",
                   Kolossos_PlayerIs(client) ? "SI" : "NO",
                   GetClientHealth(client),
                   GetEntProp(client, Prop_Data, "m_iMaxHealth"));
    PrintToConsole(client, "Modelo: %s | Avatar R: %s | L: %s",
                   g_bKolModelOK ? "OK" : "FALTA",
                   g_iKolAvatar[client] != 0 ? "vivo" : "-",
                   g_iKolAvatarL[client] != 0 ? "vivo" : "-");
    PrintToConsole(client, "Charge: estado %d | fin %.1f | CD %.1f",
                   g_iKolChargeState[client],
                   g_fKolChargeEnd[client] - now,
                   g_fKolChargeCdUntil[client] - now);
    PrintToConsole(client, "Grab: victima %d | puos %d | lunge %.1f | CD %.1f",
                   g_iKolGrabVictim[client] != 0 ? EntRefToEntIndex(g_iKolGrabVictim[client]) : -1,
                   g_iKolGrabPunches[client],
                   g_fKolLungeUntil[client] - now,
                   g_fKolGrabCdUntil[client] - now);
    PrintToConsole(client, "Block: %.1f | Indicator: %.1f",
                   g_fKolBlockUntil[client] - now,
                   g_fKolIndUntil[client] - now);
    // v1.1: la FSM de animacion al dia (estado + one-shot activo)
    char seqNow[24];
    Kolossos_SeqFor(g_iKolAnimState[client] >= 0 ? g_iKolAnimState[client] : 0, seqNow, sizeof(seqNow));
    PrintToConsole(client, "Anim: estado %d (%s) | one-shot %s (prio %d)",
                   g_iKolAnimState[client], seqNow,
                   (g_iKolAnimShotState[client] >= 0 && now < g_fKolAnimShotUntil[client])
                       ? g_sKolSeqName[g_iKolAnimShotState[client]] : "-",
                   g_iKolAnimShotTier[client]);
    // v1.6: el motor de CAPAS REALES — el avatar commentary_dummy es el
    // unico host de L4D2 que networka el overlay (jerarquia oficial de
    // Valve: CCommentaryDummy -> ... -> CBaseAnimatingOverlay). Si esta
    // ACTIVO, la linea de abajo del Fusion es solo informativa (fallback)
    // v1.6.1: el host ahora reporta POR QUE cayo el dummy (si cayo) y la
    // tabla con la forma que gano la sonda (.000 punteada / [] element)
    char kolTabla[32];
    if (g_sKolLayPrefix[0] == '\0')                strcopy(kolTabla, sizeof(kolTabla), "-");
    else if (g_iKolLayForm == KOL_LAY_FORM_PAD3)    Format(kolTabla, sizeof(kolTabla), "%s.000", g_sKolLayPrefix);
    else if (g_iKolLayForm == KOL_LAY_FORM_PLAIN)   Format(kolTabla, sizeof(kolTabla), "%s.0", g_sKolLayPrefix);
    else                                            Format(kolTabla, sizeof(kolTabla), "%s[]", g_sKolLayPrefix);

    char kolHost[PLATFORM_MAX_PATH];
    if (g_bKolDummyHost)
        strcopy(kolHost, sizeof(kolHost), "commentary_dummy");
    else if (g_iKolDummyFail > 0)
    {
        char kolRazon[96];
        Kolossos_DummyFailText(kolRazon, sizeof(kolRazon));
        Format(kolHost, sizeof(kolHost), "prop_dynamic_override — dummy cayo: %s", kolRazon);
    }
    else
        strcopy(kolHost, sizeof(kolHost), "prop_dynamic_override");

    PrintToConsole(client, "Capas: %s | host %s | %d slots | tabla %s",
                   "NO EXISTEN EN L4D2 (canal no networkado — la via es Fusion)",
                   kolHost,
                   g_iKolLayerSize,
                   kolTabla);
    // v1.6.1: la MATRIZ de descubrimiento del canal — que resolvio la
    // sonda en el host y en un player vivo (v1.7: el player SIEMPRE se
    // pruebea — el veredicto completo: host=no player=no = L4D2 no
    // networka capas para nadie)
    PrintToConsole(client, "CanalCapas: host %s | player %s",
                   g_sKolLayDiagDummy[0] != '\0' ? g_sKolLayDiagDummy : "sin sonda",
                   g_sKolLayDiagPlayer[0] != '\0' ? g_sKolLayDiagPlayer : "sin sonda");
    // v1.7: QUE .mdl corre de verdad el avatar (m_ModelName del host R)
    char kolMdl[96];
    int avDbg = EntRefToEntIndex(g_iKolAvatar[client]);
    if (avDbg > 0 && IsValidEntity(avDbg) && HasEntProp(avDbg, Prop_Data, "m_ModelName"))
        GetEntPropString(avDbg, Prop_Data, "m_ModelName", kolMdl, sizeof(kolMdl));
    else
        g_cvKolModel.GetString(kolMdl, sizeof(kolMdl));
    PrintToConsole(client, "Modelo avatar: %s", kolMdl);
    // v1.5: el estado de la FUSION — cuantas de las 15 compuestas del
    // .mdl recompilado trae el modelo (12 grab + 3 swing del pack
    // v1.5.3; 12/12 = fusion del grab operativa, 15/15 = + el M1 swing)
    // v1.7: LAS CAPAS NO EXISTEN EN L4D2 — la fusion es LA via
    int nFused = 0;
    for (int s = KOL_ST_HOLD_WALK; s <= KOL_ST_THROW_IDLE; s++)
        if (g_bKolFusedNative[s]) nFused++;
    int nSwing = 0;
    for (int s = KOL_ST_SWING_WALK; s <= KOL_ST_SWING_IDLE; s++)
        if (g_bKolFusedNative[s]) nSwing++;
    PrintToConsole(client, "Fusion: %s (%d/12 grab + %d/3 swing) | convar kolossos_grab_layers %d",
                   Kolossos_FusionActive() ? "ACTIVA — piernas y brazos en la misma seq"
                                           : (g_cvKolGrabLayers != null && g_cvKolGrabLayers.BoolValue
                                                ? "OFF — el .mdl no trae las compuestas (recompilar con el pack v1.5.3 COMPLETO)"
                                                : "OFF (convar en 0)"),
                   nFused, nSwing,
                   g_cvKolGrabLayers != null ? g_cvKolGrabLayers.IntValue : -1);
    // v2.0: el pegado es el PIN GMod — el doble cuelga de la MANO por
    // frame (Sonic_RagPhysPin: SetPosition + velocidad CERO, sin
    // SetParent), marker info_target al attachment grabhand + tilt
    PrintToConsole(client, "Victima: PIN GMod por frame (hueso raiz a la mano animada, cero SetParent) | tilt %.0f grados (kolossos_grab_tilt) | mano %s",
                   g_cvKolGrabTilt != null ? g_cvKolGrabTilt.FloatValue : -35.0,
                   (g_iKolHandMark[client] != 0 && EntRefToEntIndex(g_iKolHandMark[client]) > 0) ? "marker vivo" : "-");
    // v1.9: el estado de los sistemas nuevos
    int nRag = 0, nPin = 0, nFly = 0;
    for (int v = 1; v <= MaxClients; v++)
    {
        if (g_iKolVictRag[v] == 0) continue;
        if (g_iKolVictRagMode[v] == KOL_RAGMODE_FLIGHT) nFly++;
        else nPin++;
        nRag++;
    }
    PrintToConsole(client, "Ragdolls: %d activos (%d clavados / %d volando con follow) | grab_ragdoll %d | charge_carry %d | counter_ragdoll %d",
                   nRag, nPin, nFly,
                   g_cvKolGrabRag != null ? g_cvKolGrabRag.IntValue : -1,
                   g_cvKolChgCarry != null ? g_cvKolChgCarry.IntValue : -1,
                   g_cvKolCntRag != null ? g_cvKolCntRag.IntValue : -1);
    // v2.1: el estado de la witch colgada + la puerta del combo + la roca
    {
        int nWitch = 0;
        for (int w = 1; w <= MaxClients; w++)
            if (g_iKolWitchRag[w] != 0) nWitch++;
        PrintToConsole(client, "v2.1: witch colgada %d (doble pineado, JAMAS parentada) | puerta del combo %s (max %d punos, ritmo %.2fs) | punos %.0f + %.2f%% de la vida actual | roca: LANZA (vuelo recto %0.f u/s, stun-ragdoll %.1fs al impactar)",
                       nWitch,
                       (g_iKolGrabPunches[client] >= 0 && g_fKolGrabNextPunchAt[client] >= 0.0) ? "ACTIVA" : "ACTIVA",
                       g_cvKolGrabPunches != null ? g_cvKolGrabPunches.IntValue : 3,
                       KOL_PUNCH_GATE,
                       g_cvKolGrabPunchDmg != null ? g_cvKolGrabPunchDmg.FloatValue : 550.0,
                       g_cvKolGrabHpDmg != null ? g_cvKolGrabHpDmg.FloatValue : 0.0,
                       KOL_ROCK_SPEED,
                       KOL_CNT_STUN);
    }
    // v2.2: el modelo ACTIVO de la roca (la cadena) + el stun nativo +
    // los wavs de cada uno (que nunca mas haya misterio de "no sale")
    PrintToConsole(client, "v2.2: roca modelo %s (escala %.1f por m_flModelScale, colision solo-mundo) | stun NATIVO L4D2 (pounce/lengua/carry/pummel/jockey/stagger/knockdown) = anim stun + kol stun %d/4 wavs | M1: %d/4 wavs precacheados (cero not-precached)",
                   g_bKolRockModel ? g_sKolRockModel : "CADENA VACIA (dano directo)",
                   g_cvKolRockScale != null ? g_cvKolRockScale.FloatValue : 3.0,
                   g_iKolSndStunCount,
                   g_iKolSndM1Count);
    PrintToConsole(client, "M1: click izq %s (slots 0/1 pisados + ARMA CONGELADA m_flNextPrimaryAttack, granadas/botiquin intactos) | dano %.0f-%.0f (tirada aleatoria v2.1) | CD %.2fs | anim: serie swing fusionada (fallback punch)",
                   (g_cvKolM1 != null && g_cvKolM1.BoolValue) ? "PUO basico" : "OFF (kolossos_m1 0)",
                   g_cvKolM1Dmg != null ? g_cvKolM1Dmg.FloatValue : 350.0,
                   g_cvKolM1DmgMax != null ? g_cvKolM1DmgMax.FloatValue : 450.0,
                   KOL_M1_CD);
    PrintToConsole(client, "Counter: especiales/habilidades SI (commons/witch NO cuentan) | melee <300u = ragdoll stun %.1fs | roca: dano %.0f + stun %.1fs",
                   KOL_CNT_STUN,
                   g_cvKolRockDmg != null ? g_cvKolRockDmg.FloatValue : 75.0,
                   g_cvKolRockStun != null ? g_cvKolRockStun.FloatValue : 1.0);
    // v1.3: la serie del grab — duraciones medidas + lanzamiento pendiente
    PrintToConsole(client, "GrabSerie: reach %.2fs | punch %.2fs | throw %.2fs (0 = fallback QC 60fps) | lanzar en %.1fs",
                   g_fKolSeqDur[KOL_ST_GRABREACH], g_fKolSeqDur[KOL_ST_GRABPUNCH],
                   g_fKolSeqDur[KOL_ST_GRABTHROW],
                   g_fKolGrabThrowAt[client] > 0.0 ? g_fKolGrabThrowAt[client] - now : 0.0);
    PrintToChat(client, "\x04[Kolossos]\x01 Estado en consola (sm_kolossos).");
    return Plugin_Handled;
}
