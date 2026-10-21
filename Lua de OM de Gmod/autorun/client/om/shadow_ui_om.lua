AddCSLuaFile()
if SERVER then
end

--
if CLIENT then

    hook.Add("pre_afterimage_om_optimize", "shadow_afterimage_OM_noodles", function()
        om_afterimage.Add_plainoptimized({
            Canfuction = function(ent)
                return ent:GetNW2Float("shadow_afterimage_duration", 0) > CurTime()
            end,
            color = Color(175,255,175,40),
            lifeTime = 0.2,
            afterimagecooldown = 0.015,
            name = "shadow_afterimage_duration",
            shouldnolighting = true,
        })
        om_afterimage.Add_plainoptimized({
            Canfuction = function(ent)
                return ent:GetNW2Float("shadow_natural_afterimage_duration", 0) > CurTime()
            end,
            color = Color(135,255,135,255),
            lifeTime = 0.5,
            afterimagecooldown = 0.75,
            name = "shadow_natural_afterimage_duration",
            shouldnolighting = true,
        })
    end)

    hook.Add("PreRenderColor_om_plain_optimized", "shadow_ui_OM_noodles", function()--
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("shadow_highlight_pill", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("shadow_highlight_pill", 0)
                local duration, fade = 0.5*0.5, 0.25*0.5
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 255, 255, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("shadow_highlight_pill_redglow", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("shadow_highlight_pill_redglow", 0)
                local duration, fade = 0.5*0.5, 0.25*0.5
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

    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_shadow", function()
        om_halo.Add_optimized(
            function(ent) 
                ent.shadow_ability_outline = ent.shadow_ability_outline or 0

                if ent:GetNW2Float("shadow_ability_outline", 0) >= CurTime() then 
                    ent.shadow_ability_outline = 1
                else
                    ent.shadow_ability_outline = Lerp(FrameTime()*5, ent.shadow_ability_outline, 0)
                end

                return ent.shadow_ability_outline > 0.1 
            end, 
            function(ent) 
                return Color(255, 255, 255, 255 * ent.shadow_ability_outline)
            end, 
            1, 
            false)    
          
    end )
end