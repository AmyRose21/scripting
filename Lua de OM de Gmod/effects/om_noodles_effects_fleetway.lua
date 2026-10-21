-- Chaos Dash


local textures = {
    "icons/fleetway_chaos_dash_stars"
}

local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Particles = {}

    if math.random(1,4) == 1 then
        local tex = textures[math.random(#textures)]
        table.insert(self.Particles, {
            Pos = self.Pos + VectorRand() * 18,
            Size = math.random(8, 12),
            Rotation = math.random(0, 360),
            Lifetime = CurTime() + math.Rand(0.5, 1.2),
            Material = Material(tex)
        })
    end
end

function EFFECT:Think()
    local ct = CurTime()
    for i = #self.Particles, 1, -1 do
        if ct > self.Particles[i].Lifetime then
            table.remove(self.Particles, i)
        end
    end
    return #self.Particles > 0
end

function EFFECT:Render()
    if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then return end
    local camPos = EyePos()
    for _, p in ipairs(self.Particles) do
        render.SetMaterial(p.Material)
        local normal = (camPos - p.Pos):GetNormalized()
        render.DrawQuadEasy(p.Pos, normal, p.Size, p.Size, color_white, p.Rotation)
    end
end

effects.Register(EFFECT, "fleetway_sparkle_OM")


local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Life = 1
    self.DieTime = CurTime() + self.Life

    self.StartSize = 5
    self.EndSize = 300

    self.Speed = 2

    self.Mat1 = Material("icons/FLEETWAY_IS_THE_ROARING_KNIGHT_2.png", "smooth")
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

effects.Register(EFFECT, "Fleetway_lasershootout")

local EFFECT = {}

EFFECT.Mat = Material("icons/fleetway_laser_release_sparks")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Ang = EyeAngles()

    self.Copies = {}

    local count = 6
    local radius = 90

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
            endRadius = radius*1.8,

            startSizex = 5*0.65,
            endSizex = 150*0.65,
            startSizey = 10*0.65,
            endSizey = 250*0.65,

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
    local forward = -eyeAng:Forward()
    if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then return end

    render.SuppressEngineLighting(true)

    for _, copy in ipairs(self.Copies) do
        local age = CurTime() - copy.startTime
        local frac = math.Clamp(age / copy.lifeTime, 0, 1)

        if frac >= 1 then continue end

        local peak = 4 * frac * (1 - frac)

        local radius = Lerp(frac, copy.startRadius, copy.endRadius)

        local worldOffset =
            self.Ang:Up()    * (copy.dir.x * radius) +
            self.Ang:Right() * (copy.dir.y * radius)

        local pos = self.Pos + worldOffset

        local sizex = Lerp(peak, copy.startSizex, copy.endSizex)
        local sizey = Lerp(peak, copy.startSizey, copy.endSizey)

        local alpha = 255 * (1 - frac)

        render.DrawQuadEasy(
            pos,
            forward,
            sizex,
            sizey,
            Color(255, 255, 255, alpha),
            eyeAng.y - copy.ang
        )
    end

    render.SuppressEngineLighting(false)
end

effects.Register(EFFECT, "fleetway_explosion_laser")

local EFFECT = {}

function EFFECT:Init(data)
    self.scale = data:GetScale()
    self.Pos = data:GetOrigin()
    self.Life = 0.7
    self.DieTime = CurTime() + self.Life

    self.StartSize = 600
    self.EndSize = self.scale

    self.CurrentSize = 0

    self.Speed = 7

    self.Mat1 = Material("icons/red_round.png", "smooth")
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()

    self.CurrentSize = Lerp(FrameTime() * self.Speed, self.CurrentSize, 1)
    local size = Lerp(self.CurrentSize, self.StartSize, self.EndSize)

    local frac = math.TimeFraction(self.DieTime - self.Life, self.DieTime, CurTime())
    frac = math.Clamp(frac, 0, 1)

    local fadeStart = 0.1
    local fadeFrac = math.Clamp((frac - fadeStart) / (1 - fadeStart), 0, 1)

    local alpha = 255 * (1 - fadeFrac)

    render.SetMaterial(self.Mat1)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "FleetwayBurstOutline")


-- EYES
local EFFECT_FleetwayEyeSize = {}

function EFFECT_FleetwayEyeSize:Init(data)
    self.Life = 1
    self.DieTime = CurTime() + self.Life

    self.StartSize = 5
    self.EndSize = 40
    self.Mat = Material("icons/Fleetwayspiralnew.png", "smooth")

    self.Ent = data:GetEntity()
    if not IsValid(self.Ent) then return end

    self.Bone = self.Ent:LookupBone("Head")
end

function EFFECT_FleetwayEyeSize:Think()
    if not IsValid(self.Ent) then return false end
    return CurTime() < self.DieTime
end

function EFFECT_FleetwayEyeSize:Render()
    if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then return end
    if not IsValid(self.Ent) or not self.Bone then return end

    local matrix = self.Ent:GetBoneMatrix(self.Bone)
    if not matrix then return end

    local bonePos = matrix:GetTranslation()
    local boneAng = matrix:GetAngles()

    local leftOffset = boneAng:Forward() * 5
    local downOffset = boneAng:Right() * -11
    local forwardOffset = boneAng:Up() * 9

    local pos1 = bonePos + leftOffset + downOffset + forwardOffset
    local pos2 = bonePos - leftOffset + downOffset + forwardOffset

    local frac = 1 - ((self.DieTime - CurTime()) / self.Life)
    frac = math.Clamp(frac * 2, 0, 1)

    local size = Lerp(frac, self.StartSize, self.EndSize)

    local fadeStart = 0.65
    local fadeFrac = 0

    if frac > fadeStart then
        fadeFrac = (frac - fadeStart) / (1 - fadeStart)
    end

    local alpha = 255 * (1 - fadeFrac)

    render.SetMaterial(self.Mat)
    render.DrawSprite(pos1, size, size, Color(255, 255, 255, alpha))
    render.DrawSprite(pos2, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT_FleetwayEyeSize, "Fleetway_EyeSize")


-- SPINDASH HIT
local EFFECT_FleetwaySpindash = {}

local mat = Material("icons/Fleet_impact_kill.png")

function EFFECT_FleetwaySpindash:Init(data)
    self.Origin = data:GetOrigin()

    self.Life = 0
    self.MaxLife = 0.75

    self.Size = 65
    self.MaxSize = 90

    self.RotZ = 900
    self.RotSpeedZ = 900

    self.Mat = mat
end

function EFFECT_FleetwaySpindash:Think()
    self.Life = self.Life + FrameTime()
    self.RotZ = self.RotZ + self.RotSpeedZ*FrameTime()

    return self.Life < self.MaxLife
end

function EFFECT_FleetwaySpindash:Render()
    local pos = self.Origin + Vector(0,0,50)

    local frac = self.Life/self.MaxLife
    local size = Lerp(frac,self.Size,self.MaxSize)

    local alpha = 255
    if frac > 0.75 then
        alpha = 255*(1-(frac-0.75)/0.25)
    end

    local viewAng = EyeAngles()
    local normal = -viewAng:Forward()

    render.SetMaterial(self.Mat)

    render.DrawQuadEasy(
        pos,
        normal,
        size,
        size,
        Color(255,255,255,alpha),
        self.RotZ
    )
end

effects.Register(EFFECT_FleetwaySpindash,"fleetway_spindashhit")



local EFFECT = {}

local function ElectricWobble(pos, intensity, seed)
    local t = CurTime() * 10 + seed

    local offset = Vector(
        math.sin(t * 1.3) * intensity,
        math.cos(t * 1.7) * intensity,
        math.sin(t * 2.1) * intensity
    )

    return pos + offset
end

function EFFECT:Init(data)
    self.LifeTime = 1.0
    self.MaxRadius = 300
    self.Ent = data:GetEntity()
    self.DieTime = CurTime() + self.LifeTime

    self.NextSpark = 0
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:SpawnSpark(startPos, endPos)
    if not startPos or not endPos then return end

    local dir = endPos - startPos
    local dist = dir:Length()
    if dist < 5 then return end

    local steps = math.Clamp(math.floor(dist / 25), 3, 12)

    local emitter = ParticleEmitter(startPos)

    for i = 1, steps do
        local frac = i / steps
        local pos = LerpVector(frac, startPos, endPos)

        local p = emitter:Add("effects/yellowflare", pos)
        if p then
            p:SetVelocity(VectorRand() * 10 + dir:GetNormalized() * 20)
            p:SetDieTime(0.15)
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(2)
            p:SetEndSize(0)
            p:SetGravity(Vector(0,0,0))
            p:SetCollide(false)
            p:SetLighting(false)
            p:SetColor(255, 220, 120)
        end
    end

    emitter:Finish()
end

function EFFECT:Render()
    if not IsValid(self.Ent) then return end

    local startPos = self.Ent:GetNW2Vector("Position1")
    local endPos   = self.Ent:GetNW2Vector("Position2")

    local diff = endPos - startPos
    if diff:Length() < 1 then return end

    local dirAng = diff:Angle()
    local mid = (startPos + endPos) * 0.5

    self:SetRenderBoundsWS(
        startPos - Vector(400,400,400),
        endPos   + Vector(400,400,400)
    )

    local frac = 1 - math.Clamp((self.DieTime - CurTime()) / self.LifeTime, 0, 1)
    local alpha = (1 - frac) * 255

    alpha = alpha * (0.7 + math.Rand(0, 0.3))

    local spread = frac * self.MaxRadius
    local wobbleStrength = (1 - frac) * 25

    local leftPoint  = mid + dirAng:Right() * -spread
    local rightPoint = mid + dirAng:Right() *  spread

    local s1 = ElectricWobble(startPos, wobbleStrength, 1)
    local e1 = ElectricWobble(endPos, wobbleStrength, 2)
    local l1 = ElectricWobble(leftPoint, wobbleStrength, 3)
    local r1 = ElectricWobble(rightPoint, wobbleStrength, 4)

    if CurTime() > self.NextSpark then
        self.NextSpark = CurTime() + 0.05

        self:SpawnSpark(startPos, endPos)
        self:SpawnSpark(startPos, leftPoint)
        self:SpawnSpark(startPos, rightPoint)
    end

    render.SetColorMaterial()

    render.StartBeam(3)
        render.AddBeam(s1, 8, 0, Color(255,255,255,alpha))
        render.AddBeam(l1, 8, 0.5, Color(255,255,255,alpha))
        render.AddBeam(e1, 8, 1, Color(255,255,255,alpha))
    render.EndBeam()

    render.StartBeam(3)
        render.AddBeam(s1, 8, 0, Color(255,255,255,alpha))
        render.AddBeam(r1, 8, 0.5, Color(255,255,255,alpha))
        render.AddBeam(e1, 8, 1, Color(255,255,255,alpha))
    render.EndBeam()
end

effects.Register(EFFECT, "OM_LaserEnd_Fleetway")

local EFFECT = {}

local noneglowmat = Material("models/props_c17/paper01")
local glowMat = Material("models/noodles/om/shared/white")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Scale = data:GetScale() or 1

    self.StartTime = CurTime()

    self.Duration = 0.85
    self.EndTime = self.StartTime + self.Duration

    self.StartRadius = 9
    self.EndRadius = 0

    self.Height = 50
end

function EFFECT:Think()
    return CurTime() < self.EndTime
end

function EFFECT:Render()
    if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then return end
    local frac = (CurTime() - self.StartTime) / self.Duration
    frac = math.Clamp(frac, 0, 1)

    local alpha = (1 - frac) * 125
    local radius = Lerp(frac, self.StartRadius, self.EndRadius)

    if alpha <= 0 then return end

    local startPos = self.Pos
    local endPos = self.Pos + Vector(0, 0, self.Height)

    cam.Start3D()
        render.SetMaterial(glowMat)

        render.DrawBeam(
            startPos,
            endPos,
            radius * 2,
            0,
            1,
            Color(255, 255, 255, alpha)
        )
    cam.End3D()
end

effects.Register(EFFECT, "Fleetway_fatefuldrain_energy_beam")

local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Life = 1.2
    self.DieTime = CurTime() + self.Life

    self.StartSize = 210
    self.EndSize = 5

    self.StarStartSize = 280
    self.StarEndSize = 0

    self.Speed = 2

    self.RotationSpeed1 = 360
    self.RotationSpeed2 = 360

    self.Mat1 = Material("icons/laser_loadup_circle_things.png", "smooth")
    self.Mat2 = Material("icons/fleet_laser_star.png", "smooth")
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = 1 - ((self.DieTime - CurTime()) / self.Life)
    frac = math.Clamp(frac * self.Speed, 0, 1)

    local size = Lerp(frac, self.StartSize, self.EndSize)
    local starSize = Lerp(frac, self.StarStartSize, self.StarEndSize)

    local fadeStart = 0.65
    local fadeFrac = 0
    if frac > fadeStart then
        fadeFrac = (frac - fadeStart) / (1 - fadeStart)
    end

    local alpha = 255 * (1 - fadeFrac)
    local color = Color(255, 255, 255, alpha)

    local angle1 = CurTime() * self.RotationSpeed1
    local angle2 = CurTime() * self.RotationSpeed2

    render.SetMaterial(self.Mat1)
    render.DrawSprite(
        self.Pos,
        size,
        size,
        color,
        angle1
    )

    local normal = EyeVector() * -1

    render.SetMaterial(self.Mat2)
    render.DrawQuadEasy(self.Pos, normal, starSize, starSize, color, angle2)
end


effects.Register(EFFECT, "Fleetway_laserintro")


local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Normal = data:GetNormal() or Vector(0, 0, 1)
    self.Scale = data:GetScale() or 1

    local emitter = ParticleEmitter(self.Pos)

    local ang = self.Normal:Angle()
    local right = ang:Right()
    local forward = ang:Forward()

    for i = 1, 8 do
        local p = emitter:Add("effects/fleck_cement" .. math.random(1,2), self.Pos)
        if p then
            local side = (math.random(0,1) == 1) and right or -right
            local spread = forward * math.Rand(-180, 180)

            local dir = (side * math.Rand(250, 500))
                        + spread
                        + (self.Normal * math.Rand(120, 250))

            p:SetVelocity(dir)
            p:SetDieTime(math.Rand(4.5, 7.0))

            p:SetStartAlpha(255)
            p:SetEndAlpha(0)

            p:SetStartSize(math.Rand(4,8))
            p:SetEndSize(0)

            p:SetGravity(Vector(0,0,-600))
            p:SetAirResistance(60)

            p:SetCollide(true)
            p:SetBounce(0.3)

            p:SetColor(90, 80, 70)
        end
    end

    for i = 1, 25 do
        local p = emitter:Add("particles/smokey", self.Pos)
        if p then
            local side = (math.random(0,1) == 1) and right or -right
            local spread = forward * math.Rand(-120, 120)

            local dir = (side * math.Rand(120, 220))
                        + spread
                        + (self.Normal * math.Rand(60, 140))

            p:SetVelocity(dir)
            p:SetDieTime(math.Rand(5.0, 8.0))

            p:SetStartAlpha(180)
            p:SetEndAlpha(0)

            p:SetStartSize(math.Rand(10,18))
            p:SetEndSize(math.Rand(20,35))

            p:SetGravity(Vector(0,0,-600))
            p:SetAirResistance(120)

            p:SetCollide(true)
            p:SetBounce(0.1)

            p:SetColor(80, 70, 60)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "Fleetway_fatefuldrain_ground_destroy")










