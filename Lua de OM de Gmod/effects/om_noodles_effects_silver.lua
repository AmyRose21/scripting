local EFFECT = {}

function EFFECT:Init(data)
    self.Ent  = data:GetEntity()
    self.Life = CurTime() + 0.25

    if not IsValid(self.Ent) then return end

    self.mat = Material("sprites/physbeam")

    self.Points = {}
    for i = 1, 8 do
        self.Points[i] = {
            t    = CurTime(),
            off  = VectorRand() * math.Rand(4, 10),
            life = math.Rand(0.08, 0.18)
        }
    end

    self.Sparks = {}
    for i = 1, 3 do
        self.Sparks[i] = {
            t    = CurTime(),
            off  = VectorRand() * math.Rand(1, 3),
            life = math.Rand(0.02, 0.05)
        }
    end
end


function EFFECT:Think()
    if not IsValid(self.Ent) or not self.Ent:LookupBone("LeftHand") then return false end
    return CurTime() < self.Life
end


function EFFECT:Render()
    if not IsValid(self.Ent) then return end

    local boneIndex = self.Ent:LookupBone("LeftHand")
    if boneIndex then
        local matrix = self.Ent:GetBoneMatrix(boneIndex)
        if matrix then

            local basePos = matrix:GetTranslation()
            local ang = matrix:GetAngles()

            local pos = basePos + ang:Right()*-4

            render.SetMaterial(self.mat)

            for _, bolt in ipairs(self.Points) do
                local age = CurTime() - bolt.t
                if age > bolt.life then continue end

                local strength = 1 - age / bolt.life
                local wobble = ang:Forward() * math.sin(CurTime() * 50 + _) * 1.5

                local endPos = pos + bolt.off * (1.0 + strength) + wobble

                render.DrawBeam(
                    pos,
                    endPos,
                    5 * strength,
                    0,
                    1,
                    Color(75, 200 + 55 * strength, 255, 255 * strength)
                )
            end

            for _, sp in ipairs(self.Sparks) do
                local age = CurTime() - sp.t
                if age > sp.life then continue end

                local strength = 1 - age / sp.life
                local endPos = pos + sp.off * 0.5

                render.DrawBeam(
                    pos,
                    endPos,
                    2 * strength,
                    0,
                    1,
                    Color(255, 255, 150, 150 * strength)
                )
            end
        end
    end

    local boneIndex = self.Ent:LookupBone("RightHand")
    if boneIndex then
        local matrix = self.Ent:GetBoneMatrix(boneIndex)
        if matrix then

            local basePos = matrix:GetTranslation()
            local ang = matrix:GetAngles()

            local pos = basePos + ang:Right()*-4

            render.SetMaterial(self.mat)

            for _, bolt in ipairs(self.Points) do
                local age = CurTime() - bolt.t
                if age > bolt.life then continue end

                local strength = 1 - age / bolt.life
                local wobble = ang:Forward() * math.sin(CurTime() * 50 + _) * 1.5

                local endPos = pos + bolt.off * (1.0 + strength) + wobble

                render.DrawBeam(
                    pos,
                    endPos,
                    5 * strength,
                    0,
                    1,
                    Color(75, 200 + 55 * strength, 255, 255 * strength)
                )
            end

            for _, sp in ipairs(self.Sparks) do
                local age = CurTime() - sp.t
                if age > sp.life then continue end

                local strength = 1 - age / sp.life
                local endPos = pos + sp.off * 0.5

                render.DrawBeam(
                    pos,
                    endPos,
                    2 * strength,
                    0,
                    1,
                    Color(255, 255, 150, 150 * strength)
                )
            end
        end
    end
end

effects.Register(EFFECT, "electric_hand_emitting_SILVER")


local EFFECT = {}

local mat3 = Material("icons/silver rock throw ground silver.png")
function EFFECT:Init(data)
    self.Player = data:GetEntity()
    if not IsValid(self.Player) then return end

    self.Life = 0
    self.MaxLife = 0.35
    self.Size = 40
    self.MaxSize = 120

    self.RotZ = 75
    self.RotSpeedZ = 75

    self.Mat = mat3
end

function EFFECT:Think()
    if not IsValid(self.Player) then return false end

    self.Life = self.Life + FrameTime()
    self.RotZ = self.RotZ + self.RotSpeedZ * FrameTime()

    return self.Life < self.MaxLife
end

