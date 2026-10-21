/*
 * ======================================================
 *  [MODULO] Metal Sonic - The Ultimate Machine (v6.0-OM - LA TORMENTA ELÉCTRICA DEL DESTRUCTIVE)
 *
 *  v6.0-OM (suite 3.77.74 — pedido del owner 2026-10-15: "aparte del
 *   efecto que ya tiene se le añadira los efectos: mientras lleva a la
 *   victima efx_arc_new1, efx_arc_new1_XXL y efx_arc_new1_XXL2; cuando
 *   este impacte a la pared con el enemigo generara el efecto
 *   electrical_arc_01_system; y cuando metal empiece a moverse con su
 *   destructive en su Torso nasera el efecto flame_blue — y ya sabes
 *   el efecto terminara cuando metal se detenga o tecnicamente
 *   estrelle a la victima hacia la pared"). LA CAPA DE PARTICULAS DEL
 *   DESTRUCTIVE CHARGE:
 *     [F1] flame_blue PARENTADA al torso de Metal (z +40) desde que
 *          DESPEGA la embestida (transición WINDUP->DASH = "cuando
 *          empiece a moverse") hasta que Metal SE DETIENE: estampado
 *          contra pared, rebote sin infectado, drop por cap de dano
 *          (especial y witch), timeout del reloj, muerte/desconexion/
 *          mapa. Si el arrastrado MUERE en sus manos la embestida
 *          CONTINUA = la llama SIGUE (regla v5.8).
 *     [F2] efx_arc_new1 + efx_arc_new1_XXL + efx_arc_new1_XXL2, las
 *          TRES PARENTADAS a la VICTIMA (cliente especial o witch)
 *          durante TODO el arrastre; mueren en la suelta UNIVERSAL
 *          (Metal_ReleaseGrabbed: drop, cancel, muerte del objetivo,
 *          atasco, timeout, slam-end) y al ARRANCAR el estampado.
 *     [F3] electrical_arc_01_system one-shot en el punto de impacto
 *          con la pared (hitPos + normal x 12, mirando HACIA FUERA
 *          del muro) al iniciar el WALL_SLAM — "el estrelle a la
 *          victima hacia la pared".
 *   Receta: info_particle_system + auto-kill por OnUser1 (cero
 *   handles vivos) — el MISMO patron del flame_blue del airstrike y
 *   del ChampFX_Particle del pet_fusion de ESTE server (particulas
 *   ya montadas y comprobadas) y de la capa Blaze_FX v2.2 del suite;
 *   nombres registrados en la tabla ParticleEffectNames (no-op para
 *   las stock). Kill-switch metalom_fx_charge 1 (0 = v5.9 exacto,
 *   cero entidades nuevas). CERO cambios de lógica de la FSM: mismos
 *   estados, mismos timings, mismos daños.
 *
 *  v5.9-OM (suite 3.77.62 — reporte del owner 2026-10-13: "cuando la
 *   habilidad del dash que tiene en la 1 habilidad termina el sonido
 *   del deslizamiento sigue sonando no se detiene (esto no ocurre si
 *   este impacta contra algo)"). FIX DEL LOOP ELÉCTRICO: el stop ya
 *   corria en TODOS los caminos de fin de carga (CancelCharge / wall
 *   slam / rebote / drop por cap / muerte / reset), pero el WATCHDOG
 *   re-emitia el metalchargeloopsound.wav cada 3s "a ciegas" — y un
 *   wav con cue de loop horneada re-emitido sobre el mismo canal NO
 *   siempre se reemplaza en el cliente: se APILAN copias y cada resto
 *   solo muere con su propio SND_STOP. Por eso con impacto temprano
 *   (0-1 latidos: una instancia) el stop final mataba el sonido, y al
 *   agotarse los 8s (2-3 latidos acumulados) quedaba loop zombie
 *   sonando para siempre. TRES capas de fix:
 *     (1) WATCHDOG STOP+EMIT: cada latido PRIMERO corta la instancia
 *         viva (SND_STOP) y DESPUÉS emite la nueva — el canal siempre
 *         tiene EXACTAMENTE una instancia;
 *     (2) ARRANQUE STOP+EMIT: la transición WINDUP->DASH limpia
 *         cualquier resto de una carga anterior antes de emitir;
 *         el fallback electric_loop.wav pasa de SNDCHAN_AUTO (0 = el
 *         MOTOR elige canal: el stop sobre 0 podía no apuntar al canal
 *         elegido) a SNDCHAN_STATIC explícito;
 *     (3) DOBLE GOLPE DIFERIDO: Metal_StopLoopSound re-stoppa todo a
 *         los 0.25s (timer T_MetalLoopRestop con guard de estado — no
 *         toca una carga nueva) + refuerzo per-cliente con el flag
 *         SND_STOP explícito. SND_STOP sobre un sonido que no suena
 *         es un no-op silencioso: reintentar es gratis.
 *
 *  v5.8-OM (suite 3.77.60 — pedido literal del owner 2026-10-13: "Buff a
 *   metal sonic: si metal durante el dash mata al objetivo que tiene
 *   llevándose el dash no se detendra. Aclaro que el continuar solo
 *   sucede si el SI muere en sus manos; si ya lo estrello contra la
 *   pared el efecto no aplica (obviamente, porque en la pared pasa a
 *   modo de embiste final)"). NUEVA FUNCION Metal_DragTargetDied:
 *   cuando el ARRASTRADO (especial o witch) muere o desaparece a
 *   mitad de arrastre, la embestida YA NO SE CANCELA — vuelve al
 *   ESTADO DASH puro (misma velocidad 750, mismo grupo DEBRIS, mismo
 *   FOV/loop/lagged, mismo reloj de seguridad) y puede ATRAPAR UN
 *   OBJETIVO NUEVO, rebotar contra pared o terminar sola al agotar
 *   el tiempo. El WALL_SLAM (estampado contra la pared = modo embiste
 *   final) queda INTACTO: ahi la secuencia de 3 golpes sigue su curso
 *   como siempre — el buff solo corre durante el ARRASTRE.
 *
 *  v5.7.1-OM (suite 3.77.51): el +25% de dano de la embestida quedó
 *   INCOMPLETO en la fusión del v5.7 — solo entraron atrape/tick/
 *   estampado; el GOLPE DE PARED (wall slam, 3 hits por embestida
 *   contra la pared) siguio en los valores v4.2. COMPLETADO AQUÍ:
 *   METAL_WALL_SLAM_DMG 3.25 -> 4.0625 y su piso de misericordia LMS
 *   1.25 -> 1.5625 (mismo x1.25; 3 hits = 12.1875 vs 9.75). Todo lo
 *   demas del v5.7 intacto.
 *
 *  v5.7-OM (suite 3.77.50 — pedido literal del owner 2026-10-11: "Metal
 *   aumento de dano a su embestida 25% reducción de enfriamiento de
 *   25%"). APLICADO ENCIMA de los valores actuales (ojo: la v5.5 ya había
 *   subido el dano +55% y la v5.2 bajado los cd -30% — esto se SUMA):
 *   (1) DANO DE LA EMBESTIDA +25% (solo lo que INFLIGE al enemigo):
 *       atrape 6.2 -> 7.75, tick de arrastre al enemigo 6.2 -> 7.75,
 *       golpe de estampado 15.1 -> 18.875. El AUTO-DANO (coste propio)
 *       queda INTACTO a propósito.
 *   (2) ENFRIAMIENTO -25%: embestida 17.5 -> 13.125s y su cancelado
 *       8.75 -> 6.5625s. (Si se prefiere -25% contando desde el 25
 *       original del GMod = 18.75, ya estaba POR DEBAJO desde la v5.2.)
 *
 *  v5.6-OM - ADOPCION DEL AVATAR EN EL MONTAJE + FIN DEL BARRIDO EN CALIENTE
 *  v5.6 (suite 3.77.40 — orden del owner 2026-10-10: "tu barrido de
 *  avatares está haciendo reiniciar mi avatar a cada rato... BUSCA
 *  OTRA MANERA"): el avatar de Metal ya NUNCA es barrido en caliente.
 *  (1) REEMPLAZO LIMPIO en Metal_CreateAvatar: un montaje doble mata
 *  al R/L viejo en vez de dejarlo huerfano; (2) ADOPCION: todo prop
 *  "metal_avatar_om"/"_l"/"metalom_avatar" que esta FSM no rastrea
 *  muere en el instante del montaje. El único barrido restante del
 *  suite corre en el arranque del mapa (cuando no existe ningún
 *  avatar vivo). v5.5 (suite 3.77.38 — reporte del owner 2026-10-10):
 *   (1) DANO DE LA EMBESTIDA +55% ("si vez el dano el esta muy por
 *       debajo de otros supervivientes"): catch 4.0 -> 6.2, tick de
 *       arrastre 4.0 -> 6.2, golpe de estampado 9.75 -> 15.1. El
 *       AUTO-DANO de Metal NO se toca (sigue siendo el costo).
 *   (2) GOLPE DE 0 DE DANO REAL NO INTERRUMPE NADA ("la embestida y
 *       la reparación ya no se interrumpe si recibe un golpe que sea
 *       = a 0 de dano, o sea si no recibe dano real no es interrumpido,
 *       ninguna de las 2"): guard damage<=0 en Metal_OnTakeDamage
 *       ANTES de los caminos de interrupción.
 *   (3) BOOMER FUSE ("si detecta que algún golpe lo matara le colocara
 *       una especie de contador; cuando el stun termine este estallara
 *       solo, evitando que el boomer le explote encima a metal"): el
 *       golpe LETAL de la embestida NO se aplica — se marca la mecha
 *       (OM_BoomerFuseMark STUN, modulo OM_Stun v2.1) y el boomer
 *       estalla al terminar SU stun, ya lejos de Metal.
 *   (4) WITCH DE PARED ("no se le aplica el freeze cuando es estampada
 *       en la pared en el tiempo correspondiente = que como se hacia
 *       con los SI"): al TERMINAR el estampado la witch YA NO se suelta
 *       descongelada al instante — queda ESTATUA contra la pared
 *       METAL_WITCH_WALLSTUN_KEEP (2.0s = el stun por golpe de los SI)
 *       y el release completo (movetype + flag + estrellas) llega con
 *       un timer autonomo que captura SU estado en el DataPack.
 *  v5.4 (suite 3.77.29 — fix del frozen de la witch, 2026-10-09):
 *   EL REPORTE: "la witch no se congela (no se le aplica el freeze para
 *   Nextbot)... el stun normal sirve pero el frozen no está sirviendo
 *   para la witch... Tails y Amy aplican el frozen incluso Sonic pero
 *   Metal no". Causa raíz: el v5.3 congelaba a la witch SOLO con
 *   MOVETYPE_NONE (la FÍSICA quieta) — su IA seguía VIVA: segia
 *   animándose y podía zarpear en el sitio. El congelado de verdad del
 *   suite para la witch (el "freeze para nextbot") son DOS capas:
 *   FL_FROZEN apaga su IA (ESTATUA — receta Witch_Flight/Rouge) +
 *   MOVETYPE_NONE. Tails (rayo), Amy (martillo) y Sonic (final del
 *   spin) lo aplican con Sonic_WitchStun; Metal no lo llamaba nunca.
 *   EL FIX:
 *   (1) Metal_WitchFreeze(witch): FL_FROZEN inmediato y propio (capa
 *       que funciona SIEMPRE, sin depender de ningún cvar) +
 *       Sonic_WitchStun (estrellas + el watch que re-afirma el flag
 *       cada 0.1s — la MISMA función de Tails/Amy/Sonic).
 *   (2) Catch, cada tick del arrastre y cada golpe del estampado la
 *       re-afirman (el dano o el motor pueden tirar el flag a mitad).
 *   (3) Suelta: se libera el slot de Sonic y se quita SOLO el flag que
 *       pusimos nosotros (si venía congelada por otro stun, queda como
 *       estaba) — sin esto el fling de salida rebotaba contra la estatua.
 *   (4) Explosión de muerte: la witch del radio recibe el paquete
 *       completo (estatua 5.5s + ragdoll volador — receta Amy: Sonic_
 *       WitchStun + Sonic_SpawnWitchRagdoll).
 *   (5) hadFrozen capturado UNA VEZ en el catch: un re-afirmo con el
 *       flag ya puesto JAMÁS "cree" que la witch venía congelada.
 *
 *  v5.3 (suite 3.77.28 — tercera ronda de la revisión, 5 puntos):
 *   (1) ANTI-CONTROL DE VERDAD (fix critico): la inmunidad de la v5.2
 *       estaba cableada en el manager a 6 FORWARDS FANTASMA que
 *       left4dhooks NUNCA invoca (L4D_OnTongueGrab_Pre, L4D_OnPouncedOn-
 *       Survivor_Pre, L4D_OnJockeyRide_Pre, L4D_OnChargerImpact_Pre,
 *       L4D_OnFling, L4D_OnStagger — compilan pero jamás se llaman: por
 *       eso "un smoker me pudo agarrar con la lengua durante la carga").
 *       Renombrados a los REALES del left4dhooks.inc:
 *         L4D_OnGrabWithTongue(victim, attacker)      — lengua del smoker
 *         L4D_OnPouncedOnSurvivor(victim, attacker)   — ensarte del hunter
 *         L4D2_OnJockeyRide(victim, attacker)         — monta del jockey
 *         L4D2_OnStartCarryingVictim(victim, attacker) — carga del charger
 *         L4D2_OnPlayerFling(client, attacker, dir)  — fling
 *         L4D2_OnStagger(client, source)             — stagger
 *       (TankClaw_OnPlayerHit_Pre y OnKnockedDown ya eran reales). DE
 *       PASO revive las contras de Amy/Knuckles/Sonic que vivian muertas
 *       en los mismos forwards fantasma. El pre-hook devuelve Handled =
 *       el agarre NUNCA EMPIEZA (no hay ni un frame de lengua).
 *   (2) AVALANCHA DE COMMONS: la embestida MATA a los comunes que toca
 *       (SDKHooks_TakeDamage 9999 DMG_CLUB, escaneo de entidades
 *       "infected" en radio 120u cada 0.1s durante DASH y DRAGGING — el
 *       v5.2 solo miraba CLIENTS infectados y los comunes eran puro
 *       obstaculo físico).
 *   (3) WITCH EMBESTIBLE: la witch también es objetivo (FindEntityBy-
 *       Classname "witch" en el radio de agarre): catch con congelado
 *       (MOVETYPE_NONE) + grupo DEBRIS en ELLA (su cuerpo no tapona
 *       pasillos estrechos mientras la arrastra), arrastre con teleport
 *       a 85u, dano por tick como un especial, WALL SLAM completo (3
 *       golpes de 9.75 contra la pared) y suelta con fling.
 *   (4) ANTI-ATASCO EN PASILLOS ANGOSTOS: (a) el ARRASTRADO también va a
 *       DEBRIS durante el arrastre (su capsula deja de pelear contra la
 *       de Metal — la fuente del "sigo atascándome contra los enemigos
 *       que envisto"), se restaura al soltar por TODOS los caminos;
 *       (b) cuando el watchdog detecta atasco con objetivo vivo, el
 *       objetivo se TELETRANSPORTA DETRÁS de Metal (90u contra la
 *       dirección de la marcha) antes de liberar — el pasillo queda
 *       despejado al instante; (c) la suelta por cap de dano flinga al
 *       objetivo hacia delante (350 + 250z) para no dejarlo pegado.
 *   (5) VIDA MÁXIMA 175 AL ESCOGERLO: m_iMaxHealth = 175 al escoger a
 *       Metal y en cada spawn ("si se escoige... de 175 y no 100") +
 *       re-afirmado cada 1s (el motor re-normaliza a 100 en algunos
 *       caminos) — el BOTIQUIN del juego cura hacia el máximo REAL, así
 *       que ya NO SE PIERDE la vida adicional al curarse (el v5.2 la
 *       curaba por encima de 100 permanente y el medkit la recortaba
 *       hacia el máximo 100 vanilla). Self Repair: tope 150 -> 175.
 *       Al cambiar de personaje/morir: max 100 + clamp (nadie hereda).
 *
 *  v5.2 (suite 3.77.27 — revisión del owner 8.5/10, ajustes 2 a 10,
 *   "Ok esta bn por el momento... Ahora hace falta algo ah si...", 9
 *   puntos en un solo pedido):
 *   (1) ATASCOS: watchdog en DASH y DRAGGING — si la embestida DEBERÍA
 *       estar empujando (750 uu/s) y Metal lleva METAL_STUCK_TIME sin
 *       superar 80 uu/s (enemigos enormes que taponan, geometria que
 *       el trace de pared no ve como muro), la carga se LIBERA limpia
 *       (fin natural con frenado suave) en vez de quedarse pegado
 *       hasta agotar los 8s. El catch ahora también STAGGERA al
 *       oponente (punto 7): un tank/charger dejara de presionar en el
 *       instante del contacto.
 *   (2) SONIDOS MÁS FUERTES: TODOS los sonidos de habilidad suben al
 *       soundLevel 87 del AdvancedPillSound del lua (el mod emite a
 *       87 — el port v5.1 usaba el default 75 del EmitSoundToAll, por
 *       eso se oian flojos). Loop del dash incluido (watchdog y
 *       arranque).
 *   (3) COOLDOWNS -30% (pedido literal): embestida 25 -> 17.5s (y su
 *       cancel 12.5 -> 8.75), Overdrive 30 -> 21s, Self Repair
 *       24 -> 16.8s.
 *   (4) OVERDRIVE SIN INMOVILIZAR: fuera el sobrecalentamiento con
 *       MOVETYPE_NONE 1.5s al terminar ("ya no inmovilizara a metal")
 *       — el buff simplemente expira y sigue corriendo.
 *   (5) ANIMaciones: SALTO con ventana del one-shot (receta Sonic: el
 *       "jump" del metal.mdl ya no se corta a la primera — vive hasta
 *       0.5s o hasta que el ciclo del modelo termine de verdad) + el
 *       WALK vuelve al rate 1.0 CONSTANTE del GMod (Metal NO define
 *       animrates en su lua — noodles_om_pills_survivors2.lua trae los
 *       animrates de Tails (walk 1.8/run 1.1); metal no -> rate 1,
 *       noodles_om_pills_base.lua l.936-944. El v5.0 jugaba el walk a
 *       1.8*(s/85) = piernas muy rápidas "a comparación de los demas")
 *       + INMUNIDAD ANTI-CONTROL TOTAL durante TODA la embestida
 *       (windup->rebote): Metal_ControlImmune() en los 8 forwards del
 *       manager (tank puño/roca, fling, stagger, pounce, jockey ride,
 *       charger, tongue) — "stagger de ningún tipo ni agarrado ni
 *       nada".
 *   (6) SELF REPAIR CON SOPORTE: si hay un Tails o un Eggman VIVO a
 *       menos de 250u (el radio del tails_heal_boost del suite), el
 *       tick se acelera x2 (cada 1s en vez de 2s) — "la reparación
 *       esta heredada a curarse más rápido si está con eggman o tails".
 *   (7) EMBESTIDA LIBERA EL CONTROL AGARRADO (bug del jockey montado:
 *       "metal se ha llevado a un jokey de un survivor y este siguio
 *       montado aun si no estaba su cuerpo"): el catch STAGGERA al
 *       oponente (el interrupt vanilla) y si el oponente tenía a
 *       alguien agarrado, PinRelease_Cleanse lo libera POR EL CAMINO
 *       DEL MOTOR (L4D2_Jockey_EndRide etc. — jockey desmontado ya, no
 *       "montado fantasma") + el OM_Stun lo deja congelado y quieto en
 *       el sitio (como el owner suponia que ya pasaba).
 *   (8) OVERDRIVE LEVITA (Espacio mantenido) + INTERACTUA CON LA
 *       EMBESTIDA: mientras la C está activa, mantener Espacio =
 *       levitar (vel[2] = 220). Con la embestida en el aire (antes
 *       imposible): escritura horizontal directa dir*750 conservando
 *       la Z — la embestida vuela a la altura que la levitación
 *       sostenga. Bloqueo mutuo C<->Z ELIMINADO (la combinación es
 *       intencional: C + Espacio + Z = dash aéreo).
 *   (9) 1 VIDA + AUTO-DESTRUCCION (la Sin-Incap ya existía desde v3.1):
 *       la explosión de muerte ahora es LA DEL GMOD (l.756: esfera
 *       230, dano 50, DMG_CLUB) con el stun de 5.5s pedido por el
 *       owner ("5seg y medio"; el GMod usa 7) + RAGDOLL: cada special
 *       afectado sale VOLANDO con su doble prop_ragdoll (receta Sonic
 *       v6.11 Sonic_SpawnFlingRagdoll: estatua oculta + doble con
 *       vphysics + onda env_physexplosion; al pasar el stun reaparece
 *       DONDE cayó el doble) + los 2 sonidos extra del lua
 *       (Explosión.wav + MetalBloodSound.wav, soundLevel 87).
 *
 *  v5.1 (suite 3.77.26 — revisión del owner 8.5/10, ajuste 1: "el
 *   efecto de cura revisaste bn el efecto que usa metal en Gmod? el
 *   original"):
 *   - FX DEL TICK DE CURA = EL ORIGINAL DEL LUA DE VERDAD. El v5.0 solo
 *     ponía un sprite glow01 verde flotante — NO era el efecto del mod.
 *     Cada tick (+7 HP cada 2s) reproduce las DOS señales del lua
 *     (l.987-988, ambas con ventana 0.5*0.5 = 0.25s):
 *     (1) MetalSonicHeal_highlight -> TINTE VERDE del avatar con el fade
 *         EXACTO del UI (l.94-112: 0->1 en 0.125s + 1->0 en 0.125s,
 *         Color(0,255,0, 255*alpha)) aplicado sobre las DOS copias R/L
 *         cada FRAME (Metal_PreThink = la misma granularidad por frame
 *         del hook de cliente del GMod) + DLIGHT VERDE de verdad
 *         (l.1583-1596: r=0 g=255 b=0, brightness 3, Size 200, Decay
 *         1000 — luz que ilumina la ESCENA alrededor): light_dynamic
 *         "0 255 0" brightness 3 distance 200 parentado al player
 *         (receta Sonic_MakeBlueLight v6.20, probada en el server),
 *         nace OFF y TurnOn SOLO durante la ventana del destello.
 *     (2) metalsonic_ability_outline -> halo BLANCO fino del om_halo
 *         (UI l.135-148, blur 1, Color(255,255,255)): el outline por
 *         shader no es portable a L4D2 — sustituto documentado: anillo
 *         TE fino blanco 8->48u a la altura del pecho, vida 0.25s (el
 *         mismo pulso blanco por tick).
 *     FUERA el sprite glow01 verde (el original NO lo tiene). Limpieza
 *     total de la luz: muere en Metal_StopHeal (natural/dano/stun) Y en
 *     Metal_ResetState (muerte/desconexion/cambio de personaje en plena
 *     cura — nunca queda huerfana encendida tras el parent roto).
 *
 *  v5.0 (suite 3.77.25 — pedido del owner: "Es tiempo del avatar de
 *   metal Sonic. Ya sabes que hacer... mover la habilidad que tiene
 *   metal actualmente que es esa aura eléctrica a la habilidad 3 y la
 *   curación sería en la X y para su habilidad Z que es la embestida
 *   (te lo dira el lua de Gmod) usaremos el truco que usamos con
 *   sonic... lo de desplazarse por el suelo"):
 *   - AVATAR DE METAL SONIC (models/Noodles/OM/metal.mdl, modelScale 1
 *     del lua): el patron Sonic v6.30 COMPLETO — doble copia R/L, modo
 *     TP para la R (tails_avatar_tp: la que ven los demas viaja por
 *     TeleportEntity + reloj vivo = interpolada suave), L parentada +
 *     EF_NOINTERP + pulso de pausa (tails_pausefix: UN solo sistema),
 *     transmit filters dueño/demas, cuerpo del survivor RENDER_NONE,
 *     follow PostThink con yaw suave (deadband 3 grados, 900 grados/s,
 *     Tails_ExpDamp 0.05) y FSM de animación a 10 Hz con las secuencias
 *     del metal.mdl: idle/walk/run/jump/fall + "charge" (embestida) +
 *     "heal" (reparación) + one-shots ChargeUp (windup) / Slam1-Slam2
 *     (estampado, alternando por golpe como el PillAnim('Slam'..random)
 *     del lua) / HealToIldle (salida de la cura). RAGDOLL de muerte
 *     prop_ragdoll metal.mdl + ventana anti-corpse de 2s (receta
 *     Sonic v3.76.2: la muerte del avatar corre en el player_death
 *     POST, jamás en el PRE del manager). Palanca: metalom_avatar 1.
 *   - EMBESTIDA (Z) AHORA SE DESPLAZA POR EL SUELO (truco Sonic): FUERA
 *     el modo aéreo FLYGRAVITY con re-escritura de velocidad por frame
 *     (receta Amy v63); DENTRO el mecanismo del spindash — SLOT 2 del
 *     stack del Speed_sonic (SPEED_STACK_METAL_DASH) sube m_flMaxspeed
 *     a 750 y el auto-forward se inyecta en OnPlayerRunCmd (vel[0]
 *     saturado = el OM_MoveForward del GMod): EL MOTOR lo mueve con la
 *     física de caminar — sube escalones, sigue rampas, no despega, no
 *     se desliza por las paredes. Launch instantaneo 750 (tope ya
 *     alzado) + sostenido + arrastre, los tres a 750 (orden v4.2 R36).
 *     El grupo DEBRIS durante dash/arrastre se CONSERVA (atraviesa
 *     cuerpos como el mod). Windup/slam/rebote/FOV/loop/FX: intactos.
 *   - HABILIDAD 2 (X) = SELF REPAIR (nueva, port del lua T key):
 *     toggle de reparación — tick cada 2s: +7 HP (heal_healamount),
 *     acumulado +7 (TotalHeals, tope 70 = 10 ticks), para sola a HP
 *     150 o tope 70. CONGELADO mientras repara (OM_NoMovement 6.7s del
 *     lua) y el dano entrante la CANCELA bloqueándose (GMod:
 *     OM_Damage_Reduction = 1 + hook EntityTakeDamage que corta la
 *     cura). Cooldown 24s (heal_cooldownSucess) al terminar o cancelar.
 *     Sonidos REALES del pack: Metal self repair activation (2).wav /
 *     Heal.wav por tick / healfinished.wav al cerrar + glow verde por
 *     tick (el MetalSonicHeal_highlight del lua: dlight verde 200/brillo
 *     3 — aquí sprite glow01 verde + centro "REPARANDO x/70").
 *   - HABILIDAD 3 (C) = V. MAXIMUM OVERDRIVE: la aura eléctrica +
 *     +30% velocidad se MUEVE de la X a la C (pedido literal del owner).
 *     Cero cambio de lógica: es la misma de siempre en su nueva tecla.
 *   - Fixes heredados automáticos por ser el 4o avatar del suite:
 *     modo TP + pausa + interpolación viva (tails_avatar_tp 1 default),
 *     stun unificado OM_Stun v2.0 (Metal ya llamaba al documento único),
 *     auto-agregado del convar metalom_avatar al Sonic_Suite.cfg por la
 *     reconciliación de la 3.77.4 (prefijo metalom_ aniadido a la lista).
 *
 *  v4.2 (R36 - reporte del owner):
 *   - VELOCIDAD DE LA CARGA: 750 uu/s (pedido literal: la de v4.0/4.1 a
 *     1850 era MUY alta). Launch + sostenido + arrastre, los tres.
 *   - DANO QUE RECIBE METAL: -75% en TODAS las vias (tick de arrastre
 *     4->1, tope 40->10 con el MISMO timing de soltada; golpe de slam
 *     13->3.25). El GMod se autodestruia con la carga: ahora castiga sin
 *     sentenciar.
 *   - ELECTRIC + IMPACT del CUERPO de la victima CADA TICK de arrastre
 *     (GMod l.1196-1202: Metal_ChargeImpact en victima+40z+fwd*20 y
 *     Metal_eletricity en victima+30z) — v4.1 solo los usaba en el dash.
 *   - PUNCH IMPACT del cuerpo de Metal en cada golpe del slam (GMod
 *     l.1318-1320) y el 3er golpe remata con punchstun.wav +
 *     metalchargeend.wav (GMod l.1410-1432).
 *   - FIX ICONO DE CARGA: el sprite flotante del windup quedaba vivo si
 *     interrumpian la carga con dano (Metal_CancelWindup no lo mataba).
 *
 *  v4.0 - PORT FIEL DEL MOD GMOD "[Pill Pack] Outcome Memories" (Workshop
 *   3640989797, GMA extraido y auditado): pedido del owner "yo quería
 *   hacerlo igual a como esta hay". Fuente: lua/autorun/include/survivor/
 *   noodles_om_pills_survivors_metalsonic.lua (1800 líneas) + convars
 *   OUTCOMEMEMORIES_N_MetalSonic_charge_* del registro oficial:
 *   - DURACION 8s (charge_Duration) y VELOCIDAD 3524 x 0.525 = 1850 uu/s
 *     (speedhandeler "Charging", factor 0.525) — antes 2.5s y 1000.
 *   - AUTO-FORWARD TOTAL (GMod OM_MoveForward cada frame): el jugador SOLO
 *     dirige con la mira. Embestida y ARRASTRE ya no piden W nunca: la
 *     física FLYGRAVITY re-aplica la velocidad cada frame (receta Amy
 *     v63) con DIRECCION HORIZONTAL pura (Metal_GetMoveDir: mirar abajo
 *     ya NO frena la carga — bug oculto del v3.6: el vector con pitch
 *     perdia hasta el 100% de la velocidad XY).
 *   - ATRAPAR (GMod FindInSphere 100): stun 1.6s (additionalstun_tic x 2)
 *     + dano 4 (DamageTick) vía OM_Stun — el sistema de STUN del mod
 *     portado al suite (OM_Stun.inc): freeze + 3 estrellas girando +
 *     chispas + zap + tinte rojo + shake.
 *   - ARRASTRE: infectado ADELANTE (forward x 65, yaw+180, SetPos cada
 *     frame igual que el mod) a VELOCIDAD DE EMBESTIDA (no 600),
 *     re-stuneado 0.8s cada tick de 0.25s (en el GMod no podía actuar;
 *     aquí antes seguía disparando), 4 de dano al infectado por tick
 *     (DamageTick, que el v3.6 no aplicaba) + 4 auto-dano hasta el cap
 *     de 40 (= 2.5s de arrastre).
 *   - INVULNERABLE durante la carga (GMod OM_Damage_Reduction = 0 en dash
 *     y arrastre; el windup sigue interrumpible como en el mod).
 *   - WALL SLAM: 3 golpes temporizados EXACTOS del mod (0.167/0.417/
 *     0.717s), cada uno stun 2s (additionalstun_slam x 0.33) + 9.75 al
 *     infectado (slamDamage x 0.33) + 13 auto-dano + chispas en la pared;
 *     fin a 1.05s con empuje de salida 300 (GMod dir x 300). El infectado
 *     queda PINEADO contra la pared (SetPos(hitPos + normal x pushDist)
 *     del mod) mirando a Metal.
 *   - REBOTE sin infectado: impulso ~250 atras + 1.4s de recuperación
 *     (GMod OM_NoMovement 1.4 + SetVelocity 200), con slide físico real
 *     los primeros 0.25s.
 *   - FOV 105 durante la embestida (el mod abre la cámara +40) y loop
 *     eléctrico TODO el trayecto (metalChargeLoopSound) con StopSound en
 *     TODOS los caminos de fin (el v3.6 lo dejaba colgado sonando).
 *
 *  Rol: Tanque Kamikaze / Bruiser
 *  Pasivas: Resistencia 50%, Sin Incap (Explota al morir), Sonar de Infectados, Impermeable.
 *  Habilidad 1 (Z): Destructive Charge (carga, agarra, arrastra y estampa — por SUELO v5.0)
 *  Habilidad 2 (X): Self Repair (reparación: +7 HP/2s congelado, cancela con dano)
 *  Habilidad 3 (C): V. Maximum Overdrive (velocidad y dano eléctrico)
 *
 *  v3.6 - OVERDRIVE = DANO + VELOCIDAD REAL (corrección del owner 09/30:
 *   "no era al max over, era a la 1 habilidad, la EMBESTIDA!!! el MAX
 *   SOLO SERVIA COMO DANO Y VELOCIDAD EN SI, DEBERÍA AUMENTAR LA
 *   VELOCIDAD (pero no debe hacer conflicto con speed: si se usa uno y
 *   otro la velocidad SUMA)"):
 *   - El modo aéreo/FLYGRAVITY de v3.5 era para la EMBESTIDA (habilidad
 *     1), que lo conserva INTACTO (impulso único 1500/1000, momentum,
 *     step-assist, DEBRIS, HitWall receta Amy v62). El Overdrive NO es
 *     un vuelo: se revierte a BUFF puro estilo v3.4.
 *   - OVERDRIVE v3: cero m_flLaggedMovementValue (el 1.3 viejo era
 *     escala de TIEMPO = rubber-band = el "no sirve" de siempre), cero
 *     FLYGRAVITY, cero DEBRIS, cero impulso de arranque. Es dano
 *     eléctrico (aura intacta) + VELOCIDAD REAL +30%
 *     (METAL_OVERDRIVE_SPEED_MULT = 1.3) registrada en el STACK ADITIVO
 *     del Speed_sonic v3.2 (API Speed_StackSet, SLOT 0).
 *   - SUMA, NO PISA ("no debe hacer conflicto con speed"): si !speed
 *     (x3.5) y Overdrive (x1.3) están activos a la vez, la velocidad
 *     SUMA: 220 x (1 + 2.5 + 0.3) = 836 uu/s. El chute de adrenalina
 *     agrega su +40 encima (el Speed_sonic v3.2 lo suma solo).
 *   - Fin natural (5s) = sobrecalentamiento canonico (1.5s inmovil),
 *     exactamente como v3.4. Incap/agarre: el writer del Speed_sonic
 *     pausa la velocidad en esos estados (restaura la natural).
 *
 *  v3.5 - MODO AIRE REAL (FLYGRAVITY) - "restaura el impulso a como estaba,
 *   pero con el truco: en vez de una velocidad de suelo y una de aire, el
 *   método de air con gravedad" (feedback del owner tras confirmar que el
 *   Speed_sonic v3.0 maxspeed "AHORA SI funciona como velocidad real"):
 *   - CAUSA RAÍZ del "max overdrive no sirve": el Overdrive usaba
 *     m_flLaggedMovementValue = 1.3 (escala de TIEMPO, el método que ya
 *     descartamos en Speed_sonic): el servidor simula 1.3x pero la
 *     predicción del cliente corre a 1x -> rubber-band -> "no funciona".
 *   - SOLUCION (la receta probada de la embestida de Amy v63/v66):
 *     MOVETYPE_FLYGRAVITY ("air con gravedad") durante Overdrive y DASH.
 *     Ese camino de física NO aplica la fricción del suelo NI el clampeo
 *     a m_flMaxspeed (la velocidad escrita es la que integra el motor, en
 *     tierra igual que en el aire) y la gravedad sigue trabajando normal
 *     (vel[2] conservada). Cero lagged, cero conflicto con Speed_sonic.
 *   - OVERDRIVE v2: lagged 1.3 ELIMINADO. Arranque 1500 + piso sostenido
 *     1000 (momentum superior conservado), dirección a la mirada,
 *     reafirmación del movetype cada tick, red de seguridad de maxspeed,
 *     grupo DEBRIS (atraviesa cuerpos), fin por pared de verdad (sin
 *     sobrecalentamiento) o estado inválido, restauración TOTAL en TODOS
 *     los caminos de fin.
 *   - DASH: modo dual v3.4 ELIMINADO (velocidad de suelo + de aire): un
 *     solo impulso "como estaba" en v3.3 (lanzamiento 1500, piso 1000,
 *     conservación de momentum) corriendo en FLYGRAVITY. Step-assist de
 *     escalones (FLYGRAVITY no sube bordillos como caminar: receta Amy
 *     v63: impulso vertical 250 si la velocidad real queda frenada).
 *   - Metal_HitWall (receta Amy v62): las criaturas YA NO cuentan como
 *     pared (con DEBRIS la embestida las atraviesa) y las rampas/
 *     escaleras transitables (normal.z >= 0.7) tampoco: solo paredes
 *     empinadas, props y puertas. Rayo desde los ojos a 70u.
 *
 *  v3.4 - MODO DUAL TIERRA/AIRE DE LA EMBESTIDA (feedback del usuario:
 *   "la mejora de metal si está funcionando; para que el empuje de tierra
 *   sea más poderoso, cuando este en tierra aplicar el doble de fuerza
 *   (2.5), pero cuando este en el aire esa velocidad se detenga y cambie
 *   a modo aéreo, o sea cambie al impulso aéreo, para evitar que el
 *   personaje se vaya de plano volando debido a la inmensa fuerza que
 *   estamos aplicando cuando está en el piso"):
 *   - MODO TIERRA: la fuerza continua de la embestida en piso ahora es
 *     2.5x (METAL_DASH_SPEED_GROUND = 1000 x 2.5 = 2500 uu/s): empuje de
 *     tierra mucho más poderoso, renovado cada frame (la fricción no la
 *     mata, técnica de la atracción del tank).
 *   - MODO AÉREO: en cuanto Metal despega del piso, la velocidad 2.5x de
 *     tierra SE DETIENE en seco en ese mismo frame: se recorta al impulso
 *     aéreo (METAL_DASH_AIR_CAP = 1500) y de ahi en adelante el dash
 *     aéreo se sostiene con el piso anterior (METAL_DASH_SPEED = 1000,
 *     conservando el momentum vertical para que la gravedad trabaje
 *     normal). Resultado: la inmensa fuerza del piso nunca lo lanza de
 *     plano volando por el mapa.
 *   - Transición AIRE->TIERRA (aterriza a mitad del dash): vuelve al
 *     modo tierra con su fuerza 2.5x: no pierde fuerza ni en aire ni en
 *     tierra (requisito original de v3.3 intacto).
 *   - Trail de chispas intensificado en tierra (7 vs 4 en aire) para que
 *     la potencia extra SE VEA.
 *
 *  v3.3 - REWORK DE LA EMBESTIDA (bug del usuario: "el impulso muere
 *   cuando Metal trata de usarlo en tierra, pierde toda la fuerza, solo
 *   que no se desactiva; el coso del tank -la atracción de jugadores-
 *   funciona incluso con ellos en el suelo, xq Metal no logra ese mismo
 *   efecto de no perder fuerza en el aire como en el suelo?"):
 *   - CAUSA RAÍZ: el WINDUP congela a Metal con m_flLaggedMovementValue = 0
 *     y la transición WINDUP->DASH JAMÁS lo restauraba a 1.0: la simulación
 *     de movimiento corria a velocidad 0x durante TODO el dash, el impulso
 *     de 1500 quedaba escrito en m_vecVelocity pero nunca se integraba
 *     (Metal parado en el sitio mientras el estado seguía "activo" hasta el
 *     timeout de 2.5s: exactamente "pierde el impulso todo y no se
 *     desactiva").
 *   - FIX 1: restaurar lagged movement a 1.0 al entrar en DASH.
 *   - FIX 2 (técnica de la atracción del tank): la embestida ahora es de
 *     FUERZA CONTINUA: cada frame de PreThink se re-aplica la velocidad
 *     hacia donde mira Metal (como el Black Hole del Super Tank, que tira
 *     de jugadores en el suelo re-aplicando SetVelocity cada 0.03s). La
 *     fricción del suelo ya no puede comerse el impulso: la fuerza se
 *     renueva cada tick, en tierra igual que en el aire.
 *   - El impulso inicial de Peelout (1500) se conserva y NO se recorta: el
 *     sostenido re-aplica como MÍNIMO METAL_DASH_SPEED y mantiene el
 *     momentum superior si lo hay (en aire ~1500, en suelo piso de 1000).
 *   - Nuevo trail de chispas (0.1s) para que la embestida se VEA activa.
 *
 *  v3.1 - FIXES DE BUGS Y LÓGICA (reajuste):
 *   - FIX PASIVA FALTANTE: "Sin Incap (Explota al morir)" estaba prometida
 *     en el header pero NO estaba implementada (no había ningún manejo de
 *     m_isIncapacitated). Ahora: golpe letal -> detonación directa
 *     (muerte + explosión), nunca queda incapacitado tirado en el suelo.
 *   - FIX PASIVA FALTANTE: la explosión solo ocurría por auto-dano de la
 *     carga. Ahora Metal detona SIEMPRE que muere de verdad (infectados,
 *     suicidio, cualquier causa) vía Metal_Event_PlayerDeath.
 *   - FIX ESTADO RESIDUAL: si Metal moria o se desconectaba durante
 *     WALL_SLAM / BOUNCE (MOVETYPE_NONE) o WINDUP (velocidad 0) o con el
 *     tinte rojo del parpadeo, nada lo restauraba al reaparecer. Ahora
 *     Metal_ResetState restaura movimiento/color/velocidad y hay reset
 *     defensivo en cada spawn (Metal_Event_PlayerSpawn).
 *   - FIX SEGURIDAD: el suicidio por auto-dano ya no se ejecuta en medio
 *     del think de la carga (ForcePlayerSuicide dentro de PreThink); se
 *     marca como pendiente y se ejecuta al inicio del siguiente frame.
 *   - LIMPIEZA: eliminado el parámetro "fromCharge" de SelfDestruct que
 *     no se usaba.
 *
 *  v3.0 - Implementación canonica según spec oficial:
 *   - Windup ~1s con parpadeo rojo (3 destellos).
 *   - Dash con controles resbaladizos (estilo Dropdash).
 *   - Al agarrar Executioner: Metal LO ARRASTRA, sigue moviéndose.
 *   - Auto-dano 4 HP / 0.25s mientras arrastra. Total acumulado 40 HP.
 *   - Reducido si Metal < 30% HP. Muy reducido en Last Man Standing.
 *   - Si no mantiene W mientras arrastra: Metal se queda pegado, acumula
 *     40 HP de dano (PEOR que wall slam = 39).
 *   - Wall slam CON Executioner: infectado aturdido 10s, Metal pierde 39 HP (13x3).
 *     En LMS: 15 HP (5x3).
 *   - Wall slam SIN Executioner: rebota, aturdido 1-2s.
 *   - Cancel en windup: dano completo (ignora resistencia), CD reducido (50%),
 *     speed boost temporal que stacea con on-hit.
 *   - Fin natural del charge (acumula 40): infectado aturdido 3s, Metal libre.
 *   - El stun NO comienza hasta que Metal slamea al infectado contra pared
 *     o lo suelta (termina el charge).
 * ======================================================
 */

