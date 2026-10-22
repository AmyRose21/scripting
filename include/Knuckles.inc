/*
 * ======================================================
 *  [MODULO] Knuckles the Echidna - Power & Defense v71-OM (EL PARRY DE PROYECTILES SE DELEGA AL VSCRIPT chch_parrying.nut v2.3)
 *
 *  v76-OM - PATCH DE BALANCE (manager 3.77.50, pedido literal del owner
 *     2026-10-11: "Knuckles recibira un buff reducción de sus
 *     enfriamientos 4 seg menos"): los TRES cooldowns principales -4s —
 *     Puño 15 -> 11s, Postura/Counter 20 -> 16s, H3 Meteoro 20 -> 16s.
 *     Cero cambios de lógica; el dano del counter y su duración (8s)
 *     quedan como estaban (el counter buffado en este parche es el de
 *     ROGUE, su X v10.3). El cooldown de cancelación de la carga
 *     (knux_punch_cd_cancel 5s, caso reducido del puño) queda intacto.
 *
 *  v71-OM CHANGES (suite 3.77.38 — reporte del owner 2026-10-10,
 *     "así ocurrirá con Knuckles también que empujara al boomer y
 *     cuando este toque el suelo después de volar estallara (también
 *     cuenta su ataque aéreo)"):
 *   - SMASH AÉREO vs BOOMER: el dano del smash YA NO lo mata a los
 *     pies de Knuckles — si el golpe sería letal se queda sin aplicar,
 *     y en TODOS los casos el boomer sale VOLANDO con la levantada de
 *     siempre + la MECHA (OM_BoomerFuseMark GROUND del OM_Stun v2.1):
 *     estalla solo al TOCAR EL SUELO tras volar. (El empuje del parry
 *     VScript — ventana/shove — lleva su propia mecha dentro del
 *     chch_parrying.nut v2.3.)
 *
 *  v70-OM CHANGES (R40 — "le quites el parry toggle pues la idea era
 *     como te plantee delegar el parry al vscript, solo el SMX le
 *     avisara que está activo su shove parry, la ventana quedara
 *     abierta hasta que el smx le diga que knux termino parry"):
 *   - MUERE TODO EL PARRY DE PROYECTILES DEL LADO DEL MANAGER (el que
 *     crasheaba): eliminado el escaneo de la postura (Knux_ParryScan
 *     + throttle 0.05s), el reflect, el watchdog de rocas, la lista
 *     de spits devueltos, el hook del evento spit_burst (Knux_Event_
 *     SpitBurst), el boom diferido (T_KnuxSpitBurstBoom), la explosión
 *     del parry (Knux_ParryExplosion + T_KnuxKillEnt) y las 4 convars
 *     (knux_parry_projectiles/spit/rocks/radius) con sus defines —
 *     TODO el camino del crash desaparece del suite de raíz.
 *   - ARQUITECTURA FINAL (la que pidió): el parry de proyectiles lo
 *     ejecuta EL VSCRIPT chch_parrying.nut v2.2 (el bueno: universal,
 *     cono, granadas, props Y enemigos con cooldown). El Parry.smx
 *     v2.1 detecta el shove-parry, hace el parry instantaneo de
 *     siempre y le AVISA al nut (ChCh_KnxNotify idx,1,dur = "Knuckles
 *     está en parry"); la ventana del nut queda ABIERTA toda la
 *     duración y se cierra cuando el smx manda la orden de apagado
 *     (ChCh_KnxNotify idx,0 = "knux termino parry" — expiry, muerte,
 *     cambio de equipo o disconnect).
 *   - LA POSTURA (sm_knux_counter) vuelve a ser SOLO el counter de
 *     GOLPES FÍSICOS como siempre (v65 y anteriores): cero contacto
 *     con proyectiles, cero riesgo del charco acido corrupto.
 *
 *  v69-OM CHANGES (R38 — "ES A KNUCKLES POR EL AMOR A JESUCRISTO! EL
 *     CÓDIGO ERA PARA QUE VIERAS COMO SE HACE!" (el chch_parrying.nut
 *     era MATERIAL DE REFERENCIA, no un mod que el owner corra) +
 *     "PON UN COMANDO QUE PUEDA PERMITIR SI KNUCKLES PUEDE PARRY
 *     PROYECTILES (spiter y tank) A SOLAMENTE PARRYEAR GOLPES FÍSICOS
 *     COMO SIEMPRE"):
 *   - PALANCA MAESTRA knux_parry_projectiles (default 1; console:
 *     knux_parry_projectiles 0): 0 = la postura NO devuelve NINGÚN
 *     proyectil (ni escupitajos del spitter NI rocas del tank: escaneo
 *     y boom del spit_burst congelados) y Knuckles queda parrynado
 *     GOLPES FÍSICOS como siempre — el counter/bloqueo melee no se
 *     toca para nada. 1 = comportamiento .31-.33. Las palancas
 *     individuales knux_parry_spit / knux_parry_rocks quedan debajo
 *     de la maestra (maestra en 0 = off total, pasan de todo).
 *   - FIX DEL VECTOR DE CRASH QUE PERSISTIO TRAS LA v68 (forense del
 *     chch_parrying.nut, condición [C]): Knux_ParryReflect le ponía
 *     m_hThrower = superviviente al SPIT devuelto — el motor crea el
 *     charco acido con esa "propiedad" corrupta (el dueño del dano
 *     del charco deja de ser la spitter) y crashea al procesarlo.
 *     v69: al spit JAMÁS se le toca el m_hThrower (el credito del boom
 *     del spit_burst ya sale de la lista de slots); la ROCA si lo
 *     conserva (es seguro y da el credito — las rocas nunca
 *     crashearon).
 *   - INTACTO: TODO lo demas de la v68 (boom diferido al frame
 *     siguiente, watchdog de rocas, latch orientado, fuego en los
 *     puños, counter/bloqueo y sus animaciones, Meteoro, avatar).
 *
 *  v68-OM CHANGES (R36 — "todavia se sigue crasheando el left. Analiza
 *     bn el VSCRIPT para poder saber"):
 *   - CAUSA RAÍZ DEL CRASH QUE PERSISTIA (forense del chch_parrying.nut
 *     v2.1 completo, 630 líneas): el nut NUNCA ejecuta su explosión
 *     dentro del código del juego — los callbacks OnGameEvent_* de
 *     VScript en L4D2 se ENCOLAN y corren en el siguiente ciclo del
 *     script VM, y aún dentro del callback el Explode del env_explosion
 *     pasa por la COLA de entity I/O del motor (EntFireByHandle delay 0
 *     = siguiente frame, l.543). SourceMod HookEvent en cambio es
 *     SINCRONO: Knux_Event_SpitBurst corria DENTRO del stack del
 *     spitter_projectile reventando (donde nace el charco y se
 *     autodestruye) y ahi adentro la v67 hacia CreateEntityByName +
 *     DispatchSpawn + AcceptEntityInput("Explode") inmediato +
 *     SDKHooks_TakeDamage DMG_BLAST a props/witch/infectados — con
 *     vphysics en plena colisión = crash. PRUEBA: la ROCA (misma
 *     Knux_ParryExplosion, pero desde un TIMER = contexto seguro como
 *     el logic_timer del nut) NUNCA crasheo; solo el spit (desde el
 *     evento) crasheaba. El contexto era el asesino.
 *   - FIX v68: Knux_Event_SpitBurst queda de SOLO LECTURA — detecta el
 *     spit devuelto cerca del subject (<=16u como el nut), captura
 *     posición + userid, limpia el slot y DIFIERE TODA la explosión a
 *     un timer de 0.0s (siguiente frame = la semantica EXACTA del nut:
 *     callback encolado + Explode encolado). Cero mutación de entidades
 *     dentro del evento. T_KnuxSpitBurstBoom dispara la misma
 *     Knux_ParryExplosion 250/150u solo infectados, ahora en contexto
 *     seguro entre frames (el mismo de la roca, que nunca fallo).
 *   - PARIDAD NUT en Knux_ParryExplosion: env_explosion con spawnflags=1
 *     (SF_ENVEXPLOSION_NODAMAGE — el nut l.540: explosión del motor
 *     puramente visual) + rendermode 5 (nut l.540) + func_breakable en
 *     los objetivos del dano manual (targets del nut l.549: le faltaba).
 *   - INTACTO: el latch orientado, el fuego de los puños, el watchdog de
 *     rocas (timer, vel<=100 o 5s como CheckParriedTankRocks), la
 *     devolución del spit (velocidad + m_hThrower + piso 900), el
 *     bloqueo/counter y TODO lo demas de la v67.
 *  v67-OM CHANGES (R35 — "fix el agarre de pared si vez el lua este
 *     cambia la orientación de knuckles al lado contrario a la pared
 *     (lo dice el lua)" + "el efecto de fuego de su 3 fase puedes
 *     colocarle 2 efectos de fuego en los puños (lo dice el propio lua
 *     de gmod)" + "cuando uso el counter sobre el vómito de la spitter
 *     en vez de devolverse como hace en Vscript el juego se muere y
 *     se cierra. solo"):
 *   - AGARRE DE PARED ORIENTADO (lua l.759-792): al engancharse, el
 *     pill_assignedangle = normal:Angle() — el avatar queda MIRANDO
 *     AL LADO CONTRARIO de la pared (espalda contra ella; el giro lo
 *     suaviza el ExpDamp del yaw). Gate del lua l.761 (|normal.z| <
 *     0.5): solo paredes, nunca suelo/techo. El SALTO DE SALIDA sale
 *     por la NORMAL de la pared (lua l.700: Normals_latch:Forward()*
 *     glideg) — antes salia por la cámara y podias lanzarte contra la
 *     propia pared que mirabas.
 *   - FUEGO REAL EN LOS PUÑOS (lua l.1123-1190 + effects l.319-484):
 *     la espiral Knuckles_FireOrb EXACTA del GMod (radio 35->0, 2
 *     vueltas, ciclo 0.9s, onda ~18 Hz, color fuego 255/120-245/30)
 *     dibujada con beams TE + material NUEVO om_knux_flame (blaze
 *     flame del pack OM, 2 archivos en materials/icons) sobre CADA
 *     PUÑO (2 efectos, uno por mano) + nucleo env_sprite de llama en
 *     la mano + el ANILLO Knuckles_firering al alcanzar el nivel 3
 *     (l.1179-1189). Fallback glow01 naranja si el material no esta
 *     montado (patron om_bluesmoke). Palanca knux_fist_fire (1).
 *   - FIX DEL CRASH del counter sobre el spit (reporte del owner):
 *     causa — la v66 hookeaba SDKHook_Touch al spitter_projectile y
 *     lo mataba con Kill: el juego revienta el spit por DENTRO de su
 *     propio touch (spawn del charco + autodestrucción) y el
 *     doble-manipulo lo tumbaba. FIX nut-faithful (ChCh v2.1): el
 *     spit SOLO se devuelve (velocidad + m_hThrower + lista propia de
 *     refs) — CERO hooks, CERO watchdog, CERO Kill sobre el; la
 *     explosión cae encima cuando el JUEGO lo revienta (evento
 *     spit_burst, el mismo camino del nut: spitter_projectile a <=16u
 *     del subject -> explosión 250/150u solo infectados). Las ROCAS
 *     pierden también el touch hook (el nut no lo usa): quedan con el
 *     watchdog de velocidad (vel<=100 o 5s -> explosión 500/250u +
 *     Kill, como CheckParriedTankRocks). Sonido de las explosiones =
 *     explode_1-3 del nut (antes el skyboom del Meteoro).
 *
 *  v66-OM CHANGES (R34 — "el puño se puede cargar (el lua lo dice
 *     todo)" + "el bloqueo no hace su animación de golpe ni de
 *     preparación" + "la animación counter y counter_hit no están
 *     mirando de frente sino hacia la derecha" + "este sistema
 *     devuelve proyectiles... para devolver escupitajos de spitter
 *     o rocas de tank con más eficacia"):
 *   - CARGA DEL PUÑO DE 3 NIVELES (lua l.1105-1164, convars
 *     knux_charge_t1 4.5 / knux_charge_t2 9.0): nivel 2 = phase1.wav
 *     + pulso rojo (Knuckles_glow_1->2 l.1107-1121), nivel 3 =
 *     phase3.wav + pulso (l.1152-1164), y las ORBES DE FUEGO en los
 *     puños desde 0.6s antes del nivel 3 (Knuckles_FireOrb l.1123-
 *     1149 — glow01 naranja a 20 Hz, el patron de las estrellas del
 *     OM_Stun). El golpe escala con el nivel como el original: dano
 *     x1.15/x1.30 (damageamount1/2 sobre basedamage, l.926-931), stun
 *     de ESTATUA OM_Stun 4/5/6s (basestun 4 + stunamount 1/2, l.303 y
 *     l.583) EMPUJABLE (OM_STUN_F_PUSH + OM_Stun_Push: la estatua
 *     vuela con el lanzon y desliza como el rayo de Tails), lanzon
 *     x1/x2/x3 (750*(additives+1), l.323) y QUEMA de 8s al nivel 3
 *     (OM_burntarget 8, l.306-307). CLICK = Slam1-4.wav aleatorio
 *     (l.1757-1765). Cancelar con [R] cobra el COOLDOWN CORTO del
 *     original (knux_punch_cd_cancel 5.0 = cooldown_cancel l.1688;
 *     antes el cancel no cobraba nada).
 *   - ANIMACIONES DEL BLOQUEO (los 2 gestures del lua que faltaban):
 *     PREPARACION = 'counter' al activar la postura (AddGesture
 *     ACT_GESTURE_RANGE_ATTACK1_LOW l.1618, fade 1.25s l.1637) y
 *     GOLPE = 'counter_hit' al bloquear (ACT_GESTURE_RANGE_ATTACK2_LOW
 *     l.590, fade 0.5s l.609) — one-shots KNUX_ST_COUNTER /
 *     KNUX_ST_COUNTER_HIT sobre las DOS copias del avatar.
 *   - FIX DE FACING (aviso del owner): las secuencias counter y
 *     counter_hit del knuckles.mdl miran a la DERECHA — mientras corre
 *     el one-shot el avatar gira KNUX_COUNTER_YAW_FIX (+90) para que
 *     la pose mire al FRENTE. Si saliera girado al lado contrario:
 *     cambiar el define a -90.0 (1 línea, receta en CAMBIOS).
 *   - PARRY DE PROYECTILES en la POSTURA (receta ChCh_Parrying v2.1
 *     que el owner paso de referencia): escupitajos del spitter y
 *     ROCAS DEL TANK dentro de knux_parry_radius (300) y del cono
 *     frontal (dot 0.30 + emergencia <100u = ChCh PassesConeFilter)
 *     se DEVUELVEN hacia donde apunta el Knuckles con piso de 900
 *     uu/s (ChCh ParryGrenade; la roca a x1.5) y credito vía
 *     m_hThrower. Al aterrizar o tocar a un infectado DETONAN:
 *     env_explosion magnitud 0 (visual) + particula
 *     weapon_grenadelauncher + dano MANUAL solo a infectados (roca
 *     500/250u, spit 250/150u — números exactos del ChCh; QoL: JAMÁS
 *     dana al equipo). Reemplaza el reflejo tosco v58 (Kill + respawn
 *     de grenade_launcher). Convars knux_parry_spit/knux_parry_rocks
 *     (default 1/1).
 *
 *  v65-OM CHANGES (R33 — "Incluiremos a knuckles... revisa lua de
 *     knuckles... y hacer el añadido y todo el resto ya lo sabes"):
 *   - EL AVATAR (5o avatar del suite, patron Metal v5.4/sonic v6.30):
 *     doble copia R/L (la R para los demas — viaja por TP con
 *     tails_avatar_tp, la L parentada contra los eye angles del
 *     dueño), pulso de pausa, FSM de 10 Hz y cvar knux_avatar 1.
 *     Modelo models/Noodles/OM/knuckles.mdl del VPK om_ (escala 1,
 *     l.51 del lua) con gate PrecacheModel: sin VPK no se monta y
 *     TODO lo demas sigue igual.
 *   - FSM con las 15 SECUENCIAS del knuckles.mdl que usa el lua GMod
 *     (noodles_om_pills_survivors_knuckles.lua): idle/walk/run/jump/
 *     fall + glide (planeo, ShouldAlternate.fall l.231) + latch
 *     (agarre de pared l.227 y hover del Meteoro) + FallAttack
 *     (picada del smash aéreo l.229 y del Meteoro) + los one-shots
 *     de los 5 PillAnim del lua (PunchAnim l.326, GroundSmash l.1073,
 *     attack = lanzamiento aéreo l.1781, LatchOff l.1585) + las
 *     variantes lowhealth de HP<=60 (ShouldAlternate l.213-241).
 *     Walk al rate 1.0 CONSTANTE (knuckles NO define animrates —
 *     framework l.936-944: rate 1 para TODO; lección Metal v5.2), run
 *     al ritmo de la velocidad como el resto del suite.
 *   - TINTES DEL UI (knuckles_ui_om.lua, fades simetricos EXACTOS
 *     duration 0.5*0.5=0.25s / fade 0.25*0.5=0.125s): pulso ROJO
 *     repetido cargando el puño (Knuckles_glow_duration), BLANCO al
 *     bloquear con la contra (glow_duration_white), VERDE al
 *     cancelar (glow_cancel_duration) y la postura azul 200,200,255
 *     de siempre del port (el cuerpo sigue tintándose también para
 *     el modo sin avatar).
 *   - SONIDOS AUTÉNTICOS del VPK om/knuckles/ con gates y fallback
 *     stock (receta Metal): punchstart (inicio de carga), swing
 *     (lanzamiento aéreo/terrestre), punchstun (impacto que aturde),
 *     counter (activación de la postura), CounterBounce (rebote de
 *     bloqueo, vol 0.65 en el lua), Latch (agarrarse de pared) y
 *     KnucklesCancel (cancelar la carga con R).
 *   - RAGDOLL DE MUERTE prop_ragdoll knuckles.mdl 15s (noragdoll=false
 *     del lua l.59) + ventana anti-corpse 2s/200u (receta Sonic
 *     v3.76.2 vía Knuckles_OnEntityCreated — lo despacha Rouge.inc).
 *   - FIX DE CICLO DE VIDA: Knuckles_OnPlayerDeath NUEVO para el
 *     cambio de personaje/desconexion del manager (antes solo
 *     Knux_ResetState: el avatar habría quedado huerfano).
 *
 *  v64 CHANGES (R32 — FIX del Meteoro, reporte literal del owner:
 *     "al presionar la c explota en el aire y no debería ser... debería
 *     ser impulsado a la dirección donde el seleccione y caera por
 *     gravedad... la explosión sucede después de que este impacte en el
 *     suelo... la roca también debería no estar muy separado... debería
 *     ir a la dirección de donde el apunte... fix al contacto con una
 *     pared suelo o algo ya que esta las ignora"):
 *   - PICADA (aérea): la velocidad sigue EXACTAMENTE la dirección de la
 *     mira (fuera el clamp vertical +150) y se aplica UNA SOLA VEZ: el
 *     vuelo es del motor, con gravedad real ("dara el impulso pero
 *     caera por gravedad eventualmente"). Antes el think re-afirmaba la
 *     velocidad cada frame: borraba la gravedad y lo dejaba flotando
 *     adelante-arriba hasta que la tapa dura detonaba EN EL AIRE.
 *   - La explosión de la picada sucede al IMPACTAR: tocar suelo
 *     (FL_ONGROUND) o estrellarse de frente (trace horizontal de muro).
 *     Tapa dura de 3s como seguro.
 *   - ESFERA (terrestre): sale hacia donde apuntas (fuera el clamp que
 *     la lanzaba por encima de la cabeza en una dirección fija) y
 *     detona AL CONTACTO con pared/suelo/infectado/lo que sea (trace con
 *     pad anti-tunel). El timer de 2.5s queda SOLO de respaldo si no
 *     impacta nada en su vuelo.
 *
 *  v63 CHANGES (R30 — pedido literal del owner):
 *   - AJUSTE 1: "su golpe ahora tanto su lanzamiento hacia adelante
 *     como su golpe al suelo en área ahora Puede empujar Objetos (props)
 *     autos y demas Con el mismo tipo de sistema que amy (sin la parte
 *     de convertir objetos en V)". El DASH PUNCH y el GROUND SLAM del
 *     Meteor Smash barren y avientan objetos con física (V/VPHYSICS) de
 *     fábrica: receta EXACTA del martillo de Amy (liberar física +
 *     golpe real con fuerza escalada por masa + despertador nativo
 *     env_physexplosion + aventon + volteo). SIN conversión: los
 *     decorativos (prop_dynamic) ni se tocan.
 *   - NUEVA HABILIDAD 3 "METEOR STRIKE" (tecla C / sm_knux_sky /
 *     sm_sjs_ability3), SOLO del Knuckles real, recarga 20s
 *     (knux_sky_cooldown). DOS VARIACIONES:
 *     * AÉREA (cast en el aire): se ELEVA hasta knux_sky_height (300u,
 *       tapa 1.5s / techo), queda clavado apuntando (hover estilo
 *       agarre de pared) y con la SEGUNDA pulsación de C (o al agotarse
 *       la ventana de 4s) se LANZA hacia donde mira a 1800 u/s. Al
 *       IMPACTAR (suelo/pared/2s): MEGA EXPLOSION estilo "detonador"
 *       (nativa, SIN tocar el VScript del Super Tank; particula
 *       gas_explosion_main doble + anillos de fuego) — SIN TEMBLOR
 *       (regla del owner R29: cero env_shake / cero ScreenShake).
 *     * TERRESTRE (cast en el suelo): lanza la ESFERA DE FUEGO (la
 *       esfera del escudo de Sally — atlas_break_ball — en pequeño y
 *       naranja translucido) como PROYECTIL (arco suave, 33 Hz): al
 *       IMPACTAR contra suelo/muro/infectado estalla con la misma
 *       explosión a escala reducida.
 *   - LA EXPLOSION (compartida): "El golpe podrá mandar a volar todo
 *     lo que no sea Especial (esto incluye a la witch). Los especiales
 *     también son mandados a volar (excepto al tank). aquí la distansia
 *     y la elevación varia dependiendo el especial (y el peso que tu
 *     puedas deducir.)":
 *     * COMUNES: empuje radial antes del dano (ragdolls volando, v45).
 *     * WITCH: WitchFlight_Launch (IA suspendida + dano de aterrizaje).
 *     * ESPECIALES: vuelo por PESO DEDUCIDO (Jockey 1.25, Hunter 1.15,
 *       Spitter 1.05, Smoker 1.00, Boomer 0.85, Charger 0.70) —
 *       distancia y elevación escaladas por clase. TANK: solo dano.
 *     * BOOMER: "no explotara de inmediato... será empujado y
 *       explotara tiempo después" — patron Amy v64: mecha 0.45s
 *       (knux_boomer_fuse) + pop real 9999 + frasco de bilis + onda
 *       a los comunes (T_KnuxBoomerBurst).
 *     * PROPS/AUTOS: "todo lo que tenga V en activo" — mismo empuje
 *       del sistema de Amy (sin conversión).
 *   - SEGURIDAD: tapas duras (elevación 1.5s, picada 2s, esfera 2.5s),
 *     EntRefs + DataPack con TIMER_DATA_HNDL_CLOSE (cero fugas),
 *     reset del estado en muerte/round/aggro/cambio de personaje (nadie
 *     flota en el aire para siempre), la esfera es autonoma (su vuelo
 *     sigue aunque el lanzador muera).
 *
 *  v61 CHANGES (FIX CRITICO - mismo crash que el martillo de Amy):
 *   - CAUSA RAÍZ: los 4 flings del modulo (puño, counter de vómito,
 *     counter de tank, hard-stop del charger) llamaban
 *     L4D2_CTerrorPlayer_Fling: SDKCall crudo a CTerrorPlayer::Fling
 *     del motor con anim 76 + incapTime 3.0 hardcodeados (contexto
 *     EXCLUSIVO del golpe de carga del Charger). Sobre un especial en
 *     estado transicional - o justo tambaleado por el SIStagger del
 *     MISMO frame, exactamente el patron de T_KnuxHardStopAttacker -
 *     es un crash documentado del motor ("you will probably crash the
 *     server", AlliedMods). FIX: lanzamiento manual (TeleportEntity,
 *     misma velocidad) + SIStagger_Auto donde faltaba. Mismo derribe
 *     visual, cero riesgo.
 *   - La witch golpeada por el puño ahora pasa por WitchFlight_CheckDead
 *     tras el dano (si muere en pleno vuelo, se restaura al instante).
 *
 *  v60 CHANGES (fix del bug "los stagger no se levantan"):
 *   - FIX: los staggers del puño / ground slam / counter (sobre bots
 *     SI: tank, smoker, charger, etc) los dejaban TIRADOS en el
 *     suelo para siempre: es un bug del estado del propio motor de
 *     L4D2 (OnStaggered no se limpia solo en bots; el usuario lo
 *     reporto y tiene razón, es código del motor). Ahora TODOS los
 *     staggers van por SI_Stagger.inc: auto L4D_CancelStagger a los
 *     1.8s (SI) / 3.0s (Tank) → se levantan garantizado.
 *
 *  v59 CHANGES (witch: poder levantarla y lanzarla como a los tanks):
 *   - FIX DEFINITIVO (witch): la witch es un NPC NextBot con IA propia:
 *     su locomoción reescribe su velocidad cada tick (por eso el fling
 *     v58 con STEP + impulso se anulaba al instante) y no tiene ni
 *     knockdown ni stagger. Ahora el puño y el ground slam usan
 *     WitchFlight_Launch (include Witch_Flight.inc): IA suspendida
 *     (MOVETYPE_NONE), vuelo integrado a mano (gravedad, colisión solo
 *     contra el mundo, deslizamiento en paredes) y restauración de su IA
 *     al aterrizar / a los 4s / si muere en vuelo. Dano de impacto en el
 *     aterrizaje proporcional a la velocidad de caida.
 *   - QoL (comunes): el puño ahora aplica el empuje ANTES del dano (el
 *     ragdoll hereda el impulso, igual que el fix de Amy v45): mueren
 *     volando igual que con el martillo.
 *   - Limpieza: eliminados Knux_FlingWitch/T_KnuxRestoreWitchMT
 *     (sustituidos por el sistema compartido Witch_Flight.inc).
 *
 *  v58 CHANGES (mantenidos):
 *   - FIX CRITICO (out-of-bounds): el marcado de golpeados del Dash usaba
 *     bool[65][2048] indexado con el índice de entidad; en servidores con
 *     más de 2048 edicts, los comunes/witch con índice >= 2048 provocaban
 *     "array index out-of-bounds" (error runtime que abortaba el barrido).
 *     Sustituido por un sistema de "epoch" global: misma semantica, sin
 *     bucle de reset de 2048 slots por golpe y ~500KB menos de memoria.
 *   - FIX (leak): el DataPack del T_KnuxSweep nunca se liberaba al terminar
 *     el timer (fuga en cada golpe). Ahora usa TIMER_DATA_HNDL_CLOSE.
 *   - FIX (interacción witch): Knux_FlingWitch dejaba a la witch con el
 *     movetype cambiado para siempre; ahora se captura el ORIGINAL y se
 *     restaura 0.8s después (fling con física normal + IA intacta).
 *   - FIX: se podía iniciar una nueva carga de Puño en mitad de un Meteor
 *     Smash (g_bKnuxSlamming) -> ahora se bloquea hasta aterrizar.
 *   - FIX: el barrido del Dash seguía activo 0.5s aunque se cambiara de
 *     personaje a mitad (golpeaba con poderes que ya no posee) -> stop.
 *   - QoL: el escaneo de proyectiles de Spitter corria CADA FRAME durante
 *     el Counter; ahora con throttle de 0.1s (misma respuesta, menos CPU).
 *   - QoL: el sprite del laser de los anillos se precachea una vez en
 *     OnMapStart en vez de llamar PrecacheModel en cada tick del barrido.
 *   - LIMPIEZA: eliminada la variable muerta g_iKnuxLastButtons (se
 *     escribía en 4 sitios y jamás se leia).
 *  FIX (v57, mantenido): detención del Charger con Delay-Timer (0.05s)
 *  y fricción absoluta instantanea en el sitio del impacto.
 * ======================================================
 */

