/*
 * ======================================================
 *  [MODULO] Tails "Miles" Prower - Support & Utility v5.28
 *                          "OM PARITY" (Outcome Memories GMod)
 *
 *  v5.21 "PULSO BLINDADO + SC PAUSA" (2026-10-18, manager v3.77.89,
 *  pedido del owner: "el l4 se pause en multiples ocasiones... hace falta
 *  una optimizacion que sea optima (algo fuerte)" + "SC necesita opcion
 *  de peticion/disparador de pausa (salida del saferoom y otros
 *  momentos): la pausa debe conservarse porque al atravesar modelos se
 *  desincronizan los locales y queda chueco el cuerpo"). TRES piezas:
 *  (1) RATE LIMITER del motor de pulsos: separacion minima entre INICIOS
 *  de pulso (tails_pausefix_spacing, default 2s) — una cadena de montajes
 *  ya no genera pause/unpause en rafaga (la causa del "se pause en
 *  multiples ocasiones": montaje L fallando = trigger INCONDICIONAL cada
 *  0.1s + refuerzos de la FSM en cadena); (2) FIX del trigger L: el
 *  pulso tras el montaje tardio de la copia L ahora se pide SOLO si el
 *  montaje EXISTIO (el patron de Amy/Blaze) + BACKOFF de reintentos de
 *  auto-montaje R/L (0.1s*< fallos, tope 1s: un spawn rechazado ya no
 *  revienta a 10 Hz para siempre); (3) API PUBLICA Tails_PF_RequestPulse
 *  para el sistema SC PAUSA del manager (salida del saferoom, conexion a
 *  media ronda, sm_scpausa manual) — mismo motor Zero-Net v5.20.7 (100%
 *  server-side, respeta sv_pausable), mismo rate limiter, sin pasar por
 *  el gate de tails_pausefix (las peticiones explicitas tienen su propio
 *  master: sc_pausa). SIN TOCAR NINGUN FX: EF_NOINTERP, MarkInterp,
 *  trails, avatares, HUD intactos.
 *
 *  v5.27 "STUN UNIFICADO" (2026-10-09, pedido del owner: "no es
 *  mejor unificar ambos stun en un solo documento? ... en si tenemos
 *  ragdoll y el stun de congelamiento y empuje (tails) pero lo que no
 *  tiene el stun de tails es las estrellas ... mejor unifiquemos ese
 *  sistema para ir simplificando todo y no gastemos tanto codigo en
 *  la misma cosa"). El sistema de congelado del rayo (Tails_SIFreeze*:
 *  ~400 lineas paralelas desde el v5.22) SE FUSIONA con el OM_Stun
 *  v2.0 — el MISMO documento del stun de Sonic/Amy/Metal: freeze
 *  estatua (martillo + lagged + pausa de animacion) + ESTRELLAS (lo
 *  que le faltaba al rayo) + chispas + zap + arrastre por el haz
 *  (OM_Stun_Push, fisica Witch_Flight) + stagger al liberar. Flags
 *  del rayo: CYAN/PUSH/STAGGER/FIXED (el contador NUNCA se
 *  reinicia)/NOIFRAME. Comportamiento identico, un solo sistema para
 *  todo el suite.
 *
 *  v5.25 "AVATAR REMOTO POR TP" (2026-10-08, pedido del owner:
 *  "el sistema de avatar es excelente... es posible que cuando mire
 *  a los avatares DE OTROS usen el sistema del tails follow, o sea
 *  modo TP? localmente que siga igual (con su pausa)... si veo a un
 *  compañero se ve mal: la pausa no recalcula lo que YO veo de EL,
 *  aunque en SU pantalla se vea bien"). Diagnostico: la pausa solo
 *  re-encaja el estado del cliente DUEÑO; la copia R que viaja a los
 *  demas llega rota de fabrica (parent + EF_NOINTERP = sin historial
 *  de interpolacion: a tirones). FIX: la copia R de TODOS los
 *  avatares del suite (Tails/Sonic/Amy — un solo sistema, como
 *  tails_pausefix) pasa al modo TP probado del tails_follow: SIN
 *  parent, TeleportEntity por tick en pose mundo (pos + yaw del
 *  cuerpo) + reloj vivo v5.9.1 y SIN EF_NOINTERP -> cada cliente la
 *  INTERPOLA como a cualquier entidad = suave siempre, pausa o no.
 *  La copia L del dueño NO se toca (parentada + EF_NOINTERP + pulso:
 *  "localmente igual"). Convar tails_avatar_tp (default 1; 0 = R
 *  parentada como antes; el cambio en vivo recrea en <=0.1s). La
 *  bola del spin de Sonic QUEDA PARENTADA (la mira su dueño en
 *  pantalla propia) y durante la bola la R oculta viaja pegada por
 *  TP para reaparecer en su sitio al terminar.
 *
 *  v5.22 "CONGELADO TOTAL + SALTO HERIDO" (2026-10-06, pedidos
 *  textuales del owner: "cuando tails esta haciendo su animacion de
 *  erido ya no usa su animacion de jump restaurasela" y "para el
 *  stun que se usa en la witch aplicasela a todos los infectados
 *  especiales"). TRES cambios:
 *   1) SALTO HERIDO (arreglo Poppy v2): la FSM vieja ponia la rama
 *      LowHealth (HP <= 60) POR ENCIMA de la rama de AIRE — un Tails
 *      herido que saltaba se quedaba en las anims de SUELO del
 *      LowHealth (Idle_LowHealth/Walk/Run_lowhealth en pleno vuelo)
 *      y "ya no usaba su animacion de jump". Ahora el AIRE gana al
 *      herido: en el aire SIEMPRE jump/fall (el mdl no tiene anims
 *      lowhealth de aire: en GMod OM el salto herido tambien es el
 *      jump normal); el LowHealth queda como variante de SUELO
 *      (parado/caminando/corriendo), como siempre. La ventana del
 *      fix Poppy v5.20 (jump completo 0.5s-1.5s) aplica igual.
 *   2) CONGELADO DE INFECTADOS ESPECIALES: el stun que se usaba en
 *      la witch (FL_FROZEN + MOVETYPE_NONE + integracion manual del
 *      empuje, receta Witch_Flight) ahora le cae a TODOS los SI
 *      (smoker/boomer/hunter/spitter/jockey/charger/TANK; la witch
 *      sigue con su sistema propio de siempre). Reglas del owner,
 *      tal cual: PRIMER toque del rayo = congelado 6s FIJOS (el rayo
 *      NUNCA reinicia el contador: "aun si solo le pego por un
 *      instante"), el rayo PUEDE seguir empujandolo mientras esta
 *      congelado (velocidad manual integrada por el ticker: se lo
 *      lleva por el haz como a la witch) pero el tiempo no se
 *      mueve, y al terminar el congelamiento SIEMPRE cae un stagger
 *      al descongelarse (SIStagger_Auto). Muerto congelado =
 *      restauracion limpia sin stagger. El acumulador de stagger
 *      1.5s/2.5s (v4.3) se RETIRA: su trabajo lo hace el descongelar.
 *      Convars: tails_sifreeze (1/0) y tails_sifreeze_duration (6).
 *   3) BUFFS DEL RAYO: duracion 3.75 -> 5.0s (tails_cannon_firetime)
 *      y dano 35/seg (tails_laser_damage 3.5 por tick de 0.1s).
 *      OJO: el auto-guardado de Sonic_Suite.cfg PISA los defaults
 *      nuevos si el server ya tiene esos cvars grabados — usar
 *      sm_cvar (se auto-graba) o borrar las lineas del cfg.
 *      El WAV del loop dura 3.75s: con rayo de 5s se re-emite a los
 *      3.6s para que el sonido no se muera antes que el rayo.
 *
 *  v5.20.6 "PULSO DE PAUSA REAL" (2026-10-06, pedido del owner:
 *  "no hace falta que te inventes nada, usemos el coso este").
 *  El fix ES el pause, automatico e invisible. El servidor hace UNA
 *  pausa momentanea (tails_pausefix_duration, default 0.1s): el
 *  cliente re-sincroniza el estado de la entidad de arriba abajo y
 *  el avatar queda encajado — exactamente lo que el owner comprobo
 *  a mano con sv_pausable 1 + pause. sv_pausable queda FORZADO a 1
 *  (config obligatoria: arranque, cada mapa, cada ronda, y
 *  re-reforzado antes de cada pulso).
 *  v5.24 (pedido del owner: "yo no te pedi que le quitaras lo del
 *  respawn sc y demas todo eso estaba bn RESTAURALOS"): el gate de
 *  la v5.23 se RETIRA ENTERO. El pulso vuelve a dispararse en CADA
 *  montaje del avatar — spawn de ronda, !sc, respawn y
 *  auto-reparacion de la FSM — exactamente como estaba en la v5.22
 *  (que estaba bien: el owner lo confirmo). La FSM de pulsos, la
 *  cola de refuerzo y el sv_pausable forzado quedan intactos.
 *  INGENIERIA: `pause` solo existe como comando de CLIENTE que el
 *  server honra con sv_pausable 1 — no hay comando de server para
 *  pausar. El pulso se le pide al dueño del avatar via ClientCommand
 *  (la MISMA ruta que escribirlo a mano) y se VERIFICA mirando si
 *  el reloj del juego (GetGameTime) se congelo; si no cuaja hay
 *  reintentos (ultima via FakeClientCommand, server-side) y un
 *  unpause escalonado con LogError de escape si nada funciona.
 *  TODO el control corre en OnGameFrame con GetEngineTime (tiempo
 *  REAL, avanza incluso en pausa): los timers de SourceMod corren
 *  con el reloj DEL JUEGO — con el server en pausa ese reloj esta
 *  congelado y un timer JAMAS soltaria la pausa. Cvars nuevos:
 *  tails_pausefix (1/0), tails_pausefix_delay (default 0.2s: hay
 *  que dejar que el cliente RECIBA el avatar antes de pausar, si
 *  no no hay nada que re-encajar) y tails_pausefix_duration
 *  (default 0.1s, imperceptible).
 *
 *  v5.20.5 "NACE ENCAJADO / FIX DEL PAUSE" (2026-10-06, forense del
 *  owner con sv_pausable): el owner descubrio en campo que `pause`
 *  (sv_pausable 1) cura el tilt de frente a camara POR EL RESTO DE LA
 *  PARTIDA (y `!sc`, que recrea el avatar, lo reintroduce al instante).
 *  Eso cambia el diagnostico completo: el bug NO es la matematica del
 *  yaw local (por eso el unwrap v5.20.4 no cambio nada) — es un ESTADO
 *  CLIENTE de la ENTIDAD avatar sembrado al nacer (el historial de
 *  interpolacion con el que el cliente monta el prop desde el primer
 *  snapshot + su reloj m_flSimulationTime clavado en el spawn, porque
 *  un prop parentado no simulado nunca lo avanza solo), estado que la
 *  pausa re-sincroniza de arriba abajo ("re-encaja") y que la entidad
 *  nueva vuelve a sembrar. FIX (modo parentado, copias R y L):
 *   1) EF_NOINTERP (0x40) en m_fEffects al crear el avatar: el cliente
 *      renderiza SIEMPRE el ultimo valor recibido, sin historial que
 *      ensuciar ni frontera +/-180 que cruzar = el avatar NACE ya
 *      encajado, como si hubiera pasado por pause. La suavidad no se
 *      pierde: el smoothing ya lo hace el SERVER (tails_angdamp /
 *      tails_leadsmooth, v5.17-A) y la POSICION sigue 100% a cargo del
 *      motor via el parent (la interpolacion del survivor NO se toca).
 *   2) RELOJ VIVO: cada write del m_angRotation estampa el reloj
 *      m_flSimulationTime con Tails_MarkInterp (la estampa ENTERA del
 *      v5.9.1 que ya usaba el modo teleport; el SendProp de L4D2 es
 *      DPT_Int — float lanza error runtime). Un prop parentado no
 *      simulado nunca avanza ese reloj solo: quedaba clavado en el
 *      spawn y la interpolacion del cliente trabajaba contra marcas
 *      viejas.
 *  Convar tails_avinterp (default 1): 1 = fix ON / 0 = interpolacion de
 *  red como v5.20.4 (escape). Cambiarlo en vivo aplica/quita el flag en
 *  los avatares existentes SIN recrear nada.
 *
 *  v5.20.4 "FIX TILT DE FRENTE A CAMARA" (2026-10-06, bug reportado
 *  por el owner: caminar hacia atras = Tails de frente a la camara
 *  se ve inclinado un lado u otro segun como mueva la camara; de
 *  lado, de espaldas o quieto NO pasa):
 *   CAUSA: con el cuerpo a ~180 grados de la camara (caminar atras,
 *     regla Poppy), el yaw LOCAL exacto del avatar cae justo en la
 *     frontera +/-180 del atan2. Al caminar, la direccion real
 *     titila +/-1-3 grados (correcciones de mouse/colision) -> el
 *     valor networked salta entre +179.x y -179.x cada pocos ticks
 *     -> la interpolacion del cliente recorre "el camino largo"
 *     (358 grados) en esos frames -> el cuerpo se ve ladeado hacia
 *     un lado u otro segun caiga el salto. Por eso SOLO pasa de
 *     frente (delta ~180 = zona del salto), SOLO en movimiento (el
 *     titileo es lo que genera saltos) y cambia de lado con la
 *     camara (lado del cruce). Idle/de lado/de espaldas estan lejos
 *     de la frontera: jamas saltan.
 *   FIX 1 (UNWRAP): el yaw local que se ESCRIBE por tick ahora es
 *     CONTINUO (se le suma/resta 360 para quedar a menos de 180 del
 *     valor anterior escrito). Al motor le da exactamente igual
 *     (+-360 = mismo angulo) pero el cliente nunca ve un salto de
 *     frontera: la interpolacion viaja siempre el camino corto.
 *     Aplicado a la copia R y a la copia L (la que ve el dueño).
 *   FIX 2 (DEADBAND 3 grados): la direccion de marcha ya NO persigue
 *     titileos de menos de 3 grados alrededor del yaw actual del
 *     cuerpo (ruido de mouse/colision al caminar). Menos cruces de la
 *     frontera = menos basura de interpolacion = anims mas estables.
 *     Los giros reales (mayores de 3 grados) siguen igual (900 gr/s).
 *
 *  v5.20.3 "DEFAULTS + CONFIG UNICA + SONDA" (2026-10-06, pedidos
 *  del owner):
 *   1) tails_follow DEFAULT 0 (owner: "el follow debe ser 0 en vez
 *      de 1 como predeterminado PARA TODO"): el smx NACE en dual
 *      parentado (copia L del dueño + R para los demás).
 *   2) AUTOEXECCONFIG ELIMINADO de este modulo: la config ahora es
 *      UNICA (Sonic_Suite.cfg, auto-guardada — ver manager v3.75).
 *      El enjambre de archivos viejos (Tails_Abilities.cfg,
 *      Speed_Sonic.cfg, sonic_jump_survivors.cfg, ...) se pisaba
 *      entre si y era la causa del "canon en 45s que nunca cambia"
 *      (se generaron con defaults viejos y re-ejecutaban en cada
 *      mapa; los cambios por consola no se guardaban en nada).
 *   3) NUEVO COMANDO !tailscd (sm_tailscd): imprime los valores
 *      VIVOS del cañón/vuelo/avatar y marca [NO FABRICA] cuando un
 *      valor difiere del default que trae el smx.
 *
 *  v5.20 "GAMEPLAY PASS" (2026-10-06, sobre la v5.17-B que el owner
 *  eligió como base definitiva; las líneas v5.18/v5.19 quedaron
 *  descartadas por veredicto del owner). Lo que pidió, tal cual:
 *   1) BUFF COOLDOWNS: láser 48->15s (default del convar), láser
 *      interrumpido por daño -> 7s (tails_cannon_cancel_cd), vuelo
 *      dura 30% más (10->13s), CD de vuelo 25->20s (y el CD de
 *      cancel manual del vuelo baja en la misma proporción: 17->13.5s).
 *   2) NUEVOS DEFAULTS: tails_lerpcomp 0 (sin lead) y tails_follow 1
 *      (avatar por teleport por tick, estilo v5.5) — son DEFAULTS:
 *      si el server.cfg los tiene fijados, LA CFG GANA.
 *   3) ANIMACIONES (arreglo Poppy): el JUMP ya no se corta — se
 *      reproduce COMPLETO mientras el jugador esté en el aire
 *      (ventana mínima 0.5s, fin real por m_flCycle de la secuencia,
 *      tope 1.5s). El rayo (cargando/disparando) y el glide siguen
 *      interrumpiéndolo (prioridad del FSM, igual que antes).
 *   4) RUN +20%: playback base de correr 1.1x -> 1.32x (sigue
 *      variando con la velocidad real del jugador; caps escalados).
 *   5) TRAIL DEL SPEED EN EL AVATAR: el beam follow del boost
 *      (módulo Speed_sonic) sale ahora del CUERPO DEL AVATAR cuando
 *      el jugador tiene avatar vivo (el survivor está invisible);
 *      dual L/R repartido dueño/demás vía Tails_GetAvatarEnts().
 *   6) FIX RAGDOLL DE MUERTE: el mod de ragdolls del owner revive el
 *      cuerpo del survivor al morir; para un Tails eso NO debe verse
 *      (es un avatar: solo queda el ragdoll OM de tails.mdl). Ventana
 *      de 2s tras la muerte: toda entidad física con modelo
 *      models/survivors/ a menos de 200u del punto de muerte -> oculta.
 *
 *  v5.17-B "AVATAR DUAL" (build de prueba B, 2026-10-06): TODO lo del
 *  v5.17-A (writes en rampa) + la solución al tilt del dueño. El motor
 *  arma el transform del parent EN CADA CLIENTE: el cliente del dueño
 *  usa el cuerpo PREDICHO (cámara completa: pitch+yaw) y los demás el
 *  NETWORKEADO (yaw solo) → UN solo par de ángulos locales no puede
 *  dejar vertical a los dos a la vez (verificación v5.6). SALIDA: DOS
 *  copias del avatar (mismo modelo/parent/offset/FSM) filtradas con
 *  SDKHook_SetTransmit (la técnica de l4d_hats):
 *   - copia L: SOLO el dueño la recibe; contra-rotada con sus EYE
 *     ANGLES = vertical EN SU PANTALLA (mata el tilt y su wobble)
 *   - copia R: el resto; contra-rotada con GetClientAbsAngles
 *     (v5.11 EXACTO para ellos, sin cambios)
 *  Convar tails_localparent (1 = dual ON / 0 = un solo avatar = v5.17-A).
 *  Si en tu pantalla el cuerpo quedara INCLINADO AL REVÉS con 1, ponlo
 *  en 0 (fallback vivo). Posición: 100% a cargo del motor en ambas
 *  copias (cero teleport). Al morir: ambas mueren, un solo ragdoll OM.
 *
 *  v5.17-A "SMOOTHING" (build de prueba A, 2026-10-06): MISMO v5.11
 *  (parentado v5.7 + bomba de bilis) pero los 2 writes per-tick del
 *  avatar ya NO van secos: rampa exponencial. Cada write por tick es
 *  un ESCALON que el cliente del dueno nota como micro-tiron (su
 *  camara se mueve por FRAME, la correccion llega por TICK):
 *   - m_angRotation (contra-rotacion) -> tails_angdamp   (default 0.05s)
 *   - m_vecOrigin   (lead del lerp)    -> tails_leadsmooth (default 0.10s)
 *  Ambos convars en 0 = v5.11 byte a byte. EL TILT RESIDUAL AL APUNTAR
 *  ARRIBA/ABAJO SIGUE IGUAL (el aceptado: el parent del dueno lleva la
 *  camara y eso no tiene arreglo con un solo avatar). Lo que muere
 *  aqui es el ESCALON (micro-tiron), no el tilt. Resto del suite:
 *  INTACTO (laser, canon 4 modos, bomba de bilis, vuelo, FSM, ragdoll).
 *
 *  v5.11 (veredicto del owner, 2026-10-06: "es inutil el pitch es el
 *  unico metodo que permite al model moverse sin esos molestos mini
 *  tirones... pero bueno... ponle de item una bomba de bilis xq esa
 *  no tiene efecto de llamas"): ROLLBACK AL SEGUIMIENTO PARENTADO DEL
 *  v5.7 ("el metodo del pitch"). Toda la saga posterior quedo
 *  descartada por decision del owner:
 *  - v5.8 (carrier invisible + TeleportEntity por tick): mato el
 *    pitch pero el MOVIMIENTO entero viajaba por teleport de server
 *    -> STEPPING (los "mini tirones" que nunca se fueron).
 *  - v5.9 / v5.9.1 (estampa de m_flSimulationTime): el reloj de
 *    interpolacion avanzo, los tirones NO.
 *  - v5.10 (Plan B: ornament/attachment directo al survivor): PEOR:
 *    avatar pegado al transform del survivor (los 2 modelos solapados
 *    -> el survivor "aparecia y desaparecia") y Tails recien visible
 *    cuando el survivor moria (el ragdoll soltaba el parent -> el
 *    "cadaver" de Tails).
 *  El owner confirmo empiricamente lo unico que funciona: el SetParent
 *  DIRECTO al survivor (v5.7): el MOTOR de cada cliente mueve al avatar
 *  junto al cuerpo y el movimiento es suave SIEMPRE. El tilt momentaneo
 *  al apuntar arriba/abajo (la contra-rotacion local nunca llega 100%
 *  sincronizada al cliente) VUELVE y QUEDA: el owner lo acepta de forma
 *  explicita ("pero bueno"). El bloque de avatar es byte-exacto al v5.7:
 *  cero carrier, cero ornament, cero teleport por tick sobre el avatar.
 *  - ITEM = BOMBA DE BILIS (pedido del owner): el proyectil del modo
 *    ORBS ahora usa el frasco de bilis REAL de L4D2
 *    (models/w_models/weapons/w_eq_bile_flask.mdl, ruta verificada en
 *    el changelog del L4D2 Community Update y en VScripts que hacen
 *    FindByModel con esa misma ruta): SIN llama en el trapo (el molotov
 *    de la v5.10 mostraba el fuego), SIN luz parpadeante, con fisica
 *    valida de throwable nativo (nada de "Can't create physics object").
 *  - Se conserva de la v5.9.1 SOLO Tails_MarkInterp para el modo
 *    diagnostico (tails_follow 1: teleport por tick).
 *  - FIX DEL LASER (v5.7): INTACTO byte a byte (T_TailsFireLoop,
 *    Tails_ProcessLaserHit, Tails_EndFiring, Tails_GetMuzzlePos,
 *    Tails_StartFiring, Tails_GetLerpLead).
 *
 *  v5.7 (2 fixes del video de prueba del owner, 2026-10-04):
 *  - FIX 1 - "el ataque no sale en el centro de la mira": el lazo de
 *    disparo (v4.5, abanico raygun) armaba el array de offsets con [0]
 *    = -12 grados y el rayo UNICO del modo LASER usaba justo ese [0]:
 *    el haz (y el DANO) salian 12 grados a la DERECHA de la mira desde
 *    el v4.5 (en el video se ve claro: el rayo termina ~12 grados a la
 *    derecha de la cruz, siempre a la misma altura). FIX: [0] = 0
 *    (centro) -> el rayo unico pega EXACTAMENTE donde apunta la mira;
 *    el abanico de 3 rayos del modo raygun queda igual (centro y
 *    laterales +-12).
 *  - FIX 2 - "volvio el error" (desfase al moverse, "como cuando
 *    tienes los lerps bajos"; con interp 0 se ve pegado): el avatar
 *    PARENTADO se dibuja en la posicion INTERPOLADA del survivor (todo
 *    lo que ves del mundo va ~lerp detras; tu camara va PREDICHA): al
 *    caminar, el avatar queda ~lerp por detras de donde realmente
 *    estas. El fix NO toca la interpolacion de nadie (nada de interp 0
 *    ni saltos): ORIGEN LOCAL del avatar con "lead" = velocidad *
 *    tails_lerpcomp (default 0.1s = lerp default de L4D2). Taylor 1er
 *    orden: pos_interp + vel*lerp = pos actual -> en TU pantalla el
 *    avatar queda PEGADO; el delta por tick es diminuto (2-3u, el
 *    historial de interpolacion sigue limpio = anims suaves intactas)
 *    y para los demas es indetectable (el cuerpo del survivor esta
 *    invisible: no hay referencia). El MUZZLE del laser lleva el mismo
 *    lead (el haz sigue naciendo del cañon del brazo aunque camines).
 *    tails_lerpcomp 0 = off (v5.6 exacto); ajustalo a tu lerp real si
 *    ves que el avatar se adelanta o se queda atras.
 *
 *  v5.6 (fix del owner: "cuando el jugador se mueve se le nota unos
 *  pequeños retrasos de movimiento... desfazado por milisegundos, como
 *  cuando tienes los lerps bajos" y "las animaciones de tails cambian
 *  al instante, ya no lo hacen de manera suave las transiciones"):
 *  - EL PARENT VUELVE (v5.4-style): el v5.5 lo quitó (para matar el
 *    pitch heredado) y pasó el seguimiento a TeleportEntity por tick.
 *    ESO rompió la suavidad: un prop teleportado por el server cada
 *    tick pierde el historial de interpolación estable del cliente ->
 *    movimiento desfazado (1 tick + lerp) Y transiciones de animación
 *    secas. Con el SetParent el MOTOR de cada cliente mueve al avatar
 *    junto al survivor: cero delay de red, cero teleport por tick, y
 *    las anims vuelven a la suavidad del v5.4.
 *  - EL BUG DEL PITCH NO VUELVE (la razón del v5.5 sigue resuelta):
 *    Tails_AvatarFollow escribe cada tick los ángulos LOCALES del
 *    avatar = contra-rotación EXACTA del parent (L = P^-1 * vertical,
 *    fórmula cerrada verificada): cuerpo SIEMPRE vertical en mundo,
 *    mirando al yaw de las reglas v5.5 (movimiento / bloqueo de
 *    cámara en carga-disparo / sm_tailslock). La FSM de animaciones,
 *    one-shots, tint y persistencia NO cambia.
 *  - Hook del follow: PreThink -> PostThink (posición/velocidad/
 *    ángulos frescos del tick, no del tick anterior).
 *  - NUEVO convar tails_follow (0 parentado suave = default / 1
 *    teleport estilo v5.5) para diagnosticar/comparar; al cambiarlo
 *    se recrean los avatares en <=0.1s.
 *  - ¿Lag si OTROS jugadores tienen lag? NINGUNO: cada cliente dibuja
 *    al avatar a partir del survivor que ya recibe (transform del
 *    parent, computado local); el avatar no agrega tráfico por
 *    jugador y el server ya no lo toca cada tick.
 *
 *  v5.5 (fix del owner: "cuando apunto hacia abajo todo el cuerpo de
 *  tails baja hacia abajo. o mira hacia arriba. Lo cual es extraño xq
 *  en Gmod cuando uno de ellos gira gira es la cabeza en vez de todo
 *  el cuerpo (asi como hace los survivors de l4d2)... voltear todo el
 *  cuerpo a como mire la camara no deberia poder hacerse si no esta en
 *  modo carga y o disparo del cañon... al caminar, si camina hacia
 *  atras deberia voltearse el cuerpo (fix Poppy)... estara disponible
 *  un comando que habilite el modo bloq Mayuscula (referencia a
 *  roblox) para activar o desactivarla. Pero vendra desactivada por
 *  defecto"):
 *  - CUERPO SIEMPRE VERTICAL: fuera el SetParent (heredaba el PITCH
 *    de la cámara: el cuerpo entero se inclinaba al mirar abajo/
 *    arriba). El avatar se sigue por tick desde el PreThink del
 *    jugador (igual que el pill de GMod hacia SetPos/SetAngles por
 *    tick): pitch y roll FIJOS en 0. (La cabeza del MDL no tiene
 *    animaciones de mirada: son secuencias pre-hechas, así que el
 *    efecto equivalente a GMod es cuerpo vertical SIEMPRE.)
 *  - YAW CON LAS REGLAS DEL PILL:
 *      (1) cargando o disparando el cañón (TODO el loop, carga
 *          incluida) o con sm_tailslock activo: cuerpo FIJO hacia
 *          donde mira la cámara ("bloqueo de cámara");
 *      (2) normal: el cuerpo se VOLTEA hacia donde camina/corre/
 *          vuela (caminar hacia atrás = cuerpo mirando hacia atrás,
 *          fix estilo Poppy);
 *      (3) parado: mantiene el último yaw (no gira solo).
 *    Giro suave (~900°/s): sin saltos ni teleports visuales.
 *  - NUEVO COMANDO sm_tailslock ("bloq Mayús" de Roblox): fija el
 *    cuerpo a la mira SIEMPRE. Toggle por jugador, DESACTIVADO por
 *    defecto (feedback en el chat al alternarlo).
 *
 *  v5.4 (fix del owner: "si se reinicia la ronda el cuerpo del survivor
 *  que era invisible aparece denuevo y tails desaparece; 2 al pasar de
 *  capitulo si tails desaparecio reaparece si. pero el cuerpo del
 *  survivor tambien"):
 *  - REINICIO DE RONDA: en L4D2 el player_spawn del reinicio llega
 *    ANTES que el round_start: el avatar se recreaba bien y despues el
 *    round_start lo MATABA (Tails fuera + cuerpo visible). El
 *    round_start ya NO toca el avatar (ni los hooks de dano: el mismo
 *    bug de orden dejaba el OnTakeDamage de cancelacion descolgado).
 *  - CAMBIO DE CAPITULO: el motor resetea el render del player
 *    DESPUES del player_spawn del mapa nuevo y el RENDER_NONE del
 *    cuerpo se perdia (Tails reaparecia + cuerpo visible). El think
 *    de 10 Hz ahora REAFIRMA el cuerpo invisible (deriva maxima 0.1s)
 *    y AUTO-RECREA el avatar si se pierde cualquier spawn (restart,
 *    capitulo, takeover de bot, rescue) - igual que el pill de GMod.
 *  - CreateAvatar ya NO guarda RENDER_NONE como modo restaurable (el
 *    cuerpo quedaba invisible para siempre al cambiar de personaje) y
 *    OnMapStart limpia los slots de avatar del mapa anterior.
 *
 *  v5.3 (pedido del owner: "Los sonidos de tails No se escuchan lo
 *  suficientemente fuerte aumentale el volumen (por codigo) y por
 *  cierto el rayo debe salir del brazo (del modelo de tails) no de
 *  la cabeza del Superviviente"):
 *  - VOLUMEN x2 CAPAS: EmitSound no pasa de vol 1.0, asi que la unica
 *    forma de subir el volumen POR CODIGO es apilar el mismo WAV en
 *    DOS canales a la vez (AUTO + ITEM): las capas alineadas se suman
 *    (~+6dB) y se oye CLARAMENTE mas fuerte. Aplicado a TODOS los
 *    sonidos OM del canon/vuelo (charge, shoot, ready, impact, burst,
 *    toggle, orbes, boom, shock, fly start/loop, unlock). Ademas
 *    SNDLEVEL 75-80dB -> 100/120dB (a distancia ya no lo tapa el
 *    tiroteo de L4D2) y vol 0.8/0.9 -> 1.0 en todo. FIX extra: el
 *    "laser ready" ya NO lo pisaba el loop del disparo (van en
 *    canales distintos ahora y los 2 se oyen).
 *  - EL RAYO SALE DEL BRAZO: el haz ya NO nace en la cabeza del
 *    survivor: el trace sigue saliendo de los OJOS (punteria intacta:
 *    el rayo pega exactamente donde apuntas) pero el HAZ VISUAL y la
 *    linea de dano salen del CAÑON del brazo del avatar tails.mdl
 *    (fwd 15u / derecha 12u / altura 21u = brazo del modelo de 33u
 *    con el cañon TailsCannon). Los 3 rayos del MODO RAYGUN salen
 *    del mismo cañon en abanico.
 *
 *  v5.2 OM R3 (SONIDOS REALES del pack del owner, pedido: "solo
 *  falta eso que ordenes el audio para que quede = para que el port
 *  este listo"): TODOS los sonidos del canon/vuelo pasan a los WAV
 *  reales del OM (sound/om/tails/ al VPK de recursos, rutas EXACTAS
 *  del pack = merge limpio): laser charge/shoot/ready/impact/burst,
 *  cannon unlock, CannonCancel_1+_2 EN CAPA (GMod exacto), toggle de
 *  modo (tails toggle.wav), loop de vuelo s135_sba_flying (pitch
 *  25..100) + despegue flystarting.wav. NUEVO: "tails laser ready"
 *  al completar la carga (GMod lo reproduce y faltaba) e "impact"
 *  1x por sesion de disparo. El sonido de carga (4.5s) ahora se
 *  CORTA al cancelar. Orbes/shockwave/electric conservan nativos
 *  L4D2 (en GMod usaban stock HL2: sinewave/stunstick/hegrenade).
 *
 *  v5.1 OM R2 (materials al VPK + HABILIDAD 3, pedido del owner:
 *  "lo del tailscannon mejor colocala como su habilidad 3 para
 *  cambiar su tipo (una habilidad sin CD)"):
 *  - HABILIDAD 3 (tecla C del manager): el CAMBIO DE MODO del cañón
 *    ES la 3a habilidad de Tails (la T de GMod -> C aquí). El alias
 *    sm_tailscannon queda vivo para binds viejos. SIN cooldown (la
 *    habilidad no gasta recarga); solo anti-spam 0.5s del GMod
 *    (nuevo convar tails_togglecd = OUTCOMEMORIES_N_tails_togglecd).
 *  - TINT DE MODO GMod EXACTO (laserswap de tails_ui_om.lua): al
 *    cambiar de modo el AVATAR ENTERO flahea 0.35s con el color del
 *    modo (Laser azul 0,0,255 / Burst verde 0,255,0 / Orbs rojo
 *    255,0,0 / Shockwave amarillo 255,255,0) y el think del avatar
 *    lo devuelve a blanco al expirar. El anillo de beam usa ahora
 *    los mismos colores exactos.
 *  - #define TAILS_INC_VERSION para el sm_sjsver del manager.
 *
 *  v5.0 OM PARITY (port del OM de GMod, arranque por Tails):
 *  - NUEVO AVATAR ESPEJO: prop_dynamic_override con el tails.mdl del OM
 *    (VPK de recursos) parentado al survivor + cuerpo oculto. FSM de
 *    animaciones con las 16 secuencias del MDL y las prioridades del
 *    ShouldAlternate de GMod: downed > roll > GLIDE (vuelo) > disparo
 *    (ShootingReady) > vida baja (lowhealth) > suelo (idle/walk/run) >
 *    aire (jump/fall). PlaybackRates GMod: walk 1.8x, run 1.1x, glide
 *    se APAGA con el combustible (los ultimos 2s el aleteo decae).
 *    Ragdoll OM al morir (tails.phy del pack). Si el modelo no esta
 *    aun en el VPK, el avatar queda inerte y el resto funciona igual.
 *  - VUELO = FISICA GMod OM: velocidad SETEADA = mira*300 + lateral
 *    (A/D)*300 + vertical +-90 (ESPACIO sube / soltar baja), todo
 *    escalado por el "clampval" GMod (decay 0->1 en los ultimos 2s).
 *    Loop de vuelo re-emitido cada 0.2s (lleno) a 0.55s (agotandose)
 *    con pitch 25..100 (GMod s135_sba_flying). Despegue desde suelo:
 *    +10u de lift + 1s de ascenso automatico (flyingDuration_Up).
 *    Cancel manual (re-tecla con >50% de carga): colchon de 1s + CD
 *    corto 17s; expiracion/aterrizaje: CD 32s. EL DANO RECIBIDO
 *    CANCELA el vuelo sin CD (igual que OM_DamageBeforeCustomFunction).
 *  - CANON DE 4 MODOS (toggle T de GMod -> sm_tailscannon): LASER
 *    (carga 4.75s, rayo 3.75s, 6/0.1s), BURST (carga 2s, radial 200,
 *    10 dmg + stun + empuje 750 + quemadura 3s + anim ShootingBurst +
 *    jugador congelado durante el blast), ORBS (3 orbes/sesion,
 *    proyectil al punto de mira, explota al tocar o a los 3s, radio
 *    130) y SHOCKWAVE (zona en el punto de mira que da +200 de
 *    velocidad a los ALIADOS cercanos 5s, CD reducido a la mitad).
 *    El dano recibido interrumpe carga/rayo con CD corto 14s
 *    (CannonCancel de GMod).
 *  - ELIMINADO m_flLaggedMovementValue del disparo (regla del suite:
 *    rubber-band): sustituido por m_flMaxspeed = 60 (WALK de GMod)
 *    mantenido por PreThink SOLO mientras carga/dispara.
 *  - Defaults GMod: laser dmg 15->6 por tick, CD 45->30+1, carga 1s ->
 *    4.75s (laser) / 2s (resto), duracion de vuelo 10s (igual).
 *
 *  v4.4 FIXES (peticion del usuario: "fix a la pasiva de tails
 *  de curar mas rapido"):
 *  - FIX PASIVA MEDIC SUPPORT: la aceleracion de curacion se
 *    aplicaba solo en el evento "heal_begin", donde la barra del
 *    motor puede que aun NO estuviera escrita (m_flProgressBarDuration
 *    en 0 -> el bloque entero se saltaba en silencio: la pasiva
 *    parecia muerta). Ahora se aplica tambien (y sobre todo) desde
 *    el forward de left4dhooks L4D2_OnStartUseAction_Post, que se
 *    dispara DESPUES de que CTerrorPlayer::StartUseAction termine
 *    (props garantizadas) + doble validacion con m_iCurrentUseAction
 *    == Healing. Con sello de tiempo anti-doble-aplicacion (el evento
 *    y el forward disparan en el mismo frame para la misma curacion).
 *  - FIX TEXTOS: eliminados los emojis de los mensajes (no se
 *    renderizan bien en el HUD de L4D2) y textos mas claros.
 *
 *  v4.3 FIXES (peticion del usuario):
 *  - FIX CRITICO LASER vs WITCH: el empuje crudo por velocidad se
 *    anulaba al instante (la witch es un NPC NextBot: su locomocion
 *    reescribe la velocidad cada tick de IA; cuando se enojaba y
 *    cargaba contra Tails, el laser "no hacia nada"). Ahora el beam
 *    usa el sistema Witch_Flight: mientras el rayo la mantiene, su
 *    IA queda SUSPENDIDA y se la empuja a lo largo del rayo → el
 *    laser SI es mas fuerte que su impulso NextBot, incluso en
 *    pleno ataque.
 *  - NUEVO stagger de la WITCH: la witch SI puede ser tambaleada
 *    por el motor (mecanica vanilla: golpe unico >= 50 de dano
 *    explosivo, como el lanzagranadas o el sniper). Tras 1.5s de
 *    laser continuo sobre ella: impacto de 75 DMG_BLAST que dispara
 *    su stumble NATIVO + lanzamiento fuerte (se recupera sola, como
 *    en vanilla).
 *  - FIX STAGGER "NO SE LEVANTAN": los bots infectados quedaban
 *    tirados en el suelo tras un stagger (bug del estado del propio
 *    motor: no lo limpia solo en bots). Ahora todo stagger del
 *    plugin va por SI_Stagger.inc: auto L4D_CancelStagger a los 1.8s
 *    (SI) / 3.0s (Tank) → se levantan GARANTIZADO.
 *  
 *  v4.2 FIXES DE BUGS Y QoL:
 *  - FIX "INVALID HANDLE" (log): si Tails desconectaba con el
 *    laser activo, el handle del timer quedaba colgado (stale).
 *    El proximo cliente en ese slot provocaba KillTimer sobre un
 *    handle ya cerrado -> error de nativa. Nuevo
 *    Tails_OnClientPutInServer resetea TODO el estado del slot.
 *  - FIX REENTRANCIA: T_TailsFireLoop llamaba Tails_ResetState
 *    (que hace KillTimer) sobre el MISMO timer en ejecucion. Ahora
 *    los stop-paths de los timers hacen limpieza suave.
 *  - FIX INJUSTO: morir volando aplicaba el cooldown de vuelo
 *    completo (25s de castigo por morir). Ahora la muerte/round
 *    NO aplican cooldown de vuelo.
 *  - FIX: el vuelo podia iniciarse incapacitado, y el FlyThink
 *    segia forzando velocidad mientras te tenia un Hunter/Jockey/
 *    Smoker encima (peleaba contra el agarre). Ahora se cancela.
 *  - FIX PROMESA ROTA: el header decia que el laser "atraviesa
 *    hordas enteras", pero el trace se detenia en el primer
 *    comun infectado. Ahora el beam SI atraviesa comunes y
 *    compaeros (el dano se aplica por linea, como estaba pensado).
 *  - FIX FLICKER: el Animal Sense (amarillo) y la Treasure Vision
 *    de Rouge (rosa) se pisaban el glow mutuamente cada tick
 *    (parpadeo de colores). Ahora cada modulo solo limpia el glow
 *    de SU color.
 *  - QoL: reset defensivo al (re)conectar y al cambiar de
 *    personaje (nuevos hooks cableados al manager).
 *  
 *  v4.1: (Witch Fix)
 *  FIX: Lift-Off Assist y Air Steering añadidos al vuelo.
 *  FIX: Láser ahora atraviesa hordas enteras y daña a las Witches.
 *  FIX: Se permite disparar el láser mientras se vuela.
 *  FIX: Animal Sense ahora detecta Witches y limpia el brillo al morir Tails.
 *  FIX: Feedback visual para la curación de soporte (Anillo Verde).
 * ======================================================
 */

