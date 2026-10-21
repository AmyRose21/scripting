# Worklog Consolidado — Sonic Suite L4D2
**Canon externo:** https://github.com/AmyRose21/scripting
**Última sync:** 2026-10-21 (commit 0ad0518 "New" — el owner ya subió la entrega kolossos_v1 al repo)

## 📜 PROTOCOLO DE USO (para cualquier agente/IA que trabaje en este proyecto)
1. Al inicio de cada tarea: `git pull` del repo — el repo SIEMPRE manda.
2. Nunca modificar código FX de la suite (regla de hierro del owner).
3. NUNCA reintroducir sistemas de bots supervivientes (OM Survivors / LoL Survivors fueron retirados por decisión terminante del owner el 2026-10-18 tras crashes en producción).
4. Compilar con 0 errores / 0 warnings. Compiladores: spcomp64 1.12.0.7119 (tools/) o 1.12.0.7255 (necesario para l4d2_pet_fusion / sizeof de g_Styles).
5. Cada tarea completada = nueva sección `Task ID: N` appendeada al final de este archivo (formato: Task / Work Log / Stage Summary).
6. Entregas vía TransferNow (scripts tnow_create_transfer.py + tnow_upload.py en scripts/).
7. Idioma de entrega: español. Entorno: listen server 127.0.0.1:27015, el owner es el host.

## 📌 ESTADO ACTUAL
- **Sonic_ability_manager: v3.77.95** (Kolossos.inc v1.1-OM: animaciones completas + fix del doblado). La v3.77.94 = kolossos_v1 (entrega base del port). Versiones 3.77.92/93 quemadas (era OM). Compilador: spcomp64 1.12.0.7119.
- **l4d2_pet_fusion: v4.35.0** (fuente original del owner, compilado con spcomp 1.12.0.7255).
- **Última entrega:** https://www.transfernow.net/dl/2026102103phZocY (kolossos_v11.zip). Anteriores: kolossos_v1 https://www.transfernow.net/dl/20261021slvYOyTh | rollback https://www.transfernow.net/dl/20261018XkHQefTn (expira ~10-25).
- **Lua GMod OM:** `Lua de OM de Gmod/` — 118 archivos .lua (3.8 MB) = fuente original de todos los ports. Base: noodles_om_pills_base.lua. 17 survivors, killers (fleetway/eyx/kolossos/tripwire/2011x/lordx/lilith/steveoutcome/end_new), 27 UIs, 14 entidades, módulos (afterimage/color/halo).
- **Personaje 14 = KOLOSSOS:** avatar espejo sobre el survivor actual (sin cuerpo CST), kit Z/X/C/B, FSM de 15 anims del registro Lua, fix del doblado aplicado (receta Tails v5.17-B en la copia L). Pendientes posibles: Climb de paredes, M1 de puños.
- **Crash m_afButtonDisabled (era OM):** resuelto DE RAÍZ con el rollback — el camino del error (ChampNav/PoppyDecoy) era del fork OM, no existe en las builds actuales (verificado en binario hasta 3.77.95).

---
# HISTORIAL COMPLETO — sesiones del agente (Tasks 1-28)


---
Task ID: 1
Agent: Super Z (main agent)
Task: Diagnóstico y fix del fallo "señal CST no aplica amy.cfg + error VScript GetByIndex" en el server L4D2 del usuario (SourceMod + CST + Sonic Manager). El usuario exigió: la señal del manager debe EJECUTAR EL COMANDO del jugador (sm_amy / sm_sonic) en su contexto.

Work Log:
- Analizados los logs del servidor provistos por el usuario (10/12/2026 15:59-16:00): señal Amy SÍ recibida por el guard, pero cada "aplicando amy.cfg" empareja 1:1 con "AN ERROR HAS OCCURED [the index 'GetByIndex' does not exist]" (InputRunScript line 1, LOCALS [cst] TABLE) → el motor VScript que aplica el modelo es el camino viejo roto; bucle watchdog cada ~30s x3 reintentos.
- Descargado el paquete del usuario: https://filebin.net/BXq9cTjkYMmEhBvrp/cst_skinchange_v220.zip (cst_skinchange.sp/.smx v2.2.0, cstguard.inc, test_cstguard.sp, ejemplo_parche_manager.txt, CAMBIOS_v2.txt, referencia_cst/*.nut).
- Leído el fuente v2.2.0 COMPLETO (2187 líneas): la señal (natives CSTGuard_*), el motor de aplicación (CSTG_ApplyStart → CSTG_FireApply → SetCharacterProfile VScript), la resolución de comandos dinámicos (Cmd_DynamicProfile → CSTG_ResolveAndApply, nivel 4 = caller) y el mapa personaje→cfg.
- PROBA LA DIVERGENCIA: los strings de los logs del server ("watchdog ->", "verificacion-senal ->", "(intento N)" N>1, "(senal amy.cfg; check...)") NO existen en el fuente v2.2.0; y v2.2.0 no contiene GetByIndex en código ejecutable (solo 4 menciones en comentarios del historial). → El .smx instalado en el server era una build intermedia vieja; el fuente entregado ya estaba arreglado.
- Verificada la API real del CST contra referencia_cst/: CST_Base_Profile.GetProfile(cfg, debug, gamble) (3 args OK) + Custom_Survivor_Takeover.SetCharacterProfile(target, profile) — camino del !skinchange (yeoh_cst_chat_commands.nut lineas 149-152).
- Descargado SourceMod 1.12.0.7119 (tools/addons/sourcemod/scripting/spcomp64) para compilar.
- Implementada v2.3.0 "LA SEÑAL EJECUTA EL COMANDO" sobre la base v2.2.0:
  * Nuevo núcleo CSTG_RunPlayerCommand(client, k, tag): ejecuta sm_<clave> (sm_amy/sm_sonic/...) EN EL CONTEXTO del jugador señalado — perfil registrado del comando + CSTG_ApplyStart (mismo motor que el comando tipeado); target = el jugador señalado (semántica nivel 4); SIN chequeo de admin (señal del manager = confianza; debe funcionar para no-admins y bots; por eso NO se usa FakeClientCommand).
  * CSTG_HandleSignal: señal → modelo no corresponde → CSTG_RunPlayerCommand (antes: ApplyStart directo).
  * CSTG_EvaluateClient (auto-guard: ronda/spawn/AFK/defib/rescate): descoincidencia → CSTG_RunPlayerCommand (núcleo unificado).
  * Watchdog periódico: cstguard_watchdog (1) + cstguard_watchdog_sec (30.0); timer TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE creado en OnMapStart; encola who-query "watchdog"; solo actúa ante descoincidencia real.
  * Identificación de build: #define CSTG_BUILD "2026-10-13"; banner de carga con versión+build+modo; sm_cstcheck muestra versión; log de rendición incluye versión/build; log de reintento muestra "(intento N)".
- Compilado: cst_skinchange.smx (0 errores, 0 warnings) y test_cstguard.smx (valida cstguard.inc para el manager, 0/0).
- Empaquetado /download/cst_skinchange_v230/ con LEEME_v230.txt (instalación + verificación de build + regla de oro anti-smx-viejo), CAMBIOS_v230.txt (changelog técnico + diagnóstico del caso) y zip listo para bajar.

Stage Summary:
- ROOT CAUSE: el server corría un .smx viejo (motor VScript cst.GetByIndex, ya corregido en el fuente v2.2.0); la señal del manager SÍ llegaba. Evidencia: strings de log inexistentes en v2.2.0 + GetByIndex ausente de su código.
- FIX ENTREGADO: cst_skinchange v2.3.0 compilada — la señal EJECUTA el comando del personaje (sm_amy/etc.) en el contexto del jugador señalado; watchdog 30s; banner de build verificable.
- API cstguard SIN CAMBIOS → el Sonic Manager parcheado para v2.2.0 no requiere recompilar.
- Entregables: /home/z/my-project/download/cst_skinchange_v230/ (cst_skinchange.smx listo para subir, .sp, cstguard.inc, test plugin, LEEME, CAMBIOS, cst_skinchange_v230.zip).

---
Task ID: 2
Agent: Super Z (main agent)
Task: Convertir el CST-Guard completo en un INCLUDE (cstguard.inc v3.0.0) para embeberlo dentro del Sonic Manager (pedido del owner: "lo convertiras en un INC y lo incluiras en el manager"). Motivo del owner: el guard como plugin separado "hace la vista gorda" con lo que el manager hace.

Work Log:
- Leido el fuente v2.3.0 completo (2276 lineas) para la conversion.
- Transformacion mecanica scriptada (sed) sobre copia de trabajo: prefijo g_cstg_ a todos los globals (verificado antes con grep que ningun string literal contiene "g_"), prefijo CSTG_ a los 24 callbacks publicos (Event_*/Timer_*/Cmd_*) para eliminar riesgo de colision con los hooks del manager.
- Cambios estructurales (MultiEdit): sin myinfo / sin AskPluginLoad2 / sin natives / sin RegPluginLibrary / sin CreateGlobalForward; OnPluginStart -> stock CSTGuard_Init() con anti-doble-arranque, hook interno player_disconnect y watchdog persistente; logica de OnMapStart doblada dentro del hook interno de round_start (reset de estado + probe + resync +6s + watchdog refrescado tomando cstguard_watchdog_sec); OnClientDisconnect -> hook interno player_disconnect; natives Native_* reemplazados por stocks con la MISMA firma (CSTGuard_Signal/Clear/Query) + API nueva (CSTGuard_Verify/CSTGuard_VerifyAll/CSTGuard_IsReady = fin de la vista gorda); CSTG_RequestResync llama directo a CSTGuard_OnResyncRequested() con escape #define CSTGUARD_NO_RESYNC; guarda anti-doble-disparo en CSTG_ApplyCommand para applies simultaneos del mismo perfil; banner "EMBEBIDO en <nombre del plugin host>" via GetPluginInfo(PlInfo_Name) (nota: en SM 1.12 el enum es PlInfo_*, no PluginInfo_* — corregido en compilacion).
- Estado: TODO static (file-scoped) + prefijo → imposible colision con variables del manager.
- Compilados con spcomp64 1.12.0.7119, 0 errores / 0 warnings: test_cstguard.smx (manager simulado: wiring de 1 linea + forward de resync con re-anuncio desde registro propio + sm_test_senal/clear/verify), cst_skinchange.smx (wrapper standalone opcional) y variante CSTGUARD_NO_RESYNC.
- Empaquetado /download/cstguard_embed_v300/: include + ambos .sp + ambos .smx + COMO_INCLUIR_EN_EL_MANAGER.txt (paso 0 prueba sin tocar el manager con test_cstguard.smx; paso 2 UNA linea CSTGuard_Init(); pasos 3-5 API igual + Verify/VerifyAll; paso 6 BORRAR cst_skinchange.smx del server) + CAMBIOS_v300.txt (diagnostico de la vista gorda: tiempos de checkpoint, vidas separadas de 2 plugins, native opcional silencioso) + zip.

Stage Summary:
- ENTREGADO cstguard.inc v3.0.0 (build 2026-10-13b): TODO el CST-Guard + motor CST como include drop-in (mismo nombre de archivo y misma firma de CSTGuard_Signal/Clear/Query que el cstguard.inc de natives v2.x → el manager solo agrega CSTGuard_Init() en OnPluginStart y recompila).
- El manager pasa a ser el unico dueño del guard: cero natives, cero forwards globales, cero señales perdidas; API nueva Verify/VerifyAll para revision inmediata en el mismo frame.
- Regla de oro documentada: UN guard por server (manager embebido O wrapper standalone, nunca ambos — duplicaria sm_amy).
- No se posee el fuente del Sonic Manager del usuario (scripting3.zip nunca re-enviado): se entrego include + plantilla exacta (test_cstguard.sp) + guia; si el owner manda su manager, falta solo compilarlo con el include (Task potencial 3).

