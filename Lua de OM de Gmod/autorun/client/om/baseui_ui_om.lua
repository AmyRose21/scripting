AddCSLuaFile()

-- SUBTITLES
if SERVER then
    util.AddNetworkString("OM_Subtitle_n")
else


    surface.CreateFont("OM_Subtitle_Large", {
        font = "Trebuchet MS",
        size = 64,
        weight = 800,
        antialias = true,
        shadow = false
    })
    surface.CreateFont("OM_Subtitle_Larger", {
        font = "Trebuchet MS",
        size = 128,
        weight = 800,
        antialias = true,
        shadow = false
    })

    local subtitles = {}

    local function AddSubtitle(text, duration)
        local startTime = CurTime()
        local letters = {}

        local font = "OM_Subtitle_Large"
        surface.SetFont(font)

        local centerX = ScrW() * 0.5 * 0.75
        local baseY   = ScrH() * 0.9

        text = '"' .. text .. '"'

        local totalW = surface.GetTextSize(text)
        local offsetX = -totalW / 2

        for i = 1, #text do
            local char = text[i]
            local w = surface.GetTextSize(char)

            table.insert(letters, {
                char = char,
                x = centerX + offsetX,
                y = baseY + 50,
                targetY = baseY,
                start = startTime + (i * 0.03),
                alpha = 0
            })

            offsetX = offsetX + w
        end

        table.insert(subtitles, {
            letters = letters,
            startTime = startTime,
            endTime = startTime + duration
        })
    end
    net.Receive("OM_Subtitle_n", function()
        local text = net.ReadString()
        local ply = LocalPlayer()

        if ply:GetInfoNum("om_pills_action_subtitles", 0) == 1 then
            AddSubtitle(string.upper(text), 4)
        end
    end)
    
    hook.Add("PostDrawHUD", "ChatTriggeredSubtitles", function()
        local time = CurTime()

        for i = #subtitles, 1, -1 do
            local sub = subtitles[i]

            if time > sub.endTime then
                table.remove(subtitles, i)
                continue
            end

            local progress = (time - sub.startTime) / (sub.endTime - sub.startTime)
            local fadeAlpha = 255

            if progress < 0.2 then
                fadeAlpha = Lerp(progress / 0.2, 0, 255)
            elseif progress > 0.8 then
                fadeAlpha = Lerp((progress - 0.8) / 0.2, 255, 0)
            end

            for _, l in ipairs(sub.letters) do
                if time >= l.start then
                    local frac = math.Clamp((time - l.start) * 3, 0, 1)

                    l.y = Lerp(frac, l.y, l.targetY)
                    l.alpha = Lerp(frac, l.alpha, fadeAlpha)

                    draw.SimpleText(
                        l.char,
                        "OM_Subtitle_Large",
                        l.x,
                        l.y,
                        Color(255, 40, 40, l.alpha),
                        TEXT_ALIGN_LEFT,
                        TEXT_ALIGN_TOP
                    )
                end
            end
        end
    end)
end


-- UI --

if SERVER then
    util.AddNetworkString("ShakeCamera_OM")
else
    net.Receive("ShakeCamera_OM", function()
        local ply = LocalPlayer()
        util.ScreenShake(
            ply:GetPos(),
            15,
            15,
            0.5,
            1
        )
    end)


    hook.Add("HUDPaint", "drawUI_OM_lnz", function()
        MINIgame_drawhud_om()
        blooddraw_drawhud_om()
    end)

    hook.Add("HUDShouldDraw", "pk_pill_hideHud_CUSTOM_OM", function(name)
        local ply = LocalPlayer()
        if !IsValid(ply) then return true end

        if name == "CHudHealth" and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            return false
        end
    end)
end