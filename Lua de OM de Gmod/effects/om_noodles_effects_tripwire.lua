local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Normal = data:GetNormal() or Vector(0, 0, 1)

    self.StartTime = CurTime()
    self.LifeTime = 0.75

    self.StartSize = 64
    self.BaseRadius = 20
    self.RadiusStep = 15 

    self.SpiralSpeed = 16 * 3
    self.HeightSpeed = 30

    self.Mat = Material("icons/particle that emits when laser is being prepared.png", "smooth")
end

function EFFECT:Think()
    return CurTime() < (self.StartTime + self.LifeTime)
end

function EFFECT:Render()
    local elapsed = CurTime() - self.StartTime
    local frac = math.Clamp(elapsed / self.LifeTime, 0, 1)

    local shrink = 1 - frac
    local alpha = 255 * shrink

    local ply = LocalPlayer()
    local ang = ply:EyeAngles()

    local forward = ang:Forward() * -1
    local right = ang:Right()
    local up = ang:Up()

    render.CullMode(MATERIAL_CULLMODE_NONE)
    render.SetMaterial(self.Mat)

    for i = 0, 3 do
        local startRadius = self.BaseRadius + (self.RadiusStep * i)
        local currentRadius = startRadius * shrink

        local theta = (elapsed * self.SpiralSpeed) + (i * math.pi / 2)

        local spiralOffset =
            right * math.cos(theta) * currentRadius +
            up    * math.sin(theta) * currentRadius +
            Vector(0, 0, elapsed * self.HeightSpeed * shrink)

        local roll = math.deg(theta)
        local currentSize = self.StartSize * shrink

        render.DrawQuadEasy(
            self.Pos + spiralOffset,
            forward,
            currentSize * 0.5,
            currentSize,
            Color(255, 255, 255, alpha),
            roll
        )
    end
    render.CullMode(MATERIAL_CULLMODE_CCW)
end

effects.Register(EFFECT, "Tripwire_emit_laserload")

local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Normal = data:GetNormal() or Vector(0, 0, 1)

    self.StartTime = CurTime()
    self.LifeTime = 0.5

    self.StartSize = 8
    self.EndSize = 96*3

    self.Mat1 = Material("icons/tripwirecircles.png", "smooth")
    self.Mat2 = Material("icons/tripwire_star.png", "smooth")
end

function EFFECT:Think()
    return CurTime() < (self.StartTime + self.LifeTime)
end

function EFFECT:Render()
    local elapsed = CurTime() - self.StartTime
    local frac = math.Clamp(elapsed / self.LifeTime, 0, 1)

    local fade = 1 - frac
    local alpha = 255 * fade

    local ply = LocalPlayer()
    local ang = ply:EyeAngles()
    local forward = ang:Forward() * -1

    render.CullMode(MATERIAL_CULLMODE_NONE)

    local function LerpSize(startSize, endSize, t)
        return startSize + (endSize - startSize) * t
    end

    local starSize = LerpSize(self.StartSize, self.EndSize * 1.5, frac)
    local starRoll = elapsed * 45

    render.SetMaterial(self.Mat2)
    render.DrawQuadEasy(
        self.Pos,
        forward,
        starSize,
        starSize,
        Color(255, 255, 255, alpha),
        starRoll
    )

    local circleSize = LerpSize(self.StartSize, self.EndSize*2, frac)

    render.SetMaterial(self.Mat1)

    render.DrawQuadEasy(
        self.Pos,
        forward,
        circleSize,
        circleSize,
        Color(255, 255, 255, alpha),
        0
    )

    render.DrawQuadEasy(
        self.Pos,
        ang:Forward() + ang:Up()*-2,
        circleSize * 0.9,
        circleSize * 0.9,
        Color(255, 255, 255, alpha * 0.8),
        0
    )
    render.CullMode(MATERIAL_CULLMODE_CCW)
end

effects.Register(EFFECT, "Tripwire_emit_laserstart")

local EFFECT = {}

local RADIUS = 60
local beamMat = Material("sprites/physbeam")

function EFFECT:Init(data)
    self.Ent = data:GetEntity()
    if not IsValid(self.Ent) then return end

    self.Emitter = ParticleEmitter(self.Ent:GetPos())

    self.Arcs = {}
    self.NextArc = 0
    self.NextEmit = 0
    self.NextSpark = 0
end