#if defined _Knuckles_included
    #endinput
#endif
#define _Knuckles_included

// v63: sonda de versión (sm_sjsver del manager)
#define KNUCKLES_INC_VERSION "v77-OM"  // v77: EL UPPERCUT VUELA (pedido del owner 2026-10-13: "hay que aplicar el stun ragdoll a knuckles pues su counter es un uppercut hacia arriba") — su CONTRA ahora aplica STUN + RAGDOLL VOLADOR mayormente HACIA ARRIBA (Sonic_SpawnFlingRagdollEx del sonic v6.35): dano amplificado PRIMERO (OM_AbilityDamage hibrido x2 + % vs jefes del OM_Stun v2.2), letal = cadaver volando (copia Rouge generalizada), sobrevive = OM_Stun + doble vertical. Convars knu_counter_ragdoll (3.0s) / knu_counter_fling (700 u/s). Tank: uppercut también (con su desarme de 5s intacto). + TODO el dano de sus habilidades (puño/slam/meteoro/counter) amplificado. v76: PATCH DE BALANCE — enfriamientos -4s (puño 11 / counter 16 / meteoro 16) (manager 3.77.50); v75: LA POSTURA LLAMA AL VSCRIPT DIRECTO (patron supertank SetAmyMode): Knux_ParryNotifyNut por RunScriptCode a la entrada ChCh_KnxNotify del chch_parrying.nut v2.8 — fuera el puente de consola knxparry_state (manager 3.77.44)

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
#if !defined _si_stagger_included
    #include <SI_Stagger>
#endif

#if !defined KNUCKLES_INDEX
    #define KNUCKLES_INDEX 2
#endif

// =======================
// Constantes y Audio
// =======================
#define KNUX_SOUND_CHARGE_1     "player/survivor/hit/crowbar_swing_miss1.wav"
#define KNUX_SOUND_PUNCH        "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_1.wav"
#define KNUX_SOUND_SLAM         "player/tank/hit/hulk_punch_1.wav"
#define KNUX_SOUND_COUNTER      "weapons/knife/knife_deploy.wav"
#define KNUX_SOUND_COUNTER_HIT  "weapons/pan/pan_hit_infected1.wav" 
#define KNUX_SOUND_SMASH_HIT    "player/tank/hit/hulk_punch_2.wav"

#define KNUX_MAX_WALL_CHAINS    3

// =======================
// v63 (R30): H3 METEOR STRIKE + PROPS
// =======================
#define KNUX_SKY_NONE       0
#define KNUX_SKY_ASCENT     1   // variación aérea fase 1: elevación
#define KNUX_SKY_AIM        2   // variación aérea fase 2: apuntado (hover)
#define KNUX_SKY_DIVE       3   // variación aérea fase 3: picada

#define KNUX_SOUND_SKYBOOM      "ambient/explosions/explode_1.wav"  // el mismo boom de Amy (probado)
#define KNUX_SKY_MAX_ASCENT     1.5     // tapa dura de la elevación (segundos)
#define KNUX_SKY_MAX_DIVE       3.0     // v64: tapa dura de la picada (el arco con gravedad vive más)
#define KNUX_SKY_LIFT_SI        450.0   // elevación base de especiales (x peso)
#define KNUX_SKY_LIFT_COMMON    550.0   // elevación de comunes
#define KNUX_SKY_LIFT_WITCH     800.0   // elevación de la witch (vuela alto)
#define KNUX_BOOMER_PUSH_RAD    250.0   // onda del estallido del boomer (patron Amy)
#define KNUX_SKY_BALL_MDL       "models/props_unique/airport/atlas_break_ball.mdl"
#define KNUX_SKY_BALL_SCALE     0.35    // la esfera de Sally, en pequeño y naranja
#define KNUX_SKY_BALL_TICK      0.03    // integración del proyectil (~33 Hz)
#define KNUX_SKY_BALL_LIFE      2.5     // vida máxima antes de detonar en el aire
#define KNUX_SKY_BALL_GRAV      360.0   // arco suave (es energía, no una piedra)
// v64: KNUX_SKY_BALL_MINUP y KNUX_SKY_DIVE_MINUP ELIMINADOS: forzaban
// +150 vertical y la picada/esfera salian hacia arriba (nunca hacia
// donde apuntabas). El arco lo hace la gravedad del motor.
#define KNUX_PROPS_PER_HIT      24      // tope de props por golpe/scan
#define KNUX_PROP_WAKE_FORCE    200.0   // empujon físico del golpe real (u/s, x masa — Amy v75)
#define KNUX_PROP_WAKE_DMG      10.0    // dano del golpe real (mismo default que Amy)
#define KNUX_PROP_WAKE_LIFT     0.75    // lift del golpe real (75% — receta Amy)
#define KNUX_PROP_BLAST_RAD     130.0   // radio base del despertador (Amy v76)

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif

// =======================
// Variables Globales
// =======================
bool  g_bKnuxGliding[MAXPLAYERS + 1];
bool  g_bKnuxClinging[MAXPLAYERS + 1];
int   g_iKnuxWallChains[MAXPLAYERS + 1];

bool  g_bKnuxCharging[MAXPLAYERS + 1]; 
bool  g_bKnuxSlamming[MAXPLAYERS + 1]; 
float g_fKnuxPunchCooldown[MAXPLAYERS + 1];

bool  g_bKnuxCountering[MAXPLAYERS + 1];
float g_fKnuxCounterEndTime[MAXPLAYERS + 1];
float g_fKnuxCounterCooldown[MAXPLAYERS + 1];
// v73-OM: throttle compartido del feedback de bloqueo (0.4 s): el del
// .nut (knx_parry_blocked) y el de los básicos de especiales/witch
float g_fKnuxBlockFxNext[MAXPLAYERS + 1];
// v66-OM: niveles de carga del puño (1/2/3) + el poder fijado al soltar
int   g_iKnuxChargeLevel[MAXPLAYERS + 1];
float g_fKnuxChargeStart[MAXPLAYERS + 1];
int   g_iKnuxPunchPower[MAXPLAYERS + 1];    // nivel con el que salió el golpe/slam
float g_fKnuxNextOrbT[MAXPLAYERS + 1];      // orbes de fuego del nivel 3 (20 Hz)
// v70-OM: g_iKnuxOrbSprite (glow01 del flash del parry) se elimina
// junto al parry — las orbes de fuego usan g_iKnuxFlameSprite
int   g_iKnuxOrbEnt[MAXPLAYERS + 1][2];     // v66: las 2 orbes persistentes (refs)
// v67-OM: FUEGO REAL en los puños (lua l.1123-1190: espirales
// Knuckles_FireOrb de 2 vueltas + firering al llenar — material
// om_knux_flame, el blaze flame del pack OM)
int   g_iKnuxFlameSprite = 0;                 // om_knux_flame.vmt (0 = no montado -> glow01)
float g_fKnuxFlameStart[MAXPLAYERS + 1];      // inicio del ciclo de espiral
float g_fKnuxFlameAng[MAXPLAYERS + 1][2];     // angulo inicial por mano (lua math.Rand)
int   g_iKnuxFlameDir[MAXPLAYERS + 1][2];     // sentido de giro por mano (lua random)
float g_fKnuxFlamePrev[MAXPLAYERS + 1][2][3]; // punto anterior del beam (trail)
bool  g_bKnuxFlameHasPrev[MAXPLAYERS + 1][2]; // hay punto previo válido
float g_fKnuxDisarmTank[MAXPLAYERS + 1]; 

float g_fKnuxExtendedImmunity[MAXPLAYERS + 1];

// Manejo de físicas en pared
float g_fKnuxNextClingTime[MAXPLAYERS + 1];
// v67-OM: ORIENTACION DEL AGARRE (lua l.759-792): el avatar mira a la
// NORMAL de la pared (lado contrario, espalda contra la pared) y el
// salto de salida sale por la normal (l.700), no por la cámara
float g_fKnuxLatchNormal[MAXPLAYERS + 1][3];
float g_fKnuxLatchYaw[MAXPLAYERS + 1];

// v58: Prevención de impactos múltiples por un solo Dash.
// Sistema de "epoch": cada golpe incrementa la epoch global; una entidad
// queda marcada con la epoch del golpe que la alcanzo. Sustituye al viejo
// bool[65][2048] (532KB de memoria estática + riesgo de out-of-bounds con
// edicts >= 2048 + bucle de reset de 2048 iteraciones por golpe).
int   g_iKnuxDashEpoch = 1;
int   g_iKnuxHitMark[2048];

// v58: sprite cacheado de los beam rings (carga/counter/slam) — v70:
// el throttle del escaneo de proyectiles se fue con el parry delegado
int   g_iKnuxBeamSprite = -1;

// v63 (R30): H3 METEOR STRIKE — maquina de estados por jugador
int    g_iKnuxSkyState[MAXPLAYERS + 1];      // 0 none / 1 ascent / 2 aim / 3 dive
float  g_fKnuxSkyCooldown[MAXPLAYERS + 1];
float  g_fKnuxSkyStateStart[MAXPLAYERS + 1]; // inicio de la fase en curso
float  g_fKnuxSkyCastZ[MAXPLAYERS + 1];      // Z del punto de cast (base de la elevación)
float  g_fKnuxSkyHoverEnd[MAXPLAYERS + 1];   // fin de la ventana de apuntado
float  g_fKnuxSkyDiveVel[MAXPLAYERS + 1][3]; // velocidad de picada FIJADA al lanzarse
float  g_fKnuxSkyHudT[MAXPLAYERS + 1];       // throttle del HUD

// v62 (petición usuario): STAGGER AL ATERRIZAR del Meteor Smash.
// El smash ahora LEVANTA a los oponentes (especiales y witches):
// en vez del stagger inmediato de antes, los especiales salen
// disparados hacia arriba y el SIStagger se aplica CUANDO TOCAN
// SUELO (aterrizan golpeados). Slots por userid + timer 0.1s.
#define KNUX_LANDSTAGGER_SLOTS 16
#define KNUX_LANDSTAGGER_TIMEOUT 3.0
#define KNUX_LANDSTAGGER_MIN_AIR 0.35
int   g_iKnuxLandVictim[KNUX_LANDSTAGGER_SLOTS];   // userid del lanzado
int   g_iKnuxLandAttacker[KNUX_LANDSTAGGER_SLOTS]; // userid de Knuckles
float g_fKnuxLandDeadline[KNUX_LANDSTAGGER_SLOTS];
float g_fKnuxLandMinAir[KNUX_LANDSTAGGER_SLOTS];
bool  g_bKnuxLandTimerOn = false;

ConVar g_cvKnuxPunchCD, g_cvKnuxCounterCD;
ConVar g_cvKnuxCounterRagdoll, g_cvKnuxCounterFling;   // v77: el uppercut vuela
ConVar g_cvKnuxChargeT1, g_cvKnuxChargeT2, g_cvKnuxPunchCDCancel;
// v70-OM: las 4 convars del parry de proyectiles (knux_parry_projectiles/
// spit/rocks/radius) SE ELIMINAN — el parry lo ejecuta el VScript
ConVar g_cvKnuxFistFire;
ConVar g_cvKnuxGlideSpeed, g_cvKnuxGlideGravity;
ConVar g_cvKnuxDamageReduc, g_cvKnuxSlamDmg, g_cvKnuxSlamRadius;
ConVar g_cvKnuxCounterDuration;

// v63 (R30): H3 Meteoro + empuje de props
ConVar g_cvKnuxSkyCD, g_cvKnuxSkyHeight, g_cvKnuxSkyAscend, g_cvKnuxSkyHover;
ConVar g_cvKnuxSkyDiveSpd, g_cvKnuxSkyRadius, g_cvKnuxSkyDamage;
ConVar g_cvKnuxSkySiForce, g_cvKnuxSkyCommonForce, g_cvKnuxSkyWitchForce;
ConVar g_cvKnuxSkyBallSpeed, g_cvKnuxSkyBallRadius, g_cvKnuxSkyBallDamage;
ConVar g_cvKnuxPropForce, g_cvKnuxPropBlast, g_cvKnuxBoomerFuse;

// =====================================================================
// v65-OM: AVATAR KNUCKLES (patron Metal v5.4 / sonic v6.30 / Tails)
// =====================================================================
#define KNUX_OM_MODEL       "models/Noodles/OM/knuckles.mdl"
#define KNUX_AVATAR_NAME    "knuckles_avatar_om"

// FSM de animación — las 15 secuencias del knuckles.mdl que usa el lua
// GMod (anims.default + ShouldAlternate + los PillAnim one-shots)
#define KNUX_ST_IDLE         0
#define KNUX_ST_WALK         1
#define KNUX_ST_RUN          2
#define KNUX_ST_JUMP         3
#define KNUX_ST_FALL         4
#define KNUX_ST_GLIDE        5    // loop: planeo (ShouldAlternate.fall -> 'glide')
#define KNUX_ST_LATCH        6    // loop: agarrado de pared / hover del Meteoro
#define KNUX_ST_PUNCH        7    // one-shot: PunchAnim (dash punch, lua l.326)
#define KNUX_ST_SMASH        8    // one-shot: GroundSmash (aterrizaje, l.1073)
#define KNUX_ST_ATTACK       9    // one-shot: attack (lanzamiento aéreo, l.1781)
#define KNUX_ST_FALLATK     10    // loop: FallAttack (picada smash + Meteoro)
#define KNUX_ST_LATCHOFF    11    // one-shot: LatchOff (salida de pared, l.1585)
#define KNUX_ST_IDLE_LOW    12    // idle_lowhealth (HP <= 60)
#define KNUX_ST_WALK_LOW    13    // walk_lowhealth
#define KNUX_ST_RUN_LOW     14    // run_lowhealth
// v66-OM: los 2 gestures del BLOQUEO del lua (AddGesture) como one-shots
#define KNUX_ST_COUNTER     15    // one-shot: counter (PREPARACION, gesture RANGE_ATTACK1 l.1618)
#define KNUX_ST_COUNTER_HIT 16    // one-shot: counter_hit (GOLPE del bloqueo, gesture RANGE_ATTACK2 l.590)
#define KNUX_ANIM_COUNT     17

// lock de los one-shots mientras corren (segundos)
#define KNUX_LOCK_PUNCH      0.55
#define KNUX_LOCK_SMASH      0.90
#define KNUX_LOCK_ATTACK     0.50
#define KNUX_LOCK_LATCHOFF   0.45
#define KNUX_LOCK_COUNTER     1.25   // v66: fade del gesture de preparación (l.1637)
#define KNUX_LOCK_COUNTER_HIT 0.55   // v66: fade del gesture de golpe (l.609)

// v66-OM: las secuencias counter/counter_hit del knuckles.mdl miran a
// la DERECHA (aviso del owner) — mientras corre el one-shot el avatar
// gira +90 para que la pose mire al FRENTE. Si saliera girado al otro
// lado: cambiar a -90.0 (1 línea, receta en CAMBIOS_37731).
#define KNUX_COUNTER_YAW_FIX  90.0

// v66-OM: ORBES DE FUEGO del preview del nivel 3 (lua l.1123-1149:
// Knuckles_FireOrb en ambas manos — glow01 naranja a 20 Hz)
#define KNUX_ORB_FORWARD   14.0
#define KNUX_ORB_SIDE      11.0
#define KNUX_ORB_HEIGHT    46.0
#define KNUX_ORB_SIZE       8.0
#define KNUX_ORB_LIFE      0.08
#define KNUX_ORB_EVERY     0.05

// v67-OM: FUEGO de los puños — la espiral EXACTA del Knuckles_FireOrb
// del effects lua (l.319-484): radio 35 -> 0, 2 vueltas, vida 0.9s, onda
// sen(cos)*18 Hz de amplitud 4; el beam TE lleva el trail (el GMod
// encadena 25 segmentos, l.372-407) y el color fuego 255/120+i*5/30
#define KNUX_FLAME_CYCLE     0.9
#define KNUX_FLAME_RADIUS    35.0
#define KNUX_FLAME_FLOOR_R    3.0
#define KNUX_FLAME_ROTATIONS 2.0
#define KNUX_FLAME_WAVEHZ   18.0
#define KNUX_FLAME_WAVEAMP   4.0
#define KNUX_FLAME_BEAMLIFE  0.30
#define KNUX_FLAME_BEAMW     9.0

// v70-OM: los 10 defines KNUX_PARRY_* se eliminan con todo el parry
// de proyectiles del lado del manager (delegado al chch_parrying.nut)

// tintes del knuckles_ui_om.lua — fade simétrico EXACTO del UI:
// duration = 0.5*0.5 = 0.25s con fade = 0.25*0.5 = 0.125s por lado
#define KNUX_TINT_DUR        0.25
#define KNUX_TINT_FADE       0.125
#define KNUX_TINT_PULSE_EVERY 0.6   // retrig del pulso ROJO mientras carga
#define KNUX_SND_LEVEL       87     // AdvancedPillSound del lua (todas las del mod van a 87)

ConVar g_cvKnuxAvatar;                          // knux_avatar (default 1)
bool   g_bKnuxModelOK = false;                  // knuckles.mdl en el VPK om_
int    g_iKnuxAvatar[MAXPLAYERS + 1];           // EntRef copia R (0 = sin avatar)
int    g_iKnuxAvatarL[MAXPLAYERS + 1];          // EntRef copia L (solo el dueño)
int    g_iKnuxBodyRender[MAXPLAYERS + 1];       // RenderMode original del cuerpo
int    g_iKnuxAnimState[MAXPLAYERS + 1];        // estado actual de la FSM
float  g_fKnuxAnimLock[MAXPLAYERS + 1];         // lock de los one-shots
float  g_fKnuxBodyYaw[MAXPLAYERS + 1];          // yaw suavizado del cuerpo
float  g_fKnuxYawLastT[MAXPLAYERS + 1];         // dt del giro suave
float  g_fKnuxSmLoc[MAXPLAYERS + 1][3];         // smoothing angulos copia R
float  g_fKnuxSmLocL[MAXPLAYERS + 1][3];        // smoothing angulos copia L
bool   g_bKnuxSmSnap[MAXPLAYERS + 1];           // snap al nacer (write seco)
float  g_fKnuxJumpStart[MAXPLAYERS + 1];        // t0 del jump (ventana v5.2)
float  g_fKnuxDeathHideUntil[MAXPLAYERS + 1];   // ventana anti-corpse (2s)
float  g_vKnuxDeathOrigin[MAXPLAYERS + 1][3];   // origen de la muerte (200u)

// tintes del avatar (pulso activo + postura)
float  g_fKnuxTintEnd[MAXPLAYERS + 1];          // fin del pulso (0 = ninguno)
int    g_iKnuxTintR[MAXPLAYERS + 1];
int    g_iKnuxTintG[MAXPLAYERS + 1];
int    g_iKnuxTintB[MAXPLAYERS + 1];
float  g_fKnuxNextPulse[MAXPLAYERS + 1];        // próximo pulso de carga

// sonidos auténticos del VPK om_ (gates individuales, fallback stock)
bool   g_bKnuxSndPunchStart, g_bKnuxSndSwing, g_bKnuxSndPunchStun;
bool   g_bKnuxSndCounter, g_bKnuxSndBounce, g_bKnuxSndLatch, g_bKnuxSndCancel;
bool   g_bKnuxSndPhase1, g_bKnuxSndPhase3, g_bKnuxSndSlam;

// tabla de secuencias (índices = KNUX_ST_*)
static const char g_sKnuxAnimSeq[KNUX_ANIM_COUNT][20] = {
    "idle", "walk", "run", "jump", "fall",
    "glide", "latch",
    "PunchAnim", "GroundSmash", "attack", "FallAttack", "LatchOff",
    "idle_lowhealth", "walk_lowhealth", "run_lowhealth",
    "counter", "counter_hit"    // v66: los 2 gestures del bloqueo (lua l.1618/l.590)
};

#define Knux_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

public void Knuckles_OnPluginStart()
{
    g_cvKnuxPunchCD         = CreateConVar("knux_punch_cooldown", "11.0", "v76: Cooldown del Puño [15 -> 11: -4s pedido del owner]");
    g_cvKnuxCounterCD       = CreateConVar("knux_counter_cooldown", "16.0", "v76: Cooldown del Counter [20 -> 16: -4s pedido del owner]");
    g_cvKnuxCounterDuration = CreateConVar("knux_counter_duration", "8.0", "Duración de la Postura Defensiva");
    g_cvKnuxCounterRagdoll  = CreateConVar("knu_counter_ragdoll", "3.0", "v77: segundos de STUN+RAGDOLL del UPPERCUT de la contra (0 = desactivado: el stagger plano de antes)", _, true, 0.0, true, 12.0);
    g_cvKnuxCounterFling    = CreateConVar("knu_counter_fling", "700", "v77: velocidad (u/s) del vuelo del UPPERCUT (mayormente hacia ARRIBA + separación)", _, true, 0.0, true, 2000.0);

    // v66-OM: carga de 3 niveles del puño (defaults del lua GMod:
    // chargetime1 4.5 / chargetime2 9 / cooldown_cancel 5)
    g_cvKnuxChargeT1       = CreateConVar("knux_charge_t1", "4.5", "v66: segundos de carga para el NIVEL 2 (lua 4.5)");
    g_cvKnuxChargeT2       = CreateConVar("knux_charge_t2", "9.0", "v66: segundos de carga para el NIVEL 3 (lua 9.0)");
    g_cvKnuxPunchCDCancel  = CreateConVar("knux_punch_cd_cancel", "5.0", "v66: cooldown al CANCELAR la carga (lua cooldown_cancel 5)");
    // v70-OM: el parry de proyectiles lo ejecuta el VScript (chch_parrying.nut
    // v2.2 avisado por el Parry.smx v2.1) — el manager ya no toca proyectiles
    // v67-OM: fuego real en los puños de la fase 3 (espiral + nucleo + firering)
    g_cvKnuxFistFire       = CreateConVar("knux_fist_fire", "1", "v67: fuego en los puños de la carga nivel 3 (1/0)");
    
    g_cvKnuxGlideSpeed    = CreateConVar("knux_glide_speed", "450.0", "Velocidad horizontal al planear");
    g_cvKnuxGlideGravity  = CreateConVar("knux_glide_gravity", "0.4", "Gravedad al planear");
    g_cvKnuxDamageReduc   = CreateConVar("knux_damage_reduction", "0.25", "Daño recibido al cargar");
    
    g_cvKnuxSlamDmg       = CreateConVar("knux_slam_damage", "500.0", "Daño del Ground Smash (+75% Buffed)");
    g_cvKnuxSlamRadius    = CreateConVar("knux_slam_radius", "450.0", "Radio del Ground Smash");

    RegConsoleCmd("sm_knux_punch", Command_KnuxPunch);
    RegConsoleCmd("sm_knux_counter", Command_KnuxCounter);
    // v73-OM: el chch_parrying.nut v2.5 avisa AQUÍ cada bloqueo de la
    // ventana (roca/granada/saliva/enemigo) -> anim de bloqueo del avatar
    RegServerCmd("knx_parry_blocked", Knux_CmdParryBlocked, "v73: el VScript bloqueo algo en la ventana de Knuckles (dispara el gesto de bloqueo del avatar)");

    // v63 (R30): H3 METEOR STRIKE (tecla C) + empuje de props
    // (mismo sistema que Amy SIN conversión: solo objetos con V/VPHYSICS)
    g_cvKnuxSkyCD          = CreateConVar("knux_sky_cooldown", "16.0", "v76: recarga de la H3 Meteoro [20 -> 16: -4s pedido del owner] (ambas variaciones)");
    g_cvKnuxSkyHeight      = CreateConVar("knux_sky_height", "300.0", "v64: altura de elevación de la variación aérea");
    g_cvKnuxSkyAscend      = CreateConVar("knux_sky_ascend", "420.0", "v64: velocidad de elevación");
    g_cvKnuxSkyHover       = CreateConVar("knux_sky_hover", "4.0", "v64: ventana de apuntado en el aire (luego auto-lanzamiento)");
    g_cvKnuxSkyDiveSpd     = CreateConVar("knux_sky_dive_speed", "1800.0", "v64: velocidad de la picada");
    g_cvKnuxSkyRadius      = CreateConVar("knux_sky_radius", "550.0", "v63: radio de la mega explosión (variación aérea)");
    g_cvKnuxSkyDamage      = CreateConVar("knux_sky_damage", "350.0", "v63: dano de la mega explosión");
    g_cvKnuxSkySiForce     = CreateConVar("knux_sky_si_force", "900.0", "v63: empuje base de especiales (x peso deducido)");
    g_cvKnuxSkyCommonForce = CreateConVar("knux_sky_common_force", "800.0", "v63: empuje de comunes");
    g_cvKnuxSkyWitchForce  = CreateConVar("knux_sky_witch_force", "650.0", "v63: empuje horizontal de la witch (vertical fijo)");
    g_cvKnuxSkyBallSpeed   = CreateConVar("knux_sky_ball_speed", "1400.0", "v64: velocidad de la esfera (variación terrestre)");
    g_cvKnuxSkyBallRadius  = CreateConVar("knux_sky_ball_radius", "400.0", "v63: radio de la explosión de la esfera");
    g_cvKnuxSkyBallDamage  = CreateConVar("knux_sky_ball_damage", "250.0", "v63: dano de la explosión de la esfera");
    g_cvKnuxPropForce      = CreateConVar("knux_prop_force", "700.0", "v63: empuje de props/autos del puño y el slam (receta Amy)");
    g_cvKnuxPropBlast      = CreateConVar("knux_prop_blast", "300.0", "v63: despertador env_physexplosion del empuje de props (0 = off)");
    g_cvKnuxBoomerFuse     = CreateConVar("knux_boomer_fuse", "0.45", "v63: mecha del boomer lanzado (patron Amy v64)");
    RegConsoleCmd("sm_knux_sky", Command_KnuxSkyStrike);

    HookEvent("player_spawn", Knux_Event_PlayerSpawn);
    HookEvent("player_death", Knux_Event_PlayerDeath);
    HookEvent("round_end", Knux_Event_RoundEnd);
    // v70-OM: el hook del spit_burst se va con todo el parry de proyectiles
    // (delegado al VScript — cero contacto del manager con proyectiles)

    // v65-OM: avatar — convar + FSM a 10 Hz (patron T_MetalAvatarThink).
    // La muerte del avatar (ragdoll + anti-corpse) vive en el hook
    // player_death POST que este modulo YA tiene (Knux_Event_PlayerDeath).
    g_cvKnuxAvatar = CreateConVar("knux_avatar", "1", "Knuckles OM: avatar espejo (knuckles.mdl del VPK de recursos, patron Tails/Sonic/Amy/Metal)", _, true, 0.0, true, 1.0);
    CreateTimer(0.1, T_KnuxAvatarThink, _, TIMER_REPEAT);
    
    // v3.75: AutoExecConfig eliminado - config ÚNICA del suite (Sonic_Suite.cfg, auto-guardada; ver manager). El archivo viejo queda muerto.

    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i)) {
            Knux_ResetState(i);
            SDKUnhook(i, SDKHook_OnTakeDamage, Knux_OnTakeDamage);
            SDKHook(i, SDKHook_OnTakeDamage, Knux_OnTakeDamage);
            SDKUnhook(i, SDKHook_PreThink, Knux_PreThink);
            SDKHook(i, SDKHook_PreThink, Knux_PreThink);
            SDKUnhook(i, SDKHook_Touch, Knux_OnTouch);
            SDKHook(i, SDKHook_Touch, Knux_OnTouch);
        }
    }
}

