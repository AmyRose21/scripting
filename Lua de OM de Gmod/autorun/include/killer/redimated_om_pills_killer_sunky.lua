
AddCSLuaFile()

local function damagestun(ply, target, DamageNumb, damagetype, shoulddamage, damagesound, ShouldBlood)
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
                    net.Start("Bloodeffect_killers_OM")
                    net.Send(ply)
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

        target:TakeDamageInfo(dmg)
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
        end
        return true
    end
end



local preservedmats = {
    ["milkncereal_sunki"] = Material("icons/milkncereal_sunki.png"),
    ["skedaddle_sunki"] = Material("icons/skedaddle_sunki.png"),
}

pk_pills.register('pill_om_sunky', {

    printName='Sunky.MPEG',
    Outcomememories='Sunky',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/sunki.mdl",
    --[[
    hull = Vector(20,20,60),
    duckBy = 14,
    ]]

    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',
    
    ShouldRoll_om = function(e, ply, ent)
        return true
    end,

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            jump2 = "jump",
            CerialIntro = "CerialIntro",
            CerialEnd = "CerialEnd",
            SkedaddleIntro = "Skedaddle Intro ND",
            SkedaddleEnd = "Skedaddle End",
        },
            
        ShouldMoveRotate={
            ["Skedaddle Intro ND"]= function(ent)
                return 'shiftlock' 
            end,
            idle= function(ent)
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then return "shiftlock" end
                return 'notshftlock' 
            end,
            walk= function(ent)
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then return "shiftlock" end
                return 'notshftlock' 
            end,
            run= function(ent)
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then return "shiftlock" end
                return 'notshftlock' 
            end,
            jump= function(ent)
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then return "shiftlock" end
                return 'notshftlock'
            end,
            fall= function(ent)
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then return "shiftlock" end
                return "notshftlock"
            end,
        },

        ShouldAlternate={
            fall = function(ent)
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then 
                    return "Stunned"
                end
                if ent:GetNW2Bool("HoldingDown_milkandcereal") then 
                    return "CerialLoop"
                end
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then
                    if IsValid(ent:GetNW2Entity("Skedaddle_entity")) then return "Skedaddle Hold" end
                    return "SkedaddleLoop"
                end
                
            end,
            idle= function(ent)
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then 
                    return "Stunned"
                end
                if ent:GetNW2Bool("HoldingDown_milkandcereal") then 
                    return "CerialLoop"
                end
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then
                    if IsValid(ent:GetNW2Entity("Skedaddle_entity")) then return "Skedaddle Hold" end
                    return "SkedaddleLoop"
                end
                
            end,
            walk= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then 
                    return "Stunned"
                end
                if ent:GetNW2Bool("HoldingDown_milkandcereal") then 
                    return "CerialLoop"
                end
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then
                    if IsValid(ent:GetNW2Entity("Skedaddle_entity")) then return "Skedaddle Hold" end
                    return "SkedaddleLoop"
                end
                
            end,
            run= function(ent)
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then 
                    return "Stunned"
                end
                if ent:GetNW2Bool("HoldingDown_milkandcereal") then 
                    return "CerialLoop"
                end
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then
                    if IsValid(ent:GetNW2Entity("Skedaddle_entity")) then return "Skedaddle Hold" end
                    return "SkedaddleLoop"
                end
                
            end,
        },
        
        animrates = {
        }
    },

    OM_cameratable = function(ply,ent)
        local basetable =  {
            startoffset = Vector(0,0,50),  -- left-up, front-back, up-down
            dist=175,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 0,
            transition = 1,
            canscroll = true,
        }

        return basetable
    end,


    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["milkncereal_sunki"]
            end,
            name = function(uselessvar,ply,ent)
                return "Milk and Cereal"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_E
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("MilkandCereal_om_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            survivor = false,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility3_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["skedaddle_sunki"]
            end,
            name = function(uselessvar,ply,ent)
                return "Skedaddle"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_T
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Skedaddle_om_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 33
            end,
            survivor = false,
            font = "CreditsText",
        },
    },

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return 70
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return 545
                end
            end,
            Charge = function(ply,ent)
                if SERVER then
                    return 2000
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return 70
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return 460
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
    --ent.formTable.Outcomememories_stats.abilities.Attack.Damage
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },

    --canAim=function(ply,ent) return ent.active end,     

    speedhandeler_om = {
        modifiers = {
            ['invisible'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.Charge() - ent.formTable.Outcomememories_stats.moveSpeed.walk() 
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Charge() - ent.formTable.Outcomememories_stats.moveSpeed.run() 
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.Charge() - ent.formTable.Outcomememories_stats.moveSpeed.ducked() 
                    
                end

                return sendtotable
            end,
        }
    },

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if SERVER then
            if event == "Step" then
                if ent.sunkistep then
                    ent.sunkistep = false
                    AdvancedPillSound(
                        {
                            stringe = "OM/sunky/Step2.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                else
                    ent.sunkistep = true
                    AdvancedPillSound(
                        {
                            stringe = "OM/sunky/Step1.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            end
            if event == "Attack" then
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end

                if SERVER then
                    local nearest
                    local nearestDist = math.huge

                    local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                    for _, ent2 in pairs(ents.FindInSphere(attackPos, 180)) do
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                            if not GetConVar("PVPStun_OM_exe"):GetBool() then
                                if ent2:GetNW2Bool("OM_character_monster") then continue end
                            end

                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                            if not Mutal_OMCanDamage(ply, ent, ent2) then continue end

                            local dist = attackPos:DistToSqr(ent2:GetPos())

                            if dist < nearestDist then
                                nearestDist = dist
                                nearest = ent2
                            end
                        end
                    end

                    if IsValid(nearest) then
                        nearest:SetNW2Float("sunky_afterimage_OM_noodles_indicator_hit", CurTime()+ 4)
                        local typeofdamage = 35
                        
                        KillerdamagestunDynamic({
                            ply = ply,
                            target = nearest,
                            DamageNumb = typeofdamage,
                            damagetype = DMG_CLUB,
                            CustomDamageSound = nil,
                            damagesound = true,
                            ShouldBlood = true,
                            flingremoveal = true,
                            ShouldBloodEffect = true
                        })
                    end
                end
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_killer_om(initializetable2["entity"])


        initializetable2["player"].ColorRGB_B_1_OM = Color(215,215,0, 255)
        if SERVER then

            local health = 250
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            --initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)

            initializetable2["entity"]:SetNW2Float('OM_friction', 1)

            initializetable2["player"]:SetNW2String("TerrorRadius_om","OM/music/SunkiChaseMusic_terror.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life1_om","OM/music/SunkiChaseMusic_1.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life2_om","OM/music/SunkiChaseMusic_2.wav")

            initializetable2["player"]:SetNW2String("CharacterStunned_om", "")
--,


            initializetable2["player"].OM_AttacterCustomFunction = function(table1, table2)

                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]
                    if entityfall == ent:GetNW2Entity("Skedaddle_entity") and ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then
                        if entityfall:Health() - damageamount <= 0.5 then
                            if ent:GetNW2Float("Skedaddle_identify") >= CurTime() then
                            else
                                ent:SetNW2Float("Skedaddle_charge_duration", 0)
                            end
                            
                            dmg:SetDamage(0)
                        end
                    end
                end
            end

            initializetable2["player"].OM_StunFunction = function()
                local ent = initializetable2["entity"]
                local ply = initializetable2["player"]
                if !IsValid(ent) then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end
                AdvancedPillSound(
                    {
                        stringe = {
                            "OM/sunky/SunkiStunned1.wav",
                            "OM/sunky/SunkiStunned2.wav",
                            "OM/sunky/SunkiStunned3.wav"
                        },
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end
        end
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            if bit.band(initializetable2["player"]:GetFlags(), FL_NOTARGET) ~= 0 then
                initializetable2["player"]:RemoveFlags(FL_NOTARGET)
            end
        end
        initializetable2["entity"]:StopSound("OM/sunky/ability 3 loop.wav")
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            ply:SetNW2Float("DamageResistance_OM_2", 1)

            OM_PILL_speedThink(ply, ent)
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") > CurTime() or ent:GetNW2Float("OM_executionanim") > CurTime() then
                ply:SetNW2Float("OM_Damage_Reduction",0)
            else
                ply:SetNW2Float("OM_Damage_Reduction",1)
            end

            if ent:GetNW2Float("Skedaddle_chargeup_duration") >= CurTime() then
                ent:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                if not ent.Skedaddle_chargeup_duration_bool then
                    ent.Skedaddle_chargeup_duration_bool = true

                    AdvancedPillSound(
                        {
                            stringe = "OM/sunky/ability 3 intro.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.1)
            else
                if ent.Skedaddle_chargeup_duration_bool then
                    ent.Skedaddle_chargeup_duration_bool = false
                    ent:SetNW2Float("Skedaddle_charge_duration", CurTime() + 6)
                end
            end

            if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then
                ent:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                if not ent.Skedaddle_charge_duration_bool then
                    ent.Skedaddle_charge_duration_bool = true
                    AdvancedPillSound(
                        {
                            stringe = "OM/sunky/ability 3 loop.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent.Skedaddle_charge_duration_hitwall = false
                    ent:SetNW2Entity("Skedaddle_entity", NULL)
                end

                if !IsValid(ent:GetNW2Entity("Skedaddle_entity")) then
                    ply:SetNW2Float("OM_MoveForwardSpeed", 10000)
                    ply:SetNW2Float("OM_MoveForward", CurTime() + 0.1)

                    local nearest
                    local nearestDist = math.huge

                    local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                    for _, ent2 in pairs(ents.FindInSphere(attackPos, 180)) do
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                            if not GetConVar("PVPStun_OM_exe"):GetBool() then
                                if ent2:GetNW2Bool("OM_character_monster") then continue end
                            end

                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                            if not Mutal_OMCanDamage_grab(ply, ent, ent2) then continue end

                            local dist = attackPos:DistToSqr(ent2:GetPos())

                            if dist < nearestDist then
                                nearestDist = dist
                                nearest = ent2
                            end
                        end
                    end

                    if IsValid(nearest) then

                        ent:SetNW2Float("Skedaddle_charge_duration", CurTime() + 8)
                        ent:SetNW2Entity("Skedaddle_entity", nearest)

                        ent:SetNW2Float("Skedaddle_identify", CurTime()+0.01)
                        KillerdamagestunDynamic({
                            ply = ply,
                            target = nearest,
                            DamageNumb = 15,
                            damagetype = DMG_CLUB,
                            CustomDamageSound = nil,
                            damagesound = true,
                            ShouldBlood = true,
                            flingremoveal = true,
                            ShouldBloodEffect = true
                        })

                        AdvancedPillSound(
                            {
                                stringe = "OM/kolossos/Kol impacts.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        AdvancedPillSound(
                            {
                                stringe = "OM/kolossos/Kol charge laugh impale.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 67
                            },
                            ent
                        )
                        
                        if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then
                        else
                            local Flung1 = false
                            local Flung = false
                            local enemyragdoll = CreateRagdolLCharacter_OM({
                                target = nearest,
                                host = ent,

                                shouldremove = function(createfakeragdoll)
                                    if not IsValid(createfakeragdoll) then return true end
                                    if not IsValid(nearest) then return true end
                                    if not IsValid(ent) then return true end

                                    if ent:GetNW2Float("IdentifiedAsCrash_kolossos_wall") > CurTime() then return false end
                                    if ent.Skedaddle_charge_duration_bool then return false end

                                    if ent:GetNW2Float("Skedaddle_charge_duration") < CurTime() then -- and Flung
                                        return true
                                    end

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
                                    if not IsValid(headPhys) then
                                        headPhys = createfakeragdoll:GetPhysicsObject()
                                    end
                                    if not IsValid(headPhys) then return end

                                    local bone = puppet:LookupBone("RightHand")
                                    if not bone then return end
                                    local pos, ang = puppet:GetBonePosition(bone)

                                    if not Flung1 then
                                        headPhys:SetPos(pos)
                                        headPhys:SetAngles(ang)
                                        headPhys:SetVelocityInstantaneous(vector_origin)
                                        headPhys:Wake()
                                    end

                                    if ent:GetNW2Float("Skedaddle_charge_duration") < CurTime() and not Flung1 then
                                        Flung1 = true

                                    if ent:GetNW2Float("IdentifiedAsCrash_kolossos_wall") > CurTime() then
                                        local dirs = {
                                            puppet:GetRight(),
                                            -puppet:GetRight(),
                                            puppet:GetForward()
                                        }

                                        local chosenDir = table.Random(dirs)

                                        for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                            local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                            if IsValid(phys) then
                                                phys:ApplyForceCenter(
                                                    chosenDir * 500
                                                )
                                            end
                                        end
                                    else
                                        for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                            local phys = createfakeragdoll:GetPhysicsObjectNum(i)
                                            if IsValid(phys) then
                                                phys:ApplyForceCenter(puppet:GetForward() * 500 + Vector(0,0,2000))
                                            end
                                        end
                                    end



                                        --createfakeragdoll:SetCollisionGroup(COLLISION_GROUP_NONE)
                                        timer.Simple(2,function()
                                            if !IsValid(ent) then return end
                                            Flung = true
                                        end)
                                    end
                                end,
                            })
                        end
                    end

                else
                    if ent:GetNW2Float("Skedaddle_identify") < CurTime() then
                        local startPos = ply:GetPos()+Vector(0,0,25)
                        local endpos = startPos+ent:GetPuppet():GetForward() * 65

                        local tr = util.TraceHull({
                            start = startPos,
                            endpos = endpos,
                            mask = MASK_SOLID,
                            mins = Vector(-10, -10, 0),
                            maxs = Vector(10, 10, 10),
                            filter = function(hitEnt)
                                if hitEnt == ent then return false end
                                if hitEnt == ent:GetPuppet() then return false end
                                if hitEnt:IsPlayer() then return false end
                                if hitEnt:IsNPC() then return false end
                                if hitEnt:IsNextBot() then return false end
                                if hitEnt.OMRagdoll then return false end
                                return true
                            end
                        })

                        if ent.Skedaddle_charge_duration_hitwall then
                            ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.1)
                            if ply:IsOnGround() then
                                ent.Skedaddle_charge_duration_hitwall = false
                            end
                            ply:SetNW2Float("OM_MoveForward", 0)
                        else
                            ply:SetNW2Float("OM_MoveForwardSpeed", 10000)
                            ply:SetNW2Float("OM_MoveForward", CurTime() + 0.1)
                            ply:SetNW2Float("OM_NoMovement_noodles", 0)
                        end

                        if tr.Hit and ent:GetNW2Float("Skedaddle_charge_bonk") < CurTime() then

                            local hitNormal = tr.HitNormal

                            if math.abs(hitNormal.z) < 0.25 then
                                if ply:IsOnGround() then
                                    ply:SetPos(ply:GetPos()+Vector(0,0,20))
                                end
                                ply:SetLocalVelocity(hitNormal *800 + Vector(0,0,100) + ply:GetVelocity()*0.35)
                                --ply:SetVelocity(hitNormal * 800 + Vector(0,0,600))
                                ent.Skedaddle_charge_duration_hitwall = true

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/sunky/bonk.wav",
                                        pitchPercent = 100,
                                        volume = 2,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/sunky/squish.wav",
                                        pitchPercent = 100,
                                        volume = 2,
                                        soundLevel = 87
                                    },
                                    ent
                                )

                                ent:SetNW2Float("Skedaddle_charge_bonk", CurTime()+0.2)


                                KillerdamagestunDynamic({
                                    ply = ply,
                                    target = ent:GetNW2Entity("Skedaddle_entity"),
                                    DamageNumb = 3,
                                    damagetype = DMG_CLUB,
                                    CustomDamageSound = nil,
                                    damagesound = true,
                                    ShouldBlood = true,
                                    flingremoveal = true,
                                    ShouldBloodEffect = true
                                })

                                ent:SetNW2Float("Skedaddle_charge_duration",  ent:GetNW2Float("Skedaddle_charge_duration")-0.3)
                            end
                        end
                    end
                end

            else
                if ent.Skedaddle_charge_duration_bool then
                    ent.Skedaddle_charge_duration_bool = false

                    AdvancedPillSound(
                        {
                            stringe = "OM/sunky/ability 3 outro.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent:PillAnim("SkedaddleEnd")
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.75)
                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 2)
                    ent:SetNW2Float("IdentifiedAsCrash_kolossos_wall", CurTime() + 1.5)

                    ent:SetNW2Float("Skedaddle_om_cd", CurTime() + 33)
                end
                ent:StopSound("OM/sunky/ability 3 loop.wav")
            end

            if ent:GetNW2Bool("HoldingDown_milkandcereal") then 
                if not ent.HoldingDown_milkandcereal_bool then
                    ent:PillAnim("CerialIntro")
                    ent:SetNW2Float("HoldingDown_milkandcereal_spawndur", CurTime()+0.3)
                    ent:SetNW2Float("HoldingDown_milkandcereal_pour", CurTime()+0.7)
                    ent.HoldingDown_milkandcereal_bool = true
                    ent.HoldingDown_milkandcereal_pour_bool = false

                    ent:GetPuppet():SetNW2Float("mighty_glowwhite", CurTime()+0.5)

                end
                if ent.HoldingDown_milkandcereal_throw_bool then
                    ent.HoldingDown_milkandcereal_throw_bool = false
                end

                if ent:GetNW2Float("HoldingDown_milkandcereal_spawndur") <= CurTime() then
                    if not ent.HoldingDown_milkandcereal_spawndur_bool then
                        ent.HoldingDown_milkandcereal_spawndur_bool = true
                        local rock = ents.Create("ent_om_sunky_milkdisplay")
                        if IsValid(rock) then
                            rock:SetPos(ent:GetPuppet():GetPos())
                            rock:SetPillUser(ent:GetPuppet())
                            rock:Spawn()

                            ent:DeleteOnRemove(rock)
                            ent:SetNW2Entity("ent_om_sunky_milkdisplay", rock)

                            rock:GetPuppet():SetNW2Float("mighty_glowwhite", CurTime()+0.5)
                        end
                    end
                end

                if ent:GetNW2Float("HoldingDown_milkandcereal_pour") <= CurTime() then
                    if not ent.HoldingDown_milkandcereal_pour_bool then
                        ent.HoldingDown_milkandcereal_pour_bool = true

                        local puppet = ent:GetPuppet()
                        local cylinder = ents.Create("ent_om_sunkypuddle")

                        local pos = ply:GetPos() + ent:GetPuppet():GetForward()*60

                        local tr = util.TraceLine({
                            start = pos + Vector(0, 0, 50),
                            endpos = pos - Vector(0, 0, 50000),
                            filter = {ply, ent, puppet}
                        })

                        local ang = Angle(0, 0, 0)

                        if tr.Hit then
                            ang = tr.HitNormal:Angle()
                            ang:RotateAroundAxis(ang:Right(), 90)
                        end

                        cylinder:SetPos(tr.HitPos or pos)
                        cylinder:SetAngles(ang)

                        cylinder:Spawn()
                        cylinder:SetPillUser(ply)
                        cylinder:SetPuppet(ent)
                        cylinder:Spawn()
                        ent:DeleteOnRemove(cylinder)

                        ent.SunkyMilkPuddle = cylinder
                    else
                        if ent.SunkyMilkPuddle and IsValid(ent.SunkyMilkPuddle) then
                            if ent.SunkyMilkPuddle:GetModelScale() <= 3 then
                                local targetScale = 3
                                local scale = ent.SunkyMilkPuddle:GetModelScale()

                                if scale < targetScale then
                                    local diff = targetScale - scale
                                    local step = math.max(diff * 0.017, 0.002)

                                    ent.SunkyMilkPuddle:SetModelScale(math.min(scale + step, targetScale))
                                else
                                    ent:SetNW2Bool("HoldingDown_milkandcereal", false)
                                end
                            end
                        end
                    end
                end

                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.2)
            else
                if ent.HoldingDown_milkandcereal_bool then
                    ent:PillAnim("CerialEnd")
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.75)
                    ent:SetNW2Float("HoldingDown_milkandcereal_throw", CurTime()+0.3)
                    ent.HoldingDown_milkandcereal_bool = false
                    ent.SunkyMilkPuddle = nil

                    ent:SetNW2Float("MilkandCereal_om_cd", CurTime()+25)
                end
                if ent.HoldingDown_milkandcereal_spawndur_bool then
                    ent.HoldingDown_milkandcereal_spawndur_bool = false
                end

                if ent:GetNW2Float("HoldingDown_milkandcereal_throw") <= CurTime() then
                    if not ent.HoldingDown_milkandcereal_throw_bool then
                        ent.HoldingDown_milkandcereal_throw_bool = true
                        local bowl = ent:GetNW2Entity("ent_om_sunky_milkdisplay")
                        if IsValid(bowl) then
                            bowl:Remove()

                            local rock = ents.Create("prop_physics")

                            if IsValid(rock) then
                                rock:SetModel("models/Noodles/OM/sunkycerial.mdl")

                                local leftBone = ent:GetPuppet():LookupBone("LeftHand")
                                local rightBone = ent:GetPuppet():LookupBone("RightHand")

                                if rightBone and leftBone then
                                    local rightPos, rightAng = ply:GetBonePosition(rightBone)
                                    local leftPos, leftAng = ply:GetBonePosition(leftBone)

                                    if rightPos and leftPos then
                                        rightPos = rightPos + rightAng:Up() * -15 + rightAng:Right()  * -50
                                        leftPos  = leftPos  + leftAng:Up()  * -15 + leftAng:Right()  * -50

                                        local pos = (rightPos + leftPos) * 0.5

                                        local ang = LerpAngle(0.5, leftAng, rightAng)
                                        ang:RotateAroundAxis(ang:Forward(), 90)
                                        ang:RotateAroundAxis(ang:Up(), 90)
                                        ang:RotateAroundAxis(ang:Right(), -90)

                                        if SERVER then
                                            rock:SetPos(pos)
                                            rock:SetAngles(ang)
                                        else
                                            rock:SetRenderOrigin(pos)
                                            rock:SetRenderAngles(ang)
                                        end
                                    end
                                end

                                rock:Spawn()

                                ent:DeleteOnRemove(rock)
                                ent:SetNW2Entity("ent_om_mighty_rock_display", rock)

                                local phys = rock:GetPhysicsObject()

                                if IsValid(phys) then
                                    phys:Wake()
                                    phys:SetVelocity(ent:GetPuppet():GetUp() * 300 + ent:GetPuppet():GetForward() * -300)
                                    phys:SetMass(50)
                                    phys:EnableDrag(false)
                                    phys:EnableMotion(true)
                                end

                                rock:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

                                timer.Simple(3,function()
                                    if !IsValid(rock) then return end
                                    rock:SetNW2Float("mighty_glowwhite", CurTime()+0.5)
                                    timer.Simple(0.25,function()
                                        if !IsValid(rock) then return end
                                        rock:Remove()
                                    end)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply, ent, button)
        if SERVER then
            if button == KEY_E then
                if ent:GetNW2Float("HoldingDown_milkandcereal_pour") >= CurTime() then return end
                if ent:GetNW2Float("HoldingDown_milkandcereal_throw") >= CurTime() then return end
                if ent:GetNW2Float("HoldingDown_milkandcereal_spawndur") >= CurTime() then return end
                if not ent:GetNW2Bool("HoldingDown_milkandcereal") then return end
                ent:SetNW2Bool("HoldingDown_milkandcereal", false)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply, ent, button)
        if SERVER then
            if button == KEY_E then
                if ent:GetNW2Float("MilkandCereal_om_cd") >= CurTime() then return end
                if ent:GetNW2Float("HoldingDown_milkandcereal_throw") >= CurTime() then return end
                if ent:GetNW2Float("HoldingDown_milkandcereal_pour") >= CurTime() then return end
                if ent:GetNW2Bool("HoldingDown_milkandcereal") then return end

                if ent:GetNW2Float("Skedaddle_chargeup_duration") >= CurTime() then return end
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles") >= CurTime() then return end

                ent:SetNW2Bool("HoldingDown_milkandcereal", true)
            end

            if button == KEY_T then
                if ent:GetNW2Float("Skedaddle_om_cd") >= CurTime() then return end
                if ent:GetNW2Float("HoldingDown_milkandcereal_throw") >= CurTime() then return end
                if ent:GetNW2Float("HoldingDown_milkandcereal_pour") >= CurTime() then return end
                if ent:GetNW2Bool("HoldingDown_milkandcereal") then return end

                if ent:GetNW2Float("Skedaddle_chargeup_duration") >= CurTime() then return end
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles") >= CurTime() then return end

                local dur = ent:GetPuppet():SequenceDuration(ent:GetPuppet():LookupSequence("Skedaddle Intro ND"))
                ent:SetNW2Float("Skedaddle_chargeup_duration", CurTime()+dur)

                ent:PillAnim("SkedaddleIntro")
            end
        end
    end,

    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if SERVER then
                if ent:GetNW2Float("HoldingDown_milkandcereal_throw") >= CurTime() then return end
                if ent:GetNW2Float("HoldingDown_milkandcereal_pour") >= CurTime() then return end
                if ent:GetNW2Bool("HoldingDown_milkandcereal") then return end

                if ent:GetNW2Float("Skedaddle_chargeup_duration") >= CurTime() then return end
                if ent:GetNW2Float("Skedaddle_charge_duration") >= CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles") >= CurTime() then return end

                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end

                local puppet = ent:GetPuppet()
                if !IsValid(puppet) then return end
                
                AdvancedPillSound(
                    {
                        stringe = "OM/fleetway/Fleetway m1 swing.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1)

                local layeredAnim = puppet:AddGesture(ACT_MELEE_ATTACK_SWING_GESTURE, false)

                local current = 1
                puppet:SetLayerWeight(layeredAnim, current)
                puppet:SetLayerPriority(layeredAnim, 10)

                local playbackRate = 1.5
                puppet:SetLayerPlaybackRate(layeredAnim, playbackRate)

                local function fadeLayer()
                    if not IsValid(puppet) then return end
                    current = current - 0.04
                    puppet:SetLayerWeight(layeredAnim, math.max(current, 0))

                    if current > 0 then
                        timer.Simple(0.00035, fadeLayer)
                    end
                end

                timer.Simple(0.45, fadeLayer)

                timer.Simple(0.95,function()
                    if !IsValid(ent) then return end
                    puppet:RemoveLayer(puppet:FindGestureLayer(ACT_MELEE_ATTACK_SWING_GESTURE))
                end)


            end
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
            ent.AlternatePlaySolution = true
            ent:PillAnim('jump2')
            ent.AlternatePlaySolution = false
        end

        AdvancedPillSound(
            {
                stringe = "OM/sunky/Jump.wav",
                pitchPercent = 100,
                volume = 1,
                soundLevel = 87
            },
            ent
        )

    end
})