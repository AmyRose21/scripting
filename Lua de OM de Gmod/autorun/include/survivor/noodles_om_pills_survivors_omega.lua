
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


local preservedmats = {
    ["shadow_icon_Aim"] = Material("icons/shadow_icon_Aim.png"),
    ["shadow_icon_dash_boost"] = Material("icons/shadow_icon_dash_boost.png"),
    ["shadow_icon_reload"] = Material("icons/shadow_icon_reload.png"),
    ["shadow_icon_chaos_snap"] = Material("icons/shadow_icon_chaos_snap.png")
}

pk_pills.register('pill_om_Omega', {

    printName='Omega',
    Outcomememories='Omega',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/Omega.mdl",
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',


    ShouldRoll_om = function(e, ply, ent)
        return true
    end,

    OM_UI_icons = {
        --[[
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["shadow_icon_Aim"]
            end,
            name = function(uselessvar,ply,ent)
                return "Hook (not functional)"
            end,
            keybind = function(uselessvar,ply,ent)
                return "E"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Omega_Hook_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 27
            end,
            survivor = true,
            font = "CreditsText",
        },
        ]]
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["shadow_icon_Aim"]
            end,
            name = function(uselessvar,ply,ent)
                return "Bullet Rain"
            end,
            keybind = function(uselessvar,ply,ent)
                return "E"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Omega_BulletRain_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 27
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["shadow_icon_Aim"]
            end,
            name = function(uselessvar,ply,ent)
                return "Beatdown"
            end,
            keybind = function(uselessvar,ply,ent)
                return "R"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Omega_Beatdown_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 26
            end,
            survivor = true,
            font = "CreditsText",
        },
    },

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            jump2 = "jump",
            BeatDown = "BeatDown",
            ChargeStart="ChargeStart",
        },
        ShouldMoveRotate={
            ChargeStart= function(ent)
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return "shiftlock" end
                return "notanything"
            end,
            idle= function(ent)
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return "shiftlock" end
                return "notanything"
            end,
            run= function(ent)
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return "shiftlock" end
                return "notshftlock"
            end,
            walk= function(ent)
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return "shiftlock" end
                return "notshftlock"
            end,
            fall= function(ent) 
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return "shiftlock" end
                return "notshftlock"
            end,
            jump= function(ent) 
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return "shiftlock" end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            idle= function(ent)
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() or ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return "IdleShooting" end
                if ent:GetNW2Float("Omega_shootduration_Jetpack") > CurTime() then return "JetPackShoot" end
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return "FallJetPack" end
                if ent:GetNW2Float("Omega_chargeup_Beatdown_notonground") < CurTime() then if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return "ChargeIdle" end end
                if ent:GetNW2Float("Omega_dash_Beatdown") > CurTime() or ent:GetNW2Float("Omega_dash_animation") > CurTime() then return "ChargeDash" end
            end,
            walk= function(ent) 
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() or ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return "WalkingShooting" end
                if ent:GetNW2Float("Omega_shootduration_Jetpack") > CurTime() then return "JetPackShoot" end
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return "FallJetPack" end
                if ent:GetNW2Float("Omega_chargeup_Beatdown_notonground") < CurTime() then if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return "ChargeIdle" end end
                if ent:GetNW2Float("Omega_dash_Beatdown") > CurTime() or ent:GetNW2Float("Omega_dash_animation") > CurTime() then return "ChargeDash" end
            end,
            fall= function(ent) 
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() or ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return "FallShooting" end
                if ent:GetNW2Float("Omega_shootduration_Jetpack") > CurTime() then return "JetPackShoot" end
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return "FallJetPack" end
                if ent:GetNW2Float("Omega_chargeup_Beatdown_notonground") < CurTime() then if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return "ChargeIdle" end end
                if ent:GetNW2Float("Omega_dash_Beatdown") > CurTime() or ent:GetNW2Float("Omega_dash_animation") > CurTime() then return "ChargeDash" end
            end,
            run= function(ent) 
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() or ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return "WalkingShooting" end
                if ent:GetNW2Float("Omega_shootduration_Jetpack") > CurTime() then return "JetPackShoot" end
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return "FallJetPack" end
                if ent:GetNW2Float("Omega_chargeup_Beatdown_notonground") < CurTime() then if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return "ChargeIdle" end end
                if ent:GetNW2Float("Omega_dash_Beatdown") > CurTime() or ent:GetNW2Float("Omega_dash_animation") > CurTime() then return "ChargeDash" end
                --jetpackshoot
            end,
        },
    },
    
    OM_cameratable = function(ply,ent)
        local basetable =  {
            startoffset = Vector(20,0,25),  -- left-up, front-back, up-down
            dist=145,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 0,
            transition = 1,
            canscroll = true,
            bonecenter = "Torso",
        }

        ent.Omega_chargeup_BulletRain_lerp = ent.Omega_chargeup_BulletRain_lerp or 0

        if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() then
            ent.Omega_chargeup_BulletRain_lerp = Lerp(FrameTime()*4, ent.Omega_chargeup_BulletRain_lerp, 1)
        else
            ent.Omega_chargeup_BulletRain_lerp = Lerp(FrameTime()*4, ent.Omega_chargeup_BulletRain_lerp, 0)
        end

        ent.Omega_duration_BulletRain_lerp = ent.Omega_duration_BulletRain_lerp or 0

        if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then
            ent.Omega_duration_BulletRain_lerp = Lerp(FrameTime()*4, ent.Omega_duration_BulletRain_lerp, 1)
        else
            ent.Omega_duration_BulletRain_lerp = Lerp(FrameTime()*4, ent.Omega_duration_BulletRain_lerp, 0)
        end

        basetable["fov"] = basetable["fov"] - ent.Omega_chargeup_BulletRain_lerp * 20
        basetable["startoffset"] = basetable["startoffset"] + Vector(ent.Omega_chargeup_BulletRain_lerp * 40 + ent.Omega_duration_BulletRain_lerp * 40,0,0)
        basetable["dist"] = basetable["dist"] - ent.Omega_chargeup_BulletRain_lerp * 90 - ent.Omega_duration_BulletRain_lerp * 90

        return basetable
    end,
       
    speedhandeler_om = {
        modifiers = {
            ['function0'] = function( ply, ent )
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() or ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * 1.8 - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * 1.8 - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * 1.8 - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
        }
    }, 

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return 60
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return 390
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return 60
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return 400
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return 2
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return 1500
                end
            end,
        },
    },

    camera={
        offset = Vector(0, 0, 50),
        dist=130,
    },
        
    jumpPower=400,
        
    
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },
        
    canAim=function(ply,ent) return ent.active end,     

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if event == "Step" then
            if ent:GetPuppet():GetSequenceName(ent:GetPuppet():GetSequence()) == "walk" then
                AdvancedPillSound({
                    stringe = {"OM/metal/Step1.wav","OM/metal/Step2.wav","OM/metal/Step3.wav","OM/metal/Step4.wav","OM/metal/Step5.wav","OM/metal/Step6.wav"},
                    soundLevel = 90
                }, ent)
            elseif ent:GetPuppet():GetSequenceName(ent:GetPuppet():GetSequence()) == "run" then
                AdvancedPillSound({
                    stringe = {"OM/metal/RunStep1.wav","OM/metal/RunStep2.wav","OM/metal/RunStep3.wav","OM/metal/RunStep4.wav","OM/metal/RunStep5.wav","OM/metal/RunStep6.wav","OM/metal/RunStep7.wav","OM/metal/RunStep8.wav"},
                    soundLevel = 90
                }, ent)
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
        if SERVER then
            initializetable2["entity"]:SetNW2Int('OM_friction', 1)
            initializetable2["player"]:SetHealth(225)
            initializetable2["player"]:SetMaxHealth(225)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Int("MaxHealth",225)
            initializetable2["player"]:SetNW2Int("MaxHealth_OM",225)
        end
        initializetable2["player"]:SetNW2Bool("MetalBeing_OM", true)
        initializetable2["player"]:SetNW2Bool("OM_character", true)
        initializetable2["player"]:SetNW2Bool("SecondLife_OM", false)
        initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", true)


        initializetable2["player"].OM_DamageBeforeBeforeCustomFunction = function(table1, table2)
            local entityfall = table2[1]
            local dmg = table2[2]
            local damageamount = table2[3]
            if IsValid(initializetable2["entity"]) then
                local ent = initializetable2["entity"]
                local shouldplay = false
                ent:SetNW2Bool("Omega_Beatdown_bool", false)
                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then
                    ent:SetNW2Float("Omega_MoveUp_Jetpack", 0)
                    shouldplay = true
                end
                if ent:GetNW2Float("Omega_shootduration_Jetpack") > CurTime() then
                    ent:SetNW2Float("Omega_shootduration_Jetpack", 0)
                    shouldplay = true
                end
                if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then
                    ent:SetNW2Float("Omega_duration_BulletRain", 0)
                    shouldplay = true
                end
                if shouldplay then
                    AdvancedPillSound(
                        {
                            stringe = "OM/tails/CannonCancel_1.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    AdvancedPillSound(
                        {
                            stringe = "OM/tails/CannonCancel_2.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            end
        end


        local function exploding(victim)
            if IsValid(initializetable2["entity"]) then else return end
            if SERVER then
                local ply = initializetable2["player"]
                local ent = initializetable2["entity"]

                if IsValid(ply) and ply:IsPlayer() then
                    if not ent.PlayedSound_selfdestruct then
                        ent.PlayedSound_selfdestruct = true
                        net.Start("MetalSonic_deathsound")
                        net.Send(ply)
                    end
                end

                local pos = victim:GetPos()

                local explosion = ents.Create("env_explosion")
                if IsValid(explosion) then
                    explosion:SetPos(pos)
                    explosion:SetOwner(victim)
                    explosion:Spawn()
                    explosion:SetKeyValue("iMagnitude", "0")
                    explosion:Fire("Explode", 0, 0)
                end

                AdvancedPillSound(
                    {
                        stringe = "OM/metal/ExplodeSfx.wav",
                        pitchPercent = 100,
                        volume = 2,
                        soundLevel = 87
                    },
                    initializetable2["entity"]
                )      

                AdvancedPillSound(
                    {
                        stringe = "OM/metal/Explosion.wav",
                        pitchPercent = 100,
                        volume = 2,
                        soundLevel = 87
                    },
                    initializetable2["entity"]
                )      
                AdvancedPillSound(
                    {
                        stringe = "OM/metal/MetalBloodSound.wav",
                        pitchPercent = 100,
                        volume = 2,
                        soundLevel = 87
                    },
                    initializetable2["entity"]
                )      


                for _, ent2 in pairs(ents.FindInSphere(pos, 230)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == initializetable2["player"] then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        
                        if Mutual_OMCanStun(initializetable2["player"], initializetable2["entity"], ent2, false) then
                            if ( ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() ) then continue end
                            Mutaul_OMStunCode(
                                {
                                    ["ply"] = initializetable2["player"],
                                    ["ent"] = initializetable2["entity"],
                                    ["target"] = ent2,
                                    ["StunDur"] = 7,
                                    ["CallForClashing"] = true,
                                    ["stunfunction"] = function(shouldstundamage)
                                        if shouldstundamage then


                                                    local last = CurTime() + 1.25
                                                    local flung = false
                                                    local enemyragdoll = CreateRagdolLCharacter_OM({
                                                        target = ent2,
                                                        host = initializetable2["entity"],

                                                        shouldremove = function(createfakeragdoll)
                                                            if not IsValid(createfakeragdoll) then return true end
                                                            if not IsValid(ent2) then return true end

                                                            local pos = createfakeragdoll:GetPos()
                                                                        
                                                            local tr = util.TraceLine({
                                                                start = pos,
                                                                endpos = pos - Vector(0, 0, 10),
                                                                filter = createfakeragdoll
                                                            })

                                                            if (last < CurTime() and tr.Hit ) or ent2:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime() then
                                                                return true
                                                            else
                                                                if not tr.Hit then
                                                                    last = CurTime() + 1.25
                                                                end
                                                            end
                                                            return false
                                                        end,

                                                        shoulddocustomfunction = function(createfakeragdoll)
                                                            if not IsValid(createfakeragdoll) then return end
                                                            if not IsValid(ent2) then return end
                                                            if flung then return end
                                                            flung = true

                                                            local ragPos = createfakeragdoll:GetPos()

                                                            local dir = (ragPos - pos):GetNormalized()
                                                            local force = dir * 800 + Vector(0, 0, 50)

                                                            local phys = createfakeragdoll:GetPhysicsObject()
                                                            if IsValid(phys) then
                                                                phys:SetVelocity(force)
                                                                phys:AddAngleVelocity(VectorRand() * 1600)
                                                            end

                                                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                                local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                                if IsValid(bonePhys) then
                                                                    bonePhys:SetVelocity(force)
                                                                    bonePhys:AddAngleVelocity(VectorRand() * 1600)
                                                                end
                                                            end
                                                        end
                                                    })

                                        end
                                    end,
                                    ["shouldstack"] = true,
                                    ["Damage"] = 0,
                                    ["checkoutprevention"] = true,
                                    ["DamageType"] = DMG_CLUB
                                }
                            )
                        end
                    end
                end

            end
        end

        local hookname = "OM_Metals_explode".. initializetable2["player"]:EntIndex()
        if initializetable2["player"]:IsPlayer() then
            hook.Add("PlayerDeath", hookname, function(victim, inflictor, attacker)
                if IsValid(victim) and victim == initializetable2["player"] then
                    exploding(victim)
                end
            end)
        else
            hook.Add("OnNPCKilled", hookname, function(npc, attacker, inflictor)
                if IsValid(npc) and npc == initializetable2["player"] then
                    exploding(npc)
                end
            end)
        end


    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetNW2Bool("ShoukdntStun_OM_Noodles", false)
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetGravity(1)
            initializetable2["player"]:SetNW2Bool("MetalBeing_OM", false)
        end
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", 1)
            ply:SetNW2Float("OM_Damage_Reduction",0.5)

            if not ent.Tripwire_glide_lerp then
                ent.Tripwire_glide_lerp = 0
            end

            local shouldheal = false
            for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 1200)) do
                if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                if ent2:GetClass() == "pill_puppet" then continue end
                if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                    if ent2 == ply then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                    if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then
                    else
                        shouldheal = true
                        break
                    end
                end
            end

            if shouldheal then
                if not ent.OM_omega_healingcd or ent.OM_omega_healingcd < CurTime() then
                    ent.OM_omega_healingcd = CurTime() + 0.5
                    if 175 >= ply:Health()+1 then
                        ply:SetHealth(ply:Health()+1)
                    end
                end 
            end


            if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                if not ent.Omega_MoveUp_Jetpack_setcd then
                    ent.Omega_MoveUp_Jetpack_setcd = true
                end
                if not ent.shadow_dashvelocity_omega then ent.shadow_dashvelocity_omega = 0 end

                if ent:GetNW2Float("Omega_MoveUp_Jetpack_shift") > CurTime() then
                    ent.shadow_dashvelocity_omega = 500
                else
                    ent.shadow_dashvelocity_omega = Lerp(FrameTime()*2, ent.shadow_dashvelocity_omega, 0)
                end


                local speed = ply:GetRunSpeed() * 0.5

                local vel = ply:GetVelocity()
                local velo = ent:GetPuppet():GetUp()* 70

                if ent.shadow_dashvelocity_omega > 70 then
                    velo = ent:GetPuppet():GetUp()* ent.shadow_dashvelocity_omega*0.8
                end

                local forward = ply:GetForward()
                local side = ply:GetRight()*0

                if ply:KeyDown(IN_MOVELEFT) then
                    side = ply:GetRight()*-speed
                elseif ply:KeyDown(IN_MOVERIGHT) then
                    side = ply:GetRight()*speed
                end

                if ply:KeyDown(IN_MOVERIGHT) and ply:KeyDown(IN_MOVELEFT) then
                    side = ply:GetRight()*0
                end

                if ply:KeyDown(IN_BACK) then
                    forward = ply:GetForward()*-speed
                elseif ply:KeyDown(IN_FORWARD) then
                    forward = ply:GetForward()*speed
                end

                if ply:KeyDown(IN_FORWARD) and ply:KeyDown(IN_BACK) then
                    forward = ply:GetRight()*0
                end

                if ent.shadow_dashvelocity_omega > 100 then
                    forward = forward* ent.shadow_dashvelocity_omega/150
                    side = side* ent.shadow_dashvelocity_omega/150
                end


                ent.Tripwire_glide_lerp = Lerp(FrameTime() * 0.85, ent.Tripwire_glide_lerp, 1)

                local lerping = Lerp(ent.Tripwire_glide_lerp, vel, (velo + forward + side))
                ply:SetLocalVelocity(lerping)
            else
                if ent.Omega_MoveUp_Jetpack_setcd then
                    ent.Omega_MoveUp_Jetpack_setcd = false
                    ent:SetNW2Float("Omega_BulletRain_cd", CurTime() + 27)
                end
            end


            if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() then
                ply:SetNW2Float("OM_NoMovement_noodles", 0.2 + CurTime())
                if not ent.Omega_chargeup_BulletRain_bool then
                    ent.Omega_chargeup_BulletRain_bool = true

                    AdvancedPillSound(
                        {
                            stringe = "OM/shadow/GunStart.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    AdvancedPillSound(
                        {
                            stringe = "OM/Fleetway/PreLaugh.wav",
                            pitchPercent = 75,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            else
                if ent.Omega_chargeup_BulletRain_bool then
                    ent.Omega_chargeup_BulletRain_bool = false
                    AdvancedPillSound(
                        {
                            stringe = "OM/Fleetway/AfterLaugh.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    AdvancedPillSound(
                        {
                            stringe = "OM/Fleetway/snd_bombsplosion.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:SetNW2Float("Omega_duration_BulletRain", CurTime() + 4)
                end
            end

            local function FireGunBone(ply, puppet, boneName)
                if not IsValid(ply) or not IsValid(puppet) then return end

                local bone = puppet:LookupBone(boneName)
                if not bone then return end

                local pos, ang = puppet:GetBonePosition(bone)
                if not pos then return end
                
                AdvancedPillSound(
                    {
                        stringe = {
                            "OM/shadow/GunShot1.wav",
                            "OM/shadow/GunShot2.wav"
                        },
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                ang = ang or ply:EyeAngles()

                pos = pos + ang:Forward() * 8

                local fx = EffectData()
                fx:SetOrigin(pos)
                fx:SetAngles(ang)
                fx:SetEntity(puppet)
                fx:SetScale(1.5)
                util.Effect("MuzzleFlash", fx, true, true)

                util.Effect("ShellEject", fx)

                ply:FireBullets({
                    Num = 13,
                    Src = pos,
                    Dir = ply:GetAimVector(),
                    Spread = Vector(0.1, 0.1, 0),
                    Tracer = 1,
                    TracerName = math.random(1,3) == 1 and "AR2Tracer" or "Tracer",
                    Damage = 0.2,
                    Force = 5,
                    Distance = 4096,

                    Callback = function(attacker, tr, dmginfo)

                        if !tr.Hit then return end
                        local impact = EffectData()
                        impact:SetOrigin(tr.HitPos)
                        impact:SetNormal(tr.HitNormal)
                        util.Effect("cball_bounce", impact)

                        local hitpos = tr.HitPos
                        local HitEntity = tr.Entity

                        util.ScreenShake(hitpos, 10, 5, 0.3, 80)

                        if IsValid(HitEntity) then
                            if IsValid(HitEntity:GetNW2Entity("DrGBasePossessing")) then return end
                            if HitEntity:GetClass() == "pill_puppet" then return end
                            if (HitEntity:IsPlayer() or HitEntity:IsNextBot() or HitEntity:IsNPC()) and HitEntity:Health() >= 0.1 then
                                if HitEntity == ply then return end
                                if HitEntity:IsPlayer() and HitEntity:Team() == TEAM_SPECTATOR then return end

                                if Mutual_OMCanStun(ply, ent, HitEntity, true) then
                                    HitEntity:SetNWFloat("ShadowBulletHitCount", HitEntity:GetNWFloat("ShadowBulletHitCount")+0.17)

                                    ent:SetNW2Float("Shadow_showcharacter_".. tostring(HitEntity), CurTime()+ 1.25)


                                    if HitEntity:GetNWFloat("ShadowBulletHitCount") >= 6 then

                                        Mutaul_OMStunCode(
                                            {
                                                ["ply"] = ply,
                                                ["ent"] = ent,
                                                ["target"] = HitEntity,
                                                ["StunDur"] = 3,
                                                ["stunfunction"] = function(shouldstundamage)
                                                    if shouldstundamage then
                                                    end
                                                end,
                                                ["shouldstack"] = true,
                                                ["Damage"] = 0,
                                                ["DamageType"] = DMG_GENERIC
                                            }
                                        )
                                    end
                                    if HitEntity:GetNWFloat("ShadowBulletHitCount") > 6 then
                                        HitEntity:SetNWFloat("ShadowBulletHitCount", 0.17)
                                    end
                                else
                                    dmginfo:SetDamage(0)
                                end
                            end
                        end

                    end
                })
                if ply:IsPlayer() then
                    ply:ViewPunch(Angle(-1, 0.3, 0))
                end
            end

            if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() or ent:GetNW2Float("Omega_shootduration_Jetpack") > CurTime() then
                if not ent.Omega_duration_BulletRain_cd or ent.Omega_duration_BulletRain_cd < CurTime() then
                    ent.Omega_duration_BulletRain_cd = CurTime() + 0.15
                    if ent:GetNW2Float("Omega_shootduration_Jetpack") > CurTime() then
                        ent.Omega_duration_BulletRain_cd = CurTime() + 0.2
                    end

                    local puppet = ent:GetPuppet()

                    if IsValid(puppet) then
                        ply:LagCompensation(true)

                        FireGunBone(ply, puppet, "LeftGun")
                        FireGunBone(ply, puppet, "RightGun")

                        ply:LagCompensation(false)
                    end
                end
                if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then
                    if not ent.Omega_duration_BulletRain_setcd then
                        ent.Omega_duration_BulletRain_setcd = true
                    end
                end
            else
                if ent.Omega_duration_BulletRain_setcd then
                    ent.Omega_duration_BulletRain_setcd = false
                    ent:SetNW2Float("Omega_BulletRain_cd", CurTime() + 27)
                end
            end

            if ent:GetNW2Bool("Omega_Beatdown_bool") then
                if not ent.Omega_Beatdown_bool then
                    ent:SetNW2Float("Omega_chargeup_Beatdown_notonground", CurTime() + 0.1)
                    ent:SetNW2Float("Omega_chargeup_Beatdown", CurTime() + 1.5)
                    ent:PillAnim("ChargeStart")
                end
                ent.Omega_Beatdown_bool = true
            

                if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then
                    ply:SetNW2Float("OM_NoMovement_noodles", 0.2 + CurTime())
                    if not ent.Omega_chargeup_Beatdown_bool then
                        ent.Omega_chargeup_Beatdown_bool = true
                    end
                else
                    if ent.Omega_chargeup_Beatdown_bool then
                        ent.Omega_chargeup_Beatdown_bool = false
                        ent:SetNW2Float("Omega_dash_Beatdown", CurTime() + 0.15)
                        ent.Omega_chargeup_Beatdown_direction = ent:GetPuppet():GetForward()
                        ent:SetNW2Bool("Omega_Beatdown_bool", false)
                    end
                end
            else
                ent.Omega_Beatdown_bool = false
            end

            if not ent.shadow_dashvelocity then ent.shadow_dashvelocity = 0 end

            if ent:GetNW2Float("Omega_dash_Beatdown") > CurTime() then
                ent.shadow_dashvelocity = 3500
            else
                ent.shadow_dashvelocity = Lerp(FrameTime()*5, ent.shadow_dashvelocity, 0)
            end

            if ent.shadow_dashvelocity > 600 then
                if not ent.Omega_duration_Beatdown_setcd then
                    ent.Omega_duration_Beatdown_setcd = true
                end

                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)

                if ply:IsOnGround() then
                    ply:SetPos(ply:GetPos()+Vector(0,0,5))
                end
                ent:SetNW2Float("Omega_dash_animation", CurTime()+0.1)
                ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.1)
                if ply:IsPlayer() then
                    ply:SetNW2Vector("OM_SetVelocity_Vector",ent.Omega_chargeup_Beatdown_direction * ent.shadow_dashvelocity)
                end

                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 80)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if Mutual_OMCanStun(ply, ent, ent2, false) then
                            local seq = ent:GetPuppet():LookupSequence("BeatDown")
                            Mutaul_OMStunCode(
                                {
                                    ["ply"] = ply,
                                    ["ent"] = ent,
                                    ["target"] = ent2,
                                    ["CallForClashing"] = true,
                                    ["StunDur"] = ent:GetPuppet():SequenceDuration(seq) + 3,
                                    ["stunfunction"] = function(shouldstundamage)
                                        if shouldstundamage then

                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/metal/Eletricsound.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )

                                            ent.shadow_dashvelocity = 0
                                            ent:SetNW2Float("Omega_dash_animation", 0)
                                            ply:SetNW2Float("OM_SetVelocity_pos", 0)
                                            ent:SetNW2Float("Omega_dash_Beatdown", 0)

                                            ply:SetLocalVelocity(Vector(0,0,0))

                                            ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                                            ent:SetNW2Float("OM_beatdownanim", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                                            ent:PillAnim("BeatDown")

                                            ent.Omega_duration_Beatdown_setcd = false
                                            ent:SetNW2Float("Omega_Beatdown_cd", CurTime() + 26)

                                            local last = CurTime() + 2
                                            local flung = false

                                            local enemyragdoll = CreateRagdolLCharacter_OM({
                                                target = ent2,
                                                host = ent,

                                                shouldremove = function(createfakeragdoll)
                                                    if not IsValid(createfakeragdoll) then return true end
                                                    if not IsValid(ent2) then return true end
                                                    if not IsValid(ent) then return true end

                                                    if last <= CurTime() then return true end

                                                    return false
                                                end,

                                                shoulddocustomfunction = function(createfakeragdoll)
                                                    if not IsValid(createfakeragdoll) then return end

                                                    local puppet = ent:GetPuppet()
                                                    if not IsValid(puppet) then return end

                                                    local headPhys
                                                    for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                        local phys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                        if IsValid(phys) then
                                                            local boneIndex = createfakeragdoll:TranslatePhysBoneToBone(i)
                                                            local boneName = createfakeragdoll:GetBoneName(boneIndex) or ""

                                                            if string.find(string.lower(boneName), "head", 1, true) then
                                                                headPhys = phys
                                                                break
                                                            end
                                                        end
                                                    end

                                                    if not IsValid(headPhys) then headPhys = createfakeragdoll:GetPhysicsObject() end
                                                    if not IsValid(headPhys) then return end

                                                    if ent:GetNW2Float("OM_beatdownanim") > CurTime() then
                                                        last = CurTime() + 1
                                                        headPhys:SetPos(ent:GetPuppet():GetPos()+ent:GetPuppet():GetForward()*60+ent:GetPuppet():GetUp()*60)
                                                        --headPhys:SetAngles( ( (ent:GetPuppet():GetPos()+ent:GetPuppet():GetForward()*80) - ent:GetPuppet():GetPos() ):GetNormalized():Angle()  )
                                                        headPhys:SetVelocityInstantaneous(vector_origin)
                                                        headPhys:Wake()
                                                    end
                                                end
                                            })

                                        end
                                    end,
                                    ["shouldstack"] = true,
                                    ["Damage"] = 0,
                                    ["checkoutprevention"] = true,
                                    ["DamageType"] = DMG_CLUB
                                }
                            )
                        end

                    end
                end
            else
                if ent.Omega_duration_Beatdown_setcd then
                    ent.Omega_duration_Beatdown_setcd = false
                    ent:SetNW2Float("Omega_Beatdown_cd", CurTime() + 26)
                end
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if button == KEY_E then --  Bullet Rain
                if ent:GetNW2Float("Omega_BulletRain_cd") > CurTime() then return end

                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return end
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() then return end
                if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return end
                if ent:GetNW2Float("Omega_shootduration_Jetpack") > CurTime() then return end
                if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return end
                if ent:GetNW2Float("Omega_dash_Beatdown") > CurTime() then return end
                if ent:GetNW2Bool("Omega_Beatdown_bool") then return end
                if ent.shadow_dashvelocity and ent.shadow_dashvelocity > 600 then return end
                if ent.Omega_duration_BulletRain_setcd then return end

                if ply:IsOnGround() then
                    ent:SetNW2Float("Omega_chargeup_BulletRain", CurTime() + 0.6)
                else
                    ent:SetNW2Float("Omega_MoveUp_Jetpack", CurTime() + 4)
                    ent:SetNW2Float("Omega_MoveUp_Jetpack_shift", CurTime() + 0.3)
                    ent:SetNW2Float("Omega_shootduration_Jetpack", CurTime() + 2)
                end
            end
            if button == KEY_R then --  Beatdown
                if ent:GetNW2Float("Omega_Beatdown_cd") > CurTime() then return end

                if ent:GetNW2Float("Omega_MoveUp_Jetpack") > CurTime() then return end
                if ent:GetNW2Float("Omega_chargeup_BulletRain") > CurTime() then return end
                if ent:GetNW2Float("Omega_duration_BulletRain") > CurTime() then return end
                if ent:GetNW2Float("Omega_shootduration_Jetpack") > CurTime() then return end
                if ent:GetNW2Float("Omega_chargeup_Beatdown") > CurTime() then return end
                if ent:GetNW2Float("Omega_dash_Beatdown") > CurTime() then return end
                if ent:GetNW2Bool("Omega_Beatdown_bool") then return end
                if ent.shadow_dashvelocity and ent.shadow_dashvelocity > 600 then return end
                if ent.Omega_duration_BulletRain_setcd then return end

                ent:SetNW2Bool("Omega_Beatdown_bool", true)

            end
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply,ent,button)
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)

        end
    },


    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
        end,
    },

    reload=function(ply,ent)
    end,
    flashlight = function(ply, ent)
    end,
        
    jump = function(ply, ent)
        if SERVER then 
            ent:PillAnim('jump2')
        end

        AdvancedPillSound(
            {
                stringe = "OM/metal/metaljump.wav",
                pitchPercent = 100,
                volume = 1,
                soundLevel = 87
            },
            ent
        )
    end
})