#if defined _Tails_included
    #endinput
#endif
#define _Tails_included

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
#if !defined _witch_flight_included
    #include <Witch_Flight>
#endif
#if !defined _si_stagger_included
    #include <SI_Stagger>
#endif

#if !defined TAILS_INDEX
    #define TAILS_INDEX 1
#endif

// =======================
// Constantes y Audio
// =======================
#define TAILS_SOUND_FLY_START   "om/flystarting.wav"              // v5.2: despegue (familia OM: Silver/Fleetway lo usan al volar)
#define TAILS_SOUND_FLY_LOOP    "om/tails/s135_sba_flying.wav"    // v5.2: loop de vuelo GMod (re-emit con pitch 25..100)
#define TAILS_SOUND_CHARGE      "om/tails/tails laser charge.wav" // v5.2: carga del canon (4.5s, se corta al cancelar)
#define TAILS_SOUND_LASER_LOOP  "om/tails/tails laser shoot.wav"  // v5.2: loop de disparo (3.75s GMod + StopSound)

// =======================
// v5.0 OM: avatar espejo + cañón de 4 modos (paridad GMod OM)
// =======================
// El modelo vive en el VPK de recursos del server (owner lo mete
// en el pack y se auto-actualiza al abrir L4D2: nada de downloads).
#define TAILS_OM_MODEL          "models/noodles/om/tails.mdl"

// v5.2 OM R3: sonidos REALES del pack del owner (WAV 44.1kHz/16bit
// verificados). Rutas EXACTAS del pack (sound/om/...) para que el
// vpk_recursos mergee limpio con su pack completo. ORB/SHOCK/ELEC
// conservan nativos L4D2: en GMod usaban stock HL2 (sinewave,
// stunstick spark, hegrenade) que L4D2 no trae.
#define TAILS_OM_SOUND_UNLOCK   "om/tails/tails cannon unlock.wav" // GMod exacto (CD listo)
#define TAILS_OM_SOUND_READY    "om/tails/tails laser ready.wav"   // GMod exacto (carga completa)
#define TAILS_OM_SOUND_ZAP      "om/tails/cannoncancel_1.wav"      // cancel por daño
#define TAILS_OM_SOUND_ZAP2     "om/tails/cannoncancel_2.wav"      // GMod reproduce _1 + _2 EN CAPA
#define TAILS_OM_SOUND_IMPACT   "om/tails/tails laser impact.wav"  // GMod: shouldstundamage (1x/sesion)
#define TAILS_OM_SOUND_BURST    "om/tails/tails laser burst.wav"   // GMod exacto
#define TAILS_OM_SOUND_TOGGLE   "om/tails/tails toggle.wav"        // GMod exacto (surface.PlaySound)
#define TAILS_OM_SOUND_ORB_FIRE "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_1.wav"
#define TAILS_OM_SOUND_ORB_BOOM "weapons/hegrenade/explode4.wav" // orb explode
#define TAILS_OM_SOUND_SHOCK    "ambient/explosions/explode_1.wav"
#define TAILS_OM_SOUND_ELEC     "ambient/machines/electric_loop.wav"
// Modelo de proyectil del modo ORBS. v5.11 (pedido del owner: "ponle
// de item una bomba de bilis xq esa no tiene efecto de llamas"): el
// frasco de bilis REAL de L4D2 (ruta del changelog del L4D2 Community
// Update y de los VScripts con FindByModel): sin llama, sin luz
// parpadeante, fisica nativa de throwable. El v5.7 usaba la pipebomb;
// el molotov que probo el owner en la v5.10 mostraba el fuego del trapo
// y venia con un path mal escrito ("Can't create physics object").
#define TAILS_OM_ORB_MODEL      "models/w_models/weapons/w_eq_bile_flask.mdl"

// FSM del avatar: 12 estados de animación (secuencias del tails.mdl)
#define TAILS_ANIM_COUNT 12
static const char g_sTailsAnimSeq[TAILS_ANIM_COUNT][24] = {
    "idle",                  // 0
    "walk",                  // 1
    "run",                   // 2
    "jump",                  // 3
    "fall",                  // 4
    "glide",                 // 5 (vuelo: GMod ShouldAlternate)
    "ShootingReady_Idle",    // 6 (cargando/disparando parado)
    "ShootingReady_Walk",    // 7 (cargando/disparando moviéndose)
    "DownedIdle",            // 8 (incapacitado)
    "Idle_LowHealth",        // 9 (vida <= 60: variante GMod)
    "Walk_lowhealth",        // 10
    "Run_Lowhealth"          // 11
};

// Colores del Laser (Amarillo Puro y Solido)
int g_iColorLaser[4] = {255, 255, 0, 255}; 
int g_iSpriteLaser = -1;
int g_iSpriteHalo = -1;
int g_iSpriteGlow = -1;

// =======================
// Variables Globales
// =======================
// --- Vuelo ---
bool g_bTailsFlying[MAXPLAYERS + 1];
float g_fTailsFuel[MAXPLAYERS + 1]; 
float g_fTailsFlyCooldown[MAXPLAYERS + 1];

// --- Laser ---
bool g_bTailsCharging[MAXPLAYERS + 1];     
bool g_bTailsFiring[MAXPLAYERS + 1];       
float g_fTailsLaserCooldown[MAXPLAYERS + 1];
float g_fTailsChargeStartTime[MAXPLAYERS + 1];
float g_fTailsFireEndTime[MAXPLAYERS + 1]; 

// --- v4.5 (peticion usuario): sistema de usos del rayo ---
// 1er y 2do uso: rayo normal (mas grande). 3er uso: MODO RAYGUN
// (spray triple al estilo Spread Gun de Contra: 3 rayos en abanico,
// centro + laterales). El contador cicla: 1-2-3(RAYGUN)-1-2-3...
int  g_iTailsLaserUses[MAXPLAYERS + 1];
bool g_bTailsRaygunMode[MAXPLAYERS + 1];
bool g_bTailsImpactPlayed[MAXPLAYERS + 1];  // v5.2: "tails laser impact" 1x por sesion

// --- v5.0 OM: avatar espejo ---
int   g_iTailsAvatar[MAXPLAYERS + 1];       // EntRef del prop_dynamic R (0 = sin avatar)
int   g_iTailsAvatarL[MAXPLAYERS + 1];      // v5.17-B: EntRef de la copia L (solo el dueño la ve)

// v5.21 — BACKOFF del auto-montaje (R y L): un montaje que falla (sin
// edicts libres, spawn rechazado) ya NO se re-intenta a 10 Hz para siempre;
// escala 0.1s * fallos con tope 1s. Reset al exito / mapa / cliente nuevo.
int    g_iTailsRMountFails[MAXPLAYERS + 1];
float  g_fTailsNextRMountTry[MAXPLAYERS + 1];
int    g_iTailsLMountFails[MAXPLAYERS + 1];
float  g_fTailsNextLMountTry[MAXPLAYERS + 1];
int   g_iTailsAnimState[MAXPLAYERS + 1];    // estado FSM actual (-1 = sin setear)
float g_fTailsAnimLock[MAXPLAYERS + 1];     // lock de one-shots (ShootingBurst...)
int   g_iTailsBodyRender[MAXPLAYERS + 1];   // render mode ORIGINAL del survivor
#define TAILS_INC_VERSION "v5.28-B"           // v5.28: ADOPCION EN EL MONTAJE + reemplazo limpio del avatar (manager 3.77.40: fin del barrido en caliente). v5.27: STUN UNIFICADO (pedido del owner 2026-10-09: "no es mejor unificar ambos stun en un solo documento? ... en si tenemos ragdoll y el stun de congelamiento y empuje (tails) pero lo que no tiene el stun de tails es las estrellas"): TODO el congelado del rayo (Tails_SIFreezeStart/Push/Release + ticker + 10 arrays, las ~400 lineas paralelas del v5.22-v5.26) SE BORRA y el rayo llama al OM_Stun v2.0 con flags (CYAN|PUSH|STAGGER|FIXED|NOIFRAME): freeze estatua + ESTRELLAS (lo que le faltaba) + arrastre por el haz + stagger al liberar — identico, pero en el mismo documento que Sonic/Amy/Metal. v5.26: ESTATUA DE VERDAD — pausa de ANIMACION del SI congelado (pedido del owner 2026-10-09: "si podemos hacer algo pausar la animacion del infectado especial... literalmente es como poner una pausa en su animacion obligandole a que quede congelado (como pasaria con el FL_Frozen)"): el rayo congela la fisica pero el bot de player seguia ANIMANDO en el sitio; ahora la pose del momento del congelado queda CLAVADA con la capa compartida del OM_Stun v1.3 (OM_Stun_AnimPause al congelar / AnimTick re-afirmado por el ticker / AnimResume al liberar — ANTES del stagger, para que el tambaleo del descongelado se vea a full). v5.25: AVATAR REMOTO POR TP — la copia R (la que ven LOS DEMAS) de los TRES avatares del suite (Tails/Sonic/Amy) viaja por TeleportEntity por tick + reloj vivo SIN EF_NOINTERP (la receta del modo tails_follow): los clientes de los demas la INTERPOLAN = suave sin depender de la pausa, que solo re-encaja la vista del dueno (pedido: "los avatares de otros al modo TP; localmente igual, con su pausa"). Convar tails_avatar_tp (default 1; 0 = R parentada como antes; el cambio en vivo recrea en <=0.1s). La copia L del dueno queda INTACTA (parentada + EF_NOINTERP + pulso). La bola del spin queda parentada y la R oculta viaja pegada durante la bola. v5.24: RESTAURADO el pulso de pausa en CADA montaje del avatar (!sc, respawn, FSM: el gate "solo al iniciar la ronda" de la v5.23 se retira por pedido del owner — estaba bien como estaba) + FIX del congelado SI con las capas OM_Stun que faltaban (m_flLaggedMovementValue=0 re-afirmado por tick + tinte cyan: la witch es NPC NextBot y FL_FROZEN le apaga TODO; los especiales son bots de player y con solo el martillo su IA seguia viva). v5.23: el cañon SOLO lo cortan los STUN. v5.22: congelado de todos los SI + salto herido + rayo 5s/35dps

bool  g_bTailsModelOK = false;              // el tails.mdl está en el VPK

// --- v5.0 OM: vuelo GMod ---
bool  g_bTailsFlyManual[MAXPLAYERS + 1];    // cancel manual (CD corto 13.5s v5.20)

// --- v5.20 GAMEPLAY PASS ---
float g_fTailsJumpStart[MAXPLAYERS + 1];     // marca de entrada al estado 3 (jump completo, fix Poppy)
float g_fTailsDeathHideUntil[MAXPLAYERS + 1]; // ventana anti-ragdoll del survivor (2s tras morir)
float g_fTailsDeathOrigin[MAXPLAYERS + 1][3]; // punto de muerte del Tails (radio del filtro)
float g_fTailsFlyUpUntil[MAXPLAYERS + 1];   // despegue: 1s de ascenso auto
float g_fTailsFlyNextSnd[MAXPLAYERS + 1];   // re-emisión del loop (pitch GMod)

// --- v5.0 OM: cañón de 4 modos ---
int   g_iTailsCannonMode[MAXPLAYERS + 1];   // 0 LASER / 1 BURST / 2 ORBS / 3 SHOCKWAVE
float g_fTailsToggleCD[MAXPLAYERS + 1];     // v5.1: anti-spam del toggle (convar; NO es cooldown)
float g_fTailsTintUntil[MAXPLAYERS + 1];    // v5.1: tint laserswap del avatar (0 = off)
bool  g_bTailsLock[MAXPLAYERS + 1];         // v5.5: "bloq Mayús" (sm_tailslock): cuerpo a la mira SIEMPRE (off por defecto)
float g_fTailsBodyYaw[MAXPLAYERS + 1];      // v5.5: yaw actual del cuerpo (giro suave)
float g_fTailsYawLastT[MAXPLAYERS + 1];     // v5.5: timestamp del último follow (dt del giro)
// --- v5.17-A: WRITES SUAVES (rampa exponencial, no escalones por tick) ---
float g_fTailsSmLoc[MAXPLAYERS + 1][3];     // contra-rotación local amortiguada (m_angRotation)
float g_fTailsSmLocL[MAXPLAYERS + 1][3];    // v5.17-B: ídem para la copia L (eye angles)
float g_fTailsSmLead[MAXPLAYERS + 1][3];    // lead del lerp suavizado, espacio MUNDO (m_vecOrigin)
bool  g_bTailsSmSnap[MAXPLAYERS + 1];       // true = próximo tick pega el valor seco (reset/creación)
bool  g_bTailsOrbSession[MAXPLAYERS + 1];   // sesión de orbes activa
int   g_iTailsOrbsLeft[MAXPLAYERS + 1];     // orbes restantes de la sesión
bool  g_bTailsCannonCding[MAXPLAYERS + 1];  // para el sonido "cannon unlock"
float g_fTailsBurstFreezeEnd[MAXPLAYERS + 1]; // freeze del blast (GMod OM_NoMovement)
Handle g_hTailsBurstFreeze[MAXPLAYERS + 1];

// --- v5.0 OM: shockwave (boost a aliados) ---
float g_fTailsSwBoostUntil[MAXPLAYERS + 1]; // hasta cuándo corre el boost
float g_fTailsSwBoostBase[MAXPLAYERS + 1];  // maxspeed snapshot del aliado
#define TAILS_RAYGUN_FAN_DEGREES 12.0   // apertura del abanico (grados por rayo lateral)

// --- v5.27: STUN UNIFICADO — el congelado del rayo vive en el OM_Stun
// v2.0 (el MISMO documento del stun de Sonic/Amy/Metal). Solo quedan
// aqui las DOS constantes del EMPUJE DEL HAZ (la matematica witch del
// hold: 450/z60 = clavado al haz a ras de suelo). La fisica del
// arrastre (gravedad/terminal/deslizamiento/reposo) ahora es del
// OM_Stun (OM_STUN_PUSH_*). ---
#define TAILS_SIFRZ_BEAM_CARRY 450.0   // empuje sostenido del rayo sobre el congelado (= witch)
#define TAILS_SIFRZ_BEAM_Z     60.0    // hover exacto al haz: dz por ciclo de 0.1s
                                       // (X-40)*0.05 + (X-80)*0.05 = 0 con X=60 (matematica witch)
float  g_fTailsLaserSndNext[MAXPLAYERS + 1];// v5.22: re-emision del loop del rayo (WAV 3.75s < rayo 5s)
float  g_fTailsTongueAt[MAXPLAYERS + 1];    // v5.23: cuando vieron los loops el agarre del smoker (0 = libre)
bool   g_bTailsTongueFiring[MAXPLAYERS + 1];// v5.23: estaba DISPARANDO al ser agarrado -> inmune

// --- Stagger de Witches (v4.3): acumulador del rayo por witch ---
// Slots por REFERENCIA (las witches son entidades, no clientes: el
// acumulador [MAXPLAYERS] de los SI no les sirve) con expiracion de
// 2s: si el rayo deja de golpearla, el slot se libera solo (nunca un
// acumulador congelado dispara un stagger instantaneo en el proximo
// disparo).
#define TAILS_WITCH_ACC_SLOTS   8
#define TAILS_WITCH_ACC_EXPIRE  2.0
int   g_iTailsWitchAccRef[TAILS_WITCH_ACC_SLOTS];
float g_fTailsWitchAcc[TAILS_WITCH_ACC_SLOTS];
float g_fTailsWitchAccLast[TAILS_WITCH_ACC_SLOTS];

// --- Timers ---
Handle g_hTailsPassiveTimer = INVALID_HANDLE; 
Handle g_hTailsActionTimer[MAXPLAYERS + 1]; 
Handle g_hTailsAvatarTimer = INVALID_HANDLE;  // v5.0 OM: FSM del avatar (10 Hz)

// --- Medic Support ---
// v4.4: sello de tiempo de la ultima aceleracion aplicada (anti
// doble-aplicacion: heal_begin y L4D2_OnStartUseAction_Post
// disparan en el mismo frame para la misma curacion).
float g_fTailsHealBoostAt[MAXPLAYERS + 1];

// --- ConVars ---
ConVar g_cvTailsSenseRange;
ConVar g_cvTailsHealBoost;
ConVar g_cvTailsFlyDuration;
ConVar g_cvTailsFlyCooldown;
ConVar g_cvTailsLaserDamage;  
ConVar g_cvTailsLaserCooldown;
// v5.0 OM
ConVar g_cvTailsAvatar;        // avatar espejo on/off
ConVar g_cvTailsFlyFwd;        // empuje frontal GMod (300)
ConVar g_cvTailsFlyVert;       // vertical GMod (90)
ConVar g_cvTailsFlyCdCancel;   // CD cancel manual (17)
ConVar g_cvTailsCannonCharge;  // carga modo LASER (4.75)
ConVar g_cvTailsCannonCharge2; // carga BURST/ORBS/SHOCK (2.0)
ConVar g_cvTailsFireTime;      // duración del rayo (3.75)
ConVar g_cvTailsCancelCD;      // CD cancel por daño (14)
ConVar g_cvTailsOrbSpeed;      // velocidad del orbe (1500)
ConVar g_cvTailsToggleCD;      // v5.1: anti-spam del cambio de modo (GMod 0.5)
ConVar g_cvTailsFollow;        // v5.6: 0 parentado (default, suave) / 1 teleport por tick (v5.5)
ConVar g_cvTailsLerpComp;      // v5.7: segundos de lerp a compensar con lead (anti-desfase)
// v5.17-A
ConVar g_cvTailsAngDamp;       // amortiguación de la contra-rotación local (s; 0 = v5.11)
ConVar g_cvTailsLeadSmooth;    // suavizado del lead del origen local (s; 0 = v5.11)
ConVar g_cvTailsLocalParent;   // v5.17-B: avatar dual on/off (1 = copia del dueño con eye angles)
ConVar g_cvTailsRoundRefresh;  // v5.20.2: segundos tras round_start para refrescar el avatar (0 = off)
ConVar g_cvTailsAvInterp;     // v5.20.5: 1 = avatar sin interp de red (EF_NOINTERP, nace encajado) / 0 = v5.20.4
ConVar g_cvTailsPauseFix;         // v5.20.6: 1 = pulso de pausa real tras montar el avatar (metodo del owner)
ConVar g_cvTailsPauseFixDelay;    // v5.20.6: espera tras el montaje antes de pausar (s)
ConVar g_cvTailsPauseFixDuration; // v5.20.6: duracion de la pausa del pulso (s)
ConVar g_cvTailsPauseFixSpacing;  // v5.21: separacion minima entre INICIOS de pulso (anti flicker)
ConVar g_cvTailsAvatarTP;         // v5.25: 1 = la copia R (la que ven LOS DEMAS) viaja por TP: teleport por tick + interpolacion (receta tails_follow)
ConVar g_cvTailsSIFreeze;         // v5.22: 1 = el rayo congela a los infectados especiales (stun de la witch)
ConVar g_cvTailsSIFreezeDur;      // v5.22: segundos FIJOS de congelado (el rayo NO los reinicia)

#define Tails_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif

// =======================
// Inicializacion
// =======================

// ============================================================
//  v5.3: VOLUMEN REFORZADO + MUZZLE DEL BRAZO (pedido del owner)
// ============================================================
// EmitSound no pasa de vol 1.0: para SUBIR el volumen POR CODIGO se
// apila el mismo WAV en 2 canales a la vez (AUTO + ITEM): al llegar
// al mismo tiempo las 2 capas se suman (~+6dB, claramente mas
// fuerte). El SNDLEVEL (solo afecta la caida por DISTANCIA) sube a
// 100dB/120dB para que el tiroteo de L4D2 no lo tape a distancia.
void Tails_EmitLoud(int client, const char[] snd, int level = SNDLEVEL_TRAIN,
                    int pitch = 100, int chan1 = SNDCHAN_AUTO, int chan2 = SNDCHAN_ITEM)
{
    EmitSoundToAll(snd, client, chan1, level, _, 1.0, pitch);
    EmitSoundToAll(snd, client, chan2, level, _, 1.0, pitch);
}

void Tails_StopLoud(int client, const char[] snd,
                    int chan1 = SNDCHAN_AUTO, int chan2 = SNDCHAN_ITEM)
{
    StopSound(client, chan1, snd);
    StopSound(client, chan2, snd);
}

// v5.7: lead anti-desfase. El avatar parentado se dibuja en la posicion
// INTERPOLADA del survivor (~lerp detras de la camara PREDICHA del
// dueno): al caminar se le ve "desfazado como con lerps bajos" (reporte
// del owner; con interp 0 se ve pegado -> probamos que es pura
// interpolacion del cliente). Solucion SIN tocar la interpolacion de
// nadie: adelantar el avatar por velocidad * lerp (feed-forward; Taylor
// 1er orden: pos_interp + vel*lerp = pos actual). SUMA el lead a out.
void Tails_GetLerpLead(int client, float out[3])
{
    float comp = g_cvTailsLerpComp.FloatValue;
    if (comp <= 0.0) return;
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    out[0] += vel[0] * comp;
    out[1] += vel[1] * comp;
    out[2] += vel[2] * comp;
}

