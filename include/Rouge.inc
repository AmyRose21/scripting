/*
 * ======================================================
 *  [MODULO] Rouge the Bat - Spy & Night Ops v11.0-OM (KIT GMOD + AVATAR)
 *
 *  v11.0-OM - "EL GLIDE DE ROUGE" (manager 3.77.112, pedido del owner
 *          2026-10-22: "es hora de crear el codigo del glide... el
 *          glide La activacion seria = a la de knuckles la diferencia
 *          es que Ella si podra subir con los aleteos pero al moverse
 *          ahora usara la animacion glide en vez de flyrun"). TRES
 *          cambios quirurgicos sobre el vuelo v10.2 (la fisica — cap
 *          de caida -100, steering 45, tope 320 — INTACTA):
 *
 *            [1] ACTIVACION ESTILO KNUCKLES: un TAP de SPACE en el
 *                aire despliega las alas y el planeo SE QUEDA ON solo
 *                — nada que mantener (antes: SPACE apretado todo el
 *                vuelo; al soltarlo se apagaba al frame). El salto del
 *                SUELO no la enciende: el borde del boton se consume
 *                en el piso, hay que RE-APRETAR en el aire (el
 *                doble-salto clasico de los Sonic). El lanzazo de
 *                pared la enciende de una — Knuckles sale de su pared
 *                ya planeando, ella igual. Termina al ATERRIZAR,
 *                agarrar pared o frenar con SHIFT: los mismos finales
 *                del glide de Knuckles.inc.
 *
 *            [2] EL ALETEO VIVE DENTRO DEL PLANEO: con las alas
 *                fuera, cada TAP nuevo de SPACE es un aleteo que la
 *                ELEVA (energia 8 — la unica moneda del vuelo:
 *                "solo dependera es de la energia"). El primer tap
 *                (el que abre las alas) es gratis. LA DIFERENCIA CON
 *                KNUCKLES: el solo cae planeando — ELLA SI PUEDE
 *                SUBIR.
 *
 *            [3] AL MOVERSE = SECUENCIA "glide": el estado FLYRUN
 *                dispara la secuencia "glide" del rouge.mdl v15 (el
 *                planeo Sonic Dream Team construido en las Tasks
 *                30-38: cuerpo horizontal, alas batiendo, brazos
 *                atras, piernas en tijera). QUIETA en el aire sigue
 *                siendo FlyIdle (el hover del freno). PROBE en cada
 *                montaje de avatar (receta Shadow v6.0 / Amy v92:
 *                SetAnimation + m_nSequence): si el servidor todavia
 *                tiene el rouge.mdl VIEJO sin la secuencia, el FSM cae
 *                a "FlyRun" SOLA — nunca se congela el avatar.
 *
 *          Extra: el planeo NO pelea con el Barrido — si embiste en
 *          el aire (Z), la maquina del kick manda ese frame y el cap
 *          del planeo espera; al soltarla sigue planeando como si
 *          nada.
 *
 *  v10.4-OM - "EL RAGDOLL QUE POR FIN VUELA" (manager 3.77.52): el
 *          cuerpo del Barrido (Z) contra comunes usaba
 *          TeleportEntity-vel + m_angVelocity — escribirle velocidad a
 *          la ENTIDAD de un prop_ragdoll no mueve NI UN HUESO (los
 *          huesos sobreescriben la velocidad de la entidad cada tick;
 *          la v6.9 de sonic.inc lo demostro). Ahora pasa por el impulso
 *          v6.33 de sonic.inc: SetVelocity(dir*500 + 300z, giro random)
 *          POR HUESO directo al vphysics (la receta GMod literal), con
 *          el plan B motor puro de fallback. Mismo look del lua, pero
 *          esta vez llegando de verdad.
 *
 *  v10.3-OM - "PATCH DE BALANCE" (manager 3.77.50, pedido literal del
 *          owner 2026-10-11: "buff a la habilidad 1 de rouge la patada
 *          baja ahora causara 50% más de dano El counter causara 45% más
 *          de dano y durara 7 seg) QoL La pantada baja ahora su Aoe
 *          aumentara un 25%"). Sobre el kit v10.2 la "habilidad 1 / la
 *          patada baja" = su Z (H1) BARRIDO (el Sweep Kick, sm_rouge_sweep)
 *          y "El counter" = su X (H2) CONTRAGOLPE:
 *            - BARRIDO (patada baja): dano 150 -> 225 (+50%) y radio
 *              95 -> 118.75 (+25% AoE) — el mismo convar alimenta TODOS
 *              los impactos de la embestida del barrido.
 *            - CONTRAGOLPE: devolución a comunes 100 -> 145 y a
 *              especiales 200 -> 290 (+45%); duración 6 -> 7s.
 *          TODO lo demas INTACTO (energía/vuelo/planeo/bat bomb/onda
 *          negra/eva/vida 125/avatar rouge.mdl).
 *
 *  v10.2-OM - "VUELO SIN LIMITE" (manager 3.77.48, orden del owner:
 *          "el vuelo no tiene limite de saltos de vuelo. Solo
 *          dependera es de la energía"). El aleteo ya no tiene tope de
 *          CANTIDAD: el único limite es la ENERGÍA (250 / 8 = ~31
 *          aleteos por tanque lleno). rouge_flap_max 0 = ilimitado
 *          (>0 = tope, palanca si algún día se quiere devolver).
 *          Potencia PLENA en cada aleteo (fuera el decaimiento 7.5%
 *          del lua, que con vuelo largo llegaba a cero y hasta
 *          negativo) y cd PLANO al aterrizar (era 6s por aleteo usado
 *          = hasta 120s de muro oculto con vuelo ilimitado).
 *
 *  v10-OM - "EL KIT DEL GMOD + SU PROPIA ENTRADA EN EL VSCRIPT" (ronda
 *          32, 2026-10-10, manager 3.77.45). Pedido del owner: "Aún
 *          tienes los Lua de Gmod? Si aún los tienes incluyelas con sus
 *          pasivas de rouge y habilidades (y si las otras 2 habilidades
 *          que ya tiene muevelas a la 3 y 4) [...] la habilidad de flash
 *          será modificada: se fusionada con la granada quimica en la
 *          habilidad 4 ella tendrá también un Parry (tipo counter de
 *          knuckles pero un tanto más debil pero aún así podrá activar
 *          la devolución de proyectiles". Los Lua SI están (pack 118 de
 *          la Task 25) — portadas las mecanicas EXACTAS del
 *          redimated_om_pills_survivors_rouge.lua:
 *
 *          LAYOUT NUEVO (Z/X/C/B como los 4 slots del suite):
 *            Z (H1) BARRIDO      = Sweep Kick del lua (carga 0.35 ->
 *                                embestida 550 con i-frames + primer
 *                                golpe: stagger/dano/ragdoll volado,
 *                                blazekick.wav; desde pared = lanzazo
 *                                1500). Recarga 28 hit / 15 miss (lua).
 *            X (H2) CONTRAGOLPE  = counter estilo Knuckles PERO MÁS
 *                                DEBIL: 4s (vs 8s de knux), devoluciones
 *                                a media fuerza (comunes 50, SI 100 +
 *                                empuje 500) — y SU PROPIA ENTRADA EN EL
 *                                VSCRIPT: Rouge_ParryNotifyNut ->
 *                                ChCh_RougeNotify (chch_parrying.nut
 *                                v2.9, patron supertank: la entrada es
 *                                la identidad) -> DEVOLUCION DE
 *                                PROYECTILES COMPLETA (roca/saliva/
 *                                granadas + enemigos en cono).
 *            C (H3) BAT BOMB    = movida intacta desde la X.
 *            B (H4) CEBO+FLASH  = el Cebo Quimico movido desde la Z Y
 *                                FUSIONADO con la Flash Bang del lua:
 *                                la granada quimica ahora APLANA (destello
 *                                + om/rouge/flashbomb.wav) a todo lo que
 *                                mire la explosión en 400u con línea de
 *                                visión: comunes/witch estatua, SI
 *                                stagger + lentitud x0.7 durante 6s (la
 *                                rougeslowdown del lua), tank lento.
 *                                Sigue teniendo su explosión + charco de
 *                                acido. Onda Negra: fuera de los slots
 *                                (reemplazada; queda en consola:
 *                                sm_rouge_wave).
 *
 *          PASIVAS DEL LUA (todas portadas):
 *            - ENERGÍA (rouge_latchbar): 30 inicial / 100 max / regen
 *              1.2/s (17/1000 por tick del lua); alimenta TODO lo de
 *              abajo; histeresis del lua: si llega a <=1 no vuelve a
 *              agarrar hasta 35 (Rouge_OM_regenserious).
 *            - AGARRE DE PARED (LatchOntoWall_OM_Knuckels, el mismo
 *              sistema del lua — aquí es la receta del Knuckles.inc del
 *              suite): pegada a pared en el aire (max 2 por vuelo),
 *              drena energía 23/s, SPACE = lanzazo aim*700+60z (15
 *              energía), rompe sola si la energía muere o llega al piso.
 *            - SALTOS EN EL AIRE (Flap): 3 por vuelo, 16 de energía
 *              cada uno, impulso 400-30*usados (el 400 del lua), xy
 *              x0.85, anim flap + om/rouge/flap.wav.
 *            - REDUCCION PASIVA: recibe el 90% del dano
 *              (passivereduction 90 del lua); durante el Barrido tiene
 *              I-FRAMES completos (el lua pone OM_Damage_Reduction=0).
 *            - Y las de siempre: planeo SHIFT, inmunidad de caida,
 *              evasión instintiva.
 *
 *          AVATAR (patron Knuckles v75/Tails/Metal — 6o avatar del
 *          suite): rouge.mdl del VPK (FileExists, SI el modelo no esta
 *          montado TODO cae al survivor normal, CERO dependencia),
 *          copias R/L + sync TP/parentado + pulso de pausa + adopción
 *          de huerfanos en el montaje + FSM con las secuencias del lua
 *          (idle/walk/run/jump/fall/latch/flap/SweepKick +
 *          IdleLowHealth/WalkLowHealth/RunLowHealth <=60 HP +
 *          DownedIdle/DownedWalk) + ragdoll de muerte rouge.mdl 15s.
 *
 *          SONIDOS DEL LUA (con guard + fallback vanilla): carga del
 *          barrido om/knuckles/punchstart.wav (107 de pitch), golpe
 *          om/blaze/blazekick.wav, aleteo om/rouge/flap.wav, pared
 *          om/knuckles/Latch.wav, destello om/rouge/flashbomb.wav. El
 *          contragolpe suena con SU flashbomb (la ventana del VScript
 *          lleva Rouge_Window_Sound en el .nut v2.9).
 * ======================================================
 *  [MODULO] Rouge the Bat - Spy & Night Ops v9.1 (Tactical Rework)
 *
 *  v9.1 - ONDA NEGRA: FIX CRITICO + CINEMÁTICA (ronda 31). El owner
 *          reporto: "los commons quedan congelados... la witch queda
 *          congelada nunca muere nunca es atraida... solos ale una onda
 *          que sale y vuelve". Causa raíz: Rouge_WaveGrab congelaba a la
 *          victima pero NUNCA registraba su referencia en el pool
 *          (falto el g_iRWWRef[slot] = ref). El tick de 20 Hz veía el
 *          pool VACÍO, contaba active == 0 y se apagaba solo en su
 *          primer tick: cero arrastre, cero liberación, cero dano ->
 *          estatuas congeladas eternas (comunes y witch) + solo los
 *          anillos de VFX. FIX: el slot ahora SI registra la victima.
 *          ADEMÁS (el "no hay cinemática no hay esfera no hay nada"):
 *          * NUCLEO DE ONDA: esfera translucida NEGRO-MAGENTA en el
 *            punto de convergencia (mismo modelo del escudo de Sally),
 *            elevada sobre el punto de cast: las victimas se succionan
 *            hacia el corazon de la esfera.
 *          * COLAPSO DE LLEGADA (0.75s): la esfera se traga todo: kill
 *            + anillo de implosión rápido + particula de suelo + boom.
 *          * Trace del arrastre levantado +2u: el plano del piso ya no
 *            se roza con el rayo anti-muro (arrastre limpio en plano).
 *  v9.0 - HABILIDAD 3 "ONDA NEGRA" (Black Wave, ronda 29): pedido del
 *      owner: "La 1 que dijiste esta destructora. Pero quitale el
 *      temblor (para evitar mareos por usos constantes y demas).
 *      También colocale que pueda jalar a la witch pero para eso se
 *      nesesita aplicar el método que se uso con el golpe de martillo
 *      de amy que apaga su Nextbot y la congela como tal para que
 *      esta pueda comportarse igual. También haslo con los commons:
 *      o sea apagarles el cerebro y congelarlos para que ellos también
 *      puedan ser jalados".
 *      - NUEVA H3 (tecla C / sm_rouge_wave / sm_sjs_ability3), SOLO de
 *        la Rouge real (las granadas Z/X se prestan al set ROUGE de
 *        Sage; la onda es SU firma): recarga 17s (rouge_wave_cooldown),
 *        rango S = 1000u (rouge_wave_radius).
 *      - ONDA EXPANSIVA NEGRA (concepto A "la destructora"): anillos
 *        negro-magenta que se EXPANDEN y CONTRAEN (implosión) +
 *        particulas de suelo "gas_explosion_ground_wave" (la misma del
 *        agujero negro del Super Tank, precacheada por nosotros).
 *        SIN TEMBLOR: cero env_shake / cero ScreenShake (pedido
 *        literal del owner: evitar mareos por usos constantes).
 *      - FASE DE SUCCION: todo infectado en rango es JALADO hacia el
 *        punto de cast:
 *        * ESPECIALES/TANK (players): no se congelan (FL_FROZEN en un
 *          player le roba el control) -> succión por velocidad +
 *          stagger seguro + dano inmediato.
 *        * COMUNES y WITCH: EL MÉTODO DEL MARTILLO DE AMY (Witch_Flight
 *          v2.x): APAGAR EL CEREBRO (FL_FROZEN: el gate del motor
 *          NextBot, DoThink solo llama Update() si el flag está en 0) +
 *          CONGELAR (MOVETYPE_NONE: la física no integra nada). Con la
 *          IA apagada y el cuerpo congelado, el sistema los ARRASTRA
 *          por teleports (tick 20 Hz) hasta 80u de Rouge, con trace
 *          brush-only por paso (anti-muro: detrás de una pared se
 *          liberan en el punto de bloqueo, sin traspasar geometria).
 *      - LLEGADA (0.75s): restauración EXACTA (movetype original +
 *        FL_FROZEN retirado + velocidad cero) ANTES del dano de la
 *        marea (patron WitchFlight_CheckDead: si el golpe los mata, la
 *        muerte procede con el estado normal del motor): comunes x2
 *        (revientan a los pies de Rouge), witch base + m_rage=1.0
 *        (llega ENFADADA, patron WitchFlight_Landing v2.6).
 *      - SEGURIDAD: slots 56, tapa dura de arrastre, re-afirmación del
 *        congelamiento cada tick (patron WF v2.0), liberación inmediata
 *        si mueren en pleno arrastre, OnMapEnd/RoundStart vacian el
 *        pool. NO se edito el VScript del Super Tank (no hizo falta):
 *        la onda es NATIVA (control total, patron Sally/Amy).
 *
 *  v8.0 CHANGES (petición del usuario):
 *  - NUEVA PASIVA: EVASION INSTINTIVA (reemplaza la Treasure
 *    Visión / Busca Tesoros): 30% (ConVar rouge_evade_chance) de
 *    esquivar por completo un ataque cuerpo a cuerpo o de melee
 *    (el dano se anula) + aturdimiento respectivo del atacante:
 *    especiales -> stagger seguro (SIStagger_Auto, se levanta
 *    garantizado), witch -> lanzamiento corto (WitchFlight).
 *    Feedback: destello rosa + texto "ESQUIVADO".
 *  - FIX PLANGO (el bug del planeo): la versión antigua solo
 *    capaba la velocidad de caida EN EL FRAME DE ACTIVACION
 *    (el bloque de steer/cap vivía dentro de "if (!gliding)
 *    ... activación"), así que tras 1 frame la gravedad volvia
 *    a acelerarla hasta velocidad terminal: el "planeo" no
 *    planeaba. Ahora cada PreThink mientras vuela: caida capada
 *    a ROUGE_GLIDE_FALL (-100), steering WASD continuo con
 *    aceleración aérea, cap horizontal de 320 y desactivación
 *    natural al soltar SHIFT (o al aterrizar / ser agarrada /
 *    incapacitarse). Solo se activa cayendo (vel[2] < -50).
 *  - MEJORAS HABILIDADES (las 2):
 *    * Cebo Quimico y Bat Bomb Spray ahora DAÑAN A LA WITCH y la
 *      lanzan por los aires (WitchFlight: 400h/350v desde el
 *      centro de la explosión) y a los comunes se les aplica el
 *      empuje ANTES del dano (el ragdoll hereda el impulso y
 *      vuelan, mismo fix que Amy v45).
 *    * El stagger de área ahora va por SIStagger_Auto (fix del
 *      bug "los staggered no se levantan": auto-cancel del
 *      estado del motor a los 1.8s / 3.0s Tank).
 *    * Textos de cooldown/uso en español consistente.
 *
 *  v7.2 FIXES DE BUGS Y QoL (mantenidos):
 *   - FIX GUARD: Rouge_Event_PlayerDeath reseteaba el estado (color,
 *     movetype, cooldowns) de CUALQUIER jugador que muriera, no solo
 *     de Rouge. Poda pisar el estado de otros personajes en su muerte.
 *   - FIX FLICKER (media solucin que faltaba): la Treasure Visión limpiaba
 *     TODOS los glows tipo 3, pisando el amarillo del Animal Sense de
 *     Tails cada segundo (parpadeo de colores). Ahora solo toca glows
 *     ROSAS (propios).
 *   - FIX GLOW RESIDUAL: si un especial herido se curaba por encima del
 *     50% o respawneaba con HP lleno, el glow rosa le quedaba pegado para
 *     siempre (el bloque de limpieza solo corria si segua herido). Ahora
 *     el glow se limpia SIEMPRE que el objetivo deja de ser elegible.
 *   - FIX GLOW RESIDUAL 2: al morir/cambiar de personaje/desconectar Rouge,
 *     los glows rosas de los especiales qudaban pegados. Nueva
 *     Rouge_ClearTreasureGlows() llamada desde Rouge_OnPlayerDeath.
 *   - FIX WARNING: parámetro "damage" de Rouge_CreateExplosion nunca
 *     usado (warning 203 del compilador). Eliminado (el dao real lo hace
 *     Rouge_DamageInfectedInRadius).
 *   - FIX BAT BOMBS: detonaban al TOCAR EL SUELO/PAREDES (SDKHook_Touch
 *     dispara con worldspawn=0), así que el "abanico" explotaba al
 *     primer bote en vez de rodar. Ahora solo detonan contra jugadores,
 *     infectados comunes o Witches; contra el mundo rebotan.
 *   - FIX LEAK: los DataPacks de los timers de beep/acido con
 *     TIMER_FLAG_NO_MAPCHANGE quedaban colgados si el mapa cambiaba a
 *     mitad. Ahora se trackean y se liberan en OnMapEnd.
 *   - FIX PRECACHE: Rouge_CreateExplosion haca PrecacheModel en tiempo
 *     de ejecucin (mala práctica). Ahora usa los sprites precacheados
 *     en OnMapStart (nuevo halo01).
 *   - FIX CEBO: el pipe_bomb_projectile nativo poda detonar por su propio
 *     fuse (aleatorio ~2.2-2.7s) ANTES que nuestro timer de 2.5s, y al
 *     destruirse la entidad el charco de acido nunca se creaba (habilidad
 *     a medias). Ahora se neutraliza el fuse nativo (m_flDetonateTime
 *     lejano) para que NUESTRO timer siempre controle la detonacin.
 *   - FIX CRITICO (pasiva muerta): el timer de la Treasure Visión solo se
 *     creaba en OnPluginStart con NO_MAPCHANGE y muere en cada cambio de
 *     mapa, pero nadie lo recreaba -> la pasiva funcionaba SOLO en el
 *     primer mapa de la sesión. Ahora Rouge_OnMapStart lo recrea.
 *
 *  v7.0 CHANGES:
 *   - FIX CRITICO: El "charco de acido" del Cebo Quimico ahora HACE DANO real.
 *     Se spawnea un insect_swarm nativo (entidad del spit del Spitter) que
 *     genera el efecto visual verde persistente. Adicionalmente se lanza un
 *     timer de dano por tick paralelo como respaldo robusto para asegurar
 *     que SIEMPRE haya dano a los infectados en el área, sin depender de
 *     gamedata externa ni signatures.
 *   - Reemplazo de g_bBombDetonated[2048] por ArrayList g_hRougeActiveBombs
 *     (más eficiente, sin arrays gigantes).
 *   - Validaciones estrictas en todos los callbacks (client, entity, ref).
 *   - Cleanup correcto de DataPacks en todos los timers.
 *   - TIMER_FLAG_NO_MAPCHANGE en todos los timers repetitivos.
 *   - Verificación de null en ConVars antes de usarlas.
 *   - Documentación completa de cada función.
 *   - Mejor manejo de estados de cliente en reset.
 *
 *  Rol: Spy / Night Ops / Crowd Control
 *  Pasivas: Bat Glide (planeo real con SHIFT en el aire), Inmunidad a dano
 *           de caida, Evasión Instintiva (30% de esquivar + aturdir al
 *           atacante; reemplaza la Treasure Visión).
 *  Habilidad 1 (Z): Cebo Quimico - granada rosa que explota y deja charco de acido real
 *                    (ahora también daña y lanza a la Witch).
 *  Habilidad 2 (X): Bat Bomb Spray - 3 granadas rosa en abanico (ahora con
 *                    empuje de comunes, dano a Witch y stagger seguro).
 * ======================================================
 */

#if defined _Rouge_included
    #endinput
#endif
#define _Rouge_included
#define ROUGE_INC_VERSION "v11.0-OM" // v11.0: EL GLIDE DE ROUGE (manager 3.77.112) — activacion ESTILO KNUCKLES (tap de SPACE en el aire = planeo que SE QUEDA ON; aterrizar/pared/SHIFT lo apagan; el salto del piso no la enciende — re-apretar en el aire) + aleteo DENTRO del planeo (primer tap abre alas gratis, siguientes ELEVAN — energia; LA DIFERENCIA CON KNUCKLES: ella SI sube) + AL MOVERSE secuencia "glide" del rouge.mdl v15 (probe por montaje; fallback "FlyRun" con modelo viejo) + gate del kick aereo | v10.7: EL BARRIDO CON RANGO (pedido del owner 2026-10-17, ronda 2): "Rouge daño aumentado 225 a 200-335" — la patada baja deja de ser un 225 FIJO y pasa a un aleatorio por golpe [rouge_kick_dmg_min/_max; rouge_kick_damage queda DEPRECATED] | v10.6: LA BARRA DE ENERGÍA AL CHAT (manager 3.77.85, pedido del owner: "ese mismo tipo de barra debería salir para sonic y todos aquellos que lo usan") — la rouge_latchbar del lua (0-250) vive ahora en el motor común SBar con la paleta colors.inc [PARED! en oliva mientras DRENA pegada / FRENO! el hover de SHIFT / PLANEO! con SPACE / AGOTADA! en rojo parpadeando con la histeresis del lua (bloquea pegarse a paredes hasta rouge_energy_serious 88)] vía Rouge_BarState + el despachador SBar_Resolve; el hint de 10 bloques Rouge_EnergyHUD se RETIRA (patron anillos de Sonic v6.36: la barra pinta EN VIVO a 5 Hz, el hint era un recurso compartido a 1.2s) | v10.5: LA PATADA BAJA MANDA A VOLAR (pedido del owner 2026-10-13: "hay que aplicar el stun ragdoll a rouge... rouge es una patada baja") — su CONTRAGOLPE ahora aplica STUN + RAGDOLL VOLADOR con la dirección de la patada (horizontal alejándola + elevación corta — una patada baja barre, no levanta): orden martillo v106 (dano amplificado PRIMERO; letal = cadaver volando con la copia Rouge; sobrevive = OM_Stun + doble volador por Sonic_SpawnFlingRagdollEx). Convars nuevos rouge_parry_ragdoll (3.0s) / rouge_parry_fling (600 u/s). + el dano de sus habilidades pasa por OM_AbilityDamage (amplificador hibrido x2 + % vs jefes del OM_Stun v2.2). v10.4: RAGDOLL DEL BARRIDO CON IMPULSO REAL — SetVelocity por hueso vía sonic v6.33 (antes TeleportEntity-vel que los huesos ignoraban); v10.3-OM: PATCH DE BALANCE — patada baja (Barrido Z) dano 150->225 (+50%) y radio 95->118.75 (+25%); counter +45% dano (145/290) y 7s (manager 3.77.50); v10.2: ALETEO SIN LIMITE — solo energía (manager 3.77.48); v10.1: rework del vuelo + counter pleno + onda negra

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

// =======================
// Dependencias
// =======================
#if !defined ROUGE_INDEX
    #define ROUGE_INDEX 6
#endif

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// =======================
// Constantes y Audio
// =======================
#define ROUGE_SND_KICK_HIT  "weapons/katana/melee/katana_hit_infected2.wav"
#define ROUGE_SND_THROW     "weapons/molotov/molotov_throw.wav"
#define ROUGE_SND_BEEP      "buttons/button16.wav"
#define ROUGE_SND_BOOM      "weapons/hegrenade/explode4.wav"
#define ROUGE_SND_ACID      "player/spitter/voice/attack/spitter-spit2.wav"
#define ROUGE_MODEL_BOMB    "models/w_models/weapons/w_eq_pipebomb.mdl"

// Configuración del charco de acido (Habilidad 1)
#define ROUGE_ACID_RADIUS       220.0   // Radio de dano del charco
#define ROUGE_ACID_DURATION     8.0     // Duración total del charco (segundos)
#define ROUGE_ACID_TICK         0.5     // Intervalo de dano por tick
#define ROUGE_ACID_DMG_SPEC     12.0    // Dano por tick a infectados especiales
#define ROUGE_ACID_DMG_COMM     80.0    // Dano por tick a infectados comunes
#define ROUGE_ACID_DMG_TANK     8.0     // Dano por tick al Tank

#define ROUGE_BAIT_FUSE         2.5     // Tiempo del fuse del cebo
#define ROUGE_BAIT_RADIUS       250.0   // Radio de la explosión inicial

// Configuración de la Bat Bomb (Habilidad 2)
#define ROUGE_BOMB_MAX_ACTIVE   32      // Máximo de bombas activas simultaneas

// Configuración del planeo v8.0 (pasiva)
#define ROUGE_GLIDE_FALL        -100.0  // velocidad de caida máxima planeando
#define ROUGE_GLIDE_HORIZ_MAX   320.0   // velocidad horizontal máxima planeando
#define ROUGE_GLIDE_ACCEL       45.0    // aceleración aérea WASD por PreThink
#define ROUGE_GLIDE_MIN_FALL    -50.0   // (v11.0: sin uso — la activación es el TAP de SPACE en el aire, estilo Knuckles)
#define ROUGE_BRAKE_RATE       7.0    // v10.1: tasa de decaimiento del FRENO aéreo (1-e^-7 ~ freno total en ~0.6s)
#define ROUGE_BRAKE_STOP       30.0   // v10.1: por debajo de esta velocidad queda CLAVADA (hover)
#define ROUGE_KICK_HITS        24     // v10.1: victims del barrido en área por embestida

// Configuración de la Evasión Instintiva v8.0 (pasiva)
#define ROUGE_EVADE_SOUND       "buttons/bell1.wav"

// Configuración de la Onda Negra v9.0 (Habilidad 3 - rango S)
#define ROUGE_WAVE_SLOTS        56      // infectados arrastrados a la vez (comunes + witches)
#define ROUGE_WAVE_TICK         0.05    // integración del arrastre (20 Hz)
#define ROUGE_WAVE_DRAG_TIME    0.75    // duración del arrastre hasta los pies de Rouge
#define ROUGE_WAVE_MAX_DRAG     1.5     // tapa dura de seguridad (segundos extra tras el fin)
#define ROUGE_WAVE_MIN_DIST     80.0    // distancia de parada alrededor del punto de cast
#define ROUGE_WAVE_SI_PULL      700.0   // velocidad de succión de especiales/tank (players)
#define ROUGE_WAVE_SPHERE_MDL   "models/props_unique/airport/atlas_break_ball.mdl"
#define ROUGE_WAVE_SPHERE_SCALE 0.55    // nucleo ~130u: las victimas frenan a 80u (se apilan al borde)
#define ROUGE_WAVE_SPHERE_LIFT  40.0    // altura del nucleo sobre el punto de cast (la succión tira hacia arriba)

