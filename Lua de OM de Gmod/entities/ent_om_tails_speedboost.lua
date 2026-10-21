AddCSLuaFile()
ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "PillUser")
    self:NetworkVar("Entity", 1, "Puppet")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_phx/construct/metal_angle360.mdl")

        self:SetRenderMode(RENDERMODE_TRANSALPHA)
        self:SetColor(Color(255, 255, 255, 1))
    end
end

function ENT:OnRemove()
end

ENT.alreadyeletricited = {}
function ENT:Think()
    local ply = self:GetPillUser()

    if !IsValid(ply) then
        self:NextThink(CurTime()+0.1)
        return true
    end
    if SERVER then
        for _, ent2 in pairs(ents.FindInSphere(ball:GetPos(), 200)) do
            if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
            if ent2:GetClass() == "pill_puppet" then continue end
            if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then 

                    if ent.alreadyeletricited[ent2] then return end

                    ent.alreadyeletricited[ent2] = true


                    local pillent = ent2.pk_pill_ent
                    if ent2:IsNextBot() then
                        pillent = ent2
                    end 
                    
                    if IsValid(pillent) then
                        pillent:SetNW2Float("OM_SpeedBoost_Damage",pillent:GetNW2Float("OM_SpeedBoost_Damage")+200)
                    end

                    timer.Simple(5,function()
                        if !IsValid(ent2) then return end
                        alreadyeletricited[ent2] = false
                        if IsValid(pillent) then
                            pillent:SetNW2Float("OM_SpeedBoost_Damage",pillent:GetNW2Float("OM_SpeedBoost_Damage")-200)
                        end
                    end)
                else continue 
                end
            end
        end
    end

    self:NextThink(CurTime()+0.1)

    return true
end

local beamMat = {
    [0] = Material("icons/tailslaser"),
    [1] = Material("icons/tripwirereachout"),
    [2] = Material("icons/tails_blast"),
    [3] = Material("trails/electric")
}
local tailsmat = {
    [1] = Material("icons/tails fly yellow layer 1.png"),
    [2] = Material("icons/tails fly yellow layer 2.png"),
    [3] = Material("icons/tails fly white layer 1.png"),
    [4] = Material("icons/tails fly white layer 2.png"),
}
function ENT:Draw()


    local pos = self:GetPos()
    local ang = self:GetAngles()

    local time = CurTime()

    local pulse = math.sin(time * 3) * 15
    local quadSize = 400 + pulse

    local quadRot = -time * 90

    render.SetMaterial(beamMat[2])

    render.DrawQuadEasy(
        pos,
        ang:Up(),
        quadSize,
        quadSize,
        Color(255, 255, 255),
        quadRot
    )

    local radius = 150
    local segments = 14

    render.SetMaterial(beamMat[3])

    for i = 1, segments do
        local dir = Angle(0, (360 / segments) * i + time * 120, 0):Forward()

        local startPos = pos + dir * math.Rand(20, radius * 0.4)
        local endPos = pos + dir * math.Rand(radius * 0.6, radius)

        startPos = startPos + VectorRand() * 15
        endPos = endPos + VectorRand() * 25

        render.DrawBeam(
            startPos,
            endPos,
            math.Rand(6, 12),
            0,
            1,
            Color(255, 200, 0, 255)
        )

        render.DrawSprite(
            endPos,
            math.Rand(8, 16),
            math.Rand(8, 16),
            Color(255, 200, 0)
        )
    end

end