public void Knuckles_OnMapStart()
{
    PrecacheSound(KNUX_SOUND_CHARGE_1, true);
    PrecacheSound(KNUX_SOUND_PUNCH, true);
    PrecacheSound(KNUX_SOUND_SLAM, true);
    PrecacheSound(KNUX_SOUND_COUNTER, true);
    PrecacheSound(KNUX_SOUND_COUNTER_HIT, true);
    PrecacheSound(KNUX_SOUND_SMASH_HIT, true);
    PrecacheParticle("gas_explosion_main"); 

    // v58: cachear el sprite del laser de los anillos VFX (antes se llamaba
    // PrecacheModel en cada tick del barrido del Dash)
    g_iKnuxBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");

    // v63 (R30): sonidos/particulas del METEORO + esfera + boomer diferido
    PrecacheSound(KNUX_SOUND_SKYBOOM, true);
    // v67-OM: boom del parry estilo ChCh (nut: ambient/explosions/explode_1-3)
    PrecacheSound("ambient/explosions/explode_1.wav", true);
    PrecacheSound("ambient/explosions/explode_2.wav", true);
    PrecacheSound("ambient/explosions/explode_3.wav", true);
    Knux_PrecacheParticle("boomer_explode_Boomer");   // burst del boomer (patron Amy)
    Knux_PrecacheParticle("gas_explosion_main");      // mega explosión (no-op si ya esta)
    PrecacheModel(KNUX_SKY_BALL_MDL);                 // esfera del escudo de Sally

    // v65-OM: SONIDOS AUTÉNTICOS del VPK om_ (AdvancedPillSound del lua,
    // todos a soundLevel 87 — el port iba al default 75). Gates
    // individuales con fallback stock (receta Metal v4.1/v5.2): sin VPK
    // TODO cae a los sonidos de siempre, cero dependencia.
    g_bKnuxSndPunchStart = PrecacheSound("om/knuckles/punchstart.wav", true);      // carga del puño
    g_bKnuxSndSwing      = PrecacheSound("om/knuckles/swing.wav", true);           // lanzamiento (aéreo l.1794)
    g_bKnuxSndPunchStun  = PrecacheSound("om/knuckles/punchstun.wav", true);      // impacto que aturde
    g_bKnuxSndCounter    = PrecacheSound("om/knuckles/counter.wav", true);        // activación de la postura
    g_bKnuxSndBounce     = PrecacheSound("om/knuckles/CounterBounce.wav", true);  // rebote de bloqueo
    g_bKnuxSndLatch      = PrecacheSound("om/knuckles/Latch.wav", true);          // agarrarse de pared
    g_bKnuxSndCancel     = PrecacheSound("om/knuckles/KnucklesCancel.wav", true); // cancelar carga
    // v66-OM: sonidos de los NIVELES de carga + el Slam del CLICK
    // (phase1 l.1114 / phase3 l.1159 / Slam1-4 l.1759 — mismos gates)
    g_bKnuxSndPhase1     = PrecacheSound("om/knuckles/phase1.wav", true);        // nivel 2
    g_bKnuxSndPhase3     = PrecacheSound("om/knuckles/phase3.wav", true);        // nivel 3
    g_bKnuxSndSlam       = PrecacheSound("om/knuckles/Slam1.wav", true);         // click (Slam1-4)
    if (g_bKnuxSndSlam)
    {
        PrecacheSound("om/knuckles/Slam2.wav", true);
        PrecacheSound("om/knuckles/Slam3.wav", true);
        PrecacheSound("om/knuckles/Slam4.wav", true);
    }
    // v70-OM: el precache del glow01 (flash del parry) se va con el parry

    // v67-OM: material de FUEGO de los puños (blaze flame del pack OM,
    // renombrado a om_knux_flame) — gate como om_bluesmoke: si el
    // archivo no está montado PrecacheModel da 0 y todo cae al glow01
    // naranja de la v66 (nada se rompe)
    g_iKnuxFlameSprite = PrecacheModel("materials/icons/om_knux_flame.vmt", true);
    AddFileToDownloadsTable("materials/icons/om_knux_flame.vmt");
    AddFileToDownloadsTable("materials/icons/om_knux_flame.vtf");
    if (g_bKnuxSndPunchStart) AddFileToDownloadsTable("sound/om/knuckles/punchstart.wav");
    if (g_bKnuxSndSwing)      AddFileToDownloadsTable("sound/om/knuckles/swing.wav");
    if (g_bKnuxSndPunchStun)  AddFileToDownloadsTable("sound/om/knuckles/punchstun.wav");
    if (g_bKnuxSndCounter)    AddFileToDownloadsTable("sound/om/knuckles/counter.wav");
    if (g_bKnuxSndBounce)     AddFileToDownloadsTable("sound/om/knuckles/CounterBounce.wav");
    if (g_bKnuxSndLatch)      AddFileToDownloadsTable("sound/om/knuckles/Latch.wav");
    if (g_bKnuxSndCancel)     AddFileToDownloadsTable("sound/om/knuckles/KnucklesCancel.wav");
    if (g_bKnuxSndPhase1)     AddFileToDownloadsTable("sound/om/knuckles/phase1.wav");
    if (g_bKnuxSndPhase3)     AddFileToDownloadsTable("sound/om/knuckles/phase3.wav");
    if (g_bKnuxSndSlam)
    {
        AddFileToDownloadsTable("sound/om/knuckles/Slam1.wav");
        AddFileToDownloadsTable("sound/om/knuckles/Slam2.wav");
        AddFileToDownloadsTable("sound/om/knuckles/Slam3.wav");
        AddFileToDownloadsTable("sound/om/knuckles/Slam4.wav");
    }

    // v65-OM: gate del MODELO del avatar (PrecacheModel devuelve 0 si el
    // .mdl no está en el VPK montado; con 0 el avatar jamás se monta y
    // todo lo demas del Knuckles sigue igual — receta g_bMetalModelOK)
    g_bKnuxModelOK = view_as<bool>(PrecacheModel(KNUX_OM_MODEL, true));

    for (int i = 1; i <= MaxClients; i++) Knux_ResetState(i);
}

public void Knuckles_OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, Knux_OnTakeDamage);
    SDKHook(client, SDKHook_PreThink, Knux_PreThink);
    SDKHook(client, SDKHook_Touch, Knux_OnTouch);
}

public void Knux_Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && IsClientInGame(client)) {
        Knux_ResetState(client);
        SDKUnhook(client, SDKHook_OnTakeDamage, Knux_OnTakeDamage);
        SDKHook(client, SDKHook_OnTakeDamage, Knux_OnTakeDamage);

        // v65-OM: montar el avatar ya (patron Metal/Sonic: la FSM de 10 Hz
        // lo re-monta sola si el orden de eventos fue raro)
        if (g_cvKnuxAvatar != null && g_cvKnuxAvatar.BoolValue && g_bKnuxModelOK
            && g_iPlayerCharIdx[client] == KNUCKLES_INDEX
            && GetClientTeam(client) == 2 && IsPlayerAlive(client))
        {
            Knux_CreateAvatar(client);
        }
    }
}

// v65-OM: MUERTE REAL del Knuckles (hook player_death POST propio — ya
// registrado desde siempre). El avatar se va con RAGDOLL + ventana
// anti-corpse (receta Metal v5.0 / Sonic v3.76.2: en POST el cuerpo ya se
// devolvio y el corpse del survivor que spawnea el motor justo después
// lo filtra la ventana de 2s/200u). SIN avatar: vanilla, igual que antes.
public void Knux_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients) return;

    if (g_iKnuxAvatar[client] != 0)
    {
        if (IsClientInGame(client))
        {
            GetClientAbsOrigin(client, g_vKnuxDeathOrigin[client]);
            g_fKnuxDeathHideUntil[client] = GetEngineTime() + 2.0;
            Knux_SpawnDeathRagdoll(client);
        }
        Knux_KillAvatar(client);
    }

    Knux_ResetState(client);
}

// v65-OM: CAMBIO DE PERSONAJE / DESCONEXION (la invoca el manager en
// CleanupCharModuleState — patron Metal_OnPlayerDeath): estado fuera +
// avatar fuera SIN ragdoll (el jugador no murió; la muerte real pasa por
// Knux_Event_PlayerDeath de arriba).
public void Knuckles_OnPlayerDeath(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return;
    Knux_ResetState(client);
    Knux_KillAvatar(client);
}

public void Knux_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) { for (int i = 1; i <= MaxClients; i++) Knux_ResetState(i); }

void Knux_ResetState(int client)
{
    g_bKnuxGliding[client] = false;
    g_bKnuxClinging[client] = false;
    g_iKnuxWallChains[client] = 0;
    g_bKnuxCharging[client] = false;
    g_bKnuxSlamming[client] = false;
    // v73/v75-OM: si la postura estaba activa, su ventana del parry
    // se cierra con ella (muerte / fin de ronda / reset de estado).
    // v75: DIRECTO al .nut (patron supertank) — nada de consola.
    if (g_bKnuxCountering[client])
        Knux_ParryNotifyNut(client, false, 0.0);
    g_bKnuxCountering[client] = false;
    g_fKnuxDisarmTank[client] = 0.0;
    g_fKnuxExtendedImmunity[client] = 0.0;
    g_fKnuxNextClingTime[client] = 0.0;
    // v66-OM: niveles de carga del puño fuera + orbes apagadas
    Knux_KillFireOrbs(client);
    g_iKnuxChargeLevel[client] = 0;
    g_iKnuxPunchPower[client] = 0;
    g_fKnuxNextOrbT[client] = 0.0;
    // v67-OM: orientación del agarre + espiral de fuego fresca
    g_fKnuxLatchYaw[client] = 0.0;
    g_fKnuxLatchNormal[client][0] = 0.0;
    g_fKnuxLatchNormal[client][1] = 0.0;
    g_fKnuxLatchNormal[client][2] = 0.0;

    // v63 (R30): cortar la maquina del METEORO (el movetype y el resto del
    // estado físico se restauran abajo; la esfera ya lanzada es AUTONOMA y
    // sigue su vuelo — no se le ata el estado del lanzador)
    g_iKnuxSkyState[client] = KNUX_SKY_NONE;
    g_fKnuxSkyStateStart[client] = 0.0;
    g_fKnuxSkyHudT[client] = 0.0;

    // v65-OM: tintes del avatar fuera (el avatar en si NO se toca aquí:
    // su ciclo de vida lo manejan los eventos de spawn/muerte y la FSM
    // de 10 Hz — el cambio de personaje pasa por Knuckles_OnPlayerDeath)
    g_fKnuxTintEnd[client] = 0.0;
    g_fKnuxNextPulse[client] = 0.0;
    g_fKnuxAnimLock[client] = 0.0;
    g_iKnuxAnimState[client] = -1;
    
    if (IsClientInGame(client)) {
        if (!GetEntProp(client, Prop_Send, "m_isIncapacitated")) SetEntityMoveType(client, MOVETYPE_WALK);
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntityRenderColor(client, 255, 255, 255, 255);
        SetEntityGravity(client, 1.0);
        SetEntProp(client, Prop_Data, "m_takedamage", 2); 
    }
}

// INHABILITAR HABILIDADES DE LOS INFECTADOS ESPECIALES
void Knux_DisableInfectedAbility(int client, float duration)
{
    if (client > 0 && client <= MaxClients && IsClientInGame(client))
    {
        int ability = GetEntPropEnt(client, Prop_Send, "m_customAbility");
        if (ability > 0 && IsValidEntity(ability))
        {
            SetEntPropFloat(ability, Prop_Send, "m_timestamp", GetGameTime() + duration);
        }
    }
}

// =======================
// LÓGICA DE MOVIMIENTO & PRETHINK
// =======================

public void Knux_PreThink(int client)
{
    if (!Knux_IsValidClient(client)) return;
    
    // Tank Disarm
    if (GetClientTeam(client) == TEAM_INFECTED && GetEntProp(client, Prop_Send, "m_zombieClass") == 8) {
        if (GetEngineTime() < g_fKnuxDisarmTank[client]) {
            int b = GetClientButtons(client);
            if (b & IN_ATTACK) SetEntProp(client, Prop_Data, "m_nButtons", b & ~IN_ATTACK);
        }
        return;
    }
    
    if (g_iPlayerCharIdx[client] != KNUCKLES_INDEX)
    {
        // v63: cambiando de personaje con el Meteoro activo (hover con
        // MOVETYPE_NONE) el estado quedaría huerfano -> reset INMEDIATO
        if (g_iKnuxSkyState[client] != KNUX_SKY_NONE) Knux_ResetState(client);
        return;
    }

    // Safety Checks
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0 || 
        GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0 ||
        GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0)
    {
        if (g_bKnuxCharging[client] || g_bKnuxSlamming[client] || g_bKnuxClinging[client] || g_bKnuxGliding[client] || g_bKnuxCountering[client]
            || g_iKnuxSkyState[client] != KNUX_SKY_NONE) {
            Knux_ResetState(client);
        }
        return;
    }

    // LÓGICA DE TIEMPO DEL COUNTER
    if (g_bKnuxCountering[client])
    {
        if (GetEngineTime() > g_fKnuxCounterEndTime[client]) Knux_StopCounter(client);
    }

    // v65-OM: TINTES DEL AVATAR — animador por frame (la matemática
    // simétrica EXACTA del knuckles_ui_om.lua) + el pulso ROJO repetido
    // de la carga del puño. Va ANTES de las ramas de vuelo para correr
    // también con el Meteoro activo.
    Knux_TintThink(client);

    int buttons = GetClientButtons(client);
    int flags = GetEntityFlags(client);
    float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);

    // v63 (R30): H3 METEOR STRIKE — con el estado activo, la maquina del
    // meteoro MANDA este frame (elevación/apuntado/picada): ni carga del
    // puño, ni planeo, ni pared. El impacto/timeout detona la explosión.
    if (g_iKnuxSkyState[client] != KNUX_SKY_NONE)
    {
        Knux_SkyThink(client, flags);
        return;
    }
    
    // Resetear al tocar suelo
    if (flags & FL_ONGROUND) {
        if (g_bKnuxGliding[client] || g_bKnuxClinging[client]) SetEntityGravity(client, 1.0);
        g_iKnuxWallChains[client] = 0;
        g_bKnuxGliding[client] = false;
        g_bKnuxClinging[client] = false;
        
        if (!g_bKnuxCharging[client] && !g_bKnuxSlamming[client]) SetEntityMoveType(client, MOVETYPE_WALK);
        
        if (g_bKnuxSlamming[client]) Knux_PerformGroundSlam(client);
    }

    // LÓGICA DE CARGA DEL PUÑO
    if (g_bKnuxCharging[client])
    {
        // v66-OM: NIVELES DE CARGA (lua l.1105-1164): nivel 2 a los 4.5s
        // (phase1.wav + pulso rojo l.1107-1121) y nivel 3 a los 9s
        // (phase3.wav + pulso l.1152-1164), con las ORBES DE FUEGO en
        // los puños desde 0.6s antes del nivel 3 (Knuckles_FireOrb
        // l.1123-1149). El poder del golpe = nivel al soltar.
        float heldT = GetEngineTime() - g_fKnuxChargeStart[client];
        if (g_iKnuxChargeLevel[client] == 1 && heldT >= g_cvKnuxChargeT1.FloatValue)
        {
            g_iKnuxChargeLevel[client] = 2;
            Knux_AvatarTintPulse(client, 255, 0, 0);   // Knuckles_glow_duration (l.1110)
            if (g_bKnuxSndPhase1) EmitSoundToAll("om/knuckles/phase1.wav", client, _, KNUX_SND_LEVEL);
            PrintCenterText(client, "✊ CARGA NIVEL 2");
        }
        if (g_iKnuxChargeLevel[client] == 2)
        {
            if (heldT >= g_cvKnuxChargeT2.FloatValue - 0.6) Knux_FireOrbs(client);
            if (heldT >= g_cvKnuxChargeT2.FloatValue)
            {
                g_iKnuxChargeLevel[client] = 3;
                Knux_AvatarTintPulse(client, 255, 0, 0);   // l.1155
                if (g_bKnuxSndPhase3) EmitSoundToAll("om/knuckles/phase3.wav", client, _, KNUX_SND_LEVEL);
                // v67-OM: el anillo de fuego en ambos puños (Knuckles_firering
                // del lua l.1179-1189 — effects l.95-183)
                Knux_FireRing(client);
                PrintCenterText(client, "🔥 CARGA NIVEL 3 — ¡MÁXIMO!");
            }
        }
        if (buttons & IN_RELOAD) {
            Knux_ResetState(client);
            // v66-OM: el cancel cobra el COOLDOWN CORTO del original
            // (cooldown_cancel 5s, lua l.1688) — antes no cobraba nada
            g_fKnuxPunchCooldown[client] = GetEngineTime() + g_cvKnuxPunchCDCancel.FloatValue;
            // v65-OM: pulso VERDE del cancel (glow_cancel_duration del
            // knuckles_ui_om.lua) + KnucklesCancel.wav — DESPUÉS del reset
            // (el reset limpia el tinte)
            Knux_KillFireOrbs(client);
            Knux_AvatarTintPulse(client, 0, 255, 0);
            if (g_bKnuxSndCancel) EmitSoundToAll("om/knuckles/KnucklesCancel.wav", client, _, KNUX_SND_LEVEL);
            PrintCenterText(client, "❌ Carga Cancelada");
            return;
        }
        
        if ((buttons & IN_ATTACK) || (buttons & IN_ATTACK2)) {
            int newButtons = buttons & ~(IN_ATTACK | IN_ATTACK2); 
            SetEntProp(client, Prop_Data, "m_nButtons", newButtons);
            // v66-OM: Slam1-4.wav aleatorio del CLICK (lua l.1757-1765) —
            // el golpe sale con el NIVEL de carga alcanzado
            if (g_bKnuxSndSlam) {
                char slamSnd[64];
                Format(slamSnd, sizeof(slamSnd), "om/knuckles/Slam%d.wav", GetRandomInt(1, 4));
                EmitSoundToAll(slamSnd, client, _, KNUX_SND_LEVEL);
            }
            Knux_ReleasePunch(client, g_iKnuxChargeLevel[client]); 
            return;
        }
    }

    // FÍSICAS EN EL AIRE Y PARED
    if (!(flags & FL_ONGROUND))
    {
        // 1. Enganche a la Pared (SOLO SI ESTÁ EN EL AIRE)
        if (!g_bKnuxCharging[client] && !g_bKnuxClinging[client] && !g_bKnuxSlamming[client] && g_iKnuxWallChains[client] < KNUX_MAX_WALL_CHAINS) {
            float wallN[3];
            if (GetEngineTime() > g_fKnuxNextClingTime[client] && Knux_FindWall(client, wallN)) {
                g_bKnuxClinging[client] = true;
                g_bKnuxGliding[client] = false;
                g_iKnuxWallChains[client]++;
                
                // v67-OM: ORIENTACION DEL AGARRE (lua l.759-792): el
                // pill_assignedangle = normal:Angle() — el avatar queda
                // MIRANDO AL LADO CONTRARIO de la pared (espalda contra
                // ella) mientras dura el agarre, y el salto de salida
                // sale por la normal (l.700), no por la cámara
                g_fKnuxLatchNormal[client][0] = wallN[0];
                g_fKnuxLatchNormal[client][1] = wallN[1];
                g_fKnuxLatchNormal[client][2] = wallN[2];
                g_fKnuxLatchYaw[client] = RadToDeg(ArcTangent2(wallN[1], wallN[0]));
                
                float stop[3] = {0.0, 0.0, 0.0};
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, stop);
                SetEntityMoveType(client, MOVETYPE_NONE); 
                // v65-OM: Latch.wav del lua (l.776) al agarrarse
                if (g_bKnuxSndLatch) EmitSoundToAll("om/knuckles/Latch.wav", client, _, KNUX_SND_LEVEL);
                PrintCenterText(client, "🧱 Agarrado (%d/%d)", g_iKnuxWallChains[client], KNUX_MAX_WALL_CHAINS);
            }
        }

        // 2. Salida de la Pared (Responsivo al mantener salto o presionarlo)
        if (g_bKnuxClinging[client]) {
            if (buttons & IN_JUMP) {
                g_bKnuxClinging[client] = false;
                g_fKnuxNextClingTime[client] = GetEngineTime() + 0.5; // Cooldown de pared
                
                SetEntityMoveType(client, MOVETYPE_WALK); 
                // v67-OM: el impulso sale por la NORMAL de la pared (lua
                // l.700: Normals_latch:Forward()*glideg) — mirando al lado
                // contrario, saltar YA no te lanza contra la propia pared
                // que dejaste atras (la cámara puede seguir mirándola)
                float fwd[3];
                fwd[0] = g_fKnuxLatchNormal[client][0] * g_cvKnuxGlideSpeed.FloatValue * 1.2;
                fwd[1] = g_fKnuxLatchNormal[client][1] * g_cvKnuxGlideSpeed.FloatValue * 1.2;
                fwd[2] = 450.0; // Gran empuje hacia arriba
                
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fwd);
                // v65-OM: one-shot LatchOff al soltarse de la pared (lua l.1585)
                Knux_AvatarOneShot(client, KNUX_ST_LATCHOFF, KNUX_LOCK_LATCHOFF);
                g_bKnuxGliding[client] = true;
                
                return; // Return inmediato para evitar que el Air Steering anule la velocidad de salto
            }
        }

        // 3. Air Steering (Control Aéreo Activo)
        if (g_bKnuxGliding[client] && !g_bKnuxClinging[client]) 
        {
            SetEntityGravity(client, g_cvKnuxGlideGravity.FloatValue);
            if (vel[2] < -250.0) vel[2] = -250.0; // Velocidad terminal del planeo

            // Dirección basada en la cámara (WASD)
            float fwdAng[3], fwd[3], right[3];
            GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
            GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);

            float accel = 25.0; 
            float maxSpeed = g_cvKnuxGlideSpeed.FloatValue;
            bool apply = false;

            if (buttons & IN_FORWARD)  { vel[0] += fwd[0]*accel; vel[1] += fwd[1]*accel; apply = true; }
            if (buttons & IN_BACK)     { vel[0] -= fwd[0]*accel; vel[1] -= fwd[1]*accel; apply = true; }
            if (buttons & IN_MOVELEFT) { vel[0] -= right[0]*accel; vel[1] -= right[1]*accel; apply = true; }
            if (buttons & IN_MOVERIGHT){ vel[0] += right[0]*accel; vel[1] += right[1]*accel; apply = true; }

            if (apply) {
                float speed2D = SquareRoot(vel[0]*vel[0] + vel[1]*vel[1]);
                if (speed2D > maxSpeed) {
                    vel[0] = (vel[0]/speed2D) * maxSpeed;
                    vel[1] = (vel[1]/speed2D) * maxSpeed;
                }
            }
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        }
        else if (!g_bKnuxClinging[client] && !g_bKnuxSlamming[client]) 
        {
            // Control Aéreo Normal (Pequeña aceleración extra al saltar normal)
            float fwdAng[3], fwd[3], right[3];
            GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
            GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);
            
            float accel = 12.0; 
            float maxSpeed = 300.0; 
            bool apply = false;
            
            if (buttons & IN_FORWARD)  { vel[0] += fwd[0]*accel; vel[1] += fwd[1]*accel; apply = true; }
            if (buttons & IN_BACK)     { vel[0] -= fwd[0]*accel; vel[1] -= fwd[1]*accel; apply = true; }
            if (buttons & IN_MOVELEFT) { vel[0] -= right[0]*accel; vel[1] -= right[1]*accel; apply = true; }
            if (buttons & IN_MOVERIGHT){ vel[0] += right[0]*accel; vel[1] += right[1]*accel; apply = true; }

            if (apply) {
                float speed2D = SquareRoot(vel[0]*vel[0] + vel[1]*vel[1]);
                if (speed2D > maxSpeed) {
                    vel[0] = (vel[0]/speed2D) * maxSpeed;
                    vel[1] = (vel[1]/speed2D) * maxSpeed;
                }
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
            }
        }
    }
    
    // v70-OM: el escaneo de proyectiles de la postura SE VA — el parry
    // de proyectiles lo ejecuta el VScript (chch_parrying.nut v2.2, con
    // la ventana que le abre el Parry.smx v2.1 al detectar el shove).
    // La postura sigue siendo el counter de GOLPES FÍSICOS de siempre.
}