-- TINY BALLS
local EFFECT_FleetwayTinyBalls = {}

function EFFECT_FleetwayTinyBalls:Init(data)
    self.Ent = data:GetEntity()
    self.Mat = Material("icons/Fleetways_tiny_balls.png","smooth")
    self.restarttime = CurTime()+ 0.1
end

function EFFECT_FleetwayTinyBalls:Think()

    if !IsValid(self.Ent) then return false end

    if self.restarttime <= CurTime() then
        self.restarttime = CurTime() + 0.1
        local ent = self.Ent

        local entIndex = ent:EntIndex()
        local torsoBone = ent:LookupBone("Torso")

        local function GetFleetwayPos()
            if !IsValid(ent) then return end

            local pos = ent:GetPos()

            if torsoBone then
                local matrix = ent:GetBoneMatrix(torsoBone)
                if matrix then
                    pos = matrix:GetTranslation()
                end
            end

            return pos
        end

        if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then
        else
            local pos = GetFleetwayPos()
            local Emitter = ParticleEmitter(pos)
            for i=1,40 do
                if math.random(1,6) ~= 1 then continue end

                local p = Emitter:Add(self.Mat,pos+Vector(
                    math.random(-10,10),
                    math.random(-10,10),
                    math.random(-10,10)
                )*1.2)

                if p then
                    local dir = VectorRand():GetNormalized()

                    p:SetVelocity(dir*math.Rand(15,40)*2)
                    p:SetDieTime(math.Rand(1.2,2.5))
                    p:SetStartAlpha(150)
                    p:SetEndAlpha(0)
                    p:SetStartSize(math.Rand(0.5,1))
                    p:SetEndSize(0)
                    p:SetColor(255,255,255)
                    p:SetGravity(Vector(0,0,math.Rand(1,3)))
                    p:SetAirResistance(40)
                    p:SetCollide(false)
                end
            end

            Emitter:Finish()
        end
    end

    return true
