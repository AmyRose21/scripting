AddCSLuaFile()

--
if CLIENT then

    hook.Add("PreRenderColor_om_plain_optimized", "vector_ui_OM_noodles", function()--
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                local expire = ent:GetNW2Float("vector_ringcolor", 0)
                return expire >= CurTime()
            end, 
            color = function(ent)
                return Color(255, 255, 0, 255)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                local expire = ent:GetNW2Float("vector_punchflash", 0)
                ent.vector_punchflash = ent.vector_punchflash or 0
                if expire >= CurTime() then
                    ent.vector_punchflash = Lerp(FrameTime()*4, ent.vector_punchflash, 1)
                else
                    ent.vector_punchflash = Lerp(FrameTime()*4, ent.vector_punchflash, 0)
                end
                return ent.vector_punchflash >= 0.04
            end, 
            color = function(ent)
                return Color(255, 0, 0, 255 * ent.vector_punchflash)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                local expire = ent:GetNW2Float("vector_punchflash_white", 0)
                ent.vector_punchflash_white = ent.vector_punchflash_white or 0
                if expire >= CurTime() then
                    ent.vector_punchflash_white = Lerp(FrameTime()*4, ent.vector_punchflash_white, 1)
                else
                    ent.vector_punchflash_white = Lerp(FrameTime()*4, ent.vector_punchflash_white, 0)
                end
                return ent.vector_punchflash_white >= 0.04
            end, 
            color = function(ent)
                return Color(255, 255, 255, 255 * ent.vector_punchflash_white)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                local expire = ent:GetNW2Float("vector_punchflash_yellow", 0)
                ent.vector_punchflash_yellow = ent.vector_punchflash_yellow or 0
                if expire >= CurTime() then
                    ent.vector_punchflash_yellow = Lerp(FrameTime()*4, ent.vector_punchflash_yellow, 1)
                else
                    ent.vector_punchflash_yellow = Lerp(FrameTime()*4, ent.vector_punchflash_yellow, 0)
                end
                return ent.vector_punchflash_yellow >= 0.04
            end, 
            color = function(ent)
                return Color(255, 255, 0, 255 * ent.vector_punchflash_yellow)
            end,
            ignorez = false 
        })
    end)
end