#if defined _Metal_included
    #endinput
#endif
#define _Metal_included

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
#if !defined _om_stun_included
    #include <OM_Stun>     // v4.0: sistema de STUN portado del mod GMod
#endif
#if !defined _pin_release_included
    #include <Pin_Release> // v5.2: liberar agarres por el camino del MOTOR (ajuste 7)
#endif

#if !defined METALSONIC_INDEX
    #define METALSONIC_INDEX 8
#endif

// v5.2: índices de los personajes del aura de soporte del Self Repair
// (ajuste 6). Tails.inc ya los define (va antes en el manager); el
// guard los hace inocuos y a la vez auto-contenidos.
#if !defined TAILS_INDEX
    #define TAILS_INDEX 1
#endif
#if !defined EGGMAN_INDEX
    #define EGGMAN_INDEX 9
#endif

#if !defined TEAM_INFECTED
    #define TEAM_INFECTED 3
#endif
#if !defined TEAM_SURVIVOR
    #define TEAM_SURVIVOR 2
#endif

// =======================
// Constantes Ajustables
// =======================
#define METAL_WINDUP_DURATION       1.0   // Carga canonica ~1 segundo
#define METAL_DASH_DURATION         8.0   // v4.0 GMod: OUTCOMEMEMORIES_N_MetalSonic_charge_Duration = 8s
#define METAL_DASH_LAUNCH           750.0  // v4.2 R36: pedido del owner (v4.0/4.1: 1850 = MUY alta)
#define METAL_DASH_SPEED            750.0  // v4.2 R36: piso de velocidad sostenida de la embestida
#define METAL_DASH_FX_TICK          0.05   // v4.0: trail denso (GMod suelta particulas cada frame)
#define METAL_DASH_FOV              105   // v4.0 GMod: cámara abierta durante la embestida (mod: +40)

// v3.5 - MODO AIRE REAL (FLYGRAVITY)
#define METAL_DASH_COLGROUP         2      // v3.5: DEBRIS durante embestida/overdrive (atraviesa cuerpos)
#define METAL_AIR_SLOW_FACTOR       0.5    // v3.5: vel. real por debajo del 50% del piso = frenado físico
#define METAL_AIR_STEPASSIST_VEL    250.0  // v3.5: impulso vertical para saltarse escalones (receta Amy v63)
#define METAL_AIR_END_DAMP          0.35   // v3.5: frenado horizontal al salir del modo aire (fin natural)
#define METAL_AIR_END_DAMP_WALL     0.15   // v3.5: frenado al salir contra pared
#define METAL_WALL_AHEAD            70.0   // v3.5: detección de pared delante (unidades, desde los ojos)
#define METAL_WALL_WALK_NORMAL_Z    0.7    // v3.5: normal.z >= esto = superficie transitable, NO pared
#define METAL_GRAB_RADIUS           100.0 // v4.0 GMod: FindInSphere(ent + 50z, 100)
#define METAL_DRAG_SPEED            750.0  // v4.2 R36: el arrastre sigue a la velocidad de la embestida
#define METAL_CATCH_STUN            1.6   // v4.0 GMod: additionalstun_tic x 2 al ATRAPAR
#define METAL_CATCH_DMG             7.75  // v5.7: +25% (era 6.2 del v5.5, que ya era 4.0 del GMod +55%) — dano al ATRAPAR
#define METAL_DRAG_DMG_ENEMY        7.75  // v5.7: +25% (era 6.2 del v5.5) — DamageTick AL ENEMIGO cada 0.25s
#define METAL_DRAG_STUN_TICK        0.8   // v4.0 GMod: additionalstun_tic (re-stun por tick)
#define METAL_ENEMY_HOLD_DIST       65.0  // v4.0 GMod: forward x 65 (enemigo ADELANTE, mirando a Metal)

#define METAL_DRAG_DMG_NORMAL       1     // v4.2: -75% (era 4): castiga sin sentenciar
#define METAL_DRAG_DMG_LOWHP        1     // v4.2: -75% (era 2)
#define METAL_DRAG_DMG_LMS          1     // v4.2: piso de misericordia LMS (ya era 1)
#define METAL_DRAG_TOTAL_CAP        10    // v4.2: -75% (era 40) -> MISMO timing de soltada (2.5s)
#define METAL_DRAG_TICK             0.25  // Intervalo de auto-dano

#define METAL_DROP_STUN_TIME        3.0   // Stun al soltarlo por 40 acumulado (v4.0: con efectos OM_Stun)
#define METAL_SLAM_STUN_PER_HIT     2.0   // v4.0 GMod: additionalstun_slam x 0.33 POR GOLPE (apilan ~6s)
#define METAL_WALL_SLAM_DMG         4.0625 // v5.7.1: +25% (era 3.25 del v4.2; 3 hits = 12.1875 vs 9.75) — completo el +25% de la embestida que falto en la fusión del v5.7
#define METAL_WALL_SLAM_DMG_LMS     1.5625 // v5.7.1: +25% (era 1.25 del v4.2; 3 hits = 4.6875 vs 3.75)
#define METAL_SLAM_DMG_ENEMY        18.875 // v5.7: +25% (era 15.1 del v5.5) — slamDamage POR GOLPE al infectado
#define METAL_SLAM_HIT_1            0.167 // v4.0 GMod: t del golpe 1 (timings exactos del mod)
#define METAL_SLAM_HIT_2            0.417 // v4.0 GMod: t del golpe 2
#define METAL_SLAM_HIT_3            0.717 // v4.0 GMod: t del golpe 3
#define METAL_SLAM_END              1.05  // v4.0 GMod: duration x 3 (fin + empuje de salida)

#define METAL_BOUNCE_SPEED          250.0 // v4.0 GMod: impulso de rebote hacia atras (mod: 200)
#define METAL_BOUNCE_STUN           1.4   // v4.0 GMod: OM_NoMovement 1.4s tras el rebote
#define METAL_BOUNCE_SLIDE          0.25  // v4.0: slide físico del golpe antes del freeze

#define METAL_CHARGE_COOLDOWN       13.125 // v5.7: -25% (era 17.5 del v5.2, que ya era 25 del GMod -30%)
#define METAL_CHARGE_CD_CANCELLED   6.5625 // v5.7: -25% (era 8.75 del v5.2; 50% del normal)

#define METAL_CANCEL_SPEED_BOOST    1.25  // Multiplicador de velocidad al cancelar windup
#define METAL_CANCEL_BOOST_TIME     2.0   // Duración del speed boost

#define METAL_OVERDRIVE_COOLDOWN    21.0  // v5.2 ajuste 3: -30% (era 30)
#define METAL_OVERDRIVE_DURATION    5.0
#define METAL_OVERDRIVE_SPEED_MULT  1.30   // v3.6: +30% de VELOCIDAD REAL (aditivo: SUMA con !speed y adrenalina)
#define METAL_OD_LEVITATE_SPEED     220.0 // v5.2 ajuste 8: velocidad de levitación (Espacio mantenido con la C activa)
#define METAL_AURA_RADIUS           200.0
#define METAL_AURA_TICK             0.3
#define METAL_AURA_DMG_INF          15.0

#define METAL_SONAR_MAX_RANGE       800.0
#define METAL_SONAR_MIN_DELAY       0.1
#define METAL_SONAR_MAX_DELAY       0.5

// v5.2 ajuste 2: EL NIVEL DE SONIDO DEL MOD. Todas las habilidades del
// Metal en GMod emiten con soundLevel 87 (AdvancedPillSound del lua);
// el port usaba el default 75 (SNDLEVEL_NORMAL) = se oian flojos.
#define METAL_SND_LEVEL             87

// v5.2 ajuste 1: WATCHDOG DE ATASCOS. Si en DASH/DRAGGING la velocidad
// real no supera METAL_STUCK_SPEED durante METAL_STUCK_TIME (gracia de
// METAL_STUCK_GRACE tras el lanzamiento), la carga se libera limpia.
#define METAL_STUCK_SPEED           80.0
#define METAL_STUCK_TIME            0.6
#define METAL_STUCK_GRACE           0.5

// ---- v5.3 (ronda 3 del owner) ----
#define METAL_MAX_HP                175   // v5.3 punto 5: vida máxima de Metal al escogerlo
#define METAL_MAXHP_ASSERT_TICK     1.0   // v5.3: re-afirmación del tope (segundos)
#define METAL_COMMON_KILL_RADIUS    120.0 // v5.3 punto 2: radio de la avalancha de comunes
#define METAL_COMMON_KILL_TICK      0.1   // v5.3: escaneo de comunes cada 0.1s
#define METAL_COMMON_KILL_DMG       9999.0 // v5.3: un toque = muerto
#define METAL_WITCH_HOLD_DIST       85.0  // v5.3 punto 3: la witch va un poco más adelantada (es grande)
#define METAL_WITCH_RELEASE_FLING   400.0 // v5.3: impulso al soltar a la witch
#define METAL_WITCH_STUN_REFRESH    1.5   // v5.4: refresco del congelado (estatua) de la witch por tick
#define METAL_WITCH_WALLSTUN_KEEP   2.0   // v5.5: freeze de la witch al FIN del estampado (el "tiempo correspondiente" de los SI)
#define METAL_DRAG_RELEASE_FLING    350.0 // v5.3: impulso al soltar al arrastrado (cap de dano)
#define METAL_STUCK_TELEPORT_DIST   90.0  // v5.3 punto 4: el atascado se teletransporta DETRÁS

// v5.2 ajuste 9: LA AUTO-DESTRUCCION DEL GMOD (l.756+): esfera 230,
// dano 50 DMG_CLUB — y el stun de 5.5s pedido por el owner ("5seg y
// medio"; alla StunDur 7) con RAGDOLL volador por victima.
#define METAL_DEATH_RADIUS          230.0
#define METAL_DEATH_DMG             50.0
#define METAL_DEATH_STUN            5.5

#define METAL_LOW_HP_THRESHOLD      0.30  // 30% de HP máximo

// =======================
// v5.0: SELF REPAIR (X) — números EXACTOS del lua GMod
// (convars OUTCOMEMEMORIES_N_MetalSonic_heal_* del registro oficial)
// =======================
#define METAL_HEAL_COOLDOWN        16.8   // v5.2 ajuste 3: -30% (era 24 = heal_cooldownSucess del lua)
#define METAL_HEAL_TICK             2.0   // healingCooldown_OM: un tick cada 2s
#define METAL_HEAL_AURA_MULT        2.0   // v5.2 ajuste 6: x2 de velocidad de tick con Tails/Eggman a 250u (= tails_heal_boost default)
#define METAL_HEAL_AURA_RADIUS      250.0 // v5.2 ajuste 6: mismo radio del tails_heal_boost del suite
#define METAL_HEAL_AMOUNT           7     // heal_healamount (+7 HP por tick)
#define METAL_HEAL_TOTAL_CAP        70    // TotalHeals tope (10 ticks)
#define METAL_HEAL_HP_CAP           175   // v5.3 punto 5: tope del Self Repair = la vida max nueva (era 150 del lua)
#define METAL_HEAL_FREEZE           6.7   // OM_NoMovement 6.7s refrescado por tick
#define METAL_HEAL_EXIT_FREEZE      0.5   // NoMovement 0.5s al cerrar (si curo >= 1 tick)
#define METAL_HEAL_FX               0.25  // v5.1: ventana del destello (0.5*0.5 del lua)
#define METAL_HEAL_FX_FADE          0.125 // v5.1: rampa simétrica (0.25*0.5, UI l.99)

// =======================
// v5.0: AVATAR (models/Noodles/OM/metal.mdl — lua l.51, modelScale '1')
// =======================
#define METAL_OM_MODEL     "models/Noodles/OM/metal.mdl"
#define METAL_AVATAR_NAME  "metal_avatar_om"

// FSM del avatar: 11 estados (secuencias del metal.mdl — tabla anims del
// lua l.183-195 + ShouldAlternate l.247-273: heal/charge sustituyen a
// idle/walk/run/fall mientras duran; ChargeUp/HealToIldle/Slam1/Slam2
// son one-shots con AlternatePlaySolution en el lua)
#define METAL_ANIM_COUNT 11
#define METAL_ST_CHARGEUP   5   // one-shot: windup de la embestida
#define METAL_ST_CHARGE     6   // loop: embestida/arrastre (dash)
#define METAL_ST_HEAL       7   // loop: reparándose
#define METAL_ST_HEAL2IDLE  8   // one-shot: salida de la cura
#define METAL_ST_SLAM1      9   // one-shot: golpe de estampado 1
#define METAL_ST_SLAM2     10   // one-shot: golpe de estampado 2

// =======================
// Estados del Charge
// =======================
enum
{
    METAL_STATE_IDLE = 0,
    METAL_STATE_WINDUP,     // Cargando (inmovil, parpadea)
    METAL_STATE_DASH,       // Avanza buscando Executioner
    METAL_STATE_DRAGGING,   // Arrastrando Executioner, sigue en movimiento
    METAL_STATE_WALL_SLAM,  // Slameando contra pared (timer de 3 hits)
    METAL_STATE_BOUNCE      // Rebote sin infectado (stun 1-2s)
};

// =======================
// Variables Globales
// =======================
float g_fMetalChargeCD[MAXPLAYERS + 1];
float g_fMetalOverdriveCD[MAXPLAYERS + 1];

int   g_iMetalChargeState[MAXPLAYERS + 1];
int   g_iMetalGrabbedTarget[MAXPLAYERS + 1];
float g_fMetalStateEndTime[MAXPLAYERS + 1];
float g_fMetalNextDragTick[MAXPLAYERS + 1];   // Próximo tick de auto-dano
float g_fMetalAccumulatedDragDmg[MAXPLAYERS + 1]; // Dano acumulado en el drag actual
float g_fMetalWindupStartTime[MAXPLAYERS + 1]; // Para calcular los 3 destellos

// Wall slam (v4.0: 3 golpes con los tiempos EXACTOS del GMod) + rebote
int   g_iMetalSlamHitsFired[MAXPLAYERS + 1];    // golpes ya disparados (0..3)
float g_fMetalSlamStartTime[MAXPLAYERS + 1];    // t0 del slam (hits a 0.167/0.417/0.717s)
float g_vMetalSlamWallPos[MAXPLAYERS + 1][3];   // punto de impacto contra la pared
float g_vMetalSlamWallNrm[MAXPLAYERS + 1][3];   // normal de la pared (empuje del final)
float g_fMetalBounceStart[MAXPLAYERS + 1];      // v4.0: t0 del rebote (slide + freeze)

// v3.5: MODO AIRE REAL (FLYGRAVITY) de la embestida y el Overdrive.
// Snapshots para restaurarlo TODO en TODOS los caminos de fin
// (misma técnica que la embestida de Amy v63/v66).
int   g_iMetalSavedColGroup[MAXPLAYERS + 1];  // grupo de colisión original (-1 = nada guardado)
float g_fMetalSavedMaxSpeed[MAXPLAYERS + 1];  // m_flMaxspeed original   (<1  = nada guardado)

// Overdrive
bool  g_bMetalOverdrive[MAXPLAYERS + 1];
float g_fMetalOverdriveEndTime[MAXPLAYERS + 1];
float g_fMetalNextAuraTick[MAXPLAYERS + 1];

// Sonar
float g_fMetalNextBeepTick[MAXPLAYERS + 1];

// Cancel boost
float g_fMetalCancelBoostEnd[MAXPLAYERS + 1];

// v3.3: trail de la embestida (FX del dash)
float g_fMetalNextDashFX[MAXPLAYERS + 1];

// v5.2 ajuste 1: watchdog de atascos del dash/arrastre
float g_fMetalStuckSince[MAXPLAYERS + 1];     // 0 = moviéndose bien

// v5.3 punto 2: avalancha de comunes (escaneo throttled)
float g_fMetalNextCommonKill[MAXPLAYERS + 1]; // próximo escaneo de "infected"
float g_fMetalNextCommonSnd[MAXPLAYERS + 1];  // throttle del sonido de avalancha

// v5.3 punto 3: la WITCH como objetivo del dash (entref; 0 = ninguna)
int   g_iMetalWitchTarget[MAXPLAYERS + 1];    // entref de la witch arrastrada
int   g_iMetalWitchColGroup[MAXPLAYERS + 1];  // grupo de colisión original de la witch (-1 = nada)
int   g_iMetalWitchSavedMT[MAXPLAYERS + 1];   // movetype original de la witch (por si no es WALK)
bool  g_bMetalWitchHadFrozen[MAXPLAYERS + 1];  // v5.4: la witch ya traía FL_FROZEN de otro stun al atraparla

// v5.3 punto 4: grupo de colisión original del CLIENTE arrastrado (-1 = nada)
int   g_iMetalVictimColGroup[MAXPLAYERS + 1];

// v5.3 punto 5: re-afirmación del tope de vida
float g_fMetalNextMaxHpAssert[MAXPLAYERS + 1];

// v5.2 ajuste 5: ventana del one-shot de salto (receta Sonic fix Poppy)
float g_fMetalJumpStart[MAXPLAYERS + 1];      // t0 del jump para la FSM

// v3.1: pasivas "Sin Incap" / "Explota al morir"
bool  g_bMetalSelfDestructPending[MAXPLAYERS + 1]; // Detonación pendiente (auto-dano)
bool  g_bMetalLethalHit[MAXPLAYERS + 1];           // Golpe letal recibido (sin incap)

// Cache de modelos precacheados
int g_iMetalSpriteGlow = 0;

// v4.1: ASSETS REALES del mod GMod (VPK "om_"). Cero dependencia: si el
// VPK no está montado, todo cae a los sonidos/sprites stock de la v4.0.
bool  g_bMetalAssets = false;               // gate FileExists(materials/om/...)
int   g_iMetalFxGlow = 0;                   // om/metal_chargeglow.vmt (icono windup)
stock int   g_iMetalFxElec = 0;                   // legacy: asignado (map start) pero nunca leido
stock int   g_iMetalFxImpact = 0;                 // legacy: asignado (map start) pero nunca leido
int   g_iMetalFxSpark = 0;                  // om/metal_spark.vmt (estela del dash)
int   g_iMetalBeam = 0;                     // om/beam_glow.vmt (rayos TE)
bool  g_bMetalSndLoop = false;              // om/metal/metalchargeloopsound.wav (LOOP)
bool  g_bMetalSndCharge = false;            // om/metal/metal_chargeup.wav
bool  g_bMetalSndElec = false;              // om/metal/eletricsound.wav
bool  g_bMetalSndPing = false;              // om/metal/ping1.wav
bool  g_bMetalSndSlam = false;              // om/metal/wallslam.wav
bool  g_bMetalSndBump = false;              // om/metal/wallbump.wav
bool  g_bMetalSndEnd = false;               // om/metal/metalchargeend.wav
bool  g_bMetalSndBoom = false;              // om/metal/explodesfx.wav
bool  g_bMetalSndBoom2 = false;             // v5.2: om/metal/Explosión.wav (la muerte toca 3 del lua)
bool  g_bMetalSndBlood = false;             // v5.2: om/metal/MetalBloodSound.wav (3er sonido del lua)
bool  g_bMetalSndPunch = false;             // v4.2: om/knuckles/punchstun.wav (3er golpe del slam)
int   g_iMetalWindupIcon[MAXPLAYERS + 1];   // env_sprite del icono de carga
int   g_iMetalDashFxTick[MAXPLAYERS + 1];   // contador (arcos/estela)
float g_fMetalLoopStart[MAXPLAYERS + 1];    // watchdog del loop (wav 3.41s)

// v6.0: LA TORMENTA ELÉCTRICA DEL DESTRUCTIVE (particulas del owner)
ConVar g_cvMetalFXCharge = null;               // metalom_fx_charge (kill-switch de la capa)
int    g_iMetalDashFlameRef[MAXPLAYERS + 1];   // EntRef flame_blue en el torso de Metal
int    g_iMetalArcRefs[MAXPLAYERS + 1][3];     // EntRefs efx_arc_new1/XXL/XXL2 sobre la victima

// v6.0: nombres y tiempos de la tormenta (las macros viven AQUÍ porque
// OnMapStart las usa — la expansión de macros es POSICIONAL en spcomp)
#define METAL_FX_FLAME_BLUE  "flame_blue"                // torso de Metal durante la embestida
#define METAL_FX_ARC_V1      "efx_arc_new1"              // arcos sobre la victima arrastrada
#define METAL_FX_ARC_XXL     "efx_arc_new1_XXL"          // variante XXL
#define METAL_FX_ARC_XXL2    "efx_arc_new1_XXL2"         // variante XXL2
#define METAL_FX_ARC_WALL    "electrical_arc_01_system"  // el estampado contra la pared
#define METAL_FX_FLAME_LIFE  20.0    // tope de la llama (dash 8s + arrastre 10s + margen)
#define METAL_FX_ARC_LIFE    15.0    // tope de los arcos (arrastre 10s + margen)
#define METAL_FX_WALL_LIFE   2.0     // el destello del impacto contra la pared
#define METAL_FX_TORSO_Z     40.0    // altura del torso de Metal

