AddCSLuaFile()
if SERVER then
end

--
if CLIENT then
    hook.Add("pre_afterimage_om", "end_afterimage_OM_noodles", function()
        for _, ent in ipairs(ents.GetAll()) do
            if !IsValid(ent) then continue end
            if ent:GetNoDraw() then continue end

            local expire = ent:GetNW2Float("end_afterimage_debuff_duration", 0)
            if expire >= CurTime() then
                om_afterimage.Add({
                    entities = ent,
                    color = Color(255,0,0,15),
                    lifeTime = 0.2,
                    afterimagecooldown = 0.015,
                    name = "end_afterimage_debuff_duration",
                    shouldnolighting = true,
                })
            end
        end
    end)

    local vignette = Material("icons/om_end_vignette.png")

    hook.Add("HUDPaint", "end_vignette", function()
        local ply = LocalPlayer()
        local pillentity = ply.pk_pill_ent

        if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
        end

        if not IsValid(pillentity) then return end
        if not pillentity.formTable or pillentity.formTable.Outcomememories ~= "End" then return end

        local frac = pillentity.end_dive_ability1_activated_lerp or 0
        if frac <= 0.001 then return end

        surface.SetMaterial(vignette)
        surface.SetDrawColor(255, 255, 255, 255 * frac)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end)

    hook.Add("RenderScreenspaceEffects", "end_renderscreen", function()
        local ply = LocalPlayer()
        local pillentity = ply.pk_pill_ent
        local isdrgbase = false

        if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end

        if IsValid(pillentity) then
            if pillentity.formTable and pillentity.formTable.Outcomememories == "End" then
                local ent = pillentity

                ent.end_dive_ability1_activated_lerp = ent.end_dive_ability1_activated_lerp or 0

                        
                if ent:GetNW2Bool("end_dive_ability1_activated") or ent:GetNW2Float("end_diving_ability1_duration_inportal") > CurTime() then  
                    ent.end_dive_ability1_activated_lerp = Lerp(FrameTime()*3, ent.end_dive_ability1_activated_lerp, 1)
                else
                    ent.end_dive_ability1_activated_lerp = Lerp(FrameTime()*3, ent.end_dive_ability1_activated_lerp, 0)
                end

                DrawColorModify({
                    ["$pp_colour_addr"]       = -0.05 * ent.end_dive_ability1_activated_lerp,
                    ["$pp_colour_addg"]       = -0.05 * ent.end_dive_ability1_activated_lerp,
                    ["$pp_colour_addb"]       = 0.1 * ent.end_dive_ability1_activated_lerp,

                    ["$pp_colour_brightness"] = 0,
                    ["$pp_colour_contrast"]   = 1,
                    ["$pp_colour_colour"]     = 1 - 0.15 * ent.end_dive_ability1_activated_lerp,

                    ["$pp_colour_mulr"]       = 0,
                    ["$pp_colour_mulg"]       = 0,
                    ["$pp_colour_mulb"]       = 1*0.5 * ent.end_dive_ability1_activated_lerp
                })
            end
        end
    end)

    local inkBubbleMat = Material("models/noodles/OM/end/material")

    hook.Add("PostDrawTranslucentRenderables", "OM_highlight_end", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        cam.Start3D()

        render.OverrideBlend(
            true,
            BLEND_SRC_ALPHA,
            BLEND_ONE_MINUS_SRC_ALPHA,
            BLENDFUNC_ADD
        )

        for _, v in ipairs(ents.GetAll()) do
            if not IsValid(v) or v == ply then continue end

            local endTime = v:GetNW2Float("end_bubble_formation", 0)

            if not v.end_bubble_formation then v.end_bubble_formation = 0 end

            if endTime >= CurTime() then
                v.end_bubble_formation = Lerp(FrameTime()*4, v.end_bubble_formation, 1)
            else
                v.end_bubble_formation = Lerp(FrameTime()*9, v.end_bubble_formation, 0)
            end

            if v.end_bubble_formation <= 0.1 then continue end
            local factor = v.end_bubble_formation

            local pos = v:GetPos() + Vector(0,0,40)

            local wobble =
                math.sin(CurTime() * 4 + v:EntIndex()) * 4 +
                math.cos(CurTime() * 7 + v:EntIndex()) * 2

            local size = 45 + wobble

            render.SuppressEngineLighting(false)

            local matrix = Matrix()
            matrix:Translate(pos)

            local stretch = 1 + math.sin(CurTime() * 5) * 0.08

            matrix:Scale(Vector(
                (size / 50),
                (size / 50),
                (size / 50) * stretch
            ))

            cam.PushModelMatrix(matrix)
                render.SetMaterial(inkBubbleMat)

                render.SetColorModulation(0.01, 0.01, 0.01)
                render.SetBlend(0.10)


                local t = CurTime() + v:EntIndex()

                local innerPos = Vector(
                    math.sin(t * 2) * 1.5,
                    math.cos(t * 2.5) * 1.5,
                    math.sin(t * 3) * 1.5
                )

                render.SetBlend(0.25)
                render.SetColorModulation(0.08, 0.08, 0.10)

                render.DrawSphere(
                    innerPos,
                    50*0.95*factor,
                    40*0.95*factor,
                    40*0.95*factor,
                    Color(30, 30, 40, 255)
                )

                render.SetBlend(0.12)
                render.SetColorModulation(0.2, 0.2, 0.25)

                render.DrawSphere(
                    vector_origin,
                    50*factor,
                    40*factor,
                    40*factor,
                    Color(255,255,255,255)
                )

            cam.PopModelMatrix()

            render.SetBlend(1)
            render.SetColorModulation(1,1,1)

            render.SuppressEngineLighting(false)
        end

        render.OverrideBlend(false)

        cam.End3D()
    end)



end