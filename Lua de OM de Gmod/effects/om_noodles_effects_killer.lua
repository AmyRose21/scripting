local EFFECT = {}

EFFECT.Mat = Material("effects/blood_core")
EFFECT.RingMat = Material("effects/select_ring")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Scale = math.Clamp(data:GetScale(), 0.5, 8)

    self.LifeTime = CurTime() + 0.7
    self.Emitter = ParticleEmitter(self.Pos)

    self.RingSize = 4
    self.RingAlpha = 255

    if not self.Emitter then return end

    for i = 1, math.random(28, 45) do
        local particle = self.Emitter:Add("effects/blood_core", self.Pos)

        if particle then
            local dir = VectorRand():GetNormalized()

            particle:SetVelocity(dir * math.random(120, 420) * self.Scale)

            particle:SetAirResistance(140)

            particle:SetDieTime(math.Rand(0.5, 1.4))

            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)

            local size = math.Rand(2, 6) * self.Scale

            particle:SetStartSize(size)
            particle:SetEndSize(size * 0.2)

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-10, 10))

            particle:SetColor(140, 0, 0)

            particle:SetGravity(Vector(0, 0, -500))

            particle:SetCollide(true)
            particle:SetBounce(0.15)

            particle:SetNextThink(CurTime())

            particle:SetThinkFunction(function(p)
                if not IsValid(self.Emitter) then return end

                for _ = 1, 2 do
                    local mist = self.Emitter:Add(
                        "particle/particle_smokegrenade",
                        p:GetPos()
                    )

                    if mist then
                        mist:SetVelocity(VectorRand() * 20)

                        mist:SetAirResistance(40)

                        mist:SetDieTime(math.Rand(0.2, 0.45))

                        mist:SetStartAlpha(math.random(40, 70))
                        mist:SetEndAlpha(0)

                        mist:SetStartSize(math.Rand(3, 5))
                        mist:SetEndSize(math.Rand(10, 16))

                        mist:SetRoll(math.Rand(0, 360))
                        mist:SetRollDelta(math.Rand(-2, 2))

                        mist:SetColor(120, 0, 0)

                        mist:SetGravity(Vector(0, 0, 15))
                    end
                end

                p:SetNextThink(CurTime() + 0.015)
            end)
        end
    end

    for i = 1, math.random(5, 10) do
        local chunk = self.Emitter:Add("effects/fleck_cement1", self.Pos)

        if chunk then
            chunk:SetVelocity(
                VectorRand():GetNormalized() * math.random(150, 280)
            )

            chunk:SetDieTime(math.Rand(0.6, 1.6))

            chunk:SetStartAlpha(255)
            chunk:SetEndAlpha(0)

            chunk:SetStartSize(math.Rand(1, 3))
            chunk:SetEndSize(0)

            chunk:SetRoll(math.Rand(0, 360))

            chunk:SetColor(90, 0, 0)

            chunk:SetGravity(Vector(0, 0, -650))

            chunk:SetCollide(true)
            chunk:SetBounce(0.3)
        end
    end

    for i = 1, math.random(15, 22) do
        local smoke = self.Emitter:Add(
            "particle/particle_smokegrenade",
            self.Pos
        )

        if smoke then
            smoke:SetVelocity(VectorRand() * math.random(20, 80))

            smoke:SetAirResistance(80)

            smoke:SetDieTime(math.Rand(0.4, 0.9))

            smoke:SetStartAlpha(math.random(40, 80))
            smoke:SetEndAlpha(0)

            smoke:SetStartSize(math.Rand(5, 10) * self.Scale)
            smoke:SetEndSize(math.Rand(18, 28) * self.Scale)

            smoke:SetRoll(math.Rand(0, 360))
            smoke:SetRollDelta(math.Rand(-1, 1))

            smoke:SetColor(100, 0, 0)

            smoke:SetGravity(Vector(0, 0, 25))
        end
    end
end

function EFFECT:Think()
    self.RingSize = self.RingSize + FrameTime() * 220
    self.RingAlpha = math.max(self.RingAlpha - FrameTime() * 500, 0)

    if CurTime() > self.LifeTime then
        if self.Emitter and IsValid(self.Emitter) then
            self.Emitter:Finish()
        end

        return false
    end

    return true
end

function EFFECT:Render()
    render.SetMaterial(self.RingMat)

    render.DrawSprite(
        self.Pos,
        self.RingSize,
        self.RingSize,
        Color(180, 180, 180, self.RingAlpha)
    )
end

effects.Register(EFFECT, "om_blood_splatter")







local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Dir = data:GetNormal():GetNormalized()

    local emitter = ParticleEmitter(self.Pos)
    if not emitter then return end

    for i = 1, 70 do
        local frac = i / 70

        local spawnPos =
            self.Pos +
            self.Dir * (frac * math.Rand(5, 40))

        local particle = emitter:Add("effects/blood_core", spawnPos)
        if particle then
            local right = self.Dir:Angle():Right()
            local up = self.Dir:Angle():Up()

            particle:SetVelocity(
                self.Dir * math.Rand(500, 1200)*0.3 +
                right * math.Rand(-500, 500)*0.75 +
                up * math.Rand(-400, 400)*0.75
            )

            particle:SetDieTime(math.Rand(1, 2)*20)

            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(8, 16))
            particle:SetEndSize(math.Rand(2, 6))

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-5, 5))

            particle:SetGravity(Vector(0, 0, -500))
            particle:SetAirResistance(150)

            particle:SetCollide(true)
            particle:SetBounce(0.1)

            particle:SetColor(120, 0, 0)
        end
    end

    for i = 1, 35 do
        local particle = emitter:Add("particle/particle_smokegrenade", self.Pos)
        if particle then
            local right = self.Dir:Angle():Right()
            local up = self.Dir:Angle():Up()

            particle:SetVelocity(
                self.Dir * math.Rand(500, 1200)*0.3 +
                right * math.Rand(-500, 500)*0.75 +
                up * math.Rand(-400, 400)*0.75
            )

            particle:SetDieTime(math.Rand(0.5, 1.2)*50)

            particle:SetStartAlpha(80)
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(8, 15)*3)
            particle:SetEndSize(math.Rand(25, 50)*3)

            particle:SetColor(120, 0, 0)

            particle:SetGravity(Vector(0, 0, -200))
            particle:SetAirResistance(300)
        end
    end

    emitter:Finish()

    util.Decal(
        "Blood",
        self.Pos + self.Dir * 20,
        self.Pos - self.Dir * 80
    )

    self.DieTime = CurTime() + 0.1
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
end

effects.Register(EFFECT, "large_blood_squirt_om")