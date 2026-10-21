
local EFFECT = {}
local burst = Material("icons/RayTakeCover_burst.png")
local pop = Material("icons/Raypoisondebuff_om.png")

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
            surface.SetDrawColor(175,255,175,alpha)

            surface.DrawTexturedRectUV(-burstSize / 2, -burstSize / 2, burstSize, burstSize, u1, v1, u2, v2)
            surface.DrawTexturedRectUV(-burstSize / 2, -burstSize / 2, burstSize, burstSize, u1, v1, u2, v2)

            surface.SetMaterial(pop)
            surface.SetDrawColor(175,255,175,alpha)

            surface.DrawTexturedRectUV(-burstSize / 2, -burstSize / 2, burstSize, burstSize, u1, v1, u2, v2)
            surface.DrawTexturedRectUV(-burstSize / 2, -burstSize / 2, burstSize, burstSize, u1, v1, u2, v2)
        cam.End3D2D()
    end
end

effects.Register(EFFECT, "ray_poison_explode")






local EFFECT = {}

local ray_tornado_wind1 = Material("icons/ray_tornado_wind1.png")
local ray_tornado_wind2 = Material("icons/ray_tornado_wind2.png")
local ray_tornado_wind3 = Material("icons/ray_tornado_wind3.png")
local ray_tornado_wind4 = Material("icons/ray_tornado_wind4.png")
local ray_tornado_smoke = Material("particle/particle_smokegrenade")

function EFFECT:Init(data)
    self.Entity = data:GetEntity()

    self:SetRenderBounds(
        Vector(-2048, -2048, -2048),
        Vector(2048, 2048, 2048)
    )

    if IsValid(self.Entity) then
        self:SetPos(self.Entity:WorldSpaceCenter())
    else
        self:SetPos(data:GetOrigin())
    end

    self.StartTime = CurTime()
    self.EndTime = CurTime() + 5

    self.Particles1 = {}
    self.Particles2 = {}
    self.Particles3 = {}
    self.Particles4 = {}
    self.SmokeParticles = {}
    self.GroundSmokeParticles = {}

    self.NextParticle1 = CurTime()
    self.NextParticle2 = CurTime()
    self.NextParticle3 = CurTime()
    self.NextParticle4 = CurTime()
    self.NextSmoke = CurTime()
    self.NextGroundSmoke = CurTime()
end

