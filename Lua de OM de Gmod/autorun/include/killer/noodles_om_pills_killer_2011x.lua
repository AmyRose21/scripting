
AddCSLuaFile()
--

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
    ["SONIC'S CHOKING 2011x"] = Material("icons/SONIC'S CHOKING 2011x.png"),
    ["Invisible 2011x"] = Material("icons/Invisible 2011x.png"),
    ["rage of sonics coming 2 2011x"] = Material("icons/rage of sonics coming 2 2011x.png"),
    ["God's trickery 2011x"] = Material("icons/God's trickery 2011x.png"),
    ["RAGE METER NEW"] = Material("icons/RAGE METER NEW.png"),
}

pk_pills.register('pill_om_2011x', {

    printName='2011x',
    Outcomememories='2011x',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/2011x.mdl",

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
            InvisibleInNear = "InvisibleInNear",
        },

        ShouldMoveRotate_lerpspeed={
            idle= function(ent) 
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
                    return 99
                end
                return 7
            end,
            run= function(ent) 
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
                    return 99
                end
                return 7
            end,
            walk= function(ent) 
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
                    return 99
                end
                return 7
            end,
            jump= function(ent) 
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
                    return 99
                end
                return 7
            end,
            fall= function(ent)
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
                    return 99
                end
                return 7
            end,
        },
        ShouldMoveRotate={
            idle= function(ent) 
                if ent:GetNW2Float("ChargeDuration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
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
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
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
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
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
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
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
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
                    return "assignedagnles"
                end
                return "notshftlock"
            end,
        },

        ShouldAlternate={
            fall = function(ent)
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return "fly" end
                if IsValid(ent:GetNW2Entity("ChargeGrabEntity")) then return "choke" end
            end,
            idle= function(ent)
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return "fly" end
                if IsValid(ent:GetNW2Entity("ChargeGrabEntity")) then return "choke" end
                if ent:GetNW2Bool("Bool_Invisible_2011x_om") then return "Invisible_idle" end
            end,
            walk= function(ent)
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return "fly" end
                if IsValid(ent:GetNW2Entity("ChargeGrabEntity")) then return "choke" end
                if ent:GetNW2Bool("Bool_Invisible_2011x_om") then return "Invisible_Walk" end
            end,
            run= function(ent)
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return "fly" end
                if IsValid(ent:GetNW2Entity("ChargeGrabEntity")) then return "choke" end
                if ent:GetNW2Bool("Bool_Invisible_2011x_om") or ent:GetNW2Float("2011x_rage_duration", 0 ) > CurTime() then return "Invisible_Run" end
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
            bonecenter = "UpperTorso",
        }
        if ent:GetNW2Float("ChargeDuration") > CurTime() then
            basetable =  {
                startoffset = Vector(50,0,15),  -- left-up, front-back, up-down
                dist=75,
                fov = ply:GetInfoNum("om_pills_default_fov", 80)+30,
                id = 1,
                transition = 1,
                canscroll = true,
            }
        end

        return basetable
    end,


    OM_transitionbar_type1table = {
        ColorDisplay = Color(255,0,0,255),
        CanShowcase = function(e,ply, ent)
            return ent:GetNW2Bool("Bool_Invisible_2011x_om")
        end,
        Factor = function(e,ply, ent)
            return math.Clamp((ent:GetNW2Float("duration_invisible_2011x_OM")-CurTime())/20, 0, 20)
        end,
        offset = function(e,ply, ent)
            return Vector(-20,15,0)
        end
    },

    OM_UI_custom_start = function(ply, ent)
        local screenW, screenH = ScrW(), ScrH()
        local middlex, middley = screenW * 0.5, screenH * 0.5
        local iconsize = screenW / 13

        local yaxis_health_bg = screenH - iconsize * 2.25
        local textureW, textureH = iconsize * 3, iconsize * 6

        -- Smooth X offset
        local targetOffset = 0

        if ent:GetNW2Bool("ActivatedRage") then
            targetOffset = textureW * 0.35
        end

        ent.OM_UI_RageOffset = Lerp(
            FrameTime() * 5,
            ent.OM_UI_RageOffset or 0,
            targetOffset
        )

        local xoffset = ent.OM_UI_RageOffset

        surface.SetDrawColor(75, 0, 0, 255)
        surface.DrawRect(
            0 + textureW * 0.1 -xoffset*2,
            middley - textureH * 0.3,
            textureW * 0.22,
            textureH * 0.625
        )

        local factor = ent:GetNW2Float("Ragebar_factor")

        local revert = Lerp(factor, 1, 0)

        local lerpaxisy = Lerp(
            revert,
            middley - textureH * 0.3,
            middley - textureH * 0.3 + textureH * 0.625
        )

        local lerpsizey = Lerp(
            revert,
            textureH * 0.625,
            0
        )

        surface.SetDrawColor(255, 0, 0, 255)
        surface.DrawRect(
            0 + textureW * 0.1 -xoffset*2,
            lerpaxisy,
            textureW * 0.22,
            lerpsizey
        )

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(preservedmats["RAGE METER NEW"])
        surface.DrawTexturedRect(
            0 - textureW * 0.1 -xoffset*2,
            middley - textureH * 0.5,
            textureW,
            textureH
        )
    end,

    OM_UI_custom_end = function(ply, ent)
        if not ent.OM_ColorModifyIntensity then
            ent.OM_ColorModifyIntensity = 0
        end

        local target = ent:GetNW2Bool("Bool_Invisible_2011x_om") and 1 or 0

        ent.OM_ColorModifyIntensity = math.Approach(
            ent.OM_ColorModifyIntensity,
            target,
            FrameTime() * 3
        )

        local i = ent.OM_ColorModifyIntensity
        if i > 0 then
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = -0.1 * i,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = 1,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })
        end
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
                    return 545*1.75
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return 500
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return 2
                end
            end,
        }
    },

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Invisible 2011x"]
            end,
            name = function(uselessvar,ply,ent)
                return "Invisible"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_E
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("cd_invisible_2011x_OM")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 10
            end,
            survivor = false,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["SONIC'S CHOKING 2011x"]
            end,
            name = function(uselessvar,ply,ent)
                return "Charge"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_R
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("cd_charge_2011x_OM")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 35
            end,
            survivor = false,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["God's trickery 2011x"]
            end,
            name = function(uselessvar,ply,ent)
                return "God's Trickery"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_T
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("cd_godstrickery_2011x_OM")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 34
            end,
            survivor = false,
            font = "CreditsText",
        },
        [4] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["rage of sonics coming 2 2011x"]
            end,
            name = function(uselessvar,ply,ent)
                return "Rage"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_I
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("dash_OM_Fleetway_Cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 24
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

                if ent:GetNW2Bool("Bool_Invisible_2011x_om") then 
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.charging() - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
            ['Function2'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("2011x_rage_duration", 0 ) > CurTime() then 
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.charging() - ent.formTable.Outcomememories_stats.moveSpeed.run()
                end

                return sendtotable
            end,
            ['Function3'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("indicatorduration_invis_2011x") > CurTime() then 
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.run()*0.5 - ent.formTable.Outcomememories_stats.moveSpeed.charging()
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
        
    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if event == "Step" then
        end

        if event == "Attack" then

            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end

            if SERVER then

                local nearest
                local nearestDist = math.huge

                local forward = 10
                local AttackRadius = 110

                local attackPos = ent:LocalToWorld(Vector(0, 0, 50)+ent:GetPuppet():GetForward()*forward)

                for _, ent2 in pairs(ents.FindInSphere(attackPos, AttackRadius)) do
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
                    local damageamount = 25
                    KillerdamagestunDynamic({
                        ply = ply,
                        target = nearest,
                        DamageNumb = damageamount,
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

            initializetable2["entity"]:SetNW2Bool("OM_2011x_pill", true)

            initializetable2["player"].OMCompelteClash_lnz = function(Wintype)
                if !IsValid(initializetable2["entity"]) then return end

                local ply = initializetable2["player"]
                local ent = initializetable2["entity"]

                ent:SetNW2Entity("ChargeGrabEntity", NULL)
                return true
            end

            initializetable2["player"].OM_StunFunction = function()
                if !IsValid(initializetable2["entity"]) then return end

                local ply = initializetable2["player"]
                local ent = initializetable2["entity"]

                ent:SetNW2Entity("ChargeGrabEntity", NULL)

                return true
            end

            initializetable2["player"].CustomFunctionForDowning_OM = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if IsValid(initializetable2["entity"]) then
                    timer.Simple(1,function()
                        if !IsValid(initializetable2["entity"]) then return end
                        AdvancedPillSound(
                            {
                                stringe = {"OM/2011x/2011xDown1.wav", "OM/2011x/2011xDown2.wav", "OM/2011x/2011xDown3.wav"},
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            initializetable2["entity"]
                        )
                    end)
                end
            end

            initializetable2["player"].OM_AttacterCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]
                    if ent:GetNW2Float("2011x_rage_duration", 0 ) > CurTime() then
                        ent:SetNW2Float("ScanForEntities_OM", CurTime() + 3)
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
                ent:SetNW2Float("ChargeAbilityDuration", 0)  
                if ent:GetNW2Bool("ShouldCharge_2011x0") then
                    ent:SetNW2Bool("ShouldCharge_2011x0", false)
                    ent:SetNW2Float("cd_charge_2011x_OM", CurTime()+ 24)

                    AdvancedPillSound({
                        stringe = "OM/2011x/fail.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 76
                    }, ent)
                end

                if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) < CurTime() then
                    AdvancedPillSound({
                        stringe = {
                            "OM/2011x/StunGrunt1.wav",
                            "OM/2011x/StunGrunt2.wav",
                            "OM/2011x/StunGrunt3.wav",
                            "OM/2011x/StunGrunt4.wav",
                            "OM/2011x/StunGrunt5.wav",
                            "OM/2011x/StunGrunt6.wav",
                            "OM/2011x/StunGrunt7.wav"
                        },
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 76
                    }, ent)
                end
                if ent:GetNW2Float("2011x_rage_duration", 0 ) > CurTime() then
                    return {
                        canceltype = "effectstun",
                        StunDur=tableofitemz["StunDur"]*0.6
                    }
                else
                    ent:SetNW2Float("Ragebar_factor", ent:GetNW2Float("Ragebar_factor") + 0.0085)
                end
            end

        end
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetGravity(1)

            if bit.band(initializetable2["player"]:GetFlags(), FL_NOTARGET) ~= 0 then
                initializetable2["player"]:RemoveFlags(FL_NOTARGET)
            end
        end
        initializetable2["entity"]:StopSound("om/2011x/ChargeAmbiane.wav")
    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", 1)

            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                ent:SetNW2Float("Ragebar_factor", ent:GetNW2Float("Ragebar_factor") + 0.00085)
            end
            if ent:GetNW2Float("2011x_rage_duration") > CurTime() or ent:GetNW2Float("2011x_rage_windup") > CurTime() then
                ent:GetPuppet():SetNW2Float("2011x_rage_duration_fire", CurTime()+0.2)
                if not ent:GetNW2Bool("2011x_rage_duration_toggle_music") then
                    ent:SetNW2Bool("2011x_rage_duration_toggle_music", true)
                    
                    ply:SetNW2String("TerrorRadius_om","")
                    ply:SetNW2String("chasemusic_life1_om","")
                    ply:SetNW2String("chasemusic_life2_om","")
                    
                end
            else
                if ent:GetNW2Bool("2011x_rage_duration_toggle_music") then
                    ent:SetNW2Bool("2011x_rage_duration_toggle_music", false)

                    ply:SetNW2String("TerrorRadius_om","OM/music/2011Xradius.wav")
                    ply:SetNW2String("chasemusic_life1_om","OM/music/2011Xchase.wav")
                    ply:SetNW2String("chasemusic_life2_om","OM/music/2011Xchaselast.wav")
                end
            end

            if ent:GetNW2Float("duration_invisible_2011x_OM") > CurTime() then
                ply:SetGravity(0.5)
                ply:SetNW2Float("om_nojumping", CurTime()+0.25)
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.05)
                ent:SetNW2Bool("Bool_Invisible_2011x_om", true)

                if not ent:GetNW2Bool("Bool_toggle_Invisible_2011x_om") then
                    
                    ply:SetNW2String("TerrorRadius_om","")
                    ply:SetNW2String("chasemusic_life1_om","")
                    ply:SetNW2String("chasemusic_life2_om","")
                    
                    ply:AddFlags(FL_NOTARGET)
                    ent:SetNW2Bool("Bool_toggle_Invisible_2011x_om", true)
                end
            else
                ply:SetGravity(1)
                ent:SetNW2Bool("Bool_Invisible_2011x_om", false)

                if ent:GetNW2Bool("Bool_toggle_Invisible_2011x_om") then

                    ent:SetNW2Float("cd_invisible_2011x_OM", CurTime() + 10)

                    ply:SetNW2String("TerrorRadius_om","OM/music/2011Xradius.wav")
                    ply:SetNW2String("chasemusic_life1_om","OM/music/2011Xchase.wav")
                    ply:SetNW2String("chasemusic_life2_om","OM/music/2011Xchaselast.wav")
                    
                    if bit.band(ply:GetFlags(), FL_NOTARGET) ~= 0 then
                        ply:RemoveFlags(FL_NOTARGET)
                    end

                    ent:SetNW2Bool("Bool_toggle_Invisible_2011x_om", false)
                    AdvancedPillSound(
                        {
                            stringe = "OM/2011x/2011X appears.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    local invisplay = false
                    for _, ent2 in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if ent2 == ply then continue end
                        if not GetConVar('PVPStun_OM_exe'):GetBool() then
                            if ent2:GetNW2Bool("OM_character_monster") then continue end
                        end
                        if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                            invisplay = true
                            break
                        end  
                    end
                    if invisplay then
                        local seq = ent:GetPuppet():LookupSequence("InvisibleInNear")
                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + ent:GetPuppet():SequenceDuration(seq))
                        ent:PillAnim("InvisibleInNear")
                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/2011x/2011xteleport1.wav",
                                    "OM/2011x/2011xteleport2.wav",
                                    "OM/2011x/2011xteleport3.wav",
                                    "OM/2011x/2011xteleport4.wav",
                                },
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end
                end
            end

            local function tick()
                AdvancedPillSound(
                    {
                        stringe = "OM/2011x/precharge.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                ent:GetPuppet():SetNW2Float('2011x_ability_outline',CurTime()+0.175)
                ent:GetPuppet():SetNW2Float('2011x_redflash_om',CurTime()+0.25)
            end

            if ent:GetNW2Float("ChargeAbilityDuration") > CurTime() then
                if not ent:GetNW2Bool("ShouldCharge_2011x0") then
                    ent:SetNW2Bool("ShouldCharge_2011x0", true)
                end
                if ent:GetNW2Float("chargeChargeUpTick") > CurTime() then
                else
                    ent:SetNW2Float("chargeChargeUpTick", CurTime()+1)  
                    tick()
                end
            else
                if ent:GetNW2Bool("ShouldCharge_2011x0") then
                    ent:SetNW2Bool("ShouldCharge_2011x0", false)
                    ent:SetNW2Float("ChargeDuration", CurTime()+ 5)
                    tick()
                end
            end

            if ent:GetNW2Float("ChargeDuration") > CurTime() then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)

                if not ent:GetNW2Bool("ChargeDuration_bool") then
                    ent:SetNW2Bool("ChargeDuration_bool", true)
                    AdvancedPillSound(
                        {
                            stringe = "om/2011x/ChargeAmbiane.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end

                ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.2)
                if ply:IsPlayer() then
                    ply:SetNW2Vector("OM_SetVelocity_Vector",ply:EyeAngles():Forward() * (800*2))
                else
                end

                local nearest
                local nearestDist = math.huge
                local searchPos = ent:LocalToWorld(Vector(0, 0, 50))

                for _, ent2 in pairs(ents.FindInSphere(searchPos, 90)) do
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if not GetConVar("PVPStun_OM_exe"):GetBool() then
                            if ent2:GetNW2Bool("OM_character_monster") then continue end
                        end

                        if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                        if not Mutal_OMCanDamage_grab(ply, ent, ent2) then continue end

                        local dist = searchPos:DistToSqr(ent2:GetPos())

                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = ent2
                        end
                    end
                end

                if IsValid(nearest) then

                    ent.damagegrab_cd = CurTime() + 0.5

                    KillerdamagestunDynamic({
                        ply = ply,
                        target = nearest,
                        DamageNumb = 2,
                        damagetype = DMG_CLUB,
                        CustomDamageSound = nil,
                        damagesound = true,
                        ShouldBlood = true,
                        flingremoveal = true,
                        ShouldBloodEffect = true
                    })
                    ent:SetNW2Float("ChargeDuration", 0)
                    ent:SetNW2Entity("ChargeGrabEntity", nearest)

                    OM_Minigame(ply, nearest, {
                        EndRoundLogic = function()
                            if nearest:GetNW2Bool("Survivor_Downed_OM") then
                                return {
                                    ['ply'] = 'Win',
                                    ['target'] = 'Loss'
                                }
                            end

                            if not IsValid(ent) then
                                return {
                                    ['ply'] = 'Win',
                                    ['target'] = 'Loss'
                                }
                            end

                            if ent:GetNW2Entity("ChargeGrabEntity") ~= nearest then
                                return {
                                    ['ply'] = 'Win',
                                    ['target'] = 'Loss'
                                }
                            end

                            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then
                                return {
                                    ['ply'] = 'Loss',
                                    ['target'] = 'Win'
                                }
                            end
                        end,

                        CanPlyplay = false,
                        TimeLimitBool = false,
                        CanPlyEndRound = false,
                        Cantargetmessup = false,
                        starthealth = 75,
                    })

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

                            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return true end

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

                            if not IsValid(headPhys) then
                                headPhys = createfakeragdoll:GetPhysicsObject()
                            end

                            if not IsValid(headPhys) then return end

                            if ply:GetNW2Bool("clashingminigame_om_isinminigame") then

                                local leftHandBone = puppet:LookupBone("LeftHand")
                                local rightHandBone = puppet:LookupBone("RightHand")

                                local leftPos = leftHandBone and select(1, puppet:GetBonePosition(leftHandBone))
                                local rightPos = rightHandBone and select(1, puppet:GetBonePosition(rightHandBone))

                                leftPos = leftPos or puppet:GetPos()
                                rightPos = rightPos or puppet:GetPos()

                                local medianPos = (leftPos + rightPos) * 0.5
                                medianPos = medianPos + Vector(0, 0, 10)

                                local headBone = puppet:LookupBone("Head")

                                local headPos
                                if headBone then
                                    headPos = select(1, puppet:GetBonePosition(headBone))
                                end

                                headPos = headPos or (puppet:GetPos() + Vector(0, 0, 60))

                                local ang = (headPos - medianPos):Angle()

                                headPhys:SetPos(medianPos)
                                headPhys:SetAngles(ang)
                                headPhys:SetVelocityInstantaneous(vector_origin)
                                headPhys:Wake()

                                nearest:SetNW2Float("ragdolltype_grab", CurTime() + 0.1)
                            end
                        end
                    })

                    AdvancedPillSound(
                        {
                            stringe = {
                                "OM/2011x/ChargeLine_1.wav",
                                "OM/2011x/ChargeLine_2.wav",
                                "OM/2011x/ChargeLine_3.wav",
                                "OM/2011x/ChargeLine_4.wav",
                                "OM/2011x/ChargeLine_5.wav"
                            },
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end

            else
                if ent:GetNW2Bool("ChargeDuration_bool") then
                    if !IsValid(ent:GetNW2Entity("ChargeGrabEntity")) then
                        ent:SetNW2Float("cd_charge_2011x_OM", CurTime()+ 24)
                    end
                    ent:StopSound("om/2011x/ChargeAmbiane.wav")
                    ent:SetNW2Bool("ChargeDuration_bool", false)
                end
            end

            if IsValid(ent:GetNW2Entity("ChargeGrabEntity")) then
                if not ent:GetNW2Bool("ChargeGrabEntity_bool") then
                    ent:SetNW2Bool("ChargeGrabEntity_bool", true)
                end
                local puppet = ent:GetPuppet()
                puppet:SetPoseParameter("aim_yaw", 0)
                puppet:SetPoseParameter("aim_pitch", 0)
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.5)

                local ent2 = ent:GetNW2Entity("ChargeGrabEntity")
                if not ent.damagegrab_cd then ent.damagegrab_cd = 0 end
                if ent.damagegrab_cd < CurTime() then
                    if ent:GetNW2Float("2011x_rage_duration") > CurTime() then
                        ent.damagegrab_cd = CurTime() + 0.25
                    else
                        ent.damagegrab_cd = CurTime() + 0.5
                    end

                    if ent2:Health() > 16 then
                        KillerdamagestunDynamic({
                            ply = ply,
                            target = ent2,
                            DamageNumb = 2,
                            damagetype = DMG_CLUB,
                            CustomDamageSound = nil,
                            damagesound = false,
                            ShouldBlood = true,
                            flingremoveal = false,
                            ShouldBloodEffect = false
                        })
                    else
                        KillerdamagestunDynamic({
                            ply = ply,
                            target = ent2,
                            DamageNumb = 1e9,
                            damagetype = DMG_CLUB,
                            CustomDamageSound = nil,
                            damagesound = true,
                            ShouldBlood = true,
                            flingremoveal = true,
                            ShouldBloodEffect = true
                        })
                    end
                    
                end
            else
                if ent:GetNW2Bool("ChargeGrabEntity_bool") then
                    ent:SetNW2Bool("ChargeGrabEntity_bool", false)
                    ent:SetNW2Float("cd_charge_2011x_OM", CurTime()+ 35)
                end
            end

            if ent:GetNWFloat("om_noodle_2011x_colorfate") > CurTime() then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
            end
            if ent:GetNW2Float("Eddy_2011x_godstrickeryduration") > CurTime() then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
            end
            if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack") > CurTime() then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                local puppet = ent:GetPuppet()
                puppet:SetPoseParameter("aim_yaw", 0)
                puppet:SetPoseParameter("aim_pitch", 0)
            end

            if ent:GetNW2Float("indicatorduration_invis_2011x") > CurTime() then
                if not ent:GetNW2Bool("indicatorduration_invis_2011x_bool") then
                    ent:SetNW2Bool("indicatorduration_invis_2011x_bool", true)
                end
            else
                if ent:GetNW2Bool("indicatorduration_invis_2011x_bool") then
                    ent:SetNW2Bool("indicatorduration_invis_2011x_bool", false)
                    ent:SetNW2Float("cd_invisible_2011x_OM", CurTime() + 10)
                end
            end
            if ent:GetNW2Float("indicatorduration_invis_2011x") > CurTime() then 
                ent:SetNW2Float("ScanForEntities_OM", CurTime() + 2)
            end
        end





        if CLIENT then--
            local hookName = "PostDrawTranslucentRenderables"
            local name = "2011x_ui_OM_noodles"..ent:EntIndex()

            local hooks = hook.GetTable()

            if hooks[hookName] and hooks[hookName][name] then
            else
                    
                local beamMat = {
                    [0] = Material("icons/Fleetway_laser"),
                    [1] = Material("icons/Fateful_drain_line"),
                    [2] = Material("icons/Fateful_drain_line_2"),
                    [3] = Material("icons/2011xragemodefire"),
                }

                hook.Add(hookName, name, function()
                    local ply = LocalPlayer()
                    if !IsValid(ply) then hook.Remove(hookName, name) return end
                    if !IsValid(ent) then hook.Remove(hookName, name) return end

                    if ent:GetNW2Float("2011x_rage_duration_fire") > CurTime() then

                        render.SetMaterial(beamMat[3])

                        local center = ent:GetPos()

                        local targetLength = 100
                        local targetWidth = 75

                        local curLength = ent:GetNW2Float("2011x_beam_length", 0)
                        local curWidth = ent:GetNW2Float("2011x_beam_width", 0)

                        local speed = 2

                        curLength = Lerp(FrameTime() * speed, curLength, targetLength)
                        curWidth  = Lerp(FrameTime() * speed, curWidth, targetWidth)

                        ent:SetNW2Float("2011x_beam_length", curLength)
                        ent:SetNW2Float("2011x_beam_width", curWidth)

                        local eyeAng = EyeAngles()
                        eyeAng.p = 0
                        eyeAng.r = 0

                        local camForward = eyeAng:Up()
                        local camRight = eyeAng:Right()

                        local forward = camForward * curLength
                        local right = camRight * (curWidth * 0.5)

                        local p1 = center - right
                        local p2 = center + forward - right
                        local p3 = center + forward + right
                        local p4 = center + right

                        local t = CurTime() * -2
                        local texScale = curLength / 100

                        mesh.Begin(MATERIAL_QUADS, 1)

                            mesh.Position(p1)
                            mesh.TexCoord(0, t, 0)
                            mesh.Color(255,255,255,255)
                            mesh.AdvanceVertex()

                            mesh.Position(p2)
                            mesh.TexCoord(0, t + texScale, 0)
                            mesh.Color(255,255,255,0)
                            mesh.AdvanceVertex()

                            mesh.Position(p3)
                            mesh.TexCoord(0, t + texScale, 1)
                            mesh.Color(255,255,255,0)
                            mesh.AdvanceVertex()

                            mesh.Position(p4)
                            mesh.TexCoord(0, t, 1)
                            mesh.Color(255,255,255,255)
                            mesh.AdvanceVertex()

                        mesh.End()

                    end
                end)
            end


            local hookName = "PreDrawTranslucentRenderables"
            local name = "2011x_invis_ability"..ent:EntIndex()

            local hooks = hook.GetTable()

            if hooks[hookName] and hooks[hookName][name] then
            else
                hook.Add(hookName, name, function()
                    local localPly = LocalPlayer()
                    if !IsValid(localPly) then hook.Remove(hookName, name) return end
                    if !IsValid(ent) then hook.Remove(hookName, name) return end

                    local puppet = ent:GetPuppet()
                    if not IsValid(puppet) then return end

                    local isInvisible = ent:GetNW2Bool("Bool_Invisible_2011x_om")
                    local isLocalThing = (ent:GetPillUser() == localPly)

                    local targetR, targetG, targetB, targetA

                    local snap = true
                    if isInvisible then
                        snap = false
                        if isLocalThing then
                            targetR, targetG, targetB, targetA = 65, 65, 65, 5
                        else
                            targetR, targetG, targetB, targetA = 0, 0, 0, 5
                        end
                    else
                        targetR, targetG, targetB, targetA = 255, 255, 255, 255
                    end

                    ent._2011xColor = ent._2011xColor or {
                        r = 255,
                        g = 255,
                        b = 255,
                        a = 255
                    }

                    local speed = 3
                    if snap then speed = 1e9 end

                    ent._2011xColor.r = Lerp(FrameTime() * speed, ent._2011xColor.r, targetR)
                    ent._2011xColor.g = Lerp(FrameTime() * speed, ent._2011xColor.g, targetG)
                    ent._2011xColor.b = Lerp(FrameTime() * speed, ent._2011xColor.b, targetB)
                    ent._2011xColor.a = Lerp(FrameTime() * speed, ent._2011xColor.a, targetA)

                    local col = Color(
                        ent._2011xColor.r,
                        ent._2011xColor.g,
                        ent._2011xColor.b,
                        ent._2011xColor.a
                    )

                    local rag = ent:GetNWEntity("OM_ragdollentity")
                    if IsValid(rag) then
                        if rag:GetNWEntity("fakemodel_om") then
                            puppet = rag:GetNWEntity("fakemodel_om")
                        else
                            puppet = rag
                        end
                    else
                    end
                    if !IsValid(puppet) then return end

                    if ent:GetNWFloat("om_noodle_2011x_colorfate") > CurTime() then
                        local colorfateclamp = math.Clamp( ( ent:GetNWFloat("om_noodle_2011x_colorfate")-0.5 - CurTime() ) / 1.5, 0, 1 )
                        local colorlerp = Lerp(colorfateclamp, 0, 255)
                        col = Color(colorlerp,colorlerp,colorlerp,colorlerp)
                    end

                    puppet:SetColor(col)
                    puppet:SetRenderMode(RENDERMODE_TRANSALPHA)
                end)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply, ent, button)
        if SERVER then
            if button == KEY_I then
                if ent:GetNW2Float("Ragebar_factor") >= 1 and not ent:GetNW2Bool("ActivatedRage") then
                    if ent:GetNW2Float("2011x_rage_windup", 0 ) > CurTime() then return end
                    if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                    ent:SetNW2Bool("ActivatedRage", true)
                    ent:SetNW2Float("2011x_rage_windup", CurTime() + 3)
                    AdvancedPillSound(
                        {
                            stringe = "OM/2011x/Rage.wav",
                            pitchPercent = 100,
                            volume = 2,
                            soundLevel = 87
                        },
                        ent
                    )
                    AdvancedPillSound(
                        {
                            stringe = "OM/2011x/rage mode activation.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+3)


                    net.Start("2011x_Ragemodemeter")
                        net.WriteEntity(ent)
                        net.WriteFloat(3+90)
                        net.WriteBool(true)
                    net.Broadcast()

                    timer.Simple(3,function()
                        if !IsValid(ent) then return end
                        ent:SetNW2Float("ScanForEntities_OM", CurTime() + 3)
                        ent:SetNW2Float("2011x_rage_duration", CurTime() + 90)
                    end)
                end
            end
            if button == KEY_E then

                if ent:GetNW2Float("cd_invisible_2011x_OM") > CurTime() then return end
                if ent:GetNW2Float("2011x_rage_duration", 0 ) > CurTime() then
                    if ent:GetNW2Bool("indicatorduration_invis_2011x_bool") then return end
                    if ent:GetNW2Float("indicatorduration_invis_2011x") > CurTime() then return end
                    if ent:GetNW2Float("ScanForEntities_OM") > CurTime() then return end
                    ent:SetNW2Float("indicatorduration_invis_2011x", CurTime() + 3)

                else
                    if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                    if ent:GetNW2Bool("ShouldCharge_2011x0") then return end
                    if ent:GetNW2Float("ChargeAbilityDuration") > CurTime() then return end
                    if ent:GetNW2Float("ChargeDuration") > CurTime() then return end
                    if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
                    if ent:GetNW2Bool("ChargeDuration_bool") then return end
                    if IsValid(ent:GetNW2Entity("ChargeGrabEntity")) then return end
                    
                    if ent:GetNW2Float("Eddy_2011x_godstrickeryduration", 0 ) > CurTime() then return end
                    if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack", 0 ) > CurTime() then return end

                    if ent:GetNW2Bool("Bool_Invisible_2011x_om") then
                        ent:SetNW2Float("duration_invisible_2011x_OM", 0)
                        ent:SetNW2Float("cd_invisible_2011x_OM", CurTime() + 10)
                    else
                        ent:SetNW2Float("duration_invisible_2011x_OM", CurTime() + 20)
                        ent:SetNW2Float("cd_invisible_2011x_OM", CurTime() + 5)
                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.75)
                        AdvancedPillSound(
                            {
                                stringe = "OM/2011x/invisibility activation.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end
                end
            end
            if button == KEY_R then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("ShouldCharge_2011x0") then return end
                if ent:GetNW2Float("ChargeAbilityDuration") > CurTime() then return end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
                if ent:GetNW2Bool("ChargeDuration_bool") then return end
                if IsValid(ent:GetNW2Entity("ChargeGrabEntity")) then return end

                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration", 0 ) > CurTime() then return end
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack", 0 ) > CurTime() then return end

                if ent:GetNW2Float("duration_invisible_2011x_OM") > CurTime() then return end
                if ent:GetNW2Bool("Bool_Invisible_2011x_om") then return end

                if ent:GetNW2Float("cd_charge_2011x_OM") > CurTime() then return end
                
                ent:SetNW2Float("ChargeAbilityDuration", CurTime()+ 2)

            end
            if button == KEY_T then
                if ent:GetNW2Float("2011x_rage_duration", 0 ) > CurTime() then return end 
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("ShouldCharge_2011x0") then return end
                if ent:GetNW2Float("ChargeAbilityDuration") > CurTime() then return end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
                if ent:GetNW2Bool("ChargeDuration_bool") then return end
                if IsValid(ent:GetNW2Entity("ChargeGrabEntity")) then return end
                
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration", 0 ) > CurTime() then return end
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack", 0 ) > CurTime() then return end

                if ent:GetNW2Float("duration_invisible_2011x_OM") > CurTime() then return end
                if ent:GetNW2Bool("Bool_Invisible_2011x_om") then return end

                if ent:GetNW2Float("cd_godstrickery_2011x_OM") > CurTime() then return end

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

                    ent:SetNWFloat("om_noodle_2011x_colorfate", CurTime()+2)
                    ent:SetNW2Float("Eddy_2011x_godstrickeryduration", CurTime()+6)

                    local function quickangle(ang)
                        ent:SetNW2Angle("pill_assignedangle", ang)
                        ply:SetAngles(ang)
                    end

                    timer.Simple(2,function()
                        if !IsValid(ent) then return end

                        ply:SetPos(finalPos)

                        ent:SetNW2Float("Eddy_2011x_godstrickeryduration_attack", CurTime()+2)

                        ent:GetPuppet():SetColor(Color(255,255,255,255))

                        local hookId = "LordX_MoveSequence_" .. ply:EntIndex()

                        local dir = chosenEnt:GetPos() - ply:GetPos()
                        local ang = dir:Angle()
                        ang.p = 0
                        ang.r = 0

                        local StartTime = CurTime()

                        local startpos1 = finalPos + ang:Forward()*-25
                        local EndPos1 = finalPos + ang:Forward()*-100
                        local attackpos 

                        local refresh = false
                        local currentpos

                        local mode

                        local random = math.random(1,3)
                        if random == 1 then
                            mode = 'Move'
                            ent:GetPuppet():SetNW2Float("2011x_trickery_red", CurTime()+2)
                        elseif random == 2 then
                            mode = 'OffGround'
                            ent:GetPuppet():SetNW2Float("2011x_trickery_black", CurTime()+2)
                        elseif random == 3 then
                            mode = 'Standstill'
                            if math.random(1,2) == 1 then
                                ent:GetPuppet():SetNW2Float("2011x_trickery_white", CurTime()+2)
                            else
                                ent:GetPuppet():SetNW2Float("2011x_trickery_blue", CurTime()+2)
                            end
                        end
                        local sayline = false
                        hook.Add("Think", hookId, function()
                            if !IsValid(ent) or !IsValid(ply) or !IsValid(chosenEnt) then
                                if !IsValid(chosenEnt) then
                                    ent:SetNW2Float("Eddy_2011x_godstrickeryduration_attack", 0)
                                    ent:GetPuppet():SetNW2Float("2011x_trickery_red", 0)
                                    ent:GetPuppet():SetNW2Float("2011x_trickery_black", 0)
                                    ent:GetPuppet():SetNW2Float("2011x_trickery_white", 0)
                                    ent:GetPuppet():SetNW2Float("2011x_trickery_blue", 0)
                                    ent:SetNW2Float("cd_godstrickery_2011x_OM", CurTime()+ 34)
                                end
                                hook.Remove("Think", hookId)
                                return
                            end
                            local dir = chosenEnt:GetPos() - ply:GetPos()
                            local ang = dir:Angle()
                            ang.p = 0
                            ang.r = 0
                            quickangle(ang)

                            if StartTime+1 >= CurTime() then

                                if not sayline then
                                    sayline = true
                                    AdvancedPillSound(
                                        {
                                            stringe = {
                                                "OM/2011x/GodsTrickery1.wav",
                                                "OM/2011x/GodsTrickery2.wav",
                                                "OM/2011x/GodsTrickery3.wav",
                                                "OM/2011x/GodsTrickery4.wav",
                                                "OM/2011x/GodsTrickery5.wav",
                                                "OM/2011x/GodsTrickery6.wav"
                                            },
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        ent
                                    )
                                    AdvancedPillSound(
                                        {
                                            stringe = "OM/2011x/god's trickery appear.wav",
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        ent
                                    )
                                end

                                local fraction = math.Clamp((CurTime() - StartTime) / 0.75, 0, 1)

                                fraction = 1 - (1 - fraction)^3
                                currentpos = LerpVector(fraction, startpos1, EndPos1)
                            elseif StartTime+2 >= CurTime() then
                                if not refresh then
                                    attackpos = FindSafePosNearEntity(chosenEnt, ply, 40)
                                    refresh = true


                                    AdvancedPillSound(
                                        {
                                            stringe = "OM/2011x/god's trickery hit.wav",
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        ent
                                    )

                                    timer.Simple(0.35,function()
                                        if !IsValid(ent) then return end
                                        if !IsValid(chosenEnt) then return end
                                        local hit = true
                                        if mode == "Move" then
                                            if chosenEnt:GetVelocity():Length() > 5 and chosenEnt:IsOnGround() then
                                                hit = false
                                            end
                                        elseif mode == "Standstill" then
                                            if chosenEnt:GetVelocity():Length2D() <= 0 then
                                                hit = false
                                            end
                                        elseif mode == "OffGround" then
                                            if chosenEnt:GetVelocity():Length2D() <= 0 and not chosenEnt:IsOnGround() then
                                                hit = false
                                            end
                                        end

                                        if hit then
                                            chosenEnt:SetNWFloat("om_daze", CurTime() + 5)

                                            KillerdamagestunDynamic({
                                                ply = ply,
                                                target = chosenEnt,
                                                DamageNumb = 25,
                                                damagetype = DMG_SLASH,
                                                CustomDamageSound = "OM/2011x/god's trickery land "..math.random(1,3)..".wav",
                                                damagesound = true,
                                                ShouldBlood = true,
                                                flingremoveal = true,
                                                ShouldBloodEffect = true
                                            })

                                        end
                                    end)

                                end
                                local fraction = math.Clamp((CurTime()-1 - StartTime) / 0.5, 0, 1)

                                fraction = 1 - (1 - fraction)^3
                                currentpos = LerpVector(fraction, EndPos1, attackpos)
                            else
                                hook.Remove("Think", hookId)
                                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 2)
                                ent:SetNW2Float("cd_godstrickery_2011x_OM", CurTime()+ 34)
                                return
                            end
                            ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.5)
                            ply:SetPos(currentpos)
                        end)
                    end)
                end
            end
        end
    end,

    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if SERVER then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Bool("ShouldCharge_2011x0") then return end
                if ent:GetNW2Float("ChargeAbilityDuration") > CurTime() then return end
                if ent:GetNW2Float("ChargeDuration") > CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
                if ent:GetNW2Bool("ChargeDuration_bool") then return end
                if IsValid(ent:GetNW2Entity("ChargeGrabEntity")) then return end
                
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration", 0 ) > CurTime() then return end
                if ent:GetNW2Float("Eddy_2011x_godstrickeryduration_attack", 0 ) > CurTime() then return end

                if ent:GetNW2Float("duration_invisible_2011x_OM") > CurTime() then return end
                if ent:GetNW2Bool("Bool_Invisible_2011x_om") then return end

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

                if ent:GetNW2Float("2011x_rage_duration", 0 ) > CurTime() then
                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 2.1)
                else
                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1.1)
                end 
                
                    
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
        if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then return end


    end
})

