// v5.0: SELF REPAIR (X)
bool  g_bMetalHealing[MAXPLAYERS + 1];      // el toggle de reparación vive
float g_fMetalHealNextTick[MAXPLAYERS + 1]; // próximo +7 (cada 2s)
int   g_iMetalHealTotal[MAXPLAYERS + 1];    // TotalHeals del lua (tope 70)
float g_fMetalHealCD[MAXPLAYERS + 1];       // heal_cooldown (24s al cerrar)
float g_fMetalHealFreezeEnd[MAXPLAYERS + 1]; // NoMovement vigente (6.7s/tick)
float g_fMetalHealExitEnd[MAXPLAYERS + 1];  // 0.5s de salida al terminar
float g_fMetalHealAnimEnd[MAXPLAYERS + 1];  // ventana del anim "heal" en la FSM
int   g_iMetalHealLight[MAXPLAYERS + 1];    // v5.1: EntRef del light_dynamic verde
bool  g_bMetalHealLightOn[MAXPLAYERS + 1];  // v5.1: TurnOn/TurnOff por ventana
float g_fMetalHealFxStart[MAXPLAYERS + 1];  // v5.1: inicio del destello (para el fade)
float g_fMetalHealFxEnd[MAXPLAYERS + 1];    // v5.1: fin del destello (0 = inactivo)

// v5.0: sonidos del heal (gates del VPK om_; fallback stock si faltan)
bool  g_bMetalSndHealAct = false;           // om/metal/Metal self repair activation (2).wav
bool  g_bMetalSndHeal = false;              // om/metal/Heal.wav (por tick)
bool  g_bMetalSndHealFin = false;           // om/metal/healfinished.wav

// v5.0: AVATAR (patron sonic.inc v6.30 — mismo sistema Tails compartido)
ConVar g_cvMetalAvatar = null;              // metalom_avatar (default 1)
bool   g_bMetalModelOK = false;             // metal.mdl presente en el VPK
int    g_iMetalAvatar[MAXPLAYERS + 1];       // EntRef copia R (0 = sin avatar)
int    g_iMetalAvatarL[MAXPLAYERS + 1];      // EntRef copia L (solo el dueño)
int    g_iMetalBodyRender[MAXPLAYERS + 1];   // RenderMode original del cuerpo
int    g_iMetalAnimState[MAXPLAYERS + 1];    // estado actual de la FSM
float  g_fMetalAnimLock[MAXPLAYERS + 1];     // lock de los one-shots
float  g_fMetalBodyYaw[MAXPLAYERS + 1];      // yaw suavizado del cuerpo
float  g_fMetalYawLastT[MAXPLAYERS + 1];     // dt del giro suave
float  g_fMetalSmLoc[MAXPLAYERS + 1][3];     // smoothing angulos copia R
float  g_fMetalSmLocL[MAXPLAYERS + 1][3];    // smoothing angulos copia L
bool   g_bMetalSmSnap[MAXPLAYERS + 1];       // snap al nacer (write seco)
float  g_fMetalDeathHideUntil[MAXPLAYERS + 1]; // ventana anti-corpse (2s)
float  g_vMetalDeathOrigin[MAXPLAYERS + 1][3]; // origen de la muerte (filtro 200u)

// FSM del avatar: nombres de las secuencias del metal.mdl
static const char g_sMetalAnimSeq[METAL_ANIM_COUNT][16] = {
    "idle",           // 0
    "walk",           // 1
    "run",            // 2
    "jump",           // 3
    "fall",           // 4
    "ChargeUp",       // 5  one-shot: windup
    "charge",         // 6  loop: embestida/arrastre
    "heal",           // 7  loop: reparación
    "HealToIldle",    // 8  one-shot: salida de la cura
    "Slam1",          // 9  one-shot: estampado
    "Slam2"           // 10 one-shot: estampado
};

#define Metal_IsValidClient(%1) (1 <= %1 && %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1))

// =======================
// Inicialización
// =======================

public void Metal_OnPluginStart()
{
    RegConsoleCmd("sm_metal_charge", Command_MetalCharge);
    RegConsoleCmd("sm_metal_overdrive", Command_MetalOverdrive);
    RegConsoleCmd("sm_metal_heal", Command_MetalHeal);   // v5.0: X = Self Repair

    // v5.0: avatar — convar + FSM a 10 Hz (patron T_SonicAvatarThink) +
    // muerte en su PROPIO player_death POST (receta Sonic v3.76.2: el PRE
    // del manager corria antes de que el motor procesara la muerte y el
    // restore del cuerpo dejaba ver el corpse del survivor)
    g_cvMetalAvatar = CreateConVar("metalom_avatar", "1", "Metal Sonic OM: avatar espejo (metal.mdl del VPK de recursos, patron Tails/Sonic/Amy)", _, true, 0.0, true, 1.0);

    // v6.0: kill-switch de la tormenta eléctrica del Destructive Charge
    // (metalom_ = auto-guardado en el Sonic_Suite.cfg del suite)
    g_cvMetalFXCharge = CreateConVar("metalom_fx_charge", "1", "Metal Sonic OM: tormenta eléctrica del Destructive Charge (flame_blue en el torso durante la embestida + efx_arc_new1/XXL/XXL2 sobre la victima arrastrada + electrical_arc_01_system al estrellarla contra la pared)", _, true, 0.0, true, 1.0);
    CreateTimer(0.1, T_MetalAvatarThink, _, TIMER_REPEAT);
    HookEvent("player_death", Metal_Event_DeathPost);
}

public void Metal_OnMapStart()
{
    PrecacheSound("buttons/button17.wav", true);
    PrecacheSound("ambient/explosions/explode_3.wav", true);
    PrecacheSound("ambient/energy/zap1.wav", true);
    PrecacheSound("npc/attack_helicopter/aheli_charge_up.wav", true);
    PrecacheSound("player/tank/hit/hulk_punch_1.wav", true);
    PrecacheSound("player/tank/hit/hulk_punch_2.wav", true);
    PrecacheSound("player/survivor/hit/crowbar_swing_miss1.wav", true);
    PrecacheSound("ambient/machines/electric_loop.wav", true);
    // v5.0: fallbacks del heal (si el VPK om_ no trae los .wav del mod)
    PrecacheSound("ui/pickup_medkit.wav", true);
    PrecacheSound("items/smallmedkit1.wav", true);
    PrecacheSound("items/healthcharger.wav", true);

    // v6.0: LA TORMENTA ELÉCTRICA — nombres en la tabla del motor (no-op
    // si ya están). electrical_arc_01_system (pet_fusion v48) y flame_blue
    // (airstrike de ESTE server) ya están montadas y comprobadas; las
    // efx_arc_new* son del pack de particulas del owner. Si alguna no
    // existiera, su info_particle_system simplemente no renderiza (fallo
    // silencioso — previsualización con el fxtest.smx: sm_fxt flame_blue).
    Metal_ParticlePrecache(METAL_FX_FLAME_BLUE);
    Metal_ParticlePrecache(METAL_FX_ARC_V1);
    Metal_ParticlePrecache(METAL_FX_ARC_XXL);
    Metal_ParticlePrecache(METAL_FX_ARC_XXL2);
    Metal_ParticlePrecache(METAL_FX_ARC_WALL);

    g_iMetalSpriteGlow  = PrecacheModel("materials/sprites/glow01.vmt", true);

    // v4.1: ASSETS REALES del mod GMod (VPK "om_"). Gate FileExists vía
    // filesystem de Valve (ve VPKs montados). Sin VPK -> fallback stock.
    g_bMetalAssets = FileExists("materials/om/metal_chargeglow.vmt", true);
    if (g_bMetalAssets)
    {
        g_iMetalFxGlow   = PrecacheModel("materials/om/metal_chargeglow.vmt", true);
        g_iMetalFxElec   = PrecacheModel("materials/om/metal_elec.vmt", true);
        g_iMetalFxImpact = PrecacheModel("materials/om/metal_impact.vmt", true);
        g_iMetalFxSpark  = PrecacheModel("materials/om/metal_spark.vmt", true);
        g_iMetalBeam     = PrecacheModel("materials/om/beam_glow.vmt", true);

        g_bMetalSndLoop   = PrecacheSound("om/metal/metalchargeloopsound.wav", true);
        g_bMetalSndCharge = PrecacheSound("om/metal/metal_chargeup.wav", true);
        g_bMetalSndElec   = PrecacheSound("om/metal/eletricsound.wav", true);
        g_bMetalSndPing   = PrecacheSound("om/metal/ping1.wav", true);
        g_bMetalSndSlam   = PrecacheSound("om/metal/wallslam.wav", true);
        g_bMetalSndBump   = PrecacheSound("om/metal/wallbump.wav", true);
        g_bMetalSndEnd    = PrecacheSound("om/metal/metalchargeend.wav", true);
        g_bMetalSndBoom   = PrecacheSound("om/metal/explodesfx.wav", true);
        // v5.2 ajuste 9: los otros DOS sonidos de la muerte del lua
        // (l.594-604: ExplodeSfx + Explosión + MetalBloodSound)
        g_bMetalSndBoom2  = PrecacheSound("om/metal/Explosión.wav", true);
        g_bMetalSndBlood  = PrecacheSound("om/metal/MetalBloodSound.wav", true);
        g_bMetalSndPunch  = PrecacheSound("om/knuckles/punchstun.wav", true);

        AddFileToDownloadsTable("materials/om/metal_chargeglow.vmt");
        AddFileToDownloadsTable("materials/om/metal_chargeglow.vtf");
        AddFileToDownloadsTable("materials/om/metal_elec.vmt");
        AddFileToDownloadsTable("materials/om/metal_elec.vtf");
        AddFileToDownloadsTable("materials/om/metal_impact.vmt");
        AddFileToDownloadsTable("materials/om/metal_impact.vtf");
        AddFileToDownloadsTable("materials/om/metal_spark.vmt");
        AddFileToDownloadsTable("materials/om/metal_spark.vtf");
        AddFileToDownloadsTable("materials/om/metal_particle.vmt");
        AddFileToDownloadsTable("materials/om/metal_particle.vtf");
        AddFileToDownloadsTable("materials/om/beam_glow.vmt");
        AddFileToDownloadsTable("materials/om/beam_glow.vtf");
        if (g_bMetalSndLoop)   AddFileToDownloadsTable("sound/om/metal/metalchargeloopsound.wav");
        if (g_bMetalSndCharge) AddFileToDownloadsTable("sound/om/metal/metal_chargeup.wav");
        if (g_bMetalSndElec)   AddFileToDownloadsTable("sound/om/metal/eletricsound.wav");
        if (g_bMetalSndPing)   AddFileToDownloadsTable("sound/om/metal/ping1.wav");
        if (g_bMetalSndSlam)   AddFileToDownloadsTable("sound/om/metal/wallslam.wav");
        if (g_bMetalSndBump)   AddFileToDownloadsTable("sound/om/metal/wallbump.wav");
        if (g_bMetalSndEnd)    AddFileToDownloadsTable("sound/om/metal/metalchargeend.wav");
        if (g_bMetalSndBoom)   AddFileToDownloadsTable("sound/om/metal/explodesfx.wav");
        if (g_bMetalSndBoom2)  AddFileToDownloadsTable("sound/om/metal/Explosión.wav");
        if (g_bMetalSndBlood)  AddFileToDownloadsTable("sound/om/metal/MetalBloodSound.wav");
        if (g_bMetalSndPunch)  AddFileToDownloadsTable("sound/om/knuckles/punchstun.wav");

        // v5.0: sonidos del SELF REPAIR (mismo VPK)
        g_bMetalSndHealAct = PrecacheSound("om/metal/Metal self repair activation (2).wav", true);
        g_bMetalSndHeal    = PrecacheSound("om/metal/Heal.wav", true);
        g_bMetalSndHealFin = PrecacheSound("om/metal/healfinished.wav", true);
        if (g_bMetalSndHealAct) AddFileToDownloadsTable("sound/om/metal/Metal self repair activation (2).wav");
        if (g_bMetalSndHeal)    AddFileToDownloadsTable("sound/om/metal/Heal.wav");
        if (g_bMetalSndHealFin) AddFileToDownloadsTable("sound/om/metal/healfinished.wav");
    }

    // v5.0: AVATAR — gate del modelo (PrecacheModel devuelve 0 si el .mdl
    // no está en el VPK montado; con 0 el avatar jamás se monta y todo lo
    // demas del Metal sigue igual — misma receta g_bSonicModelOK)
    g_bMetalModelOK = view_as<bool>(PrecacheModel(METAL_OM_MODEL, true));

    for (int i = 1; i <= MaxClients; i++)
        Metal_ResetState(i);
}

public void Metal_OnClientPutInServer(int client)
{
    SDKUnhook(client, SDKHook_OnTakeDamage, Metal_OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamage, Metal_OnTakeDamage);

    SDKUnhook(client, SDKHook_PreThink, Metal_PreThink);
    SDKHook(client, SDKHook_PreThink, Metal_PreThink);

    // v5.0: follow del avatar (post-think: escribe los angulos contra-
    // rotados después de que el motor integre el tick del survivor)
    SDKUnhook(client, SDKHook_PostThink, Metal_AvatarFollow);
    SDKHook(client, SDKHook_PostThink, Metal_AvatarFollow);

    // v5.0: slot limpio para el ocupante nuevo (nunca hereda avatar)
    g_iMetalAvatar[client]     = 0;
    g_iMetalAvatarL[client]    = 0;
    g_iMetalBodyRender[client] = -1;
    g_iMetalAnimState[client]  = -1;
    g_bMetalSmSnap[client]     = true;
}

void Metal_ResetState(int client)
{
    g_iMetalChargeState[client]       = METAL_STATE_IDLE;
    g_iMetalGrabbedTarget[client]     = -1;
    g_bMetalOverdrive[client]         = false;
    // v3.6: quitar el extra de velocidad del Overdrive del stack del
    // Speed_sonic (muerte/spawn/desconexion/cambio de personaje en pleno
    // Overdrive: nunca queda velocidad residual heredada)
    Speed_StackSet(client, SPEED_STACK_METAL_OD, 0.0);
    // v5.0: idem el SLOT 2 de la EMBESTIDA (por suelo: si muere a mitad
    // del dash, el tope de m_flMaxspeed baja con la última fuente)
    Speed_StackSet(client, SPEED_STACK_METAL_DASH, 0.0);
    g_fMetalChargeCD[client]          = 0.0;
    g_fMetalOverdriveCD[client]       = 0.0;
    g_fMetalAccumulatedDragDmg[client] = 0.0;
    g_iMetalSlamHitsFired[client]     = 0;   // v4.0: golpes del slam disparados
    g_fMetalCancelBoostEnd[client]    = 0.0;
    g_fMetalNextDashFX[client]        = 0.0;
    g_fMetalStuckSince[client]        = 0.0;  // v5.2: watchdog de atascos fuera
    g_fMetalJumpStart[client]         = 0.0;  // v5.2: ventana del jump fuera
    g_iMetalDashFxTick[client]        = 0;    // v4.1
    g_fMetalLoopStart[client]         = 0.0;  // v4.1
    Metal_KillWindupIcon(client);             // v4.1: icono de windup fuera
    Metal_FxFlameStop(client);                // v6.0: la llama azul del torso fuera (muerte/cambio/mapa)
    Metal_FxArcsStop(client);                 // v6.0: los arcos de la victima fuera (idempotente)

    // ============================================================
    // v5.3 ronda 3: limpiezas de los sistemas nuevos
    // ============================================================
    // punto 4: restaurar al ARRASTRADO (cliente a DEBRIS / witch)
    // por el camino que sea — idempotente
    Metal_ReleaseGrabbed(client, true);
    g_bMetalWitchHadFrozen[client] = false;   // v5.4: sin estado de freeze heredado

    // puntos 2+5: timers de la avalancha y del tope de vida fuera
    g_fMetalNextCommonKill[client]  = 0.0;
    g_fMetalNextCommonSnd[client]   = 0.0;
    g_fMetalNextMaxHpAssert[client] = 0.0;

    // punto 5: NADIE hereda las 175 — al dejar de ser Metal (cambio de
    // personaje / muerte / descarga del plugin) el tope vuelve a 100 y
    // la vida se recorta si quedaba por encima (el spawn como Metal de
    // nuevo las re-aplica)
    Metal_RestoreMaxHealth(client);

    // v5.0: SELF REPAIR fuera (muerte/cambio en plena cura: sin freeze
    // residual, sin cooldown heredado)
    g_bMetalHealing[client]       = false;
    g_iMetalHealTotal[client]     = 0;
    g_fMetalHealNextTick[client]  = 0.0;
    g_fMetalHealFreezeEnd[client] = 0.0;
    g_fMetalHealExitEnd[client]   = 0.0;
    g_fMetalHealAnimEnd[client]   = 0.0;
    g_fMetalHealFxStart[client]   = 0.0;    // v5.1
    g_fMetalHealFxEnd[client]     = 0.0;    // v5.1
    Metal_KillHealLight(client);            // v5.1: la luz verde nunca queda huerfana

    // v3.1 FIX ESTADO RESIDUAL: restaurar el estado visual/movimiento del
    // propio Metal. Antes, si moria o se desconectaba durante WALL_SLAM /
    // BOUNCE (MOVETYPE_NONE + tinte rojo) o WINDUP (velocidad 0), nada lo
    // restauraba y poda reaparecer congelado o teñido de rojo.
    g_bMetalSelfDestructPending[client] = false;
    g_bMetalLethalHit[client]           = false;

    if (client >= 1 && client <= MaxClients && IsClientInGame(client))
    {
        // v5.0: salir del grupo DEBRIS por el camino que sea (la embestida
        // va por suelo pero SIGUE atravesando cuerpos durante el dash)
        Metal_DashColExit(client);
        SetEntityMoveType(client, MOVETYPE_WALK);
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        SetEntityRenderColor(client, 255, 255, 255, 255);
        Metal_AvatarTintReset(client);
        // v4.0: FOV y loop eléctrico también se restauran (muerte/spawn/
        // desconexion en plena embestida: cero estado residual)
        SetEntProp(client, Prop_Send, "m_iFOV", 0);
        SetEntProp(client, Prop_Send, "m_iFOVStart", 0);
        Metal_StopLoopSound(client);
    }

    // v3.5: sentinelas limpias (slots no conectados incluidos)
    g_iMetalSavedColGroup[client] = -1;
    g_fMetalSavedMaxSpeed[client] = -1.0;
}

// =======================
// HELPERS
// =======================

// Cuenta sobrevivientes vivos (no incapacitados)
int Metal_CountAliveSurvivors()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_SURVIVOR)
        {
            if (GetEntProp(i, Prop_Send, "m_isIncapacitated") == 0)
                count++;
        }
    }
    return count;
}

// Detecta si Metal está en Last Man Standing
// v3.1: parámetro client eliminado (nunca se uso: cuenta a todos los vivos)
bool Metal_IsLMS()
{
    return Metal_CountAliveSurvivors() <= 1;
}

// Detecta si Metal esta por debajo del 30% de HP
bool Metal_IsLowHP(int client)
{
    int hp = GetClientHealth(client);
    int maxHp = GetEntProp(client, Prop_Send, "m_iMaxHealth");
    if (maxHp <= 0) maxHp = 100;
    return float(hp) <= float(maxHp) * METAL_LOW_HP_THRESHOLD;
}

// v5.5: EL BOOMER NO LE ESTALLA ENCIMA A METAL. Si el golpe de la
// embestida sería LETAL para un boomer (o ya tiene la mecha puesta),
// el dano NO se aplica: se marca la MECHA (OM_BoomerFuseMark STUN del
// OM_Stun v2.1) y el boomer estalla solo cuando SU stun termina, ya
// lejos de Metal. Devuelve el dano a pasarle al OM_Stun (0 si la mecha
// se come el golpe).
float Metal_BoomerGuardDamage(int target, float dmg, int client)
{
    if (target < 1 || target > MaxClients || !IsClientInGame(target)) return dmg;
    if (GetClientTeam(target) != 3) return dmg;
    if (GetEntProp(target, Prop_Send, "m_zombieClass") != 2) return dmg;  // 2 = boomer

    if (OM_BoomerFusePending(target) || float(GetClientHealth(target)) <= dmg)
    {
        OM_BoomerFuseMark(target, client, OM_BOOMER_FUSE_STUN);
        return 0.0;
    }
    return dmg;
}

// Devuelve el dano por tick de arrastre según contexto
int Metal_GetDragDamage(int client)
{
    if (Metal_IsLMS())
        return METAL_DRAG_DMG_LMS;
    if (Metal_IsLowHP(client))
        return METAL_DRAG_DMG_LOWHP;
    return METAL_DRAG_DMG_NORMAL;
}

// =======================
// PASIVAS Y SONAR
// =======================

public void Metal_PreThink(int client)
{
    if (!Metal_IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return;

    float now = GetEngineTime();

    // v3.1 FIX SEGURIDAD: detonación pendiente por auto-dano de la carga.
    // Se ejecuta AQUÍ (inicio del frame) en vez de en medio del think de
    // la carga, para no llamar ForcePlayerSuicide dentro de Metal_ChargeThink.
    if (g_bMetalSelfDestructPending[client])
    {
        g_bMetalSelfDestructPending[client] = false;
        if (IsPlayerAlive(client)) ForcePlayerSuicide(client); // detona vía evento de muerte
        return;
    }

    // v3.1 FIX PASIVA "SIN INCAP": si el último golpe letal lo dejo
    // incapacitado (el juego incapacita en vez de matar), detonarlo
    // directamente: muerte + explosión, nunca queda tirado en el suelo.
    if (g_bMetalLethalHit[client])
    {
        g_bMetalLethalHit[client] = false; // bandera de un solo uso
        if (IsPlayerAlive(client) && GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
        {
            ForcePlayerSuicide(client); // detona vía evento de muerte
            return;
        }
    }

    // v4.0 (GMod OM_Stun_Blockfunction): un stun que aterrice sobre Metal
    // en plena carga la corta en seco (el mod cancela charge/heal igual).
    if (g_iMetalChargeState[client] != METAL_STATE_IDLE && OM_IsStunned(client))
    {
        Metal_CancelCharge(client);
        return;
    }
    // v5.0: un stun también corta la REPARACION (mismo bloqueo del mod)
    if (g_bMetalHealing[client] && OM_IsStunned(client))
    {
        Metal_StopHeal(client, false);
        return;
    }

    // ============================================================
    // v5.3 punto 5: re-afirmar el TOPE DE VIDA cada 1s — el motor lo
    // re-normaliza a 100 en algunos caminos (revive, transiciones) y el
    // BOTIQUIN cura hacia el máximo que VEE: si ve 100, recorta la vida
    // extra (el bug de "si me aplican botiquin pierdo la vida
    // adicional"). Con 175 grabado en las DOS copias (Data + Send), el
    // medkit cura hacia 175 de verdad.
    // ============================================================
    if (now >= g_fMetalNextMaxHpAssert[client])
    {
        g_fMetalNextMaxHpAssert[client] = now + METAL_MAXHP_ASSERT_TICK;
        if (GetClientTeam(client) == TEAM_SURVIVOR
            && !GetEntProp(client, Prop_Send, "m_isIncapacitated")
            && GetEntProp(client, Prop_Data, "m_iMaxHealth") != METAL_MAX_HP)
        {
            if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
                SetEntProp(client, Prop_Data, "m_iMaxHealth", METAL_MAX_HP);
            if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
                SetEntProp(client, Prop_Send, "m_iMaxHealth", METAL_MAX_HP);
        }
    }

    // 0. Cancel speed boost (si activo)
    if (g_fMetalCancelBoostEnd[client] > 0.0)
    {
        if (now >= g_fMetalCancelBoostEnd[client])
        {
            g_fMetalCancelBoostEnd[client] = 0.0;
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        }
        else
        {
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", METAL_CANCEL_SPEED_BOOST);
        }
    }

    // 1. SONAR DE PROXIMIDAD
    if (now >= g_fMetalNextBeepTick[client] && g_iMetalChargeState[client] == METAL_STATE_IDLE)
    {
        g_fMetalNextBeepTick[client] = now + 0.5;

        int closestInfected = -1;
        float closestDist = METAL_SONAR_MAX_RANGE;
        float mPos[3], tPos[3];
        GetClientAbsOrigin(client, mPos);

        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
            {
                GetClientAbsOrigin(i, tPos);
                float dist = GetVectorDistance(mPos, tPos);
                if (dist < closestDist)
                {
                    closestDist = dist;
                    closestInfected = i;
                }
            }
        }

        if (closestInfected != -1)
        {
            float delay = METAL_SONAR_MIN_DELAY + (closestDist / METAL_SONAR_MAX_RANGE) * (METAL_SONAR_MAX_DELAY - METAL_SONAR_MIN_DELAY);
            g_fMetalNextBeepTick[client] = now + delay;

            int hp = GetClientHealth(client);
            int pitch = 100 + (150 - hp);
            if (pitch > 250) pitch = 250;
            if (pitch < 50)  pitch = 50;

            EmitSoundToClient(client, "buttons/button17.wav", _, _, _, _, _, pitch);
        }
    }

    // 2. OVERDRIVE (v3.6: revertido a BUFF de dano + VELOCIDAD REAL —
    // "el MAX solo servia como dano y velocidad en si". El modo aéreo
    // era para la EMBESTIDA, que lo conserva intacto. La velocidad es
    // un extra ADITIVO en el stack del Speed_sonic: SUMA con !speed y
    // con el chute de adrenalina, jamás los pisa. Cero lagged.)
    // v5.2 ajuste 4: al terminar YA NO INMOVILIZA (fuera el "reactor
    // sobrecalentado" con MOVETYPE_NONE 1.5s — pedido literal "el
    // movimiento de la habilidad C ya sobrecalentamiento ya no
    // inmovilizara a metal") y ajuste 8: LEVITACION mientras dure —
    // Espacio mantenido = despegue (vel[2] = 220, receta del vuelo de
    // Tails: escritura directa por TeleportEntity cada frame).
    if (g_bMetalOverdrive[client])
    {
        if (now >= g_fMetalOverdriveEndTime[client])
        {
            // Fin natural: solo quitar el bono — sigue moviéndose
            g_bMetalOverdrive[client] = false;
            Speed_StackSet(client, SPEED_STACK_METAL_OD, 0.0);
            PrintCenterText(client, "Overdrive completado.");
        }
        else
        {
            // v3.6: reafirmar el extra aditivo cada tick (auto-cura, el
            // mismo patron de la reafirmación del FLYGRAVITY de la
            // embestida: si algo limpia el slot, se re-registra solo) +
            // aura eléctrica canonica.
            Speed_StackSet(client, SPEED_STACK_METAL_OD, METAL_OVERDRIVE_SPEED_MULT - 1.0);

            // v5.2 ajuste 8: LEVITACION — Espacio mantenido despega a
            // Metal (conserva el componente horizontal de verdad). Solo
            // en los estados libres (idle/dash/arrastre): el windup, el
            // slam y el rebote son momentos congelados por diseño, y la
            // REPARACION también lo esta (NoMovement del lua).
            int levState = g_iMetalChargeState[client];
            if ((GetClientButtons(client) & IN_JUMP)
                && !g_bMetalHealing[client]
                && (levState == METAL_STATE_IDLE
                    || levState == METAL_STATE_DASH
                    || levState == METAL_STATE_DRAGGING)
                && GetEntProp(client, Prop_Send, "m_isIncapacitated") == 0)
            {
                float lev[3];
                GetEntPropVector(client, Prop_Data, "m_vecVelocity", lev);
                lev[2] = METAL_OD_LEVITATE_SPEED;
                TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, lev);
            }

            if (now >= g_fMetalNextAuraTick[client])
            {
                g_fMetalNextAuraTick[client] = now + METAL_AURA_TICK;
                Metal_OverdriveAuraTick(client);
            }
        }
    }

    // 3. SELF REPAIR (v5.0: la X — port del toggle T del lua) + su
    // ventana de salida congelado (NoMovement 0.5s del lua l.1036)
    if (g_bMetalHealing[client])
    {
        Metal_HealThink(client, now);
    }
    else if (g_fMetalHealExitEnd[client] > 0.0)
    {
        if (now >= g_fMetalHealExitEnd[client])
        {
            g_fMetalHealExitEnd[client] = 0.0;
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        }
        else
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);
    }

    // 4. DESTRUCTIVE CHARGE
    if (g_iMetalChargeState[client] > METAL_STATE_IDLE)
    {
        Metal_ChargeThink(client, now);
    }
}

// Aura de Overdrive
void Metal_OverdriveAuraTick(int client)
{
    float mPos[3];
    GetClientAbsOrigin(client, mPos);

    int entity = -1;
    while ((entity = FindEntityByClassname(entity, "infected")) != -1)
    {
        if (IsValidEntity(entity))
        {
            float zPos[3];
            GetEntPropVector(entity, Prop_Send, "m_vecOrigin", zPos);
            if (GetVectorDistance(mPos, zPos) <= METAL_AURA_RADIUS)
                SDKHooks_TakeDamage(entity, client, client, 999.0, DMG_SHOCK);
        }
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float tPos[3];
            GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(mPos, tPos) <= METAL_AURA_RADIUS)
                SDKHooks_TakeDamage(i, client, client, METAL_AURA_DMG_INF, DMG_SHOCK);
        }
    }

    TE_SetupSparks(mPos, NULL_VECTOR, 5, 2);
    TE_SendToAll();
}

// =======================
// DESTRUCTIVE CHARGE - THINK PRINCIPAL
// =======================

