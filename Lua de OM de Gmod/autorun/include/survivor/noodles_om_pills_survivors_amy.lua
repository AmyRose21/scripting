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

-- Amy mouse handeler
if SERVER then
    util.AddNetworkString("Amy_recieve_mouse")
    util.AddNetworkString("Amy_retrieve_mouse")

    net.Receive("Amy_recieve_mouse", function()
        local ply = net.ReadEntity()
        local hitPos = net.ReadVector()

        local pillentity = ply.pk_pill_ent
        
        if IsValid(pillentity) then
            if pillentity.formTable.SendOverPoition then
                pillentity.formTable.SendOverPoition(ply, pillentity, hitPos)
            end
        end
    end)

    
    util.AddNetworkString("Amy_retrieve_mouse_hitentity")
    util.AddNetworkString("Amy_recieve_mouse_hitentity")

    net.Receive("Amy_recieve_mouse_hitentity", function(_, ply)
        local HitEntity = net.ReadEntity()
        local pillentity = ply.pk_pill_ent
        if IsValid(pillentity) then
            if pillentity.formTable.CollectHammer then
                pillentity.formTable.CollectHammer(ply, pillentity, HitEntity)
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
    net.Receive("Amy_retrieve_mouse", function()
        local ply = LocalPlayer()

        net.Start("Amy_recieve_mouse")
            net.WriteEntity(ply)
            net.WriteVector(GetTrueMouseHitPos(ply))
        net.SendToServer()
    end)

    local function GetTrueMouseHitEntity(ply)
        local startPos = ply:EyePos()

        local mx, my = gui.MousePos()
        local screenW, screenH = ScrW(), ScrH()
        local middlex, middley = screenW * 0.5, screenH * 0.5

        if mx == 0 and my == 0 then
            mx, my = middlex, middley
        end

        local dir = gui.ScreenToVector(mx, my)

        local tr = util.TraceLine({
            start = startPos,
            endpos = startPos + dir * 10000,
            filter = ply,
            mask = MASK_SOLID
        })

        return tr.Entity
    end
    net.Receive("Amy_retrieve_mouse_hitentity", function()
        local ply = LocalPlayer()

        net.Start("Amy_recieve_mouse_hitentity")
            net.WriteEntity(GetTrueMouseHitEntity(ply))
        net.SendToServer()
    end)
end


local AmyCards_test = {
    [0] = "Moon",
    [1] = "Sun",
    [2] = "Empeor",
    [3] = "Strength",
    [4] = "World",
    [5] = "Fool",
}

local preservedmats = {
    ["Amy_OM_Noodles_hammer"] = Material("icons/Amy_OM_Noodles_hammer.png"),
    ["Amy_OM_Noodles_throw"] = Material("icons/Amy_OM_Noodles_throw.png"),
    ["Amy_OM_Noodles_cardshuffle"] = Material("icons/Amy_OM_Noodles_cardshuffle.png")
}

local cards = {
    [0] = Material("icons/Card1.png"),
    [1] = Material("icons/Card2.png"),
    [2] = Material("icons/Card3.png"),
    [3] = Material("icons/Card4.png"),
    [4] = Material("icons/Card5.png"),
    [5] = Material("icons/Card6.png")
}

pk_pills.register('pill_om_amy', {

    printName='Amy',
    Outcomememories='Amy',
    Outcomememories_material="Organic",

    model="models/Noodles/OM/amy.mdl",
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
            jump2="jump",
            glide="fall",
            HammerBounce = "HammerBounce",
            HammerJump = "HammerJump",
        },

        ShouldMoveRotate={
            idle= function(ent) 
                if not ent:GetNW2Bool("HammerThrowShouldThrow") then return 'notanything' end
                if ent:GetNW2Bool("HammerThrowShouldThrow") then return "assignedagnles" end
            end,
            run= function(ent)
                if not ent:GetNW2Bool("HammerThrowShouldThrow") then return 'notshftlock' end
                if ent:GetNW2Bool("HammerThrowShouldThrow") then return "assignedagnles" end
            end,
            walk= function(ent) 
                if not ent:GetNW2Bool("HammerThrowShouldThrow") then return 'notshftlock' end
                if ent:GetNW2Bool("HammerThrowShouldThrow") then return "assignedagnles" end
            end,
            jump= function(ent) 
                if ent:GetNW2Bool("HammerThrowShouldThrow") then return "assignedagnles" end
                return 'notshftlock'
            end,
            HammerJump= function(ent) 
                if ent:GetNW2Bool("HammerThrowShouldThrow") then return "assignedagnles" end
                return 'notshftlock'
            end,
            fall= function(ent) 
                if ent:GetNW2Bool("HammerThrowShouldThrow") then return "assignedagnles" end
                return 'notshftlock'
            end,
            HammerBounce= function(ent) 
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            fall = function(ent)
                if ent:GetNW2Bool("landbounce") then return "HammerFall" end
                if not ent:GetNW2Bool('HasNoHammer') then return "FallAnimHammer" end
            end,
            idle= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("HammerDuration") > CurTime() then return 'idleattack' end
                if ent:GetNW2Bool("HammerThrowShouldThrow") then return 'idlethrow' end
                if ent:GetNW2Bool('HasNoHammer') then
                    return "idleaxeless"
                end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "idle_lowhealth"
                end 
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("HammerDuration") > CurTime() then return 'walkattack' end
                if ent:GetNW2Bool("HammerThrowShouldThrow") then return 'walkthrow' end
                if ent:GetNW2Bool('HasNoHammer') then
                    return "walk_axeless"
                end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "walk_lowhealth"
                end 
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("HammerDuration") > CurTime() then return 'runattack' end
                if ent:GetNW2Bool("HammerThrowShouldThrow") then return 'runthrow' end
                if ent:GetNW2Bool('HasNoHammer') then
                    return "run_axeless"
                end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "run_lowhealth"
                end 
            end,
        },
        animrates = {
            --[[
            run= function(ent)
                local ply = ent:GetPillUser()
                local amount = 1
                local runspeed = ent.formTable.Outcomememories_stats.moveSpeed.run(ply,ent) or 400
                amount = ent:GetPillUser():GetRunSpeed() / runspeed
                return amount
            end,
            ]]
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

        ent.sonic_fov_lerp = ent.sonic_fov_lerp or 0 

        if ply:GetInfoNum("om_pills_action_camera_Amy", 1) == 1 then
            if ent:GetNW2Bool("HammerThrowShouldThrow") or ent:GetNW2Bool("landbounce") or ent:GetNW2Float("HammerDuration") > CurTime() then
                ent.sonic_fov_lerp = Lerp(FrameTime()*2, ent.sonic_fov_lerp, 1)
            else
                ent.sonic_fov_lerp = Lerp(FrameTime()*2, ent.sonic_fov_lerp, 0)
            end
        else
            ent.sonic_fov_lerp = Lerp(FrameTime()*3, ent.sonic_fov_lerp, 0)
        end

        basetable["fov"] = basetable["fov"] + ent.sonic_fov_lerp * 20
        basetable["dist"] = basetable["dist"] - ent.sonic_fov_lerp * 30
        basetable["startoffset"] = basetable["startoffset"] + Vector(ent.sonic_fov_lerp * 30, 0,0)

        return basetable
    end,

    OM_UI_custom1 = function(ply, ent)
                        
        local screenW, screenH = ScrW(), ScrH()
        local iconsize = screenW / 13
        
        local yaxis_cards = screenH - iconsize * 2.7
        surface.SetDrawColor(255, 255, 255, 255)
                        
        local card1_material = cards[ent:GetNW2Float("CardSelection1", 0)]
        if card1_material and not card1_material:IsError() then
            surface.SetMaterial(card1_material)
            surface.DrawTexturedRect(iconsize * 2.1, yaxis_cards + iconsize * 0, iconsize * 0.8, iconsize * 1.4)
        end

        local card2_material = cards[ent:GetNW2Float("CardSelection2", 0) ]
        if card2_material and not card2_material:IsError() then
            surface.SetMaterial(card2_material)
            surface.DrawTexturedRect(iconsize * 3, yaxis_cards + iconsize * 0, iconsize * 0.8, iconsize * 1.4)
        end
    end,

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Amy_OM_Noodles_hammer"]
            end,
            name = function(uselessvar,ply,ent)
                return "Hammer"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Amy_Hammer_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("HammerCooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("HammerCooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.05, yaxis = 0, xsize = 0 - iconsize* 0.05, ysize = 0 - iconsize * 0.05}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Amy_OM_Noodles_throw"]
            end,
            name = function(uselessvar,ply,ent)
                return "Hammer Throw"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Amy_Throw_key", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("HammerThrowCooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("HammerThrowCooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.05, yaxis = 0+ iconsize*0.05, xsize = 0, ysize = 0}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility3_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Amy_OM_Noodles_cardshuffle"]
            end,
            name = function(uselessvar,ply,ent)
                return "Reroll"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Amy_Cards_key", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("CardCooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("CardCooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.025, yaxis = 0+ iconsize*0.025, xsize = 0, ysize = 0}
            end,
            survivor = true,
            font = "CreditsText",
        }
    },

    ShouldRoll_om = function(e, ply, ent)
        if ent:GetNW2Bool("landbounce") then return false end
        return true
    end,

    speedhandeler_om = {
        modifiers = {
            ['Function1'] = function(ply, ent)
                local cardsstatsbuff = {
                    [0] = function(ent)
                        return {
                            ['walk'] = ent:GetNW2Float("Amy_OM_mooncard_effect1") or 0,
                            ['run'] = ent:GetNW2Float("Amy_OM_mooncard_effect1") or 0,
                            ['ducked'] = ent:GetNW2Float("Amy_OM_mooncard_effect1") or 0,
                        }
                    end,
                    [1]  = {
                        ['mathtype'] = "add",
                        ['walk'] = 0,
                        ['run'] = GetConVar("OUTCOMEMORIES_N_Amy_1_speed"):GetFloat(),
                        ['ducked'] = 0,
                    },
                    [2]  = {
                        ['mathtype'] = "add",
                        ['walk'] = 60,
                        ['run'] = GetConVar("OUTCOMEMORIES_N_Amy_2_speed"):GetFloat(),
                        ['ducked'] = 60,
                    },
                    [3] = {
                        ['mathtype'] = "add",
                        ['walk'] = 0-90,
                        ['run'] = GetConVar("OUTCOMEMORIES_N_Amy_3_speed"):GetFloat(),
                    ['ducked'] = 0-90,
                    },
                    [4] = {
                        ['mathtype'] = "add",
                        ['walk'] = 0-60,
                        ['run'] = GetConVar("OUTCOMEMORIES_N_Amy_4_speed"):GetFloat(),
                        ['ducked'] = 0-60,
                    },
                    [5] = {
                        ['mathtype'] = "add",
                        ['walk'] = 40,
                        ['run'] = GetConVar("OUTCOMEMORIES_N_Amy_5_speed"):GetFloat(),
                        ['ducked'] = 40,
                    }
                }

                local add1, add2 = 0, 0

                if type(cardsstatsbuff[ ent:GetNW2Float("CardSelection1") ]) == "function" then
                    add1 = cardsstatsbuff[ ent:GetNW2Float("CardSelection1") ](ent)['run']
                else
                    add1 = cardsstatsbuff[ ent:GetNW2Float("CardSelection1") ]['run']
                end
                if type(cardsstatsbuff[ ent:GetNW2Float("CardSelection2") ]) == "function" then
                    add2 = cardsstatsbuff[ ent:GetNW2Float("CardSelection2") ](ent)['run']
                else
                    add2 = cardsstatsbuff[ ent:GetNW2Float("CardSelection2") ]['run']
                end

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = add1 + add2,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                return sendtotable
            end,
        }
    },

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_".."Amy".."_".. "walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_".."Amy".."_".. "run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_".."Amy".."_".. "walk"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_".."Amy".."_".. "jumppower"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Amy_jumpcd"):GetFloat()
                end
            end,
            rollingPower = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Amy_jumpcd"):GetFloat()
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Amy_rollingPower"):GetFloat()
                end
            end,
        },
        abilities = {
            ["Hammer"] = {
                ["ActivationKey"] = KEY_E,
                ["Cooldown"] = function() 
                    return GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_cd"):GetFloat()
                end,
                ["Duration"] = function() 
                    return GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_dur"):GetFloat()
                end,
                ["BounceEffect"] = function(ply, ent, ent2, BaseStunDuration)
                    local vel2 = Vector(0,0,0)

                    if ply:IsPlayer() then
                        ply:SetPos(ply:GetPos()+ply:GetUp()*5)
                        vel2 = ent:GetPuppet():GetForward() * 500
                        vel2.z = 700*0.3
                    else
                        ply:SetPos(ply:GetPos()+ply:GetUp()*40)
                        vel2 = ent:GetPuppet():GetForward() * 2000
                        vel2.z = 400
                    end
                    ent:PillAnim('HammerBounce')
                    ply:SetVelocity(vel2)
                    ply:SetLocalVelocity(vel2)
                    AdvancedPillSound(
                        {
                            stringe = "OM/Amy/HammerBounce.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end,
                ["StunEffect"] = function(ply, ent, ent2, BaseStunDuration)
                    Mutaul_OMStunCode(
                        {
                            ["ply"] = ply,
                            ["ent"] = ent,
                            ["target"] = ent2,
                            ["StunDur"] = BaseStunDuration,
                            ["stunfunction"] = function(shouldstundamage)
                                if shouldstundamage then
                                    ent2:SetNW2Float("Amy_highlight_pill_red", CurTime()+0.5*0.35)
                                    local ed = EffectData()
                                    ed:SetOrigin(ent2:GetPos() + Vector(0,0,40))
                                    util.Effect("Amy_hammerhit_new", ed)

                                    ent2:SetVelocity( ply:GetVelocity():GetNormalized()*750 )
                                            
                                    if ent:GetNW2Bool("landbounce") then
                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/Amy/WeirdCrowbarHit.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        )
                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/Amy/HammerBounce.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        )

                                        if SERVER then
                                            if GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_ragdollstun"):GetBool() then
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
                                                        local entPos = ent2:GetPos()

                                                        local dir = (ragPos - entPos):GetNormalized()

                                                        local force = dir * 300 + Vector(0, 0, -350)

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

                                    else
                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/Amy/HammerHit.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        )
                                    end
                                end
                            end,
                            ["shouldstack"] = false,
                            ["Damage"] = BaseStunDuration*1.25/GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_Stun_dur"):GetFloat() * GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_Stun_damage"):GetFloat(),
                            ["DamageType"] = DMG_CLUB
                        }
                    )
                end,
            },
            ["Throw"] = {
                ["ActivationKey"] = KEY_T,
                ["Cooldown"] = function() 
                    return GetConVar("OUTCOMEMEMORIES_N_Amy_Throw_cd"):GetFloat()
                end,
                ["CooldownCancel"] = function() 
                    return GetConVar("OUTCOMEMORIES_N_Amy_Throw_cd_cancel"):GetFloat()
                end,
                ["StunEffect"] = function(ply, ent, ent2, BaseStunDuration, hammer)
                    Mutaul_OMStunCode(
                        {
                            ["ply"] = ply,
                            ["ent"] = ent,
                            ["target"] = ent2,
                            ["StunDur"] = BaseStunDuration,
                            ["stunfunction"] = function(shouldstundamage)
                                if shouldstundamage then
                                    local ed = EffectData()
                                    ed:SetOrigin(ent2:GetPos() + Vector(0,0,40))
                                    util.Effect("Amy_hammerhit_new", ed)

                                    AdvancedPillSound(
                                        {
                                            stringe = "OM/Amy/HammerThrowHit.wav",
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        ent
                                    )

                                    local last = CurTime() + 1.25
                                    local flung = false

                                    if SERVER then
                                        if GetConVar("OUTCOMEMEMORIES_N_Amy_Throw_ragdollstun"):GetBool() then
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
                                                    local entPos = hammer:GetPos()

                                                    local dir = (ragPos - entPos):GetNormalized()

                                                    local force = dir * 500 + Vector(0, 0, 350)

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
                            ["shouldstack"] = false,
                            ["Damage"] = BaseStunDuration*1.25/GetConVar("OUTCOMEMORIES_N_Amy_Throw_Stun_dur"):GetFloat() * GetConVar("OUTCOMEMORIES_N_Amy_Throw_Stun_damage"):GetFloat(),
                            ["DamageType"] = DMG_CRUSH
                        }
                    )
                end
            },
            ["CardSwap"] = {
                ["ActivationKey"] = KEY_R,
                ["Cooldown"] = function() 
                    return GetConVar("OUTCOMEMORIES_N_Amy_CardSwap_cd"):GetFloat()
                end,
                ["RetrieveDamageReduction"] = function(ply,ent)
                    local cardsdamagebuff = {
                        [0] = function(ent)
                            return ent:GetNW2Float("Amy_OM_mooncard_effect2")
                        end,
                        [1] = GetConVar("OUTCOMEMORIES_N_Amy_1_damage_reduction"):GetFloat(),
                        [2] = GetConVar("OUTCOMEMORIES_N_Amy_2_damage_reduction"):GetFloat(),
                        [3] = GetConVar("OUTCOMEMORIES_N_Amy_3_damage_reduction"):GetFloat(),
                        [4] = GetConVar("OUTCOMEMORIES_N_Amy_4_damage_reduction"):GetFloat(),
                        [5] = GetConVar("OUTCOMEMORIES_N_Amy_5_damage_reduction"):GetFloat()
                    }
                    
                    
                    local DamageMultiplyer1, DamageMultiplyer2 = 1, 1
                    if type(cardsdamagebuff[ ent:GetNW2Float("CardSelection1",0) ]) == "function" then
                        DamageMultiplyer1 = cardsdamagebuff[ ent:GetNW2Float("CardSelection1") ](ent)
                    else
                        DamageMultiplyer1 = cardsdamagebuff[ ent:GetNW2Float("CardSelection1") ]
                    end
                    if type(cardsdamagebuff[ ent:GetNW2Float("CardSelection2",0) ]) == "function" then
                        DamageMultiplyer2 =  cardsdamagebuff[ ent:GetNW2Float("CardSelection2") ](ent)
                    else
                        DamageMultiplyer2 =  cardsdamagebuff[ ent:GetNW2Float("CardSelection2") ]
                    end
                    ply:SetNW2Float("OM_Damage_Reduction",DamageMultiplyer1*DamageMultiplyer2)
                end,
                ["RetrieveCurrentAttack"] = function(ply, ent, throwing)
                    local cardsstunbuff = {
                        [0] = GetConVar("OUTCOMEMORIES_N_Amy_0_stunduration"):GetFloat(),
                        [1] = GetConVar("OUTCOMEMORIES_N_Amy_1_stunduration"):GetFloat(),
                        [2] = GetConVar("OUTCOMEMORIES_N_Amy_2_stunduration"):GetFloat(),
                        [3] = GetConVar("OUTCOMEMORIES_N_Amy_3_stunduration"):GetFloat(),
                        [4] = GetConVar("OUTCOMEMORIES_N_Amy_4_stunduration"):GetFloat(),
                        [5] = GetConVar("OUTCOMEMORIES_N_Amy_5_stunduration"):GetFloat()
                    }

                    local BaseStunDuration = GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_Stun_dur"):GetFloat()
                    if throwing then
                        BaseStunDuration = GetConVar("OUTCOMEMORIES_N_Amy_Throw_Stun_dur"):GetFloat()
                    end
                    local stunDur1, stunDur2 = 0, 0

                    if type(cardsstunbuff[ ent:GetNW2Float("CardSelection1") ]) == "function" then
                        stunDur1 = cardsstunbuff[ ent:GetNW2Float("CardSelection1") ](ent)
                    else
                        stunDur1 = cardsstunbuff[ ent:GetNW2Float("CardSelection1") ]
                    end
                    if type(cardsstunbuff[ ent:GetNW2Float("CardSelection2") ]) == "function" then
                        stunDur2 = cardsstunbuff[ ent:GetNW2Float("CardSelection2") ](ent)
                    else
                        stunDur2 = cardsstunbuff[ ent:GetNW2Float("CardSelection2") ]
                    end
                    return BaseStunDuration + stunDur1 + stunDur2
                end,
                ["RetrieveHealingCard"] = function(ply, ent)
                    if not GetConVar("OUTCOMEMORIES_N_Amy_1_healing"):GetBool() then return end
                    if ent:GetNW2Float("CardSelection1",0) == 1 or ent:GetNW2Float("CardSelection2",0) == 1 then
                        if ent:GetNW2Float("Card_cream") > CurTime() then
                        else
                            ent:SetNW2Float("Card_cream",CurTime()+GetConVar("OUTCOMEMORIES_N_Amy_1_healspeed"):GetFloat())
                            for _, ent3 in ipairs(ents.FindInSphere(ply:GetPos(), 200)) do
                                if IsValid(ent3:GetNW2Entity("DrGBasePossessing")) then continue end
                                if ent3:GetClass() == "pill_puppet" then continue end
                                if ent3:GetNW2Bool("OM_cantHeal") then continue end
                                if not ent3:GetNW2Bool("OM_character") then continue end

                                if bit.band(ent3:GetFlags(), FL_NOTARGET) ~= 0 then continue end

                                if GetConVar('PVPStun_OM'):GetBool() then
                                    if ent3 ~= ply then continue end
                                end

                                if ent3:GetNW2Bool("NoHealing_OM_Noodles") then continue end
                                if IsValid(ent3) then
                                    if ent3 ~= ply then
                                        ent3:SetNW2Float("SunCardBlindingEffect", CurTime()+2)
                                    end
                                    if (ent3:IsPlayer() and ent3:Alive()) or ent3:IsNPC() or ent3:IsNextBot() then
                                        if ent3:Health() >= GetConVar("OUTCOMEMORIES_N_Amy_1_healLimit"):GetFloat() then continue end
                                        local newHP = math.min(ent3:Health() + GetConVar("OUTCOMEMORIES_N_Amy_1_healAmount"):GetFloat(), GetConVar("OUTCOMEMORIES_N_Amy_1_healLimit"):GetFloat())
                                        ent3:SetHealth(newHP)
                                    end
                                end
                            end
                        end
                    end
                end
            },
        },
    },
        
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if event == "Step" then
            StepSFX_OM(ply,ent)
        end
    end,

    CardSwitch_om = function(ply, ent)
        if SERVER then
            local numb_mooncard_1, numb_mooncard_2
            if math.random(1,2) == 1 then
                numb_mooncard_1 = GetConVar("OUTCOMEMORIES_N_Amy_0_1_speed"):GetFloat()
                numb_mooncard_2 = GetConVar("OUTCOMEMORIES_N_Amy_0_1_damage_reduction"):GetFloat()
            else
                numb_mooncard_1 = GetConVar("OUTCOMEMORIES_N_Amy_0_2_speed"):GetFloat()
                numb_mooncard_2 = GetConVar("OUTCOMEMORIES_N_Amy_0_2_damage_reduction"):GetFloat()
            end
            ent:SetNW2Float("Amy_OM_mooncard_effect1",numb_mooncard_1)
            ent:SetNW2Float("Amy_OM_mooncard_effect2",numb_mooncard_2)

            local oldnumber1, oldnumber2 = ent:GetNW2Float("CardSelection1"), ent:GetNW2Float("CardSelection2")

            local card1 = math.random(0, 5)
            local card2 = math.random(0, 5)

            while card2 == card1 do
                card2 = math.random(0, 5)
            end

            ent:SetNW2Float("CardSelection1",card1)
            ent:SetNW2Float("CardSelection2",card2)
            
            ent:SetNW2Float("CardUsageDelay", CurTime()+ 4)
            if ply:IsPlayer() then
                if SERVER then
                    net.Start("Amy_OM_choosecards")
                    net.WriteEntity(ent)
                    net.WriteInt(card1, 32)
                    net.WriteInt(card2, 16)
                    net.WriteInt(numb_mooncard_1, 33)
                    net.WriteInt(numb_mooncard_2, 31)
                    net.Send(ply)
                end
            else
                if ply:IsNextBot() then
                    if ply:IsPossessed() then
                        if SERVER then
                            net.Start("Amy_OM_choosecards")
                            net.WriteEntity(ent)
                            net.WriteInt(card1, 32)
                            net.WriteInt(card2, 16)
                            net.WriteInt(numb_mooncard_1, 33)
                            net.WriteInt(numb_mooncard_2, 31)
                            net.Send(ply:GetPossessor())
                        end
                    end
                end
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
        if SERVER then
            initializetable2["entity"]:SetNW2Float('OM_friction', 1)
            initializetable2["entity"]:SetNW2Float("OM_Damage_Reduction",1)

            local health = GetConVar("OUTCOMEMEMORIES_N_Amy_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)

            initializetable2["entity"].formTable.CardSwitch_om(initializetable2["player"], initializetable2["entity"])
            initializetable2["entity"]:SetNW2Bool("CardsEffectInitiate", true)
            initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
            initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)

            initializetable2["player"].CustomFunctionForDowned_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]
                    ent:SetNW2Float("HammerDuration", 0)
                    ent:SetNW2Bool("HammerThrowShouldThrow", false)
                    ent:SetNW2Bool("landbounce", false)
                end
            end
            initializetable2["player"].OM_Stun_Blockfunction = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]
                    ent:SetNW2Float("HammerDuration", 0)
                    ent:SetNW2Bool("HammerThrowShouldThrow", false)
                    ent:SetNW2Bool("landbounce", false)
                end
            end
        end

        initializetable2["entity"]:SetNW2Float("CardCooldown",CurTime())
        initializetable2["player"]:SetNW2Bool("OM_character", true)
    end,
    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"].GotTheStun = false
        end
    end,

    SendOverPoition = function(ply, ent, hitpos)
        local ply = ent:GetPillUser()
        local startPos = ent:GetPuppet():GetPos()

        local ang = (hitpos - startPos):Angle()
        ang.p = 0
        ang.r = 0
        ent:SetNW2Angle("pill_assignedangle",ang)
        ent:SetNW2Vector("pill_targetpos_amy",hitpos)
    end,

    think_noodles_om_pill = function(ply, ent)
        if not SERVER then return end
        
        OM_PILL_speedThink(ply, ent)

        if not GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_useable"):GetBool() then
            ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
        else
            ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
        end
        if not GetConVar("OUTCOMEMEMORIES_N_Amy_Throw_useable"):GetBool() then
            ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
        else
            ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
        end
        if not GetConVar("OUTCOMEMORIES_N_Amy_CardSwap_useable"):GetBool() then
            ent:SetNW2Bool("ShouldntShowAbility3_OM", true)
        else
            ent:SetNW2Bool("ShouldntShowAbility3_OM", false)
        end
        ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_Amy_Resistance"):GetFloat()/100)

        if ent:GetNW2Bool("HammerThrowShouldThrow") then
            if ply:IsPlayer() then
                if SERVER then
                    net.Start("Amy_retrieve_mouse")
                    net.Send(ply)
                end
            end
        end

        local hasthestun = false

        if IsValid(ent) and SERVER then 
            ent.formTable.Outcomememories_stats.abilities.CardSwap.RetrieveDamageReduction(ply, ent)
            ent.formTable.Outcomememories_stats.abilities.CardSwap.RetrieveHealingCard(ply, ent)

            if ent:GetNW2Float("HammerDuration") > CurTime() or ent:GetNW2Bool("landbounce") or ent:GetNW2Float("landbounce_Stunlinger") > CurTime() then
                hasthestun = true

                if ent:GetNW2Bool("landbounce") or ent:GetNW2Float("landbounce_Stunlinger") > CurTime() then
                    ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                    ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                end

                local jumpscare_entity = nil

                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 130)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        local shouldstunstack = GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_stunstack"):GetBool()
                        if Mutual_OMCanStun(ply, ent, ent2, shouldstunstack) then
                            ent.formTable.Outcomememories_stats.abilities.Hammer.StunEffect(ply, ent, ent2, ent.formTable.Outcomememories_stats.abilities.CardSwap.RetrieveCurrentAttack(ply, ent))
                            if not jumpscare_entity then
                                jumpscare_entity = ent2
                                ent:GetPuppet():SetLayerPlaybackRate(ent:GetPuppet():AddGestureSequence(ent:GetPuppet():LookupSequence("swing")), ent:GetPuppet():SequenceDuration(ent:GetPuppet():LookupSequence("swing"))/1)

                                local vel = ply:GetVelocity()
                                ent:SetNW2Float("HammerDuration",0)
                                ent:SetNW2Bool('HammerDebounce',false)
                                ent:GetPuppet():SetNW2Float("Amy_highlight_pill", CurTime()+0.5*0.35)
                                ent:GetPuppet():SetNW2Float("amy_ability_outline", CurTime()+0.5*0.35)
                                ent:SetNW2Float("HammerCooldown",CurTime()+ent.formTable.Outcomememories_stats.abilities.Hammer.Cooldown())
                                ent:SetNW2Float("HammerCooldown_duration",ent.formTable.Outcomememories_stats.abilities.Hammer.Cooldown())
                                if not ply:OnGround() and ent:GetNW2Bool("landbounce") then
                                    ent:SetNW2Bool("landbounce", false)
                                    ent.formTable.Outcomememories_stats.abilities.Hammer.BounceEffect(ply, ent)
                                end
                                ent:SetNW2Float("landbounce_Stunlinger", 0)
                            end
                        else
                            if ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then
                            else
                                if not jumpscare_entity then
                                    jumpscare_entity = ent2
                                    
                                    local vel = ply:GetVelocity()
                                    if not ply:OnGround() and ent:GetNW2Bool("landbounce") and ent:GetNW2Float("landbounce_Stunlinger") < CurTime() then
                                    else
                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/Amy/HammerMiss.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        )
                                        ent:SetNW2Float("landbounce_Stunlinger", 0)
                                        ent:GetPuppet():SetNW2Float("Amy_highlight_pill_blue", CurTime()+0.5*0.35)
                                        ent:GetPuppet():SetNW2Float("amy_ability_outline", CurTime()+0.5*0.35)

                                        ent:SetNW2Float("HammerCooldown",CurTime()+ent.formTable.Outcomememories_stats.abilities.Hammer.Cooldown())
                                        ent:SetNW2Float("HammerCooldown_duration",ent.formTable.Outcomememories_stats.abilities.Hammer.Cooldown())
                                        ent:SetNW2Float("HammerDuration",0)
                                        ent:SetNW2Bool('HammerDebounce',false)
                                        ent:GetPuppet():SetLayerPlaybackRate(ent:GetPuppet():AddGestureSequence(ent:GetPuppet():LookupSequence("swing")), ent:GetPuppet():SequenceDuration(ent:GetPuppet():LookupSequence("swing"))/1)
                                    end
                                end
                            end
                        end
                    end
                end

                if ply:OnGround() and ent:GetNW2Bool("landbounce") and ent:GetNW2Float("landbounce_Stunlinger") < CurTime() then
                    ent:PillAnim('HammerBounce')
                    ent:SetNW2Bool("landbounce", false)
                    ent:SetNW2Float("HammerDuration",0)

                    ent.formTable.Outcomememories_stats.abilities.Hammer.BounceEffect(ply, ent)
                    ent:SetNW2Float("landbounce_Stunlinger", CurTime()+ 0.15)
                end
            end
        end

        if ent:GetNW2Float("HammerDuration") > CurTime() or ent:GetNW2Bool("landbounce") then
            hasthestun = true
            if not ent:GetNW2Bool('HammerDebounce') then
                ent:SetNW2Bool('HammerDebounce',true)
            end
        else
            if ent:GetNW2Bool('HammerDebounce') then
                ent:SetNW2Bool("landbounce", false)
                ent:SetNW2Bool('HammerDebounce',false)
                ent:GetPuppet():SetNW2Float("Amy_highlight_pill", CurTime()+0.5*0.35)
                ent:SetNW2Float("HammerCooldown",CurTime()+ent.formTable.Outcomememories_stats.abilities.Hammer.Cooldown())
                ent:SetNW2Float("HammerCooldown_duration",ent.formTable.Outcomememories_stats.abilities.Hammer.Cooldown())
            end
        end
        
        if ent:GetNW2Bool("HammerThrowShouldThrow") then
            hasthestun = true
        end

        if hasthestun then
            ply.GotTheStun = true
        else
            ply.GotTheStun = false
        end
        
    end,


    CollectHammer = function(ply, ent, HitEntity)
        if !IsValid(HitEntity) then return end
        if HitEntity.amy_om_hammer then
            if HitEntity.amy_om_hammerUse then
                HitEntity:amy_om_hammerUse(ply)
            end
        end
    end,

    noodles_OM_survivor_naturalkeys = function(ply,ent,key)
        if not SERVER then return end
        if key == IN_USE then
            if ply:IsPlayer() then
                net.Start("Amy_retrieve_mouse_hitentity")
                net.Send(ply)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if not SERVER then return end

        if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() or IsValid(ply:GetNWEntity("OM_ragdollentity")) then
            return
        end

        if button == ply:GetInfoNum("om_pills_action_Amy_Hammer_key", KEY_E) then
            if not GetConVar("OUTCOMEMEMORIES_N_".."Amy".."_".. "Hammer_useable"):GetBool() then return end
            if ent:GetNW2Bool('HasNoHammer') then return end
            if ent:GetNW2Bool("HammerThrowShouldThrow") then return end
            if ent:GetNW2Float("HammerDuration") > CurTime() then return end
            if ent:GetNW2Float("HammerDurationjustincaase") > CurTime() then return end
            if ent:GetNW2Float("HammerCooldown") > CurTime() then return end
            if ent:GetNW2Float("HammerEndLag") > CurTime() then return end

            local hammerdur = ent.formTable.Outcomememories_stats.abilities.Hammer.Duration()
            ent:SetNW2Float("HammerDuration",CurTime()+hammerdur)
            ent:SetNW2Float("HammerDurationjustincaase",CurTime()+hammerdur+0.5)
            ent:SetNW2Bool("HammerThrowShouldThrow", false)
            if not ply:IsOnGround() then
                ent:SetNW2Bool("landbounce", true)
            end

            AdvancedPillSound(
                {
                    stringe = "OM/Amy/HammerReady.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )
            ent:GetPuppet():SetNW2Float("Amy_highlight_pill", CurTime()+0.5*0.35)
        end
        if button == ply:GetInfoNum("om_pills_action_Amy_Cards_key", KEY_R) then
            if not GetConVar("OUTCOMEMORIES_N_Amy_CardSwap_useable"):GetBool() then return end
            if ent:GetNW2Float("CardCooldown",0) > CurTime() then return end
            if ent:GetNW2Float("CardUsageDelay",0) > CurTime() then return end
            ent:SetNW2Float("CardCooldown",CurTime()+ent.formTable.Outcomememories_stats.abilities.CardSwap.Cooldown())
            ent:SetNW2Float("CardCooldown_duration",ent.formTable.Outcomememories_stats.abilities.CardSwap.Cooldown())
            if SERVER then
                ent.formTable.CardSwitch_om(ply, ent)
            end
        end
        if button == ply:GetInfoNum("om_pills_action_Amy_Throw_key", KEY_T) then
            if not GetConVar("OUTCOMEMEMORIES_N_".."Amy".."_".. "Throw_useable"):GetBool() then return end
            if ent:GetNW2Bool('HasNoHammer') then return end
            
            if ent:GetNW2Float("HammerThrowCooldown") > CurTime() then return end
            if ent:GetNW2Bool("HammerThrowShouldThrow") then
                ent:SetNW2Bool("HammerThrowShouldThrow", false)
                ent:SetNW2Float("HammerThrowCooldown", CurTime()+ent.formTable.Outcomememories_stats.abilities.Throw.CooldownCancel())
                ent:SetNW2Float("HammerThrowCooldown_duration", ent.formTable.Outcomememories_stats.abilities.Throw.CooldownCancel())
                
                AdvancedPillSound(
                    {
                        stringe = "OM/Amy/HammerThrowCancel.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent:GetPuppet():SetNW2Float("Amy_highlight_pill_blue", CurTime()+0.5*0.35)
                ent:GetPuppet():SetNW2Float("amy_ability_outline", CurTime()+0.5*0.35)
                return
            end
            if ent:GetNW2Float("HammerDuration") > CurTime() then return end

            AdvancedPillSound(
                {
                    stringe = "OM/Amy/HammerThrowReady.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )
            ent:SetNW2Bool("HammerThrowShouldThrow", true)

            ent:SetNW2Float("HammerThrowCooldown", CurTime()+0.3)
            ent:SetNW2Float("HammerThrowCooldown_duration", 0.3)
            ent:GetPuppet():SetNW2Float("Amy_highlight_pill", CurTime()+0.5*0.35)
        end
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if ent:GetNW2Bool("HammerThrowShouldThrow") then
                if ent:GetNW2Bool("HammerThrowShouldThrow2") then return end
                if ent:GetNW2Float("HammerThrowCooldown") > CurTime() then return end
                ent:SetNW2Bool("HammerThrowShouldThrow2", true)
                ent:GetPuppet():SetLayerPlaybackRate(ent:GetPuppet():AddGestureSequence(ent:GetPuppet():LookupSequence("throw")), ent:GetPuppet():SequenceDuration(ent:GetPuppet():LookupSequence("throw"))/1)
                
                ent:SetNW2Float("HammerThrowCooldown", CurTime() + ent.formTable.Outcomememories_stats.abilities.Throw.Cooldown())
                ent:SetNW2Float("HammerThrowCooldown_duration", ent.formTable.Outcomememories_stats.abilities.Throw.Cooldown())

                AdvancedPillSound(
                    {
                        stringe = "OM/Amy/HammerThrow.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                timer.Simple(0.15,function()
                    if !IsValid(ent) then return end
                    ent:SetNW2Bool("HammerThrowShouldThrow", false)
                    ent:SetNW2Bool("HammerThrowShouldThrow2", false)
                    local power = 10000*0.3
                    local tr = ply:GetEyeTrace()
                    
                    local startPos = ent:GetPuppet():GetPos()
                    local endPos = startPos + ply:GetAimVector() * 20000
                    if ply:IsPlayer() then
                        endPos = ent:GetNW2Vector("pill_targetpos_amy")
                    end
                    local hammertrace = (endPos-startPos):Angle()
                    local direction = (endPos - startPos):GetNormalized()

                    local prop = ents.Create("prop_physics")
                    prop:SetModel("models/Noodles/OM/Amy/hammer.mdl") 

                    --directiondirection
                    local startpos = ent:GetPuppet():GetPos()+ent:GetPuppet():GetUp()*30
                    local tr = util.TraceLine({
                        start = startPos,
                        endpos = startPos + direction * 50,
                        filter = ply,
                        mask = MASK_ALL
                    })
                    if tr.Hit then
                        prop:SetPos(tr.HitPos+direction*5)
                    else
                        prop:SetPos(startpos+ direction*50)
                    end

                    prop:SetNWEntity("NoCollideEntity_om", ply)

                    prop:SetAngles( (tr.HitPos - ent:GetPuppet():GetPos()):Angle() + Angle(0,90,0))
                    prop:Spawn()
                    prop.amy_om_hammer = true

                    local trailFoot1 = util.SpriteTrail(
                        prop,
                        0,
                        Color(255, 255, 255),
                        true,
                        25,
                        2,
                        0.3,
                        0.2,
                        "models/noodles/om/amy/white.vmt"
                    )
                    prop:DeleteOnRemove(trailFoot1)

                    startPos = prop:GetPos()
                    if ply:IsPlayer() then
                    else
                        endPos = startPos + ply:GetAimVector() * 20000
                    end
                    direction = (endPos - startPos):GetNormalized()
                    local velocity = direction * power + Vector(0, 0, 150)

                    local spawntime = CurTime()+ 1

                    prop.amy_om_hammerUse = function(ply1, ply2)
                        if ply2:GetPos():Distance(prop:GetPos()) > 140 then return end
                        if ply2 == ply then
                            if spawntime > CurTime() then return end
                            prop:Remove()
                            ent:SetNW2Bool("HasNoHammer", false)
                            ent:GetPuppet():SetBodygroup(1,0)
                            ent:SetNW2Float("HammerEndLag", CurTime()+0.85)
                            AdvancedPillSound(
                                {
                                    stringe = "OM/Amy/HammerRetract.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                            ent:GetPuppet():SetNW2Float("Amy_highlight_pill_green", CurTime()+0.5*0.35)
                            ent:GetPuppet():SetNW2Float("amy_ability_outline", CurTime()+0.5*0.35)
                        end
                    end

                    hook.Add("PlayerUse", "CustomPropUse_"..prop:EntIndex(), function(ply2, entUsed)
                        if entUsed == prop and ply2 == ply then
                            if spawntime > CurTime() then return end
                            prop:Remove()
                            ent:SetNW2Bool("HasNoHammer", false)
                            ent:GetPuppet():SetBodygroup(1,0)
                            ent:SetNW2Float("HammerEndLag", CurTime()+0.85)
                            AdvancedPillSound(
                                {
                                    stringe = "OM/Amy/HammerRetract.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )

                            ent:GetPuppet():SetNW2Float("Amy_highlight_pill_green", CurTime()+0.5*0.35)
                            ent:GetPuppet():SetNW2Float("amy_ability_outline", CurTime()+0.5*0.35)
                        end
                    end)

                    prop.StartTouch = function(hitEnt)
                        if SERVER then
                            if !IsValid(hitEnt) or hitEnt == ply then return end

                            if hitEnt:GetNW2Bool("OM_character") and GetConVar('PVPStun_OM'):GetBool() then
                                if hitEnt.CustomFunctionCancelAbility_OM then
                                    hitEnt:CustomFunctionCancelAbility_OM()
                                end
                            else
                            end
                            timer.Simple(0.05,function()
                                if !IsValid(ply) then return end
                                if !IsValid(ent) then return end
                                if !IsValid(hitEnt) then return end
                                
                                local shouldstunstack = GetConVar("OUTCOMEMEMORIES_N_Amy_Throw_stunstack"):GetBool()
                                if Mutual_OMCanStun(ply, ent, hitEnt, shouldstunstack) then
                                    if hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:IsNextBot() then
                                        ent.formTable.Outcomememories_stats.abilities.Throw.StunEffect(ply, ent, hitEnt, ent.formTable.Outcomememories_stats.abilities.CardSwap.RetrieveCurrentAttack(ply, ent), prop)
                                    end
                                end

                                if not (hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:IsNextBot()) then
                                    local phys = prop:GetPhysicsObject()
                                    if IsValid(phys) then
                                        local vel = phys:GetVelocity()
                                        local speed = vel:Length()

                                        if speed > 1 then
                                            local drag = 0.96
                                            local newVel = vel * drag

                                            phys:SetVelocityInstantaneous(newVel)

                                            local axis = prop:GetAngles():Right()
                                            phys:SetAngleVelocity(axis * speed * 0.7)
                                        else
                                            phys:SetVelocityInstantaneous(vector_origin)
                                            phys:SetAngleVelocity(vector_origin)
                                        end
                                    end
                                    return
                                end
                            end)
                        end
                    end

                    prop:AddCallback("PhysicsCollide", function(prop, colData)
                        local hitEnt = colData.HitEntity

                        local phys = prop:GetPhysicsObject()
                        if IsValid(phys) then
                            AdvancedPillSound(
                                {
                                    stringe = "OM/Amy/HammerPropBounce.wav",
                                    pitchPercent = 100,
                                    volume = 0.65,
                                    soundLevel = 87
                                },
                                prop
                            )
                            local vel = phys:GetVelocity()
                            local speed = vel:Length()

                            if speed > 1 then
                                local newVel = vel * 0.6
                                phys:SetVelocityInstantaneous(newVel)

                                local angVel = phys:GetAngleVelocity()
                                phys:SetAngleVelocity(angVel * 0.6)
                            else
                                phys:SetVelocityInstantaneous(vector_origin)
                                phys:SetAngleVelocity(vector_origin)
                            end
                        end
                        
                        if !IsValid(hitEnt) or hitEnt == ply then return end

                            if hitEnt:GetNW2Bool("OM_character") and GetConVar('PVPStun_OM'):GetBool() then
                                if hitEnt.CustomFunctionCancelAbility_OM then
                                    hitEnt:CustomFunctionCancelAbility_OM()
                                end
                            else
                            end
                            timer.Simple(0.05,function()
                                if !IsValid(ply) then return end
                                if !IsValid(ent) then return end
                                if !IsValid(hitEnt) then return end

                                local shouldstunstack = GetConVar("OUTCOMEMEMORIES_N_Amy_Throw_stunstack"):GetBool()
                                if Mutual_OMCanStun(ply, ent, hitEnt, shouldstunstack) then
                                    if hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:IsNextBot() then
                                        ent.formTable.Outcomememories_stats.abilities.Throw.StunEffect(ply, ent, hitEnt, ent.formTable.Outcomememories_stats.abilities.CardSwap.RetrieveCurrentAttack(ply, ent), prop)
                                    end
                                end

                                if not (hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:IsNextBot()) then
                                    local phys = prop:GetPhysicsObject()
                                    if IsValid(phys) then
                                        local vel = phys:GetVelocity()
                                        local speed = vel:Length()

                                        if speed > 1 then
                                            local drag = 0.96
                                            local newVel = vel * drag

                                            phys:SetVelocityInstantaneous(newVel)

                                            local axis = prop:GetAngles():Right()
                                            phys:SetAngleVelocity(axis * speed * 0.7)
                                        else
                                            phys:SetVelocityInstantaneous(vector_origin)
                                            phys:SetAngleVelocity(vector_origin)
                                        end
                                    end
                                    return
                                end
                            end)
                    end)
        
                    local phys = prop:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:AddAngleVelocity(hammertrace:Forward() * 1000)
                        phys:SetVelocity(velocity)
                        phys:SetMaterial("metal")
                        phys:SetMass(50)
                        phys:EnableDrag(false)
                        phys:EnableMotion(true)
                    end

                    ent:DeleteOnRemove(prop)
                    ent:SetNW2Bool('HasNoHammer', true)
                    ent:GetPuppet():SetBodygroup(1,1)
                    ent:SetNW2Bool("HammerThrowShouldThrow", false)

                    hook.Add("EntityTakeDamage", "disableAmy_hammerProp_damage_OM_" .. prop:EntIndex(), function(target, dmginfo)
                        if !IsValid(target) or not dmginfo then return end

                        local inflictor = dmginfo:GetInflictor()
                        local damager = dmginfo:GetAttacker()
                        if !IsValid(damager) then return end

                        if damager == prop or inflictor == prop or damager == phys or inflictor == phys then
                            dmginfo:SetDamage(0)
                            dmginfo:SetDamageType(DMG_GENERIC)
                            return true
                        end
                    end)

                    ent:CallOnRemove("RemoveHook_OM"..prop:EntIndex(), function()
                        hook.Remove("PlayerUse", "CustomPropUse_"..prop:EntIndex())
                        hook.Remove("EntityTakeDamage", "disableAmy_hammerProp_damage_OM_:".. prop:EntIndex())
                    end)

                    timer.Simple(8,function()
                        if !IsValid(prop) or !IsValid(ply) then return end
                        if not IsValid(prop) or not IsValid(ply) then return end

                        hook.Remove("PlayerUse", "CustomPropUse_"..prop:EntIndex())

                        prop:SetMoveType(MOVETYPE_NOCLIP)

                        local id = "FlyToPlayer_" .. prop:EntIndex()
                        local startPos = prop:GetPos()
                        local startTime = CurTime()
                        local duration = 0.5
                        local arcHeight = 150

                        local spin = 0
                        local swayAmount = 4
                        local swayCount  = 2

                        hook.Add("Think", id, function()
                            if not IsValid(prop) or not IsValid(ply) then
                                hook.Remove("Think", id)
                                return
                            end

                            local frac = math.min((CurTime() - startTime) / duration, 1)

                            local basePos = LerpVector(frac, startPos, ply:GetPos())

                            local arc = math.sin(frac * math.pi) * arcHeight
                            basePos = basePos + Vector(0, 0, arc)

                            local dir = (ply:GetPos() - basePos):GetNormalized()
                            local right = dir:Angle():Right()

                            local sway = math.sin(frac * math.pi * 2 * swayCount) * swayAmount
                            local pos = basePos + right * sway

                            prop:SetPos(pos)
                            prop:SetSolid(0)

                            local ang = dir:Angle()
                            spin = spin + FrameTime() * 720
                            ang.roll = spin

                            prop:SetAngles(ang)

                            if frac >= 1 then
                                hook.Remove("Think", id)
                                prop:Remove()

                                ent:SetNW2Bool("HasNoHammer", false)
                                ent:GetPuppet():SetBodygroup(1,0)
                                ent:SetNW2Float("HammerEndLag", CurTime()+0.85)

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/Amy/HammerRetract.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                            end
                        end)


                    end)
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
        if ply:GetNW2Bool("Survivor_Downed_OM") then return end
        if SERVER then
            ent.AlternatePlaySolution = true
            if not ent:GetNW2Bool('HasNoHammer') then
                ent:PillAnim('HammerJump')
            else
                ent:PillAnim('jump2')
            end
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