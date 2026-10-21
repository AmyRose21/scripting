
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
    ["eggmanshield"] = Material("icons/eggman shield.png"),
    ["eggflying"] = Material("icons/egg flying.png"),
}

pk_pills.register('pill_om_Eggman', {

    printName='Eggman',
    Outcomememories='Eggman',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/eggman.mdl",
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',

    ShouldRoll_om = function(e, ply, ent)
        return true
    end,

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["eggflying"]
            end,
            name = function(uselessvar,ply,ent)
                return "Explosive charge"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Knuckles_Punch_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float('Eggman_JetpackBoostcooldown')
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 22
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["eggmanshield"]
            end,
            name = function(uselessvar,ply,ent)
                return "Soapy sheidl"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("Eggman_shieldcooldown", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Eggman_shieldcooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 35
            end,
            survivor = true,
            font = "CreditsText",
        }
    },

    OM_transitionbar_type2table = {
        ColorDisplay = Color(255,0,0,255),
        CanShowcase = function(e,ply, ent)
            return ent:GetNW2Float("JetpackJumpCooldown") > CurTime()
        end,
        Factor = function(e,ply, ent)
            local clamp = math.Clamp(( ent:GetNW2Float("JetpackJumpCooldown") - CurTime()) / 10, 0, 1)
            return Lerp(clamp, 1, 0)
        end,
        offset = function(e,ply, ent)
            return Vector(-20,15,0)
        end
    },

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            jump2 = "jump",
        },
        ShouldMoveRotate={
            idle= function(ent) 
                return "notanything"
            end,
            run= function(ent) 
                return "notshftlock"
            end,
            walk= function(ent) 
                return "notshftlock"
            end,
            fall= function(ent) 
                return "notshftlock"
            end,
            jump= function(ent) 
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            idle= function(ent)

                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "idle_lowhealth"
                end 
            end,
            walk= function(ent) 
                
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "walk_lowhealth"
                end 
            end,
            fall= function(ent) 
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("Eggman_JetpackBoost") > CurTime() then 
                    return "Jetpack"
                end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "run_lowhealth"
                end 
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

        return basetable
    end,
       
    speedhandeler_om = {
        think = function(ply,ent)
            local Currentwalkspeed = ent.formTable.Outcomememories_stats.moveSpeed.walk(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.walk or 200
            local Currentrunspeed = ent.formTable.Outcomememories_stats.moveSpeed.run(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.run or 400
            local Currentcrouchspeed = ent.formTable.Outcomememories_stats.moveSpeed.ducked(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.ducked or 200
            local Currentjump = ent.formTable.Outcomememories_stats.moveSpeed.jumppower(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.jumppower or 400
            for i,v in pairs(ent.formTable.speedhandeler_om.modifiers) do
                local modifier = v(ply, ent)
                Currentwalkspeed = Currentwalkspeed + modifier["Walk"] 
                Currentrunspeed = Currentrunspeed + modifier["Run"]
                Currentcrouchspeed = Currentcrouchspeed + modifier["Crouch"]
                Currentjump = Currentjump + modifier["Jump"]
            end

            if ply:GetNW2Bool("Survivor_Downed_OM") then
                Currentwalkspeed = 15
                Currentrunspeed = 15
                Currentcrouchspeed = 15
                Currentjump = 1
            end

            local factor = ent:GetNW2Float("OM_SpeedBoost_Damage")
            ply:SetWalkSpeed(Currentwalkspeed + factor )
            ply:SetRunSpeed(Currentrunspeed + factor )
            ply:SetCrouchedWalkSpeed(Currentcrouchspeed + factor )
            ply:SetJumpPower(Currentjump )
        end,
        modifiers = {
            ['function0'] = function( ply, ent )
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("Eggman_JetpackBoost") > CurTime() then
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Charging() - ent.formTable.Outcomememories_stats.moveSpeed.run()
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
                    return 412
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
                    return 0.6
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return 1500
                end
            end,
            Charging = function(ply,ent)
                if SERVER then
                    return 1400
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
            StepSFX_OM(ply,ent)
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
        if SERVER then
            initializetable2["entity"]:SetNW2Int('OM_friction', 1)
            initializetable2["player"]:SetHealth(100)
            initializetable2["player"]:SetMaxHealth(100)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Int("MaxHealth",100)
            initializetable2["player"]:SetNW2Int("MaxHealth_OM",100)

            initializetable2["player"].CustomFunctionForDowned_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]

                    ent:SetNW2Float("Eggman_JetpackBoost", 0)
                    ent:SetNW2Float("Eggman_shieldduration", 0)
                end
            end
            initializetable2["player"].CustomFunctionCancelAbility_OM = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end
            initializetable2["player"].OM_Stun_Blockfunction = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end
        end
        initializetable2["player"]:SetNW2Bool("OM_character", true)
        initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
        initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)




    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetNW2Bool("ShoukdntStun_OM_Noodles", false)
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetGravity(1)
        end
    end,

    think_noodles_om_pill = function(ply, ent)
        if not SERVER then return end
        OM_PILL_speedThink(ply, ent)
        ply:SetNW2Float("DamageResistance_OM_2", 1)
        if ply:IsOnGround() then
            ent:SetNW2Bool("JetpackJump", false)
        end
        if ply:GetNW2Bool("Survivor_Downed_OM") then
            if !IsValid(ply:GetNWEntity("OM_ragdollentity")) and !IsValid(ent:GetNWEntity("OM_ragdollentity")) then
                local enemyragdoll = CreateRagdolLCharacter_OM({
                    target = ply,
                    host = ent,

                    shouldremove = function(createfakeragdoll)
                        if not IsValid(createfakeragdoll) then return true end
                        if not IsValid(ent) then return true end


                        if !ply:GetNW2Bool("Survivor_Downed_OM") then
                            return true end

                        return false
                    end,

                    shoulddocustomfunction = function(createfakeragdoll)
                        if not IsValid(createfakeragdoll) then return end
                        if not IsValid(ent) then return end
                    end
                })
            end
        end

        if not ent:GetNW2Bool("PeelOut_saidoutahere") then
            local amount = 0
            for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 700)) do
                if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                if ent2:GetClass() == "pill_puppet" then continue end
                if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                    if ent2 == ply then continue end
                    if ent2 == ent:GetNW2Entity("DrGBasePossessor") then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                    if (not ent2:GetNW2Bool("OM_character") or GetConVar("PVPStun_OM"):GetBool()) then
                        amount = amount + 1
                        ent:SetNW2Bool("PeelOut_readytosay", true)
                    end
                end
            end
            if amount == 0 and ent:GetNW2Bool("PeelOut_readytosay") then
                ent:SetNW2Bool("PeelOut_saidoutahere", true)
                AdvancedPillSound(
                    {
                        stringe = {
                            "OM/eggman/voiceline/eggmanendsachase (1).wav",
                            "OM/eggman/voiceline/eggmanendsachase (2).wav",
                            "OM/eggman/voiceline/eggmanendsachase (3).wav",
                            "OM/eggman/voiceline/eggmanendsachase (4).wav",
                            "OM/eggman/voiceline/eggmanendsachase (5).wav",
                            "OM/eggman/voiceline/eggmanendsachase (6).wav",
                            "OM/eggman/voiceline/eggmanendsachase (7).wav",
                            "OM/eggman/voiceline/eggmanendsachase (8).wav",
                            "OM/eggman/voiceline/eggmanendsachase (9).wav"
                        },
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end
        else

            for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 600)) do
                if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                if ent2:GetClass() == "pill_puppet" then continue end
                if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                    if ent2 == ply then continue end
                    if ent2 == ent:GetNW2Entity("DrGBasePossessor") then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                    if (not ent2:GetNW2Bool("OM_character") or GetConVar("PVPStun_OM"):GetBool()) then
                        ent:SetNW2Bool("PeelOut_saidoutahere", false)
                        ent:SetNW2Bool("PeelOut_readytosay", false)
                    end
                end
            end
        end
        local name = "disablefalldamage_OM".. ent:EntIndex()
        if ent:GetNW2Float("Eggman_shieldduration") > CurTime() then 
            if not ent:GetNW2Bool("Eggman_shieldbool") then
                local prop = ents.Create("ent_om_eggman_display")
                prop:SetPillUser(ply)
                prop:Spawn()
                prop:SetPillUser(ply)
                prop:SetPillEntity(ent)
                ent:DeleteOnRemove(prop)
                ent:SetNW2Entity("ShieldEntity_OM1", prop)

                prop:SetRenderMode(RENDERMODE_TRANSCOLOR)
                prop:SetColor(Color(255,255,255,0))
                prop.OM_FadeStart = CurTime()
                prop.OM_FadeDuration = 0.3

                ent:SetNW2Bool("Eggman_shieldbool", true)
                AdvancedPillSound(
                    {
                        stringe = {
                            "OM/eggman/voiceline/eggmanshieldvoice1.wav",
                            "OM/eggman/voiceline/eggmanshieldvoice2.wav",
                            "OM/eggman/voiceline/eggmanshieldvoice3.wav"
                        },
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                AdvancedPillSound(
                    {
                        stringe = "OM/eggman/shieldactivation.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                hook.Add("EntityTakeDamage", name, function(entityfall, dmg)
                    local damager = dmg:GetAttacker()
                    if not ( dmg:IsDamageType(DMG_CLUB) or dmg:IsDamageType(DMG_SLASH) or dmg:IsDamageType(DMG_CRUSH) ) then return false end
                    if IsValid(damager) then
                        if entityfall == ply then
                            dmg:SetDamage(0)
                            dmg:SetDamageType(DMG_GENERIC)

                            ent:SetNW2Float("Eggman_shieldduration", CurTime()+0.25)

                            Mutaul_OMStunCode(
                                {
                                    ["ply"] = ply,
                                    ["ent"] = ent,
                                    ["target"] = damager,
                                    ["StunDur"] = 1,
                                    ["stunfunction"] = function(shouldstundamage)
                                    end,
                                    ["shouldstack"] = false,
                                    ["Damage"] = 0,
                                    ["DamageType"] = DMG_CLUB
                                }
                            )
                            ent:SetNW2Bool("Eggman_shieldbool_popped", true)

                            local ed = EffectData()
                            ed:SetOrigin(ply:GetPos()+Vector(0,0,40))
                            util.Effect("OM_eggman_shieldburst", ed)

                            return true
                        end
                    end
                end)

                ent:CallOnRemove("RemoveHook_OM_knuckles"..ent:EntIndex(), function()
                    hook.Remove("EntityTakeDamage", name)
                end)
            end


            if IsValid(ent:GetNW2Entity("ShieldEntity_OM1")) then
            end
        else
            if IsValid(ent:GetNW2Entity("ShieldEntity_OM1")) then
                local shield1 = ent:GetNW2Entity("ShieldEntity_OM1"):GetPuppet()

                if not shield1.OM_FadeOutStart then
                    shield1.OM_FadeOutStart = CurTime()
                    shield1.OM_FadeOutDuration = 0.3
                end

                shield1:SetPos(ply:GetPos()+Vector(0,0,40))
                shield1:SetAngles(ply:GetAngles())
                ent:GetNW2Entity("ShieldEntity_OM1"):Remove()
            end

            if ent:GetNW2Bool("Eggman_shieldbool") then
                ent:SetNW2Bool("Eggman_shieldbool", false)

                ent:SetNW2Float("Eggman_shieldcooldown", CurTime()+26)
                ent:SetNW2Float("Eggman_jetpackdisabled", CurTime()+1)
                if ent:GetNW2Bool("Eggman_shieldbool_popped") then
                    AdvancedPillSound(
                        {
                            stringe = "OM/eggman/shield popping.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:SetNW2Float("Eggman_shieldcooldown", CurTime()+35)
                end
                AdvancedPillSound(
                    {
                        stringe = "OM/eggman/shield deactivated new.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                ent:GetPuppet():SetNW2Float("eggman_jshield_highlight", CurTime()+0.25)
                timer.Simple(0.2,function()
                    if !IsValid(ent) then return end
                    ent:GetPuppet():SetNW2Float("eggman_jshield_highlight", CurTime()+0.25)
                end)

                ent:SetNW2Bool("Eggman_shieldbool_popped", false)
                hook.Remove("EntityTakeDamage", name)
            end
        end

        if ent:GetNW2Float("Eggman_JetpackBoost") > CurTime() then
            if not ent:GetNW2Bool("Eggman_boostbbool") then
                ent:SetNW2Bool("Eggman_boostbbool", true)
                AdvancedPillSound(
                    {
                        stringe = "OM/eggman/jetpack boost activation layer 1.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                AdvancedPillSound(
                    {
                        stringe = "OM/eggman/jetpack boost activation layer 2.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end


            if not ent.firecdpartical then
                ent.firecdpartical = 0
            end

            if ent.firecdpartical < CurTime() then
                local effect = EffectData()
                effect:SetOrigin(ent:GetPuppet():GetPos() +Vector(0,0,2))
                effect:SetNormal(ent:GetPuppet():GetForward()*-1)
                effect:SetMagnitude(20)
                effect:SetScale(50)
                effect:SetEntity(ply)

                util.Effect("om_eggman_expell", effect)
                ent.firecdpartical = CurTime() +0.2
            end

        else
            if ent:GetNW2Bool("Eggman_boostbbool") then
                ent:SetNW2Bool("Eggman_boostbbool", false)
                ent:SetNW2Float("Eggman_JetpackBoostcooldown", CurTime()+22)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if button == KEY_SPACE then
                if not ent:GetNW2Bool("JetpackJump") then return end
                if ent:GetNW2Float("JetpackJumpCooldown") > CurTime() then return end
                if ply:IsOnGround() then return end
                local currentplyVelocity = ply:GetVelocity()
                currentplyVelocity.z = 400
                ply:SetLocalVelocity(currentplyVelocity)
                AdvancedPillSound(
                    {
                        stringe = "OM/eggman/eggman double jump.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent:SetNW2Float("JetpackJumpCooldown", CurTime()+10)
                ent:SetNW2Bool("JetpackJump", false)

                local ed = EffectData()
                ed:SetOrigin(ply:GetPos())
                util.Effect("OM_eggman_doublejump", ed)

                ent:PillAnim('jump2')

            end
            if button == KEY_T then
                if ent:GetNW2Bool("Eggman_shieldbool") then return end
                if ent:GetNW2Float("Eggman_shieldcooldown") > CurTime() then return end
                ent:SetNW2Float("Eggman_shieldduration", CurTime()+5)

            end
            if button == KEY_E then
                if ent:GetNW2Bool("Eggman_boostbbool") then return end
                if ent:GetNW2Float("Eggman_shieldduration") > CurTime() then return end
                if ent:GetNW2Float("Eggman_JetpackBoostcooldown") > CurTime() then return end
                if ent:GetNW2Float("Eggman_jetpackdisabled") > CurTime() then return end
                ent:SetNW2Float("Eggman_JetpackBoost", CurTime()+3.75)
                ent:GetPuppet():SetNW2Float("eggman_jetpackboost_highlight", CurTime()+0.25)
            end
        end
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
        ent:SetNW2Bool("JetpackJump", true)
        ent:PillAnim('jump2')

        AdvancedPillSound(
            {
                stringe = "OM/eggman/eggman jump.wav",
                pitchPercent = 100,
                volume = 1,
                soundLevel = 87
            },
            ent
        )
    end
})