// v67-OM: devuelve la NORMAL de la pared (lua l.759: tr.HitNormal) y
// aplica el gate del lua l.761 (|normal.z| < 0.5): solo superficies de
// PARED cuentan — suelo y techo no son agarrables en el original
bool Knux_FindWall(int client, float normal[3])
{
    float pos[3], ang[3], fwd[3], end[3];
    GetClientEyePosition(client, pos); GetClientEyeAngles(client, ang);
    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(fwd, 40.0); AddVectors(pos, fwd, end);
    float mins[3] = {-16.0, -16.0, -16.0}; float maxs[3] = {16.0, 16.0, 16.0};
    Handle trace = TR_TraceHullFilterEx(pos, end, mins, maxs, MASK_SOLID, Knux_TraceFilter_World, client);
    bool hit = TR_DidHit(trace);
    if (hit)
    {
        TR_GetPlaneNormal(trace, normal);
        // lua l.761: solo paredes (normal ~horizontal)
        if (normal[2] > 0.5 || normal[2] < -0.5) hit = false;
    }
    delete trace;
    return hit;
}
public bool Knux_TraceFilter_World(int entity, int contentsMask, int data) { return (entity == 0); }

// =======================
// ACTIVA 1: PUNCH / GROUND SLAM
// =======================

public Action Command_KnuxPunch(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Knux_IsValidClient(client) || g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return Plugin_Handled;
    
    if (g_bKnuxCharging[client]) return Plugin_Handled; 
    if (g_bKnuxCountering[client]) return Plugin_Handled;
    // v58: no permitir iniciar una nueva carga en mitad de un Meteor Smash
    if (g_bKnuxSlamming[client]) return Plugin_Handled;
    // v63: ni en mitad de la H3 Meteoro (el estado manda el frame)
    if (g_iKnuxSkyState[client] != KNUX_SKY_NONE) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fKnuxPunchCooldown[client]) {
        PrintCenterText(client, "Punch Cooldown: %.1f", g_fKnuxPunchCooldown[client] - now);
        return Plugin_Handled;
    }

    g_bKnuxCharging[client] = true;
    // v66-OM: la carga arranca en NIVEL 1 y sube con el tiempo (lua l.1105)
    g_iKnuxChargeLevel[client] = 1;
    g_fKnuxChargeStart[client] = now;
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.7); 
    // v65-OM: sonido auténtico del inicio de carga (punchstart.wav, lua
    // l.1707 — antes iba el crowbar stock) + arranque del pulso ROJO del
    // UI (el primer pulso sale YA en el próximo PreThink)
    if (g_bKnuxSndPunchStart) EmitSoundToAll("om/knuckles/punchstart.wav", client, _, KNUX_SND_LEVEL);
    else EmitSoundToAll(KNUX_SOUND_CHARGE_1, client);
    g_fKnuxNextPulse[client] = 0.0;
    
    PrintCenterText(client, "✊ [CLICK] GOLPEAR | [R] CANCELAR");
    return Plugin_Handled;
}

void Knux_ReleasePunch(int client, int power)
{
    g_bKnuxCharging[client] = false;
    Knux_KillFireOrbs(client);   // v66: las orbes se apagan al soltar
    // v66-OM: el poder con el que salió (lo leen el sweep y el slam)
    g_iKnuxPunchPower[client] = power;
    g_iKnuxChargeLevel[client] = 0;
    g_fKnuxPunchCooldown[client] = GetEngineTime() + g_cvKnuxPunchCD.FloatValue;
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntityMoveType(client, MOVETYPE_WALK);

    if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // AIR SLAM (Caida en picada)
        g_bKnuxSlamming[client] = true;
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[0] = 0.0; vel[1] = 0.0; vel[2] = -1500.0; 
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        // v65-OM: one-shot 'attack' del lanzamiento aéreo (lua l.1781) +
        // swing.wav (l.1794) — el loop de la picada lo pone la FSM
        // (FallAttack, el punchFallanim del lua)
        Knux_AvatarOneShot(client, KNUX_ST_ATTACK, KNUX_LOCK_ATTACK);
        if (g_bKnuxSndSwing) EmitSoundToAll("om/knuckles/swing.wav", client, _, KNUX_SND_LEVEL);
        PrintCenterText(client, "☄️ METEOR SMASH!");
    }
    else
    {
        // DASH PUNCH (Ataque terrestre)
        float ang[3], fwd[3], pos[3];
        GetClientEyeAngles(client, ang);
        GetClientAbsOrigin(client, pos);
        
        pos[2] += 10.0;
        float dashAng[3]; dashAng[0] = 0.0; dashAng[1] = ang[1]; dashAng[2] = 0.0;
        GetAngleVectors(dashAng, fwd, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(fwd, 1500.0);
        fwd[2] = 200.0; 
        
        TeleportEntity(client, pos, NULL_VECTOR, fwd);
        // v65-OM: one-shot PunchAnim del dash punch (lua l.326) + swing
        // auténtico con fallback al stock de siempre
        Knux_AvatarOneShot(client, KNUX_ST_PUNCH, KNUX_LOCK_PUNCH);
        if (g_bKnuxSndSwing) EmitSoundToAll("om/knuckles/swing.wav", client, _, KNUX_SND_LEVEL);
        else EmitSoundToAll(KNUX_SOUND_PUNCH, client);

        // v58: abrir una nueva "epoch" de golpe (invalida áutomaticamente
        // todas las marcas de golpes anteriores - antes había que resetear
        // 2048 slots con un bucle en cada golpe)
        g_iKnuxDashEpoch++;
        if (g_iKnuxDashEpoch >= 0x7FFFFFF0)
        {
            // Protección de wrap-around (practicamente inalcanzable)
            for (int i = 0; i < 2048; i++) g_iKnuxHitMark[i] = 0;
            g_iKnuxDashEpoch = 1;
        }

        DataPack pack = new DataPack();
        pack.WriteCell(GetClientUserId(client));
        pack.WriteFloat(GetEngineTime());
        // v58: TIMER_DATA_HNDL_CLOSE - el pack se libera solo cuando el timer
        // termina (antes se filtraba el handle en CADA golpe)
        CreateTimer(0.1, T_KnuxSweep, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
    }
}

public Action T_KnuxSweep(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    float startTime = pack.ReadFloat();
    
    int client = GetClientOfUserId(userid);
    
    // v58: parar también si el jugador ya no es Knuckles (cambio de personaje
    // a mitad del dash) - no debe golpear con poderes que ya no posee
    if (!Knux_IsValidClient(client) || GetEngineTime() - startTime > 0.5
        || g_iPlayerCharIdx[client] != KNUCKLES_INDEX)
    {
        return Plugin_Stop;
    }
    
    float pos[3]; GetClientAbsOrigin(client, pos);
    float radius = 160.0;
    
    // Rastro Visual (Anillos) - v58: sprite cacheado en OnMapStart
    pos[2] += 30.0;
    if (g_iKnuxBeamSprite <= 0) g_iKnuxBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
    TE_SetupBeamRingPoint(pos, 10.0, radius, g_iKnuxBeamSprite, 0, 0, 0, 0.2, 5.0, 0.0, {255, 50, 0, 255}, 0, 0);
    TE_SendToAll();
    pos[2] -= 30.0;

    // Detectar Jugadores Infectados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            if (g_iKnuxHitMark[i] != g_iKnuxDashEpoch)
            {
                float targetPos[3]; GetClientAbsOrigin(i, targetPos);
                if (GetVectorDistance(pos, targetPos) <= radius)
                {
                    Knux_ApplyPunchHit(client, i, g_iKnuxPunchPower[client]);
                    g_iKnuxHitMark[i] = g_iKnuxDashEpoch;
                }
            }
        }
    }
    
    // Detectar Comunes y Witches (v58: guard de rango para edicts altos)
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (entity < 2048 && IsValidEntity(entity) && g_iKnuxHitMark[entity] != g_iKnuxDashEpoch)
        {
            float targetPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos);
            if (GetVectorDistance(pos, targetPos) <= radius)
            {
                Knux_ApplyPunchHit(client, entity, g_iKnuxPunchPower[client]);
                g_iKnuxHitMark[entity] = g_iKnuxDashEpoch;
            }
        }
    }
    
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (entity < 2048 && IsValidEntity(entity) && g_iKnuxHitMark[entity] != g_iKnuxDashEpoch)
        {
            float targetPos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos);
            if (GetVectorDistance(pos, targetPos) <= radius)
            {
                Knux_ApplyPunchHit(client, entity, g_iKnuxPunchPower[client]);
                g_iKnuxHitMark[entity] = g_iKnuxDashEpoch;
            }
        }
    }

    // v63 (R30): PROPS/VEHICULOS — "mismo tipo de sistema que amy (sin
    // la parte de convertir objetos en V)": el dash BARRA objetos con V
    // (VPHYSICS) activo y los avienta hacia donde embiste. Los
    // decorativos ni se tocan (sin conversión). Un golpe por dash
    // (mismo epoch de los infectados).
    {
        int props[KNUX_PROPS_PER_HIT];
        int nProps = Knux_FindVProps(pos, radius, props, KNUX_PROPS_PER_HIT);
        if (nProps > 0)
        {
            float ang[3], dir[3];
            GetClientEyeAngles(client, ang);
            GetAngleVectors(ang, dir, NULL_VECTOR, NULL_VECTOR);
            float hLen = SquareRoot(dir[0] * dir[0] + dir[1] * dir[1]);
            if (hLen < 0.001) { dir[0] = 0.0; dir[1] = 1.0; }
            else { dir[0] /= hLen; dir[1] /= hLen; }
            dir[2] = 0.0;

            for (int k = 0; k < nProps; k++)
            {
                int prop = props[k];
                if (prop < 2048 && g_iKnuxHitMark[prop] == g_iKnuxDashEpoch) continue;
                if (Knux_PushMapProp(client, prop, dir, g_cvKnuxPropForce.FloatValue, 0.25))
                {
                    if (prop < 2048) g_iKnuxHitMark[prop] = g_iKnuxDashEpoch;
                }
            }
        }
    }
    
    return Plugin_Continue;
}

void Knux_ApplyPunchHit(int attacker, int victim, int power)
{
    if (power < 1) power = 1;
    if (power > 3) power = 3;
    bool isWitch = false;
    char cls[32];
    
    if (victim > MaxClients) {
        GetEntityClassname(victim, cls, sizeof(cls));
        if (StrEqual(cls, "witch")) isWitch = true;
    }

    // v66-OM: escalado del NIVEL DE CARGA (lua l.297-335 + l.915-932):
    // dano + damageamount1/2 (35+5/+10 del original -> x1.15/x1.30 sobre
    // nuestro 100/1000), stun basestun 4 + stunamount 1/2 (4/5/6s) y el
    // lanzon 750*(additives+1) = x1/x2/x3 (l.323). Nivel 3: QUEMA 8s
    // (OM_burntarget 8, l.306-307).
    float dmgMult  = (power == 3) ? 1.30 : (power == 2) ? 1.15 : 1.0;
    float pushMult = float(power);           // x1 / x2 / x3
    float stunDur  = 4.0 + float(power - 1); // 4 / 5 / 6s

    if (victim <= MaxClients && IsClientInGame(victim)) {
        float pos[3]; GetClientAbsOrigin(attacker, pos);
        float fling[3]; GetClientEyeAngles(attacker, fling);
        GetAngleVectors(fling, fling, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(fling, 800.0 * pushMult); fling[2] = 300.0 * pushMult;

        // v66-OM: el stun del original es el OM COMPLETO (Mutaul_OMStunCode
        // l.298: ESTATUA + estrellas + apilable) EMPUJABLE — la estatua
        // vuela con el lanzon y desliza como el arrastre del rayo de
        // Tails (OM_STUN_F_PUSH + OM_Stun_Push). Los SI humanos (sin
        // estatua por el gate de paridad GMod) caen al camino de siempre
        // del v60: stagger seguro + TeleportEntity.
        if (OM_Stun(victim, stunDur, attacker, 100.0 * dmgMult, DMG_CLUB, true, OM_STUN_F_PUSH))
        {
            float srcPos[3]; GetClientAbsOrigin(attacker, srcPos);
            OM_Stun_Push(victim, fling, srcPos);
        }
        else
        {
            // v60: stagger SEGURO (antes: L4D_StaggerPlayer directo → los
            // bots SI se quedaban tirados en el suelo para siempre)
            SIStagger_Auto(victim, attacker, pos);
            // v61: TeleportEntity en vez del Fling crudo (crash documentado
            // del motor fuera del contexto del Charger; ver header v61)
            TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, fling);
            OM_AbilityDamage(victim, attacker, 100.0 * dmgMult, DMG_CLUB);
        }
        // v66-OM: la QUEMA del nivel 3 (OM_burntarget 8s del lua)
        if (power >= 3) IgniteEntity(victim, 8.0);
        // v65-OM: punchstun.wav auténtico del impacto (lua l.310) con
        // fallback al stock de siempre
        if (g_bKnuxSndPunchStun) EmitSoundToAll("om/knuckles/punchstun.wav", victim, _, KNUX_SND_LEVEL);
        else EmitSoundToAll(KNUX_SOUND_SMASH_HIT, victim);
    } else {
        if (isWitch) {
            // v59 (Witch Flight): lanzamiento con IA suspendida: la witch
            // vuela de verdad (su locomoción NextBot anulaba el empuje)
            float push[3]; GetClientEyeAngles(attacker, push);
            GetAngleVectors(push, push, NULL_VECTOR, NULL_VECTOR);
            ScaleVector(push, 800.0 * pushMult); push[2] = 450.0 * pushMult;
            WitchFlight_Launch(victim, attacker, push);
            OM_AbilityDamage(victim, attacker, 1000.0 * dmgMult, DMG_CLUB);
            // v61: si murió en pleno vuelo, restaurarla YA
            WitchFlight_CheckDead(victim);
            // v66: la witch NO se quema (el fuego la ENFURECE y pelearia
            // con el WitchFlight — receta para activarlo: 1 línea
            // IgniteEntity(victim, 8.0) justo aquí)
        } else {
            // v59: común - empuje ANTES del dano (el ragdoll hereda el
            // impulso, mismo fix que Amy v45): mueren volando
            float push[3]; GetClientEyeAngles(attacker, push);
            GetAngleVectors(push, push, NULL_VECTOR, NULL_VECTOR);
            ScaleVector(push, 700.0 * pushMult); push[2] = 350.0 * pushMult;
            TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, push);
            OM_AbilityDamage(victim, attacker, 1000.0 * dmgMult, DMG_CLUB);
            if (power >= 3) IgniteEntity(victim, 8.0);
        }
        // v65-OM: idem para witch/comunes del dash punch
        if (g_bKnuxSndPunchStun) EmitSoundToAll("om/knuckles/punchstun.wav", attacker, _, KNUX_SND_LEVEL);
        else EmitSoundToAll(KNUX_SOUND_SMASH_HIT, attacker);
    }
}

void Knux_PerformGroundSlam(int client)
{
    g_bKnuxSlamming[client] = false;
    SetEntityMoveType(client, MOVETYPE_WALK);

    EmitSoundToAll(KNUX_SOUND_SLAM, client);
    // v65-OM: one-shot GroundSmash del aterrizaje (lua l.1073) + el
    // punchstun.wav que el lua pone en el impacto del smash (l.1060)
    Knux_AvatarOneShot(client, KNUX_ST_SMASH, KNUX_LOCK_SMASH);
    if (g_bKnuxSndPunchStun) EmitSoundToAll("om/knuckles/punchstun.wav", client, _, KNUX_SND_LEVEL);
    
    float pos[3]; GetClientAbsOrigin(client, pos);
    float radius = g_cvKnuxSlamRadius.FloatValue;
    // v66-OM: el smash escala con el NIVEL DE CARGA con el que se solto
    // (damageamount1/2 del lua: x1.15/x1.30) y al nivel 3 QUEMA 8s
    int power = g_iKnuxPunchPower[client];
    if (power < 1) power = 1;
    if (power > 3) power = 3;
    float damage = g_cvKnuxSlamDmg.FloatValue * ((power == 3) ? 1.30 : (power == 2) ? 1.15 : 1.0);
    
    TE_SetupBeamRingPoint(pos, 10.0, radius, PrecacheModel("materials/sprites/laserbeam.vmt"), 0, 0, 0, 0.5, 20.0, 0.0, {255, 50, 0, 255}, 0, 0);
    TE_SendToAll();

    for (int i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;
        float targetPos[3]; GetClientAbsOrigin(i, targetPos);
        if (GetVectorDistance(pos, targetPos) <= radius) {
            // v71: EL BOOMER NO LE ESTALLA ENCIMA A KNUCKLES — el dano
            // del smash NO lo mata aquí (si sería letal, no se aplica):
            // sale VOLANDO con la levantada de siempre + la MECHA y
            // estalla al TOCAR EL SUELO (OM_BoomerFuseMark GROUND).
            bool esBoomer = (GetEntProp(i, Prop_Send, "m_zombieClass") == 2);
            if (esBoomer)
            {
                if (!OM_BoomerFusePending(i) && float(GetClientHealth(i)) > damage)
                    OM_AbilityDamage(i, client, damage, DMG_BLAST);  // no letal: dano normal
                OM_BoomerFuseMark(i, client, OM_BOOMER_FUSE_GROUND);
            }
            else
                OM_AbilityDamage(i, client, damage, DMG_BLAST);

            // v62 (petición usuario): el smash LEVANTA a los especiales:
            // lanzamiento vertical potente + separación moderada. El
            // stagger YA NO se aplica aquí: se aplica AL ATERRIZAR
            // (registrado en la lista de landing-stagger). La witch
            // ya vuela con WitchFlight (su propio sistema de
            // aterrizaje ya la aturde e impacta al caer).
            float push[3]; MakeVectorFromPoints(pos, targetPos, push);
            push[2] = 0.0;
            if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; }
            NormalizeVector(push, push);
            ScaleVector(push, 350.0);   // separación moderada
            push[2] = 600.0;            // LEVANTADA potente
            TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);

            Knux_RegisterLandingStagger(i, client);
            // v66-OM: la QUEMA del nivel 3 en el área del smash
            if (power >= 3) IgniteEntity(i, 8.0);
        }
    }
    
    int infected = -1;
    while ((infected = FindEntityByClassname(infected, "infected")) != -1) {
        if (IsValidEntity(infected)) {
            float zPos[3]; GetEntPropVector(infected, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(pos, zPos) <= radius) {
                OM_AbilityDamage(infected, client, damage, DMG_BLAST);
                if (power >= 3) IgniteEntity(infected, 8.0);
            }
        }
    }
    
    int witch = -1;
    while ((witch = FindEntityByClassname(witch, "witch")) != -1) {
        if (IsValidEntity(witch)) {
            float wPos[3]; GetEntPropVector(witch, Prop_Send, "m_vecOrigin", wPos);
            if (GetVectorDistance(pos, wPos) <= radius) {
                // v59 (Witch Flight): lanzamiento con IA suspendida antes
                // del dano (la witch sale volando y aterriza con impacto)
                // v62: la LEVANTADA de la witch se refuerza (más vertical):
                // el smash la manda bien arriba y el sistema WitchFlight
                // aplica dano + stun de aterrizaje al caer (0.75s de IA
                // congelada + impacto + rage).
                float push[3]; MakeVectorFromPoints(pos, wPos, push); 
                push[2] = 0.0;
                if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; }
                NormalizeVector(push, push);
                ScaleVector(push, 500.0); push[2] = 700.0;
                WitchFlight_Launch(witch, client, push);
                OM_AbilityDamage(witch, client, damage, DMG_BLAST);
                // v61: si murió en pleno vuelo, restaurarla YA
                WitchFlight_CheckDead(witch);
            }
        }
    }

    // v63 (R30): PROPS/VEHICULOS — el ground slam del Meteor Smash
    // empuja RADIALMENTE todo objeto con V (VPHYSICS) activo (mismo
    // sistema que Amy, sin conversión): "su golpe al suelo en área
    // ahora Puede empujar Objetos (props) autos y demas".
    {
        int props[KNUX_PROPS_PER_HIT];
        int nProps = Knux_FindVProps(pos, radius, props, KNUX_PROPS_PER_HIT);
        for (int k = 0; k < nProps; k++)
        {
            float pPos[3], dir[3];
            GetEntPropVector(props[k], Prop_Send, "m_vecOrigin", pPos);
            MakeVectorFromPoints(pos, pPos, dir);
            dir[2] = 0.0;
            if (GetVectorLength(dir) < 1.0) { dir[0] = 0.0; dir[1] = 1.0; }
            NormalizeVector(dir, dir);
            Knux_PushMapProp(client, props[k], dir, g_cvKnuxPropForce.FloatValue * 1.2, 0.6);
        }
    }
    // v66-OM: el poder ya fue consumido por el slam (higiene: un Meteoro
    // posterior no hereda un nivel viejo)
    g_iKnuxPunchPower[client] = 0;
}

// ============================================================
// v62: STAGGER AL ATERRIZAR (Meteor Smash)
// ============================================================

// Registra a un especial lanzado por el smash para recibir el
// SIStagger justo al tocar suelo (con un mínimo de aire de 0.35s para
// no disparar en el frame de lanzamiento, que aún reporta ONGROUND).
void Knux_RegisterLandingStagger(int victim, int attacker)
{
    if (victim <= 0 || victim > MaxClients) return;

    int victimUid = GetClientUserId(victim);
    if (victimUid <= 0) return;

    // Reusar el slot si este jugador ya esta registrado
    int slot = -1;
    for (int i = 0; i < KNUX_LANDSTAGGER_SLOTS; i++)
    {
        if (g_iKnuxLandVictim[i] == victimUid) { slot = i; break; }
    }
    if (slot == -1)
    {
        for (int i = 0; i < KNUX_LANDSTAGGER_SLOTS; i++)
        {
            if (g_iKnuxLandVictim[i] == 0) { slot = i; break; }
        }
    }
    if (slot == -1) return;   // lleno: se pierde el stagger de aterrizaje (graceful)

    float now = GetEngineTime();
    g_iKnuxLandVictim[slot]   = victimUid;
    g_iKnuxLandAttacker[slot] = (attacker > 0 && attacker <= MaxClients) ? GetClientUserId(attacker) : 0;
    g_fKnuxLandDeadline[slot] = now + KNUX_LANDSTAGGER_TIMEOUT;
    g_fKnuxLandMinAir[slot]   = now + KNUX_LANDSTAGGER_MIN_AIR;

    if (!g_bKnuxLandTimerOn)
    {
        g_bKnuxLandTimerOn = true;
        CreateTimer(0.1, T_KnuxLandStagger, _, TIMER_REPEAT);
    }
}

