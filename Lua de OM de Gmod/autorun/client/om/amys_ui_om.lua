AddCSLuaFile()
if SERVER then
    util.AddNetworkString("Amy_OM_choosecards")
end


if CLIENT then



    local cards = {
        [0] = Material("icons/Card1.png"),-- moon
        [1] = Material("icons/Card2.png"),-- sun
        [2] = Material("icons/Card3.png"),-- empo
        [3] = Material("icons/Card4.png"),-- knuckle
        [4] = Material("icons/Card5.png"),-- sonic
        [5] = Material("icons/Card6.png") -- tail
    }

    local AmyCardStarBurst = {
        active = true,
        start = CurTime(),
        duration = 2.2,
        x = ScrW() * 0.5,
        y = ScrH() * 0.5,
        stars = {}
    }

    net.Receive("Amy_OM_choosecards", function()
        local ent = net.ReadEntity()
        local ply = LocalPlayer()

        surface.PlaySound("OM/Amy/CardPick.wav")
        
        if not IsValid(ent) then return end

        local value = 0

        local cardsstunbuff = {
            [0] = 0,
            [1] = 0,
            [2] = 0,
            [3] = 3,
            [4] = 0,
            [5] = -1
        }

        local stunDur1, stunDur2 = 0, 0

        local card1 = net.ReadInt(32)
        local card2 = net.ReadInt(16)
        local Amy_OM_mooncard_effect1 = net.ReadInt(33)
        local Amy_OM_mooncard_effect2 = net.ReadInt(31)
        --print(card1.. " ".. card2.. " ".. Amy_OM_mooncard_effect1.. " ".. Amy_OM_mooncard_effect2)

        if type(cardsstunbuff[card1]) == "function" then
            stunDur1 = cardsstunbuff[card1](ent)
        else
            stunDur1 = cardsstunbuff[card1]
        end

        if type(cardsstunbuff[card2]) == "function" then
            stunDur2 = cardsstunbuff[card2](ent)
        else
            stunDur2 = cardsstunbuff[card2]
        end

        local cardsstatsbuff = {
            [0] = function(ent)
                local val = Amy_OM_mooncard_effect1
                return {
                    ['walk'] = val,
                    ['run'] = val,
                    ['ducked'] = val
                }
            end,
            [1] = { ['mathtype'] = "add", ['walk'] = 0, ['run'] = 0, ['ducked'] = 0 },
            [2] = { ['mathtype'] = "add", ['walk'] = 60, ['run'] = 60, ['ducked'] = 60 },
            [3] = { ['mathtype'] = "add", ['walk'] = -90, ['run'] = -90, ['ducked'] = -90 },
            [4] = { ['mathtype'] = "add", ['walk'] = -60, ['run'] = -60, ['ducked'] = -60 },
            [5] = { ['mathtype'] = "add", ['walk'] = 40, ['run'] = 40, ['ducked'] = 40 }
        }

        local function getRunValue(card)
            if type(cardsstatsbuff[card]) == "function" then
                return cardsstatsbuff[card](ent)['run']
            else
                return cardsstatsbuff[card]['run']
            end
        end

        local add1 = getRunValue(card1)
        local add2 = getRunValue(card2)

        local cardsdamagebuff = {
            [0] = function(ent) return Amy_OM_mooncard_effect2 end,
            [1] = 1,
            [2] = 0.85,
            [3] = 1.15,
            [4] = 1,
            [5] = 1
        }

        local function getDamageMultiplier(card)
            if type(cardsdamagebuff[card]) == "function" then
                return cardsdamagebuff[card](ent)
            else
                return cardsdamagebuff[card]
            end
        end

        local DamageMultiplyer1 = getDamageMultiplier(card1)
        local DamageMultiplyer2 = getDamageMultiplier(card2)

        local BaseDamageResistance = DamageMultiplyer1 * DamageMultiplyer2
        local BaseStunPower = stunDur1 + stunDur2
        local BaseRunSpeed = add1 + add2

        if BaseRunSpeed > 0 then value = value + 2
        elseif BaseRunSpeed < 0 then value = value - 2
        else value = value + 0.5
        end

        if BaseStunPower > 0 then value = value + 0.6
        elseif BaseStunPower < 0 then value = value - 1
        else value = value + 0.5
        end

        if BaseDamageResistance > 1 then value = value + 0.6
        elseif BaseDamageResistance < 1 then value = value - 1
        else value = value + 0.5
        end

        --print(BaseRunSpeed, BaseStunPower, BaseDamageResistance)
        --print("Value:", value)
        if card1 == 1 or card2 == 1 then
            value=value+0.5
        end
        if card1 == 4 or card2 == 4 then
            value=value+0.5
        end

        surface.PlaySound("OM/Amy/CardUpgrade.wav")
        timer.Simple(0.5, function()
            if not IsValid(ent) then return end

            surface.PlaySound(value < 0 and "OM/Amy/CardNormal.wav" or "OM/Amy/CardGood.wav")

            if ent:GetNW2Float("CardSelection1", 0) == 0
            or ent:GetNW2Float("CardSelection2", 0) == 0 then
                surface.PlaySound("OM/Amy/cardmoon.wav")
            end
        end)

        local LeftMdl = ClientsideModel("models/Noodles/OM/Amy/cards.mdl", RENDERGROUP_OPAQUE)
        LeftMdl:SetNoDraw(true)

        local seq = LeftMdl:LookupSequence("ref")
        if seq then LeftMdl:ResetSequence(seq) end

        local Rightmdl = ClientsideModel("models/Noodles/OM/Amy/cards.mdl", RENDERGROUP_OPAQUE)
        Rightmdl:SetNoDraw(true)

        local seq = Rightmdl:LookupSequence("ref")
        if seq then Rightmdl:ResetSequence(seq) end

        local WhiteMat = Material("models/debug/debugwhite")

        local ENABLE_FINAL_WHITE = LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 0

        local START_TIME = CurTime()

        local SPIN_ACCEL = 3000
        local ENTRY_TIME = 0.6
        local CardGrabTime = 1.4
        local EXIT_START = 2.9
        local END_TIME = 3.5

        local GLOW_START = EXIT_START - 0.5

        local SECOND_CARD_DELAY = 0.3

        local WOBBLE_SPEED = 6
        local WOBBLE_POS_INTENSITY = 0.2
        local WOBBLE_ANG_INTENSITY = 18

        local WOBBLE_CALM_MIN = 0.25

        local leftSeed = math.Rand(0, 1000)
        local rightSeed = math.Rand(0, 1000)

        local entryDir = math.random(1, 4)

        local CardGrabLeft = false
        local CardGrabRight = false

        local LeftCardMove = false
        local RightCardMove = false
        local LeftCardMove2 = false
        local RightCardMove2 = false

        local windstart = false

        local function GetEntryOffset(ang)
            local side = ang:Right() * 4
            local up = ang:Up() * 3

            if entryDir == 1 then return -side
            elseif entryDir == 2 then return side
            elseif entryDir == 3 then return up
            else return -up end
        end

        local name = "DrawAmy_cards_OM"..ply:Nick().." "..CurTime()


        hook.Add("HUDPaint", name, function()
            if render.GetRenderTarget() ~= nil then return end
            local view = render.GetViewSetup()
            local CamPos = view.origin
            local CamAng = view.angles
            if not IsValid(ent) or not IsValid(LeftMdl) or not IsValid(Rightmdl) then
                hook.Remove("HUDPaint", name)
                if IsValid(LeftMdl) then LeftMdl:Remove() end
                if IsValid(Rightmdl) then Rightmdl:Remove() end
                return
            end

            local globalTime = CurTime() - START_TIME

            LeftMdl:SetSkin(ent:GetNW2Float("CardSelection1", 1))
            Rightmdl:SetSkin(ent:GetNW2Float("CardSelection2", 1))

            local basePos = CamPos + CamAng:Forward() * 7
            local baseAng = Angle(CamAng.p, CamAng.y, CamAng.r)
            baseAng:RotateAroundAxis(baseAng:Up(), 180)

            local entryOffset = GetEntryOffset(CamAng)

            local screenW, screenH = ScrW(), ScrH()
            cam.Start3D(CamPos, CamAng, 70, 0, 0, ScrW(), ScrH())
                render.SuppressEngineLighting(true)

                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)

                do
                    local time = globalTime

                    local entryFrac = math.Clamp(time / ENTRY_TIME, 0, 1)
                    local easedEntry = entryFrac * entryFrac * (3 - 2 * entryFrac)

                    local target = basePos + CamAng:Right() * -1
                    local pos = LerpVector(math.Clamp(easedEntry * 1.2, 0, 1), basePos + entryOffset, target)

                    local t = CurTime()

                    local calm = 1
                    if time > ENTRY_TIME then
                        local post = math.Clamp((time - ENTRY_TIME) / 1.2, 0, 1)
                        calm = Lerp(post, 1, WOBBLE_CALM_MIN)
                    end

                    if time > CardGrabTime then
                        if not CardGrabLeft then
                            CardGrabLeft = true
                            sound.Play("physics/cardboard/cardboard_box_impact_hard1.wav", pos, 60, 120, 0.7)
                        end
                    end

                    local wobX = math.sin(t * WOBBLE_SPEED + leftSeed) * calm
                    local wobY = math.cos(t * (WOBBLE_SPEED * 0.9) + leftSeed) * calm
                    local wobZ = math.sin(t * (WOBBLE_SPEED * 1.1) + leftSeed * 0.7) * calm

                    pos = pos +
                        CamAng:Right() * (wobX * WOBBLE_POS_INTENSITY) +
                        CamAng:Up() * (wobY * WOBBLE_POS_INTENSITY * 0.6)

                    local glow = 0
                    if time > GLOW_START then
                        glow = math.Clamp((time - GLOW_START) / (EXIT_START - GLOW_START), 0, 1)
                    end

                    local exitFrac = 0
                    local alpha = 255

                    if time > EXIT_START then
                        exitFrac = math.Clamp((time - EXIT_START) / (END_TIME - EXIT_START), 0, 1)

                        local closePos = CamPos + CamAng:Forward() * 2
                        pos = LerpVector(exitFrac, pos, closePos)

                        alpha = 255 * (1 - exitFrac * 2)
                        alpha = math.Clamp(alpha, 0, 255)
                    end

                    LeftMdl:FrameAdvance(FrameTime())

                    local ang = Angle(baseAng)
                    ang:RotateAroundAxis(ang:Forward(), wobZ * WOBBLE_ANG_INTENSITY)
                    ang:RotateAroundAxis(ang:Right(), wobX * (WOBBLE_ANG_INTENSITY * 0.6))
                    ang:RotateAroundAxis(ang:Up(), wobY * (WOBBLE_ANG_INTENSITY * 0.4))

                    local spinAngle = 0
                    if time > GLOW_START then
                        local t2 = math.Clamp(time - GLOW_START, 0, EXIT_START - GLOW_START)
                        spinAngle = 0.5 * SPIN_ACCEL * (t2 * t2)
                    end

                    ang:RotateAroundAxis(ang:Up(), spinAngle)

                    if ENABLE_FINAL_WHITE and time >= EXIT_START then
                        render.MaterialOverride(WhiteMat)
                    else
                        render.MaterialOverride(nil)
                    end

                    LeftMdl:SetPos(pos)
                    LeftMdl:SetAngles(ang)
                    LeftMdl:SetRenderOrigin(pos)
                    LeftMdl:SetRenderAngles(ang)
                    LeftMdl:DrawModel()

                    render.MaterialOverride(nil)
                    local scale = 1 - exitFrac
                    scale = math.Clamp(scale, 0.05, 1)

                    LeftMdl:SetModelScale(scale, 0)
                    
                    if exitFrac >= 0.1 then
                        if not LeftCardMove then
                            LeftCardMove = true
                            sound.Play("ambient/levels/labs/electric_explosion1.wav", pos, 60, 180, 0.4)
                        end
                    end
                    if exitFrac >= 0.75 then
                        if not LeftCardMove2 then
                            LeftCardMove2 = true
                            sound.Play("ambient/levels/labs/coinslot1.wav", pos, 60, 150, 1)
                        end
                    end
                end

                do
                    local time = math.max(0, globalTime - SECOND_CARD_DELAY)

                    if globalTime > SECOND_CARD_DELAY then

                        local entryFrac = math.Clamp(time / ENTRY_TIME, 0, 1)
                        local easedEntry = entryFrac * entryFrac * (3 - 2 * entryFrac)

                        local target = basePos + CamAng:Right() * 1
                        local pos = LerpVector(math.Clamp(easedEntry * 1.2, 0, 1), basePos + entryOffset, target)

                        local t = CurTime()

                        local calm = 1
                        if time > ENTRY_TIME then
                            local post = math.Clamp((time - ENTRY_TIME) / 1.2, 0, 1)
                            calm = Lerp(post, 1, WOBBLE_CALM_MIN)
                        end

                        if time > CardGrabTime then
                            if not CardGrabRight then
                                CardGrabRight = true
                                sound.Play("physics/cardboard/cardboard_box_impact_hard1.wav", pos, 60, 120, 0.7)
                            end
                        end

                        local wobX = math.sin(t * WOBBLE_SPEED + rightSeed) * calm
                        local wobY = math.cos(t * (WOBBLE_SPEED * 0.9) + rightSeed) * calm
                        local wobZ = math.sin(t * (WOBBLE_SPEED * 1.1) + rightSeed * 0.7) * calm

                        pos = pos +
                            CamAng:Right() * (wobX * WOBBLE_POS_INTENSITY) +
                            CamAng:Up() * (wobY * WOBBLE_POS_INTENSITY * 0.6)

                        local glow = 0
                        if time > GLOW_START then
                            glow = math.Clamp((time - GLOW_START) / (EXIT_START - GLOW_START), 0, 1)
                        end

                        local exitFrac = 0
                        local alpha = 255

                        if time > EXIT_START then
                            exitFrac = math.Clamp((time - EXIT_START) / (END_TIME - EXIT_START), 0, 1)

                            local closePos = CamPos + CamAng:Forward() * 2
                            pos = LerpVector(exitFrac, pos, closePos)

                            alpha = 255 * (1 - exitFrac * 2)
                            alpha = math.Clamp(alpha, 0, 255)
                        end

                        Rightmdl:SetColor(Color(255,255,255,255))
                        Rightmdl:FrameAdvance(FrameTime())

                        local ang = Angle(baseAng)
                        ang:RotateAroundAxis(ang:Forward(), wobZ * WOBBLE_ANG_INTENSITY)
                        ang:RotateAroundAxis(ang:Right(), wobX * (WOBBLE_ANG_INTENSITY * 0.6))
                        ang:RotateAroundAxis(ang:Up(), wobY * (WOBBLE_ANG_INTENSITY * 0.4))

                        local spinAngle = 0
                        if time > GLOW_START then
                            local t2 = math.Clamp(time - GLOW_START, 0, EXIT_START - GLOW_START)
                            spinAngle = 0.5 * SPIN_ACCEL * (t2 * t2)
                        end

                        ang:RotateAroundAxis(ang:Up(), spinAngle)

                        if ENABLE_FINAL_WHITE and time >= EXIT_START then
                            render.MaterialOverride(WhiteMat)
                        else
                            render.MaterialOverride(nil)
                        end

                        Rightmdl:SetPos(pos)
                        Rightmdl:SetAngles(ang)
                        Rightmdl:SetRenderOrigin(pos)
                        Rightmdl:SetRenderAngles(ang)
                        Rightmdl:DrawModel()

                        render.MaterialOverride(nil)

                        local scale = 1 - exitFrac
                        scale = math.Clamp(scale, 0.05, 1)

                        Rightmdl:SetModelScale(scale, 0)

                        if exitFrac >= 0.1 then
                            if not RightCardMove then
                                RightCardMove = true
                                sound.Play("ambient/levels/labs/electric_explosion1.wav", pos, 60, 180, 0.4)
                            end
                        end
                        if exitFrac >= 0.75 then
                            if not RightCardMove2 then
                                RightCardMove2 = true
                                sound.Play("ambient/levels/labs/coinslot1.wav", pos, 60, 150, 1)
                            end
                        end
                    end
                end

                render.SetBlend(1)
                render.SetColorModulation(1,1,1)
                render.SuppressEngineLighting(false)

            cam.End3D()
        end)

        timer.Simple(END_TIME + SECOND_CARD_DELAY, function()
            if IsValid(LeftMdl) then LeftMdl:Remove() end
            if IsValid(Rightmdl) then Rightmdl:Remove() end
            hook.Remove("HUDPaint", name)
        end)
    end)

    --[[
    local fadeAmount = 0

    hook.Add("RenderScreenspaceEffects", "WhiteScreenFadeEffect", function()
        local ply = LocalPlayer()

        local ft = FrameTime()
        if ply:GetNW2Float("SunCardBlindingEffect") > CurTime() then
            fadeAmount = math.Clamp(fadeAmount + ft * 0.01, 0, 0.85)
        else
            fadeAmount = math.Clamp(fadeAmount - ft * 0.1, 0, 0.85)
        end

        if fadeAmount <= 0 then return end

        DrawColorModify({
            ["$pp_colour_addr"] = fadeAmount * 1.5,
            ["$pp_colour_addg"] = fadeAmount * 1.5,
            ["$pp_colour_addb"] = fadeAmount * 1.5,

            ["$pp_colour_brightness"] = fadeAmount * -0.2,
            ["$pp_colour_contrast"] = 1 - (fadeAmount * 0.9),
            ["$pp_colour_colour"] = 1 - (fadeAmount * 0.9),

            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })

        surface.SetDrawColor(255, 255, 255, 180 * (fadeAmount / 0.85))
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end)
    ]]

    local mat = Material("icons/amy_alt_indicator.png", "noclamp smooth")

    hook.Add("PostDrawOpaqueRenderables", "OM_HighlightEntity_amy", function()
        local ply = LocalPlayer()
        local pillentity = ply.pk_pill_ent
        local isdrgbase = false

        if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end

        if not IsValid(pillentity) then return end

        if not (pillentity.formTable and pillentity.formTable.Outcomememories == "Amy") then return end
        if pillentity:GetNW2Float("CardSelection1") ~= 4 and pillentity:GetNW2Float("CardSelection2") ~= 4 then return end
        if ply:GetInfoNum("om_pills_action_Amy_alternateIndicator", 0) ~= 1 then return end

        cam.Start3D(EyePos(), EyeAngles())
            render.FogMode(MATERIAL_FOG_NONE)

            for _, ent in ipairs(ents.GetAll()) do
                if not IsValid(ent) then continue end

                if not (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then continue end
                if ent == ply or ent == pillentity then continue end
                if ent:IsPlayer() and ent:Team() == TEAM_SPECTATOR then continue end
                if ent:GetColor().a <= 30 then continue end
                if ent:GetClass() == "pill_puppet" then continue end

                local hp = (ent.Health and ent:Health()) or 0
                if hp <= 0 then continue end

                local pos = ent:WorldSpaceCenter()
                local dist = ply:GetPos():Distance(ent:GetPos())

                local Size = math.min(math.max(95 * dist / 700, 95), 1750)

                local curcolor = ent:GetNW2Bool("OM_character") and Color(255,255,255,200) or Color(255,185,185,200)

                render.SetMaterial(mat)

                cam.IgnoreZ(true)
                render.SetBlend(0.65)
                render.DrawSprite(pos, Size, Size, curcolor)
                render.SetBlend(1)
                cam.IgnoreZ(false)
            end

        cam.End3D()

        render.FogMode(MATERIAL_FOG_LINEAR)
    end)

    --[[
    hook.Add("SetupPlayerVisibility", "VisibilityHandler_v2", function()
        local ply = LocalPlayer()

        local pillentity = ply.pk_pill_ent
        if IsValid(pillentity) then
            if pillentity.formTable then
                if pillentity.formTable.Outcomememories then
                    if pillentity.formTable.Outcomememories == "Amy" then

                        if pillentity:GetNW2Float("CardSelection1") == 4 or pillentity:GetNW2Float("CardSelection2") == 4 then
                            for _, ent in ipairs(ents.GetAll()) do
                                if IsValid(ent) then
                                    if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
                                        AddOriginToPVS(plr:GetPos())
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    ]]

    hook.Add("PostDraw2DSkyBox", "Amy_MoonCardFog_SkyBox_OM", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local pillentity = ply.pk_pill_ent
        if not IsValid(pillentity) then
            local drg = ply:GetNW2Entity("DrGBasePossessing")
            if IsValid(drg) then
                pillentity = drg
            end
        end
        if not IsValid(pillentity) then return end
        if not pillentity.FogDensity_OM or pillentity.FogDensity_OM <= 0.01 then return end


        if IsValid(pillentity) then
            if pillentity.formTable then
                if pillentity.formTable.Outcomememories then
                    if pillentity.formTable.Outcomememories == "Amy" then
                    else
                        return
                    end
                else
                    return
                end
            else
                return
            end
        end


        pillentity.SkyColor_OM = pillentity.SkyColor_OM or Vector(0, 0, 0)
        pillentity.SkyAlpha_OM = pillentity.SkyAlpha_OM or 0

        local speed = 5
        local ft = FrameTime()

        local light = render.GetLightColor(ply:GetPos() + Vector(0,0,50)) * 255

        local target = pillentity.FogColor_OM or light
        local density = math.Clamp(pillentity.FogDensity_OM or 0, 0, 1)

        pillentity.SkyColor_OM = LerpVector(ft * speed, pillentity.SkyColor_OM, target)

        local col = pillentity.SkyColor_OM

        local r = math.Clamp(col.x * density, 0, 255)
        local g = math.Clamp(col.y * density, 0, 255)
        local b = math.Clamp(col.z * density, 0, 255)

        local targetAlpha = 0
        if pillentity.formTable and pillentity.formTable.Outcomememories == "Amy" then
            local c1 = pillentity:GetNW2Float("CardSelection1", 0)
            local c2 = pillentity:GetNW2Float("CardSelection2", 0)

            if c1 == 0 or c2 == 0 then
                targetAlpha = 255
            end
        end

        pillentity.SkyAlpha_OM = Lerp(ft * speed, pillentity.SkyAlpha_OM, targetAlpha)

        cam.Start2D()
            surface.SetDrawColor(r, g, b, pillentity.SkyAlpha_OM)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        cam.End2D()
    end)
    hook.Add("SetupSkyboxFog", "Amy_MoonCardFog_Sky_OM", function(scale)
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local pillentity = ply.pk_pill_ent
        isdrgbase = false
        if !IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end

        if not IsValid(pillentity) then return end
        if not pillentity.FogDensity_OM or pillentity.FogDensity_OM <= 0.01 then return end

        if IsValid(pillentity) then
            if pillentity.formTable then
                if pillentity.formTable.Outcomememories then
                    if pillentity.formTable.Outcomememories == "Amy" then
                    else
                        return
                    end
                else
                    return
                end
            else
                return
            end
        end

        render.FogMode(MATERIAL_FOG_LINEAR)

        local col = pillentity.FogColor_OM or Vector(0,0,0)
        render.FogColor(col.x, col.y, col.z)

        render.FogStart(0)

        render.FogEnd(1375 * scale)

        render.FogMaxDensity(pillentity.FogDensity_OM)

        return true
    end)

    hook.Add("SetupWorldFog", "Amy_MoonCardFog_OM", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local pillentity = ply.pk_pill_ent
        isdrgbase = false
        if !IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end
        if !IsValid(pillentity) then return end



        if IsValid(pillentity) then
            if pillentity.formTable then
                if pillentity.formTable.Outcomememories then
                    if pillentity.formTable.Outcomememories == "Amy" then
                    else
                        return
                    end
                else
                    return
                end
            else
                return
            end
        end

        local shouldFog = false

        if IsValid(pillentity) and pillentity.formTable and pillentity.formTable.Outcomememories == "Amy" then
            local card_idx_1_raw = pillentity:GetNW2Float("CardSelection1", 0)
            local card_idx_2_raw = pillentity:GetNW2Float("CardSelection2", 0)

            if card_idx_1_raw == 0 or card_idx_2_raw == 0 then
                shouldFog = true
            end
        end

        local targetDensity = shouldFog and 1 or 0

        if not pillentity.FogDensity_OM then
            pillentity.FogDensity_OM = render.GetFogDistances()
        end

        if not pillentity.FogColor_OM then
            local r, g, b = render.GetFogColor()
            pillentity.FogColor_OM = Vector(r, g, b)
        end

        local speed = 2

        pillentity.FogDensity_OM = Lerp(FrameTime() * speed, pillentity.FogDensity_OM, targetDensity)

        if pillentity.FogDensity_OM <= 0.01 then return end

        render.FogMode(MATERIAL_FOG_LINEAR)

        local light = render.GetLightColor(ply:GetPos()) * 100

        pillentity.FogColor_OM = LerpVector(FrameTime() * speed, pillentity.FogColor_OM, light)

        local col = pillentity.FogColor_OM

        render.FogColor(col.x, col.y, col.z)
        render.FogStart(0)
        render.FogEnd(1375)

        render.FogMaxDensity(pillentity.FogDensity_OM)
        return true
    end)

    hook.Add("PreRenderColor_om_plain_optimized", "Amy_highlight_ui_OM_noodles", function()
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("Amy_highlight_pill", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("Amy_highlight_pill", 0)
                local duration, fade = 0.5*0.35, 0.25*0.35
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 255, 255, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("Amy_highlight_pill_blue", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("Amy_highlight_pill_blue", 0)
                local duration, fade = 0.5*0.35, 0.25*0.35
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(0, 255*0.35, 255, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("Amy_highlight_pill_red", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("Amy_highlight_pill_red", 0)
                local duration, fade = 0.5*0.35, 0.25*0.35
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 0, 0, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("Amy_highlight_pill_green", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("Amy_highlight_pill_green", 0)
                local duration, fade = 0.5, 0.25
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(0, 255, 0, 255 * alpha)
            end,
            ignorez = false 
        })
    end)

    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_AMY_1", function()
        local ply = LocalPlayer()
        local pillentity = LocalPlayer().pk_pill_ent
        local isdrgbase = false
        if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end

        local hasworldcard

        if IsValid(pillentity) then
            if pillentity.formTable then
                if pillentity.formTable.Outcomememories then
                    if pillentity.formTable.Outcomememories == "Amy" then
                        if pillentity:GetNW2Float("CardSelection1") == 4 or pillentity:GetNW2Float("CardSelection2") == 4 then
                            
                            if ply:GetInfoNum("om_pills_action_Amy_alternateIndicator", 0) == 0 then

                                hasworldcard = true
                            end
                        end
                    end
                end
            end
        end

        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("amy_ability_outline", 0) >= CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            1, 
            false)    

        om_halo.Add_optimized(
            function(ent) 
                return hasworldcard and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and ent:Health() > 0.1 and ent ~= ply
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            1, 
            true)
    end )

end