
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











if SERVER then
    util.AddNetworkString("shadow_recieve_mouse")
    util.AddNetworkString("shadow_retrieve_mouse")
    util.AddNetworkString("shadow_recieve_mouse_chaossnap")
    util.AddNetworkString("shadow_retrieve_mouse_chaossnap")

    net.Receive("shadow_recieve_mouse", function()
        local ply = net.ReadEntity()
        local hitPos = net.ReadVector()

        local pillentity = ply.pk_pill_ent
        
        if IsValid(pillentity) then
            if pillentity.formTable.shadow_shootgun then
                pillentity.formTable.shadow_shootgun(ply, pillentity, hitPos)
            end
        end
    end)

    net.Receive("shadow_recieve_mouse_chaossnap", function(_, ply)
        local HitEntity = net.ReadEntity()
        local pillentity = ply.pk_pill_ent
        if IsValid(pillentity) then
            if pillentity.formTable.shadow_chaossnap then
                pillentity.formTable.shadow_chaossnap(ply, pillentity, HitEntity)
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
    local function GetTrueMouseHitEntity(ply)
        local startPos = ply:EyePos()

        local mx, my = gui.MousePos()
        local screenW, screenH = ScrW(), ScrH()
        local middlex, middley = screenW * 0.5, screenH * 0.5

        if mx == 0 and my == 0 then
            mx, my = middlex, middley
        end

        local dir = gui.ScreenToVector(mx, my)

        local tr = util.TraceHull({
            start = startPos,
            endpos = startPos + dir * 10000,
            mins = Vector(-16, -16, -16),
            maxs = Vector(16, 16, 16),
            filter = ply,
            mask = MASK_SOLID
        })

        return tr.Entity
    end
    net.Receive("shadow_retrieve_mouse", function()
        local ply = LocalPlayer()

        net.Start("shadow_recieve_mouse")
            net.WriteEntity(ply)
            net.WriteVector(GetTrueMouseHitPos(ply))
        net.SendToServer()
    end)
    net.Receive("shadow_retrieve_mouse_chaossnap", function()
        local ply = LocalPlayer()

        net.Start("shadow_recieve_mouse_chaossnap")
            net.WriteEntity(GetTrueMouseHitEntity(ply))
        net.SendToServer()
    end)
end

local preservedmats = {
    ["shadow_icon_Aim"] = Material("icons/shadow_icon_Aim.png"),
    ["shadow_icon_dash_boost"] = Material("icons/shadow_icon_dash_boost.png"),
    ["shadow_icon_reload"] = Material("icons/shadow_icon_reload.png"),
    ["shadow_icon_chaos_snap"] = Material("icons/shadow_icon_chaos_snap.png")
}

pk_pills.register('pill_om_Shadow', {

    printName='Shadow',
    Outcomememories='Shadow',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/Shadow.mdl",
    
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
            kick = "kick",
        },
        ShouldMoveRotate={
            idle= function(ent) 
                if ent:GetNW2Float("DashBoost_Duration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("EnabledGun_shadow") and ent:GetNW2Float("MovesetGun") == 1 then return "shiftlock" end
                return "notanything"
            end,
            run= function(ent) 
                if ent:GetNW2Float("DashBoost_Duration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("EnabledGun_shadow") and ent:GetNW2Float("MovesetGun") == 1 then return "shiftlock" end
                return "notshftlock"
            end,
            walk= function(ent) 
                if ent:GetNW2Float("DashBoost_Duration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("EnabledGun_shadow") and ent:GetNW2Float("MovesetGun") == 1 then return "shiftlock" end
                return "notshftlock"
            end,
            fall= function(ent) 
                if ent:GetNW2Float("DashBoost_Duration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("EnabledGun_shadow") and ent:GetNW2Float("MovesetGun") == 1 then return "shiftlock" end
                return "notshftlock"
            end,
            jump= function(ent) 
                if ent:GetNW2Float("DashBoost_Duration") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("EnabledGun_shadow") and ent:GetNW2Float("MovesetGun") == 1 then return "shiftlock" end
                return 'notshftlock'
            end,
            kick = function(ent) 
                return 'assignedagnles'
            end,
        },

        ShouldAlternate={
            idle= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "rolling" end
                if ent:GetNW2Bool("EnabledGun_shadow") and ent:GetNW2Float("MovesetGun") == 1 then return "ShootIdle_layer" end
                if ent:GetNW2Float("DashBoost_Duration") > CurTime() then return "dash" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "idle_lowhealth"
                end 
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "rolling" end
                if ent:GetNW2Float("DashBoost_Duration") > CurTime() then return "dash" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "walk_lowhealth"
                end 
                if ent:GetNW2Bool("EnabledGun_shadow") and ent:GetNW2Float("MovesetGun") == 1 then return "walkGun" end
            end,
            run= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "rolling" end
                if ent:GetNW2Bool("EnabledGun_shadow") and ent:GetNW2Float("MovesetGun") == 1 then return "walkGun" end
                if ent:GetNW2Float("DashBoost_Duration") > CurTime() then return "dash" end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "run_lowhealth"
                end 
                if ent:GetNW2Float("MovesetGun") == 2 then return "Run Gunless" end
                if ent:GetNW2Float("MovesetGun") == 0 then return "Run Gunless" end
            end,
            fall= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "rolling" end
                if ent:GetNW2Float("DashBoost_Duration") > CurTime() then return "dash" end 
            end,
        },

        animrates = {
            run= function(ent)
                return 1
            end,
        }
    },

    ShouldRoll_om = function(e, ply, ent)
        return true
    end,


    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            if ply:GetInfoNum("om_pills_action_custombar_shadow", 0) == 1 then
                return ent:GetNW2Float("MovesetGun") == 1
            end
        end,
        colorbar = function(uselessvar,ply,ent)
            if ent:GetNW2Float("MovesetGun") == 1 
                and not ent:GetNW2Bool("EnabledGun_shadow") then
                    return Color(50, 50, 175, 255) end
            return Color(175, 0, 0, 255)
        end,
        progression = function(uselessvar,ply,ent)
            if ent:GetNW2Float("MovesetGun") == 1  then
                if ent:GetNW2Bool("EnabledGun_shadow") then
                    return ent:GetNW2Float("CurrentBulletCount")
                else
                    return ent:GetNW2Float("CurrentReloadCount")
                end
            end
            return 0
        end,
        maximumbar = function(uselessvar,ply,ent)
            if ent:GetNW2Float("MovesetGun") == 1  then
                if ent:GetNW2Bool("EnabledGun_shadow") then
                    return ent:GetNW2Float("CurrentBulletCount_bullet_count")
                else
                    return ent:GetNW2Float("CurrentReloadCount_max")
                end
            end
            return 1
        end,
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


        if ply:GetInfoNum("om_pills_action_camera_shadow", 1) == 1 then
            if ent:GetNW2Float("MovesetGun") == 1 and ent:GetNW2Bool("EnabledGun_shadow") then
                basetable =  {
                    startoffset = Vector(25,0,50),  -- left-up, front-back, up-down
                    dist=80,
                    fov = ply:GetInfoNum("om_pills_default_fov", 80),
                    id = 1,
                    transition = 1,
                    canscroll = true,
                }
            end
        end


        ent.DashBoost_DurationLerp = ent.DashBoost_DurationLerp or 0
        if ent:GetNW2Float("DashBoost_Duration") > CurTime() then ent.DashBoost_DurationLerp = Lerp(FrameTime()*3, ent.DashBoost_DurationLerp, 1)
        else ent.DashBoost_DurationLerp = Lerp(FrameTime()*1, ent.DashBoost_DurationLerp, 0) end

        basetable["fov"] = basetable["fov"] + ent.DashBoost_DurationLerp * 10
        basetable["dist"] = basetable["dist"] + ent.DashBoost_DurationLerp * 10

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

                if ent:GetNW2Bool("EnabledGun_shadow") and ent:GetNW2Float("MovesetGun") == 1 then
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * 1.8 - ent.formTable.Outcomememories_stats.moveSpeed.run()
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * 1.8 - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.walk() * 1.8 - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                end

                return sendtotable
            end,
            ['function1'] = function( ply, ent )
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
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
                    return GetConVar("OUTCOMEMEMORIES_N_shadow_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_shadow_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_shadow_walk"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_shadow_jumppower"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_shadow_jumpcd"):GetFloat()
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_shadow_rollingPower"):GetFloat()
                end
            end,
        },
    },

    OM_UI_icons = { --pill_om_Shadowpill_om_Shadow
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Float("MovesetGun") == 0
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["shadow_icon_Aim"]
            end,
            name = function(uselessvar,ply,ent)
                return "Gun"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_shadow_ability_1_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return 0
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.04, yaxis = 0 + iconsize * 0.04, xsize = 0 - iconsize* 0.05, ysize = 0 - iconsize * 0.05}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Float("MovesetGun") == 2 and ent:GetNW2Bool("ability1_shouldshow")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["shadow_icon_chaos_snap"]
            end,
            name = function(uselessvar,ply,ent)
                return "Chaos snap"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_shadow_ability_1_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("chaossnap_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 20
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.04, yaxis = 0 + iconsize * 0.07, xsize = 0 - iconsize* 0.05, ysize = 0 - iconsize * 0.05}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return (ent:GetNW2Float("MovesetGun") == 0 or ent:GetNW2Float("MovesetGun") == 2) and ent:GetNW2Bool("ability2_shouldshow")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["shadow_icon_dash_boost"]
            end,
            name = function(uselessvar,ply,ent)
                return "Dash Boost"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_shadow_ability_2_key", KEY_R)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("DashBoost_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 15
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.05, yaxis = 0 + iconsize * 0.03, xsize = 0 - iconsize* 0.05, ysize = 0 - iconsize * 0.05}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [4] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Float("MovesetGun") == 1 
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["shadow_icon_Aim"]
            end,
            name = function(uselessvar,ply,ent)
                return "Aim"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_shadow_ability_1_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("moveset_GunCD")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 1
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.04, yaxis = 0 + iconsize * 0.04, xsize = 0 - iconsize* 0.05, ysize = 0 - iconsize * 0.05}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [5] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return ent:GetNW2Float("MovesetGun") == 1
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["shadow_icon_reload"]
            end,
            name = function(uselessvar,ply,ent)
                return "Reload"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_shadow_ability_2_key", KEY_R)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("moveset_ReloadCD")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 2.5
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.04, yaxis = 0 + iconsize * 0.05, xsize = 0 - iconsize* 0.05, ysize = 0 - iconsize * 0.05}
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

        if event == "RStep" then
            AdvancedPillSound(
                {
                    stringe = {
                        "OM/shadow/RunStep1.wav",
                        "OM/shadow/RunStep2.wav",
                        "OM/shadow/RunStep3.wav",
                        "OM/shadow/RunStep4.wav"
                    },
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )
        end
    end,

    shadow_chaossnap = function(ply, ent, HitEntity)
        if IsValid(HitEntity) then
            if IsValid(HitEntity:GetNW2Entity("DrGBasePossessing")) then return end
            if HitEntity:GetClass() == "pill_puppet" then return end
            if (HitEntity:IsPlayer() or HitEntity:IsNextBot() or HitEntity:IsNPC()) and HitEntity:Health() >= 0.1 then
                if HitEntity == ply then return end
                if HitEntity:IsPlayer() and HitEntity:Team() == TEAM_SPECTATOR then return end
                if HitEntity:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then
                    ent:SetNW2Float("chaossnap_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_shadow_ChaosSnap_miss_cd"):GetFloat())
                else
                    AdvancedPillSound(
                        {
                            stringe = "OM/shadow/chaoscontrol.wav",
                            pitchPercent = 100,
                            volume = 2,
                            soundLevel = 100
                        },
                        ent
                    )

                    local ed = EffectData()
                    ed:SetOrigin(HitEntity:GetPos() + HitEntity:GetUp()*40)
                    util.Effect("shadow_chaossnap_charge_warping", ed)

                    local ed = EffectData()
                    ed:SetOrigin(ply:GetPos()+Vector(0,0,30))
                    util.Effect("shadow_chaossnap_charge_warping", ed)
                    
                    local hit = false
                    local duration = GetConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_windup"):GetFloat()
                    
                    ent:SetNW2Float("chaossnap_Duration", CurTime()+duration+0.35)

                    timer.Simple(duration, function()
                        if not IsValid(ply) then return end
                        if not IsValid(ent) then return end
                        ent:SetNW2Float("chaossnap_cd", CurTime()+GetConVar("OUTCOMEMEMORIES_N_shadow_ChaosSnap_cd"):GetFloat())
                        if not IsValid(HitEntity) then return end

                        local center = HitEntity:WorldSpaceCenter()

                        local plyMins = ply:OBBMins()
                        local plyMaxs = ply:OBBMaxs()

                        local entMins = HitEntity:OBBMins()
                        local entMaxs = HitEntity:OBBMaxs()

                        local entRadius = math.max(
                            math.abs(entMins.x), math.abs(entMaxs.x),
                            math.abs(entMins.y), math.abs(entMaxs.y)
                        )

                        local plyRadius = math.max(
                            math.abs(plyMins.x), math.abs(plyMaxs.x),
                            math.abs(plyMins.y), math.abs(plyMaxs.y)
                        )

                        local startRadius = entRadius + plyRadius + 16

                        local function IsSafe(pos)
                            local tr = util.TraceHull({
                                start = pos,
                                endpos = pos,
                                mins = plyMins,
                                maxs = plyMaxs,
                                filter = ply, -- Don't ignore HitEntity
                                mask = MASK_PLAYERSOLID
                            })

                            return not tr.Hit
                        end

                        local function FindSafePos()
                            local extraRadii = {0, 20, 40, 70, 100}

                            for _, extra in ipairs(extraRadii) do
                                local radius = startRadius + extra

                                for ang = 0, 350, 10 do
                                    local dir = Angle(0, ang, 0):Forward()

                                    local start = center + dir * radius + Vector(0, 0, 128)

                                    local ground = util.TraceHull({
                                        start = start,
                                        endpos = start - Vector(0, 0, 512),
                                        mins = plyMins,
                                        maxs = plyMaxs,
                                        filter = ply,
                                        mask = MASK_PLAYERSOLID
                                    })

                                    if ground.Hit then
                                        local pos = ground.HitPos + Vector(0, 0, 2)

                                        if IsSafe(pos) then
                                            return pos
                                        end
                                    end
                                end
                            end

                            return nil
                        end

                        local safePos = FindSafePos()

                        if safePos then
                            ply:SetPos(safePos)
                        else
                            local fallback = center + Vector(0, 0, entMaxs.z + 72)

                            if IsSafe(fallback) then
                                ply:SetPos(fallback)
                            end
                        end

                        local dir = (HitEntity:GetPos() - safePos):GetNormalized()
                        local velocity = dir * 900 + Vector(0, 0, 250)

                        ply:SetVelocity(velocity)

                        local shouldstunstack = GetConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_canstunstack"):GetBool()

                        if Mutual_OMCanStun(ply, ent, HitEntity, shouldstunstack) then
                            Mutaul_OMStunCode({
                                ["ply"] = ply,
                                ["ent"] = ent,
                                ["target"] = HitEntity,
                                ["StunDur"] = GetConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_baseduration"):GetFloat(),
                                ["stunfunction"] = function(shouldstundamage)
                                    if shouldstundamage then
                                        AdvancedPillSound({
                                            stringe = "OM/shadow/ShadowHit.wav",
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        }, ent)
                                        hit = true


                                        local ed = EffectData()
                                        ed:SetOrigin(HitEntity:GetPos() + HitEntity:GetUp()*40)
                                        util.Effect("shadow_chaossnap_charge", ed)

                                        if GetConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_canragdoll"):GetBool() then


                                            local last = CurTime() + 2
                                            local flung = false

                                            local enemyragdoll = CreateRagdolLCharacter_OM({
                                                target = HitEntity,
                                                host = ent,

                                                shouldremove = function(createfakeragdoll)
                                                    if not IsValid(createfakeragdoll) then return true end
                                                    if not IsValid(HitEntity) then return true end
                                                    if not IsValid(ent) then return true end

                                                    local pos = createfakeragdoll:GetPos()

                                                    local tr = util.TraceLine({
                                                        start = pos,
                                                        endpos = pos - Vector(0, 0, 10),
                                                        filter = createfakeragdoll
                                                    })

                                                    if (last < CurTime() and tr.Hit ) or HitEntity:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime() then
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
                                ["shouldstack"] = shouldstunstack,
                                ["Damage"] = GetConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_stundamage"):GetFloat(),
                                ["DamageType"] = DMG_GENERIC
                            })
                        end


                        local ed2 = EffectData()
                        ed2:SetOrigin(ply:GetPos() + Vector(0, 0, 40))
                        util.Effect("shadow_chaossnap_hit", ed2)
                        
                        if ent.PillAnim then

                            local dir = ply:GetVelocity():GetNormalized()
                            local ang = (HitEntity:GetPos() - ply:GetPos()):Angle()
                            ent:SetNW2Angle("pill_assignedangle",ang)

                            ent.AlternatePlaySolution = true
                            ent:PillAnim("kick")
                            ent.AlternatePlaySolution = false
                        end
                    end)
                    timer.Simple(1.5, function()
                        if not IsValid(ply) then return end
                        if not IsValid(ent) then return end
                        if not IsValid(HitEntity) then return end
                        if not hit then return end
                        AdvancedPillSound({
                            stringe = {
                                "OM/shadow/ChaosSnap1_hit.wav",
                                "OM/shadow/ChaosSnap2_hit.wav",
                                "OM/shadow/ChaosSnap3_hit.wav",
                                "OM/shadow/ChaosSnap4_hit.wav"
                            },
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        }, ent)
                    end)
                end
            end
        end
    end,

    shadow_shootgun = function(ply, ent, hitpos)
        if !IsValid(ply) then return end
        if !IsValid(ent) then return end

        local src = ply:GetPos() + ply:GetUp()*30+ ply:GetForward()*10
        local dir = (hitpos - src):GetNormalized()

        local bullet = {}
        bullet.Num = 1
        bullet.Src = src
        bullet.Dir = dir
        bullet.Spread = Vector(0, 0, 0)
        bullet.Tracer = 0
        bullet.TracerName = ""
        bullet.Force = 50
        bullet.Damage = GetConVar("OUTCOMEMEMORIES_N_shadow_aim_bulletdamage"):GetFloat()
        bullet.AmmoType = "SniperRound"

        bullet.Callback = function(attacker, tr, dmginfo)
            if !tr.Hit then return end

            local hitpos = tr.HitPos
            local HitEntity = tr.Entity

            util.ScreenShake(hitpos, 10, 5, 0.3, 80)

            if IsValid(HitEntity) then
                if IsValid(HitEntity:GetNW2Entity("DrGBasePossessing")) then return end
                if HitEntity:GetClass() == "pill_puppet" then return end
                if (HitEntity:IsPlayer() or HitEntity:IsNextBot() or HitEntity:IsNPC()) and HitEntity:Health() >= 0.1 then
                    if HitEntity == ply then return end
                    if HitEntity:IsPlayer() and HitEntity:Team() == TEAM_SPECTATOR then return end

                    local stunstack = GetConVar("OUTCOMEMEMORIES_N_shadow_aim_canstunstack"):GetBool()

                    if Mutual_OMCanStun(ply, ent, HitEntity, stunstack) then
                        if HitEntity:IsPlayer() then
                            if HitEntity:IsOnGround() then
                                HitEntity:SetPos(HitEntity:GetPos()+Vector(0,0,15))
                            end
                            HitEntity:SetVelocity(dir*200)
                            HitEntity:SetLocalVelocity(dir*200)
                        else
                            if HitEntity:IsOnGround() then
                                HitEntity:SetPos(HitEntity:GetPos()+Vector(0,0,30))
                            end
                            HitEntity:SetVelocity(dir*200)
                            HitEntity:SetLocalVelocity(dir*200)
                        end
                        HitEntity:SetNWFloat("ShadowBulletHitCount", HitEntity:GetNWFloat("ShadowBulletHitCount")+ 6/GetConVar("OUTCOMEMEMORIES_N_shadow_aim_bulletamounttillstun"):GetFloat() )

                        ent:SetNW2Float("Shadow_showcharacter_".. tostring(HitEntity), CurTime()+ 1.25)

                        if HitEntity:GetNWFloat("ShadowBulletHitCount") > 6 then
                            HitEntity:SetNWFloat("ShadowBulletHitCount", 1)
                        end

                        if HitEntity:GetNWFloat("ShadowBulletHitCount") >= 6 then

                            Mutaul_OMStunCode(
                                {
                                    ["ply"] = ply,
                                    ["ent"] = ent,
                                    ["target"] = HitEntity,
                                    ["StunDur"] = GetConVar("OUTCOMEMEMORIES_N_shadow_aim_baseduration"):GetFloat(),
                                    ["stunfunction"] = function(shouldstundamage)
                                        if shouldstundamage then
                                            if GetConVar("OUTCOMEMEMORIES_N_shadow_aim_canragdoll"):GetBool() then


                                                local last = CurTime() + 2
                                                local flung = false

                                                local enemyragdoll = CreateRagdolLCharacter_OM({
                                                    target = HitEntity,
                                                    host = ent,

                                                    shouldremove = function(createfakeragdoll)
                                                        if not IsValid(createfakeragdoll) then return true end
                                                        if not IsValid(HitEntity) then return true end
                                                        if not IsValid(ent) then return true end

                                                        local pos = createfakeragdoll:GetPos()

                                                        local tr = util.TraceLine({
                                                            start = pos,
                                                            endpos = pos - Vector(0, 0, 10),
                                                            filter = createfakeragdoll
                                                        })

                                                        if (last < CurTime() and tr.Hit ) or HitEntity:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime() then
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
                                    ["shouldstack"] = stunstack,
                                    ["Damage"] = GetConVar("OUTCOMEMEMORIES_N_shadow_aim_stundamage"):GetFloat(),
                                    ["DamageType"] = DMG_GENERIC
                                }
                            )
                        end
                    else
                        dmginfo:SetDamage(0)
                    end
                end
            end
        end

        ply:FireBullets(bullet)

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
           

        local tr = util.TraceLine({
            start = src,
            endpos = src + dir * 4000000,
            filter = ply,
            mask = MASK_SOLID
        })

        local ed = EffectData()
        ed:SetStart(src)
        ed:SetOrigin(tr.HitPos)

        util.Effect("shadow_shoot_beam", ed)
        
        util.ScreenShake(
            src,
            20,
            5,
            0.6,
            60
        )
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
        if SERVER then
            initializetable2["entity"]:SetNW2Int('OM_friction', 1)

            local health = GetConVar("OUTCOMEMEMORIES_N_shadow_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Int("MaxHealth",health)
            initializetable2["player"]:SetNW2Int("MaxHealth_OM",health)

            initializetable2["player"].OM_DamageBeforeCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                local ent = initializetable2["entity"]
                local ply = initializetable2["player"]
                    
                if !IsValid(initializetable2["entity"]) then return end
                if initializetable2["entity"]:GetNW2Float("CounterOM_duration") > CurTime() then
                    if damageamount > 0 then else return end
                    local damager = dmg:GetAttacker()
                    if not ( dmg:IsDamageType(DMG_CLUB) or dmg:IsDamageType(DMG_SLASH) ) then return false end
                    if IsValid(damager) then
                        if entityfall == ply and damager ~= ply  then
                            if damager.CustomFunctionParryAbility_OM then
                                damager:CustomFunctionParryAbility_OM()
                            end
                            dmg:SetDamage(0)
                            dmg:SetDamageType(DMG_GENERIC)

                            ent:GetPuppet():SetNW2Float("shadow_highlight_pill", 0)
                            ent:SetNW2Float("CounterOM_duration", 0)

                            ent:GetPuppet():SetNW2Float('shadow_highlight_pill_redglow',CurTime()+0.5*0.5)
                            damager:SetNW2Float('shadow_highlight_pill_redglow',CurTime()+0.5*0.5)

                            damager:SetPos(damager:GetPos()+Vector(0,0,40))
                            local dir = (damager:GetPos() - entityfall:GetPos()):GetNormalized()
                            damager:SetVelocity(dir*900)
                            damager:SetLocalVelocity(dir*900)
                            return true
                        end
                    end
                end
            end


            initializetable2["player"].CustomFunctionForDowned_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]

                    if ent:GetNW2Bool("DashBoost_bool") then
                        ent:SetNW2Bool("DashBoost_bool", false)
                        ent:SetNW2Float("DashBoost_cd", CurTime()+15)
                    end
                    ent:SetNW2Float("DashBoost_Duration",0)
                    ent:SetNW2Bool("EnabledGun_shadow", false)
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
        initializetable2["entity"]:GetPuppet():SetBodygroup(1,1)
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
            ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_shadow_Resistance"):GetFloat()/100)
            
            if GetConVar("OUTCOMEMEMORIES_N_shadow_CanChaosSnap"):GetBool() then
                ent:SetNW2Float("ability1_shouldshow", true)
            else
                ent:SetNW2Float("ability1_shouldshow", false)
            end
            
            if GetConVar("OUTCOMEMEMORIES_N_shadow_CanDashBoost"):GetBool() then
                ent:SetNW2Float("ability2_shouldshow", true)
            else
                ent:SetNW2Float("ability2_shouldshow", false)
            end

            if not GetConVar("OUTCOMEMEMORIES_N_shadow_CanUseGun"):GetBool() then
                if ent:GetNW2Float("MovesetGun") == 0 then
                    ent:SetNW2Float("MovesetGun", 2)
                end
            else
                if not ent.OM_shadow_phase2 and ent:GetNW2Float("MovesetGun") == 2 then
                    ent:SetNW2Float("MovesetGun", 0)
                end
            end

            if ent:GetNW2Float("MovesetGun") == 2 then
                if ent:GetPuppet():GetNW2Float("shadow_afterimage_duration") < CurTime() then
                    ent:GetPuppet():SetNW2Float("shadow_natural_afterimage_duration", CurTime() +0.1)
                end
            end

            local shouldiframe = false

            if not ent.shadow_dashvelocity then ent.shadow_dashvelocity = 0 end

            if ent:GetNW2Float("DashBoost_Duration") > CurTime() then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                ent:GetPuppet():SetNW2Float("shadow_afterimage_duration", CurTime() + 0.1)
                shouldiframe = true
                ent.shadow_dashvelocity = GetConVar("OUTCOMEMEMORIES_N_shadow_charge"):GetFloat()
                ent:SetNW2Bool("DashBoost_bool", true)

                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 120)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if ( ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() ) then continue end

                        if not Mutual_OMCanStun(ply, ent, ent2, true) then
                            if ent2.CustomFunctionCancelAbility_OM then
                                ent2:CustomFunctionCancelAbility_OM()
                                ent:SetNW2Float("DashBoost_Duration", 0)
                            end
                        end
                    end
                end
            else
                if ent:GetNW2Bool("DashBoost_bool") then
                    ent:SetNW2Bool("DashBoost_bool", false)
                    ent:SetNW2Float("DashBoost_cd", CurTime()+15)
                end
                ent.shadow_dashvelocity = Lerp(FrameTime()*5, ent.shadow_dashvelocity, 0)
            end


            if ent.shadow_dashvelocity > 400 then
                ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.1)
                if ply:IsPlayer() then
                    ply:SetNW2Vector("OM_SetVelocity_Vector",ply:EyeAngles():Forward() * ent.shadow_dashvelocity)
                end
            end
            
            if ent:GetNW2Float("CurrentReloadCount") <= 0 and ent:GetNW2Float("CurrentBulletCount") <= 0 then
                if ent:GetNW2Float("MovesetGun") == 1 then
                    ent:GetPuppet():SetBodygroup(1,1)
                    ent:SetNW2Float("MovesetGun", 2)

                    ent.OM_shadow_phase2 = true
                    ent:SetNW2Bool("EnabledGun_shadow", false)
                    AdvancedPillSound(
                        {
                            stringe = "OM/shadow/Phase2.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:GetPuppet():SetNW2Float('shadow_highlight_pill_redglow',CurTime()+0.5*0.5)
                    ent:GetPuppet():SetNW2Float('shadow_ability_outline',CurTime()+0.5*0.5)
                end
            end

            if shouldiframe then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.15)
                ply:SetNW2Float("OM_Damage_Reduction",0)
            else
                ply:SetNW2Float("OM_Damage_Reduction",1)
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if ent:GetNW2Float("DashBoost_Duration") > CurTime() then return end
        if ent:GetNW2Float("chaossnap_Duration") > CurTime() then return end




        if button == ply:GetInfoNum("om_pills_action_shadow_ability_1_key", KEY_E) then
            if ent:GetNW2Float("MovesetGun") == 0 then
                ent:SetNW2Float("MovesetGun", 1)
                ent:GetPuppet():SetBodygroup(1,0)
                ent:SetNW2Float("CurrentReloadCount", GetConVar("OUTCOMEMEMORIES_N_shadow_reload_reloads"):GetFloat())
                ent:SetNW2Float("CurrentReloadCount_max", GetConVar("OUTCOMEMEMORIES_N_shadow_reload_reloads"):GetFloat())
                AdvancedPillSound(
                    {
                        stringe = "OM/shadow/GunStart.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent:GetPuppet():SetNW2Float("shadow_highlight_pill", CurTime()+0.5*0.5)
                return
            end
            if ent:GetNW2Float("MovesetGun") == 1 then
                if ent:GetNW2Float("moveset_GunCD") > CurTime() then return end
                ent:SetNW2Float("moveset_GunCD", CurTime()+GetConVar("OUTCOMEMEMORIES_N_shadow_aim_cd"):GetFloat() )

                if GetConVar("OUTCOMEMEMORIES_N_shadow_aim_canparry"):GetBool() then
                    ent:GetPuppet():SetNW2Float("shadow_highlight_pill", CurTime()+0.5*0.5)
                    ent:SetNW2Float("CounterOM_duration", CurTime()+0.5)
                end

                if ent:GetNW2Bool("EnabledGun_shadow") then
                    AdvancedPillSound(
                        {
                            stringe = "OM/shadow/GunEnd.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:SetNW2Bool("EnabledGun_shadow", false)

                else
                    AdvancedPillSound(
                        {
                            stringe = "OM/shadow/GunStart.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:SetNW2Bool("EnabledGun_shadow", true)
                end
                return
            end
            if ent:GetNW2Float("MovesetGun") == 2 then
                if not GetConVar("OUTCOMEMEMORIES_N_shadow_CanChaosSnap"):GetBool() then return end
                if ent:GetNW2Float("chaossnap_cd") > CurTime() then return end
                if ent:GetNW2Float("chaossnap_Duration") > CurTime() then return end
                if SERVER then
                    if ply:IsPlayer() then
                        net.Start("shadow_retrieve_mouse_chaossnap")
                        net.Send(ply)
                    else
                        if ent:GetNW2Float("MovesetGun") == 2 then
                            local tr = util.TraceLine({
                                start = ply:GetShootPos(),
                                endpos = ply:GetShootPos() + ply:GetAimVector() * 32768,
                                filter = ply
                            })

                            local hitEnt = tr.Entity

                            if ent.formTable.shadow_chaossnap then
                                ent.formTable.shadow_chaossnap(ply, ent, hitEnt)
                            end
                        end
                    end
                end
            end
        end
        if button == ply:GetInfoNum("om_pills_action_shadow_ability_2_key", KEY_R) then
            if ent:GetNW2Float("MovesetGun") == 0 or ent:GetNW2Float("MovesetGun") == 2 then
                if not GetConVar("OUTCOMEMEMORIES_N_shadow_CanDashBoost"):GetBool() then return end
                if ent:GetNW2Float("DashBoost_Duration") > CurTime() then return end
                if ent:GetNW2Float("DashBoost_cd") > CurTime() then return end
                if ent:GetNW2Bool("DashBoost_bool") then return end
                ent:SetNW2Float("DashBoost_Duration", CurTime()+GetConVar("OUTCOMEMEMORIES_N_shadow_DashBoost_Duration"):GetFloat())
                AdvancedPillSound(
                    {
                        stringe = "OM/shadow/Boost.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                return
            end
            if ent:GetNW2Float("MovesetGun") == 1 then
                if ent:GetNW2Float("CurrentReloadCount") <= 0 then return end
                if ent:GetNW2Float("CurrentBulletCount") > 0 then return end
                if ent:GetNW2Float("moveset_ReloadCD") > CurTime() then return end
                ent:SetNW2Float("CurrentBulletCount", GetConVar("OUTCOMEMEMORIES_N_shadow_reload_bulletsreload"):GetFloat() )
                ent:SetNW2Float("CurrentBulletCount_bullet_count", GetConVar("OUTCOMEMEMORIES_N_shadow_reload_bulletsreload"):GetFloat() )
                ent:SetNW2Float("CurrentReloadCount", ent:GetNW2Float("CurrentReloadCount")-1)
                ent:SetNW2Float("moveset_ReloadCD", CurTime()+ GetConVar("OUTCOMEMEMORIES_N_shadow_reload_cd"):GetFloat() )
                AdvancedPillSound(
                    {
                        stringe = {
                            "OM/shadow/Reload1.wav",
                            "OM/shadow/Reload2.wav",
                            "OM/shadow/Reload3.wav",
                            "OM/shadow/Reload4.wav",
                            "OM/shadow/Reload5.wav"
                        },
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                if GetConVar("OUTCOMEMEMORIES_N_shadow_reload_canparry"):GetBool() then
                    ent:GetPuppet():SetNW2Float("shadow_highlight_pill", CurTime()+0.5*0.5)
                    ent:SetNW2Float("CounterOM_duration", CurTime()+0.5)
                end

                return
            end
        end
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if ent:GetNW2Float("MovesetGun") == 1 then
                if ent:GetNW2Float("moveset_GunCD") > CurTime() then return end
                if not ent:GetNW2Bool("EnabledGun_shadow") then return end
                if ent:GetNW2Float("moveset_ReloadCD") > CurTime() then return end
                if ent:GetNW2Float("CurrentBulletCount") <= 0 then 
                    ent:EmitSound("Weapon_Pistol.Empty")
                    return end

                if ent:GetNW2Float("moveset_shootingCD") > CurTime() then return end
                ent:SetNW2Float("moveset_shootingCD", CurTime()+0.1)

                ent:SetNW2Float("CurrentBulletCount", ent:GetNW2Float("CurrentBulletCount")-1)

                if ply:IsPlayer() then
                    net.Start("shadow_retrieve_mouse")
                    net.Send(ply)
                else
                    local tr = util.TraceLine({
                        start = ply:GetShootPos(),
                        endpos = ply:GetShootPos() + ply:GetAimVector() * 32768,
                        filter = ply
                    })

                    local hitpos = tr.HitPos

                    if ent.formTable.shadow_shootgun then
                        ent.formTable.shadow_shootgun(ply, ent, hitpos)
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
        ent.AlternatePlaySolution = true
        ent:PillAnim('jump2')
        ent.AlternatePlaySolution = false

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
