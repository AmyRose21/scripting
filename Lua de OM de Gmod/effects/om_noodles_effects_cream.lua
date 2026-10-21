local EFFECT = {}

local mat = Material("icons/cream heal particle 2.png", "smooth")

function EFFECT:Init(data)
    self.Ent = data:GetEntity()
    if not IsValid(self.Ent) then return end

    self.StartTime = CurTime()
    self.LifeTime = 2

    self.Size = 50

    self.Particles = {}
    for i = 1, math.random(1,5) do
        self.Particles[i] = {
            zOffset = math.Rand(-20, 0),
            SpinSpeed = math.random(70,180)
        }
    end

    self:SetRenderBounds(
        Vector(-128, -128, -128),
        Vector(128, 128, 128)
    )
end

function EFFECT:Think()
    if not IsValid(self.Ent) then return false end
    return CurTime() < (self.StartTime + self.LifeTime)
end

function EFFECT:Render()
    if not IsValid(self.Ent) then return end

    local elapsed = CurTime() - self.StartTime
    local lifeFrac = elapsed / self.LifeTime

    local fadeTime = 0.2
    local alpha
    if lifeFrac < fadeTime then
        alpha = (lifeFrac / fadeTime) * 255
    elseif lifeFrac > (1 - fadeTime) then
        alpha = ((1 - lifeFrac) / fadeTime) * 255
    else
        alpha = 255
    end
    alpha = math.Clamp(alpha, 0, 255)

    local center = self.Ent:WorldSpaceCenter()

    render.CullMode(MATERIAL_CULLMODE_NONE)
    render.SetMaterial(mat)

    for _, particle in ipairs(self.Particles) do
        local pos = center + Vector(0, 0, particle.zOffset)
        local spin = elapsed * particle["SpinSpeed"]
        render.DrawQuadEasy(
            pos,
            Vector(0, 0, 1),
            self.Size,
            self.Size,
            Color(255, 255, 255, alpha),
            spin
        )
    end
end

effects.Register(EFFECT, "cream_heal_orbit2")

local EFFECT = {}

function EFFECT:Init(data)
    self.Lifetime = CurTime() + 3

    local pos = data:GetOrigin()

    self.Emitter = ParticleEmitter(pos)
    self.Mat = Material("icons/cream's heal particles.png", "smooth")

    for i = 1, 20 do
        if math.random(1,2) ~= 1 then continue end

        local p = self.Emitter:Add(self.Mat, pos + Vector(
            math.random(-14,14),
            math.random(-14,14),
            math.random(-14,14)
        ))

        if p then
            local speed = math.Rand(15, 30)
            p:SetVelocity(Vector(0, 0, speed))

            p:SetDieTime(math.Rand(1.2, 2.5))
            p:SetStartAlpha(150)
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(9,20))
            p:SetEndSize(0)
            p:SetColor(255, 255, 255)
            p:SetGravity(Vector(0, 0, math.Rand(1, 3)))
            p:SetAirResistance(5)
            p:SetCollide(false)
        end
    end

    self.Emitter:Finish()
end

function EFFECT:Think()
    return CurTime() < self.Lifetime
end

function EFFECT:Render()
end

effects.Register(EFFECT, "cream_healing_diamond")

local EFFECT = {}

function EFFECT:Init(data)
    self.Lifetime = CurTime() + 3
    self.Pos = data:GetOrigin()

    self.Emitter = ParticleEmitter(self.Pos)
    self.Mat = Material("icons/Cream light beam.png", "smooth")

    for i = 1, 20 do
        if math.random(1,3) ~= 1 then continue end

        local p = self.Emitter:Add(self.Mat, self.Pos + Vector(
            math.random(-30,30),
            math.random(-30,30),
            math.random(-14,14)
        ))

        if p then
            local speed = math.Rand(15, 50)
            p:SetVelocity(Vector(0, 0, speed))

            p:SetDieTime(math.Rand(1.2, 2.5))
            p:SetStartAlpha(150)
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(9,14))
            p:SetEndSize(0)
            p:SetColor(255, 255, 255)
            p:SetGravity(Vector(0, 0, math.Rand(1, 7)))
            p:SetAirResistance(5)
            p:SetCollide(false)
        end
    end

    self.Emitter:Finish()
end

function EFFECT:Think()
    if CurTime() >= self.Lifetime then return false end

    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.Pos = self.Pos
        dlight.r = 0
        dlight.g = 255
        dlight.b = 0
        dlight.Brightness = 2
        dlight.Decay = 500
        dlight.Size = 300
        dlight.DieTime = CurTime() + 0.1
    end

    return true
end

function EFFECT:Render()
end

effects.Register(EFFECT, "cream_healing_upwards")