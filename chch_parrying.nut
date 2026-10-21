printl("Ultrakill-like parrying v2.4 loaded: LOOP SELF-BOOTSTRAP + punchstun del counter (fix roca/sonido del owner)")
// ------------------------------------------------------------------
// v2.4 (suite 3.77.39 — fix del reporte del owner 2026-10-10:
//   "ya el vscript no bloquea auto la roca del tank" y "el counter
//   no hace el sonido de om/knuckles/punchstun.wav ni nada"):
//   - EL LOOP YA NACE AL CARGAR EL ARCHIVO (EnsureLoop): antes solo
//     lo creaba OnGameEvent_round_start — si el .nut se cargaba con
//     la ronda YA andando (plugin recargado a mitad de mapa, sm
//     plugins refresh SIN cambio de mapa) el evento nunca llegaba,
//     el loop no existia y NADIE parreaba la ventana (el smx, viendo
//     el handshake en 1, confiaba en este script = roca sin
//     bloquear y sin sonido NADA). Ahora: bootstrap al cargar +
//     round_start lo refresca + el Parry.smx v2.3 lo vigila con un
//     watchdog cada 2 s (::ChCh_EnsureLoop) + el smx vuelve a
//     escanear NATIVO siempre (anti-robo por m_hThrower en ambos
//     lados = el que agarra primero es el dueno).
//   - EL SONIDO DE LA VENTANA KNX VUELVE A SER EL DEL COUNTER:
//     om/knuckles/punchstun.wav (el que pide el owner; el
//     hulk_punch_1 de la v2.3 no existe como WAV y quedaba mudo —
//     "ni nada"). El manager lo precachea en cada mapa.
//   - HEARTBEAT: uk_parry_nut_beat = Time() en cada EnsureLoop para
//     que knx_parry_status (Parry.smx v2.3) diga si este script esta
//     VIVO y el loop corriendo.
// ------------------------------------------------------------------
// v2.3 (suite 3.77.38 — reporte del owner 2026-10-10):
//   - EL SHOVE DEL PARRY YA NO PRODUCE STAGGER sobre el objetivo NI
//     DAÑO DESDE LEJOS: PerformEnemyParry pasa a ser PURO EMPUJE
//     (ni Stagger() ni TakeDamage() — el stagger/daño son cosa del
//     counter del manager, no del parry).
//   - FIX DEL SONIDO DEL BLOQUEO: "GolfClub.ImpactWorld" es un nombre
//     de script que NO existe en L4D2 (impacto mudo). Ahora suena el
//     WAV real del golf club; y el parry de ENEMIGOS en ventana
//     tambien lleva el jugo sonoro (SLAM + hint) — el fix del
//     "bloquea el salto de hunter/jockey/smoker y no suena nada".
//   - EFECTO ESPECIAL VS BOOMER (Knuckles): el boomer empujado por la
//     ventana/shove sale VOLANDO con MECHA y ESTALLA AL TOCAR EL
//     SUELO — nunca le explota encima.
//   - AMY USA EL MISMO SISTEMA con CONTADOR APARTE: la abre su POSE DE
//     DEFENSA de la Z (el manager avisa por la misma API
//     ChCh_KnxNotify), dura lo que dure la pose y se cierra al
//     consumirla; si un PROYECTIL entra en rango se le avisa al
//     manager (amyparry_strike) y sale LA DEFENSA DE MARTILLO
//     (el ataque + el aura) con SU sonido.
// ------------------------------------------------------------------
// FIX v2.1: Squirrel (VScript de L4D2) NO trae max ni min nativos.
// El mod original llamaba max en una via poco frecuentada (bug latente)
// y la v2.0 lo uso en CheckEnemyParry, que corre en CADA shove:
// "the index 'max' does not exist" + el parry de enemigos quedaba
// muerto. Definicion en el root, protegida contra re-ejecucion:
// ------------------------------------------------------------------
if (!("max" in getroottable()))
{
    ::max <- function(a, b) { return (a > b) ? a : b; }
}
if (!("min" in getroottable()))
{
    ::min <- function(a, b) { return (a < b) ? a : b; }
}