function EFFECT:Render()
    if not IsValid(self.Player) then return end

    local pos = self.Player:GetPos() + Vector(0,0,50)

    local frac = self.Life / self.MaxLife
    local size = Lerp(frac, self.Size, self.MaxSize)

    local alpha = 255
    if frac > 0.75 then
        alpha = 255 * (1 - (frac - 0.75) / 0.25)
    end

    local viewAng = EyeAngles()
    local normal = -viewAng:Forward()

    render.SetMaterial(self.Mat)
    self.RotZ = self.RotZ + self.RotSpeedZ * FrameTime()

    render.DrawQuadEasy(pos, normal, size, size, Color(255,255,255,alpha), self.RotZ)

end


effects.Register(EFFECT, "silver_rockthrow_circle")

local EFFECT = {}

local mat2 = Material("icons/silver rock throw ground silver surround.png", "smooth")

function EFFECT:Init(data)
    self.Entity = data:GetEntity()
    if not IsValid(self.Entity) then return end

    self.Pos = self.Entity:GetPos()
    self.DieTime = CurTime() + 1

    self.Particles = {}

    local count = 25
    local forward = self.Entity:GetUp()
    forward:Normalize()

    local count = 25

    local right = self.Entity:GetRight()

    for i = 1, count do
        local sideAmount = math.Rand(-1, 1)
        local side = right * sideAmount
        local dir = (side + Vector(0, 0, 1)):GetNormalized()

        table.insert(self.Particles, {
            pos = self.Pos + Vector(0, 0, 15),
            vel = dir * math.Rand(200, 350),
            size = math.Rand(18, 30),
            startSize = math.Rand(18, 30),
            alpha = 255,
            rot = math.Rand(0, 360),
            rotSpeed = math.Rand(-180, 180)
        })
    end

end

function EFFECT:Think()
    if CurTime() > self.DieTime then return false end

    local ft = FrameTime()

    for _, p in ipairs(self.Particles) do
        p.pos = p.pos + p.vel * ft
        p.size = math.max(0, p.size - 45 * ft)
        p.alpha = math.max(0, p.alpha - 350 * ft)
        p.rot = p.rot + p.rotSpeed * ft
    end

    return true
end



function EFFECT:Render()
    render.SetMaterial(mat2)

    for _, p in ipairs(self.Particles) do
        render.DrawSprite(
            p.pos,
            p.size,
            p.size,
            Color(255, 255, 255, p.alpha)
        )
    end
end

effects.Register(EFFECT, "silver_rock_spray")

local EFFECT = {}

local mat = Material("icons/silver suspension romb.png", "smooth")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.StartTime = CurTime()
    self.LifeTime = 0.25
    self.LifeTime2 = 0.35

    self.StartSize = 100
    self.EndSize = 150
end

function EFFECT:Think()
    return CurTime() < (self.StartTime + self.LifeTime2)
end

function EFFECT:Render()
    local progress = (CurTime() - self.StartTime) / self.LifeTime
    progress = math.Clamp(progress, 0, 1)

    local size = Lerp(progress, self.StartSize, self.EndSize)
    local alpha = 255 * (1 - progress)

    render.SetMaterial(mat)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))

    local progress = (CurTime() - self.StartTime) / self.LifeTime2
    progress = math.Clamp(progress, 0, 1)

    local size = Lerp(progress, 65, 299)
    local alpha = 255 * (1 - progress)

    render.SetMaterial(mat3)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "silver_suspension_spawn_eff")


local EFFECT = {}

local mat = Material("icons/silver suspension romb.png", "smooth")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.StartTime = CurTime()
    self.LifeTime = 0.35
    self.LifeTime2 = 0.25

    self.StartSize = 100*0.25
    self.EndSize = 115
end

function EFFECT:Think()
    return CurTime() < (self.StartTime + self.LifeTime2)
end

function EFFECT:Render()
    local progress = (CurTime() - self.StartTime) / self.LifeTime
    progress = math.Clamp(progress, 0, 1)

    local size = Lerp(progress, self.StartSize, self.EndSize)
    local alpha = 255 * (1 - progress)

    render.SetMaterial(mat)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))

    local progress = (CurTime() - self.StartTime) / self.LifeTime2
    progress = math.Clamp(progress, 0, 1)

    local size = Lerp(progress, 65*0.25, 169)
    local alpha = 255 * (1 - progress)

    render.SetMaterial(mat3)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "silver_suspension_spawn_eff_smaller")


local EFFECT = {}

local mat = Material("icons/silver suspension thing remake.png", "smooth")

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.StartTime = CurTime()
    self.LifeTime = 0.25
    self.LifeTime2 = 0.35

    self.StartSize = 1
    self.EndSize = 115
end

function EFFECT:Think()
    return CurTime() < (self.StartTime + self.LifeTime2)
end