---
Task ID: 3
Agent: Super Z (main agent)
Task: Integrar el cstguard.inc v3.0.x (guard embebido) DIRECTAMENTE en el Sonic_ability_manager.sp del usuario y compilarlo — pedido literal: "te hablaba del Sonic_ability_manager.sp... que otro manager me voy a referir!?" (la entrega anterior v300 dio plantilla+guia porque "no se tenia" el fuente; en realidad el scripting3.zip y el manager 37753 parcheado seguian en /tmp/my-project de la sesion anterior).

Work Log:
- RECUPERADOS los archivos "perdidos" en /tmp/my-project (sandbox persistio): scripting3.zip (13.8MB, arbol de scripting completo del usuario con los 16 .inc del suite) + download/senal_cst_quien_es_quien/Sonic_ability_manager.sp (v3.77.53, el parche de la señal, compildo y funcionando en el server) + download/suite_37752_ragdoll_impulso/include/{sonic.inc v6.33-OM, Rouge.inc v10.4-OM} (versiones NUEVAS que las del zip: el sonic.inc del zip tiene el motor de ragdoll v6.11-onda, el de la 37752 es el v6.14-SetVelocity-por-hueso).
- Verificada la arquitectura de la señal 37753: FireCharSignal() dispara el GlobalForward Sonic_OnCharacterChanged en 5 puntos (menu commit, Rebuild robado, "Sin personaje", freechars, LoadPlayerCharChoice cookie) + RegPluginLibrary + native Sonic_GetPlayerCharIndex. HALLAZGO CLAVE: el cst_skinchange v2.2/v2.3 NO escucha ese forward NI pollea el native (el polling L0 quedo solo en la v2.1 y se perdio en la fusion) — la señal salia al vacio: ESA era la "vista gorda" (el guard solo veia L1-L4 y el manager asigna sin tocar el modelo, avatar prop aparte).
- Montado el entorno de compilacion en work/manager_embed/build: include tree del scripting3.zip + sonic.inc/Rouge.inc de la 37752 (los exactos del build en produccion) + cstguard.inc. SANITY CHECK: baseline 37753 compila 0 errores (4 warnings tag-mismatch preexistentes) — base valida.
- Chequeo de colisiones simbolo por simbolo: 24 publics del guard (prefijo CSTG_*) vs publics del manager+includes = CERO colisiones. Unico comando compartido: sm_sonic (Speed_sonic.inc Command_Speed) — YA coexistian asi cuando el guard era plugin suelto (SM encadena callbacks), comportamiento preservado, no regresion. Cvars cstguard_* fuera de g_sSuitePrefixes = no entran al Sonic_Suite.cfg auto-guardado.
- PATCH v3.77.54 (6 zonas quirurgicas, 116 lineas con comentarios, todo lo demas byte a byte):
  1) #include <cstguard> tras <Doll_System>.
  2) g_sCstCharKeys[MAX_CHARS] = tabla charIdx->clave (sonic/tails/knuckles/amy/sally/shadow/rouge/cream/metal_sonic/eggman/sage, mismo orden que g_CharNames).
  3) CSTGuard_Init() en OnPluginStart ANTES del bucle late-load (ese bucle dispara FireCharSignal->CSTGuard_Signal: el guard debe estar vivo).
  4) FireCharSignal: primero CSTGuard_Signal/Clear directo (MISMO FRAME, fin de la vista gorda), luego el forward global como siempre.
  5) public CSTGuard_OnResyncRequested(): re-dispara FireCharSignal para todos los activos (el guard lo pide a +4.5s del arranque, cada ronda +6s, sm_cstsync).
  6) sm_sjsver: segunda linea de verificacion del guard embebido (version/build/watchdog/CST montado) — anti-smx-viejo.
- BUG CAZADO ANTES DE COMPILAR: late-load llamaba CSTGuard_Signal ANTES de CSTGuard_Init (handles nulos -> runtime error). Doble fix: Init movido antes del bucle + cstguard.inc v3.0.1 con guard anti-pre-Init en TODOS los stocks (Signal/Clear/Query/Verify/VerifyAll retornan seguro; el re-anuncio +4.5s repone).
- COMPILADO con spcomp64 1.12.0.7119: Sonic_ability_manager.smx v3.77.54 (494001 bytes; +31900 vs 37753 = el guard entero embebido; 0 errores, mismos 4 warnings preexistentes) + test_cstguard.smx y cst_skinchange.smx wrapper recompilados con el v3.0.1 (consistencia de la familia).
- Verificacion del binario: smx v2 con secciones LZMA (los strings no son grepeables — igual que el smx 37753 original del usuario); prueba de vinculacion: todos los simbolos CSTGuard_* resueltos (error fatal si el include no hubiera entrado) + delta de tamaño exacto al peso del guard.
- Empaquetado /download/manager_guard_embebido_v37754/: smx + sp + cstguard.inc v3.0.1 + sonic.inc/Rouge.inc (las de la 37752, para que el paquete sea autocontenido al recompilar) + LEEME (REGLA DE ORO: BORRAR cst_skinchange.smx del server o sm_amy se dispara doble; verificacion sm_sjsver/sm_cstcheck; prueba real por el menu) + CAMBIOS + zip.

Stage Summary:
- ENTREGADO Sonic_ability_manager v3.77.54 con el CST-Guard + motor CST EMBEBIDOS (cstguard.inc v3.0.1): el guard ve CADA commit de personaje del manager EN EL MISMO FRAME (llamada directa, sin forward ni native) y ejecuta sm_amy/sm_sonic/sm_rouge en el contexto del jugador señalado.
- Root cause de la vista gorda documentada: la señal 37753 salia al vacio (v2.2/v2.3 no escuchaban el forward ni polleaban el native) + el manager asigna sin tocar modelos.
- El usuario debe: BORRAR cst_skinchange.smx, subir el smx nuevo, verificar sm_sjsver (linea CST-Guard EMBEBIDO) y probar por el menu (señal instantanea en log, sin esperar watchdog).
- Entregables: /home/z/my-project/download/manager_guard_embebido_v37754/ (+ .zip).

---
Task ID: 4
Agent: Super Z (main agent)
Task: "LA LLAMADA DIRECTA" — reporte del owner: la señal seguia sin aplicar ("señal: Amy Rose ES 'sonic' -> sonic.cfg ... el guard si reconoce la señal de quien soy pero no aplica el cfg"). Pedido literal: cuando el jugador seleccione o recuerde un personaje, llamar directamente el sm_<cfg disponible> (si es amy sm_amy, si es metal sm_metal, etc).

Work Log:
- Leidos el fuente entregado v3.77.54 + cstguard.inc v3.0.1 completos. Log del owner decodificado: "Amy Rose" = NICK del jugador; señal "sonic"->sonic.cfg = mapeo del manager CORRECTO (tablas g_CharNames/g_sCstCharKeys alineadas, sin bug de mapeo).
- CAZADO EL ROOT CAUSE DEFINITIVO: CSTG_HandleSignal solo ejecutaba CSTG_RunPlayerCommand si (cstguard_signal && cstguard_auto && g_cstg_bCstReady). bCstReady dependia del probe por convar write-back cuyo VScript usaba "DirectorScript.Convars.SetValue(...)" — pero Convars es un GLOBAL RAIZ del VM, NO miembro de DirectorScript (evidencia: el propio CST lo usa raiz en yeoh_survivor_model_changer.nut L18). El script reventaba en silencio, cstguard_probe jamas se escribia, bCstReady=0 ETERNO -> señal/watchdog/sweeps/who MUERTOS mientras los comandos manuales vivian (no pasan por el gate). La "vista gorda" existia desde la v2.2.0.
- cstguard.inc v3.0.1 -> v3.0.2 (build 2026-10-13d), 6 zonas quirurgicas:
  1) CSTG_WHO_SCRIPT: Convars.SetValue raiz (who-query viva).
  2) CSTG_ProbeFire: mismo fix (bCstReady confirma de verdad).
  3) CSTG_HandleSignal: LLAMADA DIRECTA — fuera el gate auto/bCstReady, queda solo kill-switch cstguard_signal; skip por modelo-matcheado pasa de CSTG_Debug invisible a LogMessage visible; resto -> CSTG_RunPlayerCommand EN EL ACTO.
  4) CSTGuard_Signal: IsClientInGame -> IsClientConnected + rama not-in-game que registra identidad (indice+steamid, clave normalizada) y aplica en el primer spawn (cookie al reconectar = "recuerde").
  5) CSTG_Timer_Probe: transicion no-listo->listo pide re-anuncio +0.5s (lo llegado antes del montaje del CST se aplica apenas confirma).
  6) Version/build/banner/docs.
- Manager v3.77.54 -> v3.77.55: CERO cambios de logica — solo PLUGIN_VERSION, changelog, comentario de FireCharSignal y texto de sm_sjsver.
- Compilado con spcomp64 1.12.0.7119: Sonic_ability_manager.smx 494239 bytes (+238 vs 3.77.54 = costo exacto del parche), 0 errores / mismos 4 warnings preexistentes (tag mismatch Rouge_Event_PlayerSpawn, anteriores a 3.77.53). test_cstguard.smx y cst_skinchange.smx (wrapper opcional) recompilados con v3.0.2.
- Empaquetado /download/manager_llamada_directa_v37755/ (+zip): smx + sp + cstguard.inc v3.0.2 + sonic.inc/Rouge.inc + LEEME (instalacion 2 pasos, verificacion sm_sjsver "v3.0.2 build 2026-10-13d", prueba real por el menu con las 3 lineas de log esperadas, como agregar sm_metal u otros cfg via data/cst_skinchange_maps.txt) + CAMBIOS (autopsia tecnica completa).

Stage Summary:
- ROOT CAUSE DEFINITIVO de la vista gorda: DirectorScript.Convars no existe (Convars es global raiz) -> probe muerto -> bCstReady=0 eterno -> TODO lo automatico muerto desde v2.2, manuales vivos. Evidencia: .nut del propio CST.
- ENTREGADO v3.77.55 + cstguard v3.0.2: seleccion/recuerdo = sm_<cfg disponible> EN EL ACTO sin gates; probe/who arreglados; señal pre-in-game registrada (aplica al primer spawn); resync al montar el CST; decisiones todas visibles en log.
- Extension documentada para el owner: cualquier personaje con cfg (metal, tails, etc) se activa agregando linea "clave cfg" en data/cst_skinchange_maps.txt -> sm_<clave> automatico (match por frontera de palabra: "metal_sonic" -> "metal").
- Entregables: /home/z/my-project/download/manager_llamada_directa_v37755/ (+ .zip).

---
Task ID: 5
Agent: Super Z (main agent)
Task: Cierre — confirmacion del owner del funcionamiento de la v3.77.55 + cstguard v3.0.2.

Work Log:
- CONFIRMACION DEL OWNER (10/13/2026): "Ok ahora si funciona perfecto. y si incluye a metal ahora." — la llamada directa seleccion/recuerdo -> sm_<cfg> funciona para TODA la cadena, incluido Metal (metal_sonic -> "metal" -> sm_metal -> metal.cfg via el mapeo de data/cst_skinchange_maps.txt).
- Observacion del owner: Metal queda SIN voz. Diagnostico tecnico: los perfiles CST solo cambian modelo/avatar; la voz en L4D2 viene del vo del superviviente reemplazado. Si el paquete/modelo de Metal no trae vo asociado, el motor no emite lineas = silencio. Los otros personajes hablan con la voz original del superviviente base (por eso "hablan tonterias" — modelo de Sonic con voz de Coach/Nick/etc, segun el slot que ocupen).
- Decision del owner: el silencio de Metal es ACEPTABLE y preferido ("mejor callado que hablando tonteria y media como alguno de los 8"). No se requiere accion.
- Estado del caso: CERRADO. La tuberia completa (menu/remember -> FireCharSignal -> CSTGuard_Signal misma-frame -> CSTG_RunPlayerCommand -> sm_<cfg> -> CST aplica modelo) queda validada en produccion.

