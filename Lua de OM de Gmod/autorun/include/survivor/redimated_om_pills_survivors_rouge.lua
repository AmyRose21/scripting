
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

if SERVER then
    util.AddNetworkString("OM_FlashBangScreen")
else

    local flashAlpha = 0
    local flashState = "none"

    local fadeInTime = 0.005
    local holdTime = 5
    local fadeOutTime = 1

    local flashStart = 0


    net.Receive("OM_FlashBangScreen", function()

        flashStart = CurTime()
        flashState = "fadein"

    end)


    hook.Add("HUDPaint", "ZZZ_OM_FlashBangEffect", function()

        if flashState == "none" then return end

        local time = CurTime() - flashStart


        if time <= fadeInTime then

            flashAlpha = math.Clamp(
                (time / fadeInTime) * 255,
                0,
                255
            )

        elseif time <= fadeInTime + holdTime then

            flashAlpha = 255

        elseif time <= fadeInTime + holdTime + fadeOutTime then

            local fadeTime = time - fadeInTime - holdTime

            flashAlpha = Lerp(
                fadeTime / fadeOutTime,
                255,
                0
            )

        else

            flashAlpha = 0
            flashState = "none"

        end


        surface.SetDrawColor(255, 255, 255, flashAlpha)
        surface.DrawRect(0, 0, ScrW(), ScrH())

    end)


    hook.Add("PostRenderVGUI", "ZZZ_OM_FlashBangVGUIBlock", function()

        if flashState == "none" then return end
        if flashAlpha <= 0 then return end

        surface.SetDrawColor(255,255,255,flashAlpha)
        surface.DrawRect(0,0,ScrW(),ScrH())

    end)

end

if SERVER then--
    timer.Simple(1,function()
        if SERVER then else return end
        OM_AddSpeedConfigeration(function(entity)
            if SERVER and entity:GetNW2Float("OM_FlashBangScreen_rougeslowdown", 0) >= CurTime() then
                return 0.7
            end
            return 1
        end)
    end)
end

hook.Add("SetupMove", "Silver_RockHit_debuff", function(ply, mv, cmd)
    if !IsValid(ply) then return end
    if !ply:Alive() then return end

    if ply:GetNW2Float("OM_FlashBangScreen_rougeslowdown", 0) >= CurTime() then
        local vel = mv:GetVelocity()

        vel.x = vel.x * 0.7
        vel.y = vel.y * 0.7

        mv:SetVelocity(vel)
    end
end)

local preservedmats = {
    ["rouge_kick_om"] = Material("icons/rouge_kick_om.png"),
    ["rouge_smokebomb_om"] = Material("icons/rouge_smokebomb_om.png"),
}

