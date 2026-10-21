AddCSLuaFile()
if SERVER then
    util.AddNetworkString("2011x_Ragemodemeter")
end

--
if CLIENT then
    hook.Add("PreRenderColor_om_plain_optimized", "2011x_ui_OM_noodles", function()

        local colortypes = {
            ["red"] = { Color = {R = 1, G = 0, B = 0}, blend = 0.6 },
            ["black"] = { Color = {R = 0, G = 0, B = 0}, blend = 1 },
            ["white"] = { Color = {R = 1, G = 1, B = 1}, blend = 0.6 },
            ["blue"] = { Color = {R = 0, G = 0, B = 1}, blend = 0.6 }
        }

        om_color.Add_plainoptimized({
            Canfuction = function(ent)
                for name, v in pairs(colortypes) do
                    local key = "Var2011x_trickery_" .. name
                    local expire = ent:GetNW2Float("2011x_trickery_" .. name, 0)

                    v[key] = v[key] or 0

                    if expire >= CurTime() then
                        v[key] = v.blend
                    else
                        v[key] = 0
                    end

                    if v[key] > 0.025 then
                        return true
                    end
                end

                return false
            end, 
            color = function(ent)
                local r, g, b, a = 0, 0, 0, 0
                local totalBlend = 0

                for name, v in pairs(colortypes) do
                    local key = "Var2011x_trickery_" .. name
                    local expire = ent:GetNW2Float("2011x_trickery_" .. name, 0)

                    v[key] = v[key] or 0

                    if expire >= CurTime() then
                        local blend = v.blend or 0

                        r = r + (v.Color.R * 255) * blend
                        g = g + (v.Color.G * 255) * blend
                        b = b + (v.Color.B * 255) * blend
                        a = a + blend * 255

                        totalBlend = totalBlend + blend
                    end
                end

                if totalBlend > 0 then
                    r = r / totalBlend
                    g = g / totalBlend
                    b = b / totalBlend
                    a = a / totalBlend
                else
                    r, g, b, a = 255, 255, 255, 255
                end

                return Color(r,g,b,a)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("2011x_redflash_om", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("2011x_redflash_om", 0)
                local duration, fade = 0.5, 0.25
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 0, 0, 255 * alpha)
            end,
            ignorez = false 
        })
    end)

    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_2011x", function()
        om_halo.Add_optimized(
            function(ent) 
                ent.q2011x_ability_outline = ent.q2011x_ability_outline or 0

                if ent:GetNW2Float("2011x_ability_outline", 0) >= CurTime() then 
                    ent.q2011x_ability_outline = 1
                else
                    ent.q2011x_ability_outline = Lerp(FrameTime()*5, ent.q2011x_ability_outline, 0)
                end

                return ent.q2011x_ability_outline > 0.1 
            end, 
            function(ent) 
                return Color(255, 255, 255, 255 * ent.q2011x_ability_outline)
            end, 
            1, 
            false)    
    end )


    local preservedmats = {
        ["2011xHand_create"] = Material("icons/2011xHand_create.png"),
        ["2011xHand_hold"] = Material("icons/2011xHand_hold.png"),
        ["2011xragemodebar"] = Material("icons/2011xragemodebar.png"),
    }

    surface.CreateFont("2011x_RageModeFont", {
        font = "Trebuchet24",
        size = 50,
        weight = 800,
        antialias = true,
        extended = true
    })

    local snd

    local registeredragemode = {}

    net.Receive("2011x_Ragemodemeter", function()
        local ply = LocalPlayer()
        local ent = net.ReadEntity()
        local timeleft = net.ReadFloat()
        local bool = net.ReadBool()

        local hookname = "2011x_RageMode_ValidityWatch" .. ent:EntIndex()
        local timername = "2011x_RageMode_Timer" .. ent:EntIndex()
        if bool then 
            if not snd then
                snd = CreateSound(LocalPlayer(), "OM/music/2011xrage.wav")
            end
            if snd and not snd:IsPlaying() then
                snd:Play()
                snd:ChangeVolume(0.35, 0)
            end

            registeredragemode[ent] = {}

            registeredragemode[ent].Var2011x_startup = CurTime()
            registeredragemode[ent].ragemodecomplete = true
            registeredragemode[ent].InRageMode = true

            registeredragemode[ent].rightHandAng = 0
            registeredragemode[ent].leftHandAng =  0
            registeredragemode[ent].barAng = 0
            registeredragemode[ent].Var2011x_endanim_startup = 0

            registeredragemode[ent].ragemodeduration = timeleft

            hook.Add("Think", hookname, function()
                if not IsValid(ent) then

                    hook.Remove("Think", hookname)
                    timer.Remove(timername)
                    registeredragemode[ent].Var2011x_endanim_startup = CurTime()

                    snd:Stop()

                    return
                end
            end)

            timer.Create(timername, timeleft, 1, function()

                hook.Remove("Think", hookname)
                if not IsValid(ent) then
                    return
                end

                if registeredragemode[ent] then
                    registeredragemode[ent].Var2011x_endanim_startup = CurTime()
                end
            end)
        else
            if not IsValid(ent) then
                return
            end
            hook.Remove("Think", hookname)
            timer.Remove(timername)
            if registeredragemode[ent] then
                registeredragemode[ent].Var2011x_endanim_startup = CurTime()
            end
        end
    end)

    hook.Add("HUDPaint", "drawUI_OM_2011x_global", function()
        local ply = LocalPlayer()
        for i,v in pairs(registeredragemode) do

            local Var2011x_startup = registeredragemode[i].Var2011x_startup
            local ragemodecomplete = registeredragemode[i].ragemodecomplete
            local InRageMode = registeredragemode[i].InRageMode

            local rightHandAng = registeredragemode[i].rightHandAng
            local leftHandAng = registeredragemode[i].leftHandAng
            local barAng = registeredragemode[i].barAng

            local Var2011x_endanim_startup = registeredragemode[i].Var2011x_endanim_startup

            if not InRageMode then continue end
            local screenW, screenH = ScrW(), ScrH()
            local middlex, middley = screenW * 0.5, screenH * 0.5
            local iconsize = screenW / 13

            local startXLeft, startYLeft = iconsize, screenH - (iconsize * 2)
            local startXRight, startYRight = screenW - (iconsize * 2), screenH - (iconsize * 2)

            local startXLeft_widen = iconsize * 0.25
            local startXRight_widen = screenW - startXLeft_widen - iconsize

            local offset = iconsize * 0.53
            local Create_middleXLeft = middlex - offset
            local Create_middleXRight = middlex + offset - iconsize

            local startXLeft_holding = middlex - iconsize * 3
            local startXRight_holding = middlex + iconsize * 3 - iconsize

            local lefthandXlerp = startXLeft
            local lefthandYlerp = startYLeft

            local righthandXlerp = startXRight
            local righthandYlerp = startYRight

            local curtime = CurTime()
            local shoulddrawbar = false
            local handholding = false
            local drawbar = false
            local barProgress = true

            if Var2011x_startup + 0.25 >= curtime then
                barAng = 0
                leftHandAng =  0
                rightHandAng = 0
                local factorclamp = math.Clamp((curtime - Var2011x_startup) / 0.25, 0, 1)
                factorclamp = 1 - (1 - factorclamp) ^ 3

                lefthandXlerp = Lerp(factorclamp, startXLeft, startXLeft_widen)
                righthandXlerp = Lerp(factorclamp, startXRight, startXRight_widen)

            elseif Var2011x_startup + 1.25 >= curtime then
                local factorclamp = math.Clamp((curtime - Var2011x_startup) / 1, 0, 1)
                factorclamp = factorclamp ^ 4

                lefthandXlerp = Lerp(factorclamp, startXLeft_widen, Create_middleXLeft)
                righthandXlerp = Lerp(factorclamp, startXRight_widen, Create_middleXRight)

            elseif Var2011x_startup + 2 >= curtime then
                lefthandXlerp = Create_middleXLeft
                righthandXlerp = Create_middleXRight

            elseif Var2011x_startup + 3 >= curtime or ragemodecomplete then

                local factorclamp = math.Clamp((curtime - (Var2011x_startup + 2)) / 1, 0, 1)

                lefthandXlerp = Lerp(factorclamp, Create_middleXLeft, startXLeft_holding)
                righthandXlerp = Lerp(factorclamp, Create_middleXRight, startXRight_holding)

                ragemodecomplete = true
                shoulddrawbar = true
                drawbar = true

                barProgress = factorclamp

                if Var2011x_startup + 2.75 >= curtime then
                else
                    handholding = true
                end
            end

            local bar_progy = screenH - (iconsize * 1.6) + iconsize * 0.15
            local bary = screenH - (iconsize * 1.6)
            if Var2011x_endanim_startup + 1.75 >= curtime then

                local t = curtime - Var2011x_endanim_startup
                local factorclamp = math.Clamp(t / 1.5, 0, 1)

                local smoothFactor = factorclamp * factorclamp * (3 - 2 * factorclamp)
                local rotations = Lerp(smoothFactor, 0, -360)

                barAng = rotations
                leftHandAng = rotations
                rightHandAng = rotations

                handholding = true
                ragemodecomplete = false
                shoulddrawbar = true
                drawbar = true

                barProgress = 1

                lefthandXlerp = startXLeft_holding
                righthandXlerp = startXRight_holding

                local function easeOutQuad(x)
                    return 1 - (1 - x) * (1 - x)
                end

                local function easeInQuad(x)
                    return x * x
                end

                if t <= 0.75 then

                    local f = math.Clamp(t / 0.75, 0, 1)
                    f = easeOutQuad(f)

                    local targetLift = iconsize * 2

                    lefthandYlerp = Lerp(f, startYLeft, startYLeft - targetLift)
                    righthandYlerp = Lerp(f, startYRight, startYRight - targetLift)

                    bary = Lerp(f, bary, bary - targetLift)
                    bar_progy = Lerp(f, bar_progy, bar_progy - targetLift)
                else

                    local f = math.Clamp((t - 0.75) / 0.75, 0, 1)
                    f = easeInQuad(f)

                    local targetLift = iconsize * 2

                    lefthandYlerp = Lerp(f, startYLeft - targetLift, startYLeft + targetLift * 1.5)
                    righthandYlerp = Lerp(f, startYRight - targetLift, startYRight + targetLift * 1.5)

                    bary = Lerp(f, bary - targetLift, bary + targetLift * 2)
                    bar_progy = Lerp(f, bar_progy - targetLift, bar_progy + targetLift * 2)
                    
                end
                if t >= 1.6 then registeredragemode[i].InRageMode = false end
            end

            local function PushRotate(x, y, ang)
                local m = Matrix()
                m:Translate(Vector(x, y, 0))
                m:Rotate(Angle(0, ang, 0))
                m:Translate(Vector(-x, -y, 0))
                cam.PushModelMatrix(m)
            end

            -- bar
            if drawbar then
                local progress = barProgress or 0

                local fullWidth = iconsize * 5
                local height = iconsize * 0.7

                local width = fullWidth * progress
                local x = middlex - (width * 0.5)

                local pivotX = middlex
                local pivotY = bar_progy + height * 0.5

                PushRotate(pivotX, pivotY, barAng)
                    surface.SetDrawColor(0, 0, 0, 255)
                    surface.DrawRect(x, bar_progy, width, height)

                    local clampfactor = math.Clamp((CurTime()-registeredragemode[i].Var2011x_startup)/(registeredragemode[i].ragemodeduration+3),0,1)
                    local lerpfactor = Lerp(clampfactor, 1,0)

                    surface.SetDrawColor(255, 0, 0, 255)
                    surface.DrawRect(x, bar_progy, width*lerpfactor, height)

                    local frameFullWidth = iconsize * 2.7 * 2
                    local frameWidth = frameFullWidth * progress
                    local frameX = middlex - (frameWidth * 0.5)

                    surface.SetMaterial(preservedmats["2011xragemodebar"])
                    surface.SetDrawColor(255, 255, 255, 255)

                    surface.DrawTexturedRect(
                        frameX,
                        bary,
                        frameWidth,
                        iconsize
                    )

                local remaining = math.max((registeredragemode[i].Var2011x_startup + (registeredragemode[i].ragemodeduration or 0)) - CurTime(), 0)
                local minutes = math.floor(remaining / 60)
                local seconds = math.floor(remaining % 60)

                local mm = string.format("%02d", minutes)
                local ss = string.format("%02d", seconds)
                local colon = ":"

                surface.SetFont("2011x_RageModeFont")

                local wMM, hMM = surface.GetTextSize(mm)
                local wColon, hColon = surface.GetTextSize(colon)
                local wSS, hSS = surface.GetTextSize(ss)

                local baseX = middlex
                local baseY = bar_progy + height * 0.5 - hMM * 0.5

                local t = CurTime()

                local offMM = math.sin(t * 4) * 4
                local offSS = math.sin(t * 4 + 1.7) * 4
                local offColon = math.sin(t * 2) * 2

                local spacing = 4

                local function DrawOutlined(txt, x, y, r, g, b)
                    surface.SetTextColor(0, 0, 0, 255)

                    for ox = -2, 2 do
                        for oy = -2, 2 do
                            if ox ~= 0 or oy ~= 0 then
                                surface.SetTextPos(x + ox, y + oy)
                                surface.DrawText(txt)
                            end
                        end
                    end

                    surface.SetTextColor(r, g, b, 255)
                    surface.SetTextPos(x, y)
                    surface.DrawText(txt)
                end

                DrawOutlined(
                    mm,
                    baseX - (wMM + wColon * 0.5 + spacing),
                    baseY + offMM,
                    175, 0, 0
                )

                DrawOutlined(
                    colon,
                    baseX - (wColon * 0.5),
                    baseY + offColon,
                    175, 0, 0
                )

                DrawOutlined(
                    ss,
                    baseX + (wColon * 0.5 + spacing),
                    baseY + offSS,
                    175, 0, 0
                )
                cam.PopModelMatrix()
            end

            if handholding then surface.SetMaterial(preservedmats["2011xHand_hold"]) else surface.SetMaterial(preservedmats["2011xHand_create"]) end
            surface.SetDrawColor(255, 255, 255, 255)

            local lw = iconsize
            local lh = iconsize * 2

            local leftPivotX = lefthandXlerp + lw * 0.5
            local leftPivotY = lefthandYlerp + lh * 0.5

            PushRotate(leftPivotX, leftPivotY, leftHandAng)

                surface.SetMaterial(
                    handholding and preservedmats["2011xHand_hold"]
                    or preservedmats["2011xHand_create"]
                )

                surface.SetDrawColor(255, 255, 255, 255)

                surface.DrawTexturedRect(
                    lefthandXlerp,
                    lefthandYlerp,
                    lw,
                    lh
                )

            cam.PopModelMatrix()
            -- Right hand
            local rw = iconsize
            local rh = iconsize * 2

            local rightPivotX = righthandXlerp + rw * 0.5
            local rightPivotY = righthandYlerp + rh * 0.5

            PushRotate(rightPivotX, rightPivotY, rightHandAng)

                surface.SetMaterial(
                    handholding and preservedmats["2011xHand_hold"]
                    or preservedmats["2011xHand_create"]
                )

                surface.SetDrawColor(255, 255, 255, 255)

                surface.DrawTexturedRectUV(
                    righthandXlerp,
                    righthandYlerp,
                    rw,
                    rh,
                    1, 0,
                    0, 1
                )

            cam.PopModelMatrix()
        end
    end)
end