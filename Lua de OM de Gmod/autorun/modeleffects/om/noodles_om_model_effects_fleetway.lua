AddCSLuaFile()

if SERVER then
else
    hook.Add("OnEntityCreated", "FleetWay_ModelInitialize_OM_C", function(ent)
        timer.Simple(0, function()
            if not IsValid(ent) then return end

            if ent:GetModel() ~= "models/noodles/om/fleetway.mdl" and ent:GetModel() ~= "models/noodles/om/fleetwaynextbot.mdl" then return end
                local entIndex = ent:EntIndex()
                local torsoBone = ent:LookupBone("Torso")

                local timerID = "Fleetway_LightThink_" .. entIndex

                local function GetFleetwayPos()
                    if not IsValid(ent) then return end

                    local pos = ent:GetPos()

                    if torsoBone then
                        local matrix = ent:GetBoneMatrix(torsoBone)
                        if matrix then
                            pos = matrix:GetTranslation()
                        end
                    end

                    return pos
                end

                local function Cleanup()
                    timer.Remove(timerID .. "_electric")
                    timer.Remove(timerID .. "_eye")
                    timer.Remove(timerID .. "_light")
                end

                ent:CallOnRemove("Fleetway_RemoveTimers_" .. entIndex, Cleanup)

                local data = EffectData()
                data:SetEntity(ent)
                util.Effect("OM_tinyball_fleetway", data)


                timer.Create(timerID .. "_electric", 0.2, 0, function()
                    if not IsValid(ent) or ent:GetNoDraw() then return end

                    local data = EffectData()
                    data:SetOrigin(GetFleetwayPos())

                    util.Effect("Fleetway_Eletricity", data, true, true)
                end)


                timer.Create(timerID .. "_eye", 0.15, 0, function()
                    if not IsValid(ent) or ent:GetNoDraw() then return end

                    local data = EffectData()
                    data:SetEntity(ent)

                    util.Effect("Fleetway_EyeSize", data)
                end)


                timer.Create(timerID .. "_light", 0.05, 0, function()
                    if not IsValid(ent) or ent:GetNoDraw() then return end

                    local light = DynamicLight(entIndex)
                    if not light then return end

                    light.pos = GetFleetwayPos()

                    light.r = 5
                    light.g = 4
                    light.b = 1

                    light.brightness = 0.5
                    light.Decay = 100
                    light.Size = 1400
                    light.DieTime = CurTime() + 0.1
                end)

        end)
    end)


    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_fleetway_model", function()
        local ply = LocalPlayer()

        om_halo.Add_optimized(
            function(ent) 
                if ent:GetNoDraw() then return end
                if ent:GetColor().a <= 30 then return end
                return ent:GetModel() == "models/noodles/om/fleetway.mdl" or ent:GetNWBool("Fleetway_om_outline")
            end, 
            function(ent) 
                return Color(255, 255, 255, 100)
            end, 
            1, 
            false)            
    end )







end
















