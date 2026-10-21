
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
    ["Roundhouse_kick"] = Material("icons/Roundhouse kick.png"),
    ["burning_javelin"] = Material("icons/burning javelin.png"),
}

pk_pills.register('pill_om_Blaze', {

    printName='Blaze',
    Outcomememories='Blaze',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/Blaze.mdl",
    
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
                if ply:IsOnGround() then
                    return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
                else
                    return not ent:GetNW2Bool("ShouldntShowAbility1alt_OM")
                end
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Roundhouse_kick"]
            end,
            name = function(uselessvar,ply,ent)
                if ply:IsOnGround() then
                    return "Roundhouse Kick"
                else
                    return "Sol Dash"
                end
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_blaze_abillty1_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float('Kick/dash_cd')
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.07, yaxis = 0 + iconsize * 0.04, xsize = 0 - iconsize* 0.1, ysize = 0 - iconsize * 0.1}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                if ent:GetNW2Float("SolFlameBar") >= 50 then
                    return not ent:GetNW2Bool("ShouldntShowAbility2alt_OM")
                else
                    return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
                end
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["burning_javelin"]
            end,
            name = function(uselessvar,ply,ent)
                if ent:GetNW2Float("SolFlameBar") >= 50 then
                    return "Sol Flame"
                else
                    return "Burning Javelin"
                end
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_blaze_abillty2_key", KEY_R)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Javelin/flame_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.1, yaxis = 0 + iconsize * 0.12, xsize = 0 - iconsize* 0.2, ysize = 0 - iconsize * 0.2}
            end,
            survivor = true,
            font = "CreditsText",
        }
    },
    
    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            return true
        end,
        colorbar = function(uselessvar,ply,ent)
            return Color(255, 0, 0, 255)
        end,
        progression = function(uselessvar,ply,ent)
            return ent:GetNW2Float("SolFlameBar")
        end,
        maximumbar = function(uselessvar,ply,ent)
            return ent:GetNW2Float("SolFlameBar_max")
        end,
    },

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            attack = "attack",
            jump2 = "jump",
            Kick = "Kick",
        },
        ShouldMoveRotate={
            idle= function(ent) 
                
                if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float('KickDurationWait') > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Float('throwingduration') > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Bool('ExpellSolFlame') then
                    return "shiftlock"
                end
                return "notanything"
            end,
            run= function(ent) 
                if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float('KickDurationWait') > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Float('throwingduration') > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Bool('ExpellSolFlame') then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            walk= function(ent) 
                if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float('KickDurationWait') > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Float('throwingduration') > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Bool('ExpellSolFlame') then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            fall= function(ent) 
                if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then return "assignedagnles" end
                if ent:GetNW2Float('throwingduration') > CurTime() then
                    return "shiftlock"
                end
                if ent:GetNW2Bool('ExpellSolFlame') then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            jump= function(ent) 
                if ent:GetNW2Float('KickStarted') > CurTime() then return "notanything" end
                if ent:GetNW2Bool('ExpellSolFlame') then
                    return "shiftlock"
                end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            idle= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Bool('ExpellSolFlame') then return 'IdleSolFlame' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "Roll" end
                if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then return "SolDash" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "LowHealthIdle"
                end 
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "Roll" end
                if ent:GetNW2Bool('ExpellSolFlame') then return 'WalkSolFlame' end
                if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then return "SolDash" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "LowHealthWalk"
                end 
            end,
            fall= function(ent) 
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "Roll" end
                if ent:GetNW2Bool("Blaze_kicking") then return "KickIdle" end
                if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then return "SolDash" end
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "Roll" end
                if ent:GetNW2Bool('ExpellSolFlame') then return 'RunSolFlame' end
                if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then return "SolDash" end
                if ent:GetNW2Float('KickDurationWait') > CurTime() then return "walk" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "LowHealthRun"
                end 
            end,
        },
        animrates = {
            run= function(ent)
                return 1.1
            end,
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
        if ply:GetInfoNum("om_pills_action_camera_blaze", 1) == 1 then
            if ent:GetNW2Float('DashDurationWait') > CurTime() then
                basetable =  {
                    startoffset = Vector(35,0,50),  -- left-up, front-back, up-down
                    dist=175,
                    fov = 70,
                    id = 2,
                    transition = 1,
                    canscroll = true,
                }
            end

            if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then
                basetable =  {
                    startoffset = Vector(50,-35,15),  -- left-up, front-back, up-down
                    dist=100,
                    fov = 100,
                    id = 1,
                    transition = 1,
                    canscroll = true,
                }
            end
            
            if ent:GetNW2Bool('ExpellSolFlame') then
                basetable =  {
                    startoffset = Vector(65,-50,35),  -- left-up, front-back, up-down
                    dist=0,
                    fov = 90,
                    id = 2,
                    transition = 1,
                    canscroll = true,
                }
            end
        end

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

                if ent:GetNW2Int("KickDurationWait") > CurTime() then
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() - ent.formTable.Outcomememories_stats.moveSpeed.run()
                end

                return sendtotable
            end,
        }
    }, 

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_blaze_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_blaze_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_blaze_walk"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_blaze_jumppower"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_blaze_jumpcd"):GetFloat()
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_blaze_rollingPower"):GetFloat()
                end
            end,
        },

        abilities = {
            ["KickNSoldash"] = {
                ["StunEffect"] = function(ply, ent, ent2, type)
                    local stunduration = 3
                    local Damage = 25
                    local canstunstack = false
                    local sol = 35
                    local CanBurn = false
                    local CanRagdoll = false
                    if type == "Kick" then
                        canstunstack = GetConVar("OUTCOMEMORIES_N_blaze_kick_stunstack"):GetBool()
                        stunduration = GetConVar("OUTCOMEMORIES_N_blaze_kick_basestun"):GetFloat()
                        Damage = GetConVar("OUTCOMEMORIES_N_blaze_kick_basedamage"):GetFloat()
                        sol = GetConVar("OUTCOMEMORIES_N_blaze_kick_solflamemeter"):GetFloat()

                        if ent:GetNW2Float("SolFlameBar") >= 50 then
                            sol = GetConVar("OUTCOMEMORIES_N_blaze_kick_solflamemeterSolflame"):GetFloat()
                        end

                        CanBurn = GetConVar("OUTCOMEMORIES_N_blaze_kick_canburn"):GetBool()
                        CanRagdoll = GetConVar("OUTCOMEMORIES_N_blaze_kick_canragdollstun"):GetBool()
                    end
                    if type == "Dash" then
                        canstunstack = GetConVar("OUTCOMEMORIES_N_blaze_SolDash_stunstack"):GetBool()
                        stunduration = GetConVar("OUTCOMEMORIES_N_blaze_SolDash_basestun"):GetFloat()
                        Damage = GetConVar("OUTCOMEMORIES_N_blaze_SolDash_basedamage"):GetFloat()
                        sol = GetConVar("OUTCOMEMORIES_N_blaze_SolDash_solflamemeter"):GetFloat()

                        if ent:GetNW2Float("SolFlameBar") >= 50 then
                            sol = GetConVar("OUTCOMEMORIES_N_blaze_kick_solflamemeterSolflame"):GetFloat()
                        end

                        CanBurn = GetConVar("OUTCOMEMORIES_N_blaze_SolDash_canburn"):GetBool()
                        CanRagdoll = GetConVar("OUTCOMEMORIES_N_blaze_soldash_canragdollstun"):GetBool()
                    end
                    Mutaul_OMStunCode(
                        {
                            ["ply"] = ply,
                            ["ent"] = ent,
                            ["target"] = ent2,
                            ["StunDur"] = stunduration,
                            ["stunfunction"] = function(shouldstundamage)
                                if shouldstundamage then

                                    if type == "Dash" then
                                        local effectdata = EffectData()
                                        effectdata:SetOrigin(ent2:GetPos()+Vector(0,0,50))
                                        util.Effect("SolDash_solbooststart_blaze_om", effectdata)
                                    end

                                    if ent:GetNW2Float("SolFlameBar") >= 50 then
                                        local ed = EffectData()
                                        ed:SetOrigin(ent2:GetPos())
                                        util.Effect("blaze_kick_punch_OM", ed)
                                    else
                                        local effect = EffectData()
                                        effect:SetOrigin(ent2:GetPos()+ Vector(0,0,-60))
                                        effect:SetNormal(ent2:GetUp()*1)
                                        effect:SetMagnitude(250)
                                        effect:SetScale(15)
                                        effect:SetEntity(ent2)

                                        util.Effect("ExpellSolFlame_blaze_impact_kick", effect)
                                    end

                                    --[[
                                    ]]

                                    AdvancedPillSound(
                                        {
                                            stringe = "OM/blaze/blazekick.wav",
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        ent
                                    )


                                    if ent:GetNW2Float("StartStunTime_soldash/kick") < CurTime() then
                                        if ent:GetNW2Float("SolFlameBar") >= 50 then
                                            ent2:SetVelocity( ply:GetVelocity():GetNormalized()*1000 )
                                        else
                                            ent2:SetVelocity( ply:GetVelocity():GetNormalized()*600 )
                                        end
                                        if ply:IsPlayer() then
                                            ply:SetLocalVelocity(ply:GetForward()*-250*2+ply:GetUp()*120*2.4)
                                            ply:SetNW2Vector("OM_SetVelocity_Vector",ply:GetForward()*-500+ply:GetUp()*300)
                                        else
                                            ply:SetVelocity(ply:GetForward()*-250*2+ply:GetUp()*120*2.4)
                                            ply:SetNW2Vector("OM_SetVelocity_Vector",ply:GetForward()*-500+ply:GetUp()*300)
                                        end
                                    end

                                    ent:SetNW2Float("SolFlameBar", ent:GetNW2Float("SolFlameBar") + sol)
                                    if ent:GetNW2Float("SolFlameBar") > ent:GetNW2Float("SolFlameBar_max") then
                                        ent:SetNW2Float("SolFlameBar", ent:GetNW2Float("SolFlameBar_max"))
                                    end
                                    if ent:GetNW2Float("SolFlameBar") > 50 and CanBurn then
                                        OM_burntarget(ply,ent2,5, true)
                                    end

                                    if CanRagdoll then

                                        local last = CurTime() + 2
                                        local flung = false

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
                                                        last = CurTime() + 1
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

                                                local force = dir * 750 + Vector(0, 0, 120)

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
                            end,
                            ["shouldstack"] = canstunstack,
                            ["Damage"] = Damage,
                            ["DamageType"] = DMG_GENERIC
                        }
                    )
                end
            }
        }
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

            local health = GetConVar("OUTCOMEMEMORIES_N_blaze_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)


            local maxsolflame = GetConVar("OUTCOMEMEMORIES_N_blaze_maxSolflame"):GetFloat()
            initializetable2["entity"]:SetNW2Float("SolFlameBar", GetConVar("OUTCOMEMEMORIES_N_blaze_SolfalemOnSapwn"):GetFloat())
            initializetable2["entity"]:SetNW2Float("SolFlameBar_max", maxsolflame)

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

    think_noodles_om_pill = function(ply, ent) -- pill_om_Blaze
        if not SERVER then return end
        OM_PILL_speedThink(ply, ent)
        ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_blaze_Resistance"):GetFloat()/100)

        if not GetConVar("OUTCOMEMORIES_N_blaze_kick_useable"):GetBool() then
            ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
        else
            ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
        end
        if not GetConVar("OUTCOMEMORIES_N_blaze_SolDash_useable"):GetBool() then
            ent:SetNW2Bool("ShouldntShowAbility1alt_OM", true)
        else
            ent:SetNW2Bool("ShouldntShowAbility1alt_OM", false)
        end

        if not GetConVar("OUTCOMEMORIES_N_blaze_javelin_useable"):GetBool() then
            ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
        else
            ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
        end
        if not GetConVar("OUTCOMEMORIES_N_blaze_solflame_useable"):GetBool() then
            ent:SetNW2Bool("ShouldntShowAbility2alt_OM", true)
        else
            ent:SetNW2Bool("ShouldntShowAbility2alt_OM", false)
        end

        if ent:GetNW2Bool("DrainDash") or ent:GetNW2Bool("Blaze_kicking") or ent:GetNW2Bool("Blaze_kickActivation") or ent:GetNW2Bool("Blaze_DashActivation") or ent:GetNW2Float("KickDurationWait") > CurTime() or ent:GetNW2Float("DashDurationWait") > CurTime() or ent:GetNW2Bool("ExpellSolFlame") then
            ply:SetNW2Float("OM_Damage_Reduction",0)
            ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2",CurTime()+0.75)
        else
            ply:SetNW2Float("OM_Damage_Reduction",1)
        end

        if ent:GetNW2Float('BlazeBeepingsfx') > CurTime() then
            if not ent.blazebeepsfx_bool then
                ent.blazebeepsfx_bool = true
                local ed = EffectData()

                ed:SetOrigin(ent:GetPuppet():GetPos()+ Vector(0,0,35)+ent:GetPuppet():GetForward()*75)
                ed:SetEntity(ent:GetPuppet())
                ed:SetNormal(ent:GetForward())
                ed:SetScale(1)
                ed:SetMagnitude(1)

                util.Effect("SolFlame_chargeup_blaze_om", ed)
            end
            if ent:GetNW2Float('KickStarted_beep') < CurTime() then
                ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.35)
                ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.35)
                ent:SetNW2Float("KickStarted_beep", CurTime()+0.05)
                if not ent.BlazeAddupval then
                    ent.BlazeAddupval = 0
                end
                AdvancedPillSound(
                    {
                        stringe = "OM/blaze/blazebeep.wav",
                        pitchPercent = 80+ent.BlazeAddupval,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent.BlazeAddupval = ent.BlazeAddupval - 9
            end
        else
            if ent.blazebeepsfx_bool then
                ent.blazebeepsfx_bool = false
            end
        end

        local ply = ent:GetPillUser()
        local dir = ply:GetVelocity():GetNormalized()
        local aheadPos = ply:GetPos() + dir * 5
        local ang = (aheadPos - ply:GetPos()):Angle()
        
        ent:SetNW2Angle("pill_assignedangle",ang)
        if ent:GetNW2Float('KickDurationWait') > CurTime() then

            ent:SetNW2Bool("Blaze_kickActivation", true)

            if ent:GetNW2Float('KickStarted_beep') < CurTime() then
                ent:SetNW2Float("KickStarted_beep", CurTime()+0.035)
                if not ent.BlazeAddupval then
                    ent.BlazeAddupval = 0
                end
                AdvancedPillSound(
                    {
                        stringe = "OM/blaze/blazebeep.wav",
                        pitchPercent = 90+ent.BlazeAddupval,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent.BlazeAddupval = ent.BlazeAddupval + 2.5
            end
        else
            if ent:GetNW2Bool("Blaze_kickActivation") then

                local solgain = false

                if ent:GetNW2Float("SolFlameBar") >= 50 then
                    AdvancedPillSound(
                        {
                            stringe = "OM/blaze/firestorm.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 90
                        },
                        ent
                    )
                    if SERVER then
                        local puppet = ent:GetPuppet()
                        local bone = puppet:LookupBone("LeftFoot")

                        local trailOrigin = ents.Create("info_target")
                        trailOrigin:SetPos(puppet:GetPos())
                        trailOrigin:SetParent(puppet)
                        trailOrigin:Spawn()

                        if bone then
                            trailOrigin:FollowBone(puppet, bone)
                        end

                        local trail = util.SpriteTrail(
                            trailOrigin,
                            0,
                            Color(255, 0, 0),
                            true,
                            20,
                            2,
                            0.25,
                            0.015,
                            "icons/blaze_trail"
                        )

                        ent.blazeball = trailOrigin
                        ent.trail = trail
                        ent:DeleteOnRemove(trailOrigin)
                        ent:DeleteOnRemove(trail)
                    end

                    if ply:IsPlayer() then
                        ply:SetLocalVelocity(ply:GetForward()*365*3+ply:GetUp()*135*2.1)
                        ply:SetPos(ply:GetPos()+Vector(0,0,15))
                    else
                        ply:SetVelocity(ply:GetForward()*365*3+ply:GetUp()*135*3)
                        ply:SetPos(ply:GetPos()+Vector(0,0,44))
                    end
                else
                    if ply:IsPlayer() then
                        ply:SetLocalVelocity(ply:GetForward()*365*2.8+ply:GetUp()*135*1.8)
                        ply:SetPos(ply:GetPos()+Vector(0,0,15))
                    else
                        ply:SetVelocity(ply:GetForward()*365*3+ply:GetUp()*135*3)
                        ply:SetPos(ply:GetPos()+Vector(0,0,44))
                    end
                end
                
                ent:PillAnim('Kick')
                ent:SetNW2Bool("Blaze_kicking", true)
                ent:SetNW2Bool("Blaze_kickActivation", false)
                ent:SetNW2Float("KickStarted", CurTime()+0.25)
                AdvancedPillSound(
                    {
                        stringe = "OM/knuckles/swing.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.35)
                ent:SetNW2Float('StartStunTime_soldash/kick',CurTime()+0.1)
            end

            if ent:GetNW2Bool("Blaze_kicking") then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 100)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if Mutual_OMCanStun(ply, ent, ent2, GetConVar("OUTCOMEMORIES_N_blaze_kick_stunstack"):GetBool()) then

                            ent.formTable.Outcomememories_stats.abilities.KickNSoldash.StunEffect(ply,ent,ent2, "Kick")
                            ent:SetNW2Bool("Blaze_kicking", false)
                            ent:PillAnim('jump2')
                            ent:SetNW2Float('KickStarted', CurTime() + 1)
                            ent:SetNW2Float('Kick/dash_cd', CurTime()+GetConVar("OUTCOMEMORIES_N_blaze_kick_cooldownland"):GetFloat())
                            local entity = ent.blazeball
                            if entity and IsValid(entity) then
                                entity:SetParent(nil)
                                timer.Simple(1,function()
                                    if !IsValid(entity) then return end
                                    entity:Remove()
                                end)
                            end
                        end
                    end
                end
            end
        end

        if ply:IsOnGround() and ent:GetNW2Bool("Blaze_kicking") and ent:GetNW2Float('KickStarted') < CurTime() then
            ent:SetNW2Bool("Blaze_kicking", false)
            ply:SetNW2Float("RollEndTime_om", CurTime()+0.5)
            ent:SetNW2Float("RollEndTime_om", CurTime()+0.5)
            ply:SetNW2Vector("RollDir_om", ply:GetForward()*650)
            ent:SetNW2Float('Kick/dash_cd', CurTime()+GetConVar("OUTCOMEMORIES_N_blaze_kick_cooldownmiss"):GetFloat())
            if ent:GetNW2Float("SolFlameBar") >= 50 then
                ent:SetNW2Float("SolFlameBar", ent:GetNW2Float("SolFlameBar") - 15)
            end
            local entity = ent.blazeball
            if entity and IsValid(entity) then
                entity:SetParent(nil)
                timer.Simple(1,function()
                    if !IsValid(entity) then return end
                    entity:Remove()
                end)
            end
        end


        if ent:GetNW2Float('DashDurationWait') > CurTime() then
            ent:SetNW2Float('StartStunTime_soldash/kick',CurTime()+0.1)
            ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)
            ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
            if not ent:GetNW2Bool("Blaze_DashActivation") then

                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_NONE)
                else
                    --ply:SetMoveType(2)
                    if ply.loco then
                        ply.loco:SetVelocity(vector_origin)
                        ply.loco:SetDesiredSpeed(0)
                    end
                    ent.TeleportEnt = ent:GetPos()
                end

                ent:SetNW2Bool("Blaze_DashActivation", true)

                local effectdata = EffectData()
                effectdata:SetOrigin(ply:GetPos()+ply:GetAngles():Up()*30)
                util.Effect("SolDash_decrease_charge_blaze_om", effectdata)
                timer.Simple(0.25,function()
                    if !IsValid(ent) then return end

                    local effectdata = EffectData()
                    effectdata:SetOrigin(ply:GetPos()+ply:GetAngles():Up()*30)
                    util.Effect("SolDash_charge_blaze_om", effectdata)

                    for i=1,2 do
                        local effect = EffectData()
                        effect:SetOrigin(ent:GetPuppet():GetPos()+ Vector(0,0,35)+ent:GetPuppet():GetForward()*100)
                        effect:SetEntity(ent:GetPuppet())
                        effect:SetNormal(ent:GetPuppet():GetForward())
                        effect:SetMagnitude(650)
                        effect:SetScale(90)

                        util.Effect("ExpellSolFlame_blaze_impact", effect)
                    end
                end)
            end

            if ent:GetNW2Float('KickStarted_beep') < CurTime() then
                ent:SetNW2Float("KickStarted_beep", CurTime()+0.035)
                if not ent.BlazeAddupval then
                    ent.BlazeAddupval = 0
                end
                AdvancedPillSound(
                    {
                        stringe = "OM/blaze/blazebeep.wav",
                        pitchPercent = 90+ent.BlazeAddupval,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent.BlazeAddupval = ent.BlazeAddupval + 2.5
            end
            ply:SetLocalVelocity(Vector(0,0,0))
            ply:SetVelocity(Vector(0,0,0))

        else
            if ent:GetNW2Bool("Blaze_DashActivation") then
                ent:SetNW2Bool("Blaze_DashActivation", false)
                ent:SetNW2Float("CanDash", CurTime()+0.1)
                AdvancedPillSound(
                    {
                        stringe = "OM/blaze/roundhouse kick.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                if ent:GetNW2Float("SolFlameBar") >= 50 then
                    ent:SetNW2Bool("DrainDash", true)

                else
                    ent:SetNW2Float("SolDashStun", CurTime()+0.85)
                    ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.2)
                    ply:SetNW2Vector("OM_SetVelocity_Vector",ply:EyeAngles():Forward() * GetConVar("OUTCOMEMEMORIES_N_blaze_soldashspeed"):GetFloat())
                end
                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_WALK)
                else
                    ply:SetMoveType(0)
                    if SERVER then
                        ent.TeleportEnt = nil
                    end
                end
            end

            if ent:GetNW2Float("SolDashStun") > CurTime() then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                if not ent.SolDashStun_e then
                    ent.SolDashStun_e = true
                end
                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 100)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if Mutual_OMCanStun(ply, ent, ent2, GetConVar("OUTCOMEMORIES_N_blaze_SolDash_stunstack"):GetBool()) then

                            ply:SetNW2Float("OM_SetVelocity_pos", 0)
                            ent.formTable.Outcomememories_stats.abilities.KickNSoldash.StunEffect(ply,ent,ent2, "Dash")
                            ent:SetNW2Float('SolDashStun', 0)
                            ent:PillAnim('jump2')
                            ent:SetNW2Float('Kick/dash_cd', CurTime()+GetConVar("OUTCOMEMORIES_N_blaze_soldash_cooldownland"):GetFloat())
                            ent.SolDashStun_e = false
                        end
                    end
                end
            else
                if ent.SolDashStun_e then
                    ent.SolDashStun_e = false
                    ent:SetNW2Float('Kick/dash_cd', CurTime()+GetConVar("OUTCOMEMORIES_N_blaze_SolDash_cooldownmiss"):GetFloat())
                end
            end

            if ply:IsOnGround() then 
                ent:SetNW2Float('SolDashStun', 0)
            end

            if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then

                if ent:GetNW2Float("SolFlameBar") > 0 then
                    ent:SetNW2Float("SolFlameBar", ent:GetNW2Float("SolFlameBar") - 0.5)
                end

                ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.1)
                if ply:IsPlayer() then
                    ply:SetNW2Vector("OM_SetVelocity_Vector",ply:EyeAngles():Forward() * GetConVar("OUTCOMEMEMORIES_N_blaze_soldashspeed"):GetFloat())
                else
                end


                if not ent.firecdpartical then
                    ent.firecdpartical = 0
                end

                if ent.firecdpartical < CurTime() then
                    local effect = EffectData()
                    effect:SetOrigin(ply:GetPos()-Vector(0,0,60))
                    effect:SetNormal(ply:GetNW2Vector("OM_SetVelocity_Vector")*-1)
                    effect:SetMagnitude(750*2)
                    effect:SetScale(45)
                    effect:SetEntity(ply)

                    util.Effect("SolDash_blaze_om", effect)
                    ent.firecdpartical = CurTime() +0.1
                end


                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 100)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if Mutual_OMCanStun(ply, ent, ent2, GetConVar("OUTCOMEMORIES_N_blaze_SolDash_stunstack"):GetBool()) then

                            ent.formTable.Outcomememories_stats.abilities.KickNSoldash.StunEffect(ply,ent,ent2, "Dash")
                            ent:SetNW2Bool("DrainDash", false)
                            ent:PillAnim('jump2')
                            ent:SetNW2Float('OM_SetVelocity_pos', 0)
                            ent:SetNW2Float('Dash_Duration', 0)
                            ent:SetNW2Float('CanDash', 0)
                            ent:SetNW2Float('Kick/dash_cd', CurTime()+GetConVar("OUTCOMEMORIES_N_blaze_soldash_cooldownland"):GetFloat())
                        end
                    end
                end
            else
                if ent:GetNW2Bool("DrainDash") then
                    ent:SetNW2Bool("DrainDash", false)
                    ent:SetNW2Float('Kick/dash_cd', CurTime()+GetConVar("OUTCOMEMORIES_N_blaze_SolDash_cooldownmiss"):GetFloat())
                    ent:SetNW2Float("SolDashStun", CurTime()+0.5)
                end
            end
        end

        if ent:GetNW2Bool("ExpellSolFlame") then

            if ent:GetNW2Float('BlazeBeepingsfx') < CurTime() then
                if not ent.ExpellSolFlameBool then
                    ent.ExpellSolFlameBool = true

                    local ed = EffectData()

                    ed:SetOrigin(ent:GetPuppet():GetPos()+ Vector(0,0,35)+ent:GetPuppet():GetForward()*75)
                    ed:SetEntity(ent:GetPuppet())
                    ed:SetNormal(ent:GetForward())
                    ed:SetScale(1)
                    ed:SetMagnitude(1)

                    util.Effect("SolFlame_expell_blaze_om", ed)


                    for i=1,4 do
                        local effect = EffectData()
                        effect:SetOrigin(ent:GetPuppet():GetPos()+ Vector(0,0,35)+ent:GetPuppet():GetForward()*100)
                        effect:SetEntity(ent:GetPuppet())
                        effect:SetNormal(ent:GetPuppet():GetForward())
                        effect:SetMagnitude(650)
                        effect:SetScale(35)

                        util.Effect("ExpellSolFlame_blaze_impact", effect)
                    end


                end

                local function FindInCone(origin, direction, distance, angle)
                    local found = {}
                    direction = direction:GetNormalized()

                    local entities = ents.FindInSphere(origin, distance)

                    for _, ent2 in ipairs(entities) do
                        if IsValid(ent2) then
                            local dirToEnt = (ent2:GetPos() - origin)
                            local dist = dirToEnt:Length()

                            if dist > 0 then
                                dirToEnt:Normalize()

                                local dot = direction:Dot(dirToEnt)
                                local deg = math.deg(math.acos(dot))

                                if deg <= angle then
                                    table.insert(found, ent2)
                                end
                            end
                        end
                    end

                    if not ent.firecdpartical then
                        ent.firecdpartical = 0
                    end

                    ent:SetNW2Vector("direction_blaze",direction)

                    if ent.firecdpartical < CurTime() then
                        local ed = EffectData()
                        ed:SetEntity(ent)
                        ed:SetOrigin(ent:GetPos() + Vector(0,0,25)+direction*40)
                        ed:SetNormal(direction)
                        ed:SetMagnitude(distance)
                        ed:SetScale(angle)

                        util.Effect("ExpellSolFlame_blaze", ed)
                        ent.firecdpartical = CurTime() +0.1
                    end

                    local ed = EffectData()
                    ed:SetEntity(ent)
                    ed:SetOrigin(ent:GetPos() + Vector(0,0,20)+direction*40)
                    ed:SetNormal(direction)
                    ed:SetMagnitude(distance)
                    ed:SetScale(angle)

                    util.Effect("ExpellSolFlame_blaze_fire", ed)

                    return found
                end

                local targets = FindInCone(ply:GetPos() + Vector(0,0,35)-ply:GetForward()*20, ply:GetAimVector(), 650, 50)

                for _, ent2 in ipairs(targets) do
                    if not IsValid(ent2) then continue end
                    if ent2 == ply then continue end

                    local pushDir = ((ent2:GetPos() + Vector(0,0,0)) - ply:GetPos()):GetNormalized()
                    local pushForce = 1250

                    if (ent2:IsPlayer() or ent2:IsNPC() or ent2:IsNextBot()) and ent2:Health() > 0.1 then
                        if ent2:GetNW2Bool("OM_character") and not GetConVar("PVPStun_OM"):GetBool() then continue end

                        if ent2:IsOnGround() then
                            if ent2:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime() then
                                ent2:SetPos(ent2:GetPos() + Vector(0,0,15))
                            end
                        end

                        if ent2.loco then
                            ent2.loco:SetVelocity(vector_origin)
                            ent2.loco:SetDesiredSpeed(0)
                        end
                        if ent2:IsPlayer() then
                            ent2:SetVelocity(pushDir * 175)
                            ent2:SetLocalVelocity(pushDir * 175)
                        elseif ent2:IsNextBot() then
                            ent2:SetVelocity(pushDir * pushForce)
                            ent2:SetLocalVelocity(pushDir * pushForce)
                        else
                            ent2:SetVelocity(pushDir * 275)
                            ent2:SetLocalVelocity(pushDir * 275)
                        end

                        if ent2:GetNW2Float("Blaze_solflamesoundcd") < CurTime() then
                            AdvancedPillSound({
                                stringe = "OM/blaze/swoosh.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 90
                            }, ent2)
                        end

                        if ent2:GetNW2Float("Blaze_solflamesoundcd_e") < CurTime() then
                            local effect = EffectData()
                            effect:SetOrigin(ent2:GetPos()+ Vector(0,0,35))
                            effect:SetNormal(ent2:GetForward()*-1)
                            effect:SetMagnitude(650)
                            effect:SetScale(35)
                            effect:SetEntity(ent2)

                            util.Effect("ExpellSolFlame_blaze_impact", effect)
                            ent2:SetNW2Float("Blaze_solflamesoundcd_e", CurTime() + 0.25)
                        end

                        OM_burntarget(ply, ent2, 1.35, true)
                        ent2:SetNW2Float("Blaze_solflamesoundcd", CurTime() + 0.5)

                    else
                        local phys = ent2:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:Wake()
                            
                            local physForce = (pushDir + Vector(0,0,0.1)) * pushForce * 2

                            phys:ApplyForceCenter(physForce)
                        end
                    end
                end

                if ent:GetNW2Float("SolFlameBar") > 0 then
                    ent:SetNW2Float("SolFlameBar", ent:GetNW2Float("SolFlameBar") - 0.25 )
                else
                    ent:SetNW2Float("SolFlameBar", 0 )
                    ent:SetNW2Bool("ExpellSolFlame", false)
                    ent:SetNW2Float('Javelin/flame_cd', CurTime()+GetConVar("OUTCOMEMORIES_N_blaze_solflame_cooldown"):GetFloat())
                end
            end
        else
            if ent.ExpellSolFlameBool then
                ent.ExpellSolFlameBool = false
            end
        end

        if ent:GetNW2Float("throwingduration_anim") > CurTime() then
            ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)
            ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if ply:GetNW2Bool("Survivor_Downed_OM") then return end
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() or IsValid(ply:GetNWEntity("OM_ragdollentity")) then
                return
            end

            if button == ply:GetInfoNum("om_pills_action_blaze_abillty1_key", KEY_E) then
                if ent:GetNW2Float('Kick/dash_cd') > CurTime() then return end
                if ent:GetNW2Float("SolDashStun") > CurTime() then return end

                if ent:GetNW2Float('KickDurationWait') > CurTime() then return end
                if ent:GetNW2Float('DashDurationWait') > CurTime() then return end
                if ent:GetNW2Bool("Blaze_kickActivation") then return end
                if ent:GetNW2Bool("Blaze_DashActivation") then return end
                if ent:GetNW2Float('KickStarted_beep') > CurTime() then return end

                if ent:GetNW2Float('throwingduration') > CurTime() then return end

                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return end
                if ent:GetNW2Bool("Blaze_kicking") then return end
                if ent:GetNW2Bool("ExpellSolFlame") then return end

                if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then return end

                if ent:GetNW2Bool("Blaze_kicking") and ent:GetNW2Float('KickStarted') < CurTime() then return end

                local solgain = false

                if ent:GetNW2Float("SolFlameBar") >= 50 then
                    solgain = true
                end

                ent.BlazeAddupval = 0
                if ply:IsOnGround() then

                    if not GetConVar("OUTCOMEMORIES_N_blaze_kick_useable"):GetBool() then return end
                    if solgain then
                        ent:SetNW2Float("KickDurationWait", CurTime()+0.6)
                        ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.6)
                        ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.6)
                        --ply:SetNW2Float("NoJumpingCooldown_OM", CurTime()+0.4)
                    else
                        ent:SetNW2Float("KickDurationWait", CurTime()+0.35)
                        ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.35)
                        ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.35)
                        --ply:SetNW2Float("NoJumpingCooldown_OM", CurTime()+0.4)
                    end

                else

                    if not GetConVar("OUTCOMEMORIES_N_blaze_SolDash_useable"):GetBool() then return end

                    if solgain then
                        ent:SetNW2Float("DashDurationWait", CurTime()+0.7)
                    else
                        ent:SetNW2Float("DashDurationWait", CurTime()+0.6)
                    end
                end
            end
            if button == ply:GetInfoNum("om_pills_action_blaze_abillty2_key", KEY_R) then
                if ent:GetNW2Float('Javelin/flame_cd') > CurTime() then return end

                if ent:GetNW2Float("SolDashStun") > CurTime() then return end
                if ent:GetNW2Float('KickDurationWait') > CurTime() then return end
                if ent:GetNW2Float('throwingduration') > CurTime() then return end

                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return end
                if ent:GetNW2Bool("Blaze_kicking") then return end
                if ent:GetNW2Bool("ExpellSolFlame") then return end
                if ( ent:GetNW2Float("SolFlameBar") > 0 and ent:GetNW2Bool("DrainDash") ) or ent:GetNW2Float("CanDash") > CurTime() then return end


                if ent:GetNW2Float("SolFlameBar") >= 50 then
                    if not GetConVar("OUTCOMEMORIES_N_blaze_solflame_useable"):GetBool() then return end
                    ent:SetNW2Bool("ExpellSolFlame", true)
                    ent:SetNW2Float("BlazeBeepingsfx", CurTime()+0.45)
                    ent.BlazeAddupval = 0

                    --[[
                    AdvancedPillSound(
                        {
                            stringe = "OM/blaze/firestorm.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 90
                        },
                        ent
                    )
                    ]]

                else
                    if not GetConVar("OUTCOMEMORIES_N_blaze_javelin_useable"):GetBool() then return end
                    ent:SetNW2Float('Javelin/flame_cd', CurTime()+GetConVar("OUTCOMEMORIES_N_blaze_javelin_cooldown"):GetFloat())
                    ent:SetNW2Float("throwingduration", CurTime()+1)
                    ent:SetNW2Float("throwingduration_anim", CurTime()+0.5)

                    AdvancedPillSound(
                        {
                            stringe = "OM/blaze/burning javelin.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )


                    local javelin = ents.Create("ent_om_blaze_javelin_hold")
                    if IsValid(javelin) then
                        javelin:SetPos(ent:GetPuppet():GetPos())
                        javelin:SetPillUser(ent:GetPuppet())
                        javelin:Spawn()

                        ent:DeleteOnRemove(javelin)
                        ent:SetNW2Entity("ent_om_mighty_rock_display", javelin)

                        javelin:GetPuppet():SetNW2Float("CounterOM_duration", CurTime()+0.35)
                    end

                    ent:GetPuppet():SetLayerPlaybackRate(ent:GetPuppet():AddGestureSequence(ent:GetPuppet():LookupSequence("throw")), ent:GetPuppet():SequenceDuration(ent:GetPuppet():LookupSequence("throw"))/1)
                
                    timer.Simple(0.45, function()
                        if not IsValid(ent) then return end
                        if not IsValid(ply) then return end

                        local puppet = ent:GetPuppet()
                        if not IsValid(puppet) then return end


                        puppet:SetNW2Float("CounterOM_duration", CurTime()+0.35)

                        if IsValid(javelin) then javelin:Remove() end

                        local startPos = puppet:GetPos() + puppet:GetUp() * 40
                        local direction = ply:GetAimVector():GetNormalized()

                        local prop = ents.Create("prop_physics")
                        prop:SetModel("models/props_junk/harpoon002a.mdl")
                        prop:SetPos(startPos + direction * 25)
                        prop:SetAngles(direction:Angle())
                        prop:Spawn()
                        prop:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

                        prop:SetMaterial("icons/blaze_trail")
                        prop:SetColor(Color(217,217,217,255))

                        prop:SetNW2Float("CounterOM_duration", CurTime()+0.25)

                        local trailFoot1 = util.SpriteTrail(
                            prop,
                            0,
                            Color(255, 255, 255),
                            true,
                            25,
                            2,
                            0.2,
                            0.2,
                            "icons/blaze_trail"
                        )

                        prop:SetNWEntity("NoCollideEntity_om", ply)

                        prop:DeleteOnRemove(trailFoot1)
                        ent:DeleteOnRemove(prop)
                        prop:ManipulateBoneScale(0,Vector(1,6.11,6.11))
                        
                        local function setvelocityofphysics()
                            local phys = prop:GetPhysicsObject()
                            if IsValid(phys) then
                                phys:EnableMotion(true)
                                phys:EnableDrag(false)
                                phys:EnableGravity(false)
                                phys:SetVelocity(direction * 10000)
                            end
                        end
                        setvelocityofphysics()
                        
                        local attachedTarget = NULL
                        local removeTime = CurTime() + 2

                        local followHook = "PropFollow_" .. prop:EntIndex()

                        hook.Add("Think", followHook, function()
                            if not IsValid(prop) then
                                hook.Remove("Think", followHook)
                                return
                            end

                            if IsValid(attachedTarget) then

                            
                                local desiredPos = prop:GetPos() + prop:GetForward() * 0
                                local mins, maxs = attachedTarget:OBBMins(), attachedTarget:OBBMaxs()

                                local tr = util.TraceHull({
                                    start  = attachedTarget:GetPos(),
                                    endpos = desiredPos,
                                    mins   = mins,
                                    maxs   = maxs,
                                    filter = function(ent)
                                        if ent == attachedTarget then return false end
                                        if ent == prop then return false end
                                        return true
                                    end,
                                    mask = MASK_SOLID
                                })

                                if tr.Hit then
                                    local safePos = tr.HitPos + tr.HitNormal * 1
                                    attachedTarget:SetPos(safePos)
                                else
                                    attachedTarget:SetPos(desiredPos)
                                end

                                if attachedTarget.loco then
                                    attachedTarget.loco:SetVelocity(vector_origin)
                                    attachedTarget.loco:SetDesiredSpeed(0)
                                end
                                attachedTarget:SetVelocity((direction * 10000) * FrameTime())
                            else
                                for _, v in ipairs(ents.FindInSphere(prop:GetPos(), 25)) do
                                    if IsValid(v) and (v:IsPlayer() or v:IsNPC() or v:IsNextBot()) and v:Health() > 0.1 then
                                        if v == ply then continue end
                                        if v:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then continue end

                                        attachedTarget = v

                                        local amount = GetConVar("OUTCOMEMORIES_N_blaze_javelin_solflamemeter"):GetFloat()
                                        ent:SetNW2Float("SolFlameBar", ent:GetNW2Float("SolFlameBar") + amount)
                                        if ent:GetNW2Float("SolFlameBar") > 100 then
                                            ent:SetNW2Float("SolFlameBar", 100)
                                        end

                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/blaze/blaze javelin hit.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 90
                                            },
                                            prop
                                        )

                                        removeTime = CurTime() + 0.5
                                        
                                    end
                                end
                            end

                            setvelocityofphysics()
                            
                            if removeTime and CurTime() >= removeTime then
                                hook.Remove("Think", followHook)

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/blaze/snd_impact.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 90
                                    },
                                    prop
                                )
                                if attachedTarget and IsValid(attachedTarget) then 
                                    if attachedTarget.loco then
                                        attachedTarget.loco:SetVelocity(Vector(0,0,0))
                                        attachedTarget.loco:SetDesiredSpeed(0)
                                    end
                                    attachedTarget:SetVelocity(Vector(0,0,0))
                                    attachedTarget:SetLocalVelocity(Vector(0,0,0))

                                end
                                if IsValid(prop) then
                                    prop:Remove()
                                end
                            end
                        end)

                        hook.Add("EntityTakeDamage", "disableAmy_hammerProp_damage_OM_" .. prop:EntIndex(), function(target, dmginfo)
                            if !IsValid(target) or not dmginfo then return end

                            local damager = dmginfo:GetAttacker()
                            if !IsValid(damager) then return end

                            if damager == prop then
                                dmginfo:SetDamage(0)
                                dmginfo:SetDamageType(DMG_GENERIC)
                                return true
                            end
                        end)

                        prop:AddCallback("PhysicsCollide", function(prop, colData)
                            if !IsValid(prop) then return end

                            local hit = colData.HitEntity
                            if IsValid(hit) and (hit:IsPlayer() or hit:IsNPC() or hit:IsNextBot()) then
                                setvelocityofphysics()
                                return
                            end

                            prop:SetMoveType(MOVETYPE_NONE)
                            prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

                            AdvancedPillSound(
                                {
                                    stringe = "OM/blaze/snd_impact.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 90
                                },
                                prop
                            )

                            local fadeTime = 0.3
                            local start = CurTime()
                            local hookID = "FadeProp_" .. prop:EntIndex()

                            hook.Add("Think", hookID, function()
                                if !IsValid(prop) then
                                    hook.Remove("Think", hookID)
                                    return
                                end

                                local delta = (CurTime() - start) / fadeTime
                                if delta >= 1 then
                                    hook.Remove("Think", hookID)
                                    prop:Remove()
                                    return
                                end

                                prop:SetRenderMode(RENDERMODE_TRANSALPHA)
                                prop:SetColor(Color(255,255,255,255 * (1 - delta)))
                            end)
                        end)
                    end)
                end
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
        ent:PillAnim('jump2')

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