// =======================
// v10-OM: CONFIG DEL KIT GMOD (defaults = lua GMod)
// =======================
#define ROUGE_OM_MODEL        "models/Noodles/OM/rouge.mdl"
#define ROUGE_AVATAR_NAME     "rouge_avatar_om"
#define ROUGE_AVATAR_NAME_L   "rouge_avatar_om_l"

// FSM de animación — las secuencias del rouge.mdl que usa el lua GMod
// (anims.default: idle/walk/run/glide="fall"/Jump2="jump"/SweepKick/Flap
//  + ShouldAlternate: latch/Downed*/lowhealth)
#define ROUGE_ST_IDLE         0
#define ROUGE_ST_WALK         1
#define ROUGE_ST_RUN          2
#define ROUGE_ST_JUMP         3    // Jump2 -> "jump" (one-shot con ventana)
#define ROUGE_ST_FALL         4    // caida Y planeo (el lua: glide="fall")
#define ROUGE_ST_LATCH        5    // loop: agarrada de pared
#define ROUGE_ST_FLAP         6    // one-shot: Flap (aleteo)
#define ROUGE_ST_KICK         7    // one-shot: SweepKick (el barrido)
#define ROUGE_ST_IDLE_LOW     8    // IdleLowHealth (HP <= 60, el lua)
#define ROUGE_ST_WALK_LOW     9
#define ROUGE_ST_RUN_LOW      10
#define ROUGE_ST_DOWNED_IDLE  11   // DownedIdle (incap)
#define ROUGE_ST_DOWNED_WALK  12
#define ROUGE_ST_FLYIDLE      13   // v10.1: QUIETA en el aire (hover/freno) — la anim del owner
#define ROUGE_ST_FLYRUN       14   // v11.0: volando EN MOVIMIENTO — secuencia "glide" (modelo v15; fallback "FlyRun" si el .mdl viejo no la trae)
#define ROUGE_ANIM_COUNT      15

#define ROUGE_LOCK_FLAP       0.45
#define ROUGE_LOCK_KICK       0.95
#define ROUGE_LOCK_LATCHOFF   0.40

// fases del Barrido (Sweep Kick)
#define ROUGE_KICK_NONE       0
#define ROUGE_KICK_CHARGING   1
#define ROUGE_KICK_DASH       2

// tintes del avatar (misma matemática fade simétrica del UI GMod)
#define ROUGE_TINT_DUR        0.25
#define ROUGE_TINT_FADE       0.125

#define ROUGE_SLOW_SLOTS      64    // pool de lentitud (flash/parry)
#define ROUGE_SND_LEVEL       87    // AdvancedPillSound del lua

// =======================
// Variables Globales
// =======================
float g_fRougeBaitCooldown[MAXPLAYERS + 1];
float g_fRougeBombCooldown[MAXPLAYERS + 1];
float g_fRougeWaveCooldown[MAXPLAYERS + 1];    // v9.0: Habilidad 3 (Onda Negra)

bool g_bRougeGliding[MAXPLAYERS + 1];
bool g_bRougeBraking[MAXPLAYERS + 1];      // v10.1: freno aéreo con SHIFT (hover)
float g_fRougeNextLatchTime[MAXPLAYERS + 1]; // v10.1: cd de re-agarre al salir de pared (0.5s, como Knuckles)
float g_fRougeLatchNormal[MAXPLAYERS + 1][3]; // v10.1: la normal de la pared (salida estilo Knuckles)
bool g_bRougeCounterHit[MAXPLAYERS + 1];   // v10.1: bloqueo exitoso en la ventana -> cd 85% en vez de 55%
bool g_bRougeMaxHpApplied[MAXPLAYERS + 1]; // v10.1: vida max 125 aplicada (restore al 100 al cambiar)

// ---- v10-OM: estado del KIT GMOD ----
float g_fRougeEnergy[MAXPLAYERS + 1];        // rouge_latchbar (0..max)
bool  g_bRougeRegenSerious[MAXPLAYERS + 1];  // histeresis <=1 -> espera 35
int   g_iRougeLatches[MAXPLAYERS + 1];       // agarres de pared restantes
bool  g_bRougeLatched[MAXPLAYERS + 1];       // pegada a la pared ahora
float g_fRougeLatchYaw[MAXPLAYERS + 1];      // yaw de la normal (mirar afuera)
int   g_iRougeUsedJumps[MAXPLAYERS + 1];     // aleteos usados en el vuelo
float g_fRougeJumpCDUntil[MAXPLAYERS + 1];   // cd de aleteos al aterrizar
int   g_iRougePrevButtons[MAXPLAYERS + 1];   // borde del SPACE

int g_iRougeKickPhase[MAXPLAYERS + 1];     // NONE/CHARGING/DASH
int g_iRougeKickHitList[MAXPLAYERS + 1][ROUGE_KICK_HITS];  // v10.1: victimas del barrido en ÁREA (refs)
int g_iRougeKickHitCount[MAXPLAYERS + 1];
float g_fRougeKickChargeEnd[MAXPLAYERS + 1];
float g_fRougeKickDashEnd[MAXPLAYERS + 1];
float g_vRougeKickDir[MAXPLAYERS + 1][3];
bool  g_bRougeKickHit[MAXPLAYERS + 1];       // ya golpeo a alguien
float g_fRougeKickCDUntil[MAXPLAYERS + 1];

bool  g_bRougeCountering[MAXPLAYERS + 1];    // contragolpe activo
float g_fRougeCounterEnd[MAXPLAYERS + 1];
float g_fRougeCounterCDUntil[MAXPLAYERS + 1];
float g_fRougeBlockFxNext[MAXPLAYERS + 1];

// ---- v10-OM: avatar espejo (patron Knuckles v75) ----
ConVar g_cvRougeAvatar;
bool   g_bRougeModelOK = false;
int    g_iRougeAvatar[MAXPLAYERS + 1];       // EntRef copia R (0 = sin avatar)
int    g_iRougeAvatarL[MAXPLAYERS + 1];      // EntRef copia L
int    g_iRougeBodyRender[MAXPLAYERS + 1];   // render ORIGINAL del survivor
int    g_iRougeAnimState[MAXPLAYERS + 1];    // estado FSM actual
float  g_fRougeAnimLock[MAXPLAYERS + 1];     // lock de one-shot en curso
float  g_fRougeJumpStart[MAXPLAYERS + 1];    // t0 de la ventana del jump
float  g_fRougeBodyYaw[MAXPLAYERS + 1];      // yaw suavizado del avatar
float  g_fRougeYawLastT[MAXPLAYERS + 1];
bool   g_bRougeSmSnap[MAXPLAYERS + 1];
float  g_fRougeSmLoc[MAXPLAYERS + 1][3];
float  g_fRougeSmLocL[MAXPLAYERS + 1][3];
int    g_iRougeTintR[MAXPLAYERS + 1], g_iRougeTintG[MAXPLAYERS + 1], g_iRougeTintB[MAXPLAYERS + 1];
float  g_fRougeTintEnd[MAXPLAYERS + 1];
float  g_fRougeDeathHideUntil[MAXPLAYERS + 1];
float  g_vRougeDeathOrigin[MAXPLAYERS + 1][3];
Handle g_hRougeAvatarThink = null;
bool   g_bRougeGlideSeqOK = false;      // v11.0: el rouge.mdl trae la secuencia "glide" (modelo v15 compilado)
// (v10.6: g_fRougeHUDNext/g_fRougeHUDLastVal RETIRADOS — el HUD de
// energía vive en la BARRA SBar del manager, pintada por T_SBarThink
// a 5 Hz; ya no hay throttle propio del hint)

// ---- v10-OM: sonidos del lua (guard + fallback) ----
bool g_bRougeSndFlap = false, g_bRougeSndFlash = false;
bool g_bRougeSndBlazeKick = false, g_bRougeSndPunchStart = false, g_bRougeSndLatch = false;
bool g_bRougeSndKnxCounter = false, g_bRougeSndKnxPunchStun = false;   // v10.1: LOS SONIDOS DEL COUNTER DE KNUCKLES
bool g_bRougeSndSwing = false;

// ---- v10-OM: pool de lentitud (SI/tank) ----
int    g_iRougeSlowRef[ROUGE_SLOW_SLOTS];
float  g_fRougeSlowEnd[ROUGE_SLOW_SLOTS];
float  g_fRougeSlowMul[ROUGE_SLOW_SLOTS];
Handle g_hRougeSlowTick = null;

// v8.0: Evasión Instintiva
ConVar g_cvRougeEvadeChance;
float g_fRougeLastEvade[MAXPLAYERS + 1];   // throttle anti-spam de VFX
bool  g_bRougeEvadeFlash[MAXPLAYERS + 1];  // destello rosa activo (restaurar)

// Trackeo de bombas activas (reemplaza al g_bBombDetonated[2048])
ArrayList g_hRougeActiveBombs;

// Trackeo de charcos de acido activos (entidades insect_swarm)
ArrayList g_hRougeAcidPools;

// v7.2: DataPacks de timers NO_MAPCHANGE aún vivos (beep de bombas y
// tick de acido). Si el mapa cambia, esos timers mueren sin correr su
// callback y el "delete" del pack nunca ocurre -> leak. Se liberan todos
// en Rouge_OnMapEnd.
ArrayList g_hRougePendingPacks;

// v9.0: pool de arrastre de la Onda Negra (comunes + witches con el
// cerebro apagado y el cuerpo congelado). Patron de slots de
// Witch_Flight.inc: ref de entidad + estado ORIGINAL capturado antes
// de congelar, restaurado EXACTO al liberar.
int    g_iRWWRef[ROUGE_WAVE_SLOTS];         // referencia de entidad (0 = slot libre)
int    g_iRWWOrigMT[ROUGE_WAVE_SLOTS];      // movetype ORIGINAL (pre-congelamiento)
int    g_iRWWOrigFlags[ROUGE_WAVE_SLOTS];   // flags ORIGINALES (no pisamos frozen ajenos)
int    g_iRWWAttacker[ROUGE_WAVE_SLOTS];    // autor del cast (credito del dano de llegada)
float  g_fRWWEnd[ROUGE_WAVE_SLOTS];         // fin programado del arrastre del slot
float  g_fRWWLast[ROUGE_WAVE_SLOTS];        // último tick (dt real, anti lag-spike)
bool   g_bRWWWitch[ROUGE_WAVE_SLOTS];       // true = witch (rage al liberar)
Handle g_hRWWTick = null;                   // timer global compartido (patron WF)
float  g_vRWWCenter[ROUGE_WAVE_SLOTS][3];   // punto de convergencia por cast (multi-Rouge safe)

// Sprites
int g_iRougeGlowSprite = -1;
int g_iRougeBeamSprite = -1;
int g_iRougeHaloSprite = -1; // v7.2: halo para las explosiones (antes se precacheaba en runtime)

// v7.1: SDKCall para crear spit nativo del Spitter (sistema de Silvers)
Handle g_hRougeSDK_Spit = null;
bool g_bRougeAcidSpawn = false;  // Flag para detectar el próximo insect_swarm creado

// ConVars
ConVar g_cvRougeBaitCD, g_cvRougeBaitDamage;
ConVar g_cvRougeBombDamage, g_cvRougeBombRadius, g_cvRougeBombTimer, g_cvRougeBombCD;
ConVar g_cvRougeWaveCD, g_cvRougeWaveRadius, g_cvRougeWaveDamage;   // v9.0: H3 Onda Negra
// v10-OM: kit GMod
ConVar g_cvRougeEnergyStart, g_cvRougeEnergyMax, g_cvRougeEnergyRegen;
ConVar g_cvRougeLatchMax, g_cvRougeLatchDrain, g_cvRougeLatchJumpCost, g_cvRougeLatchLaunch;
ConVar g_cvRougeFlapMax, g_cvRougeFlapCost, g_cvRougeFlapPower, g_cvRougeFlapCD;
ConVar g_cvRougePassiveRed;
ConVar g_cvRougeKickCharge, g_cvRougeKickSpeed, g_cvRougeKickDuration, g_cvRougeKickRadius;
ConVar g_cvRougeKickStun, g_cvRougeKickCDHit, g_cvRougeKickCDMiss, g_cvRougeKickReward;
// v10.7-OM: el rango del barrido
ConVar g_cvRougeKickDmgMin, g_cvRougeKickDmgMax;
ConVar g_cvRougeParryCD, g_cvRougeParryDuration, g_cvRougeParryCommon, g_cvRougeParrySIDmg, g_cvRougeParryPush;
ConVar g_cvRougeParryRagdoll, g_cvRougeParryFling;   // v10.5: la patada baja vuela
ConVar g_cvRougeParryCDWhiff, g_cvRougeParryCDSucc;
ConVar g_cvRougePassiveRedMid, g_cvRougePassiveRedLow, g_cvRougeEnergySerious, g_cvRougeMaxHp;
ConVar g_cvRougeFlashRadius, g_cvRougeFlashSlowDur, g_cvRougeFlashSlow, g_cvRougeFlashStun, g_cvRougeFlashReward;

#define Rouge_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))
#define Rouge_IsValidEntity(%1) (IsValidEntity(%1) && (%1) != INVALID_ENT_REFERENCE)

// =======================
// Inicialización
// =======================

public void Rouge_OnPluginStart()
{
    // Habilidad 1: Cebo Quimico
    g_cvRougeBaitCD       = CreateConVar("rouge_bait_cooldown", "12.0", "Cooldown del Cebo Quimico", _, true, 0.0, true, 120.0);
    g_cvRougeBaitDamage   = CreateConVar("rouge_bait_damage", "300.0", "Dano de la explosión inicial del cebo", _, true, 0.0, true, 5000.0);

    // Habilidad 2: Bat Bomb Spray
    g_cvRougeBombDamage   = CreateConVar("rouge_bomb_damage", "600.0", "Dano de la explosión de la Bat Bomb", _, true, 0.0, true, 5000.0);
    g_cvRougeBombRadius   = CreateConVar("rouge_bomb_radius", "350.0", "Radio de explosión de la Bat Bomb", _, true, 50.0, true, 1500.0);
    g_cvRougeBombTimer    = CreateConVar("rouge_bomb_time", "1.5", "Tiempo para detonar si no toca a nadie", _, true, 0.1, true, 10.0);
    g_cvRougeBombCD       = CreateConVar("rouge_bomb_cooldown", "13.0", "v10.1: cooldown de la Bat Bomb (20 -35%: el cd de la granada)", _, true, 0.0, true, 120.0);

    // v8.0: Pasiva Evasión Instintiva (reemplazo de la Treasure Visión)
    g_cvRougeEvadeChance = CreateConVar("rouge_evade_chance", "30.0", "Probabilidad (0-100) de evadir un ataque y aturdir al atacante", _, true, 0.0, true, 100.0);

    // ---- v10-OM: KIT GMOD (defaults del lua) ----
    g_cvRougeEnergyStart = CreateConVar("rouge_energy_start", "75.0", "v10.1: energía inicial (30% del tope nuevo 250 — el lua era 30/100)", _, true, 0.0, true, 500.0);
    g_cvRougeEnergyMax   = CreateConVar("rouge_energy_max", "250.0", "v10.1: energía máxima (el owner: 100 -> 250)", _, true, 10.0, true, 1000.0);
    g_cvRougeEnergyRegen = CreateConVar("rouge_energy_regen", "3.0", "v10.1: regeneración por segundo (1.2 x 2.5 — el tope subió 100->250, misma velocidad de llenado)", _, true, 0.0, true, 100.0);
    g_cvRougeLatchMax    = CreateConVar("rouge_latch_max", "2", "v10: agarres de pared por vuelo (lua passive_latches_maximum 2)", _, true, 0.0, true, 10.0);
    g_cvRougeLatchDrain  = CreateConVar("rouge_latch_drain", "11.5", "v10.1: drenaje por segundo agarrada (23 -50% de consumo)", _, true, 0.0, true, 200.0);
    g_cvRougeLatchJumpCost = CreateConVar("rouge_latchjump_cost", "7.5", "v10.1: energía del salto desde pared (15 -50% de consumo)", _, true, 0.0, true, 100.0);
    g_cvRougeLatchLaunch = CreateConVar("rouge_latch_launch", "700.0", "v10: potencia del lanzazo desde pared (lua launchy_power 700)", _, true, 0.0, true, 3000.0);
    g_cvRougeFlapMax     = CreateConVar("rouge_flap_max", "0", "v10.2: 0 = SIN LIMITE de aleteos — SOLO ENERGÍA (owner); >0 = tope por vuelo (el lua era 3). OJO: si un Sonic_Suite.cfg viejo trae rouge_flap_max 3, ponerlo a 0", _, true, 0.0, true, 100.0);
    g_cvRougeFlapCost    = CreateConVar("rouge_flap_cost", "8.0", "v10.1: energía por aleteo (16 -50% de consumo)", _, true, 0.0, true, 100.0);
    g_cvRougeFlapPower   = CreateConVar("rouge_flap_power", "400.0", "v10: impulso vertical del aleteo (lua jumppower 400)", _, true, 0.0, true, 1000.0);
    g_cvRougeFlapCD      = CreateConVar("rouge_flap_cd", "6.0", "v10: cd por aleteo usado al aterrizar (lua cdperjump 6)", _, true, 0.0, true, 60.0);
    g_cvRougePassiveRed  = CreateConVar("rouge_passive_reduction", "0.80", "v10.1: fracción de dano con vida alta (20% de reducción; era 0.90 plano)", _, true, 0.05, true, 1.0);
    g_cvRougePassiveRedMid = CreateConVar("rouge_passive_reduction_mid", "0.65", "v10.1: fracción al 50% de vida o menos (35% de reducción)", _, true, 0.05, true, 1.0);
    g_cvRougePassiveRedLow = CreateConVar("rouge_passive_reduction_low", "0.50", "v10.1: fracción al 25% de vida o menos (50% de reducción)", _, true, 0.05, true, 1.0);
    g_cvRougeEnergySerious = CreateConVar("rouge_energy_serious", "88.0", "v10.1: umbral de la histeresis (35% de 250; el lua era 35/100)", _, true, 0.0, true, 1000.0);
    g_cvRougeMaxHp        = CreateConVar("rouge_maxhealth", "125", "v10.1: vida máxima (el lua: salud 125; receta Metal 175)", _, true, 1.0, true, 1000.0);

    g_cvRougeKickCharge   = CreateConVar("rouge_kick_charge", "0.35", "v10: carga del Barrido (lua sweepkick_chargeup 0.35)", _, true, 0.0, true, 3.0);
    g_cvRougeKickSpeed    = CreateConVar("rouge_kick_speed", "550.0", "v10: velocidad de la embestida (lua sweepkick_speed 550)", _, true, 100.0, true, 2000.0);
    g_cvRougeKickDuration = CreateConVar("rouge_kick_duration", "0.9", "v10: duración de la embestida (SequenceDuration del SweepKick)", _, true, 0.2, true, 3.0);
    g_cvRougeKickRadius   = CreateConVar("rouge_kick_radius", "118.75", "v10.3: radio de golpe del Barrido [95 -> 118.75: +25% AoE pedido del owner; lua FindInSphere 95]", _, true, 30.0, true, 300.0);
    CreateConVar("rouge_kick_damage", "225.0", "DEPRECATED v10.7: reemplazado por rouge_kick_dmg_min/_max (200-335 por golpe). Registrado para no ensuciar el Sonic_Suite.cfg — YA SIN EFECTO", _, true, 0.0, true, 5000.0);
    // v10.7-OM: EL BARRIDO CON RANGO (ronda 2 del owner) — 225 fijo -> 200-335
    g_cvRougeKickDmgMin   = CreateConVar("rouge_kick_dmg_min", "200",
        "v10.7: daño MINIMO del barrido / patada baja (antes 225 fijo)");
    g_cvRougeKickDmgMax   = CreateConVar("rouge_kick_dmg_max", "335",
        "v10.7: daño MAXIMO del barrido (aleatorio 200-335 por golpe)");
    g_cvRougeKickStun     = CreateConVar("rouge_kick_stun", "2.5", "v10: stagger del SI golpeado (lua basestun 5, recortado a L4D2)", _, true, 0.0, true, 10.0);
    g_cvRougeKickCDHit    = CreateConVar("rouge_kick_cd_hit", "6.0", "v10.1: recarga al golpear (el owner: 6s — buff de área)", _, true, 0.0, true, 120.0);
    g_cvRougeKickCDMiss   = CreateConVar("rouge_kick_cd_miss", "6.0", "v10.1: recarga al fallar (el owner: 6s flat)", _, true, 0.0, true, 120.0);
    g_cvRougeKickReward   = CreateConVar("rouge_kick_reward", "30.0", "v10: energía al golpear (lua sweepkick_reward 30)", _, true, 0.0, true, 100.0);

    g_cvRougeParryCD       = CreateConVar("rouge_parry_cooldown", "25.0", "v10.1: BASE de la recarga del Contragolpe (se cobra por % según el resultado)", _, true, 0.0, true, 120.0);
    g_cvRougeParryCDWhiff  = CreateConVar("rouge_parry_cd_whiff_pct", "55.0", "v10.1: % del base que se cobra si la ventana termina SIN bloquear (13.75s)", _, true, 0.0, true, 100.0);
    g_cvRougeParryCDSucc   = CreateConVar("rouge_parry_cd_success_pct", "85.0", "v10.1: % del base si hizo un COUNTER EXITOSO (21.25s — el éxito cobra más)", _, true, 0.0, true, 100.0);
    g_cvRougeParryDuration = CreateConVar("rouge_parry_duration", "7.0", "v10.3: duración del Contragolpe [6 -> 7s pedido del owner; v10.1: 6s — ya NO más debil que el de Knuckles]", _, true, 0.5, true, 30.0);
    g_cvRougeParryCommon   = CreateConVar("rouge_parry_common_dmg", "145.0", "v10.3: devolución a comunes [100 -> 145: +45% pedido del owner; v10.1: = Knuckles 100]", _, true, 0.0, true, 500.0);
    g_cvRougeParrySIDmg    = CreateConVar("rouge_parry_si_dmg", "290.0", "v10.3: devolución a especiales [200 -> 290: +45% pedido del owner; v10.1: = Knuckles 200]", _, true, 0.0, true, 1000.0);
    g_cvRougeParryPush     = CreateConVar("rouge_parry_push", "800.0", "v10.1: empuje de la devolución (= Knuckles: 800)", _, true, 0.0, true, 2000.0);
    g_cvRougeParryRagdoll  = CreateConVar("rouge_parry_ragdoll", "3.0", "v10.5: segundos de STUN+RAGDOLL de la PATADA BAJA del contragolpe (0 = desactivado: el stagger plano de antes)", _, true, 0.0, true, 12.0);
    g_cvRougeParryFling    = CreateConVar("rouge_parry_fling", "600", "v10.5: velocidad (u/s) del vuelo del ragdoll de la patada baja (horizontal alejando + elevación corta)", _, true, 0.0, true, 2000.0);

    g_cvRougeFlashRadius   = CreateConVar("rouge_flash_radius", "400.0", "v10: radio del destello del Cebo+Flash (lua FindInSphere 400)", _, true, 50.0, true, 1500.0);
    g_cvRougeFlashSlowDur  = CreateConVar("rouge_flash_slowdur", "6.0", "v10: duración de la lentitud post-destello (lua slowdownduration 6)", _, true, 0.0, true, 30.0);
    g_cvRougeFlashSlow     = CreateConVar("rouge_flash_slow", "0.70", "v10: multiplicador de velocidad post-destello (lua 0.7)", _, true, 0.1, true, 1.0);
    g_cvRougeFlashStun     = CreateConVar("rouge_flash_stun", "1.5", "v10: estatua de comunes/witch ante el destello (la ceguera)", _, true, 0.0, true, 10.0);
    g_cvRougeFlashReward   = CreateConVar("rouge_flash_reward", "20.0", "v10: energía si el destello alcanzo a alguien (lua smokebomb_reward 20)", _, true, 0.0, true, 100.0);

    g_cvRougeAvatar = CreateConVar("rouge_avatar", "1", "Rouge OM: avatar espejo (rouge.mdl del VPK de recursos, patron Tails/Sonic/Amy/Metal/Knuckles)", _, true, 0.0, true, 1.0);

    // v9.0: Habilidad 3 - Onda Negra (Black Wave)
    g_cvRougeWaveCD     = CreateConVar("rouge_wave_cooldown", "17.0", "v9: recarga de la Onda Negra (Habilidad 3)", _, true, 0.0, true, 120.0);
    g_cvRougeWaveRadius = CreateConVar("rouge_wave_radius", "1000.0", "v9: rango de la Onda Negra (rango S)", _, true, 100.0, true, 3000.0);
    g_cvRougeWaveDamage = CreateConVar("rouge_wave_damage", "400.0", "v9: dano base de la Onda Negra al llegar (comunes x2)", _, true, 0.0, true, 5000.0);

    // v7.1: Cargar gamedata para SDKCall de CSpitterProjectile_Create
    Rouge_LoadGamedata();

    // Comandos
    RegConsoleCmd("sm_rouge_kick", Command_RougeKick); // Mantiene el nombre por compatibilidad (el CEBO QUIMICO)
    RegConsoleCmd("sm_rouge_bomb", Command_RougeBomb);
    RegConsoleCmd("sm_rouge_wave", Command_RougeBlackWave);   // v9.0: Onda Negra — v10: fuera de slots, SOLO consola
    // v10-OM: el kit nuevo
    RegConsoleCmd("sm_rouge_sweep", Command_RougeSweepKick);  // H1 (Z): Barrido
    RegConsoleCmd("sm_rouge_counter", Command_RougeCounter);  // H2 (X): Contragolpe
    RegServerCmd("rouge_parry_blocked", Rouge_CmdParryBlocked, "v10: el VScript bloqueo algo en la ventana de Rouge (tinte + sonido)");

    // Hooks de eventos
    HookEvent("player_spawn", Rouge_Event_PlayerSpawn);
    HookEvent("player_death", Rouge_Event_PlayerDeath);
    HookEvent("round_start", Rouge_Event_RoundStart);

    // Inicializar ArrayLists
    g_hRougeActiveBombs = new ArrayList();
    g_hRougeAcidPools   = new ArrayList();
    g_hRougePendingPacks = new ArrayList(); // v7.2

    // v3.75: AutoExecConfig eliminado - config ÚNICA del suite (Sonic_Suite.cfg, auto-guardada; ver manager). El archivo viejo queda muerto.

    // Carga tardia: hookear clientes ya conectados
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            Rouge_OnClientPutInServer(i);
        }
    }
}

// v7.1: Carga el gamedata para el SDKCall de CSpitterProjectile_Create
// Requiere el archivo gamedata/rouge_abilities.txt
void Rouge_LoadGamedata()
{
    Handle hGameData = LoadGameConfigFile("rouge_abilities");
    if (hGameData == null)
    {
        PrintToServer("[Rouge] WARNING: No se pudo cargar gamedata/rouge_abilities.txt");
        PrintToServer("[Rouge] WARNING: El charco de acido nativo NO estara disponible.");
        PrintToServer("[Rouge] WARNING: Se usara el sistema de respaldo (timer de dano).");
        g_hRougeSDK_Spit = null;
        return;
    }

    StartPrepSDKCall(SDKCall_Static);
    if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CSpitterProjectile_Create"))
    {
        PrintToServer("[Rouge] WARNING: Signature CSpitterProjectile_Create no encontrada en gamedata.");
        delete hGameData;
        g_hRougeSDK_Spit = null;
        return;
    }
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
    PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
    PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
    g_hRougeSDK_Spit = EndPrepSDKCall();

    if (g_hRougeSDK_Spit == null)
    {
        PrintToServer("[Rouge] WARNING: No se pudo preparar el SDKCall de CSpitterProjectile_Create.");
    }
    else
    {
        PrintToServer("[Rouge] OK: SDKCall de CSpitterProjectile_Create cargado correctamente.");
    }

    delete hGameData;
}

