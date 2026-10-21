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
        puppet:SetModel("models/props_wasteland/rockgranite03b.mdl")
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

    if rightBone then
        local rightPos, rightangle = ply:GetBonePosition(rightBone)
        rightPos = rightPos + rightangle:Forward()*-15 + rightangle:Right()*-5

        rightangle:RotateAroundAxis(rightangle:Forward(), 90)
        rightangle:RotateAroundAxis(rightangle:Right(), -90)

        if rightPos then

            if SERVER then
                rock:SetPos(rightPos)
                rock:SetAngles(rightangle)
            else
                rock:SetRenderOrigin(rightPos)
                rock:SetRenderAngles(rightangle)
            end
        end
    end

    self:NextThink(CurTime())

    return true
end

function ENT:Draw()
end