void Metal_ChargeThink(int client, float now)
{
    int state  = g_iMetalChargeState[client];
    int target = g_iMetalGrabbedTarget[client];

    // ---- ESTADO 1: WINDUP (cargando ~1s) ----
    if (state == METAL_STATE_WINDUP)
    {
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);

        // Parpadeo rojo con 3 destellos visibles sobre 1 segundo
        // v5.0: el parpadeo va al AVATAR (el cuerpo del survivor esta
        // RENDER_NONE — el tinte en el ya no se veía; GMod: el glow rojo
        // "metalsonic_ability_red_long" del puppet)
        float elapsed = now - g_fMetalWindupStartTime[client];
        float freq = METAL_WINDUP_DURATION / 3.0; // 3 destellos
        float phase = elapsed / freq;
        float sineVal = Sine(phase * 3.14159 * 2.0);
        int alpha = RoundToNearest(sineVal * 127.5 + 127.5);
        if (alpha < 50) alpha = 50;
        if (alpha > 255) alpha = 255;

        SetEntityRenderMode(client, RENDER_TRANSCOLOR);
        SetEntityRenderColor(client, 255, 0, 0, alpha);
        int avR = EntRefToEntIndex(g_iMetalAvatar[client]);
        if (avR > 0 && IsValidEntity(avR))
        {
            SetEntityRenderMode(avR, RENDER_TRANSCOLOR);
            SetEntityRenderColor(avR, 255, 0, 0, alpha);
        }
        int avLw = EntRefToEntIndex(g_iMetalAvatarL[client]);
        if (avLw > 0 && IsValidEntity(avLw))
        {
            SetEntityRenderMode(avLw, RENDER_TRANSCOLOR);
            SetEntityRenderColor(avLw, 255, 0, 0, alpha);
        }

        // v4.1: ICONO DE CARGA sobre la cabeza (GMod: metal_load girando
        // 900 grados/s a +23z; L4D2: sprite glow que flota y PULSA al
        // ritmo del parpadeo del windup — mismo mensaje visual).
        if (g_bMetalAssets && g_iMetalFxGlow != 0)
        {
            int icon = EntRefToEntIndex(g_iMetalWindupIcon[client]);
            float ipos[3];
            GetClientAbsOrigin(client, ipos);
            ipos[2] += 78.0;
            if (icon <= MaxClients || !IsValidEntity(icon))
            {
                g_iMetalWindupIcon[client] =
                    Metal_SpawnSprite(ipos, "materials/om/metal_chargeglow.vmt",
                                      "255 255 200", 0.30);
            }
            else
            {
                SetEntPropVector(icon, Prop_Data, "m_vecOrigin", ipos);
                SetEntPropFloat(icon, Prop_Data, "m_flSpriteScale",
                                0.26 + 0.12 * (float(alpha) / 255.0));
            }
        }

        if (now >= g_fMetalStateEndTime[client])
        {
            // Transición a DASH
            g_iMetalChargeState[client] = METAL_STATE_DASH;
            g_fMetalStateEndTime[client] = now + METAL_DASH_DURATION;
            g_fMetalNextDashFX[client]   = now;
            SetEntityRenderColor(client, 255, 0, 0, 255);
            Metal_AvatarTintReset(client);   // v5.0: el avatar vuelve a su color
            Metal_KillWindupIcon(client);

            // v4.1: ping1.wav REAL del mod al soltar la embestida
            if (g_bMetalSndPing)
                EmitSoundToAll("om/metal/ping1.wav", client, _, METAL_SND_LEVEL);
            else
                EmitSoundToAll("npc/attack_helicopter/aheli_charge_up.wav", client, _, METAL_SND_LEVEL);

            // v3.3 FIX CRITICO: el WINDUP congela con lagged movement 0.0 y
            // esta transición JAMÁS lo restauraba -> durante el DASH la
            // simulación de movimiento corria a 0x: el impulso quedaba
            // escrito pero Metal no se movía ("el impulso muere en tierra y
            // el estado no se desactiva"). Sin esto, ningún fix de
            // velocidad funciona.
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);

            // v4.0 GMod: loop eléctrico durante TODA la embestida (el
            // metalChargeLoopSound.wav del mod). Se detiene en TODOS los
            // caminos de fin (el v3.6 lo dejaba sonando para siempre tras
            // soltar al infectado: bug de sonido colgado).
            // v4.1: loop REAL del mod (metalchargeloopsound.wav, con cue de
            // loop horneada en el VPK) + watchdog de re-emisión cada 3s en
            // el dash (cero silencio aunque el cue no corra). Stop en TODOS
            // los finales vía Metal_StopLoopSound.
            // v5.9 FIX (reporte del owner: "cuando la habilidad del dash
            // termina el sonido del deslizamiento sigue sonando, no se
            // detiene — no ocurre si impacta contra algo"): STOP+EMIT al
            // ARRANCAR. Un re-emit a ciegas sobre el canal puede APILAR
            // copias del loop en clientes donde el replace del canal no
            // corre para wavs con cue de loop (cada copia solo muere con
            // su propio SND_STOP): primero se corta cualquier resto de
            // una carga anterior y DESPUÉS se emite — el canal arranca
            // con EXACTAMENTE una instancia viva. El fallback
            // electric_loop pasa de SNDCHAN_AUTO (0 = el MOTOR elige
            // canal: el stop sobre 0 puede no apuntar al canal elegido)
            // a SNDCHAN_STATIC explícito.
            StopSound(client, SNDCHAN_STATIC, "om/metal/metalchargeloopsound.wav");
            StopSound(client, SNDCHAN_STATIC, "ambient/machines/electric_loop.wav");
            StopSound(client, SNDCHAN_AUTO,   "ambient/machines/electric_loop.wav");
            if (g_bMetalSndLoop)
                EmitSoundToAll("om/metal/metalchargeloopsound.wav", client, SNDCHAN_STATIC, METAL_SND_LEVEL);
            else
                EmitSoundToAll("ambient/machines/electric_loop.wav", client, SNDCHAN_STATIC, METAL_SND_LEVEL);
            g_fMetalLoopStart[client] = now;

            // ============================================================
            // v5.0: LA EMBESTIDA VA POR EL SUELO (truco del spindash de
            // Sonic). FUERA el FLYGRAVITY con re-escritura de velocidad
            // por frame (receta Amy v63); DENTRO el mecanismo del roll:
            // SLOT 2 del stack del Speed_sonic -> m_flMaxspeed = 750, y
            // el auto-forward del RunCmd (vel[0] saturado = el
            // OM_MoveForward del GMod) hace que EL MOTOR lo mueva con la
            // física de caminar: sube escalones, sigue rampas, gravedad
            // normal, nunca despega. El grupo DEBRIS se conserva
            // (atraviesa cuerpos durante el dash como el mod).
            // ============================================================
            Metal_DashColEnter(client);
            Metal_DashSpeedSet(client, METAL_DASH_SPEED);
            g_fMetalStuckSince[client] = 0.0;   // v5.2: watchdog a cero

            // Launch instantaneo 750: con el tope YA alzado por el stack,
            // un único impulso horizontal queda clampeado por el motor al
            // maxspeed nuevo = arranca a full sin rampa (orden v4.2 R36:
            // "launch + sostenido, los tres a 750"). Dirección HORIZONTAL
            // pura (Metal_GetMoveDir: mirar abajo no frena el arranque).
            float dir[3], vel[3];
            Metal_GetMoveDir(client, dir);
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
            vel[0] = dir[0] * METAL_DASH_LAUNCH;
            vel[1] = dir[1] * METAL_DASH_LAUNCH;
            if (GetEntityFlags(client) & FL_ONGROUND)
                vel[2] = 0.0;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
            PrintCenterText(client, "DESTRUCTIVE CHARGE!");

            // ============================================================
            // v6.0: LA LLAMA AZUL DEL TORSO — "cuando metal empieze a
            // moverse con su destructive en su Torso nasera el efecto
            // flame_blue". Nace AQUÍ (la transición WINDUP->DASH = el
            // momento exacto en que Metal DESPEGA) y muere cuando Metal
            // SE DETIENE (Metal_FxFlameStop en cada camino de fin:
            // estampado / rebote / drop por cap / timeout / muerte).
            // Si el objetivo muere en sus manos la embestida CONTINUA
            // (v5.8) y la llama TAMBIÉN.
            // ============================================================
            Metal_FxFlameStart(client);
        }
        return;
    }

    // ---- ESTADO 2: DASH (embestida GMod: 8s a 750 uu/s, busca infectado) ----
    if (state == METAL_STATE_DASH)
    {
        // v5.0 GMod AUTO-FORWARD POR SUELO: el stack del Speed_sonic
        // re-afirma el tope (750) cada tick (auto-cura: si algo limpia el
        // slot, se re-registra solo — mismo patron del Overdrive) y el
        // auto-forward lo inyecta Metal_OnPlayerRunCmd (vel[0] saturado).
        // El MOTOR lo mueve con la física de caminar: cero re-escrituras
        // de velocidad, cero FLYGRAVITY, escalones y rampas nativos.
        Metal_DashSpeedSet(client, METAL_DASH_SPEED);

        // v4.0 GMod: FOV de velocidad mientras embiste (el mod abre la
        // cámara +40: a 105 se VE la velocidad). Se re-afirma por si el
        // juego lo resetea al cambiar de arma.
        SetEntProp(client, Prop_Send, "m_iFOV", METAL_DASH_FOV);
        SetEntProp(client, Prop_Send, "m_iFOVStart", METAL_DASH_FOV);

        // Trail de chispas denso (GMod suelta particulas cada frame)
        if (now >= g_fMetalNextDashFX[client])
        {
            g_fMetalNextDashFX[client] = now + METAL_DASH_FX_TICK;
            float pos[3];
            GetClientAbsOrigin(client, pos);
            TE_SetupSparks(pos, NULL_VECTOR, 7, 2);
            TE_SendToAll();

            // v4.1 (cada 6 ticks = 0.3s): ARCOS ELECTRICOS amarillos alrededor
            // (port del efecto metal_om_Eletricity del GMod: 4 puntos radio
            // 20-32 con jitter, vida 0.15s, amarillo 255 255 0).
            g_iMetalDashFxTick[client]++;
            if (g_bMetalAssets && g_iMetalBeam != 0 && g_iMetalDashFxTick[client] % 6 == 0)
                Metal_ElectricArcs(pos);

            // v4.1 (cada 5 ticks = 0.25s): ESTELA de particulas del mod
            // (GMod suelta particle_metal_1/metal_particle_new al pasar).
            if (g_bMetalAssets && g_iMetalFxSpark != 0 && g_iMetalDashFxTick[client] % 5 == 0)
            {
                int trailColor[4] = {180, 220, 255, 180};
                TE_SetupBeamFollow(client, g_iMetalFxSpark, 0, 0.5, 4.0, 1.0, 1, trailColor);
                TE_SendToAll();
            }

            // v4.1: watchdog del loop (wav 3.41s; re-arranca en el mismo canal)
            // v5.9 FIX: STOP+EMIT — el re-emit a ciegas APILABA copias del
            // loop en clientes donde el replace del canal no corre para
            // wavs con cue de loop horneada (la causa del "el deslizamiento
            // sigue sonando al terminar el dash": con impacto temprano había
            // UNA instancia y el stop final la mataba; al agotarse los 8s
            // habían 2-3 latidos acumulados y quedaban restos zombie).
            // Cada latido ahora PRIMERO corta la instancia viva y DESPUÉS
            // emite la nueva: el canal siempre tiene UNA sola instancia y
            // el stop final la mata seguro.
            if (g_bMetalSndLoop && now - g_fMetalLoopStart[client] >= 3.0)
            {
                StopSound(client, SNDCHAN_STATIC, "om/metal/metalchargeloopsound.wav");
                EmitSoundToAll("om/metal/metalchargeloopsound.wav", client, SNDCHAN_STATIC, METAL_SND_LEVEL);
                g_fMetalLoopStart[client] = now;
            }
        }

        // ============================================================
        // v5.2 ajuste 8: DASH AÉREO. En el aire el auto-forward del
        // RunCmd no sostiene 750 (el motor frena el wishspeed con la
        // acceleraion aérea) — escribir la componente horizontal
        // DIRECTO cada frame (dir * 750) conservando la Z: la
        // levitación de la C (Espacio) la sostiene, sin Espacio la
        // gravedad lo devuelve al piso y la embestida sigue por suelo.
        // v5.2 ajuste 1: WATCHDOG DE ATASCOS — la embestida DEBERÍA ir
        // a 750; si no supera 80 uu/s durante 0.6s (enemigos enormes
        // que taponan, geometria que no es "pared" para el trace), la
        // carga se libera limpia en vez de quedarse pegado 8s.
        // ============================================================
        if (!(GetEntityFlags(client) & FL_ONGROUND))
        {
            float airDir[3], airVel[3];
            Metal_GetMoveDir(client, airDir);
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", airVel);
            airVel[0] = airDir[0] * METAL_DASH_SPEED;
            airVel[1] = airDir[1] * METAL_DASH_SPEED;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, airVel);
            g_fMetalStuckSince[client] = 0.0;   // en el aire no hay atasco
        }
        else if (Metal_StuckCheck(client, now))
        {
            return;
        }

        // ============================================================
        // v5.3 punto 2: AVALANCHA DE COMMONS — los comunes que toca la
        // embestida MUEREN al instante (SDKHooks 9999 DMG_CLUB, escaneo
        // de entidades "infected" en radio 120u cada 0.1s). El v5.2 solo
        // miraba CLIENTS infectados: los comunes eran puro obstaculo
        // físico que taponaba los pasillos angostos.
        // ============================================================
        Metal_KillCommonsInPath(client, now);

        // Buscar objetivo (GMod: esfera de 100u alrededor del pecho)
        if (target == -1)
        {
            int grabbed = Metal_FindGrabTarget(client);
            if (grabbed != -1)
            {
                Metal_BeginDrag(client, grabbed, now);
                return;
            }

            // ========================================================
            // v5.3 punto 3: LA WITCH TAMBIÉN ES OBJETIVO ("ni puede
            // embestir a la witch") — misma esfera de 100u, pero sobre
            // entidades "witch" (la witch no es un client). Catch con
            // congelado + DEBRIS y el mismo FSM de arrastre/estampado.
            // ========================================================
            int witch = Metal_FindWitchTarget(client);
            if (witch != -1)
            {
                Metal_BeginWitchDrag(client, witch, now);
                return;
            }
        }

        // Choco pared SIN infectado -> rebote (GMod: vel ~200 + 1.4s)
        if (Metal_HitWall(client))
        {
            Metal_DoBounce(client);
            return;
        }

        // Tiempo agotado (8s GMod): fin natural
        if (now >= g_fMetalStateEndTime[client])
        {
            Metal_CancelCharge(client);
        }
        return;
    }

    // ---- ESTADO 3: DRAGGING (GMod: la embestida SIGUE a full velocidad
    // ARRASTRANDO al infectado por delante — sin W, sin frenar) ----
    if (state == METAL_STATE_DRAGGING)
    {
        // ============================================================
        // v5.3 punto 3: rama WITCH — el MISMO estado DRAGGING pero con
        // operaciones de entidad (congelado por movetype + dano directo,
        // sin OM_Stun que es player-only). Metal conserva velocidad,
        // watchdog, avalancha y estampado contra pared.
        // ============================================================
        if (g_iMetalWitchTarget[client] != 0)
        {
            Metal_WitchDragThink(client, now);
            return;
        }

        // Validar target — v5.8: SI MUERE EN SUS MANOS, LA EMBESTIDA
        // CONTINUA (Metal_DragTargetDied: vuelve al estado DASH y puede
        // atrapar otro objetivo; antes esto era Metal_CancelCharge y la
        // carga moria con el). El WALL_SLAM no pasa por aquí.
        if (!Metal_IsValidClient(target))
        {
            Metal_DragTargetDied(client);
            return;
        }

        // v5.0 GMod AUTO-FORWARD del arrastre: mismo mecanismo del dash por
        // suelo a velocidad de embestida (el v3.6 frenaba a 600 y exigia
        // "manten W": la fuente del "la carga no va bn"). El stack
        // re-afirma el tope a 750 y el RunCmd el auto-forward.
        Metal_DashSpeedSet(client, METAL_DRAG_SPEED);
        float dir[3];
        Metal_GetMoveDir(client, dir);

        // v5.2 ajustes 1+8: watchdog de atascos (el arrastre también va a
        // 750 — si el enemigo enorme tapono un paso estrecho, soltar) +
        // ARRASTRE AÉREO (la levitación de la C sostiene la altura y el
        // arrastre sigue volando; sin Espacio cae al piso y sigue).
        if (!(GetEntityFlags(client) & FL_ONGROUND))
        {
            float airVel[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", airVel);
            airVel[0] = dir[0] * METAL_DRAG_SPEED;
            airVel[1] = dir[1] * METAL_DRAG_SPEED;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, airVel);
            g_fMetalStuckSince[client] = 0.0;
        }
        else if (Metal_StuckCheck(client, now))
        {
            return;
        }

        // v5.3 punto 2: avalancha de comunes TAMBIÉN durante el arrastre
        // (se acumulan alrededor de la pelea y taponan el paso angosto)
        Metal_KillCommonsInPath(client, now);

        // v4.0 GMod: el infectado va ADELANTE (forward x 65) MIRANDO a
        // Metal (yaw + 180), clavado al frente (SetPos cada frame del mod).
        float mPos[3], hold[3], tAng[3], zeroVel[3], eyeAng[3];
        GetClientAbsOrigin(client, mPos);
        hold[0] = mPos[0] + dir[0] * METAL_ENEMY_HOLD_DIST;
        hold[1] = mPos[1] + dir[1] * METAL_ENEMY_HOLD_DIST;
        hold[2] = mPos[2] + 10.0;
        GetClientEyeAngles(client, eyeAng);
        tAng[0] = 0.0;
        tAng[1] = eyeAng[1] + 180.0;
        tAng[2] = 0.0;
        zeroVel[0] = 0.0; zeroVel[1] = 0.0; zeroVel[2] = 0.0;
        TeleportEntity(target, hold, tAng, zeroVel);

        // v4.0 GMod: cada 0.25s — re-stun 0.8s + dano al infectado
        // (DamageTick, con EFECTOS incluidos vía OM_Stun) y auto-dano a
        // Metal (v4.2: -75%, hasta el cap de 10 = 2.5s de arrastre).
        if (now >= g_fMetalNextDragTick[client])
        {
            g_fMetalNextDragTick[client] = now + METAL_DRAG_TICK;
            int dmg = Metal_GetDragDamage(client);
            g_fMetalAccumulatedDragDmg[client] += float(dmg);
            Metal_TakeSelfDamage(client, float(dmg));

            // v5.5: boomer letal = mecha (no muere encima de Metal)
            OM_Stun(target, METAL_DRAG_STUN_TICK, client,
                    Metal_BoomerGuardDamage(target, METAL_DRAG_DMG_ENEMY, client),
                    DMG_OM_CLUB, true);

            // v4.2 (GMod EXACTO, metalsonic.lua l.1196-1202 — "el electric
            // sale del cuerpo cada tick que metal lo sostiene"): cada tick
            // del arrastre le salen del CUERPO DE LA VICTIMA:
            //   * Metal_ChargeImpact (cuadrado de impacto) en +40z + fwd*20
            //   * Metal_eletricity (electricidad) en +30z + arcos alrededor
            // (el stun.wav de cada tick lo emite el OM_Stun al re-stunear)
            if (g_bMetalAssets && Metal_IsValidClient(target))
            {
                float vPos[3], fwd[3], iPun[3];
                GetClientAbsOrigin(target, vPos);
                Metal_GetMoveDir(client, fwd);
                iPun[0] = vPos[0] + fwd[0] * 20.0;
                iPun[1] = vPos[1] + fwd[1] * 20.0;
                iPun[2] = vPos[2] + 40.0;
                Metal_FxFlash(iPun, "materials/om/metal_impact.vmt", 0.55, 0.30);
                float ePos[3];
                ePos[0] = vPos[0];
                ePos[1] = vPos[1];
                ePos[2] = vPos[2] + 30.0;
                Metal_FxFlash(ePos, "materials/om/metal_elec.vmt", 0.65, 0.35);
                Metal_ElectricArcs(vPos);
            }

            if (g_fMetalAccumulatedDragDmg[client] >= float(METAL_DRAG_TOTAL_CAP))
            {
                Metal_DropByDamageCap(client, target);
                return;
            }
        }

        // Choco pared CON infectado -> WALL SLAM (estampado GMod)
        if (Metal_HitWall(client))
        {
            Metal_BeginWallSlam(client, now);
            return;
        }

        if (now >= g_fMetalStateEndTime[client])
            Metal_CancelCharge(client);

        return;
    }

    // ---- ESTADO 4: WALL_SLAM (GMod: 3 golpes temporizados 0.167/0.417/0.717s) ----
    if (state == METAL_STATE_WALL_SLAM)
    {
        // Metal inmovil golpeando (GMod: MOVETYPE_NONE + BeatDown)
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);
        SetEntityMoveType(client, MOVETYPE_NONE);

        float wElapsed = now - g_fMetalSlamStartTime[client];

        // Golpes disparados por TIEMPO (timings exactos del mod GMod)
        if (g_iMetalSlamHitsFired[client] < 1 && wElapsed >= METAL_SLAM_HIT_1)
        {
            g_iMetalSlamHitsFired[client] = 1;
            Metal_SlamHit(client);
        }
        if (g_iMetalSlamHitsFired[client] < 2 && wElapsed >= METAL_SLAM_HIT_2)
        {
            g_iMetalSlamHitsFired[client] = 2;
            Metal_SlamHit(client);
        }
        if (g_iMetalSlamHitsFired[client] < 3 && wElapsed >= METAL_SLAM_HIT_3)
        {
            g_iMetalSlamHitsFired[client] = 3;
            Metal_SlamHit(client);
        }

        // Fin del slam (1.05s): empuje de salida de la pared (GMod: vel 300
        // alejándose del muro) + restauración TOTAL + liberar al infectado
        // (su stun del último golpe sigue corriendo ~2s más, solo).
        if (wElapsed >= METAL_SLAM_END)
        {
            float outVel[3];
            outVel[0] = g_vMetalSlamWallNrm[client][0] * 300.0;
            outVel[1] = g_vMetalSlamWallNrm[client][1] * 300.0;
            outVel[2] = 100.0;

            // ========================================================
            // v5.3 puntos 3+4: soltar al objetivo por el camino COMÚN:
            // el ARRASTRADO recupera su grupo de colisión (su stun de
            // los golpes sigue corriendo solo) y la WITCH sale despedida
            // de la pared con la normal del muro.
            // ========================================================
            int slamWitch = (g_iMetalWitchTarget[client] != 0) ? Metal_GetWitchTarget(client) : -1;
            if (slamWitch != -1)
            {
                // ====================================================
                // v5.5 (reporte owner): LA WITCH ESTAMPADA QUEDA
                // CONGELADA CONTRA LA PARED el tiempo correspondiente
                // (como los SI, cuyo stun del último golpe les dura
                // ~2s tras el slam) — antes el Metal_WitchRelease la
                // descongelaba AL INSTANTE y era la única que no pagaba
                // el estampado. Se restaura SOLO su grupo de colisión
                // (que no estorbe) y el release COMPLETO (movetype +
                // estatua + estrellas) llega con el timer autonomo.
                // ====================================================
                if (g_iMetalWitchColGroup[client] > 0 && IsValidEntity(slamWitch))
                    SetEntProp(slamWitch, Prop_Data, "m_CollisionGroup",
                               g_iMetalWitchColGroup[client]);
                g_iMetalWitchColGroup[client] = -1;

                if (IsValidEntity(slamWitch))
                {
                    // estatua re-afirmada + el tiempo correspondiente
                    Metal_WitchFreeze(slamWitch);
                    Sonic_WitchStun(slamWitch, METAL_WITCH_WALLSTUN_KEEP);

                    // release diferido AUTONOMO: captura el estado de
                    // ESA witch en el DataPack (no usa los slots
                    // por-cliente, que un re-catch entremedio pisaria)
                    DataPack wpack = new DataPack();
                    wpack.WriteCell(EntIndexToEntRef(slamWitch));
                    wpack.WriteCell(GetClientUserId(client));
                    wpack.WriteCell(g_iMetalWitchSavedMT[client]);
                    wpack.WriteCell(g_bMetalWitchHadFrozen[client] ? 1 : 0);
                    CreateTimer(METAL_WITCH_WALLSTUN_KEEP, T_MetalWitchWallRelease,
                                wpack, TIMER_FLAG_NO_MAPCHANGE);

                    // los slots por-cliente quedan libres YA
                    g_iMetalWitchSavedMT[client]    = -1;
                    g_iMetalWitchTarget[client]     = 0;
                    g_bMetalWitchHadFrozen[client]  = false;
                }
                else
                    Metal_WitchRelease(client, slamWitch, false);
            }
            Metal_ReleaseGrabbed(client, false);

            // v5.0: fuera grupo DEBRIS + slot de la embestida (por suelo)
            Metal_DashColExit(client);
            Speed_StackSet(client, SPEED_STACK_METAL_DASH, 0.0);
            SetEntityRenderColor(client, 255, 255, 255, 255);
            Metal_AvatarTintReset(client);
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            SetEntityMoveType(client, MOVETYPE_WALK);
            SetEntProp(client, Prop_Send, "m_iFOV", 0);
            SetEntProp(client, Prop_Send, "m_iFOVStart", 0);
            Metal_StopLoopSound(client);
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, outVel);

            g_iMetalChargeState[client]       = METAL_STATE_IDLE;
            g_iMetalGrabbedTarget[client]     = -1;
            g_fMetalAccumulatedDragDmg[client] = 0.0;
            g_iMetalSlamHitsFired[client]     = 0;

            PrintCenterText(client, "¡Estampado! Infectado aturdido contra la pared.");
        }
        return;
    }

    // ---- ESTADO 5: BOUNCE (rebote sin infectado: slide + 1.4s GMod) ----
    if (state == METAL_STATE_BOUNCE)
    {
        float bElapsed = now - g_fMetalBounceStart[client];

        // v4.0: primeros 0.25s = slide físico del golpe (la velocidad del
        // rebote se integra de verdad, como el SetVelocity del GMod);
        // después, recuperación dura con lagged 0 (OM_NoMovement).
        if (bElapsed >= METAL_BOUNCE_SLIDE)
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);

        if (bElapsed >= METAL_BOUNCE_STUN)
        {
            SetEntityMoveType(client, MOVETYPE_WALK);
            SetEntityRenderColor(client, 255, 255, 255, 255);
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
            g_iMetalChargeState[client] = METAL_STATE_IDLE;
            PrintCenterText(client, "Recuperado del rebote.");
        }
        return;
    }
}

// ============================================================
//  v4.1: HELPERS DE ASSETS REALES DEL MOD (VPK "om_")
// ============================================================

// v5.0: devuelve el tinte normal de las copias R/L del avatar (fin del
// parpadeo rojo del windup por cualquiera de sus caminos)
void Metal_AvatarTintReset(int client)
{
    int avR = EntRefToEntIndex(g_iMetalAvatar[client]);
    if (avR > 0 && IsValidEntity(avR))
    {
        SetEntityRenderMode(avR, RENDER_NORMAL);
        SetEntityRenderColor(avR, 255, 255, 255, 255);
    }
    int avL = EntRefToEntIndex(g_iMetalAvatarL[client]);
    if (avL > 0 && IsValidEntity(avL))
    {
        SetEntityRenderMode(avL, RENDER_NORMAL);
        SetEntityRenderColor(avL, 255, 255, 255, 255);
    }
}

