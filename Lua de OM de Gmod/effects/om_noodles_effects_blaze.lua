local EFFECT = {}

local mat = Material("icons/blaze's flame spiral.png", "smooth additive")

function EFFECT:Init(data)
    self.Ent = data:GetEntity()

    self.Pos = data:GetOrigin()
    self.Direction = self.Ent:GetNW2Vector("direction_blaze")--data:GetNormal():GetNormalized()
    self.Distance = data:GetMagnitude() * 0.85
    self.Angle = data:GetScale()

    if IsValid(self.Ent) then
        self.Offset = self.Pos - self.Ent:GetPos()
    else
        self.Offset = vector_origin
    end

    self.SpiralLife = 0.75
    self.StartTime = CurTime()
    self.DieTime = CurTime() + self.SpiralLife

    self.Roll = math.Rand(0, 360)

    self.Emitter = ParticleEmitter(self.Pos)

    for i = 1, 12 do
        local p = self.Emitter:Add("particles/flamelet"..math.random(1,5), self.Pos-self.Direction*5)
        if p then
            p:SetVelocity(VectorRand() * 30 + Vector(0,0,40))
            p:SetDieTime(math.Rand(0.3, 0.6)*0.25)
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(6, 12))
            p:SetEndSize(0)
            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-2, 2))
            p:SetColor(255, 120, 40)
            p:SetAirResistance(60)
            p:SetGravity(Vector(0, 0, 80))
        end
    end

    self.Emitter:Finish()
end

function EFFECT:Think()
    if CurTime() > self.DieTime then
        return false
    end
    if IsValid(self.Ent) then
        self.Direction = self.Ent:GetNW2Vector("direction_blaze")
    end

    return true
end

function EFFECT:Render()
    local frac = math.TimeFraction(
        self.StartTime,
        self.DieTime,
        CurTime()
    )

    local radius = math.tan(math.rad(self.Angle)) * self.Distance

    local basePos
    if IsValid(self.Ent) then
        basePos = self.Ent:GetPos() + self.Offset
    else
        basePos = self.Pos
    end

    local forward = self.Direction
    local pos = basePos + forward * self.Distance * frac

    self.Roll = self.Roll + FrameTime() * 40

    render.SetMaterial(mat)
    render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_ADD)

    local camPos = EyePos()
    local lifeAlpha = (1 - frac)

    local maxAngle = math.rad(60)

    for i = 1, 3 do
        local layerFrac = i / 3

        local depthOffset = forward * (i - 2) * 6

        local side = forward:Angle():Right()
        local up = forward:Angle():Up()

        local swirlOffset =
            side * math.sin(self.Roll * 0.05 + i) * 2 +
            up * math.cos(self.Roll * 0.05 + i) * 2

        local layerPos = pos + depthOffset + swirlOffset

        local toCam = (camPos - layerPos):GetNormalized()
        local baseDir = forward

        local dot = math.Clamp(baseDir:Dot(toCam), -1, 1)
        local angle = math.acos(dot)

        local faceDir = baseDir

        if angle > 0 then
            if angle > maxAngle then
                local t = maxAngle / angle
                faceDir = LerpVector(t, baseDir, toCam):GetNormalized()
            else
                faceDir = toCam
            end
        end

        local size = Lerp(frac, radius * (0.08 + layerFrac * 0.05), radius * (0.9 - layerFrac * 0.15))
        local alpha = lifeAlpha * (0.6 + (1 - layerFrac) * 0.4)

        local col = Color(255, 255, 255, 255 * alpha)

        render.DrawQuadEasy(
            layerPos,
            faceDir,
            size,
            size,
            col,
            self.Roll + i * 15
        )

        render.DrawQuadEasy(
            layerPos,
            -faceDir,
            size,
            size,
            col,
            -self.Roll - i * 15
        )
    end

    render.OverrideBlend(false)
end

effects.Register(EFFECT, "ExpellSolFlame_blaze")

