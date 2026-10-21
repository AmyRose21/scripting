
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
    ["Lazy_indicator_steve"] = Material("icons/Lazy_indicator_steve.png"),
    ["Rushout_steve"] = Material("icons/Rushout_steve.png"),
    ["sabotage_steve"] = Material("icons/sabotage_steve.png"),
    ["counter_cus_im_evil_haha"] = Material("icons/counter_cus_im_evil_haha.png"),
}



pk_pills.register('pill_om_SteveOutcome', {

    printName='Steve Outcome',
    Outcomememories='Steve Outcome',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/steveoutcome.mdl",
    --[[
    hull = Vector(20,20,60),
    duckBy = 14,
    ]]

    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',
    
    anims={
        default={
            idle="ref",
            run="run",
            walk="ref",
            jump2="jump",
            glide="fall",
            KillAnim = "KillAnim",
        },
            
        ShouldMoveRotate={
            ref= function(ent)
                if ent:GetNW2Float("Rushout_steveoutcome_rush_duration") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("Rushout_steveoutcome_chargeup_duration") > CurTime() then return "shiftlock" end
                return 'notshftlock' 
            end,
            run= function(ent)
                if ent:GetNW2Float("Rushout_steveoutcome_rush_duration") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("Rushout_steveoutcome_chargeup_duration") > CurTime() then return "shiftlock" end
                return 'notshftlock' 
            end,
            jump= function(ent)
                if ent:GetNW2Float("Rushout_steveoutcome_rush_duration") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("Rushout_steveoutcome_chargeup_duration") > CurTime() then return "shiftlock" end
                return 'notshftlock'
            end,
            fall= function(ent)
                if ent:GetNW2Float("Rushout_steveoutcome_rush_duration") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("Rushout_steveoutcome_chargeup_duration") > CurTime() then return "shiftlock" end
                return "notshftlock"
            end,
        },

        ShouldAlternate={
            fall = function(ent)
                --local ply = ent:GetPillUser()
                
            end,
            idle= function(ent)
                --local ply = ent:GetPillUser()
                
            end,
            walk= function(ent) 
                --local ply = ent:GetPillUser()
                
            end,
            run= function(ent)
                --local ply = ent:GetPillUser()
                
            end,
        },
        
        animrates = {
        }
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


    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["sabotage_steve"]
            end,
            name = function(uselessvar,ply,ent)
                return "Sabotage"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_E
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Sabotage_steveoutcome_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 1
            end,
            survivor = false,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Rushout_steve"]
            end,
            name = function(uselessvar,ply,ent)
                return "Rushout"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_R
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Rushout_steveoutcome_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 16
            end,
            survivor = false,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility3_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["counter_cus_im_evil_haha"]
            end,
            name = function(uselessvar,ply,ent)
                return "Counter cuz im evil"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_T
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("counter_steveoutcome_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 20
            end,
            survivor = false,
            font = "CreditsText",
        },
        [4] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility4_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Lazy_indicator_steve"]
            end,
            name = function(uselessvar,ply,ent)
                return "Lazy indicator"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_I
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("lazyindicator_steveoutcome_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 20
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
            Invisible = function(ply,ent)
                if SERVER then
                    return 1000
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return 70
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

                if ent:GetNW2Bool("Bool_Invisible_steveoutcome_om") then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.Invisible() - ent.formTable.Outcomememories_stats.moveSpeed.walk() *0.7
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Invisible() - ent.formTable.Outcomememories_stats.moveSpeed.run() *0.7
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.Invisible() - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *0.7
                    
                end

                return sendtotable
            end,
        }
    },

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if SERVER then
            if event == "SlamImpact" then
                local bone = ent:GetPuppet():LookupBone("RightHand")
                if bone then
                    local pos, ang = ent:GetPuppet():GetBonePosition(bone)
                    local ed = EffectData()
                    ed:SetOrigin(pos)
                    ed:SetEntity(ent)
                    util.Effect("fleetway_spindashhit", ed)
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
            if event == "ThrowRagdoll" then
                timer.Simple(0.1,function()
                    if !IsValid(ent) then return end
                    ent:SetNWBool("JumpscareAnim_om_boolean2", false)
                end)
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_killer_om(initializetable2["entity"])


        initializetable2["player"].ColorRGB_B_1_OM = Color(215,215,0, 255)
        if SERVER then

            local health = 2017
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            --initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)

            initializetable2["entity"]:SetNW2Float('OM_friction', 1)

            initializetable2["player"]:SetNW2String("TerrorRadius_om","OM/music/steveoutcomeTerrorRadius.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life1_om","OM/music/steveoutcomechase.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life2_om","OM/music/steveoutcomelastlife.wav")

            initializetable2["player"]:SetNW2String("CharacterStunned_om", "")

            initializetable2["player"].CustomFunctionForDowning_OM = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if IsValid(initializetable2["entity"]) then
                    timer.Simple(1,function()
                        if !IsValid(initializetable2["entity"]) then return end
                        --[[
                        AdvancedPillSound(
                            {
                                stringe = {"OM/Fleetway/FleetwaySurvDown1.wav", "OM/Fleetway/FleetwaySurvDown2.wav", "OM/Fleetway/FleetwaySurvDown3.wav"},
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            initializetable2["entity"]
                        )
                        ]]
                    end)
                end
            end

            initializetable2["player"].OM_AttacterCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if IsValid(initializetable2["entity"]) then
                    if GetConVar("om_pills_action_2ndlife"):GetBool() then
                        if entityfall:GetNW2Bool("SecondLife_OM") and not entityfall:GetNW2Bool("OnSecondLife_OM") then return end
                    end
                    if entityfall:GetNW2Float("Dead_OM") > CurTime() then return end
                    if dmg:GetDamageType() ~= DMG_CLUB then return end
                    if entityfall:Health() - damageamount <= 0.5 then
                        if entityfall:GetNW2Bool("MetalBeing_OM") then
                            initializetable2["entity"]:SetNW2Bool("DownedMetalSonic_OM", true)
                            return end
                        local ent = initializetable2["entity"]
                        local ply = initializetable2["player"]


                        if ent.flyingent and IsValid(ent.flyingent) then
                            ent.flyingent:Remove()
                        end


                        initializetable2["entity"]:PillAnim("KillAnim")
                        local anim = ent:GetPuppet():LookupSequence("KillAnim")
                        local dur = ent:GetPuppet():SequenceDuration(anim)
                        initializetable2["entity"]:SetNW2Float("OM_executionanim", CurTime()+dur)

                        initializetable2["entity"]:SetNW2Float("DisablePlayerMovement_OM_stun_iframe1", CurTime()+dur)
                        
                        entityfall:SetNW2Float("OM_NoDamagePrevention", CurTime()+dur)
                        dmg:SetDamage(0)

                        ent:SetNW2Float("Rushout_steveoutcome_block", 0)
                        ent:SetNWBool("JumpscareAnim_om_boolean2", true)

                        timer.Simple(0.5,function()
                            if !IsValid(initializetable2["entity"]) then return end
                            AdvancedPillSound(
                                {
                                    stringe = "OM/Fleetway/Fleetway-KillSound.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                initializetable2["entity"]
                            )
                        end)


                        if entityfall.loco then
                            entityfall.loco:SetVelocity(vector_origin)
                            entityfall.loco:SetDesiredSpeed(0)
                        end
                        if entityfall:IsNPC() or entityfall:IsNextBot() then
                            entityfall:NextThink(CurTime() + dur)
                        end


                        local character = ""
                        if entityfall:IsPlayer() and entityfall.pk_pill_ent then
                            character = entityfall.pk_pill_ent.formTable.printName
                        end
                        if entityfall.formTable then
                            character = entityfall.formTable.printName
                        end

                        timer.Simple(dur,function()
                            if !IsValid(initializetable2["entity"]) then return end
                            if !IsValid(entityfall) then return end
                            ent:SetNW2Float("Dead_OM", CurTime()+0.1)

                            entityfall:SetNW2Float("OM_Damage_ReductionRemoveal", CurTime()+0.1)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_GENERIC, true, false, false, true)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_CRUSH, true, false, false, true)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_BULLET, true, false, false, true)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_SLASH, true, false, false, true)
                            ent:SetNWBool("JumpscareAnim_om_boolean2", false)

                            timer.Simple(1, function()
                                if !IsValid(initializetable2["entity"]) then return end
                                if character == "Amy" then
                                end
                                if character == "Sonic" then
                                end
                                if character == "Knuckles" then
                                end
                            end)
                        end)

                        ent:SetNWBool("JumpscareAnim_om_boolean2", true)
                        local throw = false
                        local enemyragdoll = CreateRagdolLCharacter_OM({
                            target = entityfall,
                            host = ent,

                            shouldremove = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return true end
                                if not IsValid(entityfall) then return true end
                                if not IsValid(ent) then return true end
                                if ent:GetNW2Float("OM_executionanim") < CurTime() then
                                    return true
                                else
                                    entityfall:SetNW2Float("ragdolltype_grab", CurTime()+0.1)
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

                                if not IsValid(headPhys) then headPhys = createfakeragdoll:GetPhysicsObject() end
                                if not IsValid(headPhys) then return end

                                local bone = puppet:LookupBone("RightHand")
                                if not bone then return end

                                local pos, ang = puppet:GetBonePosition(bone)
                                if not pos then return end
                                --JumpscareAnim_om_boolean2JumpscareAnim_om_boolean2
                                if not ent:GetNWBool("JumpscareAnim_om_boolean2") then
                                    if not throw then
                                        throw = true
                                        headPhys:ApplyForceCenter(puppet:GetRight()*1750)
                                    end
                                    return true end
                                headPhys:SetPos(pos)
                                headPhys:SetAngles(ang)
                                headPhys:SetVelocityInstantaneous(vector_origin)
                                headPhys:Wake()
                            end

                        })

                    end
                end
            end

            initializetable2["player"].OM_StunFunction = function()
                local ent = initializetable2["entity"]
                if !IsValid(ent) then return end

            end


            initializetable2["player"].OM_DamageBeforeBeforeCustomFunction = function(useless, datainfo)
                local ent = initializetable2["entity"]
                if !IsValid(ent) then return end
                if ent:GetNW2Float("Rushout_steveoutcome_block") > CurTime() then
                    if datainfo[2]:GetAttacker() and IsValid(datainfo[2]:GetAttacker()) then else return end
                    if datainfo[2]:GetAttacker() == initializetable2["player"] then return end
                    if datainfo[2]:GetAttacker():IsPlayer() or datainfo[2]:GetAttacker():IsNPC() or datainfo[2]:GetAttacker():IsNextBot() then else return end
                    datainfo[2]:SetDamage(0)
                    datainfo[2]:SetDamageType(DMG_GENERIC)
                    initializetable2["player"].OM_AfterStunBlock({
                            ["ply"] = datainfo[2]:GetAttacker(),
                            ["ent"] = datainfo[2]:GetAttacker(),
                            ["target"] = datainfo[1],
                            ["StunDur"] = 1,
                            ["Damage"] = 1,
                            ["DamageType"] = DMG_GENERIC
                        }
                    )
                end
            end
            
            initializetable2["player"].OM_AfterStunBlock = function(DataTable, StunStatus)

                local tableofitemz = {}

                -- stun data
                if DataTable.ply then tableofitemz["ply"] = DataTable.ply end
                if DataTable.ent then tableofitemz["ent"] = DataTable.ent end
                if DataTable.target then tableofitemz["target"] = DataTable.target end
                if DataTable.StunDur then tableofitemz["StunDur"] = DataTable.StunDur else tableofitemz[StunDur] = 1 end
                if DataTable.stunfunction then tableofitemz["stunfunction"] = DataTable.stunfunction end
                if DataTable.shouldstack then tableofitemz["shouldstack"] = DataTable.shouldstack end

                -- damage data
                if DataTable.Damage then tableofitemz["Damage"] = DataTable.Damage else tableofitemz[Damage] = 25 end
                if DataTable.DamageType then tableofitemz["DamageType"] = DataTable.DamageType else tableofitemz[DamageType] = DMG_CLUB end
                if not DataTable.ply then return end
                if not DataTable.ent then return end
                if not DataTable.target then return end

                local ent = initializetable2["entity"]
                local ply = initializetable2["player"]
                if !IsValid(ent) then return end

                if ent:GetNW2Float("Rushout_steveoutcome_block") > CurTime() then
                    ent:SetNW2Float("Rushout_steveoutcome_block", 0)

                    local ply = initializetable2["player"]
                    ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)


                    KillerdamagestunDynamic({
                        ply = ply,
                        target = DataTable.ply,
                        DamageNumb = 17,
                        damagetype = DMG_CLUB,
                        CustomDamageSound = nil,
                        damagesound = true,
                        ShouldBlood = true,
                        flingremoveal = true,
                        ShouldBloodEffect = true
                    })

                    if ent:GetNW2Float("OM_executionanim") < CurTime() then
                        local last = CurTime() + 1.25
                        local flung = false
                        local enemyragdoll = CreateRagdolLCharacter_OM({
                            target = DataTable.ply,
                            host = ent,

                            shouldremove = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return true end
                                if not IsValid(DataTable.ply) then return true end

                                if last < CurTime() then return true end

                                return false
                            end,

                            shoulddocustomfunction = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return end
                                if not IsValid(DataTable.ply) then return end
                                if flung then return end
                                flung = true
                                local dir = (DataTable.ply:GetPos() - ply:GetPos()):GetNormalized()


                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                    local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                    if IsValid(phys) then
                                        phys:Wake()
                                        phys:SetVelocityInstantaneous(dir*1000)
                                    end
                                
                                end
                            end
                        })
                    end

                    return "cancelstun"
                end
            end
        end
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            if bit.band(initializetable2["player"]:GetFlags(), FL_NOTARGET) ~= 0 then
                initializetable2["player"]:RemoveFlags(FL_NOTARGET)
            end
        end
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

            if ent:GetNW2Float("OM_executionanim") > CurTime() then
                ent:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                if not ent:GetNW2Bool("OM_executionanimToggle") then
                    if ply:IsPlayer() then ply:SetMoveType(0) else ply:SetMoveType(0) end
                    ent:SetNW2Bool("OM_executionanimToggle", true)
                end
            else

                if ent:GetNW2Bool("OM_executionanimToggle") then
                    if ply:IsPlayer() then ply:SetMoveType(2) else ply:SetMoveType(0) end
                    ent:SetNW2Bool("OM_executionanimToggle", false)
                end
            end
            
            if ent:GetNW2Bool("Bool_Invisible_steveoutcome_om") then
                if not ent.Invisible_toggle then

                    ply:SetNW2String("TerrorRadius_om","")
                    ply:SetNW2String("chasemusic_life1_om","")
                    ply:SetNW2String("chasemusic_life2_om","")

                    ent.Invisible_toggle = true

                    ent:GetPuppet():SetRenderMode(RENDERMODE_TRANSALPHA)
                    ent:GetPuppet():SetColor(Color(255, 255, 255, 0))

                    ply:AddFlags(FL_NOTARGET)
                end
                ent:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
            else
                if ent.Invisible_toggle then

                    ply:SetNW2String("TerrorRadius_om","OM/music/steveoutcomeTerrorRadius.wav")
                    ply:SetNW2String("chasemusic_life1_om","OM/music/steveoutcomechase.wav")
                    ply:SetNW2String("chasemusic_life2_om","OM/music/steveoutcomelastlife.wav")

                    ply:RemoveFlags(FL_NOTARGET)
                    ent.Invisible_toggle = false

                    ent:GetPuppet():SetRenderMode(RENDERMODE_TRANSALPHA)
                    ent:GetPuppet():SetColor(Color(255, 255, 255, 255))
                end
            end

            if ply:IsOnGround() then
                if ent:GetNW2Float('Rushout_steveoutcome_grablookout_duration') > CurTime() then
                    ent:SetNW2Float("Rushout_steveoutcome_grablookout_duration", 0)
                    ent:SetNW2Float("Rushout_steveoutcome_cd", CurTime()+16)
                end
            end

            if ent:GetNW2Float("Rushout_steveoutcome_chargeup_duration") > CurTime() then
                ent:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                if not ent.rushout_steveoutcome_chargeup_bool then
                    ent.rushout_steveoutcome_chargeup_bool = true
                end
                if ent:GetNW2Float("Rushout_steveoutcome_chargeup_tick_cd") < CurTime() then
                    ent:SetNW2Float("Rushout_steveoutcome_chargeup_tick_cd", CurTime()+0.65*0.5)

                    AdvancedPillSound(
                        {
                            stringe = "OM/silver/Silver time reverse tick 0.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.5)
                end
            else
                if ent.rushout_steveoutcome_chargeup_bool then
                    ent.rushout_steveoutcome_chargeup_bool = false
                    AdvancedPillSound(
                        {
                            stringe = "OM/silver/silver_reverseRelease.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    AdvancedPillSound(
                        {
                            stringe = "OM/silver/SilverSuspension.ogg",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    AdvancedPillSound(
                        {
                            stringe = "OM/silver/Silver time reverse tick 0.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ply:SetPos(ply:GetPos()+Vector(0,0,10))
                    local vel2 = Vector(0,0,0)

                    if ply:IsPlayer() then
                        vel2 = ent:GetPuppet():GetForward() * 1400
                        vel2.z = 200
                    else
                    end
                    ply:SetLocalVelocity(vel2)
                    ent:PillAnim('jump2')
                    ent:SetNW2Float("Rushout_steveoutcome_grablookout_duration", CurTime()+0.75)
                end
            end

            if ent:GetNW2Float("Rushout_steveoutcome_grablookout_duration") > CurTime() then
                if not ent.Rushout_steveoutcome_grablookout_duration then
                    ent.Rushout_steveoutcome_grablookout_duration = true
                end
                
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                ent:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
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

                    AdvancedPillSound(
                        {
                            stringe = "OM/music/RushOutMusic.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent:SetNW2Float("Rushout_steveoutcome_grablookout_duration", 0)
                    ent:SetNW2Entity("Rushout_steveoutcome_entity", nearest)

                    local radius = 4000

                    local targetPos = nearest:GetPos()
                    local dir = (ply:GetPos() - targetPos)
                    dir.z = 0
                    dir:Normalize()

                    local newPos = targetPos + dir * radius


                    local tr = {
                        mins = nil,
                        maxs = nil,
                        mask = MASK_PLAYERSOLID
                    }

                    local function FindSafePosNearEntity(ent, ply, radius)
                        if not IsValid(ent) then return nil end

                        tr.mins = ply:OBBMins()
                        tr.maxs = ply:OBBMaxs()

                        local basePos = ent:GetPos()

                        local mins, maxs = ent:OBBMins(), ent:OBBMaxs()

                        if not radius then radius = 80 end

                        local radius = math.max(
                            math.abs(mins.x), math.abs(maxs.x),
                            math.abs(mins.y), math.abs(maxs.y)
                        ) + radius

                        local offsets = {
                            ent:GetForward() * radius,
                            -ent:GetForward() * radius,
                            ent:GetRight() * radius,
                            -ent:GetRight() * radius,
                            Vector(0,0,radius * 0.5)
                        }

                        for i = 1, #offsets do
                            local pos = basePos + offsets[i]

                            tr.start = pos
                            tr.endpos = pos
                            tr.filter = ply

                            local result = util.TraceHull(tr)

                            if not result.StartSolid and not result.AllSolid and not result.Hit then
                                return pos
                            end
                        end
                    end
                    local hookId = "crimson_steveoutcome_rushdown_" .. ply:EntIndex() .. "_" .. ent:EntIndex() .. "_" .. nearest:EntIndex()
                    local targetpos = FindSafePosNearEntity(nearest, ply, 40) or nearest:GetPos() or Vector(0,0,0)
                    ply:SetPos(newPos)
                    local increase = 0.02

                    local firsttime = false

                    hook.Add("Think", hookId, function()
                        if !IsValid(ent) or !IsValid(ply) or ply:GetPos():Distance(targetpos) < 40 then
                            if IsValid(ent) and IsValid(nearest) then
                                ent:SetNW2Float("AttackCooldown_OM", CurTime()+2 )
                                ent:SetNW2Entity("Rushout_steveoutcome_entity", NULL)
                                if ply:GetPos():Distance(targetpos) < 40 then
                                    ent:SetNW2Float("Rushout_steveoutcome_cd", CurTime()+16)

                                    KillerdamagestunDynamic({
                                        ply = ply,
                                        target = nearest,
                                        DamageNumb = 39,
                                        damagetype = DMG_CLUB,
                                        CustomDamageSound = nil,
                                        damagesound = true,
                                        ShouldBlood = true,
                                        flingremoveal = true,
                                        ShouldBloodEffect = true
                                    })

                                    if ent:GetNW2Float("OM_executionanim") < CurTime() then
                                        local last = CurTime() + 1.25
                                        local flung = false
                                        local enemyragdoll = CreateRagdolLCharacter_OM({
                                            target = nearest,
                                            host = ent,

                                            shouldremove = function(createfakeragdoll)
                                                if not IsValid(createfakeragdoll) then return true end
                                                if not IsValid(nearest) then return true end

                                                if last < CurTime() then return true end

                                                return false
                                            end,

                                            shoulddocustomfunction = function(createfakeragdoll)
                                                if not IsValid(createfakeragdoll) then return end
                                                if not IsValid(nearest) then return end
                                                if flung then return end
                                                flung = true
                                                local dir = (nearest:GetPos() - ply:GetPos()):GetNormalized()


                                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                    local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                                    if IsValid(phys) then
                                                        phys:Wake()
                                                        phys:SetVelocityInstantaneous(dir*1000)
                                                    end
                                                
                                                end
                                            end
                                        })
                                    end
                                end
                            end

                            hook.Remove("Think", hookId)
                            return
                        end

                        if not firsttime then
                            firsttime = true
                            ply:SetPos(newPos)
                        end

                        ent:SetNW2Float("Rushout_steveoutcome_rush_duration", CurTime()+0.3)
                        ent:SetNW2Angle("pill_assignedangle",(targetpos - ply:GetPos()):Angle())

                        if IsValid(nearest) then
                            targetpos = FindSafePosNearEntity(nearest, ply, 40) or nearest:GetPos()
                        end
                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.2)
                        ply:SetLocalVelocity(Vector(0,0,0))
                        ply:SetPos(LerpVector(FrameTime()*increase, ply:GetPos(), targetpos))
                        increase = math.Clamp(increase* 1.03, 0, 20)
                        ent:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                    end)
                end
            else
                if ent.Rushout_steveoutcome_grablookout_duration then
                    ent.Rushout_steveoutcome_grablookout_duration = false
                    if !IsValid(ent:GetNW2Entity("Rushout_steveoutcome_entity")) then
                        ent:SetNW2Float("Rushout_steveoutcome_cd", CurTime()+16)
                    end
                end
            end

            if ent:GetNW2Float("Rushout_steveoutcome_block") > CurTime() then
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.2)
                if not ent.Rushout_steveoutcome_block_bool then
                    ent.Rushout_steveoutcome_block_bool = true
                end
            else
                if ent.Rushout_steveoutcome_block_bool then
                    ent.Rushout_steveoutcome_block_bool = false
                    ent:SetNW2Float("counter_steveoutcome_cd", CurTime()+20)
                end
            end
        end
    end,


    noodles_OM_survivor_keybinds = function(ply, ent, button)
        if SERVER then
            if IsValid(ply:GetNWEntity("OM_ragdollentity")) then
                return
            end
            if ent:GetNW2Float("OM_executionanim") > CurTime() then return end
            if button == KEY_E then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("Rushout_steveoutcome_chargeup_duration") > CurTime() then return end
                if ent:GetNW2Float("Rushout_steveoutcome_grablookout_duration") > CurTime() then return end
                if ent.rushout_steveoutcome_chargeup_bool then return end
                if IsValid(ent:GetNW2Entity("Rushout_steveoutcome_entity")) then return end
                if ent:GetNW2Float("Rushout_steveoutcome_rush_duration") > CurTime() then return end

                if ent:GetNW2Float("Rushout_steveoutcome_block") > CurTime() then return end
                if ent:GetNW2Float("Sabotage_steveoutcome_cd") > CurTime() then return end
                if ent.Rushout_steveoutcome_block_bool then return end
                ent:SetNW2Float("Sabotage_steveoutcome_cd", CurTime()+1)

                if ent:GetNW2Bool("Bool_Invisible_steveoutcome_om") then
                    ent:SetNW2Bool("Bool_Invisible_steveoutcome_om", false)
                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1)

                    AdvancedPillSound(
                        {
                            stringe = "OM/2011x/2011X appears.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                else
                    AdvancedPillSound(
                        {
                            stringe = "OM/steveoutcome/Steve Invisible.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:SetNW2Bool("Bool_Invisible_steveoutcome_om", true)
                end
            end
            if button == KEY_R then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("Rushout_steveoutcome_chargeup_duration") > CurTime() then return end
                if ent:GetNW2Float("Rushout_steveoutcome_grablookout_duration") > CurTime() then return end
                if ent.rushout_steveoutcome_chargeup_bool then return end
                if IsValid(ent:GetNW2Entity("Rushout_steveoutcome_entity")) then return end
                if ent:GetNW2Float("Rushout_steveoutcome_rush_duration") > CurTime() then return end

                if ent:GetNW2Float("Rushout_steveoutcome_block") > CurTime() then return end
                if ent:GetNW2Bool("Bool_Invisible_steveoutcome_om") then return end
                if ent.Rushout_steveoutcome_block_bool then return end

                if ent:GetNW2Float("Rushout_steveoutcome_cd") > CurTime() then return end
                ent:SetNW2Float("Rushout_steveoutcome_chargeup_duration", CurTime()+0.65)
            end
            if button == KEY_T then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("Rushout_steveoutcome_chargeup_duration") > CurTime() then return end
                if ent:GetNW2Float("Rushout_steveoutcome_grablookout_duration") > CurTime() then return end
                if ent.rushout_steveoutcome_chargeup_bool then return end
                if IsValid(ent:GetNW2Entity("Rushout_steveoutcome_entity")) then return end
                if ent:GetNW2Float("Rushout_steveoutcome_rush_duration") > CurTime() then return end

                if ent:GetNW2Float("Rushout_steveoutcome_block") > CurTime() then return end
                if ent:GetNW2Bool("Bool_Invisible_steveoutcome_om") then return end
                if ent.Rushout_steveoutcome_block_bool then return end
                if ent:GetNW2Float("counter_steveoutcome_cd") > CurTime() then return end

                ent:SetNW2Float("Rushout_steveoutcome_block", CurTime()+1)

                ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.5)
                ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+1)
            end
            if button == KEY_I then
                if ent:GetNW2Float("lazyindicator_steveoutcome_cd") > CurTime() then return end
                if ent:GetNW2Float("ScanForEntities_OM") > CurTime() then return end

                ent:SetNW2Float("lazyindicator_steveoutcome_cd", CurTime()+20)
                ent:SetNW2Float("ScanForEntities_OM", CurTime() + 5)
            end
        end
    end,

    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if SERVER then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("Rushout_steveoutcome_chargeup_duration") > CurTime() then return end
                if ent:GetNW2Float("Rushout_steveoutcome_grablookout_duration") > CurTime() then return end
                if ent.rushout_steveoutcome_chargeup_bool then return end
                if IsValid(ent:GetNW2Entity("Rushout_steveoutcome_entity")) then return end
                if ent:GetNW2Float("Rushout_steveoutcome_rush_duration") > CurTime() then return end

                if ent:GetNW2Float("Rushout_steveoutcome_block") > CurTime() then return end
                if ent:GetNW2Bool("Bool_Invisible_steveoutcome_om") then return end
                if ent.Rushout_steveoutcome_block_bool then return end

                if ent:GetNW2Float("OM_executionanim") > CurTime() then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end

                local puppet = ent:GetPuppet()
                if not IsValid(puppet) then return end
                
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

                local playbackRate = 1
                puppet:SetLayerPlaybackRate(layeredAnim, playbackRate)

                local function fadeLayer()
                    if not IsValid(puppet) then return end
                    current = current - 0.04
                    puppet:SetLayerWeight(layeredAnim, math.max(current, 0))

                    if current > 0 then
                        timer.Simple(0.0005, fadeLayer)
                    end
                end

                timer.Simple(0.15, fadeLayer)

                timer.Simple(0.9,function()
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
            ent:PillAnim('jump2')
        end

        AdvancedPillSound(
            {
                stringe = "OM/Jump.wav",
                pitchPercent = 100,
                volume = 1,
                soundLevel = 87
            },
            ent
        )

    end
})