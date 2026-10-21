
--NoHealing_OM_Noodles
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

local preservedmats = {
    ["IT'S NO USE 2"] = Material("icons/IT'S NO USE 2.png"),
    ["rock 2"] = Material("icons/rock 2.png"),
    ["silverref"] = Material("icons/silverref.png"),
}

if SERVER then--
    timer.Simple(1,function()
        if SERVER then else return end
        OM_AddSpeedConfigeration(function(entity)
            if SERVER and entity:GetNW2Int("Silver_RockHit", 0) >= CurTime() then
                return 0.75
            end
            return 1
        end)
    end)
end

hook.Add("SetupMove", "Silver_RockHit_debuff", function(ply, mv, cmd)
    if !IsValid(ply) then return end
    if !ply:Alive() then return end

    if ply:GetNW2Int("Silver_RockHit", 0) >= CurTime() then
        local vel = mv:GetVelocity()

        vel.x = vel.x * 0.75
        vel.y = vel.y * 0.75

        mv:SetVelocity(vel)
    end
end)

hook.Add("StartCommand", "OM_BlockAllPlayerInput", function(ply, cmd)
    if IsValid(ply) then
        local shouldchecktrue = true
        if ply.canusestun_input_om and ply:canusestun_input_om(ply,cmd) then shouldchecktrue = false end
        if ( ply:GetNW2Int("Silver_RockHit", 0) >= CurTime() ) and shouldchecktrue then
            cmd:ClearButtons()
        end

    end
end)


