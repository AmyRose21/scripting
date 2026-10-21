AddCSLuaFile()
ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true

if SERVER then--
    timer.Simple(1,function()
        if SERVER then else return end
        OM_AddSpeedConfigeration(function(entity)
            if SERVER and entity:GetNW2Float("sunky_afterimage_OM_noodles_slowdown", 0) >= CurTime() then
                return 0.35
            end
            return 1
        end)
    end)
end

hook.Add("SetupMove", "sunky_slowdown_debuff", function(ply, mv, cmd)
    if !IsValid(ply) then return end
    if !ply:Alive() then return end

    if ply:GetNW2Float("sunky_afterimage_OM_noodles_slowdown", 0) >= CurTime() then
        local vel = mv:GetVelocity()

        vel.x = vel.x * 0.35
        vel.y = vel.y * 0.35

        mv:SetVelocity(vel)
    end
end)

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "PillUser")
    self:NetworkVar("Entity", 1, "Puppet")
end
function ENT:Initialize()
    if SERVER then
        self:SetModel("models/hunter/tubes/circle2x2.mdl")

        self:SetColor(Color(255, 255, 255, 255))
        self:SetMaterial("models/debug/debugwhite")
        self:SetModelScale(0.01, 0)
    end
end

function ENT:OnRemove()
end

function ENT:Think()
    if SERVER then
        local ply = self:GetPillUser()
        local ent = self:GetPuppet()

        local puddle = self

        for _, ent2 in pairs(ents.FindInSphere(self:GetPos(), 46 * self:GetModelScale())) do
            if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                if ent2 == ply then continue end
                if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                if not GetConVar('PVPStun_OM_exe'):GetBool() then
                    if ent2:GetNW2Bool("OM_character_monster") then continue end
                end
                if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                if ent:IsNextBot() then
                    if ent.GetPossessor and ent:GetPossessor() == ent2 then continue end
                end

                local relative = ent2:GetPos() - puddle:GetPos()

                local horizontalDist = Vector(relative.x, relative.y, 0):Length()
                local verticalDist = relative.z

                if verticalDist >= -35 and verticalDist <= 50 then

                    ent2:SetNW2Float("sunky_afterimage_OM_noodles", CurTime()+5)
                    ent2:SetNW2Float("sunky_afterimage_OM_noodles_indicator", CurTime()+5)
                    ent2:SetNW2Float("sunky_afterimage_OM_noodles_slowdown", CurTime()+5)
                end
            end
        end

        self:NextThink(CurTime())
        return true
    end
end