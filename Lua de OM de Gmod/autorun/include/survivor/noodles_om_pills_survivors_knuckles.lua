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
    ["Knuckles_OM_noodles_punch"] = Material("icons/Knuckles_OM_noodles_punch.png"),
    ["Knuckles_OM_noodles_counter"] = Material("icons/Knuckles_OM_noodles_counter.png"),
}

pk_pills.register('pill_om_knuckles', {

    printName='Knuckles',
    Outcomememories='Knuckles',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/knuckles.mdl",
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

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Knuckles_OM_noodles_punch"]
            end,
            name = function(uselessvar,ply,ent)
                return "Punch"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Knuckles_Punch_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("PunchCooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("PunchCooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.02, yaxis = 0+ iconsize*0.0, xsize = 0, ysize = 0}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Knuckles_OM_noodles_counter"]
            end,
            name = function(uselessvar,ply,ent)
                return "Counter"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Knuckles_Counter_key", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("CounterOM_cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("CounterOM_cooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.02, yaxis = 0+ iconsize*0.01, xsize = 0, ysize = 0}
            end,
            survivor = true,
            font = "CreditsText",
        }
    },
    
    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            if ent:GetNW2Bool("OM_Knuckles_punchReady") and ply:GetInfoNum("om_pills_knuckles_custombar", 1) == 1 then
                return false
            end
        end,
        colorbar = function(uselessvar,ply,ent)
            return Color(255, 0, 0, 255)
        end,
        progression = function(uselessvar,ply,ent)
            local factor = math.Clamp( ((CurTime()-(ent:GetNW2Float("PunchDuration")-3))*-1)/6, 0, 1)
            local lerp = Lerp(factor,100,0)
            return lerp
        end,
        maximumbar = function(uselessvar,ply,ent)
            return 100
        end,
    },

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            LatchOff = "LatchOff",
            attack = "attack",
            jump2 = "jump",
            GroundSmash="GroundSmash",
            PunchAnim = "PunchAnim",
        },
        ShouldMoveRotate={
            idle= function(ent) 
                if not ent:GetNW2Bool("OM_Knuckles_punchReady") then return 'notanything'
                else return "shiftlock" end
            end,
            GroundSmash= function(ent) 
                if not ent:GetNW2Bool("OM_Knuckles_punchReady") then return 'notshftlock'
                else return "shiftlock" end
            end,
            PunchAnim= function(ent) 
                if not ent:GetNW2Bool("OM_Knuckles_punchReady") then return 'notshftlock'
                else return "shiftlock" end
            end,
            run= function(ent) 
                if not ent:GetNW2Bool("OM_Knuckles_punchReady") then return 'notshftlock'
                else return "shiftlock" end
            end,
            walk= function(ent) 
                if not ent:GetNW2Bool("OM_Knuckles_punchReady") then return 'notshftlock'
                else return "shiftlock" end
            end,
            fall= function(ent) 
                local ply = ent:GetPillUser()
                if not ply:IsOnGround() then if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "assignedagnles" end end
                if ent:GetNW2Float('GlideDuration') > CurTime() then return "shiftlock"
                elseif ent:GetNW2Bool("OM_Knuckles_punchFallanim") then return 'shiftlock' end
                if not ent:GetNW2Bool("OM_Knuckles_punchReady") then return 'notshftlock'
                else return "shiftlock" end
            end,
            jump= function(ent) 
                if ent:GetNW2Bool("OM_Knuckles_punchFallanim") or ent:GetNW2Float("CounterOM_duration2") > CurTime() then return 'notshftlock' end
                return 'notshftlock'
            end,
            attack= function(ent) 
                return 'shiftlock'
            end,
            LatchOff= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Bool("OM_Knuckles_punchFallanim") or ent:GetNW2Float("CounterOM_duration2") > CurTime() then return 'notshftlock' end
                if ent:GetNW2Float('GlideDuration') > CurTime() then return "shiftlock" end
                if not ply:IsOnGround() then if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "assignedagnles" end end
                if not ent:GetNW2Bool("OM_Knuckles_punchReady") then return 'notshftlock'
                else return "notshftlock" end
            end,
            FallAttack= function(ent) 
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            idle= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("OM_Knuckles_punchReady") then return 'AttackIdle' end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "idle_lowhealth"
                end 
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("OM_Knuckles_punchReady") then return 'attackwalk' end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "walk_lowhealth"
                end 
            end,
            fall= function(ent) 
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then return "latch" end
                if not ent:GetNW2Bool("OM_Knuckles_punchFallanim_loseanim") then
                    if ent:GetNW2Bool("OM_Knuckles_punchFallanim") then return 'FallAttack' end
                end
                if ent:GetNW2Float('GlideDuration') > CurTime() then return "glide" end
                
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("OM_Knuckles_punchReady") then return 'attackwalk' end
                if ent:GetNW2Float("CounterOM_duration2") > CurTime() then return 'walk' end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "run_lowhealth"
                end 
            end,
        },
    },
    
    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Knuckles_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Knuckles_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Knuckles_walk"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Knuckles_jumppower"):GetFloat()
                end
            end,
            glide=function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Knuckles_glide"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Knuckles_jumpcd"):GetFloat()
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Knuckles_rollingPower"):GetFloat()
                end
            end,
        },
        abilities = {
            ["Punch"] = {
                ["ActivationKey"] = KEY_E,
                ["CooldownHit"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_cooldown"):GetFloat()
                    end
                end,
                ["CooldownCancel"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_cooldown_cancel"):GetFloat()
                    end
                end,
                ["StunEffect"] = function(ply, ent, ent2, additives, damage, punch) --
                    Mutaul_OMStunCode(
                        {
                            ["ply"] = ply,
                            ["ent"] = ent,
                            ["target"] = ent2,
                            ["StunDur"] = GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_basestun"):GetFloat() + additives,
                            ["stunfunction"] = function(shouldstundamage)
                                if shouldstundamage then
                                    if additives == 2 then
                                        OM_burntarget(ply,ent2,8, true)
                                    end

                                    AdvancedPillSound(
                                        {
                                            stringe = "OM/knuckles/punchstun.wav",
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        ent
                                    )
                                    local ed = EffectData()
                                    ed:SetOrigin(ent2:GetPos()+Vector(0,0,30))
                                    util.Effect("Knuckles_punch_OM", ed)

                                    ent2:SetVelocity( ply:GetVelocity():GetNormalized()*750 * (additives + 1) )

                                    ent.AlternatePlaySolution = true
                                    ent:PillAnim('PunchAnim')
                                    ent.AlternatePlaySolution = false
                                end
                            end,
                            ["shouldstack"] = true,
                            ["Damage"] = damage,
                            ["DamageType"] = DMG_GENERIC
                        }
                    )
                end
            },
            ["Counter"] = {
                ["cooldownSucess"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_cooldownSucess"):GetFloat()
                    end
                end,
                ["cooldownFail"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_cooldownFail"):GetFloat()
                    end
                end,
                ["StunEffect"] = function(ply, ent, damager, amount, additives)
                    Mutaul_OMStunCode(
                        {
                            ["ply"] = ply,
                            ["ent"] = ent,
                            ["target"] = damager,
                            ["StunDur"] = GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_basestun"):GetFloat()+amount,
                            ["stunfunction"] = function(shouldstundamage)
                                if shouldstundamage then
                                    if additives == 2 then
                                        OM_burntarget(ply,damager,7, true)
                                    end
                                    
                                    local ed = EffectData()
                                    ed:SetOrigin(damager:GetPos())
                                    util.Effect("Knuckles_punch_OM", ed)

                                    local last = CurTime() + 2
                                    local flung = false

                                    if SERVER then
                                        if GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_canragdollstun"):GetBool() then
                                            local enemyragdoll = CreateRagdolLCharacter_OM({
                                                target = damager,
                                                host = ent,

                                                shouldremove = function(createfakeragdoll)
                                                    if not IsValid(createfakeragdoll) then return true end
                                                    if not IsValid(damager) then return true end
                                                    if not IsValid(ent) then return true end

                                                    local pos = createfakeragdoll:GetPos()
                                                        
                                                    local tr = util.TraceLine({
                                                        start = pos,
                                                        endpos = pos - Vector(0, 0, 10),
                                                        filter = createfakeragdoll
                                                    })

                                                    if (last < CurTime() and tr.Hit ) or damager:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime() then
                                                        return true
                                                    else
                                                        if not tr.Hit then
                                                            last = CurTime() + 2.5
                                                        end
                                                    end
                                                    return false
                                                end,

                                                shoulddocustomfunction = function(createfakeragdoll)
                                                    if not IsValid(createfakeragdoll) then return end
                                                    if not IsValid(ent) then return end
                                                    if flung then return end
                                                    flung = true

                                                    local ragPos = createfakeragdoll:GetPos()
                                                    local entPos = ent:GetPos()

                                                    local dir = (ragPos - entPos):GetNormalized()

                                                    local force = damager:GetVelocity()+ dir * 300 + Vector(0, 0, 259)

                                                    local phys = createfakeragdoll:GetPhysicsObject()
                                                    if IsValid(phys) then
                                                        phys:SetVelocity(force)
                                                        phys:AddAngleVelocity(VectorRand() * 300)
                                                    end

                                                    for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                        local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                        if IsValid(bonePhys) then
                                                            bonePhys:SetVelocity(force)
                                                            bonePhys:AddAngleVelocity(VectorRand() * 300)
                                                        end
                                                    end
                                                end
                                            })
                                        end
                                    end
                                end
                            end,
                            ["shouldstack"] = true,
                            ["Damage"] = GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_basedamage"):GetFloat(),
                            ["DamageType"] = DMG_CLUB,
                            ["Counter"] = true
                        }
                    )
                end
            }
        },
    },

    OM_cameratable = function(ply,ent)
        local basetable =  {
            startoffset = Vector(20,0,25),  -- left-up, front-back, up-down
            dist=145,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 1,
            id = 0,
            transition = 1,
            canscroll = true,
			bonecenter = "UpperTorso",
        }

        if ply:GetInfoNum("om_pills_action_camera_Knuckles", 1) == 1 then
            if ent:GetNW2Bool("OM_Knuckles_punchReady") then
                basetable =  {
                    startoffset = Vector(35,0,20),  -- left-up, front-back, up-down
                    dist=65,
                    fov = ply:GetInfoNum("om_pills_default_fov", 80)-10,
                    id = 1,
                    transition = 1,
                    canscroll = true,
                    bonecenter = "UpperTorso",
                }
            end
        end


        if ply:GetNW2Bool("Survivor_Downed_OM") then
            basetable =  {
                startoffset = Vector(45,0,25),  -- left-up, front-back, up-down
                dist=50,
                fov = ply:GetInfoNum("om_pills_default_fov", 80)*0.85,
                id = 67,
                transition = 1,
                canscroll = false,
            }
        end

        return basetable
    end,


    speedhandeler_om = {
        modifiers = {
            ['punch'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }
                if ent:GetNW2Bool("OM_Knuckles_punchReady") or ent:GetNW2Float("CounterOM_duration2") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*2 - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*2 - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk()*2 - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
        }
    },
        
    
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },
        
    --canAim=function(ply,ent) return ent.active end,     

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if event == "Step" then
            StepSFX_OM(ply,ent)
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
        if SERVER then
            initializetable2["entity"]:SetNW2Float('OM_friction', 1)
            initializetable2["entity"]:SetNW2Float("OM_Damage_Reduction",1)
            
            local health = GetConVar("OUTCOMEMEMORIES_N_Knuckles_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)
            initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
            initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)
            
                initializetable2["player"].OM_DamageBeforeCustomFunction = function(table1, table2)
                    local entityfall = table2[1]
                    local dmg = table2[2]
                    local damageamount = table2[3]
                    local ent = initializetable2["entity"]
                    local ply = initializetable2["player"]
                    
                    if !IsValid(initializetable2["entity"]) then return end
                    if initializetable2["entity"]:GetNW2Float("CounterOM_duration2") > CurTime() then
                        if damageamount > 0 then else return end

                        local damager = dmg:GetAttacker()
                        if not ( dmg:IsDamageType(DMG_CLUB) or dmg:IsDamageType(DMG_SLASH) or dmg:IsDamageType(DMG_GENERIC) or dmg:IsDamageType(DMG_CRUSH) ) then return false end
                        if IsValid(damager) then
                            if entityfall == ply then
                                if damager.CustomFunctionCancelAbility_OM then
                                    damager:CustomFunctionCancelAbility_OM()
                                end


                                AdvancedPillSound(
                                    {
                                        stringe = "OM/knuckles/CounterBounce.wav",
                                        pitchPercent = 100,
                                        volume = 0.65,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                                
                                
                                dmg:SetDamage(0)
                                dmg:SetDamageType(DMG_GENERIC)
                                ent.CounterSetCD = false
                                --timer.Simple(0.04, function()
                                    if !IsValid(ent) then return end

                                    ent:SetNW2Float("CounterOM_cooldown", CurTime()+ent.formTable.Outcomememories_stats.abilities.Counter.cooldownSucess())
                                    ent:SetNW2Float("CounterOM_cooldown_duration", ent.formTable.Outcomememories_stats.abilities.Counter.cooldownSucess())
                                    ent:SetNW2Float("CounterOM_cooldown_e", 0)
                                    ent:SetNW2Float("CounterOM_duration2", 0)
                                    ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.25*0.5)

                                    local additives = 0
                                    local additivesStunEffect = 0
                                    for i = 2, 3 do
                                        if ent:GetPuppet():GetNW2Bool("Knuckles_glow_"..i) then 
                                            additives = 1 + additives
                                            additivesStunEffect = GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_stunamount"..i-1):GetFloat() + additivesStunEffect
                                        end
                                    end
                                    ent.formTable.Outcomememories_stats.abilities.Counter.StunEffect(ply,ent,damager, additivesStunEffect,additives)


                                    local puppet = ent:GetPuppet()
                                    local layeredAnim = puppet:AddGesture(ACT_GESTURE_RANGE_ATTACK2_LOW, false)

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

                                    timer.Simple(0.5, fadeLayer)

                                    timer.Simple(1,function()
                                        if !IsValid(ent) then return end
                                        puppet:RemoveLayer(puppet:FindGestureLayer(ACT_GESTURE_RANGE_ATTACK2_LOW))
                                    end)

                                --end)

                                ent:GetPuppet():SetNW2Bool("Knuckles_glow_1", false)
                                ent:GetPuppet():SetNW2Bool("Knuckles_glow_2", false)
                                ent:GetPuppet():SetNW2Bool("Knuckles_glow_3", false)
                                return true
                            end
                        end
                    end
                end

            --OM_Knuckles_punchFallanimOM_Knuckles_punchFallanim
            initializetable2["player"].CustomFunctionForDowned_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]
                    if ent:GetNW2Bool("OM_Knuckles_punchFallanim") then
                        ent:SetNW2Float("PunchCooldown", CurTime() + ent.formTable.Outcomememories_stats.abilities.Punch.CooldownHit())
                        ent:SetNW2Float("PunchCooldown_duration", ent.formTable.Outcomememories_stats.abilities.Punch.CooldownHit())
                    end
                    ent:SetNW2Float("GlideDuration", 0)
                    ent:SetNW2Bool("OM_Knuckles_punchFallanim", false)
                    ent:SetNW2Bool("OM_Knuckles_punchShouldPunch", false)
                    ent:SetNW2Float("CounterOM_duration2", 0)
                    ent:SetNW2Float("PunchDuration", 0)
                    ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)
                    ent:SetNW2Bool("OM_Knuckles_punchReady", false)
                    ent:SetNWBool('ShouldStunning_fix', false)
                    if initializetable2["player"]:IsPlayer() then
                        initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
                    end
                end
            end
            initializetable2["player"].OM_Stun_Blockfunction = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end
            initializetable2["player"].OM_AfterStunBlock = function(DataTable, e2)
                if IsValid(initializetable2["entity"]) then
                    if not ( DataTable.DamageType == DMG_CLUB or DataTable.DamageType == DMG_SLASH ) then return false end
                    if initializetable2["entity"]:GetNW2Float("CounterOM_duration2") > CurTime() then
                        return { 
                            canceltype = "effectstun",
                            StunDur = 0,
                        }
                    end
                end
            end

        end
        initializetable2["player"]:SetNW2Bool("OM_character", true)


    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetGravity(1)
            initializetable2["player"].GotTheStun = false
        end
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)

            if not GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
            end
            if not GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
            end
            ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_Knuckles_Resistance"):GetFloat()/100)

            local hasthestun = false
            if not ply:IsOnGround() then

                if ent:GetNW2Float("GlideDuration") > CurTime() then
                    local glideg = ent.formTable.Outcomememories_stats.moveSpeed.glide(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.glide or 325
                    glideg = glideg * 1.75
                    local velo = ent:GetPuppet():GetForward()*glideg + ent:GetPuppet():GetUp()* -60
                    if ent:GetNW2Float("GlideUpDuration") > CurTime() then
                        velo = ent.Normals_latch_knuckles_OM:Forward()*glideg + ent:GetPuppet():GetUp()* 30--ent:GetPuppet():GetForward()*glideg + ent:GetPuppet():GetUp()* 30
                    end
                    if ply:IsPlayer()then
                        ply:SetLocalVelocity(velo)
                    else
                        ply:SetVelocity(velo)                    
                    end

                    ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                    ply:SetGravity(0.2)
                    ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                else
                    ply:SetGravity(1)
                end
                
                if ent:GetNW2Bool("OM_Knuckles_punchFallanim") then
                else
                    if ent:GetNW2Float('LatchesLeft') > 0 and ent:GetNW2Float("GlideUpDuration") < CurTime() then
                        if not ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then
                            local startPos = ply:GetPos()
                            local dir = ply:GetForward() * 1
                            local endPos = startPos + dir * 30

                            local tr = util.TraceLine({
                                start = startPos,
                                endpos = endPos,
                                filter = function(ent)
                                    if not IsValid(ent) then return false end

                                    if ent == ply then return false end

                                    if ent:IsPlayer() then return false end
                                    if ent:IsNPC() then return false end
                                    if ent:IsNextBot() then return false end
                                    if ent:GetClass() == "prop_ragdoll" then return false end

                                    return true
                                end,
                                mask = MASK_SOLID
                            })

                            if tr.Hit then
                                ent:SetNW2Float('LatchDuration',CurTime()+ GetConVar("OUTCOMEMORIES_N_Knuckles_Latch_duration"):GetFloat())
                                    
                                local groundTrace = util.TraceLine({
                                    start = ply:GetPos(),
                                    endpos = ply:GetPos() - Vector(0,0,900),
                                    filter = ply,
                                    mask = MASK_SOLID_BRUSHONLY
                                })

                                if groundTrace.HitPos:Distance(ply:GetPos()) > 25 then
                                    local function latching( )
                                        local plyvelocity = ply:GetVelocity()

                                        if plyvelocity.z < 0 then
                                            if GetConVar("OUTCOMEMORIES_N_Knuckles_latch_useable"):GetBool() then 
                                                --if ply:IsPlayer() then else return end
                                                
                                                local normal = tr.HitNormal

                                                if math.abs(normal.z) < 0.5 then
                                                    if ply:IsPlayer() then
                                                        ply:SetMoveType(0)
                                                    else

                                                    end
                                                    local ang = normal:Angle()
                                                    
                                                    ent.Normals_latch_knuckles_OM = ang
                                                    --ply:SetPos(tr.HitPos + tr.HitNormal * 5)
                                                    ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", true)

                                                    ply:SetVelocity(Vector(0,0,0))
                                                    ply:SetLocalVelocity(Vector(0,0,0))

                                                    AdvancedPillSound(
                                                        {
                                                            stringe = "OM/knuckles/Latch.wav",
                                                            pitchPercent = 100,
                                                            volume = 1,
                                                            soundLevel = 87
                                                        },
                                                        ent
                                                    )
                                                    ent:SetNW2Float("startPos_knuckles", startPos)
                                                    ent:SetNW2Float("endPos_knuckles", tr.HitPos)
                                                    if GetConVar("OUTCOMEMORIES_N_Knuckles_latch_haslimit"):GetBool() then
                                                        ent:SetNW2Float('LatchesLeft', ent:GetNW2Float('LatchesLeft')-1)
                                                    end

                                                    local angle = ( (tr.HitPos+ tr.HitNormal*5) - tr.HitPos ):Angle()
                                                    ent:SetNW2Angle("pill_assignedangle", angle)
                                                end
                                            end
                                        end
                                    end

                                    local hitEnt = tr.Entity
                                    if IsValid(hitEnt) then
                                        if hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:IsNextBot() then
                                        else
                                            latching()
                                        end
                                    else
                                        latching()
                                    end
                                end
                            end
                        else
                            ply:SetNW2Float("OM_NoMovement_noodles_jump", CurTime()+0.2)
                            if ply:IsPlayer() then else 
                                ply:SetVelocity(Vector(0,0,25))
                            end
                            ply:SetLocalVelocity(Vector(0,0,0))

                            ply:SetPos(ply:GetPos()+Vector(0,0,-0.15))
                            local groundTrace = util.TraceLine({
                                start = ply:GetPos(),
                                endpos = ply:GetPos() - Vector(0,0,900),
                                filter = function(ent)
                                    if not IsValid(ent) then return false end

                                    if ent == ply then return false end

                                    if ent:IsPlayer() then return false end
                                    if ent:IsNPC() then return false end
                                    if ent:IsNextBot() then return false end
                                    if ent:GetClass() == "prop_ragdoll" then return false end

                                    return true
                                end,
                                mask = MASK_SOLID_BRUSHONLY
                            })

                            local startPos = ent:GetNW2Vector("startPos_knuckles")
                            local endPos = ent:GetNW2Vector("endPos_knuckles")

                            local direction = (endPos - startPos):GetNormalized()
                            local tr = util.TraceLine({
                                start = ply:GetPos(),
                                endpos = ply:GetPos()+direction*30,
                                filter = function(ent)
                                    if not IsValid(ent) then return false end

                                    if ent == ply then return false end

                                    if ent:IsPlayer() then return false end
                                    if ent:IsNPC() then return false end
                                    if ent:IsNextBot() then return false end
                                    if ent:GetClass() == "prop_ragdoll" then return false end

                                    return true
                                end,
                                mask = MASK_SOLID
                            })

                            local dist = 30
                            if groundTrace.Hit then
                                dist = groundTrace.HitPos:Distance(ply:GetPos())
                            end
                            
                            if dist < 25 or not tr.Hit then
                                if ply:IsPlayer() then
                                    ply:SetMoveType(MOVETYPE_WALK)
                                else
                                    ply:SetMoveType(0)
                                end
                                ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)

                                local angle = ( (tr.HitPos+ tr.HitNormal*5) - tr.HitPos ):Angle()
                                ent:SetNW2Angle("pill_assignedangle", angle)
                            end
                            if ent:GetNW2Float('LatchDuration') < CurTime() then

                                if ply:IsPlayer() then
                                    ply:SetMoveType(MOVETYPE_WALK)
                                else
                                    ply:SetMoveType(0)
                                end
                                ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)
                                ent:SetNW2Float('LatchesLeft', 0)
                            end
                        end
                    end
                end
            else
                ply:SetGravity(1)
                ent:SetNW2Float('GlideDuration', 0)
                ent:SetNW2Float('LatchesLeft', GetConVar("OUTCOMEMORIES_N_Knuckles_latchcount"):GetFloat())
                ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)
                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_WALK)
                else
                    ply:SetMoveType(0)
                end
            end
            

            local jumpscare_entity = nil
            local stunfunction = function(ent, shouldplay)
                local range = 140
                if shouldplay then 
                    range = 200
                end
                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), range)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        local shouldstunstack = GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_stunstack"):GetBool()
                        if Mutual_OMCanStun(ply, ent, ent2, shouldstunstack) then
                            if not jumpscare_entity then jumpscare_entity = ent2 end
                            local additives = 0
                            local additivesStunEffect = 0
                            for i = 2, 3 do
                                if ent:GetPuppet():GetNW2Bool("Knuckles_glow_"..i) then 
                                    additives = 1 + additives
                                    additivesStunEffect = GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_stunamount"..i-1):GetFloat() + additivesStunEffect
                                end
                            end

                            ent:SetNW2Bool("OM_Knuckles_punchFallanim_loseanim", true)

                            local damage = GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_basedamage"):GetFloat()
                            if additives == 1 then
                                damage = damage+GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_damageamount1"):GetFloat()
                            elseif additives == 2 then
                                damage = damage+GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_damageamount2"):GetFloat()
                            end
                            ent.formTable.Outcomememories_stats.abilities.Punch.StunEffect(ply,ent,ent2,additivesStunEffect,damage, not shouldplay)

                            ent:SetNW2Bool("OM_Knuckles_punchShouldPunch", false)

                            if shouldplay or additives > 0 then
                                local last = CurTime() + 5.25
                                local flung = false

                                if SERVER then
                                    if GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_canragdollstun"):GetBool() then
                                        local enemyragdoll = CreateRagdolLCharacter_OM({
                                            target = ent2,
                                            host = ent,

                                            shouldremove = function(createfakeragdoll)
                                                if not IsValid(createfakeragdoll) then return true end
                                                if not IsValid(ent2) then return true end
                                                if not IsValid(ent) then return true end

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
                                                        last = CurTime() + 5.25
                                                    end
                                                end
                                                return false
                                            end,

                                            shoulddocustomfunction = function(createfakeragdoll)
                                                if not IsValid(createfakeragdoll) then return end
                                                if not IsValid(ent) then return end
                                                if flung then return end
                                                flung = true

                                                local ragPos = createfakeragdoll:GetPos()
                                                local entPos = ent:GetPos()

                                                local dir = (ragPos - entPos):GetNormalized()

                                                local force = dir * 300 + Vector(0, 0, 350)
                                                if additives == 1 and not shouldplay then
                                                    force = dir * 500 + Vector(0, 0, 10)
                                                end
                                                if additives == 2 and not shouldplay then
                                                    force = dir * 850 + Vector(0, 0, 10)
                                                end
                                                if additives == 3 and not shouldplay then
                                                    force = dir * 1000 + Vector(0, 0, 10)
                                                end

                                                local phys = createfakeragdoll:GetPhysicsObject()
                                                if IsValid(phys) then
                                                    phys:SetVelocity(force)
                                                    phys:AddAngleVelocity(VectorRand() * 300)
                                                end

                                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                    local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                    if IsValid(bonePhys) then
                                                        bonePhys:SetVelocity(force)
                                                        bonePhys:AddAngleVelocity(VectorRand() * 300)
                                                    end
                                                end
                                            end
                                        })
                                    end
                                end
                            end
                        end
                        
                    end
                end
            end

            --OM_Knuckles_punchFallanimOM_Knuckles_punchFallanim
            if ent:GetNW2Bool("OM_Knuckles_punchFallanim") then
                
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)

                if ent:GetNW2Bool("OM_Knuckles_punchShouldPunch") then
                    ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                    if not ent:GetNW2Bool("PunchType") then
                        hasthestun = true
                        stunfunction(ent, false)
                    end
                end
                if ply:IsOnGround() then
                    if ent:GetNWBool('ShouldStunning_fix') then 
                        if ent:GetNW2Bool("PunchType") then
                            ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)

                            local pos = ply:GetPos()

                            radius = radius or 150

                            local effectdata = EffectData()
                            effectdata:SetOrigin(pos)
                            effectdata:SetNormal(Vector(0,0,1)) 
                            effectdata:SetRadius(radius)
                            util.Effect("cball_explode", effectdata, true, true) 

                            local concreteEffect = EffectData()
                            concreteEffect:SetOrigin(pos)
                            concreteEffect:SetNormal(Vector(0,0,1))
                            concreteEffect:SetScale(radius / 100)
                            util.Effect("ThumperDust", concreteEffect, true, true) 
                            sound.Play("physics/concrete/concrete_impact_hard1.wav", pos, 90, 100, 1)

                            local ed = EffectData()
                            ed:SetOrigin(ply:GetPos())
                            util.Effect("GroundCrash_OM", ed)

                            util.ScreenShake(ply:GetPos(), 10, 5, 1, 500, true)

                            local tr=util.TraceLine({start=ply:GetPos()+Vector(0,0,10),endpos=ply:GetPos()-Vector(0,0,80),filter=ply})
                            if tr.HitWorld then util.Decal("Scorch",tr.HitPos+tr.HitNormal*2,tr.HitPos-tr.HitNormal*2) end

                            stunfunction(ent, true)

                            AdvancedPillSound(
                                {
                                    stringe = "OM/knuckles/punchstun.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )

                            if SERVER then
                                --ply:SetNW2Float("OM_NoMovement_noodles", 1 + CurTime())
                                ent.AlternatePlaySolution = true
                                ent:PillAnim('GroundSmash')
                                ent.AlternatePlaySolution = false
                                ent:SetNW2Float("RollEndTime_om",0)
                            end

                        end


                        ent:SetNW2Bool("OM_Knuckles_punchFallanim_loseanim", false)

                        ent:SetNW2Float("PunchCooldown", CurTime() + ent.formTable.Outcomememories_stats.abilities.Punch.CooldownHit())
                        ent:SetNW2Float("PunchCooldown_duration", ent.formTable.Outcomememories_stats.abilities.Punch.CooldownHit())


                        ent:SetNW2Bool("OM_Knuckles_punchFallanim", false)
                        ent:SetNW2Bool("OM_Knuckles_punchShouldPunch", false)
                        ent:SetNWBool('ShouldStunning_fix', false)
                        
                        ent:GetPuppet():SetNW2Bool("Knuckles_glow_1", false)
                        ent:GetPuppet():SetNW2Bool("Knuckles_glow_2", false)
                        ent:GetPuppet():SetNW2Bool("Knuckles_glow_3", false)
                        ent:GetPuppet():SetNW2Bool("Knuckles_glow_3_ef", false)
                    end
                else
                    ent:SetNWFloat("Pill_rebound", 0.5 + CurTime())
                    ent:SetNWBool('ShouldStunning_fix', true)
                end
            else
                ent:SetNWBool('ShouldStunning_fix', false)
            end
            
            if IsValid(ent) then
                if ent:GetNW2Bool("OM_Knuckles_punchReady") then
                    if GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_cancharge"):GetBool() then
                        if ent:GetNW2Float("PunchDuration") < CurTime() - GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_chargetime1"):GetFloat() then
                            if not ent:GetPuppet():GetNW2Bool("Knuckles_glow_2") then
                                ent:GetPuppet():SetNW2Bool("Knuckles_glow_2", true)
                                ent:GetPuppet():SetNW2Float("Knuckles_glow_duration", CurTime()+0.5*0.5)
                                ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5*0.5)
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/knuckles/phase1.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                            end
                        end
                        if ent:GetNW2Float("PunchDuration") < CurTime() - (GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_chargetime2"):GetFloat() - 0.6) then
                            if not ent:GetPuppet():GetNW2Bool("Knuckles_glow_3_ef") then
                                ent:GetPuppet():SetNW2Bool("Knuckles_glow_3_ef", true)
                                local leftBone = ent:GetPuppet():LookupBone("LeftHand")
                                local rightBone = ent:GetPuppet():LookupBone("RightHand")

                                local leftPos, leftAng
                                if leftBone then
                                    leftPos, leftAng = ent:GetPuppet():GetBonePosition(leftBone)
                                end

                                local rightPos, rightAng
                                if rightBone then
                                    rightPos, rightAng = ent:GetPuppet():GetBonePosition(rightBone)
                                end

                                if leftPos then
                                    local ed = EffectData()
                                    ed:SetOrigin(leftPos + leftAng:Right()*-5)
                                    util.Effect("Knuckles_FireOrb", ed)
                                end

                                if rightPos then
                                    local ed = EffectData()
                                    ed:SetOrigin(rightPos + rightAng:Right()*-5)
                                    util.Effect("Knuckles_FireOrb", ed)
                                end
                            end
                        end
                        if ent:GetNW2Float("PunchDuration") < CurTime() - GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_chargetime2"):GetFloat() then
                            if not ent:GetPuppet():GetNW2Bool("Knuckles_glow_3") then
                                ent:GetPuppet():SetNW2Bool("Knuckles_glow_3", true)
                                ent:GetPuppet():SetNW2Float("Knuckles_glow_duration", CurTime()+0.5*0.5)
                                ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5*0.5)
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/knuckles/phase3.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                                local leftBone = ent:GetPuppet():LookupBone("LeftHand")
                                local rightBone = ent:GetPuppet():LookupBone("RightHand")

                                local leftPos, leftAng
                                if leftBone then
                                    leftPos, leftAng = ent:GetPuppet():GetBonePosition(leftBone)
                                end

                                local rightPos, rightAng
                                if rightBone then
                                    rightPos, rightAng = ent:GetPuppet():GetBonePosition(rightBone)
                                end

                                if leftPos then
                                    local ed = EffectData()
                                    ed:SetOrigin(leftPos + leftAng:Right()*-5)
                                    util.Effect("Knuckles_firering", ed)
                                end

                                if rightPos then
                                    local ed = EffectData()
                                    ed:SetOrigin(rightPos + rightAng:Right()*-5)
                                    util.Effect("Knuckles_firering", ed)
                                end
                            end
                        end
                    end
                end
            end
            --CounterOM_durationCounterOM_duration
            if ent:GetNW2Float("CounterOM_duration2") > CurTime() then
                if not ent.CounterSetCD then
                    ent.CounterSetCD = true
                end
            else
                if ent.CounterSetCD then
                    ent.CounterSetCD = false
                    ent:GetPuppet():SetNW2Bool("Knuckles_glow_1", false)
                    ent:GetPuppet():SetNW2Bool("Knuckles_glow_2", false)
                    ent:GetPuppet():SetNW2Bool("Knuckles_glow_3", false)
                    ent:GetPuppet():SetNW2Bool("Knuckles_glow_3_ef", false)
                    ent:SetNW2Float("CounterOM_cooldown", CurTime()+ent.formTable.Outcomememories_stats.abilities.Counter.cooldownFail())
                    ent:SetNW2Float("CounterOM_cooldown_duration", ent.formTable.Outcomememories_stats.abilities.Counter.cooldownFail())
                end
            end

            if ent:GetNW2Bool("OM_Knuckles_punchFallanim") then
                hasthestun = true
                if ent:GetNW2Float("PunchVelocityDuration") > CurTime() then
                    ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)

                    ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.2)
                    if ply:IsPlayer() then
                        ply:SetNW2Vector("OM_SetVelocity_Vector", ent.punchdir*2)
                    end
                end
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.05)
                ply:SetNW2Float("OM_Damage_Reduction",0)
            else
                if ent:GetNW2Bool("OM_Knuckles_punchReady") then    
                    ply:SetNW2Float("OM_Damage_Reduction",1-0.64)
                else
                    ply:SetNW2Float("OM_Damage_Reduction",1)
                end
            end
            if hasthestun then
                ply.GotTheStun = true
            else
                ply.GotTheStun = false
            end
        else

            local v = ent:GetPuppet()

            local enabled = false

            local FlameCount = 0
            local FlameSizeMin = 0
            local FlameSizeMax = 0
            local FlameLifeMin = 0
            local FlameLifeMax = 0
            local FlameVelocity = 0
            local FlameUpwardVelocity = 0
            local FlameAirResistance = 0
            local FlameGravity = Vector(0,0,0)
            local FlameForwardForce = 0
            local FlameColorMin = 0
            local FlameColorMax = 0

            local SmokeChance = 0
            local SmokeCount = 0
            local SmokeSizeMin = 0
            local SmokeSizeMax = 0
            local SmokeLifeMin = 0
            local SmokeLifeMax = 0
            local SmokeVelocity = 0
            local SmokeStartAlpha = 0

            local SparkChance = 0
            local SparkCount = 0
            local SparkSize = 0
            local SparkLife = 0
            local SparkVelocity = 0

            if v:GetNW2Bool("Knuckles_glow_3") then
                enabled = true

                FlameCount = 4
                FlameSizeMin = 6
                FlameSizeMax = 10
                FlameLifeMin = 0.2
                FlameLifeMax = 0.45
                FlameVelocity = 14
                FlameUpwardVelocity = 20
                FlameAirResistance = 38
                FlameGravity = Vector(0,0,18)
                FlameForwardForce = 8
                FlameColorMin = 100
                FlameColorMax = 165

                SmokeChance = 0.45
                SmokeCount = 2
                SmokeSizeMin = 7
                SmokeSizeMax = 13
                SmokeLifeMin = 0.7
                SmokeLifeMax = 1.2
                SmokeVelocity = 8
                SmokeStartAlpha = 95

                SparkChance = 0.05
                SparkCount = 2
                SparkSize = 2
                SparkLife = 0.2
                SparkVelocity = 70
            end

            if enabled and curentime ~= CurTime() then
                curentime = CurTime()
                local emitter = ParticleEmitter(v:GetPos())
                if not emitter then return end

                local function CreateFireParticles(pos, ang)

                    for i = 1, 3 do
                        local p = emitter:Add("sprites/light_glow02_add", pos)

                        if p then
                            p:SetVelocity(
                                VectorRand() * 8 +
                                ang:Forward() * 10 +
                                Vector(0,0,28)
                            )

                            p:SetDieTime(math.Rand(0.08,0.18))

                            p:SetStartAlpha(180)
                            p:SetEndAlpha(0)

                            p:SetStartSize(math.Rand(4, 8))
                            p:SetEndSize(0)

                            p:SetColor(255,255,235)

                            p:SetAirResistance(90)
                        end
                    end


                    for i = 1, FlameCount + 3 do

                        local p = emitter:Add(
                            "particles/flamelet"..math.random(1,5),
                            pos + VectorRand()*2
                        )

                        if p then

                            p:SetVelocity(
                                VectorRand()*20 +
                                ang:Forward()*math.Rand(4,18) +
                                Vector(0,0,math.Rand(18,40))
                            )

                            p:SetDieTime(math.Rand(0.35,0.75))

                            p:SetStartAlpha(255)
                            p:SetEndAlpha(0)

                            p:SetStartSize(math.Rand(4, 8))
                            p:SetEndSize(math.Rand(8, 14))

                            p:SetRoll(math.random(0,360))
                            p:SetRollDelta(math.Rand(-10,10))

                            p:SetColor(
                                255,
                                math.random(130,220),
                                math.random(0,40)
                            )

                            p:SetAirResistance(55)

                            p:SetGravity(Vector(
                                math.Rand(-2,2),
                                math.Rand(-2,2),
                                40
                            ))
                        end

                    end


                    for i = 1, 8 do

                        local p = emitter:Add(
                            "particles/flamelet"..math.random(1,5),
                            pos + VectorRand()*3
                        )

                        if p then

                            p:SetVelocity(
                                VectorRand()*35 +
                                Vector(0,0,25)
                            )

                            p:SetDieTime(math.Rand(0.15,0.4))

                            p:SetStartAlpha(255)
                            p:SetEndAlpha(0)

                            p:SetStartSize(math.Rand(1, 3))
                            p:SetEndSize(0)

                            p:SetRoll(math.random(0,360))
                            p:SetRollDelta(math.Rand(-25,25))

                            p:SetColor(
                                255,
                                math.random(180,255),
                                40
                            )

                            p:SetAirResistance(40)
                            p:SetGravity(Vector(0,0,18))
                        end

                    end


                    for i = 1, math.random(3,6) do

                        local ember = emitter:Add(
                            "sprites/light_glow02_add",
                            pos
                        )

                        if ember then

                            ember:SetVelocity(
                                VectorRand()*45 +
                                Vector(0,0,50)
                            )

                            ember:SetDieTime(math.Rand(0.5,1.2))

                            ember:SetStartAlpha(255)
                            ember:SetEndAlpha(0)

                            ember:SetStartSize(math.Rand(0.8, 1.8))
                            ember:SetEndSize(0)
                            
                            ember:SetColor(
                                255,
                                math.random(170,255),
                                60
                            )

                            ember:SetAirResistance(8)
                            ember:SetGravity(Vector(0,0,-10))
                        end

                    end


                    if math.Rand(0,1) < .55 then

                        for i = 1,3 do

                            local smoke = emitter:Add(
                                "particle/particle_smokegrenade",
                                pos
                            )

                            if smoke then

                                smoke:SetVelocity(
                                    VectorRand()*14 +
                                    Vector(0,0,18)
                                )

                                smoke:SetDieTime(math.Rand(1.0,1.8))

                                smoke:SetStartAlpha(70)
                                smoke:SetEndAlpha(0)

                                smoke:SetStartSize(math.Rand(4, 8))
                                smoke:SetEndSize(math.Rand(12, 20))

                                smoke:SetRoll(math.random(360))
                                smoke:SetRollDelta(math.Rand(-2,2))

                                smoke:SetColor(45,45,45)

                                smoke:SetAirResistance(28)

                                smoke:SetGravity(Vector(
                                    math.Rand(-4,4),
                                    math.Rand(-4,4),
                                    22
                                ))
                            end

                        end

                    end

                    if math.Rand(0,1) < .25 then
                        for i = 1, math.random(4,8) do
                            local spark = emitter:Add(
                                "effects/spark",
                                pos
                            )

                            if spark then

                                spark:SetVelocity(
                                    VectorRand()*120 +
                                    Vector(0,0,25)
                                )

                                spark:SetDieTime(math.Rand(0.2,0.45))

                                spark:SetStartAlpha(255)
                                spark:SetEndAlpha(0)

                                spark:SetStartSize(math.Rand(1,2))
                                spark:SetEndSize(0)

                                spark:SetColor(
                                    255,
                                    math.random(220,255),
                                    120
                                )

                                spark:SetGravity(Vector(0,0,-220))
                            end
                        end
                    end
                end

                local leftBone = v:LookupBone("LeftHand")
                local leftMatrix = leftBone and v:GetBoneMatrix(leftBone)

                if leftMatrix then
                    local leftPos = leftMatrix:GetTranslation()
                    local leftAng = leftMatrix:GetAngles()

                    CreateFireParticles(
                        leftPos + leftAng:Right() * -10,
                        leftAng
                    )
                end

                local rightBone = v:LookupBone("RightHand")
                local rightMatrix = rightBone and v:GetBoneMatrix(rightBone)

                if rightMatrix then
                    local rightPos = rightMatrix:GetTranslation()
                    local rightAng = rightMatrix:GetAngles()

                    CreateFireParticles(
                        rightPos + rightAng:Right() * -10,
                        rightAng
                    )
                end

                emitter:Finish()
            end

        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if not SERVER then return end

        if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() or IsValid(ply:GetNWEntity("OM_ragdollentity")) then
            return
        end
        if button == KEY_SPACE then
            if ent:GetNW2Bool("LatchOntoWall_OM_Knuckels") then

                local ang1 = (ent:GetNW2Vector("startPos_knuckles") - ent:GetNW2Vector("endPos_knuckles")):Angle()
                local ang2 = (ply:GetPos() - (ply:GetPos() + ply:GetAngles():Forward() * 500)):Angle()

                local diff = math.abs(math.AngleDifference(ang1.yaw, ang2.yaw))

                --if diff > 84 then
                    if ply:IsPlayer() then
                        ply:SetMoveType(MOVETYPE_WALK)
                    else
                        ply:SetMoveType(0)
                    end
                    ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)
                    ent:SetNW2Float('GlideDuration', CurTime() + GetConVar("OUTCOMEMORIES_N_Knuckles_Glide_duration"):GetFloat())
                    ent:SetNW2Float('GlideUpDuration', CurTime()+0.35)
                    --ply:SetPos(ply:GetPos()+ply:GetForward()*30)
                    if SERVER then
                        ent.AlternatePlaySolution = true
                        ent:PillAnim('LatchOff')
                        ent.AlternatePlaySolution = false
                    end
                --end
            end
        end
        if button == ply:GetInfoNum("om_pills_action_Knuckles_Counter_key", KEY_T) then
            if SERVER then
                if not GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_useable"):GetBool() then return end
                if ent:GetNW2Float("CounterOM_duration2") > CurTime() then return end
                if ent:GetNW2Float("CounterOM_cooldown") > CurTime() then return end
                if ent.CounterSetCD then return end

                if ent:GetNW2Bool("OM_Knuckles_punchFallanim") then return end
                if ent:GetNW2Bool("OM_Knuckles_punchShouldPunch") then return end
                if ent:GetNW2Bool("OM_Knuckles_punchReady") then
                    if SERVER then
                        if ent.RightHandFire then
                            ent.RightHandFire:Remove()
                            ent.RightHandFire = nil
                        end
                        if ent.LeftHandFire then
                            ent.LeftHandFire:Remove()
                            ent.LeftHandFire = nil
                        end
                    end

                    ent:SetNW2Bool("OM_Knuckles_punchReady", false)
                    ent:SetNW2Bool("OM_Knuckles_punchFallanim", false)
                    ent:SetNW2Bool("OM_Knuckles_punchShouldPunch", false)
                end

                local puppet = ent:GetPuppet()
                local layeredAnim = puppet:AddGesture(ACT_GESTURE_RANGE_ATTACK1_LOW, false)

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

                timer.Simple(1.25, fadeLayer)

                timer.Simple(2,function()
                    if !IsValid(ent) then return end
                    puppet:RemoveLayer(puppet:FindGestureLayer(ACT_GESTURE_RANGE_ATTACK1_LOW))
                end)

                --CounterOM_durationCounterOM_duration
                ent:SetNW2Float("CounterOM_duration2", CurTime()+3)
                ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+3)

                AdvancedPillSound(
                    {
                        stringe = "OM/knuckles/counter.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end
        end
        if button == ply:GetInfoNum("om_pills_action_Knuckles_Punch_key", KEY_E) then
            if not GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_useable"):GetBool() then return end
            if ent:GetNW2Float("CounterOM_duration2") > CurTime() then return end
            if ent:GetNWFloat("Pill_rebound") > CurTime() then return end
            if ent:GetNWBool("ShouldStunning_fix") then return end

            if ent:GetNW2Bool("OM_Knuckles_punchFallanim") then return end
            if ent:GetNW2Bool("OM_Knuckles_punchShouldPunch") then return end
            if ent:GetNW2Float("PunchCooldown") > CurTime() then return end

            if ent:GetNW2Bool("OM_Knuckles_punchReady") then 
                if SERVER then
                    if ent.RightHandFire then
                        ent.RightHandFire:Remove()
                        ent.RightHandFire = nil
                    end
                    if ent.LeftHandFire then
                        ent.LeftHandFire:Remove()
                        ent.LeftHandFire = nil
                    end
                end

                ent:GetPuppet():SetNW2Bool("Knuckles_glow_1", false)
                ent:GetPuppet():SetNW2Bool("Knuckles_glow_2", false)
                ent:GetPuppet():SetNW2Bool("Knuckles_glow_3", false)

                ent:SetNW2Bool("OM_Knuckles_punchReady", false)
                ent:SetNW2Bool("OM_Knuckles_punchFallanim", false)
                ent:SetNW2Bool("OM_Knuckles_punchShouldPunch", false)
                ent:SetNW2Float("PunchCooldown", CurTime() + ent.formTable.Outcomememories_stats.abilities.Punch.CooldownCancel())
                ent:SetNW2Float("PunchCooldown_duration", ent.formTable.Outcomememories_stats.abilities.Punch.CooldownCancel())
                ent:GetPuppet():SetNW2Float("Knuckles_glow_cancel_duration", CurTime()+0.5*0.5)
                ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5*0.5)
                AdvancedPillSound(
                    {
                        stringe = "OM/knuckles/KnucklesCancel.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                return
            end

            ent:SetNW2Float("ShouldPunch", CurTime()+ 0.4)
            ent:SetNW2Float("PunchDuration", CurTime())
            AdvancedPillSound(
                {
                    stringe = "OM/knuckles/punchstart.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )
            ent:SetNW2Bool("OM_Knuckles_punchReady", true)
            ent:SetNW2Bool("PunchType", false)

            ent:GetPuppet():SetNW2Bool("Knuckles_glow_1", false)
            ent:GetPuppet():SetNW2Bool("Knuckles_glow_2", false)
            ent:GetPuppet():SetNW2Bool("Knuckles_glow_3", false)
            
            ent:GetPuppet():SetNW2Float("Knuckles_glow_duration", CurTime()+0.5*0.5)
            ent:GetPuppet():SetNW2Float("knuckles_block_outline", CurTime()+0.5*0.5)
                
            
        end
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if SERVER then
                if ent:GetNW2Float("ShouldPunch") > CurTime() then return end

                if ent:GetNW2Bool("OM_Knuckles_punchFallanim") then return end
                if ent:GetNW2Bool("OM_Knuckles_punchShouldPunch") then return end
                if ent:GetNWBool("ShouldStunning_fix") then return end

                if ent:GetNW2Bool("OM_Knuckles_punchReady") then
                    ent:SetNW2Bool("LatchOntoWall_OM_Knuckels", false)
                    if ply:IsPlayer() then
                        ply:SetMoveType(MOVETYPE_WALK)
                    end

                    local groundTrace = util.TraceLine({
                        start = ply:GetPos(),
                        endpos = ply:GetPos() - Vector(0,0,900),
                        filter = ply,
                        mask = MASK_SOLID_BRUSHONLY
                    })
                    local dist = 30
                    if groundTrace.Hit then
                        dist = groundTrace.HitPos:Distance(ply:GetPos())
                    end

                            AdvancedPillSound(
                                {
                                    stringe = "OM/knuckles/Slam"..math.random(1,4)..".wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                    if ply:IsOnGround() then
                        if ply:IsPlayer() then

                            --ply:SetVelocity(ply:GetForward()*425+ply:GetUp()*135)
                            --ply:SetLocalVelocity(ply:GetForward()*425+ply:GetUp()*135)
                            ent:SetNW2Float("PunchVelocityDuration", CurTime()+0.5)
                            ent.punchdir = ply:GetForward()*365+ply:GetUp()*35
                            ply:SetPos(ply:GetPos()+Vector(0,0,15))
                        else
                            ply:SetVelocity(ply:GetForward()*365*3+ply:GetUp()*135*3)
                            ply:SetLocalVelocity(ply:GetForward()*365*3+ply:GetUp()*135*3)
                            ply:SetPos(ply:GetPos()+Vector(0,0,44))
                        end

                        ent.AlternatePlaySolution = true
                        ent:PillAnim('attack')
                        ent.AlternatePlaySolution = false

                        ent:SetNW2Bool("OM_Knuckles_punchReady", false)
                        ent:SetNW2Bool("OM_Knuckles_punchFallanim", true)
                        ent:SetNW2Bool("OM_Knuckles_punchShouldPunch", true)

                        AdvancedPillSound(
                            {
                                stringe = "OM/knuckles/swing.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        
                        timer.Simple(0.01,function()
                            if !IsValid(ply) then return end
                            if !IsValid(ent) then return end
                        end)
                        
                    else
                        if dist > 25 then
                            if ent.anim == "jump2" then
                                ent.anim = nil
                                ent.animStart = false
                                ent.animFreeze = false
                            end
                            ent:GetPuppet():SetNW2Float('Knuckles_glow_duration_white',CurTime()+0.5*0.25)
                            ent:SetNW2Bool("PunchType", true)

                            ent:SetNW2Bool("OM_Knuckles_punchReady", false)
                            ent:SetNW2Bool("OM_Knuckles_punchFallanim", true)
                            ent:SetNW2Bool("OM_Knuckles_punchShouldPunch", true)

                        end
                    end
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
        
        if ply:GetNW2Bool("Survivor_Downed_OM") then return end
        if SERVER then
            ent.AlternatePlaySolution = true
            ent:PillAnim('jump2')
            ent.AlternatePlaySolution = false
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