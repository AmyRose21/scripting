AddCSLuaFile()
ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "PillUser")
    self:NetworkVar("Entity", 1, "Puppet")
end

function ENT:Initialize()
    self.SpawnTime = CurTime()
    self.SpinAngle = 0
    if SERVER then
        self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
        local ply = self:GetPillUser()
        self:SetPos(ply:GetPos())
        self:SetParent(ply)
        self:DrawShadow(false)

        local puppet = ents.Create("pill_puppet")

        puppet:SetModel("models/props_junk/harpoon002a.mdl")

        puppet:SetMaterial("icons/blaze_trail")
        puppet:SetColor(Color(217,217,217,255))

        local bone = ply:LookupBone("RightHand")
        local pos, ang = ply:GetBonePosition(bone)

        self:SetPuppet(puppet)
        puppet:Spawn()
        puppet:SetPos(pos)
        puppet:SetModelScale(0)
        puppet:SetModelScale(1,0.1)
        self:DeleteOnRemove(puppet)
        puppet:ManipulateBoneScale(0,Vector(1,3.11,3.11))

        local trailOrigin = ents.Create("info_target")
        trailOrigin:SetPos(puppet:GetPos() + puppet:GetAngles():Right() * 60)
        trailOrigin:SetParent(puppet)
        trailOrigin:Spawn()

        local fire = ents.Create("env_fire")
        if IsValid(fire) then
            fire:SetPos(trailOrigin:GetPos())
            fire:SetParent(trailOrigin)

            fire:SetKeyValue("StartDisabled", "0")
            fire:SetKeyValue("health", "1")
            fire:SetKeyValue("firesize", "50")
            fire:SetKeyValue("fireattack", "0")
            fire:SetKeyValue("damagescale", "0")

            fire:Spawn()
            fire:Activate()

            fire:Fire("StartFire", "", 0)
        end

        local trail = util.SpriteTrail(
            trailOrigin,
            0,
            Color(255, 0, 0),
            true,
            7,
            7,
            0.4,
            0.015,
            "icons/blaze_trail"
        )

        puppet:CallOnRemove("TrailRemove",function()
            trailOrigin:SetParent(NULL)
            timer.Simple(0.65,function()
                if IsValid(trailOrigin) then
                    trailOrigin:Remove()
                end
                if IsValid(trail) then
                    trail:Remove()
                end
                if IsValid(fire) then
                    fire:Remove()
                end
            end)
        end)

    end
end

function ENT:OnRemove()
end

function ENT:Think()
    local ply = self:GetPillUser()
    local rock = self:GetPuppet()

    if not IsValid(ply) or not IsValid(rock) then
        self:NextThink(CurTime())
        return true
    end

    local bone = ply:LookupBone("RightHand")

    if bone then
        local pos, ang = ply:GetBonePosition(bone)

        if pos and ang then
            pos = pos + ang:Right() * -3
            ang:RotateAroundAxis(ang:Right(), 90)

            local elapsed = CurTime() - self.SpawnTime

            if elapsed < 0.35 then
                self.SpinAngle = self.SpinAngle + FrameTime() * 4000
                ang:RotateAroundAxis(ang:Up(), self.SpinAngle)
            end

            if SERVER then
                rock:SetPos(pos)
                rock:SetAngles(ang)
            else
                rock:SetRenderOrigin(pos)
                rock:SetRenderAngles(ang)
            end
        end
    end

    self:NextThink(CurTime())
    return true
end
function ENT:Draw()
end
