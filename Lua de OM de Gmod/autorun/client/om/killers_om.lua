AddCSLuaFile()
if SERVER then
    --[[
    util.AddNetworkString("EnterChase_OM")
    util.AddNetworkString("EscapeChase_OM")

    net.Receive("EnterChase_OM", function(len, ply)
        local ent = net.ReadEntity()

        if ply.EnterChase_OM then
            ply:EnterChase_OM(ent)
        end
    end)
    
    net.Receive("EscapeChase_OM", function(len, ply)
        local ent = net.ReadEntity()

        if ply.EscapeChase_OM then
            ply:EscapeChase_OM(ent)
        end
    end)
    ]]
end

--
if CLIENT then
local ChaseSound = nil
local CurrentSoundPath = nil

-- leaving these variables out just in case bc Ik for a fact my team will need to change these eventually.
local TriggerDist, ChaseDist, StopDist, FadeSpeed = 2000, 1035, 2500, 1.5
local currentVolume, targetVolume = 0, 0

function OM_ChaseMusicHandeler()
    local ply = LocalPlayer()
    if !IsValid(ply) then return end

    if GetConVar("om_pills_chasemusic"):GetBool() == false then
        if ChaseSound then
            ChaseSound:FadeOut(0.5)
            ChaseSound = nil
            CurrentSoundPath = nil
        end
        return
    end

    -- Make sure the sound keeps looping/restarting
    if ChaseSound and !ChaseSound:IsPlaying() then
        ChaseSound:Play()
    end

    local maxVol = math.Clamp(GetConVar("om_pills_chasemusicvolume"):GetInt() / 100, 0, 1)

    if !ply:Alive() or ply:GetNW2Bool("Survivor_Downed_OM") then
        targetVolume = 0
        currentVolume = Lerp(FrameTime() * FadeSpeed, currentVolume, targetVolume)

        if ChaseSound then
            ChaseSound:ChangeVolume(currentVolume * maxVol, 0)

            if currentVolume <= 0.01 then
                ChaseSound:FadeOut(0.5)
                ChaseSound = nil
                CurrentSoundPath = nil
            end
        end

        return
    end

    if ply:GetNW2Bool("OM_character_monster") or (IsValid(ply:GetNW2Entity("DrGBasePossessing")) and ply:GetNW2Entity("DrGBasePossessing"):GetNW2Bool("OM_character_monster")) then

        local nearestDist = math.huge
        local currentenemy = nil

        for _, ent in ipairs(ents.GetAll()) do
            if ent == ply then continue end

            if !ent:GetNW2Bool("OM_character_monster") and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and ent:Health() > 0.1 then
                local dist = ply:GetPos():DistToSqr(ent:GetPos())

                if dist < nearestDist then
                    nearestDist = dist
                    currentenemy = ent
                end
            end
        end

        if !IsValid(currentenemy) then
            targetVolume = 0
        else
            local dist = math.sqrt(nearestDist)

            if dist <= ChaseDist then
                targetVolume = 1
            else
                targetVolume = 0
            end
        end

        currentVolume = Lerp(FrameTime() * FadeSpeed, currentVolume, targetVolume)

        if currentVolume > 0.01 and IsValid(currentenemy) then
            local dist = math.sqrt(nearestDist)

            local tr = util.TraceLine({
                start = ply:EyePos(),
                endpos = currentenemy:WorldSpaceCenter(),
                mask = MASK_SOLID,
                filter = function(ent)
                    if ent == ply or ent == currentenemy then return false end
                    if ent:IsPlayer() then return false end
                    if ent:IsNPC() then return false end
                    if ent:IsNextBot() then return false end
                end
            })

            if dist <= ChaseDist and !tr.Hit then
                local soundPath = ply:GetNW2String("chasemusic_life1_om")

                if IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
                    soundPath = ply:GetNW2Entity("DrGBasePossessing"):GetNW2String("chasemusic_life1_om")

                    if currentenemy:GetNW2Bool("OnSecondLife_OM") then
                        soundPath = ply:GetNW2Entity("DrGBasePossessing"):GetNW2String("chasemusic_life2_om")
                    end
                else
                    if currentenemy:GetNW2Bool("OnSecondLife_OM") then
                        soundPath = ply:GetNW2String("chasemusic_life2_om")
                    end
                end

                if soundPath ~= "" and soundPath ~= CurrentSoundPath then
                    if ChaseSound then
                        ChaseSound:FadeOut(0.4)
                        ChaseSound = nil
                    end

                    ChaseSound = CreateSound(ply, soundPath)
                    ChaseSound:Play()

                    CurrentSoundPath = soundPath
                end
            else
                targetVolume = 0
            end

            if ChaseSound then
                ChaseSound:ChangeVolume(currentVolume * maxVol, 0)

                -- Keep loop alive
                if !ChaseSound:IsPlaying() then
                    ChaseSound:Play()
                end
            end
        else
            if ChaseSound then
                ChaseSound:FadeOut(0.6)
                ChaseSound = nil
                CurrentSoundPath = nil
            end
        end

        return
    end

    local nearestDist = math.huge
    local currentenemy = nil

    for _, ent in ipairs(ents.GetAll()) do
        if ent:GetNW2Bool("OM_character_monster") then
            local dist = ply:GetPos():DistToSqr(ent:GetPos())

            if dist < nearestDist then
                nearestDist = dist
                currentenemy = ent
            end
        end
    end

    if !IsValid(currentenemy) then
        targetVolume = 0
    else
        local dist = math.sqrt(nearestDist)

        if dist <= TriggerDist then
            targetVolume = 1
        elseif dist >= StopDist then
            targetVolume = 0
        end
    end

    currentVolume = Lerp(FrameTime() * FadeSpeed, currentVolume, targetVolume)

    if currentVolume > 0.01 and IsValid(currentenemy) then
        local soundPath = nil
        local dist = math.sqrt(nearestDist)

        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = currentenemy:WorldSpaceCenter(),
            mask = MASK_SOLID,
            filter = function(ent)
                if ent == ply or ent == currentenemy then return false end
                if ent:IsPlayer() then return false end
                if ent:IsNPC() then return false end
                if ent:IsNextBot() then return false end
            end
        })

        if dist <= ChaseDist and !tr.Hit then
            if ply:GetNW2Bool("OnSecondLife_OM") then
                soundPath = currentenemy:GetNW2String("chasemusic_life2_om")
            else
                soundPath = currentenemy:GetNW2String("chasemusic_life1_om")
            end
        else
            soundPath = currentenemy:GetNW2String("TerrorRadius_om")
        end

        if soundPath ~= CurrentSoundPath then
            if ChaseSound then
                ChaseSound:FadeOut(0.5)
                ChaseSound = nil
            end

            if soundPath ~= "" then
                ChaseSound = CreateSound(ply, soundPath)
                ChaseSound:Play()

                CurrentSoundPath = soundPath
            end
        end

        if ChaseSound then
            ChaseSound:ChangeVolume(currentVolume * maxVol, 0)

            -- Keep loop alive
            if !ChaseSound:IsPlaying() then
                ChaseSound:Play()
            end
        end
    else
        if ChaseSound then
            ChaseSound:FadeOut(1)
            ChaseSound = nil
            CurrentSoundPath = nil
        end
    end