Stage Summary:
- v3.77.55 + cstguard v3.0.2 VALIDADOS EN PRODUCCION por el owner: funciona perfecto, incluye Metal.
- Voz de Metal: silencio por ausencia de vo en el paquete del modelo; el owner lo aprueba. Si algun dia quiere voz robotica o silenciar a los otros 8, seria trabajo de sound-mod/reemplazo de vo (fuera del alcance del plugin CST).
- Sin pendientes activos.

---
Task ID: 6
Agent: Super Z (main agent)
Task: "EL MAPA OFICIAL DE LOS 13" — el owner mando via transfernow.net (20261012YgV7oVAs) la lista definitiva de los modelos CST que existen en el server: "Aqui tienes los model que existen en CST por ahora... metal esta hay y bueno ya sabes.. que hacer".

Work Log:
- Descargados los 13 VPK del transfer con agent-browser (click por link; la API de transfernow exige api-key): sonic, tails, amy_rose_model, big, blaze, cream, eggman, knuckles, metal_sonic, omega, sage, shadow, silver (todos *_cst.vpk, ~175MB total).
- Parser VPK v1 propio (scripts/vpk_list.py + vpk_extract.py, corrigiendo el orden del arbol: extension->directorio->nombre de archivo): cada VPK trae SU perfil ems/custom_survivor_takeover/profiles/<clave>.cfg + scripts/vscripts/yeoh_cst/profiles/<clave>.nut + models/survivors/survivor_<char>.mdl + v_arms. Perfiles oficiales: sonic tails knuckles amy big blaze cream eggman metal omega sage shadow silver (metal_sonic->"metal"). Todos con survivor_slot "anon" y takeover_chance 100; takeovers base: sonic/tails->@ellis, knuckles/amy/big/eggman/omega->@coach, blaze->@zoey, cream/sage->@rochelle, metal->@francis, shadow->@bill, silver->@louis.
- Cruce con el roster del manager (11 chars): 9 con modelo (sonic tails knuckles amy shadow cream metal_sonic eggman sage), sally y rouge SIN modelo (no hay VPK de ellas). Extras con modelo pero sin personaje en el manager: big blaze omega silver.
- ROOT del trabajo: el default del guard solo sembraba 3 claves (amy/rouge/sonic desde v2.2); el resto era edicion manual del owner (asi entro metal). Pedido: cablear TODO lo disponible de fabrica.
- cstguard.inc v3.0.2 -> v3.0.3 (build 2026-10-13e), zonas:
  1) g_cstg_DefCharKeys/Cfgs: 3 -> 13 entradas (CSTG_DEF_CHARS; manager chars primero en orden de menu + extras big blaze omega silver); CSTG_MAX_CHARS 12 -> 20.
  2) CSTG_LoadMapsFile UPGRADE INTELIGENTE: sin archivo -> siembra 13; archivo con marcador [MAPA-OFICIAL] (nuevo, lo escribe CSTG_SaveMapsFile) -> MANDA tal cual (ediciones/borrados del owner se respetan); archivo viejo con todas entradas oficiales/historicas (CSTG_DefaultPairKnown con equivalencia de frontera: "metal_sonic metal.cfg" == "metal metal.cfg"; historicos = seeds v2.2 amy/rouge/sonic) -> RE-SIEMBRADO a los 13 (el caso del server del owner: su amy/rouge/sonic+metal se actualiza SOLO); archivo custom -> se conserva + se completan oficiales + UN solo save con marcador (estado estable, no escribe por ronda).
  3) rouge_r.cfg RETIRADO (su modelo no esta en la lista oficial): Rouge queda como Sally, sin linea = stock intacto; restaurable con una linea (documentado en archivo+LEEME+log).
  4) BLOCKLIST CSTG_SuiteOwnedCmds={sage}: sm_sage NO se registra (Sage.inc ya es duena: alias de sm_sageset = ciclar sets; sin blocklist, ciclar sets re-aplicaria el modelo por callbacks encadenados). sage.cfg se aplica igual por senal (CSTG_RunPlayerCommand cae al perfil del MAPA si el comando no esta registrado) o sm_cstapply. Inventario completo de colisiones: solo sm_sage chocaba (los demas includes usan prefijos sm_amy*/sm_cream_*/etc); sm_sonic sigue coexistiendo con Speed_sonic como desde v2.2.
  5) Cosmetica: banner (menciona los 13), header del archivo de mapas (documenta marcador/13/sally-rouge/slots legacy), ejemplos sm_cstguard_maps, doc de build-id.
- Manager v3.77.55 -> v3.77.56: CERO logica — solo PLUGIN_VERSION, changelog y la linea del guard en sm_sjsver ("MAPA OFICIAL de 13 perfiles", espera v3.0.3/2026-10-13e).
- SANITY: baseline 3.77.55 recompilado ANTES de parchear = 494239 bytes identico al entregado (arbol de build verificado; los "8 warnings" = los mismos 4 tag-mismatch de Rouge_Event_PlayerSpawn duplicados en pantalla).
- COMPILADO spcomp64 1.12.0.7119: Sonic_ability_manager.smx 495862 bytes (+1623 = mapa de 13 + upgrade + blocklist), 0 errores / 4 warnings preexistentes; test_cstguard.smx 35901 y wrapper cst_skinchange.smx 32998 recompilados 0/0 (validacion standalone del include).
- Empaquetado /download/manager_mapa_13_v37756/ (+zip): smx + sp + cstguard.inc v3.0.3 + sonic.inc/Rouge.inc (37752) + data/cst_skinchange_maps.txt ya escrito con los 13 + LEEME (instalacion 2 pasos: subir smx y ya — el archivo del server se re-siembra solo; verificacion sm_sjsver; notas sm_sage/sally/rouge) + CAMBIOS (matriz de decision del archivo + flujo verificado por personaje + tabla completa VPK->perfil->modelo).

Stage Summary:
- ENTREGADO v3.77.56 + cstguard v3.0.3: el mapa clave->perfil pasa a ser el OFICIAL de los 13 modelos CST del server, de fabrica. Seleccion/recuerdo aplica el perfil EN EL ACTO para los 9 personajes del manager con modelo (Metal via frontera, ya confirmado); big/blaze/omega/silver quedan con sm_<clave> manual; sally/rouge sin linea (stock intacto); rouge_r retirado (restaurable con 1 linea).
- El data/cst_skinchange_maps.txt del server se ACTUALIZA SOLO al reiniciar (re-siembra del seed viejo) y desde el marcador [MAPA-OFICIAL] el archivo manda tal cual — cero edicion manual obligatoria.
- sm_sage protegido (Sage.inc lo conserva para ciclar sets; el perfil sage aplica por senal/sm_cstapply).
- Entregables: /home/z/my-project/download/manager_mapa_13_v37756/ (+ .zip).
---
Task ID: 7
Agent: Super Z (main agent)
Task: "EL MARTILLO CON FISICA REAL" — pedido del owner (2026-10-13, transfernow 20261012vqwLj1Z1 con la data actualizada del server): (1) "es hora de modificar el ataque de martillo... osea el lanzamiento no el golpe de defensa... NO tiene el impulso fake Ragdoll" con la direccion dependiendo de donde recibe el golpe (desde abajo = arriba; en el suelo = direccion contraria + elevacion), (2) quitar el dano de colision fisica vanilla al martillo ("amy se dano cuando lanza el martillo en si") al menos para Amy y el equipo, (3) fisica dinamica real del martillo en vuelo ("esta siempre tieso... hasta un auto cuando le pega el tank gira en el aire"), (4) "rouge rouge_r.cfg si existe solo que se paso colocarla en la descarga".

Work Log:
- Descargado sourcemod.zip (15.6MB) del transfer con agent-browser (click por link): data/ + gamedata/ + scripting/ + translations/ COMPLETOS del server. Hallazgos: data/cst_skinchange_maps.txt del server YA tiene "rouge rouge_r.cfg" agregado a mano por el owner + marcador [MAPA-OFICIAL] (su archivo manda tal cual); el arbol scripting trae manager v3.77.56 + Amy.inc v104 + sonic.inc v6.33 identicos a la entrega 37756, PERO cstguard.inc v3.0.2 viejo (nunca copio el de la 37756) — normalizado a v3.0.3 como base. Lua de Gmod NO presentes en la descarga (los rars son backups de .inc); la mecanica del impulso se tomo de la descripcion literal del owner + los comentarios del propio manager (sonic.lua L435-485: SetVelocity 700 + AddAngleVelocity por hueso, un impulso 1 vez).
- Gap identificado en Amy_OM_HammerHitTarget: comunes solo recibian SDKHooks_TakeDamage (sin lanzamiento) — ahi faltaba "el tratamiento del spindash"; SI/witch recibian Sonic_SpawnFlingRagdoll con rumbo plano del martillo (sin reglas de direccion); y el giro del martillo se escribia al m_angVelocity del datamap que el vphysics sobreescribe cada tick (misma clase de bug del "doble v6.9") = martillo tieso. El dano de colision: physdamagescale 0.0 por KV no pega en prop_physics_override — el campo real es m_impactEnergyScale.
- sonic.inc v6.33 -> v6.34: NUEVA wrapper publica bool Sonic_PhysSetVel(int prop, const float lin[3], const float ang[3]) — el SDKCall SetVelocity(lineal, angular) del motor v6.33 abierto a PROPS fisicos; cache PROPIO del offset m_pPhysicsObject de CBaseEntity (NO el cache del ragdoll: m_ragdoll.* no existe en un prop y envenenaria el cache global) + las mismas 4 sondas semanticas (IsAsleep/IsMotionEnabled/IsMoveable/GetMass); false = el llamador cae a su plan B. Los ragdolls siguen por Sonic_RagPhysLaunch intacto.
- Amy.inc v104 -> v105 (TRES fixes quirurgicos al lanzamiento V):
  1) IMPULSO DIRECCIONAL GMOD: nueva Amy_OM_HammerHitDir (dir = velocidad del martillo normalizada con fallback victima-Amy; grounded = FL_ONGROUND; regla: grounded && dir.z<0.1 -> dir.z invertida + piso 0.35 + 0.45 de elevacion, renormaliza). Rewire de las 3 ramas: especiales/witch pasan el dir con reglas a Sonic_SpawnFlingRagdoll/Sonic_SpawnWitchRagdoll; COMUNES ahora TakeDamage(500) + TeleportEntity(dir * amyom_throw_fling) — la receta exacta del barrido de la bola (el ragdoll de muerte hereda la velocidad). Convar amyom_throw_fling 550.
  2) CERO COLISION VANILLA AL EQUIPO (3 cinturones): (C1) m_impactEnergyScale 0.0 al nacer (el campo real del physdamagescale — de ahi el autodano de Amy); (C2) nueva Amy_OM_HammerBlocksDamage (recorre g_iAmyOMHammerProp por EntRef) cableada al TOPE de Amy_PropBlocksSurvivorDamage (gate v82 PROPS AMIGOS, siempre activo): crash damage a cualquier survivor con inflictor/attacker = martillo = bloqueado; (C3) Amy_OM_HammerTouch devuelve Handled vs survivors (el rebote fisico lo resuelve el vphysics igual). Infectados siguen pagando el golpe de juego (500/stun+ragdoll) que nunca pasa por ese camino.
  3) TUMBLE REAL: en Amy_OM_HammerLaunch el bloque vel+m_angVelocity se reemplaza por spin = (right + dir*wDir + up*wUp) * amyom_throw_spin (right = eje derecho del rumbo = CARTWHEEL de cabeza; wDir/wUp = wobble random fijo por lanzamiento +-20%/+-10%) via Sonic_PhysSetVel(hammer, vel, spin); fallback = TeleportEntity(vel) + m_angVelocity viejo (v104 exacto). Convar amyom_throw_spin 700. Todo lo demas intacto (CD/armado/retorno scriptado/hitbox 1.35x/trail/gesto/AOE de la Z no tocado).