// Vigila a los lanzados: cuando tocan suelo (o expiran), aplica el
// stagger de aterrizaje (SIStagger_Auto: se levanta garantizado).
public Action T_KnuxLandStagger(Handle timer)
{
    bool anyActive = false;
    float now = GetEngineTime();

    for (int i = 0; i < KNUX_LANDSTAGGER_SLOTS; i++)
    {
        if (g_iKnuxLandVictim[i] == 0) continue;

        int victim = GetClientOfUserId(g_iKnuxLandVictim[i]);

        // Expiro / desconecto / murió: liberar slot
        if (now > g_fKnuxLandDeadline[i]
            || victim <= 0 || !IsClientInGame(victim) || !IsPlayerAlive(victim))
        {
            g_iKnuxLandVictim[i] = 0;
            continue;
        }

        // Mínimo de aire: el flag ONGROUND tarda 1+ frames en
        // limpiarse tras el TeleportEntity del lanzamiento
        if (now < g_fKnuxLandMinAir[i]) { anyActive = true; continue; }

        // Aterrizo? -> STAGGER
        if (GetEntityFlags(victim) & FL_ONGROUND)
        {
            int attacker = GetClientOfUserId(g_iKnuxLandAttacker[i]);
            float vPos[3]; GetClientAbsOrigin(victim, vPos);

            SIStagger_Auto(victim, (attacker > 0 && IsClientInGame(attacker)) ? attacker : 0, vPos);
            EmitSoundToAll(KNUX_SOUND_SMASH_HIT, victim);

            // VFX del aterrizaje golpeado
            TE_SetupBeamRingPoint(vPos, 10.0, 120.0, g_iKnuxBeamSprite, 0, 0, 0, 0.3, 5.0, 0.0, {255, 50, 0, 220}, 0, 0);
            TE_SendToAll();

            g_iKnuxLandVictim[i] = 0;
            continue;
        }

        anyActive = true;
    }

    if (!anyActive)
    {
        g_bKnuxLandTimerOn = false;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// v59: el fling de witch vive ahora en Witch_Flight.inc (sistema
// compartido con Amy): IA suspendida + vuelo real + restauración
// garantizada (aterrizaje / timeout 4s / muerte).

// ============================================================
//  v75-OM — EL PUENTE DIRECTO AL VSCRIPT (patron supertank):
//  Knux_ParryNotifyNut. La postura invoca a la entrada ChCh_KnxNotify
//  del chch_parrying.nut v2.8 por RunScriptCode en un logic_script
//  propio — EXACTAMENTE como Amy con su pose (Amy_ParryNotifyNut) y
//  como el tarot con SetAmyMode del Super Tank. Cero consola, cero
//  Parry.smx de por medio, cero registro de personajes: la entrada ES
//  la identidad (la invoca el código de Knuckles, luego es Knuckles).
//  El guard "in getroottable()" lo hace no-op silencioso si el .nut
//  no está cargado (no ensucia la consola).
// ============================================================
void Knux_ParryNotifyNut(int client, bool on, float dur)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    int runner = Knux_FindScriptRunner();
    if (runner == -1 || !IsValidEntity(runner)) return;

    char code[192];
    Format(code, sizeof(code),
        "local r = getroottable(); if(\"ChCh_KnxNotify\" in r) r.ChCh_KnxNotify(%d, %d, %.2f)",
        client, on ? 1 : 0, dur);

    SetVariantString(code);
    AcceptEntityInput(runner, "RunScriptCode");
}

// Helper: encontrar o crear NUESTRO logic_script (lección v51 de Amy:
// JAMÁS reusar el logic_script de un mapa — pisaria su estado). Se
// crea nuevo con targetname propio y muere con el mapa.
#define KNUX_SCRIPT_RUNNER_NAME "knux_parry_runner"
int Knux_FindScriptRunner() {
    int entity = -1;
    char nameBuf[32];
    while ((entity = FindEntityByClassname(entity, "logic_script")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        GetEntPropString(entity, Prop_Data, "m_iName", nameBuf, sizeof(nameBuf));
        if (StrEqual(nameBuf, KNUX_SCRIPT_RUNNER_NAME, false)) return entity;
    }
    entity = CreateEntityByName("logic_script");
    if (entity != -1) {
        DispatchKeyValue(entity, "targetname", KNUX_SCRIPT_RUNNER_NAME);
        DispatchSpawn(entity);
    }
    return entity;
}

// =======================
// ACTIVA 2: COUNTER (PERSISTENTE)
// =======================

public Action Command_KnuxCounter(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Knux_IsValidClient(client) || g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return Plugin_Handled;
    if (g_bKnuxCharging[client]) return Plugin_Handled;
    // v63: ni counter en mitad de la H3 Meteoro (su estado manda el frame)
    if (g_iKnuxSkyState[client] != KNUX_SKY_NONE) return Plugin_Handled;

    if (g_bKnuxCountering[client]) {
        Knux_StopCounter(client); 
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fKnuxCounterCooldown[client]) {
        PrintCenterText(client, "Counter Cooldown: %.1f", g_fKnuxCounterCooldown[client] - now);
        return Plugin_Handled;
    }

    g_bKnuxCountering[client] = true;
    g_fKnuxCounterEndTime[client] = now + g_cvKnuxCounterDuration.FloatValue;
    
    // v66-OM: ANIMACION DE PREPARACION del bloqueo (el gesture del lua
    // l.1618: AddGesture ACT_GESTURE_RANGE_ATTACK1_LOW, fade 1.25s) —
    // faltaba desde el v65 ("no hace su animación de golpe ni de
    // preparación"). Con el fix de yaw: la secuencia mira al FRENTE.
    Knux_AvatarOneShot(client, KNUX_ST_COUNTER, KNUX_LOCK_COUNTER);
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.5); 
    // v65-OM: counter.wav auténtico (lua l.1648) con fallback
    if (g_bKnuxSndCounter) EmitSoundToAll("om/knuckles/counter.wav", client, _, KNUX_SND_LEVEL);
    else EmitSoundToAll(KNUX_SOUND_COUNTER, client);
    SetEntityRenderColor(client, 200, 200, 255, 255); 
    
    PrintCenterText(client, "🛡️ POSTURA DEFENSIVA (%.1fs)", g_cvKnuxCounterDuration.FloatValue);

    // v73/v75-OM (owner 2026-10-10: "tenía que hacer un shove previo y
    // luego activar el bloqueo... es un desproposito"): LA POSTURA
    // ABRE LA VENTANA DEL PARRY SOLA. v75: LLAMADA DIRECTA AL VSCRIPT
    // (patron SetAmyMode del supertank — igual que Amy con su pose):
    // RunScriptCode -> ChCh_KnxNotify(idx, 1, dur) en el
    // chch_parrying.nut v2.8. Sin consola, sin Parry.smx de por medio,
    // sin gates: la entrada ES la identidad. La ventana dura lo que
    // dure la postura (knux_counter_duration, 8 s) y devuelve todo lo
    // que le tiren (roca/saliva/granadas + enemigos en cono).
    Knux_ParryNotifyNut(client, true, g_cvKnuxCounterDuration.FloatValue);
    
    return Plugin_Handled;
}

void Knux_StopCounter(int client)
{
    g_bKnuxCountering[client] = false;
    // v73/v75-OM: la postura se apaga -> su ventana del parry TAMBIÉN
    // (toggle manual, expiración de los 8s: todo pasa por aquí).
    // v75: DIRECTO al .nut (patron supertank).
    Knux_ParryNotifyNut(client, false, 0.0);
    if (IsClientInGame(client)) {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0); 
        SetEntityRenderColor(client, 255, 255, 255, 255);
        SetEntProp(client, Prop_Data, "m_takedamage", 2); 
    }
    g_fKnuxCounterCooldown[client] = GetEngineTime() + g_cvKnuxCounterCD.FloatValue;
    PrintCenterText(client, "Postura terminada.");
}

// ===================================================================================
// HOOKS "FAKE SI" (EXTRAÍDOS DE L4D2_PLAY_AS_SI)
// BLOQUEO ABSOLUTO DE AGARRES (SMOKER / CHARGER / FLING / BOOMER)
// ===================================================================================

