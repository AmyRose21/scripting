
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
}

pk_pills.register('pill_om_vector', {

    printName='Vector',
    Outcomememories='Vector',
    Outcomememories_material="Organic",
        
    model="models/nick/OM/tor.mdl",
    
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
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Vector_punchicon_om"]
            end,
            name = function(uselessvar,ply,ent)
                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then  return "Furious Throw" end
                return "Furious Punch"
            end,
            keybind = function(uselessvar,ply,ent)
                return "E"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Vector_PunchCD")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Vector_PunchDur")
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
                return "Mid-Air Dash / Grab"
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
                return "Bound Ring"
            end,
            keybind = function(uselessvar,ply,ent)
                return "T"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Vector_BoundRingCD")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Vector_BoundRingDur")
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
            jump2 = "jump",
        },
        ShouldMoveRotate={
            idle= function(ent)
                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then  return "shiftlock" end
                if ent:GetNW2Bool("Vector_ringpull") or ent:GetNW2Float("Vector_ringpull_throwduration") >= CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return "shiftlock" end
                return "notanything"
            end,
            run= function(ent)
                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then  return "shiftlock" end
                if ent:GetNW2Bool("Vector_ringpull") or ent:GetNW2Float("Vector_ringpull_throwduration") >= CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return "shiftlock" end
                return "notshftlock"
            end,
            walk= function(ent)
                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then  return "shiftlock" end
                if ent:GetNW2Bool("Vector_ringpull") or ent:GetNW2Float("Vector_ringpull_throwduration") >= CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return "shiftlock" end
                return "notshftlock"
            end,
            fall= function(ent) 
                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then  return "shiftlock" end
                if ent:GetNW2Bool("Vector_ringpull") or ent:GetNW2Float("Vector_ringpull_throwduration") >= CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return "shiftlock" end
                return "notshftlock"
            end,
            jump= function(ent) 
                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then  return "shiftlock" end
                if ent:GetNW2Bool("Vector_ringpull") or ent:GetNW2Float("Vector_ringpull_throwduration") >= CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return "shiftlock" end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            idle= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("DashinganimDuration") > CurTime() then return "DashAnim" end

                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return "PunchChargeUp" end
                if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then return "PunchRun" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "IdleLowHealth"
                end 
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("DashinganimDuration") > CurTime() then return "DashAnim" end
                
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return "PunchChargeUp" end
                if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then return "PunchRun" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "WalkLowHealth"
                end 
            end,
            fall= function(ent) 
                if ent:GetNW2Float("DashinganimDuration") > CurTime() then return "DashAnim" end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return "PunchChargeUp" end
                if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then return "PunchRun" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
            end,
            jump= function(ent) 
                if ent:GetNW2Float("DashinganimDuration") > CurTime() then return "DashAnim" end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return "PunchChargeUp" end
                if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then return "PunchRun" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("DashinganimDuration") > CurTime() then return "DashAnim" end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return "PunchChargeUp" end
                if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then return "PunchRun" end
                if ent:GetNW2Float("Vector_punchslowdown") >= CurTime() then
                    if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                        return "RunLowHealth"
                    end 
                    return "walk"
                end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "RunLowHealth"
                end 
            end,
        },
    },
    
    OM_cameratable = function(ply,ent)
        local basetable =  {
            startoffset = Vector(20,0,15),  -- left-up, front-back, up-down
            dist=145,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 0,
            transition = 1,
            canscroll = true,
            bonecenter = "UpperTorso",
        }

        ent.Vector_ringpull_lerp = ent.Vector_ringpull_lerp or 0
        
        ent.Vector_ringpull_lerp = Lerp(FrameTime()*8, ent.Vector_ringpull_lerp, (ent:GetNW2Bool("Vector_ringpull") or ent:GetNW2Float("Vector_ringpull_throwduration") >= CurTime() or IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om"))) and 1 or 0)
        
        basetable["startoffset"] = basetable["startoffset"] + Vector(10*ent.Vector_ringpull_lerp,0,0)
        basetable["dist"] = basetable["dist"] - 70 * ent.Vector_ringpull_lerp

        return basetable
    end,
       
    speedhandeler_om = {
        modifiers = {
            ["Speedup"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then
                    local multiplyer = 1.3 * ent.Vector_punchspeed_multiplyer
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.run()*multiplyer - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run()*multiplyer - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.run()*multiplyer - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
            ["Slowdown"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("Vector_punchslowdown") >= CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
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
            initializetable2["player"]:SetHealth(125)
            initializetable2["player"]:SetMaxHealth(125)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Int("MaxHealth",125)
            initializetable2["player"]:SetNW2Int("MaxHealth_OM",125)

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
                    ent:SetNW2Float("Vector_punchchargeup", 0)
                    ent.Vector_punchchargeup = false
                    if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then
                        ent.Vector_punchcharge = false
                    end
                    ent:SetNW2Float("Vector_punchcharge", 0)

                end
            end

            initializetable2["player"].CustomFunctionForDowned_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]

                    if IsValid(ent:GetNW2Entity("ent_om_vector_ring")) then
                        ent:GetNW2Entity("ent_om_vector_ring"):Remove()
                    end
                    ent:SetNW2Float("Vector_punchchargeup", 0)
                    ent.Vector_punchchargeup = false
                    if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then
                        ent.Vector_punchcharge = false
                    end
                    ent:SetNW2Float("Vector_punchcharge", 0)

                    if ent:GetNW2Bool("Vector_ringpull") then
                        ent:SetNW2Bool("Vector_ringpull", false)
                    end

                    local ent2 = ent:GetNW2Entity("PeelOutGrabEntity_om",ent2)
                    ent:SetNW2Entity("PeelOutGrabEntity_om",NULL)
                    ent2:SetNW2Entity("PeeloutEntity_OM_Sonic",NULL)
                end
            end
            initializetable2["player"].CustomFunctionCancelAbility_OM = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end
            initializetable2["player"].OM_Stun_Blockfunction = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end

        end


    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetNW2Bool("ShoukdntStun_OM_Noodles", false)
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetGravity(1)
        end
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", 1)
            ply:SetNW2Float("OM_Damage_Reduction",ent:GetNW2Float("Vector_armordown") >= CurTime() and 1 or 0.8)
            local shouldiframe = false

            if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then
                if not ent.Vector_punchchargeup then
                    AdvancedPillSound(
                        {
                            stringe = "OM/knuckles/punchstart.wav",
                            pitchPercent = 107,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    AdvancedPillSound(
                        {
                            stringe = "OM/vector/impact.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent:GetPuppet():SetNW2Float("vector_punchflash_white", CurTime()+0.2)
                    ent.Vector_punchchargeup = true
                    ent.Vector_punchdirection = ply:GetForward()
                    ent.Vector_punchspeed = 2000
                    ent:SetNW2Float("Vector_punchchargeup_moveduration", ent:GetNW2Float("Vector_punchchargeup")-0.1)
                end
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.1)

                if ent:GetNW2Float("Vector_punchchargeup_moveduration") >= CurTime() then
                    ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.1)
                    ent.Vector_punchspeed = ent.Vector_punchspeed *0.92
                    ply:SetNW2Vector("OM_SetVelocity_Vector",ent.Vector_punchdirection*ent.Vector_punchspeed*-1)
                else
                    ply:SetLocalVelocity(Vector(0,0,0))
                    ply:SetVelocity(Vector(0,0,0))
                end
            else
                if ent.Vector_punchchargeup then
                    ent:GetPuppet():SetNW2Float("vector_punchflash", CurTime()+0.2)
                    ent.Vector_punchchargeup = false
                    ent:SetNW2Float("Vector_punchcharge", CurTime()+0.8)

                    AdvancedPillSound(
                        {
                            stringe = "OM/cream/Dash.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    AdvancedPillSound(
                        {
                            stringe = "OM/fleetway/Fleetway fateful drain release 2.wav",
                            pitchPercent = 100,
                            volume = 0.6,
                            soundLevel = 87
                        },
                        ent
                    )

                end
            end

            if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then
                if not ent.Vector_punchcharge then
                    ent.Vector_punchcharge = true
                    ent.Vector_punchspeed_multiplyer = 16
                end
                shouldiframe = true
                ply:SetNW2Float("OM_MoveForwardSpeed", ent.formTable.Outcomememories_stats.moveSpeed.run()*1.3*ent.Vector_punchspeed_multiplyer)
                ply:SetNW2Float("OM_MoveForward", CurTime() + 0.2)
                ent.Vector_punchspeed_multiplyer = math.Clamp(ent.Vector_punchspeed_multiplyer * 0.94, 0.8, 1e9)


                local jumpscare_entity = nil
                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 95)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        local canstunstack = false


                        if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then continue end

                        local function hitfunction(shouldstundamage)

                            if shouldstundamage then

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/vector/Vector_HitSound"..math.random(1,2)..".wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/vector/impact.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/knuckles/punchstun.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = "physics/body/body_medium_impact_hard6.wav",
                                        pitchPercent = 100,
                                        volume = 0.25,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = "npc/zombie/zombie_pound_door.wav",
                                        pitchPercent = 90,
                                        volume = 0.25,
                                        soundLevel = 92
                                    },
                                    ent
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = "npc/antlion_guard/shove1.wav",
                                        pitchPercent = 85,
                                        volume = 0.25,
                                        soundLevel = 95
                                    },
                                    ent
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = "ambient/machines/thumper_hit.wav",
                                        pitchPercent = 75,
                                        volume = 0.25,
                                        soundLevel = 96
                                    },
                                    ent
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = "physics/flesh/flesh_squishy_impact_hard4.wav",
                                        pitchPercent = 75,
                                        volume = 0.25,
                                        soundLevel = 86
                                    },
                                    ent
                                )

                                local puppet = ent:GetPuppet()

                                local layeredAnim = puppet:AddGesture(ACT_VM_HITRIGHT, false)

                                local current = 1
                                puppet:SetLayerWeight(layeredAnim, current)
                                puppet:SetLayerPriority(layeredAnim, 10)

                                puppet:SetLayerPlaybackRate(layeredAnim, 1)

                                local function fadeLayer()
                                    if not IsValid(puppet) then return end
                                    current = current - 0.04
                                    puppet:SetLayerWeight(layeredAnim, math.max(current, 0))

                                    if current > 0 then
                                        timer.Simple(0.0005, fadeLayer)
                                    end
                                end

                                timer.Simple(0.3, fadeLayer)

                                timer.Simple(1.2,function()
                                    if !IsValid(ent) then return end
                                    puppet:RemoveLayer(puppet:FindGestureLayer(ACT_VM_HITRIGHT))
                                end)



                                        
                                local ed = EffectData()
                                ed:SetOrigin(ent2:GetPos()+Vector(0,0,40))
                                util.Effect("Knuckles_punch_OM", ed)

                            
                                local last = CurTime() + 2
                                local flung = false
                                local enemyragdoll = CreateRagdolLCharacter_OM({
                                    target = ent2,
                                    host = ent,

                                    shouldremove = function(createfakeragdoll)
                                        if not IsValid(createfakeragdoll) then return true end
                                        if not IsValid(ent2) then return true end

                                        if last < CurTime() then return true end

                                        return false
                                    end,

                                    shoulddocustomfunction = function(createfakeragdoll)
                                        if not IsValid(createfakeragdoll) then return end
                                        if not IsValid(ent2) then return end
                                        if flung then return end
                                        flung = true
                                        local dir = (ent2:GetPos() - ply:GetPos()):GetNormalized()


                                        for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                            local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                            if IsValid(phys) then
                                                phys:Wake()
                                                phys:SetVelocityInstantaneous(dir*1300)
                                            end
                                        
                                        end
                                    end
                                })
                            end
                        end
                            
                        ent:SetNW2Float("Vector_punchcharge", 0)

                        if Mutual_OMCanStun(ply, ent, ent2, canstunstack) then
                            if IsValid(ent2:GetNWEntity("OM_ragdollentity")) then
                                continue
                            end

                            Mutaul_OMStunCode(
                                {
                                    ["ply"] = ply,
                                    ["ent"] = ent,
                                    ["target"] = ent2,
                                    ["StunDur"] = 3,
                                    ["stunfunction"] = function(shouldstundamage)
                                        hitfunction(shouldstundamage)
                                    end,
                                    ["checkoutprevention"] = true,
                                    ["shouldstack"] = canstunstack,
                                    ["Damage"] = 13, -- ent:GetNW2Float(StunTimesName) < 2  and true or 30
                                    ["DamageType"] = DMG_CLUB
                                }
                            )
                            ent.HitStun = true
                        else
                            --[[
                            Mutaul_OMStunCode(
                                {
                                    ["ply"] = ply,
                                    ["ent"] = ent,
                                    ["target"] = ent2,
                                    ["StunDur"] = 1.5,
                                    ["stunfunction"] = function(shouldstundamage)
                                        hitfunction(shouldstundamage)
                                    end,
                                    ["checkoutprevention"] = true,
                                    ["shouldstack"] = canstunstack,
                                    ["Damage"] = 13, -- ent:GetNW2Float(StunTimesName) < 2  and true or 30
                                    ["DamageType"] = DMG_CLUB
                                }
                            )
                            ent.HitWithIframes = true
                            ]]

                        end
                    end
                end

            else
                if ent.Vector_punchcharge then
                    ent.Vector_punchcharge = false
                    ent:SetNW2Float("Vector_punchslowdown", CurTime()+1.3)

                    local dur = ent.HitWithIframes and 35 or ent.HitStun and 28 or 20
                    ent:SetNW2Float("Vector_PunchCD", CurTime() + dur )
                    ent:SetNW2Float("Vector_PunchDur", dur )

                    ent.HitStun = false
                    ent.HitWithIframes = false
                end
            end

            local puppet = ent:GetPuppet()
            ent.layeredAnim_time = ent.layeredAnim_time or 0
            if not ent.layeredAnim then
                ent.layeredAnim = puppet:AddGesture(ACT_VM_HITCENTER2, false)
                puppet:SetLayerWeight(ent.layeredAnim, 0)
                puppet:SetLayerPriority(ent.layeredAnim, 10)
            end

            ent.layeredAnim_time = Lerp(FrameTime()*8, ent.layeredAnim_time, not ent:GetNW2Bool("Vector_ringpull") and 0 or 1)
            if ent.layeredAnim then puppet:SetLayerWeight(ent.layeredAnim, ent.layeredAnim_time) end


            if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then
                local peel = ent:GetNW2Entity("PeelOutGrabEntity_om")
                peel:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.15)

                local startPos   = ply:GetPos() + Vector(0, 0, 30)
                local desiredPos = startPos + ent:GetPuppet():GetForward() * 50

                local pMins, pMaxs = peel:OBBMins(), peel:OBBMaxs()
                pMins = pMins - Vector(2, 2, 2)
                pMaxs = pMaxs + Vector(2, 2, 2)

                local tr = util.TraceHull({
                    start  = startPos,
                    endpos = desiredPos,
                    mins   = pMins,
                    maxs   = pMaxs,
                    filter = { ply, ent, peel },
                    mask   = MASK_SOLID
                })

                local safePos
                if tr.Hit then
                    safePos = tr.HitPos + tr.HitNormal * 2
                else
                    safePos = desiredPos
                end

                local plyMins, plyMaxs = ply:OBBMins(), ply:OBBMaxs()
                local plyRadius = math.max(
                    math.abs(plyMins.x), math.abs(plyMins.y),
                    math.abs(plyMaxs.x), math.abs(plyMaxs.y)
                )

                local peelRadius = math.max(
                    math.abs(pMins.x), math.abs(pMins.y),
                    math.abs(pMaxs.x), math.abs(pMaxs.y)
                )

                local minDist = plyRadius + peelRadius + 4
                local dir = safePos - ply:GetPos()
                local dist = dir:Length()

                if dist < minDist then
                    dir:Normalize()
                    safePos = ply:GetPos() + dir * minDist
                end

                if util.IsInWorld(safePos) then
                    peel:SetPos(safePos)
                end

                ent:GetNW2Entity("PeelOutGrabEntity_om"):SetNW2Float("OM_character_shouldnotgrab2", CurTime()+0.1)
            end

            if ent:GetNW2Float("DashDuration") >= CurTime() then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                ent:SetNW2Float("DashinganimDuration", CurTime()+0.1)
                
                local jumpscare_entity = nil

                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 100)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end

                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if ent2 == ent.PeelOutGrabEntity_om_oldone then continue end

                        if ent2:GetNW2Bool("OM_character") and not ent2:GetNW2Bool("OM_character_shouldnotgrab") and ent2:GetNW2Float("OM_character_shouldnotgrab2") < CurTime() and ent2:GetNW2Float("OM_character_Sonic_pickup_debounce") < CurTime() then
                            ent.PeelOutGrabEntity_om_oldone = ent:GetNW2Entity("PeelOutGrabEntity_om")

                            ent:SetNW2Float("DashDuration",0)

                            ent:SetNW2Entity("PeelOutGrabEntity_om",ent2)
                            ent2:SetNW2Entity("PeeloutEntity_OM_Sonic",ent)

                            AdvancedPillSound(
                                {
                                    stringe = "OM/sonic/peeloutpickup.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                            ply:SetLocalVelocity(Vector(0,0,0))

                            if ent2:GetNW2Bool("Survivor_Downed_OM") then
                                if ent2.ReviveFunction_OM then
                                    ent2:ReviveFunction_OM()
                                end
                            end
                        end
                    end
                end
            end
            if shouldiframe then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.15)
                ply:SetNW2Float("OM_Damage_Reduction",0)
            else
                ply:SetNW2Float("OM_Damage_Reduction",1)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if button == KEY_E then
                if ent:GetNW2Float("Vector_PunchCD") >= CurTime() then return end

                if IsValid(ent:GetNW2Entity("ent_om_vector_ring")) then return end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return end
                if ent.Vector_punchchargeup then return end
                if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then return end
                if ent.Vector_punchcharge then return end
                if ent:GetNW2Float("Vector_punchslowdown") >= CurTime() then return end
                if ent:GetNW2Float("Vector_ThrowingDuration") >= CurTime() then return end
                if ent:GetNW2Float("DashDuration") >= CurTime() then return end

                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then

                    local dur = 20
                    ent:SetNW2Float("Vector_PunchCD", CurTime() + dur )
                    ent:SetNW2Float("Vector_PunchDur", dur )

                    ent:SetNW2Float("Vector_ThrowingDuration", CurTime() + 1 )

                    AdvancedPillSound({
                        stringe = "OM/vector/sparing.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 76
                    }, ent)
                    AdvancedPillSound(
                        {
                            stringe = "OM/Amy/HammerThrow.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    local puppet = ent:GetPuppet()

                    local layeredAnim = puppet:AddGesture(ACT_VM_HITRIGHT2, false)

                    local current = 1
                    puppet:SetLayerWeight(layeredAnim, current)
                    puppet:SetLayerPriority(layeredAnim, 10)

                    puppet:SetLayerPlaybackRate(layeredAnim, 1)

                    local function fadeLayer()
                        if not IsValid(puppet) then return end
                        current = current - 0.04
                        puppet:SetLayerWeight(layeredAnim, math.max(current, 0))

                        if current > 0 then
                            timer.Simple(0.0005, fadeLayer)
                        end
                    end

                    timer.Simple(0.7, fadeLayer)

                    timer.Simple(1.7,function()
                        if !IsValid(ent) then return end
                        puppet:RemoveLayer(puppet:FindGestureLayer(ACT_VM_HITRIGHT2))
                    end)

                    local ent2 = ent:GetNW2Entity("PeelOutGrabEntity_om",ent2)

                    timer.Simple(0.2,function()
                        if !IsValid(ent) then return end
                        if !IsValid(ent2) then return end
                        ent:SetNW2Entity("PeelOutGrabEntity_om",NULL)
                        ent2:SetNW2Entity("PeeloutEntity_OM_Sonic",NULL)

                        local last = CurTime() + 3
                        local flingingduration = CurTime() + 0.1
                        local flung = false

                        local dir = ply:GetAimVector()

                        local enemyragdoll = CreateRagdolLCharacter_OM({
                            target = ent2,
                            host = ent,

                            shouldremove = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return true end
                                if not IsValid(ent2) then return true end
                                if not IsValid(ent) then return true end

                                if last >= CurTime() then else return true end

                                return false
                            end,

                            shoulddocustomfunction = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return end
                                if not IsValid(ent) then return end
                                ent2:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+1)


                                if createfakeragdoll:GetVelocity():Length() >= 100 then
                                    local jumpscare_entity = nil
                                    for _, ent2 in pairs(ents.FindInSphere(createfakeragdoll:GetPos(), 95)) do
                                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                                        if ent2:GetClass() == "pill_puppet" then continue end
                                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                                            if ent2 == ply then continue end
                                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                            local canstunstack = false


                                            if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then continue end

                                            local function hitfunction(shouldstundamage)

                                                if shouldstundamage then

                                                    last = CurTime() + 0.5

                                                    AdvancedPillSound(
                                                        {
                                                            stringe = "OM/vector/Vector_HitSound"..math.random(1,2)..".wav",
                                                            pitchPercent = 100,
                                                            volume = 1,
                                                            soundLevel = 87
                                                        },
                                                        ent2
                                                    )

                                                    AdvancedPillSound(
                                                        {
                                                            stringe = "OM/vector/impact.wav",
                                                            pitchPercent = 100,
                                                            volume = 1,
                                                            soundLevel = 87
                                                        },
                                                        ent2
                                                    )

                                                    AdvancedPillSound(
                                                        {
                                                            stringe = "OM/knuckles/punchstun.wav",
                                                            pitchPercent = 100,
                                                            volume = 1,
                                                            soundLevel = 87
                                                        },
                                                        ent2
                                                    )

                                                    AdvancedPillSound(
                                                        {
                                                            stringe = "physics/body/body_medium_impact_hard6.wav",
                                                            pitchPercent = 100,
                                                            volume = 0.25,
                                                            soundLevel = 87
                                                        },
                                                        ent2
                                                    )

                                                    AdvancedPillSound(
                                                        {
                                                            stringe = "npc/zombie/zombie_pound_door.wav",
                                                            pitchPercent = 90,
                                                            volume = 0.25,
                                                            soundLevel = 92
                                                        },
                                                        ent2
                                                    )

                                                    AdvancedPillSound(
                                                        {
                                                            stringe = "npc/antlion_guard/shove1.wav",
                                                            pitchPercent = 85,
                                                            volume = 0.25,
                                                            soundLevel = 95
                                                        },
                                                        ent2
                                                    )

                                                    AdvancedPillSound(
                                                        {
                                                            stringe = "ambient/machines/thumper_hit.wav",
                                                            pitchPercent = 75,
                                                            volume = 0.25,
                                                            soundLevel = 96
                                                        },
                                                        ent2
                                                    )

                                                    AdvancedPillSound(
                                                        {
                                                            stringe = "physics/flesh/flesh_squishy_impact_hard4.wav",
                                                            pitchPercent = 75,
                                                            volume = 0.25,
                                                            soundLevel = 86
                                                        },
                                                        ent2
                                                    )

                                                            
                                                    local ed = EffectData()
                                                    ed:SetOrigin(ent2:GetPos()+Vector(0,0,40))
                                                    util.Effect("Knuckles_punch_OM", ed)

                                                
                                                    local last = CurTime() + 2
                                                    local flung = false
                                                    local enemyragdoll = CreateRagdolLCharacter_OM({
                                                        target = ent2,
                                                        host = ent,

                                                        shouldremove = function(createfakeragdoll)
                                                            if not IsValid(createfakeragdoll) then return true end
                                                            if not IsValid(ent2) then return true end

                                                            if last < CurTime() then return true end

                                                            return false
                                                        end,

                                                        shoulddocustomfunction = function(createfakeragdoll)
                                                            if not IsValid(createfakeragdoll) then return end
                                                            if not IsValid(ent2) then return end
                                                            if flung then return end
                                                            flung = true
                                                            local dir = (ent2:GetPos() - ply:GetPos()):GetNormalized()


                                                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                                local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                                                if IsValid(phys) then
                                                                    phys:Wake()
                                                                    phys:SetVelocityInstantaneous(dir*1300)
                                                                end
                                                            
                                                            end
                                                        end
                                                    })
                                                end
                                            end
                                            if Mutual_OMCanStun(ply, ent, ent2, canstunstack) then
                                                if IsValid(ent2:GetNWEntity("OM_ragdollentity")) then
                                                    continue
                                                end

                                                Mutaul_OMStunCode(
                                                    {
                                                        ["ply"] = ply,
                                                        ["ent"] = ent,
                                                        ["target"] = ent2,
                                                        ["StunDur"] = 3,
                                                        ["stunfunction"] = function(shouldstundamage)
                                                            hitfunction(shouldstundamage)
                                                        end,
                                                        ["checkoutprevention"] = true,
                                                        ["shouldstack"] = canstunstack,
                                                        ["Damage"] = 13, -- ent:GetNW2Float(StunTimesName) < 2  and true or 30
                                                        ["DamageType"] = DMG_CLUB
                                                    }
                                                )
                                            end
                                        end
                                    end
                                end

                                if flingingduration <= CurTime() then return end

                                local ragPos = createfakeragdoll:GetPos()
                                local entPos = ent:GetPos()

                                local force = dir * 2000

                                local phys = createfakeragdoll:GetPhysicsObject()
                                if IsValid(phys) then
                                    phys:SetVelocity(force)
                                    --phys:AddAngleVelocity(VectorRand() * 300)
                                end

                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                    local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                    if IsValid(bonePhys) then
                                        bonePhys:SetVelocity(force)
                                        bonePhys:AddAngleVelocity(VectorRand() * 300)
                                    end
                                end
                            end
                        })

                    end)
                else
                    ent:SetNW2Float("Vector_punchchargeup", CurTime()+0.5)
                end
            end
            if button == KEY_R then

                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then

                    local ent2 = ent:GetNW2Entity("PeelOutGrabEntity_om",ent2)
                    ent:SetNW2Entity("PeelOutGrabEntity_om",NULL)
                    ent2:SetNW2Entity("PeeloutEntity_OM_Sonic",NULL)

                    return
                end
                if ent:GetNW2Float("Vector_MidairdashCD") >= CurTime() then return end

                if ent:GetNW2Float("DashDuration") >= CurTime() then return end
                if IsValid(ent:GetNW2Entity("ent_om_vector_ring")) then return end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return end
                if ent.Vector_punchchargeup then return end
                if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then return end
                if ent.Vector_punchcharge then return end
                if ent:GetNW2Float("Vector_punchslowdown") >= CurTime() then return end
                if ent:GetNW2Float("Vector_ThrowingDuration") >= CurTime() then return end

                ent:SetNW2Float("DashDuration", CurTime()+0.6)
                local vel2 = ply:GetAimVector()*500*1.6
                vel2.x = vel2.x *1.3
                vel2.y = vel2.y *1.3
                --ply:SetVelocity(vel2)
                if ply:IsOnGround() then
                    ply:SetPos(ply:GetPos()+Vector(0,0,10))
                    vel2.z = math.Clamp(vel2.y, 100, 500)
                end

                ply:SetLocalVelocity(vel2)


                local dur = 25
                ent:SetNW2Float("Vector_MidairdashCD", CurTime() + dur )
                ent:SetNW2Float("Vector_MidairdashDur", dur )

            end

            if button == KEY_T then
                if ent:GetNW2Float("Vector_BoundRingCD") >= CurTime() then return end

                if ent:GetNW2Float("DashDuration") >= CurTime() then return end
                if IsValid(ent:GetNW2Entity("ent_om_vector_ring")) then return end
                if ent:GetNW2Float("Vector_punchchargeup") >= CurTime() then return end
                if ent.Vector_punchchargeup then return end
                if ent:GetNW2Float("Vector_punchcharge") >= CurTime() then return end
                if ent.Vector_punchcharge then return end
                if ent:GetNW2Float("Vector_punchslowdown") >= CurTime() then return end
                if ent:GetNW2Float("Vector_ThrowingDuration") >= CurTime() then return end

                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then return end

                ent:GetPuppet():SetNW2Float("vector_punchflash_yellow", CurTime()+0.2)

                local dur = 1
                ent:SetNW2Float("Vector_BoundRingCD", CurTime() + dur )
                ent:SetNW2Float("Vector_BoundRingDur", dur )

                if not ent:GetNW2Bool("Vector_ringpull") then
                    ent:SetNW2Bool("Vector_ringpull", true)
                    AdvancedPillSound({
                        stringe = "OM/vector/weaponpull.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 76
                    }, ent)
                else
                    ent:SetNW2Bool("Vector_ringpull", false)
                    AdvancedPillSound(
                        {
                            stringe = "OM/Amy/HammerThrowCancel.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            end
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply,ent,button)
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if IsValid(ent:GetNW2Entity("ent_om_vector_ring")) then return end
            if ent:GetNW2Bool("Vector_ringpull") then
                ent:SetNW2Bool("Vector_ringpull", false)
                ent:SetNW2Float("Vector_ringpull_throwduration", CurTime()+0.6)

                AdvancedPillSound({
                    stringe = "OM/vector/sparing.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 76
                }, ent)
                AdvancedPillSound(
                    {
                        stringe = "OM/Amy/HammerThrow.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                local puppet = ent:GetPuppet()

                local layeredAnim = puppet:AddGesture(ACT_VM_HITCENTER, false)

                local current = 1
                puppet:SetLayerWeight(layeredAnim, current)
                puppet:SetLayerPriority(layeredAnim, 10)

                puppet:SetLayerPlaybackRate(layeredAnim, 1)

                local function fadeLayer()
                    if not IsValid(puppet) then return end
                    current = current - 0.04
                    puppet:SetLayerWeight(layeredAnim, math.max(current, 0))

                    if current > 0 then
                        timer.Simple(0.0005, fadeLayer)
                    end
                end

                timer.Simple(0.5, fadeLayer)

                timer.Simple(1.3,function()
                    if !IsValid(ent) then return end
                    puppet:RemoveLayer(puppet:FindGestureLayer(ACT_VM_HITCENTER))
                end)

                timer.Simple(0.2,function()
                    if !IsValid(ent) then return end
                    puppet:SetBodygroup(1,1)


                    local rock = ents.Create("ent_om_vector_ring")

                    if IsValid(rock) then

                        rock:SetPos(ply:GetPos()+Vector(0,0,60) + ply:GetAimVector()*40)
                        rock:SetAngles(ply:GetAimVector():Angle())
                        rock:Spawn()

                        rock.Owner = ply
                        rock.EntOwner = ent

                        ent:SetNW2Entity("ent_om_vector_ring", rock)

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
                        rock:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                    end

                end)
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
        if ply:GetNW2Bool("Survivor_Downed_OM") then return end
        ent.AlternatePlaySolution = true
        if SERVER then
            ent:PillAnim('jump2')
        end
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