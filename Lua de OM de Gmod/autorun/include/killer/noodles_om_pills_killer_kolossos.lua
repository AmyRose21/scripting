
AddCSLuaFile()
--

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

            if ent.formTable then
                if ent.formTable.OM_subtitles then
                    if ent.formTable.OM_subtitles[chosenSound] then
                        for i, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():Distance(ent:GetPos()) < 2000 then

                                net.Start("OM_Subtitle_n")
                                    net.WriteString(ent.formTable.OM_subtitles[chosenSound])
                                net.Send(ply)

                            end
                        end
                    end

                end
            end
        end
        return true
    end
end

local function damagestun(ply, target, DamageNumb, damagetype, shoulddamage, damagesound, ShouldBlood)
    if SERVER then
        if damagesound then


                        AdvancedPillSound(
                            {
                                stringe = {"OM/Hurt"..math.random(1,3)..".wav"},
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            target
                        )

        end
        if ShouldBlood then
                if ply:IsPlayer() then
                    net.Start("Bloodeffect_killers_OM")
                    net.Send(ply)
                    net.Start("ShakeCamera_OM")
                    net.Send(ply)
                end
                if target:IsPlayer() then
                    net.Start("Bloodeffect_killers_OM")
                    net.Send(target)
                end

        end
        local dmg = DamageInfo()
        if shoulddamage then
        else
            DamageNumb = 0.1
        end
        dmg:SetDamage(DamageNumb)
        dmg:SetAttacker(ply)
        dmg:SetInflictor(ply)
        dmg:SetDamageType(damagetype)
        dmg:SetDamagePosition(target:GetPos())

        target:TakeDamageInfo(dmg)
    end
end

local preservedmats = {
    ["Kolossos_hi"] = Material("icons/Kolossos_hi.png"),
    ["KOLOSSOS_PUNCH"] = Material("icons/KOLOSSOS_PUNCH.png"),
    ["kolossos_block"] = Material("icons/kolossos_block.png"),
    ["kolossos_peek"] = Material("icons/kolossos_peek.png"),
}

local Indicator = {
    ["Border1"] = Material("icons/kolossos border indicator.png"),
    ["Border2"] = Material("icons/kol border layer 2 new.png"),
    ["Red"] = Material("icons/kol indicator remake red.png"),
    ["White"] = Material("icons/kol indicator remake white.png"),
}

pk_pills.register('pill_om_Kolossos', {

    printName='Kolossos',
    Outcomememories='Kolossos',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/Kolossos.mdl",

    camera={
        offset = Vector(0, 0, 40),
        dist=130,
    },

    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',
        
    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            jump2="jump",
            glide="fall",
            slaminwall="slaminwall",
            BlockStart= "BlockStart",
            BlackCounterMelee = "BlackCounterMelee",
            BlockProjectile = "BlockProjectile",
            Kill = "Kill",
        },

        ShouldMoveRotate={
            idle= function(ent) 
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "assignedagnles"
                end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then
                    return "shiftlock"
                end
                return 'notanything' 
            end,
            run= function(ent) 
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "assignedagnles"
                end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then
                    return "shiftlock"
                end
                return 'notshftlock' 
            end,
            walk= function(ent) 
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "assignedagnles"
                end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then
                    return "shiftlock"
                end
                return 'notshftlock' 
            end,
            jump= function(ent)
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "assignedagnles"
                end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then
                    return "shiftlock"
                end 
                return 'notshftlock'
            end,
            fall= function(ent)
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "assignedagnles"
                end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("Kolossos_BumpDuration") then
                    return 'notanything' 
                end
                return "notshftlock"
            end,

            BlackCounterMelee= function(ent)
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "assignedagnles"
                end
                return "notshftlock"
            end,

            BlockProjectile= function(ent)
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "assignedagnles"
                end
                return "notshftlock"
            end,
        },

        ShouldAlternate={
            fall = function(ent)
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stun"
                end
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    return "climb"
                end
                if ent:GetNW2Float("Kolossos_blocking") > CurTime() then
                    return "BlockPos"
                end
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "idle"
                end
                if ent:GetNW2Float("jump_animdur") > CurTime() then
                    return "jump"
                end
            end,
            idle= function(ent)
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stun"
                end
                if ent:GetNW2Float("Kolossos_blocking") > CurTime() then
                    return "BlockPos"
                end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then
                    return "chargestart"
                end
                if ent:GetNW2Float("Charging_kolossos") > CurTime() or ent:GetNW2Float("Charging_kolossos_losecontrol") > CurTime() then
                    return "charge_notimpaled"
                end 
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "idle"
                end
            end,
            walk= function(ent)
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stun"
                end
                if ent:GetNW2Float("Kolossos_blocking") > CurTime() then
                    return "BlockPos"
                end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then
                    return "chargestart"
                end 
                if ent:GetNW2Float("Charging_kolossos") > CurTime() or ent:GetNW2Float("Charging_kolossos_losecontrol") > CurTime() then
                    if #ent.OM_Kolossos_HitList > 0 then return "Charge_impaled" end
                    return "charge_notimpaled"
                end 
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "idle"
                end
            end,
            run= function(ent)
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stun"
                end
                if ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then
                    return "walk"
                end
                if ent:GetNW2Float("Kolossos_blocking") > CurTime() then
                    return "BlockPos"
                end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then
                    return "chargestart"
                end
                if ent:GetNW2Float("Charging_kolossos") > CurTime() or ent:GetNW2Float("Charging_kolossos_losecontrol") > CurTime() then
                    if #ent.OM_Kolossos_HitList > 0 then return "Charge_impaled" end
                    return "charge_notimpaled"
                end 
                if ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                    return "idle"
                end
                if ent:GetNW2Float("kolossos_grab_slowdown") > CurTime() then
                    return "walk"
                end
            end,
        },
        animrates = {
            fall = function(ent)
                if ent:GetNW2Bool("Kolossos_Climbing") then
                    if ent:GetNW2Bool("HoldingSpaceClimbClimb_up") then
                        return 1.5
                    end
                    if ent:GetNW2Bool("HoldingSpaceClimbClimb_down") then
                        return -1.5
                    end
                    return 0
                end

                return 1
            end,
            walk = function(ent)
                if ent:GetNW2Float("Charging_kolossos") > CurTime() or ent:GetNW2Float("Charging_kolossos_losecontrol") > CurTime() then
                    return 1.2
                end

                if ent:GetNW2Float("grabbing_kolossos") > CurTime() then
                    return 3
                end

                return 1
            end,

            run= function(ent)
                if ent:GetNW2Float("Charging_kolossos") > CurTime() or ent:GetNW2Float("Charging_kolossos_losecontrol") > CurTime() then
                    return 1.2
                end

                if ent:GetNW2Float("grabbing_kolossos") > CurTime() then
                    return 3
                end

                return 1.05
            end,
        }
    },
    
    OM_UI_custom1 = function(ply, ent)

        if not ent.OM_UI1_Intensity then
            ent.OM_UI1_Intensity = 0
        end
        
        if not ent.OM_UI2_Intensity then
            ent.OM_UI2_Intensity = 0
        end
        
        if not ent.OM_UI3_Intensity then
            ent.OM_UI3_Intensity = 0
        end

        if ent:GetNW2Float("OM_Kolossos_indicator") > CurTime() then
            if not ent.Toggle_Kolossos_indicator1 then
                ent.Toggle_Kolossos_indicator1 = true
                surface.PlaySound("OM/metal/Ping1.wav")
            end
        else
            if ent.Toggle_Kolossos_indicator1 then
                ent.Toggle_Kolossos_indicator1 = false

                for _, ent2 in ipairs(ents.GetAll()) do
                    ent2.OM_Kolossos_indicator_shouldplaysound_target = false
                end

            end
        end

        local target = ent:GetNW2Float("OM_Kolossos_indicator") > CurTime() and 1 or 0

        ent.OM_UI1_Intensity = math.Approach(
            ent.OM_UI1_Intensity,
            target,
            FrameTime() * 0.75
        )

        ent.OM_UI3_Intensity = math.Approach(
            ent.OM_UI3_Intensity,
            target,
            FrameTime() * 0.15
        )

        local rangedetectuser = math.Clamp(Lerp(ent.OM_UI3_Intensity, 0, 32000), 0, 32000)

        local i = ent.OM_UI1_Intensity

        if i <= 0 then
            if not ent.OM_Kolossos_indicator_shouldplaysound then
                ent.OM_Kolossos_indicator_shouldplaysound = true

            end
            return
        else
            if ent.OM_Kolossos_indicator_shouldplaysound then
                ent.OM_Kolossos_indicator_shouldplaysound = false
                if CLIENT then
                    surface.PlaySound("om/kolossos/kol whispers.wav")
                end
            end
        end
        
        cam.Start3D(EyePos(), EyeAngles())
            render.SuppressEngineLighting(true)
            render.FogMode(MATERIAL_FOG_NONE)

            for _, ent2 in ipairs(ents.GetAll()) do
                if not IsValid(ent2) then continue end
                if not (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) then continue end
                if ent2 == ply then continue end
                if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                if not ent2.OM_UI2_Intensity then
                    ent2.OM_UI2_Intensity = 0
                end

                if ent2:GetPos():Distance(ply:GetPos()) > rangedetectuser then
                    if not ent2.OM_Kolossos_indicator_shouldplaysound_target then
                        ent2.OM_Kolossos_indicator_shouldplaysound_target = true
                        ent2.OM_UI2_Intensity = 0
                    end
                    continue
                else
                    if ent2.OM_Kolossos_indicator_shouldplaysound_target then
                        ent2.OM_Kolossos_indicator_shouldplaysound_target = false
                        if CLIENT then
                            surface.PlaySound("OM/metal/Ping1.wav")
                        end
                    end
                end

                ent2.OM_UI2_Intensity = math.Approach(
                    ent2.OM_UI2_Intensity,
                    target,
                    FrameTime() * 2
                )

                local hp = ent2:Health() or 0
                if hp <= 0 then continue end

                local i = ent2.OM_UI2_Intensity

                local dist = ply:GetPos():Distance(ent2:GetPos())
                local Size = math.min(math.max(95 * dist / 400, 95), 2200)

                local pos = ent2:WorldSpaceCenter()

                cam.IgnoreZ(true)
                    render.SetBlend(0.65)

                    render.SetMaterial(Indicator["White"])
                    local eased = i * i * (3 - 2 * i)
                    local rotation = 45 * eased

                    render.DrawQuadEasy(
                        pos,
                        EyeAngles():Forward() * -1,
                        Size * 0.85,
                        Size * 0.85,
                        Color(255, 255, 255, 255 * i),
                        rotation
                    )

                    render.SetMaterial(Indicator["Red"])
                    render.DrawQuadEasy(
                        pos,
                        EyeAngles():Forward() * -1,
                        Size,
                        Size,
                        Color(255, 255, 255, 255 * i),
                        0
                    )

                    render.SetBlend(1)
                cam.IgnoreZ(false)
            end

            render.FogMode(MATERIAL_FOG_LINEAR)
            render.SuppressEngineLighting(false)
        cam.End3D()

        local screenW, screenH = ScrW(), ScrH()
        local iconsizew, iconsizeh = screenW/13, screenH/13

        surface.SetDrawColor(255, 255, 255, 255 * i)
        surface.SetMaterial(Indicator["Border1"])
        surface.DrawTexturedRect(0, 0, screenW, screenH)

        local shake = 0.2 * i
        local randomizerx = math.random(-20,20) / 100 * shake
        local randomizery = math.random(-20,20) / 100 * shake

        surface.SetMaterial(Indicator["Border2"])
        surface.DrawTexturedRect(
            0 - (iconsizew * 0.5) * randomizerx,
            0 - (iconsizeh * 0.5) * randomizery,
            screenW + iconsizew * randomizerx,
            screenH + iconsizeh * randomizery
        )
    end,


    OM_UI_custom_start = function(ply, ent)

        if not ent.OM_ColorModifyIntensity then
            ent.OM_ColorModifyIntensity = 0
        end

        local target = ent:GetNW2Float("OM_Kolossos_indicator") > CurTime() and 1 or 0

        ent.OM_ColorModifyIntensity = math.Approach(
            ent.OM_ColorModifyIntensity,
            target,
            FrameTime() * 0.75
        )

        local i = ent.OM_ColorModifyIntensity
        if i <= 0 then return end

        DrawColorModify({
            ["$pp_colour_addr"] = 0.35 * i,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = -0.13 * i,
            ["$pp_colour_contrast"] = 1 + ((0.85 - 1) * i),
            ["$pp_colour_colour"] = 1 - ((1 - 0.65) * i),
            ["$pp_colour_mulr"] = 0.25 * i,
            ["$pp_colour_mulg"] = -0.25 * i,
            ["$pp_colour_mulb"] = -0.25 * i
        })
    end,


    OM_cameratable = function(ply,ent)


        if not ent.OM_UI1_Intensity then
            ent.OM_UI1_Intensity = 0
        end

        local target = ent:GetNW2Float("OM_Kolossos_indicator") > CurTime() and 1 or 0

        ent.OM_UI1_Intensity = math.Approach(
            ent.OM_UI1_Intensity,
            target,
            FrameTime() * 0.75
        )

        local i = ent.OM_UI1_Intensity
        if ply:GetInfoNum("om_pills_action_camera_kolossos", 1) == 1 then
        else
            i = 0
        end
        local basetable =  {
            startoffset = Vector(20,0,5),  -- left-up, front-back, up-down
            dist=145,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 0,
            transition = 1,
            canscroll = true,
            bonecenter = "Head",
        }


        if ply:GetInfoNum("om_pills_action_camera_kolossos", 1) == 1 then

            if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then
                basetable =  {
                    startoffset = Vector(40,-35,50),
                    dist=35,
                    fov = 90,
                    id = 1,
                    transition = 1,
                    canscroll = true,
                }
            end
            if ent:GetNW2Float("Charging_kolossos") > CurTime() then
                basetable =  {
                    startoffset = Vector(40,0,50),
                    dist=60,
                    fov = 130,
                    id = 2,
                    transition = 1,
                    canscroll = true,
                }
            end
            if ent:GetNW2Float("grabbing_kolossos") > CurTime() then
            end
        end

        return basetable
    end,

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Kolosssos_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Kolosssos_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Kolosssos_walk"):GetFloat()
                end
            end,
            charging= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Kolosssos_charge"):GetFloat()
                end
            end,
            grab= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Kolosssos_grab"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Kolosssos_jumppower"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Kolosssos_jumpcd"):GetFloat()
                end
            end,
        },
    },

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Kolossos_hi"]
            end,
            name = function(uselessvar,ply,ent)
                return "Charge"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Furnace_abillty1_key", KEY_E) 
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("kolossos_charge_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 22
            end,
            survivor = false,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["KOLOSSOS_PUNCH"]
            end,
            name = function(uselessvar,ply,ent)
                return "Grab"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_kolossos_grab_key", KEY_R)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("kolossos_grab_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            survivor = false,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility3_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["kolossos_peek"]
            end,
            name = function(uselessvar,ply,ent)
                return "Indicator"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_kolossos_indicator_key", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("kolossos_indicator_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 14
            end,
            survivor = false,
            font = "CreditsText",
        },
        [4] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility4_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["kolossos_block"]
            end,
            name = function(uselessvar,ply,ent)
                return "Block"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_kolossos_block_key", KEY_I)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("kolossos_block_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 14
            end,
            survivor = false,
            font = "CreditsText",
        },
    },

    jumpPower=400,
       
    speedhandeler_om = {
        modifiers = {
            ['Function1'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("Charging_kolossos") > CurTime() or ent:GetNW2Float("Charging_kolossos_losecontrol") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.charging() - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.charging() - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.charging() - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
            ['Function2'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("grabbing_kolossos") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.grab()*1 - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.grab()*1 - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.grab()*1 - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
            ['Function3'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() or ent:GetNW2Float("kolossos_grab_slowdown") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1 - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1 - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1 - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
        }
    }, 
    
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },
        
    --canAim=function(ply,ent) return ent.active end,     

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if event == "Step" then
            AdvancedPillSound(
                {
                    stringe = {
                        "OM/kolossos/kol step 1.wav",
                        "OM/kolossos/kol step 2.wav",
                        "OM/kolossos/kol step 3.wav",
                    },
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )
            if ent:GetNW2Float("Charging_kolossos") > CurTime() or ent:GetNW2Float("Charging_kolossos_losecontrol") > CurTime() then
                local ed = EffectData()
                ed:SetOrigin(ply:GetPos() + ply:GetForward()*60)
                util.Effect("kolossos_charging_step", ed)
                --[[
                    local ed = EffectData()
                    ed:SetOrigin(Vector(0,0,0))

                    util.Effect("kolossos_impact_effect", ed, true, true)
                ]]
            end

            
        end
        if event == "Attack" then
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end
            if SERVER then


                local nearest
                local nearestDist = math.huge

                local forward = 10
                local AttackRadius = 110

                local attackPos = ent:LocalToWorld(Vector(0, 0, 50)+ent:GetPuppet():GetForward()*forward)

                for _, ent2 in pairs(ents.FindInSphere(attackPos, AttackRadius)) do
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if not GetConVar("PVPStun_OM_exe"):GetBool() then
                            if ent2:GetNW2Bool("OM_character_monster") then continue end
                        end

                        if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                        if not Mutal_OMCanDamage(ply, ent, ent2) then continue end

                        local dist = attackPos:DistToSqr(ent2:GetPos())

                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = ent2
                        end
                    end
                end

                if nearest and IsValid(nearest) then
                    KillerdamagestunDynamic({
                        ply = ply,
                        target = nearest,
                        DamageNumb = GetConVar("OUTCOMEMEMORIES_N_Kolosssos_Damage"):GetFloat(),
                        damagetype = DMG_CLUB,
                        CustomDamageSound = nil,
                        damagesound = true,
                        ShouldBlood = true,
                        flingremoveal = true,
                        ShouldBloodEffect = true
                    })
                end
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_killer_om(initializetable2["entity"])
        if SERVER then
            initializetable2["entity"]:SetNW2Float('OM_friction', 1)
            if GetConVar("OUTCOMEMEMORIES_N_Kolosssos_HasHealth"):GetBool() then
                initializetable2["player"]:GodDisable()
            end
            initializetable2["player"]:SetHealth(GetConVar("OUTCOMEMEMORIES_N_Kolosssos_Health"):GetFloat())
            initializetable2["player"]:SetMaxHealth(GetConVar("OUTCOMEMEMORIES_N_Kolosssos_Health"):GetFloat())
            --
            initializetable2["entity"]:SetNW2Float("MaxHealth",GetConVar("OUTCOMEMEMORIES_N_Kolosssos_Health"):GetFloat())
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",GetConVar("OUTCOMEMEMORIES_N_Kolosssos_Health"):GetFloat())

            initializetable2["player"]:SetNW2Bool("OM_character_monster", true)

            initializetable2["player"]:SetNW2String("TerrorRadius_om","OM/music/Kolossosradius.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life1_om","OM/music/KolossosChaseMusic.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life2_om","OM/music/Kolossoschaselast.wav")
            initializetable2["entity"].OM_Kolossos_HitList = {}




            initializetable2["player"].OM_StunFunction = function()
                local ent = initializetable2["entity"]
                local ply = initializetable2["player"]
                if !IsValid(ent) then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end
                ent:SetNW2Float("Charging_kolossos", 0)
                ent:SetNW2Float("Charging_kolossos_losecontrol", 0)
                ent:GetPuppet():RemoveGesture(ACT_HOVER, false)

                timer.Simple(0.1,function()
                    if !IsValid(ent) then return end
                    if IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) and ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then
                        if not ent:GetNW2Bool("GrabToggle_OM") then
                            ent:GetPuppet():RemoveGesture(ACT_HOVER, false)
                            ent:SetNW2Bool("GrabToggle_OM", true)

                            local puppet = ent:GetPuppet()
                            if IsValid(puppet) then
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/kolossos/kol sting and pull out.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                local layeredAnim = puppet:AddGesture(ACT_DISARM, false)

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
                                        timer.Simple(0.0005, fadeLayer)
                                    end
                                end

                                timer.Simple(0.15, fadeLayer)

                                timer.Simple(0.9,function()
                                    if !IsValid(ent) then return end
                                    puppet:RemoveLayer(layeredAnim)
                                end)
                                ent:SetNW2Entity("grabbingEnt_kolossos", NULL)
                                
                            end

                        end
                    end
                end)
            end


            initializetable2["player"].CustomFunctionForDowning_OM = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if IsValid(initializetable2["entity"]) then
                    timer.Simple(0.15,function()
                        if !IsValid(initializetable2["entity"]) then return end
                        AdvancedPillSound(
                            {
                                stringe = "OM/Kolossos/Kolossos laughing.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            initializetable2["entity"]
                        )
                    end)
                end
            end

            initializetable2["player"].OM_AttacterCustomFunction = function(table1, table2)

                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]

                    if ent:GetNW2Float("Charging_kolossos") > CurTime() then
                        if entityfall:Health()-damageamount < GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeImpaleDamage"):GetFloat() then
                            entityfall:SetHealth(GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeImpaleDamage"):GetFloat())
                            dmg:SetDamage(0.1)
                            return
                        end
                    end
                    if ent:GetNW2Float("Kolossos_considered_slam") > CurTime() then
                        if entityfall:Health()-damageamount < GetConVar("OUTCOMEMEMORIES_N_Kolosssos_slamDamage"):GetFloat() then
                            entityfall:SetHealth(GetConVar("OUTCOMEMEMORIES_N_Kolosssos_slamDamage"):GetFloat())
                            dmg:SetDamage(0.1)
                            return
                        end
                    end


                    if GetConVar("om_pills_action_2ndlife"):GetBool() then
                        if entityfall:GetNW2Bool("SecondLife_OM") and not entityfall:GetNW2Bool("OnSecondLife_OM") then return end
                    end
                    if entityfall:GetNW2Float("Dead_OM") > CurTime() then return end
                    if dmg:GetDamageType() ~= DMG_CLUB then return end
                    if entityfall:Health() - damageamount <= 0.5 then
                        if entityfall:GetNW2Bool("MetalBeing_OM") then
                            initializetable2["entity"]:SetNW2Bool("DownedMetalSonic_OM", true)
                            return end
                        local ent = initializetable2["entity"]
                        local ply = initializetable2["player"]


                        if ent.flyingent and IsValid(ent.flyingent) then
                            ent.flyingent:Remove()
                        end

                        if ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then
                            ent:SetNW2Bool("GrabToggle_OM", true)
                            ent:GetPuppet():RemoveGesture(ACT_HOVER, false)
                        end

                        initializetable2["entity"]:PillAnim("Kill")
                        local anim = ent:GetPuppet():LookupSequence("Kill")
                        local dur = ent:GetPuppet():SequenceDuration(anim)
                        initializetable2["entity"]:SetNW2Float("OM_executionanim", CurTime()+dur)
                        initializetable2["player"]:SetNW2Float("OM_NoMovement_noodles", CurTime()+dur)

                        initializetable2["entity"]:SetNW2Float("DisablePlayerMovement_OM_stun_iframe1", CurTime()+dur)
                        
                        entityfall:SetNW2Float("OM_NoDamagePrevention", CurTime()+dur)
                        dmg:SetDamage(0)

                        timer.Simple(0.5,function()
                            if !IsValid(initializetable2["entity"]) then return end
                        end)


                        if entityfall.loco then
                            entityfall.loco:SetVelocity(vector_origin)
                            entityfall.loco:SetDesiredSpeed(0)
                        end
                        if entityfall:IsNPC() or entityfall:IsNextBot() then
                            entityfall:NextThink(CurTime() + dur)
                        end


                        local character = ""
                        if entityfall:IsPlayer() and entityfall.pk_pill_ent then
                            character = entityfall.pk_pill_ent.formTable.printName
                        end
                        if entityfall.formTable then
                            character = entityfall.formTable.printName
                        end
                        local dur = 1.65
                        timer.Simple(dur,function()
                            if !IsValid(initializetable2["entity"]) then return end
                            if !IsValid(entityfall) then return end
                            ent:SetNW2Float("Dead_OM", CurTime()+0.1)
                            entityfall:SetNW2Float("OM_NoDamagePrevention", 0)
                            damagestun(ply, entityfall, 1e9, DMG_GENERIC, true)
                            damagestun(ply, entityfall, 1e9, DMG_CRUSH, true)
                            damagestun(ply, entityfall, 1e9, DMG_BULLET, true)
                            damagestun(ply, entityfall, 1e9, DMG_SLASH, true)
                            ent:SetNWBool("JumpscareAnim_om_boolean2", false)

                            timer.Simple(1, function()
                                if !IsValid(initializetable2["entity"]) then return end
                                AdvancedPillSound(
                                    {
                                    stringe = "OM/Kolossos/Kolossos laughing.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    initializetable2["entity"]
                                )
                            end)
                        end)
                        ent:SetNWBool("JumpscareAnim_om_boolean2", true)

                        local enemyragdoll = CreateRagdolLCharacter_OM({
                            target = entityfall,
                            host = ent,

                            shouldremove = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return true end
                                if not IsValid(entityfall) then return true end
                                if not IsValid(ent) then return true end
                                if ent:GetNW2Float("OM_executionanim") < CurTime() then
                                    return true
                                end

                                return false
                            end,

                            shoulddocustomfunction = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return end

                                local puppet = ent:GetPuppet()
                                if not IsValid(puppet) then return end

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

                                if not IsValid(headPhys) then headPhys = createfakeragdoll:GetPhysicsObject() end
                                if not IsValid(headPhys) then return end

                                local bone = puppet:LookupBone("RightHand")
                                if not bone then return end

                                local pos, ang = puppet:GetBonePosition(bone)
                                if not pos then return end

                                if not ent:GetNWBool("JumpscareAnim_om_boolean2") then return true end
                                headPhys:SetPos(pos)
                                headPhys:SetAngles(ang)
                                headPhys:SetVelocityInstantaneous(vector_origin)
                                headPhys:Wake()
                            end

                        })

                    end
                end
            end

            initializetable2["player"].OM_DamageBeforeBeforeCustomFunction = function(useless, datainfo)
                local ent = initializetable2["entity"]
                if !IsValid(ent) then return end
                if ent:GetNW2Float("Kolossos_blocking") > CurTime() then
                    if datainfo[2]:GetAttacker() and IsValid(datainfo[2]:GetAttacker()) then else return end
                    if datainfo[2]:GetAttacker() == initializetable2["player"] then return end
                    if datainfo[2]:GetAttacker():IsPlayer() or datainfo[2]:GetAttacker():IsNPC() or datainfo[2]:GetAttacker():IsNextBot() then else return end
                    datainfo[2]:SetDamage(0)
                    datainfo[2]:SetDamageType(DMG_GENERIC)
                    initializetable2["player"].OM_AfterStunBlock({
                            ["ply"] = datainfo[2]:GetAttacker(),
                            ["ent"] = datainfo[2]:GetAttacker(),
                            ["target"] = datainfo[1],
                            ["StunDur"] = 1,
                            ["Damage"] = 1,
                            ["DamageType"] = DMG_GENERIC
                        }
                    )
                end
            end

            initializetable2["player"].OM_AfterStunBlock = function(DataTable, StunStatus)

                local tableofitemz = {}

                -- stun data
                if DataTable.ply then tableofitemz["ply"] = DataTable.ply end
                if DataTable.ent then tableofitemz["ent"] = DataTable.ent end
                if DataTable.target then tableofitemz["target"] = DataTable.target end
                if DataTable.StunDur then tableofitemz["StunDur"] = DataTable.StunDur else tableofitemz[StunDur] = 1 end
                if DataTable.stunfunction then tableofitemz["stunfunction"] = DataTable.stunfunction end
                if DataTable.shouldstack then tableofitemz["shouldstack"] = DataTable.shouldstack end

                -- damage data
                if DataTable.Damage then tableofitemz["Damage"] = DataTable.Damage else tableofitemz[Damage] = 25 end
                if DataTable.DamageType then tableofitemz["DamageType"] = DataTable.DamageType else tableofitemz[DamageType] = DMG_CLUB end
                if not DataTable.ply then return end
                if not DataTable.ent then return end
                if not DataTable.target then return end

                local ent = initializetable2["entity"]
                local ply = initializetable2["player"]
                if !IsValid(ent) then return end

                if ent:GetNW2Float("Kolossos_blocking") > CurTime() then
                    ent:SetNW2Bool("Kolossos_inblock", true)
                    ent:SetNW2Float("Kolossos_blocking", 0)

                    local ply = initializetable2["player"]
                    ent:SetNW2Float("BlockingTime!_kolo_om", CurTime()+1)
                    ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 1)
                    local targetpos_block = DataTable.ply:GetPos()
                    local ang = (targetpos_block - ent:GetPuppet():GetPos()):Angle()
                    ang.p = 0
                    ang.r = 0
                    ent:SetNW2Angle("pill_assignedangle",ang)

                    local lungeduration = CurTime() + 0.75
                    local gotflinged = CurTime() + 2
                    local notflinged = true

                    local enemyragdoll = CreateRagdolLCharacter_OM({
                        target = DataTable.ply,
                        host = ent,

                        shouldremove = function(createfakeragdoll)
                            if not IsValid(ent) then return true end
                            if not IsValid(createfakeragdoll) then
                                ent:SetNW2Bool("Kolossos_inblock", false)
                                return true end
                            if not IsValid(DataTable.ply) then
                                ent:SetNW2Bool("Kolossos_inblock", false)
                                return true end

                            if gotflinged < CurTime() then
                                ent:SetNW2Bool("Kolossos_inblock", false)
                                return true end

                            return false
                        end,
                        shoulddocustomfunction = function(createfakeragdoll)
                            if lungeduration > CurTime() then return end
                            if not notflinged then return end
                            notflinged = false
                            if !IsValid(createfakeragdoll) then return end

                            local phys = createfakeragdoll:GetPhysicsObject()
                            if !IsValid(phys) then return end

                            local dir = (createfakeragdoll:GetPos() - ent:GetPos()):GetNormalized()

                            phys:SetVelocity(dir * 3000)
                        end,
                    })

                    if ply:GetPos():Distance(DataTable.ply:GetPos()) < 300 then -- BlockProjectileBlockProjectile
                        timer.Simple(0.35, function()
                            if !IsValid(ent) then return end
                            if !IsValid(DataTable.ply) then return end
                            if ent.PillAnim then
                                ent:PillAnim("BlackCounterMelee")
                            end

                            local travelTime = 0.1
                            local startTime = CurTime()
                            local ogpos = ent:GetPos()
                            local targetpos_block_direction = (targetpos_block - ent:GetPuppet():GetPos()):GetNormalized()

                            local hookName = "MoveRockArc2_" .. ent:EntIndex()

                            hook.Add("Think", hookName, function()
                                if not IsValid(ent) then
                                    hook.Remove("Think", hookName)
                                    return
                                end

                                local frac = math.Clamp((CurTime() - startTime) / travelTime, 0, 1)
                                ply:SetPos(LerpVector(frac, ogpos, ogpos+targetpos_block_direction*-90))

                                if frac >= 1 then
                                    hook.Remove("Think", hookName)
                                end
                            end)
                            timer.Simple(0.4,function()
                                if !IsValid(ent) then return end
                                if !IsValid(DataTable.ply) then return end


                                local travelTime = 0.75 - 0.45
                                local startTime = CurTime()
                                local ogpos = ply:GetPos()

                                local hookName = "MoveRockArc1_" .. ent:EntIndex()

                                hook.Add("Think", hookName, function()
                                    if not IsValid(ent) then
                                        hook.Remove("Think", hookName)
                                        return
                                    end

                                    local frac = math.Clamp((CurTime() - startTime) / travelTime, 0, 1)
                                    ply:SetPos(LerpVector(frac, ogpos, targetpos_block))

                                    if frac >= 1 then
                                        hook.Remove("Think", hookName)
                                    end
                                end)
                            end)

                        end)
                        timer.Simple(0.75, function()
                            if !IsValid(ent) then return end
                            if !IsValid(DataTable.ply) then return end

                            local effectData = EffectData()
                            local direction = (ent:GetPos() - DataTable.ply:GetPos()):GetNormalized()
                            effectData:SetOrigin(DataTable.ply:GetPos()+Vector(0,0,25) + direction*-80)
                            local direction = (ent:GetPos()+Vector(0,0,5) - DataTable.ply:GetPos()):GetNormalized()
                            effectData:SetNormal(direction*1)
                            effectData:SetScale(2)

                            util.Effect("kolossos_charging_blood", effectData, true, true)
                            
                            local ed = EffectData()
                            ed:SetOrigin(DataTable.ply:GetPos()+Vector(0,0,25))

                            util.Effect("kolossos_impact_effect", ed, true, true)


                            AdvancedPillSound(
                                {
                                    stringe = "OM/kolossos/kolossos punching.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                        end)

                    else
                        timer.Simple(0.25, function()
                            if !IsValid(ent) then return end
                            if !IsValid(DataTable.ply) then return end
                            if ent.PillAnim then
                                ent:PillAnim("BlockProjectile")
                                lungeduration = CurTime()+ 1
                                ent:SetNW2Float("BlockingTime!_kolo_om", CurTime()+2)
                            end
                        end)
                        timer.Simple(0.75, function()
                            if not IsValid(ent) then return end
                            if not IsValid(DataTable.ply) then return end

                            local rock = ents.Create("prop_physics")
                            if not IsValid(rock) then return end

                            rock:SetModel("models/props_wasteland/rockgranite03b.mdl")

                            local ogpos = ent:GetPos() - Vector(0, 0, 30)
                            local targetpos_block = DataTable.ply:GetPos()

                            rock:SetPos(ogpos)
                            rock:Spawn()
                            rock:SetMoveType(MOVETYPE_NONE)
                            rock:SetModelScale(3)

                            ent:DeleteOnRemove(rock)

                            rock:SetRenderMode(RENDERMODE_TRANSCOLOR)
                            rock:SetColor(Color(255, 255, 255, 255))

                            local travelTime = 0.5
                            local startTime = CurTime()
                            local peakHeight = 150

                            local hookName = "MoveRockArc_" .. rock:EntIndex()

                            hook.Add("Think", hookName, function()
                                if not IsValid(rock) then
                                    hook.Remove("Think", hookName)
                                    return
                                end

                                local frac = math.Clamp((CurTime() - startTime) / travelTime, 0, 1)

                                local pos = LerpVector(frac, ogpos, targetpos_block)

                                local arcHeight = math.sin(frac * math.pi) * peakHeight
                                pos = pos + Vector(0, 0, arcHeight)

                                rock:SetPos(pos)

                                local ang = rock:GetAngles()

                                ang.p = ang.p + FrameTime() * 720
                                ang.y = ang.y + FrameTime() * 1080
                                ang.r = ang.r + FrameTime() * 540

                                rock:SetAngles(ang)

                                if frac >= 1 then
                                    if IsValid(DataTable.ply) and IsValid(ply) then
                                        damagestun(ply, DataTable.ply, 35, DMG_CLUB, true)
                                        
                                        rock:EmitSound("physics/concrete/concrete_break4.wav", 85, 90)
                                        rock:EmitSound("physics/body/body_medium_impact_hard6.wav", 75, 80)

                                        local ed = EffectData()
                                        ed:SetOrigin(rock:GetPos()+Vector(0,0,5))
                                        util.Effect("kolossos_charging_step", ed)

                                    end

                                    rock:Remove()
                                    hook.Remove("Think", hookName)
                                end
                            end)
                        end)
                    end

                    return "cancelstun"
                else
                    if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) < CurTime() then
                        AdvancedPillSound({
                            stringe = {
                                "OM/kolossos/kol stun 1 (1).wav",
                                "OM/kolossos/kol stun 2 (1).wav",
                                "OM/kolossos/kol stun 3 (1).wav",
                                "OM/kolossos/kol stun 4 (1).wav"
                            },
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 76
                        }, ent)
                        ent:SetNW2Bool("Kolossos_Climbing", false)
                        ent:SetNW2Bool("HoldingSpaceClimb", false)
                    end
                end
            end

        end


    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetGravity(1)
        end
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)

            if not GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanCharge"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
            end
            if not GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanGrab"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
            end
            if not GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanIndicator"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility3_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility3_OM", false)
            end
            if not GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanBlock"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility4_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbilit4_OM", false)
            end
            ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_Kolosssos_Resistance"):GetFloat()/100)

            if ent:GetNW2Float("OM_executionanim") > CurTime() then
                ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                ent:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                if not ent:GetNW2Bool("OM_executionanimToggle") then
                    if ply:IsPlayer() then ply:SetMoveType(0) else ply:SetMoveType(0) end
                    ent:SetNW2Bool("OM_executionanimToggle", true)
                end
            else

                if ent:GetNW2Bool("OM_executionanimToggle") then
                    if ply:IsPlayer() then ply:SetMoveType(2) else ply:SetMoveType(0) end
                    ent:SetNW2Bool("OM_executionanimToggle", false)
                end
            end



            if ent:GetNW2Float("Kolossos_blocking") > CurTime() then
                ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.15)
            end

            if ent:GetNW2Bool("Kolossos_BumpDuration") then
                if ply:IsOnGround() then
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.2)
                    ent:SetNW2Bool("Kolossos_BumpDuration", false)
                    ent:SetNW2Bool("Kolossos_BumpDuration_toggle", true)
                end
            else
                if ent:GetNW2Bool("Kolossos_BumpDuration_toggle") then
                    ent:SetNW2Bool("Kolossos_BumpDuration_toggle", false)
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.5)
                    ply:SetLocalVelocity(ply:GetForward()*1)
                end
            end
            
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") > CurTime() or ent:GetNW2Float("OM_executionanim") > CurTime() then
                ply:SetNW2Float("OM_Damage_Reduction",0)
            else
                ply:SetNW2Float("OM_Damage_Reduction",1)
            end

            if ent:GetNW2Float("Charging_kolossos") > CurTime() or ent:GetNW2Float("grabbing_kolossos") > CurTime() or ent:GetNW2Float("chargestart_Kolossos") > CurTime() or ent:GetNW2Float("BlockingTime!_kolo_om") > CurTime() then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
            end

            if ent:GetNW2Float("Charging_kolossos") > CurTime() or ent:GetNW2Float("Charging_kolossos_losecontrol") > CurTime() then
                ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                if not ent.setcd_charge_kolo then
                    ent.setcd_charge_kolo = true
                end
                            
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then
                    ply:SetNW2Float("OM_MoveForward", CurTime() + 0.2)

                    local vector2 = ply:GetForward() * ent.formTable.Outcomememories_stats.moveSpeed.charging()
                    vector2.z = 0
                    ply:SetNW2Vector("OM_SetVelocity_Vector", vector2)
                    ent:SetNW2Vector("Kolossos_Charge_forward", ply:GetForward())

                elseif ent:GetNW2Float("Charging_kolossos_losecontrol") > CurTime() then
                    ply:SetNW2Float("OM_SetVelocity_pos", CurTime() + 0.2)

                    local startPos = ply:GetPos()

                    local currentVec = ply:GetNW2Vector("OM_SetVelocity_Vector", ply:GetForward())
                    local currentDir = currentVec:GetNormalized()
                    currentDir:Normalize()

                    local forward = ply:GetForward()
                    forward.z = 0
                    forward:Normalize()

                    local bestDir = ent:GetNW2Vector("Kolossos_Charge_forward")

                    if bestDir then
                        local steerStrength = 0.1

                        local newDir = LerpVector(steerStrength, currentDir, bestDir)
                        newDir.z = 0
                        newDir:Normalize()

                        local gravity = physenv.GetGravity()
                        local currentVel = ply:GetVelocity()

                        local finalVel = newDir * ent.formTable.Outcomememories_stats.moveSpeed.charging()
                        finalVel.z = gravity.z*0.65

                        ply:SetNW2Vector("OM_SetVelocity_Vector", finalVel)
                    end
                end

                local speed = ent.formTable.Outcomememories_stats.moveSpeed.charging()
                ply:SetNW2Float("OM_MoveForwardSpeed", speed )

                local startPos = ply:GetPos()+Vector(0,0,25)
                local endpos = startPos+ent:GetPuppet():GetForward() * 65

                local tr = util.TraceHull({
                    start = startPos,
                    endpos = endpos,
                    mask = MASK_SOLID,
                    mins = Vector(-10, -10, 0),
                    maxs = Vector(10, 10, 10),
                    filter = function(hitEnt)
                        if hitEnt == ent then return false end
                        if hitEnt == ent:GetPuppet() then return false end
                        if hitEnt:IsPlayer() then return false end
                        if hitEnt:IsNPC() then return false end
                        if hitEnt:IsNextBot() then return false end
                        if hitEnt.OMRagdoll then return false end
                        local ishitentity = false
                        for i,v in ipairs(ent.OM_Kolossos_HitList) do
                            if v == hitEnt then ishitentity = true end
                        end 
                        if ishitentity then
                            return false
                        end
                        return true
                    end
                })

                if tr.Hit then

                    local hitNormal = tr.HitNormal

                    if math.abs(hitNormal.z) < 0.25 then
                        ply:SetNW2Float("OM_SetVelocity_pos", 0)
                        ply:SetLocalVelocity(Vector(0,0,0))
                        ply:SetVelocity(Vector(0,0,0))
                        if SERVER then
                            --chargestart_Kolossoschargestart_Kolossos
                            ent:SetNW2Float("chargestart_Kolossos",0)
                            ent:SetNW2Float("Charging_kolossos",0)
                            ent:SetNW2Float("Charging_kolossos_losecontrol", 0)
                            ply:SetNW2Float("OM_MoveForward", 0.2)
                            ply:SetNW2Float("NoJumpingCooldown_OM", 0.2)
                            ent:SetNW2Float("Kolossos_considered_slam", CurTime()+0.2)
                            ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1.65)
                            ent:SetNW2Float("IdentifiedAsCrash_kolossos_wall", CurTime() + 0.2)

                            for _, ent2 in ipairs(ent.OM_Kolossos_HitList) do
                                if !IsValid(ent2) then return end
                                
                                KillerdamagestunDynamic({
                                    ply = ply,
                                    target = ent2,
                                    DamageNumb = GetConVar("OUTCOMEMEMORIES_N_Kolosssos_slamDamage"):GetFloat(),
                                    damagetype = DMG_CLUB,
                                    CustomDamageSound = nil,
                                    damagesound = true,
                                    ShouldBlood = true,
                                    flingremoveal = true,
                                    ShouldBloodEffect = true
                                })

                            end
                            if #ent.OM_Kolossos_HitList > 0 then

                                ent:PillAnim("slaminwall")
                                ply:SetVelocity(Vector(0,0,0))
                                ply:SetLocalVelocity(Vector(0,0,0))
                                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 1.3)

                                AdvancedPillSound({
                                    stringe = "OM/kolossos/Sound.mp3",
                                    pitchPercent = 100,
                                    volume = 2,
                                    soundLevel = 100
                                }, ent)
                                
                            else
                                ent:SetNW2Bool("Kolossos_BumpDuration", true)

                                AdvancedPillSound({
                                    stringe = "OM/kolossos/Kol wall bump.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 76
                                }, ent)
                                
                                if ply:IsNextBot() then
                                    if ply:IsOnGround() then
                                        ply:SetPos(ply:GetPos()+Vector(0,0,40))
                                    end
                                    ply:SetVelocity(Vector(0,0,200) + ply:GetForward()*-500)
                                    ply:SetLocalVelocity(Vector(0,0,200) + ply:GetForward()*-500)
                                else
                                    if ply:IsOnGround() then
                                        ply:SetPos(ply:GetPos()+Vector(0,0,25))
                                    end
                                    ply:SetVelocity(Vector(0,0,75) + ply:GetForward()*-150)
                                    ply:SetLocalVelocity(Vector(0,0,75) + ply:GetForward()*-150)
                                end
                            end

                            local ed = EffectData()
                            ed:SetOrigin(tr.HitPos + tr.HitNormal * 30)

                            util.Effect("kolossos_impact_effect", ed, true, true)

                            ent:GetPuppet():SetNW2Float("MetalSonicbump_highlight", CurTime()+0.5)
                            ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5)
                        end
                    end
                end

                local function isontable(ent2)
                    for _, obj in ipairs(ent.OM_Kolossos_HitList) do
                        if ent2 == obj then
                            return true
                        end
                    end
                end

                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 90)) do
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if not GetConVar('PVPStun_OM_exe'):GetBool() then
                            if ent2:GetNW2Bool("OM_character_monster") then return end
                        end

                        if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                        if Mutal_OMCanDamage_grab(ply,ent,ent2) then else continue end
                        
                        if isontable(ent2) then
                            continue
                        end

                        if IsValid(ent2) then
                            table.insert(ent.OM_Kolossos_HitList, ent2)

                            KillerdamagestunDynamic({
                                ply = ply,
                                target = ent2,
                                DamageNumb = GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeImpaleDamage"):GetFloat(),
                                damagetype = DMG_CLUB,
                                CustomDamageSound = nil,
                                damagesound = true,
                                ShouldBlood = true,
                                flingremoveal = true,
                                ShouldBloodEffect = true
                            })

                            local effectData = EffectData()
                            effectData:SetOrigin(ent2:GetPos()+Vector(0,0,40))
                            effectData:SetNormal(ply:GetForward()*-1)
                            effectData:SetScale(3)

                            util.Effect("kolossos_charging_blood", effectData, true, true)

                            AdvancedPillSound(
                                {
                                    stringe = "OM/kolossos/Kol impacts.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                            if ent:GetNW2Float("Charging_kolossos") < CurTime() then
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/kolossos/Kol charge laugh impale.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 67
                                    },
                                    ent
                                )
                            end

                            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then
                            else
                                local chargeadd = GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ImapleChargeDuration"):GetFloat()
                                ent:SetNW2Float("Charging_kolossos",CurTime()+chargeadd)
                                ent:SetNW2Float("Charging_kolossos_losecontrol",CurTime()+chargeadd+GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeNoConotrolDuration"):GetFloat())
                                local Flung1 = false
                                local Flung = false
                                local enemyragdoll = CreateRagdolLCharacter_OM({
                                    target = ent2,
                                    host = ent,

                                    shouldremove = function(createfakeragdoll)
                                        if not IsValid(createfakeragdoll) then return true end
                                        if not IsValid(ent2) then return true end
                                        if not IsValid(ent) then return true end

                                        if (ent:GetNW2Float("Charging_kolossos") < CurTime() and ent:GetNW2Float("Charging_kolossos_losecontrol") < CurTime()) and Flung then
                                            return true
                                        end

                                        return false
                                    end,

                                    shoulddocustomfunction = function(createfakeragdoll)

                                        if not IsValid(createfakeragdoll) then return end

                                        if math.random(1,60) == 1 then

                                            local effectData = EffectData()
                                            effectData:SetOrigin(createfakeragdoll:GetPos()+Vector(0,0,10))
                                            effectData:SetNormal(ply:GetForward())
                                            effectData:SetScale(3)

                                            util.Effect("kolossos_blood_drip", effectData, true, true)
                                        end
                                        local puppet = ent:GetPuppet()
                                        if not IsValid(puppet) then return end

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

                                        local bone = puppet:LookupBone("RightHand")
                                        if not bone then return end
                                        local pos, ang = puppet:GetBonePosition(bone)
                                        pos = puppet:GetPos() + puppet:GetForward() * 40 + puppet:GetUp() * 40

                                        if not Flung1 then
                                            headPhys:SetPos(pos)
                                            headPhys:SetAngles(ang)
                                            headPhys:SetVelocityInstantaneous(vector_origin)
                                            headPhys:Wake()
                                        end

                                        if ent:GetNW2Float("Charging_kolossos") < CurTime() and ent:GetNW2Float("Charging_kolossos_losecontrol") < CurTime() and not Flung1 then
                                            Flung1 = true

                                        if ent:GetNW2Float("IdentifiedAsCrash_kolossos_wall") > CurTime() then
                                            local dirs = {
                                                puppet:GetRight(),
                                                -puppet:GetRight(),
                                                puppet:GetForward()
                                            }

                                            local chosenDir = table.Random(dirs)

                                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                                if IsValid(phys) then
                                                    phys:ApplyForceCenter(
                                                        chosenDir * 7500
                                                    )
                                                end
                                            end
                                        else
                                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                local phys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                if IsValid(phys) then
                                                    phys:ApplyForceCenter(puppet:GetForward() * 5000 + Vector(0,0,2000))
                                                end
                                            end
                                        end



                                            --createfakeragdoll:SetCollisionGroup(COLLISION_GROUP_NONE)
                                            timer.Simple(2,function()
                                                if !IsValid(ent) then return end
                                                Flung = true
                                            end)
                                        end
                                    end,
                                })
                                
                            end


                        end
                    end
                end  
            else
                if ent.setcd_charge_kolo then
                    ent.setcd_charge_kolo = false

                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 3.65)

                    AdvancedPillSound({
                        stringe = "OM/kolossos/Kol wall bump.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 76
                    }, ent)
                    ent:SetNW2Float("kolossos_charge_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeCooldown"):GetFloat())
                end
            end

            if ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then
                local ent2 = ent:GetNW2Entity("grabbingEnt_kolossos")
                if !IsValid(ent2) or ent2:Health() < 0.1 or bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then
                    ent:SetNW2Entity("grabbingEnt_kolossos", NULL)
                    ent:SetNW2Float("grabbing_duration_kolossos", CurTime())
                    ent:SetNW2Float("kolossos_grab_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Kolosssos_GrabCooldown"):GetFloat())
                end
                if ent:GetNW2Float("grabbing_duration_kolossos") - CurTime() <= 1 then
                    if not ent:GetNW2Bool("GrabToggle_OM") then
                        ent:GetPuppet():RemoveGesture(ACT_HOVER, false)
                        ent:SetNW2Bool("GrabToggle_OM", true)

                        local puppet = ent:GetPuppet()
                        if IsValid(puppet) then
                            AdvancedPillSound(
                                {
                                    stringe = "OM/kolossos/kol sting and pull out.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )

                            local layeredAnim = puppet:AddGesture(ACT_DISARM, false)

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
                                    timer.Simple(0.0005, fadeLayer)
                                end
                            end

                            timer.Simple(0.15, fadeLayer)

                            timer.Simple(0.9,function()
                                if !IsValid(ent) then return end
                                puppet:RemoveLayer(layeredAnim)
                            end)
                            
                            ent:SetNW2Float("AttackCooldown_OM", CurTime() + 3)
                            ent:SetNW2Float("grabbing_duration_kolossos", CurTime() + 1.75)
                            ent:SetNW2Float("kolossos_grab_cd", CurTime()+2)
                            ent:SetNW2Entity("grabbingEnt_kolossos", NULL)
                        end

                    end
                end

            else
                ent:GetPuppet():RemoveGesture(ACT_HOVER, false)
                if ent:GetNW2Bool("GrabToggle_OM") then
                    ent:SetNW2Bool("GrabToggle_OM", false)
                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 0.3)
                end
            end

            if ent:GetNW2Float("grabbing_kolossos") > CurTime() then
                if not ent.setcd_grab_kolo then
                    ent.setcd_grab_kolo = true

                end
                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 90)) do
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if not GetConVar('PVPStun_OM_exe'):GetBool() then
                            if ent2:GetNW2Bool("OM_character_monster") then return end
                        end

                        if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                        if Mutal_OMCanDamage_grab(ply,ent,ent2) then else continue end

                        ent:SetNW2Float("grabbing_kolossos", CurTime() - 0.75)
                        ent:SetNW2Float("grabbing_duration_kolossos", CurTime() + 10)
                        ent:SetNW2Float("PunchesLeft_grab", GetConVar("OUTCOMEMEMORIES_N_Kolosssos_PunchesLeft"):GetFloat())
                        ent:SetNW2Entity("grabbingEnt_kolossos", ent2)

                        ent:GetPuppet():AddGesture(ACT_HOVER, false)

                        AdvancedPillSound(
                            {
                                stringe = "OM/kolossos/Kol impales.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )

                        local effectData = EffectData()
                        effectData:SetOrigin(ent2:GetPos()+Vector(0,0,40))
                        effectData:SetNormal(ply:GetForward()*-1)
                        effectData:SetScale(3)

                        util.Effect("kolossos_charging_blood", effectData, true, true)

                        local throw = false
                        local timestarted = false
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

                                if ent:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then
                                    return true
                                end

                                if ent:GetNW2Float("grabbing_duration_kolossos") < CurTime() and not timestarted then
                                    return true
                                end

                                return false
                            end,

                            shoulddocustomfunction = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return end
                                if math.random(1,60) == 1 then

                                    local effectData = EffectData()
                                    effectData:SetOrigin(createfakeragdoll:GetPos()+Vector(0,0,10))
                                    effectData:SetNormal(ply:GetForward())
                                    effectData:SetScale(3)

                                    util.Effect("kolossos_blood_drip", effectData, true, true)
                                end

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
                                if ent:GetNW2Bool("GrabToggle_OM") and not timestarted then timestarted = true
                                    starttime = CurTime()+1.5
                                    timer.Simple(0.3,function()
                                        throw = true
                                        if IsValid(createfakeragdoll) then

                                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                                if IsValid(phys) then
                                                    phys:Wake()

                                                    phys:SetVelocityInstantaneous(puppet:GetForward()*700)
                                                end
                                            end
                                        end
                                    end)
                                end

                                local bone = puppet:LookupBone("RightHand")
                                if not bone then return end
                                local pos, ang = puppet:GetBonePosition(bone)
                                --pos = puppet:GetPos() + puppet:GetForward() * 40 + puppet:GetUp() * 40

                                headPhys:SetPos(pos)
                                headPhys:SetAngles(ang)
                                headPhys:SetVelocityInstantaneous(vector_origin)
                                headPhys:Wake()
                                    
                            end,
                        })
                        break
                    end
                end
            else
                if ent.setcd_grab_kolo then
                    ent.setcd_grab_kolo = false
                    if !IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) then
                        ent:SetNW2Float("kolossos_grab_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Kolosssos_GrabCooldown"):GetFloat())
                        ent:SetNW2Float("kolossos_grab_slowdown", CurTime() + 3)
                    end
                end
            end

            if ent:GetNW2Bool("HoldingSpaceClimb") and not ply:IsOnGround() then
                local startPos = ply:GetPos()
                local endPos = startPos + ent:GetPuppet():GetForward() * 65

                local tr = util.TraceLine({
                    start = startPos,
                    endpos = endPos,
                    filter = ply,
                    mask = MASK_SOLID
                })

                if tr.Hit then
                    local climbspeed = 4

                    if ent:GetNW2Bool("HoldingSpaceClimbClimb_up") then
                        climbspeed = climbspeed + 500
                    end
                    if ent:GetNW2Bool("HoldingSpaceClimbClimb_down") then
                        climbspeed = climbspeed -500
                    end

                    if ply:GetVelocity():Length() > 50 then
                        if ent:GetNW2Float("ClimbSounudTick") > CurTime() then
                        else
                            AdvancedPillSound(
                                {
                                    stringe = "OM/kolossos/kol climb 1.wav",
                                    pitchPercent = math.random(95,105),
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                            ent:SetNW2Float("ClimbSounudTick", CurTime()+0.35)
                        end
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
                ent:SetNW2Bool("Kolossos_Climbing", false)
            end

            if SERVER then
                if ent:GetNW2Bool("Glide") and not ent:GetNW2Bool("Kolossos_Climbing") then
                    local vel = ply:GetVelocity()
                    local velo = ply:GetForward()*(ply:GetRunSpeed()*0.5) + ply:GetUp()* -40
                    if ply:IsNextBot() then
                        velo = ply:GetForward()*(ply:GetRunSpeed()*1) + ply:GetUp()* -40
                    end
                    ply:SetVelocity(velo)
                    ply:SetLocalVelocity(velo)
                    
                    ply:SetGravity(0.3)
                else
                    ply:SetGravity(1)
                end
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

    noodles_OM_survivor_keybinds = function(ply, ent, button)
        if SERVER then
            if button == KEY_SPACE then
                if GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanClimb"):GetBool() then
                    
                    if ent:GetNW2Float("grabbing_kolossos", 0 ) > CurTime() then return end
                    if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                    if ent:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end
                    if ent:GetNW2Float("Charging_kolossos") > CurTime() then return end
                    if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then return end
                    
                    if IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) and ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then return end
                    
                    ent:SetNW2Bool("HoldingSpaceClimb", true)
                end

                if ent:GetNW2Bool("Kolossos_Climbing") then
                    ply:SetLocalVelocity(Vector(0,0,185)+ply:GetForward()*-200)
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

            if button == ply:GetInfoNum("om_pills_action_kolossos_charge_key", KEY_E) then
                if not GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanCharge"):GetBool() then return end
                if ent.setcd_charge_kolo then return end
                if ent.setcd_grab_kolo then return end
                if ent:GetNW2Bool("Kolossos_inblock") then return end
                if ent:GetNW2Float("Kolossos_blocking", 0 ) > CurTime() then return end
                if ent:GetNW2Bool("GrabToggle_OM") then return end
                if ent:GetNW2Float("kolossos_grab_slowdown") > CurTime() then return end
                if ent:GetNW2Float("OM_Kolossos_indicator", 0 ) > CurTime() then return end
                if ent:GetNW2Bool("Kolossos_Climbing") then return end
                if ent:GetNW2Float("grabbing_kolossos", 0 ) > CurTime() then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then return end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then return end

                if IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) and ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then return end
                
                if ent:GetNW2Float("kolossos_charge_cd") > CurTime() then return end
                
                ent:SetNW2Float("chargestart_Kolossos", CurTime()+0.8)
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.75)
                
                timer.Simple(0.15,function()
                    if !IsValid(ent) then return end
                    AdvancedPillSound({
                        stringe = "OM/kolossos/kol sigh i think.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    }, ent)
                    ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                    ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)
                end)
                timer.Simple(0.35,function()
                    if !IsValid(ent) then return end
                    AdvancedPillSound({
                        stringe = "OM/kolossos/kol charge start ground rumble.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 76
                    }, ent)

                    local ed = EffectData()
                    ed:SetOrigin(ply:GetPos() + ply:GetForward()*60)
                    util.Effect("kolossos_charging_step", ed)

                    local ed = EffectData()
                    ed:SetOrigin(ply:GetPos() + ply:GetForward()*60)
                    util.Effect("kolossos_charging_step", ed)

                    local ed = EffectData()
                    ed:SetOrigin(ply:GetPos() + ply:GetForward()*60)
                    util.Effect("kolossos_charging_step", ed)

                    ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                    ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)
                end)
                timer.Simple(0.75,function()
                    if !IsValid(ent) then return end
                    ent:SetNW2Bool("ChargeThing", false)
                    ent:SetNW2Bool("ChargeThing2", false)

                    AdvancedPillSound({
                        stringe = "OM/kolossos/KolossosChargeRoar.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    }, ent)

                    ent:SetNW2Float("Charging_kolossos", CurTime() + GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeDuration"):GetFloat())
                    
                    ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                    ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)
                end)

                AdvancedPillSound(
                    {
                        stringe = "OM/kolossos/StartUpCharge.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent.OM_Kolossos_HitList = {}
            end
            if button == ply:GetInfoNum("om_pills_action_kolossos_grab_key", KEY_R) then
                if not GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanGrab"):GetBool() then return end

                if GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanCancelGrab"):GetBool() and IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) and ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then
                    ent:SetNW2Float("PunchesLeft_grab", 0)

                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 3)
                    ent:SetNW2Float("grabbing_duration_kolossos", CurTime() + 1)
                    ent:SetNW2Float("kolossos_grab_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Kolosssos_GrabCooldown"):GetFloat())
                end
                if ent.setcd_charge_kolo then return end
                if ent.setcd_grab_kolo then return end
                if ent:GetNW2Bool("Kolossos_inblock") then return end
                if ent:GetNW2Float("Kolossos_blocking", 0 ) > CurTime() then return end
                if ent:GetNW2Bool("GrabToggle_OM") then return end
                if ent:GetNW2Float("OM_Kolossos_indicator", 0 ) > CurTime() then return end
                if ent:GetNW2Bool("Kolossos_Climbing") then return end
                if ent:GetNW2Float("grabbing_kolossos", 0 ) > CurTime() then return end
                if ent:GetNW2Float("grabbing_kolossos_spamprev", 0 ) > CurTime() then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then return end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then return end
                
                if IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) and ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then return end

                if ent:GetNW2Float("kolossos_grab_cd") > CurTime() then return end

                local puppet = ent:GetPuppet()
                if not IsValid(puppet) then return end
                
                local layeredAnim = puppet:AddGesture(ACT_GESTURE_MELEE_ATTACK1, false)

                local current = 1
                puppet:SetLayerWeight(layeredAnim, current)
                puppet:SetLayerPriority(layeredAnim, 10)

                local playbackRate = 1.35
                puppet:SetLayerPlaybackRate(layeredAnim, playbackRate)

                local function fadeLayer()
                    if not IsValid(puppet) then return end
                    current = current - 0.04
                    puppet:SetLayerWeight(layeredAnim, math.max(current, 0))

                    if current > 0 then
                        timer.Simple(0.0005, fadeLayer)
                    end
                end

                timer.Simple(0.3, fadeLayer)

                timer.Simple(0.9,function()
                    if !IsValid(ent) then return end
                    puppet:RemoveLayer(layeredAnim)
                end)

                ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.35)
                ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.35)
                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1)
                ent:SetNW2Float("grabbing_kolossos", CurTime() + 0.6)
                ent:SetNW2Float("grabbing_kolossos_spamprev", CurTime() + 0.7)

                AdvancedPillSound(
                    {
                        stringe = "OM/kolossos/kol grab lunge.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                AdvancedPillSound(
                    {
                        stringe = "OM/kolossos/Kol uses grab.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end
            if button == ply:GetInfoNum("om_pills_action_kolossos_indicator_key", KEY_T) then
                if not GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanIndicator"):GetBool() then return end
                if ent.setcd_charge_kolo then return end
                if ent.setcd_grab_kolo then return end
                if ent:GetNW2Bool("Kolossos_inblock") then return end
                if ent:GetNW2Float("Kolossos_blocking", 0 ) > CurTime() then return end
                if ent:GetNW2Bool("GrabToggle_OM") then return end
                if ent:GetNW2Float("grabbing_kolossos", 0 ) > CurTime() then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then return end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then return end
                
                if IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) and ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then return end

                if ent:GetNW2Float("kolossos_indicator_cd") > CurTime() then return end

                ent:SetNW2Float("OM_Kolossos_indicator", CurTime() + GetConVar("OUTCOMEMEMORIES_N_Kolosssos_IndicatorDuration"):GetFloat(),CurTime())
                ent:SetNW2Float("kolossos_indicator_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Kolosssos_IndicatorCooldown"):GetFloat(),CurTime())
            end
            if button == ply:GetInfoNum("om_pills_action_kolossos_block_key", KEY_I) then
                if not GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanBlock"):GetBool() then return end
                if ent.setcd_charge_kolo then return end
                if ent.setcd_grab_kolo then return end
                if ent:GetNW2Bool("GrabToggle_OM") then return end
                if ent:GetNW2Bool("Kolossos_inblock") then return end
                if ent:GetNW2Float("Kolossos_blocking", 0 ) > CurTime() then return end
                if ent:GetNW2Float("OM_Kolossos_indicator", 0 ) > CurTime() then return end
                if ent:GetNW2Bool("Kolossos_Climbing") then return end
                if ent:GetNW2Float("grabbing_kolossos", 0 ) > CurTime() then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then return end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then return end
                
                if IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) and ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then return end

                if ent:GetNW2Float("kolossos_block_cd") > CurTime() then return end

                ent:SetNW2Float("kolossos_block_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Kolosssos_BlockCooldown"):GetFloat())
                if ent.PillAnim then
                    ent:PillAnim("BlockStart")
                end
                ent:SetNW2Float("Kolossos_blocking", CurTime() + GetConVar("OUTCOMEMEMORIES_N_Kolosssos_BlockDuration"):GetFloat())
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + GetConVar("OUTCOMEMEMORIES_N_Kolosssos_BlockDuration"):GetFloat())
                ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.5)
                
                AdvancedPillSound(
                    {
                        stringe = "OM/kolossos/kol block.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end
        end
    end,

    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if SERVER then

                --
                if ent:GetNW2Float("OM_executionanim") > CurTime() then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end
                if ent:GetNW2Float("CaosDash_duration", 0) > CurTime() then return end
                if ent:GetNW2Bool("drawfleetwaylaser") then return end
                if ent:GetNW2Bool("FatefulDrainMode") or (ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing")) then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Bool("LaserDuration") then return end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then return end
                --


                if ent.setcd_charge_kolo then return end
                if ent.setcd_grab_kolo then return end
                if ent:GetNW2Float("Kolossos_blocking", 0 ) > CurTime() then return end
                if ent:GetNW2Bool("GrabToggle_OM") then return end
                if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then return end
                if ent:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end
                if ent:GetNW2Float("Charging_kolossos") > CurTime() then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) and ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then
                    if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                    if ent:GetNW2Float("PunchesLeft_grab") <= 0 then return end

                    local puppet = ent:GetPuppet()
                    if not IsValid(puppet) then return end
                    
                    local layeredAnim = puppet:AddGesture(ACT_GESTURE_MELEE_ATTACK2, false)

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
                            timer.Simple(0.0005, fadeLayer)
                        end
                    end

                    timer.Simple(0.15, fadeLayer)

                    timer.Simple(0.6,function()
                        if !IsValid(ent) then return end
                        puppet:RemoveLayer(layeredAnim)
                    end)
                    
                    AdvancedPillSound(
                        {
                            stringe = "OM/kolossos/kolossos punching.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )


                    local ed = EffectData()
                    ed:SetOrigin(ply:GetPos()+Vector(0,0,40)+ply:GetForward()*40)

                    util.Effect("kolossos_impact_effect", ed, true, true)

                    local effectData = EffectData()
                    effectData:SetOrigin(ply:GetPos()+Vector(0,0,40)+ply:GetForward()*40)
                    effectData:SetNormal(ply:GetForward()*-1)
                    effectData:SetScale(1)

                    util.Effect("kolossos_charging_blood", effectData, true, true)

                    ent:SetNW2Float("PunchesLeft_grab", ent:GetNW2Float("PunchesLeft_grab") - 1)
                    if ent:GetNW2Float("PunchesLeft_grab") <= 0 then

                        ent:SetNW2Float("AttackCooldown_OM", CurTime() + 3)
                        ent:SetNW2Float("grabbing_duration_kolossos", CurTime() + 1.75)
                        ent:SetNW2Float("kolossos_grab_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Kolosssos_GrabCooldown"):GetFloat())
                    end
                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 0.75)
                    damagestun(ply, ent:GetNW2Entity("grabbingEnt_kolossos", ent2), GetConVar("OUTCOMEMEMORIES_N_Kolosssos_slamDamage"):GetFloat(), DMG_CLUB, true)

                else
                    if ent:GetNW2Float("kolossos_grab_slowdown") > CurTime() then return end

                    local puppet = ent:GetPuppet()
                    if not IsValid(puppet) then return end
                    
                    local layeredAnim = puppet:AddGesture(ACT_MELEE_ATTACK_SWING_GESTURE, false)

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
                            timer.Simple(0.0005, fadeLayer)
                        end
                    end

                    timer.Simple(0.15, fadeLayer)

                    timer.Simple(0.9,function()
                        if !IsValid(ent) then return end
                        puppet:RemoveLayer(layeredAnim)
                    end)

                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1.65)
                    
                    AdvancedPillSound(
                        {
                            stringe = {"OM/kolossos/kol m1 (1).wav", "OM/kolossos/kol m1 (2).wav", "OM/kolossos/kol m1 (3).wav", "OM/kolossos/kol m1 (4).wav"},
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
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

        ent:SetNW2Float("jump_animdur", CurTime()+0.1)

        AdvancedPillSound(
            {
                stringe = "OM/kolossos/Kolossos jump.wav",
                pitchPercent = 100,
                volume = 1,
                soundLevel = 87
            },
            ent
        )

    end
})

-- tripwire mouse handeler
if SERVER then
    util.AddNetworkString("Tripwire_recieve_mouse")
    util.AddNetworkString("Tripwire_retrieve_mouse")

    net.Receive("Tripwire_recieve_mouse", function()
        local ply = net.ReadEntity()
        local hitPos = net.ReadVector()

        local pillentity = ply.pk_pill_ent
        
        if IsValid(pillentity) then
            if pillentity.formTable.SpawnMine then
                pillentity.formTable.SpawnMine(ply, pillentity, hitPos)
            end
        end
    end)
else
    local function GetTrueMouseHitPos(ply)
        local view = render.GetViewSetup()
        local startPos = view.origin

        local mx, my = gui.MousePos()
        local screenW, screenH = ScrW(), ScrH()
        local middlex, middley = screenW * 0.5, screenH * 0.5
        if mx == 0 and my == 0 then 
            mx = middlex
            my = middley
        end

        local dir = gui.ScreenToVector(mx, my)

        local tr = util.TraceLine({
            start = startPos,
            endpos = startPos + dir * 10000,
            filter = ply,
            mask = MASK_ALL
        })

        return tr.HitPos
    end
    net.Receive("Tripwire_retrieve_mouse", function()
        local ply = LocalPlayer()

        net.Start("Tripwire_recieve_mouse")
            net.WriteEntity(ply)
            net.WriteVector(GetTrueMouseHitPos(ply))
        net.SendToServer()
    end)
end
