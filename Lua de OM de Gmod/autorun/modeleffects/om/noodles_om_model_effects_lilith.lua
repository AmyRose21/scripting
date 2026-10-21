AddCSLuaFile()

game.AddParticles( "particles/lilith_particals.pcf" )
PrecacheParticleSystem( "Lilith_Green" )
PrecacheParticleSystem( "Lilith_GreenSecond" )
PrecacheParticleSystem( "Lilith_Red" )
PrecacheParticleSystem( "Lilith_White" )
PrecacheParticleSystem( "Lilith_glitching" )
PrecacheParticleSystem( "Lilith_Glitch2" )
PrecacheParticleSystem( "Lilith_Glitch2Big" )




if SERVER then
else                

    hook.Add("OnEntityCreated", "LilithVertexCache", function(ent)
        timer.Simple(0, function()
            if not IsValid(ent) then return end

            if ent:GetModel() == "models/noodles/om/lilith.mdl" then
                if ent:GetNoDraw() then return end

                ParticleEffectAttach(
                    "Lilith_glitching",
                    PATTACH_ABSORIGIN_FOLLOW,
                    ent,
                    0
                )
                ParticleEffectAttach(
                    "Lilith_Glitch2",
                    PATTACH_ABSORIGIN_FOLLOW,
                    ent,
                    0
                )

                local models = {
                    "models/noodles/om/lilith/color_green1.mdl",
                    "models/noodles/om/lilith/color_green2.mdl",
                    "models/noodles/om/lilith/color_white.mdl",
                    "models/noodles/om/lilith/color_red.mdl",
                    "models/noodles/om/lilith/color_yellow.mdl"
                }

                ent.LilithBonemerge = {}

                for _, mdl in ipairs(models) do
                    local bonemerge = ClientsideModel(mdl, RENDERGROUP_OPAQUE)

                    if IsValid(bonemerge) then
                        bonemerge:SetPos(ent:GetPos())
                        bonemerge:SetAngles(ent:GetAngles())

                        bonemerge:SetParent(ent)
                        bonemerge:AddEffects(EF_BONEMERGE)

                        bonemerge:SetNoDraw(true)
                        bonemerge:SetBodygroup(0,1)

                        table.insert(ent.LilithBonemerge, bonemerge)
                    end
                end

                local id = "LilithBonemergeCheck_" .. ent:EntIndex()
                local target = ent

                target:CallOnRemove("LilithRemoveBonemerge", function()
                    for _, mdl in ipairs(target.LilithBonemerge or {}) do
                        if IsValid(mdl) then
                            mdl:Remove()
                        end
                    end

                    hook.Remove("Think", id)
                end)

                hook.Add("Think", id, function()
                    if not IsValid(target) then
                        hook.Remove("Think", id)
                        return
                    end

                    for _, mdl in ipairs(target.LilithBonemerge or {}) do
                        if IsValid(mdl) then
                            if mdl:GetParent() ~= target then
                                mdl:SetParent(target)
                            end

                            mdl:AddEffects(EF_BONEMERGE)
                        end
                    end
                end)
            end

            if ent:GetModel() == "models/noodles/om/lilith/color_yellow.mdl" then
                for i = 1, 6 do
                    ParticleEffectAttach(
                        "Lilith_GreenSecond",
                        PATTACH_ABSORIGIN_FOLLOW,
                        ent,
                        0
                    )
                end
            end

            if ent:GetModel() == "models/noodles/om/lilith/color_red.mdl" then
                for i = 1, 4 do
                    ParticleEffectAttach(
                        "Lilith_Red",
                        PATTACH_ABSORIGIN_FOLLOW,
                        ent,
                        0
                    )
                end
            end

            if ent:GetModel() == "models/noodles/om/lilith/color_white.mdl" then
                for i = 1, 5 do
                    ParticleEffectAttach(
                        "Lilith_White",
                        PATTACH_ABSORIGIN_FOLLOW,
                        ent,
                        0
                    )
                end
            end

            if ent:GetModel() == "models/noodles/om/lilith/color_green1.mdl" then
                for i = 1, 2 do
                    ParticleEffectAttach(
                        "Lilith_Green",
                        PATTACH_ABSORIGIN_FOLLOW,
                        ent,
                        0
                    )
                end
            end

            if ent:GetModel() == "models/noodles/om/lilith/color_green2.mdl" then
                for i = 1, 7 do
                    ParticleEffectAttach(
                        "Lilith_Green",
                        PATTACH_ABSORIGIN_FOLLOW,
                        ent,
                        0
                    )
                end
            end

        end)
    end)

end
