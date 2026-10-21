printl("Ultrakill-like parrying v2.1 loaded: QoL & Precision Update (max fix)")
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
        EmitSoundOnClient("GolfClub.ImpactWorld", who)
        // QoL: ahora el impacto de parry tambien se oye en el mundo (los demas jugadores cerca lo perciben)
        EmitSoundOn("GolfClub.ImpactWorld", who)
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
    // Efectos
    PlayParryEffects(who, enemy.GetOrigin() + Vector(0,0,40));

    // Lógica específica
    if (type == "charger")
    {
        // Detener carga inmediatamente
        enemy.SetVelocity(Vector(0,0,0));
        // Aplicar Stagger (Aturdimiento) alejándolo del jugador
        try { enemy.Stagger(who.GetOrigin()); } catch(e) {}

        // Daño extra por parry perfecto
        enemy.TakeDamage(50, 128, who); // 128 = CLUB damage
    }
    else if (type == "hunter")
    {
        // Parry aereo: cortar el pounce y mandarlo volando de vuelta
        try { enemy.Stagger(who.GetOrigin()); } catch(e) {}
        local push = enemy.GetOrigin() - who.GetOrigin();
        push.Norm();
        enemy.SetVelocity(push.Scale(600) + Vector(0,0,300));
        enemy.TakeDamage(30, 128, who);
    }
    else if (type == "witch")
    {
        // Stagger a la witch (con fallback fisico: las witch no exponen Stagger() en VScript)
        local staggered = false;
        try { enemy.Stagger(who.GetOrigin()); staggered = true; } catch(e) {}
        if (!staggered)
        {
            local push = enemy.GetOrigin() - who.GetOrigin();
            push.Norm();
            enemy.SetVelocity(push.Scale(250) + Vector(0,0,150));
        }
        enemy.TakeDamage(25, 128, who);
    }
    else
    {
        // Infectados normales / Especiales melee
        try { enemy.Stagger(who.GetOrigin()); } catch(e) {}

        // Empuje físico extra (Knockback)
        local push = enemy.GetOrigin() - who.GetOrigin();
        push.Norm();
        enemy.SetVelocity(push.Scale(400) + Vector(0,0,200));
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

function ChCh_Parrying::OnGameEvent_round_start(params)
{
    PrecacheSound("ambient/explosions/explode_1.wav")
    PrecacheSound("ambient/explosions/explode_2.wav")
    PrecacheSound("ambient/explosions/explode_3.wav")
    local firstEnt = Entities.First()
    if(firstEnt) firstEnt.PrecacheScriptSound("GolfClub.ImpactWorld")

    // FIX: limpiar el estado de shove de la ronda anterior (evita "parrys fantasma"
    // al reciclarse los handles de jugadores entre rondas)
    local stale = []
    foreach (k, v in ShovingPlayerData) stale.append(k)
    foreach (k in stale) ShovingPlayerData.rawdelete(k)

    // FIX: eliminar el logic_timer de la ronda/mapa anterior antes de crear el nuevo.
    // Antes cada round_start apilaba un timer extra -> el loop corria N veces por tick
    // (shoves detectados varias veces = parrys duplicados y lag acumulado)
    local toKill = []
    local t = null
    while (t = Entities.FindByClassname(t, "logic_timer"))
    {
        if (t.GetName() == "chch_parry_loop") toKill.append(t)
    }
    foreach(k in toKill) k.Kill()

    SpawnEntityFromTable("logic_timer", {targetname = "chch_parry_loop", RefireTime = 0.033, OnTimer = "!self,runscriptcode,DirectorScript.ChCh_Parrying.CheckIfShoving()"})
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

__CollectEventCallbacks(ChCh_Parrying, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
ChCh_Parrying.ParseSettings()