- cstguard.inc v3.0.3 -> v3.0.4 (build 2026-10-13f): rouge/rouge_r.cfg REINTEGRADO al mapa oficial (CSTG_DEF_CHARS 13 -> 14, posicion de menu entre shadow y cream); header del archivo de mapas + banner + logs de re-sembra actualizados a 14; sm_rouge verificado SIN colision (Rouge.inc solo registra sm_rouge_kick/bomb/wave/sweep/counter -> no entra al blocklist, solo sage). El archivo del server del owner ya manda por el marcador.
- Manager 3.77.56 -> 3.77.57: CERO logica — PLUGIN_VERSION, changelog de la ronda, sm_sjsver (Amy v105-OM con el resumen del martillo; CST-Guard "MAPA OFICIAL de 14 perfiles... rouge de vuelta via rouge_r.cfg", espera v3.0.4/2026-10-13f).
- COMPILADO spcomp64 1.12.0.7119: Sonic_ability_manager.smx 497306 bytes (baseline 495872 + 1434), 0 errores / 8 warnings en pantalla (los 4 tag-mismatch preexistentes de Rouge_Event_PlayerSpawn duplicados); test_cstguard.smx 35932 y cst_skinchange.smx 33772 recompilados 0/0 con el v3.0.4. HALLAZGO TECNICO DOCUMENTADO: spcomp 1.12 es NO-DETERMINISTA entre ejecuciones (mismo arbol 2 veces difiere desde offset 181473, region de timestamp, mismo tamano) — la validacion round-trip es fuentes del paquete sobre arbol limpio = 0 errores + 497306 bytes exactos (byte-a-byte no aplica con este compilador).
- Empaquetado /download/hammer_fisica_real_v37757/ (+zip 948KB): smx + sp + Amy.inc v105 + sonic.inc v6.34 + cstguard.inc v3.0.4 + data/cst_skinchange_maps.txt (seed oficial de 14, referencia) + test/wrapper + LEEME (instalacion 2 pasos, verificacion sm_sjsver, convars nuevos amyom_throw_fling/spin, prueba real en 3 pasos) + CAMBIOS (autopsia completa).

Stage Summary:
- ENTREGADO v3.77.57: el martillo lanzado de Amy con (1) impulso direccional GMod a TODO lo que golpea — comunes vuelan con la receta del barrido de la bola, SI/witch con las mismas reglas (desde abajo = arriba; en suelo = contraria + eleva), (2) cero dano de colision fisica vanilla al equipo (3 cinturones: m_impactEnergyScale 0 + PROPS AMIGOS reconoce el martillo + Touch Handled), (3) tumble REAL en vuelo (SDKCall SetVelocity angular directo al IPhysicsObject: cartwheel + wobble tipo coche del tank, amyom_throw_spin 700).
- rouge_r.cfg REINTEGRADO al mapa oficial del guard (14 perfiles de fabrica); el archivo del server del owner (que ya tenia la linea a mano) manda igual por el marcador.
- Convars nuevos: amyom_throw_fling 550 / amyom_throw_spin 700 (auto-guardados en Sonic_Suite.cfg).
- Entregables: /home/z/my-project/download/hammer_fisica_real_v37757/ (+ .zip).

---
Task ID: 8
Agent: Super Z (main agent)
Task: "EL VUELO REAL DEL IMPACTO" — reporte del owner sobre la v3.77.57: "El empuje del martillo aun sigue siendo = la fuerza no lanza al oponente... el enemigo no sale volando hacia atras ni tampoco pareciera reaccionar como deberia cuando el martillo le pega estando inmovil". El impulso del martillo lanzado de Amy NO se veia en absoluto.

Work Log:
- Leidos completos Amy.inc v105 + sonic.inc v6.34 + OM_Stun v2.1 + Rouge.inc v10.4 (la referencia que el owner ve volar comunes a diario) del paquete 37757 (base verificada IDENTICA al arbol de build).
- AUTOPSIA — el impulso v105 se moria por DOS caminos independientes (cualquiera bastaba para el sintoma):
  * RC1 COMUNES: TakeDamage(500) + TeleportEntity(vel) al cuerpo YA MUERTO — el ragdoll de muerte de un comun de L4D2 es CLIENTE-SIDE y no hereda ninguna velocidad del server; el comun se desploma normal. El comentario v105 ("la receta probada del barrido de la bola: el ragdoll de muerte hereda la velocidad") era FALSO — la prueba en el propio codigo: Rouge_FlingRagdoll NO usa TeleportEntity, spawnea una COPIA prop_ragdoll y ESA vuela + BecomeRagdoll + cleanup 3s.
  * RC2 ESPECIALES/TANK/WITCH: Amy_OM_HammerHitTarget corria INLINE dentro del callback SDKHook_Touch del prop — DENTRO de la simulacion vphysics — y ahi el spawn+wake+SDKCall-launch del ragdoll falso no despega (stun si, vuelo nunca). Contraste del suite: NINGUNA habilidad que vuela cuerpos lanza desde touch fisico (spindash=think, Barrido=dash, ritual witch=timer); el martillo era la unica. Bonus: el scan 30Hz (contexto seguro) muestrea cada ~90-100u con el martillo a 3000 u/s y se escapa la mitad de las ventanas.
  * RC3 (menor): el dano viajaba DENTRO de OM_Stun; si mataba, T_SonicStunWatch mataba al doble a los 0.1s = vuelo invisible en golpes letales.
- Amy.inc v105 -> v106, TRES fixes quirurgicos: (F1) comunes con la RECETA ROUGE v10.4 exacta (TakeDamage -> health<=0 -> Amy_OM_HammerFlingCopy: copia prop_ragdoll lanzada con Sonic_RagPhysLaunch por hueso [plan B Sonic_RagFlingEngine] con fling=amyom_throw_fling 550 + elev 0.55x + tumble 900, BecomeRagdoll en el comun real, T_AmyOMHammerRagClean 3s; sobrevive = empujon plano); (F2) IMPACTO DIFERIDO: el Touch solo ENCOLA (Amy_OM_HammerHitQueue: EntRef victima + userid Amy, max 16/frame, marca blandos compartidos con el scan) y RequestFrame(Amy_OM_HammerHitFlush) lo procesa el frame siguiente FUERA de la simulacion — el contexto de timer del spindash; Plugin_Continue intacto (rebote vphysics igual); (F3) orden Rouge en especiales: TakeDamage FUERA primero; muere = copia Rouge volada (becomeRag=false para players); sobrevive + OM_Stun(stack) = Sonic_SpawnFlingRagdoll con reglas GMod de direccion. Amy_OM_HammerHitDir con guard de prop invalido (flush diferido; fallback Amy->victima). Lectura segura players-vs-entities en FlingCopy (GetClientModel/AbsOrigin/AbsAngles para clients).
- sonic.inc v6.34 / cstguard.inc v3.0.4 / OM_Stun v2.1: SIN CAMBIOS (spindash y ritual witch intactos). Manager 3.77.57 -> 3.77.58: PLUGIN_VERSION + changelog + sm_sjsver (Amy v106-OM "EL VUELO REAL DEL IMPACTO", parcheado por script exact-byte scripts/patch_sjsver.py).
- COMPILADO spcomp64 1.12.0.7119: Sonic_ability_manager.smx 498586 bytes (baseline 497306 + 1280 = bloque v106), 0 errores / 8 warnings en pantalla (los 4 tag-mismatch preexistentes de Rouge_Event_PlayerSpawn duplicados). No-determinismo del compilador re-confirmado (mismo arbol 2 veces: 498586/498590).
- ROUND-TRIP: primera pasada FALLEIDA por orden de cp (el include v105 sobrescribino al del paquete — detectado por el delta de Code size 3608 bytes); rehecha en orden correcto: fuentes del paquete sobre arbol limpio = Code 1447580 / Data 689676 / Total 2159192 IDENTICOS al build principal, 498586 bytes, 0 errores. Paquete autocontenido verificado.
- Empaquetado /download/hammer_vuelo_real_v37758/ (+zip 951KB, 14 archivos): smx + sp + Amy.inc v106 + sonic.inc v6.34 + cstguard.inc v3.0.4 + data/cst_skinchange_maps.txt (referencia) + test/wrapper + LEEME (instalacion 2 pasos, verificacion sm_sjsver "3.77.58 / Amy v106-OM", prueba real en 3 pasos: comun inmovil + V = cuerpo muere VOLANDO; especial + V = stun + doble volador; re-golpe estando inmovil = re-stun + relanzado) + CAMBIOS (autopsia RC1/RC2/RC3 + F1/F2/F3).

Stage Summary:
- ENTREGADO v3.77.58 (Amy v106-OM): el impacto del martillo lanzado ahora (1) comunes mueren VOLANDO con la receta Rouge (copia prop_ragdoll + BecomeRagdoll — la unica que vuela comunes en este server), (2) especiales/tank/witch procesados el frame SIGUIENTE al toque (fuera de la simulacion vphysics — el contexto del spindash; el inline en el touch era lo que mataba el vuelo), (3) golpe letal a especiales = cadaver volando (copia Rouge; el watcher ya no mata al doble).
- Convars sin cambios (amyom_throw_fling 550 = velocidad de vuelo de los cuerpos; amyom_throw_dmg_common 500).
- Verificacion en server: sm_sjsver debe decir 3.77.58 + Amy v106-OM; prueba recomendada: comun PARADO + tecla V.
- Entregables: /home/z/my-project/download/hammer_vuelo_real_v37758/ (+ .zip).
---
Task ID: 9
Agent: Super Z (main agent)
Task: FIX DEL CRASH SILENCIOSO — reporte del owner: "el crash ocurre solamente en alta medica no mercy al bajar apenas (empezar a bajar por los apartamentos) el juego crash, sin mensajes de error ni nada". Continuacion del debugging del crash que empezo con las versiones del HUD bar (v3.77.80+).

