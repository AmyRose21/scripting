AddCSLuaFile()

--
if CLIENT then

    hook.Add("PreRenderColor_om_plain_optimized", "ray_ui_OM_noodles", function()--
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                local expire = ent:GetNW2Float("ray_flashgreen_OM", 0)
                ent.ray_flashgreen_OM = ent.ray_flashgreen_OM or 0
                if expire >= CurTime() then
                    ent.ray_flashgreen_OM = Lerp(FrameTime()*7, ent.ray_flashgreen_OM, 1)
                else
                    ent.ray_flashgreen_OM = Lerp(FrameTime()*7, ent.ray_flashgreen_OM, 0)
                end
                return ent.ray_flashgreen_OM >= 0.04
            end, 
            color = function(ent)
                return Color(0, 255, 0, 255 * ent.ray_flashgreen_OM)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                local expire = ent:GetNW2Float("ray_flashred_OM", 0)
                ent.ray_flashred_OM = ent.ray_flashred_OM or 0
                if expire >= CurTime() then
                    ent.ray_flashred_OM = Lerp(FrameTime()*7, ent.ray_flashred_OM, 1)
                else
                    ent.ray_flashred_OM = Lerp(FrameTime()*7, ent.ray_flashred_OM, 0)
                end
                return ent.ray_flashred_OM >= 0.04
            end, 
            color = function(ent)
                return Color(255, 0, 0, 255 * ent.ray_flashred_OM)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                local expire = ent:GetNW2Float("ray_flashwhite_OM", 0)
                ent.ray_flashwhite_OM = ent.ray_flashwhite_OM or 0
                if expire >= CurTime() then
                    ent.ray_flashwhite_OM = Lerp(FrameTime()*7, ent.ray_flashwhite_OM, 1)
                else
                    ent.ray_flashwhite_OM = Lerp(FrameTime()*3, ent.ray_flashwhite_OM, 0)
                end
                return ent.ray_flashwhite_OM >= 0.04
            end, 
            color = function(ent)
                return Color(255, 255, 255, 255 * ent.ray_flashwhite_OM)
            end,
            ignorez = false 
        })
    end)

    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_ray", function() 

        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Bool("ray_ability_outline2")
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            1, 
            false)            
    end )

end