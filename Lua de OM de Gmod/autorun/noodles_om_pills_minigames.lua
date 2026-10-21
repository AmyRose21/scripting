
AddCSLuaFile()
-- Clashing -- 
if SERVER then


    function OM_Minigame(ply, target, settingstable)
        -- drawUI_OM_button_om
        if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return end
        if target:GetNW2Bool("clashingminigame_om_isinminigame") then return end
        if ply.OMInitiateClash_lnz then
            ply:OMInitiateClash_lnz(target)
        end
        if target.OMInitiateClash_lnz then
            target:OMInitiateClash_lnz(ply)
        end
        
        if not settingstable then settingstable = {} end
        
        local configurations = {}
        if settingstable.CanPlyplay ~= nil then configurations["CanPlyplay"] = settingstable.CanPlyplay else configurations["CanPlyplay"] = true end
        if settingstable.CanPlyEndRound ~= nil then configurations["CanPlyEndRound"] = settingstable.CanPlyEndRound else configurations["CanPlyEndRound"] = true end
        if settingstable.Canplymessup ~= nil then configurations["Canplymessup"] = settingstable.Canplymessup else configurations["Canplymessup"] = true end


        target:SetNW2Bool("clashingminigame_om_isinminigame_canplay", true)
        ply:SetNW2Bool("clashingminigame_om_isinminigame_canplay", configurations.CanPlyplay)
        target:SetNW2Bool("clashingminigame_om_isinminigame_canplayOpp", configurations.CanPlyplay)
        if settingstable.Cantargetmessup ~= nil then configurations["Cantargetmessup"] = settingstable.Cantargetmessup else configurations["Cantargetmessup"] = true end
        
        if settingstable.TimeLimitBool ~= nil then configurations["TimeLimitBool"] = settingstable.TimeLimitBool else configurations["TimeLimitBool"] = true end
        if settingstable.TimeLimitFloat ~= nil then configurations["TimeLimitFloat"] = settingstable.TimeLimitFloat else configurations["TimeLimitFloat"] = 10 end
        if settingstable.EndRoundLogic ~= nil then configurations["EndRoundLogic"] = settingstable.EndRoundLogic else configurations["EndRoundLogic"] = function(ply, target, configurations) return nil end end

        if settingstable.starthealth ~= nil then configurations["starthealth"] = settingstable.starthealth else configurations["starthealth"] = 50 end

        if settingstable.StunPLYLoss ~= nil then configurations["StunPLYLoss"] = settingstable.StunPLYLoss else configurations["StunPLYLoss"] = true end
        if settingstable.StunTARGETLoss ~= nil then configurations["StunTARGETLoss"] = settingstable.StunTARGETLoss else configurations["StunTARGETLoss"] = true end
        if settingstable.PLYIframes ~= nil then configurations["PLYIframes"] = settingstable.PLYIframes else configurations["PLYIframes"] = true end
        if settingstable.TARGETIframes ~= nil then configurations["TARGETIframes"] = settingstable.TARGETIframes else configurations["TARGETIframes"] = true end
        ply:SetNW2Bool("clashingminigame_om_isinminigame_TimeLimitBool", configurations.TimeLimitBool)
        ply:SetNW2Bool("clashingminigame_om_isinminigame_TimeLimitFloat", configurations.TimeLimitFloat + CurTime())
        ply:SetNW2Bool("clashingminigame_om_isinminigame_TimeLimitFloat_duration", configurations.TimeLimitFloat )

        target:SetNW2Bool("clashingminigame_om_isinminigame_TimeLimitBool", configurations.TimeLimitBool)
        target:SetNW2Bool("clashingminigame_om_isinminigame_TimeLimitFloat", configurations.TimeLimitFloat + CurTime())
        target:SetNW2Bool("clashingminigame_om_isinminigame_TimeLimitFloat_duration", configurations.TimeLimitFloat )

        ply:SetNW2Entity("clashingminigame_om_opponent", target)
        target:SetNW2Entity("clashingminigame_om_opponent", ply)

        ply:SetNW2Bool("clashingminigame_om_isinminigame", true)
        target:SetNW2Bool("clashingminigame_om_isinminigame", true)

        local DamageCurrently = configurations.starthealth

        ply:SetNW2Float("DamageCurrently_OM_clashingminigame", DamageCurrently)
        target:SetNW2Float("DamageCurrently_OM_clashingminigame", DamageCurrently)

        ply:SetNW2Float('OM_PointOfView', 0)
        target:SetNW2Float('OM_PointOfView', 1)

        if not ply.ColorRGB_B_1_OM then 
            ply.ColorRGB_B_1_OM = Color(255,0,0,255)
        end
        if not target.ColorRGB_B_1_OM then 
            target.ColorRGB_B_1_OM = Color(0,0,255,255)
        end

        ply:SetNW2Float("ColorRGB_R_1_OM", ply.ColorRGB_B_1_OM.r or 255)
        ply:SetNW2Float("ColorRGB_g_1_OM", ply.ColorRGB_B_1_OM.g or 255)
        ply:SetNW2Float("ColorRGB_b_1_OM", ply.ColorRGB_B_1_OM.b or 255)
        ply:SetNW2Float("ColorRGB_a_1_OM", ply.ColorRGB_B_1_OM.a or 255)

        target:SetNW2Float("ColorRGB_R_1_OM", ply.ColorRGB_B_1_OM.r or 255)
        target:SetNW2Float("ColorRGB_g_1_OM", ply.ColorRGB_B_1_OM.g or 255)
        target:SetNW2Float("ColorRGB_b_1_OM", ply.ColorRGB_B_1_OM.b or 255)
        target:SetNW2Float("ColorRGB_a_1_OM", ply.ColorRGB_B_1_OM.a or 255)

        ply:SetNW2Float("ColorRGB_R_2_OM", target.ColorRGB_B_1_OM.r or 255)
        ply:SetNW2Float("ColorRGB_g_2_OM", target.ColorRGB_B_1_OM.g or 255)
        ply:SetNW2Float("ColorRGB_b_2_OM", target.ColorRGB_B_1_OM.b or 255)
        ply:SetNW2Float("ColorRGB_a_2_OM", target.ColorRGB_B_1_OM.a or 255)

        target:SetNW2Float("ColorRGB_R_2_OM", target.ColorRGB_B_1_OM.r or 255)
        target:SetNW2Float("ColorRGB_g_2_OM", target.ColorRGB_B_1_OM.g or 255)
        target:SetNW2Float("ColorRGB_b_2_OM", target.ColorRGB_B_1_OM.b or 255)
        target:SetNW2Float("ColorRGB_a_2_OM", target.ColorRGB_B_1_OM.a or 255)

        local combo = {
        }

        local function SetUpKeyCombo(entity)
            combo[entity] = {}
            combo[entity]['keyison'] = 1
            if combo[entity]['DamageTake'] then
                combo[entity]['DamageTake'] = combo[entity]['DamageTake'] * 1.25
            else
                combo[entity]['DamageTake'] = 10
            end
            for i=1,4 do
                local randomke = math.random(1,4)
                if randomke == 1 then
                    randomke = IN_FORWARD
                elseif randomke == 2 then
                    randomke = IN_BACK
                elseif randomke == 3 then
                    randomke = IN_MOVELEFT
                elseif randomke == 4 then
                    randomke = IN_MOVERIGHT
                end
                combo[entity][i] = { Key = randomke, AlreadyPresed = false }
                entity:SetNW2Int("clashingminigame_om_keypress_".. i, randomke)
                entity:SetNW2Bool("clashingminigame_om_keypressed_".. i, false)
            end
        end

        
        local function stunloser(winner, loser)
            Mutaul_OMStunCode(
                {
                    ["ply"] = winner,
                    ["ent"] = winner,
                    ["target"] = loser,
                    ["StunDur"] = 5,
                    ["stunfunction"] = function(shouldstundamage)
                    end,
                    ["shouldstack"] = true,
                    ["Damage"] = 35,
                    ["DamageType"] = DMG_CLUB,
                    ["IgnoreBoundries"] = true
                }
            )
        end

        local hookname = "BackKeyPressed".. ply:EntIndex()
        local starttime = CurTime() + configurations.TimeLimitFloat

        hook.Remove("Think", hookname)
        hook.Add("Think", hookname, function()
            local var1 = false
            if ply.pk_pill_ent then
                if IsValid(ply.pk_pill_ent) then
                    var1 = false
                else
                    var1 = true
                end
            else
            end
            local var2 = !IsValid(ply)
            local var3 = false
            if target.pk_pill_ent then
                if IsValid(target.pk_pill_ent) then
                    var3 = false
                else
                    var3 = true
                end
            else
            end
            local var4 = !IsValid(target)

            if (var1 or var2) or (var3 or var4) then
                if (var1 or var2) then
                    if IsValid(ply) then
                        if ply.OMCompelteClash_lnz then ply.OMCompelteClash_lnz("Loss") end
                        ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    end
                    if IsValid(target) then
                        if target.OMCompelteClash_lnz then target.OMCompelteClash_lnz("Win") end
                        target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    end
                end
                if (var3 or var4) then
                    if IsValid(ply) then
                        if ply.OMCompelteClash_lnz then ply.OMCompelteClash_lnz("Win") end
                        ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    end
                    if IsValid(target) then
                        if target.OMCompelteClash_lnz then target.OMCompelteClash_lnz("Loss") end
                        target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    end
                end
                if IsValid(ply) then
                    ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                end
                if IsValid(target) then
                    target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                end
                hook.Remove("Think", hookname)
            end

            if !IsValid(ply) or !IsValid(target) then
                if (var1 or var2) then
                    if IsValid(ply) then
                        if ply.OMCompelteClash_lnz then ply.OMCompelteClash_lnz("Loss") end
                        ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    end
                    if IsValid(target) then
                        if target.OMCompelteClash_lnz then target.OMCompelteClash_lnz("Loss") end
                        target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    end
                end
                if (var3 or var4) then
                    if IsValid(ply) then
                        if ply.OMCompelteClash_lnz then ply.OMCompelteClash_lnz("Loss") end
                        ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    end
                    if IsValid(target) then
                        if target.OMCompelteClash_lnz then target.OMCompelteClash_lnz("Loss") end
                        target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    end
                end
                if IsValid(ply) then
                    ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                end
                if IsValid(target) then
                    target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                end
                hook.Remove("Think", hookname)
                return
            end

            if ply:Health() <= 0.1 or target:Health() <= 0.1 then 
                if target:Health() <= 0.1 then
                    if IsValid(ply) then
                        if ply.OMCompelteClash_lnz then ply.OMCompelteClash_lnz("Win") end
                    end
                end
                if ply:Health() <= 0.1 then
                    if IsValid(target) then
                        if target.OMCompelteClash_lnz then target.OMCompelteClash_lnz("Loss") end
                    end
                end
                if IsValid(ply) then
                    ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                end
                if IsValid(target) then
                    target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                end
                hook.Remove("Think", hookname)
                return
            end

            local score = configurations.EndRoundLogic()
            if score then
                if IsValid(ply) then
                    if ply.OMCompelteClash_lnz then ply.OMCompelteClash_lnz(score["ply"]) end
                    ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                end
                if IsValid(target) then
                    if target.OMCompelteClash_lnz then target.OMCompelteClash_lnz(score["target"]) end
                    target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                end
                hook.Remove("Think", hookname)
                return
            end

            if starttime < CurTime() and configurations.TimeLimitBool then
                if DamageCurrently > 50 then
                    if ply.OMCompelteClash_lnz then
                        ply.OMCompelteClash_lnz("Win")
                    end
                    if target.OMCompelteClash_lnz then
                        target.OMCompelteClash_lnz("Loss")
                    end

                    ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    stunloser(ply, target)
                    hook.Remove("Think", hookname)
                end
                if DamageCurrently < 50 then
                    if ply.OMCompelteClash_lnz then
                        ply.OMCompelteClash_lnz("Loss")
                    end
                    if target.OMCompelteClash_lnz then
                        target.OMCompelteClash_lnz("Win")
                    end

                    ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    stunloser(target, ply)
                    hook.Remove("Think", hookname)
                end
            end

            if DamageCurrently >= 85 then
                if configurations.CanPlyEndRound then 
                    if ply.OMCompelteClash_lnz then
                        ply.OMCompelteClash_lnz("Win")
                    end
                    if target.OMCompelteClash_lnz then
                        target.OMCompelteClash_lnz("Loss")
                    end

                    ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                    stunloser(ply, target)
                    hook.Remove("Think", hookname)
                end
                DamageCurrently = math.Clamp(DamageCurrently,0,84)
            end

            if DamageCurrently <= 15 then
                if ply.OMCompelteClash_lnz then
                    ply.OMCompelteClash_lnz("Loss")
                end
                if target.OMCompelteClash_lnz then
                    target.OMCompelteClash_lnz("Win")
                end

                ply:SetNW2Bool("clashingminigame_om_isinminigame", false)
                target:SetNW2Bool("clashingminigame_om_isinminigame", false)
                stunloser(target, ply)
                hook.Remove("Think", hookname)
            end

            local tableofentities = {ply, target}
            local tableofnumbs = {1, -1}
            for i,v in ipairs(tableofentities) do

                if not combo[v] then
                    SetUpKeyCombo(v)
                end

                if v == target then
                    local oldfactor = DamageCurrently/100
                    local reverse = Lerp(oldfactor, 100, 0)
                    v:SetNW2Float("DamageCurrently_OM_clashingminigame", reverse)
                else
                    v:SetNW2Float("DamageCurrently_OM_clashingminigame", DamageCurrently)
                end
                
                if (v == ply and configurations.CanPlyplay ) or v == target then

                    local plycurrentlyon = combo[v]['keyison']
                    if plycurrentlyon > 4 then
                        DamageCurrently = DamageCurrently + combo[v]['DamageTake'] * tableofnumbs[i]
                        SetUpKeyCombo(v)
                    else
                        local key
                        if combo[v] then
                            if combo[v][plycurrentlyon] then
                                if combo[v][plycurrentlyon]['Key'] then
                                end
                            end
                        end
                        if v.KeyDown then 
                            v.meanttopress_om = combo[v][plycurrentlyon]['Key']
                            key = v:KeyDown(combo[v][plycurrentlyon]['Key'])
                        else
                            if math.random(1,45) == 1 then key = true end
                        end
                        if key then
                            if not combo[v]["canpress"] then
                                if not v:GetNW2Bool("clashingminigame_om_keypressed_".. plycurrentlyon) then
                                    v:SetNW2Bool("clashingminigame_om_keypressed_".. plycurrentlyon, true)
                                    combo[v]["canpress"] = true
                                end
                            end
                        else
                            if v.KeyDown then 
                                local var = false
                                if v.IsPossessed and not v:IsPossessed() then var = true end
                                if not var then
                                    local oldkeys = combo[v][plycurrentlyon]['Key']
                                    local varW_keydown = (v:KeyDown(IN_FORWARD) and IN_FORWARD ~= oldkeys)
                                    local varS_keydown = (v:KeyDown(IN_BACK) and IN_BACK ~= oldkeys)
                                    local varA_keydown = (v:KeyDown(IN_MOVELEFT) and IN_MOVELEFT ~= oldkeys)
                                    local varD_keydown = (v:KeyDown(IN_MOVERIGHT) and IN_MOVERIGHT ~= oldkeys)
                                    if varW_keydown or varS_keydown or varA_keydown or varD_keydown then
                                        if not combo[v]["canpressMessUp"] then
                                            combo[v]["canpressMessUp"] = true
                                            if (v == ply and configurations.Canplymessup) or (v == target and configurations.Cantargetmessup) then
                                                DamageCurrently = DamageCurrently + combo[v]['DamageTake'] * tableofnumbs[i] * -0.6
                                            end
                                        end
                                    else
                                        if combo[v]["canpressMessUp"] then
                                            combo[v]["canpressMessUp"] = false
                                        end
                                    end
                                else
                                    if math.random(1,250) == 1 then 
                                        if (v == ply and configurations.Canplymessup) or (v == target and configurations.Cantargetmessup) then
                                            DamageCurrently = DamageCurrently + combo[v]['DamageTake'] * tableofnumbs[i] * -0.6
                                        end
                                    end
                                end
                            end
                            if v:GetNW2Bool("clashingminigame_om_keypressed_".. plycurrentlyon) then
                                combo[v]['keyison'] = combo[v]['keyison'] + 1
                                combo[v]["canpress"] = false
                            end
                        end
                    end
                end
            end
        end)
    end
