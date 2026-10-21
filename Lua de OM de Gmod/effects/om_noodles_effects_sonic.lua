local textures = {
    "icons/om_star_sonic"
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
    local camPos = EyePos()
    for _, p in ipairs(self.Particles) do
        render.SetMaterial(p.Material)
        local normal = (camPos - p.Pos):GetNormalized()
        render.DrawQuadEasy(p.Pos, normal, p.Size, p.Size, color_white, p.Rotation)
    end
end

effects.Register(EFFECT, "sonic_sparkle_OM")

local EFFECT = {}

function EFFECT:Init(data)

    local pos = data:GetOrigin()

    if not pos or pos == vector_origin then
        local ent = data:GetEntity()
        if IsValid(ent) then
            pos = ent:GetPos()
        else
            pos = vector_origin
        end
    end

    self.HasDLight = true
end


function EFFECT:Think()

    if CurTime() > self.DieTime then
        self.HasDLight = false
        return false
    end

    if self.HasDLight then

        local fade = math.Clamp((self.DieTime - CurTime()) / 0.5, 0, 1)

        local dlight = DynamicLight(self:EntIndex())

        if dlight then
            dlight.pos = self.Pos
            dlight.r = 255
            dlight.g = 255
            dlight.b = 255
            dlight.brightness = 1.2 * fade
            dlight.Decay = 600
            dlight.Size = 250 * fade
            dlight.DieTime = CurTime() + 0.05
        end
    end

    return true
end


function EFFECT:Render()
end


effects.Register(EFFECT, "SonicTrail_OM")

local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Dir = data:GetNormal() or Vector(0,0,1)

    self.LifeTime = 1.5
    self.DieTime = CurTime() + self.LifeTime

    self.NextEmit = 0
end

function EFFECT:Think()
    if CurTime() >= self.DieTime then
        return false
    end

    if CurTime() < self.NextEmit then return true end
    self.NextEmit = CurTime() + 0.015

    for i = 1, 8 do
        local effect = EffectData()

        effect:SetOrigin(
            self.Pos +
            VectorRand() * math.Rand(2, 8)
        )

        effect:SetNormal(
            (self.Dir + VectorRand() * 0.8):GetNormalized()
        )

        effect:SetScale(math.Rand(8, 15))
        effect:SetMagnitude(math.Rand(2, 4))
        effect:SetRadius(math.Rand(8, 20))

        util.Effect("BloodImpact", effect)
    end

    return true
end

function EFFECT:Render()
end

effects.Register(EFFECT, "sonic_dropdashdrill_OM")

local EFFECT = {}

local smokeMat = Material("particle/particle_smokegrenade")

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local normal = data:GetNormal() or Vector(0, 0, 1)

    local emitter = ParticleEmitter(pos)
    if not emitter then return end

    for i = 1, 45 do
        local particle = emitter:Add(smokeMat, pos)
        if particle then

            local dir = VectorRand()
            dir.z = math.abs(dir.z) * 0.6
            dir:Normalize()

            particle:SetVelocity(dir * math.Rand(40, 120) + normal * math.Rand(40, 90))

            particle:SetGravity(Vector(0, 0, math.Rand(10, 30)))
            particle:SetAirResistance(120)

            particle:SetDieTime(math.Rand(1.2, 2.5))

            particle:SetStartAlpha(math.Rand(80, 140))
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(3, 6))
            particle:SetEndSize(math.Rand(10, 20))

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-1, 1))

            particle:SetColor(180, 180, 180)

            particle:SetCollide(false)
        end
    end


    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "sonic_peeloutdust2_OM")

local EFFECT = {}

local mat = Material("icons/sonic_drop_impact.png")

function EFFECT:Init(data)
    self.Player = data:GetEntity()
    if not IsValid(self.Player) then return end

    self.Life = 0
    self.MaxLife = 0.45

    self.StartSize = 0
    self.EndSize = 165

    self.RotZ = math.random(0,360)
    self.RotSpeedZ = 900

    self.Mat = mat
end

function EFFECT:Think()
    if not IsValid(self.Player) then return false end

    self.Life = self.Life + FrameTime()*1

    return self.Life < self.MaxLife
end

function EFFECT:Render()
    if not IsValid(self.Player) then return end

    local pos = self.Player:GetPos() + Vector(0, 0, 50)

    local frac = self.Life / self.MaxLife

    local size = Lerp(frac, self.StartSize, self.EndSize)

    local alpha = 255 * (1 - frac)

    local viewAng = EyeAngles()
    local normal = -viewAng:Forward()

    render.SetMaterial(self.Mat)

    render.DrawQuadEasy(
        pos,
        normal,
        size,
        size,
        Color(255, 255, 255, alpha*2),
        self.RotZ
    )
end

effects.Register(EFFECT, "sonic_spindashhit")


local EFFECT = {}

EFFECT.Mat = Material("icons/sonic_dashing_effect")

function EFFECT:Init(data)
    self.Origin = data:GetOrigin()
    self.Normal = data:GetNormal():GetNormalized()

    local ang = self.Normal:Angle()
    self.Forward = ang:Forward()
    self.Right = ang:Right()
    self.Up = ang:Up()

    self.Theta = math.Rand(0, math.pi * 2)

    self.StartRadius = 20
    self.EndRadius = 30

    self.StartBackOffset = 0
    self.EndBackOffset = 80

    self.StartSize = 16
    self.EndSize = self.StartSize * 7

    self.LifeTime = 0.5
    self.DieTime = CurTime() + self.LifeTime
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = 1 - (self.DieTime - CurTime()) / self.LifeTime

    local radius = Lerp(frac, self.StartRadius, self.EndRadius)

    local offset =
        self.Right * math.cos(self.Theta) * radius +
        self.Up * math.sin(self.Theta) * radius

    local backOffset = -self.Normal * Lerp(frac, self.StartBackOffset, self.EndBackOffset)

    local pos = self.Origin + offset + backOffset

    local size = Lerp(frac, self.StartSize, self.EndSize)
    local alpha = 255 * (1 - frac)

    local dir = (self.Origin - pos):GetNormalized()

    local rot = math.deg(math.atan2(
        dir:Dot(self.Up),
        dir:Dot(self.Right)
    ))

    render.SetMaterial(self.Mat)
    render.DrawQuadEasy(
        pos,
        -EyeVector(),
        size,
        size,
        Color(255, 255, 255, alpha),
        rot + 180
    )
end

effects.Register(EFFECT, "sonic_peelout_moons")