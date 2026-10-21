
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
    ["Vector_punchicon_om"] = Material("icons/Vector_punchicon_om.png"),
    ["Cream_dash"] = Material("icons/Cream_dash.png"),
    ["Vector_ringicon_om"] = Material("icons/Vector_ringicon_om.png"),

    ["leftclick"] = Material("icons/left-click_epsio_om.png"),
    ["rightclick"] = Material("icons/right-click_epsio_om.png"),
}

pk_pills.register('pill_om_Espio', {
    printName='Espio',
    Outcomememories='Espio',
    Outcomememories_material="Organic",
        
    model="models/nick/OM/po.mdl",
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',

    ShouldRoll_om = function(e, ply, ent)
        if ent:GetNW2Bool("Espio_Camouflage_bool") then return false end
        return true
    end,

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Vector_punchicon_om"]
            end,
            name = function(uselessvar,ply,ent)
                return "Poison Ninja Stars"
            end,
            keybind = function(uselessvar,ply,ent)
                return "E"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Vector_NinjaStarCD")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Vector_NinjaStarhDur")
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Cream_dash"]
            end,
            name = function(uselessvar,ply,ent)
                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then  return "Drop" end
                return "Bodyguard"
            end,
            keybind = function(uselessvar,ply,ent)
                return "R"
            end,
            cooldown = function(uselessvar,ply,ent)
                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then return 0 end
                return ent:GetNW2Float("Vector_MidairdashCD")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then return 0 end
                return ent:GetNW2Float("Vector_MidairdashDur")
            end,
            survivor = true,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Vector_ringicon_om"]
            end,
            name = function(uselessvar,ply,ent)
                return "Camouflage"
            end,
            keybind = function(uselessvar,ply,ent)
                return "T"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Espio_CamouflageCD")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Espio_CamouflageDur")
            end,
            survivor = true,
            font = "CreditsText",
        },
    },

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
        },
        ShouldMoveRotate={
            idle= function(ent) 
                if ent:GetNW2Float("espio_togglestarability_duration") >= CurTime() then return "shiftlock" end
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    return "assignedagnles"
                end
                return "notanything"
            end,
            run= function(ent) 
                if ent:GetNW2Float("espio_togglestarability_duration") >= CurTime() then return "shiftlock" end
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    return "assignedagnles"
                end
                return "notshftlock"
            end,
            walk= function(ent) 
                if ent:GetNW2Float("espio_togglestarability_duration") >= CurTime() then return "shiftlock" end
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    return "assignedagnles"
                end
                return "notshftlock"
            end,
            fall= function(ent) 
                if ent:GetNW2Float("espio_togglestarability_duration") >= CurTime() then return "shiftlock" end
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    return "assignedagnles"
                end
                return "notshftlock"
            end,
        },

        ShouldAlternate={
            idle= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    return "climb"
                end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end

                if ent:GetNW2Bool("Espio_Camouflage_bool") then return "IdleCamo" end

                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "IdleLowHealth"
                end 
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    return "climb"
                end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end

                if ent:GetNW2Bool("Espio_Camouflage_bool") then return "WalkCamo" end

                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "WalkLowHealth"
                end 
            end,
            fall= function(ent) 
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    return "climb"
                end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("JumpAnim") > CurTime() then return "jump" end
            end,
            run= function(ent) 
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    return "climb"
                end
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                
                if ent:GetNW2Bool("Espio_Camouflage_bool") then return "WalkCamo" end

                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "RunLowHealth"
                end 
            end,
        },
        animrates = {
            fall = function(ent)
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    if ent:GetNW2Bool("HoldingSpaceClimbClimb_up") then
                        return 1
                    end
                    if ent:GetNW2Bool("HoldingSpaceClimbClimb_down") then
                        return 1
                    end
                    return 0
                end

                return 1
            end,
        }
    },
    
    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            return true
        end,
        colorbar = function(uselessvar,ply,ent)
            return Color(175, 0, 175, 255)
        end,
        progression = function(uselessvar,ply,ent)
            return ent:GetNW2Float("espio_poisonstarcount")
        end,
        maximumbar = function(uselessvar,ply,ent)
            return 12
        end,
    },

    OM_cameratable = function(ply,ent)
        local basetable =  {
            startoffset = Vector(20,0,20),  -- left-up, front-back, up-down
            dist=145,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 0,
            transition = 1,
            canscroll = true,
            bonecenter = "Torso",
        }

        ent.espio_togglestarability_duration = ent.espio_togglestarability_duration or 0
        ent.espio_togglestarability_duration = Lerp(FrameTime()*9, ent.espio_togglestarability_duration, ent:GetNW2Float("espio_togglestarability_duration") >= CurTime() and 1 or 0)

        basetable["startoffset"] = basetable["startoffset"] + Vector(5*ent.espio_togglestarability_duration, 10*ent.espio_togglestarability_duration, 0)
        basetable["dist"] = basetable["dist"] - 102 * ent.espio_togglestarability_duration
        basetable["fov"] = basetable["fov"] - 30 * ent.espio_togglestarability_duration

        return basetable
    end,
       
    speedhandeler_om = {
        modifiers = {
            ['function0'] = function( ply, ent )
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Bool("Espio_Camouflage_bool") then
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * 1.3 - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * 1.3 - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * 1.3 - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
        }
    }, 

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return 100
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return 410
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return 100
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
            initializetable2["player"]:SetHealth(100)
            initializetable2["player"]:SetMaxHealth(100)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Int("MaxHealth",100)
            initializetable2["player"]:SetNW2Int("MaxHealth_OM",100)

            initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
            initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)
            initializetable2["player"]:SetNW2Bool("OM_character", true)

            initializetable2["player"].OM_DamageBeforeCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                local ent = initializetable2["entity"]
                if !IsValid(initializetable2["entity"]) then return end
                if damageamount > 0 then else return end

                if entityfall == initializetable2["player"] then
                end
            end

            initializetable2["player"].CustomFunctionForDowned_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]

                end
            end
            initializetable2["player"].CustomFunctionCancelAbility_OM = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end
            initializetable2["player"].OM_Stun_Blockfunction = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end
            initializetable2["entity"]:SetNW2Float("espio_poisonstarcount", 12)

        end


    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetNW2Bool("ShoukdntStun_OM_Noodles", false)
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetGravity(1)
        end
    end,

    OM_transitionbar_type1table = {
        ColorDisplay = Color(175,0,175,255),
        CanShowcase = function(e,ply, ent)
            return ent:GetNW2Bool("Kolossos_Climbing")
        end,
        Factor = function(e,ply, ent)
            local amoutn = (ent:GetNW2Float("Kolossos_Climbing_duration_duration")-CurTime()) / ent:GetNW2Float("Kolossos_Climbing_duration_amount")
            return amoutn
        end
    },

    OM_transitionbar_type2table = {
        ColorDisplay = Color(175,0,175,255),
        CanShowcase = function(e,ply, ent)
            return ent:GetNW2Float("Climbing_cd_OMEspio_duration") >= CurTime()
        end,
        Factor = function(e,ply, ent)
            return (ent:GetNW2Float("Climbing_cd_OMEspio_duration")-CurTime()) / ent:GetNW2Float("Climbing_cd_OMEspio_amount")
        end,
        offset = function(e,ply, ent)
            return Vector(-20,15,0)
        end
    },

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", 1)
            ply:SetNW2Float("OM_Damage_Reduction",ent:GetNW2Float("Vector_armordown") >= CurTime() and 1 or 0.8)

            local shouldgeneratestar = true

            local puppet = ent:GetPuppet()
            ent.layeredAnim_time = ent.layeredAnim_time or 0
            if not ent.layeredAnim then
                ent.layeredAnim = puppet:AddGesture(ACT_VM_HITCENTER2, false)
                puppet:SetLayerWeight(ent.layeredAnim, 0)
                puppet:SetLayerPriority(ent.layeredAnim, 10)
            end

            ent.layeredAnim_time = Lerp(FrameTime()*8, ent.layeredAnim_time, ent:GetNW2Float("espio_togglestarability_duration") <= CurTime() and 0 or 1)
            if ent.layeredAnim then puppet:SetLayerWeight(ent.layeredAnim, ent.layeredAnim_time) end

            if ent:GetNW2Float("espio_togglestarability_duration") >= CurTime() then
                if not ent.espio_togglestarability_toggle then
                    ent.espio_togglestarability_toggle = true
                    ent:SetNW2Bool("espio_togglestarability_mouse", math.random(1,2)==1)
                    if ent.espio_togglestarability_toggle1sttime then
                        ent:SetNW2Float("espio_togglestarability_duration", CurTime()+1.1)
                        ent:SetNW2Float("espio_togglestarability_amount", 1.1)
                        ent:SetNW2Float("espio_poisonstarcount", math.Clamp(ent:GetNW2Float("espio_poisonstarcount") - 1,0,12 ))
                        ent.formTable.OM_Espio_throw(ply,ent)
                        ent.espio_togglestarability_CDAdd = ent.espio_togglestarability_CDAdd + 1.3
                        if ent:GetNW2Float("espio_poisonstarcount") <= 0 then
                            ent:SetNW2Float("espio_togglestarability_duration", 0)
                            ent.espio_poisonstarcount_cd = CurTime() + 6
                        end


                        local rock = ents.Create("ent_om_espio_star")

                        if IsValid(rock) then

                            rock:SetPos(ply:GetPos()+Vector(0,0,35) + ply:GetAimVector()*25)
                            rock:SetAngles(ply:GetAimVector():Angle())
                            rock:Spawn()

                            rock.Owner = ply
                            rock.EntOwner = ent

                            ent:SetNW2Entity("ent_om_espio_star", rock)

                            ent:DeleteOnRemove(rock)


                            local phys = rock:GetPhysicsObject()

                            if IsValid(phys) then
                                phys:Wake()
                                phys:SetVelocity(ply:GetAimVector() * 2500)
                                phys:SetMass(50)
                                phys:EnableDrag(false)
                                phys:EnableMotion(true)
                            end

                            rock.Direction = ply:GetAimVector()
                        end

                    else
                        ent:SetNW2Float("espio_togglestarability_duration", CurTime()+2)
                        ent:SetNW2Float("espio_togglestarability_amount", 2)
                        ent.espio_togglestarability_CDAdd = 0
                    end
                else
                    ent.espio_togglestarability_toggle1sttime = true
                end
                shouldgeneratestar = false
            else
                if ent.espio_togglestarability_toggle then
                    ent.espio_togglestarability_toggle = false
                    ent.espio_togglestarability_toggle1sttime = false

                    ent.espio_poisonstarcount_cd = CurTime() + 6

                    ent:SetNW2Float("Vector_NinjaStarCD", CurTime()+13 + ent.espio_togglestarability_CDAdd)
                    ent:SetNW2Float("Vector_NinjaStarhDur", CurTime()+13+ ent.espio_togglestarability_CDAdd)
                end
            end

            if (not ent.espio_poisonstarcount_cd or ent.espio_poisonstarcount_cd <= CurTime()) and shouldgeneratestar then
                ent.espio_poisonstarcount_cd = CurTime() + 2
                ent:SetNW2Float("espio_poisonstarcount", math.Clamp(ent:GetNW2Float("espio_poisonstarcount") + 1,0,12 ))
            end


            if ent:GetNW2Bool("HoldingSpaceClimb") and not ply:IsOnGround() and ent:GetNW2Float("Climbing_cd_OMEspio_duration") <= CurTime() then

                local startPos = ply:GetPos()
                local endPos = startPos + ent:GetPuppet():GetForward() * 50

                local tr = util.TraceLine({
                    start = startPos,
                    endpos = endPos,
                    filter = ply,
                    mask = MASK_SOLID
                })

                if tr.Hit and math.abs(tr.HitNormal.z) < 0.2 then

                    if not ent.Debounce_HoldingSpaceClimb then
                        ent.Debounce_HoldingSpaceClimb = true
                        ent:SetNW2Float("Kolossos_Climbing_duration_duration", CurTime() + 1.75)
                        ent:SetNW2Float("Kolossos_Climbing_duration_amount", 1.75)
                    end

                    if ent:GetNW2Float("Kolossos_Climbing_duration_duration") >= CurTime() then
                    else
                        ent:SetNW2Bool("HoldingSpaceClimb", false)
                    end

                    local climbspeed = 4

                    if ent:GetNW2Bool("HoldingSpaceClimbClimb_up") then
                        climbspeed = climbspeed + 175
                    end
                    if ent:GetNW2Bool("HoldingSpaceClimbClimb_down") then
                        climbspeed = climbspeed - 175
                    end


                    ent:SetNW2Bool("Kolossos_Climbing", true)
                    ent:SetNW2Angle("pill_assignedangle", (tr.HitNormal - tr.HitNormal*2):Angle())

                    if ply:IsNextBot() then
                        ply:SetVelocity(Vector(0,0,climbspeed))
                    end
                    ply:SetLocalVelocity(Vector(0,0,climbspeed))
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.2)
                else
                    if ent:GetNW2Bool("Kolossos_Climbing") then
                        ply:SetGravity(1)
                        if ply:IsNextBot() then
                            ply:SetVelocity(Vector(0,0,15)+ply:GetForward()*300)
                        end
                        ply:SetLocalVelocity(Vector(0,0,15)+ply:GetForward()*300)
                    end
                    ent:SetNW2Bool("Kolossos_Climbing", false)
                end
            else
                if ent.Debounce_HoldingSpaceClimb then
                    ent.Debounce_HoldingSpaceClimb = false
                    ent:SetNW2Float("Climbing_cd_OMEspio_duration", CurTime() + 17)
                    ent:SetNW2Float("Climbing_cd_OMEspio_amount", 17)
                end
                ent:SetNW2Bool("Kolossos_Climbing", false)
            end
            
            local puppet = ent:GetPuppet()
            local PC = puppet:GetColor()

            ent.Espio_Camouflage_lerp = ent.Espio_Camouflage_lerp or 255
            
            ent.Espio_Camouflage_lerp = Lerp(FrameTime()*10, ent.Espio_Camouflage_lerp, ent:GetNW2Bool("Espio_Camouflage_bool") and 10 or 255)
            puppet:SetRenderMode(RENDERMODE_TRANSCOLOR)
            puppet:SetColor(Color(PC.r, PC.g, PC.b, math.Round(ent.Espio_Camouflage_lerp,0)))
        end
    end,

    OM_Espio_throw = function(ply, ent)
        if SERVER then

            if ent.Espio_throw_timer then
                timer.Remove(ent.Espio_throw_timer)
            end

            if ent.Espio_throw_fade_timer then
                timer.Remove(ent.Espio_throw_fade_timer)
            end

            local puppet = ent:GetPuppet()
            local layeredAnim = puppet:AddGesture(ACT_VM_HITRIGHT2, false)

            local current = 1
            puppet:SetLayerWeight(layeredAnim, current)
            puppet:SetLayerPriority(layeredAnim, 10)

            local playbackRate = 1
            puppet:SetLayerPlaybackRate(layeredAnim, playbackRate)

            local function fadeLayer()
                if not IsValid(puppet) then return end

                current = current - 0.04
                puppet:SetLayerWeight(layeredAnim, math.max(current, 0))

                if current > 0 then
                    ent.Espio_throw_fade_timer = "Espio_throw_fade_" .. ent:EntIndex()
                    timer.Create(ent.Espio_throw_fade_timer, 0.0005, 1, fadeLayer)
                end
            end

            ent.Espio_throw_fade_timer = "Espio_throw_fade_" .. ent:EntIndex() .. "_" .. CurTime()
            timer.Create(ent.Espio_throw_fade_timer, 0.15, 1, fadeLayer)

            ent.Espio_throw_timer = "Espio_throw_" .. ent:EntIndex()

            timer.Create(ent.Espio_throw_timer, 0.9, 1, function()
                if not IsValid(ent) then return end

                local layer = puppet:FindGestureLayer(ACT_VM_HITRIGHT2)

                if layer then
                    puppet:RemoveLayer(layer)
                end

                ent.Espio_throw_timer = nil
            end)

        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if button == KEY_SPACE then
                    
                if ent:GetNW2Float("grabbing_kolossos", 0 ) > CurTime() then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then return end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then return end
                
                if IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) and ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then return end
                
                ent:SetNW2Bool("HoldingSpaceClimb", true)

                if ent:GetNW2Bool("Kolossos_Climbing") then
                    ply:SetLocalVelocity(Vector(0,0,185)+ply:GetForward()*-800)
                    ent:SetNW2Bool("HoldingSpaceClimb", false)
                else
                end
            end
            if button == KEY_W then
                ent:SetNW2Bool("HoldingSpaceClimbClimb_up", true)
            end
            if button == KEY_S then
                ent:SetNW2Bool("HoldingSpaceClimbClimb_down", true)
            end

            if button == KEY_E then

                if ent:GetNW2Float("Vector_NinjaStarCD") >= CurTime() then return end
                if ent:GetNW2Float("espio_togglestarability_duration") >= CurTime() then return end
                if ent.espio_togglestarability_toggle then return end
                
                ent:SetNW2Float("espio_togglestarability_duration", CurTime()+1.65)
                
            end
            if button == KEY_R then
            end
            if button == KEY_T then
                if ent:GetNW2Float("Espio_CamouflageCD") >= CurTime() then return end

                local cd = not ent:GetNW2Bool("Espio_Camouflage_bool") and 0.5 or 8
                ent:SetNW2Bool("Espio_Camouflage_bool", not ent:GetNW2Bool("Espio_Camouflage_bool"))

                ent:SetNW2Float("Espio_CamouflageCD", CurTime() + cd)
                ent:SetNW2Float("Espio_CamouflageDur", cd)
            end
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply,ent,button)
        if SERVER then 
            if button == KEY_SPACE then
                if ent:GetNW2Bool("Kolossos_Climbing") then
                else
                    ent:SetNW2Bool("HoldingSpaceClimb", false)
                end
                --ent:SetNW2Bool("Glide", false)

            end
            if button == KEY_W then
                ent:SetNW2Bool("HoldingSpaceClimbClimb_up", false)
            end
            if button == KEY_S then
                ent:SetNW2Bool("HoldingSpaceClimbClimb_down", false)
            end
        end
    end,


    OM_UI_custom_end = function(ply, ent)

        local screenW, screenH = ScrW(), ScrH()
        local middlex, middley = screenW * 0.5, screenH * 0.5
        local iconsize = screenW / 13


        ent.espio_togglestarability_alpha = ent.espio_togglestarability_alpha or 0

        if ent.espio_togglestarability_alpha >= 0.1 then
            local frac = ent.espio_togglestarability_alpha/255

            local barHeight = screenH * 0.2

            local height = barHeight * frac

            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(
                0,
                0,
                screenW,
                height
            )

            surface.DrawRect(
                0,
                screenH - height,
                screenW,
                height*1.1
            )
        end
    end,

    OM_UI_custom1 = function(ply, ent)
        local countdown = ent:GetNW2Float("espio_togglestarability_duration")
        local duration = ent:GetNW2Float("espio_togglestarability_amount")

        ent.espio_togglestarability_alpha = ent.espio_togglestarability_alpha or 0

        ent.espio_togglestarability_alpha = Lerp(countdown >= CurTime() and FrameTime()*3 or FrameTime()*10, ent.espio_togglestarability_alpha, countdown >= CurTime() and 255 or 0)
        local alpha = ent.espio_togglestarability_alpha

        if alpha > 1 then
            local screenW, screenH = ScrW(), ScrH()
            local iconsize = screenW / 20

            local x = screenW / 2
            local y = screenH / 2

            local icon = ent:GetNW2Bool("espio_togglestarability_mouse") and preservedmats["leftclick"] or preservedmats["rightclick"]

            local rotation = 0

            if ent:GetNW2Float("espio_togglestarability_offset_left") > CurTime() then
                rotation = Lerp(FrameTime() * 10, rotation, 50)
            elseif ent:GetNW2Float("espio_togglestarability_offset_right") > CurTime() then
                rotation = Lerp(FrameTime() * 10, rotation, -50)
            end

            surface.SetMaterial(icon)
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.DrawTexturedRectRotated(
                x ,
                y,
                iconsize,
                iconsize,
                rotation
            )

            local countdown = ent:GetNW2Float("espio_togglestarability_duration")
            local duration = ent:GetNW2Float("espio_togglestarability_amount")

            local progress = math.Clamp((countdown - CurTime()) / duration, 0, 1)

            local barWidth = iconsize
            local barHeight = iconsize * 0.08

            local barX = x - iconsize * 0.5
            local barY = y - iconsize * 0.6

            draw.RoundedBox(
                2,
                barX,
                barY,
                barWidth,
                barHeight,
                Color(0, 0, 0, alpha)
            )

            draw.RoundedBox(
                2,
                barX,
                barY,
                barWidth * progress,
                barHeight,
                Color(255, 255, 255, alpha)
            )
        end


    end,

    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if ent:GetNW2Float("espio_togglestarability_duration") >= CurTime() then
                if ent:GetNW2Bool("espio_togglestarability_mouse") then
                    ent.espio_togglestarability_toggle = false
                    ent:SetNW2Float("espio_togglestarability_offset_left", CurTime()+0.2)
                else
                    ent:SetNW2Float("espio_togglestarability_duration", 0)
                end
            end
        end
    },


    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
            if ent:GetNW2Float("espio_togglestarability_duration") >= CurTime() then
                if not ent:GetNW2Bool("espio_togglestarability_mouse") then
                    ent:SetNW2Float("espio_togglestarability_offset_right", CurTime()+0.2)
                    ent.espio_togglestarability_toggle = false
                else
                    ent:SetNW2Float("espio_togglestarability_duration", 0)
                end
            end
        end,
    },

    reload=function(ply,ent)
    end,
    flashlight = function(ply, ent)
    end,
        
    jump = function(ply, ent)
        if ply:GetNW2Bool("Survivor_Downed_OM") then return end
        ent.AlternatePlaySolution = true
        ent:SetNW2Float("JumpAnim", CurTime()+0.28)
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