function EFFECT:Render()
    local progress = (CurTime() - self.StartTime) / self.LifeTime
    progress = math.Clamp(progress, 0, 1)

    local size = Lerp(progress, self.StartSize, self.EndSize)
    local alpha = 255 * (1 - progress)

    render.SetMaterial(mat)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))

    local progress = (CurTime() - self.StartTime) / self.LifeTime2
    progress = math.Clamp(progress, 0, 1)

    local size = Lerp(progress, 2, 169)
    local alpha = 255 * (1 - progress)

    render.SetMaterial(mat3)
    render.DrawSprite(self.Pos, size, size, Color(255, 255, 255, alpha))
end

effects.Register(EFFECT, "silver_suspension_grab_eff")
local EFFECT = {}

local mat = Material("icons/silver rock lines.png", "smooth")

function EFFECT:Init(data)
    self.Ent = data:GetEntity()
    self.Offset = Vector(0, 0, 0)
    self.Size = 100
    self.Pos = data:GetOrigin()
    self.Ang = 0
end

function EFFECT:Think()
    if IsValid(self.Ent) and not self.Ent:GetNWBool("Thrown") then
        self.Pos = self.Ent:GetPos() + self.Offset
        self.Ang = self.Ang - FrameTime() * 180
        return true
    end
    return false
end

function EFFECT:Render()
    if not self.Pos then return end

    local normal = (EyePos() - self.Pos):GetNormalized()

    render.SetMaterial(mat)
    render.DrawQuadEasy(
        self.Pos,
        normal,
        self.Size,
        self.Size,
        color_white,
        self.Ang
    )
end

effects.Register(EFFECT, "rockparticals_overlay_silver_003")



local EFFECT = {}

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local scale = data:GetScale() or 1

    local emitter = ParticleEmitter(pos)
    if not emitter then return end

    for i = 1, 40 do
        local particle = emitter:Add("effects/blueflare1", pos)
        if not particle then continue end

        local dir = VectorRand():GetNormalized()

        particle:SetVelocity(dir * math.Rand(400, 900) * scale)
        particle:SetDieTime(math.Rand(0.3, 1.6))

        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)

        particle:SetStartSize(math.Rand(15, 75) * scale)
        particle:SetEndSize(0)

        particle:SetRoll(math.Rand(0, 360))
        particle:SetRollDelta(math.Rand(-6, 6))

        particle:SetColor(75, 255, 238)
        particle:SetGravity(Vector(0, 0, 100))
        particle:SetAirResistance(150)
    end

    for i = 1, 60 do
        local particle = emitter:Add("particle/particle_smokegrenade", pos)
        if not particle then continue end

        local dir = VectorRand():GetNormalized()

        particle:SetVelocity(dir * math.Rand(200, 500) * scale)
        particle:SetDieTime(math.Rand(0.8, 1.4))

        particle:SetStartAlpha(220)
        particle:SetEndAlpha(0)

        particle:SetStartSize(math.Rand(20, 35) * scale)
        particle:SetEndSize(math.Rand(70, 110) * scale)

        particle:SetRoll(math.Rand(0, 360))
        particle:SetRollDelta(math.Rand(-3, 3))

        particle:SetColor(80, 80, 80)
        particle:SetGravity(Vector(0, 0, -500))
        particle:SetAirResistance(300)

        particle:SetCollide(true)
        particle:SetBounce(0.2)
    end

    for i = 1, 25 do
        local particle = emitter:Add("effects/fleck_cement"..math.random(1,2), pos)
        if not particle then continue end

        local dir = VectorRand():GetNormalized()

        particle:SetVelocity(dir * math.Rand(300, 700) * scale)
        particle:SetDieTime(math.Rand(0.6, 1))

        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)

        particle:SetStartSize(math.Rand(4, 8) * scale)
        particle:SetEndSize(0)

        particle:SetGravity(Vector(0, 0, -800))
        particle:SetCollide(true)
        particle:SetBounce(0.5)

        particle:SetColor(110, 110, 110)
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "rockparticalsBurst_silver")

local EFFECT = {}

function EFFECT:Init(data)
    self.Lifetime = CurTime() + 3

    local pos = data:GetOrigin()

    self.Emitter = ParticleEmitter(pos)
    self.Mat = Material("icons/Silver's rock bubbles.png", "smooth")

    for i = 1, 3 do
        local p = self.Emitter:Add(self.Mat, pos + Vector(
            math.random(-20,20),
            math.random(-20,20),
            math.random(-20,20)
        ))

        if p then
            local dir = VectorRand():GetNormalized()

            p:SetVelocity(dir * math.Rand(15, 30))
            p:SetDieTime(math.Rand(1.2, 2.5))
            p:SetStartAlpha(150)
            p:SetEndAlpha(0)
            p:SetStartSize(math.Rand(1, 3))
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

effects.Register(EFFECT, "OM_tinyball_silver_rock")