local preservedmats = {
    ["Cream_heal"] = Material("icons/Cream_heal.png"),
    ["Cream_dash"] = Material("icons/Cream_dash.png")
}

pk_pills.register('pill_om_Cream', {

    printName='Cream',
    Outcomememories='cream',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/cream.mdl",
    
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
            attack = "attack",
            jump2 = "jump",
            HealStart = "HealStart",
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
                if ent:GetNW2Bool("GlideTime") then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            jump= function(ent) 
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            idle= function(ent)
                if ent:GetNW2Bool("Cream_Healing_debounce") then return "HealIdle" end
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "idle_lowhealth"
                end 
            end,
            walk= function(ent) 
                if ent:GetNW2Bool("Cream_Healing_debounce") then return "HealIdle" end
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "walk_lowhealth"
                end 
            end,
            fall= function(ent) 
                if ent:GetNW2Bool("Cream_Healing_debounce") then return "HealIdle" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool("GlideTime") then
                    return "glide"
                end
            end,
            run= function(ent) 
                if ent:GetNW2Bool("Cream_Healing_debounce") then return "HealIdle" end
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "run_lowhealth"
                end 
            end,
        },
    },

    ShouldRoll_om = function(e, ply, ent)
        return true
    end,

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
            
        }
    }, 

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return 35
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return 410
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return 35
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

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Cream_heal"]
            end,
            name = function(uselessvar,ply,ent)
                return "Heal"
            end,
            keybind = function(uselessvar,ply,ent)
                return "E"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Cream_heal_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 15
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Cream_dash"]
            end,
            name = function(uselessvar,ply,ent)
                return "Dash"
            end,
            keybind = function(uselessvar,ply,ent)
                return "T"
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Cream_Dash_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 15
            end,
            survivor = true,
            font = "CreditsText",
        }
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
        end
        initializetable2["player"]:SetNW2Bool("OM_character", true)
        initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
        initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)



        local ply = initializetable2["player"]
        local ent = initializetable2["entity"]

        if SERVER then

            local prop = ents.Create("prop_physics")
            if IsValid(prop) then
                prop:SetModel("models/Noodles/OM/cheese.mdl")
                prop:SetPos(ply:GetPos() + ent:GetPuppet():GetRight() * 100 + ent:GetPuppet():GetUp()*40)
                prop:Spawn()

                prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
                prop:SetMoveType(MOVETYPE_NOCLIP)
                prop:SetSolid(SOLID_NONE)
                prop:DrawShadow(false)

                prop:SetNotSolid(true)
                prop:SetNoDraw(false)

                prop:AddEFlags(EFL_DONTBLOCKLOS)
                prop:SetTrigger(false)

                ent:DeleteOnRemove(prop)
                ent:SetNW2Bool("HasCheese", true)

                local physicsname = "BlockPhysgun_" .. prop:EntIndex()
                prop:CallOnRemove("CleanupHooks", function()
                    hook.Remove("PhysgunPickup", physicsname)
                    hook.Remove("CanTool", physicsname)
                    hook.Remove("EntityTakeDamage", physicsname)
                    hook.Remove("Think", physicsname)
                end)

                hook.Add("PhysgunPickup", physicsname, function(p, ent)
                    if ent == prop then return false end
                end)
                hook.Add("CanTool", physicsname, function(p, tr, tool)
                    if IsValid(tr.Entity) and tr.Entity == prop then
                        return false
                    end
                end)
                hook.Add("EntityTakeDamage", physicsname, function(ent, dmg)
                    if ent == prop then
                        return true
                    end
                end)

                hook.Add("Think", physicsname, function()
                    if !IsValid(prop) or !IsValid(ply) or !IsValid(ent) then return end

                    if not ent:GetNW2Bool("HasCheese") then prop:Remove() end

                    local puppet = ent:GetPuppet()
                    if !IsValid(puppet) then return end

                    local targetPos = ply:GetPos() + puppet:GetRight() * 30 + puppet:GetUp() * 20
                    local lerpSpeed = 10
                    local newPos = LerpVector(FrameTime() * lerpSpeed, prop:GetPos(), targetPos)

                    prop:SetPos(newPos)

                    prop:SetAngles(ent:GetPuppet():GetForward():Angle())
                end)

            end

        end
    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetNW2Bool("ShoukdntStun_OM_Noodles", false)
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetGravity(1)
        end
        initializetable2["entity"]:StopSound("OM/cream/HealLoop.wav")
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", 1)
            if ply:IsOnGround() then
                ent:SetNW2Float("DashDuration", 0)
                ent:SetNW2Bool("GlideTime", false)
                ent:SetNW2Bool("DisabledGlind", false)
            end
            if ent:GetNW2Bool("HasCheese") then
                if ply:Health() <= 30 then
                    ent:SetNW2Bool("HasCheese", false)
                    AdvancedPillSound(
                        {
                            stringe = "OM/cream/CheeseDead.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            end
            if ent:GetNW2Bool("GlideTime") and not ent:GetNW2Bool("DisabledGlind") then
                local vel = ply:GetVelocity()
                if vel.z < 0 then
                    local velo = ent:GetPuppet():GetForward()*430 + ent:GetPuppet():GetUp()* -40
                    ply:SetVelocity(velo)
                    ply:SetLocalVelocity(velo)
                end
                ply:SetGravity(0.3)
            else
                ply:SetGravity(1)
            end

            if (ent:GetNW2Bool("GlideTime") or ent:GetNW2Float("DashDuration") > CurTime()) and not ply:IsOnGround() then
                
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                
                local startPos = ply:GetPos()
                local endPos = startPos + ply:GetForward() * 30

                local tr = util.TraceLine({
                    start = startPos,
                    endpos = endPos,
                    filter = ply,
                    mask = MASK_SOLID
                })

                local function latching( )   
                    local normal = tr.HitNormal

                    if math.abs(normal.z) < 0.5 then
                        ent:SetNW2Bool("GlideTime", false)
                        ent:SetNW2Bool("DisabledGlind", true)
                        ent:SetNW2Float("DashDuration", 0)
                        local vel2 = ent:GetPuppet():GetForward() * -200
                        vel2.z = 100
                        if ply:IsPlayer() then
                            ply:SetPos(ply:GetPos()+ply:GetUp()*5)
                        else
                            ply:SetPos(ply:GetPos()+ply:GetUp()*40)
                        end
                        ply:SetVelocity(vel2)
                        ply:SetLocalVelocity(vel2)
                        ent:SetNW2Float("DashDuration", CurTime()-1)

                        AdvancedPillSound(
                            {
                                stringe = "OM/cream/Wallhit.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end
                end
                if tr.Hit then
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

            if ent:GetNW2Float("DashDuration") > CurTime() then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 90)) do
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if IsValid(ent2) then

                            local vel2 = ent:GetPuppet():GetForward() * -400
                            vel2.z = 100
                            if ply:IsPlayer() then
                                ply:SetPos(ply:GetPos()+ply:GetUp()*5)
                            else
                                ply:SetPos(ply:GetPos()+ply:GetUp()*40)
                            end
                            ply:SetVelocity(vel2)
                            ply:SetLocalVelocity(vel2)
                            ent:SetNW2Float("DashDuration", CurTime()-1)

                            local vel2 = (ent2:GetPos() - ent:GetPos()):GetNormalized() * 900
                            vel2.z = 200
                            if ent2:IsPlayer() then
                                ent2:SetPos(ent2:GetPos()+ent2:GetUp()*5)
                            else
                                ent2:SetPos(ent2:GetPos()+ent2:GetUp()*40)
                            end
                            ent2:SetVelocity(vel2)
                            ent2:SetLocalVelocity(vel2)

                            AdvancedPillSound(
                                {
                                    stringe = "OM/cream/DashHit.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )

                            local damage = 800
                            if ent:GetNW2Float("OM_SpeedBoost_Damage") > 0 then
                                ent:SetNW2Float( "OM_SpeedBoost_Damage", ent:GetNW2Float("OM_SpeedBoost_Damage") + damage)
                            else
                                ent:SetNW2Float( "OM_SpeedBoost_Damage", damage)
                            end
                            timer.Simple(5,function()
                                if !IsValid(ent) then return end
                                ent:SetNW2Float( "OM_SpeedBoost_Damage", ent:GetNW2Float("OM_SpeedBoost_Damage") - damage)
                            end)
                            damagestun(ply, ply, 20, DMG_GENERIC, true)

                            break
                        end
                    end
                end
            end
            if ent:GetNW2Float("Cream_healingduration") > CurTime() then
                ply:SetNW2Float("OM_NoMovement_noodles", 0.1 + CurTime())
                ent:SetNW2Bool('Cream_Healing_debounce', true)
                if ent:GetNW2Float("Cream_healingNextstep") > CurTime() then
                else
                    local effectdata = EffectData()
                    effectdata:SetOrigin(ent:GetPos()+Vector(0,0,30))
                    util.Effect("cream_healing_upwards", effectdata)
                    
                    local counter = 0
                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 90)) do
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                            if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then else continue end
                            if ent2:GetNW2Bool("NoHealing_OM_Noodles") then continue end

                            if IsValid(ent2) then
                                counter = counter + 1

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/cream/Heal.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                        },
                                    ent2
                                )

                                local effectdata = EffectData()
                                effectdata:SetEntity(ent2)
                                util.Effect("cream_heal_orbit2", effectdata)
                                
                                local effectdata = EffectData()
                                effectdata:SetOrigin(ent2:GetPos()+Vector(0,0,15))
                                util.Effect("cream_healing_diamond", effectdata)

                                if ent2:Health() >= 100 then 
                                    ent2:SetHealth(100)
                                    continue end
                                local currenthealth = 10
                                if ent:GetNW2Bool("HasCheese") then
                                else
                                    currenthealth = 5
                                end
                                ent2:SetHealth(ent2:Health() + currenthealth)
                            end
                        end
                    end
                    ent:SetNW2Float("Cream_healingNextstep", CurTime() + 1)
                    if counter <= 0 then
                        ent:SetNW2Float("Cream_healingduration", CurTime() + 0.9)
                    end
                end
            else
                if ent:GetNW2Bool("Cream_Healing_debounce") then
                    ent:SetNW2Bool('Cream_Healing_debounce', false)
                    ent:SetNW2Float("Cream_heal_cd", CurTime() + 15 )
                end
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if button == KEY_SPACE then

            if ent:GetNW2Bool("DisabledGlind") then return end
            if ent:GetNW2Bool("Cream_Healing_debounce") then return end
            if ent:GetNW2Float("GlideDebounce") > CurTime() then return end
            if ply:IsOnGround() then return end
            
            ent:SetNW2Bool("GlideTime", true)
        end
        if button == KEY_E then
            if not ply:IsOnGround() then return end
            if ent:GetNW2Bool("Cream_Healing_debounce") then return end
            if ent:GetNW2Float("Cream_healingduration") > CurTime() then return end
            AdvancedPillSound(
                {
                    stringe = "OM/cream/HealStart.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                    },
                ent
            )

            if ply:Health() < 100 then
                local currenthealth = 10
                if ent:GetNW2Bool("HasCheese") then
                else
                    currenthealth = 5
                end
                ply:SetHealth(ply:Health() + currenthealth)
            end

            ent:PillAnim("HealStart")
            
            local effectdata = EffectData()
            effectdata:SetOrigin(ent:GetPos()+Vector(0,0,30))
            util.Effect("cream_healing_upwards", effectdata)

            local effectdata = EffectData()
            effectdata:SetOrigin(ent:GetPos()+Vector(0,0,10))
            util.Effect("cream_healing_diamond", effectdata)

            local effectdata = EffectData()
            effectdata:SetEntity(ply)
            util.Effect("cream_heal_orbit2", effectdata)
            
            ent:SetNW2Float("Cream_healingduration", CurTime() + 7.1)
            ent:SetNW2Float("Cream_healingNextstep", CurTime() + 1)

            local snd = CreateSound(ent, "OM/cream/HealLoop.wav")
            snd:SetSoundLevel(87)
            snd:PlayEx(0, 100)

            local fadeTime = 0.75
            local startTime = CurTime()
            local hookID = "HealLoopFade_" .. ent:EntIndex()

            hook.Add("Think", hookID, function()

                if not IsValid(ent) then
                    snd:Stop()
                    hook.Remove("Think", hookID)
                    return
                end

                local remaining = ent:GetNW2Float("Cream_healingduration", 0) - CurTime()
                local elapsed = CurTime() - startTime

                if remaining > 0 then

                    if elapsed < fadeTime then
                        local volume = math.Clamp(elapsed / fadeTime, 0, 1)
                        snd:ChangeVolume(volume, 0)
                    else
                        snd:ChangeVolume(1, 0)
                    end

                else
                    local fadeOutElapsed = math.abs(remaining)

                    if fadeOutElapsed < fadeTime then
                        local volume = math.Clamp(1 - (fadeOutElapsed / fadeTime), 0, 1)
                        snd:ChangeVolume(volume, 0)
                    else
                        snd:Stop()
                        hook.Remove("Think", hookID)
                    end
                end
            end)
        end
        if button == KEY_T then
            if ent:GetNW2Float("Cream_Dash_cd") > CurTime() then return end
            ent:SetNW2Float("Cream_Dash_cd", CurTime() + 15 )
            ent:SetNW2Float("Cream_healingduration", 0)
            if ply:IsOnGround() then
                if ply:IsPlayer() then
                    ply:SetPos(ply:GetPos()+ply:GetUp()*5)
                else
                    ply:SetPos(ply:GetPos()+ply:GetUp()*40)
                end
            end
            ent:SetNW2Float("DashDuration", CurTime()+1)

            AdvancedPillSound(
                {
                    stringe = "OM/cream/Dash.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )

            if ent:GetNW2Bool("GlideTime") then return end
            local vel2 = ent:GetPuppet():GetForward() * 500
            vel2.z = 145
            ply:SetVelocity(vel2)
            ply:SetLocalVelocity(vel2)

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
        ent:PillAnim('jump2')
        ent:SetNW2Float("GlideDebounce", CurTime()+0.65)

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


local preservedmats = {
    ["cannon_bar"] = Material("icons/cannon_bar.png"),
    ["tails_abilitycannon"] = Material("icons/tails_abilitycannon.png"),
    ["tails_abilityfly"] = Material("icons/tails_abilityfly.png"),

    ["shadow_icon_reload"] = Material("icons/shadow_icon_reload.png"),
    
    ["laser_cannon"] = Material("icons/laser_cannon.png"),
    ["SQUARE_BLUE"] = Material("icons/SQUARE_BLUE.png"),
    
    ["blast_cannon"] = Material("icons/blast_cannon.png"),
    ["SQUARE_GREEN"] = Material("icons/SQUARE_GREEN.png"),
    
    ["orbs_cannon"] = Material("icons/orbs_cannon.png"),
    ["SQUARE_RED"] = Material("icons/SQUARE_RED.png"),
    
    ["shockwave_cannon"] = Material("icons/shockwave_cannon.png"),
    ["SQUARE_YELLOW"] = Material("icons/SQUARE_YELLOW.png"),
}

-- tripwire mouse handeler
if SERVER then
    util.AddNetworkString("tails_recieve_mouse")
    util.AddNetworkString("tails_retrieve_mouse")

    net.Receive("tails_recieve_mouse", function()
        local ply = net.ReadEntity()
        local hitPos = net.ReadVector()

        local pillentity = ply.pk_pill_ent
        
        if IsValid(pillentity) then
            if pillentity.formTable.SetShootPoint then
                pillentity.formTable.SetShootPoint(ply, pillentity, hitPos)
            end
        end
    end)
else
    local function GetTrueMouseHitPos(ply)
        local view = render.GetViewSetup()
        local startPos = view.origin

        local mx, my = gui.MousePos()
        local screenW, screenH = ScrW(), ScrH()
        local middlex, middley = screenW * 0.5, screenH * 0.5
        if mx == 0 and my == 0 then 
            mx = middlex
            my = middley
        end

        local dir = gui.ScreenToVector(mx, my)

        local tr = util.TraceLine({
            start = startPos,
            endpos = startPos + dir * 10000,
            filter = ply,
            mask = MASK_ALL
        })

        return tr.HitPos
    end
    net.Receive("tails_retrieve_mouse", function()
        local ply = LocalPlayer()

        net.Start("tails_recieve_mouse")
            net.WriteEntity(ply)
            net.WriteVector(GetTrueMouseHitPos(ply))
        net.SendToServer()
    end)
end

local beamMat = {
    [0] = Material("icons/tailslaser"),
    [1] = Material("icons/tripwirereachout"),
    [2] = Material("icons/tails_blast"),
    [3] = Material("trails/electric")
}
local tailsmat = {
    [1] = Material("icons/tails fly yellow layer 1.png"),
    [2] = Material("icons/tails fly yellow layer 2.png"),
    [3] = Material("icons/tails fly white layer 1.png"),
    [4] = Material("icons/tails fly white layer 2.png"),
}

local cd = 30
pk_pills.register('pill_om_tails', {

    printName='Tails',
    Outcomememories='Tails',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/Tails.mdl",
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',
        

    OM_transitionbar_type1table = {
        ColorDisplay = Color(165,75,0,255),
        CanShowcase = function(e,ply, ent)
            return ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime()
        end,
        Factor = function(e,ply, ent)
            return math.Clamp((ent:GetNW2Float("OM_Tails_flyingDuration")-CurTime())/ent:GetNW2Float("OM_Tails_flyingDuration_numb"), 0, 1)
        end
    },

    OM_UI_custom1 = function(ply, ent)
        local screenW, screenH = ScrW(), ScrH()
        local iconsize = screenW / 13
        local yaxis_cards = screenH - iconsize * 2.7
 
        local xarea = iconsize * 2.1
        local yarea = yaxis_cards - iconsize * 0.25
        local xsize = iconsize * 2.4
        local ysize = iconsize * 2

        local barmat, nozzlemat, cannontype, colorbar = preservedmats["laser_cannon"], preservedmats["SQUARE_BLUE"], "Laser", Color(0,0,255,255)

        if ent:GetNW2Float("Traverse_bar", 0) == 1 then
            barmat = preservedmats["blast_cannon"]
            nozzlemat = preservedmats["SQUARE_GREEN"]
            cannontype = "Burst"
            colorbar = Color(0,255,0,255)
        elseif ent:GetNW2Float("Traverse_bar", 0) == 2 then
            barmat = preservedmats["orbs_cannon"]
            nozzlemat = preservedmats["SQUARE_RED"]
            cannontype = "Orbs"
            colorbar = Color(255,0,0,255)
        elseif ent:GetNW2Float("Traverse_bar", 0) == 3 then
            barmat = preservedmats["shockwave_cannon"]
            nozzlemat = preservedmats["SQUARE_YELLOW"]
            cannontype = "Shockwave"
            colorbar = Color(255,255,0,255)
        end
        local id = 0
        local function drawbar(factor)
            local stringvar = "tailsbar_sliding".. id
            if not ent[stringvar] then ent[stringvar] = factor end
            ent[stringvar] = Lerp(FrameTime() * 8, ent[stringvar], factor)

            local clamp = Lerp(ent[stringvar],0.17,0.8)
            surface.SetMaterial(preservedmats["cannon_bar"])
            surface.DrawTexturedRectUV(
                xarea,
                yarea,
                xsize*clamp,
                ysize,
                0, 0, 1*clamp, 1
            )
            id = id + 1
        end

        surface.SetDrawColor(255,0,0,255)
        drawbar(1)


        if not ent.LerpBar_tails_cannon_green then
            ent.LerpBar_tails_cannon_green = 0
        end
        local targetval = ent:GetNW2Float("Tails_barbuildup_green",0)/100

        ent.LerpBar_tails_cannon_green = Lerp(FrameTime() * 8, ent.LerpBar_tails_cannon_green, targetval)
        surface.SetDrawColor(0,255,0,255)
        drawbar( ent.LerpBar_tails_cannon_green )


        if not ent.LerpBar_tails_cannon_yellow then
            ent.LerpBar_tails_cannon_yellow = 0
        end
        local targetval = ent:GetNW2Float("Tails_barbuildup_yellow",0)/100

        ent.LerpBar_tails_cannon_yellow = Lerp(FrameTime() * 8, ent.LerpBar_tails_cannon_yellow, targetval)
        surface.SetDrawColor(255,255,0,255)
        drawbar( ent.LerpBar_tails_cannon_yellow )


        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(barmat)
        surface.DrawTexturedRect(xarea, yarea, xsize, ysize)    
        
        local multiply = Lerp( math.Clamp(ent:GetNW2Float("Traverse_bar", 0)/3, 0, 1) ,2.75, 3.5)

        if not ent.tailsbar_sliding then ent.tailsbar_sliding = multiply end
        ent.tailsbar_sliding = Lerp(FrameTime() * 8, ent.tailsbar_sliding, multiply)

        surface.SetMaterial(nozzlemat)
        surface.DrawTexturedRect(iconsize * ent.tailsbar_sliding, yaxis_cards + iconsize * 0.55, iconsize * 0.25, iconsize * 0.25)    

        draw.SimpleText(cannontype, "CloseCaption_BoldItalic",  iconsize * ent.tailsbar_sliding + iconsize * 0.25*0.5, yaxis_cards + iconsize * 0.4, colorbar, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end,

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            attack = "attack",
            jump2 = "jump",
            ShootingBurst="ShootingBurst",
        },
        ShouldMoveRotate={
            idle= function(ent) 
                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    return "shiftlock"
                end
                return "notanything"
            end,
            run= function(ent) 
                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            walk= function(ent) 
                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            fall= function(ent) 
                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            jump= function(ent) 
                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    return "shiftlock"
                end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            idle= function(ent)

                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then
                    return "Glide"
                end
                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    return "ShootingReady_Idle"
                end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "idle_lowhealth"
                end 
            end,
            walk= function(ent) 
                
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then
                    return "Glide"
                end
                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    return "ShootingReady_Walk"
                end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "walk_lowhealth"
                end 
            end,
            fall= function(ent) 
                
                if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then
                    return "Glide"
                end
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                
                if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then
                    return "Glide"
                end
                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    return "ShootingReady_Walk"
                end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "run_lowhealth"
                end 
            end,
        },

        animrates={
            idle= function(ent)
                return 1
            end,
            walk= function(ent) 
                
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 1 end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return 1 end
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 1 end
                if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then
                    return 1
                end
                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    return 1
                end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return 1
                end 
                return 1.8
            end,
            fall= function(ent) 
                local clampval = math.Clamp( ( ent:GetNW2Float("OM_Tails_flyingDuration") - CurTime() ) / 2, 0, 1)
                local lerpvalclamp = Lerp(clampval, 1, 0)
                local lerpval = Lerp(clampval, 0, 1)
                return lerpval
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 1 end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return 1 end
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 1 end
                
                if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then
                    return 1
                end
                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    return 1
                end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return 1
                end 
                return 1.1
            end,
        },
    },

    ShouldRoll_om = function(e, ply, ent)
        return true
    end,

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
        if ply:GetInfoNum("om_pills_action_camera_tails", 1) == 1 then
            if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then
                basetable =  {
                    startoffset = Vector(35,0,25),  -- left-up, front-back, up-down
                    dist=125,
                    fov = ply:GetInfoNum("om_pills_default_fov", 80),
                    id = 2,
                    transition = 2,
                    canscroll = true,
                }
            end
            if ent:GetNW2Bool("OM_TailsChargeEnabled") then
                basetable =  {
                    startoffset = Vector(45,0,35),  -- left-up, front-back, up-down
                    dist=60,
                    fov = ply:GetInfoNum("om_pills_default_fov", 80),
                    id = 1,
                    transition = 1,
                    canscroll = true,
                }
            end
            if ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                basetable =  {
                    startoffset = Vector(45,0,35),  -- left-up, front-back, up-down
                    dist=70,
                    fov = ply:GetInfoNum("om_pills_default_fov", 80) + 20,
                    id = 3,
                    transition = 1,
                    canscroll = true,
                }
            end
        end

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

                if ent:GetNW2Bool("OM_TailsChargeEnabled") or ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() - ent.formTable.Outcomememories_stats.moveSpeed.run()
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
                    return 400
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

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM") or ent:GetNW2Bool("OM_TailsChargeEnabled")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["tails_abilitycannon"]
            end,
            name = function(uselessvar,ply,ent)
                return "Cannon"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_tails_laser_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Tails_cannon_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 14
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM") or ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime()
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["tails_abilityfly"]
            end,
            name = function(uselessvar,ply,ent)
                return "Glide"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_tails_glide_key", KEY_R)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Tails_glide_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 32
            end,
            survivor = true,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility3_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["shadow_icon_reload"]
            end,
            name = function(uselessvar,ply,ent)
                return "Toggle"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_tails_toggle_key", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Tails_toggle_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 0.5
            end,
            survivor = true,
            font = "CreditsText",
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

    SetShootPoint=function(ply,ent,hitPos)
        ent:SetNW2Vector("Position2", hitPos)
    end,     

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
            initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
            initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)


            initializetable2["player"].OM_DamageBeforeCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                local ent = initializetable2["entity"]
                local ply = initializetable2["player"]
                    
                if !IsValid(initializetable2["entity"]) then return end
                
                if ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                    ent:SetNW2Float("OM_TailsShootDuration", 0)
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
                    ent:StopSound("OM/tails/tails laser shoot.wav")
                    
                    ent:SetNW2Float("Tails_barbuildup_yellow",0)
                end
                if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then
                    ent:SetNW2Float("OM_Tails_flyingDuration", 0)
                end
            end

        end
        initializetable2["player"]:SetNW2Bool("OM_character", true)
        initializetable2["entity"]:SetNW2Bool("OM_tails_pill", true)
        initializetable2["entity"]:SetNW2Bool("Holdingglidespace", false)


    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetNW2Bool("ShoukdntStun_OM_Noodles", false)
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetGravity(1)
        end
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", 1)

            if not GetConVar("OUTCOMEMORIES_N_tails_laser_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
            end
            if not GetConVar("OUTCOMEMORIES_N_tails_glide_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
            end
            if not GetConVar("OUTCOMEMORIES_N_tails_Toggle_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility3_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility3_OM", false)
            end

            if not ent.ThinkInitialize_tails_om then
                ent.ThinkInitialize_tails_om = true
                ent:SetNW2Float("OM_Tails_cannon_cd", CurTime()+1)
            end

            if ent:GetNW2Bool("OM_TailsBlastInSession") then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
            end

            local OM_Tails_cannon_cd = ent:GetNW2Float("OM_Tails_cannon_cd")
            if OM_Tails_cannon_cd > CurTime() then
                if not ent.OM_Tails_cannon_cd_Bool then
                    ent.OM_Tails_cannon_cd_Bool = true
                end
            else
                if ent.OM_Tails_cannon_cd_Bool then
                    ent.OM_Tails_cannon_cd_Bool = false
                    AdvancedPillSound(
                        {
                            stringe = "OM/tails/tails cannon unlock.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            end

            local lerpfactor = math.Clamp((OM_Tails_cannon_cd-CurTime())/ GetConVar("OUTCOMEMORIES_N_tails_laser_cd"):GetFloat() , 0, 1)
            local lerping = Lerp(lerpfactor, 100, 0)

            ent:SetNW2Float("Tails_barbuildup_green",lerping)

            local OM_Tails_chargeup_duration = ent:GetNW2Float("OM_Tails_chargeup_duration")
            if OM_Tails_chargeup_duration > CurTime() then
                if not ent.OM_Tails_chargeup_duration_bool then
                    ent.OM_Tails_chargeup_duration_bool = true
                end

                local lerpfactor = math.Clamp((OM_Tails_chargeup_duration-CurTime())/4.75, 0, 1)
                local lerping = Lerp(lerpfactor, 100, 0)

                ent:SetNW2Float("Tails_barbuildup_yellow",lerping)
            else
                if ent.OM_Tails_chargeup_duration_bool then
                    ent.OM_Tails_chargeup_duration_bool = false
                    if ent:GetNW2Bool("OM_TailsChargeEnabled") then
                        AdvancedPillSound(
                            {
                                stringe = "OM/tails/tails laser ready.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end
                end
            end


            local OM_Tails_chargeup_burst_duration = ent:GetNW2Float("OM_Tails_chargeup_burst_duration")
            if OM_Tails_chargeup_burst_duration > CurTime() then
                if not ent.OM_Tails_chargeup_burst_duration_bool then
                    ent.OM_Tails_chargeup_burst_duration_bool = true
                end
            else
                if ent.OM_Tails_chargeup_burst_duration_bool then
                    ent.OM_Tails_chargeup_burst_duration_bool = false
                    if ent:GetNW2Bool("OM_TailsChargeEnabled") then
                        AdvancedPillSound(
                            {
                                stringe = "buttons/blip1.wav",
                                pitchPercent = 140,
                                volume = 0.8,
                                soundLevel = 80
                            },
                            ent
                        )
                        AdvancedPillSound(
                            {
                                stringe = "buttons/lightswitch2.wav",
                                pitchPercent = 120,
                                volume = 0.8,
                                soundLevel = 70
                            },
                            ent
                        )
                    end
                end
            end

            local OM_TailsShootDuration = ent:GetNW2Float("OM_TailsShootDuration")
            if ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then
                if not ent.OM_TailsShootDuration_bool then
                    ent.OM_TailsShootDuration_bool = true
                end

                ent:SetNW2Bool("OM_TailsChargeShooting", true)
                if ply:IsPlayer() then
                    net.Start("tails_retrieve_mouse")
                    net.Send(ply)
                end

                local puppet = ent:GetPuppet()
                local startPos
                local endpos = ent:GetNW2Vector("Position2")

                local bone = puppet:LookupBone("RightHand")
                if bone then
                    local pos, ang = ply:GetBonePosition(bone)
                    startPos = pos + ang:Right() * -15 + ang:Up() * 1
                end

                local function hit(ent2)
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then return end
                    if ent2:GetClass() == "pill_puppet" then return end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then return end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then return end
                        local canstunstack = GetConVar("OUTCOMEMORIES_N_tails_laser_stunstack_laser"):GetBool()
                        local name = "TailsStunned"..ent:EntIndex()..""..ent.TailsStunID
                        local namecd = "TailsStunned_cd"..ent:EntIndex()..""..ent.TailsStunID
                        if Mutual_OMCanStun(ply, ent, ent2, canstunstack) and not ent2[name] then

                            ent2[name] = true

                            Mutaul_OMStunCode({
                                ["ply"] = ply,
                                ["ent"] = ent,
                                ["target"] = ent2,
                                ["StunDur"] = GetConVar("OUTCOMEMORIES_N_tails_laser_basestun_laser"):GetFloat(),
                                ["stunfunction"] = function(shouldstundamage)
                                    if shouldstundamage then
                                        AdvancedPillSound({
                                            stringe = "OM/tails/tails laser impact.wav",
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        }, ent2)


                                        if GetConVar("OUTCOMEMORIES_N_tails_laser_canragdollstun_laser"):GetBool() then

                                            local last = CurTime() + 2
                                            local flung = false

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
                                                            last = CurTime() + 1
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

                                                    local force = dir * 750 + Vector(0, 0, 120)

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
                                end,
                                ["shouldstack"] = canstunstack,
                                ["Damage"] = GetConVar("OUTCOMEMORIES_N_tails_laser_basedamage_laser"):GetFloat(),
                                ["DamageType"] = DMG_ENERGYBEAM
                            })
                        else
                            
                            if not ent2[namecd] then 
                                 ent2[namecd] = 0
                            end

                            if ent2[namecd] < CurTime() then
                                ent2[namecd] = CurTime() + 0.12
                                local dmg = DamageInfo()
                                dmg:SetDamage(1)
                                dmg:SetAttacker(ply)
                                dmg:SetInflictor(ply)
                                dmg:SetDamageType(bit.bor(DMG_ENERGYBEAM, DMG_DISSOLVE))

                                ent2:TakeDamageInfo(dmg)
                            end
                        end
                    end
                end

                local hits = ents.FindAlongRay(
                    startPos,
                    ent:GetNW2Vector("Position2"),
                    Vector(-20, -20, -20),
                    Vector(20, 20, 20)
                )
                for _, ent2 in pairs(hits) do
                    hit(ent2)
                end

                ent:SetNW2Float("Tails_barbuildup_green",0)

                local lerpfactor = math.Clamp((OM_TailsShootDuration-CurTime())/3.75, 0, 1)
                local lerping = Lerp(lerpfactor, 0, 100)

                ent:SetNW2Float("Tails_barbuildup_yellow",lerping)
            else
                if ent.OM_TailsShootDuration_bool then
                    ent:SetNW2Float("OM_Tails_cannon_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_tails_laser_cd"):GetFloat()+1)
                    ent.OM_TailsShootDuration_bool = false
                end
                ent:SetNW2Bool("OM_TailsChargeShooting", false)
            end


            if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then

                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                ent:GetPuppet():SetNW2Float("OM_TailsShootDuration_visual", CurTime()+0.1)

                if not ent.OM_Tails_flyingcancel then
                    ent.OM_Tails_flyingcancel = true
                end

                if not ent.OM_Tails_flyingDuration then
                    ent.OM_Tails_flyingDuration = 0
                end

                local clampval = math.Clamp( ( ent:GetNW2Float("OM_Tails_flyingDuration") - CurTime() ) / 2, 0, 1)
                local lerpvalclamp = Lerp(clampval, 1, 0)
                local lerpval = Lerp(clampval, 0, 1)

                local verticalspeed = GetConVar("OUTCOMEMEMORIES_N_tails_glide_Verticalspeed"):GetFloat()
                local horizontalspeed = GetConVar("OUTCOMEMEMORIES_N_tails_glide_Horizontalspeed"):GetFloat()

                local vel = ply:GetVelocity()
                local velo = ply:GetUp()* -verticalspeed * clampval
                local forward = ply:GetForward()*horizontalspeed * clampval
                local side = ply:GetRight()*0

                if ply:KeyDown(IN_MOVELEFT) then
                    side = ply:GetRight()*-horizontalspeed * clampval
                elseif ply:KeyDown(IN_MOVERIGHT) then
                    side = ply:GetRight()*horizontalspeed * clampval
                end

                if ply:KeyDown(IN_MOVERIGHT) and ply:KeyDown(IN_MOVELEFT) then
                    side = ply:GetRight()*0
                end

                if ent:GetNW2Bool("Holdingglidespace") or ent:GetNW2Float("OM_Tails_flyingDuration_Up") > CurTime() then
                    velo = ply:GetUp()* verticalspeed * clampval
                end

                ply:SetVelocity(velo + forward + side)
                ply:SetLocalVelocity(velo + forward + side)


                if ent.OM_Tails_flyingDuration < CurTime() then
                    ent.OM_Tails_flyingDuration = CurTime()+0.2+0.35*lerpvalclamp
                    AdvancedPillSound(
                        {
                            stringe = "OM/tails/s135_sba_flying.wav",
                            pitchPercent = math.Clamp(100*lerpval,25,100),
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end


                if ply:IsOnGround() then
                    ent:SetNW2Float("Tails_glide_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_tails_glidecd_expire"):GetFloat())
                    ent:SetNW2Float("OM_Tails_flyingDuration", 0)
                end
            else
                if ent.OM_Tails_flyingcancel then
                    ent.OM_Tails_flyingcancel = false
                    if ent.OM_Tails_flyingmanualcancel then
                        ent.OM_Tails_flyingmanualcancel = false
                        ent:SetNW2Float("Tails_glide_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_tails_glidecd_cancel"):GetFloat())
                    else
                        ent:SetNW2Float("Tails_glide_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_tails_glidecd_expire"):GetFloat())
                    end
                end
            end

            if ent.OM_Tails_bulletcount == nil then
                ent.OM_Tails_bulletcount = 3
            end

            if ent.OM_Tails_bulletcount <= 0 then
                ent.OM_Tails_bulletcount = 3
                ent:SetNW2Bool("OM_TailsShootingOrbs", false)
                ent:SetNW2Float("OM_Tails_cannon_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_tails_laser_cd"):GetFloat()+1)
                ent:SetNW2Float("Tails_barbuildup_green",0)
                ent:SetNW2Float("Tails_barbuildup_yellow",0)
                ent:SetNW2Bool("OM_TailsChargeEnabled", false)
            end

            if ent:GetNW2Bool("OM_TailsShootingOrbs") then
                ent:SetNW2Float("Tails_barbuildup_green",(ent.OM_Tails_bulletcount/3)*100)
                ent:SetNW2Float("Tails_barbuildup_yellow",(ent.OM_Tails_bulletcount/3)*100)
            end
        else

            local hookName = "PostDrawTranslucentRenderables"
            local name = "tails_ui_OM_noodles2"..ent:EntIndex()

            local hooks = hook.GetTable()

            if hooks[hookName] and hooks[hookName][name] then
            else
                hook.Add(hookName, name, function()
                    if !IsValid(ent) then hook.Remove(hookName, name) return end
                    local v = ent

                    local startPos
                    local endPos = v:GetNW2Vector("Position2")

                    local puppet = v:GetPuppet()

                    local bone = puppet:LookupBone("RightHand")
                    local pos = Vector(0,0,0)
                    local ang = Angle(0,0,0)
                    if bone then
                        local matrix = puppet:GetBoneMatrix(bone)

                        if matrix then
                            pos = matrix:GetTranslation()
                            ang = matrix:GetAngles()

                            startPos = pos + ang:Right() * -15 + ang:Up() * 1
                        end
                    end

                    if v.OM_TailsChargeShooting_transition > 0.05 then

                        render.SetMaterial(beamMat[0])

                        render.DrawBeam(
                            startPos + ang:Up() * 3,
                            endPos,
                            200*v.OM_TailsChargeShooting_transition,
                            0,
                            1,
                            Color(255,255,255,255*v.OM_TailsChargeShooting_transition)
                        )

                    end

                    local v = ent:GetPuppet()
                    local expire = v:GetNW2Float("OM_TailsShootDuration_visual", 0)

                    if expire >= CurTime() then

                        local pos = v:GetPos() + Vector(0, 0, 10)
                        local size = 65
                        local angle = CurTime() * 720*1.5 + 90

                        render.SetMaterial(tailsmat[1])

                        render.DrawQuadEasy(
                            pos,
                            Vector(0, 0, 1),
                            size,
                            size,
                            color_white,
                            angle
                        )
                        render.DrawQuadEasy(
                            pos,
                            Vector(0, 0, -1),
                            size,
                            size,
                            color_white,
                            angle
                        )

                        local pos = v:GetPos() + Vector(0, 0, 15)
                        local size = 75
                        local angle = CurTime() * 720*1.5 + 180

                        render.SetMaterial(tailsmat[2])

                        render.DrawQuadEasy(
                            pos,
                            Vector(0, 0, 1),
                            size,
                            size,
                            color_white,
                            angle
                        )
                        render.DrawQuadEasy(
                            pos,
                            Vector(0, 0, -1),
                            size,
                            size,
                            color_white,
                            angle
                        )



                        local pos = v:GetPos() + Vector(0, 0, 20)
                        local size = 85
                        local angle = CurTime() * 720*1.5 + 270

                        render.SetMaterial(tailsmat[3])

                        render.DrawQuadEasy(
                            pos,
                            Vector(0, 0, 1),
                            size,
                            size,
                            color_white,
                            angle
                        )
                        render.DrawQuadEasy(
                            pos,
                            Vector(0, 0, -1),
                            size,
                            size,
                            color_white,
                            angle
                        )

                        local pos = v:GetPos() + Vector(0, 0, 25)
                        local size = 80
                        local angle = CurTime() * 720*1.5 + 360

                        render.SetMaterial(tailsmat[4])

                        render.DrawQuadEasy(
                            pos,
                            Vector(0, 0, 1),
                            size,
                            size,
                            color_white,
                            angle
                        )
                        render.DrawQuadEasy(
                            pos,
                            Vector(0, 0, -1),
                            size,
                            size,
                            color_white,
                            angle
                        )
                    end


                    local v = ent


                    if not v.OM_TailsChargeEnabled_transition then
                        v.OM_TailsChargeEnabled_transition = 0
                    end
                    if v:GetNW2Bool("OM_TailsChargeEnabled")  then
                        v.OM_TailsChargeEnabled_transition = Lerp(FrameTime()*2, v.OM_TailsChargeEnabled_transition, 1)
                    else
                        v.OM_TailsChargeEnabled_transition = Lerp(FrameTime()*2, v.OM_TailsChargeEnabled_transition, 0)
                    end 

                    if v.OM_TailsChargeEnabled_transition > 0.05 then
                        local sparklepos = pos + ang:Right() * -12 + ang:Up() * 1

                        local spriteMat = Material("icons/tails_cannon_spiral")

                        render.SetMaterial(spriteMat)

                        local time = CurTime()

                        local radius = 8*v.OM_TailsChargeEnabled_transition
                        local speed = -180

                        local normal = ang:Right()

                        for i = 0, 2 do


                            local orbitOffset = i * 120

                            local orbitAng = math.rad(time * speed + orbitOffset)

                            local offset =
                                ang:Forward() * math.cos(orbitAng) * radius +
                                ang:Up() * math.sin(orbitAng) * radius

                            render.DrawQuadEasy(
                                sparklepos + offset,
                                normal,
                                12,
                                12,
                                Color(255, 255, 255, 255*v.OM_TailsChargeEnabled_transition),
                                time * -180 + orbitOffset+100
                            )

                            sparklepos = sparklepos + ang:Right() * 3

                        end


                        local sparklepos = pos + ang:Right() * -16.5 + ang:Up() * 1

                        local spriteMat = Material("icons/tails_lasershine")

                        render.SetMaterial(spriteMat)

                        local time = CurTime()

                        local speed = 25 

                        local orbitAng = Angle(0, time * speed, 0)

                        local normal = ang:Right()

                        render.DrawQuadEasy(
                            sparklepos,
                            normal,
                            12*v.OM_TailsChargeEnabled_transition,
                            12*v.OM_TailsChargeEnabled_transition,
                            Color(255, 255, 255, 255*v.OM_TailsChargeEnabled_transition),
                            time * -180
                        )
                    
                    end



                end)
            end

            local v = ent

            local startPos
            local endPos = v:GetNW2Vector("Position2")

            local puppet = v:GetPuppet()

            local bone = puppet:LookupBone("RightHand")
            local pos = Vector(0,0,0)
            local ang = Angle(0,0,0)
            if bone then
                local matrix = puppet:GetBoneMatrix(bone)

                if matrix then
                    pos = matrix:GetTranslation()
                    ang = matrix:GetAngles()

                    startPos = pos + ang:Right() * -15 + ang:Up() * 1
                end
            end

            if not v.OM_TailsChargeShooting_transition then
                v.OM_TailsChargeShooting_transition = 0
            end
            if v:GetNW2Bool("OM_TailsChargeShooting")  then
                v.OM_TailsChargeShooting_transition = Lerp(FrameTime()*4, v.OM_TailsChargeShooting_transition, 1)
            else
                v.OM_TailsChargeShooting_transition = Lerp(FrameTime()*4, v.OM_TailsChargeShooting_transition, 0)
            end 

            if v.OM_TailsChargeShooting_transition > 0.05 then

                if startPos then

                    if v:GetNW2Bool("OM_TailsChargeShooting") then
                        local emitter = ParticleEmitter(startPos)

                        for i = 1, 5 do
                            local dir = VectorRand()

                            local p = emitter:Add("particle/particle_smokegrenade", startPos)
                            if p then
                                p:SetVelocity(dir * math.Rand(15, 45))
                                p:SetDieTime(math.Rand(0.35, 0.7))

                                p:SetStartAlpha(90)
                                p:SetEndAlpha(0)

                                p:SetStartSize(math.Rand(18, 28)*0.35)
                                p:SetEndSize(math.Rand(45, 70)*0.35)

                                p:SetRoll(math.Rand(0, 360))
                                p:SetRollDelta(math.Rand(-2, 2))

                                p:SetColor(255, 255, 0)
                                p:SetAirResistance(80)
                            end
                        end

                        for i = 1, 5 do
                            local dir = VectorRand()

                            local edgeOffset = dir * math.Rand(15, 28)*0.45

                            local p = emitter:Add("particle/particle_smokegrenade", startPos + edgeOffset)
                            if p then
                                p:SetVelocity(dir * math.Rand(20, 60))
                                p:SetDieTime(math.Rand(0.45, 0.9))

                                p:SetStartAlpha(60)
                                p:SetEndAlpha(0)

                                p:SetStartSize(math.Rand(20, 30)*0.35)
                                p:SetEndSize(math.Rand(55, 85)*0.35)

                                p:SetRoll(math.Rand(0, 360))
                                p:SetRollDelta(math.Rand(-3, 3))

                                p:SetColor(15, 15, 15)
                                p:SetAirResistance(120)
                            end
                        end

                        emitter:Finish()


                        local emitter = ParticleEmitter(endPos)

                        for i = 1, 5 do
                            local dir = VectorRand()

                            local p = emitter:Add("particle/particle_smokegrenade", endPos)
                            if p then
                                p:SetVelocity(dir * math.Rand(15, 45))
                                p:SetDieTime(math.Rand(0.35, 0.7))

                                p:SetStartAlpha(60)
                                p:SetEndAlpha(0)

                                p:SetStartSize(math.Rand(18, 28)*0.85)
                                p:SetEndSize(math.Rand(45, 70)*0.85)

                                p:SetRoll(math.Rand(0, 360))
                                p:SetRollDelta(math.Rand(-2, 2))

                                p:SetColor(255, 255, 255)
                                p:SetAirResistance(80)
                            end
                        end

                        for i = 1, 5 do
                            local dir = VectorRand()

                            local edgeOffset = dir * math.Rand(15, 28)*0.75

                            local p = emitter:Add("particle/particle_smokegrenade", startPos + edgeOffset)
                            if p then
                                p:SetVelocity(dir * math.Rand(20, 60))
                                p:SetDieTime(math.Rand(0.45, 0.9))

                                p:SetStartAlpha(35)
                                p:SetEndAlpha(0)

                                p:SetStartSize(math.Rand(20, 30)*0.85)
                                p:SetEndSize(math.Rand(55, 85)*0.85)

                                p:SetRoll(math.Rand(0, 360))
                                p:SetRollDelta(math.Rand(-3, 3))

                                p:SetColor(185, 185, 185)
                                p:SetAirResistance(120)
                            end
                        end

                        emitter:Finish()
                    end
                end
            end
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply,ent,button)
        if SERVER then
            if button == KEY_SPACE then
                ent:SetNW2Bool("Holdingglidespace", false)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then
            if button == KEY_SPACE then
                ent:SetNW2Bool("Holdingglidespace", true)
            end
            if button == ply:GetInfoNum("om_pills_action_tails_laser_key", KEY_E) then
                if ent:GetNW2Bool("OM_TailsShootingOrbs") then return end
                if ent:GetNW2Bool("OM_TailsBlastInSession") then return end
                if ent:GetNW2Float("Tails_cannon_cd") > CurTime() then return end
                if ent:GetNW2Float("OM_Tails_cannon_cd") > CurTime() then return end
                if ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then return end
                if ent:GetNW2Float("OM_Tails_chargeup_duration") > CurTime() then return end
                if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then return end

                if ent.OM_TailsShootDuration_bool then return end

                if not ent.TailsStunID then
                    ent.TailsStunID = 0
                end
                ent.TailsStunID = ent.TailsStunID + 1

                if not ent:GetNW2Bool("OM_TailsChargeEnabled", false) then
                    if not GetConVar("OUTCOMEMORIES_N_tails_laser_useable"):GetBool() then return end
                    ent:SetNW2Bool("OM_TailsChargeEnabled", true)

                    AdvancedPillSound(
                        {
                            stringe = "OM/tails/tails laser charge.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:SetNW2Float("OM_Tails_chargeup_duration", CurTime()+4.75)
                    ent:SetNW2Float("OM_Tails_chargeup_burst_duration", CurTime()+2)
                else
                    ent:SetNW2Float("Tails_cannon_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_tails_laser_cancel_cd"):GetFloat())
                    ent:SetNW2Float("Tails_barbuildup_yellow",0)
                    ent:SetNW2Bool("OM_TailsChargeEnabled", false)
                end
            end
            if button == ply:GetInfoNum("om_pills_action_tails_glide_key", KEY_R) then
                if ent:GetNW2Bool("OM_TailsShootingOrbs") then return end
                if ent:GetNW2Bool("OM_TailsBlastInSession") then return end
                if ent:GetNW2Float("Tails_glide_cd") > CurTime() then return end
                if ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then return end
                if ent:GetNW2Bool("OM_TailsChargeEnabled", false) then return end



                if ent:GetNW2Float("OM_Tails_flyingDuration") > CurTime() then
                    local clampval = math.Clamp( ( ent:GetNW2Float("OM_Tails_flyingDuration") - CurTime() ) / 2, 0, 1)
                    local lerpvalclamp = Lerp(clampval, 1, 0)
                    local lerpval = Lerp(clampval, 0, 1)

                    if lerpval < 0.5 then return end

                    ent.OM_Tails_flyingmanualcancel = true
                    ent:SetNW2Float("OM_Tails_flyingDuration", CurTime() + 1)
                else
                    if not GetConVar("OUTCOMEMORIES_N_tails_glide_useable"):GetBool() then return end
                    ent:SetNW2Float("OM_Tails_flyingDuration", CurTime() + GetConVar("OUTCOMEMORIES_N_tails_glide_duration"):GetFloat())
                    ent:SetNW2Float("OM_Tails_flyingDuration_numb", GetConVar("OUTCOMEMORIES_N_tails_glide_duration"):GetFloat())
                    if ply:IsOnGround() then
                        ent:SetNW2Float("OM_Tails_flyingDuration_Up", CurTime() + 1)
                        ply:SetPos(ply:GetPos()+Vector(0,0,10))
                    end
                    ent:GetPuppet():SetNW2Float("tails_white_highlight_pill", CurTime()+0.5*0.35)
                end
            end
            if button == ply:GetInfoNum("om_pills_action_tails_toggle_key", KEY_T) then
                if not GetConVar("OUTCOMEMORIES_N_tails_glide_useable"):GetBool() then return end


                if ent:GetNW2Float("Tails_toggle_cd") > CurTime() then return end
                if ent:GetNW2Bool("OM_TailsShootingOrbs") then return end
                if ent:GetNW2Float("OM_TailsShootDuration") > CurTime() then return end
                ent:SetNW2Float("Traverse_bar", ent:GetNW2Float("Traverse_bar", 0) + 1)
                ent:SetNW2Float("Tails_toggle_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_tails_togglecd"):GetFloat())

                if not GetConVar("OUTCOMEMORIES_N_tails_Toggle_laser_useable"):GetBool() and not GetConVar("OUTCOMEMORIES_N_tails_Toggle_burst_useable"):GetBool() and not GetConVar("OUTCOMEMORIES_N_tails_Toggle_orbs_useable"):GetBool() and not GetConVar("OUTCOMEMORIES_N_tails_Toggle_shockwave_useable"):GetBool() then return end


                if IsValid(ply) and ply:IsPlayer() then
                    net.Start("tails_toggle_om")
                    net.Send(ply)
                end

                local function press()


                    if GetConVar("OUTCOMEMORIES_N_tails_Toggle_laser_useable"):GetBool() then
                        if ent:GetNW2Float("Traverse_bar") == 0 then
                            ent:GetPuppet():SetNW2Float("tails_laserswap_laser", CurTime()+0.35)
                        end
                    else
                        if ent:GetNW2Float("Traverse_bar") == 0 then ent:SetNW2Float("Traverse_bar", ent:GetNW2Float("Traverse_bar", 0) + 1) end
                    end

                    if GetConVar("OUTCOMEMORIES_N_tails_Toggle_burst_useable"):GetBool() then
                        if ent:GetNW2Float("Traverse_bar") == 1 then
                            ent:GetPuppet():SetNW2Float("tails_laserswap_burst", CurTime()+0.35)
                        end
                    else
                        if ent:GetNW2Float("Traverse_bar") == 1 then ent:SetNW2Float("Traverse_bar", ent:GetNW2Float("Traverse_bar", 0) + 1) end
                    end

                    if GetConVar("OUTCOMEMORIES_N_tails_Toggle_orbs_useable"):GetBool() then
                        if ent:GetNW2Float("Traverse_bar") == 2 then
                            ent:GetPuppet():SetNW2Float("tails_laserswap_orbs", CurTime()+0.35)
                        end
                    else
                        if ent:GetNW2Float("Traverse_bar") == 2 then ent:SetNW2Float("Traverse_bar", ent:GetNW2Float("Traverse_bar", 0) + 1) end
                    end

                    if GetConVar("OUTCOMEMORIES_N_tails_Toggle_shockwave_useable"):GetBool() then
                        if ent:GetNW2Float("Traverse_bar") == 3 then
                            ent:GetPuppet():SetNW2Float("tails_laserswap_shockwave", CurTime()+0.35)
                        end
                    else
                        if ent:GetNW2Float("Traverse_bar") == 3 then ent:SetNW2Float("Traverse_bar", ent:GetNW2Float("Traverse_bar", 0) + 1) end
                    end

                end

                press()

                if ent:GetNW2Float("Traverse_bar") >= 4 then
                    ent:SetNW2Float("Traverse_bar", 0)
                    press()
                end
            end


        end
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if ent:GetNW2Bool("OM_TailsBlastInSession") then return end
            if ent:GetNW2Bool("OM_TailsChargeEnabled") then
                if ent:GetNW2Float("Traverse_bar") == 0 then
                    if ent:GetNW2Float("OM_Tails_chargeup_duration") > CurTime() then return end
                    ent:SetNW2Float("OM_TailsShootDuration", CurTime() + 3.75)
                    ent:SetNW2Bool("OM_TailsChargeEnabled", false)
                    AdvancedPillSound(
                        {
                            stringe = "OM/tails/tails laser shoot.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                elseif ent:GetNW2Float("Traverse_bar") == 1 then
                    if ent:GetNW2Float("OM_Tails_chargeup_burst_duration") > CurTime() then return end
                    ent:PillAnim("ShootingBurst")

                    local seq = ent:GetPuppet():LookupSequence("ShootingBurst")
                    local duration = ent:GetPuppet():SequenceDuration(seq)
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + duration)

                    AdvancedPillSound(
                        {
                            stringe = "OM/tails/tails laser burst.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent:SetNW2Float("OM_Tails_chargeup_duration", 0)
                    ent:SetNW2Float("OM_Tails_chargeup_burst_duration", 0)
                    ent:SetNW2Float("Tails_barbuildup_yellow",0)
                    ent:SetNW2Float("OM_Tails_cannon_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_tails_laser_cd"):GetFloat()+1)
                    

                    ent:SetNW2Bool("OM_TailsChargeEnabled", false)
                    ent:SetNW2Bool("OM_TailsBlastInSession", true)
                    timer.Simple(0.45,function()
                        if !IsValid(ent) then return end
                        local origin = ply:GetPos()+ent:GetPuppet():GetForward()*20
                        for i=1,2 do

                            local ed = EffectData()
                            ed:SetOrigin(origin)

                            ed:SetStart(Vector(255, 255, 255))

                            ed:SetScale(1)
                            ed:SetMagnitude(500)
                            ed:SetRadius(2)

                            util.Effect("om_tails_burst", ed)
                        end

                        ent:SetNW2Float("Tails_barbuildup_yellow",0)

                        for _, ent2 in pairs(ents.FindInSphere(origin, 200)) do
                            if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                            if ent2:GetClass() == "pill_puppet" then continue end
                            if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                                if ent2 == ply then continue end
                                if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                local canstunstack = GetConVar("OUTCOMEMORIES_N_tails_laser_stunstack_burst"):GetBool()
                                if Mutual_OMCanStun(ply, ent, ent2, canstunstack) then

                                    Mutaul_OMStunCode(
                                        {
                                            ["ply"] = ply,
                                            ["ent"] = ent,
                                            ["target"] = ent2,
                                            ["StunDur"] = GetConVar("OUTCOMEMORIES_N_tails_laser_basestun_burst"):GetFloat(),
                                            ["stunfunction"] = function(shouldstundamage)
                                                if shouldstundamage then
                                                    if GetConVar("OUTCOMEMORIES_N_tails_laser_canragdollstun_burst"):GetBool() then
                                                        local last = CurTime() + 4
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
                                                                local dir = (ent2:GetPos()+Vector(0,0,40) - ply:GetPos()):GetNormalized()


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
                                                    OM_burntarget(ply, ent2, 3, true)
                                                end
                                            end,
                                            ["checkoutprevention"] = true,
                                            ["shouldstack"] = canstunstack,
                                            ["Damage"] = GetConVar("OUTCOMEMORIES_N_tails_laser_basedamage_burst"):GetFloat(),
                                            ["DamageType"] = DMG_CLUB
                                        }
                                    )

                                end
                            end
                        end


                    end)
                    timer.Simple(duration,function()
                        if !IsValid(ent) then return end
                        ent:SetNW2Bool("OM_TailsBlastInSession", false)
                    end)
                elseif ent:GetNW2Float("Traverse_bar") == 2 then
                    if ent:GetNW2Float("OM_Tails_chargeup_duration") > CurTime() then return end
                    if not ent.orbsshootcd_tails then
                        ent.orbsshootcd_tails = 0
                    end
                    if ent.orbsshootcd_tails > CurTime() then return end
                    ent.orbsshootcd_tails = CurTime() + 0.3
                    local puppet = ent:GetPuppet()
                    local layeredAnim = puppet:AddGesture(ACT_BARNACLE_HIT, false)

                    puppet:SetLayerWeight(layeredAnim, 1)
                    puppet:SetLayerPriority(layeredAnim, 10)

                    local playbackRate = 1*1.25
                    puppet:SetLayerPlaybackRate(layeredAnim, playbackRate)

                    timer.Simple(0.3,function()
                        if !IsValid(ent) then return end
                        puppet:RemoveLayer(puppet:FindGestureLayer(ACT_BARNACLE_HIT))
                    end)


                    AdvancedPillSound(
                        {
                            stringe = "ambient/energy/sinewave.wav",
                            pitchPercent = 130,
                            volume = 0.35,
                            soundLevel = 60
                        },
                        ent
                    )

                    AdvancedPillSound(
                        {
                            stringe = "weapons/stunstick/spark1.wav",
                            pitchPercent = 150,
                            volume = 0.7,
                            soundLevel = 75
                        },
                        ent
                    )

                    AdvancedPillSound(
                        {
                            stringe = "weapons/physcannon/energy_sing_explosion2.wav",
                            pitchPercent = 110,
                            volume = 1,
                            soundLevel = 90
                        },
                        ent
                    )

                    AdvancedPillSound(
                        {
                            stringe = "weapons/gauss/fire1.wav",
                            pitchPercent = 105,
                            volume = 0.8,
                            soundLevel = 88
                        },
                        ent
                    )

                    ent:SetNW2Bool("OM_TailsShootingOrbs", true)

                    ent.OM_Tails_bulletcount = ent.OM_Tails_bulletcount - 1

                    if ply:IsPlayer() then
                        net.Start("tails_retrieve_mouse")
                        net.Send(ply)
                    end

                    timer.Simple(0.1,function()
                        if !IsValid(ent) then return end
                        local rock = ents.Create("prop_physics")

                        if IsValid(rock) then
                            rock:SetModel("models/hunter/misc/sphere025x025.mdl")

                            local startPos = Vector(0,0,0)
                            local puppet = ent:GetPuppet()
                            local rightBone = puppet:LookupBone("RightHand")

                            if rightBone then
                                local rightPos, rightang = puppet:GetBonePosition(rightBone)

                                startPos = rightPos + rightang:Right() * -15 + rightang:Up() * 1
                            end

                            rock:SetPos(startPos)

                            rock:SetAngles(ent:GetPuppet():GetAngles())
                            rock:Spawn()

                            ent:DeleteOnRemove(rock)

                            rock:SetNW2Float("tails_orbsglow", CurTime()+1e9)

                            local phys = rock:GetPhysicsObject()

                            if IsValid(phys) then
                                phys:Wake()
                                phys:EnableGravity(false)
                                phys:SetVelocity((ent:GetNW2Vector("Position2") - startPos) * 8500)
                            end

                            local function PlasmaExplode(pos)
                                sound.Play("weapons/gauss/cannon_high.wav", pos, 100, 100, 1)

                                sound.Play("ambient/energy/weld2.wav", pos, 90, 120, 1)

                                local fx1 = EffectData()
                                fx1:SetOrigin(pos)
                                util.Effect("cball_explode", fx1, true, true)

                                local fx2 = EffectData()
                                fx2:SetOrigin(pos)
                                util.Effect("AR2Explosion", fx2, true, true)

                                util.ScreenShake(pos, 10, 12, 0.3, 500)

                                if IsValid(rock) then
                                    rock:Remove()
                                end
                            end

                            timer.Simple(3, function()
                                if IsValid(rock) then
                                    PlasmaExplode(rock:GetPos())
                                end
                            end)

                            local hookID = "rock_nodamage_" .. rock:EntIndex()

                            hook.Add("EntityTakeDamage", hookID, function(target, dmginfo)

                                if !IsValid(rock) then
                                    hook.Remove("EntityTakeDamage", hookID)
                                    return
                                end

                                local attacker = dmginfo:GetAttacker()
                                local inflictor = dmginfo:GetInflictor()

                                if attacker == rock or inflictor == rock then
                                    dmginfo:SetDamage(0)
                                    dmginfo:ScaleDamage(0)

                                    return true
                                end
                            end)

                            rock:AddCallback("PhysicsCollide", function(self, data)

                                if self.Broken then return end
                                self.Broken = true

                                local hitPos = data.HitPos
                                local hitNormal = data.HitNormal

                                util.ScreenShake(
                                    hitPos,
                                    8,
                                    8,
                                    0.4,
                                    400
                                )

                                local jumpscare_entity = nil
                                for _, ent2 in pairs(ents.FindInSphere(hitPos, 130)) do
                                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                                    if ent2:GetClass() == "pill_puppet" then continue end
                                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                                        if ent2 == ply then continue end
                                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                        local canstunstack = GetConVar("OUTCOMEMORIES_N_tails_laser_stunstack_orbs"):GetBool()
                                        if Mutual_OMCanStun(ply, ent, ent2, canstunstack) then

                                            if IsValid(ent2:GetNWEntity("OM_ragdollentity")) then
                                                continue
                                            end

                                            if not ent2.OM_tails_orbsstunhit then
                                                ent2.OM_tails_orbsstunhit = 0
                                            end
                                            ent2.OM_tails_orbsstunhit = ent2.OM_tails_orbsstunhit + 1

                                            OM_burntarget(ply, ent2, 3, true)
                                            if ent2.OM_tails_orbsstunhit >= 2 then
                                                ent2.OM_tails_orbsstunhit = 0
                                                Mutaul_OMStunCode(
                                                    {
                                                        ["ply"] = ply,
                                                        ["ent"] = ent,
                                                        ["target"] = ent2,
                                                        ["StunDur"] = GetConVar("OUTCOMEMORIES_N_tails_laser_basestun_orbs"):GetFloat(),
                                                        ["stunfunction"] = function(shouldstundamage)

                                                            if shouldstundamage then

                                                                if GetConVar("OUTCOMEMORIES_N_tails_laser_canragdollstun_orbs"):GetBool() then
                                                                    local last = CurTime() + 4
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
                                                                            local dir = (ent2:GetPos() - hitPos):GetNormalized()


                                                                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                                                local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                                                                                if IsValid(phys) then
                                                                                    phys:Wake()
                                                                                    phys:SetVelocityInstantaneous(dir*1500)
                                                                                end
                                                                            
                                                                            end
                                                                        end
                                                                    })
                                                                end
                                                            end
                                                        end,
                                                        ["checkoutprevention"] = true,
                                                        ["shouldstack"] = canstunstack,
                                                        ["Damage"] = GetConVar("OUTCOMEMORIES_N_tails_laser_basedamage_orbs"):GetFloat(), -- ent:GetNW2Float(StunTimesName) < 2  and true or 30
                                                        ["DamageType"] = DMG_CLUB
                                                    }
                                                )
                                            end
                                        end
                                    end
                                end
                                PlasmaExplode(data.HitPos)

                            end)
                        end
                    end)
                elseif ent:GetNW2Float("Traverse_bar") == 3 then
                    if ent:GetNW2Float("OM_Tails_chargeup_burst_duration") > CurTime() then return end

                    local puppet = ent:GetPuppet()
                    local layeredAnim = puppet:AddGesture(ACT_BARNACLE_HIT, false)

                    puppet:SetLayerWeight(layeredAnim, 1)
                    puppet:SetLayerPriority(layeredAnim, 10)

                    local playbackRate = 1*1.25
                    puppet:SetLayerPlaybackRate(layeredAnim, playbackRate)

                    timer.Simple(0.3,function()
                        if !IsValid(ent) then return end
                        puppet:RemoveLayer(puppet:FindGestureLayer(ACT_BARNACLE_HIT))
                    end)


                    if ply:IsPlayer() then
                        net.Start("tails_retrieve_mouse")
                        net.Send(ply)
                    end
                    ent:SetNW2Bool("OM_TailsChargeEnabled", false)
                    ent:SetNW2Float("OM_Tails_chargeup_duration", 0)
                    ent:SetNW2Float("OM_Tails_chargeup_burst_duration", 0)
                    ent:SetNW2Float("Tails_barbuildup_yellow",0)
                    ent:SetNW2Float("OM_Tails_cannon_cd", CurTime()+GetConVar("OUTCOMEMORIES_N_tails_laser_cd"):GetFloat()/2+1)

                    timer.Simple(0.1,function()
                        if !IsValid(ent) then return end


                        local ball = ents.Create("ent_om_tails_speedboost")

                        local startPos = ent:GetNW2Vector("Position2")

                        local tr = util.TraceLine({
                            start = startPos + Vector(0, 0, 100),
                            endpos = startPos - Vector(0, 0, 5000),
                            filter = {ply, ball}
                        })

                        ball:SetPos(tr.HitPos + tr.HitNormal*3)

                        local origin = tr.HitPos + tr.HitNormal*3
                        for i=1,2 do

                            local ed = EffectData()
                            ed:SetOrigin(origin)

                            ed:SetStart(Vector(255, 255, 255))

                            ed:SetScale(1)
                            ed:SetMagnitude(500)
                            ed:SetRadius(2)

                            util.Effect("om_tails_burst", ed)
                        end

                        local ang = tr.HitNormal:Angle()
                        ang:RotateAroundAxis(ang:Right(), -90)

                        ball:SetAngles(ang)
                        ball:Spawn()


                        timer.Simple(45,function()
                            if !IsValid(ball) then return end
                            ball:Remove()
                        end)

                        ent:DeleteOnRemove(ball)
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
        ent:PillAnim('jump2')

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

