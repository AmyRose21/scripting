AddCSLuaFile()
if SERVER then
end

--
if CLIENT then

    hook.Add("PreRenderColor_om_plain_optimized", "tripwirehighlight", function()--
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                local expire = ent.tripwirehighlight_0 or 0

                if not ent.tripwirehighlight_0_alpha then
                    ent.tripwirehighlight_0_alpha = 0
                end

                local fadeInTime = 0.15
                local fadeOutTime = 0.4

                local targetAlpha = 0

                if expire > CurTime() then
                    targetAlpha = 255
                    ent.tripwirehighlight_0_alpha = math.Approach(
                        ent.tripwirehighlight_0_alpha,
                        targetAlpha,
                        FrameTime() * (255 / fadeInTime)
                    )
                else
                    ent.tripwirehighlight_0_alpha = math.Approach(
                        ent.tripwirehighlight_0_alpha,
                        0,
                        FrameTime() * (255 / fadeOutTime)
                    )
                end

                return ent.tripwirehighlight_0_alpha > 1
            end, 
            color = function(ent)
                return Color(255, 0, 0, ent.tripwirehighlight_0_alpha)
            end,
            ignorez = true 
        })
    end)


end