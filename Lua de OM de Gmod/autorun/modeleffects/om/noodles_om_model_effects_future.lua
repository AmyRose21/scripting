AddCSLuaFile()
if SERVER then
    hook.Add("OnEntityCreated", "silver_ModelInitialize_OM", function(ent)
        timer.Simple(0, function()
            if not IsValid(ent) then return end

            if ent:GetModel() ~= "models/noodles/om/silver.mdl" then return end


            local id = "Silver_ElecThink_" .. ent:EntIndex()
            local eletricityCooldown = CurTime()
            hook.Add("Think", id, function()
                if not IsValid(ent) then return end

                if eletricityCooldown > CurTime() then
                else
                    eletricityCooldown = CurTime()+0.1

                    local eff = EffectData()
                    eff:SetEntity(ent)
                    util.Effect("electric_hand_emitting_SILVER", eff)

                end

            end)

            ent:CallOnRemove("Silver_RemoveHook_" .. ent:EntIndex(), function()
                hook.Remove("Think", id)
            end)
        end)
    end)
else                                                                                    -- CLIENT --
    hook.Add("OnEntityCreated", "Silver_ModelInitialize_OM_C", function(ent)
        timer.Simple(0, function()
            if not IsValid(ent) then return end

            if ent:GetModel() ~= "models/noodles/om/silver.mdl" then return end
            local id = "Silver_LightThink_" .. ent:EntIndex()

            hook.Add("Think", id, function()
                if not IsValid(ent) then return end

                local matrix1 = ent:GetBoneMatrix(ent:LookupBone("LeftHand"))
                if matrix1 then
                    local l = DynamicLight(ent:EntIndex()+1)
                    if l then
                        l.pos = matrix1:GetTranslation()
                        l.r = 0
                        l.g = 255
                        l.b = 255
                        l.brightness = 2
                        l.Decay = 1000
                        l.Size = 30
                        l.DieTime = CurTime() + 1
                    end
                end
                local matrix2 = ent:GetBoneMatrix(ent:LookupBone("RightHand"))
                if matrix2 then
                    local r = DynamicLight(ent:EntIndex()+2)
                    if r then
                        r.pos = matrix2:GetTranslation()
                        r.r = 0
                        r.g = 255
                        r.b = 255
                        r.brightness = 2
                        r.Decay = 1000
                        r.Size = 30
                        r.DieTime = CurTime() + 1
                    end
                end
                local matrix1 = ent:GetBoneMatrix(ent:LookupBone("LeftLowerLeg"))
                if matrix1 then
                    local l = DynamicLight(ent:EntIndex()+3)
                    if l then
                        l.pos = matrix1:GetTranslation()
                        l.r = 0
                        l.g = 255
                        l.b = 255
                        l.brightness = 2
                        l.Decay = 1000
                        l.Size = 41
                        l.DieTime = CurTime() + 1
                    end
                end
                local matrix2 = ent:GetBoneMatrix(ent:LookupBone("RightLowerLeg"))
                if matrix2 then
                    local r = DynamicLight(ent:EntIndex()+4)
                    if r then
                        r.pos = matrix2:GetTranslation()
                        r.r = 0
                        r.g = 255
                        r.b = 255
                        r.brightness = 2
                        r.Decay = 1000
                        r.Size = 41
                        r.DieTime = CurTime() + 1
                    end
                end
            end)

            ent:CallOnRemove("Silver_RemoveHook_C_" .. ent:EntIndex(), function()
                hook.Remove("Think", id)
            end)
        end)
    end)

    hook.Add("PreRenderColor_om_render_optimized", "emrald_color_om", function()
        om_color.Add_renderoptimized({ 
            Canfuction = function(ent) 
                return ent:GetModel() == "models/noodles/om/gem.mdl"
            end, 
            ignorez = false,
            rendereffects = function(ent)

                local alpha = ent:GetColor().a / 255

                local whiteLerp = 0

                local whiteTime = ent:GetNW2Float("modernsonic_ui_OM_noodles_lerp_white2", 0)

                if whiteTime > CurTime() then
                    whiteLerp = math.Approach(
                        ent.OM_WhiteLerp or 0,
                        1,
                        FrameTime() * 0.3
                    )
                else
                    whiteLerp = math.Approach(
                        ent.OM_WhiteLerp or 0,
                        0,
                        FrameTime() * 2
                    )
                end

                ent.OM_WhiteLerp = whiteLerp


                local colors = {
                    white = {1, 1, 1},
                    red   = {1, 0, 0},
                    green = {0, 1, 0},
                    blue  = {0, 0, 1},
                    yellow= {1, 1, 0},
                    cyan  = {0, 1, 1},
                    pink  = {1, 0, 1}
                }


                for name, mul in pairs(colors) do
                    if ent:GetNW2Bool("emerald_color_" .. name) then

                        local r = Lerp(whiteLerp, mul[1], 1)
                        local g = Lerp(whiteLerp, mul[2], 1)
                        local b = Lerp(whiteLerp, mul[3], 1)

                        DrawColorModify({
                            ["$pp_colour_addr"]       = r * 3 * alpha,
                            ["$pp_colour_addg"]       = g * 3 * alpha,
                            ["$pp_colour_addb"]       = b * 3 * alpha,

                            ["$pp_colour_brightness"] = -0.7,
                            ["$pp_colour_contrast"]   = 1,
                            ["$pp_colour_colour"]     = 1,

                            ["$pp_colour_mulr"]       = 0,
                            ["$pp_colour_mulg"]       = 0,
                            ["$pp_colour_mulb"]       = 0
                        })

                        break
                    end
                end
            end
        })
    end)

end