// Corta el loop eléctrico en TODOS sus nombres/canales (v4.0 cortaba solo
// electric_loop.wav; v4.1 emite el del mod en SNDCHAN_STATIC + fallback).
void Metal_StopLoopSound(int client)
{
    // ---- cortes clasicos por canal+sample (inmediato) ----
    // v5.9: electric_loop ahora también se corta en SNDCHAN_STATIC (su
    // nuevo canal de emisión) ADEMÁS del AUTO viejo (por si quedó una
    // instancia de un emit v5.8- en el canal que el motor eligio).
    StopSound(client, SNDCHAN_STATIC, "om/metal/metalchargeloopsound.wav");
    StopSound(client, SNDCHAN_STATIC, "ambient/machines/electric_loop.wav");
    StopSound(client, SNDCHAN_AUTO,   "ambient/machines/electric_loop.wav");

    // v5.9 REFUERZO: el stop EXPLÍCITO con el flag SND_STOP del engine
    // a cada cliente humano (identico paquete que el StopSound clasico,
    // pero enviado por-cliente: cubre cualquier ruta interna distinta
    // del EmitSoundToAll y no cuesta nada — se invoca una vez por fin de
    // carga).
    for (int i = 1; i <= MaxClients; i++)
    {
        // v3.77.79: el host de modo solo es fake — el stop también le llega
        if (!IsClientInGame(i) || (IsFakeClient(i) && !Sonic_IsSoloHost(i))) continue;
        EmitSoundToClient(i, "om/metal/metalchargeloopsound.wav", client, SNDCHAN_STATIC, _, SND_STOP);
        EmitSoundToClient(i, "ambient/machines/electric_loop.wav", client, SNDCHAN_STATIC, _, SND_STOP);
        EmitSoundToClient(i, "ambient/machines/electric_loop.wav", client, SNDCHAN_AUTO, _, SND_STOP);
    }

    // v5.9 DOBLE GOLPE DIFERIDO: re-stop a los 0.25s. Reporte del owner:
    // "cuando la habilidad del dash termina el sonido del deslizamiento
    // sigue sonando no se detiene (esto no ocurre si este impacta contra
    // algo)". El stop ya corria en TODOS los caminos de fin — pero con
    // impacto temprano el canal tenía UNA sola instancia y el stop la
    // mataba, mientras que al agotarse los 8s el watchdog había
    // re-emitido el loop 2-3 veces y en algunos clientes quedaban
    // restos sonando (wavs con cue de loop horneada re-emitidos sobre
    // el mismo canal no siempre se reemplazan: se APILAN, y cada resto
    // solo muere con su propio SND_STOP). El watchdog v5.9 ya hace
    // STOP+EMIT (ver abajo) y este re-stop diferido mata cualquier cosa
    // que aún así sobreviva. SND_STOP sobre un sonido que no suena es
    // un no-op silencioso: reintentar es gratis.
    CreateTimer(0.25, T_MetalLoopRestop, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

// v5.9: el re-stop diferido (NUNCA crea otro timer — llamaria al loop
// infinito). Solo si Metal sigue vivo, en juego y SIN una carga nueva
// arrancada (imposible por cooldown, pero defensivo: no cortarle el
// loop fresco a una carga recien iniciada).
public Action T_MetalLoopRestop(Handle timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || client > MaxClients || !IsClientInGame(client))
        return Plugin_Stop;
    if (g_iMetalChargeState[client] != METAL_STATE_IDLE)
        return Plugin_Stop;

    StopSound(client, SNDCHAN_STATIC, "om/metal/metalchargeloopsound.wav");
    StopSound(client, SNDCHAN_STATIC, "ambient/machines/electric_loop.wav");
    StopSound(client, SNDCHAN_AUTO,   "ambient/machines/electric_loop.wav");
    for (int i = 1; i <= MaxClients; i++)
    {
        // v3.77.79: el host de modo solo es fake — el stop también le llega
        if (!IsClientInGame(i) || (IsFakeClient(i) && !Sonic_IsSoloHost(i))) continue;
        EmitSoundToClient(i, "om/metal/metalchargeloopsound.wav", client, SNDCHAN_STATIC, _, SND_STOP);
        EmitSoundToClient(i, "ambient/machines/electric_loop.wav", client, SNDCHAN_STATIC, _, SND_STOP);
        EmitSoundToClient(i, "ambient/machines/electric_loop.wav", client, SNDCHAN_AUTO, _, SND_STOP);
    }
    return Plugin_Stop;
}

// Mata el icono de windup (transición a dash / cancel / reset / muerte).
static void Metal_KillWindupIcon(int client)
{
    int icon = EntRefToEntIndex(g_iMetalWindupIcon[client]);
    if (icon > MaxClients && IsValidEntity(icon))
        AcceptEntityInput(icon, "Kill");
    g_iMetalWindupIcon[client] = INVALID_ENT_REFERENCE;
}

// Crea un env_sprite con material del VPK. Devuelve entref (o INVALID).
static int Metal_SpawnSprite(const float pos[3], const char[] mat,
                             const char[] color, float scale)
{
    int ent = CreateEntityByName("env_sprite");
    if (ent == -1) return INVALID_ENT_REFERENCE;

    char buf[16];
    FloatToString(scale, buf, sizeof(buf));

    DispatchKeyValue(ent, "model", mat);
    DispatchKeyValue(ent, "rendercolor", color);
    DispatchKeyValue(ent, "renderamt", "255");
    DispatchKeyValue(ent, "scale", buf);
    DispatchKeyValue(ent, "GlowProxySize", "0.0");
    DispatchSpawn(ent);
    TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
    return EntIndexToEntRef(ent);
}

// Destello breve (impacto / catch / detonación) con el arte REAL del mod.
static void Metal_FxFlash(const float pos[3], const char[] mat,
                          float scale, float life)
{
    int ent = Metal_SpawnSprite(pos, mat, "255 255 255", scale);
    if (ent == INVALID_ENT_REFERENCE) return;
    CreateTimer(life, T_Metal_FxKill, ent);
}

public Action T_Metal_FxKill(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(ref);
    if (ent > MaxClients && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Arcos electricos amarillos alrededor de pos (port del efecto
// metal_om_Eletricity del GMod: 4 puntos radio 20-32 + jitter 4, vida
// 0.15s, Color(255,255,0)).
static void Metal_ElectricArcs(const float pos[3])
{
    if (g_iMetalBeam == 0) return;

    float pts[4][3];
    for (int i = 0; i < 4; i++)
    {
        float ang = DegToRad(float(i) * 90.0);
        pts[i][0] = pos[0] + Cosine(ang) * 26.0 + GetRandomFloat(-6.0, 6.0);
        pts[i][1] = pos[1] + Sine(ang) * 26.0 + GetRandomFloat(-6.0, 6.0);
        pts[i][2] = pos[2] + 36.0 + GetRandomFloat(-18.0, 18.0);
    }

    int color[4] = {255, 255, 0, 230};
    for (int i = 0; i < 4; i++)
    {
        TE_SetupBeamPoints(pts[i], pts[(i + 1) % 4], g_iMetalBeam, 0, 0, 0,
                           0.15, 5.0, 1.0, 0, 0.0, color, 0);
        TE_SendToAll();
    }
}

// ============================================================
//  v6.0: LA TORMENTA ELÉCTRICA DEL DESTRUCTIVE — la capa de
//  particulas del pedido del owner (2026-10-15). Receta
//  info_particle_system + auto-kill por OnUser1 (cero handles
//  vivos): el MISMO patron del flame_blue del airstrike y del
//  ChampFX_Particle del pet_fusion de ESTE server (particulas ya
//  montadas y comprobadas) y de la capa Blaze_FX v2.2 del suite.
//  (Los #define METAL_FX_* viven arriba, con los globals — las
//  macros son posicionales en spcomp y OnMapStart las usa antes.)
// ============================================================

// los 3 arcos de la tormenta de la victima (base + XXL + XXL2)
static const char g_sMetalArcFx[3][18] = {
    "efx_arc_new1",        // la base
    "efx_arc_new1_XXL",    // la grande
    "efx_arc_new1_XXL2"    // la grande 2
};

// registra el nombre en la tabla ParticleEffectNames del motor (patron
// Blaze_ParticlePrecache / Knux v63): no-op si ya esta (las stock ya
// viven ahi; las custom las traen los VPKs/manifests del server).
static void Metal_ParticlePrecache(const char[] name)
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

// particula one-shot con auto-kill por OnUser1 (CERO handles).
static void Metal_FxParticleLife(const float pos[3], const float ang[3],
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

// [F1] LA LLAMA AZUL — flame_blue PARENTADA al torso de Metal mientras
// dura la embestida. El tope OnUser1 es SOLO de seguridad: cada camino
// de fin la mata ANTES vía Metal_FxFlameStop.
static void Metal_FxFlameStart(int client)
{
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    if (g_cvMetalFXCharge != null && !g_cvMetalFXCharge.BoolValue) return;

    // si quedaba una de una carga anterior (imposible por los stops,
    // defensivo), fuera YA — nunca dos llamas vivas
    Metal_FxFlameStop(client);

    float pos[3], ang[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    pos[2] += METAL_FX_TORSO_Z;

    int particle = CreateEntityByName("info_particle_system");
    if (particle <= 0 || !IsValidEntity(particle)) return;

    DispatchKeyValue(particle, "effect_name", METAL_FX_FLAME_BLUE);
    DispatchSpawn(particle);
    ActivateEntity(particle);
    TeleportEntity(particle, pos, ang, NULL_VECTOR);

    // parentada al cuerpo: la llama sigue a Metal a 750 uu/s (el patron
    // del flame_blue del airstrike, PARENTADA al proyectil en vuelo)
    SetVariantString("!activator");
    AcceptEntityInput(particle, "SetParent", client);

    AcceptEntityInput(particle, "Start");

    char io[96];
    Format(io, sizeof(io), "OnUser1 !self:kill::%.1f:1", METAL_FX_FLAME_LIFE);
    SetVariantString(io);
    AcceptEntityInput(particle, "AddOutput");
    AcceptEntityInput(particle, "FireUser1");

    g_iMetalDashFlameRef[client] = EntIndexToEntRef(particle);
}

// ... y MUERE cuando Metal se detiene: estampado / rebote / drop por
// cap / timeout del reloj / muerte-desconexion-mapa (ResetState).
static void Metal_FxFlameStop(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (g_iMetalDashFlameRef[client] == 0) return;

    int particle = EntRefToEntIndex(g_iMetalDashFlameRef[client]);
    if (particle > MaxClients && IsValidEntity(particle))
    {
        AcceptEntityInput(particle, "Stop");
        AcceptEntityInput(particle, "Kill");
    }
    g_iMetalDashFlameRef[client] = 0;
}

// [F2] LOS ARCOS DE LA VICTIMA — "mientras lleva a la victima efx_arc_
// new1, efx_arc_new1_XXL y efx_arc_new1_XXL2": las TRES parentadas al
// cuerpo arrastrado (cliente especial o witch) TODO el arrastre. Mueren
// en Metal_FxArcsStop: la suelta universal (Metal_ReleaseGrabbed) y el
// arranque del estampado (Metal_BeginWallSlam).
static void Metal_FxArcsStart(int client, int victim)
{
    if (client < 1 || client > MaxClients) return;
    if (g_cvMetalFXCharge != null && !g_cvMetalFXCharge.BoolValue) return;
    if (victim <= 0 || !IsValidEntity(victim)) return;

    // nunca dos tormentas (un catch inmediato a una suelta del mismo
    // frame): la anterior fuera YA
    Metal_FxArcsStop(client);

    float pos[3];
    if (victim <= MaxClients) GetClientAbsOrigin(victim, pos);
    else                      GetEntPropVector(victim, Prop_Data, "m_vecOrigin", pos);
    float ang[3] = { 0.0, 0.0, 0.0 };

    // la tormenta envuelve el cuerpo: torso / pecho alto / cabeza
    float arcZ[3];
    arcZ[0] = 34.0; arcZ[1] = 42.0; arcZ[2] = 50.0;

    for (int i = 0; i < 3; i++)
    {
        float ap[3];
        ap[0] = pos[0]; ap[1] = pos[1]; ap[2] = pos[2] + arcZ[i];

        int particle = CreateEntityByName("info_particle_system");
        if (particle <= 0 || !IsValidEntity(particle)) continue;

        DispatchKeyValue(particle, "effect_name", g_sMetalArcFx[i]);
        DispatchSpawn(particle);
        ActivateEntity(particle);
        TeleportEntity(particle, ap, ang, NULL_VECTOR);

        SetVariantString("!activator");
        AcceptEntityInput(particle, "SetParent", victim);

        AcceptEntityInput(particle, "Start");

        char io[96];
        Format(io, sizeof(io), "OnUser1 !self:kill::%.1f:1", METAL_FX_ARC_LIFE);
        SetVariantString(io);
        AcceptEntityInput(particle, "AddOutput");
        AcceptEntityInput(particle, "FireUser1");

        g_iMetalArcRefs[client][i] = EntIndexToEntRef(particle);
    }
}

// fuera los arcos de la victima (la suelta universal + el estampado).
static void Metal_FxArcsStop(int client)
{
    if (client < 1 || client > MaxClients) return;
    for (int i = 0; i < 3; i++)
    {
        if (g_iMetalArcRefs[client][i] == 0) continue;
        int particle = EntRefToEntIndex(g_iMetalArcRefs[client][i]);
        if (particle > MaxClients && IsValidEntity(particle))
        {
            AcceptEntityInput(particle, "Stop");
            AcceptEntityInput(particle, "Kill");
        }
        g_iMetalArcRefs[client][i] = 0;
    }
}

// [F3] EL ESTAMPE — "cuando este impacte a la pared con el enemigo
// generara el efecto electrical_arc_01_system": one-shot en el punto
// de impacto, empujado de la pared y mirando HACIA FUERA del muro.
static void Metal_FxWallArc(const float hitPos[3], const float hitNrm[3])
{
    if (g_cvMetalFXCharge != null && !g_cvMetalFXCharge.BoolValue) return;

    float pos[3], nrm[3], ang[3];
    nrm[0] = hitNrm[0]; nrm[1] = hitNrm[1]; nrm[2] = hitNrm[2];
    pos[0] = hitPos[0] + nrm[0] * 12.0;
    pos[1] = hitPos[1] + nrm[1] * 12.0;
    pos[2] = hitPos[2] + nrm[2] * 12.0;
    GetVectorAngles(nrm, ang);

    Metal_FxParticleLife(pos, ang, METAL_FX_ARC_WALL, METAL_FX_WALL_LIFE);
}

// v4.0: dirección de movimiento HORIZONTAL normalizada de la mira de
// Metal (equivalente al forwardmove del GMod, que el motor proyecta al
// plano del suelo). Fallback al yaw del cuerpo si mira vertical: la
// embestida NUNCA pierde fuerza por mirar arriba/abajo.
void Metal_GetMoveDir(int client, float dir[3])
{
    float ang[3], fwd[3];
    GetClientEyeAngles(client, ang);
    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);

    float len = SquareRoot(fwd[0] * fwd[0] + fwd[1] * fwd[1]);
    if (len < 0.05)
    {
        GetClientAbsAngles(client, ang);
        GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
        len = SquareRoot(fwd[0] * fwd[0] + fwd[1] * fwd[1]);
        if (len < 0.05)
            len = 1.0;
    }

    dir[0] = fwd[0] / len;
    dir[1] = fwd[1] / len;
    dir[2] = 0.0;
}

// v4.0 GMod: un golpe del wall slam (los 3 van temporizados). Cada golpe
// re-stunea al infectado 2s CON efectos (additionalstun_slam x 0.33), le
// pega 9.75 (slamDamage x 0.33) a través del OM_Stun, le cuesta a Metal
// 13 de auto-dano (MetalSelfDamageSlam x 0.33) y lo re-sujeta contra la
// pared (GMod: SetPos(hitPos + normal x pushDist)).
// v5.3 punto 3: rama WITCH — mismo golpe con operaciones de entidad
// (dano directo SDKHooks + teleport; sin OM_Stun que es player-only).
void Metal_SlamHit(int client)
{
    // ---- rama WITCH ----
    int witch = (g_iMetalWitchTarget[client] != 0) ? Metal_GetWitchTarget(client) : -1;
    if (witch != -1)
    {
        SDKHooks_TakeDamage(witch, client, client, METAL_SLAM_DMG_ENEMY, DMG_OM_CLUB);
        SetEntityMoveType(witch, MOVETYPE_NONE);   // re-congelar tras el dano
        Metal_WitchFreeze(witch);   // v5.4: estatua re-afirmada en cada golpe del estampado

        // Re-sujetar contra la pared (45u de la pared: es más grande)
        float wPos[3], wHold[3], zero[3];
        GetEntPropVector(witch, Prop_Data, "m_vecOrigin", wPos);
        wHold[0] = g_vMetalSlamWallPos[client][0] + g_vMetalSlamWallNrm[client][0] * 45.0;
        wHold[1] = g_vMetalSlamWallPos[client][1] + g_vMetalSlamWallNrm[client][1] * 45.0;
        wHold[2] = wPos[2];
        zero[0] = 0.0; zero[1] = 0.0; zero[2] = 0.0;
        TeleportEntity(witch, wHold, NULL_VECTOR, zero);

        // Auto-dano de Metal por golpe (igual que un especial)
        float dmgPerHitW = Metal_IsLMS() ? METAL_WALL_SLAM_DMG_LMS : METAL_WALL_SLAM_DMG;
        Metal_TakeSelfDamage(client, dmgPerHitW);

        // FX del golpe (sonido + chispas + destello en el punto de impacto)
        float fxPosW[3];
        fxPosW[0] = g_vMetalSlamWallPos[client][0];
        fxPosW[1] = g_vMetalSlamWallPos[client][1];
        fxPosW[2] = g_vMetalSlamWallPos[client][2];
        if (g_bMetalSndSlam)
            EmitSoundToAll("om/metal/wallslam.wav", client, _, METAL_SND_LEVEL);
        else
            EmitSoundToAll("player/tank/hit/hulk_punch_2.wav", client, _, METAL_SND_LEVEL);
        TE_SetupSparks(fxPosW, NULL_VECTOR, 6, 3);
        TE_SendToAll();
        if (g_bMetalAssets)
        {
            Metal_FxFlash(fxPosW, "materials/om/metal_impact.vmt", 0.9, 0.3);
            Metal_ElectricArcs(fxPosW);
        }
        if (g_iMetalSlamHitsFired[client] >= 3)
        {
            if (g_bMetalSndPunch)
                EmitSoundToAll("om/knuckles/punchstun.wav", client, _, METAL_SND_LEVEL);
            if (g_bMetalSndEnd)
                EmitSoundToAll("om/metal/metalchargeend.wav", client, _, METAL_SND_LEVEL);
        }
        return;
    }

    // ---- rama INFECTADO ESPECIAL (cliente) — camino original intacto ----
    int target = g_iMetalGrabbedTarget[client];
    if (!Metal_IsValidClient(target))
        return;

    // Golpe = stun 2s + dano (OM_Stun trae los efectos incluidos)
    // v5.5: boomer letal = mecha (estalla al terminar SU stun)
    OM_Stun(target, METAL_SLAM_STUN_PER_HIT, client,
            Metal_BoomerGuardDamage(target, METAL_SLAM_DMG_ENEMY, client),
            DMG_OM_CLUB, true);

    // Re-sujetar contra la pared, mirando a Metal
    float tPos[3], hold[3], tAng[3], zero[3];
    GetClientAbsOrigin(target, tPos);
    hold[0] = g_vMetalSlamWallPos[client][0] + g_vMetalSlamWallNrm[client][0] * 30.0;
    hold[1] = g_vMetalSlamWallPos[client][1] + g_vMetalSlamWallNrm[client][1] * 30.0;
    hold[2] = tPos[2];

    float eyeAng[3];
    GetClientEyeAngles(client, eyeAng);
    tAng[0] = 0.0;
    tAng[1] = eyeAng[1] + 180.0;
    tAng[2] = 0.0;
    zero[0] = 0.0; zero[1] = 0.0; zero[2] = 0.0;
    TeleportEntity(target, hold, tAng, zero);

    // Auto-dano de Metal por golpe (13 normal / 5 en LMS, mercy del suite)
    float dmgPerHit = Metal_IsLMS() ? METAL_WALL_SLAM_DMG_LMS : METAL_WALL_SLAM_DMG;
    Metal_TakeSelfDamage(client, dmgPerHit);

    // FX del golpe (GMod: punch sound + chispas en el punto de impacto)
    float fxPos[3];
    fxPos[0] = g_vMetalSlamWallPos[client][0];
    fxPos[1] = g_vMetalSlamWallPos[client][1];
    fxPos[2] = g_vMetalSlamWallPos[client][2];
    // v4.1: wallslam.wav REAL del mod (GMod: WallSlam en cada golpe) +
    // destello con el arte de impacto del punch del mod + arcos.
    if (g_bMetalSndSlam)
        EmitSoundToAll("om/metal/wallslam.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("player/tank/hit/hulk_punch_2.wav", client, _, METAL_SND_LEVEL);
    TE_SetupSparks(fxPos, NULL_VECTOR, 6, 3);
    TE_SendToAll();
    if (g_bMetalAssets)
    {
        Metal_FxFlash(fxPos, "materials/om/metal_impact.vmt", 0.9, 0.3);
        Metal_ElectricArcs(fxPos);

        // v4.2 (GMod l.1318-1320): el PunchImpact sale del CUERPO DE METAL
        // (ply:GetPos()+30z) en cada golpe, además del destello en la pared
        float mBody[3];
        GetClientAbsOrigin(client, mBody);
        mBody[2] += 30.0;
        Metal_FxFlash(mBody, "materials/om/metal_impact.vmt", 0.7, 0.35);
    }

    // v4.2 (GMod l.1410-1432): el 3er golpe REMATA con punchstun.wav
    // (OM/knuckles) + MetalChargeEnd.wav, como el mod. El stun.wav de cada
    // golpe ya lo emite el OM_Stun de arriba (GMod l.1384/1397/1411).
    if (g_iMetalSlamHitsFired[client] >= 3)
    {
        if (g_bMetalSndPunch)
            EmitSoundToAll("om/knuckles/punchstun.wav", client, _, METAL_SND_LEVEL);
        if (g_bMetalSndEnd)
            EmitSoundToAll("om/metal/metalchargeend.wav", client, _, METAL_SND_LEVEL);
    }
}

// ============================================================
// v5.2 ajuste 1: WATCHDOG DE ATASCOS (DASH/DRAGGING). Devuelve true
// si ACABA de liberar la carga (el caller hace return inmediato).
// La embestida debería ir a 750 uu/s: si la velocidad real no supera
// METAL_STUCK_SPEED de forma CONTINUA durante METAL_STUCK_TIME, algo
// no-pared (enemigo enorme, borde, prop del mapa) lo está taponando —
// liberar limpio (fin natural con frenado suave) en vez de esperar
// los 8s enteros atascado contra el obstaculo.
// ============================================================
bool Metal_StuckCheck(int client, float now)
{
    if (Metal_Speed2D(client) < METAL_STUCK_SPEED)
    {
        if (g_fMetalStuckSince[client] <= 0.0)
        {
            g_fMetalStuckSince[client] = now;
            return false;
        }
        if (now - g_fMetalStuckSince[client] >= METAL_STUCK_TIME)
        {
            g_fMetalStuckSince[client] = 0.0;
            // v5.3 punto 4: ANTES de liberar la carga, DESPEGAR al objetivo
            // (teleport DETRÁS de Metal + restaurar su colisión) — el
            // pasillo por delante queda libre al instante y Metal ya no
            // pelea contra su capsula al salir de la embestida
            Metal_UnwedgeDragTarget(client);
            Metal_CancelCharge(client);
            PrintCenterText(client, "Embestida liberada (atascado).");
            return true;
        }
        return false;
    }
    g_fMetalStuckSince[client] = 0.0;   // volvió a moverse: reiniciar
    return false;
}

// v5.8: EL ARRASTRADO MURIÓ EN SUS MANOS — LA EMBESTIDA CONTINUA.
// Pedido del owner: "si metal durante el dash mata al objetivo que
// tiene llevándose el dash no se detendra". Antes este camino era
// Metal_CancelCharge (la carga moria con el objetivo); ahora vuelve al
// ESTADO DASH puro y sigue: misma velocidad, puede ATRAPAR OTRO
// objetivo, rebota contra pared y termina sola al agotar su reloj.
// Se invoca SOLO desde el estado DRAGGING (el arrastre); el WALL_SLAM
// (estampado = modo embiste final del owner) NO pasa por aquí — su
// secuencia de 3 golpes sigue su curso como siempre.
void Metal_DragTargetDied(int client)
{
    // liberar las referencias SIN restaurar al muerto (soft: el cuerpo
    // ya no necesita colisión/movetype) y SIN tocar NADA del dash
    // (grupo DEBRIS de Metal, slot 750 del stack, FOV, loop, lagged):
    // Metal_ReleaseGrabbed cubre especial Y witch en un solo call
    Metal_ReleaseGrabbed(client, false);
    g_fMetalAccumulatedDragDmg[client] = 0.0;

    // de vuelta al DASH — conserva su reloj (el limite de seguridad
    // del arrastre sigue corriendo: NO hay embestida infinita)
    g_iMetalChargeState[client] = METAL_STATE_DASH;
    g_fMetalStuckSince[client] = 0.0;

    // FX de despedida + aviso (chispas donde iba el objetivo)
    float mPos[3];
    GetClientAbsOrigin(client, mPos);
    mPos[0] += 0.0; mPos[1] += 0.0; mPos[2] += 45.0;
    TE_SetupSparks(mPos, NULL_VECTOR, 8, 4);
    TE_SendToAll();
    PrintCenterText(client, "Objetivo eliminado! La embestida continúa...");
}

// v4.0 GMod: ATRAPA al infectado (el Mutaul_OMStunCode del catch): stun
// de 0.8 x 2 = 1.6s + dano 4 + chispas. La embestida NO termina aquí:
// el GMod mantiene la velocidad de carga ARRASTRANDO al enemigo por
// delante (el v3.6 frenaba a 600 y exigiendo W: fuente del "no va bn").
void Metal_BeginDrag(int client, int target, float now)
{
    g_iMetalGrabbedTarget[client]      = target;
    g_iMetalChargeState[client]        = METAL_STATE_DRAGGING;
    g_fMetalNextDragTick[client]       = now + METAL_DRAG_TICK;
    g_fMetalAccumulatedDragDmg[client] = 0.0;
    g_fMetalStateEndTime[client]       = now + 10.0; // limite de seguridad

    // ============================================================
    // v5.3 punto 4: el ARRASTRADO también a DEBRIS mientras dura el
    // arrastre — su capsula deja de pelear contra la de Metal en los
    // pasillos angostos (la fuente del "aún sigo atascándome contra los
    // enemigos que envisto"). Se restaura en TODOS los caminos de
    // suelta (ReleaseGrabbed cubre drop/slam/cancel/atasco/muerte).
    // ============================================================
    if (g_iMetalVictimColGroup[client] <= 0)
        g_iMetalVictimColGroup[client] = GetEntProp(target, Prop_Data, "m_CollisionGroup");
    SetEntProp(target, Prop_Data, "m_CollisionGroup", METAL_DASH_COLGROUP);
    // ============================================================
    // v5.2 ajuste 7: EL CATCH STAGGERA AL OPONENTE Y LIBERA SU CONTROL
    // AGARRADO — bug del owner: "metal se ha llevado a un jokey de un
    // survivor y resulta que aunque se lo llevo este siguio montado
    // aun si no estaba su cuerpo éspecificamente hay". El v5.0 solo
    // OM_Stuneaba y teletransportaba al jockey: el ESTADO de ride
    // segua vivo en el survivor (montado fantasma). Ahora:
    //   (a) si el oponente tenía a alguien agarrado (jockey montado,
    //       hunter ensartado, smoker arrastrando, charger cargando):
    //       PinRelease_Cleanse(victima) = el camino COMPLETO del motor
    //       (L4D2_Jockey_EndRide etc. — desmonta de verdad, corta la
    //       música de agarre y STAGGERA al atacante anti re-grab) —
    //       "para que libere todos sus efectos de control (como
    //       nativamente hace)";
    //   (b) si no tenía a nadie: SIStagger_Auto directo (el interrupt
    //       vanilla del impacto — un charger a media carga o un tank
    //       a media swing se cortan en seco).
    // Después el OM_Stun de siempre lo deja congelado y quieto en el
    // sitio mientras Metal lo arrastra ("como está congelado y quieto
    // xq supongo que el stun de metal lo forza a estar en un mismo
    // lugar no?" — si: lagged 0 + anim pausada + teleport de arrastre).
    // ============================================================
    float mPos[3];
    GetClientAbsOrigin(client, mPos);
    int pinVictim = Metal_ControlVictimOf(target);
    if (pinVictim > 0)
        PinRelease_Cleanse(pinVictim);
    else
        SIStagger_Auto(target, client, mPos);

    // STUN del catch (1.6s) — OM_Stun trae el freeze + los EFECTOS
    // v5.5: el boomer letal no muere aquí — mecha y estalla al final
    OM_Stun(target, METAL_CATCH_STUN, client,
            Metal_BoomerGuardDamage(target, METAL_CATCH_DMG, client), DMG_OM_CLUB, true);

    // Zap eléctrico + chispas del catch (GMod: Eletricsound + 3x
    // StunstickImpact sobre el enemigo). v4.1: Eletricsound.wav REAL del
    // mod (antes zap1 de HL2) + destello con el arte de electricidad +
    // arcos alrededor de la victima (metal_om_Eletricity del GMod).
    float tPos[3];
    GetClientAbsOrigin(target, tPos);
    float flashPos[3];
    flashPos[0] = tPos[0];
    flashPos[1] = tPos[1];
    flashPos[2] = tPos[2] + 40.0;
    TE_SetupSparks(flashPos, NULL_VECTOR, 6, 3);
    TE_SendToAll();

    if (g_bMetalSndElec)
        EmitSoundToAll("om/metal/eletricsound.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("ambient/energy/zap1.wav", client, _, METAL_SND_LEVEL);
    if (g_bMetalAssets)
    {
        Metal_FxFlash(flashPos, "materials/om/metal_elec.vmt", 1.0, 0.4);
        Metal_ElectricArcs(tPos);
    }

    // v6.0: LA TORMENTA SOBRE LA VICTIMA — "mientras lleva a la victima
    // efx_arc_new1, efx_arc_new1_XXL y efx_arc_new1_XXL2": las 3
    // parentadas al atrapado TODO el arrastre (mueren en la suelta
    // universal y al arrancar el estampado contra la pared)
    Metal_FxArcsStart(client, target);

    PrintCenterText(client, "Infectado atrapado! Arrastrandolo...");
}

// v4.0: Suelta al infectado porque acumulo 40 HP de dano (no slameo).
// El infectado queda aturdido 3s CON efectos (estrellas + chispas + tinte
// + freeze: el paquete del OM_Stun).
void Metal_DropByDamageCap(int client, int target)
{
    if (Metal_IsValidClient(target))
    {
        OM_Stun(target, METAL_DROP_STUN_TIME, client, 0.0, DMG_OM_CLUB, true);

        // ========================================================
        // v5.3 punto 4: FLING hacia delante al soltarlo por cap de dano —
        // sale despedido de la capsula de Metal en vez de quedarse
        // pegado en medio del pasillo angosto (con el stun activo el
        // impulso se integra cuando expira, y ya no bloquea la salida)
        // ========================================================
        float dropDir[3], dropVel[3];
        Metal_GetMoveDir(client, dropDir);
        dropVel[0] = dropDir[0] * METAL_DRAG_RELEASE_FLING;
        dropVel[1] = dropDir[1] * METAL_DRAG_RELEASE_FLING;
        dropVel[2] = 250.0;
        TeleportEntity(target, NULL_VECTOR, NULL_VECTOR, dropVel);
    }

    // v5.3 punto 4: devolver su grupo de colisión original (estaba en
    // DEBRIS anti-atasco) sin cortar el stun de la suelta
    Metal_ReleaseGrabbed(client, false);

    // v5.0: fuera grupo DEBRIS + slot del stack: la embestida termina
    // (frenado suave del momentum por suelo)
    Metal_DashColExit(client, METAL_AIR_END_DAMP);
    Speed_StackSet(client, SPEED_STACK_METAL_DASH, 0.0);
    SetEntityRenderColor(client, 255, 255, 255, 255);
    Metal_AvatarTintReset(client);
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntityMoveType(client, MOVETYPE_WALK);
    SetEntProp(client, Prop_Send, "m_iFOV", 0);
    SetEntProp(client, Prop_Send, "m_iFOVStart", 0);
    Metal_StopLoopSound(client);
    Metal_FxFlameStop(client);   // v6.0: la carga termino = Metal se detuvo

    g_iMetalChargeState[client]       = METAL_STATE_IDLE;
    g_iMetalGrabbedTarget[client]     = -1;
    g_fMetalAccumulatedDragDmg[client] = 0.0;

    PrintCenterText(client, "Carga terminada. Infectado aturdido %.0fs.", METAL_DROP_STUN_TIME);
}

// v4.0: Inicia el wall slam GMod (3 golpes temporizados a 0.167/0.417/
// 0.717s, fin a 1.05s). Captura la pared de verdad (posición + normal)
// para pinear al infectado contra ella y para el empuje final de Metal.
void Metal_BeginWallSlam(int client, float now)
{
    g_iMetalChargeState[client]   = METAL_STATE_WALL_SLAM;
    g_iMetalSlamHitsFired[client] = 0;
    g_fMetalSlamStartTime[client] = now;

    // v6.0: EL FIN DEL VIAJE — Metal SE DETIENE (la llama azul del torso
    // muere aquí: "el efecto terminara cuando metal se detenga o
    // tecnicamente estrelle a la victima hacia la pared") y la victima
    // deja de ser ARRASTRADA (la tormenta de arcos muere aquí).
    Metal_FxFlameStop(client);
    Metal_FxArcsStop(client);

    // Frenar a Metal de inmediato (venía a 750 uu/s)
    float zero[3] = {0.0, 0.0, 0.0};
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, zero);

    // Pared de verdad (receta Amy v62 con salida de pos/normal)
    float hitPos[3], hitNrm[3];
    if (!Metal_WallTrace(client, hitPos, hitNrm))
    {
        // Defensa (no debería pasar: el dash ya la detecto): ojos + fwd
        float eyePos[3], eyeAng[3], fwd[3];
        GetClientEyePosition(client, eyePos);
        GetClientEyeAngles(client, eyeAng);
        GetAngleVectors(eyeAng, fwd, NULL_VECTOR, NULL_VECTOR);
        hitPos[0] = eyePos[0] + fwd[0] * METAL_WALL_AHEAD;
        hitPos[1] = eyePos[1] + fwd[1] * METAL_WALL_AHEAD;
        hitPos[2] = eyePos[2] + fwd[2] * METAL_WALL_AHEAD;
        hitNrm[0] = -fwd[0];
        hitNrm[1] = -fwd[1];
        hitNrm[2] = 0.0;
    }
    g_vMetalSlamWallPos[client][0] = hitPos[0];
    g_vMetalSlamWallPos[client][1] = hitPos[1];
    g_vMetalSlamWallPos[client][2] = hitPos[2];
    g_vMetalSlamWallNrm[client][0] = hitNrm[0];
    g_vMetalSlamWallNrm[client][1] = hitNrm[1];
    g_vMetalSlamWallNrm[client][2] = hitNrm[2];

    // v6.0: "cuando este impacte a la pared con el enemigo generara el
    // efecto electrical_arc_01_system" — one-shot en el punto de impacto,
    // mirando HACIA FUERA del muro (la particula del pet_fusion v48 de
    // este server). Camino común: cubre el slam de especiales Y de la
    // witch (ambos entran por aquí).
    Metal_FxWallArc(hitPos, hitNrm);

    // Acercar a Metal a la pared (GMod lo teletransporta pegado al muro)
    float mPos[3], near[3], dir[3];
    GetClientAbsOrigin(client, mPos);
    Metal_GetMoveDir(client, dir);
    near[0] = hitPos[0] - dir[0] * 55.0;
    near[1] = hitPos[1] - dir[1] * 55.0;
    near[2] = mPos[2];
    TeleportEntity(client, near, NULL_VECTOR, zero);

    // Pinear al infectado contra la pared (GMod: SetPos(hitPos + normal x
    // pushDist)), mirando a Metal
    int target = g_iMetalGrabbedTarget[client];
    if (Metal_IsValidClient(target))
    {
        float tPos[3], hold[3], tAng[3];
        GetClientAbsOrigin(target, tPos);
        hold[0] = hitPos[0] + hitNrm[0] * 30.0;
        hold[1] = hitPos[1] + hitNrm[1] * 30.0;
        hold[2] = tPos[2];

        float eyeAng[3];
        GetClientEyeAngles(client, eyeAng);
        tAng[0] = 0.0;
        tAng[1] = eyeAng[1] + 180.0;
        tAng[2] = 0.0;
        TeleportEntity(target, hold, tAng, zero);
    }

    // v5.3 punto 3: pinear a la WITCH contra la pared (misma receta con
    // operaciones de entidad — 45u del muro porque es más grande)
    int pinWitch = (g_iMetalWitchTarget[client] != 0) ? Metal_GetWitchTarget(client) : -1;
    if (pinWitch != -1)
    {
        float wPos[3], wHold[3];
        GetEntPropVector(pinWitch, Prop_Data, "m_vecOrigin", wPos);
        wHold[0] = hitPos[0] + hitNrm[0] * 45.0;
        wHold[1] = hitPos[1] + hitNrm[1] * 45.0;
        wHold[2] = wPos[2];
        TeleportEntity(pinWitch, wHold, NULL_VECTOR, zero);
    }

    PrintCenterText(client, "¡Estampando contra la pared!");
    // v4.1: wallbump.wav REAL del mod al clavarse contra la pared
    if (g_bMetalSndBump)
        EmitSoundToAll("om/metal/wallbump.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("player/tank/hit/hulk_punch_1.wav", client, _, METAL_SND_LEVEL);
}

// v4.0 GMod: rebote sin infectado — impulso 250 hacia atras + 1.4s de
// recuperación (OM_NoMovement 1.4s del mod; los primeros 0.25s son slide
// físico real del golpe, después freeze duro).
void Metal_DoBounce(int client)
{
    // v5.0: fuera grupo DEBRIS + slot del stack antes del rebote
    Metal_DashColExit(client);
    Speed_StackSet(client, SPEED_STACK_METAL_DASH, 0.0);

    // Impulso hacia atras (GMod: dir x 200)
    float dir[3], vel[3];
    Metal_GetMoveDir(client, dir);
    vel[0] = -dir[0] * METAL_BOUNCE_SPEED;
    vel[1] = -dir[1] * METAL_BOUNCE_SPEED;
    vel[2] = 150.0;
    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);

    SetEntityRenderColor(client, 255, 255, 255, 255);
    Metal_AvatarTintReset(client);
    SetEntProp(client, Prop_Send, "m_iFOV", 0);
    SetEntProp(client, Prop_Send, "m_iFOVStart", 0);
    Metal_StopLoopSound(client);
    Metal_FxFlameStop(client);   // v6.0: Metal se detuvo contra la pared (sin victima)
    g_iMetalChargeState[client] = METAL_STATE_BOUNCE;
    g_fMetalBounceStart[client] = GetEngineTime();
    g_fMetalStateEndTime[client] = g_fMetalBounceStart[client] + METAL_BOUNCE_STUN;

    PrintCenterText(client, "¡Rebote! Recuperandote %.1fs.", METAL_BOUNCE_STUN);
    // v4.1: wallbump.wav REAL del mod (rebote sin infectado)
    if (g_bMetalSndBump)
        EmitSoundToAll("om/metal/wallbump.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("player/survivor/hit/crowbar_swing_miss1.wav", client, _, METAL_SND_LEVEL);
}

// v3: Busca un infectado especial dentro del radio de agarre
int Metal_FindGrabTarget(int client)
{
    float mPos[3], tPos[3];
    GetClientAbsOrigin(client, mPos);

    int best = -1;
    float bestDist = METAL_GRAB_RADIUS;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_INFECTED) continue;

        GetClientAbsOrigin(i, tPos);
        float dist = GetVectorDistance(mPos, tPos);
        if (dist < bestDist)
        {
            bestDist = dist;
            best = i;
        }
    }
    return best;
}

// ============================================================
// ============================================================
// v5.3 RONDA 3: AVALANCHA DE COMMONS + WITCH EMBESTIBLE +
// ANTI-ATASCO + VIDA MÁXIMA 175
// ============================================================
// ============================================================

// v5.3 punto 2: AVALANCHA — mata a todos los comunes en radio de la
// embestida (llamada cada 0.1s desde DASH y DRAGGING). Un toque = un
// muerto: el v5.2 los ignoraba (solo buscaba CLIENTS infectados) y eran
// puro obstaculo físico en los pasillos angostos.
void Metal_KillCommonsInPath(int client, float now)
{
    if (now < g_fMetalNextCommonKill[client]) return;
    g_fMetalNextCommonKill[client] = now + METAL_COMMON_KILL_TICK;

    float mPos[3], cPos[3];
    GetClientAbsOrigin(client, mPos);

    int ent = -1, killed = 0, fxCount = 0;
    while ((ent = FindEntityByClassname(ent, "infected")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;

        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", cPos);
        if (GetVectorDistance(mPos, cPos) > METAL_COMMON_KILL_RADIUS) continue;

        SDKHooks_TakeDamage(ent, client, client, METAL_COMMON_KILL_DMG, DMG_OM_CLUB);
        killed++;

        // FX en máximo 2 por barrido (en plena horda esto dispara muchisimo)
        if (g_bMetalAssets && fxCount < 2)
        {
            fxCount++;
            float fxPos[3];
            fxPos[0] = cPos[0]; fxPos[1] = cPos[1]; fxPos[2] = cPos[2] + 40.0;
            Metal_FxFlash(fxPos, "materials/om/metal_impact.vmt", 0.6, 0.25);
        }
    }

    // Sonido de impacto con throttle (un solo golpe sonoro por rfaga)
    if (killed > 0 && now >= g_fMetalNextCommonSnd[client])
    {
        g_fMetalNextCommonSnd[client] = now + 0.25;
        if (g_bMetalSndPunch)
            EmitSoundToAll("om/knuckles/punchstun.wav", client, _, METAL_SND_LEVEL);
        else
            EmitSoundToAll("player/survivor/hit/punch_hit1.wav", client, _, METAL_SND_LEVEL);
    }
}

// v5.3 punto 3: la witch viva más cercana dentro del radio de agarre
// (misma esfera de 100u que los especiales — la diferencia es que la
// witch es una ENTIDAD, no un client: por eso el v5.2 jamás la veía)
int Metal_FindWitchTarget(int client)
{
    float mPos[3], tPos[3];
    GetClientAbsOrigin(client, mPos);

    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "witch")) != -1)
    {
        if (!IsValidEntity(ent)) continue;
        if (GetEntProp(ent, Prop_Data, "m_iHealth") <= 0) continue;

        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", tPos);
        if (GetVectorDistance(mPos, tPos) <= METAL_GRAB_RADIUS)
            return ent;
    }
    return -1;
}

// v5.3 punto 3: la witch arrastrada por Metal, como índice de entidad
// (valida el entref contra el serial — si murió y el índice se reciclo,
// no es ella). Devuelve -1 si ya no existe.
int Metal_GetWitchTarget(int client)
{
    if (g_iMetalWitchTarget[client] == 0) return -1;
    int witch = EntRefToEntIndex(g_iMetalWitchTarget[client]);
    if (witch <= MaxClients || !IsValidEntity(witch)) return -1;

    static char cls[16];
    GetEntityClassname(witch, cls, sizeof(cls));
    if (!StrEqual(cls, "witch", false)) return -1;
    return witch;
}

// v5.3 punto 3: ATRAPA a la witch — el equivalente del Metal_BeginDrag
// para entidades: congelada (MOVETYPE_NONE, su movetype original se
// guarda) + DEBRIS en su cuerpo (no tapona el pasillo mientras la
// arrastra) + el dano del catch + los FX electricos de siempre.
// v5.4: EL CONGELADO DE VERDAD para la witch — el "freeze para nextbot"
// que ya usan Tails/Amy/Sonic con ella. Dos capas del recetario del suite:
//   1) FL_FROZEN inmediato y propio (el gate del motor que apaga su IA =
//      ESTATUA; funciona SIEMPRE, sin depender de ningún cvar);
//   2) Sonic_WitchStun (estrellas + el watch de sonic.inc que re-afirma
//      el flag cada 0.1s — la MISMA función que llaman Tails/Amy/Sonic).
// Idempotente: se invoca en el catch, en cada tick del arrastre y en cada
// golpe del estampado (el dano o el motor pueden tirar el flag a mitad).
// OJO: el hadFrozen NO se captura aquí — un re-afirmo con el flag ya
// puesto jamás debe "creer" que la witch venía congelada de antes (se
// captura UNA VEZ en Metal_BeginWitchDrag, antes del primer freeze).
// v5.5: el release diferido de la witch estampada (fin del tiempo
// correspondiente congelada contra la pared). Restaura SU movetype
// original + la estatua (flag solo si la pusimos nosotros + slot de
// estrellas). Si Metal la volvió a atrapar entremedio: no-op.
public Action T_MetalWitchWallRelease(Handle timer, DataPack pack)
{
    pack.Reset();
    int witch     = EntRefToEntIndex(pack.ReadCell());
    int client    = GetClientOfUserId(pack.ReadCell());
    int savedMT   = pack.ReadCell();
    bool hadFrozen = (pack.ReadCell() != 0);
    delete pack;

    if (witch <= MaxClients || !IsValidEntity(witch)) return Plugin_Stop;

    // la volvió a atrapar en esos 2s? no pisar el estado nuevo
    if (client >= 1 && client <= MaxClients && IsClientInGame(client)
        && g_iMetalWitchTarget[client] != 0
        && EntRefToEntIndex(g_iMetalWitchTarget[client]) == witch)
        return Plugin_Stop;

    // estatua fuera: slot de estrellas + flag (solo si lo pusimos nosotros)
    int wslot = Sonic_WitchStunSlotOf(witch);
    if (wslot != -1) Sonic_WitchStunClear(wslot);
    if (!hadFrozen && (GetEntityFlags(witch) & FL_FROZEN) != 0)
        SetEntityFlags(witch, GetEntityFlags(witch) & ~FL_FROZEN);

    // su movetype ORIGINAL (guardado en el catch)
    MoveType mt = view_as<MoveType>(savedMT);
    if (view_as<int>(mt) <= 0) mt = MOVETYPE_WALK;
    SetEntityMoveType(witch, mt);
    return Plugin_Stop;
}

void Metal_WitchFreeze(int witch)
{
    if (witch <= MaxClients || !IsValidEntity(witch)) return;
    if ((GetEntityFlags(witch) & FL_FROZEN) == 0)
        SetEntityFlags(witch, GetEntityFlags(witch) | FL_FROZEN);
    Sonic_WitchStun(witch, METAL_WITCH_STUN_REFRESH);
}

void Metal_BeginWitchDrag(int client, int witch, float now)
{
    g_iMetalGrabbedTarget[client]      = -1;   // no hay cliente agarrado
    g_iMetalWitchTarget[client]        = EntIndexToEntRef(witch);
    g_iMetalWitchColGroup[client]      = GetEntProp(witch, Prop_Data, "m_CollisionGroup");
    g_iMetalWitchSavedMT[client]       = view_as<int>(GetEntityMoveType(witch));
    g_iMetalChargeState[client]        = METAL_STATE_DRAGGING;
    g_fMetalNextDragTick[client]       = now + METAL_DRAG_TICK;
    g_fMetalAccumulatedDragDmg[client] = 0.0;
    g_fMetalStateEndTime[client]       = now + 10.0; // limite de seguridad

    // congelar + anti-atasco en ELLA (en entidades el DEBRIS funciona
    // de verdad: su capsula deja de bloquear el paso angosto)
    SetEntityMoveType(witch, MOVETYPE_NONE);
    SetEntProp(witch, Prop_Data, "m_CollisionGroup", METAL_DASH_COLGROUP);

    // v5.4: congelado COMPLETO — el hadFrozen se captura ANTES de tocar
    // el flag (si venía congelada por otro stun, no la descongelamos al
    // soltarla) y la ESTATUA es de verdad: el MOVETYPE_NONE de arriba
    // solo quieta la física, el FL_FROZEN de Metal_WitchFreeze apaga su
    // IA (el "la witch no se congela" del reporte de la ronda 4).
    g_bMetalWitchHadFrozen[client] = (GetEntityFlags(witch) & FL_FROZEN) != 0;
    Metal_WitchFreeze(witch);

    // Dano del catch (como un especial: 4) — sin OM_Stun (player-only)
    SDKHooks_TakeDamage(witch, client, client, METAL_CATCH_DMG, DMG_OM_CLUB);

    // FX eléctrico del catch (mismo paquete que un especial)
    float tPos[3];
    GetEntPropVector(witch, Prop_Data, "m_vecOrigin", tPos);
    float flashPos[3];
    flashPos[0] = tPos[0]; flashPos[1] = tPos[1]; flashPos[2] = tPos[2] + 50.0;
    TE_SetupSparks(flashPos, NULL_VECTOR, 6, 3);
    TE_SendToAll();

    if (g_bMetalSndElec)
        EmitSoundToAll("om/metal/eletricsound.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("ambient/energy/zap1.wav", client, _, METAL_SND_LEVEL);
    if (g_bMetalAssets)
    {
        Metal_FxFlash(flashPos, "materials/om/metal_elec.vmt", 1.0, 0.4);
        Metal_ElectricArcs(tPos);
    }

    // v6.0: la misma tormenta de arcos sobre la WITCH arrastrada (la
    // victima es entidad, el parentado funciona igual)
    Metal_FxArcsStart(client, witch);

    PrintCenterText(client, "Witch atrapada! Arrastrandola...");
}

// v5.3 punto 3: el ARRASTRE de la witch (rama de entidad del estado
// DRAGGING): velocidad de embestida + watchdog + avalancha de comunes +
// teleport de sujeción a 85u + tick de dano cada 0.25s + estampado
// contra pared (los golpes van por la rama witch del Metal_SlamHit).
void Metal_WitchDragThink(int client, float now)
{
    int witch = Metal_GetWitchTarget(client);
    if (witch == -1 || GetEntProp(witch, Prop_Data, "m_iHealth") <= 0)
    {
        // murió o desapareció — v5.8: misma regla que un especial
        // muerto en sus manos: LA EMBESTIDA CONTINUA (vuelve al DASH;
        // antes era Metal_CancelCharge). Metal_ReleaseGrabbed dentro
        // limpia también las referencias de la witch
        Metal_DragTargetDied(client);
        return;
    }

    // v5.4: re-afirmar el congelado cada tick — la estatua aguanta TODO
    // el arrastre (el dano o el motor pueden tirar el flag a mitad)
    Metal_WitchFreeze(witch);

    // Velocidad de arrastre (mismo stack que un especial)
    Metal_DashSpeedSet(client, METAL_DRAG_SPEED);
    float dir[3];
    Metal_GetMoveDir(client, dir);

    // Arrastre aéreo + watchdog de atascos (mismo criterio del cliente)
    if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        float airVel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", airVel);
        airVel[0] = dir[0] * METAL_DRAG_SPEED;
        airVel[1] = dir[1] * METAL_DRAG_SPEED;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, airVel);
        g_fMetalStuckSince[client] = 0.0;
    }
    else if (Metal_StuckCheck(client, now))
    {
        return;
    }

    // v5.3 punto 2: avalancha de comunes también arrastrando a la witch
    Metal_KillCommonsInPath(client, now);

    // La witch ADELANTE (85u — es más grande que un especial), congelada
    // por movetype y sujetada por teleport cada frame
    float mPos[3], hold[3];
    GetClientAbsOrigin(client, mPos);
    hold[0] = mPos[0] + dir[0] * METAL_WITCH_HOLD_DIST;
    hold[1] = mPos[1] + dir[1] * METAL_WITCH_HOLD_DIST;
    hold[2] = mPos[2] + 10.0;
    TeleportEntity(witch, hold, NULL_VECTOR, NULL_VECTOR);

    // Tick de dano cada 0.25s — mismo ritmo que un especial (dano directo
    // SDKHooks + re-congelado: la witch no usa OM_Stun porque es entidad)
    if (now >= g_fMetalNextDragTick[client])
    {
        g_fMetalNextDragTick[client] = now + METAL_DRAG_TICK;
        int dmg = Metal_GetDragDamage(client);
        g_fMetalAccumulatedDragDmg[client] += float(dmg);
        Metal_TakeSelfDamage(client, float(dmg));

        SDKHooks_TakeDamage(witch, client, client, METAL_DRAG_DMG_ENEMY, DMG_OM_CLUB);
        SetEntityMoveType(witch, MOVETYPE_NONE);   // re-congelar tras el dano
        Metal_WitchFreeze(witch);   // v5.4: estatua re-afirmada tras el dano del tick

        // FX del tick sobre la witch (impacto + electricidad del mod)
        if (g_bMetalAssets)
        {
            float vPos[3];
            GetEntPropVector(witch, Prop_Data, "m_vecOrigin", vPos);
            float iPun[3], ePos[3];
            iPun[0] = vPos[0] + dir[0] * 20.0;
            iPun[1] = vPos[1] + dir[1] * 20.0;
            iPun[2] = vPos[2] + 50.0;
            Metal_FxFlash(iPun, "materials/om/metal_impact.vmt", 0.55, 0.30);
            ePos[0] = vPos[0]; ePos[1] = vPos[1]; ePos[2] = vPos[2] + 40.0;
            Metal_FxFlash(ePos, "materials/om/metal_elec.vmt", 0.65, 0.35);
            Metal_ElectricArcs(vPos);
        }

        if (g_fMetalAccumulatedDragDmg[client] >= float(METAL_DRAG_TOTAL_CAP))
        {
            Metal_WitchDrop(client, witch);
            return;
        }
    }

    // Pared delante -> WALL SLAM sobre la witch (golpes por Metal_SlamHit)
    if (Metal_HitWall(client))
    {
        Metal_BeginWallSlam(client, now);
        return;
    }

    if (now >= g_fMetalStateEndTime[client])
        Metal_CancelCharge(client);
}

// v5.3 punto 3: restaura TODO lo que Metal le hizo a la witch (grupo de
// colisión original + movetype original) y la suelta con impulso
// opcional (fling) para que no quede congelada en el aire.
void Metal_WitchRelease(int client, int witch, bool fling)
{
    if (g_iMetalWitchColGroup[client] > 0 && IsValidEntity(witch))
        SetEntProp(witch, Prop_Data, "m_CollisionGroup", g_iMetalWitchColGroup[client]);
    g_iMetalWitchColGroup[client] = -1;

    if (IsValidEntity(witch))
    {
        // v5.4: DESCONGELAR antes del fling — la estatua (FL_FROZEN)
        // ignoraria el impulso de salida. Se libera el slot de Sonic
        // (estrellas + watch) por el mismo camino y se quita SOLO el
        // flag que pusimos nosotros (si venía congelada por otro stun,
        // queda como estaba — patron Rouge_WaveRelease).
        int wslot = Sonic_WitchStunSlotOf(witch);
        if (wslot != -1) Sonic_WitchStunClear(wslot);
        if (!g_bMetalWitchHadFrozen[client]
            && (GetEntityFlags(witch) & FL_FROZEN) != 0)
            SetEntityFlags(witch, GetEntityFlags(witch) & ~FL_FROZEN);

        // su movetype ORIGINAL (guardado en el catch — por si no era WALK)
        MoveType mt = view_as<MoveType>(g_iMetalWitchSavedMT[client]);
        if (view_as<int>(mt) <= 0) mt = MOVETYPE_WALK;
        SetEntityMoveType(witch, mt);

        if (fling)
        {
            float dir[3], vel[3];
            Metal_GetMoveDir(client, dir);
            vel[0] = dir[0] * METAL_WITCH_RELEASE_FLING;
            vel[1] = dir[1] * METAL_WITCH_RELEASE_FLING;
            vel[2] = 250.0;
            TeleportEntity(witch, NULL_VECTOR, NULL_VECTOR, vel);
        }
    }
    g_iMetalWitchSavedMT[client]  = -1;
    g_iMetalWitchTarget[client]   = 0;
    g_bMetalWitchHadFrozen[client] = false;
}

// v5.3 punto 3: suelta de la witch por cap de dano (el equivalente del
// Metal_DropByDamageCap): fling de salida + cierre estándar de Metal.
void Metal_WitchDrop(int client, int witch)
{
    Metal_WitchRelease(client, witch, true);   // despejada + despedida

    Metal_DashColExit(client, METAL_AIR_END_DAMP);
    Speed_StackSet(client, SPEED_STACK_METAL_DASH, 0.0);
    SetEntityRenderColor(client, 255, 255, 255, 255);
    Metal_AvatarTintReset(client);
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntityMoveType(client, MOVETYPE_WALK);
    SetEntProp(client, Prop_Send, "m_iFOV", 0);
    SetEntProp(client, Prop_Send, "m_iFOVStart", 0);
    Metal_StopLoopSound(client);
    Metal_FxFlameStop(client);   // v6.0: la carga termino = Metal se detuvo

    g_iMetalChargeState[client]        = METAL_STATE_IDLE;
    g_iMetalGrabbedTarget[client]      = -1;
    g_fMetalAccumulatedDragDmg[client] = 0.0;

    PrintCenterText(client, "Carga terminada. Witch empujada.");
}

// ============================================================
// v5.3 punto 4: DESPEGA al objetivo del watchdog de atascos — ANTES de
// cancelar la carga, el objetivo (especial o witch) se teletransporta
// DETRÁS de Metal (contra la dirección de la marcha, +30z) y recupera
// su colisión: el pasillo por delante queda LIBRE al instante. Es la
// respuesta directa al "aún sigo atascándome contra los enemigos que
// envisto contra la pared en lugares angostos".
// ============================================================
void Metal_UnwedgeDragTarget(int client)
{
    float dir[3], mPos[3], behind[3];
    Metal_GetMoveDir(client, dir);
    GetClientAbsOrigin(client, mPos);
    behind[0] = mPos[0] - dir[0] * METAL_STUCK_TELEPORT_DIST;
    behind[1] = mPos[1] - dir[1] * METAL_STUCK_TELEPORT_DIST;
    behind[2] = mPos[2] + 30.0;

    // ---- WITCH ----
    int witch = (g_iMetalWitchTarget[client] != 0) ? Metal_GetWitchTarget(client) : -1;
    if (witch != -1)
    {
        Metal_WitchRelease(client, witch, false);   // colisión + movetype
        TeleportEntity(witch, behind, NULL_VECTOR, NULL_VECTOR);
        return;
    }

    // ---- INFECTADO ESPECIAL (cliente) ----
    int target = g_iMetalGrabbedTarget[client];
    if (Metal_IsValidClient(target))
    {
        if (g_iMetalVictimColGroup[client] > 0)
        {
            SetEntProp(target, Prop_Data, "m_CollisionGroup", g_iMetalVictimColGroup[client]);
            g_iMetalVictimColGroup[client] = -1;
        }
        // DETRÁS de Metal, mirándolo: fuera del camino por completo
        TeleportEntity(target, behind, NULL_VECTOR, NULL_VECTOR);
    }
}

// ============================================================
// v5.3 punto 5: LA VIDA MÁXIMA REAL DE METAL — 175 AL ESCOGERLO.
// "hay que ajustar que la vida max de metal (si se escoje) sea de 175
// de vida max y no 100 aunque la cura puede aumentar esa cantidad si
// me aplican botiquin pierdo la vida adicional":
//   (a) m_iMaxHealth = 175 en las DOS copias (Data + Send) — el
//       BOTIQUIN del juego cura 80% del máximo QUE VEE: con 100 grabado
//       CURA HACIA ABAJO (esa era la perdida de vida adicional);
//   (b) al escogerlo / nacer con vida llena (100), arranca a 175 —
//       con menos vida se conserva la actual (no es un full-heal);
//   (c) el Self Repair ahora puede llenar hasta 175 (cap 150 -> 175).
// Se invoca desde la SELECCION de personaje y desde cada spawn vivo.
// ============================================================
void Metal_ApplyMaxHealth(int client)
{
    if (!Metal_IsValidClient(client)) return;
    if (GetClientTeam(client) != TEAM_SURVIVOR) return;

    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", METAL_MAX_HP);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", METAL_MAX_HP);

    if (IsPlayerAlive(client) && !GetEntProp(client, Prop_Send, "m_isIncapacitated"))
    {
        int hp = GetClientHealth(client);
        if (hp >= 100 && hp < METAL_MAX_HP)
            SetEntityHealth(client, METAL_MAX_HP);
    }
}

// v5.3 punto 5: el camino de VUELTA — al dejar de ser Metal (cambio de
// personaje, muerte, descarga del plugin) nadie hereda las 175: tope
// vanilla 100 y recorte de la vida por encima.
void Metal_RestoreMaxHealth(int client)
{
    if (client < 1 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;

    if (HasEntProp(client, Prop_Data, "m_iMaxHealth"))
        SetEntProp(client, Prop_Data, "m_iMaxHealth", 100);
    if (HasEntProp(client, Prop_Send, "m_iMaxHealth"))
        SetEntProp(client, Prop_Send, "m_iMaxHealth", 100);

    if (IsPlayerAlive(client) && GetClientHealth(client) > 100)
        SetEntityHealth(client, 100);
}

// ============================================================
// v5.2 ajuste 7: la victima que el oponente tiene AGARRADA ahora
// mismo (leida del lado del ATACANTE: los enlaces que el motor
// mantiene mientras el hunter ensarta / el jockey monta / el smoker
// arrastra / el charger carga o machaca). Devuelve el survivor o -1.
// ============================================================
int Metal_ControlVictimOf(int attacker)
{
    if (attacker <= 0 || attacker > MaxClients) return -1;
    if (!IsClientInGame(attacker) || !IsPlayerAlive(attacker)) return -1;

    static const char pins[5][] = {
        "m_pounceVictim",   // hunter ensartado
        "m_jockeyVictim",   // jockey montado (el bug del owner)
        "m_tongueVictim",   // smoker arrastrando
        "m_carryVictim",    // charger cargando en brazos
        "m_pummelVictim"    // charger machacando
    };

    for (int p = 0; p < 5; p++)
    {
        if (!HasEntProp(attacker, Prop_Send, pins[p])) continue;
        int victim = GetEntPropEnt(attacker, Prop_Send, pins[p]);
        if (victim > 0 && victim <= MaxClients && IsClientInGame(victim)
            && IsPlayerAlive(victim) && GetClientTeam(victim) == TEAM_SURVIVOR)
            return victim;
    }
    return -1;
}

// ============================================================
// v5.2 ajuste 5: INMUNIDAD ANTI-CONTROL durante TODA la embestida
// ("durante Su embestida el no debería poder ser aturdido. stagger de
//  ningún tipo ni agarrado ni nada"). Vale para windup, dash,
// arrastre, wall slam y rebote. El manager la consulta en los 8
// forwards anti-control (puño/roca del tank, fling, stagger, pounce,
// jockey ride, charger, tongue). El windup sigue interrumpible por
// DANO (diseño GMod) — solo el CONTROL queda blindado.
// ============================================================
bool Metal_ControlImmune(int client)
{
    if (client <= 0 || client > MaxClients) return false;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return false;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return false;
    return g_iMetalChargeState[client] != METAL_STATE_IDLE;
}

// =======================
// GESTION DE DANO Y AUTO-DESTRUCCION
// =======================

public Action Metal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!Metal_IsValidClient(victim)) return Plugin_Continue;
    if (g_iPlayerCharIdx[victim] != METALSONIC_INDEX) return Plugin_Continue;

    // Inmunidades pasivas
    if (damagetype & DMG_FALL || damagetype & DMG_ACID || damagetype & DMG_POISON || damagetype & DMG_RADIATION)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // v5.5 (reporte owner): un golpe de 0 de DANO REAL (bloqueado por
    // iframes/armadura/otro hook antes de llegar aquí) NO interrumpe
    // NADA: ni la REPARACION ni el WINDUP de la embestida ("si no
    // recibe dano real no es interrumpido, ninguna de las 2").
    if (damage <= 0.0)
        return Plugin_Continue;

    // v5.0 GMod (l.963-964 + l.1621-1633): mientras SE REPARA es
    // INVULNERABLE (OM_Damage_Reduction = 1) y el golpe CANCELA la cura:
    // el dano se bloquea entero y el ciclo se cierra con cooldown.
    if (g_bMetalHealing[victim])
    {
        damage = 0.0;
        Metal_StopHeal(victim, false);
        return Plugin_Handled;
    }

    // v3: Si está en WINDUP y lo golpean -> CANCEL con dano completo, CD reducido, speed boost
    if (g_iMetalChargeState[victim] == METAL_STATE_WINDUP)
    {
        // v3.1: el dano NO se reduce aquí, así que un golpe letal directo
        // también debe marcar la bandera (sino quedaría incapacitado)
        if (damage >= float(GetClientHealth(victim)))
            g_bMetalLethalHit[victim] = true;

        Metal_CancelWindup(victim);
        return Plugin_Changed; // dano completo (sin reducción 50%)
    }

    // v4.0 GMod: durante la EMBESTIDA (dash/arrastre) Metal es
    // INVULNERABLE (el mod pone OM_Damage_Reduction = 0 mientras carga).
    // Wall slam y bounce ya lo eran. El windup sigue interrumpible (arriba).
    if (g_iMetalChargeState[victim] == METAL_STATE_DASH ||
        g_iMetalChargeState[victim] == METAL_STATE_DRAGGING ||
        g_iMetalChargeState[victim] == METAL_STATE_WALL_SLAM ||
        g_iMetalChargeState[victim] == METAL_STATE_BOUNCE)
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    // v3.1 FIX PASIVA "SIN INCAP": si el dano reducido dejaría a Metal en
    // 0 HP, marcar golpe letal. El juego incapacitara en vez de matar, y el
    // PreThink lo detonara (muerte directa + explosión).
    if (damage * 0.5 >= float(GetClientHealth(victim)))
        g_bMetalLethalHit[victim] = true;

    // Reducción 50% en el resto de casos
    damage *= 0.5;
    return Plugin_Changed;
}

