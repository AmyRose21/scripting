AddCSLuaFile()
if CLIENT then

    hook.Add("PreRenderColor_om_render", "PreRenderColor_sunki_om", function()
        for _, ent in ipairs(ents.GetAll()) do
            if not IsValid(ent) then continue end
            if ent:GetNoDraw() then continue end
            if ent:GetColor().a <= 30 then continue end

            if ent:GetModel() == "models/noodles/om/sunki.mdl" or ent:GetNWBool("sunki_om_outline") then
                om_color.Add_render({
                    ent = ent,
                    ignorez = false,
                    rendereffects = function()
                    end
                })

            end
        end
    end)
end