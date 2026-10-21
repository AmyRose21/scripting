
module( "om_afterimage", package.seeall )


AddCSLuaFile()

if CLIENT then 
    local List = {}

    function Add( colortable )

        if not colortable.entities or (colortable.entities and !IsValid(colortable.entities)) then return end
        local t = {
            Ents = colortable.entities,
            Color = colortable.color or Color(255,255,255,255),
            lifeTime = colortable.lifeTime or 0.5,
            afterimagecooldown = colortable.afterimagecooldown or 0.075,
            name = colortable.name or "e",
            shouldnolighting = colortable.shouldnolighting or false
        }

        table.insert( List, t )
    end

    local List_optimized = {}

    function Add_plainoptimized( colortable )
        local t = {
            Canfuction = colortable.Canfuction or function(entity) return false end,
            Color = colortable.color or Color(255,255,255,255),
            lifeTime = colortable.lifeTime or 0.5,
            afterimagecooldown = colortable.afterimagecooldown or 0.075,
            name = colortable.name or "e",
            shouldnolighting = colortable.shouldnolighting or false
        }

        table.insert( List_optimized, t )
    end

    local AfterImages = {}

    hook.Add("PostDrawOpaqueRenderables", "OM_DrawAfterImages", function()
        render.SuppressEngineLighting(true)

        for _, data in ipairs(AfterImages) do
            if IsValid(data.mdl) and data.shouldnolighting then

                local col = data.mdl:GetColor()

                render.SetColorModulation(
                    col.r / 255,
                    col.g / 255,
                    col.b / 255
                )
                render.SetBlend(col.a / 255)

                data.mdl:DrawModel()
            end
        end
        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)
        render.SuppressEngineLighting(false)
    end)

    local function DrawEntity_effect(ent, playerIndex, ply)
        if not ent["NextAfterImage"..ply.name] or CurTime() > ent["NextAfterImage"..ply.name] then
            ent["NextAfterImage"..ply.name] = CurTime() + ply.afterimagecooldown

            local ghost = ClientsideModel(ent:GetModel(), RENDERGROUP_TRANSLUCENT)
            if IsValid(ghost) then

                ghost:SetPos(ent:GetPos())
                ghost:SetAngles(ent:GetAngles())
                ghost:SetModelScale(ent:GetModelScale(), 0)

                ghost:SetSkin(ent:GetSkin())

                for i = 0, ent:GetNumBodyGroups() - 1 do
                    ghost:SetBodygroup(i, ent:GetBodygroup(i))
                end

                ghost:SetSequence(ent:GetSequence())
                ghost:SetCycle(ent:GetCycle())
                ghost:SetPlaybackRate(ent:GetPlaybackRate())

                local poseCount = ent:GetNumPoseParameters()
                if poseCount and poseCount > 0 then
                    for i = 0, poseCount - 1 do
                        local name = ent:GetPoseParameterName(i)
                        if name then
                            ghost:SetPoseParameter(name, ent:GetPoseParameter(name))
                        end
                    end
                end

                ghost:InvalidateBoneCache()
                ghost:SetupBones()

                -- color
                local color2 = isfunction(ply.Color) and ply.Color(ent) or ply.Color
                ghost:SetColor(color2)
                ghost:SetRenderMode(RENDERMODE_TRANSALPHA)

                table.insert(AfterImages, {
                    mdl = ghost,
                    die = CurTime() + ply.lifeTime,
                    start = CurTime(),
                    life = ply.lifeTime,
                    ogcolor = ghost:GetColor(),
                    shouldnolighting = ply.shouldnolighting
                })
            end
        end
    end
    local entities = {}

    hook.Add("NetworkEntityCreated", "om_color_optimized_init3", function(ent)
        timer.Simple(0, function()
            if not IsValid(ent) then return end

            local model = ent:GetModel()
            if not model or model == "" then return end

            local class = ent:GetClass()

            -- Ignore things that don't need render effects
            if ent:IsWeapon() then return end

            if class == "viewmodel" then return end
            if class == "predicted_viewmodel" then return end
            if class == "gmod_hands" then return end

            -- Brush entities
            if class == "func_illusionary" then return end
            if class == "func_brush" then return end
            if class == "func_lod" then return end

            -- Helpers
            if class == "env_sprite" then return end
            if class == "env_beam" then return end
            if class == "env_laser" then return end
            if class == "env_lightglow" then return end
            if class == "env_smokestack" then return end

            -- Logic / map entities
            if string.StartWith(class, "env_") then return end
            if string.StartWith(class, "logic_") then return end
            if string.StartWith(class, "point_") then return end
            if string.StartWith(class, "trigger_") then return end
            if string.StartWith(class, "path_") then return end
            if string.StartWith(class, "info_") then return end

            entities[ent] = true

            --print("Added render entity:", ent, class, model)
        end)
    end)

    hook.Add("EntityRemoved", "om_color_optimized_remove3", function(ent)
        if entities[ent] then
            entities[ent] = nil
            --print("Removed render entity:", ent)
        end
    end)

    hook.Add("Think", "OM_AfterImage_handeler", function()
        for k = #AfterImages, 1, -1 do
            local data = AfterImages[k]

            if !IsValid(data.mdl) then
                table.remove(AfterImages, k)
                continue
            end

            local frac = 1 - ((CurTime() - data.start) / data.life)

            if frac <= 0 then
                data.mdl:Remove()
                table.remove(AfterImages, k)
            else
                local c = data.mdl:GetColor()
                c.a = frac * data.ogcolor.a
                data.mdl:SetColor(c)
            end
        end

        hook.Run( "pre_afterimage_om_optimize" )

        if #List_optimized > 0 then
            for ent, i in pairs(entities) do
                if !IsValid(ent) then continue end
                if ent:GetNoDraw() then continue end

                for playerIndex, ply in ipairs(List_optimized) do
                    if playerIndex then else continue end
                    if ply.Canfuction(ent) then
                        DrawEntity_effect(ent, playerIndex, ply)
                    end
                end
            end
        end

        List_optimized = {}

        --[[
        hook.Run( "pre_afterimage_om" )

        if #List > 0 then
            for playerIndex, ply in ipairs(List) do
                local ent = ply.Ents
                if not IsValid(ent) then continue end
                DrawEntity_effect(ent, playerIndex, ply)
            end
        end

        List = {}
        ]]
    end)
end