pk_pills.register('pill_om_Silver', {

    printName='Silver',
    Outcomememories='Silver',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/Silver.mdl",
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',


    ShouldRoll_om = function(e, ply, ent)
        return true
    end,

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["IT'S NO USE 2"]
            end,
            name = function(uselessvar,ply,ent)
                return "Suspension"
            end,
            keybind = function(uselessvar,ply,ent)
                return "E"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("SilverSuspension_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["rock 2"]
            end,
            name = function(uselessvar,ply,ent)
                return "Rock"
            end,
            keybind = function(uselessvar,ply,ent)
                return "R"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("SilverRock_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 30
            end,
            survivor = true,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["silverref"]
            end,
            name = function(uselessvar,ply,ent)
                return "Time Reversal"
            end,
            keybind = function(uselessvar,ply,ent)
                return "T"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("SilverTimeReversal_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            survivor = true,
            font = "CreditsText",
        },
    },
    
    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            return true
        end,
        colorbar = function(uselessvar,ply,ent)
            return Color(0, 175, 245, 255)
        end,
        progression = function(uselessvar,ply,ent)
            return ent:GetNW2Float("Silver_PowerBar")
        end,
        maximumbar = function(uselessvar,ply,ent)
            return 100
        end,
    },


    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            attack = "attack",
            jump2 = "jump",
            hoverfire = "hoverfire",
        },
        ShouldMoveRotate={
            idle= function(ent) 
                if ent:GetNW2Float("TimeReversal_tic_Silver_OM_rotation") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("CurrentRockCount") > 0 then 
                    return "shiftlock" end
                if ent.SilverRocks and #ent.SilverRocks > 0 then 
                    return "shiftlock" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return "shiftlock" end
                return "notanything"
            end,
            run= function(ent) 
                if ent:GetNW2Float("TimeReversal_tic_Silver_OM_rotation") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("CurrentRockCount") > 0 then return "shiftlock" end
                if ent.SilverRocks and #ent.SilverRocks > 0 then return "shiftlock" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return "shiftlock" end
                return "notshftlock"
            end,
            walk= function(ent) 
                if ent:GetNW2Float("TimeReversal_tic_Silver_OM_rotation") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("CurrentRockCount") > 0 then return "shiftlock" end
                if ent.SilverRocks and #ent.SilverRocks > 0 then return "shiftlock" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return "shiftlock" end
                return "notshftlock"
            end,
            fall= function(ent) 
                if ent:GetNW2Float("TimeReversal_tic_Silver_OM_rotation") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("CurrentRockCount") > 0 then return "shiftlock" end
                if ent.SilverRocks and #ent.SilverRocks > 0 then return "shiftlock" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return "shiftlock" end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                return "notshftlock"
            end,
            jump= function(ent) 
                if ent:GetNW2Float("TimeReversal_tic_Silver_OM_rotation") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("CurrentRockCount") > 0 then return "shiftlock" end
                if ent.SilverRocks and #ent.SilverRocks > 0 then return "shiftlock" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return "shiftlock" end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            idle= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'downedidle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "Roll" end

                if ent.SilverRocks and #ent.SilverRocks > 0 then return "abilityhover" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 3 then return "suspension loop" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return "abilityhover" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "LowHealthIdle"
                end 
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'downedwalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "Roll" end

                if ent.SilverRocks and #ent.SilverRocks > 0 then return "abilityhover" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 3 then return "suspension loop" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return "abilityhover" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "LowHealthWalk"
                end 
            end,
            fall= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'downedidle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "Roll" end

                if ent.SilverRocks and #ent.SilverRocks > 0 then return "abilityhover" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 3 then return "suspension loop" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return "abilityhover" end
                if IsValid(ent:GetNW2Entity("flyingent")) then
                    return "FlyIdle"
                end
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'downedwalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "Roll" end

                if ent.SilverRocks and #ent.SilverRocks > 0 then return "abilityhover" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 3 then return "suspension loop" end
                if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return "abilityhover" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "LowHealthRun"
                end 
            end,
        },
    },
    

    
    OM_cameratable = function(ply,ent)

        local basetable =  {
            startoffset = Vector(20,0,25),  -- left-up, front-back, up-down
            dist=145,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 0,
            transition = 1,
            canscroll = true,
            bonecenter = "Torso",
        }

        if ply:GetNW2Bool("Survivor_Downed_OM") then
            basetable =  {
                startoffset = Vector(45,0,25),  -- left-up, front-back, up-down
                dist=50,
                fov = ply:GetInfoNum("om_pills_default_fov", 80)*0.85,
                id = 67,
                transition = 1,
                canscroll = false,
                bonecenter = "Torso",
            }
        end
        if ent:GetNW2Float("SilverSuspension_enabled") == 1 then 
            basetable =  {
                startoffset = Vector(35,0,25),  -- left-up, front-back, up-down
                dist=145,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 1,
                transition = 1,
                canscroll = true,
                bonecenter = "Torso",
            }
        end


        local fly = ent:GetNW2Entity("flyingent")
        if IsValid(fly) then
            basetable =  {
                startoffset = Vector(20,0,55),  -- left-up, front-back, up-down
                dist=145,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 2,
                transition = 0.75,
                canscroll = true,
            }
        end

        if ent:GetNW2Float("CurrentRockCount") > 0 then
            --[[
            basetable =  {
                startoffset = Vector(35,-25,50),  -- left-up, front-back, up-down
                dist=35,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 2,
                transition = 1,
                canscroll = true,
                bonecenter = "Torso",
            }
            ]]
        end
        if ent:GetNW2Float("CurrentRockCount") == 2 then
            --[[
            basetable =  {
                startoffset = Vector(35,25,50),  -- left-up, front-back, up-down
                dist=50,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 3,
                transition = 1,
                canscroll = true,
            }
            ]]
        end

        return basetable
    end,
       
    speedhandeler_om = {
        modifiers = {
            
        }
    }, 

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return 60
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return 412
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return 60
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return 400
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return 2
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return 1500
                end
            end,
        },
    },

    camera={
        offset = Vector(0, 0, 50),
        dist=130,
    },
        
    jumpPower=400,
        
    
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },
        
    canAim=function(ply,ent) return ent.active end,     

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if event == "Step" then
            StepSFX_OM(ply,ent)
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
        if SERVER then
            initializetable2["entity"]:SetNW2Int('OM_friction', 1)
            initializetable2["player"]:SetHealth(105)
            initializetable2["player"]:SetMaxHealth(105)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Int("MaxHealth",105)
            initializetable2["player"]:SetNW2Int("MaxHealth_OM",105)
        end
        initializetable2["entity"]:SetNW2Float("OM_Fleetway_flyingBar", 20)
        initializetable2["entity"]:SetNW2Float("OM_maximum_flight", 20)
        initializetable2["entity"]:SetNW2Float("Silver_PowerBar", 100)
        initializetable2["player"]:SetNW2Bool("OM_character", true)
        initializetable2["entity"].SilverRocks = {}
        initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
        initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)
        initializetable2["entity"]:SetNW2Bool('HasFlyCompad_OM', true)
    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetNW2Bool("ShoukdntStun_OM_Noodles", false)
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetGravity(1)
        end
        hook.Remove("EntityTakeDamage", "OM_Silver_timelapse_cancel_".. initializetable2["entity"]:EntIndex())
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", 1)



            if ent:GetNW2Float("OM_Fleetway_flyingBar_cd", 0) > CurTime() then
                if not ent.OM_Fleetway_flyingBar_cd_bool then
                    ent.OM_Fleetway_flyingBar_cd_bool = true
                end
            else
                if ent.OM_Fleetway_flyingBar_cd_bool then
                    ent.OM_Fleetway_flyingBar_cd_bool = false

                    AdvancedPillSound(
                        {
                            stringe = "OM/Fleetway/emrald.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            end

            ent:SetNW2Float("Fleetway_flightspeed", GetConVar('OUTCOMEMORIES_N_Fleetway_flying_run'):GetFloat())


            if ply:IsOnGround() then
                ent:SetNW2Bool('StillInAir_Flying', false)
            end
            local fly = ent:GetNW2Entity("flyingent")

            if IsValid(fly) and ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) < CurTime() then

                ply:SetNW2Float("NoJumpingCooldown_OM", CurTime() + 0.1)

                local options = {
                    speed = 0,
                    flyingdrainamount = 0.94
                }

                local move = Vector(0, 0, 0)
                local angled = fly:GetAngles()
                local aim = Angle(0, ply:EyeAngles().y, 0)

                if ply:IsPlayer() then
                    aim.p = math.Clamp(ply:EyeAngles().p, -90, 90)

                    if ply:KeyDown(IN_SPEED) then
                        options.speed = 12
                    else
                        options.speed = 7
                    end
                    if ply:KeyDown(IN_FORWARD) then
                        move = angled:Forward() * ent:GetNW2Float("SpeedAccelerate")
                    elseif ply:KeyDown(IN_BACK) then
                        move = angled:Forward() * -ent:GetNW2Float("SpeedAccelerate")
                    end
                    if ply:KeyDown(IN_MOVERIGHT) then
                        move = move + angled:Right() * ent:GetNW2Float("SpeedAccelerate")
                    elseif ply:KeyDown(IN_MOVELEFT) then
                        move = move + angled:Right() * -ent:GetNW2Float("SpeedAccelerate")
                    end
                    
                    if not ( (ply:KeyDown(IN_FORWARD)) or (ply:KeyDown(IN_MOVERIGHT)) or (ply:KeyDown(IN_MOVELEFT)) or (ply:KeyDown(IN_BACK)) ) then
                        if ent:GetNW2Float("SpeedAccelerate") > 0 then 
                            ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") - 0.8 )
                            move = ( ent:GetNW2Vector("CurrentVelocity_fly") - Vector(0,0,0) ):GetNormalized() * ent:GetNW2Float("SpeedAccelerate")
                        end
                    else
                        if ent:GetNW2Float("SpeedAccelerate") < options.speed then 
                            ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") + 1.8 )
                        elseif ent:GetNW2Float("SpeedAccelerate") > options.speed then 
                            ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") - 1.8 )
                        end
                    end
                else
                    move = ply:GetNW2Vector("flymove_om_fleetway")
                    options.speed = ply:GetNW2Float("Fleetwayspeed")
                    aim = ply:GetNW2Angle("fleetway_OM_angle")
                end

                local origin = fly:GetPos()
                local endposition = ((origin+move)-origin):GetNormalized()
                if ent:GetNW2Float("OM_Fleetway_flyingBar") <= 0 then
                    ent:SetNW2Float("OM_Fleetway_flyingBar_cd", CurTime()+8)
                    OM_base_FlyingEnd(ply, ent)
                    return
                end
                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_NONE)
                else
                    ply:SetMoveType(MOVETYPE_NONE)
                end

                if ply:IsPlayer() then
                    if ent:GetNW2Float("FleetwayFlyDrainCooldown") <= CurTime() then
                        ent:SetNW2Float("FleetwayFlyDrainCooldown", CurTime() + 0.1)
                        ent:SetNW2Float("OM_Fleetway_flyingBar", ent:GetNW2Float("OM_Fleetway_flyingBar", 0) - options.flyingdrainamount)
                    end
                else
                    if ent:GetNW2Float("FleetwayFlyDrainCooldown") <= CurTime() then
                        ent:SetNW2Float("FleetwayFlyDrainCooldown", CurTime() + 0.1)
                        ent:SetNW2Float("OM_Fleetway_flyingBar", ent:GetNW2Float("OM_Fleetway_flyingBar", 0) - ply:GetNW2Float("FleetwayDrain"))
                    end
                end

                OM_base_FlyMovement(ply, ent, options, move, aim, fly, origin)
            else
                ent:SetNW2Float("SpeedAccelerate", 0 )
                if ent:GetNW2Float("OM_Fleetway_flyingBar") < 20 then
                    if not ent:GetNW2Bool("StillInAir_Flying") then
                        if ent:GetNW2Float("FleetwayFlyDrainCooldown") <= CurTime() then
                            ent:SetNW2Float("FleetwayFlyDrainCooldown", CurTime() + 0.08)
                            ent:SetNW2Float("OM_Fleetway_flyingBar", ent:GetNW2Float("OM_Fleetway_flyingBar") + 0.35)
                        end
                    end
                
                end
            end

            local Barregen = true

            if ent:GetNW2Bool("GrabbingEntity_om_silver") then
                local ent2 = ent:GetNW2Entity("CurrentEntityToThrow")
                if IsValid(ent2) then 

                    if ent2:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then
                        ent:SetNW2Bool("GrabbingEntity_om_silver", false)
                        ent:SetNW2Float("SilverSuspension_enabled", 0)
                    end

                    if ent2:IsOnGround() then
                        ent2:SetPos(ent2:GetPos()+Vector(0,0,30))
                    end

                    local targetpos = ent:GetNW2Vector("CurrentEntityToThrow_flypos")
                    local direction = ( targetpos - ent2:GetPos() ):GetNormalized() * 650

                    ent:GetPuppet():SetNW2Float("OM_highlight_Silver", CurTime()+0.5)
                    ent2:SetNW2Float("OM_highlight_Silver", CurTime()+0.5)

                    ent2:SetPos(targetpos)
                    
                    Barregen = false
                    if ent:GetNW2Float("Silver_PowerBar") > 0 then 
                        ent:SetNW2Float("Silver_PowerBar", ent:GetNW2Float("Silver_PowerBar") - 0.6)
                    else
                        ent:SetNW2Float("Silver_PowerBar", 0)
                        ent:SetNW2Bool("GrabbingEntity_om_silver", false)
                        ent:SetNW2Float("SilverSuspension_enabled", 0)
                    end
                    ply:SetNW2Float("OM_NoMovement_noodles", 0.25 + CurTime())
                else
                    ent:SetNW2Float("SilverSuspension_enabled", 0)
                    ent:SetNW2Bool("GrabbingEntity_om_silver", false)
                end
            end

            if not ent.SilverRocks or #ent.SilverRocks == 0 then
                ent.ThrowingRocks = false
                if ent.SilverRocks_toggle then
                    ent.SilverRocks_toggle = false
                    ent:SetNW2Float("SilverRock_cd", CurTime()+15 + 5 * ent:GetNW2Float("RocksHit"))
                end
            else
                if not ent.SilverRocks_toggle then
                    ent.SilverRocks_toggle = true
                end
                ply:SetNW2Float("OM_NoMovement_noodles", 0.25 + CurTime())

                local backDistance = 50
                local sideSpacing = 60
                local baseHeight = 60

                local count = #ent.SilverRocks
                local centerIndex = (count + 1) / 2

                ent:SetNW2Float("Silver_PowerBar", ent:GetNW2Float("Silver_PowerBar") - 0.1)

                for i, rock in ipairs(ent.SilverRocks) do
                    if not IsValid(rock) then continue end
                    if rock.Hindered then continue end

                    local sideOffset = (i - centerIndex) * sideSpacing
                    local height = baseHeight

                    if count == 3 and i == 2 then
                        height = baseHeight + 30
                    end

                    local targetPos =
                        ply:GetPos()
                        - ply:GetForward() * backDistance
                        + ply:GetRight() * sideOffset
                        + ply:GetUp() * height

                    local currentPos = rock:GetPos()
                    local lerpSpeed = 8
                    local newPos = LerpVector(FrameTime() * lerpSpeed, currentPos, targetPos)

                    rock:SetPos(newPos)

                    local ang = (ply:GetPos() - newPos):Angle()
                    ang.p = 0
                    ang.r = 0

                    local currentAng = rock:GetAngles()
                    local smoothAng = LerpAngle(FrameTime() * lerpSpeed, currentAng, Angle(0, ang.y, 0))

                    rock:SetAngles(smoothAng)
                    
                    ent:GetPuppet():SetNW2Float("OM_highlight_Silver", CurTime()+0.5)
                    rock:SetNW2Float("OM_highlight_Silver", CurTime()+1e9)
                    rock:SetNW2Float("OM_highlight_Silver_color", CurTime()+1e9)

                    if not rock.smallballcooldown then rock.smallballcooldown = 1 end
                    
                    if rock.smallballcooldown <= CurTime() then
                        rock.smallballcooldown = CurTime() + 0.3

                        local effectdata = EffectData()
                        effectdata:SetOrigin(rock:GetPos())
                        effectdata:SetEntity(rock)
                        util.Effect("OM_tinyball_silver_rock", effectdata)
                    end

                    Barregen = false
                    if ent:GetNW2Float("Silver_PowerBar") > 0 then
                    else
                        ent:SetNW2Float("Silver_PowerBar", 0)

                        local function RemoveSilverRocks(ent)
                            for _, rock in ipairs(ent.SilverRocks) do
                                if not IsValid(rock) then continue end

                                rock:SetRenderMode(RENDERMODE_TRANSCOLOR)

                                local startPos = rock:GetPos()
                                local targetPos = startPos - Vector(0,0,70)

                                local startTime = CurTime()
                                local duration = 0.4
                                local id = "SilverRockSink_" .. rock:EntIndex()

                                timer.Create(id, 0, 0, function()
                                    if not IsValid(rock) then
                                        timer.Remove(id)
                                        return
                                    end

                                    local frac = (CurTime() - startTime) / duration

                                    if frac >= 1 then
                                        rock:Remove()
                                        timer.Remove(id)
                                        return
                                    end

                                    local newPos = LerpVector(frac, startPos, targetPos)
                                    rock:SetPos(newPos)

                                    local alpha = 255 * (1 - frac)
                                    rock:SetColor(Color(255,255,255,alpha))
                                end)
                            end

                            ent.SilverRocks = {}
                        end

                        RemoveSilverRocks(ent)
                        ent:SetNW2Float("CurrentRockCount", 0)

                        break
                    end
                end
            end



            if ent:GetNW2Bool("TimeReversal_Silver_OM") then
                ent:GetPuppet():SetNW2Float("OM_highlight_Silver", CurTime()+0.5)
                --Barregen = false
                ent:SetNW2Bool("TimeReversal_Silver_OM_Debounce",true)
                if ent:GetNW2Float("TimeReversal_tic_Silver_OM") > CurTime() then
                else
                    if ent:GetNW2Bool("TimeReversal_Silver_OM_reversingmode") then
                        hook.Remove("EntityTakeDamage", "OM_Silver_timelapse_cancel_".. ent:EntIndex())

                        ent:SetNW2Float("TimeReversal_tic_Silver_OM", CurTime()+0.1)
                        ent:SetNW2Float("TimeReversal_tic_Silver_OM_rotation", CurTime()+0.15)

                        ent:SetNW2Int("TimeReversal_tic_sound_Silver_OM", ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM") - 1)
                        local variable_pos, variable_angle = "OM_Silver_teleportation_pos_".. ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM"),  "OM_Silver_teleportation_rot".. ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM")
                        
                        if ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM") >= 0 then
                            
                            local travelTime = 0.09
                            local startTime = CurTime()
                            local ogpos = ply:GetPos()

                            local hookName = "timereversal_om_" .. ent:EntIndex()

                            hook.Add("Think", hookName, function()
                                if !IsValid(ent) then
                                    hook.Remove("Think", hookName)
                                    return
                                end

                                local frac = math.Clamp((CurTime() - startTime) / travelTime, 0, 1)
                                ply:SetPos(LerpVector(frac, ogpos, ent[variable_pos]))
                                ent:SetNW2Angle("pill_assignedangle",LerpAngle(frac, ply:GetAngles(), ent[variable_angle]) )

                                if frac >= 1 then
                                    hook.Remove("Think", hookName)
                                end
                            end)

                            
                            ply:SetVelocity(Vector(0,0,0))
                            ply:SetLocalVelocity(Vector(0,0,0))

                            AdvancedPillSound(
                                {
                                    stringe = "OM/silver/silver_reverseRelease.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                        else
                            ent:SetNW2Bool("TimeReversal_Silver_OM", false)
                            ent:SetNW2Bool("TimeReversal_Silver_OM_reversingmode", false)
                        end
                    else
                        local function ENDTimeReversal()
                            ent:SetNW2Bool("TimeReversal_Silver_OM_reversingmode", true)
                        end
                        if ent:GetNW2Float("Silver_PowerBar") > 0 then 
                            ent:SetNW2Float("Silver_PowerBar", ent:GetNW2Float("Silver_PowerBar") - 10)

                            if ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM") < 10 then
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/silver/Silver time reverse tick "..ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM")..".wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                local variable_pos, variable_angle = "OM_Silver_teleportation_pos_".. ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM"),  "OM_Silver_teleportation_rot".. ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM")
                                ent[variable_pos] = ply:GetPos()
                                ent[variable_angle] = ply:GetAngles()

                                ent:SetNW2Int("TimeReversal_tic_sound_Silver_OM", ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM") + 1)
                                ent:SetNW2Float("TimeReversal_tic_Silver_OM", CurTime()+1)
                                --SilverCreateTimeframe()
                                ent:GetPuppet():SetNW2Float("silver_afterimage_duration", CurTime()+0.1)
                            else
                                ENDTimeReversal()
                            end

                        else
                            ent:SetNW2Float("Silver_PowerBar", 0)
                            ENDTimeReversal()
                        end
                    end
                end
            else
                if ent:GetNW2Bool("TimeReversal_Silver_OM_Debounce") then
                    ent:SetNW2Bool("TimeReversal_Silver_OM_Debounce",false)
                    if ent:GetNW2Bool("TimeReversal_Silver_OM_Canceled") then
                        ent:SetNW2Float("SilverTimeReversal_cd", CurTime()+15)
                    else
                        ent:SetNW2Float("SilverTimeReversal_cd", CurTime()+25)
                    end
                end
            end

            if Barregen then
                if ent:GetNW2Float("Silver_PowerBar") < 100 then 
                    ent:SetNW2Float("Silver_PowerBar", ent:GetNW2Float("Silver_PowerBar") + 0.05)
                else
                    ent:SetNW2Float("Silver_PowerBar", 100)
                end
            end
            if ent:GetNW2Float("Silver_PowerBar") <= 0 then 
                ent:SetNW2Float("Silver_PowerBar", 0)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if button == KEY_SPACE then
            if not SERVER then return end
            if ent:GetNW2Float("CurrentRockCount") >= 1 then return end
            if not ent.SilverRocks then ent.SilverRocks = {} end
            if #ent.SilverRocks >= 1 then return end
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end
            if ent:GetNW2Float("OM_Fleetway_flyingBar_cd_return", 0) > CurTime() then return end
            if ent:GetNW2Float("OM_Fleetway_flyingBar_cd", 0) > CurTime() then return end
            if ent:GetNW2Float("SilverSuspension_enabled") == 3 then return end

            ent:SetNW2Float("OM_Fleetway_flyingBar_cd_return", CurTime()+0.25)

            if ply:IsPlayer() then
                if ply:IsOnGround() then return end
            else
                if ply.IsPossessed and ply:IsPossessed() then
                    if ply:IsOnGround() then return end
                end
            end

            if ent.flyingent and IsValid(ent.flyingent) then
                OM_base_FlyingEnd(ply, ent)
                return
            end

            local flyingent = ents.Create("prop_physics")

            if !IsValid(flyingent) then return end

            ply:SetVelocity(Vector(0,0,0))
            ply:SetLocalVelocity(Vector(0,0,0))

            flyingent:SetModel("models/hunter/blocks/cube1x1x1.mdl")
            flyingent:SetPos(ply:GetPos())
            flyingent:SetAngles(ply:GetAngles())
            flyingent:Spawn()
            flyingent:Activate()
            flyingent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

            flyingent:PhysicsInit(0)
            flyingent:SetMoveType(0)
            flyingent:SetSolid(0)

            ent:SetNW2Vector("CurrentVelocity_fly", Vector(0,0,0))

            ent:DeleteOnRemove(flyingent)
            
            ply:SetMoveType(MOVETYPE_NONE)

            ent.flyingent = flyingent
            ent:SetNW2Entity("flyingent",flyingent)

            flyingent:SetRenderMode(RENDERMODE_TRANSALPHA)
            flyingent:SetColor(Color(0,0,0,0))
            flyingent:DrawShadow(false)

            ent:SetNW2Bool('StillInAir_Flying', true)

            AdvancedPillSound(
                {
                    stringe = "OM/Flystarting.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )
        end

        if button == KEY_E then
            if not SERVER then return end
            if ent:GetNW2Bool("TimeReversal_Silver_OM") then return end
            if ent:GetNW2Bool("TimeReversal_Silver_OM_reversingmode") then return end
            if ent:GetNW2Float("Silver_PowerBar") < 10 then return end

            if ent:GetNW2Float("CurrentRockCount") >= 1 then return end

            if ent:GetNW2Float("SilverSuspension_cd") >= CurTime() then return end

            if not ent.SilverRocks then ent.SilverRocks = {} end
            if #ent.SilverRocks >= 1 then return end
            if ent:GetNW2Bool("GrabbingEntity_om_silver") then return end
            if ent:GetNW2Float("SilverSuspension_eletricityExistanceDuration") > CurTime() then return end

            if ent:GetNW2Float("SilverSuspension_enabled") == 0 then
                ent:SetNW2Float("SilverSuspension_enabled", 1)
                AdvancedPillSound(
                    {
                        stringe = "OM/silver/SilverSuspension.ogg",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent:SetNW2Float("SilverSuspension_cd", CurTime()+5)
            else
                ent:SetNW2Float("SilverSuspension_enabled", 0)
            end
        end

        if button == KEY_R then
            if not SERVER then return end
                if ent:GetNW2Float("Silver_PowerBar") < 30 then return end
            if ent:GetNW2Bool("TimeReversal_Silver_OM") then return end
            if ent:GetNW2Bool("TimeReversal_Silver_OM_reversingmode") then return end

            if IsValid(ent:GetNW2Entity("flyingent")) then return end
            if ent:GetNW2Bool("GrabbingEntity_om_silver") then return end
            if ent:GetNW2Float("SilverSuspension_eletricityExistanceDuration") > CurTime() then return end
            if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return end
            if ent:GetNW2Float("SilverSuspension_enabled") == 3 then return end

            if ent:GetNW2Float("SilverRock_cd") >= CurTime() then return end

            ent:SetNW2Float("SilverRock_cd", CurTime()+0.2)

            if SERVER then

                local function RemoveSilverRocks(ent)
                    for _, rock in ipairs(ent.SilverRocks) do
                        if not IsValid(rock) then continue end

                        rock:SetRenderMode(RENDERMODE_TRANSCOLOR)

                        local startPos = rock:GetPos()
                        local targetPos = startPos - Vector(0,0,70)

                        local startTime = CurTime()
                        local duration = 0.4
                        local id = "SilverRockSink_" .. rock:EntIndex()

                        timer.Create(id, 0, 0, function()
                            if not IsValid(rock) then
                                timer.Remove(id)
                                return
                            end

                            local frac = (CurTime() - startTime) / duration

                            if frac >= 1 then
                                rock:Remove()
                                timer.Remove(id)
                                return
                            end

                            local newPos = LerpVector(frac, startPos, targetPos)
                            rock:SetPos(newPos)

                            local alpha = 255 * (1 - frac)
                            rock:SetColor(Color(255,255,255,alpha))
                        end)
                    end

                    ent.SilverRocks = {}
                end
                if !IsValid(ent) then return end

                if not ent.SilverRocks then ent.SilverRocks = {} end

                if ent:GetNW2Float("CurrentRockCount") <= 0 then
                    ent:SetNW2Float("RocksHit", 0)

                    ent.ThrowingRocks = false
                    ent:SetNW2Float("Silver_OM_Rock_ID", ent:GetNW2Float("Silver_OM_Rock_ID")+1)

                end

                if ent.ThrowingRocks then
                    ent.ThrowingRocks = false
                    RemoveSilverRocks(ent)

                    ent:SetNW2Float("CurrentRockCount", 0)
                    return
                end
                
                if ent:GetNW2Float("CurrentRockCount") >= 3 then
                    return
                end


                local name = "Silver_RockHit_ID_".. ent:GetNW2Float("Silver_OM_Rock_ID").. " "..tostring(ent).. " ".. tostring(ply)
                ent:SetNW2Float(name, 0)

                ent:SetNW2Float("CurrentRockCount", ent:GetNW2Float("CurrentRockCount")+1)

                local spawnWorld = ply:GetPos() + ply:GetForward() * -120

                local trace = util.TraceLine({
                    start = spawnWorld + Vector(0,0,100),
                    endpos = spawnWorld - Vector(0,0,300),
                    mask = MASK_SOLID_BRUSHONLY
                })

                local groundPos = trace.HitPos
                local rock = ents.Create("prop_physics")
                if not IsValid(rock) then return end

                rock:SetModel("models/props_wasteland/rockgranite03b.mdl")
                rock:SetPos(groundPos - Vector(0,0,60))
                rock:Spawn()
                rock:SetMoveType(MOVETYPE_NONE)

                rock:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

                ent:DeleteOnRemove(rock)

                rock:SetRenderMode(RENDERMODE_TRANSCOLOR)
                rock:SetColor(Color(255,255,255,0))

                local startPos = rock:GetPos()
                local targetPos = groundPos + Vector(0,0,60)

                local startTime = CurTime()
                local duration = 0.25
                local id = "SilverRockRise_" .. rock:EntIndex()

                AdvancedPillSound(
                    {
                        stringe = "OM/silver/SilverRockk.ogg",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                timer.Create(id, 0, 0, function()
                    if not IsValid(rock) then
                        timer.Remove(id)
                        return
                    end

                    local frac = (CurTime() - startTime) / duration

                    if frac >= 1 then
                        rock:SetPos(targetPos)
                        rock:SetColor(Color(255,255,255,255))

                        table.insert(ent.SilverRocks, rock)

                        timer.Remove(id)
                        return
                    end

                    local newPos = LerpVector(frac, startPos, targetPos)
                    rock:SetPos(newPos)

                    local alpha = 255 * frac
                    rock:SetColor(Color(255,255,255,alpha))
                end)

                timer.Simple(0.1,function()
                    if !IsValid(rock) then return end

                    local effectdata = EffectData()
                    effectdata:SetEntity(rock)
                    effectdata:SetOrigin(rock:GetPos())
                    util.Effect("rockparticals_overlay_silver_003", effectdata, true, true)
                end)

            end
        end


        if button == KEY_T then
            if not SERVER then return end
            if ent:GetNW2Float("CurrentRockCount") >= 1 then return end
            if #ent.SilverRocks >= 1 then return end
            if ent:GetNW2Float("SilverSuspension_enabled") == 1 then return end
            if ent:GetNW2Float("SilverSuspension_enabled") == 3 then return end
            if ent:GetNW2Bool("GrabbingEntity_om_silver") then return end
            if ent:GetNW2Float("SilverSuspension_eletricityExistanceDuration") > CurTime() then return end
            if ent:GetNW2Bool("TimeReversal_Silver_OM_reversingmode") then return end


            if ent:GetNW2Float("SilverTimeReversal_cd") >= CurTime() then return end

            if not ent:GetNW2Bool("TimeReversal_Silver_OM") then

                if ent:GetNW2Bool("TimeReversal_Silver_OM_Debounce") then return end
                
                ent:SetNW2Bool("TimeReversal_Silver_OM", true) 
                ent:SetNW2Bool("TimeReversal_Silver_OM_reversingmode", false)
                ent:SetNW2Float("TimeReversal_tic_Silver_OM", CurTime()+1) 

                if ent:GetNW2Float("Silver_PowerBar") > 0 then 
                    ent:SetNW2Float("Silver_PowerBar", ent:GetNW2Float("Silver_PowerBar") - 10)
                else
                    ent:SetNW2Float("Silver_PowerBar", 0)
                end

                AdvancedPillSound(
                    {
                        stringe = "OM/silver/Silver time reverse tick 0.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                --SilverCreateTimeframe(ent:GetPuppet())
                ent:GetPuppet():SetNW2Float("silver_afterimage_duration", CurTime()+0.1)

                ent:SetNW2Int("TimeReversal_tic_sound_Silver_OM", 0) 
                local variable_pos, variable_angle = "OM_Silver_teleportation_pos_".. ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM"),  "OM_Silver_teleportation_rot".. ent:GetNW2Int("TimeReversal_tic_sound_Silver_OM")
                ent[variable_pos] = ply:GetPos()
                ent[variable_angle] = ply:GetAngles()

                ent.timierversal_startpos = ply:GetPos()

                ent:SetNW2Int("TimeReversal_tic_sound_Silver_OM", 1) 
                ent:SetNW2Bool("TimeReversal_Silver_OM_Canceled", false)


                local hookname = "OM_Silver_timelapse_cancel_".. ent:EntIndex()
                hook.Add("EntityTakeDamage", hookname, function(target, dmg)
                    if target == ply then
                        if ent:GetNW2Bool("TimeReversal_Silver_OM_reversingmode") then return end
                        local attacker = dmg:GetAttacker()
                        ent:SetNW2Float("TimeReversal_tic_Silver_OM", CurTime()+0) 
                        ent:SetNW2Bool("TimeReversal_Silver_OM", false) 
                        ent:SetNW2Bool("TimeReversal_Silver_OM_reversingmode", false)
                        ent:SetNW2Bool("TimeReversal_Silver_OM_Canceled", false)
                        hook.Remove("EntityTakeDamage", hookname)

                        AdvancedPillSound(
                            {
                                stringe = "OM/silver/silver_reverseCancel.ogg",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )

                    end
                end)
                ent:SetNW2Float("SilverTimeReversal_cd", CurTime()+1) 


            else
                ent:SetNW2Float("TimeReversal_tic_Silver_OM", CurTime()+0) 
                ent:SetNW2Bool("TimeReversal_Silver_OM_reversingmode", true)
                ent:SetNW2Bool("TimeReversal_Silver_OM_Canceled", true)
            end
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply,ent,button)
        --[[
        if button == KEY_T then
            if not SERVER then return end
            if not ent:GetNW2Bool("TimeReversal_Silver_OM") then
                
            else
                if ent:GetNW2Bool("TimeReversal_Silver_OM_reversingmode") then
                    ent:SetNW2Bool("TimeReversal_Silver_OM", false)
                    ent:SetNW2Bool("TimeReversal_Silver_OM_reversingmode", false)
                end
            end
        end
        ]]
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)


            if ent:GetNW2Bool("TimeReversal_Silver_OM") then
                if ent:GetNW2Bool("TimeReversal_Silver_OM_reversingmode") then return end
                ent:SetNW2Float("TimeReversal_tic_Silver_OM", CurTime()+0) 
                ent:SetNW2Bool("TimeReversal_Silver_OM", false) 
                ent:SetNW2Bool("TimeReversal_Silver_OM_reversingmode", false)
                ent:SetNW2Bool("TimeReversal_Silver_OM_Canceled", false)
                AdvancedPillSound(
                    {
                        stringe = "OM/silver/charge cancel.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end

            if #ent.SilverRocks >= 1 then

                if ent:GetNW2Float("Silver_rockthrow_m1cd") > CurTime() then return end
                ent:SetNW2Float("Silver_rockthrow_m1cd", CurTime()+0.2)

                ent.ThrowingRocks = true
                local name = "Silver_RockHit_ID_".. ent:GetNW2Float("Silver_OM_Rock_ID").. " "..tostring(ent).. " ".. tostring(ply)

                if ent.PillAnim then
                    ent.AlternatePlaySolution = true 
                    ent:PillAnim("hoverfire")
                    ent.AlternatePlaySolution = false
                end

                local ed = EffectData()
                ed:SetOrigin(ent:GetPos()+Vector(0,0,40))
                ed:SetEntity(ent)
                util.Effect("silver_rockthrow_circle", ed)
                
                local ed = EffectData()
                ed:SetEntity(ply)
                util.Effect("silver_rock_spray", ed, true, true)
                
                AdvancedPillSound(
                    {
                        stringe = "OM/silver/SilverRockThrow.ogg",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                
                local rock = ent.SilverRocks[1]
                table.remove(ent.SilverRocks, 1)
                if !IsValid(rock) then
                    return
                end

                rock:SetNW2Bool("Thrown", true)
                
                if #ent.SilverRocks <= 0 then
                    ent:SetNW2Float("CurrentRockCount", 0)
                end

                rock:SetMoveType(MOVETYPE_VPHYSICS)

                local oldpositionofrock = rock:GetPos()
                local phys = rock:GetPhysicsObject()
                rock.Hindered = true

                if IsValid(phys) then
                    phys:Wake()

                    phys:SetPos(oldpositionofrock + ply:GetForward()*130)
                    local startPos = phys:GetPos()

                    local direction = ply:GetAimVector()
                    phys:SetVelocity(direction * 2500)
                    local axis = rock:GetAngles():Right()
                    phys:SetAngleVelocity(axis * 600 * 0.7)
                end


                local name = "RockThinking".. rock:EntIndex()
                hook.Add("Think", name, function()
                    if !IsValid(rock) then hook.Remove("Think", name) return end

                    local jumpscare_entity = nil
                    for _, ent2 in pairs(ents.FindInSphere( rock:GetPos(), 80)) do
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                            if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then continue end

                            ent:SetNW2Float("RocksHit", ent:GetNW2Float("RocksHit")+1)
                            ent2:SetNW2Float("Silver_RockHit", CurTime()+5)

                            if ent:GetNW2Float("RocksHit") >= 3 then
                                Mutaul_OMStunCode(
                                    {
                                        ["ply"] = ply,
                                        ["ent"] = ent,
                                        ["target"] = ent2,
                                        ["StunDur"] = 3,
                                        ["stunfunction"] = function(shouldstundamage)
                                        end,
                                        ["shouldstack"] = false,
                                        ["Damage"] = 15,
                                        ["DamageType"] = DMG_CLUB
                                    }
                                )
                            end

                            AdvancedPillSound(
                                {
                                    stringe = "OM/silver/SilverRockHit.ogg",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                rock
                            )
                            

                            local effectdata = EffectData()
                            effectdata:SetOrigin(rock:GetPos())
                            effectdata:SetScale(0.75)
                            util.Effect("rockparticalsBurst_silver", effectdata, true, true)

                            rock:EmitSound("physics/concrete/concrete_break2.wav", 75, math.random(95,105))

                            util.ScreenShake(rock:GetPos(), 10, 10, 1, 1000)


                            rock._Removed = true
                            rock:Remove()
                            
                            break
                        end
                    end
                end)

                timer.Simple(5,function()
                    if !IsValid(rock) then return end
                    rock._Removed = true

                    rock:Remove()
                end)

            end


            if ent:GetNW2Float("SilverSuspension_enabled") == 1 then
                ent:SetNW2Float("SilverSuspension_enabled", 0)
                if ent.PillAnim then
                    ent.AlternatePlaySolution = true
                    ent:PillAnim("hoverfire")
                    ent.AlternatePlaySolution = false
                end


                AdvancedPillSound(
                    {
                        stringe = "OM/silver/SilverSuspensionThrow.ogg",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                
                local puppet = ent:GetPuppet()
                local startPos = puppet:GetPos() + puppet:GetUp() * 30
                local direction = ply:GetAimVector():GetNormalized()

                local prop = ents.Create("prop_physics")
                prop:SetModel("models/hunter/blocks/cube025x025x025.mdl")
                prop:SetPos(startPos + direction * 15)
                prop:SetAngles(direction:Angle())
                prop:Spawn()

                prop:SetRenderMode(RENDERMODE_TRANSALPHA)
                prop:SetColor(Color(255,255,255,0))

                local effectdata = EffectData()
                effectdata:SetOrigin(startPos + direction * 40)
                util.Effect("silver_suspension_spawn_eff", effectdata)

                local uniqueID = "AmyHammerProp_" .. prop:EntIndex()

                local trailFoot1 = util.SpriteTrail(
                    prop,
                    0,
                    Color(0, 125, 255),
                    true,
                    25,
                    2,
                    0.3,
                    0.2,
                    "models/noodles/om/amy/white.vmt"
                )

                prop:DeleteOnRemove(trailFoot1)
                ent:DeleteOnRemove(prop)

                prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

                local followHook = "PropFollow_" .. prop:EntIndex()

                local function StartFade(duration)
                    local start = CurTime()

                    hook.Add("Think", uniqueID .. "_Fade", function()
                        if !IsValid(prop) then return end

                        local delta = (CurTime() - start) / duration

                        if delta >= 1 then
                            prop:Remove()
                            return
                        end
                    end)
                end

                prop:CallOnRemove("CleanupHooks", function()
                    hook.Remove("Think", uniqueID .. "_Fade")
                end)

                local phys = prop:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(true)
                    phys:EnableDrag(false)
                    phys:EnableGravity(false)
                    phys:SetVelocity(direction * 2100)
                end

                ent:SetNW2Float("SilverSuspension_eletricityExistanceDuration", CurTime()+1.3)
                timer.Simple(1.25, function()
                    if IsValid(prop) then
                        prop:SetMoveType(MOVETYPE_NONE)
                        prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
                        StartFade(0.3)
                    end
                end)

                local name = "RockThinking".. prop:EntIndex()
                hook.Add("Think", name, function()
                    if !IsValid(prop) then hook.Remove("Think", name) return end

                    if ent:GetNW2Bool("GrabbingEntity_om_silver") then return end

                    local jumpscare_entity = nil
                    for _, ent2 in pairs(ents.FindInSphere( prop:GetPos(), 80)) do
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                            if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then continue end

                            ent:SetNW2Bool("GrabbingEntity_om_silver", true)
                            ent:SetNW2Entity("CurrentEntityToThrow", ent2)
                            ent:SetNW2Vector("CurrentEntityToThrow_flypos", ent2:GetPos()+Vector(0,0,70))
                            prop:SetMoveType(MOVETYPE_NONE)
                            prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
                            StartFade(0.3)
                            ent:SetNW2Float("SilverSuspension_enabled", 3)


                            if ent.flyingent and IsValid(ent.flyingent) then
                                OM_base_FlyingEnd(ply, ent)
                                return
                            end

                            local effectdata = EffectData()
                            effectdata:SetOrigin(ent2:GetPos() + ent2:GetUp() * 40)
                            util.Effect("silver_suspension_grab_eff", effectdata)

                            AdvancedPillSound(
                                {
                                    stringe = "OM/silver/SilverSuspensionLand.ogg",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                            AdvancedPillSound(
                                {
                                    stringe = "OM/silver/SilverSuspensionLand.ogg",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent2
                            )


                            prop:SetMoveType(MOVETYPE_NONE)
                            prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

                            StartFade(0.3)
                            break
                        end
                    end
                end)
            elseif ent:GetNW2Float("SilverSuspension_enabled") == 3 then


                if ent.PillAnim then
                    ent.AlternatePlaySolution = true
                    ent:PillAnim("hoverfire")
                    ent.AlternatePlaySolution = false
                end

                AdvancedPillSound(
                    {
                        stringe = "OM/silver/SilverSuspensionThrow.ogg",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                local direction = ply:GetAimVector():GetNormalized()

                local effectdata = EffectData()
                effectdata:SetOrigin(ply:GetPos()+ply:GetUp()*40+ent:GetPuppet():GetForward()*30)
                util.Effect("silver_suspension_spawn_eff_smaller", effectdata)

                ent:SetNW2Float("SilverSuspension_enabled", 0)
                ent:SetNW2Bool("GrabbingEntity_om_silver", false)

                local ent2 = ent:GetNW2Entity("CurrentEntityToThrow")
                if IsValid(ent2) then 
                    if ent2:IsOnGround() then
                        ent2:SetPos(ent2:GetPos()+Vector(0,0,30))
                    end
                    if ply:IsPlayer() then
                        ent2:SetLocalVelocity(direction * 2000)
                    else
                        ent2:SetVelocity(direction * 2000)
                    end
                end

                ent:SetNW2Float("SilverSuspension_cd", CurTime()+17)

            end

        end
    },


    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
        end,
    },

    reload=function(ply,ent)
    end,
    flashlight = function(ply, ent)
    end,
        
    jump = function(ply, ent)
        ent.AlternatePlaySolution = true
        ent:PillAnim('jump2')
        ent.AlternatePlaySolution = false

        AdvancedPillSound(
            {
                stringe = "OM/Jump.wav",
                pitchPercent = 100,
                volume = 1,
                soundLevel = 87
            },
            ent
        )
    end
})