--NoHealing_OM_Noodles
AddCSLuaFile()


local function AdvancedPillSound(SoundData, ent)
    if SERVER then
        if IsValid(ent) then
            SoundData = SoundData or {}
            SoundData.stringe = SoundData.stringe or {}
            SoundData.soundLevel = SoundData.soundLevel or 75
            SoundData.pitchPercent = SoundData.pitchPercent or 100
            SoundData.volume = SoundData.volume or 1
            SoundData.channel = SoundData.channel or CHAN_AUTO
            SoundData.soundFlags = SoundData.soundFlags or 0
            SoundData.dsp = SoundData.dsp or 0
            SoundData.filter = SoundData.filter or nil

            local chosenSound = SoundData.stringe

            if istable(SoundData.stringe) then
                local index = math.random(1, #SoundData.stringe)
                chosenSound = SoundData.stringe[index]
            end

            ent:EmitSound(
                chosenSound,
                SoundData.soundLevel,
                SoundData.pitchPercent,
                SoundData.volume,
                SoundData.channel,
                SoundData.soundFlags,
                SoundData.dsp,
                SoundData.filter
            )
        end
        return true
    end
end

function sharedinitializefunction_survivor_om(ent)
    local PuppetEntity = ent:GetPuppet()
    local entityply = ent:GetPillUser()
    local tablevarable = {["player"] = entityply, ["entity"] = ent, ["puppet"] = PuppetEntity}
    
    hook.Add("PlayerFootstep", "DisableFootstepID_OM:".. tostring(ent:EntIndex()), function(ply)
        if entityply == ply then return true end
    end)

    if SERVER then
        entityply.ReviveFunction_OM = function()
            if IsValid(ent) then
                if entityply.CustomReviveFunction_OM then
                    entityply:CustomReviveFunction_OM()
                end
                entityply:SetHealth(60)
                entityply:SetNW2Bool("Survivor_Downed_OM", false)
                entityply:SetNW2Bool("OnSecondLife_OM", true)

                if bit.band(entityply:GetFlags(), FL_NOTARGET) ~= 0 then
                    entityply:RemoveFlags(FL_NOTARGET)
                end
                
                local damage = 200
                if ent:GetNW2Float("OM_SpeedBoost_Damage") > 0 then
                    ent:SetNW2Float( "OM_SpeedBoost_Damage", ent:GetNW2Float("OM_SpeedBoost_Damage") + damage)
                else
                    ent:SetNW2Float( "OM_SpeedBoost_Damage", damage)
                end
                timer.Simple(5,function()
                    if !IsValid(ent) then return end
                    ent:SetNW2Float( "OM_SpeedBoost_Damage", ent:GetNW2Float("OM_SpeedBoost_Damage") - damage)
                end)
                entityply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe1", CurTime()+5)
                entityply:SetNW2Float("survivor_iframes", CurTime()+5)
                AdvancedPillSound(
                    {
                        stringe = "OM/revive_om.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end
        end

        local hookName = "ThinkHookForEntity_OM_" .. ent:EntIndex()
        hook.Add("Think", hookName, function()
            if not IsValid(ent) then
                hook.Remove("Think", hookName)
                return
            end

            local ply = ent:GetPillUser()
            local puppet = ent:GetPuppet()

            if not IsValid(puppet) or not IsValid(ply) then
                hook.Remove("Think", hookName)
                return
            end

            if SERVER then
                if GetConVar("om_pills_action_2canrevive"):GetBool() then
                    ply:SetNW2Bool("CanSelfRevive_OM", true)
                else
                    ply:SetNW2Bool("CanSelfRevive_OM", false)
                end
                if ply:GetNW2Bool("OM_character") and ply:GetNW2Bool("Survivor_Downed_OM") then
                    if ply:GetNW2Float("Survivor_DownedTime_OM", CurTime()) < CurTime() then
                        ply:Kill()
                    end
                end
            end
        end)

        if tablevarable["player"]:IsPlayer() then
            net.Start("OM_CameraCode_n")
            net.WriteEntity(tablevarable["entity"])
            net.Send(tablevarable["player"])
        end

        if entityply:IsPlayer() then
            hook.Add("PlayerDeath", "playerdeath_om"..ent:EntIndex(), function(ply)
                if ply == entityply then 
                    ply:EmitSound("om/death"..math.random(1,4)..".wav", 75, 100)
                end
            end)
        else
            hook.Add("OnNPCKilled", "playerdeath_om"..ent:EntIndex(), function(ply, attacker, inflictor)
                if not IsValid(ply) then return end

                if ply == entityply then 
                    ply:EmitSound("om/death"..math.random(1,4)..".wav", 75, 100)
                end
            end)
        end
        entityply:SetNW2Float("LowestHealth",1e9)
        entityply:SetNW2Float("OM_Damage_Reduction",1)
        entityply:SetNW2Float('LowestHealthCount_OM_pills', 1e9)

        hook.Add("OnPlayerHitGround", "gmx_antifalldamage_OM".. tostring(ent:EntIndex()), function(entityfall, inWater, onFloater, speed)
            if entityfall == entityply then return true end
        end)

        local lowesthealth = 1e9

        ent:CallOnRemove("RemoveHook_OM"..ent:EntIndex(), function()
            hook.Remove("PlayerFootstep", "DisableFootstepID_OM:".. tostring(ent:EntIndex()))
            hook.Remove("OnPlayerHitGround", "gmx_antifalldamage_OM".. tostring(ent:EntIndex()))
            hook.Remove("PlayerDeath", "playerdeath_om".. ent:EntIndex())
            hook.Remove("OnNPCKilled", "playerdeath_om".. ent:EntIndex())

            ent.formTable:noodles_OM_survivor_OnRemove(tablevarable,tablevarable,tablevarable)

            if SERVER then
                if IsValid(entityply) then
                    entityply:SetNW2Float("OM_lowerFriction", 0)
                    entityply:SetNW2Float("OM_lowerFriction_not", 0)
                    
                    entityply:SetNW2Bool("OM_character", false)
                    entityply:SetNW2Bool("OM_character_shouldnotgrab", false)
                    entityply:SetNW2Bool("NoHealing_OM_Noodles", false)
                    entityply:SetNW2Float('LowestHealthCount_OM_pills', 1e9)
                    if bit.band(entityply:GetFlags(), FL_NOTARGET) ~= 0 then
                        entityply:RemoveFlags(FL_NOTARGET)
                    end
                    entityply:SetNW2Bool("Survivor_Downed_OM", false)
                    entityply:SetNW2Bool("SecondLife_OM", false)
                    entityply:SetNW2Bool("OnSecondLife_OM", false)
                end
            end
        end)
    end
end