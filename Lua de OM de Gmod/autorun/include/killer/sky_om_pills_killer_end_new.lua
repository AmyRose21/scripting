
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
    ["End_om_icon1"] = Material("icons/End_om_icon1.png"),
    ["End_om_icon2"] = Material("icons/End_om_icon2.png"),
    ["End_om_icon3"] = Material("icons/End_om_icon3.png"),
    ["End_om_icon_alt1"] = Material("icons/End_om_icon_alt1.png"),
    ["End_om_icon_alt2"] = Material("icons/End_om_icon_alt2.png"),
}


if SERVER then--
    timer.Simple(1,function()
        if SERVER then else return end
        OM_AddSpeedConfigeration(function(entity)
            if SERVER and entity:GetNW2Float("end_afterimage_debuff_duration_slowness", 0) >= CurTime() then
                return 0.8
            end
            return 1
        end)
    end)
    timer.Simple(1,function()
        if SERVER then else return end
        OM_AddSpeedConfigeration(function(entity)
            if SERVER and entity:GetNW2Float("end_afterimage_debuff_duration_slowness_35", 0) >= CurTime() then
                return 0.65
            end
            return 1
        end)
    end)
end

hook.Add("SetupMove", "ray_slowdown_debuff", function(ply, mv, cmd)
    if !IsValid(ply) then return end
    if !ply:Alive() then return end

    if ply:GetNW2Float("end_afterimage_debuff_duration_slowness", 0) >= CurTime() then
        local vel = mv:GetVelocity()

        vel.x = vel.x * 0.8
        vel.y = vel.y * 0.8

        mv:SetVelocity(vel)
    end

    if ply:GetNW2Float("end_afterimage_debuff_duration_slowness_35", 0) >= CurTime() then
        local vel = mv:GetVelocity()

        vel.x = vel.x * 0.65
        vel.y = vel.y * 0.65

        mv:SetVelocity(vel)
    end
end)