// v5.3: MUZZLE = de donde sale el HAZ visual. El avatar tails.mdl mide
// ~33u (ojo a 26.8u) y esta parentado a los PIES del survivor: el cañon
// (material TailsCannon) vive en el brazo a ~21u de altura, adelantado
// 15u y 12u a la derecha (segun el YAW de la mira, sin pitch: el brazo
// no se inclina con los ojos). El TRACE sigue saliendo de los ojos
// (punteria exacta); solo lo VISUAL cambia de origen.
#define TAILS_MUZZLE_FWD    15.0
#define TAILS_MUZZLE_RIGHT  12.0
#define TAILS_MUZZLE_Z      21.0
void Tails_GetMuzzlePos(int client, float out[3])
{
    float ang[3], yaw[3], fwd[3], right[3];
    GetClientEyeAngles(client, ang);
    yaw[1] = ang[1];                       // solo yaw: base horizontal
    GetAngleVectors(yaw, fwd, right, NULL_VECTOR);

    GetClientAbsOrigin(client, out);

    // v5.7: el avatar lleva el lead = vel * tails_lerpcomp (fix del
    // desfase): el cañon del brazo tambien, para que el haz siga
    // naciendo EXACTAMENTE del cañon aunque camines mientras disparas.
    Tails_GetLerpLead(client, out);

    for (int i = 0; i < 3; i++)
        out[i] += fwd[i] * TAILS_MUZZLE_FWD + right[i] * TAILS_MUZZLE_RIGHT;
    out[2] += TAILS_MUZZLE_Z;
}

public void Tails_OnPluginStart()
{
    // Pasivas
    g_cvTailsSenseRange = CreateConVar("tails_sense_range", "800.0", "Rango de deteccion del Animal Sense");
    g_cvTailsHealBoost  = CreateConVar("tails_heal_boost", "2.0", "Multiplicador de velocidad de curacion cerca de Tails");
    
    // Vuelo
    // v5.20 BUFF: vuelo dura 30% mas (10 -> 13) y CD 25 -> 20 (owner)
    g_cvTailsFlyDuration = CreateConVar("tails_fly_duration", "13.0", "Duracion maxima del vuelo (segundos) [v5.20: 13 = 10 +30%]");
    g_cvTailsFlyCooldown = CreateConVar("tails_fly_cooldown", "20.0", "Cooldown del vuelo [v5.20: 25 -> 20]");

    // Laser (v5.22: 3.5/tick = 35 dps pedido owner; el GMod OM traia 6/tick)
    g_cvTailsLaserDamage   = CreateConVar("tails_laser_damage", "3.5", "Dano del canon laser por tick de 0.1s [v5.22: 3.5 = 35/seg, pedido owner (antes 6.0 GMod)]", _, true, 0.1, true, 100.0);
    // v5.20 BUFF: CD del laser 48 -> 15 (owner). OJO: si el server.cfg
    // tiene tails_laser_cooldown fijado, LA CFG PISA este default.
    g_cvTailsLaserCooldown = CreateConVar("tails_laser_cooldown", "15.0", "Cooldown del canon laser [v5.20: 48 -> 15]");

    // v5.0 OM: avatar + física GMod + cañón de 4 modos
    g_cvTailsAvatar       = CreateConVar("tails_avatar", "1.0", "Avatar espejo OM (modelo tails.mdl del VPK de recursos)", _, true, 0.0, true, 1.0);
    g_cvTailsFlyFwd       = CreateConVar("tails_fly_forward", "300.0", "Empuje frontal del vuelo [GMod OM: 300]");
    g_cvTailsFlyVert      = CreateConVar("tails_fly_vert", "90.0", "Velocidad vertical del vuelo (subir con ESPACIO) [GMod OM: 90]");
    // v5.20 BUFF: misma proporcion que el CD normal del vuelo (x0.8)
    g_cvTailsFlyCdCancel  = CreateConVar("tails_fly_cd_cancel", "13.5", "CD del vuelo al cancelar manual [v5.20: 17 -> 13.5]");
    g_cvTailsCannonCharge  = CreateConVar("tails_cannon_charge_laser", "4.75", "Carga del modo LASER [GMod OM: 4.75]");
    g_cvTailsCannonCharge2 = CreateConVar("tails_cannon_charge", "2.0", "Carga de BURST/ORBS/SHOCKWAVE [GMod OM: 2]");
    g_cvTailsFireTime      = CreateConVar("tails_cannon_firetime", "5.0", "Duracion del rayo laser [v5.22: 5.0 pedido owner; GMod OM: 3.75]", _, true, 0.5, true, 15.0);
    // v5.20 BUFF: interrumpido por dano -> 7s para volver a cargar (owner)
    g_cvTailsCancelCD      = CreateConVar("tails_cannon_cancel_cd", "7.0", "CD al ser interrumpido por dano [v5.20: 14 -> 7]");
    g_cvTailsOrbSpeed      = CreateConVar("tails_orb_speed", "1500.0", "Velocidad del proyectil ORBS [GMod OM: 8500 escalado]");
    g_cvTailsToggleCD      = CreateConVar("tails_togglecd", "0.5", "Anti-spam del cambio de modo del cañón (s) [GMod OM: 0.5. La H3 NO tiene cooldown]");

    // v5.6: modo de seguimiento del avatar. 0 = PARENTADO al survivor
    // (el motor lo mueve con el cuerpo: cero delay de red, animaciones
    // suaves como v5.4). 1 = teleport por tick estilo v5.5 (fallback de
    // diagnóstico). Al cambiar se recrean los avatares.
    // v5.20.3 DEFAULT NUEVO (owner: "el follow debe ser 0 en vez de 1
    // como predeterminado PARA TODO"): 0 = parentado dual (copia L del
    // dueño + R para los demás). Con 1 el avatar es único (v5.5).
    g_cvTailsFollow        = CreateConVar("tails_follow", "0.0", "Seguimiento del avatar: 0 parentado al survivor (suave, dual L+R, DEFAULT v5.20.3) / 1 teleport por tick (v5.5)", _, true, 0.0, true, 1.0);
    HookConVarChange(g_cvTailsFollow, Tails_OnFollowModeChanged);

    // v5.7: compensacion del desfase de interpolacion del avatar en la
    // vista del dueno (ver Tails_AvatarFollow). Lead = vel * esto.
    // Default 0.1 = lerp default de L4D2 (cl_interp 0.1). 0 = off.
    // v5.20 DEFAULT NUEVO (owner): 0 = sin lead de lerp
    g_cvTailsLerpComp      = CreateConVar("tails_lerpcomp", "0.0", "Lerp a compensar en el avatar (segundos; 0.1 = lerp default de L4D2; 0 = desactivado, DEFAULT v5.20)", _, true, 0.0, true, 0.3);

    // v5.17-A: WRITES SUAVES. Cada escritura per-tick de m_angRotation /
    // m_vecOrigin es un ESCALÓN que el cliente del dueño nota como
    // micro-tirón (su cámara va por FRAME, la corrección llega por TICK).
    // Estos dos convars convierten los escalones en rampas: filtro
    // exponencial con constante de tiempo tau (alpha = dt / (tau + dt)).
    // 0 = writes secos = v5.11 EXACTO (para A/B en vivo).
    g_cvTailsAngDamp       = CreateConVar("tails_angdamp", "0.05", "Amortiguacion de la contra-rotacion local del avatar (segundos; 0.05 = rampa ~3 ticks; 0 = write seco como v5.11)", _, true, 0.0, true, 0.2);
    g_cvTailsLeadSmooth    = CreateConVar("tails_leadsmooth", "0.10", "Suavizado del lead de lerp del origen local del avatar (segundos; 0.10 = rampa ~6 ticks; 0 = write seco como v5.11)", _, true, 0.0, true, 0.5);

    // v5.17-B: AVATAR DUAL. Copia L SOLO para el dueño (contra-rotada
    // con sus eye angles = vertical EN SU PANTALLA) + copia R para el
    // resto (v5.11 exacto). 0 = un solo avatar compartido (v5.17-A).
    // Al cambiarlo se recrean los avatares (mismo recreador que
    // tails_follow: la FSM de 10 Hz los remonta en <=0.1s).
    g_cvTailsLocalParent   = CreateConVar("tails_localparent", "1.0", "Avatar dual: 1 = copia propia del dueno con contra-rotacion de sus eye angles (mata el tilt EN SU PANTALLA) + copia v5.11 para los demas / 0 = un solo avatar compartido", _, true, 0.0, true, 1.0);

    // v5.20.2 (hallazgo del owner en campo): el avatar creado DENTRO del
    // player_spawn de inicio de ronda nace con el canal del parent sucio
    // (retrazo + cuerpo volteando como linterna); el MISMO avatar que
    // recrea la FSM de auto-reparacion (timer, player ya asentado — lo
    // que pasa al re-seleccionar con !sc) nace perfecto: posicion y
    // giro 100% a cargo del motor. Este convar agenda ese refresh
    // automatico tras el round_start: mata el avatar vivo y la FSM
    // (<=0.1s) lo recrea por el camino bueno. 0 = desactivado.
    g_cvTailsRoundRefresh  = CreateConVar("tails_roundrefresh", "1.0", "Segundos tras round_start para refrescar el avatar de Tails (kill + recreacion por la FSM = el camino del !sc, sin retrazo). 0 = desactivado", _, true, 0.0, true, 10.0);
    HookConVarChange(g_cvTailsLocalParent, Tails_OnFollowModeChanged);

    // v5.20.5 (forense del pause del owner): el tilt de frente a camara
    // es un estado CLIENTE del avatar sembrado al nacer (historial de
    // interpolacion + reloj de simulacion clavados en el spawn) que
    // `pause` re-sincroniza. 1 = el avatar NACE ya encajado: EF_NOINTERP
    // en m_fEffects (el cliente renderiza siempre el ultimo angulo
    // recibido) + estampa del reloj en cada write (ver AvatarFollow).
    // 0 = interpolacion de red del avatar como v5.20.4 (escape en vivo:
    // aplicar/quitar el flag no recrea nada).
    g_cvTailsAvInterp      = CreateConVar("tails_avinterp", "1.0", "Avatar sin interpolacion de red (EF_NOINTERP): 1 = fix del tilt que el pause curaba, el avatar nace ya encajado / 0 = como v5.20.4", _, true, 0.0, true, 1.0);
    HookConVarChange(g_cvTailsAvInterp, Tails_OnAvInterpChanged);

    // v5.20.6 (pedido del owner): usar el PAUSE de verdad. Cada vez
    // que se monta el avatar, el servidor hace UNA pausa momentanea
    // (0.1s por defecto): el cliente re-sincroniza el estado del
    // avatar y queda encajado — su descubrimiento hecho automatico
    // e invisible. sv_pausable queda FORZADO a 1 (config obligatoria)
    // mientras el modulo este cargado (aunque este cvar este en 0,
    // el sv_pausable sigue forzado: asi el pause manual siempre esta
    // disponible, tal como lo pidio).
    g_cvTailsPauseFix        = CreateConVar("tails_pausefix", "1.0", "Pulso de pausa tras montar el avatar (el fix que el owner descubrio con pause): 1 = automatico / 0 = desactivado", _, true, 0.0, true, 1.0);
    g_cvTailsPauseFixDelay   = CreateConVar("tails_pausefix_delay", "0.2", "Espera tras montar el avatar antes del pulso de pausa (segundos: hay que dejar que el cliente reciba el avatar primero)", _, true, 0.0, true, 5.0);
    g_cvTailsPauseFixDuration = CreateConVar("tails_pausefix_duration", "0.1", "Duracion de la pausa del pulso (segundos; imperceptible)", _, true, 0.05, true, 2.0);
    g_cvTailsPauseFixSpacing  = CreateConVar("tails_pausefix_spacing", "2.0", "v5.21: separacion minima en segundos entre INICIOS de pulso de pausa (anti flicker: cadenas de montaje ya no generan pause/unpause seguidos; tambien aplica a las peticiones SC)", _, true, 0.5, true, 30.0);

    // v5.25 "AVATAR REMOTO POR TP": la pausa solo re-encaja la vista
    // del DUEÑO; la copia R que ven los demas llega rota desde que
    // nace (parent + EF_NOINTERP). La R pasa al modo TP probado del
    // tails_follow: TeleportEntity por tick + reloj vivo y SIN
    // EF_NOINTERP -> los clientes de los demas la INTERPOLAN (suave,
    // sin depender de la pausa). La copia L del dueño NO cambia.
    // Gobierna la R de TODOS los avatares del suite (Tails/Sonic/Amy,
    // mismas reglas que tails_pausefix: UN solo sistema).
    g_cvTailsAvatarTP = CreateConVar("tails_avatar_tp", "1.0", "La copia R del avatar (la que ven LOS DEMAS) viaja por teleport por tick con interpolacion de red (modo TP del tails_follow): 1 = suave para los demas sin depender de la pausa / 0 = parentada como antes. La copia L del dueno queda parentada+pausa SIEMPRE", _, true, 0.0, true, 1.0);
    HookConVarChange(g_cvTailsAvatarTP, Tails_OnAvatarTPChanged);

    // v5.22: CONGELADO de infectados especiales (el stun de la witch
    // para todos). Reglas del owner: 1er toque del rayo = congelado
    // N segundos FIJOS (el rayo NUNCA reinicia el contador), puede
    // seguir empujando al congelado, y al descongelar SIEMPRE stagger.
    g_cvTailsSIFreeze     = CreateConVar("tails_sifreeze", "1", "El rayo congela a los infectados especiales (stun de la witch): 1 = on / 0 = solo dano y empuje clasico", _, true, 0.0, true, 1.0);
    g_cvTailsSIFreezeDur  = CreateConVar("tails_sifreeze_duration", "6.0", "Segundos FIJOS de congelado por 1er toque del rayo (el rayo NO reinicia el contador). Al terminar: stagger SIEMPRE", _, true, 0.5, true, 15.0);

    // v5.20.7 ZERO-NET: solo CACHE del cvar del motor (ya NO se fuerza a
    // 1: el admin decide; con 0 el pulso se omite y el re-encaje corre
    // por EF_NOINTERP) + FSM del pulso en reposo (por si es una recarga)
    Tails_PF_CachePausable();
    Tails_PauseFix_Reset();

    // v5.0 OM: toggle de modo del cañón (la tecla T de GMod)
    RegConsoleCmd("sm_tailscannon", Command_TailsCannon, "Tails: modo del cañón (H3 tecla C; Laser/Burst/Orbs/Shockwave)");

    // v5.20.3: sonda de valores VIVOS (owner: "¿por qué el cañón sigue
    // en 45?"). Muestra lo que el server usa AHORA y marca [NO FABRICA]
    // cuando un valor difiere del default que trae el smx.
    RegConsoleCmd("sm_tailscd", Command_TailsCd, "Tails: valores VIVOS del cañón/vuelo/avatar vs default de fábrica del smx");

    // v5.5: "bloq Mayús" de Roblox: fija el cuerpo del avatar a la mira
    // SIEMPRE (toggle por jugador, DESACTIVADO por defecto). El bloqueo
    // automático de la carga/disparo del cañón no depende de esto.
    RegConsoleCmd("sm_tailslock", Command_TailsLock, "Tails: bloqueo de cámara (bloq Mayús): cuerpo siempre hacia la mira (off por defecto)");

    HookEvent("player_death", Tails_Event_PlayerDeath);
    HookEvent("round_start", Tails_Event_RoundStart);
    HookEvent("heal_begin", Tails_Event_HealBegin);
    if (g_hTailsPassiveTimer != INVALID_HANDLE) KillTimer(g_hTailsPassiveTimer);
    g_hTailsPassiveTimer = CreateTimer(0.5, T_TailsPassiveLogic, _, TIMER_REPEAT);

    // v5.0 OM: FSM del avatar a 10 Hz (barato: itera solo si hay avatars)
    if (g_hTailsAvatarTimer != INVALID_HANDLE) KillTimer(g_hTailsAvatarTimer);
    g_hTailsAvatarTimer = CreateTimer(0.1, T_TailsAvatarThink, _, TIMER_REPEAT);
    
    // v5.20.3: AutoExecConfig ELIMINADO — config UNICA del suite
    // (cfg/sourcemod/Sonic_Suite.cfg, auto-guardada; ver manager
    // v3.75). El Tails_Abilities.cfg viejo ya no se genera ni se
    // ejecuta: donde exista queda muerto y se puede borrar.
}

public void Tails_OnMapStart()
{
    // v5.21: backoff de auto-montaje a cero (mapa nuevo = intentos frescos)
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iTailsRMountFails[i]   = 0;
        g_fTailsNextRMountTry[i] = 0.0;
        g_iTailsLMountFails[i]   = 0;
        g_fTailsNextLMountTry[i] = 0.0;
    }

    PrecacheSound(TAILS_SOUND_FLY_START, true);
    PrecacheSound(TAILS_SOUND_FLY_LOOP, true);
    PrecacheSound(TAILS_SOUND_CHARGE, true);
    PrecacheSound(TAILS_SOUND_LASER_LOOP, true);
    
    g_iSpriteLaser = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    g_iSpriteHalo = PrecacheModel("materials/sprites/glow01.vmt", true);
    g_iSpriteGlow = PrecacheModel("materials/sprites/redglow1.vmt", true); 

    // v5.0 OM: modelo del avatar (del VPK de recursos). Si el pack aun
    // no lo tiene, g_bTailsModelOK queda en false y el avatar se
    // desactiva en silencio (el resto del modulo funciona normal).
    g_bTailsModelOK = view_as<bool>(PrecacheModel(TAILS_OM_MODEL, true));

    // v5.0 OM: sonidos del cañón (equivalentes nativos L4D2)
    PrecacheSound(TAILS_OM_SOUND_UNLOCK, true);
    PrecacheSound(TAILS_OM_SOUND_READY, true);
    PrecacheSound(TAILS_OM_SOUND_ZAP, true);
    PrecacheSound(TAILS_OM_SOUND_ZAP2, true);
    PrecacheSound(TAILS_OM_SOUND_IMPACT, true);
    PrecacheSound(TAILS_OM_SOUND_TOGGLE, true);
    PrecacheSound(TAILS_OM_SOUND_BURST, true);
    PrecacheSound(TAILS_OM_SOUND_ORB_FIRE, true);
    PrecacheSound(TAILS_OM_SOUND_ORB_BOOM, true);
    PrecacheSound(TAILS_OM_SOUND_SHOCK, true);
    PrecacheSound(TAILS_OM_SOUND_ELEC, true);
    PrecacheModel(TAILS_OM_ORB_MODEL, true);

    // v4.3: los slots del acumulador de witches guardan refs de
    // entidades del mapa anterior (numericamente pueden repetirse en
    // el mapa nuevo) -> liberarlos todos aqui.
    Tails_WitchAccClearAll();

    // v5.27: el congelado ya no tiene estado propio — la limpieza de
    // mapa (restore de martillo/lagged/tint + slots) la hace el
    // OM_Stun v2.0 del manager (OM_Stun_OnMapEnd).

    // v5.4: igual con los avatars: las EntRef del mapa anterior son
    // invalidas aqui (el prop murio con el mapa) y el render guardado
    // del cuerpo ya no aplica (el player entity del capitulo nuevo
    // nace con render propio). Se limpia el slot completo; el think de
    // 10 Hz re-crea el avatar en cuanto el jugador spawnea.
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iTailsAvatar[i]     = 0;
        g_iTailsAvatarL[i]    = 0;     // v5.17-B
        g_iTailsBodyRender[i] = -1;
        g_iTailsAnimState[i]  = -1;
        g_bTailsSmSnap[i]     = true;     // v5.17-A: próximo avatar arranca pegado
    }

    // v5.20.7 ZERO-NET: sin pulsos huerfanos del mapa anterior + cache
    // del cvar del motor (sin forzar: el pulso y el pause manual solo
    // corren si el admin deja sv_pausable 1)
    Tails_PauseFix_Reset();
    Tails_PF_CachePausable();
}

// =======================
// Eventos y Limpieza
// =======================

public void Tails_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // v5.20.7 ZERO-NET: cache del cvar por si un game mode script lo
    // re-crea (ya NO se escribe: el pulso del avatar y el pause manual
    // solo funcionan si el admin mantiene sv_pausable 1).
    Tails_PF_CachePausable();

    for (int i = 1; i <= MaxClients; i++)
    {
        // v4.2 FIX: tambien resetear el flag de vuelo (quedaba en true
        // tras un round_restart a mitad de vuelo y el primer !fly solo
        // "cancelaba" un vuelo fantasma aplicando cooldown)
        g_bTailsFlying[i] = false;
        Tails_ResetStateExternal(i);
        g_fTailsFlyCooldown[i] = 0.0;
        g_fTailsLaserCooldown[i] = 0.0;
        g_iTailsLaserUses[i] = 0;      // v4.5: contador de usos del rayo
        g_bTailsRaygunMode[i] = false; // v4.5
        g_fTailsTongueAt[i]     = 0.0;    // v5.23: estado del agarre del smoker
        g_bTailsTongueFiring[i] = false;
        // v5.0 OM: resets de cañón/flight/ragdoll/boost (v5.4: el
        // avatar ya NO se mata aquí, ver el FIX de abajo)
        g_iTailsCannonMode[i]   = 0;
        g_fTailsToggleCD[i]     = 0.0;
        g_bTailsOrbSession[i]   = false;
        g_iTailsOrbsLeft[i]     = 0;
        g_bTailsCannonCding[i]  = false;
        g_bTailsFlyManual[i]    = false;
        g_fTailsFlyUpUntil[i]   = 0.0;
        g_fTailsFlyNextSnd[i]   = 0.0;
        g_fTailsSwBoostUntil[i] = 0.0;
        g_fTailsSwBoostBase[i]  = 0.0;
        if (g_hTailsBurstFreeze[i] != INVALID_HANDLE)
        {
            KillTimer(g_hTailsBurstFreeze[i]);
            g_hTailsBurstFreeze[i] = INVALID_HANDLE;
        }
        // v5.4 FIX (reinicio de ronda): el round_start ya NO mata el
        // avatar ni desengancha los hooks. En el reinicio de ronda del
        // MISMO mapa, L4D2 spawnea a los players ANTES de disparar
        // round_start: player_spawn ya habia recreado el avatar y
        // ocultado el cuerpo, y este KillAvatar lo mataba otra vez
        // (Tails desaparecia + cuerpo visible, exacto el bug del
        // owner). El ciclo de vida del avatar lo gestionan
        // player_spawn / player_death / cambio de personaje /
        // disconnect, y el think de 10 Hz lo auto-recrea si falta.
        // Los SDKUnhook tampoco: borraban el OnTakeDamage de
        // cancelacion por dano que player_spawn acababa de reponer
        // (mismo bug de orden) y los tres callbacks son self-guarding
        // (se desenganchan solos cuando su estado se apaga - y arriba
        // ya se apago).
    }

    // v5.20.2: REFRESH DE RONDA (hallazgo del owner). Ver el comentario
    // del convar tails_roundrefresh. TIMER_FLAG_NO_MAPCHANGE: si la
    // ronda/mapa cambia antes de que dispare, muere solo (la FSM monta
    // los avatares del mapa nuevo por su cuenta).
    float rr = g_cvTailsRoundRefresh.FloatValue;
    if (rr > 0.0)
        CreateTimer(rr, T_TailsRoundRefresh, _, TIMER_FLAG_NO_MAPCHANGE);
}

// v5.20.2: mata los avatares vivos de Tails; la FSM de auto-reparacion
// (T_TailsAvatarThink, 10 Hz) los recrea en <=0.1s por el camino del
// TIMER (player asentado) — exactamente el flujo del !sc que el owner
// reprodujo en campo: survivor visible una milesima de segundo y Tails
// vuelve a tomar su lugar, esta vez SIN retrazo ni linterna.
public Action T_TailsRoundRefresh(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iTailsAvatar[i] == 0) continue;       // no hay nada que refrescar
        if (!IsClientInGame(i)) continue;           // la FSM lo limpia aparte
        if (g_iPlayerCharIdx[i] != TAILS_INDEX) continue;
        Tails_KillAvatar(i);   // restaura el cuerpo (flash de survivor) -> FSM recrea
    }
    return Plugin_Stop;
}

public Action Tails_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && client <= MaxClients)
    {
        // v4.2 FIX: morir NO debe aplicar el cooldown de vuelo
        Tails_StopFlying(client, false);
        Tails_ResetStateExternal(client);
        // v5.0 OM: el avatar muere con el: ragdoll del modelo OM en la
        // posicion de muerte (GMod: CreateRagdolLCharacter_OM)
        if (g_iPlayerCharIdx[client] == TAILS_INDEX)
        {
            // v5.20: ventana anti-ragdoll del survivor. El mod de ragdolls
            // del owner revive el cuerpo del jugador al morir; para un
            // Tails ese cuerpo NO debe verse (es un avatar: solo queda el
            // ragdoll OM). OnEntityCreated filtra lo que aparezca cerca
            // en los próximos 2s (ver Tails_CheckDeathRagdoll).
            GetClientAbsOrigin(client, g_fTailsDeathOrigin[client]);
            g_fTailsDeathHideUntil[client] = GetEngineTime() + 2.0;
            Tails_SpawnDeathRagdoll(client);
            Tails_KillAvatar(client);
        }
    }
    return Plugin_Continue;
}

// v4.2: limpieza para cambio de personaje / disconnect (la llama el
// manager via CleanupCharModuleState). El indice de personaje aun
// es TAILS_INDEX en ese momento, el guard interno funciona.
public void Tails_OnPlayerDeath(int client)
{
    if (client <= 0 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    Tails_StopFlying(client, false);
    Tails_ResetStateExternal(client);
    // v5.0 OM: quitar avatar, restaurar cuerpo y soltar hooks propios
    Tails_KillAvatar(client);
    SDKUnhook(client, SDKHook_PreThink, Tails_SlowThink);
    SDKUnhook(client, SDKHook_OnTakeDamage, Tails_OnTakeDamage);
}

// v4.2: reset TOTAL del slot al conectar un cliente nuevo.
// Elimina handles colgados (stale) del cliente anterior y estados
// fantasma de vuelo/laser. Lo llama el manager en OnClientPutInServer.
public void Tails_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;

    // v5.21: estado de backoff fresco para el slot
    g_iTailsRMountFails[client]   = 0;
    g_fTailsNextRMountTry[client] = 0.0;
    g_iTailsLMountFails[client]   = 0;
    g_fTailsNextLMountTry[client] = 0.0;

    g_bTailsFlying[client]      = false;
    g_fTailsFuel[client]        = 0.0;
    g_fTailsFlyCooldown[client] = 0.0;
    g_bTailsCharging[client]    = false;
    g_bTailsFiring[client]      = false;
    g_fTailsLaserCooldown[client] = 0.0;
    g_fTailsChargeStartTime[client] = 0.0;
    g_fTailsFireEndTime[client]     = 0.0;
    g_hTailsActionTimer[client]     = INVALID_HANDLE;
    g_iTailsLaserUses[client]       = 0;    // v4.5
    g_bTailsRaygunMode[client]      = false; // v4.5
    g_iTailsAvatar[client]     = 0;          // v5.0 OM
    g_iTailsAvatarL[client]    = 0;          // v5.17-B
    g_fTailsJumpStart[client]  = 0.0;        // v5.20: fix Poppy del jump
    g_fTailsDeathHideUntil[client] = 0.0;    // v5.20: ventana anti-ragdoll
    g_bTailsSmSnap[client]     = true;       // v5.17-A: estado de smoothing limpio
    g_iTailsBodyRender[client] = -1;          // -1 = cuerpo no tocado
    g_iTailsAnimState[client]  = -1;
    g_fTailsAnimLock[client]   = 0.0;
    g_bTailsLock[client]       = false;      // v5.5: bloq Mayús OFF al conectar
    g_fTailsBodyYaw[client]    = 0.0;        // v5.5
    g_fTailsYawLastT[client]   = 0.0;        // v5.5
    g_bTailsFlyManual[client]  = false;
    g_fTailsFlyUpUntil[client] = 0.0;
    g_fTailsFlyNextSnd[client] = 0.0;
    g_iTailsCannonMode[client] = 0;
    g_fTailsToggleCD[client]   = 0.0;
    g_fTailsTintUntil[client]  = 0.0;         // v5.1
    g_bTailsOrbSession[client] = false;
    g_iTailsOrbsLeft[client]   = 0;
    g_bTailsCannonCding[client] = false;
    if (g_hTailsBurstFreeze[client] != INVALID_HANDLE)
    {
        KillTimer(g_hTailsBurstFreeze[client]);
        g_hTailsBurstFreeze[client] = INVALID_HANDLE;
    }
    g_fTailsSwBoostUntil[client] = 0.0;
    g_fTailsSwBoostBase[client]  = 0.0;
    g_fTailsLaserSndNext[client] = 0.0;   // v5.22: re-emit del loop del rayo
    g_fTailsTongueAt[client]      = 0.0;   // v5.23: estado del agarre del smoker
    g_bTailsTongueFiring[client]  = false;
    // v5.27: el slot del congelado lo limpia el OM_Stun del manager
    // (OM_Stun_OnClientDisconnect + validacion por userid anti-herencia)

    SDKUnhook(client, SDKHook_PreThink, Tails_FlyThink);
}

void Tails_ResetState(int client)
{
    // v4.2 FIX: guard contra indices invalidos (los timers de laser
    // pueden llegar aqui con client=0 tras un disconnect)
    if (client < 1 || client > MaxClients) return;

    // v5.2 OM R3: con el WAV real (4.5s) hay que CORTAR la carga al cancelar
    if (g_bTailsCharging[client]) {
        Tails_StopLoud(client, TAILS_SOUND_CHARGE);
    }
    g_bTailsCharging[client] = false;
    g_bTailsImpactPlayed[client] = false;
    
    if (g_bTailsFiring[client]) {
        Tails_StopLoud(client, TAILS_SOUND_LASER_LOOP); 
    }
    
    g_bTailsFiring[client] = false;
    g_fTailsTongueAt[client]     = 0.0;   // v5.23: estado del agarre del smoker
    g_bTailsTongueFiring[client] = false;
    
    // v4.2 FIX REENTRANCIA: este reset se llama desde DENTRO del
    // callback del propio timer de laser en algunos paths. Matar el
    // timer que esta en ejecucion es peligroso y ademas dejaba el
    // handle en un estado ambiguo. Ahora el handle solo se anula;
    // el timer muere solo devolviendo Plugin_Stop. El KillTimer queda
    // para los llamadores EXTERNOS (death/round) cuando el timer
    // realmente sigue vivo.
    if (g_hTailsActionTimer[client] != INVALID_HANDLE)
    {
        g_hTailsActionTimer[client] = INVALID_HANDLE;
    }
    // v5.22: el acumulador de stagger por SI (v4.3) se RETIRO: el rayo
    // congela al 1er toque (6s fijos) y el stagger cae al descongelar.
    // Estado por-victima, no por-atacante: nada que limpiar aqui.
    
    // v5.0 OM: ya no se toca m_flLaggedMovementValue (regla del suite).
    // El walk-forzado de la carga/disparo se suelta aquí también:
    if (IsClientInGame(client)) {
        SDKUnhook(client, SDKHook_PreThink, Tails_SlowThink);
    }
}

// v4.2: reset EXTERNO (desde eventos, no desde dentro del timer):
// si el timer de laser sigue vivo, se mata de verdad.
void Tails_ResetStateExternal(int client)
{
    if (client < 1 || client > MaxClients) return;

    if (g_hTailsActionTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hTailsActionTimer[client]);
        g_hTailsActionTimer[client] = INVALID_HANDLE;
    }
    Tails_ResetState(client);
}

// =======================
// PASIVA 1: ANIMAL SENSE (SENSE DE WITCHES & SI)
// =======================