end

function EFFECT_FleetwayTinyBalls:Render()
end

effects.Register(EFFECT_FleetwayTinyBalls,"OM_tinyball_fleetway")



-- ELECTRICITY
local EFFECT_FleetwayElectricity = {}

local mats = {
    [0] = Material("icons/fleet_spark_red_1.png"),
    [1] = Material("icons/fleet_spark_red_2.png"),
    [2] = Material("icons/fleet_spark_red_3.png"),
    [3] = Material("icons/fleet_spark_red_4.png"),
    [4] = Material("icons/fleet_spark_red_5.png")
}

function EFFECT_FleetwayElectricity:Init(data)

    -- build a safe origin
    local pos = data:GetOrigin()

    if pos == vector_origin then
        pos = data:GetStart()
    end

    if pos == vector_origin then
        local ent = data:GetEntity()
        if IsValid(ent) then
            pos = ent:GetPos()
        end
    end

    self.BasePos = pos
    self.Sparks = {}

    local count = math.random(1,6)

    for i = 1, count do
        local duration = math.Rand(0.2,0.5)

        self.Sparks[i] = {
            pos = VectorRand()*math.random(10,30)+Vector(0,0,math.random(10,50)),
            size = math.random(16,28),
            alpha = 255,
            DieTime = CurTime()+duration,
            Life = duration
        }
    end
end

function EFFECT_FleetwayElectricity:Think()
    local alive = false

    for _,spark in ipairs(self.Sparks or {}) do
        local frac = math.Clamp((spark.DieTime-CurTime())/spark.Life,0,1)
        spark.alpha = 255*frac

        if CurTime() < spark.DieTime then
            alive = true
        end
    end

    return alive
end

function EFFECT_FleetwayElectricity:Render()
    if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then return end

    if not self.BasePos then return end

    for _,spark in ipairs(self.Sparks or {}) do

        if CurTime() >= spark.DieTime then continue end

        render.SetMaterial(mats[math.random(0,4)])

        render.DrawSprite(
            self.BasePos + spark.pos,
            spark.size,
            spark.size,
            Color(255,70,20,spark.alpha)
        )

    end
end

effects.Register(EFFECT_FleetwayElectricity,"Fleetway_Eletricity")