if (!("ChCh_Parrying" in getroottable()))
{
    ChCh_Parrying <-
    {
        ShovingPlayerData = {}

        // ------------------------------------------------------------------
        // v2.2 — MODO ESTADO KNX: mientras el smx (Parry.smx v2.1+) avise
        // que el jugador esta en parry, este script escanea y parrea SOLO
        // (sin shove). EntIdx del jugador -> { until }
        // ------------------------------------------------------------------
        KnxWindows = {}

        // v2.2 — cooldown de parry de ENEMIGOS durante la ventana (1 s por
        // enemigo: sin ametralladora de staggers a 30 Hz)
        KnxEnemyCD = {}

        // v2.2 — flags vivos de la ventana (tabla para mutar por referencia)
        KnxState = { enemyThrottle = false }

        // v2.3 — MECHAS DE BOOMERS: ent -> { air, until, atk }. El
        // boomer empujado vuela y ESTALLA al tocar el suelo (KnxBoomerTick)
        KnxBoomers = {}

        Settings =
        {
            // Opciones de sonido y visuales
            Parried_Sound = 1
            FX_Scale = 0.45            // Tamano del destello azul (antes 0.25)
            FX_Duration = 0.22         // Duracion del destello (antes 0.15)

            // Proyectiles Vanilla
            Parry_Molotovs = 1
            Molotov_Explode = 1
            Parry_Pipes = 1
            Pipe_Fire = 1
            Parry_Bile = 1
            Parry_Spit = 1
            Spit_Explode = 1
            Parry_Grenade_launcher = 1
            Parry_Rocks = 1 // Tank Rock

            // --- Opciones Parry Universal (Proyectiles Custom) ---
            Universal_Parry = 1
            Parry_Radius = 300          // Radio de deteccion de proyectiles
            Universal_MinVelocity = 75  // Velocidad minima para considerar "en vuelo"
            Reflect_Use_Aim = 1         // 1 = el proyectil reflejado sale hacia donde apuntas (coherente con ParryGrenade); 0 = reflexion especular clasica

            // --- Opciones de PRECISION ---
            Parry_Directional = 1       // 1 = los proyectiles deben estar en tu cono frontal o pegados a ti; 0 = esfera completa (clasico)
            Parry_Cone_Dot = 0.30       // Apertura del cono frontal: 0.30 = ~72 grados a cada lado
            Parry_Cone_MinDist = 100    // Proximidad de emergencia: dentro de esta distancia siempre se puede parry

            // --- Opciones Parry de Enemigos ---
            Parry_Charger = 1           // 1 = Interrumpe carga y aturde (Stagger)
            Parry_Melee_Infected = 1    // 1 = Aturde a Hunters, Jockeys, Smokers, etc. en rango melee
            Parry_Witch = 1             // 1 = Permite aturdir a la Witch (Riesgoso pero posible)
            Parry_Hunter_Pounce = 1     // 1 = NUEVO: Hunters en pleno salto (pounce) son parreables en vuelo
            Melee_Parry_Radius = 200    // Radio de parry melee (antes 150)
            Hunter_Parry_Radius = 260   // Radio del parry anti-pounce del Hunter

            // --- Opciones de balance ---
            Explosion_Hurt_Team = 0     // 0 = las explosiones de parry NO danan a los supervivientes (QoL); 1 = comportamiento clasico (FF)

            // --- v2.2: VENTANA DE PARRY (modo estado; la abre/cierra el smx) ---
            Knx_Window = 1              // 1 = la ventana externa funciona; 0 = el .nut ignora los avisos del smx
            Knx_Window_Max = 3600.0     // tope si abren la ventana sin duracion ("hasta la orden de apagado")
            Knx_Window_IncomingOnly = 1 // 1 = la ventana solo agarra lo que viene HACIA el jugador (receta Amy: >250 u/s y coseno 0.3); 0 = todo lo que caiga en la esfera/cono
            Knx_Window_Enemies = 1      // 1 = la ventana tambien parrea enemigos (charger/hunter/witch/melee) con cooldown de 1 s por enemigo; 0 = solo proyectiles
            Knx_Window_Sound = "om/knuckles/punchstun.wav" // v2.4: EL SONIDO DEL COUNTER de Knuckles (el del owner; lo precachea el manager en cada mapa). "" = apagado
            Amy_Window_Sound = "OM/Amy/HammerHit.wav" // v2.3: sonido de AMY en SU ventana (contador aparte; lo precachea el manager del suite). "" = apagado
            Knx_Boomer_Fuse = 1        // v2.3: el boomer empujado por la ventana/shove ESTALLA al tocar el suelo tras volar. 0 = apagado
            Knx_Debug = false           // true = log en consola de cada aviso ON/OFF que llega del smx
        }
    }
}

// Función auxiliar para crear fuego
function ChCh_Parrying::DropFire(pos)
{
    local fire = SpawnEntityFromTable("env_fire", {
        origin = pos,
        targetname = "parry_fire",
        health = 30,
        firesize = 64,
        fireattack = 4,
        ignitionpoint = 32,
        damagescale = 1.0,
        spawnflags = 256 + 2 + 1
    });
    if (fire) {
        EntFireByHandle(fire, "StartFire", "", 0, null, null);
        EntFireByHandle(fire, "Kill", "", 15.0, null, null);
    }
}

function ChCh_Parrying::ParseSettings()
{
    // Carga de configuración (simplificada para este ejemplo)
    // Si tienes un archivo cfg externo, mantén la lógica de lectura aquí.
}

// -------------------------------------------------------------------
// Helpers de estado de infectados (tolerantes a fallos de NetProps)
// -------------------------------------------------------------------
function ChCh_Parrying::IsPlayerCharger(ent) { return ent.GetZombieType() == 6; }

function ChCh_Parrying::IsCharging(ent)
{
    try { return NetProps.GetPropInt(ent, "m_isCharging") == 1 } catch(e) { return false }
}

function ChCh_Parrying::IsPouncing(ent)
{
    try { return NetProps.GetPropInt(ent, "m_isPouncing") == 1 } catch(e) { return false }
}

// Filtro de cono frontal: devuelve true si el objetivo es parreable segun Parry_Directional
function ChCh_Parrying::PassesConeFilter(who, delta, dist)
{
    if (Settings.Parry_Directional == 0) return true   // Esfera completa (comportamiento clasico)
    if (dist <= Settings.Parry_Cone_MinDist) return true // Emergencia: esta practicamente encima de ti
    if (dist < 0.001) return true
    local dir = delta.Scale(1.0 / dist)
    return who.EyeAngles().Forward().Dot(dir) >= Settings.Parry_Cone_Dot
}

// -------------------------------------------------------------------
// Efectos Visuales y Sonoros (Feedback de Parry)
// -------------------------------------------------------------------
function ChCh_Parrying::PlayParryEffects(who, pos)
{
    if (Settings.Parried_Sound >= 1)
    {
        // v2.3 FIX DEL SONIDO: "GolfClub.ImpactWorld" es un NOMBRE DE
        // SCRIPT que no existe en L4D2 = el impacto quedaba SILENCIOSO
        // (el bug del "bloquea el salto y no suena el bloqueo"). El
        // WAV real del golf club (el mismo que usa el Parry.smx) suena
        // SIEMPRE.
        EmitSoundOnClient("weapons/golf_club/hit_world_01.wav", who)
        // QoL: ahora el impacto de parry tambien se oye en el mundo (los demas jugadores cerca lo perciben)
        EmitSoundOn("weapons/golf_club/hit_world_01.wav", who)
    }

    // Flash Azul estilo Ultrakill (mas grande y duradero para que se lea mejor)
    local fx = SpawnEntityFromTable("env_sprite", {
        origin = pos,
        model = "sprites/physcannon_bluecore1.vmt",
        scale = Settings.FX_Scale,
        rendercolor = "100 255 255",
        rendermode = 9,
        spawnflags = 1
    })
    if (fx) EntFireByHandle(fx, "Kill", "", Settings.FX_Duration, null, null)
}

