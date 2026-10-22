/*
 * ======================================================
 *  [MODULO] Sonic The Hedgehog - OM PORT v6.6
 *  (antes v5.4 "Lore & Gameplay Overhaul" custom)
 *
 *  v6.33-OM - EL IMPULSO QUE NUNCA LLEGO (manager 3.77.52, reporte del
 *          owner: "el ragdoll falso no hereda ningún impulso, ni en el
 *          aire ni en el piso — la fuerza del golpe final de Sonic, el
 *          martillo de Amy y la autodestrucción de Metal deberían
 *          empujarlo COMO EMPUJAN LOS AUTOS, con física de verdad").
 *          Autopsia con el fuente del MOTOR en la mano (hl2sdk branch
 *          l4d2: physics_prop_ragdoll.cpp + physobj.cpp + baseentity.cpp
 *          + takedamageinfo.cpp) — el veredicto es comico:
 *            (a) Escribirle velocidad a la ENTIDAD con las PROPS
 *                (m_vecVelocity, m_angVelocity) no mueve NADA: los huesos
 *                sobreescriben la velocidad de la entidad cada tick (v6.9
 *                lo probo a las malas). TeleportEntity-vel es distinto:
 *                el motor lo reenvia al hueso RAÍZ (baseentity.cpp L4296
 *                pPhys->SetVelocity) — eso vuela, pero sin giro por hueso
 *                y sin control. Por eso es el PLAN B, no la receta.
 *            (b) La ONDA env_physexplosion de la v6.11 aplica su fuerza
 *                vía CBaseEntity::VPhysicsTakeDamage -> ApplyForceOffset
 *                SOLO al hueso RAÍZ, y esa fuerza pasa antes por la
 *                licuadora de CalculateExplosiveDamageForce: clamp a
 *                30000, x phys_pushscale, x Damage_NoPhysicsForce de las
 *                reglas del juego — un embudo de condiciones que en este
 *                server termina en CERO. Por eso el doble nace y cae en
 *                seco mientras los autos (CPhysicsProp, otro camino)
 *                si vuelan. Tres versiones cebando el mismo pollo.
 *          EL FIX es la receta GMod LITERAL (alla es una línea de Lua:
 *          ragdoll:GetPhysicsObjectNum(i):SetVelocity(dir*700)): con el
 *          puntero IPhysicsObject de CADA hueso — que el propio motor
 *          deja expuesto en el DATAMAP ("m_pPhysicsObject" = hueso 0 y
 *          "m_ragdoll.list[i].pObject" = huesos 1..23, DEFINE_PHYSPTR
 *          del CRagdollProp público) — le llamamos directo por SDKCall
 *          SetVelocity(lineal, angular) POR HUESO. El impulso entra AL
 *          SIMULADOR vphysics, no a la entidad: arco, tumbado y rebotes
 *          los hace el motor, determinista, como la granada del GMod.
 *          Ver Sonic_RagPhysLaunch para el blindaje (4 sondas semanticas
 *          + L4D_GetServerOS para el +1 de vtable de Linux + plan B
 *          motor puro si algo no cuadra — el peor día de esta función
 *          es el comportamiento de la v6.32).
 *          La onda v6.11 se RETIRO completa (Sonic_RagBlast + serial +
 *          targetname + env_physexplosion): su fuerza jamás llego al
 *          doble en este server. Plan B nuevo = Sonic_RagFlingEngine
 *          (TeleportEntity-vel = SetVelocity del hueso raíz, la ruta
 *          Rouge probada aquí). Los tres embudos (golpe final de Sonic,
 *          martillo de Amy, self-destruct de Metal) + el ritual de la
 *          witch pasan por la cascada sin tocar una línea de sus callers.
 *
 *  v6.32-OM - PATCH DE BALANCE + FIX DEL AGARRE (manager 3.77.50, pedido
 *          literal del owner 2026-10-11: "Su spindash ahora causara 35%
 *          más de dano (en todas sus fases) El Peelout Reducira su
 *          enfriamiento 8 seg tanto su falla como su succes en rescatar
 *          Y Fix al agarre cuando agarra a un survivor hay una
 *          posibilidad que el survivor se suelte sin este hacer nada").
 *          REAPLICADO sobre la línea REAL v6.31 (ADOPCION DEL MONTAJE):
 *          el primer intento se hizo sobre una base vieja (3.77.26) y el
 *          owner lo rechazo — este va sobre SU árbol actualizado.
 *    (1) SPINDASH +35% EN TODAS SUS FASES: TODO el dano de la bola sale
 *        de los mismos 2 convars (toque a especiales = spin_damage;
 *        comunes/witch/barrido frontal/picoada del dropdash = x2;
 *        tank = spin_damage_tank) — subirlos cubre TODA la habilidad de
 *        una vez: sonicom_spin_damage 90 -> 121.5 y
 *        sonicom_spin_damage_tank 105 -> 141.75.
 *    (2) PEEL OUT -8s EN AMBOS CAMINOS: sonicom_peel_cd_rescue 25 -> 17
 *        (exit: rescato a un caido) y sonicom_peel_cd_fail 45 -> 37
 *        (fallo — también aplica si le cancelan la carga en pleno
 *        windup: misma convar).
 *    (3) FIX DEL AGARRE (el carry del peel): DOS causas de "se suelto
 *        solo sin hacer nada" cerradas de raíz:
 *        (a) SALTO HEREDADO — si el pasajero traía el ESPACIO presionado
 *            al montarse (corriendo/saltando cuando Sonic lo agarra), ese
 *            espacio pegado lo eyectaba al frame siguiente. Detector de
 *            FLANCO: el espacio heredado NO cuenta hasta que el pasajero
 *            lo SUELTE (ahi se arma) o lo sostenga 1.0s seguidos.
 *        (b) HUECO BLOQUEADO — con los DOS huecos tapados por geometria
 *            el frame se saltaba, Sonic avanzaba a 800 uu/s y el check
 *            de distancia soltaba al pasajero atrasado "solo". Ahora se
 *            ENROLLA al punto de Sonic (+12z) hasta que la geometria
 *            abra el asiento. Resets del estado nuevo en Eject/ClearState.
 *
 *  v6.6 - INFORME 1 DE CAMPO DEL OWNER (9 puntos, sobre la v6.5):
 *    (1) SONIDOS DEL PEEL: la carrera del Peel Out YA NO emite el
 *        loop de la bola (looping3.wav = "el sonido del spin sonando
 *        como si hiciera el spin a la vez"). El peel queda: carga
 *        (PeelOutChargeUp en loop) -> suelta (PeelOutStart) ->
 *        outta-here/brake. El loop solo existe en la bola.
 *    (2a) RAGDOLL FALSO "COMO UN PUNT": receta del owner — PRIMERO
 *        se le hace TP AL AIRE (+105u, la posición SIEMPRE se mueve:
 *        se desclava del piso) y 0.4s DESPUÉS se le da el empujon de
 *        verdad (rumbo*820 + arco 220, escrita por doble vía
 *        TeleportEntity + m_vecVelocity) + EnableMotion/Wake del
 *        vphysics (el ragdoll recien nacido nace dormido: por eso
 *        "solo cae al piso y queda desparramado" o se queda
 *        clavado). Mismo vuelo para el ragdoll de la witch.
 *    (2b) AL TERMINAR LA BOLA el avatar reaparece SIEMPRE: render
 *        restaurado por triple vía (modo + color alpha 255 +
 *        re-afirmado 0.15s después) y la FSM re-dispara la anim del
 *        estado actual — adios al "invisible hasta que para de
 *        correr".
 *    (3) ANIM DE CARGA DEL PEEL MUCHO MÁS RÁPIDA: la rampa sube de
 *        0.45x a 3.4x (antes terminaba en 1.6x) — Sonic CD puro.
 *    (4) EFECTOS VISUALES: trails TE BeamFollow para la BOLA
 *        (v6.18: el env_spritetrail NUNCA renderizo en L4D2 — migrado
 *        al TE del motor, el mismo mecanismo del trail del speed;
 *        v6.17: TRES capas con los materiales AUTÉNTICOS del
 *        sonicball del GMod — blue_2ndlayer.vmt + blue.vmt x2 — si
 *        están en el VPK; si no, las dos capas laserbeam del v6.6),
 *        para la CARRERA del peel y para el SPEED (zapatos): el
 *        modulo Speed ahora resuelve el avatar de Sonic igual que
 *        hacia con el de Tails (el cuerpo viaja en RENDER_NONE y el
 *        trail/glow al cuerpo no se ve — el mismo error que tenía
 *        Tails). Puente nuevo Sonic_GetAvatarEnts (con la bola
 *        puesta devuelve la BOLA).
 *    (5) AOE CONTRA COMUNES: mientras rueda, la bola barre un cono
 *        frontal de radio sonicom_spin_radius_commons (140u) cada
 *        0.2s y revienta TODOS los comunes del área (dano x2 +
 *        empujon). Especiales y witch SIGUEN con el alcance del
 *        toque de siempre (el rango extra es solo para comunes).
 *    (6) ANIM DE EVASION CON PRIORIDAD REAL: la rama Dodge pasa
 *        ENCIMA de peel/dive/windup (antes perdia contra la carrera
 *        del peel) — dodge > todo excepto incap.
 *    (7) GRACIA CORTA 0.3s PARA VÓMITO Y SPIT (sonicom_dodge_grace_
 *        dot): tras esquivar CUALQUIER cosa, la bilis no vuelve a
 *        cobrar ni el spit del spitter entra durante 0.3s (la eva
 *        se consumia demasiado rápido con los re-spray).
 *    (9) LA EVA ESQUIVA LOS AGARRES: red de seguridad por NETPROPS
 *        en el PreThink — si la lengua/hunter/jockey/carry llegaron
 *        a aplicar (el forward del servidor no bloquéo), se pagan
 *        los anillos de la tabla y se ROMPE el agarre al instante
 *        (receta DollSys: m_*Attacker/Victim a -1 en ambos + walk).
 *        En bola/gracia se rompe GRATIS. Ventana anti-doble-cobro
 *        de 0.75s. La fase de bola/peel ya no se cancela por un
 *        agarre que va a ser esquivado (Sonic_OM_BusyLockedSerious).
 *
 *  v6.5 - RITUAL COMPLETO + DODGE DE CONTROLES (cuarta ronda del
 *    owner, 8 pedidos sobre la v6.4):
 *    (1) RAGDOLL DEL FINAL EN 2 FASES ("primero levantarlo del piso
 *        y después lanzarlo, el impulso actual no se nota"): el
 *        ragdoll falso ya NO nace con la velocidad completa — el
 *        watcher primero lo LEVANTA (pico vertical 550 + giro
 *        aleatorio) y 0.35s después lo LANZA (rumbo*780 + arco 150
 *        + más giro). Dos impulsos separados = vuelo legible. Y al
 *        pasarse el stun, la victima REAL se teletransporta a DONDE
 *        QUEDÓ EL RAGDOLL y de ahi arranca su recuperación.
 *    (2) WITCH SIN EL EFECTO DE AMY: el golpe de la bola ya no usa
 *        WitchFlight_Launch (el home-run del martillo). Ahora es el
 *        MISMO tratamiento que los especiales: congelada (FL_FROZEN
 *        + estrellas) + empujon hacia atras (NADA de vuelo) + dano,
 *        en CADA golpe; y en el FINAL también ritual completo: bola
 *        pegada a la cara, ragdoll falso de la witch volando (se
 *        puede: está congelada) y TP de la witch al ragdoll al
 *        pasarse su stun.
 *    (3) NÚMEROS: stun del golpe final 3.0 -> 4.5s (convar
 *        sonicom_spin_stun_final); dano de la bola 60 -> 90 (+50%)
 *        y contra TANK 105 (+75%, convar propia
 *        sonicom_spin_damage_tank).
 *    (4) EN BOLA NO TE AGARRAN: lengua de smoker, pounce de hunter,
 *        jockey, carry/pummel de charger y el empujon/stagger del
 *        tank NO entran mientras dura la bola/picoada (convar
 *        sonicom_spin_grabguard). Se bloquean ANTES de aplicarse
 *        (forwards de left4dhooks) + cancela el stagger del motor.
 *    (5) PEEL OUT SONIC CD: la carga ahora ACELERA (empieza lenta
 *        0.35x y llega a 1.6x al final de la carga — antes frenaba
 *        al reves) y la anim de carga LOOPEDA hasta soltar (reinicia
 *        al completar el ciclo) + el sonido de carga re-emitido.
 *    (6) HOMING CON BOLA (mismo truco del spin): al lanzarlo Sonic
 *        queda invisible y la ESFERA viaja por el; al impactar (o
 *        cancelar/fallar) Sonic reaparece. El dano del homing YA NO
 *        PUEDE EJECUTAR AL TANK (le deja 1 HP si el golpe lo mataría)
 *        y entre usos hay 1.0s de bloqueo anti-spam.
 *    (7) DODGE DE CONTROLES (tabla del owner, pagado en ANILLOS):
 *        lengua 15 / hunter 16 / jockey 16 / charger (carry, slam y
 *        fling) 30 / vómito 6 / explosión del boomer 15 / witch 22
 *        fijo si el golpe es >25 o el dano exacto si <=24 / tank y
 *        spit del spitter = el dano que entren. La esquiva usa las
 *        anims Dodge1-4 del GMod. TRAS esquivar hay 1.5s de GRACIA
 *        inmune a controles y dano (la lengua no re-entra gratis)
 *        — PERO la gracia NO cubre vómito ni escupitajo (siguen
 *        cobrando). Convars sonicom_dodge_*.
 *    (8) SONIC JAMÁS CIEGO: el vómito del boomer (spray o explosión)
 *        NUNCA deja el efecto de bilis en Sonic — con anillos lo
 *        esquiva entero (cuesta), y sin anillos la bilis cae pero se
 *        LIMPIA al instante (m_itTimer expirado, receta estilo Poppy
 *        del cleanup de vómito).
 *
 *  v6.4 - STUN ESTILO GMOD EN LA BOLA (elección del owner: "usaremos
 *    el de metal" = OM_Stun.inc, el port del sistema de stun del mod
 *    GMod que ya usa Metal) + reglas del owner:
 *    (1) ESPECIALES y WITCH reciben el STUN de verdad por golpe de la
 *        bola: OM_Stun congela (FL_FROZEN + MOVETYPE_NONE + lagged 0 +
 *        botones 0 = estatua) + 3 estrellas de mareo girando (radio 22,
 *        rot time*4, bob sin(t*3+i)*2 — números GMod exactos) + chispas
 *        + tinte + zap. Funciona igual para bots y jugadores (Versus):
 *        la victima humana solo puede MIRAR. Duraciones GMod del Sonic:
 *        1.5s por golpe, 3.0s el final (sonicom_spin_stun / _final).
 *        El push 750 de los SI se retira: un congelado no vuela.
 *    (2) LOS COMUNES YA NO CUENTAN: la bola los revienta como siempre
 *        (dano x2 + empujon) pero NO suman golpe, NO stunean y NO
 *        disparan el golpe final — la tanda solo avanza con especiales
 *        y witch ("el spin no debería bastar impactar commons").
 *    (3) GOLPE FINAL = EL RITUAL COMPLETO DEL GMOD: Sonic se PEGA a la
 *        cara del enemigo (GMod L313: SetPos(victima+35z), quieto
 *        sonicom_spin_locktime s con el drill sonando) y al soltar lo
 *        lanza: ragdoll FALSO de la victima (GMod CreateRagdolLCharacter_
 *        OM) que sale volando a 700 y VIVE HASTA QUE SE PASA EL STUN
 *        mientras el de verdad queda oculto (RENDER_NONE); explosión,
 *        rebote de Sonic y fin de bola. La victima que muere a mitad
 *        recupera su cuerpo visible al instante (watch 0.1s).
 *    (4) WITCH: es ENTITY (no cliente) -> fuera del OM_Stun. Stun
 *        propio: FL_FROZEN (receta Witch_Flight: su IA queda apagada)
 *        + estrellas orbitando; el launch del suite se conserva y al
 *        aterrizar queda clavada con las estrellas hasta expirar.
 *    (5) LIMPIEZA: Sonic_OM_Cancel/EndRoll sueltan el pegado a mitad;
 *        el watch libera ragdolls (stun fin/muerte/mapa) y witch slots;
 *        Sonic_OM_StunOnMapEnd lo llama el manager.
 *    NOTA manager v3.76.4: cableado del ciclo de vida del OM_Stun
 *    (OnPluginStart/OnMapStart/RunCmd/OnMapEnd/Disconnect) que NADIE
 *    llamaba — sin eso el stun de Metal congelaba pero SIN estrellas
 *    ni zap (g_bOMStunAssets false, glow 0). Con este cableado el stun
 *    de Metal también recupera sus efectos.
 *
 *  v6.3 - SPINDASH SIN RE-MONTAJE (diseño del dueño, 3.a ronda):
 *    "haremos invisible a sonic (no lo destruiremos) durante toda
 *    la secuencia; cuando el spin termine lo hacemos visible otra
 *    vez — así evitamos llamar a la pausa". El retorno de la bola
 *    ya NO re-monta el avatar (el "como si hicieramos sc" que a
 *    veces no hacia la pausa y descocaba al avatar): Sonic_Create-
 *    Ball ahora OCULTA el avatar R+L (RENDER_NONE, mismas
 *    entidades VIVAS — la FSM de anim les sigue corriendo) mientras
 *    rueda la bola, y EndRoll / OM_Cancel solo devuelven la
 *    visibilidad + snap de smoothing. Cero re-montajes en combate,
 *    cero pulsos, y el avatar reaparece ya en posición con la anim
 *    que le toca. Blindajes: (a) la FSM no repara la copia L en
 *    pleno ROLL (montarla ahi mostraría un Sonic parado junto a la
 *    bola y dispararía el pulso); (b) si el avatar muriera a mitad
 *    de bola, fallback al montaje SIN pulso del v6.2 — ahora
 *    respetando sonicom_avatar 0; (c) si la bola no nace, el avatar
 *    se des-oculta al instante; (d) el pulso queda SOLO en montajes
 *    de ciclo de vida (spawn/selección/FSM-repair), como Tails.
 *
 *  v6.2 - TRIPLE FIX DE CAMPO (segunda prueba del owner):
 *    (1) CRASH DROPDASH/HOMING: "Property m_Local.m_flFallVelocity
 *        not found" — la propiedad no existe como Prop_Send en L4D2.
 *        En el v5.4 nunca crashio porque el homing que la usaba era
 *        CÓDIGO MUERTO (el Z pristino despachaba al SuperJump). Fix:
 *        helper Sonic_ResetFallVelocity con guard HasEntProp
 *        (Prop_Send -> Prop_Data -> skip silencioso; es redundante:
 *        el hook de dano ya bloquea TODO el DMG_FALL de Sonic).
 *    (2) MUERTE SUCIA (cuerpo del survivor visible + 2 ragdolls): la
 *        muerte de Sonic corria en el hook PRE del manager — ANTES de
 *        que el motor procesara la muerte — y el restore del cuerpo
 *        (Sonic_KillAvatar) dejaba ver el survivor_death_model / el
 *        corpse del mod de ragdolls. Tails nunca sufrió esto porque
 *        SU muerte corre en un hook player_death POST propio. Fix:
 *        paridad EXACTA — Sonic engancha su propio player_death POST
 *        en Sonic_OnPluginStart (como Tails.inc L944) y el manager ya
 *        no lo llama desde el PRE.
 *    (3) PAUSA TRAS EL SPINDASH ("la broma de pausa"): el pulso
 *        pause/unpause sv_pausable (Tails_PauseFix_Trigger) disparaba
 *        al re-montar el avatar AL TERMINAR cada bola — en pleno
 *        combate. Fix: Sonic_CreateAvatar gana pulsePause (default
 *        true); el re-montaje post-bola (EndRoll y OM_Cancel) va SIN
 *        pulso — el swap ya nace encajado (NoInterp + snap). El pulso
 *        queda SOLO en montajes de ciclo de vida (spawn / selección /
 *        reparación tardia de la FSM), como Tails.
 *
 *  v6.1 - HOTFIX ARRANQUE + RAGDOLL EN CAMBIO (dos bugs de
 *    integración reportados por el owner en la primera prueba):
 *    (1) El manager NUNCA llamaba Sonic_OnPluginStart() — en su
 *        OnPluginStart el slot de Sonic quedó con Sonic_OnMapStart()
 *        (herencia del v5.4, que no tenía OnPluginStart). Resultado:
 *        0 convars sonicom_* creados -> "Invalid convar handle 0"
 *        en CADA OnClientPutInServer (además la excepción abortaba
 *        la función antes de los SDKHooks: ni PreThink ni Touch ni
 *        OnTakeDamage), 0 comandos (sm_sonicspindash etc.) y FSM del
 *        avatar muerta (timer creado en OnPluginStart). FIX manager:
 *        Sonic_OnPluginStart() cableado + Sonic_OnMapStart() extra
 *        para late-load (precarga a mitad de mapa, como el pristino).
 *    (2) Cambiar de Sonic a otro personaje (o desconectar) dejaba el
 *        RAGDOLL OM tirado en el piso: CleanupCharModuleState usaba
 *        Sonic_Event_PlayerDeath como limpieza y el v6.0 le había
 *        agregado el ragdoll de muerte. FIX: separación patron Tails
 *        — Sonic_Event_PlayerDeath = SOLO muerte real (ragdoll +
 *        ventana anti-ragdoll); Sonic_CleanupState = limpieza pura
 *        (corta habilidades, mata avatar, restaura cuerpo, SIN
 *        ragdoll). El manager cambio el case del cleanup.
 *    Nada más cambia: habilidades, convars y defaults intactos.
 *
 *  v6.0 - EL SONIC DE GMOD OM (Outcomememories) LLEGA A L4D2.
 *    Fuente: noodles_om_pills_survivors_sonic.lua (2027 líneas,
 *    pack del owner 2026-10-06) + models.zip (sonic.mdl 13792
 *    bytes de tabla de seqs + hedgehog/sonicball.mdl). Portado
 *    siguiendo el PATRON TAILS v5.24 (avatar espejo + FSM +
 *    convars + config única), que ya esta probado en campo.
 *
 *    MAPPING DE TECLAS (Z/X = GMod E/T):
 *      Z  = SPINDASH (en suelo) / DROPDASH (en el aire)
 *           [GMod: KEY_E "DropDash" con Spindash_Duration]
 *      X  = PEEL OUT (carga de piernas -> supervesagogo)
 *           [GMod: KEY_T "PeelOut"]
 *      C  = HOMING ATTACK (el v5.4 encadenable MIGRADO INTACTO
 *           de la Z; nada se pierde, solo se muda de tecla)
 *      sm_sonicwind = el tornado v5.4 queda como COMANDO (sin
 *           tecla: su slot X lo ocupa el Peel Out)
 *
 *    HABILIDADES NUEVAS (GMod -> L4D2, calibrado):
 *    - SPINDASH (Z, suelo): brinco de arranque (vel z 270) +
 *      windup 0.65s congelado en bola (Spindash anim) -> ROLL:
 *      la bola azul (sonicball.mdl) por sonicom_spin_duration s
 *      a sonicom_spin_speed uu/s (GMod 8s / 1000 GMod-u);
 *      atraviesa hordas golpeando TODO lo que toca (dano +
 *      SIStagger_Auto + empuje), gana +10 anillos por golpe y
 *      al 3er golpe (maxhits) sale el FINAL: dropdash_final +
 *      drill, explosión de área y Sonic rebota hacia atras
 *      (GMod: el "drill" sobre el último enemigo).
 *    - DROPDASH (Z, aire): picoada (vel z -700, anim dive) y al
 *      tocar suelo se convierte en ROLL con la duración completa
 *      (GMod: DropDash_Diving / _alt + aterrizaje en bola).
 *      La inmunidad a caida del v5.4 se conserva (el dive la
 *      necesita para no auto-danarse).
 *    - COMBO PEEL->SPIN (GMod DropdashPeelout_useable 1): Z
 *      durante el Peel Out convierte el tiempo restante de
 *      carrera en ROLL de bola (mismo contrato GMod).
 *    - PEEL OUT (X): carga 3s clavado en el sitio (anim
 *      PeelOutStart frenando a 0, sonido de carga) -> suelta:
 *      8s de carrera automática hacia adelante a sonicom_peel_speed
 *      (GMod 1850 -> 800 L4D2 = el 3.5x que el owner aprobo en
 *      Speed_sonic v3.1), girando con el mouse, BRAKING + freno
 *      sonoro al terminar. RESCATE: tocar a un companion
 *      incapacitado lo LEVANTA al instante (GMod: el peel agarra
 *      al downed y lo revive) -> CD corto si rescato (25s) o
 *      largo si no (45s), exacto GMod. v6.14 LLEVAR ("el peel
 *      out según los lua de GMod puede llevar supervivientes
 *      = otros jugadores"): tocar a un companion SANO lo MONTA
 *      detrás de Sonic (hasta 3 asientos) — viaja a la velocidad
 *      de la carrera, dispara montado y salta para bajarse; se
 *      sueltan al frenar, si Sonic es interrumpido o si quedan atras.
 *    - ANILLOS (Rings, Dodgemeter GMod): escudo pasivo. El dano
 *      directo (NO quemaduras/blast/radiación - GMod excluye los
 *      DoT) se absorbe en anillos (50 max, +10 por golpe de bola,
 *      reset por ronda) y Sonic hace el DODGE (Dodge1-4, giro
 *      esquiva del GMod). Sin anillos = dano normal.
 *    - SEGUNDA VIDA: el revive "nervios de acero" v5.4 se
 *      conserva con su switch de admin (g_bSonicRevive_Enable).
 *
 *    AVATAR OM (patron Tails v5.24 aplicado entero):
 *    - sonic.mdl en models/noodles/om/ (VPK de recursos del
 *      owner, igual que tails.mdl). 20 secuencias mapeadas:
 *      idle/walk/run/jump/fall/Spindash/dive/PeelOut/
 *      PeelOutStart/Braking/roll/DownedIdle/DownedWalk/
 *      (idle/walk/run)_lowhealth/Dodge1-4.
 *    - Copia R (todos) + copia L (el dueño, contra-rotada con
 *      sus eye angles: mata el tilt EN SU PANTALLA) + EF_NOINTERP
 *      al nacer (nace encajado, v5.20.5 Tails) + PULSO DE PAUSA
 *      en cada montaje (Tails_PauseFix_Trigger reusado: es la
 *      misma infra sv_pausable del suite).
 *    - En ROLL el avatar se cambia por la BOLA (sonicball.mdl,
 *      models/noodles/om/hedgehog/) con giro visual por tick
 *      (el "ManipulateBoneAngles" de GMod traducido a rotación
 *      local continua del prop).
 *    - Cuerpo del survivor oculto (RENDER_NONE) como Tails.
 *
 *    CONVARS (prefijo sonicom_ NUEVO en g_sSuitePrefixes):
 *      sonicom_avatar 1 / sonicom_ballspin 1
 *      sonicom_ball_z 15 / sonicom_ball_scale 1.25  (v6.16: altura/tamaño del dropballs GMod)
 *      sonicom_spin_speed 600 / sonicom_spin_duration 8
 *      sonicom_spin_damage 60 / sonicom_spin_cd 20 / sonicom_spin_cd_final 27
 *      sonicom_spin_slippery 1 / sonicom_spin_maxhits 3 / sonicom_spin_ringgain 10
 *      sonicom_peel_speed 800 / sonicom_peel_charge 3.0 / sonicom_peel_duration 8
 *      sonicom_peel_cd_rescue 25 / sonicom_peel_cd_fail 45 / sonicom_peel_rescue 1
 *      sonicom_peel_carry 1 / sonicom_peel_carry_max 3  (v6.14: lleva jugadores)
 *      sonicom_trails 1 / sonicom_trails_mat 0  (v6.19 nativo por default; v6.20: 1 = AUTÉNTICOS vía env_spritetrail + fix del render de fbef0102 — el MISMO renderer del SpriteTrail de GMod)
 *      sonicom_rings 1 / sonicom_rings_max 50
 *    (los defaults GMod: Dropdash_cooldownSucess 27 / cooldownLand 35 /
 *     maxhits 3 / ringgain 10 / Peelout charge 3s / duration 8s /
 *     cdSuccess 25 / cdFail 45 / Dodgemeter 50; velocidades
 *     re-calibradas a uu/s L4D2: 1000->600 bola, 1850->800 peel)
 *
 *    SE CONSERVA DEL v5.4 (sin tocar su lógica):
 *    - HOMING ATTACK encadenable (ahora en C) con su LOS, su
 *      re-adquisición en vuelo, su rebote y su CD de cadena.
 *    - INSTA-SHIELD (doble salto aéreo, solo impulso vertical).
 *    - Drop Dash automático por dano de caida (inmunidad).
 *    - Explosión de kill melee (35%) + revive "nervios de acero".
 *
 *  v5.4/v5.2/v5.1/v5.0 (historial del Sonic custom original):
 *    homing encadenable, fix crash Fling, fix witch flotante
 *    (WitchFlight), LOS del escaneo, insta-shield, sonic wind,
 *    inmunidad de fuego amigo en vuelo. Ver cabecera anterior
 *    en el historial del zip v522_final_fullsource.
 * ======================================================
 */

#if defined SONIC_INCLUDED
    #endinput
#endif
#define SONIC_INCLUDED

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
#if !defined _witch_flight_included
    #include <Witch_Flight>
#endif
#if !defined _om_stun_included
    #include <OM_Stun>      // v6.4: sistema de STUN del mod GMod (el de Metal): freeze + estrellas
#endif

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

#if !defined SONIC_INDEX
    #define SONIC_INDEX 0
#endif

// v6.24: EL PEEL DE VERDAD — ANÁLISIS FOTOGRAMA A FOTOGRAMA del video
//   de prueba del owner (05:50, testeando la 3.77.16) contra el video
//   del GMod (04:54, dash entre t=2.75 y 4.25). El veredicto del owner:
//   "Esta igual... No se parece a la de Gmod ni bueno en nada" — y el
//   video le da razón, las 3 causas raíz:
//   (a) LA BANDA AZUL PLANA: el trail nativo v6.23 usaba el CHIP blue2
//       (2x2 solido) que en el renderer TE = una BANDA RECTANGULAR
//       SATURADA de borde duro (fade 3 = corte a tijera en la cola)
//       tapando al personaje; en el video GMod la banda es SUAVE,
//       palida (azul hielo $color2 [0.8 0.9 1] = 204 230 255) y se
//       difumina. FIX: el nativo vuelve al LASERBEAM (radial suave,
//       aditivo) tintado azul palido + fade 200 (cola que se apaga
//       gradual) — el chip queda SOLO para el auténtico (allí lo
//       dibuja el renderer del SpriteTrail de GMod como es debido).
//   (b) LOS POLIGONOS ROJOS RIGIDOS: las estelas de pies v6.23 eran
//       BeamPoints ENCADENADOS cada 0.2s — a 800 uu/s cada segmento
//       media 160u RECTO = cuadrilateros con esquinas al girar (el
//       "flat geometric polygon with sharp straight edges" del
//       análisis del video). En GMod son 2 SpriteTrail suaves PEGADOS
//       a los pies (attachments 2/3, 6->1, 0.75s). FIX: 2 info_targets
//       parentados a los PIES (+-8 lateral, +8z — giran con el
//       personaje) y BeamFollow laserbeam ROJO sobre ellos: el beam
//       samplea el target POR FOTOGRAMA en el cliente = curva suave
//       como la del trail principal (misma receta que ya funciona).
//   (c) LA NUBE QUE NO SALIA: la niebla azul (LA firma del look GMod —
//       alla 16 humos + 16 glows POR FOTOGRAMA alrededor del corredor)
//       dependía de om_bluesmoke.vmt (mats v3) que NO estaba instalado
//       en el server del owner = fallback glow01 alpha 80 = casi
//       invisible; y sin sonic_dashing_effect no había moons. FIX:
//       la MASA de la nube ahora es un env_steam DEL PROPIO MOTOR
//       (entidad stock, CERO material, SIEMPRE se ve): uno AURA que
//       sube alrededor del cuerpo (+26z) + uno ESTELA hacia atras
//       (+20z), color humo GMod exacto (135 185 255); la carga gana
//       su NUBE GRIS (peeloutdust2_OM) con el mismo env_steam a los
//       pies. El cloud tick queda para lo que el steam no da: 2 humos
//       om_bluesmoke si el material esta (textura extra), 3 glows
//       glow01 más chicos y brillantes (chispas) y el moon. Los 4
//       archivos de icons/ van AHORA DENTRO del zip de la suite.
//   (d) BUG PREEXISTENTE: el COMBO peel->spin (Z durante la carrera)
//       ponía fase 0 sin matar las entidades del trail — beams, luz
//       (y ahora el steam) quedaban VIVOS PARA SIEMPRE hasta morir.
//       Ahora el combo también hace KillPeelTrail. (En GMod el trail
//       sigue unos segundos tras el combo; aquí muere en el momento —
//       desviación documentada a cambio de no filtrar entidades.)
// v6.23: LOOK DEL PEEL AL ESTILO GMOD (feedback del owner 2026-10-08 con
//   capturas del 04:50 + video del GMod original: "efectos incorrectos
//   (l4d2) peelout ... el Gmod está hecho de diferente manera — debes
//   revisar los lua de Gmod"). Diagnostico de las capturas vs el video:
//   la nube gigante uniforme que flotaba detrás/arriba del personaje =
//   3 excesos nuestros: (a) GLOWS a escala 0.60-0.85 (60-85u — alla son
//   45-55u), (b) FLASH blanco a escala 1.6 (160u!), (c) light_dynamic
//   radio 220 brightness 2 a +40z (altura de cabeza) lavando de azul la
//   niebla y las paredes — en el GMod NO hay dlight en la carrera: la
//   "luz" que recuerda el owner son los GLOW PARTICLES aditivos. Correcciones
//   a valores GMod EXACTOS (bloque Think L1591-1661 + effects lua):
//   (1) GLOWS 45-55u (0.45-0.55) alpha 100 Color(125,125,175) — 5 por
//   latido; HUMOS 20-25u (0.20-0.25) Color(135,185,255) — 8 por latido
//   (masa de la nube, era 3); ambos con dispersión aleatoria alrededor
//   del emisor (pos+27z+fwd*10) y desvanecido por I/O Alpha->0.
//   (2) MOON (sonic_peelout_moons): ya no un puntito estático — nace
//   DETRÁS del corredor (offset -fwd*20-60, alla el espiral back-offset
//   0->80) a 30-55u intentando CRECER x2.2 al 50% de vida (input Scale
//   vía AddOutput; si el input no existiera en L4D2 queda estático sin
//   romper nada) — el sonic_dashing_effect es un arco creciente azul-cian
//   (85-90% transparente) que vuela hacia atras.
//   (3) FLASH BLANCO 1.6 -> 0.45 (glow de tamanio cuerpo, no pantalla).
//   (4) LUZ del peel: radio 220->150, brightness 2->1, altura +40z (cabeza)
//   -> +20z (cuerpo): brilla azul en la oscuridad SIN lavar la niebla
//   entera de azul (la bola conserva su luz 220/2 — sin quejas de ella).
//   (5) TRAIL PRINCIPAL NATIVO CON LA TEXTURA REAL: blue2.vmt es un chip
//   2x2 UNIFORME (shared_t + $color2 [0.8 0.9 1]) = inmune a la
//   orientación del mapeo U/V de los TE beams (el problema del v6.17 era
//   de bluetrail/bluestartrail2, texturas de PERFIL) — con el pack de
//   materiales instalado, el BeamFollow nativo usa blue2 tintado BLANCO
//   (la banda azul suave y plana del GMod) aunque sonicom_trails_mat sea 0;
//   los PIES usan Sonicred (chip rojo, mismo truco) tintado blanco;
//   sin el pack: laserbeam tintado como siempre. (6) POLVO DE CARGA:
//   crece 3-6 -> 10-20 alla (SetStartSize 3-6 SetEndSize 10-20 del
//   sonic_peeloutdust2_OM) — aquí 0.05-0.09 intentando crecer x2.2 al 40%;
//   4 puffs por gate. Cero gameplay, cero cvars.
// v6.22: NUBE AZUL DEL PEEL OUT + 3a CAPA AZUL (feedback del owner
//   2026-10-08: "falta el efecto y demas cosas que tenía el Peelout en
//   el original de Gmod — el peel tenía el efecto rojo de los pies y
//   la luz, ambos y muchos efectos de estela" + "ese efecto no debería
//   ser morado debería ser azul (el del spindash y el peelout)").
//   (1) AZUL NO MORADO: la 3a capa de la bola (el Color(255,0,255) del
//   fadeeiie L1927-1935) pasa a AZUL PROFUNDO {35,90,255} en las tres
//   ramas (nativo TE / auténtico env_spritetrail / fallback) — en GMod
//   el tinte magenta caía sobre una textura azul (se leia azul-violeta
//   sutil); sobre el laserbeam blanco de L4D2 se leia ROSA chillon.
//   (2) NUBE DE LA CARRERA: port del bloque visual del Think L1588-
//   1662 que faltaba — cada 0.1s alrededor del corredor: HUMO AZUL
//   (particle_smokegrenade Color(135,185,255) alla; textura propia
//   om_bluesmoke generada 128x128 + fallback glow01 tenue) + GLOWS
//   (light_glow02_add Color(125,125,175) alla; glow01 aquí) + 1 MOON
//   (sonic_peelout_moons: quads sonic_dashing_effect del pack original
//   512x512 DXT5 tal cual). Batería de env_sprites efimeros SIN parent
//   en posición de MUNDO + Kill diferido por I/O: cada puff queda donde
//   nació y el corredor se aleja = la nube queda detrás sola (el mismo
//   resultado del emitter GMod con air resistance 255), CERO riesgo del
//   bug del cielo v6.21 (nada parentado). Densidad recalibrada: 3 humos
//   + 2 glows + 1 moon por latido (~60/s, pico ~30 vivos vs los 32/0.1s
//   con física de cliente de alla).
//   (3) POLVO DE LA CARGA: port del sonic_peeloutdust2_OM (L795-807 —
//   pasos durante la carga): mismos puffs en GRIS (180,180,180) a los
//   pies detrás, gate 0.2s. (4) FLASH BLANCO de arranque: el
//   glow_duration_white del GMod (L1701 al apretar la tecla / L1778 al
//   soltar) = glow01 blanco 0.2s. Gates FileExists + precache + tabla
//   de descargas para om_bluesmoke y sonic_dashing_effect (mismo
//   patron de los 5 materiales anteriores). Nota: sonic_sparkle_OM y
//   SonicTrail_OM analizados y DESCARTADOS — el primero esta COMENTADO
//   en el Lua original (L1487 dentro de --[[ ]]) y el segundo no tiene
//   NINGÚN disparador en todo el pack (código muerto). Cero gameplay,
//   cero cvars nuevos.
// v6.21: FIX DEL "TRAIL EN EL CIELO LEJANO" (reporte del owner con
//   capturas 2026-10-08: "los sprites que deberían salir en Sonic durante
//   el spindash y eso aparecen alla a lo lejos" — haces blancos cruzando
//   el cielo + una estructura magenta de alambres gigante, lejos del
//   personaje). El fix del fbef0102 FUNCIONO (las estelas auténticas
//   env_spritetrail SI se dibujan por primera vez) pero nacian en el
//   lugar equivocado. Causa raíz: la receta avatar (world-pos ->
//   SetParent re-basa el offset vivo) se aplicó en el v6.20 leyendo
//   m_vecOrigin del PADRE — pero la BOLA y las copias R/L del avatar son
//   props PARENTADOS al survivor: su m_vecOrigin es la origin LOCAL
//   (~{0,0,15}), NO la de mundo. Cada hijo (3 env_spritetrail de la bola
//   + glow01 + light_dynamic + info_targets +20z del peel) nacia
//   teleportado al (0,0,15) DEL MAPA y el SetParent re-basaba un offset
//   de MILES de unidades: la familia entera volaba por el cielo pegada a
//   un offset gigante que GIRABA con el yaw del survivor (= las formas
//   geometricas de las capturas). FIX: Sonic_WorldOrigin (nuevo; m_vec-
//   AbsOrigin = la absoluta de verdad, GetClientAbsOrigin para players,
//   fallback defensivo) reemplaza las 5 lecturas: Sonic_MakeSpriteTrail /
//   Sonic_MakeTrailTarget / Sonic_MakeBlueLight / Sonic_MakeBallGlow /
//   anillo del pulso en Sonic_OM_RollHit. La receta NO cambia (world-pos
//   -> SetParent), ahora con la world-pos DE VERDAD: offset resultante
//   ~{0,0,0} en la bola y ~{0,0,20} en el trailOrigin del peel = la
//   receta EXACTA del GMod. NOTA: los trails NATIVOS (TE, default) no
//   sufrian el bug (el beam TE lo dibuja el CLIENTE pegado a la
//   entidad); solo el AUTÉNTICO (mat 1) lo padecia. Cero gameplay, cero
//   cvars.
// v6.20: PULIDO DEL LOOK + EFECTO DE GOLPE + AUTÉNTICO env_spritetrail REVIVIDO —
//   el owner trajo el fix del env_spritetrail (fbef0102 smd_spritetrail_fix,
//   original de FrozDark: en L4D2 la estela se dibuja ~1 s y se CONGELA — la
//   entidad sigue viva; un SetScale diferido 0.5 s vía AddOutput+FireUser1 la
//   revive y dibuja para siempre. La necrologia del v6.18 quedaba a medias: la
//   entidad SI dibuja, solo se dormia). MODO AUTÉNTICO (mat 1) vuelve a
//   env_spritetrail + fix = el MISMO renderer del útil.SpriteTrail de GMod
//   (alla también crea env_spritetrail) con los .vmt originales del sonicball.
//   FEEDBACK del owner 2026-10-08: (1) PIES ROJOS del peel visibles como
//   estelas de pie: el trail principal SUBE a +20z en un info_target parentado
//   (la receta trailOrigin del GMod L1211-1215 — el BeamFollow directo al
//   avatar lo dibujaba AL RAS DEL SUELO, el origen del avatar son los pies, y
//   la franja de 16u se tragaba las estelas rojas) y los pies pasan a 6->1 /
//   0.75s exactos del GMod (L1232-1258); (2) azul MÁS POTENTE (alpha 200->250,
//   vida 0.55->0.75 del GMod) + BRILLO AZUL EN LA OSCURIDAD pedido:
//   light_dynamic azul parentado (a la bola en el spin, al player en el peel)
//   + glow01 azul suave pegado a la bola (fullbright: se ve hasta en lo más
//   oscuro); (3) trail de la bola REESCALADO A LA BOLA REAL (sonicball a escala
//   1.25 = ~32u: halo 70->40 pasa a 34->19 apenas más ancho que la bola, nucleo
//   y magenta 40->1 pasan a 24->1 — "el trail es literalmente más grande que la
//   ball"); (4) EFECTO DE GOLPE del spindash portado del sonic_spindashhit del
//   GMod (sonic.lua L234 + effects L203-253): flash sonic_drop_impact en la
//   victima +50z (el PNG del pack convertido a VTF 7.2 RGBA8888 256x256 + VMT —
//   sin el, glow01 nativo), anillo expansivo 10->165 en 0.45s, chispas y PULSO
//   de la bola (alla sonic_attack_glow_duration 0.25s).
// v6.25: "TODOS MECANISMOS PROBADOS" — tercer rechazo del owner (prueba de la
//   3.77.17: "todavia siguen saliendo esas aspas azules solas sin las nubes
//   de particulas ni el Beam azul (que se parece un poco a la de spindash)
//   y las botas de líneas rojas que tenía antes — cada vez estas alejándote
//   más"). AUTOPSIA de la 3.77.17 contra el Lua del GMod (releido COMPLETO,
//   bloque Think L1588-1670 + SpriteTrail L1207-1258 + effects lua L149-197
//   y L256-322): (a) el env_steam NO RENDERIZA en el cliente L4D2 (las 3
//   nieblas — aura, estela y polvo de carga — invisibles: por eso "sin las
//   nubes de particulas" NI EN LA CARGA NI EN LA CARRERA); (b) los pies
//   BeamFollow sobre info_targets lateralmente offseteados no se dejaban
//   ver (la .16 con polylineas SI: "beams rojos brillantes" del VLM); (c)
//   el trail laserbeam ÚNICO a width 16 + los moons ESTÁTICOS gigantes
//   (77-140u naciendo atras) = las "aspas azules" sueltas. RECONSTRUCCION
//   1-a-1 con el Lua, cada pieza en el mecanismo que ESTE server YA
//   demostro que dibuja:
//   (1) NUBE = batería env_sprite (el polvo de la carga .16/.17 SI se veía):
//       5 humos alpha-blend Color(135,185,255) 28-44u + 5 glows aditivos
//       glow01 Color(125,125,175) 66-92u POR LATIDO 0.1s (la FSM ya corre
//       a 10 Hz = cadencia exacta del pealoutEffectcd2 GMod), vida 0.4-1.0s,
//       alrededor de pos+27z+fwd*10 — la niebla densa que envuelve y queda
//       atras. om_bluesmoke si esta (textura fiel), glow01 si no (misma
//       lectura). (2) MOONS = el efecto sonic_peelout_moons de verdad: 1
//       arco por latido (0.1s exacto como alla) NACIENDO EN EL CUERPO
//       +35z (no detrás: alla nace en el corredor y el back-offset 0->80
//       lo deja atras VIVO), 16->112 creciendo (input Scale a mitad de
//       vida), 0.5s, fade — el corredor lo abandona y lee como arco de
//       velocidad volando atras. (3) PIES ROJOS = polylineas CHAIN de
//       vuelta (lo que SE VEÍA) pero sampleadas cada 0.05s (latido
//       0.2->0.05: segmentos de 40u a 800 uu/s = curva suave, adi
//       poligonos de 160u), 6->1 / 0.75s laserbeam {235,60,60,235}
//       (nativo) o chip Sonicred (mat 1) — UNA por pie como el GMod.
//       (4) BEAM AZUL = 3 CAPAS estilo spindash (pedido literal: "que se
//       parece un poco a la de spindash"): halo 28->14 {90,150,255} +
//       nucleo 15->1 {210,235,255} + acento 15->1 {60,120,255} sobre el
//       info_target +20z (la franja palida flotando SOBRE la línea roja
//       del suelo del video GMod), split dueño/demas intacto; auténtico =
//       blue2 16->1 único como alla. (5) POLVO DE CARGA de vuelta a
//       batería (6 puffs/0.15s, era steam invisible) 3-6->10-20u gris
//       (180,180,180) vida 1.2-2.5s sesgo atras-arriba = L149-197 exacto.
//       (6) env_steam/MakSteam/MakFootTarget ELIMINADOS (cero código
//       muerto). Todo respeta sonicom_trails / sonicom_trails_mat.
//       Cero gameplay, cero cvars, cero materiales NUEVOS.
// v6.26: "LA COSA NEGRA" — cuarto reporte del owner (prueba de la 3.77.18,
//   video 13-20-15-351: "OK ESTAS CERCA"): el peel por fin lee como el
//   GMod (niebla visible + estelas rojas + beam) PERO (1) flotan CUADROS
//   NEGROS de bordes duros con centro blanco-gris alrededor del corredor
//   ("la cosa esta negra"), (2) las líneas rojas siguen viéndose a
//   segmentos ("debes aumentar su hz... el del spindash siempre estuvo
//   pegado, funcionaba a la perfección") y (3) el LASER AZUL atras no se
//   deja leer ("el que antes aparecía a espaldas de sonic... se perdió en
//   los cambios"). DIAGNOSTICO 1-a-1 con VLM sobre el video:
//   (1) LOS CUADROS NEGROS = los humos de la nube: el único env_sprite
//       del suite que NO iba en aditivo — el SpawnPeelPuff rendermode 0
//       (kRenderNormal) dibuja el quad OPAOCO: los texeles transparentes
//       de glow01/om_bluesmoke (RGB 0) pintan NEGRO y solo el nucleo
//       blanco queda = cuadrado negro con centro blanco, el "glow sprite
//       that failed to blend" del VLM, 5-7 dominando la pantalla. TODO
//       sprite que este server dibuja bien (bola, glow, niebla .17, polvo
//       .16) es rendermode 5. FIX: SpawnPeelPuff SIEMPRE aditivo (muere
//       el param mode), humos recalibrados para aditivo (alpha 220->120,
//       escala 0.11-0.17 -> 0.14-0.21: el aditivo apila, con 50/s el
//       nucleo de la masa queda denso sin lavarse a blanco).
//   (2) LAS LÍNEAS ROJAS: el latido general baja 0.05 -> 0.01 = dispara
//       CADA FOTOGRAMA del servidor (los timers no bajan del frame): 30
//       Hz en un server de 30 tick, 60 Hz con su TickrateEnabler — el
//       mismo regimen de muestreo que el BeamFollow del spindash (que el
//       cliente samplea por fotograma y por eso "siempre está pegado").
//       Segmentos de 27u (13u a 60fps) a 800 uu/s = curva continua de
//       verdad. Los BeamFollow no cambian (cada slot lleva SU cadencia
//       life*0.8; el tick solo pregunta "ya toca?").
//   (3) EL LASER AZUL: la 3-capas v6.25 era esbelta (28->14 + 15->1 +
//       15->1, alphas 165-205) y en el video lee como "borracho"/a ratos
//       se pierde — el owner no lo reconoce como EL laser. SUBE a la
//       geometria EXACTA del trail de la BOLA (el que el owner certifica:
//       "se parece un poco a la de spindash... funcionaba a la
//       perfección"): halo 34->19 + nucleo 24->1 + acento 24->1, alphas
//       190-220, sobre el mismo info_target +20z del Lua (la banda
//       flotando SOBRE la línea roja del suelo, L1211-1215).
//   Cero gameplay, cero cvars, cero materiales nuevos.
// v6.27: "LAS ESFERITAS BLANCAS" — quinto reporte del owner (prueba de la
//   3.77.19): "weon y las cositas blancas que había antes?... que las
//   hiciste desaparecieron" + "las esferitas blancas que desapareciste
//   nacen de Torso también y se dispersan aleatoriamente y CAMBIAN el
//   humo blanco (lo dice el lua de Gmod no mms...)". El owner aporta el
//   QC del modelo (Noodles/OM/Sonic.mdl): $attachment "Trail" sobre el
//   bone "Trail" a +19z con la secuencia autoplay "attatchfix" (peso 1
//   SOLO para ese bone: queda FIJO pegado al cuerpo en toda animación —
//   donde GMod enlaza el trail azul, y de ahi los +20z del info_target
//   del Lua L1213 que ya usamos), $attachment "LeftFootTrail"/
//   "RightFootTrail" hijos de los bones de los pies (los attachments 2/3
//   del puppet donde el Lua cuelga los Sonicred — "las rojas están bn
//   salen en sus sapatos") y el bone "Torso" = la pieza del cuerpo.
//   "Las esferitas blancas" del Lua = el efecto OM_tinyball_fleetway
//   (om_noodles_effects_fleetway.lua L657-742): bolitas Material(icons/
//   Fleetways_tiny_balls.png) que nacen de la POSICION DEL BONE "Torso"
//   (matrix:GetTranslation) + rand(-10,10)*1.2 por eje, velocidad
//   VectorRand():GetNormalized()*Rand(15,40)*2 (30-80 uu/s EN CUALQUIER
//   dirección), Color(255,255,255) BLANCAS, alpha 150->0, size 0.5-1->0,
//   vida 1.2-2.5s, gravedad (0,0,Rand(1,3)) suave hacia arriba, cada
//   0.1s (40 intentos x 1/6 de éxito ~ 6.7 por tanda). IMPLEMENTACION:
//   (1) MATERIAL AUTÉNTICO: fleetways_tiny_balls.vmt/.vtf convertido del
//       PNG del pack del owner (70x72 -> 64x64 RGBA8888 VTF 7.2, la
//       estrellita crema-blanca (189,248,185) exacta), gate FileExists +
//       downloads como los otros 5; sin el: glow01 blanco (misma
//       lectura de esferita).
//   (2) Sonic_PeelTinyBall + Sonic_SpawnPeelBall: env_sprite aditivo
//       BLANCO 255,255,255 alpha 150, nace pos+24z (torso) +-12u,
//       escala 0.05-0.09 -> 0 (puntito brillante), vida 1.2-2.5s — y el
//       MOVIMIENTO REAL: SetEntityMoveType(MOVETYPE_FLY) + TeleportEntity
//       con velocity 30-80 uu/s aleatoria (sesgo +z: la gravedad suave
//       del lua) — el ENGINE las dispersa solas, sin timers ni thinks
//       (degradación documentada: si el movetype no simulase, quedan
//       como puffs estáticos — inofensivo). 2-3 por latido 10 Hz (~25/s:
//       alla 67/s eran particulas de CLIENTE sin costo; aquí cada una es
//       un edict — ~46 vivos, el mismo presupuesto que los humos que se
//       van).
//   (3) "CAMBIAN EL HUMO BLANCO": los 5 humos "135 185 255" del
//       PeelCloudTick FUERA (eran el humo blanco-azulado que tapaba la
//       lectura) — la nube de la carrera ahora son LAS ESFERITAS + los 5
//       glows "125 125 175" (las líneas de velocidad aprobadas desde la
//       .18) + moon + luz. El POLVO GRIS de la carga (180,180,180) NO se
//       toca: es el sonic_peeloutdust2_OM del sonic.lua original.
//   INTACTOS por orden del owner: la línea roja ("ya dejalo así"), el
//   aspa azul ("esta bn xq en el Gmod original también sale"), beam
//   azul (ya nace a +20z = el attachment Trail del QC a 19.08z).
//   Cero gameplay, cero cvars, 1 material NUEVO (fleetways_tiny_balls).
// v6.28: HUMO DENSO + BOTAS AL SUELO + sonicom_trails_mat FUERA (orden
//   del owner 2026-10-09 tras probar la .20: "las esferitas si
//   aparecieron... el único peo que queda es el humo azulado que no se
//   ve" + "mira como se ven las botas el gráfico rojo en Gmod y mira
//   como se ve en L4d2" + "ya quita la opción de sonicom_trails_mat
//   ahora estara por defecto en 1... el parche lo arreglo. o sea siempre
//   usara los materiales originales (no los vanilla del l4d2)" + "si
//   en este cambio el humo sigue sin salir ponme un comando que me
//   permita que este cambie por el Beam este nativo que usa el speed
//   para complementar la falta (necera desde el torso)"). ANÁLISIS DE
//   LOS 2 VIDEOS (4 pasadas VLM + mediciones normalizadas por altura de
//   personaje): (a) BOTAS — a igual escala las estelas son casi gemelas
//   en ancho (0.23 vs 0.25 de la altura) y largo; las diferencias REALES
//   son que la L4D2 flota al DOBLE de altura (z+8 tobillo vs ras del
//   suelo) y es textura DEGRADADA translucida (laserbeam radial) vs la
//   cinta SOLIDA opaca del chip Sonicred: pies a z+2, ancho 7->3.5 (sin
//   el taper extremo 6->1 que dejaba la mayor parte del largo en 1-3u),
//   fade 1 (cola suave mínima — el stock TE_* declara FadeLength INT:
//   el fadeTime 0.2 del Lua no es representable) y el chip AUTÉNTICO
//   siempre.
//   (b) HUMO — el video GMod muestra una masa translucida 2-3x el cuerpo
//   que envuelve de la cintura para abajo y derrama atras (200-280px de
//   ancho, cian-blanco cerca del cuerpo -> azul profundo atras); la .20
//   ponía 5 glows tenues de 26-36u que en su video leen como "faint
//   traces": la batería se DOBLA y se agranda — 5 humos om_bluesmoke de
//   45-62u en 2 tonos con sesgo ATRAS (la estela/cape) + 4 glows
//   cian-blanco de 34-46u alrededor (el nucleo brillante). (c) ESFERITAS
//   — el video GMod las muestra como motas REDONDAS suaves cian-blanco
//   (#E0F0FF) con mucho glow que PULSAN en el sitio (el air resistance
//   40 del Lua mata su velocidad enseguida); la .20 las ponía con la
//   estrella crema de fleetways volando a 30-80 uu/s constantes = se
//   regaban lejos: ahora glow01 tintado "224 240 255" alpha 200 y
//   velocidad 10-28 (quedan como un enjambre de motas alrededor del
//   torso). (d) PALANCA NUEVA sonicom_peel_nube: 0 (default) = batería
//   de sprites anterior; 1 = EL BEAM NATIVO DEL SPEED (BeamFollow
//   laserbeam 0.6s 10->1 fade 3 — la receta EXACTA del trail de colores
//   del Speed_sonic) naciendo del TORSO (el mismo info_target +20z del
//   trail principal) — cambio EN VIVO sin reiniciar el peel.
//
// v6.30 (octavo reporte del owner, 2026-10-09) — DOS ORDENES:
//   (A) "el FL_Frozen no sirve con SI xq no son nextbots pero si
//   podemos hacer algo pausar la animación del infectado especial...
//   literalmente es como poner una pausa en su animación obligándole
//   a que quede congelado (como pasaría con el FL_Frozen)": la capa
//   vive en OM_Stun v1.3 (OM_Stun_AnimPause/Tick/Resume — la usan
//   este modulo en el golpe de la bola, Amy en sus martillos y el
//   congelado del rayo de Tails v5.26) — el SI bot deja de animar en
//   el sitio y queda ESTATUA como la witch.
//   (B) "la evasión evitara el stun del tank y el stun de la roca del
//   mismo y también el spindash (ya que como dije no tiene sentido
//   que lo aturdan en spindash)": la roca era EL HUECO — el forward
//   L4D_OnKnockedDown del manager (reason KNOCKDOWN_TANK, la receta
//   del l4d_block_stumble 2.1 de Silvers que el owner paso de
//   referencia) ahora consulta Sonic_TankKnockImmune: evasión ACTIVA
//   (0.5s, incluye la del vómito) + gracia 1.5s + bola (la palanca de
//   siempre sonicom_spin_grabguard, default 1). Y la evasión ACTIVA
//   entra al Sonic_FlingGuard (el dodge del vómito no abre gracia de
//   1.5s y el puño del tank podía colarse en esos 0.5s). El daño
//   (bola invulnerable / gracia) y el stagger (StaggerGuard) ya
//   estaban: con esto el tank NO aturde a Sonic en ninguna de las dos
//   ventanas. Cero cvars nuevos.
//
// v6.29 (septimo reporte del owner, 2026-10-09) — TRES ORDENES:
//   (1) "sigue sin salir es mejor que le dejes el plan de respaldo
//   sonicom_peel_nube 1 por defecto activado": el humo azulado de la
//   batería JAMÁS se dejo ver en su server (dos iteraciones densas
//   cayeron en vacío) — sonicom_peel_nube DEFAULT 1: el BeamFollow
//   nativo del Speed nace del TORSO desde el arranque de cada carrera.
//   OJO CFG: si el Sonic_Suite.cfg ya grabo "sonicom_peel_nube 0"
//   (corriendo la 3.77.21 lo agrego a su default viejo), la
//   reconciliación NO pisa líneas existentes — hay que ponerlo en 1 a
//   mano o borrar la línea (documentado en el CAMBIOS).
//   (2) BOLA DEL SPINDASH EN MODO TP ("el modo TP no muestra bn el
//   spindash... cuando el jugador está cambiando de dirección la bola
//   no cambia su orientación, el cuerpo si"): la bola quedaba PARENTADA
//   al jugador (decisión v6.15: el dueño la mira en propia pantalla) y
//   su yaw dependía de la composición parent-rotation ⊗ angulos
//   locales — en el campo no giraba con los cambios de rumbo. Ahora en
//   modo TP (tails_avatar_tp 1) la bola viaja POR TELEPORT como la R
//   humana: TeleportEntity por tick con angulos de MUNDO directos
//   (pitch = spin, yaw = bodyYaw = dirección REAL del movimiento) +
//   reloj vivo, SIN EF_NOINTERP = todos los clientes la interpolan
//   (el puppet de GMod se mueente igual: por red, para todos). La
//   orientación sigue al rumbo POR CONSTRUCCION — cero composición con
//   los angulos de vista del parent. Modo parentado (tp 0): intacto.
//   (3) EVASION PRIORITARIA A COMPLETAR EN LA COPIA R ("la animación
//   de la evasión nunca se llega a ver... debería ser prioritaria por
//   encima de cualquier otra... debe concretar hasta que la animación
//   acabe... el problema no es el local, el lo ve, sino el R"): la eva
//   quedaba cortada al lock fijo de 0.5s y cualquier cosa que le pisara
//   la secuencia en la R la matava en silencio. Ahora: el lock se
//   ESTIRA tick a tick mientras la secuencia DodgeX siga viva en el
//   modelo (m_flCycle < 0.95, el mismo patron del jump) con tope duro
//   1.2s; y SELF-HEAL: cada latido se verifica el m_nSequence de la
//   copia R contra el índice real aprendido al disparar (sonda
//   SetAnimation + readback, el patron del resolvedor de Amy v91) — si
//   algo lo piso, se RE-DISPARA en el acto en R y L. La eva corre
//   ENTERA y encima de cualquier estado (peelout incluido: al acabar
//   la FSM devuelve la animación que toque).
#define SONIC_OM_VERSION "v6.38-OM"   // v6.38: EL PIN GMod — Sonic_RagPhysPin + Sonic_RagPhysGet: SetPosition/GetPosition/SetVelocityInstantaneous del IPhysicsObject RAIZ por SDKCall_Raw (indices del mismo vphysics_interface.h l4d2: 46/48/51 win +shift lin), la receta literal del killer Lua de Kolossos para el agarre (el hueso ancla en la mano por tick con velocidad a CERO y el resto del cuerpo cuelga por fisica — JAMAS SetParent: el vphysics despierto contra un padre que se mueve acumula velocidad fantasma y el doble sale disparado).   // v6.37: LA BARRA AL CHAT — paleta colors.inc [AZUL survivor lleno/medio — su color / bajo {green}=AMARILLO aviso / SIN ANILLOS! {red}] vía g_iSBarChatColor + throttle sbar_chat_interval/_refresh (la captura del owner mató el rich text del hint: los <font> salen literales en L4D2) | v6.36: LA BARRA DE ANILLOS — pedido del owner 2026-10-15 ("ese mismo tipo de barra debería salir para sonic y todos aquellos que lo usan (silver para su vuelo sonic para su evasión)"): el Dodgemeter (los anillos, su EVA) vive en BARRA GRÁFICA con el motor común SBar del manager 3.77.81 (Sonic_PlayerIs + Sonic_BarState; el hint "Anillos: x/y" se RETIRA — la barra lo reemplaza en vivo)   // v6.35: AMPLIFICADOR + RAGDOLLS PARAMETRIZADOS — (1) Sonic_SpawnFlingRagdollEx(victim, dir, speed, liftMul, tumble): la velocidad del doble DEJA de venir fija de sonicom_ragblast — cada habilidad pone SU fuerza (contras de Amy/Rouge/Knuckles); la vanilla SpawnFlingRagdoll la envuelve con los números de siempre (CERO cambio en spindash); (2) Sonic_DeadFlingCopy(victim, dir, speed, becomeRag): la receta Rouge/Amy del CADaver VOLANDO generalizada al suite (copia prop_ragdoll + impulso por hueso + limpieza 3s — la usan los counters cuando MATAN); (3) el dano directo del suite (bola, embestida, poderes del supertank) pasa por OM_AbilityDamage = amplificador hibrido del OM_Stun v2.2 (x2 + % vs jefes, pedido del owner)   // v6.34: ENVOLTURA PUBLICA Sonic_PhysSetVel — el SDKCall SetVelocity(lineal, angular) del motor v6.33 abierto a PROPS físicos (no-ragdoll), con cache propio del m_pPhysicsObject de CBaseEntity y las mismas 4 sondas; lo usa el MARTILLO LANZADO de Amy v105 para su TUMBLE REAL en vuelo (el m_angVelocity del datamap lo mata el vphysics cada tick — misma lección del doble v6.9)   // v6.33: IMPULSO VPHYSICS DIRECTO POR HUESO (SetVelocity por SDKCall al IPhysicsObject de cada hueso leido del datamap — la receta GMod literal; la onda v6.11 queda de fallback) — fix del "doble que nace y cae en seco"   // v6.32: PATCH DE BALANCE (spin +35% en TODAS sus fases 121.5/141.75, peel cd -8s 17/37) + FIX DEL AGARRE del carry (salto heredado + hueco bloqueado)   // v6.31: ADOPCION EN EL MONTAJE + reemplazo limpio del avatar (manager 3.77.40: fin del barrido en caliente). v6.30: ESTATUA SI + TANK NO ATURDE A SONIC   // v6.19: TRAILS A MATERIAL NATIVO (default) — análisis del pack de materiales ORIGINALES del OM subido por el owner (2026-10-08): los .vmt del sonicball son legítimos (UnlitGeneric $translucent $vertexcolor/$vertexalpha, VTF 7.2 RGBA8888) pero diseniados para el renderer del SpriteTrail de GMod: bluetrail.vtf = barra vertical nucleo-blanco/halo-azul (perfil transversal), bluestartrail2.vtf = 98% TRANSPARENTE con destellos sueltos (la 'capa ancha' es casi aire), blue2/Sonicred = chips 2x2 shared_t/t2. En los TE beams del L4D2 la textura se mapea al reves (U a lo largo del beam) = look bugeado (reporte del owner); el laserbeam radial nativo es inmune a la orientación. NATIVO default con la geometria 3-capas GMod completa (halo 70->40 + nucleo 40->1 + magenta 40->1, aditivas como alla) y el peel gana los 2 pies ROJOS nativos. FIX descargas: Sonic_AddMatToDownloads ahora encola el $basetexture REAL (blue.vmt->bluetrail.vtf etc.; el v6.17 encolaba un blue.vtf INEXISTENTE = damero en clientes). sonicom_trails_mat default 0 (1 = auténtico opt-in). v6.18: FIX DE VISIBILIDAD REAL DE LOS TRAILS — reporte del owner: "ni el nativo ni ese parecen ser visibles". Diagnostico: el env_spritetrail NO renderiza en L4D2 (entidad de la familia HL2/TF2: el cliente de L4D2 no dibuja su estela — invisible con CUALQUIER material, nativo o auténtico; y el parent YA estaba bien puesto: los trails de la bola iban a la BOLA, no al cuerpo invisible — no era eso). Migración al mecanismo que este MISMO server ya demuestra a diario: los TE del motor — TE_SetupBeamFollow (el del trail de colores del speed, Speed_sonic) y TE_SetupBeamPoints (el del laser de Tails). Motor de slots con UN latido global de 0.2s: re-envia cada BeamFollow a life*0.8 (estela continua sin apilar brillo aditivo) y estira las polylineas encadenadas de los pies. BOLA: las 3 capas del GMod en BeamFollow (Width=cabecera EndWidth=cola: blue_2ndlayer 70->40 blanca + blue 40->1 blanca + blue 40->1 MAGENTA). PEEL: blue2 16->1 sobre el AVATAR con split dueño/demas (el beam del dueño sigue su copia L, el de los demas la R — lección del speed v5.20: un beam sobre el survivor RENDER_NONE "sale del aire") + las 2 Sonicred de los pies como encadenadas con offset lateral +-8u (el BeamFollow no tiene offset: única forma de tener DOS estelas de pies). MARTILLO DE AMY (v100-OM): su trail pasa al mismo motor (mismo look 25->2 / 0.3s / blanco). TODO el diseño de materiales v6.17 INTACTO: FileExists -> auténticos, fallback laserbeam nativo, palancas sonicom_trails / sonicom_trails_mat. v6.17: TRAILS CON MATERIALES AUTÉNTICOS DEL GMOD (pedido del owner: verifico que tiene los .vmt del sonicball y pidió ver si los usabamos — NO los usabamos: el v6.6 tradujo el look a laserbeam.vmt nativo). Ahora el spindash usa las TRES capas EXACTAS del fadeeiie del sonic.lua (L1921-1964): blue_2ndlayer.vmt ancha 70->40 blanca + blue.vmt 40->0 blanca + blue.vmt 40->0 con tinte MAGENTA (255,0,255); el peel usa blue2.vmt 16->1 en el cuerpo + los DOS trails de pies ROJOS Sonicred.vmt 6->1 (alla en attachments 2/3 del puppet L1232-1258; aquí offsets fijos +-8u al tobillo, el env_spritetrail no sigue huesos — aproximación documentada). Detección por FileExists al estilo star_stun del OM_Stun (ve los VPK montados): sin los archivos TODO cae al laserbeam nativo del v6.6, CERO dependencia. Palanca: sonicom_trails_mat 1 (0 = forzar nativo).

// =======================
// RECURSOS (VPK de recursos del owner; mismas rutas que GMod OM)
// =======================
#define SONIC_OM_MODEL     "models/noodles/om/sonic.mdl"
#define SONIC_OM_BALL      "models/noodles/om/hedgehog/sonicball.mdl"

// Sonidos REALES del pack OM del owner (sound/om/sonic/*.wav).
// Si alguno falta, EmitSound solo tira warning y sigue (no crash).
#define SONIC_SND_SPIN_CHARGE  "om/sonic/PeelOutChargeUp.wav"   // GMod: windup del dropdash + carga del peel
#define SONIC_SND_SPIN_LOOP    "om/sonic/looping3.wav"          // GMod: Dashing_loop re-emitido cada 2s
#define SONIC_SND_HIT          "om/sonic/SonicHitSound.wav"     // GMod: cada golpe de la bola
#define SONIC_SND_FINAL        "om/sonic/dropdash_final.wav"    // GMod: golpe final (maxhits)
#define SONIC_SND_DRILL        "om/sonic/DropdashDrill.wav"     // GMod: drill del final
#define SONIC_SND_RELEASE     "om/sonic/dropdashrelease.wav"    // GMod: suelta de la bola
#define SONIC_SND_PEEL_START   "om/sonic/PeelOutStart.wav"      // GMod: arranca la carrera
#define SONIC_SND_PEEL_PICKUP  "om/sonic/peeloutpickup.wav"     // GMod: agarra/rescata al companion
#define SONIC_SND_OUTTAHERE    "om/sonic/sonicimouttahere.wav"  // GMod: "I'm outta here" (sin enemigos)
#define SONIC_SND_BRAKE        "om/sonic/sonicbrake.wav"        // GMod: frenado al terminar el peel
#define SONIC_SND_STUN         "om/sonic/stun.wav"              // GMod: post-clash

// FX nativos L4D2 (sprites ya usados por el suite)
#define SONIC_SPRITE_BEAM "materials/sprites/laserbeam.vmt"
#define SONIC_SPRITE_GLOW "materials/sprites/glow01.vmt"

// v6.17: materiales AUTÉNTICOS de los trails del sonicball del GMod
// (spindash = 3 capas: blue_2ndlayer ancha + blue x2, L1921-1964 del
// sonic.lua; peel = blue2 en el cuerpo + Sonicred en los pies,
// L1216-1258). El owner los tiene en el VPK de recursos.
#define SONIC_BALL_MAT_WIDE  "materials/models/noodles/om/sonicball/blue_2ndlayer.vmt"
#define SONIC_BALL_MAT_FADE  "materials/models/noodles/om/sonicball/blue.vmt"
#define SONIC_PEEL_MAT_MAIN  "materials/models/noodles/om/sonicball/blue2.vmt"
#define SONIC_PEEL_MAT_FOOT  "materials/models/noodles/om/sonicball/Sonicred.vmt"
// v6.20: material del FLASH DEL GOLPE del spindash — port del efecto
// sonic_spindashhit del GMod (icons/sonic_drop_impact.png en el pack de
// materiales del owner; el PNG directo solo lo lee GMod => convertido a
// VTF 7.2 RGBA8888 256x256 + VMT UnlitGeneric, mismo formato del pack)
#define SONIC_HITFX_MAT      "materials/icons/sonic_drop_impact.vmt"
// v6.22: materiales de la NUBE del peel — port del bloque Think del
// GMod (L1588-1662): humo azul + glows alrededor del corredor y los
// "moons" (sonic_peelout_moons, quads sonic_dashing_effect en
// espiral). El humo GMod usa particle/particle_smokegrenade (stock de
// GMod, NO viene en el pack del owner) => textura propia generada
// (om_bluesmoke: puff suave procedural 128x128 RGBA8888, blanco — el
// tinte lo pone el rendercolor del env_sprite, la misma textura sirve
// para el humo azul de la carrera Y el polvo gris de la carga); los
// moons usan el sonic_dashing_effect.vmt/.vtf ORIGINAL del pack tal
// cual (512x512 DXT5, legible por L4D2 directo).
#define SONIC_FX_MAT_SMOKE    "materials/icons/om_bluesmoke.vmt"
#define SONIC_FX_MAT_MOON     "materials/icons/sonic_dashing_effect.vmt"
#define SONIC_FX_MAT_TINYBALL "materials/icons/fleetways_tiny_balls.vmt"

// =======================
// FSM DEL AVATAR: 20 estados (secuencias del sonic.mdl)
// =======================
#define SONIC_ANIM_COUNT 20
static const char g_sSonicAnimSeq[SONIC_ANIM_COUNT][24] = {
    "idle",              // 0
    "walk",              // 1
    "run",               // 2
    "jump",              // 3
    "fall",              // 4
    "Spindash",          // 5  (windup de la bola, en el modelo)
    "dive",              // 6  (dropdash en el aire)
    "PeelOut",           // 7  (carrera supervesa)
    "PeelOutStart",      // 8  (carga de piernas)
    "Braking",           // 9  (frenado al terminar el peel)
    "roll",              // 10 (salto rodando)
    "DownedIdle",        // 11 (incapacitado)
    "DownedWalk",        // 12
    "idle_lowhealth",    // 13
    "walk_lowhealth",    // 14
    "run_lowhealth",     // 15
    "Dodge1",            // 16 (giro esquiva al absorber con anillos)
    "Dodge2",            // 17
    "Dodge3",            // 18
    "Dodge4"             // 19
};

// Estados "one-shot" con lock temporal (como el jump de Tails)
#define SONIC_ST_JUMP       3
#define SONIC_ST_SPINDASH   5
#define SONIC_ST_DIVE       6
#define SONIC_ST_PEELRUN    7
#define SONIC_ST_PEELSTART  8
#define SONIC_ST_BRAKING    9
#define SONIC_ST_ROLLJUMP   10
#define SONIC_ST_DODGE      16

// EF_NOINTERP (mismo valor que usa Tails: fix del tilt v5.20.5)
#define SONIC_EF_NOINTERP 8

// =======================
// SWITCHES DE ADMINISTRACION (se conservan del v5.4)
// =======================
bool g_bSonicInstinct_Enable = false;
bool g_bSonicRevive_Enable   = false;

// =======================
// ESTADO v5.4 CONSERVADO (homing / insta-shield / wind)
// =======================
int g_iSonicRevives[MAXPLAYERS + 1];
int g_iSonicJumps[MAXPLAYERS + 1];
int g_iSonicLastButtons[MAXPLAYERS + 1];
float g_fSonicAirDashNext[MAXPLAYERS + 1];

bool g_bSonicHoming[MAXPLAYERS + 1];
int g_iSonicTarget[MAXPLAYERS + 1];
float g_fSonicDashTime[MAXPLAYERS + 1];
float g_fSonicActionCD[MAXPLAYERS + 1];
float g_fSonicWindCD[MAXPLAYERS + 1];

int g_iSonicBeamSprite = -1;
int g_iSonicGlowSprite = -1;

float g_fSonicChainWindowEnd[MAXPLAYERS + 1];
int   g_iSonicChainCount[MAXPLAYERS + 1];

#define SONIC_EXPLOSION_CHANCE 0.35
#define SONIC_AIR_DASH_CD      0.5
#define SONIC_REVIVE_LIMIT     2
#define SONIC_HOMING_CHAIN_WINDOW   2.5
#define SONIC_HOMING_CHAIN_MAX      3
#define SONIC_HOMING_CHAIN_BONUS    400.0
#define SONIC_HOMING_CHAIN_RANGE   900.0
#define SONIC_HOMING_CHAIN_CONE    0.55
#define SONIC_HOMING_REACQ_RANGE   500.0
#define SONIC_HOMING_REACQ_CONE    0.30
#define SONIC_HOMING_CHAIN_CD      2.0
#define SONIC_HOMING_FLIGHT_SPEED  2200.0
#define SONIC_HOMING_FLIGHT_TIME   1.5

// =======================
// ESTADO OM v6.0: SPINDASH / DROPDASH / PEEL OUT / ANILLOS
// =======================
// Fases del spin (GMod Spindash_Duration / spindash_fake / Diving)
#define SONIC_SPIN_NONE    0   // normal
#define SONIC_SPIN_WINDUP  1   // brinco de arranque + carga 0.65s (bola en el modelo)
#define SONIC_SPIN_DIVE    2   // dropdash en el aire (picoada)
#define SONIC_SPIN_ROLL    3   // la bola azul rodando (sonicball.mdl)
#define SONIC_SPIN_FINAL   4   // golpe final: drill + rebote (lock corto)
int  g_iSonicSpinPhase[MAXPLAYERS + 1];       // SonicSpinPhase
float g_fSonicSpinUntil[MAXPLAYERS + 1];       // fin del ROLL (Spindash_Duration)
float g_fSonicSpinWindEnd[MAXPLAYERS + 1];     // fin del WINDUP (0.65s)
float g_fSonicSpinNextHit[MAXPLAYERS + 1];     // por-objetivo: filtro 0.5s (CooldownHit)
float g_fSonicSpinLastHit[MAXPLAYERS + 1];     // global: 0.5s entre golpes (GMod)
int   g_iSonicSpinHits[MAXPLAYERS + 1];        // Hit_OM_sonic: contador hasta maxhits
float g_fSonicSpinCD[MAXPLAYERS + 1];          // Spindash_Cooldown (fin)
float g_fSonicSpinCDDur[MAXPLAYERS + 1];       // Spindash_Cooldown_duration (para HUD)
bool  g_bSonicSpinFinalized[MAXPLAYERS + 1];   // ya salió el final (no repetir por esta tanda)

// Peel Out (GMod PeelOut_duration / _anim / _2 / Cooldown)
int   g_iSonicPeelPhase[MAXPLAYERS + 1];       // 0 nada / 1 cargando / 2 corriendo / 3 frenando
float g_fSonicPeelChargeEnd[MAXPLAYERS + 1];   // fin de la carga (PeelOut_duration_anim)
float g_fSonicPeelRunEnd[MAXPLAYERS + 1];      // fin de la carrera (PeelOut_duration)
float g_fSonicPeelBrakeEnd[MAXPLAYERS + 1];    // ventana del Braking (0.5s)
float g_fSonicPeelCD[MAXPLAYERS + 1];          // PeelOut_Cooldown (fin)
float g_fSonicPeelCDDur[MAXPLAYERS + 1];       // para HUD
bool  g_bSonicPeelSaidOut[MAXPLAYERS + 1];     // "I'm outta here" ya dicho en esta corrida
int   g_iSonicPeelRescues[MAXPLAYERS + 1];     // rescates de la corrida (para el CD success)
float g_fSonicPeelLoopSnd[MAXPLAYERS + 1];     // re-emisión del loop (WAV 2s)
float g_fSonicSpinLoopSnd[MAXPLAYERS + 1];     // idem durante la bola

// v6.14: PEEL OUT LLEVA JUGADORES (pedido del owner: "el peel out
// según los lua de GMod dice que este puede llevar supervivientes
// (o sea en GMod a otros jugadores)"). Asientos detrás de Sonic: el
// pasajero viaja pegado a su estela. El ARRASTRE vive en el PreThink
// del carrier (por frame — a 800 u/s el think de 10 Hz haría saltos
// visibles de 80u); el MONTAJE lo dispara la FSM de fase (10 Hz, un
// sano nuevo por tick, como el rescate de incap de la v6.13).
#define SONIC_PEEL_SEATS    3      // asientos físicos (cvar lo limita)
#define SONIC_PEEL_PICK_R   100.0  // radio de montaje (u)
#define SONIC_PEEL_DROP_R   260.0  // más atras que esto = se solto
int     g_iSonicPeelSeats[MAXPLAYERS + 1][SONIC_PEEL_SEATS]; // EntRefs (0 = libre)
int     g_iSonicPeelCarrier[MAXPLAYERS + 1];  // client del que ME lleva (0 = nadie)
// v6.32 FIX AGARRE: estado anti "se me solto solo" del pasajero.
// g_fSonicPeelMountAt = hora de montaje; g_bSonicPeelJumpArmed = false
// mientras el pasajero NO haya soltado el ESPACIO que traía presionado
// al montarse (ese salto heredado NO cuenta como bajarse a propósito).
float   g_fSonicPeelMountAt[MAXPLAYERS + 1];
bool    g_bSonicPeelJumpArmed[MAXPLAYERS + 1];

// Anillos (GMod Rings / MaxRings / DodgeAnim)
int   g_iSonicRings[MAXPLAYERS + 1];
float g_fSonicDodgeEnd[MAXPLAYERS + 1];        // ventana de la anim Dodge1-4
float g_fSonicRingsHUDNext[MAXPLAYERS + 1];    // throttle del HUD de anillos
// v6.29: la eva a completar — seq real aprendida por readback (self-heal
// contra pisadas) + tope duro del estiramiento del lock
int     g_iSonicDodgeSeq[MAXPLAYERS + 1];      // m_nSequence de la DodgeX activa en el prop R (-1 = no aprendido)
float   g_fSonicDodgeCap[MAXPLAYERS + 1];      // fin del tope duro de la eva (now + 1.2 al disparar)

// v6.5: DODGE de controles (tabla del owner) + homing 1s
float g_fSonicDodgeGraceUntil[MAXPLAYERS + 1]; // gracia 1.5s tras esquivar
float g_fSonicHomingNext[MAXPLAYERS + 1];      // anti-spam del homing (1s)

// v6.6 (informe 1): efectos visuales + AoE comunes + gracia DoT + agarres
float g_fSonicDotGraceUntil[MAXPLAYERS + 1];   // (7) 0.3s anti vómito/spit
float g_fSonicDodgePaidAt[MAXPLAYERS + 1];     // (9) anti doble cobro del dodge
float g_fSonicSpinNextSweep[MAXPLAYERS + 1];   // (5) tick del barrido AoE de comunes
// v6.18: ahora guardan SLOTS del motor TE (no más EntRefs de
// env_spritetrail — esa entidad no renderiza en L4D2)
int   g_iSonicBallTrailR[MAXPLAYERS + 1];      // (4) slot TE: trail ancho de la bola
int   g_iSonicBallTrailW[MAXPLAYERS + 1];      // (4) slot TE: trail fino de la bola
int   g_iSonicBallTrailM[MAXPLAYERS + 1];      // (4) 3a capa de la bola (tinte AZUL profundo v6.22 — era magenta)
int   g_iSonicPeelTrail[MAXPLAYERS + 1];       // (4) slot TE: trail del peel (copia R, los demas)
int   g_iSonicPeelTrailO[MAXPLAYERS + 1];      // (4) v6.18: slot TE del trail del peel para el DUEÑO (copia L)
int   g_iSonicPeelTrail2[MAXPLAYERS + 1];      // (4) v6.25: capa 2 (nucleo claro) del trail 3-capas del peel (copia R)
int   g_iSonicPeelTrail3[MAXPLAYERS + 1];      // (4) v6.25: capa 3 (acento azul) del trail 3-capas del peel (copia R)
int   g_iSonicPeelTrailO2[MAXPLAYERS + 1];     // (4) v6.25: idem copia L (solo el dueño)
int   g_iSonicPeelTrailO3[MAXPLAYERS + 1];     // (4) v6.25: idem copia L (solo el dueño)
int   g_iSonicPeelFootL[MAXPLAYERS + 1];       // (4) v6.17: trail ROJO pie izq del peel (Sonicred.vmt)
int   g_iSonicPeelFootR[MAXPLAYERS + 1];       // (4) v6.17: trail ROJO pie der del peel (Sonicred.vmt)
// v6.20: AUTÉNTICO env_spritetrail (fix fbef0102) + brillo azul + info_targets
int   g_iSonicBallSTrR[MAXPLAYERS + 1];        // v6.20: EntRef trail ancho auténtico (env_spritetrail) de la bola
int   g_iSonicBallSTrW[MAXPLAYERS + 1];        // v6.20: idem capa fina
int   g_iSonicBallSTrM[MAXPLAYERS + 1];        // v6.20: idem 3a capa (rendercolor AZUL v6.22)
int   g_iSonicPeelSTrail[MAXPLAYERS + 1];      // v6.20: EntRef trail peel auténtico (env_spritetrail, copia R)
int   g_iSonicPeelSTrailO[MAXPLAYERS + 1];     // v6.20: idem copia L (solo el dueño)
int   g_iSonicPeelTgt[MAXPLAYERS + 1];         // v6.20: EntRef info_target +20z del trail del peel (copia R)
int   g_iSonicPeelTgtO[MAXPLAYERS + 1];        // v6.20: idem copia L
int   g_iSonicBallGlow[MAXPLAYERS + 1];        // v6.20: EntRef env_sprite glow azul de la bola (brillo en la oscuridad)
int   g_iSonicBallLight[MAXPLAYERS + 1];       // v6.20: EntRef light_dynamic azul de la bola
int   g_iSonicPeelLight[MAXPLAYERS + 1];       // v6.20: EntRef light_dynamic azul del peel (parent al player)
int   g_iSonicPeelNubeBeam[MAXPLAYERS + 1];    // v6.28: slot TE BeamFollow del torso (modo sonicom_peel_nube 1, copia R)
int   g_iSonicPeelNubeBeamO[MAXPLAYERS + 1];   // v6.28: idem copia L (solo el dueño)
// v6.25: los steams (aura/estela/polvo) y los info_targets de pies
// FUERON ELIMINADOS — el env_steam no dibuja en el cliente L4D2 y los
// pies volvieron a las polylineas CHAIN (g_iSonicPeelFootL/R, muestran
// la posición viva del CLIENTE: cero entidades intermedias)
bool  g_bSonicHitFxMat = false;                // v6.20: icons/sonic_drop_impact.vmt presente en el server
int   g_iSonicHitFxMat = 0;                    // v6.20: index precacheado del flash del golpe del spindash
// v6.20: filtros SetTransmit de los env_spritetrail auténticos (split
// dueño/demas — el mismo mecanismo de las copias R/L del avatar)
int   g_iSonicSTOnly[4096];                    // entindex -> userid que PUEDE verlo (0 = todos)
int   g_iSonicSTExcl[4096];                    // entindex -> userid EXCLUIDO (0 = nadie)

// =======================
// AVATAR OM (patron Tails: R + L + EF_NOINTERP + pausa)
// =======================
int   g_iSonicAvatar[MAXPLAYERS + 1];          // EntRef copia R (0 = sin avatar)
int   g_iSonicAvatarL[MAXPLAYERS + 1];         // EntRef copia L (solo el dueño)
int   g_iSonicBall[MAXPLAYERS + 1];            // EntRef de la BOLA en ROLL (0 = ninguna)
int   g_iSonicAnimState[MAXPLAYERS + 1];       // estado FSM actual (-1 = sin setear)
float g_fSonicAnimLock[MAXPLAYERS + 1];        // lock de one-shots (dodge/braking/dive)
float g_fSonicJumpStart[MAXPLAYERS + 1];       // marca del jump (ventana Poppy de Tails)
int   g_iSonicBodyRender[MAXPLAYERS + 1];      // render ORIGINAL del survivor
bool  g_bSonicModelOK = false;                 // sonic.mdl en el VPK
bool  g_bSonicBallOK  = false;                 // sonicball.mdl en el VPK
// v6.17: materiales AUTÉNTICOS de los trails del sonicball del GMod (VPK)
bool  g_bSonicBallMatWide = false;             // blue_2ndlayer.vmt (capa ancha de la bola)
bool  g_bSonicBallMatFade = false;             // blue.vmt (capas de desvanecimiento de la bola)
bool  g_bSonicPeelMatMain = false;             // blue2.vmt (trail de la carrera del peel)
bool  g_bSonicPeelMatFoot = false;             // Sonicred.vmt (trails de los pies del peel)
// v6.18: INDEX de cada material precacheado (los TE piden modelo,
// no ruta; 0 = no disponible -> el gate bool correspondiente manda)
int   g_iSonicTELaser   = 0;                   // laserbeam.vmt (fallback nativo, > 0 tras OnMapStart)
int   g_iSonicTEMatWide = 0;                   // blue_2ndlayer.vmt (capa ancha de la bola)
int   g_iSonicTEMatFade = 0;                   // blue.vmt (capas de desvanecimiento de la bola)
int   g_iSonicTEMatPeel = 0;                   // blue2.vmt (trail de la carrera del peel)
int   g_iSonicTEMatFoot = 0;                   // Sonicred.vmt (trails de los pies del peel)
// v6.22: materiales de la NUBE del peel (gates + index como los demas)
bool  g_bSonicFxMatSmoke = false;              // om_bluesmoke.vmt (humo azul/gris generado)
bool  g_bSonicFxMatMoon  = false;              // sonic_dashing_effect.vmt (los "moons" GMod)
bool  g_bSonicFxMatTinyBall = false;           // fleetways_tiny_balls.vmt (v6.27: las esferitas)
int   g_iSonicFxMatSmoke = 0;                  // index precacheado (0 = no disponible)
int   g_iSonicFxMatMoon  = 0;                  // idem
int   g_iSonicFxMatTinyBall = 0;                // idem
#pragma unused g_iSonicFxMatTinyBall            // v6.28: RESERVADO — las esferitas pasaron a glow01 (video GMod = motas redondas); el material queda cargado y descargándose para que volver a la estrella fleetways sea solo cambiar el DispatchKeyValue "model" de Sonic_SpawnPeelBall
float g_fSonicPeelDustNext[MAXPLAYERS + 1];    // v6.22: gate 0.2s del polvo de la carga
float g_fSonicBallSpin[MAXPLAYERS + 1];        // angulo de giro acumulado de la bola
// seguimiento (mismo sistema de lecciones Tails: yaw suave + deadband)
float g_fSonicBodyYaw[MAXPLAYERS + 1];
float g_fSonicYawLastT[MAXPLAYERS + 1];
float g_fSonicSmLoc[MAXPLAYERS + 1][3];        // contra-rotación local R (amortiguada)
float g_fSonicSmLocL[MAXPLAYERS + 1][3];       // idem copia L
bool  g_bSonicSmSnap[MAXPLAYERS + 1];          // snap al crear (1 tick seco)

// =======================
// CONVARS OM
// =======================
ConVar g_cvSonicAvatar;        // avatar espejo on/off
ConVar g_cvSonicBallSpin;      // giro visual de la bola
ConVar g_cvSonicBallZ;         // v6.16: altura Z local de la bola (GMod +15)
ConVar g_cvSonicBallScale;     // v6.16: escala del modelo de la bola (GMod 1.25)
ConVar g_cvSonicSpinSpeed;     // uu/s de la bola (GMod DropDash 1000)
ConVar g_cvSonicSpinDuration;  // s de bola (GMod 8)
ConVar g_cvSonicSpinDamage;    // dano de la bola
ConVar g_cvSonicSpinCD;        // CD normal (GMod cooldownSucess 27)
ConVar g_cvSonicSpinCDFinal;   // CD tras el golpe final (GMod cooldownLand 35)
ConVar g_cvSonicSpinSlippery;  // GMod Dropdash_slippery: lateral permitido
ConVar g_cvSonicSpinMaxHits;   // GMod maxhits 3
ConVar g_cvSonicSpinRingGain;  // GMod ringgain 10
ConVar g_cvSonicPeelSpeed;     // uu/s del peel (GMod 1850 -> L4D2 800)
ConVar g_cvSonicPeelCharge;    // s de carga (GMod 3)
ConVar g_cvSonicPeelDuration;  // s de carrera (GMod 8)
ConVar g_cvSonicPeelCDRescue;  // CD si rescato (GMod cooldownSuccess 25)
ConVar g_cvSonicPeelCDFail;    // CD si no rescato (GMod cooldownFail 45)
ConVar g_cvSonicPeelRescue;    // levantar incap al tocar (GMod grab+revive)
ConVar g_cvSonicPeelCarry;     // v6.14: llevar companions sanos (el Lua del GMod)
ConVar g_cvSonicPeelCarryMax;  // v6.14: asientos simultaneos
ConVar g_cvSonicRings;         // escudo de anillos on/off
ConVar g_cvSonicRingsMax;      // anillos máximos (GMod Dodgemeter 50)

// v6.4: STUN estilo GMod en la bola (sistema OM_Stun de Metal)
ConVar g_cvSonicSpinStun;        // stun por golpe a especiales [GMod basestun 1.5]
ConVar g_cvSonicSpinStunFinal;   // stun del golpe final [GMod basestun_final 3.0]
ConVar g_cvSonicSpinStunStack;   // re-aturdir suma tiempo (GMod stunstack)
ConVar g_cvSonicSpinLockTime;    // s pegado a la cara en el final [GMod 1]
ConVar g_cvSonicSpinRagdoll;     // ragdoll falso del final (CreateRagdolLCharacter_OM)
ConVar g_cvSonicRagBlast;        // v6.33: velocidad de LANZAMIENTO del doble (u/s, GMod SetVelocity 700); de fallback: magnitud de la onda v6.11
ConVar g_cvSonicSpinStunWitch;   // la witch recibe stun en el final

// v6.5: números del owner + inmunidad de la bola
ConVar g_cvSonicSpinDmgTank;     // dano de la bola contra TANK (60*1.75 = 105)
ConVar g_cvSonicSpinGrabGuard;   // en bola no entran agarres/fling de tank

// v6.5: DODGE de controles (tabla del owner, pagado en anillos)
ConVar g_cvSonicDodge;           // master del dodge de controles + gracia
ConVar g_cvSonicDodgeGrace;      // s de gracia tras esquivar [owner: 1.5]
ConVar g_cvSonicDodgeTongue;     // lengua de smoker [owner: 10-20]
ConVar g_cvSonicDodgeHunter;     // pounce de hunter [owner: 12-20]
ConVar g_cvSonicDodgeJockey;     // jockey [owner: rango del hunter]
ConVar g_cvSonicDodgeCharger;    // charger carry/slam/fling [owner: 30]
ConVar g_cvSonicDodgeVomit;      // vómito del boomer [owner: 5-8]
ConVar g_cvSonicDodgeBoom;       // explosión del boomer [owner: 15]
ConVar g_cvSonicDodgeWitch;      // witch [owner: 20-25 fijo si dano > 25]

// v6.6 (informe 1): AoE comunes + trails + gracia DoT
ConVar g_cvSonicSpinRadiusCommons; // radio del barrido frontal vs comunes (0 = off)
ConVar g_cvSonicTrails;            // trails visuales de bola/peel (env_spritetrail)
ConVar g_cvSonicPeelNube;          // v6.28: nube de la carrera — 0 = batería sprites / 1 = BeamFollow nativo estilo Speed
ConVar g_cvSonicDodgeGraceDot;     // (7) gracia corta post-dodge para vómito/spit

// pegado del golpe final (GMod L264/313: SetPos(enemigo+35z) + quieto 1s)
bool  g_bSonicSpinFinalPending[MAXPLAYERS + 1];  // final en curso (pegado)
int   g_iSonicSpinLockVictim[MAXPLAYERS + 1];    // EntRef del enemigo pegado
float g_fSonicSpinLockUntil[MAXPLAYERS + 1];     // fin del pegado
float g_fSonicSpinLockDir[MAXPLAYERS + 1][3];    // rumbo capturado al golpear

// ragdoll falso del final (la victima REAL queda RENDER_NONE mientras vive)
int   g_iSonicSpinRagRef[MAXPLAYERS + 1];        // EntRef del prop_ragdoll
int   g_iSonicSpinRagRender[MAXPLAYERS + 1];     // render ORIGINAL de la victima

// v6.33 — IMPULSO VPHYSICS DIRECTO POR HUESO (ver bloque grande abajo):
// llamadas SDKCall_Raw contra la interfaz pública IPhysicsObject y los
// offsets del datamap donde el motor guarda los punteros de cada hueso.
Handle g_hRagPhysIsAsleep;     // bool  IsAsleep()          [sonda]
Handle g_hRagPhysMotion;       // bool  IsMotionEnabled()  [sonda]
Handle g_hRagPhysMoveable;     // bool  IsMoveable()       [sonda]
Handle g_hRagPhysMass;         // float GetMass()          [sonda]
Handle g_hRagPhysSetVel;       // void  SetVelocity(const Vector*, const AngularImpulse*)  [LA HABILIDAD]
// v6.38: EL PIN DEL KOLOSSOS — SetPosition/GetPosition/SetVelocityInstantaneous
// sobre el hueso RAIZ (la receta literal del killer Lua: headPhys:SetPos +
// SetVelocityInstantaneous(vector_origin) por tick). Indices contados del
// MISMO vphysics_interface.h l4d2: SetPosition win=46/lin=47, GetPosition
// win=48/lin=49 (vecinos ya verificados de SetVelocity 50: GetPositionMatrix
// 49... ojo, GetPosition=48 y GetPositionMatrix=49; SetVelocityInstantaneous
// win=51/lin=52 — confirmado por el vecino documentado del 50).
Handle g_hRagPhysSetPos;       // void  SetPosition(const Vector&, const QAngle&, bool isTeleport)
Handle g_hRagPhysGetPos;       // void  GetPosition(Vector*, QAngle*)
Handle g_hRagPhysSetVelInst;   // void  SetVelocityInstantaneous(const Vector*, const AngularImpulse*)
int    g_iRagPhysState = 0;    // 0=sin init, 1=listo, -1=mesa mala -> onda
int    g_iRagOffRoot = -1;     // datamap "m_pPhysicsObject" (hueso 0)
int    g_iRagOffCount = -1;    // datamap "m_ragdoll.listCount"
int    g_iRagOffBone[24];      // datamap "m_ragdoll.list[i].pObject" (1..23)
// v6.7 (informe 2): la victima REAL invisible deja de ser un MURO —
// su grupo de colisión pasa a DEBRIS mientras vuela el doble (receta
// Amy v64 "nada la frena fisicamente" + Sonic homing v6.5).
int   g_iSonicRagOldColGroup[MAXPLAYERS + 1];    // grupo ORIGINAL (-1 = no la tocamos)

// v6.12 (informe 6 — "siempre debería lanzarse hacia atras"): ventana
// de re-afirmación del REBOTE del golpe final. El rebote es un
// TeleportEntity de velocidad pura — si algo se comia la velocidad, Sonic
// se quedaba en el sitio sin salto hacia atras. Tras el FinalThrow queda
// abierta ~0.12s: mientras dure, si Sonic no lleva velocidad horizontal
// de huida (< 200 uu/s), el PreThink le re-imprime el vector guardado
// (misma filosofia de la re-afirmación v5.32).
float g_vSonicBounceDir[MAXPLAYERS + 1][3];       // vector del rebote final guardado
float g_fSonicBounceAssertUntil[MAXPLAYERS + 1];  // fin de la ventana (0 = inactiva)

// witch stun (ENTITY: FL_FROZEN + estrellas, receta Witch_Flight/OM_Stun)
#define SONIC_WITCH_STUN_SLOTS 4
int   g_iSonicWitchRef[SONIC_WITCH_STUN_SLOTS];
float g_fSonicWitchStunUntil[SONIC_WITCH_STUN_SLOTS];
float g_fSonicWitchStunStart[SONIC_WITCH_STUN_SLOTS];
bool  g_bSonicWitchHadFrozen[SONIC_WITCH_STUN_SLOTS];
int   g_iSonicWitchStars[SONIC_WITCH_STUN_SLOTS][3];
// v6.5 (B): ragdoll falso de la witch del ritual final
// v6.11: mismo vuelo FÍSICO (onda) que la victima
int   g_iSonicWitchRagRef[SONIC_WITCH_STUN_SLOTS];
int   g_iSonicWitchRagRender[SONIC_WITCH_STUN_SLOTS];
// v6.7 (informe 2): lo mismo para la witch real invisible
int   g_iSonicWitchRagOldColGroup[SONIC_WITCH_STUN_SLOTS];
// v6.5 (B): desliz manual de la witch (la witch congelada NO integra
// velocidad: FL_FROZEN apaga su locomoción — receta Witch_Flight) +
// su filtro de trace (no chocar contra infectados ni ella misma).
float g_fSonicWitchPushUntil[SONIC_WITCH_STUN_SLOTS];
float g_vSonicWitchPushDir[SONIC_WITCH_STUN_SLOTS][3];
Handle g_hSonicStunWatch = null;                 // ticker 0.1s (stuns + estrellas + TP final)

// timer de la FSM (10 Hz, como Tails)
Handle g_hSonicAvatarTimer = null;

// muerte OM: ventana anti-ragdoll del survivor (patron Tails v5.20)
float g_fSonicDeathHideUntil[MAXPLAYERS + 1];
float g_fSonicDeathOrigin[MAXPLAYERS + 1][3];

#define Sonic_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1))

// =====================================================================
// CICLO DE VIDA
// =====================================================================

public void Sonic_OnPluginStart()
{
    g_cvSonicAvatar        = CreateConVar("sonicom_avatar", "1", "Sonic OM: avatar espejo (sonic.mdl del VPK de recursos, patron Tails)", _, true, 0.0, true, 1.0);
    g_cvSonicBallSpin      = CreateConVar("sonicom_ballspin", "1", "Sonic OM: giro visual de la bola del spindash", _, true, 0.0, true, 1.0);
    // v6.16: los 2 ajustes de posición del dropballs de GMod que el port
    // no llevaba (la bola es una esfera CENTRADA en su origen y el survivor
    // tiene el origen a los PIES -> sin offset quedaba media hundida)
    g_cvSonicBallZ         = CreateConVar("sonicom_ball_z", "15", "Sonic OM v6.16: altura Z de la bola sobre los pies [GMod dropballs: GetPos()+Vector(0,0,15); 0 = media hundida como antes]. Aplica al nacer la bola", _, true, 0.0, true, 64.0);
    g_cvSonicBallScale     = CreateConVar("sonicom_ball_scale", "1.25", "Sonic OM v6.16: tamaño del modelo de la bola [GMod: SetModelScale(1.25); 1 = tamaño natural del mdl]. Aplica al nacer la bola", _, true, 0.25, true, 4.0);
    g_cvSonicSpinSpeed     = CreateConVar("sonicom_spin_speed", "600", "Sonic OM: velocidad de la bola [GMod: 1000 GMod-u re-calibrado]", _, true, 100.0, true, 1200.0);
    g_cvSonicSpinDuration  = CreateConVar("sonicom_spin_duration", "8", "Sonic OM: duración de la bola en segundos [GMod: 8]", _, true, 0.5, true, 30.0);
    g_cvSonicSpinDamage    = CreateConVar("sonicom_spin_damage", "121.5", "Sonic OM: dano de la bola por golpe [90 -> 121.5: +35% pedido del owner v6.32, aplica a TODAS las fases: toque de especiales, x2 comunes/witch, barrido frontal y picoada del dropdash]", _, true, 1.0, true, 500.0);
    g_cvSonicSpinCD        = CreateConVar("sonicom_spin_cd", "20", "Sonic OM: cooldown del spindash al terminar normal [GMod: 27]", _, true, 0.0, true, 120.0);
    g_cvSonicSpinCDFinal   = CreateConVar("sonicom_spin_cd_final", "27", "Sonic OM: cooldown tras el golpe FINAL (maxhits) [GMod: 35]", _, true, 0.0, true, 120.0);
    g_cvSonicSpinSlippery = CreateConVar("sonicom_spin_slippery", "1", "Sonic OM: bola deslizante (1 = permite corregir lateral, GMod slippery) / 0 = línea recta", _, true, 0.0, true, 1.0);
    g_cvSonicSpinMaxHits   = CreateConVar("sonicom_spin_maxhits", "3", "Sonic OM: golpes hasta el FINAL [GMod: 3]", _, true, 1.0, true, 20.0);
    g_cvSonicSpinRingGain  = CreateConVar("sonicom_spin_ringgain", "10", "Sonic OM: anillos por golpe de la bola [GMod: 10]", _, true, 0.0, true, 100.0);
    g_cvSonicPeelSpeed     = CreateConVar("sonicom_peel_speed", "800", "Sonic OM: velocidad del Peel Out [GMod: 1850 GMod-u -> 800 uu/s L4D2 = el 3.5x aprobado]", _, true, 220.0, true, 1200.0);
    g_cvSonicPeelCharge    = CreateConVar("sonicom_peel_charge", "3.0", "Sonic OM: segundos de carga del Peel Out [GMod: 3]", _, true, 0.1, true, 15.0);
    g_cvSonicPeelDuration  = CreateConVar("sonicom_peel_duration", "8", "Sonic OM: duración de la carrera del Peel Out [GMod: 8]", _, true, 0.5, true, 60.0);
    g_cvSonicPeelCDRescue  = CreateConVar("sonicom_peel_cd_rescue", "17", "Sonic OM v6.32: cooldown del Peel si rescato a alguien [25 -> 17: -8s pedido del owner]", _, true, 0.0, true, 120.0);
    g_cvSonicPeelCDFail    = CreateConVar("sonicom_peel_cd_fail", "37", "Sonic OM v6.32: cooldown del Peel si NO rescato [45 -> 37: -8s pedido del owner; también aplica si le cancelan la carga en pleno windup]", _, true, 0.0, true, 180.0);
    g_cvSonicPeelRescue    = CreateConVar("sonicom_peel_rescue", "1", "Sonic OM: tocar a un companion incapacitado durante el Peel lo levanta (GMod: agarra y revive)", _, true, 0.0, true, 1.0);
    // v6.14: LLEVAR JUGADORES ("el peel out según los lua de GMod puede
    // llevar supervivientes"): tocar a un companion SANO durante la
    // carrera lo MONTA detrás de Sonic — viaja a la velocidad del peel,
    // dispara montado y salta para bajarse. Incap sigue siendo RESCATE.
    g_cvSonicPeelCarry     = CreateConVar("sonicom_peel_carry", "1", "Sonic OM v6.14: el Peel Out LLEVA supervivientes — tocar a un companion sano durante la carrera lo monta detrás de Sonic hasta el final del viaje (salta para bajarse) [Lua GMod: el peel lleva jugadores]", _, true, 0.0, true, 1.0);
    g_cvSonicPeelCarryMax  = CreateConVar("sonicom_peel_carry_max", "3", "Sonic OM v6.14: asientos del Peel Out (pasajeros simultaneos detrás de Sonic)", _, true, 0.0, true, 3.0);
    g_cvSonicRings         = CreateConVar("sonicom_rings", "1", "Sonic OM: escudo de anillos (el dano directo gasta anillos antes que vida; GMod Dodgemeter)", _, true, 0.0, true, 1.0);
    g_cvSonicRingsMax      = CreateConVar("sonicom_rings_max", "50", "Sonic OM: anillos máximos [GMod Dodgemeter: 50]", _, true, 1.0, true, 999.0);

    // v6.4: stun estilo GMod (el sistema de Metal) para la bola
    g_cvSonicSpinStun       = CreateConVar("sonicom_spin_stun", "1.5", "Sonic OM: segundos de STUN (congela+estrellas) por golpe de la bola a los especiales [GMod Dropdash_basestun: 1.5]", _, true, 0.0, true, 12.0);
    g_cvSonicSpinStunFinal  = CreateConVar("sonicom_spin_stun_final", "4.5", "Sonic OM: STUN del golpe FINAL de la bola [owner v6.5: 4.5s]", _, true, 0.0, true, 12.0);
    g_cvSonicSpinStunStack  = CreateConVar("sonicom_spin_stun_stack", "1", "Sonic OM: re-aturdir a alguien ya aturdido SUMA tiempo (GMod stunstack)", _, true, 0.0, true, 1.0);
    g_cvSonicSpinLockTime   = CreateConVar("sonicom_spin_locktime", "1.0", "Sonic OM: segundos PEGADO a la cara del enemigo en el golpe final [GMod: 1]", _, true, 0.0, true, 3.0);
    g_cvSonicSpinRagdoll    = CreateConVar("sonicom_spin_ragdoll", "1", "Sonic OM: ragdoll falso del golpe final — sale volando y vive hasta que se pasa el stun (GMod CreateRagdolLCharacter_OM)", _, true, 0.0, true, 1.0);
    g_cvSonicRagBlast       = CreateConVar("sonicom_ragblast", "700", "Sonic OM v6.33: velocidad de lanzamiento del ragdoll falso en u/s (la receta GMod: SetVelocity dir*700 POR HUESO, directo al vphysics — independiente de la masa). Si el camino directo no esta disponible (sin left4dhooks o sondas falladas), el plan B motor puro (TeleportEntity al hueso raíz, ruta Rouge) usa el mismo número como u/s", _, true, 50.0, true, 5000.0);
    g_cvSonicSpinStunWitch  = CreateConVar("sonicom_spin_stun_witch", "1", "Sonic OM: la witch recibe el STUN del golpe final (estatua + estrellas)", _, true, 0.0, true, 1.0);

    // v6.5: números del owner + inmunidad de la bola
    g_cvSonicSpinDmgTank   = CreateConVar("sonicom_spin_damage_tank", "141.75", "Sonic OM: dano de la bola contra el TANK [105 -> 141.75: +35% pedido del owner v6.32]", _, true, 1.0, true, 500.0);
    g_cvSonicSpinGrabGuard = CreateConVar("sonicom_spin_grabguard", "1", "Sonic OM: en bola/picoada NINGÚN agarre entra (lengua/hunter/jockey/charger) ni el tank empuja", _, true, 0.0, true, 1.0);

    // v6.5: DODGE de controles (tabla del owner, pagado en anillos)
    g_cvSonicDodge         = CreateConVar("sonicom_dodge", "1", "Sonic OM: dodge de controles con anillos (tabla del owner) + 1.5s de gracia tras esquivar", _, true, 0.0, true, 1.0);
    g_cvSonicDodgeGrace    = CreateConVar("sonicom_dodge_grace", "1.5", "Sonic OM: segundos de GRACIA tras esquivar (inmune a controles y dano; NO cubre vómito ni spit del spitter) [owner: 1.5]", _, true, 0.0, true, 5.0);
    g_cvSonicDodgeTongue   = CreateConVar("sonicom_dodge_tongue", "15", "Sonic OM: anillos que cuesta esquivar la LENGUA del smoker [owner: 10-20]", _, true, 0.0, true, 999.0);
    g_cvSonicDodgeHunter   = CreateConVar("sonicom_dodge_hunter", "16", "Sonic OM: anillos que cuesta esquivar el POUNCE del hunter [owner: 12-20]", _, true, 0.0, true, 999.0);
    g_cvSonicDodgeJockey   = CreateConVar("sonicom_dodge_jockey", "16", "Sonic OM: anillos que cuesta esquivar el JOCKEY [owner: rango del hunter]", _, true, 0.0, true, 999.0);
    g_cvSonicDodgeCharger  = CreateConVar("sonicom_dodge_charger", "30", "Sonic OM: anillos que cuesta esquivar al CHARGER (carry/slam/fling) [owner: 30]", _, true, 0.0, true, 999.0);
    g_cvSonicDodgeVomit    = CreateConVar("sonicom_dodge_vomit", "6", "Sonic OM: anillos que cuesta esquivar el VÓMITO del boomer [owner: 5-8]", _, true, 0.0, true, 999.0);
    g_cvSonicDodgeBoom     = CreateConVar("sonicom_dodge_boom", "15", "Sonic OM: anillos que cuesta esquivar la EXPLOSION del boomer [owner: 15]", _, true, 0.0, true, 999.0);
    g_cvSonicDodgeWitch    = CreateConVar("sonicom_dodge_witch", "22", "Sonic OM: anillos que cuesta esquivar a la WITCH — fijo si su golpe es >25 [owner: 20-25]; si es <=24 gasta exacto el dano", _, true, 0.0, true, 999.0);

    // v6.6 (informe 1 del owner)
    g_cvSonicSpinRadiusCommons = CreateConVar("sonicom_spin_radius_commons", "140", "Sonic OM: radio del barrido AoE de la bola contra COMUNES (0 = off). Especiales y witch siguen con el alcance del toque — el rango extra es SOLO para comunes [owner: 'sufrimos mucho con los comunes']", _, true, 0.0, true, 400.0);
    g_cvSonicTrails = CreateConVar("sonicom_trails", "1", "Sonic OM: trails visuales (env_spritetrail) de la bola y la carrera del Peel Out — el look de los SpriteTrail del GMod", _, true, 0.0, true, 1.0);
    // v6.28: sonicom_trails_mat ELIMINADA por orden del owner ("ya quita
    // la opción... siempre usara los materiales originales"): los trails
    // usan AUTÉNTICOS siempre que los archivos existan (gate FileExists
    // interno, sin palanca); el nativo queda solo como fallback. La
    // nueva palanca es de la NUBE (abajo).
    g_cvSonicPeelNube = CreateConVar("sonicom_peel_nube", "1", "Sonic OM v6.29: NUBE de la carrera del Peel Out — 1 (DEFAULT, orden del owner 2026-10-09: el humo de la batería nunca se dejo ver en su server) = LA CUBRE EL BEAM NATIVO DEL SPEED: BeamFollow laserbeam 0.6s 10->1 fade 3 azul (la receta exacta del trail de colores del Speed_sonic) naciendo del TORSO (info_target +20z, el attachment Trail del QC); 0 = batería de sprites aditivos (5 humos om_bluesmoke 45-62u azul profundo con sesgo atras + 4 glows cian-blanco + moon). Cambiable EN VIVO (el próximo latido de 0.1s lo aplica, sin reiniciar el peel). OJO: si tu Sonic_Suite.cfg ya tiene sonicom_peel_nube 0 grabado de la 3.77.21, el default nuevo NO lo pisa — ponlo en 1 a mano o borra la línea", _, true, 0.0, true, 1.0);
    g_cvSonicDodgeGraceDot = CreateConVar("sonicom_dodge_grace_dot", "0.3", "Sonic OM: segundos de gracia CORTA tras esquivar durante los que el vómito del boomer no vuelve a cobrar y el spit del spitter no entra [owner: la eva se consumia demasiado rápido]", _, true, 0.0, true, 2.0);

    // comandos directos (además de Z/X/C del manager)
    RegConsoleCmd("sm_sonicspindash", Command_SonicSpinBind, "Sonic OM: Spindash/DropDash (tecla Z)");
    RegConsoleCmd("sm_sonicpeelout",  Command_SonicPeelBind, "Sonic OM: Peel Out (tecla X)");
    RegConsoleCmd("sm_sonichoming",   Command_SonicHomingBind, "Sonic OM: Homing Attack encadenable (tecla C)");
    RegConsoleCmd("sm_sonicwind",     Sonic_ActivateSonicWind_Passthrough, "Sonic v5.4: Sonic Wind (sin tecla; el X lo ocupa el Peel Out)");
    RegConsoleCmd("sm_soniccd",       Command_SonicCd, "Sonic OM: valores VIVOS (spindash/peel/anillos) vs default de fábrica");

    if (g_hSonicAvatarTimer != INVALID_HANDLE) KillTimer(g_hSonicAvatarTimer);
    g_hSonicAvatarTimer = CreateTimer(0.1, T_SonicAvatarThink, _, TIMER_REPEAT);

    // v6.2: muerte en hook PROPIO player_death POST (paridad Tails.inc
    // L944: HookEvent("player_death", Tails_Event_PlayerDeath)). El
    // manager dejó de llamarnos desde su hook PRE — el PRE corria antes
    // de que el motor procesara la muerte y el restore del cuerpo
    // dejaba ver el corpse del survivor (ver comentario en
    // Sonic_Event_PlayerDeath).
    HookEvent("player_death", Sonic_Event_PlayerDeath, EventHookMode_Post);
}

public void Sonic_OnMapStart()
{
    PrecacheSound("mobius/sfx/spring.mp3", true);
    PrecacheSound("mobius/sfx/instinct.mp3", true);
    PrecacheSound("mobius/sfx/boom.mp3", true);
    PrecacheSound("mobius/sfx/revive.mp3", true);

    g_iSonicBeamSprite = PrecacheModel(SONIC_SPRITE_BEAM, true);
    g_iSonicGlowSprite = PrecacheModel(SONIC_SPRITE_GLOW, true);

    // v6.0 OM: modelo del avatar + bola + sonidos del pack OM
    g_bSonicModelOK = view_as<bool>(PrecacheModel(SONIC_OM_MODEL, true));
    g_bSonicBallOK  = view_as<bool>(PrecacheModel(SONIC_OM_BALL, true));

    // v6.17/v6.18: materiales AUTÉNTICOS de los trails del sonicball
    // (patron star_stun del OM_Stun: FileExists vía filesystem de Valve
    // = ve los VPK montados; sin ellos TODO cae al laserbeam nativo —
    // el plugin NUNCA depende de que esten). v6.18: se guarda el INDEX
    // precacheado de cada uno (los TE BeamFollow piden modelo, no ruta)
    g_bSonicBallMatWide = FileExists(SONIC_BALL_MAT_WIDE, true);
    g_bSonicBallMatFade = FileExists(SONIC_BALL_MAT_FADE, true);
    g_bSonicPeelMatMain = FileExists(SONIC_PEEL_MAT_MAIN, true);
    g_bSonicPeelMatFoot = FileExists(SONIC_PEEL_MAT_FOOT, true);
    if (g_bSonicBallMatWide) { g_iSonicTEMatWide = PrecacheModel(SONIC_BALL_MAT_WIDE, true); Sonic_AddMatToDownloads(SONIC_BALL_MAT_WIDE); }
    if (g_bSonicBallMatFade) { g_iSonicTEMatFade = PrecacheModel(SONIC_BALL_MAT_FADE, true); Sonic_AddMatToDownloads(SONIC_BALL_MAT_FADE); }
    if (g_bSonicPeelMatMain) { g_iSonicTEMatPeel = PrecacheModel(SONIC_PEEL_MAT_MAIN, true); Sonic_AddMatToDownloads(SONIC_PEEL_MAT_MAIN); }
    if (g_bSonicPeelMatFoot) { g_iSonicTEMatFoot = PrecacheModel(SONIC_PEEL_MAT_FOOT, true); Sonic_AddMatToDownloads(SONIC_PEEL_MAT_FOOT); }

    // v6.20: material del FLASH DEL GOLPE del spindash (port del
    // sonic_spindashhit del GMod: icons/sonic_drop_impact — el PNG del
    // pack convertido a VTF+VMT para L4D2). Sin el: glow01 nativo
    // (cero dependencia, como siempre)
    // v6.22: materiales de la NUBE del peel (patron de los demas gates)
    g_bSonicFxMatSmoke = FileExists(SONIC_FX_MAT_SMOKE, true);
    if (g_bSonicFxMatSmoke) { g_iSonicFxMatSmoke = PrecacheModel(SONIC_FX_MAT_SMOKE, true); Sonic_AddMatToDownloads(SONIC_FX_MAT_SMOKE); }
    g_bSonicFxMatMoon = FileExists(SONIC_FX_MAT_MOON, true);
    if (g_bSonicFxMatMoon) { g_iSonicFxMatMoon = PrecacheModel(SONIC_FX_MAT_MOON, true); Sonic_AddMatToDownloads(SONIC_FX_MAT_MOON); }
    g_bSonicFxMatTinyBall = FileExists(SONIC_FX_MAT_TINYBALL, true);
    if (g_bSonicFxMatTinyBall) { g_iSonicFxMatTinyBall = PrecacheModel(SONIC_FX_MAT_TINYBALL, true); Sonic_AddMatToDownloads(SONIC_FX_MAT_TINYBALL); }
    g_bSonicHitFxMat = FileExists(SONIC_HITFX_MAT, true);
    if (g_bSonicHitFxMat)
    {
        g_iSonicHitFxMat = PrecacheModel(SONIC_HITFX_MAT, true);
        Sonic_AddMatToDownloads(SONIC_HITFX_MAT);
    }

    // v6.18: index del fallback nativo + slots del motor TE del mapa
    // anterior fuera (sus TEs murieron con el mapa; los slot ids por
    // jugador se ponen a cero en el loop de abajo). OJO: SONIC_TRAIL_SPRITE
    // (abajo, en la sección del motor) aún no existe a esta altura del
    // archivo — los #define son textuales; se usa SONIC_SPRITE_BEAM,
    // que es el MISMO laserbeam.vmt nativo (definido arriba, L378)
    g_iSonicTELaser = PrecacheModel(SONIC_SPRITE_BEAM, true);
    Sonic_TETeardown();

    PrecacheSound(SONIC_SND_SPIN_CHARGE, true);
    PrecacheSound(SONIC_SND_SPIN_LOOP, true);
    PrecacheSound(SONIC_SND_HIT, true);
    PrecacheSound(SONIC_SND_FINAL, true);
    PrecacheSound(SONIC_SND_DRILL, true);
    PrecacheSound(SONIC_SND_RELEASE, true);
    PrecacheSound(SONIC_SND_PEEL_START, true);
    PrecacheSound(SONIC_SND_PEEL_PICKUP, true);
    PrecacheSound(SONIC_SND_OUTTAHERE, true);
    PrecacheSound(SONIC_SND_BRAKE, true);
    PrecacheSound(SONIC_SND_STUN, true);

    for (int i = 1; i <= MaxClients; i++)
    {
        g_iSonicRevives[i] = 0;
        // OM: refs de entidades del mapa anterior mueren con el mapa
        g_iSonicAvatar[i]   = 0;
        g_iSonicAvatarL[i]  = 0;
        g_iSonicBall[i]     = 0;
        // v6.18: slots TE de trails a cero (el teardown apago el motor)
        g_iSonicBallTrailR[i] = 0;
        g_iSonicBallTrailW[i] = 0;
        g_iSonicBallTrailM[i] = 0;
        g_iSonicPeelTrail[i]  = 0;
        g_iSonicPeelTrailO[i] = 0;
        g_iSonicPeelTrail2[i] = 0;
        g_iSonicPeelTrail3[i] = 0;
        g_iSonicPeelTrailO2[i] = 0;
        g_iSonicPeelTrailO3[i] = 0;
        g_iSonicPeelFootL[i]  = 0;
        g_iSonicPeelFootR[i]  = 0;
        g_iSonicPeelNubeBeam[i]  = 0;
        g_iSonicPeelNubeBeamO[i] = 0;
        g_iSonicBodyRender[i] = -1;
        g_iSonicAnimState[i]  = -1;
        g_bSonicSmSnap[i]     = true;
        Sonic_OM_ResetSlot(i);
    }
}

public void Sonic_OnRoundStart()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iSonicRevives[i] = 0;
        g_fSonicActionCD[i] = 0.0;
        g_fSonicWindCD[i] = 0.0;
        g_fSonicAirDashNext[i] = 0.0;
        g_iSonicChainCount[i] = 0;
        g_fSonicChainWindowEnd[i] = 0.0;
        // OM: ronda nueva = anillos llenos (GMod: initialize Dodgemeter)
        g_iSonicRings[i] = g_cvSonicRingsMax.IntValue;
        Sonic_OM_ResetSlot(i);
    }
}

// Reset TOTAL del slot OM (spin/peel/anillo-dodge + velocidad del stack)
void Sonic_OM_ResetSlot(int client)
{
    g_iSonicSpinPhase[client] = SONIC_SPIN_NONE;
    g_fSonicSpinUntil[client] = 0.0;
    g_fSonicSpinWindEnd[client] = 0.0;
    g_fSonicSpinNextHit[client] = 0.0;
    g_fSonicSpinLastHit[client] = 0.0;
    g_iSonicSpinHits[client] = 0;
    g_fSonicSpinCD[client] = 0.0;
    g_fSonicSpinCDDur[client] = 0.0;
    g_bSonicSpinFinalized[client] = false;

    g_iSonicPeelPhase[client] = 0;
    g_fSonicPeelChargeEnd[client] = 0.0;
    g_fSonicPeelRunEnd[client] = 0.0;
    g_fSonicPeelBrakeEnd[client] = 0.0;
    g_fSonicPeelCD[client] = 0.0;
    g_fSonicPeelCDDur[client] = 0.0;
    g_bSonicPeelSaidOut[client] = false;
    g_iSonicPeelRescues[client] = 0;
    g_fSonicPeelLoopSnd[client] = 0.0;
    g_fSonicSpinLoopSnd[client] = 0.0;

    // v6.14: pasajeros fuera — limpieza de estado SIN teleport (en
    // spawn/round/putInServer cada quien reaparece solo; si era
    // pasajero de otro Sonic, libera su bandera)
    Sonic_PeelCarryClearState(client);

    g_fSonicDodgeEnd[client] = 0.0;
    g_iSonicDodgeSeq[client] = -1;     // v6.29: eva a completar
    g_fSonicDodgeCap[client] = 0.0;

    // v6.5: dodge/gracia/homing + ragdoll del final
    g_fSonicDodgeGraceUntil[client] = 0.0;
    g_fSonicHomingNext[client] = 0.0;
    // v6.12: ventana de re-afirmación del rebote final fuera
    g_fSonicBounceAssertUntil[client] = 0.0;
    // v6.11: sin estado de vuelo que resetear (la onda + el vphysics
    // llevan al doble; el serial de targetnames no necesita reset)
    if (g_iSonicSpinRagRef[client] == 0)
        g_iSonicRagOldColGroup[client] = -1;   // con ragdoll vivo lo libera el Kill

    // v6.6 (informe 1): gracia DoT + anti doble cobro + barrido + trails
    g_fSonicDotGraceUntil[client] = 0.0;
    g_fSonicDodgePaidAt[client] = 0.0;
    g_fSonicSpinNextSweep[client] = 0.0;
    Sonic_KillBallTrails(client);
    Sonic_KillPeelTrail(client);

    // soltar la fuente de velocidad del stack (slot 1 = Sonic OM)
    Speed_StackSet(client, 1, 0.0);
}

// v6.2: reset de velocidad de caida a prueba de excepciones. La forma
// cruda heredada del v5.4 (SetEntPropFloat Prop_Send "m_Local.
// m_flFallVelocity") EXCEPCIONA en L4D2: "Property not found"
// (reporte del owner en el dropdash). En el v5.4 nunca crashió
// porque el homing que la usaba era CÓDIGO MUERTO (el Z pristino
// despachaba a HabilidadSonicSuperJump) — al revivirlo en v6.0 la
// propiedad fantasma salto a la luz. Técnica conservada CON GUARD:
// Prop_Send si existe (otros engines), si no Prop_Data, si no se
// salta en silencio — y es redundancia de sobra: Sonic_OnTakeDamage_
// Fall ya bloquea TODO el DMG_FALL del Sonic (damage = 0 + Handled).
void Sonic_ResetFallVelocity(int client)
{
    if (HasEntProp(client, Prop_Send, "m_Local.m_flFallVelocity"))
    {
        SetEntPropFloat(client, Prop_Send, "m_Local.m_flFallVelocity", 0.0);
        return;
    }
    if (HasEntProp(client, Prop_Data, "m_Local.m_flFallVelocity"))
        SetEntPropFloat(client, Prop_Data, "m_Local.m_flFallVelocity", 0.0);
}

// v6.2: MUERTE REAL — ahora en hook PROPIO player_death POST (paridad
// EXACTA con Tails_Event_PlayerDeath, Tails.inc). Antes la llamaba el
// manager desde su hook PRE y el orden rompia la muerte: el PRE corre
// ANTES de que el juego procese la muerte, así que Sonic_KillAvatar
// restauraba el render del cuerpo (lo volvia VISIBLE) un instante
// ANTES de que el motor generara el survivor_death_model / el corpse
// del mod de ragdolls — y esos nacian visibles (cuerpo + ragdoll
// doble en pantalla, reporte del owner). Tails nunca sufrió esto
// porque SU muerte corre en POST: la ventana + el ragdoll OM + el
// restore corren DESPUÉS de que el motor creo el cuerpo de muerte con
// el jugador aún RENDER_NONE. Mismo orden aquí = mismo resultado
// limpio (solo el ragdoll OM de sonic.mdl).
public void Sonic_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;

    Sonic_CancelHoming(client);
    g_iSonicChainCount[client] = 0;
    g_fSonicChainWindowEnd[client] = 0.0;
    // OM: cortar spin/peel + solter el stack + quitar avatar/bola
    Sonic_OM_Cancel(client);

    // OM: el avatar muere con el — ragdoll del modelo OM en la posición
    // de muerte (GMod: CreateRagdolLCharacter_OM; patron Tails v5.20:
    // ventana anti-ragdoll para el cuerpo del survivor que el mod de
    // ragdolls del owner revive al morir)
    GetClientAbsOrigin(client, g_fSonicDeathOrigin[client]);
    g_fSonicDeathHideUntil[client] = GetEngineTime() + 2.0;
    Sonic_SpawnDeathRagdoll(client);
    Sonic_KillAvatar(client);
}

// v6.1: LIMPIEZA pura para CAMBIO DE PERSONAJE / DISCONNECT (la invoca
// CleanupCharModuleState del manager, cuando el índice aún es SONIC).
// IGUAL que Tails_OnPlayerDeath: corta habilidades, suelta el stack,
// mata avatar/bola y restaura el cuerpo — PERO SIN ragdoll y SIN
// ventana anti-ragdoll (el jugador no murió: no hay nada que esconder).
// (Nombre: Sonic_CleanupState porque Sonic_OnPlayerDeath YA existía en
// el v5.4 como filtro de dano del revive "nervios de acero" — 5 params,
// no se puede sobrecargar en SourcePawn.)
public void Sonic_CleanupState(int client)
{
    if (!Sonic_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;
    Sonic_CancelHoming(client);
    g_iSonicChainCount[client] = 0;
    g_fSonicChainWindowEnd[client] = 0.0;
    Sonic_OM_Cancel(client);
    // v6.4: si este jugador era una victima con ragdoll falso en vuelo,
    // liberarle el cuerpo antes de limpiar el resto
    Sonic_KillSpinRagdoll(client, true);
    Sonic_KillAvatar(client);
}

// Ragdoll OM: prop_ragdoll con sonic.mdl (usa el .phy del modelo) +
// limpieza a los 15s (receta Tails exacta)
void Sonic_SpawnDeathRagdoll(int client)
{
    if (!g_bSonicModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", SONIC_OM_MODEL);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    CreateTimer(15.0, T_SonicRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_SonicRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Filtro anti-ragdoll (patron Tails: el mod de ragdolls del owner
// revive el cuerpo del survivor; para un Sonic ese cuerpo NO debe
// verse — su ragdoll es el de sonic.mdl). Lo invoca el OnEntityCreated
// central de Rouge.inc (Rogue se incluye DESPUÉS de sonic).
void Sonic_OnEntityCreated(int entity, const char[] classname)
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
            if (g_fSonicDeathHideUntil[i] == 0.0 || now >= g_fSonicDeathHideUntil[i])
                continue;
            // candidata: revisar modelo/origen en el próximo frame
            RequestFrame(Sonic_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }
}

public void Sonic_CheckDeathRagdoll(any ref)
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
        if (g_fSonicDeathHideUntil[i] == 0.0 || now >= g_fSonicDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_fSonicDeathOrigin[i]) < 200.0)
        {
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}

// v5.1: reset defensivo al spawn (estado residual de la vida anterior)
public void Sonic_Event_PlayerSpawn(Event event, const char[] name, int client)
{
    if (client <= 0 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;

    Sonic_CancelHoming(client);
    g_iSonicJumps[client] = 0;
    g_iSonicLastButtons[client] = 0;
    g_iSonicChainCount[client] = 0;
    g_fSonicChainWindowEnd[client] = 0.0;

    // OM: reset del slot (por si la vida anterior murió en bola/carrera)
    Sonic_OM_ResetSlot(client);
    Sonic_KillAvatar(client);
    g_iSonicAnimState[client] = -1;
    g_fSonicAnimLock[client]  = 0.0;

    // OM: montar el avatar (patron Tails: el think de 10 Hz lo
    // re-monta solo si algo sale raro con el orden de eventos)
    if (g_cvSonicAvatar.BoolValue && g_bSonicModelOK
        && GetClientTeam(client) == 2 && IsPlayerAlive(client))
    {
        Sonic_CreateAvatar(client);
    }
}

public void Sonic_OnClientPutInServer(int client)
{
    g_iSonicRevives[client] = 0;
    g_iSonicJumps[client] = 0;

    Sonic_CancelHoming(client);
    Sonic_OM_ResetSlot(client);
    Sonic_KillAvatar(client);

    g_fSonicDashTime[client] = 0.0;
    g_fSonicActionCD[client] = 0.0;
    g_fSonicWindCD[client] = 0.0;
    g_iSonicLastButtons[client] = 0;
    g_fSonicAirDashNext[client] = 0.0;
    g_iSonicChainCount[client] = 0;
    g_fSonicChainWindowEnd[client] = 0.0;
    // OM: slot limpio para el ocupante nuevo (nunca hereda)
    g_iSonicAvatar[client] = 0;
    g_iSonicAvatarL[client] = 0;
    g_iSonicBall[client] = 0;
    g_iSonicBodyRender[client] = -1;
    g_iSonicAnimState[client] = -1;
    g_bSonicSmSnap[client] = true;
    g_iSonicRings[client] = g_cvSonicRingsMax.IntValue;

    SDKUnhook(client, SDKHook_OnTakeDamage, Sonic_OnTakeDamage_Combat);
    SDKUnhook(client, SDKHook_OnTakeDamage, Sonic_OnTakeDamage_Fall);
    SDKUnhook(client, SDKHook_PreThink, Sonic_PreThink);
    SDKUnhook(client, SDKHook_Touch, Sonic_OnTouch);
    SDKUnhook(client, SDKHook_PostThink, Sonic_AvatarFollow);

    SDKHook(client, SDKHook_OnTakeDamage, Sonic_OnTakeDamage_Combat);
    SDKHook(client, SDKHook_OnTakeDamage, Sonic_OnTakeDamage_Fall);
    SDKHook(client, SDKHook_PreThink, Sonic_PreThink);
    SDKHook(client, SDKHook_Touch, Sonic_OnTouch);
}

// =====================================================================
// AVATAR OM (patron Tails v5.24: R + L + EF_NOINTERP + pulso de pausa)
// =====================================================================

void Sonic_SetAvatarNoInterp(int av, bool on)
{
    if (av <= 0 || !IsValidEntity(av)) return;
    if (!HasEntProp(av, Prop_Send, "m_fEffects")) return;
    int fx = GetEntProp(av, Prop_Send, "m_fEffects");
    if (on)
    {
        if ((fx & SONIC_EF_NOINTERP) == 0)
            SetEntProp(av, Prop_Send, "m_fEffects", fx | SONIC_EF_NOINTERP);
    }
    else if ((fx & SONIC_EF_NOINTERP) != 0)
        SetEntProp(av, Prop_Send, "m_fEffects", fx & ~SONIC_EF_NOINTERP);
}

// Crea el prop base (avatar R o L o bola): parentado al survivor,
// sin sombras, EF_NOINTERP al nacer (v5.20.5: nace ENCAJADO).
// v6.15: tpMode = la copia R en modo TP (tails_avatar_tp): nace SIN
// parent y SIN EF_NOINTERP — ya queda en pose MUNDO por el
// TeleportEntity de arriba; el follow la mueve por tick y los
// clientes de los DEMAS la interpolan (L y BOLA siempre parentados).
// v6.16: zOffs = offset Z LOCAL horneado ANTES del SetParent (misma
// receta world-pos-primero de los trails): el prop viaja pegado al
// survivor a esa altura. La BOLA lo usa (+15 GMod; es una esfera
// CENTRADA en su origen y el survivor tiene el origen a los PIES:
// sin offset queda media hundida en el suelo). R/L humanos pasan 0.0.
int Sonic_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false, float zOffs = 0.0)
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
    g_fSonicBodyYaw[client]  = ang[1];
    g_fSonicYawLastT[client] = GetEngineTime();
    pos[2] += zOffs;                       // v6.16: offset LOCAL del parent
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fSonicBodyYaw[client], loc);

    if (!tpMode)
    {
        // parentado (modo Tails default v5.6: el motor mueve la posición,
        // cero delay de red, anims suaves; aquí solo se escriben angulos)
        SetVariantString("!activator");
        AcceptEntityInput(av, "SetParent", client);
        if (HasEntProp(av, Prop_Send, "m_angRotation"))
            SetEntPropVector(av, Prop_Send, "m_angRotation", loc);
    }

    for (int k = 0; k < 3; k++)
    {
        g_fSonicSmLoc[client][k]  = loc[k];
        g_fSonicSmLocL[client][k] = loc[k];
    }
    g_bSonicSmSnap[client] = true;

    if (!tpMode)
        Sonic_SetAvatarNoInterp(av, true);
    return av;
}

// v6.2: pulsePause = disparar el pulso de pausa (Tails_PauseFix_
// Trigger, el ciclo pause/unpause sv_pausable que cura el tilt del
// avatar en la pantalla del dueño). SOLO para montajes de CICLO DE
// VIDA (spawn / selección / reparación tardia de la FSM — momentos
// raros, como Tails). El re-montaje tras la BOLA del spindash va con
// false: un pulso por cada spindash en pleno combate era el "broma
// de pausa" que reporto el owner; el swap bola->avatar ya nace
// encajado (EF_NOINTERP + snap de smoothing) y no lo necesita.
// =====================================================================
// v6.31-OM (manager 3.77.40): ADOPCION EN EL MONTAJE — el reemplazo del
// barrido en caliente (orden del owner 2026-10-10: "tu barrido de
// avatares está haciendo reiniciar mi avatar a cada rato... BUSCA OTRA
// MANERA"). Esta FSM es la ÚNICA creadora de props con los nombres de
// abajo: un prop así que ELLA no rastrea es un huerfano por definición
// (lo fabrico una vida anterior, un montaje doble del pasado o una
// versión vieja del suite) y muere en el instante exacto del montaje.
// Un avatar rastreado es INTOCABLE: no existe ningún timer que lo mire.
// =====================================================================
bool Sonic_IsMyAvatarRef(int ref)
{
    // v3.77.40: el 0 es "sin avatar"; un ref NEGATIVO puede ser
    // perfectamente legitimo (bit alto del serial del handle).
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iSonicAvatar[i] == ref) return true;
        if (g_iSonicAvatarL[i] == ref) return true;
        if (g_iSonicBall[i] == ref) return true;
    }
    return false;
}

void Sonic_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "sonic_avatar_om", "sonic_avatar_om_l", "sonic_ball_om", "sonicom_avatar" };
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
                if (Sonic_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
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
        PrintToServer("[Sonic v6.31-OM] Adopción del montaje: %d huerfano(s) del avatar eliminado(s).", ng);
}

void Sonic_CreateAvatar(int client, bool pulsePause = true)
{
    if (!g_bSonicModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    // en ROLL/WINDUP manda la fase de la bola: no montar el humano
    // (v6.3: en ROLL el avatar real sigue VIVO pero oculto — se ve
    // la bola; montar otro aquí pondría un Sonic parado junto a ella)
    if (g_iSonicSpinPhase[client] == SONIC_SPIN_ROLL
        || g_iSonicSpinPhase[client] == SONIC_SPIN_WINDUP) return;

    // v6.15: la copia R nace en modo TP si tails_avatar_tp (la que ven
    // los DEMAS viaja por teleport por tick + interpolación de red)
    // v6.31-OM (manager 3.77.40): REEMPLAZO LIMPIO — orden del owner
    // 2026-10-10: en caliente YA NO EXISTE barrido. Si este cliente ya
    // tenía un R o L vivo (montaje doble por orden raro de eventos),
    // muere AQUÍ enterito: jamás vuelve a quedar un prop sin dueño (la
    // fábrica de huerfanos del "= 0" sin Kill queda cerrada).
    {
        int oldR = EntRefToEntIndex(g_iSonicAvatar[client]);
        if (g_iSonicAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Sonic_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iSonicAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iSonicAvatarL[client]);
        if (g_iSonicAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Sonic_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iSonicAvatarL[client] = 0;
    }

    // v6.31-OM: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje, no en un
    // timer a ciegas.
    Sonic_KillGhostAvatarProps();

    int av = Sonic_CreateAvatarProp(client, SONIC_OM_MODEL, "sonic_avatar_om", Tails_AvatarTPOn());
    if (av == 0) return;

    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");
    g_iSonicAnimState[client] = 0;

    SDKHook(av, SDKHook_SetTransmit, Sonic_TransmitAvatarR);

    g_iSonicAvatarL[client] = 0;
    Sonic_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iSonicBodyRender[client] = view_as<int>(curMode);
    else if (g_iSonicBodyRender[client] == -1)
        g_iSonicBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    g_iSonicAvatar[client] = EntIndexToEntRef(av);

    // per-tick: angulos locales (contra-rotación del parent)
    SDKHook(client, SDKHook_PostThink, Sonic_AvatarFollow);

    // v5.20.6/v5.24 Tails: PULSO DE PAUSA en cada montaje de ciclo de
    // vida (la misma infra sv_pausable del suite; convar tails_pausefix
    // manda para ambos avatares — es UN solo sistema). El re-montaje
    // post-bola NO pulsa (ver firma: pulsePause).
    if (pulsePause)
        Tails_PauseFix_Trigger(client);
}

void Sonic_CreateAvatarL(int client)
{
    if (!g_bSonicModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iSonicAvatar[client] == 0) return;

    int av = Sonic_CreateAvatarProp(client, SONIC_OM_MODEL, "sonic_avatar_om_l");
    if (av == 0) return;

    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Sonic_TransmitAvatarL);

    g_iSonicAvatarL[client] = EntIndexToEntRef(av);
}

// v6.16 - BOLA A ALTURA GMOD (fix visual del owner: "el modelo de la
// bola aparece media undida en el suelo"). Causa raíz: sonicball.mdl es
// una esfera de radio ~13u CENTRADA en el origen del modelo (la hitbox
// del propio mdl: -16..16 en X, ~+-12 en Y/Z alrededor del 0) y el
// origen del survivor en Source esta a los PIES (hull 0..72 sobre el
// origen) — la v6.0 la parento con offset local (0,0,0) = el centro de
// la esfera caía EXACTAMENTE a nivel del suelo = media hundida. El
// dropballs original de GMod NUNCA la puso en el origen:
// ent_om_hedgehog_dropballs.lua hacia cada tick
// ply:GetPos()+Vector(0,0,15) y el spawner además SetModelScale(1.25)
// — los 2 ajustes que este port no llevaba. Ahora: sonicom_ball_z
// (default 15 GMod) horneado como offset LOCAL del parent al nacer la
// bola + sonicom_ball_scale (default 1.25 GMod) vía m_flModelScale.
// Ambos aplican AL NACER la bola (siguiente spin tras cambiarlos).
// Los avatares humanos R/L NO se tocan (sus modelos tienen el origen
// en los pies = ya cuadraban) y los trails de la bola mantienen su
// offset relativo (30u sobre el ORIGEN de la bola, como siempre).
//
// La BOLA del spindash: mismo parent/NoInterp, spin visual por tick.
// v6.3 (diseño del dueño): el avatar humano NO se destruye — se
// OCULTA (RENDER_NONE en R+L, entidades VIVAS) durante TODA la bola;
// EndRoll/OM_Cancel le devuelven la visibilidad. El retorno deja de
// pasar por el montaje completo: cero re-creación de props, cero
// pulsos de pausa, y el avatar ya está en posición y con la anim
// correcta al reaparecer (la FSM de anim le siguio corriendo mientras
// estuvo oculto).
void Sonic_CreateBall(int client)
{
    if (!g_bSonicBallOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;

    Sonic_KillBall(client);

    // v6.3: OCULTAR el humano (no matarlo) mientras rueda la bola
    Sonic_HideAvatarForBall(client);

    // v6.16: zOffs = sonicom_ball_z (GMod +15) horneado como offset
    // LOCAL del parent ANTES del SetParent (receta world-pos-primero)
    // v6.29: en modo TP la bola nace SIN parent (viaja por teleport con
    // angulos de MUNDO — su yaw sigue al rumbo real por construcción;
    // el parentado quedaba con la orientación congelada al girar)
    int av = Sonic_CreateAvatarProp(client, SONIC_OM_BALL, "sonic_ball_om", Tails_AvatarTPOn(), g_cvSonicBallZ.FloatValue);
    if (av == 0)
    {
        // la bola no nació (prop fallo): no dejar a Sonic oculto
        Sonic_ShowAvatarAfterBall(client);
        return;
    }

    g_fSonicBallSpin[client] = 0.0;
    g_iSonicBall[client] = EntIndexToEntRef(av);

    // v6.16: escala del GMod (SetModelScale(1.25)) vía netprop —
    // prop_dynamic_override la soporta, es puramente visual (solid 0)
    // y se sincroniza solo con los clientes
    if (g_cvSonicBallScale != null && HasEntProp(av, Prop_Send, "m_flModelScale"))
        SetEntPropFloat(av, Prop_Send, "m_flModelScale", g_cvSonicBallScale.FloatValue);

    // v6.6 (4): los trails azules de la bola (las dos capas del GMod)
    Sonic_CreateBallTrails(client);

    SDKHook(client, SDKHook_PostThink, Sonic_AvatarFollow);
}

// =====================================================================
// v6.18: MOTOR DE TRAILS TE (BeamFollow / BeamPoints temp-ents).
// NECROLOGIA del env_spritetrail: el v6.6 lo introdujo traduciendo el
// útil.SpriteTrail del GMod, el v6.17 le puso los materiales
// AUTÉNTICOS del sonicball... y el owner descubrio que NUNCA se vio
// ("ni el nativo ni ese parecen ser visibles"): L4D2 no dibuja la
// estela del env_spritetrail (entidad de la familia HL2/TF2) con
// CUALQUIER material — ni laserbeam nativo ni blue.vmt auténtico.
// No era el parent (los trails de la bola SI iban parentados a la
// BOLA, no al cuerpo invisible): era el TIPO de entidad.
// SOLUCION: el mecanismo que este MISMO server ya demuestra a diario
// — los TE del motor: el rastro de colores del speed (Speed_sonic:
// TE_SetupBeamFollow sobre el avatar) y el laser de Tails
// (TE_SetupBeamPoints/RingPoint). El motor dibuja la estela del lado
// del cliente y el TE no es una entidad de red: imposible que "no
// renderice".
// v6.18 mantiene TODO el diseño v6.17 (las 3 capas EXACTAS del
// fadeeiie del sonic.lua L1921-1964 para la bola; peel con blue2 +
// las 2 Sonicred de los pies; FileExists -> laserbeam nativo si
// falta) y SOLO cambia el motor de dibujo.
// =====================================================================
#define SONIC_TRAIL_SPRITE "materials/sprites/laserbeam.vmt"

// v6.19: agrega el .vmt + su .vtf REAL a la tabla de descargas (patron
// OM_Stun; inofensivo si el material vive dentro de un VPK). FIX del v6.17:
// encolaba el .vtf del MISMO nombre (blue.vtf) — pero NINGÚN .vmt del
// sonicball tiene su textura al lado (análisis del pack original del OM
// 2026-10-08): blue.vmt -> bluetrail.vtf, blue_2ndlayer.vmt ->
// bluestartrail2.vtf, blue2.vmt -> shared/shared_t.vtf, Sonicred.vmt ->
// shared/shared_t2.vtf. Sin la dependencia en la tabla, el cliente que no
// la tenga instalada a mano veía el DAMERO de textura faltante. Se parsea
// el $basetexture del propio .vmt; si no se puede leer (p.ej. dentro de un
// VPK sin abrir) se cae al .vtf homonimo del v6.17 — y solo se encola lo
// que EXISTE en el servidor (nada de archivos fantasma en la descarga).
bool Sonic_GetMatBasetexture(const char[] vmt, char[] texOut, int maxLen)
{
    texOut[0] = 0;
    File f = OpenFile(vmt, "r");
    if (f == null) return false;
    char line[512];
    bool found = false;
    while (!found && f.ReadLine(line, sizeof(line)))
    {
        int pos = StrContains(line, "$basetexture");
        if (pos == -1) continue;
        pos += 12;
        if (pos < sizeof(line) && ((line[pos] >= 'a' && line[pos] <= 'z') || (line[pos] >= 'A' && line[pos] <= 'Z') || (line[pos] >= '0' && line[pos] <= '9')))
            continue;  // $basetexture2 / $basetexturetransform: no es el
        // rest empieza justo después del keyword: 1a comilla = cierre del
        // propio "$basetexture", 2a = apertura del valor, 3a = cierre
        char rest[512];
        strcopy(rest, sizeof(rest), line[pos]);
        int c1 = FindCharInString(rest, '"');
        if (c1 == -1) continue;
        int c2 = FindCharInString(rest[c1+1], '"');
        if (c2 == -1) continue;
        int start = c1 + 1 + c2 + 1;
        int c3 = FindCharInString(rest[start], '"');
        if (c3 == -1) continue;
        rest[start + c3] = 0;
        strcopy(texOut, maxLen, rest[start]);
        found = (strlen(texOut) > 0);
    }
    delete f;
    return found;
}

void Sonic_AddMatToDownloads(const char[] vmt)
{
    AddFileToDownloadsTable(vmt);

    // 1) dependencia REAL: el $basetexture declarado dentro del .vmt
    char tex[PLATFORM_MAX_PATH];
    char vtf[PLATFORM_MAX_PATH];
    if (Sonic_GetMatBasetexture(vmt, tex, sizeof(tex)))
    {
        Format(vtf, sizeof(vtf), "materials/%s.vtf", tex);
        if (FileExists(vtf, true)) AddFileToDownloadsTable(vtf);
    }

    // 2) fallback v6.17: .vtf homonimo — solo si existe (el blue.vtf del
    //    sonicball NO existe: no encolar archivos fantasma)
    strcopy(vtf, sizeof(vtf), vmt);
    ReplaceString(vtf, sizeof(vtf), ".vmt", ".vtf");
    if (FileExists(vtf, true)) AddFileToDownloadsTable(vtf);
}

// ---------------------------------------------------------------------
// v6.20: EL FIX DEL env_spritetrail (smd_spritetrail_fix de fbef0102,
// plugin original de FrozDark — lo trajo el owner 2026-10-08). La
// NECROLOGIA del v6.18 quedaba a medias: el env_spritetrail en L4D2 SI
// dibuja... pero solo ~1 s, y después se CONGELA (la entidad sigue viva:
// "el objeto no se elimina"). El fix de la comunidad: un SetScale
// diferido 0.5 s (AddOutput OnUser1 + FireUser1) re-despierta la estela
// y dibuja para siempre. Con esto el MODO AUTÉNTICO vuelve a
// env_spritetrail = el MISMO renderer para el que GMod disenho los .vmt
// del sonicball (alla útil.SpriteTrail crea un env_spritetrail).
// ---------------------------------------------------------------------
// v6.21: POSICION DE MUNDO de una entidad. Bug del "trail en el cielo
// lejano" (reporte del owner con capturas 2026-10-08: "los sprites que
// deberían salir en Sonic durante el spindash aparecen alla a lo lejos"
// — haces cruzando el cielo + una estructura magenta de alambres). Causa
// raíz: la receta avatar (world-pos -> SetParent re-basa el offset vivo)
// se aplicó en el v6.20 leyendo m_vecOrigin del PADRE — pero la BOLA y
// las copias R/L del avatar son props PARENTADOS al survivor: su
// m_vecOrigin es la origin LOCAL (~{0,0,15}), NO la de mundo. El hijo
// nacia teleportado al (0,0,15) DEL MAPA (el cielo a lo lejos) y el
// SetParent re-basaba un offset de MILES de unidades: toda la familia
// (3 env_spritetrail de la bola + glow01 + light_dynamic + info_targets
// del peel + el anillo del pulso del golpe) volaba por el cielo pegada
// a un offset gigante que además GIRABA con el yaw del survivor (= las
// formas geometricas de las capturas). FIX: leer m_vecAbsOrigin (la
// absoluta de verdad, correcta con o sin parent; canonica GetClientAbs-
// Origin para players; fallback defensivo al m_vecOrigin si la prop no
// existiera). Nota: los trails NATIVOS (TE, default) NO sufrian el bug
// — el beam TE lo dibuja el CLIENTE pegado a la entidad; solo el modo
// AUTÉNTICO (mat 1, env_spritetrail + fix) lo padecia.
// ---------------------------------------------------------------------
void Sonic_WorldOrigin(int ent, float pos[3])
{
    if (ent > 0 && ent <= MaxClients)
    {
        GetClientAbsOrigin(ent, pos);
        return;
    }
    if (HasEntProp(ent, Prop_Data, "m_vecAbsOrigin"))
        GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", pos);
    else
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", pos);
}

void Sonic_FixSpriteTrail(int tr)
{
    SetVariantString("OnUser1 !self:SetScale:1:0.5:1");
    AcceptEntityInput(tr, "AddOutput");
    AcceptEntityInput(tr, "FireUser1");
}

// v6.20: mata un EntRef de entidad creada por nosotros (spritetrail /
// glow / luz / info_target) y limpia su filtro de transmisión
void Sonic_KillOwnedEnt(int &ref)
{
    int e = EntRefToEntIndex(ref);
    if (e > 0 && IsValidEntity(e))
    {
        if (e < 4096) { g_iSonicSTOnly[e] = 0; g_iSonicSTExcl[e] = 0; }
        AcceptEntityInput(e, "Kill");
    }
    ref = 0;
}

// v6.20: filtro SetTransmit de los env_spritetrail auténticos (split
// dueño/demas — mismo mecanismo de las copias R/L del avatar)
public Action Sonic_STTransmit(int ent, int client)
{
    if (ent > 0 && ent < 4096)
    {
        if (g_iSonicSTOnly[ent] > 0 && GetClientUserId(client) != g_iSonicSTOnly[ent])
            return Plugin_Handled;
        if (g_iSonicSTExcl[ent] > 0 && GetClientUserId(client) == g_iSonicSTExcl[ent])
            return Plugin_Handled;
    }
    return Plugin_Continue;
}

// v6.20: crea un env_spritetrail AUTÉNTICO parentado (modo mat 1):
// material por RUTA (mismo formato que usaba el Sonic_MakeTrail v6.17),
// rendercolor "r g b", ADITIVO (additive=true en los 3 SpriteTrail del
// GMod), anchos/vida en unidades del motor. Split dueño/demas opcional
// vía SetTransmit. Devuelve EntRef (0 = fallo).
int Sonic_MakeSpriteTrail(int parent, const char[] mat, float life, float w1, float w2,
                          const char[] rgb, int onlyUser, int exclUser)
{
    if (parent <= 0 || !IsValidEntity(parent)) return 0;
    int tr = CreateEntityByName("env_spritetrail");
    if (tr <= 0 || !IsValidEntity(tr)) return 0;

    DispatchKeyValue(tr, "spritename", mat);
    DispatchKeyValueFloat(tr, "lifetime", life);
    DispatchKeyValueFloat(tr, "startwidth", w1);
    DispatchKeyValueFloat(tr, "endwidth", w2);
    DispatchKeyValue(tr, "rendercolor", rgb);
    DispatchKeyValue(tr, "renderamt", "255");
    DispatchKeyValue(tr, "rendermode", "5");   // aditivo (additive=true del GMod)

    // receta avatar (L1223-1247): keyvalues -> DispatchSpawn ->
    // world-pos -> SetParent (la posición queda re-basada al espacio
    // del padre con el offset vivo). v6.21: la world-pos ahora es la DE
    // VERDAD (Sonic_WorldOrigin) — el m_vecOrigin del padre era LOCAL
    // (bola/avatar van PARENTADOS) y el trail nacia en el (0,0,z) DEL
    // MAPA = el bug del cielo lejano
    float pos[3];
    Sonic_WorldOrigin(parent, pos);
    DispatchSpawn(tr);
    TeleportEntity(tr, pos, NULL_VECTOR, NULL_VECTOR);
    SetVariantString("!activator");
    AcceptEntityInput(tr, "SetParent", parent);

    Sonic_FixSpriteTrail(tr);

    if (onlyUser > 0 || exclUser > 0)
    {
        if (tr > 0 && tr < 4096)
        {
            g_iSonicSTOnly[tr] = onlyUser;
            g_iSonicSTExcl[tr] = exclUser;
        }
        SDKHook(tr, SDKHook_SetTransmit, Sonic_STTransmit);
    }
    return EntIndexToEntRef(tr);
}

// v6.20: info_target parentado a +zOffs — la receta EXACTA del
// trailOrigin del GMod (L1211-1215: el trail principal del peel cuelga
// de un info_target a Vector(0,0,20), no del origen del personaje)
int Sonic_MakeTrailTarget(int parent, float zOffs)
{
    if (parent <= 0 || !IsValidEntity(parent)) return 0;
    int t = CreateEntityByName("info_target");
    if (t <= 0 || !IsValidEntity(t)) return 0;
    float pos[3];
    Sonic_WorldOrigin(parent, pos);   // v6.21: MUNDO (el avatar es parentado)
    pos[2] += zOffs;
    DispatchSpawn(t);
    TeleportEntity(t, pos, NULL_VECTOR, NULL_VECTOR);
    SetVariantString("!activator");
    AcceptEntityInput(t, "SetParent", parent);
    return EntIndexToEntRef(t);
}

// v6.25: ELIMINADOS Sonic_MakeFootTarget y Sonic_MakeSteam — el env_steam
// NO dibuja en el cliente L4D2 (prueba de la 3.77.17 del owner: las 3
// nieblas invisibles) y los info_targets laterales de pies ya no hacen
// falta: los pies volvieron a las polylineas CHAIN, que muestran la
// posición viva del CLIENTE (cero entidades intermedias, cero parents).
// El trail principal CONSERVA su Sonic_MakeTrailTarget +20z (receta
// trailOrigin L1211-1215 del GMod, dibuja desde la v6.20).

// v6.20: BRILLO AZUL EN LA OSCURIDAD (pedido del owner): light_dynamic
// azul parentado — la luz de verdad que ilumina la escena alrededor
// (paredes/zombies) mientras dura la habilidad
int Sonic_MakeBlueLight(int parent, float zOffs, int dist = 220, float bright = 2.0)
{
    if (parent <= 0 || !IsValidEntity(parent)) return 0;
    int l = CreateEntityByName("light_dynamic");
    if (l <= 0 || !IsValidEntity(l)) return 0;
    DispatchKeyValue(l, "_light", "70 130 255 200");
    char sb[8], sd[8];
    FloatToString(bright, sb, sizeof(sb));
    IntToString(dist, sd, sizeof(sd));
    DispatchKeyValue(l, "brightness", sb);
    DispatchKeyValue(l, "distance", sd);
    DispatchKeyValue(l, "style", "0");
    float pos[3];
    Sonic_WorldOrigin(parent, pos);   // v6.21: MUNDO (la bola es parentada)
    pos[2] += zOffs;
    DispatchSpawn(l);
    TeleportEntity(l, pos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(l, "TurnOn");
    SetVariantString("!activator");
    AcceptEntityInput(l, "SetParent", parent);
    return EntIndexToEntRef(l);
}

// v6.20: glow01 aditivo azul SUAVE parentado a la bola — el "brillo" de
// la bola misma (UnlitGeneric = fullbright: se ve SIEMPRE, hasta en lo
// más oscuro; la luz dinámica ilumina la escena, este la hace brillar)
int Sonic_MakeBallGlow(int ball)
{
    if (ball <= 0 || !IsValidEntity(ball)) return 0;
    int s = CreateEntityByName("env_sprite");
    if (s <= 0 || !IsValidEntity(s)) return 0;
    DispatchKeyValue(s, "model", SONIC_SPRITE_GLOW);
    DispatchKeyValue(s, "scale", "0.7");
    DispatchKeyValue(s, "rendermode", "5");
    DispatchKeyValue(s, "rendercolor", "70 130 255");
    DispatchKeyValue(s, "renderamt", "140");
    DispatchKeyValue(s, "spawnflags", "1");   // Start on
    float pos[3];
    Sonic_WorldOrigin(ball, pos);   // v6.21: MUNDO (la bola es parentada)
    DispatchSpawn(s);
    TeleportEntity(s, pos, NULL_VECTOR, NULL_VECTOR);
    SetVariantString("!activator");
    AcceptEntityInput(s, "SetParent", ball);
    return EntIndexToEntRef(s);
}

// v6.20: EFECTO DE GOLPE del spindash — port del sonic_spindashhit del
// GMod (sonic.lua L234 + effects/om_noodles_effects_sonic.lua L203-253):
// alla un quad camera-facing con icons/sonic_drop_impact.png que crece
// 0->165 en 0.45s con fade (rotando a 900 gr/s) en la VICTIMA +50z.
// Aquí: flash env_sprite (material auténtico convertido a VTF si esta
// en el server, glow01 nativo si no) + anillo expansivo 10->165/0.45s
// + chispas. La rotación no es portable (sprite plano) — el crecimiento
// y el punch visual si.
void Sonic_SpawnHitFx(const float targetPos[3])
{
    float pos[3];
    pos[0] = targetPos[0];
    pos[1] = targetPos[1];
    pos[2] = targetPos[2] + 50.0;   // GMod: GetPos()+Vector(0,0,50)

    // 1) flash: vive 0.45s (MaxLife del efecto GMod) — Kill diferido
    //    por I/O (truco FireUser1, cero timers)
    int spr = CreateEntityByName("env_sprite");
    if (spr > 0 && IsValidEntity(spr))
    {
        bool auth = (g_bSonicHitFxMat && g_iSonicHitFxMat > 0);
        char matPath[PLATFORM_MAX_PATH];
        if (auth) strcopy(matPath, sizeof(matPath), SONIC_HITFX_MAT);
        else      strcopy(matPath, sizeof(matPath), SONIC_SPRITE_GLOW);
        float scale = auth ? 0.65 : 2.5;   // ~165u (256px custom / 64px glow01)
        DispatchKeyValue(spr, "model", matPath);
        DispatchKeyValueFloat(spr, "scale", scale);
        DispatchKeyValue(spr, "rendermode", "5");
        DispatchKeyValue(spr, "rendercolor", "255 255 255");
        DispatchKeyValue(spr, "renderamt", "255");
        DispatchKeyValue(spr, "spawnflags", "1");
        DispatchSpawn(spr);
        TeleportEntity(spr, pos, NULL_VECTOR, NULL_VECTOR);
        SetVariantString("OnUser1 !self:Kill::0.45:1");
        AcceptEntityInput(spr, "AddOutput");
        AcceptEntityInput(spr, "FireUser1");
    }

    // 2) anillo expansivo 10->165 en 0.45s (EndSize/MaxLife del GMod)
    if (g_iSonicGlowSprite > 0)
    {
        int cRing[4] = {200, 225, 255, 235};
        TE_SetupBeamRingPoint(pos, 10.0, 165.0, g_iSonicGlowSprite, g_iSonicGlowSprite,
                              0, 15, 0.45, 6.0, 1.0, cRing, 0, 0);
        TE_SendToAll();
    }

    // 3) chispas del golpe
    TE_SetupSparks(pos, NULL_VECTOR, 6, 3);
    TE_SendToAll();
}

// ---------------------------------------------------------------------
// v6.18: slots TE. Un trail = un slot; UN latido global (0.2s) re-
// envia los BeamFollow vivos y estira las polylineas encadenadas.
// FOLLOW: el beam se pega a la ENTIDAD (bola/avatar/martillo) y el
//   motor le acumula la estela detrás — Width = ancho en la cabecera
//   (la entidad), EndWidth = ancho en la cola: el mismo decaimiento
//   del SpriteTrail de GMod. El TE vive `life` s y muere: se re-envia
//   a life*0.8 = estela continua SIN apilar brillo aditivo.
// CHAIN: BeamPoints del pie actual al anterior — lo único que
//   permite DOS estelas con offset lateral (el BeamFollow no tiene
//   offset). Ancho uniforme: el taper por segmento quedaba en diente
//   de sierra a lo largo de la polylinea.
// onlyUser/exclUser: el mismo split SetTransmit del trail del speed
//   (el beam que sigue a la copia L SOLO lo recibe el dueño, el de la
//   R todos menos el dueño — cada cliente dibuja el beam de la copia
//   que puede ver).
// ---------------------------------------------------------------------
#define SONIC_TE_SLOTS   128     // v6.25: slots simultaneos (trail peel 3 capas x2 copias + pies 2 + bola 3
                                // por jugador = 8 Sonic corriendo en bola+peel a la vez con holgura)
#define SONIC_TE_TICK    0.01    // v6.26: latido del motor — 0.05 -> 0.01: un timer no puede
                                // disparar más rápido que UNA VEZ POR FOTOGRAMA del server,
                                // así que 0.01 = cada frame = 30 Hz en un server de 30 tick /
                                // 60 Hz con el TickrateEnabler del owner = EL regimen de
                                // muestreo del BeamFollow nativo (el cliente samplea al frame
                                // y por eso el trail del spindash "siempre está pegado" —
                                // pedido literal del owner "aumenta su hz"). Segmentos de
                                // 27u a 800 uu/s (13u a 60 fps) = curva CONTINUA. Historia:
                                // 0.2 (v6.18) = poligonos rigidos de 160u; 0.05 (v6.25) =
                                // segmentos de 40u todavia legibles a la vista. Los
                                // BeamFollow no cambian: cada slot re-envia a SU cadencia
                                // life*0.8 (el tick solo comprueba "ya toca?" — un tick
                                // barato de por si: 128 slots de if por frame).
#define SONIC_TE_FOLLOW  0       // BeamFollow pegado a una entidad
#define SONIC_TE_CHAIN   1       // polylinea encadenada (pies del peel)

bool   g_bSonicTEUsed[SONIC_TE_SLOTS];
int    g_iSonicTEType[SONIC_TE_SLOTS];
int    g_iSonicTEEnt[SONIC_TE_SLOTS];      // FOLLOW: EntRef de la entidad seguida
int    g_iSonicTEUser[SONIC_TE_SLOTS];     // CHAIN: userid del dueño del pie
int    g_iSonicTESide[SONIC_TE_SLOTS];     // CHAIN: -1 pie izq / +1 pie der
int    g_iSonicTEModel[SONIC_TE_SLOTS];
int    g_iSonicTEColor[SONIC_TE_SLOTS][4];
int    g_iSonicTEFade[SONIC_TE_SLOTS];    // v6.28: se mantuvo int — el stock TE_* de SourceMod declara FadeLength INT (0.22 era inválido); los pies llevan 1 (cola suave mínima, como OM_Stun)
int    g_iSonicTEOnly[SONIC_TE_SLOTS];     // userid destinatario único (0 = todos)
int    g_iSonicTEExcl[SONIC_TE_SLOTS];     // userid excluido (0 = nadie)
float  g_fSonicTELife[SONIC_TE_SLOTS];
float  g_fSonicTEW1[SONIC_TE_SLOTS];
float  g_fSonicTEW2[SONIC_TE_SLOTS];
float  g_fSonicTENext[SONIC_TE_SLOTS];     // FOLLOW: hora del próximo reenvio
float  g_fSonicTELast[SONIC_TE_SLOTS][3];  // CHAIN: posición del pie del latido anterior
Handle g_hSonicTETimer = null;

// envío con el mismo split SetTransmit del trail del speed
void Sonic_TESend(int onlyUser, int exclUser)
{
    int solo = 0;
    if (onlyUser > 0) solo = GetClientOfUserId(onlyUser);
    if (solo > 0)
    {
        if (IsClientInGame(solo)) TE_SendToClient(solo);
        return;
    }

    int fuera = (exclUser > 0) ? GetClientOfUserId(exclUser) : 0;
    int total = 0;
    int[] rec = new int[MaxClients];
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == fuera || !IsClientInGame(i)) continue;
        rec[total++] = i;
    }
    if (total > 0) TE_Send(rec, total);
}

int Sonic_TEAlloc()
{
    for (int s = 1; s < SONIC_TE_SLOTS; s++)
    {
        if (g_bSonicTEUsed[s]) continue;
        g_bSonicTEUsed[s] = true;
        if (g_hSonicTETimer == null)
            g_hSonicTETimer = CreateTimer(SONIC_TE_TICK, Sonic_TETick, _, TIMER_REPEAT);
        return s;
    }
    return 0;
}

// FOLLOW: beam pegado a `ent` (bola/avatar/martillo). El TE muere
// solo a los `life` s; el latido lo re-envia (estela continua)
int Sonic_TEStartFollow(int ent, int model, float life, float w1, float w2, int fade, const int color[4], int onlyUser = 0, int exclUser = 0)
{
    if (ent <= 0 || !IsValidEntity(ent) || model <= 0) return 0;
    int slot = Sonic_TEAlloc();
    if (slot == 0) return 0;

    g_iSonicTEType[slot]  = SONIC_TE_FOLLOW;
    g_iSonicTEEnt[slot]   = EntIndexToEntRef(ent);
    g_iSonicTEModel[slot] = model;
    g_fSonicTELife[slot]  = life;
    g_fSonicTEW1[slot]    = w1;
    g_fSonicTEW2[slot]    = w2;
    g_iSonicTEFade[slot]  = fade;
    g_iSonicTEOnly[slot]  = onlyUser;
    g_iSonicTEExcl[slot]  = exclUser;
    for (int k = 0; k < 4; k++) g_iSonicTEColor[slot][k] = color[k];

    // primer envío inmediato (la estela nace con la habilidad, no 0.2s tarde)
    TE_SetupBeamFollow(ent, model, 0, life, w1, w2, fade, color);
    Sonic_TESend(onlyUser, exclUser);
    g_fSonicTENext[slot] = GetEngineTime() + life * 0.8;
    return slot;
}

// CHAIN: estela del pie `side` de `userId` (offset lateral +-8u al
// tobillo, rotado por el yaw del cuerpo — el BeamFollow no tiene
// offset y es la única forma de tener DOS estelas de pies).
// v6.25: DE VUELTA EN USO (los pies del peel) — lo que SE VEÍA se
// conserva (polilineas .16) y lo que no se veía (BeamFollow sobre
// info_targets laterales .17) fuera. Muestrea la posición VIVA del
// CLIENTE: cero entidades intermedias.
// v6.26: EL LATIDO YA NO ES 0.05s — SONIC_TE_TICK bajó a 0.01 = dispara
// CADA FOTOGRAMA del server (30 Hz a 30 tick / 60 Hz con su
// TickrateEnabler): segmentos de 13-27u a 800 uu/s = el regimen de
// muestreo del BeamFollow nativo del spindash, el "siempre pegado"
// (pedido del owner: "aumenta su hz"). Cero entidades, cero parents,
// cero splits.
int Sonic_TEStartChain(int userId, int side, int model, float life, float w1, float w2, int fade, const int color[4])
{
    if (userId <= 0 || model <= 0) return 0;
    int slot = Sonic_TEAlloc();
    if (slot == 0) return 0;

    g_iSonicTEType[slot]  = SONIC_TE_CHAIN;
    g_iSonicTEUser[slot]  = userId;
    g_iSonicTESide[slot]  = side;
    g_iSonicTEModel[slot] = model;
    g_fSonicTELife[slot]  = life;
    g_fSonicTEW1[slot]    = w1;
    g_fSonicTEW2[slot]    = w2;
    g_iSonicTEFade[slot]  = fade;
    for (int k = 0; k < 4; k++) g_iSonicTEColor[slot][k] = color[k];
    for (int k = 0; k < 3; k++) g_fSonicTELast[slot][k] = 0.0;
    return slot;
}

void Sonic_TEStop(int &slot)
{
    if (slot > 0 && slot < SONIC_TE_SLOTS)
        g_bSonicTEUsed[slot] = false;
    slot = 0;

    // sin slots vivos el latido se apaga (higiene: un tick vacío no
    // enviaría nada, pero no deja el timer girando todo el mapa)
    for (int s = 1; s < SONIC_TE_SLOTS; s++)
        if (g_bSonicTEUsed[s]) return;
    if (g_hSonicTETimer != null)
    {
        KillTimer(g_hSonicTETimer);
        g_hSonicTETimer = null;
    }
}

// OnMapStart: barato y a prueba de todo (los slots del mapa anterior
// apuntan a entidades muertas)
void Sonic_TETeardown()
{
    if (g_hSonicTETimer != null)
    {
        KillTimer(g_hSonicTETimer);
        g_hSonicTETimer = null;
    }
    for (int s = 0; s < SONIC_TE_SLOTS; s++)
        g_bSonicTEUsed[s] = false;
}

public Action Sonic_TETick(Handle timer)
{
    float now = GetEngineTime();
    bool vivos = false;

    for (int s = 1; s < SONIC_TE_SLOTS; s++)
    {
        if (!g_bSonicTEUsed[s]) continue;
        vivos = true;

        if (g_iSonicTEType[s] == SONIC_TE_FOLLOW)
        {
            int ent = EntRefToEntIndex(g_iSonicTEEnt[s]);
            if (ent <= 0 || !IsValidEntity(ent))
            {
                g_bSonicTEUsed[s] = false;   // la entidad murió: slot se libera solo
                continue;
            }
            if (now < g_fSonicTENext[s]) continue;
            g_fSonicTENext[s] = now + g_fSonicTELife[s] * 0.8;

            TE_SetupBeamFollow(ent, g_iSonicTEModel[s], 0, g_fSonicTELife[s],
                               g_fSonicTEW1[s], g_fSonicTEW2[s], g_iSonicTEFade[s],
                               g_iSonicTEColor[s]);
            Sonic_TESend(g_iSonicTEOnly[s], g_iSonicTEExcl[s]);
        }
        else
        {
            int client = GetClientOfUserId(g_iSonicTEUser[s]);
            if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
            {
                g_bSonicTEUsed[s] = false;
                continue;
            }

            float pos[3], ang[3], foot[3];
            GetClientAbsOrigin(client, pos);
            GetClientAbsAngles(client, ang);
            float rad = ang[1] * FLOAT_PI / 180.0;
            float lat = 8.0 * view_as<float>(g_iSonicTESide[s]);
            foot[0] = pos[0] - lat * Sine(rad);
            foot[1] = pos[1] + lat * Cosine(rad);
            // v6.28: z+8 (tobillo) -> z+2 RAS DEL SUELO — la cuña roja del
            // GMod es un decal PLANO pegado al piso, en su video .20 la
            // nuestra flotaba al doble de altura (medición normalizada)
            foot[2] = pos[2] + 2.0;

            // solo si el pie se movió (parado no hay estela, como GMod)
            if (g_fSonicTELast[s][2] != 0.0
                && GetVectorDistance(g_fSonicTELast[s], foot) > 4.0)
            {
                TE_SetupBeamPoints(g_fSonicTELast[s], foot, g_iSonicTEModel[s], 0, 0, 0,
                                   g_fSonicTELife[s], g_fSonicTEW1[s], g_fSonicTEW2[s],
                                   g_iSonicTEFade[s], 0.0, g_iSonicTEColor[s], 0);
                TE_SendToAll();
            }
            for (int k = 0; k < 3; k++) g_fSonicTELast[s][k] = foot[k];
        }
    }

    if (!vivos && g_hSonicTETimer == timer)
    {
        g_hSonicTETimer = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// v6.19: NATIVO = DEFAULT. Rama auténtica (opt-in, sonicom_trails_mat 1
// + materiales en el server): las 3 capas EXACTAS del fadeeiie del
// sonic.lua (L1921-1964) — blue_2ndlayer.vmt ancha 70->40 blanca +
// blue.vmt 40->1 blanca + blue.vmt 40->1 con tinte MAGENTA. Rama NATIVA
// (default): MISMA geometria 3-capas del GMod sobre el laserbeam del
// juego con tintes — halo azul 70->40 (0.75s) + nucleo blanco-azul 40->1
// (0.5s) + acento AZUL PROFUNDO 40->1 (0.5s — v6.22: pedido del owner
// "no morado, azul"; alla era el Color(255,0,255) que sobre textura
// azul se leia violeta); las 3 eran ADITIVAS
// (additive=true en los 3 útil.SpriteTrail) y el laserbeam también lo
// es. v6.18: BeamFollow — Width = ancho en la bola (cabecera), EndWidth
// = ancho de la cola: el mismo decaimiento del SpriteTrail de GMod.
// La bola no tiene filtro SetTransmit (la ven todos): envío a todos.
// v6.20: NATIVO sigue de DEFAULT + anchos REESCALADOS A LA BOLA (~32u
// a escala 1.25). Rama auténtica (opt-in, sonicom_trails_mat 1 +
// materiales en el server): env_spritetrail + FIX (fbef0102) = el
// renderer del GMod con los .vmt originales; fallback TE si la creación
// falla. Las 3 capas EXACTAS del fadeeiie del sonic.lua (L1921-1964).
void Sonic_CreateBallTrails(int client)
{
    Sonic_KillBallTrails(client);
    if (g_cvSonicTrails == null || !g_cvSonicTrails.BoolValue) return;
    int ball = (g_iSonicBall[client] != 0) ? EntRefToEntIndex(g_iSonicBall[client]) : -1;
    if (ball <= 0 || !IsValidEntity(ball)) return;

    // v6.20: ANCHOS REESCALADOS A LA BOLA REAL — sonicball.mdl es una
    // esfera de ~26u y el spin la lleva a escala 1.25 (GMod) = ~32u de
    // diámetro; el owner midio el 70 del GMod "literalmente más grande
    // que la ball". Mismas proporciones relativas ajustadas a la bola:
    // halo 70->40 pasa a 34->19 (aura apenas más ancha que la bola),
    // nucleo y magenta 40->1 pasan a 24->1. Vidas intactas (0.75/0.5/0.5)
    // v6.28: sonicom_trails_mat FUERA — AUTÉNTICO SIEMPRE que los
    // archivos existan (orden del owner: "el parche lo arreglo... siempre
    // usara los materiales originales"); el TE nativo queda solo como
    // fallback de creación fallida o pack ausente.
    bool wantAuth = g_bSonicBallMatWide && g_bSonicBallMatFade
                    && g_iSonicTEMatWide > 0 && g_iSonicTEMatFade > 0;
    bool stOK = false;
    if (wantAuth)
    {
        // v6.20: AUTÉNTICO = env_spritetrail + FIX (fbef0102): el MISMO
        // renderer del útil.SpriteTrail de GMod con los .vmt originales
        // del sonicball (el mapeo de textura para el que fueron disenados)
        g_iSonicBallSTrR[client] = Sonic_MakeSpriteTrail(ball, SONIC_BALL_MAT_WIDE, 0.75, 34.0, 19.0, "255 255 255", 0, 0);
        g_iSonicBallSTrW[client] = Sonic_MakeSpriteTrail(ball, SONIC_BALL_MAT_FADE, 0.5, 24.0, 1.0, "255 255 255", 0, 0);
        // v6.22: 3a capa AZUL PROFUNDO (pedido del owner: "no morado,
        // azul") — el Color(255,0,255) del Lua sobre la textura azul de
        // alla se leia azul-violeta; sobre nuestro render se leia ROSA
        g_iSonicBallSTrM[client] = Sonic_MakeSpriteTrail(ball, SONIC_BALL_MAT_FADE, 0.5, 24.0, 1.0, "35 90 255", 0, 0);
        stOK = (g_iSonicBallSTrR[client] != 0 && g_iSonicBallSTrW[client] != 0
                && g_iSonicBallSTrM[client] != 0);
        if (!stOK)
        {
            // algo fallo al crear: limpiar y caer al TE (el diseño v6.19)
            Sonic_KillOwnedEnt(g_iSonicBallSTrR[client]);
            Sonic_KillOwnedEnt(g_iSonicBallSTrW[client]);
            Sonic_KillOwnedEnt(g_iSonicBallSTrM[client]);
        }
    }

    if (!stOK)
    {
        int mWide = wantAuth ? g_iSonicTEMatWide : g_iSonicTELaser;
        int mFade = wantAuth ? g_iSonicTEMatFade : g_iSonicTELaser;
        if (wantAuth)
        {
            int cWhite[4] = {255, 255, 255, 255};
            int cMag[4]   = {35, 90, 255, 255};    // v6.22: azul profundo (no magenta)
            g_iSonicBallTrailR[client] = Sonic_TEStartFollow(ball, mWide, 0.75, 34.0, 19.0, 3, cWhite);
            g_iSonicBallTrailW[client] = Sonic_TEStartFollow(ball, mFade, 0.5, 24.0, 1.0, 3, cWhite);
            g_iSonicBallTrailM[client] = Sonic_TEStartFollow(ball, mFade, 0.5, 24.0, 1.0, 3, cMag);
        }
        else
        {
            // v6.20: geometria GMod sobre laserbeam nativo (default) con
            // los anchos escalados + alphas al alza (más potente)
            int cHalo[4] = {70, 130, 255, 195};   // capa ancha 34->19 azul suave
            int cCore[4] = {175, 220, 255, 235};  // capa fina 24->1 nucleo claro
            int cMag[4]  = {35, 90, 255, 195};    // v6.22: 3a capa AZUL (pedido del owner)
            g_iSonicBallTrailR[client] = Sonic_TEStartFollow(ball, mWide, 0.75, 34.0, 19.0, 3, cHalo);
            g_iSonicBallTrailW[client] = Sonic_TEStartFollow(ball, mFade, 0.5, 24.0, 1.0, 3, cCore);
            g_iSonicBallTrailM[client] = Sonic_TEStartFollow(ball, mFade, 0.5, 24.0, 1.0, 3, cMag);
        }
    }

    // v6.20: BRILLO AZUL EN LA OSCURIDAD de la bola (pedido del owner):
    // glow01 azul suave pegado a la bola (fullbright, se ve siempre) +
    // light_dynamic azul que ilumina la escena alrededor en lo oscuro
    g_iSonicBallGlow[client]  = Sonic_MakeBallGlow(ball);
    g_iSonicBallLight[client] = Sonic_MakeBlueLight(ball, 0.0, 220, 2.0);
}

void Sonic_KillBallTrails(int client)
{
    Sonic_TEStop(g_iSonicBallTrailR[client]);
    Sonic_TEStop(g_iSonicBallTrailW[client]);
    Sonic_TEStop(g_iSonicBallTrailM[client]);
    // v6.20: entidades del auténtico (env_spritetrail) + brillo azul
    Sonic_KillOwnedEnt(g_iSonicBallSTrR[client]);
    Sonic_KillOwnedEnt(g_iSonicBallSTrW[client]);
    Sonic_KillOwnedEnt(g_iSonicBallSTrM[client]);
    Sonic_KillOwnedEnt(g_iSonicBallGlow[client]);
    Sonic_KillOwnedEnt(g_iSonicBallLight[client]);
}

// ---------------------------------------------------------------------
// v6.28: EL BEAM DEL TORSO del modo sonicom_peel_nube 1 — LA RECETA
// EXACTA del trail de colores del Speed_sonic (L1227-1251: BeamFollow
// laserbeam 0.6s, ancho 10->1, fade 3), azul del humo "125 185 255",
// naciendo del TORSO: el mismo info_target +20z del trail principal
// (el attachment "Trail" del QC a +19.08z), con el mismo split
// dueño/demas de siempre. Pedido literal del owner (2026-10-09): "si
// en este cambio el humo sigue sin salir ponme un comando que me
// permita que este cambie por el Beam este nativo que usa el speed
// para complementar la falta (necera desde el torso)".
// ---------------------------------------------------------------------
void Sonic_PeelNubeBeamStart(int client)
{
    if (g_iSonicPeelNubeBeam[client] != 0 || g_iSonicPeelNubeBeamO[client] != 0) return;
    int tgt  = (g_iSonicPeelTgt[client]  != 0) ? EntRefToEntIndex(g_iSonicPeelTgt[client])  : 0;
    int tgtO = (g_iSonicPeelTgtO[client] != 0) ? EntRefToEntIndex(g_iSonicPeelTgtO[client]) : 0;
    if (tgt <= 0 || !IsValidEntity(tgt)) return;

    int userid = GetClientUserId(client);
    int cNube[4] = {125, 185, 255, 220};   // el azul del humo del GMod
    if (tgtO > 0 && tgtO != tgt && IsValidEntity(tgtO))
    {
        g_iSonicPeelNubeBeamO[client] = Sonic_TEStartFollow(tgtO, g_iSonicTELaser, 0.6, 10.0, 1.0, 3, cNube, userid, 0);
        g_iSonicPeelNubeBeam[client]  = Sonic_TEStartFollow(tgt,  g_iSonicTELaser, 0.6, 10.0, 1.0, 3, cNube, 0, userid);
    }
    else
    {
        g_iSonicPeelNubeBeam[client] = Sonic_TEStartFollow(tgt, g_iSonicTELaser, 0.6, 10.0, 1.0, 3, cNube);
    }
}

// v6.18: la carrera del peel con los materiales del GMod — trail
// principal blue2.vmt (16->1, vida 0.75, blanco, L1221-1231) + los
// DOS trails de pies ROJOS (Sonicred.vmt 6->1 en los attachments 2/3
// del puppet alla L1232-1258; aquí polylineas encadenadas con offset
// lateral +-8u al tobillo — el BeamFollow no tiene offset, es la
// única forma de tener DOS estelas de pies). El trail principal va
// al AVATAR (R para los demas / L para el dueño — el survivor viaja
// en RENDER_NONE y un beam sobre un cuerpo invisible "sale del
// aire": la misma lección del trail del speed v5.20) con el mismo
// split SetTransmit. Fallback: el laserbeam del v6.6.
// v6.20: la carrera del peel — MISMO diseño GMod con la receta EXACTA
// del trailOrigin: el trail principal blue2.vmt (16->1, vida 0.75,
// blanco, L1221-1231) cuelga de un info_target parentado a +20z (alla
// L1211-1215) — el BeamFollow directo al avatar lo dibujaba AL RAS DEL
// SUELO (el origen del avatar son los PIES) y la franja de 16u se
// tragaba las estelas rojas. Los DOS trails de pies ROJOS (Sonicred.vmt
// 6->1, vida 0.75 — valores GMod EXACTOS L1232-1258; en los attachments
// 2/3 del puppet alla; aquí polylineas encadenadas con offset lateral
// +-8u al tobillo). Split R/L (SetTransmit en auténtico / solo-excl en
// TE). v6.20: azul MÁS POTENTE (alpha 200->250, vida 0.55->0.75) +
// light_dynamic azul en el player (brillo en la oscuridad).
void Sonic_CreatePeelTrail(int client)
{
    Sonic_KillPeelTrail(client);
    if (g_cvSonicTrails == null || !g_cvSonicTrails.BoolValue) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;

    int userid = GetClientUserId(client);

    // avatar R/L vía el puente del speed (en el peel no hay bola: da
    // las copias del avatar; sin avatar, el propio cliente)
    int avOwner, avOthers;
    bool tieneAvatar = Sonic_GetAvatarEnts(client, avOwner, avOthers);

    // v6.20: info_target a +20z por copia — el trail principal (beam o
    // spritetrail) sigue a ESTO, no al origen del avatar
    if (tieneAvatar && avOwner == avOthers)
    {
        g_iSonicPeelTgt[client] = Sonic_MakeTrailTarget(avOthers, 20.0);
    }
    else if (tieneAvatar)
    {
        g_iSonicPeelTgt[client]  = Sonic_MakeTrailTarget(avOthers, 20.0);
        g_iSonicPeelTgtO[client] = Sonic_MakeTrailTarget(avOwner, 20.0);
    }
    else
    {
        g_iSonicPeelTgt[client] = Sonic_MakeTrailTarget(client, 20.0);
    }
    int tgt  = (g_iSonicPeelTgt[client]  != 0) ? EntRefToEntIndex(g_iSonicPeelTgt[client])  : 0;
    int tgtO = (g_iSonicPeelTgtO[client] != 0) ? EntRefToEntIndex(g_iSonicPeelTgtO[client]) : 0;

    bool wantAuth = g_bSonicPeelMatMain && g_iSonicTEMatPeel > 0;
    bool stOK = false;
    if (wantAuth && tgt > 0)
    {
        // v6.20: AUTÉNTICO = env_spritetrail sobre el info_target (la
        // receta EXACTA del GMod: SpriteTrail(trailOrigin, ...)) con el
        // fix de fbef0102 y el split R/L por SetTransmit
        if (tieneAvatar && avOwner != avOthers && tgtO > 0)
        {
            g_iSonicPeelSTrailO[client] = Sonic_MakeSpriteTrail(tgtO, SONIC_PEEL_MAT_MAIN, 0.75, 16.0, 1.0, "255 255 255", userid, 0);
            g_iSonicPeelSTrail[client]  = Sonic_MakeSpriteTrail(tgt,  SONIC_PEEL_MAT_MAIN, 0.75, 16.0, 1.0, "255 255 255", 0, userid);
        }
        else
        {
            g_iSonicPeelSTrail[client] = Sonic_MakeSpriteTrail(tgt, SONIC_PEEL_MAT_MAIN, 0.75, 16.0, 1.0, "255 255 255", 0, 0);
        }
        stOK = (g_iSonicPeelSTrail[client] != 0 || g_iSonicPeelSTrailO[client] != 0);
        if (!stOK)
        {
            Sonic_KillOwnedEnt(g_iSonicPeelSTrail[client]);
            Sonic_KillOwnedEnt(g_iSonicPeelSTrailO[client]);
        }
    }

    if (!stOK)
    {
        // TE BeamFollow (nativo o fallback del auténtico).
        // v6.25: 3 CAPAS ESTILO SPINDASH — pedido LITERAL del owner ("el
        // Beam azul (que se parece un poco a la de spindash)").
        // v6.26: GEOMETRIA EXACTA DE LA BOLA — la v6.25 era esbelta
        // (28->14 + 15->1 + 15->1, alfas 165-205) y en el video del owner
        // leia como nada ("el laser azul que falta... el que antes
        // aparecía a espaldas de sonic"): ahora es LA MISMA del trail de
        // la bola que su server certifica desde la v6.19 — halo ancho
        // 34->19 / nucleo claro 24->1 / acento azul profundo 24->1 (los
        // mismos anchos del spindash), alfas 190-220, laserbeam radial
        // (inmune a la orientación) sobre el info_target +20z: la banda
        // que en el video GMod flota EN EL AIRE sobre la línea roja del
        // suelo (nunca a ras) y queda a ESPALDAS del corredor mientras
        // avanza. Split dueño/demas intacto (el beam del dueño sigue su
        // copia, el de los demas la otra).
        int cHalo[4] = {120, 170, 255, 190};
        int cCore[4] = {225, 240, 255, 220};
        int cAcc[4]  = {35, 90, 255, 200};
        int model = g_iSonicTELaser;
        if (tgt > 0)
        {
            if (tieneAvatar && avOwner != avOthers && tgtO > 0)
            {
                g_iSonicPeelTrailO[client]  = Sonic_TEStartFollow(tgtO, model, 0.75, 34.0, 19.0, 60, cHalo, userid, 0);
                g_iSonicPeelTrail[client]   = Sonic_TEStartFollow(tgt,  model, 0.75, 34.0, 19.0, 60, cHalo, 0, userid);
                g_iSonicPeelTrailO2[client] = Sonic_TEStartFollow(tgtO, model, 0.5, 24.0, 1.0, 40, cCore, userid, 0);
                g_iSonicPeelTrail2[client]  = Sonic_TEStartFollow(tgt,  model, 0.5, 24.0, 1.0, 40, cCore, 0, userid);
                g_iSonicPeelTrailO3[client] = Sonic_TEStartFollow(tgtO, model, 0.5, 24.0, 1.0, 40, cAcc, userid, 0);
                g_iSonicPeelTrail3[client]  = Sonic_TEStartFollow(tgt,  model, 0.5, 24.0, 1.0, 40, cAcc, 0, userid);
            }
            else
            {
                g_iSonicPeelTrail[client]  = Sonic_TEStartFollow(tgt, model, 0.75, 34.0, 19.0, 60, cHalo);
                g_iSonicPeelTrail2[client] = Sonic_TEStartFollow(tgt, model, 0.5, 24.0, 1.0, 40, cCore);
                g_iSonicPeelTrail3[client] = Sonic_TEStartFollow(tgt, model, 0.5, 24.0, 1.0, 40, cAcc);
            }
        }
        else
        {
            // info_target fallo (raro): el avatar/client directo como la
            // v6.19 — mejor un beam bajo que ninguno
            if (tieneAvatar && avOwner == avOthers)
            {
                g_iSonicPeelTrail[client]  = Sonic_TEStartFollow(avOthers, model, 0.75, 34.0, 19.0, 60, cHalo);
                g_iSonicPeelTrail2[client] = Sonic_TEStartFollow(avOthers, model, 0.5, 24.0, 1.0, 40, cCore);
                g_iSonicPeelTrail3[client] = Sonic_TEStartFollow(avOthers, model, 0.5, 24.0, 1.0, 40, cAcc);
            }
            else if (tieneAvatar)
            {
                g_iSonicPeelTrailO[client]  = Sonic_TEStartFollow(avOwner, model, 0.75, 34.0, 19.0, 60, cHalo, userid, 0);
                g_iSonicPeelTrail[client]   = Sonic_TEStartFollow(avOthers, model, 0.75, 34.0, 19.0, 60, cHalo, 0, userid);
                g_iSonicPeelTrailO2[client] = Sonic_TEStartFollow(avOwner, model, 0.5, 24.0, 1.0, 40, cCore, userid, 0);
                g_iSonicPeelTrail2[client]  = Sonic_TEStartFollow(avOthers, model, 0.5, 24.0, 1.0, 40, cCore, 0, userid);
                g_iSonicPeelTrailO3[client] = Sonic_TEStartFollow(avOwner, model, 0.5, 24.0, 1.0, 40, cAcc, userid, 0);
                g_iSonicPeelTrail3[client]  = Sonic_TEStartFollow(avOthers, model, 0.5, 24.0, 1.0, 40, cAcc, 0, userid);
            }
            else
            {
                g_iSonicPeelTrail[client]  = Sonic_TEStartFollow(client, model, 0.75, 34.0, 19.0, 60, cHalo);
                g_iSonicPeelTrail2[client] = Sonic_TEStartFollow(client, model, 0.5, 24.0, 1.0, 40, cCore);
                g_iSonicPeelTrail3[client] = Sonic_TEStartFollow(client, model, 0.5, 24.0, 1.0, 40, cAcc);
            }
        }
    }

    // PIES ROJOS (GMod L1232-1258: SpriteTrail Sonicred 6->1, vida 0.75,
    // fadeTime 0.2, attachments 2/3 del puppet — UNA por pie, SIN split:
    // alla todos ven los dos pies). v6.25: POLILINEAS CHAIN DE VUELTA —
    // el único mecanismo de pies que este server YA demostro que dibuja
    // (la .16: "beams rojos brillantes" del análisis del video; la .17
    // con BeamFollow sobre info_targets laterales: invisible). El defecto
    // de la .16 era el muestreo 0.2s (segmentos RECTOS de 160u a 800 uu/s
    // = poligonos): el latido ahora corre por FOTOGRAMA = segmentos de
    // 13-27u = curva continua. Muestrea la posición VIVA del cliente
    // (+-8 lateral al tobillo): cero entidades intermedias.
    // v6.28: BOTAS COMO EL VIDEO GMOD (medición normalizada de los 2
    //   videos): z+8 (tobillo, flotaba al DOBLE de alto que alla) -> z+2
    //   RAS DEL SUELO como la cuña plana del GMod; ancho 6->1 (la mayor
    //   parte del largo quedaba en 1-3u = línea laser fina) -> 7->3.5
    //   (cinta gruesa tipo huella de neumatico) y fade 0 (corte seco al
    //   morir el segmento) -> 1 (cola suave mínima — el stock TE_* declara
    //   FadeLength INT y el fadeTime 0.2 del Lua no es representable; en
    //   segmentos de 13-27u sería imperceptible). AUTÉNTICO = el chip
    //   Sonicred SIEMPRE (el chip
    //   2x2 plano es inmune al mapeo U/V de los TE beams y lee como la
    //   cinta SOLIDA opaca del GMod — la diferencia "laser fino vs
    //   cuña gruesa" que el owner senalo en los videos); nativo = fallback
    //   laserbeam {235,60,60} si el pack no esta.
    bool wantAuthF = g_bSonicPeelMatFoot && g_iSonicTEMatFoot > 0;
    if (wantAuthF)
    {
        int cWhite[4] = {255, 255, 255, 255};
        g_iSonicPeelFootL[client] = Sonic_TEStartChain(userid, -1, g_iSonicTEMatFoot, 0.75, 7.0, 3.5, 1, cWhite);
        g_iSonicPeelFootR[client] = Sonic_TEStartChain(userid,  1, g_iSonicTEMatFoot, 0.75, 7.0, 3.5, 1, cWhite);
    }
    else
    {
        int cRed[4] = {235, 60, 60, 235};
        g_iSonicPeelFootL[client] = Sonic_TEStartChain(userid, -1, g_iSonicTELaser, 0.75, 7.0, 3.5, 1, cRed);
        g_iSonicPeelFootR[client] = Sonic_TEStartChain(userid,  1, g_iSonicTELaser, 0.75, 7.0, 3.5, 1, cRed);
    }

    // v6.20: BRILLO AZUL en la oscuridad del peel: luz dinámica azul en
    // el PLAYER (sigue la posición real — la luz es de mundo, sin split)
    // v6.23: luz del peel RECALIBRADA (reporte del owner: la del v6.20 a
    // radio 220 / brightness 2 / +40z (cabeza) lavaba de azul la niebla y
    // las paredes enteras = la "nube gigante" de las capturas 04:50):
    // radio 150 / brightness 1 / +20z (cuerpo) — brilla azul en lo oscuro
    // sin convertirse en un blob; en GMod la "luz" de la carrera son los
    // glow particles aditivos (5 por latido, abajo), NO un dlight.
    // v6.24: 170 / 1.1 — un pelin más de presencia (pedido "la luz"),
    // todavia lejos del blob.
    g_iSonicPeelLight[client] = Sonic_MakeBlueLight(client, 20.0, 170, 1.1);

    // v6.28: si la palanca sonicom_peel_nube viene en 1, el BEAM NATIVO
    // DEL SPEED (desde el TORSO) nace ya con la carrera; si viene en 0 lo
    // arranca el CloudTick al vuelo si el owner la cambia a mitad de peelando
    if (g_cvSonicPeelNube != null && g_cvSonicPeelNube.BoolValue)
        Sonic_PeelNubeBeamStart(client);

    // v6.25: LA NIEBLA AZUL ya NO es env_steam (no dibuja en el cliente
    // L4D2 — prueba .17 del owner: invisible): la masa de la nube la
    // pone la BATERÍA DE SPRITES de Sonic_PeelCloudTick (5 humos + 5
    // glows por latido 0.1s, el mecanismo del polvo de la carga que SI
    // se veía en su video) + los moons. Aquí no queda nada más.
}

void Sonic_KillPeelTrail(int client)
{
    Sonic_TEStop(g_iSonicPeelTrail[client]);
    Sonic_TEStop(g_iSonicPeelTrailO[client]);
    Sonic_TEStop(g_iSonicPeelTrail2[client]);
    Sonic_TEStop(g_iSonicPeelTrail3[client]);
    Sonic_TEStop(g_iSonicPeelTrailO2[client]);
    Sonic_TEStop(g_iSonicPeelTrailO3[client]);
    Sonic_TEStop(g_iSonicPeelFootL[client]);
    Sonic_TEStop(g_iSonicPeelFootR[client]);
    // v6.28: el beam del torso del modo sonicom_peel_nube 1 también muere
    Sonic_TEStop(g_iSonicPeelNubeBeam[client]);
    Sonic_TEStop(g_iSonicPeelNubeBeamO[client]);
    // v6.20: entidades (spritetrails auténticos + info_targets + luz).
    // v6.25: los targets de pies y los 3 steams FUERON — polylinas al
    // cliente (pies) y batería de sprites (nube/polvo).
    Sonic_KillOwnedEnt(g_iSonicPeelSTrail[client]);
    Sonic_KillOwnedEnt(g_iSonicPeelSTrailO[client]);
    Sonic_KillOwnedEnt(g_iSonicPeelTgt[client]);
    Sonic_KillOwnedEnt(g_iSonicPeelTgtO[client]);
    Sonic_KillOwnedEnt(g_iSonicPeelLight[client]);
}

// ---------------------------------------------------------------------
// v6.22: LA NUBE AZUL DEL PEEL OUT — port del bloque visual del Think
// del GMod (sonic.lua L1588-1662) que faltaba: alrededor del corredor,
// cada 0.1s (NUESTRA FSM corre a 10 Hz exactos = la misma cadencia del
// emitter GMod): HUMO AZUL (alla particle_smokegrenade Color(135,185,
// 255), 16 puffs 20-25->0, vida 0.05-0.6) + GLOWS (light_glow02_add
// Color(125,125,175), 16 de 45-55->0) + 1 "moon" (sonic_peelout_moons:
// quads sonic_dashing_effect en espiral 16->112 creciendo 0.5s —
// aquí sprite estático de 40-90u). Implementación: batería de
// env_sprites efimeros nacidos en POSICION DE MUNDO, SIN parent y con
// Kill diferido por I/O (el truco FireUser1 del SpawnHitFx: cero
// timers, cero parents, CERO riesgo del bug del cielo v6.21). Al no
// estar parentados, cada puff se queda donde nació y el corredor se
// aleja: la nube queda detrás SOLA (el mismo resultado del emitter GMod
// con air resistance 255). Densidad recalibrada a entidades: 3 humos +
// 2 glows + 1 moon por latido (~60/s, pico ~30 vivos — alla eran 32
// particulas/0.1s con física de cliente). Fallbacks: sin om_bluesmoke
// el humo sale con glow01 tenue (aditivo); sin sonic_dashing_effect no
// hay moon (humo+glows siguen). Todo el conjunto respeta sonicom_trails
// (es FX visual de la habilidad, como los trails).
// ---------------------------------------------------------------------
void Sonic_SpawnPeelPuff(const float pos[3], const char[] mat, float scale,
                         const char[] rgb, int alpha, float life,
                         float scaleEnd = -1.0)
{
    int s = CreateEntityByName("env_sprite");
    if (s <= 0 || !IsValidEntity(s)) return;
    char amt[8];
    IntToString(alpha, amt, sizeof(amt));
    DispatchKeyValue(s, "model", mat);
    DispatchKeyValueFloat(s, "scale", scale);
    // v6.26: SIEMPRE ADITIVO (5). El rendermode 0 (kRenderNormal) que
    // usaban los humos dibuja el quad OPAOCO: los texeles transparentes
    // de glow01/om_bluesmoke (RGB 0) pintan NEGRO y solo el nucleo blanco
    // sobrevive = los CUADROS NEGROS de bordes duros del video del owner
    // (13-20-15: "la cosa esta negra", 5-7 por fotograma dominando la
    // pantalla). Todo env_sprite que este server YA dibuja bien (glow de
    // la bola, chispas, niebla, polvo) es rendermode 5 — el aditivo
    // también apila suave (50 sprites/s viviendo 0.4-1.0s se funden en
    // una masa) que es exactamente la lectura del video GMod.
    DispatchKeyValue(s, "rendermode", "5");
    DispatchKeyValue(s, "rendercolor", rgb);
    DispatchKeyValue(s, "renderamt", amt);
    DispatchKeyValue(s, "spawnflags", "1");   // Start on
    DispatchSpawn(s);
    TeleportEntity(s, pos, NULL_VECTOR, NULL_VECTOR);

    // v6.23: DESVANECIDO y ESCALA por I/O (todo en la MISMA cadena OnUser1
    // que el Kill — cero timers, cero thinks): Alpha->0 justo al final de
    // la vida (el puff se apaga suave en vez de desaparecer de golpe) y un
    // salto de escala a mitad de vida (encoger humos/glows como los
    // SetEndSize 0 del GMod / CRECER los moons y el polvo como sus
    // SetEndSize grandes). Si el input "Scale" no existiera en L4D2 el
    // AddOutput simplemente no hace nada (el Alpha/Kill son genericos y
    // esos SI) — degrada elegante a la v6.22.
    char io[80];
    if (scaleEnd > 0.0)
    {
        Format(io, sizeof(io), "OnUser1 !self:Scale:%.2f:%.2f:1",
               scaleEnd, life * 0.5);
        SetVariantString(io);
        AcceptEntityInput(s, "AddOutput");
    }
    Format(io, sizeof(io), "OnUser1 !self:Alpha:0:%.2f:1", life);
    SetVariantString(io);
    AcceptEntityInput(s, "AddOutput");
    Format(io, sizeof(io), "OnUser1 !self:Kill::%.2f:1", life + 0.05);
    SetVariantString(io);
    AcceptEntityInput(s, "AddOutput");
    AcceptEntityInput(s, "FireUser1");
}

// ---------------------------------------------------------------------
// v6.27: LA ESFERITA BLANCA VOLADORA — una por una, con MOVIMIENTO REAL.
// Diferencia con Sonic_SpawnPeelPuff (que nace y muere en el sitio):
// SetEntityMoveType(MOVETYPE_FLY) + TeleportEntity con velocity => el
// ENGINE la mueve cada tick (sin timers, sin thinks — el mismo truco de
// los proyectiles caseros de SM). El lua GMod era una particula de
// CLIENTE con física (VectorRand 30-80, gravedad suave +z, air resistance
// 40); aquí es un edict con velocity lineal — el sesgo +z al nacer
// reemplaza la gravedad, la vida corta (1.2-2.5s) hace que la falta de
// fricción no se note (30-80 uu/s casi constantes). Si el movetype no
// simulase en algún build: queda como un puff estático más (inofensivo,
// documentado). Kill diferido por I/O como todos (FireUser1): cero leaks.
// ---------------------------------------------------------------------
void Sonic_SpawnPeelBall(const float pos[3], const float vel[3], float life)
{
    int s = CreateEntityByName("env_sprite");
    if (s <= 0 || !IsValidEntity(s)) return;
    // v6.28: glow01 SIEMPRE tintado "224 240 255" — el video GMod las
    // muestra como motas REDONDAS suaves cian-blanco (#E0F0FF) con
    // brillo alto que PULSAN en el sitio; la estrella crema del
    // fleetways (v6.27) leia amarillenta con destello en cruz y el
    // owner las quería "más florecentes con brillo". El glow01 aditivo
    // a alpha 200 ES esa mota brillante. (El fleetways queda en el zip
    // como referencia; si el owner extrana la estrella es 1 línea.)
    char amt[8];
    IntToString(200, amt, sizeof(amt));           // v6.28: 150 -> 200 (más florecente)
    DispatchKeyValue(s, "model", SONIC_SPRITE_GLOW);
    DispatchKeyValueFloat(s, "scale", GetRandomFloat(0.05, 0.09));
    DispatchKeyValue(s, "rendermode", "5");      // aditivo (todo lo que este server dibuja bien)
    DispatchKeyValue(s, "rendercolor", "224 240 255");  // cian-blanco #E0F0FF del video GMod
    DispatchKeyValue(s, "renderamt", amt);
    DispatchKeyValue(s, "spawnflags", "1");       // Start on
    DispatchSpawn(s);
    TeleportEntity(s, pos, NULL_VECTOR, vel);      // posición + VELOCIDAD de dispersión
    SetEntityMoveType(s, MOVETYPE_FLY);             // el engine la dispersa sola

    // encoger suave (SetEndSize(0) del lua) y apagar al final — todo I/O
    char io[80];
    Format(io, sizeof(io), "OnUser1 !self:Scale:0.00:%.2f:1", life * 0.55);
    SetVariantString(io);
    AcceptEntityInput(s, "AddOutput");
    Format(io, sizeof(io), "OnUser1 !self:Alpha:0:%.2f:1", life * 0.9);
    SetVariantString(io);
    AcceptEntityInput(s, "AddOutput");
    Format(io, sizeof(io), "OnUser1 !self:Kill::%.2f:1", life + 0.05);
    SetVariantString(io);
    AcceptEntityInput(s, "AddOutput");
    AcceptEntityInput(s, "FireUser1");
}

// v6.22: la NUBE de la CARRERA (pealoutEffectcd2 cada 0.1s en GMod).
// La invoca la FSM case 2 (corriendo) — ya corre a 10 Hz.
// v6.25: LA NUBE ES LA BATERÍA — el env_steam de la v6.24 resulto NO
// dibujar en el cliente L4D2 (prueba del owner: cero niebla); este tick
// vuelve a ser LA MASA con el único mecanismo de particulas que su
// server ya demostro (el polvo de la carga se veía en su video).
// v6.27: EL HUMO BLANCO SE VA — "las esferitas blancas... CAMBIAN el
// humo blanco (lo dice el lua de Gmod)": los 5 humos "135 185 255" del
// latido FUERA; la masa de la carrera ahora son LAS ESFERITAS BLANCAS
// voladoras (Sonic_PeelTinyBall, el OM_tinyball_fleetway del lua) + los
// GLOWS "125 125 175" (las líneas de velocidad del video GMod, aprobadas
// desde la .18) + el moon. El polvo gris de la CARGA (PeelChargeDust)
// NO se toca: es del sonic.lua original (sonic_peeloutdust2_OM). Port
// 1-a-1 del bloque Think L1588-1670: cada 0.1s alla tiraba 16 humos +
// 16 glows POR FOTOGRAMA (a 60fps ~960/s de vida 0.05-0.6s = ~290
// vivos); aquí 10 Hz => 5 glows por latido (50/s) con vida 0.4-1.0s
// (~30 vivos) y tamanos un punto mayores = la misma lectura
// visual: masa densa azul-blanca alrededor del cuerpo que difumina los
// bordes y queda atras cuando el corredor se aleja (sprites SIN parent:
// cada puff vive donde nació — el air resistance 255 del GMod hace
// exactamente eso alla). v6.27: sin humos — quedan los GLOWS Color(125,
// 125,175) aditivos (las líneas de velocidad blancas-azuladas DENTRO del
// aura del video GMod) + 1 MOON por latido (abajo) + LAS ESFERITAS
// BLANCAS voladoras de Sonic_PeelTinyBall (la otra mitad del latido).
void Sonic_PeelCloudTick(int client)
{
    if (g_cvSonicTrails == null || !g_cvSonicTrails.BoolValue) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;

    // v6.28: PALANCA sonicom_peel_nube (EN VIVO — se aplica al latido
    // siguiente, sin reiniciar el peel): 1 = LA FALTA DEL HUMO la cubre
    // el BEAM NATIVO DEL SPEED (BeamFollow laserbeam 0.6s 10->1 fade 3
    // azul "125 185 255" desde el TORSO, el info_target +20z) y la
    // batería de sprites se APAGA; 0 = la batería (el intento denso de
    // abajo). Pedido literal del owner: "si en este cambio el humo sigue
    // sin salir ponme un comando que me permita que este cambie por el
    // Beam este nativo que usa el speed para complementar la falta
    // (necera desde el torso)".
    bool beamMode = (g_cvSonicPeelNube != null && g_cvSonicPeelNube.BoolValue);
    if (beamMode)
    {
        if (g_iSonicPeelNubeBeam[client] == 0 && g_iSonicPeelNubeBeamO[client] == 0)
            Sonic_PeelNubeBeamStart(client);
        return;   // batería apagada: el beam la reemplaza
    }
    if (g_iSonicPeelNubeBeam[client] != 0 || g_iSonicPeelNubeBeamO[client] != 0)
    {
        // el owner la regreso a 0 a mitad de la carrera: el beam muere
        Sonic_TEStop(g_iSonicPeelNubeBeam[client]);
        Sonic_TEStop(g_iSonicPeelNubeBeamO[client]);
    }

    float pos[3];
    GetClientAbsOrigin(client, pos);

    // forward horizontal del player (patron yaw del encadenado de pies)
    float ang[3];
    GetClientAbsAngles(client, ang);
    float rad = ang[1] * FLOAT_PI / 180.0;
    float fwd[3];
    fwd[0] = Cosine(rad);
    fwd[1] = Sine(rad);
    fwd[2] = 0.0;

    // emitter base: pos + 27z + fwd*10 (L1619/1621: +Vector(0,0,27)+fwd*10)
    float base[3];
    base[0] = pos[0] + fwd[0] * 10.0;
    base[1] = pos[1] + fwd[1] * 10.0;
    base[2] = pos[2] + 27.0;

    // v6.28: LA BATERÍA DENSA — reporte de la .20: "el único peo que
    // queda es el humo azulado que no se ve". El video GMod muestra una
    // masa translucida 2-3x el cuerpo que envuelve de la cintura para
    // abajo y derrama hacia atras (cian-blanco cerca del cuerpo ->
    // azul profundo en la cola). La .20 ponía 5 glows tenues de 26-36u
    // que en su video leian como trazas apenas visibles: la batería se
    // DOBLA (9 sprites por latido) y se agranda — la masa son HUMOS de
    // 45-62u y el nucleo brilla con glows de 34-46u. Edicts: ~90/s
    // con vida 0.35-0.75 (~50 vivos) + ~46 esferitas = ~96 sprites
    // por Sonic peelando (documentado; el .19 corrio 60+/s sin pestañar).

    // 5 HUMOS om_bluesmoke 45-62u AZUL PROFUNDO con sesgo ATRAS (la
    // "cape/wake" que envuelve espalda y piernas — la MASA del humo)
    bool smokeOK = (g_bSonicFxMatSmoke && g_iSonicFxMatSmoke > 0);
    for (int i = 0; i < 5; i++)
    {
        float p[3];
        float back = GetRandomFloat(8.0, 55.0);
        p[0] = base[0] - fwd[0] * back + GetRandomFloat(-30.0, 30.0);
        p[1] = base[1] - fwd[1] * back + GetRandomFloat(-30.0, 30.0);
        p[2] = pos[2] + GetRandomFloat(6.0, 28.0);
        Sonic_SpawnPeelPuff(p, smokeOK ? SONIC_FX_MAT_SMOKE : SONIC_SPRITE_GLOW,
                            GetRandomFloat(0.45, 0.62), "110 160 255",
                            GetRandomInt(130, 160), GetRandomFloat(0.45, 0.75), 0.24);
    }

    // 4 GLOWS cian-blanco 34-46u alrededor del cuerpo (el nucleo
    // brillante que en el video GMod se mezcla con las esferitas —
    // light_glow02_add Color(125,125,175) alla, aquí más claro)
    for (int i = 0; i < 4; i++)
    {
        float p[3];
        float back = GetRandomFloat(-12.0, 18.0);
        p[0] = base[0] - fwd[0] * back + GetRandomFloat(-32.0, 32.0);
        p[1] = base[1] - fwd[1] * back + GetRandomFloat(-32.0, 32.0);
        p[2] = pos[2] + GetRandomFloat(10.0, 32.0);
        Sonic_SpawnPeelPuff(p, SONIC_SPRITE_GLOW, GetRandomFloat(0.34, 0.46),
                            "170 210 255", GetRandomInt(150, 180),
                            GetRandomFloat(0.35, 0.60), 0.18);
    }

    // 1 MOON POR LATIDO (L1601-1607 + effects L256-322: sonic_peelout_
    // moons cada 0.1s EXACTOS = 1 por latido aquí; el efecto nace en
    // puppet+35z, espiral radio 20->30, se derrama HACIA ATRAS 0->80
    // contra la marcha y crece 16->112 en 0.5s). v6.25: nace EN el
    // cuerpo (no detrás — el v6.24 estático a -fwd*20-60 era las "aspas"):
    // arco chico 35-46u que SALTA a ~112u (input Scale a mitad de vida)
    // mientras el corredor ya lo abandono a 800 uu/s = lee como arco de
    // velocidad VOLANDO hacia atras como alla.
    if (g_iSonicFxMatMoon > 0 && g_bSonicFxMatMoon)
    {
        float p[3];
        p[0] = pos[0] + GetRandomFloat(-20.0, 20.0);
        p[1] = pos[1] + GetRandomFloat(-20.0, 20.0);
        p[2] = pos[2] + 35.0 + GetRandomFloat(-8.0, 8.0);
        Sonic_SpawnPeelPuff(p, SONIC_FX_MAT_MOON, GetRandomFloat(0.14, 0.18),
                            "255 255 255", 235, 0.5, 0.44);
    }
}

// ---------------------------------------------------------------------
// v6.27: LAS ESFERITAS BLANCAS — "nacen de Torso también y se dispersan
// aleatoriamente y CAMBIAN el humo blanco (lo dice el lua de Gmod)".
// Puerto del OM_tinyball_fleetway (om_noodles_effects_fleetway.lua
// L657-742): cada 0.1s el lua hacia 40 intentos x 1/6 de éxito (~6.7
// bolitas por tanda, ~67/s) — particulas de CLIENTE. Aquí: 2-3
// por latido 10 Hz (~25/s, ~46 vivos — alla cada una era gratis para el
// server, aquí es un edict; misma tasa visual: en pantalla GMod se ven
// 15-25 a la vez). Nacen DEL TORSO: pos+24z ±12u (el lua: bone "Torso"
// + Vector(rand(-10,10)) * 1.2 — el QC del owner confirma el bone
// Torso como la pieza del cuerpo, a la altura del attachment Trail +19z
// y del emitter +27z del Think).
// v6.28: CALIBRADAS AL VIDEO GMOD (reporte .20: "en el video de Gmod se
// ven un poco más florecentes con brillo"): (a) TEXTURA — alla el video
// muestra motas REDONDAS suaves cian-blanco #E0F0FF (el air resistance
// 40 del Lua les mata la velocidad y quedan PULSANDO en el torso; la
// estrella crema del fleetways leia amarillenta con destello en cruz):
// glow01 tintado "224 240 255" alpha 200 SIEMPRE (el .vtf/.vmt del
// fleetways quedan en el zip como referencia — cambiar de vuelta es 1
// línea en Sonic_SpawnPeelBall). (b) VELOCIDAD — el lua tira
// VectorRand()*Rand(30,80) pero su air resistance 40 la mata en ~0.1s
// (deriva real ~10-20u); el MOVETYPE_FLY no tiene fricción y a 30-80
// constantes se regaban 36-200u: 10-28 uu/s con sesgo +z = enjambre
// alrededor del torso que se queda vivo detrás (la firma del look).
// Vida 1.2-2.5s — de las más largas del suite.
// ---------------------------------------------------------------------
void Sonic_PeelTinyBall(int client)
{
    if (g_cvSonicTrails == null || !g_cvSonicTrails.BoolValue) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;

    float pos[3];
    GetClientAbsOrigin(client, pos);

    int n = GetRandomInt(2, 3);   // ~25/s: la tasa del lua recortada a edicts
    for (int i = 0; i < n; i++)
    {
        // nace DEL TORSO (pos + 24z ± 12u — bone "Torso" + rand(-10,10)*1.2)
        float p[3];
        p[0] = pos[0] + GetRandomFloat(-12.0, 12.0);
        p[1] = pos[1] + GetRandomFloat(-12.0, 12.0);
        p[2] = pos[2] + 24.0 + GetRandomFloat(-12.0, 12.0);

        // v6.28: VectorRand 30-80 -> 10-28 uu/s — en el GMod el air
        // resistance 40 del Lua MATA la velocidad enseguida (las motas
        // PULSAN en el sitio con deriva sutil, medido en su video); el
        // MOVETYPE_FLY no tiene fricción y a 30-80 constantes se regaban
        // por todo el pasillo. A 10-28 quedan como enjambre alrededor
        // del torso (deriva total ~12-70u en sus 1.2-2.5s de vida).
        float dir[3], vang[3];
        vang[0] = GetRandomFloat(-90.0, 90.0);
        vang[1] = GetRandomFloat(-180.0, 180.0);
        vang[2] = 0.0;
        GetAngleVectors(vang, dir, NULL_VECTOR, NULL_VECTOR);
        float spd = GetRandomFloat(10.0, 28.0);
        float vel[3];
        vel[0] = dir[0] * spd;
        vel[1] = dir[1] * spd;
        // sesgo +z: la gravedad (0,0,Rand(1,3)) del lua las lleva arriba
        vel[2] = dir[2] * spd * 0.6 + GetRandomFloat(4.0, 14.0);

        Sonic_SpawnPeelBall(p, vel, GetRandomFloat(1.2, 2.5));
    }
}

// v6.22: el POLVO GRIS de la CARGA — port del sonic_peeloutdust2_OM
// (L795-807 + effects L149-197: en cada paso de la animación de carga,
// 45 smokegrenades grises detrás, vida 1.2-2.5s, sesgo atras-ARRIBA).
// v6.25: VOLVER A LA BATERÍA — la v6.24 lo cambio por un env_steam que
// resulto invisible en el cliente L4D2 (el owner perdió el polvo de la
// carga junto con la niebla). Misma batería que SI se veía, más densa:
// 6 puffs cada 0.15s (40/s — alla 45 por paso a ~2-3 pasos/s), gris
// (180,180,180) alpha 105-140, nace 5-9u y SALTA x2.2 al 40% de vida
// (SetStartSize 3-6 -> SetEndSize 10-20 del lua L174-175), vida 1.2-1.9s,
// nace a los pies detrás con sesgo hacia ARRIBA (dir.z = abs*0.6 L161).
void Sonic_PeelChargeDust(int client, float now)
{
    if (g_cvSonicTrails == null || !g_cvSonicTrails.BoolValue) return;
    if (now < g_fSonicPeelDustNext[client]) return;
    g_fSonicPeelDustNext[client] = now + 0.15;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;

    float pos[3];
    GetClientAbsOrigin(client, pos);
    float ang[3];
    GetClientAbsAngles(client, ang);
    float rad = ang[1] * FLOAT_PI / 180.0;
    float fwd[3];
    fwd[0] = Cosine(rad);
    fwd[1] = Sine(rad);
    fwd[2] = 0.0;

    bool smokeOK = (g_bSonicFxMatSmoke && g_iSonicFxMatSmoke > 0);
    for (int i = 0; i < 6; i++)
    {
        float p[3];
        p[0] = pos[0] - fwd[0] * 15.0 + GetRandomFloat(-14.0, 14.0);
        p[1] = pos[1] - fwd[1] * 15.0 + GetRandomFloat(-14.0, 14.0);
        p[2] = pos[2] + 4.0 + GetRandomFloat(2.0, 26.0);
        float dScale = GetRandomFloat(0.05, 0.09);
        Sonic_SpawnPeelPuff(p, smokeOK ? SONIC_FX_MAT_SMOKE : SONIC_SPRITE_GLOW,
                            dScale, "180 180 180", GetRandomInt(105, 140),
                            GetRandomFloat(1.2, 1.9),
                            dScale * 2.2);
    }
}

// v6.22: FLASH BLANCO — el glow_duration_white del GMod (L1701 al
// apretar la tecla de carga, 0.5*0.4 = 0.2s; L1778 al soltar, 0.175s).
// Un glow01 blanco grande que vive `life` s en el personaje.
void Sonic_PeelFlash(int client, float life)
{
    if (g_cvSonicTrails == null || !g_cvSonicTrails.BoolValue) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 40.0;
    // v6.23: 1.6 -> 0.45 — el 1.6 eran 160u = media pantalla de glow
    // blanco (parte de la "nube gigante" de las capturas 04:50); alla
    // el flash es un glow del tamanio del cuerpo
    Sonic_SpawnPeelPuff(pos, SONIC_SPRITE_GLOW, 0.45, "255 255 255", 200, life);
}

// v6.3: oculta el avatar R+L SIN tocar nada más. Las entidades
// siguen vivas, parentadas y con su FSM de anim corriendo — cuando
// reaparezcan ya tienen la secuencia correcta puesta. RENDER_NONE =
// la misma técnica con la que se esconde el cuerpo del survivor.
void Sonic_HideAvatarForBall(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iSonicAvatar[client] != 0)
    {
        int av = EntRefToEntIndex(g_iSonicAvatar[client]);
        if (av > 0 && IsValidEntity(av))
            SetEntityRenderMode(av, RENDER_NONE);
    }
    if (g_iSonicAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iSonicAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
            SetEntityRenderMode(avL, RENDER_NONE);
    }
}

// v6.3: termina la bola — devolver la visibilidad del avatar. Caso
// normal: estuvo vivo-oculto TODO el roll -> solo mostrar + snap de
// smoothing (reaparece encajado, sin re-montar nada). Edge raro: el
// avatar murió a mitad de bola (mod externo / round) -> fallback al
// montaje SIN pulso (criterio v6.2), ahora respetando también el
// convar del avatar (el EndRoll del v6.2 montaba con sonicom_avatar
// en 0). Si la copia L se perdió en el camino, se repone SIN pulso.
void Sonic_ShowAvatarAfterBall(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;

    int av = (g_iSonicAvatar[client] != 0) ? EntRefToEntIndex(g_iSonicAvatar[client]) : -1;
    if (av > 0 && IsValidEntity(av))
    {
        // v6.6 (2b): restauración a PRUEBA DE BALAS — modo + color alpha
        // (un render color 0 también deja ciego al prop) + re-afirmado
        // 0.15s después (T_SonicBallRestore) + la FSM re-dispara la anim
        // del estado actual al reaparecer. Adios al "invisible hasta que
        // paro de correr".
        SetEntityRenderMode(av, RENDER_NORMAL);
        SetEntityRenderColor(av, 255, 255, 255, 255);
        if (g_iSonicAvatarL[client] != 0)
        {
            int avL = EntRefToEntIndex(g_iSonicAvatarL[client]);
            if (avL > 0 && IsValidEntity(avL))
            {
                SetEntityRenderMode(avL, RENDER_NORMAL);
                SetEntityRenderColor(avL, 255, 255, 255, 255);
            }
        }
        else
        {
            // copia L perdida a mitad de bola: reponerla (sin pulso —
            // esto NO es un montaje de ciclo de vida)
            Sonic_CreateAvatarL(client);
        }
        g_bSonicSmSnap[client] = true;   // reaparece encajado
        // FSM re-aplica la anim del estado (salvo si una esquiva esta
        // en pleno one-shot: esa GANA, v6.6 6)
        if (GetEngineTime() >= g_fSonicDodgeEnd[client])
            g_iSonicAnimState[client] = -1;
        CreateTimer(0.15, T_SonicBallRestore, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
        return;
    }

    if (g_cvSonicAvatar.BoolValue && g_bSonicModelOK)
        Sonic_CreateAvatar(client, false);
}

// v6.6 (2b): re-afirma la visibilidad del avatar un tick después de
// terminar la bola. Guardas: si en esos 0.15s empezó OTRA bola (homing
// re-lanzado, spindash encadenado), NO pisar su RENDER_NONE.
public Action T_SonicBallRestore(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return Plugin_Stop;
    if (g_iSonicSpinPhase[client] != SONIC_SPIN_NONE || g_iSonicBall[client] != 0) return Plugin_Stop;

    if (g_iSonicAvatar[client] != 0)
    {
        int av = EntRefToEntIndex(g_iSonicAvatar[client]);
        if (av > 0 && IsValidEntity(av))
        {
            SetEntityRenderMode(av, RENDER_NORMAL);
            SetEntityRenderColor(av, 255, 255, 255, 255);
        }
    }
    if (g_iSonicAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iSonicAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetEntityRenderMode(avL, RENDER_NORMAL);
            SetEntityRenderColor(avL, 255, 255, 255, 255);
        }
    }
    return Plugin_Stop;
}

void Sonic_KillBall(int client)
{
    // v6.6 (4): los trails mueren con la bola SIEMPRE (aunque el ref
    // de la bola ya se hubiera perdido)
    Sonic_KillBallTrails(client);
    if (g_iSonicBall[client] == 0) return;
    int av = EntRefToEntIndex(g_iSonicBall[client]);
    if (av > 0 && IsValidEntity(av))
        AcceptEntityInput(av, "Kill");
    g_iSonicBall[client] = 0;
}

// mata avatar R+L SIN restaurar el cuerpo (v6.3: queda para muerte/
// limpieza total — el swap a la bola ahora OCULTA en vez de matar)
void Sonic_KillAvatarOnly(int client)
{
    Sonic_KillAvatarL(client);
    if (g_iSonicAvatar[client] != 0)
    {
        int av = EntRefToEntIndex(g_iSonicAvatar[client]);
        if (av > 0 && IsValidEntity(av))
        {
            SDKUnhook(av, SDKHook_SetTransmit, Sonic_TransmitAvatarR);
            AcceptEntityInput(av, "Kill");
        }
        g_iSonicAvatar[client] = 0;
        g_bSonicSmSnap[client] = true;
    }
    g_iSonicAnimState[client] = -1;
}

void Sonic_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iSonicAvatarL[client] == 0) return;

    int avL = EntRefToEntIndex(g_iSonicAvatarL[client]);
    if (avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Sonic_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iSonicAvatarL[client] = 0;
}

void Sonic_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;

    Sonic_KillBall(client);
    Sonic_KillAvatarOnly(client);

    SDKUnhook(client, SDKHook_PostThink, Sonic_AvatarFollow);

    // restaurar el cuerpo SI seguimos siendo Sonic con render escondido
    if (IsClientInGame(client) && g_iSonicBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iSonicBodyRender[client]));
        g_iSonicBodyRender[client] = -1;
    }
    g_iSonicAnimState[client] = -1;
}

public Action Sonic_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iSonicAvatar[i] != 0 && EntRefToEntIndex(g_iSonicAvatar[i]) == entity)
        {
            if (client == i && g_iSonicAvatarL[i] != 0
                && EntRefToEntIndex(g_iSonicAvatarL[i]) > 0)
                return Plugin_Handled;   // el dueño tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

public Action Sonic_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iSonicAvatarL[i] != 0 && EntRefToEntIndex(g_iSonicAvatarL[i]) == entity)
        {
            if (client == i) return Plugin_Continue;   // el dueño si
            return Plugin_Handled;                     // nadie más
        }
    }
    return Plugin_Continue;
}

// =====================================================================
// FOLLOW PER-TICK (mismo sistema de lecciones Tails: yaw suave con
// deadband 3 grados, contra-rotación amortiguada, reloj vivo, copia L
// contra los eye angles del dueño + giro de la bola)
// =====================================================================
public void Sonic_AvatarFollow(int client)
{
    if (g_iSonicAvatar[client] == 0 && g_iSonicBall[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Sonic_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    // ---- yaw objetivo: dirección REAL del movimiento ----
    float yawObj = g_fSonicBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        // deadband 3 grados (v5.20.4: no perseguir el ruido de marcha)
        float dv = velYaw - g_fSonicBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    // ---- giro suave hacia el objetivo (~900 grados/s) ----
    float now = GetEngineTime();
    float dt  = now - g_fSonicYawLastT[client];
    g_fSonicYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fSonicBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fSonicBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bSonicSmSnap[client];
    GetClientAbsAngles(client, par);

    // ---- copia R (todos) o BOLA ----
    if (g_iSonicBall[client] != 0)
    {
        int ball = EntRefToEntIndex(g_iSonicBall[client]);
        if (ball > 0 && IsValidEntity(ball))
        {
            // el giro de la bola: rotación continua alrededor del eje
            // local X (el "ManipulateBoneAngles(0, CurTime*360*mult)"
            // de GMod traducido: el prop gira entero sobre si mismo)
            // v6.29: el acumulador es COMÚN a los dos modos (se consume
            // abajo como pitch de mundo en TP o pitch local en parentado)
            if (g_cvSonicBallSpin.BoolValue)
            {
                float mult = 1.0 + (GetEntityFlags(client) & FL_ONGROUND ? 2.0 : 1.0);
                g_fSonicBallSpin[client] += 1080.0 * mult * dt;   // ~3-9 rev/s
                if (g_fSonicBallSpin[client] > 360.0) g_fSonicBallSpin[client] -= 360.0 * RoundToFloor(g_fSonicBallSpin[client] / 360.0);
            }

            if (Tails_AvatarTPOn())
            {
                // v6.29: LA BOLA VIAJA POR TP EN MODO TP — la receta de la
                // R humana aplicada a la bola: TeleportEntity por tick +
                // reloj vivo, SIN EF_NOINTERP = todos los clientes la
                // INTERPOLAN suave (el puppet de GMod se mueve igual: por
                // red, para todos). Angulos de MUNDO directos: pitch = el
                // spin (rueda hacia delante), yaw = bodyYaw (la dirección
                // REAL del movimiento). La orientación sigue al rumbo POR
                // CONSTRUCCION — cero composición con los angulos de vista
                // del parent (el bug del owner: "cuando el jugador cambia
                // de dirección la bola no cambia su orientación, el cuerpo
                // si"). El offset del parent es puro +Z: rotación-
                // independiente, mismo valor en mundo que en local.
                float posB[3], angB[3];
                GetClientAbsOrigin(client, posB);
                posB[2] += (g_cvSonicBallZ != null) ? g_cvSonicBallZ.FloatValue : 15.0;
                angB[0] = g_cvSonicBallSpin.BoolValue ? g_fSonicBallSpin[client] : 0.0;
                angB[1] = g_fSonicBodyYaw[client];
                angB[2] = 0.0;
                TeleportEntity(ball, posB, angB, NULL_VECTOR);
                Tails_MarkInterp(ball);
            }
            else
            {
                // parentado (modo default tp 0): contra-rotación local
                // contra los angulos del parent, como siempre
                Tails_AvatarLocalAngles(par[0], par[1], g_fSonicBodyYaw[client], loc);
                loc[1] = Tails_UnwrapYaw(g_fSonicSmLoc[client][1], loc[1]);
                if (g_cvSonicBallSpin.BoolValue)
                    loc[0] += g_fSonicBallSpin[client];
                Tails_ExpDamp(loc, g_fSonicSmLoc[client], 0.0, dt, snap);  // bola: write seco (es una esfera)
                if (HasEntProp(ball, Prop_Send, "m_angRotation"))
                    SetEntPropVector(ball, Prop_Send, "m_angRotation", g_fSonicSmLoc[client]);
                Tails_MarkInterp(ball);
            }
        }

        // v6.15: la R OCULTA viaja pegada por TP durante la bola (la
        // parentada se movía sola con el survivor; la TP hay que
        // moverla aquí) para reaparecer EN SU SITIO al terminar la
        // bola — no a 2000u atras del frenado
        if (Tails_AvatarTPOn() && g_iSonicAvatar[client] != 0)
        {
            int avH = EntRefToEntIndex(g_iSonicAvatar[client]);
            if (avH > 0 && IsValidEntity(avH))
            {
                float posH[3], angH[3];
                GetClientAbsOrigin(client, posH);
                angH[0] = 0.0;                      // pitch NUNCA
                angH[1] = g_fSonicBodyYaw[client];
                angH[2] = 0.0;                      // roll NUNCA
                TeleportEntity(avH, posH, angH, NULL_VECTOR);
                Tails_MarkInterp(avH);
            }
        }
    }
    else
    {
        int av = EntRefToEntIndex(g_iSonicAvatar[client]);
        if (av > 0 && IsValidEntity(av))
        {
            if (Tails_AvatarTPOn())
            {
                // v6.15: LA COPIA R VIAJA POR TP (receta tails_follow de
                // Tails v5.25): TeleportEntity por tick en pose mundo
                // (pos + yaw del cuerpo) + reloj vivo, SIN EF_NOINTERP
                // -> los clientes de los demas la INTERPOLAN = suave sin
                // depender de la pausa. El dueño no la recibe (su L
                // parentada se la filtra por transmit).
                float posTP[3], angTP[3];
                GetClientAbsOrigin(client, posTP);
                angTP[0] = 0.0;                      // pitch NUNCA
                angTP[1] = g_fSonicBodyYaw[client];
                angTP[2] = 0.0;                      // roll NUNCA
                TeleportEntity(av, posTP, angTP, NULL_VECTOR);
                Tails_MarkInterp(av);
            }
            else
            {
            Tails_AvatarLocalAngles(par[0], par[1], g_fSonicBodyYaw[client], loc);
            loc[1] = Tails_UnwrapYaw(g_fSonicSmLoc[client][1], loc[1]);
            // amortiguación fija 0.05 (default tails_angdamp: rampa ~3 ticks)
            Tails_ExpDamp(loc, g_fSonicSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fSonicSmLoc[client]);
            Tails_MarkInterp(av);
            }
        }

        // ---- copia L: contra-rotada contra los EYE del dueño ----
        if (g_iSonicAvatarL[client] != 0)
        {
            int avL = EntRefToEntIndex(g_iSonicAvatarL[client]);
            if (avL > 0 && IsValidEntity(avL))
            {
                float eye[3], locL[3];
                GetClientEyeAngles(client, eye);
                Tails_AvatarLocalAngles(eye[0], eye[1], g_fSonicBodyYaw[client], locL);
                locL[1] = Tails_UnwrapYaw(g_fSonicSmLocL[client][1], locL[1]);
                Tails_ExpDamp(locL, g_fSonicSmLocL[client], 0.05, dt, snap);
                if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                    SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fSonicSmLocL[client]);
                Tails_MarkInterp(avL);
            }
        }
    }
    g_bSonicSmSnap[client] = false;
}

// =====================================================================
// FSM 10 HZ: lógica de fases SIEMPRE (aunque el avatar este apagado o
// falte el modelo — las habilidades NO dependen del visual) +
// auto-reparación del avatar (patron T_TailsAvatarThink: si un spawn
// se pierde o llega en mal orden, el think re-monta en <=0.1s)
// =====================================================================
public Action T_SonicAvatarThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Sonic_KillAvatar(i); continue; }

        bool esSonicVivo = (g_iPlayerCharIdx[i] == SONIC_INDEX
                            && IsPlayerAlive(i) && GetClientTeam(i) == 2);

        // ---- LÓGICA DE FASES: corre SIEMPRE que sea Sonic vivo ----
        // (sin avatar igual: spindash/peel/anillos no dependen del visual)
        if (esSonicVivo)
        {
            Sonic_OM_PhaseThink(i, now);
        }
        else if (g_iSonicSpinPhase[i] != SONIC_SPIN_NONE
                 || g_iSonicPeelPhase[i] != 0)
        {
            // cayó muerto/cambio de personaje con fase abierta
            Sonic_OM_Cancel(i);
        }

        // ---- AVATAR: montaje / auto-reparación ----
        if (g_iSonicAvatar[i] == 0 && g_iSonicBall[i] == 0)
        {
            if (esSonicVivo && g_cvSonicAvatar.BoolValue && g_bSonicModelOK)
            {
                // en fase de bola la monta la propia fase; aquí solo humano
                if (g_iSonicSpinPhase[i] == SONIC_SPIN_NONE
                    || g_iSonicSpinPhase[i] == SONIC_SPIN_DIVE)
                    Sonic_CreateAvatar(i);
            }
            continue;
        }

        // quitar avatar/bola si dejó de ser un Sonic survivor vivo
        if (!esSonicVivo)
        {
            Sonic_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iSonicAvatar[i]);
        if ((g_iSonicAvatar[i] != 0) && (av <= 0 || !IsValidEntity(av)))
        {
            g_iSonicAvatar[i] = 0;
            g_iSonicAnimState[i] = -1;
        }
        int ball = EntRefToEntIndex(g_iSonicBall[i]);
        if ((g_iSonicBall[i] != 0) && (ball <= 0 || !IsValidEntity(ball)))
            g_iSonicBall[i] = 0;
        if (g_iSonicAvatar[i] == 0 && g_iSonicBall[i] == 0) continue;

        // reafirmar el RENDER_NONE del cuerpo (el motor lo resetea al
        // cambiar de capítulo/incap/rescue: v5.4 fix Tails)
        if (g_iSonicBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparación de la copia L. v6.3: JAMÁS en pleno ROLL —
        // el avatar R sigue vivo-oculto toda la bola y su L también;
        // montarla aquí mostraría un Sonic parado junto a la bola Y
        // dispararía el pulso de pausa en combate. (Si la L se perdió
        // a mitad de bola, la repone ShowAvatarAfterBall al terminar.)
        if (g_iSonicAvatarL[i] == 0 && g_iSonicAvatar[i] != 0
            && g_iSonicSpinPhase[i] != SONIC_SPIN_ROLL)
        {
            Sonic_CreateAvatarL(i);
            if (g_iSonicAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);   // montaje tardio: pulso también
        }

        // ---- FSM de animación ----
        av = EntRefToEntIndex(g_iSonicAvatar[i]);
        if (g_iSonicAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Sonic_AvatarUpdate(i, av, now);
    }
    return Plugin_Continue;
}

// =====================================================================
// FSM DE ANIMACION (prioridades GMod ShouldAlternate + lecciones Tails)
// =====================================================================
void Sonic_AvatarUpdate(int client, int av, float now)
{
    if (now < g_fSonicAnimLock[client])
    {
        // v6.29: DODGE = one-shot PRIORITARIO A COMPLETAR (orden del
        // owner: "debería ser una animación prioritaria por encima de
        // cualquier otra... debe concretar hasta que la animación
        // acabe"). Mientras la secuencia DodgeX siga viva en el modelo
        // (m_flCycle < 0.95 — el mismo patron del jump) y no se haya
        // venido el tope duro, el lock se ESTIRA tick a tick: la eva
        // corre ENTERA aunque dure más de los 0.5s del lock viejo, y
        // ningún estado (run/walk/peel/dive) la vuelve a pisar. Si
        // algo le piso la secuencia a la copia R (motor, timing),
        // SELF-HEAL: se re-dispara en el acto (R + L) y sigue. Al
        // acabar de verdad: se suelta YA el lock y la FSM cae derecha
        // a reevaluar (vuelve a run/peelout/lo que toque).
        if (g_iSonicAnimState[client] >= SONIC_ST_DODGE
            && g_iSonicAnimState[client] < SONIC_ANIM_COUNT
            && now < g_fSonicDodgeCap[client])
        {
            if (!Sonic_DodgeAnimDone(av))
            {
                if (Sonic_DodgeStomped(client, av))
                    Sonic_RefireDodge(client, av);
                g_fSonicAnimLock[client] = now + 0.15;   // estirar el lock un latido más
                return;
            }
            // la anim acabo de verdad: liberar YA (no esperar el 0.5
            // justo del lock) y dejar pasar a la reevaluación
            g_fSonicDodgeEnd[client]   = 0.0;
            g_fSonicAnimLock[client]   = 0.0;
            g_iSonicDodgeSeq[client]   = -1;
        }
        else return;   // otro one-shot (Braking/jump-window): como siempre
    }

    int state = 0;
    float rate = 1.0;

    bool incap  = GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0;
    bool lowhp  = GetClientHealth(client) <= 60;   // GMod: LowestHealthCount <= 60

    if (incap)
    {
        state = (Sonic_Speed2D(client) > 20.0) ? 12 : 11;   // DownedWalk/Idle
    }
    // v6.6 (6): LA EVASION GANA SOBRE TODO lo demas (caminar, salto,
    // quieto, e incluso la carrera del peel — antes las ramas de peel/
    // dive/windup le pisaban el one-shot y el owner no la veía llegar)
    else if (now < g_fSonicDodgeEnd[client]
             && g_iSonicAnimState[client] >= SONIC_ST_DODGE)
    {
        state = g_iSonicAnimState[client];   // ya está en DodgeX (lock)
        rate = 1.4;
    }
    else if (g_iSonicPeelPhase[client] == 1)                    // cargando peel
    {
        state = SONIC_ST_PEELSTART;
        // v6.6 (3): la carga ACELERA MUCHO más — arranca lenta (0.45x)
        // y despega hasta 3.4x al completarse (antes terminaba en
        // 1.6x). Sonic CD: lento -> acelera -> rapidisimo -> suelta.
        float total = g_cvSonicPeelCharge.FloatValue;
        float left  = g_fSonicPeelChargeEnd[client] - now;
        if (total <= 0.05) total = 0.05;
        float frac = left / total;              // 1 = recien empezó
        if (frac < 0.0) frac = 0.0;
        if (frac > 1.0) frac = 1.0;
        rate = 0.45 + (1.0 - frac) * 2.95;      // 0.45 -> 3.40
        if (rate > 3.4) rate = 3.4;

        // v6.5 (E): la anim de carga LOOPEA hasta soltar — PeelOutStart
        // es one-shot en el modelo, así que al llegar al final del
        // ciclo se re-dispara (R y L), como el charge de Sonic CD
        if (g_iSonicAnimState[client] == SONIC_ST_PEELSTART
            && Sonic_PeelChargeLooped(av))
        {
            SetVariantString(g_sSonicAnimSeq[SONIC_ST_PEELSTART]);
            AcceptEntityInput(av, "SetAnimation");
            if (g_iSonicAvatarL[client] != 0)
            {
                int avLP = EntRefToEntIndex(g_iSonicAvatarL[client]);
                if (avLP > 0 && IsValidEntity(avLP))
                {
                    SetVariantString(g_sSonicAnimSeq[SONIC_ST_PEELSTART]);
                    AcceptEntityInput(avLP, "SetAnimation");
                }
            }
        }
    }
    else if (g_iSonicPeelPhase[client] == 2)                    // carrera peel
    {
        state = SONIC_ST_PEELRUN;
        rate = 1.25;
    }
    else if (g_iSonicPeelPhase[client] == 3)                    // frenando
    {
        state = SONIC_ST_BRAKING;
    }
    else if (g_iSonicSpinPhase[client] == SONIC_SPIN_DIVE)      // picoada dropdash
    {
        state = SONIC_ST_DIVE;
        rate = 0.5;      // GMod animrates fall en dive: 0.5
    }
    else if (g_iSonicSpinPhase[client] == SONIC_SPIN_WINDUP)    // windup de la bola
    {
        state = SONIC_ST_SPINDASH;   // la secuencia Spindash del modelo
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // AIRE (v5.22 Tails: el aire le gana al LowHealth)
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[2] > 40.0)
        {
            state = SONIC_ST_JUMP;
        }
        else
        {
            // ventana del jump completa en el aire (fix Poppy)
            bool jumpLive = false;
            if (g_iSonicAnimState[client] == SONIC_ST_JUMP)
            {
                float jt = now - g_fSonicJumpStart[client];
                if (jt < 0.5)      jumpLive = true;
                else if (jt < 1.5 && !Sonic_JumpAnimDone(av))
                    jumpLive = true;
            }
            state = jumpLive ? SONIC_ST_JUMP : 4;   // fall
        }
    }
    else if (lowhp)
    {
        // LowHealth = variante de SUELO (GMod walk_lowhealth etc.)
        float s = Sonic_Speed2D(client);
        if (s < 40.0)       state = 13;
        else if (s < 150.0) state = 14;
        else                state = 15;
    }
    else
    {
        float s = Sonic_Speed2D(client);
        if (s < 40.0)
            state = 0;
        else if (s < 150.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = 1;
            rate = 1.8 * (s / 85.0);
            if (rate > 2.5) rate = 2.5;
        }
        else
        {
            state = 2;
            rate = 1.32 * (s / 450.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6) rate = 3.6;
        }
    }

    if (state != g_iSonicAnimState[client])
    {
        if (state == SONIC_ST_JUMP) g_fSonicJumpStart[client] = now;
        if (state >= SONIC_ST_DODGE) g_fSonicAnimLock[client] = now + 0.5;   // Dodge one-shot
        if (state == SONIC_ST_BRAKING) g_fSonicAnimLock[client] = now + 0.5; // Braking one-shot
        SetVariantString(g_sSonicAnimSeq[state]);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iSonicAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iSonicAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                // v5.20.1 Tails: el variant es de UN SOLO USO — re-armarlo
                SetVariantString(g_sSonicAnimSeq[state]);
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iSonicAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iSonicAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iSonicAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

bool Sonic_JumpAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return true;
}

// =====================================================================
// v6.29: LA EVASION A COMPLETAR — helpers del one-shot prioritario.
// El modelo no trae LookupSequence (SM 1.11), así que el índice real
// de la secuencia DodgeX se APRENDE por readback justo después del
// SetAnimation (la misma sonda del resolvedor de anims de Amy v91):
// m_nSequence queda en el prop y es lo que el server compara en cada
// latido para el self-heal.
// =====================================================================

// true si la secuencia DodgeX ya termino en el prop (mismo patron que
// Sonic_JumpAnimDone; el cycle lo avanza el server en prop_dynamic)
bool Sonic_DodgeAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return true;
}

// índice m_nSequence actual del prop (-1 = no legible)
int Sonic_PropSequence(int prop)
{
    if (prop <= 0 || !IsValidEntity(prop)) return -1;
    if (HasEntProp(prop, Prop_Send, "m_nSequence"))
        return GetEntProp(prop, Prop_Send, "m_nSequence");
    if (HasEntProp(prop, Prop_Data, "m_nSequence"))
        return GetEntProp(prop, Prop_Data, "m_nSequence");
    return -1;
}

// la copia R sigue en la secuencia del dodge? (false = la pisaron)
bool Sonic_DodgeStomped(int client, int av)
{
    int want = g_iSonicDodgeSeq[client];
    if (want < 0) return false;      // no aprendimos el índice: no juzgar
    int cur = Sonic_PropSequence(av);
    if (cur < 0) return false;       // ilegible: no juzgar
    return cur != want;
}

// re-dispara la DodgeX activa en R + L (self-heal; el variant se
// re-arma por prop — lección v5.20.1 Tails: es de UN SOLO USO)
void Sonic_RefireDodge(int client, int av)
{
    int st = g_iSonicAnimState[client];
    if (st < SONIC_ST_DODGE || st >= SONIC_ANIM_COUNT) return;

    if (av > 0 && IsValidEntity(av))
    {
        SetVariantString(g_sSonicAnimSeq[st]);
        AcceptEntityInput(av, "SetAnimation");
        if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", 1.4);
    }
    if (g_iSonicAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iSonicAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetVariantString(g_sSonicAnimSeq[st]);
            AcceptEntityInput(avL, "SetAnimation");
            if (HasEntProp(avL, Prop_Data, "m_flPlaybackRate"))
                SetEntPropFloat(avL, Prop_Data, "m_flPlaybackRate", 1.4);
        }
    }
}

// v6.5 (E): true si la anim de carga del peel completo su ciclo — se
// usa para RELANZARLA y que la carga loopee hasta soltar (Sonic CD).
bool Sonic_PeelChargeLooped(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return false;
    if (!HasEntProp(av, Prop_Data, "m_flCycle")) return false;
    return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.92;
}

float Sonic_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// =====================================================================
// HABILIDADES OM: SPINDASH / DROPDASH (Z) + PEEL OUT (X)
// =====================================================================

// Cancel total de las fases OM (muerte / cambio de personaje / reset)
void Sonic_OM_Cancel(int client)
{
    bool hadBall = (g_iSonicSpinPhase[client] == SONIC_SPIN_ROLL);
    g_iSonicSpinPhase[client] = SONIC_SPIN_NONE;
    g_iSonicPeelPhase[client] = 0;
    g_fSonicDodgeEnd[client] = 0.0;
    g_fSonicAnimLock[client] = 0.0;
    g_iSonicDodgeSeq[client] = -1;     // v6.29: eva a completar fuera
    g_fSonicDodgeCap[client] = 0.0;
    // v6.4: si estaba pegado a la cara (golpe final a mitad), se suelta —
    // la victima conserva su stun, pero no hay lanzamiento ni ragdoll
    g_bSonicSpinFinalPending[client] = false;
    g_iSonicSpinLockVictim[client] = 0;
    g_fSonicSpinLockUntil[client] = 0.0;
    // v6.6: fuera el trail del peel y la gracia DoT si quedaba viva
    Sonic_KillPeelTrail(client);
    g_fSonicDotGraceUntil[client] = 0.0;
    Speed_StackSet(client, 1, 0.0);
    if (hadBall)
    {
        Sonic_KillBall(client);
        // v6.3: devolver la visibilidad del avatar (oculto desde el
        // StartRoll). Cero re-montaje y cero pulso — cancelar un roll
        // por stun/incap/muerte en pleno combate ya no toca el sistema
        // de pausa. (En muerte se autocalcela: guarda IsPlayerAlive
        // adentro, y Event_PlayerDeath mata el avatar justo después.)
        Sonic_ShowAvatarAfterBall(client);
    }
    // cortar loops de sonido que pudieran quedar vivos
    StopSound(client, SNDCHAN_AUTO, SONIC_SND_SPIN_LOOP);
    StopSound(client, SNDCHAN_AUTO, SONIC_SND_SPIN_CHARGE);
}

bool Sonic_OM_BusyLocked(int client)
{
    // bloqueos GMod: stun/incap/agarres cancelan TODO (CustomFunctionForDowned_OM)
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return true;
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return true;
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) return true;
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return true;
    if (GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0) return true;
    if (GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0) return true;
    if (g_bSonicHoming[client]) return true;   // volando con homing
    return false;
}

// v6.6 (9): ¿este agarre va a QUEDAR? Para el CICLO DE FASES (bola/
// peel) un agarre solo corta la fase si es real: la eva lo rompe en
// el PreThink (bola/gracia gratis, anillos de la tabla) — la fase ya
// no se cancela por un agarre que será esquivado en el próximo tick.
bool Sonic_OM_GrabSticks(int client)
{
    int tongue = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
    int pounce = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
    int jockey = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
    int carry  = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
    if (tongue <= 0 && pounce <= 0 && jockey <= 0 && carry <= 0) return false;

    // en bola o en gracia el PreThink lo ROMPE gratis
    if (Sonic_SpinGuardActive(client)) return false;
    if (Sonic_DodgeGraceActive(client)) return false;

    // con anillos suficientes: paga la tabla y también se rompe
    if (g_cvSonicDodge != null && g_cvSonicDodge.BoolValue)
    {
        int cost = g_cvSonicDodgeTongue.IntValue;
        if (pounce > 0) cost = g_cvSonicDodgeHunter.IntValue;
        else if (jockey > 0) cost = g_cvSonicDodgeJockey.IntValue;
        else if (carry > 0) cost = g_cvSonicDodgeCharger.IntValue;
        if (cost > 0 && g_iSonicRings[client] >= cost) return false;
    }
    return true;   // agarre que pega de verdad (sin anillos)
}

// el BusyLocked de las FASES: incap/pummel/homing SIEMPRE; agarres
// solo si van a quedar (v6.6)
bool Sonic_OM_BusyLockedSerious(int client)
{
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return true;
    if (GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0) return true;
    if (g_bSonicHoming[client]) return true;      // volando con homing
    return Sonic_OM_GrabSticks(client);
}

// Z: SPINDASH en suelo / DROPDASH en el aire / COMBO desde el peel
public void Sonic_OM_Spindash(int client)
{
    // v3.77.79: el host de modo solo es un cliente fake — dejarlo pasar
    if (!Sonic_IsValidClient(client) || !IsPlayerAlive(client) || (IsFakeClient(client) && !Sonic_IsSoloHost(client))) return;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;

    // fase en curso: no re-disparar (GMod: guards de Spindash_Duration_C)
    if (g_iSonicSpinPhase[client] != SONIC_SPIN_NONE) return;
    if (Sonic_OM_BusyLocked(client)) return;
    if (g_iSonicPeelPhase[client] == 1) return;   // cargando el peel

    float now = GetEngineTime();

    // cooldown (GMod: se chequea ANTES de todo, incluida la conversión
    // del peel — el combo también respeta el CD de la bola)
    if (now < g_fSonicSpinCD[client])
    {
        PrintCenterText(client, "Spindash recargando... (%.0fs)", g_fSonicSpinCD[client] - now);
        return;
    }

    // COMBO GMod (DropdashPeelout_useable): Z durante la CARRERA del
    // peel convierte el tiempo restante en ROLL (Spindash_Duration =
    // PeelOut_duration restante)
    if (g_iSonicPeelPhase[client] == 2)
    {
        float left = g_fSonicPeelRunEnd[client] - now;
        if (left < 0.3) left = 0.3;
        g_iSonicPeelPhase[client] = 0;               // el peel termina AQUÍ
        // v6.24: BUGFIX — este camino ponía fase 0 SIN matar las
        // entidades del trail: beams + luz (y ahora las nieblas)
        // quedaban VIVOS PARA SIEMPRE hasta morir/cambiar. (En GMod el
        // trail sigue un rato tras el combo; aquí muere en el momento —
        // desviación documentada a cambio de no filtrar entidades.)
        Sonic_KillPeelTrail(client);
        g_iSonicSpinPhase[client] = SONIC_SPIN_ROLL; // directo a la bola
        g_fSonicSpinUntil[client] = now + left;
        g_iSonicSpinHits[client] = 0;
        g_bSonicSpinFinalized[client] = false;
        g_fSonicSpinLoopSnd[client] = 0.0;
        Sonic_StartRoll(client);
        PrintCenterText(client, "[!] COMBO: PEEL -> SPIN!");
        return;
    }

    bool onGround = (GetEntityFlags(client) & FL_ONGROUND) != 0;

    if (onGround)
    {
        // ================= SPINDASH (suelo) =================
        // GMod: brinco de arranque + windup 0.65s congelado en bola
        g_iSonicSpinPhase[client] = SONIC_SPIN_WINDUP;
        g_fSonicSpinWindEnd[client] = now + 0.65;
        g_iSonicSpinHits[client] = 0;
        g_bSonicSpinFinalized[client] = false;

        // el brinco de arranque (GMod: SetPos +5 y vel z 270)
        float hop[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", hop);
        hop[2] = 270.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, hop);

        EmitSoundToAll(SONIC_SND_SPIN_CHARGE, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
        PrintCenterText(client, "[*] SPINDASH...");
    }
    else
    {
        // ================= DROPDASH (aire) =================
        // GMod: DropDash_Diving_alt: picoada con el aire deshabilitado
        g_iSonicSpinPhase[client] = SONIC_SPIN_DIVE;
        g_iSonicSpinHits[client] = 0;
        g_bSonicSpinFinalized[client] = false;

        float dive[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", dive);
        dive[0] *= 0.35;
        dive[1] *= 0.35;
        dive[2] = -700.0;                       // picoada
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, dive);

        // el dano de caida fantasma no cuenta (inmunidad v5.4 + dive)
        Sonic_ResetFallVelocity(client);

        EmitSoundToAll(SONIC_SND_SPIN_CHARGE, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
        PrintCenterText(client, "[v] DROPDASH!");
    }
}

// Monta la BOLA y engancha la velocidad del stack
void Sonic_StartRoll(int client)
{
    Sonic_CreateBall(client);
    float base = Speed_GetBaseSpeed(client);
    if (base < 50.0) base = 220.0;
    float extra = (g_cvSonicSpinSpeed.FloatValue * 1.05) / base - 1.0;
    Speed_StackSet(client, 1, extra);
    if (g_fSonicSpinLoopSnd[client] < GetEngineTime())
    {
        EmitSoundToAll(SONIC_SND_SPIN_LOOP, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
        g_fSonicSpinLoopSnd[client] = GetEngineTime() + 1.9;   // WAV ~2s
    }
}

// Termina la bola: CD según como termino
void Sonic_EndRoll(int client, bool finalHit)
{
    float now = GetEngineTime();
    float cd = finalHit ? g_cvSonicSpinCDFinal.FloatValue : g_cvSonicSpinCD.FloatValue;
    g_fSonicSpinCD[client] = now + cd;
    g_fSonicSpinCDDur[client] = cd;

    g_iSonicSpinPhase[client] = SONIC_SPIN_NONE;
    Speed_StackSet(client, 1, 0.0);
    Sonic_KillBall(client);
    StopSound(client, SNDCHAN_AUTO, SONIC_SND_SPIN_LOOP);

    // v6.4: si la duración de la bola corto un final a mitad del pegado,
    // soltar el estado (la victima conserva su stun, sin lanzamiento)
    g_bSonicSpinFinalPending[client] = false;
    g_iSonicSpinLockVictim[client] = 0;
    g_fSonicSpinLockUntil[client] = 0.0;

    EmitSoundToAll(SONIC_SND_RELEASE, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // v6.3 (diseño del dueño): NO se re-monta nada. El avatar siguio
    // VIVO (oculto con RENDER_NONE) durante TODA la bola — solo se le
    // devuelve la visibilidad + snap de smoothing. Se acabo el "como
    // si hicieramos sc" al terminar cada spindash: cero re-montajes,
    // cero pulsos de pausa, cero riesgo de avatar torcido; y Sonic
    // reaparece ya en posición con la anim que le toca (su FSM de
    // anim le siguio corriendo mientras estuvo oculto).
    Sonic_ShowAvatarAfterBall(client);
}

// X: PEEL OUT (carga -> carrera supervesa -> frenado)
public void Sonic_OM_PeelOut(int client)
{
    // v3.77.79: el host de modo solo es un cliente fake — dejarlo pasar
    if (!Sonic_IsValidClient(client) || !IsPlayerAlive(client) || (IsFakeClient(client) && !Sonic_IsSoloHost(client))) return;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;

    if (g_iSonicPeelPhase[client] != 0) return;          // ya en ello
    if (g_iSonicSpinPhase[client] != SONIC_SPIN_NONE) return;   // en bola no
    if (Sonic_OM_BusyLocked(client)) return;

    float now = GetEngineTime();
    if (now < g_fSonicPeelCD[client])
    {
        PrintCenterText(client, "Peel Out recargando... (%.0fs)", g_fSonicPeelCD[client] - now);
        return;
    }

    g_iSonicPeelPhase[client] = 1;   // cargando
    g_fSonicPeelChargeEnd[client] = now + g_cvSonicPeelCharge.FloatValue;
    g_bSonicPeelSaidOut[client] = false;
    g_iSonicPeelRescues[client] = 0;

    // GMod: solo de pie en el suelo (el brinco está bloqueado por la carga)
    if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[2] > 0.0) vel[2] = 0.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    }

    EmitSoundToAll(SONIC_SND_SPIN_CHARGE, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    // v6.5 (E): la FSM re-emite la carga en loop hasta que suelte
    g_fSonicPeelLoopSnd[client] = now + 1.9;
    // v6.22: flash blanco de arranque (glow_duration_white L1701) +
    // reset del gate del polvo de la carga
    Sonic_PeelFlash(client, 0.25);
    g_fSonicPeelDustNext[client] = 0.0;
    // v6.25: el POLVO GRIS de la carga es la BATERÍA de la FSM case 1
    // (Sonic_PeelChargeDust — 6 puffs/0.15s, mecanismo que SI dibuja);
    // el env_steam gris de la v6.24 FUE ELIMINADO (no renderiza en el
    // cliente L4D2: el owner perdió el polvo junto con la niebla).
    PrintCenterText(client, "[>>] PEEL OUT: cargando...");
}

// La carrera arranca (la invoca la FSM al terminar la carga)
void Sonic_PeelRunStart(int client)
{
    float now = GetEngineTime();
    g_iSonicPeelPhase[client] = 2;
    g_fSonicPeelRunEnd[client] = now + g_cvSonicPeelDuration.FloatValue;
    g_fSonicPeelLoopSnd[client] = 0.0;

    float base = Speed_GetBaseSpeed(client);
    if (base < 50.0) base = 220.0;
    float extra = (g_cvSonicPeelSpeed.FloatValue * 1.05) / base - 1.0;
    Speed_StackSet(client, 1, extra);

    // v6.6 (1): la carga muere AQUÍ (su loop no se arrastra a la
    // carrera) — y la carrera suena SOLO a PeelOutStart (+ trail 4)
    StopSound(client, SNDCHAN_AUTO, SONIC_SND_SPIN_CHARGE);
    EmitSoundToAll(SONIC_SND_PEEL_START, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // v6.6 (4): el trail azul de la carrera (el trailPeel del GMod)
    Sonic_CreatePeelTrail(client);

    // v6.22: flash blanco del release (glow_duration_white L1778)
    Sonic_PeelFlash(client, 0.2);

    PrintCenterText(client, "[>>>] PEEL OUT!");
}

// Termina la carrera: frenado + CD según rescates (GMod success/fail)
void Sonic_PeelRunEnd(int client)
{
    float now = GetEngineTime();
    g_iSonicPeelPhase[client] = 3;   // frenando (Braking)
    g_fSonicPeelBrakeEnd[client] = now + 0.5;

    Speed_StackSet(client, 1, 0.0);
    StopSound(client, SNDCHAN_AUTO, SONIC_SND_SPIN_LOOP);
    Sonic_KillPeelTrail(client);    // v6.6 (4): el trail muere con la carrera

    float cd = (g_iSonicPeelRescues[client] > 0)
             ? g_cvSonicPeelCDRescue.FloatValue
             : g_cvSonicPeelCDFail.FloatValue;
    g_fSonicPeelCD[client] = now + cd;
    g_fSonicPeelCDDur[client] = cd;

    EmitSoundToAll(SONIC_SND_BRAKE, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // frenada real: corta el momentum horizontal
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    vel[0] *= 0.25;
    vel[1] *= 0.25;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    // v6.14: fin del viaje — desembarco de los pasajeros (con su
    // pasito: 30% de la velocidad ya frenada + saltito)
    Sonic_PeelCarryDropAll(client, true);
}

// =====================================================================
// LÓGICA DE FASES (10 Hz, desde T_SonicAvatarThink)
// =====================================================================
void Sonic_OM_PhaseThink(int client, float now)
{
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;

    // ---- SPIN ----
    switch (g_iSonicSpinPhase[client])
    {
        case SONIC_SPIN_WINDUP:
        {
            if (now >= g_fSonicSpinWindEnd[client])
            {
                // windup cumplido: fuera bola
                g_iSonicSpinPhase[client] = SONIC_SPIN_ROLL;
                g_fSonicSpinUntil[client] = now + g_cvSonicSpinDuration.FloatValue;
                g_fSonicSpinLastHit[client] = 0.0;
                Sonic_StartRoll(client);
                PrintCenterText(client, "[O] BOLA!");
            }
        }
        case SONIC_SPIN_DIVE:
        {
            // aterrizaje de la picoada -> ROLL con duración completa
            if (GetEntityFlags(client) & FL_ONGROUND)
            {
                g_iSonicSpinPhase[client] = SONIC_SPIN_ROLL;
                g_fSonicSpinUntil[client] = now + g_cvSonicSpinDuration.FloatValue;
                g_fSonicSpinLastHit[client] = 0.0;
                Sonic_StartRoll(client);

                // mini-impacto de aterrizaje (satisfacción)
                float pos[3];
                GetClientAbsOrigin(client, pos);
                TE_SetupBeamRingPoint(pos, 10.0, 120.0, g_iSonicGlowSprite, g_iSonicGlowSprite, 0, 15, 0.3, 4.0, 1.0, {80, 120, 255, 180}, 0, 0);
                TE_SendToAll();
                PrintCenterText(client, "[O] DROPDASH ATERRIZADO!");
            }
        }
        case SONIC_SPIN_ROLL:
        {
            // v6.6 (9): solo un bloqueo SERIO corta la bola — un agarre
            // que la eva va a romper en el próximo tick ya no la mata
            if (Sonic_OM_BusyLockedSerious(client)) { Sonic_EndRoll(client, false); return; }
            // v6.12 (informe 6 — "a veces no hace el retroceso"): el
            // pegado del golpe final ya NO puede cortarse por vencerse el
            // cronometro de la bola a mitad del lock (antes: EndRoll
            // silencioso = se quedaba pegado sin rebote ni ragdoll). Si
            // la bola vence estando el final en curso, se ESTIRA hasta
            // que el PreThink resuelva el lock con el FinalThrow.
            if (g_bSonicSpinFinalPending[client]
                && g_fSonicSpinUntil[client] < g_fSonicSpinLockUntil[client] + 0.1)
            {
                g_fSonicSpinUntil[client] = g_fSonicSpinLockUntil[client] + 0.1;
            }
            if (now >= g_fSonicSpinUntil[client])
            {
                Sonic_EndRoll(client, false);
                return;
            }
            // v6.6 (5): barrido AoE frontal contra COMUNES cada 0.2s
            // (rango extra SOLO para ellos; especiales y witch siguen
            // con el alcance del toque de siempre)
            Sonic_OM_RollSweepCommons(client, now);

            // re-emisión del loop (WAV ~2s)
            if (now >= g_fSonicSpinLoopSnd[client])
            {
                EmitSoundToAll(SONIC_SND_SPIN_LOOP, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
                g_fSonicSpinLoopSnd[client] = now + 1.9;
            }
        }
    }

    // ---- PEEL ----
    switch (g_iSonicPeelPhase[client])
    {
        case 1:   // cargando
        {
            if (Sonic_OM_BusyLockedSerious(client))
            {
                // cancelada por dano de control: CD de fallo (GMod CooldownFail)
                g_iSonicPeelPhase[client] = 0;
                float cd = g_cvSonicPeelCDFail.FloatValue;
                g_fSonicPeelCD[client] = now + cd;
                g_fSonicPeelCDDur[client] = cd;
                StopSound(client, SNDCHAN_AUTO, SONIC_SND_SPIN_CHARGE);
                // v6.24: mata la NUBE GRIS de la carga (KillPeelTrail
                // barre también el steam del polvo)
                Sonic_KillPeelTrail(client);
                return;
            }
            // v6.5 (E): el sonido de carga también LOOPEA (WAV ~2s)
            if (now >= g_fSonicPeelLoopSnd[client])
            {
                EmitSoundToAll(SONIC_SND_SPIN_CHARGE, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
                g_fSonicPeelLoopSnd[client] = now + 1.9;
            }
            // v6.22: POLVO GRIS de la carga (peeloutdust2_OM del GMod)
            Sonic_PeelChargeDust(client, now);
            if (now >= g_fSonicPeelChargeEnd[client])
                Sonic_PeelRunStart(client);
        }
        case 2:   // corriendo
        {
            if (Sonic_OM_BusyLockedSerious(client)) { Sonic_PeelRunEnd(client); return; }
            if (now >= g_fSonicPeelRunEnd[client]) { Sonic_PeelRunEnd(client); return; }

            // "I'm outta here": sin infectados cerca (voz GMod)
            if (!g_bSonicPeelSaidOut[client])
            {
                if (!Sonic_AnyInfectedNear(client, 700.0))
                {
                    g_bSonicPeelSaidOut[client] = true;
                    EmitSoundToAll(SONIC_SND_OUTTAHERE, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
                }
            }

            // RESCATE: companion incapacitado al alcance -> lo levanta
            if (g_cvSonicPeelRescue.BoolValue)
                Sonic_PeelRescueScan(client);

            // v6.14: LLEVAR — companion SANO al alcance -> lo montamos
            // detrás (incap = rescate arriba; sano = viaje)
            if (g_cvSonicPeelCarry.BoolValue)
                Sonic_PeelCarryScan(client);

            // v6.22: LA NUBE AZUL de la carrera — v6.27: esferitas blancas
            // del TORSO (Sonic_PeelTinyBall) + glows 125,125,175 + moon
            // (el bloque Think L1588-1662 del GMod a la misma cadencia 10
            // Hz del emitter original; el humo blanco lo CAMBIAN las
            // esferitas — orden del owner 2026-10-09)
            Sonic_PeelCloudTick(client);
            Sonic_PeelTinyBall(client);

            // v6.6 (1): SIN loop de la bola en la carrera del peel —
            // "el sonido del spin sonando como si hiciera el spin a la
            // vez". La carrera suena a PeelOutStart + outta-here +
            // brake; el looping3 es SOLO de la bola.
        }
        case 3:   // frenando
        {
            if (now >= g_fSonicPeelBrakeEnd[client])
                g_iSonicPeelPhase[client] = 0;
        }
    }
}

// Escaneo de rescate del peel (GMod: FindInSphere 100 + ReviveFunction_OM)
void Sonic_PeelRescueScan(int client)
{
    float pos[3];
    GetClientAbsOrigin(client, pos);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != 2) continue;
        if (GetEntProp(i, Prop_Send, "m_isIncapacitated") <= 0) continue;
        if (GetEntProp(i, Prop_Send, "m_isHangingFromLedge") > 0) continue;  // colgado: que lo salven con manos

        float ipos[3];
        GetClientAbsOrigin(i, ipos);
        if (GetVectorDistance(pos, ipos) > 120.0) continue;

        // levantarlo (receta del suite: incap off + revive count + HP)
        SetEntProp(i, Prop_Send, "m_isIncapacitated", 0);
        SetEntProp(i, Prop_Send, "m_reviveCount", 0);
        SetEntityHealth(i, 50);

        EmitSoundToAll(SONIC_SND_PEEL_PICKUP, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
        g_iSonicPeelRescues[client]++;
        PrintCenterText(i, "[Sonic] TE LEVANTO EN PLENA CARRERA!");
        PrintCenterText(client, "[+] RESCATE: %N de pie!", i);
        PrintToChatAll("\x04[Sonic]\x05 %N\x01 levanto a \x05%N\x01 con el Peel Out!", client, i);
        break;   // uno por tick de fase
    }
}

// =====================================================================
// v6.14 - PEEL OUT LLEVA JUGADORES ("el peel out según los lua de GMod
// dice que este puede llevar supervivientes (o sea en GMod a otros
// jugadores)"). Companions SANOS tocados durante la carrera viajan
// montados detrás de Sonic; el rescate de incap de la v6.13 queda
// INTACTO (incap = levantar, sano = llevar).
// =====================================================================

// pineado/colgado/en-su-propia-fase: no se monta (o se baja YA)
bool Sonic_PeelPassengerBusy(int p)
{
    if (GetEntProp(p, Prop_Send, "m_isIncapacitated") > 0) return true;
    if (GetEntProp(p, Prop_Send, "m_isHangingFromLedge") > 0) return true;
    if (GetEntPropEnt(p, Prop_Send, "m_tongueOwner") > 0) return true;
    if (GetEntPropEnt(p, Prop_Send, "m_pounceAttacker") > 0) return true;
    if (GetEntPropEnt(p, Prop_Send, "m_jockeyAttacker") > 0) return true;
    if (GetEntPropEnt(p, Prop_Send, "m_carryAttacker") > 0) return true;
    if (GetEntPropEnt(p, Prop_Send, "m_pummelAttacker") > 0) return true;
    // un Sonic pasajero que arranca su propia bola/peel se baja
    if (g_iPlayerCharIdx[p] == SONIC_INDEX
        && (g_iSonicSpinPhase[p] != SONIC_SPIN_NONE || g_iSonicPeelPhase[p] != 0)) return true;
    return false;
}

// ¿la bandera de pasajero sigue válida? (self-heal: el carrier pudo
// morir o soltar sin limpiar — la bandera rancia solo estorbaria el
// próximo montaje, así que se purga al verificarla)
bool Sonic_PeelIsSeated(int p)
{
    int c = g_iSonicPeelCarrier[p];
    if (c <= 0 || c > MaxClients) { g_iSonicPeelCarrier[p] = 0; return false; }
    if (!IsClientInGame(c) || !IsPlayerAlive(c)) { g_iSonicPeelCarrier[p] = 0; return false; }
    int ref = EntIndexToEntRef(p);
    for (int s = 0; s < SONIC_PEEL_SEATS; s++)
        if (g_iSonicPeelSeats[c][s] == ref) return true;
    g_iSonicPeelCarrier[p] = 0;   // el asiento ya no existe
    return false;
}

// montaje (FSM 10 Hz): un SANO nuevo por tick de fase, como el rescate
void Sonic_PeelCarryScan(int client)
{
    int maxSeats = g_cvSonicPeelCarryMax.IntValue;
    if (maxSeats > SONIC_PEEL_SEATS) maxSeats = SONIC_PEEL_SEATS;
    if (maxSeats < 0) maxSeats = 0;

    int seat = -1;
    for (int s = 0; s < maxSeats; s++)
        if (g_iSonicPeelSeats[client][s] == 0) { seat = s; break; }
    if (seat == -1) return;

    float pos[3];
    GetClientAbsOrigin(client, pos);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != 2) continue;
        // incap = territorio del RESCATE (v6.13), no del viaje
        if (GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0) continue;
        if (Sonic_PeelPassengerBusy(i)) continue;
        if (Sonic_PeelIsSeated(i)) continue;   // ya viaja (con cualquiera)

        float ipos[3];
        GetClientAbsOrigin(i, ipos);
        if (GetVectorDistance(pos, ipos) > SONIC_PEEL_PICK_R) continue;

        g_iSonicPeelSeats[client][seat] = EntIndexToEntRef(i);
        g_iSonicPeelCarrier[i] = client;
        // v6.32 FIX AGARRE (1/2): el salto que el pasajero traiga
        // PRESIONADO al montarse (corriendo/saltando cuando Sonic lo
        // agarra — lo normal en este server) NO cuenta como bajarse:
        // se arma el detector de FLANCO — solo un ESPACIO nuevo (tras
        // soltarlo) o 1.0s sostenido lo bajan a propósito.
        g_fSonicPeelMountAt[i] = GetEngineTime();
        g_bSonicPeelJumpArmed[i] = false;

        EmitSoundToAll(SONIC_SND_PEEL_PICKUP, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
        PrintCenterText(i, "[Sonic] TE LLEVA! [ESPACIO] para bajarte");
        PrintCenterText(client, "[+] LLEVANDO: %N", i);
        return;   // uno por tick
    }
}

// hueco bloqueado? solo GEOETRIA/props cuentan — jugadores e infectados
// se ignoran (a 800 u/s siempre hay un común pisando el asiento)
public bool Sonic_PeelCarryTraceFilter(int entity, int contentsMask, any data)
{
    if (entity <= MaxClients) return false;
    static char cls[16];
    GetEntityClassname(entity, cls, sizeof(cls));
    if (StrEqual(cls, "infected", false)) return false;
    return true;
}

bool Sonic_PeelCarrySpotBlocked(const float dest[3], const float mins[3], const float maxs[3])
{
    TR_TraceHullFilter(dest, dest, mins, maxs, MASK_PLAYERSOLID, Sonic_PeelCarryTraceFilter, 0);
    return TR_DidHit();
}

// ARRASTRE (PreThink del carrier, por frame): cada pasajero se pega a
// su ancla detrás de Sonic heredando la velocidad de la carrera
void Sonic_PeelCarryPreThink(int client)
{
    // nada que arrastrar (3 lecturas baratas)
    if (g_iSonicPeelSeats[client][0] == 0 && g_iSonicPeelSeats[client][1] == 0
        && g_iSonicPeelSeats[client][2] == 0) return;

    // la carrera acabo (freno/combo/interrupción)? soltar YA, sin
    // esperar al 10 Hz de la FSM
    if (g_iSonicPeelPhase[client] != 2)
    {
        Sonic_PeelCarryDropAll(client, false);
        return;
    }

    float pos[3], ang[3], fwd[3], right[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetAngleVectors(ang, fwd, right, NULL_VECTOR);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);

    for (int s = 0; s < SONIC_PEEL_SEATS; s++)
    {
        int ref = g_iSonicPeelSeats[client][s];
        if (ref == 0) continue;

        int p = EntRefToEntIndex(ref);
        if (p == INVALID_ENT_REFERENCE || p <= 0 || p > MaxClients
            || !IsClientInGame(p) || !IsPlayerAlive(p))
        {
            Sonic_PeelCarryEject(client, s, 2);   // se fue/murió: slot libre
            continue;
        }

        // se baja solo (salto) — v6.32 FIX AGARRE: SOLO un salto NUEVO
        // cuenta. El ESPACIO heredado del montaje (presionado al agarrarlo)
        // se ignora hasta que el pasajero lo SUELTE (entonces se arma) o
        // pasen 1.0s sostenidos (querer bajarse dejándolo pisado).
        if (GetClientButtons(p) & IN_JUMP)
        {
            if (g_bSonicPeelJumpArmed[p]
                || GetEngineTime() - g_fSonicPeelMountAt[p] >= 1.0)
            {
                Sonic_PeelCarryEject(client, s, 1);
                continue;
            }
        }
        else
        {
            // solto el espacio: el próximo press ya es a propósito
            if (!g_bSonicPeelJumpArmed[p]) g_bSonicPeelJumpArmed[p] = true;
        }
        // pineado/incap/su-propia-bola: emergencia
        if (Sonic_PeelPassengerBusy(p))
        {
            Sonic_PeelCarryEject(client, s, 2);
            continue;
        }

        // se nos perdió por atras (un muro se lo comio varios frames)
        float ppos[3];
        GetClientAbsOrigin(p, ppos);
        if (GetVectorDistance(pos, ppos) > SONIC_PEEL_DROP_R)
        {
            Sonic_PeelCarryEject(client, s, 2);
            continue;
        }

        // ancla del asiento — tren detrás de Sonic:
        // s0: 45u atras | s1: 75u atras +26 der | s2: 75u atras -26 der
        float back = (s == 0) ? 45.0 : 75.0;
        float side = (s == 1) ? 26.0 : (s == 2) ? -26.0 : 0.0;
        float dest[3];
        dest[0] = pos[0] - fwd[0] * back + right[0] * side;
        dest[1] = pos[1] - fwd[1] * back + right[1] * side;
        dest[2] = pos[2];

        // cabe? si el hueco esta tapado, probar pegado atras sin lado;
        // si tampoco, este frame se salta (NO se suelta por un muro)
        float mins[3], maxs[3];
        GetClientMins(p, mins);
        GetClientMaxs(p, maxs);
        if (Sonic_PeelCarrySpotBlocked(dest, mins, maxs))
        {
            float alt[3];
            alt[0] = pos[0] - fwd[0] * 45.0;
            alt[1] = pos[1] - fwd[1] * 45.0;
            alt[2] = pos[2];
            // si tampoco, v6.32 FIX AGARRE (2/2): se ENROLLA al punto de
            // Sonic (+12z) — ANTES el frame se saltaba, Sonic seguía a
            // 800 uu/s y el pasajero quedaba atras hasta pasar
            // SONIC_PEEL_DROP_R... y se soltaba SOLO sin hacer nada. El
            // trace ignora clientes (el hueco de Sonic está libre por
            // definición): el pasajero viaja pegado al dueño hasta que la
            // geometria abra el asiento de nuevo.
            if (Sonic_PeelCarrySpotBlocked(alt, mins, maxs))
            {
                float self[3];
                self[0] = pos[0];
                self[1] = pos[1];
                self[2] = pos[2] + 12.0;
                TeleportEntity(p, self, NULL_VECTOR, vel);
                continue;
            }
            TeleportEntity(p, alt, NULL_VECTOR, vel);
            continue;
        }
        TeleportEntity(p, dest, NULL_VECTOR, vel);
    }
}

// bajar del asiento — reason: 0 fin de viaje (desembarco con pasito),
// 1 se bajó solo (salto), 2 emergencia (queda donde esta)
void Sonic_PeelCarryEject(int client, int seat, int reason)
{
    int ref = g_iSonicPeelSeats[client][seat];
    g_iSonicPeelSeats[client][seat] = 0;

    int p = EntRefToEntIndex(ref);
    if (p == INVALID_ENT_REFERENCE || p <= 0 || p > MaxClients) return;
    if (!IsClientInGame(p)) return;

    if (g_iSonicPeelCarrier[p] == client) g_iSonicPeelCarrier[p] = 0;
    // v6.32: reset del estado anti-salto-fantasma del pasajero
    g_bSonicPeelJumpArmed[p] = false;
    g_fSonicPeelMountAt[p] = 0.0;
    if (!IsPlayerAlive(p)) return;

    if (reason == 1)
    {
        PrintCenterText(p, "[Sonic] te bajaste del viaje");
    }
    else if (reason == 2)
    {
        PrintCenterText(p, "[Sonic] te suelta!");
    }
    else
    {
        PrintCenterText(p, "[Sonic] FIN DEL VIAJE!");
        // pasito de desembarco: 30% de la velocidad (ya frenada por el
        // brake) + un saltito para salir de encima de Sonic
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[0] *= 0.3;
        vel[1] *= 0.3;
        vel[2] = 120.0;
        TeleportEntity(p, NULL_VECTOR, NULL_VECTOR, vel);
    }
}

// soltar todos (fin de carrera con desembarco / emergencia silenciosa)
void Sonic_PeelCarryDropAll(int client, bool endOfRun)
{
    for (int s = 0; s < SONIC_PEEL_SEATS; s++)
        if (g_iSonicPeelSeats[client][s] != 0)
            Sonic_PeelCarryEject(client, s, endOfRun ? 0 : 2);
}

// limpieza total del slot (spawn/round/putInServer): estado, sin teleport
void Sonic_PeelCarryClearState(int client)
{
    for (int s = 0; s < SONIC_PEEL_SEATS; s++)
    {
        int ref = g_iSonicPeelSeats[client][s];
        if (ref == 0) continue;
        g_iSonicPeelSeats[client][s] = 0;

        int p = EntRefToEntIndex(ref);
        if (p == INVALID_ENT_REFERENCE || p <= 0 || p > MaxClients) continue;
        if (IsClientInGame(p) && g_iSonicPeelCarrier[p] == client)
            g_iSonicPeelCarrier[p] = 0;
        // v6.32: reset del estado del pasajero liberado
        if (p > 0 && p <= MaxClients)
        {
            g_bSonicPeelJumpArmed[p] = false;
            g_fSonicPeelMountAt[p] = 0.0;
        }
    }
    g_iSonicPeelCarrier[client] = 0;
    // v6.32: y del propio slot (por si era pasajero de otro Sonic)
    g_bSonicPeelJumpArmed[client] = false;
    g_fSonicPeelMountAt[client] = 0.0;
}

bool Sonic_AnyInfectedNear(int client, float radius)
{
    float pos[3];
    GetClientAbsOrigin(client, pos);
    float rSq = radius * radius;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != 3) continue;
        float ipos[3];
        GetClientAbsOrigin(i, ipos);
        if (GetVectorDistance(pos, ipos, true) <= rSq) return true;
    }
    static const char sCls[][] = {"infected", "witch"};
    for (int c = 0; c < 2; c++)
    {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, sCls[c])) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            float epos[3];
            GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
            if (GetVectorDistance(pos, epos, true) <= rSq) return true;
        }
    }
    return false;
}

// =====================================================================
// PRETHINK OM: movimiento forzado por tick (bola / peel / windup)
// (se integra AL FINAL del Sonic_PreThink v5.4, que sigue intacto)
// =====================================================================
void Sonic_OM_PreThink(int client)
{
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;

    // v6.12 (informe 6): ventana de re-afirmación del REBOTE del golpe
    // final ("siempre debería lanzarse hacia atras"). Si el impulso se
    // lo comio algo (velocidad horizontal < 200 uu/s), se re-imprime el
    // vector del rebote; si salió bien (o el motor lo recorto contra un
    // muro de verdad, que ya lo recortara otra vez), la velocidad es
    // alta y aquí no se toca nada. La ventana se cierra sola si Sonic
    // mete otra habilidad en esos ~4 ticks.
    if (g_fSonicBounceAssertUntil[client] > 0.0)
    {
        if (GetEngineTime() >= g_fSonicBounceAssertUntil[client]
            || g_iSonicSpinPhase[client] != SONIC_SPIN_NONE
            || g_iSonicPeelPhase[client] != 0)
        {
            g_fSonicBounceAssertUntil[client] = 0.0;
        }
        else if (IsPlayerAlive(client))
        {
            float bvel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", bvel);
            if (SquareRoot(bvel[0] * bvel[0] + bvel[1] * bvel[1]) < 200.0)
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, g_vSonicBounceDir[client]);
        }
    }

    // WINDUP / CARGA DE PEEL: clavado en el sitio (GMod OM_NoMovement)
    if (g_iSonicSpinPhase[client] == SONIC_SPIN_WINDUP
        || g_iSonicPeelPhase[client] == 1)
    {
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[0] != 0.0 || vel[1] != 0.0)
        {
            vel[0] = 0.0;
            vel[1] = 0.0;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        }
        return;
    }

    // ROLL: carrera forzada de la bola
    if (g_iSonicSpinPhase[client] == SONIC_SPIN_ROLL)
    {
        // v6.4: PEGADO del golpe final (GMod L313/264: SetPos(enemigo+35z)
        // + quieto): la bola queda clavada en la cara del enemigo hasta
        // expirar el lock y entonces sale el lanzamiento completo.
        // v6.5: el pegado puede ser a un CLIENTE o a una WITCH (entity).
        if (g_bSonicSpinFinalPending[client])
        {
            int fvictim = EntRefToEntIndex(g_iSonicSpinLockVictim[client]);
            bool vicOK = false;
            float fpos[3];

            if (fvictim > 0 && fvictim <= MaxClients)
            {
                vicOK = (IsClientInGame(fvictim) && IsPlayerAlive(fvictim));
                if (vicOK) GetClientAbsOrigin(fvictim, fpos);
            }
            else if (fvictim > MaxClients && IsValidEntity(fvictim))
            {
                char fcls[16];
                GetEntityClassname(fvictim, fcls, sizeof(fcls));
                vicOK = (StrEqual(fcls, "witch")
                         && GetEntProp(fvictim, Prop_Data, "m_iHealth") > 0);
                if (vicOK) GetEntPropVector(fvictim, Prop_Data, "m_vecOrigin", fpos);
            }

            if (GetEngineTime() >= g_fSonicSpinLockUntil[client] || !vicOK)
            {
                Sonic_OM_FinalThrow(client, g_fSonicSpinLockDir[client]);
            }
            else
            {
                float fzero[3] = {0.0, 0.0, 0.0};
                fpos[2] += 35.0;    // GMod: +35 = altura de la cara
                TeleportEntity(client, fpos, NULL_VECTOR, fzero);
            }
            return;
        }

        float speed = g_cvSonicSpinSpeed.FloatValue;
        float vel[3], ang[3], fwd[3];
        if (g_cvSonicSpinSlippery.BoolValue)
        {
            // deslizante: se dirige con la vista (mouse steering)
            GetClientEyeAngles(client, ang);
            ang[0] = 0.0; ang[2] = 0.0;
            GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
        }
        else
        {
            // línea recta: rumbo fijo de la velocidad actual (o vista)
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            if (vel[0]*vel[0] + vel[1]*vel[1] > 100.0)
            {
                float y = RadToDeg(ArcTangent2(vel[1], vel[0]));
                ang[0] = 0.0; ang[1] = y; ang[2] = 0.0;
            }
            else
                GetClientEyeAngles(client, ang);
            ang[0] = 0.0; ang[2] = 0.0;
            GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
        }
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[0] = fwd[0] * speed;
        vel[1] = fwd[1] * speed;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        return;
    }

    // PEEL RUN: carrera automática hacia adelante (GMod OM_MoveForward)
    if (g_iSonicPeelPhase[client] == 2)
    {
        float speed = g_cvSonicPeelSpeed.FloatValue;
        float vel[3], ang[3], fwd[3];
        GetClientEyeAngles(client, ang);
        ang[0] = 0.0; ang[2] = 0.0;
        GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[0] = fwd[0] * speed;
        vel[1] = fwd[1] * speed;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        return;
    }
}

// =====================================================================
// GOLPES DE LA BOLA (SDKHook_Touch, como el spin dash v5.4)
// =====================================================================
void Sonic_OM_RollHit(int client, int other, float now)
{
    if (g_iSonicSpinPhase[client] != SONIC_SPIN_ROLL) return;
    if (g_bSonicSpinFinalPending[client]) return;   // v6.4: pegado al final, no golpea más

    char targetCls[32];
    bool SpecCheck = (other <= MaxClients && other > 0 && IsClientInGame(other)
                      && GetClientTeam(other) == 3 && IsPlayerAlive(other));
    bool wtCheck = false, ctCheck = false;
    if (!SpecCheck && other > MaxClients && IsValidEntity(other))
    {
        GetEntityClassname(other, targetCls, sizeof(targetCls));
        wtCheck = StrEqual(targetCls, "witch");
        ctCheck = StrEqual(targetCls, "infected");
    }
    if (!SpecCheck && !wtCheck && !ctCheck) return;

    // filtro global de 0.5s entre golpes (GMod CooldownHit_OM_sonic)
    if (now < g_fSonicSpinLastHit[client]) return;
    g_fSonicSpinLastHit[client] = now + 0.5;

    float dmg = g_cvSonicSpinDamage.FloatValue;
    float targetPos[3];
    if (SpecCheck) GetClientAbsOrigin(other, targetPos);
    else GetEntPropVector(other, Prop_Send, "m_vecOrigin", targetPos);

    // dirección de golpeo = rumbo de la bola
    float fDir[3], ang[3];
    GetClientEyeAngles(client, ang);
    ang[0] = 0.0; ang[2] = 0.0;
    GetAngleVectors(ang, fDir, NULL_VECTOR, NULL_VECTOR);

    // ===== COMUNES (v6.4, regla del owner): la bola los revienta igual
    // pero NO cuentan para la tanda — ni golpe, ni stun, ni golpe final.
    // Solo especiales y witch "marcan" (en el GMod no existen comunes) =====
    if (ctCheck)
    {
        // común: revienta (GMod OM: los commons caen de un roce).
        // v6.35: OM_AbilityDamage = amplificador hibrido del suite
        OM_AbilityDamage(other, client, dmg * 2.0, DMG_CLUB);
        float push[3] = {0.0, 0.0, 350.0};
        TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, push);
        EmitSoundToAll(SONIC_SND_HIT, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
        return;
    }

    // ===== ESPECIALES / WITCH: aquí si avanza la tanda =====
    bool finalHit = (g_iSonicSpinHits[client] + 1 >= g_cvSonicSpinMaxHits.IntValue);

    // anillos por golpe (GMod ringgain, respetando el tope)
    Sonic_GainRings(client, g_cvSonicSpinRingGain.IntValue);

    if (SpecCheck)
    {
        // v6.4: STUN DE VERDAD estilo GMod (el sistema de Metal, OM_Stun):
        // estatua + 3 estrellas + chispas + tinte + zap, y el dano viaja
        // DENTRO (como el DamageInfo del GMod). El push 750 se retira: un
        // congelado no vuela (el freeze gana, igual que en el GMod).
        // Bot o jugador humano da igual: el freeze cubre a los dos.
        // v6.5 (C): el TANK tiene su propia cifra (+75% del original).
        float hitDmg = dmg;
        if (GetEntProp(other, Prop_Send, "m_zombieClass") == 8)
            hitDmg = g_cvSonicSpinDmgTank.FloatValue;
        float stunDur = finalHit ? g_cvSonicSpinStunFinal.FloatValue
                                 : g_cvSonicSpinStun.FloatValue;
        OM_Stun(other, stunDur, client, hitDmg, DMG_CLUB,
                g_cvSonicSpinStunStack.BoolValue);
    }
    else if (wtCheck)
    {
        // v6.5 (B): FUERA el efecto de Amy (WitchFlight_Launch era el
        // home-run del martillo). La witch recibe el MISMO trato que
        // los especiales: dano, empujon hacia ATRAS (nada de vuelo) y
        // stun de witch (estatua + estrellas) en CADA golpe — no solo
        // en el final. El empujon lo desliza el watcher a mano: la
        // witch congelada NO integra velocidad (FL_FROZEN apaga su
        // locomoción — misma razón por la que Witch_Flight integra su
        // vuelo en su propio tick).
        OM_AbilityDamage(other, client, dmg * 2.0, DMG_CLUB);
        WitchFlight_CheckDead(other);

        Sonic_WitchStun(other, finalHit ? g_cvSonicSpinStunFinal.FloatValue
                                        : g_cvSonicSpinStun.FloatValue);

        int ws = Sonic_WitchStunSlotOf(other);
        if (ws != -1)
        {
            g_vSonicWitchPushDir[ws][0] = fDir[0];
            g_vSonicWitchPushDir[ws][1] = fDir[1];
            g_vSonicWitchPushDir[ws][2] = 0.0;
            g_fSonicWitchPushUntil[ws] = now + 0.30;   // ~120u a 400 uu/s
        }
    }

    EmitSoundToAll(SONIC_SND_HIT, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // v6.20: EFECTO DE GOLPE completo (port del sonic_spindashhit del
    // GMod, pedido del owner: "los impactos del spindash tienen también
    // un efecto de golpe") — reemplaza el mini-anillo 10->90/0.25s
    Sonic_SpawnHitFx(targetPos);

    // v6.20: PULSO de la bola al golpear (alla: GlowingBallThingy recibe
    // sonic_attack_glow_duration 0.25s — la bola brilla más un instante)
    int ballPulse = (g_iSonicBall[client] != 0) ? EntRefToEntIndex(g_iSonicBall[client]) : -1;
    if (ballPulse > 0 && IsValidEntity(ballPulse) && g_iSonicGlowSprite > 0)
    {
        float bp[3];
        Sonic_WorldOrigin(ballPulse, bp);   // v6.21: MUNDO (la bola es parentada — el anillo salia en el (0,0,15) del mapa)
        int cPulse[4] = {120, 170, 255, 235};
        TE_SetupBeamRingPoint(bp, 4.0, 42.0, g_iSonicGlowSprite, g_iSonicGlowSprite,
                              0, 15, 0.25, 5.0, 1.5, cPulse, 0, 0);
        TE_SendToAll();
    }

    g_iSonicSpinHits[client]++;

    // ===== GOLPE FINAL (GMod maxhits): el ritual completo =====
    if (!finalHit) return;

    g_bSonicSpinFinalized[client] = true;
    EmitSoundToAll(SONIC_SND_FINAL, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);
    EmitSoundToAll(SONIC_SND_DRILL, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);

    if ((SpecCheck || wtCheck) && g_cvSonicSpinLockTime.FloatValue > 0.0)
    {
        // GMod L313: SetPos(enemigo + 35z) — Sonic se queda PEGADO a la
        // cara del enemigo sonicom_spin_locktime s (quieto, drill sonando)
        // y al expirar el PreThink ejecuta el lanzamiento. En la bola es
        // invulnerable: el pegado es seguro. v6.5: la WITCH también
        // entra al pegado (su ritual final ahora es completo).
        g_bSonicSpinFinalPending[client] = true;
        g_iSonicSpinLockVictim[client] = EntIndexToEntRef(other);
        g_fSonicSpinLockUntil[client] = now + g_cvSonicSpinLockTime.FloatValue;
        g_fSonicSpinLockDir[client] = fDir;
        return;
    }

    Sonic_OM_FinalThrow(client, fDir);
}

// =====================================================================
// v6.6 (5): BARRIDO AoE FRONTAL CONTRA COMUNES mientras rueda la bola.
// El owner: "no tiene suficiente dano en Aoe para los comons (al menos
// de frente ya que sonic sufre mucho con los comunes) — con los
// especiales y witch el alcance seguirá igual, el aumenta de rango
// solo es para los commons". Cada 0.2s revienta TODO común del cono
// frontal (radio sonicom_spin_radius_commons): a 600+ uu/s el toque
// tunelaba comunes y solo alcanzaba a uno por pasada.
// =====================================================================
void Sonic_OM_RollSweepCommons(int client, float now)
{
    float radius = g_cvSonicSpinRadiusCommons.FloatValue;
    if (radius <= 1.0) return;                    // convar en 0 = off
    if (now < g_fSonicSpinNextSweep[client]) return;
    g_fSonicSpinNextSweep[client] = now + 0.2;

    float pos[3];
    GetClientAbsOrigin(client, pos);

    // cono frontal: rumbo de la bola = la vista (slippery) o su
    // velocidad — usamos la vista, es el rumbo real del movimiento
    float fwd[3], ang[3];
    GetClientEyeAngles(client, ang);
    ang[0] = 0.0; ang[2] = 0.0;
    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);

    float rSq = radius * radius;
    float dmg = g_cvSonicSpinDamage.FloatValue * 2.0;   // mismo x2 del toque
    int hits = 0;

    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;

        float epos[3];
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", epos);
        float dx = epos[0] - pos[0];
        float dy = epos[1] - pos[1];
        if (dx * dx + dy * dy > rSq) continue;   // medido en plano (la bola es baja)

        float to[3];
        to[0] = dx; to[1] = dy; to[2] = 0.0;
        if (NormalizeVector(to, to) < 1.0) { to[0] = fwd[0]; to[1] = fwd[1]; }
        if (to[0] * fwd[0] + to[1] * fwd[1] < 0.25) continue;   // cono ~±75°

        hits++;
        float push[3];
        push[0] = to[0] * 320.0;
        push[1] = to[1] * 320.0;
        push[2] = 330.0;
        OM_AbilityDamage(ent, client, dmg, DMG_CLUB);
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
    }

    if (hits > 0)
    {
        // UN solo golpe sonoro por barrida (no ametrallar el WAV) +
        // anillo sutil de feedback
        EmitSoundToAll(SONIC_SND_HIT, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
        TE_SetupBeamRingPoint(pos, 20.0, 130.0, g_iSonicGlowSprite, g_iSonicGlowSprite, 0, 15, 0.2, 3.0, 0.5, {80, 120, 255, 120}, 0, 0);
        TE_SendToAll();
    }
}

// =====================================================================
// STUN OM DE LA BOLA v6.4: lanzamiento del final + ragdoll falso + witch
// (los especiales usan OM_Stun.inc directamente: freeze+estrellas ya)
// =====================================================================

// Lanzamiento del golpe final (GMod L328+, tras el segundo pegado):
// ragdoll falso de la victima volando + explosión + rebote + fin de bola.
void Sonic_OM_FinalThrow(int client, const float fDir[3])
{
    g_bSonicSpinFinalPending[client] = false;
    g_fSonicSpinLockUntil[client] = 0.0;

    int victim = EntRefToEntIndex(g_iSonicSpinLockVictim[client]);
    g_iSonicSpinLockVictim[client] = 0;

    // ragdoll falso (GMod CreateRagdolLCharacter_OM): copia de la victima
    // que sale volando (hitdirection*700) y vive hasta que se pasa el
    // stun; mientras vive, el de verdad queda oculto (RENDER_NONE).
    if (victim > 0 && victim <= MaxClients && IsClientInGame(victim)
        && IsPlayerAlive(victim) && OM_IsStunned(victim)
        && g_cvSonicSpinRagdoll.BoolValue)
    {
        Sonic_SpawnFlingRagdoll(victim, fDir);
    }
    // v6.5 (B): la WITCH también tiene ragdoll falso en su final (se
    // puede: está congelada) — la real queda oculta hasta que se le
    // pasa el stun, y entonces se teletransporta donde cayó el doble.
    else if (victim > MaxClients && IsValidEntity(victim)
             && g_cvSonicSpinRagdoll.BoolValue)
    {
        char vcls[16];
        GetEntityClassname(victim, vcls, sizeof(vcls));
        if (StrEqual(vcls, "witch")
            && GetEntProp(victim, Prop_Data, "m_iHealth") > 0)
        {
            Sonic_SpawnWitchRagdoll(victim, fDir);
        }
    }

    // explosión + rebote (el final clasico del port)
    float pos[3];
    GetClientAbsOrigin(client, pos);
    Sonic_ApplyAreaStagger(client, pos, 300.0, 700.0);
    TE_SetupBeamRingPoint(pos, 20.0, 420.0, g_iSonicBeamSprite, g_iSonicGlowSprite, 0, 15, 0.5, 12.0, 2.0, {90, 130, 255, 220}, 25, 0);
    TE_SendToAll();

    // rebote hacia atras y arriba (GMod L499: dir*640 al soltarse)
    float bounce[3];
    bounce[0] = fDir[0] * -450.0;
    bounce[1] = fDir[1] * -450.0;
    bounce[2] = 500.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, bounce);

    // v6.12 (informe 6 — "siempre debería lanzarse hacia atras"): guardar
    // el vector y abrir la ventana de re-afirmación — si algo se comio la
    // velocidad del rebote, el PreThink la re-imprime en los ~4 ticks
    // siguientes. El doble ya nace SIN colisión (Sonic_RagMakePassable),
    // así que lo normal es que la ventana ni actue: es el cinturon de
    // seguridad por si el rebote nace solapado a cualquier OTRA cosa.
    g_vSonicBounceDir[client][0] = bounce[0];
    g_vSonicBounceDir[client][1] = bounce[1];
    g_vSonicBounceDir[client][2] = bounce[2];
    g_fSonicBounceAssertUntil[client] = GetEngineTime() + 0.12;

    PrintCenterText(client, "[!!] GOLPE FINAL!");
    Sonic_EndRoll(client, true);
}

// GMod CreateRagdolLCharacter_OM: copia ragdoll de la victima que sale
// volando (hitdirection*700) mientras la victima REAL queda oculta.
// Vive hasta que se pasa el stun (lo vigila T_SonicStunWatch).
// v6.9 (informe 4 — "aparece pero cae en seco al suelo y no sale
// impulsado"): DOS versiones le escribieron VELOCIDAD a la entidad
// (TeleportEntity/vel + m_vecVelocity + m_angVelocity) y el doble nunca
// se movió. Causa de raíz: el vphysics de un prop_ragdoll de SERVIDOR
// ignora la velocidad de la entidad — sus huesos la sobreescriben cada
// tick. Eso mueve coches prop_physics (un solo cuerpo rigido, ver
// l4d_explosive_cars LaunchCar) y players, pero no un ragdoll. El juego
// lanza los cadaveres de verdad por la vía CLIENTE (cs_ragdoll +
// m_vecForce/m_nForceBone, AlliedMods t=316614) — física de cliente:
// no rastrea posición en el server (romperia el "reaparece donde cayó
// su doble") y exige m_hPlayer (la witch no es player). SOLUCION: la
// receta casera YA probada en este suite (bruja deslizada, estrellas
// orbitando, Witch_Flight) — lo movemos NOSOTROS: TeleportEntity por
// tick (lo ÚNICO garantizado que mueve un ragdoll vivo; LuxLuma
// L4D2_Defib_Ragdolls mueve los suyos igual desde un timer) siguiendo
// un arco balistico con giro; al tocar piso/muro o vencerse el vuelo,
// el vphysics vuelve al mando (EnableMotion + Wake) y el cuerpo se
// asienta solo. Deterministico: no hay nada que se lo pueda comer.
// v6.11 (owner: "se nota muy... es como el teleport pero sin cosas,
// no podemos hacer una onda tipo amy para empujar solo al ragdoll?"):
// v6.10 demostro que el problema no era la frecuencia de muestreo —
// era el MECANISMO: el vuelo por TeleportEntity mueve al doble en
// saltos discretos que el cliente VE como teleports (los huesos del
// ragdoll viajan por el array m_ragPos y el hop-hop se nota a cualquier
// tickrate). EL CAMBIO DE RAÍZ (la idea del owner): NO lo movemos
// nosotros — lo lanza una ONDA FÍSICA REAL y el vphysics del propio
// ragdoll hace el vuelo. Receta Amy v76/v79 (env_physexplosion) con
// 2 mejoras del pedido: (1) "SOLO al ragdoll": el doble recibe un
// targetname único y la onda filtra por targetentityname (evidencia
// hl2sdk physobj.cpp CPhysExplosion::FindEntity); (2) "peso": la
// magnitud escala por masa (m_iMass/100, como Amy v79) = el mismo
// empujon para cualquier cuerpo (equivalente al SetMass(50) del GMod,
// que aca no existe: las masas por hueso vienen del .phy del modelo).
// spawnflags=1 (SF_PHYSEXPLOSION_NODAMAGE): empuje PURO, cero dano.
// Consecuencias: FUERA el ticker del vuelo, el arco, los traces de
// muro/piso, el giro y el CAP — el vphysics arco+tumba+choca solo, y
// el "reaparece donde cayó su doble" (que lee m_vecOrigin al fin del
// stun) sigue igual. El spawn +24u adelantado se mantiene (no nace
// solapado). v6.33: la ONDA env_physexplosion que vivía aquí abajo
// se RETIRO (ver el bloque v6.33): su fuerza nunca llego al ragdoll
// en este server — la reemplaza la cascada Sonic_RagPhysLaunch ->
// Sonic_RagFlingEngine.
#define SONIC_RAG_SPAWNFWD 24.0   // u de adelanto del spawn en el rumbo (no nace solapado a la victima)

// v6.7 (informe 2): la victima real invisible DEJA DE SER UN MURO. Su
// grupo de colisión pasa a DEBRIS (2) mientras vuela el doble — misma
// receta que Amy v64 en su embestida ("nada la frena fisicamente") y
// que Sonic homing v6.5: atraviesa cuerpos, sigue chocando con el
// mundo. El grupo original se guarda y se restaura en TODOS los
// caminos de fin del ragdoll (Kill* Ragdoll).
void Sonic_RagGhostCollision(int ent, int &oldGroup)
{
    oldGroup = -1;
    if (ent <= 0 || !IsValidEntity(ent)) return;
    if (!HasEntProp(ent, Prop_Data, "m_CollisionGroup")) return;

    oldGroup = GetEntProp(ent, Prop_Data, "m_CollisionGroup");
    SetEntProp(ent, Prop_Data, "m_CollisionGroup", 2);   // DEBRIS
    if (HasEntProp(ent, Prop_Send, "m_CollisionGroup"))
        SetEntProp(ent, Prop_Send, "m_CollisionGroup", 2);   // doble vía (homing v6.5)
}

void Sonic_RagRestoreCollision(int ent, int &oldGroup)
{
    if (oldGroup < 0) { oldGroup = -1; return; }   // no la tocamos
    if (ent <= 0 || !IsValidEntity(ent)) { oldGroup = -1; return; }
    if (!HasEntProp(ent, Prop_Data, "m_CollisionGroup")) { oldGroup = -1; return; }

    SetEntProp(ent, Prop_Data, "m_CollisionGroup", oldGroup);
    if (HasEntProp(ent, Prop_Send, "m_CollisionGroup"))
        SetEntProp(ent, Prop_Send, "m_CollisionGroup", oldGroup);
    oldGroup = -1;
}

// v6.12 (informe 6 — "se queda a veces atascado por el ragdoll
// dependiendo de la posición del spindash"): el doble en si MISMO era
// SOLIDO para el jugador. El spawn va +24u adelante en el rumbo, pero los
// HUESOS de un doble recien despertado (EnableMotion+Wake) alcanzan a
// envolver la capsula de Sonic pegado a la cara (+35z) — sobre todo en
// los modelos grandes (tank/charger/boomer) y según el angulo de entrada
// del spindash — y entonces el rebote hacia atras NACE DENTRO de un
// solido: la traza del movimiento del jugador parte en solape y el motor
// se come la velocidad (el clasico "atascado"). Solución: la idea del
// owner apuntada al lado correcto del par de colisión — en vez de
// quitarle la colisión a SONIC (su grupo no gobierna SUS trazas de
// movimiento, y abrirlo dejaría pasar comunes/tank a través de el), se
// la quitamos al DOBLE: nace en DEBRIS (la misma receta de la victima
// fantasma v6.7) y se queda así TODA su vida:
//   - el rebote jamás nace dentro de un solido (las trazas del jugador
//     atraviesan DEBRIS, igual que se camina sobre los gibs);
//   - la ONDA lo sigue lanzando igual (env_physexplosion enumera por
//     vphysics, no por grupo de colisión — una granada levanta gibs
//     DEBRIS sin problema);
//   - sigue chocando con el MUNDO: cae, se tumba, rebota, aterriza;
//   - los comunes lo atraviesan = los cadaveres del juego, que nunca
//     estorban el paso;
//   - las balas lo atraviesan (decisión ya aceptada para la victima
//     fantasma v5.32: el doble es un adorno, no un blanco);
//   - no hace falta restaurar nada: nadie necesita que un cadaver de
//     adorno estorbe, y su muerte (Kill*) no cambia.
void Sonic_RagMakePassable(int rag)
{
    if (rag <= MaxClients || !IsValidEntity(rag)) return;
    if (!HasEntProp(rag, Prop_Data, "m_CollisionGroup")) return;
    SetEntProp(rag, Prop_Data, "m_CollisionGroup", 2);   // DEBRIS
    if (HasEntProp(rag, Prop_Send, "m_CollisionGroup"))
        SetEntProp(rag, Prop_Send, "m_CollisionGroup", 2);   // doble vía (receta v6.7)
}

// ============================================================================
// v6.13 - HUECO SEGURO AL REAPARECER (puerto directo del GMod OM, archivos
// que el owner reenvio: noodles_om_pills_status.lua L245-287). Alla, cuando
// el doble termina su vuelo, la victima JAMÁS reaparece pegada a una pared
// o dentro de una escalera: el OM busca un punto donde la CAPSULA ENTERA de
// la victima quepa (TraceHull de punto con sus propios mins/maxs) y si el
// punto de caida no entra, espirala alrededor (radios 16..96u cada 45
// grados, alturas +12/+28/+44) hasta hallar uno. Receta textual:
//   local function IsSafe(pos) ... TraceHull(pos, pos, mins, maxs,
//       MASK_SOLID) ... return not tr.Hit end
//   for radius = 16, 96, 16 do for ang = 0, 315, 45 do
//       for z = 0, 48, 16 do pos = currentpos + dir*radius + z ...
// El OM original solo exige que la capsula QUEPA (no valida piso debajo:
// si el hueco está al aire, la victima cae — el motor se encarga). Si no
// hay NINGÚN hueco en 96u (rincon sellado), false = el llamador usa el
// punto tal cual (comportamiento v6.12, igual que el fallback de GMod).
// Se usa para la victima del golpe final y para la witch del ritual.
// ============================================================================
public bool Sonic_RagSpotFilter(int entity, int contentsMask, int data)
{
    // la propia victima no cuenta (y el doble es DEBRIS: el MASK_SOLID
    // ya lo atraviesa — doble seguro)
    if (entity == data) return false;
    return true;
}

bool Sonic_RagSafeSpot(int self, const float base[3], const float mins[3],
                       const float maxs[3], float out[3])
{
    // alturas de prueba: a ras del doble (+12 = la de siempre del TP)
    float lift[3];
    lift[0] = 12.0; lift[1] = 28.0; lift[2] = 44.0;
    float radius[6];
    radius[0] = 16.0; radius[1] = 32.0; radius[2] = 48.0;
    radius[3] = 64.0; radius[4] = 80.0; radius[5] = 96.0;

    float p[3];
    // 1) el punto de caida tal cual (a las 3 alturas)
    for (int l = 0; l < 3; l++)
    {
        p[0] = base[0]; p[1] = base[1]; p[2] = base[2] + lift[l];
        Handle tr = TR_TraceHullFilterEx(p, p, mins, maxs, MASK_SOLID,
                                          Sonic_RagSpotFilter, self);
        bool hit = TR_DidHit(tr);
        delete tr;
        if (!hit)
        {
            out[0] = p[0]; out[1] = p[1]; out[2] = p[2];
            return true;
        }
    }
    // 2) espiral GMod: 6 radios x 8 rumbos x 3 alturas
    for (int rr = 0; rr < 6; rr++)
    {
        for (int a = 0; a < 360; a += 45)
        {
            float rad = float(a) * FLOAT_PI / 180.0;
            float dx = Cosine(rad) * radius[rr];
            float dy = Sine(rad) * radius[rr];
            for (int l = 0; l < 3; l++)
            {
                p[0] = base[0] + dx; p[1] = base[1] + dy;
                p[2] = base[2] + lift[l];
                Handle tr = TR_TraceHullFilterEx(p, p, mins, maxs, MASK_SOLID,
                                                  Sonic_RagSpotFilter, self);
                bool hit = TR_DidHit(tr);
                delete tr;
                if (!hit)
                {
                    out[0] = p[0]; out[1] = p[1]; out[2] = p[2];
                    return true;
                }
            }
        }
    }
    return false;
}

// ============================================================================
// v6.33 - IMPULSO VPHYSICS DIRECTO POR HUESO (el bloque que cierra la saga)
// ============================================================================
// Receta: GMod ragdoll:GetPhysicsObjectNum(i):SetVelocity(dir*700) — aca la
// interfaz IPhysicsObject es pública (vphysics_interface.h, estable desde
// 2004 en TODOS los Source) y los punteros de los huesos están en el DATAMAP
// del CRagdollProp (DEFINE_PHYSPTR los publica uno por uno). Los índices de
// vtable salen del header del BRANCH L4D2 contado a mano — y como el
// destructor virtual ocupa 1 slot en Windows y 2 en Linux (Itanium), el +1
// lo decide L4D_GetServerOS (left4dhooks, que este suite YA requiere).
//   IsAsleep win=2/lin=3 | IsMotionEnabled win=9/lin=10 | IsMoveable
//   win=10/lin=11 | GetMass win=29/lin=30 | SetVelocity win=50/lin=51.
// BLINDAJE (ningún camino termina en crash):
//   1) Sin left4dhooks o sin datamap -> g_iRagPhysState=-1 -> plan B
//      motor puro (Sonic_RagFlingEngine: TeleportEntity-vel al raíz).
//   2) CUATRO sondas semanticas sobre el hueso raíz ANTES de tocar nada:
//      IsMotionEnabled==1 (acabamos de mandar EnableMotion), IsMoveable==1,
//      IsAsleep en {0,1} y GetMass en [0.05, 10000]. Si UNA falla, la mesa
//      está mala -> plan B motor puro. (Los vecinos de las sondas son
//      getters bool puros: hasta un desfase hipotetico caeria en lectura
//      inocua — y los vecinos de SetVelocity son GetPositionMatrix y
//      SetVelocityInstantaneous, igual de inofensivos.)
//   3) Velocidad por hueso = INDEPENDIENTE DE LA MASA (GMod no pesa nada:
//      SetVelocity es SetVelocity) — TODO cuerpo vuela IGUAL.
//      Nota funebre: el "escalado por masa" de la onda v6.11 leia m_iMass,
//      un campo que prop_ragdoll NO TIENE (es de prop_physics) — o sea que
//      el "peso GMod" de la v6.11 era un cuento que jamás funciono. RIP.
//   4) L4D2 servers son 32-bit en ambos OS: los punteros se leen como
//      Int32 y las sondas validan la lectura antes de usarla.
// ============================================================================
#define SONIC_RAG_PHYSLIFT 0.30   // fracción de la velocidad sumada en Z ("levantarlo del suelo y luego aventarlo", receta de la onda v6.11)
#define SONIC_RAG_TUMBLE  900.0  // giro random max por hueso (el AddAngleVelocity del GMod, mismo número del barrido de Rouge)

// Prep de una llamada virtual cruda contra IPhysicsObject (this = puntero del hueso)
Handle Sonic_RagPhysPrep(int vtblIdx, SDKType retType)
{
    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetVirtual(vtblIdx);
    PrepSDKCall_SetReturnInfo(retType, SDKPass_Plain);
    return EndPrepSDKCall();
}

// Init perezoso, UNA vez por carga de plugin (la vtable no cambia entre
// mapas: es la del binario del servidor). Fallar aquí = plan B para siempre.
bool Sonic_RagPhysReady()
{
    if (g_iRagPhysState != 0) return (g_iRagPhysState == 1);
    g_iRagPhysState = -1;   // pesimista: solo sale vivo si TODO cuadra

    // (1) OS: 0=Windows 1=Linux — sin el native (left4dhooks viejo/no
    // cargado) no hay forma segura de elegir la vtable -> plan B
    if (GetFeatureStatus(FeatureType_Native, "L4D_GetServerOS") != FeatureStatus_Available)
        return false;
    int shift = (L4D_GetServerOS() == 1) ? 1 : 0;

    // (2) las llamadas (índices contados del vphysics_interface.h l4d2)
    g_hRagPhysIsAsleep = Sonic_RagPhysPrep(2  + shift, SDKType_Bool);
    g_hRagPhysMotion   = Sonic_RagPhysPrep(9  + shift, SDKType_Bool);
    g_hRagPhysMoveable = Sonic_RagPhysPrep(10 + shift, SDKType_Bool);
    g_hRagPhysMass     = Sonic_RagPhysPrep(29 + shift, SDKType_Float);

    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetVirtual(50 + shift);   // SetVelocity(const Vector*, const AngularImpulse*)
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);   // velocidad lineal
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);   // impulso angular (3 floats, misma maleta que Vector)
    g_hRagPhysSetVel = EndPrepSDKCall();

    // v6.38: EL PIN — misma interface, vecinos del SetVelocity ya validados
    // por el motor v6.33 (GetPositionMatrix 49 y SetVelocityInstantaneous 51
    // eran los "inofensivos" del blindaje original: ahora son HABILIDAD).
    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetVirtual(46 + shift);   // SetPosition(const Vector&, const QAngle&, bool isTeleport)
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
    PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_Pointer);
    PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
    g_hRagPhysSetPos = EndPrepSDKCall();

    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetVirtual(48 + shift);   // GetPosition(Vector*, QAngle*)
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
    PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_Pointer);
    g_hRagPhysGetPos = EndPrepSDKCall();

    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetVirtual(51 + shift);   // SetVelocityInstantaneous(const Vector*, const AngularImpulse*)
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);   // AngularImpulse = 3 floats
    g_hRagPhysSetVelInst = EndPrepSDKCall();

    if (g_hRagPhysIsAsleep == null || g_hRagPhysMotion == null
        || g_hRagPhysMoveable == null || g_hRagPhysMass == null
        || g_hRagPhysSetVel == null
        || g_hRagPhysSetPos == null || g_hRagPhysGetPos == null
        || g_hRagPhysSetVelInst == null)
        return false;

    g_iRagPhysState = 1;
    return true;
}

// Cachea los offsets del datamap del ragdoll (una sola vez en la vida;
// los nombres son los que el DEFINE_PHYSPTR/DEFINE_FIELD del CRagdollProp
// público compila DENTRO del binario: m_pPhysicsObject = hueso 0,
// m_ragdoll.list[i].pObject = huesos 1..23, m_ragdoll.listCount = cuenta)
bool Sonic_RagPhysCacheOffsets(int rag)
{
    g_iRagOffRoot  = FindDataMapInfo(rag, "m_pPhysicsObject");
    g_iRagOffCount = FindDataMapInfo(rag, "m_ragdoll.listCount");
    if (g_iRagOffRoot <= 0 || g_iRagOffCount <= 0)
    {
        g_iRagOffRoot = -1; g_iRagOffCount = -1;
        return false;
    }
    char fld[48];
    for (int i = 1; i < 24; i++)
    {
        Format(fld, sizeof(fld), "m_ragdoll.list[%d].pObject", i);
        g_iRagOffBone[i] = FindDataMapInfo(rag, fld);   // -1 = hueso sin datamap: se salta
    }
    return true;
}

// LANZA el doble: SetVelocity(lineal, angular) por hueso, directo al
// simulador vphysics. La lineal es la MISMA para todos los huesos (así
// vuela compacto, como el ragdoll del GMod) y el giro es random POR HUESO
// (el AddAngleVelocity del lua). Devuelve true si al menos un hueso
// recibió el impulso; false = el llamador usa el plan B motor puro.
bool Sonic_RagPhysLaunch(int rag, const float fDir[3], float speed, float liftUp, float tumbleMax)
{
    if (!Sonic_RagPhysReady()) return false;
    if (rag <= MaxClients || !IsValidEntity(rag)) return false;

    Address base = GetEntityAddress(rag);
    if (base == Address_Null) return false;

    if (g_iRagOffRoot == -1 && !Sonic_RagPhysCacheOffsets(rag))
        return false;

    // hueso raíz = m_pPhysicsObject (el InitRagdoll del motor hace
    // VPhysicsSetObject(m_ragdoll.list[0].pObject) — es el mismo)
    Address pRoot = view_as<Address>(LoadFromAddress(base + view_as<Address>(g_iRagOffRoot), NumberType_Int32));
    if (pRoot == Address_Null) return false;

    // ---- SONDA SEMANTICA: la mesa esta buena? (ver blindaje en el header)
    int asleep = view_as<int>(SDKCall(g_hRagPhysIsAsleep, pRoot));
    if (asleep != 0 && asleep != 1) return false;
    if (view_as<int>(SDKCall(g_hRagPhysMotion, pRoot)) != 1) return false;   // acabamos de EnableMotion
    if (view_as<int>(SDKCall(g_hRagPhysMoveable, pRoot)) != 1) return false;
    float mass = view_as<float>(SDKCall(g_hRagPhysMass, pRoot));
    if (mass < 0.05 || mass > 10000.0) return false;

    // ---- cuenta de huesos y el impulso
    int nBones = LoadFromAddress(base + view_as<Address>(g_iRagOffCount), NumberType_Int32);
    if (nBones < 1) nBones = 1;
    if (nBones > 24) nBones = 24;

    float lin[3], ang[3];
    lin[0] = fDir[0] * speed;
    lin[1] = fDir[1] * speed;
    lin[2] = fDir[2] * speed + liftUp;   // "levantarlo del suelo y luego aventarlo"

    int launched = 0;
    for (int i = 0; i < nBones; i++)
    {
        Address pBone = pRoot;
        if (i > 0)
        {
            if (g_iRagOffBone[i] <= 0) continue;   // hueso sin campo: fuera
            pBone = view_as<Address>(LoadFromAddress(base + view_as<Address>(g_iRagOffBone[i]), NumberType_Int32));
            if (pBone == Address_Null) continue;
        }
        ang[0] = GetRandomFloat(-tumbleMax, tumbleMax);
        ang[1] = GetRandomFloat(-tumbleMax, tumbleMax);
        ang[2] = GetRandomFloat(-tumbleMax, tumbleMax) * 0.5;
        SDKCall(g_hRagPhysSetVel, pBone, lin, ang);
        launched++;
    }
    return (launched > 0);
}

// v6.38 — EL PIN GMod (pedido del owner via Kolossos v2.0: "el ragdoll no
// queda adherido al brazo... se va hasta el fondo del mapa"). El killer Lua
// NUNCA parenta el ragdoll: su shoulddocustomfunction corre CADA TICK y hace
// headPhys:SetPos(mano) + SetAngles + SetVelocityInstantaneous(vector_origin)
// + Wake — el hueso ancla en la mano y el RESTO del cuerpo cuelga por
// fisica (el look "limp" del agarre). Este es el mismo pin sobre el hueso
// RAIZ del doble: SetPosition(pos, ang, isTeleport=true) + velocidad a
// CERO. El llamador lo repite por frame (su think) mientras dure el agarre.
// Devuelve false = la mesa no esta -> el llamador usa su plan B
// (TeleportEntity con velocidad cero: el mismo efecto por la via engine).
bool Sonic_RagPhysPin(int rag, const float pos[3], const float ang[3])
{
    if (!Sonic_RagPhysReady()) return false;
    if (rag <= MaxClients || !IsValidEntity(rag)) return false;

    Address base = GetEntityAddress(rag);
    if (base == Address_Null) return false;

    if (g_iRagOffRoot == -1 && !Sonic_RagPhysCacheOffsets(rag))
        return false;

    Address pRoot = view_as<Address>(LoadFromAddress(base + view_as<Address>(g_iRagOffRoot), NumberType_Int32));
    if (pRoot == Address_Null) return false;

    // las MISMAS 4 sondas semanticas del launch (mesa mala -> plan B)
    int asleep = view_as<int>(SDKCall(g_hRagPhysIsAsleep, pRoot));
    if (asleep != 0 && asleep != 1) return false;
    if (view_as<int>(SDKCall(g_hRagPhysMotion, pRoot)) != 1) return false;
    if (view_as<int>(SDKCall(g_hRagPhysMoveable, pRoot)) != 1) return false;
    float mass = view_as<float>(SDKCall(g_hRagPhysMass, pRoot));
    if (mass < 0.05 || mass > 10000.0) return false;

    // la receta literal del Lua: velocidad a CERO y CLAVARLO a la mano.
    // El cero de velocidad es EL detalle que falta en un parent: sin el,
    // un padre a 750 u/s (la embestida) acumula velocidad fantasma en el
    // vphysics y el doble sale DISPARADO al soltarlo ("al fondo del mapa")
    float zero[3];
    SDKCall(g_hRagPhysSetVelInst, pRoot, zero, zero);
    SDKCall(g_hRagPhysSetPos, pRoot, pos, ang, true);
    return true;
}

// v6.38 — lectura del hueso RAIZ (pos + ang actuales del doble): el pin
// quiere conservar la orientacion que la fisica le dio (el tilt del agarre
// se aplica ENCIMA). false = plan B (ang del llamador tal cual).
bool Sonic_RagPhysGet(int rag, float pos[3], float ang[3])
{
    if (!Sonic_RagPhysReady()) return false;
    if (rag <= MaxClients || !IsValidEntity(rag)) return false;

    Address base = GetEntityAddress(rag);
    if (base == Address_Null) return false;

    if (g_iRagOffRoot == -1 && !Sonic_RagPhysCacheOffsets(rag))
        return false;

    Address pRoot = view_as<Address>(LoadFromAddress(base + view_as<Address>(g_iRagOffRoot), NumberType_Int32));
    if (pRoot == Address_Null) return false;

    int asleep = view_as<int>(SDKCall(g_hRagPhysIsAsleep, pRoot));
    if (asleep != 0 && asleep != 1) return false;

    SDKCall(g_hRagPhysGetPos, pRoot, pos, ang);
    return true;
}

// v6.33 PLAN B — EL MOTOR HACIENDO EL TRABAJO (cero SDKCall, cero
// left4dhooks: no hay puerta que se pueda cerrar). CBaseEntity::Teleport
// con velocidad invoca pPhys->SetVelocity(vel, NULL) SOBRE EL HUESO RAÍZ
// del ragdoll (evidencia hl2sdk l4d2 baseentity.cpp L4296: static void
// TeleportEntity -> pPhys->SetVelocity(newVelocity, NULL); y
// CRagdollProp::Teleport L951 le pasa la velocidad intacta). Es la MISMA
// ruta que ya hace volar los cuerpos del Barrido de Rouge en este server
// desde hace semanas — la única versión que jamás fallo. El raíz vuela y
// las restricciones del ragdoll arrastran al resto (tumbado natural).
void Sonic_RagFlingEngine(int rag, const float fDir[3], float speed, float liftUp)
{
    if (rag <= MaxClients || !IsValidEntity(rag)) return;
    float vel[3];
    vel[0] = fDir[0] * speed;
    vel[1] = fDir[1] * speed;
    vel[2] = fDir[2] * speed + liftUp;
    TeleportEntity(rag, NULL_VECTOR, NULL_VECTOR, vel);
}

// v6.34 - ENVOLTURA PUBLICA PARA PROPS (no-ragdoll): el MISMO SDKCall
// SetVelocity(lineal, angular) del motor v6.33, aplicado al IPhysicsObject
// RAÍZ de cualquier entidad física (prop_physics*). Pedido del owner: el
// MARTILLO LANZADO de Amy (manager 3.77.57) debe tener GIRO REAL en vuelo
// ("el martillo esta siempre tieso... hasta un auto cuando le pega el
// tank este puede girar, rota en el aire") — el m_angVelocity del datamap
// lo sobreescribe el vphysics cada tick (la MISMA clase de bug del "doble
// que nace y cae en seco" v6.9, pero en props: dos versiones le escribian
// la velocidad a la ENTIDAD y el simulador jamás la adopto).
// Diferencias con Sonic_RagPhysLaunch (por eso es función aparte):
//   1) NO usa Sonic_RagPhysCacheOffsets: ese cache exige m_ragdoll.*
//      (que un prop NO tiene) y fallaria => envenenaria el cache y
//      mandaría a TODOS los ragdolls al plan B. Cache propio MÍNIMO
//      del m_pPhysicsObject de CBaseEntity (offset común a TODAS las
//      entidades del motor — el mismo campo de siempre).
//   2) El giro lo decide EL LLAMADOR (un prop es UN solo cuerpo, no
//      hay huesos que repartir).
//   3) Las MISMAS 4 sondas semanticas de blindaje antes de tocar nada
//      (mesa mala -> false -> el llamador usa su plan B, cero crash).
bool Sonic_PhysSetVel(int prop, const float lin[3], const float ang[3])
{
    if (!Sonic_RagPhysReady()) return false;
    if (prop <= MaxClients || !IsValidEntity(prop)) return false;

    // cache propio (offset de CBaseEntity: vale para cualquier entidad)
    static int offRoot = -1;
    if (offRoot == -1)
    {
        offRoot = FindDataMapInfo(prop, "m_pPhysicsObject");
        if (offRoot <= 0) { offRoot = -2; return false; }   // no publicado: plan B
    }
    if (offRoot == -2) return false;

    Address base = GetEntityAddress(prop);
    if (base == Address_Null) return false;
    Address pPhys = view_as<Address>(LoadFromAddress(base + view_as<Address>(offRoot), NumberType_Int32));
    if (pPhys == Address_Null) return false;

    // ---- SONDA SEMANTICA (el blindaje del motor v6.33) ----
    int asleep = view_as<int>(SDKCall(g_hRagPhysIsAsleep, pPhys));
    if (asleep != 0 && asleep != 1) return false;
    if (view_as<int>(SDKCall(g_hRagPhysMotion, pPhys)) != 1) return false;
    if (view_as<int>(SDKCall(g_hRagPhysMoveable, pPhys)) != 1) return false;
    float mass = view_as<float>(SDKCall(g_hRagPhysMass, pPhys));
    if (mass < 0.05 || mass > 10000.0) return false;

    SDKCall(g_hRagPhysSetVel, pPhys, lin, ang);
    return true;
}

void Sonic_SpawnFlingRagdoll(int victim, const float fDir[3])
{
    // v6.35: la vanilla envuelve la Ex con los números de siempre —
    // el spindash y todo lo que ya volaba queda IDENTICO
    Sonic_SpawnFlingRagdollEx(victim, fDir, g_cvSonicRagBlast.FloatValue,
                               SONIC_RAG_PHYSLIFT, SONIC_RAG_TUMBLE);
}

// v6.35: LA VARIANTE PARAMETRIZADA — misma receta blindada del
// spindash (esconde a la victima + doble con colisión DEBRIS +
// impulso por hueso + watcher que la restaura), pero la FUERZA la
// pone el llamador (contras de Amy/Rouge/Knuckles: cada una con su
// convar). speed = u/s lineales; liftMul = fracción extra en Z
// (0.30 = la receta clasica); tumble = giro random por hueso.
void Sonic_SpawnFlingRagdollEx(int victim, const float fDir[3], float speed, float liftMul, float tumble)
{
    Sonic_KillSpinRagdoll(victim, true);   // si había uno viejo, liberar

    char mdl[PLATFORM_MAX_PATH];
    GetClientModel(victim, mdl, sizeof(mdl));
    if (mdl[0] == '\0') return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", mdl);
    DispatchSpawn(rag);

    // v6.6: despertar el vphysics YA (input inexistente = fallo
    // silencioso, cero riesgo) — el ragdoll dormido era el "clavado"
    AcceptEntityInput(rag, "EnableMotion");
    AcceptEntityInput(rag, "Wake");

    float pos[3], ang[3];
    GetClientAbsOrigin(victim, pos);
    GetClientAbsAngles(victim, ang);
    // v6.7: nace ADELANTADO en el rumbo del vuelo (+24u) — no nace
    // solapado a la capsula de la victima (el vphysics de un ragdoll
    // que nace dentro de un cuerpo sale raro o queda enganchado)
    pos[0] += fDir[0] * SONIC_RAG_SPAWNFWD;
    pos[1] += fDir[1] * SONIC_RAG_SPAWNFWD;
    pos[2] += 12.0;                          // nace despegado del piso
    TeleportEntity(rag, pos, ang, NULL_VECTOR);

    // v6.12: el doble NACE SIN COLISION contra entidades (DEBRIS de por
    // vida — Sonic_RagMakePassable): el rebote de Sonic ya no puede
    // nacer dentro de un solido, pase por donde pase el spindash.
    Sonic_RagMakePassable(rag);

    if (speed <= 0.0) speed = g_cvSonicRagBlast.FloatValue;
    if (!Sonic_RagPhysLaunch(rag, fDir, speed, speed * liftMul, tumble))
        Sonic_RagFlingEngine(rag, fDir, speed, speed * liftMul);

    g_iSonicSpinRagRender[victim] = view_as<int>(GetEntityRenderMode(victim));
    SetEntityRenderMode(victim, RENDER_NONE);
    // v6.7 (owner "quitarle la colisión al inf invisible"): la victima
    // real aturdida seguía siendo SOLIDA en el sitio del lanzamiento —
    // un muro invisible que se comia el impulso del doble. Sin
    // colisión mientras vuela el ragdoll (se restaura al caer).
    Sonic_RagGhostCollision(victim, g_iSonicRagOldColGroup[victim]);
    g_iSonicSpinRagRef[victim] = EntIndexToEntRef(rag);

    Sonic_StunWatchEnsure();
}

// v6.35: EL CADaver VOLANDO — la receta Rouge v10.4 / Amy v106
// (Amy_OM_HammerFlingCopy) generalizada al suite para los counters que
// MATAN con la contra: copia prop_ragdoll del cuerpo lanzada con el
// impulso por hueso + limpieza a los 3s. becomeRag=true (comunes):
// BecomeRagdoll en el original para que su muerte quede limpia (la
// copia ES el cadaver); false (players): su muerte ya genera cuerpo.
// La usa el uppercut de Knuckles y la patada de Rouge cuando matan.
void Sonic_DeadFlingCopy(int victim, const float dir[3], float speed, bool becomeRag)
{
    if (!IsValidEntity(victim)) return;

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

    if (speed <= 0.0) speed = 550.0;
    if (!Sonic_RagPhysLaunch(rag, dir, speed, speed * 0.55, 900.0))
        Sonic_RagFlingEngine(rag, dir, speed, speed * 0.55);

    if (becomeRag)
        AcceptEntityInput(victim, "BecomeRagdoll");

    CreateTimer(3.0, Sonic_T_DeadFlingClean, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Sonic_T_DeadFlingClean(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Mata el ragdoll falso de una victima (fin de stun / muerte / mapa).
void Sonic_KillSpinRagdoll(int victim, bool restoreRender)
{
    if (g_iSonicSpinRagRef[victim] != 0)
    {
        int rag = EntRefToEntIndex(g_iSonicSpinRagRef[victim]);
        if (rag > MaxClients && IsValidEntity(rag))
            AcceptEntityInput(rag, "Kill");
        g_iSonicSpinRagRef[victim] = 0;
    }
    // v6.11: sin estado de vuelo que limpiar (la onda no deja estado)
    // v6.7: devolver la colisión a la victima (era DEBRIS mientras
    // volaba su doble — todos los caminos de fin pasan por aquí).
    // Guard de cliente desconectado: no tocar un index reciclado.
    if (victim > 0 && victim <= MaxClients)
    {
        if (IsClientInGame(victim))
            Sonic_RagRestoreCollision(victim, g_iSonicRagOldColGroup[victim]);
        else
            g_iSonicRagOldColGroup[victim] = -1;
    }
    if (restoreRender && IsClientInGame(victim))
        SetEntityRenderMode(victim, view_as<RenderMode>(g_iSonicSpinRagRender[victim]));
}

// v6.5 (B): slot de witch para una witch dada (-1 si no esta stuneada).
int Sonic_WitchStunSlotOf(int witch)
{
    int ref = EntIndexToEntRef(witch);
    for (int i = 0; i < SONIC_WITCH_STUN_SLOTS; i++)
        if (g_iSonicWitchRef[i] != 0 && g_iSonicWitchRef[i] == ref) return i;
    return -1;
}

// v6.5 (B): ragdoll falso de la WITCH del ritual final — la witch real
// (congelada por Sonic_WitchStun) queda RENDER_NONE mientras su doble
// vuela con FÍSICA REAL (v6.11: la misma onda que la victima).
void Sonic_SpawnWitchRagdoll(int witch, const float fDir[3])
{
    int s = Sonic_WitchStunSlotOf(witch);
    if (s == -1) return;                    // sin stun activo no hay ritual

    Sonic_KillWitchRagdoll(s, true);

    char mdl[PLATFORM_MAX_PATH];
    GetEntPropString(witch, Prop_Data, "m_ModelName", mdl, sizeof(mdl));
    if (mdl[0] == '\0') return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", mdl);
    DispatchSpawn(rag);

    // v6.6: idem victima — despertar el vphysics al nacer
    AcceptEntityInput(rag, "EnableMotion");
    AcceptEntityInput(rag, "Wake");

    float pos[3], ang[3];
    GetEntPropVector(witch, Prop_Data, "m_vecOrigin", pos);
    GetEntPropVector(witch, Prop_Data, "m_angRotation", ang);
    // v6.7: idem victima — adelantado en el rumbo + colisión fuera
    pos[0] += fDir[0] * SONIC_RAG_SPAWNFWD;
    pos[1] += fDir[1] * SONIC_RAG_SPAWNFWD;
    pos[2] += 12.0;
    TeleportEntity(rag, pos, ang, NULL_VECTOR);

    // v6.12: idem victima — el doble nace SIN colisión (DEBRIS de por
    // vida): el rebote de Sonic no puede nacer dentro de un solido.
    Sonic_RagMakePassable(rag);

    // v6.33: idem victima — LA CASCADA: impulso DIRECTO por hueso y, si
    // la mesa no se pudo armar, el plan B motor puro (TeleportEntity-vel
    // al hueso raíz). La witch vuela con la misma receta que el resto.
    float speed = g_cvSonicRagBlast.FloatValue;
    if (!Sonic_RagPhysLaunch(rag, fDir, speed, speed * SONIC_RAG_PHYSLIFT, SONIC_RAG_TUMBLE))
        Sonic_RagFlingEngine(rag, fDir, speed, speed * SONIC_RAG_PHYSLIFT);

    g_iSonicWitchRagRender[s] = view_as<int>(GetEntityRenderMode(witch));
    SetEntityRenderMode(witch, RENDER_NONE);
    Sonic_RagGhostCollision(witch, g_iSonicWitchRagOldColGroup[s]);
    g_iSonicWitchRagRef[s] = EntIndexToEntRef(rag);
}

// Mata el ragdoll de la witch del slot (y devuelve su render).
void Sonic_KillWitchRagdoll(int s, bool restoreRender)
{
    if (g_iSonicWitchRagRef[s] != 0)
    {
        int rag = EntRefToEntIndex(g_iSonicWitchRagRef[s]);
        if (rag > MaxClients && IsValidEntity(rag))
            AcceptEntityInput(rag, "Kill");
        g_iSonicWitchRagRef[s] = 0;
    }
    // v6.11: sin estado de vuelo que limpiar (la onda no deja estado)
    g_fSonicWitchPushUntil[s] = 0.0;
    // v6.7: idem victima — devolver la colisión a la witch real
    int witchForCol = EntRefToEntIndex(g_iSonicWitchRef[s]);
    if (witchForCol > MaxClients)
        Sonic_RagRestoreCollision(witchForCol, g_iSonicWitchRagOldColGroup[s]);
    else
        g_iSonicWitchRagOldColGroup[s] = -1;
    if (restoreRender)
    {
        int witch = EntRefToEntIndex(g_iSonicWitchRef[s]);
        if (witch > MaxClients && IsValidEntity(witch))
            SetEntityRenderMode(witch, view_as<RenderMode>(g_iSonicWitchRagRender[s]));
    }
}

// STUN DE WITCH: la witch es ENTITY (no cliente) -> fuera del OM_Stun.
// Receta del suite (Witch_Flight/Rouge): FL_FROZEN apaga su IA por
// completo — estatua en el sitio, y si venía volando del launch,
// aterriza y queda clavada. Estrellas = misma matemática del OM_Stun.
void Sonic_WitchStun(int witch, float duration)
{
    if (g_cvSonicSpinStunWitch == null || !g_cvSonicSpinStunWitch.BoolValue) return;
    if (duration <= 0.0) return;

    int s = -1;
    for (int i = 0; i < SONIC_WITCH_STUN_SLOTS; i++)
        if (EntRefToEntIndex(g_iSonicWitchRef[i]) == witch) { s = i; break; }
    if (s == -1)
        for (int i = 0; i < SONIC_WITCH_STUN_SLOTS; i++)
            if (g_iSonicWitchRef[i] == 0) { s = i; break; }
    if (s == -1) { s = 0; Sonic_WitchStunClear(0); }   // reciclar (4 a la vez no pasa)

    float now = GetEngineTime();
    if (g_iSonicWitchRef[s] == 0)
    {
        g_iSonicWitchRef[s] = EntIndexToEntRef(witch);
        g_bSonicWitchHadFrozen[s] = (GetEntityFlags(witch) & FL_FROZEN) != 0;
        g_fSonicWitchStunStart[s] = now;
        Sonic_WitchStunCreateStars(s, witch);
    }
    g_fSonicWitchStunUntil[s] = now + duration;
    Sonic_StunWatchEnsure();
}

// Estrellas de la witch (env_sprite con el ARTE REAL del mod si el VPK
// lo trae — mismos números que OM_Stun: radio 22, rot t*4, bob sin(t*3+i))
void Sonic_WitchStunCreateStars(int s, int witch)
{
    if (!g_bOMStunAssets) return;   // sin VPK: el ticker usa glow TE

    float pos[3];
    GetEntPropVector(witch, Prop_Data, "m_vecOrigin", pos);
    pos[2] += OM_STUN_STAR_HEIGHT;

    for (int i = 0; i < OM_STUN_STAR_COUNT; i++)
    {
        g_iSonicWitchStars[s][i] = 0;
        int ent = CreateEntityByName("env_sprite");
        if (ent == -1) continue;
        DispatchKeyValue(ent, "model", "materials/om/star_stun.vmt");
        DispatchKeyValue(ent, "rendercolor", "255 255 0");
        DispatchKeyValue(ent, "renderamt", "40");
        DispatchKeyValue(ent, "scale", "0.10");
        DispatchKeyValue(ent, "GlowProxySize", "0.0");
        DispatchSpawn(ent);
        TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
        g_iSonicWitchStars[s][i] = EntIndexToEntRef(ent);
    }
}

// Libera un slot de witch: quitar SOLO el FL_FROZEN que pusimos nosotros
// (patron Rouge_WaveRelease) + matar sus estrellas. v6.5: su ragdoll
// falso (si había ritual) muere con el slot y devuelve el render.
void Sonic_WitchStunClear(int s)
{
    Sonic_KillWitchRagdoll(s, true);

    int witch = EntRefToEntIndex(g_iSonicWitchRef[s]);
    if (witch > MaxClients && IsValidEntity(witch) && !g_bSonicWitchHadFrozen[s])
    {
        int flags = GetEntityFlags(witch);
        if (flags & FL_FROZEN)
            SetEntityFlags(witch, flags & ~FL_FROZEN);
    }
    for (int i = 0; i < 3; i++)
    {
        int star = EntRefToEntIndex(g_iSonicWitchStars[s][i]);
        if (star > MaxClients && IsValidEntity(star))
            AcceptEntityInput(star, "Kill");
        g_iSonicWitchStars[s][i] = 0;
    }
    g_iSonicWitchRef[s] = 0;
    g_fSonicWitchStunUntil[s] = 0.0;
    g_fSonicWitchStunStart[s] = 0.0;
    g_bSonicWitchHadFrozen[s] = false;
}

// Enciende el ticker (una sola vez; se apaga solo cuando no queda nada).
void Sonic_StunWatchEnsure()
{
    if (g_hSonicStunWatch == null)
        g_hSonicStunWatch = CreateTimer(0.1, T_SonicStunWatch, _, TIMER_REPEAT);
}

// Ticker 0.1s: vigila ragdolls falsos (viven hasta que se pasa el
// stun) y el witch stun (re-affirma FL_FROZEN + orbita las estrellas).
// v6.11: el vuelo lo hace el vphysics (onda del spawn) — aquí nada lo
// toca. Al pasarse el stun la victima REAL reaparece DONDE QUEDÓ su doble.
public Action T_SonicStunWatch(Handle timer)
{
    bool any = false;
    float now = GetEngineTime();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iSonicSpinRagRef[i] == 0) continue;
        int rag = EntRefToEntIndex(g_iSonicSpinRagRef[i]);
        bool victimOK = (IsClientInGame(i) && IsPlayerAlive(i) && OM_IsStunned(i));
        if (rag <= MaxClients || !IsValidEntity(rag) || !victimOK)
        {
            // v6.5 (A): fin del stun — la victima REAL se teletransporta
            // a DONDE QUEDÓ EL RAGDOLL y de ahi arranca su recuperación
            // (si murió, su cadaver no se toca: solo liberar).
            if (rag > MaxClients && IsValidEntity(rag)
                && IsClientInGame(i) && IsPlayerAlive(i))
            {
                float ragPos[3];
                GetEntPropVector(rag, Prop_Data, "m_vecOrigin", ragPos);
                // v6.13: hueco SEGURO para reaparecer (puerto del GMod
                // status.lua): si el doble cayó pegado a una pared o en
                // una escalera, espiral hasta donde la capsula QUEPA —
                // la victima ya no puede despertar atascada en geometria
                float vmins[3], vmaxs[3], spot[3];
                GetClientMins(i, vmins);
                GetClientMaxs(i, vmaxs);
                if (!Sonic_RagSafeSpot(i, ragPos, vmins, vmaxs, spot))
                {
                    spot[0] = ragPos[0]; spot[1] = ragPos[1];
                    spot[2] = ragPos[2] + 12.0;   // fallback v6.12
                }
                TeleportEntity(i, spot, NULL_VECTOR, NULL_VECTOR);
            }
            Sonic_KillSpinRagdoll(i, IsClientInGame(i));
            continue;
        }
        any = true;

        // v6.11: el vuelo del doble lo lleva el VPHYSICS (onda del
        // spawn) — aquí solo se vigila que el stun siga vivo.
    }

    for (int s = 0; s < SONIC_WITCH_STUN_SLOTS; s++)
    {
        if (g_iSonicWitchRef[s] == 0) continue;
        int witch = EntRefToEntIndex(g_iSonicWitchRef[s]);
        if (witch <= MaxClients || !IsValidEntity(witch)
            || now >= g_fSonicWitchStunUntil[s]
            || GetEntProp(witch, Prop_Data, "m_iHealth") <= 0)
        {
            // v6.5 (A+B): expiro su stun — la witch reaparece DONDE QUEDÓ
            // su ragdoll (si Amy no la relanzo en pleno stun) y de ahi
            // sigue. Muerta: solo liberar.
            int wrag = EntRefToEntIndex(g_iSonicWitchRagRef[s]);
            if (wrag > MaxClients && IsValidEntity(wrag)
                && witch > MaxClients && IsValidEntity(witch)
                && GetEntProp(witch, Prop_Data, "m_iHealth") > 0
                && !WitchFlight_IsFlying(witch))
            {
                float wragPos[3];
                GetEntPropVector(wrag, Prop_Data, "m_vecOrigin", wragPos);
                // v6.13: idem victima — hueco seguro con la capsula de
                // la propia witch (status.lua del GMod)
                float wmins[3], wmaxs[3], wspot[3];
                GetEntPropVector(witch, Prop_Data, "m_vecMins", wmins);
                GetEntPropVector(witch, Prop_Data, "m_vecMaxs", wmaxs);
                if (!Sonic_RagSafeSpot(witch, wragPos, wmins, wmaxs, wspot))
                {
                    wspot[0] = wragPos[0]; wspot[1] = wragPos[1];
                    wspot[2] = wragPos[2] + 10.0;   // fallback v6.12
                }
                TeleportEntity(witch, wspot, NULL_VECTOR, NULL_VECTOR);
            }
            Sonic_WitchStunClear(s);   // expiro / murió / desapareció
            continue;
        }
        any = true;

        // v6.5 (B): desliz hacia atras del golpe — 40u por tick (la
        // witch congelada no integra velocidad: la movemos nosotros,
        // receta Witch_Flight). Muro delante = corto el desliz.
        if (now < g_fSonicWitchPushUntil[s])
        {
            float wnow[3], wdest[3];
            GetEntPropVector(witch, Prop_Data, "m_vecOrigin", wnow);
            wdest[0] = wnow[0] + g_vSonicWitchPushDir[s][0] * 40.0;
            wdest[1] = wnow[1] + g_vSonicWitchPushDir[s][1] * 40.0;
            wdest[2] = wnow[2];
            Handle tr = TR_TraceRayFilterEx(wnow, wdest, MASK_SOLID, RayType_EndPoint,
                                             Sonic_WitchSlideFilter, witch);
            bool blocked = TR_DidHit(tr);
            delete tr;
            if (blocked)
                g_fSonicWitchPushUntil[s] = 0.0;
            else
                TeleportEntity(witch, wdest, NULL_VECTOR, NULL_VECTOR);
        }

        // v6.11: el vuelo del doble de la witch también lo lleva el
        // vphysics (onda) — aquí solo se vigila que exista.
        if (g_iSonicWitchRagRef[s] != 0)
        {
            int wrag = EntRefToEntIndex(g_iSonicWitchRagRef[s]);
            if (wrag <= MaxClients || !IsValidEntity(wrag))
                g_iSonicWitchRagRef[s] = 0;   // lo mataron por fuera
        }

        // re-affirmar el freeze (receta Witch_Flight: si algo externo
        // limpio el flag, el stun tiene que ganar hasta el final)
        if ((GetEntityFlags(witch) & FL_FROZEN) == 0)
            SetEntityFlags(witch, GetEntityFlags(witch) | FL_FROZEN);

        // estrellas: orbita sobre la cabeza (números OM_Stun exactos)
        float wpos[3];
        GetEntPropVector(witch, Prop_Data, "m_vecOrigin", wpos);
        float head[3];
        head[0] = wpos[0];
        head[1] = wpos[1];
        head[2] = wpos[2] + OM_STUN_STAR_HEIGHT;

        // fade in/out (GMod: Lerp 8x)
        int starAlpha = 255;
        float tSince = now - g_fSonicWitchStunStart[s];
        float tLeft  = g_fSonicWitchStunUntil[s] - now;
        if (tSince < 0.25)     starAlpha = RoundToNearest(tSince / 0.25 * 255.0);
        else if (tLeft < 0.25) starAlpha = RoundToNearest(tLeft / 0.25 * 255.0);
        if (starAlpha < 0)   starAlpha = 0;
        if (starAlpha > 255) starAlpha = 255;

        for (int i = 0; i < OM_STUN_STAR_COUNT; i++)
        {
            float sAng = now * OM_STUN_STAR_ROT + (float(i) / float(OM_STUN_STAR_COUNT)) * 6.28318;
            float sPos[3];
            sPos[0] = head[0] + Cosine(sAng) * OM_STUN_STAR_RADIUS;
            sPos[1] = head[1] + Sine(sAng) * OM_STUN_STAR_RADIUS;
            sPos[2] = head[2] + Sine(now * 3.0 + float(i)) * 2.0;

            int star = EntRefToEntIndex(g_iSonicWitchStars[s][i]);
            if (star > MaxClients && IsValidEntity(star))
            {
                TeleportEntity(star, sPos, NULL_VECTOR, NULL_VECTOR);
                SetEntityRenderColor(star, 255, 255, 0, starAlpha);
            }
            else if (g_iSonicWitchStars[s][i] != 0)
            {
                g_iSonicWitchStars[s][i] = 0;   // la mataron por fuera: seguir sin ella
            }
            else
            {
                // sin estrellas REALES (sin VPK om_): glow del suite
                TE_SetupGlowSprite(sPos, g_iSonicGlowSprite, 0.12, 4.0, 255);
                TE_SendToAll();
            }
        }
    }

    if (!any)
    {
        g_hSonicStunWatch = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

// Limpieza total (manager OnMapEnd): sin refs ni renders del mapa viejo.
public void Sonic_OM_StunOnMapEnd()
{
    for (int i = 1; i <= MaxClients; i++)
        Sonic_KillSpinRagdoll(i, IsClientInGame(i));
    for (int s = 0; s < SONIC_WITCH_STUN_SLOTS; s++)
        Sonic_WitchStunClear(s);
    if (g_hSonicStunWatch != null)
    {
        KillTimer(g_hSonicStunWatch);
        g_hSonicStunWatch = null;
    }
}

// =====================================================================
// ANILLOS (GMod Rings / MaxRings / DodgeAnim)
// =====================================================================
void Sonic_GainRings(int client, int amount)
{
    if (amount <= 0) return;
    int maxR = g_cvSonicRingsMax.IntValue;
    g_iSonicRings[client] += amount;
    if (g_iSonicRings[client] > maxR) g_iSonicRings[client] = maxR;
    // v6.36: RETIRADO el hint "Anillos: x/y" (PrintHintText) y la
    // función Sonic_RingsHUD que lo pintaba — la BARRA de ANILLOS
    // del motor SBar (manager 3.77.81) muestra el valor EN VIVO a
    // 5 Hz: no hace falta avisar al ganar (el hint chico, encima, se
    // perdia entre los demas avisos de panel)
}

// =====================================================================
// v6.36: LA BARRA DE ANILLOS — el estado para el motor SBar del
// manager 3.77.81 (pedido del owner: "ese mismo tipo de barra debería
// salir para sonic... sonic para su evasión"). Los ANILLOS son SU EVA
// (el Dodgemeter 0-50 del GMod): con anillos el dano golpea los
// anillos primero y Sonic hace el DODGE; sin anillos, dano normal.
// =====================================================================

// Sonic seleccionado como personaje del manager (el ÍNDICE, no el
// modelo: los anillos son de la selección, no de la skin CST)
bool Sonic_PlayerIs(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return false;
    return g_iPlayerCharIdx[client] == SONIC_INDEX;
}

// llena el estado compartido de SBar; false = sin barra (anillos off)
bool Sonic_BarState(int client)
{
    if (g_cvSonicRings == null || !g_cvSonicRings.BoolValue) return false;

    int mx = (g_cvSonicRingsMax != null) ? g_cvSonicRingsMax.IntValue : 50;
    if (mx < 1) mx = 1;
    int rings = g_iSonicRings[client];
    if (rings < 0) rings = 0;
    if (rings > mx) rings = mx;

    SBar_Clear();
    g_fSBarFrac = float(rings) / float(mx);
    g_iSBarNum  = rings;
    g_iSBarDen  = mx;
    strcopy(g_sSBarLabel, sizeof(g_sSBarLabel), "ANILLOS");

    float now = GetEngineTime();
    bool empty = (rings <= 0);
    if (empty)                  g_bSBarBlink = true;                          // SIN ANILLOS: rojo-gris
    else if (g_fSBarFrac >= 0.5) { g_iSBarChatColor = SBAR_CHAT_BLUE;  }   // celeste Sonic — chat: AZUL survivor (su color)
    else if (g_fSBarFrac >= 0.2) { g_iSBarChatColor = SBAR_CHAT_BLUE;  }   // celeste claro — chat: AZUL
    else                         { g_iSBarChatColor = SBAR_CHAT_GREEN; }   // naranja aviso — chat: AMARILLO aviso

    if (now < g_fSonicDodgeEnd[client] || now < g_fSonicDodgeGraceUntil[client])
        strcopy(g_sSBarTag, sizeof(g_sSBarTag), "ESQUIVA!");
    else if (empty)
        strcopy(g_sSBarTag, sizeof(g_sSBarTag), "SIN ANILLOS!");
    return true;
}

// =====================================================================
// v6.5: DODGE DE CONTROLES (tabla del owner, pagado en anillos)
// + GUARDS DE LA BOLA (en bola no entran agarres ni empujones)
// Los forwards compartidos (lengua/carry/slam/fling/vómito del
// Knuckles, stagger del Tails) llaman a estos helpers desde SUS
// handlers — aquí SOLO se decide, nunca se muta estado ajeno.
// =====================================================================

// Fases de bola activas (WINDUP/DIVE/ROLL): invulnerable a controles.
bool Sonic_SpinGuardActive(int client)
{
    return Sonic_IsValidClient(client) && IsPlayerAlive(client)
        && g_iPlayerCharIdx[client] == SONIC_INDEX
        && g_iSonicSpinPhase[client] != SONIC_SPIN_NONE;
}

// Ventana de gracia (1.5s) tras esquivar: controles y dano gratis.
bool Sonic_DodgeGraceActive(int client)
{
    return g_cvSonicDodge != null && g_cvSonicDodge.BoolValue
        && Sonic_IsValidClient(client)
        && g_iPlayerCharIdx[client] == SONIC_INDEX
        && g_fSonicDodgeGraceUntil[client] > GetEngineTime();
}

// v6.6 (7): gracia CORTA (0.3s) solo para VÓMITO y SPIT — el owner:
// "la evasión ahora tendrá un tiempo de gracia de 0.3 seg para el
// vómito de boomer y spiter ya que esta eva se consume demasiado
// rápido" (la bilis re-spray cada ~0.5s vaciaba los anillos).
bool Sonic_DotGraceActive(int client)
{
    return Sonic_IsValidClient(client)
        && g_iPlayerCharIdx[client] == SONIC_INDEX
        && g_fSonicDotGraceUntil[client] > GetEngineTime();
}

// v6.6 (4): puente para el modulo Speed_sonic (mismo contrato que
// Tails_GetAvatarEnts — el cuerpo de Sonic viaja en RENDER_NONE y el
// trail/glow puesto en el CLIENTE no se ve: ES el error que tenía
// Tails). Con la BOLA puesta devuelve la BOLA (es el visual real).
//   forOwner  = copia L (la que ve el dueño) o el avatar único
//   forOthers = copia R (la que ven los demas) o el avatar único
// false = no hay avatar/bola vivo (usar el player como antes).
bool Sonic_GetAvatarEnts(int client, int &forOwner, int &forOthers)
{
    forOwner = forOthers = -1;
    if (client < 1 || client > MaxClients) return false;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return false;

    if (g_iSonicBall[client] != 0)
    {
        int ball = EntRefToEntIndex(g_iSonicBall[client]);
        if (ball > 0 && IsValidEntity(ball))
        {
            forOwner = forOthers = ball;
            return true;
        }
    }
    if (g_iSonicAvatar[client] == 0) return false;
    int av = EntRefToEntIndex(g_iSonicAvatar[client]);
    if (av <= 0 || !IsValidEntity(av)) return false;
    forOthers = av;
    forOwner  = av;
    if (g_iSonicAvatarL[client] != 0)   // dual R+L del dueño
    {
        int avL = EntRefToEntIndex(g_iSonicAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL)) forOwner = avL;
    }
    return true;
}

// Anim de esquiva del GMod (Dodge1-4 al azar, 0.5s a 1.4x) en R + L.
// v6.29: PRIORITARIA A COMPLETAR — aprende el índice real de la
// secuencia por readback (self-heal contra pisadas en la R) y abre el
// tope duro de 1.2s: la FSM estira el lock hasta que la secuencia
// acabe de verdad en el modelo (m_flCycle >= 0.95).
void Sonic_PlayDodgeAnim(int client)
{
    int st = SONIC_ST_DODGE + GetRandomInt(0, 3);
    g_iSonicDodgeSeq[client] = -1;
    if (g_iSonicAvatar[client] != 0)
    {
        int av = EntRefToEntIndex(g_iSonicAvatar[client]);
        if (av > 0 && IsValidEntity(av))
        {
            SetVariantString(g_sSonicAnimSeq[st]);
            AcceptEntityInput(av, "SetAnimation");
            if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
                SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", 1.4);
            // v6.29: sonda — el índice REAL de la DodgeX en este prop
            // (para que la FSM detecte cualquier pisada y re-dispare)
            g_iSonicDodgeSeq[client] = Sonic_PropSequence(av);
        }
    }
    if (g_iSonicAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iSonicAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetVariantString(g_sSonicAnimSeq[st]);
            AcceptEntityInput(avL, "SetAnimation");
            if (HasEntProp(avL, Prop_Data, "m_flPlaybackRate"))
                SetEntPropFloat(avL, Prop_Data, "m_flPlaybackRate", 1.4);
        }
    }
    g_iSonicAnimState[client] = st;
    g_fSonicAnimLock[client] = GetEngineTime() + 0.5;
    g_fSonicDodgeEnd[client] = GetEngineTime() + 0.5;
    g_fSonicDodgeCap[client] = GetEngineTime() + 1.2;   // v6.29: tope duro de la eva a completar
}

// Intento de dodge de un CONTROL: en bola es inmunidad gratis (D);
// en gracia también; si no, paga el coste en anillos y ABRE la
// gracia. Devuelve true si quedó esquivado (caller: Plugin_Handled).
bool Sonic_TryControlDodge(int client, int cost, const char[] label)
{
    if (!Sonic_IsValidClient(client) || !IsPlayerAlive(client)) return false;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return false;

    // (D) en bola/picoada NO entra ningún control, sin coste
    if (g_cvSonicSpinGrabGuard != null && g_cvSonicSpinGrabGuard.BoolValue
        && Sonic_SpinGuardActive(client))
        return true;

    // (G) gracia 1.5s del dodge anterior: gratis (menos vómito/spit,
    // que se filtran antes de llamar aquí)
    if (Sonic_DodgeGraceActive(client)) return true;

    if (g_cvSonicDodge == null || !g_cvSonicDodge.BoolValue) return false;
    if (cost <= 0 || g_iSonicRings[client] < cost) return false;

    g_iSonicRings[client] -= cost;
    Sonic_PlayDodgeAnim(client);
    g_fSonicDodgeGraceUntil[client] = GetEngineTime() + g_cvSonicDodgeGrace.FloatValue;
    g_fSonicDotGraceUntil[client]  = GetEngineTime() + g_cvSonicDodgeGraceDot.FloatValue;   // v6.6 (7)
    g_fSonicDodgePaidAt[client]    = GetEngineTime();   // v6.6 (9): anti doble cobro
    PrintHintText(client, "ESQUIVADO: %s (-%d anillos)", label, cost);
    g_fSonicRingsHUDNext[client] = GetEngineTime() + 0.75;
    return true;
}

// ---- Guards por fuente (los llaman los forwards compartidos) ----

// Lengua del smoker (L4D_OnGrabWithTongue — lo engancha Knuckles.inc)
bool Sonic_TongueGuard(int victim)
{
    if (!Sonic_IsValidClient(victim)) return false;
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return false;
    return Sonic_TryControlDodge(victim, g_cvSonicDodgeTongue.IntValue, "lengua del smoker");
}

// Pounce del hunter (forward propio de sonic.inc)
bool Sonic_PounceGuard(int victim)
{
    if (!Sonic_IsValidClient(victim)) return false;
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return false;
    return Sonic_TryControlDodge(victim, g_cvSonicDodgeHunter.IntValue, "pounce del hunter");
}

// Jockey (forward propio de sonic.inc)
bool Sonic_JockeyGuard(int victim)
{
    if (!Sonic_IsValidClient(victim)) return false;
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return false;
    return Sonic_TryControlDodge(victim, g_cvSonicDodgeJockey.IntValue, "agarre del jockey");
}

// Carry del charger (L4D2_OnStartCarryingVictim — Knuckles.inc)
bool Sonic_ChargerGuard(int victim)
{
    if (!Sonic_IsValidClient(victim)) return false;
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return false;
    return Sonic_TryControlDodge(victim, g_cvSonicDodgeCharger.IntValue, "carry del charger");
}

// Slam del charger contra la pared (L4D2_OnSlammedSurvivor — Knuckles.inc;
// el "incluyendo el tropiezo" de la tabla del owner)
bool Sonic_ChargerSlamGuard(int victim)
{
    if (!Sonic_IsValidClient(victim)) return false;
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return false;
    return Sonic_TryControlDodge(victim, g_cvSonicDodgeCharger.IntValue, "slam del charger");
}

// Empujon del motor (L4D2_OnPlayerFling — Knuckles.inc): puño/roca de
// tank y embestida de charger. En bola/gracia gratis; fuera de ellas
// se bloquea SOLO si el dano que lo acompana se va a absorber con
// anillos (tank: queda bolsa; charger: coste completo).
bool Sonic_FlingGuard(int client, int attacker)
{
    if (!Sonic_IsValidClient(client) || !IsPlayerAlive(client)) return false;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return false;

    if (g_cvSonicSpinGrabGuard != null && g_cvSonicSpinGrabGuard.BoolValue
        && Sonic_SpinGuardActive(client))
        return true;                       // (D) el tank no mueve a la bola
    if (Sonic_DodgeGraceActive(client)) return true;
    // v6.30: la evasión ACTIVA (la ventana Dodge1-4 de 0.5s) tampoco
    // admite empujones del motor — cubre el dodge del vómito, que
    // abre la gracia corta de 0.3s pero NO la de 1.5s (pedido del
    // owner: "la evasión evitara el stun del tank")
    if (GetEngineTime() < g_fSonicDodgeEnd[client]) return true;

    if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker)
        && GetClientTeam(attacker) == 3)
    {
        int zc = GetEntProp(attacker, Prop_Send, "m_zombieClass");
        if (zc == 8)
            return (g_cvSonicRings.BoolValue && g_iSonicRings[client] > 0);  // el dano paga lo que entre
        if (zc == 6)
            return Sonic_TryControlDodge(client, g_cvSonicDodgeCharger.IntValue, "embestida del charger");
    }
    return false;
}

// Stagger del motor (L4D2_OnStagger_Post — Tails.inc): en bola o en
// gracia se CANCELA al instante (puño/roca de tank, impacto charger).
void Sonic_StaggerGuard(int client)
{
    if (!Sonic_IsValidClient(client) || !IsPlayerAlive(client)) return;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return;
    if (!Sonic_SpinGuardActive(client) && !Sonic_DodgeGraceActive(client)) return;

    if (GetFeatureStatus(FeatureType_Native, "L4D_CancelStagger") == FeatureStatus_Available)
        L4D_CancelStagger(client);
}

// v6.30 (pedido del owner 2026-10-09): la ROCA del tank no tumba a
// Sonic mientras dura la evasión ni el spindash — "la evasión evitara
// el stun del tank y el stun de la roca del mismo y también el
// spindash (ya que como dije no tiene sentido que lo aturdan en
// spindash)". Lo engancha el L4D_OnKnockedDown del manager con la
// receta del l4d_block_stumble 2.1 de Silvers (forward reason
// KNOCKDOWN_TANK = la roca). Ventanas: la evasión ACTIVA (0.5s,
// incluye la del vómito, que no abre gracia) + la gracia de 1.5s
// ("inmune a controles") + la bola con la MISMA palanca del "el tank
// empuja" (sonicom_spin_grabguard, default 1). El daño (bola
// invulnerable / gracia), el fling del puño (FlingGuard) y el stagger
// (StaggerGuard) ya estaban cubiertos — esta era la pieza que faltaba.
bool Sonic_TankKnockImmune(int client)
{
    if (!Sonic_IsValidClient(client) || !IsPlayerAlive(client)) return false;
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return false;

    float now = GetEngineTime();
    if (now < g_fSonicDodgeEnd[client]) return true;    // eva activa
    if (Sonic_DodgeGraceActive(client)) return true;     // gracia 1.5s
    if (g_cvSonicSpinGrabGuard != null && g_cvSonicSpinGrabGuard.BoolValue
        && g_iSonicSpinPhase[client] != SONIC_SPIN_NONE) return true;  // bola
    return false;
}

// (H) Vómito del boomer (spray o explosión — L4D_OnVomitedUpon en
// Knuckles.inc): Sonic JAMÁS queda ciego. Con anillos lo esquiva
// entero (paga; SIN gracia — la tabla del owner deja el vómito fuera
// de ella). Sin anillos la bilis cae pero se LIMPIA al instante
// (m_itTimer expirado — cleanup estilo Poppy, fuera del hook).
bool Sonic_VomitDodge(int victim, bool boomerExplosion)
{
    if (!Sonic_IsValidClient(victim) || !IsPlayerAlive(victim)) return false;
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return false;

    // v6.6 (7): gracia corta post-dodge — la bilis NO vuelve a cobrar
    // (la ventana de 0.3s cubre el re-spray del boomer)
    if (Sonic_DotGraceActive(victim)) return true;

    int cost = boomerExplosion ? g_cvSonicDodgeBoom.IntValue
                               : g_cvSonicDodgeVomit.IntValue;

    if (g_cvSonicDodge.BoolValue && cost > 0 && g_iSonicRings[victim] >= cost)
    {
        g_iSonicRings[victim] -= cost;
        Sonic_PlayDodgeAnim(victim);
        // SIN gracia de 1.5s: el vómito no la abre (regla del owner);
        // PERO SI abre la corta de 0.3s (v6.6 7)
        g_fSonicDotGraceUntil[victim] = GetEngineTime() + g_cvSonicDodgeGraceDot.FloatValue;
        g_fSonicDodgePaidAt[victim]   = GetEngineTime();
        PrintHintText(victim, "ESQUIVADO: %s (-%d anillos)",
                      boomerExplosion ? "explosión del boomer" : "vómito del boomer", cost);
        g_fSonicRingsHUDNext[victim] = GetEngineTime() + 0.75;
        return true;    // Plugin_Handled: bloqueado ENTERO
    }

    // sin anillos: la bilis aplica y se retira ya (delay 0.1s fuera
    // del hook del vómito — misma lección v70 de Amy: nunca mutar
    // estado del motor dentro de OnVomitedUpon)
    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(victim));
    CreateTimer(0.1, T_SonicVomitClean, dp, TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
    return false;
}

public Action T_SonicVomitClean(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = GetClientOfUserId(pack.ReadCell());
    if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client)
        && g_iPlayerCharIdx[client] == SONIC_INDEX)
    {
        // m_itTimer a pasado = el motor ve el IT (bilis) EXPIRADO y
        // retira el efecto de pantalla/al atracción de comunes solo
        if (HasEntProp(client, Prop_Send, "m_itTimer"))
            SetEntPropFloat(client, Prop_Send, "m_itTimer", GetGameTime() - 0.5);
    }
    return Plugin_Stop;
}

// ---- Forwards propios de sonic.inc (nadie más los define) ----

// v6.6 (9): RED DE SEGURIDAD POR NETPROPS — el owner reporto que la
// eva NO esquivaba lengua/hunter/jockey ("el spindash si pero la eva
// no"): si el forward pre del left4dhooks del servidor no bloqueo (o
// no existe en su versión), el agarre APLICA y aquí lo cazamos al
// tick siguiente: en bola/gracia se ROMPE gratis; con anillos se
// paga la tabla del owner y se rompe también. Ventana de 0.75s anti
// doble cobro (forward + esta red = un solo pago).
void Sonic_GrabDodgePreThink(int client, int tongue, int pounce, int jockey, int carry)
{
    int src = -1;         // 0 lengua / 1 hunter / 2 jockey / 3 charger
    int attacker = -1;
    if (tongue > 0)      { src = 0; attacker = tongue; }
    else if (pounce > 0) { src = 1; attacker = pounce; }
    else if (jockey > 0) { src = 2; attacker = jockey; }
    else if (carry > 0)  { src = 3; attacker = carry; }
    else return;

    bool dodged = false;
    if (Sonic_SpinGuardActive(client)) dodged = true;        // bola: gratis
    else if (Sonic_DodgeGraceActive(client)) dodged = true;  // gracia: gratis
    else if (Sonic_DotGraceActive(client)) dodged = true;    // re-spray inmediato
    else if (GetEngineTime() - g_fSonicDodgePaidAt[client] < 0.75) dodged = true;  // ya pago este agarre
    else
    {
        int cost = (src == 0) ? g_cvSonicDodgeTongue.IntValue
                : (src == 1) ? g_cvSonicDodgeHunter.IntValue
                : (src == 2) ? g_cvSonicDodgeJockey.IntValue
                : g_cvSonicDodgeCharger.IntValue;
        if (g_cvSonicDodge.BoolValue && cost > 0 && g_iSonicRings[client] >= cost)
        {
            g_iSonicRings[client] -= cost;
            g_fSonicDodgePaidAt[client]   = GetEngineTime();
            g_fSonicDodgeGraceUntil[client] = GetEngineTime() + g_cvSonicDodgeGrace.FloatValue;
            g_fSonicDotGraceUntil[client]  = GetEngineTime() + g_cvSonicDodgeGraceDot.FloatValue;
            Sonic_PlayDodgeAnim(client);
            static const char sGrabLabels[4][22] = {
                "lengua del smoker", "pounce del hunter",
                "agarre del jockey", "carry del charger" };
            PrintHintText(client, "ESQUIVADO: %s (-%d anillos)", sGrabLabels[src], cost);
            g_fSonicRingsHUDNext[client] = GetEngineTime() + 0.75;
            dodged = true;
        }
    }
    if (!dodged) return;   // sin anillos: el agarre pega de verdad

    // ROMPER el agarre (receta DollSys_CleanseGrapples): liberar a
    // AMBOS lados del vinculo, uno por uno
    switch (src)
    {
        case 0:
        {
            if (attacker > 0 && IsValidEntity(attacker) && HasEntProp(attacker, Prop_Send, "m_tongueVictim"))
                SetEntPropEnt(attacker, Prop_Send, "m_tongueVictim", -1);
            SetEntPropEnt(client, Prop_Send, "m_tongueOwner", -1);
        }
        case 1:
        {
            if (attacker > 0 && IsValidEntity(attacker) && HasEntProp(attacker, Prop_Send, "m_pounceVictim"))
                SetEntPropEnt(attacker, Prop_Send, "m_pounceVictim", -1);
            SetEntPropEnt(client, Prop_Send, "m_pounceAttacker", -1);
        }
        case 2:
        {
            if (attacker > 0 && IsValidEntity(attacker) && HasEntProp(attacker, Prop_Send, "m_jockeyVictim"))
                SetEntPropEnt(attacker, Prop_Send, "m_jockeyVictim", -1);
            SetEntPropEnt(client, Prop_Send, "m_jockeyAttacker", -1);
        }
        case 3:
        {
            if (attacker > 0 && IsValidEntity(attacker) && HasEntProp(attacker, Prop_Send, "m_carryVictim"))
                SetEntPropEnt(attacker, Prop_Send, "m_carryVictim", -1);
            SetEntPropEnt(client, Prop_Send, "m_carryAttacker", -1);
        }
    }
    SetEntityMoveType(client, MOVETYPE_WALK);

    // v6.8 (informe 3): avisarle al JUEGO (y a su música) que el agarre
    // termino — sin el evento, el loop de música de la montura del
    // jockey sigue sonando para siempre aunque el ride ya no exista.
    // Se dispara DESPUÉS de la limpieza, como hace el motor de verdad.
    Sonic_FireGrabEndEvents(src, client, attacker);

    // al hunter y al jockey (pegados al cuerpo) se los empuja para
    // atras: que no re-agarren en la misma cara
    if ((src == 1 || src == 2) && attacker > 0 && attacker <= MaxClients
        && IsClientInGame(attacker) && IsPlayerAlive(attacker))
    {
        float sPos[3], aPos[3], dir[3];
        GetClientAbsOrigin(client, sPos);
        GetClientAbsOrigin(attacker, aPos);
        MakeVectorFromPoints(sPos, aPos, dir);
        dir[2] = 0.0;
        if (NormalizeVector(dir, dir) > 0.1)
        {
            ScaleVector(dir, 420.0);
            dir[2] = 260.0;
            TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, dir);
        }
    }
}

// v6.8 (informe 3 — "cuando esquivo la montura se termina si, pero
// la música empieza a sonar y no se detiene"): al cortar el vinculo
// por netprops, el camino del motor (OnJockeyRideEnd) NUNCA corre —
// el juego no dispara su evento de fin y el music-cue de "siendo
// montado" queda sonando en LOOP para la victima. Receta: disparar
// NOSOTROS el game event que el motor suelta al terminar de verdad
// (jockey_ride_end: userid = jockey + victim = survivor — mismo
// formato que jockey_ride). Idem hunter con pounce_end (userid):
// prevención del mismo bug latente en el pin.
void Sonic_FireGrabEndEvents(int src, int victim, int attacker)
{
    if (victim <= 0 || victim > MaxClients) return;
    if (attacker <= 0 || attacker > MaxClients) return;
    if (!IsClientInGame(victim) || !IsClientInGame(attacker)) return;

    switch (src)
    {
        case 1:   // pounce del hunter
        {
            Event ev = CreateEvent("pounce_end", true);
            if (ev != null)
            {
                ev.SetInt("userid", GetClientUserId(attacker));
                ev.Fire();
            }
        }
        case 2:   // montura del jockey (el loop de música reportado)
        {
            Event ev = CreateEvent("jockey_ride_end", true);
            if (ev != null)
            {
                ev.SetInt("userid", GetClientUserId(attacker));
                ev.SetInt("victim", GetClientUserId(victim));
                ev.Fire();
            }
        }
    }
}

// Pounce del hunter: la esquiva lo bloquea ANTES de aplicarse (sin
// mini-pounce de 1 tick). En bola es inmunidad directa (D).
// v3.77.28 (Metal v5.3): el hunter TAMPOCO ensarta a un Metal en plena
// embestida — este es el forward REAL (el guard de la 3.77.27 vivía en
// un "L4D_OnPouncedOnSurvivor_Pre" fantasma que nunca corria). De paso
// reviven las contras de Amy/Knuckles que el fantasma cableaba (las
// mismas funciones que ya corrian en el carry del charger).
public Action L4D_OnPouncedOnSurvivor(int victim, int attacker)
{
    if (Sonic_PounceGuard(victim)) return Plugin_Handled;
    // v5.2-OM (Eggman): el doctor es INMUNE a agarres DE POR SI (como
    // Metal Sonic en si) — "si es agarrado, el especial recibe el stun
    // directamente y liberara al doctor" (la capa de CURA vive en
    // Eggman_CheckGrabCure del GameplayTick de Eggman)
    if (g_iPlayerCharIdx[victim] == EGGMAN_INDEX && Eggman_ControlImmune(victim)) return Plugin_Handled;
    if (g_iPlayerCharIdx[victim] == METALSONIC_INDEX && Metal_ControlImmune(victim)) return Plugin_Handled;
    if (g_iPlayerCharIdx[victim] == AMY_INDEX && Amy_GrabCounter(victim, attacker)) return Plugin_Handled;
    if (Knuckles_CheckSpecialCounter(victim, attacker)) return Plugin_Handled;
    // v2.1 Kolossos: el bloqueo detecta la pounce AL INSTANTE — el
    // ensarte nunca engancha y el hunter sale contraado
    if (Kolossos_PlayerIs(victim) && Kolossos_BlockActive(victim))
    {
        Kolossos_BlockEnd(victim);
        Kolossos_BlockCounter(victim, attacker, attacker);
        PrintCenterText(victim, "BLOQUEO! Pounce roto al instante");
        return Plugin_Handled;
    }
    // v3.77.46 (Rouge v10.1): counter pleno o EVA del pounce
    if (g_iPlayerCharIdx[victim] == ROUGE_INDEX)
    {
        if (Rouge_Countering(victim) && Rouge_SpecialCounter(victim, attacker)) return Plugin_Handled;
        if (Rouge_EvadeControl(victim, attacker, "pounce del hunter")) return Plugin_Handled;
    }
    return Plugin_Continue;
}

// Jockey: idem — bloqueado antes de montar.
public Action L4D2_OnJockeyRide(int victim, int attacker)
{
    if (Sonic_JockeyGuard(victim)) return Plugin_Handled;
    // v3.77.28 (Metal v5.3): el jockey no monta a un Metal en embestida
    // (forward real) + contras Amy/Knuckles revividas del fantasma.
    // v5.2-OM (Eggman): el doctor es INMUNE a agarres DE POR SI (como
    // Metal Sonic en si) — "si es agarrado, el especial recibe el stun
    // directamente y liberara al doctor" (la capa de CURA vive en
    // Eggman_CheckGrabCure del GameplayTick de Eggman)
    if (g_iPlayerCharIdx[victim] == EGGMAN_INDEX && Eggman_ControlImmune(victim)) return Plugin_Handled;
    if (g_iPlayerCharIdx[victim] == METALSONIC_INDEX && Metal_ControlImmune(victim)) return Plugin_Handled;
    if (g_iPlayerCharIdx[victim] == AMY_INDEX && Amy_GrabCounter(victim, attacker)) return Plugin_Handled;
    if (Knuckles_CheckSpecialCounter(victim, attacker)) return Plugin_Handled;
    // v2.1 Kolossos: el bloqueo detecta la monta AL INSTANTE — el jockey
    // nunca se sube y sale contraado ("por si acaso")
    if (Kolossos_PlayerIs(victim) && Kolossos_BlockActive(victim))
    {
        Kolossos_BlockEnd(victim);
        Kolossos_BlockCounter(victim, attacker, attacker);
        PrintCenterText(victim, "BLOQUEO! Jockey rechazado al instante");
        return Plugin_Handled;
    }
    // v3.77.46 (Rouge v10.1): counter pleno o EVA del agarre
    if (g_iPlayerCharIdx[victim] == ROUGE_INDEX)
    {
        if (Rouge_Countering(victim) && Rouge_SpecialCounter(victim, attacker)) return Plugin_Handled;
        if (Rouge_EvadeControl(victim, attacker, "agarre del jockey")) return Plugin_Handled;
    }
    return Plugin_Continue;
}

// v6.5 (B): filtro del desliz de la witch (el trace solo ve el mundo).
public bool Sonic_WitchSlideFilter(int entity, int contentsMask, int data)
{
    if (entity == data) return false;
    if (entity > 0 && entity <= MaxClients) return false;
    char cls[16];
    if (GetEntityClassname(entity, cls, sizeof(cls)))
    {
        if (StrEqual(cls, "infected") || StrEqual(cls, "witch")) return false;
    }
    return true;
}

// =====================================================================
// PRETHINK v5.4 (INTACTO) + integración OM
// =====================================================================
public void Sonic_PreThink(int client)
{
    if (g_iPlayerCharIdx[client] != SONIC_INDEX || !Sonic_IsValidClient(client) || !IsPlayerAlive(client)) return;

    float now = GetEngineTime();

    // v6.14: arrastre de los pasajeros del peel — POR FRAME (a 800 u/s
    // el think de 10 Hz de la FSM haría saltos visibles de 80u). Corre
    // antes de las ramas de agarre/incap para que la carrera siga
    // sincronizada aunque ese frame toque una de esas salidas.
    Sonic_PeelCarryPreThink(client);

    // v6.6 (9): detección de agarres POR NETPROP (funciona aunque el
    // forward del left4dhooks del servidor no bloquee): incap corta el
    // homing como siempre; un agarre entra a la red de esquiva
    bool bIncap = GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0;
    int grabTongue = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
    int grabPounce = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
    int grabJockey = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
    int grabCarry  = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
    if (bIncap || grabTongue > 0 || grabPounce > 0 || grabJockey > 0 || grabCarry > 0)
    {
        if (g_bSonicHoming[client]) Sonic_CancelHoming(client);
        if (!bIncap)
            Sonic_GrabDodgePreThink(client, grabTongue, grabPounce, grabJockey, grabCarry);
        Sonic_OM_PreThink(client);
        return;
    }

    // ==========================================
    // LÓGICA DE AUTO-GUIADO DEL HOMING ATTACK (v5.4)
    // ==========================================
    if (g_bSonicHoming[client])
    {
        int target = g_iSonicTarget[client];

        bool valid = false;
        if (target > 0 && IsValidEntity(target))
        {
            if (target <= MaxClients) { if (IsClientInGame(target) && IsPlayerAlive(target)) valid = true; }
            else
            {
                valid = (GetEntProp(target, Prop_Data, "m_iHealth") > 0);
            }
        }

        if (!valid)
        {
            int newTarget = Sonic_ScanHomingTarget(client, SONIC_HOMING_REACQ_RANGE, SONIC_HOMING_REACQ_CONE);
            if (newTarget != -1)
            {
                g_iSonicTarget[client] = newTarget;
                target = newTarget;
                valid = true;
                if (g_fSonicDashTime[client] < now + 0.6)
                    g_fSonicDashTime[client] = now + 0.6;
                EmitSoundToClient(client, "mobius/sfx/spring.mp3", _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.5);
                PrintCenterText(client, "[*] HOMING RE-DIRIGIDO!");
            }
        }

        if (!valid || now > g_fSonicDashTime[client])
        {
            Sonic_CancelHoming(client);
            Sonic_OM_PreThink(client);
            return;
        }

        float sPos[3], tPos[3];
        GetClientAbsOrigin(client, sPos);

        if (target <= MaxClients) GetClientAbsOrigin(target, tPos);
        else GetEntPropVector(target, Prop_Data, "m_vecOrigin", tPos);

        tPos[2] += 40.0;
        sPos[2] += 20.0;

        float dist = GetVectorDistance(sPos, tPos);

        if (dist <= 110.0)
        {
            Sonic_PerformHomingImpact(client, target, tPos);
        }
        else
        {
            float flightSpeed = SONIC_HOMING_FLIGHT_SPEED;
            if (g_iSonicChainCount[client] > 0)
                flightSpeed += SONIC_HOMING_CHAIN_BONUS;

            float vel[3];
            MakeVectorFromPoints(sPos, tPos, vel);
            NormalizeVector(vel, vel);
            ScaleVector(vel, flightSpeed);

            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
        }

        g_iSonicLastButtons[client] = GetClientButtons(client);
        return;
    }

    // ==========================================
    // v5.4: CADENA DE HOMING (ventana / aterrizaje)
    // ==========================================
    if (g_iSonicChainCount[client] > 0 && now > g_fSonicChainWindowEnd[client])
    {
        g_iSonicChainCount[client] = 0;
        g_fSonicChainWindowEnd[client] = 0.0;
        if (now + SONIC_HOMING_CHAIN_CD > g_fSonicActionCD[client])
            g_fSonicActionCD[client] = now + SONIC_HOMING_CHAIN_CD;
    }

    // ==========================================
    // INSTA SHIELD & JUMP CORE (v5.4)
    // OM: bloqueado mientras dura la bola/picoada (GMod: en bola no
    // hay salto normal) — el doble salto vuelve al terminar la fase.
    // ==========================================
    int flags = GetEntityFlags(client);
    int buttons = GetClientButtons(client);

    if ((flags & FL_ONGROUND) || GetEntityMoveType(client) == MOVETYPE_LADDER) {
        g_iSonicJumps[client] = 0;
        if (g_iSonicChainCount[client] > 0 && (flags & FL_ONGROUND))
        {
            g_iSonicChainCount[client] = 0;
            g_fSonicChainWindowEnd[client] = 0.0;
        }
    } else {
        bool bNewAirJump = ((buttons & IN_JUMP) && !(g_iSonicLastButtons[client] & IN_JUMP));

        if (bNewAirJump && g_iSonicJumps[client] == 0
            && g_iSonicSpinPhase[client] == SONIC_SPIN_NONE)
        {
            g_iSonicJumps[client] = 1;

            if (now > g_fSonicAirDashNext[client])
            {
                g_fSonicAirDashNext[client] = now + SONIC_AIR_DASH_CD;

                float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
                float jumpV = 250.0;
                vel[2] = (vel[2] < 0.0) ? jumpV : (vel[2] + jumpV);

                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
                float pos[3];
                GetClientAbsOrigin(client, pos);

                EmitSoundToAll("mobius/sfx/spring.mp3", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.25);
                PrintCenterText(client, "[+] INSTA-SHIELD ACTIVO!");

                TE_SetupBeamRingPoint(pos, 10.0, 180.0, g_iSonicGlowSprite, g_iSonicGlowSprite, 0, 15, 0.2, 5.0, 1.0, {150, 200, 255, 180}, 0, 0);
                TE_SendToAll();

                Sonic_ApplyAreaStagger(client, pos, 180.0, 450.0);
            }
        }
    }
    g_iSonicLastButtons[client] = buttons;

    // ===== OM: movimiento forzado de las fases (bola/peel/windup) =====
    Sonic_OM_PreThink(client);
}

// Limpia el estado de vuelo del homing (v5.4)
// v6.5 (F): fallar/cancelar TAMBIÉN devuelve el cuerpo (la bola se
// retira y el avatar vuelve a ser visible) y arranca el 1s anti-spam.
void Sonic_CancelHoming(int client)
{
    bool hadBall = (g_iSonicBall[client] != 0);
    g_bSonicHoming[client] = false;
    g_iSonicTarget[client] = -1;
    if (IsClientInGame(client))
    {
        SetEntityMoveType(client, MOVETYPE_WALK);
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
        SetEntProp(client, Prop_Send, "m_CollisionGroup", 5);
        if (hadBall && g_iSonicSpinPhase[client] == SONIC_SPIN_NONE
            && IsPlayerAlive(client))
        {
            Sonic_KillBall(client);
            Sonic_ShowAvatarAfterBall(client);
        }
    }
    g_fSonicHomingNext[client] = GetEngineTime() + 1.0;
}

// v6.5 (F): el burst (homing sin objetivo) dura 0.4s — la bola se
// retira sola al acabar (salvo que empezara un homing/bola de verdad).
public Action T_SonicHomingBurstRestore(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
    {
        if (g_bSonicHoming[client]) return Plugin_Stop;              // paso a homing
        if (g_iSonicSpinPhase[client] != SONIC_SPIN_NONE) return Plugin_Stop;  // bola real
        Sonic_KillBall(client);
        Sonic_ShowAvatarAfterBall(client);
    }
    return Plugin_Stop;
}

// =======================
// COMBATE CONTACTO: BOLA OM (nuevo) + SPIN DASH v5.4 (ventana del burst)
// =======================
public Action Sonic_OnTouch(int client, int other)
{
    if (g_iPlayerCharIdx[client] != SONIC_INDEX) return Plugin_Continue;

    float now = GetEngineTime();

    // OM: la BOLA golpea todo lo que toca mientras rueda
    if (g_iSonicSpinPhase[client] == SONIC_SPIN_ROLL
        && other > 0 && IsValidEntity(other))
    {
        Sonic_OM_RollHit(client, other, now);
        return Plugin_Continue;
    }

    // v5.4: ventana del Spin Dash burst (sin homing)
    if (!g_bSonicHoming[client] && now < g_fSonicDashTime[client] && other > 0 && IsValidEntity(other))
    {
        char targetCls[32]; GetEntityClassname(other, targetCls, sizeof(targetCls));
        bool SpecCheck = (other <= MaxClients && IsClientInGame(other) && GetClientTeam(other) == 3);
        bool wtCheck = StrEqual(targetCls, "witch");
        bool ctCheck = StrEqual(targetCls, "infected");

        if (SpecCheck || wtCheck || ctCheck)
        {
            float targetPos[3];
            if (SpecCheck) GetClientAbsOrigin(other, targetPos); else GetEntPropVector(other, Prop_Send, "m_vecOrigin", targetPos);

            float fDashHitAng[3]; GetClientEyeAngles(client, fDashHitAng);
            GetAngleVectors(fDashHitAng, fDashHitAng, NULL_VECTOR, NULL_VECTOR);
            ScaleVector(fDashHitAng, 800.0); fDashHitAng[2] += 400.0;

            float dmg = (SpecCheck ? 150.0 : 400.0);
            OM_AbilityDamage(other, client, dmg, DMG_CRUSH);

            if (SpecCheck || wtCheck) {
               if (SpecCheck) {
                   SIStagger_Auto(other, client, targetPos);
                   TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, fDashHitAng);
               }
               if (wtCheck) {
                   WitchFlight_Launch(other, client, fDashHitAng);
                   WitchFlight_CheckDead(other);
               }
            } else {
                float fBodP[3]; fBodP[0] = fDashHitAng[0]*2.0; fBodP[1] = fDashHitAng[1]*2.0; fBodP[2] = 800.0;
                TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, fBodP);
            }

            float sRcd[3]; GetClientEyeAngles(client, sRcd); GetAngleVectors(sRcd, sRcd, NULL_VECTOR, NULL_VECTOR);
            sRcd[0] *= -450.0; sRcd[1] *= -450.0; sRcd[2] = 550.0;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, sRcd);

            g_fSonicDashTime[client] = 0.0;
            EmitSoundToAll("mobius/sfx/spring.mp3", client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.4);
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}

// =======================
// v5.4: ESCANEO DE OBJETIVOS DEL HOMING (LOS / cono / rango)
// =======================
public bool Sonic_TraceFilter_HomingLos(int entity, int contentsMask, int data)
{
    if (entity == data) return false;
    if (entity > 0 && entity <= MaxClients) return false;

    char cls[32];
    if (GetEntityClassname(entity, cls, sizeof(cls)))
    {
        if (StrEqual(cls, "infected"))  return false;
        if (StrEqual(cls, "witch"))     return false;
        if (StrEqual(cls, "tank_rock")) return false;
        if (StrEqual(cls, "prop_physics") || StrEqual(cls, "prop_physics_multiplayer")) return false;
    }
    return true;
}

bool Sonic_HasHomingLos(int client, const float startPos[3], const float endPos[3])
{
    Handle trace = TR_TraceRayFilterEx(startPos, endPos, MASK_SOLID, RayType_EndPoint, Sonic_TraceFilter_HomingLos, client);
    bool blocked = TR_DidHit(trace);
    delete trace;
    return !blocked;
}

int Sonic_ScanHomingTarget(int client, float range, float dotMin)
{
    float eyePos[3], eyeAng[3], fwd[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);
    GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);

    int bestTarget = -1;
    float bestDist = range;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float targetEPos[3]; GetClientAbsOrigin(i, targetEPos); targetEPos[2] += 40.0;
            float currentDistCheck = GetVectorDistance(eyePos, targetEPos);
            if (currentDistCheck < bestDist) {
                float targetLockVectorDir[3]; MakeVectorFromPoints(eyePos, targetEPos, targetLockVectorDir); NormalizeVector(targetLockVectorDir, targetLockVectorDir);
                if (GetVectorDotProduct(fwd, targetLockVectorDir) > dotMin) {
                    if (Sonic_HasHomingLos(client, eyePos, targetEPos))
                    {
                        bestDist = currentDistCheck;
                        bestTarget = i;
                    }
                }
            }
        }
    }

    int nEntWitch = -1;
    while ((nEntWitch = FindEntityByClassname(nEntWitch, "witch")) != -1)
    {
        if (!IsValidEntity(nEntWitch)) continue;
        float witchT[3]; GetEntPropVector(nEntWitch, Prop_Send, "m_vecOrigin", witchT); witchT[2] += 40.0;
        float currWDist = GetVectorDistance(eyePos, witchT);
        if (currWDist < bestDist) {
            float witchWPDir[3]; MakeVectorFromPoints(eyePos, witchT, witchWPDir); NormalizeVector(witchWPDir, witchWPDir);
            if (GetVectorDotProduct(fwd, witchWPDir) > dotMin) {
                if (Sonic_HasHomingLos(client, eyePos, witchT))
                {
                    bestDist = currWDist;
                    bestTarget = nEntWitch;
                }
            }
        }
    }

    return bestTarget;
}

// =======================
// HOMING ATTACK (v5.4 intacto; vive en la tecla C ahora)
// =======================
public void HabilidadSonicSuperJump(int client)
{
    // v3.77.79: el host de modo solo es un cliente fake — dejarlo pasar
    if (!Sonic_IsValidClient(client) || !IsPlayerAlive(client) || (IsFakeClient(client) && !Sonic_IsSoloHost(client))) return;

    if (g_bSonicHoming[client]) return;

    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return;

    // OM: no mezclar el homing con las fases de bola/peel (GMod: la
    // bola bloquea el resto de habilidades)
    if (g_iSonicSpinPhase[client] != SONIC_SPIN_NONE) return;
    if (g_iSonicPeelPhase[client] != 0) return;

    float now = GetEngineTime();

    // v6.5 (F): 1s de bloqueo entre usos (anti-spam de pantalla y bola)
    if (now < g_fSonicHomingNext[client])
    {
        PrintCenterText(client, "Homing recargando... (%.1fs)", g_fSonicHomingNext[client] - now);
        return;
    }

    bool inChainWindow = (g_iSonicChainCount[client] > 0
                          && g_iSonicChainCount[client] <= SONIC_HOMING_CHAIN_MAX
                          && now < g_fSonicChainWindowEnd[client]);

    if (now < g_fSonicActionCD[client] && !inChainWindow)
    {
        PrintCenterText(client, "Ataques Enfriandose... (%.1f segs restantes)", g_fSonicActionCD[client] - now);
        return;
    }

    int bestTarget;
    if (inChainWindow)
        bestTarget = Sonic_ScanHomingTarget(client, SONIC_HOMING_CHAIN_RANGE, SONIC_HOMING_CHAIN_CONE);
    else
        bestTarget = Sonic_ScanHomingTarget(client, 1620.0, 0.82);

    if (bestTarget != -1)
    {
        if (!inChainWindow)
            g_fSonicActionCD[client] = now + 4.5;
        g_fSonicHomingNext[client] = now + 1.0;   // v6.5 (F): 1s entre usos
        g_bSonicHoming[client] = true;
        g_iSonicTarget[client] = bestTarget;
        g_fSonicDashTime[client] = now + SONIC_HOMING_FLIGHT_TIME;

        // v6.5 (F): mismo truco del spin — Sonic queda INVISIBLE y
        // la ESFERA viaja por el hasta el impacto (o la cancelación)
        Sonic_CreateBall(client);

        Sonic_ResetFallVelocity(client);

        SetEntityMoveType(client, MOVETYPE_FLY);
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 2);
        SetEntProp(client, Prop_Send, "m_CollisionGroup", 2);

        EmitSoundToAll("mobius/sfx/spring.mp3", client);
        if (inChainWindow)
        {
            PrintCenterText(client, "[*] HOMING CHAIN x%d!", g_iSonicChainCount[client] + 1);
            EmitSoundToAll("mobius/sfx/spring.mp3", client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.5);
            TE_SetupBeamFollow(client, g_iSonicBeamSprite, 0, 0.4, 6.0, 6.0, 0, {255, 215, 0, 200}); TE_SendToAll();
        }
        else
        {
            PrintCenterText(client, "[*] HOMING ATTACK FIJADO AL OBJETIVO!");
            TE_SetupBeamFollow(client, g_iSonicBeamSprite, 0, 0.4, 5.0, 5.0, 0, {200, 200, 255, 190}); TE_SendToAll();
        }
    }
    else if (inChainWindow)
    {
        PrintCenterText(client, "[ ] Sin objetivo para encadenar...");
    }
    else
    {
        // NO HAY TARGET - SPIN DASH BURST (v5.4)
        g_fSonicActionCD[client] = now + 8.0;
        g_fSonicHomingNext[client] = now + 1.0;   // v6.5 (F): 1s entre usos
        g_bSonicHoming[client] = false;
        g_fSonicDashTime[client] = now + 0.4;

        // v6.5 (F): el burst también sale en bola (es un spin dash) y
        // se retira solo al acabar su ventana de 0.4s
        Sonic_CreateBall(client);
        CreateTimer(0.45, T_SonicHomingBurstRestore, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

        float baseVelSpindsh[3];
        float fwd[3], eyeAng[3];
        GetClientEyeAngles(client, eyeAng);
        GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);
        baseVelSpindsh = fwd;
        ScaleVector(baseVelSpindsh, 2000.0);
        baseVelSpindsh[2] = (baseVelSpindsh[2] < 200.0) ? 200.0 : baseVelSpindsh[2];

        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, baseVelSpindsh);
        EmitSoundToAll("mobius/sfx/boom.mp3", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.85);
        PrintCenterText(client, "[*] SPIN DASH BURST!");

        float pPos[3]; GetClientAbsOrigin(client, pPos);
        Sonic_ApplyAreaStagger(client, pPos, 300.0, 600.0);
        TE_SetupBeamFollow(client, g_iSonicGlowSprite, 0, 0.8, 12.0, 8.0, 0, {0, 0, 255, 180}); TE_SendToAll();
    }
}

// IMPACTO Y RETROCESO FLOTANTE DEL HOMING (v5.4)
void Sonic_PerformHomingImpact(int attacker, int victim, float targetPos[3])
{
    float now = GetEngineTime();

    bool isWitch = false;
    char cls[32];
    if (victim > MaxClients) {
        GetEntityClassname(victim, cls, sizeof(cls));
        if (StrEqual(cls, "witch")) isWitch = true;
    }

    if (!isWitch)
    {
        // v6.5 (F): el homing YA NO EJECUTA al tank — si el golpe lo
        // mataría, se recorta para dejarle 1 HP (el golpe de gracia
        // lo pone otra habilidad)
        float hdmg = 200.0;
        if (victim <= MaxClients && IsClientInGame(victim)
            && GetEntProp(victim, Prop_Send, "m_zombieClass") == 8)
        {
            hdmg = float(GetClientHealth(victim) - 1);
            if (hdmg < 0.0) hdmg = 0.0;
            if (hdmg > 200.0) hdmg = 200.0;
        }
        if (hdmg > 0.0)
            OM_AbilityDamage(victim, attacker, hdmg, DMG_BLAST);
    }

    float sRcd[3]; GetClientEyeAngles(attacker, sRcd);
    GetAngleVectors(sRcd, sRcd, NULL_VECTOR, NULL_VECTOR);

    float pushFwd[3]; pushFwd = sRcd;
    ScaleVector(pushFwd, 800.0); pushFwd[2] += 400.0;

    if (victim <= MaxClients) {
        SIStagger_Auto(victim, attacker, targetPos);
        TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, pushFwd);
    } else if (isWitch) {
        WitchFlight_Launch(victim, attacker, pushFwd);
        OM_AbilityDamage(victim, attacker, 200.0, DMG_BLAST);
        WitchFlight_CheckDead(victim);
    }

    sRcd[0] *= -500.0;
    sRcd[1] *= -500.0;
    sRcd[2] = 450.0;

    Sonic_ResetFallVelocity(attacker);

    TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, sRcd);

    // v6.5 (F): impacto = Sonic reaparece (bola fuera, cuerpo visible)
    if (g_iSonicBall[attacker] != 0
        && g_iSonicSpinPhase[attacker] == SONIC_SPIN_NONE)
    {
        Sonic_KillBall(attacker);
        Sonic_ShowAvatarAfterBall(attacker);
    }

    g_bSonicHoming[attacker] = false;
    g_iSonicTarget[attacker] = -1;
    g_fSonicHomingNext[attacker] = now + 1.0;    // v6.5 (F): 1s entre usos

    g_iSonicChainCount[attacker]++;
    if (g_iSonicChainCount[attacker] > SONIC_HOMING_CHAIN_MAX)
    {
        g_iSonicChainCount[attacker] = 0;
        g_fSonicChainWindowEnd[attacker] = 0.0;
        g_fSonicActionCD[attacker] = now + 4.5;
        PrintCenterText(attacker, "[!] CADENA COMPLETADA (x%d)", SONIC_HOMING_CHAIN_MAX + 1);
    }
    else
    {
        g_fSonicChainWindowEnd[attacker] = now + SONIC_HOMING_CHAIN_WINDOW;
        PrintCenterText(attacker, "[*] ENCADENA! C para HOMING CHAIN x%d (%.1fs)",
                        g_iSonicChainCount[attacker] + 1,
                        g_fSonicChainWindowEnd[attacker] - now);
    }

    EmitSoundToAll("mobius/sfx/spring.mp3", attacker, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 1.4);

    CreateTimer(0.35, T_SonicRestorePhysics, GetClientUserId(attacker), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_SonicRestorePhysics(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client > 0 && IsClientInGame(client))
    {
        if (g_bSonicHoming[client]) return Plugin_Stop;

        SetEntityMoveType(client, MOVETYPE_WALK);
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
        SetEntProp(client, Prop_Send, "m_CollisionGroup", 5);
    }
    return Plugin_Stop;
}

// =======================
// SONIC WIND (v5.4; queda como comando sm_sonicwind)
// =======================
public Action Sonic_ActivateSonicWind_Passthrough(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    Sonic_ActivateSonicWind(client);
    return Plugin_Handled;
}

public void Sonic_ActivateSonicWind(int client)
{
    // v3.77.79: el host de modo solo es un cliente fake — dejarlo pasar
    if (!Sonic_IsValidClient(client) || !IsPlayerAlive(client) || (IsFakeClient(client) && !Sonic_IsSoloHost(client))) return;

    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0) return;
    if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0) return;

    float now = GetEngineTime();
    if (now < g_fSonicWindCD[client])
    {
        PrintCenterText(client, "Sonic Wind en enfriamiento (%.1f segs)", g_fSonicWindCD[client] - now);
        return;
    }
    g_fSonicWindCD[client] = now + 18.0;

    float eyePos[3], eyeAng[3], endPos[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);

    Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SOLID, RayType_Infinite, Sonic_TraceFilter_IgnoreTeam, client);
    if (TR_DidHit(trace)) {
        TR_GetEndPosition(endPos, trace);
    } else {
        float fwd[3]; GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(fwd, 1200.0);
        AddVectors(eyePos, fwd, endPos);
    }
    delete trace;

    EmitSoundToAll("mobius/sfx/boom.mp3", client);
    PrintCenterText(client, "[Sonic] SONIC WIND!");

    for (int i = 0; i < 5; i++) {
        float tPos[3]; tPos = endPos; tPos[2] += (i * 40.0);
        TE_SetupBeamRingPoint(tPos, 10.0, 200.0, g_iSonicBeamSprite, g_iSonicGlowSprite, 0, 10, 0.6, 10.0, 1.0, {50, 150, 255, 200}, 15, 0);
        TE_SendToAll();
    }

    if (!(GetEntityFlags(client) & FL_ONGROUND)) {
        float vel[3]; GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        vel[2] = 200.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    }

    Sonic_ApplyAreaStagger_Tornado(client, endPos, 250.0, 600.0);
}

void Sonic_ApplyAreaStagger_Tornado(int attacker, float origin[3], float radius, float pushPower)
{
    float radiusSq = radius * radius;
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED) {
            float ePos[3]; GetClientAbsOrigin(i, ePos);
            if (GetVectorDistance(origin, ePos, true) <= radiusSq) {
                float push[3];
                push[0] = 0.0;
                push[1] = 0.0;
                push[2] = pushPower;
                SIStagger_Auto(i, attacker, origin);
                TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, push);
                OM_AbilityDamage(i, attacker, 150.0, DMG_BLAST);
            }
        }
    }
    static const char sEnemyClasses[][] = {"infected", "witch"};
    for (int clsIdx = 0; clsIdx < sizeof(sEnemyClasses); clsIdx++) {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, sEnemyClasses[clsIdx])) != -1) {
            if (!IsValidEntity(ent)) continue;
            float ePos[3]; GetEntPropVector(ent, Prop_Data, "m_vecOrigin", ePos);
            if (GetVectorDistance(origin, ePos, true) <= radiusSq) {
                float push[3];
                push[0] = 0.0;
                push[1] = 0.0;
                push[2] = pushPower * 1.5;
                if (clsIdx == 0) {
                    OM_AbilityDamage(ent, attacker, 100.0, DMG_BLAST);
                    TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, push);
                } else {
                    WitchFlight_Launch(ent, attacker, push);
                    OM_AbilityDamage(ent, attacker, 250.0, DMG_BLAST);
                    WitchFlight_CheckDead(ent);
                }
            }
        }
    }
}

public bool TraceFilter_IgnoreSelf(int entity, int contentsMask, int data) { return entity != data; }

public bool Sonic_TraceFilter_IgnoreTeam(int entity, int contentsMask, int data)
{
    if (entity == data) return false;
    if (entity > 0 && entity <= MaxClients && IsClientInGame(entity) && GetClientTeam(entity) == 2) return false;
    return true;
}

// =======================
// CAIDAS: INMUNIDAD + DROP DASH AUTOMÁTICO v5.4 (conservado)
// =======================
public Action Sonic_OnTakeDamage_Fall(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return Plugin_Continue;

    if (damagetype & DMG_FALL)
    {
        damage = 0.0;

        // en plena picoada del dropdash no hay burst (la bola es la
        // que aterriza); en el resto de caidas, el salvavidas v5.4
        if (g_iSonicSpinPhase[victim] != SONIC_SPIN_DIVE)
        {
            float fallDirC[3], sAHor[3]; GetClientEyeAngles(victim, sAHor); sAHor[0] = 0.0;
            GetAngleVectors(sAHor, fallDirC, NULL_VECTOR, NULL_VECTOR); ScaleVector(fallDirC, 1100.0); fallDirC[2] = 300.0;
            TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, fallDirC);

            float vPos[3]; GetClientAbsOrigin(victim, vPos);
            Sonic_ApplyAreaStagger(victim, vPos, 280.0, 750.0);

            PrintCenterText(victim, "[+] SANO Y SALVO... DROP DASH AUTOMÁTICO!");
            EmitSoundToAll("mobius/sfx/boom.mp3", victim, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.95);

            float rposz[3]; GetClientAbsOrigin(victim, rposz); rposz[2] += 20.0;
            TE_SetupBeamRingPoint(rposz, 50.0, 380.0, g_iSonicGlowSprite, g_iSonicGlowSprite, 0, 10, 0.45, 15.0, 1.0, {150, 150, 255, 180}, 20, 0); TE_SendToAll();
        }
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

// =======================
// COMBATE: ANILLOS OM (nuevo) + NERVIOS DE ACERO v5.4 (conservado)
// =======================
public Action Sonic_OnTakeDamage_Combat(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return Plugin_Continue;
    if (damage <= 0.0) return Plugin_Continue;

    // ===== OM: en bola/picoada Sonic es INVULNERABLE (GMod
    // OM_Damage_Reduction 0 + iframes del Spindash_Duration) =====
    if (g_iSonicSpinPhase[victim] == SONIC_SPIN_ROLL
        || g_iSonicSpinPhase[victim] == SONIC_SPIN_WINDUP
        || g_iSonicSpinPhase[victim] == SONIC_SPIN_DIVE)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // ===== v6.5 (G): GRACIA 1.5s tras esquivar — dano bloqueado
    // GRATIS mientras dure (para que la lengua no re-cobre ni el
    // tank encadene puños). La tabla del owner deja FUERA los DoT:
    // el spit del spitter SIEMPRE cobra (y vómito se limpia aparte).
    if (Sonic_DodgeGraceActive(victim)
        && !(damagetype & DMG_ACID)
        && !(damagetype & DMG_BURN) && !(damagetype & DMG_BLAST)
        && !(damagetype & DMG_DROWN) && !(damagetype & DMG_SLOWBURN)
        && !(damagetype & DMG_RADIATION))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // ===== v6.6 (7): el SPIT respeta la gracia CORTA de 0.3s — igual
    // que el vómito del boomer ("la eva se consumia demasiado rápido")
    if (Sonic_DotGraceActive(victim) && (damagetype & DMG_ACID))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // ===== OM: ANILLOS absorben el dano directo =====
    // GMod excluye los DoT: burn/blast/drown/slowburn/radiation pasan
    if (g_cvSonicRings.BoolValue
        && g_iSonicRings[victim] > 0
        && !(damagetype & DMG_BURN) && !(damagetype & DMG_BLAST)
        && !(damagetype & DMG_DROWN) && !(damagetype & DMG_SLOWBURN)
        && !(damagetype & DMG_RADIATION))
    {
        // v6.5 (G) coste por FUENTE (tabla del owner): la WITCH paga
        // fijo (22) si su golpe es > 25; si es <= 24 (reducciones)
        // gasta exacto el dano. TANK y spit del spitter = "el dano
        // que entre" (1:1, como siempre). El resto sigue 1:1 GMod.
        int spent = RoundToCeil(damage);
        if (DollSys_IsWitchAttacker(attacker, inflictor) && damage > 25.0)
            spent = g_cvSonicDodgeWitch.IntValue;

        g_iSonicRings[victim] -= spent;
        if (g_iSonicRings[victim] < 0) g_iSonicRings[victim] = 0;

        damage = 0.0;

        // la esquiva del GMod (DodgeAnim 0.5s): R + L hacen el giro
        Sonic_PlayDodgeAnim(victim);

        // v6.5 (G): TODA esquiva abre la gracia 1.5s
        if (g_cvSonicDodge.BoolValue)
            g_fSonicDodgeGraceUntil[victim] = GetEngineTime() + g_cvSonicDodgeGrace.FloatValue;

        // v6.6 (7): ...y también la gracia corta de vómito/spit
        g_fSonicDotGraceUntil[victim] = GetEngineTime() + g_cvSonicDodgeGraceDot.FloatValue;
        g_fSonicDodgePaidAt[victim]   = GetEngineTime();

        PrintHintText(victim, "Anillos: %d / %d  (-%d)", g_iSonicRings[victim], g_cvSonicRingsMax.IntValue, spent);
        g_fSonicRingsHUDNext[victim] = GetEngineTime() + 0.75;
        return Plugin_Handled;
    }

    // ===== v5.4: inmunidad durante homing/burst =====
    if (GetEngineTime() < g_fSonicDashTime[victim] || g_bSonicHoming[victim]) {
        if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == 2) {
            damage = 0.0;
            return Plugin_Handled;
        }
        damage *= 0.3;
        return Plugin_Changed;
    }

    if (!g_bSonicInstinct_Enable) return Plugin_Continue;

    int curHP = GetClientHealth(victim);
    if (damage >= curHP)
    {
        float LIFT[3] = {0.0, 0.0, 480.0};
        TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, LIFT);
        EmitSoundToClient(victim, "mobius/sfx/instinct.mp3");
        damage = 0.0;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

// ===============================
// SISTEMAS v5.4 (área / explosión / revive) — intactos
// ===============================
void Sonic_ApplyAreaStagger(int attacker, float origin[3], float radius, float pushPower)
{
    float radiusSq = radius * radius;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float iPos[3]; GetClientAbsOrigin(i, iPos);
            if (GetVectorDistance(origin, iPos, true) <= radiusSq)
            {
                float dir[3]; MakeVectorFromPoints(origin, iPos, dir); NormalizeVector(dir, dir);
                ScaleVector(dir, pushPower); dir[2] += 250.0;

                SIStagger_Auto(i, attacker, origin);
                TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, dir);
                OM_AbilityDamage(i, attacker, 40.0, DMG_BLAST);
            }
        }
    }

    static const char sEnemyClasses[][] = {"infected", "witch"};
    for (int clsIdx = 0; clsIdx < sizeof(sEnemyClasses); clsIdx++)
    {
        int ent = -1;
        while ((ent = FindEntityByClassname(ent, sEnemyClasses[clsIdx])) != -1)
        {
            if (!IsValidEntity(ent)) continue;
            float ePos[3]; GetEntPropVector(ent, Prop_Data, "m_vecOrigin", ePos);

            if (GetVectorDistance(origin, ePos, true) <= radiusSq)
            {
                float dir[3]; MakeVectorFromPoints(origin, ePos, dir); NormalizeVector(dir, dir);
                ScaleVector(dir, pushPower); dir[2] += GetRandomFloat(200.0, 450.0);

                if (clsIdx == 0) {
                    OM_AbilityDamage(ent, attacker, 80.0, DMG_BLAST); TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, dir);
                } else {
                    WitchFlight_Launch(ent, attacker, dir);
                    OM_AbilityDamage(ent, attacker, 250.0, DMG_BLAST);
                    WitchFlight_CheckDead(ent);
                }
            }
        }
    }
}

public void Sonic_OnKillInfected_Explosion(int attacker, int victim)
{
    if (g_iPlayerCharIdx[attacker] != SONIC_INDEX) return;
    if (GetRandomFloat(0.0, 1.0) > SONIC_EXPLOSION_CHANCE) return;

    char wepName[64]; GetClientWeapon(attacker, wepName, sizeof(wepName));
    if (!Sonic_IsWeaponMelee(wepName)) return;

    float pPos[3]; GetClientAbsOrigin(attacker, pPos);
    Sonic_ApplyAreaStagger(attacker, pPos, 280.0, 500.0);
    EmitSoundToAll("mobius/sfx/boom.mp3", attacker);

    float vPos[3];
    if (victim > 0 && victim <= MaxClients && IsClientInGame(victim))
        GetClientAbsOrigin(victim, vPos);
    else if (victim > MaxClients && IsValidEntity(victim))
        GetEntPropVector(victim, Prop_Data, "m_vecOrigin", vPos);
    else
        return;

    TE_SetupBeamRingPoint(vPos, 30.0, 300.0, g_iSonicBeamSprite, g_iSonicGlowSprite, 0, 15, 0.4, 6.0, 0.0, {50, 150, 255, 120}, 10, 0); TE_SendToAll();
}

bool Sonic_IsWeaponMelee(const char[] wpName) {
    if (StrContains(wpName, "melee") != -1) return true;
    if (StrContains(wpName, "chainsaw") != -1) return true;
    if (StrContains(wpName, "pan") != -1) return true;
    if (StrContains(wpName, "axe") != -1) return true;
    if (StrContains(wpName, "bat") != -1) return true;
    if (StrContains(wpName, "sword") != -1) return true;
    if (StrContains(wpName, "katana") != -1) return true;
    if (StrContains(wpName, "machete") != -1) return true;
    if (StrContains(wpName, "tonfa") != -1) return true;
    if (StrContains(wpName, "guitar") != -1) return true;
    if (StrContains(wpName, "crowbar") != -1) return true;
    if (StrContains(wpName, "club") != -1) return true;
    if (StrContains(wpName, "shovel") != -1) return true;
    if (StrContains(wpName, "knife") != -1) return true;
    if (StrContains(wpName, "pitchfork") != -1) return true;
    return false;
}

public Action Sonic_OnPlayerDeath(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    // v3.77.79: el host de modo solo es un cliente fake — dejarlo pasar
    if (!Sonic_IsValidClient(victim) || (IsFakeClient(victim) && !Sonic_IsSoloHost(victim))) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != SONIC_INDEX) return Plugin_Continue;
    if (GetEntProp(victim, Prop_Send, "m_isIncapacitated")) return Plugin_Continue;

    if (!g_bSonicRevive_Enable) return Plugin_Continue;
    if (g_iSonicRevives[victim] >= SONIC_REVIVE_LIMIT) return Plugin_Continue;

    g_iSonicRevives[victim]++;
    CreateTimer(0.5, Timer_SonicRevive, GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);

    PrintToChatAll("[SonicJump] Sonic revive gracias a sus nervios de acero (%d/%d)", g_iSonicRevives[victim], SONIC_REVIVE_LIMIT);
    EmitSoundToAll("mobius/sfx/revive.mp3", victim, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
    damage = 0.0; return Plugin_Changed;
}

public Action Timer_SonicRevive(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (!Sonic_IsValidClient(client) || IsPlayerAlive(client)) return Plugin_Stop;

    int rdFind = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
    if (rdFind > 0 && IsValidEntity(rdFind)) AcceptEntityInput(rdFind, "Kill");

    if (!L4D2_VScriptWrapper_ReviveByDefib(client)) L4D_RespawnPlayer(client);
    SetEntityHealth(client, 100);

    float lift[3] = {0.0, 0.0, 250.0};
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, lift);
    EmitSoundToAll("mobius/sfx/revive.mp3", client);

    PrintToChatAll("[SonicJump] Sonic ha vuelto a la acción!"); return Plugin_Stop;
}

// =====================================================================
// COMANDOS DE ENLACE (Z/X/C del manager + alias directos)
// =====================================================================
public Action Command_SonicSpinBind(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    Sonic_OM_Spindash(client);
    return Plugin_Handled;
}

public Action Command_SonicPeelBind(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    Sonic_OM_PeelOut(client);
    return Plugin_Handled;
}

public Action Command_SonicHomingBind(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    HabilidadSonicSuperJump(client);
    return Plugin_Handled;
}

// sonda de valores vivos (patron sm_tailscd)
public Action Command_SonicCd(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (client == 0) { ReplyToCommand(client, "[Sonic OM] Solo en juego."); return Plugin_Handled; }
    float now = GetEngineTime();
    float cdS = (now < g_fSonicSpinCD[client]) ? (g_fSonicSpinCD[client] - now) : 0.0;
    float cdP = (now < g_fSonicPeelCD[client]) ? (g_fSonicPeelCD[client] - now) : 0.0;

    ReplyToCommand(client, "[Sonic OM %s] bola: %.0f uu/s x %.1fs (CD %.0fs%s) | peel: %.0f uu/s, carga %.1fs, dura %.1fs (CD %s=%.0fs/%.0fs) | anillos: %d/%d (golpe +%.0f)",
        SONIC_OM_VERSION,
        g_cvSonicSpinSpeed.FloatValue, g_cvSonicSpinDuration.FloatValue, g_cvSonicSpinCD.FloatValue,
        g_fSonicSpinCD[client] > now ? " [EN CURSO]" : "",
        g_cvSonicPeelSpeed.FloatValue, g_cvSonicPeelCharge.FloatValue, g_cvSonicPeelDuration.FloatValue,
        g_iSonicPeelRescues[client] > 0 ? "rescate" : "fallo", g_cvSonicPeelCDRescue.FloatValue, g_cvSonicPeelCDFail.FloatValue,
        g_iSonicRings[client], g_cvSonicRingsMax.IntValue, g_cvSonicSpinRingGain.FloatValue);
    ReplyToCommand(client, "  bola: dano %.0f (TANK %.0f) x stun %.1fs / final %.1fs | AoE comunes: %.0fu | homing: 1s entre usos | trails %s",
        g_cvSonicSpinDamage.FloatValue, g_cvSonicSpinDmgTank.FloatValue,
        g_cvSonicSpinStun.FloatValue, g_cvSonicSpinStunFinal.FloatValue,
        g_cvSonicSpinRadiusCommons.FloatValue,
        (g_cvSonicTrails != null && g_cvSonicTrails.BoolValue) ? "ON" : "OFF");
    ReplyToCommand(client, "  dodge (anillos): lengua %.0f | hunter %.0f | jockey %.0f | charger %.0f | vómito %.0f | boom %.0f | witch %.0f (<=24 = el dano) | gracia %.1fs%s | gracia vómito/spit %.1fs%s",
        g_cvSonicDodgeTongue.FloatValue, g_cvSonicDodgeHunter.FloatValue, g_cvSonicDodgeJockey.FloatValue,
        g_cvSonicDodgeCharger.FloatValue, g_cvSonicDodgeVomit.FloatValue, g_cvSonicDodgeBoom.FloatValue,
        g_cvSonicDodgeWitch.FloatValue, g_cvSonicDodgeGrace.FloatValue,
        g_fSonicDodgeGraceUntil[client] > now ? " [ACTIVA]" : "",
        g_cvSonicDodgeGraceDot.FloatValue,
        g_fSonicDotGraceUntil[client] > now ? " [ACTIVA]" : "");
    if (cdS > 0.0)  ReplyToCommand(client, "  spindash listo en %.0fs", cdS);
    if (cdP > 0.0)  ReplyToCommand(client, "  peel out listo en %.0fs", cdP);
    return Plugin_Handled;
}