// v3: Cancela el windup con penalización: CD reducido + speed boost
void Metal_CancelWindup(int client)
{
    float now = GetEngineTime();

    // CD reducido (50% del normal)
    g_fMetalChargeCD[client] = now + METAL_CHARGE_CD_CANCELLED;

    // Speed boost temporal (stacea con on-hit boost existente)
    g_fMetalCancelBoostEnd[client] = now + METAL_CANCEL_BOOST_TIME;
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", METAL_CANCEL_SPEED_BOOST);

    // Reset visual y estado
    SetEntityRenderColor(client, 255, 255, 255, 255);
    Metal_AvatarTintReset(client);
    g_iMetalChargeState[client]   = METAL_STATE_IDLE;
    g_iMetalGrabbedTarget[client] = -1;

    // v4.2 FIX (pedido del owner): el ICONO DE CARGA que flota encima debe
    // DESAPARECER si la carga se interrumpe — v4.1 solo lo mataba en la
    // transición a dash y en el CancelCharge, y este camino (dano en pleno
    // windup) lo dejaba flotando en el aire para siempre.
    Metal_KillWindupIcon(client);

    PrintCenterText(client, "¡Carga interrumpida! Speed boost activado.");
    // v4.1: metalchargeend.wav REAL del mod (carga interrumpida)
    if (g_bMetalSndEnd)
        EmitSoundToAll("om/metal/metalchargeend.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToClient(client, "player/survivor/hit/crowbar_swing_miss1.wav");
}

// Dano propio que ignora la reducción de 50%
void Metal_TakeSelfDamage(int client, float amount)
{
    // v3.1: si ya hay una detonación pendiente, no acumular más
    if (g_bMetalSelfDestructPending[client]) return;

    int hp = GetClientHealth(client);
    hp -= RoundToNearest(amount);

    if (hp <= 0)
    {
        // v3.1 FIX SEGURIDAD: marcar detonación pendiente en vez de llamar
        // ForcePlayerSuicide en medio del think de la carga. Se ejecuta al
        // inicio del siguiente PreThink y la explosión llega vía el evento
        // de muerte (pasiva "Explota al morir").
        g_bMetalSelfDestructPending[client] = true;
    }
    else
    {
        SetEntityHealth(client, hp);
    }
}

// v3.1: Explosión de muerte (pasiva "Explota al morir").
// Se invoca SOLO desde Metal_Event_PlayerDeath (evento de muerte real).
// Ya NO fuerza el suicidio: el jugador ya está muerto cuando llega aquí.
// v5.2 ajuste 9: LA EXPLOSION DEL GMOD DE VERDAD (lua l.756+):
//   - radio 230 (alla ents.FindInSphere(pos, 230); el v5.1 usaba 500);
//   - dano 50 DMG_CLUB POR VICTIMA (alla Damage 50; el v5.1 no danoia);
//   - stun 5.5s (pedido del owner: "aturdiéndolos por 5seg y medio";
//     alla StunDur 7) con el paquete OM completo (estatua + estrellas);
//   - RAGDOLL VOLADOR por victima (alla CreateRagdolLCharacter_OM +
//     fling dir*800 + angvel rand*1600): receta Sonic v6.11
//     Sonic_SpawnFlingRagdoll — doble prop_ragdoll con vphysics real
//     + onda env_physexplosion (empuje puro); la estatua real queda
//     oculta y al pasar el stun reaparece DONDE cayó el doble;
//   - los 3 sonidos del lua (l.582-604): ExplodeSfx + Explosión +
//     MetalBloodSound (volume 2 / soundLevel 87 alla = METAL_SND_LEVEL).
void Metal_Detonate(int client)
{
    if (!IsClientInGame(client)) return;

    float pos[3];
    GetClientAbsOrigin(client, pos);

    TE_SetupExplosion(pos, g_iMetalSpriteGlow, 50.0, 1, 0, 600, 0);
    TE_SendToAll();
    // v4.1: explodesfx.wav REAL del mod (Metal_Detonate) + destello grande
    if (g_bMetalSndBoom)
        EmitSoundToAll("om/metal/explodesfx.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("ambient/explosions/explode_3.wav", client, _, METAL_SND_LEVEL);
    // v5.2: los otros DOS sonidos de la muerte del lua (l.594-604)
    if (g_bMetalSndBoom2)
        EmitSoundToAll("om/metal/Explosión.wav", client, _, METAL_SND_LEVEL);
    if (g_bMetalSndBlood)
        EmitSoundToAll("om/metal/MetalBloodSound.wav", client, _, METAL_SND_LEVEL);
    if (g_bMetalAssets)
        Metal_FxFlash(pos, "materials/om/metal_elec.vmt", 2.0, 0.5);

    int ragCount = 0;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == TEAM_INFECTED)
        {
            float tPos[3];
            GetClientAbsOrigin(i, tPos);
            if (GetVectorDistance(pos, tPos) <= METAL_DEATH_RADIUS)
            {
                // v5.2: el stun 5.5s + dano 50 (el gran dano del GMod) —
                // el paquete OM completo (estrellas + chispas + freeze).
                // La recuperación es AUTOMÁTICA al expirar (cero timers).
                if (!OM_Stun(i, METAL_DEATH_STUN, client, METAL_DEATH_DMG, DMG_OM_CLUB, true))
                    continue;

                // v5.2: RAGDOLL VOLADOR — sale despedido EN DIRECCION
                // CONTRARIA a Metal ("lanzarlos"), como el fling del lua
                if (OM_IsStunned(i))
                {
                    float fDir[3];
                    fDir[0] = tPos[0] - pos[0];
                    fDir[1] = tPos[1] - pos[1];
                    fDir[2] = 0.0;
                    float len = SquareRoot(fDir[0] * fDir[0] + fDir[1] * fDir[1]);
                    if (len < 1.0) { fDir[0] = GetRandomFloat(-1.0, 1.0); fDir[1] = GetRandomFloat(-1.0, 1.0); len = 1.0; }
                    fDir[0] /= len;
                    fDir[1] /= len;
                    Sonic_SpawnFlingRagdoll(i, fDir);
                    ragCount++;
                }
            }
        }
    }

    // ============================================================
    // v5.4: LA WITCH DEL RADIO TAMBIÉN — el frozen "para nextbot" que
    // ya usan Tails/Amy/Sonic con ella: estatua 5.5s + ragdoll volador
    // en dirección contraria a Metal (la receta Amy del martillo:
    // Sonic_WitchStun + Sonic_SpawnWitchRagdoll). El watch de sonic.inc
    // hace el resto (re-afirma el flag, orbita estrellas, la despierta
    // DONDE cayó el doble cuando expira).
    // ============================================================
    int went = -1;
    while ((went = FindEntityByClassname(went, "witch")) != -1)
    {
        if (!IsValidEntity(went)) continue;
        if (GetEntProp(went, Prop_Data, "m_iHealth") <= 0) continue;

        float wPos[3];
        GetEntPropVector(went, Prop_Data, "m_vecOrigin", wPos);
        if (GetVectorDistance(pos, wPos) > METAL_DEATH_RADIUS) continue;

        float fDirW[3];
        fDirW[0] = wPos[0] - pos[0];
        fDirW[1] = wPos[1] - pos[1];
        fDirW[2] = 0.0;
        float lenW = SquareRoot(fDirW[0] * fDirW[0] + fDirW[1] * fDirW[1]);
        if (lenW < 1.0) { fDirW[0] = GetRandomFloat(-1.0, 1.0); fDirW[1] = GetRandomFloat(-1.0, 1.0); lenW = 1.0; }
        fDirW[0] /= lenW;
        fDirW[1] /= lenW;

        Sonic_WitchStun(went, METAL_DEATH_STUN);
        Sonic_SpawnWitchRagdoll(went, fDirW);
        ragCount++;
    }

    PrintToChatAll("\x04[Metal Sonic]\x01 ha sido destruido: ¡explosión final! (%d infectados lanzados)", ragCount);
}