pk_pills.register('pill_om_Rouge', {

    printName='Rouge',
    Outcomememories='Rouge',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/Rouge.mdl",
    
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
                return preservedmats["rouge_smokebomb_om"]
            end,
            name = function(uselessvar,ply,ent)
                return "Flash Bang"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_rouge_ability_1_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("smokebomb_rougeom_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0- iconsize*0.05, yaxis = 0- iconsize*0.03, xsize = 0+ iconsize*0.15, ysize = 0+ iconsize*0.15}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["rouge_kick_om"]
            end,
            name = function(uselessvar,ply,ent)
                return "Sweep Kick"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_rouge_ability_2_key", KEY_R)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("SweepKick_rouge_om_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 28
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
            Jump2 = "jump",
            SweepKick = "SweepKick",
            Flap = "flap",
        },
        ShouldMoveRotate={
            idle= function(ent)
                local ply = ent:GetPillUser()
                if not ply:IsOnGround() then if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "assignedagnles" end end
                if ent:GetNW2Float("Aim_smokeBomb_rouge_om") > CurTime() then 
                    return "shiftlock"
                end
                if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then
                    return "shiftlock"
                end
                return "notanything"
            end,
            flap= function(ent)
                local ply = ent:GetPillUser()
                if not ply:IsOnGround() then if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "assignedagnles" end end
                if ent:GetNW2Float("Aim_smokeBomb_rouge_om") > CurTime() then 
                    return "shiftlock"
                end
                if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            run= function(ent)
                local ply = ent:GetPillUser()
                if not ply:IsOnGround() then if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "assignedagnles" end end
                if ent:GetNW2Float("Aim_smokeBomb_rouge_om") > CurTime() then 
                    return "shiftlock"
                end
                if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            walk= function(ent)
                local ply = ent:GetPillUser()
                if not ply:IsOnGround() then if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "assignedagnles" end end
                if ent:GetNW2Float("Aim_smokeBomb_rouge_om") > CurTime() then 
                    return "shiftlock"
                end
                if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            fall= function(ent) 
                local ply = ent:GetPillUser()
                if not ply:IsOnGround() then if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "assignedagnles" end end
                if ent:GetNW2Float("Aim_smokeBomb_rouge_om") > CurTime() then 
                    return "shiftlock"
                end
                if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            jump= function(ent) 
                local ply = ent:GetPillUser()
                if not ply:IsOnGround() then if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "assignedagnles" end end
                if ent:GetNW2Float("Aim_smokeBomb_rouge_om") > CurTime() then 
                    return "shiftlock"
                end
                if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then
                    return "shiftlock"
                end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            idle= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "latch" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "IdleLowHealth"
                end 
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "latch" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "WalkLowHealth"
                end 
            end,
            fall= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "latch" end
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "latch" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "RunLowHealth"
                end 
                if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then
                    if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                        return "WalkLowHealth"
                    end 
                    return "Walk"
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
        ent.Aim_smokeBomb_rouge_om = ent.Aim_smokeBomb_rouge_om or 0
        if ent:GetNW2Float("Aim_smokeBomb_rouge_om") > CurTime() then 
            ent.Aim_smokeBomb_rouge_om = Lerp(FrameTime()*4, ent.Aim_smokeBomb_rouge_om, 1)
        else
            ent.Aim_smokeBomb_rouge_om = Lerp(FrameTime()*4, ent.Aim_smokeBomb_rouge_om, 0)
        end
        
        ent.SweepKick_charge_rouge_om_lerp = ent.SweepKick_charge_rouge_om_lerp or 0
        if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then
            ent.SweepKick_charge_rouge_om_lerp = Lerp(FrameTime()*4, ent.SweepKick_charge_rouge_om_lerp, 1)
        else
            ent.SweepKick_charge_rouge_om_lerp = Lerp(FrameTime()*4, ent.SweepKick_charge_rouge_om_lerp, 0)
        end
        
        ent.SweepKick_rouge_om_lerp = ent.SweepKick_rouge_om_lerp or 0
        if ent:GetNW2Float("SweepKick_rouge_om") > CurTime() then
            ent.SweepKick_rouge_om_lerp = Lerp(FrameTime()*4, ent.SweepKick_rouge_om_lerp, 1)
        else
            ent.SweepKick_rouge_om_lerp = Lerp(FrameTime()*7, ent.SweepKick_rouge_om_lerp, 0)
        end

        basetable["dist"] = basetable["dist"] - ent.Aim_smokeBomb_rouge_om * 80 - ent.SweepKick_charge_rouge_om_lerp * 30 + ent.SweepKick_rouge_om_lerp * 15
        basetable["fov"] = basetable["fov"] - ent.Aim_smokeBomb_rouge_om * 15 - ent.SweepKick_charge_rouge_om_lerp * 30 + ent.SweepKick_rouge_om_lerp * 15
        basetable["startoffset"] = basetable["startoffset"] + Vector(ent.Aim_smokeBomb_rouge_om * 25, 0,0)

        return basetable
    end,
       
    speedhandeler_om = {
        modifiers = {
            ["ChargeKick"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.5 - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.5 - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.5 - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
            ["ChargeKick"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("SweepKick_rouge_om") > CurTime() then
                    sendtotable["Walk"] = GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_speed"):GetFloat() - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_speed"):GetFloat() - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_speed"):GetFloat() - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end
        }
    }, 

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_rouge_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_rouge_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_rouge_walk"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_rouge_jumppower"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_rouge_jumpcd"):GetFloat()
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_rouge_rollingPower"):GetFloat()
                end
            end,
        },
    },

    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            return true
        end,
        colorbar = function(uselessvar,ply,ent)
            return Color(175, 0, 245, 255)
        end,
        progression = function(uselessvar,ply,ent)
            return ent:GetNW2Float("rouge_latchbar")
        end,
        maximumbar = function(uselessvar,ply,ent)
            return 100
        end,
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
        
    OM_transitionbar_type2table = {
        ColorDisplay = Color(255,0,0,255),
        CanShowcase = function(e,ply, ent)
            return ent:GetNW2Float("JumpCD_rouge_om_cd") > CurTime()
        end,
        Factor = function(e,ply, ent)
            local clamp = math.Clamp(( ent:GetNW2Float("JumpCD_rouge_om_cd") - CurTime()) / ent:GetNW2Float("JumpCD_rouge_om"), 0, 1)
            return Lerp(clamp, 1, 0)
        end,
        offset = function(e,ply, ent)
            return Vector(-20,15,0)
        end
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
            local health = GetConVar("OUTCOMEMEMORIES_N_rouge_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Int("MaxHealth", health)
            initializetable2["player"]:SetNW2Int("MaxHealth_OM", health)
            initializetable2["entity"]:SetNW2Float("rouge_latchbar", GetConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_starter"):GetFloat() )
        end
        initializetable2["player"]:SetNW2Bool("OM_character", true)
        initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
        initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)


        initializetable2["player"].CustomFunctionForDowned_OM = function()
            if IsValid(initializetable2["entity"]) then
                local ply = initializetable2["player"]
                local ent = initializetable2["entity"]

                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_WALK)
                else
                    ply:SetMoveType(0)
                end
                ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)

                ply:SetNW2Float("OM_Damage_Reduction",1)
                if ent.SweepKick_rouge_om_stun_bool then
                    ent.SweepKick_rouge_om_stun_bool = false
                    ent:SetNW2Float("SweepKick_rouge_om_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_miss"):GetFloat() )
                end
                ent:SetNW2Float("SweepKick_charge_rouge_om", 0) 
                ent.SweepKick_charge_rouge_om_bool = false
                ent:SetNW2Float("SweepKick_rouge_om", 0)
                ent:SetNW2Float("SweepKick_rouge_om_stun", 0)
                ent.SweepKick_rouge_om_stun_bool = false
            end
        end
        initializetable2["player"].CustomFunctionCancelAbility_OM = function()
            initializetable2["player"]:CustomFunctionForDowned_OM()
        end
        initializetable2["player"].OM_Stun_Blockfunction = function()
            initializetable2["player"]:CustomFunctionForDowned_OM()
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
            ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_rouge_Resistance"):GetFloat()/100)
            ply:SetNW2Float("OM_Damage_Reduction",GetConVar("OUTCOMEMEMORIES_N_rouge_passivereduction"):GetFloat()/100)
            if ply:IsOnGround() then
                if ent:GetNW2Float("UsedJumps") > 0 then
                    ent:SetNW2Float("JumpCD_rouge_om", GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_cdperjump"):GetFloat() * ent:GetNW2Float("UsedJumps") )
                    ent:SetNW2Float("JumpCD_rouge_om_cd", CurTime() + GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_cdperjump"):GetFloat() * ent:GetNW2Float("UsedJumps") )
                    ent:SetNW2Float("UsedJumps", 0)
                end
                ent:SetNW2Bool("JetpackJump", false)
                ent:SetNW2Bool("HasDoubleJump", false)
            else
                ent:SetNW2Bool("HasDoubleJump", true)
                ent:SetNW2Bool("JetpackJump", true)
            end

            local max = GetConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_maximum"):GetFloat()

            if ent:GetNW2Float("rouge_latchbar") <= 0 then
                ent:SetNW2Float("rouge_latchbar", 0)
            end
            if ent:GetNW2Float("rouge_latchbar") >= max then
                ent:SetNW2Float("rouge_latchbar", max)
            end

            if not ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") and ent:GetNW2Float("rouge_latchbar") <= max then
                ent:SetNW2Float("rouge_latchbar", ent:GetNW2Float("rouge_latchbar") + GetConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_regen"):GetFloat() / 1000 )
                if ent:GetNW2Float("rouge_latchbar") >= 35 then
                    ent.Rouge_OM_regenserious = false
                end
            else

                if ent:GetNW2Float("rouge_latchbar") >= 35 then
                    ent.Rouge_OM_regenserious = false
                end

                if ent:GetNW2Float("rouge_latchbar") <= 1 then
                    ent.Rouge_OM_regenserious = true
                end
            end


            if not ply:IsOnGround() then
                if not ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then
                    if ent:GetNW2Float("Latches_knuckles_om") > 0 and not ent.Rouge_OM_regenserious then
                        local startPos = ply:GetPos()
                        local dir = ply:GetForward() * 1
                        local endPos = startPos + dir * 20

                        local tr = util.TraceLine({
                            start = startPos,
                            endpos = endPos,
                            filter = function(ent)
                                if not IsValid(ent) then return false end

                                if ent == ply then return false end

                                if ent:IsPlayer() then return false end
                                if ent:IsNPC() then return false end
                                if ent:IsNextBot() then return false end
                                if ent:GetClass() == "prop_ragdoll" then return false end

                                return true
                            end,
                            mask = MASK_SOLID
                        })

                        if tr.Hit then
                            local groundTrace = util.TraceLine({
                                start = ply:GetPos(),
                                endpos = ply:GetPos() - Vector(0,0,900),
                                filter = ply,
                                mask = MASK_SOLID_BRUSHONLY
                            })

                            if groundTrace.HitPos:Distance(ply:GetPos()) > 25 then
                                local function latching( )
                                    --if ply:IsPlayer() then else return end
                                    
                                    local normal = tr.HitNormal

                                    if math.abs(normal.z) < 0.5 then
                                        if ply:IsPlayer() then
                                            ply:SetMoveType(0)
                                        else

                                        end
                                        local ang = normal:Angle()
                                        
                                        ent.Normals_latch_knuckles_OM = ang
                                        --ply:SetPos(tr.HitPos + tr.HitNormal * 5)
                                        ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", true)

                                        ply:SetVelocity(Vector(0,0,0))
                                        ply:SetLocalVelocity(Vector(0,0,0))

                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/knuckles/Latch.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        )
                                        ent:SetNW2Float("startPos_knuckles", startPos)
                                        ent:SetNW2Float("endPos_knuckles", tr.HitPos)

                                        local angle = ( (tr.HitPos+ tr.HitNormal*5) - tr.HitPos ):Angle()
                                        ent:SetNW2Angle("pill_assignedangle", angle)
                                        ent:SetNW2Float("Latches_knuckles_om",  ent:GetNW2Float("Latches_knuckles_om") - 1)
                                    end
                                end

                                local hitEnt = tr.Entity
                                if IsValid(hitEnt) then
                                    if hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:IsNextBot() then
                                    else
                                        latching()
                                    end
                                else
                                    latching()
                                end
                            end
                        end
                    end
                else

                    ent:SetNW2Float("rouge_latchbar", ent:GetNW2Float("rouge_latchbar") - GetConVar("OUTCOMEMEMORIES_N_rouge_passive_latch_energydrain"):GetFloat() )


                    ply:SetNW2Float("OM_NoMovement_noodles_jump", CurTime()+0.2)
                    if ply:IsPlayer() then else 
                        ply:SetVelocity(Vector(0,0,25))
                    end
                    ply:SetLocalVelocity(Vector(0,0,0))

                    ply:SetPos(ply:GetPos()+Vector(0,0,-0.3))
                    local groundTrace = util.TraceLine({
                        start = ply:GetPos(),
                        endpos = ply:GetPos() - Vector(0,0,900),
                        filter = function(ent)
                            if not IsValid(ent) then return false end

                            if ent == ply then return false end

                            if ent:IsPlayer() then return false end
                            if ent:IsNPC() then return false end
                            if ent:IsNextBot() then return false end
                            if ent:GetClass() == "prop_ragdoll" then return false end

                            return true
                        end,
                        mask = MASK_SOLID_BRUSHONLY
                    })

                    local startPos = ent:GetNW2Vector("startPos_knuckles")
                    local endPos = ent:GetNW2Vector("endPos_knuckles")

                    local direction = (endPos - startPos):GetNormalized()
                    local tr = util.TraceLine({
                        start = ply:GetPos(),
                        endpos = ply:GetPos()+direction*30,
                        filter = function(ent)
                            if not IsValid(ent) then return false end

                            if ent == ply then return false end

                            if ent:IsPlayer() then return false end
                            if ent:IsNPC() then return false end
                            if ent:IsNextBot() then return false end
                            if ent:GetClass() == "prop_ragdoll" then return false end

                            return true
                        end,
                        mask = MASK_SOLID
                    })

                    local dist = 30
                    if groundTrace.Hit then
                        dist = groundTrace.HitPos:Distance(ply:GetPos())
                    end
                    
                    if dist < 25 or not tr.Hit or ent:GetNW2Float("rouge_latchbar") <= 0 or ent.Rouge_OM_regenserious then
                        if ply:IsPlayer() then
                            ply:SetMoveType(MOVETYPE_WALK)
                        else
                            ply:SetMoveType(0)
                        end
                        ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)

                        local angle = ( (tr.HitPos+ tr.HitNormal*5) - tr.HitPos ):Angle()
                        ent:SetNW2Angle("pill_assignedangle", angle)
                    end
                end
            else
                ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)
                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_WALK)
                else
                    ply:SetMoveType(0)
                end
                ent:SetNW2Float("Latches_knuckles_om", GetConVar("OUTCOMEMEMORIES_N_rouge_passive_latches_maximum"):GetFloat() )
            end

            if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then
                if not ent.SweepKick_charge_rouge_om_bool then
                    ent.SweepKick_charge_rouge_om_bool = true

                    AdvancedPillSound(
                        {
                            stringe = "OM/knuckles/punchstart.wav",
                            pitchPercent = 107,
                            volume = 0.6,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent:GetPuppet():SetNW2Float("Knuckles_glow_duration", CurTime()+0.5)
                    ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5)
                end
            else
                if ent.SweepKick_charge_rouge_om_bool then
                    ent.SweepKick_charge_rouge_om_bool = false
                    ent.AlternatePlaySolution = true
                    ent:PillAnim('SweepKick')
                    ent.AlternatePlaySolution = false

                    local seq = ent:GetPuppet():LookupSequence("SweepKick")
                    if ply:IsPlayer() then
                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                    end
                    ent:SetNW2Float("SweepKick_rouge_om", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                    ent:SetNW2Float("SweepKick_rouge_om_stun", CurTime() + ent:GetPuppet():SequenceDuration(seq) - 0.2)
                    
                    ent.Direction_sweepkick = ent:GetPuppet():GetForward()

                    AdvancedPillSound(
                        {
                            stringe = "OM/knuckles/swing.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:GetPuppet():SetNW2Float("Knuckles_glow_duration", CurTime()+0.5)
                    ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5)
                end
            end


            if ent:GetNW2Float("SweepKick_rouge_om") > CurTime() then
                ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.1)
                if ply:IsPlayer() then
                    ply:SetNW2Vector("OM_SetVelocity_Vector",ent.Direction_sweepkick * GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_speed"):GetFloat())
                else
                end
                ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                ply:SetNW2Float("OM_Damage_Reduction",0)
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)

                if ent:GetNW2Float("SweepKick_rouge_om_stun") > CurTime() then

                    if not ent.SweepKick_rouge_om_stun_bool then
                        ent.SweepKick_rouge_om_stun_bool = true
                    end

                    local jumpscare_entity = nil
                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 95)) do
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end


                            if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then continue end
                            local canstunstack = GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_canstunstack"):GetBool()

                            if Mutual_OMCanStun(ply, ent, ent2, canstunstack) then

                                jumpscare_entity = ent2

                                ent:SetNW2Float("SweepKick_rouge_om_stun", 0)
                                ent:SetNW2Float("SweepKick_rouge_om_cd", CurTime()+ GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_hit"):GetFloat() )
                                        
                                local ed = EffectData()
                                ed:SetOrigin(ent2:GetPos()+Vector(0,0,40))
                                util.Effect("Knuckles_punch_OM", ed)


                                Mutaul_OMStunCode(
                                    {
                                        ["ply"] = ply,
                                        ["ent"] = ent,
                                        ["target"] = ent2,
                                        ["StunDur"] = GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_basestun"):GetFloat(),
                                        ["stunfunction"] = function(shouldstundamage)

                                            if shouldstundamage then
                                                AdvancedPillSound(
                                                    {
                                                        stringe = "OM/blaze/blazekick.wav",
                                                        pitchPercent = 100,
                                                        volume = 1,
                                                        soundLevel = 87
                                                    },
                                                    ent
                                                )
                                                ent.SweepKick_rouge_om_stun_bool = false

                                                if GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_canragdoll"):GetBool() then
                                                    local last = CurTime() + 3
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
                                                                    phys:SetVelocityInstantaneous(dir*500)
                                                                end
                                                            
                                                            end
                                                        end
                                                    })
                                                end
                                            end

                                        end,
                                        ["checkoutprevention"] = true,
                                        ["shouldstack"] = canstunstack,
                                        ["Damage"] = GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_damageamouunt"):GetFloat(), -- ent:GetNW2Float(StunTimesName) < 2  and true or 30
                                        ["DamageType"] = DMG_CLUB
                                    }
                                )

                            end
                        end
                    end
                    if jumpscare_entity then
                        ent:SetNW2Float("rouge_latchbar", ent:GetNW2Float("rouge_latchbar") + GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_reward"):GetFloat() )
                    end
                else

                    ply:SetNW2Float("OM_Damage_Reduction",1)
                    if ent.SweepKick_rouge_om_stun_bool then
                        ent.SweepKick_rouge_om_stun_bool = false
                        ent:SetNW2Float("SweepKick_rouge_om_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_miss"):GetFloat() )
                    end
                end
            end

        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if button == KEY_SPACE then

                if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then
                    ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)

                    if ply:IsPlayer() then
                        ply:SetMoveType(MOVETYPE_WALK)
                    else
                        ply:SetMoveType(0)
                    end

                    ent.AlternatePlaySolution = true
                    ent:PillAnim('Jump2')
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

                    if ply:IsPlayer() then
                        ply:SetLocalVelocity(ply:GetAimVector()*GetConVar("OUTCOMEMEMORIES_N_rouge_launchy_power"):GetFloat() + Vector(0,0,60))
                    else
                        ply:SetVelocity(ply:GetAimVector()*GetConVar("OUTCOMEMEMORIES_N_rouge_launchy_power"):GetFloat()*1.5 + Vector(0,0,60))
                    end
                    
                    ent:SetNW2Float("rouge_latchbar", ent:GetNW2Float("rouge_latchbar") - GetConVar("OUTCOMEMEMORIES_N_rouge_passive_latch_jump_energydrain"):GetFloat() )
                    return
                end

                if ent:GetNW2Float("rouge_latchbar") - GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_energydrain"):GetFloat() > 0 then else return end
                if not ent:GetNW2Bool("HasDoubleJump") then return end
                if ent:GetNW2Float("UsedJumps") >= GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_maximum"):GetFloat() then return end
                if ent:GetNW2Float("JumpCD_rouge_om_cd") > CurTime() then return end
                if ply:IsOnGround() then return end
                ent:SetNW2Float("UsedJumps", ent:GetNW2Float("UsedJumps") + 1 )

                local currentplyVelocity = ply:GetVelocity()
                currentplyVelocity.z = GetConVar("OUTCOMEMEMORIES_N_rouge_jumppower"):GetFloat() - (GetConVar("OUTCOMEMEMORIES_N_rouge_jumppower"):GetFloat()*(30/400)) * ent:GetNW2Float("UsedJumps")
                currentplyVelocity.x = currentplyVelocity.x * 0.85
                currentplyVelocity.y = currentplyVelocity.y * 0.85
                if ply:IsPlayer() then
                    ply:SetLocalVelocity(currentplyVelocity)
                else
                    ply:SetVelocity(currentplyVelocity)
                end
                    

                ent.AlternatePlaySolution = true
                ent:PillAnim('Flap')
                ent.AlternatePlaySolution = false

                AdvancedPillSound(
                    {
                        stringe = "OM/rouge/flap.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                
                ent:SetNW2Float("rouge_latchbar", ent:GetNW2Float("rouge_latchbar") - GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_energydrain"):GetFloat() )
            end
            if button == ply:GetInfoNum("om_pills_action_rouge_ability_2_key", KEY_R) then
                if not GetConVar("OUTCOMEMEMORIES_N_rouge_canuse_sweepkick"):GetBool() then return end
                if ent:GetNW2Float("SweepKick_rouge_om_cd") > CurTime() then return end

                if ent:GetNW2Float("SweepKick_rouge_om_stun") > CurTime() then return end
                if ent:GetNW2Float("SweepKick_rouge_om") > CurTime() then return end
                if ent.SweepKick_rouge_om_stun_bool then return end
                if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then return end
                if ent.SweepKick_charge_rouge_om_bool then return end

                if ent:GetNW2Float("Aim_smokeBomb_rouge_om") > CurTime() then return end
                if ent:GetNW2Float("Aim_smokeBomb_throwduration_rouge_om") > CurTime() then return end

                ent:SetNW2Float("SweepKick_charge_rouge_om", CurTime()+ GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_chargeup"):GetFloat() )

                if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then
                    ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)

                    if ply:IsPlayer() then
                        ply:SetMoveType(MOVETYPE_WALK)
                    else
                        ply:SetMoveType(0)
                    end

                    ent.AlternatePlaySolution = true
                    ent:PillAnim('Jump2')
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

                    ply:SetLocalVelocity(ply:GetAimVector()*1500 + Vector(0,0,60))
                    return
                end
            end
            if button == ply:GetInfoNum("om_pills_action_rouge_ability_1_key", KEY_E) then
                if not GetConVar("OUTCOMEMEMORIES_N_rouge_canuse_smokebomb"):GetBool() then return end
                if ent:GetNW2Float("smokebomb_rougeom_cd") > CurTime() then return end

                if ent:GetNW2Float("SweepKick_rouge_om_stun") > CurTime() then return end
                if ent:GetNW2Float("SweepKick_rouge_om") > CurTime() then return end
                if ent.SweepKick_rouge_om_stun_bool then return end
                if ent:GetNW2Float("SweepKick_charge_rouge_om") > CurTime() then return end
                if ent.SweepKick_charge_rouge_om_bool then return end

                if ent:GetNW2Float("Aim_smokeBomb_rouge_om") > CurTime() then return end
                if ent:GetNW2Float("Aim_smokeBomb_throwduration_rouge_om") > CurTime() then return end

                ent:SetNW2Float('Aim_smokeBomb_rouge_om', CurTime() + 0.8)
                ent:SetNW2Float('Aim_smokeBomb_throwduration_rouge_om', CurTime() + 1.2)

                AdvancedPillSound(
                    {
                        stringe = "OM/Amy/HammerThrowReady.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                ent:GetPuppet():SetNW2Float("Amy_highlight_pill_blue", CurTime()+0.5/1.5)
                ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5/1.5)

                local puppet = ent:GetPuppet()
                local layeredAnim = puppet:AddGesture(ACT_BARNACLE_HIT, false)

                puppet:SetLayerWeight(layeredAnim, 1)
                puppet:SetLayerPriority(layeredAnim, 10)

                local playbackRate = 1
                puppet:SetLayerPlaybackRate(layeredAnim, playbackRate)

                timer.Simple(0.2,function()
                    if !IsValid(ent) then return end

                    local rock = ents.Create("ent_om_rouge_smokebomb_display")
                    if IsValid(rock) then
                        rock:SetPos(ent:GetPuppet():GetPos())
                        rock:SetPillUser(ent:GetPuppet())
                        rock:Spawn()

                        ent:DeleteOnRemove(rock)
                        ent:SetNW2Entity("ent_om_rouge_smokebomb_display", rock)
                        rock:GetPuppet():SetNW2Float("CounterOM_duration", CurTime()+0.35)

                        AdvancedPillSound(
                            {
                                stringe = {
                                    "player/footsteps/chainlink1.wav",
                                    "player/footsteps/chainlink2.wav",
                                    "player/footsteps/chainlink3.wav",
                                    "player/footsteps/chainlink4.wav"
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        AdvancedPillSound(
                            {
                                stringe = {
                                    "physics/metal/weapon_impact_soft1.wav",
                                    "physics/metal/weapon_impact_soft2.wav",
                                    "physics/metal/weapon_impact_soft3.wav"
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )

                    end
                    timer.Simple(0.5,function()
                        if !IsValid(ent) then return end
                        if !IsValid(rock) then return end
                        rock:Remove()

                        AdvancedPillSound(
                            {
                                stringe = "OM/Amy/HammerThrow.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )

                        AdvancedPillSound(
                            {   
                                stringe = "WeaponFrag.Throw",
                                pitchPercent = 100,
                                volume = 4,
                                soundLevel = 125
                            },
                            ent
                        )

                        local rock = ents.Create("prop_physics")

                        if IsValid(rock) then
                            rock:SetModel("models/items/grenadeammo.mdl")
                            rock:SetModelScale(2)

                            local rightBone = puppet:LookupBone("RightHand")

                            if rightBone then
                                local rightPos, rightangle = puppet:GetBonePosition(rightBone)
                                rightPos = rightPos + rightangle:Forward() * -3 + rightangle:Right() * -3 + rightangle:Up()

                                if rightPos then
                                    if SERVER then
                                        rock:SetPos(rightPos+puppet:GetForward()*30)
                                        rock:SetAngles(rightangle)
                                    end
                                end
                            end

                            local trailFoot1 = util.SpriteTrail(
                                rock,
                                0,
                                Color(255, 255, 255),
                                true,
                                9,
                                0.1,
                                0.2,
                                0.2,
                                "models/noodles/om/amy/white.vmt"
                            )

                            rock:Spawn()

                            ent:DeleteOnRemove(rock)

                            local self = rock
                            rock:AddCallback("PhysicsCollide", function(e, data)
                                if self.GasExploded then return end

                                timer.Simple(0.7,function()
                                    if !IsValid(rock) then return end
                                    rock:Remove()
                                end)

                                self.GasExploded = true
                                self:SetNW2Float("CounterOM_duration", CurTime()+0.35)

                                local effect = EffectData()
                                effect:SetOrigin(data.HitPos)
                                util.Effect("om_rouge_smokebombhold", effect, true, true)

                                local phys = rock:GetPhysicsObject()

                                if IsValid(phys) then
                                    phys:Wake()

                                    phys:SetVelocityInstantaneous(Vector(0, 0, 0))
                                    phys:AddAngleVelocity(-phys:GetAngleVelocity())
                                    phys:EnableGravity(false)
                                    phys:EnableDrag(false)

                                    phys:EnableMotion(false)
                                end


                                timer.Simple(0.2,function()
                                    if !IsValid(self) then return end

                                    local effect = EffectData()
                                    effect:SetOrigin(data.HitPos)
                                    util.Effect("om_rouge_flash", effect, true, true)

                                    AdvancedPillSound(
                                        {
                                            stringe = "BaseExplosionEffect.Sound",
                                            pitchPercent = 100,
                                            volume = 5,
                                            soundLevel = 125
                                        },
                                        self
                                    )

                                    AdvancedPillSound(
                                        {
                                            stringe = "OM/rouge/flashbomb.wav",
                                            pitchPercent = 100,
                                            volume = 0.1,
                                            soundLevel = 76
                                        },
                                        self
                                    )

                                    local currnetpos = self:GetPos()


                                    timer.Simple(0.2,function()
                                        if !IsValid(ent) then return end

                                        local hit = false
                                        for _, ent2 in pairs(ents.FindInSphere(currnetpos, 400)) do
                                            if ent2:GetClass() == "pill_puppet" then continue end
                                            if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                                                --if ent2 == ply then continue end
                                                --if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                                if not self:Visible(ent2) then return end

                                                if ( ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() ) then continue end
                                                if ent2:IsPlayer() then

                                                    net.Start("OM_FlashBangScreen")
                                                    net.Send(ent2)

                                                end
                                                hit = true
                                                ent2:SetNW2Float("OM_FlashBangScreen_rougeslowdown", CurTime() + GetConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_slowdownduration"):GetFloat() )

                                            
                                            end
                                        end
                                        if hit then

                                            ent:SetNW2Float("rouge_latchbar", ent:GetNW2Float("rouge_latchbar") + GetConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_reward"):GetFloat() )
                                        end
                                        rock:Remove()
                                    end)

                                end)
                            end)

                            local phys = rock:GetPhysicsObject()

                            if IsValid(phys) then
                                phys:Wake()
                                phys:SetVelocity(ply:GetAimVector() * 1800 + Vector(0,0,200))
                            end
                        end
                    end)
                end)

                timer.Simple(1,function()
                    if !IsValid(ent) then return end
                    puppet:RemoveLayer(puppet:FindGestureLayer(ACT_BARNACLE_HIT))
                    puppet:AddGesture(ACT_BARNACLE_PULL, false)
                    ent:SetNW2Float('smokebomb_rougeom_cd', CurTime() + GetConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_cd"):GetFloat() )
                end)

            end
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply,ent,button)
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)

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
        if SERVER then 
            ent.AlternatePlaySolution = true
            ent:PillAnim('Jump2')
            ent.AlternatePlaySolution = false
        end

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