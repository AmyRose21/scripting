AddCSLuaFile()
if SERVER then
end

--
if CLIENT then
    hook.Add("pre_afterimage_om_optimize", "silver_afterimage_OM_noodles", function()
        om_afterimage.Add_plainoptimized({
            Canfuction = function(ent)
                return ent:GetNW2Float("silver_afterimage_duration", 0) > CurTime()
            end,
            color = Color(255,255,255,85),
            lifeTime = 1.2,
            afterimagecooldown = 0.2,
            name = "silver_afterimage_duration",
            shouldnolighting = true,
        })
    end)

    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_Silver", function()
        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("OM_highlight_Silver", 0) > CurTime()
            end, 
            function(ent) 
                return Color(0, 185, 255, 255)
            end, 
            1, 
            false)            
    end )


    hook.Add("PreRenderColor_om_plain_optimized", "OM_highlight_Silver_color", function()--
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("OM_highlight_Silver_color", 0) > CurTime()
            end, 
            color = function(ent)
                return Color(0, 255*0.85, 255, 255)
            end,
            ignorez = false 
        })
    end)

end