module("om_color", package.seeall)

AddCSLuaFile()

if CLIENT then
    local IsValid = IsValid
    local CurTime = CurTime
    local pairs = pairs
    local string_sub = string.sub
    local mat = Material("models/debug/debugwhite")

    local defaultCanFunction = function() return false end
    local defaultDrawFunction = function(ent) ent:DrawModel() end
    local defaultEndFunction = function() end
    local defaultRenderEffects = function() end

    local List_optimized = {}
    local List_optimized_second = {}

    function Add_plainoptimized(colortable)
        List_optimized[#List_optimized + 1] = {
            Canfuction = colortable.Canfuction or defaultCanFunction,
            Color = colortable.color or Color(255, 255, 255, 255),
            ignorez = colortable.ignorez == true,
            customdrawfunction = colortable.customdrawfunction or defaultDrawFunction,
            customdrawfunction_end = colortable.customdrawfunction_end or defaultEndFunction
        }
    end


    local List_second = {}

    function Add_render(colortable)

        if !colortable.ent then
            return
        end

        List_second[#List_second + 1] = {
            Ents = colortable.ent,
            ignorez = colortable.ignorez == true,
            customdrawfunction = colortable.customdrawfunction or defaultDrawFunction,
            rendereffects = colortable.rendereffects or defaultRenderEffects,
            customdrawfunction_end = colortable.customdrawfunction_end or defaultEndFunction 
        }

    end

    function Add_renderoptimized(colortable)
        List_optimized_second[#List_optimized_second + 1] = {
            Canfuction = colortable.Canfuction or defaultCanFunction,
            ignorez = colortable.ignorez == true,
            customdrawfunction = colortable.customdrawfunction or defaultDrawFunction,
            rendereffects = colortable.rendereffects or defaultRenderEffects,
            customdrawfunction_end = colortable.customdrawfunction_end or defaultEndFunction
        }

    end

    local ignoredClasses = {
        viewmodel = true,
        predicted_viewmodel = true,
        gmod_hands = true,

        func_illusionary = true,
        func_brush = true,
        func_lod = true,

        env_sprite = true,
        env_beam = true,
        env_laser = true,
        env_lightglow = true,
        env_smokestack = true
    }

    local entities = {}

    local function ShouldIgnoreEntity(ent)
        if !IsValid(ent) then return true end
        if ent:IsWeapon() then return true end

        local class = ent:GetClass()
        if ignoredClasses[class] then return true end
        local prefix4 = string_sub(class, 1, 4)

        if prefix4 == "env_" or prefix4 == "logi" or prefix4 == "poin" or prefix4 == "trig" or prefix4 == "path" or prefix4 == "info" then
            return true
        end

        return false
    end

    hook.Add( "NetworkEntityCreated", "om_color_optimized_init", function(ent)
        if !IsValid(ent) then return end
        local model = ent:GetModel()

        if not model or model == "" then return end
        if ShouldIgnoreEntity(ent) then return end

        entities[ent] = true
    end)
    hook.Add( "EntityRemoved", "om_color_optimized_remove", function(ent)
        entities[ent] = nil
    end)

    local function ResolveEntity(ent, now)
        local rag = ent:GetNWEntity("OM_ragdollentity")
        if IsValid(rag) then ent = rag end
        local pill = ent.pk_pill_ent

        if pill then
            if pill.GetPuppet then
                local puppet = pill:GetPuppet()
                if IsValid(puppet) then
                    ent = puppet
                else
                    return nil
                end
            else
                ent = pill
            end
        end

        if not IsValid(ent) then return nil end
        local ignoreBallUntil = ent:GetNW2Float("IgnoreBall_OM_moduledraw", 0 )

        if ignoreBallUntil <= now then
            local ball = ent:GetNW2Entity("GlowingBallThingy_OM")
            if IsValid(ball) then ent = ball end
        end

        if not IsValid(ent) then return nil end

        return ent
    end

    local function DrawPlain(originalEnt, data, now)

        local ent = ResolveEntity(originalEnt, now)

        if !ent then return end
        local col = data.Color

        if isfunction(col) then col = col(ent) end
        if !col then col = color_white end

        render.MaterialOverride(mat)
        render.SuppressEngineLighting(true)

        render.SetColorModulation(
            col.r / 255,
            col.g / 255,
            col.b / 255
        )

        render.SetBlend(col.a / 255)

        if data.ignorez then
            cam.IgnoreZ(true)
        end

        data.customdrawfunction(ent)

        if data.ignorez then cam.IgnoreZ(false) end

        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)

        data.customdrawfunction_end(ent)

        render.MaterialOverride(nil)
        render.SuppressEngineLighting(false)

    end

    local function DrawSecond(originalEnt, data, now)

        local ent = ResolveEntity(originalEnt, now)

        if not ent then return end

        render.ClearStencil()

        render.SetStencilEnable(true)

        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)

        render.SetStencilReferenceValue(1)

        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)

        if data.ignorez then
            cam.IgnoreZ(true)
        end

        data.customdrawfunction(ent)

        if data.ignorez then
            cam.IgnoreZ(false)
        end

        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)

        data.rendereffects(ent)

        render.SetStencilEnable(false)

        data.customdrawfunction_end(ent)

    end

    hook.Add("PostDrawTranslucentRenderables",  "RenderColor_OM_plain", function()
        hook.Run("PreRenderColor_om_plain_optimized")
        hook.Run("PreRenderColor_om_render_optimized")

        local plainCount = #List_optimized
        local secondCount = #List_optimized_second

        if plainCount == 0 and secondCount == 0 then return end

        local now = CurTime()
        for ent in pairs(entities) do
            if !IsValid(ent) then
                entities[ent] = nil
                continue
            end

            if ent:GetNoDraw() then continue end

            if plainCount > 0 then
                for i = 1, plainCount do
                    local data = List_optimized[i]
                    if data.Canfuction(ent) then DrawPlain(ent, data, now ) end
                end
            end
            if secondCount > 0 then
                for i = 1, secondCount do
                    local data = List_optimized_second[i]
                    if data.Canfuction(ent) then DrawSecond(ent, data, now) end
                end
            end
        end

        table.Empty(List_optimized)
        table.Empty(List_optimized_second)
    end)

end