// -------------------------------------------------------------------
// Lógica para Parry de Enemigos (Chargers, Hunters, Witch, melee)
// -------------------------------------------------------------------
function ChCh_Parrying::CheckEnemyParry(who, pos, fwd)
{
    if (Settings.Parry_Charger == 0 && Settings.Parry_Melee_Infected == 0
        && Settings.Parry_Witch == 0 && Settings.Parry_Hunter_Pounce == 0) return;

    // Esfera de busqueda: cubre el mayor radio usado por cualquier caso
    local searchRadius = max(Settings.Melee_Parry_Radius, Settings.Hunter_Parry_Radius);
    local ent = null;

    while (ent = Entities.FindInSphere(ent, pos, searchRadius))
    {
        if (!ent.IsValid()) continue;
        local cls = ent.GetClassname();
        local dist = (ent.GetOrigin() - pos).Length();

        // --- PARRY CHARGER ---
        if (cls == "player" && IsPlayerCharger(ent) && Settings.Parry_Charger == 1)
        {
            if (IsCharging(ent) && dist <= Settings.Melee_Parry_Radius)
            {
                // Verificar ángulo: Debe estar frente al jugador
                local toEnemy = ent.GetOrigin() - pos;
                toEnemy.Norm();
                if (fwd.Dot(toEnemy) > 0.5) // Cono frontal de 60 grados aprox
                {
                    PerformEnemyParry(who, ent, "charger");
                    continue;
                }
            }
        }

        // --- PARRY HUNTER EN VUELO (pounce) ---
        // El hunter saltando hacia ti es la "amenaza aerea": parrearlo corta el pounce
        if (cls == "player" && !ent.IsSurvivor() && ent.GetTeam() == 3
            && Settings.Parry_Hunter_Pounce == 1 && ent.GetZombieType() == 3)
        {
            if (IsPouncing(ent) && dist <= Settings.Hunter_Parry_Radius)
            {
                local toHunter = ent.GetOrigin() - pos;
                toHunter.Norm();
                if (fwd.Dot(toHunter) > 0.45)
                {
                    PerformEnemyParry(who, ent, "hunter");
                    continue;
                }
            }
        }

        // --- PARRY MELEE GENERAL (Hunter, Jockey, Smoker, Spitter, Boomer) ---
        if (cls == "player" && !ent.IsSurvivor() && ent.GetTeam() == 3 && Settings.Parry_Melee_Infected == 1)
        {
            // El charger en carga y el hunter en pounce los manejan sus casos especificos
            if (IsPlayerCharger(ent) && IsCharging(ent)) continue;
            if (Settings.Parry_Hunter_Pounce == 1 && ent.GetZombieType() == 3 && IsPouncing(ent)) continue;

            // Verificar si está vivo y no incapacitado
            if (ent.IsDead() || ent.IsIncapacitated() || ent.IsGhost()) continue;
            if (dist > Settings.Melee_Parry_Radius) continue;

            local toEnemy = ent.GetOrigin() - pos;
            toEnemy.Norm();
            // Debe estar muy cerca y en frente
            if (fwd.Dot(toEnemy) > 0.6)
            {
                PerformEnemyParry(who, ent, "common");
            }
        }

        // --- PARRY WITCH ---
        if (cls == "witch" && Settings.Parry_Witch == 1)
        {
            if (dist <= Settings.Melee_Parry_Radius)
            {
                local enraged = false;
                try { enraged = (NetProps.GetPropFloat(ent, "m_rage") > 0.5 || NetProps.GetPropInt(ent, "m_mobRush") == 1); } catch(e) {}
                if (enraged) // Si está enojada o corriendo
                {
                    local toEnemy = ent.GetOrigin() - pos;
                    toEnemy.Norm();
                    if (fwd.Dot(toEnemy) > 0.7)
                    {
                        PerformEnemyParry(who, ent, "witch");
                    }
                }
            }
        }
    }
}

function ChCh_Parrying::PerformEnemyParry(who, enemy, type)
{
    // v2.2 — durante la VENTANA cada enemigo se parrea 1 vez por segundo
    // (el shove instantaneo NO pasa por aqui: sigue sin cooldown)
    if (KnxState.enemyThrottle)
    {
        local now = Time()
        if (KnxEnemyCD.rawin(enemy) && now < KnxEnemyCD.rawget(enemy) + 1.0) return
        KnxEnemyCD.rawset(enemy, now)
    }

    // Efectos
    PlayParryEffects(who, enemy.GetOrigin() + Vector(0,0,40));

    // v2.3 (reporte owner): "ya el shove no producira stagger sobre el
    // objetivo y ya no producira daño desde lejos" — el parry de
    // enemigos es PURO EMPUJE FISICO: ni Stagger() ni TakeDamage().
    // El deflector manda al objetivo lejos de quien parrea; el stagger
    // y el daño son cosa del counter del manager (la postura), no del
    // parry.
    local push = enemy.GetOrigin() - who.GetOrigin()
    push.Norm()

    if (type == "charger")
    {
        // Detener la carga en seco y despedido de vuelta
        enemy.SetVelocity(Vector(0,0,0))
        enemy.SetVelocity(push.Scale(500) + Vector(0,0,250))
    }
    else if (type == "hunter")
    {
        // Parry aereo: la nueva velocidad corta el pounce y lo manda
        // volando de vuelta por donde vino
        enemy.SetVelocity(push.Scale(600) + Vector(0,0,300))
    }
    else if (type == "witch")
    {
        // La witch no es player: puro empuje (su vuelo/aterrizaje lo
        // lleva el WitchFlight del suite)
        enemy.SetVelocity(push.Scale(250) + Vector(0,0,150))
    }
    else
    {
        // Infectados normales / Especiales melee
        enemy.SetVelocity(push.Scale(400) + Vector(0,0,200))
    }

    // v2.3 — EFECTO ESPECIAL VS BOOMER (owner: "knuckles empujara al
    // boomer y cuando este toque el suelo despues de volar estallara
    // — tambien cuenta su ataque aereo"): al BOOMER se le pone la
    // MECHA — vuela (empuje reforzado) y ESTALLA AL TOCAR EL SUELO.
    // Nunca le explota encima a quien lo parreo.
    if (Settings.Knx_Boomer_Fuse == 1)
    {
        local isBoomer = false
        try { isBoomer = (enemy.GetClassname() == "player" && enemy.GetZombieType() == 2) } catch(e) {}
        if (isBoomer)
        {
            enemy.SetVelocity(push.Scale(500) + Vector(0,0,350))
            KnxBoomers.rawset(enemy, { air = false, until = Time() + 6.0, atk = who })
            try { ClientPrint(who, 4, "¡BOOMER FUERA! (estalla al aterrizar)") } catch(e) {}
        }
    }

    // v2.3 — SONIDO DEL BLOQUEO durante la ventana (fix del owner:
    // "cuando knuckles bloquea el salto de hunter jockey y smoker no
    // suena el sonido del bloqueo"): el parry de enemigos en ventana
    // ahora lleva el MISMO jugo sonoro que el de proyectiles (el SLAM
    // + hint). En el shove suelto no hace falta (ahi manda el smx).
    // Amy no: SU counter del manager ya suena solo.
    if (KnxState.enemyThrottle && !KnxIsAmy(who))
    {
        local msg = "¡ATAQUE DESVIADO!"
        if (type == "hunter") msg = "¡SALTO BLOQUEADO!"
        else if (type == "charger") msg = "¡CARGA DESVIADA!"
        else if (type == "witch") msg = "¡WITCH DESVIADA!"
        KnxWindowSound(who, msg)
    }
}


