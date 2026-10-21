AddCSLuaFile()

if CLIENT then
    local blurMat = Material("pp/blurscreen")

    hook.Add("RenderScreenspaceEffects", "OM_ScreechEffect_eyx", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local status = ply:GetNW2Float("screechstatus_eyx", 0)
        if status <= CurTime() then return end

        local frac = math.Clamp((status - CurTime()) / 1, 0, 1)

        surface.SetDrawColor(255, 255, 255, 255)

        for i = 1, 6 do
            blurMat:SetFloat("$blur", i * 1.5 * frac)
            blurMat:Recompute()

            render.UpdateScreenEffectTexture()

            surface.SetMaterial(blurMat)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        end
    end)

    hook.Add("Think", "OM_ScreechDSP_eyx", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local status = ply:GetNW2Float("screechstatus_eyx", 0)
        local active = status > CurTime()

        if active then
            if not ply.OM_ScreechDSP then
                ply:SetDSP(31, false)

                surface.PlaySound("ambient/levels/labs/electric_explosion5.wav")

                ply.OM_ScreechDSP = true
            end
        else
            if ply.OM_ScreechDSP then
                ply:SetDSP(0, false)
                ply.OM_ScreechDSP = nil
            end
        end
    end)

    hook.Add("PreRenderColor_om_plain_optimized", "eyx_eui_OM_noodles", function()
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
                    if pillentity.formTable.Outcomememories == "eyx" then
                        hasworldcard = true
                    end
                end
            end
        end
        if hasworldcard then
            om_color.Add_plainoptimized({ 
                Canfuction = function(ent) 
                    return ent:GetNW2Float("screechstatus_eyx", 0) > CurTime()
                end, 
                color = function(ent)
                    return Color(255, 0, 0, 255 *0.5)
                end,
                ignorez = true 
            })
            om_color.Add_plainoptimized({ 
                Canfuction = function(ent) 
                    return ent:GetNW2Float("infectionstatus_eyx", 0) > CurTime()
                end, 
                color = function(ent)
                    return Color(0, 0, 255, 255 *0.5)
                end,
                ignorez = true 
            })
        end
    end)
end