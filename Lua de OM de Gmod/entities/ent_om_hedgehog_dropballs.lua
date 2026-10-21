AddCSLuaFile()

ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "PillUser")
    self:NetworkVar("Entity", 0, "PillUser2")
end

function ENT:Initialize()
    if SERVER then -- 
        self:SetModel("models/noodles/om/hedgehog/sonicball.mdl")
    end
end

function ENT:Think()
    local ply = self:GetPillUser()
    local ply2 = self:GetPillUser2()

    if not IsValid(ply)  then
        self:NextThink(CurTime())
        return true
    end

    local position, angles = ply:GetPos() + Vector(0,0,15 + self:GetNW2Float("Offset_goingup_om", 0)), ply2:GetAngles()

    if SERVER then
        self:SetPos(position)
        self:SetAngles(angles)
    else
        self:SetRenderOrigin(position)
        self:SetRenderAngles(angles)
    end

    self:NextThink(CurTime())
    return true
end