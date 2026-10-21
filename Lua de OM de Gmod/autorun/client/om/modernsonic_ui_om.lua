AddCSLuaFile()
if SERVER then
end

--[[
PeelOutId


]]
if CLIENT then

    hook.Add("PreRenderColor_om_plain_optimized", "modernsonic_ui_OM_noodles", function()--
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                ent.modernsonic_ui_OM_noodles_lerp_white = ent.modernsonic_ui_OM_noodles_lerp_white or 0

                if ent:GetNW2Float("modernsonic_ui_OM_noodles_lerp_white", 0) > CurTime() then
                    ent.modernsonic_ui_OM_noodles_lerp_white = Lerp(FrameTime()*2, ent.modernsonic_ui_OM_noodles_lerp_white, 1)
                else
                    ent.modernsonic_ui_OM_noodles_lerp_white = Lerp(FrameTime()*5, ent.modernsonic_ui_OM_noodles_lerp_white, 0)
                end

                return ent.modernsonic_ui_OM_noodles_lerp_white >= 0.05
            end, 
            color = function(ent)

                return Color(255, 255, 255, 255 * ent.modernsonic_ui_OM_noodles_lerp_white)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                ent.modernsonic_ui_OM_noodles_lerp_white2 = ent.modernsonic_ui_OM_noodles_lerp_white2 or 0

                if ent:GetNW2Float("modernsonic_ui_OM_noodles_lerp_white2", 0) > CurTime() then
                    ent.modernsonic_ui_OM_noodles_lerp_white2 = Lerp(FrameTime()*1, ent.modernsonic_ui_OM_noodles_lerp_white2, 1)
                else
                    ent.modernsonic_ui_OM_noodles_lerp_white2 = Lerp(FrameTime()*5, ent.modernsonic_ui_OM_noodles_lerp_white2, 0)
                end

                return ent.modernsonic_ui_OM_noodles_lerp_white2 >= 0.05
            end, 
            color = function(ent)

                return Color(255, 255, 255, 255 * ent.modernsonic_ui_OM_noodles_lerp_white2)
            end,
            ignorez = false 
        })
    end)
    hook.Add("pre_afterimage_om_optimize", "modernsonic_afterimage_OM_noodles", function()
        om_afterimage.Add_plainoptimized({
            Canfuction = function(ent)
                return ent:GetNW2Float("modernsonic_afterimage_OM_noodles", 0) > CurTime()
            end,
            color = Color(255,255,255,35),
            lifeTime = 0.1,
            afterimagecooldown = 0.015,
            name = "modernsonic_afterimage_OM_noodles",
            shouldnolighting = true,
        })
        om_afterimage.Add_plainoptimized({
            Canfuction = function(ent)
                return ent:GetNW2Float("modernsonic_afterimage_OM_noodles_super", 0) > CurTime()
            end,
            color = Color(255,255,255,15),
            lifeTime = 0.1,
            afterimagecooldown = 0.015,
            name = "modernsonic_afterimage_OM_noodles_super",
            shouldnolighting = true,
        })
    end)

end