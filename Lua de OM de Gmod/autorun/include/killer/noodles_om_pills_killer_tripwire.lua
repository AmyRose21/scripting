
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

-- tripwire mouse handeler
if SERVER then
    util.AddNetworkString("Tripwire_recieve_mouse")
    util.AddNetworkString("Tripwire_retrieve_mouse")

    net.Receive("Tripwire_recieve_mouse", function()
        local ply = net.ReadEntity()
        local hitPos = net.ReadVector()

        local pillentity = ply.pk_pill_ent
        
        if IsValid(pillentity) then
            if pillentity.formTable.SpawnMine then
                pillentity.formTable.SpawnMine(ply, pillentity, hitPos)
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
    net.Receive("Tripwire_retrieve_mouse", function()
        local ply = LocalPlayer()

        net.Start("Tripwire_recieve_mouse")
            net.WriteEntity(ply)
            net.WriteVector(GetTrueMouseHitPos(ply))
        net.SendToServer()
    end)
end

local preservedmats = {
    ["brighterray"] = Material("icons/brighter ray tripwire.png"),
    ["reachout"] = Material("icons/reachout tripwire.png"),
    ["STEP"] = Material("icons/STEP tripwire.png"),
    ["Tripwirelandminebar"] = Material("icons/Tripwire landmine bar.png"),
    ["tripwire sonar arrow"] = Material("icons/tripwire sonar arrow.png"),
    

}

pk_pills.register('pill_om_tripwire', {

    printName='Tripwire',
    Outcomememories='Tripwire',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/tripwire.mdl",

    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',

    anims={
        default={
            idle="idle",
            run="run",
            walk="run",
            jump2 = "jump",
            glide = "fall",
            LaserExplode="LaserExplode",
            RopeLaunchStart = "RopeLaunchStart",
            RopeLaunchEnd="RopeLaunchEnd",
            RopeRetracEnd="RopeRetracEnd",
        },
        ShouldMoveRotate={
            idle= function(ent) 
                if ent:GetNW2Float("SpawnDynomiteDuration") > CurTime() then
                    return "assignedagnles"
                end
                if ent:GetNWFloat("LaserShootDuration") > CurTime() or ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            run= function(ent) 
                if ent:GetNW2Float("SpawnDynomiteDuration") > CurTime() then
                    return "assignedagnles"
                end
                if ent:GetNWFloat("LaserShootDuration") > CurTime() or ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            fall= function(ent) 
                if ent:GetNW2Float("SpawnDynomiteDuration") > CurTime() then
                    return "assignedagnles"
                end
                if ent:GetNWFloat("LaserShootDuration") > CurTime() or ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
                    return "shiftlock"
                end
                return "notshftlock"
            end,
            jump= function(ent) 
                if ent:GetNW2Float("SpawnDynomiteDuration") > CurTime() then
                    return "assignedagnles"
                end
                if ent:GetNWFloat("LaserShootDuration") > CurTime() or ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
                    return "shiftlock"
                end
                return 'notshftlock'
            end,

            LaserExplode= function(ent) 
                if ent:GetNWFloat("LaserShootDuration") > CurTime() or ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
                    return "shiftlock"
                end
            end,
        },

        ShouldAlternate={
            idle= function(ent) 
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stun"
                end
                if ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
                    return "LaserCharge"
                end
                if ent:GetNWFloat("LaserShootDuration") > CurTime() then
                    return "LaserIdle"
                end
                if ent:GetNW2Float("TripwireReachOut") > CurTime() then
                    return "RopeLaunchIdle"
                end
                if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then
                    return "RopeRetractIdle"
                end
            end,
            run= function(ent) 
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stun"
                end
                if ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
                    return "LaserCharge"
                end
                if ent:GetNWFloat("LaserShootDuration") > CurTime() then
                    return "LaserIdle"
                end
                if ent:GetNW2Float("TripwireReachOut") > CurTime() then
                    return "RopeLaunchIdle"
                end
                if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then
                    return "RopeRetractIdle"
                end
            end,
            jump= function(ent)
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stun"
                end 
                if ent:GetNW2Float("TripwireReachOut") > CurTime() then
                    return "RopeLaunchIdle"
                end
                if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then
                    return "RopeRetractIdle"
                end
            end,
            fall =function(ent) 
                local ply = ent:GetPillUser()
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "stun"
                end
                if ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
                    return "LaserCharge"
                end
                if ent:GetNWFloat("LaserShootDuration") > CurTime() then
                    return "LaserIdle"
                end
                if ent:GetNW2Float("TripwireReachOut") > CurTime() then
                    return "RopeLaunchIdle"
                end
                if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then
                    return "RopeRetractIdle"
                end
                if ent:GetNW2Bool("jetpackglide_holding") then
                    return "glide"
                end
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

        if ent:GetNWFloat("LaserShootDuration") > CurTime() then
            basetable =  {
                startoffset = Vector(35,0,50),  -- left-up, front-back, up-down
                dist=35,
                fov = 90,
                id = 1,
                transition = 1,
                canscroll = true,
            }
        end

        return basetable
    end,

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return 230
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return 500
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return 230
                end
            end,
            charging= function(ply,ent)
                if SERVER then
                    return 1400
                end
            end,
            jumppower= function(ply,ent) --jumppowerjumppower
                if SERVER then
                    return 300
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return 1
                end
            end,
        }
    },


    OM_UI_custom_start = function(ply, ent)
        -- bomb bar
        local screenW, screenH = ScrW(), ScrH()
        local middlex, middley = screenW * 0.5, screenH * 0.5
        local iconsize = screenW / 13

        local yaxis_health_bg = iconsize * 2.5--screenH - iconsize * 4
        local textureW, textureH = iconsize*4.5*1.2, iconsize*2*1

        local mat = Matrix()
        mat:Translate(Vector(iconsize*1.75, yaxis_health_bg, 0))
        mat:Rotate(Angle(0, 90, 0))
        mat:Translate(Vector(-textureW/2, 0, 0))

        local bombcount = ent:GetNW2Float("tripwire_bomb_count")
        local targetFactor = math.Clamp(bombcount / 10, 0, 1)

        if not ent.OM_UI_LerpedFactor then ent.OM_UI_LerpedFactor = 0 end
        ent.OM_UI_LerpedFactor = Lerp(FrameTime() * 5, ent.OM_UI_LerpedFactor, targetFactor)
        local factor = ent.OM_UI_LerpedFactor

        cam.PushModelMatrix(mat)
            surface.SetDrawColor(35, 0, 0, 255)
            surface.DrawRect(iconsize*0.81, iconsize*0.93, iconsize*3.75, iconsize*0.52)

            local xlerp = Lerp(factor, iconsize*0.81, iconsize*0.81+iconsize*3.75)
            local xsize = Lerp(factor, iconsize*3.75, 0)
            surface.SetDrawColor(255, 0, 0, 255)
            surface.DrawRect(xlerp, iconsize*0.93, xsize, iconsize*0.52)

            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(preservedmats["Tripwirelandminebar"])
            surface.DrawTexturedRect(0, 0, textureW, textureH)
        cam.PopModelMatrix()

        yaxis_health_bg = yaxis_health_bg - iconsize * 0.3
        draw.SimpleTextOutlined(10, "OM_Subtitle_Larger",  iconsize*1.25, yaxis_health_bg, Color(255,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 6, Color(0,0,0))

        yaxis_health_bg = yaxis_health_bg + iconsize * 0.6
        draw.SimpleTextOutlined(bombcount, "OM_Subtitle_Larger",  iconsize*1.25, yaxis_health_bg, Color(255,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 6, Color(0,0,0))
        
        local RANGE = 6000

        local function GetNearestEntity(ply)
            local plyPos = ply:GetPos()
            local nearest
            local nearestDist = RANGE * RANGE

            for _, ent2 in ipairs(ents.GetAll()) do
                if not IsValid(ent2) then continue end
                if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) then
                    if ent2 == ply then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                    if ent2:Health() < 0.1 then continue end
                    if not ent:GetNWBool("OM_exe_pvp") then if ent2:GetNW2Bool("OM_character_monster") then continue end end

                    local pos = ent2:GetPos()
                    local dist = plyPos:DistToSqr(pos)

                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = ent2
                    end
                end
            end

            return nearest
        end

        if not ent.sonarcd then ent.sonarcd = CurTime() + 1 end
        if not ent.sonarShowDur then ent.sonarShowDur = 0 end
        if not ent.sonaralpha then ent.sonaralpha = 0 end

        if ent.sonarcd < CurTime() then
            ent.sonarcd = CurTime() + 2
            ent.sonarShowDur = CurTime() + 0.5
        end

        if ent.sonarShowDur > CurTime() then
            ent.sonaralpha = math.Clamp( Lerp(FrameTime() * 15, ent.sonaralpha, 255), 0, 255 )
        else
            ent.sonaralpha = math.Clamp( Lerp(FrameTime() * 6.5, ent.sonaralpha, 0), 0, 255 )
        end

        if ent.sonaralpha > 1 then
            local target = GetNearestEntity(ply)
            if IsValid(target) then
                if not ent.playedsonarsound then
                    ent.playedsonarsound = true
                    surface.PlaySound("OM/tripwire/sonar beep.wav")
                end

                local starpos = ent:GetPuppet():GetPos()+ent:GetPuppet():GetUp()*50
                local dir = ((target:GetPos()+target:GetUp()*50) - starpos):GetNormalized()

                local ang = ply:EyeAngles()
                local forward = ang:Forward()
                local right = ang:Right()

                local x = dir:Dot(right)
                local y = dir:Dot(forward)

                local angle = math.deg(math.atan2(x, y))

                local screenPos = (starpos + dir *50):ToScreen()

                local size = 128

                surface.SetDrawColor(255, 255, 255, ent.sonaralpha)
                surface.SetMaterial(preservedmats["tripwire sonar arrow"])
                surface.DrawTexturedRectRotated(screenPos.x, screenPos.y, size, size, -angle)
                
                target.tripwirehighlight_0 = ent.sonarShowDur
            else
                if ent.playedsonarsound then
                    ent.playedsonarsound = false
                end
            end
        else
            if ent.playedsonarsound then
                ent.playedsonarsound = false
            end
        end

    end,

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["brighterray"]
            end,
            name = function(uselessvar,ply,ent)
                return "Laser"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_F
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("tripwire_laser_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 25
            end,
            survivor = false,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["reachout"]
            end,
            name = function(uselessvar,ply,ent)
                return "Reach Out"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_R
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("tripwire_rope_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 24
            end,
            survivor = false,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return true
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["STEP"]
            end,
            name = function(uselessvar,ply,ent)
                return "S.T.E.P."
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = KEY_T
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("tripwire_step_cd")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return 5
            end,
            survivor = false,
            font = "CreditsText",
        },
    },

    jumpPower=400,
       
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
            local factor = ( 1+ent:GetNW2Float("OM_SpeedBoost_Damage"))
            ply:SetWalkSpeed(Currentwalkspeed * factor )
            ply:SetRunSpeed(Currentrunspeed * factor )
            ply:SetCrouchedWalkSpeed(Currentcrouchspeed * factor )
            ply:SetJumpPower(Currentjump )
        end,
        modifiers = {
            ['Function1'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNWFloat("LaserShootDuration") > CurTime() or ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
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

        if event == "Attack" then
            if SERVER then
                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50))+ent:GetPuppet():GetForward()*40, 140)) do
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if not GetConVar('PVPStun_OM_exe'):GetBool() then
                            if ent2:GetNW2Bool("OM_character_monster") then return end
                        end
                        if IsValid(ent2) then
                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                            if not Mutal_OMCanDamage(ply,ent,ent2) then continue end

                            damagestun(ply, ent2, 25, DMG_CLUB, true)
                            hitent = ent2
                            break
                        end
                    end
                end
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_killer_om(initializetable2["entity"])
        if SERVER then
            initializetable2["entity"]:SetNW2Float('OM_friction', 1)
            initializetable2["player"]:SetHealth(400)
            initializetable2["player"]:SetMaxHealth(400)
            --initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",400)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",400)

            initializetable2["player"]:SetNW2Bool("OM_character_monster", true)
            initializetable2["entity"]:SetNWBool("OM_tripwire_pill", true)

            initializetable2["player"]:SetNW2String("TerrorRadius_om","OM/music/Tripwire_radius.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life1_om","OM/music/tailsdollfirstlife.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life2_om","OM/music/tripwirelastlife.wav")

            initializetable2["player"].CustomFunctionForDowning_OM = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if IsValid(initializetable2["entity"]) then
                    timer.Simple(0.15,function()
                        if !IsValid(initializetable2["entity"]) then return end
                        AdvancedPillSound(
                            {
                                stringe = {
                                    "OM/tripwire/Tripwire_downline1.wav",
                                    "OM/tripwire/Tripwire_downline2.wav",
                                    "OM/tripwire/Tripwire_downline3.wav"
                                },
                                pitchPercent = 100,
                                volume = 3,
                                soundLevel = 87
                            },
                            initializetable2["entity"]
                        )
                    end)
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
                            "OM/tripwire/Tripwire_stun1.wav",
                            "OM/tripwire/Tripwire_stun2.wav",
                            "OM/tripwire/Tripwire_stun3.wav"
                        },
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                if ent:GetNWFloat("LaserShootDuration") > CurTime() then 
                    ent:SetNWFloat("LaserShootDuration", 0)
                    ent:SetNW2Bool("Lasershoot_bool", false)
                    ent:SetNW2Float("tripwire_laser_cd", CurTime()+25)
                end
                if ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
                    ent:SetNW2Float("LaserLoadDuration", 0)
                    ent:SetNW2Bool("LaserLoad_bool", false)
                    ent:SetNW2Float("tripwire_laser_cd", CurTime()+25)
                end

                if ent:GetNW2Float("SpawnDynomiteDuration") > CurTime() then
                    ent:SetNW2Float("SpawnDynomiteDuration", 0)
                    ent:SetNW2Bool("SpawnDynomite_bool", false)
                    ent:SetNW2Float("tripwire_step_cd", CurTime() + 15)
                    if ply:IsPlayer() then
                        ply:SetMoveType(2)
                    else
                        --ply:SetMoveType(0)
                    end
                end
                if ent:GetNW2Float("TripwireReachOut") > CurTime() then 
                    ent:SetNW2Float("TripwireReachOut", 0)
                    ent:SetNW2Bool("TripwireReachOutBool", false)
                    ent:SetNW2Float("tripwire_rope_cd", CurTime()+5)
                end
                if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then 
                    ent:SetNW2Float("Tripwire_RopeDuration", 0)
                    ent.tripwire_ropetoggle = false
                    ent:SetNW2Float("tripwire_rope_cd", CurTime()+30)
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
            OM_PILL_speedThink(ply, ent)
            ply:SetNW2Float("DamageResistance_OM_2", 1)
            if ply:IsOnGround() then
                ent:SetNW2Bool("JetpackJump", false)
                ent:SetNW2Bool("jetpackglide", false)
                ent:SetNW2Bool("jetpackglide_holding", false)
            end

            ent:SetNWBool("OM_exe_pvp", GetConVar('PVPStun_OM_exe'):GetBool())

            if ent:GetNW2Float("TripwireReachOut") > CurTime() then 
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.1)
                if not ent:GetNW2Bool("TripwireReachOutBool") then 
                    ent:SetNW2Bool("TripwireReachOutBool", true)
                end
                ent:GetPuppet():SetNW2Float("Tripwire_Rope_tangle", CurTime()+0.1)
            else
                if ent:GetNW2Bool("TripwireReachOutBool") then 
                    if ent.PillAnim then
                        ent:PillAnim("RopeLaunchEnd")
                    end
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+1.75)
                    ent:SetNW2Bool("TripwireReachOutBool", false)
                    AdvancedPillSound(
                        {
                            stringe = "OM/tripwire/splat.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    local shouldstartability = {}

                    for _, ent2 in pairs(ents.FindInSphere(ply:GetPos(), 800)) do
                        if ent2 == ply then continue end
                        if not IsValid(ent2) then continue end

                        local validTarget = false

                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                            if not GetConVar('PVPStun_OM_exe'):GetBool() then
                                if ent2:GetNW2Bool("OM_character_monster") then return end
                            end

                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                            if not Mutal_OMCanDamage(ply, ent, ent2) then continue end
                            local trace = util.TraceLine({start = ent:GetPos()+Vector(0,0,30), endpos = ent2:GetPos()+Vector(0,0,30), filter = {ent2, ply}, mask = MASK_VISIBLE})

                            if trace.Hit then continue end
                            validTarget = true
                        end

                        if not validTarget then continue end
                        table.insert(shouldstartability, ent2)

                        AdvancedPillSound(
                            {
                                stringe = "OM/tripwire/Reachout catch.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent2
                        )

                    end

                    if #shouldstartability > 0 then
                        for i,v in ipairs(shouldstartability) do
                            ent:SetNW2Entity("RopeEntity_om_tripwire_".. i, v)
                        end
                        ent:SetNW2Float("AmountsOfEnemies_Rope_om_tripwire", #shouldstartability)
                        ent:SetNW2Float("Tripwire_RopeDuration", CurTime()+5)
                    else
                        ent:SetNW2Float("tripwire_rope_cd", CurTime() + 5)
                    end
                end
            end

            if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then
                if not ent.tripwire_ropetoggle then
                    ent.tripwire_ropetoggle = true
                end
                for i=1, ent:GetNW2Float("AmountsOfEnemies_Rope_om_tripwire") do
                    local trappedentity = ent:GetNW2Entity("RopeEntity_om_tripwire_" .. i)
                    if !IsValid(trappedentity) then continue end
                    if trappedentity:Health() <= 0.1 then
                        ent:SetNW2Entity("RopeEntity_om_tripwire_" .. i, NULL)
                        continue
                    end

                    local entPos = ent:GetPos()
                    local trappedPos = trappedentity:GetPos()

                    local dir = (entPos - trappedPos)
                    local dist = dir:Length()
                    dir:Normalize()

                    if trappedentity:IsPlayer() or trappedentity:IsNPC() or trappedentity:IsNextBot() then
                        if ent:GetPos():Distance(trappedentity:GetPos()) > 60 then
                            if (trappedentity:IsNPC() or trappedentity:IsNextBot()) and trappedentity:IsOnGround() then
                                trappedentity:SetPos(trappedentity:GetPos() + Vector(0,0,1)*trappedentity:GetStepHeight())
                            end

                            local radius = 450
                            local excess = math.max(dist - radius, 0)

                            local strength = 100 + (excess * 6)

                            strength = math.Clamp(strength, 100, 2500)

                            local vel = dir * strength

                            trappedentity:SetVelocity(vel)
                            trappedentity:SetLocalVelocity(vel)
                        end
                    end

                    if not trappedentity["Tripwire_RopeDamageSoundCD"..ent:EntIndex()] then
                        trappedentity["Tripwire_RopeDamageSoundCD"..ent:EntIndex()] = 0
                    end

                    if trappedentity["Tripwire_RopeDamageSoundCD"..ent:EntIndex()] < CurTime() then
                        trappedentity["Tripwire_RopeDamageSoundCD"..ent:EntIndex()] = CurTime() + 0.5
                        if ent:GetPos():Distance(trappedentity:GetPos()) < 60 then
                            trappedentity["Tripwire_RopeDamageSoundCD"..ent:EntIndex()] = CurTime() + 0.25
                        end
                        AdvancedPillSound(
                            {
                                stringe = "OM/tripwire/pow.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            trappedentity
                        )

                        AdvancedPillSound(
                            {
                                stringe = {"OM/tripwire/slap.wav", "OM/tripwire/slap 2.wav"},
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            trappedentity
                        )

                        damagestun(ply, trappedentity, 2, DMG_BLAST, true)
                    end
                end

                if ent:GetNW2Float("Tripwire_RopeDamageCD") > CurTime() then
                else
                    ent:SetNW2Float("Tripwire_RopeDamageCD", CurTime()+0.25)
                end
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.1)
            else
                if ent.tripwire_ropetoggle then
                    ent.tripwire_ropetoggle = false
                    if ent.PillAnim then
                        ent:PillAnim("RopeRetracEnd")
                    end
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+1.75)
                    ent:SetNW2Float("tripwire_rope_cd", CurTime() + 30)
                end
            end
            local canmove = true

            if ent:GetNW2Float("OM_NoMovement_noodles") > CurTime() then canmove = false end
            if ent:GetNW2Float("TripwireReachOut") > CurTime() then canmove = false end
            if ent:GetNW2Bool("TripwireReachOutBool") then canmove = false end
            if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then canmove = false end
            if ent.tripwire_ropetoggle then canmove = false end

            if not ent.Tripwire_glide_lerp then
                ent.Tripwire_glide_lerp = 0
            end

            if ent:GetNW2Bool("jetpackglide_holding") and canmove then
                local speed
                
                if ply:KeyDown(IN_SPEED) then
                    speed = ply:GetRunSpeed() * 1.5
                else
                    speed = ply:GetWalkSpeed()
                end

                local vel = ply:GetVelocity()
                local velo = ent:GetPuppet():GetUp()* -55
                local forward = ply:GetForward()*speed
                local side = ply:GetRight()*0

                if ply:KeyDown(IN_MOVELEFT) then
                    side = ply:GetRight()*-speed
                elseif ply:KeyDown(IN_MOVERIGHT) then
                    side = ply:GetRight()*speed
                end

                if ply:KeyDown(IN_MOVERIGHT) and ply:KeyDown(IN_MOVELEFT) then
                    side = ply:GetRight()*0
                end


                ent.Tripwire_glide_lerp = Lerp(FrameTime() * 0.85, ent.Tripwire_glide_lerp, 1)

                local lerping = Lerp(ent.Tripwire_glide_lerp, vel, (velo + forward + side))
                ply:SetLocalVelocity(lerping)

                
                ply:SetGravity(0.4)
            else
                ent.Tripwire_glide_lerp = Lerp(FrameTime() * 8, ent.Tripwire_glide_lerp, 0)
                --jumppowerjumppower
                ply:SetGravity(0.4)
            end

            if ent:GetNWFloat("LaserShootDuration") > CurTime() then 
                if not ent:GetNW2Bool("Lasershoot_bool") then
                    ent:SetNW2Bool("Lasershoot_bool", true)
                end

                local startPos = ply:GetShootPos()
                local endPos = startPos + ply:GetAimVector() * 20000
                    
                local tr = util.TraceHull({
                    start = startPos,
                    endpos = endPos,
                    mins = Vector(-9, -9, -9),
                    maxs = Vector(9, 9 ,9),

                    filter = function(hitent)
                        if hitent == ply then return false end
                        if hitent:GetNW2Bool("Tripwire_laser") then return false end
                        return true
                    end,

                    mask = MASK_SHOT
                })

                local hitpos = tr.HitPos
                ent:SetNW2Vector("Position1", hitpos)
                local puppetangle = ent:GetPuppet():GetAngles()
                ent:SetNWEntity("Position2Entity", ent:GetPuppet())
                ent:SetNW2Vector("Position2", ent:GetPos() + puppetangle:Up()*50 + puppetangle:Forward()*30)

                local hits = ents.FindAlongRay(
                    startPos,
                    tr.HitPos,
                    Vector(-9, -9, -9),
                    Vector(9, 9, 9)
                )

                for _, ent2 in pairs(hits) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if ent2 == ply then continue end
                    if not GetConVar('PVPStun_OM_exe'):GetBool() then
                        if ent2:GetNW2Bool("OM_character_monster") then continue end
                    end
                    if not Mutal_OMCanDamage(ply,ent,ent2) then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                    if ent2:IsNextBot() or ent2:IsNPC() or ent2:IsPlayer() then else continue end
                    if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                            
                    if ent2:GetNW2Float("lasercooldownimpact_fleetway") > CurTime() then
                    else
                        ent2:SetNW2Float("lasercooldownimpact_fleetway", CurTime()+ 0.15)
                        ent2:SetNW2Float("OM_Damage_ReductionRemoveal", CurTime()+0.1)
                        Killerdamagestun(ply, ent2, 8, DMG_ENERGYBEAM, true)                        


                        ent2:SetNW2Float("Fleetway_LaserHitCooldown", CurTime()+1) 
                        AdvancedPillSound(
                            {
                                stringe = "OM/laserhit.wav",
                                pitchPercent = 100,
                                volume = 2,
                                soundLevel = 100
                            },
                            ent2
                        )
                        AdvancedPillSound(
                            {
                                stringe = "OM/laserhit.wav",
                                pitchPercent = 100,
                                volume = 2,
                                soundLevel = 100
                            },
                            ent
                        )

                        ent:SetNW2Float("OM_LaserDuration_last", CurTime()+1.35)
                    end
                end


                if ent:GetNW2Float("SpawnEletricity_cd") > CurTime() then
                else
                    ent:SetNW2Float("SpawnEletricity_cd", CurTime() + 0.15) 
                    local Bomb = ents.Create("prop_dynamic")

                    if IsValid(Bomb) then
                        Bomb:SetModel("models/hunter/misc/sphere2x2.mdl")
                        Bomb:SetPos(hitpos + tr.HitNormal*5)
                        Bomb:SetAngles(Angle(0,0,0))
                        Bomb:Spawn()
                        Bomb:Activate()
                        Bomb:SetNW2Bool("Tripwire_laser", true)

                        local phys = Bomb:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:EnableMotion(false)
                            phys:Sleep()
                        end

                        Bomb:SetCollisionGroup(COLLISION_GROUP_WORLD)

                        Bomb:SetRenderMode(RENDERMODE_TRANSCOLOR)
                        Bomb:SetColor(Color(255,255,255,0))
                            
                        ent:DeleteOnRemove(Bomb)

                        local effectdata = EffectData()
                        effectdata:SetEntity(Bomb)
                        util.Effect("tripwire_eletricity_linger", effectdata)
                        
                        timer.Simple(13,function()
                            if !IsValid(Bomb) then return end
                            Bomb:Remove()
                        end)

                        local hookID = "EletricityHurt" .. Bomb:EntIndex()

                        local entityhitcd = {

                        }
                        local cd = CurTime()
                        hook.Add("Tick", hookID, function()
                            if !IsValid(Bomb) then
                                hook.Remove("Think", hookID)
                                return
                            end
                            if !IsValid(ent) then
                                hook.Remove("Think", hookID)
                                return
                            end
                            if cd >= CurTime() then return end
                            cd = CurTime()+0.1

                            for _, ent2 in pairs(ents.FindInSphere(Bomb:GetPos(), 120)) do -- LaserShootDuration
                                if ent2 == ply then continue end
                                if not IsValid(ent2) then continue end

                                local validTarget = false

                                if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() > 0 then
                                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                    if not GetConVar('PVPStun_OM_exe'):GetBool() then
                                        if ent2:GetNW2Bool("OM_character_monster") then return end
                                    end

                                    if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                                    if not Mutal_OMCanDamage(ply, ent, ent2) then continue end
                                    validTarget = true
                                end

                                if not validTarget then continue end

                                if entityhitcd[ent2] then
                                    if entityhitcd[ent2] > CurTime() then continue end
                                end
                                
                                entityhitcd[ent2] = CurTime()+0.2


                                damagestun(ply, ent2, 1, DMG_SHOCK, true)
                            end
                        end)
                    end
                end
            else

                if ent:GetNW2Bool("Lasershoot_bool") then
                    ent:SetNW2Bool("Lasershoot_bool", false)
                    ent:SetNW2Float("tripwire_laser_cd", CurTime()+25)
                end
            end

            if ent:GetNW2Float("LaserLoadDuration") > CurTime() then 
                if not ent:GetNW2Bool("LaserLoad_bool") then
                    ent:SetNW2Bool("LaserLoad_bool", true)
                end
            else
                if ent:GetNW2Bool("LaserLoad_bool") then
                    if ent.PillAnim then
                        ent:PillAnim("LaserExplode")
                    end
                    local ed = EffectData()
                    ed:SetOrigin(ent:GetPos()+Vector(0,0,50)+ ent:GetPuppet():GetForward()*30)
                    util.Effect("Tripwire_emit_laserstart", ed)
                    AdvancedPillSound(
                        {
                            stringe = "OM/tripwire/LaserShoot.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    ent:SetNWFloat("LaserShootDuration", CurTime() + 5)
                    ent:SetNW2Bool("LaserLoad_bool", false)

                    local snd = CreateSound(ent, "OM/tripwire/LASER TRIP.wav")
                    snd:SetSoundLevel(87)
                    snd:PlayEx(1, 350)

                    local fadeTime = 0.75
                    local hookID = "HealLoopFade_" .. ent:EntIndex()

                    local fadingOut = false
                    local fadeOutStart = 0

                    ent:CallOnRemove("StopLaserSound", function()
                        if snd then
                            snd:Stop()
                        end
                    end)

                    hook.Add("Think", hookID, function()
                        if not IsValid(ent) then
                            if snd then snd:Stop() end
                            hook.Remove("Think", hookID)
                            return
                        end

                        local curTime = CurTime()
                        local endTime = ent:GetNWFloat("LaserShootDuration", 0)

                        if not fadingOut and curTime >= endTime then
                            fadingOut = true
                            fadeOutStart = curTime
                        end

                        if fadingOut then
                            local delta = math.Clamp((curTime - fadeOutStart) / fadeTime, 0, 1)
                            snd:ChangeVolume(1 - delta, 0)

                            if delta >= 1 then
                                snd:Stop()
                                hook.Remove("Think", hookID)
                            end
                        end
                    end)
                end
            end

            if ent:GetNW2Float("SpawnDynomiteDuration") > CurTime() then
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime()+0.1)

                local angl = (ent:GetNW2Vector("SpawnPropPos")-ent:GetPos()):Angle()
                ent:SetNW2Angle("pill_assignedangle", angl )
                ent:SetNWEntity("Position2Entity", ent:GetPuppet())
                if not ent:GetNW2Bool("SpawnDynomite_bool") then
                    ent:SetNW2Bool("SpawnDynomite_bool", true)
                end
            else
                if ent:GetNW2Bool("SpawnDynomite_bool") then

                    ent:SetNW2Float("tripwire_step_cd", CurTime() + 5)

                    if ply:IsPlayer() then
                        ply:SetMoveType(2)
                    else
                        --ply:SetMoveType(0)
                    end
                    ent:SetNW2Bool("SpawnDynomite_bool", false)

                    local Bomb = ents.Create("prop_physics")
                    if IsValid(Bomb) then

                        AdvancedPillSound(
                            {
                                stringe = "OM/tripwire/mine place.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        Bomb:SetModel("models/hunter/tubes/circle2x2.mdl")
                        Bomb:SetPos(ent:GetNW2Vector("SpawnPropPos"))
                        Bomb:SetAngles(ent:GetNW2Angle("SpawnPropAng"))
                        Bomb:Spawn()
                        Bomb:Activate()

                        ent:SetNW2Float("tripwire_bomb_count", ent:GetNW2Float("tripwire_bomb_count")+1)

                        local phys = Bomb:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:EnableMotion(false)
                            phys:Sleep()
                        end

                        Bomb:SetCollisionGroup(COLLISION_GROUP_WORLD)
                        Bomb:ManipulateBoneScale(0,Vector(0.15,0.15,1.5))
                        ent:DeleteOnRemove(Bomb)

                        local prop = ents.Create("prop_physics")
                        prop:SetModel("models/hunter/misc/shell2x2.mdl")
                        prop:SetPos(ent:GetNW2Vector("SpawnPropPos"))
                        prop:SetAngles(ent:GetNW2Angle("SpawnPropAng"))
                        prop:Spawn()

                        prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
                        prop:SetMaterial("Models/effects/comball_tape")
                        prop.tripwirebomb = true

                        Bomb:DeleteOnRemove(prop)

                        local phys = prop:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:EnableMotion(false)
                            phys:Sleep()
                        end

                        local targetColor = Color(255, 0, 0, 164)
                        local targetAlpha = targetColor.a

                        prop:SetRenderMode(RENDERMODE_TRANSCOLOR)
                        prop:SetColor(Color(255, 0, 0, 0))

                        local duration = 1
                        local startTime = CurTime()
                        
                        prop:SetModelScale(0, 0)

                        local duration = 0.35
                        local startTime = CurTime()
                        local endTime = startTime + duration

                        timer.Create("ScaleUp_" .. prop:EntIndex(), 0, 0, function()
                            if not IsValid(prop) then
                                timer.Remove("ScaleUp_" .. prop:EntIndex())
                                return
                            end

                            local t = math.Clamp((CurTime() - startTime) / duration, 0, 1)
                            local scale = Lerp(t, 0, 1)

                            prop:SetModelScale(scale, 0)

                            if t >= 1 then
                                timer.Remove("ScaleUp_" .. prop:EntIndex())
                            end
                        end)

                        timer.Create("Fade_" .. prop:EntIndex(), 0, 0, function()
                            if not IsValid(prop) then
                                timer.Remove("Fade_" .. prop:EntIndex())
                                return
                            end

                            local t = math.Clamp((CurTime() - startTime) / duration, 0, 1)

                            local alpha = Lerp(t, 255, targetAlpha)

                            local c = prop:GetColor()
                            c.a = alpha
                            prop:SetColor(c)

                            if t >= 1 then
                                timer.Remove("Fade_" .. prop:EntIndex())
                            end
                        end)
                        
                        local trapped = false
                        local trappedentity = NULL
                        local hookID = "RingRiseThink_" .. Bomb:EntIndex()

                        hook.Add("Think", hookID, function()
                            if !IsValid(prop) then
                                if IsValid(ent) then
                                    ent:SetNW2Float("tripwire_bomb_count", ent:GetNW2Float("tripwire_bomb_count")-1)
                                end
                                hook.Remove("Think", hookID)
                                return
                            end
                            
                            if IsValid(trappedentity) then
                                local dir = (Bomb:GetPos() - trappedentity:GetPos())
                                local dist = dir:Length()
                                dir:Normalize()

                                if trappedentity:IsPlayer() or trappedentity:IsNPC() or trappedentity:IsNextBot() then
                                    
                                    if (trappedentity:IsNPC() or trappedentity:IsNextBot()) and trappedentity:IsOnGround() then
                                        trappedentity:SetPos(trappedentity:GetPos() + Vector(0,0,30))
                                    end

                                    trappedentity:SetVelocity(dir * 400)
                                    trappedentity:SetLocalVelocity(dir * 400)
                                end

                                if trappedentity:GetMoveType() == MOVETYPE_VPHYSICS then
                                    local phys = trappedentity:GetPhysicsObject()
                                    if IsValid(phys) and phys:IsMotionEnabled() then
                                        phys:Wake()
                                        phys:ApplyForceCenter(dir * 8000)
                                    end
                                end
                            end

                            if trapped then return end
                            for _, ent2 in pairs(ents.FindInSphere(Bomb:GetPos(), 90)) do
                                if ent2 == ply then continue end
                                if not IsValid(ent2) then continue end
                                if ent2.tripwirebomb then continue end

                                local validTarget = false

                                if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                    if not GetConVar('PVPStun_OM_exe'):GetBool() then
                                        if ent2:GetNW2Bool("OM_character_monster") then return end
                                    end

                                    if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                                    if not Mutal_OMCanDamage(ply, ent, ent2) then continue end
                                    validTarget = true
                                end

                                if not validTarget then
                                    if ent2:GetMoveType() == MOVETYPE_VPHYSICS then
                                        local phys = ent2:GetPhysicsObject()
                                        if IsValid(phys) and phys:IsMotionEnabled() then
                                            validTarget = true
                                        end
                                    end
                                end

                                if not validTarget then continue end

                                trappedentity = ent2

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/tripwire/minedetect.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    Bomb
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/tripwire/Mine detect layer 2.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    Bomb
                                )

                                AdvancedPillSound(
                                    {
                                        stringe = "OM/tripwire/landmine catches survivor.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    Bomb
                                )

                                trapped = true

                                timer.Simple(1, function()
                                    if not IsValid(Bomb) then return end


                                    local effectdata = EffectData()
                                    effectdata:SetOrigin(Bomb:GetPos() + Vector(0,0,20))
                                    util.Effect("orange_plasma_explosion", effectdata)
                                    AdvancedPillSound(
                                        {
                                            stringe = "OM/tripwire/mine explosion.wav",
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        Bomb
                                    )

                                    for _, ent2 in pairs(ents.FindInSphere(Bomb:GetPos(), 180)) do
                                        if ent2 == ply then continue end
                                        if not IsValid(ent2) then continue end

                                        local validTarget = false

                                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() > 0 then
                                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                            if not GetConVar('PVPStun_OM_exe'):GetBool() then
                                                if ent2:GetNW2Bool("OM_character_monster") then return end
                                            end

                                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                                            if not Mutal_OMCanDamage(ply, ent, ent2) then continue end
                                            validTarget = true
                                        end

                                        if not validTarget and ent2:GetMoveType() == MOVETYPE_VPHYSICS then
                                            local phys = ent2:GetPhysicsObject()
                                            if IsValid(phys) and phys:IsMotionEnabled() then
                                                validTarget = true
                                            end
                                        end

                                        if not validTarget then continue end

                                        local dir = (ent2:GetPos() - Bomb:GetPos()):GetNormalized()

                                        if ent2:IsPlayer() or ent2:IsNPC() or ent2:IsNextBot() then
                                            
                                            if (ent2:IsNPC() or ent2:IsNextBot()) and ent2:IsOnGround() then
                                                ent2:SetPos(ent2:GetPos() + Vector(0,0,40))
                                            end

                                            ent2:SetVelocity(dir * 800)
                                        end

                                        if ent2:GetMoveType() == MOVETYPE_VPHYSICS then
                                            local phys = ent2:GetPhysicsObject()
                                            if IsValid(phys) and phys:IsMotionEnabled() then
                                                phys:Wake()
                                                phys:ApplyForceCenter(dir * 60000)
                                            end
                                        end

                                        damagestun(ply, ent2, 25, DMG_BLAST, true)
                                    end
                                    Bomb:Remove()
                                end)
                            end
                        end)
                    end
                end
            end

            if ent:GetNW2Float("tripwire_claws") > CurTime() then
                ent:GetPuppet():SetBodygroup(1,1)
                if not ent.tripwire_claws_toggle then
                    ent.tripwire_claws_toggle = true
                    AdvancedPillSound(
                        {
                            stringe = "OM/tripwire/tripwire claws release.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            else
                ent:GetPuppet():SetBodygroup(1,0)
                if ent.tripwire_claws_toggle then
                    ent.tripwire_claws_toggle = false
                    AdvancedPillSound(
                        {
                            stringe = "OM/tripwire/tripwire claws retractile.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            end
        else


            local hookName = "PostDrawTranslucentRenderables"
            local name = "tripwire_ui_OM_noodles"..ent:EntIndex()

            local hooks = hook.GetTable()

            if hooks[hookName] and hooks[hookName][name] then
            else
                local beamMat = {
                    [0] = Material("icons/tripwire new laser"),
                    [1] = Material("icons/tripwirereachout"),
                    [2] = Material("icons/tripwire light beam")
                }

                local glowMat = Material("sprites/light_glow02_add")

                hook.Add(hookName, name, function()
                    local ply = LocalPlayer()
                    if !IsValid(ply) then hook.Remove(hookName, name) return end
                    if !IsValid(ent) then hook.Remove(hookName, name) return end

                    local v = ent

                    if v:GetNW2Float("Tripwire_Rope_tangle") > CurTime() then
                    end 


                    if v:GetNWFloat("LaserShootDuration") > CurTime() then

                        local startPos = v:GetNW2Vector("Position1")
                        local endPos = v:GetNW2Vector("Position2")
                        if !IsValid(v:GetNWEntity("Position2Entity")) then return end
                        local body = v:GetNWEntity("Position2Entity")
                        local boneID = body:LookupBone("Head")

                        if boneID then
                            local matrix = body:GetBoneMatrix(boneID)

                            if matrix then
                                local ang = matrix:GetAngles()
                                local pos = matrix:GetTranslation()

                                endPos = pos + ang:Right() * -18 + ang:Up() * 23
                            end
                        end

                        local beamLength = (endPos - startPos):Length()
                        local t = CurTime() * 18

                        render.SetMaterial(beamMat[0])
                        render.DrawBeam(startPos, endPos, 20, t, t + beamLength / 100, Color(255, 255, 255, 255))

                        render.SetMaterial(glowMat)
                        render.DrawSprite(endPos, 80, 80, Color(255, 0, 0, 255))


                        local emitter = ParticleEmitter(endPos)

                        if emitter then
                            for i = 1, 3 do
                                local spark = emitter:Add("effects/spark", endPos)

                                if spark then
                                    spark:SetVelocity(VectorRand() * 60 + Vector(0, 0, 20))
                                    spark:SetLifeTime(0)
                                    spark:SetDieTime(math.Rand(0.2, 0.5))

                                    spark:SetStartAlpha(255)
                                    spark:SetEndAlpha(0)

                                    spark:SetStartSize(math.Rand(4, 8))
                                    spark:SetEndSize(0)

                                    spark:SetRoll(math.Rand(0, 360))
                                    spark:SetRollDelta(math.Rand(-8, 8))

                                    spark:SetColor(255, 0, 0)
                                    spark:SetGravity(Vector(0, 0, -100))
                                    spark:SetAirResistance(40)
                                end
                            end


                            emitter:Finish()
                        end

                        local startEmitter = ParticleEmitter(startPos)

                        if startEmitter then
                            for i = 1, 8 do
                                local spark = startEmitter:Add("effects/spark", startPos)

                                if spark then
                                    spark:SetVelocity(VectorRand() * 140 + Vector(0, 0, 50))
                                    spark:SetLifeTime(0)
                                    spark:SetDieTime(math.Rand(2, 4))

                                    spark:SetStartAlpha(255)
                                    spark:SetEndAlpha(0)

                                    spark:SetStartSize(math.Rand(6, 12))
                                    spark:SetEndSize(0)

                                    spark:SetRoll(math.Rand(0, 360))
                                    spark:SetRollDelta(math.Rand(-12, 12))

                                    spark:SetColor(255, 0, 0)
                                    spark:SetGravity(Vector(0, 0, -150))
                                    spark:SetAirResistance(60)
                                end
                            end

                            startEmitter:Finish()
                        end

                        local idx = v:EntIndex()
                        local t = CurTime()

                        local dlightEnd = DynamicLight(idx * 2)
                        if dlightEnd then
                            dlightEnd.pos = endPos
                            dlightEnd.r = 255
                            dlightEnd.g = 0
                            dlightEnd.b = 0
                            dlightEnd.brightness = 3
                            dlightEnd.Decay = 1000
                            dlightEnd.Size = 120
                            dlightEnd.DieTime = t + 0.05
                        end

                        local dlightStart = DynamicLight(idx * 2 + 1)
                        if dlightStart then
                            dlightStart.pos = startPos
                            dlightStart.r = 255
                            dlightStart.g = 0
                            dlightStart.b = 0
                            dlightStart.brightness = 4
                            dlightStart.Decay = 1000
                            dlightStart.Size = 120
                            dlightStart.DieTime = t + 0.05
                        end
                    end
                    
                    local active = v:GetNW2Float("SpawnDynomiteDuration") > CurTime()

                    v._dynoAlpha = v._dynoAlpha or 0

                    if active then
                        v._dynoAlpha = math.min(v._dynoAlpha + FrameTime() * 0.5, 1)
                    else
                        v._dynoAlpha = math.max(v._dynoAlpha - FrameTime() * 0.5, 0)
                    end

                    if v._dynoAlpha > 0 then

                        local startPos = v:GetNW2Vector("SpawnPropPos")
                        local endPos = v:GetNW2Vector("Position2")
                        local body = v:GetNWEntity("Position2Entity")
                        if IsValid(body) then
                            local boneID = body:LookupBone("Head")

                            if boneID then
                                local matrix = body:GetBoneMatrix(boneID)

                                if matrix then
                                    local ang = matrix:GetAngles()
                                    local pos = matrix:GetTranslation()

                                    endPos = pos + ang:Right() * -18 + ang:Up() * 23
                                end
                            end
                        end

                        local beamLength = (endPos - startPos):Length()
                        local t = CurTime() * 0

                        local a = v._dynoAlpha * 255

                        render.SetMaterial(beamMat[2])
                        render.DrawBeam(
                            endPos,
                            startPos,
                            math.Clamp(90 * v._dynoAlpha, 1, 90),
                            0,
                            1,
                            Color(255, 255, 255, a)
                        )

                        render.SetMaterial(glowMat)
                        render.DrawSprite(
                            endPos,
                            80,
                            80,
                            Color(255, 0, 0, a)
                        )

                        local idx = v:EntIndex()
                        local t = CurTime()

                        local dlightEnd = DynamicLight(idx * 2)
                        if dlightEnd then
                            dlightEnd.pos = endPos
                            dlightEnd.r = 255
                            dlightEnd.g = 0
                            dlightEnd.b = 0
                            dlightEnd.brightness = 1
                            dlightEnd.Decay = 1000
                            dlightEnd.Size = 120
                            dlightEnd.DieTime = t + 0.05
                        end

                        local dlightStart = DynamicLight(idx * 2 + 1)
                        if dlightStart then
                            dlightStart.pos = startPos
                            dlightStart.r = 255
                            dlightStart.g = 0
                            dlightStart.b = 0
                            dlightStart.brightness = 2
                            dlightStart.Decay = 1000
                            dlightStart.Size = 400
                            dlightStart.DieTime = t + 0.05
                        end
                    end

                    if v:GetNW2Float("Tripwire_RopeDuration") > CurTime() then
                        for i=1,v:GetNW2Int("AmountsOfEnemies_Rope_om_tripwire") do
                            local v_enemy = v:GetNW2Entity("RopeEntity_om_tripwire_".. i)

                            if IsValid(v_enemy) then

                                local startPos = v_enemy:WorldSpaceCenter()
                                local endPos = v:GetPos()+Vector(0,0,35)

                                local beamLength = (endPos - startPos):Length()
                                local t = CurTime() * -9

                                render.SetMaterial(beamMat[1])
                                render.DrawBeam(startPos, endPos, 90, t, t + beamLength/100, Color(255,255,255,255))
                            end
                        end
                    end
                end)

            end
        end
    end,

    SpawnMine = function(ply, ent, hitpos)
        local startpos = ply:GetPos() +Vector(0,0,35)
        local direction = (hitpos - startpos):GetNormalized()

        local tr = util.TraceLine({
            start = startpos,
            endpos = startpos + direction * 3900,
            filter = ply,
            mask = MASK_ALL
        })

        if tr.Hit and tr.HitPos:Distance(startpos) < 280 then
            ent:SetNW2Float("SpawnDynomiteDuration", CurTime()+1.35)
            ent:SetNW2Vector("SpawnPropPos", tr.HitPos)
            local ang = tr.HitNormal:Angle()
            ang:RotateAroundAxis(ang:Right(), 90)
            ent:SetNW2Angle("SpawnPropAng", ang)
            if ply:IsPlayer() then
                ply:SetMoveType(0)
            else
                --ply:SetMoveType(2)
            end
        else
            AdvancedPillSound(
                {
                    stringe = "OM/tripwire/minefail.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )
        end
    end,

    noodles_OM_survivor_keybinds = function(ply, ent, button)
        if SERVER then

            if button == KEY_SPACE then
                if ent:GetNW2Bool("jetpackglide") then
                    ent:SetNW2Bool("jetpackglide_holding", true)
                else
                    if not ent:GetNW2Bool("JetpackJump") then return end
                    
                    if ply:IsOnGround() then return end
                    local currentplyVelocity = ply:GetVelocity()
                    currentplyVelocity.z = 300
                    ply:SetLocalVelocity(currentplyVelocity)

                    ent:SetNW2Bool("JetpackJump", false)
                    ent:SetNW2Bool("jetpackglide", true)
                    if SERVER then
                        ent:PillAnim('jump2')
                    end
                end
            end

            if button == KEY_F then

                if ent:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
                
                if ent:GetNW2Float("LaserLoadDuration") > CurTime() then return end
                if ent:GetNW2Bool("LaserLoad_bool") then return end
                if ent:GetNW2Float("LaserShootDuration") > CurTime() then return end
                if ent:GetNW2Bool("Lasershoot_bool") then return end

                if ent:GetNW2Float("TripwireReachOut") > CurTime() then return end
                if ent:GetNW2Bool("TripwireReachOutBool") then return end
                if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then return end
                if ent.tripwire_ropetoggle then return end

                if ent:GetNW2Float("SpawnDynomiteDuration") > CurTime() then return end
                if ent:GetNW2Bool("SpawnDynomite_bool") then return end

                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Float("tripwire_laser_cd", 0 ) > CurTime() then return end

                AdvancedPillSound(
                    {
                        stringe = "OM/tripwire/Laser_load.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent:SetNW2Float("LaserLoadDuration", CurTime()+0.5)
                local ed = EffectData()
                ed:SetOrigin(ent:GetPos()+Vector(0,0,50)+ ent:GetPuppet():GetForward()*30)
                util.Effect("Tripwire_emit_laserload", ed)
            end
            if button == KEY_R then

                if ent:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end

                if ent:GetNW2Float("LaserLoadDuration") > CurTime() then return end
                if ent:GetNW2Bool("LaserLoad_bool") then return end
                if ent:GetNW2Float("LaserShootDuration") > CurTime() then return end
                if ent:GetNW2Bool("Lasershoot_bool") then return end

                if ent:GetNW2Float("TripwireReachOut") > CurTime() then return end
                if ent:GetNW2Bool("TripwireReachOutBool") then return end
                if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then return end
                if ent.tripwire_ropetoggle then return end

                if ent:GetNW2Float("SpawnDynomiteDuration") > CurTime() then return end
                if ent:GetNW2Bool("SpawnDynomite_bool") then return end
                
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end

                if ent:GetNW2Float("tripwire_rope_cd", 0 ) > CurTime() then return end

                ent:SetNW2Float("TripwireReachOut", CurTime()+0.85)
                if ent.PillAnim then
                    ent:PillAnim("RopeLaunchStart")
                end
            end
            if button == KEY_T then

                if ent:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
                
                if ent:GetNW2Float("LaserLoadDuration") > CurTime() then return end
                if ent:GetNW2Bool("LaserLoad_bool") then return end
                if ent:GetNW2Float("LaserShootDuration") > CurTime() then return end
                if ent:GetNW2Bool("Lasershoot_bool") then return end

                if ent:GetNW2Float("TripwireReachOut") > CurTime() then return end
                if ent:GetNW2Bool("TripwireReachOutBool") then return end
                if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then return end
                if ent.tripwire_ropetoggle then return end

                if ent:GetNW2Float("SpawnDynomiteDuration") > CurTime() then return end
                if ent:GetNW2Bool("SpawnDynomite_bool") then return end
                
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                
                if ent:GetNW2Float("tripwire_step_cd", 0 ) > CurTime() then return end

                if ent:GetNW2Float("tripwire_bomb_count") >= 10 then return end

                if ply:IsPlayer() then
                    net.Start("Tripwire_retrieve_mouse")
                    net.Send(ply)
                elseif ply:IsNextBot() then
                    if ply:IsPossessed() then
                        if ent.formTable.SpawnMine then
                            ent.formTable.SpawnMine(ply, ent, ent:PossessorTrace().HitPos)
                        end
                    else
                        local function GetValidPosition(ply, radius)
                            local origin = ply:GetPos()
                            local forward = ply:GetForward()
                            local right = ply:GetRight()

                            for i = 1, 20 do
                                local forwardDist = math.Rand(radius * 0.5, radius)
                                local sideOffset = math.Rand(-radius * 0.4, radius * 0.4)

                                local offset = forward * forwardDist + right * sideOffset
                                offset.z = math.Rand(0, radius * 0.2)

                                local targetPos = origin + offset

                                local tr = util.TraceLine({
                                    start = origin,
                                    endpos = targetPos,
                                    filter = function(ent)
                                        if ent == ply then return false end
                                        if ent:IsPlayer() then return false end
                                        if ent:IsNPC() then return false end
                                        if ent:IsNextBot() then return false end
                                        return true
                                    end
                                })

                                if not tr.Hit then
                                    return targetPos
                                end
                            end

                            return origin + forward * radius
                        end

                        local position = GetValidPosition(ply, 200)

                        if ent.formTable.SpawnMine then
                            ent.formTable.SpawnMine(ply, ent, position)
                        end
                    end
                end
            end
        end
    end,

    noodles_OM_survivor_keybinds_deactivate = function(ply,ent,button)
        if SERVER then

            if button == KEY_SPACE then
                if ent:GetNW2Bool("jetpackglide_holding") then
                    ent:SetNW2Bool("jetpackglide", false)
                    ent:SetNW2Bool("jetpackglide_holding", false)
                end
            end
        end
    end,

    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if SERVER then

                if ent:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end

                if ent:GetNW2Float("LaserLoadDuration") > CurTime() then return end
                if ent:GetNW2Bool("LaserLoad_bool") then return end
                if ent:GetNW2Float("LaserShootDuration") > CurTime() then return end
                if ent:GetNW2Bool("Lasershoot_bool") then return end

                if ent:GetNW2Float("TripwireReachOut") > CurTime() then return end
                if ent:GetNW2Bool("TripwireReachOutBool") then return end
                if ent:GetNW2Float("Tripwire_RopeDuration") > CurTime() then return end
                if ent.tripwire_ropetoggle then return end

                if ent:GetNW2Float("SpawnDynomiteDuration") > CurTime() then return end
                if ent:GetNW2Bool("SpawnDynomite_bool") then return end
                
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                
                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1.35)


                AdvancedPillSound(
                    {
                        stringe = {
                            "OM/tripwire/trip m1 (1).wav",
                            "OM/tripwire/trip m1 (2).wav",
                            "OM/tripwire/trip m1 (3).wav",
                            "OM/tripwire/trip m1 (4).wav",
                            "OM/tripwire/trip m1 (5).wav",
                            "OM/tripwire/trip m1 (6).wav",
                            "OM/tripwire/trip m1 (7).wav",
                            "OM/tripwire/trip m1 (8).wav",
                            "OM/tripwire/trip m1 (9).wav",
                        },
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                local puppet = ent:GetPuppet()
                if not IsValid(puppet) then return end
                    
                local layeredAnim
                if math.random(1,2) == 1 then
                    layeredAnim = puppet:AddGesture(ACT_GESTURE_MELEE_ATTACK1, false)
                else
                    layeredAnim = puppet:AddGesture(ACT_GESTURE_MELEE_ATTACK2, false)
                end

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
                        timer.Simple(0.0005, fadeLayer)
                    end
                end

                timer.Simple(0.6, fadeLayer)

                timer.Simple(1.1,function()
                    if !IsValid(ent) then return end
                    puppet:RemoveLayer(layeredAnim)
                end)

                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1.25)
                ent:SetNW2Float("tripwire_claws", CurTime() + 6)
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
        ent:SetNW2Bool("JetpackJump", true)
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