// v7.1: Detecta cuando el motor crea un insect_swarm (charco de spit)
// Esto nos permite trackear el charco nativo que crea el SDKCall
public void OnEntityCreated(int entity, const char[] classname)
{
    if (entity <= 0 || entity > 2048) return;

    // v5.20 Tails: filtro anti-ragdoll del survivor (ventana de 2s tras
    // la muerte de un Tails con avatar; la lógica vive en Tails.inc.
    // Rouge se incluye DESPUÉS de Tails: la llamada resuelve directo.)
    Tails_OnEntityCreated(entity, classname);

    // v3.76 Sonic OM: mismo filtro anti-ragdoll para las muertes del
    // Sonic con avatar (la lógica vive en sonic.inc, incluido antes)
    Sonic_OnEntityCreated(entity, classname);

    // v3.77 Amy OM: idem para las muertes de la Amy con avatar
    // (la lógica vive en Amy.inc, incluida antes)
    Amy_OM_OnEntityCreated(entity, classname);

    // v3.77.25 Metal OM: idem para las muertes del Metal Sonic con
    // avatar (la lógica vive en Metal.inc — desde la 3.77.25 se incluye
    // ANTES de Rouge, así que el símbolo ya existe aquí)
    Metal_OnEntityCreated(entity, classname);

    // v3.77.30 Knuckles OM: idem para las muertes del Knuckles con
    // avatar (la lógica vive en Knuckles.inc, incluido antes que Rouge)
    Knuckles_OnEntityCreated(entity, classname);

    // v3.77.49 Shadow OM: idem para las muertes del Shadow con avatar
    // (la lógica vive en Shadow.inc, incluido antes que Rouge)
    Shadow_OnEntityCreated(entity, classname);
    Cream_OnEntityCreated(entity, classname);   // v3.77.68: ventana anti-corpse del avatar de Cream (8o avatar)
    Eggman_OnEntityCreated(entity, classname);  // v3.77.69: ventana anti-corpse del avatar de Eggman (9o avatar)
    Blaze_OnEntityCreated(entity, classname);   // v3.77.69: idem Blaze (10o avatar — modelo CST)
    Silver_OnEntityCreated(entity, classname);  // v3.77.69: idem Silver (11o avatar — modelo CST)

    // v10-OM Rouge: idem para las muertes de la Rouge con avatar — la
    // lógica es NUESTRA y vive aquí abajo (Rouge_CheckDeathRagdoll)
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
            if (g_fRougeDeathHideUntil[i] == 0.0 || nowOM >= g_fRougeDeathHideUntil[i])
                continue;
            RequestFrame(Rouge_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }

    // Si estamos esperando un insect_swarm (flag activado tras SDKCall)
    if (g_bRougeAcidSpawn)
    {
        if (strcmp(classname, "insect_swarm") == 0)
        {
            // Trackear en ArrayList
            if (g_hRougeAcidPools != null)
                g_hRougeAcidPools.Push(EntIndexToEntRef(entity));

            g_bRougeAcidSpawn = false;

            // Programar destrucción del charco al final de la duración
            CreateTimer(ROUGE_ACID_DURATION, T_RougeAcidCleanup, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
        }
    }
}

public void Rouge_OnMapStart()
{
    // v10-OM: AVATAR — rouge.mdl del VPK (detección FileExists estilo
    // star_stun: ve los VPK montados; sin el archivo TODO cae al
    // survivor normal, CERO dependencia)
    g_bRougeModelOK = FileExists(ROUGE_OM_MODEL, true);
    if (g_bRougeModelOK) PrecacheModel(ROUGE_OM_MODEL, true);

    // v10-OM: sonidos del lua GMod (guard + fallback vanilla)
    g_bRougeSndFlap      = PrecacheSound("om/rouge/flap.wav", true);            // aleteo (l.1004)
    g_bRougeSndFlash     = PrecacheSound("om/rouge/flashbomb.wav", true);       // destello (l.1246)
    g_bRougeSndBlazeKick = PrecacheSound("om/blaze/blazekick.wav", true);       // golpe del barrido (l.869)
    g_bRougeSndPunchStart= PrecacheSound("om/knuckles/punchstart.wav", true);   // carga del barrido (l.776)
    g_bRougeSndLatch     = PrecacheSound("om/knuckles/Latch.wav", true);        // pared (l.663, el mismo del lua)
    g_bRougeSndSwing     = PrecacheSound("om/knuckles/swing.wav", true);        // liberación del barrido (l.805)
    // v10.1: el counter suena COMO EL DE KNUCKLES ("su activación debe
    // llevar el mismo sonido de knuckles no el sonido del flash")
    g_bRougeSndKnxCounter   = PrecacheSound("om/knuckles/counter.wav", true);      // activación del Contragolpe
    g_bRougeSndKnxPunchStun = PrecacheSound("om/knuckles/punchstun.wav", true);    // bloqueo exitoso

    // v10-OM: FSM del avatar (10 Hz, patron T_KnuxAvatarThink) + pool de lentitud
    delete g_hRougeAvatarThink;
    g_hRougeAvatarThink = CreateTimer(0.1, T_RougeAvatarThink, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    delete g_hRougeSlowTick;
    g_hRougeSlowTick = CreateTimer(0.2, T_RougeSlowTick, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    Rouge_SlowClear();

    // Precache de sonidos
    PrecacheSound(ROUGE_SND_KICK_HIT, true);
    PrecacheSound(ROUGE_SND_THROW, true);
    PrecacheSound(ROUGE_SND_BEEP, true);
    PrecacheSound(ROUGE_SND_BOOM, true);
    PrecacheSound(ROUGE_SND_ACID, true);
    PrecacheSound(ROUGE_EVADE_SOUND, true);   // v8.0: evasión

    // v8.0: la Treasure Visión fue ELIMINADA (reemplazada por la
    // Evasión Instintiva, que no necesita timer: vive en el hook de
    // dano). Ya no se recrea ningún timer de escaneo aquí.

    // v9.0: particula de la Onda Negra en la tabla del motor (la
    // misma del agujero negro del Super Tank: si su addon ya la
    // precacheo, esto es un no-op inocuo).
    Rouge_WavePrecacheParticle("gas_explosion_ground_wave");

    // v9.1: modelo del NUCLEO de la Onda Negra (la esfera del escudo
    // de Sally / la bola de fuego de Knuckles: misma familia visual).
    PrecacheModel(ROUGE_WAVE_SPHERE_MDL, true);

    // v9.0: pool de arrastre limpio (nadie llega congelado a un mapa nuevo)
    Rouge_WaveResetPool();

    // Precache de modelos
    PrecacheModel(ROUGE_MODEL_BOMB, true);
    g_iRougeGlowSprite = PrecacheModel("materials/sprites/glow01.vmt", true);
    g_iRougeBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
    g_iRougeHaloSprite = PrecacheModel("materials/sprites/halo01.vmt", true);

    // Reset de estados por cliente
    for (int i = 1; i <= MaxClients; i++)
        Rouge_ResetState(i);

    // Limpiar ArrayLists
    if (g_hRougeActiveBombs != null) g_hRougeActiveBombs.Clear();
    if (g_hRougeAcidPools != null)   g_hRougeAcidPools.Clear();
}

public void Rouge_OnMapEnd()
{
    // v10-OM: timers del kit GMod (mueren con el mapa: NO_MAPCHANGE)
    delete g_hRougeAvatarThink;
    delete g_hRougeSlowTick;
    Rouge_SlowClear();
    for (int i = 1; i <= MaxClients; i++)
    {
        g_iRougeAvatar[i] = 0;     // las entidades murieron con el mapa
        g_iRougeAvatarL[i] = 0;
        g_iRougeAnimState[i] = -1;
        g_fRougeDeathHideUntil[i] = 0.0;
    }

    if (g_hRougeActiveBombs != null) g_hRougeActiveBombs.Clear();
    if (g_hRougeAcidPools != null)   g_hRougeAcidPools.Clear();

    // v9.0: matar el tick del arrastre y vaciar slots (las entidades
    // mueren con el mapa: nadie queda congelado).
    Rouge_WaveResetPool();

    // v7.2 FIX LEAK: los timers de beep/acido llevan TIMER_FLAG_NO_MAPCHANGE,
    // así que al cambiar de mapa mueren silenciosamente SIN ejecutar su
    // callback -> los DataPacks que aún no se hubieran liberado con
    // "delete" quedarian colgados para siempre (leak real de memoria por
    // cada uso de la habilidad en la ventana del cambio de mapa).
    Rouge_FreePendingPacks();
}

// =======================
// Gestion de Estados
// =======================

// v7.2: registra un DataPack para su liberación garantizada (ver
// Rouge_OnMapEnd). Se invoca justo después de CreateTimer con el pack.
void Rouge_TrackPack(DataPack pk)
{
    if (pk == null) return;
    if (g_hRougePendingPacks == null) return;
    if (g_hRougePendingPacks.FindValue(pk) == -1)
        g_hRougePendingPacks.Push(pk);
}

// v7.2: libera y des-registra un DataPack (sustituye al "delete" directo
// en los callbacks de los timers trackeados).
void Rouge_UntrackPack(Handle pk)
{
    if (pk == null) return;
    if (g_hRougePendingPacks != null)
    {
        int idx = g_hRougePendingPacks.FindValue(pk);
        if (idx != -1) g_hRougePendingPacks.Erase(idx);
    }
    delete pk;
}

// v7.2: libera todos los DataPacks pendientes (mapchange).
void Rouge_FreePendingPacks()
{
    if (g_hRougePendingPacks == null) return;
    for (int i = g_hRougePendingPacks.Length - 1; i >= 0; i--)
    {
        DataPack pk = view_as<DataPack>(g_hRougePendingPacks.Get(i));
        delete pk;
    }
    g_hRougePendingPacks.Clear();
}

public void Rouge_OnClientPutInServer(int client)
{
    if (client < 1 || client > MaxClients) return;

    SDKUnhook(client, SDKHook_OnTakeDamage, Rouge_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Rouge_OnTakeDamage);

    SDKUnhook(client, SDKHook_PreThink, Rouge_PreThink);
    SDKHook(client, SDKHook_PreThink, Rouge_PreThink);

    // v10-OM: sentinel del render del cuerpo (patron Knuckles — el
    // avatar lo pisa al montar y lo devuelve al morir)
    g_iRougeBodyRender[client] = -1;
}

public void Rouge_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    // Limpiar bombas y charcos activos al iniciar ronda
    if (g_hRougeActiveBombs != null) g_hRougeActiveBombs.Clear();
    if (g_hRougeAcidPools != null)   g_hRougeAcidPools.Clear();

    // v9.0: arrastre fuera (la ronda nueva repuebla infectados limpios)
    Rouge_WaveResetPool();
}

public void Rouge_Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client)) return;

    if (g_iPlayerCharIdx[client] == ROUGE_INDEX)
    {
        Rouge_ResetState(client);
        Rouge_ApplyMaxHealth(client);   // v10.1: vida max 125 (receta Metal 175)
        // Re-hookear por seguridad
        SDKUnhook(client, SDKHook_OnTakeDamage, Rouge_OnTakeDamage);
        SDKHook(client, SDKHook_OnTakeDamage, Rouge_OnTakeDamage);
        SDKUnhook(client, SDKHook_PreThink, Rouge_PreThink);
        SDKHook(client, SDKHook_PreThink, Rouge_PreThink);
    }
}

public void Rouge_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client)) return;

    // v7.2 FIX: solo resetear el estado si la victima es Rouge. Antes este
    // hook (que escucha TODAS las muertes del servidor) corria
    // Rouge_ResetState sobre cualquier victima, pisando el color/movetype
    // que otros modulos acaban de restaurar en su propia limpieza de muerte.
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return;

    // v10-OM: MUERTE DEL AVATAR — ragdoll rouge.mdl con la velocidad del
    // momento + ventana anti-corpse (receta Knuckles v75/Metal v5.0) y el
    // cuerpo del survivor vuelve a verse para el spectate/revive.
    if (g_iRougeAvatar[client] != 0)
    {
        Rouge_SpawnDeathRagdoll(client);
        g_fRougeDeathHideUntil[client] = GetEngineTime() + 2.0;
        GetClientAbsOrigin(client, g_vRougeDeathOrigin[client]);
        Rouge_KillAvatarOnly(client);
    }

    Rouge_ResetState(client);
}

void Rouge_ResetState(int client)
{
    if (client < 0 || client > MaxClients) return;

    // v10-OM: kit GMod — el contragolpe avisa SU apagado al VScript
    // (patron Knux_ResetState v75: la ventana muere con el estado)
    if (g_bRougeCountering[client])
        Rouge_ParryNotifyNut(client, false, 0.0);
    g_bRougeCountering[client] = false;
    g_fRougeCounterEnd[client] = 0.0;
    if (g_iRougeKickPhase[client] != ROUGE_KICK_NONE)
    {
        if (g_iRougeKickPhase[client] == ROUGE_KICK_DASH)
            SDKUnhook(client, SDKHook_Touch, Rouge_OnTouch);
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    }
    g_iRougeKickPhase[client] = ROUGE_KICK_NONE;
    g_bRougeKickHit[client] = false;
    if (g_bRougeLatched[client])
    {
        if (IsClientInGame(client) && IsPlayerAlive(client))
            SetEntityMoveType(client, MOVETYPE_WALK);
    }
    g_bRougeLatched[client] = false;
    g_iRougeLatches[client] = 0;
    g_iRougeUsedJumps[client] = 0;
    g_fRougeJumpCDUntil[client] = 0.0;
    g_iRougePrevButtons[client] = 0;
    g_fRougeEnergy[client] = g_cvRougeEnergyStart != null ? g_cvRougeEnergyStart.FloatValue : 30.0;
    g_bRougeRegenSerious[client] = false;

    g_bRougeGliding[client]     = false;
    g_bRougeBraking[client]     = false;   // v10.1
    g_fRougeNextLatchTime[client] = 0.0;   // v10.1
    g_bRougeCounterHit[client]  = false;   // v10.1
    g_fRougeBaitCooldown[client] = 0.0;
    g_fRougeBombCooldown[client] = 0.0;
    g_fRougeWaveCooldown[client] = 0.0;   // v9.0: H3 Onda Negra
    g_fRougeLastEvade[client]   = 0.0;   // v8.0

    if (IsClientInGame(client))
    {
        SetEntityRenderColor(client, 255, 255, 255, 255);
        g_bRougeEvadeFlash[client] = false;   // v8.0: sin destello pendiente
        // v10.1: el freno aéreo usa gravedad 0 — NUNCA heredarla
        if (IsPlayerAlive(client))
            SetEntityGravity(client, 1.0);
        SetEntProp(client, Prop_Data, "m_CollisionGroup", 5);
        SetEntProp(client, Prop_Send, "m_CollisionGroup", 5);

        if (!GetEntProp(client, Prop_Send, "m_isIncapacitated"))
        {
            SetEntityMoveType(client, MOVETYPE_WALK);
            float stop[3] = {0.0, 0.0, 0.0};
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, stop);
        }
    }
}

// =======================
// PASIVAS: BAT GLIDE v8.0 (planeo REAL) & FALL IMMUNITY
// =======================

public void Rouge_PreThink(int client)
{
    if (!Rouge_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return;

    // ============================ v10-OM: NUCLEO DEL KIT GMOD ============
    float now = GetEngineTime();
    static float s_fLastT[MAXPLAYERS + 1];
    float dt = now - s_fLastT[client];
    s_fLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.015;

    int buttons10 = GetClientButtons(client);
    bool jumpPressed = ((buttons10 & IN_JUMP) != 0 && (g_iRougePrevButtons[client] & IN_JUMP) == 0);
    g_iRougePrevButtons[client] = buttons10;

    bool airborne = !(GetEntityFlags(client) & FL_ONGROUND);

    // ---- CONTRAGOLPE: expiración ----
    if (g_bRougeCountering[client] && now >= g_fRougeCounterEnd[client])
        Rouge_StopCounter(client);

    // ---- BARRIDO: maquina de fases (carga -> embestida) ----
    if (g_iRougeKickPhase[client] == ROUGE_KICK_CHARGING)
    {
        if (now >= g_fRougeKickChargeEnd[client])
        {
            // liberar la embestida (el lua suelta el SweepKick al acabar
            // la carga: anim + velocidad delante + i-frames)
            g_iRougeKickPhase[client] = ROUGE_KICK_DASH;
            g_fRougeKickDashEnd[client] = now + g_cvRougeKickDuration.FloatValue;
            g_bRougeKickHit[client] = false;
            Rouge_KickHitClear(client);   // v10.1: lista de victims del área

            float ang[3], fwd[3];
            GetClientEyeAngles(client, ang); ang[0] = 0.0; ang[2] = 0.0;
            GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
            g_vRougeKickDir[client][0] = fwd[0];
            g_vRougeKickDir[client][1] = fwd[1];
            g_vRougeKickDir[client][2] = 0.0;

            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            Rouge_AvatarOneShot(client, ROUGE_ST_KICK, ROUGE_LOCK_KICK);
            if (g_bRougeSndSwing) EmitSoundToAll("om/knuckles/swing.wav", client, _, ROUGE_SND_LEVEL);
            else EmitSoundToAll(ROUGE_SND_KICK_HIT, client, _, 120);
            SDKHook(client, SDKHook_Touch, Rouge_OnTouch);
        }
        else
        {
            // carga: paso corto (el lua clava la velocidad a walk*1.5)
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.7);
        }
    }
    else if (g_iRougeKickPhase[client] == ROUGE_KICK_DASH)
    {
        if (now >= g_fRougeKickDashEnd[client])
        {
            // fin de la embestida: recarga según si golpeo (lua cd_hit/cd_miss)
            SDKUnhook(client, SDKHook_Touch, Rouge_OnTouch);
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            g_iRougeKickPhase[client] = ROUGE_KICK_NONE;
            g_fRougeKickCDUntil[client] = now + (g_bRougeKickHit[client]
                ? g_cvRougeKickCDHit.FloatValue : g_cvRougeKickCDMiss.FloatValue);
            if (!g_bRougeKickHit[client])
                PrintCenterText(client, "Barrido al aire (%.0fs de recarga)", g_cvRougeKickCDMiss.FloatValue);
            else
                PrintCenterText(client, "¡BARRIDO! %d golpeado(s) — recarga %.0fs", g_iRougeKickHitCount[client], g_cvRougeKickCDHit.FloatValue);
        }
        else
        {
            // mantener la embestida (el lua setea la velocidad por tick)
            float vel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            vel[0] = g_vRougeKickDir[client][0] * g_cvRougeKickSpeed.FloatValue;
            vel[1] = g_vRougeKickDir[client][1] * g_cvRougeKickSpeed.FloatValue;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

            // v10.1: EL BUFF DE ÁREA — la esfera barre TODO lo cercano
            // cada frame de la embestida (una vez por victima)
            Rouge_KickAreaSweep(client);
        }
    }

    // ---- ENERGÍA: regen + histeresis del lua (<=1 sería -> pide 35) ----
    float emax = g_cvRougeEnergyMax.FloatValue;
    if (!g_bRougeLatched[client])
    {
        g_fRougeEnergy[client] += g_cvRougeEnergyRegen.FloatValue * dt;
        if (g_fRougeEnergy[client] > emax) g_fRougeEnergy[client] = emax;
    }
    // v10.1: el umbral de la histeresis escala con el tope nuevo
    // (35/100 -> 88/250, misma fracción; convar rouge_energy_serious)
    float seriousAt = (g_cvRougeEnergySerious != null) ? g_cvRougeEnergySerious.FloatValue : 88.0;
    if (g_fRougeEnergy[client] <= 1.0) g_bRougeRegenSerious[client] = true;
    if (g_bRougeRegenSerious[client] && g_fRougeEnergy[client] >= seriousAt)
        g_bRougeRegenSerious[client] = false;

    // ---- SUELO: recarga de agarres + cd de aleteos (el lua) ----
    if (!airborne)
    {
        if (g_iRougeUsedJumps[client] > 0)
            // v10.2: cd PLANO al aterrizar — el lua lo multiplicaba por
            // aleteos usados (6 × N): con vuelo ilimitado eran 120s de
            // muro oculto. rouge_flap_cd 0 lo quita del todo.
            g_fRougeJumpCDUntil[client] = now + g_cvRougeFlapCD.FloatValue;
        g_iRougeUsedJumps[client] = 0;
        g_iRougeLatches[client] = g_cvRougeLatchMax.IntValue;
        if (g_bRougeLatched[client]) g_bRougeLatched[client] = false;
    }

    // ---- AGARRE DE PARED (LatchOntoWall_OM_Knuckels del lua) ----
    if (g_bRougeLatched[client])
    {
        // mantenimiento: drenaje + condiciones de ruptura
        g_fRougeEnergy[client] -= g_cvRougeLatchDrain.FloatValue * dt;

        bool soltar = false;
        if (g_fRougeEnergy[client] <= 0.0) soltar = true;

        // el suelo esta a menos de 25u? (el lua rompe el agarre)
        float pos[3], down[3], vGround[3];
        GetClientAbsOrigin(client, pos);
        down[0] = pos[0]; down[1] = pos[1]; down[2] = pos[2] - 900.0;
        Handle tr = TR_TraceRayFilterEx(pos, down, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Rouge_TraceFilter_World, 0);
        if (TR_DidHit(tr))
        {
            TR_GetEndPosition(vGround, tr);
            if (GetVectorDistance(pos, vGround) < 25.0) soltar = true;
        }
        delete tr;

        // v10.1: SPACE = salida IDENTICA A LA DE KNUCKLES ("el agarre de
        // pared será basicamente identica a la de knuckles. Ella salta se
        // eleva y vuela"): el impulso sale por la NORMAL de la pared (no
        // por la cámara — ya no se re-estrella contra la que dejo atras),
        // 450 de empuje vertical, ENCIENDE EL PLANEO SOLA y deja 0.5s de
        // cd antes de poder volver a pegarse (receta Knux_PreThink v67).
        if (jumpPressed)
        {
            soltar = true;
            float launch[3];
            launch[0] = g_fRougeLatchNormal[client][0] * g_cvRougeLatchLaunch.FloatValue;
            launch[1] = g_fRougeLatchNormal[client][1] * g_cvRougeLatchLaunch.FloatValue;
            launch[2] = 450.0;   // el "gran empuje hacia arriba" de Knuckles
            SetEntityMoveType(client, MOVETYPE_WALK);
            SetEntityGravity(client, 1.0);
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, launch);
            g_fRougeEnergy[client] -= g_cvRougeLatchJumpCost.FloatValue;
            g_fRougeNextLatchTime[client] = now + 0.5;
            g_bRougeGliding[client] = true;    // ...y vuela: planeo activo YA
            Rouge_AvatarOneShot(client, ROUGE_ST_JUMP, ROUGE_LOCK_LATCHOFF);
            if (g_bRougeSndFlap) EmitSoundToAll("om/rouge/flap.wav", client, _, ROUGE_SND_LEVEL);
            PrintCenterText(client, "¡Lanzada! (planeo ON — tap SPACE = aleteo para subir)");
        }

        if (soltar)
        {
            if (g_bRougeLatched[client])
            {
                SetEntityMoveType(client, MOVETYPE_WALK);
                g_bRougeLatched[client] = false;
            }
        }
    }
    else if (airborne)
    {
        // pegarse: pared al frente (20u del lua) + agarres + energía
        if (g_iRougeLatches[client] > 0
            && now >= g_fRougeNextLatchTime[client]      // v10.1: 0.5s tras salir (como Knuckles)
            && g_fRougeEnergy[client] > 1.0
            && !g_bRougeRegenSerious[client]
            && g_iRougeKickPhase[client] == ROUGE_KICK_NONE)
        {
            float pos[3], end[3], fwd[3], ang[3];
            GetClientAbsOrigin(client, pos);
            GetClientEyeAngles(client, ang); ang[0] = 0.0; ang[2] = 0.0;
            GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
            end[0] = pos[0] + fwd[0] * 20.0;
            end[1] = pos[1] + fwd[1] * 20.0;
            end[2] = pos[2] + fwd[2] * 20.0;

            Handle trw = TR_TraceRayFilterEx(pos, end, MASK_SOLID, RayType_EndPoint, Rouge_TraceFilter_World, 0);
            bool hitWall = TR_DidHit(trw);
            float normal[3];
            if (hitWall)
            {
                TR_GetPlaneNormal(trw, normal);
                if (normal[2] > 0.5 || normal[2] < -0.5) hitWall = false;  // pared VERTICAL nada más (lua)
            }
            if (hitWall)
            {
                // lejos del piso (>25u, el lua)
                float down[3], vGround[3];
                down[0] = pos[0]; down[1] = pos[1]; down[2] = pos[2] - 900.0;
                Handle trg = TR_TraceRayFilterEx(pos, down, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Rouge_TraceFilter_World, 0);
                bool sueloLejos = true;
                if (TR_DidHit(trg))
                {
                    TR_GetEndPosition(vGround, trg);
                    if (GetVectorDistance(pos, vGround) < 25.0) sueloLejos = false;
                }
                delete trg;

                if (sueloLejos)
                {
                    g_bRougeLatched[client] = true;
                    g_iRougeLatches[client]--;
                    g_bRougeGliding[client] = false;
                    // v10.1: pegarse apaga el freno (si venía frenando,
                    // su gravedad 0 NO puede heredarse al agarre)
                    if (g_bRougeBraking[client])
                    {
                        g_bRougeBraking[client] = false;
                        SetEntityGravity(client, 1.0);
                    }
                    g_iRougeKickPhase[client] = ROUGE_KICK_NONE;
                    // v10.1: la NORMAL de la pared — la salida de Knuckles
                    // sale por la NORMAL (l.700 del lua), no por la cámara
                    g_fRougeLatchNormal[client][0] = normal[0];
                    g_fRougeLatchNormal[client][1] = normal[1];
                    g_fRougeLatchNormal[client][2] = normal[2];

                    float stop[3] = {0.0, 0.0, 0.0};
                    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, stop);
                    SetEntityMoveType(client, MOVETYPE_NONE);
                    // mirar HACIA AFUERA de la pared (pill_assignedangle del lua)
                    g_fRougeLatchYaw[client] = RadToDeg(ArcTangent2(normal[1], normal[0]));

                    if (g_bRougeSndLatch) EmitSoundToAll("om/knuckles/Latch.wav", client, _, ROUGE_SND_LEVEL);
                    else EmitSoundToAll("weapons/knife/knife_hit_wall1.wav", client, _, ROUGE_SND_LEVEL);
                    PrintCenterText(client, "🦇 Agarrada (SPACE para lanzarte)");
                }
            }
            delete trw;
        }

        // ---- ALETEO v11.0: VIVE DENTRO DEL PLANEO — el primer tap en
        // el aire ABRE LAS ALAS (activa el planeo, gratis: bloque de
        // abajo) y los taps SIGUIENTES ya son aleteos que la elevan
        // (la diferencia con Knuckles: ella SI puede subir). SIN
        // LIMITE de cantidad — el único limite es la ENERGÍA (owner:
        // "el vuelo no tiene limite de saltos de vuelo. Solo dependera
        // es de la energía"). rouge_flap_max 0 = ilimitado; >0 = tope
        // (palanca por si se quiere devolver) ----
        if (jumpPressed && g_bRougeGliding[client] && !g_bRougeLatched[client]
            && g_iRougeKickPhase[client] == ROUGE_KICK_NONE
            && (g_cvRougeFlapMax.IntValue <= 0
                || g_iRougeUsedJumps[client] < g_cvRougeFlapMax.IntValue)
            && now >= g_fRougeJumpCDUntil[client]
            && g_fRougeEnergy[client] - g_cvRougeFlapCost.FloatValue > 0.0)
        {
            g_iRougeUsedJumps[client]++;
            float vel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            // v10.2: potencia PLENA en cada aleteo — el decaimiento del lua
            // (7.5% por salto, hecho para un tope de 3) con aleteo
            // ilimitado llegaba a cero y NEGATIVO; solo la energía manda
            vel[2] = g_cvRougeFlapPower.FloatValue;
            vel[0] *= 0.85;
            vel[1] *= 0.85;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
            g_fRougeEnergy[client] -= g_cvRougeFlapCost.FloatValue;
            // v10.1: el aleteo ya NO apaga el planeo (ambas pasivas
            // COMBINADAS: tap = elevarse, mantener = seguir volando)
            Rouge_AvatarOneShot(client, ROUGE_ST_FLAP, ROUGE_LOCK_FLAP);
            if (g_bRougeSndFlap) EmitSoundToAll("om/rouge/flap.wav", client, _, ROUGE_SND_LEVEL);
            else EmitSoundToAll("player/survivor/hit/crowbar_swing_miss1.wav", client, _, 100);
        }
    }

    // ---- tinte del avatar (v10.6: el HUD de energía vive en la BARRA
    // SBar del manager 3.77.85 — Rouge_EnergyHUD RETIRADO como el
    // hint de anillos de Sonic v6.36: la barra pinta EN VIVO a 5 Hz) ----
    Rouge_TintThink(client);
    // ========================== FIN NUCLEO v10-OM ========================

    // v8.0: cancelar si esta incapacitada o AGARRADA (antes solo se
    // comprobaba el hunter: un jockey/smoker/charger la agarraba en
    // pleno planeo y el PreThink seguía peleando con la velocidad).
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0
        || GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0
        || GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0
        || GetEntPropEnt(client, Prop_Send, "m_tongueOwner")  > 0
        || GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0
        || GetEntPropEnt(client, Prop_Send, "m_carryAttacker")  > 0)
    {
        // v8.0 FIX: solo apagar el planeo (NO llamar a ResetState:
        // eso ponía a 0 los cooldowns de las habilidades = reset
        // gratis de CDs con solo ser agarrada planeando).
        // v10-OM: el kit GMod se ROMPE limpio (agarre/incap): barrido
        // fuera, pared fuera, contragolpe fuera (con SU recarga y SU
        // aviso de apagado al VScript) — sin tocar los cooldowns.
        g_bRougeGliding[client] = false;
        // v10.1: el freno (y su gravedad 0) se rompe limpio igual que el
        // resto — nadie hereda un hover colgado
        if (g_bRougeBraking[client])
        {
            g_bRougeBraking[client] = false;
            SetEntityGravity(client, 1.0);
        }
        if (g_iRougeKickPhase[client] != ROUGE_KICK_NONE)
        {
            if (g_iRougeKickPhase[client] == ROUGE_KICK_DASH)
                SDKUnhook(client, SDKHook_Touch, Rouge_OnTouch);
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            g_iRougeKickPhase[client] = ROUGE_KICK_NONE;
        }
        if (g_bRougeLatched[client])
        {
            SetEntityMoveType(client, MOVETYPE_WALK);
            g_bRougeLatched[client] = false;
        }
        if (g_bRougeCountering[client])
            Rouge_StopCounter(client);
        return;
    }

    int flags = GetEntityFlags(client);
    int buttons = GetClientButtons(client);

    // ---- v10.1: FRENO AÉREO (SHIFT) — "puede presionar shift en el
    // aire para frenar en el aire (literal reducir la velocidad hasta
    // frenar)": gravedad 0 + decaimiento exponencial de TODA la
    // velocidad -> se queda QUIETA en el aire (el hover del FlyIdle).
    // Suelta SHIFT y cae/planea normal. El steering aéreo del manager
    // sigue vivo frenando: moverse frenando = glide (v11.0; FlyRun si
    // el modelo viejo no trae la secuencia).
    if (!(flags & FL_ONGROUND) && (buttons & IN_SPEED) && !g_bRougeLatched[client]
        && g_iRougeKickPhase[client] == ROUGE_KICK_NONE)
    {
        g_bRougeBraking[client] = true;
        SetEntityGravity(client, 0.0);

        float bvel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", bvel);
        float bk = 1.0 - ROUGE_BRAKE_RATE * dt;
        if (bk < 0.0) bk = 0.0;
        bvel[0] *= bk; bvel[1] *= bk; bvel[2] *= bk;
        if (GetVectorLength(bvel) < ROUGE_BRAKE_STOP)
        {
            bvel[0] = 0.0; bvel[1] = 0.0; bvel[2] = 0.0;
        }
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, bvel);

        // frenar apaga el planeo (son modos opuestos del mismo vuelo)
        g_bRougeGliding[client] = false;
    }
    else if (g_bRougeBraking[client])
    {
        // solto SHIFT / tocó pared / embistiendo: gravedad de vuelta
        g_bRougeBraking[client] = false;
        SetEntityGravity(client, 1.0);
    }

    // ---- EN SUELO: fin del planeo + del freno ----
    if (flags & FL_ONGROUND)
    {
        if (g_bRougeGliding[client] || g_bRougeBraking[client])
        {
            g_bRougeGliding[client] = false;
            g_bRougeBraking[client] = false;
            SetEntityGravity(client, 1.0);
        }
        return;
    }

    // ---- EN EL AIRE ----
    // v11.0: EL PLANEO YA NO SE SUELTA — activación estilo Knuckles: se
    // enciende con el TAP de SPACE (bloque de abajo) o con el lanzazo
    // de pared, y se queda ON hasta aterrizar / agarrar pared / frenar
    // con SHIFT / que la rompan (incap/agarres, mas arriba). Soltar
    // SPACE NO hace nada (v10.1 lo apagaba al soltar — fuera). El gate
    // del KICK: si esta embistiendo (Z en el aire) la maquina del
    // Barrido manda ese frame — el cap del planeo NO le pelea la
    // velocidad a la embestida; al acabar el dash sigue planeando.
    if (g_bRougeGliding[client] && g_iRougeKickPhase[client] == ROUGE_KICK_NONE)
    {

        // v8.0 FIX PRINCIPAL (bug "el planeo no planea"): la versión
        // antigua aplicaba el cap de caida y el steering UNA SOLA VEZ
        // (en el frame de activación). A partir del frame siguiente la
        // gravedad del motor volvia a acelerar la caida hasta velocidad
        // terminal y el "planeo" caía como una piedra. Ahora el cap y el
        // steering se MANTIENEN en cada PreThink mientras dure el vuelo.
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);

        // Caida capada: nunca cae más rápido que ROUGE_GLIDE_FALL
        if (vel[2] < ROUGE_GLIDE_FALL) vel[2] = ROUGE_GLIDE_FALL;

        // Steering aéreo continuo (WASD)
        float fwdAng[3], fwd[3], right[3];
        GetClientEyeAngles(client, fwdAng); fwdAng[0] = 0.0;
        GetAngleVectors(fwdAng, fwd, right, NULL_VECTOR);

        if (buttons & IN_FORWARD)   { vel[0] += fwd[0]  * ROUGE_GLIDE_ACCEL; vel[1] += fwd[1]  * ROUGE_GLIDE_ACCEL; }
        if (buttons & IN_BACK)      { vel[0] -= fwd[0]  * ROUGE_GLIDE_ACCEL; vel[1] -= fwd[1]  * ROUGE_GLIDE_ACCEL; }
        if (buttons & IN_MOVELEFT)  { vel[0] -= right[0] * ROUGE_GLIDE_ACCEL; vel[1] -= right[1] * ROUGE_GLIDE_ACCEL; }
        if (buttons & IN_MOVERIGHT) { vel[0] += right[0] * ROUGE_GLIDE_ACCEL; vel[1] += right[1] * ROUGE_GLIDE_ACCEL; }

        // Cap de velocidad horizontal
        float speed2D = SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
        if (speed2D > ROUGE_GLIDE_HORIZ_MAX)
        {
            vel[0] = (vel[0] / speed2D) * ROUGE_GLIDE_HORIZ_MAX;
            vel[1] = (vel[1] / speed2D) * ROUGE_GLIDE_HORIZ_MAX;
        }

        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
    }
    else
    {
        // v11.0: ACTIVACIÓN ESTILO KNUCKLES — un TAP de SPACE en el
        // aire despliega las alas y el planeo SE QUEDA ON (nada que
        // mantener: Knuckles sale de su pared ya planeando y vuela
        // hasta aterrizar; aqui igual, sin pedir pared). El salto del
        // SUELO no la enciende: el borde del SPACE se consume en el
        // piso — hay que RE-APRETAR EN el aire (el doble-salto clasico
        // de los Sonic). Con el planeo ya ON, cada tap nuevo es el
        // ALETEO que la eleva (vive arriba, en el borde del boton).
        if (jumpPressed && !g_bRougeBraking[client]
            && g_iRougeKickPhase[client] == ROUGE_KICK_NONE)
        {
            g_bRougeGliding[client] = true;

            float vel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            if (vel[2] < ROUGE_GLIDE_FALL) vel[2] = ROUGE_GLIDE_FALL;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

            // VFX de despliegue: anillo rosa + aviso
            float pos[3];
            GetClientAbsOrigin(client, pos); pos[2] += 20.0;
            TE_SetupBeamRingPoint(pos, 10.0, 90.0, g_iRougeBeamSprite, 0, 0, 0, 0.4, 6.0, 0.0, {255, 20, 147, 220}, 0, 0);
            TE_SendToAll();
            PrintCenterText(client, "¡PLANEO! (tap SPACE = aleteo para subir / WASD dirige / SHIFT frena)");
        }
    }
}

