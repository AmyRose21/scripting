AddCSLuaFile()
if SERVER then
    util.AddNetworkString("lilith_spawnpointspawndisplay")
    util.AddNetworkString("lilith_reverseindicate")
end

--
if CLIENT then
    net.Receive("lilith_spawnpointspawndisplay", function()
        local ply = LocalPlayer()
        local ent = net.ReadEntity()
        local VectorA = net.ReadVector()
        local AngleA = net.ReadAngle()

        local mdl = ClientsideModel("models/Noodles/OM/Lilith.mdl")
        if not IsValid(mdl) then return end

        mdl:SetPos(VectorA)
        mdl:SetAngles(AngleA)
        mdl:SetModelScale(1, 0)
        mdl:SetRenderMode(RENDERMODE_TRANSCOLOR)

        local spawnTime = CurTime()
        local lifeTime = 1

        local hookname = "lilith_spawnpointspawndisplay_" .. mdl:EntIndex() .. " ".. CurTime()

        mdl:EmitSound("OM/silver/Silver time reverse tick 0.wav")
        mdl:EmitSound("OM/silver/SilverSuspension.ogg")

        hook.Add("Think", hookname, function()
            if !IsValid(mdl) then
                hook.Remove("Think", hookname)
                return
            end

            local frac = math.Clamp((CurTime() - spawnTime) / lifeTime, 0, 1)

            mdl:SetColor(Color(255, 255, 255, Lerp(frac, 255, 0)))

            if frac >= 0.9 then
                mdl:Remove()
                hook.Remove("Think", hookname)
            end
        end)
    end)

    net.Receive("lilith_reverseindicate", function()
        local ply = LocalPlayer()
        local ent = net.ReadEntity()
        local VectorA = net.ReadVector()
        local AngleA = net.ReadAngle()

        local mdl = ClientsideModel("models/Noodles/OM/Lilith.mdl")
        if not IsValid(mdl) then return end

        mdl:SetPos(VectorA)
        mdl:SetAngles(AngleA)
        mdl:SetModelScale(1, 0)
        mdl:SetRenderMode(RENDERMODE_TRANSCOLOR)

        local spawnTime = CurTime()
        local lifeTime = 1

        local hookname = "lilith_spawnpointspawndisplay_" .. mdl:EntIndex() .. " ".. CurTime()

        mdl:EmitSound("OM/silver/silver_reverseRelease.wav")

        hook.Add("Think", hookname, function()
            if not IsValid(mdl) then
                hook.Remove("Think", hookname)
                return
            end

            local frac = math.Clamp((CurTime() - spawnTime) / lifeTime, 0, 1)

            mdl:SetColor(Color(255, 255, 255, Lerp(frac, 255, 0)))

            if frac >= 0.9 then
                mdl:Remove()
                hook.Remove("Think", hookname)
            end
        end)
    end)

    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_lilith", function()
        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("lilithoutine_ability_outline2", 0) > CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            1, 
            true)
        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("lilithoutine_ability_outline1", 0) > CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            1, 
            false)
        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("lilith_green_glow_red", 0) > CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            1, 
            false)
    end )

    local glitchMat = Material("effects/combine_binocoverlay")

    hook.Add("PreRenderColor_om_plain_optimized", "lilith_ui_OM_noodles", function()--
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 

                ent.lilith_green_glow_colorlerp = ent.lilith_green_glow_colorlerp or 0

                local target = (ent:GetNW2Float("lilith_green_glow", 0) > CurTime()) and 1 or 0
                local speed = (target == 1) and 3 or 0.5

                ent.lilith_green_glow_colorlerp = math.Approach(
                    ent.lilith_green_glow_colorlerp,
                    target,
                    speed * FrameTime()
                )

                return ent.lilith_green_glow_colorlerp > 0.07
            end, 
            color = function(ent)
                return Color(0, 255, 175, 255 * ent.lilith_green_glow_colorlerp)
            end,
            ignorez = true 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("lilith_green_glow_green", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("lilith_green_glow_green", 0)
                local duration, fade = 0.5*0.6, 0.25*0.6
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(0, 255, 175, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("lilith_green_glow_red", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("lilith_green_glow_red", 0)
                local duration, fade = 0.5*0.6, 0.25*0.6
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
    end)


end