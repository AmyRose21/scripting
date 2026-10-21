/*
 * ======================================================
 *  [MODULO] Amy Rose Ability - v106 "EL VUELO REAL DEL IMPACTO (lanzamiento VI)"
 *
 *  v106-OM (suite 3.77.58 — reporte del owner 2026-10-13: "el empuje
 *  del martillo aún sigue siendo = la fuerza no lanza al oponente...
 *  el enemigo no sale volando hacia atras ni tampoco pareciera
 *  reaccionar como debería cuando el martillo le pega estando
 *  inmovil"). AUTOPSIA del v105 — el impulso se moria por DOS caminos
 *  independientes, ahora ambos cerrados:
 *   A) COMUNES: el v105 hacia TakeDamage(500) + TeleportEntity(vel) —
 *      pero el común MUERE con el golpe y el ragdoll de muerte de un
 *      común de L4D2 es DEL LADO CLIENTE: la velocidad que el server
 *      le escribe a un cuerpo ya muerto NO la hereda nadie (el común
 *      se desploma normal = "no reacciona"). La receta que SI vuela
 *      comunes en este server es la del BARRIDO DE ROUGE v10.4 (la
 *      referencia que el owner ya ve funcionar a diario): copia
 *      prop_ragdoll del cuerpo LANZADA con el impulso direccional +
 *      BecomeRagdoll en el común real + limpieza de la copia a los
 *      ROUGE_FLING segundos. Ahora el martillo usa ESA receta con las
 *      reglas GMod de dirección (amyom_throw_fling 550 + elevación
 *      0.55x, los números del Barrido). Si el común SOBREVIVE al dano
 *      (mutaciones con HP boost): empujon plano como el barrido de
 *      la bola.
 *   B) ESPECIALES/TANK/WITCH: el impacto se procesaba INLINE dentro
 *      del callback del SDKHook_Touch del prop — ese callback corre
 *      DENTRO de la simulación vphysics del martillo, y ahi el
 *      spawn+wake+launch del ragdoll falso nunca despega (la misma
 *      razón por la que NINGUNA habilidad del suite lanza ragdolls
 *      desde un touch físico: el spindash lanza desde su think, el
 *      Barrido desde su dash, el ritual witch desde el timer). FIX:
 *      el Touch solo ENCOLA la victima (Amy_OM_HammerHitQueue) y un
 *      RequestFrame la procesa el frame SIGUIENTE, fuera de la
 *      simulación — el MISMO contexto de timer que el spindash. El
 *      scan 30 Hz (que ya corria en timer) sigue igual y comparte la
 *      misma lista de blandos.
 *   C) DANO FUERA DEL STUN (Rouge order): el dano a especiales ya NO
 *      va dentro de OM_Stun — primero TakeDamage, y SOLO si el
 *      objetivo SOBREVIVE entra el stun + ragdoll falso (si OM_Stun
 *      lo matara por dentro, el watcher del stun mataría el doble a
 *      los 0.1s = vuelo invisible). Si el dano LO MATA: copia
 *      Rouge volada igual que los comunes (el cadaver real queda
 *      limpio, el doble sale volando). Iframes del OM_Stun: solo
 *      resisten el stun, el martillo siempre paga el dano.
 *
 *  v105-OM (suite 3.77.57 — pedido del owner 2026-10-13): "es hora de
 *  modificar el ataque de martillo... (o sea el lanzamiento no el golpe
 *  de defensa)". TRES fixes al LANZAMIENTO (tecla V):
 *   1) IMPULSO DIRECCIONAL GMOD (el "tratamiento del spindash" que el
 *      martillo NO tenía): los COMUNES golpeados ahora SALen VOLANDO —
 *      dano + velocidad (la receta probada del barrido de la bola: el
 *      ragdoll de muerte hereda la velocidad del cuerpo). La DIRECCION
 *      depende de donde recibe el golpe, como el lua del GMod:
 *      pega desde abajo -> sale hacia ARRIBA; desde arriba -> sale
 *      EMPUJADA HACIA ABAJO; y si la victima YA ESTA EN EL SUELO ->
 *      DIRECCION CONTRARIA (la Z se niega: rebota) + impulso que la
 *      ELEVA. Especiales/tank/witch heredan las MISMAS reglas en su
 *      ragdoll falso (antes: rumbo plano del martillo sin reglas).
 *      Convar amyom_throw_fling (550 u/s).
 *   2) SIN DANO DE COLISION FÍSICA VANILLA AL EQUIPO (pedido: "el
 *      dano de colisión amy se dano cuando lanza el martillo en si"):
 *      3 cinturones — (a) m_impactEnergyScale 0.0 al nacer (el campo
 *      REAL del physdamagescale; el KV no siempre pega en el
 *      prop_physics_override), (b) el hook anti-FF v82 (PROPS AMIGOS)
 *      reconoce el prop del martillo: crash damage a CUALQUIER
 *      survivor (incluida Amy) = BLOQUEADO, (c) el Touch de juego
 *      contra survivors devuelve Handled (el vphysics resuelve el
 *      rebote físico igual). Los infectados siguen pagando el golpe
 *      de juego (500 comunes / stun+ragdoll especiales) como siempre.
 *   3) FÍSICA DINÁMICA DE VERDAD (pedido: "el martillo esta siempre
 *      tieso... hasta un auto cuando le pega el tank este puede girar,
 *      rota en el aire"): el giro YA NO se escribe al datamap
 *      m_angVelocity (el vphysics lo sobreescribe cada tick — la
 *      misma lección del doble v6.9): va DIRECTO al IPhysicsObject
 *      con el SDKCall del motor v6.33 (wrapper público nuevo
 *      Sonic_PhysSetVel de sonic.inc v6.34) — CARTWHEEL alrededor del
 *      eje derecho del rumbo (gira de cabeza, como un objeto real
 *      lanzado) + WOBBLE random en los otros 2 ejes (el tumble
 *      organico del coche del tank). Un impulso 1 vez y el motor se
 *      encarga del resto (filosofia GMod literal). Convar
 *      amyom_throw_spin (700 deg/s). Plan B: TeleportEntity-vel + el
 *      m_angVelocity viejo (si el SDKCall no esta disponible).
 *
 *  v104-OM (suite 3.77.44): entrada PROPIA de parry en el VScript
 *  (ver AMY_INC_VERSION abajo).
 *
 *  v102 "PARRY DELEGADO DE AMY (pose de defensa)"
 *
 *  v102-OM (suite 3.77.38 — pedido del owner 2026-10-10): "Amy usara el
 *  mismo sistema de parry pero usara un CONTADOR APARTE, al igual que
 *  pasa con Knuckles; solo que la diferencia es que si el proyectil
 *  está en rango activara la DEFENSA DE MARTILLO (el ataque más el
 *  aura). Si Amy no está en pose de defensa (ya uso su ataque, sea en
 *  parry o como uso normal) el contador la cuenta como NO parryeando;
 *  si usa su habilidad vuelve a activarse el parry (defensa activa =
 *  parry activo; deja de estar en defensa = parry desactivado)".
 *   - FLANCO DE SUBIDA/BAJADA en Amy_OM_PhaseThink: la ventana de
 *     defensa (g_fAmyOMCounterUntil) abre/cierra la ventana de parry
 *     de Amy en el chch_parrying.nut vía SU entrada ChCh_AmyNotify
 *     (v104: entrada propia de Amy — SU contador por entidx, el de
 *     Knuckles no se toca).
 *   - PUENTE INVERSO amyparry_strike <entidx> (RegServerCmd): el .nut
 *     lo manda por SendToServerConsole cuando un PROYECTIL entra al
 *     rango de su ventana -> Amy_OM_CounterTriggerProp = consume la
 *     pose + suelta el ATAQUE (barrido 360) + el AURA. La consumición
 *     de la ventana cierra el parry en el siguiente flanco de bajada.
 *
 *  v91 "FIX CINEMÁTICAS (clones del aura)"
 *
 *  v91 - FIX CINEMÁTICAS (pedido del owner: "hay algo en mi plugin
 *  que rompe quizás las cinemáticas de las campañas... cuando hay un
 *  objeto movible creo que se intercambia o no se que carajos pasa,
 *  el punto es que la cinemática se rompe"). FORENSE COMPLETO:
 *   1) LA CONVERSION ESTA DESCARTADA: Amy_ConvertToPhysics (v81,
 *      decorativo -> prop_physics_override) tiene UN solo llamador:
 *      el comando MANUAL sm_amyfisica (v82: la conversión AUTOMÁTICA
 *      se RETIRO hace 9 versiones — "EL MAPA MANDA"). Cero paths
 *      automáticos: verificado llamador por llamador.
 *   2) EL CULPABLE ERA EL AURA (v88/v89): el escaner spawnea CLONES
 *      (prop_dynamic_override, mismo modelo y posición EXACTA que el
 *      original) parentados a los props con V cerca de Amy/Sage. Ese
 *      clon nacia SOLIDO (malla de colisión del modelo: los autos/
 *      montacargas la tienen) — dos solidos superpuestos al palmo.
 *      Mientras el objeto duerme no pasa nada; pero cuando la
 *      CINEMÁTICA de campaña lanza/anima el objeto (o cualquier
 *      evento de física lo despierta), el solver de vphysics resuelve
 *      la penetración contra su propio clon invisible: el objeto
 *      SALE DISPARADO del sitio o tiembla violentamente = el "se
 *      intercambia o no se que pasa" = escena rota. Calza 100% con el
 *      reporte: SOLO en escenas CON objeto movible (sin V no hay
 *      clon rojo, y los VERDES nunca se lanzan porque nadie los
 *      convirtio).
 *   FIX DOBLE:
 *    a) SOLID_NONE en el clon al nacer (+ collision group NONE):
 *       el clon es 100% visual, solo existe el glow. Adios conflicto
 *       físico PARA SIEMPRE (también en mitad de partida).
 *    b) ESCANER APAGADO DURANTE EL INTRO (L4D_IsInIntro de
 *       left4dhooks, con guard de feature): durante la cinemática de
 *       campaña no se spawnea ni se mantiene NINGÚN clon (los intros
 *       son la escena más fragil del juego; cero entidades nuevas
 *       de nuestra cosecha en el medio). El timer sigue vivo: al
 *       acabar la intro el próximo tick re-encienda las auras solo.
 *
 *  v90 - HABILIDAD 3 = CAMBIO DE MODO (ronda 27, pedido del owner):
 *  "el comando de amy especial para cambiar pasara a ser su habilidad
 *  3 direcrtamente (obiamente no tendrá cd si no no tendría sentido
 *  si quiere camiar de modo salto o modo área)". El manager v3.61
 *  rutea la tecla C (sm_sjs_ability3) directamente al cambio de modo
 *  de Amy: Z IMPULSO (embestida) <-> Z GOLPE AOE (martillo 360).
 *  SIN cooldown a propósito: es una PREFERENCIA, no un ataque
 *  (cambiar de modo cuantas veces quiera, incluso entre embestidas:
 *  no cancela ninguna en curso, solo decide que hace el PRÓXIMO Z).
 *  sm_amymodo / sm_amymode siguen como alias directos (binds viejos
 *  intactos); el camino oficial es la C. Sage mantiene su propia 3a
 *  (cambio de set) y el resto del elenco sigue con 2 habilidades.
 *  SOLO textos/comentarios/versión: cero lógica de nucleo tocada.
 *
 *  v89 - AURA PRIVADA + SAGE (ronda 26, pedido del owner): "1 que todo
 *  el radio de detección de objetos reducira a 700. 2 Esto solo la
 *  puede notar amy (o sage ya que en si crearemos ahora la clase
 *  sage)". El aura pasa a vivir en un CLON invisible del objeto (mismo
 *  modelo, cuerpo TRANSTEXTURE alpha 1, glow propio) PARENTEADO al
 *  original y filtrado con SDKHook_SetTransmit: SOLO los clientes
 *  Amy/Sage reciben el clon -> solo ELLAS ven el contorno VERDE/ROJO
 *  (nadie más nota nada; el objeto REAL queda VIRGEN: sin originales
 *  que restaurar, matar el clon apaga el aura). RADIO 1000 -> 700
 *  (amy_vision_radius). El escaner vive mientras haya una Amy o SAGE
 *  viva. Y el set prestado: la Z y el TAROT aceptan también a SAGE (la
 *  Z de Sage es GOLPE EN ÁREA FIJO: "únicamente el golpe en área de
 *  martillo y no el impulso"; sm_amymodo se lo explica si lo intenta).
 *  Los lanzamientos de Sage mantienen la protección anti-FF (el
 *  tracker de props atribuye "AMY" a cualquier lanzador del kit). El
 *  vscript del martillo (::SonicSageIdx) y Cream v6 van aparte.
 *  v88 - AURA LUMINOSA (ronda 25, pedido del owner): "No me referia
 *  a que la textura tubiera que cambiar de color. Me refiero a que
 *  sea rodeada por Un aura luminosa... (así como cuando vez un
 *  objetivo que se ve de color azul? o los compañeros en campañas
 *  no realistas? así mismo)". El tinte de RENDER de la v86/v87 se
 *  RETIRA: la textura del objeto JAMÁS se toca. En su lugar, el GLOW
 *  DEL MOTOR de L4D2 — el MISMO sistema que dibuja el outline AZUL
 *  de los objetivos de mapa y el outline de los compis en campañas
 *  no realistas:
 *   - m_iGlowType = 3 (SOLIDO, constante: como un objetivo).
 *   - m_glowColorOverride = VERDE (inyectable) / ROJO (empujable).
 *     Colores PUROS (0,255,0 y 255,0,0): brillan igual bajo
 *     cualquier packing de color del motor.
 *   - m_nGlowRange = el radio de visión (1000): el aura se dibuja
 *     ALREDEDOR del modelo y ATRAVIESA paredes dentro del rango.
 *   - El glow ORIGINAL se guarda x5 (type/color/range/rangeMin/team)
 *     y se restaura EXACTO al salir del radio, morir o cerrar ronda.
 *   - Entidades con glow PROPIO del mapa (objetivos, items con glow)
 *     NO se tocan: no se pisa el trabajo del level designer.
 *   - m_iGlowType vive en el send table o solo en el datamap (según
 *     la rama del engine): resolución doble (send al arranque +
 *     datamap perezoso con la entidad en la mano). Sin glow en el
 *     mod: visión inerte, JAMÁS error.
 *  Todo lo demas de la v87 queda igual: automática (sin comandos),
 *  radio 1000, slots 128, escaner que se apaga sin Amys vivas.
 *  v87 - OJOS AUTOMÁTICOS (ronda 24, pedido del owner): "no puedes
 *  colocarla que sea áutomaticamente? xq todo debe ser de activación?
 *  lo que este a un rango de 1000 de amy se vera. y punto listo".
 *  La visión VERDE/ROJO de la v86 se vuelve 100% AUTOMÁTICA:
 *   - NADA que activar: los comandos sm_amyvision / sm_amyojos y el
 *     flag por-jugador "ojos cerrados" (g_bAmyVisOff) RETIRADOS. Mientras
 *     una Amy viva exista, el escaner está encendido: el tinte entra
 *     y sale solo con la distancia, sin comandos, binds ni recuerdos.
 *   - RADIO por defecto 700 -> 1000 (amy_vision_radius): "lo que este
 *     a un rango de 1000 de Amy se vera".
 *   - Slots del registro 96 -> 128: con 1000 unidades entran más
 *     props a la vez (si aún se llena, el objeto queda sin tinte —
 *     degradación silenciosa, JAMÁS error).
 *   - amy_vision (default 1 = encendida) queda como ÚNICO master
 *     switch de ADMIN del servidor (config, no activación jugable).
 *     La pista del spawn pasa a ser informativa de colores, 1 vez por
 *     sesión, sin mencionar ningún comando.
 *  El nucleo del tinte (offsets byte a byte, restauro EXACTO, RENDER_
 *  NONE intocable, timer NO_MAPCHANGE que se apaga sin Amy viva) es
 *  el mismo v86: solo desaparece la capa de activación. (v88: el
 *  tinte m_clrRender fue REEMPLAZADO por el AURA glow — ver v88).
 *  v86 - OJOS DE AMY (visión de objetos, petición del owner): "Amy
 *  podrá ver que objetos son inyectables (apareceran resaltados en
 *  color verde) y estaran en color rojo los que pueden ser empujados
 *  (con V)". El tinte es el COLOR DE RENDER del modelo (m_clrRender,
 *  escrito byte a byte con offsets de CBaseEntity: cero nativas que
 *  puedan lanzar ThrowError):
 *   - VERDE = INYECTABLE: decorativo SIN física al que sm_amyfisica
 *     le puede INYECTAR un cuerpo físico (prop_dynamic de vehiculo,
 *     montacargas o dumpster — receta v79: árboles/vallas no
 *     interesan). Al inyectarle la física el decorativo muere y nace
 *     uno NUEVO con V: al siguiente tick el escaner lo pasa a ROJO —
 *     el ciclo verde -> inyectar -> rojo -> martillo se ve SOLO.
 *   - ROJO = EMPUJABLE: objeto con V (VPHYSICS) incorporado de
 *     fábrica — el martillo (Z) y la embestida lo empujan tal cual
 *     (la piedra del tank, redirigible, también).
 *  El color ORIGINAL se guarda byte a byte al teñir y se restaura
 *  EXACTO al salir del radio (AMY_VISION_STALE), morir el objeto o
 *  cerrar la ronda. Registro estático de 96 slots + UN timer global
 *  NO_MAPCHANGE (0.6s) que vive mientras alguna Amy mire: sin nadie
 *  mirando, restaura todo y se apaga solo (cero handles colgando).
 *  (v87: el toggle sm_amyvision fue RETIRADO — la visión es
 *  automática; convars: amy_vision (1) y amy_vision_radius (1000)).
 *  Defensas: entidades invisibles A PROPÓSITO (RENDER_NONE) no se
 *  tocan; el registro lleno no da error (el objeto queda sin tinte);
 *  sin offsets en el mod la visión queda inerte sin romper NADA.
 *  El nucleo del martillo/embestida/props v73-v85 queda INTACTO: es
 *  una capa de VISUAL pura encima.
 *  v85 - EL EMPUJE COMPLETO (ronda 22, REVERTIDA la reducción): el
 *  owner reexplico el pedido de la ronda 21 — "reverti todo lo que
 *  hiciste; lo ÚNICO que dije es: (1) que no tenga empujones
 *  adicionales, o sea 0, solo será el EMPUJE PRINCIPAL, y (2) que el
 *  empuje de autos y cosas sea COMPATIBLE con el deslizamiento (la
 *  habilidad alternativa)". La v84 había reducido fuerza/radios/
 *  volteo de la embestida: TODO revertido. El objeto embestido sale
 *  otra vez con la MISMA receta completa del martillo:
 *   - FUERZA completa amy_proplaunch_force (700): el convar
 *     amy_propdash_scale queda RETIRADO (no hay fuerza reducida).
 *   - Despertador nativo: radio 130-300 (como el martillo; magnitud
 *     masa-escalada intacta) y metralla de comunes radio 80.
 *   - Volteo lleno (+-400) y pisito de arco 150 (AMY_PROPLAUNCH_MINUP).
 *  La ÚNICA regla propia de la embestida (el pedido de verdad): el
 *  objeto EMPUJADO recibe 0 RE-IMPULSOS — un solo empuje, sin
 *  empujones adicionales (el martillo Z conserva su único rebote de
 *  la R20). NINGÚN radio/área de ninguna habilidad se toca en esta
 *  ronda (todos los radios de Amy quedan exactamente como estaban).
 *  v83 - LA MIRA MANDA + REBOTE ÚNICO (ronda 20, 3 pedidos):
 *   1) PROTECCION COMPLETA DURANTE LOS REBOTES (bug del owner: "el
 *      auto aún me lastima a MI durante los rebotes"). DOS hoyos
 *      reales: (a) el slot del tracker moria a los 4s de vuelo o
 *      cuando la velocidad HORIZONTAL caía bajo 60 — un auto
 *      rebotando en VERTICAL leia spd=0 y quedaba DESPROTEGIDO en
 *      pleno rebote; (b) la red B volteaba el lanzador a TANK por
 *      un m_hPhysicsAttacker VIEJO (un punetazo del tank ANTERIOR
 *      al lanzamiento desarmaba la protección para siempre). FIX
 *      TRIPLE: CUSTODIA de 8s tras el vuelo (filtro anti-dano +
 *      redes de atribución vivos hasta el final del rebote) +
 *      velocidad 3D + red B con FRESCURA (el golpe del tank solo
 *      cuenta si es POSTERIOR al lanzamiento de Amy).
 *   2) UN SOLO REBOTE: re-impulsos 5 -> 1 ("ya no tiene que rebotar
 *      tantas veces").
 *   3) LA MIRA MANDA (como el tank en VS): el objeto quieto sale
 *      hacia donde APUNTA Amy — DIRECCION y ALTURA de la mira
 *      (arriba = arco alto de verdad; recto = raso con pisito de
 *      arco 150; abajo = rasante). NOTA del owner confirmada: el
 *      dano del auto lo produce el MOTOR (aplastamiento/choque de
 *      objetos) — el filtro lo intercepta en la victima y ahora
 *      cubre TODOS los rebotes.
 *  v82 - TRES REGLAS DEL OWNER:
 *   1) EL MAPA MANDA: FUERA la conversión AUTOMÁTICA de
 *      decorativos (v79) — el bus que hace de ESCALERA en The
 *      Parish "simplemente desaparecía" al transformarse. El
 *      martillo/la embestida SOLO mueven objetos con V (VPHYSICS)
 *      incorporado de fábrica; la física se inyecta A MANO: mira
 *      el objeto y escribe sm_amyfisica [masa] (v81). Todo lo
 *      demas queda COMO ANTES, exacto como lo puso el mapa.
 *   2) PROPS AMIGOS: los objetos que LANZA Amy ya no lastiman a
 *      los survivors NI a ella misma (filtro en el OnTakeDamage de
 *      la victima, siempre activo). OJO: protege SOLO el golpe de
 *      Amy — si el TANK golpea el objeto (aunque Amy le haya
 *      pegado antes), el dano a survivors VUELVE. Atribución por 3
 *      redes: el dano que RECIBE el prop, m_hPhysicsAttacker y el
 *      atacante de la victima.
 *   3) METRALLA DE COMUNES: los objetos de Amy barren la horda a
 *      su paso (el motor NO les aplica dano de aplastamiento — el
 *      monitor los ve y los golpea: oneshot 500, cooldown 0.5s por
 *      común, empujon incluido).
 *
 *  v80 - EL MURO FANTASMA (los autos del puente). Evidencia del
 *  owner en c5m5: el auto (prop_physics cara_84sedan) sale "EN
 *  RADIO pero muro de por medio" y la Z NO lo mueve... hasta que
 *  el TANK le da el primer golpe: desde ahi la Z SI lo mueve
 *  siempre. Traducción: el muro NO existe — el rayo LOS se
 *  chocaba contra algo que no es pared (vecino apiñado en fila,
 *  borda, rasante) o apuntaba demasiado bajo (origen+40 = altura
 *  del capo). El golpe del tank desplaza el auto a terreno limpio
 *  y ahi el rayo SI llega. TRES cosas:
 *   1) FILTRO v80 — UN PROP NO ES UN MURO: el rayo atraviesa
 *      cualquier prop_* (salvo puertas), func_physbox y cuerpos
 *      VPHYSICS. Solo el mundo y solidos de verdad descartan. (v77
 *      ignoro al OBJETIVO; v80 ignora TAMBIÉN a los VECINOS: en el
 *      puente los autos van en filas y el de atras tenía "muro".)
 *   2) MUESTREO A 2 ALTURAS: se traza al origen+40 Y al origen+72
 *      (el techo del auto asoma sobre capos/bordas/vecinos bajos).
 *      Si cualquiera de los 2 llega, hay línea de visión.
 *   3) DIAGNOSTICO: si aún falla, el log nombra al CULPABLE:
 *      "[PROPS v80] prop N RECHAZADO: bloquea ent=X cls=Y" (o
 *      "bloquea el MUNDO"). Adios adivinar.
 *  EXTRA: sm_amypropinfo y el mensaje del martillo reportan la
 *  misma masa (L4D2 da m_iMass=0 en muchos hittables: ambos usan
 *  el fallback 100 — se acabo la confusión "0 antes / 100 después").
 *
 *  v79 - TODOS LOS AUTOS (la conversión). Reporte del owner tras R15:
 *  "puedo mover las montacargas, las bolsas, los cauchos, muchos
 *  props, menos los autos todavia". Conclusión de la evidencia: la
 *  física R11-R15 FUNCIONA (montacargas, bolsas y cauchos SON
 *  prop_physics y vuelan) — los autos que no se mueven SON OTRA
 *  COSA: MUCHOS autos de mapa NO son prop_physics sino DECORACION
 *  prop_dynamic (sin cuerpo físico: jamás se moverian, ni con
 *  despertador, ni insistiendo). TRES frentes:
 *   1) LA CONVERSION (la estrella): el auto "pintado" (prop_dynamic
 *      de vehiculo, sin padre/targetname) se RE-SPAWNEA al instante
 *      como prop_physics con el mismo modelo/posición/angulo/skin —
 *      cuerpo NUEVO = DESPIERTO de fábrica: el TeleportEntity SI
 *      aplica, sin guerra contra el sueño vphysics. Mismo modelo,
 *      mismo sitio, ahora con física de verdad.
 *   2) ESCANEO AGNOSTICO (4c + embestida): además de las 5 clases,
 *      el martillo ve CUALQUIER "prop_*" con movetype VPHYSICS
 *      (classname raro ya no es invisible) y los autos decorativos
 *      convertibles. Amy_IsLaunchableProp idem.
 *   3) DESPERTADOR ESCALADO POR MASA: magnitude FIJA 300 = bolso de
 *      20 kg despedido y auto de 1500 kg ni enterado (misma fuerza,
 *      masa 75x). Ahora magnitude = base x (masa/100), nunca menor
 *      que la base, tope 25000: el auto recibe el mismo empujon
 *      físico que el bolso.
 *  EXTRA: sm_amypropinfo — apunta al auto y dice QUE es de verdad
 *  (clase/modelo/movetype/masa + veredicto: física real / decorativo
 *  convertible / geometria del mapa). Se acabo adivinar.
 *
 *  v78 - LA EMBESTIDA DEL CHARGER (fix del modo por DEFECTO). Reporte
 *  del owner tras R14: "el ataque no despierta ni mueve los autos (no
 *  sale tampoco el mensaje que intentara mover el prop)". NUEVA causa
 *  raíz (la que explicaba el reporte COMPLETO): el modo por defecto de
 *  Amy es IMPULSO/EMBESTIDA (g_iAmyAbilityMode=0) y TODO el código de
 *  props vivía SOLO en el modo martillo/AOE (sm_amymodo aoe). Probando
 *  con el defecto, el press embiste... y Amy_ImpulseWallAhead
 *  consideraba "pared" cualquier entidad solida (hitEnt > 0): la
 *  embestida MORIA contra el auto SIN tocarlo. Cero launch, cero
 *  mensaje, el auto ni se enteraba de que existía Amy.
 *  FIX (la receta del charger del owner, l4d2_charger_power): lo que
 *  hay delante ahora se CLASIFICA. Un prop con física = ARMA: se
 *  REVENTA con la receta completa del martillo (despertador nativo +
 *  golpe real + aventon + volteo + monitor) y la embestida ATRAVIESA;
 *  puerta / prop estático / muro = pared (fin, como siempre). 1 golpe
 *  por objeto por embestida (registro del impulso). Extras:
 *  func_physbox en las clases lanzables + diagnostico visible
 *  (amy_propdebug, 1 por defecto): pista de modo 1 vez por sesión al
 *  embestir + "0 objetos con física en radio" en el primer tick del
 *  AOE (adios a adivinar que vio el escaneo). Tunables intactos.
 *
 *  v77 - EL MURO INVISIBLE (fix del escaneo de props). Reporte del
 *  owner tras R13: "el ataque no despierta ni mueve los autos (no
 *  sale tampoco el mensaje que intentara mover el prop)". CAUSA RAÍZ
 *  DEFINITIVA, presente desde que el martillo toca props (v73): el
 *  chequeo anti-muro del barrido (Amy_HasLineOfSight) usa un filtro
 *  donde TODO prop es solido ("props, puertas y demas solidos del
 *  mapa") — y el rayo va de los ojos de Amy al origen DEL PROPIO
 *  OBJETIVO: el AUTO SE BLOQUEA A SI MISMO (TR_DidHit = true ->
 *  continue). Amy_LaunchMapProp NUNCA se ejecuta: ni inputs (R11),
 *  ni golpe real (R12), ni despertador nativo (R13): TODO el work
 *  físico era correcto pero INALCANZABLE — el descarte ocurre en el
 *  ESCANEO, antes de todo. Por eso tampoco salia el mensaje de chat.
 *  La PIEDRA del tank (4a) sufre el mismo auto-bloqueo: la
 *  redirección jamás pudo disparar. FIX: filtro nuevo
 *  Amy_TraceFilter_PropLOS + helper Amy_HasLineOfSightToProp — el
 *  rayo ATRAVIESA al objetivo mismo (y a las piedras en vuelo); el
 *  mundo, puertas y OTROS props siguen bloqueando (= solo un muro
 *  REAL de por medio descarta). 4a y 4b migradas + log nuevo de
 *  "en radio pero muro de por medio". Tunables intactos (blast /
 *  wake / launch / redirect). El ataque SIEMPRE estuvo diseñado
 *  para los props golpeables (v73); ahora el camino hasta ellos
 *  existe de verdad.
 *
 *  v76 - EL DESPERTADOR NATIVO (env_physexplosion). Reporte del owner
 *  tras R12: "no está funcionando... el comando no está haciendo nada
 *  de nada". Auditoria del R12: el .smx del paquete esta verificado
 *  byte a byte (= build, 0 errores, baseline de warnings intacto) — no
 *  quedó nada roto. Dos causas reales:
 *   1) TÉCNICA: el "golpe real" de v75 confiaba en la fuerza del dano,
 *      pero la doc oficial de SDKHooks advierte: "Force application is
 *      dependent on game and damage type(s)" — el motor L4D2 puede
 *      IGNORAR la fuerza de un DMG_CLUB: golpe sin efecto físico = el
 *      auto dormido sigue dormido = "no hace nada".
 *   2) DE PROCESO: el changelog R12 decía "cambiar de mapa o reiniciar
 *      el servidor" — PERO CAMBIAR DE MAPA NO RECARGA EL .SMX: el
 *      plugin vive en memoria mientras el server corra. Solo
 *      "sm plugins reload Sonic_ability_manager" o reinicio completo
 *      cargan el binario nuevo (puede que R12 nunca llego a correr).
 *  EL FIX DEFINITIVO: Amy_PropBlastWake — env_physexplosion sobre el
 *  objeto golpeado, EXACTAMENTE la receta del plugin de autos
 *  explosivos que ya corre en este server (l4d_explosive_cars:
 *  magnitude 300, radius): el motor aplica la fuerza de explosión
 *  DIRECTO al cuerpo vphysics (despierta al dormido — por eso un
 *  barril dormido vuela con una explosión). Centro DETRÁS-DEBAJO del
 *  objeto: el empuje radial sale hacia delante+arriba ("levantarlo del
 *  suelo y luego aventarlo", la receta del tank). El re-impulso del
 *  monitor repite la receta completa. El dano canonico (alarma) se
 *  mantiene. Feedback visible en chat + sonda de versión sm_sjsver.
 *  Tunable: amy_propwake_blast (300.0; 0 = desactivado).
 *  v75:
 *  v75 - EL GOLPE REAL (dano con fuerza = la receta del punetazo del
 *  tank). Reporte del owner tras R11: "no, aún sigue sin despertar a
 *  los autos: literalmente si el tank no lo golpea el objeto no
 *  despierta en si". Referencia aportada por el owner:
 *  l4d2_charger_power.sp (DJ_WEST) — el charger mueve coches con un
 *  simple TeleportEntity 500 PERO SOLO tras embestirlos FISICAMENTE:
 *  el contacto físico es el evento que despierta al cuerpo vphysics.
 *  Conclusión técnica: EnableMotion/EnablePhysics/Wake solo tocan
 *  banderas del ENT; la velocidad del TeleportEntity vive en
 *  m_vecVelocity y el cuerpo vphysics la IGNORA mientras duerme. El
 *  ÚNICO camino que empuja el cuerpo físico de verdad es el DANO CON
 *  FUERZA (lo que hace el punetazo del tank): el motor aplica esa
 *  fuerza al objeto vphysics (ApplyForceOffset) y eso DESPIERTA al
 *  dormido. Cambios:
 *   - Amy_PropRealHit (nuevo): SDKHooks_TakeDamage al prop con fuerza
 *     ESCALADA POR MASA (amy_propwake_force 200 u/s de empujon físico
 *     para CUALQUIER objeto, auto o barril) + dano amy_propwake_dmg
 *     (10; 0 = golpe desactivado y el auto dormido vuelve a no
 *     despegar). Canon L4D2: golpear un auto con alarma la ACTIVA
 *     (exactamente como el punetazo del tank).
 *   - Amy_LaunchMapProp (rama quieto): GOLPE REAL antes del aventon
 *     (despierta el cuerpo) y TeleportEntity después (sobre el cuerpo
 *     ya despierto: 700 + arco 400 + volteo, probado en vivo).
 *   - Monitor: el re-impulso dispara por velocidad O por
 *     DESPLAZAMIENTO REAL (m_vecVelocity puede MENTIR: retiene el 700
 *     del teleport mientras el cuerpo duerme quieto — la velocidad
 *     sola no era confiable como detector) y cada re-impulso repite
 *     el GOLPE REAL completo (dano + fuerza, no solo inputs).
 *   - BUG LATENTE R11 corregido: el re-impulso v74 escribía el volteo
 *     en "m_angAngularVelocity" (propiedad INEXISTENTE: la válida es
 *     "m_angVelocity") — si el re-impulso llegaba a disparar, error
 *     de runtime. Corregido a "m_angVelocity".
 *  Tunables: amy_propwake_force / amy_propwake_dmg (convars en vivo) +
 *  AMY_PROP_STALL_DIST (define). La EMBESTIDA (modo 0) INTACTA.
 *
 *  v74 - DESPERTAR DEL MOTOR (fix del Auto estacionado): el owner
 *  descubrio el patron en vivo: "cuando el auto está en el aire el
 *  impacto es repelido o sea lanzado a otra parte pero si trato de mover
 *  el auto como tal no pasa nada... el objeto debe estar en el aire
 *  para que se mueva o la fricción del motor no lo deja moverse".
 *  Causa raíz: un prop QUIETO (Auto estacionado) tiene su cuerpo físico
 *  DORMIDO (vphysics sleep) y el motor DESCARTA la velocidad del
 *  TeleportEntity sobre un cuerpo dormido; el punetazo del tank
 *  funciona porque su dano DESPIERTA la física y la LEVANTA antes de
 *  aventarla (por eso el auto volcado o en el aire SI reaccionaba).
 *  Fix de 3 capas (Amy_LaunchMapProp + T_AmyPropTick):
 *   - CAPA 1 (input): EnableMotion + EnablePhysics + WAKE antes de
 *     teleportar la velocidad. "Wake" es EL input que faltaba: es el
 *     único que saca al cuerpo físico del sueño (EnableMotion solo
 *     descongela props congelados por el mapa).
 *   - CAPA 2 (persistencia): la velocidad objetivo queda guardada en el
 *     slot del tracker (g_vecAmyPropVel) para poder re-aplicarla.
 *   - CAPA 3 (insistencia "tank"): el monitor de 10 Hz re-despierta y
 *     re-aplica el impulso hasta 5 veces (0.5s) si el objeto no alcanzo
 *     el 60% de la velocidad objetivo (fricción del suelo o re-sueño):
 *     "levantarlo del suelo y luego aventarlo", igual que el tank. La
 *     piedra del tank NO se re-impulsa (proyectil siempre despierto).
 *   - Tunables: AMY_PROP_REBOOSTS (5 intentos), AMY_PROP_REBOOST_RATIO
 *     (0.6 de la meta). Convars intactos. La EMBESTIDA (modo 0) queda
 *     INTACTA (su física R8/R9).
 *
 *  v73 - MARTILLO PESADO: los golpes de martillo (modo AOE de la tecla
 *  Z, "GOLPE PIKO PIKO") ahora LANZAN los objetos del mapa (petición del
 *  usuario: "mejora para las habilidades de amy ahora los golpes de
 *  martillo Ahora puede lanzar Auto y objetos del mapa (como el tank) y
 *  redirigir eso en caso si es que el tank los lanza"):
 *   - Sección 4 del barrido 360 (T_AmyHammerSweep): props con física
 *     (prop_physics / _multiplayer / _override / prop_car_alarm) y la
 *     PIEDRA del tank (tank_rock) entran al golpe con LOS real (nada
 *     se lanza a través de paredes) y registro por golpe (el mismo
 *     objeto no se relanza dos veces en un barrido).
 *   - OBJETO QUIETO -> LANZADO "como el tank": EnableMotion + velocidad
 *     horizontal amy_proplaunch_force (700) + arco 400 + volteo
 *     aleatorio (m_angVelocity). El Auto sale volando con arco, estilo
 *     punetazo de Tank.
 *   - PIEDRA DEL TANK u objeto ENTRANTE (velocidad > 250 viniendo hacia
 *     Amy: punetazo de tank a un coche) -> REDIRIGIDO: se devuelve al
 *     tank vivo más cercano (auto-apuntado; sin tank vivo, a la mirada
 *     de Amy) a amy_propredirect_speed (1100). La piedra pasa a ser de
 *     Amy (m_hThrower / m_hOwnerEntity).
 *   - DANO DEL OBJETO VOLADOR: mientras vuela (4s o hasta frenar), lo
 *     que TOQUE sufre (comunes 500; especiales/witch amy_prophit_dmg
 *     150; tank = x2 escalado por el Verdugo, hasta x4; la piedra
 *     DEVUELTA usa amy_rockhit_dmg 500 con Verdugo al tank). El dano se
 *     aplica SIEMPRE desde el monitor de timer (fuera de cualquier hook
 *     del motor: receta v70 anti re-entrada); el hook de toque SOLO
 *     anota la victima pendiente. Cero friendly fire.
 *   - Anti-crash canonico del suite: tracker de EntRefs en arrays
 *     estáticos (CERO handles), UN timer global NO_MAPCHANGE que muere
 *     con el mapa, validación de ref en cada uso, slots reciclables,
 *     reset total en OnPluginStart/OnMapStart/OnMapEnd (SDKHooks limpia
 *     los touches al morir la entidad solo). Sonidos y particulas SOLO
 *     de la lista ya precacheada (AMY_SOUND_HIT_GEN/HIT_TANK y
 *     AMY_PARTICLE_STRIKE_BURST).
 *   - La EMBESTIDA (modo 0) queda INTACTA: su HitWall sigue frenando en
 *     coches (esa es su física probada R8/R9). El martillo pesado vive
 *     SOLO en el modo AOE (los "golpes de martillo").
 *
 *  v72 - PUENTE VSCRIPT PERSISTENTE PARA EL MARTILLO (petición del
 *  usuario: "mejora a lanzamiento de arma: solo Amy podrá lanzar el
 *  martillo"):
 *   - NUEVO: Amy_PublishScriptIdx() escribe ::SonicAmyIdx (el índice de
 *  entidad de la Amy viva) en el root de VScript usando el mismo
 *  logic_script runner del tarot. Se publica en CADA spawn de Amy y se
 *  limpia en muerte / desconexion / cambio de personaje (Amy_OnPlayerDeath
 *  llega por CleanupCharModuleState en los tres caminos).
 *   - El addon "Lanzamiento de martillo v2 (Amy Edition)" lo usa para dos
 *  cosas: (1) SOLO Amy puede lanzar EL martillo (los demas melees siguen
 *  lanzables por cualquiera) y (2) el homing del martillo de Amy.
 *   - Seguro contra índices reciclados: si el slot lo ocupa otro jugador,
 *  su primer spawn limpia el índice viejo (rama else de la publicación).
 *   - Compatible hacia atras: si el addon del martillo no esta instalado,
 *  la publicación es inocua (una escritura de variable por spawn).
 *   - LADO VSCRIPT (v7.4, entregado aparte): Hydro Bomb ya no levanta a
 *  Amy ni a aliados (solo infectados), Vomit Bomb ya no ciega a
 *  supervivientes (solo infectados + stagger), y arreglos de DeathVail /
 *  PhantomBleeding que mataban aliados durante la ventana del tarot.
 *
 *  v71 - TAROT 100% FUNCIONAL (bug del usuario: "arreglo para el resto
 *  de las habilidades del Supertank cuando amy las usa: habilidades como
 *  Singularity y Hydro Bomb y demás no funcionan / no aparecen; y los
 *  escudos no funcionan contra un infectado especial"):
 *   - CAUSA RAÍZ (junto al parche VScript "Amy-Aligned v7.3"): el filtro
 *     anti-FF del Poder 2 ponía damage = 0 a TODO el dano a survivors
 *     durante los 12s de ventana (incluidas garras/puños de SI, tank,
 *     witch y comunes). Eso dejaba al equipo invulnerable 12s y, sobre
 *     todo, el hook de dano VScript de los escudos (que exige
 *     damageDone > 0) JAMÁS veía el dano de un infectado especial:
 *     los escudos nunca reflejaban/absorbían/aturdían.
 *   - FIX: el filtro ahora solo bloquea el dano de las PROPIAS entidades
 *     de las habilidades (point_hurt / env_explosion / inferno: atacante
 *     que NO es un infectado del juego). El dano real de SI/tank (player
 *     de equipo 3), witch y comunes PASA, y los escudos reaccionan.
 *   - LADO VSCRIPT (v7.3, entregado aparte): IsTankDying ya no explota
 *     sobre el info_target del puente (m_nSequence no existe en un
 *     CPointEntity: ~30 habilidades morían en su primera línea, entre
 *     ellas Singularity, Hydro Bomb, Electrocute y TODAS las ramas Amy
 *     de v7.2 que eran código muerto); Singularity ahora se auto-repite
 *     con su bola negra visual; Hydro/Laser ya no llaman natives de
 *     player sobre el info_target; DisruptionWorld aturde de verdad a
 *     los infectados; ElectricMine inicia su timer; SwiftImpact expira.
 *   - Con ambos parches las 50 habilidades del tarot son 100% funcionales
 *     contra SI: NINGUNA se retira del pool (los escudos ahora sí
 *     funcionan contra infectados especiales, que era la condición para
 *     retirarlos).
 *   - QoL: la habilidad loc "ElectroField" se llamaba "Electric Field"
 *     igual que la entity-based "ElectricField" (dos poderes con el
 *     mismo nombre en el menú). Renombrada a "Electro Spot".
 *
 *  v70 - CONTRA DE VÓMITO A PRUEBA DE CRASH (bug del usuario: "cuando
 *  el boomer lanza su vómito pero el contraataque se lo devuelve, en
 *  ocasiones causa crash"):
 *   - CAUSA: la contra mataba al boomer (100 ácido > 50 HP) DENTRO del
 *     hook L4D_OnVomitedUpon, es decir, EN MEDIO del propio spray del
 *     boomer. Al morir explotaba: su explosión volvía a llamar a
 *     OnVomitedUpon (bilis a todos los cercanos) y mutaba el estado
 *     del juego con el spray todavía en la pila de llamadas del motor
 *     (re-entrada dependiente del timing = crash OCASIONAL).
 *   - FIX 1 (diferido): el hook solo DECIDE (bloquea la bilis de Amy);
 *     los efectos (bilis propia al boomer, lanzamiento v68, 100 ácido,
 *     5s sin habilidad) se aplican 0.1s después vía timer userid-only
 *     + NO_MAPCHANGE + DATA_HNDL_CLOSE, FUERA de cualquier hook.
 *   - FIX 2 (solo boomers): la contra solo dispara contra un BOOMER
 *     VIVO del equipo infectado. Las jars de bilis de un compañero
 *     (atacante superviviente) y la bilis de la explosión de un boomer
 *     ya muerto dejan de re-entrar (antes una jar aliada lanzaba y
 *     dañaba con 100 ácido al PROPIO ALIADO = FF involuntario).
 *   - FIX 3 (ventana 1s): tras reflejar, Amy es inmune a la bilis de la
 *     explosión del boomer que ella misma contró (no se ciega por su
 *     propio contraataque). El poder del menú Mastery v69 no cambia.
 *   - Si el boomer muere en los 0.1s de ventana (le disparó el equipo),
 *     la contra se disuelve sin efectos: nadie lanza/daña cadáveres.
 *   - Knuckles v70 (en su .inc): su contra de vómito tenía el MISMO
 *     patrón (stagger + 100 ácido dentro del hook): mismo hardening.
 *
 *  v69 - ANTI-VÓMITO ACTIVABLE (petición del usuario: "quiero que el
 *  anti vómito sea ahora un efecto activable y desactivable"): la contra
 *  de bilis del boomer deja de ser fija y pasa al menú Mastery (sm_mastery)
 *  como poder "Anti-Vómito (reflejo)":
 *   - ON (default): exactamente igual que siempre — la bilis nunca ciega
 *     a Amy, el boomer recibe su propio vómito, sale volando (arco 400,
 *     Amy_ApplyHardStopFling) y come 100 de daño ácido + 5s sin habilidad.
 *   - OFF: el vómito del boomer le afecta normal (bilis + horda).
 *   - La contra de LENGUA del smoker sigue SIEMPRE activa (no cambia).
 *   - La preferencia se guarda en cookie (persiste entre sesiones). Gate
 *     vía DollSys_AntiVomitoActive() (wrapper de Doll_System.inc: este
 *     archivo se incluye ANTES que Doll_System en el manager, por eso no
 *     se referencia el enum DollPowers directo).
 *
 *  v68 - EMPUJE CON LEVANTAMIENTO + STAGGER AL ATERRIZAR (petición del
 *  usuario, 2 cosas: "mejora al empuje de Amy" y "el golpe de martillo
 *  ya no dara stagger inmediatamente sino que lo dara cuando aterrice
 *  al piso, pero no se hará cuando impacte, con todos los tipos de
 *  infectados, ya que si se usa el stagger no funciona el
 *  levantamiento"):
 *   - CAUSA: hasta v67 el golpe aplicaba el stagger (tambaleo del motor)
 *     EN EL MISMO FRAME que el empuje; el estado "stumble" re-escribe la
 *     locomoción del bot y PISABA la velocidad del lanzamiento: la
 *     victima se tambaleaba en el sitio y el levantamiento (vuelo) nunca
 *     se veía.
 *   - FIX: Amy_ApplyHardStopFling (todos los callers: embestida, golpe
 *     AOE del martillo, terremoto del Hammer Jump y las 4 contras
 *     instantaneas) ahora LANZA puro: dano -> frenado en seco -> 0.05s
 *     -> velocidad de vuelo (arco). El stagger seguro (SIStagger_Auto)
 *     lo aplica el MONITOR DE ATERRIZAJE cuando la victima TOCA EL SUELO
 *     (tick 0.1s, userid + serial; grace 0.45s si nunca despega por una
 *     pared pegada; timeout 4s; muerte en vuelo = sin stagger).
 *   - MEJORA DEL EMPUJE: arcos verticales nuevos por tipo (especial y
 *     boomer 400, tank 320, comunes 300, aliados 220; antes 250/250/250/
 *     150): el levantamiento ahora es visible y real.
 *   - WITCH: Witch_Flight v2.5 le añade su propio "stagger al aterrizar"
 *     (stun de aterrizaje: la IA sigue congelada 0.75s tras tocar suelo;
 *     la witch no es CTerrorPlayer y no puede recibir L4D_StaggerPlayer,
 *     el stun congelado es su equivalente exacto).
 *   - COMUNES: oneshot + empuje (mueren en el golpe: nada que tambalear).
 *
 *  v67 - TAROT ALINEADO (petición del usuario: "que el vscript del Super
 *  Tank este 100% alineado con Amy porque no todas las habilidades le
 *  favorecen"): el puente del Poder 2 ahora pasa el ÍNDICE de Amy al
 *  VScript (SetAmyMode(<idx>)). El vscript "Amy-Aligned v7.2" lo usa para:
 *   - Saber quien es la castera (Hyperdrive = sobrecarga de velocidad,
 *     Teleport = Amy parpadea al punto apuntado, Shift Toward = lanza a
 *     los infectados pegados a ella al punto apuntado).
 *   - Poderes defensivos reales para ella: Reflect Shield (refleja 8s),
 *     Reflect Shield Ovl (escudo absorbente 100pts/30s) y Disarm Shield
 *     (puntas: aturde a quien la golpee, 20s).
 *   - Ventana de protección anti-FF en el propio VScript (los efectos
 *     persistentes de 13-22s ya no danan al equipo tras los 12s del SM).
 *   - DropFire/DropSpit definidos (faltaban en el addon modificado:
 *     FireGround y BurningAcid morian con excepción).
 *  Compatible con el vscript viejo (SetAmyMode() sin argumento sigue
 *  funcionando) y con el .smx viejo sobre el vscript nuevo.
 *
 *  v66 - MODO ELEGIBLE (a petición del usuario, confirmado que el crash
 *  del capítulo 2 era el PRECACHE abortado del OnMapStart del manager y
 *  NO el ataque en área): la tecla Z de Amy despacha según el MODO
 *  elegido por el jugador:
 *   - MODO 0 IMPULSO (defecto): la embestida tipo Charger de v64
 *     (steering, cancel, seguro de vacío, ariete, boomer, contra...).
 *   - MODO 1 GOLPE AOE (martillo restaurado): el golpe CIRCULAR 360 del
 *     viejo martillo (v48-v60): Amy se planta y golpea TODO lo que la
 *     rodea en radio 220 durante 0.5s de barrido, con el nucleo v64
 *     (Amy_ImpulseHit): witch flight, Verdugo del tank, boomer burst,
 *     rompe-huesos de pared, desarme, sonidos + burst rosa.
 *  Comando de cambio (ronda 27): la HABILIDAD 3 (tecla C =
 *  sm_sjs_ability3, ruteada por el manager v3.61) o sm_amymodo (alias
 *  sm_amymode): sin argumentos ALTERNA; con "impulso"/"aoe" fija el
 *  modo. SIN cooldown: es preferencia, no ataque.
 *  Cooldown COMPARTIDO (amy_strike_cooldown): misma habilidad, dos
 *  estilos. Patrones anti-crash intactos (v60/v61): arrays estáticos,
 *  timer userid + NO_MAPCHANGE, LOS MASK_SHOT, snapshot-then-strike,
 *  tope de comunes por tick. El registro del barrido se limpia en
 *  OnMapStart/OnMapEnd/round y disconnect; el MODO es preferencia de
 *  sesión y sobrevive cambios de mapa.
 *
 *  v65 - FIX DEL CRASH DEL CAPÍTULO 2 (causa raíz en el manager +
 *  Speed_sonic v2.4: la excepción "Invalid timer handle" del KillTimer
 *  del watchdog abortaba el OnMapStart del manager en el 2o mapa de cada
 *  sesión -> este modulo quedaba SIN precache ni reset -> el jugo del
 *  golpe usaba sonidos/sprites con índices obsoletos del mapa anterior
 *  -> cierre del juego al golpear zombies en el capítulo 2. Aquí se
 *  restaura el precache del burst del golpe (v64 restauro el uso de
 *  AMY_PARTICLE_STRIKE_BURST pero olvido su precache) y se sube la
 *  versión para que el log confirme el build corriendo.
 *
 *  CAMBIO DEFINITIVO (petición del usuario): el Hammer Attack fue
 *  RETIRADO POR COMPLETO y sustituido por el IMPULSO DE IMPACTO:
 *  una embestida tipo Charger (v64: con el jugo del martillo original
 *  restaurado: sonidos de impacto + rompe-huesos contra pared) que
 *  mata y empuja todo lo
 *  que encuentre a su paso (sea lo que sea) y es IMPARABLE durante
 *  el impulso: agarres de hunter/smoker/jockey/charger, golpes de
 *  Tank y tropiezos no la detienen.
 *
 *  v62 - FIX "EN TIERRA APENAS SE MUEVE": el motor de L4D2 CLAMPEA la
 *  velocidad de un superviviente EN EL SUELO a m_flMaxspeed (~220 con
 *  arma). El TeleportEntity ponía 900 u/s: el camino AÉREO no aplica ese
 *  limite (por eso en el aire volaba) y el camino de SUELO la devolvia
 *  al tope en el primer tick -> "apenas se movía unos cm". Fix: durante
 *  el impulso m_flMaxspeed se eleva a la velocidad de la embestida y se
 *  RESTAURA el valor original al terminar (en todos los caminos de fin:
 *  natural, pared, incap, muerte, desconexion, round y mapa). Además el
 *  chequeo de "pared delante" ya no corta el impulso en rampas/escaleras
 *  transitables (normal de la superficie >= 0.7): solo una pared de
 *  verdad (o un prop/puerta) detiene la embestida.
 *
 *  v63 - DOS ARREGLOS tras probar la v62:
 *   1) VELOCIDAD EN TIERRA (raíz de verdad): m_flMaxspeed PIERDE cada
 *      frame contra UpdateSpeed del motor (recalcula arma/vida/etc y
 *      devuelve el tope a ~220 antes del siguiente frame). La embestida
 *      ahora corre en MOVETYPE_FLYGRAVITY (vuelo con gravedad): sin
 *      fricción de suelo y sin clampeo -> 900 u/s REALES en tierra y
 *      aire. WALK se restaura en todos los caminos de fin. Con
 *      asistente de escalones (FLYGRAVITY no sube escalones sola).
 *   2) WITCH: WitchFlight RESTAURADO en la embestida (a petición del
 *      usuario): la witch vuelve a salir VOLANDO al arrollarla, igual
 *      que con el viejo martillo (IA congelada + arco + aterrizaje).
 *
 *  v64 - "CONTROL TOTAL + JUGO DEL MARTILLO" (tras probar la v63, que
 *   ya funciona: el problema de velocidad era un conflicto de mods del
 *   servidor, resuelto reinstalando SourceMod):
 *   1) CONTROL: velocidad 900 -> 700 (pedido: "reducela unos 200 para
 *      que sea más controlable"), la embestida SIGUE LA MIRADA (giro
 *      suave, blend 0.12), la 2a pulsación de Z la frena EN SECO y el
 *      SEGURO DE VACÍO la detiene en el borde de precipicios (no más
 *      caer al vacío cuando el impulso se pasa).
 *   2) NADA LA FRENA FISICAMENTE: grupo de colisión DEBRIS durante la
 *      embestida (atraviesa cuerpos: comunes, especiales, tank),
 *      radio de captura 130 -> 180 y tope de comunes por tick
 *      24 -> 40. La horda ya no detiene el avance.
 *   3) ARIETE: specials y tank golpeados SIGUEN siendo empujados cada
 *      tick mientras esten delante de la embestida (empuje continuo,
 *      sin re-dano): el tank y todo especial van POR DELANTE.
 *   4) BOOMER: no recibe dano al pegarle: sale VOLANDO y a los 0.45s
 *      estalla con TODO su vómito (pop real del juego + frasco de
 *      bilis en el suelo: los comunes cercanos se avalanzan al charco,
 *      como una bilis de boomer lanzada ahi).
 *   5) JUGO DEL MARTILLO ORIGINAL (a petición): sonidos de impacto
 *      (gen/tank, con throttle), swing al arrancar, burst rosa del
 *      golpe (Amy_VFX_StrikeHit), ROMPE-HUESOS CONTRA PARED instantaneo
 *      (bone break 8s + execute) y desarme normal 2s sin pared.
 *   6) CONTRA INSTANTANEA (portada del counter de Knuckles): lengua
 *      (SIEMPRE: el agarre nunca empieza + contraataque al smoker),
 *      vómito (SIEMPRE: se refleja al boomer), pinza de hunter /
 *      montura de jockey / carga de charger / garra de tank /
 *      tropiezos / empujones (DURANTE el impulso: bloqueados ANTES
 *      de que el efecto la toque).
 *
 *  POR QUE ESTA VERSION ES DISTINTA A TODAS LAS ANTERIORES (v49-v60):
 *  el crash "al usar la habilidad tras pasar de capítulo, aunque sea
 *  sin pegarle a nadie" sobrevivio a seis fixes de causa-raíz porque
 *  la activación compartia piezas imposibles de auditar desde
 *  SourceMod (animación del arma, VFX del strike, WitchFlight).
 *  El Impulso de Impacto NO USA NINGUNA de esas piezas:
 *    - CERO escrituras al arma (no existe ResetMeleeWeaponState ni
 *      IN_ATTACK forzado ni amy_hammer_anim: el arma ni se entera).
 *    - CERO VFX y CERO sonidos en la activación (pedido explícito:
 *      "sin las vfx"). Nada de beam rings, shake ni partculas.
 *    - v63: WitchFlight RESTAURADO en la embestida (pedido del
 *      usuario tras la v62): la witch sale volando exactamente como
 *      con el viejo martillo (IA congelada + arco + aterrizaje).
 *    - La activación entera es: TeleportEntity (velocidad) + un
 *      timer userid-only + trazos de rayo + SDKHooks_TakeDamage.
 *      Si esto llega a crashear, la última línea de
 *      logs/amy_impulse_debug.log nombra la llamada culpable.
 *
 *  DISEÑO DEL IMPULSO (tecla Z, mismo sitio del martillo):
 *   - Activación: mismo cooldown (amy_strike_cooldown) y misma
 *     fuerza de empuje (amy_strike_force) que el viejo martillo.
 *   - Movimiento: velocidad fija (amy_impulse_speed, 700 por
 *     defecto desde v64: antes 900, reducida 200 a petición para
 *     control) en la dirección de la mirada (aplanada al plano
 *     horizontal), reafirmada cada 0.05s: ni empujones ni hordas
 *     la desvian de su línea. La componente vertical queda libre
 *     (gravedad/suelo funcionan con normalidad). v63: la embestida
 *     corre en MOVETYPE_FLYGRAVITY (vuelo con gravedad): sin fricción
 *     de suelo ni clampeo a maxspeed, velocidad entera en tierra y
 *     aire (m_flMaxspeed se sigue alzando como red de seguridad).
 *   - IMPARABLE (en cada tick):
 *       1) si esta agarrada, se libera POR EL CAMINO DEL MOTOR
 *          (PinRelease_Cleanse: L4D_Hunter_ReleaseVictim,
 *          L4D_Smoker_ReleaseVictim, L4D2_Jockey_EndRide,
 *          L4D2_Charger_EndPummel/EndCarry) y el atacante queda
 *          tambaleado (anti re-grab inmediato);
 *       2) se cancela el tropiezo del motor (L4D_CancelStagger:
 *          el golpe de Tank la empuja 1 tick como mucho);
 *       3) se reafirma la velocidad del impulso;
 *       4) v62: se reafirma m_flMaxspeed (red de seguridad);
 *       5) v63: se reafirma MOVETYPE_FLYGRAVITY: la embestida VUELA
 *          con gravedad, sin fricción de suelo ni clampeo de
 *          maxspeed -> 900 u/s REALES en tierra y aire (el maxspeed
 *          perdia cada frame contra UpdateSpeed: por eso la v62
 *          seguía lenta en el suelo).
 *     El dano recibido NO se reduce: no es invulnerable, es
 *     imparable (definición exacta del usuario).
 *   - Dano a su paso (radio amy_impulse_radius alrededor de Amy,
 *     con LÍNEA DE VISION real: nada se golpea a través de paredes,
 *     la lección de v53 se mantiene):
 *       comunes   -> amy_impulse_dmg_common (999: oneshot) + empuje
 *       espec     -> amy_impulse_dmg_special (570) + hard-stop
 *                    (stagger seguro + empuje + liberación)
 *       tank      -> amy_impulse_dmg_tank (150, escalado por el
 *                    dash del Verdugo hasta x4) + hard-stop
 *       witch     -> amy_impulse_dmg_witch (400) + WitchFlight
 *                    (v63: vuela igual que con el viejo martillo)
 *       aliados   -> SOLO empuje (sin dano), conmutable
 *                    (amy_impulse_push_teammates)
 *   - Fin del impulso: duración (amy_impulse_duration), distancia
 *     (amy_impulse_maxdist), PARED DE VERDAD delante (v62: rampas y
 *     escaleras transitables ya no cortan el impulso), incap o
 *     muerte. Al terminar, frenado suave, m_flMaxspeed restaurado y
 *     movetype devuelto a WALK (v63: la embestida vuela).
 *   - Estado: arrays estáticos + timer userid-only con
 *     TIMER_FLAG_NO_MAPCHANGE (patron v60, probado estable):
 *     cero handles en todo el ciclo, imposible dejar estado
 *     residual entre capitulos.
 *
 *  LO DEMAS DEL MODULO NO CAMBIA: doble salto (con sus sonidos y
 *  VFX propios), pasivas (Furia/Momentum/JumpBonus), Poder 2
 *  (pool del Super Tank + Hammer Jump con terremoto + WitchFlight,
 *  vuelo de la witch también en la embestida v63), Diva Body,
 *  cookies de sonido, resets en map/round/spawn/disconnect.
 *
 *  ELIMINADO EN v61 (todo lo que era exclusivo del martillo):
 *   - Command_HammerStrike / T_AmyHammerSweep / Amy_HammerHit
 *   - Amy_ForceMeleeAnimation + estado de animación del arma
 *   - Amy_VFX_Strike / Amy_VFX_StrikeHit (VFX del golpe)
 *   - Sonidos del martillo (swing + hit gen + hit tank)
 *   - Sistema de desarme normal 2s (Amy_ApplyNormalDisarm +
 *     T_AmyClearDisarm: era solo del golpe sin pared; el bone-break
 *     del TERREMOTO se conserva intacto)
 *   - Amy_CheckWallImpact + Amy_TraceFilter_World (el impulso usa
 *     el filtro LOS contra geometria solida)
 *  v64: RESTAURADOS a petición del usuario (el jugo del original):
 *   - Sonidos del martillo (swing + hit gen + hit tank)
 *   - Amy_VFX_StrikeHit (burst rosa del golpe)
 *   - Rompe-huesos contra pared instantaneo (bone break + execute)
 *   - Sistema de desarme normal 2s (Amy_ApplyNormalDisarm)
 *   - Convars de bisección amy_dbg_skip_* / amy_dbg_safe /
 *     amy_hammer_anim (ya no hay nada que saltar)
 *  Historial completo de v42-v60: ver worklog del proyecto.
 * ======================================================
 */

#if defined _Amy_included
    #endinput
#endif
#define _Amy_included

#if !defined _sourcemod_included
    #include <sourcemod>
#endif
#if !defined _sdktools_included
    #include <sdktools>
#endif
#if !defined _sdkhooks_included
    #include <sdkhooks>
#endif
#if !defined _clientprefs_included
    #include <clientprefs>
#endif
#if !defined _l4d_stocks_included && !defined _left4dhooks_included
    #tryinclude <left4dhooks>
#endif
#if !defined _si_stagger_included
    #include <SI_Stagger>
#endif
#if !defined _pin_release_included
    #include <Pin_Release>
#endif
#if !defined _witch_flight_included
    #include <Witch_Flight>
#endif

#if !defined AMY_INDEX
    #define AMY_INDEX 3
#endif

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// =======================
// Constantes
// =======================
#define AMY_SOUND_EXPLODE    "ambient/explosions/explode_1.wav"
#define AMY_SOUND_QUAKE      "player/tank/hit/pound_victim_2.wav"
// v64: JUGO DEL MARTILLO ORIGINAL restaurado a petición del usuario
// ("los sonidos de impacto y de cuando se rompen los huesos"):
#define AMY_SOUND_SWING_DEF  "weapons/crowbar/crowbar_swing_1.wav"   // swing al arrancar
#define AMY_SOUND_HIT_GEN    "mobius/sfx/amy/hammer_hit.mp3"         // impacto general
#define AMY_SOUND_HIT_TANK   "mobius/sfx/amy/hammer_tank.mp3"        // impacto de tank

#define AMY_MODEL_CHUNK      "models/props_debris/concrete_chunk01a.mdl"

#define AMY_PARTICLE_EXP1    "gas_explosion_initialburst_smoke"
#define AMY_PARTICLE_EXP2    "gas_explosion_chunks_02"
#define AMY_PARTICLE_EXP3    "aircraft_destroy_fastFireTrail"
#define AMY_SPRITE_BEAM      "sprites/laserbeam.vmt"
#define AMY_SPRITE_GLOW      "sprites/glow01.vmt"

// ============================================================
//  MEJORAS VFX v2.0 - Rosa Chillón
//  Nuevas constantes para efectos visuales mejorados.
//  Se usan partículas nativas de L4D2 (no requiere custom content).
// ============================================================

// Partículas adicionales (todas nativas de L4D2 - seguro sin custom content)
// v61: eliminado AMY_PARTICLE_STRIKE_BURST (VFX del golpe del martillo)
#define AMY_PARTICLE_FURY_AURA      "env_fire_large"                      // aura para Furia Protectora
#define AMY_PARTICLE_JUMP_RING      "scavenge_gas_explosion"              // ring al despegar salto
#define AMY_PARTICLE_WALL_HIT       "boomer_explode_Boomer"               // burst al chocar contra pared
#define AMY_PARTICLE_MOMENTUM       "weapon_grenade_launcher_explosion"   // chispa rosa al ganar momentum
#define AMY_PARTICLE_STRIKE_BURST   "weapon_pipebomb_explosion"           // v64: burst rosa al impactar el golpe (del martillo original)

// Colores Rosa Chillón (RGB)
#define AMY_COLOR_PINK_R     255
#define AMY_COLOR_PINK_G     20
#define AMY_COLOR_PINK_B     147
#define AMY_COLOR_PINK_HOT_R 255
#define AMY_COLOR_PINK_HOT_G 105
#define AMY_COLOR_PINK_HOT_B 180
#define AMY_COLOR_PINK_DEEP_R 200
#define AMY_COLOR_PINK_DEEP_G 0
#define AMY_COLOR_PINK_DEEP_B 120

// v61: eliminados los VFX del golpe (el impulso no tiene VFX)

// Radios de efectos
#define AMY_VFX_FURY_RADIUS      120.0
#define AMY_VFX_EARTHQUAKE_RINGS 3     // cantidad de rings concéntricos en earthquake

// Nuevas constantes v43
#define AMY_FURY_DURATION        8.0     // Duración de la Furia Protectora (era 5s, ahora 8s)
#define AMY_FURY_SPEED_MULT      1.35    // +35% velocidad (era +20%, ahora +35%)
#define AMY_FURY_DMG_MULT        2.00    // +100% dano melee (era +50%, ahora +100%)
#define AMY_FURY_RESIST_MULT     0.70    // -30% dano recibido (era -10%, ahora -30%)
#define AMY_FURY_RADIUS          600.0   // Radio para detectar aliados daniados (era 500, ahora 600)

#define AMY_MOMENTUM_DURATION    5.0     // Duración de cada stack de Momentum (era 3s, ahora 5s)
#define AMY_MOMENTUM_MAX_STACKS  10      // Max stacks de Momentum (era 5, ahora 10)
#define AMY_MOMENTUM_SPEED_BONUS 0.08    // +8% por stack (era +5%, ahora +8%, max +80%)
#define AMY_MOMENTUM_DMG_BONUS   0.05    // +5% dano por stack (NUEVO)

// Jump Damage Bonus — Amy gana +50% de daño durante 5s tras hacer doble salto
#define AMY_JUMP_DMG_MULT        1.50    // +50% de daño tras doble salto
#define AMY_JUMP_DMG_DURATION    5.0     // Duración del bonus de salto (segundos)

// ============================================================
//  v61 - IMPULSO DE IMPACTO: constantes del motor del impulso
// ============================================================
#define AMY_IMPULSE_TICK          0.05   // tick del impulso (20 Hz)
#define AMY_IMPULSE_MAX_PER_TICK  40     // v64: 24 -> 40 (hitbox más grande: la horda no detiene el avance)
#define AMY_IMPULSE_WALL_AHEAD    70.0   // detección de pared/prop delante (unidades, desde los ojos)
#define AMY_IMPULSE_WALK_NORMAL_Z 0.7    // v62: normal.z >= esto = superficie transitable (rampa/escalera), NO pared
// v64 - CONTROL TOTAL de la embestida
#define AMY_IMPULSE_STEER_BLEND     0.12   // cuánto sigue la dirección a la MIRADA por tick (0.12 = giro suave y controlable)
#define AMY_IMPULSE_JUICE_THROTTLE  0.08   // separación mínima entre sonidos/VFX de impacto (la embestida golpea hasta 40 veces/s)

// v66 - MODO AOE (golpe circular 360 del martillo original v48-v60):
// radio del golpe, duración del barrido, tick del barrido y tope de
// comunes por tick (el resto de la horda entra en el tick siguiente).
#define AMY_STRIKE_RANGE          220.0   // radio del golpe circular 360
#define AMY_STRIKE_DURATION       0.5     // duración del barrido (segundos)
#define AMY_STRIKE_VISUAL_TICK    0.1     // tick del barrido (10 Hz)
#define AMY_SWING_MAX_PER_TICK    24      // tope de comunes por tick del barrido
#define AMY_AOE_MAX_HITS          48      // registro de golpeados del AOE (array estático)
#define AMY_VFX_STRIKE_RADIUS     250.0   // radio del ring rosa del press (v12)
#define AMY_VFX_STRIKE_RING_LIFE  0.6     // vida del ring rosa del press (v12)
#define AMY_IMPULSE_BOOMER_FUSE     0.45   // tiempo hasta que estalla un boomer lanzado por la embestida
#define AMY_IMPULSE_VOID_AHEAD      70.0   // distancia de detección de vacío/precipicio delante
#define AMY_IMPULSE_VOID_DEPTH      250.0  // caida sin suelo bajo ese punto = vacío de verdad
#define AMY_NORMAL_DISARM_DURATION  2.0    // v64: desarme normal tras golpe seco sin pared (restaurado del martillo)

// ============================================================
//  v73/v74 - MARTILLO PESADO: el golpe AOE lanza los objetos del mapa
//  (Autos, dumpsters, barriles...) "como el tank" (v74: WAKE despierta
//  la física de los props DORMIDOS + re-impulso de insistencia) y
//  REDIRIGE lo que el tank lanza (la piedra, un coche puneteado hacia
//  Amy). Tunables:
// ============================================================
#define AMY_PROP_CLASSES          5      // clases de props con física escaneadas (v78: + func_physbox)
#define AMY_PROPS_PER_TICK        8      // tope de props lanzados por tick del barrido
#define AMY_PROPS_TRACKED        24      // slots del monitor de objetos volando
#define AMY_PROP_TRACK_LIFE       4.0    // segundos de seguimiento del objeto volador
#define AMY_PROP_MONITOR_TICK     0.1    // tick del monitor (10 Hz, fuera de todo hook)
#define AMY_PROPLAUNCH_UP       400.0    // arco vertical máximo de referencia (u/s)
#define AMY_PROPLAUNCH_MINUP    150.0    // v83: pisito de arco con la mira horizontal/abajo
#define AMY_PROP_GUARD_LIFE       8.0    // v83: custodia (protección+atribución) tras el vuelo
#define AMY_PROP_DMG_COMMON     500.0    // dano del objeto volador a comunes
#define AMY_PROP_DMG_THROTTLE     0.3    // separación mínima entre danos del mismo objeto
#define AMY_PROP_MIN_INCOMING   250.0    // velocidad horizontal mínima = "viene hacia Amy"
#define AMY_PROP_INCOMING_DOT     0.3    // coseno del angulo hacia Amy (entrante de verdad)
#define AMY_PROP_REBOOSTS          1     // v83: UN SOLO rebote (owner: "ya no tiene que rebotar tantas veces")
#define AMY_PROP_REBOOST_RATIO     0.6   // v74: fracción de la meta = "va volando bien" (bajo esto: insistir)
#define AMY_PROP_STALL_DIST        5.0   // v75: desplazamiento real mínimo por tick (menos = cuerpo quieto)
#define AMY_PROP_WAKE_RAD        130.0   // v76: radio del despertador nativo (apretado: el golpeado + vecinos inmediatos)
#define AMY_PROPSRC_HAMMER        0      // v84/v85: lanzado por el MARTILLO Z (con su rebote R20)
#define AMY_PROPSRC_DASH          1      // v84/v85: EMPUJADO por la EMBESTIDA (un solo empuje: 0 re-impulsos)
#define AMY_PROPLAUNCH_NONE       0      // v82: lanzador desconocido (regla default del juego)
#define AMY_PROPLAUNCH_AMY        1      // v82: lo lanzo Amy (NO lastima survivors)
#define AMY_PROPLAUNCH_TANK       2      // v82: lo golpeo el tank (SI lastima survivors)
#define AMY_PROP_COMMON_MIN_SPD  150.0    // v82: velocidad mínima del barrido de comunes
#define AMY_PROP_COMMON_RAD       80.0    // v82: radio del barrido de comunes (martillo)
#define AMY_PROP_COMMON_CD        0.5     // v82: cooldown por común (anti ametrallada)
#define AMY_PROP_ENTS_MAX         4096    // v82: tope de índices de entidad (array de cooldown)

// ============================================================
//  v86/v88/v89 - OJOS DE AMY: AURA de objetos (VERDE = inyectable
//  con sm_amyfisica / ROJO = empujable, con V) — tunables
// ============================================================
#define AMY_VISION_MAX            128    // clones de aura a la vez (v89: 1 clon por objeto)
#define AMY_VISION_CLONE_NAME     "sjs_aura_clone"  // v89: targetname de nuestros clones (el escaner los ignora)
#define AMY_VISION_TICK           0.6    // refresco del escaner (segundos)
#define AMY_VISION_STALE          2.4    // sin verse estos segundos -> apagar el aura
#define AMY_VISION_GREEN_PATTERNS 3      // patrones de modelo "inyectable" (verde)
#define AMY_VISION_GREEN_R        0      // aura VERDE (inyectable): color PURO
#define AMY_VISION_GREEN_G        255    // (byte-order agnostico: brilla igual
#define AMY_VISION_GREEN_B        0      //  bajo cualquier packing del motor)
#define AMY_VISION_RED_R          255    // aura ROJA (empujable): color PURO
#define AMY_VISION_RED_G          0
#define AMY_VISION_RED_B          0
#define AMY_VISION_GLOWTYPE       3      // glow SOLIDO (constante, como el azul de un objetivo)

// v101-OM (manager 3.77.13): TRAIL DEL MARTILLO A COLOR ROSA — pedido
//   del owner ("ajuste al trail de amy ahora el efecto será de color
//   rosa"): mismo motor y misma geometria (laserbeam 25->2, vida 0.3,
//   alpha subido 200->220 para que el rosa se lea bien también en
//   mapas oscuros), solo cambia el tinte: {255,105,180} (pink clasico).
// v100-OM (manager 3.77.11): TRAIL DEL MARTILLO AL MOTOR TE — el
//   env_spritetrail de sonic.inc no renderizaba en L4D2 (invisible
//   con cualquier material, nativo o auténtico; el owner lo confirmo
//   probando ambos): el trail del martillo pasa a TE BeamFollow del
//   motor nuevo de sonic.inc (Sonic_TEStartFollow: laserbeam 25->2,
//   vida 0.3, blanco alpha 200 — el mismo look de la v92, ahora SI
//   visible). Historial v99-OM y anteriores: en la línea de abajo.
#define AMY_INC_VERSION          "v109-OM"  // v109: EL REBALANCEO DEL TAROT (pedido del owner 2026-10-17, ronda 2): "las cartas que no tienen efecto tendrá 1" — la carta MUNDO (la neutra) ahora cura +1 HP en el MISMO pulso del Sol ["tendrá 1": el 1 HP de la cura]; "Sol será Buff pero Luna será nerf": el SOL cura 20% MÁS RÁPIDO (el pulso 2.0s -> 1.6s) y la LUNA su reducción nerf un 5% (la tirada buena de daño recibido x0.85 -> x0.90: la reducción pasa de -15% a -10%; la tirada mala x1.15 queda IGUAL) | v108: EL BUMERAN DE VERDAD + LA B QUE DECIDE + LAS CARTAS SIN MENTIRAS — (1) LA B (sm_sjs_ability4) YA NO ES DE LAS CARTAS DEL SUPER TANK: ahora ALTERNA POR JUGADOR entre modo BUMERAN y modo COMÚN del martillo lanzado (amyom_boom_mode queda como el default de fábrica; las cartas del super tank siguen vivas en consola con sm_amysupertank); (2) el golpe del martillo en modo BUMERAN pega tipo CORTE (DMG_SLASH — pedido del owner); el tiro clasico conserva DMG_CLUB; (3) ROTACION REAL EN VUELO (pedido: "debe girar como un bumeran de verdad, no estar tieso"): la ida gira con la MISMA receta del vuelo de retorno que ya se ve girando desde la v92 — TeleportEntity con el yaw avanzando amyom_boom_spin grados/s (el motor hace pPhys->SetPosition(origin, ang): el objeto físico ADOPTA el angulo — SDK baseentity.cpp L4296+) + la velocidad re-afirmada en el MISMO call (Teleport con vel -> SetVelocity(vel, NULL)); CERO dependencia del SDKCall de sonic.inc; (4) ALCANCE +55%: amyom_boom_dist 1500 -> 2325 de fábrica; (5) CARTAS DEL TAROT: descripción EXACTA carta por carta (con la tirada concreta de la Luna de ese robo, el tope del Sol, y el "dano RECIBIDO por Amy" aclarado) + en cooldown la X muestra la mano vigente con sus efectos; el CUADRO de reducciones de todo el equipo vive en el manager (sm_defensas). (v107: EL BUMERAN + LOS AUTOS + EL GOLPE QUE LANZA)
// v99-OM (manager 3.77.10): MIGRACION MECANICA de firma del Sonic_MakeTrail compartido (v6.17 del sonic.inc: ahora recibe sprite + offset[3] + alpha) — el trail del martillo lanzado mantiene EXACTAMENTE su look (laserbeam nativo, blanco, 25->2, vida 0.3, Z+8). CERO cambio de comportamiento. El GMod original usa models/noodles/om/amy/white.vmt para ese trail — si el owner confirma que lo tiene, se cablea auténtico con fallback en una futura versión. v98-OM (manager 3.77.7): AVATAR REMOTO POR TP — pedido del owner ("los avatares DE OTROS al sistema del tails follow, modo TP; localmente igual, con su pausa"): la copia R (la que ven los demas) viaja por TeleportEntity por tick + reloj vivo SIN EF_NOINTERP (receta tails_follow / Tails v5.25; convar compartido tails_avatar_tp, default 1, 0 = R parentada como antes): los clientes de los demas la INTERPOLAN = suave sin depender de la pausa (que solo re-encaja la vista del dueño). La copia L queda INTACTA (parentada + EF_NOINTERP + pulso). v97-OM (manager 3.77.5): DEFENSA vs PROPS INMOVILES — veredicto del owner: "los inmoviles importan, recuerda que normalmente los props no se mueven (con excepciones, pero es mejor cubrir ambas cosas)": ELIMINADO el filtro de 60 u/s de la v96 — cualquier prop al radio de la ventana (quieto o volando) la consume y suelta el aura que lo repele (sin stun); orden del escaneo intacto (especial/tank > witch > común > prop > piedra del tank); typo "repeledido"->"repelido". v96-OM (manager 3.77.4): CUATRO FIXES — (1) rate del runattack de la pose de defensa y del runthrow = curvas del run/walk normal (antes curva del walk = 3.6x en carrera); (2) HITBOX AÉREO del martillo lanzado 35% mayor (amyom_throw_hitbox 1.35, scan 30 Hz del vuelo de ida, mismos stun+ragdoll/dano que el Touch, una vez por victima); (3) CVARS al cargar/recargar: reconciliación de Sonic_Suite.cfg — los cvars del suite que falten se AGREGAN AL FINAL sin tocar las líneas existentes + prefijo amyom_ dentro del auto-guardado; (4) DEFENSA REWORK: la Z solo abre la POSE, el AURA sale AL IMPACTAR (especial/tank/witch -> aura + contra stun + cartas; común -> aura; prop -> aura que lo repele, sin stun). (manager 3.77.3): v95-OM (manager 3.77.3): FIX JUMP/FALL ENMASCARADOS — la rama de AIRE viva debajo de throw armado/ventana/sin martillo desde la v92-OM (reporte: "el jump y fall no se reproducen"); ahora va justo tras incap, como el framework pills (L775-794: el aire es estado base, los alternates solo sustituyen idle/walk/run) + sentinel de fallbacks 0 -> -1 (el 0 ES AMY_OM_ST_IDLE). v94-OM: AIRE CON MARTILLO — jump/fall según martillo (HammerJump/FallAnimHammer con el; normales sin el; Lua L1631-1640/L221-224; estados JUMPH/FALLH + fallbacks). v93-OM (manager 3.77.1): CHAINS — el martillo del MODELO (submodelo "hammer" del amy.mdl) desaparece de verdad cuando Amy no lo lleva: bodygroup "Chains" = el SetBodygroup(1,1)/(1,0) del Lua del OM (bit 0 de m_nBody), aplicado a las DOS copias del avatar en cada lanzar/recuperar y al ragdoll de muerte; FIX nombres reales del Lua sin martillo (walk_axeless/run_axeless CON guion bajo — la v92-OM buscaba "walkaxeless"/"runaxeless", que NO existen) + fallbacks AXE->base. v92-OM (manager 3.77.0): LAS 4 RANURAS — Z swing fusionado con el área + VENTANA DE DEFENSA (contra pre-sonic 3.5s+cartas, sin ragdoll), X CARTAS DEL TAROT nuevas (2 de 6: Moon/Sun/Emperor/Strength/World/Fool), V (habilidad 3) LANZAMIENTO de martillo (hammer.mdl masa 50 poder 3000, impacto = stun + ragdoll falso VOLANDO), B (habilidad 4) cartas del SUPER TANK intactas, C sigue cambiando área<->dash, + AVATAR amy.mdl patron Tails/Sonic. v91: FIX CINEMÁTICAS

// ============================================================
//  v92-OM — DECLARACIONES (constantes/globals/ConVars). Van AQUÍ,
//  antes del primer uso (Amy_Event_PlayerSpawn / Amy_PreThink /
//  Amy_OnTakeDamage_Passive / Amy_DoHammerAOE usan este estado).
//  Las FUNCIONES del modulo viven al final del archivo.
// ============================================================
#define AMY_OM_VERSION        "v97-OM"
#define AMY_OM_EF_NOINTERP    0x40    // EF_NOINTERP (el avatar nace encajado — receta Tails/Sonic)

// --- modelos (VPK de recursos del owner; mismas rutas que GMod OM).
// Doble intento: caso exacto del Lua de GMod y minusculas (el VPK de
// L4D2 del owner monta sonic.mdl en minusculas — Linux es
// case-sensitive, Windows no: probamos ambas y nos quedamos con la
// que precachee).
#define AMY_OM_MODEL          "models/Noodles/OM/amy.mdl"
#define AMY_OM_MODEL_ALT      "models/noodles/om/amy.mdl"
#define AMY_OM_HAMMER         "models/Noodles/OM/Amy/hammer.mdl"
#define AMY_OM_HAMMER_ALT     "models/noodles/om/amy/hammer.mdl"
#define AMY_OM_HAMMER_FALLBACK "models/w_models/weapons/w_eq_bile_flask.mdl"  // frasco de bilis (receta ORBS de Tails) si falta hammer.mdl

// --- sonidos (rutas EXACTAS del Lua de GMod, como sonic.inc v6.0)
#define AMY_OM_SND_READY      "OM/Amy/HammerReady.wav"        // Z: abre la ventana de defensa
#define AMY_OM_SND_HIT        "OM/Amy/HammerHit.wav"          // Z: la contra aturdi
#define AMY_OM_SND_MISS       "OM/Amy/HammerMiss.wav"         // Z: la ventana vencio sin nadie
#define AMY_OM_SND_THROW_READY "OM/Amy/HammerThrowReady.wav"  // V: se arma
#define AMY_OM_SND_THROW      "OM/Amy/HammerThrow.wav"        // V: lanza
#define AMY_OM_SND_THROW_HIT  "OM/Amy/HammerThrowHit.wav"     // V: el martillo impacta
#define AMY_OM_SND_THROW_CANCEL "OM/Amy/HammerThrowCancel.wav"
#define AMY_OM_SND_RETRACT    "OM/Amy/HammerRetract.wav"      // recupera el martillo
#define AMY_OM_SND_CARD_PICK  "OM/Amy/CardPick.wav"           // roba cartas
#define AMY_OM_SND_CARD_UP    "OM/Amy/CardUpgrade.wav"
#define AMY_OM_SND_CARD_GOOD  "OM/Amy/CardGood.wav"
#define AMY_OM_SND_CARD_NORM  "OM/Amy/CardNormal.wav"
#define AMY_OM_SND_CARD_MOON  "OM/Amy/cardmoon.wav"

// --- números del GMod (om_survivors_register_noodles.lua)
#define AMY_OM_COUNTER_Z          50.0    // el escaneo nace a mitad del cuerpo (GMod: LocalToWorld(0,0,50))
#define AMY_OM_THROW_SPAWN_Z      40.0    // el martillo nace a la altura del pecho (GMod: up*30 del puppet)
#define AMY_OM_THROW_SPAWN_FWD    60.0    // traza anti-pared al nacer (GMod: 50)
#define AMY_OM_THROW_UP           150.0   // componente vertical del lanzamiento (GMod: +150)
#define AMY_OM_HAMMER_MASS        50      // kg (GMod: phys:SetMass(50) — el "peso 50" del owner)
#define AMY_OM_THROW_RETURN_T     0.5     // duración del vuelo de retorno (GMod FlyToPlayer)
#define AMY_OM_THROW_RETURN_ARC   150.0   // arco del retorno (GMod: 150)
#define AMY_OM_THROW_RETURN_SPIN  720.0   // grados/s del retorno (GMod: 720)
#define AMY_OM_ENDLAG             0.85    // tras recuperar el martillo (GMod: HammerEndLag)
#define AMY_OM_HEAL_RADIUS        200.0   // radio de la cura del Sun (GMod: 200)
#define AMY_OM_HEAL_CAP           75      // tope de HP de la cura (GMod: healLimit 75)
#define AMY_OM_TAROT_COUNT        6       // Moon Sun Emperor Strength World Fool

// --- FSM de animación (secuencias del amy.mdl del GMod)
#define AMY_OM_ST_IDLE       0
#define AMY_OM_ST_WALK       1
#define AMY_OM_ST_RUN        2
#define AMY_OM_ST_JUMP       3
#define AMY_OM_ST_FALL       4
#define AMY_OM_ST_DOWNIDLE   5
#define AMY_OM_ST_DOWNWALK   6
#define AMY_OM_ST_ATKIDLE    7    // idleattack: ventana de defensa
#define AMY_OM_ST_ATKWALK    8
#define AMY_OM_ST_ATKRUN     9
#define AMY_OM_ST_THRIDLE    10   // idlethrow: lanzamiento armado
#define AMY_OM_ST_THRWALK    11
#define AMY_OM_ST_THRRUN     12
#define AMY_OM_ST_AXEIDLE    13   // idleaxeless: sin martillo
#define AMY_OM_ST_AXEWALK    14
#define AMY_OM_ST_AXERUN     15
#define AMY_OM_ST_LOWIDLE    16   // idle_lowhealth
#define AMY_OM_ST_LOWWALK    17
#define AMY_OM_ST_LOWRUN     18
#define AMY_OM_ST_SWING      19   // gesto one-shot al aturdir con la contra
#define AMY_OM_ST_THROW      20   // gesto one-shot al lanzar
#define AMY_OM_ST_JUMPH      21   // HammerJump: salto CON martillo (Lua L1636)
#define AMY_OM_ST_FALLH      22   // FallAnimHammer: caida CON martillo (Lua L222)
#define AMY_OM_ANIM_COUNT    23

// --- estado global del modulo OM
int     g_iAmyOMAvatar[MAXPLAYERS + 1];          // EntRef copia R (0 = sin avatar)
int     g_iAmyOMAvatarL[MAXPLAYERS + 1];         // EntRef copia L (solo la duna)
int     g_iAmyOMAnimState[MAXPLAYERS + 1];       // estado FSM actual (-1 = nada)
float   g_fAmyOMAnimLock[MAXPLAYERS + 1];        // one-shot en curso (swing/throw)
float   g_fAmyOMJumpStart[MAXPLAYERS + 1];       // ventana del salto (fix Poppy)
float   g_fAmyOMBodyYaw[MAXPLAYERS + 1];         // yaw del cuerpo (3 reglas)
float   g_fAmyOMYawLastT[MAXPLAYERS + 1];        // reloj del giro suave
float   g_fAmyOMSmLoc[MAXPLAYERS + 1][3];        // smoothing angulos locales R
float   g_fAmyOMSmLocL[MAXPLAYERS + 1][3];       // smoothing L
bool    g_bAmyOMSmSnap[MAXPLAYERS + 1];          // snap (nacimiento/montaje)
int     g_iAmyOMBodyRender[MAXPLAYERS + 1];      // render del cuerpo oculto
float   g_fAmyOMDeathHideUntil[MAXPLAYERS + 1];  // ventana anti-ragdoll
float   g_fAmyOMDeathOrigin[MAXPLAYERS + 1][3];  // donde murió (para el filtro)
bool    g_bAmyOMModelOK = false;                 // amy.mdl en el VPK
bool    g_bAmyOMHammerOK = false;                // hammer.mdl en el VPK
char    g_sAmyOMModel[96];                       // ruta que precacheo (dinámica)
char    g_sAmyOMHammerMdl[96];

// secuencia resuelta por estado (nombre listo para SetAnimation)
char    g_sAmyOMAnimSeq[AMY_OM_ANIM_COUNT][32];
bool    g_bAmyOMAnimSeqOK[AMY_OM_ANIM_COUNT];
bool    g_bAmyOMAnimsResolved = false;

// --- tarot (X)
int     g_iAmyTarotCard1[MAXPLAYERS + 1];        // -1 = sin robar aún
int     g_iAmyTarotCard2[MAXPLAYERS + 1];
float   g_fAmyTarotMoonSpeed[MAXPLAYERS + 1];    // +- del Moon (aleatorio por robo)
float   g_fAmyTarotMoonDmg[MAXPLAYERS + 1];      // 1.15 | 0.85 (aleatorio por robo)
float   g_fAmyTarotNextUse[MAXPLAYERS + 1];      // CD (18s GMod)
float   g_fAmyTarotDelayUntil[MAXPLAYERS + 1];   // CardUsageDelay (4s GMod)
float   g_fAmyTarotNextHeal[MAXPLAYERS + 1];     // pulso de cura del Sun (cada 2s)

// --- contra de la Z (ventana de defensa)
float   g_fAmyOMCounterUntil[MAXPLAYERS + 1];    // fin de la ventana (0 = cerrada)
bool    g_bAmyParryOpen[MAXPLAYERS + 1];         // v102: espejo del parry delegado (lo mueve SOLO el PhaseThink)
bool    g_bAmyOMCounterMissed[MAXPLAYERS + 1];   // aviso de vencimiento 1 vez

// --- lanzamiento (V)
bool    g_bAmyOMThrowArmed[MAXPLAYERS + 1];      // 1a pulsación dada
float   g_fAmyOMArmedUntil[MAXPLAYERS + 1];      // expiración silenciosa del armado
float   g_fAmyOMArmLockUntil[MAXPLAYERS + 1];    // anti-doble del armado (0.3s GMod)
float   g_fAmyOMThrowCDUntil[MAXPLAYERS + 1];    // CD del lanzamiento (24s GMod)
bool    g_bAmyOMNoHammer[MAXPLAYERS + 1];        // el martillo está volando/tirado
float   g_fAmyOMEndLagUntil[MAXPLAYERS + 1];     // tras recuperar (0.85s)
int     g_iAmyOMHammerProp[MAXPLAYERS + 1];      // EntRef del martillo
int     g_iAmyOMHammerTrail[MAXPLAYERS + 1];     // EntRef del trail blanco
float   g_fAmyOMHammerBorn[MAXPLAYERS + 1];      // GameTime del lanzamiento
bool    g_bAmyOMHammerHit[MAXPLAYERS + 1];       // ya hubo victima especial (stats)
bool    g_bAmyOMHammerReturning[MAXPLAYERS + 1]; // vuelo de retorno en curso
float   g_fAmyOMHammerRetStart[MAXPLAYERS + 1];  // inicio del retorno
float   g_fAmyOMHammerRetFrom[MAXPLAYERS + 1][3];// origen del vuelo de retorno
Handle  g_hAmyOMHammerFly[MAXPLAYERS + 1];       // timer 30 Hz del retorno

// --- v107: BOOMERANG HAMMER — el lanzamiento de la V pasa a ser
// bumeran (gira plano, llega a la distancia max y vuelve solo);
// amyom_boom_mode 0 lo devuelve al tiro recto clasico ---
bool    g_bAmyOMHammerBoom[MAXPLAYERS + 1];      // este tiro es bumeran
float   g_fAmyOMHammerBoomPos[MAXPLAYERS + 1][3]; // origen del lanzamiento (distancia)
float   g_fAmyOMHammerBoomDir[MAXPLAYERS + 1][3]; // rumbo del bumeran (velocidad fija en ida)
int     g_iAmyOMHammerSlowN[MAXPLAYERS + 1];     // ticks consecutivos casi-parado (pared/piso)
// v108: LA B ALTERNA EL MODO POR JUGADOR (preferencia, no convar) y la
// ROTACION VISIBLE de la ida se escribe por Teleport (la receta del
// retorno): yaw acumulado + pitch del plano + reloj del avance
bool    g_bAmyOMBoomPref[MAXPLAYERS + 1];        // v108: modo bumeran ELEGIDO por la B (default = convar)
bool    g_bAmyOMBoomPrefInit[MAXPLAYERS + 1];    // v108: ya se cargó el default de fábrica? (la B sobrevive respawns)
float   g_fAmyOMBoomYaw[MAXPLAYERS + 1];         // v108: yaw actual del giro plano (grados)
float   g_fAmyOMBoomPitch[MAXPLAYERS + 1];       // v108: pitch de lanzamiento (el plano del giro)
float   g_fAmyOMBoomLastT[MAXPLAYERS + 1];       // v108: reloj del avance del yaw (dt real)

// --- v107: AUTOS DEL MARTILLO — el impacto mueve objetos (receta del
// aura de la defensa) y un auto en movimiento que ROZA a un especial
// lo deja en ragdoll 4s (3s tank) + empujon, 1 vez por auto por tiro ---
#define AMY_OM_CARS_MAX   12
int     g_iAmyOMCarRef[AMY_OM_CARS_MAX];     // EntRef del auto armado
int     g_iAmyOMCarUser[AMY_OM_CARS_MAX];    // userid de la Amy que tiro
float   g_fAmyOMCarUntil[AMY_OM_CARS_MAX];  // fin de la vigilia
bool    g_bAmyOMCarDone[AMY_OM_CARS_MAX];   // ya aturdio (1 vez por movimiento)
Handle  g_hAmyOMCarWatch = null;            // timer 10 Hz de vigilancia

// --- v96: HITBOX AÉREO del martillo lanzado (35% mayor que su cuerpo)
#define AMY_OM_HITSOFT_MAX  64      // registro de blandos por lanzamiento
#define AMY_OM_HULL_R       20.0    // radio efectivo del casco del objetivo
// v97: AMY_OM_HIT_VEL_MIN (60 u/s) ELIMINADO — veredicto del owner:
// "normalmente los props no se mueven... es mejor cubrir ambas cosas";
// los props activan la defensa quietos o en movimiento.
Handle  g_hAmyOMHammerScan[MAXPLAYERS + 1];    // scan 30 Hz del vuelo de IDA
int     g_iAmyOMHammerSoft[MAXPLAYERS + 1][AMY_OM_HITSOFT_MAX]; // EntRefs ya golpeados por el hitbox ampliado
int     g_iAmyOMHammerSoftN[MAXPLAYERS + 1];
float   g_fAmyOMHammerHitR[MAXPLAYERS + 1];    // radio del hitbox ampliado

// --- v106: COLA DE IMPACTOS DIFERIDOS del Touch físico. El callback del
// SDKHook_Touch corre DENTRO de la simulación vphysics del martillo —
// ahi spawnear/despertar/lanzar el ragdoll falso no despega (ninguna
// habilidad del suite lanza ragdolls desde un touch físico: spindash
// desde su think, Barrido desde su dash, ritual witch desde timer).
// El Touch solo ENCOLA (victima + userid de Amy) y un RequestFrame
// procesa la cola el frame siguiente, FUERA de la simulación — el
// mismo contexto de timer del spindash. La lista de blandos (soft)
// se marca AL ENCOLAR: el scan 30 Hz no re-procesa lo ya tocado.
#define AMY_OM_HITPEND_MAX  16      // impactos simultaneos encolables por frame
int     g_iAmyOMHitPendRef[AMY_OM_HITPEND_MAX];   // EntRef de la victima
int     g_iAmyOMHitPendUser[AMY_OM_HITPEND_MAX];  // userid de la Amy dueña
int     g_iAmyOMHitPendN = 0;
bool    g_bAmyOMHitPendFrame = false;             // RequestFrame ya pedido

// --- convars
ConVar  g_cvAmyOMAvatar;
ConVar  g_cvAmyOMCounterWindow;    // 2.0  (GMod Hammer_dur)
ConVar  g_cvAmyOMCounterStun;      // 3.5  (owner: "por 3.5 seg")
ConVar  g_cvAmyOMCounterRadius;    // 130  (GMod FindInSphere)
ConVar  g_cvAmyOMCounterDmg;       // 20   (GMod aprox stun*1.25/3*13)
ConVar  g_cvAmyOMTarotCD;          // 18   (GMod CardSwap_cd)
ConVar  g_cvAmyOMTarotDelay;       // 4    (GMod CardUsageDelay)
ConVar  g_cvAmyOMTarotSpeed;       // 1    // aplicar el +- velocidad de las cartas
ConVar  g_cvAmyOMTarotHeal;        // 1    // cura del Sun
ConVar  g_cvAmyOMThrowCD;          // 24   (GMod Throw_cd)
ConVar  g_cvAmyOMThrowPower;       // 3000 (GMod 10000*0.3)
ConVar  g_cvAmyOMThrowDmg;         // 25   // dano del impacto a especiales
ConVar  g_cvAmyOMThrowDmgCommon;   // 500  // a comunes
ConVar  g_cvAmyOMThrowReturn;      // 8    (GMod timer 8s)
ConVar  g_cvAmyOMThrowGrab;        // 140  (GMod distancia de recogida)
ConVar  g_cvAmyOMTrails;           // 1    // trail blanco del martillo
ConVar  g_cvAmyOMThrowHitbox;      // 1.35 // v96: multiplicador del hitbox aéreo
ConVar  g_cvAmyOMThrowFling;       // 550  // v105: velocidad de lanzamiento de comunes (impulso GMod direccional)
ConVar  g_cvAmyOMThrowSpin;        // 700  // v105: deg/s del TUMBLE real del martillo en vuelo
ConVar  g_cvAmyOMBoomMode;         // 1    // v107: 1 = bumeran, 0 = tiro recto
ConVar  g_cvAmyOMBoomDist;         // 1500 // v107: distancia max de ida del bumeran
ConVar  g_cvAmyOMBoomSpin;         // 720  // v107: giro plano del bumeran (deg/s)
ConVar  g_cvAmyOMThrowCars;        // 1    // v107: el impacto mueve objetos (receta aura)
ConVar  g_cvAmyOMCarStunSp;        // 4.0  // v107: ragdoll del auto al especial (s)
ConVar  g_cvAmyOMCarStunTank;      // 3.0  // v107: ragdoll del auto al tank (s)
ConVar  g_cvAmyOMCarWatch;         // 6.0  // v107: ventana de vigilia del auto (s)
ConVar  g_cvAmyOMCounterLaunch;    // 1    // v107: la contra lanza con ragdoll volador
ConVar  g_cvAmyOMCounterFling;     // 600  // v107: velocidad del lanzamiento de la contra

Handle  g_hAmyOMAvatarTimer = null;

// nombres de las cartas (orden GMod 0..5)
static const char g_sAmyTarotNames[AMY_OM_TAROT_COUNT][16] = { "Luna", "Sol", "Emperador", "Fuerza", "Mundo", "Loco" };
static const char g_sAmyTarotColors[AMY_OM_TAROT_COUNT][12] = { "9AA7FF", "FFD24A", "B26BFF", "FF5A5A", "6BFF8A", "CCCCCC" };
bool    g_bAmyOMHammerWarned = false;           // aviso 1 vez del fallback del frasco
// === FIN DE LAS DECLARACIONES v92-OM ===

// ============================================================
//  v68 - LEVANTAMIENTO REAL DEL EMPUJE: arcos verticales por tipo
//  de infectado (u/s) + parámetros del monitor de aterrizaje (el
//  stagger se aplica cuando la victima TOCA EL SUELO, no al impactar)
// ============================================================
#define AMY_LAUNCH_UP_SPECIAL    400.0   // arco vertical: especiales y boomer (antes 250)
#define AMY_LAUNCH_UP_TANK       320.0   // arco vertical: tank (pesa más)
#define AMY_LAUNCH_UP_COMMON     300.0   // arco vertical: comunes (el ragdoll hereda el impulso)
#define AMY_LAUNCH_UP_ALLY       220.0   // arco vertical: aliados empujados (antes 150)
#define AMY_LAUNCH_MONITOR_TICK  0.1     // tick del monitor de aterrizaje (10 Hz)
#define AMY_LAUNCH_MAX_AIR       4.0     // timeout de seguridad del monitor (segundos)
#define AMY_LAUNCH_GROUND_GRACE  0.45    // sin despegar en este tiempo (pared pegada): stagger igual

// v70 - contra de vómito diferida (fix del crash): el hook solo decide,
// los efectos se aplican fuera de él
#define AMY_VOMIT_REFLECT_DELAY   0.1    // delay de los efectos de la contra (fuera del hook del vómito)
#define AMY_VOMIT_REFLECT_WINDOW  1.0    // inmunidad de bilis tras reflejar (explosión del boomer contrado)

#define AMY_VFX_TRAIL_LIFE       0.5
#define AMY_VFX_FURY_AURA_LIFE   1.0
#define AMY_VFX_JUMP_RING_LIFE   0.4
#define AMY_VFX_WALL_BURST_LIFE  0.8
#define AMY_FURY_OVERLAY_LIFE    0.5     // Refresh del overlay de Furia (v3.0)
#define AMY_MOMENTUM_HUD_REFRESH 0.2     // Refresh del HUD de Momentum

// v61: los danos del golpe son ahora ConVars (amy_impulse_dmg_*), para
// ajustarlos en vivo sin recompilar. Defaults identicos al martillo:
// común 999 (oneshot), especial 570, witch 400, tank 150 (escalado por el
// dash del Verdugo hasta x4).

// v61: eliminados AMY_HAMMER_ANIM_SEQ (secuencia 742 de la guitarra) y
// el sistema de cleave: el impulso golpea TODO lo que esta a su paso, no
// necesita cleave adicional.

// ============================================================
//  v3.0/v61 - Bone break + Ejecución (ruta del TERREMOTO del Poder 2;
//  el Impulso de Impacto NO usa este sistema: mata y empuja, sin
//  estados sobre las victimas)
//  - Terremoto: bone break (4s) + daño de pared + execute si HP<20%
//  - Si ya está bone-broken y recibe OTRO wall hit: +150% daño de pared
// ============================================================
#define AMY_VULNERABILITY_MULT      1.5       // +50% daño recibido mientras desarmado
#define AMY_WALL_BONUS_MULT         2.5       // +150% daño de pared si ya está desarmado/bone-broken
#define AMY_WALL_HIT_DAMAGE         100.0     // Daño base del golpe contra pared
#define AMY_EXECUTE_HP_PERCENT      0.2       // 20% HP = threshold para execute
#define AMY_EXECUTE_DAMAGE          999999999.0  // Daño de ejecución

// HP máximo del Tank en L4D2 (vanilla y Super Tank).
// - Vanilla Tank: 6000 HP
// - Super Tank (con VScript): puede tener hasta 100,000+ HP según config
//   (Base_Health × (1 + Health_Multiply))
// Usamos un fallback alto para que el execute funcione incluso con Super Tanks.
#define AMY_TANK_MAX_HP_FALLBACK    100000

// ============================================================
//  DASH ESTILO "VERDUGO" (League of Legends)
//  Mientras más vida tenga el Tank en comparación a Amy, más daño hace el strike.
//  Ver fórmula por tramos en Amy_CalculateDashMultiplier().
// ============================================================
#define AMY_DASH_BONUS_MAX          3.0      // +300% daño (x4 total) en ratio máximo
#define AMY_DASH_SURVIVOR_HP_MIN    50.0     // HP mínimo a considerar para Amy (evita div by 0)

static const char g_AmyBoneSounds[][64] = {
    "mobius/sfx/bones/bone_crack_1.mp3",
    "mobius/sfx/bones/bone_crack_2.mp3",
    "mobius/sfx/bones/bone_crack_3.mp3"
};

static const char g_sAmyJumpSoundsLocal[][64] = {
    "mobius/sfx/saltos/jumpSonic1.mp3",
    "mobius/sfx/saltos/jumpSonic2.mp3",
    "mobius/sfx/saltos/jumpSonicCD.mp3",
    "mobius/sfx/saltos/jumpSonicSRB2.mp3"
};

// =======================
// Variables Globales
// =======================
// v49: g_bAmyL4D2 eliminada (solo la usaban los 2 Fling crudos L4D2-only
// que se quitaron por el fix del crash; TeleportEntity es multi-juego)
Handle g_hAmyJumpTimer[MAXPLAYERS + 1];
float g_fAmyStrikeCooldown[MAXPLAYERS + 1];

// Disarm Logic
bool g_bIsBoneBroken[MAXPLAYERS + 1];
float g_fAmyDisarmEndTime[MAXPLAYERS + 1];

// v61: el desarme normal (2s) fue eliminado junto con el martillo. Solo
// queda el hook de dano para el bone-break del terremoto (Poder 2).
bool  g_bAmyHookedOnTakeDmg[MAXPLAYERS + 1];    // Track si el hook OnTakeDamage está activo (bone break)

// Offsets y Sprites
int g_iAmyVelocityOffs = -1;
int g_iAmyBeamSprite = -1;
int g_iAmyHaloSprite = -1;

// v53: eliminados los offsets crudos del arma (m_meleeSwingTimer /
// m_attackTimer / m_swingTimer): los timers del arma se escriben por el
// sistema de PROPS en Amy_ResetWeaponTimerByProp. No queda ninguna
// escritura a memoria por offset calculado en todo el modulo.

int g_iAmySoundChoice[MAXPLAYERS + 1];
Handle g_hAmySoundCookie = INVALID_HANDLE;

// Variables de Salto
int g_iAmyJumps[MAXPLAYERS + 1];
int g_iAmyLastButtons[MAXPLAYERS + 1];

// v61: eliminado TODO el estado de animación del arma (g_bAmyForceMelee-
// Swing / g_fAmySwingEndTime / g_iAmySwingWeaponRef): el impulso no toca
// el arma para nada, ni escribe una sola de sus propiedades, jamás.

float g_fAmyJumpDmg, g_fAmyUpForce, g_fAmyFlingForce, g_fAmyJumpHeight;
float g_fAmyTS_Val, g_fAmyTS_Acc, g_fAmyTS_Rad, g_fAmyTS_Dur;
float g_fAmyStrikeForce, g_fAmyStrikeCD;
float g_fAmyDoubleJumpPower;

// NUEVAS PASIVAS
bool  g_bAmyFuryActive[MAXPLAYERS + 1];
float g_fAmyFuryEndTime[MAXPLAYERS + 1];

// Piko Piko Momentum (nueva pasiva v43)
int   g_iAmyMomentumStacks[MAXPLAYERS + 1];
float g_fAmyMomentumEndTime[MAXPLAYERS + 1];

// Jump Damage Bonus — +50% de daño tras doble salto
bool  g_bAmyJumpDmgActive[MAXPLAYERS + 1];
float g_fAmyJumpDmgEndTime[MAXPLAYERS + 1];

// ============================================================
//  HABILIDAD 2: PODER ALEATORIO DEL SUPER TANK
//  Amy obtiene una habilidad aleatoria del Super Tank.
//  El doble salto ahora es uno de los poderes aleatorios.
// ============================================================
#define AMY_POWER2_CD          1.0    // Cooldown de la habilidad 2
#define AMY_POWER2_POOL_SIZE   55      // Tamaño máximo del pool

// Pool de habilidades: {funcionVScript, nombre, tomaLocation, esSelfCast, esDoubleJump}
char  g_sAmyPower2Funcs[AMY_POWER2_POOL_SIZE][64];
char  g_sAmyPower2Names[AMY_POWER2_POOL_SIZE][48];
bool  g_bAmyPower2Loc[AMY_POWER2_POOL_SIZE];
bool  g_bAmyPower2Self[AMY_POWER2_POOL_SIZE];
bool  g_bAmyPower2Jump[AMY_POWER2_POOL_SIZE];
int   g_iAmyPower2Count = 0;

int   g_iAmyPower2Next[MAXPLAYERS + 1];       // Índice de la próxima habilidad
float g_fAmyPower2LastUse[MAXPLAYERS + 1];    // Timestamp del último uso
Handle g_hAmyPower2Timer[MAXPLAYERS + 1];      // Timer para mostrar cooldown

// Doble salto sigue siendo pasiva permanente.
// Hammer Jump ahora es un poder aleatorio.
bool  g_bAmyHammerJumpActive[MAXPLAYERS + 1];  // ¿Amy tiene Hammer Jump disponible?
float g_fAmyHammerJumpEndTime[MAXPLAYERS + 1]; // Cuándo expira

// Filtro Anti-Friendly Fire para poderes aleatorios
bool  g_bAmyPowerFFActive = false;
float g_fAmyPowerFFEndTime = 0.0;

// ============================================================
//  v61 "IMPULSO DE IMPACTO" - estado del impulso SIN HANDLES
//  El timer del impulso recibe SOLO el userid (int). La lista de
//  entidades golpeadas durante el impulso es un array estático por
//  cliente: cero ArrayList / DataPack / handles que puedan quedar
//  colgados en el cambio de capítulo (patron v60, probado estable).
// ============================================================
#define AMY_IMPULSE_MAX_HITS 48
bool  g_bAmyImpulseActive[MAXPLAYERS + 1];                     // impulso en curso
float g_fAmyImpulseEndT[MAXPLAYERS + 1];                       // instante de fin del impulso
float g_fAmyImpulseDir[MAXPLAYERS + 1][3];                     // dirección del impulso (horizontal, normalizada)
float g_fAmyImpulseStartPos[MAXPLAYERS + 1][3];                // origen del lanzamiento (limite de distancia)
int   g_iAmyImpulseHits[MAXPLAYERS + 1][AMY_IMPULSE_MAX_HITS]; // entidades ya golpeadas en este impulso
int   g_iAmyImpulseHitCount[MAXPLAYERS + 1];                   // cuántas entradas válidas hay
float g_fAmyImpulseSavedMaxSpd[MAXPLAYERS + 1];                // v62: m_flMaxspeed ANTES del impulso (se restaura al terminar)
int   g_iAmyImpulseSavedColGroup[MAXPLAYERS + 1];               // v64: grupo de colisión ANTES del impulso (se restaura al terminar)
float g_fAmyImpulseLastJuice[MAXPLAYERS + 1];                   // v64: throttle del sonido/VFX de impacto del impulso
bool  g_bAmyDisarmed[MAXPLAYERS + 1];                           // v64: desarme normal (2s) tras golpe seco (restaurado del martillo)
float g_fAmyNormalDisarmEndTime[MAXPLAYERS + 1];                // v64: instante de fin del desarme normal

// v68 - monitor de aterrizaje del lanzamiento (arrays, CERO handles):
// el serial sube en cada lanzamiento/reset; un monitor cuyo serial no
// cuadra se apaga solo al primer tick (nunca dos monitores por victima
// y cero "Invalid timer handle" jamás: los timers son userid-only +
// NO_MAPCHANGE y no se guarda ningún handle).
int   g_iAmyLaunchSerial[MAXPLAYERS + 1];
bool  g_bAmyLaunchAirborne[MAXPLAYERS + 1];
// v70 - ventana de "acabo de reflejar": la bilis de la explosión del
// boomer que estalló por la contra propia no vuelve a procesarse
float g_fAmyVomitBlockUntil[MAXPLAYERS + 1];

// v66 - MODO ELEGIBLE: 0 = impulso (embestida, defecto), 1 = golpe AOE
// (martillo circular 360). Preferencia del jugador (sm_amymodo): NO se
// resetea al girar el mapa, solo al desconectar (el siguiente ocupante
// del slot empieza en impulso).
int    g_iAmyAbilityMode[MAXPLAYERS + 1];
// v66 - registro del barrido AOE (patron v60: arrays estáticos, cero
// handles; se vacía al empezar cada golpe, al terminar, en map
// start/end y en disconnect).
int    g_iAmySweepHits[MAXPLAYERS + 1][AMY_AOE_MAX_HITS];
int    g_iAmySweepHitCount[MAXPLAYERS + 1];
float  g_fAmySweepStart[MAXPLAYERS + 1];

// ============================================================
//  v73 - MARTILLO PESADO: tracker de objetos lanzados/redirigidos
//  (EntRefs en arrays estáticos, CERO handles; el monitor es UN timer
//  global NO_MAPCHANGE que muere con el mapa). El hook de toque SOLO
//  anota la victima: el dano lo aplica el monitor FUERA de los hooks
//  del motor (receta anti re-entrada v70).
// ============================================================
// clases con física golpeables por el martillo (la piedra va aparte:
// es un proyectil, no un prop)
static const char g_sAmyPropClasses[AMY_PROP_CLASSES][32] =
{
    "prop_physics",
    "prop_physics_multiplayer",
    "prop_physics_override",
    "prop_car_alarm",
    "func_physbox"        // v78: hittables de brush (también vphysics)
};

// v86: patrones de modelo de los decorativos INYECTABLES (los que se
// tiñen VERDE). Receta v79: "vehicle" es el paraguas seguro de L4D2
// (cubre autos, bus y furgonetas; "car" solo matchearia el CAROUSEL
// de Dark Carnival y sus caballitos), montacargas y dumpster aparte.
static const char g_sAmyVisGreenMdl[AMY_VISION_GREEN_PATTERNS][16] =
{
    "vehicle",
    "forklift",
    "dumpster"
};

int    g_iAmyPropRef[AMY_PROPS_TRACKED];       // EntRef del objeto (-1 = slot libre)
int    g_iAmyPropPending[AMY_PROPS_TRACKED];   // EntRef de la victima anotada por el toque
int    g_iAmyPropOwnerUid[AMY_PROPS_TRACKED];  // userid de la Amy que golpeo (credito del dano)
float  g_fAmyPropEndT[AMY_PROPS_TRACKED];      // fin de la ventana de VUELO (re-impulso+metralla)
float  g_fAmyPropGuardT[AMY_PROPS_TRACKED];    // v83: fin de la CUSTODIA (protección anti-rebote)
float  g_fAmyPropLaunchGameT[AMY_PROPS_TRACKED]; // v83: GameTime del lanzamiento (frescura red B)
float  g_fAmyPropLastDmg[AMY_PROPS_TRACKED];   // throttle de dano por objeto
bool   g_bAmyPropIsRock[AMY_PROPS_TRACKED];    // es la piedra del tank devuelta
bool   g_bAmyPropTimerOn = false;              // el monitor global está corriendo
float  g_vecAmyPropVel[AMY_PROPS_TRACKED][3];  // v74: velocidad objetivo del lanzamiento (re-impulso)
int    g_iAmyPropBoosts[AMY_PROPS_TRACKED];    // v74: re-impulsos restantes ("insistencia del tank")
float  g_vecAmyPropPos[AMY_PROPS_TRACKED][3];  // v75: posición real del tick anterior (detector de cuerpo quieto)
int    g_iAmyPropLauncher[AMY_PROPS_TRACKED];  // v82: quien lanzo el objeto (NONE/AMY/TANK)
int    g_iAmyPropSource[AMY_PROPS_TRACKED];    // v84: MARTILLO (completo) o EMBESTIDA (reducido)
float  g_fAmyCommonHitAt[AMY_PROP_ENTS_MAX];   // v82: último barrido de cada común (cooldown 0.5s)

// v86/v89: OJOS DE AMY — registro de auras (1 CLON invisible por
// objeto) + estado del escaner. Sin handles: arrays estáticos + UN
// timer global NO_MAPCHANGE que vive mientras alguna Amy o SAGE viva
// exista (muerta la última, los clones mueren solos y el timer se
// apaga). El objeto REAL jamás se toca: no hay originales que guardar.
int    g_iAmyVisRef[AMY_VISION_MAX];        // EntRef del objeto con aura (-1 = slot libre)
int    g_iAmyVisClone[AMY_VISION_MAX];      // v89: EntRef del CLON invisible que dibuja el aura
int    g_iAmyVisKind[AMY_VISION_MAX];       // 1 = VERDE (inyectable) | 2 = ROJO (empujable)
float  g_fAmyVisLast[AMY_VISION_MAX];       // última vez visto por el escaner
float  g_fAmyVisTickT = 0.0;                // marca de tiempo del tick en curso
bool   g_bAmyVisTimerOn = false;            // el escaner global está corriendo
bool   g_bAmyVisHintShown[MAXPLAYERS + 1];  // v87: pista de COLORES mostrada (1 vez por sesión, informativa)
ConVar g_cvAmyVision, g_cvAmyVisionRadius; // convars de la visión
bool   g_bAmyVisEnabled = true;             // cache amy_vision
float  g_fAmyVisRadius = 700.0;             // cache amy_vision_radius (v89: reducido a 700)
int    g_iAmyVisGlowTypeOff  = -1;  // v88: m_iGlowType (send O datamap: enciende el aura)
int    g_iAmyVisGlowClrOff   = -1;  // v88: m_glowColorOverride (color del aura)
int    g_iAmyVisGlowRangeOff = -1;  // v88: m_nGlowRange (distancia max del aura)
int    g_iAmyVisGlowRMinOff  = -1;  // v88: m_nGlowRangeMin (fade mínimo del aura)
int    g_iAmyVisGlowTeamOff  = -1;  // v88: m_iGlowTeam (quien la ve: 0 = todos)
int    g_iAmyVisModeOff = -1;               // offset de m_nRenderMode (saltar invisibles)

// v61: ConVars del impulso (y su cache de valores)
ConVar g_cvAmyImpulseSpeed, g_cvAmyImpulseDuration, g_cvAmyImpulseMaxDist, g_cvAmyImpulseRadius;
ConVar g_cvAmyImpulsePushTeam, g_cvAmyImpDmgCommon, g_cvAmyImpDmgSpecial, g_cvAmyImpDmgWitch, g_cvAmyImpDmgTank;
float  g_fAmyImpulseSpeed, g_fAmyImpulseDuration, g_fAmyImpulseMaxDist, g_fAmyImpulseRadius;
float  g_fAmyImpDmgCommon, g_fAmyImpDmgSpecial, g_fAmyImpDmgWitch, g_fAmyImpDmgTank;
bool   g_bAmyImpulsePushTeam;

// v73: convars y cache del martillo pesado (lanzar/redirigir props)
ConVar g_cvAmyPropLaunch, g_cvAmyPropRedirect, g_cvAmyPropHitDmg, g_cvAmyRockHitDmg;
float  g_fAmyPropLaunchForce, g_fAmyPropRedirectSpeed, g_fAmyPropHitDmg, g_fAmyRockHitDmg;
ConVar g_cvAmyPropWakeForce, g_cvAmyPropWakeDmg;         // v75: golpe real (dano con fuerza)
float  g_fAmyPropWakeForce, g_fAmyPropWakeDmg;           // v75: cache del golpe real
ConVar g_cvAmyPropWakeBlast;                             // v76: despertador nativo (env_physexplosion)
float  g_fAmyPropWakeBlast;                              // v76: cache del despertador
ConVar g_cvAmyPropDebug;                                 // v78: diagnostico en chat (pista de modo + hallazgos)
bool   g_bAmyPropDebug;                                  // v78: cache del diagnostico
bool   g_bAmyPropHintShown[MAXPLAYERS + 1];              // v78: pista de modo mostrada (1 vez por sesión)
bool   g_bAmySweepFirstTick[MAXPLAYERS + 1];             // v78: primer tick del barrido (línea diagnostica)

// ============================================================
//  SISTEMA DIVA BODY — Variables globales
//  (definidas aquí para que sean visibles desde todos los hooks)
// ============================================================
bool g_bDivaBodyActive[MAXPLAYERS + 1];   // ¿Amy tiene Diva Body activo?
bool g_bDivaSallyPresent = false;         // ¿La Sally real está en el servidor?
int  g_iDivaCachedSurvChar[MAXPLAYERS + 1]; // Survivor character cacheado (evita GetEntProp cada frame)
float g_fDivaLastCacheUpdate[MAXPLAYERS + 1]; // Timestamp del último update del cache
float g_fDivaLastChatMsg[MAXPLAYERS + 1];  // Throttle: último mensaje de chat enviado (evita reliable stream overflow)

// ============================================================
//  VFX v2.0 - Tracking de efectos visuales
// ============================================================
Handle g_hAmyFuryAuraTimer[MAXPLAYERS + 1];    // Timer para aura de Furia (refresca cada 0.5s)
Handle g_hAmyTrailTimer[MAXPLAYERS + 1];        // Timer para trail de doble salto
int    g_iAmyFuryAuraEnt[MAXPLAYERS + 1];       // Entidad del aura activa (para limpieza)
float  g_fAmyLastAuraPulse[MAXPLAYERS + 1];     // Control de pulso del aura
float  g_fAmyLastFuryOverlay[MAXPLAYERS + 1];   // Control de refresh del overlay de Furia
float  g_fAmyLastMomentumHUD[MAXPLAYERS + 1];   // Control de refresh del HUD de Momentum

ConVar g_cvAmyJumpDamage, g_cvAmyJumpHeight, g_cvAmyUpForce, g_cvAmyFlingForce;
ConVar g_cvAmyTimeScaleVal, g_cvAmyTimeScaleAcc, g_cvAmyTimeScaleDur, g_cvAmyTimeScaleRad;
ConVar g_cvAmyStrikeForce, g_cvAmyStrikeCD;
ConVar g_cvAmyDoubleJumpPower;

// ============================================================
//  v52 - SISTEMA DE DIAGNOSTICO DEL CRASH DEL MARTILLO
//  Ver cabecera del archivo. Estas convars permiten desactivar por
//  partes el press de la habilidad para bisecar el crash, y
//  amy_dbg_log escribe cada paso a addons/sourcemod/logs/
//  amy_hammer_debug.log (la última línea antes del cierre del juego
//  es la llamada que lo provoco).
// ============================================================
ConVar g_cvDbgLog;   // v61: único convar de diagnostico que queda (log paso a paso)

// Escribe una línea al log de diagnostico (si amy_dbg_log 1).
// LogToFile abre/escribe/cierra el archivo en la MISMA llamada: la
// última línea del archivo tras un crash = la llamada culpable.
void AmyDbg_Log(const char[] fmt, any ...)
{
    if (g_cvDbgLog == null || !g_cvDbgLog.BoolValue) return;
    char buf[256];
    VFormat(buf, sizeof(buf), fmt, 2);
    LogToFile("amy_impulse_debug.log", buf);
}

// v61: eliminados los helpers de bisección (AmyDbg_Skip*): no hay VFX,
// ni sonidos, ni animación, ni barrido del martillo que saltar. La
// activación del impulso es una sola pieza: velocidad + timer + trazos.

#define Amy_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// Inicialización
// =======================

public void Amy_OnPluginStart()
{
    // v49: g_bAmyL4D2 eliminada junto a los Fling crudos (warning 204)

    g_hAmySoundCookie = RegClientCookie("sj_sound_choice", "Sonic Jump sound selection", CookieAccess_Public);

    g_cvAmyUpForce      = CreateConVar("amy_hammer_upforce", "200.0", "Fuerza vertical del impacto", _, true, 0.0, true, 2000.0);
    g_cvAmyFlingForce   = CreateConVar("amy_hammer_flingforce", "800.0", "Fuerza de empuje horizontal", _, true, 0.0, true, 5000.0);
    g_cvAmyJumpHeight   = CreateConVar("amy_hammer_jumpheight", "600.0", "Altura del salto", _, true, 0.0, true, 2000.0);
    g_cvAmyJumpDamage   = CreateConVar("amy_hammer_damage", "50.0", "Dano del impacto sismico", _, true, 0.0, true, 5000.0);

    g_cvAmyStrikeForce  = CreateConVar("amy_strike_force", "1100.0", "Fuerza del golpe directo", _, true, 0.0, true, 5000.0);
    g_cvAmyStrikeCD     = CreateConVar("amy_strike_cooldown", "1.5", "Enfriamiento del golpe", _, true, 0.0, true, 30.0);

    // v73 - MARTILLO PESADO: lanzar/redirigir objetos del mapa
    g_cvAmyPropLaunch   = CreateConVar("amy_proplaunch_force", "700.0", "v73: fuerza del objeto lanzado por el martillo (como el punetazo del tank)", _, true, 0.0, true, 3000.0);
    g_cvAmyPropRedirect = CreateConVar("amy_propredirect_speed", "1100.0", "v73: velocidad de la devolución (piedra del tank / objeto entrante)", _, true, 0.0, true, 3000.0);
    g_cvAmyPropHitDmg   = CreateConVar("amy_prophit_dmg", "150.0", "v73: dano del objeto volador a especiales y witch (tank: x2 x Verdugo)", _, true, 0.0, true, 5000.0);
    g_cvAmyRockHitDmg   = CreateConVar("amy_rockhit_dmg", "500.0", "v73: dano de la piedra del tank DEVUELTA (tank: x Verdugo hasta x4)", _, true, 0.0, true, 5000.0);
    // v75 - GOLPE REAL: dano con fuerza al prop (la única ruta que
    // despierta y empuja el cuerpo vphysics dormido: receta del tank)
    g_cvAmyPropWakeForce = CreateConVar("amy_propwake_force", "200.0", "v75: empujon físico real del golpe (u/s, escalado por masa: igual para todo objeto)", _, true, 0.0, true, 1000.0);
    g_cvAmyPropWakeDmg   = CreateConVar("amy_propwake_dmg", "10.0", "v75: dano del golpe real (0 = desactivado: el objeto dormido no despega)", _, true, 0.0, true, 500.0);
    g_cvAmyPropWakeBlast = CreateConVar("amy_propwake_blast", "300.0", "v76: potencia del despertador nativo env_physexplosion (receta del plugin de autos explosivos; 0 = desactivado)", _, true, 0.0, true, 5000.0);
    // v78: diagnostico visible (1 = on: pista de modo + "objetos en radio")
    g_cvAmyPropDebug   = CreateConVar("amy_propdebug", "1.0", "v78: diagnostico en chat de props (pista de modo en la embestida + aviso de escaneo vacío); 0 = silencio", _, true, 0.0, true, 1.0);

    // v86: OJOS DE AMY — visión de objetos (verde/rojo)
    g_cvAmyVision       = CreateConVar("amy_vision", "1.0", "v89: AURA AUTOMÁTICA de Amy (master switch de admin): 1 = siempre encendida, aura VERDE = inyectables, aura ROJA = empujables (SOLO Amy y Sage la ven); 0 = apagada", _, true, 0.0, true, 1.0);
    g_cvAmyVisionRadius = CreateConVar("amy_vision_radius", "700.0", "v89: radio del AURA AUTOMÁTICA de Amy (lo que este a este rango queda rodeado de aura; R26: reducido a 700)", _, true, 200.0, true, 2000.0);

    // v73: tracker de props vacío desde el arranque (cubre el late-load:
    // un mapa ya iniciado no vuelve a disparar OnMapStart)
    Amy_PropResetTracker();

    // v86: registro de teñidos vacío desde el arranque (mismo late-load)
    Amy_VisionResetAll();

    g_cvAmyTimeScaleVal = CreateConVar("amy_timescale_value", "1.0", "Timescale (1.0 = normal, <1.0 = slowmo)", _, true, 0.1, true, 1.0);
    g_cvAmyTimeScaleAcc = CreateConVar("amy_timescale_acc", "1.0", "Aceleración del timescale", _, true, 0.1, true, 10.0);
    g_cvAmyTimeScaleDur = CreateConVar("amy_timescale_dur", "2.0", "Duración del timescale", _, true, 0.1, true, 10.0);
    g_cvAmyTimeScaleRad = CreateConVar("amy_timescale_rad", "500.0", "Radio del efecto timescale", _, true, 50.0, true, 3000.0);

    g_cvAmyDoubleJumpPower = CreateConVar("amy_double_jump_power", "600.0", "Fuerza del doble salto", _, true, 0.0, true, 2000.0);

    g_cvAmyUpForce.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyFlingForce.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyJumpHeight.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyJumpDamage.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyTimeScaleRad.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyStrikeForce.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyStrikeCD.AddChangeHook(Amy_ConVarChanged);
    // v73: martillo pesado
    g_cvAmyPropLaunch.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyPropRedirect.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyPropHitDmg.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyRockHitDmg.AddChangeHook(Amy_ConVarChanged);
    // v75: golpe real
    g_cvAmyPropWakeForce.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyPropWakeDmg.AddChangeHook(Amy_ConVarChanged);
    // v76: despertador nativo
    g_cvAmyPropWakeBlast.AddChangeHook(Amy_ConVarChanged);
    // v78: diagnostico
    g_cvAmyPropDebug.AddChangeHook(Amy_ConVarChanged);
    // v86: ojos de Amy (visión de objetos)
    g_cvAmyVision.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyVisionRadius.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyDoubleJumpPower.AddChangeHook(Amy_ConVarChanged);

    HookEvent("player_hurt", Amy_Event_PlayerHurt);
    HookEvent("player_death", Amy_Event_PlayerDeath);
    HookEvent("round_end", Amy_Event_RoundEnd);
    HookEvent("round_start", Amy_Event_RoundStart_Full);
    HookEvent("round_start", Diva_OnRoundStart);
    HookEvent("player_disconnect", Amy_Event_PlayerDisconnect);
    HookEvent("player_spawn", Amy_Event_PlayerSpawn_FF);

    // DIVA BODY — Detección de Amy usando Rochelle sin Sally real
    HookEvent("player_spawn", Diva_OnPlayerSpawn);
    HookEvent("player_disconnect", Diva_OnPlayerDisconnect);
    HookEvent("witch_spawn", Diva_OnWitchSpawn);
    HookEvent("player_team", Diva_OnPlayerTeam);          // Detectar cambio de equipo
    HookEvent("player_first_spawn", Diva_OnPlayerSpawn);  // Detectar primer spawn del capítulo

    // Comando de debug para Diva Body
    RegConsoleCmd("sm_divadebug", Amy_CommandDivaDebug, "Estado de Diva Body (debug)");

    g_iAmyVelocityOffs = FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]");

    // v88: offsets del AURA — el glow del motor de L4D2 (el MISMO de
    // los objetivos azules y los compis no realistas). Resueltos UNA
    // vez al arranque, mismo patron del velocity: si el mod no los
    // tuviera (-1), la visión queda inerte — JAMÁS stocks por nombre
    // (ThrowError). m_iGlowType puede vivir solo en el datamap según
    // la rama del engine: se intenta por send aquí y, si falla,
    // perezosamente por datamap con la primera entidad teñida.
    g_iAmyVisGlowTypeOff  = FindSendPropInfo("CBaseEntity", "m_iGlowType");
    g_iAmyVisGlowClrOff   = FindSendPropInfo("CBaseEntity", "m_glowColorOverride");
    g_iAmyVisGlowRangeOff = FindSendPropInfo("CBaseEntity", "m_nGlowRange");
    g_iAmyVisGlowRMinOff  = FindSendPropInfo("CBaseEntity", "m_nGlowRangeMin");
    g_iAmyVisGlowTeamOff  = FindSendPropInfo("CBaseEntity", "m_iGlowTeam");
    g_iAmyVisModeOff      = FindSendPropInfo("CBaseEntity", "m_nRenderMode");

    // v61: el arma NO SE TOCA. No hay escrituras de props del arma, ni
    // offsets crudos, ni IN_ATTACK forzado, ni animación: el impulso de
    // impacto es 100% capa SourceMod (velocidad + trazos de rayo + dano)
    // y no escribe NADA en el arma, en ningún momento, jamás.

    // v61: único convar de diagnostico (log paso a paso del impulso).
    // Los convars de bisección del martillo (amy_dbg_skip_* / amy_dbg_safe /
    // amy_hammer_anim) fueron eliminados junto con la habilidad.
    g_cvDbgLog       = CreateConVar("amy_dbg_log", "1", "1 = escribir el log paso a paso del impulso (logs/amy_impulse_debug.log)", _, true, 0.0, true, 1.0);
    RegConsoleCmd("sm_amydbg", Amy_CommandDbg, "Estado del diagnostico de Amy (v70)");

    // v66 - MODO ELEGIBLE: comando para alternar/fijar el estilo de la
    // habilidad de Z (impulso de embestida o golpe AOE del martillo).
    RegConsoleCmd("sm_amymodo", Amy_CommandAbilityMode, "Alterna el estilo de la habilidad de Amy: impulso (embestida) o golpe en área (AOE)");
    RegConsoleCmd("sm_amymode", Amy_CommandAbilityMode, "Alias de sm_amymodo (impulso | aoe)");
    RegConsoleCmd("sm_amypropinfo", Amy_CmdPropInfo, "v79: que es esto que miro? (clase/modelo/movetype/masa + veredicto)");

    // v102: puente inverso del parry delegado (lo invoca el chch_parrying.nut)
    RegServerCmd("amyparry_strike", Amy_CmdParryStrike, "v102: un proyectil entro al rango de la defensa de Amy (dispara el martillazo + aura)");
    RegConsoleCmd("sm_amyprop", Amy_CmdPropInfo, "Alias de sm_amypropinfo");
    RegConsoleCmd("sm_amyfisica", Amy_CmdFisica, "v82: inyectar FÍSICA al decorativo que miras (ÚNICA vía desde v82; masa opcional en kg, defecto 100)");
    RegConsoleCmd("sm_amyfis", Amy_CmdFisica, "Alias corto de sm_amyfisica");
    // v87: OJOS AUTOMÁTICOS — sin comando: la visión enciende sola
    // al spawn y ve todo en radio amy_vision_radius (1000).

    // ============================================================
    //  v61 - IMPULSO DE IMPACTO: convars
    // ============================================================
    // v64: 900 -> 700 a petición del usuario ("reducela unos 200 para
    // que sea un poco más controlable"). OJO: si el server ya tiene
    // cfg/sourcemod/Amy_Impulse_Ability.cfg generado, hay que borrarlo
    // o bajar a mano amy_impulse_speed 700 (el cfg viejo pisa el default).
    g_cvAmyImpulseSpeed    = CreateConVar("amy_impulse_speed",    "700",  "Velocidad del impulso de impacto (u/s)", _, true, 100.0, true, 2500.0);
    g_cvAmyImpulseDuration = CreateConVar("amy_impulse_duration", "1.2",  "Duración máxima del impulso (segundos)", _, true, 0.2, true, 5.0);
    g_cvAmyImpulseMaxDist  = CreateConVar("amy_impulse_maxdist",  "1200", "Distancia máxima del impulso (unidades)", _, true, 100.0, true, 5000.0);
    // v64: 130 -> 180 (hitbox "un poco más grande": los comunes mueren
    // antes de tocarla y la horda no detiene el avance)
    g_cvAmyImpulseRadius   = CreateConVar("amy_impulse_radius",   "180",  "Radio de captura del impulso alrededor de Amy (unidades)", _, true, 50.0, true, 300.0);
    g_cvAmyImpulsePushTeam = CreateConVar("amy_impulse_push_teammates", "1", "1 = el impulso también empuja a los aliados (sin dano)", _, true, 0.0, true, 1.0);
    g_cvAmyImpDmgCommon    = CreateConVar("amy_impulse_dmg_common",  "999", "Dano del impulso a comunes (999 = oneshot)", _, true, 0.0, true, 9999.0);
    g_cvAmyImpDmgSpecial   = CreateConVar("amy_impulse_dmg_special", "570", "Dano del impulso a especiales", _, true, 0.0, true, 9999.0);
    g_cvAmyImpDmgWitch     = CreateConVar("amy_impulse_dmg_witch",   "400", "Dano del impulso a la witch", _, true, 0.0, true, 9999.0);
    g_cvAmyImpDmgTank      = CreateConVar("amy_impulse_dmg_tank",    "150", "Dano base del impulso al Tank (el dash del Verdugo lo escala hasta x4)", _, true, 0.0, true, 9999.0);

    g_cvAmyImpulseSpeed.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyImpulseDuration.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyImpulseMaxDist.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyImpulseRadius.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyImpulsePushTeam.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyImpDmgCommon.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyImpDmgSpecial.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyImpDmgWitch.AddChangeHook(Amy_ConVarChanged);
    g_cvAmyImpDmgTank.AddChangeHook(Amy_ConVarChanged);

    AmyDbg_Log("=== BUILD AMY v71 (TAROT 100% FUNCIONAL: anti-FF inteligente + escudos reactivan vs infectados) | plugin iniciado ===");

    // v3.75: AutoExecConfig eliminado - config ÚNICA del suite (Sonic_Suite.cfg, auto-guardada; ver manager). El archivo viejo queda muerto.
    Amy_UpdateCvars();

    // Inicializar pool de poderes aleatorios
    Amy_InitPower2Pool();

    // Hookear SDKHook_OnTakeDamage en todos los players ya conectados (hot reload)
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i)) {
            SDKHook(i, SDKHook_OnTakeDamage, Amy_PowerFF_OnTakeDamage);
        }
    }

    // Hot Reload Support
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            Amy_ResetVictim(i);
            g_iAmyJumps[i] = 0;
            g_bAmyFuryActive[i] = false;
            g_iAmyMomentumStacks[i] = 0;
            g_fAmyMomentumEndTime[i] = 0.0;

            SDKUnhook(i, SDKHook_OnTakeDamage, Amy_OnTakeDamage_Passive);
            SDKUnhook(i, SDKHook_PreThink, Amy_PreThink);

            if (g_iPlayerCharIdx[i] == AMY_INDEX)
            {
                SDKHook(i, SDKHook_OnTakeDamage, Amy_OnTakeDamage_Passive);
                SDKHook(i, SDKHook_PreThink, Amy_PreThink);
            }

            if (AreClientCookiesCached(i)) Amy_LoadSoundPreference(i);
        }
    }

    // v86: late-load — si ya hay una Amy viva conectada, el escaner de
    // objetos arranca ya (player_spawn no re-dispara en un mapa vivo)
    Amy_VisionEnsureTimer();

    // v92-OM: el modulo OM (avatar, tarot, contra, lanzamiento)
    Amy_OM_OnPluginStart();
}

public void Amy_UpdateCvars()
{
    if (g_cvAmyJumpDamage == null) return;

    g_fAmyJumpDmg     = g_cvAmyJumpDamage.FloatValue;
    g_fAmyUpForce     = g_cvAmyUpForce.FloatValue;
    g_fAmyFlingForce  = g_cvAmyFlingForce.FloatValue;
    g_fAmyJumpHeight  = g_cvAmyJumpHeight.FloatValue;
    g_fAmyStrikeForce = g_cvAmyStrikeForce.FloatValue;
    g_fAmyStrikeCD    = g_cvAmyStrikeCD.FloatValue;

    // v73: cache del martillo pesado
    g_fAmyPropLaunchForce   = g_cvAmyPropLaunch.FloatValue;
    g_fAmyPropRedirectSpeed = g_cvAmyPropRedirect.FloatValue;
    g_fAmyPropHitDmg        = g_cvAmyPropHitDmg.FloatValue;
    g_fAmyRockHitDmg        = g_cvAmyRockHitDmg.FloatValue;

    // v75: cache del golpe real
    g_fAmyPropWakeForce     = g_cvAmyPropWakeForce.FloatValue;
    g_fAmyPropWakeDmg       = g_cvAmyPropWakeDmg.FloatValue;
    // v76: cache del despertador nativo
    g_fAmyPropWakeBlast     = g_cvAmyPropWakeBlast.FloatValue;
    // v78: cache del diagnostico
    g_bAmyPropDebug       = g_cvAmyPropDebug.BoolValue;
    // v86: cache de la visión de objetos
    g_bAmyVisEnabled = g_cvAmyVision.BoolValue;
    g_fAmyVisRadius  = g_cvAmyVisionRadius.FloatValue;

    g_fAmyTS_Val = g_cvAmyTimeScaleVal.FloatValue;
    g_fAmyTS_Acc = g_cvAmyTimeScaleAcc.FloatValue;
    g_fAmyTS_Dur = g_cvAmyTimeScaleDur.FloatValue;
    g_fAmyTS_Rad = g_cvAmyTimeScaleRad.FloatValue;

    g_fAmyDoubleJumpPower = g_cvAmyDoubleJumpPower.FloatValue;

    // v61: cache del impulso de impacto
    g_fAmyImpulseSpeed    = g_cvAmyImpulseSpeed.FloatValue;
    g_fAmyImpulseDuration = g_cvAmyImpulseDuration.FloatValue;
    g_fAmyImpulseMaxDist  = g_cvAmyImpulseMaxDist.FloatValue;
    g_fAmyImpulseRadius   = g_cvAmyImpulseRadius.FloatValue;
    g_bAmyImpulsePushTeam = g_cvAmyImpulsePushTeam.BoolValue;
    g_fAmyImpDmgCommon    = g_cvAmyImpDmgCommon.FloatValue;
    g_fAmyImpDmgSpecial   = g_cvAmyImpDmgSpecial.FloatValue;
    g_fAmyImpDmgWitch     = g_cvAmyImpDmgWitch.FloatValue;
    g_fAmyImpDmgTank      = g_cvAmyImpDmgTank.FloatValue;
}

public void Amy_ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    Amy_UpdateCvars();
}

public void Amy_OnMapStart()
{
    char dbgMap[64];
    GetCurrentMap(dbgMap, sizeof(dbgMap));
    AmyDbg_Log("=== OnMapStart: mapa=%s (precache + resets) ===", dbgMap);

    PrecacheParticle(AMY_PARTICLE_EXP1);
    PrecacheParticle(AMY_PARTICLE_EXP2);
    PrecacheParticle(AMY_PARTICLE_EXP3);

    // VFX v2.0: precachear partículas de las pasivas
    PrecacheParticle(AMY_PARTICLE_FURY_AURA);
    PrecacheParticle(AMY_PARTICLE_JUMP_RING);
    PrecacheParticle(AMY_PARTICLE_WALL_HIT);
    PrecacheParticle(AMY_PARTICLE_MOMENTUM);
    // v65: v64 restauró el burst rosa del golpe pero olvidó su precache
    // (eliminado en v61 junto con el martillo): el motor daba "Attempting
    // to create unknown particle system" en cada golpe.
    PrecacheParticle(AMY_PARTICLE_STRIKE_BURST);

    PrecacheModel(AMY_MODEL_CHUNK, true);
    g_iAmyBeamSprite = PrecacheModel(AMY_SPRITE_BEAM, true);
    g_iAmyHaloSprite = PrecacheModel(AMY_SPRITE_GLOW, true);

    PrecacheSound(AMY_SOUND_EXPLODE, true);
    PrecacheSound(AMY_SOUND_QUAKE, true);
    // v64: sonidos del martillo original restaurados (impacto + swing)
    PrecacheSound(AMY_SOUND_SWING_DEF, true);
    PrecacheSound(AMY_SOUND_HIT_GEN, true);
    PrecacheSound(AMY_SOUND_HIT_TANK, true);

    for (int i = 0; i < sizeof(g_AmyBoneSounds); i++)
        PrecacheSound(g_AmyBoneSounds[i], true);

    for (int i = 0; i < sizeof(g_sAmyJumpSoundsLocal); i++)
        PrecacheSound(g_sAmyJumpSoundsLocal[i], true);

    for (int i = 1; i <= MaxClients; i++)
        Amy_ResetVictim(i);

    // v51: reset defensivo del estado que NO dependía del round_end
    // anterior (changelevel de admin / voto de mapa / finale sin round_end):
    // cooldowns del strike, contadores de salto y el filtro anti-FF global
    // del Poder 2, que podía quedar activo hasta 12s en este mapa nuevo.
    // v61: el estado del impulso son arrays estáticos que se ponen a cero
    // aquí (imposible que quede nada colgado del mapa viejo).
    g_bAmyPowerFFActive = false;
    g_fAmyPowerFFEndTime = 0.0;
    for (int i = 1; i <= MaxClients; i++)
    {
        g_fAmyStrikeCooldown[i] = 0.0;
        g_iAmyJumps[i] = 0;
        // v61: reset del estado del impulso (arrays, no handles).
        // v62: si un impulso quedó a medias (cambio de mapa en plena
        // embestida), devolver el tope de velocidad normal.
        // v63: y el movetype de caminar (nadie empieza el mapa volando).
        if (g_bAmyImpulseActive[i] && IsClientInGame(i))
        {
            if (g_fAmyImpulseSavedMaxSpd[i] > 1.0)
                Amy_ImpulseSetMaxSpeed(i, g_fAmyImpulseSavedMaxSpd[i]);
            SetEntityMoveType(i, MOVETYPE_WALK);
            // v64: y el grupo de colisión (que nadie atraviese cuerpos ya)
            if (g_iAmyImpulseSavedColGroup[i] > 0)
                SetEntProp(i, Prop_Data, "m_CollisionGroup", g_iAmyImpulseSavedColGroup[i]);
            g_iAmyImpulseSavedColGroup[i] = 0;
        }
        g_bAmyImpulseActive[i] = false;
        g_fAmyImpulseEndT[i] = 0.0;
        g_iAmyImpulseHitCount[i] = 0;
        g_fAmyImpulseSavedMaxSpd[i] = 0.0;
        // v66: reset del registro del barrido AOE (el MODO de cada
        // jugador SI se conserva entre mapas: es su preferencia).
        g_fAmySweepStart[i] = 0.0;
        g_iAmySweepHitCount[i] = 0;
    }

    // v73: reset TOTAL del tracker de props lanzados (el monitor murió
    // con el mapa vía NO_MAPCHANGE y los SDKHooks murieron con sus
    // entidades: aquí solo quedan refs muertas que se limpian)
    Amy_PropResetTracker();

    // v86: registro de teñidos limpio (entidades del mapa NUEVO: nada
    // que restaurar) y el flag del escaner a cero (el timer murió con
    // el mapa vía NO_MAPCHANGE)
    Amy_VisionResetAll();
    g_bAmyVisTimerOn = false;

    // Inicializar tracking VFX
    for (int i = 1; i <= MaxClients; i++)
    {
        g_hAmyFuryAuraTimer[i] = null;
        g_hAmyTrailTimer[i] = null;
        g_iAmyFuryAuraEnt[i] = -1;
        g_fAmyLastAuraPulse[i] = 0.0;
    }

    // v92-OM: modelos amy.mdl/hammer.mdl (doble intento MAYUS/min) +
    // sonidos OM + anims por resolver
    Amy_OM_OnMapStart();
}

public void Amy_OnMapEnd()
{
    // v52: log de transición (correlación de crashes con cambios de mapa)
    AmyDbg_Log("=== OnMapEnd: reset del estado del impulso ===");

    // v61: el impulso NO tiene handles (timer con solo userid + arrays
    // estáticos): aquí se pone a cero el estado y ya. El timer del impulso
    // lleva TIMER_FLAG_NO_MAPCHANGE (SM lo mata el solo al girar el mapa) y
    // NO transporta datos (solo un int): nada que liberar, cero fugas.
    // Los kills EN VIVO siguen haciéndolos round_end/round_start/disconnect.
    Amy_FreeStrikeState();

    // v73: reset del tracker de props lanzados (higiene idempotente: el
    // monitor ya murió con el mapa vía NO_MAPCHANGE)
    Amy_PropResetTracker();

    // v86: idem para el registro de teñidos (higiene idempotente: los
    // colores murieron con sus entidades)
    Amy_VisionResetAll();
    g_bAmyVisTimerOn = false;

    // v92-OM: refs del avatar/martillo a cero (las entidades murieron
    // con el mapa; el timer de la FSM es del plugin y sigue vivo)
    Amy_OM_OnMapEnd();
}

// ==============================================================
// UTILIDADES DEL MOTOR DE COMBATE
// ==============================================================

// ============================================================
//  v60 "HAMMER REBORN" - ANIMACION DEL ARMA (RECONSTRUIDA)
//
//  ELIMINADO por completo el viejo sistema (v43-v53):
//  ResetMeleeWeaponState escribía 7 propiedades del ESTADO
//  INTERNO del arma (m_flNextPrimaryAttack, m_flNextAttack,
//  m_flTimeWeaponIdle, m_iNextPrimaryAttackIndex y 3 timers
//  Countdown) y después forzaba IN_ATTACK para que la MAQUINA
//  DE ESTADOS DEL MOTOR ejecutara su swing nativo. Ese es el
//  ÚNICO punto de toda la activación donde entregamos control
//  a C++ interno del engine sobre un arma cuyo estado pudo
//  quedar inconsistente tras la transición de capítulo (el
//  arma se recrea en el mapa nuevo): si la maquina de estados
//  esta corrupta, el crash ocurre DENTRO del motor y ningún
//  guard de SourceMod puede evitarlo. Por eso el rework:
//
//  NUEVO (convar amy_hammer_anim, 0 por defecto):
//   - DESACTIVADO (0): la activación NO toca el arma. Sonido +
//     VFX + barrido, 100% capa SourceMod. La animación de swing
//     no se reproduce (quien quiera verla puede hacer clic
//     izquierdo a la vez que pulsa Z: es exactamente el mismo
//     swing nativo, decidido por el motor, sin intervención).
//   - ACTIVADO (1): fuerza IN_ATTACK durante 1 frame y YA. Sin
//     resetear NADA del arma: si el arma está lista para golpear
//     (como en cualquier clic izquierdo normal), el motor
//     reproduce su swing; si no lo esta, no ocurre nada. Es
//     identico a que el jugador hiciera clic: cero manipulación
//     de estado, cero superficie nueva de crash.
// ============================================================
// v61: ELIMINADA Amy_ForceMeleeAnimation junto a TODO el sistema de
// animación del arma (v43-v60). El impulso de impacto jamás escribe una
// sola propiedad del arma ni fuerza IN_ATTACK: la pieza de la activación
// que entregaba control a la maquina de estados C++ del arma sobre un
// arma recreada tras el cambio de capítulo YA NO EXISTE en Amy.

// ============================================================
//  v3.0 - Animación del Hammer Strike (SISTEMA m_nSequence ELIMINADO)
//
//  HISTORIAL: forzar la secuencia 742 en el viewmodel causaba drift
//  progresivo de cámara (el motor lo interpreta como "target angle").
//  La animación nativa se reproduce sola vía IN_ATTACK forzado (v43/v45)
//  + ResetMeleeWeaponState. v45: eliminadas las 4 funciones no-op que
//  quedaban de ese sistema (generaban warnings de código muerto).
// ============================================================

// =======================
// FUNCIONES AUXILIARES & DETENCION ABSOLUTA
// =======================

public void Amy_SlowThink(int client)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_bIsBoneBroken[client])
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.2);
    }
}

void Amy_ResetVictim(int client)
{
    if (client <= 0 || client > MaxClients) return;

    g_bIsBoneBroken[client] = false;
    g_fAmyDisarmEndTime[client] = 0.0;
    // v64: desarme normal restaurado
    g_bAmyDisarmed[client] = false;
    g_fAmyNormalDisarmEndTime[client] = 0.0;

    // v68: invalidar el monitor de aterrizaje pendiente de este slot
    // (muerte/round/mapa/desconexion): sin tocar handles, el serial ya
    // no cuadra y el timer del monitor se apaga solo en su próximo tick.
    g_iAmyLaunchSerial[client]++;
    g_bAmyLaunchAirborne[client] = false;
    g_fAmyVomitBlockUntil[client] = 0.0;   // v70: ventana de bilis reflejada
    g_bAmyFuryActive[client] = false;
    g_iAmyMomentumStacks[client] = 0;
    g_fAmyMomentumEndTime[client] = 0.0;

    // v61: reset del estado del impulso (arrays, no handles).
    // v62: si el impulso estaba en marcha (muerte/despawn en plena
    // embestida), devolver el tope de velocidad normal antes de limpiar.
    // v63: y el movetype de caminar (que no quede nadie flotando).
    if (g_bAmyImpulseActive[client] && IsClientInGame(client))
    {
        if (g_fAmyImpulseSavedMaxSpd[client] > 1.0)
            Amy_ImpulseSetMaxSpeed(client, g_fAmyImpulseSavedMaxSpd[client]);
        SetEntityMoveType(client, MOVETYPE_WALK);
        // v64: y el grupo de colisión (que nadie atraviese cuerpos ya)
        if (g_iAmyImpulseSavedColGroup[client] > 0)
            SetEntProp(client, Prop_Data, "m_CollisionGroup", g_iAmyImpulseSavedColGroup[client]);
        g_iAmyImpulseSavedColGroup[client] = 0;
    }
    g_bAmyImpulseActive[client] = false;
    g_fAmyImpulseEndT[client] = 0.0;
    g_iAmyImpulseHitCount[client] = 0;
    g_fAmyImpulseSavedMaxSpd[client] = 0.0;

    // v3.0: limpiar Jump Damage Bonus
    g_bAmyJumpDmgActive[client] = false;
    g_fAmyJumpDmgEndTime[client] = 0.0;

    // v3.0: limpiar Hammer Jump (es poder aleatorio)
    g_bAmyHammerJumpActive[client] = false;
    g_fAmyHammerJumpEndTime[client] = 0.0;

    if (IsClientInGame(client))
    {
        SDKUnhook(client, SDKHook_PreThink, Amy_SlowThink);
        // v3.0: unhook OnTakeDamage si estaba activo
        if (g_bAmyHookedOnTakeDmg[client])
        {
            SDKUnhook(client, SDKHook_OnTakeDamage, Amy_VictimTakeDamage);
            g_bAmyHookedOnTakeDmg[client] = false;
        }
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
}

// ============================================================
//  v3.0 - Sistema de Desarme + Vulnerability + Execute
// ============================================================

// Aplica desarme normal (2s) tras golpe seco sin pared.
// NO aplica bone break, solo vulnerability (+50% daño recibido de todas las fuentes).
// v61: ELIMINADO el sistema de desarme normal (2s) del martillo
// (Amy_ApplyNormalDisarm + T_AmyClearDisarm + g_bAmyDisarmed):
// era exclusivo del golpe sin pared. El bone-break del TERREMOTO del
// Poder 2 se conserva intacto (mismos hooks, mismo timer de reset).

// Hook de daño en la víctima: multiplica daño si está bone-broken
public Action Amy_VictimTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!IsValidClient(victim)) return Plugin_Continue;
    if (GetClientTeam(victim) != TEAM_INFECTED) return Plugin_Continue;

    // Si está desarmado (normal, v64) o bone-broken: +50% daño de TODAS las fuentes
    if (g_bIsBoneBroken[victim] || g_bAmyDisarmed[victim])
    {
        damage *= AMY_VULNERABILITY_MULT;
        return Plugin_Changed;
    }

    return Plugin_Continue;
}

void Amy_DisableInfectedAbility(int client, float duration)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    int ability = GetEntPropEnt(client, Prop_Send, "m_customAbility");
    if (ability > 0 && IsValidEntity(ability))
    {
        SetEntPropFloat(ability, Prop_Send, "m_timestamp", GetGameTime() + duration);
    }
}

// ============================================================
//  v68 - LANZAMIENTO DE VICTIMAS ("levantamiento") + STAGGER AL
//  ATERRIZAR. Petición del usuario (2 cosas):
//   1) MEJORA DEL EMPUJE: el empuje de Amy ahora levanta DE VERDAD a
//      la victima: sale volando con arco. Hasta v67 el impacto aplicaba
//      el stagger (tambaleo) EN EL MISMO FRAME y el estado "stumble"
//      del motor pisaba la velocidad: la victima se tambaleaba en el
//      sitio y el levantamiento no funcionaba ("si se usa el stagger
//      no funciona el levantamiento").
//   2) EL GOLPE YA NO DA STAGGER AL IMPACTAR: lo da AL ATERRIZAR, con
//      todos los tipos de infectados (especiales y tank por este
//      camino; la witch vía su stun de aterrizaje en Witch_Flight
//      v2.5; comunes y boomer mueren/estallan con el golpe).
//
//  FLUJO (mismos patrones anti-crash de siempre):
//   - frame 0 (impacto): el dano lo aplica el caller ANTES de esta
//     llamada; aquí frenamos en seco la velocidad ACTUAL de la victima
//     (un charger cargando queda parado YA) y diferimos el lanzamiento
//     0.05s (no tocar la maquina de estados en el mismo frame que el
//     dano: lección v49/v51).
//   - +0.05s: TELEPORT con la velocidad de vuelo (arco), liberación de
//     agarres de Amy por el camino del motor (PinRelease v50) y bloqueo
//     de la habilidad de la victima 5s. SIN stagger aquí (era la pieza
//     que anulaba el vuelo).
//   - monitor de aterrizaje (tick 0.1s): espera el vuelo y cuando la
//     victima VUELVE a tocar suelo aplica el stagger seguro
//     (SIStagger_Auto: red de recuperación anti "bot tirado para
//     siempre" del modulo SI_Stagger). Redes de seguridad: si nunca
//     despega (pared pegada: grace 0.45s) o el vuelo se alarga
//     (timeout 4s), el stagger se aplica igual. Muerte en vuelo /
//     desconexion / cambio de equipo: el monitor se apaga solo, sin
//     stagger.
//
//  SEGURIDAD:
//   - timers userid-only + TIMER_FLAG_NO_MAPCHANGE + DATA_HNDL_CLOSE
//     (SM los mata y cierra su pack en el cambio de mapa): CERO
//     handles guardados -> imposible el "Invalid timer handle" que
//     abortaba el OnMapStart (lecciones v17).
//   - re-lanzamiento (re-golpe, contra, terremoto...): cada
//     lanzamiento sube g_iAmyLaunchSerial[victim]; el monitor viejo ve
//     el serial desfasado y se apaga al primer tick (nunca dos
//     monitores vivos por victima).
//   - Amy_ResetVictim sube el serial: muerte/round/mapa/desconexion
//     invalidan cualquier monitor pendiente sin tocar handles.
// ============================================================
void Amy_ApplyHardStopFling(int attacker, int victim, float pushDir[3])
{
    if (!Amy_IsValidClient(attacker) || !Amy_IsValidClient(victim)) return;

    // Frenado en seco de la velocidad ACTUAL (detiene cargas y
    // embestidas en el acto); el lanzamiento llega 0.05s después.
    float zeroVel[3] = {0.0, 0.0, 0.0};
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, zeroVel);

    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(attacker));
    dp.WriteCell(GetClientUserId(victim));
    dp.WriteFloat(pushDir[0]);
    dp.WriteFloat(pushDir[1]);
    dp.WriteFloat(pushDir[2]);
    // v51: TIMER_DATA_HNDL_CLOSE - si el mapa gira dentro de estos 0.05s,
    // el SourceMod cierra el DataPack al matar el timer (antes: leak).
    CreateTimer(0.05, T_AmyHardStopSpecial, dp, TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
}

public Action T_AmyHardStopSpecial(Handle timer, DataPack pack)
{
    pack.Reset();
    int attacker = GetClientOfUserId(pack.ReadCell());
    int victim = GetClientOfUserId(pack.ReadCell());
    float pushDir[3];
    pushDir[0] = pack.ReadFloat();
    pushDir[1] = pack.ReadFloat();
    pushDir[2] = pack.ReadFloat();
    // v51: el pack lo cierra TIMER_DATA_HNDL_CLOSE al terminar el timer
    // (kill por mapa incluido) - el delete manual duplicaba el cierre.

    if (Amy_IsValidClient(attacker) && Amy_IsValidClient(victim))
    {
        // v68: LANZAMIENTO puro. El stagger que iba aquí EN EL MISMO
        // FRAME era justo lo que anulaba el vuelo (el estado stumble
        // del motor re-escribe la locomoción del bot): ahora la victima
        // SALE VOLANDO y el stagger llega AL ATERRIZAR.
        // (v49: L4D2_CTerrorPlayer_Fling sigue PROHIBIDO: el SDKCall
        // crudo con anim 76 + incapTime sobre estados transicionales es
        // el crash documentado del motor; esto es solo velocidad.)
        TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, pushDir);

        // v48/v50: liberar a Amy del agarre por el CAMINO DEL MOTOR:
        // PinRelease v2.0 invoca a las funciones nativas de liberación
        // (L4D_Hunter_ReleaseVictim, L4D2_Jockey_EndRide, etc) que
        // ejecutan el fin de agarre completo del motor, sin estados
        // rotos (era la causa real del cierre del juego con el
        // martillo v1-v47).
        PinRelease_Cleanse(attacker);

        Amy_DisableInfectedAbility(victim, 5.0);

        // v68: stagger AL ATERRIZAR (monitor de vuelo por victima)
        Amy_LaunchBeginMonitor(victim, attacker);

        AmyDbg_Log("[LANZADO v68] victim=%d vel=(%.0f, %.0f, %.0f): vuela y se tambalea al caer",
                   victim, pushDir[0], pushDir[1], pushDir[2]);
    }
    return Plugin_Stop;
}

// v68: arranca el monitor de aterrizaje de una victima lanzada. El
// serial por slot invalida monitores anteriores (re-golpe/re-contra) y
// el NO_MAPCHANGE mata el timer en el cambio de mapa: cero handles.
static void Amy_LaunchBeginMonitor(int victim, int attacker)
{
    if (victim <= 0 || victim > MaxClients) return;

    g_iAmyLaunchSerial[victim]++;
    g_bAmyLaunchAirborne[victim] = false;

    int srcUid = 0;
    if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
        srcUid = GetClientUserId(attacker);

    DataPack dp = new DataPack();
    dp.WriteCell(victim);                    // slot (para el serial)
    dp.WriteCell(GetClientUserId(victim));   // validez al disparar
    dp.WriteCell(g_iAmyLaunchSerial[victim]);// serial de ESTE lanzamiento
    dp.WriteCell(srcUid);                    // fuente del stagger (Amy)
    dp.WriteFloat(GetEngineTime());          // inicio del vuelo

    CreateTimer(AMY_LAUNCH_MONITOR_TICK, T_AmyLaunchMonitor, dp,
                TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
}

// v68: monitor de vuelo de una victima lanzada por el empuje de Amy.
// El stagger SOLO se aplica al tocar el suelo (petición: "no al
// impactar, si no cuando aterrice al piso, con todos los tipos").
public Action T_AmyLaunchMonitor(Handle timer, DataPack dp)
{
    dp.Reset();
    int slot   = dp.ReadCell();
    int userid = dp.ReadCell();
    int serial = dp.ReadCell();
    int srcUid = dp.ReadCell();
    float startT = dp.ReadFloat();

    int client = GetClientOfUserId(userid);

    // Desconecto / slot reciclado / re-lanzada (serial nuevo) / murió
    // en pleno vuelo / dejó de ser infectado: nada que tambalear.
    if (client <= 0 || client != slot
        || g_iAmyLaunchSerial[client] != serial
        || !IsClientInGame(client) || !IsPlayerAlive(client)
        || GetClientTeam(client) != TEAM_INFECTED)
    {
        return Plugin_Stop;
    }

    float now = GetEngineTime();

    // Red de seguridad: nunca más de AMY_LAUNCH_MAX_AIR en el aire
    if (now - startT > AMY_LAUNCH_MAX_AIR)
    {
        Amy_LaunchDoStagger(client, srcUid);
        return Plugin_Stop;
    }

    bool onGround = (GetEntityFlags(client) & FL_ONGROUND) != 0;

    if (!onGround)
    {
        // en pleno vuelo: recordarlo (el stagger solo cuenta tras volar)
        g_bAmyLaunchAirborne[client] = true;
        return Plugin_Continue;
    }

    // En suelo: o aún no ha despegado (primeros ticks tras el
    // lanzamiento: grace) o YA ATERRIZO -> stagger al caer al piso.
    if (!g_bAmyLaunchAirborne[client] && (now - startT) < AMY_LAUNCH_GROUND_GRACE)
    {
        return Plugin_Continue;
    }

    Amy_LaunchDoStagger(client, srcUid);
    return Plugin_Stop;
}

// v68: el stagger de aterrizaje (el MISMO stagger seguro de siempre:
// SIStagger_Auto elige 1.8s/3.0s según clase y programa la
// recuperación garantizada del bot vía L4D_CancelStagger).
static void Amy_LaunchDoStagger(int client, int srcUid)
{
    int source = GetClientOfUserId(srcUid);
    int srcEnt = (source > 0 && source <= MaxClients && IsClientInGame(source)) ? source : client;

    float srcPos[3];
    GetClientAbsOrigin(srcEnt, srcPos);

    SIStagger_Auto(client, srcEnt, srcPos);
    AmyDbg_Log("[ATERRIZO v68] victim=%d tocó el suelo: stagger aplicado", client);
}

public Action T_AmyResetSpeed(Handle timer, int ref)
{
    int enemy = EntRefToEntIndex(ref);
    if (enemy > 0 && enemy <= MaxClients && IsClientInGame(enemy))
        Amy_ResetVictim(enemy);
    return Plugin_Stop;
}

// v61: ELIMINADOS Amy_CheckWallImpact + Amy_TraceFilter_World (eran del
// "rompe-huesos contra pared" del martillo). El impulso detecta la pared
// delante con Amy_TraceFilter_LOS + MASK_SOLID (mundo/props/puertas, sin
// criaturas) desde la altura de los ojos.

// =======================
// Eventos y Limpieza
// =======================

public void Amy_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    AmyDbg_Log("=== round_end: reset de timers/victimas ===");
    Amy_ClearAllTimers();
    for (int i = 1; i <= MaxClients; i++) Amy_ResetVictim(i);

    // v51: el filtro anti-FF del Poder 2 es ESTADO GLOBAL (no por cliente):
    // sin esto sobrevivia al cambio de ronda y bloqueaba fuego amigo hasta
    // 12s dentro de la ronda nueva.
    g_bAmyPowerFFActive = false;
    g_fAmyPowerFFEndTime = 0.0;

    // v86: los objetos teñidos recuperan su color al cerrar la ronda
    // (si una Amy sigue viva, el escaner los re-teñe al siguiente tick)
    Amy_VisionResetAll();
}

// ============================================================================
//  v51 - RESET TOTAL AL COMENZAR UNA RONDA NUEVA (la pieza que faltaba)
//
//  AUDITORIA cruzada de rondas (reporte del usuario: crash del martillo en
//  el capítulo siguiente de la campaña): se auditó TODO el estado global del
//  modulo y había 4 huecos de estado residual que sobrevivian al cambio de
//  mapa/round. Este handler los cierra TODOS de una vez, y corre en cada
//  round_start (nuevo capítulo = round_end + cambio de mapa + round_start):
//
//    1. Timers por cliente (salto + cooldown del Poder 2) -> ya los mataba
//       round_end, aquí van de nuevo por si el mapa giro sin round_end
//       (changelevel de admin, voto de mapa, fin de finale).
//    2. Hitlists del strike (g_hAmySwingHits): antes SOLO se liberaban en
//       OnMapEnd. Si OnMapEnd no corria (error en otro modulo aborta el
//       forward compartido del manager), quedaban colgadas toda la ronda.
//    3. Filtro anti-FF GLOBAL (g_bAmyPowerFFActive): quedaba activo hasta
//       12s dentro de la ronda nueva (bloqueaba dano a survivors que no
//       venía de ningún poder).
//    4. Cooldowns y contadores por slot (strike, saltos, botones): valores
//       de la ronda anterior en slots que pueden ocupar otros jugadores.
//
//  Nota: el strike en si no se toca aquí (el timer del swing muere solo:
//  REPEAT de 0.5s max). Los DataPacks de hard-stop/monitor/cooldown ahora
//  llevan TIMER_DATA_HNDL_CLOSE (v51): si el mapa gira a mitad, el motor
//  del SourceMod los cierra el solo - cero leaks.
// ============================================================================
public void Amy_Event_RoundStart_Full(Event event, const char[] name, bool dontBroadcast)
{
    char dbgMap[64];
    GetCurrentMap(dbgMap, sizeof(dbgMap));
    AmyDbg_Log("=== round_start en mapa=%s: RESET TOTAL (timers+hitlists+cooldowns) ===", dbgMap);

    Amy_ClearAllTimers();
    Amy_FreeStrikeState();

    // v86: objetos del mapa NUEVO: registro de teñidos a cero
    Amy_VisionResetAll();

    for (int i = 1; i <= MaxClients; i++)
    {
        Amy_ResetVictim(i);
        g_fAmyStrikeCooldown[i] = 0.0;
        g_iAmyJumps[i] = 0;
        g_iAmyLastButtons[i] = 0;
        // v45/v51: cooldown del Poder 2 y Hammer Jump también por slot
        g_fAmyPower2LastUse[i] = 0.0;
        g_bAmyHammerJumpActive[i] = false;
        g_fAmyHammerJumpEndTime[i] = 0.0;
    }

    g_bAmyPowerFFActive = false;
    g_fAmyPowerFFEndTime = 0.0;
}

// v51/v61: resetea el estado residual de impulsos que no terminaron
// por su camino normal (mapa girado a mitad del impulso / forward
// abortado). v61: sin handles - solo arrays y timestamps.
// Idempotente y sin riesgo alguno.
void Amy_FreeStrikeState()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        // v62: restaurar el tope de velocidad si la embestida quedó a
        // medias (forward abortado / transición rara). v63: y el movetype.
        if (g_bAmyImpulseActive[i] && IsClientInGame(i))
        {
            if (g_fAmyImpulseSavedMaxSpd[i] > 1.0)
                Amy_ImpulseSetMaxSpeed(i, g_fAmyImpulseSavedMaxSpd[i]);
            SetEntityMoveType(i, MOVETYPE_WALK);
            // v64: y el grupo de colisión (que nadie atraviese cuerpos ya)
            if (g_iAmyImpulseSavedColGroup[i] > 0)
                SetEntProp(i, Prop_Data, "m_CollisionGroup", g_iAmyImpulseSavedColGroup[i]);
            g_iAmyImpulseSavedColGroup[i] = 0;
        }
        g_bAmyImpulseActive[i] = false;
        g_fAmyImpulseEndT[i] = 0.0;
        g_iAmyImpulseHitCount[i] = 0;
        g_fAmyImpulseSavedMaxSpd[i] = 0.0;
        // v66: y el registro del barrido AOE (cero handles: solo olvidar).
        g_fAmySweepStart[i] = 0.0;
        g_iAmySweepHitCount[i] = 0;
    }
}

public Action Amy_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        if (g_hAmyJumpTimer[client] != null)
        {
            delete g_hAmyJumpTimer[client];
            g_hAmyJumpTimer[client] = null;
        }
        Amy_ResetVictim(client);
    }
    return Plugin_Continue;
}

public Action Amy_Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        // v45 FIX (handles colgados): si el jugador se va con un Hammer Jump
        // o el cooldown del Poder 2 en curso, el slot queda con handles
        // muertos; el siguiente ocupante del slot provocaria "Invalid Handle"
        // al usar la habilidad. El evento de disconnect SIEMPRE llega antes
        // del siguiente tick del timer, así que aquí siguen vivos y se
        // pueden matar con seguridad.
        if (g_hAmyJumpTimer[client] != null)
        {
            delete g_hAmyJumpTimer[client];
            g_hAmyJumpTimer[client] = null;
        }
        if (g_hAmyPower2Timer[client] != null)
        {
            // v51: sin autoClose - el pack se cierra por TIMER_DATA_HNDL_CLOSE
            KillTimer(g_hAmyPower2Timer[client]);
            g_hAmyPower2Timer[client] = null;
        }

        Amy_ResetVictim(client);
        // v66: el modo es preferencia de SESION: el siguiente ocupante del
        // slot empieza en IMPULSO (defecto) y el registro queda limpio.
        g_iAmyAbilityMode[client] = 0;
        g_fAmySweepStart[client] = 0.0;
        g_iAmySweepHitCount[client] = 0;
        // v78: banderas de diagnostico limpias para el próximo ocupante
        g_bAmyPropHintShown[client] = false;
        g_bAmySweepFirstTick[client] = false;
        // v108: la preferencia del bumeran también es de SESION — el
        // próximo ocupante del slot arranca del default de fábrica
        g_bAmyOMBoomPrefInit[client] = false;
        g_bAmyOMBoomPref[client] = (g_cvAmyOMBoomMode != null && g_cvAmyOMBoomMode.BoolValue);
    }
    return Plugin_Continue;
}

public void Amy_Event_PlayerSpawn(Event event, const char[] name, int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    g_fAmyStrikeCooldown[client] = 0.0;
    Amy_ResetVictim(client);

    g_iAmyJumps[client] = 0;

    if (AreClientCookiesCached(client)) Amy_LoadSoundPreference(client);

    SDKUnhook(client, SDKHook_OnTakeDamage, Amy_OnTakeDamage_Passive);
    SDKUnhook(client, SDKHook_PreThink, Amy_PreThink);

    if (g_iPlayerCharIdx[client] == AMY_INDEX)
    {
        SDKHook(client, SDKHook_OnTakeDamage, Amy_OnTakeDamage_Passive);
        SDKHook(client, SDKHook_PreThink, Amy_PreThink);

        // v92-OM: reset del slot OM (por si la vida anterior dejo la
        // ventana abierta o el martillo volando) + cartas iniciales
        // (GMod: CardSwitch_om en el initialize — Amy NACE con 2 cartas)
        g_fAmyOMCounterUntil[client] = 0.0;
        g_bAmyOMCounterMissed[client] = false;
        g_bAmyOMThrowArmed[client] = false;
        g_fAmyOMThrowCDUntil[client] = 0.0;
        g_fAmyOMEndLagUntil[client] = 0.0;
        Amy_OM_HammerKill(client);
        if (g_iAmyTarotCard1[client] < 0)
            Amy_OM_TarotDraw(client, true);

        // v108: la preferencia de modo del martillo arranca del convar
        // (amyom_boom_mode = default de fábrica) y de ahi la B la mueve.
        // SOLO la primera vez de la conexion: la elección de la B
        // SOBREVIVE respawns (es una preferencia, como el modo de la C)
        if (!g_bAmyOMBoomPrefInit[client])
        {
            g_bAmyOMBoomPref[client] = (g_cvAmyOMBoomMode != null && g_cvAmyOMBoomMode.BoolValue);
            g_bAmyOMBoomPrefInit[client] = true;
        }

        // v72: publicar el índice de Amy en VScript (::SonicAmyIdx) para que
        // el addon "Lanzamiento de martillo v2" restrinja el lanzamiento del
        // martillo SOLO a Amy y active su homing. Se publica en cada spawn;
        // si este jugador NO es Amy pero ocupa el índice, se limpia.
        Amy_PublishScriptIdx(client, true);

        // v87/v88/v89: AURA AUTOMÁTICA — nada que activar: el escaner
        // enciende solo y rodea de aura todo lo que este a 700 (v89)
        Amy_VisionEnsureTimer();
        if (!g_bAmyVisHintShown[client])
        {
            g_bAmyVisHintShown[client] = true;
            PrintToChat(client, "\x04[AMY]\x01 AURA (automática, radio %.0f): \x03VERDE = inyectable\x01 (sm_amyfisica) | \x03ROJO = empujable\x01 (con V). \x04SOLO Amy y Sage la ven\x01 (a través de paredes).", g_fAmyVisRadius);
        }
    }
    else
    {
        // v72: limpia el índice si este slot era la Amy publicada (cambio de
        // personaje o jugador nuevo en el mismo slot).
        Amy_PublishScriptIdx(client, false);
    }
}

void Amy_LoadSoundPreference(int client)
{
    if (client <= 0 || client > MaxClients) return;
    if (g_hAmySoundCookie == INVALID_HANDLE) return;

    char sValue[8]; GetClientCookie(client, g_hAmySoundCookie, sValue, sizeof(sValue));
    if (sValue[0] != '\0') g_iAmySoundChoice[client] = StringToInt(sValue);
    else g_iAmySoundChoice[client] = -1;
}

// =======================
// PRETHINK: LÓGICA PRINCIPAL Y PASIVAS
// =======================

public void Amy_PreThink(int client)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return;

    float now = GetEngineTime();

    // 1. GESTIONAR FURIA PROTECTORA (expiración)
    if (g_bAmyFuryActive[client] && now > g_fAmyFuryEndTime[client])
    {
        g_bAmyFuryActive[client] = false;
        // Aviso de expiración
        PrintHintText(client, "<font color='#FF80C0' size='18'>La Furia Protectora se ha calmando</font>");
    }

    // VFX v3.0: aura rosa pulsante + screen overlay mientras Furia está activa
    if (g_bAmyFuryActive[client])
    {
        Amy_VFX_FuryAura(client);
        Amy_VFX_FuryOverlay(client);
    }

    // 2. GESTIONAR MOMENTUM (expiración y refresh)
    if (g_iAmyMomentumStacks[client] > 0 && now > g_fAmyMomentumEndTime[client])
    {
        g_iAmyMomentumStacks[client] = 0;
        PrintHintText(client, "<font color='#FF80C0' size='18'>Momentum Piko Piko perdido</font>");
    }

    // 2.5 GESTIONAR JUMP DAMAGE BONUS (expiración)
    if (g_bAmyJumpDmgActive[client] && now > g_fAmyJumpDmgEndTime[client])
    {
        g_bAmyJumpDmgActive[client] = false;
    }

    // 2.6 GESTIONAR HAMMER JUMP (expiración - es poder aleatorio)
    if (g_bAmyHammerJumpActive[client] && now > g_fAmyHammerJumpEndTime[client])
    {
        g_bAmyHammerJumpActive[client] = false;
    }

    // VFX v3.0: HUD refresh de Momentum (cada 0.2s)
    if (g_iAmyMomentumStacks[client] > 0)
    {
        Amy_VFX_MomentumHUD(client);
    }

    // 3. ADRENALINA DEL MARTILLO + MOMENTUM (sin frenado al empuÃ±ar melee)
    // (v44: la variable `buttons` y la lógica de doble salto se movieron a
    //  Amy_OnPlayerRunCmd para usar los buttons reales del frame y evitar
    //  el reset prematuro por FL_ONGROUND.)
    int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
    bool isMelee = false;

    if (weapon > 0 && IsValidEntity(weapon))
    {
        char wepName[32];
        GetEntityClassname(weapon, wepName, sizeof(wepName));
        if (StrContains(wepName, "melee") != -1 || StrContains(wepName, "chainsaw") != -1) isMelee = true;
    }

    // VFX v3.0: trail rosa mientras Amy corre con melee + Momentum/Furia
    if (isMelee && (g_bAmyFuryActive[client] || g_iAmyMomentumStacks[client] > 0))
    {
        Amy_VFX_RunTrail(client);
    }

    // Calcular multiplicador de velocidad total
    float speedMult = 1.0;

    // Furia Protectora: +35% velocidad
    if (g_bAmyFuryActive[client]) speedMult *= AMY_FURY_SPEED_MULT;

    // Piko Piko Momentum: +8% por stack (max +80%)
    if (g_iAmyMomentumStacks[client] > 0)
        speedMult *= 1.0 + (float(g_iAmyMomentumStacks[client]) * AMY_MOMENTUM_SPEED_BONUS);

    // v92-OM: CARTAS DEL TAROT (Emperador +15%, Fuerza -20%, Loco +10%,
    // Luna +-15% — la conversión de los +-90/60/40 del GMod)
    speedMult *= Amy_OM_TarotSpeedMult(client);

    // Aplicar velocidad
    if (isMelee)
    {
        // Mientras empuÃ±a melee, SIEMPRE se aplica el multiplicador (sin frenado)
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speedMult);
    }
    else
    {
        // Sin melee: se aplica si DIFFIERE de 1.0 (v92-OM: las cartas
        // Fuerza/Luna pueden BAJAR la velocidad — antes cualquier valor
        // <1 se reseteaba y el debuff de la carta no actuaba; el caso
        // sin furia/momentum/cartas sigue escribiendo 1.0 como siempre)
        if (speedMult != 1.0)
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speedMult);
        else
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }

}

// PASIVA: Furia Protectora + reducción de dano
public Action Amy_OnTakeDamage_Passive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Amy_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != AMY_INDEX) return Plugin_Continue;

    // NOTA: El sistema Diva Body fue reemplazado por Doll_System.inc
    // (sistema modular por SteamID con menú !dollmenu)
    // Ya no se procesa aquí.

    // v92-OM: CARTAS DEL TAROT — multiplicador de dano recibido
    // (RetrieveDamageReduction del GMod: Emperador 0.85 aguanta más,
    // Fuerza 1.15 suena más, Luna 1.15|0.85 según el robo)
    float tarotMult = Amy_OM_TarotDmgMult(victim);
    if (tarotMult != 1.0)
    {
        damage *= tarotMult;
        // (no vuelve aún: la Furia puede apilar abajo)
    }

    // Reducción de dano si la Furia está activa (v108: comentario
    // corregido — AMY_FURY_RESIST_MULT 0.70 = -30%, el "-10%" viejo
    // era del valor anterior; lo que ve el jugador en los mensajes ya
    // se calcula con la constante, no con este texto)
    if (g_bAmyFuryActive[victim])
    {
        damage *= AMY_FURY_RESIST_MULT;
    }
    if (tarotMult != 1.0 || g_bAmyFuryActive[victim])
        return Plugin_Changed;
    return Plugin_Continue;
}

// =======================
// PASIVA: FURIA PROTECTORA (Detección de dano al equipo + Bono de dano)
// =======================

public void Amy_Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));

    // Validaciones básicas
    if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)) return;

    // 1. Si un compañero recibe dano de un infectado -> Amy entra en Furia
    if (GetClientTeam(victim) == TEAM_SURVIVOR && attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == TEAM_INFECTED)
    {
        float vPos[3], aPos[3];
        GetClientAbsOrigin(victim, vPos);

        for (int i = 1; i <= MaxClients; i++)
        {
            if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
            if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
            if (g_iPlayerCharIdx[i] != AMY_INDEX) continue;
            if (i == victim) continue;

            GetClientAbsOrigin(i, aPos);
            if (GetVectorDistance(vPos, aPos) <= AMY_FURY_RADIUS)
            {
                if (!g_bAmyFuryActive[i])
                {
                    // VFX v3.0: mensaje más impactante con HTML
                    PrintHintText(i,
                        "<font color='#FF00FF' size='28'>>> FURIA PROTECTORA <<</font>\n\
<font color='#FF80C0'>¡Un aliado ha sido herido cerca tuyo!</font>\n\
<font color='#FFFFFF'>+%d%% Velocidad  |  +%d%% Daño  |  -%d%% Daño Recibido</font>",
                        RoundToNearest((AMY_FURY_SPEED_MULT - 1.0) * 100.0),
                        RoundToNearest((AMY_FURY_DMG_MULT - 1.0) * 100.0),
                        RoundToNearest((1.0 - AMY_FURY_RESIST_MULT) * 100.0));
                    EmitSoundToClient(i, "player/survivor/voice/gambler/relayreactivate04.wav");

                    // VFX: ring grande rosa al activar Furia
                    float aPos2[3];
                    GetClientAbsOrigin(i, aPos2);
                    aPos2[2] += 30.0;
                    Amy_VFX_BeamRing(aPos2, 10.0, 300.0,
                                     AMY_COLOR_PINK_R, AMY_COLOR_PINK_G, AMY_COLOR_PINK_B, 255,
                                     0.8, 10.0);
                }
                g_bAmyFuryActive[i] = true;
                g_fAmyFuryEndTime[i] = GetEngineTime() + AMY_FURY_DURATION;
            }
        }
    }

    // 2. Bono de dano si Amy pega a un infectado especial con Furia activa
    //    + acumular stacks de Momentum
    if (GetClientTeam(victim) == TEAM_INFECTED && attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR)
    {
        if (g_iPlayerCharIdx[attacker] == AMY_INDEX)
        {
            char weaponName[32];
            event.GetString("weapon", weaponName, sizeof(weaponName));

            bool isMeleeHit = (StrContains(weaponName, "melee") != -1 ||
                               StrContains(weaponName, "katana") != -1 ||
                               StrContains(weaponName, "machete") != -1 ||
                               StrContains(weaponName, "bat") != -1 ||
                               StrContains(weaponName, "crowbar") != -1 ||
                               StrContains(weaponName, "pan") != -1 ||
                               StrContains(weaponName, "axe") != -1 ||
                               StrContains(weaponName, "guitar") != -1 ||
                               StrContains(weaponName, "tonfa") != -1 ||
                               StrContains(weaponName, "club") != -1 ||
                               StrContains(weaponName, "knife") != -1 ||
                               StrContains(weaponName, "shovel") != -1 ||
                               StrContains(weaponName, "pitchfork") != -1);

            if (isMeleeHit)
            {
                // Bono de Furia: +50% dano
                if (g_bAmyFuryActive[attacker])
                {
                    int dmg = event.GetInt("dmg_health");
                    SDKHooks_TakeDamage(victim, attacker, attacker, float(dmg) * 0.5, DMG_CLUB);
                }

                // Piko Piko Momentum: +1 stack (max 5)
                if (g_iAmyMomentumStacks[attacker] < AMY_MOMENTUM_MAX_STACKS)
                {
                    g_iAmyMomentumStacks[attacker]++;
                    // v48: texto con los valores REALES del rework
                    // (+8%% velocidad y +5%% dano por stack; el texto
                    // viejo decía "+5%%" a secas y estaba desactualizado).
                    PrintCenterText(attacker, "MOMENTUM PIKO PIKO x%d  (+%d%% vel, +%d%% dano)",
                        g_iAmyMomentumStacks[attacker],
                        RoundToNearest(g_iAmyMomentumStacks[attacker] * AMY_MOMENTUM_SPEED_BONUS * 100.0),
                        RoundToNearest(g_iAmyMomentumStacks[attacker] * AMY_MOMENTUM_DMG_BONUS * 100.0));

                    // VFX v2.0: chispa rosa al ganar stack
                    Amy_VFX_Momentum(attacker, g_iAmyMomentumStacks[attacker]);
                }
                // Refrescar duración
                g_fAmyMomentumEndTime[attacker] = GetEngineTime() + AMY_MOMENTUM_DURATION;
            }
        }
    }

    // ============================================================
    //  FILTRO ANTI-FRIENDLY FIRE PARA PODERES ALEATORIOS
    //  Usamos SDKHook_OnTakeDamage que intercepta TODO el daño
    //  (incluido point_hurt del Super Tank) antes de aplicarse.
    //  Ver Amy_PowerFF_OnTakeDamage más abajo.
    // ============================================================
}

// Hook de spawn para hookear SDKHook_OnTakeDamage en survivors
void Amy_Event_PlayerSpawn_FF(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients && IsClientInGame(client)) {
        SDKHook(client, SDKHook_OnTakeDamage, Amy_PowerFF_OnTakeDamage);
    }
}

// Este hook intercepta TODO el daño antes de que se aplique.
// Si Amy tiene un poder activo y la víctima es survivor, bloquea el daño
// QUE VIENE DE LAS HABILIDADES del Super Tank (v71).
//
// v71 - ANTI-FF INTELIGENTE: antes se ponía a 0 TODO el daño a survivors
// durante los 12s de ventana, incluido el daño REAL de infectados
// especiales, tank, witch y comunes. Eso (a) dejaba al equipo invulnerable
// 12s y (b) impedía que el hook de daño VScript de los escudos del tarot
// (ReflectShield / ReflecShieldOvl / DisarmShield, que exige damageDone>0)
// reaccionara JAMÁS contra un infectado especial ("los escudos no
// funcionan contra un SI"). Ahora solo se bloquea el daño cuyo atacante
// NO es un infectado del juego (point_hurt / env_explosion / inferno /
// props de las habilidades); el daño real de SI/tank/witch/comunes pasa
// y los escudos pueden reflejarlo/absorberlo/aturdirlo.
public Action Amy_PowerFF_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
    // v82 - PROPS AMIGOS (SIEMPRE activo, sin ventana de FF): un
    // survivor golpeado por un objeto LANZADO POR AMY no paga nada
    // (tampoco la propia Amy). La protección es SOLO del golpe de
    // Amy: si el objeto lo golpeo el TANK, el dano PASA (regla del
    // owner). Ver Amy_PropBlocksSurvivorDamage.
    if (victim > 0 && victim <= MaxClients && IsClientInGame(victim)
        && GetClientTeam(victim) == TEAM_SURVIVOR
        && Amy_PropBlocksSurvivorDamage(attacker, inflictor))
    {
        AmyDbg_Log("[PROPS v82] dano a survivor %d por un prop de Amy BLOQUEADO", victim);
        return Plugin_Handled;
    }

    if (!g_bAmyPowerFFActive) return Plugin_Continue;
    if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)) return Plugin_Continue;
    if (GetClientTeam(victim) != TEAM_SURVIVOR) return Plugin_Continue;

    // Verificar si el filtro sigue activo
    float now = GetEngineTime();
    if (now > g_fAmyPowerFFEndTime) {
        g_bAmyPowerFFActive = false;
        return Plugin_Continue;
    }

    // v71: ¿el daño es del JUEGO (infectado real) o de una habilidad?
    // - Garra/puño de un SI o del TANK: atacante = player del equipo 3.
    // - Witch / common: atacante = entidad "witch" / "infected".
    // Eso pasa SIEMPRE (el juego sigue justo y los escudos reaccionan).
    if (attacker > 0)
    {
        if (attacker <= MaxClients)
        {
            if (IsClientInGame(attacker) && GetClientTeam(attacker) == TEAM_INFECTED)
                return Plugin_Continue;
        }
        else
        {
            char atkCls[24];
            if (GetEntityClassname(attacker, atkCls, sizeof(atkCls))
                && (StrEqual(atkCls, "infected") || StrEqual(atkCls, "witch")))
                return Plugin_Continue;
        }
    }

    // El atacante no es un infectado del juego: es point_hurt /
    // env_explosion / inferno / prop de las habilidades del Super Tank.
    // Bloquear el daño completamente (anti-Friendly-Fire real)
    damage = 0.0;
    return Plugin_Changed;
}

// ==============================================================
// PUENTES ONPLAYERRUNCMD
// ==============================================================

public void Amy_OnPlayerRunCmd(int client, int &buttons)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return;

    // NOTA: El sistema Diva Body fue reemplazado por Doll_System.inc
    // (sistema modular por SteamID con menú !dollmenu)
    // Ya no se procesa la activación de Diva Body aquí.

    // v61: ELIMINADO el bloque de animación del arma (force de IN_ATTACK
    // del martillo). El impulso de impacto no toca los buttons del
    // jugador para nada: lo único que vive aquí es el doble salto.

    // ======================================================
    // v44: LÓGICA DE DOBLE SALTO (movida desde Amy_PreThink)
    // ======================================================
    // Razones del move:
    //  - Aquí recibimos los `buttons` REALES del frame (pasados por ref
    //    desde el OnPlayerRunCmd del manager), no una lectura instantanea
    //    vía GetClientButtons() que puede estar desincronizada.
    //  - El reset por FL_ONGROUND ahora se hace ANTES de detectar el
    //    pressed, y se ejecuta en el mismo tick del comando, no en
    //    PreThink donde FL_ONGROUND puede seguir true un frame extra.
    // ======================================================
    int djFlags = GetEntityFlags(client);
    bool bOnGround = ((djFlags & FL_ONGROUND) != 0);

    if (bOnGround || GetEntityMoveType(client) == MOVETYPE_LADDER
        || GetEntProp(client, Prop_Data, "m_nWaterLevel") > 1)
    {
        // En suelo/escala/agua: resetear contador de saltos.
        g_iAmyJumps[client] = 0;
    }
    else
    {
        // Flanco ascendente de IN_JUMP (pulsado en este frame, no en el anterior)
        bool bPressedJump = ((buttons & IN_JUMP) && !(g_iAmyLastButtons[client] & IN_JUMP));

        // Doble salto sigue siendo pasiva permanente (siempre disponible)
        if (bPressedJump && g_iAmyJumps[client] == 0)
        {
            g_iAmyJumps[client] = 1;

            // Aplicar impulso vertical del doble salto
            float vel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            vel[2] = g_fAmyDoubleJumpPower;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

            // Sonido personalizado (según cookie sj_sound_choice)
            int sIdx = g_iAmySoundChoice[client];
            if (sIdx >= 0 && sIdx < sizeof(g_sAmyJumpSoundsLocal))
                EmitSoundToAll(g_sAmyJumpSoundsLocal[sIdx], client);
            else
                EmitSoundToAll(AMY_SOUND_EXPLODE, client);

            // VFX v2.0: ring rosa expandido + partícula + glow al despegar
            Amy_VFX_DoubleJump(client);

            // v3.0: Activar Jump Damage Bonus (+50% de daño por 5 segundos)
            g_bAmyJumpDmgActive[client] = true;
            g_fAmyJumpDmgEndTime[client] = GetEngineTime() + AMY_JUMP_DMG_DURATION;
            PrintHintText(client, "<font color='#FF00FF' size='18'>>> SALTO POTENCIADO <<</font>\n<font color='#FF80C0'>Tus golpes hacen +50%% de dano durante %.0fs</font>", AMY_JUMP_DMG_DURATION);
        }
    }

    // Guardar los buttons de este frame para el calculo del flanco en el próximo tick
    g_iAmyLastButtons[client] = buttons;
}

public void Amy_OnPlayerRunCmd_Victim(int client, int &buttons)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_bIsBoneBroken[client])
    {
        if (GetEngineTime() < g_fAmyDisarmEndTime[client])
        {
            buttons &= ~IN_ATTACK;
            buttons &= ~IN_ATTACK2;
        }
        else
        {
            Amy_ResetVictim(client);
        }
    }
}

// ============================================================================
//  HABILIDAD 2: PODER ALEATORIO DEL SUPER TANK
//  Amy obtiene una habilidad aleatoria del Super Tank.
//  El doble salto es uno de los poderes aleatorios.
// ============================================================================

void Amy_InitPower2Pool() {
    g_iAmyPower2Count = 0;

    // Hammer Jump (especial - no usa VScript, usa el sistema de Amy)
    Amy_AddPower2("hammer_jump", "Hammer Jump", false, false, true);

    // Habilidades entity-based
    Amy_AddPower2("ThunderZap", "Thunder Zap", false, false, false);
    Amy_AddPower2("HellfirePillar", "Hellfire Pillar", false, false, false);
    Amy_AddPower2("MeguminExplosion", "Megumin Explosión", false, false, false);
    Amy_AddPower2("MeguminExplosions", "Megumin Explosions", false, false, false);
    Amy_AddPower2("Electrocute", "Electrocute", false, false, false);
    Amy_AddPower2("ActivateBlackHole", "Black Hole", false, false, false);
    Amy_AddPower2("FireGround", "Fire Ground", false, false, false);
    Amy_AddPower2("HellFlameWave", "Flame Wave", false, false, false);
    Amy_AddPower2("FireRains", "Fire Rains", false, false, false);
    Amy_AddPower2("FlameSpin", "Flame Spin", false, false, false);
    Amy_AddPower2("ThunderStorm", "Thunder Storm", false, false, false);
    Amy_AddPower2("EarthquakeEffectInner", "Earthquake", false, true, false);
    Amy_AddPower2("VomitOverlord", "Vomit Bomb", false, false, false);
    Amy_AddPower2("AcidPath", "Acid Path", false, false, false);
    Amy_AddPower2("ElectricMineField", "Electric Mines", false, false, false);
    Amy_AddPower2("ElectricMine", "Electric Mine", false, false, false);
    Amy_AddPower2("LightningZap", "Lightning Zap", false, false, false);
    Amy_AddPower2("SingularityEventHorizon", "Singularity", false, false, false);
    Amy_AddPower2("DeathBlackHole", "Death Black Hole", false, false, false);
    Amy_AddPower2("SwiftImpact", "Swift Impact", false, true, false);
    Amy_AddPower2("Hyperdrive", "Hyperdrive", false, false, false);
    Amy_AddPower2("ShiftToward", "Shift Toward", false, false, false);
    Amy_AddPower2("FogEffect", "Fog Effect", false, false, false);
    Amy_AddPower2("InfectiousArea", "Infectious Área", false, false, false);
    Amy_AddPower2("ExplodeDetonator", "Explode Detonator", false, false, false);
    Amy_AddPower2("ExplosivePath", "Explosive Path", false, false, false);
    Amy_AddPower2("RuptureEffect", "Rupture Effect", false, false, false);
    Amy_AddPower2("DisruptionWorld", "Disruption World", false, false, false);
    Amy_AddPower2("DisarmShield", "Disarm Shield", false, true, false);
    Amy_AddPower2("ReflecShieldOvl", "Reflect Shield Ovl", false, true, false);
    Amy_AddPower2("ReflectShield", "Reflect Shield", false, true, false);
    Amy_AddPower2("BurningAcid", "Burning Acid", false, false, false);
    Amy_AddPower2("AcidArea", "Acid Área", false, false, false);
    Amy_AddPower2("HydroBomb", "Hydro Bomb", false, false, false);
    Amy_AddPower2("ElectricField", "Electric Field", false, false, false);
    Amy_AddPower2("DeathHole", "Death Hole", false, false, false);
    Amy_AddPower2("DeathCurse", "Death Curse", false, false, false);
    Amy_AddPower2("DeathVail", "Death Vail", false, false, false);
    Amy_AddPower2("SwordGuardian", "Sword Guardian", false, true, false);
    Amy_AddPower2("LaserDefense", "Laser Defense", false, false, false);
    Amy_AddPower2("TeleportToSomeone", "Teleport", false, false, false);

    // Habilidades location-based
    Amy_AddPower2("SpawnMeteorsRain", "Meteor Rain", true, false, false);
    Amy_AddPower2("OrbitalStrike", "Orbital Strike", true, false, false);
    Amy_AddPower2("ExplosiveDetonate", "Explosive Detonate", true, false, false);
    Amy_AddPower2("HellfireSpot", "Hellfire Spot", true, false, false);
    Amy_AddPower2("ElectroField", "Electro Spot", true, false, false); // v71: antes "Electric Field" (duplicado con la entity-based)
    Amy_AddPower2("PraiseTheSUN", "Praise The Sun", true, false, false);
    Amy_AddPower2("SwordRain", "Sword Rain", true, false, false);
    Amy_AddPower2("ExplosiveDetonateOvl", "Explosive Detonate Ovl", true, false, false);

    for (int i = 1; i <= MaxClients; i++) {
        g_iAmyPower2Next[i] = -1;
        g_fAmyPower2LastUse[i] = 0.0;
        g_hAmyPower2Timer[i] = null;
        g_bAmyHammerJumpActive[i] = false;
        g_fAmyHammerJumpEndTime[i] = 0.0;
    }

    PrintToServer("[Amy] Pool de poderes aleatorios inicializado: %d habilidades", g_iAmyPower2Count);
}

void Amy_AddPower2(const char[] funcName, const char[] displayName, bool isLocation, bool isSelfCast, bool isDoubleJump) {
    if (g_iAmyPower2Count >= AMY_POWER2_POOL_SIZE) return;
    strcopy(g_sAmyPower2Funcs[g_iAmyPower2Count], 64, funcName);
    strcopy(g_sAmyPower2Names[g_iAmyPower2Count], 48, displayName);
    g_bAmyPower2Loc[g_iAmyPower2Count] = isLocation;
    g_bAmyPower2Self[g_iAmyPower2Count] = isSelfCast;
    g_bAmyPower2Jump[g_iAmyPower2Count] = isDoubleJump;
    g_iAmyPower2Count++;
}

public Action Command_RandomPower(int client, int args) {
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Amy_IsValidClient(client)) return Plugin_Handled;
    // v89 (R26): Sage también roba el poder 2 (set AMY prestado)
    if (g_iPlayerCharIdx[client] != AMY_INDEX
        && g_iPlayerCharIdx[client] != SAGE_INDEX) return Plugin_Handled;
    if (g_iAmyPower2Count == 0) return Plugin_Handled;

    // Verificar cooldown
    float now = GetEngineTime();
    if (now - g_fAmyPower2LastUse[client] < AMY_POWER2_CD) {
        float remaining = AMY_POWER2_CD - (now - g_fAmyPower2LastUse[client]);
        PrintToChat(client, "\x04[Amy]\x01 El poder aleatorio se está recargando: \x04%.1fs\x01", remaining);
        return Plugin_Handled;
    }

    // Si no hay próxima habilidad, elegir una aleatoria
    if (g_iAmyPower2Next[client] < 0 || g_iAmyPower2Next[client] >= g_iAmyPower2Count) {
        g_iAmyPower2Next[client] = GetRandomInt(0, g_iAmyPower2Count - 1);
    }

    int abilityIdx = g_iAmyPower2Next[client];
    char vscriptFunc[64];
    char abilityName[48];
    bool isLocation, isSelfCast, isDoubleJump;
    strcopy(vscriptFunc, sizeof(vscriptFunc), g_sAmyPower2Funcs[abilityIdx]);
    strcopy(abilityName, sizeof(abilityName), g_sAmyPower2Names[abilityIdx]);
    isLocation = g_bAmyPower2Loc[abilityIdx];
    isSelfCast = g_bAmyPower2Self[abilityIdx];
    isDoubleJump = g_bAmyPower2Jump[abilityIdx];

    // Registrar uso
    g_fAmyPower2LastUse[client] = now;

    // === ACTIVAR FILTRO ANTI-FF ===
    // Las habilidades del Super Tank usan point_hurt que daña a todos.
    // Durante 12s, bloqueamos el daño a survivors.
    g_bAmyPowerFFActive = true;
    g_fAmyPowerFFEndTime = now + 12.0;

    // Si es Hammer Jump, ejecutarlo directamente (como las demás habilidades)
    if (isDoubleJump) {  // isDoubleJump = es especial (Hammer Jump)
        PrintToChat(client, "\x04[Amy]\x01 ¡Martillo Resorte!");
        PrintHintText(client, "<font color='#FF00FF' size='20'>>> MARTILLO RESORTE <<</font>");

        // Ejecutar Hammer Jump directamente
        Amy_AddVelocity(client, g_fAmyJumpHeight);
        Amy_SpawnEffect(client, AMY_PARTICLE_EXP3);

        int sIdx = g_iAmySoundChoice[client];
        if (sIdx >= 0 && sIdx < sizeof(g_sAmyJumpSoundsLocal))
            EmitSoundToAll(g_sAmyJumpSoundsLocal[sIdx], client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
        else
            EmitSoundToAll(AMY_SOUND_EXPLODE, client);

        // Iniciar timer de aterrizaje (terremoto)
        if (g_hAmyJumpTimer[client] != null) delete g_hAmyJumpTimer[client];
        g_hAmyJumpTimer[client] = CreateTimer(0.1, T_AmyLandCheck, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    } else {
        // Obtener posición del objetivo apuntado
        float eyePos[3], eyeAng[3];
        GetClientEyePosition(client, eyePos);
        GetClientEyeAngles(client, eyeAng);

        float targetPos[3];
        GetClientAbsOrigin(client, targetPos);  // Default: posición de Amy

        Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, Amy_TraceFilter_NoSelf, client);
        if (trace != null && TR_DidHit(trace)) {
            int targetEntity = TR_GetEntityIndex(trace);
            if (targetEntity > 0) {
                if (targetEntity <= MaxClients) {
                    GetClientAbsOrigin(targetEntity, targetPos);
                } else {
                    GetEntPropVector(targetEntity, Prop_Send, "m_vecOrigin", targetPos);
                }
            } else {
                TR_GetEndPosition(targetPos, trace);
            }
        }
        delete trace;

        // Ejecutar la habilidad vía VScript bridge
        char code[2048];
        if (isLocation) {
            Format(code, sizeof(code), "%s(Vector(%f, %f, %f))", vscriptFunc, targetPos[0], targetPos[1], targetPos[2]);
        } else if (isSelfCast) {
            Format(code, sizeof(code),
                "local p = null; local found = null; while(p = Entities.FindByClassname(p, \"player\")) { if(p.GetEntityIndex() == %d) { found = p; break; } } if(found != null) { found.ValidateScriptScope(); local s = found.GetScriptScope(); s.DoomsdayTank <- true; s.ThunderTank <- true; s.HellfireTank <- true; s.Hellflame <- true; s.SingularityTank <- true; s.blacklord <- true; s.CorruptedTank <- true; s.boomlord <- true; s.Lightning <- true; s.SwiftTank <- true; s.RuptureTank <- true; s.NukeTank <- true; s.InfectTank <- true; s.NoxiousTank <- true; s.HydroTank <- true; s.SamsaraTank <- true; s.TankLives <- 3; s.ImmTimer <- 10; s.MeteorCount <- 0; s.deathlord <- true; s.MeteorLord <- true; s.DisarmTank <- true; s.Shield <- true; s.shieldlord <- true; s.Reflecting <- true; s.Berserk <- true; s.TempestTank <- true; s.LegionTank <- true; s.ElementTank <- true; s.HungerTank <- true; s.ShiftTank <- true; s.flashtank <- true; s.EvericeTank <- true; s.ArcanaTank <- true; %s(found); }",
                client, vscriptFunc);
        } else {
            Format(code, sizeof(code),
                "local e = SpawnEntityFromTable(\"info_target\", {origin = Vector(%f, %f, %f)}); e.ValidateScriptScope(); local s = e.GetScriptScope(); s.DoomsdayTank <- true; s.ThunderTank <- true; s.HellfireTank <- true; s.Hellflame <- true; s.SingularityTank <- true; s.blacklord <- true; s.CorruptedTank <- true; s.boomlord <- true; s.Lightning <- true; s.SwiftTank <- true; s.RuptureTank <- true; s.NukeTank <- true; s.InfectTank <- true; s.NoxiousTank <- true; s.HydroTank <- true; s.SamsaraTank <- true; s.TankLives <- 3; s.ImmTimer <- 10; s.MeteorCount <- 0; s.deathlord <- true; s.MeteorLord <- true; s.DisarmTank <- true; s.Shield <- true; s.shieldlord <- true; s.Reflecting <- true; s.Berserk <- true; s.TempestTank <- true; s.LegionTank <- true; s.ElementTank <- true; s.HungerTank <- true; s.ShiftTank <- true; s.flashtank <- true; s.EvericeTank <- true; s.ArcanaTank <- true; %s(e); DoEntFire(\"!self\", \"Kill\", \"\", 5.0, null, e);",
                targetPos[0], targetPos[1], targetPos[2], vscriptFunc);
        }

        int runner = Amy_FindScriptRunner();
        if (runner != -1) {
            // Setear AmyMode ANTES de llamar la habilidad.
            // Esto hace que los efectos no-dañinos (ralentizar, atraer, vomit)
            // afecten a INFECTADOS en vez de survivors.
            // v67: se pasa el ÍNDICE de Amy para que el VScript sepa quien es
            // la castera (Hyperdrive/Teleport/Shift de ella + defensivas).
            // El vscript viejo ignora el argumento (idx = null): compatible.
            char amyModeCode[48];
            Format(amyModeCode, sizeof(amyModeCode), "SetAmyMode(%d)", client);
            SetVariantString(amyModeCode);
            AcceptEntityInput(runner, "RunScriptCode");

            // Ejecutar la habilidad
            SetVariantString(code);
            AcceptEntityInput(runner, "RunScriptCode");

            // Resetear AmyMode DESPUÉS (con delay de 12s para efectos persistentes)
            SetVariantString("Timers.AddTimer(12.0, false, function(timer) { ResetAmyMode(); })");
            AcceptEntityInput(runner, "RunScriptCode");
        }

        PrintToChat(client, "\x04[Amy]\x01 ¡\x03%s\x01 activado!", abilityName);
    }

    // Elegir la PRÓXIMA habilidad y anunciarla
    int nextIdx = GetRandomInt(0, g_iAmyPower2Count - 1);
    g_iAmyPower2Next[client] = nextIdx;
    char nextName[48];
    strcopy(nextName, sizeof(nextName), g_sAmyPower2Names[nextIdx]);
    PrintToChat(client, "\x04[Amy]\x01 Tu próximo poder será: \x04%s\x01", nextName);

    // Iniciar timer para mostrar cooldown
    if (g_hAmyPower2Timer[client] != null) {
        KillTimer(g_hAmyPower2Timer[client]);
    }
    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    g_hAmyPower2Timer[client] = CreateTimer(0.5, Amy_TimerPower2CD, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);

    return Plugin_Handled;
}

// Timer que muestra el cooldown del poder aleatorio en pantalla
Action Amy_TimerPower2CD(Handle timer, DataPack pack) {
    pack.Reset();
    int userId = pack.ReadCell();

    int client = GetClientOfUserId(userId);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) {
        // v52 FIX: guard del slot (GetClientOfUserId puede devolver 0 si el
        // jugador ya se fue: escribir g_hAmyPower2Timer[0] era un write
        // fuera del rango de players reales)
        if (client > 0 && client <= MaxClients) {
            g_hAmyPower2Timer[client] = null;
        }
        // v51: el pack lo cierra TIMER_DATA_HNDL_CLOSE al morir el timer
        return Plugin_Stop;
    }

    float now = GetEngineTime();
    float remaining = AMY_POWER2_CD - (now - g_fAmyPower2LastUse[client]);

    if (remaining <= 0.0) {
        char nextName[48];
        strcopy(nextName, sizeof(nextName), g_sAmyPower2Names[g_iAmyPower2Next[client]]);
        PrintHintText(client, "<font color='#FF00FF' size='20'>>> PODER ALEATORIO LISTO <<</font>\n<font color='#FF80C0'>Próximo: %s</font>", nextName);
        g_hAmyPower2Timer[client] = null;
        // v51: el pack lo cierra TIMER_DATA_HNDL_CLOSE al morir el timer
        return Plugin_Stop;
    }

    char nextName[48];
    strcopy(nextName, sizeof(nextName), g_sAmyPower2Names[g_iAmyPower2Next[client]]);
    PrintHintText(client, "<font color='#FF00FF' size='18'>Poder Aleatorio</font>\n<font color='#FFFFFF'>Enfriamiento: %.1fs</font>\n<font color='#FF80C0'>Próximo: %s</font>", remaining, nextName);

    pack.Reset();
    pack.WriteCell(userId);
    return Plugin_Continue;
}

// Helper: encontrar o crear logic_script para VScript
// v51: SOLO se reusa NUESTRO runner etiquetado (targetname). El FindByClassname
// a ciegas de antes devolvia el PRIMER logic_script del mapa: los mapas de
// campaña traen los suyos (eventos, fades, música, spawns dirigidados por
// script) y ejecutar los poderes del Super Tank dentro de su scope pisaba
// el estado del propio mapa - justo en el mapa 2, donde el usuario crasheaba.
// Nuestro runner se crea nuevo, con su scope limpio, y muere con el mapa.
#define AMY_SCRIPT_RUNNER_NAME "amy_p2_runner"
int Amy_FindScriptRunner() {
    int entity = -1;
    char nameBuf[32];
    while ((entity = FindEntityByClassname(entity, "logic_script")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        GetEntPropString(entity, Prop_Data, "m_iName", nameBuf, sizeof(nameBuf));
        if (StrEqual(nameBuf, AMY_SCRIPT_RUNNER_NAME, false)) return entity;
    }
    entity = CreateEntityByName("logic_script");
    if (entity != -1) {
        DispatchKeyValue(entity, "targetname", AMY_SCRIPT_RUNNER_NAME);
        DispatchSpawn(entity);
    }
    return entity;
}

// ============================================================
//  v72 - PUENTE VSCRIPT PERSISTENTE: ::SonicAmyIdx
// ============================================================
//  Escribe en el root de VScript el índice de entidad de la Amy viva.
//  Lo leen los addons VScript (p.ej. "Lanzamiento de martillo v2": solo
//  Amy puede lanzar el martillo + homing). Usa el MISMO logic_script
//  runner del tarot (lo crea si no existe). Un índice reciclado queda
//  anulado al primer spawn del nuevo ocupante (rama else) o al morir
//  (Amy_OnPlayerDeath, que también llega por disconnect y cambio de
//  personaje vía CleanupCharModuleState).
// ============================================================
void Amy_PublishScriptIdx(int client, bool isAmy)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    int runner = Amy_FindScriptRunner();
    if (runner == -1 || !IsValidEntity(runner)) return;

    char code[96];
    if (isAmy)
        Format(code, sizeof(code), "::SonicAmyIdx <- %d", client);
    else
        Format(code, sizeof(code),
               "if(\"SonicAmyIdx\" in getroottable() && ::SonicAmyIdx == %d) ::SonicAmyIdx <- -1",
               client);

    SetVariantString(code);
    AcceptEntityInput(runner, "RunScriptCode");
}

// ============================================================
//  v102/v104 - PARRY DELEGADO DE AMY: el puente SMX -> .nut
//  (patron Amy_PublishScriptIdx / SetAmyMode del supertank):
//  RunScriptCode en el root llamando a ChCh_AmyNotify — SU PROPIA
//  ENTRADA en el chch_parrying.nut v2.8 (v104: antes llamaba la
//  entrada de Knuckles y su identidad dependía de convars espejo;
//  ahora LA ENTRADA ES LA IDENTIDAD, como SetAmyMode). on = "Amy
//  está en pose de defensa" (la ventana del .nut dura lo que le
//  quede de pose); off = "Amy ya no está en defensa" (LA ORDEN DE
//  APAGADO).
// ============================================================
void Amy_ParryNotifyNut(int client, bool on, float now)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    int runner = Amy_FindScriptRunner();
    if (runner == -1 || !IsValidEntity(runner)) return;

    float dur = 0.0;
    if (on)
    {
        dur = g_fAmyOMCounterUntil[client] - now;
        if (dur <= 0.0) return;
        if (dur > 10.0) dur = 10.0;
    }

    char code[192];
    Format(code, sizeof(code),
        "local r = getroottable(); if(\"ChCh_AmyNotify\" in r) r.ChCh_AmyNotify(%d, %d, %.2f)",
        client, on ? 1 : 0, dur);

    SetVariantString(code);
    AcceptEntityInput(runner, "RunScriptCode");
}

// v102 - EL PUENTE INVERSO .nut -> SMX: el chch_parrying.nut v2.3
// avisa por SendToServerConsole("amyparry_strike <entidx>") cuando un
// PROYECTIL entra al rango de la ventana de defensa de Amy ("si el
// proyectil está en rango activara la defensa de martillo — el ataque
// más el aura"). Se consume la pose con el MISMO paquete del trigger
// por prop: Amy_OM_CounterTriggerProp (barrido 360 + VFX + gesto).
public Action Amy_CmdParryStrike(int args)
{
    if (args < 1) return Plugin_Handled;
    char s[16];
    GetCmdArg(1, s, sizeof(s));
    int client = StringToInt(s);
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return Plugin_Handled;
    if (!IsPlayerAlive(client) || GetClientTeam(client) != 2) return Plugin_Handled;

    // sin ventana de defensa abierta: nada que disparar (el flanco de
    // bajada del PhaseThink ya mandó la orden de apagado del parry)
    if (g_fAmyOMCounterUntil[client] <= GetEngineTime()) return Plugin_Handled;

    Amy_OM_CounterTriggerProp(client);   // consume la pose + ATAQUE + AURA
    return Plugin_Handled;
}

// Trace filter para no golpearse a sí mismo
public bool Amy_TraceFilter_NoSelf(int entity, int mask, int self) {
    return entity != self;
}
// =======================
// HABILIDAD 1: IMPULSO DE IMPACTO (v61, sustituye al Hammer Strike)
// =======================

// ============================================================================
//  v61 - IMPULSO DE IMPACTO: ACTIVACION (tecla Z)
//
//  Embestida tipo Charger, SIN VFX y sin sonidos (pedido del usuario).
//  La activación completa es:
//     cooldown -> log -> TeleportEntity(velocidad) -> timer userid-only
//  CERO ArrayList, CERO DataPack, CERO escrituras al arma, CERO VFX,
//  CERO sonidos, CERO SDKCalls. Si esto crashea, la última línea del
//  log (amy_impulse_debug.log) nombra la llamada culpable.
//
//  La dirección es la de la MIRADA de Amy, aplanada al plano horizontal
//  (embestida por el suelo). La componente vertical de la velocidad se
//  conserva: la gravedad y el suelo siguen funcionando con normalidad.
// ============================================================================
public Action Command_ImpulseCharge(int client, int args)
{
    if (!Amy_IsValidClient(client)) return Plugin_Handled;
    // v89 (R26): Sage entra por el SET AMY prestado...
    if (g_iPlayerCharIdx[client] != AMY_INDEX
        && g_iPlayerCharIdx[client] != SAGE_INDEX) return Plugin_Handled;

    // v89 (R26): "únicamente el golpe en área de martillo y no el
    // impulso": la Z de Sage es GOLPE EN ÁREA FIJO (la embestida es
    // exclusiva de Amy). Su modo se clava a 1 antes de cualquier rama.
    if (g_iPlayerCharIdx[client] == SAGE_INDEX) g_iAmyAbilityMode[client] = 1;

    // v64 - CONTROL TOTAL: pulsar Z OTRA VEZ en plena embestida la frena
    // en seco (parar donde quieras / esquivar el vacío). El cooldown ya
    // se pago al arrancar: esta pulsación solo corta.
    if (g_bAmyImpulseActive[client])
    {
        Amy_ImpulseEnd(client, false);
        AmyDbg_Log("[PRESS v66] client=%d: embestida cancelada por 2a pulsación", client);
        PrintCenterText(client, "EMBESTIDA CANCELADA");
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fAmyStrikeCooldown[client]) {
        // QoL v45: avisar del tiempo restante (antes fallaba en silencio)
        if (g_iAmyAbilityMode[client] == 1)
            PrintCenterText(client, "GOLPE PIKO PIKO: %.1fs", g_fAmyStrikeCooldown[client] - now);
        else
            PrintCenterText(client, "IMPULSO DE IMPACTO: %.1fs", g_fAmyStrikeCooldown[client] - now);
        return Plugin_Handled;
    }

    // v66 - MODO ELEGIBLE: misma tecla, misma habilidad, DOS estilos. El
    // cooldown es COMPARTIDO (amy_strike_cooldown) y se paga aquí una
    // sola vez, sea cual sea el modo. La embestida en curso se cancela
    // con la 2a pulsación (arriba), antes de entrar aquí.
    if (g_iAmyAbilityMode[client] == 1)
    {
        g_fAmyStrikeCooldown[client] = now + g_fAmyStrikeCD;
        return Amy_DoHammerAOE(client, now);
    }

    char mapName[64];
    GetCurrentMap(mapName, sizeof(mapName));
    AmyDbg_Log("[PRESS v66] client=%d userid=%d mapa=%s modo=IMPULSO", client, GetClientUserId(client), mapName);

    g_fAmyStrikeCooldown[client] = now + g_fAmyStrikeCD;

    // v78: pista de UNA VEZ por sesión — el prop-lanzamiento vivía solo
    // en el modo aoe y el defecto es embestida: sin esta línea el owner
    // no tiene forma de saber que hay DOS estilos con la misma tecla
    if (g_bAmyPropDebug && !g_bAmyPropHintShown[client])
    {
        g_bAmyPropHintShown[client] = true;
        PrintToChat(client, "\x04[EMBESTIDA]\x01 v85: autos y barriles delante salen \x03EMPUJADOS\x01 (receta completa, un solo empuje: \x03la C\x01 pasa a modo AOE)");
    }

    // Dirección: mirada aplanada al plano horizontal y normalizada
    float eyeAngles[3], fwd[3], dir[3];
    GetClientEyeAngles(client, eyeAngles);
    GetAngleVectors(eyeAngles, fwd, NULL_VECTOR, NULL_VECTOR);
    dir[0] = fwd[0];
    dir[1] = fwd[1];
    dir[2] = 0.0;
    float len = SquareRoot(dir[0] * dir[0] + dir[1] * dir[1]);
    if (len < 0.001) {
        // Mirando recto arriba/abajo: embestir al frente absoluto
        dir[0] = 1.0; dir[1] = 0.0;
    } else {
        dir[0] /= len;
        dir[1] /= len;
    }

    // Estado del impulso: arrays estáticos (cero handles). El registro de
    // golpeados se vacía AQUÍ: no hereda nada del impulso anterior ni del
    // mapa anterior.
    g_bAmyImpulseActive[client] = true;
    g_fAmyImpulseDir[client][0] = dir[0];
    g_fAmyImpulseDir[client][1] = dir[1];
    g_fAmyImpulseDir[client][2] = 0.0;
    g_fAmyImpulseEndT[client] = now + g_fAmyImpulseDuration;
    g_iAmyImpulseHitCount[client] = 0;
    GetClientAbsOrigin(client, g_fAmyImpulseStartPos[client]);

    // v62: subir el TOPE DE VELOCIDAD EN TIERRA antes de lanzarla. El
    // motor de L4D2 clampea la velocidad de un superviviente en el suelo
    // a m_flMaxspeed (~220 con arma): sin esto, el TeleportEntity pone
    // 900, en el aire no hay clamp (vuela) pero en el suelo la velocidad
    // cae al tope en el primer tick. Se guarda el valor anterior para
    // restaurarlo al terminar (en TODOS los caminos de fin).
    g_fAmyImpulseSavedMaxSpd[client] = Amy_ImpulseGetMaxSpeed(client);
    Amy_ImpulseSetMaxSpeed(client, g_fAmyImpulseSpeed + 50.0);   // red de seguridad
    AmyDbg_Log("[PRESS v66] tope de suelo (red de seguridad): m_flMaxspeed %.0f -> %.0f",
               g_fAmyImpulseSavedMaxSpd[client], g_fAmyImpulseSpeed + 50.0);

    // v63: MOVETYPE (el fix de verdad). El motor recalcula m_flMaxspeed
    // CADA FRAME (UpdateSpeed: arma/vida/curación...) y devuelve el tope
    // a ~220 antes del siguiente frame de movimiento: por eso la v62
    // seguía lenta en el suelo aunque lo alzaramos cada 0.05s. La
    // embestida pasa a MOVETYPE_FLYGRAVITY (vuelo con gravedad, como
    // una bala): ese camino de física NO aplica ni la fricción del
    // suelo ni el clampeo a maxspeed -> los 900 u/s enteros, en tierra
    // y en aire. Colisiona con paredes y rampas (se desliza sobre
    // ellas), la gravedad la mantiene pegada al suelo y WALK se
    // restaura al terminar por TODOS los caminos de fin.
    SetEntityMoveType(client, MOVETYPE_FLYGRAVITY);
    AmyDbg_Log("[PRESS v66] movetype -> FLYGRAVITY (sin fricción ni clamp)");

    // v64 - NADA LA FRENA FISICAMENTE: durante la embestida su grupo de
    // colisión pasa a DEBRIS (2): atraviesa CUERPOS (comunes,
    // especiales, tank): quien este a su paso es golpeado y empujado
    // por el barrido, no la frena por contacto físico. El grupo
    // original se guarda y se restaura en TODOS los caminos de fin
    // (mismo patron que el movetype y el maxspeed).
    g_iAmyImpulseSavedColGroup[client] = GetEntProp(client, Prop_Data, "m_CollisionGroup");
    SetEntProp(client, Prop_Data, "m_CollisionGroup", 2);
    AmyDbg_Log("[PRESS v66] grupo de colisión %d -> DEBRIS (atraviesa cuerpos)",
               g_iAmyImpulseSavedColGroup[client]);

    // Impulso inicial (la vertical se conserva: si está en el aire, la
    // física de gravedad/suelo sigue su curso)
    float vel[3], launchVel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    launchVel[0] = dir[0] * g_fAmyImpulseSpeed;
    launchVel[1] = dir[1] * g_fAmyImpulseSpeed;
    launchVel[2] = vel[2];

    AmyDbg_Log("[PRESS] TeleportEntity(vel): begin");
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, launchVel);
    AmyDbg_Log("[PRESS] TeleportEntity(vel): end OK");

    // v64: swing del martillo original al arrancar (feedback de
    // activación; el resto del jugo suena al GOLPEAR, con throttle)
    EmitSoundToAll(AMY_SOUND_SWING_DEF, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);

    // Timer del impulso: SOLO userid + NO_MAPCHANGE (patron v60: si el
    // mapa gira a mitad, SourceMod lo mata y no queda NADA pendiente).
    AmyDbg_Log("[PRESS] CreateTimer(IMPULSE, 0.05, REPEAT|NO_MAPCHANGE, userid=%d): begin", GetClientUserId(client));
    CreateTimer(AMY_IMPULSE_TICK, T_AmyImpulseTick, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    AmyDbg_Log("[PRESS] timer creado OK. FIN DEL PRESS");

    return Plugin_Handled;
}

// ============================================================================
//  v66 -> v90 - COMANDO DE MODO (HABILIDAD 3 desde la ronda 27)
//  Sin argumentos: ALTERNA. Con argumento: fija el modo ("impulso" = 0,
//  "aoe"/"golpe"/"área"/"martillo" = 1). El modo es una preferencia por
//  jugador que SOBREVIVE cambios de mapa (se resetea al desconectar).
//  No toca ninguna embestida en curso: solo decide que hace el PRÓXIMO
//  press de Z (la embestida en curso se cancela con la 2a pulsación,
//  como siempre). Desde v90 el manager rutea la tecla C (sm_sjs_ability3)
//  AQUÍ: es la habilidad 3 de Amy, SIN cooldown (preferencia, no ataque).
//  sm_amymodo/sm_amymode siguen como alias directos (binds viejos).
// ============================================================================
public Action Amy_CommandAbilityMode(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Amy_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] == SAGE_INDEX)
    {
        PrintToChat(client, "\x04[Sage]\x01 Tu Z es \x03GOLPE EN ÁREA\x01 fijo. Tu habilidad 3 (C) cambia de \x03SET\x01, no de modo.");
        return Plugin_Handled;
    }
    if (g_iPlayerCharIdx[client] != AMY_INDEX)
    {
        PrintToChat(client, "\x04[Amy]\x01 El modo impulso/golpe es solo de Amy.");
        return Plugin_Handled;
    }

    int newMode = g_iAmyAbilityMode[client] ^ 1;   // sin argumentos: alterna
    if (args > 0)
    {
        char arg[24];
        GetCmdArg(1, arg, sizeof(arg));
        if (StrEqual(arg, "impulso", false) || StrEqual(arg, "impulse", false)
            || StrEqual(arg, "dash", false) || StrEqual(arg, "embestida", false))
        {
            newMode = 0;
        }
        else if (StrEqual(arg, "aoe", false) || StrEqual(arg, "golpe", false)
                 || StrEqual(arg, "área", false) || StrEqual(arg, "martillo", false)
                 || StrEqual(arg, "hammer", false))
        {
            newMode = 1;
        }
        else
        {
            PrintToChat(client, "\x04[Amy]\x01 La \x03C\x01 alterna el modo; también: sm_amymodo <impulso|aoe>.");
            return Plugin_Handled;
        }
    }

    g_iAmyAbilityMode[client] = newMode;
    AmyDbg_Log("[MODO v66] client=%d userid=%d -> %s",
               client, GetClientUserId(client),
               newMode == 1 ? "GOLPE AOE (martillo 360)" : "IMPULSO (embestida)");

    if (newMode == 1)
    {
        PrintCenterText(client, "Z: GOLPE PIKO PIKO (AOE 360 + DEFENSA)");
        PrintToChat(client, "\x04[Amy]\x01 Z = \x03GOLPE EN ÁREA + DEFENSA\x01: golpe circular 360 (radio %.0f) y %.1fs de posición de defensa — el especial/tank/witch que te toque queda \x03ATURDIDO SIN RAGDOLL\x01 (%.1fs + cartas).", AMY_STRIKE_RANGE, 2.0, 3.5);
        PrintToChat(client, "\x04[Amy]\x01 Alterna con la \x03C\x01 o \x03sm_amymodo\x01. Sin cooldown.");
    }
    else
    {
        PrintCenterText(client, "Z: IMPULSO DE IMPACTO");
        PrintToChat(client, "\x04[Amy]\x01 Z = \x03IMPULSO DE IMPACTO\x01: embestida tipo Charger (%.0f u/s) que atraviesa la horda.", g_fAmyImpulseSpeed);
        PrintToChat(client, "\x04[Amy]\x01 Alterna con la \x03C\x01 o \x03sm_amymodo\x01. Sin cooldown.");
    }
    return Plugin_Handled;
}

// ============================================================================
//  v66 - GOLPE AOE (martillo PIKO PIKO restaurado del v12/v60, adaptado)
//  Restaurado tras confirmar que el crash del capítulo 2 era el PRECACHE
//  abortado del OnMapStart del manager (fix v17/v65) y NO el ataque en
//  área. El cooldown ya lo pago el dispatcher (Command_ImpulseCharge):
//  mismo CD compartido con el impulso (amy_strike_cooldown).
//  Patrones anti-crash intactos: arrays estáticos + timer userid +
//  TIMER_FLAG_NO_MAPCHANGE + LOS MASK_SHOT + snapshot-then-strike + tope
//  de comunes por tick.
// ============================================================================
Action Amy_DoHammerAOE(int client, float now)
{
    char mapName[64];
    GetCurrentMap(mapName, sizeof(mapName));

    // v96 (owner): "recuerdas el aura expansiva que sale antes de la
    // pose defensiva? ahora será diferente: se hará la pose defensiva;
    // si llega a impactar contra un infectado, soltara el aura".
    // La Z de la Amy REAL CON MARTILLO ya NO suelta el aura upfront:
    // solo abre la VENTANA (la pose). El aura (VFX + sonido + barrido
    // 360) la suelta Amy_OM_CounterTrigger al IMPACTAR (infectado o
    // prop en movimiento) durante la ventana.
    if (g_iPlayerCharIdx[client] == AMY_INDEX && !g_bAmyOMNoHammer[client])
    {
        AmyDbg_Log("[PRESS v97] client=%d userid=%d mapa=%s modo=DEFENSA (pose sola, aura al impactar)",
                   client, GetClientUserId(client), mapName);
        Amy_OM_CounterOpen(client, now);
        return Plugin_Handled;
    }

    AmyDbg_Log("[PRESS v66] client=%d userid=%d mapa=%s modo=AOE (martillo 360)",
               client, GetClientUserId(client), mapName);

    // 1. VFX del press: ring rosa expansivo + screen shake local (la
    //    misma pieza del martillo v12: BeamRing + shake, cero entidades).
    Amy_VFX_Strike(client);

    // 2. Sonido de swing (nativo del juego, precacheado en OnMapStart).
    EmitSoundToAll(AMY_SOUND_SWING_DEF, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);

    // 3. Barrido 360 durante 0.5s (radio 220, LOS real, tope por tick).
    //    El registro de golpeados se vacía AQUÍ: no hereda nada del golpe
    //    anterior ni del mapa anterior.
    g_iAmySweepHitCount[client] = 0;
    g_fAmySweepStart[client] = now;
    g_bAmySweepFirstTick[client] = true;   // v78: línea diagnostica del primer tick

    // (v92-OM fusión retirada en v96: la Amy real con martillo vuelve
    // arriba antes de llegar aquí — la ventana ya no se abre con el
    // golpe; Sage y la Amy sin martillo SI conservan este AOE pelado)

    AmyDbg_Log("[PRESS v66] CreateTimer(AOE, %.2f, REPEAT|NO_MAPCHANGE, userid=%d): begin",
               AMY_STRIKE_VISUAL_TICK, GetClientUserId(client));
    CreateTimer(AMY_STRIKE_VISUAL_TICK, T_AmyHammerSweep, GetClientUserId(client),
                TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    AmyDbg_Log("[PRESS v66] timer creado OK. FIN DEL PRESS AOE");

    return Plugin_Handled;
}

// ============================================================================
//  v66 - BARRIDO 360 (tick cada 0.1s durante 0.5s): reconstrucción del
//  T_AmyHammerSweep v60 con el nucleo de dano v64 (Amy_ImpulseHit):
//   - Timer con SOLO userid + NO_MAPCHANGE (cambio de mapa: SM lo mata,
//     cero pendientes).
//   - Registro de golpeados: array estático por cliente (g_iAmySweepHits).
//   - Snapshot-then-strike (v49) y LOS MASK_SHOT (v53): nada se golpea a
//     través de paredes ni se matan entidades mientras se itera.
//   - Por victima: la dirección de empuje se escribe en
//     g_fAmyImpulseDir[attacker] (atacante -> victima, normalizada) para
//     que Amy_ImpulseHit empuje ALEJANDO de Amy y el wall-check decida
//     rompe-huesos/desarme en esa dirección. Amy_ImpulseHit aporta TODO
//     el jugo v64: witch flight, Verdugo, boomer burst, bone break,
//     desarme, sonidos/VFX con throttle y pasivas (Furia/Momentum/Jump).
// ============================================================================
public Action T_AmyHammerSweep(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);

    // Fin del barrido: cliente inválido (desconecto/murió/cambio de
    // equipo) o duración agotada. El registro se vacía: el siguiente
    // golpe empieza de cero (Amy_DoHammerAOE también lo resetea).
    if (!Amy_IsValidClient(client)
        || g_fAmySweepStart[client] <= 0.0
        || (GetEngineTime() - g_fAmySweepStart[client] > AMY_STRIKE_DURATION))
    {
        if (client > 0 && client <= MaxClients)
        {
            g_fAmySweepStart[client] = 0.0;
            g_iAmySweepHitCount[client] = 0;
            g_bAmySweepFirstTick[client] = false;
        }
        AmyDbg_Log("[AOE] fin del barrido (userid=%d)", userid);
        return Plugin_Stop;
    }

    // GOLPE CIRCULAR 360 alrededor de Amy (v48) + SOLO CON LÍNEA DE
    // VISION REAL (v53, MASK_SHOT: lo detrás de una pared no existe
    // para el martillo).
    float eyePos[3];
    GetClientEyePosition(client, eyePos);
    float myPos[3];
    GetClientAbsOrigin(client, myPos);

    int siFound = 0;

    // --- 1. Infectados especiales (players) ---
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;
        if (Amy_SweepAlreadyHit(client, i)) continue;

        float targetPos[3]; GetClientAbsOrigin(i, targetPos); targetPos[2] += 40.0;
        if (Amy_IsTargetInArea(eyePos, targetPos, AMY_STRIKE_RANGE))
        {
            if (!Amy_HasLineOfSight(client, eyePos, targetPos))
            {
                AmyDbg_Log("[AOE] SI %d descartado (sin línea de visión: pared de por medio)", i);
                continue;
            }
            AmyDbg_Log("[AOE] GOLPE a SI: client=%d (zclass=%d)",
                       i, GetEntProp(i, Prop_Send, "m_zombieClass"));
            siFound++;
            Amy_AOEHit(client, i, myPos);
            Amy_SweepRegisterHit(client, i);
        }
    }

    // --- 2. Comunes: snapshot primero (v49: nunca matar mientras se
    //        itera), LOS, tope por tick (el resto de la horda entra en
    //        el próximo tick del barrido) ---
    int commons[AMY_SWING_MAX_PER_TICK];
    int nCommons = 0;
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (nCommons >= AMY_SWING_MAX_PER_TICK) break;
        if (!IsValidEntity(entity)) continue;
        if (Amy_SweepAlreadyHit(client, entity)) continue;

        float targetPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos); targetPos[2] += 40.0;
        if (Amy_IsTargetInArea(eyePos, targetPos, AMY_STRIKE_RANGE))
        {
            if (!Amy_HasLineOfSight(client, eyePos, targetPos)) continue;
            commons[nCommons++] = entity;
        }
    }

    for (int k = 0; k < nCommons; k++)
    {
        int ent = commons[k];
        // pudo morir por el golpe de un commons anterior de ESTE mismo tick
        if (ent <= 0 || !IsValidEntity(ent)) continue;
        AmyDbg_Log("[AOE] GOLPE a común: ent=%d", ent);
        Amy_AOEHit(client, ent, myPos);
        Amy_SweepRegisterHit(client, ent);
    }

    // --- 3. Witches: snapshot + LOS (la witch detrás de la pared del
    //        safe room queda fuera del golpe: v53, mantenido) ---
    int witches[8];
    int nWitches = 0;
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (nWitches >= 8) break;
        if (!IsValidEntity(entity)) continue;
        if (Amy_SweepAlreadyHit(client, entity)) continue;

        float targetPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos); targetPos[2] += 40.0;
        if (Amy_IsTargetInArea(eyePos, targetPos, AMY_STRIKE_RANGE))
        {
            if (!Amy_HasLineOfSight(client, eyePos, targetPos))
            {
                AmyDbg_Log("[AOE] witch %d descartada (sin línea de visión: pared de por medio)", entity);
                continue;
            }
            witches[nWitches++] = entity;
        }
    }

    for (int k = 0; k < nWitches; k++)
    {
        int ent = witches[k];
        if (ent <= 0 || !IsValidEntity(ent)) continue;
        AmyDbg_Log("[AOE] GOLPE a WITCH: ent=%d", ent);
        Amy_AOEHit(client, ent, myPos);
        Amy_SweepRegisterHit(client, ent);
    }

    // --- 4. v73 - MARTILLO PESADO: props con física del mapa (Autos,
    //        dumpsters, barriles...) y la PIEDRA del tank. El objeto
    //        quieto sale LANZADO "como el tank"; la piedra o cualquier
    //        objeto que venga hacia Amy (punetazo de tank a un coche) se
    //        REDIRIGE de vuelta al remitente. El mismo LOS MASK_SHOT +
    //        registro por golpe del resto del barrido: nada se lanza a
    //        través de paredes ni dos veces. ---
    int props[AMY_PROPS_PER_TICK];
    int nProps = 0;

    // 4a. piedra del tank (proyectil: siempre redirigible)
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "tank_rock")) != -1)
    {
        if (nProps >= AMY_PROPS_PER_TICK) break;
        if (!IsValidEntity(entity)) continue;
        if (Amy_SweepAlreadyHit(client, entity)) continue;

        float targetPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos);
        targetPos[2] += 40.0;
        if (Amy_IsTargetInArea(eyePos, targetPos, AMY_STRIKE_RANGE))
        {
            // v77: la piedra es solida para el filtro antiguo y el rayo
            // termina DENTRO de ella: se auto-bloqueaba y la redirección
            // jamás disparaba. El LOS nuevo la ATRAVIESA.
            if (!Amy_HasLineOfSightToProp(client, eyePos, targetPos, entity))
            {
                AmyDbg_Log("[PROPS v80] piedra %d EN RADIO pero muro de por medio", entity);
                continue;
            }
            props[nProps++] = entity;
        }
    }

    // 4b. props con física del mapa (clase por clase)
    for (int c = 0; c < AMY_PROP_CLASSES && nProps < AMY_PROPS_PER_TICK; c++)
    {
        entity = -1;
        while ((entity = FindEntityByClassname(entity, g_sAmyPropClasses[c])) != -1)
        {
            if (nProps >= AMY_PROPS_PER_TICK) break;
            if (!IsValidEntity(entity)) continue;
            if (Amy_SweepAlreadyHit(client, entity)) continue;

            float targetPos[3];
            GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos);
            targetPos[2] += 40.0;
            if (Amy_IsTargetInArea(eyePos, targetPos, AMY_STRIKE_RANGE))
            {
                // v77 - EL MURO INVISIBLE: el LOS antiguo trataba CUALQUIER
                // prop como solido -> el rayo ojos->origen del auto chocaba
                // CONTRA EL PROPIO AUTO y lo descartaba SIEMPRE (por eso
                // jamás salió el mensaje: Amy_LaunchMapProp nunca corria).
                // El LOS nuevo ignora al objetivo: solo un muro REAL descarta.
                if (!Amy_HasLineOfSightToProp(client, eyePos, targetPos, entity))
                {
                    AmyDbg_Log("[PROPS v80] prop %d EN RADIO pero muro de por medio", entity);
                    continue;
                }
                props[nProps++] = entity;
            }
        }
    }

    // 4c. v79/v82 - ESCANEO AGNOSTICO: las 5 clases de 4b cubren los
    //      hittables clasicos, pero un "prop_*" con classname raro
    //      quedaba INVISIBLE para el martillo. Este pase ve CUALQUIER
    //      "prop_*" con cuerpo VPHYSICS (mismo radio, mismo LOS, mismo
    //      registro por golpe, dedupe contra 4a/4b). Los DECORATIVOS
    //      (prop_dynamic) QUEDAN FUERA desde v82: sin V no se toca
    //      (la física es manual: sm_amyfisica).
    int maxEnt = GetMaxEntities();
    if (maxEnt <= MaxClients) maxEnt = 2048;
    for (int e = MaxClients + 1; e < maxEnt && nProps < AMY_PROPS_PER_TICK; e++)
    {
        if (!IsValidEntity(e)) continue;

        bool dup = false;
        for (int d = 0; d < nProps; d++)
            if (props[d] == e) { dup = true; break; }
        if (dup) continue;
        if (Amy_SweepAlreadyHit(client, e)) continue;

        static char cls2[32];
        GetEntityClassname(e, cls2, sizeof(cls2));
        if (StrContains(cls2, "prop_", false) != 0
            && !StrEqual(cls2, "func_physbox", false)) continue;
        if (StrEqual(cls2, "prop_ragdoll", false)) continue;   // cuerpos: fuera

        bool physicsBody = (GetEntityMoveType(e) == MOVETYPE_VPHYSICS);
        if (!physicsBody) continue;   // v82: sin V incorporado, no existe para el martillo

        float targetPos[3];
        GetEntPropVector(e, Prop_Send, "m_vecOrigin", targetPos);
        targetPos[2] += 40.0;
        if (Amy_IsTargetInArea(eyePos, targetPos, AMY_STRIKE_RANGE))
        {
            if (!Amy_HasLineOfSightToProp(client, eyePos, targetPos, e))
            {
                AmyDbg_Log("[PROPS v80] prop %d EN RADIO pero muro de por medio", e);
                continue;
            }
            props[nProps++] = e;
        }
    }

    // golpearlos (el primero del tick lleva el sonido: 8 props no
    // ametrallan el canal de sonido)
    for (int k = 0; k < nProps; k++)
    {
        int ent = props[k];
        if (ent <= 0 || !IsValidEntity(ent)) continue;
        Amy_LaunchMapProp(client, ent, (k == 0), false);   // v84: martillo = receta completa
        Amy_SweepRegisterHit(client, ent);
    }

    // v78: diagnostico del PRIMER tick — si el escaneo no ve objetos, el
    // owner lo sabe AL INSTANTE en el chat (nada de adivinar)
    if (g_bAmySweepFirstTick[client])
    {
        g_bAmySweepFirstTick[client] = false;
        if (g_bAmyPropDebug && nProps == 0)
            PrintToChat(client, "\x04[MARTILLO]\x01 0 objetos con V (física) en radio %.0f (acercate; decorativo? apunta y escribe sm_amypropinfo; física a mano: sm_amyfisica)", AMY_STRIKE_RANGE);
    }

    // v52/v66/v73: resumen del tick (correlación con reportes de "no pega").
    AmyDbg_Log("[AOE] tick OK: SI=%d commons=%d witches=%d props=%d",
               siFound, nCommons, nWitches, nProps);

    return Plugin_Continue;
}

// ============================================================================
//  v73 - MARTILLO PESADO: PROPS DEL MAPA Y PIEDRA DEL TANK EN EL GOLPE
//  "Puede lanzar Auto y objetos del mapa (como el tank) y redirigir
//  eso en caso si es que el tank los lanza." Patrones anti-crash del
//  suite: EntRefs + arrays estáticos (CERO handles), UN timer global
//  NO_MAPCHANGE que muere con el mapa, validación de ref en cada uso,
//  y el dano NUNCA dentro de un hook del motor (receta v70: el toque
//  SOLO anota, castiga el monitor de timer).
// ============================================================================

// v73: tank vivo más cercano a una posición (para devolverle lo que
// lanzo). 0 si no hay tank vivo.
int Amy_FindNearestTank(const float fromPos[3])
{
    int best = 0;
    float bestDist = 999999.0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;
        if (GetEntProp(i, Prop_Send, "m_zombieClass") != 8) continue;

        float tPos[3];
        GetClientAbsOrigin(i, tPos);
        float d = GetVectorDistance(fromPos, tPos, true);
        if (d < bestDist)
        {
            bestDist = d;
            best = i;
        }
    }
    return best;
}

// v73: liberar un slot del tracker
void Amy_PropFreeSlot(int slot)
{
    // v82: quitar el hook de dano del vigilado (si la entidad vive)
    if (g_iAmyPropRef[slot] != INVALID_ENT_REFERENCE)
    {
        int hookEnt = EntRefToEntIndex(g_iAmyPropRef[slot]);
        if (hookEnt > 0 && IsValidEntity(hookEnt))
            SDKUnhook(hookEnt, SDKHook_OnTakeDamage, Amy_PropOnTakeDamage);
    }
    g_iAmyPropRef[slot]      = INVALID_ENT_REFERENCE;
    g_iAmyPropPending[slot]  = INVALID_ENT_REFERENCE;
    g_iAmyPropOwnerUid[slot] = 0;
    g_fAmyPropEndT[slot]     = 0.0;
    g_fAmyPropGuardT[slot]   = 0.0;      // v83: custodia fuera
    g_fAmyPropLaunchGameT[slot] = 0.0;   // v83: fresqueda fuera
    g_fAmyPropLastDmg[slot]  = 0.0;
    g_bAmyPropIsRock[slot]   = false;
    g_iAmyPropLauncher[slot] = AMY_PROPLAUNCH_NONE;   // v82: lanzador fuera
    g_iAmyPropSource[slot]  = AMY_PROPSRC_HAMMER;     // v84: fuente fuera (defecto martillo)
    g_iAmyPropBoosts[slot]   = 0;      // v74: sin re-impulsos pendientes
    g_vecAmyPropVel[slot][0] = 0.0;    // v74: velocidad objetivo fuera
    g_vecAmyPropVel[slot][1] = 0.0;
    g_vecAmyPropVel[slot][2] = 0.0;
    g_vecAmyPropPos[slot][0] = 0.0;    // v75: huella de posición fuera
    g_vecAmyPropPos[slot][1] = 0.0;
    g_vecAmyPropPos[slot][2] = 0.0;
}

// v73: reset total del tracker (OnPluginStart/OnMapStart/OnMapEnd: el
// monitor murió con el mapa vía NO_MAPCHANGE y los SDKHooks murieron
// con sus entidades; aquí solo quedan refs muertas que se limpian)
void Amy_PropResetTracker()
{
    for (int s = 0; s < AMY_PROPS_TRACKED; s++)
        Amy_PropFreeSlot(s);
    g_bAmyPropTimerOn = false;
}

// v73/v74: registrar un objeto lanzado/redirigido + engancharle su
// toque. v74: la velocidad OBJETIVO viaja con el registro para que el
// monitor pueda re-aplicarla si el motor se come el impulso.
void Amy_PropTrack(int client, int prop, bool isRock, const float launchVel[3], bool fromImpulse)
{
    int ref = EntIndexToEntRef(prop);

    // buscar slot: el suyo (re-golpe de algo ya en vuelo) o el primero
    // libre; si no hay, reciclar el que expira antes
    int slot = -1;
    int freeSlot = -1;
    for (int s = 0; s < AMY_PROPS_TRACKED; s++)
    {
        if (g_iAmyPropRef[s] == ref) { slot = s; break; }
        if (freeSlot == -1 && g_iAmyPropRef[s] == INVALID_ENT_REFERENCE) freeSlot = s;
    }
    if (slot == -1) slot = freeSlot;
    if (slot == -1)
    {
        float earliest = 999999.0;
        for (int s = 0; s < AMY_PROPS_TRACKED; s++)
        {
            if (g_fAmyPropGuardT[s] < earliest)   // v83: reciclar por la custodia (la más corta)
            {
                earliest = g_fAmyPropEndT[s];
                slot = s;
            }
        }
    }
    if (slot < 0) return;   // defensivo: nunca ocurre

    Amy_PropFreeSlot(slot);
    g_iAmyPropRef[slot]      = ref;
    g_iAmyPropOwnerUid[slot] = (client > 0) ? GetClientUserId(client) : 0;
    g_fAmyPropEndT[slot]     = GetEngineTime() + AMY_PROP_TRACK_LIFE;
    // v83: la CUSTODIA vive MÁS que el vuelo: mientras viva, el
    // objeto sigue protegido (no lastima survivors) y las redes de
    // atribución siguen vigilando al tank — el auto que REBOTA no
    // se le escapa a nadie.
    g_fAmyPropGuardT[slot]     = GetEngineTime() + AMY_PROP_GUARD_LIFE;
    g_fAmyPropLaunchGameT[slot] = GetGameTime();   // v83: frescura de la red B
    g_bAmyPropIsRock[slot]   = isRock;
    // v82: quien lanza este objeto (regla del owner: lo de Amy no
    // lastima survivors; si el TANK lo golpea, vuelve a lastimar)
    g_iAmyPropLauncher[slot] = Amy_IsValidClient(client) ? AMY_PROPLAUNCH_AMY : AMY_PROPLAUNCH_NONE;
    // v74: meta de velocidad + presupuesto de re-impulsos. La piedra no
    // lleva (proyectil siempre despierto: re-volar una piedra caida
    // sería raro); cualquier prop de mapa si: insistir como el tank.
    g_vecAmyPropVel[slot][0] = launchVel[0];
    g_vecAmyPropVel[slot][1] = launchVel[1];
    g_vecAmyPropVel[slot][2] = launchVel[2];
    // v85 - LA ÚNICA DIFERENCIA martillo/embestida (revertida la
    // reducción v84: el empuje vuelve a ser 100% compatible): el
    // MARTILLO conserva su único re-impulso de insistencia (su rebote
    // de la R20); el objeto EMPUJADO por la embestida NO — 0
    // re-impulsos (owner: "no quiero que tenga empujones adicionales,
    // o sea 0, solo será el empuje principal"). El re-golpe con la Z
    // re-registra el slot como MARTILLO (rebote al instante).
    g_iAmyPropSource[slot]  = fromImpulse ? AMY_PROPSRC_DASH : AMY_PROPSRC_HAMMER;
    g_iAmyPropBoosts[slot]   = isRock ? 0 : (fromImpulse ? 0 : AMY_PROP_REBOOSTS);
    // v75: huella de posición REAL (detector de "el cuerpo no se
    // mueve": m_vecVelocity puede mentir en un cuerpo dormido)
    if (HasEntProp(prop, Prop_Send, "m_vecOrigin"))
        GetEntPropVector(prop, Prop_Send, "m_vecOrigin", g_vecAmyPropPos[slot]);

    // hook de toque: SOLO anota la victima pendiente (el dano lo aplica
    // el monitor, FUERA de cualquier hook del motor - receta v70)
    SDKHook(prop, SDKHook_StartTouch, Amy_PropTouch);

    // v82: NET A DE ATRIBUCION — observar el dano que RECIBE el prop:
    // si quien golpea es un TANK, el lanzador pasa a TANK. Solo anota
    // un int: cero acciones dentro del hook del motor.
    SDKHook(prop, SDKHook_OnTakeDamage, Amy_PropOnTakeDamage);

    // monitor global: uno solo mientras haya algo volando
    if (!g_bAmyPropTimerOn)
    {
        g_bAmyPropTimerOn = true;
        CreateTimer(AMY_PROP_MONITOR_TICK, T_AmyPropTick, _,
                    TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }
}

// v73: toque del objeto lanzado: SOLO anota a la victima (nunca dana
// aquí: matar dentro de un hook del motor = re-entrada = crash v70)
public Action Amy_PropTouch(int entity, int other)
{
    for (int s = 0; s < AMY_PROPS_TRACKED; s++)
    {
        if (g_iAmyPropRef[s] == INVALID_ENT_REFERENCE) continue;
        if (EntRefToEntIndex(g_iAmyPropRef[s]) != entity) continue;

        if (other > 0 && IsValidEntity(other))
            g_iAmyPropPending[s] = EntIndexToEntRef(other);
        break;
    }
    return Plugin_Continue;
}

// ============================================================================
//  v82 - PROPS AMIGOS + METRALLA DE COMUNES (reglas del owner):
//   * lo que LANZA Amy no lastima survivors (ni a ella misma);
//   * si el TANK golpea el objeto, VUELVE a lastimar survivors;
//   * los objetos de Amy barren los comunes a su paso.
//  Atribución del tank por 3 redes independientes (baratas):
//   A) el dano que RECIBE el prop (OnTakeDamage, atacante tank)
//   B) m_hPhysicsAttacker (lo que usa el juego para atribuir las
//      muertes por hittables)
//   C) el atacante de la victima (si el juego lo atribuye al tank)
// ============================================================================

// v82: ¿que slot vigila este ente? (-1 si ninguno)
int Amy_PropFindSlot(int ent)
{
    for (int s = 0; s < AMY_PROPS_TRACKED; s++)
    {
        if (g_iAmyPropRef[s] == INVALID_ENT_REFERENCE) continue;
        if (EntRefToEntIndex(g_iAmyPropRef[s]) == ent) return s;
    }
    return -1;
}

// v82 - RED A: el prop vigilado RECIBE dano. Si el atacante es un
// TANK (punetazo/claw), el último lanzador pasa a ser el TANK: desde
// ese momento el objeto VUELVE a lastimar survivors (regla del
// owner). Solo OBSERVA y anota (cero acciones en el hook del motor).
// El golpe de Amy al prop (Amy_PropRealHit) no toca esto: Amy no es
// del equipo infectado.
public Action Amy_PropOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker)
        && GetClientTeam(attacker) == TEAM_INFECTED
        && GetEntProp(attacker, Prop_Send, "m_zombieClass") == 8)
    {
        int slot = Amy_PropFindSlot(victim);
        if (slot != -1 && g_iAmyPropLauncher[slot] != AMY_PROPLAUNCH_TANK)
        {
            g_iAmyPropLauncher[slot] = AMY_PROPLAUNCH_TANK;
            AmyDbg_Log("[PROPS v82] TANK golpeo el prop ent=%d: lanzador -> TANK (vuelve a lastimar survivors)", victim);
        }
    }
    return Plugin_Continue;
}

// v82 - RED B: el motor recuerda en m_hPhysicsAttacker quien golpeo
// FISICAMENTE el cuerpo (es lo que usa el juego para atribuir las
// muertes por hittables). Red barata: si dice TANK, lanzador -> TANK.
void Amy_PropCheckTankAttrib(int slot, int ent)
{
    if (g_iAmyPropLauncher[slot] != AMY_PROPLAUNCH_AMY) return;
    if (!IsValidEntity(ent)) return;

    int pAtt = -1;
    if (HasEntProp(ent, Prop_Send, "m_hPhysicsAttacker"))
        pAtt = GetEntPropEnt(ent, Prop_Send, "m_hPhysicsAttacker");
    else if (HasEntProp(ent, Prop_Data, "m_hPhysicsAttacker"))
        pAtt = GetEntPropEnt(ent, Prop_Data, "m_hPhysicsAttacker");
    if (pAtt <= 0 || pAtt > MaxClients || !IsClientInGame(pAtt)) return;
    if (GetClientTeam(pAtt) != TEAM_INFECTED) return;
    if (GetEntProp(pAtt, Prop_Send, "m_zombieClass") != 8) return;

    // v83 - FRESCURA: la red B solo confia en el tank si su
    // influencia física es MÁS NUEVA que el lanzamiento de Amy. El
    // hoyo v82: el motor recuerda al tank en m_hPhysicsAttacker
    // MUCHO tiempo — un punetazo ANTERIOR al lanzamiento volteaba
    // el slot a TANK y la protección moria sin que el tank hubiera
    // vuelto a tocar NADA (el auto de Amy le pegaba a ella).
    float infl = 0.0;
    if (HasEntProp(ent, Prop_Send, "m_flLastPhysicsInfluenceTime"))
        infl = GetEntPropFloat(ent, Prop_Send, "m_flLastPhysicsInfluenceTime");
    else if (HasEntProp(ent, Prop_Data, "m_flLastPhysicsInfluenceTime"))
        infl = GetEntPropFloat(ent, Prop_Data, "m_flLastPhysicsInfluenceTime");
    if (g_fAmyPropLaunchGameT[slot] > 0.0 && infl < g_fAmyPropLaunchGameT[slot])
        return;   // influencia VIEJA: el último que mandó fue Amy

    g_iAmyPropLauncher[slot] = AMY_PROPLAUNCH_TANK;
    AmyDbg_Log("[PROPS v83] TANK atribuido vía m_hPhysicsAttacker (influencia FRESCA): ent=%d lanzador -> TANK", ent);
}

// v82 - LA REGLA EN LA VICTIMA: ¿bloquear este dano a un survivor?
// SI solo si el infligidor (o atacante-entidad) es un prop VIGILADO
// lanzado por AMY y el dano no viene del tank. Prop sin vigilar =
// desconocido = pasa ("solo protege si el golpe fue de Amy").
bool Amy_PropBlocksSurvivorDamage(int attacker, int inflictor)
{
    // v105 FIX 2 (cinturon 2 de 3): EL MARTILLO LANZADO (V) — el dano
    // de colisión FÍSICA del juego vanilla NO toca al EQUIPO (pedido:
    // "que no dane a amy cuando esta es lanzada ni a nadie del equipo;
    // el dano de colisión amy se dano cuando lanza el martillo"). El
    // prop del martillo solo existe mientras una Amy lo lanzo: todo
    // crash damage que el motor le atribuya (inflictor O attacker =
    // el prop) muere AQUÍ, venga de donde venga. (El golpe de JUEGO
    // del martillo solo sale por SDKHooks_TakeDamage contra
    // infectados y nunca entra por este camino.)
    if (Amy_OM_HammerBlocksDamage(inflictor) || Amy_OM_HammerBlocksDamage(attacker))
        return true;

    if (inflictor > MaxClients && IsValidEntity(inflictor))
    {
        int slot = Amy_PropFindSlot(inflictor);
        if (slot != -1) return Amy_PropLauncherAllowsBlock(slot, attacker);
    }
    if (attacker > MaxClients && IsValidEntity(attacker))
    {
        int slot = Amy_PropFindSlot(attacker);
        if (slot != -1) return Amy_PropLauncherAllowsBlock(slot, attacker);
    }
    return false;
}

// v82: veredicto de un slot: el tank SI pega, Amy NO, el
// desconocido tampoco (regla del juego por defecto).
bool Amy_PropLauncherAllowsBlock(int slot, int attacker)
{
    // ¿el dano viene del TANK (el juego se lo atribuye)? -> PEGA
    if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker)
        && GetClientTeam(attacker) == TEAM_INFECTED
        && GetEntProp(attacker, Prop_Send, "m_zombieClass") == 8)
        return false;
    // solo el golpe de AMY protege
    return (g_iAmyPropLauncher[slot] == AMY_PROPLAUNCH_AMY);
}

// v82 - LA METRALLA DE COMUNES: el motor NO aplica dano de
// aplastamiento a los comunes (el owner lo confirmo: "no hace nada
// contra ellos" — el StartTouch con la horda nunca dispara). El
// monitor los BARRE: común en el radio del objeto volador de Amy =
// golpe (mismo oneshot 500 del toque) + empujon, con cooldown por
// común (la horda cae de a golpes, no ametrallada por tick). SOLO
// objetos de Amy: los del tank ya tienen su lógica nativa.
void Amy_PropSweepCommons(int slot, int ent, float now, const float propPos[3])
{
    int attacker = GetClientOfUserId(g_iAmyPropOwnerUid[slot]);
    if (!Amy_IsValidClient(attacker)) attacker = 0;

    // empuje = dirección de vuelo del objeto (receta del toque v73)
    float dirv[3];
    if (HasEntProp(ent, Prop_Data, "m_vecVelocity"))
        GetEntPropVector(ent, Prop_Data, "m_vecVelocity", dirv);
    else { dirv[0] = 0.0; dirv[1] = 1.0; }
    float dlen = SquareRoot(dirv[0] * dirv[0] + dirv[1] * dirv[1]);
    if (dlen > 1.0) { dirv[0] /= dlen; dirv[1] /= dlen; }
    else { dirv[0] = 0.0; dirv[1] = 1.0; }

    float rad2 = AMY_PROP_COMMON_RAD * AMY_PROP_COMMON_RAD;
    int common = -1;
    while ((common = FindEntityByClassname(common, "infected")) != -1)
    {
        if (common <= 0 || !IsValidEntity(common)) continue;
        if (common >= AMY_PROP_ENTS_MAX) continue;   // guarda del array
        if (now < g_fAmyCommonHitAt[common] + AMY_PROP_COMMON_CD) continue;

        float cPos[3];
        GetEntPropVector(common, Prop_Send, "m_vecOrigin", cPos);
        if (GetVectorDistance(propPos, cPos, true) > rad2) continue;

        g_fAmyCommonHitAt[common] = now;

        float push[3];
        push[0] = dirv[0] * 400.0;
        push[1] = dirv[1] * 400.0;
        push[2] = 250.0;
        TeleportEntity(common, NULL_VECTOR, NULL_VECTOR, push);

        SDKHooks_TakeDamage(common, attacker, ent, AMY_PROP_DMG_COMMON, DMG_CLUB);
        AmyDbg_Log("[PROPS v82] común %d barrido por el prop ent=%d (dano 500)", common, ent);
    }
}

// v73: procesar el toque anotado (FUERA de los hooks): empuje ANTES
// del dano (v45: el ragdoll hereda el impulso), dano solo a zombies
// (cero friendly fire), Verdugo escalando al tank
void Amy_PropProcessPending(int slot, int ent)
{
    if (g_iAmyPropPending[slot] == INVALID_ENT_REFERENCE) return;

    int victim = EntRefToEntIndex(g_iAmyPropPending[slot]);
    g_iAmyPropPending[slot] = INVALID_ENT_REFERENCE;
    if (victim <= 0 || victim == ent || !IsValidEntity(victim)) return;

    float now = GetEngineTime();
    if (now < g_fAmyPropLastDmg[slot] + AMY_PROP_DMG_THROTTLE) return;

    // SOLO zombies: jugadores infectados, comunes y witches. Los
    // supervivientes y los demas props no reciben NADA de Amy
    bool isPlayer = (victim <= MaxClients);
    bool isWitch = false;
    bool isZombie = false;

    if (isPlayer)
    {
        if (IsClientInGame(victim) && IsPlayerAlive(victim)
            && GetClientTeam(victim) == TEAM_INFECTED)
            isZombie = true;
    }
    else
    {
        static char vcls[16];
        GetEntityClassname(victim, vcls, sizeof(vcls));
        if (StrEqual(vcls, "infected", false)) isZombie = true;
        if (StrEqual(vcls, "witch", false)) { isZombie = true; isWitch = true; }
    }
    if (!isZombie) return;

    g_fAmyPropLastDmg[slot] = now;

    // empuje en la dirección de vuelo del objeto (v45: ANTES del dano)
    float pVel[3], push[3];
    if (HasEntProp(ent, Prop_Data, "m_vecVelocity"))
        GetEntPropVector(ent, Prop_Data, "m_vecVelocity", pVel);
    push[0] = pVel[0]; push[1] = pVel[1]; push[2] = pVel[2];
    NormalizeVector(push, push);
    ScaleVector(push, 400.0);
    push[2] = 250.0;
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, push);

    // dano: comunes oneshot; especiales/witch base; tank x2 escalado
    // por el Verdugo (Amy_CalculateDashMultiplier = 1.0 si no es tank)
    int attacker = GetClientOfUserId(g_iAmyPropOwnerUid[slot]);
    if (!Amy_IsValidClient(attacker)) attacker = 0;

    float base = g_bAmyPropIsRock[slot] ? g_fAmyRockHitDmg : g_fAmyPropHitDmg;
    float dmg;
    if (!isPlayer)
    {
        dmg = isWitch ? base : AMY_PROP_DMG_COMMON;
    }
    else
    {
        bool isTank = (GetEntProp(victim, Prop_Send, "m_zombieClass") == 8);
        dmg = base * (isTank ? 2.0 : 1.0);
        if (!isTank && g_bAmyPropIsRock[slot]) dmg *= 0.5;  // piedra: especiales pagan mitad
        dmg *= Amy_CalculateDashMultiplier(attacker, victim);
    }

    SDKHooks_TakeDamage(victim, attacker, attacker, dmg, DMG_CLUB);

    // jugo del impacto (solo victimas grandes: la horda muere sin VFX)
    if (isPlayer || isWitch)
    {
        float vPos[3];
        if (isPlayer) GetClientAbsOrigin(victim, vPos);
        else GetEntPropVector(victim, Prop_Send, "m_vecOrigin", vPos);
        vPos[2] += 40.0;
        Amy_VFX_Particle(vPos, AMY_PARTICLE_STRIKE_BURST, 1.5);
        EmitSoundToAll(AMY_SOUND_HIT_GEN, victim, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
        AmyDbg_Log("[PROPS v73] objeto tocó a %d: dano %.0f", victim, dmg);
    }
}

// v73: monitor de objetos lanzados (10 Hz). Vive mientras haya algo
// volando; muere con el mapa (NO_MAPCHANGE). Castiga los toques
// anotados y libera los slots muertos (refs inválidas).
public Action T_AmyPropTick(Handle timer)
{
    bool anyActive = false;
    float now = GetEngineTime();

    for (int s = 0; s < AMY_PROPS_TRACKED; s++)
    {
        if (g_iAmyPropRef[s] == INVALID_ENT_REFERENCE) continue;

        int ent = EntRefToEntIndex(g_iAmyPropRef[s]);
        if (ent == INVALID_ENT_REFERENCE || ent <= 0 || !IsValidEntity(ent))
        {
            // la entidad murió (piedra rota, prop destruido): slot libre
            Amy_PropFreeSlot(s);
            continue;
        }

        // castigo diferido del toque anotado por el hook
        Amy_PropProcessPending(s, ent);

        // v82 - RED B de atribución del tank (m_hPhysicsAttacker)
        Amy_PropCheckTankAttrib(s, ent);

        // v83 - LA CUSTODIA: el slot ya NO muere con el vuelo. Hoyo
        // v82: liberaba a los 4s o con "spd<60" HORIZONTAL — un auto
        // rebotando en VERTICAL leia spd=0 y quedaba DESPROTEGIDO en
        // pleno rebote (por eso el auto de Amy la seguía lastimando
        // a ELLA). Mientras la custodia viva: filtro anti-dano a
        // survivors + redes de atribución del tank encendidos.
        if (now >= g_fAmyPropGuardT[s])
        {
            Amy_PropFreeSlot(s);
            continue;
        }
        anyActive = true;   // vive mientras la custodia viva

        // v83: velocidad 3D — el rebote VERTICAL también es vuelo
        float vel[3];
        float spd = 0.0;
        if (HasEntProp(ent, Prop_Data, "m_vecVelocity"))
        {
            GetEntPropVector(ent, Prop_Data, "m_vecVelocity", vel);
            spd = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1] + vel[2] * vel[2]);
        }

        // v83: ventana de VUELO agotada -> custodia SIN motor (sin
        // re-impulso ni metralla: protección + atribución solamente)
        if (now >= g_fAmyPropEndT[s]) continue;
        // v74/v75 - RE-IMPULSO ("insistencia del tank"): el disparo
        // ahora es por VELOCIDAD o por DESPLAZAMIENTO REAL (la huella
        // de posición del slot). m_vecVelocity puede MENTIR en un
        // cuerpo dormido (retiene el 700 del teleport mientras el
        // objeto sigue clavado en el suelo), así que la posición real
        // es el detector de verdad. Cada re-impulso repite la receta
        // COMPLETA: GOLPE REAL (dano con fuerza, lo único que empuja
        // el cuerpo dormido) + inputs + el impulso guardado. La piedra
        // no entra aquí (boosts = 0 al registrarla).
        float nowPos[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", nowPos);
        float moved = GetVectorDistance(nowPos, g_vecAmyPropPos[s]);
        float want = SquareRoot(g_vecAmyPropVel[s][0] * g_vecAmyPropVel[s][0]
                              + g_vecAmyPropVel[s][1] * g_vecAmyPropVel[s][1]
                              + g_vecAmyPropVel[s][2] * g_vecAmyPropVel[s][2]);  // v83: 3D
        if (want < 100.0) want = 100.0;
        if (g_iAmyPropBoosts[s] > 0
            && (spd < want * AMY_PROP_REBOOST_RATIO || moved < AMY_PROP_STALL_DIST))
        {
            g_iAmyPropBoosts[s]--;

            // dirección del golpe real: la de la meta guardada (con
            // fallback defensivo si la meta fuera degenerada)
            float rdir[3];
            float rlen = SquareRoot(g_vecAmyPropVel[s][0] * g_vecAmyPropVel[s][0]
                                  + g_vecAmyPropVel[s][1] * g_vecAmyPropVel[s][1]);
            if (rlen > 1.0)
            {
                rdir[0] = g_vecAmyPropVel[s][0] / rlen;
                rdir[1] = g_vecAmyPropVel[s][1] / rlen;
            }
            else
            {
                rdir[0] = 0.0;
                rdir[1] = 1.0;
            }
            rdir[2] = 0.0;

            Amy_PropRealHit(GetClientOfUserId(g_iAmyPropOwnerUid[s]), ent,
                            rdir, nowPos);
            AcceptEntityInput(ent, "EnableMotion");
            AcceptEntityInput(ent, "EnablePhysics");
            AcceptEntityInput(ent, "Wake");
            // v76: el re-impulso repite la receta COMPLETA: despertador
            // nativo del motor + teleport de la meta guardada
            Amy_PropBlastWake(ent, rdir, nowPos);
            TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, g_vecAmyPropVel[s]);
            if (HasEntProp(ent, Prop_Data, "m_angVelocity"))
            {
                float spin[3];
                spin[0] = GetRandomFloat(-400.0, 400.0);
                spin[1] = GetRandomFloat(-400.0, 400.0);
                spin[2] = GetRandomFloat(-300.0, 300.0);
                SetEntPropVector(ent, Prop_Data, "m_angVelocity", spin);
            }
            AmyDbg_Log("[PROPS v75] re-impulso ent=%d: spd %.0f, movido %.1fu (quedan %d)",
                       ent, spd, moved, g_iAmyPropBoosts[s]);

            g_vecAmyPropPos[s][0] = nowPos[0];
            g_vecAmyPropPos[s][1] = nowPos[1];
            g_vecAmyPropPos[s][2] = nowPos[2];
            anyActive = true;
            continue;
        }

        // v83: retirado el "spd<60 -> liberar": la CUSTODIA decide
        // cuando soltar; un cuerpo frenado sigue protegido hasta el
        // final de su ventana (el rebote tardio no lastima a nadie)

        // v82 - METRALLA DE COMUNES: los objetos voladores de Amy
        // barren la horda a su paso (el motor no les aplica el dano
        // de aplastamiento — lo hace el monitor)
        if (g_iAmyPropLauncher[s] == AMY_PROPLAUNCH_AMY
            && spd >= AMY_PROP_COMMON_MIN_SPD)
        {
            Amy_PropSweepCommons(s, ent, now, nowPos);
        }

        // huella de posición para el detector de "no se mueve"
        g_vecAmyPropPos[s][0] = nowPos[0];
        g_vecAmyPropPos[s][1] = nowPos[1];
        g_vecAmyPropPos[s][2] = nowPos[2];

        anyActive = true;
    }

    if (!anyActive)
    {
        g_bAmyPropTimerOn = false;
        AmyDbg_Log("[PROPS v73] monitor detenido: nada volando");
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// ============================================================================
//  v75 - EL GOLPE REAL: dano con FUERZA al prop (la receta EXACTA del
//  punetazo del tank). El motor aplica la fuerza del dano al cuerpo
//  vphysics (ApplyForceOffset): es el ÚNICO camino que empuja y
//  DESPIERTA un cuerpo dormido de verdad (los inputs Wake/EnableMotion
//  solo tocan banderas; la velocidad del TeleportEntity la ignora el
//  cuerpo dormido — hallazgo R11 + la referencia charger_power del
//  owner: el charger solo mueve coches tras EMBESTIRLOS). Fuerza
//  ESCALADA POR MASA: el empujon físico real es amy_propwake_force u/s
//  para CUALQUIER objeto (auto de 1000 kg o barril de 40 kg) + lift
//  del 75% ("levantarlo del suelo y luego aventarlo"). Canon L4D2:
//  golpear un auto con alarma la ACTIVA (igual que el punetazo del
//  tank). Dano: amy_propwake_dmg (0 = golpe desactivado).
// ============================================================================
void Amy_PropRealHit(int attacker, int prop, const float dir[3], const float pos[3])
{
    if (g_fAmyPropWakeDmg <= 0.0) return;    // owner desactivo el golpe real
    if (!IsValidEntity(prop)) return;
    if (!Amy_IsValidClient(attacker)) attacker = 0;

    // masa del cuerpo (default 100 kg si el prop no la publica)
    float mass = 100.0;
    if (HasEntProp(prop, Prop_Data, "m_iMass"))
    {
        int m = GetEntProp(prop, Prop_Data, "m_iMass");
        if (m > 1) mass = float(m);
    }

    // fuerza = masa x empujon (impulso: mismo delta-v para cualquier
    // objeto) + componente vertical de "levantarlo" (75% del empujon)
    float force[3];
    force[0] = dir[0] * mass * g_fAmyPropWakeForce;
    force[1] = dir[1] * mass * g_fAmyPropWakeForce;
    force[2] = mass * g_fAmyPropWakeForce * 0.75;

    SDKHooks_TakeDamage(prop, attacker, attacker, g_fAmyPropWakeDmg,
                        DMG_CLUB, -1, force, pos);
}

// ============================================================================
//  v76 - EL DESPERTADOR NATIVO: env_physexplosion sobre el prop golpeado.
//  La fuerza del dano-con-fuerza NO esta garantizada (doc oficial
//  SDKHooks: "Force application is dependent on game and damage
//  type(s)") y el TeleportEntity solo escribe m_vecVelocity (que el
//  cuerpo dormido ignora — hallazgo R11). ESTO si lo hace el motor de
//  verdad: env_physexplosion es la receta del plugin de autos
//  explosivos que corre en este server (l4d_explosive_cars,
//  magnitude 300): la fuerza de explosión se aplica DIRECTO al cuerpo
//  vphysics y lo DESPIERTA (por eso un barril dormido vuela cuando
//  explota uno al lado). Centro DETRÁS-DEBAJO del objeto: el empuje
//  radial del motor sale hacia delante+arriba = "levantarlo del suelo
//  y luego aventarlo" (la receta del tank). Convar: amy_propwake_blast
//  (300.0; 0 = desactivado -> vuelve a confiar solo en el dano v75).
// ============================================================================
void Amy_PropBlastWake(int prop, const float dir[3], const float pos[3])
{
    if (g_fAmyPropWakeBlast <= 0.0) return;   // owner apago el despertador
    if (!IsValidEntity(prop)) return;

    // v79 - ESCALADO POR MASA: con magnitude FIJA, la misma explosión
    // que dispara un bolso de 20 kg no mueve un auto de 1500 kg (misma
    // fuerza, masa 75x: el motor reparte la fuerza entre la masa). El
    // auto recibe magnitude PROPORCIONAL a su masa = el mismo empujon
    // físico que el bolso (nunca menor que la base; tope 25000).
    float blastMass = 100.0;
    if (HasEntProp(prop, Prop_Data, "m_iMass"))
    {
        int bm = GetEntProp(prop, Prop_Data, "m_iMass");
        if (bm > 1) blastMass = float(bm);
    }
    float blastMag = g_fAmyPropWakeBlast * (blastMass / 100.0);
    if (blastMag < g_fAmyPropWakeBlast) blastMag = g_fAmyPropWakeBlast;
    if (blastMag > 25000.0) blastMag = 25000.0;

    // v79: el radio crece con el tamaño del cuerpo (un auto largo
    // necesita más cobertura que un bolso; tope 300)
    float blastRad = AMY_PROP_WAKE_RAD;
    if (blastMass > 300.0 && blastRad < blastMass / 10.0) blastRad = blastMass / 10.0;
    if (blastRad > 300.0) blastRad = 300.0;

    // centro detraz-abajo: el empuje radial sale adelante+arriba
    float center[3];
    center[0] = pos[0] - dir[0] * 35.0;
    center[1] = pos[1] - dir[1] * 35.0;
    center[2] = pos[2] - 25.0;

    int ex = CreateEntityByName("env_physexplosion");
    if (ex == -1 || !IsValidEntity(ex)) return;

    char sMag[16];
    IntToString(RoundToNearest(blastMag), sMag, sizeof(sMag));
    char sRad[16];
    IntToString(RoundToNearest(blastRad), sRad, sizeof(sRad));

    DispatchKeyValue(ex, "magnitude", sMag);
    DispatchKeyValue(ex, "radius", sRad);
    DispatchSpawn(ex);
    TeleportEntity(ex, center, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(ex, "Explode");
    AcceptEntityInput(ex, "Kill");   // la explosión es sincrona: limpieza inmediata (cero handles)

    AmyDbg_Log("[PROPS v76] despertador nativo: ent=%d magnitud=%s radio=%s centro=(%.0f %.0f %.0f)",
               prop, sMag, sRad, center[0], center[1], center[2]);
}

// v82: RETIRADAS Amy_IsVehicleModel / Amy_IsConvertibleDecorProp:
// quedaron sin callers al eliminar la conversión AUTOMÁTICA (regla
// 1 del owner: el mapa manda; física solo vía sm_amyfisica). Su
// texto completo vive en el historial (Amy_v81_backup.inc).

// v79 - SONDA DE PROPS: apuntar a cualquier objeto del mapa y escribir
// sm_amypropinfo — dice QUE es de verdad (clase, modelo, movetype,
// masa) y el veredicto: física real (lanzable) / decorativo
// convertible / geometria del mapa (ni el tank lo mueve). Se acabo
// adivinar por que "el auto no se mueve".
public Action Amy_CmdPropInfo(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Amy_IsValidClient(client)) return Plugin_Handled;

    float eye[3], ang[3];
    GetClientEyePosition(client, eye);
    GetClientEyeAngles(client, ang);

    Handle trace = TR_TraceRayFilterEx(eye, ang, MASK_ALL, RayType_Infinite,
                                       Amy_TraceFilter_LOS, client);
    if (!TR_DidHit(trace))
    {
        delete trace;
        PrintToChat(client, "\x04[AMY]\x01 No hay nada en la mira.");
        return Plugin_Handled;
    }
    int hit = TR_GetEntityIndex(trace);
    delete trace;

    if (hit <= 0)
    {
        PrintToChat(client, "\x04[AMY]\x01 Eso es GEOMETRIA DEL MAPA (mundo/estático): ni el tank puede moverlo.");
        return Plugin_Handled;
    }
    if (!IsValidEntity(hit))
    {
        PrintToChat(client, "\x04[AMY]\x01 Entidad inválida.");
        return Plugin_Handled;
    }

    static char cls[32], mdl[128];
    GetEntityClassname(hit, cls, sizeof(cls));
    GetEntPropString(hit, Prop_Data, "m_ModelName", mdl, sizeof(mdl));
    if (mdl[0] == '\0') strcopy(mdl, sizeof(mdl), "(sin modelo)");

    float mass = 0.0;
    if (HasEntProp(hit, Prop_Data, "m_iMass"))
        mass = float(GetEntProp(hit, Prop_Data, "m_iMass"));
    // v80: L4D2 reporta m_iMass=0 en muchos hittables (el "masa 100"
    // del martillo es el MISMO fallback). Sonda y chat ahora dicen
    // lo mismo — se acabo la confusión "0 antes / 100 después".
    if (mass <= 1.0) mass = 100.0;

    bool vphys = (GetEntityMoveType(hit) == MOVETYPE_VPHYSICS);

    PrintToChat(client, "\x04[AMY]\x01 ent=%d | clase: %s | movetype: %s | masa: %.0f",
                hit, cls, vphys ? "VPHYSICS" : "no-físico", mass);
    PrintToChat(client, "\x04[AMY]\x01 modelo: %s", mdl);
    if (vphys)
        PrintToChat(client, "\x04[AMY]\x01 FÍSICA REAL (V incorporado): el martillo/embestida lo lanza (si no vuela, acercate y reporta la masa).");
    else if (StrEqual(cls, "prop_dynamic", false)
             || StrEqual(cls, "prop_dynamic_override", false))
        // v82: TODO decorativo queda como el mapa lo puso (la conversión
        // automática se retiro). La física es MANUAL: sm_amyfisica.
        PrintToChat(client, "\x04[AMY]\x01 SIN FÍSICA (decorativo): queda como el mapa lo puso — el martillo NO lo toca. Física a mano: sm_amyfisica [masa] (ej: sm_amyfisica 500).");
    else
        PrintToChat(client, "\x04[AMY]\x01 SIN FÍSICA (estático): no lo mueve ni el tank. Si parece un auto, mandame el modelo de arriba.");

    AmyDbg_Log("[PROPS v79] propinfo: ent=%d cls=%s mdl=%s vphys=%d masa=%.0f",
               hit, cls, mdl, vphys ? 1 : 0, mass);
    return Plugin_Handled;
}

// ============================================================
//  v81 - INYECTOR MANUAL DE FÍSICA (sm_amyfisica). Petición del
//  owner: "habrá alguna posibilidad de darle física a objetos que
//  no tienen físicas?" — SI. El auto-convertidor v79 es CAUTELOSO
//  (solo vehiculos sin nombre/padre: la lógica del mapa queda
//  intocable), por eso el bus de la estación (prop_dynamic con
//  nombre o padre) salia "SIN FÍSICA". Este es el mando MANUAL:
//  mira el objeto, escribes el comando y nace un cuerpo físico
//  NUEVO en el mismo sitio. Masa opcional en kg (defecto 100 =
//  peso "hittable" que vuela bonito). Los avisos de nombre/padre
//  AVISAN pero no bloquean: es decisión del que escribe.
// ============================================================

// v81/v82: nucleo de conversión: decorativo -> cuerpo físico.
// Desde v82 la ÚNICA vía es el inyector MANUAL (sm_amyfisica), que
// usa asOverride=true -> prop_physics_override (ACEPTA modelos sin
// datos de física propios). massKg <= 0 = masa del modelo (no se
// toca). Devuelve el ente nuevo o -1.
int Amy_ConvertToPhysics(int oldProp, int massKg, bool asOverride)
{
    if (!IsValidEntity(oldProp)) return -1;

    static char mdl[128];
    GetEntPropString(oldProp, Prop_Data, "m_ModelName", mdl, sizeof(mdl));
    if (mdl[0] == '\0') return -1;

    float oldPos[3], oldAng[3];
    GetEntPropVector(oldProp, Prop_Send, "m_vecOrigin", oldPos);
    if (HasEntProp(oldProp, Prop_Data, "m_angRotation"))
        GetEntPropVector(oldProp, Prop_Data, "m_angRotation", oldAng);
    else if (HasEntProp(oldProp, Prop_Send, "m_angAbsAngles"))
        GetEntPropVector(oldProp, Prop_Send, "m_angAbsAngles", oldAng);
    else { oldAng[0] = 0.0; oldAng[1] = 0.0; oldAng[2] = 0.0; }

    int oldSkin = 0, oldBody = 0;
    if (HasEntProp(oldProp, Prop_Send, "m_nSkin")) oldSkin = GetEntProp(oldProp, Prop_Send, "m_nSkin");
    if (HasEntProp(oldProp, Prop_Send, "m_nBody")) oldBody = GetEntProp(oldProp, Prop_Send, "m_nBody");

    AcceptEntityInput(oldProp, "Kill");   // el decorado sale del mapa...

    int fresh = CreateEntityByName(asOverride ? "prop_physics_override" : "prop_physics");
    if (fresh == -1 || !IsValidEntity(fresh)) return -1;
    DispatchKeyValue(fresh, "model", mdl);
    if (oldSkin != 0)
    {
        char sSkin[12];
        IntToString(oldSkin, sSkin, sizeof(sSkin));
        DispatchKeyValue(fresh, "skin", sSkin);
    }
    if (oldBody != 0)
    {
        char sBody[12];
        IntToString(oldBody, sBody, sizeof(sBody));
        DispatchKeyValue(fresh, "body", sBody);
    }
    if (massKg > 0)
    {
        char sMass[12];
        IntToString(massKg, sMass, sizeof(sMass));
        DispatchKeyValue(fresh, "mass", sMass);   // masa fijada ANTES del spawn: la vphys nace con ella
    }
    DispatchSpawn(fresh);
    TeleportEntity(fresh, oldPos, oldAng, NULL_VECTOR);   // ...y entra con física al mismo sitio
    return fresh;
}

// v81: el comando. USO:
//   sm_amyfisica          -> mira un prop_dynamic, escribe: física YA
//   sm_amyfisica 800      -> idem con masa 800 kg
public Action Amy_CmdFisica(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Amy_IsValidClient(client)) return Plugin_Handled;

    int massKg = 100;   // el peso "hittable" estándar (vuela bonito)
    if (args >= 1)
    {
        char sMass[16];
        GetCmdArg(1, sMass, sizeof(sMass));
        int m = StringToInt(sMass);
        if (m >= 1 && m <= 100000) massKg = m;
    }

    float eye[3], ang[3];
    GetClientEyePosition(client, eye);
    GetClientEyeAngles(client, ang);

    Handle trace = TR_TraceRayFilterEx(eye, ang, MASK_ALL, RayType_Infinite,
                                       Amy_TraceFilter_LOS, client);
    if (!TR_DidHit(trace))
    {
        delete trace;
        PrintToChat(client, "\x04[AMY]\x01 No hay nada en la mira.");
        return Plugin_Handled;
    }
    int hit = TR_GetEntityIndex(trace);
    delete trace;

    if (hit <= 0)
    {
        PrintToChat(client, "\x04[AMY]\x01 Eso es GEOMETRIA DEL MAPA (mundo/estático de mapa): no hay entidad que convertir.");
        return Plugin_Handled;
    }
    if (!IsValidEntity(hit))
    {
        PrintToChat(client, "\x04[AMY]\x01 Entidad inválida.");
        return Plugin_Handled;
    }

    static char cls[32];
    GetEntityClassname(hit, cls, sizeof(cls));

    if (GetEntityMoveType(hit) == MOVETYPE_VPHYSICS)
    {
        PrintToChat(client, "\x04[AMY]\x01 %s: YA tiene física real — el martillo/embestida lo lanza tal cual.", cls);
        return Plugin_Handled;
    }

    if (!StrEqual(cls, "prop_dynamic", false)
        && !StrEqual(cls, "prop_dynamic_override", false))
    {
        PrintToChat(client, "\x04[AMY]\x01 Solo inyecto física a props de decorado (prop_dynamic). Eso es %s.", cls);
        return Plugin_Handled;
    }

    // avisos de lógica del mapa (AVISAN, no bloquean: decisión tuya)
    if (HasEntProp(hit, Prop_Data, "m_iName"))
    {
        static char nm[64];
        GetEntPropString(hit, Prop_Data, "m_iName", nm, sizeof(nm));
        if (nm[0] != '\0')
            PrintToChat(client, "\x04[AMY]\x01 OJO: tenía nombre '%s' — la lógica del mapa que lo usa puede romperse.", nm);
    }
    if (HasEntProp(hit, Prop_Data, "m_hMoveParent"))
    {
        int par = GetEntPropEnt(hit, Prop_Data, "m_hMoveParent");
        if (par != -1 && IsValidEntity(par))
            PrintToChat(client, "\x04[AMY]\x01 OJO: tenía padre (ent %d) — se convierte en su posición actual.", par);
    }

    static char mdl[128];
    GetEntPropString(hit, Prop_Data, "m_ModelName", mdl, sizeof(mdl));

    int fresh = Amy_ConvertToPhysics(hit, massKg, true);
    if (fresh == -1)
    {
        PrintToChat(client, "\x04[AMY]\x01 Conversión fallida (modelo '%s' sin datos).", mdl);
        return Plugin_Handled;
    }

    PrintToChat(client, "\x04[AMY]\x01 FÍSICA INYECTADA: %s | masa %d kg | ent=%d", mdl, massKg, fresh);
    PrintToChat(client, "\x04[AMY]\x01 Nace DESPIERTO: martillalo (Z) o embestelo. Peso a tu gusto: sm_amyfisica 50 (vuela) / 1000 (pesado).");
    AmyDbg_Log("[PROPS v81] FÍSICA MANUAL: ent=%d -> %d cls=prop_physics_override mdl=%s masa=%d",
               hit, fresh, mdl, massKg);
    return Plugin_Handled;
}

// ============================================================================
//  v86/v88 - OJOS DE AMY: el AURA de objetos. Petición del owner:
//  "Amy podrá ver que objetos son inyectables (apareceran resaltados
//  en color verde) y estaran en color rojo los que pueden ser
//  empujados (con V)"... y aclaración v88: "me refiero a que sea
//  rodeada por Un aura luminosa (como un objetivo que se ve azul, o
//  los compis en campañas no realistas)". v88 usa el GLOW del MOTOR
//  (m_iGlowType 3 SOLIDO + m_glowColorOverride + m_nGlowRange: el
//  MISMO sistema del outline de objetivos/compis — se dibuja alrededor
//  del modelo y ATRAVIESA paredes; la textura NO se toca):
//    - VERDE = INYECTABLE: decorativo sin V al que sm_amyfisica le
//      puede INYECTAR un cuerpo físico (prop_dynamic de vehiculo,
//      montacargas o dumpster — receta v79: el resto del decorado son
//      árboles/vallas y no interesa). El VERDE dice "este lo puedes
//      convertir". Al inyectarle la física, el decorativo muere y nace
//      uno NUEVO con V: al siguiente tick el escaner lo ve ROJO — el
//      ciclo completo (verde -> inyectar -> rojo -> martillazo) se ve
//      solo, sin comandos de diagnostico.
//    - ROJO = EMPUJABLE: objeto con V (VPHYSICS) incorporado de
//      fábrica — el martillo (Z) y la embestida lo empujan tal cual
//      (incluida la piedra del tank, que el martillo redirige).
//  v89: el aura vive en un CLON INVISIBLE del objeto (mismo modelo,
//  cuerpo TRANSTEXTURE alpha 1, glow SOLIDO + color puro) PARENTEADO
//  al original: el clon SOLO se transmite a los clientes Amy/Sage
//  (SDKHook_SetTransmit) — solo ELLAS ven el contorno a través de
//  paredes; el resto del servidor no recibe el clon y no nota NADA.
//  El objeto REAL queda VIRGEN (nada que restaurar: matar el clon
//  apaga el aura; el clon sigue al objeto si el martillo lo lanza).
//  Objetos con glow PROPIO del mapa (objetivos, items): NI TOCAR.
//  Sin handles: registro estático de AMY_VISION_MAX slots + UN timer
//  global NO_MAPCHANGE (AMY_VISION_TICK) que vive mientras alguna Amy
//  o SAGE VIVA exista (v87: automático, sin nada que activar) — muerta
//  la última, los clones mueren y se apaga solo; revive al respawn.
// ============================================================================
// v87/v89: encender el escaner si hay ALGUNA Amy o SAGE viva (automático, idempotente)
void Amy_VisionEnsureTimer()
{
    if (g_bAmyVisTimerOn) return;
    if (!g_bAmyVisEnabled) return;
    if (g_iAmyVisGlowClrOff <= 0) return;   // sin color override no hay aura

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        // v89 (R26): "Esto solo la puede notar amy (o sage)": Sage
        // también enciende el escaner (y también VE el aura)
        int idx = g_iPlayerCharIdx[i];
        if (idx != AMY_INDEX && idx != SAGE_INDEX) continue;

        g_bAmyVisTimerOn = true;
        CreateTimer(AMY_VISION_TICK, T_AmyVisionTick, _,
                    TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        return;
    }
}

// v86: ¿decorativo al que se le puede INYECTAR física? Mismo criterio
// que acepta sm_amyfisica (prop_dynamic/prop_dynamic_override sin V) +
// el modelo debe ser de vehiculo/montacargas/dumpster (los árboles y
// vallas del decorado no interesan: pintarlos todos sería ruido)
bool Amy_VisionGreenModel(int ent)
{
    static char mdl[128];
    GetEntPropString(ent, Prop_Data, "m_ModelName", mdl, sizeof(mdl));
    if (mdl[0] == '\0') return false;
    for (int i = 0; i < AMY_VISION_GREEN_PATTERNS; i++)
        if (StrContains(mdl, g_sAmyVisGreenMdl[i], false) != -1) return true;
    return false;
}

// v88/v89: clasificar + encender el aura si está en el radio de esta
// Amy o Sage. kind: 1 = VERDE (inyectable) | 2 = ROJO (empujable)
void Amy_VisionTryTint(int ent, const float eye[3], float rad2, int kind)
{
    if (kind == 1 && !Amy_VisionGreenModel(ent)) return;

    float pos[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
    float dx = pos[0] - eye[0];
    float dy = pos[1] - eye[1];
    float dz = pos[2] - eye[2];
    if (dx * dx + dy * dy + dz * dz > rad2) return;

    Amy_VisionTint(ent, kind);
}

// v89: encender el aura (o refrescar la vida de una que ya estaba).
// El aura vive en un CLON invisible parentado al objeto: SOLO Amy y
// Sage lo reciben (filtro de transmit). El objeto REAL jamás se toca.
void Amy_VisionTint(int ent, int kind)
{
    int slot = -1;
    for (int s = 0; s < AMY_VISION_MAX; s++)
    {
        if (g_iAmyVisRef[s] == INVALID_ENT_REFERENCE) continue;
        if (EntRefToEntIndex(g_iAmyVisRef[s]) != ent) continue;
        slot = s;
        break;
    }

    if (slot != -1)
    {
        g_fAmyVisLast[slot] = g_fAmyVisTickT;   // sigue visto: refrescar
        if (g_iAmyVisKind[slot] == kind)
        {
            // v89: ¿el clon sigue vivo? (limite de entidades o alguien
            // lo mató: raro). Si murió, re-encender abajo
            int clone = EntRefToEntIndex(g_iAmyVisClone[slot]);
            if (clone > 0 && IsValidEntity(clone)) return;
        }
        Amy_VisionFreeSlot(slot);   // cambio de clase o clon muerto: re-encender
    }

    // invisible A PROPÓSITO (lógica del mapa): ni tocar — su aura
    // delataria geometria escondida del mapa
    if (g_iAmyVisModeOff > 0
        && view_as<RenderMode>(GetEntData(ent, g_iAmyVisModeOff, 1)) == RENDER_NONE)
        return;

    // sin color override no hay aura posible (guarda ANTES de leer)
    if (g_iAmyVisGlowClrOff <= 0) return;

    // v88: m_iGlowType puede vivir solo en el datamap (según rama del
    // engine): resolución perezosa con la entidad en la mano
    if (g_iAmyVisGlowTypeOff <= 0)
    {
        g_iAmyVisGlowTypeOff = FindDataMapInfo(ent, "m_iGlowType");
        if (g_iAmyVisGlowTypeOff <= 0) return;   // sin glow: aura imposible
    }

    // ya tiene glow PROPIO del mapa (objetivo azul, item con glow...):
    // NO se pisa el trabajo del level designer (y encima el aura se
    // apilaba encima del suyo)
    if (GetEntData(ent, g_iAmyVisGlowTypeOff, 4) != 0) return;

    // slot nuevo (registro lleno: el objeto queda sin aura, sin error)
    slot = -1;
    for (int s = 0; s < AMY_VISION_MAX; s++)
        if (g_iAmyVisRef[s] == INVALID_ENT_REFERENCE) { slot = s; break; }
    if (slot == -1) return;

    int clone = Amy_VisionSpawnClone(ent, kind);
    if (clone == -1) return;   // sin modelo o sin entidades libres: sin aura

    g_iAmyVisRef[slot]   = EntIndexToEntRef(ent);
    g_iAmyVisClone[slot] = EntIndexToEntRef(clone);
    g_iAmyVisKind[slot]  = kind;
    g_fAmyVisLast[slot]  = g_fAmyVisTickT;
}

// v89: crear el CLON del aura. Misma geometria que el original (mismo
// modelo: la silueta luminosa abraza la forma REAL del objeto), cuerpo
// INVISIBLE (TRANSTEXTURE alpha 1: imperceptible) y el GLOW del motor
// (type 3 solido + color PURO + rango = radio de visión). Parentado al
// original: si el martillo lo lanza, el aura LO SIGUE. Sin modelo
// (brushes) o sin entidades libres: -1 (sin aura, sin error).
int Amy_VisionSpawnClone(int ent, int kind)
{
    static char mdl[128];
    GetEntPropString(ent, Prop_Data, "m_ModelName", mdl, sizeof(mdl));
    if (mdl[0] == '\0') return -1;

    int clone = CreateEntityByName("prop_dynamic_override");
    if (clone == -1) return -1;   // limite de edicts: degradación silenciosa

    PrecacheModel(mdl);
    DispatchKeyValue(clone, "model", mdl);
    DispatchKeyValue(clone, "targetname", AMY_VISION_CLONE_NAME);
    DispatchKeyValue(clone, "disableshadows", "1");
    DispatchSpawn(clone);

    // posición/angulos EXACTOS del original y parentado a el
    float pos[3], ang[3];
    GetEntPropVector(ent, Prop_Data, "m_vecOrigin", pos);
    GetEntPropVector(ent, Prop_Data, "m_angRotation", ang);
    TeleportEntity(clone, pos, ang, NULL_VECTOR);
    SetVariantString("!activator");
    AcceptEntityInput(clone, "SetParent", ent);

    // cuerpo imperceptible: la SILUETA la dibuja el pase de glow del
    // motor (alpha 1/255: jamás un doble fantasma visible)
    if (HasEntProp(clone, Prop_Send, "m_nRenderMode"))
        SetEntityRenderMode(clone, RENDER_TRANSTEXTURE);
    if (HasEntProp(clone, Prop_Send, "m_clrRender"))
        SetEntityRenderColor(clone, 255, 255, 255, 1);

    // v91 (FIX CINEMÁTICAS): el clon NUNCA es solido. Un
    // prop_dynamic_override nace SOLIDO (usa la malla de colisión del
    // modelo: autos/montacargas/dumpsters la tienen) y quedaba
    // superpuesto EXACTO al original físico: cuando la cinemática de
    // campaña (o cualquier evento de física) lanzaba el objeto, este
    // peleaba contra su propio clon invisible en el solver de vphysics
    // — el objeto saltaba/disparaba del sitio (el "se intercambia o no
    // se que pasa" del owner) y la escena se rompia. SOLID_NONE: el
    // clon es 100% visual, solo existe el glow.
    SetEntProp(clone, Prop_Data, "m_nSolidType", 0);   // SOLID_NONE
    SetEntProp(clone, Prop_Data, "m_CollisionGroup", 0); // y group NONE (cinturon y tirantes)

    // glow SOLIDO sobre el CLON (el objeto REAL queda VIRGEN)
    int color = kind == 1
        ? (AMY_VISION_GREEN_R | (AMY_VISION_GREEN_G << 8) | (AMY_VISION_GREEN_B << 16))
        : (AMY_VISION_RED_R   | (AMY_VISION_RED_G   << 8) | (AMY_VISION_RED_B   << 16));

    SetEntData(clone, g_iAmyVisGlowTypeOff, AMY_VISION_GLOWTYPE, 4, true);
    SetEntData(clone, g_iAmyVisGlowClrOff,  color, 4, true);
    if (g_iAmyVisGlowRangeOff > 0)
        SetEntData(clone, g_iAmyVisGlowRangeOff, RoundToNearest(g_fAmyVisRadius), 4, true);
    if (g_iAmyVisGlowRMinOff > 0)
        SetEntData(clone, g_iAmyVisGlowRMinOff, 0, 4, true);
    if (g_iAmyVisGlowTeamOff > 0)
        SetEntData(clone, g_iAmyVisGlowTeamOff, 0, 4, true);

    // v89: SOLO Amy y Sage reciben el clon -> solo ellas ven el aura.
    // El objeto REAL sigue transmitiéndose a todos: nadie más nota nada.
    SDKHook(clone, SDKHook_SetTransmit, Amy_AuraCloneTransmit);
    return clone;
}

// v89: filtro de transmisión del clon del aura. El clon SOLO viaja a
// los clientes cuyo personaje es Amy o Sage ("Esto solo la puede notar
// amy (o sage)"): para el resto de jugadores el clon NO EXISTE en su
// cliente y por tanto no dibujan ningún contorno.
public Action Amy_AuraCloneTransmit(int entity, int client)
{
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        int idx = g_iPlayerCharIdx[client];
        if (idx == AMY_INDEX || idx == SAGE_INDEX) return Plugin_Continue;
    }
    return Plugin_Handled;
}

// v89: liberar un slot MATANDO el clon del aura. El objeto REAL jamás
// fue tocado: no hay NADA que restaurar (sin clon no hay contorno).
// Si el clon ya murió solo (raro), el Kill sobre ref inválida se salta.
void Amy_VisionFreeSlot(int slot)
{
    if (g_iAmyVisClone[slot] != INVALID_ENT_REFERENCE)
    {
        int clone = EntRefToEntIndex(g_iAmyVisClone[slot]);
        if (clone > 0 && IsValidEntity(clone))
            AcceptEntityInput(clone, "Kill");
    }
    g_iAmyVisRef[slot]   = INVALID_ENT_REFERENCE;
    g_iAmyVisClone[slot] = INVALID_ENT_REFERENCE;
    g_iAmyVisKind[slot]  = 0;
    g_fAmyVisLast[slot]  = 0.0;
}

// v88/v89: reset total (arranque/map start/map end/round end+start/apagar):
// todos los clones de aura SE MATAN (el objeto real jamás se tocó: no
// hay nada que restaurar). NO toca el flag del timer (el escaner puede
// seguir vivo y re-encender: correcto)
void Amy_VisionResetAll()
{
    for (int s = 0; s < AMY_VISION_MAX; s++)
        Amy_VisionFreeSlot(s);
}

// v91: ¿esta el servidor en el intro/cinemática de campaña?
// (native de left4dhooks, marcada opcional en su .inc: se consulta
// con guard de feature para no reventar si faltara el binario)
bool Amy_InIntroCinematic()
{
    if (GetFeatureStatus(FeatureType_Native, "L4D_IsInIntro") != FeatureStatus_Available)
        return false;
    return view_as<bool>(L4D_IsInIntro());
}

// v88/v89: el escaner (AMY_VISION_TICK). Ve TODO prop_* en el radio
// (700) de cada Amy o SAGE viva — automático, sin nada que activar:
// con V -> AURA ROJA; decorativo de vehiculo sin V -> AURA VERDE (el
// clon se dibuja alrededor del modelo y atraviesa paredes; solo
// Amy/Sage lo reciben). Sin ninguna Amy/Sage viva: mata las auras y
// se apaga (Plugin_Stop); vuelve solo en el próximo spawn
// v91 (FIX CINEMÁTICAS): durante el intro/cinemática de campaña NO
// se spawnea NADA ni se mantiene NINGÚN clon vivo: los intros
// animan/lanzan sus props, son la escena más fragil del juego y
// cualquier entidad nueva parentada a un prop de la escena es un
// riesgo innecesario (el fix de no-solido v91 ya elimina el conflicto
// físico; esto además saca las entidades del medio del todo). El
// timer SIGUE vivo: al terminar el intro el próximo tick re-enciende
// las auras el solo.
public Action T_AmyVisionTick(Handle timer)
{
    if (!g_bAmyVisEnabled || g_iAmyVisGlowClrOff <= 0)
    {
        Amy_VisionResetAll();
        g_bAmyVisTimerOn = false;
        return Plugin_Stop;
    }

    // v91: intro de campaña en curso -> recoger clones y esperar
    if (Amy_InIntroCinematic())
    {
        Amy_VisionResetAll();
        return Plugin_Continue;   // sigue vivo: al acabar la intro retoma solo
    }

    float now = GetEngineTime();
    g_fAmyVisTickT = now;

    float rad2 = g_fAmyVisRadius * g_fAmyVisRadius;
    int maxEnt = GetMaxEntities();
    if (maxEnt <= MaxClients) maxEnt = 2048;

    bool anyViewer = false;

    for (int c = 1; c <= MaxClients; c++)
    {
        if (!IsClientInGame(c) || !IsPlayerAlive(c)) continue;
        // v89 (R26): el aura la ven (y la encienden) Amy y SAGE
        int idxC = g_iPlayerCharIdx[c];
        if (idxC != AMY_INDEX && idxC != SAGE_INDEX) continue;
        anyViewer = true;

        float eye[3];
        GetClientEyePosition(c, eye);

        // la piedra del tank (proyectil: su movetype no es VPHYSICS, el
        // pase agnostico no la ve; el martillo la redirige = empujable)
        int entity = -1;
        while ((entity = FindEntityByClassname(entity, "tank_rock")) != -1)
        {
            if (!IsValidEntity(entity)) continue;
            Amy_VisionTryTint(entity, eye, rad2, 2);
        }

        // pase agnostico: cualquier prop_* del mapa (el mismo criterio
        // del martillo v79/4c — un classname raro ya no es invisible
        // para la visión tampoco). v89: func_physbox FUERA (es un
        // BRUSH: sin modelo clonable no hay silueta posible)
        for (int e = MaxClients + 1; e < maxEnt; e++)
        {
            if (!IsValidEntity(e)) continue;

            static char cls[32];
            GetEntityClassname(e, cls, sizeof(cls));
            if (StrContains(cls, "prop_", false) != 0) continue;
            if (StrEqual(cls, "prop_ragdoll", false)) continue;   // cuerpos: fuera

            // v89: NUESTROS clones van fuera del escaner (sin esto el
            // clon de un coche verde entraría como "inyectable" y el
            // aura se re-crearia sobre si misma)
            if (StrEqual(cls, "prop_dynamic", false)
                || StrEqual(cls, "prop_dynamic_override", false))
            {
                static char nm[24];
                GetEntPropString(e, Prop_Data, "m_iName", nm, sizeof(nm));
                if (StrEqual(nm, AMY_VISION_CLONE_NAME, false)) continue;
            }

            int kind = 0;
            if (GetEntityMoveType(e) == MOVETYPE_VPHYSICS)
                kind = 2;   // con V incorporado: EMPUJABLE
            else if (StrEqual(cls, "prop_dynamic", false)
                     || StrEqual(cls, "prop_dynamic_override", false))
                kind = 1;   // decorativo: INYECTABLE (si el modelo es de vehiculo)
            if (kind == 0) continue;

            Amy_VisionTryTint(e, eye, rad2, kind);
        }
    }

    if (!anyViewer)
    {
        // nadie mirando: colores de vuelta y el escaner se apaga
        Amy_VisionResetAll();
        g_bAmyVisTimerOn = false;
        AmyDbg_Log("[VISION v89] escaner detenido: ninguna Amy/Sage viva (vuelve al próximo spawn)");
        return Plugin_Stop;
    }

    // lo que no se ha visto en AMY_VISION_STALE pierde su aura:
    // salió del radio, lo lanzaron lejos o murió (ref inválida)
    for (int s = 0; s < AMY_VISION_MAX; s++)
    {
        if (g_iAmyVisRef[s] == INVALID_ENT_REFERENCE) continue;
        int ent = EntRefToEntIndex(g_iAmyVisRef[s]);
        if (ent == INVALID_ENT_REFERENCE || ent <= 0 || !IsValidEntity(ent))
        {
            Amy_VisionFreeSlot(s);   // murió: nada que restaurar
            continue;
        }
        if (g_fAmyVisLast[s] < now - AMY_VISION_STALE)
            Amy_VisionFreeSlot(s);   // fuera de la vista: color original
    }

    return Plugin_Continue;
}

// ============================================================================
//  v73 - NUCLEO DEL MARTILLO PESADO: LANZAR (objeto quieto, "como el
//  tank") o REDIRIGIR (piedra del tank / objeto que viene hacia Amy).
// ============================================================================
void Amy_LaunchMapProp(int client, int prop, bool playJuice, bool fromImpulse)
{
    if (!Amy_IsValidClient(client)) return;
    if (!IsValidEntity(prop)) return;

    static char cls[32];
    GetEntityClassname(prop, cls, sizeof(cls));
    bool isRock = StrEqual(cls, "tank_rock", false);

    // v82 - FIN DE LA CONVERSION AUTOMÁTICA (petición del owner): la
    // Z convertia decorativos por su cuenta y el bus que hace de
    // ESCALERA en The Parish "simplemente desaparecía". Ahora TODO
    // queda como mando el mapa: el martillo SOLO mueve objetos con V
    // (VPHYSICS) incorporado de fábrica. La física se inyecta A MANO:
    // mira el objeto y escribe sm_amyfisica [masa]. (Defensa: los
    // escaneos ya no ven decorativos; esto atrapa cualquier otro
    // camino que llegue hasta aquí.)
    if (!isRock
        && (StrEqual(cls, "prop_dynamic", false)
            || StrEqual(cls, "prop_dynamic_override", false)))
    {
        if (playJuice)
            PrintToChat(client, "\x04[MARTILLO]\x01 %s SIN FÍSICA: queda como el mapa lo puso. Física a mano: sm_amyfisica [masa].", cls);
        AmyDbg_Log("[PROPS v82] decorativo ent=%d RECHAZADO: conversión automática retirada (usa sm_amyfisica)", prop);
        return;
    }

    float propPos[3];
    GetEntPropVector(prop, Prop_Send, "m_vecOrigin", propPos);

    // velocidad actual: un objeto ENTRANTE (punetazo de tank a un
    // coche hacia Amy) se REDIRIGE en vez de simplemente relanzarse
    float vel[3];
    float spd = 0.0;
    if (HasEntProp(prop, Prop_Data, "m_vecVelocity"))
    {
        GetEntPropVector(prop, Prop_Data, "m_vecVelocity", vel);
        spd = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
    }

    bool incoming = false;
    if (spd > AMY_PROP_MIN_INCOMING)
    {
        float myPos[3], toAmy[3];
        GetClientAbsOrigin(client, myPos);
        MakeVectorFromPoints(propPos, myPos, toAmy);
        float hLen = SquareRoot(toAmy[0] * toAmy[0] + toAmy[1] * toAmy[1]);
        if (hLen > 1.0)
        {
            float dot = (vel[0] * toAmy[0] + vel[1] * toAmy[1]) / (spd * hLen);
            incoming = (dot > AMY_PROP_INCOMING_DOT);
        }
    }
    bool redirect = isRock || incoming;

    // ---- dirección y velocidad ----
    float dir[3], launchVel[3];
    dir[0] = 0.0; dir[1] = 1.0; dir[2] = 0.0;

    if (redirect)
    {
        // devolución al remitente: al tank vivo más cercano al objeto
        // (auto-apuntado); sin tank vivo, a donde mira Amy
        int tank = Amy_FindNearestTank(propPos);
        if (tank > 0)
        {
            float tPos[3], toTank[3];
            GetClientAbsOrigin(tank, tPos);
            MakeVectorFromPoints(propPos, tPos, toTank);
            float hLen = SquareRoot(toTank[0] * toTank[0] + toTank[1] * toTank[1]);
            if (hLen > 0.001)
            {
                dir[0] = toTank[0] / hLen;
                dir[1] = toTank[1] / hLen;
            }
        }
        else
        {
            float eyeAng[3];
            GetClientEyeAngles(client, eyeAng);
            GetAngleVectors(eyeAng, dir, NULL_VECTOR, NULL_VECTOR);
            float hLen = SquareRoot(dir[0] * dir[0] + dir[1] * dir[1]);
            if (hLen > 0.001)
            {
                dir[0] /= hLen;
                dir[1] /= hLen;
            }
        }
        dir[2] = 0.0;

        launchVel[0] = dir[0] * g_fAmyPropRedirectSpeed;
        launchVel[1] = dir[1] * g_fAmyPropRedirectSpeed;
        // la piedra va en línea recta (50); los objetos con arco corto
        launchVel[2] = isRock ? 50.0 : 150.0;

        // la piedra pasa a ser de Amy: devolución certificada
        if (isRock)
        {
            if (HasEntProp(prop, Prop_Data, "m_hThrower"))
                SetEntPropEnt(prop, Prop_Data, "m_hThrower", client);
            if (HasEntProp(prop, Prop_Send, "m_hOwnerEntity"))
                SetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity", client);
        }
    }
    else
    {
        // v83 - LA MIRA MANDA (como el tank en VS): el objeto sale
        // hacia donde APUNTA Amy — DIRECCION y ALTURA según la mira.
        // Arriba = arco alto de verdad; recto = raso (con el pisito
        // de arco); abajo = rasante. (La vieja fórmula "lejos de
        // Amy con arco fijo 400" se retira.)
        float eyeAng[3], aim[3];
        GetClientEyeAngles(client, eyeAng);
        GetAngleVectors(eyeAng, aim, NULL_VECTOR, NULL_VECTOR);
        // horizontal unitario: para el GOLPE REAL y el DESPERTADOR
        // (la fuerza física empuja plano; la ALTURA viaja en launchVel)
        float hLen = SquareRoot(aim[0] * aim[0] + aim[1] * aim[1]);
        if (hLen < 0.001)
        {
            dir[0] = 0.0; dir[1] = 1.0;
        }
        else
        {
            dir[0] = aim[0] / hLen;
            dir[1] = aim[1] / hLen;
        }
        dir[2] = 0.0;

        // liberar la física COMPLETA (v74, se mantiene): EnableMotion
        // descongela props congelados por el mapa; Wake saca al cuerpo
        // del sueño. R11 probo que SOLO con inputs NO basta ("si el
        // tank no lo golpea, el objeto no despierta en si" - owner).
        AcceptEntityInput(prop, "EnableMotion");
        AcceptEntityInput(prop, "EnablePhysics");
        AcceptEntityInput(prop, "Wake");

        // v75 - EL GOLPE REAL (antes del aventon): dano con FUERZA
        // escalada por masa. Receta EXACTA del punetazo del tank: el
        // motor aplica esa fuerza al cuerpo vphysics y eso DESPIERTA
        // al dormido. La referencia del owner (charger power) hace lo
        // mismo: contacto físico primero, TeleportEntity después.
        // Orden: golpe real -> aventon sobre el cuerpo ya despierto.
        Amy_PropRealHit(client, prop, dir, propPos);

        // v76 - EL DESPERTADOR NATIVO: env_physexplosion en el cuerpo
        // (la receta del plugin de autos explosivos del server: el
        // motor aplica la fuerza DIRECTO al cuerpo vphysics dormido y
        // lo despierta — la ruta que si esta garantizada). Centro
        // detrás-abajo: el empuje radial sale adelante+arriba.
        Amy_PropBlastWake(prop, dir, propPos);

        // v76: feedback visible (prueba de vida del golpe en el chat,
        // solo el primer prop del tick: cero spam)
        if (playJuice)
        {
            float dbgMass = 100.0;
            if (HasEntProp(prop, Prop_Data, "m_iMass"))
            {
                int mm = GetEntProp(prop, Prop_Data, "m_iMass");
                if (mm > 1) dbgMass = float(mm);
            }
            if (fromImpulse)
                PrintToChat(client, "\x04[EMBESTIDA]\x01 %s: despertador nativo (masa %.0f) + lanzado hacia la mira", cls, dbgMass);
            else
                PrintToChat(client, "\x04[MARTILLO]\x01 %s: despertador nativo (masa %.0f) + lanzado hacia la mira", cls, dbgMass);
            AmyDbg_Log("[PROPS v85] %s ent=%d masa=%.0f blast=%.0f fuente=%s", cls, prop, dbgMass, g_fAmyPropWakeBlast, fromImpulse ? "EMBESTIDA" : "MARTILLO");
        }

        // v83: velocidad COMPLETA de la mira (pitch incluido) + el
        // pisito de arco: la mira horizontal/abajo no raspe el suelo.
        // v85: la embestida lanza con la MISMA fuerza completa del
        // martillo (revertida la reducción v84: el empuje de autos y
        // cosas vuelve a ser 100% compatible con el deslizamiento).
        launchVel[0] = aim[0] * g_fAmyPropLaunchForce;
        launchVel[1] = aim[1] * g_fAmyPropLaunchForce;
        launchVel[2] = aim[2] * g_fAmyPropLaunchForce;
        if (launchVel[2] < AMY_PROPLAUNCH_MINUP)
            launchVel[2] = AMY_PROPLAUNCH_MINUP;

        // volteo aleatorio: el coche sale girando (m_angVelocity)
        if (HasEntProp(prop, Prop_Data, "m_angVelocity"))
        {
            float spin[3];
            spin[0] = GetRandomFloat(-400.0, 400.0);
            spin[1] = GetRandomFloat(-400.0, 400.0);
            spin[2] = GetRandomFloat(-300.0, 300.0);
            SetEntPropVector(prop, Prop_Data, "m_angVelocity", spin);
        }
    }

    // v74: despertar la física también en la devolución (un objeto que
    // acaba de frenar contra algo vuelve a dormirse; los inputs son
    // gratis e inofensivos si ya esta despierto). La piedra no hace
    // falta: es proyectil, siempre simulado.
    if (!isRock)
    {
        AcceptEntityInput(prop, "EnableMotion");
        AcceptEntityInput(prop, "EnablePhysics");
        AcceptEntityInput(prop, "Wake");
    }

    TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, launchVel);

    // registrar + enganchar el toque (el dano lo aplica el monitor);
    // v74: la velocidad objetivo viaja con el registro para el
    // re-impulso del monitor
    Amy_PropTrack(client, prop, isRock, launchVel, fromImpulse);

    // jugo: burst rosa en el punto + sonido (el primero del tick; las
    // devoluciones siempre suenan: son el momento estrella)
    float vfxPos[3];
    vfxPos[0] = propPos[0]; vfxPos[1] = propPos[1]; vfxPos[2] = propPos[2] + 40.0;
    Amy_VFX_Particle(vfxPos, AMY_PARTICLE_STRIKE_BURST, 1.5);
    if (playJuice || redirect)
    {
        char snd[64];
        if (redirect) strcopy(snd, sizeof(snd), AMY_SOUND_HIT_TANK);
        else strcopy(snd, sizeof(snd), AMY_SOUND_HIT_GEN);
        EmitSoundToAll(snd, prop, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
    }
    if (isRock)
        PrintCenterText(client, "PIEDRA DEVUELTA!");

    if (redirect && isRock)
        AmyDbg_Log("[PROPS v73] PIEDRA DEVUELTA ent=%d por client=%d", prop, client);
    else if (redirect)
        AmyDbg_Log("[PROPS v73] REDIRIGIDO ent=%d cls=%s por client=%d", prop, cls, client);
    else
        AmyDbg_Log("[PROPS v73] LANZADO ent=%d cls=%s por client=%d (fuerza %.0f)",
                   prop, cls, client, g_fAmyPropLaunchForce);
}

// v66: golpe AOE por victima: fija la dirección de empuje (atacante ->
// victima, aplanada y normalizada) y delega en Amy_ImpulseHit (nucleo
// v64 con todo el jugo). El registro de "ya golpeado" lo lleva el
// barrido (Amy_SweepRegisterHit), igual que el impulso lo lleva el
// sweep del impulso.
void Amy_AOEHit(int attacker, int victim, const float attackerPos[3])
{
    if (victim <= 0 || !IsValidEntity(victim)) return;

    float victimPos[3];
    if (victim <= MaxClients) GetClientAbsOrigin(victim, victimPos);
    else GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);

    float dir[3];
    MakeVectorFromPoints(attackerPos, victimPos, dir);
    float len = SquareRoot(dir[0] * dir[0] + dir[1] * dir[1]);
    if (len < 0.001)
    {
        dir[0] = 0.0; dir[1] = 1.0;   // victim encima del atacante: al norte
    }
    else
    {
        dir[0] /= len;
        dir[1] /= len;
    }
    dir[2] = 0.0;

    g_fAmyImpulseDir[attacker][0] = dir[0];
    g_fAmyImpulseDir[attacker][1] = dir[1];
    g_fAmyImpulseDir[attacker][2] = 0.0;

    Amy_ImpulseHit(attacker, victim);
}

// ============================================================
//  v66 - Registro de golpeados del barrido AOE (patron v60:
//  array estático por cliente, CERO handles). Se vacía al
//  empezar cada golpe, al terminar, en OnMapStart/OnMapEnd y
//  en disconnect: imposible heredar estado de un barrido o de
//  un mapa anterior.
// ============================================================
bool Amy_SweepAlreadyHit(int client, int entity)
{
    for (int i = 0; i < g_iAmySweepHitCount[client]; i++)
        if (g_iAmySweepHits[client][i] == entity) return true;
    return false;
}

void Amy_SweepRegisterHit(int client, int entity)
{
    if (g_iAmySweepHitCount[client] >= AMY_AOE_MAX_HITS) return; // lleno: se ignora (solo evita doble golpe)
    g_iAmySweepHits[client][g_iAmySweepHitCount[client]++] = entity;
}

// ============================================================================
//  v66 - VFX DEL PRESS AOE (restaurado del v12): ring rosa expansivo +
//  ring secundario hot + screen shake LOCAL (radio 200: no molesta a los
//  demas). Usa BeamRing (temp entities de vida corta: cero entidades
//  creadas) y el shake del motor: la misma pieza que funciono desde la
//  v1 sin un solo crash.
// ============================================================================
void Amy_VFX_Strike(int attacker)
{
    if (!Amy_IsValidClient(attacker)) return;

    float pos[3];
    GetClientAbsOrigin(attacker, pos);
    pos[2] += 30.0;

    // v52: log de sprites (si el índice fuera inválido en un mapa nuevo,
    // aquí se ve: sprite 0 en un TE = crash del cliente)
    AmyDbg_Log("[VFX] Strike: sprites beam=%d halo=%d", g_iAmyBeamSprite, g_iAmyHaloSprite);

    // Ring expansivo rosa chillon
    Amy_VFX_BeamRing(pos, 10.0, AMY_VFX_STRIKE_RADIUS,
                     AMY_COLOR_PINK_R, AMY_COLOR_PINK_G, AMY_COLOR_PINK_B, 255,
                     AMY_VFX_STRIKE_RING_LIFE, 8.0);

    // Ring secundario más pequeño y rápido (rosa hot)
    Amy_VFX_BeamRing(pos, 5.0, 100.0,
                     AMY_COLOR_PINK_HOT_R, AMY_COLOR_PINK_HOT_G, AMY_COLOR_PINK_HOT_B, 200,
                     AMY_VFX_STRIKE_RING_LIFE * 0.5, 4.0);

    // Pequeño screen shake local (no molesta a otros jugadores)
    Amy_VFX_ScreenShake(pos, 4.0, 200.0, 0.3);
}

// ============================================================================
//  v61 - TICK DEL IMPULSO (20 Hz)
//   - El timer recibe SOLO el userid (un int): no transporta handles ni
//     datos que puedan quedar colgados al girar el mapa. Con
//     TIMER_FLAG_NO_MAPCHANGE, el core de SourceMod lo mata en el cambio
//     de mapa y no queda NADA que liberar.
//   - El registro de entidades golpeadas es un ARRAY ESTÁTICO por cliente
//     (g_iAmyImpulseHits), no un ArrayList.
//   - Se conserva el patron v49 (snapshot-then-strike: nunca se mata una
//     entidad mientras se itera la lista) y el LOS v53 (nada se golpea a
//     través de paredes).
//   - IMPARABLE: cada tick se liberan los agarres (camino del motor), se
//     cancela el tropiezo y se REAFIRMA la velocidad: ni un golpe de Tank
//     ni un hunter/jockey/smoker/charger la detienen más de 1 tick.
// ============================================================================
public Action T_AmyImpulseTick(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);

    // Fin: cliente inválido (desconecto/murió), ya no es Amy, o el estado
    // fue reseteado por otro camino (round_start/mapchange/disconnect).
    if (!Amy_IsValidClient(client) || g_iPlayerCharIdx[client] != AMY_INDEX
        || !g_bAmyImpulseActive[client])
    {
        if (client > 0 && client <= MaxClients) Amy_ImpulseEnd(client, false);
        AmyDbg_Log("[IMPULSE] fin (userid=%d inválido o estado reseteado)", userid);
        return Plugin_Stop;
    }

    // Fin: duración agotada
    if (GetEngineTime() >= g_fAmyImpulseEndT[client])
    {
        Amy_ImpulseEnd(client, false);
        return Plugin_Stop;
    }

    // Fin: incapacitada o colgando de un borde (el impulso no la salva de
    // la incap: solo de los agarres y tropiezos)
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated")
        || GetEntProp(client, Prop_Send, "m_isHangingFromLedge"))
    {
        Amy_ImpulseEnd(client, false);
        return Plugin_Stop;
    }

    float pos[3];
    GetClientAbsOrigin(client, pos);

    // Fin: distancia máxima recorrida
    if (GetVectorDistance(g_fAmyImpulseStartPos[client], pos) >= g_fAmyImpulseMaxDist)
    {
        AmyDbg_Log("[IMPULSE] client=%d: distancia máxima alcanzada", userid);
        Amy_ImpulseEnd(client, false);
        return Plugin_Stop;
    }

    // v78/v85 - Fin o EMPUJE: lo que hay delante (mundo/props/puertas;
    // las criaturas no cuentan; rayo desde los OJOS para que
    // rampas/escaleras no corten el impulso). Un prop con física
    // delante YA NO ES PARED: se EMPUJA con la receta COMPLETA (v85:
    // revertida la reducción v84) y la embestida ATRAVIESA — la
    // receta del charger de la referencia del owner
    // (l4d2_charger_power: contacto físico -> el coche sale empujado).
    // Puertas y props sin física siguen frenando la embestida.
    int wallEnt = Amy_ImpulseWallAhead(client);
    if (wallEnt != -1)
    {
        if (wallEnt > 0 && Amy_ImpulseSmashProp(client, wallEnt))
        {
            // prop reventado (o ya reventado en esta embestida): SIGUE
        }
        else
        {
            AmyDbg_Log("[IMPULSE] client=%d: pared delante. FIN del impulso", userid);
            Amy_ImpulseEnd(client, true);
            return Plugin_Stop;
        }
    }

    // v64 - FIN: SEGURO DE VACÍO. Si va pegada al suelo y delante (en
    // la dirección de la embestida) NO hay suelo, es un precipicio: el
    // impulso frena EN SECO en el borde en vez de lanzarla al vacío
    // ("evitar caer al vacío si el impulso se pasa", a petición). En
    // el aire o subiendo (salto/escalera) NO se aplica: ese control lo
    // tienes tu (mirada + 2a pulsación).
    if (Amy_ImpulseVoidAhead(client))
    {
        AmyDbg_Log("[IMPULSE] client=%d: vacío delante: frenada en el borde", userid);
        Amy_ImpulseEnd(client, true);
        if (IsClientInGame(client) && IsPlayerAlive(client))
        {
            float vvel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vvel);
            vvel[0] *= 0.05;   // frenado horizontal TOTAL: clavada en el borde
            vvel[1] *= 0.05;
            vvel[2] *= 0.2;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vvel);
        }
        return Plugin_Stop;
    }

    // ============================================================
    //  IMPARABLE: romper TODO lo que intente detenerla
    // ============================================================

    // 1) Agarres: liberar POR EL CAMINO DEL MOTOR (PinRelease v2.0:
    //    L4D_Hunter_ReleaseVictim / L4D_Smoker_ReleaseVictim /
    //    L4D2_Jockey_EndRide / L4D2_Charger_EndPummel/EndCarry). El
    //    atacante queda tambaleado (anti re-grab inmediato).
    if (Diva_IsBeingGrappled(client))
    {
        AmyDbg_Log("[IMPULSE] client=%d AGARRADO en pleno impulso: liberando por el camino del motor", userid);
        PinRelease_Cleanse(client);
    }

    // 2) Tropiezos (golpe de Tank, carga de Charger): cancelar el estado
    //    de stagger del motor. No-op inofensivo si ya esta de pie (mismo
    //    uso de red de seguridad que hace SI_Stagger).
    AmyImpulse_CancelStagger(client);

    // 3) Velocidad: REAFIRMAR la línea del impulso. Ningún empujon la
    //    desvia: la componente vertical se conserva (gravedad/suelo).
    //    v63 - ASISTENTE DE ESCALERAS: FLYGRAVITY no "sube escalones"
    //    como el caminar (no hay step-up): si la velocidad REAL se ha
    //    quedado por debajo de la mitad de la de la embestida, hay un
    //    escalon/bordillo transitable frenándola (la pared de verdad ya
    //    habría terminado el impulso). Se le da un impulso vertical
    //    corto para saltarse el escalon, como un Charger tropezando
    //    hacia arriba.
    //
    //    v64 - DIRECCION GUIADA: la embestida SIGUE LA MIRADA. Girar el
    //    raton curva suavemente la línea del impulso (blend 0.12 por
    //    tick: control total sin derrapar) para esquivar el vacío o
    //    ajustar la salida.
    float eyeAng[3], fwdAim[3];
    GetClientEyeAngles(client, eyeAng);
    GetAngleVectors(eyeAng, fwdAim, NULL_VECTOR, NULL_VECTOR);
    float aimX = fwdAim[0], aimY = fwdAim[1];
    float aimLen = SquareRoot(aimX * aimX + aimY * aimY);
    if (aimLen > 0.001)
    {
        aimX /= aimLen;
        aimY /= aimLen;
        float blend = AMY_IMPULSE_STEER_BLEND;
        float nx = g_fAmyImpulseDir[client][0] * (1.0 - blend) + aimX * blend;
        float ny = g_fAmyImpulseDir[client][1] * (1.0 - blend) + aimY * blend;
        float nLen = SquareRoot(nx * nx + ny * ny);
        if (nLen > 0.001)
        {
            g_fAmyImpulseDir[client][0] = nx / nLen;
            g_fAmyImpulseDir[client][1] = ny / nLen;
        }
    }

    float vel[3], impulseVel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    impulseVel[0] = g_fAmyImpulseDir[client][0] * g_fAmyImpulseSpeed;
    impulseVel[1] = g_fAmyImpulseDir[client][1] * g_fAmyImpulseSpeed;
    impulseVel[2] = vel[2];
    float spdH = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
    if (spdH < g_fAmyImpulseSpeed * 0.5 && vel[2] < 100.0)
        impulseVel[2] = 250.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, impulseVel);

    // 4) v62: REAFIRMAR el tope de velocidad EN TIERRA (red de
    //    seguridad: en FLYGRAVITY no aplica, pero si algo revierte el
    //    movetype a WALK a mitad de tick, al menos no la clava a ~220).
    Amy_ImpulseSetMaxSpeed(client, g_fAmyImpulseSpeed + 50.0);

    // 5) v63: REAFIRMAR el movetype del vuelo. Si un pin/agarre/estado
    //    del motor lo revirtio a WALK, la fricción y el clampeo del
    //    suelo frenarian la embestida en el siguiente frame: se pone
    //    otra vez. (La hace doblemente imparable: ningún estado del
    //    motor le roba el control del movimiento.)
    if (GetEntityMoveType(client) != MOVETYPE_FLYGRAVITY)
    {
        SetEntityMoveType(client, MOVETYPE_FLYGRAVITY);
        AmyDbg_Log("[IMPULSE] client=%d: movetype revertido por el motor: FLYGRAVITY reafirmado", userid);
    }

    // ============================================================
    //  DANAR Y EMPUJAR TODO LO QUE ESTE A SU PASO
    // ============================================================
    Amy_ImpulseSweep(client);

    return Plugin_Continue;
}

// ============================================================================
//  v78 - DETECCION DE PARED DELANTE (rework del v61/v62). Ahora devuelve
//  QUE hay delante en vez de un simple si/no:
//     -1 = nada (o subida transitable): el impulso SIGUE
//      0 = muro de verdad (mundo no transitable): FIN del impulso
//     >0 = índice de la ENTIDAD solida delante (prop/puerta). El caller
//          decide: si es un prop LANZABLE (v78: auto, barril, dumpster,
//          func_physbox, piedra) se REVENTA y la embestida ATRAVIESA; si
//          no (puerta, prop solido sin física) es pared y fin.
//  El rayo sigue saliendo de los OJOS (v62: rampas transitables no cortan
//  el impulso) con el filtro LOS (las criaturas no cuentan como pared).
// ============================================================================
int Amy_ImpulseWallAhead(int client)
{
    float eyePos[3], endPos[3];
    GetClientEyePosition(client, eyePos);
    endPos[0] = eyePos[0] + g_fAmyImpulseDir[client][0] * AMY_IMPULSE_WALL_AHEAD;
    endPos[1] = eyePos[1] + g_fAmyImpulseDir[client][1] * AMY_IMPULSE_WALL_AHEAD;
    endPos[2] = eyePos[2] + g_fAmyImpulseDir[client][2] * AMY_IMPULSE_WALL_AHEAD;

    Handle trace = TR_TraceRayFilterEx(eyePos, endPos, MASK_SOLID, RayType_EndPoint,
                                        Amy_TraceFilter_LOS, client);
    if (TR_DidHit(trace))
    {
        // v62: una superficie solo es PARED si NO es caminable (normal
        // empinada) o si es una ENTIDAD (prop/puerta). Las rampas se
        // suben corriendo, como haría un Charger.
        float normal[3];
        TR_GetPlaneNormal(trace, normal);
        int hitEnt = TR_GetEntityIndex(trace);
        delete trace;

        if (hitEnt > 0) return hitEnt;                        // entidad solida: el caller decide
        if (normal[2] < AMY_IMPULSE_WALK_NORMAL_Z) return 0;  // muro de verdad
        AmyDbg_Log("[IMPULSE] subida transitable delante (normal.z=%.2f): el impulso SIGUE",
                   normal[2]);
        return -1;
    }
    delete trace;
    return -1;
}

// v78: ¿es un objeto que la embestida puede REVENTAR? (clases con física
// del martillo + la piedra del tank). Una puerta o un prop sin física, no.
bool Amy_IsLaunchableProp(int ent)
{
    if (!IsValidEntity(ent)) return false;

    static char cls[32];
    GetEntityClassname(ent, cls, sizeof(cls));
    if (StrEqual(cls, "tank_rock", false)) return true;
    for (int i = 0; i < AMY_PROP_CLASSES; i++)
        if (StrEqual(cls, g_sAmyPropClasses[i], false)) return true;
    // v79: agnostico de classname — cualquier "prop_*" con cuerpo
    // VPHYSICS es lanzable (un auto con clase rara ya no es invisible)
    if (StrContains(cls, "prop_", false) == 0
        && GetEntityMoveType(ent) == MOVETYPE_VPHYSICS
        && !StrEqual(cls, "prop_ragdoll", false)) return true;
    // v82: el DECORATIVO ya NO se revienta (conversión automática
    // retirada: todo queda como el mapa lo puso; física manual con
    // sm_amyfisica — la embestida lo trata como pared, como antes)
    return false;
}

// v78/v85 - LA EMBESTIDA DEL CHARGER: golpear un prop de frente y
// SEGUIR. Lo EMPUJA con la receta COMPLETA del martillo (v85:
// revertida la reducción v84 — golpe real + despertador 130-300 +
// aventon 700 + volteo lleno) y el monitor SIN re-impulsos para el
// objeto empujado (0 empujones adicionales: solo el empuje
// principal). Devuelve false si no era lanzable (el caller lo
// trata como pared).
bool Amy_ImpulseSmashProp(int client, int ent)
{
    if (!Amy_IsLaunchableProp(ent)) return false;

    // 1 golpe por objeto por embestida (mismo registro del impulso que
    // usan las criaturas: imposible re-golpear en la misma corrida)
    if (Amy_ImpulseAlreadyHit(client, ent))
    {
        // ya reventado en ESTA embestida: se ATRAVIESA sin re-golpear
        // (el objeto recien despierto ya está saliendo volando)
        return true;
    }
    Amy_ImpulseRegisterHit(client, ent);

    // v85 - REVERTIDA LA REDUCCION: el objeto embestido sale con la
    // receta COMPLETA del martillo otra vez (mismo poder que la Z:
    // "el empuje de autos y cosas será compatible con el
    // deslizamiento"). La ÚNICA regla propia de la embestida: el
    // objeto empujado recibe 0 re-impulsos (solo el empuje
    // principal). La mira v83 sigue mandando y la protección/
    // custodia v83 cubre el objeto empujado.
    Amy_LaunchMapProp(client, ent, true, true);
    AmyDbg_Log("[IMPULSE v85] prop %d EMPUJADO de frente (receta completa, un solo empuje) por la embestida: SIGUE", ent);
    return true;
}

// ============================================================================
//  v62 - TOPE DE VELOCIDAD EN TIERRA (m_flMaxspeed)
//  El motor de L4D2 limita la velocidad horizontal de un superviviente
//  EN EL SUELO a m_flMaxspeed (~220 con arma): el camino aéreo (AirMove)
//  NO aplica ese limite. Por eso el impulso de la v61 volaba a 900 en el
//  aire y "apenas se movía unos cm" en el suelo: el TeleportEntity ponía
//  900 y el primer tick de suelo clampeaba al tope. Durante el impulso se
//  eleva el tope a la velocidad de la embestida; al terminar se restaura
//  el valor original. Escritura por Prop_Send (como los plugins de
//  velocidad de L4D2) con fallback a Prop_Data por si la tabla varia.
// ============================================================================
float Amy_ImpulseGetMaxSpeed(int client)
{
    if (!IsClientInGame(client)) return 0.0;
    if (HasEntProp(client, Prop_Send, "m_flMaxspeed"))
        return GetEntPropFloat(client, Prop_Send, "m_flMaxspeed");
    if (HasEntProp(client, Prop_Data, "m_flMaxspeed"))
        return GetEntPropFloat(client, Prop_Data, "m_flMaxspeed");
    return 0.0;
}

void Amy_ImpulseSetMaxSpeed(int client, float value)
{
    if (!IsClientInGame(client)) return;
    if (value < 1.0) return;
    if (HasEntProp(client, Prop_Send, "m_flMaxspeed"))
        SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", value);
    else if (HasEntProp(client, Prop_Data, "m_flMaxspeed"))
        SetEntPropFloat(client, Prop_Data, "m_flMaxspeed", value);
}

// ============================================================================
//  v61 - FIN DEL IMPULSO
//  Limpia el estado (arrays) y frena a Amy con suavidad para que no salga
//  deslizándose a velocidad de embestida cuando el impulso termina.
// ============================================================================
void Amy_ImpulseEnd(int client, bool hitWall)
{
    if (client <= 0 || client > MaxClients) return;

    bool wasFlying = g_bAmyImpulseActive[client];   // v63: restaurar movetype
    g_bAmyImpulseActive[client] = false;
    g_fAmyImpulseEndT[client] = 0.0;
    g_iAmyImpulseHitCount[client] = 0;

    // v62: devolver el tope de velocidad normal (el impulso lo alzo para
    // que el clamp del suelo no frenara la embestida). Guard: si nunca se
    // guardo (fin por camino atipico), el propio motor lo recalcula al
    // cambiar de arma o al hacer spawn: no se toca nada.
    if (IsClientInGame(client) && g_fAmyImpulseSavedMaxSpd[client] > 1.0)
    {
        Amy_ImpulseSetMaxSpeed(client, g_fAmyImpulseSavedMaxSpd[client]);
        AmyDbg_Log("[IMPULSE] fin: m_flMaxspeed restaurado a %.0f", g_fAmyImpulseSavedMaxSpd[client]);
    }
    g_fAmyImpulseSavedMaxSpd[client] = 0.0;

    // v63: devolver el movetype de caminar. La embestida corre en
    // FLYGRAVITY: sin esto Amy se quedaría flotando al terminar. Solo
    // si estaba volando de verdad (wasFlying) y sigue en juego: si murió
    // en plena embestida, el motor ya gestiona el cuerpo por su cuenta.
    if (wasFlying && IsClientInGame(client))
    {
        SetEntityMoveType(client, MOVETYPE_WALK);
        AmyDbg_Log("[IMPULSE] fin: movetype restaurado a WALK");

        // v64: devolver el grupo de colisión normal (la embestida
        // atraviesa cuerpos; al terminar vuelve a colisionar con ellos)
        if (g_iAmyImpulseSavedColGroup[client] > 0)
            SetEntProp(client, Prop_Data, "m_CollisionGroup", g_iAmyImpulseSavedColGroup[client]);
        g_iAmyImpulseSavedColGroup[client] = 0;
        g_fAmyImpulseLastJuice[client] = 0.0;
    }

    if (IsClientInGame(client) && IsPlayerAlive(client))
    {
        float vel[3], endVel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        float scale = hitWall ? 0.15 : 0.35;   // contra pared frena más
        endVel[0] = vel[0] * scale;
        endVel[1] = vel[1] * scale;
        endVel[2] = vel[2];
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, endVel);
        AmyDbg_Log("[IMPULSE] fin (pared=%d): velocidad frenada x%.2f", hitWall ? 1 : 0, scale);
    }
    else
    {
        AmyDbg_Log("[IMPULSE] fin (cliente muerto/fuera del juego)");
    }
}

// ============================================================================
//  v61 - CANCELAR EL TROPIEZO (la pieza "imparable" ante el Tank)
//  L4D_CancelStagger es la función del motor que termina el estado de
//  stumble (la MISMA que SI_Stagger usa como red de seguridad: no-op
//  inofensivo si no hay stagger activo). Feature-check porque la native
//  es opcional en left4dhooks viejos.
// ============================================================================
static bool g_bAmyImpStagChecked = false;
static bool g_bAmyImpStagOK = false;

void AmyImpulse_CancelStagger(int client)
{
    if (!g_bAmyImpStagChecked)
    {
        g_bAmyImpStagChecked = true;
        g_bAmyImpStagOK = true;
        if (CanTestFeatures())
        {
            g_bAmyImpStagOK = (GetFeatureStatus(FeatureType_Native, "L4D_CancelStagger")
                               == FeatureStatus_Available);
        }
    }
    if (!g_bAmyImpStagOK) return;

    L4D_CancelStagger(client);
}

// ============================================================================
//  v61 - BARRIDO DEL IMPULSO (dano y empuje a todo lo que este a su paso)
//  Radio amy_impulse_radius alrededor de Amy, CON LÍNEA DE VISION (v53:
//  nada se golpea a través de paredes). Cada victima se golpea UNA sola
//  vez por impulso (registro estático). Aliados: SOLO empuje, sin dano.
// ============================================================================
void Amy_ImpulseSweep(int client)
{
    float eyePos[3], myPos[3];
    GetClientEyePosition(client, eyePos);
    GetClientAbsOrigin(client, myPos);
    float range = g_fAmyImpulseRadius;

    int siFound = 0, commFound = 0, witchFound = 0, teamFound = 0, siPlowed = 0;

    // --- 1. Jugadores: especiales/tank (dano + hard-stop) y aliados
    //        (solo empuje, una vez por impulso) ---
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;

        if (GetClientTeam(i) == TEAM_SURVIVOR)
        {
            if (!g_bAmyImpulsePushTeam) continue;
            if (Amy_ImpulseAlreadyHit(client, i)) continue;
            if (GetEntProp(i, Prop_Send, "m_isIncapacitated")) continue;

            float targetPos[3]; GetClientAbsOrigin(i, targetPos); targetPos[2] += 40.0;
            if (Amy_IsTargetInArea(myPos, targetPos, range))
            {
                if (!Amy_HasLineOfSight(client, eyePos, targetPos)) continue;

                float push[3];
                push[0] = g_fAmyImpulseDir[client][0] * g_fAmyStrikeForce;
                push[1] = g_fAmyImpulseDir[client][1] * g_fAmyStrikeForce;
                // v68: arco de aliados (levantamiento visible, sin dano)
                push[2] = AMY_LAUNCH_UP_ALLY;
                TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
                Amy_ImpulseRegisterHit(client, i);
                teamFound++;
            }
            continue;
        }

        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float targetPos[3]; GetClientAbsOrigin(i, targetPos); targetPos[2] += 40.0;
        if (Amy_IsTargetInArea(myPos, targetPos, range))
        {
            if (!Amy_HasLineOfSight(client, eyePos, targetPos))
            {
                AmyDbg_Log("[IMPULSE] SI %d fuera de línea de visión (pared): ignorado", i);
                continue;
            }

            // v64 - ARIETE: si ya fue golpeado pero SIGUE delante (en la
            // línea de la embestida), se le sigue EMPUJANDO cada tick sin
            // re-danarlo: especiales, boomers y tank van POR DELANTE de
            // Amy como delante de un ariete, hasta salir de su línea.
            // ("que pudiera empujar también a los tank y los otros
            // especiales", a petición del usuario).
            if (Amy_ImpulseAlreadyHit(client, i))
            {
                float toV[3];
                MakeVectorFromPoints(myPos, targetPos, toV);
                toV[2] = 0.0;
                float toLen = SquareRoot(toV[0] * toV[0] + toV[1] * toV[1]);
                if (toLen > 0.001)
                {
                    float fwdDot = (toV[0] / toLen) * g_fAmyImpulseDir[client][0]
                                 + (toV[1] / toLen) * g_fAmyImpulseDir[client][1];
                    if (fwdDot > 0.2)
                    {
                        float plow[3];
                        plow[0] = g_fAmyImpulseDir[client][0] * (g_fAmyImpulseSpeed + 150.0);
                        plow[1] = g_fAmyImpulseDir[client][1] * (g_fAmyImpulseSpeed + 150.0);
                        plow[2] = 60.0;
                        TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, plow);
                        siPlowed++;
                    }
                }
                continue;
            }

            Amy_ImpulseHit(client, i);
            Amy_ImpulseRegisterHit(client, i);
            siFound++;
        }
    }

    // --- 2. Comunes: snapshot primero (v49: nunca matar mientras se itera),
    //        LOS, tope por tick (el resto de la horda entra en el próximo) ---
    int commons[AMY_IMPULSE_MAX_PER_TICK];
    int nCommons = 0;
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (nCommons >= AMY_IMPULSE_MAX_PER_TICK) break;
        if (!IsValidEntity(entity)) continue;
        if (Amy_ImpulseAlreadyHit(client, entity)) continue;

        float targetPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos); targetPos[2] += 40.0;
        if (Amy_IsTargetInArea(myPos, targetPos, range))
        {
            if (!Amy_HasLineOfSight(client, eyePos, targetPos)) continue;
            commons[nCommons++] = entity;
        }
    }

    for (int k = 0; k < nCommons; k++)
    {
        int ent = commons[k];
        // pudo morir por el golpe de un commons anterior de ESTE mismo tick
        if (ent <= 0 || !IsValidEntity(ent)) continue;
        Amy_ImpulseHit(client, ent);
        Amy_ImpulseRegisterHit(client, ent);
        commFound++;
    }

    // --- 3. Witches: snapshot + LOS (la witch detrás de una pared queda
    //        fuera del impulso: fix v53, mantenido) ---
    int witches[8];
    int nWitches = 0;
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (nWitches >= 8) break;
        if (!IsValidEntity(entity)) continue;
        if (Amy_ImpulseAlreadyHit(client, entity)) continue;

        float targetPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos); targetPos[2] += 40.0;
        if (Amy_IsTargetInArea(myPos, targetPos, range))
        {
            if (!Amy_HasLineOfSight(client, eyePos, targetPos))
            {
                AmyDbg_Log("[IMPULSE] witch %d fuera de línea de visión (pared): ignorada", entity);
                continue;
            }
            witches[nWitches++] = entity;
        }
    }

    for (int k = 0; k < nWitches; k++)
    {
        int ent = witches[k];
        if (ent <= 0 || !IsValidEntity(ent)) continue;
        Amy_ImpulseHit(client, ent);
        Amy_ImpulseRegisterHit(client, ent);
        witchFound++;
    }

    // v52: resumen del tick (verifica el "sin pegarle a nadie" del reporte)
    AmyDbg_Log("[IMPULSE] tick OK: SI=%d (arietados=%d) commons=%d witches=%d aliados=%d",
               siFound, siPlowed, commFound, witchFound, teamFound);
}

// ============================================================
//  v61 - Registro de golpeados del impulso (array estático por
//  cliente, CERO handles). El registro se vacía al empezar cada
//  impulso, al terminar, en OnMapStart/OnMapEnd/round_start y en
//  el reset de victima: es imposible heredar estado de un impulso
//  o de un mapa anterior.
// ============================================================
bool Amy_ImpulseAlreadyHit(int client, int entity)
{
    for (int i = 0; i < g_iAmyImpulseHitCount[client]; i++)
        if (g_iAmyImpulseHits[client][i] == entity) return true;
    return false;
}

void Amy_ImpulseRegisterHit(int client, int entity)
{
    if (g_iAmyImpulseHitCount[client] >= AMY_IMPULSE_MAX_HITS) return; // lleno: se ignora (solo evita doble golpe)
    g_iAmyImpulseHits[client][g_iAmyImpulseHitCount[client]++] = entity;
}

// v48: área CIRCULAR (360 grados) alrededor de Amy. Sustituye al
// cono frontal Amy_IsTargetInFan (eliminado): el martillo golpea
// adelante y atras del objetivo (pedido del usuario). Distancia al
// cuadrado (sin raíz cuadrada).
bool Amy_IsTargetInArea(float origin[3], float targetPos[3], float range)
{
    return (GetVectorDistance(origin, targetPos, true) <= range * range);
}

// ============================================================
//  v53 - LÍNEA DE VISION DEL GOLPE (fix del crash del capítulo siguiente)
//  El golpe 360 conserva su radio, pero SOLO alcanza lo que Amy puede
//  "ver": un rayo MASK_SHOT (el mismo filtro que usan las balas) entre
//  sus ojos y el objetivo. Si hay pared de por medio, no hay golpe.
//  Hasta v52 el swing golpeaba CUALQUIER cosa en radio 220, incluidas
//  entidades invisibles detrás de geometria: el usuario creía no golpear
//  a nadie y el strike entraba por la rama witch sobre una entidad en
//  plena transición -> cierre del juego. Con LOS, ese escenario queda
//  estructuralmente IMPOSIBLE.
// ============================================================
bool Amy_HasLineOfSight(int fromClient, const float fromPos[3], const float toPos[3])
{
    Handle trace = TR_TraceRayFilterEx(fromPos, toPos, MASK_SHOT, RayType_EndPoint,
                                        Amy_TraceFilter_LOS, fromClient);
    bool blocked = TR_DidHit(trace);
    delete trace;
    return !blocked;
}

// v53: filtro del rayo de LOS: SOLO colisiona con geometria solida del
// mapa (mundo, props, puertas). Atraviesa criaturas (jugadores, SI,
// comunes, witches): el LOS mide si hay PARED entre Amy y el objetivo,
// no si hay infectados en medio.
public bool Amy_TraceFilter_LOS(int entity, int contentsMask, any data)
{
    if (entity == 0) return true;            // mundo
    if (entity <= MaxClients) return false;  // jugadores (atacante incluido)

    static char cls[16];
    GetEntityClassname(entity, cls, sizeof(cls));
    if (StrEqual(cls, "infected", false)) return false;   // comunes
    if (StrEqual(cls, "witch", false)) return false;      // witches

    return true;  // props, puertas y demas solidos del mapa
}

// ============================================================
//  v80 - LOS A UN PROPIEDAD, 2a GENERACION (el MURO FANTASMA de
//  los autos). Evidencia del owner en c5m5 (puente): el auto
//  (prop_physics cara_84sedan) sale "EN RADIO pero muro de por
//  medio" y la Z NO lo mueve... hasta que el TANK le da el primer
//  golpe: desde ahi la Z SI lo mueve SIEMPRE. Conclusión: el muro
//  NO existe — el rayo se chocaba contra algo que no es pared
//  (vecino apiñado en fila, borda, rasante) o apuntaba demasiado
//  bajo (origen+40 = altura del capo). El golpe del tank desplaza
//  el auto a terreno limpio y ahi el rayo SI llega. TRES cosas:
//   1) FILTRO v80: UN PROP NO ES UN MURO. El rayo atraviesa a
//      CUALQUIER prop_* (salvo puertas), func_physbox y cuerpos
//      VPHYSICS (jugadores/comunes/witches/tank_rock como siempre).
//      Solo el mundo y los solidos de verdad descartan. (v77
//      ignoro al OBJETIVO; v80 ignora TAMBIÉN a los VECINOS.)
//   2) MUESTREO A 2 ALTURAS: se traza al punto del caller
//      (origen+40) Y a la parte alta (origen+72). Un auto mide
//      ~55 de alto: el +72 siempre asoma por encima de capos,
//      bordas y vecinos bajos. Si CUALQUIERA de los 2 llega = LOS.
//   3) DIAGNOSTICO: si aún así falla, el log dice QUIEN bloquea
//      (ent+clase, o MUNDO). Se acabo adivinar.
// ============================================================
bool Amy_HasLineOfSightToProp(int fromClient, const float fromPos[3], const float toPos[3], int targetEnt)
{
    // objetivo inválido: degradar al LOS clasico (comportamiento v53)
    if (targetEnt <= 0 || !IsValidEntity(targetEnt))
        return Amy_HasLineOfSight(fromClient, fromPos, toPos);

    // punto 1: el del caller (origen + 40)
    int blocker = Amy_PropRayBlocker(fromPos, toPos, targetEnt);
    if (blocker == -1) return true;

    // punto 2 (v80): la parte ALTA (origen + 72) — el techo del
    // auto asoma por encima de capos, bordas y vecinos bajos
    float up[3];
    GetEntPropVector(targetEnt, Prop_Send, "m_vecOrigin", up);
    up[2] += 72.0;
    if (up[2] > toPos[2] + 4.0)
    {
        int blocker2 = Amy_PropRayBlocker(fromPos, up, targetEnt);
        if (blocker2 == -1) return true;
        if (blocker == 0) blocker = blocker2;   // la entidad es más informativa que "mundo"
    }

    // v80: diagnostico — QUIEN bloquea (adios adivinar)
    static char bcls[32];
    if (blocker > 0 && IsValidEntity(blocker))
    {
        GetEntityClassname(blocker, bcls, sizeof(bcls));
        AmyDbg_Log("[PROPS v80] prop %d RECHAZADO: bloquea ent=%d cls=%s", targetEnt, blocker, bcls);
    }
    else
    {
        AmyDbg_Log("[PROPS v80] prop %d RECHAZADO: bloquea el MUNDO (rasante/borda alta)", targetEnt);
    }
    return false;
}

// v80: un rayo ojos->punto que ATRAVIESA todo lo que no es muro
// (ver filtro). Devuelve -1 = llega limpio, 0 = bloquea el mundo,
// >0 = índice de la entidad que bloquea.
int Amy_PropRayBlocker(const float fromPos[3], const float toPos[3], int targetEnt)
{
    Handle trace = TR_TraceRayFilterEx(fromPos, toPos, MASK_SHOT, RayType_EndPoint,
                                        Amy_TraceFilter_PropLOS, targetEnt);
    if (!TR_DidHit(trace)) { delete trace; return -1; }
    int hit = TR_GetEntityIndex(trace);
    delete trace;
    return hit;
}

// v80: filtro del LOS a props — UN PROP NO ES UN MURO (el martillo
// 360 golpea todo el radio a la vez; el vecino de delante no puede
// "proteger" al de atras). Atraviesa: jugadores (atacante incluido),
// comunes, witches, tank_rock, CUALQUIER prop_* (salvo puertas, que
// siguen siendo puerta) y cualquier cuerpo VPHYSICS. Bloquea: el
// mundo y los solidos de verdad (func_wall, doors, brushes).
public bool Amy_TraceFilter_PropLOS(int entity, int contentsMask, any data)
{
    if (entity == 0) return true;                     // mundo: muro real
    if (entity <= MaxClients) return false;           // jugadores (atacante incluido)
    if (entity == view_as<int>(data)) return false;   // EL PROPIO OBJETIVO (v77)

    static char cls[32];
    GetEntityClassname(entity, cls, sizeof(cls));
    if (StrContains(cls, "prop_", false) == 0)
    {
        if (StrContains(cls, "prop_door", false) == 0) return true;   // puerta = puerta
        return false;                                 // CUALQUIER otro prop: atravesar
    }
    if (StrEqual(cls, "func_physbox", false)) return false;   // lanzable el mismo (v78)
    if (StrEqual(cls, "infected", false)) return false;       // comunes
    if (StrEqual(cls, "witch", false)) return false;          // witches
    if (StrEqual(cls, "tank_rock", false)) return false;      // piedra en vuelo: proyectil, no muro
    if (GetEntityMoveType(entity) == MOVETYPE_VPHYSICS) return false;  // cuerpo físico generico

    return true;  // puertas, func_wall, brushes y demas solidos = muro
}

// ============================================================
//  v3.0 - Obtener HP máximo real de una víctima
//  L4D2 a veces reporta m_iMaxHealth = 0 o incorrecto para SI players.
//  El Super Tank VScript setea el HP con SetMaxHealth() que actualiza
//  correctamente m_iMaxHealth, pero a veces SourceMod no lo lee bien.
//  Usamos fallbacks robustos.
// ============================================================
int Amy_GetVictimMaxHP(int victim)
{
    if (victim <= 0 || victim > MaxClients) return 100;
    if (!IsClientInGame(victim)) return 100;

    int maxHp = 100;
    bool isTank = (GetEntProp(victim, Prop_Send, "m_zombieClass") == 8);

    // Intentar m_iMaxHealth (Prop_Send)
    if (HasEntProp(victim, Prop_Send, "m_iMaxHealth"))
    {
        maxHp = GetEntProp(victim, Prop_Send, "m_iMaxHealth");
    }

    // Si maxHp es inválido, intentar m_iMaxHealth (Prop_Data)
    if (maxHp <= 0 && HasEntProp(victim, Prop_Data, "m_iMaxHealth"))
    {
        maxHp = GetEntProp(victim, Prop_Data, "m_iMaxHealth");
    }

    // Si es Tank y maxHp sigue siendo inválido o muy bajo (< 1000),
    // usar fallback alto (Super Tank puede tener hasta 100k+)
    if (isTank && (maxHp <= 0 || maxHp < 1000))
    {
        maxHp = AMY_TANK_MAX_HP_FALLBACK;
    }

    // Si es Tank y maxHp es válido pero menor al HP actual (caso raro),
    // usar el HP actual como maxHp
    if (isTank)
    {
        int currentHp = GetClientHealth(victim);
        if (currentHp > maxHp) maxHp = currentHp;
    }

    // Fallback final
    if (maxHp <= 0) maxHp = 100;

    return maxHp;
}

// ============================================================
//  v3.0 - Obtener HP actual de una víctima
//  Para Tanks, GetClientHealth puede no devolver el HP real si está
//  en estado de "furia" o si el Super Tank VScript lo modificó.
//  Intentamos múltiples fuentes.
// ============================================================
int Amy_GetVictimCurrentHP(int victim)
{
    if (victim <= 0 || victim > MaxClients) return 0;
    if (!IsClientInGame(victim)) return 0;

    int hp = GetClientHealth(victim);

    // Si HP es 0 o inválido, intentar m_iHealth (Prop_Data)
    if (hp <= 0 && HasEntProp(victim, Prop_Data, "m_iHealth"))
    {
        hp = GetEntProp(victim, Prop_Data, "m_iHealth");
    }

    return hp;
}

// ============================================================
//  DASH ESTILO "VERDUGO" (LoL Goliath/Darius style)
//  Calcula el multiplicador de daño basado en la diferencia de HP
//  entre el Tank y Amy. Mientras más vida tenga el Tank vs Amy,
//  más daño hace el strike.
//
//  Fórmula por tramos (sin logaritmo, SourcePawn no lo tiene nativo):
//    ratio = tankHP / survivorHP
//    - ratio <= 1.0    → mult 1.0x (no bonus)
//    - ratio <= 5.0    → mult 1.5x
//    - ratio <= 10.0   → mult 2.0x
//    - ratio <= 50.0   → mult 2.5x
//    - ratio <= 100.0  → mult 3.0x
//    - ratio <= 500.0  → mult 3.5x
//    - ratio > 500.0   → mult 4.0x (cap)
//
//  Ejemplos:
//    Tank 6k HP vs Amy 100 HP    → ratio 60    → mult 3.0x
//    Tank 10k HP vs Amy 100 HP   → ratio 100   → mult 3.0x
//    Tank 50k HP vs Amy 100 HP   → ratio 500   → mult 3.5x
//    Tank 100k HP vs Amy 100 HP  → ratio 1000  → mult 4.0x
//    Tank 100k HP vs Amy 50 HP   → ratio 2000  → mult 4.0x
// ============================================================
float Amy_CalculateDashMultiplier(int attacker, int victim)
{
    if (!Amy_IsValidClient(attacker)) return 1.0;
    if (victim <= 0 || victim > MaxClients || !IsClientInGame(victim)) return 1.0;

    // Solo aplica a Tanks
    if (GetEntProp(victim, Prop_Send, "m_zombieClass") != 8) return 1.0;

    int tankHP = Amy_GetVictimCurrentHP(victim);
    int survivorHP = GetClientHealth(attacker);

    // Fallbacks para evitar división por 0
    if (survivorHP < AMY_DASH_SURVIVOR_HP_MIN) survivorHP = RoundToNearest(AMY_DASH_SURVIVOR_HP_MIN);
    if (tankHP <= 0) tankHP = survivorHP;  // Tank ya casi muerto → ratio 1:1

    // Calcular ratio lineal
    float ratio = float(tankHP) / float(survivorHP);
    if (ratio < 1.0) ratio = 1.0;

    // Calcular multiplicador por tramos
    float mult;
    if (ratio <= 1.0) {
        mult = 1.0;
    } else if (ratio <= 5.0) {
        mult = 1.5;
    } else if (ratio <= 10.0) {
        mult = 2.0;
    } else if (ratio <= 50.0) {
        mult = 2.5;
    } else if (ratio <= 100.0) {
        mult = 3.0;
    } else if (ratio <= 500.0) {
        mult = 3.5;
    } else {
        mult = 4.0;  // cap para Super Tanks con HP enorme
    }

    return mult;
}
// ============================================================================
//  v61 - GOLPE DEL IMPULSO (Amy_ImpulseHit)
//  Mata y empuja todo lo que este a su paso, sea lo que sea:
//   - Comunes: oneshot (999) + empuje ANTES del dano (v45: el ragdoll
//     hereda el impulso y sale volando - comportamiento confirmado).
//   - Especiales: dano + LANZAMIENTO con arco (v68: vuela de verdad,
//     stagger seguro AL ATERRIZAR + liberación de agarres + bloqueo de
//     su habilidad 5s).
//   - Tank: dano escalado por el dash del Verdugo (hasta x4) +
//     lanzamiento con arco propio (v68: stagger al aterrizar).
//   - Witch: dano + WITCHFLIGHT (v63, restaurado a petición del
//     usuario): igual que el viejo martillo - IA congelada, sale
//     volando con arco, aterriza y su IA se reactiva sola.
//   - Aliados: SOLO empuje, sin dano (gestionado en Amy_ImpulseSweep).
//  Los multiplicadores de pasivas (Furia/Momentum/JumpBonus) se aplican
//  igual que en el viejo martillo.
// ============================================================================
void Amy_ImpulseHit(int attacker, int victim)
{
    if (!Amy_IsValidClient(attacker)) return;
    if (victim <= 0 || !IsValidEntity(victim)) return;

    bool isTank = false;
    bool isWitch = false;
    bool isCommon = false;

    if (victim <= MaxClients) {
        if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return;
        if (GetEntProp(victim, Prop_Send, "m_zombieClass") == 8) isTank = true;
    } else {
        char cls[32]; GetEntityClassname(victim, cls, sizeof(cls));
        if (StrEqual(cls, "witch")) isWitch = true;
        else if (StrEqual(cls, "infected")) isCommon = true;
    }

    AmyDbg_Log("[HIT] victim=%d tanque=%d witch=%d común=%d",
               victim, isTank ? 1 : 0, isWitch ? 1 : 0, isCommon ? 1 : 0);

    // Multiplicador total (Furia + Momentum + Jump Bonus): mismo escalado
    // de pasivas que tenía el martillo.
    float dmgMult = 1.0;
    if (g_bAmyFuryActive[attacker]) dmgMult *= AMY_FURY_DMG_MULT;
    if (g_iAmyMomentumStacks[attacker] > 0)
        dmgMult *= 1.0 + (float(g_iAmyMomentumStacks[attacker]) * AMY_MOMENTUM_DMG_BONUS);
    if (g_bAmyJumpDmgActive[attacker]) dmgMult *= AMY_JUMP_DMG_MULT;

    // v64 - JUGO DEL MARTILLO ORIGINAL (a petición): punto de impacto +
    // sonido de impacto (el tank lleva el suyo propio) + burst rosa, con
    // THROTTLE: la embestida golpea hasta 40 veces/s y sin esto los
    // sonidos se apilan en un muro de ruido.
    float enemyOrigin[3];
    if (victim <= MaxClients) GetClientAbsOrigin(victim, enemyOrigin);
    else GetEntPropVector(victim, Prop_Send, "m_vecOrigin", enemyOrigin);
    float hitPos[3];
    hitPos[0] = enemyOrigin[0];
    hitPos[1] = enemyOrigin[1];
    hitPos[2] = enemyOrigin[2] + 40.0;

    bool juice = false;
    float nowT = GetEngineTime();
    if (nowT - g_fAmyImpulseLastJuice[attacker] >= AMY_IMPULSE_JUICE_THROTTLE)
    {
        g_fAmyImpulseLastJuice[attacker] = nowT;
        juice = true;
        if (isTank) EmitSoundToAll(AMY_SOUND_HIT_TANK, attacker, SNDCHAN_WEAPON, SNDLEVEL_RAIDSIREN);
        else        EmitSoundToAll(AMY_SOUND_HIT_GEN,  attacker, SNDCHAN_WEAPON, SNDLEVEL_RAIDSIREN);
        Amy_VFX_StrikeHit(hitPos);
    }

    // Empuje: SIEMPRE en la dirección del impulso (todo lo que este a su
    // paso sale despedido por delante, sea lo que sea). v68: arco
    // vertical de LEVANTAMIENTO (base especial/boomer; el tank y los
    // comunes lo ajustan en su propia rama).
    float push[3];
    push[0] = g_fAmyImpulseDir[attacker][0] * g_fAmyStrikeForce;
    push[1] = g_fAmyImpulseDir[attacker][1] * g_fAmyStrikeForce;
    push[2] = AMY_LAUNCH_UP_SPECIAL;

    // ============================================================
    //  TANK: dano escalado por el dash del Verdugo + hard-stop
    // ============================================================
    if (isTank)
    {
        float dashMult = Amy_CalculateDashMultiplier(attacker, victim);
        float dmgTank = g_fAmyImpDmgTank * dmgMult * dashMult;

        if (dashMult > 1.5)
        {
            PrintHintText(attacker,
                "<font color='#FF00FF' size='20'>>> IMPULSO VERDUGO <<</font>\n\
<font color='#FF80C0'>Mientras mas vida le quede al Tank, mas dano</font>\n\
<font color='#FFFFFF'>Dano x%.1f  |  Tank: %d HP  |  Amy: %d HP</font>",
                dashMult,
                Amy_GetVictimCurrentHP(victim),
                GetClientHealth(attacker));
        }

        // v107: OM_AbilityDamage = amplificador hibrido (x2 + % vs jefes)
        OM_AbilityDamage(victim, attacker, dmgTank, DMG_CLUB);

        // v68: lanzamiento diferido (arco propio del tank + liberación de
        // agarres, 0.05s después para no tocar la maquina de estados del
        // motor en el mismo frame que el dano; el stagger llega AL
        // ATERRIZAR por el monitor de vuelo, no al impactar)
        push[2] = AMY_LAUNCH_UP_TANK;
        Amy_ApplyHardStopFling(attacker, victim, push);

        // v64: anillo rosa del dash del Verdugo (como el martillo
        // original cuando el multiplicador pasaba de 2.5)
        if (dashMult > 2.5 && juice)
        {
            Amy_VFX_BeamRing(hitPos, 10.0, 200.0,
                             AMY_COLOR_PINK_R, AMY_COLOR_PINK_G, AMY_COLOR_PINK_B, 255,
                             0.6, 8.0);
        }

        // v64: ROMPE-HUESOS CONTRA PARED instantaneo (el del martillo
        // original): si el tank tiene pared a menos de 60u en la
        // dirección del empuje, impacto de pared YA (dano extra + bone
        // break 8s + execute si está al 20% de vida).
        if (Amy_CheckWallImpact(victim, g_fAmyImpulseDir[attacker]))
        {
            AmyDbg_Log("[HIT] tank=%d contra pared (rompe-huesos instantaneo)", victim);
            Amy_ApplyBrokenBones(victim, 8.0);
        }
        return;
    }

    // ============================================================
    //  ESPECIAL NO-TANK: dano + hard-stop (stagger seguro + empuje +
    //  liberación de agarres + bloqueo de su habilidad 5s)
    // ============================================================
    if (victim <= MaxClients && IsClientInGame(victim) && GetClientTeam(victim) == TEAM_INFECTED)
    {
        // ============================================================
        //  v64 - BOOMER: NO recibe dano al pegarle: sale VOLANDO con la
        //  embestida y a los 0.45s ESTALLA con todo el vómito. El pop
        //  real del juego suelta bilis a los supervivientes cercanos y
        //  el frasco de bilis que dejamos en el suelo atrae a los
        //  comunes de la zona (como una bilis de boomer lanzada ahi:
        //  la horda se avalanza sobre el charco y deja de ir a por el
        //  equipo). Amy es inmune al vómito (contra instantanea v64).
        // ============================================================
        if (GetEntProp(victim, Prop_Send, "m_zombieClass") == 2)
        {
            TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, push);
            PrintToChat(attacker, "\x04[Amy]\x01 ¡Boomer lanzado! Va a reventar...");
            DataPack bpack = new DataPack();
            bpack.WriteCell(GetClientUserId(victim));
            bpack.WriteCell(GetClientUserId(attacker));
            CreateTimer(AMY_IMPULSE_BOOMER_FUSE, T_AmyBoomerBurst, bpack,
                        TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
            AmyDbg_Log("[HIT] boomer=%d lanzado: estallido programado (%.2fs)",
                       victim, AMY_IMPULSE_BOOMER_FUSE);
            return;
        }

        float dmg = g_fAmyImpDmgSpecial * dmgMult;

        // Si esta desarmado o bone-broken: +50% dano de todo
        // (v64: desarme normal restaurado del martillo original)
        if (g_bAmyDisarmed[victim] || g_bIsBoneBroken[victim])
        {
            dmg *= AMY_VULNERABILITY_MULT;
        }

        // v107: OM_AbilityDamage = amplificador hibrido (x2 + % vs jefes)
        OM_AbilityDamage(victim, attacker, dmg, DMG_CLUB);

        // v68: lanzamiento con el arco de especial (fijado arriba) +
        // stagger AL ATERRIZAR por el monitor de vuelo
        Amy_ApplyHardStopFling(attacker, victim, push);

        // v64: ROMPE-HUESOS CONTRA PARED instantaneo (el del martillo
        // original): si la victima tiene pared a menos de 60u en la
        // dirección del empuje, impacto de pared YA (dano extra + bone
        // break 8s + sonidos de huesos + execute). Sin pared: desarme
        // normal 2s (+50% dano de todo).
        if (Amy_CheckWallImpact(victim, g_fAmyImpulseDir[attacker]))
        {
            AmyDbg_Log("[HIT] SI=%d contra pared (rompe-huesos instantaneo)", victim);
            Amy_ApplyBrokenBones(victim, 8.0);
        }
        else
        {
            Amy_ApplyNormalDisarm(victim);
        }
        return;
    }

    // ============================================================
    //  WITCH: dano + WITCHFLIGHT (v63, RESTAURADO a petición del
    //  usuario: "ya no empuja a la witch como hacia con el golpe de
    //  martillo usando el frozen de antes"). La MISMA ruta del viejo
    //  martillo (v46-v60): WitchFlight_Launch suspende su IA de
    //  locomoción (la congela), la lanza con arco, se desliza en
    //  paredes, aterriza con dano de impacto y su IA se reactiva sola
    //  (movetype original restaurado siempre). El dano va DESPUÉS del
    //  lanzamiento (sale volando gritando) y CheckDead la restaura al
    //  instante si el golpe la mató en pleno vuelo (v49). Witch_Flight
    //  v2.4 trae guard de salud propia: una witch muriendo no se lanza.
    // ============================================================
    if (isWitch)
    {
        float launchVel[3];
        launchVel[0] = g_fAmyImpulseDir[attacker][0] * 350.0;
        launchVel[1] = g_fAmyImpulseDir[attacker][1] * 350.0;
        launchVel[2] = 900.0;
        WitchFlight_Launch(victim, attacker, launchVel);

        OM_AbilityDamage(victim, attacker, g_fAmyImpDmgWitch * dmgMult, DMG_CLUB);

        WitchFlight_CheckDead(victim);
        return;
    }

    // ============================================================
    //  COMUNES: oneshot + empuje (empuje ANTES del dano: el ragdoll
    //  hereda el impulso y sale volando - v45, confirmado por el usuario)
    // ============================================================
    if (isCommon)
    {
        // v68: arco de comunes (el ragdoll hereda el impulso al morir:
        // vuelan con más ganas)
        push[2] = AMY_LAUNCH_UP_COMMON;
        TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, push);
        OM_AbilityDamage(victim, attacker, g_fAmyImpDmgCommon, DMG_CLUB);
        return;
    }

    // ============================================================
    //  FALLBACK (cualquier otra entidad golpeable): dano + empuje
    //  (v68: arco de comunes; sin monitor: no es jugador)
    // ============================================================
    push[2] = AMY_LAUNCH_UP_COMMON;
    OM_AbilityDamage(victim, attacker, g_fAmyImpDmgSpecial * dmgMult, DMG_CLUB);
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, push);
}

// ============================================================================
//  v64 - SEGURO DE VACÍO: va pegada al suelo y delante NO hay suelo
//  (precipicio / tejado sin baranda): frenar EN SECO en el borde. Si esta
//  en el aire o subiendo (salto/escalera) no se aplica: ese control lo
//  tiene la jugadora (dirección guiada por la mirada + 2a pulsación).
// ============================================================================
bool Amy_ImpulseVoidAhead(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[2] > 150.0) return false;    // subiendo: salto/escalera, libre

    float pos[3];
    GetClientAbsOrigin(client, pos);

    // hay suelo bajo sus pies AHORA? (si ya está en el aire: libre)
    float down[3];
    down[0] = pos[0]; down[1] = pos[1]; down[2] = pos[2] - 60.0;
    Handle t0 = TR_TraceRayFilterEx(pos, down, MASK_SOLID, RayType_EndPoint,
                                    Amy_TraceFilter_LOS, client);
    bool groundNow = TR_DidHit(t0);
    delete t0;
    if (!groundNow) return false;

    // hay suelo delante, en la dirección de la embestida?
    float ahead[3], deep[3];
    ahead[0] = pos[0] + g_fAmyImpulseDir[client][0] * AMY_IMPULSE_VOID_AHEAD;
    ahead[1] = pos[1] + g_fAmyImpulseDir[client][1] * AMY_IMPULSE_VOID_AHEAD;
    ahead[2] = pos[2];
    deep[0] = ahead[0]; deep[1] = ahead[1]; deep[2] = ahead[2] - AMY_IMPULSE_VOID_DEPTH;
    Handle t1 = TR_TraceRayFilterEx(ahead, deep, MASK_SOLID, RayType_EndPoint,
                                    Amy_TraceFilter_LOS, client);
    bool groundAhead = TR_DidHit(t1);
    delete t1;

    return !groundAhead;
}

// ============================================================================
//  v64 - ESTALLIDO DEL BOOMER LANZADO (T_AmyBoomerBurst)
//  El boomer que Amy arrollo NO recibe dano: sale volando y a los
//  AMY_IMPULSE_BOOMER_FUSE segundos revienta AQUÍ:
//   1) pop REAL del juego (muerte del boomer: el motor suelta la bilis
//      sobre los supervivientes cercanos; Amy la refleja al instante
//      con su contra v64)
//   2) frasco de bilis en el punto (vomitjar): los comunes de la zona
//      se avalanzan al charco (distraction real, igual que una bilis
//      de boomer lanzada ahi)
//   3) empujon a los comunes cercanos (la onda del estallido)
// ============================================================================
public Action T_AmyBoomerBurst(Handle timer, DataPack pack)
{
    pack.Reset();
    int boomer   = GetClientOfUserId(pack.ReadCell());
    int attacker = GetClientOfUserId(pack.ReadCell());
    // v51: el pack lo cierra TIMER_DATA_HNDL_CLOSE al terminar el timer

    if (boomer <= 0 || !IsClientInGame(boomer) || !IsPlayerAlive(boomer)) return Plugin_Stop;
    if (GetEntProp(boomer, Prop_Send, "m_zombieClass") != 2) return Plugin_Stop;  // ya no es boomer

    float pos[3];
    GetClientAbsOrigin(boomer, pos);
    float vPos[3];
    vPos[0] = pos[0]; vPos[1] = pos[1]; vPos[2] = pos[2] + 40.0;

    // VFX + sonido: burst de boomer + explosión
    Amy_VFX_Particle(vPos, AMY_PARTICLE_WALL_HIT, 1.5);   // "boomer_explode_Boomer"
    EmitSoundToAll(AMY_SOUND_EXPLODE, boomer, SNDCHAN_WEAPON, SNDLEVEL_RAIDSIREN);
    AmyDbg_Log("[BOOMER] %d estalla tras la embestida", boomer);

    // 1) pop real del juego: matarlo con el golpe de Amy como fuente
    int src = (Amy_IsValidClient(attacker)) ? attacker : 0;
    SDKHooks_TakeDamage(boomer, src, src, 9999.0, DMG_CLUB);

    // 2) bilis en el suelo: frasco de vómito en el punto del estallido
    Amy_SpawnBileJar(attacker, vPos);

    // 3) onda del estallido: los comunes cercanos salen empujados
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float cPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", cPos);
        if (GetVectorDistance(pos, cPos) <= 250.0)
        {
            float push[3];
            MakeVectorFromPoints(pos, cPos, push);
            NormalizeVector(push, push);
            ScaleVector(push, 300.0);
            push[2] = 150.0;
            TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
    return Plugin_Stop;
}

// Frasco de bilis (vomitjar) en el punto del estallido del boomer: el
// juego lo detona contra el suelo y su bilis atrae a los comunes a ESE
// punto. Si la entidad no existiera en esta build del juego, no se crea
// (el pop del boomer ya dio el efecto base; cero riesgo).
void Amy_SpawnBileJar(int thrower, float pos[3])
{
    int jar = CreateEntityByName("vomitjar_projectile");
    if (jar == -1) return;

    DispatchSpawn(jar);
    ActivateEntity(jar);
    if (thrower > 0)
    {
        if (HasEntProp(jar, Prop_Send, "m_hOwnerEntity"))
            SetEntPropEnt(jar, Prop_Send, "m_hOwnerEntity", thrower);
        if (HasEntProp(jar, Prop_Data, "m_hThrower"))
            SetEntPropEnt(jar, Prop_Data, "m_hThrower", thrower);
    }
    float drop[3];
    drop[0] = 0.0; drop[1] = 0.0; drop[2] = -100.0;
    TeleportEntity(jar, pos, NULL_VECTOR, drop);
    AmyDbg_Log("[BOOMER] frasco de bilis creado (ent=%d)", jar);
}

// ============================================================
//  v64 - ROMPE-HUESOS CONTRA PARED (RESTAURADO verbatim del martillo
//  original v60): un solo rayo HULL en la dirección del empuje; si hay
//  pared a menos de 60u, el impacto de pared ocurre YA (dano extra +
//  bone break + execute). Sin monitores ni timers.
// ============================================================
bool Amy_CheckWallImpact(int entity, float direction[3])
{
    if (entity <= 0 || !IsValidEntity(entity)) return false;

    float origin[3], endPos[3];
    GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", origin);
    origin[2] += 35.0;

    float traceVec[3]; traceVec = direction;
    ScaleVector(traceVec, 60.0);
    AddVectors(origin, traceVec, endPos);

    float mins[3] = {-16.0, -16.0, -10.0};
    float maxs[3] = {16.0, 16.0, 10.0};

    Handle trace = TR_TraceHullFilterEx(origin, endPos, mins, maxs, MASK_SOLID,
                                        Amy_TraceFilter_World, entity);
    bool hit = TR_DidHit(trace);
    delete trace;

    return hit;
}

// v64: restaurado del martillo original (mundo y solo mundo = pared)
public bool Amy_TraceFilter_World(int entity, int contentsMask, int data)
{
    return (entity == 0);
}

// ============================================================
//  v64 - DESARME NORMAL (2s) RESTAURADO del martillo original: golpe
//  seco SIN pared -> la victima queda "desarmada" 2s (+50% de dano de
//  TODAS las fuentes vía Amy_VictimTakeDamage, igual que el bone break
//  pero sin pared de por medio).
// ============================================================
void Amy_ApplyNormalDisarm(int victim)
{
    if (!Amy_IsValidClient(victim)) return;
    if (GetClientTeam(victim) != TEAM_INFECTED) return;

    g_bAmyDisarmed[victim] = true;
    g_fAmyNormalDisarmEndTime[victim] = GetEngineTime() + AMY_NORMAL_DISARM_DURATION;

    // Hookear OnTakeDamage si no estaba ya hookeado
    if (!g_bAmyHookedOnTakeDmg[victim])
    {
        SDKHook(victim, SDKHook_OnTakeDamage, Amy_VictimTakeDamage);
        g_bAmyHookedOnTakeDmg[victim] = true;
    }

    CreateTimer(AMY_NORMAL_DISARM_DURATION, T_AmyClearDisarm,
                GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_AmyClearDisarm(Handle timer, int userId)
{
    int client = GetClientOfUserId(userId);
    if (client <= 0 || client > MaxClients) return Plugin_Stop;

    g_bAmyDisarmed[client] = false;
    g_fAmyNormalDisarmEndTime[client] = 0.0;

    // Si tampoco está bone-broken, deshookear OnTakeDamage
    if (!g_bIsBoneBroken[client] && g_bAmyHookedOnTakeDmg[client])
    {
        SDKUnhook(client, SDKHook_OnTakeDamage, Amy_VictimTakeDamage);
        g_bAmyHookedOnTakeDmg[client] = false;
    }
    return Plugin_Stop;
}

// ============================================================
//  v64 - VFX DEL GOLPE (RESTAURADO del martillo original): burst rosa
//  en el punto de impacto + glow + ring pequeño expansivo. Se invoca con
//  el throttle de Amy_ImpulseHit: sabor de sobra sin apilar efectos.
// ============================================================
void Amy_VFX_StrikeHit(float pos[3])
{
    // Burst de partícula rosa
    Amy_VFX_Particle(pos, AMY_PARTICLE_STRIKE_BURST, 1.0);

    // Glow rosa pulsante
    Amy_VFX_Glow(pos, AMY_COLOR_PINK_R, AMY_COLOR_PINK_G, AMY_COLOR_PINK_B,
                 0.6, 15.0);

    // Ring pequeño expansivo rosa
    Amy_VFX_BeamRing(pos, 5.0, 60.0,
                     AMY_COLOR_PINK_HOT_R, AMY_COLOR_PINK_HOT_G, AMY_COLOR_PINK_HOT_B, 255,
                     0.4, 5.0);
}

// ============================================================
//  v64 - NOTA: Amy_VFX_Glow ya existía en el modulo (v45): se usa tal
//  cual desde Amy_VFX_StrikeHit (arriba). No se duplica.
// ============================================================

// ============================================================================
//  v64 - CONTRA INSTANTANEA (portada del sistema de Knuckles a petición
//  del usuario: "literalmente reacciona al instante antes de que el
//  efecto le afecte (agarres empujes) etc"):
//   - LENGUA (smoker): SIEMPRE activa: el agarre NUNCA llega a empezar
//     (pre-hook del motor) y el smoker recibe la contra al instante.
//   - VÓMITO (boomer): SIEMPRE activa: se refleja; el boomer recibe su
//     propia bilis + empujon (igual que el counter de Knuckles).
//   - Pinza de hunter, montura de jockey, carga de charger, garra de
//     tank, tropiezos y empujones: DURANTE el impulso (la embestida es
//     imparable ANTES de que el efecto la toque; fuera de ella, juego
//     normal: la embestida ya la libera de cualquier agarre).
// ============================================================================
bool Amy_IsImpulseImmune(int client)
{
    if (!Amy_IsValidClient(client)) return false;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return false;
    return g_bAmyImpulseActive[client];
}

bool Amy_TongueCounter(int victim, int smoker)
{
    if (!Amy_IsValidClient(victim) || g_iPlayerCharIdx[victim] != AMY_INDEX) return false;

    EmitSoundToAll(AMY_SOUND_HIT_GEN, victim, SNDCHAN_WEAPON, SNDLEVEL_RAIDSIREN);

    if (Amy_IsValidClient(smoker))
    {
        float vPos[3], sPos[3], push[3];
        GetClientAbsOrigin(victim, vPos);
        GetClientAbsOrigin(smoker, sPos);
        MakeVectorFromPoints(vPos, sPos, push);
        NormalizeVector(push, push);
        ScaleVector(push, 700.0);
        push[2] = 350.0;

        // v68: lanzamiento + stagger al aterrizar (el stagger inmediato
        // anulaba el vuelo del empuje)
        Amy_ApplyHardStopFling(victim, smoker, push);
        OM_AbilityDamage(smoker, victim, 100.0, DMG_CLUB);
        Amy_DisableInfectedAbility(smoker, 3.0);

        PrintCenterText(victim, ">> ¡LENGUA ROTA AL INSTANTE! <<");
        PrintCenterText(smoker, "¡Amy rompió tu lengua en el aire!");
        AmyDbg_Log("[CONTRA v64] lengua del smoker %d rota al instante (victim=%d)",
                   smoker, victim);
    }
    return true;
}

bool Amy_VomitCounter(int victim, int &attacker)
{
    if (!Amy_IsValidClient(victim) || g_iPlayerCharIdx[victim] != AMY_INDEX) return false;

    // v69: el anti-vómito ahora es un poder del menú Mastery (activable /
    // desactivable por la propia Amy, default ON). Si está apagado, la
    // bilis del boomer le afecta normal (return false -> Plugin_Continue).
    if (!DollSys_AntiVomitoActive(victim)) return false;

    // v70: ventana post-reflejo (AMY_VOMIT_REFLECT_WINDOW). La explosión
    // del boomer que acaba de estallar por esta misma contra vuelve a
    // entrar aquí con la bilis del pop (atacante ya muerto): se BLOQUEA
    // sin efectos, no se re-procesa.
    if (GetGameTime() < g_fAmyVomitBlockUntil[victim]) return true;

    // v70: la contra SOLO dispara contra un BOOMER VIVO del equipo
    // infectado. Las jars de bilis de un compañero (atacante
    // superviviente, vivo pero del otro equipo) y la bilis de la
    // explosión de un boomer ya muerto dejan de re-entrar: hasta v69 una
    // jar aliada lanzaba y aplicaba 100 de daño ácido al PROPIO ALIADO.
    if (!Amy_IsValidClient(attacker)
        || GetClientTeam(attacker) != TEAM_INFECTED
        || GetEntProp(attacker, Prop_Send, "m_zombieClass") != 2)
    {
        return false;
    }

    EmitSoundToAll(AMY_SOUND_HIT_GEN, victim, SNDCHAN_WEAPON, SNDLEVEL_RAIDSIREN);
    PrintCenterText(victim, ">> ¡VÓMITO REFLEJADO! <<");

    // v70 - FIX DEL CRASH REPORTADO ("cuando el boomer lanza su vómito
    // pero el contraataque se lo devuelve, en ocasiones causa crash"):
    // hasta v69 la contra mataba al boomer (100 ácido > 50 HP) AQUÍ
    // MISMO, DENTRO de L4D_OnVomitedUpon, es decir, EN MEDIO del propio
    // spray del boomer. Al morir explotaba: la explosión volvía a llamar
    // a OnVomitedUpon (bilis del pop sobre los cercanos) y mutaba el
    // estado del juego con el spray todavía en la pila de llamadas del
    // motor: re-entrada dependiente del timing = crash OCASIONAL.
    //
    // El hook ahora SOLO DECIDE (bloquea la bilis de Amy); los efectos
    // se aplican AMY_VOMIT_REFLECT_DELAY segundos después, FUERA de
    // cualquier hook, con timer userid-only + NO_MAPCHANGE +
    // DATA_HNDL_CLOSE (cero handles guardados: imposible el "Invalid
    // timer handle").
    g_fAmyVomitBlockUntil[victim] = GetGameTime() + AMY_VOMIT_REFLECT_WINDOW;

    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(attacker));
    dp.WriteCell(GetClientUserId(victim));
    CreateTimer(AMY_VOMIT_REFLECT_DELAY, T_AmyVomitReflect, dp,
                TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);

    AmyDbg_Log("[CONTRA v70] vómito del boomer %d reflejado por %d (efectos en %.1fs, fuera del hook)",
               attacker, victim, AMY_VOMIT_REFLECT_DELAY);
    return true;
}

// v70: aplicación diferida de la contra de vómito (la parte que puede
// matar al boomer NUNCA corre dentro de un hook del juego). Re-valida
// TODO al dispararse: si el boomer murió en la ventana de 0.1s (le
// disparó el equipo), la contra se disuelve sin tocar cadáveres.
public Action T_AmyVomitReflect(Handle timer, DataPack pack)
{
    pack.Reset();
    int boomer = GetClientOfUserId(pack.ReadCell());
    int amy    = GetClientOfUserId(pack.ReadCell());
    // (el pack lo cierra TIMER_DATA_HNDL_CLOSE al terminar el timer)

    if (amy > 0 && IsClientInGame(amy) && IsPlayerAlive(amy)
        && Amy_IsValidClient(boomer)
        && GetClientTeam(boomer) == TEAM_INFECTED
        && GetEntProp(boomer, Prop_Send, "m_zombieClass") == 2)
    {
        // el boomer recibe SU PROPIA bilis (igual que el counter de Knuckles)
        if (HasEntProp(boomer, Prop_Send, "m_itTimer"))
            SetEntPropFloat(boomer, Prop_Send, "m_itTimer", GetGameTime() + 10.0);

        float vAtt[3], vVic[3], push[3];
        GetClientAbsOrigin(boomer, vAtt);
        GetClientAbsOrigin(amy, vVic);
        MakeVectorFromPoints(vVic, vAtt, push);
        NormalizeVector(push, push);
        ScaleVector(push, 800.0);
        push[2] = 300.0;

        // v68: lanzamiento + stagger al aterrizar (el núcleo re-valida
        // vivos por dentro); v70: la habilidad se bloquea ANTES del daño
        Amy_ApplyHardStopFling(amy, boomer, push);
        Amy_DisableInfectedAbility(boomer, 5.0);
        OM_AbilityDamage(boomer, amy, 100.0, DMG_ACID);

        PrintCenterText(boomer, "¡Te has vomitado a ti mismo!");
        AmyDbg_Log("[CONTRA v70] efectos aplicados al boomer %d (bilis propia + 100 acido + lanzamiento)",
                   boomer);
    }
    else
    {
        AmyDbg_Log("[CONTRA v70] boomer %d ya no válido al aplicar efectos: contra disuelta",
                   boomer);
    }
    return Plugin_Stop;
}

bool Amy_GrabCounter(int victim, int attacker)
{
    if (!Amy_IsImpulseImmune(victim)) return false;

    EmitSoundToAll(AMY_SOUND_HIT_GEN, victim, SNDCHAN_WEAPON, SNDLEVEL_RAIDSIREN);

    if (Amy_IsValidClient(attacker))
    {
        // v68: el atacante sale POR DELANTE lanzado (vuela con arco;
        // el stagger le llega al ATERRIZAR, no al impactar)
        float push[3];
        push[0] = g_fAmyImpulseDir[victim][0] * 800.0;
        push[1] = g_fAmyImpulseDir[victim][1] * 800.0;
        push[2] = 400.0;
        Amy_ApplyHardStopFling(victim, attacker, push);
        OM_AbilityDamage(attacker, victim, 200.0, DMG_CLUB);
        Amy_DisableInfectedAbility(attacker, 5.0);

        PrintCenterText(victim, ">> ¡EMBESTIDA IMPARABLE! <<");
        AmyDbg_Log("[CONTRA v64] agarre de %d contrado en plena embestida (victim=%d)",
                   attacker, victim);
    }
    return true;
}

bool Amy_TankClawCounter(int tank, int player)
{
    if (!Amy_IsImpulseImmune(player)) return false;

    EmitSoundToAll(AMY_SOUND_HIT_TANK, player, SNDCHAN_WEAPON, SNDLEVEL_RAIDSIREN);

    if (Amy_IsValidClient(tank))
    {
        // v68: tank lanzado hacia atras con arco propio (el stagger le
        // llega al ATERRIZAR, no al impactar)
        float push[3];
        push[0] = g_fAmyImpulseDir[player][0] * 600.0;
        push[1] = g_fAmyImpulseDir[player][1] * 600.0;
        push[2] = AMY_LAUNCH_UP_TANK;
        Amy_ApplyHardStopFling(player, tank, push);
        Amy_DisableInfectedAbility(tank, 3.0);

        PrintCenterText(player, ">> ¡GARRA DEL TANK BLOQUEADA! <<");
        AmyDbg_Log("[CONTRA v64] garra del tank %d bloqueada (player=%d)", tank, player);
    }
    return true;
}

void Amy_ApplyBrokenBones(int victim, float duration)
{
    if (victim <= 0 || !IsValidEntity(victim)) return;

    char cls[32]; GetEntityClassname(victim, cls, sizeof(cls));

    // VFX v2.0: efecto visual de impacto contra pared en todos los casos
    float vPos[3];
    if (victim <= MaxClients) {
        GetClientAbsOrigin(victim, vPos);
    } else {
        GetEntPropVector(victim, Prop_Send, "m_vecOrigin", vPos);
    }
    vPos[2] += 40.0;
    Amy_VFX_WallImpact(vPos);

    if (victim > MaxClients && StrEqual(cls, "infected"))
    {
        SDKHooks_TakeDamage(victim, 0, 0, 9999.0, DMG_CRUSH | DMG_BLAST);
        return;
    }

    if (victim > MaxClients && StrEqual(cls, "witch"))
    {
        int rnd = GetRandomInt(0, sizeof(g_AmyBoneSounds) - 1);
        EmitSoundToAll(g_AmyBoneSounds[rnd], victim, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN);
        SDKHooks_TakeDamage(victim, 0, 0, 300.0, DMG_CRUSH);
        return;
    }

    if (victim <= MaxClients && IsClientInGame(victim))
    {
        int rnd = GetRandomInt(0, sizeof(g_AmyBoneSounds) - 1);
        EmitSoundToAll(g_AmyBoneSounds[rnd], victim, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.0);
        EmitSoundToAll(g_AmyBoneSounds[rnd], victim, SNDCHAN_STATIC, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.0);

        // ============================================================
        //  v3.0 - EXECUTE CHECK: si HP < 20% max → ejecución instantánea
        //  FIX: usar Amy_GetVictimCurrentHP y Amy_GetVictimMaxHP que manejan
        //  correctamente el HP del Tank (que a veces reporta m_iMaxHealth=0)
        // ============================================================
        int hp = Amy_GetVictimCurrentHP(victim);
        int maxHp = Amy_GetVictimMaxHP(victim);

        // Debug log para verificar los valores
        // PrintToChatAll("[DEBUG] victim=%d hp=%d maxHp=%d threshold=%d",
        //     victim, hp, maxHp, RoundToNearest(float(maxHp) * AMY_EXECUTE_HP_PERCENT));

        if (maxHp > 0 && hp > 0 && float(hp) <= float(maxHp) * AMY_EXECUTE_HP_PERCENT)
        {
            // EJECUCIÓN: 999999999 de daño
            SDKHooks_TakeDamage(victim, 0, 0, AMY_EXECUTE_DAMAGE, DMG_CRUSH | DMG_BLAST);
            PrintToChat(victim, "\x04[Amy]\x01 >> ¡EJECUTADO! << Contra la pared. (HP %d/%d)", hp, maxHp);
            PrintHintText(victim, "<font color='#FF0000' size='24'>>> EJECUTADO <<</font>");
            return;
        }

        // ============================================================
        //  v3.0 - WALL HIT DAMAGE: el golpe contra pared causa su propio daño
        //  - Base: 100 de daño
        //  - Si ya estaba desarmado (normal) o bone-broken: +150% daño (x2.5)
        // ============================================================
        float wallDmg = AMY_WALL_HIT_DAMAGE;
        bool wasAlreadyVulnerable = g_bIsBoneBroken[victim];
        if (wasAlreadyVulnerable)
        {
            wallDmg *= AMY_WALL_BONUS_MULT;  // 100 * 2.5 = 250 daño
            PrintToChat(victim, "\x04[Amy]\x01 >> ¡RUPTURA DOBLE! << Contra la pared (+150%% daño)");
        }

        SDKHooks_TakeDamage(victim, 0, 0, wallDmg, DMG_CRUSH);

        // Aplicar bone break completo
        g_bIsBoneBroken[victim] = true;
        g_fAmyDisarmEndTime[victim] = GetEngineTime() + duration;

        // Hookear OnTakeDamage para vulnerability (si no estaba ya)
        if (!g_bAmyHookedOnTakeDmg[victim])
        {
            SDKHook(victim, SDKHook_OnTakeDamage, Amy_VictimTakeDamage);
            g_bAmyHookedOnTakeDmg[victim] = true;
        }

        SDKHook(victim, SDKHook_PreThink, Amy_SlowThink);

        CreateTimer(duration, T_AmyResetSpeed, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);

        if (!wasAlreadyVulnerable)
        {
            PrintToChat(victim, "\x04[Amy]\x01 ¡CRACK! Huesos rotos contra la pared (desarmado %.0fs)", duration);
        }
    }
}

// =======================
// HABILIDAD 2: HAMMER JUMP
// =======================

void Amy_AddVelocity(int client, float zSpeed)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_iAmyVelocityOffs == -1) return;
    float vel[3];
    GetEntDataVector(client, g_iAmyVelocityOffs, vel);
    vel[2] += zSpeed;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
}

public Action T_AmyLandCheck(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (!Amy_IsValidClient(client))
    {
        if (client > 0 && client <= MaxClients) g_hAmyJumpTimer[client] = null;
        return Plugin_Stop;
    }

    if (GetEntityFlags(client) & FL_ONGROUND)
    {
        float pos[3];
        GetClientAbsOrigin(client, pos);
        Amy_DoEarthquake(client, pos);
        g_hAmyJumpTimer[client] = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

void Amy_DoEarthquake(int client, float origin[3])
{
    if (!Amy_IsValidClient(client)) return;

    Amy_CreateMeteorRocks(origin);
    if (g_fAmyTS_Val < 1.0) Amy_CreateSlowMotion(origin);

    // VFX v2.0: múltiples rings concéntricos rosa + screen shake potente
    Amy_VFX_Earthquake(origin);

    origin[2] += 20.0;

    float visualRadius = g_fAmyTS_Rad * 1.3;
    TE_SetupBeamRingPoint(origin, 10.0, visualRadius, g_iAmyBeamSprite, g_iAmyHaloSprite, 0, 15, 0.5, 10.0, 0.0, {255, 50, 150, 255}, 10, 0);
    TE_SendToAll();

    EmitSoundToAll(AMY_SOUND_QUAKE, client);

    float effectiveRad = g_fAmyTS_Rad * 1.3;
    float radiusSq = effectiveRad * effectiveRad;

    // BONO DE FURIA APLICADO AL TERREMOTO
    float eqDmg = g_fAmyJumpDmg;
    if (g_bAmyFuryActive[client]) eqDmg *= AMY_FURY_DMG_MULT;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED)
            continue;

        float targetPos[3];
        GetClientAbsOrigin(i, targetPos);

        if (GetVectorDistance(origin, targetPos, true) <= radiusSq)
        {
            SDKHooks_TakeDamage(i, client, client, eqDmg, DMG_BLAST);
            Amy_ApplyBrokenBones(i, 4.0);

            float flingDir[3];
            MakeVectorFromPoints(origin, targetPos, flingDir);
            NormalizeVector(flingDir, flingDir);
            ScaleVector(flingDir, g_fAmyFlingForce);
            flingDir[2] += g_fAmyUpForce;

            Amy_ApplyHardStopFling(client, i, flingDir);
        }
    }

    // v49: snapshot-then-strike (no matar/mover entidades mientras se
    // itera la lista del motor)
    int commonList[32];
    int nCommon = 0;
    int infected = -1;
    while ((infected = FindEntityByClassname(infected, "infected")) != -1)
    {
        if (nCommon >= 32) break;
        if (!IsValidEntity(infected)) continue;
        float zPos[3]; GetEntPropVector(infected, Prop_Send, "m_vecOrigin", zPos);

        if (GetVectorDistance(origin, zPos, true) <= radiusSq)
        {
            // v53: LOS obligatorio (no empujar comunes a través de paredes:
            // el push los incrustaba en geometria)
            float eyePos[3];
            GetClientEyePosition(client, eyePos);
            if (!Amy_HasLineOfSight(client, eyePos, zPos)) continue;
            commonList[nCommon++] = infected;
        }
    }

    for (int k = 0; k < nCommon; k++)
    {
        int ent = commonList[k];
        if (ent <= 0 || !IsValidEntity(ent)) continue;
        float zPos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", zPos);

        // v45 FIX: empuje ANTES del dano (el ragdoll hereda el impulso
        // al morir - antes el orden inverso hacia que no volaran)
        float push[3]; MakeVectorFromPoints(origin, zPos, push); NormalizeVector(push, push); ScaleVector(push, 500.0); push[2] = 300.0;
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
        SDKHooks_TakeDamage(ent, client, client, OM_AmpDamage(ent, g_fAmyJumpDmg), DMG_CLUB);
    }

    int witchList[8];
    int nWitch = 0;
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (nWitch >= 8) break;
        if (!IsValidEntity(witch)) continue;
        float wPos[3]; GetEntPropVector(witch, Prop_Send, "m_vecOrigin", wPos);

        if (GetVectorDistance(origin, wPos, true) <= radiusSq)
        {
            // v53: LOS obligatorio (radio de 600+ alcanzaba witches
            // detrás de paredes: mismo escenario del crash del martillo)
            float eyePos[3];
            GetClientEyePosition(client, eyePos);
            if (!Amy_HasLineOfSight(client, eyePos, wPos)) continue;
            witchList[nWitch++] = witch;
        }
    }

    for (int k = 0; k < nWitch; k++)
    {
        int wEnt = witchList[k];
        if (wEnt <= 0 || !IsValidEntity(wEnt)) continue;
        float wPos[3]; GetEntPropVector(wEnt, Prop_Send, "m_vecOrigin", wPos);

        // v46 (Witch Flight): lanzamiento con IA suspendida (la witch
        // vuela de verdad y aterriza con dano de impacto). Dano después
        // del lanzamiento, igual que en el strike.
        {
            float push[3];
            MakeVectorFromPoints(origin, wPos, push);
            NormalizeVector(push, push);
            ScaleVector(push, 250.0);
            push[2] = 900.0;

            WitchFlight_Launch(wEnt, client, push);

            SDKHooks_TakeDamage(wEnt, client, client, OM_AmpDamage(wEnt, g_fAmyJumpDmg), DMG_BLAST);
            Amy_ApplyBrokenBones(wEnt, 4.0);
            // v49: si murió en pleno vuelo, restaurarla YA
            WitchFlight_CheckDead(wEnt);
        }
    }
}

// ============================================================================
//  VFX v2.0 - Funciones de efectos visuales mejorados (Rosa Chillón)
//  Todas usan partículas nativas de L4D2 (no requiere custom content).
// ============================================================================

// Crea un ring de beam expansivo en una posición con color y radio dados.
// Útil para ondas de choque, despegues de salto, etc.
void Amy_VFX_BeamRing(float pos[3], float startRadius, float endRadius,
                     int r, int g, int b, int a, float life, float width)
{
    if (g_iAmyBeamSprite <= 0 || g_iAmyHaloSprite <= 0) return;
    int color[4];
    color[0] = r; color[1] = g; color[2] = b; color[3] = a;
    TE_SetupBeamRingPoint(pos, startRadius, endRadius, g_iAmyBeamSprite,
                          g_iAmyHaloSprite, 0, 15, life, width, 0.0, color, 0, 0);
    TE_SendToAll();
}

// Glow sprite pulsante en una posición.
// (v45: eliminada Amy_VFX_Beam - nunca se llamaba, generaba warning)
void Amy_VFX_Glow(float pos[3], int r, int g, int b, float life, float scale)
{
    if (g_iAmyHaloSprite <= 0) return;
    // TE_SetupGlowSprite no soporta color personalizado, usa el del sprite.
    // Para color custom, usamos beam ring muy pequeño que simula un glow.
    int color[4];
    color[0] = r; color[1] = g; color[2] = b; color[3] = 200;
    TE_SetupBeamRingPoint(pos, 0.0, scale * 2.0, g_iAmyBeamSprite,
                          g_iAmyHaloSprite, 0, 15, life, scale, 0.0, color, 0, 0);
    TE_SendToAll();
}

// Spawn de partícula temporal en posición.
void Amy_VFX_Particle(float pos[3], const char[] particleName, float life = 3.0)
{
    int particle = CreateEntityByName("info_particle_system");
    if (!IsValidEntity(particle)) return;
    DispatchKeyValue(particle, "effect_name", particleName);
    DispatchSpawn(particle);
    ActivateEntity(particle);
    TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(particle, "Start");

    char killOutput[64];
    Format(killOutput, sizeof(killOutput), "OnUser1 !self:Kill::%f:-1", life);
    SetVariantString(killOutput);
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");
}

// Screen shake para todos los jugadores cercanos a una posición.
// L4D2 no expone shake directamente, lo simulamos con env_shake.
void Amy_VFX_ScreenShake(float pos[3], float amplitude, float radius, float duration)
{
    AmyDbg_Log("[VFX] ScreenShake: CreateEntityByName(env_shake)");
    int shake = CreateEntityByName("env_shake");
    if (!IsValidEntity(shake))
    {
        AmyDbg_Log("[VFX] ScreenShake: entidad inválida, ABORTADO");
        return;
    }

    DispatchKeyValueFloat(shake, "amplitude", amplitude);
    DispatchKeyValueFloat(shake, "radius", radius);
    DispatchKeyValueFloat(shake, "duration", duration);
    DispatchKeyValueFloat(shake, "frequency", 255.0);
    DispatchKeyValue(shake, "spawnflags", "1");  // GlobalShake
    DispatchKeyValueVector(shake, "origin", pos);
    AmyDbg_Log("[VFX] ScreenShake: DispatchSpawn (ent=%d)", shake);
    DispatchSpawn(shake);
    AmyDbg_Log("[VFX] ScreenShake: StartShake/AddOutput/FireUser1");
    AcceptEntityInput(shake, "StartShake");

    char killOutput[64];
    Format(killOutput, sizeof(killOutput), "OnUser1 !self:Kill::%f:-1", duration + 0.5);
    SetVariantString(killOutput);
    AcceptEntityInput(shake, "AddOutput");
    AcceptEntityInput(shake, "FireUser1");
    AmyDbg_Log("[VFX] ScreenShake: end OK");
}
// v61: ELIMINADAS Amy_VFX_Strike y Amy_VFX_StrikeHit (VFX del golpe del
// martillo: beam rings, screen shake y burst de particulas). El impulso de
// impacto no tiene VFX por diseño (pedido del usuario).

// ============================================================================
//  VFX: DOBLE SALTO - ring al despegar + trail mientras está en el aire
// ============================================================================

void Amy_VFX_DoubleJump(int client)
{
    if (!Amy_IsValidClient(client)) return;

    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 10.0;

    // Ring expansivo rosa al despegar
    Amy_VFX_BeamRing(pos, 10.0, 100.0,
                     AMY_COLOR_PINK_HOT_R, AMY_COLOR_PINK_HOT_G, AMY_COLOR_PINK_HOT_B, 220,
                     AMY_VFX_JUMP_RING_LIFE, 6.0);

    // Partícula de salto
    Amy_VFX_Particle(pos, AMY_PARTICLE_JUMP_RING, 1.0);

    // Glow breve
    Amy_VFX_Glow(pos, AMY_COLOR_PINK_R, AMY_COLOR_PINK_G, AMY_COLOR_PINK_B,
                 0.3, 12.0);
}

// ============================================================================
//  VFX: FURIA PROTECTORA - aura rosa pulsante en Amy
//  Se invoca desde PreThink cada 0.5s mientras Furia está activa.
// ============================================================================

void Amy_VFX_FuryAura(int client)
{
    if (!Amy_IsValidClient(client)) return;
    if (!g_bAmyFuryActive[client]) return;

    float now = GetEngineTime();
    // Pulso cada 0.4s para no saturar el cliente
    if (now - g_fAmyLastAuraPulse[client] < 0.4) return;
    g_fAmyLastAuraPulse[client] = now;

    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 40.0;

    // Ring pequeño pulsante alrededor de Amy (aura)
    Amy_VFX_BeamRing(pos, 30.0, AMY_VFX_FURY_RADIUS,
                     AMY_COLOR_PINK_HOT_R, AMY_COLOR_PINK_HOT_G, AMY_COLOR_PINK_HOT_B, 180,
                     AMY_VFX_FURY_AURA_LIFE, 3.0);

    // Ring interior más pequeño y brillante
    Amy_VFX_BeamRing(pos, 20.0, 50.0,
                     255, 255, 255, 150,
                     AMY_VFX_FURY_AURA_LIFE * 0.7, 2.0);
}

// ============================================================================
//  VFX: MOMENTUM - chispa rosa al ganar stack
// ============================================================================

void Amy_VFX_Momentum(int client, int stack)
{
    if (!Amy_IsValidClient(client)) return;

    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 40.0;

    // Ring pequeño rosa con intensidad según stack
    int alpha = 150 + (stack * 20);
    if (alpha > 255) alpha = 255;

    Amy_VFX_BeamRing(pos, 10.0, 40.0 + (stack * 8.0),
                     AMY_COLOR_PINK_R, AMY_COLOR_PINK_G, AMY_COLOR_PINK_B, alpha,
                     0.3, 2.0);
}

// ============================================================================
//  VFX v3.0: FURY OVERLAY - tint de pantalla rosa para Amy mientras Furia activa
//  Usa ShowHudText con color rosa que parpadea para máximo impacto visual.
// ============================================================================

void Amy_VFX_FuryOverlay(int client)
{
    if (!Amy_IsValidClient(client)) return;
    if (!g_bAmyFuryActive[client]) return;

    float now = GetEngineTime();
    // Refresh cada 0.5s
    if (now - g_fAmyLastFuryOverlay[client] < AMY_FURY_OVERLAY_LIFE) return;
    g_fAmyLastFuryOverlay[client] = now;

    // Tiempo restante de Furia
    float timeLeft = g_fAmyFuryEndTime[client] - now;
    if (timeLeft < 0.0) timeLeft = 0.0;

    // Hint text con HTML para máximo impacto visual (texto grande rosa en pantalla)
    PrintHintText(client,
        "<font color='#FF00FF' size='24'>>> FURIA PROTECTORA <<</font>\n\
<font color='#FF80C0'>+%d%% Velocidad  |  +%d%% Daño  |  -%d%% Daño Recibido</font>\n\
<font color='#FFFFFF'>Tiempo restante: %.1fs</font>",
        RoundToNearest((AMY_FURY_SPEED_MULT - 1.0) * 100.0),
        RoundToNearest((AMY_FURY_DMG_MULT - 1.0) * 100.0),
        RoundToNearest((1.0 - AMY_FURY_RESIST_MULT) * 100.0),
        timeLeft);
}

// ============================================================================
//  VFX v3.0: MOMENTUM HUD - muestra stacks actuales en pantalla
// ============================================================================

void Amy_VFX_MomentumHUD(int client)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_iAmyMomentumStacks[client] <= 0) return;

    float now = GetEngineTime();
    if (now - g_fAmyLastMomentumHUD[client] < AMY_MOMENTUM_HUD_REFRESH) return;
    g_fAmyLastMomentumHUD[client] = now;

    float timeLeft = g_fAmyMomentumEndTime[client] - now;
    if (timeLeft < 0.0) timeLeft = 0.0;

    int stacks = g_iAmyMomentumStacks[client];
    int speedBonus = RoundToNearest(stacks * AMY_MOMENTUM_SPEED_BONUS * 100.0);
    int dmgBonus = RoundToNearest(stacks * AMY_MOMENTUM_DMG_BONUS * 100.0);

    // Barra visual de stacks con caracteres ASCII (SourcePawn no soporta UTF-8 como char literal)
    char bar[16];
    for (int i = 0; i < AMY_MOMENTUM_MAX_STACKS; i++) {
        bar[i] = (i < stacks) ? '*' : '-';
    }
    bar[AMY_MOMENTUM_MAX_STACKS] = '\0';

    // Usar PrintHintText solo si Furia NO está activa (para no sobreescribir el HUD de Furia)
    if (!g_bAmyFuryActive[client])
    {
        PrintHintText(client,
            "<font color='#FF80C0' size='20'>** MOMENTUM x%d **</font>\n\
<font color='#FFFFFF'>%s</font>\n\
<font color='#FFB6C1'>+%d%% Velocidad  |  +%d%% Daño Melee</font>\n\
<font color='#AAAAAA'>Tiempo: %.1fs</font>",
            stacks, bar, speedBonus, dmgBonus, timeLeft);
    }
}

// ============================================================================
//  VFX v3.0: RUN TRAIL - pequeñas chispas rosa cuando Amy corre con melee
//  Solo se activa si Amy tiene Furia o Momentum activo.
// ============================================================================

void Amy_VFX_RunTrail(int client)
{
    if (!Amy_IsValidClient(client)) return;

    // Solo trail si Amy se está moviendo
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    float speed = GetVectorLength(vel);
    if (speed < 50.0) return;  // no está corriendo

    // Trail sutil: pequeño beam desde la posición de Amy
    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 5.0;

    // Color depende del estado
    int r, g, b;
    if (g_bAmyFuryActive[client]) {
        // Furia: rosa chillón brillante
        r = AMY_COLOR_PINK_R; g = AMY_COLOR_PINK_G; b = AMY_COLOR_PINK_B;
    } else {
        // Solo Momentum: rosa hot
        r = AMY_COLOR_PINK_HOT_R; g = AMY_COLOR_PINK_HOT_G; b = AMY_COLOR_PINK_HOT_B;
    }

    // Glow pequeño en el suelo bajo Amy
    Amy_VFX_Glow(pos, r, g, b, 0.2, 8.0);
}

// ============================================================================
//  VFX: IMPACTO CONTRA PARED - burst rosa intenso + screen shake a víctima
// ============================================================================

void Amy_VFX_WallImpact(float pos[3])
{
    // Burst de partícula intensa
    Amy_VFX_Particle(pos, AMY_PARTICLE_WALL_HIT, 1.5);

    // Ring expansivo grande
    Amy_VFX_BeamRing(pos, 10.0, 150.0,
                     AMY_COLOR_PINK_DEEP_R, AMY_COLOR_PINK_DEEP_G, AMY_COLOR_PINK_DEEP_B, 255,
                     AMY_VFX_WALL_BURST_LIFE, 8.0);

    // Ring secundario blanco/rosa
    Amy_VFX_BeamRing(pos, 5.0, 80.0,
                     255, 200, 220, 200,
                     AMY_VFX_WALL_BURST_LIFE * 0.6, 4.0);

    // Glow grande
    Amy_VFX_Glow(pos, AMY_COLOR_PINK_DEEP_R, AMY_COLOR_PINK_DEEP_G, AMY_COLOR_PINK_DEEP_B,
                 0.8, 25.0);

    // Screen shake fuerte
    Amy_VFX_ScreenShake(pos, 8.0, 400.0, 0.5);
}

// ============================================================================
//  VFX: HAMMER JUMP / EARTHQUAKE - múltiples rings concéntricos
// ============================================================================

void Amy_VFX_Earthquake(float pos[3])
{
    pos[2] += 20.0;

    // Múltiples rings concéntricos inmediatos (sin stagger para evitar bug del parser)
    // Cada ring tiene radio creciente y tono ligeramente diferente
    for (int i = 0; i < AMY_VFX_EARTHQUAKE_RINGS; i++)
    {
        float radius = 100.0 + (i * 150.0);
        float life = 0.5 + (i * 0.2);
        int r = AMY_COLOR_PINK_R - (i * 15);
        if (r < 150) r = 150;
        int g = AMY_COLOR_PINK_G + (i * 10);
        if (g > 100) g = 100;

        Amy_VFX_BeamRing(pos, 10.0, radius, r, g, AMY_COLOR_PINK_B, 220, life, 8.0);
    }

    // Ring inicial grande rosa chillón (inmediato)
    Amy_VFX_BeamRing(pos, 10.0, 200.0,
                     AMY_COLOR_PINK_R, AMY_COLOR_PINK_G, AMY_COLOR_PINK_B, 255,
                     0.5, 12.0);

    // Screen shake potente
    Amy_VFX_ScreenShake(pos, 12.0, 800.0, 0.8);
}

// =======================
// Efectos Visuales (originales - mantenidos por compatibilidad)
// =======================

void Amy_CreateMeteorRocks(float origin[3])
{
    for (int i = 0; i < 3; i++) {
        float rockPos[3]; rockPos = origin;
        rockPos[0] += GetRandomFloat(-100.0, 100.0); rockPos[1] += GetRandomFloat(-100.0, 100.0); rockPos[2] += 20.0;
        int rock = CreateEntityByName("prop_dynamic");
        if (rock != -1) {
            SetEntityModel(rock, AMY_MODEL_CHUNK); DispatchSpawn(rock); TeleportEntity(rock, rockPos, NULL_VECTOR, NULL_VECTOR);
            SetVariantString("OnUser1 !self:kill::5.0:1"); AcceptEntityInput(rock, "AddOutput"); AcceptEntityInput(rock, "FireUser1");
        }
    }
    Amy_SpawnTempParticle(origin, AMY_PARTICLE_EXP1);
    Amy_SpawnTempParticle(origin, AMY_PARTICLE_EXP2);
}

void Amy_CreateSlowMotion(float origin[3])
{
    int iTimescale = CreateEntityByName("func_timescale");
    if (iTimescale != -1) {
        DispatchKeyValueFloat(iTimescale, "desiredTimescale", g_fAmyTS_Val);
        DispatchKeyValueFloat(iTimescale, "acceleration", g_fAmyTS_Acc);
        DispatchKeyValueFloat(iTimescale, "minBlendRate", 1.0);
        DispatchKeyValueFloat(iTimescale, "blendDeltaMultiplier", 2.0);
        DispatchKeyValueVector(iTimescale, "origin", origin);
        DispatchSpawn(iTimescale); AcceptEntityInput(iTimescale, "Start");
        CreateTimer(g_fAmyTS_Dur, T_AmyResetTimescale, EntIndexToEntRef(iTimescale), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action T_AmyResetTimescale(Handle timer, int entRef)
{
    int entity = EntRefToEntIndex(entRef);
    if (entity != INVALID_ENT_REFERENCE && IsValidEntity(entity)) { AcceptEntityInput(entity, "Stop"); AcceptEntityInput(entity, "Kill"); }
    return Plugin_Stop;
}

void Amy_SpawnTempParticle(float pos[3], char[] effectName)
{
    int particle = CreateEntityByName("info_particle_system");
    if (IsValidEntity(particle)) {
        DispatchKeyValue(particle, "effect_name", effectName); DispatchSpawn(particle); ActivateEntity(particle);
        TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR); AcceptEntityInput(particle, "Start");
        SetVariantString("OnUser1 !self:kill::3.0:1"); AcceptEntityInput(particle, "AddOutput"); AcceptEntityInput(particle, "FireUser1");
    }
}

void Amy_SpawnEffect(int client, char[] sParticleName)
{
    if (!Amy_IsValidClient(client)) return;
    float pos[3]; GetClientEyePosition(client, pos);
    int iEntity = CreateEntityByName("info_particle_system");
    if (iEntity != -1) {
        DispatchKeyValue(iEntity, "effect_name", sParticleName); DispatchKeyValueVector(iEntity, "origin", pos); DispatchSpawn(iEntity);
        SetVariantString("!activator"); AcceptEntityInput(iEntity, "SetParent", client); ActivateEntity(iEntity); AcceptEntityInput(iEntity, "Start");
        SetVariantString("OnUser1 !self:kill::5.0:1"); AcceptEntityInput(iEntity, "AddOutput"); AcceptEntityInput(iEntity, "FireUser1");
    }
}

void PrecacheParticle(const char[] sEffectName)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE) table = FindStringTable("ParticleEffectNames");
    if (table == INVALID_STRING_TABLE) return;
    int index = FindStringIndex(table, sEffectName);
    if (index == INVALID_STRING_INDEX) {
        bool save = LockStringTables(false); AddToStringTable(table, sEffectName); LockStringTables(save);
    }
}

void Amy_ClearAllTimers()
{
    for (int i = 1; i <= MaxClients; i++) {
        if (g_hAmyJumpTimer[i] != null) {
            delete g_hAmyJumpTimer[i];
            g_hAmyJumpTimer[i] = null;
        }
        // v45: incluir el timer del cooldown del Poder 2 (antes se quedaba
        // vivo tras round_end/map_end con el slot apuntándolo)
        // v51: sin autoClose: el pack ahora se cierra vía TIMER_DATA_HNDL_CLOSE
        if (g_hAmyPower2Timer[i] != null) {
            KillTimer(g_hAmyPower2Timer[i]);
            g_hAmyPower2Timer[i] = null;
        }
    }
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
public void Amy_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return;
    Amy_ResetVictim(client);

    // v72: limpiar el índice VScript (::SonicAmyIdx) para que nadie más
    // pueda lanzar el martillo mientras Amy está muerta/desconectada o
    // ha cambiado de personaje (esta función llega por los tres caminos
    // gracias a CleanupCharModuleState del manager).
    Amy_PublishScriptIdx(client, false);

    // Limpiar timer de salto
    if (client > 0 && client <= MaxClients && g_hAmyJumpTimer[client] != null)
    {
        delete g_hAmyJumpTimer[client];
        g_hAmyJumpTimer[client] = null;
    }
}
// ============================================================
//  v61 - sm_amydbg: estado del diagnostico de Amy
//  Muestra en consola la build activa y la configuración del impulso.
//  Sirve para CONFIRMAR que el server corre esta build (v61) y no un
//  .smx viejo.
// ============================================================
public Action Amy_CommandDbg(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    char mapName[64];
    GetCurrentMap(mapName, sizeof(mapName));

    PrintToConsole(client, "");
    PrintToConsole(client, "=== AMY DIAGNOSTICO v72 (MARTILLO DE AMY + VSCRIPT v7.4) ===");
    PrintToConsole(client, "Poder 2: puente SetAmyMode(<idx>) -> el vscript Super Tank");
    PrintToConsole(client, "'Amy-Aligned v7.4': Hydro/Vomit solo infectados + fixes");
    PrintToConsole(client, "DeathVail/PhantomBleeding. Martillo v2: solo Amy lo lanza");
    PrintToConsole(client, "+ homing (::SonicAmyIdx publicado en cada spawn).");
    PrintToConsole(client, "Mapa actual: %s | MaxClients: %d", mapName, MaxClients);
    PrintToConsole(client, "Anti-Vómito (menú Mastery): %s",
                   DollSys_AntiVomitoActive(client) ? "ACTIVADO (refleja la bilis del boomer)" : "desactivado (el vómito te afecta normal)");
    PrintToConsole(client, "Tu modo (sm_amymodo): %s | AOE: radio=%.0f, barrido=%.1fs, tick=%.2fs",
                   (g_iAmyAbilityMode[client] == 1) ? "GOLPE AOE (martillo 360)" : "IMPULSO (embestida)",
                   AMY_STRIKE_RANGE, AMY_STRIKE_DURATION, AMY_STRIKE_VISUAL_TICK);
    PrintToConsole(client, "Log paso a paso (amy_dbg_log): %d", (g_cvDbgLog != null && g_cvDbgLog.BoolValue) ? 1 : 0);
    PrintToConsole(client, "Impulso: velocidad=%.0f u/s | duración=%.2fs | distancia=%.0f | radio=%.0f",
                   g_fAmyImpulseSpeed, g_fAmyImpulseDuration, g_fAmyImpulseMaxDist, g_fAmyImpulseRadius);
    PrintToConsole(client, "Danos: común=%.0f | especial=%.0f | witch=%.0f | tank=%.0f | empuje=%.0f",
                   g_fAmyImpDmgCommon, g_fAmyImpDmgSpecial, g_fAmyImpDmgWitch, g_fAmyImpDmgTank, g_fAmyStrikeForce);
    PrintToConsole(client, "Aliados: %s | Cooldown: %.1fs",
                   g_bAmyImpulsePushTeam ? "empujados (sin dano)" : "no afectados",
                   g_fAmyStrikeCD);
    PrintToConsole(client, "v64 CONTROL: 700 u/s (reducida 200 a petición), la embestida SIGUE");
    PrintToConsole(client, "LA MIRADA (giro suave), 2a pulsación de Z frena en seco y seguro de");
    PrintToConsole(client, "vacío en bordes de precipicio (frena sola en el borde).");
    PrintToConsole(client, "v64 IMPARABLE: grupo de colisión DEBRIS durante la embestida");
    PrintToConsole(client, "(atraviesa cuerpos), radio de captura 180, tope 40 comunes/tick");
    PrintToConsole(client, "y ARIETE: tank/especiales delante siguen siendo empujados.");
    PrintToConsole(client, "v64 BOOMER: no recibe dano: sale volando y estalla con bilis");
    PrintToConsole(client, "(pop real + frasco: los comunes se avalanzan al charco).");
    PrintToConsole(client, "v64 JUGO: sonidos de impacto + burst rosa + rompe-huesos contra");
    PrintToConsole(client, "pared (bone break 8s + execute) + desarme 2s sin pared.");
    PrintToConsole(client, "v70 CONTRA: lengua SIEMPRE contraada; el vómito solo con el poder");
    PrintToConsole(client, "Anti-Vómito ON (sm_mastery). Efectos DIFERIDOS 0.1s fuera del hook");
    PrintToConsole(client, "(el pop del boomer ya no re-entra en el spray: fix del crash) y solo");
    PrintToConsole(client, "contra BOOMER VIVO (jars de aliados y explosiones ya no cuentan).");
    PrintToConsole(client, "pinza/montura/carga/garra/empujes: en plena embestida.");
    PrintToConsole(client, "Witch: WitchFlight (vuela congelada como con el martillo). FLYGRAVITY");
    PrintToConsole(client, "sigue activo: WALK se restaura al terminar en todos los caminos.");
    PrintToConsole(client, "v68 EMPUJE: lanzamiento con arco real por tipo (especial/boomer");
    PrintToConsole(client, "400, tank 320, común 300, aliado 220). El stagger YA NO se aplica");
    PrintToConsole(client, "al impactar: la victima VUELA y el monitor de aterrizaje (0.1s)");
    PrintToConsole(client, "le aplica SIStagger al TOCAR EL SUELO (grace 0.45s si no despega,");
    PrintToConsole(client, "timeout 4s, muerte en vuelo = sin stagger). Las 4 contras");
    PrintToConsole(client, "instantaneas usan el mismo lanzamiento. La witch aterriza y");
    PrintToConsole(client, "queda aturdida 0.75s (WitchFlight v2.5: su stagger al aterrizar).");
    PrintToConsole(client, "Activación 100% SourceMod: velocidad + rayos + dano. Cero VFX/arma.");
    PrintToConsole(client, "El log se escribe en addons/sourcemod/logs/amy_impulse_debug.log");
    PrintToConsole(client, "Si el juego se cierra: mira la ÚLTIMA línea de ese archivo.");
    PrintToConsole(client, "");

    if (client > 0)
        ReplyToCommand(client, "[AmyDbg] Estado enviado a la consola (presiona ~).");
    return Plugin_Handled;
}

// ============================================================================
//  SISTEMA DIVA BODY — Amy vistiendo el cuerpo de Rochelle (Sally)
//
//  Si Amy (STEAM_0:1:410494263) usa a Rochelle (el cuerpo que pertenece
//  a Sally) Y la Sally real (STEAM_0:0:889541669) NO está presente en
//  el servidor, Amy obtiene las siguientes pasivas:
//
//  Pasiva A: CINTURA DE LA DIVA
//    - 75% de evasión
//    - Si evade con éxito: limpia agarres y evita el daño
//    - Si está siendo agarrada: la evasión NO aplica PERO recibe 0 daño
//      (o sea, los agarres no le hacen daño)
//
//  Pasiva B: DIVA DOLL
//    - 75% de reducción de daño (sobre el daño restante tras evasión)
//
//  Pasiva C: ENLACE
//    - Si hay survivors vivos: divide el daño entre todos los aliados
//      (Amy no recibe nada, los demás lo reciben por ella)
//    - Si NO hay aliados o están muertos: el daño rebotaa los enemigos
//      (Amy sí puede recibir daño en este caso, pero reduce 50% del rebotado)
//    - Incluye efecto "Verdugo de Gigantes"
//
//  Pasiva D: ANTI-WITCH
//    - La Witch causará 99.9% menos de daño a Amy
//
//  Pasiva E: INCAP INMUNE
//    - Si Amy está incapacitada, NO recibe daño (no se desangra)
//
//  Temáticamente: Amy "se pone" a Sally como un disfraz. Al hacerlo,
//  gana las defensas pasivas de Sally (que estaban imbuídas en el cuerpo).
//  Pero como Sally real no está, los hilos protectores quedan disponibles
//  para que Amy los use en su lugar.
// ============================================================================

#define DIVA_AMY_STEAMID    "STEAM_1:1:410494263"
#define DIVA_SALLY_STEAMID  "STEAM_1:0:889541669"

// Constantes Diva Body
#define DIVA_EVASION_CHANCE        75    // 75% evasión
#define DIVA_DOLL_REDUCTION        0.75  // 75% reducción
#define DIVA_WITCH_DMG_MULT        0.001 // 99.9% menos daño de witch
#define DIVA_GIANT_SLAYER_MULT     2.0   // Verdugo de Gigantes: daño a SI x2
#define DIVA_ENLACE_REBOUND_REDUCE 0.50  // Al rebotar daño a enemigos, Amy recibe 50% del original

// IDs de Rochelle — L4D2 vanilla = 1, pero algunos mods lo cambian.
// Aceptamos ambos IDs para compatibilidad.
#define ROCHELLE_ID_VANILLA   1
#define ROCHELLE_ID_MOD       3

// Nota: g_bDivaBodyActive y g_bDivaSallyPresent están declaradas al inicio del archivo
// (junto con las demás variables globales de Amy) para que sean visibles desde
// todos los hooks, incluyendo Amy_OnTakeDamage_Passive.

// Helper: comparar SteamID aceptando tanto STEAM_0: como STEAM_1: (compatibilidad L4D2)
bool Diva_MatchSteamID(const char[] actualAuth, const char[] expectedAuth)
{
    // Comparación directa
    if (StrEqual(actualAuth, expectedAuth)) return true;

    // Si el actual empieza con STEAM_0 y el esperado con STEAM_1 (o viceversa),
    // comparar ignorando ese dígito
    if (strlen(actualAuth) >= 8 && strlen(expectedAuth) >= 8)
    {
        if (actualAuth[5] != expectedAuth[5])
        {
            // Difieren en el 0/1, comparar el resto
            if (StrEqual(actualAuth[7], expectedAuth[7])) return true;
        }
    }
    return false;
}

// Helper: ¿Es el survivor character Rochelle? (acepta ID 1 o 3)
bool Diva_IsRochelleChar(int survChar)
{
    return (survChar == ROCHELLE_ID_VANILLA || survChar == ROCHELLE_ID_MOD);
}

// ============================================================================
//  DETECCIÓN: ¿Amy tiene Diva Body activo?
//  Solo si: Amy usa Rochelle (character ID 1) Y Sally real no está conectada
// ============================================================================
bool Amy_IsDivaBody(int client)
{
    if (!Amy_IsValidClient(client)) return false;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return false;

    // CRÍTICO: m_iSurvivorCharacter solo existe en CTerrorPlayer que son survivors.
    // Si el player es espectador/infectado/no-spawneado, GetEntProp crashea.
    if (GetClientTeam(client) != TEAM_SURVIVOR) return false;

    // Verificar SteamID de Amy (acepta STEAM_0 o STEAM_1)
    char auth[32];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
    if (!Diva_MatchSteamID(auth, DIVA_AMY_STEAMID)) return false;

    // Usar el survivor character cacheado (se actualiza en player_spawn)
    // Esto evita crashear si la netprop no está disponible en algún momento
    // Acepta ID 1 (vanilla) o ID 3 (mod) como Rochelle
    if (!Diva_IsRochelleChar(g_iDivaCachedSurvChar[client])) return false;

    // Verificar que la Sally real NO esté presente
    if (g_bDivaSallyPresent) return false;

    return true;
}

// Actualizar el cache de survivor character — llamar en player_spawn
void Diva_UpdateSurvCharCache(int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;
    if (GetClientTeam(client) != TEAM_SURVIVOR)
    {
        g_iDivaCachedSurvChar[client] = -1;
        return;
    }

    // ESTRATEGIA: usar el nombre del modelo como fuente PRIMARIA
    // Es más confiable que m_iSurvivorCharacter porque:
    //  1. Siempre existe (no crashea)
    //  2. Se actualiza inmediatamente al cambiar de personaje
    //  3. No depende de estados transitorios del spawn
    char modelName[256];
    GetEntPropString(client, Prop_Data, "m_ModelName", modelName, sizeof(modelName));

    int survChar = -1;

    // Detectar por nombre de modelo (vanilla y nombres técnicos)
    if (StrContains(modelName, "rochelle", false) >= 0 ||
        StrContains(modelName, "survivor_producer", false) >= 0)
    {
        survChar = 1;  // Rochelle
    }
    else if (StrContains(modelName, "zoey", false) >= 0 ||
             StrContains(modelName, "survivor_teenangst", false) >= 0)
    {
        survChar = 0;  // Zoey (en L4D2)
    }
    else if (StrContains(modelName, "coach", false) >= 0 ||
             StrContains(modelName, "survivor_coach", false) >= 0)
    {
        survChar = 2;  // Coach
    }
    else if (StrContains(modelName, "ellis", false) >= 0 ||
             StrContains(modelName, "survivor_mechanic", false) >= 0)
    {
        survChar = 3;  // Ellis
    }
    else if (StrContains(modelName, "nick", false) >= 0 ||
             StrContains(modelName, "survivor_gambler", false) >= 0)
    {
        survChar = 4;  // Nick
    }
    else if (StrContains(modelName, "bill", false) >= 0 ||
             StrContains(modelName, "survivor_namvet", false) >= 0)
    {
        survChar = 5;  // Bill
    }
    else if (StrContains(modelName, "francis", false) >= 0 ||
             StrContains(modelName, "survivor_biker", false) >= 0)
    {
        survChar = 6;  // Francis
    }
    else if (StrContains(modelName, "louis", false) >= 0 ||
             StrContains(modelName, "survivor_manager", false) >= 0)
    {
        survChar = 7;  // Louis
    }
    else
    {
        // Fallback: intentar con m_iSurvivorCharacter si la prop existe
        if (HasEntProp(client, Prop_Send, "m_iSurvivorCharacter"))
        {
            survChar = GetEntProp(client, Prop_Send, "m_iSurvivorCharacter");
        }
    }

    g_iDivaCachedSurvChar[client] = survChar;
}


// Actualizar estado de "Sally presente" — llamar en player_spawn y disconnect
public void Diva_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    // Si es un SI, hookearlo para Verdugo de Gigantes
    if (GetClientTeam(client) == TEAM_INFECTED)
    {
        Diva_HookSIOnSpawn(client);
    }

    // Actualizar cache de survivor character para todos los players
    // (especialmente importante para Amy cuando spawnea como Rochelle)
    Diva_UpdateSurvCharCache(client);

    char auth[32];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
    if (Diva_MatchSteamID(auth, DIVA_SALLY_STEAMID))
    {
        g_bDivaSallyPresent = true;
        PrintToServer("[DivaBody] Sally real detectada (SteamID: %s). Diva Body desactivado para Amy.", auth);
    }

    // Recalcular Diva Body para todas las Amys presentes
    Diva_RefreshAllAmys();
}

// ============================================================================
//  ROUND_START — Resetear estado de Diva Body al iniciar nueva ronda/campaña
//  Esto es CRÍTICO porque:
//    - Las variables g_bDivaBodyActive quedan en true de la ronda anterior
//    - Pero los SDKHooks pueden haberse perdido
//    - El cache de survivor character puede estar desactualizado
//    - g_bDivaSallyPresent puede ser erróneo (Sally desconectada entre rondas)
// ============================================================================
public void Diva_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    PrintToServer("[DivaBody] === ROUND START — Reseteando estado Diva Body ===");

    // 1. Resetear estado de "Sally presente" — se recalculará en player_spawn
    g_bDivaSallyPresent = false;

    // 2. Resetear todos los estados Diva Body y caches
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bDivaBodyActive[i] = false;
        g_iDivaCachedSurvChar[i] = -1;
        g_fDivaLastCacheUpdate[i] = 0.0;
        g_fDivaLastChatMsg[i] = 0.0;
    }

    // 3. Volver a escanear todos los jugadores conectados para detectar Amy/Sally
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;

        char auth[32];
        GetClientAuthId(i, AuthId_Steam2, auth, sizeof(auth));

        // Detectar Sally real
        if (Diva_MatchSteamID(auth, DIVA_SALLY_STEAMID))
        {
            g_bDivaSallyPresent = true;
            PrintToServer("[DivaBody] Sally real detectada en round_start: %N", i);
        }
    }

    // 4. Múltiples re-verificaciones para asegurar que el modelo esté cargado
    // 3s: primer intento (juego terminando de cargar)
    // 5s: segundo intento (player spawn completo)
    // 10s: último intento (por si hay lag)
    CreateTimer(3.0, Diva_Timer_RoundStartRecheck, 1, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(5.0, Diva_Timer_RoundStartRecheck, 2, TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(10.0, Diva_Timer_RoundStartRecheck, 3, TIMER_FLAG_NO_MAPCHANGE);

    PrintToServer("[DivaBody] Reset completado. Re-verificaciones programadas a 3s, 5s, 10s.");
}

// Timer: re-verificar Diva Body para todos los jugadores después de round_start
// Recibe un "intento" (1, 2, 3) para logs
public Action Diva_Timer_RoundStartRecheck(Handle timer, int intento)
{
    PrintToServer("[DivaBody] === Re-verificación post round_start (intento %d) ===", intento);

    // Actualizar cache de survivor character para todos
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        if (GetClientTeam(i) != TEAM_SURVIVOR) continue;

        Diva_UpdateSurvCharCache(i);
    }

    // Refrescar Diva Body para todas las Amys
    Diva_RefreshAllAmys();

    // Verificar que los hooks de daño estén activos para las Amys con Diva Body
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        if (!g_bDivaBodyActive[i]) continue;

        // Re-registrar el hook SDKHook para asegurar que esté activo
        SDKUnhook(i, SDKHook_OnTakeDamage, Amy_OnTakeDamage_Passive);
        SDKHook(i, SDKHook_OnTakeDamage, Amy_OnTakeDamage_Passive);

        PrintToServer("[DivaBody] ✓ Hook de daño re-registrado para %N (intento %d)", i, intento);

        // Solo mostrar mensaje en chat en el primer intento exitoso
        if (intento == 1)
        {
            PrintToChat(i, "\x04[DivaBody]\x01 ✓ Reactivado tras round_start.");
        }
    }

    return Plugin_Stop;
}

// Función helper: refrescar Diva Body en todas las Amys
void Diva_RefreshAllAmys()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        if (g_iPlayerCharIdx[i] != AMY_INDEX) continue;

        bool newState = Amy_IsDivaBody(i);
        if (newState && !g_bDivaBodyActive[i])
        {
            g_bDivaBodyActive[i] = true;
            PrintHintText(i, "<font color='#FF00FF' size='24'>>> DIVA BODY <<</font>\n<font color='#FF80C0'>Vistiendo el cuerpo de Sally. Las defensas de la muñequita te pertenecen ahora.</font>");
            EmitSoundToClient(i, "ambient/energy/force_field_loop1.wav");
            PrintToServer("[DivaBody] ✓ Activado para %N", i);
        }
        else if (!newState && g_bDivaBodyActive[i])
        {
            g_bDivaBodyActive[i] = false;
            PrintToServer("[DivaBody] ✗ Desactivado para %N (condiciones ya no se cumplen)", i);
        }
    }
}

public void Diva_OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients) return;

    char auth[32];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
    if (Diva_MatchSteamID(auth, DIVA_SALLY_STEAMID))
    {
        g_bDivaSallyPresent = false;
        PrintToServer("[DivaBody] Sally real se desconectó. Diva Body puede activarse para Amy.");

        // Reactivar Diva Body para Amy si aplica
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && g_iPlayerCharIdx[i] == AMY_INDEX)
            {
                if (Amy_IsDivaBody(i) && !g_bDivaBodyActive[i])
                {
                    g_bDivaBodyActive[i] = true;
                    PrintHintText(i, "<font color='#FF00FF' size='24'>>> DIVA BODY <<</font>\n<font color='#FF80C0'>Sally se fue. Su cuerpo es tuyo ahora.</font>");
                }
            }
        }
    }
}

// ============================================================================
//  PLAYER_TEAM — Detectar cuando Amy cambia de equipo o personaje
//  Esto es importante porque al cambiar de capítulo, el player puede
//  pasar brevemente por spectator antes de volver a survivor.
// ============================================================================
public void Diva_OnPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    int oldTeam = event.GetInt("oldteam");
    int newTeam = event.GetInt("team");

    // Si el player cambió a survivor, actualizar cache y re-verificar
    if (newTeam == TEAM_SURVIVOR)
    {
        // Delay de 0.5s para que el modelo esté cargado
        DataPack dp = new DataPack();
        dp.WriteCell(client);
        // v51: TIMER_DATA_HNDL_CLOSE (mapa gira en pleno re-check = cero leak)
        CreateTimer(0.5, Diva_Timer_TeamChangeRecheck, dp, TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
    }
    else if (oldTeam == TEAM_SURVIVOR && newTeam != TEAM_SURVIVOR)
    {
        // Salió de survivor — desactivar Diva Body
        if (g_bDivaBodyActive[client])
        {
            g_bDivaBodyActive[client] = false;
            g_iDivaCachedSurvChar[client] = -1;
        }
    }
}

public Action Diva_Timer_TeamChangeRecheck(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();
    // v51: el pack lo cierra TIMER_DATA_HNDL_CLOSE al terminar el timer

    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return Plugin_Stop;

    Diva_UpdateSurvCharCache(client);
    Diva_RefreshAllAmys();

    return Plugin_Stop;
}

// ============================================================================
//  HELPERS — Detección de agarres, witch, etc.
// ============================================================================

// ¿Amy está siendo agarrada por un SI?
bool Diva_IsBeingGrappled(int client)
{
    if (!IsPlayerAlive(client)) return false;

    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0)  return true; // Hunter
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner")   > 0)  return true; // Smoker
    if (GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0)  return true; // Charger pummel
    if (GetEntPropEnt(client, Prop_Send, "m_carryAttacker")  > 0)  return true; // Charger carry
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0)  return true; // Jockey

    return false;
}

// ============================================================================
//  HOOK DE DAÑO A SI — Verdugo de Gigantes
//  Cuando Amy (con Diva Body) daña a un SI, aplica 2x daño
// ============================================================================
public Action Amy_DivaBody_OnSIDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
    if (!g_bDivaBodyActive[attacker]) return Plugin_Continue;

    // Verdugo de Gigantes: 2x daño a infectados
    damage *= DIVA_GIANT_SLAYER_MULT;
    return Plugin_Changed;
}

// ============================================================================
//  HOOK DE WITCH SPAWN — Anti-Witch
//  Cuando spawnea una witch, hookearla para reducir su daño a Amy
// ============================================================================
public void Diva_OnWitchSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int witch = event.GetInt("witchid");
    if (witch <= 0 || !IsValidEntity(witch)) return;

    SDKHook(witch, SDKHook_OnTakeDamage, Amy_DivaBody_OnWitchDamage);
}

public Action Amy_DivaBody_OnWitchDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    // ¿Amy es la atacante? Aplicar verdugo de gigantes también a la witch
    if (attacker > 0 && attacker <= MaxClients && g_bDivaBodyActive[attacker])
    {
        damage *= DIVA_GIANT_SLAYER_MULT;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

// ============================================================================
//  HOOK DE SI SPAWN — Verdugo de Gigantes
//  Cuando un SI spawnea, hookearlo para aplicar el multiplicador de daño
// ============================================================================
void Diva_HookSIOnSpawn(int client)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;
    if (GetClientTeam(client) != TEAM_INFECTED) return;

    SDKHook(client, SDKHook_OnTakeDamage, Amy_DivaBody_OnSIDamage);
}

// ============================================================================
//  COMANDO DEBUG: sm_divadebug
//  Muestra el estado completo de Diva Body en la consola del jugador.
//  Útil para verificar si los buffs están realmente activos.
// ============================================================================
Action Amy_CommandDivaDebug(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || client > MaxClients || !IsClientInGame(client))
    {
        ReplyToCommand(client, "[DivaBody] Comando solo usable in-game.");
        return Plugin_Handled;
    }

    PrintToConsole(client, "");
    PrintToConsole(client, "========================================");
    PrintToConsole(client, "  DIVA BODY — ESTADO ACTUAL");
    PrintToConsole(client, "========================================");
    PrintToConsole(client, "");

    // Información del jugador que ejecuta el comando
    char auth[32];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
    int survChar = g_iDivaCachedSurvChar[client];
    int charIdx = g_iPlayerCharIdx[client];
    int team = GetClientTeam(client);

    PrintToConsole(client, "[JUGADOR]");
    PrintToConsole(client, "  Nombre: %N", client);
    PrintToConsole(client, "  SteamID: %s", auth);
    PrintToConsole(client, "  Team: %d (Survivor=2)", team);
    PrintToConsole(client, "  CharIdx: %d (AMY_INDEX=%d)", charIdx, AMY_INDEX);

    // Leer el survivor character EN VIVO (no del cache) para diagnóstico
    int liveSurvChar = -1;
    if (team == TEAM_SURVIVOR && IsPlayerAlive(client))
    {
        // Verificar que la prop exista antes de leerla
        if (HasEntProp(client, Prop_Send, "m_iSurvivorCharacter"))
        {
            liveSurvChar = GetEntProp(client, Prop_Send, "m_iSurvivorCharacter");
        }
        else
        {
            // La prop no existe — usar el modelo como fallback
            char modelName2[256];
            GetEntPropString(client, Prop_Data, "m_ModelName", modelName2, sizeof(modelName2));
            if (StrContains(modelName2, "rochelle", false) >= 0 ||
                StrContains(modelName2, "survivor_producer", false) >= 0)
            {
                liveSurvChar = ROCHELLE_ID_VANILLA;
            }
        }
    }
    PrintToConsole(client, "  Survivor Character (EN VIVO): %d", liveSurvChar);
    PrintToConsole(client, "  Survivor Character (cacheado): %d (Rochelle=1 o 3)", survChar);

    // Mostrar el nombre del modelo para verificar que realmente es Rochelle
    char modelName[256];
    GetEntPropString(client, Prop_Data, "m_ModelName", modelName, sizeof(modelName));
    PrintToConsole(client, "  Modelo: %s", modelName);
    PrintToConsole(client, "  Vivo: %s", IsPlayerAlive(client) ? "SI" : "NO");
    PrintToConsole(client, "");

    // Estado del sistema Diva Body
    PrintToConsole(client, "[SISTEMA DIVA BODY]");
    PrintToConsole(client, "  Amy SteamID esperado: %s", DIVA_AMY_STEAMID);
    PrintToConsole(client, "  Sally SteamID esperado: %s", DIVA_SALLY_STEAMID);
    PrintToConsole(client, "  Sally real presente: %s", g_bDivaSallyPresent ? "SI (Diva desactivado)" : "NO");
    PrintToConsole(client, "  Diva Body ACTIVO para ti: %s", g_bDivaBodyActive[client] ? "SI" : "NO");
    PrintToConsole(client, "  Amy_IsDivaBody(client): %s", Amy_IsDivaBody(client) ? "SI" : "NO");
    PrintToConsole(client, "");

    // Diagnóstico: ¿por qué no está activo?
    if (!g_bDivaBodyActive[client])
    {
        PrintToConsole(client, "[DIAGNÓSTICO — Razones por las que Diva Body NO está activo]");

        if (!IsPlayerAlive(client))
            PrintToConsole(client, "  ✗ No estás vivo");

        if (charIdx != AMY_INDEX)
            PrintToConsole(client, "  ✗ CharIdx != AMY_INDEX (no eres Amy)");

        if (team != TEAM_SURVIVOR)
            PrintToConsole(client, "  ✗ No estás en team Survivor (team=%d)", team);

        bool isAmySteam = Diva_MatchSteamID(auth, DIVA_AMY_STEAMID);
        if (!isAmySteam)
            PrintToConsole(client, "  ✗ Tu SteamID no coincide con DIVA_AMY_STEAMID");

        // Comparar ambos valores (cacheado vs en vivo) — aceptar ID 1 o 3 como Rochelle
        bool liveIsRochelle = Diva_IsRochelleChar(liveSurvChar);
        bool cacheIsRochelle = Diva_IsRochelleChar(survChar);

        if (!cacheIsRochelle && !liveIsRochelle)
        {
            PrintToConsole(client, "  ✗ No estás usando Rochelle (cacheado=%d, en vivo=%d, esperado=1 o 3)", survChar, liveSurvChar);
        }
        else if (!cacheIsRochelle && liveIsRochelle)
        {
            PrintToConsole(client, "  ⚠ El valor EN VIVO es Rochelle (%d) pero el CACHEADO no (%d) — actualizando cache...", liveSurvChar, survChar);
            Diva_UpdateSurvCharCache(client);
            PrintToConsole(client, "  ✓ Cache actualizado. Ejecuta sm_divadebug de nuevo.");
        }

        if (g_bDivaSallyPresent)
            PrintToConsole(client, "  ✗ La Sally real está presente en el servidor");
    }
    else
    {
        PrintToConsole(client, "[BUFFS ACTIVOS]");
        PrintToConsole(client, "  ✓ Cintura de la Diva (75%% evasión + cleanse agarres)");
        PrintToConsole(client, "  ✓ Diva Doll (75%% reducción de daño)");
        PrintToConsole(client, "  ✓ Enlace (daño dividido entre allies o rebotado x2)");
        PrintToConsole(client, "  ✓ Anti-Witch (99.9%% menos daño de witch)");
        PrintToConsole(client, "  ✓ Incap Inmune (sin daño mientras incapacitada)");
        PrintToConsole(client, "  ✓ Verdugo de Gigantes (2x daño a infectados)");
    }
    PrintToConsole(client, "");

    // Lista de Amys en el servidor
    PrintToConsole(client, "[AMYS EN EL SERVIDOR]");
    int amyCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        if (g_iPlayerCharIdx[i] != AMY_INDEX) continue;

        char aAuth[32];
        GetClientAuthId(i, AuthId_Steam2, aAuth, sizeof(aAuth));
        int aSurv = g_iDivaCachedSurvChar[i];

        PrintToConsole(client, "  %N: SteamID=%s | Char=%d | DivaBody=%s",
                       i, aAuth, aSurv, g_bDivaBodyActive[i] ? "ACTIVO" : "inactivo");
        amyCount++;
    }
    if (amyCount == 0)
        PrintToConsole(client, "  (ninguna Amy detectada)");
    PrintToConsole(client, "");

    // Lista de Sallys reales
    PrintToConsole(client, "[SALLYS REALES EN EL SERVIDOR]");
    int sallyCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;

        char sAuth[32];
        GetClientAuthId(i, AuthId_Steam2, sAuth, sizeof(sAuth));
        if (Diva_MatchSteamID(sAuth, DIVA_SALLY_STEAMID))
        {
            PrintToConsole(client, "  %N: SteamID=%s (DETECTADA — Diva Body bloqueado)", i, sAuth);
            sallyCount++;
        }
    }
    if (sallyCount == 0)
        PrintToConsole(client, "  (ninguna Sally real — Diva Body puede activarse)");
    PrintToConsole(client, "");

    PrintToConsole(client, "========================================");
    PrintToConsole(client, "");

    PrintToChat(client, "\x04[DivaBody]\x01 Estado enviado a la consola. (presiona ~ para ver)");

    return Plugin_Handled;
}

// ################################################################
// ################################################################
// ##                                                            ##
// ##   v92 - AMY OM (Outcome Memories GMod) — "LAS 4 RANURAS"   ##
// ##                                                            ##
// ################################################################
// ################################################################
//
// PEDIDO DEL OWNER (textual): "recuerdas que tengo espacio para 4
// habilidades actualmente no solo 3 son 4: las cartas actuales de
// super tank pasaran a ser la habilidad 4, la X (habilidad 2) tendrá
// la nueva versión de las cartas, el lanzamiento de martillo será la
// habilidad 3 y la Z o la habilidad 1 que es el swing estara
// fusionada con la habilidad en área [...] cuando se usa ella levanta
// y se pone en posición defensa, durante ese tiempo si choca contra
// un infectado utiliza la habilidad para aturdir al oponente por 3.5
// seg que aumenta dependiendo de las cartas que salgan, pero este
// aturdimiento es como el aturdimiento pre de sonic (no lo coloca en
// ragdoll). El lanzamiento de martillo por otra parte si [lo hace]:
// este si es capaz de mandar a volar al oponente [...] no olvides de
// incluir el avatar y todo (es el punto de todo esto)".
//
// NUEVO MAPA DE RANURAS (manager 3.77.0):
//   Z (sm_sjs_ability1) = SWING FUSIONADO: golpe AOE 360 (el de
//       siempre, Amy_DoHammerAOE) + VENTANA DE DEFENSA (HammerDuration
//       del GMod): 2s con el martillo en alto; el primer especial/
//       tank/witch que la toque (radio 130) recibe la CONTRA:
//       aturdimiento PRE-SONIC (OM_Stun: estatua + estrellas, SIN
//       ragdoll) de 3.5s + bonus de cartas. En modo DASH la Z sigue
//       siendo la embestida de siempre (la C cambia el modo).
//   X (sm_sjs_ability2) = CARTAS DEL TAROT (nuevas, el CARDSWAP del
//       GMod): roba 2 de 6 sin repetir (Moon/Sun/Emperor/Strength/
//       World/Fool), AMBAS activas a la vez (en GMod la UI solo las
//       MUESTRA). Efectos persistentes hasta el próximo robo:
//       bonus de stun (Strength +1, Fool -1), multiplicador de dano
//       recibido (Emperor 0.85, Strength 1.15, Moon 1.15|0.85
//       aleatorio), velocidad (Emperor +, Strength -, Fool +, Moon
//       +- aleatorio) y la carta Sun cura +1hp cada 2s (tope 75) a
//       los personajes del suite en 200 a la redonda.
//   C (bind directo sm_amymodo) = CAMBIO DE MODO — igual que hoy:
//       "La c permite cambiar entre el ataque en área y el dash
//       hammer" (owner). La ranura sm_sjs_ability3 YA NO es el modo.
//   V (sm_sjs_ability3) = HABILIDAD 3: LANZAMIENTO DE MARTILLO (el
//       Throw del GMod): 1a pulsación ARMA (sonido de listo), 2a
//       LANZA el martillo como prop_physics_override (hammer.mdl,
//       masa 50, poder 3000 +150z, trail blanco) hacia donde mira;
//       al impactar contra un especial/tank/witch: stun + RAGDOLL
//       FALSO que SALE VOLANDO (receta sonic v6.11-6.13: onda física
//       env_physexplosion filtrada por targetname — "este si es
//       capaz de mandar a volar al oponente"). Sin martillo en mano
//       mientras vuela: recogida al acercarse (140u) o retorno solo
//       a los 8s (vuela de vuelta con giro), EndLag 0.85s.
//   B (sm_sjs_ability4) = HABILIDAD 4: CARTAS DEL SUPER TANK — el
//       viejo Command_RandomPower INTACTO, solo mudado de la X.
//       ("las cartas actuales de super tank pasaran a ser la
//       habilidad 4").
//
// AVATAR ESPEJO: amy.mdl del VPK de recursos (patron Tails/Sonic
// completo: copia R para todos + copia L contra-rotada para la duna,
// RENDER_NONE del cuerpo, FSM 10 Hz auto-reparable, ragdoll de muerte
// + ventana anti-ragdoll del mod del owner). Anims del GMod amy.mdl:
// idleattack/walkattack/runattack (ventana), idlethrow/walkthrow/
// runthrow (armada), idleaxeless (sin martillo), Downed*, *_lowhealth,
// gestos one-shot swing/throw.
//
// REUSO DIRECTO (sonic.inc va ANTES que Amy.inc en el manager):
//   OM_Stun (el "pre-stun"), Sonic_SpawnFlingRagdoll +
//   Sonic_SpawnWitchRagdoll + Sonic_WitchStun (el ragdoll volador con
//   onda, hueco seguro y restauración — T_SonicStunWatch vigila),
//   Sonic_TEStartFollow/Sonic_TEStop (motor TE de trails de sonic.inc), helpers del avatar de Tails
//   (Tails_AvatarLocalAngles / Tails_ExpDamp / Tails_UnwrapYaw /
//   Tails_MarkInterp / Tails_PauseFix_Trigger / Tails_AvatarTPOn).
// v98-OM: la copia R (la que ven LOS DEMAS) viaja en modo TP cuando
//   tails_avatar_tp 1 (default): SIN parent, TeleportEntity por tick
//   en pose mundo + reloj vivo, SIN EF_NOINTERP -> los demas la
//   INTERPOLAN (suave sin depender de la pausa). La copia L del dueño
//   queda parentada + EF_NOINTERP + pulso como siempre.
// ============================================================

// ============================================================
//  v92 - ARRANQUE DEL MODULO OM (lo invoca Amy_OnPluginStart)
//  (las DECLARACIONES viven arriba, junto a AMY_INC_VERSION)
// ============================================================
public void Amy_OM_OnPluginStart()
{
    g_cvAmyOMAvatar        = CreateConVar("amyom_avatar", "1", "Amy OM v92: avatar espejo (amy.mdl del VPK de recursos, patron Tails/Sonic)", _, true, 0.0, true, 1.0);
    g_cvAmyOMCounterWindow = CreateConVar("amyom_counter_window", "2.0", "Amy OM v92: segundos de la VENTANA DE DEFENSA de la Z tras el golpe en área [GMod Hammer_dur: 2]", _, true, 0.2, true, 10.0);
    g_cvAmyOMCounterStun   = CreateConVar("amyom_counter_stun", "3.5", "Amy OM v92: segundos de la CONTRA (pre-stun SIN ragdoll) [owner: 3.5 | GMod base: 3] + bonus de cartas", _, true, 0.5, true, 12.0);
    g_cvAmyOMCounterRadius = CreateConVar("amyom_counter_radius", "130", "Amy OM v92: radio de la contra (el que la toque dentro de este radio la activa) [GMod FindInSphere: 130]", _, true, 40.0, true, 400.0);
    g_cvAmyOMCounterDmg    = CreateConVar("amyom_counter_dmg", "20", "Amy OM v92: dano de la contra (viaja DENTRO del OM_Stun, como el GMod)", _, true, 0.0, true, 500.0);
    g_cvAmyOMTarotCD       = CreateConVar("amyom_tarot_cd", "18", "Amy OM v92: cooldown del robo de cartas (X) [GMod CardSwap_cd: 18]", _, true, 0.0, true, 120.0);
    g_cvAmyOMTarotDelay    = CreateConVar("amyom_tarot_delay", "4", "Amy OM v92: CardUsageDelay del GMod: segundos tras robar en los que no se puede volver a robar", _, true, 0.0, true, 30.0);
    g_cvAmyOMTarotSpeed    = CreateConVar("amyom_tarot_speed", "1", "Amy OM v92: las cartas también modifican la VELOCIDAD (Emperador +15%, Fuerza -20%, Loco +10%, Luna +-15%); 0 = desactivado", _, true, 0.0, true, 1.0);
    g_cvAmyOMTarotHeal     = CreateConVar("amyom_tarot_heal", "1", "Amy OM v92: la carta SOL cura +1hp cada 2s (tope 75) a los personajes del suite en 200 a la redonda; 0 = desactivado", _, true, 0.0, true, 1.0);
    g_cvAmyOMThrowCD       = CreateConVar("amyom_throw_cd", "24", "Amy OM v92: cooldown del LANZAMIENTO (V) [GMod Throw_cd: 24]", _, true, 0.0, true, 120.0);
    g_cvAmyOMThrowPower    = CreateConVar("amyom_throw_power", "3000", "Amy OM v92: velocidad del martillo lanzado [GMod: 10000*0.3 = 3000]", _, true, 500.0, true, 6000.0);
    g_cvAmyOMThrowDmg      = CreateConVar("amyom_throw_dmg", "25", "Amy OM v92: dano del impacto del martillo a especiales y tank", _, true, 0.0, true, 500.0);
    g_cvAmyOMThrowDmgCommon= CreateConVar("amyom_throw_dmg_common", "500", "Amy OM v92: dano del martillo a comunes (atraviesa la horda)", _, true, 0.0, true, 9999.0);
    g_cvAmyOMThrowReturn   = CreateConVar("amyom_throw_return", "8", "Amy OM v92: segundos hasta que el martillo VUELVE SOLO volando a la mano [GMod: 8]", _, true, 1.0, true, 60.0);
    g_cvAmyOMThrowGrab     = CreateConVar("amyom_throw_grab", "140", "Amy OM v92: distancia de recogida acercándose al martillo tirado [GMod: 140]", _, true, 40.0, true, 400.0);
    g_cvAmyOMTrails        = CreateConVar("amyom_trails", "1", "Amy OM v92: trail blanco del martillo lanzado (el SpriteTrail del GMod)", _, true, 0.0, true, 1.0);
    g_cvAmyOMThrowHitbox   = CreateConVar("amyom_throw_hitbox", "1.35", "Amy OM v96: multiplicador del HITBOX AÉREO del martillo lanzado (1.35 = 35% más grande que su cuerpo, pedido del owner; 1.0 = solo su colisión física)", _, true, 1.0, true, 3.0);
    g_cvAmyOMThrowFling    = CreateConVar("amyom_throw_fling", "550", "Amy OM v105: velocidad (u/s) del IMPULSO DIRECCIONAL GMod a comunes golpeados por el martillo lanzado (desde abajo = hacia arriba; desde arriba = hacia abajo; en el suelo = dirección contraria + elevación). La receta del barrido de la bola: el ragdoll de muerte hereda la velocidad", _, true, 0.0, true, 3000.0);
    g_cvAmyOMThrowSpin     = CreateConVar("amyom_throw_spin", "700", "Amy OM v105: velocidad angular (deg/s) del TUMBLE REAL del martillo en vuelo (cartwheel alrededor del eje derecho del rumbo + wobble random — como el coche que gira cuando lo pega el tank). Directo al IPhysicsObject (SDKCall del motor v6.33)", _, true, 0.0, true, 3000.0);

    // v107: BOOMERANG HAMMER + AUTOS + CONTRA VERTICAL (pedido del owner
    // 2026-10-13: "se le cambiara por otro tipo de lanzamiento llamado
    // boomerang hammer... tiene que dar giros como un bumeran, llegar
    // hasta cierta distancia y regresar... el impacto del martillo podrá
    // mover objetos (autos y demas, como hace el aura del impacto de
    // defensa)... el golpe pueda impulsar verticalmente hacia arriba,
    // o sea pueda ser controlado")
    g_cvAmyOMBoomMode      = CreateConVar("amyom_boom_mode", "1", "Amy OM v108: DEFAULT de fábrica del modo del martillo (1 = BOOMERANG, 0 = tiro recto clasico). EN PARTIDA el modo se cambia POR JUGADOR con la B (sm_sjs_ability4): ese toggle es la preferencia real; este convar solo decide como arranca cada Amy. El buff de autos aplica en AMBOS modos", _, true, 0.0, true, 1.0);
    g_cvAmyOMBoomDist      = CreateConVar("amyom_boom_dist", "2325", "Amy OM v108: distancia máxima de IDA del bumeran (unidades) — SUBIDA +55% de fábrica (1500 -> 2325, pedido del owner). Al llegar (o chocar de frente una pared) da la vuelta y vuelve. OJO: si tu Sonic_Suite.cfg ya guardo el 1500 viejo, cámbialo a mano a 2325 (o borra la línea)", _, true, 200.0, true, 6000.0);
    g_cvAmyOMBoomSpin      = CreateConVar("amyom_boom_spin", "720", "Amy OM v108: GIRO PLANO del bumeran en vuelo (deg/s alrededor del eje vertical — como un bumeran de verdad). v108: la ida gira por TeleportEntity (la receta del retorno que SI se ve); el retorno del GMod sigue girando a 720", _, true, 0.0, true, 3000.0);
    g_cvAmyOMThrowCars     = CreateConVar("amyom_throw_cars", "1", "Amy OM v107: el impacto del martillo lanzado MUEVE OBJETOS con física (autos y demas) con la receta del aura de defensa (golpe real por masa + env_physexplosion); 0 = desactivado", _, true, 0.0, true, 1.0);
    g_cvAmyOMCarStunSp     = CreateConVar("amyom_car_stun_special", "4.0", "Amy OM v107: segundos de RAGDOLL que sufre un especial rozado por un auto en movimiento golpeado por el martillo", _, true, 0.5, true, 10.0);
    g_cvAmyOMCarStunTank   = CreateConVar("amyom_car_stun_tank", "3.0", "Amy OM v107: segundos de RAGDOLL del TANK rozado por un auto en movimiento (menos que un especial: es el tank)", _, true, 0.5, true, 10.0);
    g_cvAmyOMCarWatch      = CreateConVar("amyom_car_watch", "6.0", "Amy OM v107: ventana (s) en la que un auto golpeado por el martillo puede aturdir a un especial que roce mientras se mueve; 1 vez por auto por lanzamiento", _, true, 1.0, true, 20.0);
    g_cvAmyOMCounterLaunch = CreateConVar("amyom_counter_launch", "1", "Amy OM v107: la CONTRA de la defensa (Z) LANZA a la victima con ragdoll volador (pedido: el golpe pueda impulsar verticalmente hacia arriba); 0 = el congelado quieto de siempre", _, true, 0.0, true, 1.0);
    g_cvAmyOMCounterFling  = CreateConVar("amyom_counter_fling", "600", "Amy OM v107: velocidad (u/s) del lanzamiento de la CONTRA (mayormente vertical con empujon de separación; 300 = suave, 900 = fuera del mapa)", _, true, 0.0, true, 2000.0);

    // comandos directos (además de las ranuras del manager)
    RegConsoleCmd("sm_amycartas",  Amy_OM_CmdTarot,  "Amy OM v92: robar CARTAS DEL TAROT (ranura X)");
    RegConsoleCmd("sm_amythrow",    Amy_OM_CmdThrow, "Amy OM v92: LANZAMIENTO DE MARTILLO (ranura V = habilidad 3)");
    // v108: las CARTAS DEL SUPER TANK pierden la tecla B (la B ahora
    // alterna bumeran/común) — viven AQUÍ en consola, intactas
    RegConsoleCmd("sm_amysupertank", Command_RandomPower, "Amy OM v108: CARTAS DEL SUPER TANK (antes en la B; la B ahora alterna el modo del martillo)");

    // FSM 10 Hz: lógica de fases SIEMPRE + montaje/reparación del avatar
    if (g_hAmyOMAvatarTimer != INVALID_HANDLE) KillTimer(g_hAmyOMAvatarTimer);
    g_hAmyOMAvatarTimer = CreateTimer(0.1, T_AmyOMAvatarThink, _, TIMER_REPEAT);

    // v92: muerte en hook PROPIO player_death POST (paridad sonic v6.2 /
    // Tails v5.20): el PRE del manager corre ANTES de que el motor
    // procese la muerte y el restore del cuerpo dejaría ver el corpse
    // del survivor. En POST: ragdoll amy.mdl + ventana anti-ragdoll.
    HookEvent("player_death", Amy_OM_Event_PlayerDeath, EventHookMode_Post);

    for (int i = 1; i <= MaxClients; i++)
    {
        g_iAmyOMAvatar[i] = 0;
        g_iAmyOMAvatarL[i] = 0;
        g_iAmyOMAnimState[i] = -1;
        g_iAmyOMBodyRender[i] = -1;
        g_iAmyTarotCard1[i] = -1;
        g_iAmyTarotCard2[i] = -1;
        g_hAmyOMHammerFly[i] = null;
    }
}

// ============================================================
//  v92 - MAPA: resolución de modelos (doble intento MAYUS/MINUS,
//  patron case-sensitive Linux) + precache de sonidos OM
// ============================================================
public void Amy_OM_OnMapStart()
{
    // amy.mdl: probar el caso EXACTO del Lua de GMod y luego minusculas
    g_bAmyOMModelOK = false;
    if (PrecacheModel(AMY_OM_MODEL, true))
    {
        g_bAmyOMModelOK = true;
        strcopy(g_sAmyOMModel, sizeof(g_sAmyOMModel), AMY_OM_MODEL);
    }
    else if (PrecacheModel(AMY_OM_MODEL_ALT, true))
    {
        g_bAmyOMModelOK = true;
        strcopy(g_sAmyOMModel, sizeof(g_sAmyOMModel), AMY_OM_MODEL_ALT);
    }

    // hammer.mdl: idem + fallback al frasco de bilis (receta ORBS,
    // física ya probada en este server) si el VPK no lo trae
    g_bAmyOMHammerOK = false;
    g_bAmyOMHammerWarned = false;
    if (PrecacheModel(AMY_OM_HAMMER, true))
    {
        g_bAmyOMHammerOK = true;
        strcopy(g_sAmyOMHammerMdl, sizeof(g_sAmyOMHammerMdl), AMY_OM_HAMMER);
    }
    else if (PrecacheModel(AMY_OM_HAMMER_ALT, true))
    {
        g_bAmyOMHammerOK = true;
        strcopy(g_sAmyOMHammerMdl, sizeof(g_sAmyOMHammerMdl), AMY_OM_HAMMER_ALT);
    }
    else
    {
        strcopy(g_sAmyOMHammerMdl, sizeof(g_sAmyOMHammerMdl), AMY_OM_HAMMER_FALLBACK);
        PrecacheModel(AMY_OM_HAMMER_FALLBACK, true);
    }

    // sonidos OM (si el VPK no los trae, EmitSound no hace nada: cero
    // riesgo, mismo criterio que sonic.inc v6.0)
    PrecacheSound(AMY_OM_SND_READY, true);
    PrecacheSound(AMY_OM_SND_HIT, true);
    PrecacheSound(AMY_OM_SND_MISS, true);
    PrecacheSound(AMY_OM_SND_THROW_READY, true);
    PrecacheSound(AMY_OM_SND_THROW, true);
    PrecacheSound(AMY_OM_SND_THROW_HIT, true);
    PrecacheSound(AMY_OM_SND_THROW_CANCEL, true);
    PrecacheSound(AMY_OM_SND_RETRACT, true);
    PrecacheSound(AMY_OM_SND_CARD_PICK, true);
    PrecacheSound(AMY_OM_SND_CARD_UP, true);
    PrecacheSound(AMY_OM_SND_CARD_GOOD, true);
    PrecacheSound(AMY_OM_SND_CARD_NORM, true);
    PrecacheSound(AMY_OM_SND_CARD_MOON, true);

    // las anims se resuelven de nuevo (el LookupSequence necesita una
    // entidad viva del modelo: se hace al nacer el primer avatar)
    g_bAmyOMAnimsResolved = false;
    for (int s = 0; s < AMY_OM_ANIM_COUNT; s++) g_bAmyOMAnimSeqOK[s] = false;

    for (int i = 1; i <= MaxClients; i++)
    {
        g_iAmyOMAvatar[i] = 0;
        g_iAmyOMAvatarL[i] = 0;
        g_iAmyOMAnimState[i] = -1;
        g_iAmyOMHammerProp[i] = 0;
        g_iAmyOMHammerTrail[i] = 0;
        g_bAmyOMHammerReturning[i] = false;
        g_hAmyOMHammerFly[i] = null;
        g_fAmyOMDeathHideUntil[i] = 0.0;
        g_bAmyOMHammerBoom[i] = false;      // v107: estado bumeran
        g_iAmyOMHammerSlowN[i] = 0;
    }
}

public void Amy_OM_OnMapEnd()
{
    // el timer de la FSM es del plugin (sin NO_MAPCHANGE): sigue vivo.
    // Los props/trails/avatares mueren con el mapa: refs a cero y ya.
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iAmyOMAvatar[i] = 0;
        g_iAmyOMAvatarL[i] = 0;
        g_iAmyOMAnimState[i] = -1;
        g_iAmyOMHammerProp[i] = 0;
        g_iAmyOMHammerTrail[i] = 0;
        g_bAmyOMHammerReturning[i] = false;
        g_hAmyOMHammerFly[i] = null;
        g_fAmyOMCounterUntil[i] = 0.0;
        g_bAmyOMThrowArmed[i] = false;
        g_bAmyOMNoHammer[i] = false;
        g_bAmyOMHammerBoom[i] = false;      // v107
        g_iAmyOMHammerSlowN[i] = 0;
    }

    // v107: los autos armados y su vigilia mueren con el mapa
    for (int i = 0; i < AMY_OM_CARS_MAX; i++)
    {
        g_iAmyOMCarRef[i] = 0;
        g_bAmyOMCarDone[i] = false;
    }
    g_hAmyOMCarWatch = null;   // NO_MAPCHANGE: SM lo mató con el mapa
}

// ============================================================
//  v92 - RESOLUCION DE SECUENCIAS del amy.mdl. SourcePawn no trae
// LookupSequence: el probe es el truco clasico — disparar el input
// SetAnimation(nombre) y leer m_nSequence: si el índice CAMBIO, el
// nombre resolvio a una secuencia distinta (existe); si no cambio, el
// input fue rechazado (o es un alias de la misma secuencia: visualmente
// identico, el fallback lo cubre). Se resuelve UNA vez por mapa, al
// nacer el primer avatar (todo dentro del mismo frame: el cliente solo
// ve el resultado final, y CreateAvatar re-pone el idle al acabar).
// ============================================================
void Amy_OM_ResolveTry(int av, int state, const char[] name)
{
    if (g_bAmyOMAnimSeqOK[state]) return;
    if (!HasEntProp(av, Prop_Send, "m_nSequence")) return;

    int before = GetEntProp(av, Prop_Send, "m_nSequence");
    SetVariantString(name);
    AcceptEntityInput(av, "SetAnimation");
    int after = GetEntProp(av, Prop_Send, "m_nSequence");

    if (after != before)
    {
        strcopy(g_sAmyOMAnimSeq[state], sizeof(g_sAmyOMAnimSeq[]), name);
        g_bAmyOMAnimSeqOK[state] = true;
    }
}

void Amy_OM_ResolveAnims(int av)
{
    if (g_bAmyOMAnimsResolved) return;
    g_bAmyOMAnimsResolved = true;

    Amy_OM_ResolveTry(av, AMY_OM_ST_IDLE,     "idle");
    Amy_OM_ResolveTry(av, AMY_OM_ST_WALK,     "walk");
    Amy_OM_ResolveTry(av, AMY_OM_ST_RUN,      "run");
    Amy_OM_ResolveTry(av, AMY_OM_ST_JUMP,     "jump");            // v94: SIN martillo (el jump2 del Lua)
    Amy_OM_ResolveTry(av, AMY_OM_ST_FALL,     "fall");            // v94: SIN martillo (el fall normal)
    Amy_OM_ResolveTry(av, AMY_OM_ST_JUMPH,    "HammerJump");      // v94: CON martillo (Lua L1636)
    Amy_OM_ResolveTry(av, AMY_OM_ST_FALLH,    "FallAnimHammer");  // v94: CON martillo (Lua L222)
    Amy_OM_ResolveTry(av, AMY_OM_ST_DOWNIDLE, "DownedIdle");
    Amy_OM_ResolveTry(av, AMY_OM_ST_DOWNWALK, "DownedWalk");
    Amy_OM_ResolveTry(av, AMY_OM_ST_ATKIDLE,  "idleattack");
    Amy_OM_ResolveTry(av, AMY_OM_ST_ATKWALK,  "walkattack");
    Amy_OM_ResolveTry(av, AMY_OM_ST_ATKRUN,   "runattack");
    Amy_OM_ResolveTry(av, AMY_OM_ST_THRIDLE,  "idlethrow");
    Amy_OM_ResolveTry(av, AMY_OM_ST_THRWALK,  "walkthrow");
    Amy_OM_ResolveTry(av, AMY_OM_ST_THRRUN,   "runthrow");
    // v93: nombres EXACTOS del Lua (noodles_om_pills_survivors_amy.lua
    // L230/242/254) — la v92-OM ponía walkaxeless/runaxeless SIN guion
    // bajo y esas secuencias NO existen en el amy.mdl (T-pose al
    // caminar/correr sin martillo)
    Amy_OM_ResolveTry(av, AMY_OM_ST_AXEIDLE,  "idleaxeless");
    Amy_OM_ResolveTry(av, AMY_OM_ST_AXEWALK,  "walk_axeless");
    Amy_OM_ResolveTry(av, AMY_OM_ST_AXERUN,   "run_axeless");
    Amy_OM_ResolveTry(av, AMY_OM_ST_LOWIDLE,  "idle_lowhealth");
    Amy_OM_ResolveTry(av, AMY_OM_ST_LOWWALK,  "walk_lowhealth");
    Amy_OM_ResolveTry(av, AMY_OM_ST_LOWRUN,   "run_lowhealth");
    Amy_OM_ResolveTry(av, AMY_OM_ST_SWING,    "swing");
    Amy_OM_ResolveTry(av, AMY_OM_ST_THROW,    "throw");
    // 2a pasada del idle: si el default del modelo YA era idle, la
    // primera prueba no movió el índice — ahora el actual es otro
    // (el último probe) y si "idle" existe, se registra
    Amy_OM_ResolveTry(av, AMY_OM_ST_IDLE,     "idle");

    // fallbacks de las variantes que el modelo no traiga: las anims
    // BASE cubren el hueco (idleaxeless sin martillo -> idle normal,
    // lowhealth -> normal, axewalk/axerun -> walk/run)
    // v95: -1 = "sin fallback". Antes el sentinel era 0, que ES el
    // valor de AMY_OM_ST_IDLE: el fallback ATKIDLE->IDLE quedaba
    // anulado (si "idleattack" faltara en el modelo, la ventana de
    // defensa no recaia en el idle como prometia la tabla)
    int fallbacks[AMY_OM_ANIM_COUNT];
    for (int fb = 0; fb < AMY_OM_ANIM_COUNT; fb++) fallbacks[fb] = -1;
    fallbacks[AMY_OM_ST_ATKIDLE]  = AMY_OM_ST_IDLE;
    fallbacks[AMY_OM_ST_ATKWALK]  = AMY_OM_ST_WALK;
    fallbacks[AMY_OM_ST_ATKRUN]   = AMY_OM_ST_RUN;
    // v93: el comentario de la v92 prometia axewalk/axerun -> walk/run
    // pero faltaban en la tabla — si el modelo no trae la seq, la BASE
    // cubre el hueco (nunca T-pose)
    fallbacks[AMY_OM_ST_AXEWALK]  = AMY_OM_ST_WALK;
    fallbacks[AMY_OM_ST_AXERUN]   = AMY_OM_ST_RUN;
    // v94: si el modelo no trajera las variantes CON martillo del aire,
    // el jump/fall base cubre el hueco
    fallbacks[AMY_OM_ST_JUMPH]    = AMY_OM_ST_JUMP;
    fallbacks[AMY_OM_ST_FALLH]    = AMY_OM_ST_FALL;
    fallbacks[AMY_OM_ST_THRWALK]  = AMY_OM_ST_WALK;
    fallbacks[AMY_OM_ST_THRRUN]   = AMY_OM_ST_RUN;
    fallbacks[AMY_OM_ST_LOWWALK]  = AMY_OM_ST_WALK;
    fallbacks[AMY_OM_ST_LOWRUN]   = AMY_OM_ST_RUN;
    for (int s = 0; s < AMY_OM_ANIM_COUNT; s++)
    {
        // v95: sentinel -1 (antes == 0, que anulaba el ATKIDLE->IDLE)
        if (g_bAmyOMAnimSeqOK[s] || fallbacks[s] < 0) continue;
        if (g_bAmyOMAnimSeqOK[fallbacks[s]])
        {
            strcopy(g_sAmyOMAnimSeq[s], sizeof(g_sAmyOMAnimSeq[]), g_sAmyOMAnimSeq[fallbacks[s]]);
            g_bAmyOMAnimSeqOK[s] = true;
        }
    }
}

// velocidad 2D del cliente (helper local — sonic tiene la suya)
float Amy_OM_Speed2D(int client)
{
    float v[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", v);
    return SquareRoot(v[0] * v[0] + v[1] * v[1]);
}

// ============================================================
//  v92 - AVATAR ESPEJO (patron sonic.inc v6.x completo)
// ============================================================

// EF_NOINTERP al nacer (el avatar aparece ENCAJADO, sin lerp desde
// el origen del mapa — receta sonic/Tails)
void Amy_OM_SetAvatarNoInterp(int av, bool on)
{
    if (av <= MaxClients || !IsValidEntity(av)) return;
    if (!HasEntProp(av, Prop_Send, "m_fEffects")) return;
    int fx = GetEntProp(av, Prop_Send, "m_fEffects");
    if (on)  fx |= AMY_OM_EF_NOINTERP;
    else     fx &= ~AMY_OM_EF_NOINTERP;
    SetEntProp(av, Prop_Send, "m_fEffects", fx);
}

// v93-OM — BODYGROUP "Chains" (el pedido del owner: "si lo haces
// invisible durante el tiempo que no tiene martillo lo habremos
// logrado"). El amy.mdl trae el martillo COMO PARTE DEL MODELO
// (submodelo "hammer") y el Lua del OM lo quita/pone con el bodygroup
// 1 "Chains" en cada lanzamiento y recuperación:
//     lanzar    -> GetPuppet():SetBodygroup(1,1)   (L1523-1524)
//     recuperar -> GetPuppet():SetBodygroup(1,0)   (L1354/1375/1596-97)
// SourcePawn no trae SetBodygroup nativo: en este modelo el grupo 0
// ("body") ocupa 0 bits, así que "Chains" vive en el bit 0 de m_nBody
// (lo confirmo el owner en el panel del GMod: chains 1 = sin martillo,
// chains 0 = con martillo). Se aplica a LAS DOS copias del avatar
// (la R que ve el resto del server y la L que ve la duna).
void Amy_OM_AvatarChains(int client, bool sinMartillo)
{
    for (int copia = 0; copia < 2; copia++)
    {
        int ref = (copia == 0) ? g_iAmyOMAvatar[client] : g_iAmyOMAvatarL[client];
        if (ref == 0) continue;
        int av = EntRefToEntIndex(ref);
        if (av <= MaxClients || !IsValidEntity(av)) continue;
        if (!HasEntProp(av, Prop_Send, "m_nBody")) continue;

        int body = GetEntProp(av, Prop_Send, "m_nBody");
        int nuevo = sinMartillo ? (body | 1) : (body & ~1);
        if (nuevo != body)
            SetEntProp(av, Prop_Send, "m_nBody", nuevo);
    }
}

int Amy_OM_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
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
    g_fAmyOMBodyYaw[client]  = ang[1];
    g_fAmyOMYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fAmyOMBodyYaw[client], loc);

    if (!tpMode)
    {
        // parentado (modo Tails default v5.6: el motor mueve la posición,
        // cero delay de red, anims suaves; aquí solo se escriben angulos)
        SetVariantString("!activator");
        AcceptEntityInput(av, "SetParent", client);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", loc);
    }
    // v98-OM tpMode (la copia R con tails_avatar_tp): nace SIN parent y
    // SIN EF_NOINTERP — ya quedó en pose MUNDO por el TeleportEntity de
    // arriba; el follow la mueve por tick y los demas la interpolan

    for (int k = 0; k < 3; k++)
    {
        g_fAmyOMSmLoc[client][k]  = loc[k];
        g_fAmyOMSmLocL[client][k] = loc[k];
    }
    g_bAmyOMSmSnap[client] = true;

    if (!tpMode)
        Amy_OM_SetAvatarNoInterp(av, true);
    return av;
}

// =====================================================================
// v103-OM (manager 3.77.40): ADOPCION EN EL MONTAJE — el reemplazo del
// barrido en caliente (orden del owner 2026-10-10: "tu barrido de
// avatares está haciendo reiniciar mi avatar a cada rato... BUSCA OTRA
// MANERA"). Esta FSM es la ÚNICA creadora de props con los nombres de
// abajo: un prop así que ELLA no rastrea es un huerfano por definición
// (lo fabrico una vida anterior, un montaje doble del pasado o una
// versión vieja del suite) y muere en el instante exacto del montaje.
// Un avatar rastreado es INTOCABLE: no existe ningún timer que lo mire.
// =====================================================================
bool Amy_OM_IsMyAvatarRef(int ref)
{
    // v3.77.40: el 0 es "sin avatar"; un ref NEGATIVO puede ser
    // perfectamente legitimo (bit alto del serial del handle).
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iAmyOMAvatar[i] == ref) return true;
        if (g_iAmyOMAvatarL[i] == ref) return true;
    }
    return false;
}

void Amy_OM_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "amy_avatar_om", "amy_avatar_om_l", "amyom_avatar" };
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
                if (Amy_OM_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
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
        PrintToServer("[Amy v104-OM] Adopción del montaje: %d huerfano(s) del avatar eliminado(s).", ng);
}

void Amy_OM_CreateAvatar(int client, bool pulsePause = true)
{
    if (!g_bAmyOMModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;

    // v98-OM: la copia R nace en modo TP si tails_avatar_tp (la que ven
    // los DEMAS viaja por teleport por tick + interpolación de red)
    // v103-OM (manager 3.77.40): REEMPLAZO LIMPIO — orden del owner
    // 2026-10-10: en caliente YA NO EXISTE barrido. Si este cliente ya
    // tenía un R o L vivo (montaje doble por orden raro de eventos),
    // muere AQUÍ enterito: jamás vuelve a quedar un prop sin dueño (la
    // fábrica de huerfanos del "= 0" sin Kill queda cerrada).
    {
        int oldR = EntRefToEntIndex(g_iAmyOMAvatar[client]);
        if (g_iAmyOMAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Amy_OM_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iAmyOMAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iAmyOMAvatarL[client]);
        if (g_iAmyOMAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Amy_OM_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iAmyOMAvatarL[client] = 0;
    }

    // v103-OM: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje, no en un
    // timer a ciegas.
    Amy_OM_KillGhostAvatarProps();

    int av = Amy_OM_CreateAvatarProp(client, g_sAmyOMModel, "amy_avatar_om", Tails_AvatarTPOn());
    if (av == 0) return;

    // resolver las secuencias del modelo (una vez por mapa)
    Amy_OM_ResolveAnims(av);

    SetVariantString(g_bAmyOMAnimSeqOK[AMY_OM_ST_IDLE] ? g_sAmyOMAnimSeq[AMY_OM_ST_IDLE] : "idle");
    AcceptEntityInput(av, "SetAnimation");
    g_iAmyOMAnimState[client] = AMY_OM_ST_IDLE;

    SDKHook(av, SDKHook_SetTransmit, Amy_OM_TransmitAvatarR);

    g_iAmyOMAvatarL[client] = 0;
    Amy_OM_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iAmyOMBodyRender[client] = view_as<int>(curMode);
    else if (g_iAmyOMBodyRender[client] == -1)
        g_iAmyOMBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    g_iAmyOMAvatar[client] = EntIndexToEntRef(av);

    // v93-OM: el avatar recien nacido hereda el estado del martillo
    // (si se remonta el avatar con el martillo volando, nace SIN el)
    Amy_OM_AvatarChains(client, g_bAmyOMNoHammer[client]);

    // per-tick: angulos locales (contra-rotación del parent)
    SDKHook(client, SDKHook_PostThink, Amy_OM_AvatarFollow);

    // pulso de pausa en cada montaje de ciclo de vida (misma infra
    // sv_pausable del suite; tails_pausefix manda — UN solo sistema)
    if (pulsePause)
        Tails_PauseFix_Trigger(client);
}

void Amy_OM_CreateAvatarL(int client)
{
    if (!g_bAmyOMModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iAmyOMAvatar[client] == 0) return;

    int av = Amy_OM_CreateAvatarProp(client, g_sAmyOMModel, "amy_avatar_om_l");
    if (av == 0) return;

    SetVariantString(g_bAmyOMAnimSeqOK[AMY_OM_ST_IDLE] ? g_sAmyOMAnimSeq[AMY_OM_ST_IDLE] : "idle");
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Amy_OM_TransmitAvatarL);

    g_iAmyOMAvatarL[client] = EntIndexToEntRef(av);

    // v93-OM: la copia L nace con el mismo estado del martillo que la R
    Amy_OM_AvatarChains(client, g_bAmyOMNoHammer[client]);
}

// transmit: la R la ve todo el mundo MENOS la duna (que tiene su L);
// la L SOLO la ve la duna (contra-rotada contra SUS eye angles).
public Action Amy_OM_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iAmyOMAvatar[i] != 0 && EntRefToEntIndex(g_iAmyOMAvatar[i]) == entity)
        {
            if (client == i && g_iAmyOMAvatarL[i] != 0
                && EntRefToEntIndex(g_iAmyOMAvatarL[i]) > 0)
                return Plugin_Handled;   // la duna tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

public Action Amy_OM_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iAmyOMAvatarL[i] != 0 && EntRefToEntIndex(g_iAmyOMAvatarL[i]) == entity)
        {
            if (client == i) return Plugin_Continue;   // la duna si
            return Plugin_Handled;                     // nadie más
        }
    }
    return Plugin_Continue;
}

void Amy_OM_KillAvatarL(int client)
{
    if (g_iAmyOMAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iAmyOMAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SDKUnhook(avL, SDKHook_SetTransmit, Amy_OM_TransmitAvatarL);
            AcceptEntityInput(avL, "Kill");
        }
    }
    g_iAmyOMAvatarL[client] = 0;
}

void Amy_OM_KillAvatarOnly(int client)
{
    if (g_iAmyOMAvatar[client] != 0)
    {
        int av = EntRefToEntIndex(g_iAmyOMAvatar[client]);
        if (av > 0 && IsValidEntity(av))
        {
            SDKUnhook(av, SDKHook_SetTransmit, Amy_OM_TransmitAvatarR);
            AcceptEntityInput(av, "Kill");
        }
    }
    g_iAmyOMAvatar[client] = 0;
    g_iAmyOMAnimState[client] = -1;
}

// mata el avatar y DEVUELVE el cuerpo del survivor (muerte/limpieza)
void Amy_OM_KillAvatar(int client)
{
    Amy_OM_KillAvatarOnly(client);
    Amy_OM_KillAvatarL(client);

    // devolver el render del cuerpo (si el jugador sigue conectado)
    if (IsClientInGame(client)
        && g_iAmyOMBodyRender[client] != -1
        && GetEntityRenderMode(client) == RENDER_NONE)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iAmyOMBodyRender[client]));
    }
    g_iAmyOMBodyRender[client] = -1;
    SDKUnhook(client, SDKHook_PostThink, Amy_OM_AvatarFollow);
}

// FOLLOW PER-TICK (yaw 3 reglas + contra-rotación amortiguada + copia
// L contra los eye angles de la duna — receta sonic/Tails)
public void Amy_OM_AvatarFollow(int client)
{
    if (g_iAmyOMAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Amy_OM_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    // ---- yaw objetivo: dirección REAL del movimiento ----
    float yawObj = g_fAmyOMBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fAmyOMBodyYaw[client];   // deadband 3 grados
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    // ---- giro suave hacia el objetivo (~900 grados/s) ----
    float now = GetEngineTime();
    float dt  = now - g_fAmyOMYawLastT[client];
    g_fAmyOMYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fAmyOMBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fAmyOMBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bAmyOMSmSnap[client];
    GetClientAbsAngles(client, par);

    // ---- copia R (todos) ----
    int av = EntRefToEntIndex(g_iAmyOMAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        if (Tails_AvatarTPOn())
        {
            // v98-OM: LA COPIA R VIAJA POR TP (receta tails_follow de
            // Tails v5.25): TeleportEntity por tick en pose mundo (pos
            // + yaw del cuerpo) + reloj vivo, SIN EF_NOINTERP -> los
            // clientes de los demas la INTERPOLAN = suave sin depender
            // de la pausa (que solo re-encaja la vista del dueño). El
            // dueño no la recibe (TransmitAvatarR se la filtra).
            float posTP[3], angTP[3];
            GetClientAbsOrigin(client, posTP);
            angTP[0] = 0.0;                      // pitch NUNCA
            angTP[1] = g_fAmyOMBodyYaw[client];
            angTP[2] = 0.0;                      // roll NUNCA
            TeleportEntity(av, posTP, angTP, NULL_VECTOR);
            Tails_MarkInterp(av);
        }
        else
        {
        Tails_AvatarLocalAngles(par[0], par[1], g_fAmyOMBodyYaw[client], loc);
        loc[1] = Tails_UnwrapYaw(g_fAmyOMSmLoc[client][1], loc[1]);
        Tails_ExpDamp(loc, g_fAmyOMSmLoc[client], 0.05, dt, snap);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", g_fAmyOMSmLoc[client]);
        Tails_MarkInterp(av);
        }
    }

    // ---- copia L: contra-rotada contra los EYE de la duna ----
    if (g_iAmyOMAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iAmyOMAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3], locL[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], g_fAmyOMBodyYaw[client], locL);
            locL[1] = Tails_UnwrapYaw(g_fAmyOMSmLocL[client][1], locL[1]);
            Tails_ExpDamp(locL, g_fAmyOMSmLocL[client], 0.05, dt, snap);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fAmyOMSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
    g_bAmyOMSmSnap[client] = false;
}

// pone una anim en R+L (re-armando el variant: es de UN SOLO USO)
void Amy_OM_SetAnim(int client, int state)
{
    if (!g_bAmyOMAnimSeqOK[state]) return;
    int av = EntRefToEntIndex(g_iAmyOMAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        SetVariantString(g_sAmyOMAnimSeq[state]);
        AcceptEntityInput(av, "SetAnimation");
    }
    if (g_iAmyOMAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iAmyOMAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetVariantString(g_sAmyOMAnimSeq[state]);
            AcceptEntityInput(avL, "SetAnimation");
        }
    }
    g_iAmyOMAnimState[client] = state;
}

// gesto one-shot (swing de la contra / throw del lanzamiento): fija
// la FSM por su duración, como el Dodge de sonic
void Amy_OM_PlayGesture(int client, int state, float lockTime)
{
    if (!g_bAmyOMAnimSeqOK[state]) return;
    Amy_OM_SetAnim(client, state);
    g_fAmyOMAnimLock[client] = GetEngineTime() + lockTime;
}

// playback rate en R+L
void Amy_OM_SetRate(int client, float rate)
{
    if (rate < 0.05) rate = 0.05;
    int av = EntRefToEntIndex(g_iAmyOMAvatar[client]);
    if (av > 0 && IsValidEntity(av) && HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iAmyOMAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iAmyOMAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL) && HasEntProp(avL, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avL, Prop_Data, "m_flPlaybackRate", rate);
    }
}

// FSM DE ANIMACION (prioridades ShouldAlternate del GMod amy.lua)
void Amy_OM_AvatarUpdate(int client, float now)
{
    if (now < g_fAmyOMAnimLock[client]) return;   // gesto one-shot en curso

    int state = AMY_OM_ST_IDLE;
    float rate = 1.0;
    float s = Amy_OM_Speed2D(client);

    bool incap = GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0;
    bool lowhp = GetClientHealth(client) <= 60;   // GMod: LowestHealthCount <= 60

    if (incap)
    {
        state = (s > 20.0) ? AMY_OM_ST_DOWNWALK : AMY_OM_ST_DOWNIDLE;
    }
    // v95: EL AIRE ES UN ESTADO BASE del framework pills (base L775-
    // 794: IsOnGround -> crouch/walk/run/idle; en el aire -> glide =
    // "fall") y los alternates (idlethrow/idleattack/axeless/
    // lowhealth) solo sustituyen DENTRO de idle/walk/run — el Lua de
    // Amy además dispara el salto aunque el throw este armado
    // (L1631-1641). Desde la v92-OM esta rama VIVÍA DEBAJO de las de
    // throw armado / ventana de defensa / sin martillo: al saltar o
    // caer en cualquiera de esos estados el jump/fall quedaba
    // ENMASCARADO y no se reproducia (reporte del owner tras probar
    // la v94: "el jump y fall no se reproducen"). Ahora el aire va
    // primero, como en GMod.
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // v94: las variantes dependen del martillo — pedido del owner
        // con el Lua en la mano (L1631-1640 y L221-224): SIN martillo
        // los normales (el PillAnim('jump2') del Lua = seq "jump" y
        // el "fall" pelado); CON martillo HammerJump y FallAnimHammer
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[2] > 40.0)
        {
            state = g_bAmyOMNoHammer[client] ? AMY_OM_ST_JUMP : AMY_OM_ST_JUMPH;
            if (state != g_iAmyOMAnimState[client]) g_fAmyOMJumpStart[client] = now;
        }
        else
        {
            // ventana del jump completa en el aire (fix Poppy)
            bool jumpLive = false;
            if (g_iAmyOMAnimState[client] == AMY_OM_ST_JUMP
                || g_iAmyOMAnimState[client] == AMY_OM_ST_JUMPH)
            {
                float jt = now - g_fAmyOMJumpStart[client];
                if (jt < 0.5) jumpLive = true;
            }
            if (jumpLive)
                state = g_bAmyOMNoHammer[client] ? AMY_OM_ST_JUMP : AMY_OM_ST_JUMPH;
            else
                state = g_bAmyOMNoHammer[client] ? AMY_OM_ST_FALL : AMY_OM_ST_FALLH;
        }
    }
    // v95: los tres alternates de abajo son SOLO-EN-SUELO en GMod
    // (ShouldAlternate sustituye idle/walk/run, nunca el aire)
    // el LANZAMIENTO ARMADO (GMod idlethrow/walkthrow)
    else if (g_bAmyOMThrowArmed[client])
    {
        if (s < 40.0)       state = AMY_OM_ST_THRIDLE;
        else if (s < 150.0) state = AMY_OM_ST_THRWALK;
        else                state = AMY_OM_ST_THRRUN;
        // v96: mismas curvas de rate del walk/run normal (antes el
        // 1.8*(s/85) también en run = runthrow a 3.6x)
        if (s >= 150.0) rate = 1.15 * (s / 400.0);
        else if (s >= 40.0) rate = 1.8 * (s / 85.0);
    }
    // la VENTANA DE DEFENSA (GMod HammerDuration -> idleattack etc.)
    else if (g_fAmyOMCounterUntil[client] > now)
    {
        if (s < 40.0)       state = AMY_OM_ST_ATKIDLE;
        else if (s < 150.0) state = AMY_OM_ST_ATKWALK;
        else                state = AMY_OM_ST_ATKRUN;
        // v96 (owner): "la velocidad de animación de la pose de defensa
        // está mal, es demasiado rápida, no es la misma del run normal
        // (con el walk no sucede esto)" — el runattack corria con la
        // curva del walk (1.8*(s/85) => 3.6x en run). Mismas curvas del
        // walk/run normal ahora (el walk ya cuadraba).
        if (s >= 150.0) rate = 1.15 * (s / 400.0);
        else if (s >= 40.0) rate = 1.8 * (s / 85.0);
    }
    // SIN MARTILLO (GMod HasNoHammer -> idleaxeless)
    else if (g_bAmyOMNoHammer[client])
    {
        if (s < 40.0)       state = AMY_OM_ST_AXEIDLE;
        else if (s < 150.0) state = AMY_OM_ST_AXEWALK;
        else                state = AMY_OM_ST_AXERUN;
        if (s >= 150.0) rate = 1.15 * (s / 400.0);
        else if (s >= 40.0) rate = 1.8 * (s / 85.0);
    }
    else if (lowhp)
    {
        if (s < 40.0)       state = AMY_OM_ST_LOWIDLE;
        else if (s < 150.0) state = AMY_OM_ST_LOWWALK;
        else                state = AMY_OM_ST_LOWRUN;
        if (s >= 150.0) rate = 1.15 * (s / 400.0);
        else if (s >= 40.0) rate = 1.8 * (s / 85.0);
    }
    else
    {
        if (s < 40.0)
            state = AMY_OM_ST_IDLE;
        else if (s < 150.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = AMY_OM_ST_WALK;
            rate = 1.8 * (s / 85.0);
            if (rate > 2.5) rate = 2.5;
        }
        else
        {
            state = AMY_OM_ST_RUN;
            rate = 1.15 * (s / 400.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6) rate = 3.6;
        }
    }

    if (rate > 3.6) rate = 3.6;

    if (state != g_iAmyOMAnimState[client])
        Amy_OM_SetAnim(client, state);

    Amy_OM_SetRate(client, rate);
}

// FSM 10 HZ: lógica de fases SIEMPRE (ventana/contra/retorno no
// dependen del visual) + montaje/auto-reparación del avatar
public Action T_AmyOMAvatarThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Amy_OM_KillAvatar(i); continue; }

        bool esAmyViva = (g_iPlayerCharIdx[i] == AMY_INDEX
                          && IsPlayerAlive(i) && GetClientTeam(i) == 2);

        // ---- LÓGICA DE FASES: corre SIEMPRE que sea Amy viva ----
        if (esAmyViva)
            Amy_OM_PhaseThink(i, now);

        // ---- AVATAR: montaje / auto-reparación ----
        if (g_iAmyOMAvatar[i] == 0)
        {
            if (esAmyViva && g_cvAmyOMAvatar.BoolValue && g_bAmyOMModelOK)
                Amy_OM_CreateAvatar(i);
            continue;
        }

        // quitar avatar si dejó de ser una Amy survivor viva
        if (!esAmyViva)
        {
            Amy_OM_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iAmyOMAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iAmyOMAvatar[i] = 0;
            g_iAmyOMAnimState[i] = -1;
            continue;
        }

        // reafirmar el RENDER_NONE del cuerpo (el motor lo resetea al
        // cambiar de capítulo/incap/rescue: fix Tails v5.4)
        if (g_iAmyOMBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparación de la copia L (montaje tardio: pulso también)
        if (g_iAmyOMAvatarL[i] == 0 && g_iAmyOMAvatar[i] != 0)
        {
            Amy_OM_CreateAvatarL(i);
            if (g_iAmyOMAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // ---- FSM de animación ----
        av = EntRefToEntIndex(g_iAmyOMAvatar[i]);
        if (g_iAmyOMAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Amy_OM_AvatarUpdate(i, now);
    }
    return Plugin_Continue;
}

// RAGDOLL DE MUERTE: prop_ragdoll con amy.mdl (usa el .phy del
// modelo) + limpieza a los 15s (receta Tails/Sonic exacta)
void Amy_OM_SpawnDeathRagdoll(int client, bool sinMartillo = false)
{
    if (!g_bAmyOMModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", g_sAmyOMModel);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    // v93-OM: si murió con el martillo volando, el cuerpo la muestra
    // SIN el (chains bit 0 — mismo toggle del avatar)
    if (sinMartillo && HasEntProp(rag, Prop_Send, "m_nBody"))
        SetEntProp(rag, Prop_Send, "m_nBody", 1);

    CreateTimer(15.0, T_AmyOMRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_AmyOMRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// MUERTE REAL (hook player_death POST propio — paridad sonic v6.2)
public void Amy_OM_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return;

    // v93-OM: capturar ANTES el estado del martillo (CancelStates lo
    // resetea con HammerKill) — el ragdoll debe respetar como murió:
    // si el martillo estaba volando, el cuerpo nace SIN el (chains)
    bool sinMartillo = g_bAmyOMNoHammer[client];

    // cortar todo lo vivo de la Amy OM
    Amy_OM_CancelStates(client);

    // el avatar muere con ella: ragdoll amy.mdl en la posición de
    // muerte + ventana anti-ragdoll para el cuerpo del survivor que
    // el mod de ragdolls del owner revive (patron Tails v5.20)
    GetClientAbsOrigin(client, g_fAmyOMDeathOrigin[client]);
    g_fAmyOMDeathHideUntil[client] = GetEngineTime() + 2.0;
    Amy_OM_SpawnDeathRagdoll(client, sinMartillo);
    Amy_OM_KillAvatar(client);
}

// filtro anti-ragdoll del survivor (ventana 2s tras la muerte de una
// Amy con avatar). Lo enruta el OnEntityCreated central de Rouge.inc
// (Rogue se incluye DESPUÉS de Amy).
void Amy_OM_OnEntityCreated(int entity, const char[] classname)
{
    if (StrEqual(classname, "prop_ragdoll")
        || StrEqual(classname, "prop_physics")
        || StrEqual(classname, "prop_physics_override")
        || StrEqual(classname, "prop_dynamic")
        || StrEqual(classname, "prop_dynamic_override")
        || StrEqual(classname, "cs_ragdoll")
        || StrEqual(classname, "survivor_death_model"))
    {
        float now = GetEngineTime();
        for (int i = 1; i <= MaxClients; i++)
        {
            if (g_fAmyOMDeathHideUntil[i] == 0.0 || now >= g_fAmyOMDeathHideUntil[i])
                continue;
            // candidata: revisar modelo/origen en el próximo frame
            RequestFrame(Amy_OM_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }
}

public void Amy_OM_CheckDeathRagdoll(any ref)
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
        if (g_fAmyOMDeathHideUntil[i] == 0.0 || now >= g_fAmyOMDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_fAmyOMDeathOrigin[i]) < 200.0)
        {
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}

// LIMPIEZA pura para CAMBIO DE PERSONAJE / DISCONNECT (la invoca
// CleanupCharModuleState del manager, cuando el índice aún es AMY):
// corta habilidades, mata avatar/hammer y restaura el cuerpo — SIN
// ragdoll y SIN ventana anti-ragdoll (no hubo muerte).
public void Amy_OM_CleanupState(int client)
{
    if (!Amy_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != AMY_INDEX) return;

    Amy_OnPlayerDeath(client);      // la limpieza clasica (furia, momentum, timers)
    Amy_OM_CancelStates(client);    // ventana/armado/hammer OM
    Amy_OM_KillAvatar(client);      // avatar fuera + cuerpo visible de nuevo
}

// corta TODO el estado activo de la Amy OM (muerte/limpieza/aturdida)
void Amy_OM_CancelStates(int client)
{
    g_fAmyOMCounterUntil[client] = 0.0;
    g_bAmyOMCounterMissed[client] = false;
    g_bAmyOMThrowArmed[client] = false;
    g_fAmyOMArmedUntil[client] = 0.0;
    g_fAmyOMAnimLock[client] = 0.0;
    Amy_OM_HammerKill(client);
}

// ============================================================
//  v92 - CARTAS DEL TAROT (ranura X — el CARDSWAP del GMod)
//  6 cartas (orden y valores del om_survivors_register_noodles.lua):
//    0 Luna     : stun +0 | dmg x1.15|x0.85 (aleatorio por robo) |
//                vel +15%|-15% (aleatorio por robo) — la carta caotica
//    1 Sol      : stun +0 | dmg x1.00 | cura +1hp/1.6s radio 200 tope 75 (v109: 20% más rápido)
//    2 Emperador: stun +0 | dmg x0.85 | vel +15%
//    3 Fuerza   : stun +1 | dmg x1.15 | vel -20%
//    4 Mundo    : stun +0 | dmg x1.00 | cura +1hp/1.6s como el Sol (v109)
//    5 Loco     : stun -1 | dmg x1.00 | vel +10%
//  Ambas cartas activas a la vez (GMod: la UI solo las MUESTRA).
// ============================================================

// bonus de stun de las 2 cartas en mano (RetrieveCurrentAttack)
float Amy_OM_TarotStunBonus(int client)
{
    if (g_iAmyTarotCard1[client] < 0 && g_iAmyTarotCard2[client] < 0) return 0.0;
    float bonus = 0.0;
    if (g_iAmyTarotCard1[client] == 3) bonus += 1.0;
    if (g_iAmyTarotCard2[client] == 3) bonus += 1.0;
    if (g_iAmyTarotCard1[client] == 5) bonus -= 1.0;
    if (g_iAmyTarotCard2[client] == 5) bonus -= 1.0;
    return bonus;
}

// multiplicador de dano recibido (RetrieveDamageReduction; <1 = aguanta
// más, >1 = suena más — los valores del GMod al pie de la letra)
float Amy_OM_TarotDmgMult(int client)
{
    if (g_iAmyTarotCard1[client] < 0 && g_iAmyTarotCard2[client] < 0) return 1.0;
    float mult = 1.0;
    // Luna: el valor aleatorio del robo
    if (g_iAmyTarotCard1[client] == 0) mult *= g_fAmyTarotMoonDmg[client];
    if (g_iAmyTarotCard2[client] == 0) mult *= g_fAmyTarotMoonDmg[client];
    // Emperador 0.85 | Fuerza 1.15
    if (g_iAmyTarotCard1[client] == 2 || g_iAmyTarotCard2[client] == 2) mult *= 0.85;
    if (g_iAmyTarotCard1[client] == 3 || g_iAmyTarotCard2[client] == 3) mult *= 1.15;
    return mult;
}

// multiplicador de velocidad (OM_PILL_speedThink; conversión de los
// +-90/+-60/+40 del GMod sobre su run de 400 = ~+-22%/15%/10%)
float Amy_OM_TarotSpeedMult(int client)
{
    if (g_cvAmyOMTarotSpeed == null || !g_cvAmyOMTarotSpeed.BoolValue) return 1.0;
    if (g_iAmyTarotCard1[client] < 0 && g_iAmyTarotCard2[client] < 0) return 1.0;
    float mult = 1.0;
    // Luna: +15% o -15% (el aleatorio del robo)
    if (g_iAmyTarotCard1[client] == 0 || g_iAmyTarotCard2[client] == 0)
        mult *= (g_fAmyTarotMoonSpeed[client] >= 0.0) ? 1.15 : 0.85;
    // Emperador +15% | Fuerza -20% | Loco +10%
    if (g_iAmyTarotCard1[client] == 2 || g_iAmyTarotCard2[client] == 2) mult *= 1.15;
    if (g_iAmyTarotCard1[client] == 3 || g_iAmyTarotCard2[client] == 3) mult *= 0.80;
    if (g_iAmyTarotCard1[client] == 5 || g_iAmyTarotCard2[client] == 5) mult *= 1.10;
    if (mult < 0.50) mult = 0.50;
    return mult;
}

// roba las 2 cartas (CardSwitch_om del GMod: 2 distintas al azar +
// los valores de la Luna se re-ruedan en cada robo)
void Amy_OM_TarotDraw(int client, bool silent)
{
    int c1 = GetRandomInt(0, AMY_OM_TAROT_COUNT - 1);
    int c2 = GetRandomInt(0, AMY_OM_TAROT_COUNT - 1);
    while (c2 == c1)
        c2 = GetRandomInt(0, AMY_OM_TAROT_COUNT - 1);

    g_iAmyTarotCard1[client] = c1;
    g_iAmyTarotCard2[client] = c2;

    // Luna: re-roll de sus dos efectos (GMod: math.random(1,2))
    if (c1 == 0 || c2 == 0)
    {
        if (GetRandomInt(1, 2) == 1) { g_fAmyTarotMoonSpeed[client] = 1.0;  g_fAmyTarotMoonDmg[client] = 1.15; }
        else                         { g_fAmyTarotMoonSpeed[client] = -1.0; g_fAmyTarotMoonDmg[client] = 0.90; }   // v109: la reducción nerf un 5% (0.85 -> 0.90)
    }

    if (!silent)
    {
        EmitSoundToAll(AMY_OM_SND_CARD_PICK, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
        Amy_OM_TarotAnnounce(client);
    }
}

// v108: DESCRIPCION EXACTA DE CADA CARTA — pedido del owner: "las
// cartas no describen correctamente sus efectos o la reducción que
// da". Este builder arma el texto con los valores REALES que corre el
// código (nada de aproximaciones): la Luna muestra la TIRADA CONCRETA
// de este robo (su +/- se decide al robar), el Sol detalla cuánto
// cura/donde/hasta donde, y las demas dicen exactamente el stun
// (contra + lanzamiento), el dano RECIBIDO por Amy (no el que pega) y
// la velocidad. La usa el announce del robo y la X en cooldown.
void Amy_OM_TarotCardLine(int client, int card, char out[192])
{
    switch (card)
    {
        case 0:  // Luna — la caotica: su +/- se re-rueda en CADA robo
        {
            bool fast = (g_fAmyTarotMoonSpeed[client] >= 0.0);
            Format(out, 192,
                   "Luna: dano que recibes x%.2f | tu velocidad x%.2f (tirada de ESTE robo — cambia al robar de nuevo)",
                   g_fAmyTarotMoonDmg[client], fast ? 1.15 : 0.85);
        }
        case 1:  // Sol — cura pasiva de área (solo si amyom_tarot_heal 1)
        {
            bool healOn = (g_cvAmyOMTarotHeal != null && g_cvAmyOMTarotHeal.BoolValue);
            Format(out, 192,
                   "Sol: cura +1 HP cada 1.6s a los personajes del suite vivos en %.0fu (hasta %d HP)%s",
                   AMY_OM_HEAL_RADIUS, AMY_OM_HEAL_CAP, healOn ? "" : " [DESACTIVADA: amyom_tarot_heal 0]");
        }
        case 2:  // Emperador
        {
            Format(out, 192,
                   "Emperador: dano que recibes x0.85 (-15%%) | tu velocidad x1.15 (+15%%)");
        }
        case 3:  // Fuerza
        {
            Format(out, 192,
                   "Fuerza: stun de contra/lanzamiento +1s | dano que recibes x1.15 (+15%%) | tu velocidad x0.80 (-20%%)");
        }
        case 4:  // Mundo
        {
            Format(out, 192,
                   "Mundo: cura +1 HP cada 1.6s como el Sol (la que era la carta neutra — v109)");
        }
        case 5:  // Loco
        {
            Format(out, 192,
                   "Loco: stun de contra/lanzamiento -1s | tu velocidad x1.10 (+10%%)");
        }
        default:
        {
            Format(out, 192, "?");
        }
    }
}

// anuncia las 2 cartas con sus efectos (la "UI" de L4D2: chat + hint)
// v108: carta por carta con la descripción EXACTA (arriba) + el total
// real agregado, aclarando QUE el dano recibido es el que Amy PAGA
// (no lo que pega) y apuntando al cuadro de equipo (sm_defensas)
void Amy_OM_TarotAnnounce(int client)
{
    int c1 = g_iAmyTarotCard1[client];
    int c2 = g_iAmyTarotCard2[client];

    PrintCenterText(client, "CARTAS: %s + %s", g_sAmyTarotNames[c1], g_sAmyTarotNames[c2]);
    PrintToChat(client, "\x04[Amy]\x01 Cartas robadas: \x03%s\x01 + \x03%s\x01", g_sAmyTarotNames[c1], g_sAmyTarotNames[c2]);
    PrintHintText(client, "<font color='#%s' size='22'>%s</font> <font color='#FFFFFF'>+</font> <font color='#%s' size='22'>%s</font>",
                  g_sAmyTarotColors[c1], g_sAmyTarotNames[c1], g_sAmyTarotColors[c2], g_sAmyTarotNames[c2]);

    // v108: una línea por carta con SUS efectos exactos
    char line[192];
    Amy_OM_TarotCardLine(client, c1, line);
    PrintToChat(client, "\x04[Amy]\x01 \x05%s\x01", line);
    Amy_OM_TarotCardLine(client, c2, line);
    PrintToChat(client, "\x04[Amy]\x01 \x05%s\x01", line);

    // v108: el total AGREGADO de la mano (lo que ya aplicaba el
    // announce viejo, ahora con el texto sin mentir: es el dano que
    // Amy RECIBE, no el que pega) + el cuadro del equipo
    float dmgMult  = Amy_OM_TarotDmgMult(client);
    float speedMul = Amy_OM_TarotSpeedMult(client);
    PrintToChat(client, "\x04[Amy]\x01 TOTAL de tu mano: stun de contra/lanzamiento \x03%+.1fs\x01 | dano que RECIBES \x03x%.2f\x01 | tu velocidad \x03x%.2f\x01%s",
                Amy_OM_TarotStunBonus(client), dmgMult, speedMul,
                (c1 == 1 || c2 == 1) ? " | \x05SOL: cura activa\x01" : "");
    if (dmgMult != 1.0)
        PrintToChat(client, "\x04[Amy]\x01 Las cartas solo cambian TU dano recibido (x%.2f = %s%.0f%%). Reducciones de TODO el equipo: escribe \x05sm_defensas\x01.",
                    dmgMult, dmgMult < 1.0 ? "-" : "+", (dmgMult < 1.0 ? 1.0 - dmgMult : dmgMult - 1.0) * 100.0);

    // sonidos de la secuencia del GMod (CardUpgrade -> Good/Normal -> moon)
    EmitSoundToAll(AMY_OM_SND_CARD_UP, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    float value = Amy_OM_TarotStunBonus(client);
    if (Amy_OM_TarotDmgMult(client) < 1.0) value += 0.6;
    else if (Amy_OM_TarotDmgMult(client) > 1.0) value -= 1.0;
    if (Amy_OM_TarotSpeedMult(client) > 1.0) value += 0.2;
    else if (Amy_OM_TarotSpeedMult(client) < 1.0) value -= 0.5;
    char goodSnd[64];
    strcopy(goodSnd, sizeof(goodSnd), value < 0.0 ? AMY_OM_SND_CARD_NORM : AMY_OM_SND_CARD_GOOD);
    EmitSoundToAll(goodSnd, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    if (c1 == 0 || c2 == 0)
        EmitSoundToAll(AMY_OM_SND_CARD_MOON, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
}

// efecto de la carta SOL (RetrieveHealingCard): cada 1.6s (v109: antes 2s)
// cura +1hp a los personajes del suite vivos en 200 a la redonda (tope
// 75hp). En L4D2 PVE se cura a los SURVIVORS (los "OM characters" del GMod);
// el deslumbramiento del GMod era para PvP y no aplica.
// v109: la carta MUNDO entra al mismo pulso (la que era la carta neutra).
void Amy_OM_TarotHealPulse(int client, float now)
{
    if (g_cvAmyOMTarotHeal == null || !g_cvAmyOMTarotHeal.BoolValue) return;
    if (g_iAmyTarotCard1[client] != 1 && g_iAmyTarotCard2[client] != 1
        && g_iAmyTarotCard1[client] != 4 && g_iAmyTarotCard2[client] != 4) return;   // v109: MUNDO también cura
    if (now < g_fAmyTarotNextHeal[client]) return;
    g_fAmyTarotNextHeal[client] = now + 1.6;   // v109: 2.0 -> 1.6 — el Sol necesita un 20% MENOS de tiempo para curar

    float pos[3];
    GetClientAbsOrigin(client, pos);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
        if (i != client && g_iPlayerCharIdx[i] < 0) continue;   // ella + personajes del suite
        if (GetClientHealth(i) >= AMY_OM_HEAL_CAP) continue;    // tope 75 del GMod

        float o[3];
        GetClientAbsOrigin(i, o);
        if (GetVectorDistance(pos, o) > AMY_OM_HEAL_RADIUS) continue;

        int newHp = GetClientHealth(i) + 1;   // healAmount 1
        if (newHp > AMY_OM_HEAL_CAP) newHp = AMY_OM_HEAL_CAP;
        SetEntProp(i, Prop_Send, "m_iHealth", newHp);
    }
}

// COMANDO: robar cartas (ranura X del manager + sm_amycartas)
public Action Amy_OM_CmdTarot(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Amy_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != AMY_INDEX)
    {
        // Sage NO roba: su set AMY sigue con las cartas del super tank
        if (g_iPlayerCharIdx[client] == SAGE_INDEX)
            PrintToChat(client, "\x04[Amy]\x01 Las CARTAS DEL TAROT son de la Amy real. Tu set AMY sigue con el poder aleatorio.");
        else
            PrintToChat(client, "\x04[Amy]\x01 Las cartas son solo de Amy.");
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fAmyTarotNextUse[client])
    {
        // v108: en cooldown la X MUESTRA LA MANO VIGENTE con sus
        // efectos exactos (antes solo decía los segundos que faltaban
        // y no había forma de re-leer que hacen tus cartas)
        PrintCenterText(client, "CARTAS: %.1fs", g_fAmyTarotNextUse[client] - now);
        int c1 = g_iAmyTarotCard1[client];
        int c2 = g_iAmyTarotCard2[client];
        if (c1 >= 0 || c2 >= 0)
        {
            PrintToChat(client, "\x04[Amy]\x01 Mano vigente: \x03%s\x01 + \x03%s\x01 (re-robo en %.1fs):",
                        (c1 >= 0) ? g_sAmyTarotNames[c1] : "-",
                        (c2 >= 0) ? g_sAmyTarotNames[c2] : "-",
                        g_fAmyTarotNextUse[client] - now);
            char line[192];
            if (c1 >= 0) { Amy_OM_TarotCardLine(client, c1, line); PrintToChat(client, "\x04[Amy]\x01 \x05%s\x01", line); }
            if (c2 >= 0) { Amy_OM_TarotCardLine(client, c2, line); PrintToChat(client, "\x04[Amy]\x01 \x05%s\x01", line); }
        }
        return Plugin_Handled;
    }
    if (now < g_fAmyTarotDelayUntil[client])
    {
        PrintCenterText(client, "Las cartas se asientan... %.1fs", g_fAmyTarotDelayUntil[client] - now);
        return Plugin_Handled;
    }

    g_fAmyTarotNextUse[client]    = now + g_cvAmyOMTarotCD.FloatValue;
    g_fAmyTarotDelayUntil[client] = now + g_cvAmyOMTarotDelay.FloatValue;
    g_fAmyTarotNextHeal[client]   = 0.0;

    Amy_OM_TarotDraw(client, false);
    return Plugin_Handled;
}

// ============================================================
//  v96 - LA DEFENSA DE LA Z (rework del owner)
//  "Recuerdas el aura expansiva que sale antes de la pose defensiva?
//  ahora será diferente: se hará la pose defensiva; si llega a
//  impactar contra un infectado, soltara el aura. Ahora el golpe
//  defensivo toma a los objetos Prop que tengan V como válidos para
//  activar el ataque de amy y el aura expansiva (ojo, pero no
//  aturdiria al prop, sería estupido stunear a un prop)".
//  - Z (Amy real, con martillo): SOLO la pose (ventana 2s, GMod
//    HammerDuration + HammerReady). SIN aura upfront.
//  - Al IMPACTAR durante la ventana: se suelta el AURA EXPANSIVA
//    (VFX ring + swing + barrido 360 = el ataque de la vieja Z) y:
//      * especial/tank/witch: además la CONTRA (OM_Stun pre-sonic
//        SIN ragdoll, 3.5s + cartas — igual que la v92)
//      * común: solo el aura (el barrido lo dana); sin stun
//      * PROP CON VELOCIDAD (autos que vienen volando, piedra del
//        tank...): solo el aura — el barrido lo lanza/redirige; sin
//        stun ("sería estupido stunear a un prop")
//  - La ventana se consume con el primer impacto (GMod:
//    jumpscare_entity = el primero; HammerDuration = 0 al conectar).
// ============================================================
void Amy_OM_CounterOpen(int client, float now)
{
    g_fAmyOMCounterUntil[client] = now + g_cvAmyOMCounterWindow.FloatValue;
    g_bAmyOMCounterMissed[client] = false;
    EmitSoundToAll(AMY_OM_SND_READY, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
    PrintCenterText(client, "DEFENSA: el que te toque, suelta el aura");
}

// v96: EL AURA EXPANSIVA — exactamente el paquete que la vieja Z
// soltaba upfront (VFX ring + sonido + barrido 360 de 0.5s con LOS y
// registro por golpe). La sueltan los triggers de la defensa.
void Amy_OM_ReleaseAura(int client, float now)
{
    Amy_VFX_Strike(client);
    EmitSoundToAll(AMY_SOUND_SWING_DEF, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);

    g_iAmySweepHitCount[client] = 0;
    g_fAmySweepStart[client] = now;
    g_bAmySweepFirstTick[client] = true;
    CreateTimer(AMY_STRIKE_VISUAL_TICK, T_AmyHammerSweep, GetClientUserId(client),
                TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

void Amy_OM_CounterTrigger(int client, int victim, bool isWitch)
{
    // ventana consumida (GMod: HammerDuration = 0 al conectar)
    g_fAmyOMCounterUntil[client] = 0.0;
    g_bAmyOMCounterMissed[client] = false;

    // v96: EL AURA EXPANSIVA se suelta AL IMPACTAR (antes salia con la
    // propia Z): VFX ring + swing + barrido 360 que dana a todo lo
    // que rodea a Amy (infectados, comunes y props de la vieja Z)
    Amy_OM_ReleaseAura(client, GetEngineTime());

    // stun base + cartas ("3.5 seg que aumenta dependiendo de las
    // cartas que salgan" — owner; Fuerza +1s, Loco -1s)
    float stun = g_cvAmyOMCounterStun.FloatValue + Amy_OM_TarotStunBonus(client);
    if (stun < 0.5) stun = 0.5;

    float vPos[3], aPos[3];
    GetClientAbsOrigin(client, aPos);

    if (isWitch)
    {
        // la witch no es player: estatua + estrellas (Sonic_WitchStun).
        // v107: con el lanzamiento activado TAMBIÉN suelta su doble
        // volador (la misma pieza del martillo) — la garra que toca la
        // defensa sale escupida hacia arriba
        Sonic_WitchStun(victim, stun);
        GetEntPropVector(victim, Prop_Data, "m_vecOrigin", vPos);

        if (g_cvAmyOMCounterLaunch != null && g_cvAmyOMCounterLaunch.BoolValue)
        {
            float wUp[3];
            wUp[0] = (vPos[0] - aPos[0]) * 0.2;
            wUp[1] = (vPos[1] - aPos[1]) * 0.2;
            wUp[2] = 1.0;
            NormalizeVector(wUp, wUp);
            Sonic_SpawnWitchRagdoll(victim, wUp);
        }
    }
    else
    {
        // v107: ORDEN DEL MARTILLO v106 + EL LANZON VERTICAL — pedido
        // del owner: "el golpe pueda impulsar verticalmente hacia
        // arriba, o sea pueda ser controlado". El dano VA PRIMERO y
        // AMPLIFICADO (OM_AbilityDamage: x2 + % vs jefes — si mata, el
        // cadaver vuela con la copia Rouge y el stun no lo mata al
        // doble a los 0.1s); si sobrevive: OM_Stun (sin dano dentro)
        // y, si aterrizo, el RAGDOLL VOLADOR mayormente hacia ARRIBA
        // con empujon de separación — la fuerza la pone
        // amyom_counter_fling (controlable en vivo).
        OM_AbilityDamage(victim, client, g_cvAmyOMCounterDmg.FloatValue, DMG_CLUB);
        GetClientAbsOrigin(victim, vPos);

        if (!IsPlayerAlive(victim))
        {
            // letal: el cadaver vuela (copia Rouge generalizada sonic v6.35)
            float dUp[3];
            dUp[0] = (vPos[0] - aPos[0]) * 0.2;
            dUp[1] = (vPos[1] - aPos[1]) * 0.2;
            dUp[2] = 1.0;
            NormalizeVector(dUp, dUp);
            Sonic_DeadFlingCopy(victim, dUp, g_cvAmyOMCounterFling.FloatValue, false);
        }
        else if (OM_Stun(victim, stun, client, 0.0, DMG_CLUB, true))
        {
            if (g_cvAmyOMCounterLaunch != null && g_cvAmyOMCounterLaunch.BoolValue)
            {
                // LA DIRECCION: mayormente ARRIBA + separación de Amy
                // (reglas GMod incorporadas de facto: la victima en el
                // suelo tiene la elevación garantizada del eje Z dominante)
                float up[3];
                up[0] = (vPos[0] - aPos[0]) * 0.35;
                up[1] = (vPos[1] - aPos[1]) * 0.35;
                up[2] = 1.0;
                NormalizeVector(up, up);
                Sonic_SpawnFlingRagdollEx(victim, up,
                                           g_cvAmyOMCounterFling.FloatValue, 0.45, 900.0);
                PrintCenterText(client, "CONTRA! %.1fs de stun + al aire", stun);
            }
        }
    }

    // jugo del golpe (el sonido del GMod)
    EmitSoundToAll(AMY_OM_SND_HIT, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
    EmitSoundToAll(AMY_SOUND_HIT_GEN, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);

    PrintCenterText(client, "CONTRA! %.1fs de stun", stun);

    // gesto one-shot del swing (GMod: AddGestureSequence("swing"))
    Amy_OM_PlayGesture(client, AMY_OM_ST_SWING, 0.5);
}

// v96: trigger por COMÚN — solo el aura (el barrido lo dana), sin
// stun (la contra de stun es para especiales/tank/witch)
void Amy_OM_CounterTriggerCommon(int client)
{
    g_fAmyOMCounterUntil[client] = 0.0;
    g_bAmyOMCounterMissed[client] = false;

    Amy_OM_ReleaseAura(client, GetEngineTime());

    EmitSoundToAll(AMY_SOUND_HIT_GEN, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
    PrintCenterText(client, "DEFENSA!");

    // el gesto del swing igual que el GMod (jumpscare -> swing)
    Amy_OM_PlayGesture(client, AMY_OM_ST_SWING, 0.5);
}

// v96: trigger por PROP ("los objetos Prop que tengan V como válidos").
// v97: TAMBIÉN los QUIETOS — veredicto del owner: "los inmoviles
// importan, recuerda que normalmente los props no se mueven (con
// excepciones, pero es mejor cubrir ambas cosas)": cualquier prop al
// radio consume la ventana, este quieto o volando. El aura se suelta
// igual (el barrido LANZA/REDIRIGE el prop — sin el aura los autos no
// se moverian) pero SIN stun: "sería estupido stunear a un prop" (owner)
void Amy_OM_CounterTriggerProp(int client)
{
    g_fAmyOMCounterUntil[client] = 0.0;
    g_bAmyOMCounterMissed[client] = false;

    Amy_OM_ReleaseAura(client, GetEngineTime());

    EmitSoundToAll(AMY_SOUND_HIT_GEN, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
    PrintCenterText(client, "DEFENSA! Objeto repelido");

    Amy_OM_PlayGesture(client, AMY_OM_ST_SWING, 0.5);
}

// escaneo de la ventana (10 Hz desde la FSM): el primer especial/
// tank/witch/común/prop al radio consume la ventana.
// v96: comunes y props ya cuentan (antes solo especiales; el aura ya
// no sale con la Z, así que el común que la toque TAMBIÉN la suelta
// — el stun sigue siendo solo para especiales/tank/witch).
void Amy_OM_CounterScan(int client)
{
    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += AMY_OM_COUNTER_Z;   // GMod: esfera a mitad del cuerpo

    float rad = g_cvAmyOMCounterRadius.FloatValue;

    // especiales y tank (players del equipo 3)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float o[3];
        GetClientAbsOrigin(i, o);
        if (GetVectorDistance(pos, o) > rad) continue;

        Amy_OM_CounterTrigger(client, i, false);
        return;
    }

    // witch (entity)
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (!IsValidEntity(witch)) continue;
        if (GetEntProp(witch, Prop_Data, "m_iHealth") <= 0) continue;

        float o[3];
        GetEntPropVector(witch, Prop_Data, "m_vecOrigin", o);
        if (GetVectorDistance(pos, o) > rad) continue;

        Amy_OM_CounterTrigger(client, witch, true);
        return;
    }

    // v96: comunes — "si llega a impactar contra un infectado": el
    // primer común al radio también suelta el aura (sin stun)
    int common = -1;
    while ((common = FindEntityByClassname(common, "infected")) != -1)
    {
        if (!IsValidEntity(common)) continue;
        if (GetEntProp(common, Prop_Data, "m_iHealth") <= 0) continue;

        float o[3];
        GetEntPropVector(common, Prop_Send, "m_vecOrigin", o);
        if (GetVectorDistance(pos, o) > rad) continue;

        Amy_OM_CounterTriggerCommon(client);
        return;
    }

    // v96/v97: props — CUALQUIERA al radio (owner: "normalmente los
    // props no se mueven... es mejor cubrir ambas cosas"): el auto
    // estacionado, el mueble del suelo y el auto que viene volando
    // activan igual; el barrido del aura los lanza/redirige
    for (int c = 0; c < AMY_PROP_CLASSES; c++)
    {
        int prop = -1;
        while ((prop = FindEntityByClassname(prop, g_sAmyPropClasses[c])) != -1)
        {
            if (!IsValidEntity(prop)) continue;

            float o[3];
            GetEntPropVector(prop, Prop_Data, "m_vecOrigin", o);
            if (GetVectorDistance(pos, o) > rad) continue;

            Amy_OM_CounterTriggerProp(client);
            return;
        }
    }

    // v96: la piedra del tank también es "objeto con V" (proyectil)
    int rock = -1;
    while ((rock = FindEntityByClassname(rock, "tank_rock")) != -1)
    {
        if (!IsValidEntity(rock)) continue;

        float o[3];
        GetEntPropVector(rock, Prop_Send, "m_vecOrigin", o);
        if (GetVectorDistance(pos, o) > rad) continue;

        Amy_OM_CounterTriggerProp(client);
        return;
    }
}

// ============================================================
//  v92 - PHASE THINK (10 Hz, SIEMPRE para Amy viva — las habilidades
//  NO dependen del visual): ventana de defensa, armado del
//  lanzamiento, recogida/retorno del martillo, cura del Sol
// ============================================================
void Amy_OM_PhaseThink(int client, float now)
{
    // ============================================================
    // v102/v104: PARRY DELEGADO — la VENTANA DE DEFENSA de Amy
    // abre/cierra SU ventana de parry en el chch_parrying.nut vía SU
    // entrada ChCh_AmyNotify (contador APARTE del de Knuckles; la
    // entrada de cada quien es su identidad). "Si está con la defensa
    // activa el parry se activa; si deja de estar en defensiva el
    // parry se desactiva": flanco de subida = pose ON -> notify(1);
    // flanco de bajada (impacto que consume la ventana — parry o
    // normal —, vencimiento, stun, incap) = notify(0). Si Amy muere,
    // el .nut limpia su ventana solo (checks de validez + dur corta).
    // ============================================================
    bool parryOpen = (g_fAmyOMCounterUntil[client] > now);
    if (parryOpen != g_bAmyParryOpen[client])
    {
        g_bAmyParryOpen[client] = parryOpen;
        Amy_ParryNotifyNut(client, parryOpen, now);
    }

    // aturdida o incap: cortar lo activo (GMod OM_Stun_Blockfunction /
    // CustomFunctionForDowned_OM: HammerDuration 0 + ThrowShould 0)
    if (OM_IsStunned(client) || GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
    {
        if (g_fAmyOMCounterUntil[client] > 0.0 || g_bAmyOMThrowArmed[client])
        {
            g_fAmyOMCounterUntil[client] = 0.0;
            g_bAmyOMCounterMissed[client] = false;
            g_bAmyOMThrowArmed[client] = false;
        }
    }
    else
    {
        // ---- ventana de defensa: escanear / avisar si vencio ----
        if (g_fAmyOMCounterUntil[client] > now)
        {
            Amy_OM_CounterScan(client);
        }
        else if (g_fAmyOMCounterUntil[client] > 0.0)
        {
            // vencio sin nadie (GMod: HammerMiss + cierre)
            g_fAmyOMCounterUntil[client] = 0.0;
            if (!g_bAmyOMCounterMissed[client])
            {
                g_bAmyOMCounterMissed[client] = true;
                EmitSoundToAll(AMY_OM_SND_MISS, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
            }
        }

        // ---- armado del lanzamiento: expiración silenciosa ----
        if (g_bAmyOMThrowArmed[client] && now > g_fAmyOMArmedUntil[client])
        {
            g_bAmyOMThrowArmed[client] = false;
            EmitSoundToAll(AMY_OM_SND_THROW_CANCEL, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
        }

        // ---- cura del Sol ----
        Amy_OM_TarotHealPulse(client, now);
    }

    // ---- martillo en vuelo/tirado: recogida + retorno ----
    if (g_bAmyOMNoHammer[client])
        Amy_OM_HammerTick(client, now);
}

// ============================================================
//  v92 - LANZAMIENTO DE MARTILLO (habilidad 3, tecla V)
//  El Throw del GMod adaptado a ranura: 1a pulsación ARMA (sonido de
//  listo + postura idlethrow), 2a pulsación LANZA (el GMod usa el
//  click de ataque; aquí la propia V — no le robamos el disparo al
//  jugador). El martillo es un prop_physics_override REAL (hammer.mdl
//  del VPK, masa 50 = el "peso 50" del owner) con trail blanco, y al
//  impactar contra un especial/tank/witch: stun + RAGDOLL FALSO que
//  SALE VOLANDO (la receta sonic v6.11-6.13: onda física + hueco
//  seguro + restauración — "este si es capaz de mandar a volar").
//  Recogida: acercarse (140u) o vuelve solo a los 8s volando.
// ============================================================
public Action Amy_OM_CmdThrow(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Amy_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != AMY_INDEX)
    {
        PrintToChat(client, "\x04[Amy]\x01 El lanzamiento es solo de Amy.");
        return Plugin_Handled;
    }
    if (!IsPlayerAlive(client)) return Plugin_Handled;

    float now = GetEngineTime();

    // 2a pulsación con el arma cargada: LANZAR
    if (g_bAmyOMThrowArmed[client])
    {
        g_bAmyOMThrowArmed[client] = false;
        g_fAmyOMArmLockUntil[client] = now + 0.3;
        Amy_OM_HammerLaunch(client, now);
        return Plugin_Handled;
    }

    if (now < g_fAmyOMArmLockUntil[client]) return Plugin_Handled;

    if (g_bAmyOMNoHammer[client])
    {
        int hammer = (g_iAmyOMHammerProp[client] != 0) ? EntRefToEntIndex(g_iAmyOMHammerProp[client]) : -1;
        if (hammer > MaxClients && IsValidEntity(hammer))
            PrintCenterText(client, "MARTILLO EN CAMINO (acercate o espera su retorno)");
        else
            PrintCenterText(client, "Sin martillo!");
        return Plugin_Handled;
    }

    if (now < g_fAmyOMThrowCDUntil[client])
    {
        PrintCenterText(client, "LANZAMIENTO: %.1fs", g_fAmyOMThrowCDUntil[client] - now);
        return Plugin_Handled;
    }
    if (now < g_fAmyOMEndLagUntil[client])
    {
        PrintCenterText(client, "Recuperando el martillo... %.1fs", g_fAmyOMEndLagUntil[client] - now);
        return Plugin_Handled;
    }

    // 1a pulsación: ARMAR (GMod: HammerThrowShouldThrow + sonido)
    g_bAmyOMThrowArmed[client] = true;
    g_fAmyOMArmedUntil[client] = now + 10.0;   // expiración silenciosa
    EmitSoundToAll(AMY_OM_SND_THROW_READY, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
    PrintCenterText(client, "LANZAMIENTO ARMADO — V otra vez para lanzar");
    return Plugin_Handled;
}

// pase directo del manager (sm_sjs_ability3 de Amy)
public Action Amy_OM_HammerThrow(int client, int args)
{
    return Amy_OM_CmdThrow(client, args);
}

// el pase de la habilidad 4 (sm_sjs_ability4 de Amy): el viejo poder
// aleatorio del super tank INTACTO ("las cartas actuales de super
// tank pasaran a ser la habilidad 4")
// v108: LA B DE AMY = ALTERNAR MODO DEL MARTILLO (BUMERAN <-> COMÚN).
// Pedido del owner: "el ataque impulso ya no podrá ser cambiado con el
// sm_sjs_ability4 en su lugar ahora permitira cambiar entre modo
// bumeran o modo común". Es una PREFERENCIA por jugador sin cooldown
// (la misma filosofia de la C: decide que hace el PRÓXIMO
// lanzamiento, no cancela ninguno en vuelo). Las CARTAS DEL SUPER
// TANK que vivian aquí pasan a consola (sm_amysupertank, intactas).
// Sage conserva su ruta propia (set AMY prestado): su B sigue siendo
// el poder aleatorio del super tank.
public Action Amy_OM_CmdPower4(int client, int args)
{
    if (!Amy_IsValidClient(client)) return Plugin_Handled;

    // Sage NO tiene martillo: su set AMY prestado mantiene la B como
    // cartas del super tank (sin cambio para el)
    if (g_iPlayerCharIdx[client] != AMY_INDEX)
        return Command_RandomPower(client, args);

    // Amy real: alterna la preferencia (sin cooldown — preferencia)
    if (!g_bAmyOMBoomPrefInit[client])
    {
        g_bAmyOMBoomPref[client] = (g_cvAmyOMBoomMode != null && g_cvAmyOMBoomMode.BoolValue);
        g_bAmyOMBoomPrefInit[client] = true;
    }
    g_bAmyOMBoomPref[client] = !g_bAmyOMBoomPref[client];

    float dist = (g_cvAmyOMBoomDist != null) ? g_cvAmyOMBoomDist.FloatValue : 2325.0;
    if (g_bAmyOMBoomPref[client])
    {
        PrintCenterText(client, "MARTILLO: modo BUMERAN");
        PrintToChat(client, "\x04[Amy]\x01 Modo del martillo: \x03BUMERAN\x01 — gira como un bumeran (%.0f u de ida), pega tipo \x05CORTE\x01 en ida y vuelta, y vuelve solo a tu mano.", dist);
    }
    else
    {
        PrintCenterText(client, "MARTILLO: modo COMÚN");
        PrintToChat(client, "\x04[Amy]\x01 Modo del martillo: \x03COMUN\x01 — tiro recto clasico con tumble, cae y se recoge (o auto-retorna). Pega tipo impacto.");
    }
    PrintToChat(client, "\x04[Amy]\x01 Cámbialo cuantas veces quieras con la \x03B\x01 (afecta al PRÓXIMO lanzamiento). Cartas del super tank: consola \x05sm_amysupertank\x01.");
    EmitSoundToClient(client, g_bAmyOMBoomPref[client] ? "buttons/button17.wav" : "buttons/button16.wav",
                      client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    return Plugin_Handled;
}

void Amy_OM_HammerLaunch(int client, float now)
{
    // CD desde el lanzamiento (GMod: Throw_cd al soltar)
    g_fAmyOMThrowCDUntil[client] = now + g_cvAmyOMThrowCD.FloatValue;

    // gesto one-shot del throw (GMod: AddGestureSequence("throw"))
    EmitSoundToAll(AMY_OM_SND_THROW, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
    Amy_OM_PlayGesture(client, AMY_OM_ST_THROW, 0.5);

    // --- dirección: hacia el punto de la mirada (GMod SendOverPoision:
    // el vector hacia el hit del mouse) ---
    float eyePos[3], eyeAng[3], endPos[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);
    Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, Amy_TraceFilter_NoSelf, client);
    if (trace != null && TR_DidHit(trace))
        TR_GetEndPosition(endPos, trace);
    else
        GetAngleVectors(eyeAng, endPos, NULL_VECTOR, NULL_VECTOR);   // dir como pos relativa
    delete trace;

    // --- spawn del prop (receta suite: masa ANTES del spawn) ---
    int hammer = CreateEntityByName("prop_physics_override");
    if (hammer <= 0 || !IsValidEntity(hammer)) return;

    // aviso 1 vez por mapa si el VPK no trae hammer.mdl (vuela el
    // frasco de bilis de repuesto — receta ORBS)
    if (!g_bAmyOMHammerOK && !g_bAmyOMHammerWarned)
    {
        g_bAmyOMHammerWarned = true;
        PrintToChat(client, "\x04[Amy]\x01 hammer.mdl no está en el VPK: el lanzamiento usa el \x03frasco de bilis\x01 de repuesto.");
    }

    DispatchKeyValue(hammer, "model", g_sAmyOMHammerMdl);
    DispatchKeyValue(hammer, "mass", "50");                       // el "peso 50" del GMod
    DispatchKeyValue(hammer, "physdamagescale", "0.0");
    DispatchKeyValue(hammer, "targetname", "amy_om_hammer");
    DispatchSpawn(hammer);

    // nace al pecho, con traza anti-pared (GMod: up*30 + trace 50)
    float pos[3], fwd[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += AMY_OM_THROW_SPAWN_Z;
    GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);
    Handle wall = TR_TraceRayFilterEx(pos, eyeAng, MASK_SOLID, RayType_Infinite, Amy_TraceFilter_NoSelf, client);
    if (wall != null && TR_DidHit(wall))
    {
        float hitPos[3];
        TR_GetEndPosition(hitPos, wall);
        if (GetVectorDistance(pos, hitPos) < AMY_OM_THROW_SPAWN_FWD)
        {
            // nace pegado a la pared: salir del muro en la normal
            float nrm[3];
            TR_GetPlaneNormal(wall, nrm);
            pos[0] = hitPos[0] + nrm[0] * 24.0;
            pos[1] = hitPos[1] + nrm[1] * 24.0;
            pos[2] = hitPos[2] + nrm[2] * 24.0 + 8.0;
        }
    }
    delete wall;

    // angulos: apuntando al objetivo (GMod: ang del vector + 90 yaw)
    float dir[3];
    dir[0] = endPos[0] - pos[0];
    dir[1] = endPos[1] - pos[1];
    dir[2] = endPos[2] - pos[2];
    float dlen = GetVectorLength(dir);
    if (dlen < 1.0)
    {
        dir[0] = fwd[0]; dir[1] = fwd[1]; dir[2] = fwd[2];
        dlen = 1.0;
    }
    dir[0] /= dlen; dir[1] /= dlen; dir[2] /= dlen;

    float launchAng[3];
    launchAng[1] = RadToDeg(ArcTangent2(dir[1], dir[0]));
    launchAng[0] = -RadToDeg(ArcTangent2(dir[2], SquareRoot(dir[0]*dir[0] + dir[1]*dir[1])));
    launchAng[2] = 0.0;

    TeleportEntity(hammer, pos, launchAng, NULL_VECTOR);

    // v107: BOOMERANG HAMMER — estado del tiro. En modo bumeran la V
    // gira PLANO (eje vertical, como un bumeran de verdad), mantiene el
    // rumbo RECTO (el scan re-afirma la velocidad cada tick: ni
    // gravedad ni rozamiento) y al llegar a amyom_boom_dist (o frenarse
    // contra una pared) da la vuelta con el vuelo de retorno del GMod
    // (el mismo de siempre: arco + giro 720). El clasico (mode 0) queda
    // intacto: tiro balistico + cartwheel + recogida/retorno a los 8s.
    // v108: el modo sale de la PREFERENCIA DE LA B (g_bAmyOMBoomPref,
    // default de fábrica = amyom_boom_mode) — el convar ya no manda
    // directo; y la rotación de la ida pasa a TeleportEntity (receta del
    // retorno): el giro físico nace a CERO para no pelear con el angulo
    // escrito por tick.
    g_bAmyOMHammerBoom[client] = g_bAmyOMBoomPref[client];
    g_fAmyOMHammerBoomPos[client] = pos;
    g_fAmyOMHammerBoomDir[client] = dir;
    g_iAmyOMHammerSlowN[client] = 0;
    if (g_bAmyOMHammerBoom[client])
    {
        // v108: reloj del giro plano — yaw arranca en el rumbo del tiro
        // y avanza amyom_boom_spin grados/s con dt REAL (el timer de 30
        // Hz dispara al tick del motor más cercano: el dt varia)
        g_fAmyOMBoomPitch[client] = launchAng[0];
        g_fAmyOMBoomYaw[client]   = launchAng[1];
        g_fAmyOMBoomLastT[client] = now;
    }

    // velocidad: dir * poder + 150z (GMod: power 3000 + Vector(0,0,150))
    float vel[3];
    vel[0] = dir[0] * g_cvAmyOMThrowPower.FloatValue;
    vel[1] = dir[1] * g_cvAmyOMThrowPower.FloatValue;
    vel[2] = dir[2] * g_cvAmyOMThrowPower.FloatValue + AMY_OM_THROW_UP;

    // receta suite (Amy_LaunchMapProp): despertar la física y lanzar
    AcceptEntityInput(hammer, "EnablePhysics");
    AcceptEntityInput(hammer, "Wake");

    // v105 FIX 3: FÍSICA DINÁMICA DE VERDAD (pedido del owner: "el
    // martillo no salga solamente así tieso... que tenga movimiento
    // dinámico, física de movimiento real.. que pueda girar y demas
    // como hacen los objetos reales; hasta un auto cuando le pega el
    // tank este puede girar, rota en el aire"). El giro YA NO va al
    // datamap m_angVelocity (el vphysics lo sobreescribe cada tick —
    // la MISMA lección del "doble que nace y cae en seco" v6.9): va
    // DIRECTO al IPhysicsObject con el SDKCall del motor v6.33, ahora
    // abierto a props (Sonic_PhysSetVel, sonic.inc v6.34):
    //   - CARTWHEEL: rotación alrededor del eje DERECHO del rumbo (el
    //     martillo gira de cabeza, como un martillo real lanzado — no
    //     en barren como el AddAngleVelocity(forward) del GMod)
    //   - WOBBLE: componentes random sobre los otros 2 ejes (+-20%) =
    //     el tumble organico del coche que gira cuando lo pega el tank
    // UN impulso y el motor se encarga del resto (filosofia GMod
    // literal). Plan B (sin SDKCall): TeleportEntity-vel (SetVelocity
    // del raíz) + el m_angVelocity viejo (el trail lo vende igual).
    float right[3], up[3];
    GetAngleVectors(launchAng, NULL_VECTOR, right, up);
    float spinRate = g_cvAmyOMThrowSpin.FloatValue;
    float wDir  = GetRandomFloat(-0.2, 0.2);
    float wUp   = GetRandomFloat(-0.1, 0.1);
    float spin[3];
    if (g_bAmyOMHammerBoom[client])
    {
        // v108: GIRO FÍSICO CERO en el bumeran — la rotación visible la
        // escribe el BoomDrive por TeleportEntity cada tick (la receta
        // del RETORNO, que ya gira desde la v92: el motor hace
        // pPhys->SetPosition(origin, ang, true) y el objeto ADOPTA el
        // angulo). Si el vphysics girara también pelearia con ese
        // angulo escrito = jitter. El SDKCall queda para la VELOCIDAD
        // lineal únicamente.
        spin[0] = 0.0;
        spin[1] = 0.0;
        spin[2] = 0.0;
    }
    else
    {
        spin[0] = (right[0] + dir[0] * wDir + up[0] * wUp) * spinRate;
        spin[1] = (right[1] + dir[1] * wDir + up[1] * wUp) * spinRate;
        spin[2] = (right[2] + dir[2] * wDir + up[2] * wUp) * spinRate;
    }

    if (!Sonic_PhysSetVel(hammer, vel, spin))
    {
        TeleportEntity(hammer, NULL_VECTOR, NULL_VECTOR, vel);
        if (HasEntProp(hammer, Prop_Data, "m_angVelocity"))
        {
            float oldSpin[3];
            oldSpin[0] = dir[0] * 1000.0;
            oldSpin[1] = dir[1] * 1000.0;
            oldSpin[2] = dir[2] * 1000.0;
            SetEntPropVector(hammer, Prop_Data, "m_angVelocity", oldSpin);
        }
    }

    // el martillo no recibe dano (GMod: EntityTakeDamage -> 0)
    if (HasEntProp(hammer, Prop_Data, "m_takedamage"))
        SetEntProp(hammer, Prop_Data, "m_takedamage", 0);

    // v105 FIX 2 (cinturon 1 de 3): DANO DE COLISION FÍSICA VANILLA =
    // CERO de fábrica. El keyvalue physdamagescale no siempre pega en
    // un prop_physics_override — el campo REAL que ese KV escribe es
    // m_impactEnergyScale (CBaseEntity), y a 0.0 el motor NO calcula
    // crash damage contra NADIE (pedido: "quitale el dano de colisión
    // física del juego vanilla al martillo").
    if (HasEntProp(hammer, Prop_Data, "m_impactEnergyScale"))
        SetEntPropFloat(hammer, Prop_Data, "m_impactEnergyScale", 0.0);

    // toque: el impacto contra infectados
    SDKHook(hammer, SDKHook_Touch, Amy_OM_HammerTouch);

    // v96: HITBOX AÉREO AMPLIADO (owner: "debemos crearme una hitbox
    // 35% más grande que su cuerpo del objeto que pueda aplicar los
    // efectos de stun"): el Touch físico queda (es la colisión real
    // del hammer.mdl) y este scan de 30 Hz durante el vuelo de IDA
    // engloba al martillo en una esfera de radio = 1.35 x la mitad
    // de la diagonal de su bounding box (amyom_throw_hitbox), con lo
    // que el stun+ragdoll/atraviesa conecta sin tocar fisicamente.
    g_iAmyOMHammerSoftN[client] = 0;
    g_fAmyOMHammerHitR[client] = 20.0;   // fallback si el modelo no reporta bounds
    if (HasEntProp(hammer, Prop_Data, "m_vecMins") && HasEntProp(hammer, Prop_Data, "m_vecMaxs"))
    {
        float mins[3], maxs[3], half[3];
        GetEntPropVector(hammer, Prop_Data, "m_vecMins", mins);
        GetEntPropVector(hammer, Prop_Data, "m_vecMaxs", maxs);
        half[0] = (maxs[0] - mins[0]) * 0.5;
        half[1] = (maxs[1] - mins[1]) * 0.5;
        half[2] = (maxs[2] - mins[2]) * 0.5;
        float halfDiag = GetVectorLength(half);
        if (halfDiag > 1.0)
            g_fAmyOMHammerHitR[client] = halfDiag * g_cvAmyOMThrowHitbox.FloatValue;
    }
    if (g_hAmyOMHammerScan[client] != null)
        delete g_hAmyOMHammerScan[client];
    g_hAmyOMHammerScan[client] = CreateTimer(0.03, T_AmyOMHammerScan, GetClientUserId(client),
                                             TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    // trail ROSA (GMod: SpriteTrail 25->2, vida 0.3, blanco con
    // amy/white.vmt — aquí laserbeam nativo. v101: el owner pidió el
    // efecto en color ROSA). v6.18/v100: motor TE BeamFollow
    // (el env_spritetrail no renderiza en L4D2)
    if (g_cvAmyOMTrails != null && g_cvAmyOMTrails.BoolValue && g_iSonicTELaser > 0)
    {
        int cHam[4] = {255, 105, 180, 220};   // v101: ROSA (antes blanco)
        g_iAmyOMHammerTrail[client] = Sonic_TEStartFollow(hammer, g_iSonicTELaser, 0.3, 25.0, 2.0, 3, cHam);
    }

    // estado: SIN martillo (GMod: HasNoHammer + bodygroup)
    g_bAmyOMNoHammer[client] = true;
    Amy_OM_AvatarChains(client, true);   // v93: chains 1 = martillo FUERA del modelo
    g_iAmyOMHammerProp[client] = EntIndexToEntRef(hammer);
    g_fAmyOMHammerBorn[client] = now;
    g_bAmyOMHammerHit[client] = false;
    g_bAmyOMHammerReturning[client] = false;

    // v108: el mensaje dice QUE modo se lanzo (ahora que la B lo alterna,
    // el jugador ve confirmado lo que tiro)
    if (g_bAmyOMHammerBoom[client])
        PrintCenterText(client, "MARTILLO LANZADO! (BUMERAN — gira y vuelve solo)");
    else
        PrintCenterText(client, "MARTILLO LANZADO! (COMÚN — tiro recto)");
}

// filtrito de traza que ya existe en Amy.inc (Amy_TraceFilter_NoSelf)
// reutilizado para el aim y la traza anti-pared del spawn.

// v105: LA DIRECCION DEL IMPULSO GMOD (el "que clase de impulso usa
// amy" del lua del OM): depende de EN QUE DIRECCION RECIBE EL GOLPE la
// victima — el rumbo del martillo ES la dirección del golpe:
//   - pega DESDE ABAJO (subiendo)   -> la victima sale HACIA ARRIBA
//   - pega DESDE ARRIBA (cayendo)   -> la victima sale EMPUJADA HACIA ABAJO
//   - victima YA EN EL SUELO y golpe descendente/rasante -> DIRECCION
//     CONTRARIA (la componente Z se niega: rebota) + IMPULSO QUE LA
//     ELEVA — debajo del piso no hay nada, el golpe la hace rebotar
//     y despegar ("si esta ya en el suelo el impacto lo lanzara hacia
//     la dirección contraria pero teniendo un impulso que lo eleva").
// Un impulso 1 vez y el motor se encarga del resto. La usan las 3
// ramas del impacto (especiales/tank, witch y comunes).
void Amy_OM_HammerHitDir(int client, int hammer, int other, float dir[3], bool &grounded)
{
    // rumbo del golpe = velocidad del martillo (fallback si esta casi
    // parado: la dirección Amy -> victima). v106: el impacto puede
    // llegar DIFERIDO (flush del frame siguiente) con el prop ya
    // recuperado/esfumado — martillo inválido = fallback directo.
    dir[0] = 0.0; dir[1] = 0.0; dir[2] = 0.0;
    if (hammer > MaxClients && IsValidEntity(hammer))
        GetEntPropVector(hammer, Prop_Data, "m_vecVelocity", dir);
    float vlen = GetVectorLength(dir);
    if (vlen < 50.0)
    {
        float aPos[3], vPos[3];
        GetClientAbsOrigin(client, aPos);
        if (other > 0 && other <= MaxClients)
            GetClientAbsOrigin(other, vPos);
        else
            GetEntPropVector(other, Prop_Data, "m_vecOrigin", vPos);
        dir[0] = vPos[0] - aPos[0];
        dir[1] = vPos[1] - aPos[1];
        dir[2] = vPos[2] - aPos[2];
        vlen = GetVectorLength(dir);
        if (vlen < 1.0) { dir[0] = 1.0; dir[1] = 0.0; dir[2] = 0.0; vlen = 1.0; }
    }
    dir[0] /= vlen;
    dir[1] /= vlen;
    dir[2] /= vlen;

    grounded = false;
    if (HasEntProp(other, Prop_Data, "m_fFlags"))
        grounded = (GetEntProp(other, Prop_Data, "m_fFlags") & FL_ONGROUND) != 0;

    if (grounded && dir[2] < 0.1)
    {
        // EN EL SUELO: dirección contraria en Z + elevación garantizada
        dir[2] = -dir[2];
        if (dir[2] < 0.35) dir[2] = 0.35;
        dir[2] += 0.45;
        NormalizeVector(dir, dir);
    }
}

// v96: NUCLEO DEL IMPACTO compartido por el Touch físico y el scan
// del hitbox ampliado. Especiales/tank -> stun + RAGDOLL FALSO
// VOLANDO (sonic v6.11+); witch -> stun + ragdoll; comunes -> dano y
// sigue; survivors/mundo -> nada (el vphysics rebota solo).
// Devuelve true si el objetivo era válido (para el registro del scan).
bool Amy_OM_HammerHitTarget(int client, int other, int hammer)
{
    // --- especiales / tank (players equipo 3) ---
    if (other > 0 && other <= MaxClients && IsClientInGame(other)
        && IsPlayerAlive(other) && GetClientTeam(other) == TEAM_INFECTED)
    {
        // stun base + cartas (GMod Throw_Stun_dur 3 + RetrieveCurrentAttack)
        float stun = 3.0 + Amy_OM_TarotStunBonus(client);
        if (stun < 0.5) stun = 0.5;

        // v105: dirección del impulso = LAS REGLAS GMOD (antes: el
        // rumbo plano del martillo sin más): desde abajo = hacia
        // arriba; en el suelo = dirección contraria + elevación.
        float dir[3];
        bool grounded;
        Amy_OM_HammerHitDir(client, hammer, other, dir, grounded);

        // v106 (C) DANO PRIMERO, FUERA DEL STUN (el orden del Barrido):
        // si el golpe LO MATA, la copia Rouge sale volando (el doble de
        // stun lo mataría el watcher a los 0.1s — vuelo invisible); si
        // SOBREVIVE, stun + ragdoll falso del spindash. Los iframes del
        // OM solo resisten el STUN — el dano del martillo se paga igual.
        // v107: OM_AbilityDamage = amplificador hibrido (x2 + % vs jefes)
        // v108: TIPO DE DANO SEGÚN EL MODO — pedido del owner: "el tipo
        // de dano que será el ataque de martillo boomeran será tipo
        // slash o corte". Bumeran = DMG_SLASH (corte); tiro clasico =
        // DMG_CLUB (impacto) como siempre
        int boomDmgType = g_bAmyOMHammerBoom[client] ? DMG_SLASH : DMG_CLUB;
        OM_AbilityDamage(other, client, g_cvAmyOMThrowDmg.FloatValue, boomDmgType);

        if (!IsPlayerAlive(other))
        {
            // golpe letal: el doble Rouge vuela, el cadaver real queda
            // limpio (BecomeRagdoll NO aplica a players: su muerte ya
            // genera el cuerpo; solo la copia volada)
            Amy_OM_HammerFlingCopy(other, dir, false);
        }
        else if (OM_Stun(other, stun, client, 0.0, boomDmgType, true))
        {
            // LA PIEZA DEL OWNER: "este si es capaz de mandar a volar al
            // oponente" — stun + ragdoll falso lanzado con IMPULSO REAL
            // (Sonic_SpawnFlingRagdoll: motor v6.33 SetVelocity POR HUESO
            // + restauración vigilada + hueco seguro). El ragdoll solo si
            // el stun ATERRIZO (si el OM_Stun no entro por iframes,
            // esconderla igual dejaría un parpadeo sin sentido).
            Sonic_SpawnFlingRagdoll(other, dir);
        }

        EmitSoundToAll(AMY_OM_SND_THROW_HIT, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
        g_bAmyOMHammerHit[client] = true;
        PrintCenterText(client, "IMPACTO! %.1fs + vuela", stun);
        return true;
    }

    // --- witch / comunes (entities) ---
    if (other > MaxClients && IsValidEntity(other))
    {
        char cls[16];
        GetEntityClassname(other, cls, sizeof(cls));
        if (StrEqual(cls, "witch") && GetEntProp(other, Prop_Data, "m_iHealth") > 0)
        {
            float stun = 3.0 + Amy_OM_TarotStunBonus(client);
            if (stun < 0.5) stun = 0.5;

            // v105: mismas REGLAS GMOD de dirección que especiales
            float dir[3];
            bool grounded;
            Amy_OM_HammerHitDir(client, hammer, other, dir, grounded);

            Sonic_WitchStun(other, stun);
            Sonic_SpawnWitchRagdoll(other, dir);

            EmitSoundToAll(AMY_OM_SND_THROW_HIT, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
            g_bAmyOMHammerHit[client] = true;
            return true;
        }

        // --- comunes: dano y sigue rodando (el martillo atraviesa) ---
        // v106 (A): LA RECETA ROUGE v10.4 — la referencia que el owner
        // ya ve volar comunes a diario con el Barrido de Rouge. El v105
        // le escribía velocidad AL CUERPO tras el TakeDamage, pero un
        // común muerto tiene ragdoll de MUERTE DEL LADO CLIENTE en
        // L4D2: esa velocidad no la hereda nadie y el común se desploma
        // normal ("no reacciona"). La receta que vuela: copia
        // prop_ragdoll del cuerpo LANZADA con el impulso GMod
        // direccional + BecomeRagdoll en el común real + limpieza de
        // la copia a los 3s. Sobrevive al dano (mutaciones con HP
        // boost): empujon plano como el barrido de la bola.
        if (StrEqual(cls, "infected"))
        {
            float dir[3];
            bool grounded;
            Amy_OM_HammerHitDir(client, hammer, other, dir, grounded);

            // v107: OM_AbilityDamage = amplificador hibrido (x2 + % vs jefes)
            // v108: mismo tipo de dano del modo (bumeran = CORTE)
            OM_AbilityDamage(other, client, g_cvAmyOMThrowDmgCommon.FloatValue,
                             g_bAmyOMHammerBoom[client] ? DMG_SLASH : DMG_CLUB);

            if (IsValidEntity(other) && GetEntProp(other, Prop_Send, "m_iHealth") <= 0)
            {
                // murió con el golpe: el doble vuela (Rouge order)
                Amy_OM_HammerFlingCopy(other, dir, true);
            }
            else
            {
                // sobrevivio: empujon en vivo
                float fling = g_cvAmyOMThrowFling.FloatValue;
                float push[3];
                push[0] = dir[0] * fling;
                push[1] = dir[1] * fling;
                push[2] = dir[2] * fling;
                TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, push);
            }
            return true;
        }

        // --- v107: PROPS CON V (autos y demas) — EL BUFF DEL OWNER:
        // "el impacto del martillo podrá mover objetos (autos y demas,
        // como hace el aura del impacto de martillo de defensa)".
        // OJO: NINGÚN martillo lanzado (de ninguna Amy) se empuja a si
        // mismo ni se arma como auto (Amy_OM_HammerBlocksDamage) ---
        if (other != hammer && !Amy_OM_HammerBlocksDamage(other)
            && (StrContains(cls, "prop_") == 0 || StrEqual(cls, "func_physbox")))
        {
            if (!StrEqual(cls, "prop_dynamic")
                && !StrEqual(cls, "prop_dynamic_override")
                && !StrEqual(cls, "prop_ragdoll")
                && GetEntityMoveType(other) == MOVETYPE_VPHYSICS)
            {
                Amy_OM_HammerMoveProp(client, other, hammer);
                return true;
            }
        }
    }

    return false;
}

// v106 (A): COPIA RAGDOLL VOLADA — la receta Rouge v10.4 (Rouge_FlingRagdoll)
// tal cual, la única que YA vuela cuerpos en este server: copia
// prop_ragdoll del cuerpo en su posición exacta, lanzada con el impulso
// GMod direccional (Sonic_RagPhysLaunch por hueso; plan B motor puro
// Sonic_RagFlingEngine), y limpieza de la copia a los 3s.
//   - becomeRag=true  (comunes): AcceptEntityInput "BecomeRagdoll" en el
//     común real — su muerte queda limpia y es la copia la que vuela
//     (orden exacto del Barrido: TakeDamage -> health<=0 -> esto).
//   - becomeRag=false (especiales muertos con el golpe): el player ya
//     genera su propio cadaver al morir — solo la copia vuela.
// Velocidad = amyom_throw_fling (550) + elevación 0.55x (los números
// del Barrido: 500 + 300z) + giro 900 (el tumble por hueso).
void Amy_OM_HammerFlingCopy(int victim, const float dir[3], bool becomeRag)
{
    if (!IsValidEntity(victim)) return;

    // v106: players y entities exponen modelo/posición por lados
    // distintos (el player no tiene m_vecOrigin/m_angRotation en
    // Prop_Send — se lee por AbsOrigin/AbsAngles)
    char model[96];
    if (victim <= MaxClients)
        GetClientModel(victim, model, sizeof(model));
    else
        GetEntPropString(victim, Prop_Data, "m_ModelName", model, sizeof(model));
    if (model[0] == '\0') return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    float pos[3], ang[3];
    if (victim <= MaxClients)
    {
        GetClientAbsOrigin(victim, pos);
        GetClientAbsAngles(victim, ang);
    }
    else
    {
        GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
        GetEntPropVector(victim, Prop_Send, "m_angRotation", ang);
    }

    DispatchKeyValue(rag, "model", model);
    DispatchSpawn(rag);
    TeleportEntity(rag, pos, ang, NULL_VECTOR);

    float fling = g_cvAmyOMThrowFling.FloatValue;
    if (!Sonic_RagPhysLaunch(rag, dir, fling, fling * 0.55, 900.0))
        Sonic_RagFlingEngine(rag, dir, fling, fling * 0.55);

    if (becomeRag)
        AcceptEntityInput(victim, "BecomeRagdoll");

    CreateTimer(3.0, T_AmyOMHammerRagClean, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_AmyOMHammerRagClean(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// ============================================================================
//  v107 - AUTOS DEL MARTILLO: "ahora el impacto del martillo podrá mover
//  objetos (autos y demas), como hace el aura del impacto de martillo de
//  defensa... los autos que sean impactados y movidos: si impactan a un
//  especial los podrán en ragdoll por 4 seg (3 si es el tank) pero solo
//  aplicara 1 vez por movimiento, o sea por habilidad — si impacta una vez
//  y ya lo aturdio no lo volverá a aturdir. Lo podrá en ragdoll y lo
//  empujara" (owner, 2026-10-13).
//  Receta del EMPUJE = la del aura de defensa (golpe real v75 por masa +
//  despertador nativo v76 env_physexplosion) + el ARMADO: mientras el
//  auto este en movimiento dentro de la ventana (amyom_car_watch), el
//  primer especial/tank que roce lo deja en ragdoll (OM_Stun + doble
//  volador) + empujon en el rumbo del auto. 1 vez por auto por tiro.
// ============================================================================
void Amy_OM_HammerMoveProp(int client, int prop, int hammer)
{
    if (g_cvAmyOMThrowCars == null || !g_cvAmyOMThrowCars.BoolValue) return;
    if (!IsValidEntity(prop)) return;

    // rumbo del empujon: la velocidad del martillo (fallback Amy->prop)
    float dir[3], pos[3];
    GetEntPropVector(prop, Prop_Data, "m_vecOrigin", pos);
    dir[0] = 0.0; dir[1] = 0.0; dir[2] = 0.0;
    if (hammer > MaxClients && IsValidEntity(hammer))
        GetEntPropVector(hammer, Prop_Data, "m_vecVelocity", dir);
    float dlen = GetVectorLength(dir);
    if (dlen < 50.0)
    {
        float aPos[3];
        GetClientAbsOrigin(client, aPos);
        dir[0] = pos[0] - aPos[0];
        dir[1] = pos[1] - aPos[1];
        dir[2] = pos[2] - aPos[2];
        dlen = GetVectorLength(dir);
        if (dlen < 1.0) { dir[0] = 1.0; dlen = 1.0; }
    }
    dir[0] /= dlen; dir[1] /= dlen; dir[2] /= dlen;

    // LA RECETA DEL AURA (Amy_OM_CounterTriggerProp -> barrido de la
    // vieja Z -> Amy_PropRealHit + Amy_PropBlastWake): 1) liberar la
    // física 2) el golpe real (dano con FUERZA escalada por masa —
    // despierta al dormido) 3) el despertador nativo (env_physexplosion
    // con centro detraz-abajo: el empuje sale adelante+arriba)
    AcceptEntityInput(prop, "EnableMotion");
    AcceptEntityInput(prop, "Wake");
    Amy_PropRealHit(client, prop, dir, pos);
    Amy_PropBlastWake(prop, dir, pos);

    AmyDbg_Log("[MARTILLO v107] prop %d movido (auto/objeto con V); armado", prop);

    // y lo ARMA: si mientras se mueve roza a un especial -> ragdoll
    Amy_OM_CarArm(client, prop);
}

// v107: ARMAR un auto golpeado por el martillo (vigilia por ventana de
// tiempo; re-armar el mismo prop resetea su "1 vez")
void Amy_OM_CarArm(int client, int prop)
{
    int ref = EntIndexToEntRef(prop);
    float now = GetEngineTime();

    int slot = -1;
    for (int i = 0; i < AMY_OM_CARS_MAX; i++)
    {
        if (g_iAmyOMCarRef[i] != 0 && g_iAmyOMCarRef[i] == ref) { slot = i; break; }   // re-armar
        if (g_iAmyOMCarRef[i] != 0 && EntRefToEntIndex(g_iAmyOMCarRef[i]) <= 0)
            g_iAmyOMCarRef[i] = 0;   // ref reciclado: slot libre
        if (slot == -1 && g_iAmyOMCarRef[i] == 0) slot = i;
    }
    if (slot == -1) return;   // lleno

    g_iAmyOMCarRef[slot]  = ref;
    g_iAmyOMCarUser[slot] = GetClientUserId(client);
    g_fAmyOMCarUntil[slot] = now + g_cvAmyOMCarWatch.FloatValue;
    g_bAmyOMCarDone[slot] = false;

    if (g_hAmyOMCarWatch == null)
        g_hAmyOMCarWatch = CreateTimer(0.1, T_AmyOMCarWatch, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

// v107: LA VIGILIA (10 Hz) — un auto armado EN MOVIMIENTO que roza a un
// especial/tank lo deja en ragdoll (4s / 3s tank) + empujon en su rumbo.
// 1 VEZ POR AUTO POR LANZAMIENTO (g_bAmyOMCarDone). Muere sola sin autos.
public Action T_AmyOMCarWatch(Handle timer)
{
    float now = GetEngineTime();
    bool any = false;

    for (int i = 0; i < AMY_OM_CARS_MAX; i++)
    {
        if (g_iAmyOMCarRef[i] == 0) continue;

        int car = EntRefToEntIndex(g_iAmyOMCarRef[i]);
        if (car <= MaxClients || !IsValidEntity(car)
            || now >= g_fAmyOMCarUntil[i] || g_bAmyOMCarDone[i])
        {
            g_iAmyOMCarRef[i] = 0;   // expiro / ya aturdio / se esfumo
            continue;
        }
        any = true;

        // en movimiento? (un auto parado no aturde a nadie)
        float vel[3];
        GetEntPropVector(car, Prop_Data, "m_vecVelocity", vel);
        float spd = GetVectorLength(vel);
        if (spd < 150.0) continue;

        // radio del auto: mitad de la diagonal de su caja + margen
        float cPos[3];
        GetEntPropVector(car, Prop_Data, "m_vecOrigin", cPos);
        float rad = 80.0;
        if (HasEntProp(car, Prop_Data, "m_vecMins") && HasEntProp(car, Prop_Data, "m_vecMaxs"))
        {
            float mins[3], maxs[3];
            GetEntPropVector(car, Prop_Data, "m_vecMins", mins);
            GetEntPropVector(car, Prop_Data, "m_vecMaxs", maxs);
            float half[3];
            half[0] = (maxs[0] - mins[0]) * 0.5;
            half[1] = (maxs[1] - mins[1]) * 0.5;
            half[2] = (maxs[2] - mins[2]) * 0.5;
            float diag = GetVectorLength(half);
            if (diag > rad) rad = diag;
        }
        rad += 30.0;

        // el primer especial/tank que roce
        int amy = GetClientOfUserId(g_iAmyOMCarUser[i]);
        float dir[3];
        dir[0] = vel[0] / spd;
        dir[1] = vel[1] / spd;
        dir[2] = vel[2] / spd;

        for (int p = 1; p <= MaxClients; p++)
        {
            if (!IsClientInGame(p) || !IsPlayerAlive(p)) continue;
            if (GetClientTeam(p) != TEAM_INFECTED) continue;

            float o[3];
            GetClientAbsOrigin(p, o);
            o[2] += 40.0;
            if (GetVectorDistance(cPos, o) > rad) continue;

            // IMPACTO DEL AUTO: ragdoll 4s (3s tank) + empujon
            bool isTank = (GetEntProp(p, Prop_Send, "m_zombieClass") == 8);
            float dur = isTank ? g_cvAmyOMCarStunTank.FloatValue
                               : g_cvAmyOMCarStunSp.FloatValue;

            float fling = spd * 0.8;
            if (fling > 900.0) fling = 900.0;

            if (OM_Stun(p, dur, amy, 0.0, DMG_CLUB, true))
            {
                Sonic_SpawnFlingRagdollEx(p, dir, fling, 0.45, 900.0);
                if (amy > 0)
                    PrintCenterText(amy, "AUTO IMPACTO! %s en ragdoll %.1fs", isTank ? "Tank" : "Especial", dur);
            }
            else
            {
                // iframes del stun: al menos el empujon físico
                float push[3];
                push[0] = dir[0] * fling;
                push[1] = dir[1] * fling;
                push[2] = dir[2] * fling;
                TeleportEntity(p, NULL_VECTOR, NULL_VECTOR, push);
            }

            EmitSoundToAll(AMY_OM_SND_THROW_HIT, p, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
            g_bAmyOMCarDone[i] = true;   // "1 vez por movimiento" (owner)
            break;
        }
    }

    if (!any)
    {
        g_hAmyOMCarWatch = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// v106 (B): ENCOLAR impacto del Touch físico. NO procesar nada aquí —
// este callback corre DENTRO de la simulación vphysics y ahi el
// ragdoll falso no despega. Marca la victima en la lista de blandos
// (el scan 30 Hz no la re-procesa) y pide UN RequestFrame para la
// cola entera.
void Amy_OM_HammerHitQueue(int client, int other)
{
    if (g_iAmyOMHitPendN >= AMY_OM_HITPEND_MAX) return;
    Amy_OM_HammerSoftAdd(client, other);   // una vez por victima por lanzamiento
    g_iAmyOMHitPendRef[g_iAmyOMHitPendN]  = EntIndexToEntRef(other);
    g_iAmyOMHitPendUser[g_iAmyOMHitPendN] = GetClientUserId(client);
    g_iAmyOMHitPendN++;
    if (!g_bAmyOMHitPendFrame)
    {
        g_bAmyOMHitPendFrame = true;
        RequestFrame(Amy_OM_HammerHitFlush);
    }
}

// v106 (B): FLUSH de la cola — frame SIGUIENTE al toque, FUERA de la
// simulación vphysics: el MISMO contexto de timer desde el que el
// spindash y el Barrido lanzan sus ragdolls a diario.
public void Amy_OM_HammerHitFlush(any data)
{
    g_bAmyOMHitPendFrame = false;
    int n = g_iAmyOMHitPendN;
    g_iAmyOMHitPendN = 0;

    for (int k = 0; k < n; k++)
    {
        int client = GetClientOfUserId(g_iAmyOMHitPendUser[k]);
        if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) continue;

        int other = EntRefToEntIndex(g_iAmyOMHitPendRef[k]);
        if (other <= 0 || !IsValidEntity(other)) continue;

        // el prop puede haberse recuperado/esfumado entre el toque y
        // este frame: HitDir tiene guard (fallback Amy->victima)
        int hammer = (g_iAmyOMHammerProp[client] != 0) ? EntRefToEntIndex(g_iAmyOMHammerProp[client]) : -1;
        if (hammer <= MaxClients || !IsValidEntity(hammer)) hammer = 0;

        Amy_OM_HammerHitTarget(client, other, hammer);
    }
}

// TOQUE del martillo: la colisión FÍSICA real del hammer.mdl (v96: el
// nucleo del impacto vive en Amy_OM_HammerHitTarget, compartido con el
// scan del hitbox ampliado)
public Action Amy_OM_HammerTouch(int entity, int other)
{
    // de quien es este martillo
    int client = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iAmyOMHammerProp[i] != 0 && EntRefToEntIndex(g_iAmyOMHammerProp[i]) == entity)
        {
            client = i;
            break;
        }
    }
    if (client == 0) return Plugin_Continue;
    if (other <= 0 || other == client) return Plugin_Continue;
    if (!IsClientInGame(client)) return Plugin_Continue;

    // en vuelo de retorno no golpea a nadie (va a la mano)
    if (g_bAmyOMHammerReturning[client]) return Plugin_Continue;

    // v105 FIX 2 (cinturon 3 de 3): el martillo JAMÁS procesa toque de
    // juego contra el EQUIPO (survivors) — ni dano de toque ni lógica:
    // el vphysics resuelve el rebote físico igual, y el dano ya murió
    // en los cinturones 1 (m_impactEnergyScale 0) y 2 (hook PROPS
    // AMIGOS). Amy y company pueden bloquear el martillo con el
    // cuerpo sin pagar nada.
    if (other <= MaxClients && IsClientInGame(other)
        && GetClientTeam(other) == TEAM_SURVIVOR)
        return Plugin_Handled;

    // v106 (B): EL IMPACTO YA NO SE PROCESA AQUÍ. Este callback corre
    // DENTRO de la simulación vphysics del martillo — spawnear,
    // despertar y lanzar el ragdoll falso ahi no despega (el v105 lo
    // hacia inline y el enemigo "no reaccionaba": stun si, vuelo
    // nunca; el spindash y el Barrido de Rouge lanzan SIEMPRE desde
    // timer/think, nunca desde un touch físico). Se ENCOLA y el flush
    // del RequestFrame lo procesa el frame siguiente, fuera de la
    // simulación. El rebote físico del vphysics sigue intacto
    // (Plugin_Continue = mismo comportamiento de siempre).
    Amy_OM_HammerHitQueue(client, other);
    return Plugin_Continue;
}

// v105: es <ent> el prop del MARTILLO LANZADO de alguna Amy viva?
// (lo invoca Amy_PropBlocksSurvivorDamage — cinturon 2 — para que el
// dano de colisión física vanilla del martillo jamás toque a un
// survivor; el EntRef por jugador es la identidad, index reciclado
// no engana)
bool Amy_OM_HammerBlocksDamage(int ent)
{
    if (ent <= MaxClients || !IsValidEntity(ent)) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iAmyOMHammerProp[i] == 0) continue;
        if (EntRefToEntIndex(g_iAmyOMHammerProp[i]) == ent) return true;
    }
    return false;
}

// v96: registro de blandos del hitbox ampliado (cada victima solo 1
// vez por lanzamiento — evita re-stun/re-dano cada 30 ms en radio)
bool Amy_OM_HammerSoftHas(int client, int ent)
{
    int ref = EntIndexToEntRef(ent);
    for (int i = 0; i < g_iAmyOMHammerSoftN[client]; i++)
        if (g_iAmyOMHammerSoft[client][i] == ref) return true;
    return false;
}

void Amy_OM_HammerSoftAdd(int client, int ent)
{
    if (g_iAmyOMHammerSoftN[client] >= AMY_OM_HITSOFT_MAX) return;
    g_iAmyOMHammerSoft[client][g_iAmyOMHammerSoftN[client]++] = EntIndexToEntRef(ent);
}

// v107: ARRANQUE DEL RETORNO (extraido del Tick — ahora lo llaman el
// failsafe de los 8s Y el bumeran al llegar a su distancia). En modo
// bumeran el SCAN SIGUE VIVO durante la vuelta (golpea en ida Y
// vuelta, con el registro de blandos LIMPIO para que la vuelta pueda
// re-golpear a los mismos); el clasico lo mata como siempre.
void Amy_OM_HammerReturnStart(int client)
{
    int hammer = (g_iAmyOMHammerProp[client] != 0) ? EntRefToEntIndex(g_iAmyOMHammerProp[client]) : -1;
    float now = GetEngineTime();

    g_bAmyOMHammerReturning[client] = true;
    g_fAmyOMHammerRetStart[client] = now;
    if (hammer > MaxClients && IsValidEntity(hammer))
        GetEntPropVector(hammer, Prop_Data, "m_vecOrigin", g_fAmyOMHammerRetFrom[client]);
    else
        g_fAmyOMHammerRetFrom[client] = g_fAmyOMHammerBoomPos[client];

    if (g_bAmyOMHammerBoom[client])
    {
        // bumeran: la vuelta también golpea — registro limpio + scan vivo
        g_iAmyOMHammerSoftN[client] = 0;
    }
    else if (g_hAmyOMHammerScan[client] != null)
    {
        delete g_hAmyOMHammerScan[client];
        g_hAmyOMHammerScan[client] = null;
    }

    // GMod: SetSolid(0) + MOVETYPE_NOCLIP — vuela a ella sin
    // empujar a nadie por el camino
    if (hammer > MaxClients && IsValidEntity(hammer))
    {
        SetEntProp(hammer, Prop_Data, "m_CollisionGroup", 2);   // DEBRIS
        if (HasEntProp(hammer, Prop_Send, "m_CollisionGroup"))
            SetEntProp(hammer, Prop_Send, "m_CollisionGroup", 2);
        SetEntityMoveType(hammer, MOVETYPE_NOCLIP);
        SetEntPropVector(hammer, Prop_Data, "m_vecVelocity", view_as<float>({0.0, 0.0, 0.0}));
    }

    if (g_hAmyOMHammerFly[client] != null)
        delete g_hAmyOMHammerFly[client];
    g_hAmyOMHammerFly[client] = CreateTimer(0.03, T_AmyOMHammerFly, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

// v107: EL VUELO DE IDA DEL BUMERAN (30 Hz, llamado desde el scan):
// mantiene el rumbo RECTO re-afirmando la velocidad (gravedad y
// rozamiento pisados) y da la vuelta al llegar a amyom_boom_dist o al
// frenarse 3 ticks seguidos contra algo duro (pared/techo — un común
// lo frena 1-2 ticks y el re-afirmar lo re-lanza: no lo confunde).
// Devuelve true = sigue en ida.
// v108: LA ROTACION DE VERDAD — pedido del owner: "El boomeran debe
// hacer rotar el martillo, o sea debe girar como un bommeran, no estar
// tieso en el aire". El giro del v107 viajaba al IPhysicsObject
// (Sonic_PhysSetVel) y no se veía. Ahora se usa LA RECETA DEL VUELO
// DE RETORNO, que ya se ve girando desde la v92: TeleportEntity con
// el yaw avanzando amyom_boom_spin grados/s. El Teleport de una
// entidad física hace DOS cosas en el motor (baseentity.cpp L4296+):
//   (a) pPhys->SetVelocity(vel, NULL)   -> la velocidad lineal queda
//       re-afirmada (gravedad/rozamiento pisados; el giro NO se toca)
//   (b) pPhys->SetPosition(origin, ang) -> EL OBJETO FÍSICO ADOPTA EL
//       ANGULO — la rotación escrita es la que se ve, sin depender del
//       SDKCall ni de unidades de vphysics
// Un SOLO call por tick hace vuelo + giro. El dt es el REAL (el timer
// de 30 Hz dispara en el tick del motor más cercano: 0.033/0.050/...).
bool Amy_OM_BoomDrive(int client, int hammer)
{
    float pos[3], vel[3];
    GetEntPropVector(hammer, Prop_Data, "m_vecOrigin", pos);
    GetEntPropVector(hammer, Prop_Data, "m_vecVelocity", vel);

    // (1) distancia de ida (plana: el rumbo puede llevar Z)
    float dx = pos[0] - g_fAmyOMHammerBoomPos[client][0];
    float dy = pos[1] - g_fAmyOMHammerBoomPos[client][1];
    float dist = SquareRoot(dx * dx + dy * dy);

    // (2) freno sostenido = pared/techo (3 ticks = 0.09s)
    if (GetVectorLength(vel) < 260.0) g_iAmyOMHammerSlowN[client]++;
    else                              g_iAmyOMHammerSlowN[client] = 0;

    if (dist >= g_cvAmyOMBoomDist.FloatValue || g_iAmyOMHammerSlowN[client] >= 3)
    {
        Amy_OM_HammerReturnStart(client);
        return false;
    }

    // (3) GIRO: yaw acumulado con dt real (wrap 360 como el retorno)
    float now = GetEngineTime();
    float dt = now - g_fAmyOMBoomLastT[client];
    if (dt <= 0.0 || dt > 0.25) dt = 0.03;   // primer tick o lag spike
    g_fAmyOMBoomLastT[client] = now;

    float spinRate = (g_cvAmyOMBoomSpin != null) ? g_cvAmyOMBoomSpin.FloatValue : 720.0;
    g_fAmyOMBoomYaw[client] += spinRate * dt;
    if (g_fAmyOMBoomYaw[client] >= 360.0)
        g_fAmyOMBoomYaw[client] -= 360.0 * RoundToFloor(g_fAmyOMBoomYaw[client] / 360.0);
    else if (g_fAmyOMBoomYaw[client] < 0.0)
        g_fAmyOMBoomYaw[client] += 360.0 * RoundToCeil(-g_fAmyOMBoomYaw[client] / 360.0);

    // (4) VUELO + ROTACION en UN call: velocidad re-afirmada (pisa
    // gravedad/rozamiento) + el angulo del giro plano. pitch = el del
    // lanzamiento (el plano del giro), yaw = el acumulado, roll 0
    float p = g_cvAmyOMThrowPower.FloatValue;
    float fixed[3];
    fixed[0] = g_fAmyOMHammerBoomDir[client][0] * p;
    fixed[1] = g_fAmyOMHammerBoomDir[client][1] * p;
    fixed[2] = g_fAmyOMHammerBoomDir[client][2] * p;

    float boomAng[3];
    boomAng[0] = g_fAmyOMBoomPitch[client];
    boomAng[1] = g_fAmyOMBoomYaw[client];
    boomAng[2] = 0.0;
    TeleportEntity(hammer, NULL_VECTOR, boomAng, fixed);
    return true;
}

// v96: SCAN 30 HZ del vuelo de IDA — LA HITBOX 35% MAYOR QUE SU
// CUERPO (amyom_throw_hitbox): esfera centrada en el martillo de
// radio = multiplicador x mitad de la diagonal de su bounding box (+
// el casco aproximado del objetivo). Aplica EXACTAMENTE los mismos
// efectos que el Touch físico (stun+ragdoll a especiales/witch, dano
// a comunes). Muere sola al recuperar/morir el martillo. v107: en
// modo bumeran también vive durante la VUELTA (golpea ida y vuelta)
// y lleva el FLIGHT DRIVE de la ida.
public Action T_AmyOMHammerScan(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)
        || g_iAmyOMHammerProp[client] == 0)
    {
        if (client > 0) g_hAmyOMHammerScan[client] = null;
        return Plugin_Stop;
    }

    // v107: el RETORNO ya no golpea en el clasico (como siempre); el
    // bumeran SIGUE golpeando en su vuelta (el scan de esfera no
    // necesita colisión física — el martillo va en NOCLIP)
    if (g_bAmyOMHammerReturning[client] && !g_bAmyOMHammerBoom[client])
    {
        g_hAmyOMHammerScan[client] = null;
        return Plugin_Stop;
    }

    int hammer = EntRefToEntIndex(g_iAmyOMHammerProp[client]);
    if (hammer <= MaxClients || !IsValidEntity(hammer))
    {
        g_hAmyOMHammerScan[client] = null;
        return Plugin_Stop;
    }

    // v107: FLIGHT DRIVE del bumeran (ida recta + giro plano + vuelta
    // por distancia/pared). Solo en la ida — la vuelta va por su
    // propio timer (el lerp del GMod).
    if (g_bAmyOMHammerBoom[client] && !g_bAmyOMHammerReturning[client])
        Amy_OM_BoomDrive(client, hammer);

    float hc[3];
    GetEntPropVector(hammer, Prop_Data, "m_vecOrigin", hc);
    float range = g_fAmyOMHammerHitR[client] + AMY_OM_HULL_R;

    // --- especiales / tank (players equipo 3) ---
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client || Amy_OM_HammerSoftHas(client, i)) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float o[3];
        GetClientAbsOrigin(i, o);
        o[2] += 40.0;   // pecho (mismo criterio del barrido)
        if (GetVectorDistance(hc, o) > range) continue;

        if (Amy_OM_HammerHitTarget(client, i, hammer))
            Amy_OM_HammerSoftAdd(client, i);
    }

    // --- witch + comunes (entities) ---
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (Amy_OM_HammerSoftHas(client, ent)) continue;
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;

        float o[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", o);
        o[2] += 40.0;
        if (GetVectorDistance(hc, o) > range) continue;

        if (Amy_OM_HammerHitTarget(client, ent, hammer))
            Amy_OM_HammerSoftAdd(client, ent);
    }

    ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (Amy_OM_HammerSoftHas(client, ent)) continue;
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;

        float o[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", o);
        o[2] += 40.0;
        if (GetVectorDistance(hc, o) > range) continue;

        if (Amy_OM_HammerHitTarget(client, ent, hammer))
            Amy_OM_HammerSoftAdd(client, ent);
    }

    // --- v107: PROPS CON V (autos y demas) — el buff del owner: el
    // impacto del martillo los MUEVE (receta del aura de defensa) y
    // los arma (si rozan a un especial en movimiento: ragdoll).
    // Solo en la IDA (en la vuelta va NOCLIP a la mano); el registro
    // de blandos evita re-golpear el mismo auto cada 30 ms. OJO: el
    // MARTILLO MISMO es un prop_physics_override — queda excluido
    // (sin esto se empujaría a si mismo y se armaria como auto) ---
    if (!g_bAmyOMHammerReturning[client])
    {
        for (int c = 0; c < AMY_PROP_CLASSES; c++)
        {
            ent = -1;
            while ((ent = FindEntityByClassname(ent, g_sAmyPropClasses[c])) != -1)
            {
                if (ent == hammer || Amy_OM_HammerBlocksDamage(ent)) continue;   // martillos: FUERA
                if (Amy_OM_HammerSoftHas(client, ent)) continue;
                if (!IsValidEntity(ent)) continue;
                if (GetEntityMoveType(ent) != MOVETYPE_VPHYSICS) continue;   // sin V: no existe (receta v82)

                float o[3];
                GetEntPropVector(ent, Prop_Data, "m_vecOrigin", o);
                if (GetVectorDistance(hc, o) > range + 30.0) continue;   // los autos son GRANDES: margen

                if (Amy_OM_HammerHitTarget(client, ent, hammer))
                    Amy_OM_HammerSoftAdd(client, ent);
            }
        }
    }

    return Plugin_Continue;
}

// recogida + retorno del martillo (10 Hz desde PhaseThink)
void Amy_OM_HammerTick(int client, float now)
{
    int hammer = (g_iAmyOMHammerProp[client] != 0) ? EntRefToEntIndex(g_iAmyOMHammerProp[client]) : -1;
    if (hammer <= MaxClients || !IsValidEntity(hammer))
    {
        // el prop se esfumo (killall, cambio de capítulo...): martillo
        // de vuelta sin drama
        Amy_OM_HammerRecover(client, false);
        return;
    }

    float age = now - g_fAmyOMHammerBorn[client];

    // ---- recogida por cercania (GMod: E a 140u tras 1s de gracia) ----
    if (age > 1.0 && !g_bAmyOMHammerReturning[client])
    {
        float hPos[3], aPos[3];
        GetEntPropVector(hammer, Prop_Data, "m_vecOrigin", hPos);
        GetClientAbsOrigin(client, aPos);
        if (GetVectorDistance(hPos, aPos) <= g_cvAmyOMThrowGrab.FloatValue)
        {
            // que este más o menos quieto (no pasarse por encima a 2000)
            float vel[3];
            GetEntPropVector(hammer, Prop_Data, "m_vecVelocity", vel);
            if (GetVectorLength(vel) < 300.0)
            {
                Amy_OM_HammerRecover(client, false);
                return;
            }
        }
    }

    // ---- retorno solo a los 8s (GMod: timer 8s + FlyToPlayer) ----
    // v107: el bloque vive en Amy_OM_HammerReturnStart (el bumeran lo
    // invoca al llegar a su distancia; esto queda como FAILSAFE)
    if (age >= g_cvAmyOMThrowReturn.FloatValue && !g_bAmyOMHammerReturning[client])
    {
        Amy_OM_HammerReturnStart(client);
    }
}

// el vuelo del retorno (30 Hz — el arco con balanceo y giro del GMod)
public Action T_AmyOMHammerFly(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || g_hAmyOMHammerFly[client] == null)
        return Plugin_Stop;
    if (!g_bAmyOMHammerReturning[client]) { g_hAmyOMHammerFly[client] = null; return Plugin_Stop; }

    int hammer = (g_iAmyOMHammerProp[client] != 0) ? EntRefToEntIndex(g_iAmyOMHammerProp[client]) : -1;
    if (hammer <= MaxClients || !IsValidEntity(hammer))
    {
        // (patron suite: null + Plugin_Stop desde DENTRO; el handle lo
        // cierra el sistema al morir el timer)
        g_hAmyOMHammerFly[client] = null;
        Amy_OM_HammerDoRecover(client, false);
        return Plugin_Stop;
    }
    if (!IsPlayerAlive(client))
    {
        g_hAmyOMHammerFly[client] = null;
        Amy_OM_HammerKill(client);
        return Plugin_Stop;
    }

    float now = GetEngineTime();
    float frac = (now - g_fAmyOMHammerRetStart[client]) / AMY_OM_THROW_RETURN_T;
    if (frac > 1.0) frac = 1.0;

    // LerpVector + arco sin (GMod FlyToPlayer)
    float target[3], pos[3];
    GetClientAbsOrigin(client, target);
    pos[0] = g_fAmyOMHammerRetFrom[client][0] + (target[0] - g_fAmyOMHammerRetFrom[client][0]) * frac;
    pos[1] = g_fAmyOMHammerRetFrom[client][1] + (target[1] - g_fAmyOMHammerRetFrom[client][1]) * frac;
    pos[2] = g_fAmyOMHammerRetFrom[client][2] + (target[2] - g_fAmyOMHammerRetFrom[client][2]) * frac
             + Sine(frac * FLOAT_PI) * AMY_OM_THROW_RETURN_ARC;

    // apuntando a ella + giro continuo (GMod: spin 720 grados/s)
    float dir[3];
    dir[0] = target[0] - pos[0]; dir[1] = target[1] - pos[1]; dir[2] = target[2] - pos[2];
    float dlen = GetVectorLength(dir);
    if (dlen < 1.0) dlen = 1.0;
    dir[0] /= dlen; dir[1] /= dlen; dir[2] /= dlen;

    float ang[3];
    ang[1] = RadToDeg(ArcTangent2(dir[1], dir[0]));
    ang[0] = -RadToDeg(ArcTangent2(dir[2], SquareRoot(dir[0]*dir[0] + dir[1]*dir[1])));
    static float spinAcc = 0.0;
    spinAcc += AMY_OM_THROW_RETURN_SPIN * 0.03;
    if (spinAcc > 360.0) spinAcc -= 360.0 * RoundToFloor(spinAcc / 360.0);
    ang[2] = spinAcc;

    TeleportEntity(hammer, pos, ang, NULL_VECTOR);

    if (frac >= 1.0)
    {
        g_hAmyOMHammerFly[client] = null;
        Amy_OM_HammerDoRecover(client, true);
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// martillo de vuelta a la mano (GMod amy_om_hammerUse / fin del
// FlyToPlayer): prop fuera, estados limpios, EndLag 0.85s.
// Versión SIN tocar el timer (la invoca el propio T_AmyOMHammerFly)
void Amy_OM_HammerDoRecover(int client, bool fromFlight)
{
    Amy_OM_HammerKill(client);

    g_bAmyOMNoHammer[client] = false;
    Amy_OM_AvatarChains(client, false);   // v93: chains 0 = el martillo VUELVE al modelo
    g_fAmyOMEndLagUntil[client] = GetEngineTime() + AMY_OM_ENDLAG;

    EmitSoundToAll(AMY_OM_SND_RETRACT, client, SNDCHAN_WEAPON, SNDLEVEL_NORMAL);
    if (fromFlight)
        PrintCenterText(client, "Martillo de vuelta! (EndLag %.2fs)", AMY_OM_ENDLAG);
    else
        PrintCenterText(client, "Martillo recuperado! (EndLag %.2fs)", AMY_OM_ENDLAG);
}

// versión COMPLETA (fuera del timer: recogida por cercania o prop
// perdido): primero mata el vuelo pendiente, luego recupera
void Amy_OM_HammerRecover(int client, bool fromFlight)
{
    if (g_hAmyOMHammerFly[client] != null)
    {
        Handle h = g_hAmyOMHammerFly[client];
        g_hAmyOMHammerFly[client] = null;
        if (h != null) KillTimer(h);
    }
    Amy_OM_HammerDoRecover(client, fromFlight);
}

// mata el prop del martillo + su trail (todos los caminos de fin)
void Amy_OM_HammerKill(int client)
{
    // v96: también muere el scan del hitbox ampliado y su registro
    if (g_hAmyOMHammerScan[client] != null)
        delete g_hAmyOMHammerScan[client];
    g_hAmyOMHammerScan[client] = null;
    g_iAmyOMHammerSoftN[client] = 0;

    // v6.18/v100: el trail es un slot TE del motor de sonic.inc (el
    // BeamFollow muere solo en <=0.3s; aquí solo se libera el slot)
    Sonic_TEStop(g_iAmyOMHammerTrail[client]);

    if (g_iAmyOMHammerProp[client] != 0)
    {
        int hammer = EntRefToEntIndex(g_iAmyOMHammerProp[client]);
        if (hammer > MaxClients && IsValidEntity(hammer))
        {
            SDKUnhook(hammer, SDKHook_Touch, Amy_OM_HammerTouch);
            AcceptEntityInput(hammer, "Kill");
        }
    }
    g_iAmyOMHammerProp[client] = 0;
    g_bAmyOMHammerReturning[client] = false;
    g_bAmyOMNoHammer[client] = false;
    // v93: todo camino que mate el martillo lo devuelve a la mano del
    // modelo (muerte, limpieza, prop perdido) — como el GMod
    Amy_OM_AvatarChains(client, false);
}

