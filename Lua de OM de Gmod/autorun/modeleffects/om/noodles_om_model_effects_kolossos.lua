AddCSLuaFile()

if SERVER then
else
    hook.Add("OnEntityCreated", "Kolossos_ModelInitialize_OM_C", function(ent)
        timer.Simple(0, function()
            if not IsValid(ent) then return end

            if ent:GetModel() ~= "models/noodles/om/kolossos.mdl" then return end

            local dlight = DynamicLight(ent:EntIndex())
            if not dlight then return end

            dlight.r = 255
            dlight.g = 0
            dlight.b = 0
            dlight.brightness = 2
            dlight.Decay = 1000
            dlight.Size = 200
            dlight.DieTime = CurTime() + 1

            ent.Light = dlight

            local id = "kolossos_LightThink_" .. ent:EntIndex()

            hook.Add("Think", id, function()
                if not IsValid(ent) then return end

                local l = DynamicLight(ent:EntIndex())
                if l then
                    l.pos = ent:GetPos()
                    l.r = 255
                    l.g = 0
                    l.b = 0
                    l.brightness = 2
                    l.Decay = 1000
                    l.Size = 200
                    l.DieTime = CurTime() + 1
                end
            end)

            ent:CallOnRemove("kolossos_RemoveHook_C_" .. ent:EntIndex(), function()
                hook.Remove("Think", id)
            end)
        end)
    end)
end