Work Log:
- Descargado scripting3.zip v3.77.84 (13.3MB, 365 archivos). Confirmado L4D2 (SampleInfectedAPI, WitchFrozen, BoomerFuse).
- AUTOPSIA del camino habilidad-vs-comunes: los indices 464/467/469 de los errores previos NO son clientes (imposible: MaxClients=32) — son NPC commons (classname "infected", entidades 400+). El crash = camino kick/javelin/dash vs horda, no del HUD ni del mapa (la zona de apartamentos = primera zona con comunes en masa de la campana).
- FUENTE 1 CONFIRMADA — macro OM_StunValid (OM_Stun.inc:257): "1 <= %1 <= MaxClients" NO filtra nada en SourcePawn (asociatividad: (1<=464)=1 -> 1<=32=TRUE). El Burning Javelin v2.8 llamaba OM_Stun(victima-comun) SIN check de rango en cada enganche -> IsClientInGame(464) -> error nativo "Invalid client index 464" CADA TICK (30/s), abortando el think entero y re-escaneando al mismo comun.
- FUENTE 2 — HitImpact dañaba PRIMERO y operaba el cadaver despues: OM_AbilityDamage x2 (50+ dmg vs 50 HP del comun) mata EN el frame, el edict se libera AL INSTANTE en L4D2, y TeleportEntity+IgniteEntity+GetEntPropVector corrian sobre el indice muerto ("Invalid entity" en cadena — solo visible en logs/error_*.log, no en pantalla).
- FUENTE 3 (el crash silencioso del MOTOR en si) — daño DENTRO del while(FindEntityByClassname) en Blaze_FX_AoeCommons y el swoosh del Sol Flame: al morir un comun, la siguiente iteracion arrancaba desde un edict recien liberado = acceso a memoria liberada = el proceso muere SIN escribir nada (mismo patron de fragilidad del crash v3.77.75 UserMessageBegin).
- FUENTE 4 — arrastre del javelin solo validaba IsValidEntity (insuficiente para edict reciclado) y guardaba el target aunque el daño de enganche lo hubiera matado.
- FIXES APLICADOS: (1) OM_Stun v2.4: macro con forma explicita "1 <= %1 && %1 <= MaxClients"; (2) Blaze v2.10: helper Blaze_VictimAlive(victim) [player: InGame+Alive / NPC: ValidEntity+m_iHealth>0], HitImpact reordenado damage-last [vpos capturada ANTES del daño, push/stun/ignite solo vivos, daño AL FINAL, FX/AOE con posicion capturada], javelin: OM_Stun solo players + vpos antes del daño + no arrastrar muertos, arrastre con Blaze_VictimAlive; (3) AoeCommons + swoosh con patron SNAPSHOT [recoleccion de indices vivos en radio sin daño en medio, tope 128/96, daño despues re-validando]; (4) mismo bug de asociatividad corregido en los 16 macros IsValidClient del suite (Blaze/Sonic/Silver/Amy/Knuckles/Metal/Rouge/Shadow/Sage/Tails/Cream/Sally x2/Eggman x2/Speed_sonic x2) via scripts/fix_macros_rango.py.
- Versiones: manager 3.77.84 -> 3.77.85 (PLUGIN_VERSION + changelog sm_sjsver, comillas escapadas via scripts/fix_comillas_sjsver.py tras detectar 6 comillas crudas), Blaze v2.9 -> v2.10-OM, OM_Stun v2.3 -> v2.4.
- COMPILACION: descargado SourceMod 1.12.0.7119 linux EXACTO (el mismo del compile.exe del owner; el 7255 mas nuevo rechaza 2 ternarios int->char preexistentes del tree) de sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7119-linux.tar.gz -> /tmp/sm7119. Compilado: 0 errores / 8 warnings (los tag-mismatch preexistentes de Rouge/Shadow_Event_PlayerSpawn), Code 1807372 / Data 1040800 / Stack 21936 / Total 2870108, Sonic_ability_manager.smx 638645 bytes (el smx del zip estaba desactualizado: 412405 bytes, mas viejo que la v3.77.58). Header FFPS identico al del smx que el owner ya carga.
- ROUNDTRIP: paquete montado sobre el tree original del usuario + recompilado = mismos Code/Data/Stack/Total exactos (dif. de 91 bytes en archivo = no-determinismo ya documentado del compilador).
- Empaquetado /download/crash_horda_fix_v37785/ (+zip 1.5MB, 22 archivos): smx + sp + 14 includes con fix + Speed_sonic.inc + Eggman_raiz.inc + LEEME (instalacion 2 pasos, verificacion sm_sjsver "3.77.85 / Blaze v2.10-OM / OM_Stun v2.4", prueba real: No Mercy c1 bajar por los apartamentos reventando horda con kick Z / javelin X / dash / Sol Flame) + CAMBIOS (autopsia completa de las 4 fuentes).

Stage Summary:
- ENTREGADO v3.77.85 (Blaze v2.10-OM + OM_Stun v2.4): el crash silencioso al pelear contra la horda tenia 4 fuentes — macro de rango roto (el javelin reventaba "Invalid client index 464" cada tick con un comun enganchado), operaciones sobre entidades muertas tras el daño (push/ignite/lectura del cadaver), daño DENTRO del FindEntityByClassname (iteracion desde edict liberado = segfault silencioso del motor, el crash sin mensaje reportado), y arrastre de cadaveres reciclados. Todas blindadas + los 16 macros IsValidClient del suite con el mismo bug latente corregidos.
- El HUD bar queda EXONERADO: la autopsia mostro que solo coincidia en tiempo/espacio con la primera zona de combate de la campana.
- Balance intacto (mismos daños/empujones/quema/stun a players); los FX no se tocaron (regla del owner).
- Verificacion en server: sm_sjsver = "Manager 3.77.85 ... Blaze v2.10-OM ... OM_Stun v2.4"; prueba critica = No Mercy c1 apartamentos, reventar horda con el kit completo de Blaze sin que el juego se cierre; logs/error_*.log limpio de "Invalid client index"/"Invalid entity".
- Entregables: /home/z/my-project/download/crash_horda_fix_v37785/ (+ .zip).

---
Task ID: 16
Agent: Super Z (main agent)
Task: Fix del "send reliable stream overflow" — el owner aislo al culpable en campo ("Encontro al culpable. es Sonicmanager"). Autopsia exhaustiva del Sonic_ability_manager + fix sin tocar FX.

Work Log:
- Releido worklog (Task 15: fix filenetwork v1.0.1 FALSO — el error seguia). Localizado el arbol real: /home/z/my-project/scripting3/ (scripting3.zip ya descomprimido en raiz, no scripts/scripting3_debug).
- Objetivo: Sonic_ability_manager.sp (409KB, 6529 lineas, v3.77.85 del 15-oct 23:51, smx del usuario compilado 23:52). El manager integra ~28 includes (todo el suite en un solo smx de 638KB).
- Descartado por volumen insuficiente: T_OMStatusHUD (KeyHintText 256B cada 0.5s), T_SBarThink (5Hz calculo, escritura al chat throttled 0.3s-12s, SBar.inc v3.0 bien hecho), T_SonicSoloWatchdog (2s, solo logica local), binds Z/X/C/V/B (one-shot), chats/centers (one-shot).
- CULPABLE ENCONTRADO: el PauseFix de Tails (Tails.inc, v5.20.5/v5.24, seccion ~2240-2530). Mecanismo: en CADA montaje de avatar, Tails_PauseFix_Trigger dispara una FSM que pide "pause" con ClientCommand(client,"pause") — stringcmd FIBLE server->cliente; el cliente lo ejecuta y lo devuelve como stringcmd fiable cliente->server; el server pausa el mundo REAL (sv_pausable FORZADO a 1 en OnPluginStart/OnMapStart/RoundStart/antes de cada pulso por Tails_PF_ForcePausable) y la FSM suelta con "pause" PALANCA/unpause via ClientCommand: ping-pong pause/unpause con el canal sin drenar = saturacion del stream fiable en ambas direcciones. En listen server: "127.0.0.1:27015:send reliable stream overflow" (39+). Llamadores del Trigger: Tails(1766,1992) + Amy(9077,9494) + Blaze(952,1219) + Cream(1603,1847) + Eggman(1790,2050) + Knuckles(3688,3953) + Metal(4485,4733) — cualquier personaje lo dispara (spawn/respawn/!sc/auto-reparacion FSM).
- FIX v5.20.7 "ZERO-NET" (Tails.inc) + manager v3.77.88 (salto deliberado: 3.77.86/87 ya usadas):
  (1) Tails_PF_IssuePause/IssueUnpause: 100% FakeClientCommand server-side — CERO ClientCommand, cero stringcmds fiables (firma de IssuePause limpiada: sin viaCliente).
  (2) Tails_PF_ForcePausable -> Tails_PF_CachePausable (bool): sv_pausable YA NO SE ESCRIBE NUNCA (5 llamadas migradas: OnPluginStart, OnMapStart, RoundStart, Trigger, FSM-WAIT).
  (3) Trigger: gate nuevo — sv_pausable!=1 -> pulso omitido con LogMessage 1 vez por mapa (g_bTailsPFSkipNotice, reset en Tails_PauseFix_Reset); re-encaje queda en EF_NOINTERP+MarkInterp (piezas 1-2 de v5.20.5, ya existentes).
  (4) LogError de la FSM re-etiquetados v5.20.7. SIN TOCAR FX: EF_NOINTERP, MarkInterp, trails, avatares, HUD intactos.
- Compilado spcomp 1.12.0.7119: 638625 B, 8 warnings (todas 213 preexistentes lineas 5868-5871 del codigo del usuario, no tocadas por cirugia minima; el 203 de viaCliente resuelto). MD5 26bdc5a463fa3561ea31cd90acab8473.
- Paquete: download/fix_pausefix_overflow_v37788/ (plugins/Sonic_ability_manager.smx + scripting fuentes + LEEME.txt) + zip 844061 B.
- Filebin (bin 6363dsld0qmuob9i): 4 intentos fallidos consecutivos (503 "Failed to store", luego timeouts sin respuesta — servicio degradado). Script scripts/subir_filebin_fix_overflow.sh listo para reintentar. Entrega efectiva via download/.

Stage Summary:
- Causa raiz del overflow CONFIRMADA: ping-pong pause/unpause del PauseFix por stringcmd fiable + pausas reales del mundo con sv_pausable secuestrado. El diagnostico del owner ("es Sonicmanager") era correcto; el mio (filenetwork, Task 15) era falso.
- Fix entregado: v3.77.88 / Tails v5.20.7 Zero-Net. Cero ClientCommand en el ciclo, sv_pausable respetado (0=omision con aviso 1/mapa; 1=pulso server-side sin red). tails_pausefix intacto (1/0).
- Pendiente: subir a filebin cuando el servicio reviva (script listo); verificar en campo con el owner (jugar 2-3 mapas, cambiar personaje, !sc, muertes: el error no debe salir ni una vez; en logs aparecera 1 vez/mapa el aviso sv_pausable 0, que es NORMAL).

---
Task ID: 24
Agent: Super Z (main agent)
Task: ROLLBACK COMPLETO DEL SISTEMA OM — orden terminante del owner tras el crash en produccion: "Borra eso... Borra la broma de OM quiero que dejes El sonic manager como estaba sin esa porqueria me canse No voy a pasar lo mismo que pase con lo de Los coso estos de lol otra vez.. NO no nonono no no.. no señor". Nada de DrGBase, nada de parches: eliminacion total y vuelta al estado pre-OM.

Work Log:
- RECUPERACION DEL ENTORNO: el reset del dia borro /home/z/my-project a un snapshot del Oct-17 17:25 (worklog cortado en Task 16, sin om_survivors). Hallazgo: el arbol COMPLETO de las sesiones perdidas sobrevivio en /tmp/my-project (om_survivors_v1, om_fixes_v104, om_drgbase_v105, lol_survivors_v1, limpieza_warnings_v37791, scripts tnow_*). Recuperados y preservados en work/retired_om_20261018/ + scripts/.
- IDENTIFICACION DE LA VERSION INSTALADA: el crash reportado (ChampNav_Cleanup L18008 / DecoyRestoreBot L18105 / PoppyDecoy_End L18039 / PoppyRetreat L17224 / PoppyDecoy_Tick L20510 / Timer_ChampLaunchTick L17014, "m_afButtonDisabled not found entity 2/player") calza EXACTO con om_drgbase_v105 (PLUGIN_VERSION 4.38.0, kit DrGBase) -> el owner tenia instalada la ULTIMA entrega (v1.05), no la v1.03.
- MANAGER DE ROLLBACK: elegido limpieza_warnings_v37791 (v3.77.91, build Oct-18 01:10, 660929 B) = ultimo pre-OM. Verificado grep: CERO refs om_survivors/L4D2OM/lol_survivors/drgbase. v3.77.92/93 eran SOLO la integracion OM (lo que se elimina); 89/90/91 (anti-lag+SC pausa, sol expansivo, 0 warnings+barra Rouge) se conservan integros. Bytes exactos de la entrega original, sin recompilar.
- PET_FUSION RESTAURADO: compilado scripting3/scripting/l4d2_pet_fusion.sp (v4.35.0, 24679 lineas, fuente ORIGINAL del owner) SIN UNA LINEA CAMBIADA con spcomp 1.12.0.7255 (el de su compile.exe; el 7119 rechaza sizeof(g_Styles[id].name) — repro minimal confirmado): 0 errores / 0 warnings, 375065 B. Descargado SM 1.12.0-git7255 de sm.alliedmods.net (identico al sm112.tar.gz que ya usaban las sesiones perdidas).
- PAQUETE download/rollback_sin_om_v1/ (+zip 1566291 B): plugins/Sonic_ability_manager.smx v3.77.91 + plugins/l4d2_pet_fusion.smx + scripting/ (manager .sp + Blaze/Eggman/Rouge/Silver.inc de la 37791 + l4d2_pet_fusion.sp original) + LEEME.txt (3 pasos: borrar l4d2_om_survivors.smx, subir los 2 smx, restart; verificacion sm_sjsver=3.77.91, !pet, consola sin m_afButtonDisabled; limpieza opcional data/l4d2_om_survivors.cfg) + CAMBIOS_ROLLBACK.txt (autopsia tecnica completa).
- SUBIDA: tnow_create_transfer.py + tnow_upload.py (recuperados de /tmp) -> transfer 20261018XkHQefTn, verificado descargable 1566291/1566291 B.
- NOTA DE REGISTRO: las Tasks 17-23 del worklog se perdieron con el reset (el worklog de /tmp tambien termina en Task 16); esta entrada continua la numeracion segun el resumen de sesion (OM survivors = Task 23).

