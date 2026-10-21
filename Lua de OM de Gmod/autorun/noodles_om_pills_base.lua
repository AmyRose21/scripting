
AddCSLuaFile()

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
-- DAMAGE CODE -- 
if SERVER then
    hook.Add("EntityTakeDamage", "disablefalldamage_OM", function(entityfall, dmg)
        if not SERVER then return end
        
        local damageamount = dmg:GetDamage()
        local attacker = dmg:GetAttacker()
        if IsValid(entityfall:GetNWEntity("OM_ragdollentity")) then
            if dmg:IsDamageType(DMG_FALL) then
                dmg:SetDamage(0)
                dmg:SetDamageType(DMG_GENERIC)
                return true
            end
        end

        if IsValid(entityfall) then
            if entityfall.OM_DamageBeforeBeforeCustomFunction then
                entityfall:OM_DamageBeforeBeforeCustomFunction({entityfall, dmg, damageamount},{entityfall, dmg, damageamount})
            end
            damageamount = dmg:GetDamage()
        end
        if IsValid(attacker) then
            if attacker.OM_AttacterBeforeBeforeCustomFunction then
                attacker:OM_AttacterBeforeBeforeCustomFunction({entityfall, dmg, damageamount},{entityfall, dmg, damageamount})
            end
            damageamount = dmg:GetDamage()
        end
        if entityfall:GetNW2Bool("OM_character") or entityfall:GetNW2Bool("OM_character_monster") then
            if entityfall:GetNW2Float("OM_NoDamagePrevention") > CurTime() then
                dmg:SetDamage(0)
                dmg:SetDamageType(DMG_GENERIC)
                return true
            end
            if entityfall:GetNW2Bool("Survivor_Downed_OM") then
                dmg:SetDamage(0)
                dmg:SetDamageType(DMG_GENERIC)
                return true
            end
            if dmg:IsFallDamage() then
                dmg:SetDamage(0)
                dmg:SetDamageType(DMG_GENERIC)
                return true
            end

            if IsValid(attacker) and (attacker:IsPlayer() or attacker:IsNPC() or attacker:IsNextBot()) and entityfall:GetNW2Float("OM_Damage_ReductionRemoveal") < CurTime() then
                dmg:SetDamage(dmg:GetDamage()*entityfall:GetNW2Float("OM_Damage_Reduction",0) / entityfall:GetNW2Float("DamageResistance_OM_2",0))
                damageamount = dmg:GetDamage()
            end

            if IsValid(entityfall) then
                if entityfall.OM_DamageBeforeCustomFunction then
                    entityfall:OM_DamageBeforeCustomFunction({entityfall, dmg, damageamount},{entityfall, dmg, damageamount})
                end
                damageamount = dmg:GetDamage()
            end
            if IsValid(attacker) then
                if attacker.OM_AttacterBeforeCustomFunction then
                    attacker:OM_AttacterBeforeCustomFunction({entityfall, dmg, damageamount},{entityfall, dmg, damageamount})
                end
                damageamount = dmg:GetDamage()
            end
            if entityfall:IsPlayer() and damageamount > 0 then
            end

            if entityfall:GetNW2Bool("OM_character") then
                if (entityfall:Health() - damageamount) <= 0.85 and entityfall:GetNW2Bool("SecondLife_OM") and not entityfall:GetNW2Bool("OnSecondLife_OM") then
                    if GetConVar("om_pills_action_2ndlife"):GetBool() then
                        dmg:SetDamage(0)
                        entityfall:SetHealth(10)
                        entityfall:SetNW2Bool("Survivor_Downed_OM", true)
                        entityfall:SetNW2Float("Survivor_DownedTime_OM", CurTime()+30)
                        entityfall:AddFlags(FL_NOTARGET)
                        
                        AdvancedPillSound(
                            {
                                stringe = "OM/Hurt_Om.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            entityfall
                        )
                        
                        if entityfall.CustomFunctionForDowned_OM then
                            entityfall:CustomFunctionForDowned_OM({entityfall, dmg, damageamount},{entityfall, dmg, damageamount})
                        end
                        
                        if attacker.CustomFunctionForDowning_OM then
                            attacker:CustomFunctionForDowning_OM({entityfall, dmg, damageamount},{entityfall, dmg, damageamount})
                        end

                        timer.Simple(0.1, function()
                            if !IsValid(entityfall) then return end
                            if !IsValid(attacker) then return end
                            local last = CurTime() + 2

                            local enemyragdoll = CreateRagdolLCharacter_OM({
                                target = entityfall,
                                host = attacker,

                                shouldremove = function(createfakeragdoll)
                                    if not IsValid(createfakeragdoll) then return true end
                                    if not IsValid(entityfall) then return true end

                                    local pos = createfakeragdoll:GetPos()
                                    
                                    if (last < CurTime() ) or not entityfall:GetNW2Bool("Survivor_Downed_OM") then
                                        return true
                                    end
                                    return false
                                end,

                                shoulddocustomfunction = function(createfakeragdoll) end
                            })
                        end)
                    end
                else
                    timer.Simple(0, function()
                        if !IsValid(entityfall) then return end
                        local diference = entityfall:Health() < entityfall:GetNW2Float("LowestHealth",0)
                        if entityfall:Health() < entityfall:GetNW2Float("LowestHealth",0) then
                            lowesthealth = entityfall:Health()
                            entityfall:SetNW2Float('LowestHealthCount_OM_pills', lowesthealth)

                            if entityfall:GetNW2Bool("OM_character") then
                                local ent = entityfall.pk_pill_ent
                                if entityfall:IsNextBot() then
                                    ent = entityfall
                                end 
                                
                                if IsValid(ent) then
                                    if GetConVar("OUTCOMEMEMORIES_N_ShouldSpeedBoost"):GetBool() then 
                                        local curTime = CurTime()

                                        local blockTime = ent:GetNW2Float("ShouldntGetBoost_OM", 0)
                                        local currentBoost = ent:GetNW2Float("OM_SpeedBoost_Damage", 0)
                                        local maxBoost = 1e9--GetConVar("OUTCOMEMEMORIES_N_maxboost"):GetInt()

                                        if blockTime <= curTime and currentBoost < maxBoost then
                                            if damageamount > 1 then
                                                local damageAmount = (damageamount * GetConVar("OUTCOMEMEMORIES_N_basemultiplyer"):GetInt() / 100)*5
                                                --local oldstee = GetConVar("OUTCOMEMEMORIES_N_basedamageboost"):GetInt()/100

                                                local newBoost = math.Clamp(currentBoost + damageAmount, 0, maxBoost)
                                                ent:SetNW2Float("OM_SpeedBoost_Damage", newBoost)

                                                timer.Simple(GetConVar("OUTCOMEMEMORIES_N_damageboostdur"):GetInt(), function()
                                                    if IsValid(ent) then
                                                        local cur = ent:GetNW2Float("OM_SpeedBoost_Damage", 0)
                                                        ent:SetNW2Float("OM_SpeedBoost_Damage",
                                                            math.Clamp(cur - damageAmount, 0, maxBoost)
                                                        )
                                                    end
                                                end)
                                                
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
        if IsValid(entityfall) then
            if entityfall.OM_DamageCustomFunction then
                entityfall:OM_DamageCustomFunction({entityfall, dmg, damageamount},{entityfall, dmg, damageamount})
            end
        end
        if IsValid(attacker) then
            if attacker.OM_AttacterCustomFunction then
                attacker:OM_AttacterCustomFunction({entityfall, dmg, damageamount},{entityfall, dmg, damageamount})
            end
        end
    end)
end


local function SetupPlayerCollision(ply)
    ply:SetCustomCollisionCheck(true)
end

if SERVER then
    hook.Add("PlayerSpawn", "DisablePlayerCollision_Init_om", SetupPlayerCollision)
    hook.Add("OnEntityCreated", "DisableentityCollision_Init_om", SetupPlayerCollision)


    hook.Add("ShouldCollide", "DisablePlayerCollision_Logic", function(ent1, ent2)
        if not GetConVar("ShouldCollide_om"):GetBool() then return end
        local function meetexpectations(ent)
            if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
                return true
            end
        end
        local function ispill(ent)
            local pillentity = ent.pk_pill_ent

            if (IsValid(pillentity) and pillentity.formTable and pillentity.formTable.Outcomememories) or
                (ent.formTable and ent.formTable.Outcomememories) then
                return true
            end
        end

        local function meetexpectationscollision(ent, entescond)
            if ent == entescond then
                return true
            end
        end
        --[[
        local function CollisionRadius(ent)
            local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
            return (maxs - mins):Length() * 0.5
        end
        ]]

        if IsValid(ent1) and IsValid(ent2) then
            if meetexpectationscollision(ent1, ent2:GetNWEntity("NoCollideEntity_om")) or
                meetexpectationscollision(ent2, ent1:GetNWEntity("NoCollideEntity_om")) then
                return false
            end

            if (meetexpectations(ent1) and meetexpectations(ent2)) and (ispill(ent1) or ispill(ent2)) then
                local dist = ent1:GetPos():Distance(ent2:GetPos())
                --local maxDist = CollisionRadius(ent1) + CollisionRadius(ent2)

                if dist < 50 then
                    return false
                end
            end
        end
    end)

end



-- Set up base move --
if CLIENT then
    hook.Add("CreateMove", "OM_clientsidemovement", function(cmd)
        local ply = LocalPlayer()
        if !IsValid(ply) then return end

        if ply:GetNWFloat("om_daze", 0) > CurTime() then
            local forward = cmd:GetForwardMove()
            local side = cmd:GetSideMove()

            cmd:SetForwardMove(-forward)
            cmd:SetSideMove(-side)
        end

        local ent = ply.pk_pill_ent
        if IsValid(ent) then
            if (ply:GetNW2Bool("OM_character") or ply:GetNW2Bool("OM_character_monster")) then
                if ply:GetNW2Float("RollEndTime_om") > CurTime() then
                    cmd:RemoveKey(IN_JUMP)
                else
                    if ent:GetNW2Float("OM_JumpCooldown") >= CurTime() or ent:GetNW2Bool("OM_JumpBoolean") then
                        cmd:RemoveKey(IN_JUMP)
                    end
                end
            end

            if ply:GetNW2Float("OM_MoveForward_WithSideways") >= CurTime() then
                ent.OM_Vel = ent.OM_Vel or Vector(0, 0, 0)
                ent.OM_LastYaw = ent.OM_LastYaw or cmd:GetViewAngles().y

                local ang = cmd:GetViewAngles()
                local curYaw = ang.y
                local yawDelta = math.AngleDifference(curYaw, ent.OM_LastYaw)
                ent.OM_LastYaw = curYaw

                local wishSpeed = ply:GetNW2Float("OM_MoveForwardSpeed")

                local yawAng = Angle(0, ang.y, 0)
                local forwardDir = yawAng:Forward()
                local sideDir = -yawAng:Right() * yawDelta * 5

                local wishVel = (forwardDir * wishSpeed) + sideDir

                local accelBias = 0.018
                local friction  = 0.992
                local stopFric  = 0.75
                local maxSpeed  = wishSpeed * 1.7

                ent.OM_Vel = LerpVector(accelBias, ent.OM_Vel, wishVel)

                if wishSpeed ~= 0 then
                    ent.OM_Vel = ent.OM_Vel * friction
                else
                    ent.OM_Vel = ent.OM_Vel * stopFric
                end

                local spd = ent.OM_Vel:Length()
                if spd > maxSpeed then
                    ent.OM_Vel = ent.OM_Vel * (maxSpeed / spd)
                end

                local vel = ply:GetVelocity()
                local speed = vel:Length()

                if speed > 5 then
                    local dir = vel:GetNormalized()
                    local tr = util.TraceLine({
                        start = ply:GetPos(),
                        endpos = ply:GetPos() + dir * math.min(speed * FrameTime() * 6, 28),
                        filter = ply,
                        mask = MASK_PLAYERSOLID
                    })

                    if tr.Hit and tr.HitNormal.z < 0.6 then
                        local push = math.max(dir:Dot(-tr.HitNormal), 0)

                        if push > 0.1 then
                            local slow = Lerp(push, 0.8, 0.5)
                            ent.OM_Vel = ent.OM_Vel * slow
                            ent.OM_Vel = ent.OM_Vel - tr.HitNormal * ent.OM_Vel:Dot(tr.HitNormal) * 0.5
                        end
                    end
                end

                cmd:SetForwardMove(ent.OM_Vel:Dot(forwardDir))
                cmd:SetSideMove(ent.OM_Vel:Dot(yawAng:Right()))

                local curVel = ply:GetVelocity()
                local curSpeed = curVel:Length() * 1.1
                local entSpeed = ent.OM_Vel:Length()

                if curSpeed < entSpeed then
                    ent.OM_Vel = LerpVector(0.3, ent.OM_Vel, curVel)
                elseif curSpeed > entSpeed then
                    ent.OM_Vel = LerpVector(0.05, ent.OM_Vel, curVel)
                end

            elseif ply:GetNW2Float("OM_MoveForward_WithSideways2") >= CurTime() then
                ent.OM_Vel = ent.OM_Vel or Vector(0, 0, 0)
                ent.OM_LastYaw = ent.OM_LastYaw or cmd:GetViewAngles().y

                local ang = cmd:GetViewAngles()
                local curYaw = ang.y
                local yawDelta = math.AngleDifference(curYaw, ent.OM_LastYaw)
                ent.OM_LastYaw = curYaw

                local wishSpeed = ply:GetNW2Float("OM_MoveForwardSpeed")

                local yawAng = Angle(0, ang.y, 0)
                local forwardDir = yawAng:Forward()
                local sideDir = -yawAng:Right() * yawDelta * 5

                local wishVel = (forwardDir * wishSpeed) + sideDir

                local accelBias = 0.09
                local friction  = 0.997
                local stopFric  = 0.9
                local maxSpeed  = wishSpeed * 1.5

                ent.OM_Vel = LerpVector(accelBias, ent.OM_Vel, wishVel)

                if wishSpeed ~= 0 then
                    ent.OM_Vel = ent.OM_Vel * friction
                else
                    ent.OM_Vel = ent.OM_Vel * stopFric
                end

                local spd = ent.OM_Vel:Length()
                if spd > maxSpeed then
                    ent.OM_Vel = ent.OM_Vel * (maxSpeed / spd)
                end

                local vel = ply:GetVelocity()
                local speed = vel:Length()

                if speed > 5 then
                    local dir = vel:GetNormalized()
                    local tr = util.TraceLine({
                        start = ply:GetPos(),
                        endpos = ply:GetPos() + dir * math.min(speed * FrameTime() * 6, 28),
                        filter = ply,
                        mask = MASK_PLAYERSOLID
                    })

                    if tr.Hit and tr.HitNormal.z < 0.6 then
                        local push = math.max(dir:Dot(-tr.HitNormal), 0)

                        if push > 0.1 then
                            local slow = Lerp(push, 0.8, 0.5)
                            ent.OM_Vel = ent.OM_Vel * slow
                            ent.OM_Vel = ent.OM_Vel - tr.HitNormal * ent.OM_Vel:Dot(tr.HitNormal) * 0.5
                        end
                    end
                end

                cmd:SetForwardMove(ent.OM_Vel:Dot(forwardDir))
                cmd:SetSideMove(ent.OM_Vel:Dot(yawAng:Right()))

                local curVel = ply:GetVelocity()
                local curSpeed = curVel:Length() * 1.1
                local entSpeed = ent.OM_Vel:Length()

                if curSpeed < entSpeed then
                    ent.OM_Vel = LerpVector(0.3, ent.OM_Vel, curVel)
                elseif curSpeed > entSpeed then
                    ent.OM_Vel = LerpVector(0.05, ent.OM_Vel, curVel)
                end
            else
                ent.OM_Vel = nil
                ent.OM_LastYaw = nil
            end
        end


        if ply:GetNW2Float("OM_MoveForward") >= CurTime() then
            cmd:SetForwardMove(ply:GetNW2Float("OM_MoveForwardSpeed"))
            cmd:SetSideMove(0)
        end

        if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime()
        or ply:GetNW2Float("OM_NoMovement_noodles") >= CurTime() then

            cmd:SetForwardMove(0)
            cmd:SetSideMove(0)
            cmd:SetUpMove(0)
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                cmd:ClearButtons()
            end
        end

        if ply:GetNWFloat("OM_FireSlowdown", 0) >= CurTime() then
            cmd:SetForwardMove(cmd:GetForwardMove() * 0.75)
            cmd:SetSideMove(cmd:GetSideMove() * 0.75)
            cmd:SetUpMove(cmd:GetUpMove() * 0.75)
        end
    end)
end

hook.Add("SetupMove", "DisablePlayerMovement_OM", function(ply, mv, cmd)
    --print(ply:GetVelocity():Length())
    if ply:GetNW2Float("NoJumpingCooldown_OM") >= CurTime() then
        mv:SetButtons(0)
    end
    if ply:GetNW2Float("OM_NoMovement_noodles_jump") >= CurTime() then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
    end

    if ply:GetNW2Float("OM_SetVelocity_pos") > CurTime() then
        mv:SetVelocity( ply:GetNW2Vector("OM_SetVelocity_Vector") )
    end

    if ply:GetNW2Float("om_nojumping") > CurTime() then
        if mv:KeyDown(IN_JUMP) then
            mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
        end
    end

    if SERVER then
        local ent = ply.pk_pill_ent
        if IsValid(ent) and ( ply:GetNW2Bool("OM_character") or ply:GetNW2Bool("OM_character_monster")) then
            
            if ply:GetNW2Float("RollEndTime_om") > CurTime() then
                mv:SetVelocity( ply:GetNW2Vector("RollDir_om") )
                if mv:KeyDown(IN_JUMP) then
                    mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
                end
            else
                if GetConVar("OUTCOMEMEMORIES_N_bhopping"):GetBool() then
                else
                    if mv:KeyDown(IN_JUMP) then
                        if (ent:GetNW2Float("OM_JumpCooldown")) < CurTime() and not ent:GetNW2Bool("OM_JumpBoolean") then
                            ent:SetNW2Bool("OM_JumpBoolean", true)
                            ent:SetNW2Float("OM_JumpBoolean_eo", CurTime()+0.1)
                            if ply.pk_pill_ent.OM_2ndmethodforjumping then
                                ply.pk_pill_ent:SetNW2Float("OM_JumpCooldown", (ply.pk_pill_ent.formTable.Outcomememories_stats.moveSpeed.jumpcd() + CurTime()) or (1 + CurTime()))
                            end
                        else
                            mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
                        end
                    end
                end
            end

            if ply:IsOnGround() then
                if ply.pk_pill_ent:GetNW2Bool("OM_JumpBoolean") and ent:GetNW2Float("OM_JumpBoolean_eo") < CurTime() then
                    if not ply.pk_pill_ent.OM_2ndmethodforjumping then
                        ply.pk_pill_ent:SetNW2Float("OM_JumpCooldown", (ply.pk_pill_ent.formTable.Outcomememories_stats.moveSpeed.jumpcd() + CurTime()) or (1 + CurTime()))
                    end
                    ply.pk_pill_ent:SetNW2Float("OM_JumpBoolean", false)
                end
            end
            if GetConVar("OUTCOMEMEMORIES_N_canmovewhileinair"):GetBool() then
                if ent:GetNW2Bool("OM_airmovement_disabled") or ent:GetNW2Float("OM_airmovement_disabled_float") > CurTime() then
                else

                    if not ply:OnGround() then
                        if ply:WaterLevel() < 1 then
                            local ang = mv:GetMoveAngles()
                            ang.p = 0
                            ang.r = 0

                            local wishDir = Vector(0, 0, 0)
                            wishDir:Add(ang:Forward() * cmd:GetForwardMove())
                            wishDir:Add(ang:Right() * cmd:GetSideMove())

                            local vel = mv:GetVelocity()
                            local horizVel = Vector(vel.x, vel.y, 0)

                            if wishDir:LengthSqr() > 0 then
                                wishDir:Normalize()
                            end

                            local maxSpeed = cmd:KeyDown(IN_SPEED) and ply:GetRunSpeed() or ply:GetWalkSpeed()

                            local airAccel = 7

                            local wishVel = wishDir * maxSpeed

                            local oldSpeed = horizVel:Length()

                            if oldSpeed > 0 and wishVel:LengthSqr() > 0 then
                                local dot = horizVel:GetNormalized():Dot(wishVel:GetNormalized())

                                if dot < 0 then
                                    local turnStrength = math.Clamp(1 + dot, 0, 1)

                                    local redirect = wishVel * (1 - turnStrength)

                                    horizVel = horizVel + redirect * FrameTime() * airAccel
                                else
                                    local accel = wishVel - horizVel
                                    horizVel = horizVel + accel * FrameTime() * airAccel
                                end
                            end


                            local speed = horizVel:Length()

                            if speed > maxSpeed then
                                local excess = speed - maxSpeed

                                local dragStrength = 1.75
                                local drag = math.min(excess * FrameTime() * dragStrength, excess)

                                horizVel = horizVel - horizVel:GetNormalized() * drag
                            end

                            mv:SetVelocity(Vector(horizVel.x, horizVel.y, vel.z))
                        end
                    end
                end
            end
            if ply:GetNW2Float("OM_lowerFriction") >= CurTime() then -- and ply:GetNW2Float("OM_lowerFriction_not") < CurTime() 
                ply:SetFriction(ent:GetNW2Float('OM_friction'))
                mv:SetSideSpeed(0)
                mv:SetForwardSpeed(0)
            else
                ply:SetFriction(1)
            end
        end
    end

    if ply:GetNW2Float("OM_MoveForward") >= CurTime() then
        mv:SetForwardSpeed(ply:GetNW2Float("OM_MoveForwardSpeed"))
        mv:SetSideSpeed(0)
    end

    if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() or ply:GetNW2Float("OM_NoMovement_noodles") >= CurTime() then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
        mv:SetUpSpeed(0)
        mv:SetButtons(0)
    end

    if ply:GetNWFloat("OM_FireSlowdown", 0) >= CurTime() then
        mv:SetMaxSpeed(mv:GetMaxSpeed() * 0.75)
        mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.75)

        mv:SetForwardSpeed(mv:GetForwardSpeed() * 0.75)
        mv:SetSideSpeed(mv:GetSideSpeed() * 0.75)
    end
    
    --if ply:GetNW2Bool("OM_character_monster") then
    --end
end)

if SERVER then--
    timer.Simple(1,function()
        if SERVER then else return end
        OM_AddSpeedConfigeration(function(entity)
            if SERVER and entity:GetNWFloat("OM_FireSlowdown", 0) >= CurTime() then
                return 0.75
            end
            return 1
        end)
    end)
end

-- PILL CODE --
if SERVER then
end

function OM_PILL_speedThink(ply, ent)
    if SERVER then
        if GetConVar("OUTCOMEMEMORIES_N_rolling"):GetBool() then

            if not ent.RollingInitialize_om then
                ent.RollingInitialize_om = true
                ply:SetNW2Float("NewZ_OM", 0)
            end

            if not ply:IsOnGround() then
                ply:SetNW2Float("NewZ_OM", ply:GetNW2Float("OldZ_OM", 0)-ply:GetPos().Z)
            else
                ply:SetNW2Float("OldZ_OM", ply:GetPos().Z)
            end


            if ply:GetNW2Float("NewZ_OM", 0) > 175 and ply:IsOnGround() then
                if inWater or onFloater then
                else
                    local puppet = ent:GetPuppet()
                    if IsValid(puppet) then
                        if not ent.formTable.ShouldRoll_om then
                        else
                            if ent.formTable:ShouldRoll_om(ply,ent) then
                                
                                ply:SetNW2Float("OldZ_OM", ply:GetPos().Z)
                                ply:SetNW2Float("NewZ_OM", ply:GetNW2Float("OldZ_OM", 0)-ply:GetPos().Z)

                                local currentplyvelocity = ply:GetVelocity()

                                if Vector(currentplyvelocity.x, currentplyvelocity.y, 0):Length() > 45 then
                                    local rollingspeed = ent.formTable.Outcomememories_stats.moveSpeed.Rolling and ent.formTable.Outcomememories_stats.moveSpeed.Rolling(ply,ent) or 1500
                                    local forwardDir = puppet:GetAngles():Forward() * rollingspeed

                                    ply:SetNW2Float("RollEndTime_om", CurTime()+0.5)
                                    ent:SetNW2Float("RollEndTime_om", CurTime()+0.5)
                                    ply:SetNW2Vector("RollDir_om", forwardDir)
                                end
                            end
                        end
                    end
                end
            end

            if ent:GetNW2Float("RollEndTime_om") > CurTime() then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
            end
        end

        if not ent.disablemovecode_om then
            local Currentwalkspeed = ent.formTable.Outcomememories_stats.moveSpeed.walk(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.walk or 200
            local Currentrunspeed = ent.formTable.Outcomememories_stats.moveSpeed.run(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.run or 400
            local Currentcrouchspeed = ent.formTable.Outcomememories_stats.moveSpeed.ducked(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.ducked or 200
            local Currentjump = ent.formTable.Outcomememories_stats.moveSpeed.jumppower(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.jumppower or 400
            for i,v in pairs(ent.formTable.speedhandeler_om.modifiers) do
                local modifier = v(ply, ent)
                Currentwalkspeed = Currentwalkspeed + modifier["Walk"] 
                Currentrunspeed = Currentrunspeed + modifier["Run"]
                Currentcrouchspeed = Currentcrouchspeed + modifier["Crouch"]
                Currentjump = Currentjump + modifier["Jump"]
            end

            if ply:GetNW2Bool("Survivor_Downed_OM") then
                Currentwalkspeed = 20
                Currentrunspeed = 20
                Currentcrouchspeed = 20
                Currentjump = 1
            end
            
            local factor = ent:GetNW2Float("OM_SpeedBoost_Damage")
            ply:SetWalkSpeed(Currentwalkspeed + factor )
            ply:SetRunSpeed(Currentrunspeed + factor )
            ply:SetCrouchedWalkSpeed(Currentcrouchspeed + factor )
            ply:SetJumpPower(Currentjump )
        end
    end
end

local thinkcode = function(thinktable)


    local self = thinktable.self
    local ent = thinktable.ent

    local currentanim = 'idle'
    local ply = self:GetPillUser()
    local puppet = self:GetPuppet()
    if not IsValid(puppet) or not IsValid(ply) then return end
    local vel = ply:GetVelocity():Length()

    if SERVER then
        --Anims
        local anims = table.Copy(self.formTable.anims.default or {})
        table.Merge(anims, (IsValid(ply:GetActiveWeapon()) and self.formTable.anims[ply:GetActiveWeapon():GetHoldType()]) or (self.forceAnimSet and self.formTable.anims[self.forceAnimSet]) or {})
        local anim
        --local useSeqVel=true
        local overrideRate

        if (not self.anim or not anims[self.anim]) then
            self.animFreeze = nil
            self.animStart = nil
        end

        if self.animFreeze and not self.plyFrozen then
            ply:SetWalkSpeed(ply:GetWalkSpeed() / 2)
            ply:SetRunSpeed(ply:GetWalkSpeed() / 2)
            self.plyFrozen = true
        elseif not self.animFreeze and self.plyFrozen then
            local speed = self.formTable.moveSpeed or {}
            ply:SetWalkSpeed(speed.walk or 200)
            ply:SetRunSpeed(speed.run or speed.walk or 500)
            self.plyFrozen = nil
        end

        if self.anim and anims[self.anim] then
            anim = anims[self.anim]
            overrideRate = anims[self.anim .. "_rate"] or 1
            local cycle = puppet:GetCycle()

            if not self.animStart then
                if cycle == 1 or (self.animCycle and self.animCycle > cycle) or (string.lower(anim) ~= string.lower(puppet:GetSequenceName(puppet:GetSequence()))) then
                    self.anim = nil
                    self.animCycle = nil

                    --if self.animFreeze then
                    --    self.animFreeze = nil
                    --end
                elseif self.animCycle then
                    self.animCycle = cycle
                end
            end
        elseif self.tickAnim and anims[self.tickAnim] then
            anim = anims[self.tickAnim]
            overrideRate = anims[self.tickAnim .. "_rate"] or 1
            self.tickAnim = nil
        elseif self.burrowed then
            anim = anims["burrow_loop"]
        elseif ply:WaterLevel() > 2 then
            anim = anims["swim"] or anims["glide"] or anims["idle"]
        elseif ply:IsOnGround() then
            if ply:Crouching() then
                if vel > ply:GetCrouchedWalkSpeed() / 4 then
                    anim = anims["crouch_walk"] or anims["crouch"] or anims["walk"] or anims["idle"]
                else
                    anim = anims["crouch"] or anims["idle"]
                end
            else
                if vel > (ply:GetWalkSpeed() + ply:GetRunSpeed()) / 2 then
                    anim = anims["run"] or anims["walk"] or anims["idle"]
                elseif vel > ply:GetWalkSpeed() / 4 then
                    anim = anims["walk"] or anims["idle"]
                else
                    anim = anims["idle"]
                end
            end
        else
            anim = anims["glide"] or anims["idle"]
        end

        if anim == anims["idle"] or anim == anims["crouch"] then
            overrideRate = 1
        end
        self:SetNW2String("Animlastplayed", anim)

        local ShouldAlternate = table.Copy(self.formTable.anims.ShouldAlternate or {})
        if type(ShouldAlternate[anim]) == "function" and ShouldAlternate[anim](self) then
            if ShouldAlternate[anim](self) ~= nil and isstring(ShouldAlternate[anim](self)) then
                anim = ShouldAlternate[anim](self)
            end
        end
        
        --print(self.animFreeze)

        if (anim and puppet:GetSequence() ~= puppet:LookupSequence(anim)) or self.animStart or (self.formTable.autoRestartAnims and puppet:GetCycle() == 1) then
            if self.currentanim ~= puppet:GetSequence() then
                if not animFreeze then 
                    puppet:ResetSequence(puppet:LookupSequence(anim))
                    puppet:SetCycle(0)
                    self.animCycle = 0
                    self.currentanim = anim
                end
            end
        end


        self.animStart = nil

        --Aimage
        if self.formTable.aim then
            local yaw = math.AngleDifference(ply:EyeAngles().y, puppet:GetAngles().y)
            puppet:SetPoseParameter(self.formTable.aim.xPose, yaw)
            local pitch = math.AngleDifference(ply:EyeAngles().p, puppet:GetAngles().p)
            puppet:SetPoseParameter(self.formTable.aim.yPose, pitch)
        end

        --tick attack
        if ply:KeyDown(IN_ATTACK) and self.formTable.attack and self.formTable.attack.mode == "tick" then
            self.formTable.attack.func(ply, self, self.formTable.attack)
        end

        if ply:KeyDown(IN_ATTACK2) and self.formTable.attack2 and self.formTable.attack2.mode == "tick" then
            self.formTable.attack2.func(ply, self, self.formTable.attack2)
        end

        --if !IsValid(ply) then self:NextThink(CurTime()) return true end
        --wepon-no longer SO hackey
        if not self.formTable.hideWeapons then
            local realWep = self:GetPillUser():GetActiveWeapon()

            --&&self:GetPillUser()!=ply or pk_pills.var_thirdperson:GetBool()) then
            if IsValid(realWep) and realWep:GetModel() ~= "" then
                --hiding the real thing [BROKEN]
                --[[if realWep:GetRenderMode()!=RENDERMODE_NONE then
                    realWep:SetRenderMode(RENDERMODE_NONE)
                end]]
                if realWep.pill_attachment then
                    if IsValid(self.wepmdl) then
                        self.wepmdl:Remove()
                    end

                    self.wepmdl = ents.Create("pill_attachment_wep")
                    self.wepmdl:SetParent(self:GetPuppet())
                    self.wepmdl:SetModel(realWep:GetModel())
                    self.wepmdl.attachment = realWep.pill_attachment
                    self.wepmdl:Spawn()

                    if realWep.pill_offset then
                        self.wepmdl:SetWepOffset(realWep.pill_offset)
                    end

                    if realWep.pill_angle then
                        self.wepmdl:SetWepAng(realWep.pill_angle)
                    end

                    realWep.pill_proxy = self.wepmdl
                elseif not IsValid(self.wepmdl) then
                    self.wepmdl = ents.Create("pill_attachment_wep")
                    self.wepmdl:SetParent(self:GetPuppet())
                    self.wepmdl:SetModel(realWep:GetModel())
                    self.wepmdl:Spawn()
                    realWep.pill_proxy = self.wepmdl
                elseif self.wepmdl:GetModel() ~= realWep:GetModel() then
                    self.wepmdl:SetModel(realWep:GetModel())
                end
            elseif IsValid(self.wepmdl) then
                self.wepmdl:Remove()
            end
        end
    else
        if self:GetPillUser() ~= LocalPlayer() or pk_pills.convars.cl_thirdperson:GetBool() then
            puppet:SetNoDraw(false)
        else
            puppet:SetNoDraw(true)
        end

        local realWep = self:GetPillUser():GetActiveWeapon()

        if IsValid(realWep) and realWep:GetModel() ~= "" and not realWep:GetNoDraw() then
            realWep:SetNoDraw(true)
        end
    end

    --Align pos and angles with player

    local animsshouldspn = table.Copy(self.formTable.anims.ShouldPosition or {})
    local SetPosition

    if animsshouldspn[currentanim] or (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) then
        local typeofitem = (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) or animsshouldspn[currentanim]

        local CurrentPos

        if SERVER then CurrentPos = puppet:GetPos() else CurrentPos = puppet:GetRenderOrigin() end

        local lerpspeed = 7

        local animsshouldspnLerpSpeed = table.Copy(self.formTable.anims.ShouldPosition_lerpspeed or {})
        if animsshouldspnLerpSpeed[currentanim] or (type(animsshouldspnLerpSpeed[currentanim]) == "function" and animsshouldspnLerpSpeed[currentanim](self)) then
            lerpspeed = (type(animsshouldspnLerpSpeed[currentanim]) == "function" and animsshouldspnLerpSpeed[currentanim](self)) or animsshouldspnLerpSpeed[currentanim]
        end

        if isvector(typeofitem) then
            SetPosition = LerpVector(FrameTime() * lerpspeed, CurrentPos, typeofitem)
        end
    end
    if not SetPosition then
        if SERVER then puppet:SetPos(ply:GetPos()) else puppet:SetRenderOrigin(ply:GetPos()) end
    else
        if SERVER then puppet:SetPos(CurrentPos) else puppet:SetRenderOrigin(CurrentPos) end
    end
    
    currentanim = self:GetNW2String("Animlastplayed")
    
    --if vel > 0 or math.abs(math.AngleDifference(puppet:GetAngles().y, ply:EyeAngles().y)) > 350 then

    local animsshouldspn = table.Copy(self.formTable.anims.ShouldMoveRotate or {})
    
    if SERVER then
        local rate = 1
        local animsshouldspn = table.Copy(self.formTable.anims.animrates or {})
        if animsshouldspn[currentanim] or (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) then
            rate = (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) or animsshouldspn[currentanim]
        end
        if rate > 12 then
            rate = 12
        end
        puppet:SetPlaybackRate(rate)
    end
    
    if animsshouldspn[currentanim] or (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) then
        local typeofitem = (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) or animsshouldspn[currentanim]

        local SetAngleto
        local curAng

        local lerpspeed = 7

        local animsshouldspnLerpSpeed = table.Copy(self.formTable.anims.ShouldMoveRotate_lerpspeed or {})
        if animsshouldspnLerpSpeed[currentanim] or (type(animsshouldspnLerpSpeed[currentanim]) == "function" and animsshouldspnLerpSpeed[currentanim](self)) then
            lerpspeed = (type(animsshouldspnLerpSpeed[currentanim]) == "function" and animsshouldspnLerpSpeed[currentanim](self)) or animsshouldspnLerpSpeed[currentanim]
        end

        local lerpfactor = math.min(FrameTime() * lerpspeed, 1)

        if SERVER then curAng = puppet:GetAngles() else curAng = puppet:GetRenderAngles() or Angle(0,0,0) end
        if typeofitem == "notshftlock" then
            local vel = ply:GetVelocity()
            vel.z = 0
            if vel:Length2DSqr() > 1 then
                local targetAng = vel:Angle()
                targetAng.p = 0
                targetAng.r = 0

                SetAngleto = LerpAngle(lerpfactor, curAng, targetAng)
            end
        elseif typeofitem == "assignedagnles_instant" then SetAngleto = self:GetNW2Angle("pill_assignedangle")
        elseif typeofitem == "shiftlock" then
            local angs = ply:EyeAngles()
            angs.p = 0
            SetAngleto = LerpAngle(lerpfactor, curAng, angs)
        elseif typeofitem == "Playerangles" then
            local angs = ply:GetAngles()
            angs.p = 0
            SetAngleto = LerpAngle(lerpfactor, curAng, angs)
        elseif typeofitem == "assignedagnles" then SetAngleto = LerpAngle(lerpfactor, curAng, self:GetNW2Angle("pill_assignedangle"))
        elseif typeofitem == "notanything" then SetAngleto = curAng
        end

        if SetAngleto then
            if SERVER then puppet:SetAngles(SetAngleto) end
            if CLIENT then puppet:SetRenderAngles(SetAngleto) end
        end
    end

    if self.formTable.think_noodles_om_pill then
        self.formTable.think_noodles_om_pill(ply, ent)
    end
end

if SERVER then
    util.AddNetworkString("clientside_thinkcodeinitialize_OM")
else
    net.Receive("clientside_thinkcodeinitialize_OM", function()
        local ply = LocalPlayer()
        local ent = net.ReadEntity()

        ent.Think = function()
            thinkcode({
                self = ent,
                ent = ent,
            })

            ent:NextThink(CurTime())
            return ent
        end
    end)
end

hook.Add( "PreRegisterSENT", "pill_omoveride_puppet", function( ent, class )
    if class == "pill_puppet" then
        local PuppetEntity = table.Copy(ent)
        
        PuppetEntity.Type = "anim"
        PuppetEntity.AutomaticFrameAdvance = true
        PuppetEntity.Think = function(self)
            self:NextThink(CurTime())
            return true
        end

        scripted_ents.Register( PuppetEntity, "pill_omoveride_puppet" )
    end
end )

hook.Add("OnEntityCreated", "OM_noodles_pill_initialize", function(ent)
    timer.Simple(0, function()
        if !IsValid(ent) then return end
        if ent:GetClass() == "pill_ent_costume" then
            if not ent then return end
            if ent.formTable then
                local PuppetEntity = ent:GetPuppet()
                local entityply = ent:GetPillUser()
                local hookName = "ThinkHookForEntity_OM_" .. ent:EntIndex()


                if ent.formTable.Outcomememories then
                    --print(11)
                    if SERVER then
                        PuppetEntity:Remove()
                        
                        local puppet = ents.Create("pill_omoveride_puppet")
                        puppet:SetModel(ent.formTable.model or "models/Humans/corpse1.mdl")
                        
                        if isfunction(puppet.SetPillForm) then
                            puppet:SetPillForm(ent:GetPillForm())
                        end

                        if isfunction(puppet.SetPillCostume) then
                            puppet:SetPillCostume(ent)
                        end

                        if isfunction(puppet.SetPillUser) then
                            puppet:SetPillUser(entityply)
                        end

                        puppet:Spawn()

                        ent:DeleteOnRemove(puppet)
                        ent:SetPuppet(puppet)

                        PuppetEntity = puppet
                    end
                end

                if ent.formTable.HandleAnimEvent_Noodles_OM_pill then
                    --print(222)
                    local PuppetEntity = ent:GetPuppet()
                    local entityply = ent:GetPillUser()

                    if IsValid(PuppetEntity) then
                        function PuppetEntity:HandleAnimEvent(event, eventTime, cycle, eventType, options)
                            ent.formTable.HandleAnimEvent_Noodles_OM_pill(entityply, ent, options)
                            return true
                        end
                    end
                end

                if ent.formTable.noodles_OM_survivor_initialize then
                    --print(33)
                    local tablevarable = {["player"] = entityply, ["entity"] = ent, ["puppet"] = PuppetEntity}
                    timer.Simple(0.1, function()
                        if !IsValid(ent) then return end

                        ent.PillAnim = function(e,name, freeze)
                            local anims = table.Copy(ent.formTable.anims.default or {})
                            table.Merge(anims, (IsValid(entityply:GetActiveWeapon()) and ent.formTable.anims[entityply:GetActiveWeapon():GetHoldType()]) or (ent.forceAnimSet and ent.formTable.anims[ent.forceAnimSet]) or {})
                            if not anims[name] then return end

                            ent.anim = name
                            ent.animStart = true
                            ent.animFreeze = true
                        end

                        PuppetEntity.SetupDataTables = function()
                            PuppetEntity:NetworkVar("String", 0, "PillForm")
                            PuppetEntity:NetworkVar("Entity", 1, "PillCostume")
                            PuppetEntity:NetworkVar("Entity", 2, "PillUser")
                        end

                        PuppetEntity.Initialize = function()
                            PuppetEntity:SetRenderMode(RENDERMODE_TRANSALPHA)
                        end

                        PuppetEntity.Draw = function()
                            PuppetEntity:DrawModel()
                        end

                        PuppetEntity.DrawTranslucent = function()
                            PuppetEntity:Draw()
                        end
                        
                        PuppetEntity.QueueEvent = function()
                        end

                        PuppetEntity.RunAI = function()
                        end

                        ent.formTable:noodles_OM_survivor_initialize(tablevarable,tablevarable,tablevarable)

                        local self = ent
                        self.formTable = pk_pills.getPillTable(self:GetPillForm())
                        local ply = self:GetPillUser()

                        if not self.formTable or not IsValid(ply) then
                            self:Remove()

                            return
                        end

                        local hull = self.formTable.hull or Vector(32, 32, 72)
                        local duckBy = self.formTable.duckBy or (self.formTable.hull and 0 or 36)
                        ply:SetHull(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z))
                        ply:SetHullDuck(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z - duckBy or 0))--
                        ply:SetRenderMode(RENDERMODE_NONE)
                        pk_pills.mapEnt(ply, nil)

                        if SERVER then
                            if ply:FlashlightIsOn() then
                                ply:Flashlight(false)
                            end

                            ply:Freeze(false)
                            ply:SetNotSolid(false)
                            ply:DrawViewModel(false)

                            local camOffset = Vector(0, 0, 64) --
                            --clside this?
                            ply:SetStepSize(hull.z / 4)
                            ply:SetViewOffset(camOffset)
                            ply:SetViewOffsetDucked(camOffset - Vector(0, 0, duckBy*0.15) )
                        end
                        pk_pills.mapEnt(ply, self)

                    end)

                    local self = ent

                    ent.DoKeyPress = function(_, ply, key)
                        if key == IN_ATTACK and self.formTable.attack and self.formTable.attack.mode == "trigger" then
                            self.formTable.attack.func(ply, self, self.formTable.attack)
                        end
                        if key == IN_ATTACK2 and self.formTable.attack2 and self.formTable.attack2.mode == "trigger" then
                            self.formTable.attack2.func(ply, self, self.formTable.attack2)
                        end
                        if key == IN_RELOAD and self.formTable.reload then
                            self.formTable.reload(ply, self)
                        end
                        if key == IN_DUCK then
                        end
                    end

                    local ply = self:GetPillUser()
                    if SERVER then

                        ent.Think = function()
                            thinkcode({
                                self = self,
                                ent = ent,
                            })

                            self:NextThink(CurTime())
                            return true
                        end
                        timer.Simple(0.1,function()
                            if !IsValid(ent) then return end
                            net.Start("clientside_thinkcodeinitialize_OM")
                                net.WriteEntity(ent)
                            net.Broadcast()
                        end)
                    end
                end
            end
        end
    end)
end)

-- CAMERA CODE
if SERVER then
    util.AddNetworkString("OM_CameraCode_n")
else
    local preservedmats = {
        ["OM_icon"] = Material("icons/Polygon_of_doom.png"),
        ["OM_icon_monster"] = Material("icons/Polygon_of_DEVI.png"),
        ["Ability_arrow"] = Material("icons/Ability_arrow.png"),
        ["health_bar_remake"] = Material("icons/health_bar_remake.png"),
        ["om_dirt"] = Material("icons/om_dirt.png"),
        ["dodge_bar_new"] = Material("icons/dodge_bar_new.png"),
        ["dodge_bar_meter"] = Material("icons/dodge_bar_meter.png"),
        ["cooldown_square_surv"] = Material("icons/cooldown_square_surv.png"),
        ["cooldown_square_exe"] = Material("icons/cooldown_square_exe.png"),
        ["self_revive"] = Material("icons/self_revive.png"),
        ["Clash_arrows"] = Material("icons/Clash_arrows.png"),
        ["barprogressio"] = Material("icons/barprogressio.png"),
        ["Clash_bar"] = Material("icons/Clash_bar.png"),
        ["Clash_arrows_pressed"] = Material("icons/Clash_arrows_pressed.png"),
        ["downed_blood"] = Material("icons/downed_blood.png"),
        ["clash_arrows_circle"] = Material("icons/clash_arrows_circle.png"),
    }
    
    net.Receive("OM_CameraCode_n", function()
        local ply = LocalPlayer()
        local ent = net.ReadEntity()

        timer.Simple(0,function()
            if !IsValid(ent) then return end

            local savedCalcViewHooks = {}

            local calcViewHooks = hook.GetTable().CalcView or {}
            for k, v in pairs(calcViewHooks) do
                if k ~= hookID then
                    savedCalcViewHooks[k] = v
                    hook.Remove("CalcView", k)
                end
            end




            local mdl = nil

            local UI_Variables = {
                omBarLerp = {
                    y = 0,
                    alpha = 0,
                },
                cooldownLerp = {},
                iconLerp = {},
                healthLerp = {
                    frac = 1,
                    hp = 0
                },
                omBarValueLerp = {
                    factor = 0,
                    value = 0
                },
                downedalpha = 0
            }
            
            local oldvariabletable = UI_Variables

            local name6 = "momo_calcview_".. ply:Nick()
            local name5 = "om_remove_n_".. ply:Nick()
            local name4 = "LowHealthRedEffect_OM".. ply:Nick()
            local name3 = "drawUI_OM_lnz".. ply:Nick()
            hook.Add("EntityRemoved", name5, function(removedent)
                if removedent == ent then
                    hook.Remove('CalcView', name6)
                    hook.Remove("EntityRemoved", name5)
                    hook.Remove("RenderScreenspaceEffects", name4)
                    hook.Remove("HUDPaint", name3)
                    for savedID, func in pairs(savedCalcViewHooks) do
                        hook.Add("CalcView", savedID, func)
                    end
                    savedCalcViewHooks = {}

                    if mdl then mdl:Remove() end
                end
            end)


            hook.Add("HUDPaint", name3, function()
                local ply = LocalPlayer()
                local pillentity = LocalPlayer().pk_pill_ent
                local isdrgbase = false

                if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
                    pillentity = ply:GetNW2Entity("DrGBasePossessing")
                    isdrgbase = true
                end

                local screenW, screenH = ScrW(), ScrH()
                local middlex, middley = screenW * 0.5, screenH * 0.5
                local iconsize = screenW / 13

                if IsValid(pillentity) and pillentity.formTable and pillentity.formTable.Outcomememories then
                    -- custom UI stuff 
                    if pillentity.formTable.OM_UI_custom_start then
                        pillentity.formTable.OM_UI_custom_start(ply,pillentity)
                    end

                    -- puppet model
                    if LocalPlayer():GetInfoNum("om_pills_action_3dmodel", 0) == 1 then 
                        if (isdrgbase and not pillentity:GetNW2Bool("DrGBaseGodMode")) or (not isdrgbase and not ply:HasGodMode()) then
                            local offsettable = pillentity.formTable.OM_3D_Render or {}

                            local yaxis_health_bg = screenH - iconsize * 5
                            if LocalPlayer():GetInfoNum("om_pills_action_hp", 0) == 1 then 
                                surface.SetDrawColor(255, 255, 255, 255)
                                surface.SetMaterial(preservedmats["om_dirt"])
                                surface.DrawTexturedRect(0, yaxis_health_bg+iconsize * 1.5, iconsize * 4.5 * 0.75, iconsize * 4.5 * 0.75)
                                surface.DrawTexturedRect(0, yaxis_health_bg+iconsize * 1.5, iconsize * 4.5 * 0.75, iconsize * 4.5 * 0.75)
                                surface.DrawTexturedRect(0, yaxis_health_bg+iconsize * 1.5, iconsize * 4.5 * 0.75, iconsize * 4.5 * 0.75)
                            end

                            if IsValid(pillentity:GetPuppet()) then
                                if not IsValid(mdl) then
                                    mdl = ClientsideModel(pillentity:GetPuppet():GetModel(), RENDERGROUP_OPAQUE)
                                    mdl:SetModelScale(1.5 + (offsettable.scaleoffset or 0) )
                                    mdl:SetNoDraw(true)

                                    local seqID = mdl:LookupSequence("idle")
                                    mdl:SetSequence(seqID ~= -1 and seqID or 0)
                                    mdl:SetCycle(0)
                                    mdl:SetPlaybackRate(1)
                                elseif mdl:GetModel() ~= pillentity:GetPuppet():GetModel() then
                                    mdl:Remove()
                                    mdl = nil
                                end

                                if IsValid(mdl) then
                                    mdl:FrameAdvance(FrameTime())

                                        cam.Start3D(Vector(0,0,0), Angle(0,0,0), 70,
                                            0,
                                            screenH - iconsize * 5.5,
                                            iconsize * 4,
                                            iconsize * 4.7
                                        )
                                        render.SuppressEngineLighting(true)
                                        render.ResetModelLighting(0, 0, 0)
                                        mdl:SetPos(Vector(100, 20, -70) + (offsettable.vectoroffset or Vector(0,0,0) ) )
                                        mdl:SetAngles(Angle(-5, -140, 0) + (offsettable.angleOffset or Angle(0,0,0) ) )
                                        
                                        render.SetModelLighting(BOX_LEFT,   0.6, 0.6, 0.6)
                                        render.SetModelLighting(BOX_RIGHT,  0.08, 0.08, 0.08)
                                        render.SetModelLighting(BOX_TOP,    0.9, 0.9, 0.9)
                                        render.SetModelLighting(BOX_BOTTOM, 0.08, 0.08, 0.08)

                                        render.SetModelLighting(BOX_FRONT, 1.9, 1.9, 1.9)

                                        render.SetModelLighting(BOX_BACK, 0.1, 0.1, 0.1)

                                        mdl:DrawModel()
                                        
                                        render.SuppressEngineLighting(false)
                                        
                                    cam.End3D()
                                end
                            end
                        end
                    else
                        if mdl then mdl:Remove() mdl = nil end
                    end

                    -- custom UI stuff 
                    if LocalPlayer():GetInfoNum("om_pills_action_bloodoverlay", 0) == 1 then 
                        if pillentity.formTable.OM_UI_custom1 then
                            pillentity.formTable.OM_UI_custom1(ply,pillentity)
                        end
                    end

                    -- bar display
                    if pillentity.formTable.OM_Bar and LocalPlayer():GetInfoNum("om_pills_action_bar", 0) == 1 then 
                        local shouldShow = pillentity.formTable.OM_Bar:ShouldShow(ply, pillentity)

                        local baseY = screenH - iconsize * 1.1
                        local hiddenOffset = iconsize * 1.5
                        local lerpSpeed = FrameTime() * 6

                        if UI_Variables.omBarLerp.y == 0 then
                            UI_Variables.omBarLerp.y = baseY - hiddenOffset
                        end

                        local targetY = shouldShow and baseY or (baseY - hiddenOffset)
                        local targetAlpha = shouldShow and 255 or 0

                        UI_Variables.omBarLerp.y = Lerp(lerpSpeed, UI_Variables.omBarLerp.y, targetY)
                        UI_Variables.omBarLerp.alpha = Lerp(lerpSpeed, UI_Variables.omBarLerp.alpha, targetAlpha)

                        if UI_Variables.omBarLerp.alpha > 1 then
                            local yaxis_health_bg = UI_Variables.omBarLerp.y
                            local color = pillentity.formTable.OM_Bar:colorbar(ply, pillentity)

                            local rawValue = pillentity.formTable.OM_Bar:progression(ply, pillentity)
                            local maxValue = pillentity.formTable.OM_Bar:maximumbar(ply, pillentity)

                            local targetFactor = math.Clamp(rawValue / maxValue, 0, 1)

                            UI_Variables.omBarValueLerp.factor = Lerp(FrameTime() * 6, UI_Variables.omBarValueLerp.factor, targetFactor)
                            UI_Variables.omBarValueLerp.value  = Lerp(FrameTime() * 6, UI_Variables.omBarValueLerp.value, rawValue)

                            local factor = UI_Variables.omBarValueLerp.factor

                            surface.SetDrawColor(0, 0, 0, UI_Variables.omBarLerp.alpha)
                            surface.SetMaterial(preservedmats["dodge_bar_meter"])
                            surface.DrawTexturedRectUV(
                                iconsize * 0.5,
                                yaxis_health_bg,
                                iconsize * 4 * 0.85,
                                iconsize * 1.5 * 0.75,
                                0, 0, 1, 1
                            )

                            surface.SetDrawColor(color.r, color.g, color.b, UI_Variables.omBarLerp.alpha)
                            surface.DrawTexturedRectUV(
                                iconsize * 0.5,
                                yaxis_health_bg,
                                (iconsize * 4 * 0.85) * factor,
                                iconsize * 1.5 * 0.75,
                                0, 0, factor, 1
                            )

                            surface.SetDrawColor(255, 255, 255, UI_Variables.omBarLerp.alpha)
                            surface.SetMaterial(preservedmats["dodge_bar_new"])
                            surface.DrawTexturedRectUV(
                                iconsize * 0.5,
                                yaxis_health_bg,
                                iconsize * 4 * 0.85,
                                iconsize * 1.5 * 0.75,
                                0, 0, 1, 1
                            )

                            draw.SimpleTextOutlined(
                                "x" .. math.Round(UI_Variables.omBarValueLerp.value),
                                "CloseCaption_Bold",
                                iconsize * 0.58 + (iconsize * 3.13) * 0.2,
                                yaxis_health_bg + iconsize * 0.675,
                                Color(255, 255, 255, UI_Variables.omBarLerp.alpha),
                                TEXT_ALIGN_CENTER,
                                TEXT_ALIGN_BOTTOM,
                                5,
                                Color(0,0,0,255)
                            )
                        end
                    end

                    -- healthbar
                    if (isdrgbase and not pillentity:GetNW2Bool("DrGBaseGodMode")) or (not isdrgbase and not ply:HasGodMode()) then
                        local hpMax = pillentity:GetNW2Float("MaxHealth")
                        local hpCurrent = ply:Health()
                        if isdrgbase then
                            hpCurrent = pillentity:Health()
                        end

                        local targetFrac = math.Clamp(hpCurrent / hpMax, 0, 1)

                        local healthLerpSpeed = FrameTime() * 2
                        UI_Variables.healthLerp.frac = Lerp(healthLerpSpeed, UI_Variables.healthLerp.frac, targetFrac)
                        UI_Variables.healthLerp.hp = Lerp(healthLerpSpeed, UI_Variables.healthLerp.hp, hpCurrent)

                        local frac = UI_Variables.healthLerp.frac
                        local fraccol = math.Clamp(UI_Variables.healthLerp.hp / 100, 0, 1)

                        local r = Lerp(fraccol, 60, 95)
                        local g = Lerp(fraccol, 0, 255)
                        local b = Lerp(fraccol, 0, 101)

                        if UI_Variables.healthLerp.hp > 101 then
                            r = 65
                            g = 65
                            b = 255
                        end

                        local yaxis = screenH - iconsize * 1.3
                        local yaxis_health_bg = screenH - iconsize * 2.2

                        if ply:GetNW2Bool("Survivor_Downed_OM") or pillentity:GetNW2Bool("Survivor_Downed_OM") then
                            local targetFrac = math.Clamp( (ply:GetNW2Float("Survivor_DownedTime_OM")-CurTime())/ 30, 0, 1)

                            if LocalPlayer():GetInfoNum("om_pills_action_hp", 0) == 1 then 
                                surface.SetDrawColor(0, 0, 0)
                                surface.DrawRect(iconsize*0.625, yaxis, iconsize*3.75, iconsize*0.52)

                                surface.SetDrawColor(r, g, b)
                                surface.DrawRect(iconsize*0.625, yaxis, (iconsize*3.755) * targetFrac, iconsize*0.52)
                            end

                            if LocalPlayer():GetInfoNum("om_pills_action_downedoverlay", 0) == 1 then
                                if ply:GetNW2Bool("CanSelfRevive_OM") then
                                    local revivesize = iconsize*1.5
                                    surface.SetDrawColor(255,255,255)
                                    surface.SetMaterial(preservedmats["OM_icon"])
                                    local middlex_e, middley_e = middlex - revivesize*0.5*1.5, middley - revivesize*0.5*1.5
                                    surface.DrawTexturedRect( middlex_e, middley_e, revivesize*1.5, revivesize*1.5)

                                    surface.SetDrawColor(255, 255, 255, 255)
                                    surface.SetMaterial(preservedmats["self_revive"])
                                    surface.DrawTexturedRect(middlex - revivesize*0.5*0.75, middley - revivesize*0.5, revivesize*0.75, revivesize)


                                    local mat = Matrix()
                                    mat:Translate(Vector( middlex_e, middley_e))
                                    mat:Rotate(Angle(0, -22.5, 0))
                                    mat:Translate(Vector(-middlex_e, -middley_e))

                                    cam.PushModelMatrix(mat)
                                        local name = input.GetKeyName(ply:GetInfoNum("om_pills_action_revivecharacter", KEY_F))
                                        draw.SimpleText(string.upper(name), "OM_Subtitle_Larger",  middlex_e, middley_e, colortext)
                                    cam.PopModelMatrix()

                                end
                            end

                            if LocalPlayer():GetInfoNum("om_pills_action_lowhpoverlay", 0) == 1 then 
                                local lerpSpeed = FrameTime() * 6

                                UI_Variables.downedalpha = Lerp(lerpSpeed, UI_Variables.downedalpha, 255)
                                local altlerp = Lerp(frac, 1, 0)
                                DrawMotionBlur(0.1, altlerp * 0.8, 0.01)
                            end
                        else

                            if LocalPlayer():GetInfoNum("om_pills_action_hp", 0) == 1 then 
                                surface.SetDrawColor(0, 0, 0)
                                surface.DrawRect(iconsize*0.625, yaxis, iconsize*3.75, iconsize*0.52)

                                surface.SetDrawColor(255,255,255)
                                surface.DrawRect(iconsize*0.625, yaxis, (iconsize*3.755) * frac, iconsize*0.52)

                                surface.SetDrawColor(r, g, b)
                                surface.DrawRect(iconsize*0.625, yaxis, (iconsize*3.755) * targetFrac, iconsize*0.52)
                            end

                            local mainhealth = 0
                            if (isdrgbase) then
                                mainhealth = pillentity:Health()
                            else
                                mainhealth = ply:Health()
                            end
                            local lerpSpeed = FrameTime() * 6
                            if mainhealth <= 50 then
                                UI_Variables.downedalpha = Lerp(lerpSpeed, UI_Variables.downedalpha, Lerp(mainhealth/50, 255, 0))
                            else
                                UI_Variables.downedalpha = Lerp(lerpSpeed, UI_Variables.downedalpha, 0)
                            end
                        end

                        if LocalPlayer():GetInfoNum("om_pills_action_lowhpoverlay", 0) == 1 then 
                            if ( not pillentity.formTable.ShouldntShowDwonedBlood or pillentity.formTable.ShouldntShowDwonedBlood(false, ply, pillentity) ) and not ply:GetNW2Bool("OM_character_monster") then
                                surface.SetDrawColor(255, 255, 255, UI_Variables.downedalpha)
                                surface.SetMaterial(preservedmats["downed_blood"])
                                surface.DrawTexturedRect(0,0,screenW,screenH)
                            end
                        end

                        if LocalPlayer():GetInfoNum("om_pills_action_hp", 0) == 1 then 
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.SetMaterial(preservedmats["health_bar_remake"])
                            surface.DrawTexturedRect(0, yaxis_health_bg, iconsize*4.5*1.2, iconsize*2*1.2)

                            if ply:GetNW2Bool("Survivor_Downed_OM") then
                            else
                                draw.SimpleTextOutlined(
                                    "x" .. math.Round(UI_Variables.healthLerp.hp),
                                    "OM_Subtitle_Large",
                                    iconsize*0.58 + (iconsize*3.13)*0.4,
                                    yaxis + iconsize*-0.05,
                                    Color(255, 252, 134, 255),
                                    TEXT_ALIGN_CENTER,
                                    TEXT_ALIGN_BOTTOM,
                                    5,
                                    Color(0,0,0,255)
                                )
                            end
                        end
                    end

                    if LocalPlayer():GetInfoNum("om_pills_action_abilitybar", 0) == 1 then 
                        local xaxis = middlex + iconsize
                        local yaxis_abilities = screenH - iconsize * 1.3

                        surface.SetDrawColor(255,255,255)
                        surface.SetMaterial(preservedmats["Ability_arrow"])
                        surface.DrawTexturedRect(xaxis, yaxis_abilities, iconsize * 5.5, iconsize * 1.2)
                        local slot = 0

                        for i, v in ipairs(pillentity.formTable.OM_UI_icons) do

                            UI_Variables.cooldownLerp[i] = UI_Variables.cooldownLerp[i] or { rot = 45, alpha = 0 }
                            UI_Variables.iconLerp[i] = UI_Variables.iconLerp[i] or {
                                alpha = 0,
                                slot = 0
                            }

                            local shouldAppear = true
                            if v.shouldappear then
                                shouldAppear = v:shouldappear(false, ply, pillentity)
                            end

                            local speed = FrameTime() * 10

                            local targetAlpha = shouldAppear and 255 or 0
                            UI_Variables.iconLerp[i].alpha = Lerp(speed, UI_Variables.iconLerp[i].alpha, targetAlpha)

                            if shouldAppear then
                                slot = slot + 1
                                UI_Variables.iconLerp[i].slot = Lerp(speed, UI_Variables.iconLerp[i].slot, slot)
                            end

                            if UI_Variables.iconLerp[i].alpha < 1 then continue end

                            local visualSlot = UI_Variables.iconLerp[i].slot

                            local xaxis_btn1 = middlex + iconsize * (0.9 + 2.5 * (visualSlot * 0.4))
                            local yaxis_btn1 = screenH - iconsize * 1.25

                            local icons = v:icons(ply, pillentity) or ""
                            local cooldown = v:cooldown(ply, pillentity) or 1
                            local maxcd = v:maximumcooldown(ply, pillentity) or 1
                            local keybind = v:keybind(ply, pillentity) or "E"
                            local name = v:name(ply, pillentity) or "placeholder"
                            local issurvivor = v.survivor
                            local font = v.font or "CloseCaption_BoldItalic"

                            local colortext = issurvivor and Color(80,210,200, UI_Variables.iconLerp[i].alpha) or Color(240,40,40, UI_Variables.iconLerp[i].alpha)

                            surface.SetAlphaMultiplier(UI_Variables.iconLerp[i].alpha / 255)

                            surface.SetDrawColor(125,125,125)
                            surface.SetMaterial(issurvivor and preservedmats["OM_icon"] or preservedmats["OM_icon_monster"])
                            surface.DrawTexturedRect(xaxis_btn1, yaxis_btn1, iconsize, iconsize)

                            local factor = math.Clamp((cooldown - CurTime()) / maxcd+ 0.01, 0, 1)
                            surface.SetDrawColor(255,255,255)
                            surface.DrawTexturedRectUV(
                                xaxis_btn1,
                                yaxis_btn1 + iconsize * factor,
                                iconsize,
                                iconsize * (1 - factor),
                                0, factor, 1, 1
                            )

                            local mat = Matrix()
                            mat:Translate(Vector(xaxis_btn1, yaxis_btn1))
                            mat:Rotate(Angle(0, -22.5, 0))
                            mat:Translate(Vector(-xaxis_btn1, -yaxis_btn1))

                            cam.PushModelMatrix(mat)
                                draw.SimpleText(keybind, "OM_Subtitle_Large", xaxis_btn1, yaxis_btn1, colortext)
                            cam.PopModelMatrix()


                            local OffsetIcon = {xaxis = 0, yaxis = 0, xsize = 0, ysize = 0}
                            if v.OffsetIcon then
                                OffsetIcon = v:OffsetIcon(ply, pillentity)
                            end
                            surface.SetMaterial(icons)
                            surface.DrawTexturedRect(
                                xaxis_btn1 + iconsize * 0.1 + OffsetIcon["xaxis"],
                                yaxis_btn1 + iconsize * 0.1 + OffsetIcon["yaxis"],
                                iconsize * 0.75 + OffsetIcon["xsize"],
                                iconsize * 0.75 + OffsetIcon["ysize"]
                            )

                            draw.SimpleText(
                                name,
                                font,
                                xaxis_btn1 + iconsize / 2,
                                yaxis_btn1 + iconsize,
                                colortext,
                                TEXT_ALIGN_CENTER
                            )

                            surface.SetAlphaMultiplier(1)

                            local isCooling = cooldown > CurTime()
                            local speed = FrameTime() * 12

                            local targetRot = isCooling and 0 or 45
                            local targetAlpha = isCooling and 255 or 0

                            UI_Variables.cooldownLerp[i].rot = Lerp(speed, UI_Variables.cooldownLerp[i].rot, targetRot)
                            UI_Variables.cooldownLerp[i].alpha = Lerp(speed, UI_Variables.cooldownLerp[i].alpha, targetAlpha)

                            if UI_Variables.cooldownLerp[i].alpha > 1 then
                                surface.SetDrawColor(255,255,255, UI_Variables.cooldownLerp[i].alpha*UI_Variables.iconLerp[i].alpha)

                                local cx = xaxis_btn1 + iconsize * 0.5
                                local cy = yaxis_btn1 + iconsize * 0.5

                                local mat = Matrix()
                                mat:Translate(Vector(cx, cy))
                                mat:Rotate(Angle(0, UI_Variables.cooldownLerp[i].rot, 0))
                                mat:Translate(Vector(-cx, -cy))

                                cam.PushModelMatrix(mat)
                                    surface.SetMaterial(
                                        issurvivor and preservedmats["cooldown_square_surv"]
                                        or preservedmats["cooldown_square_exe"]
                                    )
                                    surface.DrawTexturedRectUV(
                                        xaxis_btn1 + iconsize * 0.1,
                                        yaxis_btn1 + iconsize * 0.1,
                                        iconsize * 0.8,
                                        iconsize * 0.8,
                                        0, 0, 1, 1
                                    )
                                cam.PopModelMatrix()
                            end
                            if cooldown > CurTime() then
                                
                                if cooldown - CurTime() > 10 then
                                    draw.SimpleText(
                                        math.Round(cooldown-CurTime()),
                                        "CloseCaption_Bold",
                                        xaxis_btn1 + iconsize * 0.65,
                                        yaxis_btn1 + iconsize * 0.13,
                                        colortext
                                    )
                                else
                                    draw.SimpleText(
                                        string.format("%.1f", cooldown - CurTime()),
                                        "CloseCaption_Bold",
                                        xaxis_btn1 + iconsize * 0.65,
                                        yaxis_btn1 + iconsize * 0.13,
                                        colortext
                                    )
                                end
                            end
                            if v.CustomDrawFunction then
                                local tableinsert = {
                                    ["X_axis"] = xaxis_btn1,
                                    ["Y_axis"] = yaxis_btn1,
                                    ["XSize_iconsize"] = iconsize,
                                    ["YSize_iconsize"] = iconsize,
                                    ["Rot"] = UI_Variables.cooldownLerp[i].rot,
                                    ["Alpha"] = UI_Variables.cooldownLerp[i].alpha,
                                }
                                v:CustomDrawFunction(tableinsert,tableinsert)
                            end
                        end
                    end

                    -- custom UI stuff 
                    if LocalPlayer():GetInfoNum("om_pills_action_bloodoverlay", 0) == 1 then 
                        if pillentity.formTable.OM_UI_custom_end then
                            pillentity.formTable.OM_UI_custom_end(ply,pillentity)
                        end
                    end

                else
                    UI_Variables = oldvariabletable
                    if mdl then mdl:Remove() mdl = nil end
                end



                if IsValid(pillentity) and pillentity.formTable and pillentity.formTable.Outcomememories then

                    if ply:GetNW2Bool("OM_character") or (isdrgbase and pillentity:GetNW2Bool("OM_character") ) then
                        for _, v in ipairs(ents.GetAll()) do
                            if not IsValid(v) or v == ply then continue end

                            local isDowned = v:GetNW2Bool("Survivor_Downed_OM", false)

                            if IsValid(v:GetNWEntity("OM_ragdollentity")) then
                                v = v:GetNWEntity("OM_ragdollentity")
                            end

                            v._OM_UIAlpha = v._OM_UIAlpha or 0

                            local dist = ply:GetPos():Distance(v:GetPos())
                            local maxDist = 200
                            local alphaTarget = 0
                            

                            if isDowned and dist <= maxDist then
                                alphaTarget = 255
                            end
                            local duration = 0
                            if isDowned then duration = 255 end

                            v._OM_UIAlpha = Lerp(FrameTime() * 5, v._OM_UIAlpha, alphaTarget)
                            v._OM_UISubtitles = Lerp(FrameTime() * 5, v._OM_UIAlpha, duration)


                            if v._OM_UISubtitles <= 1 then
                                v.starttime_downed = 0
                                v._letters_downed = nil
                            else
                                local sub = "HELP ME!!!"
                                local pos = v:GetPos() + Vector(0, 0, 40)
                                local screenPos = pos:ToScreen()

                                local boxW, boxH = 360, 120
                                draw.RoundedBox(8, screenPos.x - boxW/2, screenPos.y - boxH/2, boxW, boxH, Color(0,0,0,v._OM_UIAlpha * 0.6))

                                local matrix = Matrix()
                                matrix:Translate(Vector(screenPos.x, screenPos.y, 0))
                                matrix:Scale(Vector(7,7,1))
                                matrix:Translate(Vector(-screenPos.x, -screenPos.y, 0))
                                cam.PushModelMatrix(matrix)

                                    local font = "DermaDefaultBold"
                                    surface.SetFont(font)

                                    if not v.starttime_downed or v.starttime_downed == 0 then
                                        v.starttime_downed = CurTime()
                                    end

                                    local time = CurTime()

                                    if not v._letters_downed then
                                        v._letters_downed = {}

                                        local totalW = surface.GetTextSize(sub)
                                        local startX = -totalW / 2

                                        for i = 1, #sub do
                                            local char = sub:sub(i,i)
                                            local w = surface.GetTextSize(char)

                                            table.insert(v._letters_downed,{
                                                char = char,
                                                x = startX,
                                                y = 20,
                                                targetY = 0,
                                                alpha = 0,
                                                start = v.starttime_downed + (i * 0.05)
                                            })

                                            startX = startX + w
                                        end
                                    end

                                    for _, l in ipairs(v._letters_downed) do
                                        if time >= l.start then

                                            local frac = math.Clamp((time - l.start) * 3, 0, 1)

                                            l.y = Lerp(frac, l.y, l.targetY)
                                            l.alpha = Lerp(frac, l.alpha, 255)

                                            draw.SimpleText(
                                                l.char,
                                                font,
                                                screenPos.x + l.x,
                                                screenPos.y + l.y,
                                                Color(255,255,255,l.alpha),
                                                TEXT_ALIGN_LEFT,
                                                TEXT_ALIGN_CENTER
                                            )

                                        end
                                    end

                                cam.PopModelMatrix()
                            end

                            local pos = v:GetPos() + Vector(0,0,42)
                            local screen = pos:ToScreen()

                            local alpha = v._OM_UIAlpha
                            local scale = math.Clamp(1.75 - dist / maxDist, 0.75, 1.4)

                            screen.y = screen.y + math.sin(CurTime() * 2.5) * 5

                            local mat = Matrix()
                            mat:Translate(Vector(screen.x, screen.y, 0))
                            mat:Scale(Vector(scale, scale, 1))
                            mat:Translate(Vector(-screen.x, -screen.y, 0))
                            cam.PushModelMatrix(mat)

                            local w = 360
                            local h = 105

                            local x = screen.x - w/2
                            local y = screen.y - h/2

                            draw.RoundedBox(18, x + 7, y + 8, w, h, Color(0,0,0,alpha * .18))

                            draw.RoundedBox(18, x, y, w, h, Color(22,22,26,alpha * .99))

                            surface.SetDrawColor(255,255,255,alpha * 8)
                            surface.DrawRect(x+1,y+1,w-2,2)


                            local pulse = 1 + math.sin(CurTime()*6)*0.05

                            local keySize = 54 * pulse

                            draw.RoundedBox(
                                14,
                                screen.x-keySize/2,
                                y+10,
                                keySize,
                                keySize,
                                Color(240,240,240,alpha)
                            )

                            draw.SimpleText(
                                string.upper(input.GetKeyName(
                                    ply:GetInfoNum("om_pills_action_revivecharacter", KEY_F)
                                ) or "F"),
                                "CloseCaption_Bold",
                                screen.x,
                                y+37,
                                Color(25,25,25,alpha),
                                TEXT_ALIGN_CENTER,
                                TEXT_ALIGN_CENTER
                            )

                            draw.SimpleText(
                                "REVIVE",
                                "Trebuchet24",
                                screen.x,
                                y+100,
                                Color(255,255,255,alpha),
                                TEXT_ALIGN_CENTER,
                                TEXT_ALIGN_BOTTOM
                            )


                            cam.PopModelMatrix()
                        end
                    end
                end
                
            end)

            hook.Add("RenderScreenspaceEffects", name4, function()

                local ply = LocalPlayer()
                local pillentity = ent
                local isdrgbase = false

                if ply:GetNW2Bool("OM_character_monster") then return end
                if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
                    pillentity = ply:GetNW2Entity("DrGBasePossessing")
                    isdrgbase = true
                end


                if LocalPlayer():GetInfoNum("om_pills_action_lowhpoverlay", 0) == 1 then 
                    local hp = ply:Health()
                    if isdrgbase then
                        hp = pillentity:Health()
                    end

                    local maxFadeStart = 60

                    local targetStrength = 0
                    if hp < maxFadeStart then
                        targetStrength = math.Clamp(1 - (hp / maxFadeStart), 0, 1)
                    end

                    pillentity._healthStrengthLerp = pillentity._healthStrengthLerp or 0
                    pillentity._healthStrengthLerp = Lerp(
                        FrameTime() * 4,
                        pillentity._healthStrengthLerp,
                        targetStrength
                    )

                    local strength = pillentity._healthStrengthLerp

                    pillentity._selfDestructLerp = pillentity._selfDestructLerp or 0
                    local target = pillentity:GetNWBool("SelfDestruct_metal_om") and 1 or 0

                    pillentity._selfDestructLerp = Lerp(
                        FrameTime() * 2,
                        pillentity._selfDestructLerp,
                        target
                    )

                    local t = pillentity._selfDestructLerp

                    local colorMod = {
                        ["$pp_colour_addr"] = strength * 0.25 * (1 - t),
                        ["$pp_colour_addg"] = strength * 0.25 * t,
                        ["$pp_colour_addb"] = 0,

                        ["$pp_colour_brightness"] = -strength * 0.075,
                        ["$pp_colour_contrast"] = 1 + strength * 0.1,
                        ["$pp_colour_colour"] = 1 - strength * 0.5,

                        ["$pp_colour_mulr"] = 0,
                        ["$pp_colour_mulg"] = 0,
                        ["$pp_colour_mulb"] = 0
                    }

                    DrawColorModify(colorMod)
                end

            end)
            
            local lastID = nil
            local lastOrigin = nil
            local lastFOV = nil
            local transitionStart = 0
            local transitionTime = 0.25

            hook.Add("CalcView", name6, function(ply, pos, ang, fov)

                local ent = pk_pills.getMappedEnt(ply)
                if isfunction(ply.DrG_IsPossessing) then
                    if ply:DrG_IsPossessing() then
                        drgbase = true
                        ent = ply:DrG_Possessing()
                    end
                end
                local removefunction = function()
                    if !IsValid(ent) and drgbase then
                        if alreadydeleted then return end
                        alreadydeleted = true
                        hook.Remove('CalcView', name6)
                        hook.Remove("EntityRemoved", name5)
                        for savedID, func in pairs(savedCalcViewHooks) do
                            hook.Add("CalcView", savedID, func)
                        end
                        savedCalcViewHooks = {}
                    end
                end

                if !IsValid(ent) then
                    removefunction()
                    return
                end
                if not IsValid(ent) or ply:GetViewEntity() ~= ply then return end

                local currentOMTable = ent.formTable.OM_cameratable(ply, ent)
                if not currentOMTable then return end

                if lastID ~= currentOMTable.id then
                    lastID = currentOMTable.id
                    transitionStart = CurTime()
                    lastOrigin = lastOrigin or pos
                    lastFOV = lastFOV or fov
                end

                if transitionTime ~= currentOMTable.transition then
                    transitionTime = currentOMTable.transition
                end

                local currentchar = ply:GetPos()
                if drgbase then
                    currentchar = ent:GetPos()
                end

                if currentOMTable.cameraentity then
                    currentchar = currentOMTable.cameraentity
                end

                local up = ang:Up() * currentOMTable.startoffset.z
                local right = ang:Right() * currentOMTable.startoffset.x
                local forward = ang:Forward() * currentOMTable.startoffset.y
                local startpos = currentchar + up + right + forward
                if IsValid(ent:GetPuppet()) then
                    if currentOMTable.bonecenter then
                        local boneID = ent:GetPuppet():LookupBone(currentOMTable.bonecenter)
                        if boneID then
                            local bonePos, boneAng = ent:GetPuppet():GetBonePosition(boneID)
                            if bonePos then
                                startpos = bonePos + up + right + forward
                            end
                        end
                    end
                end

                if pk_pills.convars.cl_thirdperson:GetBool() then

                    local dist = currentOMTable.dist
                    if currentOMTable.canscroll then
                        dist =  dist* ply:GetNW2Float("OM_cameradistancefactor_pills")
                    end
                    local offset = ang:Forward() * -dist

                    local tr = util.TraceHull({
                        start = startpos,
                        endpos = startpos + offset,
                        filter = ent.camTraceFilter,
                        mins = Vector(-5, -5, -5),
                        maxs = Vector(5, 5, 5),
                        mask = MASK_VISIBLE
                    })

                    local targetOrigin = tr.HitPos
                    local targetFOV = currentOMTable.fov

                    local t = math.Clamp((CurTime() - transitionStart) / transitionTime, 0, 1)

                    local smoothOrigin = LerpVector(t, lastOrigin, targetOrigin)
                    local smoothFOV = Lerp(t, lastFOV, targetFOV)

                    lastOrigin = smoothOrigin
                    lastFOV = smoothFOV


                    ent.camerafov_lerp_sprint = ent.camerafov_lerp_sprint or 1
                    if ply:KeyDown(IN_SPEED) and ply:GetVelocity():Length() > 300 and ent:GetNW2Float("OM_camsprint_prev") < CurTime() then 
                        ent.camerafov_lerp_sprint = Lerp(FrameTime()*2, ent.camerafov_lerp_sprint, 1.15)
                    else
                        ent.camerafov_lerp_sprint = Lerp(FrameTime()*2, ent.camerafov_lerp_sprint, 1)
                    end
                    smoothFOV = smoothFOV * ent.camerafov_lerp_sprint 
                    if LocalPlayer():GetInfoNum("OM_pills_important_Motionsickness", 0) == 1 then
                        smoothFOV = ply:GetInfoNum("om_pills_default_fov", 80)
                    end

                    return {
                        origin = smoothOrigin,
                        angles = ang,
                        fov = smoothFOV,
                        drawviewer = true
                    }
                end
            end)
        end)
    end)
end

-- Reuesd footsteps --
if SERVER then
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
    function StepSFX_OM(ply, ent)
        if not ply:OnGround() then return end
        local DefaultFootsteps = {
            [MAT_ANTLION] = { "physics/flesh/flesh_impact_hard1.wav", "physics/flesh/flesh_impact_hard2.wav", "physics/flesh/flesh_impact_hard3.wav", "physics/flesh/flesh_impact_hard4.wav", "physics/flesh/flesh_impact_hard5.wav", "physics/flesh/flesh_impact_hard6.wav" },
            [MAT_BLOODYFLESH] = { "physics/flesh/flesh_squishy_impact_hard1.wav", "physics/flesh/flesh_squishy_impact_hard2.wav", "physics/flesh/flesh_squishy_impact_hard3.wav", "physics/flesh/flesh_squishy_impact_hard4.wav" },
            [MAT_CONCRETE] = {"player/footsteps/concrete1.wav", "player/footsteps/concrete2.wav", "player/footsteps/concrete3.wav", "player/footsteps/concrete4.wav" },
            [MAT_DIRT] = { "player/footsteps/dirt1.wav", "player/footsteps/dirt2.wav", "player/footsteps/dirt3.wav", "player/footsteps/dirt4.wav" },
            [MAT_EGGSHELL] = {"physics/flesh/flesh_impact_hard1.wav", "physics/flesh/flesh_impact_hard2.wav", "physics/flesh/flesh_impact_hard3.wav", "physics/flesh/flesh_impact_hard4.wav", "physics/flesh/flesh_impact_hard5.wav", "physics/flesh/flesh_impact_hard6.wav" },
            [MAT_FLESH] = {"physics/flesh/flesh_impact_hard1.wav","physics/flesh/flesh_impact_hard2.wav","physics/flesh/flesh_impact_hard3.wav","physics/flesh/flesh_impact_hard4.wav","physics/flesh/flesh_impact_hard5.wav","physics/flesh/flesh_impact_hard6.wav"},
            [MAT_GRATE] = {"player/footsteps/chainlink1.wav","player/footsteps/chainlink2.wav","player/footsteps/chainlink3.wav","player/footsteps/chainlink4.wav"},
            [MAT_ALIENFLESH] = { "physics/flesh/flesh_impact_hard1.wav", "physics/flesh/flesh_impact_hard2.wav", "physics/flesh/flesh_impact_hard3.wav", "physics/flesh/flesh_impact_hard4.wav", "physics/flesh/flesh_impact_hard5.wav","physics/flesh/flesh_impact_hard6.wav"},
            [MAT_SNOW] = {"player/footsteps/grass1.wav", "player/footsteps/grass2.wav","player/footsteps/grass3.wav","player/footsteps/grass4.wav"},
            [MAT_PLASTIC] = {"physics/plastic/plastic_box_impact_soft1.wav","physics/plastic/plastic_box_impact_soft2.wav","physics/plastic/plastic_box_impact_soft3.wav","physics/plastic/plastic_box_impact_soft4.wav"},
            [MAT_METAL] = {"player/footsteps/metal1.wav","player/footsteps/metal2.wav","player/footsteps/metal3.wav","player/footsteps/metal4.wav"},
            [MAT_SAND] = {"player/footsteps/sand1.wav","player/footsteps/sand2.wav","player/footsteps/sand3.wav","player/footsteps/sand4.wav"},
            [MAT_FOLIAGE] = {"player/footsteps/grass1.wav","player/footsteps/grass2.wav","player/footsteps/grass3.wav","player/footsteps/grass4.wav"},
            [MAT_COMPUTER] = {"player/footsteps/metal1.wav","player/footsteps/metal2.wav","player/footsteps/metal3.wav","player/footsteps/metal4.wav"},
            [MAT_SLOSH] = {"player/footsteps/slosh1.wav","player/footsteps/slosh2.wav","player/footsteps/slosh3.wav","player/footsteps/slosh4.wav"},
            [MAT_TILE] = {"player/footsteps/tile1.wav","player/footsteps/tile2.wav","player/footsteps/tile3.wav","player/footsteps/tile4.wav"},
            [MAT_GRASS] = {"player/footsteps/grass1.wav","player/footsteps/grass2.wav","player/footsteps/grass3.wav","player/footsteps/grass4.wav"},
            [MAT_VENT] = {"player/footsteps/duct1.wav","player/footsteps/duct2.wav","player/footsteps/duct3.wav","player/footsteps/duct4.wav"},
            [MAT_WOOD] = {"player/footsteps/wood1.wav","player/footsteps/wood2.wav","player/footsteps/wood3.wav","player/footsteps/wood4.wav"},
            [MAT_DEFAULT] = {"player/footsteps/concrete1.wav","player/footsteps/concrete2.wav","player/footsteps/concrete3.wav","player/footsteps/concrete4.wav"},
            [MAT_GLASS] = {"physics/glass/glass_sheet_step1.wav","physics/glass/glass_sheet_step2.wav","physics/glass/glass_sheet_step3.wav","physics/glass/glass_sheet_step4.wav"},
            [MAT_WARPSHIELD] = {"physics/glass/glass_sheet_step1.wav","physics/glass/glass_sheet_step2.wav","physics/glass/glass_sheet_step3.wav","physics/glass/glass_sheet_step4.wav"}
        }
        local tr = util.TraceLine({
            start = ply:GetPos(),
            endpos = ply:GetPos() - ply:GetUp()*999,
            filter = {ply, ent, ent:GetPuppet()}
        })
        local sounds = DefaultFootsteps[tr.MatType]
        if not sounds then return end
        AdvancedPillSound({
            stringe = sounds[math.random(#sounds)],
            soundLevel = 79
        }, ent)
    end
end


-- KEYBINDS --

hook.Add("PlayerInitialSpawn", "OM_SetCameraInit", function(ply)
    ply:SetNW2Float("OM_cameradistancefactor_pills", 1)
end)

hook.Add("StartCommand", "OM_BlockAllPlayerInput", function(ply, cmd)
    if IsValid(ply) then
        local shouldchecktrue = true
        if ply.canusestun_input_om and ply:canusestun_input_om(ply,cmd) then shouldchecktrue = false end
        if ply:GetNW2Bool("clashingminigame_om_isinminigame") then
            if cmd:KeyDown(IN_FORWARD) then shouldchecktrue = false end
            if cmd:KeyDown(IN_BACK) then shouldchecktrue = false end
            if cmd:KeyDown(IN_MOVELEFT) then shouldchecktrue = false end
            if cmd:KeyDown(IN_MOVERIGHT) then shouldchecktrue = false end
        end
        if ( IsValid( ply:GetNWEntity("OM_ragdollentity") ) or ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() ) and shouldchecktrue then
            cmd:ClearButtons()
            cmd:ClearMovement()
        end
    end
end)

timer.Simple(0.1, function()
    local hooks = hook.GetTable()["PlayerButtonDown"]
    if not hooks then return end

    for name, func in pairs(hooks) do
        if !isfunction(func) then continue end

        local originalFunc = func

        hook.Remove("PlayerButtonDown", name)

        hook.Add("PlayerButtonDown", name, function(ply, button)
            if IsValid(ply) then
                local shouldchecktrue = true
                if ply.canusestun_keybind_om then
                    shouldchecktrue = not ply:canusestun_keybind_om(ply,button)
                end
                
                if ( IsValid(ply:GetNWEntity("OM_ragdollentity")) or ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() or ply:GetNW2Int("Silver_RockHit", 0) >= CurTime() ) and shouldchecktrue then
                    return
                end
            end

            return originalFunc(ply, button)
        end)
    end
end)

hook.Add("PlayerButtonDown", "ActivateKeybind_OM_pills_noodles", function(ply, button)
    local pillentity = ply.pk_pill_ent
    
    if button == ply:GetInfoNum("om_pills_action_scrollin", KEY_0) then
        if ply:GetNW2Float("OM_cameradistancefactor_pills") > 0.2 then
            ply:SetNW2Float("OM_cameradistancefactor_pills", ply:GetNW2Float("OM_cameradistancefactor_pills") - 0.1 )
        end
    end
    if button == ply:GetInfoNum("om_pills_action_scrollout", KEY_9) then
        if ply:GetNW2Float("OM_cameradistancefactor_pills") < 2 then
            ply:SetNW2Float("OM_cameradistancefactor_pills", ply:GetNW2Float("OM_cameradistancefactor_pills") + 0.1 )
        end
    end

    if ply:GetNW2Bool("Survivor_Downed_OM") then
        if button == ply:GetInfoNum("om_pills_action_revivecharacter", KEY_F) then
            if GetConVar("om_pills_action_2canrevive"):GetBool() then
                if ply:GetNW2Bool("Survivor_Downed_OM") then
                    if ply.ReviveFunction_OM then ply:ReviveFunction_OM() end
                end
            end
        end
        return
    end

    if button == ply:GetInfoNum("om_pills_action_revivecharacter", KEY_F) then
        if SERVER then
            if ply:GetNW2Bool("OM_character") then
                for _, v in ipairs(ents.GetAll()) do
                    if !IsValid(v) or v == ply then continue end
                    if !v:GetNW2Bool("Survivor_Downed_OM") then continue end
                    if ply:GetPos():Distance(v:GetPos()) < 100 then
                        if v.ReviveFunction_OM then
                            v:ReviveFunction_OM()
                        end
                    end
                end
            end
        end
    end

    if IsValid(pillentity) then
        if pillentity.formTable.noodles_OM_survivor_keybinds then
            pillentity.formTable.noodles_OM_survivor_keybinds(ply, pillentity, button)
        end
    end
    if button == KEY_SPACE then
        if SERVER then
            if IsValid(ply:GetNW2Entity("PeeloutEntity_OM_Sonic")) then
                local pillentity = ply:GetNW2Entity("PeeloutEntity_OM_Sonic")
                if ply == pillentity:GetNW2Entity("PeelOutGrabEntity_om") then
                    pillentity:SetNW2Entity("PeelOutGrabEntity_om",NULL)
                end
            end
        end
    end
end)

hook.Add("PlayerButtonUp", "DeactivateKeybind_OM_pills_noodles", function(ply, button)
    local pillentity = ply.pk_pill_ent
    
    if IsValid(pillentity) then
        if pillentity.formTable.noodles_OM_survivor_keybinds_deactivate then
            pillentity.formTable.noodles_OM_survivor_keybinds_deactivate(ply, pillentity, button)
        end
    end
end)


hook.Add("KeyPress", "DetectUseKey_OMPill", function(ply, key)
    local pillentity = ply.pk_pill_ent
    
    if IsValid(pillentity) then
        if pillentity.formTable.noodles_OM_survivor_naturalkeys then
            pillentity.formTable.noodles_OM_survivor_naturalkeys(ply, pillentity, key)
        end
    end
end)