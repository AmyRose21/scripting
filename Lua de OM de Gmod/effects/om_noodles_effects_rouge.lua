local EFFECT = {}

local SmokeMat = Material("particle/smokesprites_0001")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()

    self.Emitter = ParticleEmitter(self.Pos)

    if not self.Emitter then return end

    for i = 1, 1500 do
        local dir = VectorRand():GetNormalized()

        dir.z = dir.z + math.Rand(0.2, 0.8)
        dir:Normalize()

        local particle = self.Emitter:Add(SmokeMat, self.Pos)

        if particle then
            local vel = dir * math.Rand(0, 5000)
            vel.z = math.random(0, 1000)

            particle:SetVelocity(vel)

            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(30, 40))

            local size = math.Rand(80, 180)
            particle:SetStartSize(size)
            particle:SetEndSize(size * 2.5)

            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)

            particle:SetRoll(math.Rand(0,360))
            particle:SetRollDelta(math.Rand(-2,2))

            particle:SetAirResistance(120)

            particle:SetGravity(Vector(0,0,0))

            particle:SetCollide(true)
        end
    end

    self.Emitter:Finish()
end


function EFFECT:Think()
    return false
end


function EFFECT:Render()
end

effects.Register(EFFECT, "om_rouge_smokeburst")










local EFFECT = {}

local BeamMat = Material("trails/laser")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.DieTime = CurTime() + 0.5

    self.Radius = 60
    self.BeamDirs = {}

    self.Emitter = ParticleEmitter(self.Pos)
    if not self.Emitter then return end

    for i = 1, 120 do
        local dir = VectorRand():GetNormalized()
        self.BeamDirs[i] = dir

        local startPos = self.Pos + dir * math.Rand(self.Radius * 0.6, self.Radius)

        local p = self.Emitter:Add("effects/yellowflare", startPos)
        if p then
            p:SetVelocity((self.Pos - startPos):GetNormalized() * math.Rand(900, 1800))
            p:SetLifeTime(0)
            p:SetDieTime(math.Rand(0.2, 0.45))

            p:SetStartAlpha(255)
            p:SetEndAlpha(0)

            p:SetStartSize(math.Rand(2, 4))
            p:SetEndSize(0)

            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-20, 20))

            p:SetColor(255, 255, 255)
            p:SetAirResistance(0)
            p:SetGravity(vector_origin)
            p:SetCollide(false)
        end
    end

    self.Emitter:Finish()
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    render.SetMaterial(BeamMat)

    local t = math.Clamp((self.DieTime - CurTime()) / 0.5, 0, 1)

    for _, dir in ipairs(self.BeamDirs) do
        local startPos = self.Pos + dir * (self.Radius * t)

        render.DrawBeam(
            startPos,
            self.Pos,
            2,
            0,
            1,
            Color(255, 255, 255, 255 * t)
        )
    end
end

effects.Register(EFFECT, "om_rouge_smokebombhold")








local EFFECT = {}

local GlowMat = Material("sprites/light_glow02_add")
local RingMat = Material("effects/select_ring")
local SmokeMat = Material("particle/smokesprites_0001")
local SparkMat = Material("effects/spark")

function EFFECT:Init(data)

    self.Pos = data:GetOrigin()
    self.StartTime = CurTime()

    self.Duration = 2.5


    local dlight = DynamicLight(self:EntIndex())

    if dlight then
        dlight.pos = self.Pos
        dlight.r = 255
        dlight.g = 255
        dlight.b = 255
        dlight.brightness = 20
        dlight.Decay = 3000
        dlight.Size = 1500
        dlight.DieTime = CurTime() + 0.6
    end


    local emitter = ParticleEmitter(self.Pos)

    if emitter then

        for i = 1, 180 do

            local dir = VectorRand()
            dir.z = math.abs(dir.z)

            local p = emitter:Add(SparkMat, self.Pos)

            if p then

                p:SetVelocity(dir * math.Rand(400,1600))

                p:SetDieTime(math.Rand(0.4,1.2))

                p:SetStartAlpha(255)
                p:SetEndAlpha(0)

                p:SetStartSize(math.Rand(5,14))
                p:SetEndSize(0)

                p:SetRoll(math.Rand(0,360))
                p:SetRollDelta(math.Rand(-8,8))

                p:SetColor(255,255,255)

                p:SetAirResistance(80)
                p:SetGravity(Vector(0,0,-500))
            end
        end


        for i = 1,120 do

            local p = emitter:Add(SmokeMat,self.Pos)

            if p then

                p:SetVelocity(VectorRand()*math.Rand(100,500))

                p:SetDieTime(math.Rand(1,3))

                p:SetStartAlpha(200)
                p:SetEndAlpha(0)

                p:SetStartSize(math.Rand(80,160))
                p:SetEndSize(math.Rand(300,600))

                p:SetRoll(math.Rand(0,360))
                p:SetRollDelta(math.Rand(-3,3))

                p:SetColor(255,255,255)

                p:SetAirResistance(100)
            end
        end


        for i = 1,80 do

            local p = emitter:Add(GlowMat,self.Pos)

            if p then

                p:SetVelocity(VectorRand()*math.Rand(200,900))

                p:SetDieTime(math.Rand(.2,.8))

                p:SetStartAlpha(255)
                p:SetEndAlpha(0)

                p:SetStartSize(math.Rand(20,50))
                p:SetEndSize(0)

                p:SetColor(255,255,255)
            end
        end


        emitter:Finish()
    end
end



function EFFECT:Think()

    return CurTime() < self.StartTime + self.Duration

end



function EFFECT:Render()

    local delta = CurTime()-self.StartTime

    local frac = math.Clamp(delta/self.Duration,0,1)


    local power = 1-(frac*frac)


    render.SetMaterial(GlowMat)

    render.DrawSprite(
        self.Pos,
        Lerp(frac,150,1200),
        Lerp(frac,150,1200),
        Color(255,255,255,255*power)
    )


    render.SetMaterial(RingMat)

    cam.Start3D2D(
        self.Pos,
        Angle(0, LocalPlayer():EyeAngles().y - 90, 90),
        1
    )

    surface.SetDrawColor(255, 255, 255, 255 * power)
    surface.SetMaterial(RingMat)

    local size = 700
    surface.DrawTexturedRect(
        -size * power / 2,
        -size * power / 2,
        size * power,
        size * power
    )

    cam.End3D2D()


    if frac < 0.25 then

        local pulse = math.sin(CurTime()*30)*50+200

        render.DrawSprite(
            self.Pos,
            500,
            500,
            Color(255,255,255,pulse)
        )

    end

end


effects.Register(EFFECT,"om_rouge_flash")