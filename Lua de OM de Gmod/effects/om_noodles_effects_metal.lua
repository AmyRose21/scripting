local EFFECT = {}

function EFFECT:Init(data)
    self.Entity = data:GetEntity()
    if not IsValid(self.Entity) then
        self.Entity = nil
    end

    self.Life = 0
    self.MaxLife = 1
    self.Rotation = math.random(0, 360)
    self.Mat = Material("icons/metal_load")
end

function EFFECT:Think()
    self.Life = self.Life + FrameTime()
    return self.Life < self.MaxLife and (not self.Entity or IsValid(self.Entity))
end

function EFFECT:Render()
    if self.Entity and IsValid(self.Entity) then
        self.Pos = self.Entity:GetPos() + Vector(0,0,23)
    end

    local frac = self.Life / self.MaxLife

    local size
    if frac < 0.15 then
        size = 64 * (frac / 0.15)
    elseif frac < 0.75 then
        size = 64
    else
        size = 64 * (1 - (frac - 0.75)/0.25) 
    end
    size = math.max(size, 1)

    local alpha
    if frac < 0.75 then
        alpha = 255
    else
        alpha = 255 * (1 - (frac - 0.75)/0.25)
    end
    alpha = math.Clamp(alpha, 0, 255)

    self.Rotation = self.Rotation - FrameTime() * 900

    local forward = LocalPlayer():EyeAngles():Forward() * -1

    render.SetMaterial(self.Mat)
    render.DrawQuadEasy(
        self.Pos,
        forward,
        size,
        size,
        Color(255, 255, 255, alpha),
        self.Rotation
    )
end

effects.Register(EFFECT, "metalsonic_chargeOm")

local textures = {
    "icons/metal_particle_new"
}

