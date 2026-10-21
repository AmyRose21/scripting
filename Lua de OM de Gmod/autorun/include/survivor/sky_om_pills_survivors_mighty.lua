
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
    ["Cover_Mighty_om"] = Material("icons/Cover_Mighty_om.png"),
    ["Charge_Mighty_om"] = Material("icons/Charge_Mighty_om.png"),
    ["BoulderMighty_om"] = Material("icons/BoulderMighty_om.png"),
}
pk_pills.register('pill_om_Mighty', {

    printName='Mighty',
    Outcomememories='Mighty',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/Mighty.mdl",
    --[[
    hull = Vector(20,20,60),
    duckBy = 14,
    ]]
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',

    OM_Mighty_Cheer = function(ply, ent)
        if SERVER then
            if GetConVar("OUTCOMEMORIES_N_mighty_Celebration"):GetBool() then
                local puppet = ent:GetPuppet()
                local layeredAnim = puppet:AddGesture(ACT_VM_HITRIGHT2, false)

                local current = 1
                puppet:SetLayerWeight(layeredAnim, current)
                puppet:SetLayerPriority(layeredAnim, 10)

                local duration = 80/60

                ent:SetNW2Float("OM_Mighty_Cheer_speedduration", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_CelebrationDuration"):GetFloat())

                timer.Simple(duration, function()
                    if !IsValid(ent) or !IsValid(puppet) then return end
                    puppet:RemoveLayer(puppet:FindGestureLayer(ACT_VM_HITRIGHT2))
                end)
            end
        end
    end,

    OM_UI_custom_end = function(ply, ent)

        ent.OverlyProtective_BadgeLerp = ent.OverlyProtective_BadgeLerp or 0
        local isNear = ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime()

        local target = isNear and 1 or 0
        ent.OverlyProtective_BadgeLerp = Lerp(FrameTime() * 8, ent.OverlyProtective_BadgeLerp, target)

        if ent.OverlyProtective_BadgeLerp >= 0.001 then
            local title, subtitle = "Your CDs are reduced", "Overly Protective"

            local iconSize = 64
            local padding = 12

            surface.SetFont("DermaDefaultBold")
            local titleW, titleH = surface.GetTextSize(title)

            local width = math.max(270, iconSize + titleW + padding * 4)
            local height = 92

            local targetX = ScrW() - width - 24
            local y = ScrH() * 0.72

            local hiddenX = ScrW() + 20

            local x = Lerp( ent.OverlyProtective_BadgeLerp, hiddenX, targetX )
            draw.RoundedBox( 2, x + 4, y + 5, width, height, Color(0, 0, 0, 150) )
            draw.RoundedBox( 2, x, y, width, height, Color(20, 23, 28, 245) )
            surface.SetDrawColor(255, 255, 255, 18)
            surface.DrawRect( x, y, width, 1 )

            local iconX = x + padding
            local iconY = y + (height - iconSize) / 2

            draw.RoundedBox( 2, iconX, iconY, iconSize, iconSize, Color(10, 12, 15, 255) )
            draw.RoundedBox( 2, iconX + 4, iconY + 4, iconSize - 8, iconSize - 8, Color(255, 55, 55, 25))
            draw.SimpleText( "◆", "DermaLarge", iconX + iconSize / 2, iconY + iconSize / 2, Color(255, 70, 70), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( subtitle, "DermaDefault", iconX + iconSize + padding, y + 19, Color(170, 175, 185), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

            draw.SimpleText( title, "DermaDefaultBold", iconX + iconSize + padding, y + 46, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

            surface.SetDrawColor(255, 55, 55, 180)
            surface.DrawRect( x, y + height - 3,width * 0.32, 3 )
        end
    end,

    ShouldRoll_om = function(e, ply, ent)
        if ent:GetNW2Float("ram_charge_duration") > CurTime() then return end
        return true
    end,

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Cover_Mighty_om"]
            end,
            name = function(uselessvar,ply,ent)
                return "Take Cover"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_E
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("om_Mighty_takecover_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 2
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.1125, yaxis = 0+ iconsize*0.1, xsize = 0+ iconsize*-0.1, ysize = 0+ iconsize*-0.1}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Charge_Mighty_om"]
            end,
            name = function(uselessvar,ply,ent)
                return "Ram"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_R
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("om_Mighty_ram_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("om_Mighty_ram_dur")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.1, yaxis = 0+ iconsize*0.06, xsize = 0+ iconsize*-0.1, ysize = 0+ iconsize*-0.1}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["BoulderMighty_om"]
            end,
            name = function(uselessvar,ply,ent)
                return "Boulder Throw"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_T
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("om_Mighty_boulder_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("om_Mighty_boulder_dur")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.125, yaxis = 0+ iconsize*0.1, xsize = 0+ iconsize*-0.2, ysize = 0+ iconsize*-0.2}
            end,
            survivor = true,
            font = "CreditsText",
        },
    },
  
    Outcomememories_stats = {
        moveSpeed = {
            
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_mighty_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_mighty_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_mighty_walk"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_mighty_jumppower"):GetFloat()
                end
            end,
            Peelout= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_mighty_charge"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_mighty_jumpcd"):GetFloat()
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_mighty_rollingPower"):GetFloat()
                end
            end,
        },
    },

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            Jump2='jump',
            RamChargeUp="RamChargeUp",
            BoulderSpawn="BoulderSpawn",
            BoulderThrow="BoulderThrow",
        },

        ShouldMoveRotate={
            BoulderSpawn= function(ent) 
                return "shiftlock"
            end,
            RamChargeUp= function(ent) 
                return "shiftlock"
            end,
            BoulderThrow= function(ent) 
                return "shiftlock"
            end,
            idle= function(ent) 
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return "shiftlock" end
                return 'notanything' 
            end,
            run= function(ent) 
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return "shiftlock" end
                return 'notshftlock'
            end,
            walk= function(ent) 
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return "shiftlock" end
                return 'notshftlock'
            end,
            jump= function(ent) 
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return "shiftlock" end
                return 'notshftlock'
            end,
            fall= function(ent) 
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return "shiftlock" end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            jump= function(ent)
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("om_Mighty_takecover_toggle") then return "Indource_walk" end
                if ent:GetNW2Float("ram_charge_duration") > CurTime() or ent:GetNW2Bool("Ram_Decay") then return "ram" end
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return "walkhold" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "WalkLowHealth"
                end 
            end,
            idle= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("om_Mighty_takecover_toggle") then return "Endource_Idle" end
                if ent:GetNW2Float("ram_charge_duration") > CurTime() or ent:GetNW2Bool("Ram_Decay") then return "ram" end
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return "idlehold" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "IdleLowHealth"
                end 
            end,
            fall= function(ent) 
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
            end,
            run= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("om_Mighty_takecover_toggle") then return "Indource_walk" end
                if ent:GetNW2Float("ram_charge_duration") > CurTime() or ent:GetNW2Bool("Ram_Decay") then return "ram" end
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return "walkhold" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "RunLowHealth"
                end 
            end,
        },
        animrates = {
            idle = function(ent)
                return 1
            end,
            walk = function(ent)
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("ram_charge_duration") > CurTime() then return ply:GetVelocity():Length()/1450*1.7 end
                return 1.15
            end,

            run = function(ent)
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("ram_charge_duration") > CurTime() then return ply:GetVelocity():Length()/1450*1.7 end

                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return 1.25 end
                
                return 1.15
            end,

            fall = function(ent)
                return 1
            end,

            jump = function(ent)
                return 1
            end,
        }
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

        ent.om_Mighty_takecover_toggle_lerp = ent.om_Mighty_takecover_toggle_lerp or 0 
        ent.ram_charge_duration_lerp = ent.ram_charge_duration_lerp or 0 
        ent.ram_chargeup_duration_lerp = ent.ram_chargeup_duration_lerp or 0 
        ent.ram_BoulderSpawn_duration_lerp = ent.ram_BoulderSpawn_duration_lerp or 0
        ent.ram_BoulderSpawn_hasrock_lerp = ent.ram_BoulderSpawn_hasrock_lerp or 0  

        if ply:GetInfoNum("om_pills_action_camera_mighty", 1) == 1 then
            if ent:GetNW2Bool("om_Mighty_takecover_toggle") then
                ent.om_Mighty_takecover_toggle_lerp = Lerp(FrameTime()*2, ent.om_Mighty_takecover_toggle_lerp, 1)
            else
                ent.om_Mighty_takecover_toggle_lerp = Lerp(FrameTime()*2, ent.om_Mighty_takecover_toggle_lerp, 0)
            end

            if ent:GetNW2Float("ram_charge_duration") > CurTime() then
                ent.ram_charge_duration_lerp = Lerp(FrameTime()*4, ent.ram_charge_duration_lerp, 1)
            else
                ent.ram_charge_duration_lerp = Lerp(FrameTime()*4, ent.ram_charge_duration_lerp, 0)
            end

            if ent:GetNW2Float("ram_chargeup_duration") > CurTime() then
                ent.ram_chargeup_duration_lerp = Lerp(FrameTime()*3, ent.ram_chargeup_duration_lerp, 1)
            else
                ent.ram_chargeup_duration_lerp = Lerp(FrameTime()*3, ent.ram_chargeup_duration_lerp, 0)
            end

            if ent:GetNW2Float("ram_BoulderSpawn_duration") > CurTime() then
                ent.ram_BoulderSpawn_duration_lerp = Lerp(FrameTime()*2, ent.ram_BoulderSpawn_duration_lerp, 1)
            else
                ent.ram_BoulderSpawn_duration_lerp = Lerp(FrameTime()*2, ent.ram_BoulderSpawn_duration_lerp, 0)
            end

            if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then
                ent.ram_BoulderSpawn_hasrock_lerp = Lerp(FrameTime()*2, ent.ram_BoulderSpawn_hasrock_lerp, 1)
            else
                ent.ram_BoulderSpawn_hasrock_lerp = Lerp(FrameTime()*2, ent.ram_BoulderSpawn_hasrock_lerp, 0)
            end
        else
            ent.om_Mighty_takecover_toggle_lerp = Lerp(FrameTime()*3, ent.om_Mighty_takecover_toggle_lerp, 0)
            ent.ram_charge_duration_lerp = Lerp(FrameTime()*3, ent.ram_charge_duration_lerp, 0)
            ent.ram_chargeup_duration_lerp = Lerp(FrameTime()*3, ent.ram_chargeup_duration_lerp, 0)
            ent.ram_BoulderSpawn_duration_lerp = Lerp(FrameTime()*3, ent.ram_BoulderSpawn_duration_lerp, 0)
            ent.ram_BoulderSpawn_hasrock_lerp = Lerp(FrameTime()*3, ent.ram_BoulderSpawn_hasrock_lerp, 0)
        end

        basetable["fov"] = basetable["fov"] - ent.om_Mighty_takecover_toggle_lerp * 20 + ent.ram_charge_duration_lerp * 20 - ent.ram_chargeup_duration_lerp * 20 - ent.ram_BoulderSpawn_duration_lerp * 40 + ent.ram_BoulderSpawn_hasrock_lerp * 10
        basetable["dist"] = basetable["dist"] + ent.om_Mighty_takecover_toggle_lerp * 15 + ent.ram_charge_duration_lerp * 20 - ent.ram_chargeup_duration_lerp * 20 + ent.ram_BoulderSpawn_duration_lerp * 15 - ent.ram_BoulderSpawn_hasrock_lerp * 20
        basetable["startoffset"] =  basetable["startoffset"] + Vector(ent.ram_BoulderSpawn_hasrock_lerp * 20 - ent.ram_BoulderSpawn_duration_lerp * 20, 0,0)

        return basetable
    end,
    
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },
        
    --canAim=function(ply,ent) return ent.active end,     

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if event == "Step" then
            --[[
            if ent:GetNW2Float("ram_charge_duration") > CurTime() or ent:GetNW2Bool("Ram_Decay") then

                AdvancedPillSound(
                    {
                        stringe = "OM/kolossos/kolossos footstep.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end
            ]]

            StepSFX_OM(ply,ent)


        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
        


        initializetable2["player"].ColorRGB_B_1_OM = Color(0,35,255, 255)
        if SERVER then
            local name = initializetable2["entity"]:EntIndex().. " ".. "OM_CheckSound"
            hook.Add("EntityEmitSound", name, function(data)
                local ent = initializetable2["entity"]
                if !IsValid(ent) then hook.Remove("EntityEmitSound",name) end
                if not ent.Mighty_nearbytable then return end

                if data.Entity.GetPillUser then data.Entity = data.Entity:GetPillUser() end

                if ent.Mighty_nearbytable[data.Entity] then
                    if ent.Mighty_nearbytable[data.Entity] >= CurTime() then else return end
                    if data.SoundName == "OM/sonic/DropdashDrill.wav" then
                        AdvancedPillSound(
                            {
                                stringe = "OM/Mighty/sonicdropdas.wav",
                                pitchPercent = 100,
                                volume = 2,
                                soundLevel = 100
                            },
                            initializetable2["entity"]
                        )
                    end
                end
                
            end)

            initializetable2["entity"]:SetNW2Float("OM_Damage_Reduction",1)

            local health = GetConVar("OUTCOMEMEMORIES_N_mighty_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)

            initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
            initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)


            initializetable2["player"].CustomFunctionForDowned_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ply = initializetable2["player"]
                    local ent = initializetable2["entity"]
                    ent:SetNW2Float("ram_chargeup_duration", 0)


                    if ent:GetNW2Bool("om_Mighty_takecover_toggle") then
                        ent:SetNW2Bool("om_Mighty_takecover_toggle", false)
                        ent:SetNW2Float("om_Mighty_takecover_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_cancel"):GetFloat())
                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/Mighty/MightyShieldPop.wav",
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        local fx = EffectData()
                        --fx:SetOrigin(ent:GetPos()+Vector(0,0,30))
                        fx:SetEntity(ent:GetPuppet())

                        util.Effect("mighty_shield_break", fx, true, true)
                    end


                    ent:SetNW2Float("ram_charge_duration", 0)
                    ent:SetNW2Float("ram_chargeup_duration", 0)

                    ent.formTable.attack.func(ply, ent)

                    if not ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then
                        if GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):GetBool() then
                            AdvancedPillSound(
                                {
                                    stringe = "OM/Mighty/EnoughAlready.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                        end
                    end
                end
            end
            initializetable2["player"].OM_Stun_Blockfunction = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end
            initializetable2["player"].OM_Stun_Blockfunction = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end

            initializetable2["player"].OM_DamageBeforeCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                local ent = initializetable2["entity"]
                local ply = initializetable2["player"]
                    
                if !IsValid(initializetable2["entity"]) then return end
                if ent:GetNW2Float("ram_chargeup_duration") > CurTime() then
                    ent:SetNW2Float("ram_chargeup_duration", 0)
                    ent.ram_chargeup_bool = false
                    ent:SetNW2Float("om_Mighty_ram_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd_hit"):GetFloat())
                end

                if ent:GetNW2Bool("om_Mighty_takecover_toggle") then
                    local multiplyer = GetConVar("OUTCOMEMORIES_N_mighty_cover_cdgodownmultiplyer"):GetFloat()/100
                    ent:SetNW2Float("om_Mighty_ram_cd", (ent:GetNW2Float("om_Mighty_boulder_cd") -CurTime())*0.75+ CurTime() )
                    ent:SetNW2Float("om_Mighty_boulder_cd", (ent:GetNW2Float("om_Mighty_boulder_cd") - CurTime())*0.75+ CurTime() )
                end
                local damager = dmg:GetAttacker()

                if initializetable2["entity"]:GetNW2Float("CounterOM_duration") > CurTime() then
                    if damageamount > 0 then else return end
                    if not ( dmg:IsDamageType(DMG_CLUB) or dmg:IsDamageType(DMG_SLASH) ) then return false end
                    if IsValid(damager) then
                        if entityfall == ply and damager ~= ply  then
                            if damager.CustomFunctionParryAbility_OM then
                                damager:CustomFunctionParryAbility_OM()
                            end
                            dmg:SetDamage(0)
                            dmg:SetDamageType(DMG_GENERIC)

                            ent:GetPuppet():SetNW2Float("mighty_glowwhite", 0)
                            ent:SetNW2Float("CounterOM_duration", 0)

                            ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.5)
                            damager:SetNW2Float('sonic_glow_duration',CurTime()+0.5)

                            local dir = (( damager:GetPos() + Vector(0,0,30) ) - entityfall:GetPos()):GetNormalized()
                            if damager:IsPlayer() then damager:SetLocalVelocity(dir*750) else damager:SetVelocity(dir*750) end
                            if damager:IsPlayer() then
                                damager:SetPos(damager:GetPos()+Vector(0,0,20))
                            else
                                damager:SetPos(damager:GetPos()+Vector(0,0,40))
                            end

                            local dir = (( entityfall:GetPos() + Vector(0,0,50) ) - damager:GetPos()):GetNormalized()
                            if entityfall:IsPlayer() then entityfall:SetLocalVelocity(dir*1350) else entityfall:SetVelocity(dir*1350) end
                            if entityfall:IsPlayer() then
                                entityfall:SetPos(entityfall:GetPos()+Vector(0,0,20))
                            else
                                entityfall:SetPos(entityfall:GetPos()+Vector(0,0,40))
                            end

                            ent:SetNW2Bool("om_Mighty_takecover_toggle", false) 


                            if ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime() then 
                                ent:SetNW2Float("om_Mighty_takecover_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_pary"):GetFloat()*0.75) 
                            else
                                ent:SetNW2Float("om_Mighty_takecover_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_pary"):GetFloat())
                            end

                            return true
                        end
                    end
                else
                    if not ent.hurtcdsound_mighty_om then ent.hurtcdsound_mighty_om = 0 end
                    if ent.hurtcdsound_mighty_om < CurTime() then
                        ent.hurtcdsound_mighty_om = CurTime() + 1
                        if GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):GetBool() then
                            AdvancedPillSound(
                                {
                                    stringe = {
                                        "OM/Mighty/Hurt1.wav",
                                        "OM/Mighty/Hurt2.wav",
                                        "OM/Mighty/Hurt3.wav",
                                        "OM/Mighty/Hurt5.wav"
                                    },
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                        end
                    end
                end

                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then
                    if IsValid(ent:GetNW2Entity("ent_om_mighty_rock_display")) then
                        ent:SetNW2Bool("ram_BoulderSpawn_hasrock", false)

                        if ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime() then ent:SetNW2Float("om_Mighty_boulder_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_cd"):GetFloat()*0.75) else
                            ent:SetNW2Float("om_Mighty_boulder_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_cd"):GetFloat()) end
                        ent:SetNW2Float("om_Mighty_boulder_dur", ent:GetNW2Float("om_Mighty_boulder_cd")-CurTime())



                        AdvancedPillSound({
                            stringe = "OM/kolossos/kol charge start ground rumble.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 76
                        }, ent)

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
                                                
                        ent:GetNW2Entity("ent_om_mighty_rock_display"):Remove()

                        timer.Simple(0.05,function()
                            if !IsValid(ent) then return end

                            if !IsValid(ply:GetNWEntity("OM_ragdollentity")) and !IsValid(ent:GetNWEntity("OM_ragdollentity")) then
                                local dir = (( entityfall:GetPos() + Vector(0,0,0) ) - damager:GetPos()):GetNormalized()
                                local last = CurTime() + 1.3
                                local flung = false
                                local enemyragdoll = CreateRagdolLCharacter_OM({
                                    target = ply,
                                    host = ent,

                                    shouldremove = function(createfakeragdoll)
                                        if not IsValid(createfakeragdoll) then return true end
                                        if not IsValid(ent) then return true end

                                        if last < CurTime() then return true end

                                        return false
                                    end,

                                    shoulddocustomfunction = function(createfakeragdoll)
                                        if not IsValid(createfakeragdoll) then return end
                                        if not IsValid(ent) then return end
                                        if flung then return end
                                        flung = true
                                        for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                            local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                            if IsValid(phys) then
                                                phys:Wake()
                                                phys:SetVelocityInstantaneous(dir*1500)
                                            end
                                        
                                        end
                                    end
                                })
                            end
                        end)
                    end
                end
            end

        end
        initializetable2["player"]:SetNW2Bool("OM_character", true)
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetNW2Float("OM_NoMovement_noodles", CurTime())
            initializetable2["player"]:SetNW2Float("OM_NoMovement_noodles_jump", CurTime())
        end
    end,


    speedhandeler_om = {
        modifiers = {
            ["Endource"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Bool("om_Mighty_takecover_toggle") then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.25 - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.25 - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.25 - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
            ["rock"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.25 - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*3.7- ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.25 - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
            ["PeelOut"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("ram_charge_duration") > CurTime() or ent:GetNW2Bool("Ram_Decay") then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.Peelout()-ent:GetNW2Float("om_minusforwardspeed_charging") - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1 - ent:GetNW2Float("om_minusforwardspeed")
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Peelout()-ent:GetNW2Float("om_minusforwardspeed_charging") - ent.formTable.Outcomememories_stats.moveSpeed.run() *1 - ent:GetNW2Float("om_minusforwardspeed")
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.Peelout()-ent:GetNW2Float("om_minusforwardspeed_charging") - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1 - ent:GetNW2Float("om_minusforwardspeed")
                end

                return sendtotable
            end,
            ["Speedup"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("OM_Mighty_Cheer_speedduration") > CurTime() then
                    local multiplyer = GetConVar("OUTCOMEMORIES_N_mighty_CelebrationSpeedmultiplyer"):GetFloat()
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*multiplyer - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run()*multiplyer - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.ducked()*multiplyer - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
            ["Slowdebuff"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if GetConVar("OUTCOMEMORIES_N_mighty_ShouldSlowdebuff"):GetBool() then
                    if ent:GetNW2Bool("om_Mighty_takecover_toggle") then return sendtotable end
                    if ent:GetNW2Float("ram_charge_duration") > CurTime() or ent:GetNW2Bool("Ram_Decay") then return sendtotable end
                    if ent:GetNW2Bool("OM_Mighty_Cheer_speedduration") then return sendtotable end
                    if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return sendtotable end

                    local slowperability = 1
                    local slowdownper = GetConVar("OUTCOMEMORIES_N_mighty_Slowdebuffperability"):GetFloat()

                    if ent:GetNW2Float("om_Mighty_takecover_cd") > CurTime() then slowperability = slowperability * slowdownper end
                    if ent:GetNW2Float("om_Mighty_ram_cd") > CurTime() then slowperability = slowperability * slowdownper end
                    if ent:GetNW2Float("om_Mighty_boulder_cd") > CurTime() then slowperability = slowperability * slowdownper end

                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*slowperability - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run()*slowperability- ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.ducked()*slowperability - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
        }
    },

    think_noodles_om_pill = function(ply, ent)
        if SERVER then

            ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_mighty_Resistance"):GetFloat()/100)
            if not ent:GetNW2Bool("om_Mighty_takecover_toggle") then
                ply:SetNW2Float("OM_Damage_Reduction",GetConVar("OUTCOMEMEMORIES_N_mighty_passivereduction"):GetFloat()/100)
            else
                ply:SetNW2Float("OM_Damage_Reduction",GetConVar("OUTCOMEMORIES_N_mighty_cover_reduction"):GetFloat()/100)
            end
            if not GetConVar("OUTCOMEMORIES_N_mighty_cover_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
            end
            if not GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
            end
            if not GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility3_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility3_OM", false)
            end

            OM_PILL_speedThink(ply, ent)

            if ent:GetNW2Float("ram_chargeup_duration") > CurTime() then
                if not ent.ram_chargeup_bool then
                    ent.ram_chargeup_bool = true
                end
            else
                if ent.ram_chargeup_bool then
                    ent.ram_chargeup_bool = false

                    ent:SetNW2Float("ram_charge_duration", CurTime()+6)
                    ent:SetNW2Float("om_minusforwardspeed", 0)

                    ent:SetNW2Bool("Ram_Decay", false)

                    AdvancedPillSound({
                        stringe = "OM/mighty/MightyBoostForward.wav",
                        pitchPercent = 100,
                        volume = 3,
                        soundLevel = 125
                    }, ent)

                    AdvancedPillSound(
                        {
                            stringe = {
                                "OM/Mighty/sonicboomcharge.mp3",
                            },
                            pitchPercent = 100,
                            volume = 0.75,
                            soundLevel = 90
                        },
                        ent
                    )
                    ent:GetPuppet():SetNW2Float("Mighty_chargeShoot_glow_duration", CurTime()+0.5*0.75)
                    ent:SetNW2Float("om_minusforwardspeed_charging", 0)


                end
            end

            if ent:GetNW2Float("ram_charge_duration") > CurTime() or ent:GetNW2Bool("Ram_Decay") then
                if not ent.ram_charge_bool then
                    ent.ram_charge_bool = true
                end
                ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                ply:SetNW2Float("OM_Damage_Reduction",0)
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)

                ply:SetNW2Float("OM_MoveForwardSpeed", ent.formTable.Outcomememories_stats.moveSpeed.Peelout()-ent:GetNW2Float("om_minusforwardspeed_charging"))
                ply:SetNW2Float("OM_MoveForward", CurTime() + 0.2)

                if ent:GetNW2Bool("Ram_Decay") then
                    ent:SetNW2Float("om_minusforwardspeed_charging", -300 )
                    ent:SetNW2Float("om_minusforwardspeed", ent:GetNW2Float("om_minusforwardspeed") + 6 )
                    if ent:GetNW2Float("om_minusforwardspeed") > 1000 then
                        ent:SetNW2Bool("Ram_Decay", false)

                        if GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):GetBool() then
                            if ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime() then
                                AdvancedPillSound(
                                    {
                                        stringe = {
                                            "OM/Mighty/ShowOffAfterRam1.wav",
                                            "OM/Mighty/ShowOffAfterRam2.wav",
                                            "OM/Mighty/ShowOffAfterRam3.wav",
                                            "OM/Mighty/ShowOffAfterRam4.wav"
                                        },
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                            else
                                AdvancedPillSound(
                                    {
                                        stringe = {
                                            "OM/Mighty/EscapeKiller1.wav",
                                            "OM/Mighty/EscapeKiller2.wav"
                                        },
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                            end
                        end
                    end
                else
                    ent:SetNW2Float("om_minusforwardspeed_charging", ent:GetNW2Float("om_minusforwardspeed_charging") + 2 )
                    
                end


                if ent:GetNW2Float("ram_charge_duration") > CurTime() then


                    local hullSize = Vector(16, 16, 34)
                    local startPos = ply:GetPos() + Vector(0,0,35)
                    local endPos = startPos + ply:GetForward() * 25

                    local tr = util.TraceHull({
                        start = startPos,
                        endpos = endPos,
                        filter = ply,
                        mask = MASK_SOLID,
                        mins = -hullSize * 0.5,
                        maxs = hullSize * 0.5
                    })

                    local function latching()

                        local stairCheck = util.TraceLine({
                            start = tr.HitPos + tr.HitNormal * 4 + Vector(0, 0, 72),
                            endpos = tr.HitPos + tr.HitNormal * 4,
                            filter = ply,
                            mask = MASK_SOLID_BRUSHONLY
                        })

                        if stairCheck.Hit and stairCheck.HitNormal.z > 0.7 then
                            return
                        end

                        local groundTrace = util.TraceLine({
                            start = tr.HitPos + tr.HitNormal * 2,
                            endpos = tr.HitPos + tr.HitNormal * 2 - Vector(0, 0, 256),
                            filter = ply,
                            mask = MASK_SOLID_BRUSHONLY
                        })

                        local distance = tr.HitPos.z - groundTrace.HitPos.z

                        if distance >= 25 then
                            local normal = tr.HitNormal
                            if math.abs(normal.z) < 0.5 then
                                ent:SetNW2Bool("Ram_Decay", false)
                                ent:SetNW2Float("ram_charge_duration",0)

                                ent:GetPuppet():SetNW2Float("MetalSonicbump_highlight", CurTime()+0.5)
                                ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5)

                                local startPos = ply:GetPos() + Vector(0,0,30)
                                local endPos = startPos + ply:GetForward() * 30
                                if ply:IsPlayer() then
                                    ply:SetPos(ply:GetPos()+Vector(0,0,10))
                                    local dir = (startPos - (endPos-Vector(0,0,10))):GetNormalized()
                                    ply:SetVelocity(dir * 200)
                                    ply:SetLocalVelocity(dir * 200)
                                else
                                    ply:SetPos(ply:GetPos()+Vector(0,0,30))
                                    local dir = (startPos - (endPos-Vector(0,0,30))):GetNormalized()
                                    ply:SetVelocity(dir * 200)
                                    ply:SetLocalVelocity(dir * 200)
                                end
                                ply:SetNW2Float("OM_NoMovement_noodles", 1.4 + CurTime())
                                ent:SetNW2Float("OM_healidle", 1 + CurTime())

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/metal/WallBump.wav",
                                        pitchPercent = 100,
                                        volume = 0.75,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                AdvancedPillSound({
                                    stringe = "OM/kolossos/Kol wall bump.wav",
                                    pitchPercent = 100,
                                    volume = 0.4,
                                    soundLevel = 76
                                }, ent)

                                AdvancedPillSound({
                                    stringe = "OM/kolossos/Sound.mp3",
                                    pitchPercent = 100,
                                    volume = 0.75,
                                    soundLevel = 100
                                }, ent)

                                local ed = EffectData()
                                ed:SetOrigin(tr.HitPos)
                                ed:SetNormal(tr.HitNormal)
                                ed:SetScale(1)
                                util.Effect("Metal_Charge_SMASHWALL", ed)  


                                if GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):GetBool() then
                                    AdvancedPillSound(
                                        {
                                            stringe = {
                                                "OM/Mighty/Hurt1.wav",
                                                "OM/Mighty/Hurt2.wav",
                                                "OM/Mighty/Hurt3.wav",
                                                "OM/Mighty/Hurt5.wav"
                                            },
                                            pitchPercent = 100,
                                            volume = 2,
                                            soundLevel = 87
                                        },
                                        ent
                                    )
                                end

                                if !IsValid(ply:GetNWEntity("OM_ragdollentity")) and !IsValid(ent:GetNWEntity("OM_ragdollentity")) then
                                    local last = CurTime() + 2
                                    local flung = false
                                    local enemyragdoll = CreateRagdolLCharacter_OM({
                                        target = ply,
                                        host = ent,

                                        shouldremove = function(createfakeragdoll)
                                            if not IsValid(createfakeragdoll) then return true end
                                            if not IsValid(ent) then return true end

                                            if last < CurTime() then return true end

                                            return false
                                        end,

                                        shoulddocustomfunction = function(createfakeragdoll)
                                            if not IsValid(createfakeragdoll) then return end
                                            if not IsValid(ent) then return end
                                            if flung then return end
                                            flung = true
                                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                                if IsValid(phys) then
                                                    phys:Wake()
                                                    phys:SetVelocityInstantaneous(normal*400)
                                                end
                                            
                                            end
                                        end
                                    })
                                end

                                
                            end
                        end
                    end
                    if tr.Hit then
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


                    local jumpscare_entity = nil
                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 95)) do
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                            local canstunstack = GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_stunstacking"):GetBool()


                            if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then continue end

                            if Mutual_OMCanStun(ply, ent, ent2, canstunstack) then
                                if IsValid(ent2:GetNWEntity("OM_ragdollentity")) then
                                    continue
                                end
                                
                                ent:GetPuppet():SetNW2Float("Mighty_chargeShoot_glow_duration", CurTime()+0.5*0.75)
                                ent2:SetNW2Float("Mighty_chargeShoot_glow_duration", CurTime()+0.5*0.75)

                                Mutaul_OMStunCode(
                                    {
                                        ["ply"] = ply,
                                        ["ent"] = ent,
                                        ["target"] = ent2,
                                        ["StunDur"] = GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_stunduration"):GetFloat(),
                                        ["stunfunction"] = function(shouldstundamage)

                                            if shouldstundamage then



                                                if not ent.ramcdsound_mighty_om then ent.ramcdsound_mighty_om = 0 end
                                                if GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):GetBool() then
                                                    if ent.ramcdsound_mighty_om < CurTime() then
                                                        ent.ramcdsound_mighty_om = CurTime() + 1
                                                        if math.random(1,3) == 1 then
                                                            AdvancedPillSound(
                                                                {
                                                                    stringe = {
                                                                        "OM/Mighty/RamAlt_1_1.wav",
                                                                        "OM/Mighty/RamAlt_1_2.wav",
                                                                        "OM/Mighty/RamAlt_1_3.wav"
                                                                    },
                                                                    pitchPercent = 100,
                                                                    volume = 1,
                                                                    soundLevel = 87
                                                                },
                                                                ent
                                                            )
                                                        else
                                                            AdvancedPillSound(
                                                                {
                                                                    stringe = {
                                                                        "OM/Mighty/Ram1.wav",
                                                                        "OM/Mighty/Ram2.wav",
                                                                        "OM/Mighty/Ram3.wav",
                                                                        "OM/Mighty/Ram4.wav",
                                                                        "OM/Mighty/Ram5.wav",
                                                                        "OM/Mighty/Ram6.wav",
                                                                        "OM/Mighty/Ram7.wav"
                                                                    },
                                                                    pitchPercent = 100,
                                                                    volume = 1,
                                                                    soundLevel = 87
                                                                },
                                                                ent
                                                            )
                                                        end
                                                    end
                                                end

                                                ent:SetNW2Bool("Ram_Decay", true)
                                                ent.Ram_hashit = true
                                                ent:SetNW2Float("ram_charge_duration",0)

                                                ent:SetNW2Float("om_minusforwardspeed_charging", -200)
                                                        
                                                local ed = EffectData()
                                                ed:SetOrigin(ent2:GetPos()+Vector(0,0,40))
                                                util.Effect("Knuckles_punch_OM", ed)

                                                AdvancedPillSound({
                                                    stringe = "OM/kolossos/kol charge start ground rumble.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 76
                                                }, ent)

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
                                                
                                                if GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_canragdoll"):GetBool() then
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
                                                                    phys:SetVelocityInstantaneous(dir*1750)
                                                                end
                                                            
                                                            end
                                                        end
                                                    })
                                                end
                                            end

                                        end,
                                        ["checkoutprevention"] = true,
                                        ["shouldstack"] = canstunstack,
                                        ["Damage"] = GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_stundamage"):GetFloat(), -- ent:GetNW2Float(StunTimesName) < 2  and true or 30
                                        ["DamageType"] = DMG_CLUB
                                    }
                                )

                            end
                        end
                    end
                end
            else

                if ent.ram_charge_bool then
                    ent.ram_charge_bool = false

                    if ent:GetNW2Float("om_Mighty_boulder_cd") > CurTime() then
                        ent:SetNW2Float("om_Mighty_boulder_cd", ent:GetNW2Float("om_Mighty_boulder_cd") + GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_bouldercdadd"):GetFloat())
                    else
                        ent:SetNW2Float("om_Mighty_boulder_cd", CurTime() + GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_bouldercdadd"):GetFloat())
                    end
                    local amount = GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd"):GetFloat()

                    if ent.Ram_hashit then
                        ent.Ram_hashit = false
                        amount = GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd_stunhit"):GetFloat()

                        timer.Simple(0.5,function()
                            if !IsValid(ent) then return end
                            ent.formTable.OM_Mighty_Cheer(ply,ent)
                        end)
                    end

                    if ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime() then ent:SetNW2Float("om_Mighty_ram_cd", CurTime()+amount*0.75 ) else ent:SetNW2Float("om_Mighty_ram_cd", CurTime()+amount ) end
                    ent:SetNW2Float("om_Mighty_ram_dur", ent:GetNW2Float("om_Mighty_ram_cd")-CurTime() )--

                    AdvancedPillSound(
                        {
                            stringe = {
                                "OM/kolossos/kol wall bump.wav",
                            },
                            pitchPercent = 100,
                            volume = 0.75,
                            soundLevel = 90
                        },
                        ent
                    )
                end
            end

            ent.Mighty_nearbytable = ent.Mighty_nearbytable or {}

            local should = false
            if not (ent:GetNW2Bool("ram_BoulderSpawn_hasrock") or ent:GetNW2Bool("Ram_Decay") or ent:GetNW2Float("ram_charge_duration") > CurTime() or ent:GetNW2Float("ram_chargeup_duration") > CurTime() ) then
                local greetVector = false
                local greetRay = false
                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 600)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2 == ent:GetNW2Entity("DrGBasePossessor") then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if (not ent2:GetNW2Bool("OM_character") or GetConVar("PVPStun_OM"):GetBool()) then
                        else
                            should = true
                            ent.Mighty_nearbytable[ent2] = CurTime()+0.1
                            if ent2.pk_pill_ent and IsValid(ent2.pk_pill_ent) then
                                ent2.pk_pill_ent.formTable.printName = "Vector"
                                greetVector = true
                            end
                            if ent2.pk_pill_ent and IsValid(ent2.pk_pill_ent) then
                                ent2.pk_pill_ent.formTable.printName = "Ray"
                                greetRay = true
                            end
                        end
                    end
                end
                if should and ent.Alreadsaidline then
                    ent:SetNW2Bool("Mighty_IsNearSurvivor_OM", CurTime()+0.1)
                end
                
                if math.random(1,1750) == 1 and not ent.Alreadsaidline then
                    if ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime() then
                        ent.Alreadsaidline = true
                        if GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):GetBool() then
                            AdvancedPillSound(
                                {
                                    stringe = {
                                        "OM/Mighty/RandomRareLine_1.wav",
                                        "OM/Mighty/ThisPlaceIsGreat.wav",
                                        "OM/Mighty/Everybodyready.wav",
                                    },
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 86
                                },
                                ent
                            )
                        end
                    end
                end

                if greetVector then
                    if not ent.Alreadsaidline_vector then
                        ent.Alreadsaidline_vector = true
                        ent.Alreadsaidline = true
                        ent:StopSound("OM/Mighty/RandomRareLine_1.wav")
                        ent:StopSound("OM/Mighty/ThisPlaceIsGreat.wav")
                        ent:StopSound("OM/Mighty/Everybodyready.wav")
                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/Mighty/vector.wav",
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 86
                            },
                            ent
                        )
                    end
                end
                if greetRay then
                    if not ent.Alreadsaidline_Ray then
                        ent.Alreadsaidline_Ray = true
                        ent.Alreadsaidline = true
                        ent:StopSound("OM/Mighty/RandomRareLine_1.wav")
                        ent:StopSound("OM/Mighty/ThisPlaceIsGreat.wav")
                        ent:StopSound("OM/Mighty/Everybodyready.wav")
                        
                        ent:StopSound("OM/Mighty/vector.wav")

                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/Mighty/RandomRareLine_1.wav",
                                    "OM/Mighty/ThisPlaceIsGreat.wav",
                                    "OM/Mighty/Everybodyready.wav",
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 86
                            },
                            ent
                        )
                    end
                end
            else
                if ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime() then
                    ent:SetNW2Bool("Mighty_IsNearSurvivor_OM", CurTime()+0.1)
                end
            end
            


        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if button == ply:GetInfoNum("om_pills_action_mighty_TakeCover", KEY_E) then
                if ent:GetNW2Float("om_Mighty_takecover_cd") > CurTime() then return end

                if ent:GetNW2Float("ram_chargeup_duration") > CurTime() then return end
                if ent:GetNW2Float("ram_charge_duration") > CurTime() then return end
                if ent:GetNW2Bool("Ram_Decay") then return end
                if ent.ram_chargeup_bool then return end
                if ent.ram_charge_bool then return end

                if ent:GetNW2Float("ram_BoulderSpawn_duration") > CurTime() then return end
                if ent:GetNW2Float("ram_BoulderThrow_duration") > CurTime() then return end
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return end
                if IsValid(ent:GetNW2Entity("ent_om_mighty_rock_display")) then return end


                ent:GetPuppet():SetNW2Float("mighty_glowwhite", CurTime()+0.5)
                ent:SetNW2Float("CounterOM_duration", CurTime()+0.5)
                if not ent:GetNW2Bool("om_Mighty_takecover_toggle") then
                    if not GetConVar("OUTCOMEMORIES_N_mighty_cover_useable"):GetBool() then return end
                    ent:SetNW2Bool("om_Mighty_takecover_toggle", true)

                    if ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime() then 
                        ent:SetNW2Float("om_Mighty_takecover_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_start"):GetFloat()*0.75) 
                    else
                        ent:SetNW2Float("om_Mighty_takecover_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_start"):GetFloat())
                    end

                    AdvancedPillSound(
                        {
                            stringe = {
                                "OM/Mighty/CoverUpStart.wav",
                            },
                            pitchPercent = 100,
                            volume = 3,
                            soundLevel = 90
                        },
                        ent
                    )
                    local fx = EffectData()
                    --fx:SetOrigin(ent:GetPos()+Vector(0,0,30))
                    fx:SetEntity(ent:GetPuppet())

                    util.Effect("mighty_shield_activate", fx, true, true)
                else
                    ent:SetNW2Bool("om_Mighty_takecover_toggle", false)

                    if ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime() then 
                        ent:SetNW2Float("om_Mighty_takecover_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_cancel"):GetFloat()*0.75) 
                    else
                        ent:SetNW2Float("om_Mighty_takecover_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_cancel"):GetFloat())
                    end
                    
                    AdvancedPillSound(
                        {
                            stringe = {
                                "OM/Mighty/MightyShieldPop.wav",
                            },
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    local fx = EffectData()
                    --fx:SetOrigin(ent:GetPos()+Vector(0,0,30))
                    fx:SetEntity(ent:GetPuppet())

                    util.Effect("mighty_shield_break", fx, true, true)
                end
            end
            if button == ply:GetInfoNum("om_pills_action_mighty_ExponensialRam", KEY_R) then
                if not GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_useable"):GetBool() then return end
                if ent:GetNW2Float("om_Mighty_ram_cd") > CurTime() then return end

                if ent:GetNW2Bool("om_Mighty_takecover_toggle") then return end

                if ent:GetNW2Float("ram_chargeup_duration") > CurTime() then return end
                if ent:GetNW2Float("ram_charge_duration") > CurTime() then return end
                if ent:GetNW2Bool("Ram_Decay") then return end
                if ent.ram_chargeup_bool then return end
                if ent.ram_charge_bool then return end

                if ent:GetNW2Float("ram_BoulderSpawn_duration") > CurTime() then return end
                if ent:GetNW2Float("ram_BoulderThrow_duration") > CurTime() then return end
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return end
                if IsValid(ent:GetNW2Entity("ent_om_mighty_rock_display")) then return end

                ent:PillAnim("RamChargeUp")
                local seq = ent:GetPuppet():LookupSequence("RamChargeUp")
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                ent:SetNW2Float("ram_chargeup_duration", CurTime() + ent:GetPuppet():SequenceDuration(seq))



                if GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):GetBool() then
                    if ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime() then
                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/Mighty/Charge_Someonenear1.wav",
                                    "OM/Mighty/Charge_Someonenear2.wav",
                                    "OM/Mighty/Charge_Someonenear3.wav",
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    else
                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/Mighty/StayFocused.wav",
                                    "OM/Mighty/FocusScared.wav",
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end
                end

                AdvancedPillSound(
                    {
                        stringe = {
                            "OM/Mighty/ChargeFocus.wav",
                        },
                        pitchPercent = 100,
                        volume = 0.5,
                        soundLevel = 90
                    },
                    ent
                )

                AdvancedPillSound(
                    {
                        stringe = "OM/kolossos/StartUpCharge.wav",
                        pitchPercent = 65,
                        volume = 0.75,
                        soundLevel = 87
                    },
                    ent
                )

                AdvancedPillSound({
                    stringe = "OM/mighty/MightyChargeUp.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 76
                }, ent)

                ent:GetPuppet():SetNW2Float("Mighty_charge_glow_duration", CurTime()+0.5*0.75)
            end
            if button == ply:GetInfoNum("om_pills_action_mighty_BoulderThrow", KEY_T) then
                if not GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_useable"):GetBool() then return end
                if ent:GetNW2Float("om_Mighty_boulder_cd") > CurTime() then return end

                if ent:GetNW2Float("ram_BoulderSpawn_duration") > CurTime() then return end
                if ent:GetNW2Float("ram_BoulderThrow_duration") > CurTime() then return end
                if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then return end
                if IsValid(ent:GetNW2Entity("ent_om_mighty_rock_display")) then return end

                if ent:GetNW2Bool("om_Mighty_takecover_toggle") then return end

                if ent:GetNW2Float("ram_chargeup_duration") > CurTime() then return end
                if ent:GetNW2Float("ram_charge_duration") > CurTime() then return end
                if ent:GetNW2Bool("Ram_Decay") then return end
                if ent.ram_chargeup_bool then return end
                if ent.ram_charge_bool then return end

                if not ply:IsOnGround() then return end

                ent:PillAnim("BoulderSpawn")
                local seq = ent:GetPuppet():LookupSequence("BoulderSpawn")
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                ply:SetVelocity(Vector(0,0,0))
                ply:SetLocalVelocity(Vector(0,0,0))
                ent:SetNW2Float("ram_BoulderSpawn_duration", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                ent:SetNW2Bool("ram_BoulderSpawn_hasrock", true)

                timer.Simple(0.3,function()
                    if !IsValid(ent) then return end

                    if GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):GetBool() then
                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/Mighty/Ram1.wav",
                                    "OM/Mighty/Ram2.wav",
                                    "OM/Mighty/Ram3.wav",
                                    "OM/Mighty/Ram4.wav",
                                    "OM/Mighty/Ram5.wav",
                                    "OM/Mighty/Ram6.wav",
                                    "OM/Mighty/Ram7.wav"
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end

                    local fx = EffectData()
                    fx:SetOrigin(ply:GetPos()+ent:GetPuppet():GetForward()*30)
                    fx:SetNormal(Vector(0,0,1))
                    util.Effect("Mighty_rockgrab", fx, true, true)

                    AdvancedPillSound(
                        {
                            stringe = "OM/mighty/grabrock.mp3",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:GetPuppet():SetNW2Float("mighty_glowwhite", CurTime()+0.5)
                    ent:SetNW2Float("mighty_glowwhite", CurTime()+0.5)

                    if SERVER then
                        local rock = ents.Create("ent_om_mighty_rock_display")
                        if IsValid(rock) then
                            rock:SetPos(ent:GetPuppet():GetPos())
                            rock:SetPillUser(ent:GetPuppet())
                            rock:Spawn()

                            ent:DeleteOnRemove(rock)
                            ent:SetNW2Entity("ent_om_mighty_rock_display", rock)

                            rock:GetPuppet():SetNW2Float("mighty_glowwhite", CurTime()+0.5)
                        end
                    end
                    ent:SetNW2Float("ram_BoulderThrow_cantThrowDuratino", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_ThrowDisabledDuration"):GetFloat())
                    
                    ent:SetNW2Float("om_Mighty_boulder_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_ThrowDisabledDuration"):GetFloat())
                    ent:SetNW2Float("om_Mighty_boulder_dur", ent:GetNW2Float("om_Mighty_boulder_cd")-CurTime())
                end)
            end
        end
    end,

    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if ent:GetNW2Float("ram_BoulderSpawn_duration") > CurTime() then return end
            if ent:GetNW2Float("ram_BoulderThrow_duration") > CurTime() then return end
            if ent:GetNW2Float("ram_BoulderThrow_cantThrowDuratino") > CurTime() then return end

            if ent:GetNW2Bool("ram_BoulderSpawn_hasrock") then
                ent:PillAnim("BoulderThrow")
                local seq = ent:GetPuppet():LookupSequence("BoulderThrow")
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                ent:SetNW2Float("ram_BoulderThrow_duration", CurTime() + ent:GetPuppet():SequenceDuration(seq)+0.1)
                ent:SetNW2Bool("ram_BoulderSpawn_hasrock", false)

                if ent:GetNW2Float("om_Mighty_ram_cd") > CurTime() then
                    ent:SetNW2Float("om_Mighty_ram_cd", ent:GetNW2Float("om_Mighty_ram_cd") + GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_ramaddcd"):GetFloat())
                else
                    ent:SetNW2Float("om_Mighty_ram_cd", CurTime() + GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_ramaddcd"):GetFloat())
                end
                if ent:GetNW2Float("om_Mighty_takecover_cd") > CurTime() then
                    ent:SetNW2Float("om_Mighty_takecover_cd", ent:GetNW2Float("om_Mighty_takecover_cd") + GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_TakeCoveraddcd"):GetFloat())
                else
                    ent:SetNW2Float("om_Mighty_takecover_cd", CurTime() + GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_TakeCoveraddcd"):GetFloat())
                end

                timer.Simple(0.65,function()
                    if !IsValid(ent) then return end
                    if IsValid(ent:GetNW2Entity("ent_om_mighty_rock_display")) then
                        ent:GetNW2Entity("ent_om_mighty_rock_display"):Remove()
                    end

                    if GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):GetBool() then
                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/Mighty/Ram1.wav",
                                    "OM/Mighty/Ram2.wav",
                                    "OM/Mighty/Ram3.wav",
                                    "OM/Mighty/Ram4.wav",
                                    "OM/Mighty/Ram5.wav",
                                    "OM/Mighty/Ram6.wav",
                                    "OM/Mighty/Ram7.wav"
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end

                    local rock = ents.Create("prop_physics")

                    if IsValid(rock) then
                        rock:SetModel("models/props_wasteland/rockgranite03b.mdl")

                        local leftBone = ent:GetPuppet():LookupBone("LeftHand")
                        local rightBone = ent:GetPuppet():LookupBone("RightHand")

                        if leftBone and rightBone then
                            local leftPos = ent:GetPuppet():GetBonePosition(leftBone)
                            local rightPos = ent:GetPuppet():GetBonePosition(rightBone)

                            if leftPos and rightPos then
                                local medianPos = (leftPos + rightPos) / 2
                                local plyangles = ent:GetPuppet():GetAngles()

                                medianPos = medianPos
                                    + plyangles:Forward() * 10
                                    + plyangles:Up() * 10

                                rock:SetPos(medianPos)
                            end
                        end

                        rock:SetAngles(ent:GetPuppet():GetAngles())
                        rock:Spawn()

                        ent:DeleteOnRemove(rock)
                        ent:SetNW2Entity("ent_om_mighty_rock_display", rock)

                        local phys = rock:GetPhysicsObject()

                        if IsValid(phys) then
                            phys:Wake()
                            phys:SetVelocity(ply:GetAimVector() * 1300 + Vector(0,0,200))
                            phys:SetMass(50)
                            phys:EnableDrag(false)
                            phys:EnableMotion(true)
                        end

                        rock:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

                        local function stunrock(range)
                            local jumpscare_entity = nil
                            for _, ent2 in pairs(ents.FindInSphere( rock:GetPos(), 60)) do
                                if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                                if ent2:GetClass() == "pill_puppet" then continue end
                                if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                                    if ent2 == ply then continue end
                                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                    local stunstacking = GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stunstacking"):GetBool()
                                    

                                    if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then continue end


                                    if Mutual_OMCanStun(ply, ent, ent2, stunstacking) then
                                        if IsValid(ent2:GetNWEntity("OM_ragdollentity")) then
                                            continue
                                        end

                                        local hitNormal = (rock:GetPos()-ent2:GetPos())
                                        local hitPos = rock:GetPos()

                                        ent2:SetNW2Float("Mighty_chargeShoot_glow_duration", CurTime()+0.5*0.75)
                                        

                                        AdvancedPillSound({
                                            stringe = "OM/kolossos/kol charge start ground rumble.wav",
                                            pitchPercent = 100,
                                            volume = 0.25,
                                            soundLevel = 76
                                        }, rock)

                                        AdvancedPillSound(
                                            {
                                                stringe = "physics/body/body_medium_impact_hard6.wav",
                                                pitchPercent = 100,
                                                volume = 0.25,
                                                soundLevel = 87
                                            },
                                            rock
                                        )

                                        AdvancedPillSound(
                                            {
                                                stringe = "npc/zombie/zombie_pound_door.wav",
                                                pitchPercent = 90,
                                                volume = 0.25,
                                                soundLevel = 92
                                            },
                                            rock
                                        )

                                        AdvancedPillSound(
                                            {
                                                stringe = "npc/antlion_guard/shove1.wav",
                                                pitchPercent = 85,
                                                volume = 0.25,
                                                soundLevel = 95
                                            },
                                            rock
                                        )

                                        AdvancedPillSound(
                                            {
                                                stringe = "ambient/machines/thumper_hit.wav",
                                                pitchPercent = 75,
                                                volume = 0.25,
                                                soundLevel = 96
                                            },
                                            rock
                                        )

                                        AdvancedPillSound(
                                            {
                                                stringe = "physics/flesh/flesh_squishy_impact_hard4.wav",
                                                pitchPercent = 75,
                                                volume = 0.25,
                                                soundLevel = 86
                                            },
                                            rock
                                        )


                                        Mutaul_OMStunCode(
                                            {
                                                ["ply"] = ply,
                                                ["ent"] = ent,
                                                ["target"] = ent2,
                                                ["StunDur"] = GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stunduration"):GetFloat(),
                                                ["stunfunction"] = function(shouldstundamage)
                                                    if shouldstundamage then
                                                        if GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_canragdoll"):GetBool() then
                                                            local last = CurTime() + 4
                                                            local flung = false
                                                            timer.Simple(0.1,function()
                                                                flung = true
                                                            end)
                                                            local dir = (ent2:GetPos() - hitPos):GetNormalized()
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


                                                                    for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                                        local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                                                        if IsValid(phys) then
                                                                            phys:Wake()
                                                                            phys:SetVelocityInstantaneous(dir*1500)
                                                                        end
                                                                    
                                                                    end
                                                                end
                                                            })
                                                        end
                                                    end
                                                end,
                                                ["checkoutprevention"] = true,
                                                ["shouldstack"] = stunstacking,
                                                ["Damage"] = GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stundamage"):GetFloat(), -- ent:GetNW2Float(StunTimesName) < 2  and true or 30
                                                ["DamageType"] = DMG_CLUB
                                            }
                                        )

                                        
                                        ent:SetNW2Float("om_Mighty_boulder_cd", ent:GetNW2Float("om_Mighty_boulder_cd")-2.3)

                                        if not jumpscare_entity then
                                            jumpscare_entity = ent2

                                            if GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):GetBool() then
                                                AdvancedPillSound(
                                                    {
                                                        stringe = {
                                                            "OM/mighty/landrock1.wav",
                                                            "OM/mighty/landrock2.wav"
                                                        },
                                                        pitchPercent = 100,
                                                        volume = 1,
                                                        soundLevel = 86
                                                    },
                                                    ent
                                                )
                                            end

                                            timer.Simple(0.5,function()
                                                if !IsValid(ent) then return end
                                                ent.formTable.OM_Mighty_Cheer(ply,ent)
                                            end)

                                            sound.Play(
                                                "physics/concrete/concrete_break2.wav",
                                                hitPos,
                                                60*2,
                                                math.random(95, 105)
                                            )

                                            sound.Play(
                                                "physics/concrete/boulder_impact_hard" .. math.random(1,4) .. ".wav",
                                                hitPos,
                                                70*2,
                                                math.random(90, 100)
                                            )

                                            sound.Play(
                                                "ambient/materials/rock" .. math.random(1,4) .. ".wav",
                                                hitPos,
                                                60*2,
                                                math.random(90, 110)
                                            )

                                            sound.Play(
                                                "OM/mighty/rockexplode.mp3",
                                                hitPos,
                                                80*2,
                                                math.random(90, 110)
                                            )

                                            util.ScreenShake(
                                                hitPos,
                                                8,
                                                8,
                                                0.4,
                                                400
                                            )

                                            local ed = EffectData()
                                            ed:SetOrigin(hitPos)
                                            ed:SetNormal(hitNormal)
                                            ed:SetScale(1)
                                            util.Effect("Metal_Charge_SMASHWALL", ed)

                                            local ed = EffectData()
                                            ed:SetOrigin(hitPos)
                                            util.Effect("GroundCrash_OM", ed)

                                        end
                                    end
                                end
                            end
                        end

                        local name = "RockThinking".. rock:EntIndex()
                        hook.Add("Think", name, function()
                            if !IsValid(rock) then hook.Remove("Think", name) return end

                            stunrock(70)

                            if jumpscare_entity then
                                rock:Remove()
                            end

                        end)

                        rock:CallOnRemove("RemoveHook_OM"..rock:EntIndex(), function()
                            hook.Remove("EntityTakeDamage", "disableAmy_hammerProp_damage_OM_:".. rock:EntIndex())
                        end)

                        rock:AddCallback("PhysicsCollide", function(self, data)

                            if self.Broken then return end
                            self.Broken = true

                            local hitPos = data.HitPos
                            local hitNormal = data.HitNormal

                            stunrock(120)

                            sound.Play(
                                "physics/concrete/concrete_break2.wav",
                                hitPos,
                                60*2,
                                math.random(95, 105)
                            )

                            sound.Play(
                                "physics/concrete/boulder_impact_hard" .. math.random(1,4) .. ".wav",
                                hitPos,
                                70*2,
                                math.random(90, 100)
                            )

                            sound.Play(
                                "ambient/materials/rock" .. math.random(1,4) .. ".wav",
                                hitPos,
                                60*2,
                                math.random(90, 110)
                            )

                            sound.Play(
                                "OM/mighty/rockexplode.mp3",
                                hitPos,
                                80*2,
                                math.random(90, 110)
                            )

                            util.ScreenShake(
                                hitPos,
                                8,
                                8,
                                0.4,
                                400
                            )

                            local ed = EffectData()
                            ed:SetOrigin(hitPos)
                            ed:SetNormal(hitNormal)
                            ed:SetScale(1)
                            util.Effect("Metal_Charge_SMASHWALL", ed)

                            local ed = EffectData()
                            ed:SetOrigin(hitPos)
                            util.Effect("GroundCrash_OM", ed)

                            self:Remove()
                        end)
                    end


                end)

                if ent:GetNW2Float("Mighty_IsNearSurvivor_OM") >= CurTime() then ent:SetNW2Float("om_Mighty_boulder_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_cd"):GetFloat()*0.75) else
                    ent:SetNW2Float("om_Mighty_boulder_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_cd"):GetFloat()) end
                ent:SetNW2Float("om_Mighty_boulder_dur", ent:GetNW2Float("om_Mighty_boulder_cd")-CurTime())


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
    end
})