// -------------------------------------------------------------------
// Obtención de Proyectiles
// -------------------------------------------------------------------
function ChCh_Parrying::GetParriedEntsFrom(pos, who)
{
    local goodents = ["molotov_projectile","pipe_bomb_projectile","vomitjar_projectile","spitter_projectile","grenade_launcher_projectile","tank_rock"]
    local gottenents = []
    foreach(thing in goodents)
    {
        for (local ent; ent = Entities.FindByClassname(ent, thing); )
        {
            if (!ent.IsValid()) continue;
            local delta = ent.GetOrigin() - pos;
            local dist = delta.Length();
            if (dist > Settings.Parry_Radius) continue;
            // Precision: cono frontal + clausula de emergencia (Parry_Directional)
            if (!PassesConeFilter(who, delta, dist)) continue;
            gottenents.append(ent)
        }
    }
    return gottenents
}

function ChCh_Parrying::GetUniversalParriedEnts(pos, radius, who)
{
    local results = []
    local ent = null
    while (ent = Entities.FindInSphere(ent, pos, radius))
    {
        if (!ent.IsValid()) continue;
        if (ent.GetClassname() == "player") continue;

        local cls = ent.GetClassname().tolower()
        // Heurística ampliada
        if (cls.find("projectile") != null || cls.find("missile") != null || cls.find("spit") != null || cls.find("vomit") != null || cls.find("bomb") != null || cls.find("rocket") != null || cls == "tank_rock" || cls == "prop_physics")
        {
            local vel = ent.GetVelocity()
            if (vel.Length() > Settings.Universal_MinVelocity)
            {
                local exists = false;
                foreach (r in results) { if (r == ent) { exists = true; break } }
                if (!exists) results.append(ent)
            }
        }
    }
    // Filtro de precision aplicado al final (una sola pasada, con who disponible)
    local filtered = []
    foreach (u in results)
    {
        if (!u.IsValid()) continue;
        local delta = u.GetOrigin() - pos;
        local dist = delta.Length();
        if (!PassesConeFilter(who, delta, dist)) continue;

        // QoL: los props fisicos genericos solo son parreables si vienen HACIA el jugador
        // (evita "parrys" falsos a decoracion o props moviendose por su cuenta)
        if (u.GetClassname().tolower() == "prop_physics")
        {
            local toPlayer = pos - u.GetOrigin();
            local d = toPlayer.Length();
            if (d > 0.001)
            {
                toPlayer = toPlayer.Scale(1.0 / d);
                if (u.GetVelocity().Dot(toPlayer) < 100.0) continue;
            }
        }
        filtered.append(u)
    }
    return filtered
}

// -------------------------------------------------------------------
// Reflejo de Proyectiles
// -------------------------------------------------------------------
function ChCh_Parrying::ReflectEntity(ent, who)
{
    if (!ent || !ent.IsValid()) return

    local pos = ent.GetOrigin()
    local vel = ent.GetVelocity()
    local fwd = who.EyeAngles().Forward()

    ent.SetContext("ChCh_WasParried","1",-1)
    ent.SetContext("ChCh_ParriedAt", Time().tostring(), -1)
    NetProps.SetPropEntity(ent, "m_hThrower", who)

    local reflectVel
    if (Settings.Reflect_Use_Aim == 1)
    {
        // QoL/precision: el proyectil sale disparado hacia donde apuntas
        // (coherente con ParryGrenade; antes rebotaba especularmente hacia donde venia)
        local speed = max(vel.Length(), 900) * 1.5
        reflectVel = fwd.Scale(speed)
    }
    else
    {
        // Calculo vectorial del rebote (clasico)
        local dot = vel.Dot(fwd)
        reflectVel = vel - fwd.Scale(2 * dot)
        if (reflectVel.Length() < 300.0)
            reflectVel = fwd.Scale(max(vel.Length(), 900))
        reflectVel = reflectVel.Scale(1.5)
    }

    ent.SetVelocity(reflectVel)

    PlayParryEffects(who, pos)
}

function ChCh_Parrying::ParryGrenade(molly,who,pos,ang,speed)
{
    local mollyspeed = molly.GetVelocity()
    // QoL: piso de velocidad - el parry nunca devuelve la granada mas lenta de 900 uu/s
    local spd = mollyspeed.Length() * speed
    if (spd < 900.0) spd = 900.0

    NetProps.SetPropEntity(molly, "m_hThrower", who)
    molly.SetVelocity(ang.Forward().Scale(spd))
    molly.SetContext("ChCh_WasParried","1",-1)

    if (molly.GetClassname() == "tank_rock") {
        molly.SetContext("ChCh_ParriedAt", Time().tostring(), -1);
        molly.SetContext("ChCh_Exploded", "0", -1);
    }
    PlayParryEffects(who, molly.GetOrigin())
}