public Action L4D_OnGrabWithTongue(int victim, int attacker)
{
    // v6.5 Sonic: la lengua NO entra si va rodando (bola), está en la
    // gracia del dodge o paga los anillos de la tabla del owner
    if (Sonic_TongueGuard(victim)) return Plugin_Handled;

    // v3.77.28 (Metal v5.3): la lengua del smoker TAMPOCO agarra a un
    // Metal en plena embestida (windup->rebote: Metal_ControlImmune).
    // ESTE es el forward real — el guard de la 3.77.27 vivía en un
    // "L4D_OnTongueGrab_Pre" fantasma que left4dhooks nunca invocaba
    // (fuente del "un smoker me pudo agarrar con la lengua durante la
    // carga"). Devolver Handled aquí BLOQUEA el agarre antes de que
    // empiece: ni un frame de lengua.
    if (g_iPlayerCharIdx[victim] == METALSONIC_INDEX && Metal_ControlImmune(victim)) return Plugin_Handled;

    // v3.77.28: REVIVE el pedido v64 del owner que solo vivía en el
    // fantasma: Amy rompe la lengua AL INSTANTE, SIEMPRE (el agarre
    // nunca llega a empezar y el smoker recibe la contra completa).
    if (g_iPlayerCharIdx[victim] == AMY_INDEX && Amy_TongueCounter(victim, attacker)) return Plugin_Handled;

    if (Knux_IsValidClient(victim) && g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && g_bKnuxCountering[victim])
    {
        Knuckles_HandleSmokerCounter(victim, attacker);
        return Plugin_Handled;
    }

    // v2.1 Kolossos: el bloqueo detecta la lengua AL INSTANTE — el
    // agarre nunca llega a empezar y el smoker come el counter
    if (Kolossos_PlayerIs(victim) && Kolossos_BlockActive(victim))
    {
        Kolossos_BlockEnd(victim);
        Kolossos_BlockCounter(victim, attacker, attacker);
        PrintCenterText(victim, "BLOQUEO! Lengua rota al instante");
        return Plugin_Handled;
    }

    // v3.77.46 (Rouge v10.1): su counter rompe la lengua en seco (= al
    // de Knuckles); sin ventana, la EVA de control puede esquivarla
    if (g_iPlayerCharIdx[victim] == ROUGE_INDEX)
    {
        if (Rouge_Countering(victim) && Rouge_SmokerCounter(victim, attacker)) return Plugin_Handled;
        if (Rouge_EvadeControl(victim, attacker, "lengua del smoker")) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnStartCarryingVictim(int victim, int attacker)
{
    // v6.5 Sonic: el carry del charger no arranca (bola / gracia /
    // 30 anillos de la tabla del owner)
    if (Sonic_ChargerGuard(victim)) return Plugin_Handled;

    // v3.77.28 (Metal v5.3): el charger TAMPOCO carga a un Metal en
    // plena embestida (este es el forward real; el guard de la 3.77.27
    // vivía en un "L4D_OnChargerImpact_Pre" fantasma que jamás corria).
    if (g_iPlayerCharIdx[victim] == METALSONIC_INDEX && Metal_ControlImmune(victim)) return Plugin_Handled;

    // v64: Amy en plena embestida: la carga del charger NUNCA empieza
    // (contra instantanea portada del sistema de Knuckles, a petición
    // del usuario): el charger sale por delante empujado.
    if (Amy_GrabCounter(victim, attacker)) return Plugin_Handled;

    if (Knux_IsValidClient(victim) && g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && g_bKnuxCountering[victim])
    {
        Knuckles_CheckSpecialCounter(victim, attacker);
        return Plugin_Handled; 
    }

    // v2.1 Kolossos: el bloqueo detecta la carga del charger AL
    // INSTANTE — el carry nunca arranca y el charger sale contraado
    if (Kolossos_PlayerIs(victim) && Kolossos_BlockActive(victim))
    {
        Kolossos_BlockEnd(victim);
        Kolossos_BlockCounter(victim, attacker, attacker);
        PrintCenterText(victim, "BLOQUEO! Carga rota al instante");
        return Plugin_Handled;
    }

    // v3.77.46 (Rouge v10.1): idem — counter pleno o EVA del carry
    if (g_iPlayerCharIdx[victim] == ROUGE_INDEX)
    {
        if (Rouge_Countering(victim) && Rouge_SpecialCounter(victim, attacker)) return Plugin_Handled;
        if (Rouge_EvadeControl(victim, attacker, "carry del charger")) return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D2_OnSlammedSurvivor(int victim, int attacker, bool &bWallSlam, bool &bDeadlyCharge)
{
    // v6.5 Sonic: el slam del charger (incluido el tropiezo de la
    // tabla del owner) se esquiva igual que su carry
    if (Sonic_ChargerSlamGuard(victim))
    {
        bWallSlam = false;
        bDeadlyCharge = false;
        return Plugin_Handled;
    }

    // v64: Amy en plena embestida: ni el slam del charger la tumba (el
    // charger ya fue contraado en el impacto, antes de que le afecte).
    if (Amy_IsImpulseImmune(victim)) return Plugin_Handled;

    if (Knux_IsValidClient(victim) && g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && g_bKnuxCountering[victim])
    {
        // v65-OM: rebote de la contra — pulso BLANCO + CounterBounce
        Knux_CounterBlockFx(victim, KNUX_SOUND_COUNTER_HIT);
        return Plugin_Handled;
    }

    // v2.1 Kolossos: ni el slam del charger lo tumba con el bloqueo
    // puesto — absorbido en seco
    if (Kolossos_PlayerIs(victim) && Kolossos_BlockActive(victim))
    {
        bWallSlam = false;
        bDeadlyCharge = false;
        return Plugin_Handled;
    }

    // v3.77.46 (Rouge v10.1): el counter de Rouge la deja plantada; la
    // EVA esquiva el slam entero (receta del guard de Sonic de arriba)
    if (g_iPlayerCharIdx[victim] == ROUGE_INDEX)
    {
        if (Rouge_Countering(victim))
        {
            Rouge_MarkCounterHit(victim);
            Rouge_CounterBlockFx(victim);
            bWallSlam = false;
            bDeadlyCharge = false;
            return Plugin_Handled;
        }
        if (Rouge_EvadeControl(victim, attacker, "slam del charger"))
        {
            bWallSlam = false;
            bDeadlyCharge = false;
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}

public Action L4D2_OnPlayerFling(int client, int attacker, float vecDir[3])
{
    // v6.5 Sonic: en bola el tank NO lo empuja (inmunidad D); fuera de
    // bola el empujon se bloquea si va a ser absorbido por anillos
    if (Sonic_FlingGuard(client, attacker)) return Plugin_Handled;

    // v3.77.28 (Metal v5.3): ningún fling del motor derriba a un Metal
    // en plena embestida (forward real; antes el guard vivía en un
    // "L4D_OnFling" fantasma que nunca se disparaba).
    if (g_iPlayerCharIdx[client] == METALSONIC_INDEX && Metal_ControlImmune(client)) return Plugin_Handled;

    // v64: Amy en plena embestida: ningún empujon del motor la desvia
    // (la velocidad se reafirma, pero así ni la animación de tropiezo).
    if (Amy_IsImpulseImmune(client)) return Plugin_Handled;

    if (Knux_IsValidClient(client) && g_iPlayerCharIdx[client] == KNUCKLES_INDEX && g_bKnuxCountering[client])
    {
        PrintCenterText(client, "⚓ [COUNTER] ¡INMOVILIDAD!");
        // v65-OM: rebote de la contra — pulso BLANCO + CounterBounce
        Knux_CounterBlockFx(client, KNUX_SOUND_COUNTER_HIT);
        return Plugin_Handled;
    }

    // v2.1 Kolossos: EL ANTI-EMPUJE — con el bloqueo activo o dentro
    // de la ventana del counter NINGUN fling del motor lo mueve (el
    // tank no puede empujarlo durante la contra, receta Knuckles)
    if (Kolossos_PlayerIs(client) && Kolossos_BlockGuard(client))
    {
        PrintCenterText(client, "⚓ [BLOQUEO] ¡INMOVILIDAD!");
        return Plugin_Handled;
    }

    // v3.77.46 (Rouge v10.1): ningún empujon del motor la mueve durante
    // su Contragolpe (la garra del tank lleva SU entrada con desarme en
    // el TankClaw_OnPlayerHit_Pre del manager)
    if (g_iPlayerCharIdx[client] == ROUGE_INDEX && Rouge_Countering(client))
    {
        Rouge_MarkCounterHit(client);
        Rouge_CounterBlockFx(client);
        PrintCenterText(client, "⚓ [CONTRAGOLPE] ¡INMOVILIDAD!");
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action L4D_OnVomitedUpon(int victim, int &attacker, bool &boomerExplosion)
{
    // v6.5 Sonic: JAMÁS queda ciego — con anillos esquiva la bilis
    // ENTERA (spray 6 / explosión 15, sin gracia); sin anillos la
    // bilis cae pero se le LIMPIA al instante (cleanup estilo Poppy)
    if (Sonic_VomitDodge(victim, boomerExplosion)) return Plugin_Handled;

    // v5.2-OM (Eggman): mientras el ESCUDO está arriba, el doctor es
    // INMUNE al vómito del boomer (la spitter ya estaba cubierta: el
    // Eggmobile bloquea el DMG_ACID 24/7)
    if (Eggman_VomitShield(victim)) return Plugin_Handled;

    // v69: Amy refleja el vómito SOLO si tiene el poder "Anti-Vómito"
    // activado en el menú Mastery (hasta v68 era fijo/SIEMPRE). Si esta
    // apagado, la bilis del boomer la afecta normal.
    // v70: su contra ya difiere los efectos (fuera de este hook).
    if (Amy_VomitCounter(victim, attacker)) return Plugin_Handled;

    if (Knux_IsValidClient(victim) && g_iPlayerCharIdx[victim] == KNUCKLES_INDEX && g_bKnuxCountering[victim])
    {
        // v70: SOLO bilis de BOOMER VIVO del equipo infectado (las jars
        // de un compañero y la explosión de un boomer ya muerto dejan
        // de disparar efectos). El stagger y el daño van DIFERIDOS 0.1s:
        // matar al boomer aquí dentro, en medio de su propio spray,
        // re-entraba en OnVomitedUpon con la explosión del pop (crash
        // ocasional del motor).
        if (Knux_IsValidClient(attacker)
            && GetClientTeam(attacker) == TEAM_INFECTED
            && GetEntProp(attacker, Prop_Send, "m_zombieClass") == 2)
        {
            // v65-OM: CounterBounce auténtico + pulso BLANCO del bloqueo
            Knux_CounterBlockFx(victim, KNUX_SOUND_COUNTER_HIT);
            PrintCenterText(victim, "🤢 [COUNTER] ¡VÓMITO REFLEJADO!");

            DataPack dp = new DataPack();
            dp.WriteCell(GetClientUserId(attacker));
            dp.WriteCell(GetClientUserId(victim));
            CreateTimer(0.1, T_KnuxVomitReflect, dp,
                        TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
        }
        return Plugin_Handled;
    }

    // v3.77.46 (Rouge v10.1): EVA como la de Sonic — el vómito TAMBIÉN
    // se esquiva con los dados ("Podrá evitar agarres vomitos de
    // boomer"); y con el Contragolpe activo se REFLEJA entero (= al de
    // Knuckles: el boomer recibe SU PROPIA bilis)
    if (g_iPlayerCharIdx[victim] == ROUGE_INDEX)
    {
        if (Rouge_VomitCounter(victim, attacker)) return Plugin_Handled;
        if (Rouge_EvadeControl(victim, attacker, "vómito del boomer")) return Plugin_Handled;
    }
    return Plugin_Continue;
}

// v70: aplicación diferida de la contra de vómito de Knuckles (userid +
// NO_MAPCHANGE + DATA_HNDL_CLOSE: cero handles guardados). Re-valida al
// dispararse: si el boomer murió en la ventana de 0.1s (le disparó el
// equipo), la contra se disuelve sin tocar cadáveres. El stagger sigue
// siendo inmediato AL APLICARSE (diseño del counter de Knuckles: solo
// que ya no se ejecuta dentro del hook del vómito).
public Action T_KnuxVomitReflect(Handle timer, DataPack pack)
{
    pack.Reset();
    int boomer = GetClientOfUserId(pack.ReadCell());
    int knux   = GetClientOfUserId(pack.ReadCell());
    // (el pack lo cierra TIMER_DATA_HNDL_CLOSE al terminar el timer)

    if (knux > 0 && IsClientInGame(knux)
        && Knux_IsValidClient(boomer)
        && GetClientTeam(boomer) == TEAM_INFECTED
        && GetEntProp(boomer, Prop_Send, "m_zombieClass") == 2)
    {
        // el boomer recibe SU PROPIA bilis (15s, igual que siempre)
        if (HasEntProp(boomer, Prop_Send, "m_itTimer"))
            SetEntPropFloat(boomer, Prop_Send, "m_itTimer", GetGameTime() + 15.0);

        float vAttacker[3], vVictim[3], vPush[3];
        GetClientAbsOrigin(boomer, vAttacker); GetClientAbsOrigin(knux, vVictim);

        MakeVectorFromPoints(vVictim, vAttacker, vPush);
        NormalizeVector(vPush, vPush);
        ScaleVector(vPush, 800.0); vPush[2] = 300.0;

        // v61: SIStagger_Auto + lanzamiento manual (el Fling crudo
        // era un crash documentado del motor fuera de su contexto)
        SIStagger_Auto(boomer, knux, vVictim);
        TeleportEntity(boomer, NULL_VECTOR, NULL_VECTOR, vPush);
        Knux_DisableInfectedAbility(boomer, 5.0); // Cooldown forzado (antes del daño)
        OM_AbilityDamage(boomer, knux, 100.0, DMG_ACID);

        PrintCenterText(boomer, "🤮 ¡TE HAS VOMITADO A TI MISMO!");
    }
    return Plugin_Stop;
}

// ===================================================================================
// OTROS HOOKS EXISTENTES
// ===================================================================================

public bool Knuckles_IsPhysicsImmune(int client)
{
    if (!Knux_IsValidClient(client) || g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return false;
    if (g_bKnuxCountering[client] || GetEngineTime() < g_fKnuxExtendedImmunity[client]) return true;
    return false;
}

public bool Knuckles_CheckTankCounter(int tank, int player)
{
    if (Knux_IsValidClient(player) && g_bKnuxCountering[player])
    {
        // v65-OM: CounterBounce auténtico + pulso BLANCO del bloqueo
        Knux_CounterBlockFx(player, KNUX_SOUND_COUNTER_HIT);
        g_fKnuxDisarmTank[tank] = GetEngineTime() + 5.0; 
        g_fKnuxExtendedImmunity[player] = GetEngineTime() + 3.0;
        
        float zeroVel[3] = {0.0, 0.0, 0.0};
        TeleportEntity(player, NULL_VECTOR, NULL_VECTOR, zeroVel);
        SetEntityMoveType(player, MOVETYPE_NONE);
        
        CreateTimer(0.2, T_RestoreMovement, GetClientUserId(player));
        CreateTimer(0.5, T_RemoveGodMode, GetClientUserId(player));
        SetEntProp(player, Prop_Data, "m_takedamage", 0); 
        
        // v77: EL UPPERCUT — el tank TAMBIÉN sale volando (pedido del
        // owner: "knuckles su counter es un uppercut hacia arriba").
        // El desarme de 5s y la inmunidad de Knuckles quedan intactos:
        // la garra se come el uppercut y el tank pierde 3s de acción.
        // DIFERIDO 0.05s (este counter corre DENTRO del callback de
        // dano — nada de spawns ahi; la receta de los agarres).
        float vPlayer[3]; GetClientAbsOrigin(player, vPlayer);
        DataPack tpack = new DataPack();
        tpack.WriteCell(GetClientUserId(player));
        tpack.WriteCell(GetClientUserId(tank));
        CreateTimer(0.05, T_KnuxCounterTank, tpack,
                    TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
        
        PrintCenterText(player, "🛡️ TANK BLOQUEADO! (3s Inmunidad)");
        return true;
    }
    return false;
}

public Action T_RestoreMovement(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client)) SetEntityMoveType(client, MOVETYPE_WALK);
    return Plugin_Stop;
}

public Action T_RemoveGodMode(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client)) SetEntProp(client, Prop_Data, "m_takedamage", 2); 
    return Plugin_Stop;
}

// ============================================================
//  v77 - EL UPPERCUT DE LA CONTRA (receta compartida del martillo
//  v106, dirección UPPERCUT): dano AMPLIFICADO primero
//  (OM_AbilityDamage: hibrido x2 + % vs jefes); si MATA, el cadaver
//  sale volando (copia Rouge generalizada); si SOBREVIVE: OM_Stun
//  (knu_counter_ragdoll s) + RAGDOLL VOLADOR mayormente HACIA
//  ARRIBA + separación (el uppercut de Knuckles LATE hacia el
//  cielo — lo contrario de la patada baja de Rouge). Devuelve false
//  si el ragdoll está apagado (knu_counter_ragdoll 0).
// ============================================================
bool Knuckles_CounterUppercut(int knux, int enemy, const float kPos[3])
{
    if (g_cvKnuxCounterRagdoll == null || g_cvKnuxCounterRagdoll.FloatValue <= 0.0)
        return false;

    // dirección del uppercut: mayormente ARRIBA + separación
    float ePos[3], dir[3];
    GetClientAbsOrigin(enemy, ePos);
    MakeVectorFromPoints(kPos, ePos, dir);
    dir[2] = 1.0;                     // el eje vertical DOMINA el lanzamiento
    NormalizeVector(dir, dir);

    // dano primero (orden martillo v106), amplificado
    OM_AbilityDamage(enemy, knux, 200.0, DMG_CLUB);

    if (!IsPlayerAlive(enemy))
    {
        // letal: el cadaver vuela (copia Rouge generalizada sonic v6.35)
        Sonic_DeadFlingCopy(enemy, dir, g_cvKnuxCounterFling.FloatValue, false);
        return true;
    }

    if (OM_Stun(enemy, g_cvKnuxCounterRagdoll.FloatValue, knux, 0.0, DMG_OM_CLUB, true))
    {
        Sonic_SpawnFlingRagdollEx(enemy, dir,
                                  g_cvKnuxCounterFling.FloatValue, 0.45, 900.0);
        PrintCenterText(knux, "UPPERCUT! %.1fs de ragdoll", g_cvKnuxCounterRagdoll.FloatValue);
    }
    else
    {
        // iframes: al menos el empujon físico clasico
        float push[3];
        push[0] = dir[0] * 800.0;
        push[1] = dir[1] * 800.0;
        push[2] = 400.0;
        TeleportEntity(enemy, NULL_VECTOR, NULL_VECTOR, push);
    }
    return true;
}

// v77: el timer diferido del UPPERCUT al tank
public Action T_KnuxCounterTank(Handle timer, DataPack pack)
{
    pack.Reset();
    int player = GetClientOfUserId(pack.ReadCell());
    int tank   = GetClientOfUserId(pack.ReadCell());
    delete pack;

    if (Knux_IsValidClient(player) && Knux_IsValidClient(tank) && IsPlayerAlive(tank))
    {
        float vPlayer[3];
        GetClientAbsOrigin(player, vPlayer);
        if (!Knuckles_CounterUppercut(player, tank, vPlayer))
        {
            // ragdoll apagado (knu_counter_ragdoll 0): el counter de
            // tank clasico (stagger + empujon de mirada)
            float push[3]; GetClientEyeAngles(player, push);
            GetAngleVectors(push, push, NULL_VECTOR, NULL_VECTOR); ScaleVector(push, 1000.0); push[2] = 400.0;
            SIStagger_Auto(tank, player, vPlayer);
            TeleportEntity(tank, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
    return Plugin_Stop;
}

// v77: los timers diferidos del counter de entidades (la misma receta
// de T_KnuxHardStopAttacker: NADA de spawnear ragdolls dentro del
// callback de dano)
public Action T_KnuxCounterCommon(Handle timer, DataPack pack)
{
    pack.Reset();
    int ent = EntRefToEntIndex(pack.ReadCell());
    float dir[3];
    dir[0] = pack.ReadFloat(); dir[1] = pack.ReadFloat(); dir[2] = pack.ReadFloat();
    delete pack;

    if (ent > 0 && IsValidEntity(ent))
        Sonic_DeadFlingCopy(ent, dir, 500.0, true);
    return Plugin_Stop;
}

public Action T_KnuxCounterWitch(Handle timer, DataPack pack)
{
    pack.Reset();
    int ent = EntRefToEntIndex(pack.ReadCell());
    float dir[3];
    dir[0] = pack.ReadFloat(); dir[1] = pack.ReadFloat(); dir[2] = pack.ReadFloat();
    delete pack;

    if (ent > 0 && IsValidEntity(ent))
        Sonic_SpawnWitchRagdoll(ent, dir);
    return Plugin_Stop;
}

// DETENCION ABSOLUTA DEL CHARGER Y CAZADORES (CON RETRASO DE 0.05S)
public bool Knuckles_CheckSpecialCounter(int victim, int attacker)
{
    if (Knux_IsValidClient(victim) && g_bKnuxCountering[victim]) {
        if (Knux_IsValidClient(attacker)) {
            // v65-OM: CounterBounce.wav auténtico (lua l.555, vol 0.65) con
            // fallback + pulso BLANCO del bloqueo del UI
            Knux_CounterBlockFx(victim, KNUX_SOUND_COUNTER_HIT);
            
            // Fricción absoluta instantánea para evitar que el Charger pase de largo
            float zeroVel[3] = {0.0, 0.0, 0.0};
            float vAtt[3]; GetClientAbsOrigin(attacker, vAtt);
            TeleportEntity(attacker, vAtt, NULL_VECTOR, zeroVel);
            
            // Llamamos al Hard Stop retrasado por 0.05s para que el motor no sobreescriba el stagger
            DataPack pack = new DataPack();
            pack.WriteCell(GetClientUserId(victim));
            pack.WriteCell(GetClientUserId(attacker));
            CreateTimer(0.05, T_KnuxHardStopAttacker, pack, TIMER_FLAG_NO_MAPCHANGE);
            
            PrintCenterText(victim, "⛔ ¡ATAQUE DESTRUIDO EN SECO!");
        }
        return true; 
    }
    return false;
}

public Action T_KnuxHardStopAttacker(Handle timer, DataPack pack)
{
    pack.Reset();
    int victim = GetClientOfUserId(pack.ReadCell());
    int attacker = GetClientOfUserId(pack.ReadCell());
    delete pack;

    if (Knux_IsValidClient(victim) && Knux_IsValidClient(attacker))
    {
        float vPos[3];
        GetClientAbsOrigin(victim, vPos);

        // v77: EL UPPERCUT (receta compartida): dano amplificado +
        // stun-ragdoll vertical. La limpieza de punteros y el cd
        // forzado siguen INTACTOS (abajo).
        if (!Knuckles_CounterUppercut(victim, attacker, vPos))
        {
            // ragdoll apagado: la devolución clasica del v61
            float vAttacker[3], push[3];
            GetClientAbsOrigin(attacker, vAttacker);
            MakeVectorFromPoints(vPos, vAttacker, push);
            NormalizeVector(push, push);
            ScaleVector(push, 800.0);
            push[2] = 400.0;

            // 1. Stagger nativo: detiene la carga del Charger en seco.
            SIStagger_Auto(attacker, victim, vPos);

            // 2. Lanzamiento físico (v61: manual — el Fling crudo era un
            // crash documentado del motor al combinarse con el stagger)
            TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, push);

            // 3. Dano (amplificado v77)
            OM_AbilityDamage(attacker, victim, 200.0, DMG_CLUB);
        }
        
        // 4. Limpieza de punteros forzados (Desvinculación absoluta)
        SetEntPropEnt(victim, Prop_Send, "m_pounceAttacker", -1);
        SetEntPropEnt(victim, Prop_Send, "m_jockeyAttacker", -1);
        SetEntPropEnt(victim, Prop_Send, "m_carryAttacker", -1);
        SetEntPropEnt(victim, Prop_Send, "m_pummelAttacker", -1);
        
        // 5. Cooldown forzado
        Knux_DisableInfectedAbility(attacker, 5.0);
    }
    return Plugin_Stop;
}

// Smoker Counter Inmunidad Pura (CON RETRASO DE 0.05S)
public bool Knuckles_HandleSmokerCounter(int victim, int smoker)
{
    if (Knux_IsValidClient(victim) && g_bKnuxCountering[victim]) {
        // v65-OM: CounterBounce auténtico + pulso BLANCO del bloqueo
        Knux_CounterBlockFx(victim, KNUX_SOUND_COUNTER_HIT);
        
        if (Knux_IsValidClient(smoker)) {
            DataPack pack = new DataPack();
            pack.WriteCell(GetClientUserId(victim));
            pack.WriteCell(GetClientUserId(smoker));
            CreateTimer(0.05, T_KnuxHardStopSmoker, pack, TIMER_FLAG_NO_MAPCHANGE);
        }
        
        PrintCenterText(victim, "🛡️ ¡INMUNE AL SMOKER!");
        return true; 
    }
    return false;
}

public Action T_KnuxHardStopSmoker(Handle timer, DataPack pack)
{
    pack.Reset();
    int victim = GetClientOfUserId(pack.ReadCell());
    int smoker = GetClientOfUserId(pack.ReadCell());
    delete pack;

    if (Knux_IsValidClient(victim) && Knux_IsValidClient(smoker)) {
        float vPos[3]; GetClientAbsOrigin(victim, vPos);
        // v60: stagger SEGURO (auto-recuperación: ya no queda tirado)
        SIStagger_Auto(smoker, victim, vPos);
        Knux_DisableInfectedAbility(smoker, 5.0);
    }
    return Plugin_Stop;
}

// Touch Intercept: Backup de Choque para Slam y Counter
public Action Knux_OnTouch(int client, int other)
{
    if (g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return Plugin_Continue;

    // Ground Slam Detonación Instantanea por chocar
    if (g_bKnuxSlamming[client]) 
    {
        Knux_PerformGroundSlam(client);
        return Plugin_Continue;
    }

    // COUNTER AGRESIVO de Colisión (Hunter/Jockey Fallback)
    if (g_bKnuxCountering[client] && other > 0 && other <= MaxClients)
    {
        if (IsClientInGame(other) && GetClientTeam(other) == TEAM_INFECTED)
        {
            int zClass = GetEntProp(other, Prop_Send, "m_zombieClass");
            if (zClass == 6 || ((zClass == 3 || zClass == 5) && !(GetEntityFlags(other) & FL_ONGROUND)))
            {
                Knuckles_CheckSpecialCounter(client, other);
                return Plugin_Handled; 
            }
        }
    }

    return Plugin_Continue;
}

// =====================================================================
// v70-OM: TODO EL PARRY DE PROYECTILES DEL MANAGER ELIMINADO (delegado
// al VScript): el chch_parrying.nut v2.2 es el ejecutor (universal +
// cono + granadas + props + enemigos con cooldown) y el Parry.smx v2.1
// le abre la ventana al detectar el shove-parry (ChCh_KnxNotify ON/OFF:
// "knuckles está en parry" / "knux termino parry"). Aquí vivian
// Knux_ParryConeOK/Scan/Reflect/WatchRock, la lista de spits devueltos
// (Find/Mark), Knux_Event_SpitBurst + T_KnuxSpitBurstBoom, el watchdog
// T_KnuxParryWatch, T_KnuxKillEnt y Knux_ParryExplosion — el camino
// del crash del charco acido muere de raíz con ellos.
// =====================================================================

// =====================================================================
// v67-OM: FUEGO REAL EN LOS PUÑOS del nivel 3 (owner: "puedes colocarle
// 2 efectos de fuego en los puños — lo dice el propio lua de gmod").
// El lua (l.1123-1190) pone el efecto Knuckles_FireOrb en CADA MANO (los
// huesos LeftHand/RightHand) y el Knuckles_firering al llenar: aquí la
// ESPIRAL es la exacta del effects lua (l.319-484: radio 35->0, 2
// vueltas, ciclo 0.9s, onda ~18 Hz, color fuego 255/120-245/30) dibujada
// con beams TE + material om_knux_flame (blaze flame del pack OM), un
// nucleo env_sprite de llama por mano y el ANILLO al alcanzar el nivel 3.
// =====================================================================
// mata el fuego de los puños (release/cancel/reset/muerte)
void Knux_KillFireOrbs(int client)
{
    for (int k = 0; k < 2; k++)
    {
        if (g_iKnuxOrbEnt[client][k] != 0)
        {
            int orb = EntRefToEntIndex(g_iKnuxOrbEnt[client][k]);
            if (orb != INVALID_ENT_REFERENCE && IsValidEntity(orb)) AcceptEntityInput(orb, "Kill");
            g_iKnuxOrbEnt[client][k] = 0;
        }
        g_bKnuxFlameHasPrev[client][k] = false;   // v67: el trail arranca fresco
    }
    g_fKnuxFlameStart[client] = 0.0;              // v67: espiral nueva
}

// crea (o re-crea si murió) el NUCLEO de fuego de una mano — v67: material
// om_knux_flame (blaze flame del OM); sin el archivo montado cae al
// glow01 naranja de la v66 (gate del patron om_bluesmoke)
int Knux_SpawnFireOrb(float pos[3])
{
    int orb = CreateEntityByName("env_sprite");
    if (orb == -1) return 0;
    if (g_iKnuxFlameSprite != 0)
    {
        DispatchKeyValue(orb, "model", "materials/icons/om_knux_flame.vmt");
        DispatchKeyValue(orb, "rendercolor", "255 165 70");
        DispatchKeyValue(orb, "scale", "0.30");
    }
    else
    {
        DispatchKeyValue(orb, "model", "materials/sprites/glow01.vmt");
        DispatchKeyValue(orb, "rendercolor", "255 140 0");   // fallback v66
        DispatchKeyValue(orb, "scale", "0.35");
    }
    DispatchKeyValue(orb, "rendermode", "9");            // aditivo
    DispatchKeyValue(orb, "renderamt", "255");
    DispatchSpawn(orb);
    TeleportEntity(orb, pos, NULL_VECTOR, NULL_VECTOR);
    return EntIndexToEntRef(orb);
}

// posición de la mano k (offsets del cuerpo — el nucleo y la espiral viven aquí)
void Knux_HandPos(int client, int k, float fwd[3], float right[3], float hand[3])
{
    float base[3]; GetClientAbsOrigin(client, base);
    float side = (k == 0) ? KNUX_ORB_SIDE : -KNUX_ORB_SIDE;
    hand[0] = base[0] + fwd[0] * KNUX_ORB_FORWARD + right[0] * side;
    hand[1] = base[1] + fwd[1] * KNUX_ORB_FORWARD + right[1] * side;
    hand[2] = base[2] + KNUX_ORB_HEIGHT;
}

void Knux_FireOrbs(int client)
{
    if (!g_cvKnuxFistFire.BoolValue) return;   // v67: palanca del fuego
    float now = GetEngineTime();
    if (now < g_fKnuxNextOrbT[client]) return;
    g_fKnuxNextOrbT[client] = now + KNUX_ORB_EVERY;
    if (g_fKnuxFlameStart[client] <= 0.0) g_fKnuxFlameStart[client] = now;

    float yawAng[3], fwd[3], right[3];
    yawAng[0] = 0.0; yawAng[1] = g_fKnuxBodyYaw[client]; yawAng[2] = 0.0;
    GetAngleVectors(yawAng, fwd, right, NULL_VECTOR);

    for (int k = 0; k < 2; k++)
    {
        float hand[3];
        Knux_HandPos(client, k, fwd, right, hand);

        // nucleo: el corazon de llama de la mano
        int orb = (g_iKnuxOrbEnt[client][k] != 0) ? EntRefToEntIndex(g_iKnuxOrbEnt[client][k]) : INVALID_ENT_REFERENCE;
        if (orb == INVALID_ENT_REFERENCE || !IsValidEntity(orb))
        {
            g_iKnuxOrbEnt[client][k] = Knux_SpawnFireOrb(hand);
        }
        else
        {
            TeleportEntity(orb, hand, NULL_VECTOR, NULL_VECTOR);
        }

        // ---- la ESPIRAL Knuckles_FireOrb (effects lua l.319-484) ----
        float t = (now - g_fKnuxFlameStart[client]) / KNUX_FLAME_CYCLE;
        if (t >= 1.0)
        {
            // reinicio del ciclo: angulo y sentido aleatorios (lua l.333-334)
            g_fKnuxFlameStart[client] = now;
            t = 0.0;
            g_fKnuxFlameAng[client][k] = float(GetRandomInt(0, 359));
            g_iKnuxFlameDir[client][k] = (GetRandomInt(0, 1) == 0) ? -1 : 1;
            g_bKnuxFlameHasPrev[client][k] = false;
        }
        float radius = KNUX_FLAME_RADIUS * (1.0 - t);
        if (radius < KNUX_FLAME_FLOOR_R) radius = KNUX_FLAME_FLOOR_R;
        float spA = g_fKnuxFlameAng[client][k] + float(g_iKnuxFlameDir[client][k]) * t * KNUX_FLAME_ROTATIONS * 360.0;
        float rad = DegToRad(spA);
        // la onda del lua (l.388): sin(CurTime()*18 + i) * 4
        float wave = Sine(now * KNUX_FLAME_WAVEHZ + float(k)) * KNUX_FLAME_WAVEAMP;
        float p[3];
        p[0] = hand[0] + Cosine(rad) * (radius + wave);
        p[1] = hand[1] + Sine(rad)   * (radius + wave);
        p[2] = hand[2] + Sine(now * KNUX_FLAME_WAVEHZ + float(k) + 2.0) * 3.0;

        // el trail: beam del punto anterior al actual — el GMod encadena
        // 25 segmentos (l.372-407); a 20 Hz con vida 0.3s viven ~6 por
        // mano y la espiral queda envuelta en llama (mismo canal TE que
        // las estrellas del OM_Stun, cero entidades nuevas)
        if (g_iKnuxFlameSprite != 0 && g_bKnuxFlameHasPrev[client][k])
        {
            int alpha = RoundToNearest(160.0 * (1.0 - t) + 60.0);
            int col[4];
            col[0] = 255; col[1] = 130; col[2] = 40; col[3] = alpha;
            TE_SetupBeamPoints(g_fKnuxFlamePrev[client][k], p, g_iKnuxFlameSprite,
                               0, 0, 0, KNUX_FLAME_BEAMLIFE,
                               KNUX_FLAME_BEAMW * (1.0 - t) + 2.0, 2.0, 1, 4.0,
                               col, 0);
            TE_SendToAll();
        }
        g_fKnuxFlamePrev[client][k][0] = p[0];
        g_fKnuxFlamePrev[client][k][1] = p[1];
        g_fKnuxFlamePrev[client][k][2] = p[2];
        g_bKnuxFlameHasPrev[client][k] = true;
    }
}

// v67-OM: el ANILLO de fuego del nivel 3 (Knuckles_firering del lua
// l.1179-1189, effects l.95-183): un anillo CONTRAYENDO por mano al
// alcanzar la carga máxima — TE puro, cero entidades
void Knux_FireRing(int client)
{
    if (!g_cvKnuxFistFire.BoolValue || g_iKnuxFlameSprite == 0) return;
    float yawAng[3], fwd[3], right[3];
    yawAng[0] = 0.0; yawAng[1] = g_fKnuxBodyYaw[client]; yawAng[2] = 0.0;
    GetAngleVectors(yawAng, fwd, right, NULL_VECTOR);

    for (int k = 0; k < 2; k++)
    {
        float hand[3];
        Knux_HandPos(client, k, fwd, right, hand);
        int col[4];
        col[0] = 255; col[1] = 170; col[2] = 50; col[3] = 220;
        TE_SetupBeamRingPoint(hand, 65.0, 10.0, g_iKnuxFlameSprite, 0, 0, 0,
                              0.45, 9.0, 0.0, col, 0, 0);
        TE_SendToAll();
    }
}

public Action Knux_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Knux_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != KNUCKLES_INDEX) return Plugin_Continue;

    if (g_bKnuxCharging[victim]) { damage *= g_cvKnuxDamageReduc.FloatValue; return Plugin_Changed; }

    if (GetEngineTime() < g_fKnuxExtendedImmunity[victim]) {
        damage = 0.0; return Plugin_Handled;
    }

    if (g_bKnuxCountering[victim] && attacker > 0) {
        // v74-OM (owner 2026-10-10: "O sea si detecta un ataque debe
        // counterearlo. Ya lo haces con los coomons xq no con los SI
        // con el resto? ya lo haces con el tank en si."): DETECTADO =
        // CONTRAATACADO. Nada de bloqueos mudos ni bloqueos bonitos:
        // cada golpe que toca la postura sale DEVUELTO con el counter
        // del suite (commons = 100 directos, tank = su counter, SI =
        // counter completo, witch = estatua congelada).
        if (attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == TEAM_INFECTED) {
            int zClass = GetEntProp(attacker, Prop_Send, "m_zombieClass");
            if (zClass == 8) {
                Knuckles_CheckTankCounter(attacker, victim);
            }
            else
            {
                // v74-OM: el básico de un especial (smoker/boomer/
                // hunter/spitter/jockey/charger) sale con EL COUNTER
                // COMPLETO — la misma receta de los agarres y la
                // embestida aérea (Knuckles_CheckSpecialCounter):
                // endurecimiento instantaneo + hard stop diferido
                // 0.05s (stagger SEGURO + empuje 800 + 200 de dano +
                // limpieza de punteros de pin + 5s sin habilidad). El
                // propio stagger (1.8s) marca el ritmo: ese infectado
                // NO vuelve a garbear tan rápido.
                Knuckles_CheckSpecialCounter(victim, attacker);
            }
        }
        char cls[32]; GetEntityClassname(attacker, cls, sizeof(cls));
        if (StrEqual(cls, "infected")) {
            // v77: común — dano amplificado AQUÍ (probado) + el cuerpo
            // volando DIFERIDO 0.05s (nada de spawnear DENTRO del
            // callback de dano — la receta de los agarres de aquí mismo)
            float vPos[3], ePos[3], dir[3];
            GetClientAbsOrigin(victim, vPos);
            GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", ePos);
            MakeVectorFromPoints(vPos, ePos, dir);
            dir[2] = 0.8;
            NormalizeVector(dir, dir);
            OM_AbilityDamage(attacker, victim, 100.0, DMG_CLUB);
            if (!IsValidEntity(attacker) || GetEntProp(attacker, Prop_Send, "m_iHealth") <= 0)
            {
                DataPack dpack = new DataPack();
                dpack.WriteCell(EntIndexToEntRef(attacker));
                dpack.WriteFloat(dir[0]); dpack.WriteFloat(dir[1]); dpack.WriteFloat(dir[2]);
                CreateTimer(0.05, T_KnuxCounterCommon, dpack,
                            TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
            }
        }
        else if (StrEqual(cls, "witch")) {
            // v74-OM: la garra de la witch TAMBIÉN se contraataca —
            // ESTATUA en seco (Sonic_WitchStun 2s, la receta del
            // wall-slam del suite: FL_FROZEN + estrellas) + empujon.
            // v77: su doble también vuela — DIFERIDO (spawn fuera del
            // callback de dano).
            if (IsValidEntity(attacker) && GetEngineTime() >= g_fKnuxBlockFxNext[victim])
            {
                g_fKnuxBlockFxNext[victim] = GetEngineTime() + 0.4;
                Knux_CounterBlockFx(victim, KNUX_SOUND_COUNTER_HIT);
                Sonic_WitchStun(attacker, 2.0);
                float vK[3], vW[3], wPush[3], wDir[3];
                GetClientAbsOrigin(victim, vK);
                GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", vW);
                MakeVectorFromPoints(vK, vW, wDir);
                wDir[2] = 1.0;   // v77: vertical (uppercut)
                NormalizeVector(wDir, wDir);
                wPush[0] = wDir[0] * 600.0;
                wPush[1] = wDir[1] * 600.0;
                wPush[2] = 250.0;
                TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, wPush);

                DataPack wpack = new DataPack();
                wpack.WriteCell(EntIndexToEntRef(attacker));
                wpack.WriteFloat(wDir[0]); wpack.WriteFloat(wDir[1]); wpack.WriteFloat(wDir[2]);
                CreateTimer(0.05, T_KnuxCounterWitch, wpack,
                            TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
                PrintCenterText(victim, "🧊 ¡WITCH CONGELADA EN SECO!");
            }
        }
        damage = 0.0; 
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

// ============================================================================
//  v63 (R30) - PROPS DEL MAPA: "mismo tipo de sistema que amy (sin la
//  parte de convertir objetos en V)". Pedido literal del owner: el puño
//  (dash), el ground slam y las explosiones del Meteoro empujan OBJETOS
//  (props, autos y demas). La receta es LA MISMA del martillo de Amy:
//   1) liberar la física (EnableMotion / EnablePhysics / Wake),
//   2) EL GOLPE REAL: dano con FUERZA escalada por masa (la receta del
//      punetazo del tank: el motor aplica esa fuerza al cuerpo vphysics
//      y eso DESPIERTA al dormido) — Amy v75,
//   3) EL DESPERTADOR NATIVO: env_physexplosion con magnitude escalada
//      por masa y centro detraz-abajo (el empuje radial sale
//      adelante+arriba = "levantarlo del suelo y luego aventarlo") —
//      Amy v76 (la receta del plugin de autos explosivos del server),
//   4) el aventon (TeleportEntity sobre el cuerpo ya despierto) + volteo
//      aleatorio (m_angVelocity: el coche sale girando) — Amy v83.
//  SIN CONVERSION (regla v82 de Amy): solo objetos con V (VPHYSICS) de
//  fábrica. Los decorativos (prop_dynamic) NI SE TOCAN — quedan como el
//  mapa los puso. "Todo lo que tenga V en activo" = MOVETYPE_VPHYSICS.
// ============================================================================

// Escaneo agnostico UNA pasada (patron Amy v79 4c): cualquier "prop_*" /
// func_physbox con cuerpo V (VPHYSICS) activo dentro del radio. Los
// decorativos y los ragdolls quedan fuera (sin conversión, cuerpos fuera).
// Devuelve los índices encontrados (tope maxProps). Cero handles.
int Knux_FindVProps(const float center[3], float radius, int[] props, int maxProps)
{
    int n = 0;
    int maxEnt = GetMaxEntities();
    if (maxEnt <= MaxClients) maxEnt = 2048;
    for (int e = MaxClients + 1; e < maxEnt && n < maxProps; e++)
    {
        if (!IsValidEntity(e)) continue;

        static char cls[32];
        GetEntityClassname(e, cls, sizeof(cls));
        if (StrContains(cls, "prop_", false) != 0
            && !StrEqual(cls, "func_physbox", false)) continue;
        if (StrEqual(cls, "prop_ragdoll", false)) continue;          // cuerpos: fuera
        if (StrEqual(cls, "prop_dynamic", false)) continue;          // decorativo: SIN conversión
        if (StrEqual(cls, "prop_dynamic_override", false)) continue; // decorativo: SIN conversión
        if (GetEntityMoveType(e) != MOVETYPE_VPHYSICS) continue;     // sin V: no existe

        float pPos[3];
        GetEntPropVector(e, Prop_Send, "m_vecOrigin", pPos);
        if (GetVectorDistance(center, pPos) > radius) continue;

        props[n++] = e;
    }
    return n;
}

// El empuje completo (receta Amy v75+v76+v83, SIN conversión). dir debe
// venir normalizado y horizontal (la altura viaja en liftFrac). Devuelve
// true si el objeto fue empujado.
bool Knux_PushMapProp(int attacker, int prop, const float dir[3], float force, float liftFrac)
{
    if (!IsValidEntity(prop)) return false;

    // Doble guard (el escaneo ya filtro, pero esta función es pública al
    // modulo): decorativos y sin-V no se tocan NUNCA — el mapa manda.
    static char cls[32];
    GetEntityClassname(prop, cls, sizeof(cls));
    if (StrEqual(cls, "prop_dynamic", false)
        || StrEqual(cls, "prop_dynamic_override", false)
        || StrEqual(cls, "prop_ragdoll", false)) return false;
    if (GetEntityMoveType(prop) != MOVETYPE_VPHYSICS) return false;

    if (attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker)) attacker = 0;

    float pos[3];
    GetEntPropVector(prop, Prop_Send, "m_vecOrigin", pos);

    // 1) liberar la física COMPLETA: EnableMotion descongela props
    //    congelados por el mapa; Wake saca al cuerpo del sueño
    AcceptEntityInput(prop, "EnableMotion");
    AcceptEntityInput(prop, "EnablePhysics");
    AcceptEntityInput(prop, "Wake");

    // masa del cuerpo (default 100 kg si el prop no la publica — el mismo
    // fallback del martillo de Amy)
    float mass = 100.0;
    if (HasEntProp(prop, Prop_Data, "m_iMass"))
    {
        int m = GetEntProp(prop, Prop_Data, "m_iMass");
        if (m > 1) mass = float(m);
    }

    // 2) EL GOLPE REAL (receta Amy v75): fuerza = masa x empujon (mismo
    //    delta-v para cualquier objeto) + lift del 75%. Canon L4D2:
    //    golpear un auto con alarma la ACTIVA (igual que el tank).
    float forceVec[3];
    forceVec[0] = dir[0] * mass * KNUX_PROP_WAKE_FORCE;
    forceVec[1] = dir[1] * mass * KNUX_PROP_WAKE_FORCE;
    forceVec[2] = mass * KNUX_PROP_WAKE_FORCE * KNUX_PROP_WAKE_LIFT;
    SDKHooks_TakeDamage(prop, attacker, attacker, KNUX_PROP_WAKE_DMG,
                        DMG_CLUB, -1, forceVec, pos);

    // 3) EL DESPERTADOR NATIVO (receta Amy v76): env_physexplosion con
    //    magnitude ESCALADA POR MASA (mismo empujon físico para un bolso
    //    de 20 kg o un auto de 1500 kg; nunca menor que la base, tope
    //    25000) y radio que crece con el tamaño del cuerpo (tope 300).
    //    Centro detraz-abajo: el empuje radial sale adelante+arriba.
    if (g_cvKnuxPropBlast != null && g_cvKnuxPropBlast.FloatValue > 0.0)
    {
        float blastMag = g_cvKnuxPropBlast.FloatValue * (mass / 100.0);
        if (blastMag < g_cvKnuxPropBlast.FloatValue) blastMag = g_cvKnuxPropBlast.FloatValue;
        if (blastMag > 25000.0) blastMag = 25000.0;

        float blastRad = KNUX_PROP_BLAST_RAD;
        if (mass > 300.0 && blastRad < mass / 10.0) blastRad = mass / 10.0;
        if (blastRad > 300.0) blastRad = 300.0;

        float center[3];
        center[0] = pos[0] - dir[0] * 35.0;
        center[1] = pos[1] - dir[1] * 35.0;
        center[2] = pos[2] - 25.0;

        int ex = CreateEntityByName("env_physexplosion");
        if (ex != -1 && IsValidEntity(ex))
        {
            char sMag[16], sRad[16];
            IntToString(RoundToNearest(blastMag), sMag, sizeof(sMag));
            IntToString(RoundToNearest(blastRad), sRad, sizeof(sRad));
            DispatchKeyValue(ex, "magnitude", sMag);
            DispatchKeyValue(ex, "radius", sRad);
            DispatchSpawn(ex);
            TeleportEntity(ex, center, NULL_VECTOR, NULL_VECTOR);
            AcceptEntityInput(ex, "Explode");
            AcceptEntityInput(ex, "Kill");   // la explosión es sincrona: limpieza inmediata
        }
    }

    // 4) el aventon sobre el cuerpo YA despierto + volteo aleatorio
    float launch[3];
    launch[0] = dir[0] * force;
    launch[1] = dir[1] * force;
    launch[2] = force * liftFrac;
    if (launch[2] < 120.0) launch[2] = 120.0;   // pisito de arco (receta Amy)
    TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, launch);

    if (HasEntProp(prop, Prop_Data, "m_angVelocity"))
    {
        float spin[3];
        spin[0] = GetRandomFloat(-400.0, 400.0);
        spin[1] = GetRandomFloat(-400.0, 400.0);
        spin[2] = GetRandomFloat(-300.0, 300.0);
        SetEntPropVector(prop, Prop_Data, "m_angVelocity", spin);
    }

    return true;
}

// ============================================================================
//  v63 (R30) - BOOMER DIFERIDO: "el Boomer si es mandado a volar no
//  explotara de inmediato hará como la habilidad de amy será empujado y
//  explotara tiempo después". COPIA de la receta T_AmyBoomerBurst (v64):
//  el boomer sale VOLANDO con la mecha encendida y al vencer:
//   1) pop REAL del juego (9999: el motor suelta la bilis),
//   2) frasco de bilis en el punto (atrae a los comunes ahi),
//   3) empujon a los comunes cercanos (la onda del estallido).
// ============================================================================

public Action T_KnuxBoomerBurst(Handle timer, DataPack pack)
{
    pack.Reset();
    int boomer   = GetClientOfUserId(pack.ReadCell());
    int attacker = GetClientOfUserId(pack.ReadCell());
    // el pack lo cierra TIMER_DATA_HNDL_CLOSE al terminar el timer

    if (boomer <= 0 || !IsClientInGame(boomer) || !IsPlayerAlive(boomer)) return Plugin_Stop;
    if (GetEntProp(boomer, Prop_Send, "m_zombieClass") != 2) return Plugin_Stop;  // ya no es boomer

    float pos[3];
    GetClientAbsOrigin(boomer, pos);
    float vPos[3];
    vPos[0] = pos[0]; vPos[1] = pos[1]; vPos[2] = pos[2] + 40.0;

    // VFX + sonido: burst de boomer + explosión (patron Amy)
    Knux_VFX_Particle(vPos, "boomer_explode_Boomer");
    EmitSoundToAll(KNUX_SOUND_SKYBOOM, boomer, SNDCHAN_WEAPON, SNDLEVEL_RAIDSIREN);

    // 1) pop real del juego: matarlo con el golpe de Knuckles como fuente
    int src = (Knux_IsValidClient(attacker)) ? attacker : 0;
    SDKHooks_TakeDamage(boomer, src, src, 9999.0, DMG_CLUB);

    // 2) bilis en el punto del estallido (frasco de vómito)
    Knux_SpawnBileJar(attacker, vPos);

    // 3) onda del estallido: los comunes cercanos salen empujados
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float cPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", cPos);
        if (GetVectorDistance(pos, cPos) <= KNUX_BOOMER_PUSH_RAD)
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

// Frasco de bilis (vomitjar) en el punto del estallido (copia de la
// receta Amy_SpawnBileJar: si la entidad no existiera, no se crea — el
// pop del boomer ya dio el efecto base; cero riesgo).
void Knux_SpawnBileJar(int thrower, const float pos[3])
{
    int jar = CreateEntityByName("vomitjar_projectile");
    if (jar == -1) return;

    DispatchSpawn(jar);
    ActivateEntity(jar);
    if (thrower > 0 && thrower <= MaxClients && IsClientInGame(thrower))
    {
        if (HasEntProp(jar, Prop_Send, "m_hOwnerEntity"))
            SetEntPropEnt(jar, Prop_Send, "m_hOwnerEntity", thrower);
        if (HasEntProp(jar, Prop_Data, "m_hThrower"))
            SetEntPropEnt(jar, Prop_Data, "m_hThrower", thrower);
    }
    float drop[3];
    drop[0] = 0.0; drop[1] = 0.0; drop[2] = -100.0;
    TeleportEntity(jar, pos, NULL_VECTOR, drop);
}

// Particula temporal (patron Rouge_BlackWaveParticle / Amy_VFX_Particle):
// info_particle_system + kill por OnUser1. CERO handles.
void Knux_VFX_Particle(const float pos[3], const char[] name)
{
    int particle = CreateEntityByName("info_particle_system");
    if (!IsValidEntity(particle)) return;
    DispatchKeyValue(particle, "effect_name", name);
    DispatchSpawn(particle);
    ActivateEntity(particle);
    TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(particle, "Start");
    SetVariantString("OnUser1 !self:kill::3.0:1");
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");
}

// Registrar particulas en la tabla del motor (patron Rouge v9 /
// Amy PrecacheParticle). Si ya están (Amy las precachea), esto es un
// no-op inocuo — Knuckles queda autosuficiente.
void Knux_PrecacheParticle(const char[] name)
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

// ============================================================================
//  v63 (R30) - HABILIDAD 3 "METEOR STRIKE" (tecla C / sm_knux_sky /
//  sm_sjs_ability3). Pedido literal del owner:
//   * "como 3 habilidad Tendrá 2 variaciones":
//     - VARIACION AÉREA (cast en el aire): "este se elevara hasta cierta
//       distancia en el aire y luego en la dirección en la que mire puede
//       lanzarse hacia el objetivo (después de presionar C denuevo) Y
//       causara una mega explosión (hay una habilidad del tank q hace eso
//       creo que detonador creo)".
//     - VARIACION TERRESTRE (cast en el suelo): "este lanzara una (esfera
//       como lo que usa el escudo... o el escudo de sally) pero este
//       sería un proyectil que al impactar al suelo estallara (esta
//       explosión podrá mandar a volar props veiculos y todo lo que
//       tenga V en activo en este)".
//   * "El golpe podrá mandar a volar todo lo que no sea Especial (esto
//     incluye a la witch). Los especiales también son mandados a volar
//     (excepto al tank). aquí la distancia y la elevación varia
//     dependiendo el especial (y el peso que tu puedas deducir.)"
//   * "el Boomer si es mandado a volar no explotara de inmediato hará
//     como la habilidad de amy será empujado y explotara tiempo después."
//  NOTA (como la Onda Negra de Rouge): la mega explosión del "detonador"
//  del Super Tank NO se toca — la detonación es NATIVA de Knuckles.inc
//  (control total, patron Sally/Amy). El VScript del Super Tank va
//  INTACTO. SIN TEMBLOR (regla del owner R29 para todo el suite: cero
//  env_shake / cero ScreenShake).
// ============================================================================

// "y el peso que tu puedas deducir" — pesos deducidos del canon L4D2
// (multiplicador de la fuerza de vuelo: distancia y elevación por clase):
//   Jockey ~45 kg (1.25) | Hunter ~55 kg (1.15) | Spitter ~60 kg (1.05)
//   Smoker ~75 kg (1.00) | Boomer ~120 kg (0.85, + mecha diferida)
//   Charger ~150 kg (0.70) | Tank ~400+ kg: EXCLUIDO (no vuela)
float Knux_SkyWeight(int zclass)
{
    switch (zclass)
    {
        case 5:  return 1.25;   // Jockey: el más liviano — vuela más lejos y más alto
        case 3:  return 1.15;   // Hunter: cazador agil
        case 4:  return 1.05;   // Spitter
        case 1:  return 1.00;   // Smoker: la referencia
        case 2:  return 0.85;   // Boomer: pesado — y con mecha diferida
        case 6:  return 0.70;   // Charger: puro musculo, apenas despega
    }
    return 1.0;                 // desconocido: neutro
}

// Comando H3 (tecla C). SEGUNDA pulsación durante el apuntado = picada.
public Action Command_KnuxSkyStrike(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Knux_IsValidClient(client) || g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return Plugin_Handled;

    // en mitad de otra habilidad propia: no
    if (g_bKnuxCharging[client] || g_bKnuxCountering[client] || g_bKnuxSlamming[client]) return Plugin_Handled;

    // incapacitado/Agarrado: no (el PreThink lo limpiaria al frame)
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0
        || GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return Plugin_Handled;

    // SEGUNDA pulsación (fase de apuntado): LANZARSE hacia donde mira
    if (g_iKnuxSkyState[client] == KNUX_SKY_AIM)
    {
        Knux_SkyDive(client);
        return Plugin_Handled;
    }
    if (g_iKnuxSkyState[client] != KNUX_SKY_NONE) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fKnuxSkyCooldown[client])
    {
        PrintCenterText(client, "METEORO: recarga %.1fs", g_fKnuxSkyCooldown[client] - now);
        return Plugin_Handled;
    }
    g_fKnuxSkyCooldown[client] = now + g_cvKnuxSkyCD.FloatValue;

    if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // ---- VARIACION AÉREA: elevarse -> apuntar -> [C] lanzarse ----
        // (si estaba agarrado a una pared, se suelta: el cling congela
        // el movetype y la elevación necesita moverse)
        if (g_bKnuxClinging[client])
        {
            g_bKnuxClinging[client] = false;
            g_bKnuxGliding[client] = false;
            SetEntityMoveType(client, MOVETYPE_WALK);
        }
        g_bKnuxGliding[client] = false;

        g_iKnuxSkyState[client] = KNUX_SKY_ASCENT;
        g_fKnuxSkyStateStart[client] = now;
        g_fKnuxSkyHudT[client] = 0.0;
        float pos[3];
        GetClientAbsOrigin(client, pos);
        g_fKnuxSkyCastZ[client] = pos[2];   // base de la elevación

        EmitSoundToAll(KNUX_SOUND_CHARGE_1, client);
        PrintCenterText(client, "☄️ METEORO: ELEVÁNDOSE...");
    }
    else
    {
        // ---- VARIACION TERRESTRE: ESFERA DE FUEGO (proyectil) ----
        Knux_SkyBallLaunch(client);
    }
    return Plugin_Handled;
}

// Maquina de estados del meteoro (corre en Knux_PreThink; MANDA el frame
// cuando está activa: ni carga, ni planeo, ni pared).
void Knux_SkyThink(int client, int flags)
{
    float now = GetEngineTime();

    switch (g_iKnuxSkyState[client])
    {
        case KNUX_SKY_ASCENT:
        {
            // subida limpia: horizontal amortiguado, vertical constante
            // (la velocidad se re-afirma CADA think: ninguna gravedad la
            // frena — mismo truco del re-afirmado del arrastre de Rouge)
            float vel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            vel[0] *= 0.80;
            vel[1] *= 0.80;
            vel[2] = g_cvKnuxSkyAscend.FloatValue;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

            float pos[3];
            GetClientAbsOrigin(client, pos);

            // techo: trace brush-only hacia arriba (60u)
            float eye[3], upEnd[3];
            GetClientEyePosition(client, eye);
            upEnd[0] = eye[0]; upEnd[1] = eye[1]; upEnd[2] = eye[2] + 60.0;
            TR_TraceRay(eye, upEnd, MASK_SOLID_BRUSHONLY, RayType_EndPoint);
            bool ceiling = TR_DidHit();

            bool done = (pos[2] - g_fKnuxSkyCastZ[client] >= g_cvKnuxSkyHeight.FloatValue)
                        || ceiling
                        || (now - g_fKnuxSkyStateStart[client] > KNUX_SKY_MAX_ASCENT);
            if (done)
            {
                // FASE 2: apuntado clavado en el aire (hover estilo
                // agarre de pared: MOVETYPE_NONE = física congelada)
                float stop[3] = {0.0, 0.0, 0.0};
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, stop);
                SetEntityMoveType(client, MOVETYPE_NONE);
                g_iKnuxSkyState[client] = KNUX_SKY_AIM;
                g_fKnuxSkyStateStart[client] = now;
                g_fKnuxSkyHoverEnd[client] = now + g_cvKnuxSkyHover.FloatValue;
                EmitSoundToAll(KNUX_SOUND_CHARGE_1, client);
                PrintCenterText(client, "🔭 APUNTA y pulsa [C] para LANZARTE");
            }
            else if (now - g_fKnuxSkyHudT[client] > 0.25)
            {
                g_fKnuxSkyHudT[client] = now;
                PrintCenterText(client, "☄️ METEORO: ELEVÁNDOSE...");
            }
        }
        case KNUX_SKY_AIM:
        {
            // hover clavado: el movetype NONE del block de arriba congela
            // la física (la vista sigue libre para apuntar)
            if (now >= g_fKnuxSkyHoverEnd[client])
            {
                // ventana agotada: auto-lanzamiento hacia donde mire
                Knux_SkyDive(client);
                return;
            }
            if (now - g_fKnuxSkyHudT[client] > 0.5)
            {
                g_fKnuxSkyHudT[client] = now;
                PrintCenterText(client, "🔭 APUNTA y pulsa [C] (%.1fs)", g_fKnuxSkyHoverEnd[client] - now);
            }
        }
        case KNUX_SKY_DIVE:
        {
            // v64: EL VUELO ES DEL MOTOR. Un solo impulso al lanzarse
            // (Knux_SkyDive) y la gravedad hace el resto ("dara el
            // impulso pero caera por gravedad eventualmente"). NO se
            // re-afirma la velocidad: re-afirmarla borraba la gravedad
            // cada frame y lo dejaba flotando adelante-arriba hasta que
            // la tapa detonaba la explosión EN EL AIRE (el bug).
            float curVel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", curVel);

            // IMPACTO: tocar suelo (la gravedad lo baja: FL_ONGROUND),
            // estrellarse de frente (trace brush-only del paso HORIZONTAL:
            // el suelo NO cuenta aquí, lo aterriza ONGROUND y explota
            // "después de que este impacte en el suelo") o agotar la
            // tapa dura -> MEGA EXPLOSION
            float pos[3], next[3];
            GetClientAbsOrigin(client, pos);
            next[0] = pos[0] + curVel[0] * 0.06;
            next[1] = pos[1] + curVel[1] * 0.06;
            next[2] = pos[2];
            TR_TraceRay(pos, next, MASK_SOLID_BRUSHONLY, RayType_EndPoint);
            bool wall = TR_DidHit();

            if ((flags & FL_ONGROUND) || wall
                || now - g_fKnuxSkyStateStart[client] > KNUX_SKY_MAX_DIVE)
            {
                float boom[3];
                if (wall) TR_GetEndPosition(boom);
                else GetClientAbsOrigin(client, boom);
                Knux_SkyFinish(client, boom);
            }
        }
    }
}

// Lanzarse (2a pulsación o auto-lanzamiento): velocidad FIJADA a la
// dirección de la mira en el momento del disparo.
void Knux_SkyDive(int client)
{
    float ang[3], dir[3];
    GetClientEyeAngles(client, ang);
    GetAngleVectors(ang, dir, NULL_VECTOR, NULL_VECTOR);
    NormalizeVector(dir, dir);

    float spd = g_cvKnuxSkyDiveSpd.FloatValue;
    // v64: la picada sigue la mira EXACTA (fuera el clamp +150 que la
    // lanzaba hacia ARRIBA cuando apuntabas abajo). Apunta abajo = pica
    // abajo; apunta arriba = asciende y la gravedad lo devuelve.
    g_fKnuxSkyDiveVel[client][0] = dir[0] * spd;
    g_fKnuxSkyDiveVel[client][1] = dir[1] * spd;
    g_fKnuxSkyDiveVel[client][2] = dir[2] * spd;

    // salir del hover (NONE) a vuelo real (WALK)
    if (GetEntityMoveType(client) == MOVETYPE_NONE)
        SetEntityMoveType(client, MOVETYPE_WALK);

    // v64: gravedad normal garantizada (por si el cast sorprendio un
    // planeo con gravedad reducida: el arco tiene que caer)
    SetEntityGravity(client, 1.0);

    g_iKnuxSkyState[client] = KNUX_SKY_DIVE;
    g_fKnuxSkyStateStart[client] = GetEngineTime();
    // EL IMPULSO: una sola vez. De aquí en adelante la física del motor
    // integra la gravedad (la picada acelera/curva sola).
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, g_fKnuxSkyDiveVel[client]);

    EmitSoundToAll(KNUX_SOUND_CHARGE_1, client);
    EmitSoundToAll(KNUX_SOUND_PUNCH, client);
    PrintCenterText(client, "☄️ ¡PICADA METEORO!");
}

// Impacto de la picada: fin del estado + MEGA EXPLOSION en el punto.
void Knux_SkyFinish(int client, const float pos[3])
{
    g_iKnuxSkyState[client] = KNUX_SKY_NONE;
    if (GetEntityMoveType(client) == MOVETYPE_NONE)
        SetEntityMoveType(client, MOVETYPE_WALK);
    float stop[3] = {0.0, 0.0, 0.0};
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, stop);

    int hits = Knux_SkyExplode(client, pos, g_cvKnuxSkyRadius.FloatValue,
                               g_cvKnuxSkyDamage.FloatValue, 1.0, true);
    PrintCenterText(client, "☄️ ¡METEORO! (%d impactados)", hits);
}

// ============================================================================
//  LA EXPLOSION (compartida por ambas variaciones; solo cambia la escala):
//  VFX SIN TEMBLOR + especiales volando (por peso, menos el tank) +
//  boomer con mecha + comunes + witch (WitchFlight) + props con V.
// ============================================================================
int Knux_SkyExplode(int client, const float pos[3], float radius, float damage, float forceScale, bool mega)
{
    if (client < 0 || client > MaxClients || !IsClientInGame(client)) client = 0;

    // --- VFX (SIN TEMBLOR: cero env_shake, cero ScreenShake) ---
    int color[4];
    color[0] = 255; color[1] = 110; color[2] = 20; color[3] = 255;   // fuego Knuckles
    if (g_iKnuxBeamSprite <= 0) g_iKnuxBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");

    TE_SetupBeamRingPoint(pos, 20.0, radius, g_iKnuxBeamSprite, 0, 0, 0,
                          0.6, mega ? 40.0 : 22.0, 0.0, color, 5, 0);
    TE_SendToAll();
    TE_SetupBeamRingPoint(pos, 10.0, radius * 0.6, g_iKnuxBeamSprite, 0, 0, 0,
                          0.4, 20.0, 0.0, color, 5, 0);
    TE_SendToAll(0.1);

    // la mega explosión del "detonador" re-utilizada de forma NATIVA:
    // particula gas_explosion_main (la del punch, ya precacheada)
    Knux_VFX_Particle(pos, "gas_explosion_main");
    if (mega) Knux_VFX_Particle(pos, "gas_explosion_main");   // doble carga = mega

    EmitSoundToAll(KNUX_SOUND_SKYBOOM, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);
    EmitSoundToAll(mega ? KNUX_SOUND_SLAM : KNUX_SOUND_SMASH_HIT, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    int hits = 0;

    // --- ESPECIALES (players): TODOS vuelan EXCEPTO el tank ---
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float tPos[3];
        GetClientAbsOrigin(i, tPos);
        if (GetVectorDistance(pos, tPos) > radius) continue;

        int zclass = GetEntProp(i, Prop_Send, "m_zombieClass");

        // TANK: "excepto al tank" — solo el dano, ni vuelo ni stagger
        if (zclass == 8)
        {
            OM_AbilityDamage(i, client, damage, DMG_BLAST);
            continue;
        }

        float push[3];
        MakeVectorFromPoints(pos, tPos, push);
        push[2] = 0.0;
        if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; }
        NormalizeVector(push, push);

        // "la distancia y la elevación varia dependiendo el especial
        // (y el peso que tu puedas deducir)": multiplicador por clase
        float w = Knux_SkyWeight(zclass);

        // BOOMER: "no explotara de inmediato... será empujado y
        // explotara tiempo después" (patron Amy v64: mecha + pop real)
        if (zclass == 2)
        {
            ScaleVector(push, g_cvKnuxSkySiForce.FloatValue * w * forceScale);
            push[2] = KNUX_SKY_LIFT_SI * w;
            TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
            DataPack bpack = new DataPack();
            bpack.WriteCell(GetClientUserId(i));
            bpack.WriteCell(GetClientUserId(client));
            CreateTimer(g_cvKnuxBoomerFuse.FloatValue, T_KnuxBoomerBurst, bpack,
                        TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
            hits++;
            continue;
        }

        ScaleVector(push, g_cvKnuxSkySiForce.FloatValue * w * forceScale);
        push[2] = KNUX_SKY_LIFT_SI * w;          // elevación también por peso
        TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
        OM_AbilityDamage(i, client, damage, DMG_BLAST);
        if (client > 0) SIStagger_Auto(i, client, pos);
        hits++;
    }

    // --- COMUNES: "mandar a volar todo lo que no sea Especial" ---
    // empuje ANTES del dano (v45: el ragdoll hereda el impulso)
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float zPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(pos, zPos) > radius) continue;

        float push[3];
        MakeVectorFromPoints(pos, zPos, push);
        if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; push[2] = 0.0; }
        NormalizeVector(push, push);
        ScaleVector(push, g_cvKnuxSkyCommonForce.FloatValue * forceScale);
        push[2] = KNUX_SKY_LIFT_COMMON * forceScale;
        TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);
        OM_AbilityDamage(entity, client, damage, DMG_BLAST);
        hits++;
    }

    // --- WITCH: "esto incluye a la witch" — vuela con WitchFlight ---
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        if (WitchFlight_IsFlying(entity)) continue;   // ya volando: su curso sigue

        float wPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", wPos);
        if (GetVectorDistance(pos, wPos) > radius) continue;

        float push[3];
        MakeVectorFromPoints(pos, wPos, push);
        push[2] = 0.0;
        if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; }
        NormalizeVector(push, push);
        ScaleVector(push, g_cvKnuxSkyWitchForce.FloatValue * forceScale);
        push[2] = KNUX_SKY_LIFT_WITCH;
        WitchFlight_Launch(entity, client, push);
        OM_AbilityDamage(entity, client, damage, DMG_BLAST);
        WitchFlight_CheckDead(entity);   // si murió en pleno vuelo: restaurarla YA
        hits++;
    }

    // --- PROPS/AUTOS: "todo lo que tenga V en activo" (sin conversión) ---
    int props[KNUX_PROPS_PER_HIT];
    int nProps = Knux_FindVProps(pos, radius, props, KNUX_PROPS_PER_HIT);
    for (int k = 0; k < nProps; k++)
    {
        float pPos[3], dir[3];
        GetEntPropVector(props[k], Prop_Send, "m_vecOrigin", pPos);
        MakeVectorFromPoints(pos, pPos, dir);
        dir[2] = 0.0;
        if (GetVectorLength(dir) < 1.0) { dir[0] = 0.0; dir[1] = 1.0; }
        NormalizeVector(dir, dir);
        if (Knux_PushMapProp(client, props[k], dir,
                             g_cvKnuxPropForce.FloatValue * 1.2 * forceScale, 0.6))
            hits++;
    }

    return hits;
}

