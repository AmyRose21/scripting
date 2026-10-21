AddCSLuaFile()

--
if CLIENT then

    hook.Add("pre_afterimage_om_optimize", "sunky_afterimage_OM_noodles", function()
        om_afterimage.Add_plainoptimized({
            Canfuction = function(ent)
                return ent:GetNW2Float("sunky_afterimage_OM_noodles", 0) > CurTime()
            end,
            color = Color(255,125,125,15),
            lifeTime = 0.2,
            afterimagecooldown = 0.015,
            name = "sunky_afterimage_OM_noodles",
            shouldnolighting = true,
        })
    end)

    hook.Add("PreRenderColor_om_plain_optimized", "sunky_eui_OM_noodles", function()
        local ply = LocalPlayer()
        local pillentity = LocalPlayer().pk_pill_ent
        local isdrgbase = false
        if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end
        
        local hasworldcard

        if IsValid(pillentity) then
            if pillentity.formTable then
                if pillentity.formTable.Outcomememories then
                    if pillentity.formTable.Outcomememories == "Sunky" then
                        hasworldcard = true
                    end
                end
            end
        end
        if hasworldcard then
            om_color.Add_plainoptimized({ 
                Canfuction = function(ent) 
                    return ent:GetNW2Float("sunky_afterimage_OM_noodles_indicator", 0) > CurTime()
                end, 
                color = function(ent)
                    return Color(0, 185, 255, 255 *0.75)
                end,
                ignorez = true 
            })
            om_color.Add_plainoptimized({ 
                Canfuction = function(ent) 
                    ent.sunky_afterimage_OM_noodles_indicator_hit = ent.sunky_afterimage_OM_noodles_indicator_hit or 0
                    if ent:GetNW2Float("sunky_afterimage_OM_noodles_indicator_hit", 0) > CurTime() then
                        ent.sunky_afterimage_OM_noodles_indicator_hit = Lerp(FrameTime()*5, ent.sunky_afterimage_OM_noodles_indicator_hit, 1)
                    else
                        ent.sunky_afterimage_OM_noodles_indicator_hit = Lerp(FrameTime()*5, ent.sunky_afterimage_OM_noodles_indicator_hit, 0)
                    end
                    return ent.sunky_afterimage_OM_noodles_indicator_hit >= 0.05
                end, 
                color = function(ent)
                    return Color(255, 0, 0, 255 *0.75 * ent.sunky_afterimage_OM_noodles_indicator_hit)
                end,
                ignorez = true 
            })
        end
    end)
    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_sunky", function()
        om_halo.Add_optimized(
            function(ent) 
                    return ent:GetNW2Float("sunky_afterimage_OM_noodles_indicator", 0) > CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            3, 
            true)  
        om_halo.Add_optimized(
            function(ent) 
                    return ent:GetNW2Float("sunky_afterimage_OM_noodles_indicator_hit", 0) > CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            3, 
            true)    
          
    end )
end