// -------------------------------------------------------------------
// FUNCION PRINCIPAL: Se ejecuta al empujar (shove)
// -------------------------------------------------------------------
function ChCh_Parrying::OleMateShoved(who,pos,ang)
{
    // 1. Parry de Proyectiles (esfera de deteccion + cono frontal)
    local gottenents = GetParriedEntsFrom(pos, who)

    if (Settings.Universal_Parry == 1)
    {
        local uni = GetUniversalParriedEnts(pos, Settings.Parry_Radius, who)
        foreach (u in uni) {
            local added = false;
            foreach (g in gottenents) { if (g == u) { added = true; break } }
            if (!added) gottenents.append(u)
        }
    }

    if(gottenents.len() > 0)
    {
        foreach(thing in gottenents)
        {
            if (!thing.IsValid()) continue;
            local cname = thing.GetClassname()

            switch(cname)
            {
                case "molotov_projectile":
                    if(Settings.Parry_Molotovs >= 1) ParryGrenade(thing,who,pos,ang,1);
                    break
                case "pipe_bomb_projectile":
                    if(Settings.Parry_Pipes >= 1) ParryGrenade(thing,who,pos,ang,1);
                    break
                case "vomitjar_projectile":
                    if(Settings.Parry_Bile >= 1) ParryGrenade(thing,who,pos,ang,2);
                    break
                case "spitter_projectile":
                    if(Settings.Parry_Spit >= 1) ParryGrenade(thing,who,pos,ang,1);
                    break
                case "grenade_launcher_projectile":
                    if(Settings.Parry_Grenade_launcher >= 1) ParryGrenade(thing,who,pos,ang,2);
                    break
                case "tank_rock":
                    if(Settings.Parry_Rocks >= 1) ParryGrenade(thing,who,pos,ang,1.5);
                    break
                default:
                    if (Settings.Universal_Parry == 1) ReflectEntity(thing, who);
                    break
            }
        }
    }

    // 2. Parry de Enemigos (Chargers, Hunters en vuelo, Witch, melee)
    CheckEnemyParry(who, pos, ang.Forward());
}

// -------------------------------------------------------------------
// Loop de Chequeo
// -------------------------------------------------------------------
function ChCh_Parrying::CheckParriedTankRocks()
{
    local now = Time();
    for (local rock; rock = Entities.FindByClassname(rock, "tank_rock"); )
    {
        if (!rock.IsValid()) continue;
        if (ResponseCriteria.GetValue(rock, "ChCh_WasParried") != "1") continue;
        if (ResponseCriteria.GetValue(rock, "ChCh_Exploded") == "1") continue;

        local parryTimeStr = ResponseCriteria.GetValue(rock, "ChCh_ParriedAt");
        local parryTime = (parryTimeStr != "") ? parryTimeStr.tofloat() : 0.0;
        local vel = rock.GetVelocity().Length();

        if (vel <= 100.0 || (parryTime > 0 && now >= parryTime + 5.0))
        {
            rock.SetContext("ChCh_Exploded", "1", -1);
            local thrower = NetProps.GetPropEntity(rock, "m_hThrower");
            SpawnExplosionAtFrom(thrower, rock.GetOrigin(), 250, 500);
            rock.Kill();
        }
    }
}

function ChCh_Parrying::CheckIfShoving()
{
    CheckParriedTankRocks();

    // v2.2 — la ventana de estado KNX (la abre el smx) escanea y parrea sola
    KnxWindowTick();

    // v2.3 — mechas de boomers: vuelan y ESTALLAN al tocar el suelo
    KnxBoomerTick();

    local player = null
    while(player = Entities.FindByClassname(player, "player"))
    {
        if(player.IsSurvivor() && !player.IsDead() && !player.IsIncapacitated() && !player.IsHangingFromLedge())
        {
            if(ShovingPlayerData.rawin(player))
            {
                local prevshove = ShovingPlayerData.rawget(player)
                local newshove = NetProps.GetPropFloat(player, "m_flNextShoveTime")
                ShovingPlayerData.rawset(player, newshove)

                // Detectar cambio en tiempo de shove (significa que el jugador presionó click derecho)
                if(newshove != prevshove)
                {
                    // QoL: centro de deteccion a la altura del pecho (antes a los pies):
                    // la esfera de parry queda centrada donde realmente vuelan los proyectiles
                    local center = player.GetOrigin() + Vector(0,0,48)
                    OleMateShoved(player, center, player.EyeAngles())
                }
            }
            else
            {
                ShovingPlayerData.rawset(player, NetProps.GetPropFloat(player, "m_flNextShoveTime"))
            }
        }
    }
}

// -------------------------------------------------------------------
// v2.2 — MODO ESTADO KNX: la ventana de parry que abre el smx
// -------------------------------------------------------------------
// El Parry.smx v2.1+ detecta el shove, hace su parry instantaneo y
// ADEMAS abre LA VENTANA: avisa a este script ("Knuckles esta en
// parry") por la API root ChCh_KnxNotify(idx, 1, segundos). Desde
// ese momento y hasta que se cumpla la duracion (o llegue la ORDEN
// DE APAGADO: ChCh_KnxNotify(idx, 0)), este loop escanea y parrea
// SOLO todo lo que le tiren, sin tocar el shove. Filtros de la
// ventana (SOLO aqui; el shove queda intacto):
//   - anti-robo: lo que ya es tuyo o de otro sobreviviente NO se toca
//   - solo lo que viene HACIA ti (receta Amy: >250 u/s y coseno 0.3)
//   - enemigos con cooldown de 1 s (sin ametralladora de staggers)
// -------------------------------------------------------------------
function ChCh_Parrying::KnxNotify(idx, on, dur)
{
    if (Settings.Knx_Window != 1) return false

    if (on != 1)
    {
        // LA ORDEN DE APAGADO
        if (KnxWindows.rawin(idx)) KnxWindows.rawdelete(idx)
        if (Settings.Knx_Debug) printl("[KNX] ventana CERRADA en ent " + idx)
        return true
    }

    local d = 0.0
    try { d = dur.tofloat() } catch(e) { d = 0.0 }
    if (d <= 0.0) d = Settings.Knx_Window_Max   // hasta la orden de apagado
    if (d > 3600.0) d = 3600.0

    KnxWindows.rawset(idx, { until = Time() + d })
    if (Settings.Knx_Debug) printl("[KNX] ventana ABIERTA en ent " + idx + " por " + d + " s")
    return true
}

// corre en cada tick del loop (30 Hz): una pasada por ventana abierta
function ChCh_Parrying::KnxWindowTick()
{
    if (Settings.Knx_Window != 1) return
    if (KnxWindows.len() == 0) return

    local now = Time()
    local expired = []

    foreach (idx, w in KnxWindows)
    {
        if (now >= w.until) { expired.append(idx); continue }

        local who = null
        try { who = EntIndexToHScript(idx) } catch(e) { who = null }
        if (who == null || !who.IsValid()) { expired.append(idx); continue }

        // la ventana muere sola si el jugador deja de ser valido
        if (!who.IsSurvivor() || who.IsDead() || who.IsIncapacitated() || who.IsHangingFromLedge())
        { expired.append(idx); continue }

        KnxWindowScan(who)
    }

    foreach (idx in expired) KnxWindows.rawdelete(idx)
}