public Action Rouge_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Rouge_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != ROUGE_INDEX) return Plugin_Continue;

    // v10-OM: I-FRAMES DEL BARRIDO (el lua pone OM_Damage_Reduction=0
    // durante el SweepKick: embiste intocable)
    if (g_iRougeKickPhase[victim] == ROUGE_KICK_DASH)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // v10-OM: CONTRAGOLPE — bloqueo TODO y devuelvo LA PATADA BAJA
    // VUELA (v10.5, pedido del owner: "hay que aplicar el stun ragdoll
    // a rouge... rouge es una patada baja"): dano amplificado (hibrido
    // x2 + % vs jefes) + stun-ragdoll con la dirección de la patada
    // (horizontal alejando + elevación corta — una patada baja barre,
    // no levanta). Tank incluido (con desarme de 5s como Knuckles en
    // su counter de tank). La DEVOLUCION DE PROYECTILES la lleva SU
    // ventana del VScript (ChCh_RougeNotify del chch_parrying.nut v2.9).
    if (g_bRougeCountering[victim] && attacker > 0)
    {
        g_bRougeCounterHit[victim] = true;   // v10.1: bloqueo -> éxito
        float vPos[3], aPos[3];
        GetClientAbsOrigin(victim, vPos);

        if (attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == TEAM_INFECTED)
        {
            GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", aPos);

            // v10.5: LA PATADA BAJA — DIFERIDA 0.05s (la receta de los
            // agarres de este mismo archivo: NADA de spawnear ragdolls
            // DENTRO del callback de dano; el timer re-valida vivos)
            DataPack kpack = new DataPack();
            kpack.WriteCell(GetClientUserId(victim));
            kpack.WriteCell(GetClientUserId(attacker));
            CreateTimer(0.05, T_RougeCounterKick, kpack,
                        TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
        }
        else
        {
            char cls[32];
            GetEntityClassname(attacker, cls, sizeof(cls));
            if (StrEqual(cls, "infected"))
            {
                // común: dano amplificado AQUÍ (probado) + el cuerpo
                // volando DIFERIDO (el spawn sale del callback)
                float dir[3];
                GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", aPos);
                MakeVectorFromPoints(vPos, aPos, dir);
                dir[2] = 0.25;
                NormalizeVector(dir, dir);
                OM_AbilityDamage(attacker, victim, g_cvRougeParryCommon.FloatValue, DMG_CLUB);

                if (IsValidEntity(attacker) && GetEntProp(attacker, Prop_Send, "m_iHealth") <= 0)
                {
                    DataPack cpack = new DataPack();
                    cpack.WriteCell(EntIndexToEntRef(attacker));
                    cpack.WriteFloat(dir[0]); cpack.WriteFloat(dir[1]); cpack.WriteFloat(dir[2]);
                    CreateTimer(0.05, T_RougeCounterCommon, cpack,
                                TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
                }
            }
            else if (StrEqual(cls, "witch"))
            {
                if (IsValidEntity(attacker) && GetEngineTime() >= g_fRougeBlockFxNext[victim])
                {
                    Sonic_WitchStun(attacker, 1.2);
                    GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", aPos);
                    float wDir[3];
                    MakeVectorFromPoints(vPos, aPos, wDir);
                    wDir[2] = 0.4;
                    NormalizeVector(wDir, wDir);
                    float push[3];
                    push[0] = wDir[0] * 400.0;
                    push[1] = wDir[1] * 400.0;
                    push[2] = 220.0;
                    TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, push);

                    // v10.5: su doble también vuela — DIFERIDO (spawn)
                    DataPack wpack = new DataPack();
                    wpack.WriteCell(EntIndexToEntRef(attacker));
                    wpack.WriteFloat(wDir[0]); wpack.WriteFloat(wDir[1]); wpack.WriteFloat(wDir[2]);
                    CreateTimer(0.05, T_RougeCounterWitch, wpack,
                                TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
                }
            }
        }

        if (GetEngineTime() >= g_fRougeBlockFxNext[victim])
        {
            g_fRougeBlockFxNext[victim] = GetEngineTime() + 0.4;
            Rouge_CounterBlockFx(victim);
        }
        damage = 0.0;
        return Plugin_Handled;
    }

    // Inmunidad a dano de caida (planeo de murcielago)
    if (damagetype & DMG_FALL)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // v8.0: EVASION INSTINTIVA (pasiva que reemplaza a la Treasure
    // Visión): probabilidad de esquivar POR COMPLETO un ataque de
    // infectado + aturdimiento respectivo del atacante.
    if (Rouge_TryEvade(victim, attacker, inflictor, damage))
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // v10.1: REDUCCION PASIVA POR ESCALONES (el owner: "obtendra una
    // reducción pasiva de 20% que aumentara hasta 35% si ella está al
    // 50% de vida y 50% si esta a 25% o menos") — antes: x0.90 plano.
    if (damage > 0.0)
    {
        float mult = (g_cvRougePassiveRed != null) ? g_cvRougePassiveRed.FloatValue : 0.80;   // 20%
        float hpMax = 100.0;
        if (HasEntProp(victim, Prop_Send, "m_iMaxHealth"))
            hpMax = float(GetEntProp(victim, Prop_Send, "m_iMaxHealth"));
        if (hpMax <= 0.0) hpMax = 100.0;
        float frac = float(GetClientHealth(victim)) / hpMax;
        if (frac <= 0.25)            mult = (g_cvRougePassiveRedLow != null) ? g_cvRougePassiveRedLow.FloatValue : 0.50;   // 50%
        else if (frac <= 0.50)       mult = (g_cvRougePassiveRedMid != null) ? g_cvRougePassiveRedMid.FloatValue : 0.65;   // 35%
        damage *= mult;
        if (damage <= 0.05) damage = 0.05;
        return Plugin_Changed;
    }

    return Plugin_Continue;
}

// ============================================================
//  v10.5 - LA PATADA BAJA DEL CONTRAGOLPE (receta compartida del
//  martillo v106, dirección PATADA): dano AMPLIFICADO primero
//  (OM_AbilityDamage: hibrido x2 + % vs jefes); si MATA, el cadaver
//  sale volando (copia Rouge — el que la toca ve el cuerpo irse); si
//  SOBREVIVE: OM_Stun (rouge_parry_ragdoll s) + RAGDOLL VOLADOR con
//  la dirección de la patada: HORIZONTAL alejándola + elevación
//  corta (una patada baja barre, no levanta — a diferencia del
//  uppercut de Knuckles). Devuelve false si el ragdoll está apagado
//  (rouge_parry_ragdoll 0) para que el llamador suelte la devolución
//  clasica.
// ============================================================
// v10.7-OM: el daño del barrido con rango — aleatorio 200-335 por golpe
float Rouge_KickDmg()
{
    float dMin = (g_cvRougeKickDmgMin != null) ? g_cvRougeKickDmgMin.FloatValue : 200.0;
    float dMax = (g_cvRougeKickDmgMax != null) ? g_cvRougeKickDmgMax.FloatValue : 335.0;
    if (dMax < dMin) dMax = dMin;
    return GetRandomFloat(dMin, dMax);
}

bool Rouge_CounterKick(int rouge, int enemy, const float rPos[3], const float ePos[3])
{
    if (g_cvRougeParryRagdoll == null || g_cvRougeParryRagdoll.FloatValue <= 0.0)
        return false;

    // dirección de la patada: alejando de Rouge + elevación corta
    float dir[3];
    MakeVectorFromPoints(rPos, ePos, dir);
    dir[2] = 0.25;
    NormalizeVector(dir, dir);

    // dano primero (orden martillo v106)
    OM_AbilityDamage(enemy, rouge, g_cvRougeParrySIDmg.FloatValue, DMG_CLUB);

    if (!IsPlayerAlive(enemy))
    {
        // letal: el cadaver vuela (copia Rouge generalizada sonic v6.35)
        Sonic_DeadFlingCopy(enemy, dir, g_cvRougeParryFling.FloatValue, false);
        return true;
    }

    if (OM_Stun(enemy, g_cvRougeParryRagdoll.FloatValue, rouge, 0.0, DMG_OM_CLUB, true))
    {
        Sonic_SpawnFlingRagdollEx(enemy, dir,
                                  g_cvRougeParryFling.FloatValue, 0.35, 900.0);
        PrintCenterText(rouge, "PATADA BAJA! %.1fs de ragdoll", g_cvRougeParryRagdoll.FloatValue);
    }
    else
    {
        // iframes: al menos el empujon físico clasico
        float push[3];
        push[0] = dir[0] * g_cvRougeParryPush.FloatValue;
        push[1] = dir[1] * g_cvRougeParryPush.FloatValue;
        push[2] = 250.0;
        TeleportEntity(enemy, NULL_VECTOR, NULL_VECTOR, push);
    }
    return true;
}

// v10.5: LA PATADA BAJA diferida (0.05s — sale del callback de dano)
public Action T_RougeCounterKick(Handle timer, DataPack pack)
{
    pack.Reset();
    int rouge = GetClientOfUserId(pack.ReadCell());
    int enemy = GetClientOfUserId(pack.ReadCell());
    delete pack;

    if (Rouge_IsValidClient(rouge) && Rouge_IsValidClient(enemy)
        && IsPlayerAlive(enemy) && GetClientTeam(enemy) == TEAM_INFECTED)
    {
        float rPos[3], ePos[3];
        GetClientAbsOrigin(rouge, rPos);
        GetClientAbsOrigin(enemy, ePos);

        if (!Rouge_CounterKick(rouge, enemy, rPos, ePos))
        {
            // ragdoll apagado (rouge_parry_ragdoll 0): la devolución clasica
            OM_AbilityDamage(enemy, rouge, g_cvRougeParrySIDmg.FloatValue, DMG_CLUB);
            SIStagger_Auto(enemy, rouge, rPos);
            float push[3];
            MakeVectorFromPoints(rPos, ePos, push);
            NormalizeVector(push, push);
            ScaleVector(push, g_cvRougeParryPush.FloatValue); push[2] = 250.0;
            TeleportEntity(enemy, NULL_VECTOR, NULL_VECTOR, push);
        }
    }
    return Plugin_Stop;
}

// v10.5: el común muerto del counter vuela (diferido)
public Action T_RougeCounterCommon(Handle timer, DataPack pack)
{
    pack.Reset();
    int ent = EntRefToEntIndex(pack.ReadCell());
    float dir[3];
    dir[0] = pack.ReadFloat(); dir[1] = pack.ReadFloat(); dir[2] = pack.ReadFloat();
    delete pack;

    if (ent > 0 && IsValidEntity(ent))
        Rouge_FlingRagdoll(ent, dir);
    return Plugin_Stop;
}

// v10.5: el doble de la witch del counter vuela (diferido)
public Action T_RougeCounterWitch(Handle timer, DataPack pack)
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

// =======================
// PASIVA v8.0: EVASION INSTINTIVA (reemplaza a la Treasure Visión)
// =======================
// 30% (rouge_evade_chance) de esquivar POR COMPLETO un ataque de
// infectado. Al esquivar: dano anulado + aturdimiento respectivo del
// atacante (SI -> stagger seguro con auto-recuperación; witch ->
// lanzamiento corto con IA suspendida; común -> empujon de separación)
// + destello rosa + feedback. La Treasure Visión (glows rosas de
// items/infectados heridos) fue retirada a petición del usuario.

bool Rouge_TryEvade(int victim, int attacker, int inflictor, float damage)
{
    if (g_cvRougeEvadeChance == null) return false;
    if (damage <= 0.0) return false;

    // Identificar al atacante: solo ataques de INFECTADOS
    int src = attacker;
    if (src <= 0) src = inflictor;
    if (src <= 0 || !IsValidEntity(src)) return false;

    bool isSIPlayer = (src <= MaxClients && IsClientInGame(src));
    bool isCommon   = false;
    bool isWitch    = false;

    if (!isSIPlayer)
    {
        static char cls[16];
        GetEntityClassname(src, cls, sizeof(cls));
        isCommon = StrEqual(cls, "infected");
        isWitch  = StrEqual(cls, "witch");
        if (!isCommon && !isWitch) return false;   // prop/mundo/otro: no evade
    }
    else
    {
        if (GetClientTeam(src) != TEAM_INFECTED) return false;
    }

    // Tirada de dados
    float chance = g_cvRougeEvadeChance.FloatValue;
    if (chance <= 0.0) return false;
    if (GetRandomFloat(0.0, 100.0) > chance) return false;

    // Throttle del feedback (una horda puede pegar 10 veces en un frame)
    float now = GetEngineTime();
    bool withFeedback = (now - g_fRougeLastEvade[victim] >= 0.25);
    g_fRougeLastEvade[victim] = now;

    float vPos[3];
    GetClientAbsOrigin(victim, vPos);

    // Aturdimiento respectivo del atacante
    if (isSIPlayer)
    {
        // Stagger SEGURO: si el motor no lo recupera solo (bug de bots),
        // SIStagger_Auto programa el L4D_CancelStagger (se levanta
        // garantizado a los 1.8s / 3.0s si es Tank).
        SIStagger_Auto(src, victim, vPos);
    }
    else if (isWitch)
    {
        // Lanzamiento corto: WitchFlight suspende su IA NextBot, la
        // eleva y la suelta con dano de impacto al aterrizar.
        float wPos[3], push[3], launch[3];
        GetEntPropVector(src, Prop_Data, "m_vecAbsOrigin", wPos);
        MakeVectorFromPoints(wPos, vPos, push);   // alejándola de Rouge
        push[2] = 0.0;
        if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; }
        NormalizeVector(push, push);
        launch[0] = push[0] * 400.0;
        launch[1] = push[1] * 400.0;
        launch[2] = 350.0;
        WitchFlight_Launch(src, victim, launch);
    }
    else if (isCommon)
    {
        // Empujon de separación (los comunes no tienen sistema de
        // stagger: se les aplica velocidad directamente).
        float cPos[3], push[3];
        GetEntPropVector(src, Prop_Data, "m_vecAbsOrigin", cPos);
        MakeVectorFromPoints(vPos, cPos, push);   // alejándolo de Rouge
        push[2] = 0.0;
        if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; }
        NormalizeVector(push, push);
        ScaleVector(push, 250.0);
        push[2] = 150.0;
        TeleportEntity(src, NULL_VECTOR, NULL_VECTOR, push);
    }

    if (withFeedback)
    {
        // Destello rosa breve (se restaura solo; el flag evita que quede
        // pegado si el timer se pierde por cambio de mapa)
        SetEntityRenderColor(victim, 255, 20, 147, 255);
        g_bRougeEvadeFlash[victim] = true;

        DataPack dp = new DataPack();
        dp.WriteCell(GetClientUserId(victim));
        CreateTimer(0.18, T_RougeEvadeRestore, dp, TIMER_DATA_HNDL_CLOSE);

        // Texto + sonido + anillo
        PrintCenterText(victim, "¡ESQUIVADO!");
        EmitSoundToClient(victim, ROUGE_EVADE_SOUND);

        vPos[2] += 30.0;
        TE_SetupBeamRingPoint(vPos, 10.0, 80.0, g_iRougeBeamSprite, 0, 0, 0,
                              0.35, 4.0, 0.0, {255, 20, 147, 200}, 0, 0);
        TE_SendToAll();
    }

    return true;
}

// Restaura el color normal tras el destello de evasión (por userid:
// el slot puede cambiar de dueño durante los 0.18s y NO debemos
// restaurar el color de otro jugador).
public Action T_RougeEvadeRestore(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = GetClientOfUserId(dp.ReadCell());

    if (client > 0 && client <= MaxClients && IsClientInGame(client)
        && g_iPlayerCharIdx[client] == ROUGE_INDEX
        && g_bRougeEvadeFlash[client])
    {
        SetEntityRenderColor(client, 255, 255, 255, 255);
        g_bRougeEvadeFlash[client] = false;
    }

    return Plugin_Stop;
}

// =======================
// =====================================================================
//  v10.1-OM (suite 3.77.46, reporte del owner 2026-10-10) — 6 PEDIDOS:
//   (1) ENERGÍA DE VUELO 100 -> 250 y el consumo BAJA un 50% (aleteo 16
//       -> 8, agarre 23/s -> 11.5/s, salto de pared 15 -> 7.5; arranque
//       30 -> 75 y regen 1.2 -> 3.0 escalados al tope nuevo; histeresis
//       35 -> 88 — mismas fracciones del lua).
//   (2) REWORK DE LA PASIVA DE VUELO: el planeo pasa de SHIFT a SPACE
//       MANTENIDO ("si deja presionado el espacio ella puede planear");
//       el aleteo (tap) sigue elevándola; SHIFT en el aire es el FRENO
//       (reduce la velocidad hasta FRENAR — hover real con gravedad 0,
//       quieta en el aire = FlyIdle, moviéndose = "glide" desde la
//       v11.0 (FlyRun queda de fallback), las DOS anims
//       nuevas del avatar); el agarre de pared sale IDENTICO al de
//       Knuckles (impulso por la NORMAL de la pared + 450 vertical) y
//       enciende el planeo solo: "ella salta se eleva y vuela".
//   (3) COUNTER PLENO "= al de knuckles": duración 4 -> 6s, ACTIVACION
//       con counter.wav de Knuckles (NO el del flash — fix del reporte),
//       bloqueo exitoso con punchstun.wav + LA ANIMACION DE LA PATADA
//       BAJA, devoluciones a FULL (comunes 100 / SI 200 / empuje 800) y
//       las entradas que le faltaban: garra del tank (desarme 5s),
//       agarres (lengua/carry/pounce/jockey/slam/fling), vómito
//       REFLEJADO y knockdown/stagger. CD: 55% del base al terminar sin
//       bloquear nada, 85% si hizo un counter exitoso.
//   (4) BARRIDO EN ÁREA + recarga 6s (antes 28/15): TODOS los que caigan
//       en la esfera durante la embestida (una vez por victima) y el
//       stun del SI pasa a OM_Stun 2.5s APILABLE con el resto de stuns
//       del suite (el contador ACUMULA en vez de reemplazarse).
//   (5) EVA como la de Sonic: ahora también esquiva AGARRES (lengua,
//       pounce, jockey, carry, slam) y el VÓMITO del boomer (dados de
//       rouge_evade_chance + stun al atacante).
//   (6) VIDA MÁXIMA 125 (el lua: salud 125, receta Metal 175) y
//       reducción pasiva por ESCALONES: 20% -> 35% al 50% de vida ->
//       50% al 25% o menos. Bat Bomb (la granada) cd 20 -> 13 (-35%).
//       SLOT 4 (B) = ONDA NEGRA reintegrada (el fix del bind vive en el
//       manager: la 4 "estaba sin usar" porque la B se desbindeaba para
//       todo el que no era Amy); el Cebo+Flash pasa a consola
//       (sm_rouge_kick), como estaba la onda.
// =====================================================================
//  v10-OM — HABILIDAD 1 (Z): BARRIDO (Sweep Kick del lua GMod)
//  carga 0.35s (paso corto + punchstart 107) -> embestida a 550 con
//  I-FRAMES (OM_Damage_Reduction=0 del lua) + primer golpe por TOUCH:
//  común = dano + ragdoll VOLADO (dir*500), especial = stagger 2.5 +
//  dano, tank = dano + empuje, witch = estatua. blazekick.wav. Recarga
//  28 al golpear / 15 al fallar (sweepkick_cd_hit/cd_miss). Desde la
//  pared: el lanzazo 1500 del lua (kick con LatchOntoWall).
// =====================================================================
public Action Command_RougeSweepKick(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Rouge_IsValidClient(client)) return Plugin_Handled;
    // El Barrido es de la Rouge REAL (sus granadas se prestan al set de
    // Sage; el kit de combate no — misma regla de la evasión/planeo).
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return Plugin_Handled;

    float now = GetEngineTime();

    // desde la PARED: el lua convierte el kick en lanzazo (aim*1500)
    if (g_bRougeLatched[client])
    {
        g_bRougeLatched[client] = false;
        SetEntityMoveType(client, MOVETYPE_WALK);
        float aim[3], launch[3];
        GetClientEyeAngles(client, aim);
        GetAngleVectors(aim, launch, NULL_VECTOR, NULL_VECTOR);
        launch[0] *= 1500.0; launch[1] *= 1500.0; launch[2] = 60.0;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, launch);
        Rouge_AvatarOneShot(client, ROUGE_ST_JUMP, ROUGE_LOCK_LATCHOFF);
        if (g_bRougeSndSwing) EmitSoundToAll("om/knuckles/swing.wav", client, _, ROUGE_SND_LEVEL);
        PrintCenterText(client, "¡Lanzazo desde la pared!");
        return Plugin_Handled;
    }

    if (g_iRougeKickPhase[client] != ROUGE_KICK_NONE) return Plugin_Handled;
    if (g_bRougeCountering[client]) return Plugin_Handled;
    if (g_bRougeGliding[client]) return Plugin_Handled;

    if (now < g_fRougeKickCDUntil[client])
    {
        PrintCenterText(client, "BARRIDO: recarga %.1fs", g_fRougeKickCDUntil[client] - now);
        return Plugin_Handled;
    }

    // carga (sweepkick_chargeup 0.35 + punchstart.wav pitch 107 del lua)
    g_iRougeKickPhase[client] = ROUGE_KICK_CHARGING;
    g_fRougeKickChargeEnd[client] = now + g_cvRougeKickCharge.FloatValue;
    if (g_bRougeSndPunchStart) EmitSoundToAll("om/knuckles/punchstart.wav", client, _, ROUGE_SND_LEVEL, 107);
    else EmitSoundToAll("weapons/knife/knife_deploy.wav", client, _, ROUGE_SND_LEVEL);
    Rouge_AvatarTintPulse(client, 255, 60, 120);
    PrintCenterText(client, "Cargando el barrido...");
    return Plugin_Handled;
}

