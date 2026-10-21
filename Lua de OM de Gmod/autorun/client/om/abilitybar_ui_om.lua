AddCSLuaFile()
if SERVER then
    -- flight handler
    function OM_base_FlyingEnd(ply, ent)
        local phys = ent.flyingent:GetPhysicsObject()
        if phys:IsValid() then
            ply:SetVelocity(phys:GetVelocity()*0.6)
        end

        ent.flyingent:Remove()
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
    end

    function OM_base_FlyMovement(ply, ent, options, move, aim, fly)
        if IsValid(fly) then
            ent.Flightmovelength = move:Length()
            ent:SetNW2Float("Flightmovelength", ent.Flightmovelength)

            local flyingangles = fly:GetAngles()

            if ent.flight_limitpitch then flyingangles.p = 0 end

            flyingangles.p = math.Clamp(flyingangles.p, -75, 75)

            local function GetMovement(ignoreZ)
                local puppet = ent:GetPuppet()
                local dir = ply:GetVelocity()
                if ignoreZ then dir.z = 0 end
                return (ent:GetPuppet():GetAngles() - (move):Angle() ):Forward()
            end

            local function IsMovingUp(ent)
                return math.Round(GetMovement().z) > 0
            end

            local function IsMovingDown(ent)
                return math.Round(GetMovement().z) < 0
            end

            local function IsMovingForward(ent)
                return math.Round(GetMovement().x) > 0
            end

            local function IsMovingBackward(ent)
                return math.Round(GetMovement().x) < 0
            end

            local function IsMovingRight(ent)
                return math.Round(GetMovement().y) > 0
            end

            local function IsMovingLeft(ent)
                return math.Round(GetMovement().y) < 0
            end

            local function IsMovingForwardLeft(ent)
                return IsMovingForward(ent) and IsMovingLeft(ent)
            end

            local function IsMovingForwardRight(ent)
                return IsMovingForward(ent) and IsMovingRight(ent)
            end

            local rotationfactor = math.Clamp(ent:GetNW2Float("SpeedAccelerate") / 8, 0, 2.5)

            if IsMovingLeft(ent) then
                flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), -4 * rotationfactor)
            elseif IsMovingRight(ent) then
                flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), 4 * rotationfactor)
            else
                flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), 0)
            end
            if IsMovingForward(ent) then
                flyingangles:RotateAroundAxis(ent:GetPuppet():GetRight(), -4 * rotationfactor)
            elseif IsMovingBackward(ent) then
                flyingangles:RotateAroundAxis(ent:GetPuppet():GetRight(), 6 * rotationfactor)
            else
            end

            if move == Vector(0,0,0) then
            end

            ent:SetNW2Angle("pill_assignedangle", flyingangles)

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

            ent:SetNW2Vector("CurrentVelocity_fly", LerpVector(FrameTime()*3.65, ent:GetNW2Vector("CurrentVelocity_fly", Vector(0,0,0)), move*1 ))
            
            move = ent:GetNW2Vector("CurrentVelocity_fly")

            local function SlideMove(move, normal)
                local dot = move:Dot(normal)
                if dot < 0 then
                    move = move - normal * dot
                end
                return move
            end

            local probeDist = 20 + options["speed"]
            local dir = move:GetNormalized()
            local dirAng = dir:Angle()

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

            local finalAng = Angle(aim.p, aim.y, 0)

            fly:SetAngles(finalAng)

            local mins, max
            if ply:IsPlayer() then
                if ply:Crouching() then
                    mins, maxs = ply:GetHullDuck()
                else
                    mins, maxs = ply:GetHull()
                end
            else
                mins, maxs = ply:GetCollisionBounds()
            end

            local hullTrace = util.TraceHull({
                start = origin,
                endpos = origin + move,
                mins = mins,
                maxs = maxs,
                filter = extrmeelyoverusedffunction
            })

            local oldflypos = fly:GetPos()

            if hullTrace.Hit then
                move = SlideMove(move, hullTrace.HitNormal)
                fly:SetPos(origin + move * hullTrace.Fraction)
            else
                fly:SetPos(origin + move)
            end

            --[[
            if tr_f.Hit then
                ent:SetNW2Float(
                    "SpeedAccelerate",
                    math.Clamp( ent:GetNW2Float("SpeedAccelerate"), 5, math.Clamp((oldflypos - (origin + move)):Length(), 1, 1000) )
                )
            end
            ]]

            local oldplypos = ply:GetPos()
            ply:SetPos(fly:GetPos())
        end
    end
