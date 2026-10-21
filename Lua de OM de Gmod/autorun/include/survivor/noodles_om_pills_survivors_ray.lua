
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
    ["OM_ray_trickortreat"] = Material("icons/OM_ray_trickortreat.png"),
    ["OM_ray_tornado"] = Material("icons/OM_ray_tornado.png"),
    ["OM_ray_dash"] = Material("icons/OM_ray_dash.png"),
}


if SERVER then
    --[[
    timer.Simple(1,function()
        if SERVER then else return end
        OM_AddSpeedConfigeration(function(entity)
            if SERVER and entity:GetNW2Float("ray_afterimage_debuff_duration_slowdown", 0) >= CurTime() then
                return 0.6
            end
            return 1
        end)
    end)
    ]]
end

--[[
hook.Add("SetupMove", "ray_slowdown_debuff", function(ply, mv, cmd)
    if !IsValid(ply) then return end
    if !ply:Alive() then return end

    if ply:GetNW2Float("ray_afterimage_debuff_duration_slowdown", 0) >= CurTime() then
        local vel = mv:GetVelocity()

        vel.x = vel.x * 0.6
        vel.y = vel.y * 0.6

        mv:SetVelocity(vel)
    end
end)
]]

pk_pills.register('pill_om_Ray', {

    printName='Ray',
    Outcomememories='Ray',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/ray.mdl",
    --[[
    hull = Vector(20,20,60),
    duckBy = 14,
    ]]
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',


    OM_UI_custom_end = function(ply, ent)
        local screenW, screenH = ScrW(), ScrH()
        local basevalue = math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat", 50), 0, 100)
        ent.Ray_TrickOrTreatValue = ent.Ray_TrickOrTreatValue or 0
        ent.Ray_TrickOrTreatValue = Lerp(FrameTime()*5, ent.Ray_TrickOrTreatValue, basevalue)
        local value = ent.Ray_TrickOrTreatValue

        local barW, barH = 58, math.min(screenH * 0.48, 650)

        local x = 30
        local y = screenH * 0.5 - barH * 0.5

        local dark = Color(13, 7, 19, 250)
        local purple = Color(112, 55, 155, 255)
        local purpleDark = Color(53, 24, 70, 255)

        local orange = Color(238, 83, 25, 255)
        local orangeDark = Color(170, 48, 17, 255)

        local white = Color(255, 245, 225, 255)

        local centerX = x + barW * 0.5
        local halfH = barH * 0.5
        local t = CurTime()

        -- OUTER GLOW

        local pulse = 8 + math.sin(t * 2) * 3

        draw.RoundedBox(
            18,
            x - 8,
            y - 8,
            barW + 16,
            barH + 16,
            Color(255, 100, 30, 18 + pulse)
        )

        draw.RoundedBox(
            16,
            x - 5,
            y - 5,
            barW + 10,
            barH + 10,
            Color(70, 25, 90, 180)
        )

        -- OUTER FRAME

        draw.RoundedBox(
            15,
            x - 3,
            y - 3,
            barW + 6,
            barH + 6,
            purpleDark
        )

        surface.SetDrawColor(255, 120, 35, 255)
        surface.DrawOutlinedRect(
            x - 3,
            y - 3,
            barW + 6,
            barH + 6,
            2
        )

        draw.RoundedBox(
            12,
            x,
            y,
            barW,
            barH,
            dark
        )

        -- TICK MARKS

        surface.SetDrawColor(255, 255, 255, 35)

        for i = 1, 9 do
            local tickY = y + (barH / 10) * i

            surface.DrawRect(x - 12, tickY, 7, 1)
            surface.DrawRect(x + barW + 5, tickY, 7, 1)
        end

        -- TRICK SECTION

        draw.RoundedBox(
            10,
            x + 5,
            y + halfH,
            barW - 10,
            halfH - 5,
            purple
        )

        if value < 50 then
            local trickProgress = value / 50

            surface.SetDrawColor(30, 12, 42, 145)

            surface.DrawRect(
                x + 5,
                y + halfH + 5,
                barW - 10,
                (halfH - 10) * (1 - trickProgress)
            )
        end

        -- TREAT SECTION

        draw.RoundedBox(
            10,
            x + 5,
            y + 5,
            barW - 10,
            halfH - 5,
            orangeDark
        )

        if value > 50 then
            local treatProgress =
                math.Clamp((value - 50) / 50, 0, 1)

            local orangeHeight =
                (halfH - 5) * treatProgress

            render.SetScissorRect(
                math.floor(x + 5),
                math.floor(y + halfH - orangeHeight),
                math.floor(x + barW - 5),
                math.floor(y + halfH),
                true
            )

            draw.RoundedBox(
                10,
                x + 5,
                y + 5,
                barW - 10,
                halfH - 5,
                orange
            )

            render.SetScissorRect(0, 0, 0, 0, false)
        end


        local trickLetters = {"T", "R", "I", "C", "K"}
        local treatLetters = {"T", "R", "E", "A", "T"}

        local trickSpacing = 27
        local treatSpacing = 27

        local trickCenterY, treatCenterY = y + halfH + halfH * 0.5,y + halfH * 0.5

        local trickStart = trickCenterY - (#trickLetters - 1) * trickSpacing * 0.5
        local treatStart = treatCenterY - (#treatLetters - 1) * treatSpacing * 0.5

        local trickOffset = math.sin(t * 1.35) * 7
        local treatOffset = math.sin(t * 1.15 + 2) * 7

        for i, letter in ipairs(trickLetters) do
            local letterWave = math.sin(t * 2.1 + i * 0.8) * 4
            local letterX, letterY = centerX + trickOffset, trickStart + (i - 1) * trickSpacing + letterWave

            draw.SimpleText(
                letter,
                "DermaLarge",
                letterX + 2,
                letterY + 3,
                Color(20, 5, 30, 180),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )

            draw.SimpleText(
                letter,
                "DermaLarge",
                letterX,
                letterY,
                Color(245, 225, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
        end

        for i, letter in ipairs(treatLetters) do
            local letterWave = math.sin(t * 2.0 + i * 0.75 + 2) * 4
            local letterX, letterY = centerX + treatOffset, treatStart + (i - 1) * treatSpacing + letterWave

            draw.SimpleText(
                letter,
                "DermaLarge",
                letterX + 2,
                letterY + 3,
                Color(50, 10, 5, 190),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )

            draw.SimpleText(
                letter,
                "DermaLarge",
                letterX,
                letterY,
                white,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
        end



        surface.SetDrawColor(12, 6, 17, 240)

        surface.DrawRect(
            x + 3,
            y + halfH - 4,
            barW - 6,
            8
        )

        surface.SetDrawColor(255, 170, 55, 255)

        surface.DrawRect(
            x + 8,
            y + halfH - 1,
            barW - 16,
            2
        )

        surface.SetDrawColor(255, 130, 40, 45)

        surface.DrawRect(
            x + 5,
            y + halfH - 6,
            barW - 10,
            12
        )



        draw.RoundedBox(
            5,
            x - 8,
            y - 9,
            barW + 16,
            7,
            Color(28, 12, 38, 245)
        )

        surface.SetDrawColor(255, 125, 40, 255)
        surface.DrawRect(
            x - 5,
            y - 6,
            barW + 10,
            2
        )

        draw.RoundedBox(
            5,
            x - 8,
            y + barH + 2,
            barW + 16,
            7,
            Color(28, 12, 38, 245)
        )

        surface.SetDrawColor(120, 60, 165, 255)
        surface.DrawRect(
            x - 5,
            y + barH + 4,
            barW + 10,
            2
        )



        surface.SetDrawColor(255, 125, 40, 255)

        surface.DrawOutlinedRect(
            x,
            y,
            barW,
            barH,
            2
        )



        -- PERCENTAGE BADGE

        local percentage = math.Round(value)
        local badgeW, badgeH = 92, 38
        local badgeX, badgeY = centerX - badgeW * 0.5, y + halfH - badgeH * 0.5

        draw.RoundedBox(
            12,
            badgeX - 3,
            badgeY - 3,
            badgeW + 6,
            badgeH + 6,
            Color(255, 110, 30, 25)
        )

        draw.RoundedBox(
            10,
            badgeX + 3,
            badgeY + 4,
            badgeW,
            badgeH,
            Color(0, 0, 0, 210)
        )

        draw.RoundedBox(
            10,
            badgeX,
            badgeY,
            badgeW,
            badgeH,
            Color(18, 9, 24, 250)
        )

        surface.SetDrawColor(255, 120, 35, 255)

        surface.DrawRect(
            badgeX + 4,
            badgeY + 3,
            badgeW - 8,
            3
        )

        surface.SetDrawColor(120, 60, 165, 255)

        surface.DrawRect(
            badgeX + 4,
            badgeY + badgeH - 6,
            badgeW - 8,
            3
        )

        draw.SimpleText(
            percentage .. "%",
            "DermaLarge",
            centerX + 2,
            badgeY + badgeH * 0.5 + 2,
            Color(0, 0, 0, 220),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText(
            percentage .. "%",
            "DermaLarge",
            centerX,
            badgeY + badgeH * 0.5,
            Color(255, 245, 225, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end,




    ShouldRoll_om = function(e, ply, ent)
        return true
    end,

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["OM_ray_trickortreat"]
            end,
            name = function(uselessvar,ply,ent)
                return "Trick Or Treat"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_E
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("TrickOrTreat_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("TrickOrTreat_dur")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.02, yaxis = 0 + iconsize*-0.05, xsize = 0-iconsize*0.07, ysize = 0-iconsize*0.07}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["OM_ray_tornado"]
            end,
            name = function(uselessvar,ply,ent)
                return "Tornado"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_R
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Tornado_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Tornado_dur")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.1, yaxis = 0 + iconsize*0.15, xsize = 0-iconsize*0.2, ysize = 0-iconsize*0.2}
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
                    return 420
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
            Peelout= function(ply,ent)
                if SERVER then
                    return 1450
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return 2
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return 1400
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
            TrickOrTreatThrow = "TrickOrTreatThrow",
        },

        ShouldMoveRotate={
            GlideGoUp= function(ent) 
                if ent:GetNW2Float("OM_Ray_throwing_duration") >= CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return "" end
                return 'notanything' 
            end,
            idle= function(ent) 
                if ent:GetNW2Bool("OM_Ray_gliding") then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_throwing_duration") >= CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return "" end
                return 'notanything' 
            end,
            run= function(ent) 
                if ent:GetNW2Bool("OM_Ray_gliding") then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_throwing_duration") >= CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return "" end
                return 'notshftlock'
            end,
            walk= function(ent) 
                if ent:GetNW2Bool("OM_Ray_gliding") then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_throwing_duration") >= CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return "" end
                return 'notshftlock'
            end,
            fall= function(ent) 
                if ent:GetNW2Bool("OM_Ray_gliding") then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_throwing_duration") >= CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return "" end
                return 'notshftlock'
            end,
            TrickOrTreatThrow= function(ent) 
                if ent:GetNW2Bool("OM_Ray_gliding") then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_throwing_duration") >= CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return "" end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            walk= function(ent) 
                --if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return "Tornado" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "rolling" end
                if ent:GetNW2Float('cheer_chargeup_duration') > CurTime() then return 'ReadyDive' end
            end,
            idle= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return "Tornado" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "rolling" end
                if ent:GetNW2Float('cheer_chargeup_duration') > CurTime() then return 'ReadyDive' end
            end,
            fall= function(ent) 

                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "rolling" end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return "Tornado" end
                if ent:GetNW2Bool("OM_Ray_gliding") then
                    return "glide"
                end
                if ent:GetNW2Float("jump_animdur") > CurTime() then
                    return "jump"
                end
                if ent:GetNW2Float('cheer_chargeup_duration') > CurTime() then return 'ReadyDive' end
            end,
            run= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return "Tornado" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "rolling" end
                if ent:GetNW2Float('cheer_chargeup_duration') > CurTime() then return 'ReadyDive' end
                if ent:GetNW2Float("OM_Ray_gambling_duration") > CurTime() then return "walk" end
            end,
        },
        animrates = {
            idle = function(ent)
                return 1
            end,
            walk = function(ent)
                local ply = ent:GetPillUser()
                return 1
            end,

            run = function(ent)
                local ply = ent:GetPillUser()
                return 1
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
        if ent.OM_Ray_HasCandy or ent:GetNW2Float("OM_Ray_throwing_duration") > CurTime() then
            basetable =  {
                startoffset = Vector(25,0,25),  -- left-up, front-back, up-down
                dist=90,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 1,
                transition = 1,
                canscroll = true,
                bonecenter = "Torso",
            }
        end

        ent.OM_Ray_tornado_duration_lerp = ent.OM_Ray_tornado_duration_lerp or 0
        ent.OM_Ray_tornado_duration_lerp = Lerp(FrameTime()*6, ent.OM_Ray_tornado_duration_lerp, ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() and 1 or 0)

        basetable["fov"] = basetable["fov"] + 10 * ent.OM_Ray_tornado_duration_lerp

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
            StepSFX_OM(ply,ent)
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
    
        initializetable2["player"].ColorRGB_B_1_OM = Color(0,35,255, 255)
        if SERVER then

            initializetable2["entity"]:SetNW2Float("OM_Damage_Reduction",1)
            local health = 100
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)

            initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
            initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)
            initializetable2["entity"]:SetNW2Float("Ray_TrickOrTreat", math.Clamp(initializetable2["entity"]:GetNW2Float("Ray_TrickOrTreat") + 50, 0, 100) )
        end
        initializetable2["player"]:SetNW2Bool("OM_character", true)
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetGravity(1)
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetNW2Float("OM_NoMovement_noodles", CurTime())
            initializetable2["player"]:SetNW2Float("OM_NoMovement_noodles_jump", CurTime())
        end
    end,


    speedhandeler_om = {
        modifiers = {
            ["gambling"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("OM_Ray_gambling_duration") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.5 - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.5 - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*1.5 - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                if ent:GetNW2Float("OM_Ray_throwing_duration") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*0.5 - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*0.5 - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*0.5 - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end
                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then 
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*2.8 - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*2.8 - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*2.8 - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
        }
    },

    OM_transitionbar_type1table = {
        ColorDisplay = Color(165*1.3,75*1.3,0,255),
        CanShowcase = function(e,ply, ent)
            return ent:GetNW2Bool("OM_Ray_gliding")
        end,
        Factor = function(e,ply, ent)
            return math.Clamp((ent:GetNW2Float("OM_ray_flyingDuration")-CurTime())/ent:GetNW2Float("OM_ray_flyingDuration_numb"), 0, 1)
        end
    },

    OM_transitionbar_type2table = {
        ColorDisplay = Color(165*1.3,75*1.3,0,255),
        CanShowcase = function(e,ply, ent)
            return ent:GetNW2Float("OM_ray_flyingCooldown") > CurTime()
        end,
        Factor = function(e,ply, ent)
            local clamp = math.Clamp(( ent:GetNW2Float("OM_ray_flyingCooldown") - CurTime()) / ent:GetNW2Float("OM_ray_flyingCDDuration"), 0, 1)
            return Lerp(clamp, 1, 0)
        end,
        offset = function(e,ply, ent)
            return Vector(-20,0,0)
        end
    },

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", 1)

            local AmountToAdd = 0
            AmountToAdd = ply:GetVelocity():Length() / 40000
            if ent.OM_Ray_HasCandy then
                ent:SetNW2Float("Ray_TrickOrTreat", math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat") + AmountToAdd*0.5, 0, 100) )
            else
                ent:SetNW2Float("Ray_TrickOrTreat", math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat") + AmountToAdd, 0, 100) )
            end
            ent:SetNW2Float("Ray_TrickOrTreat", math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat") + 0.0035, 0, 100) )
            --print(ent:GetNW2Float("Ray_TrickOrTreat"))

            if ent:GetNW2Bool("OM_Ray_gliding") then
                if not ent.OM_Ray_gliding then
                    ent.OM_Ray_gliding = true
                    ent:SetNW2Float("OM_ray_flyingDuration_numb", 4)
                    ent:SetNW2Float("OM_ray_flyingDuration", CurTime()+4)
                end
                if ply:IsOnGround() or ent:GetNW2Float("OM_ray_flyingDuration") <= CurTime() then
                    ent:SetNW2Bool("OM_Ray_gliding", false)
                end
                local forward = ent:GetPuppet():GetForward()
                if not ent.directiontomove_ray then
                    ent.directiontomove_ray = forward
                end

                ent.directiontomove_ray = LerpVector(
                    FrameTime() * 2,
                    ent.directiontomove_ray,
                    forward
                )

                ply:SetLocalVelocity(
                    ent.directiontomove_ray * 600
                    + ent:GetPuppet():GetUp() * -110
                )
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
            else
                if ent.OM_Ray_gliding then
                    ent.OM_Ray_gliding = false
                    ent:SetNW2Float("OM_ray_flyingCDDuration", 10)
                    ent:SetNW2Float("OM_ray_flyingCooldown", CurTime()+10)
                end
                ent.directiontomove_ray = nil
            end
 
            if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then
                if not ent.OM_Ray_tornado_duration then
                    ent.OM_Ray_tornado_duration = true
                    ent.AddLuckk_OM_ray = false


                    AdvancedPillSound(
                        {
                            stringe = "OM/ray/snd_sparkle1.wav",
                            pitchPercent = 107,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    local fx = EffectData()
                    fx:SetEntity(ent:GetPuppet())
                    util.Effect("ray_tornado_effect", fx, true, true)

                    AdvancedPillSound(
                        {
                            stringe = "OM/ray/Bigcut.wav",
                            pitchPercent = 107,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    
                    AdvancedPillSound(
                        {
                            stringe = "OM/ray/snd_spearrise.wav",
                            pitchPercent = 107,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    
                    AdvancedPillSound(
                        {
                            stringe = "OM/ray/Ray_shootprojectile.wav",
                            pitchPercent = 107,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )


                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/PeelOutChargeUp.wav",
                            pitchPercent = 120,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    if not ent.Dashing_loop_soundloop then ent.Dashing_loop_soundloop = 0 end
                    if ent.Dashing_loop_soundloop < CurTime() then
                        ent.Dashing_loop_soundloop = CurTime() + 0.5
                        AdvancedPillSound(
                            {
                                stringe = "OM/sonic/looping3.wav",
                                pitchPercent = 120,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end

                end



                ply:SetNW2Float("OM_Damage_Reduction",50/100)

                ent:SetNW2Float("Ray_TrickOrTreat", math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat") + 0.04, 0, 100) )

                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 300)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if ent2 == ply then continue end


                    local pushDir = ((ent2:GetPos() + Vector(0,0,0)) - ply:GetPos()):GetNormalized() * -1
                    local pushForce = 700

                    if (ent2:IsPlayer() or ent2:IsNPC() or ent2:IsNextBot()) and ent2:Health() > 0.1 then
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if ent2:GetNW2Bool("OM_character") and not GetConVar("PVPStun_OM"):GetBool() then continue end
                        local iframes = false
                        if not Mutual_OMCanStun(ply, ent, ent2, false) then
                            iframes = true
                            pushDir = pushDir *-1
                        end
                        if !IsValid(ent2:GetNWEntity("OM_ragdollentity")) then

                            if ent2:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime() then
                                if ent2:IsOnGround() and (ent2:IsPlayer() or ent2:IsNPC()) then
                                    ent2:SetPos(ent2:GetPos() + Vector(0,0,15))
                                end
                                if ent2:IsOnGround() and ent2:IsNextBot() then
                                    ent2:SetPos(ent2:GetPos() + Vector(0,0,40))
                                end
                            end

                            if ent2.loco then
                                ent2.loco:SetVelocity(vector_origin)
                                ent2.loco:SetDesiredSpeed(0)
                            end

                            if ent2:IsPlayer() then
                                ent2:SetVelocity(pushDir * pushForce*0.07)
                            elseif ent2:IsNextBot() then
                                ent2:SetVelocity(pushDir * pushForce*0.8)
                            else
                                ent2:SetVelocity(pushDir * pushForce*0.07)
                            end



                            if ent2:GetPos():Distance(ent:GetPos()) <= 160 or iframes then
                            else
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/ray/Ray_charmexplosionq.wav",
                                        pitchPercent = 107,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/ray/snd_sparkle1.wav",
                                        pitchPercent = 107,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                            
                                local last = CurTime() + 2
                                local ragd = false
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

                                        if not ent.OM_Ray_tornado_duration then
                                            if not ragd then
                                                ragd = true
                                                local phys = createfakeragdoll:GetPhysicsObject()
                                                if IsValid(phys) then
                                                    phys:SetVelocity(phys:GetVelocity()*4)
                                                end
                                            end
                                        end
                                        if not ragd then 
                                            last = CurTime() + 2

                                            local phys = createfakeragdoll:GetPhysicsObject()
                                            if IsValid(phys) then
                                                local distance = ent2:GetPos():Distance(ent:GetPos())

                                                if distance > 160 then
                                                    local direction = (ent:GetPos() - ent2:GetPos()):GetNormalized()
                                                    phys:SetVelocity(direction * 900 + Vector(0, 0, 20))
                                                else
                                                    local direction = (ent2:GetPos() - ent:GetPos()):GetNormalized()
                                                    local tangent = Vector(-direction.y, direction.x, 0):GetNormalized()

                                                    phys:SetVelocity(tangent * 4000 + Vector(0, 0, 20))
                                                end
                                            end
                                        end
                                    end
                                })


                            end
                        end

                        if not ent.AddLuckk_OM_ray then
                            ent.AddLuckk_OM_ray = true
                            ent:SetNW2Float("Ray_TrickOrTreat", math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat") + 10, 0, 100) )
                        end
                        ent:SetNW2Float("Ray_TrickOrTreat", math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat") + 0.03, 0, 100) )
                    else
                        local phys = ent2:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:Wake()


                            if ent2:GetPos():Distance(ent:GetPos()) <= 160 then
                                local direction = (ent2:GetPos() - ent:GetPos()):GetNormalized()
                                local tangent = Vector(-direction.y, direction.x, 0):GetNormalized() 

                                phys:SetVelocity((tangent + Vector(0, 0, 0.9)) * 900)
                            else
                            
                                local physForce = (pushDir + Vector(0, 0, 0.1)) * pushForce * 2

                                phys:ApplyForceCenter(physForce)
                            end

                        end
                    end
                end
            else
                ply:SetNW2Float("OM_Damage_Reduction",100/100)
                if ent.OM_Ray_tornado_duration then
                    ent.OM_Ray_tornado_duration = false
                    ent:SetNW2Float("Tornado_cd", CurTime()+27)
                    ent:SetNW2Float("Tornado_dur", 27)


                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/Dashing_end.wav",
                            pitchPercent = 120,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:StopSound("OM/sonic/Dashing_loop.wav")
                    --

                end
            end

            ent:SetNW2Bool("OM_Ray_HasCandy", ent.OM_Ray_HasCandy)
        else
            ent.OM_Ray_HasCandy = ent:GetNW2Bool("OM_Ray_HasCandy")
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply,ent,button)
        if SERVER then
            if button == KEY_SPACE then
                ent:SetNW2Bool("OM_Ray_gliding", false)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if button == KEY_SPACE then
                if ply:IsOnGround() then return end
                if ent:GetNW2Float("OM_ray_flyingCooldown") >= CurTime() then return end
                --if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return end

                ent:SetNW2Bool("OM_Ray_gliding", true)
            end
            if button == KEY_E then
                if ent:GetNW2Float("TrickOrTreat_cd") > CurTime() then return end

                if ent.OM_Ray_HasCandy then return end
                if ent:GetNW2Float("OM_Ray_gambling_duration") > CurTime() then return end
                if ent:GetNW2Float("OM_Ray_throwing_duration") > CurTime() then return end

                if math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat"),0,100) < 20 then return end
                
                --if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return end

                local puppet = ent:GetPuppet()
                if IsValid(puppet) then
                    AdvancedPillSound(
                        {
                            stringe = "OM/ray/Drumroll.wav",
                            pitchPercent = 107,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1)

                    local layeredAnim = puppet:AddGesture(ACT_VM_HITRIGHT2, false)

                    local current = 1
                    puppet:SetLayerWeight(layeredAnim, current)
                    puppet:SetLayerPriority(layeredAnim, 10)

                    local duration = 105/60

                    ent:SetNW2Float("OM_Ray_gambling_duration", CurTime()+duration)
                    ent.OM_Ray_HasCandy = true

                    timer.Simple(duration, function()
                        if !IsValid(ent) or !IsValid(puppet) then return end
                        puppet:RemoveLayer(puppet:FindGestureLayer(ACT_VM_HITRIGHT2))
                        puppet:AddGesture(ACT_VM_HITRIGHT, false)
                    end)

                    local TrickOrTreat = {
                        ["Good"] = {"candy1", "candy2", "candy3"},
                        ["Bad"] = {"poisonitem1", "poisonitem2", "poisonitem3"}
                    }

                    local luck = math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat"), 0, 100)

                    local resultType = math.random(1, 100) <= luck and "Good" or "Bad"

                    local itemList = TrickOrTreat[resultType]
                    local chosenItem = itemList[math.random(#itemList)]

                    --print("Luck:", luck, "Result:", resultType, "Item:", chosenItem)

                    timer.Simple(0.8, function()
                        if !IsValid(ent) or !IsValid(puppet) then return end


                        AdvancedPillSound(
                            {
                                stringe = "OM/ray/item.wav",
                                pitchPercent = 107,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )

                        local rock = ents.Create("ent_om_ray_candydisplay")
                        if IsValid(rock) then
                            rock:SetPos(ent:GetPuppet():GetPos())
                            rock:SetPillUser(ent:GetPuppet())
                            rock:Spawn()
                            rock:GetPuppet():SetModel("models/Noodles/OM/Ray/"..chosenItem..".mdl")

                            ent:DeleteOnRemove(rock)
                            ent:SetNW2Entity("ent_om_ray_candydisplay", rock)

                            rock:GetPuppet():SetNW2Float("mighty_glowwhite", CurTime()+0.5)

                            ent:SetNW2String("candylucktype", resultType)

                            if resultType == "Good" then
                                ent:SetNW2Float("Ray_TrickOrTreat", math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat") - 50, 0, 100) )
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/ray/snd_sparkle1.wav",
                                        pitchPercent = 107,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/amy/cardupgrade.wav",
                                        pitchPercent = 107,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                                ent:GetPuppet():SetNW2Float("ray_flashgreen_OM", CurTime()+0.1)
                            else
                                ent:SetNW2Float("Ray_TrickOrTreat", math.Clamp(ent:GetNW2Float("Ray_TrickOrTreat") - 20, 0, 100) )
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/amy/cardbad.wav",
                                        pitchPercent = 107,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/amy/cardmoon.wav",
                                        pitchPercent = 107,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                                ent:GetPuppet():SetNW2Float("ray_flashred_OM", CurTime()+0.1)
                            end

                        end
                    end)



                end
            end
            if button == KEY_R then
                if ent:GetNW2Float("Tornado_cd") > CurTime() then return end

                --if ent.OM_Ray_HasCandy then return end
                --if ent:GetNW2Bool("OM_Ray_gliding") then return end
                if ent:GetNW2Float("OM_Ray_gambling_duration") > CurTime() then return end
                if ent:GetNW2Float("OM_Ray_throwing_duration") > CurTime() then return end

                if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return end

                ent:SetNW2Float("OM_Ray_tornado_duration", CurTime()+5)
                ent:GetPuppet():SetNW2Float("ray_flashwhite_OM", CurTime()+0.5)
            end
        end
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if SERVER then
                if ent:GetNW2Float("OM_Ray_gambling_duration") > CurTime() then return end
                if ent:GetNW2Float("OM_Ray_throwing_duration") > CurTime() then return end
                
                --if ent:GetNW2Float("OM_Ray_tornado_duration") > CurTime() then return end
                
                if ent.OM_Ray_HasCandy then
                    local puppet = ent:GetPuppet()
                    if IsValid(puppet) then
                        puppet:RemoveLayer(puppet:FindGestureLayer(ACT_VM_HITRIGHT))
                        ent:PillAnim("TrickOrTreatThrow")
                        ent.OM_Ray_HasCandy = false

                        ent:SetNW2Float("OM_Ray_throwing_duration", CurTime()+(76/60) )

                        if ent:GetNW2String("candylucktype") == "Good" then
                            ent:SetNW2Float("TrickOrTreat_cd", CurTime()+20)
                            ent:SetNW2Float("TrickOrTreat_dur", 20)
                            AdvancedPillSound(
                                {
                                    stringe = "OM/ray/snd_spearappear.wav",
                                    pitchPercent = 115,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                        else
                            ent:SetNW2Float("TrickOrTreat_cd", CurTime()+12)
                            ent:SetNW2Float("TrickOrTreat_dur", 12)
                            AdvancedPillSound(
                                {
                                    stringe = "OM/ray/snd_spearappear.wav",
                                    pitchPercent = 107,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                        end


                        timer.Simple(0.5, function()
                            if !IsValid(ent) or !IsValid(puppet) then return end

                            AdvancedPillSound(
                                {
                                    stringe = "OM/ray/throw.wav",
                                    pitchPercent = 80,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )

                            local candyentity = ent:GetNW2Entity("ent_om_ray_candydisplay")

                            local rock = ents.Create("ent_om_ray_candyentity")

                            if IsValid(rock) then

                                local rightBone = ent:GetPuppet():LookupBone("LeftHand")

                                if rightBone then
                                    local rightPos, rightangle = ent:GetPuppet():GetBonePosition(rightBone)
                                    rightPos = rightPos + rightangle:Forward()*-2 + rightangle:Right()*-3 + rightangle:Up()*0

                                    rightangle:RotateAroundAxis(rightangle:Forward(), 0)
                                    rightangle:RotateAroundAxis(rightangle:Right(), 0)

                                    if rightPos then
                                        if SERVER then
                                            rock:SetPos(rightPos)
                                            rock:SetAngles(rightangle)
                                        end
                                    end
                                end
                                rock:SetModel(candyentity:GetPuppet():GetModel())
                                rock:Spawn()

                                rock.Owner = ply

                                ent:DeleteOnRemove(rock)


                                local phys = rock:GetPhysicsObject()

                                if IsValid(phys) then
                                    phys:Wake()
                                    phys:SetVelocity(ply:GetAimVector() * 1500 + Vector(0,0,200))
                                    phys:SetMass(50)
                                    phys:EnableDrag(false)
                                    phys:EnableMotion(true)
                                end

                                rock:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                                rock:SetNW2Bool("ray_ability_outline2", true)
                                rock:SetNW2String("candylucktype", ent:GetNW2String("candylucktype"))
                            end
                            

                            candyentity:Remove()

                        end)

                    end
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
        if ply:GetNW2Bool("Survivor_Downed_OM") then return end


        ent:SetNW2Float("jump_animdur", CurTime()+0.1)

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