local EFFECT = {}

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local normal = data:GetNormal() or Vector(0,0,1)

    local emitter = ParticleEmitter(pos, false)

    if math.random(1, 2) == 1 then
        local tex = textures[math.random(#textures)]

        local targetPos = pos + VectorRand() * 60

        local particle = emitter:Add(tex, pos)

        if particle then
            particle:SetDieTime(math.Rand(0.5, 1.2))
            particle:SetStartSize(math.random(8, 24)*0.7)
            particle:SetEndSize(0)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)

            particle:SetAngles(normal:Angle())
            particle:SetAngleVelocity(Angle(0,0,0))

            local dir = (targetPos - pos):GetNormalized()

            -- Set velocity toward that random position
            particle:SetVelocity(dir * math.random(60, 120))

            particle:SetAirResistance(5)
            particle:SetGravity(Vector(0,0,0))

            particle:SetColor(255,255,255)
            particle:SetCollide(false)
        end
    end

    emitter:Finish()
    self.DieTime = CurTime() + 0.1
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
end

effects.Register(EFFECT, "metalsonic_sparkle_OM")

local textures = {
    "icons/particle_metal_1"
}

local EFFECT = {}

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local normal = data:GetNormal() or Vector(0,0,1)

    local emitter = ParticleEmitter(pos, false)
    if math.random(1,2) == 1 then
        local tex = textures[math.random(#textures)]
        local particle = emitter:Add(tex, pos + VectorRand() * 10)

        if particle then
            particle:SetDieTime(1)
            particle:SetStartSize(20)
            particle:SetEndSize(0)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)

            particle:SetAngles(normal:Angle())
            particle:SetAngleVelocity(Angle(0,0,0))

            particle:SetVelocity(normal:GetNormalized() * 80)

            particle:SetAirResistance(5)
            particle:SetGravity(Vector(0,0,0))

            particle:SetColor(255,255,255)
            particle:SetCollide(false)
        end
    end

    emitter:Finish()
    self.DieTime = CurTime() + 0.1
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
end

effects.Register(EFFECT, "metalsonic_middlespark_OM")

local EFFECT = {}

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    if not pos or pos == vector_origin then
        local ent = data:GetEntity()
        if IsValid(ent) then
            pos = ent:GetPos()
        else
            pos = Vector(0, 0, 0)
        end
    end

    self.Pos = pos
    self.Color = Color(255, 255, 0, 255)
    self.LifeTime = CurTime() + 0.15

    self.Points = {}
    for i = 1, 4 do
        local ang = math.rad((i - 1) * 90)
        local radius = math.Rand(20, 32)
        local offset = Vector(math.cos(ang) * radius, math.sin(ang) * radius, math.Rand(-18, 18))
        self.Points[i] = self.Pos + offset
    end

    self.mat = Material("sprites/physbeam")
end

function EFFECT:Think()
    return CurTime() < self.LifeTime
end

function EFFECT:Render()
    render.SetMaterial(self.mat)

    local jitter = 4
    local thickness = 20

    for i = 1, #self.Points do
        local A = self.Points[i]
        local B = self.Points[(i % #self.Points) + 1]

        local segments = 5

        for s = 0, segments - 1 do
            local t1 = s     / segments
            local t2 = (s+1) / segments

            local p1 = LerpVector(t1, A, B)
            local p2 = LerpVector(t2, A, B)

            local o1 = VectorRand() * jitter
            local o2 = VectorRand() * jitter

            render.DrawBeam(p1 + o1, p2 + o2, thickness, 0, 1, self.Color)
        end
    end
end

effects.Register(EFFECT, "metal_om_Eletricity")




local EFFECT = {}

local mat = Material("icons/metal sonic charge electricity.png")
function EFFECT:Init(data)
    self.Player = data:GetEntity()
    if not IsValid(self.Player) then return end

    self.Life = 0
    self.MaxLife = 0.75
    self.Size = 130*0.4
    self.MaxSize = 150*0.4

    self.RotZ = 500

    self.RotSpeedZ = (math.random() - 0.5) * 500 * 1

    self.Mat = mat
end

function EFFECT:Think()
    if not IsValid(self.Player) then return false end

    self.Life = self.Life + FrameTime()
    self.RotZ = self.RotZ + self.RotSpeedZ * FrameTime()

    return self.Life < self.MaxLife
end

function EFFECT:Render()
    if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then return end
    if not IsValid(self.Player) then return end

    local pos = self.Player:GetPos() + Vector(0,0,30)

    local frac = self.Life / self.MaxLife
    local size = Lerp(frac, self.Size, self.MaxSize)

    local alpha = 255
    if frac > 0.75 then
        alpha = 255 * (1 - (frac - 0.75) / 0.25)
    end

    local viewAng = EyeAngles()
    local normal = -viewAng:Forward()

    render.SetMaterial(self.Mat)
    self.RotZ = self.RotZ + self.RotSpeedZ * FrameTime()

    render.DrawQuadEasy(pos, normal, size, size, Color(255,255,255,alpha), self.RotZ)

end


effects.Register(EFFECT, "Metal_eletricity")

local EFFECT = {}

local mat = Material("icons/metal charge square.png")

function EFFECT:Init(data)
    if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then return end
    self.Pos = data:GetOrigin()

    self.Life = 0
    self.MaxLife = 1

    self.Size = 40
    self.MaxSize = 60

    self.Mat = mat

    self.Emitter = ParticleEmitter(self.Pos)

    local p = self.Emitter:Add(self.Mat, self.Pos)
    if p then
        p:SetDieTime(self.MaxLife)

        p:SetStartSize(self.Size)
        p:SetEndSize(self.MaxSize)

        p:SetStartAlpha(200)
        p:SetEndAlpha(0)

        p:SetColor(255, 255, 255)

        p:SetGravity(Vector(0, 0, 0))
        p:SetVelocity(Vector(0, 0, 0))
        p:SetAirResistance(0)

        p:SetRoll(math.Rand(0, 360))
        p:SetRollDelta(1)
    end
    self.Emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "Metal_ChargeImpact")

local EFFECT = {}

local mat = Material("icons/metal sonic punch impact.png")
local sparkMat = Material("effects/yellowflare")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()

    self.Life = 0
    self.MaxLife = 0.35

    self.Mat = mat

    self.Emitter = ParticleEmitter(self.Pos)

    for i = 1, 1 do
        local p = self.Emitter:Add(self.Mat, self.Pos)
        if p then
            local dir = VectorRand():GetNormalized()

            p:SetDieTime(self.MaxLife)

            p:SetStartSize(math.Rand(10, 18))
            p:SetEndSize(math.Rand(30, 60))

            p:SetStartAlpha(220)
            p:SetEndAlpha(0)

            p:SetColor(255, 255, 255)

            p:SetVelocity(dir * math.Rand(80, 180))
            p:SetGravity(Vector(0, 0, -200))
            p:SetAirResistance(40)

            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-8, 8))
        end
    end

    for i = 1, 10 do
        local p = self.Emitter:Add(sparkMat, self.Pos)
        if p then
            local dir = VectorRand():GetNormalized()

            p:SetDieTime(math.Rand(0.15, 0.3))

            p:SetStartSize(math.Rand(2, 4))
            p:SetEndSize(0)

            p:SetStartAlpha(255)
            p:SetEndAlpha(0)

            p:SetColor(255, 220, 120)

            p:SetVelocity(dir * math.Rand(150, 350))

            p:SetGravity(Vector(0, 0, -600))
            p:SetAirResistance(80)

            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-20, 20))
        end
    end

    local shock = self.Emitter:Add(self.Mat, self.Pos)
    if shock then
        shock:SetDieTime(0.15)

        shock:SetStartSize(5)
        shock:SetEndSize(140)

        shock:SetStartAlpha(180)
        shock:SetEndAlpha(0)

        shock:SetColor(255, 255, 255)

        shock:SetVelocity(Vector(0, 0, 0))
        shock:SetAirResistance(0)
        shock:SetGravity(Vector(0, 0, 0))

        shock:SetRoll(math.Rand(0, 360))
    end
