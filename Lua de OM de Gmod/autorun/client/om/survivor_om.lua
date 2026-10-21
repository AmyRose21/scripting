AddCSLuaFile()
if SERVER then
    util.AddNetworkString("Bloodeffect_OM")
    util.AddNetworkString("Bloodeffect_killers_OM")
end

--
if CLIENT then

    local BloodEffects = {}
    local BloodMat = Material("effects/blood_core")

    net.Receive("Bloodeffect_killers_OM", function()
        local maxSize = math.random(128, 384) * 2

        BloodEffects[#BloodEffects + 1] = {
            start = RealTime(),
            lifetime = math.Rand(5, 8),

            x = math.random(-maxSize * 0.5, ScrW() - maxSize * 0.5),
            y = math.random(-maxSize * 0.5, ScrH() - maxSize * 0.5),

            size = maxSize,
            rot = math.random(0, 360),

            fall = math.random(10, 35),
            drift = math.Rand(-15, 15),
            roll = math.Rand(-5, 5)
        }
    end)

    function blooddraw_drawhud_om()
        local rt = RealTime()

        surface.SetMaterial(BloodMat)

        for i = #BloodEffects, 1, -1 do
            local v = BloodEffects[i]

            local elapsed = rt - v.start

            if elapsed >= v.lifetime then
                BloodEffects[i] = BloodEffects[#BloodEffects]
                BloodEffects[#BloodEffects] = nil
                continue
            end

            local fadeIn = v.lifetime * 0.02
            local fadeOut = v.lifetime * 0.25

            local alpha = 255
            local size = v.size

            if elapsed < fadeIn then
                local t = elapsed / fadeIn
                alpha = t * 255
                size = v.size * t
            elseif elapsed > v.lifetime - fadeOut then
                local t = (elapsed - (v.lifetime - fadeOut)) / fadeOut
                alpha = (1 - t) * 255
                size = v.size * (1 - t)
            end

            surface.SetDrawColor(75, 0, 0, alpha * 0.9)

            surface.DrawTexturedRectRotated(
                v.x + v.size * 0.5 + math.sin(elapsed * 1.5) * v.drift,
                v.y + v.size * 0.5 + elapsed * v.fall,
                size,
                size,
                v.rot + elapsed * v.roll
            )
        end
    end

    hook.Add( "PreDrawOutlines_om_optimized", "IframesRedOutline_OM", function()
        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("DisablePlayerMovement_OM_stun_iframe1") > CurTime() and ent:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime()
            end, 
            function(ent) 
                if ent:GetNW2Float("survivor_iframes") > CurTime() then
                    return Color(255, 255, 255, 255)
                else
                    return Color(255, 0, 0, 255)
                end
                
            end, 
            1, 
            false)     
    end )




    local bloodoverlay = {
        [1] = Material("icons/blood_layer_1.png"),
        [2] = Material("icons/blood_layer_2.png"),
        [3] = Material("icons/blood_layer_3.png")
    }

    net.Receive("Bloodeffect_OM", function()
        local ply = LocalPlayer()
        if ply:GetNW2Bool("OM_character_monster") then return end
        if !IsValid(ply) then return end

        local hp = ply:Health()
        local chosenoverlay = bloodoverlay[1]
        if hp < 30 then
            chosenoverlay = bloodoverlay[3]
        elseif hp < 60 then
            chosenoverlay = bloodoverlay[2]
        end


        local sfx = CreateSound(ply, "OM/Hurt"..math.random(1,3)..".wav")
        sfx:Play()
        sfx:ChangeVolume(1, 1)

        local lifetime = math.Rand(2, 5)
        local startTime = RealTime()
        local id = "Bloodeffect_OM_" .. startTime

        hook.Add("HUDPaint", id, function()
            local elapsed = RealTime() - startTime
            if elapsed > lifetime then
                hook.Remove("HUDPaint", id)
                return
            end

            local fadeInTime = lifetime * 0.1
            local fadeOutTime = lifetime * 0.25
            local alpha = 255

            if elapsed < fadeInTime then
                alpha = (elapsed / fadeInTime) * 255
            elseif elapsed > lifetime - fadeOutTime then
                alpha = ((lifetime - elapsed) / fadeOutTime) * 255
            end

            surface.SetDrawColor(255, 255, 255, alpha)
            surface.SetMaterial(chosenoverlay)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        end)
    end)


    timer.Simple(1 ,function()

        local nextTick = 0
        local loop1 = nil
        local loop2 = nil

        hook.Add("Think", "HeartBeat_OM_survivor", function()
            ProximityTickSound_OM_Metal()
            OM_ChaseMusicHandeler()
            
            if CurTime() < nextTick then return end
            nextTick = CurTime() + 0.2

            local ply = LocalPlayer()
            if !IsValid(ply) then return end
            local pillentity = LocalPlayer().pk_pill_ent
            local isdrgbase = false

            if !IsValid(pillentity) then
                if IsValid(ply:GetNW2Entity("DrGBasePossessing"), NULL) then
                    pillentity = ply:GetNW2Entity("DrGBasePossessing")
                    isdrgbase = true
                else
                    if loop1 and loop1:IsPlaying() then loop1:Stop() end
                    if loop2 and loop2:IsPlaying() then loop2:Stop() end
                    return
                end
            end

            if ply:GetNW2Bool("OM_character_monster") then 
                if loop1 and loop1:IsPlaying() then loop1:Stop() end
                if loop2 and loop2:IsPlaying() then loop2:Stop() end
                return
            end

            if IsValid(pillentity) then
                if pillentity.formTable and pillentity.formTable.Outcomememories_material == "Organic" and IsValid(pillentity:GetPuppet()) then

                    local hp = ply:Health()
                    if isdrgbase then
                        hp = pillentity:Health()
                    end

                    if hp < 30 then
                        if loop1 and loop1:IsPlaying() then loop1:Stop() end

                        if not loop2 then
                            loop2 = CreateSound(ply, "OM/heartbeatfast.wav")
                        end

                        if not loop2:IsPlaying() then
                            loop2:Play()
                            loop2:ChangeVolume(1, 1)
                        end

                    elseif hp < 60 then
                        if loop2 and loop2:IsPlaying() then loop2:Stop() end

                        if not loop1 then
                            loop1 = CreateSound(ply, "OM/heartbeat.wav")
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
        end)
    end)


end