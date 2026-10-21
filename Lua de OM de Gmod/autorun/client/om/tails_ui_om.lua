AddCSLuaFile()
if SERVER then
    util.AddNetworkString("tails_toggle_om")
end

--
if CLIENT then

    net.Receive("tails_toggle_om", function()
        local ply = LocalPlayer()

        surface.PlaySound("OM/tails/tails toggle.wav")
    end)

    local preservedmats = {
        ["Flight_bar"] = Material("icons/Flight_bar.png")
    }
    hook.Add("PreRenderColor_om_plain_optimized", "tails_ui_OM_noodles", function()--
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("tails_laserswap_burst", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("tails_laserswap_burst", 0)
                local duration, fade = 1.5, 0.25
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
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("tails_laserswap_orbs", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("tails_laserswap_orbs", 0)
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
                return ent:GetNW2Float("tails_laserswap_shockwave", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("tails_laserswap_shockwave", 0)
                local duration, fade = 1.5, 0.25
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 255, 0, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("tails_laserswap_laser", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("tails_laserswap_laser", 0)
                local duration, fade = 1.5, 0.25
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(0, 0, 255, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("tails_orbsglow", 0) > CurTime()
            end, 
            color = function(ent)
                return Color(255, 255, 0, 255)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("tails_white_highlight_pill", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("tails_white_highlight_pill", 0)
                local duration, fade = 0.5*0.35, 0.25*0.35
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
end