// ============================================================================
//  VARIACION TERRESTRE: LA ESFERA DE FUEGO (proyectil). "Una (esfera como
//  lo que usa el escudo... o el escudo de sally) pero este sería un
//  proyectil que al impactar al suelo estallara". Misma esfera del escudo
//  de Sally (atlas_break_ball.mdl), en pequeño, translucida y NARANJA.
//  Vuelo integrado a mano (arco suave), impacto por trace (mundo, props o
//  infectado — el lanzador y la propia esfera no cuentan), vida máxima
//  2.5s (detonación aérea). EntRef + DataPack: cero estado persistente.
// ============================================================================
void Knux_SkyBallLaunch(int client)
{
    float eye[3], ang[3], dir[3];
    GetClientEyePosition(client, eye);
    GetClientEyeAngles(client, ang);
    GetAngleVectors(ang, dir, NULL_VECTOR, NULL_VECTOR);

    int ball = CreateEntityByName("prop_dynamic_override");
    if (ball == -1 || !IsValidEntity(ball))
    {
        PrintCenterText(client, "❌ La esfera no pudo crearse");
        return;
    }

    DispatchKeyValue(ball, "model", KNUX_SKY_BALL_MDL);
    DispatchKeyValue(ball, "solid", "0");
    DispatchSpawn(ball);

    // esfera de fuego: translucida naranja (estilo escudo de Sally)
    SetEntityRenderMode(ball, RENDER_TRANSCOLOR);
    SetEntityRenderColor(ball, 255, 110, 20, 170);
    if (HasEntProp(ball, Prop_Send, "m_flModelScale"))
        SetEntPropFloat(ball, Prop_Send, "m_flModelScale", KNUX_SKY_BALL_SCALE);

    float start[3];
    // v64: pegada al cuerpo (35u) — "no estar muy separado, no estar
    // arriba en la cabeza de knuckles"
    start[0] = eye[0] + dir[0] * 35.0;
    start[1] = eye[1] + dir[1] * 35.0;
    start[2] = eye[2] + dir[2] * 35.0;
    TeleportEntity(ball, start, ang, NULL_VECTOR);

    float vel[3];
    float spd = g_cvKnuxSkyBallSpeed.FloatValue;
    // v64: la esfera vuela hacia DONDE APUNTAS (fuera el pisito +150
    // que la lanzaba por encima de la cabeza en una dirección fija).
    // Apuntas al suelo/pared = la esfera va directo a el y detona al
    // contacto. El arco suave lo pone la gravedad del propio vuelo.
    vel[0] = dir[0] * spd;
    vel[1] = dir[1] * spd;
    vel[2] = dir[2] * spd;

    EmitSoundToAll(KNUX_SOUND_CHARGE_1, client);

    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(EntIndexToEntRef(ball));
    pack.WriteFloat(vel[0]);
    pack.WriteFloat(vel[1]);
    pack.WriteFloat(vel[2]);
    pack.WriteFloat(GetEngineTime());
    pack.WriteCell(0);   // tick counter (rastro)
    CreateTimer(KNUX_SKY_BALL_TICK, T_KnuxSkyBall, pack,
                TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);

    PrintCenterText(client, "🔥 ESFERA DE FUEGO LANZADA");
}

// Filtro del trace de la esfera: todo es solido MENOS la propia esfera y
// su lanzador. data = (ball << 8) | lanzador.
public bool Knux_TraceFilterBall(int entity, int contentsMask, int data)
{
    int ball = data >> 8;
    int thrower = data & 0xFF;
    if (entity == ball) return false;
    if (thrower > 0 && entity == thrower) return false;
    return true;
}