function EFFECT:Think()
    if not IsValid(self.Entity) then return false end

    self:SetPos(self.Entity:WorldSpaceCenter())

    if CurTime() >= self.NextParticle1 and CurTime() < self.EndTime then
        self.NextParticle1 = CurTime() + 0.01

        table.insert(self.Particles1, {
            startTime = CurTime(),
            dieTime = CurTime() + math.Rand(1, 2),
            size = math.Rand(20, 40),
            sizeSpeed = math.Rand(15, 25),
            heightSpeed = math.Rand(20, 40),
            radiusSpeed = math.Rand(20, 35),
            maxRadius = math.Rand(50, 85) * 2,
            angleOffset = math.Rand(0, math.pi * 2),
            spinSpeed = math.Rand(9, 14)
        })
    end

    if CurTime() >= self.NextParticle2 and CurTime() < self.EndTime then
        self.NextParticle2 = CurTime() + 0.02

        table.insert(self.Particles2, {
            startTime = CurTime(),
            dieTime = CurTime() + math.Rand(1, 2),
            size = math.Rand(20, 40),
            sizeSpeed = math.Rand(15, 25),
            heightSpeed = math.Rand(20, 40),
            radiusSpeed = math.Rand(20, 35),
            maxRadius = math.Rand(50, 85) * 1.2,
            angleOffset = math.Rand(0, math.pi * 2),
            spinSpeed = math.Rand(9, 14)
        })
    end

    if CurTime() >= self.NextParticle3 and CurTime() < self.EndTime then
        self.NextParticle3 = CurTime() + 0.02

        table.insert(self.Particles3, {
            startTime = CurTime(),
            dieTime = CurTime() + math.Rand(1, 2),
            size = math.Rand(20, 40),
            sizeSpeed = math.Rand(15, 25) * 3,
            maxRadius = math.Rand(50, 85) * 1.2,
            angleOffset = math.Rand(0, math.pi * 2),
            spinSpeed = math.Rand(9, 14)
        })
    end

    if CurTime() >= self.NextParticle4 and CurTime() < self.EndTime then
        self.NextParticle4 = CurTime() + 0.01

        table.insert(self.Particles4, {
            startTime = CurTime(),
            dieTime = CurTime() + math.Rand(1, 2),
            size = math.Rand(20, 40),
            sizeSpeed = math.Rand(15, 25) * 3,
            heightSpeed = math.Rand(20, 40),
            radiusSpeed = math.Rand(20, 35),
            maxRadius = math.Rand(50, 85) * 1.2,
            angleOffset = math.Rand(0, math.pi * 2),
            spinSpeed = math.Rand(9, 14)
        })
    end

    if CurTime() >= self.NextSmoke and CurTime() < self.EndTime then
        self.NextSmoke = CurTime() + 0.025

        table.insert(self.SmokeParticles, {
            startTime = CurTime(),
            dieTime = CurTime() + math.Rand(1.5, 2.5),
            size = math.Rand(30, 60),
            sizeSpeed = math.Rand(20, 40),
            heightSpeed = math.Rand(25, 45),
            radiusSpeed = math.Rand(15, 30),
            maxRadius = math.Rand(80, 130),
            angleOffset = math.Rand(0, math.pi * 2),
            spinSpeed = math.Rand(5, 9),
            drift = math.Rand(-12, 12)
        })
    end

    if CurTime() >= self.NextGroundSmoke and CurTime() < self.EndTime then
        self.NextGroundSmoke = CurTime() + 0.015

        table.insert(self.GroundSmokeParticles, {
            startTime = CurTime(),
            dieTime = CurTime() + math.Rand(1.2, 2.2),
            size = math.Rand(35, 70),
            sizeSpeed = math.Rand(25, 55),
            heightSpeed = math.Rand(8, 20),
            radiusSpeed = math.Rand(20, 45),
            maxRadius = math.Rand(100, 180),
            angleOffset = math.Rand(0, math.pi * 2),
            spinSpeed = math.Rand(3, 7),
            startRadius = math.Rand(0, 35),
            rotation = math.Rand(-1, 1)
        })
    end

    return CurTime() < self.EndTime
        or #self.Particles1 > 0
        or #self.Particles2 > 0
        or #self.Particles3 > 0
        or #self.Particles4 > 0
        or #self.SmokeParticles > 0
        or #self.GroundSmokeParticles > 0
end