// =======================
// HABILIDAD 1: DESTRUCTIVE CHARGE
// =======================

public Action Command_MetalCharge(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Metal_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return Plugin_Handled;
    if (g_iMetalChargeState[client] != METAL_STATE_IDLE)
    {
        PrintCenterText(client, "Ya estas en carga.");
        return Plugin_Handled;
    }
    // v5.2 ajuste 8: el bloqueo "No puedes cargar durante Overdrive"
    // SE RETIRA — la combinación C + Espacio + Z es el DASH AÉREO
    // intencional (la levitación sostiene la altura y la embestida
    // vuela; sin Espacio cae al piso y sigue por suelo).
    // v5.0: en plena reparación no se arranca la carga (lua l.1611 al reves)
    if (g_bMetalHealing[client])
    {
        PrintCenterText(client, "No puedes cargar mientras te reparas.");
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fMetalChargeCD[client])
    {
        PrintCenterText(client, "Cooldown: %.1f", g_fMetalChargeCD[client] - now);
        return Plugin_Handled;
    }

    g_fMetalChargeCD[client] = now + METAL_CHARGE_COOLDOWN;

    // Iniciar WINDUP
    g_iMetalChargeState[client]    = METAL_STATE_WINDUP;
    g_fMetalStateEndTime[client]   = now + METAL_WINDUP_DURATION;
    g_fMetalWindupStartTime[client] = now;
    g_iMetalDashFxTick[client]     = 0;
    g_iMetalWindupIcon[client]     = INVALID_ENT_REFERENCE;
    PrintCenterText(client, "Cargando Destructive Charge...");

    // v4.1: metal_chargeup.wav REAL del mod (2.4s = windup exacto),
    // fallback aheli de HL2. El icono de carga (metal_load del GMod ->
    // om/metal_chargeglow) lo crea/pulsa el ChargeThink.
    if (g_bMetalSndCharge)
        EmitSoundToAll("om/metal/metal_chargeup.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("npc/attack_helicopter/aheli_charge_up.wav", client, _, METAL_SND_LEVEL);

    return Plugin_Handled;
}

// Cancela la carga
// v3.1: parámetro hitWall eliminado (nunca se uso desde v3.0)
void Metal_CancelCharge(int client)
{
    if (g_iMetalChargeState[client] == METAL_STATE_IDLE) return;

    // v5.3 punto 4: restaurar al ARRASTRADO por este camino también
    // (timeout del arrastre con objetivo vivo: colisión del cliente +
    // estado completo de la witch) — idempotente con los demas caminos
    Metal_ReleaseGrabbed(client, true);

    // v5.0: fuera grupo DEBRIS + slot del stack (dash agotado / target
    // inválido): restaura grupo de colisión y frena suave.
    Metal_DashColExit(client, METAL_AIR_END_DAMP);
    Speed_StackSet(client, SPEED_STACK_METAL_DASH, 0.0);

    // Restaurar movilidad (+ FOV + loop eléctrico: v4.0 cero residual)
    SetEntityRenderColor(client, 255, 255, 255, 255);
    Metal_AvatarTintReset(client);
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
    SetEntityMoveType(client, MOVETYPE_WALK);
    SetEntProp(client, Prop_Send, "m_iFOV", 0);
    SetEntProp(client, Prop_Send, "m_iFOVStart", 0);
    Metal_StopLoopSound(client);
    Metal_FxFlameStop(client);   // v6.0: timeout del reloj = Metal se detuvo

    // v4.1: metalchargeend.wav REAL del mod al agotar/cancelar la carga
    if (g_bMetalSndEnd)
        EmitSoundToAll("om/metal/metalchargeend.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("ambient/energy/zap1.wav", client, _, METAL_SND_LEVEL);
    Metal_KillWindupIcon(client);

    // (v4.0: el target ya NO necesita restaurar nada aquí — OM_Stun nunca
    // toca su movetype y su freeze se restaura solo al expirar el stun)

    g_iMetalChargeState[client]    = METAL_STATE_IDLE;
    g_iMetalGrabbedTarget[client]  = -1;
    g_fMetalAccumulatedDragDmg[client] = 0.0;
}

// =======================
// HABILIDAD 2: V. MAXIMUM OVERDRIVE
// =======================

public Action Command_MetalOverdrive(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Metal_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return Plugin_Handled;
    if (g_bMetalOverdrive[client]) return Plugin_Handled;
    // v5.2 ajuste 8: el bloqueo "No puedes usar Overdrive durante una
    // carga" SE RETIRA — el Overdrive ahora COMBINA con la embestida
    // (la levitación con Espacio convierte la embestida en dash aéreo)

    float now = GetEngineTime();
    if (now < g_fMetalOverdriveCD[client])
    {
        PrintCenterText(client, "Overdrive Cooldown: %.1f", g_fMetalOverdriveCD[client] - now);
        return Plugin_Handled;
    }

    g_fMetalOverdriveCD[client]     = now + METAL_OVERDRIVE_COOLDOWN;
    g_bMetalOverdrive[client]       = true;
    g_fMetalOverdriveEndTime[client] = now + METAL_OVERDRIVE_DURATION;
    g_fMetalNextAuraTick[client]    = now;

    // v3.6: BUFF puro (estilo v3.4): sin impulso de arranque, sin
    // FLYGRAVITY, sin DEBRIS. La VELOCIDAD REAL (+30%) se registra en el
    // STACK ADITIVO del Speed_sonic (SLOT 0): si !speed también esta
    // activo, la velocidad SUMA en vez de pisarse (220 x (1 + 2.5 + 0.3)
    // = 836 uu/s; con el chute de adrenalina: +40 encima). El lagged 1.3
    // viejo era la causa del "no sirve" (escala de tiempo: la predicción
    // del cliente corre a 1x y el rubber-band se lo comia).
    Speed_StackSet(client, SPEED_STACK_METAL_OD, METAL_OVERDRIVE_SPEED_MULT - 1.0);

    EmitSoundToAll("ambient/energy/zap1.wav", client, _, METAL_SND_LEVEL);
    PrintCenterText(client, "V. MAXIMUM OVERDRIVE ACTIVADO (Espacio = levitar)");

    return Plugin_Handled;
}

// (v5.2 ajuste 4: T_Metal_OverheatEnd ELIMINADO — el Overdrive ya no
//  inmoviliza al terminar, no hay nada que restaurar)

// =======================
// HABILIDAD 2 (X): SELF REPAIR — v5.0
// =======================
// Port fiel del "selfheal" del lua (T key alla, X aquí — pedido del
// owner 3.77.25: "la curación sería en la X"). Reglas del lua l.960-1039
// + l.1600-1644:
//   - Toggle de UNA pulsación (alla T): arranca el ciclo si HP <= 150.
//   - Tick cada 2s (healingCooldown_OM): +7 HP (heal_healamount) y
//     TotalHeals += 7; para sola si HP > 150 o TotalHeals > 70.
//   - CONGELADO mientras repara: OM_NoMovement 6.7s REFRESCADO por tick
//     (el ciclo entero es estático; el arrastre de la ventana desaparece
//     al cerrar).
//   - INVULNERABLE mientras repara (OM_Damage_Reduction = 1 del lua
//     l.963-964): el dano entrante se BLOQUEA y CANCELA la cura (hook
//     EntityTakeDamage del lua l.1621-1633: Healing = false + TotalHeals
//     fuera de rango = cierre inmediato).
//   - Al cerrar (completa o cancelada): heal_cooldown 24s
//     (heal_cooldownSucess) + healfinished.wav + si curo al menos 1 tick:
//     anim HealToIldle + NoMovement 0.5s.
//   - Bloqueos de arranque (l.1606-1613): cooldown vivo, ya reparando,
//     NoMovement, en plena embestida/arrastre, o HP ya > 150.
public Action Command_MetalHeal(int client, int args)
{
    client = Sonic_SoloClient(client);   // v3.77.79 MODO SOLO: consola/fake -> tu jugador
    if (!Metal_IsValidClient(client)) return Plugin_Handled;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return Plugin_Handled;
    if (g_bMetalHealing[client]) return Plugin_Handled;   // ya en ello
    if (g_iMetalChargeState[client] != METAL_STATE_IDLE)  // en plena carga no (l.1611)
    {
        PrintCenterText(client, "No puedes repararte durante la carga.");
        return Plugin_Handled;
    }

    float now = GetEngineTime();
    if (now < g_fMetalHealCD[client])
    {
        PrintCenterText(client, "Self Repair recargando... (%.0fs)", g_fMetalHealCD[client] - now);
        return Plugin_Handled;
    }

    // lua l.1613: si ya esta por encima de 150, ni arranca
    if (GetClientHealth(client) > METAL_HEAL_HP_CAP)
    {
        PrintCenterText(client, "Sistemas ya al máximo (%d HP).", GetClientHealth(client));
        return Plugin_Handled;
    }

    g_bMetalHealing[client]      = true;
    g_iMetalHealTotal[client]    = 0;
    g_fMetalHealNextTick[client] = now + METAL_HEAL_TICK;   // primer +7 a los 2s
    g_fMetalHealFreezeEnd[client] = now + METAL_HEAL_FREEZE;

    // v5.1: la LUZ VERDE del repair nace aquí (OFF: enciende solo en la
    // ventana de 0.25s de cada tick, como el dlight del GMod)
    Metal_KillHealLight(client);   // defensivo: nunca dos
    g_iMetalHealLight[client] = Metal_MakeHealLight(client);
    g_bMetalHealLightOn[client] = false;

    // lua l.1635-1643: "Metal self repair activation (2).wav"
    if (g_bMetalSndHealAct)
        EmitSoundToAll("om/metal/Metal self repair activation (2).wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("ui/pickup_medkit.wav", client, _, METAL_SND_LEVEL);

    PrintCenterText(client, "SELF REPAIR: reparando (+%d cada %.0fs)...", METAL_HEAL_AMOUNT, METAL_HEAL_TICK);
    return Plugin_Handled;
}

// =======================
// v5.1: LA LUZ VERDE DEL SELF REPAIR — el dlight del GMod
// (noodles_om_pills_survivors_metalsonic.lua l.1583-1596: r=0 g=255
// b=0, brightness 3, Size 200, Decay 1000, refrescado cada frame
// mientras MetalSonicHeal_highlight vive — luz CONSTANTE que ilumina
// la escena alrededor). Receta Sonic_MakeBlueLight v6.20 (light_dynamic
// de verdad, ya probado en este server con la bola de Sonic). Nace
// APAGADA: TurnOn solo en la ventana del destello de cada tick.
// =======================
int Metal_MakeHealLight(int client)
{
    int l = CreateEntityByName("light_dynamic");
    if (l <= 0 || !IsValidEntity(l)) return 0;
    DispatchKeyValue(l, "_light", "0 255 0 200");   // verde puro del lua
    DispatchKeyValue(l, "brightness", "3");          // brightness 3 (l.1591)
    DispatchKeyValue(l, "distance", "200");          // Size 200 (l.1593)
    DispatchKeyValue(l, "style", "0");               // constante, sin flicker
    float pos[3];
    GetClientAbsOrigin(client, pos);                 // el origin del puppet
    DispatchSpawn(l);
    TeleportEntity(l, pos, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(l, "TurnOff");                 // off hasta el 1er tick
    SetVariantString("!activator");
    AcceptEntityInput(l, "SetParent", client);
    return EntIndexToEntRef(l);
}

// Apaga la luz si estaba encendida (idempotente, sin spam de inputs)
void Metal_HealLightOff(int client)
{
    if (!g_bMetalHealLightOn[client]) return;
    g_bMetalHealLightOn[client] = false;
    int l = EntRefToEntIndex(g_iMetalHealLight[client]);
    if (l > 0 && IsValidEntity(l))
        AcceptEntityInput(l, "TurnOff");
}

// Mata la luz SIEMPRE (StopHeal y ResetState: la entidad parentada a un
// player que desaparece quedaría encendida en el último lugar = fuga)
void Metal_KillHealLight(int client)
{
    g_bMetalHealLightOn[client] = false;
    int l = EntRefToEntIndex(g_iMetalHealLight[client]);
    if (l > 0 && IsValidEntity(l))
        AcceptEntityInput(l, "Kill");
    g_iMetalHealLight[client] = 0;
}

// ============================================================
// v5.2 ajuste 6: EL AURA DE SOPORTE del Self Repair — "la reparación
// esta heredado a curarse más rápido si está con eggman o tails no?".
// Si hay un Tails o un Eggman VIVO a menos de 250u (el mismo radio del
// tails_heal_boost del suite), el tick se acelera x2 (cada 1s en vez
// de 2s — misma proporción que el boost de curación de Tails).
// ============================================================
bool Metal_SupportAuraActive(int client)
{
    float mPos[3];
    GetClientAbsOrigin(client, mPos);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (i == client) continue;
        if (!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
        if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
        if (g_iPlayerCharIdx[i] != TAILS_INDEX && g_iPlayerCharIdx[i] != EGGMAN_INDEX) continue;

        float tPos[3];
        GetClientAbsOrigin(i, tPos);
        if (GetVectorDistance(mPos, tPos) <= METAL_HEAL_AURA_RADIUS)
            return true;
    }
    return false;
}

// El ciclo del heal (lo invoca Metal_PreThink cada frame mientras vive)
void Metal_HealThink(int client, float now)
{
    // CONGELADO (lua l.991: OM_NoMovement 6.7s refrescado por tick) + el
    // anim "heal" se mantiene vivo para la FSM (ventana 0.25s)
    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);
    g_fMetalHealFreezeEnd[client] = now + METAL_HEAL_FREEZE;
    g_fMetalHealAnimEnd[client]   = now + 0.25;

    // v5.1: EL FLASH DEL TICK — tinte VERDE del avatar con el fade
    // EXACTO del original (UI l.94-112: rampa 0->1 en 0.125s, 1->0 en
    // 0.125s, Color(0,255,0, 255*alpha)). Cada FRAME (PreThink) = la
    // granularidad del hook de cliente del GMod. Solo el AVATAR: el
    // cuerpo del survivor esta RENDER_NONE (lecciones del v5.0).
    if (g_fMetalHealFxEnd[client] > 0.0)
    {
        if (now >= g_fMetalHealFxEnd[client])
        {
            // fin del destello: tinte fuera + luz OFF
            g_fMetalHealFxEnd[client] = 0.0;
            Metal_AvatarTintReset(client);
            Metal_HealLightOff(client);
        }
        else
        {
            float t = now - g_fMetalHealFxStart[client];
            float alpha;
            if (t < METAL_HEAL_FX_FADE)
                alpha = t / METAL_HEAL_FX_FADE;
            else
                alpha = (METAL_HEAL_FX - t) / METAL_HEAL_FX_FADE;
            if (alpha < 0.0) alpha = 0.0;
            if (alpha > 1.0) alpha = 1.0;
            int a = RoundToNearest(alpha * 255.0);

            int avR = EntRefToEntIndex(g_iMetalAvatar[client]);
            if (avR > 0 && IsValidEntity(avR))
            {
                SetEntityRenderMode(avR, RENDER_TRANSCOLOR);
                SetEntityRenderColor(avR, 0, 255, 0, a);
            }
            int avL = EntRefToEntIndex(g_iMetalAvatarL[client]);
            if (avL > 0 && IsValidEntity(avL))
            {
                SetEntityRenderMode(avL, RENDER_TRANSCOLOR);
                SetEntityRenderColor(avL, 0, 255, 0, a);
            }
        }
    }

    if (now < g_fMetalHealNextTick[client]) return;

    // v5.2 ajuste 6: CON SOPORTE (Tails/Eggman a 250u) el tick corre x2
    // de rápido — "curarse más rápido si está con eggman o tails"
    float tick = Metal_SupportAuraActive(client)
        ? METAL_HEAL_TICK / METAL_HEAL_AURA_MULT
        : METAL_HEAL_TICK;
    g_fMetalHealNextTick[client] = now + tick;

    // lua l.984/1008: tope de HP o tope de acumulado -> cierre limpio
    int hp = GetClientHealth(client);
    if (hp > METAL_HEAL_HP_CAP || g_iMetalHealTotal[client] >= METAL_HEAL_TOTAL_CAP)
    {
        Metal_StopHeal(client, true);
        return;
    }

    // El tick: +7 HP y +7 al acumulado (lua l.993-995)
    g_iMetalHealTotal[client] += METAL_HEAL_AMOUNT;
    int newHp = hp + METAL_HEAL_AMOUNT;
    SetEntityHealth(client, newHp);

    // v5.1: EL EFECTO ORIGINAL DEL TICK (lua l.987-988, ventana 0.5*0.5):
    // (1) MetalSonicHeal_highlight -> abre el flash del TINTE VERDE (el
    //     bloque de arriba lo anima frame a frame) + DLIGHT VERDE ON
    //     (light_dynamic parentada, la luz de escena del GMod)
    // (2) metalsonic_ability_outline -> halo BLANCO fino (UI l.135-148,
    //     om_halo blur 1): outline por shader no portable — anillo TE
    //     fino blanco en el pecho, vida 0.25s (el pulso blanco por tick)
    g_fMetalHealFxStart[client] = now;
    g_fMetalHealFxEnd[client]   = now + METAL_HEAL_FX;

    int luz = EntRefToEntIndex(g_iMetalHealLight[client]);
    if (luz > 0 && IsValidEntity(luz) && !g_bMetalHealLightOn[client])
    {
        AcceptEntityInput(luz, "TurnOn");
        g_bMetalHealLightOn[client] = true;
    }

    float pos[3];
    GetClientAbsOrigin(client, pos);
    pos[2] += 40.0;   // pecho (donde va el halo del GMod)
    int haloColor[4] = {255, 255, 255, 220};
    TE_SetupBeamRingPoint(pos, 8.0, 48.0, g_iMetalSpriteGlow, g_iMetalSpriteGlow,
                          0, 15, METAL_HEAL_FX, 2.0, 0.0, haloColor, 0, 0);
    TE_SendToAll();

    // lua l.997-1005: Heal.wav por tick
    if (g_bMetalSndHeal)
        EmitSoundToAll("om/metal/Heal.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("items/smallmedkit1.wav", client, _, METAL_SND_LEVEL);

    PrintCenterText(client, "REPARANDO... +%d HP (%d/%d)", METAL_HEAL_AMOUNT, g_iMetalHealTotal[client], METAL_HEAL_TOTAL_CAP);

    // cierre inmediato si ESTE tick tocó el tope (lua l.1008-1011)
    if (newHp > METAL_HEAL_HP_CAP || g_iMetalHealTotal[client] >= METAL_HEAL_TOTAL_CAP)
        Metal_StopHeal(client, true);
}

// Cierra la reparación (completa o cancelada por dano/stun) — lua
// l.1016-1038: cooldown SIEMPRE + healfinished.wav + si curo al menos 1
// tick (TotalHeals > 7 alla): anim HealToIldle + NoMovement 0.5s.
void Metal_StopHeal(int client, bool completed)
{
    g_bMetalHealing[client] = false;
    g_fMetalHealAnimEnd[client] = 0.0;
    g_fMetalHealCD[client] = GetEngineTime() + METAL_HEAL_COOLDOWN;

    // v5.1: el destello y la LUZ VERDE fuera SIEMPRE al cerrar (natural,
    // dano que cancela, stun — por cualquier vía)
    if (g_fMetalHealFxEnd[client] > 0.0)
    {
        g_fMetalHealFxEnd[client] = 0.0;
        Metal_AvatarTintReset(client);
    }
    Metal_KillHealLight(client);

    SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);

    if (g_bMetalSndHealFin)
        EmitSoundToAll("om/metal/healfinished.wav", client, _, METAL_SND_LEVEL);
    else
        EmitSoundToAll("items/healthcharger.wav", client, _, METAL_SND_LEVEL);

    if (g_iMetalHealTotal[client] >= METAL_HEAL_AMOUNT)
    {
        // lua l.1030-1037: salida con 0.5s de rigidez (la FSM engancha el
        // one-shot HealToIldle con su lock)
        g_fMetalHealExitEnd[client] = GetEngineTime() + METAL_HEAL_EXIT_FREEZE;
        g_fMetalAnimLock[client]    = GetEngineTime() + 0.5;   // FSM: HealToIldle
        g_iMetalAnimState[client]   = METAL_ST_HEAL2IDLE;      // forzar one-shot
        int av = EntRefToEntIndex(g_iMetalAvatar[client]);
        if (av > 0 && IsValidEntity(av))
        {
            SetVariantString(g_sMetalAnimSeq[METAL_ST_HEAL2IDLE]);
            AcceptEntityInput(av, "SetAnimation");
        }
        int avL = EntRefToEntIndex(g_iMetalAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            SetVariantString(g_sMetalAnimSeq[METAL_ST_HEAL2IDLE]);
            AcceptEntityInput(avL, "SetAnimation");
        }
        PrintCenterText(client, completed
            ? "Reparación completa: %d HP. (%.0fs de recarga)"
            : "Reparación interrumpida: %d HP. (%.0fs de recarga)",
            GetClientHealth(client), METAL_HEAL_COOLDOWN);
    }
    else
    {
        PrintCenterText(client, "Reparación interrumpida (%.0fs de recarga).", METAL_HEAL_COOLDOWN);
    }
    g_iMetalHealTotal[client] = 0;
}

// =======================
// v5.0: EMBESTIDA POR EL SUELO — helpers
// =======================
// (v3.5/v4.x: TODO el MODO AIRE FLYGRAVITY (AirGetMaxSpeed/AirSetMaxSpeed/
//  AirModeEnter/AirModeExit) SE BORRA — pedido del owner 3.77.25: "usaremos
//  el truco que usamos con sonic, lo de desplazarse por el suelo, ya que
//  actualmente la embestida de metal usa algo diferente". El mecanismo
//  nuevo es EXACTAMENTE el del spindash de Sonic (sonic.inc v6.x):
//   - Metal_DashSpeedSet: registra el objetivo de velocidad en el SLOT 2
//     del stack ADITIVO del Speed_sonic -> el writer del stack escribe
//     m_flMaxspeed = objetivo cada tick. Si !speed o adrenalina están
//     activos, la fórmula del stack los respeta (aditivo puro).
//   - El AUTO-FORWARD lo inyecta Metal_OnPlayerRunCmd (vel[0] saturado):
//     el MOTOR mueve a Metal con la física de caminar hacia donde MIRA —
//     el equivalente exacto del OM_MoveForward del GMod.
//   - EL MOTOR hace el resto: sube escalones, sigue rampas, gravedad
//     normal, nunca despega, se frena contra la pared (que el
//     Metal_HitWall detecta para el slam).
// Lo que SI se conserva del v3.5: el grupo de colisión DEBRIS durante el
// dash (atraviesa cuerpos como el mod) y el frenado suave a la salida.

// Registra el objetivo del dash en el SLOT 2 del stack (receta exacta del
// Sonic_StartRoll: extra = objetivo/base - 1; idempotente y auto-curado
// por tick — el propio writer refina m_flMaxspeed cada frame).
void Metal_DashSpeedSet(int client, float target)
{
    float base = Speed_GetBaseSpeed(client);
    if (base < 50.0) base = 220.0;
    float extra = target / base - 1.0;
    if (extra < 0.0) extra = 0.0;
    Speed_StackSet(client, SPEED_STACK_METAL_DASH, extra);
}

// Entra al dash: guardar grupo de colisión y poner DEBRIS (atraviesa
// cuerpos: comunes, SI, tank — como el mod que no colisiona con criaturas
// durante la carga). El movetype queda WALK: va por el suelo.
void Metal_DashColEnter(int client)
{
    if (!Metal_IsValidClient(client)) return;
    g_iMetalSavedColGroup[client] = GetEntProp(client, Prop_Data, "m_CollisionGroup");
    SetEntProp(client, Prop_Data, "m_CollisionGroup", METAL_DASH_COLGROUP);
}

// Sale del dash: restaura grupo de colisión + frenado suave opcional del
// momentum horizontal (damp > 0: sin esto saldría deslizando a 750).
void Metal_DashColExit(int client, float damp = 0.0)
{
    if (client <= 0 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;

    if (g_iMetalSavedColGroup[client] > 0)
        SetEntProp(client, Prop_Data, "m_CollisionGroup", g_iMetalSavedColGroup[client]);
    g_iMetalSavedColGroup[client] = -1;

    if (damp > 0.0 && IsPlayerAlive(client))
    {
        float vel[3], endVel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        endVel[0] = vel[0] * damp;
        endVel[1] = vel[1] * damp;
        endVel[2] = vel[2];
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, endVel);
    }
}

// (v3.6: Metal_OverdriveFlyTick y Metal_OverdriveInterrupt ELIMINADOS —
//  el Overdrive ya no es un modo aéreo: es un buff de dano + velocidad
//  real registrado en el stack del Speed_sonic. v5.0: el FLYGRAVITY
//  también se retira — la embestida va por el suelo con el mismo stack.)

// =======================
// UTILIDADES
// =======================

// v4.0: detección de pared con SALIDA de posición + normal (necesarias
// para pinear al infectado contra la pared y para el empuje final).
// Receta Amy v62 intacta: rayo desde los OJOS a 70u, criaturas fuera
// (filtro LOS), una superficie solo es PARED si NO es transitable
// (normal.z < 0.7, pared empinada) o si es un prop/puerta solido.
bool Metal_WallTrace(int client, float hitPos[3], float hitNrm[3])
{
    float pos[3], endPos[3], ang[3], fwd[3];
    GetClientEyePosition(client, pos);
    GetClientEyeAngles(client, ang);

    GetAngleVectors(ang, fwd, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(fwd, METAL_WALL_AHEAD);
    AddVectors(pos, fwd, endPos);

    Handle trace = TR_TraceRayFilterEx(pos, endPos, MASK_SOLID, RayType_EndPoint, Metal_TraceFilter_LOS, client);
    bool wall = false;
    if (TR_DidHit(trace))
    {
        float normal[3];
        TR_GetPlaneNormal(trace, normal);
        int hitEnt = TR_GetEntityIndex(trace);
        wall = (hitEnt > 0) || (normal[2] < METAL_WALL_WALK_NORMAL_Z);
        if (wall)
        {
            TR_GetEndPosition(hitPos, trace);
            hitNrm[0] = normal[0];
            hitNrm[1] = normal[1];
            hitNrm[2] = normal[2];
        }
    }
    delete trace;
    return wall;
}

// Wrapper v3.5 (compatibilidad): solo importa SI hay pared delante.
bool Metal_HitWall(int client)
{
    float dummyPos[3], dummyNrm[3];
    return Metal_WallTrace(client, dummyPos, dummyNrm);
}

public bool Metal_TraceFilter_LOS(int entity, int contentsMask, any data)
{
    if (entity == 0) return true;            // mundo
    if (entity <= MaxClients) return false;  // jugadores (Metal incluido)

    static char cls[16];
    GetEntityClassname(entity, cls, sizeof(cls));
    if (StrEqual(cls, "infected", false)) return false;   // comunes
    if (StrEqual(cls, "witch", false)) return false;      // witches

    return true;  // props, puertas y demas solidos del mapa
}

// =======================
// HOOKS DE CICLO DE VIDA
// =======================

// v5.0: suelta al infectado agarrado (lo compartian la muerte PRE y la
// limpieza de cambio de personaje: mismo código, un solo lugar)
// v5.3 puntos 3+4: ahora también (a) restaura el grupo de colisión del
// ARRASTRADO (queda en DEBRIS durante el arrastre anti-atasco) y (b)
// restaura a la WITCH completa (colisión + movetype + fling opcional).
// hardRestore=false toca SOLO lo que Metal modifico (el stun del
// infectado sigue su curso — sueltas naturales); true además libera
// movimiento (caminos de muerte/cancel/atasco).
void Metal_ReleaseGrabbed(int client, bool hardRestore = true)
{
    // v6.0: la victima deja de ser arrastrada -> su TORMENTA DE ARCOS
    // muere AQUÍ (el punto de suelta UNIVERSAL: drop por cap, cancel,
    // muerte del objetivo, atasco, timeout, slam-end — todos pasan)
    Metal_FxArcsStop(client);

    // ---- WITCH ----
    if (g_iMetalWitchTarget[client] != 0)
    {
        int witch = Metal_GetWitchTarget(client);
        if (witch != -1)
            Metal_WitchRelease(client, witch, hardRestore);
        else
            g_iMetalWitchTarget[client] = 0;   // ya no existe (murió/removida)
    }

    // ---- INFECTADO ESPECIAL (cliente) ----
    int target = g_iMetalGrabbedTarget[client];
    if (target > 0 && IsClientInGame(target) && IsPlayerAlive(target))
    {
        if (g_iMetalVictimColGroup[client] > 0)
        {
            SetEntProp(target, Prop_Data, "m_CollisionGroup", g_iMetalVictimColGroup[client]);
        }

        if (hardRestore)
        {
            SetEntityMoveType(target, MOVETYPE_WALK);
            SetEntPropFloat(target, Prop_Send, "m_flLaggedMovementValue", 1.0);
        }
    }
    g_iMetalVictimColGroup[client] = -1;
    g_iMetalGrabbedTarget[client] = -1;
}

// Limpieza al morir/cambiar de personaje/desconectar (llamada desde
// Sonic_ability_manager.sp -> Event_PlayerDeath PRE vía Metal_Event_
// PlayerDeath NO — ese ya no la usa — y desde CleanupCharModuleState).
// v5.0: ahora TAMBIÉN mata el avatar y restaura el cuerpo (la muerte REAL
// del avatar la hace Metal_Event_DeathPost en POST; en los cambios de
// personaje/desconexion no hay POST del que fiarse, se limpia aquí).
public void Metal_OnPlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return;

    // Liberar al infectado si estaba agarrado
    Metal_ReleaseGrabbed(client);

    // v3.1: Metal_ResetState ahora también restaura visuals/movimiento del
    // propio Metal (por si murió congelado en WALL_SLAM/BOUNCE o teñido)
    Metal_ResetState(client);

    // v5.0: avatar fuera (sin ragdoll: el jugador no murió — cambio de
    // personaje o desconexion)
    Metal_KillAvatar(client);
}

// v3.1: Evento de muerte REAL (llamar SOLO desde Event_PlayerDeath del
// manager). Las limpiezas de estado (cambio de personaje, descarga del
// plugin) deben seguir usando Metal_OnPlayerDeath para NO detonar.
// v5.0: ESTE hook (que el manager invoca en PRE) ya NO toca el avatar —
// la muerte del avatar (ragdoll + anti-corpse) corre en el player_death
// POST propio (Metal_Event_DeathPost, receta Sonic v3.76.2: en PRE el
// restore del cuerpo dejaba ver el corpse del survivor).
public void Metal_Event_PlayerDeath(int client)
{
    if (!IsValidClient(client)) return;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return;

    // v3.1: primero liberar al infectado agarrado y limpiar el estado, y
    // detonar DESPUÉS (así la explosión también aturde al infectado que
    // estaba agarrado, en vez de liberarlo pisando el slow de la explosión)
    // (la cura también se cierra por ResetState)
    Metal_ReleaseGrabbed(client);
    Metal_ResetState(client);

    // v3.1 FIX PASIVA "Explota al morir": detonar siempre que muere de
    // verdad (infectados, suicidio, cualquier causa), no solo por el
    // auto-dano de la carga como antes.
    Metal_Detonate(client);
}

// v3.1: reset defensivo al spawn (por si quedó estado residual de la vida
// anterior: MOVETYPE_NONE, tinte rojo del parpadeo, velocidad bloqueada...)
public void Metal_Event_PlayerSpawn(Event event, const char[] name, int client)
{
    if (client <= 0 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return;

    Metal_ResetState(client);

    // v5.0: montar el avatar ya (patron Sonic: la FSM de 10 Hz lo
    // re-monta sola si algo sale raro con el orden de eventos)
    if (g_cvMetalAvatar != null && g_cvMetalAvatar.BoolValue && g_bMetalModelOK
        && GetClientTeam(client) == 2 && IsPlayerAlive(client))
    {
        Metal_CreateAvatar(client);
    }

    // v5.3 punto 5: nacer siendo Metal = tope de vida 175 (y vida llena a
    // 175 si viene con el 100 por defecto del spawn). El re-afirmador del
    // PreThink lo sostiene y el botiquin cura hacia aquí.
    Metal_ApplyMaxHealth(client);
}

// v5.0: RunCmd — EL AUTO-FORWARD DE LA EMBESTIDA POR SUELO.
// El manager pasa el wishvel del usercmd: durante DASH y DRAGGING se
// satura vel[0] (forwardmove) para que el MOTOR mueva a Metal a
// m_flMaxspeed (750, alzado por el SLOT 2 del stack) con la física de
// caminar — el equivalente exacto del OM_MoveForward del GMod ("el
// jugador SOLO dirige con la mira"). vel[1] a 0: sin lateral (el
// charge_slippery del mod es default off). Devuelve true si tocó el
// usercmd (el manager traduce a Plugin_Changed).
public bool Metal_OnPlayerRunCmd(int client, int &buttons, float vel[3])
{
    if (client < 1 || client > MaxClients) return false;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return false;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return false;

    int state = g_iMetalChargeState[client];
    if (state != METAL_STATE_DASH && state != METAL_STATE_DRAGGING)
        return false;

    // forwardmove saturado (>= maxspeed: el engine clampea el wishspeed
    // a m_flMaxspeed = la velocidad objetivo del stack)
    vel[0] = 900.0;
    vel[1] = 0.0;
    if (vel[2] < 0.0) vel[2] = 0.0;   // sin upmove raro durante la carga
    return true;
}

// =====================================================================
// v5.0: SISTEMA DE AVATAR — patron sonic.inc v6.30 (doble copia R/L +
// modo TP + pulso de pausa + FSM de animación del metal.mdl)
// =====================================================================

// Crea el prop base (avatar R o L): parentado al survivor, sin sombras,
// EF_NOINTERP al nacer (nace ENCAJADO). tpMode = la copia R viaja por
// TeleportEntity + reloj vivo (tails_avatar_tp): los clientes de los
// demas la INTERPOLAN suave (la L siempre parentada).
int Metal_CreateAvatarProp(int client, const char[] model, const char[] targetname, bool tpMode = false)
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
    g_fMetalBodyYaw[client]  = ang[1];
    g_fMetalYawLastT[client] = GetEngineTime();
    TeleportEntity(av, pos, ang, NULL_VECTOR);

    float loc[3];
    Tails_AvatarLocalAngles(0.0, ang[1], g_fMetalBodyYaw[client], loc);

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
        g_fMetalSmLoc[client][k]  = loc[k];
        g_fMetalSmLocL[client][k] = loc[k];
    }
    g_bMetalSmSnap[client] = true;

    if (!tpMode)
        Tails_SetAvatarNoInterp(av, true);
    return av;
}

// Monta el avatar completo (R + L + cuerpo oculto). pulsePause SOLO para
// montajes de ciclo de vida (spawn/selección/reparación tardia de la FSM).
// =====================================================================
// v5.6-OM (manager 3.77.40): ADOPCION EN EL MONTAJE — el reemplazo del
// barrido en caliente (orden del owner 2026-10-10: "tu barrido de
// avatares está haciendo reiniciar mi avatar a cada rato... BUSCA OTRA
// MANERA"). Esta FSM es la ÚNICA creadora de props con los nombres de
// abajo: un prop así que ELLA no rastrea es un huerfano por definición
// (lo fabrico una vida anterior, un montaje doble del pasado o una
// versión vieja del suite) y muere en el instante exacto del montaje.
// Un avatar rastreado es INTOCABLE: no existe ningún timer que lo mire.
// =====================================================================
bool Metal_IsMyAvatarRef(int ref)
{
    // v3.77.40: el 0 es "sin avatar"; un ref NEGATIVO puede ser
    // perfectamente legitimo (bit alto del serial del handle).
    if (ref == 0 || ref == INVALID_ENT_REFERENCE) return false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iMetalAvatar[i] == ref) return true;
        if (g_iMetalAvatarL[i] == ref) return true;
    }
    return false;
}

