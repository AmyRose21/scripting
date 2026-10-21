local EFFECT = {}

local shockwave = Material("icons/MightyTakeCover_shieldshockwave.png")
local sheild = Material("icons/MightyTakeCover_shield.png")

function EFFECT:Init(data)
    self.Entity = data:GetEntity()

    self.StartTime = CurTime()
    self.EndTime = self.StartTime + 0.5

    self:SetRenderBounds(
        Vector(-1000, -1000, -1000),
        Vector(1000, 1000, 1000)
    )
end

function EFFECT:Think()
    if CurTime() >= self.EndTime then
        return false
    end

    return true
end

function EFFECT:Render()
    if IsValid(self.Entity) then
        local progress = math.TimeFraction(self.StartTime,self.EndTime,CurTime())

        local eased = math.ease.OutCubic(progress)
        local alpha = 255 * (1 - progress)

        local pos = self.Entity:WorldSpaceCenter()
        local campos = EyePos()
        local eyeangles = (campos - pos):Angle()

        render.SetMaterial(sheild)
        render.DrawSprite(
            pos+eyeangles:Forward()*40,
            75,
            75,
            Color(255, 255, 255, alpha)
        )

        local shockwaveSize = Lerp(eased,50,165)
        render.SetMaterial(shockwave)
        render.DrawSprite(
            pos,
            shockwaveSize,
            shockwaveSize,
            Color(255, 255, 255, alpha)
        )
    end
end

effects.Register(EFFECT, "mighty_shield_activate")

local EFFECT = {}

local sheild = Material("icons/MightyTakeCover_shield.png")

function EFFECT:Init(data)
    self.Entity = data:GetEntity()

    self.StartTime = CurTime()
    self.EndTime = self.StartTime + 0.35

    self:SetRenderBounds(
        Vector(-1000, -1000, -1000),
        Vector(1000, 1000, 1000)
    )
end

function EFFECT:Think()
    if CurTime() >= self.EndTime then
        return false
    end

    return true
end

function EFFECT:Render()
    if IsValid(self.Entity) then
        local progress = math.TimeFraction(self.StartTime,self.EndTime,CurTime())

        local eased = math.ease.OutCubic(progress)
        local alpha = 255 * (1 - progress)

        local pos = self.Entity:WorldSpaceCenter()
        local campos = EyePos()
        local eyeangles = (campos - pos):Angle()

        render.SetMaterial(sheild)
        render.DrawSprite(
            pos+eyeangles:Forward()*40,
            75,
            75,
            Color(255, 255, 255, alpha)
        )
    end
end

effects.Register(EFFECT, "mighty_shield_hit")



local EFFECT = {}
local burst = Material("icons/MightyTakeCover_burst.png")
local pop = Material("icons/MightyTakeCover_pop.png")

function EFFECT:Init(data)
    self.Entity = data:GetEntity()

    self.StartTime = CurTime()
    self.EndTime = self.StartTime + 0.5

    self:SetRenderBounds(
        Vector(-2048, -2048, -2048),
        Vector(2048, 2048, 2048)
    )

    if IsValid(self.Entity) then
        self:SetPos(self.Entity:WorldSpaceCenter())
    else
        self:SetPos(data:GetOrigin())
    end

    self.Pops = {}

    for i = 1, 25 do
        local direction = VectorRand()
        direction:Normalize()

        self.Pops[i] = {
            direction = direction,
            speed = math.Rand(100, 250)*0.5,
            size = math.Rand(8, 18),
            rotation = math.Rand(0, 360),
            rotationSpeed = math.Rand(-180, 180)
        }
    end
end

function EFFECT:Think()
    if !IsValid(self.Entity) then return false end
    return CurTime() < self.EndTime
end

