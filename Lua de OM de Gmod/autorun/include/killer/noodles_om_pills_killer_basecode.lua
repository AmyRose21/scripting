
AddCSLuaFile()
--
function sharedinitializefunction_killer_om(ent)
    local PuppetEntity = ent:GetPuppet()
    local entityply = ent:GetPillUser()
    local tablevarable = {["player"] = entityply, ["entity"] = ent, ["puppet"] = PuppetEntity}
    
    hook.Add("PlayerFootstep", "DisableFootstepID_OM:".. tostring(ent:EntIndex()), function(ply)
        if entityply == ply then return true end
    end)

    if SERVER then
        if tablevarable["player"]:IsPlayer() then
            net.Start("OM_CameraCode_n")
            net.WriteEntity(tablevarable["entity"])
            net.Send(tablevarable["player"])
        end
        entityply:SetNW2Float("LowestHealth",1e9)
        entityply:SetNW2Float("OM_Damage_Reduction",1)
        entityply:SetNW2Float('LowestHealthCount_OM_pills', 1e9)


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

        hook.Add("OnPlayerHitGround", "gmx_antifalldamage_OM".. tostring(ent:EntIndex()), function(entityfall, inWater, onFloater, speed)
            if entityfall == entityply then return true end
        end)

        local lowesthealth = 1e9
        entityply:SetNW2Bool("OM_character_monster", true)

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
                    
                    entityply:SetNW2Bool("OM_character_monster", false)
                    entityply:SetNW2Bool("ShoukdntStun_OM_Noodles", false)
                    entityply:SetNW2Bool("OM_character_shouldnotgrab", false)
                    entityply:SetNW2Bool("NoHealing_OM_Noodles", false)
                    entityply:SetNW2Float('LowestHealthCount_OM_pills', 1e9)
                end
            end
        end)
    end
end

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

            if ent.formTable then
                if ent.formTable.OM_subtitles then
                    if ent.formTable.OM_subtitles[chosenSound] then
                        for i, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():Distance(ent:GetPos()) < 2000 then

                                net.Start("OM_Subtitle_n")
                                    net.WriteString(ent.formTable.OM_subtitles[chosenSound])
                                net.Send(ply)

                            end
                        end
                    end

                end
            end
        end
        return true
    end
end


-- old damage code
function Killerdamagestun(ply, target, DamageNumb, damagetype, shoulddamage, damagesound, ShouldBlood, flingremoveal)
    if SERVER then
        if damagesound then


                        AdvancedPillSound(
                            {
                                stringe = {"OM/Hurt"..math.random(1,3)..".wav"},
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            target
                        )

        end
        if ShouldBlood then
            if ply:IsPlayer() then
                net.Start("ShakeCamera_OM")
                net.Send(ply)
            end
            if target:IsPlayer() then
                net.Start("Bloodeffect_killers_OM")
                net.Send(target)
            end
        end
        local dmg = DamageInfo()
        if shoulddamage then
        else
            DamageNumb = 0.1
        end
        dmg:SetDamage(DamageNumb)
        dmg:SetAttacker(ply)
        dmg:SetInflictor(ply)
        dmg:SetDamageType(damagetype)
        dmg:SetDamagePosition(target:GetPos())

        if flingremoveal then
            dmg:SetDamageForce(vector_origin)
        end

        target:TakeDamageInfo(dmg)
    end
end
-- new damage code
function KillerdamagestunDynamic(DamageData)
    local InitialData = {}
    if DamageData.ply ~= nil then InitialData.ply = DamageData.ply else return end
    if DamageData.target ~= nil then InitialData.target = DamageData.target else return end
    if DamageData.DamageNumb ~= nil then
        InitialData.DamageNumb = DamageData.DamageNumb
    else
        InitialData.DamageNumb = 0
    end
    if DamageData.flingremoveal ~= nil then
        InitialData.flingremoveal = DamageData.flingremoveal
    else
        InitialData.flingremoveal = false
    end
    if DamageData.ShouldBlood ~= nil then
        InitialData.ShouldBlood = DamageData.ShouldBlood
    else
        InitialData.ShouldBlood = false
    end
    if DamageData.ShouldBloodEffect ~= nil then
        InitialData.ShouldBloodEffect = DamageData.ShouldBloodEffect
    else
        InitialData.ShouldBloodEffect = false
    end
    if DamageData.damagesound ~= nil then
        InitialData.damagesound = DamageData.damagesound
    else
        InitialData.damagesound = false
    end
    if DamageData.CustomDamageSound ~= nil then
        InitialData.CustomDamageSound = DamageData.CustomDamageSound
    end
    if DamageData.damagetype ~= nil then
        InitialData.damagetype = DamageData.damagetype
    else
        InitialData.damagetype = false
    end
    if SERVER then
        if InitialData.damagesound then
            if InitialData.CustomDamageSound then
                AdvancedPillSound(
                    {
                        stringe = InitialData.CustomDamageSound,
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    target
                )
            else
                AdvancedPillSound(
                    {
                        stringe = {"OM/Hurt"..math.random(1,3)..".wav"},
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    InitialData.target
                )
            end

        end
        if InitialData.ShouldBlood then
            if InitialData.ply:IsPlayer() then
                net.Start("ShakeCamera_OM")
                net.Send(InitialData.ply)
            end
            if InitialData.target:IsPlayer() then
                net.Start("Bloodeffect_killers_OM")
                net.Send(InitialData.target)
            end
            if InitialData.ply:IsPlayer() and InitialData.ply:GetPos():Distance(InitialData.target:GetPos()) < 100 then
                net.Start("Bloodeffect_killers_OM")
                net.Send(InitialData.ply)
            end
        end

        if InitialData.ShouldBloodEffect then
            local effect = EffectData()
            local center = InitialData.target:LocalToWorld(InitialData.target:OBBCenter())

            effect:SetOrigin(center)
            effect:SetScale(0.7)

            util.Effect("om_blood_splatter", effect, true, true)
        end

        local dmg = DamageInfo()
        dmg:SetDamage(InitialData.DamageNumb)
        dmg:SetAttacker(InitialData.ply)
        dmg:SetInflictor(InitialData.ply)
        dmg:SetDamageType(InitialData.damagetype)
        dmg:SetDamagePosition(InitialData.target:GetPos())

        if InitialData.flingremoveal then
            dmg:SetDamageForce(vector_origin)
        end

        InitialData.target:TakeDamageInfo(dmg)
    end
end