// el escaner de la ventana: los mismos colectores del shove + los
// filtros propios de la ventana
function ChCh_Parrying::KnxWindowScan(who)
{
    local center = who.GetOrigin() + Vector(0,0,48)
    local ang = who.EyeAngles()

    local gottenents = GetParriedEntsFrom(center, who)
    if (Settings.Universal_Parry == 1)
    {
        local uni = GetUniversalParriedEnts(center, Settings.Parry_Radius, who)
        foreach (u in uni)
        {
            local added = false
            foreach (g in gottenents) { if (g == u) { added = true; break } }
            if (!added) gottenents.append(u)
        }
    }

    foreach (thing in gottenents)
    {
        if (!thing.IsValid()) continue
        if (KnxIsFriendly(thing, who)) continue
        if (Settings.Knx_Window_IncomingOnly == 1 && !KnxIsIncoming(thing, center)) continue

        local cname = thing.GetClassname()
        local did = true

        switch (cname)
        {
            case "molotov_projectile":
                if (Settings.Parry_Molotovs >= 1) ParryGrenade(thing, who, center, ang, 1); else did = false
                break
            case "pipe_bomb_projectile":
                if (Settings.Parry_Pipes >= 1) ParryGrenade(thing, who, center, ang, 1); else did = false
                break
            case "vomitjar_projectile":
                if (Settings.Parry_Bile >= 1) ParryGrenade(thing, who, center, ang, 2); else did = false
                break
            case "spitter_projectile":
                if (Settings.Parry_Spit >= 1) ParryGrenade(thing, who, center, ang, 1); else did = false
                break
            case "grenade_launcher_projectile":
                if (Settings.Parry_Grenade_launcher >= 1) ParryGrenade(thing, who, center, ang, 2); else did = false
                break
            case "tank_rock":
                if (Settings.Parry_Rocks >= 1) ParryGrenade(thing, who, center, ang, 1.5); else did = false
                break
            default:
                if (Settings.Universal_Parry == 1) ReflectEntity(thing, who)
                else did = false
                break
        }

        if (did)
        {
            KnxWindowFeedback(who, cname)

            // v2.3 — AMY: "si el proyectil esta en rango activara la
            // defensa de martillo (el ataque mas el aura)" — se avisa
            // al manager por la consola del servidor y SU sistema
            // suelta el martillazo 360 + el aura (consume la pose; el
            // flanco de bajada del PhaseThink cierra esta ventana al
            // tick siguiente)
            if (KnxIsAmy(who))
            {
                try { SendToServerConsole("amyparry_strike " + who.GetEntityIndex()) } catch(e) {}
            }
        }
    }

    // enemigos durante la ventana (con el cooldown de 1 s por enemigo)
    if (Settings.Knx_Window_Enemies == 1)
    {
        KnxState.enemyThrottle = true
        CheckEnemyParry(who, center, ang.Forward())
        KnxState.enemyThrottle = false
    }
}

// anti-robo: lo que ya es tuyo (parried) o lo tiro OTRO sobreviviente
// no se toca en la ventana (el shove sigue parreandolo como siempre)
function ChCh_Parrying::KnxIsFriendly(ent, who)
{
    try
    {
        local thrower = NetProps.GetPropEntity(ent, "m_hThrower")
        if (thrower == null) return false
        if (thrower == who) return true
        if (thrower.IsValid() && thrower.GetClassname() == "player" && thrower.IsSurvivor()) return true
    }
    catch(e) {}
    return false
}

// receta Amy: solo se agarra lo que esta en movimiento (mas de 250
// u/s) y viene HACIA el jugador (coseno > 0.3). Lo quieto y lo que se
// aleja pasa de largo
function ChCh_Parrying::KnxIsIncoming(ent, pos)
{
    local vel = ent.GetVelocity()
    if (vel.Length() < 250.0) return false

    local delta = pos - ent.GetOrigin()
    local d = delta.Length()
    if (d < 1.0) return true    // encima de ti y moviendose: se agarra

    return (vel.Dot(delta) / (vel.Length() * d)) >= 0.3
}

// v2.3 — EL BOOMER ESTALLA AL ATERRIZAR (efecto especial del owner):
// cada mecha viva espera a que el boomer DESPEGUE del suelo (los
// primeros frames sigue pegado) y entonces BOOM al tocar tierra otra
// vez — su muerte = explosion de bilis AHI, ya lejos de quien lo
// empujo. Si nunca despega (choco contra algo al ras) o se muere por
// otra via, la mecha muere sola sin estallar.
function ChCh_Parrying::KnxBoomerTick()
{
    if (KnxBoomers.len() == 0) return

    local now = Time()
    local done = []

    foreach (b, f in KnxBoomers)
    {
        if (!b.IsValid() || b.IsDead() || b.GetTeam() != 3)
        {
            done.append(b)
            continue
        }
        if (now >= f.until)
        {
            done.append(b)   // nunca despego / se demoro demasiado
            continue
        }

        local onGround = false
        try { onGround = (b.GetFlags() & 1) != 0 } catch(e) { done.append(b); continue }  // 1 = FL_ONGROUND

        if (!f.air)
        {
            if (!onGround) f.air = true
        }
        else if (onGround)
        {
            // ATERRIZO tras volar: estalla solo
            done.append(b)
            try { b.TakeDamage(9999, 128, f.atk) }
            catch(e) { try { b.TakeDamage(9999, 128, b) } catch(e2) {} }
        }
    }

    foreach (b in done) KnxBoomers.rawdelete(b)
}

// v2.3 — de quien es esta ventana? Amy (pose de defensa de la Z) o
// Knuckles (shove parry): el modelo lo dice (amy.mdl del suite).
// Amy lleva SU contador aparte (sonido/hints propios) y su parry de
// proyectiles dispara la DEFENSA DE MARTILLO en el manager.
function ChCh_Parrying::KnxIsAmy(who)
{
    local mdl = ""
    try { mdl = who.GetModelName().tolower() } catch(e) { return false }
    return (mdl.find("amy") != null)
}