// Integración del vuelo de la esfera (~33 Hz). El pack se RE-ARMA en cada
// tick con la velocidad actualizada (mismo patron de re-escritura de los
// DataPack de vuelo de Amy). TIMER_DATA_HNDL_CLOSE lo libera al terminar.
public Action T_KnuxSkyBall(Handle timer, DataPack pack)
{
    pack.Reset();
    int userid = pack.ReadCell();
    int ref = pack.ReadCell();
    float vel[3];
    vel[0] = pack.ReadFloat();
    vel[1] = pack.ReadFloat();
    vel[2] = pack.ReadFloat();
    float born = pack.ReadFloat();
    int tick = pack.ReadCell();

    int ball = EntRefToEntIndex(ref);
    if (ball <= 0 || !IsValidEntity(ball)) return Plugin_Stop;   // el mapa se la llevo

    float now = GetEngineTime();
    float pos[3];
    GetEntPropVector(ball, Prop_Send, "m_vecOrigin", pos);

    // arco suave (gravedad reducida: es energía, no una piedra)
    vel[2] -= KNUX_SKY_BALL_GRAV * KNUX_SKY_BALL_TICK;

    float next[3];
    next[0] = pos[0] + vel[0] * KNUX_SKY_BALL_TICK;
    next[1] = pos[1] + vel[1] * KNUX_SKY_BALL_TICK;
    next[2] = pos[2] + vel[2] * KNUX_SKY_BALL_TICK;

    // IMPACTO: cualquier solido (mundo, prop o infectado) detona la
    // esfera en el punto exacto. El lanzador y ella misma no cuentan.
    // v64: PAD ANTI-TUNEL de +8u al largo del rayo (un brush delgado
    // entre ticks ya no se salta: el contacto es garantizado).
    int thrower = GetClientOfUserId(userid);
    int data = (ball << 8) | (thrower > 0 && thrower <= MaxClients ? thrower : 0);
    float traceEnd[3];
    traceEnd = next;
    float pad[3];
    pad = vel;
    if (GetVectorLength(pad) > 1.0)
    {
        NormalizeVector(pad, pad);
        ScaleVector(pad, 8.0);
        AddVectors(traceEnd, pad, traceEnd);
    }
    Handle trace = TR_TraceRayFilterEx(pos, traceEnd, MASK_SOLID, RayType_EndPoint,
                                       Knux_TraceFilterBall, data);
    bool hit = TR_DidHit(trace);
    float hitPos[3];
    if (hit) TR_GetEndPosition(hitPos);
    delete trace;

    bool expired = (now - born >= KNUX_SKY_BALL_LIFE);

    if (hit || expired)
    {
        float boom[3];
        if (hit) { boom[0] = hitPos[0]; boom[1] = hitPos[1]; boom[2] = hitPos[2]; }
        else GetEntPropVector(ball, Prop_Send, "m_vecOrigin", boom);

        AcceptEntityInput(ball, "Kill");
        int atk = (thrower > 0 && thrower <= MaxClients && IsClientInGame(thrower)) ? thrower : 0;
        Knux_SkyExplode(atk, boom, g_cvKnuxSkyBallRadius.FloatValue,
                        g_cvKnuxSkyBallDamage.FloatValue, 0.75, false);
        return Plugin_Stop;
    }

    TeleportEntity(ball, next, NULL_VECTOR, NULL_VECTOR);

    // rastro: anillo pulsado cada 3er tick (~11 Hz)
    if (tick % 3 == 0)
    {
        if (g_iKnuxBeamSprite <= 0) g_iKnuxBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
        int trail[4];
        trail[0] = 255; trail[1] = 110; trail[2] = 20; trail[3] = 160;
        TE_SetupBeamRingPoint(pos, 8.0, 40.0, g_iKnuxBeamSprite, 0, 0, 0,
                              0.25, 3.0, 0.0, trail, 0, 0);
        TE_SendToAll();
    }

    // re-armar el pack con la velocidad del tick en curso
    pack.Reset();
    pack.WriteCell(userid);
    pack.WriteCell(ref);
    pack.WriteFloat(vel[0]);
    pack.WriteFloat(vel[1]);
    pack.WriteFloat(vel[2]);
    pack.WriteFloat(born);
    pack.WriteCell(tick + 1);
    return Plugin_Continue;
}

// =====================================================================
// =====================================================================
// v65-OM: SISTEMA DE AVATAR — patron Metal v5.4 (doble copia R/L + modo
// TP + pulso de pausa + FSM de animación del knuckles.mdl)
// =====================================================================
// =====================================================================

// Crea el prop base (avatar R o L): parentado al survivor, sin sombras,
// EF_NOINTERP al nacer (nace ENCAJADO). tpMode = la copia R viaja por
// TeleportEntity + reloj vivo (tails_avatar_tp): los clientes de los
// demas la INTERPOLAN suave (la L siempre parentada).
int Knux_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
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
    g_fKnuxBodyYaw[client]  = ang[1];
    g_fKnuxYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fKnuxBodyYaw[client], loc);

    if (!tpMode)
    {
        // parentado (modo Tails default: el motor mueve la posición,
        // cero delay de red, anims suaves; aquí solo se escriben angulos)
        SetVariantString("!activator");
        AcceptEntityInput(av, "SetParent", client);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", loc);
    }

    for (int k = 0; k < 3; k++)
    {
        g_fKnuxSmLoc[client][k]  = loc[k];
        g_fKnuxSmLocL[client][k] = loc[k];
    }
    g_bKnuxSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// =====================================================================
// v72-OM (manager 3.77.40): ADOPCION EN EL MONTAJE — el reemplazo del
// barrido en caliente (orden del owner 2026-10-10: "tu barrido de
// avatares está haciendo reiniciar mi avatar a cada rato... BUSCA OTRA
// MANERA"). Esta FSM es la ÚNICA creadora de props con los nombres de
// abajo: un prop así que ELLA no rastrea es un huerfano por definición
// (lo fabrico una vida anterior, un montaje doble del pasado o una
// versión vieja del suite) y muere en el instante exacto del montaje.
// Un avatar rastreado es INTOCABLE: no existe ningún timer que lo mire.
// =====================================================================
bool Knux_IsMyAvatarRef(int ref)
{
    // v3.77.40: el 0 es "sin avatar"; un ref NEGATIVO puede ser
    // perfectamente legitimo (bit alto del serial del handle).
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iKnuxAvatar[i] == ref) return true;
        if (g_iKnuxAvatarL[i] == ref) return true;
    }
    return false;
}

void Knux_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "knuckles_avatar_om", "knuckles_avatar_om_l", "knux_avatar" };
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
                if (Knux_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
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
        PrintToServer("[Knuckles v75-OM] Adopción del montaje: %d huerfano(s) del avatar eliminado(s).", ng);
}

// Monta el avatar completo (R + L + cuerpo oculto). pulsePause SOLO para
// montajes de ciclo de vida (spawn/selección/reparación tardia de la FSM).
void Knux_CreateAvatar(int client, bool pulsePause = true)
{
    if (!g_bKnuxModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;

    // la copia R nace en modo TP si tails_avatar_tp (la que ven los
    // DEMAS viaja por teleport por tick + interpolación de red)
    // v72-OM (manager 3.77.40): REEMPLAZO LIMPIO — orden del owner
    // 2026-10-10: en caliente YA NO EXISTE barrido. Si este cliente ya
    // tenía un R o L vivo (montaje doble por orden raro de eventos),
    // muere AQUÍ enterito: jamás vuelve a quedar un prop sin dueño (la
    // fábrica de huerfanos del "= 0" sin Kill queda cerrada).
    {
        int oldR = EntRefToEntIndex(g_iKnuxAvatar[client]);
        if (g_iKnuxAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Knux_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iKnuxAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iKnuxAvatarL[client]);
        if (g_iKnuxAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Knux_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iKnuxAvatarL[client] = 0;
    }

    // v72-OM: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje, no en un
    // timer a ciegas.
    Knux_KillGhostAvatarProps();

    int av = Knux_CreateAvatarProp(client, KNUX_OM_MODEL, KNUX_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");
    g_iKnuxAnimState[client] = 0;

    SDKHook(av, SDKHook_SetTransmit, Knux_TransmitAvatarR);

    g_iKnuxAvatarL[client] = 0;
    Knux_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iKnuxBodyRender[client] = view_as<int>(curMode);
    else if (g_iKnuxBodyRender[client] == -1)
        g_iKnuxBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    g_iKnuxAvatar[client] = EntIndexToEntRef(av);

    // per-tick: angulos locales (contra-rotación del parent)
    SDKHook(client, SDKHook_PostThink, Knux_AvatarFollow);

    // PULSO DE PAUSA en cada montaje de ciclo de vida (la misma infra
    // sv_pausable del suite; convar tails_pausefix manda para TODOS los
    // avatares — es UN solo sistema, 5o avatar del suite)
    if (pulsePause)
        Tails_PauseFix_Trigger(client);
}

void Knux_CreateAvatarL(int client)
{
    if (!g_bKnuxModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iKnuxAvatar[client] == 0) return;

    int av = Knux_CreateAvatarProp(client, KNUX_OM_MODEL, "knuckles_avatar_om_l");
    if (av == 0) return;

    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Knux_TransmitAvatarL);

    g_iKnuxAvatarL[client] = EntIndexToEntRef(av);
}

void Knux_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iKnuxAvatarL[client]);
    if (g_iKnuxAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Knux_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iKnuxAvatarL[client] = 0;
}

// Mata las copias R+L y devuelve el cuerpo. SIN desenganchrar el follow
// (lo hace Knux_KillAvatar).
void Knux_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    Knux_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iKnuxAvatar[client]);
    if (g_iKnuxAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Knux_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iKnuxAvatar[client] = 0;

    // devolver el cuerpo SI el jugador sigue conectado (muerte/cambio de
    // personaje/desconexion: el corpse que pueda aparecer lo filtra la
    // ventana anti-ragdoll de abajo)
    if (IsClientInGame(client))
    {
        if (g_iKnuxBodyRender[client] != -1)
        {
            SetEntityRenderMode(client, view_as<RenderMode>(g_iKnuxBodyRender[client]));
            g_iKnuxBodyRender[client] = -1;
        }
    }
    else
        g_iKnuxBodyRender[client] = -1;

    g_iKnuxAnimState[client] = -1;
}

void Knux_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Knux_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Knux_AvatarFollow);
}

// Transmit filters (patron Sonic/Metal): la R no la ve su dueño (tiene
// su L), la L la ve SOLO su dueño.
public Action Knux_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iKnuxAvatar[i] != 0 && EntRefToEntIndex(g_iKnuxAvatar[i]) == entity)
        {
            if (client == i && g_iKnuxAvatarL[i] != 0
                && EntRefToEntIndex(g_iKnuxAvatarL[i]) > 0)
                return Plugin_Handled;   // el dueño tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

public Action Knux_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iKnuxAvatarL[i] != 0 && EntRefToEntIndex(g_iKnuxAvatarL[i]) == entity)
        {
            if (client == i) return Plugin_Continue;   // el dueño si
            return Plugin_Handled;                     // nadie más
        }
    }
    return Plugin_Continue;
}

// FOLLOW PER-TICK (lecciones Tails/Sonic/Metal: yaw suave con deadband 3
// grados, contra-rotación amortiguada, reloj vivo, copia L contra los
// eye angles del dueño; la R por TP en modo tp)
public void Knux_AvatarFollow(int client)
{
    if (g_iKnuxAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Knux_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    // ---- yaw objetivo: dirección REAL del movimiento ----
    float yawObj = g_fKnuxBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fKnuxBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    // v67-OM: AGARRE DE PARED — mientras cuelga, el yaw objetivo es la
    // NORMAL de la pared (lua: pill_assignedangle = normal:Angle() en el
    // latch, l.791-792): el avatar mira al lado contrario de la pared.
    // El giro suave de abajo hace la rotación (la velocidad es 0 así que
    // la rama de arriba nunca compite).
    if (g_bKnuxClinging[client]) yawObj = g_fKnuxLatchYaw[client];

    // ---- giro suave hacia el objetivo (~900 grados/s) ----
    float now = GetEngineTime();
    float dt  = now - g_fKnuxYawLastT[client];
    g_fKnuxYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fKnuxBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fKnuxBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bKnuxSmSnap[client];
    GetClientAbsAngles(client, par);

    // v66-OM: FIX DE FACING de counter/counter_hit — esas secuencias del
    // knuckles.mdl miran a la DERECHA (aviso del owner); mientras corre
    // el one-shot el avatar gira KNUX_COUNTER_YAW_FIX para que la pose
    // mire al FRENTE (el giro lo suaviza el ExpDamp a 900 grados/s).
    float yawFix = 0.0;
    if ((g_iKnuxAnimState[client] == KNUX_ST_COUNTER || g_iKnuxAnimState[client] == KNUX_ST_COUNTER_HIT)
        && GetEngineTime() < g_fKnuxAnimLock[client])
        yawFix = KNUX_COUNTER_YAW_FIX;
    float yawPuppet = g_fKnuxBodyYaw[client] + yawFix;

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iKnuxAvatar[client]);
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
            loc[1] = Tails_UnwrapYaw(g_fKnuxSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fKnuxSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fKnuxSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }

    // ---- copia L: contra-rotada contra los EYE del dueño ----
    if (g_iKnuxAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iKnuxAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3], locL[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], yawPuppet, locL);
            locL[1] = Tails_UnwrapYaw(g_fKnuxSmLocL[client][1], locL[1]);
            Tails_ExpDamp(locL, g_fKnuxSmLocL[client], 0.05, dt, snap);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fKnuxSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
    g_bKnuxSmSnap[client] = false;
}

// FSM de 10 Hz: montaje / auto-reparación / muerte del avatar (patron
// T_MetalAvatarThink / T_SonicAvatarThink)
public Action T_KnuxAvatarThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Knux_KillAvatar(i); continue; }

        bool esKnuxVivo = (g_iPlayerCharIdx[i] == KNUCKLES_INDEX
                           && IsPlayerAlive(i) && GetClientTeam(i) == 2);

        // incap = fuera (defensa anti terceros: ni el ragdoll del
        // incap ni el cuerpo vuelven a verse raros)
        if (esKnuxVivo && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            esKnuxVivo = false;

        // ---- montaje ----
        if (g_iKnuxAvatar[i] == 0)
        {
            if (esKnuxVivo && g_cvKnuxAvatar != null && g_cvKnuxAvatar.BoolValue
                && g_bKnuxModelOK)
            {
                Knux_CreateAvatar(i);
            }
            continue;
        }

        // quitar avatar si dejó de ser un Knuckles survivor vivo de pie
        if (!esKnuxVivo)
        {
            Knux_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iKnuxAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iKnuxAvatar[i] = 0;
            g_iKnuxAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (el motor lo resetea al
        // cambiar de capítulo/rescue: fix Tails v5.4)
        if (g_iKnuxBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparación de la copia L (montaje tardio: pulso también)
        if (g_iKnuxAvatarL[i] == 0 && g_iKnuxAvatar[i] != 0)
        {
            Knux_CreateAvatarL(i);
            if (g_iKnuxAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // ---- FSM de animación ----
        av = EntRefToEntIndex(g_iKnuxAvatar[i]);
        if (g_iKnuxAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Knux_AvatarUpdate(i, av, now);
    }
    return Plugin_Continue;
}

// =====================================================================
// FSM DE ANIMACION — prioridades del lua GMod:
//   el Meteoro MANDA el frame (SkyThink) -> agarrado de pared (latch) ->
//   picada del smash aéreo (FallAttack, el punchFallanim) -> planeo
//   (glide) -> aire (jump con ventana / fall) -> suelo (idle/walk/run
//   con variantes lowhealth de HP<=60 — ShouldAlternate l.209-243)
// =====================================================================
void Knux_AvatarUpdate(int client, int av, float now)
{
    // lock de one-shot en curso (PunchAnim/GroundSmash/attack/LatchOff)
    if (now < g_fKnuxAnimLock[client]) return;

    int state;
    float rate = 1.0;
    int sky = g_iKnuxSkyState[client];

    if (sky == KNUX_SKY_ASCENT)
    {
        // elevación del Meteoro: pose de vuelo
        state = KNUX_ST_GLIDE;
    }
    else if (sky == KNUX_SKY_AIM)
    {
        // hover de apuntado — "estilo agarre de pared" (v63/v64)
        state = KNUX_ST_LATCH;
    }
    else if (sky == KNUX_SKY_DIVE)
    {
        // la picada del Meteoro (mismo look que la del smash aéreo)
        state = KNUX_ST_FALLATK;
    }
    else if (g_bKnuxClinging[client])
    {
        // agarrado de pared (ShouldAlternate.fall -> 'latch')
        state = KNUX_ST_LATCH;
    }
    else if (g_bKnuxSlamming[client])
    {
        // picada del Meteor Smash (punchFallanim -> 'FallAttack')
        state = KNUX_ST_FALLATK;
    }
    else if (g_bKnuxGliding[client])
    {
        // planeo (GlideDuration -> 'glide')
        state = KNUX_ST_GLIDE;
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // AIRE (receta Metal v5.2 ajuste 5 / Sonic "ventana del jump"):
        // sube = jump; cae = fall PERO si el one-shot del jump todavia
        // vive (arranco hace < 0.5s o el ciclo del modelo no termino),
        // el jump SIGUE sin cortarse
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[2] > 40.0)
        {
            state = KNUX_ST_JUMP;
        }
        else
        {
            bool jumpLive = false;
            if (g_iKnuxAnimState[client] == KNUX_ST_JUMP)
            {
                float jt = now - g_fKnuxJumpStart[client];
                if (jt < 0.5)      jumpLive = true;
                else if (jt < 1.5 && !Knux_JumpAnimDone(av)) jumpLive = true;
            }
            state = jumpLive ? KNUX_ST_JUMP : KNUX_ST_FALL;
        }
    }
    else if (g_iKnuxAnimState[client] == KNUX_ST_JUMP && !Knux_JumpAnimDone(av)
             && now - g_fKnuxJumpStart[client] < 0.5)
    {
        // FL_ONGROUND parpadea al saltar rozando escalones: mientras el
        // one-shot del jump viva (<= 0.5s), no bajar a walk/run
        state = KNUX_ST_JUMP;
    }
    else
    {
        // SUELO: idle/walk/run (con las variantes lowhealth del lua —
        // ShouldAlternate las pisa con HP <= 60)
        bool low = (GetClientHealth(client) <= 60);
        float s = Knux_Speed2D(client);
        if (s < 40.0)
            state = low ? KNUX_ST_IDLE_LOW : KNUX_ST_IDLE;
        else if (s < 150.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = low ? KNUX_ST_WALK_LOW : KNUX_ST_WALK;
            // walk al rate 1.0 CONSTANTE del framework GMod (knuckles NO
            // define animrates — noodles_om_pills_base l.936-944: rate 1
            // para TODO; lección Metal v5.2 ajuste 5)
            rate = 1.0;
        }
        else
        {
            state = low ? KNUX_ST_RUN_LOW : KNUX_ST_RUN;
            rate = 1.32 * (s / 450.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6)  rate = 3.6;
        }
    }

    if (state != g_iKnuxAnimState[client])
    {
        // el t0 del jump para su ventana (receta Sonic/Metal)
        if (state == KNUX_ST_JUMP) g_fKnuxJumpStart[client] = now;
        SetVariantString(g_sKnuxAnimSeq[state]);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iKnuxAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iKnuxAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                // el variant es de UN SOLO USO — re-armarlo
                SetVariantString(g_sKnuxAnimSeq[state]);
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iKnuxAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iKnuxAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iKnuxAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

float Knux_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// el one-shot del jump termino? (m_flCycle del prop — la misma sonda del
// Sonic_JumpAnimDone / Metal_JumpAnimDone)
bool Knux_JumpAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return true;
}

// v65-OM: ONE-SHOT de habilidad sobre las DOS copias (los 4 PillAnim del
// lua: PunchAnim/GroundSmash/attack/LatchOff). Bloquea la FSM mientras
// corre (g_fKnuxAnimLock) para que el golpe se vea entero.
void Knux_AvatarOneShot(int client, int stIdx, float lock)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iKnuxAvatar[client] == 0) return;

    int av = EntRefToEntIndex(g_iKnuxAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        SetVariantString(g_sKnuxAnimSeq[stIdx]);
        AcceptEntityInput(av, "SetAnimation");
    }
    if (g_iKnuxAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iKnuxAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetVariantString(g_sKnuxAnimSeq[stIdx]);
            AcceptEntityInput(avL, "SetAnimation");
        }
    }
    g_iKnuxAnimState[client] = stIdx;
    g_fKnuxAnimLock[client] = GetEngineTime() + lock;
}

// =====================================================================
// TINTES DEL AVATAR — la matemática EXACTA del knuckles_ui_om.lua
// (duration 0.5*0.5 = 0.25s, fade 0.25*0.5 = 0.125s por lado, alpha
// simétrico). Aplica a las DOS copias; el cuerpo oculto no se toca.
// =====================================================================
void Knux_AvatarSetColor(int client, int r, int g, int b, int a)
{
    int av = EntRefToEntIndex(g_iKnuxAvatar[client]);
    if (g_iKnuxAvatar[client] != 0 && av > 0 && IsValidEntity(av))
        SetEntityRenderColor(av, r, g, b, a);
    int avL = EntRefToEntIndex(g_iKnuxAvatarL[client]);
    if (g_iKnuxAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
        SetEntityRenderColor(avL, r, g, b, a);
}

void Knux_AvatarTintReset(int client)
{
    Knux_AvatarSetColor(client, 255, 255, 255, 255);
}

// arranca un pulso de color (0.25s con fade simétrico)
void Knux_AvatarTintPulse(int client, int r, int g, int b)
{
    if (g_iKnuxAvatar[client] == 0) return;
    g_iKnuxTintR[client] = r;
    g_iKnuxTintG[client] = g;
    g_iKnuxTintB[client] = b;
    g_fKnuxTintEnd[client] = GetEngineTime() + KNUX_TINT_DUR;
}

// animador por frame (lo invoca Knux_PreThink): pulso activo con la rampa
// simétrica del UI; sin pulso, la POSTURA tiñe azul 200,200,255 (el
// mismo tinte que el port siempre puso en el cuerpo — con avatar el
// cuerpo esta oculto, se pintan las copias); sin nada, color base.
void Knux_TintThink(int client)
{
    if (g_iKnuxAvatar[client] == 0) return;
    float now = GetEngineTime();

    // pulso ROJO repetido de la carga del puño (Knuckles_glow_duration)
    if (g_bKnuxCharging[client] && now >= g_fKnuxNextPulse[client])
    {
        Knux_AvatarTintPulse(client, 255, 0, 0);
        g_fKnuxNextPulse[client] = now + KNUX_TINT_PULSE_EVERY;
    }

    if (g_fKnuxTintEnd[client] > 0.0)
    {
        // rampa simétrica EXACTA del UI: sube en KNUX_TINT_FADE, meseta,
        // baja en KNUX_TINT_FADE (sobre KNUX_TINT_DUR totales)
        float start = g_fKnuxTintEnd[client] - KNUX_TINT_DUR;
        float a;
        if (now <= start + KNUX_TINT_FADE)
            a = (now - start) / KNUX_TINT_FADE;
        else if (now >= g_fKnuxTintEnd[client] - KNUX_TINT_FADE)
            a = (g_fKnuxTintEnd[client] - now) / KNUX_TINT_FADE;
        else
            a = 1.0;
        if (a < 0.0) a = 0.0;
        if (a > 1.0) a = 1.0;

        Knux_AvatarSetColor(client, g_iKnuxTintR[client], g_iKnuxTintG[client],
                            g_iKnuxTintB[client], RoundToNearest(255.0 * a));

        if (now >= g_fKnuxTintEnd[client]) g_fKnuxTintEnd[client] = 0.0;
        return;
    }

    if (g_bKnuxCountering[client])
        Knux_AvatarSetColor(client, 200, 200, 255, 255);
    else
        Knux_AvatarTintReset(client);
}

// v65-OM: FX del BLOQUEO de la contra — pulso BLANCO del UI
// (knuckles_block_outline / glow_duration_white) + CounterBounce.wav del
// lua (vol 0.65, l.555) con fallback al stock de siempre
void Knux_CounterBlockFx(int client, const char[] fallback)
{
    // v66-OM: ANIMACION DE GOLPE del bloqueo (el gesture del lua l.590:
    // AddGesture ACT_GESTURE_RANGE_ATTACK2_LOW, fade 0.5s) + el pulso
    // BLANCO del UI de siempre
    Knux_AvatarOneShot(client, KNUX_ST_COUNTER_HIT, KNUX_LOCK_COUNTER_HIT);
    Knux_AvatarTintPulse(client, 255, 255, 255);
    // v73-OM (owner 2026-10-10: "el sonido de bloqueo no suena para
    // cuando bloquea habilidades (en smx) de agarres y golpes de tank")
    // — EL SONIDO DEL BLOQUEO pasa a ser om/knuckles/punchstun.wav (el
    // mismo que el owner eligio para la ventana del VScript en la .39),
    // con la cadena de respaldo de siempre. Agarres, tank, VScript y
    // básicos de especiales suenan IGUAL.
    if (g_bKnuxSndPunchStun)
        EmitSoundToAll("om/knuckles/punchstun.wav", client, _, KNUX_SND_LEVEL);
    else if (g_bKnuxSndBounce)
        EmitSoundToAll("om/knuckles/CounterBounce.wav", client, _, KNUX_SND_LEVEL, _, 0.65);
    else
        EmitSoundToAll(fallback, client);
}

// =====================================================================
// v73-OM — EL VSCRIPT BLOQUEO ALGO EN LA VENTANA (puente inverso, patron
// amyparry_strike): el chch_parrying.nut v2.5 manda knx_parry_blocked
// <idx> en cada bloqueo de la ventana (roca/granada/saliva/enemigo).
// El .nut ya puso SU hint y SU sonido; esto es la parte que SOLO el
// manager puede hacer: el GESTO DE BLOQUEO del avatar + el pulso blanco
// (+ el punchstun del CounterBlockFx). Throttle 0.4 s: el escaneo va a
// 30 Hz y el gesto dura 0.55 s.
public Action Knux_CmdParryBlocked(int args)
{
    if (args < 1) return Plugin_Handled;
    char s[16];
    GetCmdArg(1, s, sizeof(s));
    int client = StringToInt(s);
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != KNUCKLES_INDEX) return Plugin_Handled;
    if (!IsPlayerAlive(client) || GetClientTeam(client) != 2) return Plugin_Handled;
    if (GetEngineTime() < g_fKnuxBlockFxNext[client]) return Plugin_Handled;
    g_fKnuxBlockFxNext[client] = GetEngineTime() + 0.4;

    Knux_CounterBlockFx(client, KNUX_SOUND_COUNTER_HIT);
    return Plugin_Handled;
}

// =====================================================================
// MUERTE DEL AVATAR — ragdoll knuckles.mdl + filtro anti-corpse
// (receta Metal v5.0 / Sonic v3.76.2)
// =====================================================================

// Ragdoll OM: prop_ragdoll con knuckles.mdl (usa el .phy del modelo —
// el lua trae noragdoll=false, l.59) + limpieza a los 15s
void Knux_SpawnDeathRagdoll(int client)
{
    if (!g_bKnuxModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", KNUX_OM_MODEL);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    CreateTimer(15.0, T_KnuxRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_KnuxRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Filtro anti-ragdoll (patron Sonic/Metal: lo enruta el OnEntityCreated
// central de Rouge.inc — Knuckles se incluye ANTES que Rouge)
void Knuckles_OnEntityCreated(int entity, const char[] classname)
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
            if (g_fKnuxDeathHideUntil[i] == 0.0 || now >= g_fKnuxDeathHideUntil[i])
                continue;
            // candidata: revisar modelo/origen en el próximo frame
            RequestFrame(Knux_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }
}

public void Knux_CheckDeathRagdoll(any ref)
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
        if (g_fKnuxDeathHideUntil[i] == 0.0 || now >= g_fKnuxDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_vKnuxDeathOrigin[i]) < 200.0)
        {
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}