local EFFECT = {}

function EFFECT:Init(data)
    self.Ent = data:GetEntity()

    self.Pos = data:GetOrigin()
    self.Direction = data:GetNormal():GetNormalized()
    self.Distance = data:GetMagnitude() * 0.85

    self.Emitter = ParticleEmitter(self.Pos)

    for i = 1, 12 do
        local p = self.Emitter:Add("particles/flamelet"..math.random(1,5), self.Pos-self.Direction*15)
        if p then
            p:SetVelocity(VectorRand() * 30 + Vector(0,0,40))
            p:SetDieTime(math.Rand(0.3, 0.6)*0.175)
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(6, 12))
            p:SetEndSize(0)
            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-2, 2))
            p:SetColor(255, 120, 40)
            p:SetAirResistance(60)
            p:SetGravity(Vector(0, 0, 80))
        end
    end

    self.Emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "ExpellSolFlame_blaze_fire")

local EFFECT = {}

function EFFECT:Init(data)
    self.Ent = data:GetEntity()
    self.Direction = data:GetNormal()
    self.Distance = data:GetMagnitude()
    self.Angle = data:GetScale()

    self.LifeTime = 0.25
    self.DieTime = CurTime() + self.LifeTime

    self.Emitter = ParticleEmitter(Vector(0,0,0))

    self.SpiralSpawned = false
    self.SpiralLife = 0.75

    local entVel = self.Ent:GetVelocity()
    local origin = self.Ent:GetPos() + Vector(0,0,50)

    local camAng = render.GetViewSetup().angles

    local right = camAng:Right()
    local up = camAng:Up()

    for i = 1, 20 do

        local x = math.Rand(-1, 1)
        local y = math.Rand(-1, 1)

        local finalDir = (right * x + up * y):GetNormalized()

        local image = "icons/blaze flame"

        local particle = self.Emitter:Add(image, origin)

        if particle then
            local flameVel = finalDir * math.Rand(self.Distance * 0.4, self.Distance)

            particle:SetVelocity(flameVel + entVel)

            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.3, 0.6) * 2)

            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(10, 18) * 2)
            particle:SetEndSize(0)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))

            if math.random(1,2) == 1 then
                particle:SetColor(0,0,0)
            else
                particle:SetColor(255,255,255)
            end

            particle:SetGravity(Vector(0,0,0))
            particle:SetAirResistance(50)
        end
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "ExpellSolFlame_blaze_impact_kick")



local EFFECT = {}

EFFECT.Mat = Material("icons/knuckles_punch")


function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Ang = EyeAngles()

    self.StartTime = CurTime()

    self.Copies = {}

    local count = 12
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

            startRadius = radius * -0,
            endRadius = radius * 1.4,

            startSizex = 20,
            startSizey = 35,
            endSizex = 20,
            endSizey = 35,

            startangle = 180 + 45*0.1,
            endangle = 180 + 45*0.1,

            lifeTime = 0.8,
            startTime = CurTime(),
            color = Color(255,0,0)
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

        local worldOffset =
            self.Ang:Up() * (copy.dir.x * radius) +
            self.Ang:Right() * (copy.dir.y * radius)

        local pos = self.Pos + worldOffset

        local sizex = Lerp(eased, copy.startSizex, copy.endSizex)
        local sizey = Lerp(eased, copy.startSizey, copy.endSizey)
        local RotationOffset = Lerp(eased, copy.startangle, copy.endangle)

        render.DrawQuadEasy(
            pos,
            forward,
            sizex,
            sizey,
            Color(copy.color.r, copy.color.g, copy.color.b, 255 * (1 - eased)),
            -copy.ang + RotationOffset
        )
    end
end

effects.Register(EFFECT, "blaze_kick_punch_OM")









local EFFECT = {}