// v2.3 — el jugo sonoro de la ventana parametrizado (CONTADOR APARTE:
// Amy suena con SU martillo; Knuckles con SU slam) — hint + sonido a
// volumen 10 via ambient_generic
function ChCh_Parrying::KnxWindowSound(who, msg)
{
    try { ClientPrint(who, 4, msg) } catch(e) {}

    local sndPath = KnxIsAmy(who) ? Settings.Amy_Window_Sound : Settings.Knx_Window_Sound
    if (sndPath == "") return
    try
    {
        local snd = SpawnEntityFromTable("ambient_generic", {
            origin = who.GetOrigin(),
            targetname = "knx_parry_snd",
            message = sndPath,
            health = 10,        // volumen 10 = EL MAXIMO
            spawnflags = 5      // 1 = suena en todas partes + 4 = no loopeado
        })
        if (snd)
        {
            EntFireByHandle(snd, "PlaySound", "", 0.0, null, null)
            EntFireByHandle(snd, "Kill", "", 1.0, null, null)
        }
    }
    catch(e) {}
}

// el jugo del parry de la ventana: hint + el sonido (KNX o AMY) a volumen 10
function ChCh_Parrying::KnxWindowFeedback(who, cname)
{
    local msg = "OBJETO DEVUELTO!"
    if (cname == "tank_rock") msg = "ROCA DEVUELTA!"
    else if (cname == "spitter_projectile") msg = "SALIVA DEVUELTA!"
    else if (cname == "molotov_projectile" || cname == "pipe_bomb_projectile"
             || cname == "vomitjar_projectile" || cname == "grenade_launcher_projectile") msg = "GRANADA DEVUELTA!"

    // v2.3: la ventana de Amy = su DEFENSA DE MARTILLO (el proyectil
    // activa el ataque + el aura en el manager)
    if (KnxIsAmy(who)) msg = "¡DEFENSA DE MARTILLO!"

    KnxWindowSound(who, msg)
}

// -------------------------------------------------------------------
// Utilidades de Explosión y Eventos
// -------------------------------------------------------------------
function ChCh_Parrying::GetGrenadeFrom(pos)
{
    local classes = ["molotov_projectile", "pipe_bomb_projectile", "vomitjar_projectile", "grenade_launcher_projectile"]
    foreach(cls in classes) {
        local ent = Entities.FindByClassnameWithin(null, cls, pos, 32)
        if (ent) return ent;
    }
    return null;
}

function ChCh_Parrying::SpawnExplosionAtFrom(who,at,rad,dam)
{
    local kaboom = SpawnEntityFromTable("env_explosion", {origin = at, spawnflags = 1, iMagnitude = 0, iRadiusOverride = rad, rendermode = 5})
    if(kaboom) {
        EmitSoundOn("ambient/explosions/explode_" + RandomInt(1,3) + ".wav", kaboom)
        EntFireByHandle(kaboom, "Explode", "", 0, who, who)
        EntFireByHandle(kaboom, "Kill", "", 0.1, null, null)
    }
    SpawnEntityFromTable("info_particle_system", { origin = at, effect_name = "weapon_grenadelauncher", start_active = 1, flag_as_weather = 0})

    // Daño manual
    local targets = ["prop_physics", "func_breakable", "player", "infected", "witch"]
    foreach(cls in targets) {
        for (local ent; ent = Entities.FindByClassnameWithin(ent, cls, at, rad); ) {
            if (!ent.IsValid()) continue;
            if (ent.GetClassname() == "player" && ent.IsSurvivor())
            {
                // QoL: por defecto las explosiones de parry ya no dañan a los supervivientes
                // (antes: 50 de FF a tus companeros por parar una roca cerca de ellos)
                if (Settings.Explosion_Hurt_Team == 1)
                    ent.TakeDamage(dam / 10, 64, who)
                continue;
            }
            ent.TakeDamage(dam, 64, who)
        }
    }
}

function ChCh_Parrying::SpawnFireAt(who,at)
{
    DropFire(at + Vector(0,0,5))
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "molotov_projectile", at, 64); ) {
        NetProps.SetPropEntity(ent, "m_hThrower", who)
    }
}

// v2.4 — EL LOOP ES AUTO-SUFICIENTE: revive el chch_parry_loop si
// falta (y solo si falta: el watchdog del smx lo llama cada 2 s — cero
// churn). Lo llaman: (a) la carga del archivo (bootstrap — cubre el
// load a mitad de ronda donde round_start ya paso), (b) cada
// round_start (heartbeat + revivir si la ronda anterior lo dejo
// muerto) y (c) el watchdog del Parry.smx v2.3 (::ChCh_EnsureLoop
// cada 2 s). Antes el loop SOLO nacia en round_start y una carga
// tardía lo dejaba muerto para siempre = ventana muerta = el bug de
// la roca. Imposible apilar: solo crea cuando hay CERO vivos.
function ChCh_Parrying::EnsureLoop()
{
    // heartbeat SIEMPRE (para el knx_parry_status del smx)
    try { Convars.SetValue("uk_parry_nut_beat", Time().tostring()) } catch(e) {}

    // ya hay UN loop vivo? no-op (el watchdog del smx llama esto cada
    // 2 s: solo reviva cuando falta — cero churn de entidades)
    local alive = 0
    local t = null
    while (t = Entities.FindByClassname(t, "logic_timer"))
    {
        if (t.GetName() == "chch_parry_loop") alive++
    }
    if (alive >= 1) return

    SpawnEntityFromTable("logic_timer", {targetname = "chch_parry_loop", RefireTime = 0.033, OnTimer = "!self,runscriptcode,DirectorScript.ChCh_Parrying.CheckIfShoving()"})
}

