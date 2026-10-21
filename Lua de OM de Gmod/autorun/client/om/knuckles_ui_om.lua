AddCSLuaFile()
if SERVER then
end


if CLIENT then

    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_knuckles", function()
        local ply = LocalPlayer()

        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("knuckles_block_outline", 0) >= CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            1, 
            false)            
    end )

    hook.Add("PreRenderColor_om_plain_optimized", "Knuckles_ui_OM_noodles", function()
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("Knuckles_glow_duration", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("Knuckles_glow_duration", 0)
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
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("Knuckles_glow_duration_white", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("Knuckles_glow_duration_white", 0)
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
                return ent:GetNW2Float("Knuckles_glow_cancel_duration", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("Knuckles_glow_cancel_duration", 0)
                local duration, fade = 0.5*0.5, 0.25*0.5
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(0, 255, 0, 255 * alpha)
            end,
            ignorez = false 
        })
    end)
end