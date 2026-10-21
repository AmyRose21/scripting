local EFFECT = {}

EFFECT.Mat = Material("particle/particle_smokegrenade")

function EFFECT:Init(data)
    local pos = data:GetOrigin()

    local emitter = ParticleEmitter(pos)
    if not emitter then return end

    for i = 1, 180 do
        local particle = emitter:Add("particle/particle_smokegrenade", pos)
        if particle then
            local dir = VectorRand():GetNormalized()

            particle:SetVelocity(dir * math.Rand(400, 1400)*1.5)
            particle:SetAirResistance(25)

            particle:SetDieTime(math.Rand(6, 9))

            particle:SetStartAlpha(240)
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(20, 45))
            particle:SetEndSize(math.Rand(120, 260))

            particle:SetColor(0, 0, 0)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-3, 3))

            particle:SetGravity(Vector(
                math.Rand(-25, 25),
                math.Rand(-25, 25),
                math.Rand(-40, -120)*10
            ))

            particle:SetCollide(true)
            particle:SetBounce(0.15)
        end
    end

    for i = 1, 90 do
        local particle = emitter:Add("particle/particle_smokegrenade", pos)
        if particle then
            local dir = VectorRand():GetNormalized()

            particle:SetVelocity(dir * math.Rand(80, 250)*1.5)
            particle:SetAirResistance(10)

            particle:SetDieTime(math.Rand(8, 12))

            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(40, 80))
            particle:SetEndSize(math.Rand(180, 320))

            particle:SetColor(0, 0, 0)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-1, 1))

            particle:SetGravity(Vector(
                math.Rand(-10, 10),
                math.Rand(-10, 10),
                math.Rand(-10, -40)*10
            ))

            particle:SetCollide(false)
        end
    end

    for i = 1, 80 do
        local particle = emitter:Add("effects/fleck_cement1", pos)
        if particle then
            local dir = VectorRand():GetNormalized()

            particle:SetVelocity(dir * math.Rand(300, 1200)*1.5)
            particle:SetGravity(Vector(0, 0, -600))

            particle:SetDieTime(math.Rand(2, 4))

            particle:SetStartAlpha(255)
            particle:SetEndAlpha(255)

            particle:SetStartSize(math.Rand(4, 10))
            particle:SetEndSize(0)

            particle:SetColor(0, 0, 0)

            particle:SetCollide(true)
            particle:SetBounce(0.3)
        end
    end

    for i = 1, 40 do
        local particle = emitter:Add("particle/particle_smokegrenade", pos)
        if particle then
            particle:SetVelocity(VectorRand() * 500)

            particle:SetDieTime(6)

            particle:SetStartAlpha(220)
            particle:SetEndAlpha(0)

            particle:SetStartSize(50)
            particle:SetEndSize(250)

            particle:SetColor(0, 0, 0)

            particle:SetAirResistance(15)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "eyx_projectile_explode")






local EFFECT = {}

EFFECT.RingMat = Material("effects/select_ring")
EFFECT.RefractMat = Material("models/spawn_effect")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Normal = data:GetNormal()

    if self.Normal:LengthSqr() <= 0 then
        self.Normal = Vector(0,0,1)
    end

    self.MaxDistance = data:GetScale()
    self.MaxRadius = data:GetMagnitude()

    self.LifeTime = 1.2
    self.DieTime = CurTime() + self.LifeTime
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = 1 - ((self.DieTime - CurTime()) / self.LifeTime)
    local alpha = 255 * (1 - frac)

    render.UpdateRefractTexture()

    for i = 1, 5 do
        local offset = (i - 1) * (self.MaxRadius * 0.08)
        local size = frac * self.MaxRadius - offset

        if size <= 0 then continue end

        local pos = self.Pos + self.Normal * (frac * self.MaxDistance)

        render.SetMaterial(self.RefractMat)

        for j = 1, 3 do
            local scale = 1 + (j * 0.15)

            self.RefractMat:SetFloat(
                "$refractamount",
                (0.02 + math.sin(CurTime() * 10 + i) * 0.01) * j
            )

            render.DrawQuadEasy(
                pos,
                self.Normal,
                size * scale,
                size * scale,
                Color(255,255,255,40)
            )

            render.DrawQuadEasy(
                pos,
                -self.Normal,
                size * scale,
                size * scale,
                Color(255,255,255,40)
            )
        end

        render.SetMaterial(self.RingMat)

        local col = Color(
            255,
            255,
            255,
            alpha * math.Clamp(1 - (size / self.MaxRadius), 0, 1)
        )

        render.DrawQuadEasy(
            pos,
            self.Normal,
            size,
            size,
            col
        )

        render.DrawQuadEasy(
            pos,
            -self.Normal,
            size,
            size,
            col
        )
    end
end

effects.Register(EFFECT, "eyx_screamwaves")