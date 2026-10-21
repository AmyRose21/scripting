AddCSLuaFile()
if CLIENT then
    hook.Add("PreDrawOutlines_om", "PreDrawOutlines_rouge_om", function()
        for _, ent in ipairs(ents.GetAll()) do
            if not IsValid(ent) then continue end
            if ent:GetNoDraw() then continue end
            if ent:GetColor().a <= 30 then continue end

            if ent:GetModel() == "models/noodles/om/rouge.mdl" or ent:GetNWBool("Fleetway_om_outline") then
            end
        end
    end)

    hook.Add("PreRenderColor_om_render", "PreRenderColor_rouge_om", function()
        for _, ent in ipairs(ents.GetAll()) do
            if not IsValid(ent) then continue end
            if ent:GetNoDraw() then continue end
            if ent:GetColor().a <= 30 then continue end

            if ent:GetModel() == "models/noodles/om/rouge.mdl" or ent:GetNWBool("Rouge_om_outline") then
            end
        end
    end)
end