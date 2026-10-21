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
    ["Sonic_OM_noodles_spindash"] = Material("icons/Sonic_OM_noodles_spindash.png"),
    ["Sonic_OM_noodles_peelout"] = Material("icons/Sonic_OM_noodles_peelout.png"),
    ["Lilith_Indicator_Move_Thingy"] = Material("icons/Lilith_Indicator_Move_Thingy.png"),
}
pk_pills.register('pill_om_ModernSonic', {

    printName='Modern Sonic',
    Outcomememories='Moddern Sonic',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/modernsonic.mdl",
    --[[
    hull = Vector(20,20,60),
    duckBy = 14,
    ]]
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',

    ShouldRoll_om = function(e, ply, ent)
        if ent:GetNW2Bool("ChargeDash_mode") then return false end
        return true
    end,

    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            return true
        end,
        colorbar = function(uselessvar,ply,ent)
            return Color(0, 0, 255, 255)
        end,
        progression = function(uselessvar,ply,ent)
            return ent:GetNW2Float("Rings")
        end,
        maximumbar = function(uselessvar,ply,ent)
            return 100
        end,
    },

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Sonic_OM_noodles_spindash"]
            end,
            name = function(uselessvar,ply,ent)
                return "Spin Dash"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Sonic_dropdash_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Spindash_Cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Spindash_Cooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.02, yaxis = 0+ iconsize*0.02, xsize = 0, ysize = 0}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Sonic_OM_noodles_peelout"]
            end,
            name = function(uselessvar,ply,ent)
                return "Peelout"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Sonic_peelout_key", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("PeelOut_Cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("PeelOut_Cooldown_duration", 0)
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 - iconsize*0.03, yaxis = 0, xsize = 0, ysize = 0}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Bool("ShouldntShowAbility4_OM") and math.random(1,300) ~= 1
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Lilith_Indicator_Move_Thingy"]
            end,
            name = function(uselessvar,ply,ent)
                return math.random(1,50) ~= 1 and "Super form" or "Friend energy"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_1
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("superform_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 5
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                shouldrandom = true
                return {
                    xaxis = 0 + iconsize * 0.15/2 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,25) ~= 1 and 1 or math.random(-30,30)), 
                    yaxis = 0 + iconsize * 0.2/2 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,25) ~= 1 and 1 or math.random(-30,30)),
                    xsize = 0- iconsize*0.15 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,25) ~= 1 and 1 or math.random(-30,30)),
                    ysize = 0- iconsize*0.15 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,25) ~= 1 and 1 or math.random(-30,30))
                }
            end,
            survivor = true,
            font = "CreditsText",
        },
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
                    return 235
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
            Dropdash= function(ply,ent)
                if SERVER then
                    return 1200
                end
            end,
            Peelout= function(ply,ent)
                if SERVER then
                    return 3000
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

        abilities = {
        }
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
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "shiftlock" end
                if ent:GetNW2Bool("ChargeDash_mode") then return "shiftlock" end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                return 'notanything' 
            end,
            run= function(ent) 
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "shiftlock" end
                if ent:GetNW2Bool("ChargeDash_mode") then return "shiftlock" end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                return 'notshftlock'
            end,
            walk= function(ent) 
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "shiftlock" end
                if ent:GetNW2Bool("ChargeDash_mode") then return "shiftlock" end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                return 'notshftlock'
            end,
            fall= function(ent) 
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "shiftlock" end
                if ent:GetNW2Bool("ChargeDash_mode") then return "shiftlock" end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            walk= function(ent) 
                if ent:GetNW2Bool("ChargeDash_mode") or ent:GetNW2Float("spindash_fake") > CurTime() then return "roll" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "run" end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return "PeelOut" end

                if IsValid(ent:GetNW2Entity("flyingent")) then
                    local ply = ent:GetPillUser()
                    ent.Flightmovelength = ent.Flightmovelength or 0
                    if ent.Flightmovelength <= 1 then
                        return "FlyIdle"
                    end

                     return "FlyMove"
                end

                if ent:GetNW2Float("GoingCrazy_chargeup") <= CurTime() then
                    if ent:GetNW2Bool("SuperForm") then return "FlyIdle" end
                end
            end,
            idle= function(ent) 
                if ent:GetNW2Bool("ChargeDash_mode") or ent:GetNW2Float("spindash_fake") > CurTime() then return "roll" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "run" end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return "PeelOut" end

                if IsValid(ent:GetNW2Entity("flyingent")) then
                    local ply = ent:GetPillUser()
                    ent.Flightmovelength = ent.Flightmovelength or 0
                    if ent.Flightmovelength <= 1 then
                        return "FlyIdle"
                    end

                     return "FlyMove"
                end

                if ent:GetNW2Float("GoingCrazy_chargeup") <= CurTime() then
                    if ent:GetNW2Bool("SuperForm") then return "FlyIdle" end
                end
            end,
            fall= function(ent) 
                if ent:GetNW2Bool("ChargeDash_mode") or ent:GetNW2Float("spindash_fake") > CurTime() then return "roll" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("JumpDuration") > CurTime() then return "jump" end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "run" end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return "PeelOut" end

                if IsValid(ent:GetNW2Entity("flyingent")) then
                    local ply = ent:GetPillUser()
                    ent.Flightmovelength = ent.Flightmovelength or 0
                    if ent.Flightmovelength <= 1 then
                        return "FlyIdle"
                    end

                     return "FlyMove"
                end

                if ent:GetNW2Float("GoingCrazy_chargeup") <= CurTime() then
                    if ent:GetNW2Bool("SuperForm") then return "FlyMove" end
                end
            end,
            run= function(ent)
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("ChargeDash_mode") or ent:GetNW2Float("spindash_fake") > CurTime() then return "roll" end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return "PeelOut" end

                if IsValid(ent:GetNW2Entity("flyingent")) then
                    local ply = ent:GetPillUser()
                    ent.Flightmovelength = ent.Flightmovelength or 0
                    if ent.Flightmovelength <= 1 then
                        return "FlyIdle"
                    end

                     return "FlyMove"
                end

                if ent:GetNW2Float("GoingCrazy_chargeup") <= CurTime() then
                    if ent:GetNW2Bool("SuperForm") then return "FlyMove" end
                end
            end,
        },
        animrates = {
            idle = function(ent)
                if ent:GetNW2Float("JumpDuration") > CurTime() then return 1 end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return 3 end
                if ent:GetNW2Float("ChargeDash_duration") >= CurTime() then return 1.5 * ent:GetNW2Float("Decay_left_chargedash") end
                if ent:GetNW2Float("ChargeDash_chargeupduration") >= CurTime() then return ent:GetNW2Float("ChargeDash_currentamount")*2/100 end

                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local Factor = ( (ent:GetNW2Float("PeelOut_duration_anim") - CurTime()) / 3 ) *1
                    local clamp = math.Clamp(Factor, 0, 1)
                    local lerp = Lerp(clamp, 4.2, 0)
                    return lerp
                end

                return 1
            end,
            walk = function(ent)
                if ent:GetNW2Float("JumpDuration") > CurTime() then return 1 end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return 2 end
                if ent:GetNW2Float("ChargeDash_duration") >= CurTime() then return 1.5 * ent:GetNW2Float("Decay_left_chargedash") end
                if ent:GetNW2Float("ChargeDash_chargeupduration") >= CurTime() then return ent:GetNW2Float("ChargeDash_currentamount")*2/100 end

                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local Factor = ( (ent:GetNW2Float("PeelOut_duration_anim") - CurTime()) / 3 ) *1
                    local clamp = math.Clamp(Factor, 0, 1)
                    local lerp = Lerp(clamp, 4.2, 0)
                    return lerp
                end

                return 1
            end,

            run = function(ent)
                if ent:GetNW2Float("JumpDuration") > CurTime() then return 1 end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return 3 end
                if ent:GetNW2Float("ChargeDash_duration") >= CurTime() then return 1.5 * ent:GetNW2Float("Decay_left_chargedash") end
                if ent:GetNW2Float("ChargeDash_chargeupduration") >= CurTime() then return ent:GetNW2Float("ChargeDash_currentamount")*2/100 end

                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local Factor = ( (ent:GetNW2Float("PeelOut_duration_anim") - CurTime()) / 3 ) *1
                    local clamp = math.Clamp(Factor, 0, 1)
                    local lerp = Lerp(clamp, 4.2, 0)
                    return lerp
                end

                return math.Clamp(ent:GetNW2Float("accelerationfactor_om_modernsonic"),0,4)
            end,

            fall = function(ent)
                if ent:GetNW2Float("JumpDuration") > CurTime() then return 1 end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return 3 end
                if ent:GetNW2Float("ChargeDash_duration") >= CurTime() then return 1.5 * ent:GetNW2Float("Decay_left_chargedash") end
                if ent:GetNW2Float("ChargeDash_chargeupduration") >= CurTime() then return ent:GetNW2Float("ChargeDash_currentamount")*2/100 end

                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local Factor = ( (ent:GetNW2Float("PeelOut_duration_anim") - CurTime()) / 3 ) *1
                    local clamp = math.Clamp(Factor, 0, 1)
                    local lerp = Lerp(clamp, 4.2, 0)
                    return lerp
                end

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
        if ent:GetNW2Bool("ChargeDash_mode") or ent:GetNW2Float("spindash_fake") > CurTime() then
            basetable =  {
                startoffset = Vector(20,0,40),  -- left-up, front-back, up-down
                dist=145,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 0,
                transition = 1,
                canscroll = true,
            }
        end

        if ent:GetNW2Float("PeelOut_duration") > CurTime() then
            basetable =  {
                startoffset = Vector(20,0,45),  -- left-up, front-back, up-down
                dist=145,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 1,
                transition = 1,
                canscroll = true,
            }
        end

        local fly = ent:GetNW2Entity("flyingent")
        if IsValid(fly) then
            basetable =  {
                startoffset = Vector(15,0,55),  -- left-up, front-back, up-down
                dist=145,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 2,
                transition = 1,
                canscroll = true,
            }
        end

        return basetable
    end,
    
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },
        

    OM_UI_custom_start = function(ply, ent)
        if not ent.Leap_bar_lerp_eyx then
            ent.Leap_bar_lerp_eyx = 0
        end

        if ent:GetNW2Float("ChargeDash_chargeupduration") >= CurTime() then
            ent.Leap_bar_lerp_eyx = Lerp(FrameTime() * 9, ent.Leap_bar_lerp_eyx, 1)
        else
            ent.Leap_bar_lerp_eyx = Lerp(FrameTime() * 9, ent.Leap_bar_lerp_eyx, 0)
        end

        if ent.Leap_bar_lerp_eyx > 0.05 then
            local screenW, screenH = ScrW(), ScrH()
            local middlex, middley = screenW * 0.5, screenH * 0.5
            local iconsize = screenW / 13

            local barW = iconsize * 3.75 * ent.Leap_bar_lerp_eyx
            local barH = iconsize * 0.15

            local x = middlex - barW * 0.5
            local y = middley - iconsize * -2.5

            local starttime = ent:GetNW2Float("ChargeDash_currentamount")
            local factorClamped = math.Clamp(starttime / 100, 0, 1)
            local factor = Lerp(factorClamped, 0, 1)

            local shakeFrac = math.Clamp((factorClamped - 0.65) / 0.35, 0, 1)

            local shakeX = math.sin(CurTime() * 25) * shakeFrac * 3
            local shakeY = math.cos(CurTime() * 21) * shakeFrac * 2

            x = x + shakeX
            y = y + shakeY

            draw.RoundedBox(8, x - 2, y + 2, barW + 4, barH + 4, Color(0, 0, 0, 120))
            draw.RoundedBox(8, x, y, barW, barH, Color(20, 20, 20, 220))

            surface.SetDrawColor(255, 255, 255, 15)
            surface.DrawOutlinedRect(x, y, barW, barH, 1)

            local currentW = math.max(barW * factor, 0)
            local currentX = x + (barW - currentW) * 0.5

            draw.RoundedBox(8, currentX, y, currentW, barH, Color(255, 60, 60))

            if currentW > 4 then
                surface.SetDrawColor(255, 255, 255, 20)
                surface.DrawRect(
                    currentX + 2,
                    y + 2,
                    currentW - 4,
                    math.max((barH - 4) * 0.35, 1)
                )
            end

            draw.SimpleText(
                "Spam E for faster speed",
                "EYX_LeapText",
                middlex - iconsize * 0,
                y - iconsize*0.15,
                Color(255, 175, 175, 255*ent.Leap_bar_lerp_eyx),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_BOTTOM
            )
        end
    end,


    --canAim=function(ply,ent) return ent.active end,     

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if event == "Step" then
            StepSFX_OM(ply,ent)
        end
        if event == "Attack" then

            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end

            if SERVER then

                local nearest
                local nearestDist = math.huge

                local forward = 10
                local AttackRadius = 175

                local attackPos = ent:LocalToWorld(Vector(0, 0, 50)+ent:GetPuppet():GetForward()*forward)

                for _, ent2 in pairs(ents.FindInSphere(attackPos, AttackRadius)) do
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                        --if not Mutal_OMCanDamage(ply, ent, ent2) then continue end

                        local dist = attackPos:DistToSqr(ent2:GetPos())

                        if (ent2:GetNW2Bool("OM_character") and not GetConVar("PVPStun_OM"):GetBool()) then
                        else
                            if dist < nearestDist then
                                nearestDist = dist
                                nearest = ent2
                            end
                        end
                    end
                end

                if IsValid(nearest) then
                    local damageamount = 25

                    Mutaul_OMStunCode(
                        {
                            ["ply"] = ply,
                            ["ent"] = ent,
                            ["target"] = nearest,
                            ["StunDur"] = 3,
                            ["stunfunction"] = function(shouldstundamage)
                                if shouldstundamage then
                                    nearest:SetNW2Float("Amy_highlight_pill_red", CurTime()+0.5*0.35)

                                    nearest:SetVelocity( ply:GetVelocity():GetNormalized()*750 )

                                    if SERVER then
                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/Amy/HammerHit.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        )

                                        local last = CurTime() + 2
                                        local flung = false
                                        local flung2 = false

                                        local enemyragdoll = CreateRagdolLCharacter_OM({
                                            target = nearest,
                                            host = ent,

                                            shouldremove = function(createfakeragdoll)
                                                if not IsValid(createfakeragdoll) then return true end
                                                if not IsValid(nearest) then return true end
                                                if not IsValid(ent) then return true end

                                                local pos = createfakeragdoll:GetPos()

                                                local tr = util.TraceLine({
                                                    start = pos,
                                                    endpos = pos - Vector(0, 0, 10),
                                                    filter = createfakeragdoll
                                                })

                                                if (last < CurTime() and tr.Hit ) or nearest:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime() then
                                                    return true
                                                else
                                                    if not tr.Hit then
                                                        last = CurTime() + 1
                                                    end
                                                end
                                                return false
                                            end,

                                            shoulddocustomfunction = function(createfakeragdoll)
                                                if not IsValid(createfakeragdoll) then return end
                                                if not IsValid(ent) then return end
                                                if flung then return end

                                                local ragPos = nearest:GetPos()
                                                local entPos = ply:GetPos()

                                                local dir = (ragPos - entPos):GetNormalized()

                                                local force = dir * 900 + Vector(0, 0, 2)

                                                local phys = createfakeragdoll:GetPhysicsObject()
                                                if IsValid(phys) then
                                                    phys:SetVelocity(force)
                                                    phys:AddAngleVelocity(VectorRand() * 800)
                                                end

                                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                    local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                    if IsValid(bonePhys) then
                                                        bonePhys:SetVelocity(force)
                                                        bonePhys:AddAngleVelocity(VectorRand() * 800)
                                                    end
                                                end

                                                if flung2 then return end
                                                flung2 = true
                                                timer.Simple(0.02,function()
                                                    flung = true
                                                end)
                                            end
                                        })
                                    end

                                end
                            end,
                            ["shouldstack"] = true,
                            ["Damage"] = 25,
                            ["DamageType"] = DMG_CLUB
                        }
                    )

                end
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
    
        initializetable2["player"].ColorRGB_B_1_OM = Color(0,35,255, 255)
        if SERVER then

            initializetable2["entity"]:SetNW2Float("OM_Damage_Reduction",1)
            local health = GetConVar("OUTCOMEMEMORIES_N_Sonic_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)

            initializetable2["entity"]:SetNW2Float("Rings", 100)
            initializetable2["entity"]:SetNW2Float("MaxRings", 100)
            initializetable2["entity"]:SetNW2Float("OM_friction",0.25)
            initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
            initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)

            initializetable2["entity"]:SetNW2Float("OM_Fleetway_flyingBar", 200)
            initializetable2["entity"]:SetNW2Float("OM_maximum_flight", 200)
            initializetable2["entity"]:SetNW2Bool('HasFlyCompad_OM', true)

            initializetable2["entity"].CanClashOpponents_OM = true

            initializetable2["player"].CustomFunctionForDowned_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]
                    ent:SetNW2Float("ChargeDash_duration", 0)
                    ent:SetNW2Float("Decay_left_chargedash", 0)
                    ent:SetNW2Float("PeelOut_duration", 0)
                    ent:SetNW2Float("PeelOut_duration2", 0)
                    ent:SetNW2Float("PeelOut_duration_anim", 0)
                
                

                    if ent.PeelOut_duration2_early_bool or ent.PeelOut_duration2_bool then
                        ent:SetNW2Float("PeelOut_Cooldown", CurTime()+ent.formTable.Outcomememories_stats.abilities.PeelOut.CooldownFail())
                    end

                    ent.PeelOut_duration2_early_bool = false
                    ent.PeelOut_duration2_bool = false
                end
            end
            initializetable2["player"].CustomFunctionCancelAbility_OM = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end
            initializetable2["player"].OM_Stun_Blockfunction = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end

            local oldpos = Vector(0,0,0)
            local ent22 = ent2

            initializetable2["player"].OMInitiateClash_lnz = function(v,ent2)
                if IsValid(initializetable2["entity"]) then

                    local ent = initializetable2["entity"]
                    local ply = initializetable2["player"]

                    ent22 = ent2

                    oldpos = ply:GetPos() + Vector(0,0,10)

                    local character = ""
                    if ent2.pk_pill_ent then
                        character = ent2.pk_pill_ent.formTable.printName
                    end
                    if ent2.formTable then
                        character = ent2.formTable.printName
                    end

                    local ent2pos = ent2:GetPos()
                    local plypos = ply:GetPos()
                    local angl = ( Vector(ent2pos.x,ent2pos.y,0)-Vector(plypos.x,plypos.y,0) ):Angle()
                    ent:SetNW2Angle("pill_assignedangle", angl)
                    ply:SetAngles(angl)
                    ent:SetAngles(angl)
                    if character == "Furnace" then
                        ply:SetPos(ent2:GetPos()+angl:Forward()*-60+ent2:GetUp()*26)
                    end

                    -- Set the CD
                    local cdamount = 25
                    if ent:GetNW2Bool("SuperForm") then
                        cdamount = cdamount * 0.35
                    end
                    ent:SetNW2Float("Spindash_Cooldown", CurTime()+ cdamount )
                    ent:SetNW2Float("Spindash_Cooldown_duration", cdamount )

                    local oldpos = ply:GetPos()
                    if ply:IsPlayer() then
                        ply:SetMoveType(MOVETYPE_NONE)
                    else
                        ply:SetMoveType(2)
                        if ply.loco then
                            ply.loco:SetVelocity(vector_origin)
                            ply.loco:SetDesiredSpeed(0)
                        end
                    end
                    ent:SetNW2Float('Spindash_Duration',CurTime()-1)
                    ply:SetNW2Float("OM_lowerFriction", CurTime()-1)
                    ent:SetNW2Float('spindash_fake', CurTime()+1e9)
                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/dropdash_final.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )


                    local effect = EffectData()
                    effect:SetOrigin(ply:GetPos())
                    effect:SetNormal(ent:GetForward())

                    util.Effect("sonic_dropdashdrill_OM", effect)

                    ply.SonicOldPos = ply:GetPos()

                end
            end

            initializetable2["player"].OM_ShouldClash = function()
                if IsValid(initializetable2["entity"]) then
                    if initializetable2["entity"]:GetNW2Float("DropDash_Diving") > CurTime() then return false end
                    if initializetable2["entity"]:GetNW2Float("Spindash_Duration") > CurTime() then return true end
                    if initializetable2["entity"]:GetNW2Float("spindash_fake") > CurTime() then return true end
                end
                return false
            end

            initializetable2["player"].OMCompelteClash_lnz = function(Wintype)
                if !IsValid(initializetable2["entity"]) then return end

                local ply = initializetable2["player"]
                local ent = initializetable2["entity"]

                ply:SetPos(oldpos)

                ply:SetNW2Float("OM_Damage_Reduction",1)
                
                ent:SetNW2Float('spindash_fake', CurTime()-1)
                ent:SetNW2Bool('Spindashused',false)

                -- Set the CD
                local cdamount = 25
                if ent:GetNW2Bool("SuperForm") then
                    cdamount = cdamount * 0.35
                end
                ent:SetNW2Float("Spindash_Cooldown", CurTime()+ cdamount )
                ent:SetNW2Float("Spindash_Cooldown_duration", cdamount )

                if ply.loco then
                    ply.loco:SetVelocity(vector_origin)
                    ply.loco:SetDesiredSpeed(0)
                end

                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_WALK)
                else
                    ply:SetMoveType(0)
                    if SERVER then
                        ent.TeleportEnt = nil
                    end
                end

                AdvancedPillSound(
                   {
                        stringe = "OM/sonic/stun.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
               )

                timer.Simple(0.1,function()
                    if !IsValid(ply) then return end
                    ply:SetPos(ply.SonicOldPos)
                    if ply:IsPlayer() then
                        if IsValid(ent2) then
                            ply:SetPos(ply:GetPos()+Vector(0,0,8))
                            local dir = ((ply:GetPos()+ply:GetForward()*-6) - (ply:GetPos()-Vector(0,0,1))):GetNormalized()
                            ply:SetVelocity(dir * 550)
                            ply:SetLocalVelocity(dir * 550)
                        end            
                    end
                end)

                if Wintype == "Win" then
                    local ringgain = GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_ringgain"):GetFloat()
                    if ent:GetNW2Float("Rings") < ent:GetNW2Float("MaxRings", 0) then 
                        if ent:GetNW2Float("Rings") + ringgain < ent:GetNW2Float("MaxRings", 0) then 
                            ent:SetNW2Float("Rings", ent:GetNW2Float('Rings') + ringgain)
                        else
                            ent:SetNW2Float("Rings", ent:GetNW2Float("MaxRings", 0))
                        end
                    else
                        ent:SetNW2Float("Rings", ent:GetNW2Float("MaxRings", 0))
                    end
                end
                return true
            end
        end
        initializetable2["player"]:SetNW2Bool("OM_character", true)
        local dur = CurTime()

        timer.Simple(0,function()
            if !IsValid(initializetable2["entity"]) then return end
            initializetable2["player"].OM_DamageBeforeCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                local ent = initializetable2["entity"]
                if !IsValid(initializetable2["entity"]) then return end
                if damageamount > 0 then else return end

                if entityfall == initializetable2["player"] then
                    if ( dmg:IsDamageType(DMG_BURN) or dmg:IsDamageType(DMG_BLAST) or dmg:IsDamageType(DMG_DROWN) or dmg:IsDamageType(DMG_SLOWBURN) or dmg:IsDamageType(DMG_RADIATION) ) then

                    else
                        if initializetable2["entity"]:GetNW2Float("Rings") > 0 then
                            local minim = initializetable2["entity"]:GetNW2Float("Rings")-dmg:GetDamage()
                            if minim < 0 then minim = 0 end
                            initializetable2["entity"]:SetNW2Float('Rings', minim)
                            dmg:SetDamage(0)
                            dmg:SetDamageType(DMG_GENERIC)
                                
                            if SERVER then
                                ent:SetNW2Float("DodgeAnim", CurTime()+0.5)
                                ent:SetNW2Float("DodgeAnim_id", math.random(1,4))
                                ent:GetPuppet():SetNW2Float("sonicdodge_afterimage_duration", CurTime()+0.05)
                            end
                        end
                    end
                end
            end
        end)
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            hook.Remove("EntityTakeDamage", "ringspending".. initializetable2["player"]:EntIndex())
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetNW2Float("OM_NoMovement_noodles", CurTime())
            initializetable2["player"]:SetNW2Float("OM_NoMovement_noodles_jump", CurTime())
        end

        initializetable2["entity"]:StopSound("OM/sonic/PeelOutChargeUp.wav")
        initializetable2["entity"]:StopSound("OM/sonic/PeelOutStart.wav")
        initializetable2["entity"]:StopSound("OM/sonic/peeloutstop.wav")
        initializetable2["entity"]:StopSound("OM/sonic/dropdash_final.wav")
        initializetable2["entity"]:StopSound("OM/sonic/DropdashDrill.wav")
        initializetable2["entity"]:StopSound("OM/sonic/dropdashrelease.wav")

        initializetable2["entity"]:StopSound("OM/sonic/Dashing_end.wav")
        initializetable2["entity"]:StopSound("OM/sonic/Dashing_loop.wav")
        initializetable2["entity"]:StopSound("OM/sonic/Dashing_start.wav")

        initializetable2["entity"]:StopSound("OM/sonic/peeloutrelease2.wav")

        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")

        initializetable2["entity"].GotTheStun = false
    end,


    speedhandeler_om = {
        modifiers = {
            ["supersonic"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                local factor = 1
                local factor2 = 1
                local factor3 = 1
                if ent:GetNW2Bool("SuperForm") then
                    factor = factor * 2.5
                    factor2 = factor2 * 9
                    factor3 = factor3 * 3
                end

                sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * factor2 - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run() * factor - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.ducked() * factor3 - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1

                return sendtotable
            end,
            ["acceleration"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if not ent.accelerationfactor then
                    ent.accelerationfactor = 1
                end
                local factor = ent.accelerationfactor
                if ent:GetNW2Bool("SuperForm") then
                    factor = factor * 1
                end

                sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * factor - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run() * factor - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.ducked() * factor - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1

                return sendtotable
            end,
            ["chargeadsh"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }


                if ent:GetNW2Bool("ChargeDash_mode") then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.Dropdash()*ent:GetNW2Float("ChargeDash_currentamount")/40 * math.Clamp(ent:GetNW2Float("Decay_left_chargedash"), 0.3, 1) - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Dropdash()*ent:GetNW2Float("ChargeDash_currentamount")/40  * math.Clamp(ent:GetNW2Float("Decay_left_chargedash"), 0.3, 1) - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.Dropdash()*ent:GetNW2Float("ChargeDash_currentamount")/40  * math.Clamp(ent:GetNW2Float("Decay_left_chargedash"), 0.3, 1) - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
            ["peelout"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }


                if ent:GetNW2Float("PeelOut_duration") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.Peelout()  - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Peelout()  - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.Peelout()  - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
        }
    },

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            local Dashing_loop = false
            local CanAccelerate = true
            OM_PILL_speedThink(ply, ent)

            ply:SetNW2Float("DamageResistance_OM_2", 100   / 100)


            local fly = ent:GetNW2Entity("flyingent")

            if IsValid(fly) and ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) < CurTime() then

                ply:SetNW2Float("NoJumpingCooldown_OM", CurTime() + 0.1)

                local options = {
                    speed = 0,
                    flyingdrainamount = 0.1
                }

                local move = Vector(0, 0, 0)
                local angled = fly:GetAngles()
                local aim = Angle(0, ply:EyeAngles().y, 0)

                if ply:IsPlayer() then
                    aim.p = math.Clamp(ply:EyeAngles().p, -90, 90)

                    if ply:KeyDown(IN_SPEED) then
                        options.speed = 30
                    else
                        options.speed = 15
                    end
                    local MoveForward = false
                    if ent:GetNW2Float("ChargeDash_duration") >= CurTime() or ent:GetNW2Float("Decay_left_chargedash") > 0.01 then 
                        options.speed = 37 
                        MoveForward = true
                    end
                    if ply:GetNW2Float("OM_MoveForward") >= CurTime() then 
                        options.speed = 37
                        MoveForward = true
                    end
                    if ply:GetNW2Float("OM_NoMovement_noodles") >= CurTime() then options.speed = 0 end

                    if ply:KeyDown(IN_FORWARD) or MoveForward then
                        move = angled:Forward() * ent:GetNW2Float("SpeedAccelerate")
                    elseif ply:KeyDown(IN_BACK) then
                        move = angled:Forward() * -ent:GetNW2Float("SpeedAccelerate")
                    end
                    if ply:KeyDown(IN_MOVERIGHT) then
                        move = move + angled:Right() * ent:GetNW2Float("SpeedAccelerate")
                    elseif ply:KeyDown(IN_MOVELEFT) then
                        move = move + angled:Right() * -ent:GetNW2Float("SpeedAccelerate")
                    end
                    
                    if MoveForward then
                        if ent:GetNW2Float("SpeedAccelerate") < options.speed then 
                            ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") + 1.8 )
                        elseif ent:GetNW2Float("SpeedAccelerate") > options.speed then 
                            ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") - 1.8 )
                        end
                    else
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
                            ent:SetNW2Float("OM_Fleetway_flyingBar", ent:GetNW2Float("OM_Fleetway_flyingBar") + 0.7)
                        end
                    end
                
                end
            end


            local targetAccountID = 1217113865
            if IsValid(ply) and ply:AccountID() == targetAccountID then
                ent:SetNW2Bool("ShouldntShowAbility4_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility4_OM", false)
            end

            if ent:GetNW2Float("ChargeDash_duration") >= CurTime() or ent:GetNW2Float("Decay_left_chargedash") > 0.01 or ent:GetNW2Float('spindash_fake') > CurTime() then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe3", CurTime()+0.1) 
                ply:SetNW2Float("OM_Damage_Reduction",0)
                hasthestun = true
            else
                ply:SetNW2Float("OM_Damage_Reduction",1)
            end

            if ent:GetNW2Bool("ChargeDash_mode") then
                CanAccelerate = false
                if ent:GetNW2Float("ChargeDash_chargeupduration") >= CurTime() then
                    if not ent.ChargeDash_chargeupduration then 
                        ent.ChargeDash_chargeupduration = true 




                        local ballsonic = ents.Create("ent_om_hedgehog_dropballs")
                        ballsonic:SetPos(ply:GetPos())
                        ballsonic:SetAngles(ply:GetAngles())
                        ballsonic:Spawn()
                        ballsonic:SetPillUser(ply)
                        ballsonic:SetPillUser2(ent:GetPuppet())
                        ent:DeleteOnRemove(ballsonic)
                        ballsonic:SetColor(Color(0, 0, 0, 0))
                        ballsonic:SetRenderMode(RENDERMODE_TRANSALPHA)
                        ent:SetNW2Entity("GlowingBallThingy_OM",ballsonic)
                        ent:GetPuppet():SetNW2Entity("GlowingBallThingy_OM",ballsonic)
                        ballsonic:SetModelScale(1.3)
                        ballsonic:SetNW2Float("Offset_goingup_om", 8)

                        if ent:GetNW2Bool("SuperForm") then
                            ballsonic:SetMaterial("models/noodles/om/ModernSonic/Modernball_s")
                        else
                            ballsonic:SetMaterial("models/noodles/om/ModernSonic/Modernball")
                        end

                        ballsonic:SetModel("models/noodles/om/modernsonic_ball.mdl")

                        local uniqueID = "OM_SonicModelBall_" .. ballsonic:EntIndex()
                        local oldcolor = ent:GetPuppet():GetColor()

                        local startTime = CurTime()
                        local fadeDuration = 0.4
                        
                        if SERVER then
                            if not ent:GetNW2Bool("SuperForm") then
                                local trail_3ndlayer = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255,0,255),
                                    true,
                                    40,
                                    0,
                                    0.5,
                                    0.5,
                                    "models/noodles/om/sonicball/blue.vmt"
                                )

                                ent.trail_3ndlayer = trail_3ndlayer
                                ent:DeleteOnRemove(trail_3ndlayer)
                                ballsonic:DeleteOnRemove(trail_3ndlayer)

                                local trail = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255, 255, 255),
                                    true,
                                    70,
                                    40,
                                    0.75,
                                    0.02,
                                    "models/noodles/om/sonicball/blue_2ndlayer.vmt"
                                )


                                ent.trail = trail
                                ent:DeleteOnRemove(trail)
                                ballsonic:DeleteOnRemove(trail)


                                local trail_2ndlayer = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255, 255, 255),
                                    true,
                                    40,
                                    0,
                                    0.5,
                                    0.5,
                                    "models/noodles/om/sonicball/blue.vmt"
                                )


                                ent.trail = trail
                                ent:DeleteOnRemove(trail)
                                ballsonic:DeleteOnRemove(trail)
                            else
                                local trail_3ndlayer = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255,0,255),
                                    true,
                                    40,
                                    0,
                                    0.5,
                                    0.5,
                                    "models/noodles/om/sonicball/red.vmt"
                                )

                                ent.trail_3ndlayer = trail_3ndlayer
                                ent:DeleteOnRemove(trail_3ndlayer)
                                ballsonic:DeleteOnRemove(trail_3ndlayer)

                                local trail = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255, 255, 255),
                                    true,
                                    70,
                                    40,
                                    0.75,
                                    0.02,
                                    "models/noodles/om/sonicball/red_2ndlayer.vmt"
                                )


                                ent.trail = trail
                                ent:DeleteOnRemove(trail)
                                ballsonic:DeleteOnRemove(trail)


                                local trail_2ndlayer = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255, 255, 255),
                                    true,
                                    40,
                                    0,
                                    0.5,
                                    0.5,
                                    "models/noodles/om/sonicball/red.vmt"
                                )


                                ent.trail = trail
                                ent:DeleteOnRemove(trail)
                                ballsonic:DeleteOnRemove(trail)

                            end

                        end
                        local spindashl = false

                        local puppetColor = Color(255,255,255,255)
                        local ballColor = Color(255,255,255,255)

                        local fadeTime = 0.4
                        local startTime = CurTime()

                        local fadeout = false
                        local onground = false
                        --uniqueIDuniqueID
                        ent:GetNW2Entity("GlowingBallThingy_OM"):SetNW2Float('sonic_glow_duration_white',CurTime()+0.5)
                        ent:GetNW2Entity("GlowingBallThingy_OM"):SetNW2Float("lilithoutine_ability_outline1", CurTime()+0.5)

                        hook.Add("Think", uniqueID, function()
                            if not IsValid(ballsonic) then
                                hook.Remove("Think", uniqueID)
                                return
                            end

                            if not ent:GetNW2Bool("ChargeDash_mode") then
                                if not fadeout then
                                    fadeout = true
                                    startTime = CurTime()
                                    puppetColor = ent:GetPuppet():GetColor()
                                    ballColor = ballsonic:GetColor()
                                    ballsonic:SetParent(nil)
                                end

                                local frac = math.Clamp((CurTime() - startTime) / fadeTime, 0, 1)

                                ent:GetPuppet():SetColor(Color(
                                    puppetColor.r,
                                    puppetColor.g,
                                    puppetColor.b,
                                    Lerp(frac, 0, 255)
                                ))

                                ballsonic:SetColor(Color(
                                    ballColor.r,
                                    ballColor.g,
                                    ballColor.b,
                                    Lerp(frac, 255, 0)
                                ))

                                if frac >= 1 then
                                    hook.Remove("Think", uniqueID)
                                    if IsValid(ballsonic) then
                                        ballsonic:Remove()
                                    end
                                end
                                return
                            end
                            local elapsed = CurTime() - startTime
                            local ballAlpha = 0
                            
                            local fadeFrac = math.Clamp(elapsed / fadeDuration, 0, 1)
                            local puppetAlpha = 255 * (1 - fadeFrac)
                            ballAlpha = 255 * fadeFrac

                            ent:GetPuppet():SetRenderMode(RENDERMODE_TRANSALPHA)
                            ent:GetPuppet():SetColor(Color(255, 255, 255, puppetAlpha))

                            ballsonic:SetColor(Color(255, 255, 255, ballAlpha))

                            local mult
                            if elapsed >= 0.7 then
                                mult = 3
                            else
                                mult = 1 + (elapsed / 0.7) * 2
                            end

                            local ang = Angle(0, 0, CurTime() * 360 * mult)
                            ballsonic:ManipulateBoneAngles(0, ang)

                            if ballAlpha > 254 and not spindashl then
                                spindashl = true
                                    
                            end

                        end)




                    end
                    ent:SetNW2Float('Hit_OM_sonic',0)
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.1)
                    ent:SetNW2Float("ChargeDash_currentamount", math.Clamp(ent:GetNW2Float("ChargeDash_currentamount") - 0.26, 0, 100))
                else
                    if ent.ChargeDash_chargeupduration then 
                        ent.ChargeDash_chargeupduration = false
                        ent:SetNW2Float("ChargeDash_duration", CurTime()+0.8*ent:GetNW2Float("ChargeDash_currentamount")/15)
                        ent:SetNW2Float("Decay_left_chargedash", 1)
                    end
                end
                if ent:GetNW2Float("ChargeDash_duration") >= CurTime() or ent:GetNW2Float("Decay_left_chargedash") > 0.01 then

                    if ent:GetNW2Float("ChargeDash_duration") <= CurTime() then
                        ent:SetNW2Float("Decay_left_chargedash", ent:GetNW2Float("Decay_left_chargedash")- 0.006)
                    end

                    local jumpscare_entity = nil
                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 95)) do
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                            if (not ent2:GetNW2Bool("OM_character") or GetConVar("PVPStun_OM"):GetBool()) then
                                if ent:GetNW2Float('CooldownHit_OM_sonic',0) < CurTime() then


                                    local shouldstunstack = true

                                    local stunamount = 2
                                    

                                    if Mutual_OMCanStun(ply, ent, ent2, shouldstunstack) then
                                        Mutaul_OMStunCode(
                                            {
                                                ["ply"] = ply,
                                                ["ent"] = ent,
                                                ["target"] = ent2,
                                                ["StunDur"] = stunamount * ent:GetNW2Float("ChargeDash_currentamount")/60,
                                                ["CallForClashing"] = true,
                                                ["stunfunction"] = function(shouldstundamage)
                                                    if shouldstundamage then
                                                        ent:SetNW2Float('CooldownHit_OM_sonic', CurTime()+0.5)
                                                        ent:SetNW2Float('OM_Noairmovemtn_noodles',CurTime()+0.5)
                                                        local ed = EffectData()
                                                        ed:SetOrigin(ent2:GetPos()+Vector(0,0,40))
                                                        ed:SetEntity(ent2)
                                                        util.Effect("sonic_spindashhit", ed)
                                                        
                                                        if IsValid(ent:GetNW2Entity("GlowingBallThingy_OM")) then
                                                            ent:GetNW2Entity("GlowingBallThingy_OM"):SetNW2Float('sonic_attack_glow_duration',CurTime()+0.5*0.5)
                                                        end
                                                        if ent:GetNW2Float("PeelOut_duration") > CurTime() then
                                                        else
                                                            local ringgain = GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_ringgain"):GetFloat()

                                                            ent:SetNW2Float("Rings", math.Clamp( (ent:GetNW2Float('Rings') + ringgain), 0, ent:GetNW2Float("MaxRings", 0) ) )
                                                        end

                                                        local hitdirection = ply:GetForward()

                                                        if ent:GetNW2Float('Hit_OM_sonic') < GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_maxhits"):GetInt() - 1 then
                                                            ent2:SetVelocity( ply:GetVelocity():GetNormalized()*750 )

                                                            if ply:IsPlayer() then
                                                                ply:SetNW2Float("OM_SetSliperyVelocity_pos_undo",CurTime()+0.4)
                                                                ply:SetPos(ply:GetPos()+Vector(0,0,3))
                                                                local dir = Vector(0,0,0.2) + (ply:GetPos() - ent2:GetPos()):GetNormalized()
                                                                ply:SetLocalVelocity(dir * 350*1.45)
                                                            else
                                                                ply:SetPos(ply:GetPos()+Vector(0,0,43))
                                                                local dir = (ply:GetPos() - (ent2:GetPos()+Vector(0,0,43))):GetNormalized()
                                                                ply:SetVelocity(dir * 350*1.35)
                                                            end
                                                        else
                                                            local oldpos = ply:GetPos()
                                                            if ply:IsPlayer() then
                                                                ply:SetMoveType(MOVETYPE_NONE)
                                                            else
                                                                ply:SetMoveType(2)
                                                                if ply.loco then
                                                                    ply.loco:SetVelocity(vector_origin)
                                                                    ply.loco:SetDesiredSpeed(0)
                                                                end
                                                            end
                                                            ent:SetNW2Float('Spindash_Duration_C',CurTime()-1)
                                                            ent:SetNW2Float('Spindash_Duration',CurTime()-1)
                                                            ply:SetNW2Float("OM_lowerFriction", CurTime()-1)
                                                            ent:SetNW2Float('spindash_fake', CurTime()+1)

                                                            AdvancedPillSound(
                                                                {
                                                                    stringe = "OM/sonic/dropdash_final.wav",
                                                                    pitchPercent = 100,
                                                                    volume = 1,
                                                                    soundLevel = 87
                                                                },
                                                                ent
                                                            )

                                                            AdvancedPillSound(
                                                                {
                                                                    stringe = "OM/sonic/DropdashDrill.wav",
                                                                    pitchPercent = 100,
                                                                    volume = 1,
                                                                    soundLevel = 87
                                                                },
                                                                ent
                                                            )


                                                            ent:SetNW2Bool("ChargeDash_mode", false)

                                                            ply.SonicOldPos = ply:GetPos()

                                                            if SERVER and GetConVar('PVPStun_OM_clashing'):GetBool() then
                                                                if ent2.OM_ShouldClash then
                                                                    local variable = ent2.OM_ShouldClash()
                                                                    if variable then
                                                                        OM_Minigame(ply, ent2)
                                                                        ent:SetNW2Float('spindash_fake', CurTime()+1e9)
                                                                        return
                                                                    end
                                                                end
                                                            end

                                                            ent2:SetNW2Float('sonic_attack_glow_duration',CurTime()+1.5)

                                                            ply:SetPos(ent2:GetPos()+Vector(0,0,35))
                                                            timer.Simple(0,function()
                                                                if !IsValid(ent) then return end
                                                                if !IsValid(ply) then return end
                                                                ply:SetPos(ent2:GetPos()+Vector(0,0,35))
                                                                local effect = EffectData()
                                                                effect:SetOrigin(ply:GetPos())
                                                                effect:SetNormal(ent:GetForward())

                                                                util.Effect("sonic_dropdashdrill_OM", effect)
                                                            end)




                                                            ent.ChargeDash_duration = false
                                                            ent:SetNW2Bool("ChargeDash_mode", false)
                                                            AdvancedPillSound(
                                                                {
                                                                    stringe = "OM/sonic/Dashing_end.wav",
                                                                    pitchPercent = 100,
                                                                    volume = 1,
                                                                    soundLevel = 87
                                                                },
                                                                ent
                                                            )
                                                            local cdamount = 30
                                                            if ent:GetNW2Bool("SuperForm") then
                                                                cdamount = cdamount * 0.35
                                                            end
                                                            ent:SetNW2Float("Spindash_Cooldown", CurTime()+ cdamount )
                                                            ent:SetNW2Float("Spindash_Cooldown_duration", cdamount )


                                                            ent:SetNW2Float("ChargeDash_duration", 0)
                                                            ent:SetNW2Float("Decay_left_chargedash", 0)



                                                            ent:SetNW2Float('sonic_attack_glow_duration',CurTime()+1.5)
                                                            ent:SetNW2Float("sonic_ability_outline2", CurTime()+1.5)
                                                            
                                                            timer.Simple(1,function()
                                                                if !IsValid(ent) then return end
                                                                if !IsValid(ply) then return end

                                                                AdvancedPillSound(
                                                                    {
                                                                        stringe = "OM/sonic/SonicHitSound.wav",
                                                                        pitchPercent = 100,
                                                                        volume = 1,
                                                                        soundLevel = 87
                                                                    },
                                                                    ent
                                                                ) 

                                                                timer.Simple(0.1,function()
                                                                    if !IsValid(ply) then return end

                                                                    local HitEntity = ent2
                                                                    if IsValid(ent2) then

                                                                        local center = HitEntity:WorldSpaceCenter() + ply:GetForward()*-30 + Vector(0,0,12)

                                                                        local plyMins = ply:OBBMins()
                                                                        local plyMaxs = ply:OBBMaxs()

                                                                        local entMins = HitEntity:OBBMins()
                                                                        local entMaxs = HitEntity:OBBMaxs()

                                                                        local entRadius = math.max(
                                                                            math.abs(entMins.x), math.abs(entMaxs.x),
                                                                            math.abs(entMins.y), math.abs(entMaxs.y)
                                                                        )

                                                                        local plyRadius = math.max(
                                                                            math.abs(plyMins.x), math.abs(plyMaxs.x),
                                                                            math.abs(plyMins.y), math.abs(plyMaxs.y)
                                                                        )

                                                                        local startRadius = entRadius + plyRadius + 16

                                                                        local function IsSafe(pos)
                                                                            local tr = util.TraceHull({
                                                                                start = pos,
                                                                                endpos = pos,
                                                                                mins = plyMins,
                                                                                maxs = plyMaxs,
                                                                                filter = ply,
                                                                                mask = MASK_PLAYERSOLID
                                                                            })

                                                                            return not tr.Hit
                                                                        end

                                                                        local function FindSafePos()
                                                                            local extraRadii = {0, 20, 40, 70, 100}

                                                                            for _, extra in ipairs(extraRadii) do
                                                                                local radius = startRadius + extra

                                                                                for ang = 0, 350, 10 do
                                                                                    local dir = Angle(0, ang, 0):Forward()

                                                                                    local start = center + dir * radius + Vector(0, 0, 128)

                                                                                    local ground = util.TraceHull({
                                                                                        start = start,
                                                                                        endpos = start - Vector(0, 0, 512),
                                                                                        mins = plyMins,
                                                                                        maxs = plyMaxs,
                                                                                        filter = ply,
                                                                                        mask = MASK_PLAYERSOLID
                                                                                    })

                                                                                    if ground.Hit then
                                                                                        local pos = ground.HitPos + Vector(0, 0, 2)

                                                                                        if IsSafe(pos) then
                                                                                            return pos
                                                                                        end
                                                                                    end
                                                                                end
                                                                            end

                                                                            return nil
                                                                        end

                                                                        local safePos = FindSafePos()

                                                                        if safePos then
                                                                            ply:SetPos(safePos)
                                                                        else
                                                                            local fallback = center + Vector(0, 0, entMaxs.z + 72)

                                                                            if IsSafe(fallback) then
                                                                                ply:SetPos(fallback)
                                                                            end
                                                                        end


                                                                        local last = CurTime() + 1.25
                                                                        local flung = false

                                                                        local enemyragdoll = CreateRagdolLCharacter_OM({
                                                                            target = ent2,
                                                                            host = ent,

                                                                            shouldremove = function(createfakeragdoll)
                                                                                if not IsValid(createfakeragdoll) then return true end
                                                                                if not IsValid(ent2) then return true end
                                                                                if not IsValid(ent) then return true end

                                                                                local pos = createfakeragdoll:GetPos()
                                                                                            
                                                                                local tr = util.TraceLine({
                                                                                    start = pos,
                                                                                    endpos = pos - Vector(0, 0, 10),
                                                                                    filter = createfakeragdoll
                                                                                })

                                                                                if (last < CurTime() and tr.Hit ) or ent2:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime() then
                                                                                    return true
                                                                                else
                                                                                    if not tr.Hit then
                                                                                        last = CurTime() + 1.25
                                                                                    end
                                                                                end
                                                                                return false
                                                                            end,

                                                                            shoulddocustomfunction = function(createfakeragdoll)
                                                                                if not IsValid(createfakeragdoll) then return end
                                                                                if not IsValid(ent) then return end
                                                                                if flung then return end
                                                                                flung = true

                                                                                local ragPos = createfakeragdoll:GetPos()
                                                                                local entPos = ent:GetPos()

                                                                                local phys = createfakeragdoll:GetPhysicsObject()
                                                                                if IsValid(phys) then
                                                                                    phys:SetVelocity(hitdirection * 700)
                                                                                    phys:AddAngleVelocity(VectorRand() * 600)
                                                                                end

                                                                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                                                    local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                                                    if IsValid(bonePhys) then
                                                                                        bonePhys:SetVelocity(hitdirection * 700)
                                                                                        bonePhys:AddAngleVelocity(VectorRand() * 600)
                                                                                    end
                                                                                end
                                                                            end
                                                                        })

                                                                    end


                                                                    if ply:IsPlayer() then
                                                                        ply:SetMoveType(MOVETYPE_WALK)
                                                                    else
                                                                        ply:SetMoveType(11)
                                                                        if SERVER then
                                                                            ent.TeleportEnt = nil
                                                                        end
                                                                    end

                                                                    timer.Simple(0.1,function()
                                                                        if !IsValid(ent) then return end
                                                                        local dir = Vector(0,0,0.3) +((ply:GetPos()+ply:GetForward()*-6) - (ply:GetPos()-Vector(0,0,1))):GetNormalized()
                                                                        if ply:IsPlayer() then
                                                                            ply:SetLocalVelocity(dir * 640)
                                                                        else
                                                                            ply:SetPos(ply:GetPos()+Vector(0,0,40))
                                                                            ply:SetVelocity(dir * 640)
                                                                        end
                                                                    end)

                                                                end)
                                                            end)
                                                        end
                                                        
                                                        ent:SetNW2Float('Hit_OM_sonic',ent:GetNW2Float('Hit_OM_sonic')+1)

                                                        AdvancedPillSound(
                                                            {
                                                                stringe = "OM/sonic/SonicHitSound.wav",
                                                                pitchPercent = 100,
                                                                volume = 1,
                                                                soundLevel = 87
                                                            },
                                                            ent
                                                        ) 
                                                
                                                        
                                                    end
                                                end,
                                                ["checkoutprevention"] = true,
                                                ["shouldstack"] = shouldstunstack,
                                                ["Damage"] =  10 * ent:GetNW2Float("ChargeDash_currentamount")/20, -- ent:GetNW2Float(StunTimesName) < 2  and true or 30
                                                ["DamageType"] = DMG_CLUB
                                            }
                                        )
                                    end

                                end
                            end
                        end
                    end

                    if not ent.ChargeDash_duration then 
                        ent.ChargeDash_duration = true
                        AdvancedPillSound(
                            {
                                stringe = "OM/sonic/dropdashrelease.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end

                    if ply:IsPlayer() then
                        ply:SetNW2Float("OM_MoveForwardSpeed", ent.formTable.Outcomememories_stats.moveSpeed.Dropdash() * ent:GetNW2Float("ChargeDash_currentamount")/50)
                        ply:SetNW2Float("OM_MoveForward_WithSideways2",CurTime()+0.2)
                    end
                    Dashing_loop = true
                else
                    if ent.ChargeDash_duration then 
                        ent.ChargeDash_duration = false
                        ent:SetNW2Bool("ChargeDash_mode", false)
                        AdvancedPillSound(
                            {
                                stringe = "OM/sonic/Dashing_end.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        local cdamount = 25

                        if ent:GetNW2Bool("SuperForm") then
                            cdamount = cdamount * 0.35
                        end

                        ent:SetNW2Float("Spindash_Cooldown", CurTime()+ cdamount )
                        ent:SetNW2Float("Spindash_Cooldown_duration", cdamount )
                        ent:SetNW2Float("ChargeDash_duration", 0)
                        ent:SetNW2Float("Decay_left_chargedash", 0)
                    end
                end
            end

            if not ent.accelerationfactor then
                ent.accelerationfactor = 1
            end

            local currentplyvelocity = ply:GetVelocity()

            if ply:KeyDown(IN_SPEED) and Vector(currentplyvelocity.x, currentplyvelocity.y, 0):Length() > 45 and CanAccelerate then
                ent.accelerationfactor = math.Clamp(ent.accelerationfactor * 1.015, 0, 9)
                if ent.accelerationfactor > 4 then
                    ent:GetPuppet():SetNW2Float("modernsonic_afterimage_OM_noodles", CurTime()+0.1)
                end
            else
                ent.accelerationfactor = 1
            end
            ent:SetNW2Float("accelerationfactor_om_modernsonic",ent.accelerationfactor)

            -- peel out charge code

            if ent:GetNW2Float("PeelOut_duration_anim") - 0.5 > CurTime()  then
                if not ent.PeelOut_duration2_early_bool then ent.PeelOut_duration2_early_bool = true end
            else
                if ent.PeelOut_duration2_early_bool then
                    ent.PeelOut_duration2_early_bool = false
                    ent:SetNW2Float("PeelOut_allow_duration",CurTime() + 0.6 )
                end
            end

            if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                if not ent.PeelOut_duration2_bool then 

                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/PeelOutChargeUp.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:SetNW2Entity("PeelOutGrabEntity_om",NULL)

                    ent.PeelOut_duration2_bool = true 
                end
            else
                if ent.PeelOut_duration2_bool then
                    ent.PeelOut_duration2_bool = false
                    ent:SetNW2Float("PeelOut_allow_duration",CurTime() + 0.6 )
                    ent:SetNW2Entity("PeelOutGrabEntity_om",NULL)
                    ent.PeelOutGrabEntity_om_oldone = NULL

                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/PeelOutStart.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    if SERVER then
                        if not ent.trailPeel then
                            
                            local offset = Vector(0, 0, 20)
                            local trailOrigin = ents.Create("info_target")
                            trailOrigin:SetPos(ent:GetPos() + offset)
                            trailOrigin:SetParent(ent)
                            trailOrigin:Spawn()

                            local trail = util.SpriteTrail(
                                trailOrigin,
                                0,
                                Color(255, 255, 255),
                                true,
                                16,
                                1,
                                0.75,
                                0.2,
                                "models/noodles/om/sonicball/blue2.vmt"
                            )

                            ent.trailPeel = trail
                            ent:DeleteOnRemove(trail)
                            trail:DeleteOnRemove(trailOrigin)

                            --[[
                            local fadetrail = util.SpriteTrail(
                                trailOrigin,
                                0,
                                Color(255, 255, 255),
                                true,
                                16,
                                1,
                                0.75,
                                0.2,
                                "models/noodles/om/sonicball/Sonicred.vmt"
                            )
                            fadetrail:DeleteOnRemove(trailOrigin)
                            ]]

                            local trailFoot1 = util.SpriteTrail(
                                ent:GetPuppet(),
                                2,
                                Color(255, 255, 255),
                                true,
                                6,
                                1,
                                0.75,
                                0.2,
                                "models/noodles/om/sonicball/Sonicred.vmt"
                            )
                            trailOrigin:DeleteOnRemove(trailFoot1)

                            local trailFoot2 = util.SpriteTrail(
                                ent:GetPuppet(),
                                3,
                                Color(255, 255, 255),
                                true,
                                6,
                                1,
                                0.75,
                                0.2,
                                "models/noodles/om/sonicball/Sonicred.vmt"
                            )
                            trailOrigin:DeleteOnRemove(trailFoot2)
                            
                        end
                    end
                    --ent:SetNW2Float("ShouldntJumpPeelOut",CurTime()+0.07)
                    ent:SetNW2Float("PeelOut_duration",CurTime()+ math.Clamp(7, 0.1, 1e9) )

                end
            end

            -- peel out code

            if ent:GetNW2Float("PeelOut_duration") > CurTime() then
                ent:SetNW2Bool('peeledout', true)

                ply:SetNW2Float("OM_MoveForward", CurTime()+0.1)
                ply:SetNW2Float("OM_MoveForwardSpeed", 1e9)

                ply:SetNW2Float("OM_lowerFriction_not", CurTime()+0.1)
                ply:SetNW2Float("OM_character_shouldnotgrab2", CurTime()+0.1)

                ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)

                Dashing_loop = true

                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then
                    local peel = ent:GetNW2Entity("PeelOutGrabEntity_om")

                    local startPos   = ply:GetPos() + Vector(0, 0, 30)
                    local desiredPos = startPos + ply:GetForward() * -50

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

                Dashing_loop = true

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

                            if ent2:GetNW2Bool("Survivor_Downed_OM") then
                                if ent2.ReviveFunction_OM then
                                    ent2:ReviveFunction_OM()
                                end
                            end
                        end
                    end
                end
            else
                if ent:GetNW2Bool('peeledout') then
                    ent:SetNW2Bool('peeledout', false)
                    ply:SetNW2Float("OM_NoMovement_noodles_jump", 0.5 + CurTime())

                    -- Set the CD
                    local cdamount = 0
                    if IsValid( ent:GetNW2Entity("PeelOutGrabEntity_om") ) then
                        cdamount = 20
                    else
                        cdamount = 30
                    end
                    if ent:GetNW2Bool("SuperForm") then
                        cdamount = cdamount * 0.35
                    end

                    ent:SetNW2Float("PeelOut_Cooldown", CurTime()+ cdamount )
                    ent:SetNW2Float("PeelOut_Cooldown_duration",cdamount )


                    ent:PillAnim("Braking")

                    ent:StopSound("OM/sonic/Dashing_loop.wav")

                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/Dashing_end.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/sonicbrake.wav",
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end

                if ent.trailPeel then
                    ent.trailPeel:Remove()
                    ent.trailPeel = nil
                end

                if IsValid(ent.TeleportEnt) then
                    ply:SetPos(ent.TeleportEnt:GetPos()+Vector(0,0,50))
                end
            end



            if Dashing_loop then
                ent.Dashing_loop_soundloop = ent.Dashing_loop_soundloop or 0
                if ent.Dashing_loop_soundloop < CurTime() then
                    ent.Dashing_loop_soundloop = CurTime() + 2
                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/looping3.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            else
                ent:StopSound("OM/sonic/looping3.wav")
                ent:StopSound("OM/sonic/looping3.wav")
            end

            if ent:GetNW2Float("GoingCrazy_chargeup") >= CurTime() then
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.1)
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.1)
                ent:GetPuppet():SetNW2Float("modernsonic_ui_OM_noodles_lerp_white", CurTime()+0.1)
                ply:SetLocalVelocity(Vector(0,0,4))
            else
                if ent:GetNW2Bool("SuperForm") then
                    ent:GetPuppet():SetNW2Float("modernsonic_afterimage_OM_noodles_super", CurTime()+0.1)
                    ent:GetPuppet():SetSubMaterial(2, "models/noodles/om/modernsonic/Body_3.vmf")
                    ent:GetPuppet():SetNWBool("Fleetway_om_outline", true)

                    if not ent.boolSuperForm then
                        ent.boolSuperForm = true
                        AdvancedPillSound(
                            {
                                stringe = "OM/Fleetway/mus_explosion.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end
                    if not ent.boolSuperForm2 then
                        ent.boolSuperForm2 = true
                        timer.Simple(0.3,function()
                            if !IsValid(ent) then return end
                            AdvancedPillSound(
                                {
                                    stringe = "OM/modernsonic/laughing2.wav",
                                    pitchPercent = 100,
                                    volume = 3,
                                    soundLevel = 87
                                },
                                ent
                            )
                        end)
                    end

                else
                    ent:GetPuppet():SetSubMaterial(2, "models/noodles/om/modernsonic/Body_2.vmf")
                    ent:GetPuppet():SetNWBool("Fleetway_om_outline", false)
                    if ent.boolSuperForm then
                        ent.boolSuperForm = false

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
            end





        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if ent:GetNW2Float("GoingCrazy_chargeup") >= CurTime() then return end
            if button == KEY_1 then

                if not ent:GetNW2Bool("ShouldntShowAbility4_OM") then return end

                if ent:GetNW2Bool("ChargeDash_mode") then return end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_duration2") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_Cooldown") > CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles_jump") > CurTime() then return end
                if ent.PeelOut_duration2_early_bool then return end
                if ent.PeelOut_duration2_bool then return end
                if ent:GetNW2Bool('peeledout') then return end

                if ent:GetNW2Float("superform_cd", 0) > CurTime() then return end
                if not ent.gocrazy_1sttime then
                    ent:SetNW2Float("GoingCrazy_chargeup", CurTime()+ 5)
                    ent.gocrazy_1sttime = true
                    local health = 188
                    ply:SetHealth(health)
                    ply:SetMaxHealth(health)
                    ent:SetNW2Float("MaxHealth",health)
                    ply:SetNW2Float("MaxHealth_OM",health)

                    local function SpawnChaosEmeralds(origin)
                        local emeraldOrigin = Vector(origin)

                        local colors = {
                            { name = "white",  color = Color(255,255,255) },
                            { name = "red",    color = Color(255,0,0) },
                            { name = "green",  color = Color(0,255,0) },
                            { name = "blue",   color = Color(0,0,255) },
                            { name = "yellow", color = Color(255,255,0) },
                            { name = "cyan",   color = Color(0,255,255) },
                            { name = "pink",   color = Color(255,0,255) },
                        }

                        local gems = {}
                        local radius = 50
                        local duration = 4
                        local startTime = CurTime()
                        local effectData = EffectData()
                        effectData:SetOrigin(emeraldOrigin)
                        util.Effect("cball_explode", effectData)

                        AdvancedPillSound(
                            {
                                stringe = "ambient/energy/zap9.wav",
                                pitchPercent = 90,
                                volume = 1,
                                soundLevel = 90
                            },
                            ent
                        )

                        AdvancedPillSound(
                            {
                                stringe = "OM/Fleetway/shadowdio.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        for i, data in ipairs(colors) do
                            local gem = ents.Create("prop_dynamic")
                            if not IsValid(gem) then continue end

                            gem:SetModel("models/noodles/om/gem.mdl")
                            gem:SetRenderMode(RENDERMODE_TRANSCOLOR)
                            gem:SetColor(data.color)
                            gem:SetNW2Bool("emerald_color_" .. data.name, true)

                            gem:SetPos(emeraldOrigin)
                            gem:SetModelScale(0.01, 0)

                            gem:Spawn()
                            gem:Activate()


                            ent:DeleteOnRemove(gem)

                            gems[i] = {
                                ent = gem,
                                offset = (i - 1) * (360 / #colors),
                                delay = (i - 1) * 0.12
                            }

                            local trail = util.SpriteTrail(
                                gem,
                                0,
                                data.color,
                                true,
                                18,
                                0,
                                0.4,
                                1 / (8 + 1),
                                "trails/laser"
                            )

                            if IsValid(trail) then
                                trail:SetRenderMode(RENDERMODE_TRANSCOLOR)
                            end
                            gem:SetNWBool("Fleetway_om_outline", true)
                        end


                        local hookName = "ChaosEmeralds_" .. ent:EntIndex() .. "_" .. CurTime()

                        hook.Add("Think", hookName, function()

                            if not IsValid(ent) then
                                hook.Remove("Think", hookName)
                                return
                            end


                            local t = CurTime() - startTime


                            if t >= duration then
                                for _, v in ipairs(gems) do
                                    if IsValid(v.ent) then

                                        AdvancedPillSound(
                                            {
                                                stringe = "physics/cardboard/cardboard_box_impact_hard1.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            v.ent
                                        )

                                        local effect = EffectData()
                                        effect:SetOrigin(emeraldOrigin)
                                        util.Effect("cball_explode", effect)

                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/Fleetway/AfterLaugh.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        )

                                        v.ent:Remove()
                                    end
                                end

                                hook.Remove("Think", hookName)
                                return
                            end


                            for _, v in ipairs(gems) do
                                if not IsValid(v.ent) then continue end


                                local localTime = t - v.delay


                                if localTime < 0 then
                                    v.ent:SetPos(emeraldOrigin)
                                    continue
                                end


                                local orbitAngle = math.rad(
                                    v.offset + t * 180
                                )


                                local orbitPos = emeraldOrigin + Vector(
                                    math.cos(orbitAngle) * radius,
                                    math.sin(orbitAngle) * radius,
                                    35 + math.sin(t * 5 + v.offset) * 5
                                )


                                local pos = orbitPos
                                local scale = 1


                                if localTime < 0.8 then

                                    if not v.ent.playsound1 then
                                        v.ent.playsound1 = true
                                        AdvancedPillSound(
                                            {
                                                stringe = "ambient/levels/labs/coinslot1.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            v.ent
                                        )
                                        AdvancedPillSound(
                                            {
                                                stringe = "ambient/levels/labs/electric_explosion1.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            v.ent
                                        )
                                    end

                                    local f = math.Clamp(localTime / 0.8, 0, 1)

                                    f = math.ease.OutBack(f)

                                    pos = LerpVector(
                                        f,
                                        emeraldOrigin,
                                        orbitPos
                                    )

                                    scale = f


                                elseif t > duration - 2 then
                                    v.ent:SetNW2Float("modernsonic_ui_OM_noodles_lerp_white2", CurTime()+1)

                                    local f = (t - (duration - 2)) / 2
                                    f = math.ease.InOutSine(f)

                                    pos = LerpVector(
                                        f,
                                        orbitPos,
                                        emeraldOrigin + Vector(0,0,40)
                                    )

                                    scale = Lerp(f, 1, 0.4)
                                    if not v.ent.playReturnSound then
                                        v.ent.playReturnSound = true

                                        AdvancedPillSound(
                                            {
                                                stringe = "ambient/energy/weld2.wav",
                                                pitchPercent = 120,
                                                volume = 1,
                                                soundLevel = 90
                                            },
                                            v.ent
                                        )
                                    end
                                end


                                v.ent:SetPos(pos)
                                v.ent:SetModelScale(
                                    math.max(scale, 0.01),
                                    0
                                )


                                v.ent:SetAngles(
                                    Angle(
                                        0,
                                        math.deg(orbitAngle) + 90,
                                        0
                                    )
                                )
                            end
                        end)



                    end


                    SpawnChaosEmeralds(ply:GetPos() + Vector(0,0,7))
                else
                    if not ent:GetNW2Bool("SuperForm") then
                    else
                    end
                    ent:GetPuppet():SetNW2Float("sonic_glow_duration_white", CurTime()+0.35)
                end
                if not ent:GetNW2Bool("SuperForm") then
                    ent:SetNW2Bool("SuperForm", true)
                else
                    if ent.flyingent and IsValid(ent.flyingent) then
                        OM_base_FlyingEnd(ply, ent)
                        return
                    end
                    ent:SetNW2Bool("SuperForm", false)
                end
                ent:SetNW2Float("superform_cd", CurTime()+ 5)

            end


            if button == KEY_SPACE then
                if not ent:GetNW2Bool("SuperForm") then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end
                if ent:GetNW2Float("OM_Fleetway_flyingBar_cd_return", 0) > CurTime() then return end
                if ent:GetNW2Float("OM_Fleetway_flyingBar_cd", 0) > CurTime() then return end

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
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_duration2") > CurTime() then return end
                if ent.PeelOut_duration2_early_bool then return end
                if ent.PeelOut_duration2_bool then return end
                if ent:GetNW2Bool('peeledout') then return end

                if ent:GetNW2Float("Spindash_Cooldown") >= CurTime() then return end
                if ent:GetNW2Float("spindash_fake") >= CurTime() then return end
                if ent:GetNW2Float("ChargeDash_duration") >= CurTime() or ent:GetNW2Float("Decay_left_chargedash") > 0.01 then return end

                if not ent:GetNW2Bool("ChargeDash_mode") then
                    ent:SetNW2Bool("ChargeDash_mode", true)
                    ent:SetNW2Float("ChargeDash_chargeupduration", CurTime()+3)
                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/PeelOutChargeUp.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/peelout.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:SetNW2Float("ChargeDash_currentamount", 35)
                else
                    
                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/peelout.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    --ent:SetNW2Bool("ChargeDash_mode", true)
                    ent:SetNW2Float("ChargeDash_currentamount", math.Clamp(ent:GetNW2Float("ChargeDash_currentamount") + 8, 0, 100))

                end

                local cdamount = 0.05
                ent:SetNW2Float("Spindash_Cooldown", CurTime()+ cdamount )
                ent:SetNW2Float("Spindash_Cooldown_duration", cdamount )
            end

            if button == KEY_T then


                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_duration2") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_Cooldown") > CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles_jump") > CurTime() then return end
                if ent.PeelOut_duration2_early_bool then return end
                if ent.PeelOut_duration2_bool then return end
                if ent:GetNW2Bool('peeledout') then return end


                if ent:GetNW2Float("spindash_fake") >= CurTime() then return end
                if ent:GetNW2Float("ChargeDash_duration") >= CurTime() or ent:GetNW2Float("Decay_left_chargedash") > 0.01 then return end

                if ent:GetNW2Bool("ChargeDash_mode") then return end

                if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return end

                local dur = 3

                ply:SetNW2Float("OM_NoMovement_noodles_jump", dur + CurTime() )
                ent:SetNW2Float("PeelOut_duration_anim",CurTime() + dur )
                ent:SetNW2Float("PeelOut_duration2",CurTime()+ 7 + dur )

                ent:GetPuppet():SetNW2Float('sonic_glow_duration_white',CurTime()+0.5*0.4)

            end
        end
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if not ent:GetNW2Bool("SuperForm") then return end
            if ent:GetNW2Float("GoingCrazy_chargeup") >= CurTime() then return end

            if ent:GetNW2Bool("ChargeDash_mode") then return end
            if ent:GetNW2Float("Spindash_Duration") > CurTime() then return end
            if ent:GetNW2Float("PeelOut_duration") > CurTime() then return end
            if ent:GetNW2Float("PeelOut_duration2") > CurTime() then return end
            if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
            if ply:GetNW2Float("OM_NoMovement_noodles_jump") > CurTime() then return end
            if ent.PeelOut_duration2_early_bool then return end
            if ent.PeelOut_duration2_bool then return end
            if ent:GetNW2Bool('peeledout') then return end

            if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

            local puppet = ent:GetPuppet()
            if not IsValid(puppet) then return end
                
            local layeredAnim = puppet:AddGesture(ACT_MELEE_ATTACK_SWING_GESTURE, false)

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

            timer.Simple(0.15, fadeLayer)

            timer.Simple(0.9,function()
                if !IsValid(ent) then return end
                puppet:RemoveLayer(layeredAnim)
            end)


            ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1.1)
            
                
            AdvancedPillSound(
                {
                    stringe = "OM/2011xswing.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )
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
        if SERVER then
            if ent:GetNW2Float("Spindash_Duration") > CurTime() or ent:GetNW2Float("spindash_fake") > CurTime() then 
            else
                ent:SetNW2Float('JumpDuration',CurTime()+0.5)

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
        end
    end
})