function EFFECT:Init(data)
    self.Ent = data:GetEntity()
    self.Direction = data:GetNormal()
    self.Distance = data:GetMagnitude()
    self.Angle = data:GetScale()

    self.LifeTime = 0.25
    self.DieTime = CurTime() + self.LifeTime

    self.Emitter = ParticleEmitter(Vector(0,0,0))

    self.SpiralSpawned = false
    self.SpiralLife = 0.75

    local entVel = self.Ent:GetVelocity()
    local origin = self.Ent:GetPos() + Vector(0,0,50)

    for i = 1, 20 do
        local dir = self.Direction:Angle()

        dir:RotateAroundAxis(dir:Right(), math.Rand(-self.Angle, self.Angle))
        dir:RotateAroundAxis(dir:Up(), math.Rand(-self.Angle, self.Angle))

        local finalDir = dir:Forward()

        local image = "icons/blaze flame.png"
        if math.random(1,2) == 1 then
            image = "icons/blaze flame red.png"
        end

        local particle = self.Emitter:Add(image, origin)

        if particle then
            local flameVel = finalDir * math.Rand(self.Distance * 0.4, self.Distance* 1)

            particle:SetVelocity(flameVel + entVel)

            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.3, 0.6)*2)

            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(10, 18)*2)
            particle:SetEndSize(0)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))

            particle:SetColor(255, 255, 255)
            particle:SetGravity(Vector(0,0,0))
            particle:SetAirResistance(50)
        end
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "ExpellSolFlame_blaze_impact")

local EFFECT = {}

function EFFECT:Init(data)
    self.Ent = data:GetEntity()
    self.Direction = data:GetNormal()
    self.Distance = data:GetMagnitude()
    self.Angle = data:GetScale()

    self.LifeTime = 0.25
    self.DieTime = CurTime() + self.LifeTime

    self.Emitter = ParticleEmitter(Vector(0,0,0))


end

function EFFECT:Think()
    if not IsValid(self.Ent) then return false end

    if CurTime() > self.DieTime then
        if self.Emitter then
            self.Emitter:Finish()
        end
        return false
    end

    local entVel = self.Ent:GetVelocity()
    local origin = self.Ent:GetPos()+self.Ent:GetForward()*30+self.Ent:GetUp()*15

    for i = 1, 5 do
        local dir = self.Direction:Angle()

        dir:RotateAroundAxis(dir:Right(), math.Rand(-self.Angle, self.Angle))
        dir:RotateAroundAxis(dir:Up(), math.Rand(-self.Angle, self.Angle))

        local finalDir = dir:Forward()

        local image = "icons/lil' flame.png"

        local particle = self.Emitter:Add(image, origin)

        if particle then
            local flameVel = finalDir * math.Rand(self.Distance * 0.4, self.Distance* 0.9)

            particle:SetVelocity(flameVel + entVel)

            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.3, 0.6))

            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(10, 18))
            particle:SetEndSize(0)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))

            particle:SetColor(255, 255, 255)
            particle:SetGravity(Vector(0,0,0))
            particle:SetAirResistance(200)
        end
    end

    return true
end

function EFFECT:Render()
end

effects.Register(EFFECT, "SolDash_blaze_om")


local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Life = 1
    self.DieTime = CurTime() + self.Life

    self.StartSize = 5
    self.EndSize = 300

    self.Speed = 2

    self.Mat1 = Material("icons/blaze bubble.png", "smooth")
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = 1 - ((self.DieTime - CurTime()) / self.Life)
    frac = math.Clamp(frac * self.Speed, 0, 1)

    local size = Lerp(frac, self.StartSize, self.EndSize)

    local fadeStart = 0.65
    local fadeFrac = 0

    if frac > fadeStart then
        fadeFrac = (frac - fadeStart) / (1 - fadeStart)
    end

    local alpha = 255 * (1 - fadeFrac)

    render.SetMaterial(self.Mat1)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "SolDash_charge_blaze_om")

