AddCSLuaFile()
if SERVER then
end

--[[
PeelOutId


]]
if CLIENT then

    hook.Add("pre_afterimage_om_optimize", "sonic_afterimage_OM_noodles", function()
        om_afterimage.Add_plainoptimized({
            Canfuction = function(ent)
                return ent:GetNW2Float("sonicdodge_afterimage_duration", 0) > CurTime()
            end,
            color = Color(255,255,255,195),
            lifeTime = 1,
            afterimagecooldown = 0.05,
            name = "sonicdodge_afterimage_duration",
            shouldnolighting = true,
        })
    end)


    hook.Add("PreRenderColor_om_plain_optimized", "sonic_ui_OM_noodles", function()--
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("sonic_attack_glow_duration", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("sonic_attack_glow_duration", 0)
                local duration, fade = 1.5, 0.25
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
                return ent:GetNW2Float("sonic_glow_duration", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("sonic_glow_duration", 0)
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
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("sonic_glow_duration_white", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("sonic_glow_duration_white", 0)
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
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("sonic_glow_duration_blue", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("sonic_glow_duration_blue", 0)
                local duration, fade = 0.5, 0.25
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(0, 255*0.4, 255, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("sonic_glow_duration_blueSlow", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("sonic_glow_duration_blueSlow", 0)
                local duration, fade = 0.75, 0.25
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(0, 255*0.4, 255, 255 * alpha)
            end,
            ignorez = false 
        })
    end)

    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_sonic", function()
        om_halo.Add_optimized(
            function(ent) 
                ent.sonic_ability_outline = ent.sonic_ability_outline or 0

                if ent:GetNW2Float("sonic_ability_outline", 0) >= CurTime() then 
                    ent.sonic_ability_outline = 1
                else
                    ent.sonic_ability_outline = Lerp(FrameTime()*5, ent.sonic_ability_outline, 0)
                end

                return ent.sonic_ability_outline > 0.1 
            end, 
            function(ent) 
                return Color(255, 255, 255, 255 * ent.sonic_ability_outline)
            end, 
            1, 
            false)    

        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("sonic_ability_outline2", 0) > CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            1, 
            false)            
    end )
end