// golpe del barrido: el TOUCH es el disparador INSTANTANEO del contacto
// (v10.1 ya NO es el único: el buff de ÁREA barre la esfera cada frame
// por Rouge_KickAreaSweep — ambos comparten la compuerta por victima)
public Action Rouge_OnTouch(int client, int other)
{
    if (g_iRougeKickPhase[client] != ROUGE_KICK_DASH) return Plugin_Continue;
    if (other <= 0 || !IsValidEntity(other)) return Plugin_Continue;

    // la esfera del lua (FindInSphere 95): el toque cuenta solo si el
    // cuerpo alcanza esa distancia de Rouge
    float cPos[3], oPos[3];
    GetClientAbsOrigin(client, cPos);
    GetEntPropVector(other, Prop_Send, "m_vecOrigin", oPos);
    if (GetVectorDistance(cPos, oPos) > g_cvRougeKickRadius.FloatValue) return Plugin_Continue;

    if (Rouge_KickStrike(client, other)) return Plugin_Handled;
    return Plugin_Continue;
}

// ---------------- v10.1: EL BARRIDO EN ÁREA (el buff) ----------------
// Lista de victims por embestida (una vez cada una):
bool Rouge_KickHitHas(int client, int ent)
{
    int ref = EntIndexToEntRef(ent);
    for (int i = 0; i < g_iRougeKickHitCount[client]; i++)
        if (g_iRougeKickHitList[client][i] == ref) return true;
    return false;
}

void Rouge_KickHitAdd(int client, int ent)
{
    if (g_iRougeKickHitCount[client] >= ROUGE_KICK_HITS) return;
    g_iRougeKickHitList[client][g_iRougeKickHitCount[client]++] = EntIndexToEntRef(ent);
}

void Rouge_KickHitClear(int client)
{
    g_iRougeKickHitCount[client] = 0;
}

// EL GOLPE (común al TOUCH y al barrido de área): compuerta por
// victima + efecto según clase. EL STUN DEL SI PASA A OM_Stun 2.5s
// APILABLE ("la patada baja provocara el stun por 2.5 seg puede
// stackearse con otros stun — el método de stun ahora podrá acumularse
// el contador en vez de remplazarse por el entrante": OM_Stun SUMA
// sobre el restante, como el resto de los stun del suite).
bool Rouge_KickStrike(int client, int other)
{
    if (other <= 0 || !IsValidEntity(other)) return false;
    if (Rouge_KickHitHas(client, other)) return false;

    bool isCommon = false, isWitch = false, isSI = false;
    if (other > MaxClients)
    {
        char cls[16];
        GetEntityClassname(other, cls, sizeof(cls));
        isCommon = StrEqual(cls, "infected");
        isWitch  = StrEqual(cls, "witch");
        if (!isCommon && !isWitch) return false;
    }
    else
    {
        if (other == client || !IsClientInGame(other) || !IsPlayerAlive(other)) return false;
        if (GetClientTeam(other) != TEAM_INFECTED) return false;
        isSI = true;
    }

    Rouge_KickHitAdd(client, other);

    if (isCommon)
    {
        // común: dano + ragdoll volado en la dirección del barrido
        // v10.5: OM_AbilityDamage = amplificador hibrido (x2 + % vs jefes)
        OM_AbilityDamage(other, client, Rouge_KickDmg(), DMG_CLUB);   // v10.7: 200-335
        if (IsValidEntity(other) && GetEntProp(other, Prop_Send, "m_iHealth") <= 0)
            Rouge_FlingRagdoll(other, g_vRougeKickDir[client]);
    }
    else if (isWitch)
    {
        // witch: estatua 2.5 (el stun de la patada, antes 1.5)
        OM_AbilityDamage(other, client, Rouge_KickDmg(), DMG_CLUB);   // v10.7: 200-335
        Sonic_WitchStun(other, 2.5);
    }
    else if (isSI)
    {
        OM_AbilityDamage(other, client, Rouge_KickDmg(), DMG_CLUB);   // v10.7: 200-335
        int zClass = GetEntProp(other, Prop_Send, "m_zombieClass");
        if (zClass != 8)
        {
            // STUN APILABLE: OM_Stun suma 2.5s sobre el restante (estrellas
            // + congelado; apila con la bola de Sonic, los slams de Metal,
            // el martillo de Amy, el rayo de Tails...)
            OM_Stun(other, g_cvRougeKickStun.FloatValue, client, 0.0, DMG_OM_CLUB, true);
        }
        else
        {
            // tank: resiste el stun — dano + empujon (como siempre)
            float vPos[3], aPos[3], push[3];
            GetClientAbsOrigin(client, vPos);
            GetEntPropVector(other, Prop_Data, "m_vecAbsOrigin", aPos);
            MakeVectorFromPoints(vPos, aPos, push);
            NormalizeVector(push, push);
            ScaleVector(push, 450.0); push[2] = 260.0;
            TeleportEntity(other, NULL_VECTOR, NULL_VECTOR, push);
        }
    }

    // el jugo (blazekick + energía del reward del lua) UNA VEZ por
    // embestida: al PRIMER golpeado
    if (!g_bRougeKickHit[client])
    {
        g_bRougeKickHit[client] = true;
        Rouge_KickFeedback(client);
    }
    return true;
}

// la esfera del barrido barre TODO lo cercano cada frame de la
// embestida: especiales + comunes + witch (comunes con tope de lista)
void Rouge_KickAreaSweep(int client)
{
    if (g_iRougeKickPhase[client] != ROUGE_KICK_DASH) return;

    float cPos[3];
    GetClientAbsOrigin(client, cPos);
    float rad = g_cvRougeKickRadius.FloatValue;

    // especiales / tank (players infectados)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client || !IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;
        if (Rouge_KickHitHas(client, i)) continue;
        float oPos[3];
        GetClientAbsOrigin(i, oPos);
        if (GetVectorDistance(cPos, oPos) > rad) continue;
        Rouge_KickStrike(client, i);
    }

    // comunes
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (Rouge_KickHitHas(client, ent)) continue;
        float oPos[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", oPos);
        if (GetVectorDistance(cPos, oPos) > rad) continue;
        if (!Rouge_KickStrike(client, ent)) continue;
        if (g_iRougeKickHitCount[client] >= ROUGE_KICK_HITS) break;
    }

    // witch
    int w = -1;
    while ((w = FindEntityByClassname(w, "witch")) != -1)
    {
        if (!IsValidEntity(w)) continue;
        if (Rouge_KickHitHas(client, w)) continue;
        float oPos[3];
        GetEntPropVector(w, Prop_Send, "m_vecOrigin", oPos);
        if (GetVectorDistance(cPos, oPos) > rad) continue;
        Rouge_KickStrike(client, w);
    }
}

// el jugo del golpe del barrido: blazekick.wav + energía (reward 30)
void Rouge_KickFeedback(int client)
{
    if (g_bRougeSndBlazeKick) EmitSoundToAll("om/blaze/blazekick.wav", client, _, ROUGE_SND_LEVEL);
    else EmitSoundToAll(ROUGE_SND_KICK_HIT, client, _, ROUGE_SND_LEVEL);
    g_fRougeEnergy[client] += g_cvRougeKickReward.FloatValue;
    float emax = g_cvRougeEnergyMax.FloatValue;
    if (g_fRougeEnergy[client] > emax) g_fRougeEnergy[client] = emax;
    Rouge_AvatarTintPulse(client, 255, 200, 255);
    PrintCenterText(client, "¡BARRIDO! (+%.0f energía)", g_cvRougeKickReward.FloatValue);
}

// ragdoll volado del común golpeado (receta CreateRagdolLCharacter_OM
// del lua: el cuerpo sale con dir*500 y gira — patron ragdoll del suite)
// v10.4: el impulso v6.33 de sonic.inc (SetVelocity POR HUESO directo al
// vphysics — la versión completa del lua: lineal + GIRO POR HUESO, cosa
// que el TeleportEntity de abajo no puede darle a los huesos y el
// m_angVelocity de la entidad era puro humo). Si la mesa del SDKCall no
// se puede armar -> Sonic_RagFlingEngine (el plan B motor puro:
// TeleportEntity-vel al hueso raíz, la ruta que ESTE cuerpo ya usaba de
// facto — ahora compartida y con el levanton v6.33 incluido).
void Rouge_FlingRagdoll(int victim, const float dir[3])
{
    if (!IsValidEntity(victim)) return;

    char model[96];
    GetEntPropString(victim, Prop_Data, "m_ModelName", model, sizeof(model));
    if (model[0] == '\0') return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    float pos[3], ang[3];
    GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
    GetEntPropVector(victim, Prop_Send, "m_angRotation", ang);

    DispatchKeyValue(rag, "model", model);
    DispatchSpawn(rag);
    TeleportEntity(rag, pos, ang, NULL_VECTOR);

    // v10.4: dir*500 + 300z + giro random POR HUESO — los mismos números
    // del lua, pero llegando de verdad esta vez
    if (!Sonic_RagPhysLaunch(rag, dir, 500.0, 300.0, 900.0))
        Sonic_RagFlingEngine(rag, dir, 500.0, 300.0);

    AcceptEntityInput(victim, "BecomeRagdoll");
    CreateTimer(3.0, T_RougeRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_RougeRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// =====================================================================
//  v10-OM — HABILIDAD 2 (X): CONTRAGOLPE (counter estilo Knuckles pero
//  MÁS DEBIL + SU PROPIA ENTRADA EN EL VSCRIPT)
//  4s de ventana (vs 8s del Knuckles), devoluciones a media fuerza (el
//  bloqueo SI es total) y — la parte que manda — la ventana del
//  chch_parrying.nut v2.9 SE ABRE SOLA: Rouge_ParryNotifyNut ->
//  RunScriptCode -> ChCh_RougeNotify(idx, 1, dur) (patron supertank
//  SetAmyMode: la entrada ES la identidad; sin consola, sin gates).
//  Ahi vive la DEVOLUCION DE PROYECTILES completa (roca/saliva/
//  granadas + enemigos en cono).
// =====================================================================
public Action Command_RougeCounter(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Rouge_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return Plugin_Handled;
    if (g_iRougeKickPhase[client] != ROUGE_KICK_NONE) return Plugin_Handled;

    // toggle (como la postura de Knuckles: X otra vez la apaga)
    if (g_bRougeCountering[client])
    {
        Rouge_StopCounter(client);
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fRougeCounterCDUntil[client])
    {
        PrintCenterText(client, "CONTRAGOLPE: recarga %.1fs", g_fRougeCounterCDUntil[client] - now);
        return Plugin_Handled;
    }

    g_bRougeCountering[client] = true;
    g_bRougeCounterHit[client] = false;   // v10.1: el éxito se cobra al cerrar (85% vs 55%)
    g_fRougeCounterEnd[client] = now + g_cvRougeParryDuration.FloatValue;

    // paso defensivo + tinte magenta del avatar
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.5);
    Rouge_AvatarTintPulse(client, 255, 120, 220);
    // v10.1: LA ACTIVACION SUENA COMO LA DE KNUCKLES ("su activación
    // debe llevar el mismo sonido de knuckles no el sonido del flash —
    // pusiste el sonido en el counter")
    if (g_bRougeSndKnxCounter) EmitSoundToAll("om/knuckles/counter.wav", client, _, ROUGE_SND_LEVEL);
    else if (g_bRougeSndFlash) EmitSoundToAll("om/rouge/flashbomb.wav", client, _, ROUGE_SND_LEVEL, _, 0.5);
    else EmitSoundToAll("weapons/knife/knife_deploy.wav", client, _, ROUGE_SND_LEVEL);

    PrintCenterText(client, "🛡️ ¡CONTRAGOLPE! (%.0fs — devuelve proyectiles)", g_cvRougeParryDuration.FloatValue);

    // LA VENTANA DEL VSCRIPT SE ABRE AQUÍ (patron supertank)
    Rouge_ParryNotifyNut(client, true, g_cvRougeParryDuration.FloatValue);
    return Plugin_Handled;
}

void Rouge_StopCounter(int client)
{
    g_bRougeCountering[client] = false;
    // la postura se apaga -> SU ventana del parry también (directo)
    Rouge_ParryNotifyNut(client, false, 0.0);
    if (IsClientInGame(client))
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    // v10.1: LA RECARGA SEGÚN EL RESULTADO (el owner: "el counter su cd
    // reducira a 55% y aumentara a 85 si hace un counter exitoso"):
    // ventana sin bloquear nada = 55% del base (13.75s); con un counter
    // exitoso = 85% (21.25s — el éxito ya dio su show y cobra más).
    // Palancas: rouge_parry_cd_whiff_pct / rouge_parry_cd_success_pct.
    float cdBase = g_cvRougeParryCD.FloatValue;
    float cdPct = g_bRougeCounterHit[client]
        ? ((g_cvRougeParryCDSucc != null) ? g_cvRougeParryCDSucc.FloatValue : 85.0)
        : ((g_cvRougeParryCDWhiff != null) ? g_cvRougeParryCDWhiff.FloatValue : 55.0);
    g_fRougeCounterCDUntil[client] = GetEngineTime() + (cdBase * cdPct / 100.0);

    PrintCenterText(client, g_bRougeCounterHit[client]
        ? "Contragolpe terminado (EXITOSO — recarga %.0fs)"
        : "Contragolpe terminado (recarga %.0fs)", cdBase * cdPct / 100.0);
}

// =====================================================================
//  v10-OM — EL PUENTE DIRECTO AL VSCRIPT (patron supertank, clon
//  exacto del Knux_ParryNotifyNut v75 / Amy_ParryNotifyNut v104):
//  RunScriptCode -> ChCh_RougeNotify del chch_parrying.nut v2.9 en un
//  logic_script PROPIO. El guard "in getroottable()" lo hace no-op
//  silencioso si el .nut no está cargado.
// =====================================================================
#define ROUGE_SCRIPT_RUNNER_NAME "rouge_parry_runner"

void Rouge_ParryNotifyNut(int client, bool on, float dur)
{
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return;

    int runner = Rouge_FindScriptRunner();
    if (runner == -1 || !IsValidEntity(runner)) return;

    char code[192];
    Format(code, sizeof(code),
        "local r = getroottable(); if(\"ChCh_RougeNotify\" in r) r.ChCh_RougeNotify(%d, %d, %.2f)",
        client, on ? 1 : 0, dur);

    SetVariantString(code);
    AcceptEntityInput(runner, "RunScriptCode");
}

// Helper: encontrar o crear NUESTRO logic_script (lección v51 de Amy:
// JAMÁS reusar el logic_script de un mapa — pisaria su estado).
int Rouge_FindScriptRunner()
{
    int entity = -1;
    char nameBuf[32];
    while ((entity = FindEntityByClassname(entity, "logic_script")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        GetEntPropString(entity, Prop_Data, "m_iName", nameBuf, sizeof(nameBuf));
        if (StrEqual(nameBuf, ROUGE_SCRIPT_RUNNER_NAME, false)) return entity;
    }
    entity = CreateEntityByName("logic_script");
    if (entity != -1) {
        DispatchKeyValue(entity, "targetname", ROUGE_SCRIPT_RUNNER_NAME);
        DispatchSpawn(entity);
    }
    return entity;
}

// FX del bloqueo del contragolpe: pulso BLANCO + SU sonido (el
// rouge_parry_blocked que manda el .nut v2.9 cuando SU ventana bloquea)
void Rouge_CounterBlockFx(int client)
{
    Rouge_AvatarTintPulse(client, 255, 255, 255);
    // v10.1: EL BLOQUEO EXITOSO SUENA COMO EL DE KNUCKLES y hace LA
    // ANIMACION DE LA PATADA BAJA ("sonara el mismo sonido dknucles al
    // el counterear exitosamente algo y hará la animación de la
    // patada baja")
    if (g_bRougeSndKnxPunchStun)
        EmitSoundToAll("om/knuckles/punchstun.wav", client, _, ROUGE_SND_LEVEL);
    else
        EmitSoundToAll(ROUGE_SND_KICK_HIT, client, _, ROUGE_SND_LEVEL);
    Rouge_AvatarOneShot(client, ROUGE_ST_KICK, ROUGE_LOCK_KICK);
}

// el VSCRIPT bloqueo algo en la ventana de Rouge (puente inverso,
// patron knx_parry_blocked / amyparry_strike — el .nut ya puso SU hint
// y SU sonido; aquí solo el tinte del avatar)
public Action Rouge_CmdParryBlocked(int args)
{
    if (args < 1) return Plugin_Handled;
    char s[16];
    GetCmdArg(1, s, sizeof(s));
    int client = StringToInt(s);
    if (client <= 0 || client > MaxClients || !IsClientInGame(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return Plugin_Handled;
    if (!IsPlayerAlive(client) || GetClientTeam(client) != TEAM_SURVIVOR) return Plugin_Handled;
    g_bRougeCounterHit[client] = true;   // v10.1: el VScript bloqueo -> ÉXITO (cd 85%)
    if (GetEngineTime() < g_fRougeBlockFxNext[client]) return Plugin_Handled;
    g_fRougeBlockFxNext[client] = GetEngineTime() + 0.4;

    Rouge_CounterBlockFx(client);
    return Plugin_Handled;
}

// =====================================================================
//  v10.1 — EVA DE CONTROL (LA DE SONIC) + COUNTER PLENO (= KNUCKLES)
//  + VIDA MÁXIMA 125. Los forwards compartidos (tongue/carry/pounce/
//  jockey/slam/fling/vómito en Knuckles.inc/sonic.inc y TankClaw/
//  KnockedDown/Stagger en el manager) llaman a ESTAS entradas.
// =====================================================================

// ---- EVA DE CONTROL: agarres + vómito del boomer ----
// "La eva de rouge Ahora será como el de sonic Podrá evitar agarres
// vomitos de boomer": mismos forwards que los guards de sonic.inc pero
// con SUS dados (rouge_evade_chance) y SU jugo (destello rosa + stun
// al atacante). Si el Contragolpe está activo, el counter manda.
bool Rouge_EvadeControl(int victim, int attacker, const char[] label)
{
    if (!Rouge_IsValidClient(victim)) return false;
    if (g_iPlayerCharIdx[victim] != ROUGE_INDEX) return false;
    if (g_bRougeCountering[victim]) return false;   // el counter manda (SU receta)
    if (g_cvRougeEvadeChance == null) return false;

    float chance = g_cvRougeEvadeChance.FloatValue;
    if (chance <= 0.0) return false;
    if (GetRandomFloat(0.0, 100.0) > chance) return false;

    // stun del atacante (si es un especial) + destello rosa + hint
    if (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker)
        && GetClientTeam(attacker) == TEAM_INFECTED && IsPlayerAlive(attacker))
    {
        float vPos[3];
        GetClientAbsOrigin(victim, vPos);
        SIStagger_Auto(attacker, victim, vPos);
    }
    SetEntityRenderColor(victim, 255, 20, 147, 255);
    g_bRougeEvadeFlash[victim] = true;
    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(victim));
    CreateTimer(0.18, T_RougeEvadeRestore, dp, TIMER_DATA_HNDL_CLOSE);

    PrintHintText(victim, "¡ESQUIVADO: %s!", label);
    EmitSoundToClient(victim, ROUGE_EVADE_SOUND);
    return true;
}

// v10.1: ACCESSORS para los forwards compartidos — Knuckles.inc y
// sonic.inc se incluyen ANTES que Rouge.inc y SourcePawn no resuelve
// VARIABLES hacia atras (las funciones si). El manager si puede usar
// los arrays directos (su código va después de TODOS los includes).
bool Rouge_Countering(int client)
{
    return (1 <= client <= MaxClients) && g_bRougeCountering[client];
}

void Rouge_MarkCounterHit(int client)
{
    if (1 <= client <= MaxClients) g_bRougeCounterHit[client] = true;
}

// ---- COUNTER DE LA GARRA DEL TANK (= Knuckles_CheckTankCounter) ----
// Bloqueo + DESARME del tank 5s (el canal de supresión del IN_ATTACK
// vive en Knux_PreThink — un solo plugin) + stagger + empujon. La
// inmunidad al dano ya la da el OnTakeDamage durante toda la ventana.
bool Rouge_CheckTankCounter(int tank, int player)
{
    if (!Rouge_IsValidClient(player)) return false;
    if (g_iPlayerCharIdx[player] != ROUGE_INDEX) return false;
    if (!g_bRougeCountering[player]) return false;

    g_bRougeCounterHit[player] = true;
    Rouge_CounterBlockFx(player);

    if (tank > 0 && tank <= MaxClients && IsClientInGame(tank))
        g_fKnuxDisarmTank[tank] = GetEngineTime() + 5.0;   // desarme (canal Knux, mismo plugin)

    if (tank > 0 && tank <= MaxClients && IsClientInGame(tank) && IsPlayerAlive(tank))
    {
        float vPlayer[3], push[3];
        GetClientAbsOrigin(player, vPlayer);
        GetClientEyeAngles(player, push);
        GetAngleVectors(push, push, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(push, 1000.0); push[2] = 400.0;
        SIStagger_Auto(tank, player, vPlayer);
        TeleportEntity(tank, NULL_VECTOR, NULL_VECTOR, push);
    }

    PrintCenterText(player, "🛡️ TANK BLOQUEADO!");
    return true;
}

// ---- COUNTER DE AGARRES: charger/hunter/jockey (= CheckSpecialCounter)
bool Rouge_SpecialCounter(int victim, int attacker)
{
    if (!Rouge_IsValidClient(victim)) return false;
    if (g_iPlayerCharIdx[victim] != ROUGE_INDEX) return false;
    if (!g_bRougeCountering[victim]) return false;

    g_bRougeCounterHit[victim] = true;
    if (Rouge_IsValidClient(attacker))
    {
        Rouge_CounterBlockFx(victim);

        // fricción absoluta instantanea (que el charger no pase de largo)
        float zeroVel[3] = {0.0, 0.0, 0.0};
        float vAtt[3];
        GetClientAbsOrigin(attacker, vAtt);
        TeleportEntity(attacker, vAtt, NULL_VECTOR, zeroVel);

        DataPack pack = new DataPack();
        pack.WriteCell(GetClientUserId(victim));
        pack.WriteCell(GetClientUserId(attacker));
        CreateTimer(0.05, T_RougeHardStop, pack, TIMER_FLAG_NO_MAPCHANGE);
    }
    PrintCenterText(victim, "⛔ ¡ATAQUE DESTRUIDO EN SECO!");
    return true;
}

public Action T_RougeHardStop(Handle timer, DataPack pack)
{
    pack.Reset();
    int victim = GetClientOfUserId(pack.ReadCell());
    int attacker = GetClientOfUserId(pack.ReadCell());
    delete pack;

    if (Rouge_IsValidClient(victim) && Rouge_IsValidClient(attacker))
    {
        float vPos[3], vAttacker[3];
        GetClientAbsOrigin(victim, vPos);
        GetClientAbsOrigin(attacker, vAttacker);

        // v10.5: LA PATADA BAJA también aquí (agarre contrado = patada
        // voladora; receta compartida del counter principal)
        if (!Rouge_CounterKick(victim, attacker, vPos, vAttacker))
        {
            float push[3];
            MakeVectorFromPoints(vPos, vAttacker, push);
            NormalizeVector(push, push);
            ScaleVector(push, g_cvRougeParryPush.FloatValue);   // 800 (= Knuckles)
            push[2] = 400.0;

            // stagger seguro + lanzamiento + dano (= Knuckles: 200)
            SIStagger_Auto(attacker, victim, vPos);
            TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, push);
            OM_AbilityDamage(attacker, victim, g_cvRougeParrySIDmg.FloatValue, DMG_CLUB);
        }

        // desvinculación absoluta + cd del atacante
        SetEntPropEnt(victim, Prop_Send, "m_pounceAttacker", -1);
        SetEntPropEnt(victim, Prop_Send, "m_jockeyAttacker", -1);
        SetEntPropEnt(victim, Prop_Send, "m_carryAttacker", -1);
        SetEntPropEnt(victim, Prop_Send, "m_pummelAttacker", -1);
        Knux_DisableInfectedAbility(attacker, 5.0);
    }
    return Plugin_Stop;
}

// ---- COUNTER DEL SMOKER (lengua) (= Knuckles_HandleSmokerCounter) ----
bool Rouge_SmokerCounter(int victim, int smoker)
{
    if (!Rouge_IsValidClient(victim)) return false;
    if (g_iPlayerCharIdx[victim] != ROUGE_INDEX) return false;
    if (!g_bRougeCountering[victim]) return false;

    g_bRougeCounterHit[victim] = true;
    Rouge_CounterBlockFx(victim);

    if (Rouge_IsValidClient(smoker))
    {
        DataPack pack = new DataPack();
        pack.WriteCell(GetClientUserId(victim));
        pack.WriteCell(GetClientUserId(smoker));
        CreateTimer(0.05, T_RougeHardStopSmoker, pack, TIMER_FLAG_NO_MAPCHANGE);
    }
    PrintCenterText(victim, "🛡️ ¡INMUNE AL SMOKER!");
    return true;
}

public Action T_RougeHardStopSmoker(Handle timer, DataPack pack)
{
    pack.Reset();
    int victim = GetClientOfUserId(pack.ReadCell());
    int smoker = GetClientOfUserId(pack.ReadCell());
    delete pack;

    if (Rouge_IsValidClient(victim) && Rouge_IsValidClient(smoker))
    {
        float vPos[3];
        GetClientAbsOrigin(victim, vPos);
        SIStagger_Auto(smoker, victim, vPos);
        Knux_DisableInfectedAbility(smoker, 5.0);
    }
    return Plugin_Stop;
}

// ---- COUNTER DEL VÓMITO (= Knuckles): la bilis se REFLEJA entera ----
bool Rouge_VomitCounter(int victim, int attacker)
{
    if (!Rouge_IsValidClient(victim)) return false;
    if (!g_bRougeCountering[victim]) return false;

    // SOLO bilis de BOOMER VIVO del equipo infectado (receta Knux v70:
    // matar al boomer aquí dentro, en medio de su propio spray,
    // re-entraba en OnVomitedUpon). Otra bilis: se bloquea sin reflejo.
    if (!(attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker)
        && GetClientTeam(attacker) == TEAM_INFECTED
        && GetEntProp(attacker, Prop_Send, "m_zombieClass") == 2))
        return true;

    g_bRougeCounterHit[victim] = true;
    Rouge_CounterBlockFx(victim);
    PrintCenterText(victim, "🤢 [COUNTER] ¡VÓMITO REFLEJADO!");

    DataPack dp = new DataPack();
    dp.WriteCell(GetClientUserId(attacker));
    dp.WriteCell(GetClientUserId(victim));
    CreateTimer(0.1, T_RougeVomitReflect, dp, TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);
    return true;
}

public Action T_RougeVomitReflect(Handle timer, DataPack pack)
{
    pack.Reset();
    int boomer = GetClientOfUserId(pack.ReadCell());
    int rouge  = GetClientOfUserId(pack.ReadCell());

    if (rouge > 0 && IsClientInGame(rouge)
        && boomer > 0 && IsClientInGame(boomer) && IsPlayerAlive(boomer)
        && GetClientTeam(boomer) == TEAM_INFECTED
        && GetEntProp(boomer, Prop_Send, "m_zombieClass") == 2)
    {
        // el boomer recibe SU PROPIA bilis (15s, igual que Knuckles)
        if (HasEntProp(boomer, Prop_Send, "m_itTimer"))
            SetEntPropFloat(boomer, Prop_Send, "m_itTimer", GetGameTime() + 15.0);

        float vB[3], vR[3], push[3];
        GetClientAbsOrigin(boomer, vB);
        GetClientAbsOrigin(rouge, vR);
        MakeVectorFromPoints(vR, vB, push);
        push[2] = 0.0;
        if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; }
        NormalizeVector(push, push);
        ScaleVector(push, 500.0); push[2] = 300.0;
        TeleportEntity(boomer, NULL_VECTOR, NULL_VECTOR, push);
        SIStagger_Auto(boomer, rouge, vR);
    }
    return Plugin_Stop;
}

// ---- VIDA MÁXIMA 125 (el lua: salud 125; receta Metal 175) ----
void Rouge_ApplyMaxHealth(int client)
{
    if (!Rouge_IsValidClient(client)) return;
    if (GetClientTeam(client) != TEAM_SURVIVOR) return;

    int maxHp = (g_cvRougeMaxHp != null) ? g_cvRougeMaxHp.IntValue : 125;

    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", maxHp);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", maxHp);

    g_bRougeMaxHpApplied[client] = true;

    // nacer con vida llena (100) -> arranca a 125; herida se conserva
    if (!GetEntProp(client, Prop_Send, "m_isIncapacitated"))
    {
        int hp = GetClientHealth(client);
        if (hp >= 100 && hp < maxHp)
            SetEntityHealth(client, maxHp);
    }
}

