AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Vector Ring"
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
        self:SetNW2Float("vector_ringcolor", CurTime()+1e9)

        self:SetModel("models/nick/OM/Vector/ring.mdl")

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        local phys = self:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(true)
            phys:EnableDrag(false)
            phys:EnableGravity(false)
            phys:EnableCollisions(true)
        end

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
        local shouldlookfor = false
        if self.LifeTime >= CurTime() then
        else
            if not self.InitiateThing then
                self.InitiateThing = true
                self.Homing = true

                self:SetSolid(SOLID_NONE)
                self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

                local phys = self:GetPhysicsObject()

                if IsValid(phys) then
                    phys:EnableCollisions(false)
                end
            end
        end

        if self.Grapple and IsValid(self.Owner) then
            self.HasGrappled = true

            local ownerPos = self.Owner:WorldSpaceCenter()
            local direction = (self:GetPos() - ownerPos):GetNormalized()
            local targetVelocity = 800

            local position1 = direction * targetVelocity
            local position2 = self.Owner:GetVelocity()

            self.Grapple_lerp = self.Grapple_lerp or 0
            self.Grapple_lerp = Lerp(FrameTime()*0.3, self.Grapple_lerp, 1)

            self.Owner:SetLocalVelocity( LerpVector(self.Grapple_lerp, position2, position1) )
            if self.Owner:IsOnGround() then
                self.Grapple_pos = self.Grapple_pos or 0
                self.Grapple_pos = Lerp(FrameTime() * 5, self.Grapple_pos, 10)

                self.Owner:SetPos(self.Owner:GetPos() + Vector(0,0,self.Grapple_pos))
            end

            local ownerPos = self.Owner:WorldSpaceCenter()
            local distance = self:GetPos():Distance(ownerPos)

            if distance <= 70 then
                self:Remove()
                return
            end

            if self.GrappleLifeTime >= CurTime() then
            else
                self.Grapple = false
                self.InitiateThing = true

                self.Homing = true

                self:SetSolid(SOLID_NONE)
                self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

                local phys = self:GetPhysicsObject()

                if IsValid(phys) then
                    phys:EnableCollisions(false)
                    phys:EnableMotion(true)
                end
            end
            shouldlookfor = true
        end

        local phys = self:GetPhysicsObject()

        if self.Homing and IsValid(self.Owner) and IsValid(phys) then
            local ownerPos = self.Owner:WorldSpaceCenter() + Vector(0,0,30)
            local distance = self:GetPos():Distance(ownerPos)

            if distance <= 50 then
                self:Remove()
                return
            end

            local direction = (ownerPos - self:GetPos()):GetNormalized()
            local targetVelocity = direction * math.Clamp(distance * 3, 1300, 2600)

            phys:SetVelocity(LerpVector(0.24, phys:GetVelocity(), targetVelocity))
            shouldlookfor = true
        end

        if not shouldlookfor then
            local ply = self.Owner
            local ent = self.EntOwner
            local jumpscare_entity = nil
            for _, ent2 in pairs(ents.FindInSphere( self:GetPos(), 80)) do
                if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                    if ent2 == ply then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                    --if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then continue end

                    self.HasHadEnemy = true

                    
                    AdvancedPillSound(
                        {
                            stringe = "OM/vector/grab.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        self
                    )

                    local throw = false
                    local timestarted = false
                    local NoLongerValid = false
                    local starttime = CurTime()

                    local enemyragdoll = CreateRagdolLCharacter_OM({
                        target = ent2,
                        host = ent,

                        shouldremove = function(createfakeragdoll)
                            if not IsValid(createfakeragdoll) then return true end
                            if not IsValid(ent2) then return true end
                            if not IsValid(ent) then return true end

                            if timestarted and starttime < CurTime() then
                                return true
                            end

                            return false
                        end,

                        shoulddocustomfunction = function(createfakeragdoll)
                            if not IsValid(createfakeragdoll) then return end
                            local puppet = ent:GetPuppet()
                            if not IsValid(puppet) then return end

                            if throw then return end
                            local headPhys
                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                local phys = createfakeragdoll:GetPhysicsObjectNum(i)
                                if IsValid(phys) then
                                    local boneIndex = createfakeragdoll:TranslatePhysBoneToBone(i)
                                    local boneName = createfakeragdoll:GetBoneName(boneIndex) or ""
                                    if string.find(string.lower(boneName), "head", 1, true) then
                                        headPhys = phys
                                        break
                                    end
                                end
                            end
                            if not IsValid(headPhys) then
                                headPhys = createfakeragdoll:GetPhysicsObject()
                            end
                            if not IsValid(headPhys) then return end
                            if not IsValid(self) then 
                                if not NoLongerValid then
                                    NoLongerValid = true
                                end

                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                    local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                    if IsValid(phys) then
                                        phys:SetVelocity(
                                            LerpVector(FrameTime() * 9, phys:GetVelocity(), vector_origin)
                                        )
                                    end
                                end

                                return 
                            end

                            headPhys:SetPos(self:GetPos())
                            headPhys:SetVelocityInstantaneous(vector_origin)
                            headPhys:Wake()

                            timestarted = true
                            starttime = CurTime()+1
                                
                        end,
                    })

                    self.InitiateThing = false
                    self.LifeTime = 0
                    self.Grapple = false
                    self.Homing = true
                    
                    break
                end
            end
        end
    end

    self:NextThink(CurTime())

    return true
end


function ENT:PhysicsCollide(colData, collider)
    if SERVER and not self.Homing and not self.Grapple then
        self.Grapple = true
        self.InitiateThing = true

        local phys = self:GetPhysicsObject()

        if IsValid(phys) then
            phys:SetVelocity(Vector(0, 0, 0))
            phys:EnableMotion(false)
        end
        self.GrappleLifeTime = CurTime() + 1.3

        AdvancedPillSound(
            {
                stringe = "doors/door_latch1.wav",
                pitchPercent = 100,
                volume = 1,
                soundLevel = 87
            },
            self
        )

    end
end


function ENT:OnRemove()
    if self.EntOwner then
        if IsValid(self.EntOwner) then
            self.EntOwner:SetNW2Entity("ent_om_vector_ring", NULL)
            self.EntOwner:GetPuppet():SetBodygroup(1,0)

            self.EntOwner:GetPuppet():SetNW2Float("vector_punchflash_yellow", CurTime()+0.2)

            local dur = self.HasGrappled and 26 or self.HasHadEnemy and 15 or 10
            self.EntOwner:SetNW2Float("Vector_BoundRingCD", CurTime() + dur )
            self.EntOwner:SetNW2Float("Vector_BoundRingDur", dur )


            AdvancedPillSound(
                {
                    stringe = "OM/sonic/peeloutpickup.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                self
            )
            
            local dur = 4
            if self.EntOwner:GetNW2Float("Vector_PunchCD") >= CurTime() then
                self.EntOwner:SetNW2Float("Vector_PunchCD", self.EntOwner:GetNW2Float("Vector_PunchCD") + dur )
                self.EntOwner:SetNW2Float("Vector_PunchDur", self.EntOwner:GetNW2Float("Vector_PunchDur") + dur )
            else
                self.EntOwner:SetNW2Float("Vector_PunchCD", CurTime() + dur )
                self.EntOwner:SetNW2Float("Vector_PunchDur", dur )
            end
        end
    end
    if self.DamageHook then
        hook.Remove("EntityTakeDamage", self.DamageHook)
    end
end