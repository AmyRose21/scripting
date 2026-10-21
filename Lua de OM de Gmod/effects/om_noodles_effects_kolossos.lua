local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Life = 0
    self.MaxLife = 1

    local emitter = ParticleEmitter(self.Pos)

    for i = 1, 35 do
        local ang = math.rad(math.random(0, 360))
        local dir = Vector(math.cos(ang), math.sin(ang), 0)

        local p = emitter:Add("particle/particle_smokegrenade", self.Pos + dir * 5)
        if p then
            p:SetVelocity(dir * math.random(250, 450) + Vector(0,0,25))
            p:SetDieTime(1.1)
            p:SetStartAlpha(200)
            p:SetEndAlpha(0)
            p:SetStartSize(18)
            p:SetEndSize(48)
            p:SetColor(95, 95, 95)
            p:SetAirResistance(170)
            p:SetGravity(Vector(0, 0, 20))
        end
    end

    local dirtMats = {
        "effects/fleck_cement1",
        "effects/fleck_cement2",
        "effects/fleck_tile1",
        "effects/fleck_tile2",
    }

    for i = 1, 50 do
        local mat = dirtMats[math.random(#dirtMats)]
        local p = emitter:Add(mat, self.Pos + VectorRand() * 8)
        if p then
            p:SetVelocity(VectorRand() * math.random(220, 420) + Vector(0,0,180))
            p:SetDieTime(math.Rand(0.7, 1.6))
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(math.random(2,4))
            p:SetEndSize(0)
            p:SetColor(115, 95, 75)
            p:SetGravity(Vector(0,0,-800))
            p:SetBounce(0.45)
        end
    end

    for i = 1, 35 do
        local p = emitter:Add(dirtMats[math.random(#dirtMats)], self.Pos + VectorRand() * 6)
        if p then
            p:SetVelocity(VectorRand() * math.random(300, 600) + Vector(0,0,260))
            p:SetDieTime(math.Rand(0.9, 1.8))
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(math.random(4,6))
            p:SetEndSize(0)
            p:SetColor(105, 105, 105)
            p:SetGravity(Vector(0,0,-1000))
            p:SetBounce(0.55)
        end
    end

    local rockMats = {
        "effects/fleck_cement1",
        "effects/fleck_cement2",
        "effects/fleck_tile1",
        "effects/fleck_tile2",
    }

    for i = 1, 14 do
        local mat = rockMats[math.random(#rockMats)]
        local p = emitter:Add(mat, self.Pos + VectorRand() * 10)
        if p then
            p:SetVelocity(VectorRand() * math.random(280, 520) + Vector(0,0,320))
            p:SetDieTime(math.Rand(1.0, 2.0))
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(math.random(6, 12))
            p:SetEndSize(0)
            p:SetColor(120, 120, 120)
            p:SetGravity(Vector(0,0,-900))
            p:SetBounce(0.5)
        end
    end

    emitter:Finish()
end


function EFFECT:Think()
    self.Life = self.Life + FrameTime()
    return self.Life < self.MaxLife
end

function EFFECT:Render()
    local frac = self.Life / self.MaxLife
    local size = Lerp(frac, 40, 500)
    local alpha = Lerp(frac, 150, 0)

    render.SetMaterial(Material("sprites/physbeam"))
    render.DrawQuadEasy(self.Pos, Vector(0,0,1), size, size, Color(200,200,200,alpha), 0)
end

effects.Register(EFFECT, "kolossos_charging_step")

local EFFECT = {}
EFFECT.Mat = Material("icons/BLOOD DROP kolossos")

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local normal = data:GetNormal()
    local scale = data:GetScale() or 1

    if normal:Length() == 0 then
        normal = Vector(0,0,1)
    end

    local emitter = ParticleEmitter(pos)
    if not emitter then return end

    for i = 1, math.floor(math.random(25, 40) * scale) do
        local particle = emitter:Add(self.Mat, pos)
        if particle then
            local dir = (normal + VectorRand() * 0.2):GetNormalized()

            particle:SetVelocity(dir * math.random(400, 900) * scale)
            particle:SetDieTime(math.Rand(0.4, 1.0))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(4, 10) * scale)
            particle:SetEndSize(0)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-80, 80))

            particle:SetGravity(Vector(0, 0, -900))
            particle:SetColor(130, 0, 0)
            particle:SetAirResistance(30)
        end
    end

    for i = 1, math.floor(math.random(15, 25) * scale) do
        local particle = emitter:Add("particle/particle_smokegrenade", pos)
        if particle then
            local dir = (normal + VectorRand() * 0.8):GetNormalized()

            particle:SetVelocity(dir * math.random(100, 300))
            particle:SetDieTime(math.Rand(0.3, 0.7))
            particle:SetStartAlpha(80)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(5, 12))
            particle:SetEndSize(20)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-10, 10))

            particle:SetColor(150, 0, 0)
            particle:SetAirResistance(100)
        end
    end

    emitter:Finish()

    for i = 1, math.random(3, 6) do
        local offset = VectorRand() * 10
        util.Decal(
            "Blood",
            pos - normal + offset,
            pos + normal + offset
        )
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "kolossos_charging_blood")

