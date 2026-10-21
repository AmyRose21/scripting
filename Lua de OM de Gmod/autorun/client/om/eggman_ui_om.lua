AddCSLuaFile()

--
if CLIENT then

    hook.Add("PreRenderColor_om_plain_optimized", "eggman_ui_OM_noodles", function()--
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("eggman_jetpackboost_highlight", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("eggman_jetpackboost_highlight", 0)
                local duration, fade = 0.25, 0.125
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 175, 0, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("eggman_jshield_highlight", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("eggman_jshield_highlight", 0)
                local duration, fade = 0.5, 0.25
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
    end)

    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_eggman", function()  
        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("eggman_jetpackboost_highlight", 0) > CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            1, 
            false)            
    end )
end