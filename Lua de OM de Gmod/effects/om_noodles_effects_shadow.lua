local EFFECT = {}

function EFFECT:Init(data)
    self.StartPos = data:GetStart()
    self.EndPos   = data:GetOrigin()

    self.LifeTime = 0.2
    self.DieTime = CurTime() + self.LifeTime

    self.StartWidth = 40
    self.EndWidth = 0

    self.Width = self.StartWidth
    self.Alpha = 255

    self.Mat = Material("sprites/physbeam")

    local dir = (self.EndPos - self.StartPos):GetNormalized()
    local ang = dir:Angle()

    local emitter = ParticleEmitter(self.EndPos)
    local radius = 25
    local count = 16

    for i = 1, count do
        local theta = (i / count) * math.pi * 2

        local offset = ang:Right() * math.cos(theta) * radius +  ang:Up() * math.sin(theta) * radius

        local p = emitter:Add("particle/particle_smokegrenade1", self.StartPos + offset + dir * 5)
        if p then
            p:SetVelocity(offset:GetNormalized() * 60 + dir * 180)

            p:SetDieTime(0.4)

            p:SetStartAlpha(180)
            p:SetEndAlpha(0)

            p:SetStartSize(10)
            p:SetEndSize(25)

            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-2, 2))

            p:SetColor(255, 135, 0)
            p:SetAirResistance(100)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    if CurTime() > self.DieTime then return false end

    local frac = (self.DieTime - CurTime()) / self.LifeTime

    self.Width = Lerp(frac, self.EndWidth, self.StartWidth)
    self.Alpha = math.floor(255 * frac)

    return true
end

function EFFECT:Render()
    render.SetMaterial(self.Mat)

    local width = self.Width or 0

    render.DrawBeam(
        self.StartPos,
        self.EndPos,
        width,
        0,
        0,
        Color(255, 135, 0, self.Alpha)
    )
end

effects.Register(EFFECT, "shadow_shoot_beam")

local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.DieTime = CurTime() + 0.65
    self.LifeTime = 0.65

    self.Mat = Material("icons/shadow_chaos_snap_hit_1")

    self.Size = 128
    self.TargetSize = 128
    self.Alpha = 125
    self.TargetAlpha = 125
end

function EFFECT:Think()
    local remaining = self.DieTime - CurTime()
    local t = math.Clamp(remaining / self.LifeTime, 0, 1)

    self.TargetSize = 128 * t
    self.TargetAlpha = 125 * t

    local ft = FrameTime() * 15
    self.Size = Lerp(ft, self.Size, self.TargetSize)
    self.Alpha = Lerp(ft, self.Alpha, self.TargetAlpha)

    return CurTime() < self.DieTime
end

function EFFECT:Render()
    if self.Size <= 0.5 then return end

    render.SetMaterial(self.Mat)
    render.DrawSprite(
        self.Pos,
        self.Size,
        self.Size,
        Color(255, 255, 255, self.Alpha)
    )
end

effects.Register(EFFECT, "shadow_chaossnap_charge")

local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.DieTime = CurTime() + 0.96
    self.LifeTime = 0.96

    self.Mat = Material("effects/strider_pinch_dudv")

    self.Size = 180
    self.TargetSize = 180

    self.Alpha = 255
    self.TargetAlpha = 255

    self.NoiseSeed = math.Rand(0, 1000)
end

function EFFECT:Think()
    local remaining = self.DieTime - CurTime()
    local t = math.Clamp(remaining / self.LifeTime, 0, 1)

    self.TargetSize = 180 * t
    self.TargetAlpha = 180 * t

    local wobble = math.sin(CurTime() * 25 + self.NoiseSeed) * 8
    self.TargetSize = self.TargetSize + wobble

    local ft = FrameTime() * 18
    self.Size = Lerp(ft, self.Size, self.TargetSize)
    self.Alpha = Lerp(ft, self.Alpha, self.TargetAlpha)

    return CurTime() < self.DieTime
end

function EFFECT:Render()
    if self.Size <= 0.5 then return end

    render.SetMaterial(self.Mat)

    render.DrawSprite(
        self.Pos,
        self.Size,
        self.Size,
        Color(255, 255, 255, self.Alpha)
    )
end

effects.Register(EFFECT, "shadow_chaossnap_charge_warping")

local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.DieTime = CurTime() + 0.4
    self.LifeTime = 0.4

    self.Mat = Material("icons/Shadow_chaos_snap_appear")

    self.StartSize = 5
    self.PeakSize = 175

    self.Size = self.StartSize

    self.Alpha = 255
end

function EFFECT:Think()
    local remaining = self.DieTime - CurTime()
    local t = math.Clamp(1 - (remaining / self.LifeTime), 0, 1)

    local eased = 1 - (1 - t) * (1 - t)

    local sizeTarget = Lerp(eased, self.StartSize, self.PeakSize)

    local fadeStart = 0.4
    local alpha = 1

    if t > fadeStart then
        alpha = 1 - ((t - fadeStart) / (1 - fadeStart))
    end

    alpha = math.Clamp(alpha, 0, 1)

    self.TargetSize = sizeTarget
    self.TargetAlpha = 255 * alpha

    local ft = FrameTime() * 18
    self.Size = Lerp(ft, self.Size, self.TargetSize)
    self.Alpha = Lerp(ft, self.Alpha, self.TargetAlpha)

    return CurTime() < self.DieTime
end

function EFFECT:Render()
    if self.Size <= 0.5 then return end

    render.SetMaterial(self.Mat)
    render.DrawSprite(
        self.Pos,
        self.Size,
        self.Size,
        Color(255, 255, 255, self.Alpha)
    )
end

effects.Register(EFFECT, "shadow_chaossnap_hit")