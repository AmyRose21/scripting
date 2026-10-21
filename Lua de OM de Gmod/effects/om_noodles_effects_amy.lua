local EFFECT = {}

EFFECT.Mat = Material("icons/star_and_shi_-_copia")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Ang = EyeAngles()

    self.StartTime = CurTime()

    self.Copies = {}

    local count = 9
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

            startRadius = radius * 0.25,
            endRadius = radius * 2,

            startSizex = 35,
            startSizey = 75*1.5,
            endSizex = 25,
            endSizey = 75,

            startangle = 180 + 45*0.3,
            endangle = 180 + 45*0.2,

            lifeTime = 0.45,
            startTime = CurTime()
        }
    end

    self.DieTime = CurTime() + 2

    local emitter = ParticleEmitter(self.Pos)
    if not emitter then return end

    for i = 1, 20 do
            
        local mat = Material("icons/star_1")
        if math.random(1, 2) == 1 then
            mat = Material("icons/star_2")
        end
        local particle = emitter:Add(mat, self.Pos)
        if particle then
            local dir = VectorRand() * math.Rand(300, 400)*0.6

            particle:SetVelocity(dir)
            particle:SetDieTime(math.Rand(0.65, 1.65))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(17,23))
            particle:SetEndSize(0)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-3, 3))
            if math.random(1, 2) == 1 then
                particle:SetColor(255, 215, 240)
            else
                particle:SetColor(255, 255, 255)
            end
            particle:SetGravity(Vector(0, 0, -math.random(25,50)))
            particle:SetAirResistance(50)
        end
    end

    emitter:Finish()

    local emitter = ParticleEmitter(self.Pos)
    for i = 1, 60 do
        local particle = emitter:Add("particle/particle_smokegrenade", self.Pos)
            
        if particle then
            local dir = VectorRand() * math.Rand(80, 200)

            particle:SetVelocity(dir)
            particle:SetDieTime(math.Rand(0.35, 1))
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)

            particle:SetStartSize(math.Rand(5, 12))
            particle:SetEndSize(math.Rand(0, 4))

            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-1, 1))

            particle:SetColor(255, 215, 240)

            particle:SetGravity(Vector(0, 0, 40))
            particle:SetAirResistance(120)
        end
    end

    emitter:Finish()
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
            Color(255, 215, 240, 255 * (1 - eased)),
            -copy.ang + RotationOffset
        )
    end
end

effects.Register(EFFECT, "Amy_hammerhit_new")