// el camino de VUELTA: al dejar de ser Rouge nadie hereda las 125
void Rouge_RestoreMaxHealth(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    if (!g_bRougeMaxHpApplied[client]) return;
    g_bRougeMaxHpApplied[client] = false;

    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", 100);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", 100);
    if (IsPlayerAlive(client) && GetClientHealth(client) > 100)
        SetEntityHealth(client, 100);
}

// =====================================================================
//  v10-OM — POOL DE LENTITUD (la rougeslowdown del lua): el destello
//  del Cebo+Flash deja a los especiales/tank al 70% durante 6s. El
//  motor pelea el lagged: se re-afirma a 5 Hz hasta expirar.
// =====================================================================
void Rouge_SlowAdd(int ent, float mul, float dur)
{
    if (ent <= 0 || !IsValidEntity(ent)) return;
    int ref = EntIndexToEntRef(ent);
    float now = GetEngineTime();

    for (int i = 0; i < ROUGE_SLOW_SLOTS; i++)
    {
        if (g_iRougeSlowRef[i] == ref)
        {
            g_fRougeSlowEnd[i] = now + dur;
            g_fRougeSlowMul[i] = mul;
            return;
        }
    }
    for (int i = 0; i < ROUGE_SLOW_SLOTS; i++)
    {
        if (g_iRougeSlowRef[i] == 0 || !IsValidEntity(EntRefToEntIndex(g_iRougeSlowRef[i])))
        {
            g_iRougeSlowRef[i] = ref;
            g_fRougeSlowEnd[i] = now + dur;
            g_fRougeSlowMul[i] = mul;
            return;
        }
    }
}

public Action T_RougeSlowTick(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 0; i < ROUGE_SLOW_SLOTS; i++)
    {
        if (g_iRougeSlowRef[i] == 0) continue;
        int ent = EntRefToEntIndex(g_iRougeSlowRef[i]);
        if (ent <= 0 || !IsValidEntity(ent) || now >= g_fRougeSlowEnd[i])
        {
            if (ent > 0 && IsValidEntity(ent) && ent <= MaxClients && IsClientInGame(ent)
                && HasEntProp(ent, Prop_Send, "m_flLaggedMovementValue"))
                SetEntPropFloat(ent, Prop_Send, "m_flLaggedMovementValue", 1.0);
            g_iRougeSlowRef[i] = 0;
            continue;
        }
        if (ent <= MaxClients && IsClientInGame(ent)
            && HasEntProp(ent, Prop_Send, "m_flLaggedMovementValue"))
            SetEntPropFloat(ent, Prop_Send, "m_flLaggedMovementValue", g_fRougeSlowMul[i]);
    }
    return Plugin_Continue;
}

void Rouge_SlowClear()
{
    for (int i = 0; i < ROUGE_SLOW_SLOTS; i++) g_iRougeSlowRef[i] = 0;
}

// =====================================================================
// v10.6-OM: LA BARRA DE ENERGÍA — el estado para el motor común SBar
// del manager 3.77.85 (pedido del owner: "ese mismo tipo de barra
// debería salir para sonic y todos aquellos que lo usan"). La
// rouge_latchbar del lua (barra purpura 0-250): drena aleteando
// (rouge_flap_cost 8), pegada a la pared (rouge_latch_drain) y
// saltando desde la pared (7.5); se regenera sola (3/s, incluso en
// el aire — solo la pared NO recarga); la HISTERESIS del lua
// (AGOTADA <=1 hasta llegar a rouge_energy_serious 88) bloquea
// pegarse a paredes. El hint de 10 bloques Rouge_EnergyHUD se
// RETIRA (patron anillos de Sonic v6.36): la barra pinta EN VIVO a
// 5 Hz con el tag de estado.
// =====================================================================

// Rouge seleccionada como personaje del manager (el ÍNDICE, no el
// modelo CST: la energía es de la selección, no de la skin)
bool Rouge_PlayerIs(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return false;
    return g_iPlayerCharIdx[client] == ROUGE_INDEX;
}

// llena el estado compartido de SBar; siempre hay barra (la energía
// es la pasiva central del kit — aleteo, pared, planeo y freno)
bool Rouge_BarState(int client)
{
    float mx = (g_cvRougeEnergyMax != null) ? g_cvRougeEnergyMax.FloatValue : 250.0;
    if (mx < 1.0) mx = 250.0;
    float en = g_fRougeEnergy[client];
    if (en < 0.0) en = 0.0;
    if (en > mx) en = mx;
    float seriousAt = (g_cvRougeEnergySerious != null) ? g_cvRougeEnergySerious.FloatValue : 88.0;

    SBar_Clear();
    g_fSBarFrac = en / mx;
    g_iSBarNum  = RoundToFloor(en);
    g_iSBarDen  = RoundToFloor(mx);
    strcopy(g_sSBarLabel, sizeof(g_sSBarLabel), "ENERGÍA");

    bool empty = g_bRougeRegenSerious[client];   // AGOTADA: histeresis del lua (<=1 -> espera seriousAt)
    if (empty)                          g_bSBarBlink = true;                          // AGOTADA: rojo-gris
    else if (g_bRougeLatched[client]) { g_iSBarChatColor = SBAR_CHAT_OLIVE;   }   // en la pared: DRENA — chat: oliva
    else if (en < seriousAt)          { g_iSBarChatColor = SBAR_CHAT_OLIVE;   }   // baja: cuidado — chat: oliva
    else                              { g_iSBarChatColor = SBAR_CHAT_LIGHTGR; }   // volando / lista — chat: verde claro

    if (empty)                          Format(g_sSBarTag, sizeof(g_sSBarTag), "AGOTADA! recup %d", RoundToNearest(seriousAt));
    else if (g_bRougeLatched[client])   strcopy(g_sSBarTag, sizeof(g_sSBarTag), "PARED!");
    else if (g_bRougeBraking[client])   strcopy(g_sSBarTag, sizeof(g_sSBarTag), "FRENO!");
    else if (g_bRougeGliding[client])   strcopy(g_sSBarTag, sizeof(g_sSBarTag), "PLANEO!");
    else                                g_sSBarTag[0] = '\0';
    return true;
}

// filtro de trace: SOLO mundo/props (el lua excluia players/NPC/ragdolls)
public bool Rouge_TraceFilter_World(int entity, int contentsMask, any data)
{
    if (entity > 0 && entity <= MaxClients) return false;
    if (entity > MaxClients)
    {
        static char cls[16];
        GetEntityClassname(entity, cls, sizeof(cls));
        if (StrEqual(cls, "infected", false) || StrEqual(cls, "witch", false)) return false;
    }
    return true;
}

// =======================
// HABILIDAD 1: CEBO QUIMICO (con FIX del charco de acido real)
// ==========================================================

public Action Command_RougeKick(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Rouge_IsValidClient(client)) return Plugin_Handled;
    // R28 (set ROUGE de Sage): Sage con set ROUGE activo también
    // lanza el kit de granadas. La evasión/planeo siguen siendo
    // pasivas EXCLUSIVAS de la Rouge real ("sus granadas", nada más).
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX
        && !(g_iPlayerCharIdx[client] == SAGE_INDEX && g_iSageActiveSet[client] == SAGESET_ROUGE)) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fRougeBaitCooldown[client])
    {
        PrintCenterText(client, "CEBO QUIMICO: recarga %.1fs", g_fRougeBaitCooldown[client] - now);
        return Plugin_Handled;
    }

    g_fRougeBaitCooldown[client] = now + g_cvRougeBaitCD.FloatValue;

    float pos[3], ang[3], vel[3];
    GetClientEyePosition(client, pos);
    GetClientEyeAngles(client, ang);

    GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
    pos[0] += vel[0] * 30.0;
    pos[1] += vel[1] * 30.0;
    pos[2] += vel[2] * 30.0;

    // Crear la granada de tubo rosa
    int bomb = CreateEntityByName("pipe_bomb_projectile");
    if (bomb == -1)
    {
        PrintCenterText(client, "Error: no se pudo crear el cebo.");
        return Plugin_Handled;
    }

    DispatchKeyValue(bomb, "model", ROUGE_MODEL_BOMB);
    DispatchSpawn(bomb);

    // v8.1 (petición usuario) FIX "NO SE VE NI RASTRO": la granada del
    // Cebo Quimico volaba a 1500 (tiro plano tipo bala) y sin NINGÚN
    // rastro visual: nadie sabía dónde caía. Ahora tiene la MISMA
    // física y visibilidad de la Bat Bomb Spray (H2): arco de
    // lanzamiento 1100+300, trail VERDE quimico siguiendo la granada
    // y glow parpadeante hasta detonar.
    SetEntPropEnt(bomb, Prop_Data, "m_hThrower", client);
    SetEntPropEnt(bomb, Prop_Send, "m_hOwnerEntity", client);
    SetEntityRenderColor(bomb, 120, 255, 90, 255); // Verde quimico (visual de cebo toxico)

    // v7.2 FIX CEBO: el pipe_bomb_projectile tiene fuse NATIVO aleatorio
    // (~2.2-2.7s). Cuando ganaba la carrera contra nuestro timer de 2.5s,
    // la entidad se destruya sola ANTES de que T_RougeBaitDetonate corriera
    // -> sin explosión rosa, sin anillo y SOBRE TODO sin charco de acido
    // (la habilidad quedaba a medias y de forma aleatoria). Neutralizamos
    // el fuse nativo poniéndolo lejisimo: nuestro timer de 2.5s SIEMPRE
    // detona primero y destruye la bomba, por lo que el fuse nativo jamás
    // se alcanza. El beep/atracción de comunes del pipebomb sigue intacto
    // (es justo el comportamiento de "cebo" buscado).
    SetEntPropFloat(bomb, Prop_Data, "m_flDetonateTime", GetGameTime() + 3600.0);

    // Velocidad de lanzamiento (MISMO arco que la Habilidad 2)
    ScaleVector(vel, 1100.0);
    vel[2] += 300.0;
    TeleportEntity(bomb, pos, ang, vel);

    // v8.1: RASTRO VERDE siguiendo la granada (igual que las Bat
    // Bombs pero en verde quimico: se ve perfectamente donde vuela)
    TE_SetupBeamFollow(bomb, g_iRougeBeamSprite, 0, 0.8, 5.0, 5.0, 0, {120, 255, 80, 220});
    TE_SendToAll();

    // v8.1: glow parpadeante verde durante el vuelo (mismo patron de
    // la H2: 3 blips de 0.5s con glow sprite + parpadeo de color)
    DataPack blinkPack = new DataPack();
    blinkPack.WriteCell(EntIndexToEntRef(bomb));
    blinkPack.WriteCell(3);
    CreateTimer(0.5, T_RougeBaitBeep, blinkPack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    Rouge_TrackPack(blinkPack);

    // Timer propio para forzar la explosión a los ROUGE_BAIT_FUSE segundos
    DataPack dp = new DataPack();
    dp.WriteCell(EntIndexToEntRef(bomb));
    dp.WriteCell(GetClientUserId(client));
    CreateTimer(ROUGE_BAIT_FUSE, T_RougeBaitDetonate, dp, TIMER_FLAG_NO_MAPCHANGE);

    EmitSoundToAll(ROUGE_SND_THROW, client);
    PrintCenterText(client, "Cebo Quimico lanzado (explota en %.1fs)", ROUGE_BAIT_FUSE);

    return Plugin_Handled;
}

// v8.1: blips visuales del Cebo Quimico mientras vuela (clon del
// T_RougeBombBeep de la H2 pero en VERDE y sin sonido extra: el
// pipebomb nativo ya hace su propio beep de atracción de comunes).
public Action T_RougeBaitBeep(Handle timer, DataPack pack)
{
    pack.Reset();
    int ref = pack.ReadCell();
    int count = pack.ReadCell();

    int bomb = EntRefToEntIndex(ref);
    if (bomb == INVALID_ENT_REFERENCE || !IsValidEntity(bomb))
    {
        Rouge_UntrackPack(pack);
        return Plugin_Stop;
    }

    float pos[3];
    GetEntPropVector(bomb, Prop_Send, "m_vecOrigin", pos);
    pos[2] += 5.0;
    TE_SetupGlowSprite(pos, g_iRougeGlowSprite, 0.2, 2.0, 200);
    TE_SendToAll();

    // Parpadeo de color verde/verde claro
    if (count % 2 != 0) SetEntityRenderColor(bomb, 180, 255, 140, 255);
    else                 SetEntityRenderColor(bomb, 90, 220, 70, 255);

    count--;

    if (count <= 0)
    {
        Rouge_UntrackPack(pack);
        return Plugin_Stop;
    }

    pack.Reset();
    pack.WriteCell(ref);
    pack.WriteCell(count);

    return Plugin_Continue;
}

// Detonación del Cebo Quimico
public Action T_RougeBaitDetonate(Handle timer, DataPack dp)
{
    dp.Reset();
    int bombRef = dp.ReadCell();
    int clientUid = dp.ReadCell();
    delete dp; // Liberar memoria inmediatamente

    int bomb = EntRefToEntIndex(bombRef);
    int client = GetClientOfUserId(clientUid);

    // Validar bomba
    if (bomb <= 0 || !IsValidEntity(bomb))
        return Plugin_Stop;

    // Obtener posición antes de destruir la bomba
    float pos[3];
    GetEntPropVector(bomb, Prop_Send, "m_vecOrigin", pos);

    // 1. DESTRUIR LA GRANADA (para que deje de rebotar)
    RemoveEntity(bomb);

    // Validar cliente (puede haberse desconectado)
    int ownerClient = 0;
    if (client > 0 && IsClientInGame(client))
        ownerClient = client;

    // 2. EXPLOSION INICIAL (env_explosion nativa)
    Rouge_CreateExplosion(pos, ownerClient, ROUGE_BAIT_RADIUS);

    // 3. FIX CRITICO: CREAR CHARCO DE ACIDO REAL
    //    Spawn del insect_swarm (entidad nativa del spit del Spitter) que genera
    //    el efecto visual verde persistente. Adicionalmente lanzamos un timer
    //    de dano por tick paralelo como respaldo para garantizar dano real.
    Rouge_CreateAcidPool(pos, ownerClient);

    // 4. Dano inicial a infectados especiales y Tanks en el radio
    Rouge_DamageInfectedInRadius(pos, ROUGE_BAIT_RADIUS, g_cvRougeBaitDamage.FloatValue, ownerClient, DMG_BLAST, true);

    // 5. Anillo visual rosa expansivo
    TE_SetupBeamRingPoint(pos, 10.0, 350.0, g_iRougeBeamSprite, g_iRougeGlowSprite, 0, 15, 0.5, 10.0, 0.0, {255, 20, 147, 200}, 0, 0);
    TE_SendToAll();

    EmitSoundToAll(ROUGE_SND_BOOM, ownerClient > 0 ? ownerClient : 0);

    // 6. v10-OM: LA FUSION CON LA FLASH BANG DEL LUA — el Cebo Quimico
    //    ahora es el CEBO+FLASH: tras la explosión quimica llega el
    //    DESTELLO que ciega (estatua) lo que tenga línea de visión en
    //    400u: comunes/witch congelados, especiales stagger + lentitud
    //    x0.7 durante 6s (la rougeslowdown), tank lento.
    Rouge_FlashBang(pos, ownerClient);

    return Plugin_Stop;
}

// =====================================================================
//  v10-OM — EL DESTELLO DEL CEBO+FLASH (la Flash Bang del lua):
//  FindInSphere 400 + Visible() del lua -> aquí: radio + TR LOS.
//  * comunes/witch: OM_Stun (FL_FROZEN, tinte CYAN de ceguera)
//  * especiales: stagger 1.2 + lentitud x0.7 6s (SLOW de arriba)
//  * tank: lentitud x0.85 3s (resiste)
//  * si alcanzo a ALGUIEN: +20 de energía (smokebomb_reward del lua)
//  * VFX: destello BLANCO triple + om/rouge/flashbomb.wav
// =====================================================================
void Rouge_FlashBang(const float pos[3], int owner)
{
    float radius = g_cvRougeFlashRadius.FloatValue;

    // VFX del destello (el om_rouge_flash del lua: blanco total)
    TE_SetupGlowSprite(pos, g_iRougeGlowSprite, 0.45, 35.0, 255);
    TE_SendToAll();
    TE_SetupGlowSprite(pos, g_iRougeHaloSprite, 0.6, 55.0, 210);
    TE_SendToAll();
    TE_SetupBeamRingPoint(pos, 20.0, radius, g_iRougeBeamSprite, 0, 0, 30, 0.5, 22.0, 0.0, {255, 255, 255, 235}, 0, 0);
    TE_SendToAll();

    if (g_bRougeSndFlash) EmitSoundToAll("om/rouge/flashbomb.wav", _, SNDCHAN_AUTO, ROUGE_SND_LEVEL);
    else EmitSoundToAll(ROUGE_SND_BOOM, _, SNDCHAN_AUTO, 120);

    bool hitSomeone = false;
    float target[3];

    // ---- comunes + witch (con línea de visión al destello) ----
    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", target);
        if (GetVectorDistance(pos, target) > radius) continue;
        target[2] += 40.0;
        Handle tr = TR_TraceRayFilterEx(pos, target, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Rouge_TraceFilter_World, 0);
        bool clear = !TR_DidHit(tr);   // el Visible(ent2) del lua
        delete tr;
        if (!clear) continue;

        OM_Stun(ent, g_cvRougeFlashStun.FloatValue, owner, 0.0, DMG_OM_CLUB, false, OM_STUN_F_CYAN);
        hitSomeone = true;
    }
    ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", target);
        if (GetVectorDistance(pos, target) > radius) continue;
        target[2] += 40.0;
        Handle tr = TR_TraceRayFilterEx(pos, target, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Rouge_TraceFilter_World, 0);
        bool clear = !TR_DidHit(tr);
        delete tr;
        if (!clear) continue;

        Sonic_WitchStun(ent, g_cvRougeFlashStun.FloatValue);
        hitSomeone = true;
    }

    // ---- especiales y tank (players del equipo 3) ----
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == owner) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetClientTeam(i) != TEAM_INFECTED) continue;
        GetClientAbsOrigin(i, target);
        if (GetVectorDistance(pos, target) > radius) continue;
        target[2] += 40.0;
        Handle tr = TR_TraceRayFilterEx(pos, target, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Rouge_TraceFilter_World, 0);
        bool clear = !TR_DidHit(tr);
        delete tr;
        if (!clear) continue;

        int zClass = GetEntProp(i, Prop_Send, "m_zombieClass");
        if (zClass == 8)
        {
            Rouge_SlowAdd(i, 0.85, 3.0);   // el tank resiste el destello
        }
        else
        {
            SIStagger_Stagger(i, owner, pos, 1.2);
            Rouge_SlowAdd(i, g_cvRougeFlashSlow.FloatValue, g_cvRougeFlashSlowDur.FloatValue);
        }
        hitSomeone = true;
    }

    // ---- recompensa de energía (smokebomb_reward 20 del lua) ----
    if (hitSomeone && owner > 0 && IsClientInGame(owner) && IsPlayerAlive(owner))
    {
        g_fRougeEnergy[owner] += g_cvRougeFlashReward.FloatValue;
        float emax = g_cvRougeEnergyMax.FloatValue;
        if (g_fRougeEnergy[owner] > emax) g_fRougeEnergy[owner] = emax;
        PrintCenterText(owner, "💥 ¡CEBO+FLASH! (+%.0f energía)", g_cvRougeFlashReward.FloatValue);
    }
}

// FIX: Crear un charco de acido REAL que hace dano
// v7.1: Crea un charco de acido nativo usando SDKCall a CSpitterProjectile_Create
// Sistema basado en el plugin "Prototype Grenades" de Silvers.
// Requiere gamedata/rouge_abilities.txt con la signature CSpitterProjectile_Create.
void Rouge_CreateAcidPool(float pos[3], int ownerClient)
{
    // Ajustar posición al suelo para que el charco se posicione correctamente
    float groundPos[3];
    groundPos[0] = pos[0];
    groundPos[1] = pos[1];
    groundPos[2] = pos[2];

    // Trace hacia abajo para encontrar el suelo
    float endPos[3];
    endPos[0] = pos[0];
    endPos[1] = pos[1];
    endPos[2] = pos[2] - 100.0;

    Handle trace = TR_TraceRayFilterEx(pos, endPos, MASK_SOLID, RayType_EndPoint, Rouge_TraceFilter_NoPlayers, 0);
    if (TR_DidHit(trace))
    {
        TR_GetEndPosition(groundPos, trace);
    }
    delete trace;

    // === MÉTODO 1: SDKCall a CSpitterProjectile_Create (sistema de Silvers) ===
    // Esto crea un spit nativo del Spitter. El motor detecta el aterrizaje y
    // crea áutomaticamente un insect_swarm (el charco verde visible).
    // OnEntityCreated detectara el insect_swarm y lo trackeara en g_hRougeAcidPools.
    if (g_hRougeSDK_Spit != null && ownerClient > 0)
    {
        // Activar flag para que OnEntityCreated capture el próximo insect_swarm
        g_bRougeAcidSpawn = true;

        // Posición: ligeramente arriba del suelo para que el spit caiga
        float spawnPos[3];
        spawnPos[0] = groundPos[0];
        spawnPos[1] = groundPos[1];
        spawnPos[2] = groundPos[2] + 5.0;

        // Angulos: sin rotación
        float ang[3];
        ang[0] = 0.0;
        ang[1] = 0.0;
        ang[2] = 0.0;

        // Velocidad: hacia abajo para forzar el aterrizaje rápido
        float vel[3];
        vel[0] = 0.0;
        vel[1] = 0.0;
        vel[2] = -100.0;

        // Llamar a CSpitterProjectile_Create(pos, ang, vel, ang, owner)
        int acidEnt = SDKCall(g_hRougeSDK_Spit, spawnPos, ang, vel, ang, ownerClient);

        if (acidEnt > 0 && IsValidEntity(acidEnt))
        {
            // Setear owner para que el dano se atribuya correctamente
            SetEntPropEnt(acidEnt, Prop_Data, "m_hThrower", ownerClient);
            SetEntPropEnt(acidEnt, Prop_Send, "m_hOwnerEntity", ownerClient);
        }
    }
    else
    {
        // === MÉTODO 1 FALLBACK: Crear spitter_projectile manualmente ===
        // Si no hay gamedata, usar el método manual (menos confiable)
        int acidEnt = CreateEntityByName("spitter_projectile");
        if (acidEnt != -1)
        {
            DispatchSpawn(acidEnt);

            if (ownerClient > 0)
            {
                SetEntPropEnt(acidEnt, Prop_Data, "m_hThrower", ownerClient);
                SetEntPropEnt(acidEnt, Prop_Send, "m_hOwnerEntity", ownerClient);
            }

            float spawnPos[3];
            spawnPos[0] = groundPos[0];
            spawnPos[1] = groundPos[1];
            spawnPos[2] = groundPos[2] + 50.0;

            float vel[3];
            vel[0] = 0.0;
            vel[1] = 0.0;
            vel[2] = -200.0;

            TeleportEntity(acidEnt, spawnPos, NULL_VECTOR, vel);

            if (g_hRougeAcidPools != null)
                g_hRougeAcidPools.Push(EntIndexToEntRef(acidEnt));

            CreateTimer(ROUGE_ACID_DURATION, T_RougeAcidCleanup, EntIndexToEntRef(acidEnt), TIMER_FLAG_NO_MAPCHANGE);
        }
    }

    // === MÉTODO 2: Timer de dano por tick paralelo (respaldo robusto) ===
    // Esto garantiza que SIEMPRE haya dano a infectados en el área, sin importar
    // si el charco nativo funciona o no.
    DataPack acidPack = new DataPack();
    acidPack.WriteFloat(groundPos[0]);
    acidPack.WriteFloat(groundPos[1]);
    acidPack.WriteFloat(groundPos[2]);
    acidPack.WriteCell(GetClientUserId(ownerClient > 0 ? ownerClient : 0));
    acidPack.WriteCell(0); // contador de ticks

    int maxTicks = RoundToNearest(ROUGE_ACID_DURATION / ROUGE_ACID_TICK);
    acidPack.WriteCell(maxTicks);

    CreateTimer(ROUGE_ACID_TICK, T_RougeAcidTick, acidPack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    Rouge_TrackPack(acidPack); // v7.2: liberación garantizada en mapchange

    // Efectos visuales adicionales (anillo verde inicial + sonido de spit)
    TE_SetupBeamRingPoint(groundPos, 10.0, ROUGE_ACID_RADIUS, g_iRougeBeamSprite, g_iRougeGlowSprite, 0, 15, 0.5, 8.0, 0.0, {120, 255, 80, 200}, 0, 0);
    TE_SendToAll();

    TE_SetupSparks(groundPos, NULL_VECTOR, 5, 3);
    TE_SendToAll();

    EmitSoundToAll(ROUGE_SND_ACID, ownerClient > 0 ? ownerClient : 0, _, _, _, 0.7);
}

// Timer de dano por tick del charco de acido (respaldo robusto)
public Action T_RougeAcidTick(Handle timer, DataPack pack)
{
    pack.Reset();
    float pos[3];
    pos[0] = pack.ReadFloat();
    pos[1] = pack.ReadFloat();
    pos[2] = pack.ReadFloat();
    int ownerUid = pack.ReadCell();
    int tickCount = pack.ReadCell();
    int maxTicks = pack.ReadCell();

    int owner = GetClientOfUserId(ownerUid);
    if (owner > 0 && !IsClientInGame(owner)) owner = 0;

    tickCount++;

    // Dano a infectados especiales (y Tank)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float tPos[3];
        GetClientAbsOrigin(i, tPos);
        if (GetVectorDistance(pos, tPos) <= ROUGE_ACID_RADIUS)
        {
            float dmg = ROUGE_ACID_DMG_SPEC;
            // Detectar si es Tank (zombie type 8)
            if (GetEntProp(i, Prop_Send, "m_zombieClass") == 8)
                dmg = ROUGE_ACID_DMG_TANK;

            SDKHooks_TakeDamage(i,
                owner > 0 ? owner : 0,
                owner > 0 ? owner : 0,
                dmg,
                DMG_ACID);
        }
    }

    // Dano a infectados comunes en el radio
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float zPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(pos, zPos) <= ROUGE_ACID_RADIUS)
        {
            SDKHooks_TakeDamage(entity,
                owner > 0 ? owner : 0,
                owner > 0 ? owner : 0,
                ROUGE_ACID_DMG_COMM,
                DMG_ACID);
        }
    }

    // Efecto visual cada 2 ticks (chispas verdes)
    if (tickCount % 2 == 0)
    {
        TE_SetupSparks(pos, NULL_VECTOR, 3, 1);
        TE_SendToAll();
    }

    // Fin del charco
    if (tickCount >= maxTicks)
    {
        Rouge_UntrackPack(pack);
        return Plugin_Stop;
    }

    // Re-escribir todo el DataPack con el tickCount actualizado
    // (evita problemas de pack.Position entre versiones de SourcePawn)
    pack.Reset();
    pack.WriteFloat(pos[0]);
    pack.WriteFloat(pos[1]);
    pack.WriteFloat(pos[2]);
    pack.WriteCell(ownerUid);
    pack.WriteCell(tickCount);
    pack.WriteCell(maxTicks);

    return Plugin_Continue;
}

// Limpieza del insect_swarm al expirar
public Action T_RougeAcidCleanup(Handle timer, int ref)
{
    int entity = EntRefToEntIndex(ref);
    if (entity > 0 && IsValidEntity(entity))
    {
        // Remover del ArrayList
        if (g_hRougeAcidPools != null)
        {
            int idx = g_hRougeAcidPools.FindValue(ref);
            if (idx != -1) g_hRougeAcidPools.Erase(idx);
        }
        RemoveEntity(entity);
    }
    return Plugin_Stop;
}

// =======================
// HABILIDAD 2: BAT BOMB SPRAY
// =======================