Stage Summary:
- ENTREGADO ROLLBACK: https://www.transfernow.net/dl/20261018XkHQefTn (rollback_sin_om_v1.zip, 1.6 MB).
- El server vuelve a: manager v3.77.91 (pre-OM exacto) + pet_fusion 4.35.0 original del owner. Los 5 reportes + el crash m_afButtonDisabled se eliminan DE RAIZ (el camino del error era del fork OM; en pet_fusion la misma ruta lleva meses estable).
- OM survivors v1.03/v1.04/v1.05 y LoL survivors v1.03: RETIRADOS de entrega, preservados en work/retired_om_20261018/ solo como archivo historico.
- Decision del owner registrada: NO MAS experimentos con bots supervivientes. Voces VPK + vscripts_opt intocados.

---
Task ID: 25
Agent: Super Z (main agent)
Task: NUEVO CANON — el owner anuncio su repositorio GitHub https://github.com/AmyRose21/scripting como fuente de verdad permanente ("modo gestionamiento real monitorieo"). Sincronizar, auditar estado vs rollback y establecer protocolo de monitoreo.

Work Log:
- Clonado a /home/z/my-project/repo-scripting (2 commits: f4bf209 inicial 2026-06-30, 76659f2 "Datos de nuevo repositorio" 2026-10-20).
- AUDITORIA DEL MANAGER: Sonic_ability_manager.sp del repo = PLUGIN_VERSION 3.77.91 = LA VERSION ROLLBACK (pre-OM, la entregada en Task 24). grep om_survivors|L4D2OM|drgbase|lol_survivors = CERO referencias. (Nota: SONIC_OM_VERSION en el banner es el core de habilidades Sonic, legitimo de la 3.77.91, no tiene relacion con l4d2_om_survivors.)
- VERIFICACION BYTE A BYTE (MD5) repo vs download/rollback_sin_om_v1/scripting/: Sonic_ability_manager.sp ee1ede52... IGUAL, Blaze.inc 80332d4a... IGUAL, Eggman.inc c69b7312... IGUAL, Rouge.inc a4be9bbf... IGUAL, Silver.inc ff116028... IGUAL, l4d2_pet_fusion.sp 5635ab0f... IGUAL. Repo root .inc == repo include/.inc tambien identicos. EL REPO ESTA EN EL ESTADO LIMPIO EXACTO.
- l4d2_om_survivors.sp (1.175.894 B) presente en el repo SOLO como archivo historico de fuente — inofensivo (no es .smx instalado y el manager no lo referencia). Igual que l4d2_pet_fusion.sp (4.35.0 original del owner).
- Inventario relevante del repo: includes completos de todos los personajes (Amy/Blaze/Cream/Eggman/Knuckles/Metal/Rouge/Sage/Sally/Shadow/Silver/Tails + OM_Stun.inc/PathSense/SBar/etc), historial completo CAMBIOS_*.txt + VERIFICACION_*.txt + diff_*.txt de las eras 3.77.7-3.77.52, worklog propio del owner (Tasks 57-58, era 3.77.51/52 ragdoll herencia de impulso), spcomp.exe/spcomp64.exe propios, Habilidades_Sonic_Char/, compiled/ (solo .lnk), scripting.zip, l4dd/ (left4dhooks fuentes), y ~200 plugins .sp del server.
- MANIFIESTO_SHA256.txt es de la era 3.77.51 (historico, no refleja el estado actual).
- "Se debe usar en chat gpt siempre.txt" = nota del owner sobre modo canvas de ChatGPT (sin reglas de proyecto).

Stage Summary:
- PROTOCOLO ESTABLECIDO: repo-scripting/ es el canon. Al inicio de cada tarea futura: git pull para capturar cambios del owner; todo analisis/compilacion parte del arbol del repo (mas los include/ del repo).
- Estado verificado: repo == rollback v3.77.91 limpio, cero OM activo. Nada que corregir.
- El owner gana: entregas futuras verificables contra el repo, historial completo de cambios conservado, y yo siempre al dia con sus ediciones locales.

---
Task ID: 26
Agent: Super Z (main agent)
Task: LLEGADA DEL LUA GMOD DE OM AL REPO — el owner anuncio "Mira en el repositorio esta los Lua De Gmod De OM" y pregunto si ya tengo contexto permanente. Protocolo git pull ejecutado -> commit 841e7e6 "Lua de GMOD" capturado.

Work Log:
- git pull trajo "Lua de OM de Gmod/" completo: 118 .lua, 3.8 MB (no estaba en el clon del commit 76659f2 — el push fue posterior; PRIMERA VEZ que el protocolo de monitoreo demuestra valor real).
- INVENTARIO DEL ADDON: [autorun/noodles_om_pills_base.lua 106KB = nucleo del sistema pills + noodles_om_pills_status.lua 54KB]; [autorun/include/survivor/ 17 personajes: sonic(97K), amy(77K), knuckles(85K), shadow(62K), silver(65K), metalsonic(93K), vector(62K), rouge(58K), mighty(107K), fang(96K), ray, espio, omega, eggman, modernsonic(131K), survivors2(183K), base]; [autorun/include/killer/: fleetway(247K el mas grande), eyx(122K), kolossos(122K), tripwire(87K), end_new(84K), 2011x(77K), lordx(68K), lilith(58K), steveoutcome(54K), etc]; [autorun/client/om/ 27 UIs de barra de habilidad por personaje]; [autorun/om_settings/register/: registro de survivors (155K+203K)]; [entities/ 14 entidades: ent_om_blaze_javelin_hold, ent_om_tails_speedboost, ent_om_vector_ring, ent_om_rouge_smokebomb_display, ent_om_eggman_display, ent_om_eyx_infection, ent_om_hedgehog_dropballs, etc]; [includes/modules/: om_afterimage, om_color, om_halo]; [effects/].
- Autores originales del addon: noodles, cinny, sky, redimated (prefijos de archivo).
- SIGNIFICADO: esta es la FUENTE ORIGINAL GMod de donde se porto todo (OM = pills system). Referencia definitiva para futuros ports/ajustes de habilidades: cada convar/comportamiento del SourcePawn tiene su receta Lua literal aqui.
- RESPUESTA AL OWNER SOBRE CONTEXTO PERMANENTE (honestidad): el repo SI es permanente (GitHub), pero mi memoria de sesion NO es infinita (el contexto se agota — ya paso con el resumen de continuacion) y el entorno local YA SE RESETEO una vez (Oct-18, Tasks 17-23 perdidas). Mitigacion en 2 capas: [1] worklog.md local (memoria operativa, se actualiza cada tarea); [2] el repo como canon externo (git pull al inicio de cada tarea). Propuesta hecha al owner: subir el worklog.md al repo tambien, para que la memoria mia viva en GitHub y cualquier reset se recupere al 100%.

Stage Summary:
- Lua de GMod de OM integrado al canon: 118 archivos, estructura completa mapeada (base/status/survivors/killers/UIs/entities/modules/effects).
- Protocolo git pull validado en producción: detectó y capturó un push posterior al clon inicial.
- Aclarado al owner: permanente = repo (si) + worklog (si, si se sube al repo); memoria de conversación = NO (contexto agotable), pero con las 2 capas la recuperación es completa en minutos.

---
Task ID: 27
Agent: Super Z (main agent)
Task: PORT DE KONOSSO (killer del Lua OM de GMod) A L4D2 — 14o personaje del suite. Pedido del owner: "Esta vez llevaremos a Kolosos. A L4d2. Tengo su modelo Avatar sin embargo... no tengo Un cuerpo CST que pueda hostearlo. por lo que el avatar solamente se montara en el survivor que este usando en ese momento." + generacion del worklog consolidado para el repo.

Work Log:
- WORKLOG CONSOLIDADO generado: download/WORKLOG_PARA_REPO.md (protocolo + estado actual + Tasks 1-26 + apendice historico Tasks 57-58 del repo). El owner debe copiarlo al repo y pushear para blindaje total de contexto.
- ANALISIS COMPLETO DEL LUA (noodles_om_pills_killer_kolossos.lua, 2758 lineas): pill register l.115, 4 slots UI (Charge E / Grab R / Indicator T / Block I con cds 22/25/14/14), stats del registro oficial (health 670, run 550, charge 1400, grab 1750, melee 55, impale 25, slam 15, punches 3, charge dur 7 +3.75/victima, no-control 5s, block 3.5s, indicator 5s), mecanicas completas extraidas (windup staged 0.15/0.35/0.75, HitList sin repetir, fling final fwd*5000+up*2000 / pared=random, lunge 0.6s esfera 90, agarre max 10s + victima-muere=cd 2s, wall bump cd 3.65, block = parry total + counter con ROCA rockgranite03b scale 3 arco 0.5s/peak 150, indicator = wallhack 32000 con pings/susurros, climb espacio+WS).
- IMPLEMENTACION include/Kolossos.inc v1.0-OM (~2050 lineas): avatar espejo patron Blaze v2.11 (doble copia R/L + TP + PauseFix + FSM 10Hz + sonda de seqs estilo Blaze_ResolveTry — LookupSequence NO existe en SM 1.12 + yaw suavizado 900deg/s + adopcion de huerfanos + RENDER_NONE reafirmado) | Charge receta Metal v5.0 (slot 4 del stack + auto-forward vel[0]=900 + DEBRIS + FOV 105 + watchdog de pared 0.6s + extension por victima con tope 20s + fling final) | Grab (lunge 400 + ventana 0.6s + commons por movetype / SI por OM_Stun + en vilo 55u por FSM + 3 puos 15d + release fling) | Indicator (nube env_sprite glow01 nativa roja sobre SI+commons+witch en radio convar, refresco 10Hz + ping 1s + susurro) | Block (OnTakeDamage = 0 a infectados + counter: gira + roca balistica modelscale convar + StartTouch AoE 100 + watchdog 3s) | pasivas vida 670 (receta Metal) + resistencia | 25 convars con defaults del registro GMod | sm_kolossos debug.
- ANTI-CRASH v3.77.85 APLICADO: el dano de la avalancha y la roca usan SNAPSHOT (64 refs max) + dano FUERA de los FindEntityByClassname re-validando (la leccion del "crash silencioso de la horda").
- MANAGER 3.77.91 -> 3.77.94 (92/93 quemadas por la era OM): 17 puntos aditivos (MAX_CHARS 14, KOLOSSOS_INDEX 13, nombres, cstkey "kolossos" identidad L0, include tras Silver, 4 dispatchers de habilidad, RunCmd con vel, bind B como Rouge, banner sm_sjsver con KOLOSSOS_INC_VERSION, CleanupCharModuleState, OnPluginStart/OnMapStart). Speed_sonic.inc: SPEED_STACK_SLOTS 3->4 + SPEED_STACK_KOLOSSOS 3. CERO FX tocados, cero cambios en otros modulos.
- BUGS DE COMPILACION RESUELTOS: (1) LookupSequence inexistente -> sonda SetAnimation+m_nSequence; (2) KOL_CHG_WINDUP redefinido (estado vs duracion) -> KOL_CHG_WINDUP_T; (3) transmit hooks debian ser Action (bool no matchea SDKHook_SetTransmit); (4) FloatValue() con parentesis = propiedad, no metodo (error 012); (5) "om/kolossos/*" dentro de comentarios = nested comment warning 216 -> reescrito; (6) timers del windup con codificacion userid*10+stage (el +100000 se rompia con userids grandes).
- COMPILACION: spcomp64 1.12.0.7119, arbol del repo (canon): 0 errores / 0 warnings nuevos. Unico warning: halflife.inc(655) 234 CreateDialog — PREEXISTENTE del baseline del arbol (verificado compilando la 3.77.91 intacta ANTES de tocar nada: mismo warning). Code 1.929.400 B, smx 684.861 B, MD5 c487b2603056cbeee6a4e8b7a47194f8.
- FORENSE DEL BINARIO (payload zlib @482, 3.835.248 B): 32/33 marcadores (los 13 convars, Kolossos x142, om/kolossos x44, avatar/rock names, glow01 x31, mensajes de las 4 habilidades, 3.77.94 x3, sm_kolossos, FSM, dispatcher; el ausente = SPEED_STACK_KOLOSSOS que es constante de compilacion). ANTI-CHECK: l4d2_om_survivors / m_afButtonDisabled / PoppyDecoy / ChampNav = 0 apariciones.
- PAQUETE download/kolossos_v1/ + zip 875.307 B sha256 9500bf8c...: plugins/Sonic_ability_manager.smx 3.77.94 + scripting (manager .sp + Kolossos.inc NUEVO + Speed_sonic.inc modificado) + LEEME.txt (kit, instalacion 3 archivos, modelo models/noodles/om/kolossos.mdl, sonidos sound/om/kolossos/, verificacion 9 pasos, convars) + CAMBIOS_37794_Kolossos.txt (autopsia completa).
- SUBIDA: transfer 20261021slvYOyTh, verificado descargable 875307/875307 B.

