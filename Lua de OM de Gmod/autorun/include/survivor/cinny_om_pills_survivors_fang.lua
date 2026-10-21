
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


if CLIENT then
    local worldPos = Vector(0, 0, 80)

    local w, h = 200, 80

    local hovered = false
    local lastDown = false

    --[[

        local screenPos = worldPos:ToScreen()

        -- Don't draw if it's behind the camera
        if not screenPos.visible then return end

        local x = screenPos.x - w / 2
        local y = screenPos.y - h / 2

        local mx, my = gui.MousePos()

        hovered =
            mx >= x and mx <= x + w and
            my >= y and my <= y + h

        if hovered then
            surface.SetDrawColor(50, 150, 255, 255)

            local down = input.IsMouseDown(MOUSE_LEFT)
            if down and not lastDown then
                print("Clicked!")
                surface.PlaySound("buttons/button15.wav")
            end

            lastDown = down
        else
            surface.SetDrawColor(60, 60, 60, 255)
            lastDown = false
        end

        surface.DrawRect(x, y, w, h)

        draw.SimpleText(
            hovered and "Hovering!" or "Click Me",
            "DermaLarge",
            x + w / 2,
            y + h / 2,
            color_white,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )

    ]]

    -- Required for gui.MousePos()
    --hook.Add("Think", "EnableScreenClicker", function()
    --end)
        --gui.EnableScreenClicker(false)
end

local preservedmats = {
    ["fang_bounce_icon"] = Material("icons/fang_bounce_icon.png"),
    ["fang_gun_icon"] = Material("icons/fang_gun_icon.png"),
    ["fang_reworked_gun_land"] = Material("icons/fang_reworked_gun_land.png"),
    ["targetblur_fang"] = Material("icons/targetblur_fang.png"),
}
if CLIENT then
    surface.CreateFont("Fang_Western_om", {
        font = "Georgia",
        size = 32,
        weight = 1000,
        antialias = true,
        shadow = false
    })
end
if SERVER then
    util.AddNetworkString("Fang_SetShootingCount")

    net.Receive("Fang_SetShootingCount", function(len, ply)
        local value = net.ReadFloat()
        local ent = net.ReadEntity()

        if IsValid(ent) then
            ent:SetNW2Float("Fang_shootingCount", value + 1)
        end
    end)
    util.AddNetworkString("Fang_SetShootingCount_decrease")

    net.Receive("Fang_SetShootingCount_decrease", function(len, ply)
        local value = net.ReadFloat()
        local ent = net.ReadEntity()

        if IsValid(ent) then
            ent:SetNW2Float("Fang_shootingCount", value - 1)
        end
    end)
end

if SERVER then--
    timer.Simple(1,function()
        if SERVER then else return end
        OM_AddSpeedConfigeration(function(entity)
            if SERVER and entity:GetNW2Int("Fang_Gun_corkslowdown", 0) >= CurTime() then
                return 0.5
            end
            return 1
        end)
    end)
end