end



    hook.Add("PreRenderColor_om_plain", "killeerstunned_ui_OM_noodles", function()
        for _, ent in ipairs(ents.GetAll()) do
            if not IsValid(ent) then continue end
            if ent:GetNoDraw() then continue end
            
            local expire = ent:GetNW2Float("DisablePlayerMovement_OM_stun", 0) + 0.15
            if expire >= CurTime() then
                
                local duration, fade = 0.3, 0.15
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end
                om_color.Add_plaincolor({ ent = ent, color = Color(255, 255, 255, 255 * alpha), ignorez = false })
            end
        end
    end)

    local mat = Material("icons/OM_highlight.png", "noclamp smooth")

    hook.Add("PostDrawOpaqueRenderables", "OM_HighlightEntity", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local pillentity = ply.pk_pill_ent
        local isdrgbase = false
        if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end

        if not IsValid(pillentity) then return end
        if not pillentity.formTable or not pillentity.formTable.Outcomememories then return end
        if not (pillentity:GetNW2Bool("OM_character_monster") or ply:GetNW2Bool("OM_character_monster")) then return end

        local view = render.GetViewSetup()
        local eyePos = view.origin

        pillentity.ScanForEntities_OM_amount = pillentity.ScanForEntities_OM_amount or 0

        if pillentity:GetNW2Int("ScanForEntities_OM") > CurTime() then
            pillentity.ScanForEntities_OM_amount = Lerp(FrameTime()*4, pillentity.ScanForEntities_OM_amount, 1)
        else
            pillentity.ScanForEntities_OM_amount = Lerp(FrameTime()*4, pillentity.ScanForEntities_OM_amount, 0)
        end
        if pillentity.ScanForEntities_OM_amount > 0.1 then
            for _, ent2 in ipairs(ents.GetAll()) do
                if not IsValid(ent2) then continue end
                if not (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) then continue end

                if ent2 == ply then continue end
                if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                local hp = (ent2.Health and ent2:Health()) or 0
                if hp <= 0 then continue end

                local pos = ent2:WorldSpaceCenter()

                local Size = math.min(math.max(95 * eyePos:Distance(ent2:GetPos()) / 400, 95), 4000) * pillentity.ScanForEntities_OM_amount

                render.SetMaterial(mat)

                cam.IgnoreZ(true)
                render.SetBlend(15)
                render.DrawSprite(pos, Size, Size, Color(255,255,255,200))
                render.SetBlend(1)
                cam.IgnoreZ(false)
            end
        end
    end)
end