Stage Summary:
- ENTREGADO: https://www.transfernow.net/dl/20261021slvYOyTh (kolossos_v1.zip, 0.9 MB).
- Kolossos = 14o personaje del suite, avatar espejo sobre el survivor actual (sin CST), kit completo Z/X/C/B con los defaults oficiales del GMod, todo convars calibrables, anti-crash de horda de fabrica.
- El owner necesita: reemplazar el smx + 2 fuentes; OPCIONAL: poner su Kolossos.mdl en models/noodles/om/kolossos.mdl (sin el = kit sin espejo) y copiar sound/om/kolossos/ del addon GMod (sin ella = fallbacks nativos).
- NO portado a v1: M1 de puos (L4D2 usa armas) y Climb de paredes (posible v1.1).
- Worklog consolidado listo para el repo: download/WORKLOG_PARA_REPO.md.

---
Task ID: 28
Agent: Super Z (main agent)
Task: KOLOSSOS v1.1 — fixes al reporte del owner tras probar kolossos_v1: (1) "Las animaciones de kolossos faltaron" y (2) "el personaje se dobla a mirar al mover la camara, un error viejo de cuando probabamos a Tails" (el fix de erguirse al pausar que Amy y los demas si tienen). Protocolo git pull ejecutado al inicio.

Work Log:
- GIT PULL: commit 0ad0518 "New" del owner = la entrega v1 (manager 3.77.94 + Kolossos.inc v1.0-OM + Speed_sonic.inc) ya en canon; verificado byte-identico a kolossos_v1.
- DIAGNOSTICO BUG DOBLADO: es EXACTAMENTE el bug v5.4 de la era Tails ("cuerpo inclinado con la mira", documentado en Tails.inc L2755-2774). La copia L del avatar (la que ve el DUENO) estaba contra-rotada con GetClientAbsAngles; pero el cliente del dueno arma el parent contra su cuerpo PREDICHO = camara COMPLETA (pitch incluido). Blaze (L1239-1241) y Tails (L2946-2948) usan GetClientEyeAngles para la copia L — el port v1.0 uso par. Bug de portado, no del patron.
- DIAGNOSTICO ANIMACIONES: el registro del Lua tiene 10 secuencias en anims.default (L134-145) + 6 alternates de ShouldAlternate (L322-395: stun/BlockPos/chargestart/charge_notimpaled/Charge_impaled + run->walk con victima) + animrates (L404-439: charge 1.2 / grabbing 3). La v1.0 solo cableo 5.
- FIX DOBLADO: AvatarFollow copia L -> GetClientEyeAngles + Tails_AvatarLocalAngles(eye[0], eye[1], ...) con comentario del porque (receta Tails v5.17-B / Blaze). El coloso queda vertical SIEMPRE en la pantalla del dueno, ergido tambien al pausar.
- ANIMS COMPLETAS: FSM 5 -> 15 estados (KOL_ST_*: +STUN/CHARGESTART/CHARGE/CHARGE_IMP/BLOCKSTART/BLOCK/BLOCKPROJ/COUNTER/SLAMINWALL/KILL) con la prioridad textual del ShouldAlternate; sistema NUEVO de one-shots (Kolossos_AnimShot) para las anims no-continuas; 10 tablas de candidatas nuevas en la sonda + cadena de fallbacks explicita (Kolossos_FallbackTo: charge->run, counters->BlockPos, etc. — nunca T-pose).
- CABLEADO ONE-SHOTS: Ability4 = BlockStart 0.5s (GMod l.2520); BlockCounter = BlackCounterMelee <300u / BlockProjectile si no (l.1347-1355); ChargeEnd hitWall CON empalados = slaminwall 1.3s + Sound.mp3 (l.1729-1747; hadImpaled capturado ANTES de FlingHitList); GrabPunch que MATA = Kill 1.65s + risa a +1s (l.1137/l.1220). Avalancha: rate 1.2 (antes 1.6) y Charge_impaled con HitList>0. Lunge del grab: paso 3x.
- SONIDOS NUEVOS: g_bKolSndSlam (sound/om/kolossos/Sound.mp3) + g_bKolSndLaughKill/g_sKolLaughPath (Kolossos laughing.wav, probe con K mayuscula y minuscula).
- VERSIONES: Kolossos.inc v1.0-OM -> v1.1-OM + manager 3.77.94 -> 3.77.95 (banner sm_sjsver auto-actualiza por macro).
- COMPILACION: spcomp64 1.12.0.7119, arbol repo canon: 0 errores / 1 warning preexistente (halflife.inc CreateDialog). smx 686.772 B, MD5 edaae2a416eeaf1c2b63d07382155186.
- FORENSE: 30/30 marcadores en el binario (secuencias nuevas, sonidos, one-shot system, GetClientEyeAngles, base v1.0 intacta); ANTI-CHECK limpio (cero camino OM-survivors, cero "3.77.94").
- PAQUETE download/kolossos_v11/ + zip 880.974 B: smx + fuente + Kolossos.inc v1.1 + Speed_sonic.inc + LEEME + CAMBIOS_37795. SUBIDA: transfer 2026102103phZocY verificado.

Stage Summary:
- ENTREGADO: https://www.transfernow.net/dl/2026102103phZocY (kolossos_v11.zip, 0.9 MB).
- FIX DOBLADO + las 15 anims del registro Lua cableadas con sonda y fallbacks encadenados.
- El owner reemplaza 3 archivos (smx + 2 fuentes). OPCIONAL: Sound.mp3 + Kolossos laughing.wav en sound/om/kolossos/.
- Pendientes historicos del port: Climb de paredes, M1 de puños.


# APÉNDICE — worklog histórico del repo (Tasks 57-58, era 3.77.51/52, conservado del push original)


---
Task ID: 57
Agent: main (Super Z)
Task: L4D2/SMX 1.12 — "Chequeo de estabilidad del Ragdoll": el ragdoll falso (doble) no recibe NINGUN impulso al crearse (golpe final de Sonic, lanzamiento de martillo de Amy, autodestruccion de Metal). Mision: solucion exacta para que el doble sea lanzado con fisica real.

Work Log:
- Fuente: scripting3.zip del owner (file.garden, base 3.77.47 = arbol 3.77.45 + overlay 3.77.46). Unica fuente de verdad.
- FORENSE DEL PIPELINE: el doble lo spawnea Sonic_SpawnFlingRagdoll / Sonic_SpawnWitchRagdoll (include/sonic.inc, territorio SonicManager), llamados por sonic.inc:5204 (Sonic_OM_FinalThrow), Amy.inc:10396 (martillo OM) y Metal.inc:3068 (autodestruccion). El lanzamiento v6.11 era SOLO env_physexplosion (Sonic_RagBlast): targetname unico + magnitud escalada por masa (sonicom_ragblast 700).
- AUTOPSIA CON HL2SDK (clone sparse alliedmodders/hl2sdk rama l4d2, lectura real de motor):
  * CPhysExplosion::Explode (physobj.cpp:931): gate m_takedamage != DAMAGE_NO + MOVETYPE_VPHYSICS (CRagdollProp::InitRagdoll lo pasa: m_takedamage=DAMAGE_EVENTS_ONLY, physics_prop_ragdoll.cpp:690). Con NODAMAGE llama VPhysicsTakeDamage -> CBaseEntity::VPhysicsTakeDamage (baseentity.cpp:1399) -> ApplyForceOffset sobre VPhysicsGetObject() = SOLO el hueso raiz (list[0]).
  * CalculateExplosiveDamageForce (takedamageinfo.cpp:294): clamp duro ImpulseScale(75,400)=30.000 y multiplicacion por phys_pushscale.
  * CBaseEntity::Teleport con velocidad (baseentity.cpp:4294-4297): pPhys->SetVelocity(vel) directo al objeto vphysics = EXACTAMENTE el Entity:SetVelocity del GMod sobre ragdoll (raiz). CRagdollProp::Teleport (physics_prop_ragdoll.cpp:920) reubica todos los huesos y pasa newVelocity al base.
- EVIDENCIA CRUZADA DEL PROPIO ARBOL: la unica version que hizo volar ragdolls falsos en ESTE server (Amy v91, Rouge v10 = Rouge_FlingRagdoll Rouge.inc:1951, port directo del CreateRagdollCharacter_OM del lua) usa TeleportEntity SOLO-velocidad (dir*500 + z300) + SetEntPropVector m_angVelocity — NUNCA confio en la explosion sola para ragdolls. Hallazgo R11 documentado en Amy.inc:4400 ("el cuerpo dormido ignora m_vecVelocity"). Conclusion: en L4D2 la ruta env_physexplosion->VPhysicsTakeDamage entrega ~cero a un prop_ragdoll de servidor; la v6.11 aposto todo a esa ruta y el doble nacio muerto (solo gravedad).
- FIX QUIRURGICO (solo sonic.inc, v6.14 "LA HERENCIA"):
  * Nueva Sonic_RagFling(rag, fDir): vel = fDir*sonicom_ragblast(700 = hitdirection*700 del lua) + SONIC_RAG_LIFT 280z; TeleportEntity(rag, NULL, NULL, vel) = empuje fisico real al hueso raiz; + m_angVelocity aleatorio (-900..900/-400..400, mismo Rouge) para el tumble del AddAngleVelocity del lua.
  * SpawnFlingRagdoll y SpawnWitchRagdoll llaman Sonic_RagFling en reemplazo del bloque de la onda.
  * ELIMINADO: Sonic_RagBlast completo, g_iSonicRagSerial, targetname "sonicrag%d", #define SONIC_RAG_BLASTBACK/BLASTDOWN/BLASTRAD, la entity env_physexplosion por spawn (menos handles/netmsg).
  * sonicom_ragblast REPURPOSADO (mismo nombre/default 700/rango 50..5000, ahora = u/s de lanzamiento) = cero churn en el Sonic_Suite.cfg del server.
  * Resto INTACTO: EnableMotion+Wake al nacer, spawn +24u adelantado, DEBRIS (MakePassable v6.12), ghost collision de la victima (v6.7), RENDER_NONE, StunWatch, reaparicion con hueco seguro (v6.13).