pk_pills.register('pill_om_end2', {

    printName='End',
    Outcomememories='End',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/end_new.mdl",
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
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            portalspawn="portalspawn",
            portalend="portalend",
        },
            
        ShouldMoveRotate={
            idle= function(ent)
                if ent:GetNW2Float("end_speer_duration") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return "assignedagnles" end
                return 'notanything' 
            end,
            run= function(ent) 
                if ent:GetNW2Float("end_speer_duration") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return "assignedagnles" end
                return 'notshftlock' 
            end,
            walk= function(ent) 
                if ent:GetNW2Float("end_speer_duration") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return "assignedagnles" end
                return 'notshftlock' 
            end,
            jump= function(ent)
                if ent:GetNW2Float("end_speer_duration") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return "assignedagnles" end
                return 'notshftlock'
            end,
            fall= function(ent)
                if ent:GetNW2Float("end_speer_duration") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return "assignedagnles" end
                return "notshftlock"
            end,
        },

        ShouldAlternate={
            fall= function(ent)
                if ent:GetNW2Float("end_speer_duration") > CurTime() then return "ShovelSpeerCharge" end
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return "ShovelSpinning" end
                if ent:GetNW2Float("jump_animdur") > CurTime() then
                    if ent:GetNW2Bool("end_om_hasshovel") then return "jumpShovel" end
                    return "jump"
                end
                if ent:GetNW2Bool("end_om_hasshovel") then return "fallShovel" end
            end,
            idle= function(ent)
                if ent:GetNW2Float("end_speer_duration") > CurTime() then return "ShovelSpeerCharge" end
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return "ShovelSpinning" end
                if ent:GetNW2Bool("end_om_hasshovel") then return "idleShovel" end
            end,
            walk= function(ent)
                if ent:GetNW2Float("end_speer_duration") > CurTime() then return "ShovelSpeerCharge" end
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return "ShovelSpinning" end
                if ent:GetNW2Bool("end_om_hasshovel") then return "walkShovel" end
            end,
            run= function(ent)
                if ent:GetNW2Float("end_speer_duration") > CurTime() then return "ShovelSpeerCharge" end
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return "ShovelSpinning" end
                if ent:GetNW2Bool("end_om_hasshovel") then return "runShovel" end
            end,
        },
        ShouldMoveRotate_lerpspeed={
            idle= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return 13 end
                return 8
            end,
            walk= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return 13 end
                return 8
            end,
            run= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return 13 end
                return 8
            end,
            fall= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return 13 end
                return 8
            end,
        },
        
        animrates = {
            fall = function(ent)
                return 1
            end,
            idle= function(ent)
                return 1
            end,
            walk= function(ent)
                return 1
            end,
            run= function(ent)
                return 1
            end,
        }
    },

    OM_cameratable = function(ply,ent)

        local basetable =  {
            startoffset = Vector(15,0,25),  -- left-up, front-back, up-down
            dist=145,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 0,
            transition = 1,
            canscroll = true,
            bonecenter = "Head",
        }

        return basetable
    end,

    OM_transitionbar_type2table = {
        ColorDisplay = Color(255,0,0,255),
        CanShowcase = function(e,ply, ent)
            return ent:GetNW2Float("JetpackJumpCooldown") > CurTime()
        end,
        Factor = function(e,ply, ent)
            local clamp = math.Clamp(( ent:GetNW2Float("JetpackJumpCooldown") - CurTime()) / 5, 0, 1)
            return Lerp(clamp, 1, 0)
        end,
        offset = function(e,ply, ent)
            return Vector(-20,15,0)
        end
    },

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("end_om_hasshovel")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["End_om_icon1"]
            end,
            name = function(uselessvar,ply,ent)
                return "Saturated Grief"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_E
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("SATURATEDGRIEF_cd_end")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            survivor = false,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("end_om_hasshovel")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["End_om_icon2"]
            end,
            name = function(uselessvar,ply,ent)
                return "Returnal"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_R
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("RETURNAL_cd_end")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 30
            end,
            survivor = false,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Bool("end_om_hasshovel")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["End_om_icon_alt1"]
            end,
            name = function(uselessvar,ply,ent)
                return "Heavy Hitter"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_E
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("ShovelSpinning_cd_end")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            survivor = false,
            font = "CreditsText",
        },
        [4] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Bool("end_om_hasshovel")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["End_om_icon_alt2"]
            end,
            name = function(uselessvar,ply,ent)
                return "Burial"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_R
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Burial_cd_end")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 4
            end,
            survivor = false,
            font = "CreditsText",
        },
        [5] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["End_om_icon3"]
            end,
            name = function(uselessvar,ply,ent)
                return "DID YOU BRING THE SHOVEL?"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_T
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("shovel_cd_end")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 5
            end,
            survivor = false,
            font = "CreditsText",
        },
    },
    

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return 39
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return 525
                end
            end,
            Invisible = function(ply,ent)
                if SERVER then
                    return 900
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return 39
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

    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            return true
        end,
        colorbar = function(uselessvar,ply,ent)
            return Color(0, 0, 125, 255)
        end,
        progression = function(uselessvar,ply,ent)
            return ent:GetNW2Float("AmountsOfHoles_OM_end")
        end,
        maximumbar = function(uselessvar,ply,ent)
            return 8
        end,
    },

    speedhandeler_om = {
        modifiers = {
            ['LowHealth1'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }


                if ply:Health() < 200 then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() *1.05 - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run() *1.05 - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1.05 - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
            ['LowHealth2'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }


                if ply:Health() < 120 then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() *1.05 - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run() *1.05 - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1.05 - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
            ['shovelreduction'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Bool("end_om_hasshovel") then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*0.8 - ent.formTable.Outcomememories_stats.moveSpeed.walk() 
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run()*0.8 - ent.formTable.Outcomememories_stats.moveSpeed.run() 
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.ducked()*0.8 - ent.formTable.Outcomememories_stats.moveSpeed.ducked() 
                    
                end

                return sendtotable
            end,
            ['invisible'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Bool("end_dive_ability1_activated") then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.run() - ent.formTable.Outcomememories_stats.moveSpeed.walk() *0.7
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Invisible() - ent.formTable.Outcomememories_stats.moveSpeed.run() *0.7
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.run() - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *0.7
                    sendtotable["Jump"] = ent.formTable.Outcomememories_stats.moveSpeed.jumppower()*1.3 - ent.formTable.Outcomememories_stats.moveSpeed.jumppower() *0.7
                end

                return sendtotable
            end,
            ['shovelreduction'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Bool("end_om_hasshovel") then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*0.8 - ent.formTable.Outcomememories_stats.moveSpeed.walk() 
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run()*0.8 - ent.formTable.Outcomememories_stats.moveSpeed.run() 
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.ducked()*0.8 - ent.formTable.Outcomememories_stats.moveSpeed.ducked() 
                    sendtotable["Jump"] = ent.formTable.Outcomememories_stats.moveSpeed.jumppower()*0.76 - ent.formTable.Outcomememories_stats.moveSpeed.jumppower()
                end

                return sendtotable
            end,
        }
    },

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if SERVER then
            if event == "Step" then
                if ent:GetNW2Bool("end_dive_ability1_activated") then return end
                AdvancedPillSound(
                    {
                        stringe = {
                            "OM/end/endstep_1.wav",
                            "OM/end/endstep_2.wav",
                            "OM/end/endstep3.wav",
                        },
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
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
                        local typeofdamage = 25
                        if ent:GetNW2Bool("end_om_hasshovel") then 
                            typeofdamage = 55
                        end
                        
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
                        hitent = nearest
                    end
                end
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_killer_om(initializetable2["entity"])


        initializetable2["player"].ColorRGB_B_1_OM = Color(0,0,215, 255)
        if SERVER then

            initializetable2["entity"]:SetNW2Float('AmountsOfHoles_OM_end', 8)

            local health = 265
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)

            initializetable2["entity"]:SetNW2Float('OM_friction', 1)

            initializetable2["player"]:SetNW2String("TerrorRadius_om","OM/music/endterrorradius.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life1_om","OM/music/endchase.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life2_om","OM/music/endlastlife.wav")

            initializetable2["entity"].endom_holetable = {}


            initializetable2["player"].OM_DamageBeforeBeforeCustomFunction = function(useless, datainfo)
                local ent = initializetable2["entity"]
                if !IsValid(ent) then return end
                if ent:GetNW2Bool("end_dive_ability2_activated") then 
                    if datainfo[2]:GetAttacker() and IsValid(datainfo[2]:GetAttacker()) then else return end
                    if datainfo[2]:GetAttacker() == initializetable2["player"] then return end
                    if datainfo[2]:GetAttacker():IsPlayer() or datainfo[2]:GetAttacker():IsNPC() or datainfo[2]:GetAttacker():IsNextBot() then else return end
                    
                    datainfo[2]:SetDamageType(DMG_GENERIC)
                    initializetable2["player"].OM_AfterStunBlock({
                            ["ply"] = datainfo[2]:GetAttacker(),
                            ["ent"] = datainfo[2]:GetAttacker(),
                            ["target"] = datainfo[1],
                            ["StunDur"] = 1,
                            ["Damage"] = datainfo[2]:GetDamage(),
                            ["DamageType"] = DMG_GENERIC
                        }
                    )
                    datainfo[2]:SetDamage(0)
                end
            end

            initializetable2["player"].OM_StunFunction = function()
                local ent = initializetable2["entity"]
                local ply = initializetable2["player"]
                if !IsValid(ent) then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end

                AdvancedPillSound(
                    {
                        stringe = "OM/end/endstun.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end

            initializetable2["entity"].DamageAmount_om_end = 0

            initializetable2["player"].OM_AttacterCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                local ent = initializetable2["entity"]
                if IsValid(ent) then
                    if ent:GetNW2Bool("end_om_hasshovel") then 
                        ent.DamageAmount_om_end = ent.DamageAmount_om_end + damageamount
                    end

                    if ent:GetNW2Float("end_speer_duration") > CurTime() then
                        if entityfall:Health()-damageamount < 25 then
                            entityfall:SetHealth(25)
                            dmg:SetDamage(0.1)
                            return
                        end
                    end
                    if ent:GetNW2Float("Kolossos_considered_slam") > CurTime() then
                        if entityfall:Health()-damageamount < 10 then
                            entityfall:SetHealth(10)
                            dmg:SetDamage(0.1)
                            return
                        end
                    end
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

                if ent:GetNW2Bool("end_dive_ability2_activated") then 

                    local ply = initializetable2["player"]

                    --if ply:Health() >= health then else ply:SetHealth(ply:Health()+tableofitemz["Damage"]) end

                    if DataTable.ply:GetPos():Distance(ply:GetPos()) < 180 then
                        DataTable.ply:SetNW2Float("OM_Damage_ReductionRemoveal", CurTime())
                        KillerdamagestunDynamic({
                            ply = ply,
                            target = DataTable.ply,
                            DamageNumb = 17,
                            damagetype = DMG_BLAST,
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
                                            phys:SetVelocityInstantaneous(dir*750)
                                        end
                                    
                                    end
                                end
                            })
                        end
                    end

                    return "cancelstun"
                end


                if ent.canstunstack_entity_end_om == nil then 
                    ent.canstunstack_entity_end_om = tableofitemz["ply"] end

                if ent.canstunstack_entity_end_om ~= tableofitemz["ply"] then
                    DataTable.ply:SetNW2Float("OM_Damage_ReductionRemoveal", CurTime()+0.1)
                    KillerdamagestunDynamic({
                        ply = ply,
                        target = DataTable.ply,
                        DamageNumb = 12,
                        damagetype = DMG_BLAST,
                        CustomDamageSound = nil,
                        damagesound = true,
                        ShouldBlood = true,
                        flingremoveal = true,
                        ShouldBloodEffect = true
                    })
                    DataTable.ply:SetNW2Float("end_afterimage_debuff_duration", CurTime()+6)
                    DataTable.ply:SetNW2Float("end_afterimage_debuff_duration_slowness", CurTime()+6)
                end

            end


        end
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetGravity(1)
        end

    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
            else 
                ent.canstunstack_entity_end_om = nil
            end

            local aabilityinuse = false

            ply:SetNW2Float("DamageResistance_OM_2", 100/100)

            OM_PILL_speedThink(ply, ent)

            if ent:GetNW2Bool("holdingravity_holding") then
                ply:SetGravity(0.3)
                if not ent.holdingravity_holding_bool then
                    ent.holdingravity_holding_bool = true
                end
            else
                if ent.holdingravity_holding_bool then
                    ply:SetGravity(1)
                    ent.holdingravity_holding_bool = false
                    ent:SetNW2Float("JetpackJumpCooldown", CurTime()+ 5)
                    ent:SetNW2Float("LowGrav_duration_end", CurTime()+ 1)
                end
            end

            if ent:GetNW2Float("HeldGlideJump_duration") < CurTime() and not ent:GetNW2Bool("HeldGlideJump_jump_notwork") then
                if ent:GetNW2Bool("JetpackJump") and ent:GetNW2Bool("HeldGlideJump_jump") then
                    ent:SetNW2Bool("JetpackJump", false)
                    ent:SetNW2Bool("holdingravity_holding", true)
                    ply:SetVelocity(Vector(0,0,150))
                end
            end

            if ply:IsOnGround() then
                if ent:GetNW2Bool("JustStartedDrillMode") then
                    ent:SetNW2Bool("JustStartedDrillMode", false)
                else
                    if ent:GetNW2Bool("DrillMode") then
                        ent:SetNW2Bool("DrillMode", false)
                        ent:SetNW2Float("drillmode_cd", CurTime()+ 21)
                    end
                end
                ent:SetNW2Bool("HeldGlideJump_jump", false)
                ent:SetNW2Bool("JetpackJump", false)
                ent:SetNW2Bool("holdingravity_holding", false)

                ent:SetNW2Bool("HeldGlideJump_jump_notwork", false)
            end

            if ent:GetNW2Float("end_m1_swingboost") > CurTime() then
                if ply:IsOnGround() then
                    ply:SetVelocity(ply:GetForward()*240)
                else
                    ply:SetVelocity(ply:GetForward()*50)
                end
            end

            if not ent.OM_Kolossos_HitList then ent.OM_Kolossos_HitList = {} end

            --[[
            if ent:GetNW2Float("end_speer_duration") > CurTime() and ply:IsOnGround() then 
                ent:SetNW2Float("end_speer_duration",0)
            end
            ]]
            --if ent:GetNW2Bool("End_gliding") then 
            if ent:GetNW2Float("end_speer_duration") > CurTime() then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                aabilityinuse = true
                --ply:SetVelocity(velo + forward)
                if not ent.end_speer_duration_bool then
                    ent.end_speer_duration_bool = true
                    ent.end_speer_durationDirection_speed = 350
                end
                
                ent:SetNW2Angle("pill_assignedangle", ent.end_speer_durationDirection:Angle())

                ent.end_speer_durationDirection_speed = math.Clamp(ent.end_speer_durationDirection_speed+ 100, 0, 3000)
                ply:SetLocalVelocity(ent.end_speer_durationDirection * ent.end_speer_durationDirection_speed)
                



                    local function isontable(ent2)
                        for _, obj in ipairs(ent.OM_Kolossos_HitList) do
                            if ent2 == obj then
                                return true
                            end
                        end
                    end

                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 90)) do
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                            if not GetConVar('PVPStun_OM_exe'):GetBool() then
                                if ent2:GetNW2Bool("OM_character_monster") then return end
                            end

                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                            if Mutal_OMCanDamage_grab(ply,ent,ent2) then else continue end
                            
                            if isontable(ent2) then
                                continue
                            end

                            if IsValid(ent2) then
                                table.insert(ent.OM_Kolossos_HitList, ent2)

                                KillerdamagestunDynamic({
                                    ply = ply,
                                    target = ent2,
                                    DamageNumb = 25,
                                    damagetype = DMG_CLUB,
                                    CustomDamageSound = nil,
                                    damagesound = true,
                                    ShouldBlood = true,
                                    flingremoveal = true,
                                    ShouldBloodEffect = true
                                })

                                local effectData = EffectData()
                                effectData:SetOrigin(ent2:GetPos()+Vector(0,0,40))
                                effectData:SetNormal(ply:GetForward()*-1)
                                effectData:SetScale(3)

                                util.Effect("kolossos_charging_blood", effectData, true, true)

                                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then
                                else
                                    ent:SetNW2Float("end_speer_duration",CurTime()+10)
                                    
                                    local Flung1 = false
                                    local Flung = false
                                    local enemyragdoll = CreateRagdolLCharacter_OM({
                                        target = ent2,
                                        host = ent,

                                        shouldremove = function(createfakeragdoll)
                                            if not IsValid(createfakeragdoll) then return true end
                                            if not IsValid(ent2) then return true end
                                            if not IsValid(ent) then return true end

                                            if (ent:GetNW2Float("end_speer_duration") < CurTime() and Flung) then
                                                return true
                                            end

                                            return false
                                        end,

                                        shoulddocustomfunction = function(createfakeragdoll)

                                            if not IsValid(createfakeragdoll) then return end

                                            if math.random(1,60) == 1 then

                                                local effectData = EffectData()
                                                effectData:SetOrigin(createfakeragdoll:GetPos()+Vector(0,0,10))
                                                effectData:SetNormal(ply:GetForward())
                                                effectData:SetScale(3)

                                                util.Effect("kolossos_blood_drip", effectData, true, true)
                                            end
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
                                            pos = puppet:GetPos() + puppet:GetForward() * 40 + puppet:GetUp() * 40

                                            if not Flung1 then
                                                headPhys:SetPos(pos)
                                                headPhys:SetAngles(ang)
                                                headPhys:SetVelocityInstantaneous(vector_origin)
                                                headPhys:Wake()
                                            end

                                            if ent:GetNW2Float("end_speer_duration") < CurTime() and not Flung1 then
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
                                                            chosenDir * 7500
                                                        )
                                                    end
                                                end
                                            else
                                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                    local phys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                    if IsValid(phys) then
                                                        phys:ApplyForceCenter(puppet:GetForward() * 5000 + Vector(0,0,2000))
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
                        end
                    end  



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
                        local ishitentity = false
                        for i,v in ipairs(ent.OM_Kolossos_HitList) do
                            if v == hitEnt then ishitentity = true end
                        end 
                        if ishitentity then
                            return false
                        end
                        return true
                    end
                })

                if tr.Hit then
                    ply:SetNW2Float("OM_SetVelocity_pos", 0)
                    ply:SetLocalVelocity(Vector(0,0,0))
                    ply:SetVelocity(Vector(0,0,0))
                    if SERVER then
                        --chargestart_Kolossoschargestart_Kolossos
                        ent:SetNW2Float("end_speer_duration",0)
                        ent:SetNW2Float("Charging_kolossos",0)
                        ent:SetNW2Float("Charging_kolossos_losecontrol", 0)
                        ply:SetNW2Float("OM_MoveForward", 0.2)
                        ply:SetNW2Float("NoJumpingCooldown_OM", 0.2)
                        ent:SetNW2Float("Kolossos_considered_slam", CurTime()+0.2)
                        ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1.65)
                        ent:SetNW2Float("IdentifiedAsCrash_kolossos_wall", CurTime() + 0.2)

                        for _, ent2 in ipairs(ent.OM_Kolossos_HitList) do
                            if !IsValid(ent2) then return end
                            
                            KillerdamagestunDynamic({
                                ply = ply,
                                target = ent2,
                                DamageNumb = 10,
                                damagetype = DMG_CLUB,
                                CustomDamageSound = nil,
                                damagesound = true,
                                ShouldBlood = true,
                                flingremoveal = true,
                                ShouldBloodEffect = true
                            })

                        end

                        if #ent.OM_Kolossos_HitList > 0 then
                        end

                        AdvancedPillSound({
                            stringe = "OM/kolossos/Kol wall bump.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 76
                        }, ent)

                        AdvancedPillSound({
                            stringe = "OM/kolossos/Sound.mp3",
                            pitchPercent = 100,
                            volume = 2,
                            soundLevel = 100
                        }, ent)

                        local hitNormal = tr.HitNormal

                        if math.abs(hitNormal.z) < 0.25 then
                            local cylinder = ents.Create("prop_dynamic")
                            cylinder:SetModel("models/Noodles/OM/End/Shovel.mdl")
                            cylinder:SetPos(tr.HitPos + tr.HitNormal * -5)
                            cylinder:SetAngles( (tr.HitPos - (tr.HitPos + tr.HitNormal)):Angle() )

                            cylinder:Spawn()

                            ent:DeleteOnRemove(cylinder)

                            ply:SetLocalVelocity(Vector(0,0,1000))

                            ent:SetNW2Bool("end_om_hasshovel", false)
                            ent:GetPuppet():SetBodygroup(1,0)

                            local ed = EffectData()
                            ed:SetOrigin(tr.HitPos + tr.HitNormal * 30)

                            util.Effect("kolossos_impact_effect", ed, true, true)

                            --ent:GetPuppet():SetNW2Float("MetalSonicbump_highlight", CurTime()+0.5)
                            --ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5)

                            timer.Simple(5,function()
                                if !IsValid(cylinder) then return end
                                cylinder:SetModelScale(0.01, 0.75)
                                timer.Simple(0.75,function()
                                    if !IsValid(cylinder) then return end
                                    cylinder:Remove()
                                end)
                            end)
                            ent:SetNW2Float("shovel_cd_end", CurTime() + 10)
                        end
                    end
                else




                end


                if not ent.end_speer_duration_bool then
                    ent.end_speer_duration_bool = true 
                    ply:SetGravity(0.3)
                end

            else
                if ent.end_speer_duration_bool then
                    ent.end_speer_duration_bool = false
                end
                if ent.end_speer_duration_bool then
                    ent.end_speer_duration_bool = false 
                    ent:SetNW2Float("ShovelSpinning_cd_end", CurTime() + 15)
                    ply:SetGravity(1)
                end
            end

            if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then
                aabilityinuse = true
                if not ent.ShovelSpinning_duration then
                    ent.ShovelSpinning_duration = true
                    ent.ShovelSpinning_duration_StartAngle = Angle(0, ent:GetPuppet():GetAngles().y, 0)
                end

                ent.ShovelSpinning_duration_StartAngle = ent.ShovelSpinning_duration_StartAngle + Angle(0, 25, 0)

                ent:SetNW2Angle("pill_assignedangle", ent.ShovelSpinning_duration_StartAngle)


                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)

                if not ent.shovelspinning_swing_cd or ent.shovelspinning_swing_cd < CurTime() then

                    AdvancedPillSound(
                        {
                            stringe = "weapons/iceaxe/iceaxe_swing1.wav",
                            pitchPercent = 60,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    AdvancedPillSound(
                        {
                            stringe = "npc/fast_zombie/claw_miss2.wav",
                            pitchPercent = 90,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    AdvancedPillSound(
                        {
                            stringe = "npc/fast_zombie/claw_miss1.wav",
                            pitchPercent = 70,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent.shovelspinning_swing_cd = CurTime() + 0.25

                    local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                    for _, ent2 in pairs(ents.FindInSphere(attackPos, 120)) do
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                            if not GetConVar("PVPStun_OM_exe"):GetBool() then
                                if ent2:GetNW2Bool("OM_character_monster") then continue end
                            end

                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                            if not Mutal_OMCanDamage(ply, ent, ent2) then continue end
                            
                            KillerdamagestunDynamic({
                                ply = ply,
                                target = ent2,
                                DamageNumb = 8,
                                damagetype = DMG_CLUB,
                                CustomDamageSound = nil,
                                damagesound = true,
                                ShouldBlood = true,
                                flingremoveal = true,
                                ShouldBloodEffect = true
                            })

                            AdvancedPillSound(
                                {
                                    stringe = {"OM/end/HeavyHitter1.wav","OM/end/HeavyHitter2.wav"},
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                        end
                    end

                end
            else
                if ent.ShovelSpinning_duration then
                    ent.ShovelSpinning_duration = false
                    ent:SetNW2Float("ShovelSpinning_cd_end", CurTime() + 25) 
                end
            end

            if ent:GetNW2Float("end_diving_ability1_duration") > CurTime() then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)

                ply:SetGravity(0.4)
                if not ent.DivingAbility then
                    ent.DivingAbility = true
                end
            else
                if ent.DivingAbility then
                    ply:SetGravity(1)
                    ent.DivingAbility = false
                end
            end

            if not ent:GetNW2Bool("end_dive_ability1_activated") then 

                --SetColorSetColor
                ent.end_diving_ability1_duration_inportal_lerpcolor = ent.end_diving_ability1_duration_inportal_lerpcolor or 1

                if ent:GetNW2Float("end_diving_ability1_duration_inportal") > CurTime() then
                    ent.end_diving_ability1_duration_inportal_lerpcolor = Lerp(FrameTime()*11, ent.end_diving_ability1_duration_inportal_lerpcolor, 0)
                else
                    ent.end_diving_ability1_duration_inportal_lerpcolor = 1
                end
                ent:GetPuppet():SetColor(Color(255* ent.end_diving_ability1_duration_inportal_lerpcolor,255* ent.end_diving_ability1_duration_inportal_lerpcolor,255* ent.end_diving_ability1_duration_inportal_lerpcolor,255* ent.end_diving_ability1_duration_inportal_lerpcolor))

                if ent:GetNW2Bool("Bool_toggle_Invisible_2011x_om") then
                    ply:SetNW2String("TerrorRadius_om","OM/music/endterrorradius.wav")
                    ply:SetNW2String("chasemusic_life1_om","OM/music/endchase.wav")
                    ply:SetNW2String("chasemusic_life2_om","OM/music/endlastlife.wav")
                    
                    if bit.band(ply:GetFlags(), FL_NOTARGET) ~= 0 then
                        ply:RemoveFlags(FL_NOTARGET)
                    end

                    ent:SetNW2Bool("Bool_toggle_Invisible_2011x_om", false)

                    timer.Simple(0.4,function()
                        if !IsValid(ent) then return end

                        local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                        for _, ent2 in pairs(ents.FindInSphere(attackPos, 130)) do
                            if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                                if ent2 == ply then continue end
                                if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                                if not GetConVar("PVPStun_OM_exe"):GetBool() then
                                    if ent2:GetNW2Bool("OM_character_monster") then continue end
                                end

                                if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                                if not Mutal_OMCanDamage(ply, ent, ent2) then continue end
                                
                                KillerdamagestunDynamic({
                                    ply = ply,
                                    target = ent2,
                                    DamageNumb = 45,
                                    damagetype = DMG_CLUB,
                                    CustomDamageSound = nil,
                                    damagesound = true,
                                    ShouldBlood = true,
                                    flingremoveal = true,
                                    ShouldBloodEffect = true
                                })

                                ent2:SetNW2Float("end_afterimage_debuff_duration", CurTime()+6)
                                ent2:SetNW2Float("end_afterimage_debuff_duration_slowness_35", CurTime()+6)

                                local last = CurTime() + 1.5
                                local flung = false
                                local enemyragdoll = CreateRagdolLCharacter_OM({
                                    target = ent2,
                                    host = ent,

                                    shouldremove = function(createfakeragdoll)
                                        if not IsValid(createfakeragdoll) then return true end
                                        if not IsValid(ent2) then return true end

                                        if last < CurTime() then return true end

                                        return false
                                    end,

                                    shoulddocustomfunction = function(createfakeragdoll)
                                        if not IsValid(createfakeragdoll) then return end
                                        if not IsValid(ent2) then return end
                                        if flung then return end
                                        flung = true
                                        local dir = (ent2:GetPos() - ply:GetPos()):GetNormalized()


                                        for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                            local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                            if IsValid(phys) then
                                                phys:Wake()
                                                phys:SetVelocityInstantaneous(dir*1350)
                                            end
                                        
                                        end
                                    end
                                })

                            end
                        end
                    end)

                end
            else
                ent:GetPuppet():SetRenderMode(RENDERMODE_TRANSCOLOR)
                ent:GetPuppet():SetColor(Color(255,255,255,0))
                ent:SetNW2Float("ScanForEntities_OM", CurTime() + 2)

                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)

                if not ent:GetNW2Bool("Bool_toggle_Invisible_2011x_om") then
                    
                    ply:SetNW2String("TerrorRadius_om","")
                    ply:SetNW2String("chasemusic_life1_om","")
                    ply:SetNW2String("chasemusic_life2_om","")
                    
                    ply:AddFlags(FL_NOTARGET)
                    ent:SetNW2Bool("Bool_toggle_Invisible_2011x_om", true)
                end
            end



            if ent:GetNW2Bool("HoldingSpaceClimb") and not ply:IsOnGround() then
                local startPos = ply:GetPos()
                local endPos = startPos + ent:GetPuppet():GetForward() * 65

                local tr = util.TraceLine({
                    start = startPos,
                    endpos = endPos,
                    filter = ply,
                    mask = MASK_SOLID
                })

                if tr.Hit then
                    local climbspeed = 4

                    if ent:GetNW2Bool("HoldingSpaceClimbClimb_up") then
                        climbspeed = climbspeed + 500
                    end
                    if ent:GetNW2Bool("HoldingSpaceClimbClimb_down") then
                        climbspeed = climbspeed -500
                    end

                    ent:SetNW2Bool("Kolossos_Climbing", true)

                    if ply:IsNextBot() then
                        ply:SetVelocity(Vector(0,0,climbspeed))
                    end
                    ply:SetLocalVelocity(Vector(0,0,climbspeed))
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.2)
                else
                    if ent:GetNW2Bool("Kolossos_Climbing") then
                        ply:SetGravity(1)
                        if ply:IsNextBot() then
                            ply:SetVelocity(Vector(0,0,15)+ply:GetForward()*300)
                        end
                        ply:SetLocalVelocity(Vector(0,0,15)+ply:GetForward()*300)
                    end
                    ent:SetNW2Bool("Kolossos_Climbing", false)
                end
            else
                ent:SetNW2Bool("Kolossos_Climbing", false)
            end



            if ent:GetNW2Bool("end_dive_ability2_activated") and not ent:GetNW2Bool("end_dive_display") then 

                if ent:GetNW2Float("end_bubbleduration") < CurTime() then
                    ent:SetNW2Float("RETURNAL_cd_end", CurTime() + 30)

                    ent:SetNW2Bool("end_dive_ability2_activated", false)
                    ent:GetPuppet():RemoveGesture(ACT_BARNACLE_PULL)

                    local velocity = ply:GetVelocity()
                    local last = CurTime() + 3
                    local flung = false
                    local enemyragdoll = CreateRagdolLCharacter_OM({
                        target = ply,
                        host = ent,

                        shouldremove = function(createfakeragdoll)
                            if not IsValid(createfakeragdoll) then return true end
                            if not IsValid(ent) then return true end

                            if last < CurTime() then return true end

                            return false
                        end,

                        shoulddocustomfunction = function(createfakeragdoll)
                            if not IsValid(createfakeragdoll) then return end
                            if not IsValid(ent) then return end
                            if flung then return end
                            flung = true
                            local dir = ent:GetPuppet():GetForward()*-1
                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                if IsValid(phys) then
                                    phys:Wake()
                                    phys:SetVelocityInstantaneous(dir*400 + velocity)
                                end
                            
                            end
                        end
                    })

                end
                ent:GetPuppet():SetNW2Float("end_bubble_formation", CurTime()+0.2)
            end


            if not aabilityinuse then
                if ent.DamageAmount_om_end and ent.DamageAmount_om_end >= 75 then
                    ent:SetNW2Float("shovel_cd_end", CurTime() + 20)
                    ent.DamageAmount_om_end = 0
                    ent:SetNW2Bool("end_om_hasshovel", false)
                    ent:GetPuppet():SetBodygroup(1,0)
                elseif not ent.DamageAmount_om_end then
                    ent.DamageAmount_om_end = 0
                end
            end
            
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") > CurTime() or ent:GetNW2Float("OM_executionanim") > CurTime() then
                ply:SetNW2Float("OM_Damage_Reduction",0)
            else
                ply:SetNW2Float("OM_Damage_Reduction",1)
            end
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply,ent,button)
        if SERVER then
            if button == KEY_SPACE then
                if ent:GetNW2Bool("Kolossos_Climbing") then
                else
                    ent:SetNW2Bool("HoldingSpaceClimb", false)
                end

                ent:SetNW2Bool("holdingravity_holding", false)
                ent:SetNW2Bool("HeldGlideJump_jump", false)
                ent:SetNW2Bool("HeldGlideJump_jump_notwork", true)
            end
            if button == KEY_W then
                ent:SetNW2Bool("HoldingSpaceClimbClimb_up", false)
            end
            if button == KEY_S then
                ent:SetNW2Bool("HoldingSpaceClimbClimb_down", false)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply, ent, button)
        if SERVER then

            if button == KEY_SPACE then
                if ent:GetNW2Bool("end_dive_ability1_activated") then 
                    --[[
                    if ply:IsOnGround() then else
                        ent:SetNW2Bool("Glide", true)
                    end
                    ]]
                    
                    if ent:GetNW2Float("grabbing_kolossos", 0 ) > CurTime() then return end
                    if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                    if ent:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end
                    if ent:GetNW2Float("Charging_kolossos") > CurTime() then return end
                    if ent:GetNW2Float("chargestart_Kolossos") > CurTime() then return end
                    
                    if IsValid(ent:GetNW2Entity("grabbingEnt_kolossos")) and ent:GetNW2Float("grabbing_duration_kolossos") > CurTime() then return end
                    
                    ent:SetNW2Bool("HoldingSpaceClimb", true)
                end

                if ent:GetNW2Bool("Kolossos_Climbing") then
                    ply:SetLocalVelocity(Vector(0,0,185)+ply:GetForward()*-200)
                    ent:SetNW2Bool("HoldingSpaceClimb", false)
                else
                end
            end
            if button == KEY_W then
                ent:SetNW2Bool("HoldingSpaceClimbClimb_up", true)
            end
            if button == KEY_S then
                ent:SetNW2Bool("HoldingSpaceClimbClimb_down", true)
            end

            if button == KEY_SPACE then
                if ent:GetNW2Float("JetpackJumpCooldown") > CurTime() then return end
                ent:SetNW2Float("HeldGlideJump_duration", CurTime()+0.25)

                ent:SetNW2Bool("HeldGlideJump_jump", true)
            end

            if button == KEY_E then
                    
                if ent:GetNW2Bool("Kolossos_Climbing") then return end

                if ent:GetNW2Bool("end_om_hasshovel") then
                    if ent:GetNW2Float("ShovelSpinning_cd_end") > CurTime() then return end
                    if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return end
                    if ent:GetNW2Float("AmountsOfHoles_OM_end") <= 0 then return end
                    if ent:GetNW2Float("end_speer_duration") > CurTime() then return end
                    
                    if ply:IsOnGround() then
                        ent:SetNW2Float("ShovelSpinning_duration", CurTime() + 8)
                    else
                        --ent:SetNW2Bool("End_gliding", true)
                        ent.end_speer_durationDirection = ply:GetAimVector()
                        ent:SetNW2Float("end_speer_duration", CurTime() + 3)
                        --[[
                        AdvancedPillSound(
                            {
                                stringe = "OM/end/End_spear.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        ]]
                    end
                else
                    if ent:GetNW2Float("SATURATEDGRIEF_cd_end") > CurTime() then return end

                    if not ply:IsOnGround() then return end

                    if not ent:GetNW2Bool("end_dive_ability1_activated") then 
                        --[[
                        AdvancedPillSound(
                            {
                                stringe = "OM/end/End_enterportal.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        ]]
                        ent:PillAnim("portalspawn")
                        local seq = ent:GetPuppet():LookupSequence("portalspawn")
                        local duration = ent:GetPuppet():SequenceDuration(seq)
                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + duration)
                        ent:SetNW2Float("end_diving_ability1_duration", CurTime() + duration+0.5)
                        ply:SetLocalVelocity(Vector(0,0,0))
                        ply:SetVelocity(Vector(0,0,0))

                        local puppet = ent:GetPuppet()
                        local cylinder 
                        timer.Simple(0.5, function()
                            if not IsValid(ent) then return end

                            cylinder = ents.Create("prop_dynamic")

                            local pos = ply:GetPos()

                            local tr = util.TraceLine({
                                start = pos + Vector(0, 0, 50),
                                endpos = pos - Vector(0, 0, 200),
                                filter = {ply, ent, puppet}
                            })

                            local ang = Angle(0, 0, 0)

                            if tr.Hit then
                                ang = tr.HitNormal:Angle()
                                ang:RotateAroundAxis(ang:Right(), 90)
                            end

                            cylinder:SetModel("models/hunter/tubes/circle2x2.mdl")
                            cylinder:SetPos(tr.HitPos or pos)
                            cylinder:SetAngles(ang)

                            cylinder:Spawn()

                            cylinder:SetColor(Color(0, 0, 0, 255))
                            cylinder:SetMaterial("models/debug/debugwhite")

                            ent:DeleteOnRemove(cylinder)

                            cylinder:SetModelScale(0.01, 0)
                            cylinder:SetModelScale(0.4, 0.25)
                        end)
                        timer.Simple(0.8,function()
                            if !IsValid(ent) then return end
                            ent.ModelFadeOutcolor = true
                            ent:SetNW2Float("end_diving_ability1_duration_inportal", CurTime() + 2)
                            cylinder:SetModelScale(0.8, 0.25)
                        end)
                        timer.Simple(duration,function()
                            if !IsValid(ent) then return end
                            ent:SetNW2Bool("end_dive_ability1_activated", true)
                        end)
                        timer.Simple(duration*6,function()
                            if !IsValid(ent) then return end
                            if IsValid(cylinder) then 
                                cylinder:SetModelScale(0, 3)

                                timer.Simple(3,function()
                                    if !IsValid(cylinder) then return end
                                    cylinder:Remove()
                                end)
                            end
                        end)
                        ent:SetNW2Float("SATURATEDGRIEF_cd_end", CurTime() +7)
                    else
                        ent:SetNW2Float("SATURATEDGRIEF_cd_end", CurTime() +25)

                        -- the ability

                        ent:SetNW2Bool("end_dive_ability1_activated", false)
                        ent:PillAnim("portalend")
                        local seq = ent:GetPuppet():LookupSequence("portalend")
                        local duration = ent:GetPuppet():SequenceDuration(seq)
                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + duration)
                        ent:SetNW2Float("end_emerge_ability1_duration", CurTime() + duration+0.5)
                        ply:SetLocalVelocity(Vector(0,0,0))
                        ply:SetVelocity(Vector(0,0,0))

                        local puppet = ent:GetPuppet()
                        local cylinder = ents.Create("prop_dynamic")

                        local pos = ply:GetPos()

                        local tr = util.TraceLine({
                            start = pos + Vector(0, 0, 50),
                            endpos = pos - Vector(0, 0, 200),
                            filter = {ply, ent, puppet}
                        })

                        local ang = Angle(0, 0, 0)

                        if tr.Hit then
                            ang = tr.HitNormal:Angle()
                            ang:RotateAroundAxis(ang:Right(), 90)
                        end

                        cylinder:SetModel("models/hunter/tubes/circle2x2.mdl")
                        cylinder:SetPos(tr.HitPos or pos)
                        cylinder:SetAngles(ang)

                        cylinder:Spawn()

                        cylinder:SetColor(Color(0, 0, 0, 255))
                        cylinder:SetMaterial("models/debug/debugwhite")

                        ent:DeleteOnRemove(cylinder)

                        cylinder:SetModelScale(0.01, 0)
                        cylinder:SetModelScale(0.7, 0.25)

                        timer.Simple(duration,function()
                            if !IsValid(ent) then return end
                            if IsValid(cylinder) then 
                                cylinder:Spawn()
                                cylinder:SetModelScale(0, 0.45)

                                timer.Simple(0.45,function()
                                    if !IsValid(cylinder) then return end
                                    cylinder:Remove()
                                end)

                            end
                        end)
                    end
                end
            end


            if button == KEY_R then 
                if ent:GetNW2Bool("end_om_hasshovel") then
                else
                    if ent:GetNW2Float("RETURNAL_cd_end") > CurTime() then return end

                    if ent:GetNW2Bool("end_dive_ability1_activated") then return end
                    if ent:GetNW2Bool("end_dive_ability2_rebound") then return end
                    if ent:GetNW2Float("end_diving_ability1_duration") > CurTime() then return end
                    if ent:GetNW2Float("end_emerge_ability1_duration") > CurTime() then return end

                    local puppet = ent:GetPuppet()
                    if not ent:GetNW2Bool("end_dive_ability2_activated") then 
                        ent:SetNW2Float("end_dive_ability2_activated_activate", CurTime() + 0.5)

                        ent:SetNW2Float("end_bubbleduration", CurTime() + 15)
                        ent:SetNW2Bool("end_dive_ability2_activated", true)
                        ent:SetNW2Bool("end_dive_ability2_rebound", true)
                        ent:SetNW2Bool("end_dive_display", true)
                        local layeredAnim = puppet:AddGesture(ACT_BARNACLE_HIT, false)

                        puppet:SetLayerWeight(layeredAnim, 1)
                        puppet:SetLayerPriority(layeredAnim, 10)

                        local playbackRate = 1
                        puppet:SetLayerPlaybackRate(layeredAnim, playbackRate)

                        timer.Simple(0.45,function()
                            if !IsValid(ent) then return end
                            ent:SetNW2Bool("end_dive_display", false)

                            local fx = EffectData()
                            fx:SetOrigin(ent:GetPos()+Vector(0,0,40))

                            util.Effect("end_createbubble", fx, true, true)
                        end)

                        timer.Simple(0.9,function()
                            if !IsValid(ent) then return end
                            puppet:RemoveLayer(puppet:FindGestureLayer(ACT_BARNACLE_HIT))
                            puppet:AddGesture(ACT_BARNACLE_PULL, false)
                            ent:SetNW2Bool("end_dive_ability2_rebound", false)
                        end)
                    end
                end
            end

            if button == KEY_T then
                    
                if ent:GetNW2Bool("Kolossos_Climbing") then return end
                
                if ent:GetNW2Float("shovel_cd_end") > CurTime() then return end
                if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return end
                if ent:GetNW2Bool("end_dive_ability1_activated") then return end
                if ent:GetNW2Bool("end_dive_ability2_rebound") then return end
                if ent:GetNW2Bool("end_dive_ability2_activated") then return end
                if ent:GetNW2Float("end_diving_ability1_duration") > CurTime() then return end
                if ent:GetNW2Float("end_emerge_ability1_duration") > CurTime() then return end
                if ent:GetNW2Float("Shoveldigging_duration") > CurTime() then return end
                --if ent:GetNW2Bool("End_gliding") then return end
                if ent:GetNW2Float("end_speer_duration") > CurTime() then return end

                if ent:GetNW2Bool("end_om_hasshovel") then 
                    ent:SetNW2Bool("end_om_hasshovel", false)
                    ent:GetPuppet():SetBodygroup(1,0)
                    ent.DamageAmount_om_end = 0
                else
                    ent:GetPuppet():SetBodygroup(1,1)
                    ent:SetNW2Bool("end_om_hasshovel", true)
                end

                ent:SetNW2Float("shovel_cd_end", CurTime() + 5)
            end

        end
    end,

    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if SERVER then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("end_dive_ability1_activated") then return end

                local puppet = ent:GetPuppet()
                if IsValid(puppet) then

                    local layeredAnim
                    local type

                    if ent:GetNW2Bool("end_om_hasshovel") then 
                        ent:SetNW2Float("AttackCooldown_OM", CurTime() + 5.5)
                        ent:SetNW2Float("end_m1_swingboost", CurTime() + 0.24)
                        type = 1
                        layeredAnim = puppet:AddGesture(ACT_GESTURE_MELEE_ATTACK2, false)
                        
                        AdvancedPillSound(
                            {
                                stringe = "OM/end/shovelm1.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    else
                        ent:SetNW2Float("AttackCooldown_OM", CurTime() + 2.5)
                        type = 2
                        layeredAnim = puppet:AddGesture(ACT_MELEE_ATTACK_SWING_GESTURE, false)
                
                        AdvancedPillSound(
                            {
                                stringe = "OM/fleetway/Fleetway m1 swing.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end

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

                    timer.Simple(0.35, fadeLayer)

                    timer.Simple(0.9,function()
                        if !IsValid(ent) then return end
                        puppet:RemoveLayer(puppet:FindGestureLayer(ACT_MELEE_ATTACK_SWING_GESTURE))

                        if type == 1 then 
                            puppet:RemoveLayer(puppet:FindGestureLayer(ACT_GESTURE_MELEE_ATTACK2))
                        else
                            puppet:RemoveLayer(puppet:FindGestureLayer(ACT_MELEE_ATTACK_SWING_GESTURE))
                        end
                    end)
                end


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
        if ent:GetNW2Bool("end_dive_ability1_activated") then return end
        if ent:GetNW2Float("ShovelSpinning_duration") > CurTime() then return end

        AdvancedPillSound(
            {
                stringe = "OM/Jump.wav",
                pitchPercent = 100,
                volume = 1,
                soundLevel = 87
            },
            ent
        )

        ent:SetNW2Float("jump_animdur", CurTime()+0.1)
        ent:SetNW2Bool("JetpackJump", true)
    end
})