function EFFECT:Render()
    if IsValid(self.Entity) then
        local curTime = CurTime()
        local progress = math.TimeFraction( self.StartTime, self.EndTime, curTime )

        progress = math.Clamp(progress, 0, 1)

        local alpha = 255 * (1 - progress)
        local pos, eyePos = self.Entity:WorldSpaceCenter(), EyePos()
        local ang = (eyePos - pos):Angle()

        ang:RotateAroundAxis(ang:Up(), 90)
        ang:RotateAroundAxis(ang:Forward(), 90)

        local time = curTime - self.StartTime

        local frame = math.floor(time * 30)

        frame = math.Clamp(frame, 0, 11 - 1)

        local column = frame % 4
        local row = math.floor(frame / 4)

        local u1 = column * 0.25
        local v1 = row * 0.25

        local u2 = u1 + 0.25
        local v2 = v1 + 0.25

        local burstSize = Lerp(progress, 65, 150)

        cam.Start3D2D(pos, ang, 1)
            surface.SetMaterial(burst)
            surface.SetDrawColor(255,255,255,alpha)

            surface.DrawTexturedRectUV(-burstSize / 2, -burstSize / 2, burstSize, burstSize, u1, v1, u2, v2)
            surface.DrawTexturedRectUV(-burstSize / 2, -burstSize / 2, burstSize, burstSize, u1, v1, u2, v2)

        cam.End3D2D()

        for _, p in ipairs(self.Pops) do
            local popProgress = math.Clamp(progress * 1.5, 0, 1)
            local distance = p.speed * popProgress
            local popPos = pos + p.direction * distance
            local popAlpha = 255 * (1 - popProgress)
            local popSize = Lerp(popProgress, p.size * 0.5, p.size)

            local popAng = (eyePos - popPos):Angle()

            popAng:RotateAroundAxis(popAng:Up(), 90)
            popAng:RotateAroundAxis(popAng:Forward(), 90)

            cam.Start3D2D(popPos, popAng, 1)
                surface.SetMaterial(pop)
                surface.SetDrawColor(255,255,255,popAlpha)

                surface.DrawTexturedRectRotated(
                    -popSize / 2,
                    -popSize / 2,
                    popSize,
                    popSize,
                    p.rotation + p.rotationSpeed * time
                )
            cam.End3D2D()
        end
    end
end

effects.Register(EFFECT, "mighty_shield_break")











local EFFECT = {}

local dustMat = Material("particle/smokesprites_0001")
local debrisMat1 = Material("effects/fleck_cement1")
local debrisMat2 = Material("effects/fleck_cement2")
local ringMat = Material("effects/select_ring")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Normal = data:GetNormal() or Vector(0,0,1)

    self.DieTime = CurTime() + 0.5
    self.StartTime = CurTime()

    local emitter = ParticleEmitter(self.Pos)

    for i = 1, 30 do
        local p = emitter:Add(dustMat, self.Pos + VectorRand() * 5)
        if p then
            local dir = VectorRand()
            dir.z = math.abs(dir.z) * 1.2

            p:SetVelocity(dir * math.Rand(120, 260))
            p:SetDieTime(math.Rand(0.7, 1.2))

            p:SetStartAlpha(200)
            p:SetEndAlpha(0)

            p:SetStartSize(math.Rand(12, 25))
            p:SetEndSize(math.Rand(50, 80))

            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-3, 3))

            p:SetColor(110, 100, 95)
            p:SetGravity(Vector(0, 0, -700))
            p:SetAirResistance(70)
        end
    end

    for i = 1, 8 do
        local mat = (math.random(1,2) == 1 and debrisMat1 or debrisMat2)

        local p = emitter:Add(mat, self.Pos)
        if p then
            local dir = VectorRand()
            dir.z = math.abs(dir.z) * 1.4

            p:SetVelocity(dir * math.Rand(180, 420))
            p:SetDieTime(math.Rand(0.9, 1.4))

            p:SetStartAlpha(255)
            p:SetEndAlpha(0)

            p:SetStartSize(math.Rand(2, 4))
            p:SetEndSize(0)

            p:SetRoll(math.Rand(0, 360))
            p:SetRollDelta(math.Rand(-6, 6))

            p:SetGravity(Vector(0, 0, -1000))
            p:SetAirResistance(50)
        end
    end

    emitter:Finish()

    util.ScreenShake(self.Pos, 5, 90, 0.5, 500)

    sound.Play("physics/concrete/boulder_impact_hard2.wav", self.Pos, 85, 100)
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local life = (self.DieTime - CurTime()) / 0.5

    if life > 0 then
        render.SetMaterial(ringMat)

        local size = (1 - life) * 320
        local alpha = 200 * life

        render.DrawQuadEasy(
            self.Pos + Vector(0,0,2),
            Vector(0,0,1),
            size,
            size,
            Color(255, 255, 255, alpha),
            0
        )
    end
end

effects.Register(EFFECT, "Mighty_rockgrab")