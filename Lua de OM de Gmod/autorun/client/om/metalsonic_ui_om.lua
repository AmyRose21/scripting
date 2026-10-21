AddCSLuaFile()
if SERVER then
    util.AddNetworkString("MetalSonic_deathsound")
end


if CLIENT then

    net.Receive("MetalSonic_deathsound", function()
        local ent = net.ReadEntity()
        local ply = LocalPlayer()
        surface.PlaySound("OM/metal/deactivate.wav")
    end)


    hook.Add("PreRenderColor_om_render_optimized", "MetalSonic_ui_OM_noodles_env", function()
        if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then
        else
            om_color.Add_renderoptimized({ 
                Canfuction = function(ent) 
                    return ent:GetNW2Float("MetalSonicinvert_highlight", 0) > CurTime()
                end, 
                ignorez = false,
                rendereffects = function(ent)

                    local expire = ent:GetNW2Float("MetalSonicinvert_highlight", 0)
                    local duration = 0.2
                    local fade = 0.1

                    local startTime = expire - duration
                    local endTime = expire

                    local alpha = 1
                    if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                    elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                    else alpha = 1 end

                    DrawColorModify({
                        ["$pp_colour_addr"]       = 0,
                        ["$pp_colour_addg"]       = 0,
                        ["$pp_colour_addb"]       = 0,
                        ["$pp_colour_brightness"] = 0,
                        ["$pp_colour_contrast"]   = 1 + (10 * alpha),
                        ["$pp_colour_colour"]     = 1 + (-6 * alpha),
                        ["$pp_colour_mulr"]       = 0,
                        ["$pp_colour_mulg"]       = 0,
                        ["$pp_colour_mulb"]       = 0
                    })
                end
            })
        end
    end)


    hook.Add("PreRenderColor_om_plain_optimized", "MetalSonic_ui_OM_noodles", function()
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("metalsonic_ability_red_long", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("metalsonic_ability_red_long", 0)
                local duration, fade = 0.7, 0.1
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
                return ent:GetNW2Float("MetalSonic_cancel", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("MetalSonic_cancel", 0)
                local duration, fade = 0.5*0.5, 0.25*0.5
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
                return ent:GetNW2Float("MetalSonicHeal_highlight", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("MetalSonicHeal_highlight", 0)
                local duration, fade = 0.5*0.5, 0.25*0.5
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
                return ent:GetNW2Float("MetalSonicbump_highlight", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("MetalSonicbump_highlight", 0)
                local duration, fade = 0.65*0.5, 0.25*0.5
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(0, 0, 0, 255 * alpha)
            end,
            ignorez = false 
        })
    end)


    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_metalsonic", function()
        local ply = LocalPlayer()

        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("metalsonic_ability_outline", 0) >= CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            1, 
            false
        )            
    end )

    local nextTick = 0
    local loop1 = nil
    local loop2 = nil

    function ProximityTickSound_OM_Metal()
        local ply = LocalPlayer()
        local pillentity = LocalPlayer().pk_pill_ent
        local isdrgbase = false

        if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end

        if IsValid(pillentity) then
            if pillentity.formTable and pillentity.formTable.Outcomememories == "MetalSonic" and IsValid(pillentity:GetPuppet()) then
                if not pillentity:GetNWBool("ShouldntShowAbility0_OM") then
                    if loop1 and loop1:IsPlaying() then loop1:Stop() end
                    if loop2 and loop2:IsPlaying() then loop2:Stop() end
                    return end
                if pillentity:GetNWBool("SelfDestruct_metal_om") then
                    if loop1 and loop1:IsPlaying() then loop1:Stop() end
                    if loop2 and loop2:IsPlaying() then loop2:Stop() end
                    return end
                local entPos = ply:GetPos()
                local nearest = nil
                local nearestDist = math.huge

                for _, v in ipairs(ents.GetAll()) do
                    if not IsValid(v) or v == ply then continue end
                    if v:GetClass() == "pill_puppet" then continue end
                    if v == pillentity then continue end
                    if not (v:IsPlayer() or v:IsNPC() or v:IsNextBot()) then continue end
                    if v:GetNW2Bool("OM_character") then continue end

                    local dist = entPos:DistToSqr(v:GetPos())
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = v
                    end
                end

                if IsValid(nearest) then

                    local dist = ply:GetPos():Distance(nearest:GetPos()) - 300
                    local minInterval = 0.2
                    local maxInterval = 1
                    local maxDist = 3000

                    if dist <= maxDist then 
                        local interval = Lerp(math.Clamp(math.Clamp(dist, 0, maxDist) / maxDist, 0, 1), minInterval, maxInterval)
                        if CurTime() >= nextTick then
                            surface.PlaySound("OM/metal/Ping1.wav")
                            nextTick = CurTime() + interval*3
                        end
                    end
                end

                local hp = ply:Health()
                if hp < 30 then
                    if loop1 and loop1:IsPlaying() then loop1:Stop() end

                    if not loop2 then
                        loop2 = CreateSound(ply, "OM/metal/metallowerhealthalarm.wav")
                    end

                    if not loop2:IsPlaying() then
                        loop2:Play()
                        loop2:ChangeVolume(1, 1)
                    end

                elseif hp < 60 then
                    if loop2 and loop2:IsPlaying() then loop2:Stop() end

                    if not loop1 then
                        loop1 = CreateSound(ply, "OM/metal/Metallowhealthalarm.wav")
                    end

                    if not loop1:IsPlaying() then
                        loop1:Play()
                        loop1:ChangeVolume(1, 1)
                    end
                else
                    if loop1 and loop1:IsPlaying() then loop1:Stop() end
                    if loop2 and loop2:IsPlaying() then loop2:Stop() end
                end
            else
                if loop1 and loop1:IsPlaying() then loop1:Stop() end
                if loop2 and loop2:IsPlaying() then loop2:Stop() end
            end
        else
            if loop1 and loop1:IsPlaying() then loop1:Stop() end
            if loop2 and loop2:IsPlaying() then loop2:Stop() end
        end
    end
end