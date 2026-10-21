
AddCSLuaFile()

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
    ["eyxleap"] = Material("icons/eyxleap.png"),
    ["eyxslam"] = Material("icons/eyxslam.png"),
    ["eyxscreech"] = Material("icons/eyxscreech.png"),
    ["infectioneyx"] = Material("icons/infectioneyx.png"),
}
local grad = Material("vgui/gradient-r")

-- eyx mouse handeler
if SERVER then
    util.AddNetworkString("eyx_recieve_mouse_leap_infection")
    util.AddNetworkString("eyx_retrieve_mouse_leap_infection")

    util.AddNetworkString("eyx_recieve_mouse_leap")
    util.AddNetworkString("eyx_retrieve_mouse_leap")

    util.AddNetworkString("eyx_retrieve_mouse_infection")
    util.AddNetworkString("eyx_recieve_mouse_infection")

    net.Receive("eyx_recieve_mouse_leap_infection", function()
        local ply = net.ReadEntity()
        local hitPos = net.ReadVector()

        local pillentity = ply.pk_pill_ent
        
        if IsValid(pillentity) then
            if pillentity.formTable.eyx_leap_infection then
                pillentity.formTable.eyx_leap_infection(ply, pillentity, hitPos)
            end
        end
    end)

    net.Receive("eyx_recieve_mouse_leap", function()
        local ply = net.ReadEntity()
        local hitPos = net.ReadVector()

        local pillentity = ply.pk_pill_ent
        
        if IsValid(pillentity) then
            if pillentity.formTable.eyx_leap then
                pillentity.formTable.eyx_leap(ply, pillentity, hitPos)
            end
        end
    end)

    net.Receive("eyx_recieve_mouse_infection", function()
        local ply = net.ReadEntity()
        local hitPos = net.ReadVector()

        local pillentity = ply.pk_pill_ent
        
        if IsValid(pillentity) then
            if pillentity.formTable.eyx_infection then
                pillentity.formTable.eyx_infection(ply, pillentity, hitPos)
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
    net.Receive("eyx_retrieve_mouse_leap_infection", function()
        local ply = LocalPlayer()

        net.Start("eyx_recieve_mouse_leap_infection")
            net.WriteEntity(ply)
            net.WriteVector(GetTrueMouseHitPos(ply))
        net.SendToServer()
    end)
    net.Receive("eyx_retrieve_mouse_leap", function()
        local ply = LocalPlayer()

        net.Start("eyx_recieve_mouse_leap")
            net.WriteEntity(ply)
            net.WriteVector(GetTrueMouseHitPos(ply))
        net.SendToServer()
    end)
    net.Receive("eyx_retrieve_mouse_infection", function()
        local ply = LocalPlayer()

        net.Start("eyx_recieve_mouse_infection")
            net.WriteEntity(ply)
            net.WriteVector(GetTrueMouseHitPos(ply))
        net.SendToServer()
    end)
    
    surface.CreateFont("EYX_LeapText", {
        font = "Tahoma",
        size = 34,
        weight = 2000,
        antialias = true,
        extended = true,
        shadow = true,
        outline = true,
    })
    
    surface.CreateFont("EYX_LeapTextdescription", {
        font = "Tahoma",
        size = 14,
        weight = 2000,
        antialias = true,
        extended = true,
        shadow = true,
        outline = true,
    })

end

pk_pills.register('pill_om_eyx', {

    printName='EYX',
    Outcomememories='eyx',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/eyx_body.mdl",

    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',


    OM_subtitles = {
        ["OM/eyx/EyxLaugh.wav"] = "EVIL LAUGHING",
    },

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            SlamDunkLand = "SlamDunkLand",
            screech="screech",
            Puke = "Puke",
            FeralBite = "FeralBite",
            kill="kill",
            SlamDunkMiss="SlamDunkMiss,"
        },
            
        ShouldMoveRotate={
            screech= function(ent)
                return 'shiftlock' 
            end,
            Puke= function(ent)
                return 'shiftlock' 
            end,
            idle= function(ent)
                if ent:GetNW2Bool("EYX_holdleap") then return "shiftlock" end
                return 'notanything' 
            end,
            run= function(ent) 
                if ent:GetNW2Bool("EYX_holdleap") then return "shiftlock" end
                return 'notshftlock' 
            end,
            walk= function(ent) 
                if ent:GetNW2Bool("EYX_holdleap") then return "shiftlock" end
                return 'notshftlock' 
            end,
            jump= function(ent)
                if ent:GetNW2Bool("EYX_holdleap") then return "shiftlock" end
                return 'notshftlock'
            end,
            fall= function(ent)
                if ent:GetNW2Bool("EYX_holdleap") then return "shiftlock" end
                return "notshftlock"
            end,
        },

        ShouldAlternate={
            fall= function(ent)
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stunned"
                end
                if ent:GetNW2Float("jump_animdur") > CurTime() then
                    return "Jump"
                end
                if ent:GetNW2Bool("eyx_slamduck_grab_crashing") then
                    if ply:GetVelocity().z > 0 then
                        return "SlamDunkJump"
                    else
                        return "SlamDunkFall"
                    end
                end
                if ent:GetNW2Bool("EYX_leaping") or ent:GetNW2Bool("EYX_leaping_infection") then return "LeapCharge" end
                if ent:GetNW2Bool("EYX_holdleap") then return "LeapChargeUp" end
                if ent:GetNW2Float("EYXLandAnim") > CurTime() then return "LeapEnd" end
            end,
            idle= function(ent)
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stunned"
                end
                if ent:GetNW2Bool("eyx_slamduck_grab_crashing") then return "SlamDunkJump" end
                if ent:GetNW2Bool("EYX_leaping") or ent:GetNW2Bool("EYX_leaping_infection") then return "LeapCharge" end
                if ent:GetNW2Bool("EYX_holdleap") then return "LeapChargeUp" end
                if ent:GetNW2Float("EYXLandAnim") > CurTime() then return "LeapEnd" end
            end,
            walk= function(ent)
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stunned"
                end
                if ent:GetNW2Bool("eyx_slamduck_grab_crashing") then return "SlamDunkJump" end
                if ent:GetNW2Float("eyx_slamduck_grab_grabduration") > CurTime() then return "SlamDunkRun" end
                if ent:GetNW2Bool("EYX_leaping") or ent:GetNW2Bool("EYX_leaping_infection") then return "LeapCharge" end
                if ent:GetNW2Bool("EYX_holdleap") then return "LeapChargeUp" end
                if ent:GetNW2Float("EYXLandAnim") > CurTime() then return "LeapEnd" end
                if ent:GetNW2Float("EYX_crazyrun") > CurTime() or ent:GetNW2Float("Frenzy_duration_eyx") > CurTime() then return "RunAllFours" end
            end,
            run= function(ent)
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stunned"
                end
                if ent:GetNW2Bool("eyx_slamduck_grab_crashing") then return "SlamDunkJump" end
                if ent:GetNW2Float("eyx_slamduck_grab_grabduration") > CurTime() then return "SlamDunkRun" end
                if ent:GetNW2Bool("EYX_leaping") or ent:GetNW2Bool("EYX_leaping_infection") then return "LeapCharge" end
                if ent:GetNW2Bool("EYX_holdleap") then return "LeapChargeUp" end
                if ent:GetNW2Float("EYXLandAnim") > CurTime() then return "LeapEnd" end

                if ent:GetNW2Float("eyx_slowdown_om") > CurTime() then
                    if ent:GetNW2Float("EYX_crazyrun") > CurTime() or ent:GetNW2Float("Frenzy_duration_eyx") > CurTime() then return "RunAllFours" end
                    return "walk"
                end

                if ent:GetNW2Float("EYX_crazyrun") > CurTime() or ent:GetNW2Float("Frenzy_duration_eyx") > CurTime() then return "RunFourTwice" end
            end,
        },
        
        animrates = {
            fall = function(ent)
                return 1
            end,
            idle= function(ent)
                return 1
            end,
            walk= function(ent)
                return 1
            end,
            run= function(ent)
                return 1
            end,
        }
    },

    OM_cameratable = function(ply,ent)

        local basetable =  {
            startoffset = Vector(15,0,15),  -- left-up, front-back, up-down
            dist=145,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 0,
            transition = 1,
            canscroll = true,
            bonecenter = "Head",
        }
        if ent:GetNW2Bool("EYX_holdleap") then 
            local starttime = ent:GetNW2Float("EYX_LeapChargeStartTime")
            local factorClamped = math.Clamp((CurTime()-starttime)/2, 0, 1)
            local lerpfactor = Lerp(factorClamped, 0, 1)
            basetable =  {
                startoffset = Vector(45,0,75),  -- left-up, front-back, up-down
                dist=70+ 30*lerpfactor,
                fov = ply:GetInfoNum("om_pills_default_fov", 80) + 30*lerpfactor,
                id = 1,
                transition = 1,
                canscroll = true,
            }
        end

        return basetable
    end,

    OM_UI_custom_start = function(ply, ent)
        if not ent.Leap_bar_lerp_eyx then
            ent.Leap_bar_lerp_eyx = 0
        end

        if ent:GetNW2Bool("EYX_holdleap") then
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

            local starttime = ent:GetNW2Float("EYX_LeapChargeStartTime")
            local factorClamped = math.Clamp((CurTime() - starttime) / 2, 0, 1)
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
                "Hold E : More leap power",
                "EYX_LeapText",
                middlex - iconsize * 0,
                y - iconsize*0.15,
                Color(255, 175, 175, 255*ent.Leap_bar_lerp_eyx),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_BOTTOM
            )

            draw.SimpleText(
                "Left Click : Cancel Leap",
                "EYX_LeapText",
                middlex + iconsize * 0,
                y - iconsize*0.35,
                Color(175, 175, 255, 255*ent.Leap_bar_lerp_eyx),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_BOTTOM
            )

            draw.SimpleText(
                "Aim and hit at a wall to have lower cooldown",
                "EYX_LeapTextdescription",
                middlex,
                y - iconsize*0.075,
                Color(255, 255, 255, 255*ent.Leap_bar_lerp_eyx),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_BOTTOM
            )
        end


        if not ent.Leap_barrage_eyx_lerp then
            ent.Leap_barrage_eyx_lerp = 0
        end
        if ent:GetNW2Bool("Frenzy_eyx_om") and not ent:GetNW2Bool("Frenzy_eyx_om_full") then
            ent.Leap_barrage_eyx_lerp = Lerp(FrameTime()*9, ent.Leap_barrage_eyx_lerp, 1)
        else
            ent.Leap_barrage_eyx_lerp = Lerp(FrameTime()*9, ent.Leap_barrage_eyx_lerp, 0)
        end

        if ent.Leap_barrage_eyx_lerp > 0.05 then
            local screenW, screenH = ScrW(), ScrH()
            local middlex, middley = screenW * 0.5, screenH * 0.5
            local iconsize = screenW / 13

            local barW = iconsize * 0.5
            local barH = iconsize * 4.5

            local clamp = math.Clamp((CurTime()-ent:GetNW2Float("Frenzy_starttime"))/ent:GetNW2Float("eyx_frenzy_maximum_duration"), 0, 1)

            local frac = Lerp(clamp, 0, 1)

            local x = Lerp(ent.Leap_barrage_eyx_lerp, iconsize * -0.6, iconsize * 0.2)
            local y = middley - barH * 0.5

            local shakeFrac = math.max(0, (frac - 0.5) / 0.5)

            local shakeAmount = shakeFrac ^ 3 * 8

            local t = CurTime() * (10 + shakeFrac * 50)

            x = x
                + math.sin(t * 1.5) * shakeAmount
                + math.cos(t * 1.5) * shakeAmount * 0.5

            y = y
                + math.cos(t * 1.5) * shakeAmount
                + math.sin(t * 1.5) * shakeAmount * 0.5

            draw.RoundedBox(12, x - 4, y - 4, barW + 8, barH + 8, Color(5, 5, 5, 240))

            draw.RoundedBox(10, x, y, barW, barH, Color(20, 5, 5, 220))

            local fillH = barH * frac

            draw.RoundedBox(
                8,
                x + 3,
                y + barH - fillH - 3,
                barW - 6,
                fillH,
                Color(80, 0, 0, 240)
            )

            for i = 0, 8 do
                local waveX = x + (barW / 8) * i

                local waveY =
                    y + barH - fillH +
                    math.sin(CurTime() * (6 + shakeFrac * 12) + i * 0.7) *
                    (6 + shakeFrac * 8)

                draw.RoundedBox(
                    8,
                    waveX - 12,
                    waveY - 6,
                    24,
                    12,
                    Color(120, 0, 0, 220)
                )
            end

            for i = 1, 10 do
                local seed = i * 1337

                local blobX =
                    x + 8 +
                    (math.sin(CurTime() * (1 + shakeFrac * 2) + seed) * 0.5 + 0.5) *
                    (barW - 24)

                local blobY =
                    y + barH - fillH +
                    ((math.cos(CurTime() * (0.7 + shakeFrac) + seed) * 0.5 + 0.5) *
                    math.max(fillH - 20, 0))

                draw.RoundedBox(
                    16,
                    blobX,
                    blobY,
                    16,
                    16,
                    Color(40, 0, 0, 100)
                )
            end

            surface.SetDrawColor(255, 255, 255, 10)
            surface.DrawRect(x + 6, y + 6, barW * 0.15, barH - 12)

            local frenzyText = "FRENZY"
            local letters = {}

            for i = 1, #frenzyText do
                letters[i] = frenzyText[i]
            end

            local textX = x + barW * 0.5
            local spacing = barH / (#letters + 1)

            local shakeFrac = math.Clamp((frac - 0.5) / 0.5, 0, 1)
            local textShake = (shakeFrac ^ 2)*0.5
            local time = CurTime()

            for i = 1, #letters do
                local char = letters[i]

                local baseY = y + spacing * i

                local n1 = math.sin(time * (2 + textShake * 6) + i * 10.3)
                local n2 = math.cos(time * (1.7 + textShake * 5) + i * 6.7)

                local offsetX = (n1 * 2 + n2 * 1.5) * (2 + textShake * 10)
                local offsetY = (n2 * 2 + n1 * 1.2) * (2 + textShake * 8)

                local rot =
                    math.sin(time * (3 + textShake * 10) + i * 2.2)
                    * (5 + textShake * 55)

                local alpha = 200 + textShake * 55

                cam.Start2D()

                    cam.PushModelMatrix(Matrix())

                    draw.SimpleTextOutlined(
                        char,
                        "DermaLarge",
                        textX + offsetX,
                        baseY + offsetY,
                        Color(255, 80, 80, alpha),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        Color(0, 0, 0, 200)
                    )

                    draw.SimpleText(
                        char,
                        "DermaLarge",
                        textX + offsetX + math.sin(rot) * 1.5,
                        baseY + offsetY + math.cos(rot) * 1.5,
                        Color(255, 255, 255, alpha),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER
                    )

                    cam.PopModelMatrix()

                cam.End2D()
            end
        end

        if not ent.Frenzy_eyx_om_full_lerp then
            ent.Frenzy_eyx_om_full_lerp = 0
        end

        if ent:GetNW2Bool("Frenzy_eyx_om_full") then
            ent.Frenzy_eyx_om_full_lerp = Lerp(FrameTime()*1, ent.Frenzy_eyx_om_full_lerp, 1)
        else
            ent.Frenzy_eyx_om_full_lerp = Lerp(FrameTime()*2, ent.Frenzy_eyx_om_full_lerp, 0)
        end

        if ent.Frenzy_eyx_om_full_lerp > 0.05 then

            local screenW, screenH = ScrW(), ScrH()

            local bloodAlpha = Lerp(ent.Frenzy_eyx_om_full_lerp, 0, 180)

            surface.SetMaterial(grad)
            surface.SetDrawColor(80, 0, 0, bloodAlpha)

            surface.DrawTexturedRectRotated(
                screenW * 0.125,
                screenH * 0.5,
                screenW * 0.25,
                screenH,
                180
            )

            surface.DrawTexturedRectRotated(
                screenW * 0.875,
                screenH * 0.5,
                screenW * 0.25,
                screenH,
                0
            )

            surface.DrawTexturedRectRotated(
                screenW * 0.5,
                screenH * 0.125,
                screenH * 0.25,
                screenW,
                90
            )

            surface.DrawTexturedRectRotated(
                screenW * 0.5,
                screenH * 0.875,
                screenH * 0.25,
                screenW,
                -90
            )
        end
    end,

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["eyxleap"]
            end,
            name = function(uselessvar,ply,ent)
                return "Leap"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_E
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("eyx_leap_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 13
            end,
            survivor = false,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["eyxslam"]
            end,
            name = function(uselessvar,ply,ent)
                return "Slam Dunk"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_R
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("eyx_slamduck_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 27
            end,
            survivor = false,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Bool("ShouldntShowAbility3_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["eyxscreech"]
            end,
            name = function(uselessvar,ply,ent)
                return "Screech"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_T
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("eyx_screech_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            survivor = false,
            font = "CreditsText",
        },
        [4] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Bool("ShouldntShowAbility4_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["infectioneyx"]
            end,
            name = function(uselessvar,ply,ent)
                return "Infection"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_I
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("eyx_infection_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 10
            end,
            survivor = false,
            font = "CreditsText",
        },
    },
    

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_eyx_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_eyx_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_eyx_walk"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_eyx_jumppower"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_eyx_jumpcd"):GetFloat()
                end
            end,
            slamdunkgrab = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_eyx_slamdunkgrab"):GetFloat()
                end
            end,
            chargerun = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_eyx_chargerun_new"):GetFloat()
                end
            end,
            chargewalk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_eyx_chargewalk"):GetFloat()
                end
            end,
        },
    },
    --ent.formTable.Outcomememories_stats.abilities.Attack.Damage
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },
    --canAim=function(ply,ent) return ent.active end,     

    speedhandeler_om = {
        modifiers = {
            ['Function1'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("eyx_slamduck_grab_grabduration") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.slamdunkgrab() - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.slamdunkgrab() - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.slamdunkgrab() - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
            ['slowdown'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("eyx_slowdown_om") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*0.6 - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run()*0.6 - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.ducked()*0.6 - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
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

                if ent:GetNW2Float("EYX_crazyrun") > CurTime() or ent:GetNW2Float("Frenzy_duration_eyx") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.chargewalk() - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.chargerun() - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    --sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.chargerun() - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
        },
    },

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if SERVER then
            if event == "Step" then
                AdvancedPillSound(
                    {
                        stringe = {
                            "npc/fast_zombie/foot1.wav",
                            "npc/fast_zombie/foot2.wav",
                            "npc/fast_zombie/foot3.wav",
                        },
                        pitchPercent = 95,
                        volume = 0.5,
                        soundLevel = 90
                    },
                    ent
                )

                AdvancedPillSound(
                    {
                        stringe = {
                            "npc/zombie/foot1.wav",
                            "npc/zombie/foot2.wav",
                            "npc/zombie/foot3.wav",
                        },
                        pitchPercent = 90,
                        volume = 0.4,
                        soundLevel = 90
                    },
                    ent
                )

                AdvancedPillSound(
                    {
                        stringe = {
                            "npc/zombie/foot_slide1.wav",
                            "npc/zombie/foot_slide2.wav",
                        },
                        pitchPercent = 80,
                        volume = 0.35,
                        soundLevel = 80
                    },
                    ent
                )

                AdvancedPillSound(
                    {
                        stringe = {
                            "physics/flesh/flesh_squishy_impact_hard1.wav",
                            "physics/flesh/flesh_squishy_impact_hard2.wav",
                            "physics/flesh/flesh_squishy_impact_hard3.wav",
                            "physics/flesh/flesh_squishy_impact_hard4.wav",
                        },
                        pitchPercent = 70,
                        volume = 0.25,
                        soundLevel = 80
                    },
                    ent
                )

                AdvancedPillSound(
                    {
                        stringe = {
                            "physics/body/body_medium_break2.wav",
                            "physics/body/body_medium_break3.wav",
                        },
                        pitchPercent = 60,
                        volume = 0.2,
                        soundLevel = 80
                    },
                    ent
                )

                AdvancedPillSound(
                    {
                        stringe = {
                            "physics/body/body_medium_impact_soft1.wav",
                            "physics/body/body_medium_impact_soft2.wav",
                            "physics/body/body_medium_impact_soft3.wav",
                        },
                        pitchPercent = 65,
                        volume = 0.2,
                        soundLevel = 80
                    },
                    ent
                )

                AdvancedPillSound(
                    {
                        stringe = {
                            "physics/concrete/concrete_break2.wav",
                            "physics/concrete/concrete_break3.wav",
                        },
                        pitchPercent = 55,
                        volume = 0.15,
                        soundLevel = 70
                    },
                    ent
                )
            end
            if event == "Attack" then
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end

                if SERVER then
                    local nearest
                    local nearestDist = math.huge

                    local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                    for _, ent2 in pairs(ents.FindInSphere(attackPos, 165)) do
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

                    if IsValid(nearest) then
                        local typeofdamage = GetConVar("OUTCOMEMEMORIES_N_eyx_Damage"):GetFloat()
                        if ent:GetNW2Float("Frenzy_duration_eyx") > CurTime() then
                            typeofdamage = GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_frenzy"):GetFloat()
                        end
                        
                        KillerdamagestunDynamic({
                            ply = ply,
                            target = nearest,
                            DamageNumb = typeofdamage,
                            damagetype = DMG_CLUB,
                            CustomDamageSound = nil,
                            damagesound = true,
                            ShouldBlood = true,
                            flingremoveal = true,
                            ShouldBloodEffect = true
                        })
                        hitent = nearest
                    end
                end
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_killer_om(initializetable2["entity"])


        initializetable2["player"].ColorRGB_B_1_OM = Color(0,0,215, 255)
        if SERVER then

            local health = GetConVar("OUTCOMEMEMORIES_N_eyx_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            if GetConVar("OUTCOMEMEMORIES_N_eyx_HasHealth"):GetBool() then
                initializetable2["player"]:GodDisable()
            end
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)

            initializetable2["entity"]:SetNW2Float('OM_friction', 1)

            initializetable2["player"]:SetNW2String("TerrorRadius_om","")
            initializetable2["player"]:SetNW2String("chasemusic_life1_om","OM/music/EYXFirstLifeMusic.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life2_om","OM/music/EYXlastlife.wav")


            initializetable2["player"].CustomFunctionForDowning_OM = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if IsValid(initializetable2["entity"]) then
                    timer.Simple(0.15,function()
                        if !IsValid(initializetable2["entity"]) then return end

                        AdvancedPillSound(
                            {
                                stringe = "OM/eyx/EyxLaugh.wav",
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
                        if ent:GetNW2Float("OM_executionanim") > CurTime() then return end

                        AdvancedPillSound(
                            {
                                stringe = "OM/eyx/eyxkill.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )

                        ent:PillAnim("kill")
                        local anim = ent:GetPuppet():LookupSequence("Kill")
                        local dur = ent:GetPuppet():SequenceDuration(anim)
                        ent:SetNW2Float("OM_executionanim", CurTime()+dur)

                        ent:SetNW2Float("DisablePlayerMovement_OM_stun_iframe1", CurTime()+dur)
                        
                        entityfall:SetNW2Float("OM_NoDamagePrevention", CurTime()+dur)
                        dmg:SetDamage(0)

                        ent:SetNW2Float("Rushout_steveoutcome_block", 0)
                        ent:SetNWBool("JumpscareAnim_om_boolean2", true)

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

                        timer.Simple(1.65,function()
                            if !IsValid(initializetable2["entity"]) then return end
                            if !IsValid(entityfall) then return end
                            ent:SetNW2Float("Dead_OM", CurTime()+0.1)
                            entityfall:SetNW2Float("OM_NoDamagePrevention", 0)

                            entityfall:SetNW2Float("OM_Damage_ReductionRemoveal", CurTime()+0.1)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_GENERIC, true, false, false, true)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_CRUSH, true, false, false, true)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_BULLET, true, false, false, true)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_SLASH, true, false, false, true)
                            ent:SetNWBool("JumpscareAnim_om_boolean2", false)

                            timer.Simple(1, function()
                                if !IsValid(initializetable2["entity"]) then return end
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/eyx/EyxLaugh.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    initializetable2["entity"]
                                )
                            end)
                        end)

                        ent:SetNWBool("JumpscareAnim_om_boolean2", true)
                        local throw = false
                        local enemyragdoll = CreateRagdolLCharacter_OM({
                            target = entityfall,
                            host = ent,

                            shouldremove = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return true end
                                if not IsValid(entityfall) then return true end
                                if not IsValid(ent) then return true end
                                if ent:GetNW2Float("OM_executionanim") < CurTime() then
                                    return true
                                else
                                    entityfall:SetNW2Float("ragdolltype_grab", CurTime()+0.1)
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

                                local bone = puppet:LookupBone("LeftHand")
                                if not bone then return end

                                local pos, ang = puppet:GetBonePosition(bone)
                                if not pos then return end
                                --JumpscareAnim_om_boolean2JumpscareAnim_om_boolean2
                                if not ent:GetNWBool("JumpscareAnim_om_boolean2") then
                                    if not throw then
                                        throw = true
                                        headPhys:ApplyForceCenter(puppet:GetRight()*1750)
                                    end
                                    return true end
                                headPhys:SetPos(pos)
                                headPhys:SetAngles(ang)
                                headPhys:SetVelocityInstantaneous(vector_origin)
                                headPhys:Wake()
                            end

                        })

                    end
                end
            end


            initializetable2["player"].OM_StunFunction = function()
                local ent = initializetable2["entity"]
                local ply = initializetable2["player"]
                if !IsValid(ent) then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end

                ent:SetNW2Bool("EYX_holdleap", false)
                ent.EYX_holdleap = false

                ent:SetNW2Float("eyx_puke_duration", 0)
            end


        end
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetGravity(1)
        end
        initializetable2["entity"]:StopSound("OM/eyx/Leapcharge.wav")

    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_eyx_Resistance"):GetFloat()/100)

            if GetConVar("OUTCOMEMEMORIES_N_eyx_CanLeap"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
            end
            if GetConVar("OUTCOMEMEMORIES_N_eyx_CanSlamDunk"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
            end
            if GetConVar("OUTCOMEMEMORIES_N_eyx_CanScreech"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility3_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility3_OM", false)
            end
            if GetConVar("OUTCOMEMEMORIES_N_eyx_CanInfection"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility4_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility4_OM", false)
            end

            OM_PILL_speedThink(ply, ent)
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") > CurTime() or ent:GetNW2Float("OM_executionanim") > CurTime() then
                ply:SetNW2Float("OM_Damage_Reduction",0)
            else
                ply:SetNW2Float("OM_Damage_Reduction",1)
            end
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



            if ply:GetNW2Bool("OM_character_monster") then
                local targetVolume = 0
                local nearestDist = math.huge
                local currentenemy = nil
                local TriggerDist, ChaseDist, StopDist, FadeSpeed = 2000, 1500, 2500, 1.5

                for _, ent in ipairs(ents.GetAll()) do
                    if IsValid(ent:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent == ply then continue end

                    if !ent:GetNW2Bool("OM_character_monster") and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and ent:Health() > 0.1 then
                        local dist = ply:GetPos():DistToSqr(ent:GetPos())

                        if dist < nearestDist then
                            nearestDist = dist
                            currentenemy = ent
                        end
                    end
                end

                if IsValid(currentenemy) then
                    local dist = math.sqrt(nearestDist)

                    local tr = util.TraceLine({
                        start = ply:EyePos(),
                        endpos = currentenemy:WorldSpaceCenter(),
                        mask = MASK_SOLID,
                        filter = function(ent)
                            if ent == ply or ent == currentenemy then return false end
                            if ent:IsPlayer() then return false end
                            if ent:IsNPC() then return false end
                            if ent:IsNextBot() then return false end
                        end
                    })

                    if dist <= ChaseDist then
                        targetVolume = 1
                    else
                        targetVolume = 0
                    end
                end

                if targetVolume == 1  and GetConVar("OUTCOMEMEMORIES_N_eyx_HasFrenzy"):GetBool()then
                    if not ent.Frenzy_eyx_om then
                        ent.Frenzy_eyx_om = true
                        ent:SetNW2Float("Frenzy_starttime",CurTime())
                        ent:SetNW2Float("eyx_frenzy_maximum_duration", GetConVar("OUTCOMEMEMORIES_N_eyx_FrenzyBuildUpDuration"):GetFloat())

                        ent:SetNW2Bool("Frenzy_eyx_om", true)
                    end


                    if CurTime()-ent:GetNW2Float("Frenzy_starttime") > ent:GetNW2Float("eyx_frenzy_maximum_duration") then
                        ent:SetNW2Float("Frenzy_duration_eyx", CurTime()+1)
                        ent:GetPuppet():SetNW2Float("Model_Frenzy_duration_eyx", CurTime()+1)
                        ent:SetNW2Bool("Frenzy_eyx_om_full", true)
                    end
                else
                    if ent.Frenzy_eyx_om then
                        ent:SetNW2Bool("Frenzy_eyx_om", false)
                        ent.Frenzy_eyx_om = false
                        ent:SetNW2Bool("Frenzy_eyx_om_full", false)
                    end
                end
            end

            local nearest
            local nearestDist = math.huge

            local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

            for _, ent2 in pairs(ents.FindInSphere(attackPos, 2300)) do
                if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                    if ent2 == ply then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end

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

            if not nearest then
                ent:SetNW2Float("EYX_crazyrun", CurTime() + 0.5)
            else
            end

            if ent:GetNW2Float("eyx_screech_duration_inflict") > CurTime() then
                local candamage = false
                if not ent.eyx_screech_duration_inflict_bool then 
                    ent.eyx_screech_duration_inflict_bool = true
                    candamage = true
                end

                if not ent.eyx_screech_duration_inflict_effect_cd then
                    ent.eyx_screech_duration_inflict_effect_cd = 0
                end


                if ent.eyx_screech_duration_inflict_effect_cd < CurTime() then
                    ent.eyx_screech_duration_inflict_effect_cd = CurTime() +0.05
                    local puppet = ent:GetPuppet()

                    if IsValid(puppet) then
                        local bone = puppet:LookupBone("Head")

                        if bone then
                            local pos, ang = puppet:GetBonePosition(bone)

                            local ed = EffectData()
                            ed:SetOrigin(pos + ang:Up()*15+ ang:Right()*-5)
                            ed:SetNormal(ang:Up())

                            ed:SetScale(175)
                            ed:SetMagnitude(100)

                            util.Effect("eyx_screamwaves", ed)
                        end
                    end
                end

                local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                for _, ent2 in pairs(ents.FindInSphere(attackPos, 2500)) do
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end

                        if not GetConVar("PVPStun_OM_exe"):GetBool() then
                            if ent2:GetNW2Bool("OM_character_monster") then continue end
                        end
                        ent2:SetNW2Float("screechstatus_eyx", CurTime() + 5)
                        if ent:GetNW2Float("Frenzy_duration_eyx") > CurTime() and candamage then

                            local typeofdamage = GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_screech"):GetFloat()
                            
                            KillerdamagestunDynamic({
                                ply = ply,
                                target = ent2,
                                DamageNumb = typeofdamage,
                                damagetype = DMG_BLAST,
                                CustomDamageSound = nil,
                                damagesound = false,
                                ShouldBlood = false,
                                flingremoveal = true,
                                ShouldBloodEffect = true
                            })
                        end

                    end
                end
            else
                if ent.eyx_screech_duration_inflict_bool then 
                    ent.eyx_screech_duration_inflict_bool = false
                end
            end

            if ent:GetNW2Float("eyx_screech_duration") > CurTime() then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
            end


            if ent:GetNW2Float("eyx_goingup_force") > CurTime() then
                if ply:IsOnGround() then
                    local puppet = ent:GetPuppet()
                    local velocity = puppet:GetForward()*250*2 + puppet:GetUp()*450*2
                    if ply:IsPlayer() then
                        ply:SetLocalVelocity(velocity)
                    else
                        ply:SetVelocity(velocity)
                    end
                    ply:SetPos(ply:GetPos()+Vector(0,0,40))
                end
            else
                if ent:GetNW2Bool("eyx_slamduck_grab_crashing") and ply:IsOnGround() then
                    if not ent.eyx_slamduck_grab_crashing_bool then
                        ent.eyx_slamduck_grab_crashing_bool = true
                    else

                        ply:SetGravity(1)
                        ent.eyx_slamduck_grab_crashing_bool = false
                        ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                        ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)

                        ent:SetNW2Float("eyx_slamduck_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_cd"):GetFloat())
                        ent:SetNW2Float("AttackCooldown_OM", CurTime() + 2)
                        ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+2.2)
                        ent:SetNW2Bool("eyx_slamduck_grab_crashing", false)
                        ent:SetNW2Float("eyx_slamduck_grab_crashing_duration", 0)
                        ent.eyx_slamduck_grab_crashing_duration = false
                        ent:PillAnim("SlamDunkLand")

                        local velocity = Vector(0,0,0)
                        ply:SetVelocity(velocity)
                        ply:SetLocalVelocity(velocity)

                        local hullSize = Vector(16, 16, 34)
                        local startPos = ply:GetPos() + Vector(0,0,10)
                        local endPos = startPos + Vector(0,0,-40)
                        local tr = util.TraceHull({
                            start = startPos,
                            endpos = endPos,
                            filter = ply,
                            mask = MASK_SOLID,
                            mins = -hullSize * 0.5,
                            maxs = hullSize * 0.5
                        })

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

                        ent:SetNW2Float("AttackCooldown_OM", CurTime() + 2.35)

                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 1)
                    end
                end
            end

            if ent:GetNW2Float("eyx_slamduck_grab_grabduration") > CurTime() then
                if not ent.eyx_slamduck_grab_grabbool then
                    ent.eyx_slamduck_grab_grabbool = true
                end
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)

                local nearest
                local nearestDist = math.huge

                local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                for _, ent2 in pairs(ents.FindInSphere(attackPos, 120)) do
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end

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

                if IsValid(nearest) then

                    AdvancedPillSound(
                        {
                            stringe = "OM/eyx/eyx_grab.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )


                    ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                    ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)
                    ent.eyx_slamduck_grab_grabbool = false
                    ent:SetNW2Float("eyx_slamduck_grab_grabduration", 0)
                    ent:SetNW2Float("eyx_slamduck_grab_crashing_duration", CurTime()+0.6)
                    ent:SetNW2Bool("eyx_slamduck_grab_crashing", true)

                    if ply:IsOnGround() then
                        ply:SetPos(ply:GetPos()+Vector(0,0,40))
                    end
                    local puppet = ent:GetPuppet()
                    local velocity = puppet:GetForward()*250*2 + puppet:GetUp()*450*2

                    if ply:IsPlayer() then
                        ply:SetLocalVelocity(velocity)
                    else
                        ply:SetVelocity(velocity)
                    end
                    if ply:IsOnGround() then
                        ply:SetPos(ply:GetPos()+Vector(0,0,40))
                    end

                    ent:SetNW2Float('eyx_goingup_force',CurTime()+0.25)


                    AdvancedPillSound(
                        {
                            stringe = "OM/eyx/eyx_grab.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    nearest:SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                    nearest:SetNW2Float('sonic_glow_duration',CurTime()+0.25)

                    local last = CurTime() + 3
                    local hasbeenhitground = false

                    local enemyragdoll = CreateRagdolLCharacter_OM({
                        target = nearest,
                        host = ent,

                        shouldremove = function(createfakeragdoll)
                            if not IsValid(createfakeragdoll) then return true end
                            if not IsValid(nearest) then return true end
                            if not IsValid(ent) then return true end

                            if last > CurTime() then
                                return false
                            end

                            return true
                        end,

                        shoulddocustomfunction = function(createfakeragdoll)
                            if not IsValid(createfakeragdoll) then return end
                            if not IsValid(ent) then return end

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

                            if not ent:GetNW2Bool("eyx_slamduck_grab_crashing") then 
                                if not hasbeenhitground then
                                    hasbeenhitground = true
                                    
                                    KillerdamagestunDynamic({
                                        ply = ply,
                                        target = nearest,
                                        DamageNumb = GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_slamdunk"):GetFloat(),
                                        damagetype = DMG_PLASMA,
                                        CustomDamageSound = nil,
                                        damagesound = true,
                                        ShouldBlood = true,
                                        flingremoveal = true,
                                        ShouldBloodEffect = true
                                    })

                                    nearest:SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                                    nearest:SetNW2Float('sonic_glow_duration',CurTime()+0.25)

                                    local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                                    for _, ent2 in pairs(ents.FindInSphere(attackPos, 180)) do
                                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                                            if ent2 == ply then continue end
                                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                            if ent2 == nearest then continue end
                                            if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end

                                            if not GetConVar("PVPStun_OM_exe"):GetBool() then
                                                if ent2:GetNW2Bool("OM_character_monster") then continue end
                                            end

                                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                                            if not Mutal_OMCanDamage(ply, ent, ent2) then continue end

                                            local dist = attackPos:DistToSqr(ent2:GetPos())
                                            KillerdamagestunDynamic({
                                                ply = ply,
                                                target = ent2,
                                                DamageNumb = GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_slamdunk_area"):GetFloat(),
                                                damagetype = DMG_PLASMA,
                                                CustomDamageSound = nil,
                                                damagesound = true,
                                                ShouldBlood = true,
                                                flingremoveal = true,
                                                ShouldBloodEffect = true
                                            })
                                        end
                                    end

                                end
                                return
                            end

                            last = CurTime() + 1.5

                            local leftHandBone = puppet:LookupBone("LeftHand")
                            local rightHandBone = puppet:LookupBone("RightHand")

                            local leftPos = leftHandBone and select(1, puppet:GetBonePosition(leftHandBone))
                            local rightPos = rightHandBone and select(1, puppet:GetBonePosition(rightHandBone))

                            leftPos = leftPos or puppet:GetPos()
                            rightPos = rightPos or puppet:GetPos()

                            local medianPos = (leftPos + rightPos) * 0.5
                            medianPos = medianPos + Vector(0, 0, 10)

                            local headBone = puppet:LookupBone("Head")

                            local headPos
                            if headBone then
                                headPos = select(1, puppet:GetBonePosition(headBone))
                            end

                            headPos = headPos or (puppet:GetPos() + Vector(0, 0, 60))

                            local ang = (headPos - medianPos):Angle()

                            headPhys:SetPos(medianPos)
                            headPhys:SetAngles(ang)
                            headPhys:SetVelocityInstantaneous(vector_origin)
                            headPhys:Wake()

                            nearest:SetNW2Float("ragdolltype_grab", CurTime() + 0.1)
                            
                            ent:SetNW2Float("eyx_slowdown_om", CurTime()+ 4)
                        end
                    })
                end
            else
                if ent.eyx_slamduck_grab_grabbool then
                    ent:SetNW2Float("eyx_slowdown_om", CurTime()+ 3)
                    ent:SetNW2Float("eyx_slamduck_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_hit_cd"):GetFloat())
                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1.35)
                    ent.eyx_slamduck_grab_grabbool = false
                end
            end

            if ent:GetNW2Float("eyx_slamduck_grab_crashing_duration") > CurTime() then
                if not ent.eyx_slamduck_grab_crashing_duration then
                    ent.eyx_slamduck_grab_crashing_duration = true
                    ply:SetGravity(0.65)
                    ent:SetNW2Float("jump_animdur", CurTime()+0.2)
                end
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
            else

                if ent:GetNW2Bool("eyx_slamduck_grab_crashing") and ply:IsOnGround() then
                else
                    if ent.eyx_slamduck_grab_crashing_duration then
                        ent.eyx_slamduck_grab_crashing_duration = false
                        local puppet = ent:GetPuppet()
                        local velocity = puppet:GetForward()*250 + puppet:GetUp()*-800
                        --ply:SetVelocity(velocity)
                        --ply:SetLocalVelocity(velocity)
                        ply:SetGravity(4)
                    end
                end
            end

            if ply:IsOnGround() and ent:GetNW2Bool("EYX_RetryLeap") then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                ent:SetNW2Bool("EYX_RetryLeap", false)
            end

            if ent:GetNW2Bool("EYX_leaping_infection") then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime() + 0.2)

                local nearest
                local nearestDist = math.huge

                local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                for _, ent2 in pairs(ents.FindInSphere(attackPos, 70)) do
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end

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

                if IsValid(nearest) then
                    ent:SetNW2Bool("EYX_leaping_infection", false)

                    ply:SetVelocity(Vector(0,0,0))
                    ply:SetLocalVelocity(Vector(0,0,0))
                    ent:SetNW2Float("eyx_infection_cd", CurTime() + GetConVar("OUTCOMEMEMORIES_N_eyx_Infection_cd"):GetFloat() )

                    local seq = ent:GetPuppet():LookupSequence("FeralBite")
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                    ent:SetNW2Float("eyx_FeralBite_duration", CurTime() + ent:GetPuppet():SequenceDuration(seq))

                    ent:PillAnim("FeralBite")

                    local last = CurTime() + 3.25
                    local hasbeenhitground = false

                    timer.Simple(0.8,function()
                        if !IsValid(ent) then return end
                        if !IsValid(nearest) then return end
                        KillerdamagestunDynamic({
                            ply = ply,
                            target = nearest,
                            DamageNumb = GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_infection_leap"):GetFloat(),
                            damagetype = DMG_CRUSH,
                            CustomDamageSound = nil,
                            damagesound = true,
                            ShouldBlood = true,
                            flingremoveal = true,
                            ShouldBloodEffect = true
                        })
                    end)
                    timer.Simple(1.8,function()
                        hasbeenhitground = true
                    end)

                                    

                    local thrown = false

                    local enemyragdoll = CreateRagdolLCharacter_OM({
                        target = nearest,
                        host = ent,

                        shouldremove = function(createfakeragdoll)
                            if not IsValid(createfakeragdoll) then return true end
                            if not IsValid(nearest) then return true end
                            if not IsValid(ent) then return true end

                            if last > CurTime() then
                                return false
                            end

                            return true
                        end,

                        shoulddocustomfunction = function(createfakeragdoll)
                            if not IsValid(createfakeragdoll) then return end
                            if not IsValid(ent) then return end

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
                            if hasbeenhitground then
                                if not thrown then
                                    thrown = true
                                    local dir = (nearest:GetPos() - ply:GetPos()+ Vector(0,0,60)):GetNormalized()


                                    for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                        local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                        if IsValid(phys) then
                                            phys:Wake()
                                            phys:SetVelocityInstantaneous(dir*600)
                                        end
                                    end
                                end
                                return end

                            local leftHandBone = puppet:LookupBone("LeftHand")
                            local rightHandBone = puppet:LookupBone("RightHand")

                            local leftPos = leftHandBone and select(1, puppet:GetBonePosition(leftHandBone))
                            local rightPos = rightHandBone and select(1, puppet:GetBonePosition(rightHandBone))

                            leftPos = leftPos or puppet:GetPos()
                            rightPos = rightPos or puppet:GetPos()

                            local medianPos = (leftPos + rightPos) * 0.5
                            medianPos = medianPos + Vector(0, 0, 10)

                            local headBone = puppet:LookupBone("Head")

                            local headPos
                            if headBone then
                                headPos = select(1, puppet:GetBonePosition(headBone))
                            end

                            headPos = headPos or (puppet:GetPos() + Vector(0, 0, 60))

                            local ang = (headPos - medianPos):Angle()

                            headPhys:SetPos(medianPos)
                            headPhys:SetAngles(ang)
                            headPhys:SetVelocityInstantaneous(vector_origin)
                            headPhys:Wake()

                            nearest:SetNW2Float("ragdolltype_grab", CurTime() + 0.1)
                        
                        end
                    })

                end

                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.2)
                if not ent.EYX_leaping_infection_bool then
                    ent.EYX_leaping_infection_bool = true
                end
            else
                if ent.EYX_leaping_infection_bool then
                    ent.EYX_leaping_infection_bool = false
                end
            end

            if ent:GetNW2Float("eyx_FeralBite_duration") > CurTime() then
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.2)
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
            end

            if ent:GetNW2Bool("EYX_leaping_infection") and ply:IsOnGround() then
                ent:SetNW2Bool("EYX_leaping_infection", false)

                ply:SetVelocity(Vector(0,0,0))
                ply:SetLocalVelocity(Vector(0,0,0))
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.2)
                ent:SetNW2Float("EYXLandAnim", CurTime() + 2)
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                ent:SetNW2Float("eyx_infection_cd", CurTime() + 15)
            end

            if ent:GetNW2Float("EYXLandAnim") > CurTime() then
                if not ent.EYXLandAnim_bool then
                    ent.EYXLandAnim_bool = true
                end
            else
                if ent.EYXLandAnim_bool then
                    ent.EYXLandAnim_bool = false
                    AdvancedPillSound(
                        {
                            stringe = "OM/eyx/eyxleaprelease.wav",
                            pitchPercent = 100,
                            volume = 0.7,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            end

            if ply:IsOnGround() and ent:GetNW2Bool("EYX_leaping") then
                if not ent.CheckRoutine_eyxleaping then
                    ent.CheckRoutine_eyxleaping = true
                else
                    ent.CheckRoutine_eyxleaping = false
                    ply:SetVelocity(Vector(0,0,0))
                    ply:SetLocalVelocity(Vector(0,0,0))
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.2)
                    ent:SetNW2Float("EYXLandAnim", CurTime() + 1.25)
                    ent:SetNW2Bool("EYX_leaping", false)
                    ent:SetNW2Float("eyx_leap_cd", CurTime()+ GetConVar("OUTCOMEMEMORIES_N_eyx_Leap_cd"):GetFloat() )



                    local hullSize = Vector(16, 16, 34)
                    local startPos = ply:GetPos() + Vector(0,0,10) + ent:GetPuppet():GetForward()*0
                    local endPos = startPos + Vector(0,0,-40)
                    local tr = util.TraceHull({
                        start = startPos,
                        endpos = endPos,
                        filter = ply,
                        mask = MASK_SOLID,
                        mins = -hullSize * 0.5,
                        maxs = hullSize * 0.5
                    })

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
                end
            end

            if ent:GetNW2Bool("EYX_holdleap") then
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.2)
                if not ent.EYX_holdleap then
                    ent.EYX_holdleap = true
                    ent:SetNW2Float("EYX_LeapChargeStartTime", CurTime())


                    AdvancedPillSound(
                        {
                            stringe = "OM/eyx/Leapcharge.wav",
                            pitchPercent = 100,
                            volume = 0.7,
                            soundLevel = 87
                        },
                        ent
                    )

                end
            else
                if ent.EYX_holdleap then
                    ent:StopSound("OM/eyx/Leapcharge.wav")
                    ent.EYX_holdleap = false

                    AdvancedPillSound(
                        {
                            stringe = "OM/eyx/leapsound.wav",
                            pitchPercent = 100,
                            volume = 0.7,
                            soundLevel = 87
                        },
                        ent
                    )

                    if ply:IsPlayer() then
                        net.Start("eyx_retrieve_mouse_leap")
                        net.Send(ply)
                    else


                        local starttime = ent:GetNW2Float("EYX_LeapChargeStartTime")
                        local factorClamped = math.Clamp((CurTime()-starttime)/2, 0, 1)
                        local lerpfactor = Lerp(factorClamped, 0.5, 1)
                        local power = 900 * lerpfactor


                        local startPos = ply:GetPos()

                        local dir = ply:GetAimVector()
                        local velocity = dir * power *2

                        velocity.z = velocity.z * 0.9
                        velocity.x = velocity.x * 1.15
                        velocity.y = velocity.y * 1.15

                        if velocity.z < 120 then
                            velocity.z = 120
                        end

                        ply:SetPos(ply:GetPos()+Vector(0,0,40))
                        ply:SetVelocity(velocity)
                        ply:SetLocalVelocity(velocity)


                        ent:SetNW2Bool("EYX_leaping", true)

                    end
                end
            end
            
            if ent:GetNW2Bool("EYX_leaping") then

                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime() + 0.2)

                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.2)

                local hullSize = Vector(16, 16, 34)
                local startPos = ply:GetPos() + Vector(0,0,30)
                local endPos = startPos + ent:GetPuppet():GetForward() * 45
                local tr = util.TraceHull({
                    start = startPos,
                    endpos = endPos,
                    mask = MASK_SOLID,
                    mins = -hullSize * 0.5,
                    maxs = hullSize * 0.5,
                    filter = function(ent)
                        if ent == ply then return false end

                        if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
                            return false
                        end

                        return true
                    end
                })

                local function latching()
                    local normal = tr.HitNormal
                    if math.abs(normal.z) < 0.5 then
                        ent:SetNW2Float("eyx_leap_cd", CurTime()+ GetConVar("OUTCOMEMEMORIES_N_eyx_Leap_wall_cd"):GetFloat() )
                        ent:SetNW2Bool("EYX_leaping", false)
                        ent:SetNW2Bool("EYX_RetryLeap", true)
                        ent:SetNW2Float("ram_charge_duration",0)

                        local vel = ply:GetVelocity()

                        if ply:IsPlayer() then
                            ply:SetLocalVelocity(Vector(0, 0, vel.z))
                        else
                            ply:SetVelocity(Vector(0,0, vel.z))
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
            

            if ent:GetNW2Float("EYXLandAnim") > CurTime() then
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.1)
            end
                
            if ent:GetNW2Float("eyx_puke_duration") > CurTime() then
                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 0.35)
            end

            if ent:GetNW2Float("eyx_screech_duration", 0 ) > CurTime() or ent:GetNW2Float("eyx_FeralBite_duration") > CurTime() then
                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1.85)
            end
        else

            local hookName = "PostDrawTranslucentRenderables"
            local name = "eyx_ui_OM_noodles"..ent:EntIndex()

            local hooks = hook.GetTable()

            if hooks[hookName] and hooks[hookName][name] then
            else

                hook.Add(hookName, name, function()

                    if !IsValid(ent) then hook.Remove(hookName, name) return end

                    local v = ent:GetPuppet()

                    local expire = v:GetNW2Float("Model_Frenzy_duration_eyx")

                    v.Model_Frenzy_duration_eyx = v.Model_Frenzy_duration_eyx or 0

                    if CurTime() <= expire then
                        v.Model_Frenzy_duration_eyx = math.min(
                            Lerp(FrameTime() * 1, v.Model_Frenzy_duration_eyx, 1),
                            1
                        )
                    else
                        v.Model_Frenzy_duration_eyx = math.max(
                            Lerp(FrameTime() * 1, v.Model_Frenzy_duration_eyx, 0),
                            0
                        )
                    end

                    local alpha = v.Model_Frenzy_duration_eyx

                    if alpha > 0.01 then
                        local rag = v:GetNWEntity("OM_ragdollentity")

                        if IsValid(rag) then
                            v = rag
                        end

                        if v.pk_pill_ent then
                            if v.pk_pill_ent.GetPuppet then
                                v = v.pk_pill_ent:GetPuppet()
                            else
                                v = v.pk_pill_ent
                            end
                        end

                        render.SetBlend(1)
                        v:DrawModel()

                        render.SetBlend(alpha)

                        v:SetSubMaterial(6, "models/noodles/OM/eyx/redglow")
                        v:SetSubMaterial(7, "models/noodles/OM/eyx/SeperateEyeMat_glow")

                        v:DrawModel()

                        v:SetSubMaterial(6, nil)
                        v:SetSubMaterial(7, nil)

                        render.SetBlend(1)
                    end
                end)
            end

        end
    end,

    eyx_leap = function(ply, ent, hitPos)
        local starttime = ent:GetNW2Float("EYX_LeapChargeStartTime")
        local factorClamped = math.Clamp((CurTime()-starttime)/2, 0, 1)
        local lerpfactor = Lerp(factorClamped, 0.5, 1)
        local power = 900 * lerpfactor


        local startPos = ply:GetPos()

        local dir = ply:GetAimVector()--(hitPos - startPos):GetNormalized()
        local velocity = dir * power*2

        velocity.z = velocity.z * 0.9
        velocity.x = velocity.x * 1.15
        velocity.y = velocity.y * 1.15

        if velocity.z < 120 then
            velocity.z = 120
        end

        ply:SetPos(ply:GetPos()+Vector(0,0,5))
        ply:SetLocalVelocity(velocity)

        ent:SetNW2Bool("EYX_leaping", true)
    end,

    eyx_leap_infection = function(ply, ent, hitPos)
        local power = 900 * 1

        local startPos = ply:GetPos()

        local dir = ply:GetAimVector()--(hitPos - startPos):GetNormalized()
        local velocity = dir * power

        velocity.z = velocity.z * 0.9
        velocity.x = velocity.x * 1.15
        velocity.y = velocity.y * 1.15

        if velocity.z < 120 then
            velocity.z = 120
        end

        ply:SetPos(ply:GetPos()+Vector(0,0,5))
        ply:SetVelocity(velocity)
        ply:SetLocalVelocity(velocity)

        ent:SetNW2Bool("EYX_leaping_infection", true)
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply, ent, button)
        if SERVER then
            if ent:GetNW2Float("OM_executionanim") > CurTime() then return end
            if button == KEY_E then
                ent:SetNW2Bool("EYX_holdleap", false)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply, ent, button)
        if ent:GetNW2Float("OM_executionanim") > CurTime() then return end
        if ent:GetNW2Float("eyx_slowdown_om") > CurTime() then return end

        if SERVER then
            if button == KEY_E then
                if not GetConVar("OUTCOMEMEMORIES_N_eyx_CanLeap"):GetBool() then return end
                if ent:GetNW2Float("eyx_leap_cd") > CurTime() then return end

                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("EYX_RetryLeap") then return end
                if ent:GetNW2Bool("EYX_holdleap") then return end
                if ent:GetNW2Bool("EYX_leaping") then return end
                if ent:GetNW2Bool("EYX_leaping") then return end
                if ent:GetNW2Float("EYXLandAnim") > CurTime() then return end
                if ent:GetNW2Float("eyx_puke_duration") > CurTime() then return end
                if ent:GetNW2Bool("EYX_leaping_infection") then return end
                if ent:GetNW2Float("eyx_FeralBite_duration") > CurTime() then return end

                if ply:IsOnGround() then
                    ent:SetNW2Bool("EYX_holdleap", true)
                    ply:SetVelocity(Vector(0,0,0))
                    ply:SetLocalVelocity(Vector(0,0,0))
                end
            end

            if button == KEY_R then
                if not GetConVar("OUTCOMEMEMORIES_N_eyx_CanSlamDunk"):GetBool() then return end
                if ent:GetNW2Float("eyx_slamduck_cd") > CurTime() then return end


                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("EYX_RetryLeap") then return end
                if ent:GetNW2Bool("EYX_holdleap") then return end
                if ent:GetNW2Bool("EYX_leaping") then return end
                if ent:GetNW2Bool("EYX_leaping") then return end
                if ent:GetNW2Float("EYXLandAnim") > CurTime() then return end

                if ent.eyx_slamduck_grab_grabbool then return end
                if ent:GetNW2Bool("eyx_slamduck_grab_crashing") then return end
                if ent:GetNW2Float("eyx_slamduck_grab_crashing_duration") > CurTime() then return end
                if ent.eyx_slamduck_grab_crashing_duration then return end
                if ent:GetNW2Float("eyx_slamduck_grab_grabduration") > CurTime() then return end
                if ent:GetNW2Float("eyx_screech_duration", 0 ) > CurTime() then return end
                if ent:GetNW2Float("eyx_puke_duration") > CurTime() then return end


                if ent:GetNW2Bool("EYX_leaping_infection") then return end
                if ent:GetNW2Float("eyx_FeralBite_duration") > CurTime() then return end

                AdvancedPillSound(
                    {
                        stringe = "OM/eyx/eyx_grabcharge.wav",
                        pitchPercent = 100,
                        volume = 0.8,
                        soundLevel = 87
                    },
                    ent
                )
                --[[
                AdvancedPillSound(
                    {
                        stringe = "OM/kolossos/Kol uses grab.wav",
                        pitchPercent = 100,
                        volume = 0.6,
                        soundLevel = 87
                    },
                    ent
                )
                ]]

                ent:SetNW2Float("eyx_slamduck_grab_grabduration", CurTime()+GetConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_duration_v2"):GetFloat())

                ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)
            end

            if button == KEY_T then
                if not GetConVar("OUTCOMEMEMORIES_N_eyx_CanScreech"):GetBool() then return end
                if ent:GetNW2Float("eyx_screech_cd") > CurTime() then return end

                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("EYX_RetryLeap") then return end
                if ent:GetNW2Bool("EYX_holdleap") then return end
                if ent:GetNW2Bool("EYX_leaping") then return end
                if ent:GetNW2Bool("EYX_leaping") then return end
                if ent:GetNW2Float("EYXLandAnim") > CurTime() then return end

                if ent.eyx_slamduck_grab_grabbool then return end
                if ent:GetNW2Bool("eyx_slamduck_grab_crashing") then return end
                if ent:GetNW2Float("eyx_slamduck_grab_crashing_duration") > CurTime() then return end
                if ent.eyx_slamduck_grab_crashing_duration then return end
                if ent:GetNW2Float("eyx_slamduck_grab_grabduration") > CurTime() then return end
                if ent:GetNW2Float("eyx_screech_duration", 0 ) > CurTime() then return end
                if ent:GetNW2Float("eyx_puke_duration") > CurTime() then return end
                if ent:GetNW2Bool("EYX_leaping_infection") then return end
                if ent:GetNW2Float("eyx_FeralBite_duration") > CurTime() then return end

                if not ply:IsOnGround() then return end

                ent:SetNW2Float("eyx_screech_cd", CurTime() + GetConVar("OUTCOMEMEMORIES_N_eyx_Screech_cd"):GetFloat())

                ent:PillAnim("screech")
                local seq = ent:GetPuppet():LookupSequence("screech")
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                ent:SetNW2Float("eyx_screech_duration", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                timer.Simple(0.7,function()
                    if !IsValid(ent) then return end

                    AdvancedPillSound(
                        {
                            stringe = "OM/eyx/shrierk v2.wav",
                            pitchPercent = 100,
                            volume = 0.75,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:SetNW2Float("eyx_screech_duration_inflict", CurTime() + ent:GetPuppet():SequenceDuration(seq) - 1.1)
                end)
                timer.Simple(0.5,function()
                    if !IsValid(ent) then return end

                    local hullSize = Vector(16, 16, 34)
                    local startPos = ply:GetPos() + Vector(0,0,10) + ent:GetPuppet():GetForward()*70
                    local endPos = startPos + Vector(0,0,-40)
                    local tr = util.TraceHull({
                        start = startPos,
                        endpos = endPos,
                        filter = ply,
                        mask = MASK_SOLID,
                        mins = -hullSize * 0.5,
                        maxs = hullSize * 0.5
                    })

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

                    ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                    ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)

                    local nearest
                    local nearestDist = math.huge

                    local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                    for _, ent2 in pairs(ents.FindInSphere(attackPos, 250)) do
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                            if not GetConVar("PVPStun_OM_exe"):GetBool() then
                                if ent2:GetNW2Bool("OM_character_monster") then continue end
                            end

                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end

                            if ent2.OM_Stun_Blockfunction then
                                ent2:OM_Stun_Blockfunction()
                            end

                            local dist = attackPos:DistToSqr(ent2:GetPos())
                            
                            ent2:SetNW2Float("OM_Damage_ReductionRemoveal", CurTime()+0.1)
                            KillerdamagestunDynamic({
                                ply = ply,
                                target = ent2,
                                DamageNumb = GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_screech_slam"):GetFloat(),
                                damagetype = DMG_CRUSH,
                                CustomDamageSound = nil,
                                damagesound = true,
                                ShouldBlood = true,
                                flingremoveal = true,
                                ShouldBloodEffect = true
                            })


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
                                            phys:SetVelocityInstantaneous(dir*750)
                                        end
                                    
                                    end
                                end
                            })
                        end
                    end

                end)
            end

            if button == KEY_I then
                if not GetConVar("OUTCOMEMEMORIES_N_eyx_CanInfection") then return end
                if ent:GetNW2Float("eyx_infection_cd") > CurTime() then return end

                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("EYX_RetryLeap") then return end
                if ent:GetNW2Bool("EYX_holdleap") then return end
                if ent:GetNW2Bool("EYX_leaping") then return end
                if ent:GetNW2Bool("EYX_leaping") then return end
                if ent:GetNW2Float("EYXLandAnim") > CurTime() then return end

                if ent.eyx_slamduck_grab_grabbool then return end
                if ent:GetNW2Bool("eyx_slamduck_grab_crashing") then return end
                if ent:GetNW2Float("eyx_slamduck_grab_crashing_duration") > CurTime() then return end
                if ent.eyx_slamduck_grab_crashing_duration then return end
                if ent:GetNW2Float("eyx_slamduck_grab_grabduration") > CurTime() then return end
                if ent:GetNW2Float("eyx_screech_duration", 0 ) > CurTime() then return end
                if ent:GetNW2Float("eyx_puke_duration") > CurTime() then return end
                if ent:GetNW2Bool("EYX_leaping_infection") then return end
                if ent:GetNW2Float("eyx_FeralBite_duration") > CurTime() then return end

                if not ply:IsOnGround() then return end
                
                if ent:GetNW2Float("Frenzy_duration_eyx") < CurTime() or not GetConVar("OUTCOMEMEMORIES_N_eyx_CanInfection_Swap"):GetBool() then
                    ent:PillAnim("Puke")

                    ent:SetNW2Float("eyx_infection_cd", CurTime() + GetConVar("OUTCOMEMEMORIES_N_eyx_Infection_cd"):GetFloat() )

                    local seq = ent:GetPuppet():LookupSequence("Puke")
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                    ent:SetNW2Float("eyx_puke_duration", CurTime() + ent:GetPuppet():SequenceDuration(seq))

                    timer.Simple(0.5,function()
                        if !IsValid(ent) then return end

                        if ent:GetNW2Float("eyx_puke_duration") < CurTime() then return end
                        if ply:IsPlayer() then
                            net.Start("eyx_retrieve_mouse_infection")
                            net.Send(ply)
                        else

                            ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                            ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)

                            local proj = ents.Create("prop_physics")
                            if IsValid(proj) then
                                local pos = ply:GetShootPos() + ply:GetAimVector() * 50

                                sound.Play("ambient/energy/weld1.wav", pos, 85, 120,0.7)
                                sound.Play("physics/flesh/flesh_squishy_impact_hard4.wav", pos, 80, 80,0.7)
                                sound.Play("ambient/levels/labs/electric_explosion1.wav", pos, 90, 105,0.7)

                                proj:SetModel("models/props_junk/PopCan01a.mdl")
                                proj:SetPos(pos)
                                proj:SetAngles(ply:EyeAngles())
                                proj:Spawn()

                                ent:DeleteOnRemove(proj)

                                proj:SetCollisionBounds(
                                    Vector(-25, -25, -25),
                                    Vector(25, 25, 25)
                                )

                                local function Explode()
                                    if !IsValid(proj) then return end
                                    local effect = EffectData()
                                    effect:SetOrigin(proj:GetPos())
                                    util.Effect("eyx_projectile_explode", effect, true, true)

                                    local pos = proj:GetPos()
                                    sound.Play("ambient/explosions/explode_4.wav", pos, 90, 85, 0.7)
                                    sound.Play("npc/antlion_guard/shove1.wav", pos, 80, 60, 0.7)
                                    sound.Play("physics/flesh/flesh_squishy_impact_hard4.wav", pos, 75, 80, 0.7)

                                    for _, ent2 in pairs(ents.FindInSphere(pos, 250)) do
                                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                                            if ent2 == ply then continue end
                                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                                            if not GetConVar("PVPStun_OM_exe"):GetBool() then
                                                if ent2:GetNW2Bool("OM_character_monster") then continue end
                                            end

                                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                                            if not Mutal_OMCanDamage(ply, ent, ent2) then continue end

                                            ent2:SetNW2Float("infectionstatus_eyx",CurTime()+13)

                                            KillerdamagestunDynamic({
                                                ply = ply,
                                                target = ent2,
                                                DamageNumb = GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_infection"):GetFloat(),
                                                damagetype = DMG_BLAST,
                                                CustomDamageSound = nil,
                                                damagesound = true,
                                                ShouldBlood = true,
                                                flingremoveal = true,
                                                ShouldBloodEffect = true
                                            })

                                            local last = CurTime() + 2
                                            local flung = false
                                            timer.Simple(0.1,function()
                                                flung = true
                                            end)
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
                                                    local dir = (ent2:GetPos() - pos):GetNormalized()


                                                    for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                        local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                                        if IsValid(phys) then
                                                            phys:Wake()
                                                            phys:SetVelocityInstantaneous(dir*800)
                                                        end
                                                    
                                                    end
                                                end
                                            })
                                        end
                                    end

                                    proj:Remove()
                                end

                                proj:AddCallback("PhysicsCollide", function()
                                    Explode()
                                end)

                                local phys = proj:GetPhysicsObject()
                                if IsValid(phys) then
                                    phys:EnableGravity(false)
                                    phys:SetMass(1)

                                    local dir = ply:GetAimVector()
                                    phys:SetVelocity(dir * 6000)
                                end

                                proj:SetNW2Float("Infection_projectile_om_eyx", CurTime() + 10)

                                timer.Simple(10, function()
                                    Explode()
                                end)
                            end

                        end
                    end)
                    
                else
                    AdvancedPillSound(
                        {
                            stringe = "OM/eyx/shrierk v2.wav",
                            pitchPercent = 100,
                            volume = 0.75,
                            soundLevel = 87
                        },
                        ent
                    )

                    if ply:IsPlayer() then
                        net.Start("eyx_retrieve_mouse_leap_infection")
                        net.Send(ply)
                    else

                        local power = 900 * 2

                        local dir = ply:GetAimVector()
                        local velocity = dir * power

                        velocity.z = velocity.z * 0.9
                        velocity.x = velocity.x * 1.15
                        velocity.y = velocity.y * 1.15

                        if velocity.z < 120 then
                            velocity.z = 120
                        end

                        ply:SetPos(ply:GetPos()+Vector(0,0,40))
                        ply:SetVelocity(velocity)
                        


                        ent:SetNW2Bool("EYX_leaping_infection", true)
                    end
                end
            end
        end
    end,

    eyx_infection = function(ply, ent, hitPos)

        ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
        ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)

        local proj = ents.Create("ent_om_eyx_infection")
        if not IsValid(proj) then return end

        proj:SetPos(ply:GetShootPos() + ply:GetAimVector() * 50)
        proj:SetAngles(ply:EyeAngles())

        proj.OwnerPlayer = ply
        proj.OwnerWeapon = ent

        proj:Spawn()

        ent:DeleteOnRemove(proj)

        proj:Launch(hitPos)
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if ent:GetNW2Float("OM_executionanim") > CurTime() then return end

            if SERVER then
                if ent:GetNW2Bool("EYX_RetryLeap") then return end
                if ent:GetNW2Bool("EYX_leaping") then return end
                if ent:GetNW2Bool("EYX_leaping") then return end
                if ent:GetNW2Float("EYXLandAnim") > CurTime() then return end
                if ent:GetNW2Float("eyx_screech_duration", 0 ) > CurTime() then return end
                if ent:GetNW2Bool("EYX_leaping_infection") then return end
                if ent:GetNW2Float("eyx_FeralBite_duration") > CurTime() then return end
                if ent:GetNW2Float("eyx_slowdown_om") > CurTime() then return end
                if ent:GetNW2Bool("eyx_slamduck_grab_crashing") then return end

                
                if ent.eyx_slamduck_grab_grabbool then return end
                if ent:GetNW2Float("eyx_slamduck_grab_crashing_duration") > CurTime() then return end
                if ent.eyx_slamduck_grab_crashing_duration then return end
                if ent:GetNW2Float("eyx_slamduck_grab_grabduration") > CurTime() then return end
                if ent:GetNW2Float("eyx_puke_duration") > CurTime() then return end

                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if not ent:GetNW2Bool("EYX_holdleap") then
                    local puppet = ent:GetPuppet()
                    if not IsValid(puppet) then return end
                    
                    AdvancedPillSound(
                        {
                            stringe = "OM/fleetway/Fleetway m1 swing.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    AdvancedPillSound(
                        {
                            stringe = "OM/eyx/Slash.wav",
                            pitchPercent = 100,
                            volume = 0.7,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1)
                    

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
                        puppet:RemoveLayer(puppet:FindGestureLayer(ACT_MELEE_ATTACK_SWING_GESTURE))
                    end)
                end

            end

            if ent:GetNW2Bool("EYX_holdleap") then
                ent:SetNW2Bool("EYX_holdleap", false)
                ent.EYX_holdleap = false
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
        AdvancedPillSound(
            {
                stringe = "OM/Jump.wav",
                pitchPercent = 100,
                volume = 1,
                soundLevel = 87
            },
            ent
        )

        ent:SetNW2Float("jump_animdur", CurTime()+0.1)
    end
})