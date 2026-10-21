local EFFECT = {}

function EFFECT:Init(data)
    self.StartPos = data:GetStart()
    self.EndPos   = data:GetOrigin()

    self.LifeTime = 0.3
    self.DieTime = CurTime() + self.LifeTime

    self.StartWidth = 60
    self.EndWidth = 0

    self.Width = self.StartWidth
    self.Alpha = 255

    self.Mat = Material("sprites/physbeam")

    local dir = (self.EndPos - self.StartPos):GetNormalized()
    local ang = dir:Angle()

    local emitter = ParticleEmitter(self.EndPos)
    local radius = 5
    local count = 40

    for i = 1, count do
        local theta = (i / count) * math.pi * 2

        local offset = ang:Right() * math.cos(theta) * radius + ang:Up() * math.sin(theta) * radius

        local p = emitter:Add("particle/particle_smokegrenade1", self.StartPos + offset + dir * 5)
        if p then
            p:SetVelocity(offset:GetNormalized() * 30 + dir * 100)
            p:SetDieTime(0.8)
            p:SetStartAlpha(220)
            p:SetEndAlpha(0)
            p:SetStartSize(1)
            p:SetEndSize(45)
            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-1, 1))
            p:SetColor(20, 20, 20)
            p:SetAirResistance(200)
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
end

effects.Register(EFFECT, "fang_om_shoot")



local EFFECT = {}

local ringMat = Material("effects/select_ring")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin() + Vector(0,0,10)
    self.Normal = data:GetNormal()

    self.Size = math.Rand(90, 140)

    self.Life = 0
    self.MaxLife = 10

    self.Alpha = 255

    self.RingLife = 0
    self.RingMaxLife = 1

    self.RingStartSize = 20
    self.RingEndSize = 40
end

function EFFECT:Think()
    self.Life = self.Life + FrameTime()
    self.RingLife = self.RingLife + FrameTime()

    local fadeStart = self.MaxLife - 1
    local frac = 0

    if self.Life > fadeStart then
        frac = math.Clamp((self.Life - fadeStart) / 1, 0, 1)
    end

    self.Alpha = 255 * (1 - frac)

    return self.Life < self.MaxLife
end

function EFFECT:Render()
    local pos = self.Pos + self.Normal * -3

    local ang = self.Normal:Angle()
    ang:RotateAroundAxis(ang:Right(), -90)

    local ringFrac = math.Clamp(self.RingLife / self.RingMaxLife, 0, 1)

    if ringFrac < 1 then
        local ringSize = Lerp(
            ringFrac,
            self.RingStartSize,
            self.RingEndSize
        )

        local ringAlpha = 255 * (1 - ringFrac)

        render.SetMaterial(ringMat)

        render.DrawQuadEasy(
            pos,
            self.Normal,
            ringSize,
            ringSize,
            Color(80, 80, 80, ringAlpha),
            0
        )
    end
end


local EFFECT = {}

local ringMat = Material("effects/select_ring")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin() + Vector(0,0,10)
    self.Normal = data:GetNormal()

    self.Size = math.Rand(90, 140)

    self.Life = 0
    self.MaxLife = 10

    self.Alpha = 255

    self.RingLife = 0
    self.RingMaxLife = 1

    self.RingStartSize = 20
    self.RingEndSize = 200
end

function EFFECT:Think()
    self.Life = self.Life + FrameTime()
    self.RingLife = self.RingLife + FrameTime()

    local fadeStart = self.MaxLife - 1
    local frac = 0

    if self.Life > fadeStart then
        frac = math.Clamp((self.Life - fadeStart) / 1, 0, 1)
    end

    self.Alpha = 255 * (1 - frac)

    return self.Life < self.MaxLife
end

function EFFECT:Render()
    local pos = self.Pos + self.Normal * -3

    local ang = self.Normal:Angle()
    ang:RotateAroundAxis(ang:Right(), -90)

    local ringFrac = math.Clamp(self.RingLife / self.RingMaxLife, 0, 1)

    if ringFrac < 1 then
        local ringSize = Lerp(
            ringFrac,
            self.RingStartSize,
            self.RingEndSize
        )

        local ringAlpha = 255 * (1 - ringFrac)

        render.SetMaterial(ringMat)

        render.DrawQuadEasy(
            pos,
            self.Normal,
            ringSize,
            ringSize,
            Color(175, 175, 175, ringAlpha),
            0
        )
    end
end

effects.Register(EFFECT, "fang_bounce")






local EFFECT = {}

local beamMat = Material("models/noodles/om/Amy/white")
local starMat = Material("sprites/star")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()

    self.Lines = {}

    for i = 1, 12 do
        local offset = Vector(
            math.Rand(-24, 24),
            math.Rand(-24, 24),
            0
        )

        self.Lines[i] = {
            GroundPos = self.Pos + offset - Vector(0, 0, 20),
            Width = math.Rand(1, 2),
            Height = math.Rand(10, 26),
            Speed = math.Rand(18, 45),
            Drift = Vector(0, 0, 20),
            Delay = math.Rand(0, 0.15)
        }
    end

    self.StartTime = CurTime()
    self.DieTime = CurTime() + 0.6

    self:SetRenderBounds(
        Vector(-128, -128, -128),
        Vector(128, 128, 128)
    )
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local curTime = CurTime()

    render.SetMaterial(beamMat)

    for _, line in ipairs(self.Lines) do
        local time = math.max(curTime - self.StartTime - line.Delay, 0)
        local frac = math.Clamp(time / 0.45, 0, 1)

        if frac <= 0 then continue end

        local rise = frac * line.Speed
        local drift = line.Drift * frac

        local startPos = line.GroundPos + drift + Vector(0, 0, rise)

        local pulse

        if frac < 0.5 then
            pulse = frac * 2
        else
            pulse = 1 - ((frac - 0.5) * 2)
        end

        local currentHeight = line.Height * pulse
        local currentWidth = math.max(line.Width * pulse, 0.1)

        local endPos = startPos + Vector(0, 0, currentHeight)

        local alpha = 255 * (1 - frac)

        render.DrawBeam(
            startPos,
            endPos,
            currentWidth,
            0,
            1,
            Color(255, 255, 255, alpha)
        )
    end

    render.SetMaterial(starMat)
end

effects.Register(EFFECT, "white_rising_lines_fang")