function EFFECT:Render()
    if not IsValid(self.Entity) then return end

    local center = self.Entity:WorldSpaceCenter()
    local ground = center - Vector(0, 0, 20)
    local fadeTime = 0.4

    render.SetMaterial(ray_tornado_wind1)

    for i = #self.Particles1, 1, -1 do
        local particle = self.Particles1[i]

        if CurTime() >= particle.dieTime then
            table.remove(self.Particles1, i)
            continue
        end

        local particleTime = CurTime() - particle.startTime

        local size = math.min(
            particle.size + particleTime * particle.sizeSpeed,
            200
        ) * 2

        local height = math.min(
            particleTime * particle.heightSpeed,
            50
        )

        local radius = math.min(
            particleTime * particle.radiusSpeed,
            particle.maxRadius
        ) * 1.6

        local angle = particle.angleOffset + particleTime * particle.spinSpeed

        local fade = math.min(
            (particle.dieTime - CurTime()) / fadeTime,
            1
        )

        local pos = center + Vector(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
            height
        ) - Vector(0, 0, 20)

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, 1),
            size,
            size,
            Color(255, 255, 255, 255 * fade),
            math.deg(angle) + 90
        )

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, -1),
            size,
            size,
            Color(255, 255, 255, 255 * fade),
            math.deg(angle) * -1 - 90
        )
    end

    render.SetMaterial(ray_tornado_wind2)

    for i = #self.Particles2, 1, -1 do
        local particle = self.Particles2[i]

        if CurTime() >= particle.dieTime then
            table.remove(self.Particles2, i)
            continue
        end

        local particleTime = CurTime() - particle.startTime

        local size = math.min(
            particle.size + particleTime * particle.sizeSpeed,
            200
        ) * 1.6

        local height = math.min(
            particleTime * particle.heightSpeed,
            100
        )

        local angle = particle.angleOffset + particleTime * particle.spinSpeed

        local fade = math.min(
            (particle.dieTime - CurTime()) / fadeTime,
            1
        )

        local pos = center + Vector(
            0,
            0,
            height
        ) - Vector(0, 0, 20)

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, 1),
            size,
            size,
            Color(255, 255, 255, 255 * fade),
            math.deg(angle) + 90
        )

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, -1),
            size,
            size,
            Color(255, 255, 255, 255 * fade),
            math.deg(angle) * -1 - 90
        )
    end

    render.SetMaterial(ray_tornado_wind3)

    for i = #self.Particles3, 1, -1 do
        local particle = self.Particles3[i]

        if CurTime() >= particle.dieTime then
            table.remove(self.Particles3, i)
            continue
        end

        local particleTime = CurTime() - particle.startTime

        local size = math.min(
            particle.size + particleTime * particle.sizeSpeed,
            700
        ) * 1.6

        local angle = particle.angleOffset + particleTime * particle.spinSpeed

        local fade = math.min(
            (particle.dieTime - CurTime()) / fadeTime,
            1
        )

        local pos = center - Vector(0, 0, 20)

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, 1),
            size,
            size,
            Color(255, 255, 255, 255 * 0.5 * fade),
            math.deg(angle) + 90
        )

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, -1),
            size,
            size,
            Color(255, 255, 255, 255 * 0.5 * fade),
            math.deg(angle) * -1 - 90
        )
    end

    render.SetMaterial(ray_tornado_wind4)

    for i = #self.Particles4, 1, -1 do
        local particle = self.Particles4[i]

        if CurTime() >= particle.dieTime then
            table.remove(self.Particles4, i)
            continue
        end

        local particleTime = CurTime() - particle.startTime

        local size = math.min(
            particle.size + particleTime * particle.sizeSpeed,
            700
        ) * 1.6

        local height = math.min(
            particleTime * particle.heightSpeed,
            5
        )

        local angle = particle.angleOffset + particleTime * particle.spinSpeed

        local fade = math.min(
            (particle.dieTime - CurTime()) / fadeTime,
            1
        )

        local pos = center + Vector(
            0,
            0,
            height
        ) - Vector(0, 0, 20)

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, 1),
            size,
            size,
            Color(255, 255, 255, 255 * 0.5 * fade),
            math.deg(angle) + 90
        )

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, -1),
            size,
            size,
            Color(255, 255, 255, 255 * 0.5 * fade),
            math.deg(angle) * -1 - 90
        )
    end

    render.SetMaterial(ray_tornado_smoke)

    for i = #self.SmokeParticles, 1, -1 do
        local particle = self.SmokeParticles[i]

        if CurTime() >= particle.dieTime then
            table.remove(self.SmokeParticles, i)
            continue
        end

        local particleTime = CurTime() - particle.startTime

        local size = math.min(
            particle.size + particleTime * particle.sizeSpeed,
            180
        ) * 1.6

        local height = math.min(
            particleTime * particle.heightSpeed,
            100
        )

        local radius = math.min(
            particleTime * particle.radiusSpeed,
            particle.maxRadius
        ) * 2

        local angle = particle.angleOffset + particleTime * particle.spinSpeed

        local fade = math.min(
            (particle.dieTime - CurTime()) / 0.6,
            1
        )

        local pos = center + Vector(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
            height
        ) - Vector(0, 0, 20)

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, 1),
            size,
            size,
            Color(180, 180, 180, 70 * fade),
            math.deg(angle)
        )

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, -1),
            size,
            size,
            Color(180, 180, 180, 70 * fade),
            math.deg(angle) * -1
        )
    end

    render.SetMaterial(ray_tornado_smoke)

    for i = #self.GroundSmokeParticles, 1, -1 do
        local particle = self.GroundSmokeParticles[i]

        if CurTime() >= particle.dieTime then
            table.remove(self.GroundSmokeParticles, i)
            continue
        end

        local particleTime = CurTime() - particle.startTime

        local size = math.min(
            particle.size + particleTime * particle.sizeSpeed,
            220
        )

        local radius = math.min(
            particle.startRadius + particleTime * particle.radiusSpeed,
            particle.maxRadius
        ) * 2

        local angle = particle.angleOffset + particleTime * particle.spinSpeed

        local height = math.min(
            particleTime * particle.heightSpeed,
            35
        )

        local fade = math.min(
            (particle.dieTime - CurTime()) / 0.7,
            1
        )

        local pos = ground + Vector(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
            height
        )

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, 1),
            size,
            size,
            Color(150, 150, 150, 90 * fade),
            math.deg(angle)
        )

        render.DrawQuadEasy(
            pos,
            Vector(0, 0, -1),
            size,
            size,
            Color(150, 150, 150, 90 * fade),
            math.deg(angle) * -1
        )
    end
end

effects.Register(EFFECT, "ray_tornado_effect")