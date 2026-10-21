
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





if SERVER then
    util.AddNetworkString("lilith_recieve_mouse")
    util.AddNetworkString("lilith_retrieve_mouse")

    net.Receive("lilith_recieve_mouse", function()
        local ply = net.ReadEntity()
        local hitPos = net.ReadVector()

        local pillentity = ply.pk_pill_ent
        
        if IsValid(pillentity) then
            if pillentity.formTable.LilithSpawnPos then
                pillentity.formTable.LilithSpawnPos(ply, pillentity, hitPos)
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
    net.Receive("lilith_retrieve_mouse", function()
        local ply = LocalPlayer()

        net.Start("lilith_recieve_mouse")
            net.WriteEntity(ply)
            net.WriteVector(GetTrueMouseHitPos(ply))
        net.SendToServer()
    end)
end

local preservedmats = {
    ["Spinball_Lilith"] = Material("icons/Spinball_Lilith.png"),
    ["blunt_trauma"] = Material("icons/blunt_trauma.png"),
    ["Lilith_Indicator_Move_Thingy"] = Material("icons/Lilith_Indicator_Move_Thingy.png"),
    ["lilith_indicator"] = Material("icons/lilith_indicator.png"),
}

pk_pills.register('pill_om_Lilith', {

    printName='Lilith',
    Outcomememories='Lilith',
    Outcomememories_material="Organic",
        
    model="models/noodles/om/lilith.mdl",

    camera={
        offset = Vector(0, 0, 40),
        dist=130,
    },

    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',
        
    OM_UI_custom1 = function(ply, ent)
        if not ent.ClientSide_alpha_lillithindicator then ent.ClientSide_alpha_lillithindicator = 0 end
        if ent:GetNW2Float("Indicator_lilith") > CurTime() then
            ent.ClientSide_alpha_lillithindicator = Lerp(FrameTime()*6, ent.ClientSide_alpha_lillithindicator, 1)
        else
            ent.ClientSide_alpha_lillithindicator = Lerp(FrameTime()*6, ent.ClientSide_alpha_lillithindicator, 0)
        end

        if ent.ClientSide_alpha_lillithindicator > 0.05 then
            cam.Start3D(EyePos(), EyeAngles())
                render.SuppressEngineLighting(true)
                render.FogMode(MATERIAL_FOG_NONE)

                local nearestEnt
                local nearestDist = math.huge

                for _, ent2 in ipairs(ents.GetAll()) do
                    if !IsValid(ent2) then continue end
                    if !(ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) then continue end
                    if ent2 == ply then continue end
                    if ent2 == ply:GetNW2Entity("DrGBasePossessing") then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                    local hp = ent2:Health() or 0
                    if hp <= 0 then continue end

                    local dist = ply:GetPos():DistToSqr(ent2:GetPos())

                    if dist < nearestDist then
                        nearestDist = dist
                        nearestEnt = ent2
                    end
                end

                if IsValid(nearestEnt) then
                    local dist = math.sqrt(nearestDist)
                    local Size = math.min(math.max(95 * dist / 700, 95), 2200)

                    local pos = nearestEnt:WorldSpaceCenter()

                    cam.IgnoreZ(true)
                        render.SetBlend(0.65)
                        render.SetMaterial(preservedmats["lilith_indicator"])

                        render.DrawQuadEasy(
                            pos,
                            EyeAngles():Forward() * -1,
                            Size,
                            Size,
                            Color(255, 255, 255, 225*ent.ClientSide_alpha_lillithindicator),
                            0
                        )

                        render.SetBlend(1)
                    cam.IgnoreZ(false)
                end

                render.FogMode(MATERIAL_FOG_LINEAR)
                render.SuppressEngineLighting(false)
            cam.End3D()
        end

        if not ent.ClientSide_alpha_lillithindicator_teleport then ent.ClientSide_alpha_lillithindicator_teleport = 0 end
        if ent:GetNW2Bool("teleportarea_lilith_bool") then
            ent.ClientSide_alpha_lillithindicator_teleport = Lerp(FrameTime()*6, ent.ClientSide_alpha_lillithindicator_teleport, 1)
        else
            ent.ClientSide_alpha_lillithindicator_teleport = Lerp(FrameTime()*1, ent.ClientSide_alpha_lillithindicator_teleport, 0)
        end

        if ent.ClientSide_alpha_lillithindicator_teleport > 0.05 then
            local origin = ent:GetNW2Vector("teleportarea_lilith_vector")

            cam.Start3D(EyePos(), EyeAngles())
                render.SuppressEngineLighting(true)
                render.FogMode(MATERIAL_FOG_NONE)

                for _, ent2 in ipairs(ents.FindInSphere(origin, 800)) do
                    if not IsValid(ent2) then continue end
                    if not (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) then continue end
                    if ent2 == ply then continue end
                    if ent2 == ply:GetNW2Entity("DrGBasePossessing") then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                    local hp = ent2:Health() or 0
                    if hp <= 0 then continue end

                    local dist = ply:GetPos():Distance(ent2:GetPos())
                    local Size = math.Clamp(95 * (dist / 700), 95, 2200)

                    local pos = ent2:WorldSpaceCenter()

                    cam.IgnoreZ(true)
                        render.SetBlend(0.65)
                        render.SetMaterial(preservedmats["lilith_indicator"])

                        render.DrawQuadEasy(
                            pos,
                            EyeAngles():Forward() * -1,
                            Size,
                            Size,
                            Color(200, 200, 200, 255*ent.ClientSide_alpha_lillithindicator_teleport),
                            0
                        )

                        render.SetBlend(1)
                    cam.IgnoreZ(false)
                end


                local dist = ply:GetPos():Distance(origin)
                local Size = math.Clamp(95 * (dist / 700), 95, 2200)

                cam.IgnoreZ(true)
                    render.SetBlend(1)
                    render.SetMaterial(preservedmats["lilith_indicator"])

                    render.DrawQuadEasy(
                        origin+Vector(0,0,40),
                        EyeAngles():Forward() * -1,
                        Size,
                        Size,
                        Color(175, 175, 175, 175*ent.ClientSide_alpha_lillithindicator_teleport),
                        0
                    )

                    render.SetBlend(1)
                cam.IgnoreZ(false)

                render.FogMode(MATERIAL_FOG_LINEAR)
                render.SuppressEngineLighting(false)
            cam.End3D()
        end
    end,

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            jump2="jump",
            glide="fall",
            jump2="jump",
            BluntTruama="BluntTruama",
        },
        ShouldMoveRotate={
            idle= function(ent)
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return "shiftlock" end
                return 'notanything' 
            end,
            BluntTruama= function(ent)
                return 'shiftlock' 
            end,
            run= function(ent)
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return "shiftlock" end
                return 'notshftlock' 
            end,
            walk= function(ent) 
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return "shiftlock" end
                return 'notshftlock' 
            end,
            jump= function(ent) 
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return "shiftlock" end
                return 'notshftlock'
            end,
            fall= function(ent)
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return "shiftlock" end
                return "notshftlock"
            end,
        },

        ShouldAlternate={
            fall = function(ent)
                if ent:GetNW2Float("LilithChargeDash_windup_charge") > CurTime() then return "Charge" end
                if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() or ent:GetNW2Float("Spindash_Duration") > CurTime() then return "roll" end
                if ent:GetNW2Float("jumpanim") > CurTime() then return "Jump" end
            end,
            idle= function(ent)
                if ent:GetNW2Float("LilithChargeDash_windup_charge") > CurTime() then return "Charge" end
                if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() or ent:GetNW2Float("Spindash_Duration") > CurTime() then return "roll" end
            end,
            walk= function(ent)
                if ent:GetNW2Float("LilithChargeDash_windup_charge") > CurTime() then return "Charge" end
                if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() or ent:GetNW2Float("Spindash_Duration") > CurTime() then return "roll" end
            end,
            run= function(ent)
                if ent:GetNW2Float("LilithChargeDash_windup_charge") > CurTime() then return "Charge" end
                if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() or ent:GetNW2Float("Spindash_Duration") > CurTime() then return "roll" end
            end,
        },

        animrates = {
            run= function(ent)
                if ent:GetNW2Float("LilithChargeDash_windup_charge") > CurTime() then return 1 end
                if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() or ent:GetNW2Float("Spindash_Duration") > CurTime() then return 1 end
                return 1.3
            end
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
        --[[
        if ent:GetNW2Float("Spindash_Duration") > CurTime() or ent:GetNW2Float("LilithChargeDash_windup") > CurTime() then
            basetable =  {
                startoffset = Vector(20,0,45),  -- left-up, front-back, up-down
                dist=145,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 2,
                transition = 1,
                canscroll = true,
            }
        end
        if ent:GetNW2Float("jumpanim") > CurTime() then
            basetable =  {
                startoffset = Vector(0,0,25),  -- left-up, front-back, up-down
                dist=130,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 1,
                transition = 1,
                canscroll = true,
            }
        end
        ]]


        return basetable
    end,
    
    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Lilith_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Lilith_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Lilith_walk"):GetFloat()
                end
            end,
            Dropdash= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Lilith_chargedash"):GetFloat()
                end
            end,
            DropdashCharge= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargedashCharge"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Lilith_jumppower"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Lilith_jumpcd"):GetFloat()
                end
            end,
        },
    },

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM") and math.random(1,400) ~= 1
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Spinball_Lilith"]
            end,
            name = function(uselessvar,ply,ent)
                return "Charge Dash"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_lilith_ChargeDash", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Spindash_Cooldown") + math.random(75,100) / 200
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 15
            end,
            font = "CreditsText",
            OffsetIcon = function(uselessvar,ply,ent)

                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                shouldrandom = true
                return {
                    xaxis = 0 + iconsize * 0.15/2 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,200) ~= 1 and 1 or math.random(-30,30)), 
                    yaxis = 0 + iconsize * 0.2/2 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,200) ~= 1 and 1 or math.random(-30,30)),
                    xsize = 0- iconsize*0.15 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,200) ~= 1 and 1 or math.random(-30,30)),
                    ysize = 0- iconsize*0.15 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,200) ~= 1 and 1 or math.random(-30,30))
                }
            end,
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM") and math.random(1,400) ~= 1
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["blunt_trauma"]
            end,
            name = function(uselessvar,ply,ent)
                return "Blunt Trauama"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_lilith_BluntTruama", KEY_R)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("BluntTruama_Cooldown") + math.random(75,100) / 100
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 15
            end,
            font = "CreditsText",
            OffsetIcon = function(uselessvar,ply,ent)

                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                shouldrandom = true
                return {
                    xaxis = 0 + iconsize * 0.2/2 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,200) ~= 1 and 1 or math.random(-30,30)), 
                    yaxis = 0 + iconsize * 0.2/2 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,200) ~= 1 and 1 or math.random(-30,30)),
                    xsize = 0- iconsize*0.15 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,200) ~= 1 and 1 or math.random(-30,30)),
                    ysize = 0- iconsize*0.15 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,200) ~= 1 and 1 or math.random(-30,30))
                }
            end,
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility3_OM") and math.random(1,400) ~= 1
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Lilith_Indicator_Move_Thingy"]
            end,
            name = function(uselessvar,ply,ent)
                return "False Image"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_lilith_FalseImage", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("lilith_teleport_Cooldown") + math.random(75,100) / 100
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 10
            end,
            font = "CreditsText",
            OffsetIcon = function(uselessvar,ply,ent)

                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                shouldrandom = true
                return {
                    xaxis = 0 + iconsize * 0.15/2 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,50) ~= 1 and 1 or math.random(-30,30)), 
                    yaxis = 0 + iconsize * 0.2/2 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,50) ~= 1 and 1 or math.random(-30,30)),
                    xsize = 0- iconsize*0.15 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,50) ~= 1 and 1 or math.random(-30,30)),
                    ysize = 0- iconsize*0.15 + iconsize * (shouldrandom and math.random(-1,1) / 200 or 0 ) * (math.random(1,50) ~= 1 and 1 or math.random(-30,30))
                }
            end,
        },
    },

    jumpPower=400,
       
    speedhandeler_om = {
        modifiers = {
            ['DropDash'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("Spindash_Duration") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.Dropdash() - ent.formTable.Outcomememories_stats.moveSpeed.walk() *0.7
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Dropdash() - ent.formTable.Outcomememories_stats.moveSpeed.run() *0.7
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.Dropdash() - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *0.7
                end

                return sendtotable
            end,
            ['DropDashE'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.DropdashCharge() - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.DropdashCharge() - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.DropdashCharge() - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
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
                        DamageNumb = GetConVar("OUTCOMEMEMORIES_N_Lilith_Damage"):GetFloat(),
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
            initializetable2["player"]:SetNW2String("chasemusic_life1_om","OM/music/LilithChaseMusic.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life2_om","OM/music/LilithChaseMusic.wav")

            if GetConVar("OUTCOMEMEMORIES_N_Lilith_HasHealth"):GetBool() then
                initializetable2["player"]:GodDisable()
            end
            initializetable2["player"]:SetHealth(GetConVar("OUTCOMEMEMORIES_N_Lilith_Health"):GetFloat())
            initializetable2["player"]:SetMaxHealth(GetConVar("OUTCOMEMEMORIES_N_Lilith_Health"):GetFloat())
            --
            initializetable2["entity"]:SetNW2Float("MaxHealth",GetConVar("OUTCOMEMEMORIES_N_Lilith_Health"):GetFloat())
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",GetConVar("OUTCOMEMEMORIES_N_Lilith_Health"):GetFloat())

            initializetable2["entity"].poisoncd = initializetable2["entity"].poisoncd or {}
            

            initializetable2["player"].OM_StunFunction = function()
                local ent = initializetable2["entity"]
                if !IsValid(ent) then return end
                ent:SetNW2Float("Lilith_blunttrruama_chargeup", 0)
                ent:SetNW2Float("Lilith_blunttrruama_duration", 0)
                ent:SetNW2Float("Spindash_Duration", 0)
                local timername = "lilith_blunttruama_" .. ent:EntIndex()
                timer.Remove(timername)
                if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() then
                    ent:SetNW2Float('Spindash_Cooldown',CurTime()+GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashCd"):GetFloat())
                end
                ent:SetNW2Float("LilithChargeDash_windup", 0)
                ent.LilithChargeDash_windup = false
                
            end
        end
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetGravity(1)

            if bit.band(initializetable2["player"]:GetFlags(), FL_NOTARGET) ~= 0 then
                initializetable2["player"]:RemoveFlags(FL_NOTARGET)
            end

            local timername = "lilith_blunttruama_" .. initializetable2["entity"]:EntIndex()
            timer.Remove(timername)
        end
    end,


    LilithSpawnPos = function(ply, ent, hitpos)
        ent:SetNW2Vector("SpawnPropPos", hitpos)

        local position = ent:GetNW2Vector("Lilith_blunttruama_spawnpos")
        local angle = (hitpos-position):Angle()

        ent:SetNW2Angle("Lilith_blunttruama_spawnangle", angle)
    end,


    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            ent.poisoncd = ent.poisoncd or {}
            if not GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDash_canuse"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
            end
            if not GetConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
            end
            if not GetConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility3_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility3_OM", false)
            end

            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_Lilith_Resistance"):GetFloat()/100)
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") > CurTime() or ply:GetNW2Float("DisablePlayerMovement_OM_stun_iframe3") > CurTime() or ent:GetNW2Float("OM_executionanim") > CurTime() then
                ply:SetNW2Float("OM_Damage_Reduction",0)
            else
                ply:SetNW2Float("OM_Damage_Reduction",1)
            end

            if not ent.indicatorcd then
                ent.indicatorcd = CurTime() + 5
            end

            if ent.indicatorcd < CurTime() then
                ent:SetNW2Float("Indicator_lilith", CurTime()+5)
                ent.indicatorcd = CurTime() + 10
            end

            if ent:GetNW2Float("Lilith_blunttrruama_duration") > CurTime() then
                if not ent.blunttruama_bool then
                    ent.blunttruama_bool = true
                    ent:SetNW2Vector("Lilith_blunttruama_spawnpos", ply:GetPos())
                    ent:SetNW2Vector("Lilith_blunttruama_spawnpos_puddle", ply:GetPos())
                    ent:SetNW2Angle("Lilith_blunttruama_spawnangle", ply:GetAngles())
                    ent:SetNW2Float("Lilith_blunttruama_forward", 0)
                end

                if ent:GetNW2Float("spawn_blunttruama_puddle_cd") < CurTime() then
                    ent:SetNW2Float("spawn_blunttruama_puddle_cd", CurTime() + 0.0575)

                    if ply:IsPlayer() then
                        net.Start("lilith_retrieve_mouse")
                        net.Send(ply)
                    else
                        ent:SetNW2Angle("Lilith_blunttruama_spawnangle", ply:GetAngles())
                    end

                    local forward = 185

                    local ball = ents.Create("ent_om_lilithpuddle")

                    local startPos = ent:GetNW2Vector("Lilith_blunttruama_spawnpos_puddle") + ent:GetNW2Angle("Lilith_blunttruama_spawnangle"):Forward() * forward

                    local tr = util.TraceLine({
                        start = startPos + Vector(0, 0, 100),
                        endpos = startPos - Vector(0, 0, 5000),
                        filter = {ent, ball}
                    })

                    ball:SetPos(tr.HitPos)

                    local ang = tr.HitNormal:Angle()
                    ang:RotateAroundAxis(ang:Right(), -90)

                    ball:SetAngles(ang)
                    ball:Spawn()
                    ball:SetPillUser(ply)
                    ball:SetPuppet(ent)

                    ent:DeleteOnRemove(ball)

                    ent:SetNW2Vector("Lilith_blunttruama_spawnpos_puddle", ball:GetPos())
                end
            else
                if ent.blunttruama_bool then
                    ent:SetNW2Float("BluntTruama_Cooldown", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama_CD"):GetFloat())
                    ent.blunttruama_bool = false
                end
            end

            if ent:GetNW2Float("LilithChargeDash_windup_charge") > CurTime() then
                
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.1)
                if not ent.LilithChargeDash_windup_charge then
                    ent.LilithChargeDash_windup_charge = true
                    ent:GetPuppet():SetNW2Float('lilith_green_glow_green',CurTime()+0.5*0.6)
                    ent:GetPuppet():SetNW2Float("lilithoutine_ability_outline1", CurTime()+0.5*0.6)

                end
            else

                if ent.LilithChargeDash_windup_charge then
                    ent.LilithChargeDash_windup_charge = false

                    AdvancedPillSound(
                        {
                            stringe = "OM/eggman/eggman double jump.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            end

            if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() then
                if not ent.LilithChargeDash_windup then
                    ent.LilithChargeDash_windup = true
                end
                if ent:GetNW2Float("LilithChargeDash_windup_charge") < CurTime() then
                    ply:SetNW2Float("OM_MoveForwardSpeed", GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargedashCharge"):GetFloat())
                    ply:SetNW2Float("OM_MoveForward", CurTime() + 0.1)
                end
            else

                if ent.LilithChargeDash_windup then
                    ent:GetPuppet():SetNW2Float('lilith_green_glow_green',CurTime()+0.5*0.6)
                    ent:GetPuppet():SetNW2Float("lilithoutine_ability_outline1", CurTime()+0.5*0.6)
                    ent.LilithChargeDash_windup = false
                    ent:SetNW2Float("Spindash_Duration", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashDuration"):GetFloat())

                    local ballsonic = ents.Create("ent_om_hedgehog_dropballs")
                    ballsonic:SetPos(ply:GetPos())
                    ballsonic:SetAngles(ply:GetAngles())
                    ballsonic:Spawn()
                    ballsonic:SetPillUser(ply)
                    ballsonic:SetPillUser2(ent:GetPuppet())
                    ent:DeleteOnRemove(ballsonic)
                    ballsonic:SetColor(Color(0, 0, 0, 0))
                    ballsonic:SetRenderMode(RENDERMODE_TRANSALPHA)
                    ent:SetNW2Entity("GlowingBallThingy_OM",ballsonic)
                    ent:GetPuppet():SetNW2Entity("GlowingBallThingy_OM",ballsonic)
                    ballsonic:SetModelScale(1.75)
                    ballsonic:SetMaterial("models/noodles/om/Sonicball/lilithball")

                    local uniqueID = "OM_SonicModelBall_" .. ballsonic:EntIndex()
                    local oldcolor = ent:GetPuppet():GetColor()

                    local startTime = CurTime()
                    local fadeDuration = 0.4
                    
                    if SERVER then
                        local trail_3ndlayer = util.SpriteTrail(
                            ballsonic,
                            0,
                            Color(255,255,255),
                            true,
                            40,
                            0,
                            0.5,
                            0.5,
                            "models/noodles/om/sonicball/greenlilith.vmt"
                        )

                        ent.trail_3ndlayer = trail_3ndlayer
                        ent:DeleteOnRemove(trail_3ndlayer)
                        ballsonic:DeleteOnRemove(trail_3ndlayer)

                        local trail = util.SpriteTrail(
                            ballsonic,
                            0,
                            Color(255, 255, 255),
                            true,
                            70,
                            40,
                            0.75,
                            0.02,
                            "models/noodles/om/sonicball/greenlilith_2ndlayer.vmt"
                        )


                        ent.trail = trail
                        ent:DeleteOnRemove(trail)
                        ballsonic:DeleteOnRemove(trail)
                    end
                    local spindashl = false

                    local puppetColor = Color(255,255,255,255)
                    local ballColor = Color(255,255,255,255)

                    local fadeTime = 0.4
                    local startTime = CurTime()

                    local fadeout = false
                    local onground = false
                    --uniqueIDuniqueID
                    ent:GetNW2Entity("GlowingBallThingy_OM"):SetNW2Float('sonic_glow_duration_white',CurTime()+0.5)
                    ent:GetNW2Entity("GlowingBallThingy_OM"):SetNW2Float("lilithoutine_ability_outline1", CurTime()+0.5)

                    hook.Add("Think", uniqueID, function()
                        if not IsValid(ballsonic) then
                            hook.Remove("Think", uniqueID)
                            return
                        end

                        if ent:GetNW2Float('Spindash_Duration') < CurTime() then

                            if not fadeout then
                                fadeout = true
                                startTime = CurTime()
                                puppetColor = ent:GetPuppet():GetColor()
                                ballColor = ballsonic:GetColor()
                                ballsonic:SetParent(nil)
                            end

                            local frac = math.Clamp((CurTime() - startTime) / fadeTime, 0, 1)

                            ent:GetPuppet():SetColor(Color(
                                puppetColor.r,
                                puppetColor.g,
                                puppetColor.b,
                                Lerp(frac, 0, 255)
                            ))

                            ballsonic:SetColor(Color(
                                ballColor.r,
                                ballColor.g,
                                ballColor.b,
                                Lerp(frac, 255, 0)
                            ))

                            if frac >= 1 then
                                hook.Remove("Think", uniqueID)
                                if IsValid(ballsonic) then
                                    ballsonic:Remove()
                                end
                            end
                            return
                        end
                        local elapsed = CurTime() - startTime
                        local ballAlpha = 0
                        
                        local fadeFrac = math.Clamp(elapsed / fadeDuration, 0, 1)
                        local puppetAlpha = 255 * (1 - fadeFrac)
                        ballAlpha = 255 * fadeFrac

                        ent:GetPuppet():SetRenderMode(RENDERMODE_TRANSALPHA)
                        ent:GetPuppet():SetColor(Color(255, 255, 255, puppetAlpha))

                        ballsonic:SetColor(Color(255, 255, 255, ballAlpha))

                        local mult
                        if elapsed >= 0.7 then
                            mult = 3
                        else
                            mult = 1 + (elapsed / 0.7) * 2
                        end

                        local ang = Angle(0, 0, CurTime() * 360 * mult)
                        ballsonic:ManipulateBoneAngles(0, ang)

                        if ballAlpha > 254 and not spindashl then
                            spindashl = true
                                
                        end

                    end)
                    
                    ent:SetNW2Float('spindashID',ent:GetNW2Float("spindashID")+1)
                    AdvancedPillSound(
                        {
                            stringe = "OM/eggman/eggman double jump.wav",
                            pitchPercent = 150,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end


            end

            if ent:GetNW2Float("Spindash_Duration") > CurTime() then
                ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                ent:SetNW2Bool('Spindashused',true)
                if not ent:GetNW2Bool("SpinDashToggle") then
                    ent:SetNW2Bool("SpinDashToggle", true)
                end

                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe3", CurTime()+0.2)
                
                if ply:IsPlayer() then
                    ply:SetNW2Float("OM_MoveForwardSpeed", GetConVar("OUTCOMEMEMORIES_N_Lilith_chargedash"):GetFloat())
                    if GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDash_slipperiness"):GetBool() then
                        ply:SetNW2Float("OM_MoveForward_WithSideways2",CurTime()+0.2)
                    else
                        ply:SetNW2Float("OM_MoveForward", CurTime() + 0.2)
                    end
                end


                local jumpscare_entity = nil
                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 90)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if not GetConVar('PVPStun_OM_exe'):GetBool() then
                        if ent2:GetNW2Bool("OM_character_monster") then continue end
                    end
                    if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if ent2:GetNW2Float("Fleetway_damage_dash"..ent:EntIndex(),0) < CurTime() then
                            ent2:SetNW2Float("Fleetway_damage_dash"..ent:EntIndex(),CurTime()+0.75)

                            if GetConVar('PVPStun_OM_clashing'):GetBool() then
                                if ent2.OM_ShouldClash then
                                    local variable = ent2.OM_ShouldClash()
                                    if variable then
                                        OM_Minigame(ply, ent2)
                                        break
                                    end
                                end
                            end
                            if not Mutal_OMCanDamage(ply,ent,ent2) then continue end

                            if not jumpscare_entity then
                                jumpscare_entity = ent2
                                ent:SetNW2Float("CurrentSpeed_dashnig",GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Speed"):GetInt())
                                ent:SetNW2Float("CurrentSpeed_dashnigSuppressed",ent:GetNW2Float("CurrentSpeed_dashnig"))
                            end

                            KillerdamagestunDynamic({
                                ply = ply,
                                target = ent2,
                                DamageNumb = GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashDamage"):GetFloat(),
                                damagetype = DMG_CLUB,
                                CustomDamageSound = nil,
                                damagesound = false,
                                ShouldBlood = true,
                                flingremoveal = false,
                                ShouldBloodEffect = true
                            })
                            AdvancedPillSound(
                                {
                                    stringe = "OM/lilith/ouch.wav",
                                    pitchPercent = 100,
                                    volume = 2,
                                    soundLevel = 87
                                },
                                ent
                            )
                        end
                    end
                end
            else
                if ent:GetNW2Bool('Spindashused') then
                    ent:SetNW2Float('Spindash_Cooldown',CurTime()+GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashCd"):GetFloat())
                    ent:SetNW2Bool('Spindashused',false)
                end
            end

            if ent:GetNW2Float("Lilith_teleport_duration") > CurTime() then
                if not ent.Lilith_teleport_duration_bool then
                    ent.Lilith_teleport_duration_bool = true
                end

                local lerpfactor = Lerp((ent:GetNW2Float("Lilith_teleport_duration")-CurTime())/0.75, 0, 1)

                ent:GetPuppet():SetRenderMode(RENDERMODE_TRANSALPHA)
                ent:GetPuppet():SetColor(Color(255, 255, 255, 255*lerpfactor))
                
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.75)
            else
                if ent.Lilith_teleport_duration_bool then
                    ent.Lilith_teleport_duration_bool = false
                    ent.teleportarea_lilith = false
                    ply:SetPos(ent.teleportarea_lilith_vector)
                    ent:SetNW2Bool("teleportarea_lilith_bool", false)
                    ply:SetLocalVelocity(Vector(0,0,0))

                    if ply:IsPlayer() then
                        net.Start("lilith_reverseindicate")
                            net.WriteEntity(ent)
                            net.WriteVector(ply:GetPos())
                            net.WriteAngle(ent:GetPuppet():GetAngles())
                        net.Send(ply)
                    elseif not ply:IsPlayer() and ply:IsPossessed() then
                        net.Start("lilith_reverseindicate")
                            net.WriteEntity(ent)
                            net.WriteVector(ply:GetPos())
                            net.WriteAngle(ent:GetPuppet():GetAngles())
                        net.Send(ply:GetPossessor())
                    end

                    ent:SetNW2Float("lilith_teleport_Cooldown", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage_cd_out"):GetFloat())
                    
                    ent:GetPuppet():SetRenderMode(RENDERMODE_TRANSALPHA)
                    ent:GetPuppet():SetColor(Color(255, 255, 255, 255))


                    local jumpscare_entity = nil
                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 600)) do
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if not GetConVar('PVPStun_OM_exe'):GetBool() then
                            if ent2:GetNW2Bool("OM_character_monster") then continue end
                        end
                        if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                            KillerdamagestunDynamic({
                                ply = ply,
                                target = ent2,
                                DamageNumb = GetConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage_damage"):GetFloat(),
                                damagetype = DMG_CLUB,
                                CustomDamageSound = nil,
                                damagesound = true,
                                ShouldBlood = true,
                                flingremoveal = true,
                                ShouldBloodEffect = true
                            })
                            ent2:SetNWFloat("om_daze", CurTime() + 5)
                            
                        end
                    end

                end
            end
        end
    end,


    noodles_OM_survivor_keybinds = function(ply, ent, button)
        if SERVER then
            if button == ply:GetInfoNum("om_pills_action_lilith_FalseImage", KEY_T) then
                if not GetConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage"):GetBool() then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return end
                if ent:GetNW2Bool('Spindashused') then return end

                if ent.blunttruama_bool then return end
                if ent:GetNW2Float("Lilith_blunttrruama_duration") > CurTime() then return end
                if ent:GetNW2Float("lilith_teleport_Cooldown") > CurTime() then return end
                if ent:GetNW2Float("Lilith_blunttrruama_chargeup") > CurTime() then return end
                if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() then return end
                if ent:GetNW2Float("Lilith_teleport_duration") > CurTime() then return end

                if not ent.teleportarea_lilith then

                    ent.teleportarea_lilith = true
                    ent.teleportarea_lilith_vector = ply:GetPos()
                    ent:SetNW2Bool("teleportarea_lilith_bool", true)
                    ent:SetNW2Vector("teleportarea_lilith_vector", ply:GetPos())

                    util.AddNetworkString("lilith_spawnpointspawndisplay")

                    if ply:IsPlayer() then
                        net.Start("lilith_spawnpointspawndisplay")
                            net.WriteEntity(ent)
                            net.WriteVector(ply:GetPos())
                            net.WriteAngle(ent:GetPuppet():GetAngles())
                        net.Send(ply)
                    elseif not ply:IsPlayer() and ply:IsPossessed() then
                        net.Start("lilith_spawnpointspawndisplay")
                            net.WriteEntity(ent)
                            net.WriteVector(ply:GetPos())
                            net.WriteAngle(ent:GetPuppet():GetAngles())
                        net.Send(ply:GetPossessor())
                    end
                    ent:SetNW2Float("lilith_teleport_Cooldown", CurTime()+GetConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage_cd_in"):GetFloat())
                else
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.75)
                    ent:SetNW2Float("Lilith_teleport_duration", CurTime()+0.75)
                end
            end

            if button == ply:GetInfoNum("om_pills_action_lilith_BluntTruama", KEY_R) then
                if not GetConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama"):GetBool() then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return end
                if ent:GetNW2Bool('Spindashused') then return end

                if ent.blunttruama_bool then return end
                if ent:GetNW2Float("Lilith_blunttrruama_duration") > CurTime() then return end
                if ent:GetNW2Float("Lilith_blunttrruama_chargeup") > CurTime() then return end
                if ent:GetNW2Float("BluntTruama_Cooldown") > CurTime() then return end
                
                if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() then return end
                if ent:GetNW2Float("Lilith_teleport_duration") > CurTime() then return end

                --if not ply:IsOnGround() then return end

                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+2)
                ply:SetLocalVelocity(Vector(0,0,0))
                ent:SetNW2Float("Lilith_blunttrruama_chargeup", CurTime()+1)

                local timername = "lilith_blunttruama_" .. ent:EntIndex()
                timer.Create(timername, 1, 1, function()
                    if !IsValid(ent) then return end
                    ent:SetNW2Float("Lilith_blunttrruama_duration", CurTime()+1)
                end)
                ent:SetNW2Float("Lilith_blunttrruama_duration_ability", CurTime()+2)

                ent:PillAnim("BluntTruama")

                ent:GetPuppet():SetNW2Float('lilith_green_glow_green',CurTime()+0.5*0.6)
                ent:GetPuppet():SetNW2Float("lilithoutine_ability_outline1", CurTime()+0.5*0.6)
            end

            if button == ply:GetInfoNum("om_pills_action_lilith_ChargeDash", KEY_E) then
                if not GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDash_canuse"):GetBool() then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("Spindash_Cooldown") > CurTime() then return end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return end
                if ent:GetNW2Bool('Spindashused') then return end

                if ent.blunttruama_bool then return end
                if ent:GetNW2Float("Lilith_blunttrruama_chargeup") > CurTime() then return end
                if ent:GetNW2Float("Lilith_blunttrruama_duration") > CurTime() then return end
                if ent:GetNW2Float("Lilith_teleport_duration") > CurTime() then return end

                if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() then return end
                
                --if not ply:IsOnGround() then return end
                
                ent:SetNW2Float("LilithChargeDash_windup", CurTime()+1.6)
                ent:SetNW2Float("LilithChargeDash_windup_charge", CurTime()+0.8)


                AdvancedPillSound(
                    {
                        stringe = "OM/lilith/spindash.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

            end
        end
    end,

    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)

            if ent:GetNW2Float("Spindash_Duration") > CurTime() then return end
            if ent:GetNW2Bool('Spindashused') then return end

            if ent.blunttruama_bool then return end
            if ent:GetNW2Float("Lilith_blunttrruama_chargeup") > CurTime() then return end
            if ent:GetNW2Float("Lilith_blunttrruama_duration") > CurTime() then return end
            if ent:GetNW2Float("Lilith_teleport_duration") > CurTime() then return end

            if ent:GetNW2Float("LilithChargeDash_windup") > CurTime() then return end

            if SERVER then
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                
                local puppet = ent:GetPuppet()
                if not IsValid(puppet) then return end
                    
                local layeredAnim
                if math.random(1,2) == 1 then
                    layeredAnim = puppet:AddGesture(ACT_MELEE_ATTACK_SWING_GESTURE, false)
                else
                    layeredAnim = puppet:AddGesture(ACT_GESTURE_BIG_FLINCH, false)
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

                timer.Simple(0.15, fadeLayer)

                timer.Simple(0.9,function()
                    if !IsValid(ent) then return end
                    puppet:RemoveLayer(layeredAnim)
                end)

                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1)
                    
                AdvancedPillSound(
                    {
                        stringe = "OM/lilith/Hit.wav",
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
        --[[
        if SERVER then
            ent:PillAnim('jump2')
        end
        ]]
        if ent:GetNW2Float("LilithChargeDash_windup_charge") > CurTime() then return end
        
        ent:SetNW2Float("jumpanim", CurTime() + 0.8)

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



