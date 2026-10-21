
AddCSLuaFile()

local function AdvancedPillSound(SoundData, ent)
    if SERVER then
        if IsValid(ent) then
            SoundData = SoundData or {}
            SoundData.stringe = SoundData.stringe or {}
            SoundData.soundLevel = SoundData.soundLevel or 75
            SoundData.pitchPercent = SoundData.pitchPercent or 100
            SoundData.volume = SoundData.volume or 1
            SoundData.channel = SoundData.channel or CHAN_AUTO
            SoundData.soundFlags = SoundData.soundFlags or 0
            SoundData.dsp = SoundData.dsp or 0
            SoundData.filter = SoundData.filter or nil

            local chosenSound = SoundData.stringe

            if istable(SoundData.stringe) then
                local index = math.random(1, #SoundData.stringe)
                chosenSound = SoundData.stringe[index]
            end

            ent:EmitSound(
                chosenSound,
                SoundData.soundLevel,
                SoundData.pitchPercent,
                SoundData.volume,
                SoundData.channel,
                SoundData.soundFlags,
                SoundData.dsp,
                SoundData.filter
            )
        end
        return true
    end
end

-- materials --

-- Nextbot slowdown
if SERVER then
    
    local pc2addon_speedfunction = {}

    function OM_AddSpeedConfigeration(functions)

        table.insert(pc2addon_speedfunction, functions)
        return true
    end
    hook.Add("OnEntityCreated", "OM_drgbase_override_speed", function(ent)
        timer.Simple(0, function()
            if not IsValid(ent) then return end
            if not ent.IsDrGNextbot then return end
            if ent._OMSpeedOverridden then return end
            
            ent._OMSpeedOverridden = true
            
            local oldSetSpeed = ent.SetSpeed
            local self = ent
            function ent:SetSpeed(speed)
                local multiplier = 1
                
                for _, func in pairs(pc2addon_speedfunction) do
                    local result = func(self)
                    if result then
                        multiplier = multiplier * result
                    end
                end
                
                oldSetSpeed(self, speed)
                
                if self.loco then
                    local finalSpeed = (speed * self:GetScale()) * multiplier
                    self.loco:SetDesiredSpeed(finalSpeed)
                end
            end
        end)
    end)
end

-- RAGDOLL STATUS --

if SERVER then
    local function createfakeragdoll(jumpscare_entity)
        if !IsValid(jumpscare_entity) then return end
        --[[
        if jumpscare_entity.Think then
            jumpscare_entity:Think()
        end
        ]]

        if SERVER then
            local ragdoll = ents.Create("prop_ragdoll")
            if jumpscare_entity.pk_pill_ent and IsValid(jumpscare_entity.pk_pill_ent) then
                ragdoll:SetModel(jumpscare_entity.pk_pill_ent:GetPuppet():GetModel())
            else
                local model = jumpscare_entity:GetModel()

                if model and util.IsValidModel(model) then
                    ragdoll:SetModel(model)
                else
                    ragdoll:SetModel("models/error.mdl")
                end
            end
            ragdoll:SetPos(jumpscare_entity:GetPos())
            ragdoll:SetAngles(jumpscare_entity:GetAngles())
            ragdoll:SetSkin(jumpscare_entity:GetSkin() or 0)
            ragdoll:Spawn()

            local physCount = ragdoll:GetPhysicsObjectCount()
            if physCount <= 0 then
                ragdoll:Remove()

                ragdoll = ents.Create("prop_physics")
                ragdoll:SetModel("models/hunter/blocks/cube025x025x025.mdl")--ragdoll:SetModel("models/props_c17/oildrum001.mdl")
                ragdoll:SetPos(jumpscare_entity:GetPos())
                ragdoll:SetAngles(jumpscare_entity:GetAngles())
                ragdoll:SetSkin(jumpscare_entity:GetSkin() or 0)
                ragdoll:Spawn()
                ragdoll:SetRenderMode(RENDERMODE_TRANSALPHA)
                ragdoll:SetColor(Color(255, 255, 255, 0))
                ragdoll:ManipulateBoneScale(0,Vector(0,0,0))

                local ball = ents.Create("prop_dynamic")
                if jumpscare_entity.pk_pill_ent and IsValid(jumpscare_entity.pk_pill_ent) then
                    ball:SetModel(jumpscare_entity.pk_pill_ent:GetPuppet():GetModel())
                else
                    local model = jumpscare_entity:GetModel()

                    if model and util.IsValidModel(model) then
                        ball:SetModel(model)
                    else
                        ball:SetModel("models/error.mdl")
                    end
                end
                ball:SetPos(jumpscare_entity:GetPos())
                ball:SetAngles(jumpscare_entity:GetAngles())
                ball:SetSkin(jumpscare_entity:GetSkin() or 0)
                ball:SetParent(ragdoll)
                ball:SetModelScale(jumpscare_entity:GetModelScale())
                ball:Spawn()
                ball:SetCollisionGroup(COLLISION_GROUP_WORLD)

                local seqName = jumpscare_entity:GetSequenceName(jumpscare_entity:GetSequence())
                local seqID = jumpscare_entity:LookupSequence(seqName)
                ball:SetSequence(seqID)
                ball:SetPlaybackRate(0)
                ball:SetCycle(jumpscare_entity:GetCycle())

                ragdoll:DeleteOnRemove(ball)

                ragdoll:SetNW2Entity("fakemodel_om", ball)
            end

            local hookname = "DisableSpecificRagdollDamage"..ragdoll:EntIndex()
            hook.Add("EntityTakeDamage", hookname, function(target, dmginfo)
                if !IsValid(dmginfo:GetAttacker()) then return end
                        
                if dmginfo:GetAttacker() == ragdoll or dmginfo:GetInflictor() == ragdoll then
                    dmginfo:SetDamage(0)
                end
            end)

            ragdoll:CallOnRemove(hookname, function()
                hook.Remove("hookname",hookname)
            end)

            if jumpscare_entity.GetBodyGroups then
                for _, bg in ipairs(jumpscare_entity:GetBodyGroups()) do
                    ragdoll:SetBodygroup(bg.id, jumpscare_entity:GetBodygroup(bg.id))
                end
            end

            if jumpscare_entity.GetPlayerColor and ragdoll.SetPlayerColor then
                ragdoll:SetPlayerColor(jumpscare_entity:GetPlayerColor())
            end

            if jumpscare_entity.GetColor then
                ragdoll:SetColor(jumpscare_entity:GetColor())
            end

            if jumpscare_entity.GetMaterial then
                ragdoll:SetMaterial(jumpscare_entity:GetMaterial())
            end

            if ragdoll.GetNumSubMaterials and ragdoll.SetSubMaterial and jumpscare_entity.GetSubMaterial then
                for i = 0, ragdoll:GetNumSubMaterials() - 1 do
                    local sub = jumpscare_entity:GetSubMaterial(i)
                    if sub then
                        ragdoll:SetSubMaterial(i, sub)
                    end
                end
            end

            jumpscare_entity:SetNotSolid(true)
            jumpscare_entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
            ragdoll.OMRagdoll = true

            ragdoll:SetCollisionGroup(COLLISION_GROUP_WORLD)
            return ragdoll
        end
    end

    function CreateRagdolLCharacter_OM(tableofitemz)
        local shoulddocustomfunction = tableofitemz.shoulddocustomfunction
        local shouldremove = tableofitemz.shouldremove
        local ent2 = tableofitemz.target
        local ent = tableofitemz.host

        if not ent2 or !IsValid(ent2) then return end
        if not ent or !IsValid(ent) then return end
        if not shouldremove then shouldremove = function() return true end end
        if not shoulddocustomfunction then shoulddocustomfunction = function() return false end end

        if ent2:GetNW2Float("ragdolltype_grab") > CurTime() and ent:GetNW2Float("ragdolltype_bypass") < CurTime() then
            return
        end

        if IsValid(ent2:GetNWEntity("OM_ragdollentity")) then
            ent2:GetNWEntity("OM_ragdollentity"):Remove()
            --return
        end

        local createfakeragdoll = createfakeragdoll(ent2)
        if IsValid(createfakeragdoll) then
            ent2:SetNWEntity("OM_ragdollentity", createfakeragdoll)
            if ent2.pk_pill_ent then
                ent2.pk_pill_ent:SetNWEntity("OM_ragdollentity", createfakeragdoll)
                if ent2.pk_pill_ent:GetPuppet() then
                    ent2.pk_pill_ent:GetPuppet():SetNWEntity("OM_ragdollentity", createfakeragdoll)
                end
            end
            ent2:SetNWEntity("ragdollchar_om", createfakeragdoll)
        end
        local currrentpos = ent2:GetPos()
        local name = "ragdoll_nosey" .. ent2:EntIndex() .. " " .. ent:EntIndex()
        local dead = false
        hook.Add("Think", name, function()
            if shouldremove(createfakeragdoll) then
                if IsValid(createfakeragdoll) then
                    createfakeragdoll:Remove()
                end
                if IsValid(ent2) then
                    local mins, maxs = ent2:OBBMins(), ent2:OBBMaxs()
                    local safePos

                    local function IsSafe(pos)
                        local tr = util.TraceHull({
                            start = pos,
                            endpos = pos,
                            mins = mins,
                            maxs = maxs,
                            filter = ent2,
                            mask = MASK_SOLID
                        })

                        return not tr.Hit
                    end

                    if IsSafe(currrentpos) then
                        safePos = currrentpos
                    else
                        local radiusStep = 16
                        local maxRadius = 96

                        for radius = radiusStep, maxRadius, radiusStep do
                            for ang = 0, 360 - 45, 45 do
                                local dir = Angle(0, ang, 0):Forward()

                                for z = 0, 48, 16 do
                                    local pos = currrentpos + dir * radius + Vector(0, 0, z)

                                    if IsSafe(pos) then
                                        safePos = pos
                                        break
                                    end
                                end

                                if safePos then break end
                            end

                            if safePos then break end
                        end
                    end

                    ent2:SetPos(safePos or currrentpos)
                    ent2:SetNotSolid(false)
                    ent2:SetCollisionGroup(COLLISION_GROUP_PLAYER)
                end

                if ent2.pk_pill_ent and IsValid(ent2.pk_pill_ent) and ent2.pk_pill_ent.GetPuppet then
                    local puppet = ent2.pk_pill_ent:GetPuppet()
                    if IsValid(puppet) then
                        puppet:SetRenderMode(RENDERMODE_TRANSALPHA)
                        puppet:SetColor(Color(255, 255, 255, 255))
                    end
                end

                hook.Remove("Think", name)
                return
            end
            if IsValid(createfakeragdoll) then
                ent2:SetNWEntity("OM_ragdollentity", createfakeragdoll)
                ent2:SetNWEntity("ragdollchar_om", createfakeragdoll)
            end
            shoulddocustomfunction(createfakeragdoll)
                
            local phys = createfakeragdoll:GetPhysicsObject()
            local vel = phys:GetVelocity()

            if ent2.loco then
                ent2.loco:SetVelocity(vel)
                ent2.loco:SetDesiredSpeed(vel:Length())
            end

            ent2:SetVelocity(vel * FrameTime())
                        
            local desiredPos = createfakeragdoll:GetPos()
            local mins, maxs = ent2:OBBMins(), ent2:OBBMaxs()

            local tr = util.TraceHull({
                start  = ent2:GetPos(),
                endpos = desiredPos,
                mins   = mins,
                maxs   = maxs,
                filter = function(ent)
                    if ent == ent2 then return false end
                    if ent == createfakeragdoll then return false end
                    return true
                end,
                mask = MASK_SOLID
            })

            if tr.Hit then
                local safePos = tr.HitPos + tr.HitNormal * 1
                ent2:SetPos(safePos)
            else
                ent2:SetPos(desiredPos)
            end

            if ent2.loco then
                ent2.loco:SetVelocity(vector_origin)
                ent2.loco:SetDesiredSpeed(0)
            end
            if ent2:IsNPC() or ent2:IsNextBot() then
                if ent2:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then
                    if ent2.CustomOMStun then
                        ent2:CustomOMStun()
                    else
                        ent2:NextThink(ent2:GetNW2Float("DisablePlayerMovement_OM_stun",0)+0.02)
                    end
                else
                    ent2:NextThink(CurTime() + 0.05)
                end
            end
            if ent2.pk_pill_ent and IsValid(ent2.pk_pill_ent) and ent2.pk_pill_ent.GetPuppet then
                local puppet = ent2.pk_pill_ent:GetPuppet()
                if IsValid(puppet) then
                    puppet:SetRenderMode(RENDERMODE_TRANSALPHA)
                    puppet:SetColor(Color(255, 255, 255, 0))
                    puppet:SetNWEntity("OM_ragdollentity", createfakeragdoll)
                    puppet:SetNWEntity("ragdollchar_om", createfakeragdoll)
                end
            end

            local tr = util.TraceHull({
                start = createfakeragdoll:GetPos(),
                endpos = createfakeragdoll:GetPos(),
                mins = Vector(-1, -1, -1),
                maxs = Vector(1, 1, 1),
                mask = MASK_NPCWORLDSTATIC,
                filter = createfakeragdoll
            })

            if not tr.Hit then
                currrentpos = createfakeragdoll:GetPos()
            end

            if ent2:Health() <= 0.1 then
                dead = true
                createfakeragdoll:Remove()
            end


            if ent2.GetActiveWeapon then
                local wep = ent2:GetActiveWeapon()
                if IsValid(wep) then
                    wep:SetNWFloat("om_invisiblemodel", CurTime()+0.15)
                end
            end
        end)
        return createfakeragdoll
    end
else
    hook.Add("PostDrawTranslucentRenderables", "om_invisiblemodel_ragdoll", function()
        for _, ent in ipairs(ents.GetAll()) do
            if not IsValid(ent) then continue end

            local shouldHide = IsValid(ent:GetNWEntity("OM_ragdollentity")) or ent:GetNWFloat("om_invisiblemodel") > CurTime()

            if shouldHide then
                ent.RenderOverride = function() end
            else
                ent.RenderOverride = nil
            end

            if shouldHide and not ent._omShadowHidden then
                --ent:DrawShadow(false)
                ent._omShadowHidden = true
            elseif not shouldHide and ent._omShadowHidden then
                --ent:DrawShadow(true)
                ent._omShadowHidden = false
            end
        end
    end)

    local factor = 0

    local lastposition, lastangles

        --[[
    hook.Add("CalcView", "RagdollHeadView_OM", function(ply, pos, angles, fov)
        local rag = ply:GetNWEntity("ragdollchar_om")

        if IsValid(rag) then
            factor = Lerp(FrameTime() * 8, factor, 1)
            if ply:GetInfoNum("om_pills_action_ragdollthirdperson", 1) == 1 then
                local startpos = rag:GetPos()
                local offset = angles:Forward() * -170

                local tr = util.TraceHull({
                    start = startpos,
                    endpos = startpos + offset,
                    filter = {rag, ply},
                    mins = Vector(-5, -5, -5),
                    maxs = Vector(5, 5, 5),
                    mask = MASK_VISIBLE
                })

                lastposition = tr.HitPos
                lastangles = angles
            else

                local headBone = rag:LookupBone("ValveBiped.Bip01_Head1")
                if headBone then
                    local headPos, headAng = rag:GetBonePosition(headBone)

                    if not headPos then
                        local physBone = rag:TranslateBoneToPhysBone(headBone)
                        local phys = rag:GetPhysicsObjectNum(physBone)
                        if IsValid(phys) then
                            headPos = phys:GetPos()
                            headAng = phys:GetAngles()
                        end
                    end

                    lastposition = headPos
                    lastangles = headAng
                end
            end
        else
            factor = Lerp(FrameTime() * 15, factor, 0)
            if factor <= 0.2 then 
                lastposition = pos
                lastangles = angles
            end
        end

        if factor <= 0.2 then return end

        return {
            origin = LerpVector(factor,pos,lastposition + lastangles:Forward() * 2),
            angles = LerpAngle(factor,angles,lastangles or angles),
            fov = fov,
            drawviewer = true
        }
    end)]]


end

-- STUN STATUS
if SERVER then

    function Mutual_OMCanStun(ply, ent, target, ifcanstack)
        if target then 
            if target:GetNW2Bool("clashingminigame_om_isinminigame") then return false end
            if ifcanstack then
                if target:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then
                    return true
                end
            end
            local shortenedvartest = ( target:GetNW2Bool("OM_character") and GetConVar('PVPStun_OM_clashing'):GetBool() and GetConVar('PVPStun_OM'):GetBool() )
            if shortenedvartest and target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe1") < CurTime() and target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") < CurTime()  then -- and ent.CanClashOpponents_OM and target.CanClashOpponents_OM
                return true
            end
            if target:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() then
                if target:GetNW2Bool("OM_character") then
                    return false
                end
            end
            if target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe1") < CurTime() and target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") < CurTime() and target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe3") < CurTime() then
                return true
            end
            return false
        end
    end

    function Mutal_OMCanDamage(ply, ent, target)
        if target then
            return target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe1") < CurTime() and target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") < CurTime() and target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe3") < CurTime()
        end
    end
    function Mutal_OMCanDamage_grab(ply, ent, target)
        if target then
            local pillentity = target.pk_pill_ent
            if IsValid(pillentity) or target.formTable then
                if target.formTable then
                    pillentity = target
                end
                if pillentity:GetNW2Float("Rings") > 0 or ent:GetNW2Float("DrainRings_OM_".. ent:EntIndex().. " ".. pillentity:EntIndex()) > CurTime() then
                    if ent:GetNW2Float("DrainRings_OM_".. ent:EntIndex().. " ".. pillentity:EntIndex()) < CurTime() then
                        ent:SetNW2Float("DrainRings_OM_".. ent:EntIndex().. " ".. pillentity:EntIndex(), CurTime()+0.4)
                        pillentity:SetNW2Float("Rings", pillentity:GetNW2Float("Rings")-15)

                        local dmg = DamageInfo()
                        dmg:SetDamage(0.1)
                        dmg:SetAttacker(ply)
                        dmg:SetInflictor(ply)
                        dmg:SetDamageType(DMG_CRUSH)
                        dmg:SetDamagePosition(target:GetPos())

                        target:TakeDamageInfo(dmg)

                        if pillentity:GetNW2Float("Rings") < 0 then
                            pillentity:SetNW2Float("Rings", 0)
                        end
                    end
                    return false
                end
            end
            --local rag = target:GetNWEntity("OM_ragdollentity")
            --if IsValid(rag) then return false end

            if target:GetNW2Float("ragdolltype_grab") > CurTime() and ent:GetNW2Float("ragdolltype_bypass") < CurTime() then
                return false
            end
            
            return target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe1") < CurTime() and target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") < CurTime() and target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe3") < CurTime()
        end
    end

    function Mutaul_OMStunCode(DataTable)
        local tableofitemz = {}

        -- stun data
        if DataTable.ply ~= nil then tableofitemz["ply"] = DataTable.ply end
        if DataTable.ent ~= nil ~= nil then tableofitemz["ent"] = DataTable.ent end
        if DataTable.target ~= nil then tableofitemz["target"] = DataTable.target end
        if DataTable.StunDur ~= nil then tableofitemz["StunDur"] = DataTable.StunDur else tableofitemz[StunDur] = 1 end
        if DataTable.stunfunction ~= nil then tableofitemz["stunfunction"] = DataTable.stunfunction end
        if DataTable.shouldstack ~= nil then tableofitemz["shouldstack"] = DataTable.shouldstack end
        if DataTable.IgnoreBoundries ~= nil then tableofitemz["IgnoreBoundries"] = DataTable.IgnoreBoundries end
        if DataTable.CallForClashing ~= nil then tableofitemz["CallForClashing"] = DataTable.CallForClashing else tableofitemz["CallForClashing"] = false end
        if DataTable.Counter ~= nil then tableofitemz["Counter"] = DataTable.Counter else tableofitemz["Counter"] = false end
        if DataTable.checkoutprevention ~= nil then tableofitemz["checkoutprevention"] = DataTable.checkoutprevention else tableofitemz["checkoutprevention"] = false end

        -- damage data
        if DataTable.Damage ~= nil then tableofitemz["Damage"] = DataTable.Damage else tableofitemz[Damage] = 25 end
        if DataTable.DamageType ~= nil then tableofitemz["DamageType"] = DataTable.DamageType else tableofitemz[DamageType] = DMG_CLUB end
        if not DataTable.ply then return end
        if not DataTable.ent then return end
        if not DataTable.target then return end

        local ent2 = DataTable.target
        local ply = DataTable.ply
        if !IsValid(ent2) then return end
        local currentEntStun = ent2:GetNW2Float("DisablePlayerMovement_OM_stun") 
        
        local shouldstundamage = false
        local blocked = false
        local shouldstun1 = true
        local shouldstun2 = true
        if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return end
        if ent2:GetNW2Bool("clashingminigame_om_isinminigame") then return end

        if ( ent2:GetNW2Bool("OM_character") and GetConVar('PVPStun_OM'):GetBool() ) or not ent2:GetNW2Bool("OM_character") then
            if ent2.OM_StunFunction then
                ent2.OM_StunFunction(tableofitemz)
            end
            if not tableofitemz.IgnoreBoundries then
                if ent2.OM_AfterStunBlock then
                    local functiontun = ent2.OM_AfterStunBlock(tableofitemz)
                    if (!istable(functiontun) and functiontun == 'cancelstun') or (istable(functiontun) and (functiontun.canceltype and functiontun.canceltype == 'cancelstun') ) then
                        blocked = true
                    elseif (!istable(functiontun) and functiontun == 'effectstun') or (istable(functiontun) and (functiontun.canceltype and functiontun.canceltype == 'effectstun') ) then -- EFFECTS STATUS
                        if functiontun.ply ~= nil then tableofitemz["ply"] = functiontun.ply end
                        if functiontun.ent ~= nil then tableofitemz["ent"] = functiontun.ent end
                        if functiontun.target ~= nil then tableofitemz["target"] = functiontun.target end
                        if functiontun.StunDur ~= nil then tableofitemz["StunDur"] = functiontun.StunDur end
                        if functiontun.stunfunction ~= nil then tableofitemz["stunfunction"] = functiontun.stunfunction end
                        if functiontun.shouldstack ~= nil then tableofitemz["shouldstack"] = functiontun.shouldstack end
                        if functiontun.IgnoreBoundries ~= nil then tableofitemz["IgnoreBoundries"] = functiontun.IgnoreBoundries end

                        -- damage data
                        if functiontun.Damage ~= nil then tableofitemz["Damage"] = functiontun.Damage end
                        if functiontun.DamageType ~= nil then tableofitemz["DamageType"] = functiontun.DamageType end

                        if functiontun.shouldblock then
                            blocked = true
                        end
                    end
                end

                --print(tableofitemz["CallForClashing"])

                if tableofitemz.target:GetNW2Float("DisablePlayerMovement_OM_stun_iframe3") > CurTime() and not tableofitemz.CallForClashing and not DataTable.Counter then
                    --print('s')
                    return
                end

                if ent2.OM_ShouldClash and ply.OM_ShouldClash then -- tableofitemz["CallForClashing"]
                    local variable = (ent2.OM_ShouldClash(tableofitemz) or false) and (ply.OM_ShouldClash(tableofitemz) or false)
                    if variable then
                        shouldstun1 = false
                    else
                        shouldstun1 = true
                    end
                end
                if ent2.OM_ShouldStun then
                    local variable = ent2.OM_ShouldStun(tableofitemz)
                    if variable then
                        shouldstun2 = true
                    else
                        shouldstun2 = false
                    end
                end
            end


            if currentEntStun > CurTime() then
                tableofitemz.StunDur = tableofitemz.StunDur * GetConVar('OUTCOMEMEMORIES_Stun_StunStackMultiplyer'):GetFloat()
            else
                tableofitemz.StunDur = tableofitemz.StunDur * GetConVar('OUTCOMEMEMORIES_Stun_StunMultiplyer'):GetFloat()
            end

            local stunamount = currentEntStun+tableofitemz.StunDur
            if GetConVar('OUTCOMEMEMORIES_Stun_StunLimit'):GetBool() then
                tableofitemz.StunDur = math.Clamp(tableofitemz.StunDur, -1e9, GetConVar("OUTCOMEMEMORIES_Stun_StunLimitDuration"):GetFloat())
                stunamount = math.Clamp(currentEntStun+tableofitemz.StunDur, -1e9, CurTime()+GetConVar("OUTCOMEMEMORIES_Stun_StunLimitDuration"):GetFloat())
            end
            if not blocked then
                shouldstundamage = true
                if currentEntStun > CurTime() then
                    if tableofitemz.shouldstack then
                        if shouldstun1 and shouldstun2 then 

                            local amount = ent2:GetNW2Float("DisablePlayerMovement_OM_stun") - CurTime()
                            if not GetConVar('OUTCOMEMEMORIES_Stun_StunCanStackDuration'):GetBool() and not tableofitemz["checkoutprevention"] then
                                local maxamout = ent2:GetNWFloat("DisablePlayerMovement_OM_stun_count")
                                stunamount = CurTime() + math.Clamp(amount+tableofitemz.StunDur, -1e9, maxamout)
                            else
                                ent2:SetNWFloat("DisablePlayerMovement_OM_stun_count", amount*1.25)
                            end

                            if ent2:IsPlayer() then
                                ent2:SetNW2Float("DisablePlayerMovement_OM_stun",stunamount)
                            else
                                if ent2:IsNextBot() or ent2:IsNPC() then 
                                    if ent2.CustomOMStun then
                                        ent2:CustomOMStun()
                                    else
                                        if ent2.loco then
                                            ent2.loco:SetVelocity(vector_origin)
                                            ent2.loco:SetDesiredSpeed(0)
                                        end
                                        ent2:NextThink(currentEntStun+tableofitemz.StunDur)
                                    end
                                    ent2:SetNW2Float("DisablePlayerMovement_OM_stun", stunamount)
                                end
                            end
                        end
                    end
                else
                    shouldstundamage = true
                    if shouldstun1 and shouldstun2 then 
                        ent2:SetNW2Float("DisablePlayerMovement_OM_stun",CurTime()+tableofitemz.StunDur)
                        ent2:SetNWFloat("DisablePlayerMovement_OM_stun_count", tableofitemz.StunDur)
                        if ent2:IsPlayer() then
                        else
                            if ent2:IsNextBot() or ent2:IsNPC() then 
                                if ent2.CustomOMStun then
                                    ent2:CustomOMStun()
                                else
                                    if ent2.loco then
                                        ent2.loco:SetVelocity(vector_origin)
                                        ent2.loco:SetDesiredSpeed(0)
                                    end

                                    ent2:NextThink(CurTime()+tableofitemz.StunDur)
                                end
                            end
                        end
                    end
                end 
                if tableofitemz.StunDur > 0 then 
                    if GetConVar('OUTCOMEMEMORIES_Stun_StunIframesAfterStun'):GetBool() and not tableofitemz["target"]:GetNW2Bool("OM_character") then
                        ent2:SetNW2Float("DisablePlayerMovement_OM_stun_iframe1",ent2:GetNW2Float("DisablePlayerMovement_OM_stun") + GetConVar('OUTCOMEMEMORIES_Stun_StunIframesDuration'):GetFloat() )
                    end
                end
            else

                if tableofitemz.ent.OM_Stun_Blockfunction then
                    tableofitemz.ent.OM_Stun_Blockfunction(shouldstundamage)
                else
                    if tableofitemz.ply.OM_Stun_Blockfunction then
                        tableofitemz.ply.OM_Stun_Blockfunction(shouldstundamage)
                    else
                    end
                end
            end

            if ent2:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then
                local stunamountnow = math.Clamp(ent2:GetNW2Float("DisablePlayerMovement_OM_stun")-CurTime(), 0, GetConVar("OUTCOMEMEMORIES_Stun_StunLimitDuration"):GetFloat())
                ent2:SetNW2Float("DisablePlayerMovement_OM_stun", CurTime() + stunamountnow)
            end
        end


        if tableofitemz.stunfunction then
            tableofitemz.stunfunction(shouldstundamage)
        else
        end
        
        if shouldstundamage then
            if GetConVar("Damage_OM"):GetBool() then else tableofitemz.Damage = 0.1 end
            if SERVER then
                local dmg = DamageInfo()
                dmg:SetDamage(tableofitemz.Damage)
                dmg:SetAttacker(tableofitemz.ply)
                dmg:SetInflictor(tableofitemz.ply)
                dmg:SetDamageType(tableofitemz.DamageType)
                dmg:SetDamagePosition(ent2:GetPos())

                ent2:TakeDamageInfo(dmg)
            end
        end
    end
