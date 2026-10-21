AddCSLuaFile()
if SERVER then
end

--
if CLIENT then

    hook.Add("PreRenderColor_om_plain_optimized", "Fang_ui_OM_noodles", function()--

        om_color.Add_plainoptimized({
            Canfuction = function(ent)
                local curTime = CurTime()
                local frameTime = FrameTime()

                ent.Fang_Gun_cork_red_Lerp =
                    ent.Fang_Gun_cork_red_Lerp or 0

                ent.Fang_Gun_cork_white_Lerp =
                    ent.Fang_Gun_cork_white_Lerp or 0

                ent.Fang_Gun_cork_yellow_Lerp =
                    ent.Fang_Gun_cork_yellow_Lerp or 0

                local redExpire = ent:GetNW2Float("Fang_Gun_cork_red", 0)
                local whiteExpire = ent:GetNW2Float("Fang_Gun_cork_white", 0)
                local yellowExpire = ent:GetNW2Float("Fang_Gun_cork_yellow", 0)

                if redExpire >= curTime then
                    ent.Fang_Gun_cork_red_Lerp = 1
                else
                    ent.Fang_Gun_cork_red_Lerp =
                        Lerp(frameTime * 0.5, ent.Fang_Gun_cork_red_Lerp, 0)
                end

                if whiteExpire >= curTime then
                    ent.Fang_Gun_cork_white_Lerp = 1
                else
                    ent.Fang_Gun_cork_white_Lerp =
                        Lerp(frameTime * 0.5, ent.Fang_Gun_cork_white_Lerp, 0)
                end

                if yellowExpire >= curTime then
                    ent.Fang_Gun_cork_yellow_Lerp = 1
                else
                    ent.Fang_Gun_cork_yellow_Lerp =
                        Lerp(frameTime * 0.5, ent.Fang_Gun_cork_yellow_Lerp, 0)
                end

                return ent.Fang_Gun_cork_red_Lerp >= 0.04
                    or ent.Fang_Gun_cork_white_Lerp >= 0.04
                    or ent.Fang_Gun_cork_yellow_Lerp >= 0.04
            end,

            color = function(ent)
                local r = ent.Fang_Gun_cork_red_Lerp or 0
                local w = ent.Fang_Gun_cork_white_Lerp or 0
                local y = ent.Fang_Gun_cork_yellow_Lerp or 0

                local red   = math.max(r, y)
                local green = math.max(w, y)
                local blue  = w

                local alpha = math.max(r, w, y) * 255 * 0.8

                return Color(
                    255 * red,
                    255 * green,
                    255 * blue,
                    alpha
                )
            end,

            ignorez = false
        })

        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                local expire = ent:GetNW2Float("Fang_Gun_flashwhite", 0)
                ent.Fang_Gun_flashwhite = ent.Fang_Gun_flashwhite or 0
                if expire >= CurTime() then
                    ent.Fang_Gun_flashwhite = Lerp(FrameTime()*7, ent.Fang_Gun_flashwhite, 1)
                else
                    ent.Fang_Gun_flashwhite = Lerp(FrameTime()*7, ent.Fang_Gun_flashwhite, 0)
                end
                return ent.Fang_Gun_flashwhite >= 0.04
            end, 
            color = function(ent)
                return Color(255, 255, 255, 255 * ent.Fang_Gun_flashwhite)
            end,
            ignorez = false 
        })
    end)
end