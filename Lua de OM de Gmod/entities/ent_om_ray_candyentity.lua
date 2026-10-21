AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Ray Collectable"
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

function ENT:Initialize()
    self.LifeTime = CurTime() + 60
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
        --phys:EnableMotion(true)
        --phys:EnableDrag(false)
        --phys:EnableGravity(false)
        --phys:EnableCollisions(true)
    end

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

ENT.HoverHeight = 40
ENT.HoverStrength = 15
ENT.HoverDamping = 6
ENT.DontLevetateTime = 0
ENT.TargetRange = 400
ENT.MinTargetSpeed = 50
ENT.MaxTargetSpeed = 1200
ENT.LifeTime = 0

function ENT:Think()
    if SERVER then
        if self.LifeTime <= CurTime() then
            self:Remove()
            return
        end
    end

    self:NextThink(CurTime())

    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    local candylucktype = self:GetNW2String("candylucktype")
    if SERVER then
        if self.HitWall and self.DontLevetateTime <= CurTime() then
            if not self.togglehit then
                self.togglehit = true
                AdvancedPillSound(
                    {
                        stringe = "OM/ray/snd_punchweak.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 85
                    },
                    self
                )
                if candylucktype == "Good" then
                    self:SetNW2Float("ray_flashgreen_OM", CurTime()+0.5)
                elseif candylucktype == "Bad" then
                    self:SetNW2Float("ray_flashred_OM", CurTime()+0.5)
                end
            end
            local phys = self:GetPhysicsObject()

            if IsValid(phys) then
                local pos = self:GetPos()

                local tr = util.TraceHull({
                    start = pos,
                    endpos = pos - Vector(0, 0, 1000),
                    mins = self:OBBMins(),
                    maxs = self:OBBMaxs(),
                    filter = function(ent)
                        if ent == self then return false end
                        if ent:IsPlayer() then return false end
                        if ent:IsNPC() then return false end
                        if ent:IsNextBot() then return false end

                        return true
                    end
                })

                if tr.Hit then
                    local height = pos.z - tr.HitPos.z
                    local difference = self.HoverHeight - height

                    local velocity = phys:GetVelocity()

                    local force = difference * self.HoverStrength
                    force = force - velocity.z * self.HoverDamping

                    phys:ApplyForceCenter(Vector(0, 0, force))
                end

                local closestTarget
                local closestDistance = self.TargetRange

                for _, ent in ipairs(ents.FindInSphere(pos, self.TargetRange)) do
                    if ent ~= self and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and ent:Health() >= 0.1 then
                        if ent:IsPlayer() and ent:Team() == TEAM_SPECTATOR then continue end
                        if IsValid(ent:GetNW2Entity("DrGBasePossessing")) then continue end

                        local distance = pos:Distance(ent:WorldSpaceCenter())
                        local detectionRange = self.TargetRange

                        if not ent:GetNW2Bool("OM_character") or GetConVar("PVPStun_OM"):GetBool() then
                            if candylucktype == "Good" then
                                detectionRange = self.TargetRange * 0.8
                            end
                        else
                            if candylucktype == "Bad" then
                                detectionRange = self.TargetRange * 0.8
                                if ent:GetNW2Bool("NoHealing_OM_Noodles") then continue end
                            end
                        end

                        if distance < detectionRange and distance < closestDistance then
                            closestDistance = distance
                            closestTarget = ent
                        end
                    end
                end

                if IsValid(closestTarget) then
                    local targetPos = closestTarget:WorldSpaceCenter()

                    local direction = targetPos - pos

                    local shouldremove = true
                    local candy = ""

                    if self:GetModel() == "models/noodles/om/ray/candy1.mdl" then

                        candy = "purple"

                        if closestTarget:GetNW2Bool("NoHealing_OM_Noodles") then
                            shouldremove = true
                        else
                            if closestTarget:IsPlayer() or closestTarget:IsNPC() or closestTarget:IsNextBot() then
                                if closestTarget:Health() <= closestTarget:GetMaxHealth()+50 then
                                else
                                    --shouldremove = false
                                end
                            end
                        end

                    elseif self:GetModel() == "models/noodles/om/ray/candy2.mdl" then

                        candy = "green"

                        if closestTarget:GetNW2Bool("NoHealing_OM_Noodles") then
                            shouldremove = true
                        else
                            if closestTarget:IsPlayer() or closestTarget:IsNPC() or closestTarget:IsNextBot() then
                                if closestTarget:Health() <= closestTarget:GetMaxHealth()+50 then
                                else
                                    --shouldremove = false
                                end
                            end
                        end

                    elseif self:GetModel() == "models/noodles/om/ray/candy3.mdl" then

                        candy = "blue"

                        if closestTarget:GetNW2Bool("NoHealing_OM_Noodles") then
                            shouldremove = true
                        else
                            if closestTarget:IsPlayer() or closestTarget:IsNPC() or closestTarget:IsNextBot() then
                                if closestTarget:Health() <= closestTarget:GetMaxHealth()+50 then
                                else
                                    --shouldremove = false
                                end
                            end
                        end

                    elseif self:GetModel() == "models/noodles/om/ray/poisonitem1.mdl" then
                        -- banana
                        candy = "Poison"

                    elseif self:GetModel() == "models/noodles/om/ray/poisonitem2.mdl" then
                        -- sandwitch
                        candy = "sandwitch"

                    elseif self:GetModel() == "models/noodles/om/ray/poisonitem3.mdl" then
                        -- Poison
                        candy = "banana"

                    end

                    if direction:LengthSqr() > 60 then
                        if shouldremove then
                            direction:Normalize()
                            local distancePercent = 1 - math.Clamp( closestDistance / self.TargetRange, 0, 1 )
                            local speed = Lerp( distancePercent, self.MinTargetSpeed, self.MaxTargetSpeed )
                            local currentVelocity = phys:GetVelocity()
                            phys:SetVelocity(Vector(direction.x * speed, direction.y * speed, direction.z * speed))
                        end
                    else

                        local function healing(amount)
                            if closestTarget:GetNW2Bool("NoHealing_OM_Noodles") then
                                return
                            end

                            if closestTarget == self.Owner and amount >= 0 then amount = amount * 1 end

                            if closestTarget:IsPlayer() or closestTarget:IsNPC() or closestTarget:IsNextBot() then
                                if amount > 0 and closestTarget:GetMaxHealth() + amount >= closestTarget:GetMaxHealth() then
                                    amount = amount * 1
                                end
                                local newHP = math.min( closestTarget:Health() + amount, closestTarget:GetMaxHealth() + 50 )

                                if newHP < 0 then
                                    local damage = -newHP
                                    closestTarget:TakeDamage(damage, closestTarget, closestTarget)
                                    return
                                end

                                closestTarget:SetHealth(newHP)
                            end
                        end
                        local function speedboost(amount)
                            local ent = closestTarget.pk_pill_ent
                            if closestTarget:IsNextBot() then
                                ent = closestTarget
                            end 
                            
                            if IsValid(ent) then
                                if ent:GetNW2Float("OM_SpeedBoost_Damage") > 0 then
                                    ent:SetNW2Float( "OM_SpeedBoost_Damage", ent:GetNW2Float("OM_SpeedBoost_Damage") + amount)
                                else
                                    ent:SetNW2Float( "OM_SpeedBoost_Damage", amount)
                                end
                                timer.Simple(5,function()
                                    if !IsValid(ent) then return end
                                    ent:SetNW2Float( "OM_SpeedBoost_Damage", ent:GetNW2Float("OM_SpeedBoost_Damage") - amount)
                                end)
                            end
                        end

                        if candy == "green" then
                            healing(20)
                            speedboost(100)
                            closestTarget:SetNWFloat("om_daze", 0)
                            AdvancedPillSound(
                                {
                                    stringe = "OM/ray/snd_power.wav",
                                    pitchPercent = 130,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                self
                            )
                            closestTarget:SetNW2Float("ray_flashgreen_OM", CurTime()+0.2)
                        elseif candy == "blue" then
                            healing(10)
                            speedboost(150)
                            closestTarget:SetNWFloat("om_daze", 0)
                            AdvancedPillSound(
                                {
                                    stringe = "OM/ray/snd_power.wav",
                                    pitchPercent = 115,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                self
                            )
                            closestTarget:SetNW2Float("ray_flashgreen_OM", CurTime()+0.2)
                        elseif candy == "purple" then
                            healing(5)
                            speedboost(200)
                            closestTarget:SetNW2Float("ray_flashgreen_OM", CurTime()+0.2)
                            closestTarget:SetNWFloat("om_daze", 0)
                            AdvancedPillSound(
                                {
                                    stringe = "OM/ray/snd_power.wav",
                                    pitchPercent = 107,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                self
                            )
                        end

                        if candy == "banana" then
                            healing(-5)
                            speedboost(-130)
                            closestTarget:SetNW2Float("ray_flashred_OM", CurTime()+0.2)

                            if !IsValid(closestTarget:GetNWEntity("OM_ragdollentity")) then
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/ray/bananaslip.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    self
                                )

                                local plyvelocity = closestTarget:GetVelocity()
                                local last = CurTime() + 4
                                local flung = false
                                local enemyragdoll = CreateRagdolLCharacter_OM({
                                    target = closestTarget,
                                    host = closestTarget,

                                    shouldremove = function(createfakeragdoll)
                                        if not IsValid(createfakeragdoll) then return true end
                                        if not IsValid(closestTarget) then return true end

                                        if last < CurTime() then return true end

                                        return false
                                    end,

                                    shoulddocustomfunction = function(createfakeragdoll)
                                        if not IsValid(createfakeragdoll) then return end
                                        if not IsValid(closestTarget) then return end
                                        if flung then return end
                                        flung = true
                                        for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                            local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                            if IsValid(phys) then
                                                phys:Wake()
                                                phys:SetVelocityInstantaneous(plyvelocity+Vector(0,0,1)*400)
                                            end
                                        
                                        end
                                    end
                                })
                            else
                                shouldremove = false
                            end


                        elseif candy == "sandwitch" then
                            healing(-10)
                            speedboost(-90)
                            closestTarget:SetNW2Float("ray_flashred_OM", CurTime()+0.2)
                            closestTarget:SetNWFloat("om_daze", CurTime()+3)
                            AdvancedPillSound(
                                {
                                    stringe = "OM/ray/snd_damage.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 85
                                },
                                self
                            )
                        elseif candy == "Poison" then
                            healing(-20)
                            speedboost(-65)
                            closestTarget:SetNW2Float("ray_flashred_OM", CurTime()+0.2)
                            AdvancedPillSound(
                                {
                                    stringe = "OM/ray/snd_bomb.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 85
                                },
                                self
                            )

                            local fx = EffectData()
                            --fx:SetOrigin(ent:GetPos()+Vector(0,0,30))
                            fx:SetEntity(closestTarget)

                            util.Effect("ray_poison_explode", fx, true, true)
                            
                        end

                        if shouldremove then
                            self:Remove()
                        end
                    end
                end
            end
        end
    else
        --[[
        local dlight = DynamicLight(self:EntIndex())

        if dlight then
            dlight.pos = self:GetPos()+Vector(0,0,-20)
            dlight.brightness = 3
            dlight.Size = 90
            dlight.Decay = 500
            dlight.DieTime = CurTime() + 0.1

            if candylucktype == "Good" then
                dlight.r = 0
                dlight.g = 255
                dlight.b = 0
            elseif candylucktype == "Bad" then
                dlight.r = 255
                dlight.g = 0
                dlight.b = 0
            end
        end
        ]]
    end

    return true
end


function ENT:PhysicsCollide(colData, collider)

    self.DontLevetateTime = CurTime() + 0.2

    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(Vector(0, 0, 150))
        phys:AddAngleVelocity(-phys:GetAngleVelocity())
    end

    self.HitWall = true
end


function ENT:OnRemove()

    self.HitWall = true

    if self.DamageHook then
        hook.Remove("EntityTakeDamage", self.DamageHook)
    end
end