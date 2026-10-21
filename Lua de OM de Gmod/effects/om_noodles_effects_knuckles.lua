local EFFECT = {}

EFFECT.Mat = Material("icons/knuckles_punch")

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

            startRadius = radius * -0,
            endRadius = radius * 1.4,

            startSizex = 20,
            startSizey = 35,
            endSizex = 20,
            endSizey = 35,

            startangle = 180 + 45*0.1,
            endangle = 180 + 45*0.1,

            lifeTime = 0.8,
            startTime = CurTime(),
            color = (math.random(1,2) == 1) and Color(255,0,0) or Color(0,0,0)
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
            Color(copy.color.r, copy.color.g, copy.color.b, 255 * (1 - eased)),
            -copy.ang + RotationOffset
        )
    end
end

effects.Register(EFFECT, "Knuckles_punch_OM")




local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Life = 0
    self.MaxLife = 1.5

    local emitter = ParticleEmitter(self.Pos)

    local tr = util.TraceLine({
        start = self.Pos + Vector(0,0,20),
        endpos = self.Pos - Vector(0,0,50),
        mask = MASK_SOLID_BRUSHONLY + MASK_SOLID
    })
    if tr.Hit then
        util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
    end

    for i = 1, 70 do
        local ang = math.rad(math.random(0, 360))
        local dir = Vector(math.cos(ang), math.sin(ang), 0)
        local p = emitter:Add("particle/particle_smokegrenade", self.Pos + dir * 10)
        if p then
            p:SetVelocity(dir * math.random(400, 700) + Vector(0,0,80))
            p:SetDieTime(math.Rand(1.2, 2))
            p:SetStartAlpha(200)
            p:SetEndAlpha(0)
            p:SetStartSize(25)
            p:SetEndSize(80)
            p:SetColor(90, 90, 90)
            p:SetAirResistance(250)
            p:SetGravity(Vector(0,0,40))
        end
    end

    local dirtMats = {
        "effects/fleck_cement1",
        "effects/fleck_cement2",
        "effects/fleck_tile1",
        "effects/fleck_tile2",
    }

    for i = 1, 45 do
        local mat = dirtMats[math.random(#dirtMats)]
        local p = emitter:Add(mat, self.Pos + VectorRand()*5)
        if p then
            p:SetVelocity(VectorRand() * math.random(150, 300) + Vector(0,0,100))
            p:SetDieTime(math.Rand(0.6, 1.3))
            p:SetStartAlpha(255)
            p:SetEndAlpha(0)
            p:SetStartSize(3)
            p:SetEndSize(0)
            p:SetColor(110, 90, 70)
            p:SetGravity(Vector(0,0,-600))
            p:SetBounce(0.4)
        end
    end

    for i = 1, 15 do
        local rock = ents.CreateClientProp("models/props_debris/concrete_chunk05g.mdl")
        if IsValid(rock) then
            rock:SetPos(self.Pos + VectorRand() * 10)
            rock:SetAngles(AngleRand())
            rock:SetModelScale(math.Rand(0.6, 1), 0)
            rock:Spawn()
            rock:SetRenderMode(RENDERMODE_TRANSCOLOR)
            rock:SetColor(Color(255, 255, 255, 255))

            local phys = rock:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(VectorRand() * math.random(300, 600) + Vector(0,0,250))
                phys:AddAngleVelocity(VectorRand() * 400)
            end

            timer.Simple(2.5, function()
                if IsValid(rock) then rock:Remove() end
            end)
        end
    end

    self.RingRadius = 0
    self.RingMax = 600

    emitter:Finish()

    util.ScreenShake(self.Pos, 45, 220, 0.7, 1000)
end

function EFFECT:Think()
    self.Life = self.Life + FrameTime()

    self.RingRadius = math.min(self.RingRadius + FrameTime() * 1200, self.RingMax)

    return self.Life < self.MaxLife
end

function EFFECT:Render()
    local frac = self.Life / self.MaxLife
    local alpha = Lerp(frac, 200, 0)

    render.SetMaterial(Material("sprites/physbeam"))
    render.DrawQuadEasy(self.Pos, Vector(0,0,1), Lerp(frac, 60, 800), Lerp(frac, 60, 800), Color(220,220,220,alpha), 0)

    render.SetMaterial(Material("sprites/heatwave"))
    render.DrawQuadEasy(self.Pos, Vector(0,0,1), self.RingRadius, self.RingRadius, Color(255,255,255,alpha*0.6), 0)
end

effects.Register(EFFECT, "GroundCrash_OM")










local EFFECT = {}

function EFFECT:Init(data)

    self.Pos = data:GetOrigin()

    self.StartTime = CurTime()
    self.LifeTime = 0.6

    self.StartRadius = 2
    self.EndRadius = 35

    self.Width = 36

end

function EFFECT:Think()
    return CurTime() < self.StartTime + self.LifeTime
end

function EFFECT:Render()

    local frac = math.TimeFraction(
        self.StartTime,
        self.StartTime + self.LifeTime,
        CurTime()
    )

    frac = math.Clamp(frac,0,1)

    local radius = Lerp(frac,self.StartRadius,self.EndRadius)

    local alpha = (1-frac) * 255

    render.SetMaterial(Material("particles/flamelet5"))

    local view = EyeAngles()
    local right = view:Right()
    local up = view:Up()

    local segments = 64
    local rotation = -CurTime() * 360

    render.SetMaterial(Material("particles/flamelet5"))

    local view = EyeAngles()
    local right = view:Right()
    local up = view:Up()

    local segments = 72

    local rings = {
        {
            radius = radius,
            width = self.Width * (1 - frac),
            rotation = -CurTime() * 360,
            color = Color(255, 210, 120, alpha)
        },
        {
            radius = radius * 0.85,
            width = self.Width * 0.55 * (1 - frac),
            rotation = CurTime() * 220,
            color = Color(255, 140, 40, alpha * 0.8)
        },
        {
            radius = radius * 1.15,
            width = self.Width * 0.3 * (1 - frac),
            rotation = -CurTime() * 520,
            color = Color(255, 255, 180, alpha * 0.45)
        }
    }

    for _, ring in ipairs(rings) do

        for i = 0, segments - 1 do

            local a1 = math.rad((i / segments) * 360 + ring.rotation)
            local a2 = math.rad(((i + 1) / segments) * 360 + ring.rotation)

            local p1 =
                self.Pos +
                right * math.cos(a1) * ring.radius +
                up * math.sin(a1) * ring.radius

            local p2 =
                self.Pos +
                right * math.cos(a2) * ring.radius +
                up * math.sin(a2) * ring.radius

            render.DrawBeam(
                p1,
                p2,
                ring.width,
                i / segments,
                (i + 1) / segments,
                ring.color
            )

        end

    end

end

effects.Register(EFFECT, "Knuckles_firering")

local EFFECT = {}

function EFFECT:Init(data)

    self.Pos = data:GetOrigin()

    self.StartTime = CurTime()
    self.LifeTime = 0.75

    self.StartRadius = 35
    self.EndRadius = 0
    self.LifeTime = 0.9
    self.Rotations = 2

    self.Direction = math.random(0, 1) == 0 and -1 or 1
    self.StartAngle = math.Rand(0, 360)
end

function EFFECT:Think()
    return CurTime() < self.StartTime + self.LifeTime
end

function EFFECT:Render()

    local frac = math.Clamp(
        (CurTime() - self.StartTime) / self.LifeTime,
        0,
        1
    )

    local radius = Lerp(frac, self.StartRadius, self.EndRadius)

    local view = EyeAngles()
    local right = view:Right()
    local up = view:Up()

    local mainAngle = math.rad(
        self.StartAngle +
        frac * self.Rotations * 360 * self.Direction
    )

    local pos =
        self.Pos +
        right * math.cos(mainAngle) * radius +
        up * math.sin(mainAngle) * radius

    local alpha = (1 - frac) * 255


    render.SetMaterial(Material("particles/flamelet5"))

    local last = pos

    for i = 1, 25 do

        local t = frac - i * 0.025
        if t <= 0 then break end

        local trailRadius = Lerp(
            t,
            self.StartRadius,
            self.EndRadius
        )

        local trailAngle = math.rad(
            self.StartAngle +
            t * self.Rotations * 360 * self.Direction
        )

        local wave = math.sin(CurTime()*18 + i)*4

        local trailPos =
            self.Pos +
            right * math.cos(trailAngle) * (trailRadius + wave) +
            up * math.sin(trailAngle) * (trailRadius + wave)

        render.DrawBeam(
            last,
            trailPos,
            18 * (1-i/28),
            0,
            1,
            Color(
                255,
                120 + i*5,
                30,
                alpha * (1-i/25)
            )
        )

        last = trailPos

    end

    render.SetMaterial(Material("sprites/light_glow02_add"))

    local pulse = 1 + math.sin(CurTime()*20)*0.2

    render.DrawSprite(
        pos,
        60 * (1-frac) * pulse,
        60 * (1-frac) * pulse,
        Color(255,140,40,alpha*0.35)
    )


    render.DrawSprite(
        pos,
        35 * (1-frac),
        35 * (1-frac),
        Color(255,240,180,alpha)
    )

    for i = 1, 5 do

        local offset = math.rad(i*72 + CurTime()*250)

        local miniRadius = 10 * (1-frac)

        local flamePos =
            pos +
            right * math.cos(offset) * miniRadius +
            up * math.sin(offset) * miniRadius


        render.SetMaterial(Material("particles/flamelet5"))

        render.DrawSprite(
            flamePos,
            18*(1-frac),
            18*(1-frac),
            Color(
                255,
                170,
                50,
                alpha
            )
        )

    end

    render.SetMaterial(Material("effects/spark"))

    for i = 1, 8 do

        local a = math.rad(
            CurTime()*300 + i*45
        )

        local sparkPos =
            pos +
            right * math.cos(a) * math.Rand(15,30) +
            up * math.sin(a) * math.Rand(15,30)


        render.DrawSprite(
            sparkPos,
            4,
            4,
            Color(255,220,120,alpha)
        )

    end
end

effects.Register(EFFECT, "Knuckles_FireOrb")