public Action Command_RougeBomb(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Rouge_IsValidClient(client)) return Plugin_Handled;
    // R28 (set ROUGE de Sage): idem Command_RougeKick — solo granadas.
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX
        && !(g_iPlayerCharIdx[client] == SAGE_INDEX && g_iSageActiveSet[client] == SAGESET_ROUGE)) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fRougeBombCooldown[client])
    {
        PrintCenterText(client, "BAT BOMB SPRAY: recarga %.1fs", g_fRougeBombCooldown[client] - now);
        return Plugin_Handled;
    }

    float eyePos[3], eyeAng[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);

    int bombsCreated = 0;
    for (int i = 0; i < 3; i++)
    {
        float throwAng[3], fwd[3], spawnPos[3];
        throwAng[0] = eyeAng[0];
        throwAng[1] = eyeAng[1];
        throwAng[2] = eyeAng[2];

        // Abanico: bomba central + 2 laterales
        if (i == 1) throwAng[1] -= 22.0;
        else if (i == 2) throwAng[1] += 22.0;

        GetAngleVectors(throwAng, fwd, NULL_VECTOR, NULL_VECTOR);

        spawnPos[0] = eyePos[0] + (fwd[0] * 35.0);
        spawnPos[1] = eyePos[1] + (fwd[1] * 35.0);
        spawnPos[2] = eyePos[2] + (fwd[2] * 35.0);

        int bomb = CreateEntityByName("pipe_bomb_projectile");
        if (bomb == -1) continue;

        DispatchKeyValue(bomb, "model", ROUGE_MODEL_BOMB);
        DispatchSpawn(bomb);

        float velocity[3];
        velocity[0] = fwd[0] * 1100.0;
        velocity[1] = fwd[1] * 1100.0;
        velocity[2] = fwd[2] * 1100.0 + 300.0;

        TeleportEntity(bomb, spawnPos, throwAng, velocity);

        SetEntPropEnt(bomb, Prop_Send, "m_hOwnerEntity", client);
        SetEntityRenderColor(bomb, 255, 0, 255, 255);

        // Trail rosa siguiendo la bomba
        TE_SetupBeamFollow(bomb, g_iRougeBeamSprite, 0, 0.8, 5.0, 5.0, 0, {255, 20, 147, 200});
        TE_SendToAll();

        // Hook de toque para detonación por contacto
        SDKHook(bomb, SDKHook_Touch, BatBomb_OnTouch);

        // Trackear en ArrayList (reemplaza g_bBombDetonated[2048])
        if (g_hRougeActiveBombs != null)
            g_hRougeActiveBombs.Push(EntIndexToEntRef(bomb));

        // Timer de detonación por fuse
        CreateTimer(g_cvRougeBombTimer.FloatValue, T_RougeDetonateBomb, EntIndexToEntRef(bomb), TIMER_FLAG_NO_MAPCHANGE);

        // Beep parpadeante
        DataPack pack = new DataPack();
        pack.WriteCell(EntIndexToEntRef(bomb));
        pack.WriteCell(2);
        CreateTimer(0.5, T_RougeBombBeep, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        Rouge_TrackPack(pack); // v7.2: liberación garantizada en mapchange

        bombsCreated++;
    }

    if (bombsCreated == 0)
    {
        PrintCenterText(client, "Error: no se pudieron crear las bombas.");
        return Plugin_Handled;
    }

    g_fRougeBombCooldown[client] = now + g_cvRougeBombCD.FloatValue;
    EmitSoundToAll(ROUGE_SND_THROW, client);
    PrintCenterText(client, "¡Bat Bombs x3 lanzadas!");

    return Plugin_Handled;
}

// Verifica si una bomba ya fue detonada (usando ArrayList)
bool Rouge_IsBombDetonated(int bomb)
{
    if (bomb <= 0 || !IsValidEntity(bomb)) return true;
    if (g_hRougeActiveBombs == null) return true;

    int ref = EntIndexToEntRef(bomb);
    return g_hRougeActiveBombs.FindValue(ref) == -1;
}

// Marca una bomba como detonada (la remueve del ArrayList)
void Rouge_MarkBombDetonated(int bomb)
{
    if (bomb <= 0 || g_hRougeActiveBombs == null) return;

    int ref = EntIndexToEntRef(bomb);
    int idx = g_hRougeActiveBombs.FindValue(ref);
    if (idx != -1) g_hRougeActiveBombs.Erase(idx);
}

public Action BatBomb_OnTouch(int bomb, int other)
{
    if (bomb <= 0 || !IsValidEntity(bomb)) return Plugin_Continue;
    if (Rouge_IsBombDetonated(bomb)) return Plugin_Continue;

    int owner = GetEntPropEnt(bomb, Prop_Send, "m_hOwnerEntity");
    if (other == owner) return Plugin_Continue;

    // v7.2 FIX: SDKHook_Touch dispara también contra el mundo (entity 0) y
    // contra props/geometry. Antes la bomba detonaba al PRIMER bote contra
    // el suelo (el "abanico" explotaba a los pies de Rouge en vez de volar
    // y rodar). Ahora solo detona contra objetivos válidos:
    //   - Jugadores (sobrevivientes/infectados especiales, incl. bots)
    //   - Infectados comunes (NPC "infected")
    //   - Witches (NPC "witch")
    // Contra muros/suelo/props la bomba rebota y el fuse la detona.
    if (other == 0) return Plugin_Continue; // worldspawn

    if (other > MaxClients)
    {
        if (!IsValidEntity(other)) return Plugin_Continue;

        static char cls[16];
        GetEntityClassname(other, cls, sizeof(cls));

        // Ignorar otras bombas (abanico)
        if (strcmp(cls, "pipe_bomb_projectile") == 0) return Plugin_Continue;

        // v7.2: solo detonar contra seres vivos del director; el resto
        // (props, puertas, physics) hace que rebote
        if (strcmp(cls, "infected") != 0 && strcmp(cls, "witch") != 0)
            return Plugin_Continue;
    }

    CreateTimer(0.05, T_RougeDetonateBomb, EntIndexToEntRef(bomb), TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Continue;
}

public Action T_RougeBombBeep(Handle timer, DataPack pack)
{
    pack.Reset();
    int ref = pack.ReadCell();
    int count = pack.ReadCell();

    int bomb = EntRefToEntIndex(ref);
    if (bomb == INVALID_ENT_REFERENCE || !IsValidEntity(bomb) || Rouge_IsBombDetonated(bomb))
    {
        Rouge_UntrackPack(pack);
        return Plugin_Stop;
    }

    EmitSoundToAll(ROUGE_SND_BEEP, bomb);

    float pos[3];
    GetEntPropVector(bomb, Prop_Send, "m_vecOrigin", pos);
    pos[2] += 5.0;
    TE_SetupGlowSprite(pos, g_iRougeGlowSprite, 0.2, 1.5, 200);
    TE_SendToAll();

    // Parpadeo de colores
    int r = 255, g = 0, b = 255;
    if (count % 2 != 0) { r = 255; g = 100; b = 255; }
    SetEntityRenderColor(bomb, r, g, b, 255);

    count--;

    if (count <= 0)
    {
        Rouge_UntrackPack(pack);
        return Plugin_Stop;
    }

    // Re-escribir todo el DataPack con el count actualizado
    // (evita problemas de pack.Position entre versiones de SourcePawn)
    pack.Reset();
    pack.WriteCell(ref);
    pack.WriteCell(count);

    return Plugin_Continue;
}

public Action T_RougeDetonateBomb(Handle timer, int ref)
{
    int bomb = EntRefToEntIndex(ref);
    if (bomb == INVALID_ENT_REFERENCE || !IsValidEntity(bomb) || Rouge_IsBombDetonated(bomb))
        return Plugin_Stop;

    // Marcar como detonada (remueve del ArrayList)
    Rouge_MarkBombDetonated(bomb);

    float pos[3];
    GetEntPropVector(bomb, Prop_Send, "m_vecOrigin", pos);
    int owner = GetEntPropEnt(bomb, Prop_Send, "m_hOwnerEntity");
    if (!Rouge_IsValidClient(owner)) owner = 0;

    // Explosión nativa (env_explosion) para efecto visual realista
    Rouge_CreateExplosion(pos, owner, g_cvRougeBombRadius.FloatValue);

    // Ring rosa expansivo
    TE_SetupBeamRingPoint(pos, 10.0, g_cvRougeBombRadius.FloatValue, g_iRougeBeamSprite, g_iRougeGlowSprite, 0, 15, 0.4, 20.0, 0.0, {255, 20, 147, 255}, 10, 0);
    TE_SendToAll();

    // Particula del pipebomb nativo
    int particle = CreateEntityByName("info_particle_system");
    if (IsValidEntity(particle))
    {
        DispatchKeyValue(particle, "effect_name", "weapon_pipebomb");
        DispatchKeyValueVector(particle, "origin", pos);
        DispatchSpawn(particle);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "Start");
        SetVariantString("OnUser1 !self:kill::2.0:1");
        AcceptEntityInput(particle, "AddOutput");
        AcceptEntityInput(particle, "FireUser1");
    }

    // Dano a infectados especiales y comunes en el radio
    Rouge_DamageInfectedInRadius(pos, g_cvRougeBombRadius.FloatValue, g_cvRougeBombDamage.FloatValue, owner, DMG_BLAST, true);

    // Destruir la bomba
    RemoveEntity(bomb);

    return Plugin_Stop;
}

// =======================
// UTILIDADES
// =======================

// Crea una explosión VISUAL (sin dano nativo). El dano real lo hace Rouge_DamageInfectedInRadius
// que filtra por equipo (solo infectados). Esto evita que Rouge se dane a si misma.
// v7.2: eliminado el parámetro "damage" (nunca se usaba -> warning 203) y
// sustituidos los PrecacheModel en runtime por los sprites ya precacheados
// en Rouge_OnMapStart (el halo se precachea allí desde v7.2).
void Rouge_CreateExplosion(float pos[3], int owner, float radius)
{
    // Usar TE_SetupExplosion para efecto visual puro (no hace dano)
    TE_SetupExplosion(pos, g_iRougeGlowSprite, 10.0, 1, 0, RoundToNearest(radius), 0);
    TE_SendToAll();

    // Beam ring expansivo para efecto visual
    int color[4] = {255, 20, 147, 200}; // Rosa
    TE_SetupBeamRingPoint(pos, 10.0, radius, g_iRougeBeamSprite, g_iRougeHaloSprite, 0, 15, 0.5, 10.0, 0.0, color, 5, 0);
    TE_SendToAll();

    // Sonido de explosión
    EmitSoundToAll(ROUGE_SND_BOOM, owner > 0 ? owner : 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // NOTA: No usamos env_explosion nativa porque dana a TODOS los jugadores
    // incluyendo a Rouge. El dano real se hace vía Rouge_DamageInfectedInRadius
    // que filtra por equipo (solo TEAM_INFECTED).
}

// v8.0: dano de área a infectados especiales, comunes Y WITCHES.
//  - especiales: dano + stagger SEGURO (SIStagger_Auto: auto-cancel
//    del estado del motor a los 1.8s/3.0s -> fix del bug "los
//    staggered no se levantan del suelo").
//  - comunes: EMPUJE ANTES del dano (el ragdoll hereda el impulso y
//    sale volando; mismo fix que el martillo de Amy v45) + dano x2.
//  - witch: dano + lanzamiento con WitchFlight (suspende su IA, vuela
//    de verdad y recibe dano de impacto al aterrizar).
void Rouge_DamageInfectedInRadius(float pos[3], float radius, float damage, int attacker, int dmgType, bool stagger)
{
    // Infectados especiales (players)
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float tPos[3];
        GetClientAbsOrigin(i, tPos);
        if (GetVectorDistance(pos, tPos) <= radius)
        {
            SDKHooks_TakeDamage(i,
                attacker > 0 ? attacker : 0,
                attacker > 0 ? attacker : 0,
                damage,
                dmgType);
            // v8.0: stagger SEGURO (antes: L4D_StaggerPlayer crudo ->
            // los bots infectados podían quedar tirados para siempre).
            if (stagger) SIStagger_Auto(i, attacker > 0 ? attacker : 0, pos);
        }
    }

    // Infectados comunes (NPCs)
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        float zPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(pos, zPos) <= radius)
        {
            // v8.0: empuje ANTES del dano: el ragdoll hereda el impulso
            // (antes solo recibian dano y caían en el sitio).
            float push[3];
            MakeVectorFromPoints(pos, zPos, push);
            push[2] = 0.0;
            if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; }
            NormalizeVector(push, push);
            ScaleVector(push, 600.0);
            push[2] = 200.0;
            TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, push);

            SDKHooks_TakeDamage(entity,
                attacker > 0 ? attacker : 0,
                attacker > 0 ? attacker : 0,
                damage * 2.0, // Comunes reciben más dano
                dmgType);
        }
    }

    // v8.0: WITCHES (antes quedaban totalmente fuera del radio de la
    // explosión: ni dano ni nada). Dano acreditado + lanzamiento por
    // los aires con su IA suspendida (WitchFlight).
    entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (!IsValidEntity(entity)) continue;

        float wPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", wPos);
        if (GetVectorDistance(pos, wPos) <= radius)
        {
            // Lanzamiento ANTES del dano (vuela gritando; el dano la
            // enoja pero no puede perseguir mientras este en el aire).
            float push[3], launch[3];
            MakeVectorFromPoints(pos, wPos, push);
            push[2] = 0.0;
            if (GetVectorLength(push) < 1.0) { push[0] = 0.0; push[1] = 1.0; }
            NormalizeVector(push, push);
            launch[0] = push[0] * 400.0;
            launch[1] = push[1] * 400.0;
            launch[2] = 350.0;
            WitchFlight_Launch(entity, attacker > 0 ? attacker : 0, launch);

            SDKHooks_TakeDamage(entity,
                attacker > 0 ? attacker : 0,
                attacker > 0 ? attacker : 0,
                damage,
                dmgType);
        }
    }
}

// Trace filter que ignora players
public bool Rouge_TraceFilter_NoPlayers(int entity, int contentsMask, int data)
{
    if (entity > 0 && entity <= MaxClients) return false;
    return true;
}

// =======================
// HABILIDAD 3: ONDA NEGRA (Black Wave) v9.0 - RONDA 29
// =======================
// "La 1 que dijiste esta destructora" (concepto A: onda expansiva
// negra pura) + 2 pedidos del owner: (1) SIN TEMBLOR ("para evitar
// mareos por usos constantes y demas": cero env_shake, cero
// ScreenShake) y (2) la onda JALA: witch y comunes vía el MÉTODO DEL
// MARTILLO DE AMY (Witch_Flight v2.x): cerebro apagado (FL_FROZEN =
// el gate del motor NextBot) + cuerpo congelado (MOVETYPE_NONE) ->
// arrastre real por teleports hasta los pies de Rouge.
// NOTA: NO hizo falta editar el VScript del Super Tank (el owner dio
// permiso pero la onda es NATIVA de Rouge.inc: control total, patron
// Sally/Amy). Solo TOMA PRESTADA su particula "gas_explosion_ground_
// wave" (precacheada por nosotros en Rouge_OnMapStart).

public Action Command_RougeBlackWave(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Rouge_IsValidClient(client)) return Plugin_Handled;

    // H3 EXCLUSIVA de la Rouge real: las granadas Z/X se prestan al
    // set ROUGE de Sage (R28), pero la Onda Negra es la FIRMA de
    // Rouge (como su evasión o su planeo, que tampoco se prestan).
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return Plugin_Handled;

    float now = GetEngineTime();
    if (now < g_fRougeWaveCooldown[client])
    {
        PrintCenterText(client, "ONDA NEGRA: recarga %.1fs", g_fRougeWaveCooldown[client] - now);
        return Plugin_Handled;
    }

    g_fRougeWaveCooldown[client] = now + g_cvRougeWaveCD.FloatValue;

    Rouge_BlackWaveCast(client);
    return Plugin_Handled;
}

// Cast completo: VFX (SIN temblor) + succión de players + congela y
// arrastra comunes/witches. El dano de players es INMEDIATO; el de
// comunes/witches llega CON ELLOS (a los 0.75s: el owner quiere VER
// el arrastre, no un piso de cadaveres instantaneo).
void Rouge_BlackWaveCast(int client)
{
    float radius = g_cvRougeWaveRadius.FloatValue;
    float center[3];
    GetClientAbsOrigin(client, center);

    // --- FASE 1: VFX (sin temblor) ---
    Rouge_BlackWaveVFX(center, radius);
    EmitSoundToAll(ROUGE_SND_BOOM, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

    // --- FASE 2: especiales/tank (players) ---
    Rouge_BlackWavePullPlayers(client, center, radius);

    // v9.1: punto de CONVERGENCIA = el corazon del nucleo (levemente
    // elevado): las victimas no patinan por el piso, se succionan hacia
    // la esfera y al liberarse caen/danan a los pies de Rouge.
    float conv[3];
    conv[0] = center[0];
    conv[1] = center[1];
    conv[2] = center[2] + ROUGE_WAVE_SPHERE_LIFT;

    // --- FASE 3: comunes + witches (el método del martillo) ---
    int nCommons = Rouge_BlackWaveGrabCommons(client, conv, radius);
    int nWitches = Rouge_BlackWaveGrabWitches(client, conv, radius);

    // v9.1: EL NUCLEO — la esfera negra visible. Muere con la marea
    // (T_RougeWaveArrival lleva SU ref) y de backstop a los 5s.
    int sphere = Rouge_WaveSpawnSphere(conv);
    int sphereRef = (sphere > 0) ? EntIndexToEntRef(sphere) : 0;

    // --- colapso de llegada: la esfera se traga todo + boom ---
    CreateTimer(ROUGE_WAVE_DRAG_TIME, T_RougeWaveArrival, sphereRef, TIMER_FLAG_NO_MAPCHANGE);

    if (nCommons + nWitches > 0)
        PrintCenterText(client, "ONDA NEGRA: %d infectados y %d witches jalados hacia ti", nCommons, nWitches);
    else
        PrintCenterText(client, "ONDA NEGRA: nada en rango");
}

// Onda visual NEGRO-MAGENTA: 2 anillos que se EXPANDEN + 1 anillo que
// se CONTRAE (start > end: el beam ring se colapsa solo hacia el
// centro = la implosión de la succión). TE_SendToAll admite delay ->
// coreografia SIN timers. CERO temblor (pedido literal del owner).
void Rouge_BlackWaveVFX(const float center[3], float radius)
{
    int color[4];
    color[0] = 60; color[1] = 0; color[2] = 95; color[3] = 255;   // negro-magenta

    // Anillo principal: expansión completa (gordo, 0.9s de vida)
    TE_SetupBeamRingPoint(center, 20.0, radius, g_iRougeBeamSprite, g_iRougeGlowSprite,
                          0, 15, 0.9, 45.0, 0.0, color, 5, 0);
    TE_SendToAll();

    // Anillo secundario: interior, más rápido (delay 0.1s)
    TE_SetupBeamRingPoint(center, 10.0, radius * 0.6, g_iRougeBeamSprite, g_iRougeGlowSprite,
                          0, 15, 0.5, 25.0, 0.0, color, 5, 0);
    TE_SendToAll(0.1);

    // IMPLOSION: el anillo VUELVE del borde al centro (delay 0.55s,
    // justo cuando la succión está terminando de traerlos)
    TE_SetupBeamRingPoint(center, radius, 40.0, g_iRougeBeamSprite, g_iRougeGlowSprite,
                          0, 15, 0.35, 30.0, 0.0, color, 5, 0);
    TE_SendToAll(0.55);

    // Particulas de suelo (la misma del agujero negro del Super Tank)
    Rouge_BlackWaveParticle(center);
}

// Particula de suelo temporal (patron Rouge_CreateExplosion /
// Amy_VFX_Particle). "gas_explosion_ground_wave" es LA MISMA que el
// agujero negro del Super Tank re-emite cada 0.5s.
void Rouge_BlackWaveParticle(const float pos[3])
{
    int particle = CreateEntityByName("info_particle_system");
    if (!IsValidEntity(particle)) return;
    DispatchKeyValue(particle, "effect_name", "gas_explosion_ground_wave");
    DispatchSpawn(particle);
    ActivateEntity(particle);
    TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(particle, "Start");
    SetVariantString("OnUser1 !self:kill::3.0:1");
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");
}

// v9.0: registrar particulas en la tabla del motor (patron
// PrecacheParticle de Amy.inc). Si el addon del Super Tank ya las
// precacheo, esto es un no-op inocuo.
void Rouge_WavePrecacheParticle(const char[] name)
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

// Impacto de la marea: LA ESFERA SE TRAGA TODO. El nucleo colapsa
// (kill) justo cuando las victimas llegan al borde, con su anillo de
// implosión rápido + particula de suelo + boom. La ref del nucleo viaja
// en el propio timer (multi-cast seguro: cada onda colapsa SU esfera).
public Action T_RougeWaveArrival(Handle timer, any:ref)
{
    float at[3];
    bool havePos = false;

    if (ref != 0 && ref != INVALID_ENT_REFERENCE)
    {
        int ent = EntRefToEntIndex(ref);
        if (ent > 0 && IsValidEntity(ent))
        {
            GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", at);
            havePos = true;
            AcceptEntityInput(ent, "Kill");   // COLAPSO del nucleo
        }
    }

    if (havePos)
    {
        // anillo de implosión violento (300u -> 10u en 0.25s): la
        // esfera chupa el aire que dejo
        int color[4];
        color[0] = 60; color[1] = 0; color[2] = 95; color[3] = 255;
        TE_SetupBeamRingPoint(at, 300.0, 10.0, g_iRougeBeamSprite, g_iRougeGlowSprite,
                              0, 15, 0.25, 60.0, 0.0, color, 5, 0);
        TE_SendToAll();

        // fogonazo de suelo en el punto del colapso
        Rouge_BlackWaveParticle(at);
    }

    EmitSoundToAll(ROUGE_SND_KICK_HIT, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
    return Plugin_Stop;
}

// v9.1: EL NUCLEO de la Onda Negra — esfera translucida NEGRO-MAGENTA
// (mismo modelo del escudo de Sally / bola de Knuckles: familia visual
// del proyecto), solida CERO, colgada sobre el punto de cast. Es el
// "agujero negro" hacia el que se succionan las victimas. Muere con la
// marea (T_RougeWaveArrival lleva su ref) y de backstop sola a los 5s
// (patron particula: si el timer muriera en un cambio de mapa, la
// entidad muere con el mapa o con su OnUser1: cero fugas).
int Rouge_WaveSpawnSphere(const float conv[3])
{
    int sphere = CreateEntityByName("prop_dynamic_override");
    if (sphere == -1 || !IsValidEntity(sphere)) return -1;

    DispatchKeyValue(sphere, "model", ROUGE_WAVE_SPHERE_MDL);
    DispatchKeyValue(sphere, "solid", "0");
    DispatchSpawn(sphere);

    // nucleo negro-magenta DENSO (es un agujero negro, no una burbuja)
    SetEntityRenderMode(sphere, RENDER_TRANSCOLOR);
    SetEntityRenderColor(sphere, 30, 0, 45, 200);
    if (HasEntProp(sphere, Prop_Send, "m_flModelScale"))
        SetEntPropFloat(sphere, Prop_Send, "m_flModelScale", ROUGE_WAVE_SPHERE_SCALE);

    TeleportEntity(sphere, conv, NULL_VECTOR, NULL_VECTOR);

    // backstop de autoneteo (patron Rouge_BlackWaveParticle)
    SetVariantString("OnUser1 !self:kill::5.0:1");
    AcceptEntityInput(sphere, "AddOutput");
    AcceptEntityInput(sphere, "FireUser1");

    return sphere;
}

// Especiales y tank son PLAYERS: no se congelan (FL_FROZEN sobre un
// player le roba el control del teclado). Su jalon es FÍSICO:
// velocidad de succión hacia el punto de cast + stagger seguro (no
// pueden re-atacar mientras deslizan) + dano inmediato acreditado.
void Rouge_BlackWavePullPlayers(int client, const float center[3], float radius)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        float tPos[3];
        GetClientAbsOrigin(i, tPos);
        if (GetVectorDistance(center, tPos) > radius) continue;

        // succión (con lift corto: se ve el jalon y no se pegan al
        // suelo por fricción)
        float pull[3];
        MakeVectorFromPoints(tPos, center, pull);
        pull[2] = 0.0;
        if (GetVectorLength(pull) < 1.0) { pull[0] = 0.0; pull[1] = 1.0; }
        NormalizeVector(pull, pull);
        ScaleVector(pull, ROUGE_WAVE_SI_PULL);
        pull[2] = 120.0;
        TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, pull);

        SDKHooks_TakeDamage(i, client, client, OM_AmpDamage(i, g_cvRougeWaveDamage.FloatValue), DMG_CLUB);
        SIStagger_Auto(i, client, center);
    }
}

// COMUNES: "apagarles el cerebro y congelarlos para que ellos también
// puedan ser jalados" (pedido literal). FL_FROZEN apaga su NextBot y
// MOVETYPE_NONE congela el cuerpo; el tick los arrastra.
int Rouge_BlackWaveGrabCommons(int client, const float center[3], float radius)
{
    int grabbed = 0;
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (!IsValidEntity(entity)) continue;

        float zPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
        if (GetVectorDistance(center, zPos) > radius) continue;

        if (Rouge_WaveGrab(client, entity, false, center)) grabbed++;
    }
    return grabbed;
}

// WITCH: "el método que se uso con el golpe de martillo de amy que
// apaga su Nextbot y la congela como tal para que esta pueda
// comportarse igual" (pedido literal). El martillo la LANZA
// (WitchFlight_Launch); aquí la congelamos IGUAL pero la ARRASTRAMOS
// hacia Rouge. Si ya está volando por un golpe, no se toca (su vuelo
// sigue su curso normal).
int Rouge_BlackWaveGrabWitches(int client, const float center[3], float radius)
{
    int grabbed = 0;
    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "witch")) != -1)
    {
        if (!IsValidEntity(entity)) continue;
        if (WitchFlight_IsFlying(entity)) continue;   // en pleno vuelo: libre

        float wPos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", wPos);
        if (GetVectorDistance(center, wPos) > radius) continue;

        if (Rouge_WaveGrab(client, entity, true, center)) grabbed++;
    }
    return grabbed;
}

// Congela una entidad infectada (común o witch) y le reserva slot de
// arrastre. Guarda movetype/flags ORIGINALES para restaurar EXACTO.
bool Rouge_WaveGrab(int client, int entity, bool isWitch, const float center[3])
{
    // Guard de salud (patron WF v2.4): una entidad muriendo no se
    // congela NUNCA (su transición de muerte + congelamiento es el
    // tipo de intervención que tumba el motor).
    if (GetEntProp(entity, Prop_Data, "m_iHealth") <= 0) return false;

    int ref = EntIndexToEntRef(entity);

    // Slot: el suyo si ya esta arrastrado (re-cast) o uno libre
    int slot = -1;
    for (int i = 0; i < ROUGE_WAVE_SLOTS; i++)
    {
        if (g_iRWWRef[i] == ref) { slot = i; break; }
        if (slot == -1 && g_iRWWRef[i] == 0) slot = i;
    }
    if (slot == -1) return false;   // pool lleno: fuera de la succión

    if (g_iRWWRef[slot] != ref)
    {
        // Slot NUEVO: capturar el estado ORIGINAL antes de congelar.
        // (En un re-cast NO se re-captura: el original legitimo es el
        // previo al primer congelamiento, no el NONE que pusimos.)
        g_iRWWOrigMT[slot]    = view_as<int>(GetEntityMoveType(entity));
        g_iRWWOrigFlags[slot] = GetEntityFlags(entity);
        g_bRWWWitch[slot]     = isWitch;

        // v9.1 FIX CRITICO (el bug de las estatuas eternas): el slot
        // NUNCA registraba a la victima -> T_RougeWaveTick veía el pool
        // vacío, contaba active == 0 y SE APAGABA en su primer tick.
        // Congelaba... y nadie arrastraba ni liberaba JAMÁS.
        g_iRWWRef[slot] = ref;
    }

    g_iRWWAttacker[slot] = (client > 0 && client <= MaxClients && IsClientInGame(client)) ? client : 0;
    g_fRWWEnd[slot]      = GetEngineTime() + ROUGE_WAVE_DRAG_TIME;
    g_fRWWLast[slot]     = GetEngineTime();
    g_vRWWCenter[slot][0] = center[0];
    g_vRWWCenter[slot][1] = center[1];
    g_vRWWCenter[slot][2] = center[2];

    // EL MÉTODO DEL MARTILLO (dos capas, literal de Witch_Flight v2.0):
    //  1) FL_FROZEN: el gate del propio motor NextBot (DoThink solo
    //     invoca Update() si (GetFlags() & FL_FROZEN) == 0). Con el
    //     flag puesto su locomoción/comportamiento no corren -> nadie
    //     re-escribe su posición y no puede atacar mientras viaja.
    //  2) MOVETYPE_NONE: la física del motor tampoco integra nada.
    SetEntityMoveType(entity, MOVETYPE_NONE);
    SetEntityFlags(entity, GetEntityFlags(entity) | FL_FROZEN);

    if (g_hRWWTick == null)
    {
        // SIN TIMER_FLAG_NO_MAPCHANGE (patron WF): si el mapa cambia,
        // las refs se limpian solas al primer tick y el timer se apaga
        // el solo (active == 0 -> Plugin_Stop).
        g_hRWWTick = CreateTimer(ROUGE_WAVE_TICK, T_RougeWaveTick, _, TIMER_REPEAT);
    }
    return true;
}