else
    local starMat = Material("icons/Skyxboxer_stareffect.png")

    local dizzyAlpha = {}
    local dizzyBobData = {}
    local dizzyTrails = {}

    hook.Add("PostDrawTranslucentRenderables", "DizzyStarsEffect_OM_stunned", function()
        local curTime = CurTime()
        local frameTime = FrameTime()

        for _, ent in ipairs(ents.GetAll()) do
            if not IsValid(ent) then
                dizzyTrails[ent] = nil
                continue
            end

            local stunEnd = ent:GetNW2Float("DisablePlayerMovement_OM_stun", 0)
            local shouldShow = stunEnd > curTime and GetConVar("om_pills_Shouldshowstun"):GetBool() == true

            dizzyAlpha[ent] = dizzyAlpha[ent] or 0
            dizzyBobData[ent] = dizzyBobData[ent] or {
                nextSwitch = 0,
                bobActive = false
            }
            dizzyTrails[ent] = dizzyTrails[ent] or {}

            local target = shouldShow and 255 or 0
            dizzyAlpha[ent] = Lerp(frameTime * 8, dizzyAlpha[ent], target)

            local alpha = dizzyAlpha[ent]
            if alpha < 1 then continue end

            local bobData = dizzyBobData[ent]
            if curTime > bobData.nextSwitch then
                bobData.bobActive = math.random() > 0.5
                bobData.nextSwitch = curTime + math.Rand(0.8, 2)
            end

            local topPos = ent:LocalToWorld(Vector(0, 0, ent:OBBMaxs().z * 0.85))

            local time = curTime
            local starCount = 3
            local radius = 22

            if bobData.bobActive then
                topPos = topPos + Vector(0, 0, math.sin(time * 2) * 6)
            end

            render.SetMaterial(starMat)

            for i = 1, starCount do
                local angle = time * 4 + (i / starCount) * math.pi * 2

                local offset = Vector(
                    math.cos(angle) * radius,
                    math.sin(angle) * radius,
                    math.sin(time * 3 + i) * 2
                )

                local drawPos = topPos + offset

                dizzyTrails[ent][i] = dizzyTrails[ent][i] or {}
                local trail = dizzyTrails[ent][i]

                table.insert(trail, 1, drawPos)

                if #trail > 6 then
                    table.remove(trail)
                end

                for t = 1, #trail do
                    local pos = trail[t]

                    local fade = (1 - (t / #trail))
                    local trailAlpha = alpha * fade * 0.6

                    render.DrawSprite(
                        pos,
                        6 * fade,
                        6 * fade,
                        Color(255, 255, 255, trailAlpha)
                    )
                end

                render.DrawSprite(
                    drawPos,
                    8, 8,
                    Color(255, 255, 0, alpha)
                )
            end
        end
    end)

    hook.Add( "PreDrawOutlines_om_optimized", "DownedEntity_OM_highlight", function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        local pillentity = LocalPlayer().pk_pill_ent
        local isdrgbase = false

        if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end

        if IsValid(pillentity) and pillentity.formTable and pillentity.formTable.Outcomememories then
            if ply:GetNW2Bool("OM_character") or (isdrgbase and pillentity:GetNW2Bool("OM_character") ) then   

                om_halo.Add_optimized(
                    function(ent)
                        return ent:GetNW2Bool("Survivor_Downed_OM")
                    end, 
                    function(ent) 
                        return Color(255, 255, 255, 255)
                    end, 
                    1, 
                    false)  
            end
        end
    end )


    function downed_drawhud_om()
    end

    hook.Add("PreRenderColor_om_plain_optimized", "DownedEntity_OM", function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        local pillentity = LocalPlayer().pk_pill_ent
        local isdrgbase = false

        if not IsValid(pillentity) and IsValid(ply:GetNW2Entity("DrGBasePossessing")) then
            pillentity = ply:GetNW2Entity("DrGBasePossessing")
            isdrgbase = true
        end

        if IsValid(pillentity) and pillentity.formTable and pillentity.formTable.Outcomememories then
            if ply:GetNW2Bool("OM_character") or (isdrgbase and pillentity:GetNW2Bool("OM_character") ) then 
                om_color.Add_plainoptimized({ 
                    Canfuction = function(ent) 
                        return ent:GetNW2Bool("Survivor_Downed_OM")
                    end, 
                    color = function(ent)

                        return Color(255, 0, 0, 255*0.25)
                    end,
                    ignorez = false 
                })
            end
        end
    end)

end 

-- BURN STATUS --
if SERVER then
    hook.Add("EntityEmitSound", "DisableBurnPainSounds_om", function(data)
        local ent = data.Entity
        if not IsValid(ent) then return end

        local snd = string.lower(data.SoundName or "")

        if CurTime() > ent:GetNWFloat("BurningStatusDuration_OM", 0) then
            return
        end

        if snd == "player/pl_burnpain1.wav" or snd == "player/pl_burnpain2.wav" or snd == "player/pl_burnpain3.wav" then
            return false
        end
    end)

    function OM_burntarget(inflicter,target,duration, shouldntblood)
        target:SetNWEntity("BurningStatusInflicter_OM", inflicter)
        if target:GetNWFloat("BurningStatusDuration_OM", 0) < CurTime() then
            target:SetNWFloat("BurningStatusDuration_OM", CurTime()+math.Clamp(duration,0,7))
            local BurnCooldown = CurTime()

            local id = "OM_burntarget_BurnEffect" .. target:EntIndex()


            AdvancedPillSound(
                {
                    stringe = "ambient/fire/ignite.wav",
                    pitchPercent = 100,
                    volume = 0.1,
                    soundLevel = 87
                },
                target
            )

            hook.Add("Think", id, function()
                if !IsValid(target) then
                    hook.Remove("Think", id)
                    return
                end
                if CurTime() > target:GetNWFloat("BurningStatusDuration_OM", 0) then
                    hook.Remove("Think", id)
                    return
                end
                if target:Health() <= 0.1 then
                    hook.Remove("Think", id)
                    return
                end

                if BurnCooldown <= CurTime() then
                    BurnCooldown = CurTime()+0.25
                    --if shouldntblood and GetConVar("Damage_OM"):GetBool() and inflicter:GetNW2Bool("Survivor_OM") then 
                    --else
                        local ply = target:GetNWEntity("BurningStatusInflicter_OM")
                        local dmg = DamageInfo()
                        if !IsValid(ply) then
                            ply = target
                        end

                        if ply == target and ply:IsNextBot() and target:IsNextBot() then
                            ply = game.GetWorld()
                        end

                        dmg:SetAttacker(ply)
                        dmg:SetInflictor(ply)
                        dmg:SetDamageType(DMG_BURN)
                        dmg:SetDamage(1)
                        dmg:SetDamagePosition(target:GetPos())

                        target:TakeDamageInfo(dmg)
                    --end
                end
                
                if target.pk_pill_ent then
                    target.pk_pill_ent:GetPuppet():SetNWFloat("DarkerMode_om", CurTime() + 0.2)
                else
                    target:SetNWFloat("DarkerMode_om", CurTime() + 0.2)
                end
                target:SetNWFloat("OM_FireSlowdown", CurTime() + 0.2)
            end)
        else

            local without = target:GetNWFloat("BurningStatusDuration_OM") - CurTime()
            local addamount = duration/ 5
            local setvalue = math.Clamp(without + addamount,0,7)
            target:SetNWFloat("BurningStatusDuration_OM", CurTime()+setvalue  )
        end
    end
    
else


    local function IsAttachmentBone(ent, bone)
        local name = ent:GetBoneName(bone)
        if not name or name == "__INVALIDBONE__" then return true end

        name = string.lower(name)

        if string.find(name, "attach", 1, true) or
           string.find(name, "attachment", 1, true) or
           string.find(name, "weapon", 1, true) or
           string.find(name, "muzzle", 1, true) or
           string.find(name, "anim_attachment", 1, true) then
            return true
        end

        return false
    end

    local function GetBoneMedianPosition(ent)
        if not IsValid(ent) then return ent:GetPos() end

        local boneCount = ent:GetBoneCount()
        if not boneCount or boneCount <= 0 then
            return ent:LocalToWorld(ent:OBBCenter())
        end

        local positions = {}

        for i = 0, boneCount - 1 do
            if IsAttachmentBone(ent, i) then continue end

            local pos = ent:GetBonePosition(i)

            if pos and pos ~= vector_origin then
                positions[#positions + 1] = pos
            end
        end

        if #positions == 0 then
            return ent:LocalToWorld(ent:OBBCenter())
        end

        table.sort(positions, function(a, b)
            return a.x < b.x
        end)

        local mid = math.floor(#positions / 2) + 1
        local medianX = positions[mid].x

        table.sort(positions, function(a, b)
            return a.y < b.y
        end)

        local medianY = positions[mid].y

        table.sort(positions, function(a, b)
            return a.z < b.z
        end)

        local medianZ = positions[mid].z

        return Vector(medianX, medianY, medianZ)
    end

    local function GetBoneSpread(ent, center)
        if not IsValid(ent) then return 1 end

        local boneCount = ent:GetBoneCount()
        if not boneCount or boneCount <= 0 then return 1 end

        local total = 0
        local count = 0

        for i = 0, boneCount - 1 do
            if IsAttachmentBone(ent, i) then continue end

            local pos = ent:GetBonePosition(i)

            if pos and pos ~= vector_origin then
                total = total + pos:Distance(center)
                count = count + 1
            end
        end

        if count <= 0 then return 1 end

        local avgDist = total / count

        return math.Clamp(avgDist / 35, 1, 6)
    end

    hook.Add("PreRenderColor_om_render_optimized", "burn_DarkenModel_om", function()
        if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then
        else
            om_color.Add_renderoptimized({ 
                Canfuction = function(ent) 
                    ent.burn_om_glowing = ent.burn_om_glowing or 0
                    if ent:GetNWFloat("DarkerMode_om", 0) >= CurTime() then
                        ent.burn_om_glowing = Lerp(FrameTime() * 2, ent.burn_om_glowing, 1)
                    else
                        ent.burn_om_glowing = Lerp(FrameTime() * 2, ent.burn_om_glowing, 0)
                    end

                    ent.burn_om_glowing = ent.burn_om_glowing or 0
                    return ent.burn_om_glowing and ent.burn_om_glowing > 0.025
                end, 
                ignorez = false,
                rendereffects = function(ent)

                    ent.burn_om_glowing = ent.burn_om_glowing or 0
                    local multiplyer = ent.burn_om_glowing*0.85 * ent:GetColor().a / 255

                    DrawSharpen(
                        0.65*multiplyer, -- contrast
                        3.0*multiplyer  -- distance
                    )

                    DrawColorModify({
                        ["$pp_colour_addr"]       = 1*multiplyer,
                        ["$pp_colour_addg"]       = -0.5*multiplyer,
                        ["$pp_colour_addb"]       = -0.5*multiplyer,
                        ["$pp_colour_brightness"] = 0*multiplyer,
                        ["$pp_colour_contrast"]   = 1+3*multiplyer,
                        ["$pp_colour_colour"]     = 1,
                        ["$pp_colour_mulr"]       = 1*multiplyer,
                        ["$pp_colour_mulg"]       = 0*multiplyer,
                        ["$pp_colour_mulb"]       = 0*multiplyer
                    })


                    local pos = GetBoneMedianPosition(ent)

                    local spreadScale = GetBoneSpread(ent, pos)

                    local factor = math.Clamp(
                        (ent:GetNWFloat("BurningStatusDuration_OM") - CurTime()) / 2,
                        0.5,
                        1.25
                    ) * spreadScale

                    local Up = vector_up

                    local coneSize = 0.25 * factor * spreadScale

                    local emitter = ParticleEmitter(pos)

                    for i = 1, math.Round(5 * spreadScale) do
                        local dir = (
                            Up +
                            VectorRand() * coneSize
                        ):GetNormalized()

                        dir.z = math.abs(dir.z)

                        local spark = emitter:Add(
                            "effects/spark",
                            pos + VectorRand() * (4 * spreadScale)
                        )

                        if spark then
                            spark:SetVelocity(
                                dir * math.Rand(250, 700) * spreadScale
                            )

                            spark:SetLifeTime(0)
                            spark:SetDieTime(math.Rand(0.15, 0.4) * factor)

                            spark:SetStartAlpha(255 * factor)
                            spark:SetEndAlpha(0)

                            spark:SetStartSize(math.Rand(2, 5) * factor * spreadScale)
                            spark:SetEndSize(0)

                            spark:SetRoll(math.Rand(-180, 180))
                            spark:SetRollDelta(math.Rand(-12, 12))

                            spark:SetColor(
                                255,
                                math.random(180, 255),
                                math.random(80, 140)
                            )

                            spark:SetAirResistance(20)
                            spark:SetGravity(Vector(0, 0, -250))

                            spark:SetCollide(true)
                            spark:SetBounce(0.2)
                        end
                    end

                    for i = 1, math.Round(4 * spreadScale) do
                        local dir = (Up + VectorRand() * coneSize):GetNormalized()

                        local smoke = emitter:Add(
                            "particle/particle_smokegrenade",
                            pos + VectorRand() * (16 * spreadScale)
                        )

                        if smoke then
                            smoke:SetVelocity(
                                dir * math.Rand(160, 480) * spreadScale +
                                Vector(0, 0, math.Rand(120, 280))
                            )

                            smoke:SetLifeTime(0)
                            smoke:SetDieTime(math.Rand(2.5, 4) * 0.15 * factor)

                            smoke:SetStartAlpha(math.Rand(90, 245) * factor)
                            smoke:SetEndAlpha(0)

                            smoke:SetStartSize(math.Rand(48, 80) / 5 * spreadScale)
                            smoke:SetEndSize(math.Rand(144, 224) / 7 * spreadScale)

                            smoke:SetRoll(math.Rand(-180, 180))
                            smoke:SetRollDelta(math.Rand(-0.5, 0.5))

                            smoke:SetColor(60, 60, 60)

                            smoke:SetAirResistance(120)
                            smoke:SetGravity(Vector(0, 0, 80))
                            smoke:SetCollide(false)
                        end
                    end

                    for i = 1, math.Round(2 * spreadScale) do
                        local p = emitter:Add(
                            "particles/flamelet" .. math.random(1, 5),
                            pos + VectorRand() * (8 * spreadScale)
                        )

                        if p then
                            p:SetVelocity(
                                Up * math.Rand(120, 220) * spreadScale +
                                VectorRand() * (25 * spreadScale)
                            )

                            p:SetLifeTime(0)
                            p:SetDieTime(math.Rand(0.2, 0.5) * 0.35 * factor)

                            p:SetStartAlpha(255 * factor)
                            p:SetEndAlpha(0)

                            p:SetStartSize(math.Rand(8, 14) * factor * spreadScale)
                            p:SetEndSize(0)

                            p:SetRoll(math.Rand(-180, 180))
                            p:SetRollDelta(math.Rand(-2, 2))

                            p:SetColor(255, 140, 40)

                            p:SetAirResistance(50)
                            p:SetGravity(Vector(0, 0, 40))
                            p:SetCollide(false)
                        end
                    end

                    for i = 1, math.Round(3 * spreadScale) do
                        local dir = (Up + VectorRand() * coneSize * 2):GetNormalized()

                        local p = emitter:Add(
                            "particles/flamelet" .. math.random(1, 5),
                            pos + VectorRand() * (12 * spreadScale)
                        )

                        if p then
                            p:SetVelocity(
                                dir * math.Rand(150, 300) * spreadScale
                            )

                            p:SetLifeTime(0)
                            p:SetDieTime(math.Rand(0.3, 0.7) * 0.5 * factor)

                            p:SetStartAlpha(255 * factor)
                            p:SetEndAlpha(0)

                            p:SetStartSize(math.Rand(10, 18) * 1.5 * factor * spreadScale)
                            p:SetEndSize(0)

                            p:SetRoll(math.Rand(-180, 180))
                            p:SetRollDelta(math.Rand(-4, 4))

                            p:SetColor(255, math.random(100, 180), 40)

                            p:SetAirResistance(80)
                            p:SetGravity(Vector(0, 0, 20))
                            p:SetCollide(false)
                        end
                    end

                    emitter:Finish()

                    
                end
            })
        end
    end)

end

-- daze effect
if SERVER then
    
else   

    hook.Add("RenderScreenspaceEffects", "OM_dazeeffect", function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        if ply:GetNWFloat("om_daze", 0) > CurTime() then
            if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then
                local colorModify = {
                    ["$pp_colour_addr"] = 0.35,
                    ["$pp_colour_addg"] = 0,
                    ["$pp_colour_addb"] = 0,

                    ["$pp_colour_brightness"] = 0,
                    ["$pp_colour_contrast"] = 1,
                    ["$pp_colour_colour"] = 1,

                    ["$pp_colour_mulr"] = 0,
                    ["$pp_colour_mulg"] = 0,
                    ["$pp_colour_mulb"] = 0
                }

                DrawColorModify(colorModify)

                local sobelIntensity = 1
                DrawSobel(sobelIntensity)

                local motionBlurStrength = 0
                local motionBlurDelay = 0
                local motionBlurFade = 0
                DrawMotionBlur(motionBlurStrength, motionBlurDelay, motionBlurFade)

                local sharpenAmount = 0
                local sharpenDistance = 0
                DrawSharpen(sharpenAmount, sharpenDistance)

                local overlayMaterial = ""
                local overlayAlpha = 0
                DrawMaterialOverlay(overlayMaterial, overlayAlpha)
            else

                local colorModify = {
                    ["$pp_colour_addr"] = 1,
                    ["$pp_colour_addg"] = 0,
                    ["$pp_colour_addb"] = 0,

                    ["$pp_colour_brightness"] = 0,
                    ["$pp_colour_contrast"] = 0.9,
                    ["$pp_colour_colour"] = 1.3,

                    ["$pp_colour_mulr"] = 1,
                    ["$pp_colour_mulg"] = 0,
                    ["$pp_colour_mulb"] = 0
                }

                DrawColorModify(colorModify)

                local sobelIntensity = 0.01
                DrawSobel(sobelIntensity)

                local motionBlurStrength = 0.2
                local motionBlurDelay = 0.4
                local motionBlurFade = 0.01
                DrawMotionBlur(motionBlurStrength, motionBlurDelay, motionBlurFade)

                local sharpenAmount = 0
                local sharpenDistance = 0
                DrawSharpen(sharpenAmount, sharpenDistance)

                local overlayMaterial = ""
                local overlayAlpha = 0
                DrawMaterialOverlay(overlayMaterial, overlayAlpha)

            end
        end

    end)
end