function ChCh_Parrying::OnGameEvent_round_start(params)
{
    PrecacheSound("ambient/explosions/explode_1.wav")
    PrecacheSound("ambient/explosions/explode_2.wav")
    PrecacheSound("ambient/explosions/explode_3.wav")
    local firstEnt = Entities.First()
    if(firstEnt) firstEnt.PrecacheScriptSound("weapons/golf_club/hit_world_01.wav")

    // v2.2 — sonido de la ventana + estado KNX limpio de la ronda anterior
    if (Settings.Knx_Window_Sound != "")
    {
        try { PrecacheSound(Settings.Knx_Window_Sound) } catch(e) {}
    }
    // v2.3 — el sonido de AMY (contador aparte; lo precachea tambien el
    // manager del suite) + el WAV real del impacto de parry (fix del
    // sonido fantasma del GolfClub) + mechas de boomers fuera
    if (Settings.Amy_Window_Sound != "")
    {
        try { PrecacheSound(Settings.Amy_Window_Sound) } catch(e) {}
    }
    try { PrecacheSound("weapons/golf_club/hit_world_01.wav") } catch(e) {}
    local boomDone = []
    foreach (k, v in KnxBoomers) boomDone.append(k)
    foreach (k in boomDone) KnxBoomers.rawdelete(k)
    local knxWin = []
    foreach (k, v in KnxWindows) knxWin.append(k)
    foreach (k in knxWin) KnxWindows.rawdelete(k)
    local knxCD = []
    foreach (k, v in KnxEnemyCD) knxCD.append(k)
    foreach (k in knxCD) KnxEnemyCD.rawdelete(k)

    // FIX: limpiar el estado de shove de la ronda anterior (evita "parrys fantasma"
    // al reciclarse los handles de jugadores entre rondas)
    local stale = []
    foreach (k, v in ShovingPlayerData) stale.append(k)
    foreach (k in stale) ShovingPlayerData.rawdelete(k)

    // v2.4: el loop lo garantiza EnsureLoop (heartbeat + revivir si
    // falta; compartido con el bootstrap de carga y el watchdog del
    // smx — antes solo existia aqui y un load a mitad de ronda dejaba
    // el script sin loop)
    EnsureLoop()
}

function ChCh_Parrying::OnGameEvent_hegrenade_detonate(params)
{
    if("x" in params && "y" in params && "z" in params && "userid" in params) {
        local pos = Vector(params.x,params.y,params.z)
        local type = GetGrenadeFrom(pos)
        if (type == null) return;
        local thrower = GetPlayerFromUserID(params.userid)

        if(type.GetClassname() == "molotov_projectile" && Settings.Molotov_Explode >= 1 && ResponseCriteria.GetValue(type, "ChCh_WasParried") == "1")
            SpawnExplosionAtFrom(thrower, pos, 150, 250)
        else if(type.GetClassname() == "pipe_bomb_projectile" && Settings.Pipe_Fire >= 1 && ResponseCriteria.GetValue(type, "ChCh_WasParried") == "1")
            SpawnFireAt(thrower, pos)
    }
}

function ChCh_Parrying::OnGameEvent_spit_burst(params)
{
    if("subject" in params && params.subject && Settings.Spit_Explode >= 1) {
        local subjectEnt = EntIndexToHScript(params.subject);
        if (subjectEnt && subjectEnt.IsValid()) {
            local spit = Entities.FindByClassnameWithin(null, "spitter_projectile", subjectEnt.GetOrigin(), 16)
            if(spit && spit.IsValid() && ResponseCriteria.GetValue(spit, "ChCh_WasParried") == "1")
                SpawnExplosionAtFrom(null, spit.GetOrigin(), 150, 250)
        }
    }
}

// -------------------------------------------------------------------
// v2.2 — API ROOT "MODO ESTADO": el smx (Parry.smx v2.1+) avisa por
// aqui cuando Knuckles ENTRA en parry y cuando SALE. Tambien usable
// a mano desde la consola del servidor (sin smx de por medio):
//     script ChCh_KnxNotify(1, 1, 2.0)   // abre 2 s en el jugador 1
//     script ChCh_KnxNotify(1, 0)        // LA ORDEN DE APAGADO
// -------------------------------------------------------------------
if (!("ChCh_KnxNotify" in getroottable()))
{
    ::ChCh_KnxNotify <- function(idx, on, dur = 0.0)
    {
        local root = getroottable()
        local P = null
        if ("ChCh_Parrying" in root) P = root.ChCh_Parrying
        else if ("DirectorScript" in root && "ChCh_Parrying" in root.DirectorScript) P = root.DirectorScript.ChCh_Parrying
        if (P == null) { ::print("[KNX] ChCh_KnxNotify: ChCh_Parrying no esta cargado\n"); return false }
        return P.KnxNotify(idx, on, dur)
    }
}

// v2.2 — handshake con Parry.smx v2.1+: el smx crea el convar
// uk_parry_knx_api y lo lee para saber que ESTE .nut esta vivo. Si
// el smx no esta o es viejo, esto es un no-op silencioso.
try { Convars.SetValue("uk_parry_knx_api", "1") } catch(e) {}

// v2.2 — el smx tambien carga este archivo (bootstrap, idempotente):
// si tu loader ya lo habia corrido, registrar los eventos DOS veces
// duplicaria hegrenade_detonate/spit_burst (explosiones dobles de lo
// parreado). Este guard lo evita.
if (!("ChCh_KnxEventsBound" in getroottable()))
{
    ::ChCh_KnxEventsBound <- true
    __CollectEventCallbacks(ChCh_Parrying, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
}
ChCh_Parrying.ParseSettings()

// v2.4 — ROOT HELPERS DEL WATCHDOG: el Parry.smx v2.3 los llama por
// RunScriptCode. ChCh_EnsureLoop revive el loop si algo lo mato
// (llama a ChCh_Parrying::EnsureLoop — idempotente) y actualiza el
// heartbeat. El guard de "in getroottable()" hace que recargar el
// archivo no duplique nada.
if (!("ChCh_EnsureLoop" in getroottable()))
{
    ::ChCh_EnsureLoop <- function()
    {
        local root = getroottable()
        local P = null
        if ("ChCh_Parrying" in root) P = root.ChCh_Parrying
        else if ("DirectorScript" in root && "ChCh_Parrying" in root.DirectorScript) P = root.DirectorScript.ChCh_Parrying
        if (P == null) return false
        try { P.EnsureLoop() } catch(e) { return false }
        return true
    }
}

// v2.4 — BOOTSTRAP AL CARGAR: el loop nace AQUI y ya no depende de
// que llegue un round_start (la firma del bug de la 3.77.38: .nut
// cargado a mitad de ronda = sin loop = ventana muerta = roca sin
// bloquear y sin sonido, mientras el smx confiaba en el handshake).
// round_start lo refresca; el watchdog del smx lo revive.
try { ChCh_Parrying.EnsureLoop() } catch(e) {}