end

function EFFECT:Think()
    self.Life = self.Life + FrameTime()

    if self.Emitter then
        self.Emitter:Finish()
        self.Emitter = nil
    end

    return self.Life < self.MaxLife
end

function EFFECT:Render()
end

effects.Register(EFFECT, "Metal_PunchImpact")

local EFFECT = {}

local burnMat = Material("icons/metal_crack_wall")
local ringMat = Material("effects/select_ring")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin() + Vector(0,0,10)
    self.Normal = data:GetNormal()

    self.Size = math.Rand(90, 140)

    self.Life = 0
    self.MaxLife = 10

    self.Alpha = 255

    self.RingLife = 0
    self.RingMaxLife = 0.6

    self.RingStartSize = 20
    self.RingEndSize = 200

    util.ScreenShake(self.Pos, 4, 4, 0.4, 400)

    local currentpos = self.Pos - self.Normal * 8
    local emitter = ParticleEmitter(currentpos)

    if emitter then
        for i = 1, 48 do
            local p = emitter:Add("particle/particle_smokegrenade", currentpos)

            if p then
                local dir =
                    (self.Normal * math.Rand(220, 520)) +
                    (VectorRand() * math.Rand(80, 260))

                p:SetVelocity(dir)

                p:SetDieTime(math.Rand(1.2, 2.8)*0.4)

                p:SetStartAlpha(math.Rand(180, 240))
                p:SetEndAlpha(0)

                p:SetStartSize(math.Rand(22, 42))
                p:SetEndSize(math.Rand(100, 180))

                p:SetRoll(math.Rand(0, 360))
                p:SetRollDelta(math.Rand(-1, 1))

                p:SetColor(85, 82, 78)

                p:SetAirResistance(220)
                p:SetGravity(Vector(0, 0, 60))
            end
        end

        for i = 1, 36 do
            local p = emitter:Add(
                "effects/fleck_cement"..math.random(1,2),
                currentpos
            )

            if p then
                local spread = VectorRand() * math.Rand(60, 240)

                local dir =
                    (self.Normal * math.Rand(350, 850)) +
                    spread

                p:SetVelocity(dir)

                p:SetDieTime(math.Rand(1.5, 3)*0.4)

                p:SetStartAlpha(255)
                p:SetEndAlpha(0)

                p:SetStartSize(math.Rand(5, 12))
                p:SetEndSize(0)

                p:SetRoll(math.Rand(0, 360))
                p:SetRollDelta(math.Rand(-14, 14))

                p:SetColor(130, 130, 130)

                p:SetGravity(Vector(0, 0, -900))
                p:SetAirResistance(20)

                p:SetCollide(true)
                p:SetBounce(0.45)
            end
        end

        for i = 1, 25 do
            local ang = (i / 20) * 360

            local dir =
                (Angle(0, ang, 0):Forward() * math.Rand(180, 420)) +
                (self.Normal * 120)

            local p = emitter:Add("particle/particle_smokegrenade", currentpos)

            if p then
                p:SetVelocity(dir)

                p:SetDieTime(math.Rand(0.7, 1.4)*0.4)

                p:SetStartAlpha(120)
                p:SetEndAlpha(0)

                p:SetStartSize(math.Rand(18, 28))
                p:SetEndSize(math.Rand(60, 100))

                p:SetColor(70, 70, 70)

                p:SetAirResistance(150)
            end
        end

        emitter:Finish()
    end
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
    local pos = self.Pos - self.Normal * 8

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
            pos + self.Normal * 0.5,
            self.Normal,
            ringSize,
            ringSize,
            Color(80, 80, 80, ringAlpha),
            0
        )
    end

    render.SetMaterial(burnMat)

    cam.Start3D2D(pos, ang, 0.25)
        surface.SetMaterial(burnMat)
        --[[
        surface.SetDrawColor(10, 10, 10, self.Alpha)

        surface.DrawTexturedRect(
            -self.Size * 2,
            -self.Size * 2,
            self.Size * 4,
            self.Size * 4
        )
        ]]

        surface.SetDrawColor(25, 255, 255, self.Alpha)

        surface.DrawTexturedRect(
            -self.Size * 1.5,
            -self.Size * 1.5,
            self.Size * 3,
            self.Size * 3
        )
        --[[
        surface.SetDrawColor(20, 20, 20, self.Alpha * 0.5)

        surface.DrawTexturedRect(
            -self.Size * 2.4,
            -self.Size * 2.4,
            self.Size * 4.8,
            self.Size * 4.8
        )
        ]]
    cam.End3D2D()
end

effects.Register(EFFECT, "Metal_Charge_SMASHWALL")