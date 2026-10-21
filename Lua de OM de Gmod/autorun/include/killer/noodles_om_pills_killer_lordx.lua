
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
    ["LordX_charging"] = Material("icons/LordX_charging.png"),
    ["LordX_godsmockery"] = Material("icons/LordX_godsmockery.png"),
    ["lord_x_gods_mockery"] = Material("icons/lord_x_gods_mockery.png"),
    ["God's trickery 2011x"] = Material("icons/God's trickery 2011x.png"),
    ["RAGE METER NEW"] = Material("icons/RAGE METER NEW.png"),
}

pk_pills.register('pill_om_lordx', {

    printName='lordx',
    Outcomememories='lordx',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/lordx.mdl",

    camera={
        offset = Vector(0, 0, 40),
        dist=130,
    },

    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',
        
    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            jump2="jump",
            glide="fall",
            jump2="jump",
            Chargehit = "Chargehit",
            GodsMockery="GodsMockery",
            AbilityStart = "AbilityStart",
            AbilityEnd = "AbilityEnd",
        },

        ShouldMoveRotate_lerpspeed={
            GodsMockery = function(ent)
                return 90
            end,
        },
        ShouldMoveRotate={

            GodsMockery = function(ent)
                return 'assignedagnles' 
            end,
            Chargehit = function(ent)
                if ent:GetNWFloat("ChargeDurationFake") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                return 'notanything' 
            end,
            idle= function(ent) 
                if ent:GetNWFloat("ChargeDuration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                return 'notanything' 
            end,
            run= function(ent) 
                if ent:GetNW2Float("ChargeDuration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                return 'notshftlock' 
            end,
            walk= function(ent) 
                if ent:GetNW2Float("ChargeDuration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                return 'notshftlock' 
            end,
            jump= function(ent) 
                if ent:GetNW2Float("ChargeDuration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                return 'notshftlock'
            end,
            fall= function(ent)
                if ent:GetNW2Float("ChargeDuration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                return "notshftlock"
            end,
            charge= function(ent)
                if ent:GetNW2Float("ChargeDuration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                return "notshftlock"
            end,
        },

        ShouldAlternate={
            fall = function(ent)

                local fly = ent:GetNWEntity("LordXSeperatePuppetHand")
                if ent:GetNW2Float("Godlysgrasp_duration") > CurTime() or IsValid(fly) then return "AbilityIdle" end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return "charge" end
            end,
            idle= function(ent)
                local fly = ent:GetNWEntity("LordXSeperatePuppetHand")
                if ent:GetNW2Float("Godlysgrasp_duration") > CurTime() or IsValid(fly) then return "AbilityIdle" end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return "charge" end
                if ent:GetNW2Bool("Bool_Invisible_2011x_om") then return "Invisible_idle" end
            end,
            walk= function(ent)
                local fly = ent:GetNWEntity("LordXSeperatePuppetHand")
                if ent:GetNW2Float("Godlysgrasp_duration") > CurTime() or IsValid(fly) then return "AbilityIdle" end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return "charge" end
                if ent:GetNW2Bool("Bool_Invisible_2011x_om") then return "Invisible_Walk" end
            end,
            run= function(ent)
                local fly = ent:GetNWEntity("LordXSeperatePuppetHand")
                if ent:GetNW2Float("Godlysgrasp_duration") > CurTime() or IsValid(fly) then return "AbilityIdle" end
                if ent:GetNW2Float("ChargeAbilityDuration") > CurTime() then return "walk" end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return "charge" end
                if ent:GetNW2Bool("Bool_Invisible_2011x_om") then return "Invisible_Run" end
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

        if ent:GetNW2Float("ChargeDuration") > CurTime() then
            basetable =  {
                startoffset = Vector(50,0,25),  -- left-up, front-back, up-down
                dist=35,
                fov = ply:GetInfoNum("om_pills_default_fov", 80)+30,
                id = 1,
                transition = 1,
                canscroll = true,
            }
        end

        local fly = ent:GetNWEntity("LordXSeperatePuppetHand")
        if IsValid(fly) then
            basetable =  {
                startoffset = Vector(25,-25,15),  -- left-up, front-back, up-down
                dist=40,
                fov = ply:GetInfoNum("om_pills_default_fov", 80)+30,
                id = 1,
                transition = 1,
                canscroll = true,
                cameraentity = fly:GetPos(),
                viewentity = fly
            }
        end

        return basetable
    end,
    
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
            ducked= function(ply,ent)
                if SERVER then
                    return 70
                end
            end,
            charging= function(ply,ent)
                if SERVER then
                    return 1400
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

        passive = {
            ["FlyMovement"] = function(ply, ent, options, move, aim, fly)

                if IsValid(fly) then
                    local origin = fly:GetPos()
                    local function extrmeelyoverusedffunction(hitent)
                        if hitent == fly then return false end
                        if hitent == ply then return false end
                        if hitent:IsPlayer() then return false end
                        if hitent:IsNPC() then return false end
                        if hitent.IsNextBot and hitent:IsNextBot() then return false end
                        if ent:IsNextBot() then
                            if ent:GetPossessor() == hitent then
                                return false
                            end
                        end
                        return true
                    end

                    local function SlideMove(move, normal)
                        local dot = move:Dot(normal)
                        if dot < 0 then
                            move = move - normal * dot
                        end
                        return move
                    end

                    local probeDist = options["speed"]
                    local dir = move:GetNormalized()
                    local dirAng = dir:Angle()

                    local finalAng = Angle(aim.p, aim.y, 0)

                    fly:SetAngles(finalAng)
                    --[[
                    local tr_f = util.TraceLine({
                        start = origin,
                        endpos = origin + dir * probeDist,
                        filter = extrmeelyoverusedffunction
                    })

                    local tr_r = util.TraceLine({
                        start = origin,
                        endpos = origin + dirAng:Right() * probeDist,
                        filter = extrmeelyoverusedffunction
                    })

                    local tr_l = util.TraceLine({
                        start = origin,
                        endpos = origin - dirAng:Right() * probeDist,
                        filter = extrmeelyoverusedffunction
                    })

                    local tr_u = util.TraceLine({
                        start = origin,
                        endpos = origin + dirAng:Up() * probeDist,
                        filter = extrmeelyoverusedffunction
                    })

                    local tr_d = util.TraceLine({
                        start = origin,
                        endpos = origin - dirAng:Up() * probeDist,
                        filter = extrmeelyoverusedffunction
                    })
                    
                    if tr_f.Hit then
                        move = SlideMove(move, tr_f.HitNormal)
                    end
                    if tr_r.Hit then
                        move = SlideMove(move, tr_r.HitNormal)
                    end
                    if tr_l.Hit then
                        move = SlideMove(move, tr_l.HitNormal)
                    end

                    if tr_u.Hit and move.z > 0 then
                        move.z = 0
                    end
                    ]]


                    local mins = Vector(-8, -8, -8)
                    local maxs = Vector(8, 8, 8)

                    local hullTrace = util.TraceHull({
                        start = origin,
                        endpos = origin + move,
                        mins = mins,
                        maxs = maxs,
                        filter = extrmeelyoverusedffunction
                    })

                    --[[
                    debugoverlay.BoxAngles(
                        hullTrace.StartPos,
                        mins,
                        maxs,
                        angle_zero,
                        0.1,
                        Color(255, 0, 0)
                    )

                    debugoverlay.BoxAngles(
                        hullTrace.HitPos,
                        mins,
                        maxs,
                        angle_zero,
                        0.1,
                        Color(0, 255, 0)
                    )
                    ]]
                    
                    if hullTrace.Hit then
                        move = SlideMove(move, hullTrace.HitNormal)
                        fly:SetPos(origin + move * hullTrace.Fraction)
                    else
                        fly:SetPos(origin + move)
                    end

                    ent:SetNW2Vector("CurrentVelocity_fly", move)

                    ent:SetNW2Angle("pill_assignedangle", fly:GetAngles())
                end
            end,
            ["FlyingEnd"] = function(ply, ent)
                ent.LordXSeperatePuppetHand:Remove()
                ent:SetNW2Float('ClickDebounce_jump', CurTime()+0.5)

                timer.Simple(0, function()
                    if !IsValid(ply) then return end
                    if ply:IsPlayer() then 
                        ply:SetMoveType(MOVETYPE_WALK)
                    else
                        ply:SetMoveType(0)
                    end
                    ply:SetSolid(SOLID_BBOX)
                    timer.Simple(0.02, function()
                        if !IsValid(ply) then return end
                        if !IsValid(ent) then return end
                        ply:SetVelocity(ent:GetNW2Vector("CurrentVelocity_fly")*35)
                    end)
                end)
            end,
        },
    },

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["LordX_charging"]
            end,
            name = function(uselessvar,ply,ent)
                return "Dazy Charge"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_E
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("cd_charge_lordx_OM")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 20
            end,
            survivor = false,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["LordX_godsmockery"]
            end,
            name = function(uselessvar,ply,ent)
                return "Gods mockery"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_R
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("cd_godsmockery_lordx_OM")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 30
            end,
            survivor = false,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["lord_x_gods_mockery"]
            end,
            name = function(uselessvar,ply,ent)
                return "Godly Grasp"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_T
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("cd_godlygrasp_lordx_OM")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 30
            end,
            survivor = false,
            font = "CreditsText",
        },
    },

    jumpPower=400,
       
    speedhandeler_om = {
        modifiers = {
            ['Function1'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("ChargeAbilityDuration") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
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
        end
        if event == "Attack" then
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
                    KillerdamagestunDynamic({
                        ply = ply,
                        target = nearest,
                        DamageNumb = 45,
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
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_killer_om(initializetable2["entity"])
        if SERVER then
            initializetable2["entity"]:SetNW2Float('OM_friction', 1)
            initializetable2["player"]:SetHealth(100)
            initializetable2["player"]:SetMaxHealth(100)
            --initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",100)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",100)

            initializetable2["player"]:SetNW2Bool("OM_character_monster", true)

            initializetable2["player"]:SetNW2String("TerrorRadius_om","OM/music/2011Xradius.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life1_om","OM/music/2011Xchase.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life2_om","OM/music/2011Xchaselast.wav")

            initializetable2["player"].OM_StunFunction = function()
                local ent = initializetable2["entity"]
                if !IsValid(ent) then return end
                ent:SetNW2Float("ChargeAbilityDuration", 0)
                ent:SetNW2Bool("ShouldCharge_2011x0", false)
                ent:SetNW2Float("ChargeDuration", 0)
                ent:SetNW2Float("ChargeDurationFake", 0)
            end
        end
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetGravity(1)

            if bit.band(initializetable2["player"]:GetFlags(), FL_NOTARGET) ~= 0 then
                initializetable2["player"]:RemoveFlags(FL_NOTARGET)
            end
            initializetable2["player"]:SetViewEntity(initializetable2["player"])
        end
        initializetable2["entity"]:StopSound("om/lordx/LordXChargee.wav")
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", 1)

            local function tick(pitchper)
                pitchper = pitchper or 100
                AdvancedPillSound(
                    {
                        stringe = "OM/2011x/precharge.wav",
                        pitchPercent = pitchper,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)
            end

            if ent:GetNW2Float("ChargeAbilityDuration") > CurTime() then --ChargeAbilityDurationChargeAbilityDuration
                if not ent:GetNW2Bool("ShouldCharge_2011x0") then
                    ent:SetNW2Bool("ShouldCharge_2011x0", true)
                end
                if ent:GetNW2Float("chargeChargeUpTick") > CurTime() then
                else
                    ent:SetNW2Float("chargecurrentpitch", ent:GetNW2Float("chargecurrentpitch")+10 )  
                    ent:SetNW2Float("chargecurrentpitchTime", ent:GetNW2Float("chargecurrentpitchTime")+0.16 )  
                    ent:SetNW2Float("chargeChargeUpTick", CurTime()+math.Clamp(1-ent:GetNW2Float("chargecurrentpitchTime"), 0.2, 1))  
                    tick(math.Clamp(100-ent:GetNW2Float("chargecurrentpitch"), 10, 100))
                end
            else
                if ent:GetNW2Bool("ShouldCharge_2011x0") then
                    ent:SetNW2Bool("ShouldCharge_2011x0", false)
                    ent:SetNW2Float("ChargeDuration", CurTime()+ 4.7)
                    tick()
                    if ent:GetNW2Float("chargecurrentpitch") ~= 100 then
                        AdvancedPillSound(
                            {
                                stringe = "OM/silver/charge cancel.wav",
                                pitchPercent = pitchper,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        ent:SetNW2Float("cd_charge_lordx_OM", CurTime()+ 20)
                    end
                end
            end

            if ent:GetNW2Float("ChargeDuration") > CurTime() then
                
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.1)
                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 3)

                if not ent:GetNW2Bool("ChargeDuration_bool") then
                    ent:SetNW2Bool("ChargeDuration_bool", true)
                    AdvancedPillSound(
                        {
                            stringe = "om/lordx/LordXChargee.wav",
                            pitchPercent = 100,
                            volume = 3,
                            soundLevel = 100
                        },
                        ent
                    )
                end

                ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.2)
                if ply:IsPlayer() then
                    ---math.Clamp(ent:GetNW2Float("OM_SetVelocity_speed")+3,0,800)
                    ent:SetNW2Float("OM_SetVelocity_speed", 750 )  
                    ply:SetNW2Vector("OM_SetVelocity_Vector",ply:EyeAngles():Forward() * (ent:GetNW2Float("OM_SetVelocity_speed")*2))
                else
                end

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
                    nearest:SetNWFloat("om_daze", CurTime() + 5)
                    KillerdamagestunDynamic({
                        ply = ply,
                        target = nearest,
                        DamageNumb = 45,
                        damagetype = DMG_CLUB,
                        CustomDamageSound = nil,
                        damagesound = true,
                        ShouldBlood = true,
                        flingremoveal = true,
                        ShouldBloodEffect = true
                    })


                    ent:SetNW2Float("ChargeDuration", 0)
                    ent:SetNW2Float("ChargeDurationFake", CurTime()+ 1)
                    ent:SetNW2Bool("ChargeDurationHit_bool",true)

                    if ent.PillAnim then

                        ent:PillAnim("Chargehit")
                    end
                end

            else
                if ent:GetNW2Bool("ChargeDuration_bool") and not ent:GetNW2Bool("ChargeDurationHit_bool") then
                    ent:SetNW2Bool("ChargeDuration_bool", false)
                    ent:SetNW2Float("cd_charge_lordx_OM", CurTime()+ 20)
                end
            end
            if ent:GetNW2Float("ChargeDurationFake") > CurTime() then
                ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.2)
                ply:SetNW2Vector("OM_SetVelocity_Vector", ply:GetNW2Vector("OM_SetVelocity_Vector")*0.99 )
            else
                ent:SetNW2Bool("ChargeDurationHit_bool", false)
            end

            if ent:GetNWFloat("om_noodle_2011x_colorfate") > CurTime() then
                local colorfateclamp = math.Clamp( ( ent:GetNWFloat("om_noodle_2011x_colorfate") - CurTime() ) / 0.9, 0, 1 )
                local colorlerp = Lerp(colorfateclamp, 0, 255)
                ent:GetPuppet():SetColor(Color(colorlerp,colorlerp,colorlerp,colorlerp))

                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
            end

            if ent:GetNW2Float("GodsMockeryHitDuration") > CurTime() then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.1)
            end
            if ent:GetNW2Float("Godlysgrasp_duration") > CurTime() then
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.2)
                local puppet = ent:GetPuppet()
                if not ent:GetNW2Bool("Godlysgrasp_duration_bool") then
                    ent:SetNW2Bool("Godlysgrasp_duration_bool", true)
                end
            else
                if ent:GetNW2Bool("Godlysgrasp_duration_bool") then
                    ent:SetNW2Bool("Godlysgrasp_duration_bool", false)
                end
            end
            local fly = ent:GetNWEntity("LordXSeperatePuppetHand")

            if IsValid(fly) then
                local puppet = ent:GetPuppet()
                puppet:SetPoseParameter("aim_yaw", 0)
                puppet:SetPoseParameter("aim_pitch", 0)
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.5)
                if ent:GetNW2Float("Godlysgrasp_duration") > CurTime() then
                    if not ent:GetNW2Bool("Godlysgrasp_duration_bool_fly") then
                        ent:SetNW2Bool("Godlysgrasp_duration_bool_fly", true)
                        ent:SetNW2Vector("LordX_handPosorder_vector_lastpos", fly:GetPos())
                    end
                    if !IsValid(ent:GetNW2Entity("LordXGrabEntity")) then

                        local options = {
                            speed = 23*0.7,
                        }

                        local move = Vector(0, 0, 0)
                        local angled = fly:GetAngles()
                        local aim = Angle(0, ply:EyeAngles().y, 0)

                        if ply:IsPlayer() then
                            aim.p = math.Clamp(ply:EyeAngles().p, -90, 90)

                            if ply:KeyDown(IN_SPEED) then
                                options.speed = 25
                            else
                                options.speed = 15
                            end
                            if ply:KeyDown(IN_FORWARD) then
                                move = angled:Forward() * ent:GetNW2Float("SpeedAccelerate")
                            elseif ply:KeyDown(IN_BACK) then
                                move = angled:Forward() * -ent:GetNW2Float("SpeedAccelerate")
                            end
                            if ply:KeyDown(IN_MOVERIGHT) then
                                move = move + angled:Right() * ent:GetNW2Float("SpeedAccelerate")
                            elseif ply:KeyDown(IN_MOVELEFT) then
                                move = move + angled:Right() * -ent:GetNW2Float("SpeedAccelerate")
                            end
                            
                            if not ( (ply:KeyDown(IN_FORWARD)) or (ply:KeyDown(IN_MOVERIGHT)) or (ply:KeyDown(IN_MOVELEFT)) or (ply:KeyDown(IN_JUMP)) or (ply:KeyDown(IN_DUCK)) or (ply:KeyDown(IN_BACK)) ) then
                                if ent:GetNW2Float("SpeedAccelerate") > 0 then 
                                    ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") - 0.35 )
                                    move = ( ent:GetNW2Vector("CurrentVelocity_fly") - Vector(0,0,0) ):GetNormalized() * ent:GetNW2Float("SpeedAccelerate")
                                end
                            else
                                if ent:GetNW2Float("SpeedAccelerate") < options.speed then 
                                    ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") + 0.35 )
                                elseif ent:GetNW2Float("SpeedAccelerate") > options.speed then 
                                    ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") - 0.35 )
                                end
                            end
                        end

                        local origin = fly:GetPos()
                        local endposition = ((origin+move)-origin):GetNormalized()

                        ent.formTable.Outcomememories_stats.passive.FlyMovement(ply, ent, options, move, aim, fly, origin)

                        if move ~= Vector(0,0,0) then
                            ent:SetNW2Float("OM_LordX_grabability_state", 2)
                            ent:SetNW2Vector("LordX_handPosorder_vector"..ent:GetNW2Float("LordX_handPosorder_float",0),fly:GetPos())
                            ent:SetNW2Float("LordX_handPosorder_float", 1+ent:GetNW2Float("LordX_handPosorder_float",0))

                            if ent:GetNW2Vector("LordX_handPosorder_vector_lastpos"):Distance(origin) > 200 then
                                ent:SetNW2Vector("LordX_handPosorder_vector_lastpos", fly:GetPos())
                                fly:SetNWBool("CheckMark".. ent:GetNW2Float("LordX_handPosorder_float"), true)
                                fly:SetNWVector("LordX_handPosorder_vector_c"..fly:GetNWFloat("LordX_handPosorder_float_c",0),fly:GetPos())
                                fly:SetNWFloat("LordX_handPosorder_float_c", 1+fly:GetNWFloat("LordX_handPosorder_float_c",0))
                            end
                        else
                            ent:SetNW2Float("OM_LordX_grabability_state", 3)
                        end
                        ply:SetViewEntity(fly)

                        local nearest
                        local nearestDist = math.huge

                        local attackPos = fly:GetPos()

                        for _, ent2 in pairs(ents.FindInSphere(attackPos, 100)) do
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
                            ent:SetNW2Float("Godlysgrasp_duration", 0)
                            ent:SetNW2Entity("LordXGrabEntity", nearest)

                            local last = CurTime() + 1
                            local enemyragdoll = CreateRagdolLCharacter_OM({
                                target = nearest,
                                host = ent,

                                shouldremove = function(createfakeragdoll)
                                    if not IsValid(createfakeragdoll) then return true end
                                    if not IsValid(nearest) then return true end
                                    if not IsValid(ent) then return true end

                                    if nearest:GetNW2Bool("clashingminigame_om_isinminigame") then return false end
                                    if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return false end

                                    return true
                                end,

                                shoulddocustomfunction = function(createfakeragdoll)
                                    if not IsValid(createfakeragdoll) then return end
                                    if not IsValid(ent) then return end
                                    
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

                                    if ply:GetNW2Bool("clashingminigame_om_isinminigame") then
                                        headPhys:SetPos(fly:GetPos())
                                        headPhys:SetAngles(fly:GetAngles())
                                        headPhys:SetVelocityInstantaneous(vector_origin)
                                        headPhys:Wake()
                                        nearest:SetNW2Float("ragdolltype_grab", CurTime()+0.1)
                                        ent:SetNW2Float("OM_LordX_grabability_state", 3)
                                    end
                                end
                            })

                            OM_Minigame(ply, nearest, {
                                EndRoundLogic = function()
                                    if nearest:GetNW2Bool("Survivor_Downed_OM") then
                                        return {
                                            ['ply'] = 'Win',
                                            ['target'] = 'Loss'
                                        }
                                    end
                                    if !IsValid(ent) then return {
                                            ['ply'] = 'Win',
                                            ['target'] = 'Loss'
                                        }
                                    end
                                    if ent:GetNW2Entity("LordXGrabEntity") ~= nearest then
                                        return {
                                            ['ply'] = 'Win',
                                            ['target'] = 'Loss'
                                        }
                                    end
                                end,
                                CanPlyplay = false,
                                TimeLimitBool = false,
                                CanPlyEndRound = false,
                                Cantargetmessup = false,
                                starthealth = 75,
                            })
                            if ent:GetNW2Float("LordX_handPosorder_float",0) <= 0 then
                                ent:SetNW2Vector("LordX_handPosorder_vector"..ent:GetNW2Float("LordX_handPosorder_float",0),fly:GetPos())
                                ent:SetNW2Float("LordX_handPosorder_float", 1+ent:GetNW2Float("LordX_handPosorder_float",0))
                                ent:SetNW2Vector("LordX_handPosorder_vector"..ent:GetNW2Float("LordX_handPosorder_float",0),fly:GetPos())
                                ent:SetNW2Float("LordX_handPosorder_float", 1+ent:GetNW2Float("LordX_handPosorder_float",0))
                            end

                        end
                    end
                else
                    if ent:GetNW2Float("LordX_handPosorder_float") > 0 then
                        if not ent.handposordercd then ent.handposordercd = 0 end
                        --[[
                        ply:SetViewEntity(fly)
                        ent:SetNW2Float("OM_LordX_grabability_state", 1)
                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+1.4)

                        ent:SetNW2Float("LordX_handPosorder_float", math.Clamp(ent:GetNW2Float("LordX_handPosorder_float",0)-1,0,1e9))
                        local vector1 = ent:GetNW2Vector("LordX_handPosorder_vector"..ent:GetNW2Float("LordX_handPosorder_float",0))
                        local vector2 = fly:GetNWVector("LordX_handPosorder_vector_c"..fly:GetNWFloat("LordX_handPosorder_float_c",0)-1)
                        if vector1 == vector2 then
                            fly:SetNWFloat("LordX_handPosorder_float_c", fly:GetNWFloat("LordX_handPosorder_float_c",0)-1)
                        end
                        fly:SetPos(ent:GetNW2Vector("LordX_handPosorder_vector"..ent:GetNW2Float("LordX_handPosorder_float",0)))
                        ]]

                        ply:SetViewEntity(fly)
                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+1.4)

                        if fly:GetNWBool("CheckMark".. ent:GetNW2Float("LordX_handPosorder_float")) then
                            fly:SetNWBool("CheckMark".. ent:GetNW2Float("LordX_handPosorder_float"), false)
                            fly:SetNWFloat(
                                "LordX_handPosorder_float_c",
                                fly:GetNWFloat("LordX_handPosorder_float_c",0)-1
                            )
                        end

                        if not ent.PittyDecrease_lordx_hand then
                            ent.PittyDecrease_lordx_hand = true

                            ent:SetNW2Float("LordX_handPosorder_float",ent:GetNW2Float("LordX_handPosorder_float",0)-1)
                        end

                        if fly:GetPos():Distance(ent:GetNW2Vector("LordX_handPosorder_vector"..ent:GetNW2Float("LordX_handPosorder_float",0))) < 5 then
                            local clamp = false
                            if IsValid(ent:GetNW2Entity("LordXGrabEntity")) then
                                clamp = true
                            end
                            if (clamp and ent:GetNW2Float("LordX_handPosorder_float") > 20) or not clamp then
                                ent:SetNW2Float(
                                    "LordX_handPosorder_float",
                                    math.Clamp(ent:GetNW2Float("LordX_handPosorder_float",0)-1,0,1e9)
                                )
                                ent:SetNW2Float("OM_LordX_grabability_state", 1)
                            else
                                ent:SetNW2Float("OM_LordX_grabability_state", 3)
                            end
                        end

                        local targetPos = ent:GetNW2Vector( "LordX_handPosorder_vector"..ent:GetNW2Float("LordX_handPosorder_float",0) )
                        local currentPos = fly:GetPos()
                        local speed = 75
                        if IsValid(ent:GetNW2Entity("LordXGrabEntity")) then
                            speed = 20
                        end

                        local smoothPos = LerpVector(FrameTime() * speed, currentPos, targetPos)

                        fly:SetPos(smoothPos)

                    else
                        if ent:GetNW2Bool("Godlysgrasp_duration_bool_fly") then
                            ent:PillAnim("AbilityEnd")
                            ent:SetNW2Bool("Godlysgrasp_duration_bool_fly", false)
                            ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+1.4)
                            ply:SetViewEntity(ply)
                            ent:SetNW2Entity("LordXGrabEntity", NULL)
                            fly:Remove()
                            ent:SetNW2Float("cd_godlygrasp_lordx_OM", CurTime() + 30)
                        end
                    end
                end


                local ent2 = ent:GetNW2Entity("LordXGrabEntity")
                if IsValid(ent2) then
                    if not ent.damagegrab_cd then ent.damagegrab_cd = 0 end


                    local shoulddamage = true

                    if ent2:Health() < 0.1 or ent2:GetNW2Bool('Survivor_Downed_OM') or not ent2:GetNW2Bool("clashingminigame_om_isinminigame") then
                        shoulddamage = false
                        ent:SetNW2Entity("LordXGrabEntity", NULL)
                    end

                    if ent.damagegrab_cd < CurTime() then
                        ent.damagegrab_cd = CurTime() + 0.5


                        if shoulddamage then
                            KillerdamagestunDynamic({
                                ply = ply,
                                target = ent2,
                                DamageNumb = 2,
                                damagetype = DMG_BULLET,
                                CustomDamageSound = nil,
                                damagesound = false,
                                ShouldBlood = true,
                                flingremoveal = false,
                                ShouldBloodEffect = false
                            })
                        end
                    end

                end

                fly:SetAngles(ply:EyeAngles())
            end
        end
    end,


    noodles_OM_survivor_keybinds = function(ply, ent, button)
        if SERVER then
            if button == KEY_E then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("ShouldCharge_2011x0") then return end
                if ent:GetNW2Bool("ChargeDuration_bool") then return end
                if ent:GetNW2Bool("ChargeDurationHit_bool") then return end
                if ent:GetNW2Float("ChargeDurationFake") > CurTime() then return end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return end
                if ent:GetNW2Float("cd_charge_lordx_OM") > CurTime() then return end

                if ent:GetNW2Float("om_noodle_2011x_colorfate") > CurTime() then return end
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration") > CurTime() then return end
                if ent:GetNW2Float("GodsMockeryHitDuration") > CurTime() then return end
                
                if ent:GetNW2Float("Godlysgrasp_duration") > CurTime() then return end

                if ent:GetNW2Bool("Godlysgrasp_duration_bool") then return end
                if ent:GetNW2Float("LordX_handPosorder_float") > 0 then return end
                if ent:GetNW2Bool("Godlysgrasp_duration_bool_fly") then return end
                if IsValid(ent:GetNW2Entity("LordXGrabEntity")) then return end


                if ent:GetNW2Float("ChargeAbilityDuration") > CurTime() then return end

                ent:SetNW2Float("ChargeAbilityDuration", CurTime()+ 3.5)
                ent:SetNW2Float("chargecurrentpitch", 0 )  
                ent:SetNW2Float("chargecurrentpitchTime", 0) 
                ent:SetNW2Float("OM_SetVelocity_speed", 0)

            end
            if button == KEY_R then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("ShouldCharge_2011x0") then return end
                if ent:GetNW2Bool("ChargeDuration_bool") then return end
                if ent:GetNW2Bool("ChargeDurationHit_bool") then return end
                if ent:GetNW2Float("ChargeDurationFake") > CurTime() then return end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return end

                if ent:GetNW2Float("om_noodle_2011x_colorfate") > CurTime() then return end
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration") > CurTime() then return end
                if ent:GetNW2Float("GodsMockeryHitDuration") > CurTime() then return end
                
                if ent:GetNW2Float("Godlysgrasp_duration") > CurTime() then return end

                if ent:GetNW2Bool("Godlysgrasp_duration_bool") then return end
                if ent:GetNW2Float("LordX_handPosorder_float") > 0 then return end
                if ent:GetNW2Bool("Godlysgrasp_duration_bool_fly") then return end
                if IsValid(ent:GetNW2Entity("LordXGrabEntity")) then return end


                if ent:GetNW2Float("cd_godsmockery_lordx_OM") > CurTime() then return end

                local tr = {
                    mins = nil,
                    maxs = nil,
                    mask = MASK_PLAYERSOLID
                }

                local function FindSafePosNearEntity(ent, ply)
                    if not IsValid(ent) then return nil end

                    tr.mins = ply:OBBMins()
                    tr.maxs = ply:OBBMaxs()

                    local basePos = ent:GetPos()

                    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
                    local radius = math.max(
                        math.abs(mins.x), math.abs(maxs.x),
                        math.abs(mins.y), math.abs(maxs.y)
                    ) + 80

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

                local targets = {}

                for _, ent2 in ipairs(ents.GetAll()) do
                    if !IsValid(ent2) then continue end

                    if (ent2:IsPlayer() or ent2:IsNPC() or ent2:IsNextBot()) and ent2:Health() > 0.5 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if not GetConVar("PVPStun_OM_exe"):GetBool() then
                            if ent2:GetNW2Bool("OM_character_monster") then continue end
                        end

                        if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                        if not Mutal_OMCanDamage(ply, ent, ent2) then continue end
                        table.insert(targets, ent2)
                    end
                end

                local chosenEnt
                local finalPos

                if #targets > 0 then
                    local random = math.random(#targets)
                    --print(random)
                    chosenEnt = targets[random]
                    finalPos = FindSafePosNearEntity(chosenEnt, ply)
                end

                if finalPos then

                    ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                    ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)

                    AdvancedPillSound(
                        {
                            stringe = "om/lordx/LordXSpooky.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent:SetNWFloat("om_noodle_2011x_colorfate", CurTime()+0.9)
                    ent:SetNW2Float("Eddy_2011x_godstrickeryduration", CurTime()+1.2)
                    timer.Simple(1,function()
                        if !IsValid(ent) then return end
                        ply:SetPos(finalPos)

                        ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                        ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)

                        ent:GetPuppet():SetColor(Color(255,255,255,255))

                        local last = CurTime() + 2
                        local flung = false
                        local ent2 = chosenEnt

                        local enemyragdoll = CreateRagdolLCharacter_OM({
                            target = ent2,
                            host = ent,

                            shouldremove = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return true end
                                if not IsValid(ent2) then return true end
                                if not IsValid(ent) then return true end

                                if (last < CurTime() ) then
                                    return true
                                else
                                    
                                end
                                return false
                            end,

                            shoulddocustomfunction = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return end
                                if not IsValid(ent) then return end
                                if flung then return end
                                flung = true


                                local dir = (ent2:GetPos() - finalPos ):GetNormalized()
                                local force = dir * 400

                                local phys = createfakeragdoll:GetPhysicsObject()
                                if IsValid(phys) then
                                    phys:SetVelocity(force)
                                    phys:AddAngleVelocity(VectorRand() * 1250)
                                end

                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                    local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                    if IsValid(bonePhys) then
                                        bonePhys:SetVelocity(force)
                                        bonePhys:AddAngleVelocity(VectorRand() * 1250)
                                    end
                                end
                            end
                        })

                        local anim = ent:GetPuppet():LookupSequence("GodsMockery")
                        local duration = ent:GetPuppet():SequenceDuration(anim)
                        ent:SetNW2Float("GodsMockeryHitDuration", CurTime() + duration+0.5)
                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + duration+0.5)
                        ply:SetNW2Float("AttackCooldown_OM", CurTime() + duration+1.5)

                        ent:PillAnim("GodsMockery")

                        local ent2pos = ent2:GetPos()
                        local plypos = ply:GetPos()
                        local angl = ( Vector(ent2pos.x,ent2pos.y,0)-Vector(plypos.x,plypos.y,0) ):Angle()
                        ent:SetNW2Angle("pill_assignedangle", angl)

                        ent:SetNW2Float("cd_godsmockery_lordx_OM", CurTime()+ 30)


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

                    end)
                end
            end
            if button == KEY_T then

                if ent:GetNW2Bool("ShouldCharge_2011x0") then return end
                if ent:GetNW2Bool("ChargeDuration_bool") then return end
                if ent:GetNW2Bool("ChargeDurationHit_bool") then return end
                if ent:GetNW2Float("ChargeDurationFake") > CurTime() then return end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return end

                if ent:GetNW2Float("om_noodle_2011x_colorfate") > CurTime() then return end
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration") > CurTime() then return end
                if ent:GetNW2Float("GodsMockeryHitDuration") > CurTime() then return end

                if ent.LordXSeperatePuppetHand and IsValid(ent.LordXSeperatePuppetHand) then
                    ent:SetNW2Float("Godlysgrasp_duration", 0)
                    return end
                if ent:GetNW2Float("Godlysgrasp_duration") > CurTime() then return end

                if ent:GetNW2Bool("Godlysgrasp_duration_bool") then return end
                if ent:GetNW2Float("LordX_handPosorder_float") > 0 then return end
                if ent:GetNW2Bool("Godlysgrasp_duration_bool_fly") then return end
                if IsValid(ent:GetNW2Entity("LordXGrabEntity")) then return end

                if ent:GetNW2Float("cd_godlygrasp_lordx_OM") > CurTime() then return end

                ent:GetPuppet():SetNW2Float('kolossos_block_outline',CurTime()+0.25)
                ent:GetPuppet():SetNW2Float('sonic_glow_duration',CurTime()+0.25)

                local anim = ent:GetPuppet():LookupSequence("AbilityStart")
                local duration = ent:GetPuppet():SequenceDuration(anim)
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + duration+0.5)
                ent:SetNW2Float("Godlysgrasp_duration", CurTime() + 8)
                ent:PillAnim("AbilityStart")

                timer.Simple(1,function()
                    if !IsValid(ent) then return end
                    local LordXSeperatePuppetHand = ents.Create("prop_dynamic")

                    if IsValid(LordXSeperatePuppetHand) then
                        LordXSeperatePuppetHand:SetModel("models/hunter/blocks/cube025x025x025.mdl")
                        local puppet = ent:GetPuppet()
                        LordXSeperatePuppetHand:SetPos(puppet:GetPos()+puppet:GetUp()*55+puppet:GetForward()*25)
                        LordXSeperatePuppetHand:SetAngles(puppet:GetAngles())
                        LordXSeperatePuppetHand:Spawn()
                        LordXSeperatePuppetHand:Activate()
                        LordXSeperatePuppetHand:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

                        ent:DeleteOnRemove(LordXSeperatePuppetHand)

                        ent.LordXSeperatePuppetHand = LordXSeperatePuppetHand
                        ent:SetNWEntity("LordXSeperatePuppetHand",LordXSeperatePuppetHand)
                        
                        ent:SetNW2Float("Godlysgrasp_duration", CurTime() + 8)
                        ent:SetNW2Float("ScanForEntities_OM", CurTime() + 8)
                    end
                end)

            end
        end
    end,

    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if SERVER then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("ShouldCharge_2011x0") then return end
                if ent:GetNW2Bool("ChargeDuration_bool") then return end
                if ent:GetNW2Bool("ChargeDurationHit_bool") then return end
                if ent:GetNW2Float("ChargeDurationFake") > CurTime() then return end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return end

                if ent:GetNW2Float("om_noodle_2011x_colorfate") > CurTime() then return end
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration") > CurTime() then return end
                if ent:GetNW2Float("GodsMockeryHitDuration") > CurTime() then return end
                
                if ent:GetNW2Float("Godlysgrasp_duration") > CurTime() then return end

                if ent:GetNW2Bool("Godlysgrasp_duration_bool") then return end
                if ent:GetNW2Float("LordX_handPosorder_float") > 0 then return end
                if ent:GetNW2Bool("Godlysgrasp_duration_bool_fly") then return end
                if IsValid(ent:GetNW2Entity("LordXGrabEntity")) then return end
                
                local puppet = ent:GetPuppet()
                if not IsValid(puppet) then return end
                    
                local layeredAnim = puppet:AddGesture(ACT_MELEE_ATTACK_SWING_GESTURE, false)

                local current = 1
                puppet:SetLayerWeight(layeredAnim, current)
                puppet:SetLayerPriority(layeredAnim, 10)
                puppet:SetLayerPlaybackRate(layeredAnim, 1)

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
                    puppet:RemoveLayer(layeredAnim)
                end)

                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1)
                    
                AdvancedPillSound(
                    {
                        stringe = "OM/2011xswing.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
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


if CLIENT then

    local beamMat = {
        [1] = Material("icons/lord_x_bone")
    }
    hook.Add("PostDrawTranslucentRenderables", "lordx_arm_beam", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        for _, ent in ipairs(ents.GetAll()) do
            if not IsValid(ent) or ent == ply then continue end

            if ent:GetNW2Float("OM_LordX_grabability_state") <= 0 then continue end

            local hande = ent:GetNWEntity("LordXSeperatePuppetHand")
            if not IsValid(hande) then continue end

            local count = hande:GetNWFloat("LordX_handPosorder_float_c", 0)

            local previousPos = ent:GetPos() + Vector(0, 0, 50)

            for i = 0, count do
                local currentPos

                if i == count then
                    currentPos = hande:GetPos()
                else
                    currentPos = hande:GetNWVector(
                        "LordX_handPosorder_vector_c" .. i
                    )
                end

                local beamLength = (currentPos - previousPos):Length()

                local t = CurTime() * 4
                t = -t

                if ent:GetNW2Float("OM_LordX_grabability_state") == 1 then
                    t = -t
                end
                if ent:GetNW2Float("OM_LordX_grabability_state") == 3 then
                    t = 0
                end

                render.SetMaterial(beamMat[1])

                render.DrawBeam(
                    previousPos,
                    currentPos,
                    60,
                    t,
                    t + beamLength / 100,
                    Color(255,255,255)
                )

                previousPos = currentPos
            end
        end
    end)
end