public Action T_TailsPassiveLogic(Handle timer)
{
    int tailsCount = 0;
    int tailsClients[MAXPLAYERS + 1];
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (Tails_IsValidClient(i) && g_iPlayerCharIdx[i] == TAILS_INDEX)
        {
            tailsClients[tailsCount++] = i;

            // v5.0 OM: "tails cannon unlock" cuando expira el CD (el
            // think del pill lo hace igual). v5.2: WAV real del pack.
            if (g_bTailsCannonCding[i] && GetEngineTime() >= g_fTailsLaserCooldown[i])
            {
                g_bTailsCannonCding[i] = false;
                Tails_EmitLoud(i, TAILS_OM_SOUND_UNLOCK, SNDLEVEL_TRAIN, 120); // v5.3: 2 capas + 100dB + vol 1.0
                PrintCenterText(i, "Cañón listo");
            }
        }
    }
    
    // Si no hay ningun Tails en el juego, limpiamos los brillos residuales
    if (tailsCount == 0)
    {
        Tails_ClearAnimalSense();
        return Plugin_Continue;
    }
    
    float rangeSq = g_cvTailsSenseRange.FloatValue * g_cvTailsSenseRange.FloatValue;
    
    // Detectar Infectados Especiales
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;

        float targetPos[3];
        GetClientAbsOrigin(i, targetPos);
        
        bool inRange = false;
        for (int t = 0; t < tailsCount; t++)
        {
            float tPos[3]; GetClientAbsOrigin(tailsClients[t], tPos);
            if (GetVectorDistance(tPos, targetPos, true) <= rangeSq)
            {
                inRange = true;
                break;
            }
        }

        if (inRange)
        {
            SetEntProp(i, Prop_Send, "m_iGlowType", 3); 
            SetEntProp(i, Prop_Send, "m_glowColorOverride", 65535); // Amarillo REAL (255,255,0); el 16776960 era cian (0,255,255)
            SetEntProp(i, Prop_Send, "m_bFlashing", 1);
        }
        // v4.2 FIX FLICKER: solo limpiar el glow si es NUESTRO (amarillo).
        // Antes se pisaba el glow rosa de la Treasure Vision de Rouge
        // (y viceversa), produciendo parpadeo de colores cada tick.
        else if (GetEntProp(i, Prop_Send, "m_iGlowType") == 3
              && GetEntProp(i, Prop_Send, "m_glowColorOverride") == 65535)
        {
            SetEntProp(i, Prop_Send, "m_iGlowType", 0);
            SetEntProp(i, Prop_Send, "m_bFlashing", 0);
        }
    }
    
    // Detectar Witches
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (!IsValidEntity(witch)) continue;
        
        float targetPos[3];
        GetEntPropVector(witch, Prop_Send, "m_vecOrigin", targetPos);
        
        bool inRange = false;
        for (int t = 0; t < tailsCount; t++)
        {
            float tPos[3]; GetClientAbsOrigin(tailsClients[t], tPos);
            if (GetVectorDistance(tPos, targetPos, true) <= rangeSq)
            {
                inRange = true;
                break;
            }
        }

        if (inRange)
        {
            SetEntProp(witch, Prop_Send, "m_iGlowType", 3); 
            SetEntProp(witch, Prop_Send, "m_glowColorOverride", 65535); // Amarillo REAL (255,255,0); el 16776960 era cian (0,255,255)
            SetEntProp(witch, Prop_Send, "m_bFlashing", 1);
        }
        else if (GetEntProp(witch, Prop_Send, "m_iGlowType") == 3)
        {
            SetEntProp(witch, Prop_Send, "m_iGlowType", 0);
            SetEntProp(witch, Prop_Send, "m_bFlashing", 0);
        }
    }
    
    return Plugin_Continue;
}

void Tails_ClearAnimalSense()
{
    // Limpieza Especiales
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            // v4.2: solo limpiar brillos AMARILLOS (los nuestros)
            if (GetEntProp(i, Prop_Send, "m_iGlowType") == 3
              && GetEntProp(i, Prop_Send, "m_glowColorOverride") == 65535)
            {
                SetEntProp(i, Prop_Send, "m_iGlowType", 0);
                SetEntProp(i, Prop_Send, "m_bFlashing", 0);
            }
        }
    }
    // Limpieza Witches
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1)
    {
        if (IsValidEntity(witch))
        {
            // v4.2: solo brillos amarillos (nuestros)
            if (GetEntProp(witch, Prop_Send, "m_iGlowType") == 3
              && GetEntProp(witch, Prop_Send, "m_glowColorOverride") == 65535)
            {
                SetEntProp(witch, Prop_Send, "m_iGlowType", 0);
                SetEntProp(witch, Prop_Send, "m_bFlashing", 0);
            }
        }
    }
}

// =======================
// PASIVA 2: MEDIC SUPPORT
// =======================

public void Tails_Event_HealBegin(Event event, const char[] name, bool dontBroadcast)
{
    int healer = GetClientOfUserId(event.GetInt("userid"));
    if (!Tails_IsValidClient(healer)) return;

    // v4.4: el evento heal_begin puede llegar ANTES de que el motor
    // haya escrito la barra (m_flProgressBarDuration = 0 -> la
    // version antigua se saltaba todo en silencio). Aplicamos aqui
    // (si las props ya estan) y tambien desde el forward
    // L4D2_OnStartUseAction_Post, que es el momento garantizado.
    Tails_ApplyHealBoost(healer);
}

// v4.4: forward de left4dhooks. Se dispara DESPUES de que
// CTerrorPlayer::StartUseAction() termine: las props de la barra de
// progreso YA estan escritas y la accion esta registrada en
// m_iCurrentUseAction. Este es el momento seguro para acortar la
// curacion. (action 1 = L4D2n_Healing, ver left4dhooks_stocks.inc).
public void L4D2_OnStartUseAction_Post(L4D2UseAction action, int client, int target)
{
    if (action != L4D2UseAction_Healing) return;  // solo acciones de curacion
    if (!Tails_IsValidClient(client)) return;
    Tails_ApplyHealBoost(client);
}

// v4.4: nucleo compartido del boost de curacion. Aplica la
// aceleracion SOLO si hay una accion de curar activa con barra
// valida y un Tails cerca del sanador. Idempotente (sello de
// tiempo de 0.5s: el evento y el forward del mismo frame no
// re-aplican el divisor dos veces).
void Tails_ApplyHealBoost(int healer)
{
    if (!Tails_IsValidClient(healer)) return;
    if (g_cvTailsHealBoost == null) return;

    // Anti doble-aplicacion (heal_begin + forward en el mismo frame)
    float now = GetEngineTime();
    if (now - g_fTailsHealBoostAt[healer] < 0.5) return;

    // Doble validacion: hay una accion de CURAR activa ahora mismo
    // y su barra de progreso ya existe (duracion > 0).
    if (GetEntProp(healer, Prop_Send, "m_iCurrentUseAction") != view_as<int>(L4D2UseAction_Healing)) return;
    float duration = GetEntPropFloat(healer, Prop_Send, "m_flProgressBarDuration");
    if (duration <= 0.0) return;

    // Hay un Tails a menos de 250 unidades del sanador?
    bool tailsNearby = false;
    float healerPos[3]; GetClientAbsOrigin(healer, healerPos);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (Tails_IsValidClient(i) && g_iPlayerCharIdx[i] == TAILS_INDEX)
        {
            float tailsPos[3]; GetClientAbsOrigin(i, tailsPos);
            if (GetVectorDistance(healerPos, tailsPos) < 250.0)
            {
                tailsNearby = true;
                break;
            }
        }
    }
    if (!tailsNearby) return;

    // Sellar la aplicacion de ESTA curacion
    g_fTailsHealBoostAt[healer] = now;

    float boost = g_cvTailsHealBoost.FloatValue;
    if (boost < 1.0) boost = 1.0;
    float newDuration = duration / boost;
    float newTime = GetGameTime() + newDuration;

    // 1. Sincronizar la barra visual (el motor relee esta duracion
    //    en cada think de la accion: acorta la curacion de verdad).
    SetEntPropFloat(healer, Prop_Send, "m_flProgressBarDuration", newDuration);
    SetEntPropFloat(healer, Prop_Send, "m_flProgressBarStartTime", GetGameTime());

    // 2. FORZAR AL ARMA A TERMINAR ANTES
    int weapon = GetEntPropEnt(healer, Prop_Send, "m_hActiveWeapon");
    if (weapon > 0 && IsValidEntity(weapon))
    {
        SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", newTime);

        // Algunas armas usan este timer secundario para la animacion de uso
        if (HasEntProp(weapon, Prop_Send, "m_flTimeWeaponIdle"))
        {
            SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", newTime);
        }
    }

    // 3. FORZAR AL JUGADOR A PODER ACTUAR ANTES
    SetEntPropFloat(healer, Prop_Send, "m_flNextAttack", newTime);

    // v4.4: sin emojis (no se renderizan bien en el HUD de L4D2)
    PrintCenterText(healer, "¡Soporte de Tails! Curacion x%.1f mas rapida", boost);

    // Feedback Visual del Aura
    float hPos[3]; GetClientAbsOrigin(healer, hPos); hPos[2] += 10.0;
    TE_SetupBeamRingPoint(hPos, 10.0, 150.0, g_iSpriteHalo, 0, 0, 0, 1.0, 10.0, 0.0, {0, 255, 0, 200}, 0, 0);
    TE_SendToAll();
}

// ============================================================
//  v5.0 OM: AVATAR ESPEJO (el "puppet" del pill de GMod)
// ============================================================
// prop_dynamic_override + tails.mdl PARENTADO al survivor (v5.6: el
// parent VUELVE, como v5.4 — el MOTOR mueve al avatar junto al cuerpo
// en cada cliente: cero delay de red y animaciones suaves como v5.4.
// El pitch heredado del v5.4 NO vuelve: Tails_AvatarFollow escribe
// cada tick los ángulos LOCALES exactos que lo cancelan). El cuerpo
// del survivor se oculta (RENDER_NONE) y el avatar reproduce las
// secuencias del MDL siguiendo la MISMA maquina de estados que el
// ShouldAlternate del pill_om_tails de GMod:
//   downed > roll(sin usar) > GLIDE(vuelo) > ShootingReady(carga/
//   disparo) > lowhealth(<=60) > suelo(idle/walk/run) > aire(jump/fall)
// PlaybackRates GMod: walk 1.8x (ref 60 uu/s), run 1.1x (ref 412 uu/s,
// se escala con la velocidad real para que Speed_sonic se vea rapido),
// glide = "clampval" (el aleteo se apaga con el combustible, exacto al
// animrates.fall del GMod).

public void Tails_Event_PlayerSpawn(int client)
{
    if (client < 1 || client > MaxClients) return;

    // reset defensivo del slot y re-creación del avatar
    Tails_KillAvatar(client);
    g_iTailsAnimState[client] = -1;
    g_fTailsAnimLock[client]  = 0.0;

    // v5.0 OM: hook de cancelación por daño (GMod:
    // OM_DamageBeforeCustomFunction cancela vuelo + láser al recibir daño)
    SDKUnhook(client, SDKHook_OnTakeDamage, Tails_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Tails_OnTakeDamage);

    if (g_iPlayerCharIdx[client] != TAILS_INDEX) return;
    if (!g_cvTailsAvatar.BoolValue) return;
    Tails_CreateAvatar(client);
}

// =====================================================================
// v5.28-B (manager 3.77.40): ADOPCION EN EL MONTAJE — el reemplazo del
// barrido en caliente (orden del owner 2026-10-10: "tu barrido de
// avatares esta haciendo reiniciar mi avatar a cada rato... BUSCA OTRA
// MANERA"). Esta FSM es la UNICA creadora de props con los nombres de
// abajo: un prop asi que ELLA no rastrea es un huerfano por definicion
// (lo fabrico una vida anterior, un montaje doble del pasado o una
// version vieja del suite) y muere en el instante exacto del montaje.
// Un avatar rastreado es INTOCABLE: no existe ningun timer que lo mire.
// =====================================================================
bool Tails_IsMyAvatarRef(int ref)
{
    // v3.77.40: el 0 es "sin avatar"; un ref NEGATIVO puede ser
    // perfectamente legitimo (bit alto del serial del handle).
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iTailsAvatar[i] == ref) return true;
        if (g_iTailsAvatarL[i] == ref) return true;
    }
    return false;
}

void Tails_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "tails_avatar_om", "tails_avatar_om_l", "tails_avatar", "tails_avatar_tp" };
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
                if (Tails_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
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
        PrintToServer("[Tails v5.28-B] Adopcion del montaje: %d huerfano(s) del avatar eliminado(s).", ng);
}

void Tails_CreateAvatar(int client)
{
    if (!g_bTailsModelOK) return;                 // el VPK aún no trae el modelo
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;       // solo survivors

    // v5.28-B (manager 3.77.40): REEMPLAZO LIMPIO — orden del owner
    // 2026-10-10: en caliente YA NO EXISTE barrido. Si este cliente ya
    // tenia un R o L vivo (montaje doble por orden raro de eventos),
    // muere AQUI enterito: jamas vuelve a quedar un prop sin dueno (la
    // fabrica de huerfanos del "= 0" sin Kill queda cerrada).
    {
        int oldR = EntRefToEntIndex(g_iTailsAvatar[client]);
        if (g_iTailsAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Tails_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iTailsAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iTailsAvatarL[client]);
        if (g_iTailsAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Tails_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iTailsAvatarL[client] = 0;
    }

    // v5.28-B: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje, no en un
    // timer a ciegas.
    Tails_KillGhostAvatarProps();

    int av = CreateEntityByName("prop_dynamic_override");
    if (av <= 0 || !IsValidEntity(av)) return;

    DispatchKeyValue(av, "model", TAILS_OM_MODEL);
    DispatchKeyValue(av, "targetname", "tails_avatar_om");
    DispatchKeyValue(av, "solid", "0");
    DispatchKeyValue(av, "disableshadows", "1");
    DispatchSpawn(av);

    // v5.6: SEGUIMIENTO SUAVE — el parent VUELVE. El v5.5 lo quitó
    // (por el pitch heredado) y siguió al jugador con TeleportEntity
    // por tick: eso dejó el movimiento desfazado (1 tick + lerp del
    // cliente, el "como con lerps bajos" del owner) Y secó las
    // transiciones de animación (el cliente ya no interpola al avatar
    // con un historial estable como en v5.4). Con el SetParent, el
    // MOTOR/cliente mueve al avatar junto al survivor: cero delay,
    // cero teleport por tick, anims suaves de nuevo. El bug del pitch
    // NO vuelve: Tails_AvatarFollow escribe cada tick los ángulos
    // LOCALES que cancelan exactamente el pitch/roll del parent.
    float pos[3], ang[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    ang[0] = 0.0;                          // v5.5: pitch NUNCA
    ang[2] = 0.0;                          // v5.5: roll NUNCA
    g_fTailsBodyYaw[client]  = ang[1];     // v5.5: yaw inicial del cuerpo
    g_fTailsYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    // v5.17-A: estado del smoothing = valor inicial escrito (sin rampa
    // de arranque) + snap por si acaso (primer tick pega seco). v5.25:
    // se inicializa SIEMPRE (la semilla la usa la copia L que nace a
    // continuacion y el fallback parentado; en R-TP no se toca el prop).
    float loc[3];
    Tails_AvatarLocalAngles(ang[0], ang[1], g_fTailsBodyYaw[client], loc);
    for (int k = 0; k < 3; k++)
    {
        g_fTailsSmLoc[client][k]  = loc[k];
        g_fTailsSmLead[client][k] = 0.0;
    }
    g_bTailsSmSnap[client] = true;

    if (!g_cvTailsFollow.BoolValue && !Tails_AvatarTPOn())
    {
        // MODO 0 (default): parentado al survivor — la POSICIÓN queda
        // a cargo del motor (local origin (0,0,0) = pegado al survivor,
        // como v5.4); la orientación la controla Tails_AvatarFollow en
        // ángulos locales. Inicial: contra-rotación exacta del parent
        // (cuerpo vertical mirando al yaw inicial).
        SetVariantString("!activator");
        AcceptEntityInput(av, "SetParent", client);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", loc);

        // v5.20.5 FIX DEL "PAUSE": nacer ya ENCAJADO. El hallazgo del
        // owner (pause cura el tilt toda la partida; !sc lo reintroduce)
        // demostro que el estado roto nace CON la entidad: el historial
        // de interpolacion con el que el cliente monta el prop desde el
        // primer snapshot. EF_NOINTERP lo elimina de raiz (ver helper).
        Tails_SetAvatarNoInterp(av, g_cvTailsAvInterp.BoolValue);
    }
    // v5.25 MODO R-TP (tails_avatar_tp 1, default): la copia R nace SIN
    // parent y SIN EF_NOINTERP — ya quedó en pose MUNDO (pos + (0, yaw,
    // 0)) por el TeleportEntity de arriba; Tails_AvatarFollow la mueve
    // por tick y los clientes de los DEMAS la interpolan solos.
    // (en tails_follow 1 la R es el avatar único TP de siempre)
    // MODO 1 (tails_follow 1): sin parent — el follow hace
    // TeleportEntity por tick (comportamiento v5.5, ahora en PostThink).
    SDKHook(client, SDKHook_PostThink, Tails_AvatarFollow);

    // anim inicial
    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");
    g_iTailsAnimState[client] = 0;

    // v5.17-B: la copia del dueño (L) — solo si el dual está activo
    // y estamos en modo parentado (en teleport diag no hay dual)
    g_iTailsAvatarL[client] = 0;
    if (g_cvTailsLocalParent.BoolValue && !g_cvTailsFollow.BoolValue)
        Tails_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora).
    // El viewmodel en primera persona no se toca (el arma se ve igual).
    // v5.4: NO guardar RENDER_NONE como "modo a restaurar": si el motor
    // dejo el cuerpo ya invisible de un ciclo anterior sin KillAvatar
    // limpio (reset a mitad de camino), restaurarlo dejaria al survivor
    // invisible para siempre al quitar el avatar. Se guarda el ultimo
    // modo VALIDO.
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iTailsBodyRender[client] = view_as<int>(curMode);
    else if (g_iTailsBodyRender[client] == -1)
        g_iTailsBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    g_iTailsAvatar[client] = EntIndexToEntRef(av);

    // v5.20.6: PULSO DE PAUSA REAL (pedido del owner). Aqui el avatar
    // quedo montado (R y L juntas): agendar el pulso que re-encaja
    // el estado del cliente automaticamente (ver el bloque del
    // PauseFix junto a Tails_SetAvatarNoInterp).
    Tails_PauseFix_Trigger(client);
}

void Tails_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;

    Tails_KillAvatarL(client);                    // v5.17-B: la copia L también

    if (g_iTailsAvatar[client] != 0)
    {
        int av = EntRefToEntIndex(g_iTailsAvatar[client]);
        if (av > 0 && IsValidEntity(av))
        {
            SDKUnhook(av, SDKHook_SetTransmit, Tails_TransmitAvatarR);   // v5.17-B
            AcceptEntityInput(av, "Kill");
        }
        g_iTailsAvatar[client] = 0;
        g_fTailsTintUntil[client] = 0.0;      // v5.1: el avatar nuevo nace blanco
        g_bTailsSmSnap[client]   = true;      // v5.17-A: próximo avatar arranca pegado
        SDKUnhook(client, SDKHook_PostThink, Tails_AvatarFollow);   // v5.6: PostThink
    }

    // restaurar el cuerpo SI seguimos siendo Tails con render escondido
    if (IsClientInGame(client) && g_iTailsBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iTailsBodyRender[client]));
        g_iTailsBodyRender[client] = -1;
    }
    g_iTailsAnimState[client] = -1;
}

// ============================================================
//  v5.17-B: LA COPIA L (avatar dual, solo el dueño la ve)
// ============================================================

// v5.17-B: L solo viaja al dueño. El dueño se busca comparando la
// entidad contra los EntRefs vivos (sin depender de netprops raras;
// el mismo patrón de búsqueda que usan los filters del suite).
public Action Tails_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iTailsAvatarL[i] != 0 && EntRefToEntIndex(g_iTailsAvatarL[i]) == entity)
        {
            if (client == i) return Plugin_Continue;   // el dueño sí
            return Plugin_Handled;                     // nadie más
        }
    }
    return Plugin_Continue;   // huérfana: no filtrar (visible si algo raro pasa)
}

