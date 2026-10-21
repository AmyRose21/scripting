local EFFECT = {}

local dropletMat = Material("sprites/sent_ball")
local splashMat = Material("particle/particle_smokegrenade")
local glowMat = Material("sprites/light_glow02_add")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()

    self.StartTime = CurTime()
    self.DieTime = CurTime() + 1.8

    local emitter = ParticleEmitter(self.Pos)

    for i = 1, 45 do
        local p = emitter:Add(dropletMat, self.Pos)
        if p then
            local dir = VectorRand()

            dir.z = math.abs(dir.z) * 0.6

            p:SetVelocity(dir * math.Rand(250, 700))

            p:SetDieTime(math.Rand(0.6, 1.4))

            p:SetStartAlpha(255)
            p:SetEndAlpha(0)

            p:SetStartSize(math.Rand(3, 7))
            p:SetEndSize(math.Rand(6, 14))

            p:SetGravity(Vector(0, 0, -600))

            p:SetAirResistance(80)

            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-6, 6))

            -- deep dark “ink” color
            local shade = math.Rand(5, 25)
            p:SetColor(shade, shade, shade)
        end
    end

    for i = 1, 18 do
        local p = emitter:Add(splashMat, self.Pos + VectorRand() * 5)
        if p then
            local dir = VectorRand()
            dir.z = math.abs(dir.z)

            p:SetVelocity(dir * math.Rand(120, 300))
            p:SetDieTime(math.Rand(0.8, 1.6))

            p:SetStartAlpha(120)
            p:SetEndAlpha(0)

            p:SetStartSize(math.Rand(10, 25))
            p:SetEndSize(math.Rand(30, 60))

            p:SetGravity(Vector(0, 0, -200))
            p:SetAirResistance(120)

            local shade = math.Rand(10, 40)
            p:SetColor(shade, shade, shade)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local t = (CurTime() - self.StartTime)
    local frac = math.Clamp(t / 0.6, 0, 1)

    local size = frac * 160
    local alpha = (1 - frac) * 140

    render.SetMaterial(glowMat)
    render.DrawSprite(
        self.Pos,
        size,
        size,
        Color(10, 10, 10, alpha)
    )

    render.SetMaterial(splashMat)

    local glowSize = size * 1.4
    render.DrawSprite(
        self.Pos,
        glowSize,
        glowSize,
        Color(0, 0, 0, alpha * 0.6)
    )
end

effects.Register(EFFECT, "end_createbubble")


local EFFECT = {}

local dropletMat = Material("sprites/sent_ball")
local splashMat = Material("particle/particle_smokegrenade")
local glowMat = Material("sprites/light_glow02_add")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()

    self.StartTime = CurTime()
    self.DieTime = CurTime() + 1.8

    local emitter = ParticleEmitter(self.Pos)

    for i = 1, 45 do
        local p = emitter:Add(dropletMat, self.Pos)
        if p then
            local dir = VectorRand()

            dir.z = math.abs(dir.z) * 0.6

            p:SetVelocity(dir * math.Rand(250, 700))

            p:SetDieTime(math.Rand(0.6, 1.4))

            p:SetStartAlpha(255)
            p:SetEndAlpha(0)

            p:SetStartSize(math.Rand(3, 7))
            p:SetEndSize(math.Rand(6, 14))

            p:SetGravity(Vector(0, 0, -600))

            p:SetAirResistance(80)

            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-6, 6))

            -- deep dark “ink” color
            local shade = math.Rand(5, 25)
            p:SetColor(shade, shade, shade)
        end
    end

    for i = 1, 18 do
        local p = emitter:Add(splashMat, self.Pos + VectorRand() * 5)
        if p then
            local dir = VectorRand()
            dir.z = math.abs(dir.z)

            p:SetVelocity(dir * math.Rand(120, 300))
            p:SetDieTime(math.Rand(0.8, 1.6))

            p:SetStartAlpha(120)
            p:SetEndAlpha(0)

            p:SetStartSize(math.Rand(10, 25))
            p:SetEndSize(math.Rand(30, 60))

            p:SetGravity(Vector(0, 0, -200))
            p:SetAirResistance(120)

            local shade = math.Rand(10, 40)
            p:SetColor(shade, shade, shade)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local t = (CurTime() - self.StartTime)
    local frac = math.Clamp(t / 0.6, 0, 1)

    local size = frac * 160
    local alpha = (1 - frac) * 140

    render.SetMaterial(glowMat)
    render.DrawSprite(
        self.Pos,
        size,
        size,
        Color(10, 10, 10, alpha)
    )

    render.SetMaterial(splashMat)

    local glowSize = size * 1.4
    render.DrawSprite(
        self.Pos,
        glowSize,
        glowSize,
        Color(0, 0, 0, alpha * 0.6)
    )
end

effects.Register(EFFECT, "bubble_pop_end")