hook.Add("SetupMove", "fang_slowdown_debuff", function(ply, mv, cmd)
    if !IsValid(ply) then return end
    if !ply:Alive() then return end

    if ply:GetNW2Int("Fang_Gun_corkslowdown", 0) >= CurTime() then
        local vel = mv:GetVelocity()

        vel.x = vel.x * 0.5
        vel.y = vel.y * 0.5

        mv:SetVelocity(vel)
    end
end)
pk_pills.register('pill_om_fang', {

    printName='Fang',
    Outcomememories='Fang',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/Fang.mdl",
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',

    ShouldRoll_om = function(e, ply, ent)
        if ent:GetNW2Float("bounce_time") > 0 then return end
        return true
    end,

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["fang_gun_icon"]
            end,
            name = function(uselessvar,ply,ent)
                return "Snipe"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_fang_gun_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("movesettoggle_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("movesettoggle_dur")
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["fang_bounce_icon"]
            end,
            name = function(uselessvar,ply,ent)
                return "Bounce"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_fang_bounce_key", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("mobilityability_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("mobilityability_dur")
            end,
            survivor = true,
            font = "CreditsText",
        }
    },

    OM_UI_custom1 = function(ply, ent)

    end,


    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            attack = "attack",
            jump2 = "jump",
            jumpshoot = "jumpshoot",
            Shooting="Shooting",
            BounceChargePos3 = "BounceChargePos3",
            BounceChargePos5 = "BounceChargePos5",
        },
        ShouldMoveRotate={
            idle= function(ent) 
                if ent:GetNW2Float("fang_launchtowards_step") == 1 then return "shiftlock" end
                if ent:GetNW2Float("fang_launchtowards_step") == 2 then return "shiftlock" end
                if ent:GetNW2Bool("Fang_snipe_enabled") then
                    return "shiftlock"
                end
                return "notanything"
            end,
            run= function(ent) 
                if ent:GetNW2Float("fang_launchtowards_step") == 1 then return "shiftlock" end
                if ent:GetNW2Float("fang_launchtowards_step") == 2 then return "shiftlock" end
                if ent:GetNW2Bool("Fang_snipe_enabled") then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            walk= function(ent) 
                if ent:GetNW2Float("fang_launchtowards_step") == 1 then return "shiftlock" end
                if ent:GetNW2Float("fang_launchtowards_step") == 2 then return "shiftlock" end
                if ent:GetNW2Bool("Fang_snipe_enabled") then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            fall= function(ent) 
                if ent:GetNW2Float("fang_launchtowards_step") == 1 then return "shiftlock" end
                if ent:GetNW2Float("fang_launchtowards_step") == 2 then return "shiftlock" end
                if ent:GetNW2Bool("Fang_snipe_enabled") then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            jump= function(ent) 
                if ent:GetNW2Float("fang_launchtowards_step") == 1 then return "shiftlock" end
                if ent:GetNW2Float("fang_launchtowards_step") == 2 then return "shiftlock" end
                if ent:GetNW2Bool("Fang_snipe_enabled") then
                    return "shiftlock"
                end
                return 'notshftlock'
            end,
            jumpshoot= function(ent) 
                if ent:GetNW2Bool("Fang_snipe_enabled") then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            LandBounce= function(ent)
                if ent:GetNW2Bool("Fang_snipe_enabled") then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
        },

        ShouldAlternate={
            idle= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end

                if ent:GetNW2Float("fang_launchtowards_step") == 1 then return "BounceChargePos1" end
                if ent:GetNW2Float("fang_launchtowards_step") == 2 then return "BounceChargePos2" end
                if ent:GetNW2Float("fang_launchtowards_step") == 3 then return "BounceChargePos3" end
                if ent:GetNW2Float("fang_launchtowards_step") == 4 then return "BounceChargePos4" end
                if ent:GetNW2Float("fang_launchtowards_step") == 5 then return "BounceChargePos5" end

                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("Fang_snipe_enabled") then return "aimidle" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "idle_lowhealth"
                end 
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end

                if ent:GetNW2Float("fang_launchtowards_step") == 1 then return "BounceChargePos1" end
                if ent:GetNW2Float("fang_launchtowards_step") == 2 then return "BounceChargePos2" end
                if ent:GetNW2Float("fang_launchtowards_step") == 3 then return "BounceChargePos3" end
                if ent:GetNW2Float("fang_launchtowards_step") == 4 then return "BounceChargePos4" end
                if ent:GetNW2Float("fang_launchtowards_step") == 5 then return "BounceChargePos5" end

                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("Fang_snipe_enabled") then return "AimWalk" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "walk_lowhealth"
                end 
            end,
            fall= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end

                if ent:GetNW2Float("fang_launchtowards_step") == 1 then return "BounceChargePos1" end
                if ent:GetNW2Float("fang_launchtowards_step") == 2 then return "BounceChargePos2" end
                if ent:GetNW2Float("fang_launchtowards_step") == 3 then return "BounceChargePos3" end
                if ent:GetNW2Float("fang_launchtowards_step") == 4 then return "BounceChargePos4" end
                if ent:GetNW2Float("fang_launchtowards_step") == 5 then return "BounceChargePos5" end
                
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end

                if ent:GetNW2Float("fang_launchtowards_step") == 1 then return "BounceChargePos1" end
                if ent:GetNW2Float("fang_launchtowards_step") == 2 then return "BounceChargePos2" end
                if ent:GetNW2Float("fang_launchtowards_step") == 3 then return "BounceChargePos3" end
                if ent:GetNW2Float("fang_launchtowards_step") == 4 then return "BounceChargePos4" end
                if ent:GetNW2Float("fang_launchtowards_step") == 5 then return "BounceChargePos5" end
                
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("Fang_snipe_enabled") then return "AimWalk" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "run_lowhealth"
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
        
        ent.fang_launchtowards_step_lerp_1 = ent.fang_launchtowards_step_lerp_1 or 0

        if ent:GetNW2Float("fang_launchtowards_step") == 1 or ent:GetNW2Float("fang_launchtowards_step") == 2 then 
            ent.fang_launchtowards_step_lerp_1 = Lerp(FrameTime()*5, ent.fang_launchtowards_step_lerp_1, 1)
        else
            ent.fang_launchtowards_step_lerp_1 = Lerp(FrameTime()*5, ent.fang_launchtowards_step_lerp_1, 0)
        end
        basetable["dist"] = basetable["dist"] - 30*ent.fang_launchtowards_step_lerp_1
        basetable["fov"] = basetable["fov"] - 5*ent.fang_launchtowards_step_lerp_1
        basetable["startoffset"] = basetable["startoffset"] + Vector(10*ent.fang_launchtowards_step_lerp_1,0,0)
        
        ent.fang_launchtowards_step_lerp_2 = ent.fang_launchtowards_step_lerp_2 or 0

        if ent:GetNW2Float("fang_launchtowards_step") == 4 then 
            ent.fang_launchtowards_step_lerp_2 = Lerp(FrameTime()*5, ent.fang_launchtowards_step_lerp_2, 1)
        else
            ent.fang_launchtowards_step_lerp_2 = Lerp(FrameTime()*5, ent.fang_launchtowards_step_lerp_2, 0)
        end
        basetable["dist"] = basetable["dist"] - 5*ent.fang_launchtowards_step_lerp_2
        basetable["fov"] = basetable["fov"] + 10*ent.fang_launchtowards_step_lerp_2
        basetable["startoffset"] = basetable["startoffset"] + Vector(10*ent.fang_launchtowards_step_lerp_2,0,0)

        if ent:GetNW2Bool("Fang_snipe_enabled") then
            local defaultFOV = ply:GetInfoNum("om_pills_default_fov", 80)

            basetable = {
                startoffset = Vector(25, 20, 35),
                dist = 60,
                fov = defaultFOV - 20,
                id = 1,
                transition = 1,
                canscroll = true,
            }

            local entity = ent:GetNW2Entity("Fang_lockin_entity")

            ent.Fang_lockin_entity = ent.Fang_lockin_entity or 0
            ent.Fang_lockin_entity_distance = ent.Fang_lockin_entity_distance or 0

            if IsValid(entity) then
                ent.Fang_lockin_entity = Lerp(FrameTime() * 3, ent.Fang_lockin_entity, 1)
            else
                ent.Fang_lockin_entity = Lerp(FrameTime() * 5, ent.Fang_lockin_entity, 0)
            end

            if ent.Fang_lockin_entity >= 0.01 then
                if IsValid(entity) then
                    ent.Fang_lockin_entity_distance = ply:GetPos():Distance(entity:GetPos())
                end
                local distance = ent.Fang_lockin_entity_distance

                local minDistance = 50
                local maxDistance = 2000

                local distancePercent = math.Clamp(
                    (distance - minDistance) / (maxDistance - minDistance),
                    0,
                    1
                )

                local minFOV = defaultFOV - 10
                local maxFOV = defaultFOV - 120

                local zoomFOV = Lerp(distancePercent, minFOV, maxFOV)

                basetable.fov = Lerp(
                    ent.Fang_lockin_entity,
                    defaultFOV - 20,
                    zoomFOV
                )

                basetable.fov = math.Clamp(basetable.fov, 10, 120)
            end
        end

        if ply:GetInfoNum("om_pills_action_camera_fang", 1) == 1 then
        end

        return basetable
    end,
       
    OM_UI_custom_end = function(ply, ent)

        local screenW, screenH = ScrW(), ScrH()
        local middlex, middley = screenW * 0.5, screenH * 0.5
        local iconsize = screenW / 13

        ent.fang_launchtowards_step_lerp = ent.fang_launchtowards_step_lerp or 0

        local target = ent:GetNW2Entity("Fang_lockin_entity")
        if ent:GetNW2Float("fang_launchtowards_step") >= 1 or (ent:GetNW2Float("Fang_lockin") >= CurTime() and IsValid(target)) then
            ent.fang_launchtowards_step_lerp = Lerp(
                FrameTime() * 7,
                ent.fang_launchtowards_step_lerp,
                1
            )
        else
            ent.fang_launchtowards_step_lerp = Lerp(
                FrameTime() * 7,
                ent.fang_launchtowards_step_lerp,
                0
            )
        end

        if ent.fang_launchtowards_step_lerp >= 0.01 then
            local frac = ent.fang_launchtowards_step_lerp

            local barHeight = screenH * 0.12

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

    OM_UI_custom_start = function(ply, ent)

        ent:CallOnRemove("RemoveEFunction_fangsurvivor",function()
            gui.EnableScreenClicker(false)
        end)

        local screenW, screenH = ScrW(), ScrH()
        local middlex, middley = screenW * 0.5, screenH * 0.5
        local iconsize = screenW / 13

        ent.Fang_snipe_enabled = ent.Fang_snipe_enabled or 0

        if ent:GetNW2Bool("Fang_snipe_enabled") then
            ent.Fang_snipe_enabled = Lerp(FrameTime() * 7, ent.Fang_snipe_enabled, 1)
        else
            ent.Fang_snipe_enabled = Lerp(FrameTime() * 7, ent.Fang_snipe_enabled, 0)
        end

        local frac = ent.Fang_snipe_enabled

        if frac >= 0.01 then
            if not ent.Fang_snipe_enabled_bool then
                ent.Fang_snipe_enabled_bool = true
            end

            local anim = math.ease.OutBack(frac)

            local y = Lerp(anim, -iconsize * 0.8, iconsize * 0.65)

            local scale = Lerp(anim, 0.75, 1)

            local alpha = 255 * frac

            surface.SetFont("Fang_Western_om")

            local text = "◆  HOLD LEFT-CLICK TO LOCK TARGET  ◆"

            local target = ent:GetNW2Entity("Fang_lockin_entity")
            if ent:GetNW2Float("Fang_lockin") >= CurTime() and IsValid(target) then
                text = "◆  TARGET LOCKED  ◆"
            end

            local textW, textH = surface.GetTextSize(text)

            local plateW = (textW + 80) * scale
            local plateH = (textH + 35) * scale

            draw.RoundedBox(
                4,
                middlex - plateW / 2,
                y - plateH / 2,
                plateW,
                plateH,
                Color(35, 20, 8, 150 * frac)
            )

            surface.SetDrawColor(115, 75, 30, 180 * frac)

            surface.DrawOutlinedRect(
                middlex - plateW / 2,
                y - plateH / 2,
                plateW,
                plateH,
                2
            )

            local lineWidth = (plateW - 30) * frac

            surface.SetDrawColor(170, 125, 60, 180 * frac)

            surface.DrawRect(
                middlex - lineWidth / 2,
                y - plateH / 2 + 7,
                lineWidth,
                1
            )

            surface.DrawRect(
                middlex - lineWidth / 2,
                y + plateH / 2 - 8,
                lineWidth,
                1
            )

            draw.SimpleText(
                text,
                "Fang_Western_om",
                middlex + 4,
                y + 5,
                Color(20, 10, 3, 230 * frac),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )

            draw.SimpleTextOutlined(
                text,
                "Fang_Western_om",
                middlex,
                y,
                Color(245, 225, 175, alpha),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER,
                4,
                Color(35, 18, 6, alpha)
            )

            draw.SimpleTextOutlined(
                text,
                "Fang_Western_om",
                middlex,
                y - 1,
                Color(255, 235, 185, alpha),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER,
                1,
                Color(190, 140, 65, 180 * frac)
            )

            DrawColorModify({
                ["$pp_colour_addr"] = 0.2 * frac,
                ["$pp_colour_addg"] = 0.05 * frac,
                ["$pp_colour_addb"] = -0.12 * frac,

                ["$pp_colour_brightness"] = -0.18 * frac,
                ["$pp_colour_contrast"] = 1 + 0.1 * frac,
                ["$pp_colour_colour"] = 1 - 0.9 * frac,

                ["$pp_colour_mulr"] = 0.22 * frac,
                ["$pp_colour_mulg"] = 0.12 * frac,
                ["$pp_colour_mulb"] = 0.025 * frac
            })


            local target = ent:GetNW2Entity("Fang_lockin_entity")
            if ent:GetNW2Float("Fang_lockin") >= CurTime() and IsValid(target) then
                if not ent.LockOnEntity_fang_placedown then
                    ent.LockOnEntity_fang_placedown = {}

                    table.insert(ent.LockOnEntity_fang_placedown, Vector(0,0,18))
                    table.insert(ent.LockOnEntity_fang_placedown, Vector(0,0,40))
                    table.insert(ent.LockOnEntity_fang_placedown, Vector(0,0,69))

                    ent.LockOnEntity_fang_randomplacedown = {}

                    table.insert(ent.LockOnEntity_fang_randomplacedown, math.random(-8, 8))
                    table.insert(ent.LockOnEntity_fang_randomplacedown, math.random(-15, 15) )
                    table.insert(ent.LockOnEntity_fang_randomplacedown, math.random(-8, 8) )

                    ent.LockOnEntity_fang_isfinished = {
                        [1] = false,
                        [2] = false,
                        [3] = false
                    }
                    ent.LockOnEntity_fang_isfinished_nip = {
                        [1] = false,
                        [2] = false,
                        [3] = false
                    }
                end

                cam.Start3D()
                    for i, pos in ipairs(ent.LockOnEntity_fang_placedown) do

                        local randomNumber = i

                        ent["Fang_FlashUp" .. randomNumber] =
                            ent["Fang_FlashUp" .. randomNumber] or 0

                        if ent:GetNW2Float("Fang_FlashUp" .. randomNumber) >= CurTime() then
                            ent["Fang_FlashUp" .. randomNumber] = Lerp(
                                FrameTime() * 15,
                                ent["Fang_FlashUp" .. randomNumber],
                                1
                            )
                        else
                            ent["Fang_FlashUp" .. randomNumber] = Lerp(
                                FrameTime() * 7,
                                ent["Fang_FlashUp" .. randomNumber],
                                0
                            )
                        end

                        local flash = ent["Fang_FlashUp" .. randomNumber]

                        local colorchoose = Color(
                            Lerp(flash, 75, 255),
                            Lerp(flash, 5, 35),
                            Lerp(flash, 5, 35),
                            255
                        )

                        local worldPos =
                            pos
                            + target:GetPos()
                            + ply:GetRight() * ent.LockOnEntity_fang_randomplacedown[i]

                        local mouseX, mouseY = gui.MousePos()
                        local screenPos = worldPos:ToScreen()
                        if flash >= 0.1 then

                            if ent.LockOnEntity_fang_isfinished_nip[i] == false then
                                ent.LockOnEntity_fang_isfinished_nip[i] = true
                                    
                                sound.PlayFile(
                                    "sound/OM/Fang/gunstart.wav",
                                    "noplay",
                                    function(chan)
                                        if IsValid(chan) then
                                            chan:SetVolume(0.35)
                                            chan:Play()
                                        end
                                    end
                                )
                            end

                            local hoverSize = 27

                            if screenPos.visible
                            and mouseX >= screenPos.x - hoverSize
                            and mouseX <= screenPos.x + hoverSize
                            and mouseY >= screenPos.y - hoverSize
                            and mouseY <= screenPos.y + hoverSize then

                                colorchoose = Color(0, 0, 255, 255)
                                if ent.LockOnEntity_fang_isfinished[i] == false then
                                    net.Start("Fang_SetShootingCount")
                                        net.WriteFloat(ent:GetNW2Float("Fang_shootingCount"))
                                        net.WriteEntity(ent)
                                    net.SendToServer()

                                    sound.PlayFile(
                                        "sound/OM/Fang/shoot" .. math.random(1, 2) .. ".wav",
                                        "noplay",
                                        function(chan)
                                            if IsValid(chan) then
                                                chan:SetVolume(0.35)
                                                chan:Play()
                                            end
                                        end
                                    )
                                end

                                ent.LockOnEntity_fang_isfinished[i] = true

                                -- Hovering over this fang
                                -- print("Hovering:", i)
                            end
                        else

                            if ent.LockOnEntity_fang_isfinished_nip[i] == true then
                                ent.LockOnEntity_fang_isfinished_nip[i] = false
                            end
                            --[[
                            local hoverSize = 3

                            if screenPos.visible
                                and mouseX >= screenPos.x - hoverSize
                                and mouseX <= screenPos.x + hoverSize
                                and mouseY >= screenPos.y - hoverSize
                                and mouseY <= screenPos.y + hoverSize then
                                if ent.LockOnEntity_fang_isfinished[i] == true then
                                    ent.LockOnEntity_fang_isfinished[i] = false
                                    net.Start("Fang_SetShootingCount_decrease")
                                        net.WriteFloat(ent:GetNW2Float("Fang_shootingCount"))
                                        net.WriteEntity(ent)
                                    net.SendToServer()
                                end
                            end
                            ]]
                        end

                        if ent.LockOnEntity_fang_isfinished[i] == true then
                            colorchoose = Color(0, 255, 0, 255)
                        end


                        render.SetMaterial(preservedmats["targetblur_fang"])
                        render.DrawSprite(
                            worldPos,
                            20,
                            20,
                            Color(255,255,255,255)
                        )

                        render.SetMaterial(preservedmats["fang_reworked_gun_land"])
                        render.DrawSprite(
                            worldPos,
                            15,
                            15,
                            colorchoose
                        )
                    end
                cam.End3D()
                            
                gui.EnableScreenClicker(true)


                ent.Fang_lockin_ui = ent.Fang_lockin_ui or 0
                ent.Fang_lockin_ui = Lerp(FrameTime() * 10, ent.Fang_lockin_ui, 1)

                local lockFrac = ent.Fang_lockin_ui

                local pulse = (math.sin(CurTime() * 5) + 1) * 0.5

                local lockText = "◆  Hover over flashing targets  ◆"

                local lockScale = 1 + lockFrac * 0.08

                surface.SetFont("Fang_Western_om")

                local lockTextW, lockTextH = surface.GetTextSize(lockText)

                local lockPlateW = (lockTextW + 80) * scale * lockScale
                local lockPlateH = (lockTextH + 35) * scale * lockScale

                y = y + iconsize * 0.5

                draw.RoundedBox(
                    4,
                    middlex - lockPlateW / 2,
                    y - lockPlateH / 2,
                    lockPlateW,
                    lockPlateH,
                    Color(
                        45,
                        25,
                        8,
                        (150 + pulse * 30) * lockFrac
                    )
                )

                surface.SetDrawColor(
                    180,
                    130,
                    50,
                    (180 + pulse * 60) * lockFrac
                )

                surface.DrawOutlinedRect(
                    middlex - lockPlateW / 2,
                    y - lockPlateH / 2,
                    lockPlateW,
                    lockPlateH,
                    3
                )

                local lockedLineWidth =
                    (lockPlateW - 30) * (0.7 + pulse * 0.3)

                surface.SetDrawColor(
                    220,
                    170,
                    75,
                    (180 + pulse * 50) * lockFrac
                )

                surface.DrawRect(
                    middlex - lockedLineWidth / 2,
                    y - lockPlateH / 2 + 7,
                    lockedLineWidth,
                    2
                )

                surface.DrawRect(
                    middlex - lockedLineWidth / 2,
                    y + lockPlateH / 2 - 8,
                    lockedLineWidth,
                    2
                )

                draw.SimpleText(
                    lockText,
                    "Fang_Western_om",
                    middlex + 4,
                    y + 5,
                    Color(
                        15,
                        7,
                        2,
                        230 * lockFrac
                    ),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )

                draw.SimpleTextOutlined(
                    lockText,
                    "Fang_Western_om",
                    middlex,
                    y,
                    Color(
                        255,
                        225,
                        145,
                        255 * lockFrac
                    ),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER,
                    4,
                    Color(
                        35,
                        15,
                        3,
                        255 * lockFrac
                    )
                )

                draw.SimpleTextOutlined(
                    lockText,
                    "Fang_Western_om",
                    middlex,
                    y - 1,
                    Color(
                        255,
                        245,
                        190,
                        (180 + pulse * 75) * lockFrac
                    ),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER,
                    1,
                    Color(
                        210,
                        155,
                        60,
                        200 * lockFrac
                    )
                )






            else

                ent.LockOnEntity_fang_placedown = nil
                gui.EnableScreenClicker(false)

                ent.Fang_lockin_ui = ent.Fang_lockin_ui or 0
                ent.Fang_lockin_ui = Lerp(
                    FrameTime() * 10,
                    ent.Fang_lockin_ui,
                    0
                )
            end
        else
            if ent.Fang_snipe_enabled_bool then
                ent.Fang_snipe_enabled_bool = false
                ent.LockOnEntity_fang_placedown = nil
                gui.EnableScreenClicker(false)
            end
        end
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

                if ent:GetNW2Bool("Fang_snipe_enabled") then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.9 - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.9 - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.9 - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
        }
    }, 

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_fang_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_fang_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_fang_walk"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_fang_jumppower"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_fang_jumpcd"):GetFloat()
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_fang_rollingPower"):GetFloat()
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

            local health = GetConVar("OUTCOMEMEMORIES_N_fang_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)


            initializetable2["player"].CustomFunctionForDowned_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]

                    --Fang_Gun_flashwhite
                    ent:SetNW2Bool("Fang_snipe_enabled", false)
                    ent:SetNW2Float("fang_launchtowards_step", 0)
                end
            end
            initializetable2["player"].OM_Stun_Blockfunction = function()
                if IsValid(initializetable2["entity"]) then
                    initializetable2["player"]:CustomFunctionForDowned_OM()
                end
            end

        end
        initializetable2["player"]:SetNW2Bool("OM_character", true)
        initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
        initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)
    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetNW2Bool("ShoukdntStun_OM_Noodles", false)
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetGravity(1)
            if SERVER then 
                if initializetable2["player"].SetEyeAngles then
                    initializetable2["player"]:SetEyeAngles(Angle(0,0,0))
                end
            end
        end
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_fang_Resistance"):GetFloat()/100)


            if not GetConVar("OUTCOMEMORIES_N_fang_gun_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
            end
            if not GetConVar("OUTCOMEMORIES_N_fang_bounce_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
            end

            local function GetLookEntity(ply, distance)
                local tr = util.TraceHull({
                    start = ply:GetPos()+Vector(0,0,50),
                    endpos = ply:GetPos()+Vector(0,0,50) + ply:GetAimVector() * (distance or 10000),

                    mins = Vector(-30, -30, -30),
                    maxs = Vector(30, 30, 30),

                    filter = function(ent2)
                        if ent2 == ply then return false end
                        if ent2 == ent then return false end
                        if ent2 == ent:GetPuppet() then return false end
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then return false end

                        if (ent2:IsPlayer() or ent2:IsNPC() or ent2:IsNextBot()) and ent2:Health()>=0.1 then else return false end

                        --if Mutual_OMCanStun(ply, ent, ent2, false) then else return false end

                        return true
                    end,
                    mask = MASK_SHOT
                })

                if IsValid(tr.Entity) then
                    return tr.Entity
                end
                return nil
            end

            ent.Fang_Lockin_lerp = ent.Fang_Lockin_lerp or 0

            if ent:GetNW2Float("Fang_lockin") >= CurTime() and ent:GetNW2Bool("Fang_snipe_enabled") then

                if !IsValid(ent:GetNW2Entity("Fang_lockin_entity")) then
                    local target = GetLookEntity(ply, 5000)

                    if IsValid(target) then
                        ent.Fang_Lockin_lerp = 0
                        ent:SetNW2Entity("Fang_lockin_entity", target)
                        ent.Fang_lockin_entity_tablelist = nil
                        ent:SetNW2Float("Fang_shootingCount", 0)


                        AdvancedPillSound(
                            {
                                stringe = "OM/Fang/gunstart.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )

                        ent:StopSound("OM/Fang/voice/FangFound1.wav")
                        ent:StopSound("OM/Fang/voice/FangFound2.wav")
                        ent:StopSound("OM/Fang/voice/FangFound3.wav")
                        ent:StopSound("OM/Fang/voice/FangFound4.wav")
                        ent:StopSound("OM/Fang/voice/FangFound5.wav")
                        ent:StopSound("OM/Fang/voice/FangFound6.wav")
                        ent:StopSound("OM/Fang/voice/FangFound7.wav")
                        ent:StopSound("OM/Fang/voice/FangFound8.wav")

                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/Fang/voice/FangFound1.wav",
                                    "OM/Fang/voice/FangFound2.wav",
                                    "OM/Fang/voice/FangFound3.wav",
                                    "OM/Fang/voice/FangFound4.wav",
                                    "OM/Fang/voice/FangFound5.wav",
                                    "OM/Fang/voice/FangFound6.wav",
                                    "OM/Fang/voice/FangFound7.wav",
                                    "OM/Fang/voice/FangFound8.wav"
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )

                    end
                else
                    if not ent.Fang_lockin_entity_tablelist then
                        ent.Fang_lockin_entity_tablelist = {1,2,3}
                        ent.fang_lockin_minigame_cd = CurTime() + 1
                    end

                    local target = ent:GetNW2Entity("Fang_lockin_entity")
                    ent.Fang_Lockin_lerp = Lerp(FrameTime()*2,ent.Fang_Lockin_lerp, 1)

                    if IsValid(target) then
                        ent:SetNW2Float("Fang_lockin", CurTime()+0.1)
                        --local targetPos = target:WorldSpaceCenter() + Vector(0,0,25)
                        --local direction = targetPos - ply:EyePos()
                        --local targetAng = direction:Angle()

                        --ply:SetEyeAngles(LerpAngle(ent.Fang_Lockin_lerp, ply:EyeAngles(), targetAng))

                        local plyPos = ply:EyePos()
                        local tr1 = util.TraceLine({
                            start = plyPos,
                            endpos = targetPos,
                            filter = {ply, target},
                            mask = MASK_VISIBLE
                        })

                        local tr2 = util.TraceLine({
                            start = targetPos,
                            endpos = plyPos,
                            filter = {ply, target},
                            mask = MASK_VISIBLE
                        })

                        local trace = util.TraceLine({start = ply:EyePos(), endpos = target:EyePos(), filter = {ent, ply}, mask = MASK_VISIBLE})

                        local bothVisible = not trace.Hit--not tr1.Hit and not tr2.Hit

                        if not bothVisible then
                            ent:SetNW2Entity("Fang_lockin_entity", NULL)
                        else
                            if not ent.fang_lockin_minigame_cd or ent.fang_lockin_minigame_cd <= CurTime() then
                                ent.fang_lockin_minigame_cd = CurTime() + 0.5

                                if #ent.Fang_lockin_entity_tablelist <= 0 then
                                    -- shoot bullet

                                    ent:SetNW2Bool("Fang_snipe_enabled", false)
                                    local amount =  ent:GetNW2Float("Fang_shootingCount", 0)

                                    local cd = GetConVar("OUTCOMEMORIES_N_fang_gun_misscd"):GetFloat()
                                    ent:SetNW2Float("movesettoggle_cd", CurTime()+cd)
                                    ent:SetNW2Float("movesettoggle_dur", cd)

                                    ent.AlternatePlaySolution = true
                                    ent:PillAnim("Shooting")
                                    ent.AlternatePlaySolution = false
                                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.8)

                                    if amount >= 1 then
                                        local Bullet = ents.Create("prop_dynamic")

                                        if IsValid(Bullet) then


                                            AdvancedPillSound(
                                                {
                                                    stringe = {
                                                        "OM/Fang/gunshot1.wav",
                                                        "OM/Fang/gunshot2.wav",
                                                    },
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )

                                            Bullet:SetModel("models/Noodles/OM/Fang/cork.mdl")
                                            local puppet = ent:GetPuppet()
                                            local startpos = puppet:GetPos()+ puppet:GetUp()*30 + puppet:GetForward()*10
                                            Bullet:SetPos(startpos)
                                            local currentent = ent:GetNW2Entity("Fang_lockin_entity")
                                            local direction = ((currentent:GetPos()+Vector(0,0,30) )-startpos):Angle()
                                            Bullet:SetAngles(direction)

                                            Bullet:Spawn()
                                            Bullet:Activate()
                                            ent:DeleteOnRemove(Bullet)


                                            if amount == 1 then
                                                Bullet:SetNW2Float("Fang_Gun_cork_white", CurTime()+15)
                                                local cd = GetConVar("OUTCOMEMORIES_N_fang_gun_Onetarget"):GetFloat()
                                                ent:SetNW2Float("movesettoggle_cd", CurTime()+cd)
                                                ent:SetNW2Float("movesettoggle_dur", cd)

                                            elseif amount == 2 then
                                                Bullet:SetNW2Float("Fang_Gun_cork_yellow", CurTime()+2)

                                                local cd = GetConVar("OUTCOMEMORIES_N_fang_gun_Twotarget"):GetFloat()
                                                ent:SetNW2Float("movesettoggle_cd", CurTime()+cd)
                                                ent:SetNW2Float("movesettoggle_dur", cd)
                                            elseif amount == 3 then
                                                Bullet:SetNW2Float("Fang_Gun_cork_red", CurTime()+2)

                                                local cd = GetConVar("OUTCOMEMORIES_N_fang_gun_ThreeTarget"):GetFloat()
                                                ent:SetNW2Float("movesettoggle_cd", CurTime()+cd)
                                                ent:SetNW2Float("movesettoggle_dur", cd)
                                            end



                                            local TrailEnt = ents.Create("prop_dynamic")

                                            if IsValid(TrailEnt) then
                                                TrailEnt:SetModel("models/props_junk/PopCan01a.mdl")
                                                TrailEnt:SetPos(Bullet:GetPos())
                                                TrailEnt:SetAngles(Bullet:GetAngles())

                                                TrailEnt:SetParent(Bullet)

                                                TrailEnt:Spawn()
                                                TrailEnt:Activate()

                                                TrailEnt:SetNoDraw(true)

                                                util.SpriteTrail(
                                                    TrailEnt,
                                                    0,
                                                    Color(255, 255, 255),
                                                    false,
                                                    50,
                                                    0,
                                                    1,
                                                    1 / 8,
                                                    "trails/laser"
                                                )

                                            end

                                            Bullet:CallOnRemove("RemoveTrailEnt", function()
                                                if IsValid(TrailEnt) then
                                                    TrailEnt:SetParent(NULL)
                                                    timer.Simple(1.1,function()
                                                        if !IsValid(TrailEnt) then return end
                                                        TrailEnt:Remove()
                                                    end )
                                                end
                                            end)

                                            local hookID = "Fang_BulletThink_" .. Bullet:EntIndex()
                                            local startTime = CurTime()
                                            local duration = 0.14

                                            hook.Add("Think", hookID, function()

                                                if not IsValid(Bullet) then
                                                    hook.Remove("Think", hookID)
                                                    return
                                                end

                                                if not IsValid(currentent) then
                                                    hook.Remove("Think", hookID)
                                                    Bullet:Remove()
                                                    return
                                                end

                                                local frac = math.Clamp(
                                                    (CurTime() - startTime) / duration,
                                                    0,
                                                    1
                                                )

                                                local targetPos = currentent:GetPos() + Vector(0, 0, 30)

                                                Bullet:SetPos(
                                                    LerpVector(frac, startpos, targetPos)
                                                )

                                                Bullet:SetAngles(
                                                    (targetPos - Bullet:GetPos()):Angle()
                                                )

                                                if frac >= 1 or Bullet:GetPos():Distance(targetPos) <= 30 then
                                                    Bullet:SetPos(targetPos)

                                                    hook.Remove("Think", hookID)

                                                    local Cork = ents.Create("prop_physics")

                                                    if IsValid(Cork) then
                                                        Cork:SetModel("models/Noodles/OM/Fang/cork.mdl")
                                                        Cork:SetPos(targetPos)
                                                        Cork:SetAngles(Bullet:GetAngles())

                                                        Cork:Spawn()
                                                        Cork:Activate()

                                                        Cork:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

                                                        local phys = Cork:GetPhysicsObject()

                                                        if IsValid(phys) then
                                                            local awayDir = (startpos - targetPos):GetNormalized()

                                                            local flingVelocity =
                                                                awayDir * 300 +
                                                                Vector(0, 0, 300)

                                                            phys:SetVelocity(flingVelocity)

                                                            phys:AddAngleVelocity(Vector(
                                                                math.random(-100, 100),
                                                                math.random(-100, 100),
                                                                math.random(-100, 100)
                                                            ))
                                                        end

                                                        Cork:SetRenderMode(RENDERMODE_TRANSALPHA)

                                                        AdvancedPillSound(
                                                            {
                                                                stringe = {
                                                                    "OM/Fang/voice/FangSnipe1.wav",
                                                                    "OM/Fang/voice/FangSnipe2.wav",
                                                                    "OM/Fang/voice/FangSnipe3.wav",
                                                                    "OM/Fang/voice/FangSnipe4.wav",
                                                                    "OM/Fang/voice/FangSnipe5.wav",
                                                                    "OM/Fang/voice/FangSnipe6.wav",
                                                                },
                                                                pitchPercent = 100,
                                                                volume = 1,
                                                                soundLevel = 87
                                                            },
                                                            ent
                                                        )

                                                        if amount == 1 then
                                                            Cork:SetNW2Float("Fang_Gun_cork_white", CurTime()+2)

                                                            local direction = Bullet:GetAngles()

                                                            timer.Simple(0.1, function()
                                                                if not IsValid(currentent) then return end

                                                                currentent:SetPos(currentent:GetPos()+Vector(0,0,30))
                                                                currentent:SetVelocity(direction:Forward() * 7500 + Vector(0,0,140))
                                                            end)

                                                            AdvancedPillSound(
                                                                {
                                                                    stringe = "OM/Amy/WeirdCrowbarHit.wav",
                                                                    pitchPercent = 100,
                                                                    volume = 1,
                                                                    soundLevel = 87
                                                                },
                                                                currentent
                                                            )
                                                        elseif amount == 2 then
                                                            Cork:SetNW2Float("Fang_Gun_cork_yellow", CurTime()+2)


                                                            currentent:SetNW2Float("Fang_Gun_corkslowdown", CurTime()+7)

                                                            local direction = Bullet:GetAngles()

                                                            timer.Simple(0.1, function()
                                                                if not IsValid(currentent) then return end

                                                                currentent:SetPos(currentent:GetPos()+Vector(0,0,30))
                                                                currentent:SetVelocity(direction:Forward() * 3000 + Vector(0,0,200))
                                                            end)

                                                            AdvancedPillSound(
                                                                {
                                                                    stringe = "OM/Amy/WeirdCrowbarHit.wav",
                                                                    pitchPercent = 100,
                                                                    volume = 1,
                                                                    soundLevel = 87
                                                                },
                                                                currentent
                                                            )
                                                        elseif amount == 3 then
                                                            Cork:SetNW2Float("Fang_Gun_cork_red", CurTime()+2)

                                                            if IsValid(currentent) then
                                                                local canstunstack = GetConVar("OUTCOMEMORIES_N_fang_gun_stunstack"):GetBool()
                                                                if Mutual_OMCanStun(ply, ent, currentent, canstunstack) then

                                                                    Mutaul_OMStunCode(
                                                                        {
                                                                            ["ply"] = ply,
                                                                            ["ent"] = ent,
                                                                            ["target"] = currentent,
                                                                            ["StunDur"] = GetConVar("OUTCOMEMORIES_N_fang_gun_corkstunduration"):GetFloat(),
                                                                            ["stunfunction"] = function(shouldstundamage)
                                                                                if shouldstundamage then
                                                                                    currentent:SetNW2Float("Amy_highlight_pill_red", CurTime()+0.5*0.35)

                                                                                    local ed = EffectData()
                                                                                    ed:SetOrigin(currentent:GetPos() + Vector(0,0,40))
                                                                                    util.Effect("Amy_hammerhit_new", ed)

                                                                                    local direction = Bullet:GetAngles()

                                                                                    timer.Simple(0.1, function()
                                                                                        if not IsValid(currentent) then return end

                                                                                        currentent:SetVelocity(direction:Forward() * 750)
                                                                                    end)

                                                                                    AdvancedPillSound(
                                                                                        {
                                                                                            stringe = "OM/Amy/WeirdCrowbarHit.wav",
                                                                                            pitchPercent = 100,
                                                                                            volume = 1,
                                                                                            soundLevel = 87
                                                                                        },
                                                                                        currentent
                                                                                    )

                                                                                    if GetConVar("OUTCOMEMORIES_N_fang_gun_canragdoll"):GetBool() then
                                                                                        local flung = false
                                                                                        local last = CurTime() +2
                                                                                        local enemyragdoll = CreateRagdolLCharacter_OM({
                                                                                            target = currentent,
                                                                                            host = ent,

                                                                                            shouldremove = function(createfakeragdoll)
                                                                                                if not IsValid(createfakeragdoll) then return true end
                                                                                                if not IsValid(currentent) then return true end
                                                                                                if not IsValid(ent) then return true end

                                                                                                local pos = createfakeragdoll:GetPos()
                                                                                                            
                                                                                                local tr = util.TraceLine({
                                                                                                    start = pos,
                                                                                                    endpos = pos - Vector(0, 0, 10),
                                                                                                    filter = createfakeragdoll
                                                                                                })

                                                                                                if (last < CurTime() and tr.Hit ) or currentent:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime() then
                                                                                                    return true
                                                                                                else
                                                                                                    if not tr.Hit then
                                                                                                        last = CurTime() + 5.25
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

                                                                                                local dir = (ragPos - entPos):GetNormalized()

                                                                                                local force = dir * 800

                                                                                                local phys = createfakeragdoll:GetPhysicsObject()
                                                                                                if IsValid(phys) then
                                                                                                    phys:SetVelocity(force)
                                                                                                    phys:AddAngleVelocity(VectorRand() * 300)
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
                                                                                    end

                                                                                end
                                                                            end,
                                                                            ["shouldstack"] = canstunstack,
                                                                            ["Damage"] = GetConVar("OUTCOMEMORIES_N_fang_gun_corkdamage"):GetFloat(),
                                                                            ["DamageType"] = DMG_BULLET
                                                                        }
                                                                    )
                                                                end
                                                            end

                                                        end

                                                        timer.Simple(7, function()
                                                            if not IsValid(Cork) then return end

                                                            local fadeStart = CurTime()
                                                            local fadeDuration = 1

                                                            local hookID = "CorkFade_" .. Cork:EntIndex()

                                                            hook.Add("Think", hookID, function()
                                                                if not IsValid(Cork) then
                                                                    hook.Remove("Think", hookID)
                                                                    return
                                                                end

                                                                local frac = math.Clamp(
                                                                    (CurTime() - fadeStart) / fadeDuration,
                                                                    0,
                                                                    1
                                                                )

                                                                Cork:SetColor(Color(255, 255, 255, 255 * (1 - frac)))

                                                                if frac >= 1 then
                                                                    hook.Remove("Think", hookID)
                                                                    Cork:Remove()
                                                                end
                                                            end)
                                                        end)
                                                    end

                                                    Bullet:Remove()
                                                end
                                            end)
                                        end
                                    else
                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/Fang/voice/missshoot.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        )
                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/Fang/gunend.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        )
                                    end

                                else

                                    local randomNumber = table.Random(ent.Fang_lockin_entity_tablelist)
                                    ent:SetNW2Float("Fang_FlashUp"..randomNumber, CurTime()+0.26)
                                    if randomNumber then
                                        table.RemoveByValue(ent.Fang_lockin_entity_tablelist, randomNumber)
                                    end
                                end
                                
                                if #ent.Fang_lockin_entity_tablelist <= 0 then
                                    ent.fang_lockin_minigame_cd = CurTime() + 0.75
                                end
                            end
                        end

                    end
                end
            else
                ent.Fang_Lockin_lerp = 0
                ent:SetNW2Entity("Fang_lockin_entity", NULL)
            end

            if ent:GetNW2Float("fang_launchtowards_step") >= 1 then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.1) 
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.1)
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)

                if ent:GetNW2Float("fang_launchtowards_step") == 4 then
                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 90)) do
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                            if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then continue end
                            if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                            if IsValid(ent2) then

                                local vel2 = ent:GetPuppet():GetForward() * -400
                                vel2.z = 100
                                vel2 = vel2 * 2
                                if ply:IsPlayer() then
                                    ply:SetPos(ply:GetPos()+ply:GetUp()*5)
                                    ply:SetLocalVelocity(vel2)
                                else
                                    ply:SetVelocity(vel2)
                                    ply:SetPos(ply:GetPos()+ply:GetUp()*40)
                                end

                                local vel2 = (ent2:GetPos() - ent:GetPos()):GetNormalized() * 3600
                                vel2.z = 200
                                if ent2:IsPlayer() then
                                    ent2:SetLocalVelocity(vel2)
                                    ent2:SetPos(ent2:GetPos()+ent2:GetUp()*5)
                                else
                                    ent2:SetVelocity(vel2)
                                    ent2:SetPos(ent2:GetPos()+ent2:GetUp()*40)
                                end

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/cream/DashHit.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = {
                                            "OM/Fang/voice/Effort1.wav",
                                            "OM/Fang/voice/Effort2.wav",
                                            "OM/Fang/voice/Effort3.wav",
                                            "OM/Fang/voice/Effort4.wav"
                                        },
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/Fang/landhit.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                ent:SetNW2Float("fang_launchtowards_step", 0)
                                ent.AlternatePlaySolution = true
                                ent:PillAnim("BounceChargePos5")
                                ent.AlternatePlaySolution = false
                                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+1.1)
                                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+1.1)

                                local cd = GetConVar("OUTCOMEMORIES_N_fang_bounce_cd"):GetFloat()
                                ent:SetNW2Float("mobilityability_cd", CurTime()+cd)
                                ent:SetNW2Float("mobilityability_dur", cd)

                                ent:GetPuppet():SetNW2Float("Fang_Gun_flashwhite", CurTime()+0.2)


                                break
                            end
                        end
                    end

                    if ent:GetNW2Float("CantLand_fang") <= CurTime() then
                        if ply:IsOnGround() then

                            local cd = GetConVar("OUTCOMEMORIES_N_fang_bounce_cd"):GetFloat()
                            ent:SetNW2Float("mobilityability_cd", CurTime()+cd)
                            ent:SetNW2Float("mobilityability_dur", cd)

                            ent:SetNW2Float("fang_launchtowards_step", 0)
                            ent:GetPuppet():SetNW2Float("Fang_Gun_flashwhite", CurTime()+0.2)

                            --[[
                            AdvancedPillSound(
                                {
                                    stringe = "OM/Fang/bounceend.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                            ]]

                        end



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
                                    ent:SetNW2Float("fang_launchtowards_step",0)

                                    ent:GetPuppet():SetNW2Float("MetalSonicbump_highlight", CurTime()+0.5)
                                    ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5)

                                    AdvancedPillSound(
                                        {
                                            stringe = "OM/metal/WallBump.wav",
                                            pitchPercent = 100,
                                            volume = 0.75,
                                            soundLevel = 87
                                        },
                                        ent
                                    )

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


                                    local cd = GetConVar("OUTCOMEMORIES_N_fang_bounce_cd"):GetFloat()
                                    ent:SetNW2Float("mobilityability_cd", CurTime()+cd)
                                    ent:SetNW2Float("mobilityability_dur", cd)

                                    AdvancedPillSound(
                                        {
                                            stringe = {
                                                "OM/Fang/voice/Hurt1.wav",
                                                "OM/Fang/voice/Hurt2.wav",
                                                "OM/Fang/voice/Hurt3.wav",
                                                "OM/Fang/voice/Hurt4.wav"
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
                    end


                end
                if ent:GetNW2Float("fang_launchtowards_step") == 1 then
                    if not ent.fang_launchtowards_step1 then
                        ent.fang_launchtowards_step1 = true
                        ent:SetNW2Float("fang_launchtowards_step1_duration", CurTime()+0.1)
                        AdvancedPillSound(
                            {
                                stringe = "OM/Amy/HammerThrowCancel.wav",
                                pitchPercent = 100,
                                volume = 2,
                                soundLevel = 87
                            },
                            ent
                        )
                    end
                    if ent:GetNW2Float("fang_launchtowards_step1_duration") <= CurTime() then
                        ent:SetNW2Float("fang_launchtowards_step", 2)
                    end
                end
                if ent:GetNW2Float("fang_launchtowards_step") == 2 then
                    if not ent.fang_launchtowards_step2 then
                        ent.fang_launchtowards_step2 = true
                        ent:SetNW2Float("fang_launchtowards_step2_duration", CurTime()+0.4)
                    end
                    if ent:GetNW2Float("fang_launchtowards_step2_duration") <= CurTime() then
                        ent.AlternatePlaySolution = true
                        ent:PillAnim("BounceChargePos3")
                        ent.AlternatePlaySolution = false
                        ent:SetNW2Float("fang_launchtowards_step", 4)
                        ent:SetNW2Float("CantLand_fang", CurTime()+0.65)


                        local aiming = ply:GetAimVector()*1000

                        aiming.x = math.Clamp(aiming.x*0.8, -1e9, 1e9)
                        aiming.y = math.Clamp(aiming.y*0.8, -1e9, 1e9)
                        aiming.z = math.Clamp(aiming.z, 200, 1e9)

                        if ply:IsPlayer() then
                            ply:SetPos(ply:GetPos()+Vector(0,0,10))

                            ply:SetLocalVelocity(aiming)
                        else
                            aiming = aiming * 1.4
                            ply:SetPos(ply:GetPos()+Vector(0,0,30))

                            ply:SetVelocity(aiming)
                        end

                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/Fang/voice/Effort1.wav",
                                    "OM/Fang/voice/Effort2.wav",
                                    "OM/Fang/voice/Effort3.wav",
                                    "OM/Fang/voice/Effort4.wav"
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )

                        AdvancedPillSound(
                            {
                                stringe = "OM/Fang/fangbounce.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )

                    end
                end
            else
                ent.fang_launchtowards_step2 = false
                ent.fang_launchtowards_step1 = false
            end


            local function handlenextbotplayer(ply, ent)
                ent.Fang_Lockin_lerp = ent.Fang_Lockin_lerp or 0

                if ent:GetNW2Float("Fang_lockin") >= CurTime()
                    and ent:GetNW2Bool("Fang_snipe_enabled") then

                    local target = ent:GetNW2Entity("Fang_lockin_entity")

                    if IsValid(target) then
                        ent.Fang_Lockin_lerp = Lerp(FrameTime() * 4, ent.Fang_Lockin_lerp, 1)

                        local targetPos = target:WorldSpaceCenter() + Vector(0, 0, 40)
                        local direction = targetPos - ply:EyePos()
                        local targetAng = direction:Angle()

                        local currentAng = ply:EyeAngles()

                        ply:SetAngles(targetAng)
                    else
                        ent.Fang_Lockin_lerp = Lerp(FrameTime() * 8, ent.Fang_Lockin_lerp, 0)
                    end
                else
                    ent.Fang_Lockin_lerp = Lerp(FrameTime() * 8, ent.Fang_Lockin_lerp, 0)
                end
            end

            if ent:IsNextBot() then
                handlenextbotplayer(ply, ent)
            end

        else
            local function handlenextbotplayer(ply, ent)
                ent.Fang_Lockin_lerp = ent.Fang_Lockin_lerp or 0

                if ent:GetNW2Float("Fang_lockin") >= CurTime()
                    and ent:GetNW2Bool("Fang_snipe_enabled") then

                    local target = ent:GetNW2Entity("Fang_lockin_entity")

                    if IsValid(target) then
                        ent.Fang_Lockin_lerp = Lerp(FrameTime() * 4, ent.Fang_Lockin_lerp, 1)

                        local targetPos = target:WorldSpaceCenter() + Vector(0, 0, 40)
                        local direction = targetPos - ply:EyePos()
                        local targetAng = direction:Angle()

                        local currentAng = ply:EyeAngles()

                        ply:SetEyeAngles(
                            LerpAngle(
                                ent.Fang_Lockin_lerp*(FrameTime()*5),
                                currentAng,
                                targetAng
                            )
                        )
                    else
                        ent.Fang_Lockin_lerp = Lerp(FrameTime() * 8, ent.Fang_Lockin_lerp, 0)
                    end
                else
                    ent.Fang_Lockin_lerp = Lerp(FrameTime() * 8, ent.Fang_Lockin_lerp, 0)
                end
            end

            if LocalPlayer() == ply then
                handlenextbotplayer(ply, ent)
            end 
            if LocalPlayer():GetNW2Entity("DrGBasePossessing") == ent then
                handlenextbotplayer(LocalPlayer(), ent)
            end
        end
    end,


    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if button == KEY_1 then
            end
            if button == ply:GetInfoNum("om_pills_action_fang_gun_key", KEY_E) then

                if not GetConVar("OUTCOMEMORIES_N_fang_gun_useable"):GetBool() then return end

                if ent:GetNW2Float("movesettoggle_cd") >= CurTime() then return end
                if ent:GetNW2Float("fang_launchtowards_step") >= 1 then return end
                local target = ent:GetNW2Entity("Fang_lockin_entity")
                if IsValid(target) then return end

                if ent:GetNW2Bool("Fang_snipe_enabled") then
                    ent:SetNW2Bool("Fang_snipe_enabled", false)
                    AdvancedPillSound(
                        {
                            stringe = "OM/Fang/gunstart.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                else
                    ent:SetNW2Bool("Fang_snipe_enabled", true)
                    AdvancedPillSound(
                        {
                            stringe = "OM/Fang/gunend.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end

                ent:GetPuppet():SetNW2Float("Fang_Gun_flashwhite", CurTime()+0.2)

                local cd = GetConVar("OUTCOMEMORIES_N_fang_gun_cancelcd"):GetFloat()
                ent:SetNW2Float("movesettoggle_cd", CurTime()+cd)
                ent:SetNW2Float("movesettoggle_dur", cd)
            end
            if button == ply:GetInfoNum("om_pills_action_fang_bounce_key", KEY_T) then
                if not GetConVar("OUTCOMEMORIES_N_fang_bounce_useable"):GetBool() then return end
                if ent:GetNW2Float("mobilityability_cd") >= CurTime() then return end
                if ent:GetNW2Bool("Fang_snipe_enabled") then return end
                if ent:GetNW2Float("fang_launchtowards_step") >= 1 then return end
                ent:SetNW2Float("fang_launchtowards_step", 1)
                ent:GetPuppet():SetNW2Float("Fang_Gun_flashwhite", CurTime()+0.2)
            end
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply,ent,button)
        if SERVER then
            if button == ply:GetInfoNum("om_pills_action_fang_bounce_key", KEY_T) then
            end
        end
    end,

    attack = {
        mode = 'tick',
        func = function(ply, ent)
            if ent:GetNW2Bool("Fang_snipe_enabled") then
                ent:SetNW2Float("Fang_lockin", CurTime()+0.1)
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
        if ent:GetNW2Bool("movesettoggle_bool") then
            ent:PillAnim('jumpshoot')
        else
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