// v5.17-B: R viaja a todos MENOS al dueño, y SOLO mientras su copia L
// viva (si L murió o el dual se apagó, el dueño vuelve a ver R = v5.11).
public Action Tails_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iTailsAvatar[i] != 0 && EntRefToEntIndex(g_iTailsAvatar[i]) == entity)
        {
            if (client == i && g_iTailsAvatarL[i] != 0
                && EntRefToEntIndex(g_iTailsAvatarL[i]) > 0)
                return Plugin_Handled;   // el dueño tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

// v5.17-B: crea la copia L — idéntica a R (mismo modelo, parent, offset
// 0, FSM compartida) pero su contra-rotación se calcula contra los EYE
// ANGLES del dueño: SU cliente arma el transform del parent con el
// cuerpo PREDICHO (cámara completa: pitch+yaw), así que cancelar los eye
// angles deja el cuerpo VERTICAL EN SU PANTALLA. La copia R sigue con
// GetClientAbsAngles (lo que arman los clientes del resto).
void Tails_CreateAvatarL(int client)
{
    if (!g_bTailsModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iTailsAvatar[client] == 0) return;      // R debe existir primero

    int av = CreateEntityByName("prop_dynamic_override");
    if (av <= 0 || !IsValidEntity(av)) return;

    DispatchKeyValue(av, "model", TAILS_OM_MODEL);
    DispatchKeyValue(av, "targetname", "tails_avatar_om_l");
    DispatchKeyValue(av, "solid", "0");
    DispatchKeyValue(av, "disableshadows", "1");
    DispatchSpawn(av);

    float pos[3], ang[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    ang[0] = 0.0;                          // pitch NUNCA (mundo)
    ang[2] = 0.0;                          // roll NUNCA (mundo)
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    // mismo parent y mismo offset local (0,0,0) que R: la posición la
    // mueve el motor en el cliente del dueño (misma suavidad que R)
    SetVariantString("!activator");
    AcceptEntityInput(av, "SetParent", client);

    // contra-rotación inicial contra los EYE del dueño (NO los abs)
    float eye[3], loc[3];
    GetClientEyeAngles(client, eye);
    Tails_AvatarLocalAngles(eye[0], eye[1], g_fTailsBodyYaw[client], loc);
    if (HasEntProp(av, Prop_Send, "m_angRotation"))
        SetEntPropVector(av, Prop_Send, "m_angRotation", loc);

    // estado del smoothing de L = valor inicial escrito
    for (int k = 0; k < 3; k++)
        g_fTailsSmLocL[client][k] = loc[k];

    // v5.20.5: la copia L nace igual de ENCAJADA (ver CreateAvatar)
    Tails_SetAvatarNoInterp(av, g_cvTailsAvInterp.BoolValue);

    SDKHook(av, SDKHook_SetTransmit, Tails_TransmitAvatarL);

    // anim inicial = la de R
    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");

    g_iTailsAvatarL[client] = EntIndexToEntRef(av);

    // y ahora R deja de transmitirse al dueño (su copia es L)
    int r = EntRefToEntIndex(g_iTailsAvatar[client]);
    if (r > 0 && IsValidEntity(r))
        SDKHook(r, SDKHook_SetTransmit, Tails_TransmitAvatarR);
}

// v5.17-B: mata SOLO la copia L (R vuelve a verse para todos = v5.11).
void Tails_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iTailsAvatarL[client] == 0) return;

    int avL = EntRefToEntIndex(g_iTailsAvatarL[client]);
    if (avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Tails_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iTailsAvatarL[client] = 0;
}

// FSM del avatar: timer global a 10 Hz (barato: 32 slots con checks
// triviales; ademas AUTO-REPARA y REAFIRMA el estado, v5.4)
public Action T_TailsAvatarThink(Handle timer)
{
    float now = GetEngineTime();               // v5.1: expiración del tint
    for (int i = 1; i <= MaxClients; i++)
    {
        // v5.4 FIX: AUTO-REPARACION del avatar. Si un player_spawn se
        // perdio o llego en mal orden (en el reinicio de ronda L4D2
        // spawnea ANTES del round_start; en el capitulo nuevo el spawn
        // llega antes de que el director termine de montar la ronda),
        // el slot queda sin avatar. Igual que el pill de GMod: en
        // cuanto el jugador cumple las condiciones, el think lo vuelve
        // a montar (demora maxima 0.1s).
        if (g_iTailsAvatar[i] == 0)
        {
            if (g_cvTailsAvatar.BoolValue && g_bTailsModelOK
                && IsClientInGame(i) && IsPlayerAlive(i)
                && GetClientTeam(i) == 2
                && g_iPlayerCharIdx[i] == TAILS_INDEX
                && now >= g_fTailsNextRMountTry[i])      // v5.21: backoff de reintentos
            {
                Tails_CreateAvatar(i);
                if (g_iTailsAvatar[i] != 0)
                    g_iTailsRMountFails[i] = 0;          // v5.21: exito -> reset
                else
                {
                    // v5.21: montaje fallido (sin edicts / spawn rechazado):
                    // escalar el reintento en vez de reventar a 10 Hz para siempre
                    g_iTailsRMountFails[i]++;
                    g_fTailsNextRMountTry[i] = now + Tails_MountBackoff(g_iTailsRMountFails[i]);
                }
            }
            continue;
        }
        if (!IsClientInGame(i)) { Tails_KillAvatar(i); continue; }

        int av = EntRefToEntIndex(g_iTailsAvatar[i]);
        if (av <= 0 || !IsValidEntity(av)) { g_iTailsAvatar[i] = 0; continue; }

        // v5.1: tint del laserswap (H3): al expirar, avatar a blanco
        if (g_fTailsTintUntil[i] != 0.0 && now >= g_fTailsTintUntil[i])
        {
            SetEntityRenderColor(av, 255, 255, 255, 255);
            // v5.17-B: la copia L también
            if (g_iTailsAvatarL[i] != 0)
            {
                int avLT = EntRefToEntIndex(g_iTailsAvatarL[i]);
                if (avLT > 0 && IsValidEntity(avLT))
                    SetEntityRenderColor(avLT, 255, 255, 255, 255);
            }
            g_fTailsTintUntil[i] = 0.0;
        }

        // v5.4: quitar el avatar si dejo de ser un survivor de Tails
        // vivo (paridad con el guard de creacion, que exige equipo 2)
        if (g_iPlayerCharIdx[i] != TAILS_INDEX || !IsPlayerAlive(i)
            || GetClientTeam(i) != 2)
        {
            Tails_KillAvatar(i);   // el player_death ya puso el ragdoll OM
            continue;
        }

        // v5.4 FIX (cambio de capitulo): el motor re-inicializa el
        // render del player DESPUES del evento player_spawn del mapa
        // nuevo y el RENDER_NONE del cuerpo se perdia (Tails reaparecia
        // PERO el cuerpo tambien, exacto el bug del owner). Reafirmarlo
        // aqui: la deriva maxima es 0.1s y cura cualquier reset del
        // motor (spawn de capitulo, incap, rescue, etc).
        if (g_iTailsBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
        {
            SetEntityRenderMode(i, RENDER_NONE);
        }

        // ---- v5.17-B: ciclo de vida de la copia L (auto-reparación) ----
        // v5.21: la reparacion ya NO es a ciegas cada 0.1s — backoff al
        // fallar y pulso SOLO cuando el montaje EXITE (el patron que ya
        // usaban Amy/Blaze). El bug de la v5.20.x: con el montaje L
        // fallando (VPK sin modelo, sin edicts libres), el trigger
        // INCONDICIONAL pedia un pulso de pausa CADA 0.1s y la FSM los
        // re-disparaba en cadena = el juego haciendo pause/unpause sin
        // parar ("el l4 se pause en multiples ocasiones") + churn de
        // entidades a 10 Hz.
        if (g_iTailsAvatarL[i] != 0)
        {
            int avLc = EntRefToEntIndex(g_iTailsAvatarL[i]);
            if (avLc <= 0 || !IsValidEntity(avLc))
                g_iTailsAvatarL[i] = 0;   // ref muerta: limpiar
        }
        if (g_iTailsAvatarL[i] == 0 && g_cvTailsLocalParent.BoolValue
            && !g_cvTailsFollow.BoolValue
            && now >= g_fTailsNextLMountTry[i])          // v5.21: backoff de reintentos
        {
            Tails_CreateAvatarL(i);       // faltante: montarla
            if (g_iTailsAvatarL[i] != 0)
            {
                // v5.21: montaje tardio de la copia L exitoso (entidad
                // nueva que ve el dueño) -> pulso. Con uno en curso, la
                // FSM lo deja encolado como refuerzo.
                g_iTailsLMountFails[i] = 0;
                Tails_PauseFix_Trigger(i);
            }
            else
            {
                g_iTailsLMountFails[i]++;
                g_fTailsNextLMountTry[i] = now + Tails_MountBackoff(g_iTailsLMountFails[i]);
            }
        }
        else if (g_iTailsAvatarL[i] != 0 && (!g_cvTailsLocalParent.BoolValue
                 || g_cvTailsFollow.BoolValue))
        {
            Tails_KillAvatarL(i);         // el dual se apagó: quitarla
        }

        Tails_AvatarUpdate(i, av);
    }
    return Plugin_Continue;
}

void Tails_AvatarUpdate(int client, int av)
{
    float now = GetEngineTime();
    if (now < g_fTailsAnimLock[client]) return;   // one-shot en curso

    int state = 0;
    float rate = 1.0;

    bool incap  = GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0;
    bool shoot = g_bTailsCharging[client] || g_bTailsFiring[client] || g_bTailsOrbSession[client];
    bool lowhp = GetClientHealth(client) <= 60;   // GMod: LowestHealthCount <= 60

    if (incap)
    {
        state = 8;   // DownedIdle (L4D2 no gatea en incap vanilla)
    }
    else if (g_bTailsFlying[client])
    {
        state = 5;   // glide
        rate = Tails_FlightPower(client);   // se apaga con el combustible
    }
    else if (shoot)
    {
        state = (Tails_Speed2D(client) > 40.0) ? 7 : 6;
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // v5.22 (pedido owner: "cuando tails esta haciendo su animacion
        // de erido ya no usa su animacion de jump restaurasela"): la
        // rama de AIRE ahora gana al LowHealth. En la FSM vieja el
        // LowHealth (HP <= 60) estaba ARRIBA del aire: un Tails herido
        // que saltaba se quedaba en las anims de SUELO del LowHealth
        // en pleno salto (el mdl no tiene anims lowhealth de aire: en
        // GMod OM el salto herido tambien es el jump normal). El
        // LowHealth queda como variante de SUELO, como siempre.
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[2] > 40.0)
        {
            state = 3;   // subiendo: jump
        }
        else
        {
            // v5.20 (fix Poppy): la anim de jump ya NO se corta al
            // caer la velocidad vertical: se reproduce COMPLETA
            // mientras siga en el aire. El rayo (cargando/disparando,
            // estados 6/7) y el glide (estado 5) la interrumpen por
            // prioridad del if-else superior, igual que en GMod.
            bool jumpLive = false;
            if (g_iTailsAnimState[client] == 3)
            {
                float jt = now - g_fTailsJumpStart[client];
                if (jt < 0.5)      jumpLive = true;   // ventana mínima
                else if (jt < 1.5 && !Tails_JumpAnimDone(av))
                    jumpLive = true;                   // anim sin terminar (tope 1.5s)
            }
            state = jumpLive ? 3 : 4;
        }
    }
    else if (lowhp)
    {
        // v5.22: LowHealth = variante de SUELO (en el aire ya se fue
        // por la rama de arriba: jump/fall aunque esté herido).
        float s = Tails_Speed2D(client);
        if (s < 40.0)       state = 9;
        else if (s < 100.0) state = 10;
        else                state = 11;
    }
    else
    {
        float s = Tails_Speed2D(client);
        if (s < 40.0)
            state = 0;
        else if (s < 100.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = 1;
            rate = 1.8 * (s / 60.0);          // GMod animrates.walk
            if (rate > 2.5) rate = 2.5;
        }
        else
        {
            state = 2;
            rate = 1.32 * (s / 412.0);        // v5.20: run +20% (GMod 1.1 -> 1.32), sigue escalando con la velocidad real
            if (rate < 0.72) rate = 0.72;      // v5.20: piso y tope escalados +20%
            if (rate > 3.6) rate = 3.6;
        }
    }

    if (state != g_iTailsAnimState[client])
    {
        if (state == 3) g_fTailsJumpStart[client] = now;   // v5.20: marca de inicio del jump (fix Poppy)
        SetVariantString(g_sTailsAnimSeq[state]);
        AcceptEntityInput(av, "SetAnimation");
        // v5.17-B: la copia L repite la animación (mismo estado FSM)
        // v5.20.1 FIX "no sequence named:": el variant de SourceMod es
        // de UN SOLO USO — el AcceptEntityInput de R (línea de arriba)
        // ya lo consumió. Sin re-armarlo, el fire de L salía con el
        // nombre VACÍO: el engine imprimía el warning y la copia L se
        // quedaba clavada en la anim de spawn para siempre (la "pose T"
        // que ve el dueño cada vez que camina/corre/salta/vuela).
        if (g_iTailsAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iTailsAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                SetVariantString(g_sTailsAnimSeq[state]);
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iTailsAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;                 // nunca congelar el aleteo
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    // v5.17-B: playback rate también en L
    if (g_iTailsAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iTailsAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

// v5.20 (fix Poppy): ¿terminó la secuencia "jump" del avatar? La
// secuencia no loopea: m_flCycle [0..1] queda clavado en ~1.0 al
// terminar. Si la prop no existiera en el modelo/entidad, devuelve
// false y el FSM aplica el tope duro de 1.5s (nunca se cuelga).
bool Tails_JumpAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return false;
}

// v5.20: puente para el módulo Speed_sonic (include ANTERIOR a este en
// el manager; SourcePawn resuelve la llamada igual). Devuelve las
// entidades del avatar para efectos que deben salir del CUERPO DE
// TAILS (el survivor viaja en RENDER_NONE):
//   forOwner  = copia L (la que ve el dueño) o el avatar único
//   forOthers = copia R (la que ven los demás) o el avatar único
// false = el jugador no tiene avatar vivo (usar el player como antes).
bool Tails_GetAvatarEnts(int client, int &forOwner, int &forOthers)
{
    forOwner = forOthers = -1;
    if (client < 1 || client > MaxClients) return false;
    if (g_iTailsAvatar[client] == 0) return false;
    int av = EntRefToEntIndex(g_iTailsAvatar[client]);
    if (av <= 0 || !IsValidEntity(av)) return false;
    forOthers = av;
    forOwner  = av;
    if (g_iTailsAvatarL[client] != 0)   // dual v5.17-B activo (follow 0)
    {
        int avL = EntRefToEntIndex(g_iTailsAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL)) forOwner = avL;
    }
    return true;
}

// One-shot del avatar (ShootingBurst / ShootingOrbShoot): bloquea la FSM
// para que el loop no pise la animación de disparo
void Tails_AvatarOneShot(int client, const char[] seq, float lockTime)
{
    if (g_iTailsAvatar[client] == 0) return;
    int av = EntRefToEntIndex(g_iTailsAvatar[client]);
    if (av <= 0 || !IsValidEntity(av)) return;

    SetVariantString(seq);
    AcceptEntityInput(av, "SetAnimation");
    g_fTailsAnimLock[client] = GetEngineTime() + lockTime;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", 1.25);  // GMod: 1*1.25

    // v5.17-B: la copia L repite el one-shot
    if (g_iTailsAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iTailsAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetVariantString(seq);
            AcceptEntityInput(avL, "SetAnimation");
            if (HasEntProp(avL, Prop_Data, "m_flPlaybackRate"))
                SetEntPropFloat(avL, Prop_Data, "m_flPlaybackRate", 1.25);
        }
    }
}

// v5.11: estampa el reloj del server en m_flSimulationTime de una
// entidad que movemos por tick (mismo write que hace el motor al
// simular: ENTERO + tickcount; en L4D2 el SendProp es DPT_Int —
// escribirlo como float lanza "type is not float" en cada tick, el
// bug de la v5.9). La usaba SOLO el modo diagnostico tails_follow 1
// (teleport por tick); desde v5.20.5 TAMBIEN el modo 0 parentado
// (reloj vivo: un prop no simulado nunca lo avanza solo y la
// interpolacion del cliente queda contra marcas viejas — ver
// Tails_AvatarFollow).
void Tails_MarkInterp(int ent)
{
    if (ent <= 0 || !IsValidEntity(ent)) return;
    if (HasEntProp(ent, Prop_Send, "m_flSimulationTime"))
        SetEntProp(ent, Prop_Send, "m_flSimulationTime", GetGameTickCount());
}

// v5.20.5 FIX DEL "PAUSE": aplica/quita EF_NOINTERP (0x40) en m_fEffects.
// Le dice al cliente que NO interpole los netprops de transformacion de
// ESTA entidad: render = siempre el ultimo valor recibido. Asi el avatar
// no arrastra el historial de interpolacion con el que nace (el estado
// que `pause` re-encajaba y que la recreacion por !sc volvia a sembrar).
// La suavidad NO depende de esa interpolacion: el smoothing de angulos
// ya lo hace el SERVER (tails_angdamp, v5.17-A) y la POSICION sigue al
// 100% a cargo del motor via el parent (la interpolacion del survivor
// NO se toca: solo la del prop avatar).
#define TAILS_EF_NOINTERP 0x40
void Tails_SetAvatarNoInterp(int av, bool on)
{
    if (av <= 0 || !IsValidEntity(av)) return;
    if (!HasEntProp(av, Prop_Send, "m_fEffects")) return;
    int fx = GetEntProp(av, Prop_Send, "m_fEffects");
    if (on)
    {
        if ((fx & TAILS_EF_NOINTERP) == 0)
            SetEntProp(av, Prop_Send, "m_fEffects", fx | TAILS_EF_NOINTERP);
    }
    else if ((fx & TAILS_EF_NOINTERP) != 0)
        SetEntProp(av, Prop_Send, "m_fEffects", fx & ~TAILS_EF_NOINTERP);
}

// ============================================================
//  v5.20.6: PULSO DE PAUSA REAL (pedido del owner)
// ============================================================
// Ver la cabecera del modulo. Estados de la FSM:
//   IDLE    -> nada que hacer (coste: 1 comparacion de int/frame)
//   WAIT    -> avatar montado; esperando tails_pausefix_delay
//   PRECHECK-> mira si ya hay una pausa MANUAL en curso: si el juego
//              ya esta congelado (el owner pauso a mano), el pulso
//              se CANCELA en silencio: la pausa manual ya esta
//              re-encajando todo, y un pause encima seria PALANCA
//              (le quitaria su pausa al owner).
//   CONFIRM -> pausa pedida; verificar que el server congelo
//   HOLD    -> EN PAUSA; dura tails_pausefix_duration
//   RELEASE -> unpause pedido; verificar que el server retomo
// Todas las esperas son con GetEngineTime (tiempo REAL: corre aun
// en pausa). GetGameTime SOLO se usa como detector de congelado.
#define TAILS_PF_IDLE      0
#define TAILS_PF_WAIT      1
#define TAILS_PF_PRECHECK  2
#define TAILS_PF_CONFIRM   3
#define TAILS_PF_HOLD      4
#define TAILS_PF_RELEASE   5
#define TAILS_PF_VERIFY    0.3    // ventana para verificar pausa/unpause (s)

int    g_iTailsPFState     = TAILS_PF_IDLE;
int    g_iTailsPFUserid    = 0;       // dueño del avatar que disparo el pulso
int    g_iTailsPFAttempt   = 0;       // intento de la fase actual (pausar / soltar)
float  g_fTailsPFDeadline = 0.0;     // GetEngineTime() hasta el que se espera
float  g_fTailsPFSnapGT   = 0.0;     // snapshot de GetGameTime() (detector de pausa)
bool   g_bTailsPFQueued   = false;   // llego otro montaje durante el pulso
int    g_iTailsPFQueuedUid = 0;
ConVar g_hTailsSvPausable = null;    // cache del cvar del MOTOR (no del plugin)
bool   g_bTailsPFWarned   = false;   // LogError de sv_pausable ausente, 1 sola vez
bool   g_bTailsPFSkipNotice = false; // v5.20.7: aviso "sv_pausable 0: pulso omitido", 1 sola vez por mapa

// v5.21 — RATE LIMITER del motor de pulsos (anti flicker, pedido del
// owner: "el l4 se pause en multiples ocasiones"): separacion minima
// entre INICIOS de pulso. Sin esto, una cadena de montajes (auto-reparacion
// de la FSM, copia L que no logra montar, transicion de capitulo) disparaba
// pulso tras pulso con el juego haciendo pause/unpause visible.
float  g_fTailsPFLastStart  = 0.0;  // engine time del ultimo INICIO real de pulso
bool   g_bTailsPFRearm      = false; // hay un rearme espaciado pendiente
int    g_iTailsPFRearmUid   = 0;    // userid del rearme pendiente
int    g_iTailsPFRearmGen   = -1;   // generacion del pulso al agendar el rearme
int    g_iTailsPFGen        = 0;    // generacion actual (cada pulso iniciado la sube)
// (los globals del BACKOFF de auto-montaje viven arriba, junto a los del
// avatar: SourcePawn exige declararlos antes de su primer uso en el think)

// =====================================================================
// v5.20.7 "ZERO-NET" (2026-10-18, manager v3.77.88) — FIX DEL SEND
// RELIABLE STREAM OVERFLOW. Reporte del owner: overflow del canal
// fiable en su listen server (39+ errores), culpable aislado en campo:
// este manager. Autopsia: el PauseFix pedia cada pulso de re-encaje
// del avatar con ClientCommand("pause"/"unpause") — un stringcmd
// FIBLE que viaja server->cliente, el cliente lo EJECUTA y lo devuelve
// como stringcmd fiable cliente->server; el server pausa el mundo de
// verdad (sv_pausable estaba FORZADO a 1 en arranque/mapa/ronda y
// re-reforzado antes de cada pulso) y con el juego pausado el drenaje
// del canal se congela: el ping-pong palanca (pause cuando ya esta
// pausado = toggle) satura el stream fiable en ambas direcciones y
// desborda. FIX EN DOS PIEZAS, SIN TOCAR NINGUN EFECTO VISUAL (los
// avatares, EF_NOINTERP, MarkInterp, trails y FX quedan intactos):
//   [1] CERO ClientCommand: todo el ciclo del pulso (pausar y soltar)
//       pasa a FakeClientCommand — se ejecuta directo en el server,
//       mismo efecto de re-sincronizacion, CERO paquetes por la red.
//   [2] sv_pausable YA NO SE FUERZA: el suite respeta la decision del
//       admin. Con sv_pausable 0 el pulso se omite por completo (el
//       re-encaje ya esta cubierto por EF_NOINTERP + MarkInterp, las
//       piezas 1-2 de la v5.20.5: el avatar sigue naciendo encajado);
//       con sv_pausable 1 el pulso funciona server-side, sin red.
// =====================================================================

// v5.20.7 ZERO-NET: sv_pausable YA NO SE ESCRIBE NUNCA (la v5.20.6 lo
// forzaba a 1 en arranque/mapa/ronda y antes de cada pulso — secuestro
// de la config del admin retirado). Solo CACHEA el handle del motor.
bool Tails_PF_CachePausable()
{
    if (g_hTailsSvPausable == null)
        g_hTailsSvPausable = FindConVar("sv_pausable");
    if (g_hTailsSvPausable == null)
    {
        if (!g_bTailsPFWarned)
        {
            g_bTailsPFWarned = true;
            LogError("[Tails v5.20.7] sv_pausable no existe en este engine: el pulso de pausa queda desactivado.");
        }
        return false;
    }
    return true;
}

// Se llama al final de cada MONTAJE del avatar (CreateAvatar monta
// R+L de una vez; el montaje tardio de L de la FSM tambien llama).
// Si ya hay un pulso en curso, se encola UNO de refuerzo que corre
// al terminar el actual (el pulso re-sincroniza TODO lo montado
// recientemente, no solo una entidad).
// v5.24: RESTAURADO el comportamiento de la v5.22 (pedido del owner:
// el pulso en CADA montaje — !sc, respawn, FSM — estaba bien y no
// se pidio quitarlo). El gate "solo al iniciar la ronda" de la
// v5.23 se retira entero.
void Tails_PauseFix_Trigger(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (g_cvTailsPauseFix == null || !g_cvTailsPauseFix.BoolValue) return;
    Tails_PF_Arm(client, "montaje de avatar");
}

// v5.21 — API PUBLICA DE PETICION: el sistema SC PAUSA del manager (salida
// del saferoom, conexion a mitad de ronda, sm_scpausa manual) y cualquier
// modulo piden un pulso por razon explicita. NO pasa por el gate de
// tails_pausefix (ese gate es del montaje automatico; las peticiones
// explicitas tienen su propio master en el host: sc_pausa). Mismo motor
// Zero-Net (100% server-side, respeta sv_pausable), mismo rate limiter.
stock void Tails_PF_RequestPulse(int client, const char[] reason)
{
    if (client < 1 || client > MaxClients) return;
    Tails_PF_Arm(client, reason);
}

// v5.21 — nucleo comun: gates compartidos + rate limiter + arranque FSM
void Tails_PF_Arm(int client, const char[] reason)
{
    if (!Tails_PF_CachePausable()) return;     // sin sv_pausable no hay pulso

    // v5.20.7 ZERO-NET: con sv_pausable 0 el pulso se OMITE por completo
    // (cero pausas reales, cero comandos al cliente). El re-encaje visual
    // queda 100% a cargo de EF_NOINTERP + Tails_MarkInterp (piezas 1-2 de
    // la v5.20.5, ya existentes): el avatar sigue naciendo encajado.
    // Aviso 1 sola vez por mapa (reset en Tails_PauseFix_Reset).
    if (g_hTailsSvPausable.IntValue != 1)
    {
        if (!g_bTailsPFSkipNotice)
        {
            g_bTailsPFSkipNotice = true;
            LogMessage("[Tails v5.21] sv_pausable 0: pulso de pausa omitido (%s). Pon sv_pausable 1 si quieres el pulso (el re-encaje corre por EF_NOINTERP).", reason);
        }
        return;
    }

    if (g_iTailsPFState != TAILS_PF_IDLE)
    {
        // pulso en curso: este montaje queda cubierto por el pulso actual
        // (re-sincroniza TODO lo montado recientemente) + su refuerzo
        g_bTailsPFQueued   = true;
        g_iTailsPFQueuedUid = GetClientUserId(client);
        return;
    }

    // v5.21 RATE LIMITER: separacion minima entre INICIOS de pulso. Dentro
    // de la ventana se agenda UN rearme para cuando se cumpla el spacing
    // (los montajes/peticiones cubiertas por ese pulso quedan igual de
    // re-encajadas: el pulso re-sincroniza todo, no una entidad).
    float now = GetEngineTime();
    float spacing = (g_cvTailsPauseFixSpacing != null) ? g_cvTailsPauseFixSpacing.FloatValue : 2.0;
    if (spacing < 0.5) spacing = 0.5;
    if (g_fTailsPFLastStart > 0.0 && now - g_fTailsPFLastStart < spacing)
    {
        if (!g_bTailsPFRearm)
        {
            g_bTailsPFRearm    = true;
            g_iTailsPFRearmUid = GetClientUserId(client);
            g_iTailsPFRearmGen = g_iTailsPFGen;
            CreateTimer(spacing - (now - g_fTailsPFLastStart) + 0.05, Tails_PF_Timer_Rearm, _, TIMER_FLAG_NO_MAPCHANGE);
        }
        return;   // ya hay rearme pendiente: cubierto
    }

    g_fTailsPFLastStart = now;   // v5.21: marca del rate limiter
    g_iTailsPFGen++;             // v5.21: generacion (mata rearmes obsoletos)
    g_iTailsPFUserid   = GetClientUserId(client);
    g_iTailsPFAttempt  = 0;
    g_fTailsPFDeadline = now + g_cvTailsPauseFixDelay.FloatValue;
    g_iTailsPFState    = TAILS_PF_WAIT;
}

// v5.21: el rearme espaciado — cuando el rate limiter postergo un pulso,
// este timer lo dispara justo al cumplirse la ventana
public Action Tails_PF_Timer_Rearm(Handle timer)
{
    g_bTailsPFRearm = false;
    if (g_iTailsPFRearmGen != g_iTailsPFGen)
        return Plugin_Stop;   // alguien ya arranco otro pulso: obsoleto
    if (g_iTailsPFState != TAILS_PF_IDLE)
        return Plugin_Stop;   // hay un pulso vivo: su Finish lleva la cola

    int c = GetClientOfUserId(g_iTailsPFRearmUid);
    if (c > 0 && IsClientInGame(c))
        Tails_PF_Arm(c, "rearme espaciado");
    return Plugin_Stop;
}

// v5.21: escala de backoff del auto-montaje — 0.1s * fallos, tope 1.0s
float Tails_MountBackoff(int fails)
{
    float d = 0.1 * float(fails);
    if (d > 1.0) d = 1.0;
    return d;
}

// v5.21: estado del motor de pulsos para sm_omdiag
stock void Tails_PF_Diag(char[] out, int maxlen)
{
    float now = GetEngineTime();
    float since = (g_fTailsPFLastStart > 0.0) ? (now - g_fTailsPFLastStart) : -1.0;
    Format(out, maxlen, "FSM=%d/5 | ultimo inicio hace %.1fs | spacing=%.1fs | rearme pendiente=%s",
           g_iTailsPFState, since,
           (g_cvTailsPauseFixSpacing != null) ? g_cvTailsPauseFixSpacing.FloatValue : 2.0,
           g_bTailsPFRearm ? "si" : "no");
}

// Resuelve QUIEN ejecuta el comando: el dueño del avatar; si ya se
// fue, cualquier humano en juego (la pausa es del SERVER: con
// sv_pausable 1 cualquiera la puede pedir). 0 si no hay nadie.
int Tails_PF_ResolveClient()
{
    int c = GetClientOfUserId(g_iTailsPFUserid);
    if (c > 0 && IsClientInGame(c) && !IsFakeClient(c)) return c;
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && !IsFakeClient(i)) return i;
    return 0;
}

// snapshot del reloj del juego para el detector de pausa
void Tails_PF_SnapGameTime()
{
    g_fTailsPFSnapGT = GetGameTime();
}

// true si el reloj del juego NO avanzo desde el snapshot = el server
// esta EN PAUSA (curtime se congela con pause; corriendo normal, en
// cualquier ventana de 0.3s avanza ~0.3s, nunca menos de 0.05).
bool Tails_PF_GameFrozen()
{
    return (GetGameTime() - g_fTailsPFSnapGT) < 0.05;
}

// v5.20.7 ZERO-NET: la peticion de pausa es 100% SERVER-SIDE
// (FakeClientCommand). La via del cliente (v5.20.6: ClientCommand ->
// stringcmd fiable ida y vuelta + ping-pong palanca con el juego
// pausado sin drenar el canal) era la causa raiz del "send reliable
// stream overflow" del listen server: RETIRADA.
void Tails_PF_IssuePause(int client)
{
    FakeClientCommand(client, "pause");
    Tails_PF_SnapGameTime();
    g_fTailsPFDeadline = GetEngineTime() + TAILS_PF_VERIFY;
    g_iTailsPFState    = TAILS_PF_CONFIRM;
}

// v5.20.7 ZERO-NET: la salida tambien es 100% SERVER-SIDE. CERO
// ClientCommand: nada de stringcmds fiables hacia el cliente (el
// ping-pong palanca cruzada con el server era el generador del
// desborde del canal fiable). `pause` sigue siendo PALANCA.
// Si nada funciona: LogError con la salida manual (cualquier
// jugador puede escribir pause en consola y el server reanuda).
void Tails_PF_IssueUnpause(int client)
{
    switch (g_iTailsPFAttempt)
    {
        case 0:  { FakeClientCommand(client, "pause"); }   // palanca
        case 1:  { FakeClientCommand(client, "unpause"); } // por si el engine lo trae
        default: { FakeClientCommand(client, "pause"); }   // palanca de nuevo
    }
    Tails_PF_SnapGameTime();
    g_fTailsPFDeadline = GetEngineTime() + TAILS_PF_VERIFY;
    g_iTailsPFState    = TAILS_PF_RELEASE;
}

// Fin de la secuencia (exito o abort). Si llego otro montaje durante
// el pulso, se relanza un pulso de refuerzo para ese avatar.
void Tails_PF_Finish()
{
    g_iTailsPFState = TAILS_PF_IDLE;
    if (g_bTailsPFQueued)
    {
        g_bTailsPFQueued   = false;
        int uid = g_iTailsPFQueuedUid;
        g_iTailsPFQueuedUid = 0;
        int c = GetClientOfUserId(uid);
        if (c > 0 && IsClientInGame(c))
            Tails_PF_Arm(c, "refuerzo encolado");   // v5.21: pasa por el rate limiter (anti flicker)
    }
}

// Reset total (mapa nuevo / recarga): sin pulsos huerfanos.
void Tails_PauseFix_Reset()
{
    g_iTailsPFState     = TAILS_PF_IDLE;
    g_bTailsPFQueued    = false;
    g_iTailsPFQueuedUid = 0;
    g_bTailsPFSkipNotice = false;   // v5.20.7: el aviso sv_pausable 0 vuelve a poder salir
    g_bTailsPFRearm     = false;   // v5.21: sin rearmes huerfanos del mapa anterior
    // NOTA v5.21: g_fTailsPFLastStart NO se resetea a proposito — el rate
    // limiter debe seguir contando a traves de cambios de mapa para que la
    // transicion de capitulo (desmonte+monte de todos los avatares) no
    // dispare una rafaga de pulsos seguidos.
}

// La FSM del pulso. La llama el OnGameFrame del manager como
// PRIMERA linea y ANTES de cualquier early-return (si un pulso
// quedara a medias con el server en pausa y el suite se apagara en
// ese instante, la pausa quedaria huerfana). En reposo cuesta una
// comparacion de int por frame.
void Tails_PausePulse_Frame()
{
    if (g_iTailsPFState == TAILS_PF_IDLE) return;
    float now = GetEngineTime();

    // WAIT: expiro el delay tras el montaje -> pre-chequear pausa manual
    if (g_iTailsPFState == TAILS_PF_WAIT)
    {
        if (now < g_fTailsPFDeadline) return;
        Tails_PF_CachePausable();
        // PRECHECK: detectar una pausa MANUAL en curso antes de tocar
        // nada (0.1s de ventana con el reloj del juego)
        Tails_PF_SnapGameTime();
        g_fTailsPFDeadline = GetEngineTime() + 0.1;
        g_iTailsPFState    = TAILS_PF_PRECHECK;
        return;
    }

    // PRECHECK: ¿habia pausa manual en curso? -> no meterse
    if (g_iTailsPFState == TAILS_PF_PRECHECK)
    {
        if (now < g_fTailsPFDeadline) return;
        if (Tails_PF_GameFrozen())
        {
            // el owner (o alguien) pauso a mano: esa pausa YA esta
            // re-encajando el avatar; cancelar el pulso en silencio
            Tails_PF_Finish();
            return;
        }
        int c = Tails_PF_ResolveClient();
        if (c == 0) { Tails_PF_Finish(); return; }   // se fueron todos
        g_iTailsPFAttempt = 0;
        Tails_PF_IssuePause(c);
        return;
    }

    // CONFIRM: ¿congelo el server?
    if (g_iTailsPFState == TAILS_PF_CONFIRM)
    {
        if (now < g_fTailsPFDeadline) return;
        if (Tails_PF_GameFrozen())
        {
            // PAUSA ACTIVA: sostenerla lo que pida el cvar
            g_fTailsPFDeadline = now + g_cvTailsPauseFixDuration.FloatValue;
            g_iTailsPFState    = TAILS_PF_HOLD;
            return;
        }
        // no congelo: reintento por la via server-side y fuera
        g_iTailsPFAttempt++;
        int c = Tails_PF_ResolveClient();
        if (c == 0 || g_iTailsPFAttempt >= 2)
        {
            LogError("[Tails v5.21] PauseFix: el servidor no entro en pausa; se omite el ajuste (sin dano, el avatar sigue como estaba).");
            Tails_PF_Finish();
            return;
        }
        Tails_PF_IssuePause(c);
        return;
    }

    // HOLD: EN PAUSA; soltarla al vencer la duracion
    if (g_iTailsPFState == TAILS_PF_HOLD)
    {
        if (now < g_fTailsPFDeadline) return;
        int c = Tails_PF_ResolveClient();
        if (c == 0)
        {
            LogError("[Tails v5.21] PauseFix: nadie conectado para quitar la pausa; escribe pause en la consola.");
            Tails_PF_Finish();
            return;
        }
        g_iTailsPFAttempt = 0;
        Tails_PF_IssueUnpause(c);
        return;
    }

    // RELEASE: ¿retomo el server?
    if (g_iTailsPFState == TAILS_PF_RELEASE)
    {
        if (now < g_fTailsPFDeadline) return;
        if (!Tails_PF_GameFrozen()) { Tails_PF_Finish(); return; }   // listo
        g_iTailsPFAttempt++;
        int c = Tails_PF_ResolveClient();
        if (c == 0 || g_iTailsPFAttempt > 3)
        {
            LogError("[Tails v5.21] PauseFix: el servidor quedo EN PAUSA. Escribe pause en la consola para reanudar.");
            Tails_PF_Finish();
            return;
        }
        Tails_PF_IssueUnpause(c);
        return;
    }
}

// v5.17-A: filtro exponencial por componente con wraparound ±180°
// (ángulos). state += (target - state) * alpha, alpha = dt / (tau + dt).
// snap = true pega el valor seco (avatar recién creado / reset: evita
// convergencia larga desde un estado viejo). tau = 0 → alpha = 1
// → write seco = v5.11 byte a byte.
void Tails_ExpDamp(const float target[3], float state[3], float tau, float dt, bool snap)
{
    float alpha = 1.0;
    if (!snap && tau > 0.0 && dt > 0.0)
    {
        alpha = dt / (tau + dt);
        if (alpha > 1.0) alpha = 1.0;
    }
    for (int i = 0; i < 3; i++)
    {
        float d = target[i] - state[i];
        while (d > 180.0)  d -= 360.0;   // camino corto (componentes ±180)
        while (d < -180.0) d += 360.0;
        state[i] += d * alpha;
    }
}

// v5.20.4: CONTINUIDAD DEL YAW LOCAL "NETWORKED". Los ángulos
// locales del avatar viajan al cliente por snapshots y el cliente
// interpola cada COMPONENTE de forma lineal (sin wrap-awareness) entre
// dos valores consecutivos. Cuando el cuerpo queda de FRENTE a la
// cámara (caminar hacia atrás, regla Poppy: delta ~180°), el yaw local
// exacto cae justo en la frontera ±180 del atan2: con el titileo
// natural de la dirección de marcha, el valor escrito alterna entre
// +179.x y -179.x -> el cliente interpola "el camino largo" (358°) en
// esos frames -> el cuerpo se ve ladeado un lado u otro según caiga el
// cruce (el tilt reportado por el owner: solo de frente, solo en
// movimiento, cambia de lado con la cámara; idle/de lado/de espaldas
// están lejos de la frontera y jamás saltan).
// FIX: escribir SIEMPRE un yaw equivalente al exacto pero CONTINUO con
// la última escritura (±360° dan el mismo ángulo para el motor, pero
// para el interpolador del cliente no: así viaja siempre el camino
// corto). El estado del smoothing (g_fTailsSmLoc / L) vive en ese
// espacio continuo: se re-semilla en cada CreateAvatar (entidad nueva,
// sin historial de interpolación que romper).
float Tails_UnwrapYaw(const float prev, float next)
{
    float d = next - prev;
    while (d > 180.0)  { next -= 360.0; d -= 360.0; }
    while (d < -180.0) { next += 360.0; d += 360.0; }
    return next;
}

// v5.6 OM: SEGUIMIENTO DEL AVATAR (PostThink del jugador).
// v5.5 quitó el SetParent y siguió al jugador con TeleportEntity por
// tick: eso dejó el movimiento desfazado y las transiciones de animación
// secas (un prop teleportado por el server pierde la interpolación
// estable del cliente). v5.6 recupera el PARENT (la posición la mueve
// el MOTOR junto al survivor: cero delay, cero teleport por tick,
// suavidad v5.4) y el bug del v5.4 (cuerpo inclinado con la mira) NO
// vuelve: aquí se escriben cada tick los ángulos LOCALES que cancelan
// EXACTAMENTE el pitch/roll del parent (Tails_AvatarLocalAngles) ->
// cuerpo SIEMPRE vertical en mundo. El yaw obedece las mismas reglas
// del pill de GMod (v5.5):
//   (1) cargando o disparando el cañón (TODO el loop, carga incluida)
//       o con sm_tailslock ("bloq Mayús" de Roblox) activo: cuerpo
//       FIJO hacia donde mira la cámara (bloqueo de cámara);
//   (2) normal: el cuerpo se VOLTEA hacia donde camina/corre/vuela
//       (fix estilo Poppy: caminar hacia atrás = cuerpo mirando
//       hacia atrás);
//   (3) parado: mantiene el último yaw (no gira solo).
// Convar tails_follow: 0 = parentado (default, suave) / 1 = teleport
// por tick estilo v5.5 (fallback de diagnóstico).
public void Tails_AvatarFollow(int client)
{
    if (g_iTailsAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Tails_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    int av = EntRefToEntIndex(g_iTailsAvatar[client]);
    if (av <= 0 || !IsValidEntity(av)) return;

    // ---- yaw objetivo según las 3 reglas ----
    float yawObj = g_fTailsBodyYaw[client];

    bool shoot = g_bTailsCharging[client] || g_bTailsFiring[client] || g_bTailsOrbSession[client];
    if (shoot || g_bTailsLock[client])
    {
        // bloqueo de cámara: el cuerpo apunta a donde mira la mira
        float eye[3];
        GetClientEyeAngles(client, eye);
        yawObj = eye[1];
    }
    else
    {
        // dirección REAL del movimiento (misma convención que
        // Witch_Flight.inc / l4d2_pet_fusion.sp del suite)
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
        {
            float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
            // v5.20.4 DEADBAND: la dirección de marcha titila ±1-3°
            // (correcciones de mouse/colisión al caminar). Si el nuevo
            // rumbo está a menos de 3° del yaw ACTUAL del cuerpo, no
            // se persigue ese ruido: cada titileo mueve el yaw local
            // del avatar y, en la zona de frente a la cámara (local
            // yaw ~±180), era lo que generaba saltos de frontera que
            // el cliente interpolaba por el camino largo (el tilt).
            float dv = velYaw - g_fTailsBodyYaw[client];
            while (dv > 180.0)  dv -= 360.0;
            while (dv < -180.0) dv += 360.0;
            if (dv > 3.0 || dv < -3.0)
                yawObj = velYaw;
        }
    }

    // ---- giro suave hacia el objetivo (~900°/s, sin saltos) ----
    float now = GetEngineTime();
    float dt  = now - g_fTailsYawLastT[client];
    g_fTailsYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;    // primer frame o hitch

    float d = yawObj - g_fTailsBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fTailsBodyYaw[client] += d;

    // ---- aplicar la orientación según el modo de seguimiento ----
    if (g_cvTailsFollow.BoolValue)
    {
        // MODO 1 (fallback estilo v5.5): teleport por tick, ahora en
        // el PostThink (posición FRESCA del tick: 1 tick mejor que el
        // PreThink del v5.5). Cuerpo vertical en mundo. v5.7: mismo lead
        // de lerp que el modo 0 (comportamiento igual en tu pantalla).
        float pos[3];
        GetClientAbsOrigin(client, pos);
        Tails_GetLerpLead(client, pos);
        float ang[3];
        ang[0] = 0.0;                      // pitch NUNCA
        ang[1] = g_fTailsBodyYaw[client];
        ang[2] = 0.0;                      // roll NUNCA
        TeleportEntity(av, pos, ang, NULL_VECTOR);
        // v5.11: conserva el fix de reloj de la v5.9.1 para el modo
        // diagnostico (el teleport por tick tambien necesita su linea
        // de tiempo de interpolacion; el modo 0 parentado no la usa).
        Tails_MarkInterp(av);
    }
    else
    {
        float par[3], loc[3], lead[3], locPos[3];
        bool snap = g_bTailsSmSnap[client];          // v5.17-A
        GetClientAbsAngles(client, par);

        if (Tails_AvatarTPOn())
        {
            // v5.25: LA COPIA R VIAJA POR TP. TeleportEntity por tick
            // en pose MUNDO (pos del jugador + yaw del cuerpo;
            // pitch/roll NUNCA) + reloj vivo de la v5.9.1, SIN
            // EF_NOINTERP: los clientes de los demás la INTERPOLAN
            // como a cualquier entidad del juego = suave SIEMPRE, sin
            // depender de la pausa (que solo re-encaja la vista del
            // dueño). El dueño jamás la recibe: TransmitAvatarR se la
            // filtra porque tiene su copia L parentada.
            float posTP[3], angTP[3];
            GetClientAbsOrigin(client, posTP);
            angTP[0] = 0.0;                      // pitch NUNCA
            angTP[1] = g_fTailsBodyYaw[client];
            angTP[2] = 0.0;                      // roll NUNCA
            TeleportEntity(av, posTP, angTP, NULL_VECTOR);
            Tails_MarkInterp(av);
        }
        else
        {
        // MODO 0 (default v5.6): parentado — la POSICIÓN la mueve el
        // motor junto al survivor (cero delay de red); aquí SOLO se
        // fijan los ángulos LOCALES = contra-rotación exacta del
        // parent para que el cuerpo quede vertical mirando al yaw...
        Tails_AvatarLocalAngles(par[0], par[1], g_fTailsBodyYaw[client], loc);
        // v5.20.4: continuidad del yaw local networked (ver helper):
        // nunca saltar la frontera ±180 entre dos escrituras.
        loc[1] = Tails_UnwrapYaw(g_fTailsSmLoc[client][1], loc[1]);
        // v5.17-A: la contra-rotación ya NO se escribe seca: rampa con
        // tails_angdamp (el escalón por tick era el micro-tirón al apuntar).
        Tails_ExpDamp(loc, g_fTailsSmLoc[client], g_cvTailsAngDamp.FloatValue, dt, snap);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", g_fTailsSmLoc[client]);

        // v5.20.5: RELOJ DE SIMULACION VIVO. Un prop parentado no
        // simulado nunca avanza m_flSimulationTime: queda clavado en el
        // spawn y la interpolacion del cliente trabaja contra un
        // historial con marcas viejas (parte del estado que `pause`
        // re-encajaba). Estamparlo en cada write es lo que el motor hace
        // con cualquier entidad simulada — misma estampa del v5.9.1 que
        // ya usaba el modo teleport (Tails_MarkInterp; en L4D2 el
        // SendProp es DPT_Int: ENTERO + tickcount, NUNCA float).
        Tails_MarkInterp(av);

        // v5.7 FIX DESFASE ("volvió el error" del video): el avatar
        // parentado se dibuja en la posición INTERPOLADA del survivor
        // (~lerp por detrás de tu cámara, que va PREDICHA) -> al
        // caminar queda desfazado ("como con lerps bajos") y con
        // interp 0 se ve pegado. FIX sin tocar la interpolación de
        // nadie (nada de interp 0, nada de EF_NOINTERP, nada de
        // saltos): ORIGEN LOCAL del avatar = lead = velocidad *
        // tails_lerpcomp (default 0.1s = lerp default de L4D2), en el
        // espacio del parent (contra-rotado con Tails_WorldToLocalVec).
        // pos_interp + vel*lerp = pos actual -> en tu pantalla queda
        // PEGADO. El delta por tick es diminuto (2-3u): el historial de
        // interpolación del cliente sigue limpio (anims suaves intactas)
        // y para los demás es indetectable (el cuerpo del survivor está
        // invisible: no hay referencia con qué comparar).
        if (g_cvTailsLerpComp.FloatValue > 0.0)
        {
            lead[0] = 0.0; lead[1] = 0.0; lead[2] = 0.0;
            Tails_GetLerpLead(client, lead);
            // v5.17-A: el lead también va en rampa (tails_leadsmooth): el
            // escalón de ~2-4u por tick mientras caminas era el micro-tirón
            // de posición en la pantalla del dueño.
            Tails_ExpDamp(lead, g_fTailsSmLead[client], g_cvTailsLeadSmooth.FloatValue, dt, snap);
            Tails_WorldToLocalVec(par[0], par[1], g_fTailsSmLead[client], locPos);
            // escribir solo si movió (evita churn de red estando parado)
            float curPos[3];
            GetEntPropVector(av, Prop_Send, "m_vecOrigin", curPos);
            if (GetVectorDistance(curPos, locPos) > 0.05)
                SetEntPropVector(av, Prop_Send, "m_vecOrigin", locPos);
        }
        }

        // v5.17-A: el snap solo vale 1 tick (creación/reset del avatar)
        g_bTailsSmSnap[client] = false;

        // ---- v5.17-B: copia L — contra-rotación contra los EYE del dueño ----
        // (SU cliente arma el parent con el cuerpo PREDICHO = camara
        // completa; cancelar los eye angles lo deja vertical EN SU PANTALLA)
        int avL = EntRefToEntIndex(g_iTailsAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3], locL[3], locPosL[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], g_fTailsBodyYaw[client], locL);
            // v5.20.4: continuidad del yaw local networked también en L
            locL[1] = Tails_UnwrapYaw(g_fTailsSmLocL[client][1], locL[1]);
            Tails_ExpDamp(locL, g_fTailsSmLocL[client], g_cvTailsAngDamp.FloatValue, dt, snap);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fTailsSmLocL[client]);

            // v5.20.5: reloj de simulacion vivo tambien para la copia L
            // (misma estampa entera del v5.9.1 — ver bloque de R arriba)
            Tails_MarkInterp(avL);

            // lead del lerp: mismo lead MUNDO suavizado, convertido al
            // espacio local del parent CON PITCH (el del dueño si lo tiene)
            if (g_cvTailsLerpComp.FloatValue > 0.0)
            {
                Tails_WorldToLocalVec(eye[0], eye[1], g_fTailsSmLead[client], locPosL);
                float curPosL[3];
                GetEntPropVector(avL, Prop_Send, "m_vecOrigin", curPosL);
                if (GetVectorDistance(curPosL, locPosL) > 0.05)
                    SetEntPropVector(avL, Prop_Send, "m_vecOrigin", locPosL);
            }
        }
    }
}