void Metal_KillGhostAvatarProps()
{
    static const char sGhostNames[][] = { "metal_avatar_om", "metal_avatar_om_l", "metalom_avatar" };
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
                if (Metal_IsMyAvatarRef(EntIndexToEntRef(ent))) break;
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
        PrintToServer("[Metal v5.6-OM] Adopción del montaje: %d huerfano(s) del avatar eliminado(s).", ng);
}

void Metal_CreateAvatar(int client, bool pulsePause = true)
{
    if (!g_bMetalModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;

    // v5.0: la copia R nace en modo TP si tails_avatar_tp (la que ven
    // los DEMAS viaja por teleport por tick + interpolación de red)
    // v5.6-OM (manager 3.77.40): REEMPLAZO LIMPIO — orden del owner
    // 2026-10-10: en caliente YA NO EXISTE barrido. Si este cliente ya
    // tenía un R o L vivo (montaje doble por orden raro de eventos),
    // muere AQUÍ enterito: jamás vuelve a quedar un prop sin dueño (la
    // fábrica de huerfanos del "= 0" sin Kill queda cerrada).
    {
        int oldR = EntRefToEntIndex(g_iMetalAvatar[client]);
        if (g_iMetalAvatar[client] != 0 && oldR > 0 && IsValidEntity(oldR))
        {
            SDKUnhook(oldR, SDKHook_SetTransmit, Metal_TransmitAvatarR);
            AcceptEntityInput(oldR, "Kill");
        }
        g_iMetalAvatar[client] = 0;

        int oldL = EntRefToEntIndex(g_iMetalAvatarL[client]);
        if (g_iMetalAvatarL[client] != 0 && oldL > 0 && IsValidEntity(oldL))
        {
            SDKUnhook(oldL, SDKHook_SetTransmit, Metal_TransmitAvatarL);
            AcceptEntityInput(oldL, "Kill");
        }
        g_iMetalAvatarL[client] = 0;
    }

    // v5.6-OM: ADOPCION — todo prop de ESTE modulo que la FSM no rastrea
    // es un huerfano: muere en este instante del montaje, no en un
    // timer a ciegas.
    Metal_KillGhostAvatarProps();

    int av = Metal_CreateAvatarProp(client, METAL_OM_MODEL, METAL_AVATAR_NAME, Tails_AvatarTPOn());
    if (av == 0) return;

    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");
    g_iMetalAnimState[client] = 0;

    SDKHook(av, SDKHook_SetTransmit, Metal_TransmitAvatarR);

    g_iMetalAvatarL[client] = 0;
    Metal_CreateAvatarL(client);

    // ocultar el cuerpo del survivor (el avatar ES el personaje ahora)
    RenderMode curMode = GetEntityRenderMode(client);
    if (curMode != RENDER_NONE)
        g_iMetalBodyRender[client] = view_as<int>(curMode);
    else if (g_iMetalBodyRender[client] == -1)
        g_iMetalBodyRender[client] = view_as<int>(RENDER_NORMAL);
    SetEntityRenderMode(client, RENDER_NONE);

    g_iMetalAvatar[client] = EntIndexToEntRef(av);

    // per-tick: angulos locales (contra-rotación del parent)
    SDKHook(client, SDKHook_PostThink, Metal_AvatarFollow);

    // PULSO DE PAUSA en cada montaje de ciclo de vida (la misma infra
    // sv_pausable del suite; convar tails_pausefix manda para TODOS los
    // avatares — es UN solo sistema, 4o avatar del suite)
    if (pulsePause)
        Tails_PauseFix_Trigger(client);
}

void Metal_CreateAvatarL(int client)
{
    if (!g_bMetalModelOK) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;
    if (GetClientTeam(client) != 2) return;
    if (g_iMetalAvatar[client] == 0) return;

    int av = Metal_CreateAvatarProp(client, METAL_OM_MODEL, "metal_avatar_om_l");
    if (av == 0) return;

    SetVariantString("idle");
    AcceptEntityInput(av, "SetAnimation");

    SDKHook(av, SDKHook_SetTransmit, Metal_TransmitAvatarL);

    g_iMetalAvatarL[client] = EntIndexToEntRef(av);
}

void Metal_KillAvatarL(int client)
{
    if (client < 1 || client > MaxClients) return;
    int avL = EntRefToEntIndex(g_iMetalAvatarL[client]);
    if (g_iMetalAvatarL[client] != 0 && avL > 0 && IsValidEntity(avL))
    {
        SDKUnhook(avL, SDKHook_SetTransmit, Metal_TransmitAvatarL);
        AcceptEntityInput(avL, "Kill");
    }
    g_iMetalAvatarL[client] = 0;
}

// Mata las copias R+L y devuelve el cuerpo. SIN desenganchrar el follow
// (lo hace Metal_KillAvatar).
void Metal_KillAvatarOnly(int client)
{
    if (client < 1 || client > MaxClients) return;

    Metal_KillAvatarL(client);

    int av = EntRefToEntIndex(g_iMetalAvatar[client]);
    if (g_iMetalAvatar[client] != 0 && av > 0 && IsValidEntity(av))
    {
        SDKUnhook(av, SDKHook_SetTransmit, Metal_TransmitAvatarR);
        AcceptEntityInput(av, "Kill");
    }
    g_iMetalAvatar[client] = 0;

    // devolver el cuerpo SI el jugador sigue conectado (muerte/cambio de
    // personaje/desconexion: el corpse que pueda aparecer lo filtra la
    // ventana anti-ragdoll de abajo)
    if (IsClientInGame(client))
    {
        if (g_iMetalBodyRender[client] != -1)
        {
            SetEntityRenderMode(client, view_as<RenderMode>(g_iMetalBodyRender[client]));
            g_iMetalBodyRender[client] = -1;
        }
    }
    else
        g_iMetalBodyRender[client] = -1;

    g_iMetalAnimState[client] = -1;
}

void Metal_KillAvatar(int client)
{
    if (client < 1 || client > MaxClients) return;
    Metal_KillAvatarOnly(client);
    SDKUnhook(client, SDKHook_PostThink, Metal_AvatarFollow);
}

// Transmit filters (patron Sonic): la R no la ve su dueño (tiene su L),
// la L la ve SOLO su dueño.
public Action Metal_TransmitAvatarR(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iMetalAvatar[i] != 0 && EntRefToEntIndex(g_iMetalAvatar[i]) == entity)
        {
            if (client == i && g_iMetalAvatarL[i] != 0
                && EntRefToEntIndex(g_iMetalAvatarL[i]) > 0)
                return Plugin_Handled;   // el dueño tiene su copia L
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

public Action Metal_TransmitAvatarL(int entity, int client)
{
    if (client < 1) return Plugin_Continue;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iMetalAvatarL[i] != 0 && EntRefToEntIndex(g_iMetalAvatarL[i]) == entity)
        {
            if (client == i) return Plugin_Continue;   // el dueño si
            return Plugin_Handled;                     // nadie más
        }
    }
    return Plugin_Continue;
}

// FOLLOW PER-TICK (lecciones Tails/Sonic: yaw suave con deadband 3
// grados, contra-rotación amortiguada, reloj vivo, copia L contra los
// eye angles del dueño; la R por TP en modo tp)
public void Metal_AvatarFollow(int client)
{
    if (g_iMetalAvatar[client] == 0)
    {
        SDKUnhook(client, SDKHook_PostThink, Metal_AvatarFollow);
        return;
    }
    if (!IsPlayerAlive(client)) return;   // la FSM mata el avatar en <=0.1s

    // ---- yaw objetivo: dirección REAL del movimiento ----
    float yawObj = g_fMetalBodyYaw[client];
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    if (vel[0] * vel[0] + vel[1] * vel[1] > 1600.0)   // > 40 u/s
    {
        float velYaw = RadToDeg(ArcTangent2(vel[1], vel[0]));
        float dv = velYaw - g_fMetalBodyYaw[client];
        while (dv > 180.0)  dv -= 360.0;
        while (dv < -180.0) dv += 360.0;
        if (dv > 3.0 || dv < -3.0)
            yawObj = velYaw;
    }

    // ---- giro suave hacia el objetivo (~900 grados/s) ----
    float now = GetEngineTime();
    float dt  = now - g_fMetalYawLastT[client];
    g_fMetalYawLastT[client] = now;
    if (dt <= 0.0 || dt > 0.3) dt = 0.033;

    float d = yawObj - g_fMetalBodyYaw[client];
    while (d > 180.0)  d -= 360.0;
    while (d < -180.0) d += 360.0;
    float step = 900.0 * dt;
    if (d >  step) d =  step;
    if (d < -step) d = -step;
    g_fMetalBodyYaw[client] += d;

    float par[3], loc[3];
    bool snap = g_bMetalSmSnap[client];
    GetClientAbsAngles(client, par);

    // ---- copia R ----
    int av = EntRefToEntIndex(g_iMetalAvatar[client]);
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
            angTP[1] = g_fMetalBodyYaw[client];
            angTP[2] = 0.0;                      // roll NUNCA
            TeleportEntity(av, posTP, angTP, NULL_VECTOR);
            Tails_MarkInterp(av);
        }
        else
        {
            Tails_AvatarLocalAngles(par[0], par[1], g_fMetalBodyYaw[client], loc);
            loc[1] = Tails_UnwrapYaw(g_fMetalSmLoc[client][1], loc[1]);
            Tails_ExpDamp(loc, g_fMetalSmLoc[client], 0.05, dt, snap);
            if (HasEntProp(av, Prop_Send, "m_angRotation"))
                SetEntPropVector(av, Prop_Send, "m_angRotation", g_fMetalSmLoc[client]);
            Tails_MarkInterp(av);
        }
    }

    // ---- copia L: contra-rotada contra los EYE del dueño ----
    if (g_iMetalAvatarL[client] != 0)
    {
        int avL = EntRefToEntIndex(g_iMetalAvatarL[client]);
        if (avL > 0 && IsValidEntity(avL))
        {
            float eye[3], locL[3];
            GetClientEyeAngles(client, eye);
            Tails_AvatarLocalAngles(eye[0], eye[1], g_fMetalBodyYaw[client], locL);
            locL[1] = Tails_UnwrapYaw(g_fMetalSmLocL[client][1], locL[1]);
            Tails_ExpDamp(locL, g_fMetalSmLocL[client], 0.05, dt, snap);
            if (HasEntProp(avL, Prop_Send, "m_angRotation"))
                SetEntPropVector(avL, Prop_Send, "m_angRotation", g_fMetalSmLocL[client]);
            Tails_MarkInterp(avL);
        }
    }
    g_bMetalSmSnap[client] = false;
}

// FSM de 10 Hz: montaje / auto-reparación / muerte del avatar (patron
// T_SonicAvatarThink)
public Action T_MetalAvatarThink(Handle timer)
{
    float now = GetEngineTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) { Metal_KillAvatar(i); continue; }

        bool esMetalVivo = (g_iPlayerCharIdx[i] == METALSONIC_INDEX
                            && IsPlayerAlive(i) && GetClientTeam(i) == 2);

        // v5.0: incap = fuera (el Metal tiene Sin-Incap, pero mods de
        // terceros pueden tirarlo al suelo: avatar fuera, cuerpo visible)
        if (esMetalVivo && GetEntProp(i, Prop_Send, "m_isIncapacitated") > 0)
            esMetalVivo = false;

        // ---- montaje ----
        if (g_iMetalAvatar[i] == 0)
        {
            if (esMetalVivo && g_cvMetalAvatar != null && g_cvMetalAvatar.BoolValue
                && g_bMetalModelOK)
            {
                Metal_CreateAvatar(i);
            }
            continue;
        }

        // quitar avatar si dejó de ser un Metal survivor vivo de pie
        if (!esMetalVivo)
        {
            Metal_KillAvatar(i);
            continue;
        }

        int av = EntRefToEntIndex(g_iMetalAvatar[i]);
        if (av <= 0 || !IsValidEntity(av))
        {
            g_iMetalAvatar[i] = 0;
            g_iMetalAnimState[i] = -1;
        }

        // reafirmar el RENDER_NONE del cuerpo (el motor lo resetea al
        // cambiar de capítulo/rescue: fix Tails v5.4)
        if (g_iMetalBodyRender[i] != -1 && GetEntityRenderMode(i) != RENDER_NONE)
            SetEntityRenderMode(i, RENDER_NONE);

        // auto-reparación de la copia L (montaje tardio: pulso también)
        if (g_iMetalAvatarL[i] == 0 && g_iMetalAvatar[i] != 0)
        {
            Metal_CreateAvatarL(i);
            if (g_iMetalAvatarL[i] != 0)
                Tails_PauseFix_Trigger(i);
        }

        // ---- FSM de animación ----
        av = EntRefToEntIndex(g_iMetalAvatar[i]);
        if (g_iMetalAvatar[i] != 0 && av > 0 && IsValidEntity(av))
            Metal_AvatarUpdate(i, av, now);
    }
    return Plugin_Continue;
}

// =====================================================================
// FSM DE ANIMACION (prioridades GMod ShouldAlternate l.247-273:
// heal y charge sustituyen a idle/walk/run/fall mientras duran;
// ChargeUp/Slam/HealToIldle son one-shots con AlternatePlaySolution)
// =====================================================================
void Metal_AvatarUpdate(int client, int av, float now)
{
    // lock de one-shot en curso (HealToIldle): no reevaluar
    if (now < g_fMetalAnimLock[client]) return;

    int state = 0;
    float rate = 1.0;
    int cstate = g_iMetalChargeState[client];

    if (cstate == METAL_STATE_WINDUP)
    {
        // el windup entero es el ChargeUp one-shot del lua (l.1704-1706)
        state = METAL_ST_CHARGEUP;
    }
    else if (cstate == METAL_STATE_WALL_SLAM)
    {
        // cada golpe re-dispara un Slam (lua l.1368-1371: PillAnim('Slam'..
        // MathRandom)): alterna 1/2 por golpe ya disparado
        state = METAL_ST_SLAM1 + (g_iMetalSlamHitsFired[client] % 2);
    }
    else if (cstate == METAL_STATE_DASH || cstate == METAL_STATE_DRAGGING)
    {
        // la embestida corre en "charge" (velocidad al ritmo del run)
        state = METAL_ST_CHARGE;
        float s = Metal_Speed2D(client);
        rate = 1.32 * (s / 450.0);
        if (rate < 0.72) rate = 0.72;
        if (rate > 3.6)  rate = 3.6;
    }
    else if (now < g_fMetalHealAnimEnd[client] || g_bMetalHealing[client])
    {
        // el ciclo de reparación entero va en "heal"
        state = METAL_ST_HEAL;
    }
    else if (!(GetEntityFlags(client) & FL_ONGROUND))
    {
        // AIRE (v5.2 ajuste 5 — receta Sonic "ventana del jump completa"):
        // sube = jump; cae = fall PERO si el one-shot de jump todavia
        // está vivo (arranco hace < 0.5s o el ciclo del modelo no
        // termino), el jump SIGUE — el "jump" del metal.mdl ya no se
        // corta a la primera (fix del "salto a veces interrumpido")
        float vel[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
        if (vel[2] > 40.0)
        {
            state = 3;
        }
        else
        {
            bool jumpLive = false;
            if (g_iMetalAnimState[client] == 3)
            {
                float jt = now - g_fMetalJumpStart[client];
                if (jt < 0.5)      jumpLive = true;
                else if (jt < 1.5 && !Metal_JumpAnimDone(av)) jumpLive = true;
            }
            state = jumpLive ? 3 : 4;
        }
    }
    else if (g_iMetalAnimState[client] == 3 && !Metal_JumpAnimDone(av)
             && now - g_fMetalJumpStart[client] < 0.5)
    {
        // v5.2 ajuste 5: FL_ONGROUND parpadea al saltar rozando escalones
        // / paredes — mientras el one-shot del jump este vivo (<= 0.5s),
        // NO bajar a walk/run aunque el flag diga "en suelo" un instante
        state = 3;
    }
    else
    {
        float s = Metal_Speed2D(client);
        if (s < 40.0)
            state = 0;
        else if (s < 150.0 || (GetClientButtons(client) & IN_DUCK))
        {
            state = 1;
            // v5.2 ajuste 5: WALK al rate 1.0 CONSTANTE del GMod — Metal
            // NO define animrates en su lua (noodles_om_pills_base.lua
            // l.936-944: sin animrates -> rate 1 para TODO). El v5.0 lo
            // jugaba a 1.8*(s/85) = "bastante rápida a comparación de los
            // demas" (Tails SI define walk 1.8; metal no).
            rate = 1.0;
        }
        else
        {
            state = 2;
            rate = 1.32 * (s / 450.0);
            if (rate < 0.72) rate = 0.72;
            if (rate > 3.6)  rate = 3.6;
        }
    }

    if (state != g_iMetalAnimState[client])
    {
        // v5.2: el t0 del jump para su ventana (receta Sonic)
        if (state == 3) g_fMetalJumpStart[client] = now;
        SetVariantString(g_sMetalAnimSeq[state]);
        AcceptEntityInput(av, "SetAnimation");
        if (g_iMetalAvatarL[client] != 0)
        {
            int avLA = EntRefToEntIndex(g_iMetalAvatarL[client]);
            if (avLA > 0 && IsValidEntity(avLA))
            {
                // el variant es de UN SOLO USO — re-armarlo
                SetVariantString(g_sMetalAnimSeq[state]);
                AcceptEntityInput(avLA, "SetAnimation");
            }
        }
        g_iMetalAnimState[client] = state;
    }

    if (rate < 0.05) rate = 0.05;
    if (HasEntProp(av, Prop_Data, "m_flPlaybackRate"))
        SetEntPropFloat(av, Prop_Data, "m_flPlaybackRate", rate);
    if (g_iMetalAvatarL[client] != 0)
    {
        int avLB = EntRefToEntIndex(g_iMetalAvatarL[client]);
        if (avLB > 0 && IsValidEntity(avLB)
            && HasEntProp(avLB, Prop_Data, "m_flPlaybackRate"))
            SetEntPropFloat(avLB, Prop_Data, "m_flPlaybackRate", rate);
    }
}

float Metal_Speed2D(int client)
{
    float vel[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    return SquareRoot(vel[0] * vel[0] + vel[1] * vel[1]);
}

// v5.2 ajuste 5: el one-shot del jump termino? (m_flCycle del prop —
// la misma sonda del Sonic_JumpAnimDone: el ciclo lo avanza el server
// en prop_dynamic)
bool Metal_JumpAnimDone(int av)
{
    if (av <= 0 || !IsValidEntity(av)) return true;
    if (HasEntProp(av, Prop_Data, "m_flCycle"))
        return GetEntPropFloat(av, Prop_Data, "m_flCycle") >= 0.95;
    return true;
}

// =====================================================================
// MUERTE DEL AVATAR (player_death POST propio — receta Sonic v3.76.2)
// =====================================================================
public void Metal_Event_DeathPost(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || client > MaxClients) return;
    if (!IsClientInGame(client)) return;
    if (g_iPlayerCharIdx[client] != METALSONIC_INDEX) return;
    if (g_iMetalAvatar[client] == 0) return;   // sin avatar: vanilla

    // ventana anti-corpse: 2s escondiendo ragdolls/corpses del survivor
    // que nazcan a 200u de la muerte (el cuerpo se acaba de devolver en
    // KillAvatar y el motor spawnea su corpse justo después)
    GetClientAbsOrigin(client, g_vMetalDeathOrigin[client]);
    g_fMetalDeathHideUntil[client] = GetEngineTime() + 2.0;

    Metal_SpawnDeathRagdoll(client);
    Metal_KillAvatar(client);
}

// Ragdoll OM: prop_ragdoll con metal.mdl (usa el .phy del modelo — el lua
// trae noragdoll=false) + limpieza a los 15s (receta Tails/Sonic)
void Metal_SpawnDeathRagdoll(int client)
{
    if (!g_bMetalModelOK) return;
    if (!IsClientInGame(client)) return;

    int rag = CreateEntityByName("prop_ragdoll");
    if (rag <= 0 || !IsValidEntity(rag)) return;

    DispatchKeyValue(rag, "model", METAL_OM_MODEL);
    DispatchSpawn(rag);

    float pos[3], ang[3], vel[3];
    GetClientAbsOrigin(client, pos);
    GetClientAbsAngles(client, ang);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
    TeleportEntity(rag, pos, ang, vel);

    CreateTimer(15.0, T_MetalRagdollCleanup, EntIndexToEntRef(rag), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_MetalRagdollCleanup(Handle timer, any ref)
{
    int ent = EntRefToEntIndex(view_as<int>(ref));
    if (ent > 0 && IsValidEntity(ent))
        AcceptEntityInput(ent, "Kill");
    return Plugin_Stop;
}

// Filtro anti-ragdoll (patron Sonic: lo enruta el OnEntityCreated
// central de Rouge.inc — Metal se incluye ANTES que Rouge en 3.77.25)
void Metal_OnEntityCreated(int entity, const char[] classname)
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
            if (g_fMetalDeathHideUntil[i] == 0.0 || now >= g_fMetalDeathHideUntil[i])
                continue;
            // candidata: revisar modelo/origen en el próximo frame
            RequestFrame(Metal_CheckDeathRagdoll, EntIndexToEntRef(entity));
            return;
        }
    }
}

public void Metal_CheckDeathRagdoll(any ref)
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
        if (g_fMetalDeathHideUntil[i] == 0.0 || now >= g_fMetalDeathHideUntil[i])
            continue;
        if (GetVectorDistance(o, g_vMetalDeathOrigin[i]) < 200.0)
        {
            SetEntityRenderMode(ent, RENDER_NONE);
            DispatchKeyValue(ent, "disableshadows", "1");
            AcceptEntityInput(ent, "DisableShadow");
            return;
        }
    }
}
