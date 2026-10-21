local EFFECT = {}

local mat = Material("icons/eggman shield popping.png", "smooth")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.StartTime = CurTime()
    self.LifeTime = 0.25

    self.StartSize = 85
    self.EndSize = 175
end

function EFFECT:Think()
    return CurTime() < (self.StartTime + self.LifeTime)
end

function EFFECT:Render()
    local progress = (CurTime() - self.StartTime) / self.LifeTime
    progress = math.Clamp(progress, 0, 1)

    local size = Lerp(progress, self.StartSize, self.EndSize)
    local alpha = 255 * (1 - progress)

    render.SetMaterial(mat)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "OM_eggman_shieldburst")


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
    local origin = self.Ent:GetPos() + Vector(0,0,10)

    for i = 1, 5 do
        local dir = self.Direction:Angle()

        dir:RotateAroundAxis(dir:Right(), math.Rand(-self.Angle, self.Angle))
        dir:RotateAroundAxis(dir:Up(), math.Rand(-self.Angle, self.Angle))

        local finalDir = dir:Forward()

        local image = "icons/eggman clouds.png"

        local particle = self.Emitter:Add(image, origin+ Vector(
            math.random(-5,5),
            math.random(-5,5),
            math.random(-5,5)
        ))

        if particle then
            local flameVel = finalDir * math.Rand(self.Distance * 0.4, self.Distance* 0.7)

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

effects.Register(EFFECT, "om_eggman_expell")

local EFFECT = {}
local mat = Material( "icons/eggman clouds.png", "smooth")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.StartTime = CurTime()
    self.LifeTime = 0.65

    self.StartSize = 135
    self.EndSize = 85
end

function EFFECT:Think()
    return CurTime() < (self.StartTime + self.LifeTime)
end

function EFFECT:Render()
    local progress = (CurTime() - self.StartTime) / self.LifeTime
    progress = math.Clamp(progress, 0, 1)

    local size = Lerp(progress, self.StartSize, self.EndSize)
    local alpha = 255 * (1 - progress)

    render.SetMaterial(mat)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "OM_eggman_doublejump")

local EFFECT = {}

local mats = Material("icons/sparkeggman.png")

function EFFECT:Init(data)
    self.BasePos = data:GetOrigin()

    self.Sparks = {}

    local count = math.random(1, 6)

    for i = 1, count do
        local duration = math.Rand(0.2, 0.5)
        self.Sparks[i] = {
            pos = VectorRand() * math.random(10, 30),
            size = math.random(16, 28),
            alpha = 255,
            DieTime = CurTime() + duration,
            Life = duration
        }
    end
end

function EFFECT:Think()
    local alive = false

    for _, spark in ipairs(self.Sparks or {}) do
        local frac = math.Clamp((spark.DieTime - CurTime()) / spark.Life, 0, 1)
        spark.alpha = 255 * frac

        if CurTime() < spark.DieTime then
            alive = true
        end
    end

    return alive
end

function EFFECT:Render()
    if not self.BasePos then return end

    for _, spark in ipairs(self.Sparks or {}) do
        if CurTime() >= spark.DieTime then continue end

        render.SetMaterial(mats)

        render.DrawSprite(
            self.BasePos + spark.pos,
            spark.size,
            spark.size,
            Color(255, 70, 20, spark.alpha)
        )
    end
end

effects.Register(EFFECT, "eggman_eletricity")