// v5.6: contra-rotación EXACTA del parent, en espacio LOCAL.
// El survivor-parent rota con los ángulos de la cámara P=(pitch, yaw,
// 0) (convención Source: fwd=(cp*cy, cp*sy, -sp)); un avatar parentado
// queda en mundo = parent * local. Para que el cuerpo quede SIEMPRE
// vertical (pitch/roll de mundo = 0) mirando a worldYaw, el local debe
// ser L = P_inversa * (0, worldYaw, 0). Con delta = worldYaw - yaw y
// (sp, cp) = (seno, coseno) del pitch:
//   localPitch = atan2(-sp*cos(delta), sqrt(cp^2*cos^2(delta)+sen^2(delta)))
//   localYaw   = atan2(sen(delta), cp*cos(delta))
//   localRoll  = atan2(-sp*sen(delta), cp)
// (verificación numérica: delta=0 -> local=(-pitch,0,0) exacto;
//  delta=180 con pitch=30 -> fwd de mundo=(-cy,-sy,0) y up=(0,0,1)
//  exactos. El roll del parent se asume 0: en L4D2 los survivors no
//  tienen roll en sus ángulos de entidad.)
void Tails_AvatarLocalAngles(float parentPitch, float parentYaw, float worldYaw, float out[3])
{
    float delta = worldYaw - parentYaw;
    while (delta > 180.0)  delta -= 360.0;
    while (delta < -180.0) delta += 360.0;

    float sp = Sine(DegToRad(parentPitch));
    float cp = Cosine(DegToRad(parentPitch));
    float sd = Sine(DegToRad(delta));
    float cd = Cosine(DegToRad(delta));

    out[0] = RadToDeg(ArcTangent2(-sp * cd, SquareRoot(cp * cp * cd * cd + sd * sd)));
    out[1] = RadToDeg(ArcTangent2(sd, cp * cd));
    out[2] = RadToDeg(ArcTangent2(-sp * sd, cp));
}

// v5.7: convierte un vector de MUNDO al espacio LOCAL del parent (para
// escribir el ORIGEN local del avatar parentado con el lead del lerp).
// El parent rota R = RotZ(yaw) * RotY(pitch); local = R^-1 * v =
// RotY(-pitch) * RotZ(-yaw) * v. Verificado numéricamente: yaw=90 ->
// world (1,0,0) = local (0,-1,0); pitch=90 -> world (0,0,1) = local
// (-1,0,0); y round-trip world->local->world exacto en ambos casos.
void Tails_WorldToLocalVec(float parentPitch, float parentYaw, const float v[3], float out[3])
{
    float cy = Cosine(DegToRad(parentYaw));
    float sy = Sine(DegToRad(parentYaw));
    float v1[3];
    v1[0] = v[0] * cy + v[1] * sy;        // RotZ(-yaw)
    v1[1] = -v[0] * sy + v[1] * cy;
    v1[2] = v[2];
    float cp = Cosine(DegToRad(parentPitch));
    float sp = Sine(DegToRad(parentPitch));
    out[0] = v1[0] * cp - v1[2] * sp;     // RotY(-pitch)
    out[1] = v1[1];
    out[2] = v1[0] * sp + v1[2] * cp;
}

// v5.6: cambio del convar tails_follow -> recrear los avatares con el
// modo nuevo (la FSM de 10 Hz los remonta en <=0.1s). Puede flahear el
// cuerpo del survivor un instante (KillAvatar lo restaura visible y el
// avatar recreado lo vuelve a ocultar).
public void Tails_OnFollowModeChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (StrEqual(oldValue, newValue)) return;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iTailsAvatar[i] != 0 && IsClientInGame(i))
            Tails_KillAvatar(i);
    }
}

// v5.20.5: cambio de tails_avinterp EN VIVO — aplica/quita el flag
// EF_NOINTERP de los avatares existentes SIN recrear nada (el cuerpo
// del survivor no flashea). En modo teleport (follow 1) no aplica: ese
// modo conserva su interpolacion + MarkInterp propia (v5.9.1); los
// avatares que se creen al volver al modo parentado ya nacen con el
// flag segun este convar.
public void Tails_OnAvInterpChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (StrEqual(oldValue, newValue)) return;
    if (g_cvTailsFollow.BoolValue) return;   // modo teleport: intacto
    bool on = convar.BoolValue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iTailsAvatar[i] != 0)
        {
            // v5.25: la R en modo TP conserva su interpolacion de red
            // (es su razon de ser); el flag solo toca la R parentada
            if (!Tails_AvatarTPOn())
            {
                int r = EntRefToEntIndex(g_iTailsAvatar[i]);
                if (r > 0 && IsValidEntity(r))
                    Tails_SetAvatarNoInterp(r, on);
            }
        }
        if (g_iTailsAvatarL[i] != 0)
        {
            int l = EntRefToEntIndex(g_iTailsAvatarL[i]);
            if (l > 0 && IsValidEntity(l))
                Tails_SetAvatarNoInterp(l, on);
        }
    }
}

// v5.25: lectura compartida del modo R-TP para sonic.inc / Amy.inc
// (se incluyen DESPUES que este archivo): una funcion con guard null
// en vez de exponerles el ConVar directo (y cero dependencia del
// orden de OnPluginStart entre modulos).
bool Tails_AvatarTPOn()
{
    return g_cvTailsAvatarTP != null && g_cvTailsAvatarTP.BoolValue;
}

// v5.25: cambio de tails_avatar_tp EN VIVO — recreacion de los
// avatares de los TRES modulos (mismo recreador que tails_follow:
// kill y las FSM de 10 Hz re-montan en <=0.1s leyendo el modo nuevo;
// puede flahear el cuerpo del survivor un instante — el costo ya
// documentado del tails_follow). Sonic/Amy van en includes
// posteriores: SourcePawn resuelve las llamadas igual (mismo caso
// que Speed_sonic -> Sonic_GetAvatarEnts).
public void Tails_OnAvatarTPChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (StrEqual(oldValue, newValue)) return;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        Tails_KillAvatar(i);       // R+L (guards internos: no-op sin avatar)
        Sonic_KillAvatarOnly(i);   // solo R+L: la BOLA es parentada, no cambia de modo
        Amy_OM_KillAvatar(i);      // R+L + cuerpo (la FSM lo re-monta)
    }
}

// v5.5: "bloq Mayús" de Roblox (sm_tailslock): fija el cuerpo del avatar
// a la mira SIEMPRE. Toggle por jugador, DESACTIVADO por defecto. No
// afecta al bloqueo automático de la carga/disparo del cañón (ese es
// SIEMPRE activo, use o no use este comando).
public Action Command_TailsLock(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client <= 0 || !IsClientInGame(client))
    {
        ReplyToCommand(client, "[Tails] Solo usable dentro del juego.");
        return Plugin_Handled;
    }
    g_bTailsLock[client] = !g_bTailsLock[client];
    if (g_bTailsLock[client])
        PrintToChat(client, "\x04[Tails]\x01 Bloqueo de cámara \x04ACTIVADO\x01 (bloq Mayús): el cuerpo mira SIEMPRE hacia la mira.");
    else
        PrintToChat(client, "\x04[Tails]\x01 Bloqueo de cámara \x04DESACTIVADO\x01: el cuerpo vuelve a mirar hacia donde te mueves (a la mira solo al cargar/disparar el cañón).");
    return Plugin_Handled;
}

// "clampval" de GMod: potencia restante del vuelo (1 lleno -> 0 agotado,
// decae en los últimos 2s de combustible)
float Tails_FlightPower(int client)
{
    float remain = g_fTailsFuel[client] - GetEngineTime();
    if (remain > 2.0) return 1.0;
    if (remain < 0.0) return 0.0;
    return remain / 2.0;
}

float Tails_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// v5.0 OM: ragdoll del modelo al morir (GMod: CreateRagdolLCharacter_OM)
void Tails_SpawnDeathRagdoll(int client)
{
    if (!g_bTailsModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", TAILS_OM_MODEL);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    // limpiarlo a los 15s (no acumular cadáveres en mapas multi-ronda)
    CreateTimer(15.0, T_TailsRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_TailsRagdollCleanup(Handle timer, any ref)
{
    int rag = EntRefToEntIndex(view_as<int>(ref));
    if (rag > 0 && IsValidEntity(rag))
        AcceptEntityInput(rag, "Kill");
    return Plugin_Stop;
}

// =======================
// v5.20: FIX RAGDOLL DEL SURVIVOR AL MORIR
// =======================
// El owner usa un mod que convierte la muerte de los survivors en
// ragdoll físico. Para un jugador Tails eso está MAL: su cuerpo "real"
// es invisible toda la partida (es un avatar); si el cadáver aparece de
// golpe al morir, se ven DOS cuerpos (survivor muerto + ragdoll OM de
// tails.mdl). Solución: ventana de 2s abierta en Tails_Event_PlayerDeath;
// toda entidad física/ragdoll NUEVA con modelo models/survivors/ a menos
// de 200u del punto de muerte se oculta (RENDER_NONE + sin sombra). El
// ragdoll OM usa tails.mdl -> nunca entra en el filtro. Las muertes de
// jugadores NO Tails no abren ventana -> sus ragdolls quedan intactos.
// INTEGRACIÓN: SourceMod solo permite UN public OnEntityCreated por
// plugin y el del manager vive en Rouge.inc (tracker de insect_swarm,
// v7.1); Rouge se incluye DESPUÉS de Tails y lo invoca por su nombre.
void Tails_OnEntityCreated(int entity, const char[] classname)
{
    // filtro rápido por clase (el resto sale gratis en los strcmp)
    if (StrEqual(classname, "prop_ragdoll")
        || StrEqual(classname, "prop_physics")
        || StrEqual(classname, "prop_physics_override")
        || StrEqual(classname, "prop_dynamic")
        || StrEqual(classname, "prop_dynamic_override")
        || StrEqual(classname, "cs_ragdoll")
        || StrEqual(classname, "survivor_death_model"))
    {
        // ¿hay alguna ventana de muerte Tails activa?
        float now = GetEngineTime();
        for (int i = 1; i <= MaxClients; i++)
        {
            if (g_fTailsDeathHideUntil[i] == 0.0 || now >= g_fTailsDeathHideUntil[i])
                continue;
            // candidata: revisar modelo/origen en el próximo frame
            // (en OnEntityCreated las keyvalues aún no están dispatchadas)
            RequestFrame(Tails_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }
}

public void Tails_CheckDeathRagdoll(any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent <= 0 || !IsValidEntity(ent)) return;

    // ya dispatchada: ¿es un cuerpo de survivor?
    char model[96];
    GetEntPropString(ent, Prop_Data, "m_ModelName", model, sizeof(model));
    if (strncmp(model, "models/survivors/", 17) != 0) return;

    float now = GetEngineTime();
    float o[3];
    GetEntPropVector(ent, Prop_Data, "m_vecOrigin", o);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_fTailsDeathHideUntil[i] == 0.0 || now >= g_fTailsDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_fTailsDeathOrigin[i]) < 200.0)
        {
            // cuerpo del survivor "revivido" por el mod de ragdolls:
            // invisible + sin sombra. NO se elimina: el mod del owner
            // conserva su entidad y su lógica sin errores en consola.
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}

// =======================
// ACTIVA 1: GLIDE (VUELO ASISTIDO Y STEERING)
// =======================

public Action Command_TailsFly(int client, int args)
{
    if (!Tails_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != TAILS_INDEX) return Plugin_Handled;

    // v4.2 FIX: no volar incapacitado ni agarrado
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return Plugin_Handled;
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return Plugin_Handled;
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) return Plugin_Handled;
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return Plugin_Handled;

    float now = GetEngineTime();

    if (g_bTailsFlying[client])
    {
        // v5.0 OM (GMod): la re-tecla CANCELA solo si queda más de la
        // mitad de potencia (lerpval > 0.5). El cancel deja 1s de
        // "colchón" de planeo para aterrizar y aplica el CD CORTO.
        float power = Tails_FlightPower(client);
        if (power < 0.5)
        {
            PrintCenterText(client, "Colas agotadas: espera a aterrizar");
            return Plugin_Handled;
        }
        g_bTailsFlyManual[client] = true;
        g_fTailsFuel[client] = now + 1.0;   // colchón de aterrizaje GMod
        PrintCenterText(client, "Planeo cancelado (aterrizaje suave)");
        return Plugin_Handled;
    }

    if (now < g_fTailsFlyCooldown[client])
    {
        PrintCenterText(client, "Cansado... Espera %.1fs", g_fTailsFlyCooldown[client] - now);
        return Plugin_Handled;
    }

    g_bTailsFlying[client] = true;
    g_bTailsFlyManual[client] = false;
    g_fTailsFuel[client] = now + g_cvTailsFlyDuration.FloatValue;
    g_fTailsFlyNextSnd[client] = 0.0;

    // v5.0 OM (GMod): se puede despegar DESDE EL SUELO (el pill lo
    // permite): +10u de lift + 1s de ascenso automático
    // (OM_Tails_flyingDuration_Up) para no re-aterrizar al instante.
    if (GetEntityFlags(client) & FL_ONGROUND)
    {
        g_fTailsFlyUpUntil[client] = now + 1.0;
        float pos[3];
        GetClientAbsOrigin(client, pos); pos[2] += 10.0;
        TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
    }

    SDKHook(client, SDKHook_PreThink, Tails_FlyThink);
    Tails_EmitLoud(client, TAILS_SOUND_FLY_START, SNDLEVEL_TRAIN);   // v5.3: 2 capas + 100dB
    PrintCenterText(client, "¡Volando! ESPACIO sube / soltar baja / mira = dirección");
    
    return Plugin_Handled;
}

public void Tails_FlyThink(int client)
{
    if (g_iPlayerCharIdx[client] != TAILS_INDEX) { Tails_StopFlying(client, false); return; }
    if (!g_bTailsFlying[client] || !IsPlayerAlive(client)) { SDKUnhook(client, SDKHook_PreThink, Tails_FlyThink); return; }

    // v4.2 FIX: si lo agarraron (Hunter/Jockey/Smoker) o quedo
    // incapacitado, cancelar el vuelo SIN cooldown (el cancel por DAÑO
    // de GMod lo hace Tails_OnTakeDamage)
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0)
    {
        Tails_StopFlying(client, false);
        return;
    }

    float now = GetEngineTime();
    
    if (now > g_fTailsFuel[client])
    {
        Tails_StopFlying(client);
        PrintCenterText(client, "Se acabo el combustible de vuelo");
        return;
    }

    // "clampval" GMod: 1 lleno -> 0 en los últimos 2s (todo el empuje
    // decae con la potencia, igual que el pill)
    float power = Tails_FlightPower(client);

    int flags = GetEntityFlags(client);
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);

    // Aterrizaje: fin natural del vuelo (GMod: glidecd_expire al tocar suelo)
    if ((flags & FL_ONGROUND) && vel[2] <= 0.0)
    {
        if (g_cvTailsFlyDuration.FloatValue - (g_fTailsFuel[client] - now) > 0.5)
        {
            Tails_StopFlying(client, true);
            return;
        }
    }

    // ===== FISICA GMod OM (velocity SETEADA, como SetLocalVelocity del pill) =====
    // empuje = dirección de la MIRA (3D, con pitch, como ply:GetForward()
    // de GMod) * 300 * power
    float eyeAng[3], fwd[3], right[3];
    GetClientEyeAngles(client, eyeAng);
    GetAngleVectors(eyeAng, fwd, right, NULL_VECTOR);

    float thrust = g_cvTailsFlyFwd.FloatValue * power;
    vel[0] = fwd[0] * thrust;
    vel[1] = fwd[1] * thrust;
    vel[2] = fwd[2] * thrust;

    // strafe lateral GMod (A/D a velocidad horizontal completa, solo plano XZ)
    int buttons = GetClientButtons(client);
    float side = g_cvTailsFlyFwd.FloatValue * power;
    if (buttons & IN_MOVELEFT)  { vel[0] -= right[0]*side; vel[1] -= right[1]*side; }
    if (buttons & IN_MOVERIGHT) { vel[0] += right[0]*side; vel[1] += right[1]*side; }

    // vertical: ESPACIO (o el ascenso de despegue) sube; soltar baja (GMod: GetUp()*+-90)
    float vert = g_cvTailsFlyVert.FloatValue * power;
    if ((buttons & IN_JUMP) || now < g_fTailsFlyUpUntil[client]) vel[2] += vert;
    else                                                          vel[2] -= vert;

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    // ===== LOOP DE SONIDO GMod: re-emisión con pitch 25..100 =====
    // (s135_sba_flying: intervalo 0.2s con potencia llena -> 0.55s agotándose)
    if (now >= g_fTailsFlyNextSnd[client])
    {
        int pitch = RoundToCeil(100.0 * power);
        if (pitch < 25)  pitch = 25;
        if (pitch > 100) pitch = 100;
        // v5.3: doble capa (STATIC+ITEM) = se oye mas fuerte; 100dB lejos
        EmitSoundToClient(client, TAILS_SOUND_FLY_LOOP, client, SNDCHAN_STATIC, SNDLEVEL_TRAIN, SND_NOFLAGS, 1.0, pitch);
        EmitSoundToClient(client, TAILS_SOUND_FLY_LOOP, client, SNDCHAN_ITEM,  SNDLEVEL_TRAIN, SND_NOFLAGS, 1.0, pitch);
        g_fTailsFlyNextSnd[client] = now + 0.2 + 0.35 * (1.0 - power);
    }
}

void Tails_StopFlying(int client, bool applyCooldown = true)
{
    if (client < 1 || client > MaxClients) return;
    if (!g_bTailsFlying[client]) return;

    g_bTailsFlying[client] = false;

    // v4.2 FIX: la muerte, el round restart o ser agarrado NO aplican
    // cooldown de vuelo (antes morir volando = 25s de castigo injusto)
    if (applyCooldown)
    {
        // v5.0 OM (GMod): CD LARGO al expirar/aterrizar (32s,
        // glidecd_expire) y CD CORTO al cancelar manual (17s,
        // glidecd_cancel)
        float cd = g_bTailsFlyManual[client] ? g_cvTailsFlyCdCancel.FloatValue
                                             : g_cvTailsFlyCooldown.FloatValue;
        g_fTailsFlyCooldown[client] = GetEngineTime() + cd;
        g_bTailsFlyManual[client] = false;
    }

    // v5.0 OM: cortar el loop de vuelo (el pitch-stop del GMod)
    if (IsClientInGame(client))
    {
        StopSound(client, SNDCHAN_STATIC, TAILS_SOUND_FLY_LOOP);
        StopSound(client, SNDCHAN_ITEM,  TAILS_SOUND_FLY_LOOP);   // v5.3: 2a capa
    }

    SDKUnhook(client, SDKHook_PreThink, Tails_FlyThink);
}

// ============================================================
//  v5.23: CAÑÓN ININTERRUMPIBLE (contrato del owner, arreglo
//  perdido: se pidio en la serie v5.21 de la linea C, que murio;
//  la linea B viva seguia cortando el cañon con CUALQUIER daño,
//  incluido el golpe de un comun)
// ============================================================
// El rayo/carga SOLO se corta por stun: agarre de SMOKER, HUNTER
// (pounce), JOCKEY, CHARGER (carry/pummel), incap, ledge, y GOLPE
// o ROCA DE TANK (cualquier stagger o lanzamiento del motor). EL
// DAÑO YA NO CORTA: un comun pegandole a Tails NO interrumpe nada
// (el vuelo sí sigue cancelándose por daño, como siempre).
// Chequeo por tick (0.1s) dentro de los dos loops + el forward
// L4D2_OnStagger_Post para los staggers que aplica el motor.
//
// Devuelve:
//   0 = sigue (sin stun; o smoker agarrando pero inmune/en gracia)
//   1 = stun DURO (cancel YA: hunter/jockey/charger carry o pummel,
//       incap, ledge, o lanzado al aire: tank/roca/charger impact)
//   2 = smoker: la carga cae (2.5s del agarre y sigue agarrado)
int Tails_LaserStunState(int client)
{
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return 1;
    if (GetEntProp(client, Prop_Send, "m_isHangingFromLedge") > 0) return 1;
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return 1;
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return 1;
    if (GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0) return 1;
    if (GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0) return 1;

    // respaldo del OnStagger: un pico de velocidad HORIZONTAL mientras
    // se carga/dispara solo puede ser un lanzamiento (el walk-forzado
    // te tiene a 60uu/s y volando a ~300: nada legítimo pasa de 450).
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    float s2d = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
    if (s2d > 450.0) return 1;

    // SMOKER (caso especial): si estaba DISPARANDO cuando lo agarran,
    // el láser NO se cancela; la CARGA cae a los 2.5s del agarre (si
    // sigue agarrado). El primer tick que ve el agarre congela cómo
    // estaba el láser en ese momento.
    int tongue = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
    if (tongue > 0)
    {
        if (g_fTailsTongueAt[client] == 0.0)
        {
            g_fTailsTongueAt[client]     = GetEngineTime();
            g_bTailsTongueFiring[client] = g_bTailsFiring[client];
        }
        if (g_bTailsTongueFiring[client]) return 0;   // inmune (disparaba)
        if (GetEngineTime() - g_fTailsTongueAt[client] >= 2.5) return 2;
        return 0;                                     // gracia de 2.5s
    }
    g_fTailsTongueAt[client]     = 0.0;               // libre de lengua
    g_bTailsTongueFiring[client] = false;
    return 0;
}

// v5.23: interrupción del láser por stun: CD corto (7s) + zap, el mismo
// cancel de siempre PERO ahora solo lo provocan stuns. `external`
// distingue el contexto: desde los loops (dentro del callback del
// timer: NO se puede KillTimer) usa el reset suave; desde el forward
// OnStagger usa el externo, que mata el timer de verdad.
void Tails_LaserInterrupt(int client, bool external)
{
    if (external) Tails_ResetStateExternal(client);
    else          Tails_ResetState(client);
    g_fTailsLaserCooldown[client] = GetEngineTime() + g_cvTailsCancelCD.FloatValue;
    g_bTailsCannonCding[client] = true;
    EmitSoundToAll(TAILS_OM_SOUND_ZAP, client, SNDCHAN_AUTO, SNDLEVEL_TRAIN, _, 1.0, 100);   // v5.3: 100dB + vol 1.0
    EmitSoundToAll(TAILS_OM_SOUND_ZAP2, client, SNDCHAN_AUTO, SNDLEVEL_TRAIN, _, 1.0, 100);  // v5.2: _1 + _2 EN CAPA
    PrintCenterText(client, "¡Cañón interrumpido por stun!");
}

// v5.23: puño de tank / roca / impacto de charger = stagger del PLAYER
// (forward de left4dhooks, detour de CTerrorPlayer::OnStaggered).
// EL stagger SÍ corta el cañón ("incluso si recibe stagger", pedido
// del owner).
public void L4D2_OnStagger_Post(int client, int source)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;              // solo survivors

    // v6.5 Sonic: en bola o en la gracia del dodge, el stagger del
    // motor (puño/roca de tank, impacto de charger) se CANCELA al
    // instante (pedido del owner: la bola no se deja empujar).
    if (g_iPlayerCharIdx[client] == SONIC_INDEX)
    {
        Sonic_StaggerGuard(client);
        return;
    }

    if (g_iPlayerCharIdx[client] != TAILS_INDEX) return; // solo Tails
    if (!g_bTailsCharging[client] && !g_bTailsFiring[client]) return;
    Tails_LaserInterrupt(client, true);
}

// =======================
// ACTIVA 2: LASER CANNON (CON PENETRACIÓN)
// =======================

