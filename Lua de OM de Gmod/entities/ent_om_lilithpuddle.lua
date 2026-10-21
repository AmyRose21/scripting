AddCSLuaFile()
ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "PillUser")
    self:NetworkVar("Entity", 1, "Puppet")
end
ENT.lifetime = CurTime()
function ENT:Initialize()
    self.SpawnTime = CurTime()
    self.SpinAngle = 0
    if SERVER then
        self:SetModel("models/props_phx/construct/metal_angle360.mdl")

        ParticleEffectAttach(
            "Lilith_Glitch2Big",
            PATTACH_ABSORIGIN_FOLLOW,
            self,
            0
        )
        self:SetModelScale(3)

        self:SetNWFloat("BallRadius_lilith", 140)
        self:SetNWFloat("BallHeight_lilith", 30)
        self:SetNWFloat("lilith_green_glow_puddle", CurTime()+1e9)

        self:SetColor(Color(175 * math.random(75,125) / 100, 0, 0, 255))
        self:SetRenderMode(RENDERMODE_TRANSALPHA)
        self:SetMaterial("models/noodles/om/lilith/bloodblood")
        self.lifetime = CurTime()+20
        self:SetNW2Float("lilith_green_glow_red", CurTime()+0.5*0.6)
    end
end

function ENT:OnRemove()
end

function ENT:Think()
    if SERVER then
        local ply = self:GetPillUser()
        local ent = self:GetPuppet()



        local function removeFromTable(table2, target)
            for i, v in ipairs(table2) do
                local puddle = v.ent
                if puddle == target then
                    table.remove(table2,i)
                end
            end
        end

        local puddle = self
        if self.lifetime < CurTime() then
            if IsValid(self) then
                self:Remove()
            end
            return
        end

        if not puddle.changecolorcd then 
            puddle.changecolorcd = 0
        end

        if puddle.changecolorcd < CurTime() then
            puddle.changecolorcd = CurTime() + 0.1
            self:SetColor(Color(math.random(0,255), 0, 0, 255))
        end

        if IsValid(puddle) then
            for _, ent2 in pairs(ents.FindInSphere(puddle:GetPos() ,150)) do
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
                    if Mutal_OMCanDamage_grab(ply,ent,ent2) then
                        if IsValid(ent2) then
                            local relative = ent2:GetPos() - puddle:GetPos()

                            local horizontalDist = Vector(relative.x, relative.y, 0):Length()
                            local verticalDist = relative.z

                            if verticalDist >= -70 and verticalDist <= 50 then
                                if not ent.poisoncd.ent2 or ent.poisoncd.ent2 < CurTime() then
                                    ent.poisoncd.ent2 = CurTime()+0.5
                                    KillerdamagestunDynamic({
                                        ply = ply,
                                        target = ent2,
                                        DamageNumb = GetConVar("OUTCOMEMEMORIES_N_Lilith_puddledamage"):GetFloat(),
                                        damagetype = DMG_ACID,
                                        CustomDamageSound = nil,
                                        damagesound = false,
                                        ShouldBlood = false,
                                        flingremoveal = false,
                                        ShouldBloodEffect = false
                                    })
                                    ent2:SetNWFloat("om_daze", CurTime()+5)
                                    ent2:SetNW2Float("lilith_green_glow", CurTime()+10)
                                    ent2:SetNW2Float("lilithoutine_ability_outline2", CurTime()+10)
                                end
                            end
                        end
                    end
                end
            end
        end

        self:NextThink(CurTime())
        return true
    end
end