end

--
if CLIENT then

    local preservedmats = {
        ["OM_icon"] = Material("icons/Polygon_of_DEVI.png"),
        ["Ability_arrow"] = Material("icons/Ability_arrow.png"),
        ["Health_DEVI"] = Material("icons/Health_DEVI.png"),
        ["Flight_bar"] = Material("icons/Flight_bar.png"),
        ["flight_bar_new"] = Material("icons/flight_bar_new.png"),
        ["jetpackbar"] = Material("icons/eggman jetpack bar.png")
    }

    surface.CreateFont("OM_FlightBarFont_flightbar", {
        font = "Arial",
        size = 22 * 40,
        weight = 900,
        antialias = true,
        extended = true
    })

    hook.Add("PostDrawOpaqueRenderables", "om_bar_drawUI_OM_noodles2", function()
        local ply = LocalPlayer()
        local pillentity = ply.pk_pill_ent
        local isdrgbase = false

        if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end

        if IsValid(pillentity) then
            if pillentity.formTable then
                if not pillentity.GetPuppet then return end
                local puppet = pillentity:GetPuppet()
                if !IsValid(puppet) then return end 

                if not pillentity.OM_transitionbar_type1 then
                    pillentity.OM_transitionbar_type1 = 0
                end

                local table_ability = pillentity.formTable.OM_transitionbar_type1table
                if table_ability then
                    local color = (table_ability.ColorDisplay and ((isfunction(table_ability.ColorDisplay) and table_ability:ColorDisplay(ply, pillentity)) or table_ability.ColorDisplay) ) or Color(255,255,255,255)


                    if table_ability and (table_ability.CanShowcase and table_ability:CanShowcase(ply, pillentity) ) then
                        pillentity.OM_transitionbar_type1 = Lerp(FrameTime()*2, pillentity.OM_transitionbar_type1, 1)
                    else
                        pillentity.OM_transitionbar_type1 = Lerp(FrameTime()*2, pillentity.OM_transitionbar_type1, 0)
                    end 

                    if IsValid(puppet) and pillentity.OM_transitionbar_type1 > 0.05 then
                        
                        local ang = EyeAngles()
                        ang:RotateAroundAxis(ang:Right(), 90)
                        ang:RotateAroundAxis(ang:Up(), -90)


                        local offset = table_ability.offset and ((isfunction(table_ability.offset) and table_ability:offset(ply,pillentity)) or table_ability.offset) or Vector(0,0,0)
                        local pos = pillentity:GetPos() + ang:Right()* (-25+offset.x) + ang:Forward()* (25+offset.y) * pillentity.OM_transitionbar_type1

                        cam.Start3D2D(pos, ang, 1/35)-- 
                            local bar = (table_ability.Factor and ((isfunction(table_ability.Factor) and table_ability:Factor(ply, pillentity)) or table_ability.Factor) ) or 0
                            local barFrac = bar / 1

                            local xaxis, yaxis = -16 * 15, -44 * 15
                            local xsize, ysize = 32 * 15, 88 * 15

                            local xaxis_bar, yaxis_bar = -5.5 * 15, -42 * 15
                            local xsize_bar, ysize_bar = 16.5 * 15, 84 * 15

                            render.ClearStencil()
                            render.SetStencilEnable(true)

                            render.SetStencilWriteMask(255)
                            render.SetStencilTestMask(255)

                            render.SetStencilReferenceValue(1)

                            render.SetStencilCompareFunction(STENCIL_ALWAYS)
                            render.SetStencilPassOperation(STENCIL_REPLACE)
                            render.SetStencilFailOperation(STENCIL_KEEP)
                            render.SetStencilZFailOperation(STENCIL_KEEP)

                            -- Write the polygon into the stencil
                            draw.NoTexture()
                            surface.SetDrawColor(255,255,255,1)
                            surface.DrawPoly({
                                { x = xaxis_bar,                 y = yaxis_bar + ysize_bar * 0.1 },
                                { x = xaxis_bar + xsize_bar*0.7, y = yaxis_bar },
                                { x = xaxis_bar + xsize_bar,     y = yaxis_bar },
                                { x = xaxis_bar + xsize_bar,     y = yaxis_bar + ysize_bar * 0.95 },
                                { x = xaxis_bar,                 y = yaxis_bar + ysize_bar }
                            })

                            -- Only draw where the stencil == 1
                            render.SetStencilCompareFunction(STENCIL_EQUAL)
                            render.SetStencilPassOperation(STENCIL_KEEP)

                            surface.SetDrawColor(color.r*0.5, color.g*0.5, color.b*0.5, color.a * pillentity.OM_transitionbar_type1)
                            surface.DrawRect(xaxis_bar, yaxis_bar, xsize_bar, ysize_bar)

                            local fillY = Lerp(barFrac, yaxis_bar + ysize_bar, yaxis_bar)
                            local fillHeight = Lerp(barFrac, 0, ysize_bar)

                            surface.SetDrawColor(color.r, color.g, color.b, color.a * pillentity.OM_transitionbar_type1)
                            surface.DrawRect(xaxis_bar, fillY, xsize_bar, fillHeight)

                            render.SetStencilEnable(false)

                            surface.SetDrawColor(255, 255, 255, 255*pillentity.OM_transitionbar_type1)
                            surface.SetMaterial(preservedmats["Flight_bar"])
                            surface.DrawTexturedRect(xaxis, yaxis, xsize, ysize)



                        cam.End3D2D()
                    end
                end
                    
                local table_ability = pillentity.formTable.OM_transitionbar_type2table
                if table_ability then
                    pillentity.OM_transitionbar_type2 = pillentity.OM_transitionbar_type2 or 0

                    if table_ability and (table_ability.CanShowcase and table_ability:CanShowcase(ply, pillentity) ) then
                        pillentity.OM_transitionbar_type2 = math.Approach(
                            pillentity.OM_transitionbar_type2,
                            255,
                            FrameTime() * 200
                        )
                    else
                        pillentity.OM_transitionbar_type2 = math.Approach(
                            pillentity.OM_transitionbar_type2,
                            0,
                            FrameTime() * 100
                        )
                    end

                    if pillentity.OM_transitionbar_type2 >= 0.1 then
                        local ang = EyeAngles()
                        ang:RotateAroundAxis(ang:Right(), 90)
                        ang:RotateAroundAxis(ang:Up(), -90)

                        local offset = table_ability.offset and ((isfunction(table_ability.offset) and table_ability:offset(ply,pillentity)) or table_ability.offset) or Vector(0,0,0)
                        local pos = pillentity:GetPos() + Vector(0, 0, 60 + offset.x) + ang:Forward()* (30+offset.y)

                        cam.Start3D2D(pos, ang, 1/15)

                            local bar = (table_ability.Factor and ((isfunction(table_ability.Factor) and table_ability:Factor(ply, pillentity)) or table_ability.Factor) ) or 0

                            local xaxis, yaxis = -4 * 8, -100*0.5 * 8
                            local xsize, ysize = 8 * 8, 100 * 8

                            surface.SetDrawColor(25, 25, 25, pillentity.OM_transitionbar_type2)
                            surface.SetMaterial(preservedmats["jetpackbar"])
                            surface.DrawTexturedRectUV(xaxis, yaxis, xsize, ysize, 0,0,1,1)

                            surface.SetDrawColor(255, 165, 165, pillentity.OM_transitionbar_type2)
                            surface.SetMaterial(preservedmats["jetpackbar"])
                            surface.DrawTexturedRectUV(xaxis, yaxis, xsize, ysize*bar, 0,0,1,1*bar)

                        cam.End3D2D()
                    end
                end


                if pillentity:GetNW2Bool("HasFlyCompad_OM") then
                    local puppet = pillentity:GetPuppet()
                    local flying = pillentity:GetNW2Entity("flyingent")
                    local maximum = pillentity:GetNW2Float("OM_maximum_flight")

                    if not pillentity.FlyingBar_bar then
                        pillentity.FlyingBar_bar = 0
                    end
                    if not pillentity.FlyingBarfrac_amount then
                        pillentity.FlyingBarfrac_amount = 0
                    end
                    if not pillentity.FlyingBar_sidetoside_bar then
                        pillentity.FlyingBar_sidetoside_bar = 0
                    end
                    if not pillentity.FlyingBar_fronttoback_bar then
                        pillentity.FlyingBar_fronttoback_bar = 0
                    end

                    if not pillentity.FlyingBar_amount then
                        pillentity.FlyingBar_amount = maximum
                    end

                    if IsValid(puppet) and IsValid(flying) then
                        pillentity.FlyingBar_bar = Lerp(FrameTime()*3, pillentity.FlyingBar_bar, 1)
                    else
                        pillentity.FlyingBar_bar = Lerp(FrameTime()*3, pillentity.FlyingBar_bar, 0)
                    end

                    --pillentity.FlyingBar_bar = 1

                    if pillentity.FlyingBar_bar > 0.085 then
                        local bar = math.Clamp(pillentity:GetNW2Float("OM_Fleetway_flyingBar") or 0, 0, maximum)
                        local barFrac = bar / maximum

                        pillentity.FlyingBar_amount = Lerp(FrameTime()*3, pillentity.FlyingBar_amount, bar)
                        pillentity.FlyingBarfrac_amount = Lerp(FrameTime()*3, pillentity.FlyingBarfrac_amount, barFrac)

                        bar = pillentity.FlyingBar_amount
                        barFrac = pillentity.FlyingBarfrac_amount

                        local ang = EyeAngles()
                        ang:RotateAroundAxis(ang:Right(), 90)
                        ang:RotateAroundAxis(ang:Up(), -90)
                        ang:RotateAroundAxis(ang:Forward(), 0)

                        local function GetMovement(ignoreZ)
                            local puppet = pillentity:GetPuppet()
                            local dir = ply:GetVelocity()
                            if ignoreZ then dir.z = 0 end
                            return (pillentity:GetPuppet():GetAngles() - (pillentity:GetNW2Vector("CurrentVelocity_fly")):Angle() ):Forward()
                        end
                        local function IsMovingForward(ent) return math.Round(GetMovement().x) > 0 end
                        local function IsMovingBackward(ent) return math.Round(GetMovement().x) < 0 end
                        local function IsMovingRight(ent) return math.Round(GetMovement().y) > 0 end
                        local function IsMovingLeft(ent) return math.Round(GetMovement().y) < 0 end

                        local side = 0

                        if math.abs(pillentity:GetNW2Vector("CurrentVelocity_fly").y) < 5 then
                            pillentity.FlyingBar_sidetoside_bar = Lerp(FrameTime()*1, pillentity.FlyingBar_sidetoside_bar, 0)
                        else
                            if IsMovingLeft(pillentity) then
                                pillentity.FlyingBar_sidetoside_bar = Lerp(FrameTime()*1, pillentity.FlyingBar_sidetoside_bar, 3)
                            elseif IsMovingRight(pillentity) then
                                pillentity.FlyingBar_sidetoside_bar = Lerp(FrameTime()*1, pillentity.FlyingBar_sidetoside_bar, -3)
                            end
                        end
                        if math.abs(pillentity:GetNW2Vector("CurrentVelocity_fly").x) < 5 then
                            pillentity.FlyingBar_fronttoback_bar = Lerp(FrameTime()*1, pillentity.FlyingBar_fronttoback_bar, 0)
                        else
                            if IsMovingForward(pillentity) then
                                pillentity.FlyingBar_fronttoback_bar = Lerp(FrameTime()*1, pillentity.FlyingBar_fronttoback_bar, -15)
                            elseif IsMovingBackward(pillentity) then
                                pillentity.FlyingBar_fronttoback_bar = Lerp(FrameTime()*1, pillentity.FlyingBar_fronttoback_bar, 15)
                            end
                        end

                        local pos = pillentity:GetPos() + ang:Right()* -40 + ang:Forward()* 35 * pillentity.FlyingBar_bar

                        if IsMovingBackward(pillentity) then
                        end
                        --math.sin(CurTime() * 1) * 3 
                        ang:RotateAroundAxis(ang:Right(), 0)
                        ang:RotateAroundAxis(ang:Up(), 0+ pillentity.FlyingBar_sidetoside_bar)
                        ang:RotateAroundAxis(ang:Forward(), 0 + pillentity.FlyingBar_fronttoback_bar)

                        cam.Start3D2D(pos, ang, 1/35)

                            local barXAxis = -9 * 18 *pillentity.FlyingBar_bar
                            local barXAxis_refill = -16 * 20 *pillentity.FlyingBar_bar

                            local barYAxis = -39*1.175 * 20 *pillentity.FlyingBar_bar
                            local barYAxis_refill = -44*1.175 * 20 *pillentity.FlyingBar_bar

                            local BarXSize = 13*0.85 * 20 *pillentity.FlyingBar_bar
                            local BarXSize_refill = 32*0.85 * 20 *pillentity.FlyingBar_bar

                            local BarYSize = 77*1.175 * 20 *pillentity.FlyingBar_bar
                            local BarYSize_refill = 88*1.175 * 20 *pillentity.FlyingBar_bar

                            local r, g, b

                            if barFrac > 0.5 then
                                local t = (1 - barFrac) * 2

                                r = Lerp(t, 75, 255)
                                g = Lerp(t, 75, 255)
                                b = Lerp(t, 255, 0)
                            else
                                local t = (0.5 - barFrac) * 2

                                r = 255
                                g = Lerp(t, 255, 0)
                                b = 0
                            end

                            local alpha = 255 * pillentity.FlyingBar_bar

                            r = 75
                            g = 75
                            b = 255

                            local barcolor = Color(r, g, b, alpha)

                            local barcolor_2nd = Color(
                                math.min(r + 40, 255),
                                math.min(g + 40, 255),
                                math.min(b + 40, 255),
                                alpha
                            )

                            local barcolor3 = Color(
                                math.min(r + 175, 255),
                                math.min(g + 175, 255),
                                math.min(b + 175, 255),
                                alpha
                            )

                            render.ClearStencil()
                            render.SetStencilEnable(true)

                            render.SetStencilWriteMask(255)
                            render.SetStencilTestMask(255)
                            render.SetStencilReferenceValue(1)

                            render.SetStencilCompareFunction(STENCIL_ALWAYS)
                            render.SetStencilPassOperation(STENCIL_REPLACE)
                            render.SetStencilFailOperation(STENCIL_KEEP)
                            render.SetStencilZFailOperation(STENCIL_KEEP)

                            draw.NoTexture()
                            surface.SetDrawColor(255, 255, 255, 1)
                            surface.DrawPoly({
                                { x = barXAxis,                   y = barYAxis },
                                { x = barXAxis + BarXSize,        y = barYAxis + 6*20 },
                                { x = barXAxis + BarXSize,        y = barYAxis + BarYSize },
                                { x = barXAxis,                   y = barYAxis + BarYSize - 8*20 },
                            })

                            render.SetStencilCompareFunction(STENCIL_EQUAL)
                            render.SetStencilPassOperation(STENCIL_KEEP)

                            for i = 0, BarYSize, 10 do
                                local t = i / BarYSize

                                local c = Lerp(t, 95, 25)

                                surface.SetDrawColor(c*1.25, c*0.9, c*0.9, alpha)
                                surface.DrawRect(
                                    barXAxis,
                                    barYAxis + i,
                                    BarXSize,
                                    10
                                )
                            end
                            --[[
                            surface.SetDrawColor(75, 75, 75, 255 * pillentity.FlyingBar_bar)
                            surface.DrawRect(barXAxis, barYAxis, BarXSize, BarYSize)
                            ]]

                            local fillY = Lerp(barFrac, barYAxis + BarYSize, barYAxis)
                            local fillHeight = Lerp(barFrac, 0, BarYSize)

                            --[[
                            surface.SetDrawColor(barcolor.r, barcolor.g, barcolor.b, barcolor.a * pillentity.FlyingBar_bar)
                            surface.DrawRect(barXAxis, fillY, BarXSize, fillHeight)
                            ]]


                            for i = 0, fillHeight, 10 do

                                local t = i / math.max(fillHeight,1)

                                local rr = Lerp(t, barcolor.r + 95, barcolor.r)
                                local gg = Lerp(t, barcolor.g + 95, barcolor.g)
                                local bb = Lerp(t, barcolor.b + 95, barcolor.b)

                                if i <= 10 then
                                    surface.SetDrawColor(255,255,255, alpha)
                                else
                                    surface.SetDrawColor(rr, gg, bb, alpha)
                                end

                                surface.DrawRect(
                                    barXAxis,
                                    fillY + i,
                                    BarXSize,
                                    10
                                )
                            end

                            render.SetStencilEnable(false)

                            surface.SetDrawColor(255, 255, 255, 255 * pillentity.FlyingBar_bar)
                            surface.SetMaterial(preservedmats["flight_bar_new"])
                            surface.DrawTexturedRect(barXAxis_refill, barYAxis_refill, BarXSize_refill, BarYSize_refill)

                            surface.SetDrawColor(255, 255, 255, 255, 255 * pillentity.FlyingBar_bar)
                            surface.DrawRect(7 * 20*pillentity.FlyingBar_bar, -2 * 20*pillentity.FlyingBar_bar, 25 * 20*pillentity.FlyingBar_bar, 1 * 20*pillentity.FlyingBar_bar)

                            local scale = pillentity.FlyingBar_bar

                            draw.SimpleTextOutlined(
                                math.Round(bar),
                                "OM_FlightBarFont_flightbar",
                                9 * 20 * scale,
                                -14 * 20 * scale,
                                Color(barcolor3.r, barcolor3.g, barcolor3.b, 255 * scale),
                                TEXT_ALIGN_LEFT,
                                TEXT_ALIGN_TOP,
                                math.max(1, 10 * scale),
                                Color(0, 0, 0, 255 * scale)
                            )

                            draw.SimpleTextOutlined(
                                maximum,
                                "OM_FlightBarFont_flightbar",
                                9 * 20 * scale,
                                -2 * 20 * scale,
                                Color(barcolor_2nd.r, barcolor_2nd.g, barcolor_2nd.b, 255 * scale),
                                TEXT_ALIGN_LEFT,
                                TEXT_ALIGN_TOP,
                                math.max(1, 10 * scale),
                                Color(0, 0, 0, 255 * scale)
                            )

                        cam.End3D2D()
                    end
                end



                for _, ent2 in ipairs(ents.GetAll()) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then

                        ent2.shadow_om_bullet_lerp = ent2.shadow_om_bullet_lerp or 0

                        if pillentity:GetNW2Float("Shadow_showcharacter_".. tostring(ent2)) > CurTime() then
                            ent2.shadow_om_bullet_lerp = Lerp(FrameTime()*5, ent2.shadow_om_bullet_lerp, 255)
                        else
                            ent2.shadow_om_bullet_lerp = Lerp(FrameTime()*5, ent2.shadow_om_bullet_lerp, 0)
                        end

                        if ent2.shadow_om_bullet_lerp > 0.05 then
                            local ang = EyeAngles()
                            ang:RotateAroundAxis(ang:Right(), 90)
                            ang:RotateAroundAxis(ang:Up(), -90)

                            local pos = ent2:GetPos() + Vector(0, 0, 60) + ang:Forward()* 30

                            cam.Start3D2D(pos, ang, 0.5)

                                local bar = math.Clamp( ent2:GetNWFloat("ShadowBulletHitCount") / 6, 0, 1 )--math.Clamp((cooldown - CurTime()) / 10, 0, 1)

                                surface.SetDrawColor(25, 25, 25, ent2.shadow_om_bullet_lerp)
                                surface.SetMaterial(preservedmats["jetpackbar"])
                                surface.DrawTexturedRectUV(-4, -100*0.5, 8, 100, 0,0,1,1)

                                surface.SetDrawColor(255, 165, 165, ent2.shadow_om_bullet_lerp)
                                surface.SetMaterial(preservedmats["jetpackbar"])
                                surface.DrawTexturedRectUV(-4, -100*0.5, 8, 100*bar, 0,0,1,1*bar)

                            cam.End3D2D()
                        end
                    end
                end


            end
        end
    end)
end