local EFFECT = {}
EFFECT.Mat = Material("icons/BLOOD DROP kolossos")

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local normal = data:GetNormal()
    local scale = data:GetScale() or 1

    if normal:Length() == 0 then
        normal = Vector(0,0,1)
    end

    local emitter = ParticleEmitter(pos)
    if not emitter then return end

    for i = 1, math.random(6, 10) * scale do
        local particle = emitter:Add(self.Mat, pos + VectorRand() * 2)
        if particle then
            particle:SetVelocity(VectorRand() * 20 + Vector(0, 0, -80))
            particle:SetDieTime(math.Rand(1.2, 2.5))

            particle:SetStartAlpha(220)
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(4, 7) * scale)
            particle:SetEndSize(2)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-20, 20))

            particle:SetGravity(Vector(0, 0, -600))
            particle:SetAirResistance(5)
            particle:SetColor(120, 0, 0)
        end
    end

    for i = 1, math.random(3, 6) do
        local particle = emitter:Add(self.Mat, pos)
        if particle then
            particle:SetVelocity(VectorRand() * 10 + Vector(0, 0, -40))
            particle:SetDieTime(math.Rand(1.5, 3.0))

            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(6, 10))
            particle:SetEndSize(3)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-10, 10))

            particle:SetGravity(Vector(0, 0, -900))
            particle:SetAirResistance(2)
            particle:SetColor(100, 0, 0)
        end
    end

    for i = 1, math.random(5, 10) do
        local particle = emitter:Add("particle/particle_smokegrenade", pos)
        if particle then
            particle:SetVelocity(VectorRand() * 10 + Vector(0, 0, -30))
            particle:SetDieTime(math.Rand(0.4, 0.8))

            particle:SetStartAlpha(60)
            particle:SetEndAlpha(0)

            particle:SetStartSize(3)
            particle:SetEndSize(10)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-5, 5))

            particle:SetColor(120, 0, 0)
            particle:SetAirResistance(50)
        end
    end

    emitter:Finish()

    for i = 1, math.random(1, 3) do
        local offset = VectorRand() * 4
        util.Decal(
            "Blood",
            pos + offset,
            pos - Vector(0, 0, 10)
        )
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "kolossos_blood_drip")


local EFFECT = {}

EFFECT.Mat = Material("icons/kol impact better experimental")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Ang = EyeAngles()

    self.Copies = {}

    local count = 13
    local radius = 70

    for i = 1, count do
        local frac = (i - 1) / count
        local circleAng = math.rad(frac * 360)

        local offset = Vector(
            math.cos(circleAng),
            math.sin(circleAng),
            0
        )

        self.Copies[i] = {
            dir = offset,
            ang = frac * 360,

            startRadius = radius *0,
            endRadius = radius*1.3,

            startSizex = 10*0.65,
            endSizex = 150*0.65,
            startSizey = 10,
            endSizey = 250,

            lifeTime = math.Rand(0.4, 0.6),
            startTime = CurTime()
        }
    end

    self.DieTime = CurTime() + 2
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    render.SetMaterial(self.Mat)

    local eyeAng = EyeAngles()
    local forward = eyeAng:Forward() * -1

    for _, copy in ipairs(self.Copies) do
        local age = CurTime() - copy.startTime
        local frac = math.Clamp(age / copy.lifeTime, 0, 1)

        local eased = frac * frac

        local radius = Lerp(eased, copy.startRadius, copy.endRadius)

        local worldOffset = self.Ang:Up() * (copy.dir.x * radius) + self.Ang:Right() * (copy.dir.y * radius)

        local pos = self.Pos + worldOffset

        local sizex = Lerp(eased, copy.startSizex, copy.endSizex)
        local sizey = Lerp(eased, copy.startSizey, copy.endSizey)

        render.DrawQuadEasy(
            pos,
            forward,
            sizex,
            sizey,
            Color(255, 255, 255, 255 * (1 - eased)),
            eyeAng.x - copy.ang
        )
    end
end

effects.Register(EFFECT, "kolossos_impact_effect")