public Action Command_TailsLaser(int client, int args)
{
    if (!Tails_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != TAILS_INDEX) return Plugin_Handled;

    // v4.2 FIX: no disparar el laser incapacitado ni agarrado
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return Plugin_Handled;
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return Plugin_Handled;
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) return Plugin_Handled;
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return Plugin_Handled;

    float now = GetEngineTime();

    if (g_bTailsFiring[client]) return Plugin_Handled;

    // v5.0 OM: sesión de ORBS: cada pulsación dispara UN orbe (GMod:
    // bulletcount 3). Al 3ro la sesión muere con su CD.
    if (g_bTailsOrbSession[client])
    {
        Tails_FireOrb(client);
        return Plugin_Handled;
    }

    // duración de carga SEGÚN EL MODO (GMod: laser 4.75s, resto 2s)
    float chargeTime = (g_iTailsCannonMode[client] == 0) ? g_cvTailsCannonCharge.FloatValue
                                                         : g_cvTailsCannonCharge2.FloatValue;

    if (g_bTailsCharging[client])
    {
        if (now - g_fTailsChargeStartTime[client] >= chargeTime)
        {
            // FUEGO: dispatch por modo (GMod: attack dentro del pill)
            switch (g_iTailsCannonMode[client])
            {
                case 1: Tails_FireBurst(client);
                case 2: Tails_StartOrbSession(client);
                case 3: Tails_FireShockwave(client);
                default: Tails_StartFiring(client);
            }
        }
        else
        {
            // v5.0 OM (GMod): la re-tecla durante la carga la CANCELA
            // (cd corto de cancel). Antes solo mostraba "espera X".
            Tails_CancelCharge(client);
            PrintCenterText(client, "Carga cancelada (re-tecla)");
        }
        return Plugin_Handled;
    }

    if (now < g_fTailsLaserCooldown[client])
    {
        PrintCenterText(client, "Cañón recalentado. Espera %.1fs", g_fTailsLaserCooldown[client] - now);
        return Plugin_Handled;
    }

    g_bTailsCharging[client] = true;
    g_fTailsChargeStartTime[client] = now;
    
    // QoL: Ya no cancelamos el vuelo. Se puede cargar desde el aire.
    
    Tails_EmitLoud(client, TAILS_SOUND_CHARGE, SNDLEVEL_TRAIN);      // v5.3: 2 capas + 100dB
    if (g_iTailsCannonMode[client] == 0)
        PrintCenterText(client, "¡Cargando LÁSER! (%.1fs) Re-tecla = cancelar", chargeTime);
    else
    {
        char cname[16];
        Tails_CannonName(g_iTailsCannonMode[client], cname, sizeof(cname));
        PrintCenterText(client, "¡Cargando %s! (%.1fs) Re-tecla = cancelar", cname, chargeTime);
    }
    
    if (g_hTailsActionTimer[client] != INVALID_HANDLE) KillTimer(g_hTailsActionTimer[client]);
    g_hTailsActionTimer[client] = CreateTimer(0.1, T_TailsChargeLoop, GetClientUserId(client), TIMER_REPEAT);

    // v5.0 OM: mientras carga/dispara se mueve a WALK (60 uu/s, el
    // speedhandler del pill) — m_flMaxspeed mantenido por PreThink
    SDKUnhook(client, SDKHook_PreThink, Tails_SlowThink);
    SDKHook(client, SDKHook_PreThink, Tails_SlowThink);

    return Plugin_Handled;
}

// v5.0 OM: cancel de carga con CD corto (GMod: laser_cancel_cd 14)
void Tails_CancelCharge(int client)
{
    if (!g_bTailsCharging[client]) return;
    Tails_ResetStateExternal(client);
    g_fTailsLaserCooldown[client] = GetEngineTime() + g_cvTailsCancelCD.FloatValue;
    // v5.3: nivel 100dB + vol 1.0 (ya son 2 capas por diseno GMod)
    EmitSoundToAll(TAILS_OM_SOUND_ZAP, client, SNDCHAN_AUTO, SNDLEVEL_TRAIN, _, 1.0, 100);   // CannonCancel_1 de GMod
    EmitSoundToAll(TAILS_OM_SOUND_ZAP2, client, SNDCHAN_AUTO, SNDLEVEL_TRAIN, _, 1.0, 100);  // v5.2: GMod reproduce _1 + _2 EN CAPA
}

// nombre corto del modo (para los mensajes)
void Tails_CannonName(int mode, char[] out, int maxlen)
{
    switch (mode)
    {
        case 1: strcopy(out, maxlen, "BURST");
        case 2: strcopy(out, maxlen, "ORBS");
        case 3: strcopy(out, maxlen, "SHOCKWAVE");
        default: strcopy(out, maxlen, "LÁSER");
    }
}

public Action T_TailsChargeLoop(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    // v4.2: tambien cortar si cambio de personaje (antes el loop
    // visual segia corriendo para un jugador que ya no era Tails)
    if (!Tails_IsValidClient(client) || !IsPlayerAlive(client) || !g_bTailsCharging[client]
        || g_iPlayerCharIdx[client] != TAILS_INDEX)
    {
        // v4.2 FIX: anular el handle del slot correcto. Antes, si el
        // cliente habia desconectado (client=0), el handle quedaba
        // colgado y el proximo ocupante del slot reciba un
        // "Invalid handle" al intentar KillTimer sobre el.
        if (client > 0 && client <= MaxClients)
            g_hTailsActionTimer[client] = INVALID_HANDLE;
        return Plugin_Stop;
    }

    // v5.23: la carga SOLO se corta por stun (agarre de smoker/hunter/
    // jockey/charger, incap/ledge, golpe o roca de tank = cualquier
    // stagger o lanzamiento). El daño de un comun YA NO corta.
    int stun = Tails_LaserStunState(client);
    if (stun == 1 || stun == 2)
    {
        Tails_LaserInterrupt(client, false);
        return Plugin_Stop;
    }

    float pos[3]; GetClientAbsOrigin(client, pos); pos[2] += 10.0;
    
    TE_SetupBeamRingPoint(pos, 40.0, 10.0, g_iSpriteLaser, g_iSpriteHalo, 0, 15, 0.1, 5.0, 0.0, g_iColorLaser, 0, 0);
    TE_SendToAll();
    
    TE_SetupGlowSprite(pos, g_iSpriteGlow, 0.1, 1.2, 80);
    TE_SendToAll();

    return Plugin_Continue;
}

void Tails_StartFiring(int client)
{
    g_bTailsCharging[client] = false; 
    g_bTailsFiring[client] = true;
    g_bTailsImpactPlayed[client] = false;   // v5.2: impact sonara 1x en esta sesion
    
    // v5.0 OM: duración del rayo = GMod (OM_TailsShootDuration 3.75)
    g_fTailsFireEndTime[client] = GetEngineTime() + g_cvTailsFireTime.FloatValue;

    // v4.5 (peticion usuario): SISTEMA DE USOS. El 3er disparo activa
    // el MODO RAYGUN: en vez de un rayo son TRES rayos en abanico
    // (estilo Spread Gun / arma S de Contra). Ciclo: 1-2-RAYGUN-1-2...
    g_iTailsLaserUses[client]++;
    g_bTailsRaygunMode[client] = (g_iTailsLaserUses[client] % 3 == 0);

    if (g_hTailsActionTimer[client] != INVALID_HANDLE) KillTimer(g_hTailsActionTimer[client]);
    g_hTailsActionTimer[client] = CreateTimer(0.1, T_TailsFireLoop, GetClientUserId(client), TIMER_REPEAT);

    // v5.2 OM R3: GMod reproduce "tails laser ready" justo al completar
    // la carga (OM_TailsChargeEnabled -> ready), ANTES de arrancar el rayo
    // v5.3: 2 capas cada uno. OJO: el READY va en BODY+WEAPON a proposito:
    // en v5.2 el loop del disparo (mismo canal AUTO) lo PISABA al instante
    // y nunca se oia; con canales distintos AHORA SE OYEN LOS DOS.
    Tails_EmitLoud(client, TAILS_OM_SOUND_READY, SNDLEVEL_TRAIN, 100, SNDCHAN_BODY, SNDCHAN_WEAPON);
    Tails_EmitLoud(client, TAILS_SOUND_LASER_LOOP, SNDLEVEL_TRAIN);  // v5.3: 2 capas + 100dB
    // v5.22: el WAV del loop dura 3.75s y el rayo ahora 5s -> se re-emite
    // a los 3.6s (patron del loop de vuelo) para que el sonido no se muera
    // antes que el rayo. El StopLoud del final lo corta igual.
    g_fTailsLaserSndNext[client] = GetEngineTime() + 3.6;
    if (g_bTailsRaygunMode[client])
    {
        PrintCenterText(client, "MODO RAYGUN: SPRAY TRIPLE!");
        // Aviso visual del modo especial: anillo doble
        float pos[3]; GetClientAbsOrigin(client, pos); pos[2] += 10.0;
        TE_SetupBeamRingPoint(pos, 10.0, 120.0, g_iSpriteLaser, g_iSpriteHalo, 0, 15, 0.5, 8.0, 0.0, {255, 200, 0, 255}, 0, 0);
        TE_SendToAll();
    }
    else
    {
        PrintCenterText(client, "FUEGO A DISCRECION! (uso %d/3)", g_iTailsLaserUses[client] % 3);
    }
    
    // v5.0 OM: la penalización de velocidad ya NO usa
    // m_flLaggedMovementValue (prohibido en el suite: rubber-band).
    // El WALK de GMod lo mantiene Tails_SlowThink vía m_flMaxspeed.
}

public Action T_TailsFireLoop(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    // v4.2: tambien cortar si cambio de personaje
    if (!Tails_IsValidClient(client) || !g_bTailsFiring[client]
        || g_iPlayerCharIdx[client] != TAILS_INDEX)
    {
        // v4.2 FIX REENTRANCIA: NO llamar a Tails_ResetState aqui (hace
        // KillTimer del timer que esta corriendo ahora mismo). Limpieza
        // suave: parar sonido, flags y anular el handle del slot.
        if (client > 0 && client <= MaxClients)
        {
            if (IsClientInGame(client))
            {
                Tails_StopLoud(client, TAILS_SOUND_LASER_LOOP);
            }
            g_bTailsFiring[client]   = false;
            g_bTailsCharging[client] = false;
            g_hTailsActionTimer[client] = INVALID_HANDLE;
        }
        return Plugin_Stop;
    }

    if (GetEngineTime() > g_fTailsFireEndTime[client])
    {
        Tails_EndFiring(client);
        return Plugin_Stop;
    }

    // v5.23: el rayo SOLO se corta por stun (el daño ya no corta). El
    // final natural de los 5s (arriba) tiene prioridad: si el rayo ya
    // cumplió su tiempo es un final NORMAL (CD completo + cola de
    // sonido), no una interrupción.
    int stun = Tails_LaserStunState(client);
    if (stun == 1 || stun == 2)
    {
        Tails_LaserInterrupt(client, false);
        return Plugin_Stop;
    }

    // v5.22: re-emit del loop del rayo (el WAV dura 3.75s, el rayo 5s;
    // mismos canales de EmitLoud -> lo REPLAZA, no se apila)
    float nowSnd = GetEngineTime();
    if (nowSnd >= g_fTailsLaserSndNext[client])
    {
        Tails_EmitLoud(client, TAILS_SOUND_LASER_LOOP, SNDLEVEL_TRAIN);
        g_fTailsLaserSndNext[client] = nowSnd + 3.6;
    }

    // v5.3: el TRACE sale de los OJOS (punteria exacta: el rayo pega
    // donde apuntas) pero el HAZ visual y la linea de dano salen del
    // CAÑON DEL BRAZO del avatar (pedido del owner: "el rayo debe
    // salir del brazo del modelo de tails, no de la cabeza del
    // Superviviente"). El avatar (~33u) esta parentado a los PIES del
    // survivor: muzzle = pies + fwd 15 + derecha 12 + altura 21.
    float origin[3], angles[3];
    GetClientEyePosition(client, origin);
    GetClientEyeAngles(client, angles);
    float muzzle[3];
    Tails_GetMuzzlePos(client, muzzle);

    // v4.5 (peticion usuario): el rayo es UN POCO MAS GRANDE (ancho
    // 30->42 el haz principal, 10->14 el nucleo blanco) y en MODO
    // RAYGUN dispara TRES rayos en abanico (centro + laterales de
    // +-12 grados, estilo Spread Gun de Contra).
    int rayCount = g_bTailsRaygunMode[client] ? 3 : 1;
    // v5.7 FIX MIRA: el orden del v4.5 ponia -12 grados en [0] y el lazo
    // de UN rayo (modo LASER normal) usaba r=0 -> el haz y el dano
    // salian 12 grados a la DERECHA de la mira (confirmado en el video:
    // el rayo termina ~12 grados a la derecha de la cruz, a su misma
    // altura). Ahora [0] = CENTRO: el rayo unico pega EXACTO donde
    // apuntas; el abanico raygun queda igual (centro + laterales +-12).
    float yawOffsets[3];
    yawOffsets[0] = 0.0;
    yawOffsets[1] = -TAILS_RAYGUN_FAN_DEGREES;
    yawOffsets[2] = TAILS_RAYGUN_FAN_DEGREES;

    float sparksDone[3][3];  // posiciones de impacto de cada rayo
    int sparksCount = 0;

    for (int r = 0; r < rayCount; r++)
    {
        float rayAng[3];
        rayAng[0] = angles[0];
        rayAng[1] = angles[1] + yawOffsets[r];
        rayAng[2] = angles[2];

        float endPos[3];
        Handle trace = TR_TraceRayFilterEx(origin, rayAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer, client);
        if (TR_DidHit(trace)) TR_GetEndPosition(endPos, trace);
        else
        {
            float fwd[3]; GetAngleVectors(rayAng, fwd, NULL_VECTOR, NULL_VECTOR);
            ScaleVector(fwd, 2000.0);
            AddVectors(origin, fwd, endPos);
        }
        delete trace;

        // Visuals: haz principal MAS GRANDE + nucleo blanco. v5.3: nace
        // en el CAÑON del brazo (muzzle), no en la cabeza del survivor.
        TE_SetupBeamPoints(muzzle, endPos, g_iSpriteLaser, g_iSpriteHalo, 0, 0, 0.15, 42.0, 30.0, 0, 0.0, g_iColorLaser, 0);
        TE_SendToAll();

        int white[4] = {255, 255, 255, 255};
        TE_SetupBeamPoints(muzzle, endPos, g_iSpriteLaser, g_iSpriteHalo, 0, 0, 0.15, 14.0, 10.0, 0, 0.0, white, 0);
        TE_SendToAll();

        TE_SetupGlowSprite(endPos, g_iSpriteHalo, 0.1, 2.5, 220);
        TE_SendToAll();

        // Dano por linea de cada rayo (v5.3: linea desde el cañon)
        Tails_ProcessLaserHit(client, muzzle, endPos);

        if (sparksCount < 3)
        {
            sparksDone[sparksCount][0] = endPos[0];
            sparksDone[sparksCount][1] = endPos[1];
            sparksDone[sparksCount][2] = endPos[2];
            sparksCount++;
        }
    }

    // Chispas solo en los puntos de impacto (perf: centro siempre,
    // laterales solo en modo raygun)
    for (int s = 0; s < sparksCount; s++)
    {
        TE_SetupSparks(sparksDone[s], view_as<float>({0.0,0.0,1.0}), 50, 20);
        TE_SendToAll();
    }

    return Plugin_Continue;
}

void Tails_EndFiring(int client)
{
    g_bTailsFiring[client] = false;
    g_bTailsRaygunMode[client] = false;   // v4.5: el modo termina con el disparo
    g_hTailsActionTimer[client] = INVALID_HANDLE;
    g_fTailsLaserCooldown[client] = GetEngineTime() + g_cvTailsLaserCooldown.FloatValue + 1.0;
    
    // v5.22: el acumulador por-atacante murio con el sistema de
    // congelado (estado por-VICTIMA): nada que limpiar al soltar el rayo.

    // v4.3: el acumulador de witches NO se limpia aqui a proposito: es
    // estado por-witch compartido y otro Tails podria seguir disparando
    // sobre la misma witch. La Frescura la garantiza la expiracion de
    // 2s de cada slot (ver Tails_WitchAccSlot).

    PrintCenterText(client, "Cañón agotado. Enfriando...");
    Tails_StopLoud(client, TAILS_SOUND_LASER_LOOP); 

    // v5.0 OM: CD = laser_cd + 1 (GMod) + soltar el walk-forzado
    SDKUnhook(client, SDKHook_PreThink, Tails_SlowThink);
}

void Tails_ProcessLaserHit(int attacker, float start[3], float end[3])
{
    float damageTick = g_cvTailsLaserDamage.FloatValue; 
    // v4.5 (peticion usuario): rayo un poco MAS GRANDE: radio de
    // impacto del extremo 180->200 y tolerancia de linea 75->90
    float radiusSq = 200.0 * 200.0; 
    
    float vecLine[3];
    SubtractVectors(end, start, vecLine);
    float dotLine = GetVectorDotProduct(vecLine, vecLine);

    // 1. Especiales y Tank (MaxClients)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;

        float targetPos[3]; GetClientAbsOrigin(i, targetPos); targetPos[2] += 30.0;
        
        bool hit = false;
        
        if (GetVectorDistance(end, targetPos, true) <= radiusSq) hit = true;
        else if (dotLine > 0.0)
        {
            float vecPoint[3], tempLine[3];
            SubtractVectors(targetPos, start, vecPoint);
            float t = GetVectorDotProduct(vecPoint, vecLine) / dotLine;
            if (t >= 0.0 && t <= 1.0) 
            {
                float closestPoint[3];
                tempLine = vecLine;
                ScaleVector(tempLine, t);
                AddVectors(start, tempLine, closestPoint);
                if (GetVectorDistance(closestPoint, targetPos) <= 90.0) hit = true; 
            }
        }

        if (hit)
        {
            // v5.2 OM R3: "tails laser impact" en el PRIMER impacto de la
            // sesion (GMod lo reproduce con shouldstundamage; el WAV dura
            // 9s -> una sola vez por disparo para no apilar sonidos)
            if (!g_bTailsImpactPlayed[attacker])
            {
                g_bTailsImpactPlayed[attacker] = true;
                Tails_EmitLoud(i, TAILS_OM_SOUND_IMPACT, SNDLEVEL_TRAIN);   // v5.3: 2 capas + 100dB
            }
            SDKHooks_TakeDamage(i, attacker, attacker, damageTick, DMG_ENERGYBEAM | DMG_SHOCK);

            float pushDir[3];
            MakeVectorFromPoints(start, targetPos, pushDir);
            NormalizeVector(pushDir, pushDir);

            // v5.27: STUN UNIFICADO (pedido del owner: "no es mejor
            // unificar ambos stun en un solo documento?") — el
            // congelado del rayo es el OM_Stun v2.0, el MISMO
            // documento del stun de Sonic/Amy/Metal: freeze estatua +
            // ESTRELLAS (lo que le faltaba) + chispas + zap, con las
            // flags del rayo: hielo cyan, empujable por el haz,
            // stagger al liberar, duracion FIJA ("el rayo JAMAS
            // reinicia el contador") y sin iframes (re-congelable en
            // caliente). El ghost del limbo de spawn NO se congela
            // (spawnea limpio); con el sistema apagado (tails_sifreeze
            // 0) todo cae al empuje clasico de siempre.
            bool isGhost = (HasEntProp(i, Prop_Send, "m_isGhost")
                            && GetEntProp(i, Prop_Send, "m_isGhost") > 0);
            bool freezeOK = g_cvTailsSIFreeze.BoolValue && !isGhost;

            if (freezeOK)
            {
                // PRIMER toque = congelado FIJO (tails_sifreeze_duration).
                // Los toques siguientes solo empujan: el contador NO se
                // reinicia NUNCA ("aun si solo le pego por un instante
                // nada mas"). OM_IsStunned cubre tambien el caso raro de
                // un congelado por OTRO personaje: el rayo no lo roba, lo
                // respeta (Push es no-op en slots no empujables).
                if (!OM_IsStunned(i))
                {
                    if (OM_Stun(i, g_cvTailsSIFreezeDur.FloatValue, attacker,
                                0.0, DMG_OM_CLUB, false,
                                OM_STUN_F_CYAN|OM_STUN_F_PUSH|OM_STUN_F_STAGGER
                                |OM_STUN_F_FIXED|OM_STUN_F_NOIFRAME))
                    {
                        // hint de congelado (caller-side: el OM_Stun no
                        // sabe que su stunner es un rayo — el texto es
                        // del rayo). El de DESCONGELADO lo tira el
                        // OM_Stun con el flag STAGGER.
                        if (Tails_IsValidClient(attacker))
                        {
                            char hint[200];
                            Format(hint, sizeof(hint),
                                "<font color='#00FFFF' size='20'>>> INFECTADO CONGELADO! <<</font>\n\
<font color='#FFFFFF'>%.1fs fijos - el rayo lo empuja, el contador NO se reinicia</font>",
                                g_cvTailsSIFreezeDur.FloatValue);
                            PrintHintText(attacker, hint);
                        }
                    }
                }

                // El rayo PUEDE seguir empujando al congelado: misma
                // matematica del hold de la witch (450/z60 = clavado al
                // haz a ras de suelo, sin hundirse ni elevarse).
                float carry[3];
                carry = pushDir;
                ScaleVector(carry, TAILS_SIFRZ_BEAM_CARRY);
                carry[2] = TAILS_SIFRZ_BEAM_Z;
                OM_Stun_Push(i, carry, start);
            }
            else
            {
                // Empuje clasico por velocidad viva (ghosts / sistema off)
                ScaleVector(pushDir, 350.0);
                pushDir[2] = 100.0;

                float vel[3]; GetEntPropVector(i, Prop_Data, "m_vecVelocity", vel);
                AddVectors(vel, pushDir, vel);
                TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vel);
            }
            // v5.22: el acumulador de stagger 1.5s/2.5s (v4.3) se RETIRO:
            // el stagger ahora cae SIEMPRE al terminar el congelado (lo
            // tira el OM_Stun v2.0 con OM_STUN_F_STAGGER), que es el
            // ciclo que pidio el owner.
        }
    }

    // 2. Infectados Comunes
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            zPos[2] += 30.0;
            
            bool hit = false;
            if (GetVectorDistance(end, zPos) <= 200.0) hit = true;
            else if (dotLine > 0.0)
            {
                float vecPoint[3], tempLine[3];
                SubtractVectors(zPos, start, vecPoint);
                float t = GetVectorDotProduct(vecPoint, vecLine) / dotLine;
                if (t >= 0.0 && t <= 1.0) 
                {
                    float closestPoint[3];
                    tempLine = vecLine;
                    ScaleVector(tempLine, t);
                    AddVectors(start, tempLine, closestPoint);
                    if (GetVectorDistance(closestPoint, zPos) <= 90.0) hit = true; 
                }
            }

            if (hit)
            {
                SDKHooks_TakeDamage(entity, attacker, attacker, damageTick, DMG_ENERGYBEAM);
                float push[3]; MakeVectorFromPoints(start, zPos, push); NormalizeVector(push, push); ScaleVector(push, 400.0);
                push[2] += 150.0;
                TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
            }
        }
    }
    
    // 3. Witches
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float wPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", wPos);
            wPos[2] += 30.0;
            
            bool hit = false;
            if (GetVectorDistance(end, wPos) <= 200.0) hit = true;
            else if (dotLine > 0.0)
            {
                float vecPoint[3], tempLine[3];
                SubtractVectors(wPos, start, vecPoint);
                float t = GetVectorDotProduct(vecPoint, vecLine) / dotLine;
                if (t >= 0.0 && t <= 1.0) 
                {
                    float closestPoint[3];
                    tempLine = vecLine;
                    ScaleVector(tempLine, t);
                    AddVectors(start, tempLine, closestPoint);
                    if (GetVectorDistance(closestPoint, wPos) <= 90.0) hit = true; 
                }
            }

            if (hit)
            {
                SDKHooks_TakeDamage(entity, attacker, attacker, damageTick, DMG_ENERGYBEAM);

                // v4.3 FIX CRITICO: la witch es un NPC NextBot: su
                // locomocion reescribe la velocidad en cada tick de IA,
                // asi que el empuje crudo (el TeleportEntity de antes,
                // 250h/100v) se anulaba al instante → cuando se enojaba
                // y cargaba contra Tails, el laser no hacia nada. Ahora
                // el beam usa WitchFlight: mientras el rayo la mantiene,
                // su IA queda SUSPENDIDA y se la empuja a lo largo del
                // rayo → el laser SI es mas fuerte que su impulso.
                // push[2] COMPENSADO con la gravedad manual del vuelo:
                // el tick aplica vel[2] -= 800*0.05 ANTES de mover, y el
                // laser resetea la velocidad cada 0.1s (= 2 ticks). El
                // dz por ciclo de 0.1s es (X-40)*0.05 + (X-80)*0.05, que
                // es 0 exactamente con X=60: la witch queda "clavada" al
                // rayo a ras de suelo, sin hundirse (con X<60 tocaba el
                // suelo y entraba en un ciclo aterrizaje-relanzamiento
                // con spam de dano/hints) ni elevarse. Al soltarla (fin
                // del rayo), cae, aterriza y su IA se reactiva limpia
                // (garantia del sistema Witch_Flight).
                float push[3]; MakeVectorFromPoints(start, wPos, push);
                NormalizeVector(push, push);
                ScaleVector(push, 450.0);
                push[2] = 60.0;
                WitchFlight_Launch(entity, attacker, push);
                // v4.5: el dano del tick llego ANTES del relanzamiento: si
                // ese dano la mato, restaurarla al instante (no congelar
                // el cadaver hasta el tick de 33 Hz)
                WitchFlight_CheckDead(entity);

                // v4.3: acumulador del rayo sobre ESA witch. A las 1.5s
                // de laser continuo → golpe de STAGGER: la witch SI
                // puede ser tambaleada por el motor (mecanica vanilla:
                // un unico golpe >= 50 de dano de tipo explosivo la
                // hace tambalear, igual que el lanzagranadas o el
                // sniper). Impacto unico de 75 DMG_BLAST + lanzamiento
                // fuerte. Ella se recupera sola (es su comportamiento
                // nativo, no estado nuestro).
                int wslot = Tails_WitchAccSlot(entity);
                if (wslot != -1)
                {
                    g_fTailsWitchAcc[wslot] += 0.1;
                    if (g_fTailsWitchAcc[wslot] >= 1.5)
                    {
                        g_fTailsWitchAcc[wslot] = 0.0;

                        // Golpe unico >= 50 y explosivo → stumble nativo
                        SDKHooks_TakeDamage(entity, attacker, attacker,
                                            75.0, DMG_BLAST);

                        // Lanzamiento fuerte (es el stagger visual)
                        float bigPush[3];
                        MakeVectorFromPoints(start, wPos, bigPush);
                        NormalizeVector(bigPush, bigPush);
                        ScaleVector(bigPush, 650.0);
                        bigPush[2] = 250.0;
                        WitchFlight_Launch(entity, attacker, bigPush);
                        // v4.5: el golpe de 75 pudo matarla: no congelar cadaver
                        WitchFlight_CheckDead(entity);

                        TE_SetupExplosion(wPos, g_iSpriteHalo, 10.0, 1, 0, 0, 0);
                        TE_SendToAll();
                        if (Tails_IsValidClient(attacker))
                        {
                            PrintHintText(attacker,
                                "<font color='#FF69B4' size='20'>>> WITCH DESestabilizada! <<</font>\n\
<font color='#FFFFFF'>El rayo la tambaleo y la lanzo</font>");
                        }
                    }
                }
            }
            else
            {
                // sin rayo encima: enfriar su acumulador (como los SI)
                Tails_WitchAccDecay(entity);
            }
        }
    }
}

// ============================================================
//  v4.3: Acumulador de rayo por witch (slots por referencia)
// ============================================================

// Devuelve el slot de la witch (creandolo si hace falta) o -1 si
// no hay slots libres. Un slot cuya ultima actualizacion tenga mas
// de TAILS_WITCH_ACC_EXPIRE segundos se considera LIBRE: el
// acumulador nunca dispara un stagger instantaneo con progreso
// congelado de un rayo anterior.
int Tails_WitchAccSlot(int witch)
{
    if (witch <= MaxClients || !IsValidEntity(witch)) return -1;

    int ref = EntIndexToEntRef(witch);
    float now = GetEngineTime();

    for (int i = 0; i < TAILS_WITCH_ACC_SLOTS; i++)
    {
        if (g_iTailsWitchAccRef[i] == ref)
        {
            // Slot de esta witch: si el rayo la solto hace mas de
            // EXPIRE segundos, el progreso viejo no cuenta (empieza
            // de cero). Sin esto, un acumulador congelado de un rayo
            // anterior dispararia el stagger casi instantaneo en el
            // siguiente disparo del canon.
            if (now - g_fTailsWitchAccLast[i] > TAILS_WITCH_ACC_EXPIRE)
            {
                g_fTailsWitchAcc[i] = 0.0;
            }
            g_fTailsWitchAccLast[i] = now;
            return i;
        }
    }
    for (int i = 0; i < TAILS_WITCH_ACC_SLOTS; i++)
    {
        bool free = (g_iTailsWitchAccRef[i] == 0)
                    || (now - g_fTailsWitchAccLast[i] > TAILS_WITCH_ACC_EXPIRE);
        if (free)
        {
            g_iTailsWitchAccRef[i]  = ref;
            g_fTailsWitchAcc[i]     = 0.0;
            g_fTailsWitchAccLast[i] = now;
            return i;
        }
    }
    return -1;
}

// Enfriamiento del acumulador de una witch NO golpeada este tick
// (mismo criterio que el acumulador de los SI: -0.05 por tick).
void Tails_WitchAccDecay(int witch)
{
    if (witch <= MaxClients || !IsValidEntity(witch)) return;

    int ref = EntIndexToEntRef(witch);
    for (int i = 0; i < TAILS_WITCH_ACC_SLOTS; i++)
    {
        if (g_iTailsWitchAccRef[i] == ref)
        {
            g_fTailsWitchAcc[i] -= 0.05;
            if (g_fTailsWitchAcc[i] <= 0.0)
            {
                g_iTailsWitchAccRef[i]  = 0;
                g_fTailsWitchAcc[i]     = 0.0;
                g_fTailsWitchAccLast[i] = 0.0;
            }
            return;
        }
    }
}

// Limpieza total (OnMapStart: las refs del mapa anterior pueden
// repetir numericamente en el nuevo).
void Tails_WitchAccClearAll()
{
    for (int i = 0; i < TAILS_WITCH_ACC_SLOTS; i++)
    {
        g_iTailsWitchAccRef[i]  = 0;
        g_fTailsWitchAcc[i]     = 0.0;
        g_fTailsWitchAccLast[i] = 0.0;
    }
}

// ============================================================
//  v5.27: STUN UNIFICADO — este bloque (Tails_SIFreezeStart /
//  Tails_SIFreezePush / Tails_SIFrzRelease / Tails_SIFrzClearSlot /
//  Tails_SIFreezeClearAll / T_TailsSIFreezeTick + las 10 arrays de
//  estado del congelado) SE FUSIONO CON OM_Stun.inc v2.0 (el stun
//  de Sonic/Amy/Metal) por pedido del owner: "no es mejor unificar
//  ambos stun en un solo documento? ... para ir simplificando todo
//  y no gastemos tanto codigo en la misma cosa".
//  El rayo ahora llama: OM_Stun(..., OM_STUN_F_CYAN|PUSH|STAGGER|
//  FIXED|NOIFRAME) al primer toque y OM_Stun_Push(...) en cada tick
//  que lo sigue golpeando. TODO el comportamiento queda identico
//  (congelado 6s fijos + arrastre por el haz + stagger al liberar,
//  fisica Witch_Flight integra ahora en OM_Stun_PushTick) y ADEMAS
//  el congelado gana las ESTRELLAS del stun comun (lo que le faltaba).
// ============================================================


