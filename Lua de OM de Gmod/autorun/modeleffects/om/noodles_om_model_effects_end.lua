AddCSLuaFile()
if SERVER then
else                                                                                    -- CLIENT --


    hook.Add("PreRenderColor_om_render_optimized", "end_burn_model_end_new", function()
        om_color.Add_renderoptimized({ 
            Canfuction = function(ent) 
                return ent:GetModel() == "models/noodles/om/end_new.mdl"
            end, 
            customdrawfunction = function(ent) 
                local hasbodygroup = ent:GetBodygroup(1)

                --cam.IgnoreZ(true)
                ent:SetBodygroup(1,0)
                render.SetBlend(ent:GetColor().a / 255)
                    ent:DrawModel()
                render.SetBlend(1)
                ent:SetBodygroup(1,hasbodygroup)
            end, 
            ignorez = false,
            rendereffects = function(ent)

                local multiplyer = 0.85

                local alpha = ent:GetColor().a / 255

                DrawColorModify({
                    ["$pp_colour_addr"]       = 0,
                    ["$pp_colour_addg"]       = 0,
                    ["$pp_colour_addb"]       = 0 ,
                    ["$pp_colour_brightness"] = 0,
                    ["$pp_colour_contrast"]   = 1 + (3 * alpha),
                    ["$pp_colour_colour"]     = 1 + (1.5 * alpha),
                    ["$pp_colour_mulr"]       = 0,
                    ["$pp_colour_mulg"]       = 0,
                    ["$pp_colour_mulb"]       = 0
                })
                
            end
        })
    end)

end