- TESTEO SIMULADO: ragdoll despierto al inyectar (bWake=true en InitRagdoll + inputs Wake) -> SetVelocity se integra el siguiente tick de vphysics; servidor-autoritario (sin prediction); huesos viajan por m_ragPos interpolado = vuelo continuo visible; cero timers/handles nuevos; DEBRIS no afecta la integracion fisica.
- COMPILACION (spcomp64 1.12.0.7255 linux, -i arbol del owner): baseline 3.77.47 = 0 warnings / code 1.375.772 B; parcheado = 0 warnings / code 1.374.448 B / data -204 B (onda muerta fuera). EXIT 0. grep final: 0 referencias muertas (Sonic_RagBlast/serial/BLAST*/sonicrag), Sonic_RagFling definida 1x y llamada 2x (victima + witch).
- Transfernow (lua Gmod): pagina JS-gated sin link directo; no fue necesario: la receta del lua ya estaba destilada en el worklog (linea 1016: "SetVelocity 700 + AddAngleVelocity por hueso y vphysics hace el resto") y su port vivo (Rouge_FlingRagdoll) estaba en el arbol.

Stage Summary:
- CAUSA RAIZ: la v6.11 lanzaba al doble SOLO con env_physexplosion; en L4D2 esa fuerza (VPhysicsTakeDamage->ApplyForceOffset) no llega al prop_ragdoll de servidor -> el doble nacia sin impulso y solo caia. Los tres sintomas (Sonic/Amy/Metal) comparten ese unico punto.
- SOLUCION: herencia de velocidad inyectada UNA vez al hueso raiz via TeleportEntity solo-velocidad (el SetVelocity del GMod) + m_angVelocity para el giro; la onda y su plomeria (targetname/serial/explosion entity) eliminadas; sonicom_ragblast repurpouseado a u/s (default 700).
- Entregable: download/sonic.inc_v6.14_herencia_ragdoll (reemplazo directo de include/sonic.inc; compila limpio con SM 1.12, 0 warnings, verificado contra baseline).
- Cola: si el owner quiere vuelo mas alto/mas largo = sonicom_ragblast (u/s) o ajustar SONIC_RAG_LIFT; el doble sigue muriendo solo al terminar el stun (StunWatch intacto).

---
Task ID: 58
Agent: main (Super Z)
Task: 3.77.52 "EL RAGDOLL FALSO POR FIN HEREDA EL IMPULSO" — el owner respondio a la v6.14 de la Task 57 pidiendo QUE YO MODIFIQUE DIRECTAMENTE LO NECESARIO PARA ASEGURAR QUE FUNCIONE ("Y xq no simplemente lo modificas tu las cosas nesesarias. eh? para asegurarnos que esto funcione"). Entrega COMPLETA sobre SU arbol: ediciones hechas, compilado con SU compilador, paquete con smx + fuentes + diffs + informe.

Work Log:
- BASE: scripting3.zip re-descargado (13.795.005 B) — el arbol del owner ya estaba en 3.77.51 (Anti caida v3 + Metal v5.7.1) con sonic.inc v6.32 y Rouge v10.3, compila limpio con spcomp 1.12.0.7253 (0/0, verificado recompilando la baseline como referencia).
- SDK A FONDO (descarga real de hl2sdk rama l4d2, archivos: physobj.cpp, physics_prop_ragdoll.cpp, baseentity.cpp, takedamageinfo.cpp/h, vphysics_interface.h):
  * CPhysExplosion::Explode (physobj.cpp:931-1055): gate m_takedamage!=DAMAGE_NO (InitRagdoll:690 pone DAMAGE_EVENTS_ONLY=1, PASA) + la fuerza NODAMAGE va por CBaseEntity::VPhysicsTakeDamage:1399 -> ApplyForceOffset SOLO al hueso raiz (VPhysicsSetObject(list[0]) en InitRagdoll:758) — y antes CalculateExplosiveDamageForce (takedamageinfo.cpp:294-320) la clamp a ImpulseScale(75,400)=30000 y la multiplica por phys_pushscale.
  * prop_ragdoll NO TIENE m_iMass (datadesc de CRagdollProp: physics_prop_ragdoll.cpp:73-144) — el "escalado por masa" de la v6.11 nunca funciono (leia un campo inexistente, masa default 100 siempre).
  * DATAMAP PUBLICO DE HUESOS: DEFINE_PHYSPTR publica "m_pPhysicsObject" (hueso 0, baseentity.cpp:1688) y "m_ragdoll.list[i].pObject" i=1..23 + "m_ragdoll.listCount" (physics_prop_ragdoll.cpp:114 + DEFINE_RAGDOLL_ELEMENT) — los punteros IPhysicsObject de TODOS los huesos son legibles con FindDataMapInfo + GetEntityAddress + LoadFromAddress.
  * VTABLE IPhysicsObject (vphysics_interface.h branch l4d2, contada por script): IsAsleep win=2/lin=3, IsMotionEnabled win=9/lin=10, IsMoveable win=10/lin=11, GetMass win=29/lin=30, SetVelocity(const Vector*, const AngularImpulse*) win=50/lin=51 (+1 en Linux: destructor virtual doble Itanium). El bloque #if OBJECT_WELDING (slots ~78+) NO afecta esos indices.
  * TeleportEntity con velocidad -> static TeleportEntity (baseentity.cpp:4296) pPhys->SetVelocity(newVelocity, NULL) al hueso raiz; CRagdollProp::Teleport:920/951 reubica huesos y pasa la velocidad intacta = la ruta que ya vuela los cuerpos del Barrido de Rouge en este server.
  * OS: L4D_GetServerOS (left4dhooks.inc:4862, 0=Windows 1=Linux; el manager ya #incluye left4dhooks:1989). Precedente SDKCall_Raw+virtual en el MISMO server: l4d2_block_no_steam_logon.sp.
- ARQUITECTURA v6.33 (PRIMERA VUELTA): Sonic_RagPhysLaunch = SDKCall_Raw + PrepSDKCall_SetVirtual contra IPhysicsObject por hueso con 4 sondas semanticas + fallback a la onda v6.11. SEGUNDA VUELTA (final): la onda retirada del funnel porque su fuerza nunca llego al doble en este server — reemplazada por CASCADA DE 2 CAPAS: (1) Sonic_RagPhysLaunch per-bone (la receta GMod literal: lineal igual para todos + giro random POR HUESO via SetVelocity); (2) Sonic_RagFlingEngine = TeleportEntity-vel (motor puro, ruta Rouge probada, cero dependencias). La onda de Amy (Amy_PropBlastWake, AUTOS) INTACTA.
- BLINDAJE capa 1: feature-check L4D_GetServerOS -> sin left4dhooks cae a capa 2; offsets datamap cacheados 1 vez (root/count/bone[1..23]); pRoot NULL-check; 4 SONDAS sobre el hueso raiz antes de tocar velocidad (IsMotionEnabled==1 tras el input EnableMotion, IsMoveable==1, IsAsleep en {0,1}, GetMass en [0.05,10000]) — si una falla, capa 2; vecinos de sondas en vtable = getters bool puros (lecturas inocuas ante desfase hipotetico); listCount clampeado 1..24; L4D2 32-bit en ambos OS (punteros Int32, documentado).
- CAMBIOS (3 archivos del owner, cirugia minima):
  * sonic.inc v6.32 -> v6.33: bloque v6.33 completo (RagPhysPrep/Ready/CacheOffsets/Launch + RagFlingEngine); SpawnFlingRagdoll + SpawnWitchRagdoll usan la CASCADA; RETIRADO Sonic_RagBlast + g_iSonicRagSerial + #defines BLASTBACK/BLASTDOWN/BLASTRAD + targetname; sonicom_ragblast ahora = u/s de lanzamiento (default 700 = SetVelocity*700 del GMod, ambas capas, mismo rango 50..5000 = cero churn de cfg); header/changelog SONIC_OM_VERSION v6.33-OM.
  * Rouge.inc v10.3 -> v10.4: Rouge_FlingRagdoll fuera el m_angVelocity muerto; capa 1 (dir*500 + 300z + giro por hueso) y capa 2 (Sonic_RagFlingEngine con su 300 fijo).
  * Sonic_ability_manager.sp 3.77.51 -> 3.77.52: SOLO version + changelog + banner sm_sjsver ("RAGDOLL CON IMPULSO REAL..." + Rouge v10.4).
- COMPILACION FINAL (spcomp64 1.12.0.7253 linux descargado de sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7253-linux.tar.gz, -i arbol del owner): 0 errores 0 warnings (baseline 3.77.51 recompilada de referencia: mismos ceros). Code 1.378.164 (base 1.375.772, +2.392 neto). smx 461.671 B sha256 7cad73c684bfab45a28e9b0dc6d261a4d5e01e3211094b7ef4629190e20550eb.
- FORENSE FINAL: payload zlib @482 (FFPS, 2.497.141 B): 26/26 marcadores presentes (5 funciones v6.33, 3 campos datamap, L4D_GetServerOS, FindDataMapInfo, PrepSDKCall_SetVirtual, 3.77.52, v6.33-OM, v10.4-OM, regresion Amy/Metal/witch/RagSafeSpot/OM_Stun/ChCh_KnxNotify) + ONDA AUSENTE del binario (Sonic_RagBlast, Sonic_RagWaveFallback, g_iSonicRagSerial, targetentityname; el env_physexplosion restante = Amy_PropBlastWake, sistema de AUTOS intacto). Balance llaves/parser: 0/0/0 en los 3 archivos.
- diff -r vs scripting3.zip: SOLO difieren los 3 archivos de la entrega (verificado).
- PAQUETE download/suite_37752_ragdoll_impulso/: smx + sp + include/sonic.inc v6.33 + include/Rouge.inc v10.4 + 3 diffs (419/66/51 lineas) + CAMBIOS_37752_RagdollImpulso.txt (autopsia + cascada + instalacion 2 caminos + plan de prueba 6 puntos + palancas) + VERIFICACION_37752.txt + worklog.md. ZIP 828 KB sha256 c4ff5e10... (ver abajo del re-upload final).
- UPLOAD filebin tails-v517-opciones-9xk2 (metodo body crudo POST octet-stream, leccion Task 54) + re-descarga verificada BYTE A BYTE + unzip -t OK. (El zip de la primera vuelta con la onda de fallback fue reemplazado por el final de la cascada.)

Stage Summary:
- ENTREGADO el fix COMPLETO del "ragdoll falso que no hereda impulso": cascada de 2 capas con fisica REAL — capa 1 = SetVelocity POR HUESO directo al simulador vphysics (SDKCall_Raw contra IPhysicsObject con punteros leidos del datamap publico del CRagdollProp — la receta GMod literal, con giro por hueso), capa 2 = TeleportEntity-vel al hueso raiz (ruta motor pura baseentity.cpp:4296, la misma que ya vuela los cuerpos de Rouge en ese server). La onda env_physexplosion v6.11 RETIRADA: su fuerza nunca llegaba (autopsia con el fuente del motor: VPhysicsTakeDamage raiz + clamp 30000 + phys_pushscale + el "escalado por masa" leyendo un campo que prop_ragdoll no tiene).
- Los 4 flingers cubiertos por el mismo embudo: golpe final de Sonic, martillo de Amy, self-destruct de Metal, ritual de la witch + el Barrido de Rouge contra comunes.
- Compilado con SU compilador (1.12.0.7253): 0/0 exacto de la baseline. Forense 26/26 + onda ausente + diff -r limpio (solo los 3 archivos).
- Descarga: https://filebin.net/tails-v517-opciones-9xk2/suite_37752_ragdoll_impulso.zip (bin expira 2026-10-19) + espejo download/suite_37752_ragdoll_impulso/.
- Cola: probar el plan de 6 puntos (sm_sjsver -> 3.77.52 + los 4 vuelos + Barrido); si las sondas no cuadraran, todo corre en capa 2 solo; palancas sonicom_ragblast (u/s) + SONIC_RAG_PHYSLIFT/SONIC_RAG_TUMBLE.