local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Life = 0.6
    self.DieTime = CurTime() + self.Life

    self.StartSize = 300
    self.EndSize = 5

    self.Speed = 2

    self.Mat1 = Material("icons/blaze bubble.png", "smooth")
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = 1 - ((self.DieTime - CurTime()) / self.Life)
    frac = math.Clamp(frac * self.Speed, 0, 1)

    local size = Lerp(frac, self.StartSize, self.EndSize)

    local fadeStart = 0.65
    local fadeFrac = 0

    if frac > fadeStart then
        fadeFrac = (frac - fadeStart) / (1 - fadeStart)
    end

    local alpha = 255 * (1 - fadeFrac)

    render.SetMaterial(self.Mat1)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "SolDash_decrease_charge_blaze_om")

local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Life = 1
    self.DieTime = CurTime() + self.Life

    self.StartSize = 5
    self.EndSize = 300

    self.Speed = 2

    self.Mat1 = Material("icons/blaze sol boost star.png", "smooth")
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = 1 - ((self.DieTime - CurTime()) / self.Life)
    frac = math.Clamp(frac * self.Speed, 0, 1)

    local size = Lerp(frac, self.StartSize, self.EndSize)

    local fadeStart = 0.65
    local fadeFrac = 0

    if frac > fadeStart then
        fadeFrac = (frac - fadeStart) / (1 - fadeStart)
    end

    local alpha = 255 * (1 - fadeFrac)

    render.SetMaterial(self.Mat1)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "SolDash_solbooststart_blaze_om")


local EFFECT = {}

function EFFECT:Init(data)
    self.Ent = data:GetEntity()
    self.Pos = data:GetOrigin()

    self.Life = 0.85
    self.DieTime = CurTime() + self.Life

    self.StartSize = 5
    self.EndSize = 300
    self.Speed = 2

    self.Mat1 = Material("icons/blaze bubble.png", "smooth")

    if IsValid(self.Ent) then
        self.Offset = self.Pos - self.Ent:GetPos()
    else
        self.Offset = vector_origin
    end
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = 1 - ((self.DieTime - CurTime()) / self.Life)
    frac = math.Clamp(frac * self.Speed, 0, 1)

    local size = Lerp(frac, self.StartSize, self.EndSize)

    local fadeStart = 0.65
    local fadeFrac = 0

    if frac > fadeStart then
        fadeFrac = (frac - fadeStart) / (1 - fadeStart)
    end

    local alpha = 255 * (1 - fadeFrac)

    local pos
    if IsValid(self.Ent) then
        pos = self.Ent:GetPos() + self.Offset
    else
        pos = self.Pos
    end

    render.SetMaterial(self.Mat1)
    render.DrawSprite(pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "SolFlame_expell_blaze_om")


local EFFECT = {}

function EFFECT:Init(data)
    self.Ent = data:GetEntity()
    self.Pos = data:GetOrigin()

    self.Life = 0.85
    self.DieTime = CurTime() + self.Life

    self.StartSize = 300
    self.EndSize = 5
    self.Speed = 2

    self.Mat1 = Material("icons/blaze bubble.png", "smooth")

    if IsValid(self.Ent) then
        self.Offset = self.Pos - self.Ent:GetPos()
    else
        self.Offset = vector_origin
    end
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = 1 - ((self.DieTime - CurTime()) / self.Life)
    frac = math.Clamp(frac * self.Speed, 0, 1)

    local size = Lerp(frac, self.StartSize, self.EndSize)

    local fadeStart = 0.65
    local fadeFrac = 0

    if frac > fadeStart then
        fadeFrac = (frac - fadeStart) / (1 - fadeStart)
    end

    local alpha = 255 * (1 - fadeFrac)

    local pos
    if IsValid(self.Ent) then
        pos = self.Ent:GetPos() + self.Offset
    else
        pos = self.Pos
    end

    render.SetMaterial(self.Mat1)
    render.DrawSprite(pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "SolFlame_chargeup_blaze_om")
