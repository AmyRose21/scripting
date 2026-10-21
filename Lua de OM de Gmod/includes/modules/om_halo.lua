
module( "om_halo", package.seeall )


AddCSLuaFile()

if CLIENT then 
    local outlineMatSettings = {
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    }
    local outlineMat = CreateMaterial("OutlineMat", "UnlitGeneric", outlineMatSettings)


    local List = {}

    function Add( entities, color, size, ignorez )

        local t = {
            Ents = entities,
            Color = color,
            size = size or 2,
            ignorez = ignorez or false
        }

        table.insert( List, t )

    end

    local List_optimized = {}

    function Add_optimized( Canfuction, color, size, ignorez )

        local t = {
            Canfuction = Canfuction or function(entity) return false end,
            Color = color,
            size = size or 2,
            ignorez = ignorez or false
        }

        table.insert( List_optimized, t )

    end

    local copyMat = Material("pp/copy")
    local storeTexture = render.GetScreenEffectTexture(0)
    local drawTexture = render.GetScreenEffectTexture(1)

    local function DrawEntity_effect(ent, playerIndex, ply)

        local rag = ent:GetNWEntity("OM_ragdollentity")
        local ball = ent:GetNW2Entity("GlowingBallThingy_OM")

        if IsValid(rag) then
            ent = rag
        end 
        if ent.pk_pill_ent then
            if ent.pk_pill_ent.GetPuppet then
                ent = ent.pk_pill_ent:GetPuppet()
            else
                ent = ent.pk_pill_ent
            end
        end


        if !IsValid(ent) then return end
        --print(ent:GetNW2Float("IgnoreBall_OM_moduledraw")-CurTime())

        if ent:GetNW2Float("IgnoreBall_OM_moduledraw") > CurTime() then
        else
            if IsValid(ball) then
                ent = ball
            end 
        end

        if !IsValid(ent) then return end

        local scene = render.GetRenderTarget()
        local oldRT = render.GetRenderTarget()
        
        render.SetBlend(1)

        render.CopyRenderTargetToTexture(storeTexture)
        local w = ScrW()
        local h = ScrH()
        render.Clear(0, 0, 0, 0, false, true)
        
        render.SetStencilEnable(true)
        render.SuppressEngineLighting(true)

        render.SetStencilWriteMask(0xFF)
        render.SetStencilTestMask(0xFF)

        render.SetStencilCompareFunction( STENCIL_ALWAYS )
        render.SetStencilPassOperation( STENCIL_REPLACE )
        render.SetStencilFailOperation( STENCIL_KEEP )
        render.SetStencilZFailOperation(STENCIL_ZERO)

        if ply.ignorez then
            cam.Start3D()

                render.OverrideDepthEnable(true, false)

                render.SetStencilCompareFunction(STENCIL_ALWAYS)
                render.SetStencilPassOperation(STENCIL_REPLACE)
                render.SetStencilFailOperation(STENCIL_KEEP)
                render.SetStencilZFailOperation(STENCIL_REPLACE)

                render.SetStencilReferenceValue(playerIndex)

                render.SetColorModulation(0, 0, 0)
                render.SetBlend(0.0001)
                ent:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)

                render.OverrideDepthEnable(false, false)

            cam.End3D()
        else
            cam.Start3D()
                render.SetStencilCompareFunction(STENCIL_ALWAYS)
                render.SetStencilPassOperation(STENCIL_REPLACE)
                render.SetStencilFailOperation(STENCIL_KEEP)
                render.SetStencilZFailOperation(STENCIL_KEEP)
                render.DepthRange(0, 1)
                
                render.SetStencilReferenceValue(playerIndex)

                render.SetColorModulation(0, 0, 0)
                render.SetBlend(0.0001)
                ent:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)
                
                render.DepthRange(0, 0)
            cam.End3D()
        end
        
        cam.Start2D()
        render.SetStencilCompareFunction(STENCIL_EQUAL)
            render.SetStencilReferenceValue(playerIndex)
            local color2 = isfunction(ply.Color) and ply.Color(ent) or ply.Color
            surface.SetDrawColor(color2.r, color2.g, color2.b, color2.a)
            surface.DrawRect(0, 0, w, h)
        cam.End2D()
        
        render.SuppressEngineLighting(false)
        render.SetStencilEnable(false)
        
        render.CopyRenderTargetToTexture(drawTexture)
        render.SetRenderTarget(oldRT)
        
        copyMat:SetTexture("$basetexture", storeTexture)
        render.SetMaterial(copyMat)
        render.DrawScreenQuad()
        
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(0xFF)
        render.SetStencilTestMask(0xFF)
        render.SetStencilReferenceValue(0)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        
        outlineMat:SetTexture("$basetexture", drawTexture)
        render.SetMaterial(outlineMat)

        local thickness = ply.size

        render.DrawScreenQuadEx(-thickness, -thickness, w, h)
        render.DrawScreenQuadEx(-thickness, 0, w, h)
        render.DrawScreenQuadEx(-thickness, thickness, w, h)
        render.DrawScreenQuadEx(0, -thickness, w, h)
        render.DrawScreenQuadEx(0, thickness, w, h)
        render.DrawScreenQuadEx(thickness, -thickness, w, h)
        render.DrawScreenQuadEx(thickness, 0, w, h)
        render.DrawScreenQuadEx(thickness, thickness, w, h)

        render.SetBlend(1)

        render.SetStencilEnable(false)

        render.SetStencilTestMask( 0 )
        render.SetStencilWriteMask( 0 )
        render.SetStencilReferenceValue( 0 )
    end



    local entities = {}

    hook.Add("NetworkEntityCreated", "om_color_optimized_init2", function(ent)
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

    hook.Add("EntityRemoved", "om_color_optimized_remove2", function(ent)
        if entities[ent] then
            entities[ent] = nil
            --print("Removed render entity:", ent)
        end
    end)

    hook.Add("PostDrawEffects", "RenderOutlines_OM", function()
        hook.Run( "PreDrawOutlines_om_optimized" )

        if #List_optimized == 0 then
            render.SetStencilEnable(false)
        else
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
        hook.Run( "PreDrawOutlines_om" )
        
        if #List == 0 then
            render.SetStencilEnable(false)
        else
            for playerIndex, ply in ipairs(List) do
                local ent = ply.Ents
                if not IsValid(ent) then continue end
                DrawEntity_effect(ent, playerIndex, ply)
            end
        end

        render.SetStencilEnable(false)

        List = {}
        ]]
    end)
end