public bool TraceEntityFilterPlayer(int entity, int contentsMask, int data)
{
    // v4.2 FIX PROMESA ROTA: el header del v4.1 decia que el laser
    // "atraviesa hordas enteras", pero el trace se detenia en el
    // PRIMER comun infectado (o en un compaero) y el beam se cortaba
    // ahi. Ahora el trace ignora:
    //   1. Al propio Tails (data)
    //   2. A los compaeros sobrevivientes
    //   3. A los infectados comunes (entidades "infected")
    // El dano a todo lo que este EN la linea lo sigue haciendo
    // Tails_ProcessLaserHit (que es distancia-a-la-linea, no trace).
    // Especiales/Tank/Witches siguen bloqueando el beam (cuerpos
    // grandes) y los muros obviamente tambien.
    if (entity == data) return false;
    
    if (entity > 0 && entity <= MaxClients)
    {
        if (IsClientInGame(entity) && GetClientTeam(entity) == 2) return false;
        return true; // infectados especiales y tank SI bloquean
    }
    
    if (entity > MaxClients && IsValidEntity(entity))
    {
        static char cls[16];
        GetEntityClassname(entity, cls, sizeof(cls));
        if (strcmp(cls, "infected") == 0) return false; // comunes: atravesar
    }
    
    return true;
}

// ============================================================
//  v5.20.3: SONDA DE VALORES VIVOS (!tailscd)
// ============================================================
//  Origen (owner): "¿por qué el maldito cañón sigue teniendo 45 seg
//  de enfriamiento? ¿no se guarda en la cfg?" — con la config única
//  del manager (v3.75: Sonic_Suite.cfg auto-guardada) esto es
//  verificable en 5 segundos: imprime el valor VIVO de cada cvar
//  clave contra el DEFAULT DE FÁBRICA que trae el smx (GetDefault).
//  Los valores marcados [NO FABRICA] vienen de la cfg o de un
//  sm_cvar (y con el auto-guardado, ese valor es el que PERSISTE).

void Tails_CvarFrag(char[] out, int maxlen, const char[] label, ConVar cv, bool twoDec)
{
    char def[16];
    cv.GetDefault(def, sizeof(def));
    float defF  = StringToFloat(def);
    float liveF = cv.FloatValue;

    if (FloatAbs(liveF - defF) > 0.001)
    {
        if (twoDec) Format(out, maxlen, "%s %.2f [NO FABRICA]", label, liveF);
        else        Format(out, maxlen, "%s %.1f [NO FABRICA]", label, liveF);
    }
    else
    {
        if (twoDec) Format(out, maxlen, "%s %.2f", label, liveF);
        else        Format(out, maxlen, "%s %.1f", label, liveF);
    }
}

public Action Command_TailsCd(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    char f1[40], f2[40], f3[40], f4[40], f5[40], f6[40];
    char f7[40], f8[40], f9[40], f10[40], f11[40], f12[40];

    Tails_CvarFrag(f1,  sizeof(f1),  "CD láser",      g_cvTailsLaserCooldown, false);
    Tails_CvarFrag(f2,  sizeof(f2),  "CD interrump.", g_cvTailsCancelCD,      false);
    Tails_CvarFrag(f3,  sizeof(f3),  "carga",         g_cvTailsCannonCharge,  true);
    Tails_CvarFrag(f4,  sizeof(f4),  "rayo",          g_cvTailsFireTime,      true);
    Tails_CvarFrag(f5,  sizeof(f5),  "dura",          g_cvTailsFlyDuration,   false);
    Tails_CvarFrag(f6,  sizeof(f6),  "CD vuelo",      g_cvTailsFlyCooldown,   false);
    Tails_CvarFrag(f7,  sizeof(f7),  "CD manual",     g_cvTailsFlyCdCancel,   false);
    Tails_CvarFrag(f8,  sizeof(f8),  "roundrefresh",  g_cvTailsRoundRefresh,  false);
    Tails_CvarFrag(f9,  sizeof(f9),  "follow",        g_cvTailsFollow,        false);
    Tails_CvarFrag(f10, sizeof(f10), "localparent",   g_cvTailsLocalParent,   false);
    Tails_CvarFrag(f11, sizeof(f11), "dmg/tick",      g_cvTailsLaserDamage,   true);   // v5.22: x10 = dps
    Tails_CvarFrag(f12, sizeof(f12), "congelado",     g_cvTailsSIFreezeDur,   false);  // v5.22: segundos FIJOS del congelado

    ReplyToCommand(client, "[Tails] Valores VIVOS del server (lo que se usa AHORA):");
    ReplyToCommand(client, "[Tails] CAÑÓN: %ss | %ss | %ss + %ss", f1, f2, f3, f4);
    ReplyToCommand(client, "[Tails] VUELO: %ss | %ss | %ss", f5, f6, f7);
    ReplyToCommand(client, "[Tails] AVATAR: %s | %s | %ss | lerpcomp %.2f | R-TP %s (tails_avatar_tp: lo que ven los demas)", f9, f10, f8, g_cvTailsLerpComp.FloatValue, Tails_AvatarTPOn() ? "1" : "0");
    ReplyToCommand(client, "[Tails] v5.24: %s (x10 = %d/seg) | congelado SI: %ss fijos + tinte cyan (tails_sifreeze %s) | cañón SOLO lo corta un STUN (comunes NO) | pulso de pausa en CADA montaje (restaurado)",
                   f11, RoundToNearest(g_cvTailsLaserDamage.FloatValue * 10.0), f12,
                   g_cvTailsSIFreeze.BoolValue ? "1" : "0");
    ReplyToCommand(client, "[Tails] [NO FABRICA] = fijado por Sonic_Suite.cfg o sm_cvar (con el auto-guardado nuevo, ese valor se queda guardado).");
    return Plugin_Handled;
}


// ============================================================
//  v5.1 OM: CAÑÓN DE 4 MODOS (toggle: HABILIDAD 3 (C) o sm_tailscannon, la T de GMod)
// ============================================================
// 0 LÁSER  — carga 4.75s, rayo continuo 3.75s (T_TailsFireLoop)
// 1 BURST  — carga 2s, radial 200: 10 dmg + stun + empuje 750 +
//            quemadura 3s + anim ShootingBurst + jugador congelado
// 2 ORBS   — carga 2s, 3 orbes (uno por pulsación), explotan al tocar
//            o a los 3s, radio 130, 10 dmg
// 3 SHOCK  — carga 2s, zona de impulso en el punto de mira que da
//            +200 de velocidad a ALIADOS 5s; CD = laser_cd/2 + 1

public Action Command_TailsCannon(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Tails_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != TAILS_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fTailsToggleCD[client]) return Plugin_Handled;
    if (g_bTailsFiring[client] || g_bTailsOrbSession[client] || g_bTailsCharging[client])
    {
        PrintCenterText(client, "No puedes cambiar de modo ahora");
        return Plugin_Handled;
    }

    g_iTailsCannonMode[client] = (g_iTailsCannonMode[client] + 1) % 4;
    // v5.1: anti-spam configurable (GMod tails_togglecd 0.5). La HABILIDAD
    // 3 no tiene cooldown: cambiar el tipo de cañón no gasta recarga.
    g_fTailsToggleCD[client] = now + g_cvTailsToggleCD.FloatValue;

    char name[16];
    Tails_CannonName(g_iTailsCannonMode[client], name, sizeof(name));

    // v5.1: colores EXACTOS del laserswap de GMod (tails_ui_om.lua):
    // Laser azul / Burst verde / Orbs rojo / Shockwave amarillo
    int ring[4];
    switch (g_iTailsCannonMode[client])
    {
        case 1: { ring[0]=0;   ring[1]=255; ring[2]=0;   ring[3]=255; }  // Burst    verde
        case 2: { ring[0]=255; ring[1]=0;   ring[2]=0;   ring[3]=255; }  // Orbs     rojo
        case 3: { ring[0]=255; ring[1]=255; ring[2]=0;   ring[3]=255; }  // Shock    amarillo
        default:{ ring[0]=0;   ring[1]=0;   ring[2]=255; ring[3]=255; }  // Laser    azul
    }

    // v5.1: TINT DEL AVATAR (el flash del puppet de GMod): todo el
    // modelo flahea 0.35s con el color del modo; el think del avatar
    // lo devuelve a blanco al expirar (GMod: tails_laserswap_<modo>)
    if (g_iTailsAvatar[client] != 0)
    {
        int av = EntRefToEntIndex(g_iTailsAvatar[client]);
        if (av > 0 && IsValidEntity(av))
        {
            SetEntityRenderColor(av, ring[0], ring[1], ring[2], 255);
            g_fTailsTintUntil[client] = now + 0.35;
        }
    }

    // v5.17-B: tint también en la copia L
    if (g_iTailsAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iTailsAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
            SetEntityRenderColor(avL, ring[0], ring[1], ring[2], 255);
    }

    // feedback: "tails toggle.wav" REAL del OM (GMod: surface.PlaySound via net
    // message al cliente; aqui server-side con pitch 100 = reproduccion normal)
    // + anillo del color
    Tails_EmitLoud(client, TAILS_OM_SOUND_TOGGLE, SNDLEVEL_TRAIN);  // v5.3: 2 capas + 100dB
    float pos[3]; GetClientAbsOrigin(client, pos); pos[2] += 40.0;
    TE_SetupBeamRingPoint(pos, 10.0, 90.0, g_iSpriteLaser, g_iSpriteHalo, 0, 15, 0.5, 8.0, 0.0, ring, 0, 0);
    TE_SendToAll();

    PrintCenterText(client, "Cañón: %s", name);
    return Plugin_Handled;
}

// ============================================================
//  v5.0 OM: MODO 1 — BURST (blast radial, el "tails laser burst" GMod)
// ============================================================
void Tails_FireBurst(int client)
{
    g_bTailsCharging[client] = false;
    if (g_hTailsActionTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hTailsActionTimer[client]);
        g_hTailsActionTimer[client] = INVALID_HANDLE;
    }

    // anim one-shot del MDL + freeze del jugador (GMod: PillAnim +
    // OM_NoMovement durante la sesión de blast)
    Tails_AvatarOneShot(client, "ShootingBurst", 1.1);
    Tails_EmitLoud(client, TAILS_OM_SOUND_ORB_FIRE, SNDLEVEL_TRAIN);  // v5.3: 2 capas + 100dB

    // freeze 0.55s: velocidad cero + m_flMaxspeed=1 mantenido por timer
    float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[0] = 0.0; vel[1] = 0.0; vel[2] = 40.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    g_fTailsBurstFreezeEnd[client] = GetEngineTime() + 0.55;
    if (g_hTailsBurstFreeze[client] != INVALID_HANDLE)
        KillTimer(g_hTailsBurstFreeze[client]);
    g_hTailsBurstFreeze[client] = CreateTimer(0.1, T_TailsBurstFreeze, GetClientUserId(client), TIMER_REPEAT);

    // el boom llega a los 0.45s (GMod: timer.Simple(0.45))
    CreateTimer(0.45, T_TailsBurstBoom, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

    g_fTailsLaserCooldown[client] = GetEngineTime() + g_cvTailsLaserCooldown.FloatValue + 1.0;
    g_bTailsCannonCding[client] = true;
    SDKUnhook(client, SDKHook_PreThink, Tails_SlowThink);
}

public Action T_TailsBurstFreeze(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)
        || g_iPlayerCharIdx[client] != TAILS_INDEX)
        return Plugin_Stop;

    if (GetEngineTime() >= g_fTailsBurstFreezeEnd[client])
    {
        g_hTailsBurstFreeze[client] = INVALID_HANDLE;
        return Plugin_Stop;
    }

    // patron Speed_sonic: escribir m_flMaxspeed cada tanto; el motor lo
    // recalcula en cuanto dejamos de escribir (no hay restore manual)
    SetEntPropFloat(client, Prop_Data, "m_flMaxspeed", 1.0);
    if (GetEntityFlags(client) & FL_ONGROUND)
    {
        float v[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", v);
        v[0] = 0.0; v[1] = 0.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, v);
    }
    return Plugin_Continue;
}

public Action T_TailsBurstBoom(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;

    // origen = jugador + 20u adelante (GMod: pos + forward*20)
    float origin[3], eyeAng[3], fwd[3];
    GetClientAbsOrigin(client, origin); origin[2] += 40.0;
    GetClientEyeAngles(client, eyeAng);
    GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);
    origin[0] += fwd[0]*20.0; origin[1] += fwd[1]*20.0; origin[2] += fwd[2]*20.0;

    // FX x2 (GMod: dos om_tails_burst = rayos + chispas + luz)
    for (int i = 0; i < 2; i++)
    {
        TE_SetupBeamRingPoint(origin, 30.0, 200.0, g_iSpriteLaser, g_iSpriteHalo, 0, 15, 0.6, 30.0, 0.0, {255, 220, 40, 255}, 0, 0);
        TE_SendToAll();
        TE_SetupSparks(origin, view_as<float>({0.0, 0.0, 60.0}), 400, 40);
        TE_SendToAll();
        TE_SetupExplosion(origin, g_iSpriteHalo, 8.0, 1, 0, 0, 0);
        TE_SendToAll();
    }
    TE_SetupEnergySplash(origin, view_as<float>({0.0, 0.0, 1.0}), false);
    TE_SendToAll();
    Tails_EmitLoud(client, TAILS_OM_SOUND_BURST, SNDLEVEL_AIRCRAFT);  // v5.3: 2 capas + 120dB
    // v5.2: GMod reproduce SOLO "tails laser burst.wav" (el zap extra era del placeholder)

    float radiusSq = 200.0 * 200.0;

    // 1. especiales y tank
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;
        float tPos[3]; GetClientAbsOrigin(i, tPos); tPos[2] += 30.0;
        if (GetVectorDistance(origin, tPos, true) > radiusSq) continue;

        // dano + quemadura 3s (GMod: OM_burntarget 3s) + fling 750
        SDKHooks_TakeDamage(i, client, client, 10.0, DMG_CLUB | DMG_BLAST);
        IgniteEntity(i, 3.0);
        SIStagger_Auto(i, client, origin);

        float push[3]; MakeVectorFromPoints(origin, tPos, push);
        push[2] = 0.0;
        if (NormalizeVector(push, push) < 0.1) { push[0] = fwd[0]; push[1] = fwd[1]; push[2] = 0.0; }
        ScaleVector(push, 750.0);
        push[2] = 220.0;
        TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
    }

    // 2. comunes
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        float zPos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", zPos); zPos[2] += 30.0;
        if (GetVectorDistance(origin, zPos, true) > radiusSq) continue;

        SDKHooks_TakeDamage(ent, client, client, 10.0, DMG_CLUB | DMG_BLAST);
        IgniteEntity(ent, 3.0);
        float push[3]; MakeVectorFromPoints(origin, zPos, push);
        push[2] = 0.0;
        if (NormalizeVector(push, push) < 0.1) { push[0] = fwd[0]; push[1] = fwd[1]; push[2] = 0.0; }
        ScaleVector(push, 700.0);
        push[2] = 250.0;
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
    }

    // 3. witches (el rayo de 10 + lanzamiento con WitchFlight)
    ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        float wPos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", wPos); wPos[2] += 30.0;
        if (GetVectorDistance(origin, wPos, true) > radiusSq) continue;

        SDKHooks_TakeDamage(ent, client, client, 10.0, DMG_CLUB | DMG_BLAST);
        float push[3]; MakeVectorFromPoints(origin, wPos, push);
        NormalizeVector(push, push);
        ScaleVector(push, 750.0);
        push[2] = 260.0;
        WitchFlight_Launch(ent, client, push);
        WitchFlight_CheckDead(ent);
    }

    return Plugin_Stop;
}

// ============================================================
//  v5.0 OM: MODO 2 — ORBS (3 proyectiles de plasma por sesión)
// ============================================================
void Tails_StartOrbSession(int client)
{
    g_bTailsCharging[client] = false;
    if (g_hTailsActionTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hTailsActionTimer[client]);
        g_hTailsActionTimer[client] = INVALID_HANDLE;
    }
    g_bTailsOrbSession[client] = true;
    g_iTailsOrbsLeft[client] = 3;
    Tails_FireOrb(client);
}

void Tails_FireOrb(int client)
{
    g_iTailsOrbsLeft[client]--;

    // anim one-shot del MDL + sonido de disparo
    Tails_AvatarOneShot(client, "ShootingOrbShoot", 0.5);
    Tails_EmitLoud(client, TAILS_OM_SOUND_ORB_FIRE, SNDLEVEL_TRAIN, 110);  // v5.3: 2 capas + 100dB

    int orb = CreateEntityByName("prop_physics_override");
    if (orb > 0 && IsValidEntity(orb))
    {
        DispatchKeyValue(orb, "model", TAILS_OM_ORB_MODEL);
        DispatchKeyValue(orb, "targetname", "tails_orb_om");
        DispatchSpawn(orb);

        // nace en la "mano" (aprox: ojo - 8z + 20 adelante, GMod: hueso RightHand)
        float pos[3], eyeAng[3], fwd[3];
        GetClientEyePosition(client, pos); pos[2] -= 8.0;
        GetClientEyeAngles(client, eyeAng);
        GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);
        pos[0] += fwd[0]*20.0; pos[1] += fwd[1]*20.0; pos[2] += fwd[2]*20.0;
        TeleportEntity(orb, pos, NULL_VECTOR, NULL_VECTOR);

        // tint amarillo (GMod: plasma glow)
        SetEntityRenderMode(orb, RENDER_TRANSCOLOR);
        SetEntityRenderColor(orb, 255, 220, 40, 255);
        SetEntPropEnt(orb, Prop_Data, "m_hOwnerEntity", client);

        // velocidad hacia el punto de mira (GMod 8500 escalado a L4D2)
        float vel[3]; ScaleVector(fwd, g_cvTailsOrbSpeed.FloatValue);
        vel[0] = fwd[0]; vel[1] = fwd[1]; vel[2] = fwd[2];
        TeleportEntity(orb, NULL_VECTOR, NULL_VECTOR, vel);

        SDKHook(orb, SDKHook_StartTouch, Tails_OrbTouch);

        // fusible de 3s + glow parpadeante (0.1s)
        CreateTimer(3.0, T_TailsOrbFuse, EntIndexToEntRef(orb), TIMER_FLAG_NO_MAPCHANGE);
        CreateTimer(0.1, T_TailsOrbGlow, EntIndexToEntRef(orb), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    }

    if (g_iTailsOrbsLeft[client] <= 0)
    {
        // fin de la sesión: CD = laser_cd + 1 (GMod: bulletcount 0)
        g_bTailsOrbSession[client] = false;
        g_fTailsLaserCooldown[client] = GetEngineTime() + g_cvTailsLaserCooldown.FloatValue + 1.0;
        g_bTailsCannonCding[client] = true;
        SDKUnhook(client, SDKHook_PreThink, Tails_SlowThink);
    }
}

public void Tails_OrbTouch(int orb, int other)
{
    SDKUnhook(orb, SDKHook_StartTouch, Tails_OrbTouch);
    // explotar en el siguiente tick (no remover dentro del touch)
    CreateTimer(0.0, T_TailsOrbFuse, EntIndexToEntRef(orb), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_TailsOrbFuse(Handle timer, any ref)
{
    int orb = EntRefToEntIndex(view_as<int>(ref));
    if (orb > 0 && IsValidEntity(orb))
        Tails_OrbExplode(orb);
    return Plugin_Stop;
}

public Action T_TailsOrbGlow(Handle timer, any ref)
{
    int orb = EntRefToEntIndex(view_as<int>(ref));
    if (orb <= 0 || !IsValidEntity(orb)) return Plugin_Stop;

    float pos[3];
    GetEntPropVector(orb, Prop_Data, "m_vecOrigin", pos);
    TE_SetupGlowSprite(pos, g_iSpriteHalo, 0.12, 1.4, 220);
    TE_SendToAll();
    return Plugin_Continue;
}

void Tails_OrbExplode(int orb)
{
    float pos[3];
    GetEntPropVector(orb, Prop_Data, "m_vecOrigin", pos);
    int owner = GetEntPropEnt(orb, Prop_Data, "m_hOwnerEntity");
    AcceptEntityInput(orb, "Kill");

    // FX (GMod: cball_explode + AR2Explosion + gauss/cannon_high + weld2)
    TE_SetupSparks(pos, view_as<float>({0.0, 0.0, 60.0}), 300, 30);
    TE_SendToAll();
    TE_SetupExplosion(pos, g_iSpriteHalo, 8.0, 1, 0, 0, 0);
    TE_SendToAll();
    TE_SetupBeamRingPoint(pos, 10.0, 130.0, g_iSpriteLaser, g_iSpriteHalo, 0, 15, 0.5, 15.0, 0.0, {255, 220, 40, 255}, 0, 0);
    TE_SendToAll();
    TE_SetupEnergySplash(pos, view_as<float>({0.0, 0.0, 1.0}), false);
    TE_SendToAll();
    Tails_EmitLoud(owner > 0 ? owner : orb, TAILS_OM_SOUND_ORB_BOOM, SNDLEVEL_AIRCRAFT);  // v5.3: 2 capas + 120dB

    float radiusSq = 130.0 * 130.0;

    if (owner <= 0 || !IsClientInGame(owner) || !IsPlayerAlive(owner)) return;

    // especiales y tank
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;
        if (i == owner) continue;
        float tPos[3]; GetClientAbsOrigin(i, tPos); tPos[2] += 30.0;
        if (GetVectorDistance(pos, tPos, true) > radiusSq) continue;

        SDKHooks_TakeDamage(i, owner, orb <= 0 ? owner : owner, 10.0, DMG_CLUB);
        SIStagger_Auto(i, owner, pos);
        float push[3]; MakeVectorFromPoints(pos, tPos, push);
        push[2] = 0.0;
        if (NormalizeVector(push, push) < 0.1) { push[0] = 0.0; push[1] = 0.0; push[2] = 1.0; }
        ScaleVector(push, 500.0);
        push[2] = 200.0;
        TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
    }

    // comunes
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        float zPos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", zPos); zPos[2] += 30.0;
        if (GetVectorDistance(pos, zPos, true) > radiusSq) continue;

        SDKHooks_TakeDamage(ent, owner, owner, 10.0, DMG_CLUB);
        float push[3]; MakeVectorFromPoints(pos, zPos, push);
        push[2] = 0.0;
        if (NormalizeVector(push, push) < 0.1) { push[0] = 0.0; push[1] = 0.0; push[2] = 1.0; }
        ScaleVector(push, 450.0);
        push[2] = 220.0;
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
    }

    // witches
    ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        float wPos[3]; GetEntPropVector(ent, Prop_Send, "m_vecOrigin", wPos); wPos[2] += 30.0;
        if (GetVectorDistance(pos, wPos, true) > radiusSq) continue;

        SDKHooks_TakeDamage(ent, owner, owner, 10.0, DMG_CLUB);
        float push[3]; MakeVectorFromPoints(pos, wPos, push);
        NormalizeVector(push, push);
        ScaleVector(push, 450.0);
        push[2] = 200.0;
        WitchFlight_Launch(ent, owner, push);
        WitchFlight_CheckDead(ent);
    }
}

// ============================================================
//  v5.0 OM: MODO 3 — SHOCKWAVE (zona de velocidad para ALIADOS)
// ============================================================
// El ent_om_tails_speedboost de GMod: una bola eléctrica en el punto de
// mira que da +200 de velocidad a los aliados en radio 200 durante 5s.

void Tails_FireShockwave(int client)
{
    g_bTailsCharging[client] = false;
    if (g_hTailsActionTimer[client] != INVALID_HANDLE)
    {
        KillTimer(g_hTailsActionTimer[client]);
        g_hTailsActionTimer[client] = INVALID_HANDLE;
    }

    Tails_AvatarOneShot(client, "ShootingBurst", 0.6);
    Tails_EmitLoud(client, TAILS_OM_SOUND_SHOCK, SNDLEVEL_AIRCRAFT);  // v5.3: 2 capas + 120dB

    // GMod: CD del shockwave = laser_cd/2 + 1
    g_fTailsLaserCooldown[client] = GetEngineTime() + g_cvTailsLaserCooldown.FloatValue / 2.0 + 1.0;
    g_bTailsCannonCding[client] = true;
    SDKUnhook(client, SDKHook_PreThink, Tails_SlowThink);

    // 0.1s de delay (GMod: timer.Simple(0.1)) + trace al suelo del punto de mira
    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(client));
    CreateTimer(0.1, T_TailsShockPlace, dp, TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
}

public Action T_TailsShockPlace(Handle timer, Handle dpH)
{
    DataPack dp = view_as<DataPack>(dpH);
    dp.Reset();
    int client = GetClientOfUserId(dp.ReadCell());

    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;

    // punto de mira -> suelo (GMod: trace 5000 hacia abajo)
    float origin[3], eyeAng[3], fwd[3];
    GetClientEyePosition(client, origin);
    GetClientEyeAngles(client, eyeAng);
    GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);

    Handle tr = TR_TraceRayFilterEx(origin, eyeAng, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceEntityFilterPlayer, client);
    float hit[3];
    if (TR_DidHit(tr)) TR_GetEndPosition(hit, tr);
    else { ScaleVector(fwd, 2000.0); AddVectors(origin, fwd, hit); }
    delete tr;

    float down[3]; down[0] = hit[0]; down[1] = hit[1]; down[2] = hit[2] + 100.0;
    float end[3];   end[0] = hit[0];   end[1] = hit[1];   end[2] = hit[2] - 5000.0;
    tr = TR_TraceRayFilterEx(down, end, MASK_SOLID_BRUSHONLY, RayType_EndPoint, TraceEntityFilterPlayer, client);
    if (TR_DidHit(tr)) TR_GetEndPosition(hit, tr);
    delete tr;
    hit[2] += 3.0;

    // FX inicial x2 (GMod: dos om_tails_burst en el punto)
    for (int i = 0; i < 2; i++)
    {
        TE_SetupBeamRingPoint(hit, 20.0, 200.0, g_iSpriteLaser, g_iSpriteHalo, 0, 15, 0.8, 40.0, 0.0, {255, 220, 40, 255}, 0, 0);
        TE_SendToAll();
        TE_SetupSparks(hit, view_as<float>({0.0, 0.0, 80.0}), 350, 30);
        TE_SendToAll();
    }

    // ancla para el sonido de la zona (12s de vida)
    int anchor = CreateEntityByName("info_target");
    if (anchor > 0 && IsValidEntity(anchor))
    {
        DispatchKeyValue(anchor, "targetname", "tails_shock_om");
        DispatchSpawn(anchor);
        TeleportEntity(anchor, hit, NULL_VECTOR, NULL_VECTOR);
        // v5.3: loop ambiental: 1 sola capa (90dB, vol 1.0) para no saturar
        EmitSoundToAll(TAILS_OM_SOUND_ELEC, anchor, SNDCHAN_AUTO, SNDLEVEL_SCREAMING, _, 1.0);
    }

    // zona: 12s de pulsos a 0.5s (boost a aliados + FX)
    DataPack zone = new DataPack();
    zone.WriteCell(EntIndexToEntRef(anchor));
    zone.WriteFloat(hit[0]);
    zone.WriteFloat(hit[1]);
    zone.WriteFloat(hit[2]);
    zone.WriteFloat(GetEngineTime() + 12.0);
    CreateTimer(0.5, T_TailsShockZone, zone, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);

    return Plugin_Stop;
}

public Action T_TailsShockZone(Handle timer, Handle zoneH)
{
    DataPack zone = view_as<DataPack>(zoneH);
    zone.Reset();
    int anchorRef = zone.ReadCell();
    float x = zone.ReadFloat();
    float y = zone.ReadFloat();
    float z = zone.ReadFloat();
    float expire = zone.ReadFloat();
    float now = GetEngineTime();

    float origin[3]; origin[0] = x; origin[1] = y; origin[2] = z;

    if (now >= expire)
    {
        // cerrar: apagar el sonido del ancla y soltar los boosts
        int anchor = EntRefToEntIndex(anchorRef);
        if (anchor > 0 && IsValidEntity(anchor))
        {
            StopSound(anchor, SNDCHAN_AUTO, TAILS_OM_SOUND_ELEC);
            AcceptEntityInput(anchor, "Kill");
        }
        for (int i = 1; i <= MaxClients; i++)
        {
            if (g_fTailsSwBoostUntil[i] > 0.0)
            {
                g_fTailsSwBoostUntil[i] = 0.0;   // el motor re calcula solo
            }
        }
        return Plugin_Stop;
    }

    // pulso visual (bola eléctrica GMod: anillo + chispas)
    TE_SetupBeamRingPoint(origin, 150.0, 190.0, g_iSpriteLaser, g_iSpriteHalo, 0, 15, 0.4, 12.0, 0.0, {255, 220, 40, 255}, 0, 0);
    TE_SendToAll();
    TE_SetupSparks(origin, view_as<float>({0.0, 0.0, 60.0}), 60, 15);
    TE_SendToAll();

    // boost a aliados vivos en radio 200 (GMod: +200 por 5s, repetible)
    float radiusSq = 200.0 * 200.0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 2) continue;

        float aPos[3]; GetClientAbsOrigin(i, aPos);
        bool inside = (GetVectorDistance(origin, aPos, true) <= radiusSq);

        if (inside && g_fTailsSwBoostUntil[i] < now)
        {
            // nueva toma: snapshot de su velocidad natural y +200 por 5s
            g_fTailsSwBoostBase[i]  = GetEntPropFloat(i, Prop_Data, "m_flMaxspeed");
            g_fTailsSwBoostUntil[i] = now + 5.0;
            PrintCenterText(i, "¡Velocidad de Tails! (+200, 5s)");
        }

        if (g_fTailsSwBoostUntil[i] > now)
        {
            // mantenimiento aditivo: base_snapshot + 200 (no pisamos
            // stacks ajenos: escribimos el snapshot + el bonus)
            SetEntPropFloat(i, Prop_Data, "m_flMaxspeed", g_fTailsSwBoostBase[i] + 200.0);
        }
    }
    return Plugin_Continue;
}

// ============================================================
//  v5.0 OM: WALK de GMod mientras carga/dispara (speedhandler del pill)
// ============================================================
public void Tails_SlowThink(int client)
{
    if (!g_bTailsCharging[client] && !g_bTailsFiring[client] && !g_bTailsOrbSession[client])
    {
        SDKUnhook(client, SDKHook_PreThink, Tails_SlowThink);
        return;
    }
    if (g_bTailsFlying[client]) return;   // volando no se frena (QoL suite)

    // GMod: run -> walk mientras carga/dispara (delta -352 del speedhandler)
    SetEntPropFloat(client, Prop_Data, "m_flMaxspeed", 60.0);
}

// ============================================================
//  v5.0 OM: cancel por DAÑO (OM_DamageBeforeCustomFunction del pill)
// ============================================================
public Action Tails_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
    if (victim < 1 || victim > MaxClients) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != TAILS_INDEX) return Plugin_Continue;

    // GMod: recibir daño cancela el VUELO al instante (sin CD)
    if (g_bTailsFlying[victim])
    {
        Tails_StopFlying(victim, false);
        PrintCenterText(victim, "¡Vuelo interrumpido por daño!");
    }

    // v5.23: EL DAÑO YA NO CORTA EL CAÑÓN (contrato del owner, el
    // arreglo perdido: solo los stuns lo interrumpen — ver
    // Tails_LaserStunState y L4D2_OnStagger_Post). Ni un comun ni
    // ningún otro daño: el rayo sigue hasta sus 5s o hasta el stun.
    // El vuelo (arriba) sigue cancelándose por daño como siempre.

    return Plugin_Continue;
}