else
    local preservedmats = {
        ["OM_icon"] = Material("icons/Polygon_of_doom.png"),
        ["OM_icon_monster"] = Material("icons/Polygon_of_DEVI.png"),
        ["Ability_arrow"] = Material("icons/Ability_arrow.png"),
        ["health_bar_remake"] = Material("icons/health_bar_remake.png"),
        ["om_dirt"] = Material("icons/om_dirt.png"),
        ["dodge_bar_new"] = Material("icons/dodge_bar_new.png"),
        ["dodge_bar_meter"] = Material("icons/dodge_bar_meter.png"),
        ["cooldown_square_surv"] = Material("icons/cooldown_square_surv.png"),
        ["cooldown_square_exe"] = Material("icons/cooldown_square_exe.png"),
        ["self_revive"] = Material("icons/self_revive.png"),
        ["Clash_arrows"] = Material("icons/Clash_arrows.png"),
        ["barprogressio"] = Material("icons/barprogressio.png"),
        ["Clash_bar"] = Material("icons/Clash_bar.png"),
        ["Clash_arrows_pressed"] = Material("icons/Clash_arrows_pressed.png"),
        ["downed_blood"] = Material("icons/downed_blood.png"),
        ["clash_arrows_circle"] = Material("icons/clash_arrows_circle.png"),
    }

    local smoothAngles = {}
    local pressAnim = {}
    local smoothBar = 0

    function MINIgame_drawhud_om()


        local ply = LocalPlayer()
        local pillentity = LocalPlayer()
        local isdrgbase = false

        if IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end
        
        if not pillentity:GetNW2Bool("clashingminigame_om_isinminigame") then return end

        local screenW, screenH = ScrW(), ScrH()
        local middlex, middley = screenW * 0.5, screenH * 0.5
        local iconsize = screenW / 6.5

        local targetFactor = math.Clamp(
            pillentity:GetNW2Float("DamageCurrently_OM_clashingminigame") / 100,
            0,
            1
        )

        smoothBar = math.Approach(
            smoothBar,
            targetFactor,
            0.5 * FrameTime()
        )

        local t = smoothBar
        local eased = t * t * (3 - 2 * t)

        local ColorR, ColorG, ColorB, ColorA = ply:GetNW2Float("ColorRGB_R_2_OM")*0.75, ply:GetNW2Float("ColorRGB_G_2_OM")*0.75, ply:GetNW2Float("ColorRGB_B_2_OM")*0.75, ply:GetNW2Float("ColorRGB_A_2_OM")
        if ply:GetNW2Float('OM_PointOfView') == 1 then
            ColorR = ply:GetNW2Float("ColorRGB_R_1_OM")
            ColorG = ply:GetNW2Float("ColorRGB_G_1_OM")
            ColorB = ply:GetNW2Float("ColorRGB_B_1_OM")
            ColorA = ply:GetNW2Float("ColorRGB_A_1_OM")
        end
        surface.SetMaterial(preservedmats["barprogressio"])
        surface.SetDrawColor(ColorR,ColorG,ColorB,ColorA)
        surface.DrawTexturedRectUV(
            middlex - iconsize * 1,
            middley * 1.5,
            (iconsize * 2),
            iconsize * 1.5 * 0.75 * 0.5,
            0, 0, 1, 1
        )

        local ColorR, ColorG, ColorB, ColorA = ply:GetNW2Float("ColorRGB_R_1_OM"), ply:GetNW2Float("ColorRGB_G_1_OM"), ply:GetNW2Float("ColorRGB_B_1_OM"), ply:GetNW2Float("ColorRGB_A_1_OM")

        if ply:GetNW2Float('OM_PointOfView') == 1 then
            ColorR = ply:GetNW2Float("ColorRGB_R_2_OM")*0.75
            ColorG = ply:GetNW2Float("ColorRGB_G_2_OM")*0.75
            ColorB = ply:GetNW2Float("ColorRGB_B_2_OM")*0.75
            ColorA = ply:GetNW2Float("ColorRGB_A_2_OM")
        end

        surface.SetMaterial(preservedmats["barprogressio"])
        surface.SetDrawColor(ColorR,ColorG,ColorB,ColorA)
        surface.DrawTexturedRectUV(
            middlex - iconsize * 1,
            middley * 1.5,
            (iconsize * 2) * eased,
            iconsize * 1.5 * 0.75 * 0.5,
            0, 0, eased, 1
        )

        surface.SetMaterial(preservedmats["Clash_bar"])
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRectUV(
            middlex - iconsize * 1,
            middley * 1.5,
            (iconsize * 4) * 0.5,
            iconsize * 1.5 * 0.75 * 0.5,
            0, 0, 1, 1
        )

        for i = 1, 4 do
            if ply:GetNW2Bool("clashingminigame_om_isinminigame_canplay") then
                local name = pillentity:GetNW2Int("clashingminigame_om_keypress_" .. i)
                local pressed = pillentity:GetNW2Bool("clashingminigame_om_keypressed_" .. i)

                local iconsize2 = iconsize * 0.5

                local xaxis_btn1 = middlex - iconsize2 * 0.5 * (3 - i)
                local yaxis_btn1 = middley * 1.5 - iconsize2 * 0.35

                local targetYaw = 0

                if name == IN_FORWARD then
                    targetYaw = 180
                elseif name == IN_MOVERIGHT then
                    targetYaw = -90
                elseif name == IN_MOVELEFT then
                    targetYaw = 90
                else
                    targetYaw = 0
                end

                smoothAngles[i] = smoothAngles[i] or 0

                smoothAngles[i] = math.ApproachAngle(
                    smoothAngles[i],
                    targetYaw,
                    800 * FrameTime()
                )

                local targetPress = pressed and 1 or 0

                pressAnim[i] = pressAnim[i] or 0

                pressAnim[i] = math.Approach(
                    pressAnim[i],
                    targetPress,
                    6 * FrameTime()
                )

                local t = pressAnim[i]
                local bezier = t * t * (3 - 2 * t)

                local scale = 1 + (0.25 * bezier)

                local centerX = xaxis_btn1 + iconsize2 * 0.25
                local centerY = yaxis_btn1 + iconsize2 * 0.25

                local mat = Matrix()
                mat:Translate(Vector(centerX, centerY))
                mat:Scale(Vector(scale, scale, 1))
                mat:Rotate(Angle(0, smoothAngles[i], 0))
                mat:Translate(Vector(-centerX, -centerY))


                surface.SetMaterial(preservedmats["clash_arrows_circle"])
                surface.SetDrawColor(255,255,255,255)
                surface.DrawTexturedRectUV(
                    xaxis_btn1,
                    yaxis_btn1,
                    iconsize2 * 0.5,
                    iconsize2 * 0.5,
                    0, 0, 1, 1
                )
                
                cam.PushModelMatrix(mat)

                    surface.SetDrawColor(255, 255, 255, 255)

                    if pressed then
                        surface.SetMaterial(preservedmats["Clash_arrows_pressed"])
                    else
                        surface.SetMaterial(preservedmats["Clash_arrows"])
                    end
                    surface.DrawTexturedRectUV(
                        xaxis_btn1,
                        yaxis_btn1,
                        iconsize2 * 0.5,
                        iconsize2 * 0.5,
                        0, 0, 1, 1
                    )
                cam.PopModelMatrix()
            end
        end

        if ply:GetNW2Bool("clashingminigame_om_isinminigame_TimeLimitBool") then
            local progress = (ply:GetNW2Float("clashingminigame_om_isinminigame_TimeLimitFloat")-CurTime())/ply:GetNW2Float("clashingminigame_om_isinminigame_TimeLimitFloat_duration")

            local xaxisarea = middlex - iconsize * 0.5 * 1.45
            local yaxisarea = middley + iconsize * 1.65 * 0.75 * 0.5
            local wwidth = iconsize * 1.45
            local hhight = iconsize * 0.1

            local factor = math.Clamp(progress, 0, 1)

            draw.RoundedBox(6, xaxisarea, yaxisarea, wwidth, hhight, Color(80, 20, 20, 220))

            local t = math.Clamp((0.5 - factor) / (0.5 - 0.1), 0, 1)

            local greenColor = Color(80, 255, 120, 220)
            local yellowColor = Color(255, 230, 80, 220)

            local barColor = Color(
                Lerp(t, greenColor.r, yellowColor.r),
                Lerp(t, greenColor.g, yellowColor.g),
                Lerp(t, greenColor.b, yellowColor.b),
                220
            )

            draw.RoundedBox(6, xaxisarea, yaxisarea, wwidth * factor, hhight, barColor)

            surface.SetDrawColor(255, 255, 255, 25)
            surface.DrawRect(xaxisarea + 2, yaxisarea + 2, wwidth - 4, 1)
        end
        
    end
end