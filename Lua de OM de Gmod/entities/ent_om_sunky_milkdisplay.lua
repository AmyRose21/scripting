AddCSLuaFile()
ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "PillUser")
    self:NetworkVar("Entity", 1, "Puppet")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
        local ply = self:GetPillUser()
        self:SetPos(ply:GetPos())
        self:SetParent(ply)
        self:DrawShadow(false)

        local puppet = ents.Create("pill_puppet")
        puppet:SetModel("models/Noodles/OM/sunkycerial.mdl")
        self:SetPuppet(puppet)
        puppet:Spawn()
        self:DeleteOnRemove(puppet)
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

    local rightBone = ply:LookupBone("RightHand")
    local leftBone = ply:LookupBone("LeftHand")

    if rightBone and leftBone then
        local rightPos, rightAng = ply:GetBonePosition(rightBone)
        local leftPos, leftAng = ply:GetBonePosition(leftBone)

        if rightPos and leftPos then
            rightPos = rightPos + rightAng:Up() * -15 + rightAng:Right()  * -8
            leftPos  = leftPos  + leftAng:Up()  * -15 + leftAng:Right()  * -8

            local pos = (rightPos + leftPos) * 0.5

            local ang = LerpAngle(0.5, leftAng, rightAng)
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Up(), 90)
            ang:RotateAroundAxis(ang:Right(), -90)

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
