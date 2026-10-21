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
 * FIXES v4.6.2 (NOMBRES OFICIALES DE POPPY + LENGUA DE THRESH):
 *  - Poppy: nombres corregidos a los OFICIALES de LoL (wiki): la W es
 *    "Presencia Inquebrantable" (Steadfast Presence) y la R es
 *    "Veredicto del Guardián" (Keeper's Verdict) — antes sonaban a lo
 *    mismo ("Presencia Inquebrantable" / "Veredicto del Guardián").
 *  - Thresh (Sentencia de Muerte): FIX CRITICO de la lengua — nacía
 *    3000 u bajo el suelo (punto de disparo de la NAVE) y nunca
 *    enganchaba; ahora sale del pecho de Thresh y arrastra de verdad.
 *    Sin beams verdes de adorno: el visual es la smoker_tongue real.
 *  - La carga de la R de Poppy dibuja su cono real (320 u), distinto
 *    del anillo de la W (220 u).
 *
 * MEJORAS v4.6.5 (REVIVIR INTELIGENTE + IA + MENUS VIVOS):
 *  - REVIVIR que se gana luchando: cada especial/tank/witch abatido por
 *    tu campeon o tu nave rebaja 8% + 0.5% por nivel del CD TOTAL del
 *    Revivir (tope 30% por baja), solo mientras esta en recarga.
 *  - Equipo entero caido (nadie en pie): la recarga del Revivir se recorta
 *    a LA MITAD del tiempo restante, una vez por ciclo de recarga — la
 *    ultima oportunidad de levantar a alguien antes del wipe.
 *  - IA DE REVIVE: reaccion INMEDIATA al caer alguien (evento, sin esperar
 *    al chequeo de 3 s), carrera de emergencia (+25% cerca / +45% lejos),
 *    las embestidas ya no abandonan al caido y ahora revive tambien al
 *    COMPANERO caido mas cercano (no solo a la duena), reclamando la presa
 *    para que dos mascotas no la levanten a la vez.
 *  - MENUS CON NUMEROS EN VIVO: el menu de Poderes repinta sus cooldowns
 *    cada segundo (cuentan hacia abajo en tiempo real) y el del campeon
 *    muestra Nivel/XP/Bajas/vel. + el CD de P/Q/W/E/R y del Revivir,
 *    todo actualizandose en vivo mientras este abierto.
 *
 * FIXES v4.6.4 (PARTICULA QUE EL CLIENTE NO PUEDE RENDERIZAR):
 *  - Retirada explosion_huge_d (W de Vex "Espacio Personal" y R de Snowy
 *    "Tormenta Glacial"): el servidor la registraba sin error (solo apunta
 *    el nombre en la tabla de strings del engine) pero el CLIENTE no puede
 *    renderizarla -> error de consola al dispararse. Sustituida por
 *    particulas ya probadas en el servidor (cero errores en semanas):
 *    - Vex W: gas_explosion_ground_wave — onda expansiva real en el suelo
 *      (la misma del telegrafo de la R de Poppy y de la oleada de
 *      Volibear).
 *    - Snowy R: doble chorro de vapor helado (steam_manhole +
 *      steam_manhole_b — el mismo del muro de hielo y del freeze).
 *
 * FIXES v4.6.3 (VOCES OFICIALES DE POPPY):
 *  - Poppy HABLA: 18 lineas oficiales de LoL (WAV 44.1 kHz mono en
 *    sound/poppy/, registradas en la tabla de descargas -> FastDL
 *    automatico; el plugin ya no depende de que esten en el .vpk):
 *    - Q (Golpe de Martillo): "Comin' down!", "Hammer!"...
 *    - W (Presencia Inquebrantable): al DETENER a un enemigo — "Not so
 *      fast!", "Nope."... con freno de 2.5 s (hunter detenido y jockey
 *      medio segundo despues = UNA sola voz) y hueco global de 0.7 s para
 *      que dos voces de distintas categorias nunca se solapen.
 *    - E (Carga Heroica): al estrellar a la presa contra la PARED —
 *      "Don't move!", "Freeze!"...
 *    - R (Veredicto del Guardián): grito de CARGA al empezar la carga y
 *      linea de lanzamiento ("And stay there!") al soltar el martillo.
 *  - El sonido es ESPACIAL (nace del cuerpo de Poppy; SNDCHAN_VOICE) y si
 *    falta un archivo de voz esa variante simplemente no suena (sin
 *    errores de consola).
 *
 * FIXES v4.6.9 (AUDIOS DE POPPY — SE OIAN CASI NADA, pedido de la dueña):
 *  - Los 18 audios re-masterizados: +5 dB de cuerpo real (doble compresion
 *    musical + techo de picos, ~-9 LUFS por linea); los .mp3 re-codificados
 *    desde los .wav nuevos (192 kbps). Se oyen SOBRE la horda.
 *  - PRIORIDAD INVERTIDA: ahora se usa el .wav si existe y el .mp3 solo de
 *    respaldo (antes al reves). Ese era el motivo real de que los .wav
 *    subidos "no cargaran": el plugin siempre preferia el .mp3 que ya
 *    estaba en el servidor. El .wav es el formato nativo del motor para
 *    sonidos de juego y suena a nivel pleno (el .mp3 por EmitSound se oye
 *    notoriamente mas bajo).
 *  - Las voces salen a SNDLEVEL_SCREAMING (90 dB, antes 75): la voz de
 *    Poppy se oye desde lejos y sigue naciendo de su cuerpo (espacial).
 *
 * MEJORAS v4.6.8 (REWORK DEL KIT DE POPPY — pedido de la dueña):
 *  - AUTO-ATAQUE MELEE DE VERDAD: el golpe basico de Poppy ya no llega a
 *    350 u — pega a 150 u (solo la Embajadora de Hierro estira el brazo a
 *    500 u cuando esta lista) y su dano crece +1% por nivel.
 *  - CARGA HEROICA (E) MAS PODEROSA Y EN AREA: embiste a la presa y arroja
 *    a hasta 3 infectados que esten en su alrededor (170 u); golpe de
 *    entrada 30+3/nv y de vuelo 45+4.5/nv. El estrellon contra la pared
 *    hace el efecto de explosion dorado (particula del charger + polvo +
 *    esquirlas + temblor) y ahora SI se ve: deteccion de pared con margen
 *    grueso (12 u) y vuelo mas largo (2.4 s).
 *  - VEREDICTO DEL GUARDIAN (R) REWORK: la CARGA dura lo que dura su AUDIO
 *    de carga (la linea rcharge de ~4.1 s) y 45% de las veces la ejecuta
 *    rapida en 1 s sin esperar la linea completa. Al soltar sale una ONDA
 *    que recorre el camino hacia el objetivo: TODO infectado en la
 *    trayectoria sale volando lejos; al llegar detona un AREA de 450 u
 *    (+1.5%/nv) alrededor del objetivo y los de ahi tambien vuelan.
 *  - FINISH contra la pared (R): los comunes mueren de una; especiales,
 *    witch y tank reciben dano adicional = distancia recorrida + el % de
 *    vida que les falte (tope 30%) y EJECUCION si quedan bajo 5% (+0.5%
 *    por nivel) de su vida maxima.
 *
 * FIXES v4.6.7 (VOCES EN MP3 O WAV — AUTO-DETECCION, pedido de la dueña):
 *  - Las 18 voces de Poppy aceptan .mp3 O .wav, archivo por archivo: se usa
 *    el .mp3 si existe y si no el .wav (sirve un pack, el otro o ambos
 *    mezclados). Antes solo buscaba .wav — por eso con packs en mp3 salia
 *    "S_StartSound: Failed to load sound 'poppy\q1.wav'".
 *  - El log de carga del mapa ahora separa formatos: "Voces de Poppy:
 *    18/18 listas (12 mp3 + 6 wav)".
 *  - Nota del motor: con .mp3 la voz NO es espacial (mismo volumen a
 *    cualquier distancia); con .wav si sale del cuerpo de Poppy.
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

#define PLUGIN_VERSION  "4.12.0"   // v30/v65: FIX senuelo — CreateFakeClient directo (patron superversus) + cvar real survivor_limit; antes sb_add con nombre custom nunca aparecia ("no pudo plantarse"). v65b: sin doble cierre del DataPack (error 23 del log). v31/v66: CANDADO DE IDENTIDAD del senuo (el juego lo adoptaba ~1 s tras nacer: renombrado al nombre de un personaje, visible y despegado de Poppy). v32/v67: candado COMPLETO por frame (nombre+personaje+modelo) + kick verificado. v33/v70: SIN bot nuevo — se PRESTA uno de los 4 bots existentes (registro watchdog 0.1 s por userid + identidad original restaurada al final) + fix de 2 crashes (m_bGlowEnabled inexistente en players: guard HasEntProp; IsClientInGame antes de IsFakeClient). v34/v71: DOS MODOS a elegir con !decoymodo (idea del usuario) — clon (bot propio INDEFINIDO: sin reloj de 12 s, sin kick en vuelo, sin survivor_limit) o prestamo (v33 intacta). v35/v72: SOLO PRESTAMO — clon retirado tras las pruebas del usuario (el server seguia borrando al 5.o bot creado); MULTI-SENUO por duena con PROTECCION (un bot prestado jamas puede ser tomado por otra campeon); duracion ILIMITADA (termina cuando Poppy se retira/desaparece/muere); cvar de duracion retirada. Base v28: stats LoL + senuelo · v29: HUD siempre visible · v36/v73: IA de combate PROLONGADO (presa sticky + se planta a rango + solo vuelve si la duena esta en peligro: control/especial a 250/tank a 1500) · bot prestado YA al invocarla · SFX reforzados a doble canal + 140-180 dB (el Q y la R ya no se dejan solapar; hueso del tank en el estrellon de la E) · W: stagger a 2+ comunes sin dano + la witch interceptada, con dano y LEVANTADA · v37/v74: HOTFIX — fuga de Handles en el guardia de la dueña (2 return sin liberar el ArrayList: 1 Handle POR FRAME con especial/witch a 250 u, agotaba la tabla del server), escaneo cacheado 0.15 s (corria cada frame), Idle plantada con throttle 0.6 s (se re-emitia cada frame) y reset del cache de LOS al cambiar de mapa · v38/v75: ANIMACIONES REALES de Poppy leidas de su MDL (attack1/attack2 = golpes 1.90 s, attack3 = E 1.10 s, crit = Q 1.50 s, windup = CARGA de la R 5.90 s con slot 4 propio, recall = R 6.97 s, death 1.50 s en la despedida; locks calibrados a duraciones reales) · v39/v76: MAQUINA DE ESTADOS DE ANIMACION COMPLETA — el lock cubre la anim ENTERA (los ataques 1.90 s se cortaban a la mitad y volvian al Idle: el swing ocupa exacto el intervalo de golpe y el DPS no cambia), la mascota espera la anim en curso antes de moverse/atacar/castear y la CARGA de la R es inamovible (Poppy camina en windup y nada la sustituye hasta lanzar el veredicto) · v40/v77: R con ARCO de salida (cono de 320 de una) + area final de 450 y poppy_r2 sonando FUERTE al golpear (1 sola vez); pose del lanzamiento recortada a 1.0 s (la R real no es tan larga); Q con +50% de alcance (480/195/255); Q y R a TRIPLE canal; HUESOS ROTOS de Amy (mobius, patron amy.inc) en golpes/Q/E/estrellones; Poppy mira hacia donde activa cada accion; METODO DE COMBATE (!metodo bot/dps/tank/sup, persistente en BD); rastreo de presa EN TIEMPO REAL (valida cada frame) y navegacion con esquiva para DPS/TANK (rodea muros como los infectados) · v41/v78: FARO — Poppy DPS/TANK marchan por la RUTA real de los infectados cuando no hay presa al alcance (o la presa esta tras un muro: veredicto del nav con L4D2_NavAreaTravelDistance): siguen el FLOW del TerrorNavArea con waypoints contiguos (cache 0.4 s, detector de atasco 2.2 s con veto de areas 8 s, filtro de desniveles 90 u), el combate pausa la marcha y al limpiar la zona la ruta se reanuda sola; cuerda SUELTA sticky durante la excursion (latido 10 s: marcha o combate; guardia de la duena o volver al redil la reata); el kit no gasta Q/E en presas amuralladas; nativos de nav OPCIONALES (MarkNativeAsOptional + GetFeatureStatus) con fallback automatico a la navegacion clasica si el left4dhooks es viejo; BOT y SUP intactos · v42/v79: LA RUTA REAL — port del algoritmo de su l4d_path_to_goal: la CADENA ORDENADA de celdas ESCAPE_ROUTE (colecta + flow + stitch + LOS, presupuesto 0.5 ms por frame, patron PTG) es la misma ruta que su plugin dibuja con beams desde tu posicion hasta la zona segura; Poppy DPS/TANK la sigue CELDA A CELDA (localizacion por nav area / flow / distancia + wiggle de LOS del RequestGuide), combate = pausa, zona limpia = reanuda donde iba; escaleras de mano = SALTO DE FE (blink al waypoint, no vuelta a la duena); puertas que abren = la ruta se reconstruye sola (nav_blocked con cooldown 3.14 s); meta alcanzada = vuelve con la duena; el faro flow-greedy de la v41 (que se pegaba a los muros) RETIRADO
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

// ============================================================================
// v50 CHAT DE COLOR AUTOCONTENIDO — ya NO se incluye <colors>: la copia
// local de ese include (version "MultiColors") llama a MC_RemoveTags y ni
// siquiera define CPrintToChat, asi que no compila sola. Esta replica
// embebe el perfil L4D2 del colors.inc clasico 1.3.2 con el que se
// compilo la v4.4.0/v4.5.0: {default}=\x01, {green}=\x04, {olive}=\x05
// y {blue}=\x03 via SayText2 con autor del equipo 2 (supervivientes =
// azul). Mismo render exacto que ya viste en juego.
// ============================================================================
#define CF_MAXLEN      250       // colors.inc clasico: MAX_MESSAGE_LENGTH
#define CF_NO_INDEX    -1        // colors.inc clasico: NO_INDEX
#define CF_NO_PLAYER   -2        // colors.inc clasico: NO_PLAYER

// Busca un jugador del equipo pedido (autor para el color de equipo).
stock int CF_TeamPlayer(int color_team)
{
        if (color_team == 0) {
                return 0;
        }

        for (int i = 1; i <= MaxClients; i++) {
                if (IsClientInGame(i) && GetClientTeam(i) == color_team) {
                        return i;
                }
        }

        return CF_NO_PLAYER;
}

// Reemplaza los tags de color y devuelve el indice de autor para SayText2
// (CF_NO_INDEX si el mensaje no necesita SayText2).
stock int CF_Format(char[] szMessage, int maxlength)
{
        int iAuthor = CF_NO_INDEX;

        // Sin autor conocido: {teamcolor} se elimina, como en colors.inc
        ReplaceString(szMessage, maxlength, "{teamcolor}", "", false);
        ReplaceString(szMessage, maxlength, "{default}", "\x01", false);
        ReplaceString(szMessage, maxlength, "{green}", "\x04", false);
        ReplaceString(szMessage, maxlength, "{olive}", "\x05", false);

        // {blue} es color de EQUIPO en L4D2 (equipo 2 = supervivientes = azul):
        // SayText2 lo pinta con el color del autor de ese equipo.
        if (StrContains(szMessage, "{blue}", false) != -1) {
                iAuthor = CF_TeamPlayer(2);

                if (iAuthor == CF_NO_PLAYER) {
                        // Sin jugadores del equipo: se degrada a verde (mismo colors.inc)
                        ReplaceString(szMessage, maxlength, "{blue}", "\x04", false);
                } else {
                        ReplaceString(szMessage, maxlength, "{blue}", "\x03", false);
                }
        }

        return iAuthor;
}

// Envia un SayText2 (bitbuffer o protobuf segun el engine).
stock void CF_SayText2(int client, int author, const char[] szMessage)
{
        Handle hBuffer = StartMessageOne("SayText2", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);

        if (GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available
                && GetUserMessageType() == UM_Protobuf)
        {
                PbSetInt(hBuffer, "ent_idx", author);
                PbSetBool(hBuffer, "chat", true);
                PbSetString(hBuffer, "msg_name", szMessage);
                PbAddString(hBuffer, "params", "");
                PbAddString(hBuffer, "params", "");
                PbAddString(hBuffer, "params", "");
                PbAddString(hBuffer, "params", "");
        } else {
                BfWriteByte(hBuffer, author);
                BfWriteByte(hBuffer, true);
                BfWriteString(hBuffer, szMessage);
        }

        EndMessage();
}

// Quita los tags (para consola/servidor, que no renderizan colores).
stock void CF_RemoveTags(char[] szMessage, int maxlength)
{
        ReplaceString(szMessage, maxlength, "{teamcolor}", "", false);
        ReplaceString(szMessage, maxlength, "{default}", "", false);
        ReplaceString(szMessage, maxlength, "{green}", "", false);
        ReplaceString(szMessage, maxlength, "{olive}", "", false);
        ReplaceString(szMessage, maxlength, "{blue}", "", false);
}

// Mismos nombres y firmas que colors.inc: las 73 llamadas del plugin no
// se tocan.
stock void CPrintToChat(int client, const char[] szMessage, any ...)
{
        if (client < 1 || client > MaxClients) {
                ThrowError("Invalid client index %d", client);
        }

        if (!IsClientInGame(client)) {
                ThrowError("Client %d is not in game", client);
        }

        char szBuffer[CF_MAXLEN];
        char szCMessage[CF_MAXLEN];

        SetGlobalTransTarget(client);

        FormatEx(szBuffer, sizeof(szBuffer), "\x01%s", szMessage);
        VFormat(szCMessage, sizeof(szCMessage), szBuffer, 3);

        int index = CF_Format(szCMessage, sizeof(szCMessage));

        if (index == CF_NO_INDEX) {
                PrintToChat(client, "%s", szCMessage);
                return;
        }

        CF_SayText2(client, index, szCMessage);
}

stock void CReplyToCommand(int client, const char[] szMessage, any ...)
{
        char szCMessage[CF_MAXLEN];

        SetGlobalTransTarget(client);
        VFormat(szCMessage, sizeof(szCMessage), szMessage, 3);

        if (client == 0) {
                CF_RemoveTags(szCMessage, sizeof(szCMessage));
                PrintToServer("%s", szCMessage);
                return;
        }

        if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE) {
                CF_RemoveTags(szCMessage, sizeof(szCMessage));
                PrintToConsole(client, "%s", szCMessage);
                return;
        }

        CPrintToChat(client, "%s", szCMessage);
}

#define PLUGIN_FCVAR                    FCVAR_NOTIFY
#define PLUGINS_NAME                    "[L4D2] Pet Fusion"

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
#define SND_BONE                        "player/tank/hit/hulk_punch_2.wav"   // v36: ruptura de huesos — impacto contra la pared (pedido del usuario: queda mejor que el sonido de Poppy)
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


#define SPRITE_BEAMS "materials/sprites/laserbeam.vmt"
#define SPRITE_HALOS "materials/sprites/halo01.vmt"
#define HEALTH_SOUND "player/water/pl_wade2.wav"

// Models
#define LUNA_DEFAULT_MODEL "models/pet/vex/default/default.mdl"
#define LUNA_DAWN_MODEL "models/pet/vex/dawn/dawn.mdl"
#define LUNA_SHADOW_MODEL "models/pet/vex/shadow/shadow.mdl"

#define RAVEN_DEFAULT_MODEL "models/pet/poppy/default/default.mdl"
#define RAVEN_NOXUS_MODEL "models/pet/poppy/noxus/noxus.mdl"
#define RAVEN_SNOWY_MODEL "models/pet/poppy/snowy/snowy.mdl"

#define SNOWY_DEFAULT_MODEL "models/pet/anivia/default/default.mdl"
#define SNOWY_EAGLE_MODEL "models/pet/anivia/eagle/eagle.mdl"
#define SNOWY_HEXTECH_MODEL "models/pet/anivia/hextech/hextech.mdl"

#define SPYRO_DEFAULT_MODEL "models/pet/smolder/default/default.mdl"
#define SPYRO_HEAVEN_MODEL "models/pet/smolder/heaven/heaven.mdl"
#define SPYRO_REINDEER_MODEL "models/pet/smolder/reindeer/reindeer.mdl"

#define GHOSTY_DEFAULT_MODEL "models/pet/thresh/default/default.mdl"
#define GHOSTY_JANITOR_MODEL "models/pet/thresh/janitor/janitor.mdl"
#define GHOSTY_MOON_MODEL "models/pet/thresh/moon/moon.mdl"

#define STORM_DEFAULT_MODEL "models/pet/volibear/default/default.mdl"
#define STORM_DEMON_MODEL "models/pet/volibear/demon/demon.mdl"
#define STORM_TIGER_MODEL "models/pet/volibear/tiger/tiger.mdl"

#define EMBER_DEFAULT_MODEL "models/pet/ornn/default/default.mdl"
#define EMBER_CHOOCHOO_MODEL "models/pet/ornn/choochoo/choochoo.mdl"
#define EMBER_THUNDER_MODEL "models/pet/ornn/thunder/thunder.mdl"

#define WARWICK_HUNTER_MODEL "models/pet/warwick/hunter/hunter.mdl"
#define WARWICK_FIREFANG_MODEL "models/pet/warwick/firefang/firefang.mdl"
#define WARWICK_BIGBAD_MODEL "models/pet/warwick/bigbad/bigbad.mdl"

// Configurable parameters
#define STEP_REACH_DISTANCE   20.0   // When the Companion considers a path step reached
#define CLIENT_NEAR_DISTANCE  80.0   // When Companion is close enough to you to reset steps
#define TELEPORT_DISTANCE  800.0   // When Companion is close enough to you to reset steps
#define MAX_STEPS_MEMORY 512 // How many steps the Companion remembers
#define PET_MOVE_INTERVAL 0.1 // Set the interval between every step to remember

enum
{
	L4D2Class_Unknown = 0,
	L4D2Class_Smoker,
	L4D2Class_Boomer,
	L4D2Class_Hunter,
	L4D2Class_Spitter,
	L4D2Class_Jockey,
	L4D2Class_Charger,
	L4D2Class_Witch,
	L4D2Class_Tank,
	L4D2Class_Survivor
};

enum
{
	L4D2Team_Unknown = -1,
	L4D2Team_Unassigned,
	L4D2Team_Spectator,
	L4D2Team_Survivor,
	L4D2Team_Infected
}

// Cookie Handles
Cookie g_hPetSettings;
Cookie g_hPetAutoAbilities;

// Companion Main Variables
int g_iPet_Entity[MAXPLAYERS+1];
int g_iPet_MoveType [MAXPLAYERS+1];
char g_sPet_Name [MAXPLAYERS+1][16];
char g_sPet_Skin [MAXPLAYERS+1][16];
char g_sPet_Aura [MAXPLAYERS+1][16];
char g_sPet_Size [MAXPLAYERS+1][16];

// Steps Variables
int g_iSavedStep[MAXPLAYERS+1];
int g_iLoadedStep[MAXPLAYERS+1];
int g_iFollowTarget[MAXPLAYERS+1];
bool g_bPetPaused[MAXPLAYERS+1];
float g_fPlayerSteps[MAX_STEPS_MEMORY][MAXPLAYERS+1][3];
float g_fLastStepWriteTime[MAXPLAYERS+1];
float g_fPet_AnimLock[MAXPLAYERS+1];

// Teleport Variables
int g_iLastTeleportTime[MAXPLAYERS+1];
bool g_bIsTeleportPet[MAXPLAYERS+1];

// Create Beam Ring
int g_iBeamSprite;
int g_iHaloSprite;

// Auto Abilities
bool g_bAutoHeal[MAXPLAYERS+1];
bool g_bAutoAntiPuke[MAXPLAYERS+1];
bool g_bAutoRevive[MAXPLAYERS+1];
bool g_bAutoAmmo[MAXPLAYERS+1];
bool g_bAutoAdren[MAXPLAYERS+1];

// Reviving Related Variables
bool g_bTeammate_Reviving[MAXPLAYERS+1];
bool g_bPetReviveActive[MAXPLAYERS+1];
bool g_bReviveInProgress[MAXPLAYERS+1];
float g_fSetupProgressTime[MAXPLAYERS+1];

// Abilities Cooldown
int g_iHealing_Cooldown[MAXPLAYERS+1];
int g_iAntiPuke_Cooldown[MAXPLAYERS+1];
int g_iRevive_Cooldown[MAXPLAYERS+1];
int g_iAmmoRefill_Cooldown[MAXPLAYERS+1];
int g_iAdrenBoost_Cooldown[MAXPLAYERS+1];
int g_iPlayerOnVomit [MAXPLAYERS+1];

// Timers Handles
Handle g_hTimer_MoveIn [MAXPLAYERS+1];
Handle g_hTimer_MoveOut [MAXPLAYERS+1];
Handle g_hTimer_ReviveCheck[MAXPLAYERS+1];
Handle g_hTimer_CheckAutoAbilities[MAXPLAYERS+1];

// v1.3: DataPack del revive rastreado en global (evita leaks) + flag de congelado
Handle g_hRevivePack[MAXPLAYERS+1];
// v56: Revivir inteligente — segundos de CD ahorrados (bajas de especiales
// y corte de emergencia), corte de equipo ya aplicado, presa reclamada y
// objetivo de seguimiento a restaurar al terminar el revive.
int g_iReviveSaved[MAXPLAYERS+1];
bool g_bReviveWipeCut[MAXPLAYERS+1];
int g_iReviveFollowRestore[MAXPLAYERS+1];
int g_iPetRevivingTarget[MAXPLAYERS+1];
// v56: menus con numeros en vivo (1 = Poderes de apoyo, 2 = menu campeon)
int g_iLiveMenu[MAXPLAYERS+1];
Handle g_hLiveMenuTimer[MAXPLAYERS+1];
bool g_bMenuSelfRefresh[MAXPLAYERS+1];
bool g_bPetFrozeTarget[MAXPLAYERS+1];

// Cvars
ConVar g_Cvar_Pet_Plugin_Enable;
ConVar g_Cvar_PetHealCooldown;
ConVar g_Cvar_PetHealAmount;
ConVar g_Cvar_PetAntipukeCooldown;
ConVar g_Cvar_PetReviveCooldown;
ConVar g_Cvar_PetAmmoRefillCooldown;
ConVar g_Cvar_PetAdrenBoostCooldown;
ConVar g_Cvar_Server_MenuSound;
ConVar g_Cvar_Server_Adren_Duration;

// Cvars Changed
bool g_bPluginEnable;
int g_iPet_HealCooldown;
int g_iPet_HealAmount;
int g_iPet_AntiPukeCooldown;
int g_iPet_ReviveCooldown;
int g_iPet_AmmoRefillCooldown;
int g_iPet_AdrenBoostCooldown;


/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *												OnPluginStart + OnMapStart										   *
 *================================================================================================================ */


/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *												On Convar Changed		 										   *
 *================================================================================================================ */

// ============================================================================
// v45 FUSION — MODULO CAMPEONES (DECLARACIONES)
// ============================================================================
// Segunda generacion del sistema de campeones LoL (Vex, Poppy, Anivia,
// Smolder, Thresh, Volibear, Ornn, Warwick):
//   - VELOCIDAD DE ATAQUE que crece con el nivel (+2.5%/nivel, tope 2.5x).
//   - IA de prioridades estilo bot: SALVAR duegna > ultimate > combo >
//     control de horda > poke > pasivas.
//   - Habilidades FIELES a LoL con Q/W/E/R + pasiva (la R es ultimate).
//   - EFECTOS GRAFICOS en cada habilidad (libreria ChampFX: beams, anillos,
//     pilares, chispas, temblor, estelas, marcas de luz que contraen).
//   - ATURDIMIENTO REAL del motor (L4D_StaggerPlayer de left4dhooks, el
//     mismo sistema de stagger que usan los Sonic chars del servidor) con
//     red de seguridad L4D_CancelStagger para que ningun bot SI quede
//     tirado en el suelo.
//   - Embestidas con deslizamiento visible (Poppy E / Ornn E / Vex R /
//     Smolder E), lanzamientos al aire con aterrizaje (Poppy R / Ornn R),
//     zonas persistentes (Anivia R / Thresh R) y muros de hielo.
//   - Presencia Inquebrantable (Poppy W): BLOQUEA en seco los saltos de hunter,
//     jockey y charger hacia la duegna (patron del "block" de Knuckles).
// ============================================================================

#define CHAMP_COUNT            8

// nombres internos (orden = tabla SQLite + menu de seleccion)
static const char g_sChampNames[CHAMP_COUNT][16] =
{
    "Luna", "Raven", "Snowy", "Spyro", "Ghosty", "Storm", "Ember", "Warwick"
};
static const char g_sChampLoL[CHAMP_COUNT][16] =
{
    "Vex", "Poppy", "Anivia", "Smolder", "Thresh", "Volibear", "Ornn", "Warwick"
};
static const char g_sChampTitle[CHAMP_COUNT][32] =
{
    "la Triste Maliciosa",       // Luna / Vex
    "la Guardiana del Martillo", // Raven / Poppy
    "el Criofenix",              // Snowy / Anivia
    "el Dragoncito",             // Spyro / Smolder
    "el Carcelero de las Almas", // Ghosty / Thresh
    "la Tormenta Indomable",     // Storm / Volibear
    "el Herrero de las Cumbres", // Ember / Ornn
    "la Ira Encadenada"          // Warwick / Warwick
};
static const char g_sChampQ[CHAMP_COUNT][48] =
{
    "Bolido Mestral (linea sombria)",        // Luna
    "Golpe de Martillo (% vida max)",        // Raven
    "Hielo Destello (congela en linea)",     // Snowy
    "Tiro Candente (quema a distancia)",     // Spyro
    "Sentencia de Muerte (engancho y arrastra)", // Ghosty
    "Golpe Tronador (empodera el golpe)",    // Storm
    "Ruptura Volcanica (grieta de lava)",    // Ember
    "Fauces de la Bestia (muerde y te cura)" // Warwick
};
static const char g_sChampW[CHAMP_COUNT][48] =
{
    "Espacio Personal (nova que empuja)",    // Luna
    "Presencia Inquebrantable (frena y bloquea)",  // Raven (nombre oficial)
    "Cristalizar (muro de hielo)",           // Snowy
    "¡Achus! (cono que derriba)",            // Spyro
    "Pasaje Siniestro (farol = escudo)",     // Ghosty
    "Mordida Frenetica (muerde y te cura)",  // Storm
    "Aliento de Fuelle (cono de fuego)",     // Ember
    "Caza de Sangre (marca la presa)"        // Warwick
};
static const char g_sChampE[CHAMP_COUNT][48] =
{
    "Oscuridad Inminente (marca Fatalidad)", // Luna
    "Carga Heroica (area: hasta 3 lanzados)", // Raven
    "Picadura Helada (x2 sobre congelado)",  // Snowy
    "Vuelo Ardiente (embestida que quema)",  // Spyro
    "Latigazo (barre el frente)",            // Ghosty
    "Cielo Hendido (rayo del cielo)",        // Storm
    "Carga Abrasadora (pared = onda sismica)", // Ember
    "Aullido Primal (aturde a la manada)"    // Warwick
};
static const char g_sChampR[CHAMP_COUNT][56] =
{
    "Avalancha Siniestra (embestida sombria)",  // Luna
    "Veredicto del Guardián (onda voladora; pared = final)", // Raven (nombre oficial)
    "Tormenta Glacial (tormenta de area 5 s)",  // Snowy
    "Lluvia de Fuego (5 explosiones)",          // Spyro
    "La Jaula (prision espectral 5 s)",         // Ghosty
    "Anuncio de la Tormenta (rugido aturdidor)", // Storm
    "Llamada del Dios Forja (oleada)",          // Ember
    "Duelo Infinito (suprime con 6 golpes)"     // Warwick
};
static const char g_sChampP[CHAMP_COUNT][64] =
{
    "Fatalidad: sus hechizos marcan; el golpe detona (+70%)",           // Luna
    "Embajadora de Hierro: cada 8 s, golpe a distancia +60%",           // Raven
    "Renacer: con tu vida baja, escudo de hielo (60 s)",                // Snowy
    "Sobrecalentado: 5 brasas = estallido de area",                     // Spyro
    "Condenacion: cada baja cerca acumula almas (+0.6% dano)",          // Ghosty
    "Portador del Trueno: cada 4 golpes, cadena de rayos",              // Storm
    "Fragua Viviente: repara tu cargador cada 30 s",                    // Ember
    "Hambre Eterna: herida = +55% vel. ataque y +2% vida max"           // Warwick
};

// colores firma por campeon (beams, anillos, pilares y estelas)
static const int g_iChampColors[CHAMP_COUNT][4] =
{
    {170,  60, 255, 255},   // Luna  — morado sombrio
    {255, 200,  60, 255},   // Raven — dorado
    {120, 200, 255, 255},   // Snowy — cian hielo
    {255, 120,  40, 255},   // Spyro — naranja fuego
    {150, 255, 120, 255},   // Ghosty — verde alma
    { 80, 160, 255, 255},   // Storm — azul electrico
    {255,  80,  50, 255},   // Ember — rojo forja
    {255,  60,  80, 255}    // Warwick — rojo sangre
};

// cadencia base por campeon (estilo LoL: Spyro rapido, Ornn lento y fuerte)
static const float g_fChampBaseInterval[CHAMP_COUNT] =
{
    1.5,   // Luna / Vex
    1.7,   // Raven / Poppy
    1.8,   // Snowy / Anivia
    1.3,   // Spyro / Smolder
    1.9,   // Ghosty / Thresh
    1.5,   // Storm / Volibear
    2.1,   // Ember / Ornn
    1.4    // Warwick
};

// --- estado por jugador -----------------------------------------------------
int g_iChampSel[MAXPLAYERS + 1];                     // campeon activo (0-7)
int g_iChampLevel[MAXPLAYERS + 1][CHAMP_COUNT];      // nivel por campeon
int g_iChampXP[MAXPLAYERS + 1][CHAMP_COUNT];         // xp actual por campeon
int g_iChampKills[MAXPLAYERS + 1][CHAMP_COUNT];      // bajas historicas por campeon
bool g_bChampLoaded[MAXPLAYERS + 1];                 // progreso SQLite cargado
// --- v63 (v28): LA GUARDIANA — stats LoL reales + senuo (solo Poppy) --------
ConVar g_Cvar_PoppyStats;
ConVar g_Cvar_PoppyDecoy;
ConVar g_Cvar_PoppyDecoyCD;
ConVar g_Cvar_PoppyDecoyMult;
ConVar g_Cvar_PoppyTankMult;
ConVar g_Cvar_PoppyVision;
ConVar g_Cvar_PoppyLeash;
ConVar g_Cvar_PoppyAspd;
ConVar g_Cvar_PoppyRegen;
ConVar g_Cvar_PoppyADMult;
ConVar g_Cvar_PoppyHUD;
bool  g_bPoppyStats = true;
bool  g_bPoppyDecoy = true;
float g_fPoppyDecoyCD = 45.0;
float g_fPoppyDecoyMult = 5.0;
float g_fPoppyTankMult = 2.0;
float g_fPoppyVision = 1.30;
float g_fPoppyLeash = 1400.0;
// v77: METODO DE COMBATE de Poppy (persistente en la BD, tabla
// poppy_method): 0 = BOT (el clasico: pelea cerca y vuelve), 1 = DPS
// (caza por su cuenta y solo regresa si te meten en problemas), 2 = TANK
// (caza y se planta en el centro de la pelea), 3 = SUP (siempre pegada)
#define POPPY_M_BOT  0
#define POPPY_M_DPS  1
#define POPPY_M_TANK 2
#define POPPY_M_SUP  3
int   g_iPoppyMethod[MAXPLAYERS + 1];
bool  g_bFaroNativesOK = false;               // v78: nativos de nav disponibles (l4dh reciente)
bool  g_bPoppyFaroLoose[MAXPLAYERS + 1];      // v78: excursion en curso (cuerda suelta, sticky)
float g_fPoppyFaroLive[MAXPLAYERS + 1];       // v78: latido de actividad lejos de casa (10 s = rescate)
float g_vPoppyFaroPoint[MAXPLAYERS + 1][3];   // v78: waypoint activo del faro
int   g_iPoppyFaroArea[MAXPLAYERS + 1];       // v78: id del nav area del waypoint (0 = sin waypoint)
float g_fPoppyFaroNext[MAXPLAYERS + 1];       // v78: throttle del recomputo del waypoint (0.4 s)
float g_fPoppyFaroLastD[MAXPLAYERS + 1];      // v78: distancia al waypoint (detector de atasco)
float g_fPoppyFaroStuckAt[MAXPLAYERS + 1];    // v78: desde cuando sin progreso hacia el waypoint
int   g_iPoppyFaroBlkArea[MAXPLAYERS + 1];    // v78: area vetada (puerta cerrada / borde / atasco)
float g_fPoppyFaroBlkUntil[MAXPLAYERS + 1];   // v78: hasta cuando se ignora el area vetada
float g_fPoppyTgtPathNext[MAXPLAYERS + 1];    // v78: cache del veredicto de camino a la presa (0.75 s)
bool  g_bPoppyTgtPathBad[MAXPLAYERS + 1];     // v78: true = presa inalcanzable por nav (muro)

// v79 (duena): LA RUTA REAL — el port del algoritmo de su l4d_path_to_goal
// (la cadena de celdas que ese sistema dibuja con beams desde tu posicion
// hasta la zona segura). Poppy DPS/TANK la SIGUE celda a celda.
enum struct FaroCell
{
    float flow;
    Address navArea;
    float center[3];
}
ArrayList g_FaroRoute;                       // la cadena: 0 = inicio del mapa, last = la meta
bool      g_bFaroRouteReady;
bool      g_bFaroRouteBuilding;
int       g_iFaroStage;                      // 0 idle, 1 colecta, 2 ordena, 3 construye
int       g_iFaroLoop;
int       g_iFaroRetries;
float     g_fFaroFrameStart;
ArrayList g_FaroAreas;                       // etapa 1: todas las areas del nav
ArrayList g_FaroCells;                       // etapa 1->3: celdas escape recolectadas
ArrayList g_FaroAdj;                         // vecinos del stitch (reutilizado)
ArrayList g_FaroExplored;                    // areas ya visitadas por el stitch
ArrayList g_FaroBridge;                      // tramo puente del stitch
float     g_fFaroMaxFlow;
float     g_fFaroFlowStart;
float     g_fFaroFlowEnd;
Address   g_aFaroStart;
Address   g_aFaroEnd;
bool      g_bFaroMissingStart;
bool      g_bFaroMissingEnd;
float     g_tFaroNav;                        // cooldown tras eventos de nav (patron PTG)
bool      g_bFaroBlkOK;                      // L4D_NavArea_IsBlocked disponible
int       g_iPoppyFaroIdx[MAXPLAYERS + 1];   // v79: celda OBJETIVO en la cadena
float     g_fPoppyFaroWptAt[MAXPLAYERS + 1]; // v79: cuando se tomo el waypoint (salto de fe)
float     g_fPoppyFaroWarpAt[MAXPLAYERS + 1];// v79: cooldown del salto de fe
bool      g_bPoppyFaroTold[MAXPLAYERS + 1];  // v79: aviso "ruta cargada" ya dado este mapa
float g_fPoppyFastNext[MAXPLAYERS + 1];   // v77: anti-spam del rastreo en vivo
float g_fPoppyAspd = 1.15;
float g_fPoppyRegen = 5.0;
float g_fPoppyADMult = 0.60;
int   g_iPoppyHUDMode = 1;                // v64: 0=off, 1=siempre visible, 2=solo daño o provocando
float g_fPoppyHP[MAXPLAYERS + 1];        // vida actual de Poppy (barra real)
float g_fPoppyLastHit[MAXPLAYERS + 1];   // ultimo dano absorbido (para el regen)
float g_fPoppyHUDNext[MAXPLAYERS + 1];   // throttle del HUD
int   g_iPoppyLvlSeen[MAXPLAYERS + 1];   // nivel ya aplicado a la barra
bool  g_bPoppyHurt[MAXPLAYERS + 1];      // retirada por herida
bool  g_bPoppyLOSOK[MAXPLAYERS + 1];     // LOS cacheada del paso de combate
float g_fPoppyLOSNext[MAXPLAYERS + 1];
// v37 (v74): guardia de la dueña con CACHE. La v36 la reevaluaba CADA FRAME
// (OnGameFrame) con un PetEnemiesInRadius (2 escaneos completos de entidades
// por frame) y los "return true" de dentro del loop se saltaban el
// "delete list": un Handle de ArrayList perdido POR FRAME mientras un
// especial/witch estuviera a 250 u de la dueña.
bool  g_bPoppyGuardLast[MAXPLAYERS + 1];   // ultimo veredicto del guardia
float g_fPoppyGuardNext[MAXPLAYERS + 1];   // cuando vuelve a escanear
float g_fPoppyHoldIdleAt[MAXPLAYERS + 1];  // throttle del Idle al estar plantada
// v35 (v72): MULTI-SENUO — cada duena de Poppy tiene SU bot prestado
// (todas las variables del senuo son por duena). PROTECCION: un bot
// prestado por una duena JAMAS puede ser tomado por otra (DecoyOwnerOfBot).
// DURACION ILIMITADA: sin reloj — el senuo termina cuando Poppy se
// retira herida o desaparece (RemovePet / PoppyRetreat).
int    g_iDecoyBot[MAXPLAYERS + 1];          // bot prestado por esta duena (-1 = sin senuo)
float  g_fDecoyNextAt[MAXPLAYERS + 1];       // cooldown del senuo (por duena)
float  g_fDecoyStripNext[MAXPLAYERS + 1];    // throttle del strip de items
float  g_fDecoyPinNext[MAXPLAYERS + 1];      // throttle de ruptura de pines
int    g_iDecoyLockFights[MAXPLAYERS + 1];   // v67 (v32): diagnostico de re-personalizacion (1/senuo)
// v70 (v33): registro del watchdog + identidad ORIGINAL del bot prestado
int    g_iDecoyBotUid[MAXPLAYERS + 1];       // userid del bot prestado (unico por conexion)
char   g_sDecoyOrigName[MAXPLAYERS + 1][32];                 // nombre original
int    g_iDecoyOrigChar[MAXPLAYERS + 1];     // personaje original
char   g_sDecoyOrigModel[MAXPLAYERS + 1][PLATFORM_MAX_PATH]; // modelo original
int    g_iDecoyOrigHP[MAXPLAYERS + 1];       // vida original del bot prestado
int    g_iDecoyPetRef[MAXPLAYERS + 1];       // v36: pet de Poppy al que YA se le presto bot (detecta invocacion nueva)
// v36: witch dentro de la zona W — velocidad por delta de posicion (la
// m_vecVelocity de los NextBots no siempre se actualiza) y throttle
float  g_vPoppyWZoneLast[2048][3];
float  g_fPoppyWZoneLastAt[2048];

char g_sChampSteam[MAXPLAYERS + 1][64];

// atribucion de bajas del campeon (espejo del g_PetHitOwner de la nave)
int g_iChampHitOwner[2048] = {-1, ...};
float g_fChampHitTime[2048];
bool g_bChampCredited[2048];                         // la baja ya pago XP de campeon

// --- combate ----------------------------------------------------------------
int g_iChampTarget[MAXPLAYERS + 1] = {-1, ...};      // entidad objetivo actual
float g_fChampNextAttack[MAXPLAYERS + 1];            // proximo auto-ataque
float g_fChampNextQ[MAXPLAYERS + 1];                 // cooldowns Q/W/E/R/P
float g_fChampNextW[MAXPLAYERS + 1];
float g_fChampNextE[MAXPLAYERS + 1];
float g_fChampNextR[MAXPLAYERS + 1];
float g_fChampNextP[MAXPLAYERS + 1];
float g_fChampFuryUntil[MAXPLAYERS + 1];             // Spyro E: furia activa
float g_fChampAspdUntil[MAXPLAYERS + 1];             // buffs de vel. de ataque
float g_fChampQEmpowerUntil[MAXPLAYERS + 1];         // Storm Q: golpe empoderado
int g_iChampStacks[MAXPLAYERS + 1];                  // brasas (Spyro) / tormenta (Storm)
float g_fChampFrostbiteAt[2048];                     // Snowy Q: marca de congelado
int g_iChampMarkRef[MAXPLAYERS + 1] = {-1, ...};     // Warwick W: presa marcada
float g_fChampMarkUntil[MAXPLAYERS + 1];
int g_iChampSouls[MAXPLAYERS + 1];                   // Ghosty P: almas
int g_iChampKillsMap[MAXPLAYERS + 1];                // Spyro P: bajas del mapa
int g_iChampMsgKills[MAXPLAYERS + 1];                // lote de avisos de comunes
int g_iChampMsgXP[MAXPLAYERS + 1];
float g_fChampAuraFxAt[MAXPLAYERS + 1];              // pulso visual de auras
int g_iChampAnimPrio[MAXPLAYERS + 1];                // v46: 0 fondo, 1 auto-ataque, 2 habilidad
float g_fChampRavenWUntil[MAXPLAYERS + 1];           // v46: ventana activa de la W de Poppy
float g_fChampRavenChargeUntil[MAXPLAYERS + 1];      // v51: R de Poppy en fase de CARGA (auto-expira)
float g_fChampReleaseAt[MAXPLAYERS + 1];             // v47: anti-bucle de liberacion (cooldown 1 s)
float g_fChampWGuardAt[2048];                        // v47: cooldown de castigo por atacante
bool g_bChampDashCarry[MAXPLAYERS + 1];              // v47: Poppy E con la presa agarrada

// --- marcas Fatalidad (Vex P) -----------------------------------------------
float g_fChampDoomUntil[2048];                       // la victima esta marcada
int g_iChampDoomOwner[2048];                         // quien puso la marca

// --- aturdimiento real + congelacion de comunes -----------------------------
bool g_bChampFrozeSI[2048];                          // guard del freeze de SI
bool g_bChampFrozen[2048];                           // guard del freeze de comunes
Handle g_hChampStagCancel[MAXPLAYERS + 1];           // cancel del stagger (anti bug)

// --- lanzamientos al aire (Poppy R / Ornn R) --------------------------------
ArrayList g_hChampLaunchList;                        // refs de victimas volando
float g_fChampLaunchedAt[2048];
int g_iChampLaunchedBy[2048];
float g_fChampLaunchDmg[2048];                      // dano al aterrizar

// --- v49: frozen como escudo + vuelo manual (patron Witch_Flight) ----------
float g_fChampFrozenAcc[2048];                       // v49: dano que el hielo NO dejo entrar
int g_iChampFrozenMT[2048];                          // v49: movetype ORIGINAL pre-hielo
bool g_bChampFlying[2048];                           // v49: vuela con integracion manual
float g_vChampFlightVel[2048][3];                    // v49: velocidad simulada
float g_fChampFlightStart[2048];                     // v49: inicio del vuelo
float g_fChampFlightLast[2048];                      // v49: ultimo tick (dt real)
float g_fChampFlightMaxAir[2048];                    // v49: aire maximo segun lanzamiento
int g_iChampFlightBy[2048];                          // v49: dueno del golpe (credito)
float g_fChampFlightDmg[2048];                       // v49: dano al aterrizar / bonus de pared
int g_iChampFlightKind[2048];                        // v49: 0 = R (Veredicto), 1 = E (empuje)
int g_iChampFlightMT[2048];                          // v49: movetype ORIGINAL pre-vuelo
ArrayList g_hChampFlightList;                        // v49: refs de los que vuelan
float g_vChampFlightFrom[2048][3];                     // v60: punto de lanzamiento (distancia al chocar)
int g_iChampFlightLvl[2048];                           // v60: nivel del campeon al lanzarlo (finish de la R)
Handle g_hChampFlightTick = null;                    // v49: tick 33 Hz (se apaga solo)
#define CHAMP_FLIGHT_VERDICT 0   // v49: R de Poppy — leva y caida pesada
#define CHAMP_FLIGHT_PUSH    1   // v49: E de Poppy — empuje; pared = stagger

// --- v49: el campeon vuelve SOLO (mastery activo desde el mapa nuevo) ------
bool g_bChampWanted[MAXPLAYERS + 1];                 // v49: persistido en cookie (campo 5)
bool g_bChampLoading[MAXPLAYERS + 1];                // v49: query de carga en vuelo
int g_iChampLoadUserid[MAXPLAYERS + 1];              // v49: para liberar flags huerfanos
float g_fChampLoadRetryAt[MAXPLAYERS + 1];           // v49: reintento cada 3 s en el motor

// --- embestidas / dashes (Poppy E, Vex R, Smolder E, Ornn E) ----------------
bool g_bChampDashing[MAXPLAYERS + 1];
float g_fChampDashEnd[MAXPLAYERS + 1];
int g_iChampDashTarget[MAXPLAYERS + 1];              // ref de la victima arrastrada
int g_iChampDashStyle[MAXPLAYERS + 1];
float g_fChampDashHitAt[2048];                       // victima ya golpeada por el dash

// estilos de dash
#define CHAMP_DASH_VEX      1   // AoE sombrio al llegar al destino
#define CHAMP_DASH_SMOLDER  2   // dana a todo el que cruza
#define CHAMP_DASH_ORNN     3   // pared = onda sismica en area

// --- zonas persistentes (Anivia R, Anivia W, Thresh R) ----------------------
bool g_bChampZoneActive[MAXPLAYERS + 1];             // el tick vive si esto es true
float g_fChampZoneUntil[MAXPLAYERS + 1];

// --- cvars de campeones -----------------------------------------------------
ConVar g_Cvar_ChampEnable;
ConVar g_Cvar_ChampRange;
ConVar g_Cvar_ChampDmg;
ConVar g_Cvar_ChampDmgLvl;
ConVar g_Cvar_ChampInterval;
ConVar g_Cvar_ChampCDMult;
ConVar g_Cvar_ChampXPCommon;
ConVar g_Cvar_ChampXPSpecial;
ConVar g_Cvar_ChampXPTank;
ConVar g_Cvar_ChampXPWitch;
ConVar g_Cvar_ChampMaxLevel;
ConVar g_Cvar_ChampAspdLvl;
ConVar g_Cvar_ChampAspdCap;
ConVar g_Cvar_ChampAI;
ConVar g_Cvar_ChampFX;
ConVar g_Cvar_ChampStagger;

bool g_bChampEnable;
float g_fChampRange;
int g_iChampDmgBase;
int g_iChampDmgPerLevel;
float g_fChampInterval;
float g_fChampAbCD;
int g_iChampXPCommon;
int g_iChampXPSpecial;
int g_iChampXPTank;
int g_iChampXPWitch;
int g_iChampMaxLevel;
float g_fChampAspdPct;
float g_fChampAspdCap;
bool g_bChampAI;
bool g_bChampFX;
float g_fChampStaggerMult;

// motor de combate (0.3 s), autoguardado (60 s) y vigilancia de vuelos (0.1 s):
// timers perpetuos, los handles no se retienen

#define SND_CHAMP_ZAP "ambient/energy/elec_big_spark1.wav"
bool g_bChampZapSnd;                                 // el sonido zap precacheo bien
public Plugin myinfo =
{
    name = PLUGINS_NAME,
    author = "GsiX (Rework v2.4)",
    description = "FUSION v45: nave bombardero (intacta) + 8 campeones LoL con XP propio, IA de prioridades, kits Q/W/E/R/P fieles, velocidad de ataque creciente y efectos graficos",
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

    // v78: nativos del FARO opcionales (left4dhooks ya los marca por su
    // cuenta al incluir su .inc; esto es el cinturon extra por si el
    // include de compilacion difiere del runtime): sin ellos el plugin
    // CARGA IGUAL y el faro se desactiva solo (navegacion clasica v40)
    MarkNativeAsOptional("L4D_GetNearestNavArea");
    MarkNativeAsOptional("L4D2Direct_GetTerrorNavArea");
    MarkNativeAsOptional("L4D2Direct_GetTerrorNavAreaFlow");
    MarkNativeAsOptional("L4D_GetNavAreaID");
    MarkNativeAsOptional("L4D_GetNavAreaCenter");
    MarkNativeAsOptional("L4D_NavArea_GetAdjacentAreas");
    MarkNativeAsOptional("L4D_NavArea_IsConnected");
    MarkNativeAsOptional("L4D2_NavAreaTravelDistance");

    // v79: la RUTA REAL (port de su l4d_path_to_goal) — mismos nativos que
    // usa su plugin de beams; con un left4dhooks viejo el faro queda apagado
    // y Poppy navega como siempre (carga igual)
    MarkNativeAsOptional("L4D_GetAllNavAreas");
    MarkNativeAsOptional("L4D_GetNavArea_SpawnAttributes");
    MarkNativeAsOptional("L4D2Direct_GetMapMaxFlowDistance");
    MarkNativeAsOptional("L4D_NavArea_IsBlocked");

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
    HookEvent("player_incapacitated", Event_PlayerIncapacitated);   // v56: IA revive inmediato
    HookEvent("bot_player_replace", Event_PlayerBotReplace);   // v63: humano tomo el cuerpo del senuo

    // v79: el nav manda en la RUTA REAL — post_nav = flow listo para
    // construirla; nav bloqueado/regenerado = reconstruir (patron PTG)
    HookEvent("round_start_post_nav", Event_FaroPostNav, EventHookMode_PostNoCopy);
    HookEvent("nav_blocked",          Event_FaroNavBlocked);
    HookEvent("nav_generate",         Event_FaroNavGenerate, EventHookMode_PostNoCopy);

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
    // v34 (v71): comando de modo del senuo (idea del usuario: "un comando
    // para elegir el modo que quiero"). Preferencia POR JUGADOR: sin
    // argumento muestra el modo actual.
    // v35 (v72): multi-senuo — los arrays de SourceMod nacen en 0, y el
    // convenio del senuo es -1 = "sin senuo": se inicializa AQUI (y en
    // cada OnMapStart) para que ningun slot arranque "prestado al bot 0".
    for (int i = 1; i <= MaxClients; i++) DecoyResetOwner(i);

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

    // v44 FUSION: modulo de campeones (companion v1.3 + combate/XP/kits)
    Champ_Init();

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
    GetCvars();   // v44 FUSION: refresca cvars del companion/campeones
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
    // v44 FUSION: descargas/precaches/reset del modulo de campeones
    Champ_OnMapStart();
    FaroCheckNatives();   // v78: el faro depende de los nativos de nav del left4dhooks
    FaroRouteReset();   // v79: la RUTA REAL no cruza mapas (nav nuevo = cadena nueva)
    // v35 (v72): los senuos no cruzan mapas (indices de cliente invalidos)
    for (int i = 1; i <= MaxClients; i++)
    {
        DecoyResetOwner(i);
        g_fDecoyNextAt[i] = 0.0;
        g_bPoppyGuardLast[i] = false;   // v37: el cache del guardia no cruza mapas
        g_fPoppyGuardNext[i] = 0.0;     // (GetGameTime se reinicia en cada mapa)
        g_fPoppyHoldIdleAt[i] = 0.0;
        g_fPoppyLOSNext[i] = 0.0;       // v37: el cache de LOS tampoco
        g_bPoppyLOSOK[i] = false;
        g_fPoppyFastNext[i] = 0.0;      // v77: el rastreo en vivo tampoco
        g_bPoppyFaroLoose[i] = false;   // v78: el faro tampoco cruza mapas
        g_fPoppyFaroLive[i] = 0.0;
        g_vPoppyFaroPoint[i][0] = 0.0;  // (y su waypoint)
        g_vPoppyFaroPoint[i][1] = 0.0;
        g_vPoppyFaroPoint[i][2] = 0.0;
        g_iPoppyFaroArea[i] = 0;
        g_fPoppyFaroNext[i] = 0.0;
        g_fPoppyFaroLastD[i] = 0.0;
        g_fPoppyFaroStuckAt[i] = 0.0;
        g_iPoppyFaroBlkArea[i] = 0;
        g_fPoppyFaroBlkUntil[i] = 0.0;
        g_fPoppyTgtPathNext[i] = 0.0;
        g_bPoppyTgtPathBad[i] = false;

        g_iPoppyFaroIdx[i] = 0;        // v79: indice en la cadena (por mapa)
        g_fPoppyFaroWptAt[i] = 0.0;
        g_fPoppyFaroWarpAt[i] = 0.0;
        g_bPoppyFaroTold[i] = false;
    }

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
    PrecacheSound(SND_BONE, true);   // v36: ruptura de huesos del estrellon (E)
    // v2.4: glow rojo de las minas + sonido de lengua de smoker (con fallback)
    g_sGlow = PrecacheModel("sprites/glow01.vmt");
    g_bTongueSnd = PrecacheSound(SND_SMOKER_TONGUE, true);
    // v2.5: particula REAL de la lengua (tabla de strings del engine)
    g_bTongueFx = PetPrecacheParticle("smoker_tongue");
    // v48: paleta de particulas REALES del juego para los campeones
    // (guiada por los efectos de los Super Tanks del servidor)
    PetPrecacheParticle("steam_manhole");            // chorro de vapor helado
    PetPrecacheParticle("steam_manhole_b");          // segundo chorro helado
    // v55: explosion_huge_d RETIRADA — el cliente no puede renderizarla
    PetPrecacheParticle("charger_wall_impact");      // estrellon contra pared
    PetPrecacheParticle("tank_rock_throw_impact");   // polvo del golpe en el suelo
    PetPrecacheParticle("weapon_grenade_explosion"); // detonacion clasica
    PetPrecacheParticle("fire_large_01");            // lengua de fuego grande
    PetPrecacheParticle("gas_explosion_fireball");   // bola de fuego
    PetPrecacheParticle("gas_explosion_ground_wave");// onda de fuego rasante
    PetPrecacheParticle("electrical_arc_01_system"); // arco electrico
    PetPrecacheParticle("storm_lightning_01");       // rayo de tormenta
    PetPrecacheParticle("storm_lightning_02");
    PetPrecacheParticle("smoker_smokecloud_cheap");  // humo oscuro (sombras)
    PetPrecacheParticle("spitter_areaofdenial");     // charco verde acido
    PetPrecacheParticle("blood_impact_arterial_spray_5"); // sangre arterial
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

    // v44 FUSION: respaldo del progreso de CAMPÉONES antes de soltar el mapa
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_bChampLoaded[i])
            ChampSaveProgress(i);
    }
    for (int i = 1; i <= MaxClients; i++)
        ResetClientState(i);
    FaroRouteReset();   // v79: la RUTA REAL no cruza mapas
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
    // v35 (v72): limpieza del MULTI-SENUO. Si quien se va es una DUEÑA con
    // prestamo activo, su bot se devuelve intacto (NUNCA kick: es parte de
    // los 4). Si quien se va es un BOT prestado, su duña queda libre con
    // el cooldown reembolsado (perdio el bot por causa externa).
    if (g_iDecoyBot[client] != -1)
        PoppyDecoy_End(client, false);
    int bowner = DecoyOwnerOfBot(client);
    if (bowner > 0)
    {
        DecoyResetOwner(bowner);
        g_fDecoyNextAt[bowner] = 0.0;   // reembolso: el bot se fue solo
        if (IsClientInGame(bowner))
            CPrintToChat(bowner, "{green}[Raven]{default} El bot de tu senuo salio del servidor: provocacion cancelada (sin recarga).");
    }
    g_fPoppyHP[client] = 0.0;
    g_bPoppyHurt[client] = false;
    g_iPoppyLvlSeen[client] = 0;
    g_fPoppyLastHit[client] = 0.0;
    g_fPoppyHUDNext[client] = 0.0;
    g_fPoppyLOSNext[client] = 0.0;
    g_bPoppyLOSOK[client] = false;
    g_bPoppyGuardLast[client] = false;   // v37: cache del guardia
    g_fPoppyGuardNext[client] = 0.0;
    g_fPoppyHoldIdleAt[client] = 0.0;
    g_bPoppyFaroLoose[client] = false;   // v78: excursion y caches del faro
    g_fPoppyFaroLive[client] = 0.0;
    g_iPoppyFaroArea[client] = 0;
    g_iPoppyFaroBlkArea[client] = 0;
    g_fPoppyFaroBlkUntil[client] = 0.0;
    g_fPoppyTgtPathNext[client] = 0.0;
    g_bPoppyTgtPathBad[client] = false;

    g_iPoppyFaroIdx[client] = 0;   // v79: cadena y salto de fe
    g_fPoppyFaroWptAt[client] = 0.0;
    g_fPoppyFaroWarpAt[client] = 0.0;
    g_bPoppyFaroTold[client] = false;

    // v2.6: si la lengua de este jugador tenia a alguien colgado, soltarlo
    // ANTES de resetear el estado (si no, quedaria congelado para siempre)
    CleanupTongue(client);
    PetSaveProgress(client);

    // v44 FUSION: estado del companion + progreso de campeones
    SavePetCookies_Settings(client);
    SavePetCookies_Abilities(client);
    RemovePet(client);
    g_bTeammate_Reviving[client] = false;
    g_iPlayerOnVomit[client]     = 0;
    g_bPetFrozeTarget[client]    = false;
    g_iHealing_Cooldown[client]    = 0;
    g_iAntiPuke_Cooldown[client]   = 0;
    g_iRevive_Cooldown[client]     = 0;
    g_iAmmoRefill_Cooldown[client] = 0;
    g_iAdrenBoost_Cooldown[client] = 0;
    g_iReviveSaved[client] = 0;          // v56
        g_bReviveWipeCut[client] = false;    // v56
        g_iReviveFollowRestore[client] = 0;  // v56
        g_iPetRevivingTarget[client] = 0;    // v56
        g_iLiveMenu[client] = 0;             // v56: menu vivo fuera
        g_bMenuSelfRefresh[client] = false;  // v56
        delete g_hLiveMenuTimer[client];     // v56
        g_hLiveMenuTimer[client] = null;     // v56
    Champ_SaveDisconnect(client);
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
    // v66 (v31): EL JUEGO "ADOPTA" AL SENUO. Cuando le asigna personaje a
    // un bot superviviente, lo respawnea (player_spawn) con SU modelo, SU
    // nombre y el render reseteado. En ese MISMO frame: candado de
    // identidad + pegado inmediato de vuelta al cuerpo de Poppy.
    int sclient = GetClientOfUserId(event.GetInt("userid"));
    if (sclient > 0 && IsClientInGame(sclient) && IsFakeClient(sclient))
    {
        int sowner = DecoyOwnerOfBot(sclient);   // v35 (v72): ¿es un bot prestado?
        if (sowner != -1)
        {
            DecoyLockVisuals(sclient, sowner);
            StripDecoyItems(sclient);
            SetEntProp(sclient, Prop_Send, "m_iHealth", 2000);
            if (IsClientInGame(sowner) && IsPetValid(sowner))
            {
                int spet = EntRefToEntIndex(g_iPet_Entity[sowner]);
                if (spet > 0 && IsValidEntity(spet))
                {
                    float sPos[3];
                    GetEntPropVector(spet, Prop_Data, "m_vecOrigin", sPos);
                    TeleportEntity(sclient, sPos, NULL_VECTOR, NULL_VECTOR);
                }
            }
        }
    }
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
    // v35 (v72): TODOS los senuos se disuelven al acabar la ronda (sin CD)
    PoppyDecoy_EndAll(false);
    for (int i = 1; i <= MaxClients; i++) g_fDecoyNextAt[i] = 0.0;

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

    // ---- v44 FUSION: baja de especial/tank lograda por un CAMPEON ---------
    if (victim > 0 && victim < 2048 && g_iChampHitOwner[victim] > 0
        && IsValidClient(victim) && GetClientTeam(victim) == 3)
    {
        int champOwner = g_iChampHitOwner[victim];
        if (champOwner != victim && IsValidClient(champOwner) && g_bChampLoaded[champOwner]
            && GetGameTime() - g_fChampHitTime[victim] < 5.0)
        {
            int xpChamp = (GetEntProp(victim, Prop_Send, "m_zombieClass") == 8)
                ? g_iChampXPTank : g_iChampXPSpecial;
            Champ_CreditKill(champOwner, victim, xpChamp, true);
        }
        g_iChampHitOwner[victim] = -1;
    }

    // ---- XP: baja de especial lograda por la nave (dano reciente) ---------
    if (victim > 0 && victim < 2048 && g_PetHitOwner[victim] > 0
        && IsValidClient(victim) && GetClientTeam(victim) == 3)
    {
        int owner = g_PetHitOwner[victim];
        if (owner != victim && IsValidClient(owner) && g_PetLevelLoaded[owner]
            && GetGameTime() - g_PetHitTime[victim] < 5.0)
        {
            PetCountKill(owner);
            PetReviveOnSpecialKill(owner, g_PetLevel[owner]);   // v56: la nave tambien gana Revivir
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

    // ---- v44 FUSION: baja de comun lograda por un CAMPEON -----------------
    if (victim > 0 && victim < 2048 && g_iChampHitOwner[victim] > 0)
    {
        int champOwner = g_iChampHitOwner[victim];
        if (IsValidClient(champOwner) && g_bChampLoaded[champOwner]
            && GetGameTime() - g_fChampHitTime[victim] < 4.0)
        {
            g_bChampCredited[victim] = true;   // la nave no re-acredita la baja
            Champ_CreditKill(champOwner, victim, g_iChampXPCommon, false);
        }
        g_iChampHitOwner[victim] = -1;
    }

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
    if (owner == 0 && !g_bChampCredited[victim])
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
    g_bChampCredited[victim] = false;   // v44 FUSION
}

// XP: baja de witch causada por la nave
public void EVENT_WitchKilled(Event event, const char[] name, bool dontBroadcast)
{
    if (g_enable == 0) return;
    g_ChapWitches++;   // v2.8: puntaje del capitulo
    int witch = event.GetInt("witchid");

    // v44 FUSION: witch derribada por un campeon
    if (witch > 0 && witch < 2048 && g_iChampHitOwner[witch] > 0)
    {
        int champOwner = g_iChampHitOwner[witch];
        if (IsValidClient(champOwner) && g_bChampLoaded[champOwner]
            && GetGameTime() - g_fChampHitTime[witch] < 5.0)
            Champ_CreditKill(champOwner, witch, g_iChampXPWitch, true);
        g_iChampHitOwner[witch] = -1;
    }
    if (witch <= 0 || witch >= 2048 || g_PetHitOwner[witch] <= 0) return;

    int owner = g_PetHitOwner[witch];
    if (IsValidClient(owner) && g_PetLevelLoaded[owner] && GetGameTime() - g_PetHitTime[witch] < 5.0)
    {
        PetCountKill(owner);
        PetReviveOnSpecialKill(owner, g_PetLevel[owner]);   // v56: witch abatida por la nave
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
        // v70 (v33): IsClientInGame PRIMERO: IsFakeClient sobre un slot a
        // medio desconectar lanza "Client is not connected" y aborta todo
        // el callback (crash v32 en el autosave/XP justo tras el kick)
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
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
    LoadPetCookies(client);   // v44 FUSION: skin/glow/tamano del campeon
    g_iChampSel[client] = ChampIdOf(g_sPet_Name[client]);   // v44 FUSION
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
    // v48: Thresh (campeon) escala la lengua con su nivel de CAMPEON
    // (+0.10/nv); la nave conserva su +0.30/nv de siempre
    if (g_iChampSel[client] >= 0)
        return 1.0 + float(g_iChampLevel[client][g_iChampSel[client]]) * 0.10;
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
    // v35 (v72): barrido anti-residuo. Si un cuerpo renombrado "Poppy"
    // de un senuo anterior sobrevivio a un crash del server, se NORMALIZA:
    // visible, IA al 100%, vida 100 — jamas queda un bot invisible
    // congelado para siempre. Los bots prestados ACTIVOS quedan fuera.
    if (IsFakeClient(client))
    {
        char sRes[32];
        GetClientName(client, sRes, sizeof(sRes));
        if (DecoyOwnerOfBot(client) == -1 && StrEqual(sRes, "Poppy"))
        {
            SetEntityRenderMode(client, RENDER_NORMAL);
            SetEntityRenderColor(client, 255, 255, 255, 255);
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
            if (IsPlayerAlive(client))
                SetEntProp(client, Prop_Send, "m_iHealth", 100);
            PrintToServer("[Raven] La Guardiana: normalizado un cuerpo de clon residual (slot %d).", client);
        }
        return;
    }
    g_PetPendingXP[client] = 0;
    g_PetPendingKills[client] = 0;
    g_PetPendingHeals[client] = 0;
    g_bChampWanted[client] = false;   // v49: la cookie lo reactivara al cachearse
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
    Champ_DBLoad(client);   // v44 FUSION: campeones por el mismo embudo (3 vias)
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
        // v70 (v33): IsClientInGame PRIMERO (mismo fix que el XP de
        // supervivencia): el crash "Client 2 is not connected" nacia aqui
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
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
    Champ_StatusLines(client);   // v44 FUSION: estado del campeon activo
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
    menu.Pagination = 7;   // v44 FUSION: 11 entradas tras unir campeones

    char title[224];
    char status[48];
    if (PetIsActive(client))
        Format(status, sizeof(status), "ACTIVO (%d s)", RoundToCeil(g_petmaxlife - g_PetLife[client]));
    else
        strcopy(status, sizeof(status), "no invocado");

    char styleName[26];
    PetStyleName(client, styleName, sizeof(styleName));
    Format(title, sizeof(title),
        "Pet Navideño  [Nv %d | XP %d/%d]\nPet: %s  |  IA: %s\nArma: %s  |  Misil: %s\nRuta: %s  |  Granadas: %s\nCampeón: %s [Nv %d]\n ",
        g_PetLevel[client], g_PetXP[client], PetXPToNext(g_PetLevel[client]),
        status, g_AINames[g_PetAIMode[client]], g_WeaponNames[g_PetWeapon[client]], styleName,
        g_RouteNames[g_PetRoute[client]], g_PetGrenade[client] ? "ON" : "OFF",
        g_sPet_Name[client], g_iChampLevel[client][ChampIdOf(g_sPet_Name[client])]);
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
    char champItem[72];
    FormatEx(champItem, sizeof(champItem), "Campeones: %s [Nv %d]",
        g_sPet_Name[client], g_iChampLevel[client][ChampIdOf(g_sPet_Name[client])]);
    menu.AddItem("champ", champItem);
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
    else if (StrEqual(info, "champ")) ShowChampMenu(client);   // v44 FUSION
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
    // v44 FUSION: exclusividad mutua — invocar la nave retira al campeon
    Champ_DismissForPlane(client);

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
        // v49: los ataques de la NAVE ya no aturden a nadie: el club del
        // engine (mordiscos de la lengua) se convierte en bala y el tropiezo
        // de las EXPLOSIONES (misiles/granadas/minas) se cancela al instante
        if (dmgtype & DMG_CLUB) dmgtype = (dmgtype & ~DMG_CLUB) | DMG_BULLET;

        // atribucion de bajas: el XP de la nave sabe quien lastimo a quien
        g_PetHitOwner[victim] = attacker;
        g_PetHitTime[victim] = GetGameTime();
        SDKHooks_TakeDamage(victim, attacker, attacker, damage, dmgtype);

        if ((dmgtype & DMG_BLAST) && victim <= MaxClients
            && IsClientInGame(victim) && GetClientTeam(victim) == 3 && IsPlayerAlive(victim))
            L4D_CancelStagger(victim);   // v49: sin tropiezo de explosion
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

// v48: soporte de lengua para CAMPEONES (Thresh) — la misma maquinaria de
// la nave pero apuntando al cuerpo del campeon activo en vez del F18
int Champ_TongueBody(int client)
{
    if (client >= 1 && client <= MaxClients && g_iChampSel[client] >= 0)
    {
        int pet = EntRefToEntIndex(g_iPet_Entity[client]);
        if (pet != -1 && pet > 0 && IsValidEntity(pet)) return pet;
    }
    return EntRefToEntIndex(g_PetBody[client]);
}

// v48: boca de la lengua: el campeon dispara desde el pecho de su modelo;
// la nave conserva su morro original (patron GetPetMuzzle)
void TongueMuzzle(int client, int body, float out[3])
{
    if (client >= 1 && client <= MaxClients && g_iChampSel[client] >= 0)
    {
        GetEntPropVector(body, Prop_Data, "m_vecOrigin", out);
        out[2] += 45.0;
    }
    else GetPetMuzzle(body, out);
}

// v48: LOS de la lengua: el campeon traza desde su pecho (la nave, desde
// su morro a -3000): mismo filtro de trazas del resto del plugin
bool TongueLOS(int client, int body, int target, int &blocker)
{
    if (client < 1 || client > MaxClients || g_iChampSel[client] < 0)
        return PetLOS(client, body, target, blocker);

    float start[3], end[3];
    GetEntPropVector(body, Prop_Data, "m_vecOrigin", start);
    start[2] += 45.0;
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", end);
    end[2] += (target <= MaxClients) ? 40.0 : 30.0;

    float dir[3], ang[3];
    MakeVectorFromPoints(start, end, dir);
    GetVectorAngles(dir, ang);

    g_iTracePetBody = body;
    g_iTracePetModel = -1;
    g_iTracePetExhaust = -1;

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

// v48: dano de la lengua con atribucion correcta: la nave suma XP de la
// nave, Thresh suma XP de campeon
void TongueDamage(int victim, int owner, float dmg)
{
    if (owner >= 1 && owner <= MaxClients && g_iChampSel[owner] >= 0)
        ChampDamage(victim, owner, dmg, DMG_CLUB);
    else
        PetDamage(victim, owner, dmg, DMG_CLUB);
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
    if (!IsValidClient(client) || !IsPlayerAlive(client) || !(PetIsActive(client) || ChampIsActive(client)) || g_TongueRef[client] == -1)
    {
        CleanupTongue(client);
        return Plugin_Stop;
    }

    int body = Champ_TongueBody(client);
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
    TongueMuzzle(client, body, muzzle);
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
        if (!TongueLOS(client, body, target, blocker) && blocker != target)
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
    if (!TongueLOS(client, body, target, blocker2) && blocker2 != target)
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
        float tickDmg = 8.0 * PetTongueMult(client);   // v3.0: +0.30/nivel (v48: campeon +0.10/nv)
        TongueDamage(target, client, tickDmg);
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
    if (target == -1 || !IsValidEntity(target) || !IsEnemyAlive(target) || !(PetIsActive(client) || ChampIsActive(client))) return;

    float tPos[3];
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", tPos);
    tPos[2] += 40.0;
    PetBloodAt(tPos);

    int body = Champ_TongueBody(client);
    if (body != -1 && IsValidEntity(body))
    {
        float muzzle[3];
        TongueMuzzle(client, body, muzzle);
        int tongue[4] = {70, 140, 60, 255};
        PetBeam(muzzle, tPos, tongue, 3.0, 0.25);      // chasquido del latigazo
    }

    float dmg = 30.0 * PetTongueMult(client);   // v3.0: +0.30/nivel (v48: campeon +0.10/nv)
    TongueDamage(target, client, dmg);
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

    // la lengua nace en la boca del F18 (nave) o del PECHO del campeon
    // y sigue a su cuerpo mientras vuela. v53 FIX: antes se usaba
    // SIEMPRE el morro de la nave (origen - 3000): con Thresh la lengua
    // nacia 3000 u BAJO el suelo y nunca llegaba a la presa dentro de su
    // techo de vuelo de 1.2 s (se retraia siempre: la "cosa rara").
    float muzzle[3], bodyPos[3], rel[3];
    TongueMuzzle(client, body, muzzle);   // v53: nave = morro, campeon = pecho
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
    // v35 (v72): si descargan/recargan el plugin con senuos activos, TODOS
    // los bots prestados vuelven a su identidad original (nunca dejar un
    // bot de los 4 congelado, invisible y renombrado "Poppy")
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iDecoyBot[i] > 0 && g_iDecoyBot[i] <= MaxClients && IsClientInGame(g_iDecoyBot[i]))
            DecoyRestoreBot(i, g_iDecoyBot[i]);
        DecoyResetOwner(i);
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

/* ============================================================================== *
 *  v45 FUSION — MODULO COMPANION v1.3 (AlasfourOM + 12 fixes de la Task v43)     *
 *  Base visual/movil de los campeones: seguimiento por pasos (ring buffer 512),  *
 *  skins/auras/tamanos, bailes, 5 poderes de apoyo con AUTO, revive con barra.    *
 *  El COMBATE v45 (IA de prioridades, kits Q/W/E/R/P fieles, FX, stagger real)   *
 *  vive en el MODULO DE CAMPÉONES al final del archivo.                          *
 * ============================================================================== */

public void ConVarChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}


void GetCvars()
{
	
	// v44 FUSION: cvars de campeones
	g_bChampEnable = g_Cvar_ChampEnable.BoolValue;
	g_fChampRange = g_Cvar_ChampRange.FloatValue;
	g_iChampDmgBase = g_Cvar_ChampDmg.IntValue;
	g_iChampDmgPerLevel = g_Cvar_ChampDmgLvl.IntValue;
	g_fChampInterval = g_Cvar_ChampInterval.FloatValue;
	g_fChampAbCD = g_Cvar_ChampCDMult.FloatValue;
	g_iChampXPCommon = g_Cvar_ChampXPCommon.IntValue;
	g_iChampXPSpecial = g_Cvar_ChampXPSpecial.IntValue;
	g_iChampXPTank = g_Cvar_ChampXPTank.IntValue;
	g_iChampXPWitch = g_Cvar_ChampXPWitch.IntValue;
	g_iChampMaxLevel = g_Cvar_ChampMaxLevel.IntValue;
	g_bPoppyStats = g_Cvar_PoppyStats.BoolValue;
	g_bPoppyDecoy = g_Cvar_PoppyDecoy.BoolValue;
	g_fPoppyDecoyCD = g_Cvar_PoppyDecoyCD.FloatValue;
	g_fPoppyDecoyMult = g_Cvar_PoppyDecoyMult.FloatValue;
	g_fPoppyTankMult = g_Cvar_PoppyTankMult.FloatValue;
	g_fPoppyVision = g_Cvar_PoppyVision.FloatValue;
	g_fPoppyLeash = g_Cvar_PoppyLeash.FloatValue;
	g_fPoppyAspd = g_Cvar_PoppyAspd.FloatValue;
	g_fPoppyRegen = g_Cvar_PoppyRegen.FloatValue;
	g_fPoppyADMult = g_Cvar_PoppyADMult.FloatValue;
	g_iPoppyHUDMode = g_Cvar_PoppyHUD.IntValue;
	// v45: velocidad de ataque, IA, efectos y stagger
	g_fChampAspdPct = g_Cvar_ChampAspdLvl.FloatValue / 100.0;
	g_fChampAspdCap = g_Cvar_ChampAspdCap.FloatValue;
	g_bChampAI = g_Cvar_ChampAI.BoolValue;
	g_bChampFX = g_Cvar_ChampFX.BoolValue;
	g_fChampStaggerMult = g_Cvar_ChampStagger.FloatValue;
	g_bPluginEnable = g_Cvar_Pet_Plugin_Enable.BoolValue;
	g_iPet_HealCooldown = g_Cvar_PetHealCooldown.IntValue;
	g_iPet_HealAmount = g_Cvar_PetHealAmount.IntValue;
	g_iPet_AntiPukeCooldown = g_Cvar_PetAntipukeCooldown.IntValue;
	g_iPet_ReviveCooldown = g_Cvar_PetReviveCooldown.IntValue;
	g_iPet_AmmoRefillCooldown = g_Cvar_PetAmmoRefillCooldown.IntValue;
	g_iPet_AdrenBoostCooldown = g_Cvar_PetAdrenBoostCooldown.IntValue;
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *														Cookies													   *
 *================================================================================================================ */

void LoadPetCookies(int client)
{
	if (!AreClientCookiesCached(client)) return;

	char sSettings[128];
	GetClientCookie(client, g_hPetSettings, sSettings, sizeof(sSettings));
	
	if (sSettings[0] == '\0') 
	{
		strcopy(g_sPet_Name[client], sizeof(g_sPet_Name[]), "Luna");
		strcopy(g_sPet_Skin[client], sizeof(g_sPet_Skin[]), "Type I");
		strcopy(g_sPet_Aura[client], sizeof(g_sPet_Aura[]), "White");
		strcopy(g_sPet_Size[client], sizeof(g_sPet_Size[]), "0.3");
		g_bChampWanted[client] = false;   // v49
	}
	else 
	{
		char sExploded[5][16];
		ExplodeString(sSettings, "|", sExploded, 5, 16);
		
		strcopy(g_sPet_Name[client], sizeof(g_sPet_Name[]), sExploded[0]);
		strcopy(g_sPet_Skin[client], sizeof(g_sPet_Skin[]), sExploded[1]);
		strcopy(g_sPet_Aura[client], sizeof(g_sPet_Aura[]), sExploded[2]);
		strcopy(g_sPet_Size[client], sizeof(g_sPet_Size[]), sExploded[3]);
		// v49: campo 5 — el campeon convocado vuelve solo tras mapa/ronda
		g_bChampWanted[client] = (sExploded[4][0] == '1');
	}
	
	char sAbilities[32];
	GetClientCookie(client, g_hPetAutoAbilities, sAbilities, sizeof(sAbilities));
	
	if (sAbilities[0] == '\0')
	{
		g_bAutoHeal[client] = false;
		g_bAutoAntiPuke[client] = false;
		g_bAutoRevive[client] = false;
		g_bAutoAmmo[client] = false;
		g_bAutoAdren[client] = false;
	}
	else
	{
		char sExploded[5][4];
		ExplodeString(sAbilities, " ", sExploded, 5, 4);
		
		g_bAutoHeal[client]     = view_as<bool>(StringToInt(sExploded[0]));
		g_bAutoAntiPuke[client] = view_as<bool>(StringToInt(sExploded[1]));
		g_bAutoRevive[client]   = view_as<bool>(StringToInt(sExploded[2]));
		g_bAutoAmmo[client]     = view_as<bool>(StringToInt(sExploded[3]));
		g_bAutoAdren[client]    = view_as<bool>(StringToInt(sExploded[4]));
	}
}

void SavePetCookies_Settings(int client)
{
	if(!AreClientCookiesCached(client)) return;
	
	char sSettings[128];
	// v49: campo 5 = campeon convocado (vuelve solo tras mapa/ronda)
	FormatEx(sSettings, sizeof(sSettings), "%s|%s|%s|%s|%i", g_sPet_Name[client], g_sPet_Skin[client], g_sPet_Aura[client], g_sPet_Size[client], g_bChampWanted[client] ? 1 : 0);
	SetClientCookie(client, g_hPetSettings, sSettings);
}

void SavePetCookies_Abilities(int client)
{
	if(!AreClientCookiesCached(client)) return;
	
	char sAbilities[32];
	FormatEx(sAbilities, sizeof(sAbilities), "%i %i %i %i %i", g_bAutoHeal[client] ? 1 : 0, g_bAutoAntiPuke[client] ? 1 : 0, g_bAutoRevive[client] ? 1 : 0, g_bAutoAmmo[client] ? 1 : 0, g_bAutoAdren[client] ? 1 : 0);
	SetClientCookie(client, g_hPetAutoAbilities, sAbilities);
}


/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *													ALL Events													   *
 *================================================================================================================ */

void Event_StatusChanged(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || !IsClientInGame(client) || !g_bPluginEnable) return;
	
	RemovePet(client);
	g_iPlayerOnVomit[client] = 0;

	// v49: la pasiva activa desde el arranque — si el campeon estaba
	// convocado (persistido en la cookie), vuelve SOLO al reaparecer
	// (mapa nuevo / ronda nueva / respawn)
	if (StrEqual(name, "player_spawn") && GetClientTeam(client) == 2
			&& IsPlayerAlive(client) && g_bChampWanted[client] && !IsPetValid(client)
			&& !PetIsActive(client))
		CreateTimer(1.5, Timer_ChampReturn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

// v49: reinvocacion diferida del campeon (1.5 s tras el spawn)
public Action Timer_ChampReturn(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
	if (GetClientTeam(client) != 2 || !g_bChampWanted[client]) return Plugin_Stop;
	if (IsPetValid(client) || PetIsActive(client)) return Plugin_Stop;

	g_iChampSel[client] = ChampIdOf(g_sPet_Name[client]);   // re-sync defensivo
	char model[PLATFORM_MAX_PATH];
	ChampModelFor(client, model, sizeof(model));
	SpawnPet(client, model);

	int sel = g_iChampSel[client];
	CPrintToChat(client, "{green}[%s]{default} regresa al combate — {olive}Nv %d{default}.",
		g_sChampNames[sel], g_iChampLevel[client][sel]);
	return Plugin_Stop;
}

void Event_ReviveBegin(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bPluginEnable) return;
	
	int subject = GetClientOfUserId(event.GetInt("subject")); // the survivor being revived
	if (!subject || !IsClientInGame(subject)) return;
	
	// mark that a teammate is reviving this subject
	g_bTeammate_Reviving[subject] = true;
	
	// if our Companion was reviving this subject, cancel our own progress bar cleanly
	for (int owner = 1; owner <= MaxClients; owner++)
	{
		if (!IsClientInGame(owner)) continue;
		if (!g_bReviveInProgress[owner]) continue;
		
		int activeTarget = g_iFollowTarget[owner];
		if (activeTarget != owner && activeTarget == subject) KillProgressBar(owner, subject);
		else if (activeTarget == owner && subject == owner) KillProgressBar(owner, owner);
	}
}

void Event_ReviveEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bPluginEnable) return;
	
	int subject = GetClientOfUserId(event.GetInt("subject")); // the survivor who was being revived
	if (!subject || !IsClientInGame(subject)) return;
	
	g_bTeammate_Reviving[subject] = false;
	
	// if our Companion was reviving this subject, clear our own progress state
	for (int owner = 1; owner <= MaxClients; owner++)
	{
		if (!IsClientInGame(owner)) continue;
		if (!g_bReviveInProgress[owner]) continue;
		
		int activeTarget = g_iFollowTarget[owner];
		if ((activeTarget == subject) || (activeTarget == owner && subject == owner))
			KillProgressBar(owner, subject);
    }
}

void Event_OnVomit(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bPluginEnable) return;
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || !IsClientInGame(client)) return;
	g_iPlayerOnVomit[client] = 1;
}

void Event_OnUnVomit(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bPluginEnable) return;
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || !IsClientInGame(client)) return;
	
	g_iPlayerOnVomit[client] = 0;
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *											Command To Create Companion Menu									   *
 *================================================================================================================ */


void PetTalk(int client)
{
	char phrases[][] =
	{
		"Hey boss, what's the plan?",
		"I'm right behind you!",
		"Don't worry, I've got your back.",
		"Is it just me, or are there more zombies today?",
		"I'm feeling extra brave right now!",
		"Let's show them what we can do.",
		"Need a hand? Or a paw?",
		"I'm happy to be here with you!",
		"Keep moving, I'm watching the rear.",
		"That was a close one, wasn't it?",
		"I think I smell a Special Infected nearby...",
		"Lead the way, I'll follow.",
		"You're doing great, survivor!",
		"Hope you brought some treats for later!",
		"Stay alert, stay alive.",
		"I'm ready for some action!",
		"Nice shot! You're getting better.",
		"Do you hear that? Something is coming.",
		"Whatever happens, we face it together.",
		"I'm glad you picked me to be your companion!",
		"I've survived worse than this.",
		"Stick close. Things get ugly fast.",
		"If it moves funny, shoot it.",
		"Something’s watching us.",
		"You lead, I protect.",
		"I’ll scream if I see a Tank.",
		"We move fast, we survive.",
		"Stay focused. We’re almost through.",
		"Watch out! I've got a bad feeling about this corner.",
        "You keep shooting, I'll keep scouting!",
        "Don't let them surround us, boss!",
        "I'll bite their ankles if they get too close.",
        "That's one less zombie to worry about. Nice work!",
        "If you see any snacks... you know who to share with.",
        "I’m small, but I’m fierce! Let’s go!",
        "Is that a Tank? Or just a very loud neighbor?",
        "Don't worry, I'm faster than I look.",
        "I'll bark if I see anything ugly. Which is... everything here.",
        "Keep your chin up, we're making it out of here.",
        "I've seen worse. Actually, no I haven't. Let's run!",
        "You're the best teammate I've ever had!",
        "My senses are tingling... stay sharp.",
        "I wonder if there are any other pets left in this city?",
        "Zero regrets being your partner. Let's finish this!",
        "Keep your eyes on the road, I'm watching the shadows.",
        "Wait, did you hear that? Sounded like a Witch...",
        "I'm not scared if you aren't scared!",
        "Let's show these monsters who really owns the streets!"
	};
	
	int random = GetRandomInt(0, sizeof(phrases) - 1);
	CPrintToChat(client, "{green}[%s]{default} %s", g_sPet_Name[client], phrases[random]);
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *													Spawn The Pet												   *
 *================================================================================================================ */

void SpawnPet(int client, char[] model)
{
	if(g_hTimer_MoveOut[client] != null)
	{
		ShowChampMenu(client);
		return;
	}
	
	g_iFollowTarget[client] = client;
	g_iPet_Entity[client] = CreatePropDynamic(client, model);
	
	SetPetAnimation(client, "Spawn");
	SetEntProp(g_iPet_Entity[client], Prop_Send, "m_iGlowType", 3);
	PetAura_SetOrCycle(client, g_sPet_Aura[client]);
	AdjustPetSize(client, "DEFAULT");
	
	float fDelay;
	if(StrEqual(g_sPet_Name[client], "Luna")) fDelay = 4.0;
	else if(StrEqual(g_sPet_Name[client], "Raven")) fDelay = 1.3;
	else if(StrEqual(g_sPet_Name[client], "Snowy")) fDelay = 1.2;
	else if(StrEqual(g_sPet_Name[client], "Spyro")) fDelay = 3.5;
	else if(StrEqual(g_sPet_Name[client], "Ghosty")) fDelay = 4.5;
	else if(StrEqual(g_sPet_Name[client], "Storm")) fDelay = 1.0;
	else if(StrEqual(g_sPet_Name[client], "Ember")) fDelay = 1.0;
	else if(StrEqual(g_sPet_Name[client], "Warwick")) fDelay = 2.0;
	
	g_hTimer_MoveIn[client] = CreateTimer(fDelay, Timer_Spawn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	
	// v1.3 FIX: mata cualquier timer de auto-habilidades anterior antes de crear
	// uno nuevo (re-invocar rapido dejaba un duplicado huerfano corriendo).
	if (g_hTimer_CheckAutoAbilities[client] != null)
	{
		KillTimer(g_hTimer_CheckAutoAbilities[client]);
		g_hTimer_CheckAutoAbilities[client] = null;
	}
	g_hTimer_CheckAutoAbilities[client] = CreateTimer(3.0, Timer_ActivateAutoAbilities, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	g_iPet_Entity[client] = EntIndexToEntRef(g_iPet_Entity[client]);
	
	CPrintToChat(client, "{Green}[Companion] {default}Hey, {blue}%s {default}is at your service!", g_sPet_Name[client]);
	
	// Return other pets to their owner if present
	for(int i = 1; i <= MaxClients; i++)
	{
		if(i == client) continue;
		if(!IsClientInGame(i) || !IsPetValid(i)) continue;
		
		if(g_iFollowTarget[i] == client)
		{
			g_iFollowTarget[i] = i;
			TeleportPet(i);
		}
	}
}

Action Timer_Spawn(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) return Plugin_Handled;
	
	if (!IsPetValid(client))
	{
		g_hTimer_MoveIn[client] = null;
		return Plugin_Handled;
	}
	
	SetPetAnimation(client, "Idle");
	g_hTimer_MoveIn[client] = null;
	return Plugin_Handled;
}

void CycleModelSkin(int client)
{
	if(!IsPetValid(client)) { ShowChampMenu(client); return; }

	int ent = EntRefToEntIndex(g_iPet_Entity[client]);
	if(ent <= 0) { ShowChampMenu(client); return; }

	// Save pos/ang (so it looks like only skin changed)
	float pos[3], ang[3];
	GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", pos);
	GetEntPropVector(ent, Prop_Data, "m_angAbsRotation", ang);

	// Cycle: Type I -> Type II -> Type III -> Type I
	if(StrEqual(g_sPet_Skin[client], "Type I")) FormatEx(g_sPet_Skin[client], sizeof(g_sPet_Skin), "Type II");
	else if(StrEqual(g_sPet_Skin[client], "Type II")) FormatEx(g_sPet_Skin[client], sizeof(g_sPet_Skin), "Type III");
	else FormatEx(g_sPet_Skin[client], sizeof(g_sPet_Skin), "Type I");

	// Choose model by pet + skin
	char newModel[PLATFORM_MAX_PATH];

	// Luna
	if (StrEqual(g_sPet_Name[client], "Luna"))
	{
	    if (StrEqual(g_sPet_Skin[client], "Type I")) strcopy(newModel, sizeof(newModel), LUNA_DEFAULT_MODEL);
	    else if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(newModel, sizeof(newModel), LUNA_DAWN_MODEL);
	    else strcopy(newModel, sizeof(newModel), LUNA_SHADOW_MODEL);
	}
	
	// Raven
	else if (StrEqual(g_sPet_Name[client], "Raven"))
	{
	    if (StrEqual(g_sPet_Skin[client], "Type I")) strcopy(newModel, sizeof(newModel), RAVEN_DEFAULT_MODEL);
	    else if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(newModel, sizeof(newModel), RAVEN_NOXUS_MODEL);
	    else strcopy(newModel, sizeof(newModel), RAVEN_SNOWY_MODEL);
	}
	
	// Anivia
	else if (StrEqual(g_sPet_Name[client], "Snowy"))
	{
	    if (StrEqual(g_sPet_Skin[client], "Type I")) strcopy(newModel, sizeof(newModel), SNOWY_DEFAULT_MODEL);
	    else if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(newModel, sizeof(newModel), SNOWY_EAGLE_MODEL);
	    else strcopy(newModel, sizeof(newModel), SNOWY_HEXTECH_MODEL);
	}
	
	// Spyro
	else if (StrEqual(g_sPet_Name[client], "Spyro"))
	{
	    if (StrEqual(g_sPet_Skin[client], "Type I")) strcopy(newModel, sizeof(newModel), SPYRO_DEFAULT_MODEL);
	    else if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(newModel, sizeof(newModel), SPYRO_HEAVEN_MODEL);
	    else strcopy(newModel, sizeof(newModel), SPYRO_REINDEER_MODEL);
	}
	
	// Ghosty
	else if (StrEqual(g_sPet_Name[client], "Ghosty"))
	{
	    if (StrEqual(g_sPet_Skin[client], "Type I")) strcopy(newModel, sizeof(newModel), GHOSTY_DEFAULT_MODEL);
	    else if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(newModel, sizeof(newModel), GHOSTY_JANITOR_MODEL);
	    else strcopy(newModel, sizeof(newModel), GHOSTY_MOON_MODEL);
	}
	
	// Storm
	else if (StrEqual(g_sPet_Name[client], "Storm"))
	{
	    if (StrEqual(g_sPet_Skin[client], "Type I")) strcopy(newModel, sizeof(newModel), STORM_DEFAULT_MODEL);
	    else if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(newModel, sizeof(newModel), STORM_DEMON_MODEL);
	    else strcopy(newModel, sizeof(newModel), STORM_TIGER_MODEL);
	}
	
	// Ember
	else if (StrEqual(g_sPet_Name[client], "Ember"))
	{
	    if (StrEqual(g_sPet_Skin[client], "Type I")) strcopy(newModel, sizeof(newModel), EMBER_DEFAULT_MODEL);
	    else if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(newModel, sizeof(newModel), EMBER_CHOOCHOO_MODEL);
	    else strcopy(newModel, sizeof(newModel), EMBER_THUNDER_MODEL);
	}
	
	// Warwick
	else if (StrEqual(g_sPet_Name[client], "Warwick"))
	{
	    if (StrEqual(g_sPet_Skin[client], "Type I")) strcopy(newModel, sizeof(newModel), WARWICK_HUNTER_MODEL);
	    else if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(newModel, sizeof(newModel), WARWICK_FIREFANG_MODEL);
	    else strcopy(newModel, sizeof(newModel), WARWICK_BIGBAD_MODEL);
	}

	// Instant swap (no animation)
	SetEntityModel(ent, newModel);

	// Restore pos/ang (prevents snapping)
	TeleportEntity(ent, pos, ang, NULL_VECTOR);

	// Keep aura
	SetEntProp(ent, Prop_Send, "m_iGlowType", 3);
	PetAura_SetOrCycle(client, g_sPet_Aura[client]);
	SetPetAnimation(client, "Idle");

	// Keep size
	float scale = StringToFloat(g_sPet_Size[client]);
	if(scale > 0.0) SetEntPropFloat(ent, Prop_Send, "m_flModelScale", scale);

	ShowChampMenu(client);
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *													Menu Dance													   *
 *================================================================================================================ */

void OpenPetEmoteMenu(int client)
{
	Menu menu = new Menu(Handle_PetDanceMenu);
	
	if(StrEqual(g_sPet_Name[client], "Luna"))
	{
		menu.SetTitle("Select A Move:");
		menu.AddItem("MOVE1", "Shadow Groove");
		menu.AddItem("MOVE2", "Gloom Strut");
		menu.AddItem("MOVE3", "Fade Away");
		menu.AddItem("MOVE4", "Apathy State");
		menu.AddItem("MOVE5", "Dark Return");
		menu.AddItem("MOVE6", "Rise Again");
		menu.AddItem("MOVE7", "Final Silence");
	}
	
	else if(StrEqual(g_sPet_Name[client], "Raven"))
	{
		menu.SetTitle("Select A Move:");
		menu.AddItem("MOVE1", "Hammer Groove");
		menu.AddItem("MOVE2", "Battle Taunt");
		menu.AddItem("MOVE3", "Giggle Break");
		menu.AddItem("MOVE4", "Bouncy Shuffle");
		menu.AddItem("MOVE5", "Scout Stance!");
		menu.AddItem("MOVE6", "Hammer Windup");
		menu.AddItem("MOVE7", "Fallen Hero");
	}
	
	else if(StrEqual(g_sPet_Name[client], "Snowy"))
	{
		menu.SetTitle("Select A Move:");
		menu.AddItem("MOVE1", "Frost Waltz");
		menu.AddItem("MOVE2", "Icebound Taunt");
		menu.AddItem("MOVE3", "Glacial Chuckle");
		menu.AddItem("MOVE4", "Cold Strut");
		menu.AddItem("MOVE5", "Crystal Flip");
		menu.AddItem("MOVE6", "Wing Frost Slash");
		menu.AddItem("MOVE7", "Shatterfall");
	}
	
	else if(StrEqual(g_sPet_Name[client], "Spyro"))
	{
		menu.SetTitle("Select A Move:");
		menu.AddItem("MOVE1", "Flame Groove");
		menu.AddItem("MOVE2", "Dragon Prance");
		menu.AddItem("MOVE3", "Spark Giggle");
		menu.AddItem("MOVE4", "Playful Pounce");
		menu.AddItem("MOVE5", "Tumble Crash");
		menu.AddItem("MOVE6", "Wing Wiggle");
		menu.AddItem("MOVE7", "Dragon Down");
	}
	
	else if(StrEqual(g_sPet_Name[client], "Ghosty"))
	{
		menu.SetTitle("Select A Move:");
		menu.AddItem("MOVE1", "Soul Dance");
		menu.AddItem("MOVE2", "Chain Taunt");
		menu.AddItem("MOVE3", "Grim Laugh");
		menu.AddItem("MOVE4", "Rage Stir");
		menu.AddItem("MOVE5", "Chain Jab");
		menu.AddItem("MOVE6", "Soul Cleaver");
		menu.AddItem("MOVE7", "Soul Released");
	}
	
	else if(StrEqual(g_sPet_Name[client], "Storm"))
	{
		menu.SetTitle("Select A Move:");
		menu.AddItem("MOVE1", "Thunder Stomp");
		menu.AddItem("MOVE2", "Storm Roar");
		menu.AddItem("MOVE3", "War Taunt");
		menu.AddItem("MOVE4", "Bear Laugh");
		menu.AddItem("MOVE5", "Storm Recall");
		menu.AddItem("MOVE6", "Savage Maul");
		menu.AddItem("MOVE7", "Thunder Fall");
	}
	
	else if(StrEqual(g_sPet_Name[client], "Ember"))
	{
		menu.SetTitle("Select A Move:");
		menu.AddItem("MOVE1", "Forge Step");
		menu.AddItem("MOVE2", "Ember Taunt");
		menu.AddItem("MOVE3", "Ash Laugh");
		menu.AddItem("MOVE4", "Iron Mock");
		menu.AddItem("MOVE5", "Master Forge");
		menu.AddItem("MOVE6", "Hammer Strike");
		menu.AddItem("MOVE7", "Ashen Fall");
	}
	
	else if(StrEqual(g_sPet_Name[client], "Warwick"))
	{
		menu.SetTitle("Select A Move:");
		menu.AddItem("MOVE1", "Blood Rage");
		menu.AddItem("MOVE2", "Moon Howl");
		menu.AddItem("MOVE3", "Hunt Scent");
		menu.AddItem("MOVE4", "Curious Pup");
		menu.AddItem("MOVE5", "Maniac Chuckle");
		menu.AddItem("MOVE6", "Savage Strike");
		menu.AddItem("MOVE7", "Final Hunt");
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int Handle_PetDanceMenu(Menu menu, MenuAction action, int client, int select)
{
	if(action == MenuAction_Select)
	{
		char item[64];
		menu.GetItem(select, item, sizeof(item));
		
		if (!IsPetValid(client)) return 0;
		
		if (StrEqual(item, "MOVE1")) SetPetAnimation(client, "Move 1");
		else if (StrEqual(item, "MOVE2")) SetPetAnimation(client, "Move 2");
		else if (StrEqual(item, "MOVE3")) SetPetAnimation(client, "Move 3");
		else if (StrEqual(item, "MOVE4")) SetPetAnimation(client, "Move 4");
		else if (StrEqual(item, "MOVE5")) SetPetAnimation(client, "Move 5");
		else if (StrEqual(item, "MOVE6")) SetPetAnimation(client, "Move 6");
		else if (StrEqual(item, "MOVE7")) SetPetAnimation(client, "Move 7");
		OpenPetEmoteMenu(client);
	}
	else if(action == MenuAction_Cancel && select == MenuCancel_ExitBack) ShowChampMenu(client);
	else if(action == MenuAction_End) delete menu;
	return 0;
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *													Menu Aura													   *
 *================================================================================================================ */

void PetAura_SetOrCycle(int client, const char[] color = "")
{
	if (!IsPetValid(client)) return;
	
	// Both arrays MUST be the same size (22 entries)
	static const char names[22][16] =
	{
		"Disable", "White", "Gray", "Red", "Crimson", 
		"Coral", "Peach", "Orange", "Gold", "Yellow", 
		"Lime", "Green", "Mint", "Cyan", "Sky", 
		"Blue", "Navy", "Purple", "Violet", "Lavender", 
		"Pink", "Rose"
	};
	
	static const int rgb[22] = 
	{
		-1,                                 // 0 - Disable
		255 | (255<<8) | (255<<16),         // 1 - White
		80  | (80<<8)  | (80<<16),          // 2 - Gray
		255 | (0<<8)   | (0<<16),           // 3 - Red
		139 | (0<<8)   | (0<<16),           // 4 - Crimson
		255 | (60<<8)  | (20<<16),          // 5 - Coral (Red-Orange)
		255 | (180<<8) | (140<<16),         // 6 - Peach (Skin tone)
		255 | (120<<8) | (0<<16),           // 7 - Orange (Pure)
		218 | (165<<8) | (32<<16),          // 8 - Gold (Darker/Amber)
		255 | (255<<8) | (0<<16),           // 9 - Yellow (Neon)
		120 | (255<<8) | (0<<16),           // 10 - Lime (Yellow-Green)
		0   | (128<<8) | (0<<16),           // 11 - Green (Forest)
		0   | (255<<8) | (150<<16),         // 12 - Mint (Blue-Green)
		0   | (255<<8) | (255<<16),         // 13 - Cyan
		135 | (206<<8) | (250<<16),         // 14 - Sky
		0   | (0<<8)   | (255<<16),         // 15 - Blue
		0   | (0<<8)   | (100<<16),         // 16 - Navy
		128 | (0<<8)   | (128<<16),         // 17 - Purple
		238 | (130<<8) | (238<<16),         // 18 - Violet (Bright)
		180 | (150<<8) | (255<<16),         // 19 - Lavender (Soft)
		255 | (50<<8)  | (150<<16),         // 20 - Pink (Hot Pink)
		255 | (0<<8)   | (100<<16)          // 21 - Rose (Deep Pinkish-Red)
	};
	
	if (g_sPet_Aura[client][0] == '\0')
		strcopy(g_sPet_Aura[client], sizeof(g_sPet_Aura[]), "Disable");
	
	int idx = 0;
	
	if (color[0] == '\0')
	{
		for (int i = 0; i < 22; i++)
		{
			if (StrEqual(g_sPet_Aura[client], names[i], false))
			{
				idx = i;
				break;
			}
		}
		
		idx++;
		if (idx >= 22) idx = 0;
	}
	else
	{
		for (int i = 0; i < 22; i++)
		{
			if (StrEqual(color, names[i], false))
			{
				idx = i;
				break;
			}
		}
	}
	
	// Save name
	strcopy(g_sPet_Aura[client], sizeof(g_sPet_Aura[]), names[idx]);
	
	// Apply
	if (idx == 0 || rgb[idx] == -1) SetEntProp(g_iPet_Entity[client], Prop_Send, "m_iGlowType", 0);
	else
	{
		SetEntProp(g_iPet_Entity[client], Prop_Send, "m_iGlowType", 3);
		SetEntProp(g_iPet_Entity[client], Prop_Send, "m_glowColorOverride", rgb[idx]);
	}
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *													Menu Resize Pets											   *
 *================================================================================================================ */

void OpenResizePetMenu(int client)
{
	Menu menu = new Menu(Handle_ResizePetMenu);
	menu.SetTitle("Scale Your Companion:");
	menu.AddItem("DEFAULT", "Default");
	menu.AddItem("INCREASE", "Increase");
	menu.AddItem("DECREASE", "Decrease");
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int Handle_ResizePetMenu(Menu menu, MenuAction action, int client, int select)
{
	if(action == MenuAction_Select)
	{
		char item[64];
		menu.GetItem(select, item, sizeof(item));
		
		if (!IsPetValid(client)) return 0;
		else if(StrEqual(item, "DEFAULT") || StrEqual(item, "INCREASE") || StrEqual(item, "DECREASE"))
		{
			AdjustPetSize(client, item);
			OpenResizePetMenu(client);
		}
		
	}
	else if(action == MenuAction_Cancel && select == MenuCancel_ExitBack) ShowChampMenu(client);
	else if(action == MenuAction_End) delete menu;
	return 0;
}

void AdjustPetSize(int client, const char[] action)
{
	if(!IsPetValid(client)) return;

	float size = StringToFloat(g_sPet_Size[client]);
	float base = 1.00, step = 0.10;

	if(StrEqual(g_sPet_Name[client], "Luna")) { base = 0.30; step = 0.030; }
	else if(StrEqual(g_sPet_Name[client], "Raven")) { base = 0.20; step = 0.020; }
	else if(StrEqual(g_sPet_Name[client], "Snowy")) { base = 0.40; step = 0.035; }
	else if(StrEqual(g_sPet_Name[client], "Spyro")) { base = 0.20; step = 0.025; }
	else if(StrEqual(g_sPet_Name[client], "Ghosty")) { base = 0.30; step = 0.120; }
	else if(StrEqual(g_sPet_Name[client], "Storm")) { base = 0.20; step = 0.020; }
	else if(StrEqual(g_sPet_Name[client], "Ember")) { base = 0.20; step = 0.020; }
	else if(StrEqual(g_sPet_Name[client], "Warwick")) { base = 0.20; step = 0.020; }

	if(size <= 0.0) size = base;

	if(StrEqual(action, "DEFAULT")) size = base;
	else if(StrEqual(action, "INCREASE")) size += step;
	else if(StrEqual(action, "DECREASE")) size -= step;

	float min = base - (step * 4.0);
	float max = base + (step * 4.0);

	if(size < min) size = min;
	if(size > max) size = max;

	FormatEx(g_sPet_Size[client], sizeof(g_sPet_Size[]), "%.3f", size);

	int ent = EntRefToEntIndex(g_iPet_Entity[client]);
	if(ent > 0) SetEntPropFloat(ent, Prop_Send, "m_flModelScale", size);
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *													Menu Ability Pets											   *
 *================================================================================================================ */

// ----------------------------------------------------------------------------
// v56: MENUS CON NUMEROS EN VIVO — el timer repinta el menu abierto cada
// segundo (cooldowns contando hacia abajo, XP/bajas al dia). Cualquier
// salida real del menu (ESC, atras, submenu, menu externo) lo apaga. El
// repintado propio llega como MenuCancel_Interrupted con el flag puesto.
// ----------------------------------------------------------------------------
void StartLiveMenu(int client, int which)
{
	g_iLiveMenu[client] = which;
	if (g_hLiveMenuTimer[client] == null)
		g_hLiveMenuTimer[client] = CreateTimer(1.0, Timer_LiveMenu, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

void StopLiveMenu(int client)
{
	g_iLiveMenu[client] = 0;
	g_bMenuSelfRefresh[client] = false;
}

Action Timer_LiveMenu(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client))
	{
		if (client > 0 && client <= MaxClients) g_hLiveMenuTimer[client] = null;
		return Plugin_Stop;
	}
	if (g_iLiveMenu[client] == 0 || GetClientMenu(client) == MenuSource_None)
	{
		g_hLiveMenuTimer[client] = null;
		g_iLiveMenu[client] = 0;
		return Plugin_Stop;
	}
	g_bMenuSelfRefresh[client] = true;   // la proxima Cancel(Interrupted) es NUESTRO repintado
	if (g_iLiveMenu[client] == 1) OpenAbilitiesPetMenu(client);
	else ShowChampMenu(client);
	return Plugin_Continue;
}

void OpenAbilitiesPetMenu(int client)
{
	StartLiveMenu(client, 1);   // v56: cooldowns repintados en vivo cada segundo
		Menu menu = new Menu(Handle_AbilitiesPetMenu);
	
	menu.SetTitle("Companion Abilities:");
	if (g_iHealing_Cooldown[client] != 0 && (g_iHealing_Cooldown[client] + g_iPet_HealCooldown > GetTime()))
	{
		int timeleft = g_iHealing_Cooldown[client] - GetTime() + g_iPet_HealCooldown;
		char sBuffer[64];
		FormatEx(sBuffer, sizeof(sBuffer), "Healing Spell: %is", timeleft);
		menu.AddItem("HEAL", sBuffer, IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	else menu.AddItem("HEAL", "Healing Spell", IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	if (g_iAntiPuke_Cooldown[client] != 0 && (g_iAntiPuke_Cooldown[client] + g_iPet_AntiPukeCooldown > GetTime()))
	{
		int timeleft = g_iAntiPuke_Cooldown[client] - GetTime() + g_iPet_AntiPukeCooldown;
		char sBuffer[64];
		FormatEx(sBuffer, sizeof(sBuffer), "Anti-Puke Spell: %is", timeleft);
		menu.AddItem("ANTIPUKE", sBuffer, IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	else menu.AddItem("ANTIPUKE", "Anti-Puke Spell", IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	if (g_iRevive_Cooldown[client] != 0 && (g_iRevive_Cooldown[client] + g_iPet_ReviveCooldown > GetTime()))
	{
		int timeleft = g_iRevive_Cooldown[client] - GetTime() + g_iPet_ReviveCooldown - g_iReviveSaved[client];   // v56: en vivo
		char sBuffer[64];
		FormatEx(sBuffer, sizeof(sBuffer), "Reviving Spell: %is", timeleft);
		menu.AddItem("REVIVE", sBuffer, IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	else menu.AddItem("REVIVE", "Reviving Spell", IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	if (g_iAmmoRefill_Cooldown[client] != 0 && (g_iAmmoRefill_Cooldown[client] + g_iPet_AmmoRefillCooldown > GetTime()))
	{
		int timeleft = g_iAmmoRefill_Cooldown[client] - GetTime() + g_iPet_AmmoRefillCooldown;
		char sBuffer[64];
		FormatEx(sBuffer, sizeof(sBuffer), "Max Ammo: %is", timeleft);
		menu.AddItem("AMMO", sBuffer, IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	else menu.AddItem("AMMO", "Max Ammo", IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	if (g_iAdrenBoost_Cooldown[client] != 0 && (g_iAdrenBoost_Cooldown[client] + g_iPet_AdrenBoostCooldown > GetTime()))
	{
		int timeleft = g_iAdrenBoost_Cooldown[client] - GetTime() + g_iPet_AdrenBoostCooldown;
		char sBuffer[64];
		FormatEx(sBuffer, sizeof(sBuffer), "Adrenaline Boost: %is", timeleft);
		menu.AddItem("ADREN", sBuffer, IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}
	else menu.AddItem("ADREN", "Adrenaline Boost", IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	menu.AddItem("AUTO", "Auto Abilities Setting", IsPetValid(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int Handle_AbilitiesPetMenu(Menu menu, MenuAction action, int client, int select)
{
	if(action == MenuAction_Select)
	{
		char item[64];
		menu.GetItem(select, item, sizeof(item));

		StopLiveMenu(client);   // v56: al tocar una opcion, el repintado vivo se apaga

		if (!IsPetValid(client)) return 0;
		
		if (StrEqual(item, "HEAL") && !IsAbilityOnCooldown(client, "Health")) ActivateEnergyAbilities(client, "Health", true);
		if (StrEqual(item, "ANTIPUKE") && !IsAbilityOnCooldown(client, "Anti-Puke")) ActivateEnergyAbilities(client, "Anti-Puke", true);
		if (StrEqual(item, "REVIVE") && !IsAbilityOnCooldown(client, "Revive")) RevivePlayer(client, true);
		if (StrEqual(item, "AMMO") && !IsAbilityOnCooldown(client, "Ammo")) TransferAmmoToPlayer(client, true);
		if (StrEqual(item, "ADREN") && !IsAbilityOnCooldown(client, "Adrenaline")) GiveAdrenalineboost(client, true);
		if (StrEqual(item, "AUTO"))
		{
			OpenAutoAbilitiesMenu(client);
			return 0;
		}

		OpenAbilitiesPetMenu(client);
	}
	else if(action == MenuAction_Cancel)
	{
		// v56: numeros vivos — el repintado de 1 s REEMPLAZA el menu (esa
		// cancelacion con MenuCancel_Interrupted es nuestra); el resto de
		// salidas (ESC, atras, desconexion) apagan los numeros vivos
		if (select == MenuCancel_Interrupted && g_bMenuSelfRefresh[client])
			g_bMenuSelfRefresh[client] = false;
		else StopLiveMenu(client);
	
		if (select == MenuCancel_ExitBack) ShowChampMenu(client);
	}
	else if(action == MenuAction_End) delete menu;
	return 0;
	}

void OpenAutoAbilitiesMenu(int client)
{
	Menu menu = new Menu(Handle_AutoAbilitiesMenu);
	menu.SetTitle("Auto Abilities:");
	
	char sBuffer[64];
	FormatEx(sBuffer, sizeof(sBuffer), "Healing Spell: %s", g_bAutoHeal[client] ? "Auto" : "None");
	menu.AddItem("AUTO_HEAL", sBuffer);
	
	FormatEx(sBuffer, sizeof(sBuffer), "Anti-Puke: %s", g_bAutoAntiPuke[client] ? "Auto" : "None");
	menu.AddItem("AUTO_ANTIPUKE", sBuffer);
	
	FormatEx(sBuffer, sizeof(sBuffer), "Revive: %s", g_bAutoRevive[client] ? "Auto" : "None");
	menu.AddItem("AUTO_REVIVE", sBuffer);
	
	FormatEx(sBuffer, sizeof(sBuffer), "Max Ammo: %s", g_bAutoAmmo[client] ? "Auto" : "None");
	menu.AddItem("AUTO_AMMO", sBuffer);
	
	FormatEx(sBuffer, sizeof(sBuffer), "Adrenaline Boost: %s", g_bAutoAdren[client] ? "Auto" : "None");
	menu.AddItem("AUTO_ADREN", sBuffer);
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int Handle_AutoAbilitiesMenu(Menu menu, MenuAction action, int client, int iItem)
{
	if (action == MenuAction_Select)
	{
		char sId[32];
		menu.GetItem(iItem, sId, sizeof(sId));
		
		if (StrEqual(sId, "AUTO_HEAL"))
		{
			g_bAutoHeal[client] = !g_bAutoHeal[client];
			if(GetClientHealth(client) + L4D_GetTempHealth(client) <= GetEntProp(client, Prop_Send, "m_iMaxHealth") - g_iPet_HealAmount)
				if(!IsAbilityOnCooldown(client, "Health")) ActivateEnergyAbilities(client, "Health", false);
		}
		else if (StrEqual(sId, "AUTO_ANTIPUKE"))
		{
			g_bAutoAntiPuke[client] = !g_bAutoAntiPuke[client];
			if(g_iPlayerOnVomit[client] == 1 && !IsAbilityOnCooldown(client, "Anti-Puke"))
				ActivateEnergyAbilities(client, "Anti-Puke", false);
		}
		else if (StrEqual(sId, "AUTO_REVIVE")) g_bAutoRevive[client] = !g_bAutoRevive[client];
		else if (StrEqual(sId, "AUTO_AMMO"))
		{
			g_bAutoAmmo[client] = !g_bAutoAmmo[client];
			// v1.3 FIX: ejecutaba GiveAdrenalineboost y comprobaba el cooldown
			// de "Adrenaline" (copy/paste) -> daba adrenalina en vez de municion.
			if (!IsAbilityOnCooldown(client, "Ammo"))
				TransferAmmoToPlayer(client, false);
		}
		else if (StrEqual(sId, "AUTO_ADREN")) g_bAutoAdren[client] = !g_bAutoAdren[client];
		
		OpenAutoAbilitiesMenu(client);
	}
	else if (action == MenuAction_Cancel && iItem == MenuCancel_ExitBack) OpenAbilitiesPetMenu(client);
	else if (action == MenuAction_End) delete menu;
	return 0;
}

void ActivateEnergyAbilities(int client, const char[] sAbility, bool bShowText)
{
	if (!IsPetValid(client)) return;
	
	if (!IsFollowTargetNear(client))
	{
		if (bShowText) CPrintToChat(client, "{green}[Companion]{default} Get closer to your ally before using this ability.");
		return;
	}
	
	float vPetOrigin[3];
	GetEntPropVector(g_iPet_Entity[client], Prop_Data, "m_vecOrigin", vPetOrigin);
	
	int iAbilityHitType = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || IsPlayerIncapacitated(i) || GetClientTeam(i) != L4D2Team_Survivor) continue;
		
		float vTargetPos[3];
		GetClientAbsOrigin(i, vTargetPos);
		if (GetVectorDistance(vTargetPos, vPetOrigin) > 250.0) continue;
		
		if (StrEqual(sAbility, "Health"))
		{
			HealClient(i);
			ScreenFade(i, 192, 238, 39, 140, 600, 1);
			iAbilityHitType = 1;
		}
		else if (StrEqual(sAbility, "Anti-Puke"))
		{
			L4D_OnITExpired(i);
			ScreenFade(i, 0, 0, 0, 100, 600, 1);
			iAbilityHitType = 2;
		}
	}
	
	if (!iAbilityHitType) return;
	
	float vRingPosition[3];
	vRingPosition[0] = vPetOrigin[0];
	vRingPosition[1] = vPetOrigin[1];
	vRingPosition[2] = vPetOrigin[2] + 20.0;
	
	if (iAbilityHitType == 1) TE_SetupBeamRingPoint(vRingPosition, 10.0, 250.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.3, 10.0, 0.5, {192,238,39,230}, 400, 0);
	else TE_SetupBeamRingPoint(vRingPosition, 10.0, 250.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.3, 10.0, 0.5, {255,255,255,200}, 400, 0);
	
	TE_SendToAll();
	EmitAmbientSound(HEALTH_SOUND, vRingPosition, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
	
	if (iAbilityHitType == 1) g_iHealing_Cooldown[client] = GetTime();
	else g_iAntiPuke_Cooldown[client] = GetTime();
}

void HealClient(int client)
{
	if(!IsPlayerAlive(client) || GetClientTeam(client) != L4D2Team_Survivor || IsPlayerIncapacitated(client))
		return;
	
	int iHealth = GetClientHealth(client);
	int iMaxHealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
	float fHealth = L4D_GetTempHealth(client);
	
	iHealth += g_iPet_HealAmount;
	if(iHealth >= iMaxHealth)
	{
		iHealth = iMaxHealth;
		L4D_SetTempHealth(client, 0.0);
	}
	else if(iHealth + fHealth >= iMaxHealth) L4D_SetTempHealth(client, float(iMaxHealth - iHealth));
	if(iHealth <= iMaxHealth) SetEntityHealth(client, iHealth);
}

void RevivePlayer(int client, bool bShowText)
{
	int target = PetPickReviveTarget(client);   // v56: la duena caida o el companero caido mas cercano
	if (!CanAutoRevive(client, target, bShowText, false))
	{
		if (!g_bPetReviveActive[client])   // v56: no pisar un revive EN CURSO
		{
			g_bReviveInProgress[client] = false;
			PetReviveRestoreFollow(client);   // v56: aborto limpio (suelta presa y seguimiento)
		}
		return;
	}
	
	// v56: la presa manda — el companion redirige su marcha hacia el caido
	// (recuerda a quien seguia para restaurarlo al terminar)
	g_iPetRevivingTarget[client] = target;
	if (target != g_iFollowTarget[client])
	{
		if (g_iReviveFollowRestore[client] == 0) g_iReviveFollowRestore[client] = g_iFollowTarget[client];
		g_iFollowTarget[client] = target;
	}
	
	if(!IsFollowTargetNear(client))
	{
		if (bShowText)
		{
			if (target == client) CPrintToChat(client, "{green}[Companion]{default} Wait, I'm coming for you!");
			else CPrintToChat(client, "{green}[Companion]{default} I'm going to revive {blue}%N{default}.", target);
		}
		g_bReviveInProgress[client] = true;
		return;
	}
	
	g_bReviveInProgress[client] = true;
	BeginAutoRevive(client, target);
}

void BeginAutoRevive(int client, int target)
{
	if (g_bPetReviveActive[client]) return;
	
	g_bPetPaused[client]       = false;
	g_bPetReviveActive[client] = true;
	g_iPetRevivingTarget[client] = target;   // v56: presa reclamada (ninguna otra mascota la levanta)
	SetupProgressBar(client, target);
}

void SetupProgressBar(int client, int target)
{
	if (g_fSetupProgressTime[client] > 0.0) return;
	
	g_bReviveInProgress[client] = true;
	g_fSetupProgressTime[client] = 5.0;
	
	SetEntPropFloat(target, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
	SetEntPropFloat(target, Prop_Send, "m_flProgressBarDuration", g_fSetupProgressTime[client]);
	SetEntPropEnt(target, Prop_Send, "m_reviveOwner", client);
	
	SetPetAnimation(client, "Revive");
	
	// v1.3 FIX: solo se congela a objetivos NO colgados de cornisa (restaurar
	// MOVETYPE_WALK a un colgado lo haria caer y morir). Flag para restaurar solo
	// a quien congelamos de verdad.
	g_bPetFrozeTarget[client] = false;
	if (IsValidEntity(target) && IsClientInGame(target) && !IsHandingFromLedge(target))
	{
		SetEntityMoveType(target, MOVETYPE_NONE);
		g_bPetFrozeTarget[client] = true;
	}
	
	if (g_hTimer_ReviveCheck[client] != null)
	{
		KillTimer(g_hTimer_ReviveCheck[client]);
		g_hTimer_ReviveCheck[client] = null;
	}
	if (g_hRevivePack[client] != null)
	{
		delete g_hRevivePack[client];
		g_hRevivePack[client] = null;
	}
	
	DataPack dPack = new DataPack();
	dPack.WriteCell(GetClientUserId(client));
	dPack.WriteCell(GetClientUserId(target));
	g_hRevivePack[client] = dPack;
	g_hTimer_ReviveCheck[client] = CreateTimer(PET_MOVE_INTERVAL, Timer_ReviveCheck, dPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

Action Timer_ReviveCheck(Handle timer, DataPack dPack)
{
	dPack.Reset();
	int client_userid  = dPack.ReadCell();
	int target_userid = dPack.ReadCell();
	
	int client  = GetClientOfUserId(client_userid);
	int target = GetClientOfUserId(target_userid);
	
	if (!client || !IsClientInGame(client) || !IsPetValid(client))
	{
		// v1.3 FIX: esta rama solo es alcanzable si el duenyo ya se fue
		// (OnClientDisconnect -> RemovePet normalmente limpia todo antes).
		// Limpiamos los globales que apunten a este timer/pack y cerramos el pack.
		for (int i = 1; i <= MaxClients; i++)
		{
			if (g_hTimer_ReviveCheck[i] != null && g_hTimer_ReviveCheck[i] == timer)
				g_hTimer_ReviveCheck[i] = null;
			if (g_hRevivePack[i] == dPack)
				g_hRevivePack[i] = null;
		}
		delete dPack;
		return Plugin_Stop;
	}
	
	if (!target || !IsClientInGame(target) || GetClientTeam(target) != L4D2Team_Survivor)
	{
		KillProgressBar(client, target);
		return Plugin_Stop;
	}
	
	if (!g_bPetReviveActive[client] || !CanAutoRevive(client, target, false, true))
	{
		KillProgressBar(client, target);
		return Plugin_Stop;
	}
	
	if (g_fSetupProgressTime[client] > 0.4)
	{
		g_fSetupProgressTime[client] -= 0.1;
		return Plugin_Continue;
	}
	
	g_iRevive_Cooldown[client] = GetTime();
	g_iReviveSaved[client]    = 0;     // v56: nuevo ciclo de recarga
	g_bReviveWipeCut[client]  = false; // v56
	L4D_ReviveSurvivor(target);
	KillProgressBar(client, target);
	return Plugin_Stop;
}

void KillProgressBar(int client, int target)
{
	g_bReviveInProgress[client] = false;
	g_bPetReviveActive[client]  = false;
	g_fSetupProgressTime[client] = 0.0;
	PetReviveRestoreFollow(client);   // v56: suelta la presa y vuelve con los suyos
	
	if (IsClientInGame(target))
	{
		SetEntPropFloat(target, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		SetEntPropFloat(target, Prop_Send, "m_flProgressBarDuration", g_fSetupProgressTime[client]);
		SetEntPropEnt(target,  Prop_Send, "m_reviveOwner", -1);
		
		// v1.3 FIX: solo se restaura el movetype a objetivos que congelamos
		// nosotros mismos, vivos y NO colgados de cornisa (si no, caen).
		if (g_bPetFrozeTarget[client] && GetClientTeam(target) == L4D2Team_Survivor
			&& IsPlayerAlive(target) && !IsHandingFromLedge(target))
			SetEntityMoveType(target, MOVETYPE_WALK);
	}
	
	g_bPetFrozeTarget[client] = false;
	
	SetPetAnimation(client, "Idle");
	
	if (g_hTimer_ReviveCheck[client] != null)
	{
		KillTimer(g_hTimer_ReviveCheck[client]);
		g_hTimer_ReviveCheck[client] = null;
	}
	
	// v1.3 FIX: cierra el DataPack del revive (antes se filtraba en cada
	// cancelacion externa: revive_begin / revive_end / RemovePet).
	if (g_hRevivePack[client] != null)
	{
		delete g_hRevivePack[client];
		g_hRevivePack[client] = null;
	}
}

bool CanAutoRevive(int client, int target, bool bShowText, bool reviving)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client) || !IsPetValid(client) || GetClientTeam(client) != L4D2Team_Survivor) return false;
	if (!IsClientInGame(target) || !IsPlayerAlive(target) || GetClientTeam(target) != L4D2Team_Survivor) return false;
	
	if (!IsPlayerIncapacitated(target))
	{
		if (bShowText)
		{
			if (target == client) CPrintToChat(client, "{green}[Companion]{default} You are not incapacitated!");
			else CPrintToChat(client, "{green}[Companion]{default} {blue}%N{default} is not incapacitated!", target);
		}
		return false;
	}
	
	if (IsPlayerGrabbed(target))
	{
		if (bShowText)
		{
			if (target == client) CPrintToChat(client, "{green}[Companion]{default} I can't revive while you're being held!");
			else CPrintToChat(client, "{green}[Companion]{default} I can't revive {blue}%N{default} while they are being held!", target);
		}
		return false;
	}
	
	if (g_bTeammate_Reviving[target])
	{
		if (bShowText)
		{
			if (target == client) CPrintToChat(client, "{green}[Companion]{default} Your teammate is reviving you!");
			else CPrintToChat(client, "{green}[Companion]{default} A teammate is reviving {blue}%N{default}!", target);
		}
		return false;
	}
	
	if (!reviving && g_fSetupProgressTime[client] > 0.0) return false;
	return true;
}

// ----------------------------------------------------------------------------
// v56: REVIVIR INTELIGENTE — recarga que se gana luchando e IA que acude
// ----------------------------------------------------------------------------
// Segundos que le quedan al CD del Revivir (contando lo ahorrado por bajas
// de especiales y por el corte de emergencia del equipo).
int ReviveTimeLeft(int client)
{
	if (g_iRevive_Cooldown[client] == 0) return 0;
	int left = g_iRevive_Cooldown[client] + g_iPet_ReviveCooldown - g_iReviveSaved[client] - GetTime();
	return (left > 0) ? left : 0;
}

// Baja de especial/tank/witch: el Revivir recupera 8% + 0.5% por nivel del
// dueno de su CD TOTAL (tope 30% por baja). Solo mientras esta en recarga.
void PetReviveOnSpecialKill(int client, int level)
{
	if (!IsClientInGame(client) || IsFakeClient(client)) return;
	if (!IsAbilityOnCooldown(client, "Revive")) return;
	
	float pct = 0.08 + 0.005 * float(level);
	if (pct > 0.30) pct = 0.30;
	int saved = RoundToCeil(pct * float(g_iPet_ReviveCooldown));
	if (saved <= 0) return;
	
	g_iReviveSaved[client] += saved;
	int left = ReviveTimeLeft(client);
	if (left <= 0)
		CPrintToChat(client, "{green}[Companion]{default} {olive}Revivir{default}: bajas de especiales — {olive}¡listo para usar!{default}");
	else
		CPrintToChat(client, "{green}[Companion]{default} {olive}Revivir{default}: {olive}-%d s{default} por baja de especial (listo en {olive}%d s{default}).", saved, left);
}

// v56: ¿esta TODO el equipo caido? (nadie en pie)
bool PetTeamAllDown()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || GetClientTeam(i) != 2) continue;
		if (IsPlayerAlive(i) && !IsPlayerIncapacitated(i)) return false;
	}
	return true;
}

// v56: candidato valido para el Revivir (caido, no agarrado, sin compis
// encima y sin otra mascota levantandolo ya)
bool PetIsRevivable(int owner, int target)
{
	if (target <= 0 || target > MaxClients || !IsClientInGame(target)) return false;
	if (GetClientTeam(target) != 2 || !IsPlayerAlive(target)) return false;
	if (!IsPlayerIncapacitated(target)) return false;
	if (IsPlayerGrabbed(target)) return false;
	if (g_bTeammate_Reviving[target]) return false;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == owner || !g_iPetRevivingTarget[i]) continue;
		if (g_iPetRevivingTarget[i] == target) return false;
	}
	return true;
}

// v56: a quien hay que revivir — la presa en curso si sigue valida; si no,
// el objetivo seguido (la duena) caido; si no, el companero caido mas cercano
int PetPickReviveTarget(int client)
{
	int cur = g_iPetRevivingTarget[client];
	if (PetIsRevivable(client, cur)) return cur;
	
	int t = g_iFollowTarget[client];
	if (PetIsRevivable(client, t)) return t;
	
	float ownerPos[3];
	GetClientAbsOrigin(client, ownerPos);
	int best = 0;
	float bestDist = 99999.0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == client || !PetIsRevivable(client, i)) continue;
		float vPos[3];
		GetClientAbsOrigin(i, vPos);
		float d = GetVectorDistance(ownerPos, vPos);
		if (d < bestDist) { bestDist = d; best = i; }
	}
	if (best > 0) return best;
	return (t > 0) ? t : client;   // nadie caido: el flujo viejo pone el mensaje
}

// v56: fin del revive — suelta la presa y vuelve a seguir a quien seguia
void PetReviveRestoreFollow(int client)
{
	g_iPetRevivingTarget[client] = 0;
	if (g_iReviveFollowRestore[client] != 0)
	{
		g_iFollowTarget[client] = g_iReviveFollowRestore[client];
		g_iReviveFollowRestore[client] = 0;
	}
}

// v56: reaccion INMEDIATA de la IA — en cuanto cae alguien, los companions
// con auto-revive no esperan al chequeo de 3 s: salen hacia el al momento
public void Event_PlayerIncapacitated(Event event, const char[] name, bool dontBroadcast)
{
	if (g_enable == 0) return;
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (victim <= 0 || !IsClientInGame(victim) || GetClientTeam(victim) != 2) return;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || !IsPlayerAlive(i)) continue;
		if (GetClientTeam(i) != 2 || !IsPetValid(i)) continue;
		if (!g_bAutoRevive[i] || IsAbilityOnCooldown(i, "Revive")) continue;
		if (g_bReviveInProgress[i] || g_bPetReviveActive[i]) continue;
		CreateTimer(0.5, Timer_TryRushRevive, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
	}
}

Action Timer_TryRushRevive(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsPetValid(client)) return Plugin_Stop;
	if (!g_bAutoRevive[client] || IsAbilityOnCooldown(client, "Revive")) return Plugin_Stop;
	if (g_bReviveInProgress[client] || g_bPetReviveActive[client]) return Plugin_Stop;
	RevivePlayer(client, false);
	return Plugin_Stop;
}

void GiveAdrenalineboost(int client, bool bShowText)
{
	int target = g_iFollowTarget[client];
	if (!target) target = client; // v1.3 FIX: guard defensivo
	if (GetClientTeam(target) != L4D2Team_Survivor || !IsPlayerAlive(target) || IsPlayerIncapacitated(target) || IsPlayerGrabbed(target))
	{
		if(bShowText) CPrintToChat(client, "{green}[Companion]{default} Your companion can't use this ability at this moment!");
		return;
	}
	
	if(!IsFollowTargetNear(client))
	{
		if(bShowText) CPrintToChat(client, "{green}[Companion]{default} Your companion needs to be close!");
		return;
	}
	
	// v1.3 FIX: null-check con fallback de 15 s
	float fAdrenDuration = (g_Cvar_Server_Adren_Duration != null) ? g_Cvar_Server_Adren_Duration.FloatValue : 15.0;
	L4D2_UseAdrenaline(target, fAdrenDuration, true);
	ScreenFade(target, 255, 180, 50, 50, RoundToZero(0.6 * 1000.0), 1);
	g_iAdrenBoost_Cooldown[client] = GetTime();
}

void TransferAmmoToPlayer(int client, bool bShowText)
{
	int target = g_iFollowTarget[client];
	if (!target) target = client; // v1.3 FIX: guard defensivo
	if (GetClientTeam(target) != L4D2Team_Survivor || !IsPlayerAlive(target) || IsPlayerIncapacitated(target) || IsPlayerGrabbed(target))
	{
		if(bShowText) CPrintToChat(client, "{green}[Companion]{default} Your companion can't resupply ammo right now!");
		return;
	}
	
	if(!IsFollowTargetNear(client))
	{
		if(bShowText) CPrintToChat(client, "{green}[Companion]{default} Your companion needs to be close!");
		return;
	}
	
	int iPrimary = GetPlayerWeaponSlot(target, 0);
	if (!IsValidEntity(iPrimary) || !IsValidEdict(iPrimary))
	{
		if(bShowText) CPrintToChat(client, "{green}[Companion]{default} No primary weapon found to refill!");
		return;
	}
	
	GiveFullAmmo(target, true, false);
}

void GiveFullAmmo(int client, bool bKeepUpgrade = true, bool bSuppressSound = true)
{
	int iWeapon = GetPlayerWeaponSlot(client, 0);
	if (iWeapon == -1 || !IsValidEntity(iWeapon)) return;
	
	char sClassname[64];
	GetEdictClassname(iWeapon, sClassname, sizeof(sClassname));
	
	bool bIsM60 = StrEqual(sClassname, "weapon_rifle_m60");
	bool bIsGrenadeLauncher = StrEqual(sClassname, "weapon_grenade_launcher");
	
	if (bIsM60 || bIsGrenadeLauncher)
	{
		int iMaxClip = GetMaxClip(iWeapon);
		if (iMaxClip <= 0) iMaxClip = 1;
		
		SetEntProp(iWeapon, Prop_Send, "m_iClip1", iMaxClip);
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iWeapon);
		return;
	}
	
	int iAmmoType = GetEntProp(iWeapon, Prop_Send, "m_iPrimaryAmmoType");
	if (iAmmoType != -1) GivePlayerAmmo(client, 999, iAmmoType, bSuppressSound);
	
	int iMaxClip = GetMaxClip(iWeapon);
	if (iMaxClip <= 0) iMaxClip = 30;
	
	int iUpgradedLoaded = 0;
	if (bKeepUpgrade && HasEntProp(iWeapon, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded")) iUpgradedLoaded = GetEntProp(iWeapon, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
	
	if (iUpgradedLoaded > 0)
	{
		if (iUpgradedLoaded > iMaxClip) iUpgradedLoaded = iMaxClip;
		SetEntProp(iWeapon, Prop_Send, "m_iClip1", iUpgradedLoaded);
	}
	else SetEntProp(iWeapon, Prop_Send, "m_iClip1", iMaxClip);
	
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iWeapon);
	SetEntPropFloat(iWeapon, Prop_Data, "m_flNextPrimaryAttack", GetGameTime());
	
	ScreenFade(client, 100, 255, 255, 50, RoundToZero(0.6 * 1000.0), 1);
	g_iAmmoRefill_Cooldown[client] = GetTime();
}

int GetMaxClip(int iWeapon)
{
	int iAmmo;
	static char sClass[32];
	GetEdictClassname(iWeapon, sClass, sizeof(sClass));

	iAmmo = L4D2_GetIntWeaponAttribute(sClass, L4D2IWA_ClipSize);
	return iAmmo;
}

bool IsAbilityOnCooldown(int client, const char[] sAbility)
{
	int iNow = GetTime();
	if (StrEqual(sAbility, "Health")) return (g_iHealing_Cooldown[client] != 0 && (g_iHealing_Cooldown[client] + g_iPet_HealCooldown > iNow));
	else if (StrEqual(sAbility, "Anti-Puke")) return (g_iAntiPuke_Cooldown[client] != 0 && (g_iAntiPuke_Cooldown[client] + g_iPet_AntiPukeCooldown > iNow));
	else if (StrEqual(sAbility, "Revive")) return (g_iRevive_Cooldown[client] != 0 && (g_iRevive_Cooldown[client] + g_iPet_ReviveCooldown - g_iReviveSaved[client] > iNow));   // v56: descuenta lo ahorrado
	else if (StrEqual(sAbility, "Ammo")) return (g_iAmmoRefill_Cooldown[client] != 0 && (g_iAmmoRefill_Cooldown[client] + g_iPet_AmmoRefillCooldown > iNow));
	else if (StrEqual(sAbility, "Adrenaline")) return (g_iAdrenBoost_Cooldown[client] != 0 && (g_iAdrenBoost_Cooldown[client] + g_iPet_AdrenBoostCooldown > iNow));
	return false;
}

Action Timer_ActivateAutoAbilities(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsPetValid(client))
	{
		g_hTimer_CheckAutoAbilities[client] = null;
		return Plugin_Stop;
	}
	
	if (g_bAutoHeal[client] && !IsAbilityOnCooldown(client, "Health"))
	{
		if(GetClientHealth(client) + L4D_GetTempHealth(client) <= GetEntProp(client, Prop_Send, "m_iMaxHealth") - g_iPet_HealAmount)
			ActivateEnergyAbilities(client, "Health", false);
	}
	
	if (g_bAutoAntiPuke[client] && g_iPlayerOnVomit[client] == 1 && !IsAbilityOnCooldown(client, "Anti-Puke")) ActivateEnergyAbilities(client, "Anti-Puke", false);
	if (g_bAutoRevive[client] && !IsAbilityOnCooldown(client, "Revive")) RevivePlayer(client, false);

		// v56: si TODO el equipo esta caido (nadie en pie), la recarga del Revivir
		// se recorta a la MITAD del tiempo restante — una sola vez por ciclo
		if (IsAbilityOnCooldown(client, "Revive"))
		{
			if (g_bReviveWipeCut[client])
			{
				if (!PetTeamAllDown()) g_bReviveWipeCut[client] = false;   // se levanto alguien
			}
			else if (PetTeamAllDown())
			{
				int cut = ReviveTimeLeft(client) / 2;
				if (cut > 0)
				{
					g_iReviveSaved[client] += cut;
					g_bReviveWipeCut[client] = true;
					CPrintToChat(client, "{green}[Companion]{default} {olive}Revivir de emergencia{default}: equipo caido — recarga recortada a la mitad (lista en {olive}%d s{default}).",
						ReviveTimeLeft(client));
				}
			}
		}
	if (g_bAutoAdren[client] && !IsAbilityOnCooldown(client, "Adrenaline")) GiveAdrenalineboost(client, false);
	if (g_bAutoAmmo[client] && !IsAbilityOnCooldown(client, "Ammo"))
	{
		int target = g_iFollowTarget[client];
		if (!IsClientInGame(target) || !IsPlayerAlive(target)) target = client;
		
		int iWeapon = GetPlayerWeaponSlot(target, 0);
		if (iWeapon == -1 || !IsValidEntity(iWeapon)) return Plugin_Continue;
		
		int iAmmoType = GetEntProp(iWeapon, Prop_Send, "m_iPrimaryAmmoType");
		
		if (iAmmoType != -1)
		{
			int iReserve = GetEntProp(target, Prop_Send, "m_iAmmo", _, iAmmoType);
			if (iReserve > 0) return Plugin_Continue;
		}
	
		// v1.3 FIX: hay que pasar al DUENO. Antes se pasaba el objetivo seguido:
		// la funcion rellena el arma de g_iFollowTarget[objetivo] (normalmente 0
		// para companeros sin mascota) -> error "Client index 0 is invalid"
		// cada 3 segundos y municion al jugador equivocado.
		TransferAmmoToPlayer(client, false);
	}
	
	return Plugin_Continue;
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *													Spawn The Pet												   *
 *================================================================================================================ */

void OpenTeleportPetMenu(int client)
{
	Menu menu = new Menu(Handle_TeleportPetMenu);
	menu.SetTitle("Teleport Companion To:");
	
	char sInfo[255];
	char sPosition[32];
	char sUserID[10];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != L4D2Team_Survivor || !IsPetValid(client)) continue;
		
		if(!IsPlayerAlive(i)) FormatEx(sPosition, sizeof(sPosition), "Dead");
		else if (IsPlayerIncapacitated(i) && !IsPlayerGrabbed(i)) FormatEx(sPosition, sizeof(sPosition), "Incapped");
		else if (IsHandingFromLedge(i)) FormatEx(sPosition, sizeof(sPosition), "Hanging");
		else if (IsPlayerGrabbed(i)) FormatEx(sPosition, sizeof(sPosition), "Held By Infected");
		else FormatEx(sPosition, sizeof(sPosition), "Standing");
		
		FormatEx(sInfo, sizeof(sInfo), "%N - %s", i, sPosition);
		IntToString(GetClientUserId(i), sUserID, sizeof(sUserID));
		menu.AddItem(sUserID, sInfo);
	}
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int Handle_TeleportPetMenu(Menu menu, MenuAction action, int client, int select)
{
	if (action == MenuAction_Select)
	{
		char sUserID[12];
		menu.GetItem(select, sUserID, sizeof(sUserID));
		int target = GetClientOfUserId(StringToInt(sUserID));
		
		if(!IsPetValid(client))
		{
			CPrintToChat(client, "{green}[Companion]{default} You have no pet.");
			ShowChampMenu(client);
			return 0;
		}
		
		if (!target || !IsClientInGame(target) || GetClientTeam(target) != L4D2Team_Survivor) return 0;
		
		if (!IsPlayerAlive(target))
		{
			CPrintToChat(client, "{green}[Companion]{default} %N is dead.", target);
			OpenTeleportPetMenu(client);
			return 0;
		}
		
		if (target != client && IsPetValid(target))
		{
			CPrintToChat(client, "{green}[Companion]{blue} %N {default}already has a pet.", target);
			OpenTeleportPetMenu(client);
			return 0;
		}
		
		g_iFollowTarget[client] = target;
		TeleportPet(client);
		OpenTeleportPetMenu(client);
	}
	else if (action == MenuAction_Cancel && select == MenuCancel_ExitBack) ShowChampMenu(client);
	else if (action == MenuAction_End) delete menu;
	return 0;
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *											Corner Stone Of Tracking Mechanism									   *
 *================================================================================================================ */

public void OnGameFrame()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != L4D2Team_Survivor) continue;
		if (!IsPetValid(client) || g_hTimer_MoveIn[client] != null || g_bIsTeleportPet[client]) continue;
                if (g_bChampDashing[client]) continue;   // v45 FUSION: embestida en curso, el seguimiento espera
		
		int target = g_iFollowTarget[client];
		if (!IsClientInGame(target) || !IsPlayerAlive(target) || GetClientTeam(target) != L4D2Team_Survivor) g_iFollowTarget[client] = client;
		
		SetTrackingMethod(client);

        // v77: rastreo EN TIEMPO REAL de la presa (Poppy): se valida CADA
        // FRAME y, si cayo, la siguiente presa sale en ESTE frame — el
        // motor de habilidades (0.3 s) ya no decide cuando se entera Poppy
        if (g_iChampSel[client] == 1 && g_bPoppyStats)
            PoppyFastTrack(client);
    }

    // v63 (v28): el bot del senuo vive PEGADO al cuerpo de Poppy: donde se
    // mueve ella (mismo frame), se mueve el bot. Teleport por frame = las
    // paredes y los empujones jamas importan.
    // v66 (v31): y ADEMAS re-bloquea el render cada frame. El juego adopta
    // al bot ~1 s despues de nacer (le asigna personaje: modelo nuevo +
    // nombre del personaje + render normal): con candado por frame jamas
    // se le llega a ver el cuerpo.
    // v67 (v32): el candado ahora es COMPLETO y va ANTES de comprobar la
    // vida: aunque el juego tenga al bot en el limbo de re-nacer (la
    // adopcion lo respawnea), nombre/personaje/modelo/render se re-fijan
    // en el mismo frame en que vuelve a existir. Solo se ESCRIBE si algo
    // difiere: cero costo por frame cuando todo esta bien.
    // v35 (v72): MULTI-SENUO — un candado/pegado por cada duena activa
    for (int dOwner = 1; dOwner <= MaxClients; dOwner++)
    {
        int dBot = g_iDecoyBot[dOwner];
        if (dBot <= 0 || !IsClientInGame(dBot) || !IsFakeClient(dBot)) continue;
        DecoyLockVisuals(dBot, dOwner);

        // pegado por frame al cuerpo de Poppy (solo si esta vivo)
        if (IsPlayerAlive(dBot) && IsPetValid(dOwner))
        {
            int dpet = EntRefToEntIndex(g_iPet_Entity[dOwner]);
            if (dpet > 0 && IsValidEntity(dpet))
            {
                float dPos[3];
                GetEntPropVector(dpet, Prop_Data, "m_vecOrigin", dPos);
                float dVel[3];
                dVel[0] = 0.0; dVel[1] = 0.0; dVel[2] = 0.0;   // v66: nunca velocidad basura
                TeleportEntity(dBot, dPos, NULL_VECTOR, dVel);
            }
        }
    }
}

void SetTrackingMethod(int client)
{
	int target = g_iFollowTarget[client];
	if (!target || !IsClientInGame(target) || GetClientTeam(target) != L4D2Team_Survivor || !IsPlayerAlive(target)) target = client;
	
	float vClientPos[3], vPetPos[3];
	GetClientAbsOrigin(target, vClientPos);
	GetEntPropVector(g_iPet_Entity[client], Prop_Data, "m_vecOrigin", vPetPos);
	
	float fDistance = GetVectorDistance(vClientPos, vPetPos);
	
	// 1) Hanging or active revive: prioritize getting close
	if (IsHandingFromLedge(target) || g_bReviveInProgress[client])
	{
		g_bPetPaused[client] = false;
		
		if (fDistance <= CLIENT_NEAR_DISTANCE)
		{
			if (g_bReviveInProgress[client]) RevivePlayer(client, false);
			else SetPetAnimation(client, "Idle");
			return;
		}
	}
	
	// 2) Hazard / ladder freeze with safe auto-resume via teleport cooldown
	if (g_bPetPaused[client] || ShouldFreezeForFatalOrLadder(client))
	{
		g_bPetPaused[client] = true;
		SetPetAnimation(client, "Idle");
		
		if (IsGrounded(client) && !IsOnLadder(client) && (GetTime() - g_iLastTeleportTime[client] >= 3))
		{
			g_bPetPaused[client] = false;
			TeleportPet(client);
		}
		return;
	}
	
	// 3) Long gap > teleport
	// v63 (v28): leash propio de Poppy — persigue comunes lejos sin que
	// el sistema la traiga de vuelta a la fuerza. v77: el METODO manda —
	// DPS casi nunca la trae de vuelta (4000), TANK 3200, SUP 600
	float fLeash = TELEPORT_DISTANCE;
	if (g_iChampSel[client] == 1 && g_bPoppyStats) fLeash = PoppyLeashRadius(client);
	if (fDistance > fLeash)
	{
		// v78: DPS/TANK en excursion con el FARO (marchando o peleando por
		// su cuenta, a cualquier distancia de la duena) NO se teletransporta
		// a la fuerza: esta haciendo su merito por la ruta de los infectados.
		// 10 s sin latido (ni marcha ni combate) o la guardia de la duena ->
		// la cuerda vuelve a mandar y entra el rescate clasico
		if (g_iChampSel[client] == 1 && g_bPoppyStats && g_bPoppyFaroLoose[client]
				&& (GetGameTime() - g_fPoppyFaroLive[client]) < 10.0)
			return;
		g_bPoppyFaroLoose[client] = false;   // rescate: vuelve al redil
		TeleportPet(client);
		return;
	}
	
	// 4) Refresh steps while allowing animation
	// v77: DPS/TANK con presa viva JAMAS se quedan esperando junto a la
	// duena — siguen cazando aunque este pegada a ella (el candado de
	// animacion de la v76 sigue mandando dentro de MovePetToNextStep)
	if (fDistance <= CLIENT_NEAR_DISTANCE)
	{
		if (g_iChampSel[client] == 1 && g_bPoppyStats
			&& (g_iPoppyMethod[client] == POPPY_M_DPS || g_iPoppyMethod[client] == POPPY_M_TANK)
			&& !g_bChampDashing[client])
		{
			MovePetToNextStep(client, vClientPos, vPetPos);
			return;
		}
		if (GetGameTime() < g_fPet_AnimLock[client]) return;
		SetPetAnimation(client, "Idle");
		ResetSteps(client, vClientPos);
		return;
	}
	
	// 5) Normal chase
	MovePetToNextStep(client, vClientPos, vPetPos);
}

// v36 (usuario): decisiones del paso de combate de Poppy
#define POPPY_MOVE_OWNER 0   // volver con la duena (la necesita / sin enemigos)
#define POPPY_MOVE_CHASE 1   // avanzar hacia la presa
#define POPPY_MOVE_HOLD  2   // plantarse a rango y rematar (combate prolongado)
#define POPPY_MOVE_FARO  3   // v78: marchar sola por la ruta del mapa (faro: el flow de los infectados)

// v77: radio de caza por metodo (a cuantos u rastrea presas alrededor)
float PoppyHuntRadius(int client)
{
    switch (g_iPoppyMethod[client])
    {
        case POPPY_M_DPS, POPPY_M_TANK: return 3000.0;
        case POPPY_M_SUP: return 800.0;
    }
    return (g_fChampRange + 40.0) * g_fPoppyVision;
}

// v77: cuerda con la duena por metodo (a cuantos u se aleja antes de
// volver / de que el sistema la teletransporte a su lado)
float PoppyLeashRadius(int client)
{
    switch (g_iPoppyMethod[client])
    {
        case POPPY_M_DPS:  return 4000.0;
        case POPPY_M_TANK: return 3200.0;
        case POPPY_M_SUP:  return 600.0;
    }
    return g_fPoppyLeash;
}

void MovePetToNextStep(int client, float vClientPos[3], float vPetPos[3])
{
	// v47/v76: estilo LoL — mientras dura una animacion de ACCION (el
	// swing del auto-ataque, prio 1, o una habilidad, prio 2) el campeon
	// NO se mueve: espera a que la animacion TERMINE y luego retoma la
	// marcha. UNICA excepcion: la CARGA de la R de Poppy (windup, tipo
	// 20) — ella SI camina mientras carga, pero en pose de windup: la
	// animacion nunca se reemplaza.
	if (g_iChampAnimPrio[client] >= 1 && GetGameTime() < g_fPet_AnimLock[client]
		&& g_iPet_MoveType[client] != 20) return;
	
	float vPetAngle[3];
	GetEntPropVector(g_iPet_Entity[client], Prop_Data, "m_angRotation", vPetAngle);
	
	// Always record the newest step
	SaveNextStep(client, vClientPos);
	
	// v63 (v28): Poppy CAMINA HACIA los comunes — con presa viva fuera
	// de rango de golpe (y LOS real, y dentro del leash), persigue a la
	// presa en vez de seguir la migaa del duena: paso virtual al objetivo
	// v36 (usuario): COMBATE PROLONGADO — tres decisiones: volver con la
	// duena (la necesita), avanzar hacia la presa o PLANTARSE a rango
	// (antes volvia con la duena entre golpe y golpe: el va-y-vien)
	float nextX, nextY, nextZ;
	float vCombatNext[3];
	int iCombatMove = POPPY_MOVE_OWNER;
	if (g_iChampSel[client] == 1 && g_bPoppyStats)
	    iCombatMove = PoppyCombatMove(client, vPetPos, vCombatNext);
	// v79: SALTO DE FE del faro — el waypoint de la cadena esta muy arriba
	// o muy abajo (escalera de mano / drop): blink al punto ANTES de mover
	// (el motor reescribe el origin al final del paso, asi que el warp
	// manda desde aqui, estilo recall y no vuelta a la duena)
	if (iCombatMove == POPPY_MOVE_FARO && g_bPoppyFaroLoose[client] && g_iPoppyFaroArea[client] != 0)
	{
	    float dzW = g_vPoppyFaroPoint[client][2] - vPetPos[2];
	    if (dzW > 100.0 || dzW < -100.0)
	    {
	        float dxW = g_vPoppyFaroPoint[client][0] - vPetPos[0];
	        float dyW = g_vPoppyFaroPoint[client][1] - vPetPos[1];
	        if (dxW * dxW + dyW * dyW < 102400.0 && FaroWarp(client)) return;   // 320^2
	    }
	}
	if (iCombatMove == POPPY_MOVE_HOLD)
	{
	    // plantada a rango: encara y remata SIN seguir las migas de la
	    // duena (durante el swing manda la animacion de ataque)
	    if (GetGameTime() >= g_fPet_AnimLock[client])
	    {
	        PoppyCombatHoldFace(client, vPetPos);
	        ResetSteps(client, vClientPos);
	    }
	    return;
	}
	if (iCombatMove == POPPY_MOVE_CHASE || iCombatMove == POPPY_MOVE_FARO)   // v78: el paso del faro se camina igual que el de persecucion
	{
	    nextX = vCombatNext[0];
	    nextY = vCombatNext[1];
	    nextZ = vCombatNext[2];
	}
	else
	{
	    nextX = g_fPlayerSteps[g_iLoadedStep[client]][client][0];
	    nextY = g_fPlayerSteps[g_iLoadedStep[client]][client][1];
	    nextZ = g_fPlayerSteps[g_iLoadedStep[client]][client][2];
	}
	
	float deltaX  = nextX - vPetPos[0];
	float deltaY  = nextY - vPetPos[1];
	float deltaZ  = nextZ - vPetPos[2];
	
	float fDist2D = SquareRoot(deltaX *deltaX  + deltaY * deltaY);
	
	// Compute exact yaw & pitch from step A (pet) to step B (next step)
	float fHoriz = (fDist2D < 0.0001) ? 0.0001 : fDist2D;
	float fTargetYaw   =  (ArcTangent2(deltaY , deltaX ) * 180.0) / FLOAT_PI;
	float fTargetPitch = -(ArcTangent2(deltaZ , fHoriz) * 180.0) / FLOAT_PI;
	
	
	// Spin check fix
	float fCurrYaw = vPetAngle[1];
	float fYawDiff = fTargetYaw - fCurrYaw;
	
	while (fYawDiff > 180.0) fYawDiff -= 360.0;
	while (fYawDiff < -180.0) fYawDiff += 360.0;
	if ((fDist2D < 18.0 && FloatAbs(fYawDiff) > 135.0) || (fDist2D < 16.0 && FloatAbs(fTargetPitch) > 45.0))
	{
		SetPetAnimation(client, "Idle");
		ResetSteps(client, vClientPos);
		return;
	}
	
	// Teleport the pet whenever the required pitch angle is too steep, indicating a sharp change in elevation.
	if (FloatAbs(fTargetPitch) > 75.0)
	{
		// v79: en plena marcha del faro una escalera NO la devuelve a
		// la duena: SALTO DE FE (blink al waypoint) o espera su cooldown
		if (g_bPoppyFaroLoose[client] && g_iPoppyFaroArea[client] != 0)
		{
			FaroWarp(client);
			return;
		}
		TeleportPet(client);
		return;
	}
	
	// Set angles directly (no caps / no smoothing)
	vPetAngle[1] = fTargetYaw;
	vPetAngle[0] = fTargetPitch;
	
	// Face and move forward based on the full 3D angle (no vertical cap)
	float vDirection[3];
	float vNewPos[3];
	GetAngleVectors(vPetAngle, vDirection, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vDirection, vDirection);
	
	float fSpeed = SetPetSpeed(client, vClientPos, vPetPos);
	
	// Keep your animation logic tied to fSpeed
	float fAbsPitch = FloatAbs(vPetAngle[0]);
	if (fAbsPitch > 10.0) fSpeed *= 0.9;
	if (fAbsPitch > 18.0) fSpeed *= 0.8;
	
	// Move using the exact forward vector
	vNewPos[0] = vPetPos[0] + vDirection[0] * fSpeed;
	vNewPos[1] = vPetPos[1] + vDirection[1] * fSpeed;
	vNewPos[2] = vPetPos[2] + vDirection[2] * fSpeed;
	
	SetAbsOrigin(g_iPet_Entity[client], vNewPos);
	SetAbsAngles(g_iPet_Entity[client], vPetAngle);
	
	LoadNextStep(client, vNewPos);
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *												Save/Load/Reset Steps											   *
 *================================================================================================================ */

void SaveNextStep(int client, float vPos[3])
{
	float fInterval = PET_MOVE_INTERVAL;
	float fNow = GetGameTime();
	if (fNow - g_fLastStepWriteTime[client] < fInterval) return;
	
	int target = g_iFollowTarget[client];
	if (!target || !IsClientInGame(target) || GetClientTeam(target) != L4D2Team_Survivor || !IsPlayerAlive(target))
	target = client;
	
	g_fPlayerSteps[g_iSavedStep[client]][client][0] = vPos[0];
	g_fPlayerSteps[g_iSavedStep[client]][client][1] = vPos[1];
	g_fPlayerSteps[g_iSavedStep[client]][client][2] = IsGrounded(target) ? vPos[2] : (vPos[2] - GroundDistance(target));
	
	g_iSavedStep[client] = (g_iSavedStep[client] > 0) ? (g_iSavedStep[client] - 1) : (MAX_STEPS_MEMORY - 1);
	g_fLastStepWriteTime[client] = fNow;
}

void LoadNextStep(int client, float pos[3])
{
	float fReached = STEP_REACH_DISTANCE + 6.0;
	if (GetVectorDistance(pos, g_fPlayerSteps[g_iLoadedStep[client]][client]) < fReached)
		g_iLoadedStep[client] = (g_iLoadedStep[client] - 1 + MAX_STEPS_MEMORY) % MAX_STEPS_MEMORY;
}

void ResetSteps(int client, float pos[3])
{
    int target = g_iFollowTarget[client];
    if (!target || !IsClientInGame(target) || GetClientTeam(target) != L4D2Team_Survivor || !IsPlayerAlive(target))
        target = client;

    if (IsGrounded(target)) SnapPetToGround(client);

    if (!g_bReviveInProgress[client]) SetPetAnimation(client, "Idle");

    g_iSavedStep[client]  = MAX_STEPS_MEMORY - 1;
    g_iLoadedStep[client] = MAX_STEPS_MEMORY - 1;

    SaveNextStep(client, pos);
}

// v63 (v28): paso de combate de Poppy — hacia la presa, no hacia la migaa
// v36 (usuario): COMBATE PROLONGADO. Antes, al llegar a rango de golpe,
// Poppy dejaba de perseguir y volvia a las migas de la duena (por eso
// "iba y vena" dando vueltas entre golpe y golpe). Ahora hay TRES
// decisiones:
//   POPPY_MOVE_OWNER: volver con la duena — porque la necesita al lado
//     (agarrada/colgada de cornisa, especial o witch pegados a ELLA, tank
//     rondandola) o porque ya no queda ningun enemigo;
//   POPPY_MOVE_CHASE: avanzar hacia la presa (persigue, como siempre);
//   POPPY_MOVE_HOLD: PLANTARSE — ya esta a rango de golpe y se queda
//     rematando SIN volver con la duena: el combate se alarga hasta que
//     la presa (o la siguiente, y la siguiente...) caiga.
int PoppyCombatMove(int client, const float petPos[3], float out[3])
{
    if (g_bChampDashing[client]) return POPPY_MOVE_OWNER;
    if (!IsPetValid(client)) return POPPY_MOVE_OWNER;

    // la duena la necesita AL LADO: se suelta de la presa y vuelve YA
    // v78: y la excursion del faro TERMINA (la cuerda se reata)
    if (PoppyOwnerNeedsGuard(client))
    {
        g_bPoppyFaroLoose[client] = false;
        return POPPY_MOVE_OWNER;
    }

    int target = EntRefToEntIndex(g_iChampTarget[client]);
    if (target <= 0 || target >= 2048 || !IsValidEntity(target) || !IsEnemyAlive(target))
    {
        // v78 (duena): sin presa a la vista — DPS/TANK no se quedan dando
        // vueltas ni vuelven con la duena: MARCHAN por la RUTA de los
        // infectados (faro de flow del nav mesh) hacia la meta del mapa.
        // Aparece una presa -> el combate pausa la marcha; queda limpia la
        // zona -> la ruta se reanuda sola. BOT/SUP siguen con las migas de
        // la duena, como siempre.
        if ((g_iPoppyMethod[client] == POPPY_M_DPS || g_iPoppyMethod[client] == POPPY_M_TANK)
                && PoppyFaroStep(client, petPos, out))
            return POPPY_MOVE_FARO;
        return POPPY_MOVE_OWNER;   // sin enemigos: seguimiento normal
    }

    float tPos[3];
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", tPos);

    // v78: latido de COMBATE lejos de casa — mientras pelee (o marche: el
    // faro tambien late) la cuerda sigue suelta; 10 s quieta de verdad y
    // el teletransporte de rescate entra solo
    if (g_bPoppyFaroLoose[client]
            && (g_iPoppyMethod[client] == POPPY_M_DPS || g_iPoppyMethod[client] == POPPY_M_TANK))
        g_fPoppyFaroLive[client] = GetGameTime();

    float range = ChampAttackRange(client);
    float dist = GetVectorDistance(petPos, tPos);
    if (dist <= range + 1.0) return POPPY_MOVE_HOLD;   // a rango de golpe: se planta y remata (el +12 de antes la dejaba a 162 u sin poder golpear)

    // ni la presa ni Poppy mas lejos del leash de la duena (histeresis
    // +120 en la presa: no floppear justo en el borde del leash)
    // v77: la cuerda depende del METODO — DPS/TANK van casi sueltos
    // (4000/3200 u) y SUP lleva correa corta (600 u)
    float oPos[3];
    GetClientAbsOrigin(client, oPos);
    // v78: excursion con el faro = cuerda SUELTA: pelea el combate de
    // siempre con lo que se encuentre en la ruta, este donde este. Vuelve
    // al redil por su pie al acercarse a la duena (300 u) o si ella la
    // necesita (guardia) — o a los 10 s de inactividad (rescate)
    if (g_bPoppyFaroLoose[client] && GetVectorDistance(oPos, petPos) < 300.0)
        g_bPoppyFaroLoose[client] = false;
    float fLeashM = PoppyLeashRadius(client);
    if (!g_bPoppyFaroLoose[client] && GetVectorDistance(oPos, tPos) > fLeashM + 120.0) return POPPY_MOVE_OWNER;
    if (!g_bPoppyFaroLoose[client] && GetVectorDistance(oPos, petPos) > fLeashM) return POPPY_MOVE_OWNER;

    // LOS cacheada 0.25 s (la traza es cara: no por frame)
    float now = GetGameTime();
    if (now >= g_fPoppyLOSNext[client])
    {
        g_fPoppyLOSNext[client] = now + 0.25;
        float from[3];
        from[0] = petPos[0]; from[1] = petPos[1]; from[2] = petPos[2] + 40.0;
        g_bPoppyLOSOK[client] = PoppyTraceClear(from, tPos);
    }
    // v77: DPS/TANK persiguen AUN SIN linea de vision — rodean el muro
    // con la navegacion de esquiva (PoppySteerStep, estilo infectado) en
    // vez de volverse con la duena; BOT y SUP conservan la regla clasica
    if (!g_bPoppyLOSOK[client])
    {
        if (g_iPoppyMethod[client] == POPPY_M_DPS || g_iPoppyMethod[client] == POPPY_M_TANK)
        {
            // v78: la presa EXISTE pero el nav dice que no hay camino REAL
            // hasta ella (al otro lado del muro): ni topes contra la pared
            // ni rodeo a ciegas — el faro la lleva por la ruta hasta que el
            // camino hacia ella se abra (re-verificado cada 0.75 s)
            if (PoppyTargetPathBlocked(client, petPos, tPos))
            {
                if (PoppyFaroStep(client, petPos, out)) return POPPY_MOVE_FARO;
                return POPPY_MOVE_OWNER;
            }
            if (PoppySteerStep(petPos, tPos, out)) return POPPY_MOVE_CHASE;
            // v78: boxeada de verdad — antes se volvia con la duena; ahora
            // el faro la saca caminando por la ruta de los infectados
            if (PoppyFaroStep(client, petPos, out)) return POPPY_MOVE_FARO;
        }
        return POPPY_MOVE_OWNER;      // no atraviesa muros
    }

    // paso virtual: 26 u hacia la presa (orienta yaw/pitch; la velocidad
    // real la sigue poniendo SetPetSpeed como siempre)
    float dir[3];
    MakeVectorFromPoints(petPos, tPos, dir);
    float flat = SquareRoot(dir[0] * dir[0] + dir[1] * dir[1]);
    if (flat < 0.001) return POPPY_MOVE_HOLD;
    NormalizeVector(dir, dir);
    float step = (dist < 26.0) ? dist : 26.0;
    out[0] = petPos[0] + dir[0] * step;
    out[1] = petPos[1] + dir[1] * step;
    out[2] = petPos[2] + dir[2] * step;
    return POPPY_MOVE_CHASE;
}

// v36: presa STICKY — mantiene la actual mientras siga viva y a tiro
// (vision + leash con la misma histeresis del paso de combate); solo
// acepta la nueva cuando la anterior cayo o se fue del alcance
int PoppyStickyTarget(int client, const float petPos[3], int fresh)
{
    int cur = EntRefToEntIndex(g_iChampTarget[client]);
    if (cur > 0 && cur < 2048 && IsValidEntity(cur) && IsEnemyAlive(cur))
    {
        float cPos[3];
        GetEntPropVector(cur, Prop_Send, "m_vecOrigin", cPos);
        float oPos[3];
        GetClientAbsOrigin(client, oPos);
        // v77: radio de caza y cuerda por METODO — DPS/TANK no sueltan
        // la presa por distancia a la duena; SUP la suelta enseguida
        if (GetVectorDistance(petPos, cPos) <= PoppyHuntRadius(client)
            && (g_bPoppyFaroLoose[client] || GetVectorDistance(oPos, cPos) <= PoppyLeashRadius(client) + 120.0))
            return cur;   // v78: en excursion mantiene presas fuera del leash sin floppear
    }
    return fresh;
}

// v36 (usuario): la duena solo recupera a Poppy a su lado cuando esta
// REALMENTE en peligro — agarrada o en estado de control (smoker, hunter,
// jockey, charger, pummel), colgada de cornisa, un especial o la witch
// pegados a ella (250 u) o un tank vivo rondandola (1500 u). El resto del
// tiempo, con enemigos cerca, Poppy se queda en combate prolongado.
bool PoppyOwnerNeedsGuard(int client)
{
    // estos dos van SIEMPRE en vivo (son baratos y son la urgencia real:
    // agarrada / colgada): ni cache ni nada
    if (IsPlayerGrabbed(client)) return true;
    if (IsHandingFromLedge(client)) return true;

    // v37 (v74): CACHE de 0.15 s. La v36 re-escaneaba TODO el mapa CADA FRAME
    // aqui (PetEnemiesInRadius = 2 FindEntityByClassname que recorren todas
    // las entidades, por cada dueña, desde OnGameFrame) y encima los
    // "return true" de dentro del loop se saltaban el delete list: un Handle
    // de ArrayList perdido POR FRAME con un especial/witch pegado a la dueña
    // (una partida larga agotaba la tabla de handles del server: timers y
    // menus dejan de crearse). Mismo veredicto, calculado 6.7 veces/s.
    float now = GetGameTime();
    if (now < g_fPoppyGuardNext[client]) return g_bPoppyGuardLast[client];
    g_fPoppyGuardNext[client] = now + 0.15;

    float oPos[3];
    GetClientAbsOrigin(client, oPos);

    // especial, witch o tank PEGADO a la duena (250 u)
    bool bGuard = false;
    ArrayList list = new ArrayList();
    int n = PetEnemiesInRadius(oPos, 250.0, list);
    for (int i = 0; i < n && !bGuard; i++)
    {
        int ent = list.Get(i);
        if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
        if (ent > MaxClients)
        {
            char cls[16];
            if (!GetEntityClassname(ent, cls, sizeof(cls))) continue;
            if (StrEqual(cls, "witch", false)) bGuard = true;   // la witch pegada a la duena
            continue;                                           // comun: no cuenta
        }
        bGuard = true;   // especial o tank a 250 u de la duena
    }
    delete list;   // v37: SIEMPRE liberado (la v36 filtraba un Handle por frame)

    // tank vivo rondando a la duena (1500 u): prioridad absoluta
    if (!bGuard)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (i == client || !IsClientInGame(i) || !IsPlayerAlive(i)) continue;
            if (GetClientTeam(i) != 3) continue;
            if (GetEntProp(i, Prop_Send, "m_zombieClass") != 8) continue;
            float tPos[3];
            GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(oPos, tPos) <= 1500.0) { bGuard = true; break; }
        }
    }

    g_bPoppyGuardLast[client] = bGuard;
    return bGuard;
}

// v36: PLANTADA a rango — encara a la presa mientras la remata (sin
// volver a las migas de la duena entre golpe y golpe)
void PoppyCombatHoldFace(int client, const float petPos[3])
{
    int target = EntRefToEntIndex(g_iChampTarget[client]);
    if (target <= 0 || target >= 2048 || !IsValidEntity(target)) return;
    float tPos[3];
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", tPos);
    float dir[3];
    MakeVectorFromPoints(petPos, tPos, dir);
    float ang[3];
    GetEntPropVector(g_iPet_Entity[client], Prop_Data, "m_angRotation", ang);
    ang[0] = 0.0;
    ang[1] = (ArcTangent2(dir[1], dir[0]) * 180.0) / FLOAT_PI;
    ang[2] = 0.0;
    SetAbsAngles(g_iPet_Entity[client], ang);
    // v37: el Idle se re-emite como mucho cada 0.6 s. La v36 lo mandaba CADA
    // FRAME mientras Poppy esta plantada: SetAnimation reinicia la secuencia
    // en su frame 0 y el idle quedaba "clavado" (tieso) entre ataques. El
    // swing de ataque sigue mandando siempre (su animlock ya lo protege).
    float nowH = GetGameTime();
    if (nowH >= g_fPoppyHoldIdleAt[client])
    {
        g_fPoppyHoldIdleAt[client] = nowH + 0.6;
        SetPetAnimation(client, "Idle");
    }
}

// v77 (duena): Poppy SIEMPRE mira hacia donde activo la accion — los
// golpes basicos, el Q y la E encaran su direccion de disparo en el
// frame exacto del cast; el candado de animacion (v76) conserva la pose
// hasta que la accion termina
void PetFaceYaw(int client, const float dir[3])
{
    int pet = EntRefToEntIndex(g_iPet_Entity[client]);
    if (pet <= 0 || !IsValidEntity(pet)) return;
    float flat = SquareRoot(dir[0] * dir[0] + dir[1] * dir[1]);
    if (flat < 0.001) return;
    float ang[3];
    GetEntPropVector(pet, Prop_Data, "m_angRotation", ang);
    ang[0] = 0.0;
    ang[1] = (ArcTangent2(dir[1], dir[0]) * 180.0) / FLOAT_PI;
    ang[2] = 0.0;
    SetAbsAngles(pet, ang);
}

void PetFacePoint(int client, const float p[3])
{
    int pet = EntRefToEntIndex(g_iPet_Entity[client]);
    if (pet <= 0 || !IsValidEntity(pet)) return;
    float petPos[3], dir[3];
    GetEntPropVector(pet, Prop_Data, "m_vecOrigin", petPos);
    MakeVectorFromPoints(petPos, p, dir);
    PetFaceYaw(client, dir);
}

// v77: rastreo EN VIVO de la presa (la duena lo pidio a tiempo real): la
// presa se valida CADA FRAME desde OnGameFrame y, si cayo, la siguiente
// sale en ESTE frame — el motor de habilidades (0.3 s) ya no decide
// cuando se entera Poppy de que su presa murio
void PoppyFastTrack(int client)
{
    int pet = EntRefToEntIndex(g_iPet_Entity[client]);
    if (pet <= 0 || !IsValidEntity(pet)) return;
    int cur = EntRefToEntIndex(g_iChampTarget[client]);
    if (cur > 0 && cur < 2048 && IsValidEntity(cur) && IsEnemyAlive(cur)) return;   // presa viva

    float now = GetGameTime();
    if (now < g_fPoppyFastNext[client]) return;   // anti-spam del re-scan (0.1 s)
    g_fPoppyFastNext[client] = now + 0.1;

    float petPos[3];
    GetEntPropVector(pet, Prop_Data, "m_vecOrigin", petPos);
    int fresh = Champ_FindTarget(client, petPos);
    fresh = PoppyStickyTarget(client, petPos, fresh);
    if (fresh > 0) g_iChampTarget[client] = EntIndexToEntRef(fresh);
    else g_iChampTarget[client] = -1;
}

// v77: paso libre de muros — traza de casco desde el cuerpo de Poppy
// hasta 46 u por delante del rumbo probado (solo mundo: ni jugadores ni
// presas cuentan como obstaculo)
bool PoppyStepClear(const float petPos[3], const float dir[3], float step)
{
    float from[3], to[3];
    from[0] = petPos[0]; from[1] = petPos[1]; from[2] = petPos[2] + 32.0;
    to[0] = petPos[0] + dir[0] * step;
    to[1] = petPos[1] + dir[1] * step;
    to[2] = petPos[2] + 32.0;
    float mins[3] = { -16.0, -16.0, 0.0 };
    float maxs[3] = { 16.0, 16.0, 56.0 };
    Handle h = TR_TraceHullFilterEx(from, to, mins, maxs, MASK_SOLID_BRUSHONLY, PoppyTraceFilter, 0);
    bool clear = !TR_DidHit(h);
    delete h;
    return clear;
}

// v77: navegacion con ESQUIVA (el "pathfinding de infectados" casero):
// rumbo directo a la presa y, si hay muro, se rota en escalones de 30/60/
// 90/120 grados a ambos lados (el giro mas pequeno primero) hasta el
// primer hueco libre — RODEA esquinas y obstaculos en vez de darse de
// topes. Si todo esta cerrado devuelve false y Poppy vuelve a las migas
// de la duena: el camino REAL que alguien camino, como hacen los
// infectados cuando no ven a nadie.
bool PoppySteerStep(const float petPos[3], const float tPos[3], float out[3])
{
    float dir[3];
    MakeVectorFromPoints(petPos, tPos, dir);
    dir[2] = 0.0;
    if (GetVectorLength(dir) < 0.001) return false;
    NormalizeVector(dir, dir);
    float yaw = ArcTangent2(dir[1], dir[0]);
    static const float fOffs[9] = { 0.0, 30.0, -30.0, 60.0, -60.0, 90.0, -90.0, 120.0, -120.0 };
    for (int i = 0; i < 9; i++)
    {
        float rad = (yaw + fOffs[i]) * FLOAT_PI / 180.0;
        float d[3];
        d[0] = Cosine(rad);
        d[1] = Sine(rad);
        d[2] = 0.0;
        if (PoppyStepClear(petPos, d, 46.0))
        {
            out[0] = petPos[0] + d[0] * 26.0;
            out[1] = petPos[1] + d[1] * 26.0;
            out[2] = petPos[2];
            return true;
        }
    }
    return false;
}

// v78: veredicto del NAV — hay camino REAL hasta la presa? Los infectados
// se mueven por el nav mesh: si ni ellos llegarian alli (TravelDistance
// devuelve -1.0) o el rodeo es absurdo (mas de 900 u extra Y mas de 4x la
// linea recta), la presa esta DETRAS DE UN MURO y perseguirla en linea
// recta solo deja a Poppy pegada al muro dando topes (el bug reportado).
// Cacheado 0.75 s: la consulta de camino no es gratis.
bool PoppyTargetPathBlocked(int client, const float petPos[3], const float tPos[3])
{
    if (!g_bFaroNativesOK) return false;
    float now = GetGameTime();
    if (now < g_fPoppyTgtPathNext[client]) return g_bPoppyTgtPathBad[client];
    g_fPoppyTgtPathNext[client] = now + 0.75;

    float pFrom[3], pTo[3];
    pFrom[0] = petPos[0]; pFrom[1] = petPos[1]; pFrom[2] = petPos[2];
    pTo[0] = tPos[0];     pTo[1] = tPos[1];     pTo[2] = tPos[2];
    float nav = L4D2_NavAreaTravelDistance(pFrom, pTo, false);
    if (nav < 0.0)
        g_bPoppyTgtPathBad[client] = true;
    else
    {
        float straight = GetVectorDistance(petPos, tPos);
        g_bPoppyTgtPathBad[client] = (nav > 900.0 && nav > straight * 4.0);
    }
    return g_bPoppyTgtPathBad[client];
}

// v79: nativos del faro activos este mapa? La RUTA REAL pide el mismo
// juego que usa su l4d_path_to_goal (GetAllNavAreas / SpawnAttributes /
// MapMaxFlowDistance / flow de areas). Su server ya los tiene (su plugin
// de beams corre con ellos); si no, todo el faro queda apagado y Poppy
// usa la navegacion clasica — el plugin carga igual.
void FaroCheckNatives()
{
    g_bFaroNativesOK =
           GetFeatureStatus(FeatureType_Native, "L4D_GetNearestNavArea") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D2Direct_GetTerrorNavArea") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D2Direct_GetTerrorNavAreaFlow") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D_GetNavAreaID") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D_GetNavAreaCenter") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D_NavArea_GetAdjacentAreas") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D_NavArea_IsConnected") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D2_NavAreaTravelDistance") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D_GetAllNavAreas") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D_GetNavArea_SpawnAttributes") == FeatureStatus_Available
        && GetFeatureStatus(FeatureType_Native, "L4D2Direct_GetMapMaxFlowDistance") == FeatureStatus_Available;
    // opcional de lujo: sin IsBlocked la ruta se construye igual (sin
    // excluir puertas cerradas)
    g_bFaroBlkOK = GetFeatureStatus(FeatureType_Native, "L4D_NavArea_IsBlocked") == FeatureStatus_Available;
}


// v79 (duena): ================= LA RUTA REAL (port de su l4d_path_to_goal) =================
// Su sistema hace exactamente lo que ella describio: "literalmente servia
// para que en si pudieras ver la ruta desde tu posicion hasta el final (osea
// la zona segura o el objetivo)". Esa ruta es una CADENA ORDENADA de celdas —
// las areas nav marcadas ESCAPE_ROUTE (la ruta que caminan los infectados),
// ordenadas por flow, con los saltos del mapper reparados (stitch por
// exploracion del nav) y la continuidad validada con trazas de casco (el
// mismo filtro de su plugin: mundo + prop_static + func_brush). Aqui se
// construye ESA MISMA cadena una vez por mapa con presupuesto de CPU por
// frame (0.5 ms, patron PTG) y Poppy DPS/TANK la SIGUE celda a celda cuando
// no hay presa: el combate pausa la marcha y al limpiar la zona retoma
// donde iba. La v78 trepaba el flow a ciegas vecino por vecino (por eso
// "seguia igual" y se pegaba a los muros); la cadena ya sabe el camino
// COMPLETO hasta la meta.

#define FARO_STAGE_IDLE    0
#define FARO_STAGE_COLLECT 1   // recolectar areas ESCAPE_ROUTE + checkpoints
#define FARO_STAGE_SORT    2   // ordenar por flow
#define FARO_STAGE_BUILD   3   // cadena con continuidad + stitch de saltos
#define FARO_NAV_COOLDOWN  3.1416   // patron PTG: margen tras eventos de nav
#define FARO_BUDGET_MS     0.5      // presupuesto de CPU por frame (patron PTG)

// la cadena caduca y se reconstruye cuando el nav cambia (ronda nueva,
// puerta que abre, nav regenerado); el watch y el paso del faro la piden
void FaroRouteDirty()
{
    if (!g_bFaroNativesOK) return;
    g_tFaroNav = GetGameTime();
    g_bFaroRouteReady = false;
    g_bFaroRouteBuilding = false;   // cancela una construccion en curso
    g_iFaroStage = FARO_STAGE_IDLE;
}

// mapa nuevo: nada de la cadena anterior sobrevive (Address de otro nav)
void FaroRouteReset()
{
    g_bFaroRouteReady = false;
    g_bFaroRouteBuilding = false;
    g_iFaroStage = FARO_STAGE_IDLE;
    g_iFaroLoop = 0;
    g_iFaroRetries = 0;
    g_tFaroNav = -1.0;
    g_fFaroMaxFlow = 0.0;
    delete g_FaroRoute;
    delete g_FaroAreas;
    delete g_FaroCells;
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iPoppyFaroIdx[i] = 0;
        g_iPoppyFaroArea[i] = 0;
    }
}

// construir YA (lazy desde el paso del faro o desde el watch)
void FaroRouteKick()
{
    if (!g_bFaroNativesOK || g_bFaroRouteBuilding || g_bFaroRouteReady) return;
    if (g_iFaroRetries >= 5) return;   // el mapa no coopera: hasta el proximo mapa
    g_bFaroRouteBuilding = true;
    g_iFaroStage = FARO_STAGE_COLLECT;
    g_iFaroLoop = 0;
    delete g_FaroRoute;
    g_FaroRoute = new ArrayList(sizeof(FaroCell));
    delete g_FaroAreas;
    delete g_FaroCells;
    // los waypoints en curso caducan con la cadena nueva
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iPoppyFaroIdx[i] = 0;
        g_iPoppyFaroArea[i] = 0;
    }
    RequestFrame(FaroPrepFrame);
}

bool FaroBudgetExceeded()
{
    return ((GetEngineTime() - g_fFaroFrameStart) * 1000.0) >= FARO_BUDGET_MS;
}

// el mapa no da flow/nav util ahora: reintento con cooldown (patron PTG)
void FaroRouteAbort()
{
    g_bFaroRouteBuilding = false;
    g_iFaroStage = FARO_STAGE_IDLE;
    g_iFaroRetries++;
    g_tFaroNav = GetGameTime();
    delete g_FaroAreas;
    delete g_FaroCells;
    delete g_FaroRoute;
}

// el motor por etapas (patron OnFramePrep del PTG: sigue en la misma frame
// hasta agotar el presupuesto; RequestFrame para continuar la siguiente)
void FaroPrepFrame()
{
    if (!g_bFaroRouteBuilding) return;   // cancelado (map end / nav cambio)
    g_fFaroFrameStart = GetEngineTime();
    bool budget = false;
    switch (g_iFaroStage)
    {
        case FARO_STAGE_COLLECT: budget = FaroStageCollect();
        case FARO_STAGE_SORT:    FaroStageSort();
        case FARO_STAGE_BUILD:   budget = FaroStageBuild();
        default:
        {
            FaroRouteAbort();
            return;
        }
    }
    if (!g_bFaroRouteBuilding) return;   // aborto dentro de la etapa
    if (budget || FaroBudgetExceeded())
    {
        RequestFrame(FaroPrepFrame);
        return;
    }
    if (g_iFaroStage == FARO_STAGE_BUILD)   // construccion completa
    {
        g_bFaroRouteBuilding = false;
        g_bFaroRouteReady = true;
        g_iFaroStage = FARO_STAGE_IDLE;
        g_iFaroRetries = 0;
        delete g_FaroCells;
        LogMessage("[Raven] Ruta del mapa lista: %d celdas hacia la meta (flow %.0f).", g_FaroRoute.Length, g_fFaroMaxFlow);
        return;
    }
    g_iFaroStage++;
    FaroPrepFrame();   // siguiente etapa en la misma frame (patron PTG)
}

// ETAPA 1: recolectar las celdas de la ruta de escape (port del
// STAGE_PREP+COLLECT de PTG): de todas las areas del nav mesh quedarse con
// las ESCAPE_ROUTE (flow >= 0, sin flow duplicado — patron PTG), y anotar
// los checkpoints de inicio/fin por si la colecta no los toca
bool FaroStageCollect()
{
    if (g_iFaroLoop == 0)
    {
        g_fFaroMaxFlow = L4D2Direct_GetMapMaxFlowDistance();
        if (g_fFaroMaxFlow <= 0.0)
        {
            FaroRouteAbort();   // flow aun no calculado por el juego: reintento
            return false;
        }
        delete g_FaroAreas;
        g_FaroAreas = new ArrayList();
        L4D_GetAllNavAreas(g_FaroAreas);
        if (g_FaroAreas.Length <= 1)
        {
            FaroRouteAbort();
            return false;
        }
        delete g_FaroCells;
        g_FaroCells = new ArrayList(sizeof(FaroCell));
        g_fFaroFlowStart = g_fFaroMaxFlow;
        g_fFaroFlowEnd = 0.0;
        g_aFaroStart = Address_Null;
        g_aFaroEnd = Address_Null;
        g_bFaroMissingStart = true;
        g_bFaroMissingEnd = true;
    }
    static FaroCell cell;
    static float pos[3];
    while (g_iFaroLoop < g_FaroAreas.Length)
    {
        if (FaroBudgetExceeded()) return true;
        Address navArea = view_as<Address>(g_FaroAreas.Get(g_iFaroLoop));
        g_iFaroLoop++;
        if (navArea == Address_Null) continue;
        float flow = L4D2Direct_GetTerrorNavAreaFlow(navArea);
        int attrs = L4D_GetNavArea_SpawnAttributes(navArea);
        if (g_bFaroBlkOK && L4D_NavArea_IsBlocked(navArea, 2, true)) continue;   // puerta cerrada hoy: fuera de la ruta
        bool checkpoint = (attrs & NAV_SPAWN_PLAYER_START) != 0 || (attrs & NAV_SPAWN_CHECKPOINT) != 0;
        if ((attrs & NAV_SPAWN_ESCAPE_ROUTE) != 0 && flow >= 0.0)
        {
            if (g_FaroCells.FindValue(flow, 0) >= 0) continue;   // flow duplicado (patron PTG)
            L4D_GetNavAreaCenter(navArea, pos);
            pos[2] += 16.0;
            if (FaroPosUnderwater(pos))
            {
                pos[2] += 16.0;
                if (FaroPosUnderwater(pos)) pos[2] += 16.0;
            }
            cell.flow = flow;
            cell.navArea = navArea;
            cell.center = pos;
            g_FaroCells.PushArray(cell, sizeof(FaroCell));
            if (g_bFaroMissingStart && checkpoint && flow <= g_fFaroMaxFlow * 0.1) g_bFaroMissingStart = false;
            if (g_bFaroMissingEnd && checkpoint && flow >= g_fFaroMaxFlow * 0.25) g_bFaroMissingEnd = false;
        }
        if (checkpoint)
        {
            if (flow < g_fFaroFlowStart) { g_aFaroStart = navArea; g_fFaroFlowStart = flow; }
            if (flow > g_fFaroFlowEnd)   { g_aFaroEnd = navArea;   g_fFaroFlowEnd = flow; }
        }
    }
    // colecta completa: los extremos marcados que falten entran a la cadena (patron PTG)
    if (g_bFaroMissingStart && g_aFaroStart != Address_Null)
    {
        cell.navArea = g_aFaroStart;
        cell.flow = g_fFaroFlowStart;
        L4D_GetNavAreaCenter(g_aFaroStart, pos);
        pos[2] += 16.0;
        if (FaroPosUnderwater(pos)) pos[2] += 16.0;
        cell.center = pos;
        g_FaroCells.PushArray(cell, sizeof(FaroCell));
    }
    if (g_bFaroMissingEnd && g_aFaroEnd != Address_Null)
    {
        cell.navArea = g_aFaroEnd;
        cell.flow = g_fFaroFlowEnd;
        L4D_GetNavAreaCenter(g_aFaroEnd, pos);
        pos[2] += 16.0;
        if (FaroPosUnderwater(pos)) pos[2] += 16.0;
        cell.center = pos;
        g_FaroCells.PushArray(cell, sizeof(FaroCell));
    }
    delete g_FaroAreas;
    if (g_FaroCells.Length <= 1)
    {
        FaroRouteAbort();
        return false;
    }
    return false;
}

// ETAPA 2: ordenar por flow (STAGE_SORT de PTG) — la cadena nace ordenada
// del inicio del mapa hacia la meta; la primera celda siembra la ruta
void FaroStageSort()
{
    g_FaroCells.SortCustom(FaroSortFlow);
    static FaroCell cell;
    g_FaroCells.GetArray(0, cell, sizeof(FaroCell));
    g_FaroRoute.PushArray(cell, sizeof(FaroCell));
    g_iFaroLoop = 1;
}

int FaroSortFlow(int index1, int index2, Handle array, Handle hndl)
{
    float f1 = view_as<ArrayList>(array).Get(index1, 0);
    float f2 = view_as<ArrayList>(array).Get(index2, 0);
    if (f1 > f2) return 1;
    if (f1 < f2) return -1;
    return 0;
}

// ETAPA 3: construir la cadena con CONTINUIDAD (STAGE_FIX+BUILD de PTG):
// cada celda debe conectar con la anterior (vecindad nav o traza de casco);
// si el flow ordeno dos areas que NO se ven (el salto del mapper), el
// STITCH explora el nav mesh en vivo hasta reconectar y empalma el puente
bool FaroStageBuild()
{
    static FaroCell cell, cellPrev;
    while (g_iFaroLoop < g_FaroCells.Length)
    {
        if (FaroBudgetExceeded()) return true;
        if (g_FaroRoute.Length >= 1)
        {
            g_FaroRoute.GetArray(g_FaroRoute.Length - 1, cellPrev, sizeof(FaroCell));
            g_FaroCells.GetArray(g_iFaroLoop, cell, sizeof(FaroCell));
            if (!FaroCellsConnected(cellPrev, cell) && !FaroTraversable(cellPrev.center, cell.center))
                FaroExploreStitch(g_iFaroLoop);   // repara el salto (puede mover g_iFaroLoop)
        }
        g_FaroCells.GetArray(g_iFaroLoop, cell, sizeof(FaroCell));
        FaroAddCell(cell);
        g_iFaroLoop++;
    }
    delete g_FaroCells;
    if (g_FaroRoute.Length <= 1)
    {
        FaroRouteAbort();
        return false;
    }
    return false;
}

// STITCH (port lite del explore_stitch de PTG): desde la ultima celda BUENA
// se explora siguiendo las conexiones FORWARD del nav (flow >= actual) hasta
// dar con un area que este MAS ADELANTE en la lista ordenada; el tramo
// explorado se empalma como puente en el lugar del salto. Si no reconecta,
// la celda se agrega igual y el seguidor salta el hueco con su detector de
// atasco (la cadena sigue siendo util: es lo que hace PTG cuando su stitch
// falla — dibuja el tramo igual).
bool FaroExploreStitch(int &i_start)
{
    if (i_start <= 1 || i_start >= g_FaroCells.Length) return false;
    static FaroCell cell;
    g_FaroCells.GetArray(i_start - 1, cell, sizeof(FaroCell));
    if (cell.navArea == Address_Null) return false;
    static float pos_temp[3], pos_best[3];
    float flow_curr = cell.flow;
    Address nav_curr = cell.navArea;
    Address nav_best = nav_curr;
    pos_best = cell.center;
    if (g_FaroExplored == null) g_FaroExplored = new ArrayList();
    if (g_FaroAdj == null) g_FaroAdj = new ArrayList();
    if (g_FaroBridge == null) g_FaroBridge = new ArrayList(sizeof(FaroCell));
    g_FaroExplored.Clear();
    g_FaroBridge.Clear();
    bool success = false;
    int i_end = -1;
    int steps = 0;
    while (steps < 60)
    {
        bool found = false;
        float flow_best = flow_curr;
        for (int dir = 0; dir < 4; dir++)
        {
            g_FaroAdj.Clear();
            L4D_NavArea_GetAdjacentAreas(nav_curr, dir, g_FaroAdj);
            for (int i = 0; i < g_FaroAdj.Length; i++)
            {
                Address a = view_as<Address>(g_FaroAdj.Get(i));
                if (a == Address_Null || a == nav_curr) continue;
                if (g_FaroExplored.FindValue(a) >= 0) continue;
                g_FaroExplored.Push(a);
                if (g_bFaroBlkOK && L4D_NavArea_IsBlocked(a, 2, true)) continue;
                float f = L4D2Direct_GetTerrorNavAreaFlow(a);
                if (f < flow_curr) continue;   // solo hacia ADELANTE (el flow crece hacia la meta)
                L4D_GetNavAreaCenter(a, pos_temp);
                pos_temp[2] += 16.0;
                int hit = g_FaroCells.FindValue(a, 1);
                if (hit >= i_start) { success = true; i_end = hit; }
                if (success || f >= flow_best)
                {
                    flow_best = f;
                    nav_best = a;
                    pos_best = pos_temp;
                    found = true;
                    if (success) break;
                }
            }
            if (success) break;
        }
        if (found)
        {
            cell.flow = flow_best;
            cell.navArea = nav_best;
            cell.center = pos_best;
            g_FaroBridge.PushArray(cell, sizeof(FaroCell));
        }
        if (!found) break;
        nav_curr = cell.navArea;
        flow_curr = cell.flow;
        if (!success)
        {
            i_end = g_FaroCells.FindValue(nav_curr, 1);
            if (i_end >= i_start) success = true;
        }
        if (success) break;
        steps++;
    }
    if (!success) return false;
    // empalme (aritmetica exacta del PTG): la celda rota se reemplaza por el
    // puente, el tramo muerto se borra y el cursor salta al final del empalme
    static FaroCell cellB;
    if (g_FaroBridge.Length > 0)
    {
        g_FaroBridge.GetArray(0, cellB, sizeof(FaroCell));
        g_FaroCells.SetArray(i_start, cellB, sizeof(FaroCell));
    }
    int num_delete = i_end - i_start;
    int num_deleted = num_delete;
    while (num_delete > 0 && i_start < g_FaroCells.Length - 1)
    {
        g_FaroCells.Erase(i_start + 1);
        num_delete--;
    }
    for (int i = g_FaroBridge.Length - 1; i >= 1; i--)
    {
        g_FaroBridge.GetArray(i, cellB, sizeof(FaroCell));
        if (i_start < g_FaroCells.Length - 1)
        {
            g_FaroCells.ShiftUp(i_start + 1);
            g_FaroCells.SetArray(i_start + 1, cellB, sizeof(FaroCell));
        }
        else g_FaroCells.PushArray(cellB, sizeof(FaroCell));
    }
    i_start += num_deleted;
    return true;
}

// agregar celda a la cadena con continuidad (port lite del guide_add_cell
// de PTG): si la anterior no la ve (hull 8x8x30), se intenta levantar +16
// (borde de acera/balde); si la ve y la ANTE-anterior tambien (LOS + suelo
// valido), reemplaza en vez de apilar (la cadena queda corta y limpia).
// Si nada conecta, se agrega igual: el seguidor tiene su salto de fe y su
// detector de atasco para los huecos que queden.
void FaroAddCell(FaroCell cell)
{
    if (g_FaroRoute.Length < 1)
    {
        g_FaroRoute.PushArray(cell, sizeof(FaroCell));
        return;
    }
    static FaroCell cellPrev, cellPrev2, cellLift;
    g_FaroRoute.GetArray(g_FaroRoute.Length - 1, cellPrev, sizeof(FaroCell));
    bool prev2 = g_FaroRoute.Length >= 2;
    if (prev2) g_FaroRoute.GetArray(g_FaroRoute.Length - 2, cellPrev2, sizeof(FaroCell));
    bool los = FaroTraversable(cell.center, cellPrev.center);
    if (!los)
    {
        cellLift = cell;
        cellLift.center[2] += 16.0;
        los = FaroTraversable(cellLift.center, cellPrev.center);
        if (los) cell = cellLift;
        else
        {
            cellLift = cellPrev;
            cellLift.center[2] += 16.0;
            if (FaroTraversable(cellLift.center, cell.center) && (!prev2 || FaroTraversable(cellLift.center, cellPrev2.center)))
            {
                cellPrev = cellLift;
                g_FaroRoute.SetArray(g_FaroRoute.Length - 1, cellPrev, sizeof(FaroCell));
                los = true;
            }
        }
    }
    if (los && prev2 && FaroTripleGround(cellPrev2.center, cell.center) && FaroTraversable(cell.center, cellPrev2.center))
    {
        g_FaroRoute.SetArray(g_FaroRoute.Length - 1, cell, sizeof(FaroCell));   // atajo (patron PTG)
        return;
    }
    g_FaroRoute.PushArray(cell, sizeof(FaroCell));
}

// trazas de la ruta (ports de PTG): hull chico de jugador contra mundo +
// prop_static + func_brush — exactamente el filtro del path_to_goal
public bool FaroTraceFilter(int entity, int contentsMask, any data)
{
    if (entity == 0) return true;
    if (entity > 0 && entity <= MaxClients) return false;
    static char cls[16];
    if (!GetEntityClassname(entity, cls, sizeof(cls))) return false;
    if (StrEqual(cls, "prop_static", false)) return true;
    if (StrEqual(cls, "func_brush", false)) return true;
    return false;
}

bool FaroTraversable(const float pos1[3], const float pos2[3], float max_distance = -1.0)
{
    if (max_distance > 0.0 && GetVectorDistance(pos1, pos2) > max_distance) return false;
    float mins[3] = { -8.0, -8.0, 1.0 };
    float maxs[3] = { 8.0, 8.0, 30.0 };
    Handle h = TR_TraceHullFilterEx(pos1, pos2, mins, maxs, MASK_PLAYERSOLID, FaroTraceFilter, 0);
    bool clear = !TR_DidHit(h);
    delete h;
    return clear;
}

bool FaroPosUnderwater(const float pos[3])
{
    float top[3];
    top[0] = pos[0]; top[1] = pos[1]; top[2] = pos[2] + 64.0;
    Handle h = TR_TraceRayEx(top, pos, MASK_WATER, RayType_EndPoint);
    bool hit = TR_DidHit(h);
    delete h;
    return hit;
}

bool FaroValidGround(const float pos[3])
{
    float down[3];
    down[0] = pos[0]; down[1] = pos[1]; down[2] = pos[2] - 35.0;
    float mins[3] = { -16.0, -16.0, 2.0 };
    float maxs[3] = { 16.0, 16.0, 5.0 };
    Handle h = TR_TraceHullFilterEx(pos, down, mins, maxs, MASK_PLAYERSOLID | MASK_WATER, FaroTraceFilter, 0);
    bool hit = TR_DidHit(h);
    delete h;
    return hit;
}

bool FaroTripleGround(const float pos1[3], const float pos2[3])
{
    if (!FaroValidGround(pos1)) return false;
    if (!FaroValidGround(pos2)) return false;
    float diff[3];
    SubtractVectors(pos2, pos1, diff);
    if (GetVectorLength(diff, true) <= 4096.0) return true;
    ScaleVector(diff, 0.5);
    float mid[3];
    AddVectors(pos1, diff, mid);
    return FaroValidGround(mid);
}

// conexion nav entre dos celdas (port lite del cell_connected: vecindad
// de ida en cualquier dir — sin escaleras/ascensores, que los cubre el
// salto de fe del seguidor)
bool FaroCellsConnected(FaroCell from, FaroCell to)
{
    if (from.navArea == Address_Null || to.navArea == Address_Null) return false;
    if (from.navArea == to.navArea) return true;
    for (int dir = 0; dir < 4; dir++)
        if (L4D_NavArea_IsConnected(from.navArea, to.navArea, dir)) return true;
    return false;
}

// v79: eventos del nav (patron PTG) — ronda nueva con flow listo, puertas
// que abren/cierran, nav regenerado: la cadena caduca y se reconstruye
// cuando alguien la necesite
public void Event_FaroPostNav(Event event, const char[] name, bool dontBroadcast)
{
    FaroRouteDirty();
}

public void Event_FaroNavBlocked(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bFaroRouteReady || g_bFaroRouteBuilding) FaroRouteDirty();
}

public void Event_FaroNavGenerate(Event event, const char[] name, bool dontBroadcast)
{
    FaroRouteDirty();
}

// el vigilante (1 s): solo construye la ruta cuando alguien MARCHA (duena
// DPS/TANK con Poppy viva) y la cadena no esta — nada de CPU por gusto
Action Timer_FaroWatch(Handle timer)
{
    if (!g_bFaroNativesOK || g_bFaroRouteReady || g_bFaroRouteBuilding) return Plugin_Continue;
    if (g_iFaroRetries >= 5) return Plugin_Continue;
    if (g_tFaroNav > 0.0 && GetGameTime() < g_tFaroNav + FARO_NAV_COOLDOWN) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
        if (g_iChampSel[i] != 1 || !g_bPoppyStats) continue;
        if (g_iPoppyMethod[i] != POPPY_M_DPS && g_iPoppyMethod[i] != POPPY_M_TANK) continue;
        if (!IsPetValid(i)) continue;
        FaroRouteKick();
        break;
    }
    return Plugin_Continue;
}

// v79: SALTO DE FE — escalera de mano / desnivel grande de la cadena:
// Poppy no trepa escaleras (no es un bot del juego); en vez de devolverla
// a la duena (TeleportPet), BLINK al waypoint de la ruta estilo recall.
// 1.5 s de aproximacion a la base primero y cooldown de 2 s entre saltos.
bool FaroWarp(int client)
{
    float now = GetGameTime();
    if (now < g_fPoppyFaroWarpAt[client]) return false;
    if (g_fPoppyFaroWptAt[client] <= 0.0 || now - g_fPoppyFaroWptAt[client] < 1.5) return false;
    g_fPoppyFaroWarpAt[client] = now + 2.0;
    if (!IsPetValid(client)) return false;
    SetAbsOrigin(g_iPet_Entity[client], g_vPoppyFaroPoint[client]);
    g_iPoppyFaroArea[client] = 0;   // waypoint consumado: encadena con el siguiente
    g_fPoppyFaroStuckAt[client] = now;
    g_fPoppyFaroLive[client] = now;   // latido: sigue en excursion
    return true;
}

// v79 (duena): EL FARO — ahora sobre LA RUTA REAL: la cadena que su
// l4d_path_to_goal dibujaria con beams desde tu posicion hasta la zona
// segura. Sin presa (o presa amurallada), Poppy localiza su celda en la
// cadena — por nav area, por flow o por distancia, con el wiggle de LOS
// del RequestGuide — y camina CELDA A CELDA hacia la meta. El combate
// pausa la marcha (PoppyCombatMove solo llama al faro sin presa visible o
// con presa amurallada); zona limpia -> retoma donde iba. En la meta:
// excursion cumplida y vuelve con la duena.
bool PoppyFaroStep(int client, const float petPos[3], float out[3])
{
    if (!g_bFaroNativesOK) return false;
    if (g_iChampSel[client] != 1 || !g_bPoppyStats) return false;
    if (g_iPoppyMethod[client] != POPPY_M_DPS && g_iPoppyMethod[client] != POPPY_M_TANK) return false;

    // ruta ausente: pedir construirla YA (lazy, patron RequestGuide del
    // PTG) y mientras tanto navegar como siempre
    if (!g_bFaroRouteReady || g_FaroRoute == null || g_FaroRoute.Length < 2)
    {
        FaroRouteKick();
        return false;
    }
    int len = g_FaroRoute.Length;
    float now = GetGameTime();

    // paso 1: waypoint vigente — camina hacia el mientras quede lejos y
    // avance; 2.2 s sin progreso = cae al paso 2 (re-localizacion completa:
    // el wiggle de LOS elige la celda ALCANZABLE, no la del otro lado del
    // muro — aqui murio el bug de la v41 pegada a la pared)
    if (now < g_fPoppyFaroNext[client] && g_iPoppyFaroArea[client] != 0)
    {
        float dW = GetVectorDistance(petPos, g_vPoppyFaroPoint[client]);
        if (dW > 55.0)
        {
            if (dW < g_fPoppyFaroLastD[client] - 3.0)
                g_fPoppyFaroStuckAt[client] = now;   // sigue avanzando
            g_fPoppyFaroLastD[client] = dW;
            if (now - g_fPoppyFaroStuckAt[client] < 2.2)
                return PoppyFaroWalk(client, petPos, out, now);
            // atascada: re-localizar YA
        }
        else
        {
            g_iPoppyFaroArea[client] = 0;   // llego al waypoint: encadena YA
            g_iPoppyFaroIdx[client]++;
        }
    }

    // paso 2: (re)localizacion en la cadena (RequestGuide style)
    g_fPoppyFaroNext[client] = now + 0.4;
    int idx = FaroLocateIdx(petPos);
    if (idx < 0) return false;   // fuera del nav mesh: migas de la duena
    if (idx >= len - 1)
    {
        // LA META (zona segura / final de la ruta): excursion cumplida —
        // vuelve con la duena hasta que la ruta crezca o cambie
        g_iPoppyFaroArea[client] = 0;
        return false;
    }
    int target = idx + 1;

    static FaroCell cell;
    g_FaroRoute.GetArray(target, cell, sizeof(FaroCell));
    g_vPoppyFaroPoint[client][0] = cell.center[0];
    g_vPoppyFaroPoint[client][1] = cell.center[1];
    g_vPoppyFaroPoint[client][2] = cell.center[2];
    g_iPoppyFaroArea[client] = L4D_GetNavAreaID(cell.navArea);
    if (g_iPoppyFaroArea[client] <= 0) g_iPoppyFaroArea[client] = 1;   // marker de waypoint activo
    g_iPoppyFaroIdx[client] = target;
    g_fPoppyFaroWptAt[client] = now;
    g_fPoppyFaroLastD[client] = GetVectorDistance(petPos, g_vPoppyFaroPoint[client]);
    g_fPoppyFaroStuckAt[client] = now;

    if (!g_bPoppyFaroTold[client])
    {
        g_bPoppyFaroTold[client] = true;
        CPrintToChat(client, "{green}[Raven]{default} {olive}Ruta del mapa cargada{default} ({olive}%d{default} puntos): marchando hacia la meta — lo que encuentre, lo peleo.", len);
    }
    return PoppyFaroWalk(client, petPos, out, now);
}

// v79: la celda de la cadena MAS CERCANA a una posicion — el mismo metodo
// con el que RequestGuide ubica al jugador que pide la ruta: (1) el nav
// area donde esta parada, si esa area esta EN la cadena; (2) la celda con
// el flow mas parecido (L4D_GetFlowFromPoint); (3) la mas cercana en
// distancia; y el wiggle de LOS: si la elegida no es alcanzable desde
// aqui (traza de casco a 260 u), se prueba la de adelante o la de atras.
int FaroLocateIdx(const float petPos[3])
{
    float pSelf[3];
    pSelf[0] = petPos[0]; pSelf[1] = petPos[1]; pSelf[2] = petPos[2] + 8.0;
    Address areaHere = view_as<Address>(L4D_GetNearestNavArea(pSelf, 500.0, false, false, true, 2));
    if (areaHere == Address_Null)
        areaHere = L4D2Direct_GetTerrorNavArea(pSelf);   // plan B: el area del propio cuerpo
    if (areaHere == Address_Null) return -1;
    int len = g_FaroRoute.Length;

    int iFlow = g_FaroRoute.FindValue(areaHere, 1);
    float flow = L4D_GetFlowFromPoint(pSelf);
    if (flow <= 0.0)
    {
        static float c[3];
        L4D_GetNavAreaCenter(areaHere, c);
        flow = L4D_GetFlowFromPoint(c);
    }
    if (iFlow < 0)
    {
        bool useFlow = (flow > 0.0 && flow <= g_fFaroMaxFlow);
        float minFlowD = -1.0;
        int iBestFlow = -1;
        float minDist = -1.0;
        int iBestDist = -1;
        static FaroCell cell;
        for (int i = 0; i < len; i++)
        {
            g_FaroRoute.GetArray(i, cell, sizeof(FaroCell));
            if (minDist < 0.0 || minDist > 65536.0)   // 256^2: ya hay una celda MUY cerca (patron PTG)
            {
                float d = GetVectorDistance(petPos, cell.center, true);
                if (minDist < 0.0 || d < minDist)
                {
                    minDist = d;
                    iBestDist = i;
                }
            }
            if (useFlow)
            {
                float fd = FloatAbs(cell.flow - flow);
                if (minFlowD < 0.0 || fd < minFlowD)
                {
                    minFlowD = fd;
                    iBestFlow = i;
                }
            }
        }
        iFlow = (iBestFlow >= 0) ? iBestFlow : iBestDist;
    }
    if (iFlow < 0) return -1;

    // wiggle de LOS (patron RequestGuide): la elegida no es alcanzable de
    // donde esta -> la de adelante o la de atras
    static FaroCell cell;
    g_FaroRoute.GetArray(iFlow, cell, sizeof(FaroCell));
    if (!FaroTraversable(petPos, cell.center, 260.0))
    {
        if (iFlow + 1 < len)
        {
            g_FaroRoute.GetArray(iFlow + 1, cell, sizeof(FaroCell));
            if (FaroTraversable(petPos, cell.center, 260.0)) return iFlow + 1;
        }
        if (iFlow > 0)
        {
            g_FaroRoute.GetArray(iFlow - 1, cell, sizeof(FaroCell));
            if (FaroTraversable(petPos, cell.center, 260.0)) return iFlow - 1;
        }
    }
    return iFlow;
}

// v79: el PASO fisico hacia el waypoint activo — desnivel GRANDE en la
// cadena (escalera de mano / drop): paso PLANO hacia la base mientras el
// SALTO DE FE (FaroWarp, disparado desde MovePetToNextStep) hace el blink.
// Para lo demas: el esquiva-muros de la v40 (recto si esta libre;
// rotaciones de 30 a 120 si hay esquina) y, si esta boxeada, paso 3D
// directo solo cuando el rayo al frente este limpio (rampas empinadas).
// Devuelve false si no hay paso posible este frame (la cuerda manda).
bool PoppyFaroWalk(int client, const float petPos[3], float out[3], float now)
{
    float wpt[3];
    wpt[0] = g_vPoppyFaroPoint[client][0];
    wpt[1] = g_vPoppyFaroPoint[client][1];
    wpt[2] = g_vPoppyFaroPoint[client][2];
    // escalera/drop de la cadena: acercarse a la base caminando en PLANO
    // (el blink lo hace FaroWarp cuando toca — no trepa, no vuelve a casa)
    float dz = wpt[2] - petPos[2];
    if (dz > 100.0 || dz < -100.0)
    {
        float dx = wpt[0] - petPos[0];
        float dy = wpt[1] - petPos[1];
        if (dx * dx + dy * dy < 102400.0)   // 320^2: la base esta al alcance
        {
            float len = SquareRoot(dx * dx + dy * dy);
            if (len > 1.0)
            {
                out[0] = petPos[0] + (dx / len) * 26.0;
                out[1] = petPos[1] + (dy / len) * 26.0;
                out[2] = petPos[2];
                g_fPoppyFaroLive[client] = now;
                g_bPoppyFaroLoose[client] = true;
                return true;
            }
            return false;   // ya en la base: espera el blink
        }
    }
    if (PoppySteerStep(petPos, wpt, out))
    {
        g_fPoppyFaroLive[client] = now;
        g_bPoppyFaroLoose[client] = true;   // la excursion empieza aqui
        return true;
    }
    float dir[3];
    MakeVectorFromPoints(petPos, wpt, dir);
    float flat = SquareRoot(dir[0] * dir[0] + dir[1] * dir[1]);
    if (flat < 0.001) return false;
    NormalizeVector(dir, dir);
    float from[3], ahead[3];
    from[0] = petPos[0];   from[1] = petPos[1];   from[2] = petPos[2] + 32.0;
    ahead[0] = petPos[0] + dir[0] * 34.0;
    ahead[1] = petPos[1] + dir[1] * 34.0;
    ahead[2] = petPos[2] + dir[2] * 34.0 + 32.0;
    if (PoppyTraceClear(from, ahead))
    {
        out[0] = petPos[0] + dir[0] * 26.0;
        out[1] = petPos[1] + dir[1] * 26.0;
        out[2] = petPos[2] + dir[2] * 26.0;
        g_fPoppyFaroLive[client] = now;
        g_bPoppyFaroLoose[client] = true;
        return true;
    }
    return false;   // boxeada de verdad: la cuerda manda este frame
}

bool PoppyTraceClear(const float from[3], const float to[3])
{
    Handle h = TR_TraceRayFilterEx(from, to, MASK_SHOT, RayType_EndPoint, PoppyTraceFilter, 0);
    bool clear = !TR_DidHit(h);
    delete h;
    return clear;
}

public bool PoppyTraceFilter(int entity, int contentsMask, any data)
{
    if (entity > 0 && entity <= MaxClients) return false;   // jugadores no bloquean
    if (IsValidEntity(entity))
    {
        char cls[16];
        if (GetEntityClassname(entity, cls, sizeof(cls)))
            if (StrEqual(cls, "infected") || StrEqual(cls, "witch")) return false;   // la presa no bloquea
    }
    return true;
}


/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *									Teleport Companion Mechanism To Prevent Stuck								   *
 *================================================================================================================ */

void TeleportPet(int client)
{
	int iNow = GetTime();
	if (iNow - g_iLastTeleportTime[client] < 3) return;
	g_iLastTeleportTime[client] = iNow;
	
	if (!IsPetValid(client)) return;
	
	g_bIsTeleportPet[client] = true;
	SetPetAnimation(client, "Return");
	CreateTimer(1.0, Timer_TeleportPetIn, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_TeleportPetIn(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsPetValid(client))
	{
		g_bIsTeleportPet[client] = false;
		return Plugin_Handled;
	}
	
	int target = g_iFollowTarget[client];
	if (!target || !IsClientInGame(target) || !IsPlayerAlive(target) || GetClientTeam(target) != L4D2Team_Survivor)
        target = client;
	
	float vClientPos[3], vClientAng[3];
	GetClientAbsOrigin(target, vClientPos);
	GetEntPropVector(target, Prop_Data, "m_angRotation", vClientAng);
	
	SetAbsOrigin(g_iPet_Entity[client], vClientPos);
	SetAbsAngles(g_iPet_Entity[client], vClientAng);
	
	SetPetAnimation(client, "Spawn");
	CreateTimer(1.5, Timer_TeleportPetOut, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

Action Timer_TeleportPetOut(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsPetValid(client))
	{
		g_bIsTeleportPet[client] = false;
		return Plugin_Handled;
	}
	
	int target = g_iFollowTarget[client];
	if (!target || !IsClientInGame(target) || !IsPlayerAlive(target) || GetClientTeam(target) != L4D2Team_Survivor)
        target = client;
	
	float vPos[3];
	GetClientAbsOrigin(target, vPos);
	
	ResetSteps(client, vPos);    // <- seed for the OWNER
	
	for (int i = 0; i < MAX_STEPS_MEMORY; i++)
	{
		g_fPlayerSteps[i][client][0] = vPos[0];
		g_fPlayerSteps[i][client][1] = vPos[1];
		g_fPlayerSteps[i][client][2] = vPos[2];
	}
	
	g_bIsTeleportPet[client] = false;
	return Plugin_Handled;
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *													Pets Functions	   											   *
 *================================================================================================================ */

int CreatePropDynamic(int client, char[] model)
{
	int entity = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(entity, "model", model);
	
	float vecView[3], vDirection[3], vecPos[3];
	GetClientEyePosition(client, vecView);
	GetClientAbsOrigin(client, vecPos);
	GetClientEyeAngles(client, vecView);
	GetAngleVectors(vecView, vDirection, NULL_VECTOR, NULL_VECTOR);
	vecPos[0] += vDirection[0] * 50.0;
	vecPos[1] += vDirection[1] * 50.0;
	
	DispatchKeyValueVector(entity, "origin", vecPos);
	DispatchSpawn(entity);
	SetEntPropFloat(entity, Prop_Data, "m_flPoseParameter", 1.0, 4);
	
	g_iSavedStep[client]  = MAX_STEPS_MEMORY - 1;
	g_iLoadedStep[client] = MAX_STEPS_MEMORY - 1;
	
	float vClientPos[3];
	GetClientAbsOrigin(client, vClientPos);
	SaveNextStep(client, vClientPos);
	
	return entity;
}

void ReturnPet(int client)
{
	if(!IsPetValid(client)) return;
	g_bChampWanted[client] = false;   // v49: despedida manual — no vuelve solo
	SavePetCookies_Settings(client);
	
	CPrintToChat(client, "{green}[Companion] {default}Farewell!");
	SetPetAnimation(client, "Return");
	
	if(StrEqual(g_sPet_Name[client], "Luna") || g_sPet_Name[client][0] == '\0') g_hTimer_MoveOut[client] = CreateTimer(1.87, Timer_ReturnMyPet, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	else if(StrEqual(g_sPet_Name[client], "Raven")) g_hTimer_MoveOut[client] = CreateTimer(1.6, Timer_ReturnMyPet, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);   // v75: death real 1.50 s + margen
	else if(StrEqual(g_sPet_Name[client], "Snowy")) g_hTimer_MoveOut[client] = CreateTimer(1.2, Timer_ReturnMyPet, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	else if(StrEqual(g_sPet_Name[client], "Spyro")) g_hTimer_MoveOut[client] = CreateTimer(2.8, Timer_ReturnMyPet, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	else if(StrEqual(g_sPet_Name[client], "Ghosty")) g_hTimer_MoveOut[client] = CreateTimer(3.0, Timer_ReturnMyPet, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	else if(StrEqual(g_sPet_Name[client], "Storm")) g_hTimer_MoveOut[client] = CreateTimer(0.6, Timer_ReturnMyPet, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	else if(StrEqual(g_sPet_Name[client], "Ember")) g_hTimer_MoveOut[client] = CreateTimer(3.0, Timer_ReturnMyPet, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	else if(StrEqual(g_sPet_Name[client], "Warwick")) g_hTimer_MoveOut[client] = CreateTimer(0.9, Timer_ReturnMyPet, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_ReturnMyPet(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) return Plugin_Handled;

	g_hTimer_MoveOut[client] = null;
	RemovePet(client);
    
	return Plugin_Handled;
}

void RemovePet(int client)
{
	// v44 FUSION: al retirar el campeon se limpia su estado de combate
	Champ_OnRemoved(client);
	// v35 (v72): Poppy DESAPARECE (retiro herida, cambio de campeon,
	// toggle de mascota, fin de ronda...) -> su provocacion termina
	// AQUI y el bot prestado vuelve intacto. Es el "tiempo ilimitado"
	// pedido: el senuo dura exactamente lo que Poppy esta en el mapa.
	if (g_iDecoyBot[client] != -1)
		PoppyDecoy_End(client, false);
	// v1.3 FIX: si hay un revive de mascota en curso, se termina limpiamente ANTES
	// de matar la entidad. Si no: el objetivo quedaba congelado (MOVETYPE_NONE)
	// para siempre, con la barra de progreso atascada y el DataPack filtrado.
	if (g_bReviveInProgress[client] || g_bPetReviveActive[client]
		|| g_hTimer_ReviveCheck[client] != null)
		KillProgressBar(client, g_iFollowTarget[client]);
	
	if (g_iPet_Entity[client] && EntRefToEntIndex(g_iPet_Entity[client]) != INVALID_ENT_REFERENCE)
		AcceptEntityInput(g_iPet_Entity[client], "Kill");
	
	delete g_hTimer_MoveIn[client];
	delete g_hTimer_MoveOut[client];
	delete g_hTimer_CheckAutoAbilities[client];
	
	g_bIsTeleportPet[client]    = false;
	g_bPetPaused[client]        = false;
	g_bReviveInProgress[client] = false;
	g_bPetReviveActive[client]  = false;
	
	g_iPet_Entity[client]       = 0;
	g_iPet_MoveType[client]     = 0;
	
	g_fSetupProgressTime[client] = 0.0;
	g_fPet_AnimLock[client]      = 0.0;
	g_iChampAnimPrio[client]     = 0;    // v46
	g_fChampRavenWUntil[client]  = 0.0;  // v46
	g_fChampReleaseAt[client]   = 0.0;   // v47
	g_bChampDashCarry[client]   = false; // v47
	CleanupTongue(client);   // v48: lengua de Thresh fuera
}

bool IsPetValid(int client)
{
	return g_iPet_Entity[client] && EntRefToEntIndex(g_iPet_Entity[client]) != INVALID_ENT_REFERENCE && g_hTimer_MoveOut[client] == null;
}

float SetPetSpeed(int client, float vClientPos[3], float vPetPos[3])
{
	float fDistance = GetVectorDistance(vClientPos, vPetPos);
	float fSpeed = 0.3 + 0.0055 * fDistance;
	if (fSpeed < 0.3) fSpeed = 0.3;
	if (fSpeed > 3.6) fSpeed = 3.6;

	// v48: CAMPEONES estilo LoL — al lado de la duegna caminan al paso
	// de un superviviente (220 u/s); si se quedan a mas de 300 u
	// aceleran un 25% (275 u/s) hasta alcanzarla. La nave conserva
	// su escala proporcional de siempre.
	if (g_iChampSel[client] >= 0)
	{
		float fTick = GetTickInterval();
		if (fTick <= 0.0) fTick = 0.0333;
		if (g_bReviveInProgress[client])   // v56: carrera de emergencia al caido
						fSpeed = (fDistance > 300.0 ? 400.0 : 320.0) * fTick;   // +45% lejos / +25% cerca
				else
						fSpeed = (fDistance > 300.0 ? 275.0 : 220.0) * fTick;
		if (fSpeed < 0.3) fSpeed = 0.3;
	}
	
	float vVel[3];
	GetEntPropVector(g_iPet_Entity[client], Prop_Data, "m_vecVelocity", vVel);
	float fVel2D = SquareRoot(vVel[0]*vVel[0] + vVel[1] * vVel[1]);
	bool bIsMoving = (fDistance > CLIENT_NEAR_DISTANCE) || (fVel2D > 20.0);
	
	if (bIsMoving)
	{
		float fAnimFar = (g_iChampSel[client] >= 0) ? 300.0 : 500.0;   // v48
		if (fDistance < fAnimFar) SetPetAnimation(client, "Walk");
		else SetPetAnimation(client, "Run");
		return fSpeed;
	}
	
	if (g_iPet_MoveType[client] >= 6 && GetGameTime() < g_fPet_AnimLock[client]) return fSpeed;
	
	static float fLastAnimDist[MAXPLAYERS+1];
	float fThreshold = (fLastAnimDist[client] >= 500.0) ? 480.0 : 520.0;
	
	if (fDistance < fThreshold) SetPetAnimation(client, "Walk");
	else SetPetAnimation(client, "Run");
	
	fLastAnimDist[client] = fDistance;
	return fSpeed;
}

void SetPetAnimation(int client, const char[] sAnimName)
{
	if (!IsPetValid(client)) return;
	
	static const char sAnimKeys[][] = { "Idle","Walk","Run","Spawn","Return","Revive","Move 1","Move 2","Move 3","Move 4","Move 5","Move 6","Move 7","Attack","Attack2" };
	static const int iMoveTypes[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
	
	static const char sAnimSeqs_Luna[][] =
	{
		"idle",       // Idle
		"walk",        // Walk
		"run",       // Run
		"respawn",      // Spawn
		"death",     // Return
		"revive",     // Revive
		"dance",   // Move 1
		"jocking",  // Move 2
		"recall",      // Move 3
		"relax",      // Move 4
		"respawn",     // Move 5
		"revive",     // Move 6
		"death",   // Move 7
			"jocking",   // v44 Attack
			"relax"   // v44 Attack
	};
	
	static const float fLockDurations_Luna[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 4.3, 6.5, 6.4, 3.2, 3.97, 6.37, 1.87 , 0.7, 1.0, 0.9};
	
		// v75: secuencias REALES del MDL de Poppy (30 fps, iguales en los 3 skins):
	// attack1/attack2 1.90 s (golpes), attack3 1.10 s (E), crit 1.50 s (Q),
	// windup 5.90 s (CARGA de la R), recall 6.97 s (R), death 1.50 s,
	// spawn 1.03 s, respawn 1.47 s. Mapeo firmado por la duena del mod.
static const char sAnimSeqs_Raven[][] =
	{
		"idle",       // Idle
		"walk",        // Walk
		"run",       // Run
		"spawn",      // Spawn
		"death",     // Return
		"respawn",     // Revive
		"dance",   // Move 1
		"taunt",  // Move 2
		"laughing",      // Move 3
		"jocking",      // Move 4
		"recall",     // Move 5
		"windup",     // Move 6
		"death",   // Move 7
			"attack1",   // v44 Attack
			"attack2"   // v44 Attack
	};
	
	static const float fLockDurations_Raven[] = { 0.0, 0.0, 0.0, 1.1, 1.6, 1.5, 8.9, 4.3, 2.0, 3.2, 7.0, 5.9, 1.5 , 1.90, 1.90, 1.90};   // v75 REALES del MDL: spawn 1.03 / return=death 1.50 / revive=respawn 1.47 / dance 8.87 / taunt 4.30 / laughing 2.03 / jocking 3.23 / recall 6.97 / windup 5.90 / death 1.50 / attack1-2 1.90 COMPLETOS v76 (antes 0.95: el swing se veia cortado a la mitad y volvia al Idle)
	
	static const char sAnimSeqs_Snowy[][] =
	{
		"idle",       // Idle
		"run",        // Walk
		"run",       // Run
		"flip",      // Spawn
		"flip",     // Return
		"dance",     // Revive
		"dance",   // Move 1
		"taunt",  // Move 2
		"laughing",      // Move 3
		"jocking",      // Move 4
		"flip",     // Move 5
		"attack2",     // Move 6
		"death",   // Move 7pet
			"attack2",   // v44 Attack
			"attack2"   // v44 Attack
	};
	
	static const float fLockDurations_Snowy[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 10.0, 4.5, 3.0, 3.8, 0.9, 1.0, 5.0 , 0.8, 1.0, 1.0};
	
	static const char sAnimSeqs_Spyro[][] =
	{
		"idle",       // Idle
		"run",        // Walk
		"run",       // Run
		"winddown",      // Spawn
		"death",     // Return
		"dance",     // Revive
		"dance",   // Move 1
		"jocking",  // Move 2
		"laughing",      // Move 3
		"channel_windup",      // Move 4
		"winddown",     // Move 5
		"recall",     // Move 6
		"death",   // Move 7pet
			"channel_windup",   // v44 Attack
			"channel_windup"   // v44 Attack
	};
	
	static const float fLockDurations_Spyro[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 10.0, 3.0, 2.0, 1.6, 3.8, 6.0, 5.0 , 0.6, 0.9, 0.9};
	
	static const char sAnimSeqs_Ghosty[][] =
	{
		"idle",       // Idle
		"walk",        // Walk
		"run",       // Run
		"respawn",      // Spawn
		"death",     // Return
		"dance",     // Revive
		"dance",   // Move 1
		"taunt",  // Move 2
		"laughing",      // Move 3
		"spell",      // Move 4
		"attack2",     // Move 5
		"attack1",     // Move 6
		"death",   // Move 7
			"attack1",   // v44 Attack
			"attack2"   // v44 Attack
	};
	
	static const float fLockDurations_Ghosty[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 10.0, 6.5, 4.0, 1.5, 1.2, 1.2, 6.5 , 0.8, 1.2, 1.2};
	
	static const char sAnimSeqs_Storm[][] =
	{
		"idle",       // Idle
		"run",        // Walk
		"crouch_run",       // Run
		"respawn",      // Spawn
		"ground_pound",     // Return
		"dance",     // Revive
		"dance",   // Move 1
		"celebrate",  // Move 2
		"taunt",      // Move 3
		"laughing",      // Move 4
		"recall",     // Move 5
		"attack1",     // Move 6
		"death",   // Move 7
			"attack1",   // v44 Attack
			"attack1"   // v44 Attack
	};
	
	static const float fLockDurations_Storm[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 9.0, 3.6, 4.8, 3.8, 6.2, 1.2, 2.2 , 0.8, 1.2, 1.2};
	
	static const char sAnimSeqs_Ember[][] =
	{
		"idle",       // Idle
		"walk",        // Walk
		"run",       // Run
		"respawn",      // Spawn
		"death",     // Return
		"dance",     // Revive
		"dance",   // Move 1
		"taunt",  // Move 2
		"laughing",      // Move 3
		"jocking",      // Move 4
		"forge",     // Move 5
		"attack1",     // Move 6
		"death",   // Move 7
			"attack1",   // v44 Attack
			"forge"   // v44 Attack
	};
	
	static const float fLockDurations_Ember[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 10.0, 4.5, 5.6, 10.0, 3.2, 1.6, 3.3 , 0.9, 1.2, 1.6};
	
	static const char sAnimSeqs_Warwick[][] =
	{
		"idle",       // Idle
		"run",        // Walk
		"crouch_walk",       // Run
		"move_in",      // Spawn
		"move_out",     // Return
		"jocking",     // Revive
		"angry",   // Move 1
		"howl",  // Move 2
		"sniffing",      // Move 3
		"jocking",      // Move 4
		"laughing",     // Move 5
		"attack1",     // Move 6
		"death",   // Move 7
			"attack1",   // v44 Attack
			"attack1"   // v44 Attack
	};
	
	static const float fLockDurations_Warwick[] = { 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 2.4, 1.0, 1.6, 8.6, 5.1, 1.6, 2.66 , 0.9, 0.9};
	
	int iAnimIndex = -1;
	for (int i = 0; i < sizeof(iMoveTypes); i++)
	{
		if (StrEqual(sAnimName, sAnimKeys[i]))
		{
			iAnimIndex = i;
			break;
		}
	}
	
	if (iAnimIndex == -1) return;
	
	int iReqType = iMoveTypes[iAnimIndex];
	float fNow = GetGameTime();

	// v76: CARGA de la R en curso (windup): la animacion es INAMOVIBLE —
	// ni bailes del menu (Move 1-7), ni Idle/Walk/Run, ni el ciclo de vida
	// la cortan. El UNICO sucesor es el LANZAMIENTO del veredicto
	// (Champ_CastAnim slot 3, que no pasa por aqui). Poppy SI puede
	// caminar mientras carga (MovePetToNextStep la deja pasar en el
	// tipo 20), pero en pose de windup: la carga jamas se pierde.
	if (g_iChampSel[client] == 1 && g_iPet_MoveType[client] == 20 && fNow < g_fPet_AnimLock[client])
		return;
	
	// v46/v47: prioridades de animacion
	//   prio 0 = Idle/Walk/Run/Spawn/Return: fondo y movimiento
	//   prio 1 = Attack/Attack2: auto-ataque
	//   prio 2 = Revive/Move 1-7/casts de habilidad: ininterrumpibles
	// Reglas v47: el swing del auto-ataque SIEMPRE se ve completo — ni el
	// Idle ni el Walk/Run lo cortan y el campeon no se mueve hasta que
	// termina; las habilidades y el ciclo de vida (Spawn/Return) si pueden
	// cortarlo; una habilidad nunca se interrumpe hasta terminar su lock.
	int iPrioReq = (iReqType <= 5) ? 0 : ((iReqType >= 14) ? 1 : 2);
	
	if (g_iChampAnimPrio[client] == 2 && fNow < g_fPet_AnimLock[client] && iPrioReq < 2)
		return;   // habilidad en curso: NADA la interrumpe
	
	if (g_iChampAnimPrio[client] == 1 && fNow < g_fPet_AnimLock[client])
	{
		if (iReqType <= 3) return;   // v47: Idle/Walk/Run esperan al golpe
		if (iPrioReq == 1) return;   // re-ataque: el golpe actual termina primero
		// Spawn/Return (ciclo de vida) y las habilidades SI cortan el auto-ataque
	}
	
	if (iReqType <= 5 && g_iPet_MoveType[client] == iReqType) return;
	
	float fLockTime = 0.0;
	char sSeq[32];
	
	if(StrEqual(g_sPet_Name[client], "Luna") || g_sPet_Name[client][0] == '\0')
	{
		if (iAnimIndex < sizeof(sAnimSeqs_Luna))
		{
			fLockTime = fLockDurations_Luna[iAnimIndex];
			strcopy(sSeq, sizeof(sSeq), sAnimSeqs_Luna[iAnimIndex]);
		}
	}
	else if(StrEqual(g_sPet_Name[client], "Raven"))
	{
		if (iAnimIndex < sizeof(sAnimSeqs_Raven))
		{
			fLockTime = fLockDurations_Raven[iAnimIndex];
			strcopy(sSeq, sizeof(sSeq), sAnimSeqs_Raven[iAnimIndex]);
		}
	}
	else if(StrEqual(g_sPet_Name[client], "Snowy"))
	{
		if (iAnimIndex < sizeof(sAnimSeqs_Snowy))
		{
			fLockTime = fLockDurations_Snowy[iAnimIndex];
			strcopy(sSeq, sizeof(sSeq), sAnimSeqs_Snowy[iAnimIndex]);
		}
	}
	else if(StrEqual(g_sPet_Name[client], "Spyro"))
	{
		if (iAnimIndex < sizeof(sAnimSeqs_Spyro))
		{
			fLockTime = fLockDurations_Spyro[iAnimIndex];
			strcopy(sSeq, sizeof(sSeq), sAnimSeqs_Spyro[iAnimIndex]);
		}
	}
	else if(StrEqual(g_sPet_Name[client], "Ghosty"))
	{
		if (iAnimIndex < sizeof(sAnimSeqs_Ghosty))
		{
			fLockTime = fLockDurations_Ghosty[iAnimIndex];
			strcopy(sSeq, sizeof(sSeq), sAnimSeqs_Ghosty[iAnimIndex]);
		}
	}
	else if(StrEqual(g_sPet_Name[client], "Storm"))
	{
		if (iAnimIndex < sizeof(sAnimSeqs_Storm))
		{
			fLockTime = fLockDurations_Storm[iAnimIndex];
			strcopy(sSeq, sizeof(sSeq), sAnimSeqs_Storm[iAnimIndex]);
		}
	}
	else if(StrEqual(g_sPet_Name[client], "Ember"))
	{
		if (iAnimIndex < sizeof(sAnimSeqs_Ember))
		{
			fLockTime = fLockDurations_Ember[iAnimIndex];
			strcopy(sSeq, sizeof(sSeq), sAnimSeqs_Ember[iAnimIndex]);
		}
	}
	else if(StrEqual(g_sPet_Name[client], "Warwick"))
	{
		if (iAnimIndex < sizeof(sAnimSeqs_Warwick))
		{
			fLockTime = fLockDurations_Warwick[iAnimIndex];
			strcopy(sSeq, sizeof(sSeq), sAnimSeqs_Warwick[iAnimIndex]);
		}
	}
	
	// v47: la velocidad de ataque hace que la ANIMACION corra mas rapido
	// y el lock se acorta en la misma proporcion: el swing SIEMPRE se ve
	// completo, solo que mas veloz.
	float fRate = 1.0;
	if (iPrioReq == 1)
	{
		fRate = ChampAttackMult(client, fNow);
		// v76 (Poppy): el swing de 1.90 s se ACELERA para ocupar EXACTA-
		// MENTE el intervalo de ataque (rate = duracion / intervalo): el
		// ritmo de golpes queda IDENTICO y la animacion SIEMPRE se ve
		// completa — ni un frame cortado ni un golpe fantasma. Los demas
		// campeones (poses genericas sin MDL medido) conservan el rate
		// de velocidad de ataque de la v47.
		if (g_iChampSel[client] == 1)
		{
			float fInt = ChampAttackInterval(client);
			if (fInt > 0.10) fRate = 1.90 / fInt;
		}
		if (fRate < 1.0) fRate = 1.0;
		if (fRate > 3.0) fRate = 3.0;
	}
	Champ_SetAnimRate(client, fRate);   // v47 (resto de animaciones a 1.0)
	
	if (fLockTime > 0.0) g_fPet_AnimLock[client] = fNow + (fLockTime / fRate);
	
	// v46: la prioridad vigente caduca sola con el lock
	g_iChampAnimPrio[client] = iPrioReq;
	
	SetVariantString(sSeq);
	AcceptEntityInput(g_iPet_Entity[client], "SetAnimation");
	g_iPet_MoveType[client] = iReqType;
}

// v47: fija la velocidad de reproduccion de la secuencia del pet. La
// velocidad de ataque acelera el swing; el resto va a velocidad natural.
void Champ_SetAnimRate(int client, float rate)
{
    int pet = EntRefToEntIndex(g_iPet_Entity[client]);
    if (pet <= 0 || !IsValidEntity(pet)) return;
    if (!HasEntProp(pet, Prop_Data, "m_flPlaybackRate")) return;
    SetEntPropFloat(pet, Prop_Data, "m_flPlaybackRate", rate);
}

// v46: animacion de CASTEO de habilidad. Prioridad maxima: nada la
// interrumpe hasta que termina su lock. slot: 0=Q, 1=W, 2=E, 3=R,
// 4 = carga de la R (Poppy: windup, v75). Las secuencias de Raven
// vienen del MDL real de Poppy.
// Cada campeon usa las secuencias firma de su modelo.
void Champ_CastAnim(int client, int slot)
{
	if (!IsPetValid(client)) return;

	static const char sCastSeq[8][5][24] =
	{
		{ "jocking", "relax",     "recall",  "dance",  "jocking" },      // Luna: Vex (slot 4 sin uso)
		{ "crit",    "taunt",     "attack3", "recall", "windup" },      // Raven: Poppy v75 MDL real: Q=crit 1.50 s, W=taunt, E=attack3 1.10 s (LA anim de la E en LoL), R=recall 6.97 s (prestada), slot 4=windup 5.90 s=CARGA de la R
		{ "attack2", "flip",      "flip",    "dance",  "attack2" },     // Snowy: Anivia (slot 4 sin uso)
		{ "channel_windup", "laughing", "winddown", "dance", "channel_windup" },   // Spyro: Smolder (slot 4 sin uso)
		{ "attack1", "spell",     "attack2", "laughing", "attack1" },   // Ghosty: Thresh (slot 4 sin uso)
		{ "attack1", "taunt",     "celebrate", "ground_pound", "attack1" },   // Storm: Volibear (slot 4 sin uso)
		{ "forge",   "laughing",  "attack1", "taunt",  "forge" },       // Ember: Ornn (slot 4 sin uso)
		{ "attack1", "sniffing",  "howl",    "angry",  "attack1" }      // Warwick (slot 4 sin uso)
	};
	static const float fCastLock[8][5] =
	{
		{ 1.2, 1.5, 1.5, 2.5, 1.2 },   // Luna
		{ 1.5, 4.3, 1.1, 1.0, 5.9 },   // Raven v77: Q crit 1.50 · W taunt 4.30 COMPLETO · E attack3 1.10 · R = 1.0 s de pose al LANZAR y vuelta a la accion (la R real no es tan larga: la duena la libera al segundo) · carga windup 5.90
		{ 1.0, 1.2, 1.2, 2.5, 1.0 },   // Snowy
		{ 1.2, 1.5, 1.2, 2.2, 1.2 },   // Spyro
		{ 1.0, 1.6, 1.0, 2.0, 1.0 },   // Ghosty
		{ 1.0, 1.5, 1.2, 2.2, 1.0 },   // Storm
		{ 1.2, 1.5, 1.0, 2.0, 1.2 },   // Ember
		{ 1.0, 1.2, 1.4, 2.0, 1.0 }    // Warwick
	};

	int sel = g_iChampSel[client];
	if (sel < 0 || sel > 7 || slot < 0 || slot > 4) return;   // v75: slot 4 = carga de la R (Poppy)

	// v76 (Poppy): un cast NUEVO no interrumpe al que esta en curso —
	// la animacion actual termina primero (el kit ya espera por su
	// cuenta; esto es la red de seguridad para cualquier otra
	// llamada). UNICA excepcion: el LANZAMIENTO de la R (slot 3), el
	// sucesor natural de la carga (windup) — el veredicto SI la corta
	// al dispararse su timer.
	if (sel == 1 && g_iChampAnimPrio[client] == 2 && GetGameTime() < g_fPet_AnimLock[client]
		&& slot != 3)
		return;

	char sSeq[24];
	strcopy(sSeq, sizeof(sSeq), sCastSeq[sel][slot]);

	g_fPet_AnimLock[client]  = GetGameTime() + fCastLock[sel][slot];
	g_iChampAnimPrio[client] = 2;              // habilidad: nada la interrumpe
	g_iPet_MoveType[client]  = 16 + slot;      // tipo propio de cast: los checks viejos lo respetan

	Champ_SetAnimRate(client, 1.0);            // v47: los casts a velocidad natural
	SetVariantString(sSeq);
	AcceptEntityInput(g_iPet_Entity[client], "SetAnimation");
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *											Detecting Ground and Fall Distance	   								   *
 *================================================================================================================ */

float GroundDistance(int client)
{
	float fStart[3], fDistance = 0.0;
	if(IsGrounded(client)) return 0.0;
	
	GetClientAbsOrigin(client, fStart);
	fStart[2] += 10.0;
	
	Handle hTrace = TR_TraceRayFilterEx(fStart, view_as<float>({90.0, 0.0, 0.0}), MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client); 
	if (TR_DidHit(hTrace))
	{
		float fEndPos[3];
		TR_GetEndPosition(fEndPos, hTrace);
		fStart[2] -= 10.0;
		fDistance = GetVectorDistance(fStart, fEndPos);
	}
	
	if (hTrace != null) CloseHandle(hTrace);
	return fDistance;
}

void SnapPetToGround(int client)
{
	if (!IsPetValid(client)) return;
	
	float vOrigin[3];
	GetEntPropVector(g_iPet_Entity[client], Prop_Data, "m_vecOrigin", vOrigin);
	
	float vStart[3];
	vStart[0] = vOrigin[0];
	vStart[1] = vOrigin[1];
	vStart[2] = vOrigin[2] + 50.0;

	float vEnd[3];
	vEnd[0] = vStart[0];
	vEnd[1] = vStart[1];
	vEnd[2] = vStart[2] - 2048.0;
	
	// v1.3 FIX: el filtro compara indices de entidad, pero g_iPet_Entity guarda una
	// referencia (nunca coincidia) -> se pasa el indice real para filtrar la mascota.
	Handle hTrace = TR_TraceRayFilterEx(vStart, vEnd, MASK_PLAYERSOLID, RayType_EndPoint, TraceRayDontHitSelf, EntRefToEntIndex(g_iPet_Entity[client]));
	
	if (hTrace != null && TR_DidHit(hTrace))
	{
		float vHit[3];
		TR_GetEndPosition(vHit, hTrace);
		
		float vFixedPos[3];
		vFixedPos[0] = vOrigin[0];
		vFixedPos[1] = vOrigin[1];
		vFixedPos[2] = vHit[2];
		
		SetAbsOrigin(g_iPet_Entity[client], vFixedPos);
	}
	
	if (hTrace != null) CloseHandle(hTrace);
}

bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	if (entity == data) return false;
	if (entity >= 1 && entity <= MaxClients && IsClientInGame(entity)) return false;
	return true; 
}

bool NextStepIsLadder(int client)
{
	float vNextStep[3];
	vNextStep[0] = g_fPlayerSteps[g_iLoadedStep[client]][client][0];
	vNextStep[1] = g_fPlayerSteps[g_iLoadedStep[client]][client][1];
	vNextStep[2] = g_fPlayerSteps[g_iLoadedStep[client]][client][2] + 16.0;
	
	int iContents  = TR_GetPointContents(vNextStep);
	return (iContents & CONTENTS_LADDER) != 0;
}

bool IsFatalDrop(int client)
{
	if (!IsClientInGame(client)) return false;
	if (IsPlayerIncapacitated(client) || IsGrounded(client) || IsOnLadder(client)) return false;
	
	float fGap = GroundDistance(client);
	
	if (fGap >= 720.0) return true;
	if (fGap >= 520.0)
	{
		float vVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVelocity);
		if (vVelocity[2] <= -240.0) return true;
	}
	
	return false;
}

bool ShouldFreezeForFatalOrLadder(int client)
{
	int target = g_iFollowTarget[client];
	if (!target || !IsClientInGame(target) || GetClientTeam(target) != L4D2Team_Survivor || !IsPlayerAlive(target)) target = client;
	
	if (IsOnLadder(target) || IsFatalDrop(target) || NextStepIsLadder(client)) return true;
	return false;
}

bool IsFollowTargetNear(int client)
{
    int target = g_iFollowTarget[client];
    if (!target || !IsClientInGame(target) || !IsPlayerAlive(target) || GetClientTeam(target) != L4D2Team_Survivor)
        return false;

    float vTarget[3], vPet[3];
    GetClientAbsOrigin(target, vTarget);
    GetEntPropVector(g_iPet_Entity[client], Prop_Data, "m_vecOrigin", vPet);
    return (GetVectorDistance(vTarget, vPet) <= CLIENT_NEAR_DISTANCE);
}

/* =============================================================================================================== *
 *			                       _____   _         _    _                                                        *
 *			                      |  __ \ | |       | |  (_)                                                       *
 *			                      | |__) || |  __ _ | |_  _  _ __   _   _  _ __ ___                                *
 *			                      |  ___/ | | / _` || __|| || '_ \ | | | || '_ ` _ \                               *
 *			                      | |     | || (_| || |_ | || | | || |_| || | | | | |                              *
 *			                      |_|     |_| \__,_| \__||_||_| |_| \__,_||_| |_| |_|                              *
 *                                                                                                                 *
 * ============================================================================================================== */

/* =============================================================================================================== *
 *												General Functions	   											   *
 *================================================================================================================ */

void ScreenFade(int target, int red, int green, int blue, int alpha, int duration, int type)
{
	Handle msg = StartMessageOne("Fade", target);
	BfWriteShort(msg, 500);
	BfWriteShort(msg, duration);
	
	if (type == 0) BfWriteShort(msg, (0x0002 | 0x0008));
	else BfWriteShort(msg, (0x0001 | 0x0010));
	BfWriteByte(msg, red);
	BfWriteByte(msg, green);
	BfWriteByte(msg, blue);
	BfWriteByte(msg, alpha);
	EndMessage();
}

bool IsGrounded(int client)
{
	return (GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONGROUND) > 0;
}

bool IsOnLadder(int client)
{
    return GetEntityMoveType(client) == MOVETYPE_LADDER;
}

bool IsPlayerIncapacitated(int client)
{
    return GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) > 0;
}

bool IsHandingFromLedge(int client)
{
	return GetEntProp(client, Prop_Send, "m_isHangingFromLedge") != 0 || GetEntProp(client, Prop_Send, "m_isFallingFromLedge") != 0;
}

bool IsPlayerGrabbed(int client)
{
	if (GetEntProp(client, Prop_Send, "m_pummelAttacker") > 0) return true;
	if (GetEntProp(client, Prop_Send, "m_carryAttacker") > 0) return true;
	if (GetEntProp(client, Prop_Send, "m_pounceAttacker") > 0) return true;
	if (GetEntProp(client, Prop_Send, "m_jockeyAttacker") > 0) return true;
	if (GetEntProp(client, Prop_Send, "m_tongueOwner") > 0) return true;
	return false;
}


// ----------------------------------------------------------------------------
// v54: VOCES OFICIALES DE POPPY (audios de LoL; .wav o .mp3 de 44.1 kHz)
// ----------------------------------------------------------------------------
// Los archivos viven en sound/poppy/ y se registran en la tabla de descargas
// (FastDL): el cliente los baja solo al entrar al servidor. Si falta alguno
// en el servidor, esa variante queda descartada en silencio (cero errores).
//   Q  (Golpe de Martillo) ........... "Comin' down!", "Hammer!"
//   W  (Presencia Inquebrantable) .... linea al DETENER a un enemigo:
//                                       "Not so fast!", "Nope."...
//   E  (Carga Heroica) ............... linea del ESTRELLON contra la pared:
//                                       "Don't move!", "Freeze!"...
//   R  (Veredicto del Guardián) ...... grito de CARGA + linea de LANZAMIENTO
// ANTI-SPAM (pedido explicito): la voz de la W tiene su propio enfriamiento
// de 2.5 s — si detiene al hunter y medio segundo despues al jockey, se oye
// UNA sola voz, sin ametralladora; y hay un hueco global de 0.7 s entre
// voces de cualquier categoria para que dos lineas nunca se solapen.
#define POPPY_VCATEGORIES 5
#define POPPY_VTOTAL 18     // = archivos de sound/poppy/ (ver tabla abajo)
#define POPPY_VQ    0       // Q: Golpe de Martillo
#define POPPY_VW    1       // W: Presencia Inquebrantable (enemigo detenido)
#define POPPY_VE    2       // E: Carga Heroica (estrellon contra la pared)
#define POPPY_VRCH  3       // R: Veredicto del Guardián (fase de CARGA)
#define POPPY_VRL   4       // R: Veredicto del Guardián (LANZAMIENTO)

static const char g_sPoppyVoiceFile[][] =   // v59/v61: SIN extension (OnMapStart elige .wav o .mp3)
{
    "poppy/q1", "poppy/q2", "poppy/q3",
    "poppy/wblock1", "poppy/wblock2", "poppy/wblock3",
    "poppy/wblock4", "poppy/wblock5", "poppy/wblock6",
    "poppy/estun1", "poppy/estun2", "poppy/estun3", "poppy/estun4",
    "poppy/rcharge1", "poppy/rcharge2",
    "poppy/rlaunch1", "poppy/rlaunch2", "poppy/rlaunch3"
};
// v59/v61: ruta final de cada voz (con su extension): se decide en cada
// mapa — .wav si existe (nativo del motor, nivel pleno), si no .mp3.
char g_sPoppyVoices[POPPY_VTOTAL][32];
static const int g_iPoppyVoiceBase[POPPY_VCATEGORIES] = { 0,  3,  9, 13, 15 };
static const int g_iPoppyVoiceLen[POPPY_VCATEGORIES]  = { 3,  6,  4,  2,  3 };
static const float g_fPoppyVoiceCd[POPPY_VCATEGORIES] = { 0.0, 2.5, 0.8, 0.0, 0.0 };

// v60: duracion REAL de cada linea (medida sobre los .wav oficiales; los
// .mp3 duran lo mismo +-%0.05 s) — la R de Poppy espera lo que dura SU
// audio de carga antes de lanzarse
static const float g_fPoppyVoiceDur[POPPY_VTOTAL] =
{
    1.26, 0.84, 0.78,                    // Q: Golpe de Martillo
    1.33, 0.69, 0.97, 0.56, 1.25, 0.97,  // W: bloqueo
    0.74, 0.77, 1.48, 1.32,              // E: estrellon
    4.18, 4.13,                          // R: carga (¡la R espera la linea!)
    1.70, 1.38, 1.29                     // R: lanzamiento
};
float g_fPoppyLastVoiceDur = 0.0;   // v60: duracion de la ultima voz SONADA

bool g_bPoppyVoiceOk[POPPY_VTOTAL];
float g_fPoppyVoiceNext[POPPY_VCATEGORIES];   // siguiente voz valida por categoria
float g_fPoppyVoiceAnyNext;                   // hueco global anti-solape

// precache + tabla de descargas (FastDL) de las voces; se llama en cada mapa
// v61: cada voz acepta .wav o .mp3 — se usa el archivo que exista en el
// servidor (WAV PREFERIDO: formato nativo, nivel pleno; mp3 solo de respaldo)
// y ese MISMO nombre es el que se registra en la tabla de descargas y se
// emite a los clientes. (hasta 4.6.8 preferia mp3: por eso los .wav
// subidos al servidor nunca se usaban, "no cargaban").
void PoppyVoice_OnMapStart()
{
    char path[96], snd[48];
    int ok = 0, nMp3 = 0, nWav = 0;
    for (int i = 0; i < POPPY_VTOTAL; i++)
    {
        g_bPoppyVoiceOk[i] = false;
        g_sPoppyVoices[i][0] = '\0';

        // v61: WAV PRIMERO — formato nativo del motor, se oye a nivel pleno;
        // .mp3 solo si falta el .wav. (Antes era al reves: el .wav del
        // servidor nunca se usaba porque el .mp3 siempre ganaba.)
        Format(snd, sizeof(snd), "%s.wav", g_sPoppyVoiceFile[i]);
        Format(path, sizeof(path), "sound/%s", snd);
        bool isMp3 = !FileExists(path);
        if (isMp3)
        {
            Format(snd, sizeof(snd), "%s.mp3", g_sPoppyVoiceFile[i]);
            Format(path, sizeof(path), "sound/%s", snd);
            if (!FileExists(path)) continue;   // sin archivo: sin voz ni descarga
        }
        strcopy(g_sPoppyVoices[i], sizeof(g_sPoppyVoices[]), snd);
        AddFileToDownloadsTable(path);
        g_bPoppyVoiceOk[i] = PrecacheSound(g_sPoppyVoices[i], true);
        if (g_bPoppyVoiceOk[i]) { ok++; if (isMp3) nMp3++; else nWav++; }
    }
    // GetGameTime() vuelve a 0 en cada mapa: reset del anti-spam
    for (int c = 0; c < POPPY_VCATEGORIES; c++) g_fPoppyVoiceNext[c] = 0.0;
    g_fPoppyVoiceAnyNext = 0.0;
    LogMessage("Voces de Poppy: %d/%d listas en sound/poppy/ (%d wav + %d mp3 de respaldo; Q, W-bloqueo, E-estrellon, R).",
        ok, POPPY_VTOTAL, nWav, nMp3);
}

// suelta una voz de Poppy desde SU CUERPO — espacial con .wav, y desde v61
// a SNDLEVEL_SCREAMING (se la oye desde lejos). v61: los archivos vienen
// re-masterizados (+5 dB de cuerpo), se escuchan sobre la horda; con .mp3
// no es espacial. Variante al azar entre las disponibles.
void Poppy_Voice(int pet, int cat)
{
    if (pet <= 0 || pet >= 2048 || !IsValidEntity(pet)) return;
    if (cat < 0 || cat >= POPPY_VCATEGORIES) return;
    int n = g_iPoppyVoiceLen[cat];
    if (n <= 0) return;
    g_fPoppyLastVoiceDur = 0.0;   // v60: sin linea sonada todavia
    float now = GetGameTime();
    if (now < g_fPoppyVoiceNext[cat]) return;    // p.ej. la W: 2.5 s entre voces
    if (now < g_fPoppyVoiceAnyNext) return;      // dos voces nunca se solapan

    int first = g_iPoppyVoiceBase[cat];
    int idx = -1;
    for (int t = 0; t < 4; t++)                  // variante aleatoria valida
    {
        int cand = first + GetRandomInt(0, n - 1);
        if (g_bPoppyVoiceOk[cand]) { idx = cand; break; }
    }
    if (idx < 0)
    {
        for (int i = 0; i < n; i++)
            if (g_bPoppyVoiceOk[first + i]) { idx = first + i; break; }
    }
    if (idx < 0) return;                         // categoria sin archivos

    g_fPoppyLastVoiceDur = g_fPoppyVoiceDur[idx];   // v60: duracion de ESTA linea
    g_fPoppyVoiceNext[cat] = now + g_fPoppyVoiceCd[cat];
    g_fPoppyVoiceAnyNext = now + 0.7;
    EmitSoundToAll(g_sPoppyVoices[idx], pet, SNDCHAN_VOICE, SNDLEVEL_AIRCRAFT, _, 1.0, 100);   // v36: 120 dB (pedido: se oian bajito) — nivel de avion, nacen del cuerpo de Poppy
}

// ----------------------------------------------------------------------------
// v27/v62: SFX DE POPPY "PARTE POR PARTE" (paquete de la duena, 21 WAV)
// ----------------------------------------------------------------------------
// Segunda capa sonora sobre las voces: los EFECTOS de las habilidades.
// WAV PCM 16-bit 22050 Hz mono en sound/poppy/ (nombres con prefijo
// poppy_, sin colisionar con las voces): se descargan al cliente (FastDL)
// y si falta la carpeta, cada slot cae al sonido nativo que sonaba antes
// (degradacion elegante, patron del zap). Emision a volumen 1.0 con
// SNDLEVEL alto; los ataques usan SNDCHAN_BODY (canal propio) para no
// cortarse con las voces (SNDCHAN_VOICE) ni el resto de sonidos.
#define POP_SND_COUNT 21
static const char g_sPoppySnd[POP_SND_COUNT][32] =
{
    "poppy/poppy_q1.wav",      // 0: golpe principal del martillo (Q)
    "poppy/poppy_q2.wav",      // 1: rescoldo del golpe (Q)
    "poppy/poppy_w1.wav",      // 2: activacion de la zona (W)
    "poppy/poppy_w2.wav",      // 3: derribo del enemigo en la zona (W)
    "poppy/poppy_e1.wav",      // 4: embestida (E)
    "poppy/poppy_e2.wav",      // 5: impacto del aturdimiento contra el muro (E)
    "poppy/poppy_r1.wav",      // 6: plantado del martillo y carga (R)
    "poppy/poppy_r2.wav",      // 7: vuelo del misil (R)
    "poppy/poppy_r3.wav",      // 8: impacto final y desvanecimiento (R)
    "poppy/poppy_p1.wav",      // 9: impacto del escudo (proc P)
    "poppy/poppy_p2.wav",      // 10: segundo impacto del escudo (P)
    "poppy/poppy_p3.wav",      // 11: zumbido del escudo mientras dura (P)
    "poppy/poppy_p4.wav",      // 12: tick de desvanecimiento 1 (P)
    "poppy/poppy_p5.wav",      // 13: tick de desvanecimiento 2 (P)
    "poppy/poppy_atkfx_0.wav", // 14-19: 6 variantes de golpe (FX Astronauta)
    "poppy/poppy_atkfx_1.wav",
    "poppy/poppy_atkfx_2.wav",
    "poppy/poppy_atkfx_3.wav",
    "poppy/poppy_atkfx_4.wav",
    "poppy/poppy_atkfx_5.wav",
    "poppy/poppy_select.wav"   // 20: seleccion de campeon
};
#define POP_Q1 0
#define POP_Q2 1
#define POP_W1 2
#define POP_W2 3
#define POP_E1 4
#define POP_E2 5
#define POP_R1 6
#define POP_R2 7
#define POP_R3 8
#define POP_P1 9
#define POP_P2 10
#define POP_P3 11
#define POP_P4 12
#define POP_P5 13
#define POP_AFX 14
#define POP_SEL 20
// v77: HUESOS ROTOS de Amy (mobius) para los impactos de Poppy — pedido
// explicito de la duena, con el patron exacto de amy.inc
static const char g_sPoppyBone[3][48] = {
    "mobius/sfx/bones/bone_crack_1.mp3",
    "mobius/sfx/bones/bone_crack_2.mp3",
    "mobius/sfx/bones/bone_crack_3.mp3"
};
bool g_bPoppyBone[3];
bool g_bPoppySnd[POP_SND_COUNT];                       // v62: cada SFX precacheo bien
int g_iChampRavenPGen[MAXPLAYERS + 1];                 // v62: generacion de la secuencia del escudo (P)
float g_fChampRavenSndAt[MAXPLAYERS + 1];              // v62: anti-spam del impacto final de la R

// v62: precache + tabla de descargas (FastDL) de los SFX; reset del estado
// por duena (GetGameTime vuelve a 0 en cada mapa)
void PoppySnd_OnMapStart()
{
    char path[64];
    int ok = 0;
    for (int i = 0; i < POP_SND_COUNT; i++)
    {
        Format(path, sizeof(path), "sound/%s", g_sPoppySnd[i]);
        AddFileToDownloadsTable(path);
        g_bPoppySnd[i] = PrecacheSound(g_sPoppySnd[i], true);
        if (g_bPoppySnd[i]) ok++;
    }
    // v77: huesos rotos de Amy — descarga + precache con su propio estado
    int bok = 0;
    for (int b = 0; b < 3; b++)
    {
        char bpath[80];
        Format(bpath, sizeof(bpath), "sound/%s", g_sPoppyBone[b]);
        AddFileToDownloadsTable(bpath);
        g_bPoppyBone[b] = PrecacheSound(g_sPoppyBone[b], true);
        if (g_bPoppyBone[b]) bok++;
    }
    for (int c = 1; c <= MaxClients; c++)
    {
        g_iChampRavenPGen[c] = 0;
        g_fChampRavenSndAt[c] = 0.0;
    }
    LogMessage("SFX de Poppy (parte por parte): %d/%d listos en sound/poppy/ (P, Q, W, E, R, ataques, seleccion). Huesos de Amy: %d/3.",
        ok, POP_SND_COUNT, bok);
}

// v62: emite un SFX de Poppy; si ese WAV no precacheo (carpeta sound/poppy/
// sin los poppy_*.wav en el servidor) cae al sonido nativo que sonaba antes.
void PoppyEmit(int idx, int ent, const char[] fallback, float vol = 1.0,
               int level = SNDLEVEL_TRAIN, int channel = SNDCHAN_AUTO)
{
    if (idx >= 0 && idx < POP_SND_COUNT && g_bPoppySnd[idx])
        EmitSoundToAll(g_sPoppySnd[idx], ent, channel, level, _, vol, 100);
    else if (fallback[0] != '\0')
        EmitSoundToAll(fallback, ent, channel, level, _, vol, 100);
}

// v36 (usuario): los SFX se oian BAJO y se SOLAPABAN entre si. Causa
// raiz doble: (a) casi todos salian por SNDCHAN_AUTO y en Source un
// sonido nuevo en CHAN_AUTO del MISMO emisor REEMPLAZA al anterior
// (cualquier otro SFX de Poppy o del juego cortaba la explosion del Q
// o de la R en seco); (b) un solo canal a vol 1.0 suena debil junto a
// la horda. SOLUCION: emitir el MISMO sonido en DOS canales propios
// (se suman en el mezclador: ~+3 dB de cuerpo real), SNDLEVEL de
// disparo/cohete (140-180 dB: se oye entero a cualquier distancia
// desde el cuerpo de Poppy) y canal dedicado por familia para que
// NADA lo corte:  Q/R = WEAPON(1)+STATIC(6) · W = ITEM(3)+STREAM(5)
// · E = BODY(4)+VOICE_BASE(7) · ataques = BODY · voces = VOICE(2).
void PoppyEmitLoud(int idx, int ent, const char[] fallback, int level, int chA, int chB)
{
    char snd[64];
    if (idx >= 0 && idx < POP_SND_COUNT && g_bPoppySnd[idx])
        strcopy(snd, sizeof(snd), g_sPoppySnd[idx]);
    else if (fallback[0] != '\0')
        strcopy(snd, sizeof(snd), fallback);
    else
        return;
    EmitSoundToAll(snd, ent, chA, level, _, 1.0, 100);
    EmitSoundToAll(snd, ent, chB, level, _, 1.0, 100);
}

// v77: los GRANDES golpes (Q y R) salen a TRIPLE canal (WEAPON + STATIC +
// ITEM): el mismo sonido en tres canales propios se suma en el mezclador
// (~+4.5 dB sobre el doble) y a 140-180 dB se oye entero desde cualquier
// distancia — la duena pidio que el Q y la R se NOTEN mas.
void PoppyEmitLoud3(int idx, int ent, const char[] fallback, int level, int chA, int chB, int chC)
{
    char snd[64];
    if (idx >= 0 && idx < POP_SND_COUNT && g_bPoppySnd[idx])
        strcopy(snd, sizeof(snd), g_sPoppySnd[idx]);
    else if (fallback[0] != '\0')
        strcopy(snd, sizeof(snd), fallback);
    else
        return;
    EmitSoundToAll(snd, ent, chA, level, _, 1.0, 100);
    EmitSoundToAll(snd, ent, chB, level, _, 1.0, 100);
    EmitSoundToAll(snd, ent, chC, level, _, 1.0, 100);
}

// v77: el sonido de HUESOS ROTOS pedido por la duena — mismo patron que
// amy.inc: GetRandomInt de los 3 mp3, doble emision VOICE y STATIC a
// SNDLEVEL_RAIDSIREN sobre la VICTIMA. Si los mp3 de mobius no estan en
// el server, cae al hueso nativo del tank para no dejar el golpe mudo.
void PoppyBoneCrack(int victim)
{
    int rnd = GetRandomInt(0, 2);
    if (g_bPoppyBone[rnd])
    {
        EmitSoundToAll(g_sPoppyBone[rnd], victim, SNDCHAN_VOICE, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.0);
        EmitSoundToAll(g_sPoppyBone[rnd], victim, SNDCHAN_STATIC, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.0);
        return;
    }
    PoppyEmitLoud(-1, victim, SND_BONE, SNDLEVEL_GUNFIRE, SNDCHAN_BODY, SNDCHAN_VOICE_BASE);
}

// v62: la pasiva P SUENA parte por parte (secuencia del escudo):
// P1 impacto (al proc, desde Champ_Attack) -> P2 segundo impacto -> P3
// zumbido mientras dura -> P4/P5 ticks de desvanecimiento. La generacion
// (g_iChampRavenPGen) hace que un proc nuevo REEMPLAZE la secuencia
// anterior, y el flag NO_MAPCHANGE la mata sola si cambia el mapa.
public Action Timer_PoppyShieldSeq(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int client = GetClientOfUserId(pack.ReadCell());
    int step = pack.ReadCell();
    int gen = pack.ReadCell();

    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)
        || gen != g_iChampRavenPGen[client])
        return Plugin_Stop;   // duena caida o proc mas reciente: fuera
    if (!IsPetValid(client)) return Plugin_Stop;
    int pet = EntRefToEntIndex(g_iPet_Entity[client]);
    if (pet <= 0 || !IsValidEntity(pet)) return Plugin_Stop;

    float delay = 0.0;
    switch (step)
    {
        case 1: { PoppyEmit(POP_P2, pet, "", 1.0, SNDLEVEL_SCREAMING); delay = 0.5; }
        case 2: { PoppyEmit(POP_P3, pet, "", 1.0, SNDLEVEL_SCREAMING); delay = 5.5; }   // zumbido ~5.6 s
        case 3: { PoppyEmit(POP_P4, pet, "", 1.0, SNDLEVEL_SCREAMING); delay = 1.1; }
        case 4: { PoppyEmit(POP_P5, pet, "", 1.0, SNDLEVEL_SCREAMING); return Plugin_Stop; }
        default: return Plugin_Stop;
    }

    DataPack np = new DataPack();
    np.WriteCell(GetClientUserId(client));
    np.WriteCell(step + 1);
    np.WriteCell(gen);
    CreateTimer(delay, Timer_PoppyShieldSeq, np,
                TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
    return Plugin_Stop;
}

// v44 FUSION: OnMapStart del companion (descargas + precaches + reset)
// envuelto como funcion porque la fusion solo tiene UN OnMapStart
void Champ_OnMapStart()
{
	// ==================== LUNA ====================
	AddFileToDownloadsTable("models/pet/vex/default/default.mdl");
	AddFileToDownloadsTable("models/pet/vex/default/default.vvd");
	AddFileToDownloadsTable("models/pet/vex/default/default.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/vex/default/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/vex/default/body.vtf");
	
	AddFileToDownloadsTable("models/pet/vex/dawn/dawn.mdl");
	AddFileToDownloadsTable("models/pet/vex/dawn/dawn.vvd");
	AddFileToDownloadsTable("models/pet/vex/dawn/dawn.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/vex/dawn/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/vex/dawn/body.vtf");
	
	AddFileToDownloadsTable("models/pet/vex/shadow/shadow.mdl");
	AddFileToDownloadsTable("models/pet/vex/shadow/shadow.vvd");
	AddFileToDownloadsTable("models/pet/vex/shadow/shadow.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/vex/shadow/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/vex/shadow/body.vtf");
	
	// ==================== RAVEN ====================
	AddFileToDownloadsTable("models/pet/poppy/default/default.mdl");
	AddFileToDownloadsTable("models/pet/poppy/default/default.vvd");
	AddFileToDownloadsTable("models/pet/poppy/default/default.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/poppy/default/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/poppy/default/body.vtf");
	
	AddFileToDownloadsTable("models/pet/poppy/noxus/noxus.mdl");
	AddFileToDownloadsTable("models/pet/poppy/noxus/noxus.vvd");
	AddFileToDownloadsTable("models/pet/poppy/noxus/noxus.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/poppy/noxus/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/poppy/noxus/body.vtf");
	
	AddFileToDownloadsTable("models/pet/poppy/snowy/snowy.mdl");
	AddFileToDownloadsTable("models/pet/poppy/snowy/snowy.vvd");
	AddFileToDownloadsTable("models/pet/poppy/snowy/snowy.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/poppy/snowy/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/poppy/snowy/body.vtf");
	
	
	// ==================== ANIVIA ====================
	AddFileToDownloadsTable("models/pet/anivia/default/default.mdl");
	AddFileToDownloadsTable("models/pet/anivia/default/default.vvd");
	AddFileToDownloadsTable("models/pet/anivia/default/default.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/anivia/default/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/anivia/default/body.vtf");
	
	AddFileToDownloadsTable("models/pet/anivia/eagle/eagle.mdl");
	AddFileToDownloadsTable("models/pet/anivia/eagle/eagle.vvd");
	AddFileToDownloadsTable("models/pet/anivia/eagle/eagle.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/anivia/eagle/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/anivia/eagle/body.vtf");
	
	AddFileToDownloadsTable("models/pet/anivia/hextech/hextech.mdl");
	AddFileToDownloadsTable("models/pet/anivia/hextech/hextech.vvd");
	AddFileToDownloadsTable("models/pet/anivia/hextech/hextech.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/anivia/hextech/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/anivia/hextech/body.vtf");
	
	
	// ==================== SPYRO ====================
	AddFileToDownloadsTable("models/pet/smolder/default/default.mdl");
	AddFileToDownloadsTable("models/pet/smolder/default/default.vvd");
	AddFileToDownloadsTable("models/pet/smolder/default/default.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/smolder/default/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/smolder/default/body.vtf");
	
	AddFileToDownloadsTable("models/pet/smolder/heaven/heaven.mdl");
	AddFileToDownloadsTable("models/pet/smolder/heaven/heaven.vvd");
	AddFileToDownloadsTable("models/pet/smolder/heaven/heaven.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/smolder/heaven/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/smolder/heaven/body.vtf");
	
	AddFileToDownloadsTable("models/pet/smolder/reindeer/reindeer.mdl");
	AddFileToDownloadsTable("models/pet/smolder/reindeer/reindeer.vvd");
	AddFileToDownloadsTable("models/pet/smolder/reindeer/reindeer.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/smolder/reindeer/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/smolder/reindeer/body.vtf");
	
	
	// ==================== GHOSTY ====================
	AddFileToDownloadsTable("models/pet/thresh/default/default.mdl");
	AddFileToDownloadsTable("models/pet/thresh/default/default.vvd");
	AddFileToDownloadsTable("models/pet/thresh/default/default.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/thresh/default/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/thresh/default/body.vtf");
	
	AddFileToDownloadsTable("models/pet/thresh/janitor/janitor.mdl");
	AddFileToDownloadsTable("models/pet/thresh/janitor/janitor.vvd");
	AddFileToDownloadsTable("models/pet/thresh/janitor/janitor.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/thresh/janitor/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/thresh/janitor/body.vtf");
	
	AddFileToDownloadsTable("models/pet/thresh/moon/moon.mdl");
	AddFileToDownloadsTable("models/pet/thresh/moon/moon.vvd");
	AddFileToDownloadsTable("models/pet/thresh/moon/moon.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/thresh/moon/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/thresh/moon/body.vtf");
	
	
	// ==================== STORM ====================
	AddFileToDownloadsTable("models/pet/volibear/default/default.mdl");
	AddFileToDownloadsTable("models/pet/volibear/default/default.vvd");
	AddFileToDownloadsTable("models/pet/volibear/default/default.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/volibear/default/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/volibear/default/body.vtf");
	AddFileToDownloadsTable("materials/models/pet/volibear/default/ice.vmt");
	AddFileToDownloadsTable("materials/models/pet/volibear/default/ice.vtf");
	AddFileToDownloadsTable("materials/models/pet/volibear/default/neck.vmt");
	AddFileToDownloadsTable("materials/models/pet/volibear/default/neck.vtf");
	
	AddFileToDownloadsTable("models/pet/volibear/demon/demon.mdl");
	AddFileToDownloadsTable("models/pet/volibear/demon/demon.vvd");
	AddFileToDownloadsTable("models/pet/volibear/demon/demon.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/volibear/demon/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/volibear/demon/body.vtf");
	
	AddFileToDownloadsTable("models/pet/volibear/tiger/tiger.mdl");
	AddFileToDownloadsTable("models/pet/volibear/tiger/tiger.vvd");
	AddFileToDownloadsTable("models/pet/volibear/tiger/tiger.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/volibear/tiger/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/volibear/tiger/body.vtf");
	
	
	// ==================== EMBER ====================
	AddFileToDownloadsTable("models/pet/ornn/default/default.mdl");
	AddFileToDownloadsTable("models/pet/ornn/default/default.vvd");
	AddFileToDownloadsTable("models/pet/ornn/default/default.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/ornn/default/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/ornn/default/body.vtf");
	
	AddFileToDownloadsTable("models/pet/ornn/choochoo/choochoo.mdl");
	AddFileToDownloadsTable("models/pet/ornn/choochoo/choochoo.vvd");
	AddFileToDownloadsTable("models/pet/ornn/choochoo/choochoo.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/ornn/choochoo/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/ornn/choochoo/body.vtf");
	
	AddFileToDownloadsTable("models/pet/ornn/thunder/thunder.mdl");
	AddFileToDownloadsTable("models/pet/ornn/thunder/thunder.vvd");
	AddFileToDownloadsTable("models/pet/ornn/thunder/thunder.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/ornn/thunder/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/ornn/thunder/body.vtf");
	
	
	// ==================== WARWICK ====================
	AddFileToDownloadsTable("models/pet/warwick/hunter/hunter.mdl");
	AddFileToDownloadsTable("models/pet/warwick/hunter/hunter.vvd");
	AddFileToDownloadsTable("models/pet/warwick/hunter/hunter.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/warwick/hunter/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/warwick/hunter/body.vtf");
	
	AddFileToDownloadsTable("models/pet/warwick/firefang/firefang.mdl");
	AddFileToDownloadsTable("models/pet/warwick/firefang/firefang.vvd");
	AddFileToDownloadsTable("models/pet/warwick/firefang/firefang.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/warwick/firefang/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/warwick/firefang/body.vtf");
	
	AddFileToDownloadsTable("models/pet/warwick/bigbad/bigbad.mdl");
	AddFileToDownloadsTable("models/pet/warwick/bigbad/bigbad.vvd");
	AddFileToDownloadsTable("models/pet/warwick/bigbad/bigbad.dx90.vtx");
	AddFileToDownloadsTable("materials/models/pet/warwick/bigbad/body.vmt");
	AddFileToDownloadsTable("materials/models/pet/warwick/bigbad/body.vtf");
	
	PrecacheSound(HEALTH_SOUND, true);
	PrecacheModel(LUNA_DEFAULT_MODEL, true);
	PrecacheModel(LUNA_DAWN_MODEL, true);
	PrecacheModel(LUNA_SHADOW_MODEL, true);
	PrecacheModel(RAVEN_DEFAULT_MODEL, true);
	PrecacheModel(RAVEN_NOXUS_MODEL, true);
	PrecacheModel(RAVEN_SNOWY_MODEL, true);
	PrecacheModel(SNOWY_DEFAULT_MODEL, true);
	PrecacheModel(SNOWY_EAGLE_MODEL, true);
	PrecacheModel(SNOWY_HEXTECH_MODEL, true);
	PrecacheModel(SPYRO_DEFAULT_MODEL, true);
	PrecacheModel(SPYRO_HEAVEN_MODEL, true);
	PrecacheModel(SPYRO_REINDEER_MODEL, true);
	PrecacheModel(GHOSTY_DEFAULT_MODEL, true);
	PrecacheModel(GHOSTY_JANITOR_MODEL, true);
	PrecacheModel(GHOSTY_MOON_MODEL, true);
	PrecacheModel(STORM_DEFAULT_MODEL, true);
	PrecacheModel(STORM_DEMON_MODEL, true);
	PrecacheModel(STORM_TIGER_MODEL, true);
	PrecacheModel(EMBER_DEFAULT_MODEL, true);
	PrecacheModel(EMBER_CHOOCHOO_MODEL, true);
	PrecacheModel(EMBER_THUNDER_MODEL, true);
	PrecacheModel(WARWICK_HUNTER_MODEL, true);
	PrecacheModel(WARWICK_FIREFANG_MODEL, true);
	PrecacheModel(WARWICK_BIGBAD_MODEL, true);
	
	// v54: voces oficiales de Poppy (precache + tabla de descargas/FastDL)
	PoppyVoice_OnMapStart();
	PoppySnd_OnMapStart();   // v27: SFX parte por parte (descargas + precache + reset)
	
	g_iBeamSprite = PrecacheModel(SPRITE_BEAMS, true);
	g_iHaloSprite = PrecacheModel(SPRITE_HALOS, true);
	
	// v1.3 FIX: null-check antes de forzar el cvar
	if (g_Cvar_Server_MenuSound != null) g_Cvar_Server_MenuSound.SetInt(0);
	
	// v1.3 FIX: los timers creados con TIMER_FLAG_NO_MAPCHANGE mueren en el cambio
	// de mapa (sus handles se cierran solos) pero los globales conservan el valor
	// muerto -> luego RemovePet hacia "delete" sobre un handle invalido.
	// Reset completo del estado por jugador (y recuperamos el DataPack del revive).
	for (int i = 1; i <= MaxClients; i++)
	{
		g_hTimer_MoveIn[i]              = null;
		g_hTimer_MoveOut[i]             = null;
		g_hTimer_ReviveCheck[i]         = null;
		g_hTimer_CheckAutoAbilities[i]  = null;
		
		if (g_hRevivePack[i] != null)
		{
			delete g_hRevivePack[i];
			g_hRevivePack[i] = null;
		}
		
		g_iPet_Entity[i]        = 0;
		g_iPet_MoveType[i]      = 0;
		g_bIsTeleportPet[i]     = false;
		g_bPetPaused[i]         = false;
		g_bReviveInProgress[i]  = false;
		g_bPetReviveActive[i]   = false;
		g_bPetFrozeTarget[i]    = false;
		g_fSetupProgressTime[i] = 0.0;
		g_fPet_AnimLock[i]      = 0.0;
		g_iReviveFollowRestore[i] = 0;    // v56
		                g_iPetRevivingTarget[i]  = 0;     // v56
		                g_iLiveMenu[i]           = 0;     // v56: los menus mueren con el mapa
		                g_bMenuSelfRefresh[i]    = false; // v56
		                g_hLiveMenuTimer[i]      = null;  // v56 (NO_MAPCHANGE: murio solo)
	}

	// ---- v45 FUSION: reset del estado de combate de campeones ----
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iChampTarget[i] = -1;
		g_fChampNextAttack[i] = 0.0;
		g_fChampNextQ[i] = 0.0;
		g_fChampNextW[i] = 0.0;
		g_fChampNextE[i] = 0.0;
		g_fChampNextR[i] = 0.0;
		g_fChampNextP[i] = 0.0;
		g_fChampFuryUntil[i] = 0.0;
		g_fChampAspdUntil[i] = 0.0;
		g_fChampQEmpowerUntil[i] = 0.0;
		g_iChampStacks[i] = 0;
		g_iChampMarkRef[i] = -1;
		g_iDecoyPetRef[i] = -1;      // v36: re-prestamo de bot en la proxima invocacion
		g_fChampMarkUntil[i] = 0.0;
		g_iChampSouls[i] = 0;          // las almas de Thresh viven por mapa
		g_iChampKillsMap[i] = 0;       // el contador de Smolder vive por mapa
		g_iChampMsgKills[i] = 0;
		g_iChampMsgXP[i] = 0;
		g_fChampAuraFxAt[i] = 0.0;
		g_iChampAnimPrio[i] = 0;        // v46
		g_fChampRavenWUntil[i] = 0.0;   // v46: ventana de la W de Poppy
		g_fChampRavenChargeUntil[i] = 0.0;  // v51: la carga de la R expira sola
		g_fChampReleaseAt[i] = 0.0;     // v47
		g_bChampDashCarry[i] = false;   // v47
		g_bChampLoading[i] = false;     // v49: queries de carga al dia
		g_iChampLoadUserid[i] = 0;      // v49
		g_fChampLoadRetryAt[i] = 0.0;   // v49
		g_bChampDashing[i] = false;    // los ticks de dash mueren solos (NO_MAPCHANGE)
		g_iChampDashTarget[i] = -1;
		g_bChampZoneActive[i] = false; // las zonas mueren solas (NO_MAPCHANGE)
		if (g_hChampStagCancel[i] != null)
		{
			KillTimer(g_hChampStagCancel[i]);   // estos NO llevan NO_MAPCHANGE (patron SI_Stagger)
			g_hChampStagCancel[i] = null;
		}
	}
	for (int e = 0; e < 2048; e++)
	{
		g_iChampHitOwner[e] = -1;
		g_bChampCredited[e] = false;
		g_bChampFrozeSI[e] = false;
		g_fChampFrostbiteAt[e] = 0.0;
		g_fChampDoomUntil[e] = 0.0;
		g_iChampDoomOwner[e] = 0;
		g_bChampFrozen[e] = false;
		g_fChampLaunchedAt[e] = 0.0;
		g_iChampLaunchedBy[e] = 0;
		g_fChampLaunchDmg[e] = 0.0;
		g_fChampDashHitAt[e] = 0.0;
		g_fChampWGuardAt[e] = 0.0;      // v47
		g_bChampFlying[e] = false;      // v49: nadie vuela al empezar
		g_fChampFrozenAcc[e] = 0.0;     // v49
		g_iChampFrozenMT[e] = 0;        // v49
		g_iChampFlightMT[e] = 0;        // v49
		g_fChampFlightStart[e] = 0.0;   // v49
		g_iChampFlightKind[e] = 0;      // v49
	}
	if (g_hChampLaunchList != null)
		g_hChampLaunchList.Clear();   // nada volando al empezar el mapa
	if (g_hChampFlightList != null)
		g_hChampFlightList.Clear();   // v49: tampoco el vuelo manual
	if (g_hChampFlightTick != null)
	{
		KillTimer(g_hChampFlightTick);   // v49: se recrea al primer vuelo
		g_hChampFlightTick = null;
	}
	g_bChampZapSnd = PrecacheSound(SND_CHAMP_ZAP, true);
}

// ============================================================================
// v45 FUSION — MODULO CAMPEONES (parte A): utilidades + FX + control + BD/XP
// ============================================================================

int ChampIdOf(const char[] name)
{
    for (int i = 0; i < CHAMP_COUNT; i++)
        if (StrEqual(name, g_sChampNames[i])) return i;
    return 0;
}

// modelo del campeon activo segun nombre+skin guardados (mismo mapa que el
// panel original del companion)
void ChampModelFor(int client, char[] model, int maxlen)
{
    if (StrEqual(g_sPet_Name[client], "Luna"))
    {
        if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(model, maxlen, LUNA_DAWN_MODEL);
        else if (StrEqual(g_sPet_Skin[client], "Type III")) strcopy(model, maxlen, LUNA_SHADOW_MODEL);
        else strcopy(model, maxlen, LUNA_DEFAULT_MODEL);
    }
    else if (StrEqual(g_sPet_Name[client], "Raven"))
    {
        if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(model, maxlen, RAVEN_NOXUS_MODEL);
        else if (StrEqual(g_sPet_Skin[client], "Type III")) strcopy(model, maxlen, RAVEN_SNOWY_MODEL);
        else strcopy(model, maxlen, RAVEN_DEFAULT_MODEL);
    }
    else if (StrEqual(g_sPet_Name[client], "Snowy"))
    {
        if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(model, maxlen, SNOWY_EAGLE_MODEL);
        else if (StrEqual(g_sPet_Skin[client], "Type III")) strcopy(model, maxlen, SNOWY_HEXTECH_MODEL);
        else strcopy(model, maxlen, SNOWY_DEFAULT_MODEL);
    }
    else if (StrEqual(g_sPet_Name[client], "Spyro"))
    {
        if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(model, maxlen, SPYRO_HEAVEN_MODEL);
        else if (StrEqual(g_sPet_Skin[client], "Type III")) strcopy(model, maxlen, SPYRO_REINDEER_MODEL);
        else strcopy(model, maxlen, SPYRO_DEFAULT_MODEL);
    }
    else if (StrEqual(g_sPet_Name[client], "Ghosty"))
    {
        if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(model, maxlen, GHOSTY_JANITOR_MODEL);
        else if (StrEqual(g_sPet_Skin[client], "Type III")) strcopy(model, maxlen, GHOSTY_MOON_MODEL);
        else strcopy(model, maxlen, GHOSTY_DEFAULT_MODEL);
    }
    else if (StrEqual(g_sPet_Name[client], "Storm"))
    {
        if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(model, maxlen, STORM_DEMON_MODEL);
        else if (StrEqual(g_sPet_Skin[client], "Type III")) strcopy(model, maxlen, STORM_TIGER_MODEL);
        else strcopy(model, maxlen, STORM_DEFAULT_MODEL);
    }
    else if (StrEqual(g_sPet_Name[client], "Ember"))
    {
        if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(model, maxlen, EMBER_CHOOCHOO_MODEL);
        else if (StrEqual(g_sPet_Skin[client], "Type III")) strcopy(model, maxlen, EMBER_THUNDER_MODEL);
        else strcopy(model, maxlen, EMBER_DEFAULT_MODEL);
    }
    else   // Warwick
    {
        if (StrEqual(g_sPet_Skin[client], "Type II")) strcopy(model, maxlen, WARWICK_FIREFANG_MODEL);
        else if (StrEqual(g_sPet_Skin[client], "Type III")) strcopy(model, maxlen, WARWICK_BIGBAD_MODEL);
        else strcopy(model, maxlen, WARWICK_HUNTER_MODEL);
    }
}

void ChampColorOf(int champ, int out[4])
{
    out[0] = g_iChampColors[champ][0];
    out[1] = g_iChampColors[champ][1];
    out[2] = g_iChampColors[champ][2];
    out[3] = g_iChampColors[champ][3];
}

bool ChampIsActive(int client)
{
    return IsPetValid(client);
}

// ============================================================================
// DANO CON ATRIBUCION DE CAMPÉON (espejo del PetDamage de la nave)
// ============================================================================

void ChampDamage(int victim, int owner, float damage, int dmgtype)
{
    if (victim <= 0 || victim >= 2048 || !IsValidEntity(victim)) return;
    if (owner <= 0 || !IsValidClient(owner)) return;
    if (!IsEnemyAlive(victim)) return;

    // v49: ni los BASICOS ni las habilidades sin aturdimiento canonico
    // tropiezan a nadie: el club del engine se convierte en bala y el
    // tropiezo de las explosiones se cancela al instante. El stagger llega
    // SOLO por Champ_SetStagger (W, E contra pared, R al caer, supresiones
    // y miedos canonicos)
    if (dmgtype & DMG_CLUB) dmgtype = (dmgtype & ~DMG_CLUB) | DMG_BULLET;

    g_iChampHitOwner[victim] = owner;
    g_fChampHitTime[victim] = GetGameTime();
    SDKHooks_TakeDamage(victim, owner, owner, damage, dmgtype);

    if ((dmgtype & DMG_BLAST) && victim <= MaxClients
        && IsClientInGame(victim) && GetClientTeam(victim) == 3 && IsPlayerAlive(victim))
        L4D_CancelStagger(victim);   // v49: sin tropiezo de explosion
}

// dano como PORCENTAJE de la vida maxima de la victima (Poppy Q / Warwick P)
void ChampDamagePct(int victim, int owner, float pct, float minDmg, int dmgtype)
{
    if (victim <= 0 || victim >= 2048 || !IsValidEntity(victim)) return;
    if (!IsEnemyAlive(victim)) return;

    int maxHp = GetEntProp(victim, Prop_Data, "m_iMaxHealth");
    float dmg = float(maxHp) * pct;
    if (dmg < minDmg) dmg = minDmg;
    ChampDamage(victim, owner, dmg, dmgtype);
}

// ============================================================================
// LIBRERIA DE EFECTOS GRAFICOS (ChampFX): cada habilidad se VE
// ============================================================================
// Reusa los sprites laser del avion (g_iBeamSprite/g_iHaloSprite) y envia
// temp-ents a todos los jugadores. l4d2_champ_fx 0 los apaga para servers
// modestos.

void ChampFX_Beam(const float start[3], const float end[3], const int color[4], float width, float life)
{
    PetBeam(start, end, color, width, life);
}

// anillo que se EXPANDE desde el punto (impactos, novas)
void ChampFX_Ring(const float pos[3], float radius, const int color[4], float life)
{
    if (!g_bChampFX) return;
    float ringPos[3];
    ringPos[0] = pos[0];
    ringPos[1] = pos[1];
    ringPos[2] = pos[2] + 20.0;
    TE_SetupBeamRingPoint(ringPos, 10.0, radius, g_iBeamSprite, g_iHaloSprite, 0, 10, life, 8.0, 0.5, color, 400, 0);
    TE_SendToAll();
}

// marca de luz que se CONTRAE hacia el punto: telegrafo de explosion (Poppy Q)
void ChampFX_RingIn(const float pos[3], float radius, const int color[4])
{
    if (!g_bChampFX) return;
    float ringPos[3];
    ringPos[0] = pos[0];
    ringPos[1] = pos[1];
    ringPos[2] = pos[2] + 20.0;
    TE_SetupBeamRingPoint(ringPos, radius, 10.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.7, 10.0, 1.2, color, 400, 0);
    TE_SendToAll();
}

// v57: esquirlas de energia — abanico de rayitas construidas SOLO con
// TE_SetupBeamPoints y el sprite del anillo dorado (g_iBeamSprite, material
// garantizado en L4D2). Reemplazan a TE_SetupSparks/TE_SetupEnergySplash:
// esas temp-entities de HL2 las dibuja el cliente de L4D2 como LINEAS
// MORADAS de "textura faltante" — era el efecto morado de cada pulso de la
// W de Poppy. Con el sprite del anillo jamas puede salir sin textura.
void ChampFX_Shards(const float fx[3], const int color[4], int count, float life, float reach, float width)
{
    if (!g_bChampFX) return;
    float end[3];
    for (int i = 0; i < count; i++)
    {
        float ang = GetRandomFloat(0.0, 6.2832);
        float out = GetRandomFloat(reach * 0.35, reach);
        float lift = GetRandomFloat(reach * 0.8, reach * 1.6);
        end[0] = fx[0] + Cosine(ang) * out;
        end[1] = fx[1] + Sine(ang) * out;
        end[2] = fx[2] + lift;
        TE_SetupBeamPoints(fx, end, g_iBeamSprite, g_iHaloSprite, 0, 30, life, width, 0.8, 0, 0.0, color, 400);
        TE_SendToAll();
    }
}

// estallido completo: anillo + abanico de esquirlas de energia
void ChampFX_Burst(const float pos[3], const int color[4])
{
    if (!g_bChampFX) return;
    float fx[3];
    fx[0] = pos[0];
    fx[1] = pos[1];
    fx[2] = pos[2] + 30.0;
    TE_SetupBeamRingPoint(fx, 10.0, 160.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.45, 10.0, 0.5, color, 400, 0);
    TE_SendToAll();
    ChampFX_Shards(fx, color, 8, 0.32, 42.0, 2.4);
}

// columna vertical de luz (lanzamientos, rayos, llamaradas)
void ChampFX_Pillar(const float pos[3], const int color[4], float height)
{
    if (!g_bChampFX) return;
    float top[3];
    top[0] = pos[0];
    top[1] = pos[1];
    top[2] = pos[2] + 20.0 + height;
    float base[3];
    base[0] = pos[0];
    base[1] = pos[1];
    base[2] = pos[2] + 20.0;
    TE_SetupBeamPoints(base, top, g_iBeamSprite, g_iHaloSprite, 0, 100, 1.1, 9.0, 9.0, 0, 0.0, color, 400);
    TE_SendToAll();
}

// chispas de la guardia: esquirlas del color del campeon que saltan del
// punto (v57 — sin TE_SetupSparks: era la linea morada de la W de Poppy)
void ChampFX_Sparks(const float pos[3], const int color[4])
{
    if (!g_bChampFX) return;
    float fx[3];
    fx[0] = pos[0];
    fx[1] = pos[1];
    fx[2] = pos[2] + 30.0;
    ChampFX_Shards(fx, color, 6, 0.25, 30.0, 2.0);
}

// v48: particula REAL del juego (paleta del SuperTank): info_particle_system
// que arranca sola y SE AUTODESTRUYE — jamas queda dibujada para siempre
void ChampFX_Particle(const float pos[3], const char[] effect, float life)
{
    if (!g_bChampFX) return;
    if (GetEntityCount() > MAX_EDICTS_SAFE - 2) return;
    int fx = CreateEntityByName("info_particle_system");
    if (fx <= 0 || !IsValidEntity(fx)) return;
    DispatchKeyValue(fx, "effect_name", effect);
    DispatchSpawn(fx);
    TeleportEntity(fx, pos, NULL_VECTOR, NULL_VECTOR);
    ActivateEntity(fx);
    AcceptEntityInput(fx, "Start");
    char io[64];
    Format(io, sizeof(io), "OnUser1 !self:Kill::%.2f:-1", life + 1.0);
    SetVariantString(io);
    AcceptEntityInput(fx, "AddOutput");
    AcceptEntityInput(fx, "FireUser1");
}

// temblor de pantalla fisico (env_shake) alrededor de un punto
void ChampFX_Shake(const float pos[3], int amp, int radius, float dur)
{
    if (!g_bChampFX) return;
    int sh = CreateEntityByName("env_shake");
    if (sh <= 0 || !IsValidEntity(sh)) return;

    char buf[16];
    IntToString(amp, buf, sizeof(buf));
    DispatchKeyValue(sh, "amplitude", buf);
    IntToString(radius, buf, sizeof(buf));
    DispatchKeyValue(sh, "radius", buf);
    FloatToString(dur, buf, sizeof(buf));
    DispatchKeyValue(sh, "duration", buf);
    DispatchKeyValue(sh, "spawnflags", "0");
    DispatchSpawn(sh);
    TeleportEntity(sh, pos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(sh, "StartShake");
    CreateTimer(dur + 0.5, Timer_ChampKillShake, EntIndexToEntRef(sh), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_ChampKillShake(Handle timer, any data)
{
    int sh = EntRefToEntIndex(view_as<int>(data));
    if (sh > 0 && IsValidEntity(sh))
        AcceptEntityInput(sh, "Kill");
    return Plugin_Stop;
}

// estela luminosa que sigue a una entidad (embestidas)
void ChampFX_Trail(int ent, const int color[4], float life)
{
    if (!g_bChampFX || ent <= 0 || !IsValidEntity(ent)) return;
    TE_SetupBeamFollow(ent, g_iBeamSprite, g_iHaloSprite, life, 12.0, 8.0, 4, color);
    TE_SendToAll();
}

// glow temporal sobre una entidad (color BGR) con auto-apagado seguro
void ChampFX_Glow(int ent, int bgrColor, float dur)
{
    if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent)) return;
    SetEntProp(ent, Prop_Send, "m_iGlowType", 3);
    SetEntProp(ent, Prop_Send, "m_glowColorOverride", bgrColor);
    DataPack pack = new DataPack();
    pack.WriteCell(EntIndexToEntRef(ent));
    pack.WriteCell(bgrColor);
    CreateTimer(dur, Timer_ChampGlowOff, pack, TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
}

public Action Timer_ChampGlowOff(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int ent = EntRefToEntIndex(pack.ReadCell());
    int bgr = pack.ReadCell();
    if (ent > 0 && IsValidEntity(ent))
    {
        // solo apaga si NADIE marco otro color mientras tanto
        if (GetEntProp(ent, Prop_Send, "m_glowColorOverride") == bgr)
        {
            SetEntProp(ent, Prop_Send, "m_iGlowType", 0);
            SetEntProp(ent, Prop_Send, "m_glowColorOverride", 0);
        }
    }
    return Plugin_Stop;
}

// flash de pantalla para la duegna (feedback de ultimate)
void ChampFX_FadeToOwner(int client, int r, int g, int b)
{
    if (!g_bChampFX) return;
    if (client <= 0 || !IsClientInGame(client)) return;
    ScreenFade(client, r, g, b, 70, 400, 1);
}

// ============================================================================
// KNOCKBACK (utilidad de control)
// ============================================================================

void ChampKnockback(int ent, const float fromPos[3], float force)
{
    if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent)) return;
    float vPos[3], vDir[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
    MakeVectorFromPoints(fromPos, vPos, vDir);
    if (GetVectorLength(vDir) < 0.001) return;
    float vNorm[3];
    NormalizeVector(vDir, vNorm);
    float vVel[3];
    vVel[0] = vNorm[0] * force;
    vVel[1] = vNorm[1] * force;
    vVel[2] = vNorm[2] * force * 0.5 + 200.0;   // siempre un poco hacia arriba
    TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, vVel);
}

// ============================================================================
// ATURDIMIENTO REAL (stagger del motor) — el mismo sistema de los Sonic chars
// ============================================================================
// L4D_StaggerPlayer mete al infectado en el estado "stumble" de verdad (se
// tambalea, suelta lo que hacia). Con BOTS SI el motor a veces NO lo limpia
// solo (bug documentado): se programa L4D_CancelStagger como red de
// seguridad, igual que el SI_Stagger.inc del servidor.

void Champ_SetStagger(int victim, int sourceEnt, const float sourcePos[3], float dur)
{
    if (victim <= 0 || victim >= 2048 || !IsValidEntity(victim)) return;
    if (!IsEnemyAlive(victim)) return;

    if (victim <= MaxClients)
    {
        // infectado especial / tank: stagger REAL del motor
        if (!IsClientInGame(victim) || !IsPlayerAlive(victim)) return;
        float vecSource[3];
        vecSource[0] = sourcePos[0];
        vecSource[1] = sourcePos[1];
        vecSource[2] = sourcePos[2];
        L4D_StaggerPlayer(victim, sourceEnt, vecSource);

        // red de seguridad: a los ~dur s, cancel forzado (no-op si ya se levanto)
        float recover = dur * g_fChampStaggerMult;
        if (GetEntProp(victim, Prop_Send, "m_zombieClass") == 8) recover += 1.2;   // el tank se tambalea mas
        Champ_ScheduleStagCancel(victim, recover);
        ChampFX_Glow(victim, 0x0000FF, 0.5);   // flash rojo
    }
    else
    {
        // comun / witch: congelacion breve (no son jugadores: no hay stagger)
        Champ_Freeze(victim, dur);   // v48: hielo real unificado (estilo SuperTank)
    }
}

// v49: FROZEN con NOTHINK de verdad. Los comunes (y la witch) son NextBots
// como la witch del Witch_Flight: FL_FROZEN apaga el gate de su DoThink
// (la IA deja de re-escribir su posicion: se pueden LEVANTAR del suelo) y
// MOVETYPE_NONE los deja clavados. Mientras dura, el dano NO ENTRA: el
// filtro de abajo lo bloquea y lo acumula en el hielo. Al restaurar se
// devuelve el movetype ORIGINAL (la witch usa STEP, no WALK), el color y
// el flag de IA; si el dano frenado fue demasiado (>= su vida), muere.
public Action ChampFrozenDamageFilter(int victim, int &attacker, int &inflictor,
    float &damage, int &damagetype)
{
    if (victim <= 0 || victim >= 2048) return Plugin_Continue;
    if (!g_bChampFrozen[victim]) return Plugin_Continue;
    g_fChampFrozenAcc[victim] += damage;   // el hielo se lo queda
    return Plugin_Handled;
}

void Champ_Freeze(int victim, float dur)
{
    if (victim <= 0 || victim >= 2048 || !IsValidEntity(victim)) return;
    if (!IsEnemyAlive(victim)) return;
    if (g_bChampFrozen[victim]) return;   // ya esta congelado
    g_bChampFrozen[victim] = true;
    g_fChampFrozenAcc[victim] = 0.0;
    g_iChampFrozenMT[victim] = view_as<int>(GetEntityMoveType(victim));

    float vVel[3] = {0.0, 0.0, 0.0};
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vVel);
    SetEntityMoveType(victim, MOVETYPE_NONE);
    SetEntityFlags(victim, GetEntityFlags(victim) | FL_FROZEN);

    // look de hielo del SuperTank: tinte cian (0,204,204) + glow cian
    SetEntityRenderColor(victim, 0, 204, 204, 255);
    ChampFX_Glow(victim, 0xCCCC00, dur);   // cian en BGR

    // hielo REAL: dos chorros de vapor helado sobre la victima
    float pos[3];
    GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
    pos[2] += 50.0;
    ChampFX_Particle(pos, "steam_manhole", dur);
    ChampFX_Particle(pos, "steam_manhole_b", dur);
    EmitSoundToAll(SND_GLASS, victim, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.8, 120);

    // v49: mientras este congelado el dano NO entra (filtro SDKHooks)
    SDKHook(victim, SDKHook_OnTakeDamage, ChampFrozenDamageFilter);

    DataPack pack = new DataPack();
    pack.WriteCell(EntIndexToEntRef(victim));
    CreateTimer(dur, Timer_ChampUnfreeze, pack,
                TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
}

// v49: restauracion COMPLETA: flag de IA + movetype ORIGINAL + color, y
// el veredicto del hielo: si freno mas dano que la vida que le quedaba,
// el infectado muere al descongelarse.
public Action Timer_ChampUnfreeze(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int ent = EntRefToEntIndex(pack.ReadCell());
    if (ent > 0 && ent < 2048 && IsValidEntity(ent) && g_bChampFrozen[ent] && !g_bChampFlying[ent])
    {
        g_bChampFrozen[ent] = false;
        SDKUnhook(ent, SDKHook_OnTakeDamage, ChampFrozenDamageFilter);
        SetEntityFlags(ent, GetEntityFlags(ent) & ~FL_FROZEN);
        SetEntityMoveType(ent, view_as<MoveType>(g_iChampFrozenMT[ent]));
        SetEntityRenderColor(ent, 255, 255, 255, 255);

        if (IsEnemyAlive(ent))
        {
            float acc = g_fChampFrozenAcc[ent];
            g_fChampFrozenAcc[ent] = 0.0;
            if (acc > 0.0)
            {
                int hp = GetEntProp(ent, Prop_Data, "m_iHealth");
                if (view_as<int>(acc) >= hp)
                {
                    // el hielo freno demasiado dano: no hay descongelacion
                    if (ent <= MaxClients) ForcePlayerSuicide(ent);
                    else AcceptEntityInput(ent, "Kill");
                }
            }
        }
        else g_fChampFrozenAcc[ent] = 0.0;
    }
    return Plugin_Stop;
}

// --- red de seguridad del stagger (patron SI_Stagger.inc) --------------------
void Champ_ScheduleStagCancel(int victim, float delay)
{
    if (victim <= 0 || victim > MaxClients) return;
    if (g_hChampStagCancel[victim] != null)
    {
        KillTimer(g_hChampStagCancel[victim]);
        g_hChampStagCancel[victim] = null;
    }
    DataPack pack = new DataPack();
    pack.WriteCell(victim);
    pack.WriteCell(GetClientUserId(victim));
    g_hChampStagCancel[victim] = CreateTimer(delay, Timer_ChampStagCancel, pack,
                                             TIMER_DATA_HNDL_CLOSE);   // SIN NO_MAPCHANGE a proposito: el handle debe seguir siendo valido para el reset del mapa (patron SI_Stagger.inc)
}

public Action Timer_ChampStagCancel(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int slot = pack.ReadCell();
    int userid = pack.ReadCell();
    if (slot > 0 && slot <= MaxClients && g_hChampStagCancel[slot] == timer)
        g_hChampStagCancel[slot] = null;

    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
        L4D_CancelStagger(client);
    return Plugin_Stop;
}

// ============================================================================
// BLOQUEO DE SALTOS (Poppy W) — patron del block de Knuckles
// ============================================================================
// Detecta hunter (3) / jockey (5) / charger (6) volando o cargando hacia la
// duegna, o ya enganchado a ella. La liberacion usa m_pounceAttacker = -1
// (exactly el truco del Knuckles del servidor).

int Champ_FindIncomingLeap(int client)
{
    float ownerPos[3];
    GetClientAbsOrigin(client, ownerPos);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 3) continue;
        int zclass = GetEntProp(i, Prop_Send, "m_zombieClass");
        if (zclass != 3 && zclass != 5 && zclass != 6) continue;   // hunter/jockey/charger

        float vPos[3], vVel[3];
        GetClientAbsOrigin(i, vPos);
        if (GetVectorDistance(ownerPos, vPos) > 650.0) continue;

        // 1. ya la tiene agarrada: prioridad maxima
        if (Champ_LeapVictimIs(i, zclass, client)) return i;

        // 2. cargando oficialmente (charger)
        if (HasEntProp(i, Prop_Send, "m_isCharging")
            && GetEntProp(i, Prop_Send, "m_isCharging") != 0) return i;

        // 3. hunter agachado a punto de saltar
        if (HasEntProp(i, Prop_Send, "m_isAttemptingToPounce")
            && GetEntProp(i, Prop_Send, "m_isAttemptingToPounce") != 0) return i;

        // 4. en pleno vuelo hacia ella (velocidad horizontal alta y apuntando)
        GetEntPropVector(i, Prop_Data, "m_vecVelocity", vVel);
        float spd = SquareRoot(vVel[0] * vVel[0] + vVel[1] * vVel[1]);
        if (spd < 280.0) continue;
        float toOwner[3];
        MakeVectorFromPoints(vPos, ownerPos, toOwner);
        NormalizeVector(toOwner, toOwner);
        float vNorm[3];
        vNorm[0] = vVel[0]; vNorm[1] = vVel[1]; vNorm[2] = 0.0;
        if (GetVectorLength(vNorm) < 0.001) continue;
        NormalizeVector(vNorm, vNorm);
        if (GetVectorDotProduct(vNorm, toOwner) > 0.75) return i;
    }
    return -1;
}

bool Champ_LeapVictimIs(int si, int zclass, int victim)
{
    char prop[24];
    if (zclass == 3) strcopy(prop, sizeof(prop), "m_pounceVictim");
    else if (zclass == 5) strcopy(prop, sizeof(prop), "m_jockeyVictim");
    else strcopy(prop, sizeof(prop), "m_pummelVictim");

    if (!HasEntProp(si, Prop_Send, prop)) return false;
    return GetEntPropEnt(si, Prop_Send, prop) == victim;
}

// v47: liberacion DEFINITIVA de la duegna (arregla el parpadeo/crash del
// v46). Antes solo se limpiaba la prop de la VICTIMA: el canal del atacante
// seguia vivo y el motor la re-enganchaba al instante — bucle limpiar/poner
// hasta que el Left crashea. Ahora (patron Knuckles):
//   1. STAGGER del atacante — el motor suelta el canal de verdad
//   2. recarga forzada de SU habilidad — no puede re-engancharse (5 s)
//   3. limpieza de AMBOS lados (victima y atacante)
//   4. castigo + graficos UNA vez, con cooldown de 1 s por victima
bool ChampBlock_Release(int client)
{
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) return false;

    float now = GetGameTime();
    if (now < g_fChampReleaseAt[client]) return false;   // v47: anti-bucle
    g_fChampReleaseAt[client] = now + 1.0;

    int pet = EntRefToEntIndex(g_iPet_Entity[client]);
    float petPos[3];
    if (pet > 0 && pet < 2048 && IsValidEntity(pet))
        GetEntPropVector(pet, Prop_Data, "m_vecOrigin", petPos);
    else
        GetClientAbsOrigin(client, petPos);

    static const char sGrabProps[][] = {
        "m_pounceAttacker", "m_jockeyAttacker", "m_tongueOwner",
        "m_pummelAttacker", "m_carryAttacker"
    };
    static const char sAtkProps[][] = {
        "m_pounceVictim", "m_jockeyVictim", "m_tongueVictim",
        "m_pummelVictim", "m_carryVictim"
    };

    int col[4];
    ChampColorOf(1, col);
    int level = g_iChampLevel[client][1];
    bool bAny = false;

    for (int k = 0; k < sizeof(sGrabProps); k++)
    {
        if (!HasEntProp(client, Prop_Send, sGrabProps[k])) continue;
        int attacker = GetEntPropEnt(client, Prop_Send, sGrabProps[k]);
        if (attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker)) continue;

        // 1. stagger del atacante: suelta el canal de verdad
        Champ_SetStagger(attacker, pet, petPos, 1.8);
        // 2. su habilidad entra en recarga forzada: no puede re-enganchar
        ChampDisableAbility(attacker, 5.0);
        // 3. limpieza de AMBOS lados
        SetEntPropEnt(client, Prop_Send, sGrabProps[k], -1);
        if (HasEntProp(attacker, Prop_Send, sAtkProps[k]))
            SetEntPropEnt(attacker, Prop_Send, sAtkProps[k], -1);
        // 4. castigo + graficos una sola vez
        ChampDamage(attacker, client, 15.0 + 2.0 * float(level), DMG_CLUB);
        float aPos[3];
        GetClientAbsOrigin(attacker, aPos);
        aPos[2] += 40.0;
        ChampFX_Burst(aPos, col);
        ChampFX_Ring(aPos, 90.0, col, 0.6);
        EmitSoundToClient(client, SND_GLASS);
        bAny = true;
    }
    return bAny;
}

// v47: recarga forzada de la habilidad de un SI (patron
// Knux_DisableInfectedAbility del plugin de Knuckles): la entidad de su
// poder recibe un timestamp futuro y el infectado NO puede volver a usarlo.
void ChampDisableAbility(int si, float duration)
{
    if (si <= 0 || si > MaxClients || !IsClientInGame(si)) return;
    int ability = GetEntPropEnt(si, Prop_Send, "m_customAbility");
    if (ability <= 0 || !IsValidEntity(ability)) return;
    SetEntPropFloat(ability, Prop_Send, "m_timestamp", GetGameTime() + duration);
}

// ============================================================================
// v47: BLOQUEO PREVENTIVO DE AGARRES (forwards de left4dhooks)
// Con la ventana de la W activa, el agarre NUNCA LLEGA A EMPEZAR: no hay
// estado corrupto que limpiar — imposible el parpadeo del v46.
// ============================================================================

bool Champ_WActive(int client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client)
        && g_iChampSel[client] == 1
        && GetGameTime() < g_fChampRavenWUntil[client];
}

// castigo al atacante que intento agarrar a la duegna protegida
void Champ_RavenWGuard(int victim, int attacker)
{
    if (attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker)) return;

    float now = GetGameTime();
    if (now < g_fChampWGuardAt[attacker]) return;   // ya fue castigado hace poco
    g_fChampWGuardAt[attacker] = now + 1.0;

    int pet = EntRefToEntIndex(g_iPet_Entity[victim]);
    if (pet <= 0 || !IsValidEntity(pet)) pet = victim;
    float petPos[3], petHead[3];
    if (pet != victim) GetEntPropVector(pet, Prop_Data, "m_vecOrigin", petPos);
    else GetClientAbsOrigin(victim, petPos);
    petHead[0] = petPos[0]; petHead[1] = petPos[1]; petHead[2] = petPos[2] + 40.0;

    // stop en seco + stagger + habilidad en recarga forzada
    float zero[3] = {0.0, 0.0, 0.0};
    TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, zero);
    Champ_SetStagger(attacker, pet, petPos, 1.8);
    ChampDisableAbility(attacker, 5.0);

    int level = g_iChampLevel[victim][1];
    ChampDamage(attacker, victim, 15.0 + 2.0 * float(level), DMG_CLUB);

    int col[4];
    ChampColorOf(1, col);
    float aPos[3];
    GetClientAbsOrigin(attacker, aPos);
    aPos[2] += 40.0;
    ChampFX_Beam(petHead, aPos, col, 3.2, 0.3);
    ChampFX_Ring(aPos, 90.0, col, 0.6);
    ChampFX_Burst(aPos, col);
    EmitSoundToAll(SND_GLASS, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.9, 110);

    char siName[16];
    PetSIName(attacker, siName, sizeof(siName));
    CPrintToChat(victim, "{green}[%s]{default} {olive}PRESENCIA INQUEBRANTABLE{default}: {olive}%s{default} rebotado en el escudo.",
        g_sChampNames[1], siName);
}

public Action L4D_OnGrabWithTongue(int victim, int attacker)
{
    if (Champ_WActive(victim))
    {
        Champ_RavenWGuard(victim, attacker);
        return Plugin_Handled;   // v47: la lengua NUNCA engancha
    }
    return Plugin_Continue;
}

public Action L4D_OnPouncedOnSurvivor(int victim, int attacker)
{
    if (Champ_WActive(victim))
    {
        Champ_RavenWGuard(victim, attacker);
        return Plugin_Handled;   // v47: el pounce rebota
    }
    return Plugin_Continue;
}

public Action L4D2_OnJockeyRide(int victim, int attacker)
{
    if (Champ_WActive(victim))
    {
        Champ_RavenWGuard(victim, attacker);
        return Plugin_Handled;   // v47: el jockey no monta
    }
    return Plugin_Continue;
}

public Action L4D2_OnStartCarryingVictim(int victim, int attacker)
{
    if (Champ_WActive(victim))
    {
        Champ_RavenWGuard(victim, attacker);
        return Plugin_Handled;   // v47: la carga del charger no empieza
    }
    return Plugin_Continue;
}

public Action L4D2_OnSlammedSurvivor(int victim, int attacker, bool &bWallSlam, bool &bDeadlyCharge)
{
    if (Champ_WActive(victim))
    {
        bWallSlam = false;
        bDeadlyCharge = false;
        Champ_RavenWGuard(victim, attacker);
        return Plugin_Handled;   // v47: ni el golpe final del charger entra
    }
    return Plugin_Continue;
}

// ============================================================================
// v49: VUELO MANUAL (patron Witch_Flight de Amy con la witch): NOTHINK
// (FL_FROZEN apaga el NextBot de comunes/witch y congela a los especiales)
// + MOVETYPE_NONE + integracion propia a 33 Hz — la fisica del motor nunca
// entra en juego y la friccion del suelo da igual. Mientras vuelan, el
// dano NO ENTRA (frozen). Al ATERRIZAR: restauracion, 2o golpe y stagger
// (la R canonicamente aturde y levanta). En el empuje de la E, la PARED
// aplica el stagger.
// ============================================================================

void Champ_FlightLaunch(int victim, int owner, const float vel[3], float landDmg, int kind, float maxAir)
{
    if (victim <= 0 || victim >= 2048 || !IsValidEntity(victim)) return;
    if (!IsEnemyAlive(victim)) return;
    if (g_bChampFlying[victim])
    {
        // re-golpe en pleno vuelo: solo refresca el impulso
        g_vChampFlightVel[victim][0] = vel[0];
        g_vChampFlightVel[victim][1] = vel[1];
        g_vChampFlightVel[victim][2] = vel[2];
        g_fChampFlightDmg[victim] = landDmg;
        g_iChampFlightBy[victim] = owner;
        return;
    }
    // congelado por otro sistema (no volando): lo dejamos en su hielo
    if (g_bChampFrozen[victim]) return;

    g_bChampFlying[victim] = true;
    g_iChampFlightMT[victim] = view_as<int>(GetEntityMoveType(victim));
    g_iChampFlightKind[victim] = kind;
    g_iChampFlightBy[victim] = owner;
    g_fChampFlightDmg[victim] = landDmg;
    g_fChampFlightMaxAir[victim] = maxAir;
    g_fChampFlightStart[victim] = GetGameTime();
    g_fChampFlightLast[victim] = GetGameTime();

    // v60: punto de lanzamiento (para la distancia recorrida al chocar) y
    // nivel del campeon (para el umbral de EJECUCION del Veredicto)
    float startPos[3];
    GetEntPropVector(victim, Prop_Send, "m_vecOrigin", startPos);
    g_vChampFlightFrom[victim][0] = startPos[0];
    g_vChampFlightFrom[victim][1] = startPos[1];
    g_vChampFlightFrom[victim][2] = startPos[2];
    g_iChampFlightLvl[victim] = (owner > 0 && owner <= MaxClients)
        ? g_iChampLevel[owner][g_iChampSel[owner]] : 1;

    g_vChampFlightVel[victim][0] = vel[0];
    g_vChampFlightVel[victim][1] = vel[1];
    g_vChampFlightVel[victim][2] = vel[2];

    // el hielo del vuelo: IA apagada + dano negado mientras vuela
    g_bChampFrozen[victim] = true;
    g_fChampFrozenAcc[victim] = 0.0;
    SDKHook(victim, SDKHook_OnTakeDamage, ChampFrozenDamageFilter);
    SetEntityFlags(victim, GetEntityFlags(victim) | FL_FROZEN);
    SetEntityMoveType(victim, MOVETYPE_NONE);
    SetEntityRenderColor(victim, 0, 204, 204, 255);
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vel);

    if (g_hChampFlightList == null) g_hChampFlightList = new ArrayList();
    g_hChampFlightList.Push(EntIndexToEntRef(victim));

    // despegue con el color del campeon
    float pos[3];
    GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
    int col[4];
    int sel = (owner > 0 && owner <= MaxClients) ? g_iChampSel[owner] : 1;
    ChampColorOf(sel, col);
    ChampFX_Burst(pos, col);

    if (g_hChampFlightTick == null)
        g_hChampFlightTick = CreateTimer(0.03, Timer_ChampFlightTick, _, TIMER_REPEAT);
}

// restaura TODO lo que el vuelo congelo (flag de IA + movetype ORIGINAL +
// color + niega-dano fuera)
void Champ_FlightRestore(int ent, bool keepVel)
{
    if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent)) return;
    if (!g_bChampFlying[ent]) return;
    g_bChampFlying[ent] = false;

    float vel[3];
    if (keepVel)
    {
        vel[0] = g_vChampFlightVel[ent][0];
        vel[1] = g_vChampFlightVel[ent][1];
        vel[2] = g_vChampFlightVel[ent][2];
    }
    else { vel[0] = 0.0; vel[1] = 0.0; vel[2] = 0.0; }

    g_bChampFrozen[ent] = false;
    g_fChampFrozenAcc[ent] = 0.0;
    SDKUnhook(ent, SDKHook_OnTakeDamage, ChampFrozenDamageFilter);
    SetEntityFlags(ent, GetEntityFlags(ent) & ~FL_FROZEN);
    SetEntityMoveType(ent, view_as<MoveType>(g_iChampFlightMT[ent]));
    SetEntityRenderColor(ent, 255, 255, 255, 255);
    TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, vel);
}

// aterrizaje del VEREDICTO: se restauran ANTES del golpe (el hielo ya no
// niega el dano), reciben el 2o impacto y quedan STAGGER de verdad
void Champ_FlightLand(int ent)
{
    int owner = g_iChampFlightBy[ent];
    float landDmg = g_fChampFlightDmg[ent];
    float pos[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);

    Champ_FlightRestore(ent, false);

    int col[4];
    int sel = (owner > 0 && IsValidClient(owner)) ? g_iChampSel[owner] : 1;
    ChampColorOf(sel, col);
    ChampFX_Burst(pos, col);
    ChampFX_Particle(pos, "tank_rock_throw_impact", 1.0);
    ChampFX_Shake(pos, 10, 350, 0.6);
    // v27: SFX del impacto final con anti-spam por duena (hordas
    // aterrizan juntas y el sonido no debe apilarse)
    if (owner > 0 && IsValidClient(owner))
    {
        float nowL = GetGameTime();
        if (nowL > g_fChampRavenSndAt[owner] + 0.4)
        {
            g_fChampRavenSndAt[owner] = nowL;
            PoppyEmitLoud(POP_R3, ent, SND_MISSILE2, SNDLEVEL_ROCKET, SNDCHAN_WEAPON, SNDCHAN_STATIC);   // v36: impacto final — doble canal 180 dB
        }
    }
    else
        PoppyEmitLoud(POP_R3, ent, SND_MISSILE2, SNDLEVEL_ROCKET, SNDCHAN_WEAPON, SNDCHAN_STATIC);   // v36: impacto final — doble canal 180 dB

    if (!IsEnemyAlive(ent)) return;
    if (owner > 0 && IsValidClient(owner))
    {
        if (landDmg > 0.0)
            ChampDamage(ent, owner, landDmg, DMG_CLUB);
        // la R canonicamente ATURDE al caer
        Champ_SetStagger(ent, owner, pos, 1.5);
    }
}

// choque contra la pared en el EMPUJE de la E: STAGGER (no frozen, v49)
void Champ_FlightWall(int ent)
{
    int owner = g_iChampFlightBy[ent];
    float bonus = g_fChampFlightDmg[ent];
    float pos[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);

    Champ_FlightRestore(ent, false);

    // v60: el estrellon dorado — el efecto de explosion que ya tenia, mas
    // grande y garantizado (particula del charger + polvo + esquirlas +
    // temblor): ahora SI se ve siempre
    int colW[4];
    int selW = (owner > 0 && IsValidClient(owner)) ? g_iChampSel[owner] : 1;
    ChampColorOf(selW, colW);
    ChampFX_Particle(pos, "charger_wall_impact", 1.2);
    ChampFX_Particle(pos, "tank_rock_throw_impact", 1.0);
    ChampFX_Burst(pos, colW);
    ChampFX_Shards(pos, colW, 10, 0.4, 60.0, 3.0);
    ChampFX_Shake(pos, 12, 400, 0.6);
    PoppyBoneCrack(ent);   // v77: huesos rotos de Amy (mobius) — el sonido pedido (antes el nativo del tank)


    if (!IsEnemyAlive(ent)) return;
    if (owner > 0 && IsValidClient(owner))
    {
        if (bonus > 0.0)
            ChampDamage(ent, owner, bonus, DMG_CLUB);
        // solo el choque contra la pared aturde (la E es un empuje)
        Champ_SetStagger(ent, owner, pos, 2.0);
        // v54: voz del estrellon (solo si el vuelo lo lanzo la E de Poppy)
        if (g_iChampSel[owner] == 1)
        {
            int petV = EntRefToEntIndex(g_iPet_Entity[owner]);
            Poppy_Voice(petV, POPPY_VE);
        }
    }
}

// v60: choque contra la pared del VEREDICTO (la R): el FINISH. Los
// comunes mueren de una. Especiales/witch/tank reciben dano adicional =
// distancia recorrida + el % de vida que les falte (tope 30%) y, si quedan
// por debajo del umbral de EJECUCION (5% de la vida max +0.5% por nivel),
// mueren alli mismo. Mismo paquete visual del estrellon de la E, mas grande.
void Champ_FlightWallVerdict(int ent)
{
    int owner = g_iChampFlightBy[ent];
    int level = g_iChampFlightLvl[ent];
    if (level < 1) level = 1;
    float pos[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);

    // distancia VOLADA desde el lanzamiento hasta la pared (tope 1500 u)
    float traveled = GetVectorDistance(g_vChampFlightFrom[ent], pos);
    if (traveled < 0.0) traveled = 0.0;
    if (traveled > 1500.0) traveled = 1500.0;

    bool bCommon = false;
    if (ent > MaxClients)
    {
        char cls[16];
        GetEntityClassname(ent, cls, sizeof(cls));
        if (StrEqual(cls, "infected", false)) bCommon = true;
    }

    // se restaura ANTES de golpear (el hielo del vuelo niega el dano)
    float landDmg = g_fChampFlightDmg[ent];
    Champ_FlightRestore(ent, false);

    int col[4];
    int sel = (owner > 0 && IsValidClient(owner)) ? g_iChampSel[owner] : 1;
    ChampColorOf(sel, col);

    // el estrellon dorado en grande
    ChampFX_Particle(pos, "charger_wall_impact", 1.4);
    ChampFX_Particle(pos, "tank_rock_throw_impact", 1.2);
    ChampFX_Burst(pos, col);
    ChampFX_Shards(pos, col, 12, 0.5, 80.0, 3.2);
    ChampFX_Shake(pos, 14, 450, 0.8);
    // v77: HUESOS ROTOS de Amy (mobius) en el estrellon contra la pared —
    // el sonido que pidio la duena (antes era el poppy_r3 del impacto)
    if (owner > 0 && IsValidClient(owner))
    {
        float sndNow = GetGameTime();
        if (sndNow > g_fChampRavenSndAt[owner] + 0.4)
        {
            g_fChampRavenSndAt[owner] = sndNow;
            PoppyBoneCrack(ent);
        }
    }
    else
        PoppyBoneCrack(ent);

    if (!IsEnemyAlive(ent)) return;
    if (owner <= 0 || !IsValidClient(owner)) return;

    // COMUN: muere de una contra la pared
    if (bCommon)
    {
        ChampDamage(ent, owner, 99999.0, DMG_CLUB);
        return;
    }

    // ESPECIAL / WITCH / TANK: golpe de caida + dano adicional
    int maxHp = GetEntProp(ent, Prop_Data, "m_iMaxHealth");
    int hp = (ent <= MaxClients) ? GetClientHealth(ent)
        : GetEntProp(ent, Prop_Data, "m_iHealth");
    if (maxHp <= 0) maxHp = hp;
    if (maxHp <= 0) return;

    if (landDmg > 0.0)
        ChampDamage(ent, owner, landDmg, DMG_CLUB);

    if (IsEnemyAlive(ent))
    {
        // v60: dano adicional = distancia recorrida (x0.1) + el % de la
        // vida que le falte (tope 30% de la vida maxima — como se pidio)
        hp = (ent <= MaxClients) ? GetClientHealth(ent)
            : GetEntProp(ent, Prop_Data, "m_iHealth");
        float missFrac = 1.0 - float(hp) / float(maxHp);
        if (missFrac < 0.0) missFrac = 0.0;
        if (missFrac > 0.30) missFrac = 0.30;   // el tope del pedido
        float bonus = traveled * 0.1 + float(maxHp) * missFrac;
        if (bonus > 0.0)
            ChampDamage(ent, owner, bonus, DMG_CLUB);
    }

    // FINISH: ejecucion bajo 5% de la vida max (+0.5% por nivel)
    if (IsEnemyAlive(ent))
    {
        hp = (ent <= MaxClients) ? GetClientHealth(ent)
            : GetEntProp(ent, Prop_Data, "m_iHealth");
        float execPct = (5.0 + 0.5 * float(level)) / 100.0;
        if (float(hp) <= float(maxHp) * execPct)
        {
            float ePos[3];
            ePos[0] = pos[0]; ePos[1] = pos[1]; ePos[2] = pos[2] + 20.0;
            ChampFX_Pillar(ePos, col, 400.0);
            ChampFX_Ring(ePos, 220.0, col, 0.7);
            ChampDamage(ent, owner, 99999.0, DMG_CLUB);
            if (IsValidClient(owner))
                CPrintToChat(owner, "{green}[%s]{default} {olive}VEREDICTO{default}: ¡{olive}EJECUTADO{default} contra la pared (%d/%d de vida)!",
                    g_sChampNames[1], hp, maxHp);
        }
        else
        {
            Champ_SetStagger(ent, owner, pos, 2.0);
            // la voz del estrellon suena tambien con el Veredicto
            if (g_iChampSel[owner] == 1)
            {
                int petV = EntRefToEntIndex(g_iPet_Entity[owner]);
                Poppy_Voice(petV, POPPY_VE);
            }
        }
    }
}

// tick de simulacion a 33 Hz (se apaga solo cuando nadie vuela)
public Action Timer_ChampFlightTick(Handle timer)
{
    if (g_hChampFlightList == null || g_hChampFlightList.Length == 0)
    {
        g_hChampFlightTick = null;
        return Plugin_Stop;
    }

    float now = GetGameTime();
    int n = g_hChampFlightList.Length;
    for (int i = n - 1; i >= 0; i--)
    {
        int ent = EntRefToEntIndex(g_hChampFlightList.Get(i));
        if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)
            || !g_bChampFlying[ent])
        {
            if (ent > 0 && ent < 2048) Champ_FlightRestore(ent, false);
            g_hChampFlightList.Erase(i);
            continue;
        }

        // dt real protegido contra lag spikes
        float dt = now - g_fChampFlightLast[ent];
        if (dt <= 0.0) dt = 0.03;
        if (dt > 0.25) dt = 0.25;
        g_fChampFlightLast[ent] = now;

        // re-afirmar la suspension por si algo externo la limpio
        if (GetEntityMoveType(ent) != MOVETYPE_NONE) SetEntityMoveType(ent, MOVETYPE_NONE);
        if ((GetEntityFlags(ent) & FL_FROZEN) == 0)
            SetEntityFlags(ent, GetEntityFlags(ent) | FL_FROZEN);

        // gravedad manual (NONE no integra fisica)
        float vel[3];
        vel[0] = g_vChampFlightVel[ent][0];
        vel[1] = g_vChampFlightVel[ent][1];
        vel[2] = g_vChampFlightVel[ent][2] - 800.0 * dt;
        if (vel[2] < -1600.0) vel[2] = -1600.0;

        float origin[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", origin);

        float move[3];
        move[0] = vel[0] * dt;
        move[1] = vel[1] * dt;
        move[2] = vel[2] * dt;

        // extremo del rayo con margen anti-tunel (solo alarga el trace)
        float traceEnd[3];
        traceEnd[0] = move[0];
        traceEnd[1] = move[1];
        traceEnd[2] = move[2];
        float len = GetVectorLength(move);
        if (len > 1.0)
        {
            float pad[3];
            pad[0] = move[0]; pad[1] = move[1]; pad[2] = move[2];
            NormalizeVector(pad, pad);
            ScaleVector(pad, 12.0);   // v60: margen grueso — las paredes se detectan de verdad
            AddVectors(traceEnd, pad, traceEnd);
        }
        AddVectors(origin, traceEnd, traceEnd);

        // colision SOLO contra el mundo (nadie frena el vuelo)
        Handle trace = TR_TraceRayFilterEx(origin, traceEnd, MASK_SOLID,
                                           RayType_EndPoint, ChampFlightWorldOnly, 0);
        if (TR_DidHit(trace))
        {
            float hitPos[3], normal[3];
            TR_GetEndPosition(hitPos, trace);
            TR_GetPlaneNormal(trace, normal);

            if (normal[2] >= 0.65)
            {
                // SUELO: aterrizar de pie y resolver
                float land[3];
                land[0] = hitPos[0];
                land[1] = hitPos[1];
                land[2] = hitPos[2] + 32.0;
                TeleportEntity(ent, land, NULL_VECTOR, NULL_VECTOR);
                delete trace;
                if (g_iChampFlightKind[ent] == CHAMP_FLIGHT_VERDICT) Champ_FlightLand(ent);
                else Champ_FlightRestore(ent, false);   // el empuje aterriza y ya
                g_hChampFlightList.Erase(i);
                continue;
            }

            if (g_iChampFlightKind[ent] == CHAMP_FLIGHT_PUSH)
            {
                // E de Poppy: se estrella contra la PARED -> stagger
                delete trace;
                Champ_FlightWall(ent);
                g_hChampFlightList.Erase(i);
                continue;
            }

            // v60: el VEREDICTO ya no se desliza por la pared: CHOQUE =
            // FINISH de la R (comunes muertos; especiales/witch/tank con
            // dano adicional por distancia + vida faltante y EJECUCION)
            delete trace;
            Champ_FlightWallVerdict(ent);
            g_hChampFlightList.Erase(i);
            continue;
        }
        else
        {
            // vuelo libre: avanzar
            float newOrigin[3];
            AddVectors(origin, move, newOrigin);
            TeleportEntity(ent, newOrigin, NULL_VECTOR, NULL_VECTOR);
        }
        delete trace;

        g_vChampFlightVel[ent][0] = vel[0];
        g_vChampFlightVel[ent][1] = vel[1];
        g_vChampFlightVel[ent][2] = vel[2];
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, vel);

        // nunca mas de maxAir segundos en el aire
        if (now - g_fChampFlightStart[ent] > g_fChampFlightMaxAir[ent])
        {
            if (g_iChampFlightKind[ent] == CHAMP_FLIGHT_VERDICT) Champ_FlightLand(ent);
            else Champ_FlightRestore(ent, false);
            g_hChampFlightList.Erase(i);
        }
    }

    if (g_hChampFlightList.Length == 0)
    {
        g_hChampFlightTick = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// el rayo solo colisiona con el MUNDO (ignora toda entidad)
public bool ChampFlightWorldOnly(int entity, int contentsMask)
{
    return false;
}

// ============================================================================
// LANZAMIENTOS AL AIRE (Ornn R): vuelan y al ATERRIZAR -> stagger
// ============================================================================

void Champ_Launch(int victim, int owner, const float fromPos[3], float force, float dmgOnLand)
{
    if (victim <= 0 || victim >= 2048 || !IsValidEntity(victim)) return;
    if (!IsEnemyAlive(victim)) return;
    if (g_fChampLaunchedAt[victim] > 0.0) return;   // ya esta en el aire

    float vPos[3], vDir[3];
    GetEntPropVector(victim, Prop_Send, "m_vecOrigin", vPos);
    MakeVectorFromPoints(fromPos, vPos, vDir);
    vDir[2] = 0.0;
    if (GetVectorLength(vDir) < 0.001) { vDir[0] = 0.0; vDir[1] = 1.0; }
    NormalizeVector(vDir, vDir);

    float vVel[3];
    vVel[0] = vDir[0] * 160.0;
    vVel[1] = vDir[1] * 160.0;
    vVel[2] = force;
    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vVel);

    g_fChampLaunchedAt[victim] = GetGameTime();
    g_iChampLaunchedBy[victim] = owner;
    g_fChampLaunchDmg[victim] = dmgOnLand;

    if (g_hChampLaunchList == null) g_hChampLaunchList = new ArrayList();
    g_hChampLaunchList.Push(EntIndexToEntRef(victim));

    // pilar de luz donde despega
    int sel = g_iChampSel[owner];
    int col[4];
    ChampColorOf(sel, col);
    float pos[3];
    pos[0] = vPos[0];
    pos[1] = vPos[1];
    pos[2] = vPos[2];
    ChampFX_Pillar(pos, col, 240.0);
    ChampFX_Glow(victim, 0x0000FF, 1.5);
}

// vigilancia global de victimas volando (0.1 s, solo trabaja si hay alguien)
public Action Timer_ChampLaunchTick(Handle timer)
{
    // v63 (v28): corazon de La Guardiana — regen/HUD/senuo (0.1 s)
    PoppyDecoy_Tick(GetGameTime());
    if (g_hChampLaunchList == null) return Plugin_Continue;
    int n = g_hChampLaunchList.Length;
    if (n == 0) return Plugin_Continue;

    float now = GetGameTime();
    for (int i = n - 1; i >= 0; i--)
    {
        int ent = EntRefToEntIndex(g_hChampLaunchList.Get(i));
        bool done = false;

        if (ent <= 0 || !IsValidEntity(ent) || !IsEnemyAlive(ent))
            done = true;   // murieron en el aire
        else
        {
            float at = g_fChampLaunchedAt[ent];
            bool grounded = (GetEntityFlags(ent) & FL_ONGROUND) != 0;
            if (now - at > 0.25 && grounded)
            {
                // ¡aterrizo!: stagger + dano de impacto + estruendo
                int owner = g_iChampLaunchedBy[ent];
                float pos[3];
                GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
                float src[3];
                src[0] = pos[0]; src[1] = pos[1]; src[2] = pos[2] - 10.0;
                Champ_SetStagger(ent, owner, src, 1.2);
                if (owner > 0 && IsValidClient(owner))
                {
                    if (g_fChampLaunchDmg[ent] > 0.0)
                        ChampDamage(ent, owner, g_fChampLaunchDmg[ent], DMG_CLUB);
                    int sel = g_iChampSel[owner];
                    int col[4];
                    ChampColorOf(sel, col);
                    ChampFX_Burst(pos, col);
                    ChampFX_Shake(pos, 8, 300, 0.5);
                    EmitSoundToAll(SND_MISSILE2, ent, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.7, 120);
                }
                done = true;
            }
            else if (now - at > 3.0)
                done = true;   // timeout de vuelo
        }

        if (done)
        {
            if (ent > 0 && ent < 2048)
            {
                g_fChampLaunchedAt[ent] = 0.0;
                g_fChampLaunchDmg[ent] = 0.0;
            }
            g_hChampLaunchList.Erase(i);
        }
    }
    return Plugin_Continue;
}

// ============================================================================
// v63 (v28): LA GUARDIANA — stats reales de Poppy (wiki LoL) + SENUO
// ----------------------------------------------------------------------------
// La vida de Poppy ya no es abstracta: HP 610 (+110/nv), regen 9 (+0.8) HP5,
// armadura 35 (+5/nv) y AD 56 (+4/nv) escalan con su nivel (tope 50).
//
// El SENUO planta un estandarte invisible: un bot superviviente sin armas y
// sin modelo, PEGADO al cuerpo de Poppy cada frame (OnGameFrame). Los
// infectados lo ven como un jugador real: los comunes lo rodean y lo
// zarpadean (sus garras intersectan el modelo de Poppy), y los especiales
// pueden comprometerse contra el. TODO el dano que "recibe" se bloquea y se
// redirige a la barra de vida de Poppy (pasando por su armadura real).
// A 0: Poppy se retira herida, el bot se disuelve y ella regresa sola al
// curarse el 60%. SOLO Poppy (sel == 1), cero cambios en los otros 7.
// ============================================================================

// --- stats LoL (wiki, parche actual) ----------------------------------------
float PoppyMaxHP(int client)
{
    return 610.0 + 110.0 * float(g_iChampLevel[client][1] - 1);
}

float PoppyAD(int client)
{
    return 56.0 + 4.0 * float(g_iChampLevel[client][1] - 1);
}

float PoppyArmorFactor(int client)
{
    // formula real de LoL: 100 / (100 + armadura)
    float armor = 35.0 + 5.0 * float(g_iChampLevel[client][1] - 1);
    return 100.0 / (100.0 + armor);
}

float PoppyRegenRate(int client)
{
    // HP5 de la wiki (9 + 0.8/nv) pasado a HP/s, afinado con cvar
    return (9.0 + 0.8 * float(g_iChampLevel[client][1] - 1)) * 0.2 * g_fPoppyRegen;
}

// --- barra HUD (hint text a la duena) ---------------------------------------
void PoppyHUD(int client, bool active)
{
    if (!IsClientInGame(client) || IsFakeClient(client)) return;
    float maxhp = PoppyMaxHP(client);
    if (maxhp <= 0.0) return;
    int cells = RoundToFloor(g_fPoppyHP[client] / maxhp * 16.0);
    if (cells < 0) cells = 0;
    if (cells > 16) cells = 16;
    static char sBar[40];
    sBar[0] = '\0';
    for (int c = 0; c < 16; c++)
        StrCat(sBar, sizeof(sBar), (c < cells) ? "#" : "-");
    PrintHintText(client, "Poppy Nv %d  [%s]  %d / %d%s",
        g_iChampLevel[client][1], sBar, RoundToFloor(g_fPoppyHP[client]), RoundToFloor(maxhp),
        active ? "  ¡PROVOCANDO!" : "");
}

// --- absorcion de dano (lo que "recibe" el bot va a la barra de Poppy) ------
void PoppyTakeDamage(int client, float raw, bool tankHit)
{
    if (!g_bPoppyStats || client <= 0 || !IsClientInGame(client)) return;

    float dmg = raw * g_fPoppyDecoyMult;
    if (tankHit) dmg *= g_fPoppyTankMult;
    dmg *= PoppyArmorFactor(client);          // armadura real de LoL
    if (dmg < 1.0) dmg = 1.0;

    g_fPoppyHP[client] -= dmg;
    g_fPoppyLastHit[client] = GetGameTime();

    // feedback fisico: chispas doradas en el cuerpo de la mascota
    if (IsPetValid(client))
    {
        int pet = EntRefToEntIndex(g_iPet_Entity[client]);
        if (pet > 0 && IsValidEntity(pet))
        {
            float pPos[3];
            GetEntPropVector(pet, Prop_Data, "m_vecOrigin", pPos);
            pPos[2] += 40.0;
            int col[4];
            ChampColorOf(1, col);
            ChampFX_Burst(pPos, col);
            if (GetRandomFloat(0.0, 1.0) < 0.3)
                PoppyEmit(POP_P1, pet, "", 1.0, SNDLEVEL_SCREAMING);   // v36: 0.6/75 dB era casi inaudible
        }
    }

    // NOTA: el retiro por HP 0 lo ordena PoppyDecoy_Tick (nunca dentro de un
    // hook de dano: hacer RemovePet/KickClient aqui seria peligroso).
    PoppyHUD(client, g_iDecoyBot[client] != -1);   // v35 (v72): su propio senuo
}

// --- retirada herida (barra a 0) ---------------------------------------------
void PoppyRetreat(int client)
{
    PoppyDecoy_End(client, true);   // v35 (v72): el senuo de ESTA duena
    g_bPoppyHurt[client] = true;
    g_fDecoyNextAt[client] = GetGameTime() + g_fPoppyDecoyCD;

    CPrintToChat(client, "{green}[Raven]{default} {olive}Poppy se retira herida{default} — se esta curando. Volvera al 60% de vida.");

    if (IsPetValid(client))
    {
        int pet = EntRefToEntIndex(g_iPet_Entity[client]);
        if (pet > 0 && IsValidEntity(pet))
        {
            float pPos[3];
            GetEntPropVector(pet, Prop_Data, "m_vecOrigin", pPos);
            int col[4];
            ChampColorOf(1, col);
            ChampFX_Burst(pPos, col);
            ChampFX_Shake(pPos, 10, 350, 0.6);
            ChampFX_Particle(pPos, "weapon_grenade_explosion", 1.0);
            PoppyEmitLoud(POP_W2, pet, SND_GLASS, SNDLEVEL_GUNFIRE, SNDCHAN_ITEM, SNDCHAN_STREAM);   // v36: retirada — doble canal
        }
    }

    RemovePet(client);
    g_bChampWanted[client] = true;   // para que Timer_ChampReturn la traiga al curarse
}

// --- v35 (v72): helpers del MULTI-SENUO (una Poppy por jugadora) --------------
// ¿De que duena es este bot prestado? -1 = bot libre. PROTECCION (pedido
// del usuario): una campeon JAMAS toma el bot que otra ya esta usando.
int DecoyOwnerOfBot(int bot)
{
    if (bot <= 0 || bot > MaxClients) return -1;
    for (int i = 1; i <= MaxClients; i++)
        if (g_iDecoyBot[i] == bot) return i;
    return -1;
}

// reset del registro de senuo de UNA duena (no toca el bot: solo su papel)
void DecoyResetOwner(int owner)
{
    if (owner <= 0 || owner > MaxClients) return;
    g_iDecoyBot[owner] = -1;
    g_iDecoyBotUid[owner] = -1;
    g_sDecoyOrigName[owner][0] = '\0';
    g_iDecoyOrigChar[owner] = -1;
    g_sDecoyOrigModel[owner][0] = '\0';
    g_iDecoyOrigHP[owner] = 0;
    g_iDecoyLockFights[owner] = 0;
}

// cierre de TODOS los senuos activos (fin de ronda / descarga del plugin)
void PoppyDecoy_EndAll(bool hurt)
{
    for (int i = 1; i <= MaxClients; i++)
        if (g_iDecoyBot[i] != -1) PoppyDecoy_End(i, hurt);
}

// --- senuo: arranque ----------------------------------------------------------
bool PoppyDecoy_Start(int client)
{
    if (!g_bPoppyStats || !g_bPoppyDecoy) return false;
    if (g_iDecoyBot[client] != -1) return false;   // v35: esta duena YA tiene senuo
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return false;
    if (!IsPetValid(client) || g_iChampSel[client] != 1) return false;

    // v35 (v72): SOLO PRESTAMO (decision del usuario tras sus pruebas: el
    // bot CREADO seguia siendo borrado por el server a los pocos segundos,
    // el PRESTAMO funciona estable y sin conflicto). Se toma prestado uno
    // de los bots supervivientes que YA existen: al ser parte del equipo
    // de los 4, el juego NUNCA lo saca del servidor. Sin fake client
    // nuevo, sin kick, sin survivor_limit.
    int pet = EntRefToEntIndex(g_iPet_Entity[client]);
    if (pet <= 0 || !IsValidEntity(pet)) return false;

    // candidato: bot superviviente vivo que NO este ya prestado a OTRA
    // duena (v35: PROTECCION anti-robo entre campeones)
    int bot = -1;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsFakeClient(i)) continue;
        if (GetClientTeam(i) != L4D2Team_Survivor) continue;
        if (!IsPlayerAlive(i)) continue;
        if (i == client) continue;                  // nunca la propia duena
        if (DecoyOwnerOfBot(i) != -1) continue;     // v35: ya es senuo de OTRA
        bot = i;
        break;
    }
    if (bot <= 0)
    {
        // throttle de reintento: sin esto el aviso saldria cada tick
        g_fDecoyNextAt[client] = GetGameTime() + 15.0;
        CPrintToChat(client, "{green}[Raven]{default} No hay ningun bot superviviente libre para el senuo (prestado a otra Poppy o 4 humanos). Sin coste.");
        PrintToServer("[Raven] La Guardiana: sin bot superviviente libre para la duena %d (prestado a otra duena o humanos en los 4 puestos).", client);
        return false;
    }

    // v70 (v33) + v35 (v72): REGISTRO DEL WATCHDOG por duena. Se anota el
    // userid unico de la conexion del bot prestado + su identidad ORIGINAL
    // completa. Cada 0.1 s el tick comprueba que ESE userid sigue vivo en
    // el mismo slot: si el server lo borro o lo reasigno, se detecta al
    // instante, sin depender de eventos.
    g_iDecoyBotUid[client] = GetClientUserId(bot);
    GetClientName(bot, g_sDecoyOrigName[client], sizeof(g_sDecoyOrigName[]));
    g_iDecoyOrigChar[client] = GetEntProp(bot, Prop_Send, "m_survivorCharacter");
    GetEntPropString(bot, Prop_Data, "m_ModelName", g_sDecoyOrigModel[client], sizeof(g_sDecoyOrigModel[]));
    g_iDecoyOrigHP[client] = GetEntProp(bot, Prop_Send, "m_iHealth");

    // reserva inmediata (el bot YA esta en juego: sin espera de claim)
    g_iDecoyBot[client] = bot;
    g_iDecoyLockFights[client] = 0;      // diagnostico fresco por senuo
    g_fDecoyStripNext[client] = GetGameTime() + 1.0;
    // v35 (v72): SIN RELOJ. La provocacion es ILIMITADA: dura exactamente
    // lo que Poppy aguante en el mapa (se retira herida al llegar la barra
    // a 0, y RemovePet la devuelve al desaparecer por cualquier otra via).

    // transformacion completa (candado v32, sobre el bot prestado):
    // cuerpo invisible, sin glow, sin armas, imposible de herir
    SetEntityRenderMode(bot, RENDER_TRANSALPHA);
    SetEntityRenderColor(bot, 255, 255, 255, 0);
    if (HasEntProp(bot, Prop_Send, "m_bGlowEnabled"))   // v70: crash fix (la prop no existe en players de este build)
        SetEntProp(bot, Prop_Send, "m_bGlowEnabled", 0);
    SetEntProp(bot, Prop_Send, "m_iHealth", 2000);
    StripDecoyItems(bot);
    SDKHook(bot, SDKHook_OnTakeDamage, DecoyDamageFilter);

    // candado de identidad desde el primer instante (nombre "Poppy" +
    // personaje y modelo de la duena)
    DecoyLockVisuals(bot, client);

    // pegado inmediato al cuerpo de Poppy
    float dPos[3], dVel[3];
    GetEntPropVector(pet, Prop_Data, "m_vecOrigin", dPos);
    dVel[0] = 0.0; dVel[1] = 0.0; dVel[2] = 0.0;
    TeleportEntity(bot, dPos, NULL_VECTOR, dVel);

    // presentacion: anillo dorado + SFX de la zona W
    int col[4];
    ChampColorOf(1, col);
    ChampFX_Ring(dPos, 260.0, col, 0.9);
    ChampFX_Pillar(dPos, col, 180.0);
    PoppyEmitLoud(POP_W1, pet, SND_GLASS, SNDLEVEL_GUNFIRE, SNDCHAN_ITEM, SNDCHAN_STREAM);   // v36: arranque de la provocacion — doble canal
    CPrintToChat(client, "{green}[Raven]{default} {olive}LA GUARDIANA{default}: provocacion activa SIN limite de tiempo — dura mientras Poppy aguante (se retira al llegar su barra a 0).");
    PoppyHUD(client, true);
    return true;
}

// v66 (v31): CANDADO DE IDENTIDAD del senuo. El juego "adopta" al bot
// ~0.5-1 s despues de nacer: le asigna un personaje superviviente (le pone
// SU modelo, lo RENOMBRA con el nombre del personaje y le resetea el
// render -> bot visible, renombrado y despegado de Poppy). Se aplica al
// reclamarlo, en CADA player_spawn suyo y en cada tick del watchdog:
//   1) nombre: "Poppy" SIEMPRE (el juego lo renombra; lo devolvemos)
//   2) personaje: EL MISMO de la duena (aspecto y voz: pedido del usuario)
//   3) cuerpo invisible sin glow (el cambio de modelo lo resetea)
//   4) IA clavada (lagged movement 0: el juego no puede apartarlo)
void DecoyLockVisuals(int bot, int owner)
{
    if (bot <= 0 || bot > MaxClients || !IsClientInGame(bot) || !IsFakeClient(bot)) return;

    bool bFight = false;   // v67 (v32): el juego intento cambiar la identidad

    // 1) nombre: el juego renombra al bot con el nombre del personaje
    char sName[32];
    GetClientName(bot, sName, sizeof(sName));
    if (!StrEqual(sName, "Poppy"))
    {
        SetClientInfo(bot, "name", "Poppy");
        bFight = true;
    }

    // 2) personaje de la duena: mismo survivor, mismo modelo, misma voz
    if (owner > 0 && owner <= MaxClients && IsClientInGame(owner)
        && GetClientTeam(owner) == L4D2Team_Survivor)
    {
        int oChar = GetEntProp(owner, Prop_Send, "m_survivorCharacter");
        if (GetEntProp(bot, Prop_Send, "m_survivorCharacter") != oChar)
        {
            SetEntProp(bot, Prop_Send, "m_survivorCharacter", oChar);
            char sModel[PLATFORM_MAX_PATH];
            GetEntPropString(owner, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
            if (sModel[0] != '\0') SetEntityModel(bot, sModel);
            bFight = true;
        }
    }

    // v67 (v32): diagnostico (1 vez por senuo): el juego re-personalizo al
    // bot y el candado lo revirtio. Si ves esta linea en la consola del
    // servidor, el sistema esta ganando la pulseada; si NO la ves y aun
    // asi el nombre cambia, el .smx cargado no es el nuevo (comprueba la
    // version con: sm plugins info l4d2_pet_fusion).
    if (bFight && g_iDecoyLockFights[owner] < 1)
    {
        g_iDecoyLockFights[owner] = 1;
        PrintToServer("[Raven] La Guardiana: el juego intento re-personalizar al senuo (nombre/personaje) — candado re-aplicado.");
    }

    // 3) cuerpo invisible (el cambio de modelo resetea el render)
    SetEntityRenderMode(bot, RENDER_TRANSALPHA);
    SetEntityRenderColor(bot, 255, 255, 255, 0);
    // v70 (v33): m_bGlowEnabled NO existe en la send table de players de
    // este build (prop heredada de L4D1): sin guard, SetEntProp lanzaba
    // "Property not found" y ABORTABA el callback entero (crash v32 en
    // DecoyLockVisuals: mataba el candado por frame y el watchdog)
    if (HasEntProp(bot, Prop_Send, "m_bGlowEnabled"))
        SetEntProp(bot, Prop_Send, "m_bGlowEnabled", 0);

    // 4) IA clavada: sin movimiento propio (manda el pegado por frame)
    SetEntPropFloat(bot, Prop_Data, "m_flLaggedMovementValue", 0.0);
}

// el bot no lleva NADA: la IA de bot recoge cosas del suelo
void StripDecoyItems(int bot)
{
    for (int slot = 0; slot <= 4; slot++)
    {
        int w = GetPlayerWeaponSlot(bot, slot);
        if (w > 0 && IsValidEntity(w))
        {
            RemovePlayerItem(bot, w);
            AcceptEntityInput(w, "Kill");
        }
    }
}

// --- senuo: cierre del senuo de UNA duena -------------------------------------
void PoppyDecoy_End(int owner, bool hurt)
{
    if (owner <= 0 || owner > MaxClients) return;
    int bot = g_iDecoyBot[owner];
    if (bot == -1) { DecoyResetOwner(owner); return; }

    // v35 (v72): el senuo de ESTA duena termino (Poppy se retiro o
    // desaparecio, la duena salio, fin de ronda, sin humanos vivos...).
    // El bot prestado NO se expulsa (es parte de los 4): se RESTAURA a su
    // identidad original y vuelve a jugar con normalidad. El kick de la
    // v32 era justo lo que provocaba el "otro bot": al expulsar, el juego
    // rellenaba el hueco con SU bot y se perdia todo.
    if (bot > 0 && bot <= MaxClients && IsClientConnected(bot))
        DecoyRestoreBot(owner, bot);
    DecoyResetOwner(owner);

    if (hurt) g_fDecoyNextAt[owner] = GetGameTime() + g_fPoppyDecoyCD;
    else if (IsClientInGame(owner))
    {
        g_fDecoyNextAt[owner] = GetGameTime() + g_fPoppyDecoyCD;
        CPrintToChat(owner, "{green}[Raven]{default} La provocacion termino (%d s de recarga).",
            RoundToFloor(g_fPoppyDecoyCD));
    }
}

// v35 (v72): devolver el bot prestado de ESTA duena a su estado original
// (anti-rastro). La llaman el cierre (PoppyDecoy_End), la salida de la
// duena (OnClientDisconnect), la recarga del plugin (OnPluginEnd) y el
// caso humano-en-el-cuerpo (via Event_PlayerBotReplace). NUNCA kick: el
// bot sigue siendo parte de los 4 supervivientes.
void DecoyRestoreBot(int owner, int bot)
{
    if (bot <= 0 || bot > MaxClients || !IsClientConnected(bot)) return;

    // limbo de respawn (conectado pero fuera de juego): solo el nombre;
    // el render/IA/SDKUnhook requieren InGame y el juego fija lo demas al
    // volver a nacer (ademas renombra al bot a su personaje)
    if (!IsClientInGame(bot))
    {
        if (IsFakeClient(bot) && g_sDecoyOrigName[owner][0] != '\0')
            SetClientInfo(bot, "name", g_sDecoyOrigName[owner]);
        return;
    }

    SDKUnhook(bot, SDKHook_OnTakeDamage, DecoyDamageFilter);

    // si un humano ocupo el cuerpo, Event_PlayerBotReplace ya lo dejo
    // visible y con piernas; aqui solo interesa quitar el filtro de dano
    if (!IsFakeClient(bot)) return;

    // 1) nombre original de vuelta (fin del "Poppy" prestado)
    if (g_sDecoyOrigName[owner][0] != '\0')
        SetClientInfo(bot, "name", g_sDecoyOrigName[owner]);

    // 2) personaje + modelo originales (mismo survivor, misma voz)
    if (g_iDecoyOrigChar[owner] >= 0)
        SetEntProp(bot, Prop_Send, "m_survivorCharacter", g_iDecoyOrigChar[owner]);
    if (g_sDecoyOrigModel[owner][0] != '\0')
        SetEntityModel(bot, g_sDecoyOrigModel[owner]);

    // 3) cuerpo visible de nuevo + IA desclavada
    SetEntityRenderMode(bot, RENDER_NORMAL);
    SetEntityRenderColor(bot, 255, 255, 255, 255);
    if (HasEntProp(bot, Prop_Send, "m_bGlowEnabled"))
        SetEntProp(bot, Prop_Send, "m_bGlowEnabled", 0);   // bots sin glow
    SetEntPropFloat(bot, Prop_Data, "m_flLaggedMovementValue", 1.0);

    // 4) vida original + arma de cortesia (el strip se llevo las suyas;
    //    la IA del bot recogera algo mejor del suelo enseguida)
    SetEntProp(bot, Prop_Send, "m_iHealth", (g_iDecoyOrigHP[owner] > 0) ? g_iDecoyOrigHP[owner] : 100);
    GivePlayerItem(bot, "weapon_pistol");
}

// --- filtro de dano del bot: TODO se redirige a la barra de Poppy ------------
public Action DecoyDamageFilter(int victim, int &attacker, int &inflictor,
    float &damage, int &damagetype)
{
    int owner = DecoyOwnerOfBot(victim);   // v35 (v72): victima -> su duena
    if (owner == -1) return Plugin_Continue;
    if (owner <= 0 || !IsClientInGame(owner)) return Plugin_Handled;

    bool fromInfected = false;
    bool tankHit = false;

    if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
    {
        if (GetClientTeam(attacker) == L4D2Team_Survivor) return Plugin_Handled;   // FF: sin coste
        if (GetClientTeam(attacker) == L4D2Team_Infected)
        {
            fromInfected = true;
            tankHit = (GetEntProp(attacker, Prop_Send, "m_zombieClass") == 8);
        }
    }
    else
    {
        int src = (attacker > 0) ? attacker : inflictor;
        if (src > 0 && src < 2048 && IsValidEntity(src))
        {
            char cls[24];
            if (GetEntityClassname(src, cls, sizeof(cls)))
                fromInfected = (StrEqual(cls, "infected") || StrEqual(cls, "witch"));
        }
        if (!fromInfected && inflictor > 0 && inflictor < 2048 && IsValidEntity(inflictor))
        {
            char icls[24];
            if (GetEntityClassname(inflictor, icls, sizeof(icls)))
                fromInfected = StrEqual(icls, "insect_swarm");   // escupitajo
        }
    }

    if (fromInfected && IsPlayerAlive(owner))
        PoppyTakeDamage(owner, damage, tankHit);

    return Plugin_Handled;   // el senuo NUNCA recibe dano real
}

// --- corazon: tick 0.1 s (hosteado en Timer_ChampLaunchTick) -----------------
void PoppyDecoy_Tick(float now)
{
    // 1) stats de TODOS los duenos de Poppy: nivel, regen, retorno, HUD
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
        if (g_iChampSel[i] != 1 || !g_bPoppyStats) continue;

        int lvl = g_iChampLevel[i][1];
        float maxhp = PoppyMaxHP(i);

        if (g_iPoppyLvlSeen[i] == 0)
        {
            g_fPoppyHP[i] = maxhp;                    // primera vez: barra llena
            g_iPoppyLvlSeen[i] = lvl;
        }
        else if (lvl > g_iPoppyLvlSeen[i])
        {
            g_fPoppyHP[i] += 110.0 * float(lvl - g_iPoppyLvlSeen[i]);   // subir nivel sana el crecimiento (LoL)
            g_iPoppyLvlSeen[i] = lvl;
        }
        if (g_fPoppyHP[i] > maxhp) g_fPoppyHP[i] = maxhp;

        if (g_fPoppyHP[i] < maxhp && now - g_fPoppyLastHit[i] > 3.0)
            g_fPoppyHP[i] += PoppyRegenRate(i) * 0.1;

        // retirada herida: regresa sola al 60% (o ya la invoco a mano la duena)
        if (g_bPoppyHurt[i])
        {
            if (IsPetValid(i)) g_bPoppyHurt[i] = false;
            else if (g_fPoppyHP[i] >= maxhp * 0.60)
            {
                g_bPoppyHurt[i] = false;
                CreateTimer(1.5, Timer_ChampReturn, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
                CPrintToChat(i, "{green}[Raven]{default} Poppy se ha recuperado: regresa al combate.");
            }
        }

        // barra visible: v64 cvar l4d2_poppy_hudmode (1=siempre, 2=daño/ provocando, 0=off)
        if (IsPetValid(i) && now >= g_fPoppyHUDNext[i])
        {
            bool bHUDPoppy = (g_iPoppyHUDMode == 1)
                      || (g_iPoppyHUDMode == 2 && (g_iDecoyBot[i] != -1 || g_fPoppyHP[i] < maxhp * 0.98));
            if (bHUDPoppy)
            {
                PoppyHUD(i, g_iDecoyBot[i] != -1);
                g_fPoppyHUDNext[i] = now + 0.5;
            }
        }
    }

    // 2) senuos activos: vigilar TODO (v35 v72: uno por cada duena Poppy)
    // anti-softlock global: sin humanos vivos los senuos se disuelven (la
    // ronda debe poder terminar)
    bool anyHuman = false;
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == L4D2Team_Survivor) { anyHuman = true; break; }

    for (int oi = 1; oi <= MaxClients; oi++)
    {
        int bot = g_iDecoyBot[oi];
        if (bot == -1) continue;
        int owner = oi;

        // v70 (v33) + v35 (v72): WATCHDOG por userid, por duena. Mientras
        // el bot prestado viva, su userid resuelve EXACTAMENTE a su slot.
        // Si GetClientOfUserId devuelve 0, el server lo BORRO; si devuelve
        // otro index, lo REASIGNO. Deteccion en tiempo real (<= 0.1 s).
        if (g_iDecoyBotUid[oi] > 0)
        {
            int reg = GetClientOfUserId(g_iDecoyBotUid[oi]);
            if (reg != bot)
            {
                char sReg[48];
                if (reg <= 0) strcopy(sReg, sizeof(sReg), "borrado del servidor");
                else strcopy(sReg, sizeof(sReg), "reasignado a otro cliente");
                PrintToServer("[Raven] La Guardiana: watchdog 0.1s — el bot del senuo de la duena %d (userid %d) fue %s. Senuo disuelto sin restaurar: el slot ya no es del bot prestado.",
                    oi, g_iDecoyBotUid[oi], sReg);
                DecoyResetOwner(oi);
                g_fDecoyNextAt[oi] = GetGameTime() + g_fPoppyDecoyCD;
                if (IsClientInGame(oi))
                    CPrintToChat(oi, "{green}[Raven]{default} El server borro al bot de tu senuo: provocacion cancelada (%d s de recarga).",
                        RoundToFloor(g_fPoppyDecoyCD));
                continue;
            }
        }

        // v35 (v72): SIN RELOJ — la provocacion es ILIMITADA (pedido del
        // usuario). Solo termina cuando Poppy desaparece o muere
        // (RemovePet / PoppyRetreat), la duena sale o muere, el bot es
        // borrado (arriba), un humano ocupa el cuerpo, acaba la ronda o
        // no quedan humanos vivos.
        if (owner <= 0 || !IsClientInGame(owner) || !IsPlayerAlive(owner)
            || !IsPetValid(owner))
        {
            PoppyDecoy_End(oi, false);
            continue;
        }
        if (g_fPoppyHP[owner] <= 0.0)
        {
            PoppyRetreat(owner);   // hace End(true) + RemovePet
            continue;
        }
        if (!IsClientInGame(bot) || !IsFakeClient(bot))   // kick externo
        {
            PoppyDecoy_End(oi, false);
            continue;
        }
        if (!anyHuman)
        {
            PoppyDecoy_End(oi, false);
            continue;
        }

        // pines de SI sobre el bot: Poppy SE LOS SACUDE (stagger real + golpe)
        int pin = GetEntProp(bot, Prop_Send, "m_pounceAttacker");
        if (pin <= 0) pin = GetEntProp(bot, Prop_Send, "m_tongueOwner");
        if (pin <= 0) pin = GetEntProp(bot, Prop_Send, "m_jockeyAttacker");
        if (pin <= 0) pin = GetEntProp(bot, Prop_Send, "m_pummelAttacker");
        if (pin <= 0) pin = GetEntProp(bot, Prop_Send, "m_carryAttacker");
        if (pin > 0 && pin <= MaxClients && IsClientInGame(pin) && now >= g_fDecoyPinNext[pin])
        {
            g_fDecoyPinNext[pin] = now + 1.0;
            float bPos[3];
            GetClientAbsOrigin(bot, bPos);
            Champ_SetStagger(pin, owner, bPos, 1.8);
            ChampDamage(pin, owner, PoppyAD(owner) * 0.5, DMG_CLUB);
            PoppyTakeDamage(owner, 12.0, false);      // coste fijo del sacudon
            int col[4];
            ChampColorOf(1, col);
            ChampFX_Burst(bPos, col);
            PoppyEmitLoud(POP_W2, bot, SND_GLASS, SNDLEVEL_GUNFIRE, SNDCHAN_ITEM, SNDCHAN_STREAM);   // v36: sacudon — doble canal
            CPrintToChat(owner, "{green}[Raven]{default} {olive}Poppy se sacude{default} al especial que la agarraba.");
        }

        // la IA de bot recoge cosas del suelo: strip periodico
        if (now >= g_fDecoyStripNext[oi])
        {
            g_fDecoyStripNext[oi] = now + 1.0;
            StripDecoyItems(bot);
        }

        // v66 (v31): candado de identidad cada tick (0.1 s): si el juego
        // renombro al bot, le cambio el modelo o lo respawneo, aqui vuelve a
        // ser "Poppy" invisible con el personaje de la duena, pegado a ella.
        DecoyLockVisuals(bot, owner);
    }
}

// --- un humano tomo el cuerpo del bot: devolverlo VISIBLE y soltarlo ---------
public void Event_PlayerBotReplace(Event event, const char[] name, bool dontBroadcast)
{
    int bot = GetClientOfUserId(event.GetInt("bot"));
    int owner = DecoyOwnerOfBot(bot);   // v35 (v72): ¿de que duena era el bot?
    if (owner == -1) return;

    SDKUnhook(bot, SDKHook_OnTakeDamage, DecoyDamageFilter);
    SetEntityRenderMode(bot, RENDER_NORMAL);
    SetEntityRenderColor(bot, 255, 255, 255, 255);
    // v70 (v33): guard — la prop no existe en players de este build
    if (HasEntProp(bot, Prop_Send, "m_bGlowEnabled"))
        SetEntProp(bot, Prop_Send, "m_bGlowEnabled", 1);
    // v66 (v31): el humano que ocupa el cuerpo recupera las piernas (la IA
    // clavada del candado lo habria dejado quieto) y vida normal (el senuo
    // llevaba 2000 de vida para ser imposible de herir).
    SetEntPropFloat(bot, Prop_Data, "m_flLaggedMovementValue", 1.0);
    SetEntProp(bot, Prop_Send, "m_iHealth", 100);

    // v70 (v33): el humano recupera el PERSONAJE y MODELO originales del
    // bot prestado (no el de la duena que dejamos puesto)
    if (g_iDecoyOrigChar[owner] >= 0)
        SetEntProp(bot, Prop_Send, "m_survivorCharacter", g_iDecoyOrigChar[owner]);
    if (g_sDecoyOrigModel[owner][0] != '\0')
        SetEntityModel(bot, g_sDecoyOrigModel[owner]);

    // limpieza manual: NUNCA kick (ahora es un jugador de verdad)
    DecoyResetOwner(owner);
    g_fDecoyNextAt[owner] = 0.0;    // reembolso del cooldown

    if (IsClientInGame(owner))
        CPrintToChat(owner, "{green}[Raven]{default} Un jugador ocupo el cuerpo del senuo: reintentalo en un momento.");
}

// ============================================================================
// EMBESTIDAS (dashes con deslizamiento visible)
// ============================================================================
// El pet se desliza por teleports progresivos (20 ticks/s) mientras la
// IA de seguimiento del companion esta pausada (guard v45 en OnGameFrame).

void Champ_DashStart(int client, int pet, int target, int style, float speed, float dur)
{
    if (pet <= 0 || !IsValidEntity(pet)) return;
    if (g_bChampDashing[client]) return;
    if (g_bReviveInProgress[client]) return;   // v56: prioridad absoluta — no abandona al caido

    float petPos[3], destPos[3];
    GetEntPropVector(pet, Prop_Data, "m_vecOrigin", petPos);
    if (target > 0 && IsValidEntity(target))
        GetEntPropVector(target, Prop_Send, "m_vecOrigin", destPos);
    else
    {
        // sin objetivo: embiste en la direccion del ultimo target conocido
        destPos[0] = petPos[0];
        destPos[1] = petPos[1];
        destPos[2] = petPos[2];
    }

    g_bChampDashing[client] = true;
    g_fChampDashEnd[client] = GetGameTime() + dur;
    g_iChampDashTarget[client] = (target > 0) ? EntIndexToEntRef(target) : -1;
    g_iChampDashStyle[client] = style;

    int sel = g_iChampSel[client];
    int col[4];
    ChampColorOf(sel, col);
    ChampFX_Trail(pet, col, 1.2);
    ChampFX_FadeToOwner(client, g_iChampColors[sel][0], g_iChampColors[sel][1], g_iChampColors[sel][2]);
    EmitSoundToAll(SND_JETPASS, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.5, 140);

    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(EntIndexToEntRef(pet));
    pack.WriteFloat(speed);
    pack.WriteCell(style);
    pack.WriteFloat(destPos[0]);
    pack.WriteFloat(destPos[1]);
    pack.WriteFloat(destPos[2]);
    CreateTimer(0.05, Timer_ChampDashTick, pack,
                TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
}

void Champ_DashCancel(int client)
{
    g_bChampDashing[client] = false;   // el tick se detiene solo al ver el flag
    g_iChampDashTarget[client] = -1;
    g_bChampDashCarry[client] = false; // v47
}

void Champ_DashStop(int client, int pet)
{
    g_bChampDashing[client] = false;
    g_iChampDashTarget[client] = -1;
    g_bChampDashCarry[client] = false; // v47
    if (pet <= 0 || !IsValidEntity(pet)) return;
    SnapPetToGround(client);
    SetPetAnimation(client, "Idle");

    // si quedo muy lejos de la duegna, vuelve a su lado de un salto
    float ownerPos[3], petPos[3];
    GetClientAbsOrigin(client, ownerPos);
    GetEntPropVector(pet, Prop_Data, "m_vecOrigin", petPos);
    if (GetVectorDistance(ownerPos, petPos) > 600.0)
    {
        TeleportEntity(pet, ownerPos, NULL_VECTOR, NULL_VECTOR);
        SnapPetToGround(client);
    }
}



public bool TraceFilterChampDash(int entity, int contentsMask, any pet)
{
    if (entity == view_as<int>(pet)) return false;
    if (entity > 0 && entity <= MaxClients) return false;   // jugadores no son muro
    if (IsValidEntity(entity))
    {
        char cls[16];
        GetEntityClassname(entity, cls, sizeof(cls));
        if (StrEqual(cls, "infected") || StrEqual(cls, "witch")) return false;   // infectados no son muro
    }
    return true;
}

public Action Timer_ChampDashTick(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int userid = pack.ReadCell();
    int petRef = pack.ReadCell();
    float speed = pack.ReadFloat();
    int style = pack.ReadCell();
    float dest[3];
    dest[0] = pack.ReadFloat();
    dest[1] = pack.ReadFloat();
    dest[2] = pack.ReadFloat();

    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || !g_bChampDashing[client]
        || GetGameTime() > g_fChampDashEnd[client])
    {
        if (client > 0) Champ_DashCancel(client);
        return Plugin_Stop;
    }

    int pet = EntRefToEntIndex(petRef);
    if (pet <= 0 || !IsValidEntity(pet))
    {
        Champ_DashCancel(client);
        return Plugin_Stop;
    }

    float petPos[3];
    GetEntPropVector(pet, Prop_Data, "m_vecOrigin", petPos);

    // objetivo vivo: perseguirlo (homing)
    int target = -1;
    if (g_iChampDashTarget[client] != -1)
        target = EntRefToEntIndex(g_iChampDashTarget[client]);
    float goal[3];
    if (target > 0 && IsValidEntity(target) && IsEnemyAlive(target))
    {
        GetEntPropVector(target, Prop_Send, "m_vecOrigin", goal);
    }
    else
    {
        goal[0] = dest[0];
        goal[1] = dest[1];
        goal[2] = dest[2];
        g_iChampDashTarget[client] = -1;
    }


    float vDir[3];
    MakeVectorFromPoints(petPos, goal, vDir);
    vDir[2] = 0.0;
    if (GetVectorLength(vDir) < 1.0) { Champ_DashStop(client, pet); return Plugin_Stop; }
    NormalizeVector(vDir, vDir);

    float next[3];
    next[0] = petPos[0] + vDir[0] * speed * 0.05;
    next[1] = petPos[1] + vDir[1] * speed * 0.05;
    next[2] = petPos[2];

    // ---- colision con pared/muro/props (todo menos infectados y jugadores) ----
    float mins[3], maxs[3];
    mins[0] = -16.0; mins[1] = -16.0; mins[2] = -20.0;
    maxs[0] = 16.0;  maxs[1] = 16.0;  maxs[2] = 48.0;
    float traceEnd[3];
    traceEnd[0] = next[0];
    traceEnd[1] = next[1];
    traceEnd[2] = next[2];
    TR_TraceHullFilter(petPos, traceEnd, mins, maxs, MASK_SOLID, TraceFilterChampDash, pet);
    if (TR_DidHit())
    {
        float hitPos[3];
        TR_GetEndPosition(hitPos);
        Champ_DashCrash(client, pet, hitPos, style);
        Champ_DashStop(client, pet);
        return Plugin_Stop;
    }

    // v47: el pet mira hacia donde embiste (deslizamiento natural)
    float vFace[3], vFaceAng[3];
    vFace[0] = vDir[0]; vFace[1] = vDir[1]; vFace[2] = 0.0;
    GetVectorAngles(vFace, vFaceAng);
    TeleportEntity(pet, next, vFaceAng, NULL_VECTOR);


    int sel = g_iChampSel[client];
    int col[4];
    ChampColorOf(sel, col);
    float now = GetGameTime();

    // ---- estilos con efecto durante el deslizamiento ----
    if (style == CHAMP_DASH_SMOLDER)
    {
        // Vuelo Ardiente: quema a todo el que cruza (cada victima 1 vez)
        ArrayList list = new ArrayList();
        int count = PetEnemiesInRadius(petPos, 90.0, list);
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
            if (now - g_fChampDashHitAt[ent] < 1.0) continue;
            g_fChampDashHitAt[ent] = now;
            float ePos[3];
            GetEntPropVector(ent, Prop_Send, "m_vecOrigin", ePos);
            ePos[2] += 40.0;
            ChampFX_Beam(petPos, ePos, col, 1.4, 0.12);
            int level = g_iChampLevel[client][sel];
            ChampDamage(ent, client, 20.0 + 2.0 * float(level), DMG_BURN);
            AddSlow(ent, 1.0);
        }
        delete list;
    }
    else if (style == CHAMP_DASH_VEX && target > 0)
    {
        float tPos[3];
        GetEntPropVector(target, Prop_Send, "m_vecOrigin", tPos);
        if (GetVectorDistance(petPos, tPos) < 100.0)
        {
            // llega al destino: avalancha sombria
            int level = g_iChampLevel[client][sel];
            ChampFX_Burst(tPos, col);
            ChampFX_Shake(tPos, 8, 350, 0.6);
            ArrayList list = new ArrayList();
            int count = PetEnemiesInRadius(tPos, 250.0, list);
            for (int i = 0; i < count; i++)
            {
                int ent = list.Get(i);
                if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
                ChampDamage(ent, client, 45.0 + 4.0 * float(level), DMG_CLUB);
                AddSlow(ent, 3.0);
                g_fChampDoomUntil[ent] = now + 3.0;   // marca Fatalidad
                g_iChampDoomOwner[ent] = client;
                ChampFX_Glow(ent, 0xAA3CFF, 2.0);   // morado sombrio (BGR)
            }
            delete list;
            EmitSoundToAll(SND_MISSILE1, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.8, 110);
            CPrintToChat(client, "{green}[%s]{default} {olive}Avalancha Siniestra{default}: estallido sombrio.",
                g_sChampNames[sel]);
            Champ_DashStop(client, pet);
            return Plugin_Stop;
        }
    }

    return Plugin_Continue;
}

// crash contra el muro: cada estilo castiga distinto
void Champ_DashCrash(int client, int pet, const float hitPos[3], int style)
{
    int sel = g_iChampSel[client];
    int col[4];
    ChampColorOf(sel, col);
    int level = g_iChampLevel[client][sel];

    ChampFX_Burst(hitPos, col);
    ChampFX_Shake(hitPos, 12, 400, 0.7);
    EmitSoundToAll(SND_GLASS, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.8, 100);

    if (style == CHAMP_DASH_ORNN)
    {
        // v48: estampido real contra la pared (paleta del SuperTank)
        ChampFX_Particle(hitPos, "charger_wall_impact", 1.0);
        ChampFX_Particle(hitPos, "tank_rock_throw_impact", 1.0);

        // onda sismica: todo cerca del impacto queda aturdido
        ArrayList list = new ArrayList();
        int count = PetEnemiesInRadius(hitPos, 220.0, list);
        int hits = 0;
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
            Champ_SetStagger(ent, pet, hitPos, 1.5);
            ChampDamage(ent, client, 35.0 + 3.0 * float(level), DMG_CLUB);
            hits++;
        }
        delete list;
        if (hits > 0)
            CPrintToChat(client, "{green}[%s]{default} {olive}Carga Abrasadora{default}: onda sismica — %d aturdidos.",
                g_sChampNames[sel], hits);
    }
}

// ============================================================================
// ZONAS PERSISTENTES (Anivia W/R, Thresh R): anillo + pulsos de dano/lentitud
// ============================================================================

void ChampZone_Start(int client, const float pos[3], float radius, float dur, int style, float dmg)
{
    g_bChampZoneActive[client] = true;   // la zona anterior muere al ver el flag
    g_fChampZoneUntil[client] = GetGameTime() + dur;

    int sel = g_iChampSel[client];
    int col[4];
    ChampColorOf(sel, col);

    DataPack pack = new DataPack();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteFloat(pos[0]);
    pack.WriteFloat(pos[1]);
    pack.WriteFloat(pos[2] + 20.0);
    pack.WriteFloat(radius);
    pack.WriteCell(style);
    pack.WriteFloat(dmg);
    pack.WriteCell(col[0]);
    pack.WriteCell(col[1]);
    pack.WriteCell(col[2]);
    pack.WriteCell(col[3]);
    CreateTimer(0.5, Timer_ChampZoneTick, pack,
                TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
}

public Action Timer_ChampZoneTick(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int userid = pack.ReadCell();
    float pos[3];
    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();
    float radius = pack.ReadFloat();
    int style = pack.ReadCell();
    float dmg = pack.ReadFloat();
    int col[4];
    col[0] = pack.ReadCell();
    col[1] = pack.ReadCell();
    col[2] = pack.ReadCell();
    col[3] = pack.ReadCell();

    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || !g_bChampZoneActive[client]
        || GetGameTime() > g_fChampZoneUntil[client])
    {
        if (client > 0) g_bChampZoneActive[client] = false;
        return Plugin_Stop;
    }

    // latido visual de la zona
    TE_SetupBeamRingPoint(pos, radius * 0.6, radius, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.45, 6.0, 0.5, col, 400, 0);
    TE_SendToAll();

    // pulsos: dano + lentitud renovada
    ArrayList list = new ArrayList();
    int count = PetEnemiesInRadius(pos, radius, list);
    for (int i = 0; i < count; i++)
    {
        int ent = list.Get(i);
        if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
        if (dmg > 0.0) ChampDamage(ent, client, dmg, DMG_CLUB);
        if (style == 0) AddSlow(ent, 1.2);        // tormenta glacial
        else if (style == 1)                       // jaula: lentitud fuerte
        {
            AddSlow(ent, 1.2);
            AddSlow(ent, 1.2);
        }
    }
    delete list;
    return Plugin_Continue;
}

// ============================================================================
// QUEMADURAS (Smolder Q / W de Ember): ticks con mini-beam
// ============================================================================

void ChampBurn_Start(int ent, int owner, float dmg, int ticks, const int color[4])
{
    if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent)) return;

    DataPack pack = new DataPack();
    pack.WriteCell(EntIndexToEntRef(ent));
    pack.WriteCell(GetClientUserId(owner));
    pack.WriteFloat(dmg);
    pack.WriteCell(ticks);
    pack.WriteCell(color[0]);
    pack.WriteCell(color[1]);
    pack.WriteCell(color[2]);
    pack.WriteCell(color[3]);
    CreateTimer(1.0, Timer_ChampBurnTick, pack,
                TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
}

public Action Timer_ChampBurnTick(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int ent = EntRefToEntIndex(pack.ReadCell());
    int owner = GetClientOfUserId(pack.ReadCell());
    float dmg = pack.ReadFloat();
    int ticks = pack.ReadCell();
    int col[4];
    col[0] = pack.ReadCell();
    col[1] = pack.ReadCell();
    col[2] = pack.ReadCell();
    col[3] = pack.ReadCell();

    if (ticks <= 0 || ent <= 0 || !IsValidEntity(ent) || !IsEnemyAlive(ent)
        || owner <= 0 || !IsClientInGame(owner))
        return Plugin_Stop;

    float pos[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
    pos[2] += 35.0;
    ChampFX_Beam(pos, pos, col, 2.0, 0.35);
    ChampFX_Sparks(pos, col);   // v57: sin TE_SetupSparks (linea morada en L4D2)
    ChampDamage(ent, owner, dmg, DMG_BURN);

    pack.Reset();
    pack.WriteCell(EntIndexToEntRef(ent));
    pack.WriteCell(GetClientUserId(owner));
    pack.WriteFloat(dmg);
    pack.WriteCell(ticks - 1);
    pack.WriteCell(col[0]);
    pack.WriteCell(col[1]);
    pack.WriteCell(col[2]);
    pack.WriteCell(col[3]);
    return Plugin_Continue;
}

// ============================================================================
// MARCA DE CAZA (Warwick W): glow rojo persistente sobre el especial
// ============================================================================

void ChampApplyMark(int client, int target)
{
    if (target <= 0 || target > MaxClients) return;
    if (!IsClientInGame(target) || !IsPlayerAlive(target) || GetClientTeam(target) != 3) return;
    if (GetEntProp(target, Prop_Send, "m_zombieClass") == 8) return;   // no al tank

    g_iChampMarkRef[client] = EntIndexToEntRef(target);
    g_fChampMarkUntil[client] = GetGameTime() + 5.0;
    SetEntProp(target, Prop_Send, "m_iGlowType", 3);
    SetEntProp(target, Prop_Send, "m_glowColorOverride", 0x0000FF);   // rojo (BGR)
}

public Action Timer_ChampUnmark(Handle timer, any data)
{
    int target = GetClientOfUserId(view_as<int>(data));
    if (target > 0 && IsClientInGame(target))
    {
        SetEntProp(target, Prop_Send, "m_iGlowType", 0);
        SetEntProp(target, Prop_Send, "m_glowColorOverride", 0);
    }
    return Plugin_Stop;
}

// ============================================================================
// PROGRESO SQLITE (tabla champ_progress en la MISMA BD de la nave)
// ============================================================================

void InitChampDatabase()
{
    if (!g_bPetDBOK) return;   // la BD la abre la nave (InitPetDatabase)
    if (!SQL_FastQuery(g_hPetDB, "CREATE TABLE IF NOT EXISTS champ_progress (steam TEXT NOT NULL, champ INTEGER NOT NULL, level INTEGER NOT NULL DEFAULT 1, xp INTEGER NOT NULL DEFAULT 0, kills INTEGER NOT NULL DEFAULT 0, updated INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (steam, champ));"))
    {
        LogError("[CHAMP] No se pudo crear la tabla champ_progress (el nivel de los campeones no sera persistente).");
        return;
    }
    LogMessage("[CHAMP] Tabla champ_progress lista (progreso por campeon persistente).");
    // v77: metodo de combate de Poppy (bot/dps/tank/sup) — tabla propia,
    // una fila por steamid (no toca champ_progress)
    if (!SQL_FastQuery(g_hPetDB, "CREATE TABLE IF NOT EXISTS poppy_method (steam TEXT PRIMARY KEY, method INTEGER NOT NULL DEFAULT 0, updated INTEGER NOT NULL DEFAULT 0);"))
        LogError("[CHAMP] No se pudo crear la tabla poppy_method (el metodo de combate no sera persistente).");
    else
        LogMessage("[CHAMP] Tabla poppy_method lista (metodo de combate de Poppy persistente).");
}

void Champ_DBLoad(int client)
{
    if (g_bChampLoaded[client]) return;
    if (g_bChampLoading[client]) return;   // v49: query ya en vuelo
    if (!IsClientInGame(client) || IsFakeClient(client)) return;
    if (!g_bPetDBOK)
    {
        // BD caida: el combate sigue activo (nivel 1, sin persistencia)
        g_bChampLoaded[client] = true;
        return;
    }

    char auth[64];
    if (!GetClientAuthId(client, AuthId_Engine, auth, sizeof(auth))) return;
    if (auth[0] == 'B' && StrContains(auth, "BOT") == 0) return;

    strcopy(g_sChampSteam[client], sizeof(g_sChampSteam[]), auth);

    // patron de la nave (PetDBLoad): el steamid viene del engine, sin escape
    char query[192];
    FormatEx(query, sizeof(query), "SELECT champ, level, xp, kills FROM champ_progress WHERE steam = '%s';", auth);
    // v77: metodo de combate de Poppy — su propia query en la misma BD
    char qMethod[192];
    FormatEx(qMethod, sizeof(qMethod), "SELECT method FROM poppy_method WHERE steam = '%s';", auth);
    SQL_TQuery(g_hPetDB, PoppyMethod_LoadCallback, qMethod, GetClientUserId(client));
    // v49: query en vuelo — el motor reintenta cada 3 s si se pierde
    g_bChampLoading[client] = true;
    g_iChampLoadUserid[client] = GetClientUserId(client);
    SQL_TQuery(g_hPetDB, ChampDB_LoadCallback, query, GetClientUserId(client));
}

public void ChampDB_LoadCallback(Handle owner, Handle hndl, const char[] error, any data)
{
    // v49: liberar SIEMPRE el flag de query en vuelo (aunque el cliente ya
    // no este o su userid giro con el cambio de mapa)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iChampLoadUserid[i] != 0 && g_iChampLoadUserid[i] == view_as<int>(data))
        {
            g_bChampLoading[i] = false;
            g_iChampLoadUserid[i] = 0;
            break;
        }
    }
    if (hndl == null)
    {
        LogError("[CHAMP] Error cargando progreso: %s", error);
        return;
    }

    int client = GetClientOfUserId(view_as<int>(data));
    if (client <= 0 || !IsClientInGame(client)) return;

    for (int i = 0; i < CHAMP_COUNT; i++)
    {
        g_iChampLevel[client][i] = 1;
        g_iChampXP[client][i] = 0;
        g_iChampKills[client][i] = 0;
    }

    while (SQL_FetchRow(hndl))
    {
        int idx = SQL_FetchInt(hndl, 0);
        if (idx < 0 || idx >= CHAMP_COUNT) continue;
        g_iChampLevel[client][idx] = SQL_FetchInt(hndl, 1);
        g_iChampXP[client][idx] = SQL_FetchInt(hndl, 2);
        g_iChampKills[client][idx] = SQL_FetchInt(hndl, 3);
        if (g_iChampLevel[client][idx] < 1) g_iChampLevel[client][idx] = 1;
        if (g_iChampLevel[client][idx] > g_iChampMaxLevel) g_iChampLevel[client][idx] = g_iChampMaxLevel;
    }

    g_bChampLoaded[client] = true;
}

// v77: callback del metodo de combate (tabla poppy_method)
public void PoppyMethod_LoadCallback(Handle owner, Handle hndl, const char[] error, any data)
{
    if (hndl == null)
    {
        LogError("[CHAMP] Error cargando el metodo de Poppy: %s", error);
        return;
    }
    int client = GetClientOfUserId(view_as<int>(data));
    if (client <= 0 || !IsClientInGame(client)) return;
    if (SQL_FetchRow(hndl))
    {
        int m = SQL_FetchInt(hndl, 0);
        if (m >= POPPY_M_BOT && m <= POPPY_M_SUP) g_iPoppyMethod[client] = m;
    }
}

// ============================================================================
// v77: METODO DE COMBATE DE POPPY (bot / dps / tank / sup)
// DPS: caza por su cuenta y no regresa salvo emergencia. TANK: como DPS
// pero busca el CENTRO de la pelea. SUP: siempre cerca de la duena.
// BOT: el clasico de la v36 (pelea cerca + combate prolongado).
// ============================================================================

static const char g_sPoppyMethodNames[4][32] = {
    "BOT (clasico)",
    "DPS (caza por su cuenta)",
    "TANK (centro de la pelea)",
    "SUP (pegada a ti)"
};

void PoppyMethod_Set(int client, int method, bool announce)
{
    if (method < POPPY_M_BOT || method > POPPY_M_SUP) method = POPPY_M_BOT;
    if (g_iPoppyMethod[client] == method && announce)
    {
        CPrintToChat(client, "{green}[Raven]{default} Ya pelea en modo {olive}%s{default}.", g_sPoppyMethodNames[method]);
        return;
    }
    g_iPoppyMethod[client] = method;
    g_bPoppyFaroLoose[client] = false;   // v78: metodo nuevo = excursion nueva
    g_iPoppyFaroArea[client] = 0;

    // persistir (fire-and-forget, patron champ_progress)
    if (g_bPetDBOK && g_sChampSteam[client][0] != '\0')
    {
        char query[192];
        FormatEx(query, sizeof(query), "INSERT OR REPLACE INTO poppy_method (steam, method, updated) VALUES ('%s', %d, %d);",
            g_sChampSteam[client], method, GetTime());
        SQL_TQuery(g_hPetDB, ChampDB_SaveCallback, query, 100 + method);
    }
    if (announce)
        CPrintToChat(client, "{green}[Raven]{default} Metodo de combate: {olive}%s{default}.", g_sPoppyMethodNames[method]);

    // v78: aviso puntual — la marcha solitaria por la ruta (el faro) usa
    // los nativos de nav de left4dhooks; con uno viejo todo funciona igual
    // menos la marcha y Poppy navegara como siempre
    if ((method == POPPY_M_DPS || method == POPPY_M_TANK) && !g_bFaroNativesOK)
        CPrintToChat(client, "{green}[Raven]{default} Nota: la marcha por la ruta pide un {olive}left4dhooks{default} actualizado; mientras, navegacion clasica.");
}

void ShowPoppyMethodMenu(int client)
{
    Menu menu = new Menu(MenuHandler_PoppyMethod);
    menu.SetTitle("Metodo de combate de Poppy\nAhora: %s\n ", g_sPoppyMethodNames[g_iPoppyMethod[client]]);
    menu.AddItem("0", "BOT — el de siempre: pelea cerca y vuelve contigo");
    menu.AddItem("1", "DPS — caza por su cuenta; sin enemigos MARCHA sola por la ruta del mapa");
    menu.AddItem("2", "TANK — se planta en el CENTRO de la pelea; sin enemigos marcha por la ruta");
    menu.AddItem("3", "SUP — siempre pegada a ti");
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_PoppyMethod(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Cancel)
    {
        if (item == MenuCancel_ExitBack) ShowChampMenu(client);
        return 0;
    }
    if (action != MenuAction_Select) return 0;
    char info[8];
    menu.GetItem(item, info, sizeof(info));
    PoppyMethod_Set(client, StringToInt(info), true);
    ShowPoppyMethodMenu(client);
    return 0;
}

public Action Cmd_PoppyMethod(int client, int args)
{
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Handled;
    if (args > 0)
    {
        char a[16];
        GetCmdArg(1, a, sizeof(a));
        int m = -1;
        if (StrEqual(a, "bot", false)) m = POPPY_M_BOT;
        else if (StrEqual(a, "dps", false)) m = POPPY_M_DPS;
        else if (StrEqual(a, "tank", false)) m = POPPY_M_TANK;
        else if (StrEqual(a, "sup", false)) m = POPPY_M_SUP;
        else m = StringToInt(a);
        if (m >= POPPY_M_BOT && m <= POPPY_M_SUP)
            PoppyMethod_Set(client, m, true);
        else
            CPrintToChat(client, "{green}[Raven]{default} Metodos: {olive}bot{default}, {olive}dps{default}, {olive}tank{default} o {olive}sup{default}. Sin argumento abre el menu.");
    }
    else ShowPoppyMethodMenu(client);
    return Plugin_Handled;
}

void ChampSaveProgress(int client)
{
    if (!g_bPetDBOK || !g_bChampLoaded[client]) return;
    if (!IsClientInGame(client) || IsFakeClient(client)) return;
    if (g_sChampSteam[client][0] == '\0') return;

    // patron de la nave (PetSaveProgress): steamid del engine, sin escape
    for (int i = 0; i < CHAMP_COUNT; i++)
    {
        char query[256];
        FormatEx(query, sizeof(query),
            "INSERT OR REPLACE INTO champ_progress (steam, champ, level, xp, kills, updated) VALUES ('%s', %d, %d, %d, %d, %d);",
            g_sChampSteam[client], i, g_iChampLevel[client][i], g_iChampXP[client][i], g_iChampKills[client][i], GetTime());
        SQL_TQuery(g_hPetDB, ChampDB_SaveCallback, query, i);
    }
}

public void ChampDB_SaveCallback(Handle owner, Handle hndl, const char[] error, any data)
{
    if (hndl == null)
        LogError("[CHAMP] Error guardando campeon %d: %s", view_as<int>(data), error);
}

public Action Timer_ChampAutosave(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
        if (!g_bChampLoaded[i]) continue;
        ChampSaveProgress(i);
    }
    return Plugin_Continue;
}

// ============================================================================
// XP Y NIVEL DE CAMPÉON
// ============================================================================

int ChampXPToNext(int level)
{
    return 60 + level * 12;
}

// dano del auto-ataque (base + nivel, con pasivas aplicadas por el llamador)
float ChampBaseDamage(int client)
{
    int sel = g_iChampSel[client];
    float dmg = float(g_iChampDmgBase + g_iChampDmgPerLevel * g_iChampLevel[client][sel]);
    // v63 (v28): Poppy pega con su AD REAL de LoL — 56 (+4 por nivel),
    // afinado con multiplicador (0.6: nivel 1 = 33.6, nivel 50 = 151)
    if (sel == 1 && g_bPoppyStats)
        dmg = PoppyAD(client) * g_fPoppyADMult;

    if (sel == 3)   // Smolder: Aliento Sobrecalentado
        dmg *= 1.0 + 0.06 * float(g_iChampKillsMap[client] / 10);
    // v63 (v28): el +1%/nv de la v60 vive ahora dentro del AD real de Poppy
    if (sel == 4)   // Thresh: Condenacion (almas)
    {
        if (g_iChampSouls[client] > 200) dmg *= 1.0 + 0.006 * 200.0;
        else dmg *= 1.0 + 0.006 * float(g_iChampSouls[client]);
    }
    return dmg;
}


// v60: rango REAL del auto-ataque por campeon. Poppy es MELEE de verdad:
// su golpe basico ya no llega a 350 u — pega a 150 u; solo cuando la
// Embajadora de Hierro (P) esta lista estira el brazo a 500 u.
float ChampAttackRange(int client)
{
    if (g_iChampSel[client] == 1)
    {
        if (GetGameTime() >= g_fChampNextP[client]) return 500.0;   // P lista: lanzamiento
        return 150.0;    // melee de martillo (pedido de la dueña)
    }
    return g_fChampRange;
}

// VELOCIDAD DE ATAQUE (v45): intervalo = base del campeon / multiplicador.
// El multiplicador crece +2.5% por nivel (cvar) con tope (cvar), y sube
// temporalmente con furias/empoderamientos.
float ChampAttackMult(int client, float now)
{
    int sel = g_iChampSel[client];
    int level = g_iChampLevel[client][sel];

    float mult = 1.0 + float(level) * g_fChampAspdPct;
    if (mult > g_fChampAspdCap) mult = g_fChampAspdCap;
    if (sel == 1 && g_bPoppyStats) mult *= g_fPoppyAspd;   // v63 (v28): AS base +15% (duena)
    if (now < g_fChampAspdUntil[client]) mult *= 1.4;              // buff temporal
    if (sel == 3 && now < g_fChampFuryUntil[client]) mult *= 2.0;  // Spyro E: furia
    if (sel == 7 && ChampOwnerLowHP(client, 0.60)) mult *= 1.55;   // Warwick P
    return mult;
}

float ChampAttackInterval(int client)
{
    int sel = g_iChampSel[client];
    float base = g_fChampBaseInterval[sel] * (g_fChampInterval / 1.8);
    float interval = base / ChampAttackMult(client, GetGameTime());
    if (interval < 0.30) interval = 0.30;   // piso del motor (tick 0.3 s)
    return interval;
}

float ChampAttackRate(int client)
{
    return 1.0 / ChampAttackInterval(client);
}

// cooldown de habilidad: base * cdmult * (1 - 0.4% por nivel) = -20% a nv 50
float ChampCD(int client, float base)
{
    int level = g_iChampLevel[client][g_iChampSel[client]];
    float cd = base * g_fChampAbCD * (1.0 - 0.004 * float(level));
    if (cd < 0.5) cd = 0.5;
    return cd;
}

// credita una baja al campeon activo: contadores + XP + avisos
void Champ_CreditKill(int client, int victim, int xp, bool special)
{
    if (!IsValidClient(client) || !g_bChampLoaded[client]) return;

    int sel = g_iChampSel[client];

    g_iChampKills[client][sel]++;
    if (sel == 3) g_iChampKillsMap[client]++;       // Smolder cuenta sus bajas
    if (sel == 4)                                   // Thresh cosecha almas
    {
        if (g_iChampSouls[client] < 200) g_iChampSouls[client]++;
    }

    int granted = ChampAddXP(client, xp);

    // v52: Poppy — cada especial abatido rebaja el CD del Veredicto un 25%
    // del TOTAL (5.5 s de los 22 s fijos): con 4 especiales queda recargada.
    // Solo aplica mientras la R esta en recarga (si ya esta lista, no hay
    // nada que rebajar y no spamea el chat).
    if (special && g_iChampSel[client] == 1 && IsPetValid(client))
    {
        float nowCd = GetGameTime();
        if (g_fChampNextR[client] > nowCd)
        {
            g_fChampNextR[client] -= 22.0 * 0.25;   // 25% del CD total (22 s)
            if (g_fChampNextR[client] <= nowCd)
            {
                g_fChampNextR[client] = 0.0;   // recargada: usables ya mismo
                CPrintToChat(client, "{green}[%s]{default} {olive}Veredicto del Guardián{default}: baja de especial — {olive}¡R recargada!{default}",
                    g_sChampNames[1]);
            }
            else
            {
                CPrintToChat(client, "{green}[%s]{default} {olive}Veredicto del Guardián{default}: {olive}-25%% CD{default} por baja de especial (lista en {olive}%.1f s{default}).",
                    g_sChampNames[1], g_fChampNextR[client] - nowCd);
            }
        }
    }

    if (special)
    {
        char victimName[16];
        if (victim > 0 && victim <= MaxClients)
            PetSIName(victim, victimName, sizeof(victimName));
        else
            strcopy(victimName, sizeof(victimName), "witch");
        if (granted > 0)
            CPrintToChat(client, "{green}[%s]{default} +{olive}%d XP{default} — {olive}%s{default} abatido por tu campeon.",
                g_sChampNames[sel], granted, victimName);

            // v56: cada especial/tank/witch abatido rebaja el CD del Revivir
            PetReviveOnSpecialKill(client, g_iChampLevel[client][sel]);
    }
    else
    {
        // comunes: aviso agrupado cada 12 (mismo patron que la nave v2.8)
        g_iChampMsgKills[client]++;
        g_iChampMsgXP[client] += granted;
        if (g_iChampMsgKills[client] >= 12)
        {
            if (g_iChampMsgXP[client] > 0)
                CPrintToChat(client, "{green}[%s]{default} Horda digerida: +{olive}%d XP{default} (Nv %d — XP %d/%d).",
                    g_sChampNames[sel], g_iChampMsgXP[client], g_iChampLevel[client][sel],
                    g_iChampXP[client][sel], ChampXPToNext(g_iChampLevel[client][sel]));
            g_iChampMsgKills[client] = 0;
            g_iChampMsgXP[client] = 0;
        }
    }
}

int ChampAddXP(int client, int amount)
{
    if (!IsValidClient(client) || amount <= 0) return 0;
    if (!g_bChampLoaded[client]) return 0;

    int sel = g_iChampSel[client];
    int maxLvl = g_iChampMaxLevel;
    if (g_iChampLevel[client][sel] >= maxLvl) return 0;

    int before = g_iChampLevel[client][sel];
    g_iChampXP[client][sel] += amount;

    while (g_iChampLevel[client][sel] < maxLvl
        && g_iChampXP[client][sel] >= ChampXPToNext(g_iChampLevel[client][sel]))
    {
        g_iChampXP[client][sel] -= ChampXPToNext(g_iChampLevel[client][sel]);
        g_iChampLevel[client][sel]++;
    }

    if (g_iChampLevel[client][sel] != before)
    {
        EmitSoundToClient(client, SND_REWARD);
        if (g_iChampLevel[client][sel] >= maxLvl)
            CPrintToChat(client, "{green}[%s]{default} {olive}NIVEL MAXIMO (%d)!{default} %s es leyenda.",
                g_sChampNames[sel], maxLvl, g_sChampLoL[sel]);
        else
            CPrintToChat(client, "{green}[%s]{default} {olive}NIVEL %d!{default} Dano: %d | Vel. ataque: %.2f/s | XP %d/%d.",
                g_sChampNames[sel], g_iChampLevel[client][sel],
                RoundToNearest(ChampBaseDamage(client)), ChampAttackRate(client),
                g_iChampXP[client][sel], ChampXPToNext(g_iChampLevel[client][sel]));

        // anillo + pilar de nivel alrededor del campeon
        if (ChampIsActive(client))
        {
            float petPos[3];
            GetEntPropVector(EntRefToEntIndex(g_iPet_Entity[client]), Prop_Data, "m_vecOrigin", petPos);
            petPos[2] += 20.0;
            int col[4];
            ChampColorOf(sel, col);
            TE_SetupBeamRingPoint(petPos, 10.0, 200.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.6, 12.0, 0.6, col, 400, 0);
            TE_SendToAll();
            ChampFX_Pillar(petPos, col, 200.0);
        }
        ChampSaveProgress(client);
    }
    return amount;
}
// ============================================================================
// v45 FUSION — MODULO CAMPEONES (parte B): motor + IA de prioridades
// ============================================================================
// IA estilo bot de LoL. Cada tick (0.3 s) se evaluan por orden:
//   1. SALVAR   — amenaza entrante sobre la duegna (saltos/cargas) o duegna
//                 agarrada/herida  -> habilidad guardian / defensiva
//   2. ULTIMATE — horda grande o tank cerca            -> R
//   3. COMBO    - marca del kit activa (congelado, presa, Fatalidad) -> E
//   4. CONTROL  - horda mediana                        -> W / AoE
//   5. POKE     - objetivo en rango                    -> Q
//   6. PASIVA   - stacks/temporizadores propios        -> P
//   y SIEMPRE el auto-ataque con velocidad que crece con el nivel.

// ----------------------------------------------------------------------------
// MOTOR DE COMBATE (tick global cada 0.3 s)
// ----------------------------------------------------------------------------
public Action Timer_ChampEngine(Handle timer)
{
    if (!g_bChampEnable || !g_bPluginEnable) return Plugin_Continue;

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || IsFakeClient(client) || !IsPlayerAlive(client)) continue;
        if (GetClientTeam(client) != 2) continue;
        if (!IsPetValid(client)) continue;
        if (!g_bChampLoaded[client])
        {
            // v49: autoreparacion — si la carga de progreso se perdio en el
            // cambio de mapa (callback fuera de juego), se reintenta cada 3 s
            if (GetGameTime() >= g_fChampLoadRetryAt[client])
            {
                g_fChampLoadRetryAt[client] = GetGameTime() + 3.0;
                Champ_DBLoad(client);
            }
            continue;
        }
        if (g_bChampDashing[client]) continue;   // embestida en curso: la IA espera

        Champ_Think(client);
    }
    return Plugin_Continue;
}

void Champ_Think(int client)
{
    int pet = EntRefToEntIndex(g_iPet_Entity[client]);
    if (pet <= 0 || !IsValidEntity(pet)) return;

    float petPos[3], petHead[3];
    GetEntPropVector(pet, Prop_Data, "m_vecOrigin", petPos);
    petHead[0] = petPos[0];
    petHead[1] = petPos[1];
    petHead[2] = petPos[2] + 40.0;

    float now = GetGameTime();

    // la marca de caza de Warwick expira sola (el glow lo quita su timer)
    if (g_iChampMarkRef[client] != -1 && now > g_fChampMarkUntil[client])
        g_iChampMarkRef[client] = -1;

    // v36 (usuario): IA de Poppy — presa STICKY + bot prestado YA.
    // (a) STICKY: el "enemigo mas cercano" se re-elegia cada tick y con
    //     dos enemigos equidistantes Poppy daba VUELTAS (el va-y-vien
    //     desenfrenado). Ahora mantiene su presa hasta que muere o se
    //     va del alcance: combate PROLONGADO.
    // (b) BOT PRESTADO DE UNA: en cuanto es invocada (entidad de pet
    //     nueva, por cualquier via: menu, comando, retorno automatico)
    //     toma prestado su bot YA — sin esperar a los 3+ infectados
    //     (ese disparo clasico queda como respaldo si no habia bot
    //     libre en ese instante o el CD de la retirada sigue vivo).
    int target = Champ_FindTarget(client, petPos);
    if (g_iChampSel[client] == 1 && g_bPoppyStats)
    {
        if (g_bPoppyDecoy && g_iDecoyBot[client] == -1
            && EntIndexToEntRef(pet) != g_iDecoyPetRef[client])
        {
            g_iDecoyPetRef[client] = EntIndexToEntRef(pet);
            if (now >= g_fDecoyNextAt[client]) PoppyDecoy_Start(client);
        }
        target = PoppyStickyTarget(client, petPos, target);
    }
    if (target > 0) g_iChampTarget[client] = EntIndexToEntRef(target);
    else g_iChampTarget[client] = -1;

    float targetPos[3];
    float dist = 99999.0;
    if (target > 0)
    {
        GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPos);
        dist = GetVectorDistance(petPos, targetPos);
    }

    // ---- kit del campeon (IA de prioridades, Q/W/E/R/P) ----
    // v78: presa tras un MURO (veredicto del nav): no se gastan ni el Q ni
    // la E en una pared — mientras el faro la lleva por la ruta hasta que
    // el camino se abra, solo corren las pasivas guardianas
    bool bWalled = (g_iChampSel[client] == 1 && g_bPoppyStats && target > 0
        && (g_iPoppyMethod[client] == POPPY_M_DPS || g_iPoppyMethod[client] == POPPY_M_TANK)
        && PoppyTargetPathBlocked(client, petPos, targetPos));
    if (g_bChampAI && target > 0 && !bWalled)
        Champ_AutoAbilities(client, pet, petPos, petHead, target, targetPos, dist, now);
    else if (g_bChampAI)
        Champ_AutoAbilitiesIdle(client, pet, petPos, petHead, now);

    // ---- auto-ataque al infectado mas cercano ----
    // v76: el golpe NUEVO espera a que la animacion en curso termine —
    // nunca hay dano sin swing: el ataque anterior termina su animacion
    // antes de que salga el siguiente y durante una habilidad (o la
    // carga de la R) Poppy no pega.
    if (target > 0 && dist <= ChampAttackRange(client) && now >= g_fChampNextAttack[client]
    	&& !(now < g_fPet_AnimLock[client] && g_iChampAnimPrio[client] >= 1))
        Champ_Attack(client, pet, petHead, target, targetPos, dist, now);
}

int Champ_FindTarget(int client, const float petPos[3])
{
    // v63 (v28): la vision de Poppy es un 30% mas extensa
    // v77: y depende del METODO (PoppyHuntRadius) — DPS/TANK rastrean a
    // 3000 u (van a por todas), SUP ve 800 u alrededor y BOT conserva la
    // clasica del 30% extra
    bool bPoppy = (g_iChampSel[client] == 1 && g_bPoppyStats);
    float fVision = g_fChampRange + 40.0;
    if (bPoppy) fVision = PoppyHuntRadius(client);
    ArrayList list = new ArrayList();
    int count = PetEnemiesInRadius(petPos, fVision, list);

    int mark = -1;
    if (g_iChampMarkRef[client] != -1)
        mark = EntRefToEntIndex(g_iChampMarkRef[client]);

    int best = -1;
    float bestDist = 99999.0;
    float bestScore = -99999.0;
    // v77: TANK persigue el CENTRO de la pelea (puntua los vecinos de
    // cada candidato y los especiales valen doble); SUP elige al mas
    // pegado a la DUENA; BOT y DPS, al mas cercano a Poppy
    bool bTankScore = (bPoppy && g_iPoppyMethod[client] == POPPY_M_TANK);
    bool bSupScore = (bPoppy && g_iPoppyMethod[client] == POPPY_M_SUP);
    float oPos[3];
    if (bSupScore) GetClientAbsOrigin(client, oPos);
    ArrayList near = null;
    if (bTankScore) near = new ArrayList();

    for (int i = 0; i < count; i++)
    {
        int ent = list.Get(i);
        if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent)) continue;
        if (!IsEnemyAlive(ent)) continue;

        if (ent == mark)   // Warwick W: la presa marcada tiene prioridad
        {
            best = ent;
            break;
        }

        float vPos[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        float d = GetVectorDistance(petPos, vPos);
        if (bTankScore)
        {
            float score = 1.0 - d / 4000.0;
            if (ent <= MaxClients) score += 2.0;   // especial o tank: centro de atencion
            near.Clear();
            score += float(PetEnemiesInRadius(vPos, 300.0, near)) * 0.5;
            if (score > bestScore) { bestScore = score; best = ent; }
        }
        else if (bSupScore)
        {
            float dOwner = GetVectorDistance(oPos, vPos);
            if (dOwner < bestDist) { bestDist = dOwner; best = ent; }
        }
        else if (d < bestDist) { bestDist = d; best = ent; }
    }
    if (near != null) delete near;
    delete list;
    return best;
}

// ----------------------------------------------------------------------------
// AUTO-ATAQUE (estilo LoL): cadencia que crece con el nivel + detonaciones P
// ----------------------------------------------------------------------------
void Champ_Attack(int client, int pet, const float petHead[3], int target, const float targetPos[3], float dist, float now)
{
    int sel = g_iChampSel[client];
    int level = g_iChampLevel[client][sel];

    // VELOCIDAD DE ATAQUE (v45): cuanto mas nivel, mas rapido golpea
    g_fChampNextAttack[client] = now + ChampAttackInterval(client);

    float dmg = ChampBaseDamage(client);
    bool ranged = false;

    // Poppy P — Embajadora de Hierro: cada 8 s el golpe sale a distancia +60%
    if (sel == 1 && now >= g_fChampNextP[client] && dist <= 500.0)
    {
        dmg *= 1.6;
        ranged = true;
        g_fChampNextP[client] = now + 8.0 * g_fChampAbCD;
        // v27: la pasiva SUENA parte por parte — P1 al proc; P2 -> P3
        // (zumbido) -> P4/P5 via Timer_PoppyShieldSeq (proc nuevo reemplaza)
        g_iChampRavenPGen[client]++;
        PoppyEmit(POP_P1, pet, "", 1.0, SNDLEVEL_SCREAMING);
        DataPack spack = new DataPack();
        spack.WriteCell(GetClientUserId(client));
        spack.WriteCell(1);
        spack.WriteCell(g_iChampRavenPGen[client]);
        CreateTimer(2.4, Timer_PoppyShieldSeq, spack,
                    TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
        CPrintToChat(client, "{green}[%s]{default} {olive}Embajadora de Hierro{default}: lanzamiento a distancia.",
            g_sChampNames[sel]);
    }

    // Smolder Q — Tiro Candente: version a distancia con +25% y quemadura
    if (sel == 3 && dist > 200.0 && now >= g_fChampNextQ[client])
    {
        g_fChampNextQ[client] = now + ChampCD(client, 7.0);
        dmg *= 1.25;
        ranged = true;
        int col[4];
        ChampColorOf(3, col);
        ChampFX_Beam(petHead, targetPos, col, 3.0, 0.35);
        ChampBurn_Start(target, client, 8.0 + float(level), 3, col);
    }

    // Storm Q — Golpe Tronador: EL PROXIMO golpe sale con rayo (+60%)
    if (sel == 5 && now < g_fChampQEmpowerUntil[client])
    {
        dmg *= 1.6;
        g_fChampQEmpowerUntil[client] = 0.0;   // se consume (fiel a LoL)
        int zap[4] = {240, 250, 255, 255};
        int zcol[4];
        ChampColorOf(5, zcol);
        float tPos[3];
        tPos[0] = targetPos[0];
        tPos[1] = targetPos[1];
        tPos[2] = targetPos[2] + 40.0;
        ChampFX_Beam(petHead, tPos, zap, 3.4, 0.25);
        ChampFX_Beam(petHead, tPos, zcol, 1.4, 0.2);
        if (g_bChampZapSnd) EmitSoundToAll(SND_CHAMP_ZAP, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.8);
    }

    // Warwick W — +30% contra la presa marcada
    if (sel == 7 && g_iChampMarkRef[client] != -1
        && target == EntRefToEntIndex(g_iChampMarkRef[client]))
        dmg *= 1.3;

    // Vex P — Fatalidad: el objetivo marcado DETONA al golpearlo
    if (sel == 0 && g_fChampDoomUntil[target] > now
        && g_iChampDoomOwner[target] == client)
    {
        dmg *= 1.7;
        g_fChampDoomUntil[target] = 0.0;
        int col[4];
        ChampColorOf(0, col);
        float tPos[3];
        tPos[0] = targetPos[0];
        tPos[1] = targetPos[1];
        tPos[2] = targetPos[2] + 20.0;
        ChampFX_Burst(tPos, col);
        ArrayList list = new ArrayList();
        int count = PetEnemiesInRadius(tPos, 110.0, list);
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (ent == target || !IsEnemyAlive(ent)) continue;
            ChampDamage(ent, client, 12.0 + float(level), DMG_CLUB);
        }
        delete list;
    }

    // Anivia E — Picadura Helada: ejecucion sobre el congelado por el Q
    if (sel == 2 && g_fChampFrostbiteAt[target] > 0.0
        && now - g_fChampFrostbiteAt[target] < 3.0
        && now >= g_fChampNextE[client])
    {
        dmg *= 2.25;
        g_fChampNextE[client] = now + ChampCD(client, 8.0);
        int core[4] = {220, 245, 255, 255};
        int col[4];
        ChampColorOf(2, col);
        float tPos[3];
        tPos[0] = targetPos[0];
        tPos[1] = targetPos[1];
        tPos[2] = targetPos[2] + 40.0;
        ChampFX_Beam(petHead, tPos, col, 3.2, 0.22);
        ChampFX_Beam(petHead, tPos, core, 1.2, 0.18);
        CPrintToChat(client, "{green}[%s]{default} {olive}Picadura Helada{default}: critico de escarcha (x2.25).",
            g_sChampNames[sel]);
    }

    float hitPos[3];
    hitPos[0] = targetPos[0];
    hitPos[1] = targetPos[1];
    hitPos[2] = targetPos[2] + 40.0;

    int col[4];
    ChampColorOf(sel, col);
    if (ranged || dist > 120.0)
        ChampFX_Beam(petHead, hitPos, col, 1.6, 0.12);
    PetBloodAt(hitPos);

    // Warwick P — Hambre Eterna: +2% de la vida maxima de la victima
    if (sel == 7)
        ChampDamagePct(target, client, 0.02, 4.0, DMG_CLUB);
    else
        ChampDamage(target, client, dmg, DMG_CLUB);
    if (sel == 1) PoppyBoneCrack(target);   // v77: el martillo de Poppy ROMPE HUESOS (mobius, patron amy.inc)

    // Storm P — Portador del Trueno: cada 4 golpes, cadena de rayos
    if (sel == 5)
    {
        g_iChampStacks[client]++;
        if (g_iChampStacks[client] >= 4)
        {
            g_iChampStacks[client] = 0;
            Champ_ThunderChain(client, pet, petHead, target, targetPos, col);
        }
    }

    // Smolder P — Sobrecalentado: 5 brasas = estallido de area
    if (sel == 3)
    {
        g_iChampStacks[client]++;
        if (g_iChampStacks[client] >= 5)
        {
            g_iChampStacks[client] = 0;
            float tPos[3];
            tPos[0] = targetPos[0];
            tPos[1] = targetPos[1];
            tPos[2] = targetPos[2] + 20.0;
            ChampFX_Burst(tPos, col);
            ChampFX_Ring(tPos, 130.0, col, 0.5);
            ChampFX_Shake(tPos, 6, 250, 0.4);
            ArrayList list = new ArrayList();
            int count = PetEnemiesInRadius(tPos, 130.0, list);
            for (int i = 0; i < count; i++)
                ChampDamage(list.Get(i), client, 25.0 + 2.0 * float(level), DMG_BURN);
            delete list;
            CPrintToChat(client, "{green}[%s]{default} {olive}Sobrecalentado{default}: ¡las brasas estallan!",
                g_sChampNames[sel]);
        }
    }

    // v77 (duena): Poppy SIEMPRE mira hacia donde activo el golpe —
    // encara al objetivo en el frame exacto en que sale el ataque
    if (sel == 1) PetFacePoint(client, targetPos);

    // animacion real de ataque del modelo (attack1 / attack2)
    SetPetAnimation(client, (GetRandomInt(0, 1) == 0) ? "Attack" : "Attack2");
    // v27: Poppy golpea con los FX del martillo del paquete (canal BODY
    // propio para no cortarse con voces/habilidades); los demas campeones
    // conservan la metralleta nativa
    if (sel == 1)
        PoppyEmit(POP_AFX + GetRandomInt(0, 5), pet, SND_GATLING, 1.0,
                  SNDLEVEL_TRAIN, SNDCHAN_BODY);
    else
        EmitSoundToAll(SND_GATLING, pet, SNDCHAN_AUTO, SNDLEVEL_MINIBIKE, _, 0.30,
                       GetRandomInt(115, 140));
}

bool ChampOwnerLowHP(int client, float frac)
{
    int hp = GetClientHealth(client) + RoundToCeil(L4D_GetTempHealth(client));
    int max = GetEntProp(client, Prop_Send, "m_iMaxHealth");
    return (float(hp) <= float(max) * frac);
}

// cadena de rayos de Storm (P): salta hasta 3 veces
void Champ_ThunderChain(int client, int pet, const float petHead[3], int target, const float targetPos[3], const int col[4])
{
    float zapDmg = ChampBaseDamage(client) * 0.5;
    float from[3];
    from[0] = targetPos[0];
    from[1] = targetPos[1];
    from[2] = targetPos[2] + 40.0;
    ChampFX_Beam(petHead, from, col, 2.0, 0.14);
    ChampDamage(target, client, zapDmg, DMG_SHOCK);

    ArrayList list = new ArrayList();
    int count = PetCommonsInRadius(targetPos, 180.0, list);
    int hops = 0;
    for (int i = 0; i < count && hops < 3; i++)
    {
        int ent = EntRefToEntIndex(list.Get(i));
        if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || ent == target) continue;
        if (!IsEnemyAlive(ent)) continue;
        float cPos[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", cPos);
        cPos[2] += 40.0;
        ChampFX_Beam(from, cPos, col, 1.6, 0.12);
        from = cPos;
        ChampDamage(ent, client, zapDmg * 0.6, DMG_SHOCK);
        hops++;
    }
    delete list;
    if (g_bChampZapSnd) EmitSoundToAll(SND_CHAMP_ZAP, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.6);
}

// ----------------------------------------------------------------------------
// HELPERS DE TARGETING
// ----------------------------------------------------------------------------
int ChampCountEnemies(const float pos[3], float radius)
{
    ArrayList list = new ArrayList();
    int count = PetEnemiesInRadius(pos, radius, list);
    delete list;
    return count;
}

int ChampFarthestEnemy(const float pos[3], float radius)
{
    ArrayList list = new ArrayList();
    int count = PetEnemiesInRadius(pos, radius, list);
    int best = -1;
    float bestDist = -1.0;
    for (int i = 0; i < count; i++)
    {
        int ent = list.Get(i);
        if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent)) continue;
        if (!IsEnemyAlive(ent)) continue;
        float vPos[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        float d = GetVectorDistance(pos, vPos);
        if (d > bestDist) { bestDist = d; best = ent; }
    }
    delete list;
    return best;
}

// enemigos DENTRO de una linea (skillshots: Vex Q, Ornn R)
int ChampEnemiesInLine(const float from[3], const float end[3], float width, ArrayList list)
{
    float dir[3];
    MakeVectorFromPoints(from, end, dir);
    dir[2] = 0.0;
    float len = GetVectorLength(dir);
    if (len < 1.0) return 0;
    NormalizeVector(dir, dir);

    ArrayList all = new ArrayList();
    int count = PetEnemiesInRadius(from, len + 60.0, all);
    int found = 0;
    for (int i = 0; i < count; i++)
    {
        int ent = all.Get(i);
        if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
        float vPos[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        float rel[3];
        MakeVectorFromPoints(from, vPos, rel);
        rel[2] = 0.0;
        float proj = GetVectorDotProduct(rel, dir);
        if (proj < -40.0 || proj > len + 40.0) continue;   // fuera de la linea
        float perp[3];
        perp[0] = rel[0] - dir[0] * proj;
        perp[1] = rel[1] - dir[1] * proj;
        perp[2] = 0.0;
        if (GetVectorLength(perp) > width) continue;       // muy lateral
        list.Push(ent);
        found++;
    }
    delete all;
    return found;
}

// enemigos en un CONO frontal (Spyro W, Ember W, Poppy R)
int ChampEnemiesInCone(const float origin[3], const float dirTo[3], float range, ArrayList list)
{
    float dir[3];
    dir[0] = dirTo[0];
    dir[1] = dirTo[1];
    dir[2] = 0.0;
    if (GetVectorLength(dir) < 0.001) { dir[0] = 1.0; dir[1] = 0.0; }
    NormalizeVector(dir, dir);

    ArrayList all = new ArrayList();
    int count = PetEnemiesInRadius(origin, range, all);
    int found = 0;
    for (int i = 0; i < count; i++)
    {
        int ent = all.Get(i);
        if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
        float vPos[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        float rel[3];
        MakeVectorFromPoints(origin, vPos, rel);
        rel[2] = 0.0;
        if (GetVectorLength(rel) < 1.0) { list.Push(ent); found++; continue; }
        NormalizeVector(rel, rel);
        if (GetVectorDotProduct(rel, dir) > 0.35)   // ~70 grados de apertura
        {
            list.Push(ent);
            found++;
        }
    }
    delete all;
    return found;
}

int ChampNearestSI(const float pos[3], float radius)
{
    int best = -1;
    float bestDist = 99999.0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 3) continue;
        float vPos[3];
        GetClientAbsOrigin(i, vPos);
        float d = GetVectorDistance(pos, vPos);
        if (d <= radius && d < bestDist) { bestDist = d; best = i; }
    }
    return best;
}

int ChampWeakestSI(const float pos[3], float radius)
{
    int best = -1;
    int bestHP = 999999;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 3) continue;
        if (GetEntProp(i, Prop_Send, "m_zombieClass") == 8) continue;   // no marcar tanks
        float vPos[3];
        GetClientAbsOrigin(i, vPos);
        if (GetVectorDistance(pos, vPos) > radius) continue;
        int hp = GetClientHealth(i);
        if (hp < bestHP) { bestHP = hp; best = i; }
    }
    return best;
}

bool ChampTankNear(const float pos[3], float radius)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 3) continue;
        if (GetEntProp(i, Prop_Send, "m_zombieClass") != 8) continue;
        float vPos[3];
        GetClientAbsOrigin(i, vPos);
        if (GetVectorDistance(pos, vPos) <= radius) return true;
    }
    return false;
}

// v51: hay una WITCH a menos de radius de pos? (para decidir la R de Poppy)
bool ChampWitchNear(const float pos[3], float radius)
{
    int ent = -1;
    float vPos[3];
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        if (GetVectorDistance(pos, vPos) <= radius) return true;
    }
    return false;
}

// v51: presa mas cercana para la E de Poppy: especial O witch
int ChampNearestSIOrWitch(const float pos[3], float radius)
{
    int best = -1;
    float bestDist = 99999.0;
    float vPos[3];
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != 3) continue;
        GetClientAbsOrigin(i, vPos);
        float d = GetVectorDistance(pos, vPos);
        if (d <= radius && d < bestDist) { bestDist = d; best = i; }
    }
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", vPos);
        float d = GetVectorDistance(pos, vPos);
        if (d <= radius && d < bestDist) { bestDist = d; best = ent; }
    }
    return best;
}

// v51: ¿el especial esta EMBISTIENDO/volando ahora mismo? (carga del
// charger, hunter a punto de saltar o en pleno vuelo): la zona de la W de
// Poppy lo frena EN SECO, igual que el video de la W
bool Champ_IsDashing(int si)
{
    if (si <= 0 || si > MaxClients || !IsClientInGame(si)) return false;
    if (HasEntProp(si, Prop_Send, "m_isCharging")
        && GetEntProp(si, Prop_Send, "m_isCharging") != 0) return true;
    if (HasEntProp(si, Prop_Send, "m_isAttemptingToPounce")
        && GetEntProp(si, Prop_Send, "m_isAttemptingToPounce") != 0) return true;
    float vVel[3];
    GetEntPropVector(si, Prop_Data, "m_vecVelocity", vVel);
    float spd = SquareRoot(vVel[0] * vVel[0] + vVel[1] * vVel[1]);
    return (spd > 280.0);
}

// ----------------------------------------------------------------------------
// DESPACHO DE KITS (Q/W/E/R/P con IA de prioridades por campeon)
// ----------------------------------------------------------------------------
void Champ_AutoAbilities(int client, int pet, const float petPos[3], const float petHead[3], int target, const float targetPos[3], float dist, float now)
{
    // v63 (v28): SENUO de La Guardiana — con 3+ enemigos cerca y la barra
    // por encima del 25%, Poppy planta el estandarte y los infectados
    // van a por ELLA (bot invisible pegado a su cuerpo: PoppyDecoy_Tick)
    if (g_iChampSel[client] == 1 && g_bPoppyStats && g_bPoppyDecoy
            && g_iDecoyBot[client] == -1 && now >= g_fDecoyNextAt[client]   // v35 (v72): senuo y CD por duena
            && g_fPoppyHP[client] >= PoppyMaxHP(client) * 0.25)
    {
        ArrayList probe = new ArrayList();
        int near = PetEnemiesInRadius(petPos, 250.0, probe);
        delete probe;
        if (near >= 3) PoppyDecoy_Start(client);
    }
    switch (g_iChampSel[client])
    {
        case 0: Champ_Kit_Luna(client, pet, petPos, petHead, targetPos, dist, now);
        case 1: Champ_Kit_Raven(client, pet, petPos, petHead, targetPos, dist, now);
        case 2: Champ_Kit_Snowy(client, pet, petPos, petHead, targetPos, dist, now);
        case 3: Champ_Kit_Spyro(client, pet, petPos, petHead, targetPos, now);
        case 4: Champ_Kit_Ghosty(client, pet, petPos, petHead, targetPos, now);
        case 5: Champ_Kit_Storm(client, pet, petPos, petHead, target, targetPos, dist, now);
        case 6: Champ_Kit_Ember(client, pet, petPos, petHead, targetPos, dist, now);
        case 7: Champ_Kit_Warwick(client, pet, petPos, petHead, target, targetPos, dist, now);
    }
}

// sin objetivo: solo pasivas guardianas (escudos, aura, bloqueo W de Poppy)
void Champ_AutoAbilitiesIdle(int client, int pet, const float petPos[3], const float petHead[3], float now)
{
    switch (g_iChampSel[client])
    {
        case 1: Champ_Kit_RavenGuard(client, pet, petPos, petHead, now);
        case 2: Champ_Kit_SnowyGuard(client, now);
    }
}
// ============================================================================
// v45 FUSION — MODULO CAMPEONES (parte C): kits Raven/Luna/Snowy/Spyro
// ============================================================================
// Kits FIELES a LoL, con efectos graficos en cada habilidad y IA que decide
// cuando lanzarlas (salvar duegna > ultimate > combo > horda > poke).

// ----------------------------------------------------------------------------
// RAVEN (Poppy) — la Guardiana del Martillo, fiel a la especificacion
// ----------------------------------------------------------------------------
// Q Golpe de Martillo: marca de luz que contrae y EXPLOTA quitando % de la
//   vida maxima como dano fisico.
// W Presencia Inquebrantable (v51): AREA de 220 u que SIGUE a Poppy mientras
//   dura (6-10 s): todo enemigo que entra sufre el efecto de Poppy
//   (lentitud) y las embestidas/saltos que la cruzan se frenan EN SECO
//   (stop + stagger + recarga forzada); ademas libera a la duegna si la
//   agarran y bloquea los saltos hacia ella.
// E Carga Heroica (v49/v51/v60): Poppy se TELETRANSPORTA a la presa
//   (especial O witch) y la ARROJA con el vuelo manual (nothink + frozen,
//   el truco de la witch de Amy) — v60: EN AREA, hasta 3 infectados en el
//   alrededor de la presa salen igual; si estrellan contra la pared, el
//   estrellon dorado + stagger.
// R Veredicto del Guardián (v51/v60): CARGA visible que dura LO QUE DURA
//   el audio de carga (45% de las veces la ejecuta rapida en 1 s) y al
//   soltar sale una ONDA: recorre el camino hacia el objetivo — todo
//   infectado de la trayectoria vuela LEJOS — y al llegar detona un area
//   de 350 u (+1.5%/nv) alrededor del objetivo. Contra la PARED: los
//   comunes mueren de una; especiales/witch/tank reciben dano adicional =
//   distancia recorrida + % de vida que les falte (tope 30%) y EJECUCION
//   bajo 5% (+0.5%/nv) de la vida maxima. Encadena la W 12-15 s, CD 22 s,
//   -25% del CD total por especial abatido con Poppy (v52).
// P Embajadora de Hierro: cada 8 s, golpe a distancia +60% (en el ataque).
// v54: ademas tiene VOCES oficiales de LoL (sound/poppy/, FastDL): el
// modulo de voces vive arriba, junto al resto del estado de campeones.

void Champ_Kit_Raven(int client, int pet, const float petPos[3], const float petHead[3], const float targetPos[3], float dist, float now)
{
    int level = g_iChampLevel[client][1];
    int col[4];
    ChampColorOf(1, col);

    // v76: CARGA de la R en curso — Poppy esta clavada sujetando el
    // martillo: NINGUNA otra habilidad se lanza y no golpea (los
    // cooldowns ni se gastan: todo se reintenta al terminar). Solo
    // sigue vivo el aura de la W que ya estuviera corriendo — una
    // zona ya lanzada, con su liberacion de emergencia de la duena
    // (no es una accion nueva de Poppy).
    if (now < g_fChampRavenChargeUntil[client])
    {
    	Champ_RavenW(client, pet, petPos, petHead, now);
    	return;
    }
    // v76: habilidad en curso (cast con lock activo): los lanzamientos
    // nuevos esperan a que su animacion termine — despues se
    // reintentan con su cooldown intacto.
    if (g_iChampAnimPrio[client] == 2 && now < g_fPet_AnimLock[client])
    {
    	Champ_RavenW(client, pet, petPos, petHead, now);
    	return;
    }

    // ---- W primero: SALVAR a la duegna es prioridad 1 ----
    Champ_RavenW(client, pet, petPos, petHead, now);

    // ---- R: Veredicto — horda en cono, especial/witch/tank cerca o duegna agarrada ----
    // v51/v60 secuencia CON CARGA (como la R real): 1. Poppy CARGA el
    //    ataque — v60: la carga dura LO QUE DURA SU AUDIO de carga (la
    //    linea rcharge de ~4.1 s) y 45% de las veces la ejecuta rapida en
    //    1 s sin esperar la linea completa; 2. al SOLTARLO sale la ONDA:
    //    recorre el camino hacia el objetivo y TODO infectado de la
    //    trayectoria vuela lejos; al llegar detona un AREA de 450 u
    //    (+1.5%/nv) alrededor del objetivo y los de ahi tambien vuelan;
    //    3. contra la PARED: comunes muertos de una, especiales/witch/tank
    //    con dano adicional (distancia + vida que falte, tope 30%) y
    //    EJECUCION bajo 5% (+0.5%/nv) de la vida max. La W queda
    //    encadenada 12-15 s. CD 22 s desde la carga; cada especial
    //    abatido lo rebaja 25% del total (4 bajas = recargada) —
    //    Champ_CreditKill (v52).
    if (now >= g_fChampNextR[client] && now >= g_fChampRavenChargeUntil[client])
    {
        float dir[3];
        MakeVectorFromPoints(petPos, targetPos, dir);
        ArrayList list = new ArrayList();
        int count = ChampEnemiesInCone(petPos, dir, 320.0, list);
        delete list;   // solo cuenta para decidir: la onda barre AL SOLTAR
        bool grabbed = IsPlayerGrabbed(client);
        if (count >= 2 || ChampNearestSI(petPos, 350.0) > 0 || ChampWitchNear(petPos, 350.0)
            || ChampTankNear(petPos, 450.0) || (grabbed && count >= 1))
        {
            g_fChampNextR[client] = now + 22.0;             // v49: CD fijo de 22 s
            Poppy_Voice(pet, POPPY_VRCH);   // v54: grito de CARGA del veredicto

            // v60: el tiempo de espera depende del AUDIO que salio: la R se
            // lanza cuando TERMINA la linea de carga (rcharge1/rcharge2 =
            // 4.1-4.2 s); 45% de las veces la ejecuta rapida en 1 s
            float chargeT = g_fPoppyLastVoiceDur;
            if (chargeT <= 0.0) chargeT = 1.4;              // sin audio: carga clasica
            if (GetRandomInt(1, 100) <= 45) chargeT = 1.0;  // ejecucion veloz
            else
            {
                if (chargeT < 1.0) chargeT = 1.0;
                if (chargeT > 4.2) chargeT = 4.2;
            }
            g_fChampRavenChargeUntil[client] = now + chargeT;   // fase de CARGA
            Champ_CastAnim(client, 4);   // v75: windup real 5.90 s — CARGA de la R; se corta al lanzar

            // telegrafo dorado creciendo alrededor de Poppy (v53: 320 u =
            // cono REAL de la R, distinto del anillo de 220 de la W)
            ChampFX_Ring(petPos, 320.0, col, 1.2);
            ChampFX_Pillar(petPos, col, 220.0);
            ChampFX_Particle(petPos, "gas_explosion_ground_wave", 1.0);
            ChampFX_FadeToOwner(client, 255, 200, 60);
            PoppyEmitLoud3(POP_R1, pet, SND_GLASS, SNDLEVEL_GUNFIRE, SNDCHAN_WEAPON, SNDCHAN_STATIC, SNDCHAN_ITEM);   // v77: plantado del martillo — TRIPLE canal (que se NOTE la carga)
            CPrintToChat(client, "{green}[%s]{default} {olive}VEREDICTO DEL GUARDIÁN{default}: ¡cargando el ataque...!",
                g_sChampNames[1]);

            DataPack pack = new DataPack();
            pack.WriteCell(GetClientUserId(client));
            pack.WriteCell(level);
            CreateTimer(chargeT, Timer_ChampVerdictRelease, pack,
                        TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
        }
    }

    // ---- Q: Golpe de Martillo — marca de luz que detona % vida max ----
    // v77 (duena): alcance +50% — dispara a 480 u, la marca cae a 195 u
    // de Poppy y detona en 255 u (llega a 450 en vez de 300)
    if (now >= g_fChampNextQ[client] && dist <= 480.0)
    {
        g_fChampNextQ[client] = now + ChampCD(client, 9.0);
        Champ_CastAnim(client, 0);   // v75: crit 1.50 s — martillazo del MDL real (windup ya es de la R)
        Poppy_Voice(pet, POPPY_VQ);  // v54: voz del martillazo
        PoppyEmitLoud(POP_Q2, pet, "", SNDLEVEL_GUNFIRE, SNDCHAN_WEAPON, SNDCHAN_STATIC);   // v36: rescoldo de la marca — fuerte (antes 0.55/90 dB: casi nada)

        // v48: la marca se abre EN EL FRENTE de Poppy (como el Q real de
        // LoL) y se contrae como telegrafo de 0.6 s
        float dirQ[3], zone[3];
        MakeVectorFromPoints(petPos, targetPos, dirQ);
        dirQ[2] = 0.0;
        if (GetVectorLength(dirQ) < 0.001) { dirQ[0] = 1.0; dirQ[1] = 0.0; }
        NormalizeVector(dirQ, dirQ);
        PetFaceYaw(client, dirQ);   // v77 (duena): mira hacia donde activo el golpe
        zone[0] = petPos[0] + dirQ[0] * 195.0;   // v77: +50% de alcance
        zone[1] = petPos[1] + dirQ[1] * 195.0;
        zone[2] = petPos[2];
        ChampFX_Beam(petHead, zone, col, 3.0, 0.35);   // v48: linea del golpe
        ChampFX_RingIn(zone, 255.0, col);   // v77: telegrafo del area nueva (+50%)

        DataPack pack = new DataPack();
        pack.WriteCell(GetClientUserId(client));
        pack.WriteCell(level);
        pack.WriteFloat(zone[0]);
        pack.WriteFloat(zone[1]);
        pack.WriteFloat(zone[2]);
        pack.WriteCell(col[0]);
        pack.WriteCell(col[1]);
        pack.WriteCell(col[2]);
        pack.WriteCell(col[3]);
        CreateTimer(0.6, Timer_ChampHammerShock, pack,
                    TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
    }

    // ---- E: Carga Heroica — especial o witch a media distancia ----
    // v49: Poppy se TELETRANSPORTA a la presa y la ARROJA con el vuelo
    // manual (nothink + frozen + integracion propia — en el piso hay
    // muchisima mas friccion y cuesta moverlos; el truco de la witch de
    // Amy con su embestida/martillazo). Si la presa se estrella contra una
    // PARED: el estrellon dorado + stagger. Sin pared: solo el empujon.
    // v51: la presa tambien puede ser la WITCH (la E la levanta igual).
    // v60: MAS PODEROSA y EN AREA — la presa y hasta 2 infectados mas que
    // esten en su alrededor (170 u, max 3) salen volando hacia la pared.
    if (now >= g_fChampNextE[client])
    {
        int si = ChampNearestSIOrWitch(petPos, 550.0);
        if (si > 0)
        {
            float siPos[3];
            if (si > MaxClients) GetEntPropVector(si, Prop_Send, "m_vecOrigin", siPos);
            else GetClientAbsOrigin(si, siPos);
            if (GetVectorDistance(petPos, siPos) > 200.0)
            {
                g_fChampNextE[client] = now + ChampCD(client, 15.0);
                Champ_CastAnim(client, 2);   // v75: attack3 1.10 s — la anim REAL de la E en LoL

                // 1. TELETRASPORTE de Poppy justo delante de la presa
                float vDir[3];
                MakeVectorFromPoints(petPos, siPos, vDir);
                vDir[2] = 0.0;
                if (GetVectorLength(vDir) < 0.001) { vDir[0] = 0.0; vDir[1] = 1.0; vDir[2] = 0.0; }
                NormalizeVector(vDir, vDir);
                float dest[3];
                dest[0] = siPos[0] - vDir[0] * 55.0;
                dest[1] = siPos[1] - vDir[1] * 55.0;
                dest[2] = siPos[2];
                TeleportEntity(pet, dest, NULL_VECTOR, NULL_VECTOR);
                SnapPetToGround(client);
                PetFaceYaw(client, vDir);   // v77 (duena): mira hacia donde embistio
                ChampFX_Beam(petHead, dest, col, 3.0, 0.4);   // rastro del parpadeo
                float bPos[3];
                bPos[0] = dest[0]; bPos[1] = dest[1]; bPos[2] = dest[2] + 30.0;
                ChampFX_Burst(bPos, col);
                ChampFX_Particle(dest, "tank_rock_throw_impact", 0.8);   // polvo de llegada

                // v60: AREA de la embestida — la presa y hasta 2 infectados
                // mas en su alrededor (max 3) salen volando igual
                int targets[3];
                int nT = 0;
                targets[nT] = si;
                nT++;
                ArrayList area = new ArrayList();
                PetEnemiesInRadius(siPos, 170.0, area);
                for (int a = 0; a < area.Length && nT < 3; a++)
                {
                    int ent = area.Get(a);
                    if (ent == si || ent <= 0 || ent >= 2048 || !IsValidEntity(ent)) continue;
                    if (!IsEnemyAlive(ent) || g_bChampFlying[ent]) continue;
                    targets[nT] = ent;
                    nT++;
                }
                delete area;

                // 2. golpe de entrada (antes del hielo) + LEVANTA Y TIRA:
                // v60 mas poderosa (30+3.0/nv de entrada, 45+4.5/nv al caer)
                for (int t = 0; t < nT; t++)
                {
                    int ent = targets[t];
                    ChampDamage(ent, client, 30.0 + 3.0 * float(level), DMG_CLUB);
                    if (t == 0) PoppyBoneCrack(ent);   // v77: huesos del golpe de entrada (la presa)
                    if (!IsEnemyAlive(ent)) continue;   // el golpe de entrada lo mato
                    float vVel[3];
                    vVel[0] = vDir[0] * 720.0;
                    vVel[1] = vDir[1] * 720.0;
                    vVel[2] = 380.0;
                    Champ_FlightLaunch(ent, client, vVel, 45.0 + 4.5 * float(level),
                                       CHAMP_FLIGHT_PUSH, 2.4);
                }

                PoppyEmitLoud(POP_E1, pet, SND_GLASS, SNDLEVEL_GUNFIRE, SNDCHAN_BODY, SNDCHAN_VOICE_BASE);   // v36: embestida de la E (se desplaza y empuja) — doble canal 140 dB
                char siName[16];
                if (si > MaxClients) strcopy(siName, sizeof(siName), "la Witch");
                else PetSIName(si, siName, sizeof(siName));
                if (nT > 1)
                    CPrintToChat(client, "{green}[%s]{default} {olive}Carga Heroica{default}: embiste y arrojas a {olive}%s{default} (+%d en el area).",
                        g_sChampNames[1], siName, nT - 1);
                else
                    CPrintToChat(client, "{green}[%s]{default} {olive}Carga Heroica{default}: embiste y arrojas a {olive}%s{default}.",
                        g_sChampNames[1], siName);
            }
        }
    }
}

// detona el Golpe de Martillo: dano = % de la vida maxima (fisico)
public Action Timer_ChampHammerShock(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int client = GetClientOfUserId(pack.ReadCell());
    int level = pack.ReadCell();
    float pos[3];
    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();
    int col[4];
    col[0] = pack.ReadCell();
    col[1] = pack.ReadCell();
    col[2] = pack.ReadCell();
    col[3] = pack.ReadCell();

    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;

    float zone[3];
    zone[0] = pos[0];
    zone[1] = pos[1];
    zone[2] = pos[2];

    // explosion dorada (v48: con particulas REALES del juego)
    float fx[3];
    fx[0] = zone[0];
    fx[1] = zone[1];
    fx[2] = zone[2] + 25.0;
    ChampFX_Burst(fx, col);
    ChampFX_Pillar(fx, col, 160.0);
    ChampFX_Shake(fx, 8, 350, 0.5);
    ChampFX_Particle(fx, "tank_rock_throw_impact", 1.0);     // v48: polvo del martillazo
    ChampFX_Particle(fx, "weapon_grenade_explosion", 1.0);   // v48: detonacion
    // v27: golpe principal del martillo, desde el cuerpo de la mascota
    int qpet = (IsPetValid(client)) ? EntRefToEntIndex(g_iPet_Entity[client]) : -1;
    PoppyEmitLoud3(POP_Q1, (qpet > 0 && IsValidEntity(qpet)) ? qpet : client,
              SND_MISSILE1, SNDLEVEL_GUNFIRE, SNDCHAN_WEAPON, SNDCHAN_STATIC, SNDCHAN_ITEM);   // v77: TRIPLE canal — la duena quiere que el Q SE NOTE

    // % de vida maxima como dano fisico (+minimo para comunes)
    // v48: mas jugo — 6% base (+0.12%/nv, 12% a Nv 50)
    float pct = 0.06 + 0.0012 * float(level);
    float minDmg = 30.0 + 3.0 * float(level);
    ArrayList list = new ArrayList();
    int count = PetEnemiesInRadius(fx, 255.0, list);   // v77: +50% de area (duena)
    int hits = 0;
    int firstHit = -1;
    for (int i = 0; i < count; i++)
    {
        int ent = list.Get(i);
        if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
        ChampDamagePct(ent, client, pct, minDmg, DMG_CLUB);
        AddSlow(ent, 2.0);
        ChampFX_Glow(ent, 0x3CC8FF, 1.5);   // v48: marca dorada (BGR)
        if (firstHit == -1) firstHit = ent;
        hits++;
    }
    delete list;
    if (firstHit > 0) PoppyBoneCrack(firstHit);   // v77: el martillazo ROMPE huesos

    if (hits > 0)
        CPrintToChat(client, "{green}[%s]{default} {olive}Golpe de Martillo{default}: %d enemigos — %.0f%% de su vida maxima.",
            g_sChampNames[1], hits, pct * 100.0);
    return Plugin_Stop;
}

// v51/v60: la R de Poppy se SUELTA tras la carga (v60: la carga dura lo
// que dura su audio; 45% de las veces la ejecuta rapida en 1 s) y el
// martillo sale VOLANDO: una ONDA recorre el camino hacia el objetivo —
// TODO infectado de la trayectoria (comun, especial, witch o tank) sale
// despedido lejos; al llegar al objetivo detona un AREA de 450 u
// (+1.5%/nv) a su alrededor y los de esa area tambien vuelan. Contra la
// PARED: comunes muertos; especiales/witch/tank con dano adicional =
// distancia recorrida + % de vida que falte (tope 30%) y EJECUCION bajo
// 5% (+0.5%/nv). La W queda encadenada 12-15 s.
public Action Timer_ChampVerdictRelease(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int client = GetClientOfUserId(pack.ReadCell());
    int level = pack.ReadCell();

    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)
        || !IsPetValid(client))
        return Plugin_Stop;   // la carga se pierde (duegna caida / campeon retirado)

    int pet = EntRefToEntIndex(g_iPet_Entity[client]);
    if (pet <= 0 || !IsValidEntity(pet)) return Plugin_Stop;

    int col[4];
    ChampColorOf(1, col);
    float petPos[3];
    GetEntPropVector(pet, Prop_Data, "m_vecOrigin", petPos);

    // direccion de la onda: hacia la presa ACTUAL o el frente de Poppy
    float dir[3];
    int target = EntRefToEntIndex(g_iChampTarget[client]);
    bool haveDir = false;
    if (target > 0 && target < 2048 && IsValidEntity(target))
    {
        float tPos[3];
        GetEntPropVector(target, Prop_Send, "m_vecOrigin", tPos);
        MakeVectorFromPoints(petPos, tPos, dir);
        haveDir = true;
    }
    if (!haveDir)
    {
        float ang[3];
        GetEntPropVector(pet, Prop_Data, "m_angRotation", ang);
        GetAngleVectors(ang, dir, NULL_VECTOR, NULL_VECTOR);
    }
    dir[2] = 0.0;
    if (GetVectorLength(dir) < 0.001) { dir[0] = 1.0; dir[1] = 0.0; }
    NormalizeVector(dir, dir);

    // v60: recorrido de la onda — hasta la presa (min 400, tope 1200 u);
    // sin presa valida, 900 u al frente
    float maxDist = 900.0;
    int targetRef = -1;
    if (haveDir && target > 0 && target < 2048 && IsValidEntity(target)
        && IsEnemyAlive(target))
    {
        float tPos[3];
        GetEntPropVector(target, Prop_Send, "m_vecOrigin", tPos);
        maxDist = GetVectorDistance(petPos, tPos);
        if (maxDist < 400.0) maxDist = 400.0;
        if (maxDist > 1200.0) maxDist = 1200.0;
        targetRef = EntIndexToEntRef(target);
    }

    // martillazo epico al soltar
    Champ_CastAnim(client, 3);   // v75: recall confirmado — v77: 1.0 s de pose y Poppy vuelve a la accion
    ChampFX_Ring(petPos, 320.0, col, 0.8);
    ChampFX_Pillar(petPos, col, 300.0);
    ChampFX_Particle(petPos, "gas_explosion_ground_wave", 1.2);   // v48: onda expansiva real
    ChampFX_Shake(petPos, 14, 500, 0.9);
    PoppyEmitLoud3(POP_R3, pet, SND_MISSILE2, SNDLEVEL_ROCKET, SNDCHAN_WEAPON, SNDCHAN_STATIC, SNDCHAN_ITEM);   // v77: LANZAMIENTO del veredicto — poppy_r3 a TRIPLE canal 180 dB (la r2 se reserva para el MAZAZO)
    Poppy_Voice(pet, POPPY_VRL);   // v54: "And stay there!"

    // v77 (duena): ARCO DE SALIDA — el ataque inicial del veredicto es en
    // ARCO: todo el cono frontal (320 u) come el golpe de una, sin
    // esperar a que la onda los alcance por el camino
    ArrayList arc = new ArrayList();
    int arcN = ChampEnemiesInCone(petPos, dir, 320.0, arc);
    for (int a = 0; a < arcN; a++)
        ChampVerdictWaveLaunch(arc.Get(a), client, level, dir);
    delete arc;

    // v49/v51: el Veredicto encadena la W (guardia ampliada 12-15 s)
    float now = GetGameTime();
    float fDurWR = 12.0 + 0.1 * float(level - 1);
    if (fDurWR > 15.0) fDurWR = 15.0;
    g_fChampRavenWUntil[client] = now + fDurWR;
    g_fChampNextW[client] = now + fDurWR + ChampCD(client, 12.0);

    // v60: la ONDA del Veredicto — recorre el camino y arrastra a todos
    DataPack wave = new DataPack();
    wave.WriteCell(GetClientUserId(client));
    wave.WriteCell(level);
    wave.WriteFloat(petPos[0]);
    wave.WriteFloat(petPos[1]);
    wave.WriteFloat(petPos[2]);
    wave.WriteFloat(dir[0]);
    wave.WriteFloat(dir[1]);
    wave.WriteFloat(dir[2]);
    wave.WriteFloat(0.0);         // avance actual de la onda
    wave.WriteFloat(maxDist);
    wave.WriteCell(targetRef);
    wave.WriteCell(0);            // enemigos lanzados
    CreateTimer(0.1, Timer_ChampVerdictWave, wave,
                TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);

    CPrintToChat(client, "{green}[%s]{default} {olive}VEREDICTO DEL GUARDIÁN{default}: ¡martillo lanzado! La onda arrastra a todo infectado de su camino.",
        g_sChampNames[1]);
    return Plugin_Stop;
}

// v60: lanza a un enemigo con la onda del Veredicto: golpe de entrada
// (comunes al 99%; boomer exento) + vuelo LEJOS en la direccion de la onda.
// Devuelve true si salio volando.
bool ChampVerdictWaveLaunch(int ent, int client, int level, const float dir[3])
{
    if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) return false;
    if (g_bChampFlying[ent]) return false;   // ya esta volando

    // 1. golpe de entrada (todavia sin hielo: el dano ENTRA)
    bool bBoomer = (ent <= MaxClients && IsClientInGame(ent)
        && GetEntProp(ent, Prop_Send, "m_zombieClass") == 2);
    if (!bBoomer)
    {
        if (ent > MaxClients)
        {
            char cls[16];
            GetEntityClassname(ent, cls, sizeof(cls));
            if (StrEqual(cls, "infected", false))
                ChampDamagePct(ent, client, 0.99, 5.0, DMG_CLUB);   // comun: 99% de su vida
            else
                ChampDamage(ent, client, 30.0 + 3.0 * float(level), DMG_CLUB);   // witch
        }
        else
            ChampDamage(ent, client, 30.0 + 3.0 * float(level), DMG_CLUB);
    }
    if (!IsEnemyAlive(ent)) return false;

    // 2. vuela LEJOS en la direccion de la onda (v60: TODOS salen
    // despedidos, no solo los comunes; el tank es demasiado pesado)
    float vVel[3];
    float maxAir;
    bool bTank = (ent <= MaxClients && IsClientInGame(ent)
        && GetEntProp(ent, Prop_Send, "m_zombieClass") == 8);
    if (ent > MaxClients)
    {
        char cls[16];
        GetEntityClassname(ent, cls, sizeof(cls));
        if (StrEqual(cls, "infected", false))
        {
            vVel[0] = dir[0] * 1150.0; vVel[1] = dir[1] * 1150.0; vVel[2] = 450.0;
            maxAir = 3.2;
        }
        else
        {
            vVel[0] = dir[0] * 900.0; vVel[1] = dir[1] * 900.0; vVel[2] = 500.0;   // witch
            maxAir = 3.0;
        }
    }
    else if (bTank)
    {
        vVel[0] = dir[0] * 650.0; vVel[1] = dir[1] * 650.0; vVel[2] = 620.0;
        maxAir = 3.0;
    }
    else
    {
        vVel[0] = dir[0] * 1000.0; vVel[1] = dir[1] * 1000.0; vVel[2] = 480.0;
        maxAir = 2.8;
    }
    Champ_FlightLaunch(ent, client, vVel, 30.0 + 3.0 * float(level),
                       CHAMP_FLIGHT_VERDICT, maxAir);
    return true;
}

// v60: la ONDA del Veredicto: avanza 1500 u/s barriendo el camino; cada
// infectado a menos de 170 u del frente sale volando; al llegar al objetivo
// (o al final del camino) detona el AREA de 450 u (+1.5%/nv) alrededor del
// objetivo y arrastra a los de alrededor. Los que estrellan contra la pared
// caen en Champ_FlightWallVerdict (el FINISH).
public Action Timer_ChampVerdictWave(Handle timer, any data)
{
    DataPack wave = view_as<DataPack>(data);
    wave.Reset();
    int client = GetClientOfUserId(wave.ReadCell());
    int level = wave.ReadCell();
    float start[3];
    start[0] = wave.ReadFloat();
    start[1] = wave.ReadFloat();
    start[2] = wave.ReadFloat();
    float dir[3];
    dir[0] = wave.ReadFloat();
    dir[1] = wave.ReadFloat();
    dir[2] = wave.ReadFloat();
    float curDist = wave.ReadFloat();
    float maxDist = wave.ReadFloat();
    int targetRef = wave.ReadCell();
    int hits = wave.ReadCell();

    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
        return Plugin_Stop;   // la duegna cayo: la onda se disipa

    curDist += 150.0;   // 1500 u/s (tick de 0.1 s)
    if (curDist > maxDist) curDist = maxDist;

    float front[3];
    front[0] = start[0] + dir[0] * curDist;
    front[1] = start[1] + dir[1] * curDist;
    front[2] = start[2] + 20.0;

    int col[4];
    ChampColorOf(1, col);

    // barrido del frente: todo infectado en el paso de la onda vuela
    ArrayList list = new ArrayList();
    PetEnemiesInRadius(front, 170.0, list);
    for (int i = 0; i < list.Length; i++)
    {
        int ent = list.Get(i);
        if (ChampVerdictWaveLaunch(ent, client, level, dir)) hits++;
    }
    delete list;

    // rastro visible de la onda
    ChampFX_Ring(front, 90.0, col, 0.25);
    ChampFX_Sparks(front, col);

    if (curDist >= maxDist)
    {
        // DETONACION: el AREA alrededor del objetivo (su posicion ACTUAL)
        int target = EntRefToEntIndex(targetRef);
        float center[3];
        center[0] = front[0]; center[1] = front[1]; center[2] = front[2];
        if (target > 0 && target < 2048 && IsValidEntity(target) && IsEnemyAlive(target))
            GetEntPropVector(target, Prop_Send, "m_vecOrigin", center);

        // v77 (duena): area mediana de 450 u alrededor de donde cayo el
        // objetivo — todo el de dentro come el mazaso del veredicto
        float radius = 450.0 * (1.0 + 0.015 * float(level - 1));

        ArrayList area = new ArrayList();
        PetEnemiesInRadius(center, radius, area);
        for (int i = 0; i < area.Length; i++)
        {
            int ent = area.Get(i);
            if (ChampVerdictWaveLaunch(ent, client, level, dir)) hits++;
        }
        delete area;

        // explosion del impacto
        float cPos[3];
        cPos[0] = center[0]; cPos[1] = center[1]; cPos[2] = center[2] + 20.0;
        ChampFX_Ring(cPos, radius, col, 0.8);
        ChampFX_Pillar(cPos, col, 320.0);
        ChampFX_Particle(cPos, "gas_explosion_ground_wave", 1.2);
        ChampFX_Burst(cPos, col);
        ChampFX_Shake(cPos, 14, 500, 0.9);
        PoppyEmitLoud3(POP_R2, client, SND_MISSILE2, SNDLEVEL_ROCKET, SNDCHAN_WEAPON, SNDCHAN_STATIC, SNDCHAN_ITEM);   // v77 (duena): poppy_r2 = EL sonido del mazazo — FUERTE y UNA sola vez (pegue a 1 o a 20, sin saturar)

        if (hits > 0)
            CPrintToChat(client, "{green}[%s]{default} {olive}VEREDICTO DEL GUARDIÁN{default}: %d enemigos {olive}a volar{default} (trayectoria + area de %.0f u). Contra la pared: comunes muertos, el resto {olive}ejecutable{default}.",
                g_sChampNames[1], hits, radius);
        else
            CPrintToChat(client, "{green}[%s]{default} {olive}VEREDICTO DEL GUARDIÁN{default}: la onda se disipo sin enemigos (area de %.0f u).",
                g_sChampNames[1], radius);
        return Plugin_Stop;   // el DataPack lo cierra TIMER_DATA_HNDL_CLOSE
    }

    // guarda el estado y sigue avanzando
    wave.Reset();
    wave.WriteCell(GetClientUserId(client));
    wave.WriteCell(level);
    wave.WriteFloat(start[0]);
    wave.WriteFloat(start[1]);
    wave.WriteFloat(start[2]);
    wave.WriteFloat(dir[0]);
    wave.WriteFloat(dir[1]);
    wave.WriteFloat(dir[2]);
    wave.WriteFloat(curDist);
    wave.WriteFloat(maxDist);
    wave.WriteCell(targetRef);
    wave.WriteCell(hits);
    return Plugin_Continue;
}

// ---- W: Presencia Inquebrantable — el AREA dorada que sigue a Poppy (v51) ----
// v51 fiel al video de la W: mientras la ventana esta activa (6 s en Nv 1
// -> 10 s en Nv 50), Poppy arrastra consigo una ZONA de 220 u que la SIGUE.
// TODO enemigo que entra sufre el efecto de Poppy: lentitud (velocidad
// recortada mientras este dentro). Y el que EMBISTE o entra VOLANDO
// (hunter/jockey/charger en pleno salto o carga) se frena EN SECO: stop +
// stagger + habilidad en recarga forzada + castigo. Ademas sigue
// protegiendo a la duegna: si la agarran se libera y los saltos hacia
// ella se bloquean a 650 u. Recarga: 12 s tras cerrar la ventana; el
// Veredicto (R) la encadena 12 s (+0.1/nv, tope 15 s).
void Champ_RavenW(int client, int pet, const float petPos[3], const float petHead[3], float now)
{
    int level = g_iChampLevel[client][1];
    int col[4];
    ChampColorOf(1, col);

    // ---- ventana ACTIVA: el area dorada que sigue a Poppy ----
    if (now < g_fChampRavenWUntil[client])
    {
        // 1. telegrafo visible de la zona (anillo pulsante donde esta Poppy)
        if (now >= g_fChampAuraFxAt[client])
        {
            g_fChampAuraFxAt[client] = now + 0.5;
            float zone[3];
            zone[0] = petPos[0];
            zone[1] = petPos[1];
            zone[2] = petPos[2] + 10.0;
            ChampFX_Ring(zone, 220.0, col, 0.55);
            ChampFX_Sparks(zone, col);   // v57: esquirlas doradas de la guardia (sin la linea morada)
        }

        // 2. la duegna agarrada se libera SIEMPRE
        if (IsPlayerGrabbed(client)) ChampBlock_Release(client);

        // 3. salto entrante hacia la duegna (alcance de guardia 650 u)
        int threat = Champ_FindIncomingLeap(client);
        if (threat > 0) Champ_RavenWBlock(client, pet, petPos, petHead, threat, level, col);

        // 4. TODO enemigo dentro del AREA sufre el efecto de Poppy
        ArrayList zoneList = new ArrayList();
        int zcount = PetEnemiesInRadius(petPos, 220.0, zoneList);

        // v36 (usuario): con MIN 2 comunes vivos dentro de la zona, la W
        // los STAGGER. Para comunes el stagger canonico de este plugin es
        // el hielo breve — que ademas NIEGA el dano mientras dura: cumple
        // literal el "los stagger pero no les hara dano". Cadencia de 1.5 s
        // por comun: mientras sigan siendo 2+, se re-congelan al despertar.
        int nZoneCommons = 0;
        for (int i = 0; i < zcount; i++)
        {
            int ent = zoneList.Get(i);
            if (ent <= MaxClients || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
            char zcls[16];
            if (!GetEntityClassname(ent, zcls, sizeof(zcls))) continue;
            if (StrEqual(zcls, "infected", false)) nZoneCommons++;
        }
        if (nZoneCommons >= 2)
        {
            for (int i = 0; i < zcount; i++)
            {
                int ent = zoneList.Get(i);
                if (ent <= MaxClients || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
                if (g_bChampFlying[ent] || g_bChampFrozen[ent]) continue;
                if (now < g_fChampWGuardAt[ent]) continue;
                char zcls[16];
                if (!GetEntityClassname(ent, zcls, sizeof(zcls))) continue;
                if (!StrEqual(zcls, "infected", false)) continue;
                g_fChampWGuardAt[ent] = now + 1.5;
                Champ_SetStagger(ent, pet, petPos, 1.2);
            }
        }

        for (int i = 0; i < zcount; i++)
        {
            int ent = zoneList.Get(i);
            if (ent <= 0 || ent >= 2048 || !IsValidEntity(ent) || !IsEnemyAlive(ent)) continue;
            if (g_bChampFlying[ent] || g_bChampFrozen[ent]) continue;   // en el aire/hielo: ya neutralizados

            if (ent <= MaxClients)
            {
                int zclass = GetEntProp(ent, Prop_Send, "m_zombieClass");
                if ((zclass == 3 || zclass == 5 || zclass == 6) && Champ_IsDashing(ent))
                {
                    // embistio/entro volando en la zona: frenado EN SECO
                    Champ_RavenWBlock(client, pet, petPos, petHead, ent, level, col);
                    continue;
                }
            }
            else if (PoppyWitchZoneCheck(client, ent, pet, petPos, petHead, level, col, now))
                continue;   // v36: la witch corriendo/atacando: interceptada y LEVANTADA
            AddSlow(ent, 0.35);   // el efecto de Poppy: lentitud mientras este dentro
        }
        delete zoneList;
        return;
    }

    // ---- armada: aura sutil de vigilancia alrededor de Poppy ----
    if (now >= g_fChampNextW[client] && now >= g_fChampAuraFxAt[client])
    {
        g_fChampAuraFxAt[client] = now + 2.5;
        float zone[3];
        zone[0] = petPos[0];
        zone[1] = petPos[1];
        zone[2] = petPos[2] + 10.0;
        ChampFX_Ring(zone, 110.0, col, 0.6);
    }

    if (now < g_fChampNextW[client]) return;

    // v76: el cast NUEVO de la W respeta la regla de turnos: si hay una
    // habilidad en curso (o la carga de la R) espera — el cooldown no
    // se gasta, se reintenta al despejar.
    if (g_iChampAnimPrio[client] == 2 && now < g_fPet_AnimLock[client]) return;
    if (now < g_fChampRavenChargeUntil[client]) return;

    // ---- activacion: salto entrante, duegna agarrada o 2+ enemigos cerca ----
    int threat = Champ_FindIncomingLeap(client);
    bool grabbed = IsPlayerGrabbed(client);
    bool crowded = (ChampCountEnemies(petPos, 150.0) >= 2);
    if (threat <= 0 && !grabbed && !crowded) return;

    float fDurW = 6.0 + 4.0 * float(level - 1) / 49.0;   // v48: 6 s (Nv 1) -> 10 s (Nv 50)
    g_fChampRavenWUntil[client] = now + fDurW;
    g_fChampNextW[client] = now + fDurW + ChampCD(client, 12.0);  // recarga tras la ventana
    Champ_CastAnim(client, 1);                                  // v75: taunt real 4.30 s — pose de guardia

    float aPos[3];
    aPos[0] = petPos[0];
    aPos[1] = petPos[1];
    aPos[2] = petPos[2] + 10.0;
    ChampFX_Ring(aPos, 220.0, col, 0.8);
    ChampFX_Pillar(aPos, col, 190.0);
    ChampFX_Particle(aPos, "weapon_grenade_explosion", 1.0);   // v48: estampido real
    ChampFX_FadeToOwner(client, 255, 200, 60);
    PoppyEmitLoud(POP_W1, pet, SND_GLASS, SNDLEVEL_GUNFIRE, SNDCHAN_ITEM, SNDCHAN_STREAM);   // v36: activacion de la W — doble canal 140 dB

    if (threat > 0) Champ_RavenWBlock(client, pet, petPos, petHead, threat, level, col);
    if (IsPlayerGrabbed(client)) ChampBlock_Release(client);   // v47: liberacion definitiva

    CPrintToChat(client, "{green}[%s]{default} {olive}PRESENCIA INQUEBRANTABLE{default}: zona activa %.1f s — quien entre queda frenado y las embestidas se bloquean.",
        g_sChampNames[1], fDurW);
}

// v36 (usuario): la WITCH ya no ignora la Presencia Inquebrantable. Su
// carrera cuenta como embestida — la velocidad se mide por DELTA de
// posicion porque la m_vecVelocity de los NextBots no siempre se
// actualiza — y si ya esta zampandose a un superviviente (pegada a 120 u)
// tambien cuenta como ataque. Al interceptarla: freno en seco, RECIBE
// DANO (antes la W no le hacia nada) y sale LEVANTADA del suelo con el
// vuelo manual del Veredicto (nothink + frozen + integracion propia: el
// parche especial de la witch). Cadencia de 4 s por witch.
bool PoppyWitchZoneCheck(int client, int ent, int pet, const float petPos[3],
    const float petHead[3], int level, const int col[4], float now)
{
    char cls[16];
    if (!GetEntityClassname(ent, cls, sizeof(cls))) return false;
    if (!StrEqual(cls, "witch", false)) return false;    // comunes: no por aqui

    if (now < g_fChampWGuardAt[ent]) return false;      // cadencia de intercepcion
    if (g_bChampFlying[ent] || g_bChampFrozen[ent]) return false;   // ya en el aire/hielo

    // velocidad por delta de posicion (la primera vista solo anota)
    float wPos[3];
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", wPos);
    float wSpd = 0.0;
    if (now > g_fPoppyWZoneLastAt[ent] && now - g_fPoppyWZoneLastAt[ent] <= 1.0)
    {
        float dt = now - g_fPoppyWZoneLastAt[ent];
        float dx = wPos[0] - g_vPoppyWZoneLast[ent][0];
        float dy = wPos[1] - g_vPoppyWZoneLast[ent][1];
        wSpd = SquareRoot(dx * dx + dy * dy) / dt;
    }
    g_vPoppyWZoneLast[ent][0] = wPos[0];
    g_vPoppyWZoneLast[ent][1] = wPos[1];
    g_vPoppyWZoneLast[ent][2] = wPos[2];
    g_fPoppyWZoneLastAt[ent] = now;

    // ¿ya esta atacando? pegada a un superviviente al que va a zamparse
    bool bAttacking = false;
    for (int s = 1; s <= MaxClients && !bAttacking; s++)
    {
        if (s == client || !IsClientInGame(s) || !IsPlayerAlive(s)) continue;
        if (GetClientTeam(s) != 2) continue;
        float sPos[3];
        GetClientAbsOrigin(s, sPos);
        if (GetVectorDistance(wPos, sPos) <= 120.0) bAttacking = true;
    }
    if (wSpd < 220.0 && !bAttacking) return false;      // witch tranquila: solo lentitud

    // ---- INTERCEPCION: freno en seco + dano + LEVANTADA del suelo ----
    g_fChampWGuardAt[ent] = now + 4.0;
    float zero[3] = {0.0, 0.0, 0.0};
    TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, zero);

    // la witch AHORA si recibe el dano de la W (antes no le hacia nada)
    ChampDamage(ent, client, 15.0 + 2.0 * float(level), DMG_CLUB);
    if (!IsEnemyAlive(ent)) return true;

    // y sale LEVANTADA (casi vertical, como el Veredicto contra la witch)
    float lift[3];
    float dirW[3];
    MakeVectorFromPoints(petPos, wPos, dirW);
    dirW[2] = 0.0;
    if (GetVectorLength(dirW) < 0.001) { dirW[0] = 0.0; dirW[1] = 1.0; }
    NormalizeVector(dirW, dirW);
    lift[0] = dirW[0] * 200.0;
    lift[1] = dirW[1] * 200.0;
    lift[2] = 560.0;
    float wHead[3];
    wHead[0] = wPos[0]; wHead[1] = wPos[1]; wHead[2] = wPos[2] + 40.0;
    Champ_FlightLaunch(ent, client, lift, 20.0 + 2.0 * float(level),
                       CHAMP_FLIGHT_VERDICT, 2.6);

    ChampFX_Beam(petHead, wHead, col, 3.2, 0.3);
    ChampFX_Burst(wHead, col);
    ChampFX_Ring(wHead, 120.0, col, 0.7);
    ChampFX_Shake(wPos, 8, 300, 0.5);
    PoppyEmitLoud(POP_W2, pet, SND_GLASS, SNDLEVEL_GUNFIRE, SNDCHAN_ITEM, SNDCHAN_STREAM);
    Poppy_Voice(pet, POPPY_VW);
    CPrintToChat(client, "{green}[%s]{default} {olive}PRESENCIA INQUEBRANTABLE{default}: {olive}la Witch{default} interceptada — dano y levantada.",
        g_sChampNames[1]);
    return true;
}

// v46/v47: bloqueo de un saltador concreto: stop en seco + stagger + castigo.
// v47: cooldown por atacante (sin ametralladora de castigos), recarga forzada
// de su habilidad y liberacion definitiva de la duegna si ya la tenia.
// v51: tambien castiga a quien EMBISTE dentro de la zona de la W (video).
void Champ_RavenWBlock(int client, int pet, const float petPos[3], const float petHead[3],
    int threat, int level, const int col[4])
{
    float now = GetGameTime();
    if (now < g_fChampWGuardAt[threat]) return;   // v47: ya fue castigado hace poco
    g_fChampWGuardAt[threat] = now + 1.0;

    float tPos[3];
    GetClientAbsOrigin(threat, tPos);
    tPos[2] += 40.0;

    // 1. detener el salto EN SECO + recarga forzada de su habilidad
    float zero[3] = {0.0, 0.0, 0.0};
    TeleportEntity(threat, NULL_VECTOR, NULL_VECTOR, zero);
    Champ_SetStagger(threat, pet, petPos, 1.8);
    ChampDisableAbility(threat, 5.0);   // v47: sin re-intento inmediato

    // 2. castigo
    ChampDamage(threat, client, 15.0 + 2.0 * float(level), DMG_CLUB);

    // 3. si ya tenia agarrada a la duegna, se suelta AHORA de verdad
    if (IsPlayerGrabbed(client)) ChampBlock_Release(client);

    // 4. graficos del bloqueo
    ChampFX_Beam(petHead, tPos, col, 3.2, 0.3);
    ChampFX_Ring(tPos, 90.0, col, 0.6);
    ChampFX_Burst(tPos, col);
    ChampFX_Shake(tPos, 6, 250, 0.4);
    PoppyEmitLoud(POP_W2, pet, SND_GLASS, SNDLEVEL_GUNFIRE, SNDCHAN_ITEM, SNDCHAN_STREAM);   // v36: bloqueo de la W — doble canal 140 dB
    Poppy_Voice(pet, POPPY_VW);   // v54: "Not so fast!" (2.5 s entre voces: hunter->jockey no ametralla)

    char siName[16];
    PetSIName(threat, siName, sizeof(siName));
    CPrintToChat(client, "{green}[%s]{default} {olive}PRESENCIA INQUEBRANTABLE{default}: {olive}%s{default} bloqueado en seco.",
        g_sChampNames[1], siName);
}

// guardian sin objetivo: mantiene la W vigilante (zona + bloqueo)
void Champ_Kit_RavenGuard(int client, int pet, const float petPos[3], const float petHead[3], float now)
{
    Champ_RavenW(client, pet, petPos, petHead, now);
}

// ----------------------------------------------------------------------------
// LUNA (Vex) — la Triste Maliciosa: marcas Fatalidad y sombras
// ----------------------------------------------------------------------------
void Champ_Kit_Luna(int client, int pet, const float petPos[3], const float petHead[3], const float targetPos[3], float dist, float now)
{
    int level = g_iChampLevel[client][0];
    int col[4];
    ChampColorOf(0, col);

    // ---- R: Avalancha Siniestra — horda o presa lejana marcada ----
    if (now >= g_fChampNextR[client] && !g_bChampDashing[client])
    {
        bool horde = ChampCountEnemies(petPos, 400.0) >= 3;
        int far = ChampFarthestEnemy(petPos, 600.0);
        if (horde && far > 0)
        {
            g_fChampNextR[client] = now + ChampCD(client, 24.0);
            Champ_CastAnim(client, 2);   // v46: pose de embestida
            Champ_DashStart(client, pet, far, CHAMP_DASH_VEX, 650.0, 1.0);
            CPrintToChat(client, "{green}[%s]{default} {olive}Avalancha Siniestra{default}: Vex se lanza a la sombra.",
                g_sChampNames[0]);
        }
    }

    // ---- Q: Bolido Mestral — skillshot en linea ----
    if (now >= g_fChampNextQ[client] && dist <= 500.0)
    {
        g_fChampNextQ[client] = now + ChampCD(client, 8.0);
        Champ_CastAnim(client, 0);   // v46: bolido
        float dir[3], end[3];
        MakeVectorFromPoints(petPos, targetPos, dir);
        NormalizeVector(dir, dir);
        end[0] = petPos[0] + dir[0] * 500.0;
        end[1] = petPos[1] + dir[1] * 500.0;
        end[2] = petPos[2] + 20.0;

        // grafico: doble beam morado (cuerpo + nucleo)
        ChampFX_Beam(petHead, end, col, 4.0, 0.5);
        int core[4] = {230, 210, 255, 255};
        ChampFX_Beam(petHead, end, core, 1.5, 0.4);
        ChampFX_Particle(end, "smoker_smokecloud_cheap", 1.2);   // v48: humo sombrio del bolido
        EmitSoundToAll(SND_MISSILE1, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.6, 150);

        ArrayList list = new ArrayList();
        int count = ChampEnemiesInLine(petPos, end, 75.0, list);
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (!IsEnemyAlive(ent)) continue;
            ChampDamage(ent, client, 35.0 + 3.5 * float(level), DMG_CLUB);
            AddSlow(ent, 1.5);
            g_fChampDoomUntil[ent] = now + 3.0;   // marca Fatalidad
            g_iChampDoomOwner[ent] = client;
            ChampFX_Glow(ent, 0xAA3CFF, 2.0);
        }
        delete list;
    }

    // ---- W: Espacio Personal — 2+ pegados: nova que empuja ----
    if (now >= g_fChampNextW[client] && ChampCountEnemies(petPos, 120.0) >= 2)
    {
        g_fChampNextW[client] = now + ChampCD(client, 13.0);
        Champ_CastAnim(client, 1);   // v46: nova
        ChampFX_Ring(petPos, 150.0, col, 0.5);
        ChampFX_Burst(petPos, col);
        ChampFX_Particle(petPos, "gas_explosion_ground_wave", 1.0);   // v55: onda de la nova (la explosion_huge_d no renderizaba en el cliente)
        EmitSoundToAll(SND_MISSILE2, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.7, 130);
        ArrayList list = new ArrayList();
        int count = PetEnemiesInRadius(petPos, 130.0, list);
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (!IsEnemyAlive(ent)) continue;
            ChampKnockback(ent, petPos, 380.0);
            ChampDamage(ent, client, 30.0 + 3.0 * float(level), DMG_CLUB);
            g_fChampDoomUntil[ent] = now + 3.0;
            g_iChampDoomOwner[ent] = client;
        }
        delete list;
        CPrintToChat(client, "{green}[%s]{default} {olive}Espacio Personal{default}: fuera de aqui.",
            g_sChampNames[0]);
    }

    // ---- E: Oscuridad Inminente — sombra al mas lejano ----
    if (now >= g_fChampNextE[client])
    {
        int far = ChampFarthestEnemy(petPos, 600.0);
        if (far > 0)
        {
            g_fChampNextE[client] = now + ChampCD(client, 16.0);
            Champ_CastAnim(client, 2);   // v46: sombra
            float fPos[3];
            GetEntPropVector(far, Prop_Send, "m_vecOrigin", fPos);
            fPos[2] += 40.0;
            int dark[4] = {110, 30, 170, 255};
            ChampFX_Beam(petHead, fPos, dark, 2.6, 0.35);
            ChampFX_Pillar(fPos, col, 160.0);
            ChampFX_Particle(fPos, "smoker_smokecloud_cheap", 1.5);   // v48: la sombra brota
            EmitSoundToAll(SND_MISSILE1, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.6, 90);
            ChampDamage(far, client, 40.0 + 4.0 * float(level), DMG_CLUB);
            AddSlow(far, 2.5);
            g_fChampDoomUntil[far] = now + 3.0;
            g_iChampDoomOwner[far] = client;
            ChampFX_Glow(far, 0xAA3CFF, 2.0);
        }
    }
}

// ----------------------------------------------------------------------------
// SNOWY (Anivia) — el Criofenix: congelacion, muro y tormenta
// ----------------------------------------------------------------------------
void Champ_Kit_Snowy(int client, int pet, const float petPos[3], const float petHead[3], const float targetPos[3], float dist, float now)
{
    int level = g_iChampLevel[client][2];
    int col[4];
    ChampColorOf(2, col);

    // ---- P: Renacer — duegna al 35%: escudo de hielo ----
    if (now >= g_fChampNextP[client] && ChampOwnerLowHP(client, 0.35))
    {
        g_fChampNextP[client] = now + 60.0 * g_fChampAbCD;
        float temp = L4D_GetTempHealth(client) + 25.0;
        L4D_SetTempHealth(client, temp);
        float ownerPos[3];
        GetClientAbsOrigin(client, ownerPos);
        ownerPos[2] += 20.0;
        ChampFX_Ring(ownerPos, 120.0, col, 0.8);
        ChampFX_Pillar(ownerPos, col, 160.0);
        ChampFX_FadeToOwner(client, 120, 200, 255);
        EmitSoundToAll(SND_GLASS, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.8, 130);
        CPrintToChat(client, "{green}[%s]{default} {olive}Renacer{default}: escudo de hielo (+25).",
            g_sChampNames[2]);
    }

    // ---- R: Tormenta Glacial — horda grande ----
    if (now >= g_fChampNextR[client] && ChampCountEnemies(petPos, 350.0) >= 4)
    {
        g_fChampNextR[client] = now + ChampCD(client, 28.0);
        Champ_CastAnim(client, 3);   // v46: tormenta
        ChampZone_Start(client, petPos, 300.0, 5.0, 0, 12.0 + float(level));
        ChampFX_Ring(petPos, 300.0, col, 1.0);
        ChampFX_Pillar(petPos, col, 220.0);
        ChampFX_Particle(petPos, "steam_manhole", 1.5);      // v55: vapor helado (la explosion_huge_d no renderizaba en el cliente)
        ChampFX_Particle(petPos, "steam_manhole_b", 1.5);    // v55: segundo chorro del criofenix
        ChampFX_FadeToOwner(client, 120, 200, 255);
        EmitSoundToAll(SND_MISSILE2, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.8, 140);
        CPrintToChat(client, "{green}[%s]{default} {olive}TORMENTA GLACIAL{default}: el criofenix desata el invierno.",
            g_sChampNames[2]);
    }

    // ---- Q: Hielo Destello — linea: congela al primero ----
    if (now >= g_fChampNextQ[client] && dist <= 400.0)
    {
        g_fChampNextQ[client] = now + ChampCD(client, 10.0);
        Champ_CastAnim(client, 0);   // v46: destello
        float dir[3], end[3];
        MakeVectorFromPoints(petPos, targetPos, dir);
        NormalizeVector(dir, dir);
        end[0] = petPos[0] + dir[0] * 400.0;
        end[1] = petPos[1] + dir[1] * 400.0;
        end[2] = petPos[2] + 20.0;

        ChampFX_Beam(petHead, end, col, 3.4, 0.45);
        int core[4] = {220, 245, 255, 255};
        ChampFX_Beam(petHead, end, core, 1.4, 0.35);
        EmitSoundToAll(SND_GLASS, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.7, 160);

        ArrayList list = new ArrayList();
        int count = ChampEnemiesInLine(petPos, end, 65.0, list);
        int first = -1;
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (!IsEnemyAlive(ent)) continue;
            if (first == -1)
            {
                first = ent;
                Champ_Freeze(ent, 1.5 + 0.02 * float(level));   // v48: hielo REAL, tambien para especiales
                g_fChampFrostbiteAt[ent] = now;             // listo para la E (x2.25)
                ChampDamage(ent, client, 35.0 + 3.5 * float(level), DMG_CLUB);
                float ePos[3];
                GetEntPropVector(ent, Prop_Send, "m_vecOrigin", ePos);
                ePos[2] += 20.0;
                ChampFX_Burst(ePos, col);
            }
            else
            {
                AddSlow(ent, 2.5);
                ChampDamage(ent, client, 15.0 + 1.5 * float(level), DMG_CLUB);
            }
        }
        delete list;
    }

    // ---- W: Cristalizar — muro de hielo contra la horda o el peligro ----
    if (now >= g_fChampNextW[client]
        && (ChampCountEnemies(petPos, 300.0) >= 3 || IsPlayerGrabbed(client)))
    {
        g_fChampNextW[client] = now + ChampCD(client, 18.0);
        Champ_CastAnim(client, 1);   // v46: cristalizar

        // el muro se levanta entre la duegna y la amenaza mas cercana
        float wallPos[3];
        GetClientAbsOrigin(client, wallPos);
        int threat = ChampNearestSI(wallPos, 400.0);
        if (threat > 0)
        {
            float tPos[3];
            GetClientAbsOrigin(threat, tPos);
            wallPos[0] = (wallPos[0] + tPos[0]) * 0.5;
            wallPos[1] = (wallPos[1] + tPos[1]) * 0.5;
        }
        wallPos[2] += 10.0;

        // muro visible: 4 pilares + zona congelada 4 s
        for (int k = 0; k < 4; k++)
        {
            float pPos[3];
            pPos[0] = wallPos[0] + ((k % 2 == 0) ? -55.0 : 55.0);
            pPos[1] = wallPos[1] + ((k < 2) ? -55.0 : 55.0);
            pPos[2] = wallPos[2];
            ChampFX_Pillar(pPos, col, 130.0);
        }
        ChampFX_Particle(wallPos, "steam_manhole_b", 4.0);   // v48: vapor del muro de hielo
        ChampFX_Particle(wallPos, "steam_manhole", 4.0);
        ChampZone_Start(client, wallPos, 130.0, 4.0, 1, 8.0 + float(level));
        ChampFX_FadeToOwner(client, 120, 200, 255);
        EmitSoundToAll(SND_GLASS, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 100);
        CPrintToChat(client, "{green}[%s]{default} {olive}Cristalizar{default}: muro de hielo alzado.",
            g_sChampNames[2]);
    }
    // E (Picadura Helada) se resuelve dentro del auto-ataque (critico x2.25)
}

// escudo de Renacer vigilante aunque no haya objetivo
void Champ_Kit_SnowyGuard(int client, float now)
{
    int col[4];
    ChampColorOf(2, col);

    if (now >= g_fChampNextP[client] && ChampOwnerLowHP(client, 0.35))
    {
        g_fChampNextP[client] = now + 60.0 * g_fChampAbCD;
        float temp = L4D_GetTempHealth(client) + 25.0;
        L4D_SetTempHealth(client, temp);
        float ownerPos[3];
        GetClientAbsOrigin(client, ownerPos);
        ownerPos[2] += 20.0;
        ChampFX_Ring(ownerPos, 120.0, col, 0.8);
        ChampFX_FadeToOwner(client, 120, 200, 255);
        CPrintToChat(client, "{green}[%s]{default} {olive}Renacer{default}: escudo de hielo (+25).",
            g_sChampNames[2]);
    }
}

// ----------------------------------------------------------------------------
// SPYRO (Smolder) — el Dragoncito: brasas, fuego y lluvia
// ----------------------------------------------------------------------------
void Champ_Kit_Spyro(int client, int pet, const float petPos[3], const float petHead[3], const float targetPos[3], float now)
{
    int level = g_iChampLevel[client][3];
    int col[4];
    ChampColorOf(3, col);

    // ---- R: Lluvia de Fuego — horda o tank ----
    if (now >= g_fChampNextR[client]
        && (ChampCountEnemies(petPos, 450.0) >= 4 || ChampTankNear(petPos, 450.0)))
    {
        g_fChampNextR[client] = now + ChampCD(client, 26.0);
        Champ_CastAnim(client, 3);   // v46: lluvia de fuego
        float center[3];
        center[0] = targetPos[0];
        center[1] = targetPos[1];
        center[2] = targetPos[2] + 10.0;
        ChampFX_FadeToOwner(client, 255, 120, 40);
        EmitSoundToAll(SND_AIRSTRIKE1, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 100);
        CPrintToChat(client, "{green}[%s]{default} {olive}¡POLLUELO A VOLAR!{default}: lluvia de fuego.",
            g_sChampNames[3]);

        DataPack pack = new DataPack();
        pack.WriteCell(GetClientUserId(client));
        pack.WriteCell(level);
        pack.WriteFloat(center[0]);
        pack.WriteFloat(center[1]);
        pack.WriteFloat(center[2]);
        pack.WriteCell(5);   // explosiones restantes
        pack.WriteCell(col[0]);
        pack.WriteCell(col[1]);
        pack.WriteCell(col[2]);
        pack.WriteCell(col[3]);
        CreateTimer(0.3, Timer_ChampFireRain, pack,
                    TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
    }

    // ---- E: Vuelo Ardiente — embestida que quema al que cruza ----
    if (now >= g_fChampNextE[client] && !g_bChampDashing[client]
        && ChampCountEnemies(petPos, 400.0) >= 3)
    {
        int far = ChampFarthestEnemy(petPos, 500.0);
        if (far > 0)
        {
            g_fChampNextE[client] = now + ChampCD(client, 14.0);
            Champ_CastAnim(client, 2);   // v46: pose de embestida
            Champ_DashStart(client, pet, far, CHAMP_DASH_SMOLDER, 750.0, 1.0);
            CPrintToChat(client, "{green}[%s]{default} {olive}Vuelo Ardiente{default}: el dragoncito despega.",
                g_sChampNames[3]);
        }
    }

    // ---- W: ¡Achus! — cono que derriba a los pegados ----
    if (now >= g_fChampNextW[client] && ChampCountEnemies(petPos, 150.0) >= 2)
    {
        g_fChampNextW[client] = now + ChampCD(client, 12.0);
        Champ_CastAnim(client, 1);   // v46: estornudo
        float dir[3];
        MakeVectorFromPoints(petPos, targetPos, dir);
        ArrayList list = new ArrayList();
        int count = ChampEnemiesInCone(petPos, dir, 170.0, list);

        // estornudo: abanico de 3 llamaradas
        for (int k = -1; k <= 1; k++)
        {
            float sDir[3], sEnd[3];
            sDir[0] = dir[0];
            sDir[1] = dir[1];
            sDir[2] = 0.0;
            NormalizeVector(sDir, sDir);
            float ang = ArcTangent2(sDir[1], sDir[0]) + float(k) * 0.4;
            sEnd[0] = petPos[0] + Cosine(ang) * 170.0;
            sEnd[1] = petPos[1] + Sine(ang) * 170.0;
            sEnd[2] = petPos[2] + 25.0;
            ChampFX_Beam(petHead, sEnd, col, 2.6, 0.4);
        }
        ChampFX_Ring(petPos, 150.0, col, 0.5);
        ChampFX_Sparks(petPos, col);
        ChampFX_Particle(petPos, "fire_large_01", 1.2);   // v48: llama del estornudo
        EmitSoundToAll(SND_JETPASS, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.4, 170);

        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (!IsEnemyAlive(ent)) continue;
            ChampKnockback(ent, petPos, 500.0);
            AddSlow(ent, 1.5);
            ChampDamage(ent, client, 20.0 + 2.0 * float(level), DMG_BURN);
        }
        delete list;
        CPrintToChat(client, "{green}[%s]{default} {olive}¡Achus!{default}: aire de dragon.",
            g_sChampNames[3]);
    }
    // P (Sobrecalentado: 5 brasas) y Q (Tiro Candente) viven en el auto-ataque
}

// la lluvia de fuego: 5 explosiones secuenciales alrededor del objetivo
public Action Timer_ChampFireRain(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int client = GetClientOfUserId(pack.ReadCell());
    int level = pack.ReadCell();
    float center[3];
    center[0] = pack.ReadFloat();
    center[1] = pack.ReadFloat();
    center[2] = pack.ReadFloat();
    int drops = pack.ReadCell();
    int col[4];
    col[0] = pack.ReadCell();
    col[1] = pack.ReadCell();
    col[2] = pack.ReadCell();
    col[3] = pack.ReadCell();

    if (drops <= 0 || client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
        return Plugin_Stop;

    // explosion en un punto aleatorio del area
    float pos[3];
    float ang = GetRandomFloat(0.0, 6.28);
    float r = GetRandomFloat(30.0, 200.0);
    pos[0] = center[0] + Cosine(ang) * r;
    pos[1] = center[1] + Sine(ang) * r;
    pos[2] = center[2];
    pos[2] += 25.0;

    ChampFX_Burst(pos, col);
    ChampFX_Ring(pos, 120.0, col, 0.4);
    ChampFX_Shake(pos, 6, 250, 0.35);
    ChampFX_Particle(pos, "gas_explosion_fireball", 1.0);   // v48: bola de fuego real
    EmitSoundToAll((drops % 2 == 0) ? SND_MISSILE1 : SND_MISSILE2, client,
                   SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.6, GetRandomInt(100, 130));

    ArrayList list = new ArrayList();
    int count = PetEnemiesInRadius(pos, 120.0, list);
    for (int i = 0; i < count; i++)
    {
        int ent = list.Get(i);
        if (!IsEnemyAlive(ent)) continue;
        ChampDamage(ent, client, 15.0 + 1.5 * float(level), DMG_BURN);
        AddSlow(ent, 1.0);
    }
    delete list;

    // reescribir el pack con una explosion menos
    pack.Reset();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(level);
    pack.WriteFloat(center[0]);
    pack.WriteFloat(center[1]);
    pack.WriteFloat(center[2]);
    pack.WriteCell(drops - 1);
    pack.WriteCell(col[0]);
    pack.WriteCell(col[1]);
    pack.WriteCell(col[2]);
    pack.WriteCell(col[3]);
    return Plugin_Continue;
}
// ============================================================================
// v45 FUSION — MODULO CAMPEONES (parte D): kits Ghosty/Storm/Ember/Warwick
// ============================================================================

// ----------------------------------------------------------------------------
// GHOSTY (Thresh) — el Carcelero: gancho que arrastra, farol y jaula
// ----------------------------------------------------------------------------
void Champ_Kit_Ghosty(int client, int pet, const float petPos[3], const float petHead[3], const float targetPos[3], float now)
{
    int level = g_iChampLevel[client][4];
    int col[4];
    ChampColorOf(4, col);

    // ---- Q: Sentencia de Muerte — la LENGUA REAL del smoker (como la nave) ----
    // v48: Thresh dispara la lengua autentica del juego (particula
    // smoker_tongue): vuela a 1500 u/s, engancha al especial que toca, lo
    // cuelga, lo ARRASTRA hasta el carcelero y lo castiga con el latigazo.
    // v53: FIX CRITICO — antes nacia 3000 u bajo el suelo (morro de la
    // nave en vez del pecho del campeon) y NUNCA llegaba a enganchar;
    // ahora SI engancha, cuelga y arrastra de verdad (CreatePetTongue).
    if (now >= g_fChampNextQ[client] && g_TongueRef[client] == -1)
    {
        int si = ChampNearestSI(petPos, 700.0);
        if (si > 0 && Champ_ThreshTongue(client, pet, si))
        {
            g_fChampNextQ[client] = now + ChampCD(client, 14.0);
            Champ_CastAnim(client, 0);   // v46: gancho
        }
    }

    // ---- W: Pasaje Siniestro — farol = escudo para la duegna herida ----
    if (now >= g_fChampNextW[client] && ChampOwnerLowHP(client, 0.40))
    {
        g_fChampNextW[client] = now + ChampCD(client, 20.0);
        Champ_CastAnim(client, 1);   // v46: farol
        float temp = L4D_GetTempHealth(client) + 25.0;
        L4D_SetTempHealth(client, temp);
        float ownerPos[3];
        GetClientAbsOrigin(client, ownerPos);
        ownerPos[2] += 20.0;
        ChampFX_Ring(ownerPos, 120.0, col, 0.7);
        ChampFX_Pillar(ownerPos, col, 140.0);
        ChampFX_FadeToOwner(client, 150, 255, 120);
        EmitSoundToAll(SND_REWARD, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.7, 120);
        CPrintToChat(client, "{green}[%s]{default} {olive}Pasaje Siniestro{default}: el farol te protege (+25).",
            g_sChampNames[4]);
    }

    // ---- E: Latigazo — barre el frente ----
    if (now >= g_fChampNextE[client] && ChampCountEnemies(petPos, 250.0) >= 2)
    {
        g_fChampNextE[client] = now + ChampCD(client, 10.0);
        Champ_CastAnim(client, 2);   // v46: latigazo
        float dir[3];
        MakeVectorFromPoints(petPos, targetPos, dir);
        dir[2] = 0.0;
        NormalizeVector(dir, dir);

        // barrido en abanico
        for (int k = -2; k <= 2; k++)
        {
            float sEnd[3];
            float ang = ArcTangent2(dir[1], dir[0]) + float(k) * 0.3;
            sEnd[0] = petPos[0] + Cosine(ang) * 250.0;
            sEnd[1] = petPos[1] + Sine(ang) * 250.0;
            sEnd[2] = petPos[2] + 30.0;
            ChampFX_Beam(petHead, sEnd, col, 1.8, 0.25);
        }
        ChampFX_Ring(petPos, 250.0, col, 0.5);
        ChampFX_Particle(petPos, "smoker_smokecloud_cheap", 1.5);   // v48: barrido de niebla
        EmitSoundToAll(SND_JETPASS, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.4, 150);

        ArrayList list = new ArrayList();
        int count = PetEnemiesInRadius(petPos, 250.0, list);
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (!IsEnemyAlive(ent)) continue;
            ChampKnockback(ent, petPos, 300.0);
            AddSlow(ent, 1.5);
            ChampDamage(ent, client, 25.0 + 2.5 * float(level), DMG_CLUB);
        }
        delete list;
        CPrintToChat(client, "{green}[%s]{default} {olive}Latigazo{default}: barre el frente.",
            g_sChampNames[4]);
    }

    // ---- R: La Jaula — prision espectral alrededor del carcelero ----
    if (now >= g_fChampNextR[client]
        && (ChampCountEnemies(petPos, 300.0) >= 4 || IsPlayerGrabbed(client)))
    {
        g_fChampNextR[client] = now + ChampCD(client, 28.0);
        Champ_CastAnim(client, 3);   // v46: jaula

        // pentagono de 5 muros-espectrales
        float center[3];
        center[0] = petPos[0];
        center[1] = petPos[1];
        center[2] = petPos[2] + 10.0;
        for (int k = 0; k < 5; k++)
        {
            float ang = float(k) * 1.2566;
            float pPos[3];
            pPos[0] = center[0] + Cosine(ang) * 220.0;
            pPos[1] = center[1] + Sine(ang) * 220.0;
            pPos[2] = center[2];
            ChampFX_Pillar(pPos, col, 170.0);
        }
        ChampZone_Start(client, center, 250.0, 5.0, 1, 12.0 + float(level));
        ChampFX_Ring(center, 250.0, col, 1.0);
        ChampFX_Particle(center, "spitter_areaofdenial", 5.0);   // v48: charco espectral (jaula)
        ChampFX_FadeToOwner(client, 150, 255, 120);
        EmitSoundToAll(SND_GLASS, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 90);
        CPrintToChat(client, "{green}[%s]{default} {olive}LA JAULA{default}: nadie sale del circulo.",
            g_sChampNames[4]);
    }
    // P (Condenacion) se acumula con cada baja (Champ_CreditKill)
}

// v48: Sentencia de Muerte — lanzamiento de la LENGUA REAL de Thresh
// (espejo del TrySmokerTongue de la nave, pero sin tirada de dados:
// la Q dispara SIEMPRE que haya presa valida y linea de tiro)
bool Champ_ThreshTongue(int client, int pet, int prey)
{
    if (g_TongueRef[client] != -1) return false;      // ya hay lengua activa
    if (!IsTonguePreyValid(client, prey)) return false;

    // linea de tiro: la lengua no atraviesa muros... salvo que quien
    // bloquee sea OTRO especial: el tongue real engancha al primero
    // que se cruza — esta lengua hace lo mismo
    int blocker = 0;
    if (!TongueLOS(client, pet, prey, blocker))
    {
        if (!IsTonguePreyValid(client, blocker)) return false;
        prey = blocker;
    }

    float now = GetGameTime();
    if (!CreatePetTongue(client, pet))
        return false;   // sin particula no hay lengua (reintento pronto)

    g_TongueRef[client] = EntIndexToEntRef(prey);
    g_TonguePhase[client] = 0;                // fase 0: vuelo hacia la presa
    g_TongueFlightEnd[client] = now + 1.2;    // techo del vuelo (1500 u/s)
    g_TongueUntil[client] = now + 3.6;        // vuelo (1.2) + arrastre (2.3)
    g_TongueDamageDone[client] = 0.0;
    g_NextTongueAt[client] = now + 7.0;

    // v53: SIN beams de adorno al lanzar — el visual ES la lengua real
    // del smoker (particula smoker_tongue) saliendo del pecho de Thresh,
    // exactamente como la lengua de la nave: nada de lineas verdes encima.

    int snd = GetPetSoundEnt(client, pet);
    if (g_bTongueSnd)
        EmitSoundToAll(SND_SMOKER_TONGUE, snd, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 100);
    else
        EmitSoundToAll(SND_GLASS, snd, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.9, 60);

    CreateTimer(0.1, Timer_TongueDrag, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);

    char siName[16];
    PetSIName(prey, siName, sizeof(siName));
    CPrintToChat(client, "{green}[%s]{default} {olive}Sentencia de Muerte{default}: lengua enganchada a {olive}%s{default}.",
        g_sChampNames[4], siName);
    return true;
}

// ----------------------------------------------------------------------------
// STORM (Volibear) — la Tormenta Indomable
// ----------------------------------------------------------------------------
void Champ_Kit_Storm(int client, int pet, const float petPos[3], const float petHead[3], int target, const float targetPos[3], float dist, float now)
{
    int level = g_iChampLevel[client][5];
    int col[4];
    ChampColorOf(5, col);

    // ---- Q: Golpe Tronador — empodera el proximo golpe y acelera ----
    if (now >= g_fChampNextQ[client] && dist <= g_fChampRange)
    {
        g_fChampNextQ[client] = now + ChampCD(client, 12.0);
        Champ_CastAnim(client, 0);   // v46: golpe tronador
        g_fChampQEmpowerUntil[client] = now + 4.0;    // el proximo golpe sale con rayo
        g_fChampAspdUntil[client] = now + 3.0;        // +40% velocidad 3 s
        float flash[3];
        flash[0] = petHead[0];
        flash[1] = petHead[1];
        flash[2] = petHead[2];
        int white[4] = {240, 250, 255, 255};
        ChampFX_Beam(flash, targetPos, white, 3.0, 0.3);
        ChampFX_Ring(petPos, 90.0, col, 0.5);
        ChampFX_Particle(petPos, "electrical_arc_01_system", 1.0);   // v48: arco electrico real
        if (g_bChampZapSnd) EmitSoundToAll(SND_CHAMP_ZAP, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.7);
        CPrintToChat(client, "{green}[%s]{default} {olive}Golpe Tronador{default}: el trueno empodera al oso.",
            g_sChampNames[5]);
    }

    // ---- W: Mordida Frenetica — presa debil: muerde y te cura ----
    if (now >= g_fChampNextW[client] && dist <= g_fChampRange)
    {
        int hp = GetEntProp(target, Prop_Data, "m_iHealth");
        int maxHp = GetEntProp(target, Prop_Data, "m_iMaxHealth");
        bool weak = float(hp) <= float(maxHp) * 0.40;
        bool ownerHurt = ChampOwnerLowHP(client, 0.55);
        if (weak || ownerHurt)
        {
            g_fChampNextW[client] = now + ChampCD(client, 9.0);
            Champ_CastAnim(client, 1);   // v46: mordida
            float dmg = 40.0 + 4.0 * float(level);
            if (weak) dmg *= 1.5;   // presa debil: mordida ejecutora

            float hitPos[3];
            hitPos[0] = targetPos[0];
            hitPos[1] = targetPos[1];
            hitPos[2] = targetPos[2] + 40.0;
            ChampFX_Beam(petHead, hitPos, col, 2.0, 0.15);
            PetBloodAt(hitPos);
            ChampDamage(target, client, dmg, DMG_CLUB);

            // en LoL Volibear se cura: aqui la mordida revitaliza a la duegna
            float temp = L4D_GetTempHealth(client) + (weak ? 12.0 : 8.0) + float(level) * 0.5;
            L4D_SetTempHealth(client, temp);
            float ownerPos[3];
            GetClientAbsOrigin(client, ownerPos);
            ownerPos[2] += 20.0;
            int white[4] = {240, 250, 255, 255};
            ChampFX_Ring(ownerPos, 70.0, white, 0.5);
            if (weak)
                CPrintToChat(client, "{green}[%s]{default} {olive}Mordida Frenetica{default}: mordida ejecutora (+vida).",
                    g_sChampNames[5]);
        }
    }

    // ---- E: Cielo Hendido — rayo del cielo sobre la horda ----
    if (now >= g_fChampNextE[client] && ChampCountEnemies(petPos, 400.0) >= 3)
    {
        g_fChampNextE[client] = now + ChampCD(client, 16.0);
        Champ_CastAnim(client, 2);   // v46: rayo
        float sky[3];
        sky[0] = targetPos[0];
        sky[1] = targetPos[1];
        sky[2] = targetPos[2] + 20.0;

        // rayo vertical gigante + onda
        ChampFX_Pillar(sky, col, 420.0);
        ChampFX_Particle(sky, "storm_lightning_01", 1.0);   // v48: relampago real
        int white[4] = {240, 250, 255, 255};
        float top[3];
        top[0] = sky[0];
        top[1] = sky[1];
        top[2] = sky[2] + 420.0;
        ChampFX_Beam(sky, top, white, 6.0, 0.5);
        ChampFX_Ring(sky, 200.0, col, 0.7);
        ChampFX_Shake(sky, 10, 400, 0.6);
        if (g_bChampZapSnd) EmitSoundToAll(SND_CHAMP_ZAP, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0);

        ArrayList list = new ArrayList();
        int count = PetEnemiesInRadius(sky, 200.0, list);
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (!IsEnemyAlive(ent)) continue;
            ChampDamage(ent, client, 40.0 + 4.0 * float(level), DMG_SHOCK);
            AddSlow(ent, 2.0);
        }
        delete list;
        CPrintToChat(client, "{green}[%s]{default} {olive}Cielo Hendido{default}: el cielo se parte en dos.",
            g_sChampNames[5]);
    }

    // ---- R: Anuncio de la Tormenta — rugido que aturde todo ----
    if (now >= g_fChampNextR[client]
        && (ChampCountEnemies(petPos, 350.0) >= 5 || ChampTankNear(petPos, 400.0)))
    {
        g_fChampNextR[client] = now + ChampCD(client, 30.0);
        Champ_CastAnim(client, 3);   // v46: rugido

        ChampFX_Ring(petPos, 180.0, col, 0.6);
        ChampFX_Ring(petPos, 350.0, col, 0.9);
        int white[4] = {240, 250, 255, 255};
        ChampFX_Ring(petPos, 500.0, white, 1.2);
        ChampFX_Pillar(petPos, col, 320.0);
        ChampFX_Particle(petPos, "storm_lightning_02", 1.2);   // v48: trueno del rugido
        ChampFX_Shake(petPos, 14, 600, 1.0);
        ChampFX_FadeToOwner(client, 80, 160, 255);
        EmitSoundToAll(SND_AIRSTRIKE1, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 90);

        ArrayList list = new ArrayList();
        int count = PetEnemiesInRadius(petPos, 350.0, list);
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (!IsEnemyAlive(ent)) continue;
            Champ_SetStagger(ent, pet, petPos, 1.2);   // el rugido los tambalea
            ChampDamage(ent, client, 35.0 + 3.5 * float(level), DMG_CLUB);
            ChampKnockback(ent, petPos, 220.0);
        }
        delete list;
        CPrintToChat(client, "{green}[%s]{default} {olive}ANUNCIO DE LA TORMENTA{default}: rugido atronador.",
            g_sChampNames[5]);
    }
    // P (cadena de rayos cada 4 golpes) vive en el auto-ataque
}

// ----------------------------------------------------------------------------
// EMBER (Ornn) — el Herrero: fragua, lava y ondas sismicas
// ----------------------------------------------------------------------------
void Champ_Kit_Ember(int client, int pet, const float petPos[3], const float petHead[3], const float targetPos[3], float dist, float now)
{
    int level = g_iChampLevel[client][6];
    int col[4];
    ChampColorOf(6, col);

    // ---- P: Fragua Viviente — repara el cargador de la duegna ----
    if (now >= g_fChampNextP[client])
    {
        g_fChampNextP[client] = now + 30.0 * g_fChampAbCD;
        GiveFullAmmo(client, true, false);
        float ownerPos[3];
        GetClientAbsOrigin(client, ownerPos);
        ownerPos[2] += 20.0;
        ChampFX_Ring(ownerPos, 90.0, col, 0.6);
        ChampFX_Pillar(ownerPos, col, 120.0);
        CPrintToChat(client, "{green}[%s]{default} {olive}Fragua Viviente{default}: cargador reparado.",
            g_sChampNames[6]);
    }

    // ---- R: Llamada del Dios Forja — oleada que barre el frente ----
    if (now >= g_fChampNextR[client]
        && (ChampCountEnemies(petPos, 500.0) >= 4 || ChampTankNear(petPos, 500.0)))
    {
        g_fChampNextR[client] = now + ChampCD(client, 32.0);
        Champ_CastAnim(client, 3);   // v46: dios forja

        float dir[3], end[3];
        MakeVectorFromPoints(petPos, targetPos, dir);
        dir[2] = 0.0;
        NormalizeVector(dir, dir);
        end[0] = petPos[0] + dir[0] * 600.0;
        end[1] = petPos[1] + dir[1] * 600.0;
        end[2] = petPos[2] + 20.0;

        // la oleada: abanico de fuelles de fuego
        for (int k = -2; k <= 2; k++)
        {
            float sEnd[3];
            float ang = ArcTangent2(dir[1], dir[0]) + float(k) * 0.25;
            sEnd[0] = petPos[0] + Cosine(ang) * 600.0;
            sEnd[1] = petPos[1] + Sine(ang) * 600.0;
            sEnd[2] = petPos[2] + 30.0;
            ChampFX_Beam(petHead, sEnd, col, 3.4, 0.55);
        }
        ChampFX_Ring(petPos, 400.0, col, 1.0);
        ChampFX_Pillar(end, col, 280.0);
        ChampFX_Particle(end, "gas_explosion_ground_wave", 1.5);   // v48: la oleada avanza
        ChampFX_Shake(petPos, 12, 600, 0.9);
        ChampFX_FadeToOwner(client, 255, 80, 50);
        EmitSoundToAll(SND_AIRSTRIKE2, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 90);

        ArrayList list = new ArrayList();
        int count = ChampEnemiesInCone(petPos, dir, 600.0, list);
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (!IsEnemyAlive(ent)) continue;
            ChampKnockback(ent, petPos, 550.0);
            ChampDamage(ent, client, 40.0 + 4.0 * float(level), DMG_CLUB);
            // los livianos despegan: al aterrizar, stagger
            if (ent > MaxClients)
                Champ_Launch(ent, client, petPos, 300.0, 20.0 + 2.0 * float(level));
        }
        delete list;
        CPrintToChat(client, "{green}[%s]{default} {olive}LLAMADA DEL DIOS FORJA{default}: la montaña avanza.",
            g_sChampNames[6]);
    }

    // ---- Q: Ruptura Volcanica — grieta de lava hacia el objetivo ----
    if (now >= g_fChampNextQ[client] && dist <= 400.0)
    {
        g_fChampNextQ[client] = now + ChampCD(client, 12.0);
        Champ_CastAnim(client, 0);   // v46: ruptura
        float dir[3];
        MakeVectorFromPoints(petPos, targetPos, dir);
        dir[2] = 0.0;
        NormalizeVector(dir, dir);

        DataPack pack = new DataPack();
        pack.WriteCell(GetClientUserId(client));
        pack.WriteCell(level);
        pack.WriteFloat(petPos[0]);
        pack.WriteFloat(petPos[1]);
        pack.WriteFloat(petPos[2]);
        pack.WriteFloat(dir[0]);
        pack.WriteFloat(dir[1]);
        pack.WriteCell(0);   // paso actual de la grieta (0-3)
        pack.WriteCell(col[0]);
        pack.WriteCell(col[1]);
        pack.WriteCell(col[2]);
        pack.WriteCell(col[3]);
        CreateTimer(0.25, Timer_ChampVolcanicRift, pack,
                    TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
        CPrintToChat(client, "{green}[%s]{default} {olive}Ruptura Volcanica{default}: el suelo se abre.",
            g_sChampNames[6]);
    }

    // ---- W: Aliento de Fuelle — cono de fuego ----
    if (now >= g_fChampNextW[client] && ChampCountEnemies(petPos, 200.0) >= 2)
    {
        g_fChampNextW[client] = now + ChampCD(client, 9.0);
        Champ_CastAnim(client, 1);   // v46: fuelle
        float dir[3];
        MakeVectorFromPoints(petPos, targetPos, dir);
        ArrayList list = new ArrayList();
        int count = ChampEnemiesInCone(petPos, dir, 220.0, list);

        for (int k = -1; k <= 2; k++)
        {
            float sEnd[3];
            float ang = ArcTangent2(dir[1], dir[0]) + float(k) * 0.3;
            sEnd[0] = petPos[0] + Cosine(ang) * 220.0;
            sEnd[1] = petPos[1] + Sine(ang) * 220.0;
            sEnd[2] = petPos[2] + 30.0;
            ChampFX_Beam(petHead, sEnd, col, 2.4, 0.4);
        }
        ChampFX_Ring(petPos, 200.0, col, 0.5);
        ChampFX_Particle(petPos, "gas_explosion_fireball", 1.0);   // v48: fuelle de fuego
        EmitSoundToAll(SND_JETPASS, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.5, 110);

        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (!IsEnemyAlive(ent)) continue;
            ChampKnockback(ent, petPos, 300.0);
            ChampDamage(ent, client, 25.0 + 2.5 * float(level), DMG_BURN);
            ChampBurn_Start(ent, client, 5.0 + 0.5 * float(level), 2, col);
        }
        delete list;
    }

    // ---- E: Carga Abrasadora — embestida; pared = onda sismica ----
    if (now >= g_fChampNextE[client] && !g_bChampDashing[client]
        && (ChampCountEnemies(petPos, 400.0) >= 3))
    {
        int si = ChampNearestSI(petPos, 550.0);
        if (si <= 0)
        {
            ArrayList list = new ArrayList();
            int count = PetEnemiesInRadius(petPos, 450.0, list);
            if (count > 0) si = list.Get(0);
            delete list;
        }
        if (si > 0)
        {
            g_fChampNextE[client] = now + ChampCD(client, 16.0);
            Champ_CastAnim(client, 2);   // v46: pose de embestida
            Champ_DashStart(client, pet, si, CHAMP_DASH_ORNN, 620.0, 1.4);
            CPrintToChat(client, "{green}[%s]{default} {olive}Carga Abrasadora{default}: embestida al rojo vivo.",
                g_sChampNames[6]);
        }
    }
}

// la grieta volcanica: 4 erupciones secuenciales en linea
public Action Timer_ChampVolcanicRift(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int client = GetClientOfUserId(pack.ReadCell());
    int level = pack.ReadCell();
    float from[3];
    from[0] = pack.ReadFloat();
    from[1] = pack.ReadFloat();
    from[2] = pack.ReadFloat();
    float dir[3];
    dir[0] = pack.ReadFloat();
    dir[1] = pack.ReadFloat();
    dir[2] = 0.0;
    int step = pack.ReadCell();
    int col[4];
    col[0] = pack.ReadCell();
    col[1] = pack.ReadCell();
    col[2] = pack.ReadCell();
    col[3] = pack.ReadCell();

    if (step >= 4 || client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
        return Plugin_Stop;

    // punto de la grieta
    float pos[3];
    pos[0] = from[0] + dir[0] * 110.0 * float(step + 1);
    pos[1] = from[1] + dir[1] * 110.0 * float(step + 1);
    pos[2] = from[2] + 25.0;

    // telegrafo corto y erupcion
    ChampFX_RingIn(pos, 120.0, col);
    ChampFX_Burst(pos, col);
    ChampFX_Shake(pos, 5, 220, 0.3);
    ChampFX_Particle(pos, "fire_large_01", 1.2);   // v48: lava real de la grieta
    EmitSoundToAll(SND_MISSILE1, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.5,
                   100 + step * 10);

    ArrayList list = new ArrayList();
    int count = PetEnemiesInRadius(pos, 120.0, list);
    for (int i = 0; i < count; i++)
    {
        int ent = list.Get(i);
        if (!IsEnemyAlive(ent)) continue;
        ChampDamage(ent, client, 20.0 + 2.0 * float(level), DMG_BURN);
        AddSlow(ent, 1.5);
    }
    delete list;

    pack.Reset();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(level);
    pack.WriteFloat(from[0]);
    pack.WriteFloat(from[1]);
    pack.WriteFloat(from[2]);
    pack.WriteFloat(dir[0]);
    pack.WriteFloat(dir[1]);
    pack.WriteCell(step + 1);
    pack.WriteCell(col[0]);
    pack.WriteCell(col[1]);
    pack.WriteCell(col[2]);
    pack.WriteCell(col[3]);
    return Plugin_Continue;
}

// ----------------------------------------------------------------------------
// WARWICK — la Ira Encadenada: caza, marca y supresion
// ----------------------------------------------------------------------------
void Champ_Kit_Warwick(int client, int pet, const float petPos[3], const float petHead[3], int target, const float targetPos[3], float dist, float now)
{
    int level = g_iChampLevel[client][7];
    int col[4];
    ChampColorOf(7, col);

    // ---- R: Duelo Infinito — suprime al especial con 6 golpes ----
    if (now >= g_fChampNextR[client])
    {
        int prey = -1;
        if (g_iChampMarkRef[client] != -1)
            prey = EntRefToEntIndex(g_iChampMarkRef[client]);   // la presa marcada
        if (prey <= 0 || !IsEnemyAlive(prey))
            prey = ChampWeakestSI(petPos, 500.0);

        if (prey > 0)
        {
            g_fChampNextR[client] = now + ChampCD(client, 32.0);
            Champ_CastAnim(client, 3);   // v46: duelo

            // salto sobre la presa
            float preyPos[3];
            GetEntPropVector(prey, Prop_Send, "m_vecOrigin", preyPos);
            float leap[3];
            leap[0] = preyPos[0] - 40.0;
            leap[1] = preyPos[1] - 40.0;
            leap[2] = preyPos[2];
            TeleportEntity(pet, leap, NULL_VECTOR, NULL_VECTOR);
            SnapPetToGround(client);

            // SUPRESION: no se puede mover mientras dura el duelo
            Champ_SetStagger(prey, pet, petPos, 2.2);

            // graficos de la ult
            ChampFX_Pillar(preyPos, col, 300.0);
            ChampFX_Ring(preyPos, 160.0, col, 0.8);
            ChampFX_Shake(preyPos, 10, 350, 0.8);
            ChampFX_FadeToOwner(client, 255, 60, 80);
            EmitSoundToAll(SND_AIRSTRIKE3, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 1.0, 90);

            char siName[16];
            if (prey <= MaxClients) PetSIName(prey, siName, sizeof(siName));
            else strcopy(siName, sizeof(siName), "witch");
            CPrintToChat(client, "{green}[%s]{default} {olive}DUELO INFINITO{default}: {olive}%s{default} queda suprimido.",
                g_sChampNames[7], siName);

            // 6 golpes rapidos
            DataPack pack = new DataPack();
            pack.WriteCell(GetClientUserId(client));
            pack.WriteCell(EntIndexToEntRef(prey));
            pack.WriteCell(6);
            pack.WriteCell(level);
            CreateTimer(0.25, Timer_ChampRampage, pack,
                        TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
        }
    }

    // ---- Q: Fauces de la Bestia — mordida que cura a la duegna ----
    if (now >= g_fChampNextQ[client] && dist <= g_fChampRange)
    {
        g_fChampNextQ[client] = now + ChampCD(client, 8.0);
        Champ_CastAnim(client, 0);   // v46: fauces
        float dmg = 30.0 + 3.0 * float(level);
        float hitPos[3];
        hitPos[0] = targetPos[0];
        hitPos[1] = targetPos[1];
        hitPos[2] = targetPos[2] + 40.0;

        // lunge corto hacia la presa
        float lunge[3];
        lunge[0] = targetPos[0] - 50.0;
        lunge[1] = targetPos[1] - 50.0;
        lunge[2] = targetPos[2];
        TeleportEntity(pet, lunge, NULL_VECTOR, NULL_VECTOR);
        SnapPetToGround(client);

        ChampFX_Beam(petHead, hitPos, col, 2.2, 0.18);
        PetBloodAt(hitPos);
        ChampFX_Particle(hitPos, "blood_impact_arterial_spray_5", 0.8);   // v48: sangre de la mordida
        AddSlow(target, 1.5);
        ChampDamage(target, client, dmg, DMG_CLUB);

        // la mordida revitaliza (25% del dano como vida temporal)
        float temp = L4D_GetTempHealth(client) + dmg * 0.25;
        L4D_SetTempHealth(client, temp);
        float ownerPos[3];
        GetClientAbsOrigin(client, ownerPos);
        ownerPos[2] += 20.0;
        int white[4] = {240, 250, 255, 255};
        ChampFX_Ring(ownerPos, 70.0, white, 0.5);
    }

    // ---- W: Caza de Sangre — marca al especial mas debil ----
    if (now >= g_fChampNextW[client])
    {
        int weak = ChampWeakestSI(petPos, 800.0);
        if (weak > 0)
        {
            g_fChampNextW[client] = now + ChampCD(client, 18.0);
            Champ_CastAnim(client, 1);   // v46: caza
            ChampApplyMark(client, weak);
            CreateTimer(5.0, Timer_ChampUnmark, GetClientUserId(weak), TIMER_FLAG_NO_MAPCHANGE);

            float weakPos[3];
            GetClientAbsOrigin(weak, weakPos);
            weakPos[2] += 20.0;
            ChampFX_Ring(weakPos, 90.0, col, 0.7);   // pulso de la marca
            char siName[16];
            PetSIName(weak, siName, sizeof(siName));
            CPrintToChat(client, "{green}[%s]{default} {olive}Caza de Sangre{default}: {olive}%s{default} marcado, ¡a por el!",
                g_sChampNames[7], siName);
        }
    }

    // ---- E: Aullido Primal — la manada se detiene ----
    if (now >= g_fChampNextE[client] && ChampCountEnemies(petPos, 300.0) >= 5)
    {
        g_fChampNextE[client] = now + ChampCD(client, 14.0);
        Champ_CastAnim(client, 2);   // v46: aullido
        ChampFX_Ring(petPos, 300.0, col, 0.8);
        ChampFX_Shake(petPos, 8, 400, 0.6);
        if (g_bChampZapSnd) EmitSoundToAll(SND_CHAMP_ZAP, pet, SNDCHAN_AUTO, SNDLEVEL_NORMAL, _, 0.9, 60);

        ArrayList list = new ArrayList();
        int count = PetEnemiesInRadius(petPos, 300.0, list);
        for (int i = 0; i < count; i++)
        {
            int ent = list.Get(i);
            if (!IsEnemyAlive(ent)) continue;
            Champ_SetStagger(ent, pet, petPos, 0.8);   // miedo = tambaleo
            ChampDamage(ent, client, 25.0 + 2.5 * float(level), DMG_CLUB);
        }
        delete list;
        CPrintToChat(client, "{green}[%s]{default} {olive}Aullido Primal{default}: la manada retrocede.",
            g_sChampNames[7]);
    }
    // P (Hambre Eterna) vive en el auto-ataque
}

// la rafaga del Duelo Infinito: 6 golpes a 0.25 s con cura por golpe
public Action Timer_ChampRampage(Handle timer, any data)
{
    DataPack pack = view_as<DataPack>(data);
    pack.Reset();
    int client = GetClientOfUserId(pack.ReadCell());
    int prey = EntRefToEntIndex(pack.ReadCell());
    int hits = pack.ReadCell();
    int level = pack.ReadCell();

    if (hits <= 0 || client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)
        || prey <= 0 || !IsValidEntity(prey) || !IsEnemyAlive(prey))
        return Plugin_Stop;

    int col[4];
    ChampColorOf(7, col);
    float preyPos[3];
    GetEntPropVector(prey, Prop_Send, "m_vecOrigin", preyPos);
    float hitPos[3];
    hitPos[0] = preyPos[0];
    hitPos[1] = preyPos[1];
    hitPos[2] = preyPos[2] + 40.0;

    ChampFX_Beam(preyPos, hitPos, col, 2.4, 0.15);
    PetBloodAt(hitPos);
    ChampFX_Particle(hitPos, "blood_impact_arterial_spray_5", 0.8);   // v48: sangre real del duelo
    SetPetAnimation(client, (hits % 2 == 0) ? "Attack" : "Attack2");
    ChampDamage(prey, client, 12.0 + float(level), DMG_CLUB);

    // cada golpe alimenta un poco a la duegna
    float temp = L4D_GetTempHealth(client) + 2.0 + float(level) * 0.25;
    L4D_SetTempHealth(client, temp);

    pack.Reset();
    pack.WriteCell(GetClientUserId(client));
    pack.WriteCell(EntIndexToEntRef(prey));
    pack.WriteCell(hits - 1);
    pack.WriteCell(level);
    return Plugin_Continue;
}
// ============================================================================
// v45 FUSION — MODULO CAMPEONES (parte E): menus + pegamento con la nave
// ============================================================================

// v56: texto de cooldown para el titulo del menu del campeon
void ChampCdText(float nextAt, float now, char[] out, int maxlen)
{
    float left = nextAt - now;
    if (left <= 0.0) { strcopy(out, maxlen, "LISTA"); return; }
    if (left >= 10.0) FormatEx(out, maxlen, "%.0fs", left);
    else FormatEx(out, maxlen, "%.1fs", left);
}

void ShowChampMenu(int client)
{
    Menu menu = new Menu(MenuHandler_ChampMain);
    menu.Pagination = 7;

    int sel = g_iChampSel[client];
    int level = g_iChampLevel[client][sel];
    bool spawned = IsPetValid(client);

    // v56: lineas vivas del titulo — cooldowns del kit y del Revivir
    char kitTxt[80], reviveTxt[48], cdTxt[5][12];
    float nowCd = GetGameTime();
    ChampCdText(g_fChampNextP[client], nowCd, cdTxt[0], sizeof(cdTxt[]));
    ChampCdText(g_fChampNextQ[client], nowCd, cdTxt[1], sizeof(cdTxt[]));
    ChampCdText(g_fChampNextW[client], nowCd, cdTxt[2], sizeof(cdTxt[]));
    ChampCdText(g_fChampNextE[client], nowCd, cdTxt[3], sizeof(cdTxt[]));
    ChampCdText(g_fChampNextR[client], nowCd, cdTxt[4], sizeof(cdTxt[]));
    FormatEx(kitTxt, sizeof(kitTxt), "Habs: P %s | Q %s | W %s | E %s | R %s",
        cdTxt[0], cdTxt[1], cdTxt[2], cdTxt[3], cdTxt[4]);
    int revLeft = ReviveTimeLeft(client);
    if (revLeft > 0)
        FormatEx(reviveTxt, sizeof(reviveTxt), "Revivir: %d s", revLeft);
    else
        FormatEx(reviveTxt, sizeof(reviveTxt), "Revivir: LISTO");
    char title[256];
    Format(title, sizeof(title),
        "Campeones  [%s — %s]\nNivel %d | XP %d/%d | Bajas: %d\nVel. ataque: %.2f/s (%.0f%%)\n%s\n%s\n ",
        g_sChampNames[sel], g_sChampLoL[sel], level, g_iChampXP[client][sel],
        ChampXPToNext(level), g_iChampKills[client][sel],
        ChampAttackRate(client), (ChampAttackMult(client, GetGameTime()) - 1.0) * 100.0,
                kitTxt, reviveTxt);
    menu.SetTitle(title);

    char item[96];
    if (spawned) FormatEx(item, sizeof(item), "Despedir a %s", g_sChampNames[sel]);
    else FormatEx(item, sizeof(item), "Invocar a %s [Nv %d]", g_sChampNames[sel], level);
    menu.AddItem("champsummon", item);

    menu.AddItem("champsel", "Cambiar de campeon (8)");

    FormatEx(item, sizeof(item), "Skin: %s", g_sPet_Skin[client]);
    menu.AddItem("champskin", item, spawned ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    FormatEx(item, sizeof(item), "Glow: %s", g_sPet_Aura[client]);
    menu.AddItem("champaura", item, spawned ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.AddItem("champsize", "Tamano del cuerpo", spawned ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.AddItem("champmoves", "Movimientos y bailes", spawned ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.AddItem("champabilities", "Poderes de apoyo (5 + AUTO)");
    if (sel == 1)   // v77: metodo de combate (solo Poppy)
    {
        char mItem[96];
        FormatEx(mItem, sizeof(mItem), "Metodo de combate: %s", g_sPoppyMethodNames[g_iPoppyMethod[client]]);
        menu.AddItem("champmethod", mItem);
    }
    menu.AddItem("champtravel", "Viaje instantaneo", spawned ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    menu.AddItem("champstats", "Progreso de campeones");
    menu.AddItem("champkit", "Ver kit completo (chat)");
    if (spawned)
        menu.AddItem("champtalk", "Hablar con el campeon");

            StartLiveMenu(client, 2);   // v56: nivel/XP/CD repintados en vivo cada segundo

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_ChampMain(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Cancel)
    {
        // v56: numeros vivos — el repintado de 1 s REEMPLAZA el menu (esa
                // cancelacion con MenuCancel_Interrupted es nuestra); el resto apaga
                if (item == MenuCancel_Interrupted && g_bMenuSelfRefresh[client])
                    g_bMenuSelfRefresh[client] = false;
                else StopLiveMenu(client);

                if (item == MenuCancel_ExitBack) ShowPetMenu(client);   // vuelve al panel unico
        return 0;
    }
    if (action != MenuAction_Select) return 0;

    if (GetClientTeam(client) != 2 || !IsPlayerAlive(client))
    {
        CPrintToChat(client, "{green}[Companion]{default} Solo supervivientes vivos pueden usar esto.");
        ShowChampMenu(client);
        return 0;
    }

    StopLiveMenu(client);   // v56: al saltar a un submenu, el repintado vivo se apaga
        char info[24];
    menu.GetItem(item, info, sizeof(info));
    bool spawned = IsPetValid(client);

    if (StrEqual(info, "champsummon"))
    {
        if (spawned) ReturnPet(client);      // despedida animada (v1.3)
        else Champ_Summon(client);
        ShowChampMenu(client);
    }
    else if (StrEqual(info, "champsel")) ShowChampSelectMenu(client);
    else if (StrEqual(info, "champskin")) { if (spawned) CycleModelSkin(client); }
    else if (StrEqual(info, "champaura")) { if (spawned) { PetAura_SetOrCycle(client); ShowChampMenu(client); } }
    else if (StrEqual(info, "champsize")) { if (spawned) OpenResizePetMenu(client); }
    else if (StrEqual(info, "champmoves")) { if (spawned) OpenPetEmoteMenu(client); }
    else if (StrEqual(info, "champabilities")) OpenAbilitiesPetMenu(client);
    else if (StrEqual(info, "champmethod")) ShowPoppyMethodMenu(client);   // v77: bot/dps/tank/sup
    else if (StrEqual(info, "champtravel")) { if (spawned) OpenTeleportPetMenu(client); }
    else if (StrEqual(info, "champstats")) ShowChampStatsMenu(client);
    else if (StrEqual(info, "champkit")) { Champ_KitInfoText(client); ShowChampMenu(client); }
    else if (StrEqual(info, "champtalk")) { PetTalk(client); ShowChampMenu(client); }   // frases del companion

    return 0;
}

void ShowChampSelectMenu(int client)
{
    Menu menu = new Menu(MenuHandler_ChampSelect);
    menu.Pagination = 7;

    menu.SetTitle("Elige tu campeon:\nNivel y bajas por campeon (persistente)\n ");

    char display[96], info[8];
    for (int i = 0; i < CHAMP_COUNT; i++)
    {
        FormatEx(display, sizeof(display), "%s (%s) — Nv %d",
            g_sChampNames[i], g_sChampLoL[i], g_iChampLevel[client][i]);
        IntToString(i, info, sizeof(info));
        menu.AddItem(info, display);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_ChampSelect(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Cancel)
    {
        if (item == MenuCancel_ExitBack) ShowChampMenu(client);
        return 0;
    }
    if (action != MenuAction_Select) return 0;

    char info[8];
    menu.GetItem(item, info, sizeof(info));
    int idx = StringToInt(info);
    if (idx >= 0 && idx < CHAMP_COUNT)
        Champ_Select(client, idx);
    ShowChampSelectMenu(client);
    return 0;
}

void Champ_Select(int client, int idx)
{
    if (idx < 0 || idx >= CHAMP_COUNT) return;
    if (g_iChampSel[client] == idx) return;

    g_iChampSel[client] = idx;
    strcopy(g_sPet_Name[client], sizeof(g_sPet_Name[]), g_sChampNames[idx]);

    // reinicia el estado de combate/cooldowns del campeon anterior
    g_iChampMarkRef[client] = -1;
    g_fChampMarkUntil[client] = 0.0;
    g_fChampFuryUntil[client] = 0.0;
    g_fChampAspdUntil[client] = 0.0;
    g_fChampQEmpowerUntil[client] = 0.0;
    g_iChampStacks[client] = 0;
    g_fChampNextQ[client] = 0.0;
    g_fChampNextW[client] = 0.0;
    g_fChampNextE[client] = 0.0;
    g_fChampNextR[client] = 0.0;
    g_fChampNextP[client] = 0.0;
    g_iChampTarget[client] = -1;
    Champ_DashCancel(client);          // detiene embestidas en curso
    g_bChampZoneActive[client] = false;   // apaga zonas activas

    if (IsPetValid(client))
    {
        // reemplazo instantaneo (RemovePet v1.3 limpia todo de forma segura)
        RemovePet(client);
        char model[PLATFORM_MAX_PATH];
        ChampModelFor(client, model, sizeof(model));
        SpawnPet(client, model);
    }

    g_bChampWanted[client] = true;   // v49: elegir = quererlo convocado
    SavePetCookies_Settings(client);
    CPrintToChat(client, "{green}[Companion]{default} Campeon elegido: {olive}%s{default} (%s) — Nv %d.",
        g_sChampNames[idx], g_sChampLoL[idx], g_iChampLevel[client][idx]);
    if (idx == 1) PoppyEmit(POP_SEL, client, "", 1.0, SNDLEVEL_TRAIN);   // v27: SFX de seleccion
    Champ_KitInfoText(client);
}

void ShowChampStatsMenu(int client)
{
    Menu menu = new Menu(MenuHandler_ChampStats);
    menu.Pagination = 7;

    char title[192];
    FormatEx(title, sizeof(title), "Progreso de campeones (SQLite persistente)\nBD: %s\n ",
        g_bPetDBOK ? "OK" : "SIN PERSISTENCIA");
    menu.SetTitle(title);

    char display[96], info[8];
    int totalKills = 0;
    for (int i = 0; i < CHAMP_COUNT; i++)
    {
        totalKills += g_iChampKills[client][i];
        FormatEx(display, sizeof(display), "%s%s — Nv %d · XP %d/%d · %d bajas",
            (i == g_iChampSel[client]) ? "» " : "",
            g_sChampNames[i], g_iChampLevel[client][i], g_iChampXP[client][i],
            ChampXPToNext(g_iChampLevel[client][i]), g_iChampKills[client][i]);
        IntToString(i, info, sizeof(info));
        menu.AddItem(info, display, ITEMDRAW_DISABLED);
    }
    FormatEx(display, sizeof(display), "TOTAL: %d bajas de campeones", totalKills);
    menu.AddItem("champtotal", display, ITEMDRAW_DISABLED);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_ChampStats(Menu menu, MenuAction action, int client, int item)
{
    if (action == MenuAction_End) { delete menu; return 0; }
    if (action == MenuAction_Cancel)
    {
        if (item == MenuCancel_ExitBack) ShowChampMenu(client);
        return 0;
    }
    if (action == MenuAction_Select) ShowChampStatsMenu(client);
    return 0;
}

void Champ_KitInfoText(int client)
{
    int sel = g_iChampSel[client];
    CPrintToChat(client, "{green}[%s]{default} {olive}Q{default} %s", g_sChampNames[sel], g_sChampQ[sel]);
    CPrintToChat(client, "{green}[%s]{default} {olive}W{default} %s", g_sChampNames[sel], g_sChampW[sel]);
    CPrintToChat(client, "{green}[%s]{default} {olive}E{default} %s", g_sChampNames[sel], g_sChampE[sel]);
    CPrintToChat(client, "{green}[%s]{default} {olive}R{default} %s", g_sChampNames[sel], g_sChampR[sel]);
    CPrintToChat(client, "{green}[%s]{default} {olive}P{default} %s", g_sChampNames[sel], g_sChampP[sel]);
    CPrintToChat(client, "{green}[%s]{default} IA: salva > ultimate > combo > horda > poke | Vel. ataque: %.2f/s",
        g_sChampNames[sel], ChampAttackRate(client));
}

// ============================================================================
// SUMMON / DISMISS / PEGAMENTO CON LA NAVE (exclusividad mutua)
// ============================================================================

void Champ_Summon(int client)
{
    // exclusividad mutua: invocar al campeon retira la nave (nivel intacto)
    if (PetIsActive(client))
    {
        TerminatePet(client, false);
        CPrintToChat(client, "{green}[Companion]{default} La nave se retira para dar paso a tu campeon.");
    }

    char model[PLATFORM_MAX_PATH];
    ChampModelFor(client, model, sizeof(model));
    SpawnPet(client, model);
    g_bChampWanted[client] = true;   // v49: volvera solo en mapa/ronda/respawn

    int sel = g_iChampSel[client];
    CPrintToChat(client, "{green}[%s]{default} (%s) a tu servicio — {olive}Nv %d{default}, %s.",
        g_sChampNames[sel], g_sChampLoL[sel], g_iChampLevel[client][sel], g_sChampTitle[sel]);
    Champ_KitInfoText(client);
    SavePetCookies_Settings(client);
}

// la nave pide el sitio: retira al campeon activo (llamado desde CallPet)
void Champ_DismissForPlane(int client)
{
    if (!IsPetValid(client)) return;
    RemovePet(client);
    g_bChampWanted[client] = false;   // v49: la nave toma el relevo
    SavePetCookies_Settings(client);
    CPrintToChat(client, "{green}[Companion]{default} %s se retira: la nave toma el relevo.",
        g_sPet_Name[client]);
}

// limpieza de combate al retirar el campeon (llamado desde RemovePet)
void Champ_OnRemoved(int client)
{
    g_iChampTarget[client] = -1;
    g_fChampNextAttack[client] = 0.0;
    g_fChampNextQ[client] = 0.0;
    g_fChampNextW[client] = 0.0;
    g_fChampNextE[client] = 0.0;
    g_fChampNextR[client] = 0.0;
    g_fChampNextP[client] = 0.0;
    g_fChampFuryUntil[client] = 0.0;
    g_fChampAspdUntil[client] = 0.0;
    g_fChampQEmpowerUntil[client] = 0.0;
    g_iChampStacks[client] = 0;
    Champ_DashCancel(client);          // detiene la embestida en curso
    g_bChampZoneActive[client] = false;   // apaga la zona activa

    if (g_iChampMarkRef[client] != -1)
    {
        int mark = EntRefToEntIndex(g_iChampMarkRef[client]);
        if (mark > 0 && mark <= MaxClients && IsClientInGame(mark))
        {
            SetEntProp(mark, Prop_Send, "m_iGlowType", 0);
            SetEntProp(mark, Prop_Send, "m_glowColorOverride", 0);
        }
        g_iChampMarkRef[client] = -1;
        g_fChampMarkUntil[client] = 0.0;
    }
}

// guardar y limpiar al desconectar (llamado desde OnClientDisconnect de la nave)
void Champ_SaveDisconnect(int client)
{
    ChampSaveProgress(client);

    g_bChampLoaded[client] = false;
    g_sChampSteam[client][0] = '\0';
    g_iPoppyMethod[client] = POPPY_M_BOT;   // v77: se recarga sola al reconectar
    g_fPoppyFastNext[client] = 0.0;
    for (int i = 0; i < CHAMP_COUNT; i++)
    {
        g_iChampLevel[client][i] = 1;
        g_iChampXP[client][i] = 0;
        g_iChampKills[client][i] = 0;
    }
    g_iChampSel[client] = 0;
    g_iChampSouls[client] = 0;
    g_iChampKillsMap[client] = 0;
    g_iChampMsgKills[client] = 0;
    g_iChampMsgXP[client] = 0;
    g_iChampStacks[client] = 0;
    g_bChampZoneActive[client] = false;
    Champ_DashCancel(client);

    if (client > 0 && client <= MaxClients && g_hChampStagCancel[client] != null)
    {
        KillTimer(g_hChampStagCancel[client]);
        g_hChampStagCancel[client] = null;
    }
}

// lineas de estado para !petstatus (panel unico: nave + campeon)
void Champ_StatusLines(int client)
{
    int sel = g_iChampSel[client];
    ReplyToCommand(client, "%s Campeon: \x04%s (%s)\x05 [Nv %d | XP %d/%d] | Bajas: %d",
        CHAT_PREFIX, g_sChampNames[sel], g_sChampLoL[sel], g_iChampLevel[client][sel],
        g_iChampXP[client][sel], ChampXPToNext(g_iChampLevel[client][sel]), g_iChampKills[client][sel]);
    if (ChampIsActive(client))
        ReplyToCommand(client, "%s Campeon invocado: \x04ACTIVO\x05 | Ataque: %d de dano | Vel. ataque: %.2f/s (%.0f%%) | Persistencia: %s",
            CHAT_PREFIX, RoundToNearest(ChampBaseDamage(client)), ChampAttackRate(client),
            (ChampAttackMult(client, GetGameTime()) - 1.0) * 100.0, g_bPetDBOK ? "SQLite OK" : "OFFLINE");
    else
        ReplyToCommand(client, "%s Campeon: no invocado (menu \x04!pet\x05 -> Campeones o \x04!champ\x05).",
            CHAT_PREFIX);
    ReplyToCommand(client, "%s Kit automatico: \x04Q\x05 %s | \x04W\x05 %s | \x04E\x05 %s",
        CHAT_PREFIX, g_sChampQ[sel], g_sChampW[sel], g_sChampE[sel]);
    ReplyToCommand(client, "%s                 \x04R\x05 %s | \x04P\x05 %s",
        CHAT_PREFIX, g_sChampR[sel], g_sChampP[sel]);
}

// ============================================================================
// COMANDOS DE CAMPEONES
// ============================================================================

public Action Cmd_ChampMenu(int client, int args)
{
    if (client == 0)
    {
        ReplyToCommand(client, "[Companion] Este comando solo funciona desde el juego.");
        return Plugin_Handled;
    }
    if (GetClientTeam(client) != 2 || !IsPlayerAlive(client))
    {
        CReplyToCommand(client, "{Green}[Companion] {default}Solo supervivientes vivos pueden usar esto.");
        return Plugin_Handled;
    }
    ShowChampMenu(client);
    return Plugin_Handled;
}

public Action Cmd_ChampStatus(int client, int args)
{
    if (!IsValidClient(client)) return Plugin_Handled;
    ReplyToCommand(client, "==== CAMPEONES (fusion %s) ====", PLUGIN_VERSION);
    for (int i = 0; i < CHAMP_COUNT; i++)
    {
        ReplyToCommand(client, "  %s (%s): Nv %d — XP %d/%d — %d bajas — vel. ataque %.2f/s%s",
            g_sChampNames[i], g_sChampLoL[i], g_iChampLevel[client][i], g_iChampXP[client][i],
            ChampXPToNext(g_iChampLevel[client][i]), g_iChampKills[client][i],
            1.0 / (g_fChampBaseInterval[i] * (g_fChampInterval / 1.8) / ChampAttackMult(client, GetGameTime())),
            (i == g_iChampSel[client]) ? "  << ACTIVO" : "");
    }
    ReplyToCommand(client, "  Persistencia SQLite: %s | IA de prioridades: %s | Efectos: %s",
        g_bPetDBOK ? "OK" : "OFFLINE", g_bChampAI ? "ON" : "OFF", g_bChampFX ? "ON" : "OFF");
    return Plugin_Handled;
}

// ============================================================================
// INICIALIZACION DEL MODULO (llamado al final del OnPluginStart de la nave)
// ============================================================================
void Champ_Init()
{
    // ---- cvars del companion v1.3 (inalterados) ----
    g_Cvar_Pet_Plugin_Enable = CreateConVar("l4d2_pet_plugin_enable", "1", "Enables the companion plugin. 0 = Disable, 1 = Enable.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_Cvar_PetHealCooldown = CreateConVar("l4d2_pet_heal_cooldown", "120", "Sets the cooldown for the pet's healing ability (in seconds).", FCVAR_NOTIFY);
    g_Cvar_PetHealAmount = CreateConVar("l4d2_pet_heal_amount", "20", "Determines the amount of health the Companion heals.", FCVAR_NOTIFY);
    g_Cvar_PetAntipukeCooldown = CreateConVar("l4d2_pet_antipuke_cooldown", "120", "Sets the cooldown for the pet's antipuke ability (in seconds).", FCVAR_NOTIFY);
    g_Cvar_PetReviveCooldown = CreateConVar("l4d2_pet_revive_cooldown", "360", "Sets the cooldown for the pet's revive ability (in seconds).", FCVAR_NOTIFY);
    g_Cvar_PetAmmoRefillCooldown = CreateConVar("l4d2_pet_ammo_cooldown", "360", "Sets the cooldown for the pet's ammo refill ability (in seconds).", FCVAR_NOTIFY);
    g_Cvar_PetAdrenBoostCooldown = CreateConVar("l4d2_pet_adrenboost_cooldown", "120", "Sets the cooldown for the pet's adrenaline boost ability (in seconds).", FCVAR_NOTIFY);
    g_Cvar_Server_MenuSound = FindConVar("sm_menu_sounds");
    g_Cvar_Server_Adren_Duration = FindConVar("adrenaline_duration");

    // ---- cvars de CAMPEONES (van al cfg l4d2_companion.cfg) ----
    g_Cvar_ChampEnable = CreateConVar("l4d2_champ_enable", "1", "0/1: combate de campeones activo (auto-ataque + Q/W/E/R/P automaticas)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_Cvar_ChampRange = CreateConVar("l4d2_champ_range", "350.0", "Rango de auto-ataque del campeon (unidades)", FCVAR_NOTIFY);
    g_Cvar_ChampDmg = CreateConVar("l4d2_champ_dmg", "30", "Dano base del auto-ataque del campeon", FCVAR_NOTIFY);
    g_Cvar_ChampDmgLvl = CreateConVar("l4d2_champ_dmglevel", "3", "Dano extra por nivel del campeon", FCVAR_NOTIFY);
    g_Cvar_ChampInterval = CreateConVar("l4d2_champ_interval", "1.8", "Multiplicador base de cadencia (1.8 = cadencia LoL por campeon)", FCVAR_NOTIFY);
    g_Cvar_ChampCDMult = CreateConVar("l4d2_champ_cdmult", "1.0", "Multiplicador global de cooldowns Q/W/E/R/P (menor = mas rapido)", FCVAR_NOTIFY);
    g_Cvar_ChampXPCommon = CreateConVar("l4d2_champ_xp_common", "3", "XP por comun abatido por el campeon", FCVAR_NOTIFY);
    g_Cvar_ChampXPSpecial = CreateConVar("l4d2_champ_xp_special", "20", "XP por especial abatido por el campeon", FCVAR_NOTIFY);
    g_Cvar_ChampXPTank = CreateConVar("l4d2_champ_xp_tank", "250", "XP por tank abatido por el campeon", FCVAR_NOTIFY);
    g_Cvar_ChampXPWitch = CreateConVar("l4d2_champ_xp_witch", "60", "XP por witch abatida por el campeon", FCVAR_NOTIFY);
    g_Cvar_ChampMaxLevel = CreateConVar("l4d2_champ_maxlevel", "50", "Nivel maximo de cada campeon", FCVAR_NOTIFY, true, 1.0, true, 100.0);

    // ---- v63 (v28): LA GUARDIANA — stats LoL + senuo (solo Poppy) ----
    g_Cvar_PoppyStats = CreateConVar("l4d2_poppy_stats", "1", "v63: stats LoL reales de Poppy (barra de vida, regen, armadura, AD)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_Cvar_PoppyDecoy = CreateConVar("l4d2_poppy_decoy", "1", "v63: senuo de La Guardiana (bot invisible pegado a Poppy que atrae a los infectados)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_Cvar_PoppyDecoyCD = CreateConVar("l4d2_poppy_decoy_cd", "45", "v63: cooldown del senuo (segundos)", FCVAR_NOTIFY);
    g_Cvar_PoppyDecoyMult = CreateConVar("l4d2_poppy_decoy_mult", "5.0", "v63: multiplicador del dano crudo -> barra de vida", FCVAR_NOTIFY);
    g_Cvar_PoppyTankMult = CreateConVar("l4d2_poppy_tank_mult", "2.0", "v63: multiplicador extra si el que golpea es el TANK (taunt real)", FCVAR_NOTIFY);
    g_Cvar_PoppyVision = CreateConVar("l4d2_poppy_vision", "1.3", "v63: multiplicador de vision de Poppy (1.3 = +30%)", FCVAR_NOTIFY);
    g_Cvar_PoppyLeash = CreateConVar("l4d2_poppy_leash", "1400.0", "v63: distancia maxima duena-Poppy antes del teleport de retorno", FCVAR_NOTIFY);
    g_Cvar_PoppyAspd = CreateConVar("l4d2_poppy_aspd", "1.15", "v63: velocidad de ataque base de Poppy (1.15 = +15%)", FCVAR_NOTIFY);
    g_Cvar_PoppyRegen = CreateConVar("l4d2_poppy_regen", "5.0", "v63: multiplicador del regen LoL (9 +0.8 HP5; 5 = jugable)", FCVAR_NOTIFY);
    g_Cvar_PoppyADMult = CreateConVar("l4d2_poppy_ad_mult", "0.6", "v63: afinado del AD real (56 +4/nv) al dano del golpe", FCVAR_NOTIFY);
    g_Cvar_PoppyHUD = CreateConVar("l4d2_poppy_hudmode", "1", "v64: barra de vida HUD de Poppy (1=siempre visible, 2=solo con daño o provocando, 0=apagada)", FCVAR_NOTIFY, true, 0.0, true, 2.0);


    // ---- cvars nuevos v45 ----
    g_Cvar_ChampAspdLvl = CreateConVar("l4d2_champ_aspd_level", "2.5", "v45: +% de velocidad de ataque por nivel (2.5 = +125% a nivel 50)", FCVAR_NOTIFY);
    g_Cvar_ChampAspdCap = CreateConVar("l4d2_champ_aspd_cap", "2.5", "v45: multiplicador maximo de velocidad de ataque", FCVAR_NOTIFY);
    g_Cvar_ChampAI = CreateConVar("l4d2_champ_ai", "1", "v45: IA de prioridades (salvar duegna > ultimate > combo > horda > poke)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_Cvar_ChampFX = CreateConVar("l4d2_champ_fx", "1", "v45: efectos graficos de las habilidades (0 = server modesto)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_Cvar_ChampStagger = CreateConVar("l4d2_champ_stagger", "1.0", "v45: multiplicador de duracion del aturdimiento (stagger real del motor)", FCVAR_NOTIFY);

    GetCvars();
    g_Cvar_Pet_Plugin_Enable.AddChangeHook(ConVarChanged);
    g_Cvar_PetHealCooldown.AddChangeHook(ConVarChanged);
    g_Cvar_PetHealAmount.AddChangeHook(ConVarChanged);
    g_Cvar_PetAntipukeCooldown.AddChangeHook(ConVarChanged);
    g_Cvar_PetReviveCooldown.AddChangeHook(ConVarChanged);
    g_Cvar_PetAmmoRefillCooldown.AddChangeHook(ConVarChanged);
    g_Cvar_PetAdrenBoostCooldown.AddChangeHook(ConVarChanged);
    g_Cvar_ChampEnable.AddChangeHook(ConVarChanged);
    g_Cvar_ChampRange.AddChangeHook(ConVarChanged);
    g_Cvar_ChampDmg.AddChangeHook(ConVarChanged);
    g_Cvar_ChampDmgLvl.AddChangeHook(ConVarChanged);
    g_Cvar_ChampInterval.AddChangeHook(ConVarChanged);
    g_Cvar_ChampCDMult.AddChangeHook(ConVarChanged);
    g_Cvar_ChampXPCommon.AddChangeHook(ConVarChanged);
    g_Cvar_ChampXPSpecial.AddChangeHook(ConVarChanged);
    g_Cvar_ChampXPTank.AddChangeHook(ConVarChanged);
    g_Cvar_ChampXPWitch.AddChangeHook(ConVarChanged);
    g_Cvar_ChampMaxLevel.AddChangeHook(ConVarChanged);
    g_Cvar_ChampAspdLvl.AddChangeHook(ConVarChanged);
    g_Cvar_ChampAspdCap.AddChangeHook(ConVarChanged);
    g_Cvar_ChampAI.AddChangeHook(ConVarChanged);
    g_Cvar_ChampFX.AddChangeHook(ConVarChanged);
    g_Cvar_ChampStagger.AddChangeHook(ConVarChanged);
    AutoExecConfig(true, "l4d2_companion");

    // ---- cookies del companion (visual + autos) ----
    g_hPetSettings = RegClientCookie("l4d2_companion_settings", "Stores pet visual settings", CookieAccess_Protected);
    g_hPetAutoAbilities = RegClientCookie("l4d2_companion_auto_abilities", "Stores pet auto-ability toggles", CookieAccess_Protected);

    // ---- eventos del companion (conviven con los de la nave) ----
    HookEvent("player_spawn", Event_StatusChanged);
    HookEvent("player_team", Event_StatusChanged);
    HookEvent("player_death", Event_StatusChanged);
    HookEvent("player_disconnect", Event_StatusChanged);
    HookEvent("revive_begin", Event_ReviveBegin);
    HookEvent("revive_end", Event_ReviveEnd);
    HookEvent("player_now_it", Event_OnVomit);
    HookEvent("player_no_longer_it", Event_OnUnVomit);

    // ---- comandos de la fusion ----
    RegConsoleCmd("sm_champ", Cmd_ChampMenu, "Menu de campeones (invocar, kit, progreso)");
    RegConsoleCmd("sm_metodo", Cmd_PoppyMethod, "Metodo de combate de Poppy: bot | dps | tank | sup (sin argumento abre el menu)");
    RegConsoleCmd("sm_campeon", Cmd_ChampMenu, "Alias en espanol del menu de campeones");
    RegConsoleCmd("sm_champstatus", Cmd_ChampStatus, "Progreso de tus 8 campeones");
    RegConsoleCmd("sm_companion", Cmd_PetMenu, "Menu fusionado del pet (avion + campeones)");

    // ---- base de datos + motores ----
    InitChampDatabase();
    CreateTimer(0.3, Timer_ChampEngine, _, TIMER_REPEAT);
    CreateTimer(0.1, Timer_ChampLaunchTick, _, TIMER_REPEAT);   // v45: vigilancia de lanzados
    CreateTimer(60.0, Timer_ChampAutosave, _, TIMER_REPEAT);

    CreateTimer(1.0, Timer_FaroWatch, _, TIMER_REPEAT);   // v79: construye la RUTA REAL cuando alguien marcha

    FaroCheckNatives();   // v78: nativos del faro disponibles? (late load; OnMapStart re-checa)

    // carga tardia: cookies + progreso de quien ya este conectado
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;
        if (AreClientCookiesCached(i))
            OnClientCookiesCached(i);
        Champ_DBLoad(i);
    }

    LogMessage("[CHAMP] v49: campeon que vuelve solo al cargar mapa/ronda, Veredicto completo (golpe + leva con nothink/frozen + caida con stagger), E con teletrasporte y empuje de vuelo, stagger solo en habilidades canonicas.");
}