function EFFECT:Think()
    if not IsValid(self.Ent) then
        if self.Emitter then self.Emitter:Finish() end
        return false
    end

    local pos = self.Ent:GetPos()
    self.Emitter:SetPos(pos)

    local t = CurTime()

    if t >= self.NextEmit then
        self.NextEmit = t + 0.012

        for i = 1, 3 do
            local offset = VectorRand() * RADIUS

            local p = self.Emitter:Add("sprites/light_glow02_add", pos + offset)
            if p then
                p:SetDieTime(math.Rand(0.5, 0.9))
                p:SetStartSize(math.Rand(18, 30))
                p:SetEndSize(0)
                p:SetStartAlpha(220)
                p:SetEndAlpha(0)
                p:SetColor(255, 0, 0)
                p:SetVelocity(VectorRand() * 15)
                p:SetAirResistance(50)
                p:SetGravity(Vector(0, 0, 8))
            end
        end
    end

    if t >= self.NextArc then
        self.NextArc = t + math.Rand(0.03, 0.07)

        local start = pos + VectorRand() * RADIUS
        local finish = pos + VectorRand() * RADIUS

        table.insert(self.Arcs, {
            startPos = start,
            endPos = finish,
            dieTime = t + 0.08,
            jitter = VectorRand() * 3
        })
    end

    if t >= self.NextSpark then
        self.NextSpark = t + math.Rand(0.05, 0.1)

        for i = 1, 2 do
            local spawn = pos + VectorRand() * RADIUS
            local dir = VectorRand():GetNormalized()

            local p = self.Emitter:Add("sprites/light_glow02_add", spawn)
            if p then
                p:SetDieTime(math.Rand(0.2, 0.3))
                p:SetStartSize(math.Rand(7, 12))
                p:SetEndSize(0)
                p:SetStartAlpha(255)
                p:SetEndAlpha(0)
                p:SetColor(255, 0, 0)
                p:SetVelocity(dir * math.random(160, 320))
                p:SetAirResistance(35)
                p:SetGravity(Vector(0, 0, -25))
                p:SetBounce(0.6)
                p:SetCollide(true)
            end
        end
    end

    for i = #self.Arcs, 1, -1 do
        if self.Arcs[i].dieTime < t then
            table.remove(self.Arcs, i)
        end
    end

    return true
end

function EFFECT:Render()
    if not IsValid(self.Ent) then return end

    local t = CurTime()

    render.SetMaterial(beamMat)
    render.SuppressEngineLighting(true)
    render.FogMode(0)

    for _, arc in ipairs(self.Arcs) do
        local life = (arc.dieTime - t) / 0.08
        local alpha = math.Clamp(life * 255, 0, 255)

        local jitter = arc.jitter * (1 - life)

        local a = arc.startPos + jitter
        local b = arc.endPos - jitter

        render.DrawBeam(a, b, 16, 0, 1, Color(80, 0, 0, alpha * 0.5))

        render.DrawBeam(a, b, 8, 0, 1, Color(160, 0, 0, alpha))

        render.DrawBeam(a, b, 3, 0, 1, Color(255, 0, 0, alpha))
    end

    render.SuppressEngineLighting(false)
end

function EFFECT:OnRemove()
    if self.Emitter then
        self.Emitter:Finish()
    end
end

effects.Register(EFFECT, "tripwire_eletricity_linger")

local EFFECT = {}

function EFFECT:Init(data)
    local pos = data:GetOrigin()

    local emitter = ParticleEmitter(pos)
    if not emitter then return end

    for i = 1, 12 do
        local p = emitter:Add("effects/fire_cloud"..math.random(1,2), pos)
        if p then
            p:SetVelocity(VectorRand() * math.Rand(80, 200)*4)
            p:SetDieTime(math.Rand(0.2, 0.5))
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(40, 80))
            p:SetEndSize(0)
            p:SetRoll(math.Rand(0, 360))
            p:SetColor(255, math.random(120,180), 0)
            p:SetAirResistance(200)
        end
    end

    for i = 1, 18 do
        local p = emitter:Add("effects/energyball", pos)
        if p then
            p:SetVelocity(VectorRand() * math.Rand(150, 400)*4)
            p:SetDieTime(math.Rand(0.2, 0.6))
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(10, 25))
            p:SetEndSize(0)
            p:SetColor(255, math.random(140,200), 50)
            p:SetGravity(Vector(0, 0, -200))
        end
    end

    for i = 1, 25 do
        local p = emitter:Add("effects/spark", pos)
        if p then
            p:SetVelocity(VectorRand() * math.Rand(200, 600)*4)
            p:SetDieTime(math.Rand(0.3, 0.8))
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(4)
            p:SetEndSize(0)
            p:SetColor(255, 150, 50)
            p:SetGravity(Vector(0, 0, -600))
            p:SetCollide(true)
            p:SetBounce(0.6)
        end
    end

    emitter:Finish()

    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = 255
        dlight.g = 140
        dlight.b = 50
        dlight.brightness = 5
        dlight.Decay = 800
        dlight.Size = 300
        dlight.DieTime = CurTime() + 0.2
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "orange_plasma_explosion")


