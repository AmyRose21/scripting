AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Espio Star"
ENT.Spawnable = false

local function AdvancedPillSound(SoundData, ent)
    if SERVER then
        if IsValid(ent) then
            SoundData = SoundData or {}
            SoundData.stringe = SoundData.stringe or {}
            SoundData.soundLevel = SoundData.soundLevel or 75
            SoundData.pitchPercent = SoundData.pitchPercent or 100
            SoundData.volume = SoundData.volume or 1
            SoundData.channel = SoundData.channel or CHAN_AUTO
            SoundData.soundFlags = SoundData.soundFlags or 0
            SoundData.dsp = SoundData.dsp or 0
            SoundData.filter = SoundData.filter or nil

            local chosenSound = SoundData.stringe

            if istable(SoundData.stringe) then
                local index = math.random(1, #SoundData.stringe)
                chosenSound = SoundData.stringe[index]
            end

            ent:EmitSound(
                chosenSound,
                SoundData.soundLevel,
                SoundData.pitchPercent,
                SoundData.volume,
                SoundData.channel,
                SoundData.soundFlags,
                SoundData.dsp,
                SoundData.filter
            )
        end
        return true
    end
end

ENT.LifeTime = 0
ENT.GrappleLifeTime = 0

function ENT:Initialize()
    if SERVER then
        self.LifeTime = CurTime() + 2

        self:SetModel("models/nick/OM/Espio/stars.mdl")
        --self:SetModel("models/props_c17/oildrum001.mdl")


        self:SetNW2Float("vector_ringcolor", CurTime()+1e9)

        util.SpriteTrail(
            self,
            0,
            Color(255, 255, 0),
            false,
            50,
            0,
            0.4,
            1 / 12,
            "trails/laser"
        )

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(true)
            phys:EnableDrag(false)
            phys:EnableGravity(false)
            phys:EnableCollisions(true)
        end

        self.Homing = false
        self.Owner = NULL

        self.DamageHook = "disableJasonSpear_damage_" .. self:EntIndex()

        hook.Add("EntityTakeDamage", self.DamageHook, function(target, dmginfo)
            if not IsValid(target) or not dmginfo then return end

            local damager = dmginfo:GetAttacker()

            if not IsValid(damager) then return end

            if damager == self then
                dmginfo:SetDamage(0)
                dmginfo:SetDamageType(DMG_GENERIC)

                return true
            end
        end)
    end
end

function ENT:Think()
    if SERVER then
        if self.FadeStart then
            local fade = 1 - math.Clamp((CurTime() - self.FadeStart) / 15, 0, 1)

            self:SetRenderMode(RENDERMODE_TRANSCOLOR)
            self:SetColor(Color(255, 255, 255, 255 * fade))

            if CurTime() >= self.FadeEnd then
                self:Remove()
                return true
            end
        end

        local ply = self.Owner
        local ent = self.EntOwner

        local closestEnt = nil
        local closestDist = math.huge

        local phys = self:GetPhysicsObject()

        if IsValid(phys) then
            local velocity = phys:GetVelocity()

            if velocity:LengthSqr() > 0 then
                local currentDirection = velocity:GetNormalized()

                for _, ent2 in pairs(ents.FindInSphere(self:GetPos(), 1400)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end

                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if ent2:GetNW2Bool("OM_character") and not GetConVar("PVPStun_OM"):GetBool() then continue end

                        local direction = (ent2:WorldSpaceCenter() - self:GetPos()):GetNormalized()
                        local dot = currentDirection:Dot(direction)

                        if dot < 0.1 then continue end

                        local distance = self:GetPos():DistToSqr(ent2:GetPos())

                        if distance < closestDist then
                            closestDist = distance
                            closestEnt = ent2
                        end
                    end
                end

                if IsValid(closestEnt) then
                    local direction = (closestEnt:WorldSpaceCenter() - self:GetPos()):GetNormalized()

                    local homingDirection = LerpVector(0.15, currentDirection, direction):GetNormalized()

                    phys:SetVelocity(homingDirection * velocity:Length())
                end
            end
        end
    end

    self:NextThink(CurTime())

    return true
end

function ENT:PhysicsCollide(colData, collider)
    local ent2 = colData.HitEntity

    local shouldlatch = false
    local ply = self.Owner
    local ent = self.EntOwner

    if IsValid(ent2) then
        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then shouldlatch = true end
        if ent2:GetClass() == "pill_puppet" then shouldlatch = true end
        if ent2 == ply then shouldlatch = true end
        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then shouldlatch = true end
        if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then shouldlatch = true end
    end

    if not shouldlatch then
        
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        self.FadeStart = CurTime()
        self.FadeEnd = CurTime() + 15

        if ent2 == game.GetWorld() then
            local phys = self:GetPhysicsObject()

            if IsValid(phys) then
                phys:EnableMotion(false)
            end

            self:SetMoveType(MOVETYPE_NONE)
            self.LatchedEntity = ent2

            return
        end

        if IsValid(ent2) then
            if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                self:SetParent(ent2)

                local phys = self:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(false)
                end

                self:SetLocalPos(ent2:WorldToLocal(self:GetPos()))
                self:SetLocalAngles(ent2:WorldToLocalAngles(self:GetAngles()))

                self.LatchedEntity = ent2

                local HitEntity = ent2
                if IsValid(HitEntity) then
                    if IsValid(HitEntity:GetNW2Entity("DrGBasePossessing")) then return end
                    if HitEntity:GetClass() == "pill_puppet" then return end
                    if (HitEntity:IsPlayer() or HitEntity:IsNextBot() or HitEntity:IsNPC()) and HitEntity:Health() >= 0.1 then
                        if HitEntity == ply then return end
                        if HitEntity:IsPlayer() and HitEntity:Team() == TEAM_SPECTATOR then return end

                        local stunstack = GetConVar("OUTCOMEMEMORIES_N_shadow_aim_canstunstack"):GetBool()

                        if Mutual_OMCanStun(ply, ent, HitEntity, stunstack) then
                            local dir = self:GetVelocity():GetNormalized()
                            if HitEntity:IsPlayer() then
                                if HitEntity:IsOnGround() then
                                    --HitEntity:SetPos(HitEntity:GetPos()+Vector(0,0,15))
                                end
                                HitEntity:SetVelocity(dir*200)
                                HitEntity:SetLocalVelocity(dir*200)
                            else
                                if HitEntity:IsOnGround() then
                                    --HitEntity:SetPos(HitEntity:GetPos()+Vector(0,0,30))
                                end
                                HitEntity:SetVelocity(dir*200)
                                HitEntity:SetLocalVelocity(dir*200)
                            end
                            HitEntity:SetNWFloat("ShadowBulletHitCount", HitEntity:GetNWFloat("ShadowBulletHitCount")+ 4/4 )

                            ent:SetNW2Float("Shadow_showcharacter_".. tostring(HitEntity), CurTime()+ 1.25)

                            if HitEntity:GetNWFloat("ShadowBulletHitCount") > 4 then
                                HitEntity:SetNWFloat("ShadowBulletHitCount", 1)
                            end

                            if HitEntity:GetNWFloat("ShadowBulletHitCount") >= 4 then

                                Mutaul_OMStunCode(
                                    {
                                        ["ply"] = ply,
                                        ["ent"] = ent,
                                        ["target"] = HitEntity,
                                        ["StunDur"] = 3,
                                        ["stunfunction"] = function(shouldstundamage)
                                            if shouldstundamage then
                                            end
                                        end,
                                        ["shouldstack"] = stunstack,
                                        ["Damage"] = 5,
                                        ["DamageType"] = DMG_GENERIC
                                    }
                                )
                            end
                        else
                            dmginfo:SetDamage(0)
                        end
                    end
                end

            else
                self:SetParent(ent2)

                local phys = self:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(false)
                end

                self:SetLocalPos(ent2:WorldToLocal(self:GetPos()))
                self:SetLocalAngles(ent2:WorldToLocalAngles(self:GetAngles()))

                self.LatchedEntity = ent2
            end
        end
    end
end


function ENT:OnRemove()
    if self.DamageHook then
        hook.Remove("EntityTakeDamage", self.DamageHook)
    end
end