// Nucleo del arrastre (20 Hz). Mueve cada congelado hacia SU punto de
// convergencia con convergencia interpolada (llegan TODOS a la vez:
// los lejanos viajan más rápido = implosión). Trace brush-only por
// paso: una pared NO se traspasa, se liberan pegados al muro.
public Action T_RougeWaveTick(Handle timer)
{
    int active = 0;
    float now = GetEngineTime();

    for (int i = 0; i < ROUGE_WAVE_SLOTS; i++)
    {
        if (g_iRWWRef[i] == 0) continue;

        int ent = EntRefToEntIndex(g_iRWWRef[i]);
        if (ent <= 0 || !IsValidEntity(ent))
        {
            Rouge_WaveClearSlot(i);   // edict liberado/reciclado
            continue;
        }

        // v2.0 WF: RE-AFIRMAR el congelamiento cada tick (si algo
        // externo limpio el movetype o el flag, la entidad intentaria
        // reactivarse en pleno arrastre).
        if (GetEntityMoveType(ent) != MOVETYPE_NONE)
            SetEntityMoveType(ent, MOVETYPE_NONE);
        if ((GetEntityFlags(ent) & FL_FROZEN) == 0)
            SetEntityFlags(ent, GetEntityFlags(ent) | FL_FROZEN);

        // Murió en pleno arrastre -> liberar YA (patron
        // WitchFlight_CheckDead: el cadaver procede con el estado
        // normal del motor, sin NONE/FROZEN residuales).
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0)
        {
            Rouge_WaveRelease(i, ent);
            continue;
        }

        active++;

        // Tapa dura de seguridad: NUNCA un congelado eterno.
        if (now > g_fRWWEnd[i] + ROUGE_WAVE_MAX_DRAG)
        {
            Rouge_WaveRelease(i, ent);
            active--;
            continue;
        }

        // dt real protegido contra lag spikes
        float dt = now - g_fRWWLast[i];
        if (dt <= 0.0) dt = ROUGE_WAVE_TICK;
        if (dt > 0.25) dt = 0.25;
        g_fRWWLast[i] = now;

        float pos[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);

        // Vector hacia el punto de convergencia del cast
        float dir[3];
        MakeVectorFromPoints(pos, g_vRWWCenter[i], dir);
        float dist = GetVectorLength(dir);

        // Llegada: ya pegado al centro o arrastre expirado
        if (dist <= ROUGE_WAVE_MIN_DIST || now >= g_fRWWEnd[i])
        {
            Rouge_WaveRelease(i, ent);
            active--;
            continue;
        }

        // CONVERGENCIA INTERPOLADA: mover la fracción del tiempo
        // restante -> todos llegan juntos (los lejanos más rápido).
        float remaining = g_fRWWEnd[i] - now;
        if (remaining < 0.05) remaining = 0.05;
        float frac = dt / remaining;
        if (frac > 1.0) frac = 1.0;

        float step = dist * frac;
        if (step > dist - ROUGE_WAVE_MIN_DIST) step = dist - ROUGE_WAVE_MIN_DIST;
        if (step <= 0.0)
        {
            Rouge_WaveRelease(i, ent);
            active--;
            continue;
        }

        NormalizeVector(dir, dir);

        float next[3];
        next[0] = pos[0] + dir[0] * step;
        next[1] = pos[1] + dir[1] * step;
        next[2] = pos[2] + dir[2] * step;

        // ANTI-MURO: trace brush-only del paso. Si una pared bloquea
        // antes del paso completo, la entidad se suelta pegada al muro
        // (la onda no traspasa geometria solida).
        // v9.1: rayo levantado +2u en AMBOS extremos — el origen de un
        // común vive pegado al plano del piso y el roce con el brush del
        // suelo disparaba falsos "muro" (release instantaneo sin arrastre).
        float trStart[3], trEnd[3];
        trStart[0] = pos[0];  trStart[1] = pos[1];  trStart[2] = pos[2] + 2.0;
        trEnd[0]   = next[0]; trEnd[1]   = next[1]; trEnd[2]   = next[2] + 2.0;
        TR_TraceRay(trStart, trEnd, MASK_SOLID_BRUSHONLY, RayType_EndPoint);
        if (TR_DidHit() && TR_GetFraction() < 0.98)
        {
            float hit[3];
            TR_GetEndPosition(hit);
            hit[0] -= dir[0] * 5.0;
            hit[1] -= dir[1] * 5.0;
            hit[2] -= dir[2] * 5.0;
            TeleportEntity(ent, hit, NULL_VECTOR, NULL_VECTOR);
            Rouge_WaveRelease(i, ent);
            active--;
            continue;
        }

        TeleportEntity(ent, next, NULL_VECTOR, NULL_VECTOR);
    }

    if (active == 0)
    {
        g_hRWWTick = null;
        return Plugin_Stop;   // pool vacío: el timer muere solo (patron WF)
    }
    return Plugin_Continue;
}

// Liberación: restauración EXACTA (movetype original + FL_FROZEN
// retirado solo si lo pusimos nosotros + velocidad cero) ANTES del
// dano de llegada (patron WF v2.1 CheckDead: si el golpe mata, la
// muerte procede con el estado normal del motor). La witch llega
// ENFADADA (m_rage=1.0: su IA no pudo rampar el rage congelada, se
// reactiva persiguiendo - patron WitchFlight_Landing v2.6).
void Rouge_WaveRelease(int slot, int ent)
{
    if (ent > 0 && IsValidEntity(ent))
    {
        // Guard: solo devolver el movetype que pusimos nosotros
        if (GetEntityMoveType(ent) == MOVETYPE_NONE)
            SetEntityMoveType(ent, view_as<MoveType>(g_iRWWOrigMT[slot]));

        // El flag de IA se devuelve SOLO si el original no lo tenía
        // (un frozen de otro sistema/mapa no se pisa).
        if ((g_iRWWOrigFlags[slot] & FL_FROZEN) == 0)
            SetEntityFlags(ent, GetEntityFlags(ent) & ~FL_FROZEN);

        float zero[3];
        zero[0] = 0.0; zero[1] = 0.0; zero[2] = 0.0;
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, zero);

        // DANO DE LLEGADA (la parte "destructora" de la onda):
        // comunes x2 (revientan a los pies de Rouge), witch base.
        // Solo si sigue viva (la liberación por muerte no castiga).
        if (GetEntProp(ent, Prop_Data, "m_iHealth") > 0)
        {
            int attacker = g_iRWWAttacker[slot];
            if (attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker)) attacker = 0;

            float dmg = g_cvRougeWaveDamage.FloatValue;
            if (!g_bRWWWitch[slot]) dmg *= 2.0;
            OM_AbilityDamage(ent, attacker, dmg, DMG_CLUB);
        }

        // WITCH: reactivarla persiguiendo ("se levanta ENFADADA y
        // persigue, en vez de sentarse tranquila").
        if (g_bRWWWitch[slot] && GetEntProp(ent, Prop_Data, "m_iHealth") > 0)
        {
            SetEntPropFloat(ent, Prop_Send, "m_rage", 1.0);
        }
    }
    Rouge_WaveClearSlot(slot);
}

void Rouge_WaveClearSlot(int slot)
{
    g_iRWWRef[slot] = 0;
    g_iRWWOrigMT[slot] = 0;
    g_iRWWOrigFlags[slot] = 0;
    g_iRWWAttacker[slot] = 0;
    g_fRWWEnd[slot] = 0.0;
    g_fRWWLast[slot] = 0.0;
    g_bRWWWitch[slot] = false;
}

// OnMapStart/OnMapEnd/RoundStart: matar el tick y vaciar slots. Las
// entidades mueren con el mapa/la ronda: nadie queda congelado.
void Rouge_WaveResetPool()
{
    if (g_hRWWTick != null)
    {
        KillTimer(g_hRWWTick);
        g_hRWWTick = null;
    }
    for (int i = 0; i < ROUGE_WAVE_SLOTS; i++)
        Rouge_WaveClearSlot(i);
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// Limpieza al morir (llamado desde Sonic_ability_manager.sp -> Event_PlayerDeath)
public void Rouge_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != ROUGE_INDEX) return;

    // v10-OM: el avatar se mata ENTERO (cambio de personaje /
    // disconnect: NO ragdoll — no murió). El ragdoll sale en el
    // Event_PlayerDeath del hook de evento (la muerte de verdad).
    Rouge_KillAvatar(client);

    // v8.0: la Treasure Visión fue retirada; ya no hay glows rosas que
    // limpiar. Solo resetear el estado propio (planeo, destello de
    // evasión, cooldowns).
    Rouge_ResetState(client);
}

// v7.2: elimina TODOS los glows rosas de la Treasure Visión (infectados
// especiales y Witches). Solo toca glows de NUESTRO color: el amarillo de
// Tails (Animal Sense) y otros glows ajenos se respetan.
// (v8.0: Rouge_ClearTreasureGlows fue ELIMINADA junto con la
// Treasure Visión: la nueva pasiva Evasión Instintiva no pone glows.)

// =====================================================================
// =====================================================================
//  v10-OM — AVATAR ESPEJO ROUGE.MDL (el 6o avatar del suite: patron
//  Tails/Sonic/Amy/Metal/Knuckles v75). copia R (la que ven los DEMAS,
//  parentada o por TP según tails_avatar_tp) + copia L (la que ve el
//  dueño, contra-rotada con sus eye angles) + cuerpo del survivor
//  oculto (RENDER_NONE) + FSM 10 Hz con las secuencias del rouge.mdl
//  que usa el lua GMod + pulso de pausa en cada montaje + ADOPCION de
//  huerfanos (v72-OM: esta FSM es la ÚNICA creadora de props con sus
//  nombres — un prop así que ella no rastrea muere en el instante del
//  montaje) + ragdoll de muerte 15s + filtro anti-corpse 2s.
// =====================================================================
// =====================================================================

// tabla de secuencias (índices = ROUGE_ST_*) — los nombres EXACTOS del
// lua (anims.default + ShouldAlternate del redimated_om_pills_survivors_rouge)
static const char g_sRougeAnimSeq[ROUGE_ANIM_COUNT][20] = {
    "idle", "walk", "run", "jump", "fall",
    "latch",
    "flap", "SweepKick",
    "IdleLowHealth", "WalkLowHealth", "RunLowHealth",
    "DownedIdle", "DownedWalk",
    // v11.0: quieta = FlyIdle (hover), MOVIENDOSE = "glide" (la
    // secuencia nueva del rouge.mdl v15). "FlyRun" queda en la tabla
    // como FALLBACK del probe (modelo viejo sin "glide").
    "FlyIdle", "FlyRun"
};

// =====================================================================
// v11.0: PROBE DE LA SECUENCIA "glide" (receta Shadow v6.0 / Amy v92):
// SourcePawn no trae LookupSequence — se dispara SetAnimation(nombre)
// y se lee m_nSequence: si el indice CAMBIO, el nombre existe en el
// .mdl. El rouge.mdl v15 (compilado con Crowbar) trae "glide"; el
// viejo no. Se resuelve en CADA montaje del avatar R (barato: dos
// inputs extra dentro del MISMO frame del spawn — el cliente solo ve
// el idle final). Con el modelo viejo el FSM cae a "FlyRun" sola:
// nunca se congela el avatar volando.
// =====================================================================
void Rouge_ProbeGlideSeq(int av)
{
    g_bRougeGlideSeqOK = false;
    if (av <= 0 || !IsValidEntity(av)) return;
    if (!HasEntProp(av, Prop_Send, "m_nSequence")) return;

    int before = GetEntProp(av, Prop_Send, "m_nSequence");
    SetVariantString("glide");
    AcceptEntityInput(av, "SetAnimation");
    int after = GetEntProp(av, Prop_Send, "m_nSequence");

    g_bRougeGlideSeqOK = (after != before);

    // devolver el avatar al idle (estado limpio para la FSM)
    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");
}

// v11.0: la secuencia de un estado — FLYRUN usa "glide" cuando el
// probe lo confirmo (la anim del planeo nueva); si no, "FlyRun"
void Rouge_SeqFor(int state, char out[20])
{
    strcopy(out, 20, g_sRougeAnimSeq[state]);
    if (state == ROUGE_ST_FLYRUN && g_bRougeGlideSeqOK)
        strcopy(out, 20, "glide");
}

int Rouge_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
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
    g_fRougeBodyYaw[client]  = ang[1];
    g_fRougeYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fRougeBodyYaw[client], loc);

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
        g_fRougeSmLoc[client][k]  = loc[k];
        g_fRougeSmLocL[client][k] = loc[k];
    }
    g_bRougeSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// v72-OM (adopción): un prop con NUESTRO nombre que esta FSM no rastrea
// es un huerfano por definición — muere en el instante del montaje.
bool Rouge_IsMyAvatarRef(int ref)
{
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iRougeAvatar[i] == ref) return true;
        if (g_iRougeAvatarL[i] == ref) return true;
    }
    return false;
}

void Rouge_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "rouge_avatar_om", "rouge_avatar_om_l" };
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
                if (Rouge_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
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
        PrintToServer("[Rouge v10-OM] Adopción del montaje: %d huerfano(s) del avatar eliminado(s).", ng);
}

// Monta el avatar completo (R + L + cuerpo oculto). pulsePause SOLO para
// montajes de ciclo de vida (spawn/selección/reparación tardia de la FSM).
void Rouge_CreateAvatar(int client, bool pulsePause = true)
{
    if (!g_bRougeModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;

    // v72-OM (reemplazo limpio): si este cliente ya tenía un R o L vivo
    // (montaje doble por orden raro de eventos), muere AQUÍ enterito.
    {
        int oldR = EntRefToEntIndex(g_iRougeAvatar[client]);
        if (g_iRougeAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Rouge_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iRougeAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iRougeAvatarL[client]);
        if (g_iRougeAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Rouge_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iRougeAvatarL[client] = 0;
    }

    // v72-OM: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje.
    Rouge_KillGhostAvatarProps();

    int av = Rouge_CreateAvatarProp(client, ROUGE_OM_MODEL, ROUGE_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");
    Rouge_ProbeGlideSeq(av);          // v11.0: ¿el .mdl trae "glide"? (deja idle)
    g_iRougeAnimState[client] = 0;

    SDKHook(av, SDKHook_SetTransmit, Rouge_TransmitAvatarR);

    g_iRougeAvatarL[client] = 0;
    Rouge_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iRougeBodyRender[client] = view_as<int>(curMode);
    else if (g_iRougeBodyRender[client] == -1)
        g_iRougeBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    g_iRougeAvatar[client] = EntIndexToEntRef(av);

    // per-tick: angulos locales (contra-rotación del parent)
    SDKHook(client, SDKHook_PostThink, Rouge_AvatarFollow);

    // PULSO DE PAUSA en cada montaje de ciclo de vida (la misma infra
    // sv_pausable del suite; convar tails_pausefix manda para TODOS los
    // avatares — es UN solo sistema, 6o avatar del suite)
    if (pulsePause)
        Tails_PauseFix_Trigger(client);
}

void Rouge_CreateAvatarL(int client)
{
    if (!g_bRougeModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iRougeAvatar[client] == 0) return;

    int av = Rouge_CreateAvatarProp(client, ROUGE_OM_MODEL, ROUGE_AVATAR_NAME_L);
    if (av == 0) return;

    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Rouge_TransmitAvatarL);

    g_iRougeAvatarL[client] = EntIndexToEntRef(av);
}

void Rouge_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iRougeAvatarL[client]);
    if (g_iRougeAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Rouge_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iRougeAvatarL[client] = 0;
}

// Mata las copias R+L y devuelve el cuerpo. SIN desenganchar el follow
// (lo hace Rouge_KillAvatar).
void Rouge_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    Rouge_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iRougeAvatar[client]);
    if (g_iRougeAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Rouge_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iRougeAvatar[client] = 0;
    g_iRougeAnimState[client] = -1;

    // devolver el cuerpo (specate/revive/cambio de personaje)
    if (IsClientInGame(client) && g_iRougeBodyRender[client] != -1)
    {
        SetEntityRenderMode(client, view_as<RenderMode>(g_iRougeBodyRender[client]));
        g_iRougeBodyRender[client] = -1;
        SetEntityRenderColor(client, 255, 255, 255, 255);
    }
}

void Rouge_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Rouge_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Rouge_AvatarFollow);
}

// Transmit filters (patron Sonic/Metal): la R no la ve su dueño (tiene
// su L), la L la ve SOLO su dueño.
public Action Rouge_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iRougeAvatar[i] != 0 && EntRefToEntIndex(g_iRougeAvatar[i]) == entity)
        {
            if (client == i && g_iRougeAvatarL[i] != 0
                && EntRefToEntIndex(g_iRougeAvatarL[i]) > 0)
                return Plugin_Handled;   // el dueño tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

public Action Rouge_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iRougeAvatarL[i] != 0 && EntRefToEntIndex(g_iRougeAvatarL[i]) == entity)
        {
            if (client == i) return Plugin_Continue;   // el dueño si
            return Plugin_Handled;                     // nadie más
        }
    }
    return Plugin_Continue;
}

// FOLLOW PER-TICK (lecciones Tails/Sonic/Metal/Knuckles: yaw suave con
// deadband 3 grados, contra-rotación amortiguada, reloj vivo, copia L
// contra los eye angles del dueño; la R por TP en modo tp). Agarrada a
// la pared: el yaw objetivo es la NORMAL de la pared (mirar afuera).
public void Rouge_AvatarFollow(int client)
{
    if (g_iRougeAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Rouge_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    // ---- yaw objetivo: dirección REAL del movimiento ----
    float yawObj = g_fRougeBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fRougeBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    // agarrada a la pared: mira HACIA AFUERA (la normal, l.652 del lua)
    if (g_bRougeLatched[client]) yawObj = g_fRougeLatchYaw[client];

    // ---- giro suave hacia el objetivo (~900 grados/s) ----
    float now = GetEngineTime();
    float dt  = now - g_fRougeYawLastT[client];
    g_fRougeYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fRougeBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fRougeBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bRougeSmSnap[client];
    GetClientAbsAngles(client, par);
    float yawPuppet = g_fRougeBodyYaw[client];

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iRougeAvatar[client]);
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
            loc[1] = Tails_UnwrapYaw(g_fRougeSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fRougeSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fRougeSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }

    // ---- copia L: contra-rotada contra los EYE del dueño ----
    if (g_iRougeAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iRougeAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3], locL[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], yawPuppet, locL);
            locL[1] = Tails_UnwrapYaw(g_fRougeSmLocL[client][1], locL[1]);
            Tails_ExpDamp(locL, g_fRougeSmLocL[client], 0.05, dt, snap);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fRougeSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
    g_bRougeSmSnap[client] = false;
}

// FSM de 10 Hz: montaje / auto-reparación / muerte del avatar (patron
// T_KnuxAvatarThink / T_MetalAvatarThink)
public Action T_RougeAvatarThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Rouge_KillAvatar(i); continue; }

        bool esRougeViva = (g_iPlayerCharIdx[i] == ROUGE_INDEX
                           && IsPlayerAlive(i) && GetClientTeam(i) == 2);

        // incap = fuera (defensa anti terceros)
        if (esRougeViva && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            esRougeViva = false;

        // ---- montaje ----
        if (g_iRougeAvatar[i] == 0)
        {
            if (esRougeViva && g_cvRougeAvatar != null && g_cvRougeAvatar.BoolValue
                && g_bRougeModelOK)
            {
                Rouge_CreateAvatar(i);
            }
            continue;
        }

        // quitar avatar si dejó de ser una Rouge survivor viva de pie
        if (!esRougeViva)
        {
            Rouge_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iRougeAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iRougeAvatar[i] = 0;
            g_iRougeAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (el motor lo resetea al
        // cambiar de capítulo/rescue: fix Tails v5.4)
        if (g_iRougeBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparación de la copia L (montaje tardio: pulso también)
        if (g_iRougeAvatarL[i] == 0 && g_iRougeAvatar[i] != 0)
        {
            Rouge_CreateAvatarL(i);
            if (g_iRougeAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // ---- FSM de animación ----
        av = EntRefToEntIndex(g_iRougeAvatar[i]);
        if (g_iRougeAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Rouge_AvatarUpdate(i, av, now);
    }
    return Plugin_Continue;
}

// =====================================================================
// FSM DE ANIMACION — prioridades del lua GMod (ShouldAlternate):
//   incap (DownedIdle/DownedWalk) -> agarrada de pared (latch) ->
//   barrido en curso (SweepKick, lock) -> aire (jump subiendo / fall
//   cayendo — el planeo del suite TAMBIÉN es "fall": glide="fall") ->
//   suelo (idle/walk/run con variantes lowhealth de HP<=60)
// =====================================================================
void Rouge_AvatarUpdate(int client, int av, float now)
{
    // lock de one-shot en curso (Flap/SweepKick/jump de pared)
    if (now < g_fRougeAnimLock[client]) return;

    int state;
    float rate = 1.0;

    if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
    {
        // DownedIdle/DownedWalk del lua (Survivor_Downed_OM)
        state = (Rouge_Speed2D(client) > 40.0) ? ROUGE_ST_DOWNED_WALK : ROUGE_ST_DOWNED_IDLE;
    }
    else if (g_bRougeLatched[client])
    {
        // agarrada de pared (ShouldAlternate -> 'latch')
        state = ROUGE_ST_LATCH;
    }
    else if (g_iRougeKickPhase[client] == ROUGE_KICK_DASH
             || g_iRougeKickPhase[client] == ROUGE_KICK_CHARGING)
    {
        // la embestida manda el frame (SweepKick del lua)
        state = ROUGE_ST_KICK;
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // v11.0: MODO VUELO (planeo estilo Knuckles — tap de SPACE lo
        // enciende y SE QUEDA ON — o freno con SHIFT): QUIETA en el
        // aire = FlyIdle, MOVIENDOSE = "glide" (la secuencia nueva
        // del rouge.mdl v15; el probe cae a FlyRun con el modelo
        // viejo). Fuera del modo de vuelo el aire sigue siendo jump
        // (sube) / fall (cae).
        if (g_bRougeGliding[client] || g_bRougeBraking[client])
        {
            state = (Rouge_Speed2D(client) > 40.0) ? ROUGE_ST_FLYRUN : ROUGE_ST_FLYIDLE;
        }
        else
        {
            // AIRE: sube = jump; cae = fall (Y el planeo es "fall" en el
            // lua: glide="fall") — con la ventana del jump sin cortarse
            float vel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            if (vel[2] > 40.0)
            {
                state = ROUGE_ST_JUMP;
            }
            else
            {
                bool jumpLive = false;
                if (g_iRougeAnimState[client] == ROUGE_ST_JUMP)
                {
                    float jt = now - g_fRougeJumpStart[client];
                    if (jt < 0.5)      jumpLive = true;
                    else if (jt < 1.5 && !Rouge_JumpAnimDone(av)) jumpLive = true;
                }
                state = jumpLive ? ROUGE_ST_JUMP : ROUGE_ST_FALL;
            }
        }
    }
    else if (g_iRougeAnimState[client] == ROUGE_ST_JUMP && !Rouge_JumpAnimDone(av)
             && now - g_fRougeJumpStart[client] < 0.5)
    {
        // FL_ONGROUND parpadea al saltar rozando escalones
        state = ROUGE_ST_JUMP;
    }
    else
    {
        // SUELO: idle/walk/run (con lowhealth <= 60 del lua)
        bool low = (GetClientHealth(client) <= 60);
        float s = Rouge_Speed2D(client);
        if (s < 40.0)
            state = low ? ROUGE_ST_IDLE_LOW : ROUGE_ST_IDLE;
        else if (s < 150.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = low ? ROUGE_ST_WALK_LOW : ROUGE_ST_WALK;
            rate = 1.0;   // rate 1 constante del framework GMod
        }
        else
        {
            state = low ? ROUGE_ST_RUN_LOW : ROUGE_ST_RUN;
            rate = 1.32 * (s / 450.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6)  rate = 3.6;
        }
    }

    if (state != g_iRougeAnimState[client])
    {
        // el t0 del jump para su ventana (receta Sonic/Metal/Knuckles)
        if (state == ROUGE_ST_JUMP) g_fRougeJumpStart[client] = now;
        char seq[20];
        Rouge_SeqFor(state, seq);   // v11.0: FLYRUN -> "glide" (o FlyRun)
        SetVariantString(seq);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iRougeAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iRougeAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                // el variant es de UN SOLO USO — re-armarlo
                SetVariantString(seq);
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iRougeAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iRougeAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iRougeAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

float Rouge_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// el one-shot del jump termino? (m_flCycle del prop — la misma sonda
// del Sonic_JumpAnimDone / Knux_JumpAnimDone)
bool Rouge_JumpAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return true;
}

// ONE-SHOT de habilidad sobre las DOS copias (los PillAnim del lua:
// SweepKick/Flap/Jump2). Bloquea la FSM mientras corre.
void Rouge_AvatarOneShot(int client, int stIdx, float lock)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iRougeAvatar[client] == 0) return;

    int av = EntRefToEntIndex(g_iRougeAvatar[client]);
    if (av > 0 && IsValidEntity(av))
    {
        SetVariantString(g_sRougeAnimSeq[stIdx]);
        AcceptEntityInput(av, "SetAnimation");
    }
    if (g_iRougeAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iRougeAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetVariantString(g_sRougeAnimSeq[stIdx]);
            AcceptEntityInput(avL, "SetAnimation");
        }
    }
    g_iRougeAnimState[client] = stIdx;
    g_fRougeAnimLock[client] = GetEngineTime() + lock;
}

// =====================================================================
// TINTES DEL AVATAR (misma rampa simétrica del UI GMod: 0.25s con fade
// 0.125 por lado). Aplica a las DOS copias; el cuerpo oculto no se toca.
// =====================================================================
void Rouge_AvatarSetColor(int client, int r, int g, int b, int a)
{
    int av = EntRefToEntIndex(g_iRougeAvatar[client]);
    if (g_iRougeAvatar[client] != 0 && av > 0 && IsValidEntity(av))
        SetEntityRenderColor(av, r, g, b, a);
    int avL = EntRefToEntIndex(g_iRougeAvatarL[client]);
    if (g_iRougeAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
        SetEntityRenderColor(avL, r, g, b, a);
}

void Rouge_AvatarTintReset(int client)
{
    Rouge_AvatarSetColor(client, 255, 255, 255, 255);
}

// arranca un pulso de color (0.25s con fade simétrico)
void Rouge_AvatarTintPulse(int client, int r, int g, int b)
{
    if (g_iRougeAvatar[client] == 0) return;
    g_iRougeTintR[client] = r;
    g_iRougeTintG[client] = g;
    g_iRougeTintB[client] = b;
    g_fRougeTintEnd[client] = GetEngineTime() + ROUGE_TINT_DUR;
}

// animador por frame (lo invoca el nucleo del PreThink): pulso activo
// con la rampa simétrica; sin pulso, el CONTRAGOLPE tiñe magenta
// (255,120,220); sin nada, color base.
void Rouge_TintThink(int client)
{
    if (g_iRougeAvatar[client] == 0) return;
    float now = GetEngineTime();

    if (g_fRougeTintEnd[client] > 0.0)
    {
        float start = g_fRougeTintEnd[client] - ROUGE_TINT_DUR;
        float a;
        if (now <= start + ROUGE_TINT_FADE)
            a = (now - start) / ROUGE_TINT_FADE;
        else if (now >= g_fRougeTintEnd[client] - ROUGE_TINT_FADE)
            a = (g_fRougeTintEnd[client] - now) / ROUGE_TINT_FADE;
        else
            a = 1.0;
        if (a < 0.0) a = 0.0;
        if (a > 1.0) a = 1.0;

        Rouge_AvatarSetColor(client, g_iRougeTintR[client], g_iRougeTintG[client],
                            g_iRougeTintB[client], RoundToNearest(255.0 * a));

        if (now >= g_fRougeTintEnd[client]) g_fRougeTintEnd[client] = 0.0;
        return;
    }

    if (g_bRougeCountering[client])
        Rouge_AvatarSetColor(client, 255, 120, 220, 255);
    else
        Rouge_AvatarTintReset(client);
}

// =====================================================================
// MUERTE DEL AVATAR — ragdoll rouge.mdl + filtro anti-corpse
// (receta Knuckles v75 / Metal v5.0 / Sonic v3.76.2)
// =====================================================================
void Rouge_SpawnDeathRagdoll(int client)
{
    if (!g_bRougeModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", ROUGE_OM_MODEL);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    CreateTimer(15.0, T_RougeDeathRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_RougeDeathRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Filtro anti-ragdoll (patron Sonic/Metal/Knuckles — enrutado por el
// OnEntityCreated central de este mismo archivo)
public void Rouge_CheckDeathRagdoll(any ref)
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
        if (g_fRougeDeathHideUntil[i] == 0.0 || now >= g_fRougeDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_vRougeDeathOrigin[i]) < 200.0)
        {
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}
