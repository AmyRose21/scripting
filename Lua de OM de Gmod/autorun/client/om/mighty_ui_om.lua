AddCSLuaFile()
if CLIENT then

    hook.Add("PreRenderColor_om_plain_optimized", "Mighty_ui_OM_noodles", function()
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("Mighty_charge_glow_duration", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("Mighty_charge_glow_duration", 0)
                local duration, fade = 0.5*0.75, 0.25*0.75
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 255, 255, 255* alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("Mighty_chargeShoot_glow_duration", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("Mighty_chargeShoot_glow_duration", 0)
                local duration, fade = 0.5*0.75, 0.25*0.75
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 0, 0, 255* alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("mighty_glowwhite", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("mighty_glowwhite", 0)
                local duration, fade = 0.5, 0.25
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 255, 255, 255* alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("Amy_highlight_pill_red", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("Amy_highlight_pill_red", 0)
                local duration, fade = 0.5/1.5, 0.25/1.5
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 0, 0, 255* alpha)
            end,
            ignorez = false 
        })
    end)
end