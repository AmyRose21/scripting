--NoHealing_OM_Noodles
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

local preservedmats = {
    ["Sonic_OM_noodles_spindash"] = Material("icons/Sonic_OM_noodles_spindash.png"),
    ["Sonic_OM_noodles_peelout"] = Material("icons/Sonic_OM_noodles_peelout.png"),
}
pk_pills.register('pill_om_Sonic', {

    printName='Sonic',
    Outcomememories='Sonic',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/sonic.mdl",
    --[[
    hull = Vector(20,20,60),
    duckBy = 14,
    ]]
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',

    ShouldRoll_om = function(e, ply, ent)
        if ent:GetNW2Float("Spindash_Duration") > CurTime() or ent:GetNW2Float("spindash_fake") > CurTime() then
            return false
        end
        return true
    end,

    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            return true
        end,
        colorbar = function(uselessvar,ply,ent)
            return Color(0, 0, 255, 255)
        end,
        progression = function(uselessvar,ply,ent)
            return ent:GetNW2Float("Rings")
        end,
        maximumbar = function(uselessvar,ply,ent)
            return ent:GetNW2Float("MaxRings")
        end,
    },

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Sonic_OM_noodles_spindash"]
            end,
            name = function(uselessvar,ply,ent)
                return "DropDash"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Sonic_dropdash_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Spindash_Cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Spindash_Cooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize*0.02, yaxis = 0+ iconsize*0.02, xsize = 0, ysize = 0}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Sonic_OM_noodles_peelout"]
            end,
            name = function(uselessvar,ply,ent)
                return "Peelout"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_Sonic_peelout_key", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("PeelOut_Cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("PeelOut_Cooldown_duration", 0)
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 - iconsize*0.03, yaxis = 0, xsize = 0, ysize = 0}
            end,
            survivor = true,
            font = "CreditsText",
        }
    },
  
    Outcomememories_stats = {
        moveSpeed = {
            
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Sonic_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Sonic_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Sonic_walk"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Sonic_jumppower"):GetFloat()
                end
            end,
            Dropdash= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Sonic_DropDash"):GetFloat()
                end
            end,
            Peelout= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Sonic_PeelOut"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Sonic_jumpcd"):GetFloat()
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Sonic_rollingPower"):GetFloat()
                end
            end,
        },

        abilities = {
            ["DropDash"] = {
                ["ActivationKey"] = KEY_E,
                ["Cooldown"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_cooldownSucess"):GetFloat()
                    end
                end,
                ["Cooldownland"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_cooldownLand"):GetFloat()
                    end
                end,
                ["AddToPeelout"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_AddToPeelout"):GetFloat()
                    end
                end,
                ['StunEffect'] = function(ply, ent, ent2)
                    local shouldstunstack = GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_stunstack"):GetBool()

                    local stunamount = GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_basestun"):GetFloat()

                    if ent:GetNW2Float('Hit_OM_sonic') < GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_maxhits"):GetInt() - 1 then
                    else
                        stunamount = GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_basestun_final"):GetFloat()
                    end
                    

                    if Mutual_OMCanStun(ply, ent, ent2, shouldstunstack) then
                        Mutaul_OMStunCode(
                            {
                                ["ply"] = ply,
                                ["ent"] = ent,
                                ["target"] = ent2,
                                ["StunDur"] = stunamount, --(ent:GetNW2Float(StunTimesName) < 2) or 3
                                ["CallForClashing"] = true,
                                ["stunfunction"] = function(shouldstundamage)
                                    if shouldstundamage then
                                        ent:SetNW2Float('CooldownHit_OM_sonic', CurTime()+0.5)
                                        ent:SetNW2Float('OM_Noairmovemtn_noodles',CurTime()+0.5)
                                        local ed = EffectData()
                                        ed:SetOrigin(ent2:GetPos()+Vector(0,0,40))
                                        ed:SetEntity(ent2)
                                        util.Effect("sonic_spindashhit", ed)
                                        
                                        if IsValid(ent:GetNW2Entity("GlowingBallThingy_OM")) then
                                            ent:GetNW2Entity("GlowingBallThingy_OM"):SetNW2Float('sonic_attack_glow_duration',CurTime()+0.5*0.5)
                                        end
                                        if ent:GetNW2Float("PeelOut_duration") > CurTime() then
                                        else
                                            local ringgain = GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_ringgain"):GetFloat()

                                            ent:SetNW2Float("Rings", math.Clamp( (ent:GetNW2Float('Rings') + ringgain), 0, ent:GetNW2Float("MaxRings", 0) ) )
                                        end

                                        local hitdirection = ply:GetForward()

                                        if ent:GetNW2Float('Hit_OM_sonic') < GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_maxhits"):GetInt() - 1 then
                                            ent2:SetVelocity( ply:GetVelocity():GetNormalized()*750 )

                                            if ply:IsPlayer() then
                                                ply:SetNW2Float("OM_SetSliperyVelocity_pos_undo",CurTime()+0.4)
                                                ply:SetPos(ply:GetPos()+Vector(0,0,3))
                                                local dir = Vector(0,0,0.2) + (ply:GetPos() - ent2:GetPos()):GetNormalized()
                                                ply:SetLocalVelocity(dir * 350*1.45)
                                            else
                                                ply:SetPos(ply:GetPos()+Vector(0,0,43))
                                                local dir = (ply:GetPos() - (ent2:GetPos()+Vector(0,0,43))):GetNormalized()
                                                ply:SetVelocity(dir * 350*1.35)
                                            end
                                        else
                                            local oldpos = ply:GetPos()
                                            if ply:IsPlayer() then
                                                ply:SetMoveType(MOVETYPE_NONE)
                                            else
                                                ply:SetMoveType(2)
                                                if ply.loco then
                                                    ply.loco:SetVelocity(vector_origin)
                                                    ply.loco:SetDesiredSpeed(0)
                                                end
                                            end
                                            ent:SetNW2Float('Spindash_Duration_C',CurTime()-1)
                                            ent:SetNW2Float('Spindash_Duration',CurTime()-1)
                                            ply:SetNW2Float("OM_lowerFriction", CurTime()-1)
                                            ent:SetNW2Float('spindash_fake', CurTime()+1)

                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/sonic/dropdash_final.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )

                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/sonic/DropdashDrill.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )


                                            ply.SonicOldPos = ply:GetPos()

                                            if SERVER and GetConVar('PVPStun_OM_clashing'):GetBool() then
                                                if ent2.OM_ShouldClash then
                                                    local variable = ent2.OM_ShouldClash()
                                                    if variable then
                                                        OM_Minigame(ply, ent2)
                                                        ent:SetNW2Float('spindash_fake', CurTime()+1e9)
                                                        return
                                                    end
                                                end
                                            end

                                            ent2:SetNW2Float('sonic_attack_glow_duration',CurTime()+1.5)

                                            ply:SetPos(ent2:GetPos()+Vector(0,0,35))
                                            timer.Simple(0,function()
                                                if !IsValid(ent) then return end
                                                if !IsValid(ply) then return end
                                                ply:SetPos(ent2:GetPos()+Vector(0,0,35))
                                                local effect = EffectData()
                                                effect:SetOrigin(ply:GetPos())
                                                effect:SetNormal(ent:GetForward())

                                                util.Effect("sonic_dropdashdrill_OM", effect)
                                            end)

                                            ent:SetNW2Float('sonic_attack_glow_duration',CurTime()+1.5)
                                            ent:SetNW2Float("sonic_ability_outline2", CurTime()+1.5)
                                            
                                            timer.Simple(1,function()
                                                if !IsValid(ent) then return end
                                                if !IsValid(ply) then return end

                                                -- Set the CD
                                                local cdamount = ent.formTable.Outcomememories_stats.abilities.DropDash.Cooldownland()
                                                ent:SetNW2Float("Spindash_Cooldown", CurTime()+ cdamount )
                                                ent:SetNW2Float("Spindash_Cooldown_duration", cdamount )

                                                AdvancedPillSound(
                                                    {
                                                        stringe = "OM/sonic/SonicHitSound.wav",
                                                        pitchPercent = 100,
                                                        volume = 1,
                                                        soundLevel = 87
                                                    },
                                                    ent
                                                ) 

                                                timer.Simple(0.1,function()
                                                    if !IsValid(ply) then return end

                                                    local HitEntity = ent2
                                                    if IsValid(ent2) then

                                                        local center = HitEntity:WorldSpaceCenter() + ply:GetForward()*-30 + Vector(0,0,12)

                                                        local plyMins = ply:OBBMins()
                                                        local plyMaxs = ply:OBBMaxs()

                                                        local entMins = HitEntity:OBBMins()
                                                        local entMaxs = HitEntity:OBBMaxs()

                                                        local entRadius = math.max(
                                                            math.abs(entMins.x), math.abs(entMaxs.x),
                                                            math.abs(entMins.y), math.abs(entMaxs.y)
                                                        )

                                                        local plyRadius = math.max(
                                                            math.abs(plyMins.x), math.abs(plyMaxs.x),
                                                            math.abs(plyMins.y), math.abs(plyMaxs.y)
                                                        )

                                                        local startRadius = entRadius + plyRadius + 16

                                                        local function IsSafe(pos)
                                                            local tr = util.TraceHull({
                                                                start = pos,
                                                                endpos = pos,
                                                                mins = plyMins,
                                                                maxs = plyMaxs,
                                                                filter = ply,
                                                                mask = MASK_PLAYERSOLID
                                                            })

                                                            return not tr.Hit
                                                        end

                                                        local function FindSafePos()
                                                            local extraRadii = {0, 20, 40, 70, 100}

                                                            for _, extra in ipairs(extraRadii) do
                                                                local radius = startRadius + extra

                                                                for ang = 0, 350, 10 do
                                                                    local dir = Angle(0, ang, 0):Forward()

                                                                    local start = center + dir * radius + Vector(0, 0, 128)

                                                                    local ground = util.TraceHull({
                                                                        start = start,
                                                                        endpos = start - Vector(0, 0, 512),
                                                                        mins = plyMins,
                                                                        maxs = plyMaxs,
                                                                        filter = ply,
                                                                        mask = MASK_PLAYERSOLID
                                                                    })

                                                                    if ground.Hit then
                                                                        local pos = ground.HitPos + Vector(0, 0, 2)

                                                                        if IsSafe(pos) then
                                                                            return pos
                                                                        end
                                                                    end
                                                                end
                                                            end

                                                            return nil
                                                        end

                                                        local safePos = FindSafePos()

                                                        if safePos then
                                                            ply:SetPos(safePos)
                                                        else
                                                            local fallback = center + Vector(0, 0, entMaxs.z + 72)

                                                            if IsSafe(fallback) then
                                                                ply:SetPos(fallback)
                                                            end
                                                        end


                                                        local last = CurTime() + 1.25
                                                        local flung = false

                                                        local enemyragdoll = CreateRagdolLCharacter_OM({
                                                            target = ent2,
                                                            host = ent,

                                                            shouldremove = function(createfakeragdoll)
                                                                if not IsValid(createfakeragdoll) then return true end
                                                                if not IsValid(ent2) then return true end
                                                                if not IsValid(ent) then return true end

                                                                local pos = createfakeragdoll:GetPos()
                                                                            
                                                                local tr = util.TraceLine({
                                                                    start = pos,
                                                                    endpos = pos - Vector(0, 0, 10),
                                                                    filter = createfakeragdoll
                                                                })

                                                                if (last < CurTime() and tr.Hit ) or ent2:GetNW2Float("DisablePlayerMovement_OM_stun") < CurTime() then
                                                                    return true
                                                                else
                                                                    if not tr.Hit then
                                                                        last = CurTime() + 1.25
                                                                    end
                                                                end
                                                                return false
                                                            end,

                                                            shoulddocustomfunction = function(createfakeragdoll)
                                                                if not IsValid(createfakeragdoll) then return end
                                                                if not IsValid(ent) then return end
                                                                if flung then return end
                                                                flung = true

                                                                local ragPos = createfakeragdoll:GetPos()
                                                                local entPos = ent:GetPos()

                                                                local phys = createfakeragdoll:GetPhysicsObject()
                                                                if IsValid(phys) then
                                                                    phys:SetVelocity(hitdirection * 700)
                                                                    phys:AddAngleVelocity(VectorRand() * 600)
                                                                end

                                                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                                    local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                                    if IsValid(bonePhys) then
                                                                        bonePhys:SetVelocity(hitdirection * 700)
                                                                        bonePhys:AddAngleVelocity(VectorRand() * 600)
                                                                    end
                                                                end
                                                            end
                                                        })

                                                    end


                                                    if ply:IsPlayer() then
                                                        ply:SetMoveType(MOVETYPE_WALK)
                                                    else
                                                        ply:SetMoveType(11)
                                                        if SERVER then
                                                            ent.TeleportEnt = nil
                                                        end
                                                    end

                                                    timer.Simple(0.1,function()
                                                        if !IsValid(ent) then return end
                                                        local dir = Vector(0,0,0.3) +((ply:GetPos()+ply:GetForward()*-6) - (ply:GetPos()-Vector(0,0,1))):GetNormalized()
                                                        if ply:IsPlayer() then
                                                            ply:SetLocalVelocity(dir * 640)
                                                        else
                                                            ply:SetPos(ply:GetPos()+Vector(0,0,40))
                                                            ply:SetVelocity(dir * 640)
                                                        end
                                                    end)

                                                end)
                                            end)
                                        end
                                        
                                        ent:SetNW2Float('Hit_OM_sonic',ent:GetNW2Float('Hit_OM_sonic')+1)

                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/sonic/SonicHitSound.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        ) 
                                
                                        
                                    end
                                end,
                                ["checkoutprevention"] = true,
                                ["shouldstack"] = shouldstunstack,
                                ["Damage"] = GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_basedamage"):GetFloat(), -- ent:GetNW2Float(StunTimesName) < 2  and true or 30
                                ["DamageType"] = DMG_CLUB
                            }
                        )
                    end
                end,
            },
            ["PeelOut"] = {
                ["ActivationKey"] = KEY_T,
                ["CooldownSucess"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_cooldownSuccess"):GetFloat()
                    end
                end,
                ["CooldownFail"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_cooldownFail"):GetFloat()
                    end
                end,
            }
        }
    },

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            PeelOutStart = "PeelOutStart",
            Jump2='jump',
            Braking="Braking",
        },

        ShouldMoveRotate={
            idle= function(ent) 
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() or ent:GetNW2Float("spindash_fake") > CurTime() then return 'shiftlock' end
                return 'notanything' 
            end,
            run= function(ent) 
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() or ent:GetNW2Float("spindash_fake") > CurTime() then return 'shiftlock' end
                return 'notshftlock'
            end,
            walk= function(ent) 
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() or ent:GetNW2Float("spindash_fake") > CurTime() then return 'shiftlock' end
                return 'notshftlock'
            end,
            jump= function(ent) 
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() or ent:GetNW2Float("spindash_fake") > CurTime() then return 'shiftlock' end
                return 'notshftlock'
            end,
            fall= function(ent) 
                if ent:GetNW2Float("DropDash_Diving_alt") > CurTime() then
                    local ply = ent:GetPillUser()
                    local dir = ply:GetVelocity():GetNormalized()
                    local aheadPos = ply:GetPos() + dir * 5
                    local ang = (aheadPos - ply:GetPos()):Angle()
                    ent:SetNW2Angle("pill_assignedangle",ang)
                    return "assignedagnles"
                end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return "shiftlock" end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() or ent:GetNW2Float("spindash_fake") > CurTime() then return 'shiftlock' end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            jump= function(ent)
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return "PeelOut" end
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return "spindash" end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return "Fall" end
                if ent:GetNW2Float("DodgeAnim") > CurTime() then return "Dodge" .. ent:GetNW2Float("DodgeAnim_id") end
            end,
            walk= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() or ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return "PeelOut" end
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return "spindash" end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return "Fall" end
                if ent:GetNW2Float("DodgeAnim") > CurTime() then return "Dodge" .. ent:GetNW2Float("DodgeAnim_id") end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "walk_lowhealth"
                end 
            end,
            idle= function(ent) 
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedIdle' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() or ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return "PeelOut" end
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return "spindash" end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return "Fall" end  
                if ent:GetNW2Float("DodgeAnim") > CurTime() then return "Dodge" .. ent:GetNW2Float("DodgeAnim_id") end                       
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "idle_lowhealth"
                end 
            end,
            fall= function(ent) 
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() or ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return "PeelOut" end
                if ent:GetNW2Float("DropDash_Diving_alt") > CurTime() then return "dive" end
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return "spindash" end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return "Fall" end
                if ent:GetNW2Float("DodgeAnim") > CurTime() then return "Dodge" .. ent:GetNW2Float("DodgeAnim_id") end
            end,
            run= function(ent)
                if ent:GetPillUser():GetNW2Bool('Survivor_Downed_OM') then return 'DownedWalk' end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() or ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return "PeelOut" end
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return "spindash" end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return "Fall" end
                if ent:GetNW2Float("DodgeAnim") > CurTime() then return "Dodge" .. ent:GetNW2Float("DodgeAnim_id") end
                if ent:GetPillUser():GetNW2Float('LowestHealthCount_OM_pills') <= 60 then
                    return "run_lowhealth"
                end 
            end,
        },
        animrates = {
            idle = function(ent)
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return 0.5 end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local Factor = ( (ent:GetNW2Float("PeelOut_duration_anim") - CurTime()) / GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration"):GetFloat() ) *1
                    local clamp = math.Clamp(Factor, 0, 1)
                    local lerp = Lerp(clamp, 1.25, 0)
                    return lerp
                else
                    return 1
                end
            end,
            walk = function(ent)
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return 0.5 end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local Factor = ( (ent:GetNW2Float("PeelOut_duration_anim") - CurTime()) / GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration"):GetFloat() ) *1
                    local clamp = math.Clamp(Factor, 0, 1)
                    local lerp = Lerp(clamp, 1.25, 0)
                    return lerp
                else
                    return 1
                end
            end,

            run = function(ent)
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return 0.5 end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local Factor = ( (ent:GetNW2Float("PeelOut_duration_anim") - CurTime()) / GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration"):GetFloat() ) *1
                    local clamp = math.Clamp(Factor, 0, 1)
                    local lerp = Lerp(clamp, 1.2, 0)
                    return lerp
                else
                    return 1.2
                end
            end,

            fall = function(ent)
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return 0.5 end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local Factor = ( (ent:GetNW2Float("PeelOut_duration_anim") - CurTime()) / GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration"):GetFloat() ) *1
                    local clamp = math.Clamp(Factor, 0, 1)
                    local lerp = Lerp(clamp, 1.25, 0)
                    return lerp
                else
                    return 1
                end
            end,

            jump = function(ent)
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return 0.5 end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local Factor = ( (ent:GetNW2Float("PeelOut_duration_anim") - CurTime()) / GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration"):GetFloat() ) *1
                    local clamp = math.Clamp(Factor, 0, 1)
                    local lerp = Lerp(clamp, 1.25, 0)
                    return lerp
                else
                    return 1
                end
            end,

            PeelOut = function(ent)
                if ent:GetNW2Float("DropDash_Diving") > CurTime() then return 0.5 end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local Factor = ( (ent:GetNW2Float("PeelOut_duration_anim") - CurTime()) / GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration"):GetFloat() ) *1
                    local clamp = math.Clamp(Factor, 0, 1)
                    local lerp = Lerp(clamp, 1.25, 0)
                    return lerp
                else
                    return 1.25
                end
            end,
        }
    },

    OM_cameratable = function(ply,ent)
        local basetable =  {
            startoffset = Vector(20,0,25),  -- left-up, front-back, up-down
            dist=145,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 0,
            transition = 1,
            canscroll = true,
			bonecenter = "Torso",
        }
        if ent:GetNW2Float("Spindash_Duration") > CurTime() then
            basetable =  {
                startoffset = Vector(20,0,45),  -- left-up, front-back, up-down
                dist=145,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 2,
                transition = 1,
                canscroll = true,
            }
        end

        if ent:GetNW2Float("PeelOut_duration") > CurTime() then
            basetable =  {
                startoffset = Vector(20,0,45),  -- left-up, front-back, up-down
                dist=145,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 1,
                transition = 1,
                canscroll = true,
            }
        end

        if ply:GetNW2Bool("Survivor_Downed_OM") then
            basetable =  {
                startoffset = Vector(45,0,25),  -- left-up, front-back, up-down
                dist=50,
                fov = ply:GetInfoNum("om_pills_default_fov", 80)*0.85,
                id = 3,
                transition = 1,
                canscroll = false,
            }
        end

        ent.sonic_fov_lerp = ent.sonic_fov_lerp or 0 

        if ply:GetInfoNum("om_pills_action_camera_Sonic", 1) == 1 then
            if (ent:GetNW2Float("PeelOut_duration") > CurTime() or ent:GetNW2Float("Spindash_Duration") > CurTime()) and ply:GetVelocity():Length() > 300 or ent:GetVelocity():Length() > 300 then
                ent.sonic_fov_lerp = Lerp(FrameTime()*2, ent.sonic_fov_lerp, 1)
            else
                ent.sonic_fov_lerp = Lerp(FrameTime()*2, ent.sonic_fov_lerp, 0)
            end
        else
            ent.sonic_fov_lerp = Lerp(FrameTime()*3, ent.sonic_fov_lerp, 0)
        end

        basetable["fov"] = basetable["fov"] - ent.sonic_fov_lerp * 5
        basetable["dist"] = basetable["dist"] - ent.sonic_fov_lerp * 30

        return basetable
    end,
    
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },
        
    --canAim=function(ply,ent) return ent.active end,     

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if event == "Step" then
            StepSFX_OM(ply,ent)
            if ply:IsOnGround() then
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    local effect = EffectData()
                    effect:SetOrigin(ply:GetPos() + ent:GetPuppet():GetForward()*-15)
                    effect:SetNormal(ent:GetPuppet():GetForward()*-1)

                    util.Effect("sonic_peeloutdust2_OM", effect)
                end
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
    
        initializetable2["player"].ColorRGB_B_1_OM = Color(0,35,255, 255)
        if SERVER then

            initializetable2["entity"]:SetNW2Float("OM_Damage_Reduction",1)
            local health = GetConVar("OUTCOMEMEMORIES_N_Sonic_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)

            initializetable2["entity"]:SetNW2Float("Rings", GetConVar("OUTCOMEMEMORIES_N_Sonic_Dodgemeter"):GetFloat())
            initializetable2["entity"]:SetNW2Float("MaxRings", initializetable2["entity"]:GetNW2Float("Rings",0))
            initializetable2["entity"]:SetNW2Float("OM_friction",0.25)
            initializetable2["player"]:SetNW2Bool("SecondLife_OM", true)
            initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)

            initializetable2["entity"].CanClashOpponents_OM = true

            initializetable2["player"].CustomFunctionForDowned_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]
                    ent:SetNW2Float("Spindash_Duration", 0)
                    ent:SetNW2Float("PeelOut_duration", 0)
                    ent:SetNW2Float("PeelOut_duration2", 0)
                    ent:SetNW2Float("PeelOut_duration_anim", 0)

                    if ent.PeelOut_duration2_early_bool or ent.PeelOut_duration2_bool then
                        ent:SetNW2Float("PeelOut_Cooldown", CurTime()+ent.formTable.Outcomememories_stats.abilities.PeelOut.CooldownFail())

                    end

                    ent.PeelOut_duration2_early_bool = false
                    ent.PeelOut_duration2_bool = false
                end
            end
            initializetable2["player"].CustomFunctionCancelAbility_OM = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end
            initializetable2["player"].OM_Stun_Blockfunction = function()
                initializetable2["player"]:CustomFunctionForDowned_OM()
            end

            local oldpos = Vector(0,0,0)
            local ent22 = ent2

            initializetable2["player"].OMInitiateClash_lnz = function(v,ent2)
                if IsValid(initializetable2["entity"]) then

                    local ent = initializetable2["entity"]
                    local ply = initializetable2["player"]

                    ent22 = ent2

                    oldpos = ply:GetPos() + Vector(0,0,10)

                    local character = ""
                    if ent2.pk_pill_ent then
                        character = ent2.pk_pill_ent.formTable.printName
                    end
                    if ent2.formTable then
                        character = ent2.formTable.printName
                    end

                    local ent2pos = ent2:GetPos()
                    local plypos = ply:GetPos()
                    local angl = ( Vector(ent2pos.x,ent2pos.y,0)-Vector(plypos.x,plypos.y,0) ):Angle()
                    ent:SetNW2Angle("pill_assignedangle", angl)
                    ply:SetAngles(angl)
                    ent:SetAngles(angl)
                    if character == "Furnace" then
                        ply:SetPos(ent2:GetPos()+angl:Forward()*-60+ent2:GetUp()*26)
                    end

                    -- Set the CD
                    local cdamount = ent.formTable.Outcomememories_stats.abilities.DropDash.Cooldown()
                    ent:SetNW2Float("Spindash_Cooldown", CurTime()+ cdamount )
                    ent:SetNW2Float("Spindash_Cooldown_duration", cdamount )

                    local oldpos = ply:GetPos()
                    if ply:IsPlayer() then
                        ply:SetMoveType(MOVETYPE_NONE)
                    else
                        ply:SetMoveType(2)
                        if ply.loco then
                            ply.loco:SetVelocity(vector_origin)
                            ply.loco:SetDesiredSpeed(0)
                        end
                    end
                    ent:SetNW2Float('Spindash_Duration',CurTime()-1)
                    ply:SetNW2Float("OM_lowerFriction", CurTime()-1)
                    ent:SetNW2Float('spindash_fake', CurTime()+1e9)
                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/dropdash_final.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )


                    local effect = EffectData()
                    effect:SetOrigin(ply:GetPos())
                    effect:SetNormal(ent:GetForward())

                    util.Effect("sonic_dropdashdrill_OM", effect)

                    ply.SonicOldPos = ply:GetPos()

                end
            end

            initializetable2["player"].OM_ShouldClash = function()
                if IsValid(initializetable2["entity"]) then
                    if initializetable2["entity"]:GetNW2Float("DropDash_Diving") > CurTime() then return false end
                    if initializetable2["entity"]:GetNW2Float("Spindash_Duration") > CurTime() then return true end
                    if initializetable2["entity"]:GetNW2Float("spindash_fake") > CurTime() then return true end
                end
                return false
            end

            initializetable2["player"].OMCompelteClash_lnz = function(Wintype)
                if !IsValid(initializetable2["entity"]) then return end

                local ply = initializetable2["player"]
                local ent = initializetable2["entity"]

                ply:SetPos(oldpos)

                ply:SetNW2Float("OM_Damage_Reduction",1)
                
                ent:SetNW2Float('spindash_fake', CurTime()-1)
                ent:SetNW2Bool('Spindashused',false)

                -- Set the CD
                local cdamount = ent.formTable.Outcomememories_stats.abilities.DropDash.Cooldown()
                ent:SetNW2Float("Spindash_Cooldown", CurTime()+ cdamount )
                ent:SetNW2Float("Spindash_Cooldown_duration", cdamount )

                if ply.loco then
                    ply.loco:SetVelocity(vector_origin)
                    ply.loco:SetDesiredSpeed(0)
                end

                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_WALK)
                else
                    ply:SetMoveType(0)
                    if SERVER then
                        ent.TeleportEnt = nil
                    end
                end

                AdvancedPillSound(
                   {
                        stringe = "OM/sonic/stun.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
               )

                timer.Simple(0.1,function()
                    if !IsValid(ply) then return end
                    ply:SetPos(ply.SonicOldPos)
                    if ply:IsPlayer() then
                        if IsValid(ent2) then
                            ply:SetPos(ply:GetPos()+Vector(0,0,8))
                            local dir = ((ply:GetPos()+ply:GetForward()*-6) - (ply:GetPos()-Vector(0,0,1))):GetNormalized()
                            ply:SetVelocity(dir * 550)
                            ply:SetLocalVelocity(dir * 550)
                        end            
                    end
                end)

                if Wintype == "Win" then
                    local ringgain = GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_ringgain"):GetFloat()
                    if ent:GetNW2Float("Rings") < ent:GetNW2Float("MaxRings", 0) then 
                        if ent:GetNW2Float("Rings") + ringgain < ent:GetNW2Float("MaxRings", 0) then 
                            ent:SetNW2Float("Rings", ent:GetNW2Float('Rings') + ringgain)
                        else
                            ent:SetNW2Float("Rings", ent:GetNW2Float("MaxRings", 0))
                        end
                    else
                        ent:SetNW2Float("Rings", ent:GetNW2Float("MaxRings", 0))
                    end
                end
                return true
            end
        end
        initializetable2["player"]:SetNW2Bool("OM_character", true)
        local dur = CurTime()

        timer.Simple(0,function()
            if !IsValid(initializetable2["entity"]) then return end
            initializetable2["player"].OM_DamageBeforeCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                local ent = initializetable2["entity"]
                if !IsValid(initializetable2["entity"]) then return end
                if damageamount > 0 then else return end

                if entityfall == initializetable2["player"] then
                    if ( dmg:IsDamageType(DMG_BURN) or dmg:IsDamageType(DMG_BLAST) or dmg:IsDamageType(DMG_DROWN) or dmg:IsDamageType(DMG_SLOWBURN) or dmg:IsDamageType(DMG_RADIATION) ) then

                    else
                        if initializetable2["entity"]:GetNW2Float("Rings") > 0 then
                            local minim = initializetable2["entity"]:GetNW2Float("Rings")-dmg:GetDamage()
                            if minim < 0 then minim = 0 end
                            initializetable2["entity"]:SetNW2Float('Rings', minim)
                            dmg:SetDamage(0)
                            dmg:SetDamageType(DMG_GENERIC)
                                
                            if SERVER then
                                ent:SetNW2Float("DodgeAnim", CurTime()+0.5)
                                ent:SetNW2Float("DodgeAnim_id", math.random(1,4))
                                ent:GetPuppet():SetNW2Float("sonicdodge_afterimage_duration", CurTime()+0.05)
                            end
                        end
                    end
                end
            end
        end)
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            hook.Remove("EntityTakeDamage", "ringspending".. initializetable2["player"]:EntIndex())
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetNW2Float("OM_NoMovement_noodles", CurTime())
            initializetable2["player"]:SetNW2Float("OM_NoMovement_noodles_jump", CurTime())
        end

        initializetable2["entity"]:StopSound("OM/sonic/PeelOutChargeUp.wav")
        initializetable2["entity"]:StopSound("OM/sonic/PeelOutStart.wav")
        initializetable2["entity"]:StopSound("OM/sonic/peeloutstop.wav")
        initializetable2["entity"]:StopSound("OM/sonic/dropdash_final.wav")
        initializetable2["entity"]:StopSound("OM/sonic/DropdashDrill.wav")
        initializetable2["entity"]:StopSound("OM/sonic/dropdashrelease.wav")

        initializetable2["entity"]:StopSound("OM/sonic/Dashing_end.wav")
        initializetable2["entity"]:StopSound("OM/sonic/Dashing_loop.wav")
        initializetable2["entity"]:StopSound("OM/sonic/Dashing_start.wav")

        initializetable2["entity"]:StopSound("OM/sonic/peeloutrelease2.wav")

        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")
        initializetable2["entity"]:StopSound("OM/sonic/looping3.wav")

        initializetable2["entity"].GotTheStun = false
    end,


    speedhandeler_om = {
        modifiers = {
            ["PeelOut"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("PeelOut_duration") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.Peelout() - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Peelout() - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.Peelout() - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                end

                return sendtotable
            end,
            ['DropDash'] = function(ply, ent)

                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("PeelOut_duration") < CurTime() and ent:GetNW2Float("Spindash_Duration") > CurTime() then
                    sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.Dropdash() - ent.formTable.Outcomememories_stats.moveSpeed.walk() *0.7
                    sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Dropdash() - ent.formTable.Outcomememories_stats.moveSpeed.run() *0.7
                    sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.Dropdash() - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *0.7
                    --sendtotable["Jump"] = ( ent.formTable.Outcomememories_stats.moveSpeed.jumppower(ply,ent) - 1) * -1
                end

                return sendtotable
            end,
        }
    },

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            local Dashing_loop = false
            OM_PILL_speedThink(ply, ent)

            if not GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
            end
            if not GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
            end

            ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_Sonic_Resistance"):GetFloat()/100)

            local hasthestun = false

            -- frames determined

            if ent:GetNW2Float('Spindash_Duration') > CurTime() or ent:GetNW2Float('spindash_fake') > CurTime() then
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe3", CurTime()+0.1) 
                ply:SetNW2Float("OM_Damage_Reduction",0)
                hasthestun = true
            else
                ply:SetNW2Float("OM_Damage_Reduction",1)
            end

            -- peel out charge code
            if ent:GetNW2Float("PeelOut_duration_anim") - 2 > CurTime() then
            else
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    Dashing_loop = true
                end
            end


            if ent:GetNW2Float("PeelOut_duration_anim") - 0.5 > CurTime() then

                if not ent.PeelOut_duration2_early_bool then ent.PeelOut_duration2_early_bool = true end
            else
                if ent.PeelOut_duration2_early_bool then
                    ent.PeelOut_duration2_early_bool = false
                    ent:SetNW2Float("PeelOut_allow_duration",CurTime() + 0.6 )
                end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                    Dashing_loop = true
                end
            end

            if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                if not ent.PeelOut_duration2_bool then 

                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/PeelOutChargeUp.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ent:SetNW2Entity("PeelOutGrabEntity_om",NULL)

                    ent.PeelOut_duration2_bool = true 
                end
                        ent:SetNW2Bool("PeelOut_saidoutahere", false)
            else
                if ent.PeelOut_duration2_bool then
                    ent.PeelOut_duration2_bool = false
                    ent:SetNW2Float("PeelOut_allow_duration",CurTime() + 0.6 )
                    ent:SetNW2Entity("PeelOutGrabEntity_om",NULL)
                    ent.PeelOutGrabEntity_om_oldone = NULL

                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/PeelOutStart.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    if SERVER then
                        if not ent.trailPeel then
                            
                            local offset = Vector(0, 0, 20)
                            local trailOrigin = ents.Create("info_target")
                            trailOrigin:SetPos(ent:GetPos() + offset)
                            trailOrigin:SetParent(ent)
                            trailOrigin:Spawn()

                            local trail = util.SpriteTrail(
                                trailOrigin,
                                0,
                                Color(255, 255, 255),
                                true,
                                16,
                                1,
                                0.75,
                                0.2,
                                "models/noodles/om/sonicball/blue2.vmt"
                            )

                            ent.trailPeel = trail
                            ent:DeleteOnRemove(trail)
                            trail:DeleteOnRemove(trailOrigin)

                            local trailFoot1 = util.SpriteTrail(
                                ent:GetPuppet(),
                                2,
                                Color(255, 255, 255),
                                true,
                                6,
                                1,
                                0.75,
                                0.2,
                                "models/noodles/om/sonicball/Sonicred.vmt"
                            )
                            trailOrigin:DeleteOnRemove(trailFoot1)

                            local trailFoot2 = util.SpriteTrail(
                                ent:GetPuppet(),
                                3,
                                Color(255, 255, 255),
                                true,
                                6,
                                1,
                                0.75,
                                0.2,
                                "models/noodles/om/sonicball/Sonicred.vmt"
                            )
                            trailOrigin:DeleteOnRemove(trailFoot2)
                            
                        end
                    end
                    --ent:SetNW2Float("ShouldntJumpPeelOut",CurTime()+0.07)
                    ent:SetNW2Float("PeelOut_duration",CurTime()+ math.Clamp(GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_duration"):GetFloat(), 0.1, 1e9) )

                end
            end

            -- peel out code

            if ent:GetNW2Float("PeelOut_duration") > CurTime() then



                if not ent:GetNW2Bool("PeelOut_saidoutahere") then
                    local amount = 0
                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 700)) do
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                            if ent2 == ply then continue end
                            if ent2 == ent:GetNW2Entity("DrGBasePossessor") then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                            if (not ent2:GetNW2Bool("OM_character") or GetConVar("PVPStun_OM"):GetBool()) then
                                amount = amount + 1
                                ent:SetNW2Bool("PeelOut_readytosay", true)
                            end
                        end
                    end
                    if amount == 0 and ent:GetNW2Bool("PeelOut_readytosay") then
                        ent:SetNW2Bool("PeelOut_saidoutahere", true)
                        AdvancedPillSound(
                            {
                                stringe = "OM/sonic/sonicimouttahere.wav",
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end
                else

                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 600)) do
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                            if ent2 == ply then continue end
                            if ent2 == ent:GetNW2Entity("DrGBasePossessor") then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                            if (not ent2:GetNW2Bool("OM_character") or GetConVar("PVPStun_OM"):GetBool()) then
                                ent:SetNW2Bool("PeelOut_saidoutahere", false)
                                ent:SetNW2Bool("PeelOut_readytosay", false)
                            end
                        end
                    end
                end


                ent:SetNW2Bool('peeledout', true)

                ply:SetNW2Float("OM_MoveForward", CurTime()+0.1)
                ply:SetNW2Float("OM_MoveForwardSpeed", 1e9)

                ply:SetNW2Float("OM_lowerFriction_not", CurTime()+0.1)
                ply:SetNW2Float("OM_character_shouldnotgrab2", CurTime()+0.1)

                ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)

                Dashing_loop = true

                if IsValid(ent:GetNW2Entity("PeelOutGrabEntity_om")) then
                    local peel = ent:GetNW2Entity("PeelOutGrabEntity_om")

                    local startPos   = ply:GetPos() + Vector(0, 0, 30)
                    local desiredPos = startPos + ply:GetForward() * -50

                    local pMins, pMaxs = peel:OBBMins(), peel:OBBMaxs()
                    pMins = pMins - Vector(2, 2, 2)
                    pMaxs = pMaxs + Vector(2, 2, 2)

                    local tr = util.TraceHull({
                        start  = startPos,
                        endpos = desiredPos,
                        mins   = pMins,
                        maxs   = pMaxs,
                        filter = { ply, ent, peel },
                        mask   = MASK_SOLID
                    })

                    local safePos
                    if tr.Hit then
                        safePos = tr.HitPos + tr.HitNormal * 2
                    else
                        safePos = desiredPos
                    end

                    local plyMins, plyMaxs = ply:OBBMins(), ply:OBBMaxs()
                    local plyRadius = math.max(
                        math.abs(plyMins.x), math.abs(plyMins.y),
                        math.abs(plyMaxs.x), math.abs(plyMaxs.y)
                    )

                    local peelRadius = math.max(
                        math.abs(pMins.x), math.abs(pMins.y),
                        math.abs(pMaxs.x), math.abs(pMaxs.y)
                    )

                    local minDist = plyRadius + peelRadius + 4
                    local dir = safePos - ply:GetPos()
                    local dist = dir:Length()

                    if dist < minDist then
                        dir:Normalize()
                        safePos = ply:GetPos() + dir * minDist
                    end

                    if util.IsInWorld(safePos) then
                        peel:SetPos(safePos)
                    end

                    ent:GetNW2Entity("PeelOutGrabEntity_om"):SetNW2Float("OM_character_shouldnotgrab2", CurTime()+0.1)
                end

                local jumpscare_entity = nil

                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 100)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end

                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if ent2 == ent.PeelOutGrabEntity_om_oldone then continue end

                        if ent2:GetNW2Bool("OM_character") and not ent2:GetNW2Bool("OM_character_shouldnotgrab") and ent2:GetNW2Float("OM_character_shouldnotgrab2") < CurTime() and ent2:GetNW2Float("OM_character_Sonic_pickup_debounce") < CurTime() then
                            ent.PeelOutGrabEntity_om_oldone = ent:GetNW2Entity("PeelOutGrabEntity_om")

                            ent:SetNW2Entity("PeelOutGrabEntity_om",ent2)
                            ent2:SetNW2Entity("PeeloutEntity_OM_Sonic",ent)

                            AdvancedPillSound(
                                {
                                    stringe = "OM/sonic/peeloutpickup.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )

                            if ent2:GetNW2Bool("Survivor_Downed_OM") then
                                if ent2.ReviveFunction_OM then
                                    ent2:ReviveFunction_OM()
                                end
                            end
                        end
                    end
                end
            else
                if ent:GetNW2Bool('peeledout') then
                    ent:SetNW2Bool('peeledout', false)
                    ply:SetNW2Float("OM_NoMovement_noodles_jump", 0.5 + CurTime())

                    -- Set the CD
                    local cdamount = 0
                    if IsValid( ent:GetNW2Entity("PeelOutGrabEntity_om") ) then
                        cdamount = ent.formTable.Outcomememories_stats.abilities.PeelOut.CooldownSucess()
                    else
                        cdamount = ent.formTable.Outcomememories_stats.abilities.PeelOut.CooldownFail()
                    end

                    ent:SetNW2Float("PeelOut_Cooldown", CurTime()+ cdamount )
                    ent:SetNW2Float("PeelOut_Cooldown_duration",cdamount )


                    ent:PillAnim("Braking")

                    ent:StopSound("OM/sonic/Dashing_loop.wav")
                    --[[
                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/Dashing_end.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ]]
                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/sonicbrake.wav",
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end

                if ent.trailPeel then
                    ent.trailPeel:Remove()
                    ent.trailPeel = nil
                end

                if IsValid(ent.TeleportEnt) then
                    ply:SetPos(ent.TeleportEnt:GetPos()+Vector(0,0,50))
                end
            end

            -- dropdash code

            if ent:GetNW2Float("spindash_fake") > CurTime() then
                if IsValid(ent:GetNW2Entity("GlowingBallThingy_OM")) then
                    ent:GetNW2Entity("GlowingBallThingy_OM"):SetNW2Float('sonic_glow_duration',CurTime()+0.3)
                end
            end

            if ent:GetNW2Float("Spindash_Duration") > CurTime() then
                Dashing_loop = true
                ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                if not ent:GetNW2Bool("SpinDashToggle") then
                    ent:SetNW2Bool("SpinDashToggle", true)
                end
                --[[
                local ed = EffectData()
                ed:SetOrigin(ply:GetPos() + Vector(0,0,20))
                util.Effect("sonic_sparkle_OM", ed)
                ]]

                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe3", CurTime()+0.05)
                
                if ply:IsPlayer() then
                    if ent:GetNW2Float("PeelOut_duration") < CurTime() then
                        ply:SetNW2Float("OM_MoveForwardSpeed", ent.formTable.Outcomememories_stats.moveSpeed.Dropdash()*1)
                        if GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_slippery"):GetBool() then
                            ply:SetNW2Float("OM_MoveForward_WithSideways2",CurTime()+0.2)
                        else
                            ply:SetNW2Float("OM_MoveForward", CurTime() + 0.2)
                        end
                    end
                end

                local jumpscare_entity = nil
                for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 95)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                        if (not ent2:GetNW2Bool("OM_character") or GetConVar("PVPStun_OM"):GetBool()) then
                            if ent:GetNW2Float('CooldownHit_OM_sonic',0) < CurTime() then
                                if ent:GetNW2Float("DropDash_Diving") < CurTime() and ent:GetNW2Float("DropDash_Diving_alt") < CurTime() then
                                    ent.formTable.Outcomememories_stats.abilities.DropDash.StunEffect(ply, ent, ent2)
                                end
                            end
                        end
                    end
                end
            else
                if ent:GetNW2Bool("SpinDashToggle") then

                    --[[
                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/Dashing_end.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    ]]
                    ent:StopSound("OM/sonic/Dashing_loop.wav")

                    ent:SetNW2Bool("SpinDashToggle", false)

                    -- Set the CD
                    local cdamount = 0
                    if ent:GetNW2Float("PeelOut_Cooldown") > CurTime() then
                        cdamount = ent:GetNW2Float("PeelOut_Cooldown")-CurTime() + ent.formTable.Outcomememories_stats.abilities.DropDash.AddToPeelout()
                    else
                        cdamount = ent.formTable.Outcomememories_stats.abilities.DropDash.AddToPeelout()
                    end
                    ent:SetNW2Float("PeelOut_Cooldown", CurTime()+ cdamount )
                    ent:SetNW2Float("PeelOut_Cooldown_duration", cdamount )

                end
                if ent:GetNW2Bool('Spindashused') then
                    if ent:GetNW2Float("spindash_fake") < CurTime() then
                        -- Set the CD
                        local cdamount = ent.formTable.Outcomememories_stats.abilities.DropDash.Cooldown()
                        ent:SetNW2Float("Spindash_Cooldown", CurTime()+ cdamount )
                        ent:SetNW2Float("Spindash_Cooldown_duration", cdamount )

                    end
                    ent:SetNW2Bool('Spindashused',false)
                end
            end

            if hasthestun then
                ply.GotTheStun = true
            else
                ply.GotTheStun = false
            end

            if Dashing_loop then
                ent.Dashing_loop_soundloop = ent.Dashing_loop_soundloop or 0
                if ent.Dashing_loop_soundloop < CurTime() then
                    ent.Dashing_loop_soundloop = CurTime() + 2
                    AdvancedPillSound(
                        {
                            stringe = "OM/sonic/looping3.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            else
                ent:StopSound("OM/sonic/looping3.wav")
                ent:StopSound("OM/sonic/looping3.wav")
            end
        else
            local v = ent

            if v:GetNW2Float("PeelOut_duration") > CurTime() then

                local puppet = v:GetPuppet()
                if not v.pealoutEffectcd then
                    v.pealoutEffectcd = 0
                end
                if not v.pealoutEffectcd2 then
                    v.pealoutEffectcd2 = 0
                end

                if v.pealoutEffectcd < CurTime() then
                    v.pealoutEffectcd = CurTime()

                    if v.pealoutEffectcd2 < CurTime() then
                        v.pealoutEffectcd2 = CurTime() + 0.1

                        local ed = EffectData()
                        ed:SetOrigin(puppet:GetPos()+Vector(0,0,35))
                        ed:SetNormal(puppet:GetForward())
                        util.Effect("sonic_peelout_moons", ed)
                    end


                    for i=1,16 do
                    
                        local offset = Vector(
                            math.Rand(-0,0),
                            math.Rand(-0,0),
                            math.Rand(-0,0)
                        )
                        
                        local Emitter = ParticleEmitter(v:GetPos() +Vector(0,0,27) + offset + puppet:GetForward() * -10, false)

                        local particlePos = v:GetPos() +Vector(0,0,27) + offset + puppet:GetForward() * 10

                        local smoke = Emitter:Add("particle/particle_smokegrenade", particlePos)

                        if smoke then
                            smoke:SetVelocity(Vector(math.Rand(-300,300),math.Rand(-300,300),math.Rand(-400,400))*1.45)
                            smoke:SetLifeTime(0)
                            smoke:SetDieTime(math.Rand(0.05,0.6))
                            smoke:SetColor(135,185,255)
                            smoke:SetStartAlpha(255)
                            smoke:SetEndAlpha(0)

                            local size = math.Rand(20,25)
                            smoke:SetStartSize(size)
                            smoke:SetEndSize(size * 0)

                            smoke:SetRoll(math.Rand(-180,180))
                            smoke:SetRollDelta(math.Rand(-0.2,0.2))

                            smoke:SetAirResistance(255)
                            smoke:SetGravity(Vector(0,0,math.Rand(0,0)))
                            smoke:SetCollide(false)
                            smoke:SetLighting(false)
                        end

                        local glow = Emitter:Add("sprites/light_glow02_add", particlePos)

                        if glow then
                            glow:SetVelocity(Vector(math.Rand(-300,300),math.Rand(-300,300),math.Rand(-400,400))*1.25)
                            glow:SetLifeTime(0)
                            glow:SetDieTime(math.Rand(0.05,0.6))
                            glow:SetColor(125,125,175)
                            glow:SetStartAlpha(100)
                            glow:SetEndAlpha(0)

                            local glowSize = math.Rand(45,55)
                            glow:SetStartSize(glowSize)
                            glow:SetEndSize(glowSize * 0)

                            glow:SetRoll(math.Rand(-180,180))
                            glow:SetRollDelta(math.Rand(-0.2,0.2))

                            glow:SetAirResistance(200)
                            glow:SetGravity(Vector(0,0,0))
                            glow:SetCollide(false)
                            glow:SetLighting(false)
                        end
                        Emitter:Finish()
                    end
                end
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if SERVER then

            if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() or IsValid(ply:GetNWEntity("OM_ragdollentity")) then
                return
            end
            if button == ply:GetInfoNum("om_pills_action_Sonic_peelout_key", KEY_T) then
                if not GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_useable"):GetBool() then return end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_duration") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_duration2") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_Cooldown") > CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles_jump") > CurTime() then return end
                if ent.PeelOut_duration2_early_bool then return end
                if ent.PeelOut_duration2_bool then return end
                if ent:GetNW2Bool('peeledout') then return end

                if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return end

                local dur = math.Clamp(GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration"):GetFloat(),0.1, 1e9)

                ply:SetNW2Float("OM_NoMovement_noodles_jump", dur + CurTime())
                ent:SetNW2Float("PeelOut_duration_anim",CurTime() + dur )
                ent:SetNW2Float("PeelOut_duration2",CurTime()+ GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_duration"):GetFloat() + dur )

                ent:GetPuppet():SetNW2Float('sonic_glow_duration_white',CurTime()+0.5*0.4)
            end
            --[[ 
            if button == KEY_1 then
                game.SetTimeScale(0.4)
            end
            if button == KEY_2 then
                game.SetTimeScale(1)
            end
            ]]
            if button == KEY_3 then
            end

            if button == ply:GetInfoNum("om_pills_action_Sonic_dropdash_key", KEY_E) then
                if not GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_useable"):GetBool() then return end

                if ent:GetNW2Float("Spindash_Duration_C") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_allow_duration") < CurTime() or not GetConVar("OUTCOMEMORIES_N_Sonic_DropdashPeelout_useable"):GetBool()  then 
                    if ent:GetNW2Float("PeelOut_duration") > CurTime() then return end
                end
                if ent:GetNW2Float("Spindash_Duration") > CurTime() then return end
                if ent:GetNW2Float("Spindash_Cooldown") > CurTime() then return end
                if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
                if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return end
                if ent.PeelOut_duration2_early_bool then return end
                if ent.PeelOut_duration2_bool then return end

                if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return end


                if ent:GetNW2Float("PeelOut_duration") > CurTime() then
                    if GetConVar("OUTCOMEMORIES_N_Sonic_DropdashPeelout_useable"):GetBool() then 
                        ent:SetNW2Float('Spindash_Duration',ent:GetNW2Float("PeelOut_duration"))
                        ent:SetNW2Float('Spindash_Duration_C',ent:GetNW2Float("PeelOut_duration")+0.5)
                    else
                        return
                    end
                else
                    ent:SetNW2Float('Spindash_Duration',CurTime()+GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_duration"):GetFloat()  )
                    ent:SetNW2Float('Spindash_Duration_C',CurTime()+GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_duration"):GetFloat()+1 )
                end

                ent:SetNW2Bool('Spindashused',true)
                local origninallyonground = false
                local curlup = false
                local jumpdurationeti = CurTime()+3
                if ply:IsOnGround() or ent:GetNW2Float("JumpDuration") < CurTime() then
                    if not ply:IsOnGround() and ent:GetNW2Float("JumpDuration") < CurTime() then
                        curlup = true
                    end

                    if ply:IsPlayer() then
                    else
                        if ply:IsOnGround() then
                            ply:SetPos(ply:GetPos()+Vector(0,0,30))
                        end
                    end

                    origninallyonground = true
                    if ply:IsOnGround() then
                        ply:SetPos(ply:GetPos()+ Vector(0,0,5))
                        ply:SetVelocity(Vector(0,0,270))
                    end
                end

                AdvancedPillSound(
                    {
                        stringe = "OM/sonic/PeelOutChargeUp.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                ent:SetNW2Float('IgnoreBall_OM_moduledraw',CurTime()+1)
                ent:GetPuppet():SetNW2Float('IgnoreBall_OM_moduledraw',CurTime()+1)
                ent:GetPuppet():SetNW2Float('sonic_glow_duration_white',CurTime()+0.5*0.35)
                ent:GetPuppet():SetNW2Float("sonic_ability_outline", CurTime()+0.5*0.35)

                local winduptime = CurTime()+0.65
                local fadeeiie = false

                if SERVER then
                    local ballsonic = ents.Create("ent_om_hedgehog_dropballs")
                    ballsonic:SetPos(ply:GetPos())
                    ballsonic:SetAngles(ply:GetAngles())
                    ballsonic:SetModelScale(1.25)
                    ballsonic:Spawn()
                    ballsonic:SetPillUser(ply)
                    ballsonic:SetPillUser2(ent:GetPuppet())
                    ent:DeleteOnRemove(ballsonic)
                    ballsonic:SetColor(Color(0, 0, 0, 0))
                    ballsonic:SetRenderMode(RENDERMODE_TRANSALPHA)
                    ent:SetNW2Entity("GlowingBallThingy_OM",ballsonic)
                    ent:GetPuppet():SetNW2Entity("GlowingBallThingy_OM",ballsonic)

                    local uniqueID = "OM_SonicModelBall_" .. ballsonic:EntIndex()
                    local oldcolor = ent:GetPuppet():GetColor()

                    local startTime = CurTime()
                    local fadeDuration = 0.2

                    local spindashl = false

                    local puppetColor = Color(255,255,255,255)
                    local ballColor = Color(255,255,255,255)

                    local fadeTime = 0.3
                    local startTime = CurTime()

                    local fadeout = false
                    local onground = false
                    local notset = false

                    --uniqueIDuniqueID
                    hook.Add("Think", uniqueID, function()
                        if not IsValid(ballsonic) or not IsValid(ballsonic) then
                            hook.Remove("Think", uniqueID)
                            return
                        end

                        if ent:GetNW2Float('Spindash_Duration') < CurTime() and ent:GetNW2Float('spindash_fake') < CurTime() then


                            if not fadeout then
                                fadeout = true
                                startTime = CurTime()
                                puppetColor = ent:GetPuppet():GetColor()
                                ballColor = ballsonic:GetColor()
                                ballsonic:SetParent(nil)
                            end


                            local frac = math.Clamp((CurTime() - startTime) / fadeTime, 0, 1)

                            ent:GetPuppet():SetColor(Color(
                                puppetColor.r,
                                puppetColor.g,
                                puppetColor.b,
                                Lerp(frac, 0, 255)
                            ))


                            ballsonic:SetColor(Color(
                                ballColor.r,
                                ballColor.g,
                                ballColor.b,
                                Lerp(frac, 255, 0)
                            ))

                            if frac >= 1 then
                                hook.Remove("Think", uniqueID)
                                if IsValid(ballsonic) then
                                    ballsonic:Remove()
                                end
                            end
                            return
                        end


                        local elapsed = CurTime() - startTime
                        local ballAlpha = 0
                        if (ply:IsOnGround() or onground and not origninallyonground) or (origninallyonground and winduptime < CurTime()) or (curlup and winduptime < CurTime()) or (not origninallyonground and jumpdurationeti < CurTime()) then
                            onground = true
                            local fadeFrac = math.Clamp(elapsed / fadeDuration, 0, 1)
                            local puppetAlpha = 255 * (1 - fadeFrac)
                            ballAlpha = 255 * fadeFrac

                            ent:GetPuppet():SetRenderMode(RENDERMODE_TRANSALPHA)
                            ent:GetPuppet():SetColor(Color(255, 255, 255, puppetAlpha))

                            ballsonic:SetColor(Color(255, 255, 255, 255))


                            if not notset then
                                notset = true
                            end

                        else
                            if not onground then
                                startTime = CurTime()
                                ent:SetNW2Float("DropDash_Diving", CurTime()+1)
                                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+1)
                            end
                            if not origninallyonground then
                                ent:SetNW2Float("DropDash_Diving_alt", CurTime()+1)
                                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+1)
                            end
                            if curlup then
                                ent:SetNW2Float("DropDash_Diving_alt", CurTime()+1)
                                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+1)
                            end
                        end

                        if ballAlpha < 250 then
                            ent:SetNW2Float('Spindash_Duration',CurTime()+GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_duration"):GetFloat()  )
                            ent:SetNW2Float('Spindash_Duration_C',CurTime()+GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_duration"):GetFloat()+1 )
                        end

                        local mult
                        if elapsed >= 0.7 then
                            mult = 3
                        else
                            mult = 1 + (elapsed / 0.7) * 2
                        end

                        local ang = Angle(0, 0, CurTime() * 360 * mult)
                        ballsonic:ManipulateBoneAngles(0, ang)

                        if ballAlpha > 0 and not fadeeiie then
                            fadeeiie = true
                                
                            ent:SetNW2Float('IgnoreBall_OM_moduledraw',CurTime()+0.25)
                            ent:GetPuppet():SetNW2Float('IgnoreBall_OM_moduledraw',CurTime()+0.25)
                            ent:GetPuppet():SetNW2Float('sonic_glow_duration_blueSlow',CurTime()+0.25)
                            ent:GetPuppet():SetNW2Float("sonic_ability_outline", CurTime()+0.25)
                            ent:GetNW2Entity("GlowingBallThingy_OM"):SetNW2Float('sonic_glow_duration_blueSlow',CurTime()+0.25)
                            ent:GetNW2Entity("GlowingBallThingy_OM"):SetNW2Float("sonic_ability_outline", CurTime()+0.25)
                            if SERVER then
                                local trail_3ndlayer = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255,0,255),
                                    true,
                                    40,
                                    0,
                                    0.5,
                                    0.5,
                                    "models/noodles/om/sonicball/blue.vmt"
                                )

                                ent.trail_3ndlayer = trail_3ndlayer
                                ent:DeleteOnRemove(trail_3ndlayer)
                                ballsonic:DeleteOnRemove(trail_3ndlayer)

                                local trail = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255, 255, 255),
                                    true,
                                    70,
                                    40,
                                    0.75,
                                    0.02,
                                    "models/noodles/om/sonicball/blue_2ndlayer.vmt"
                                )


                                ent.trail = trail
                                ent:DeleteOnRemove(trail)
                                ballsonic:DeleteOnRemove(trail)


                                local trail_2ndlayer = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255, 255, 255),
                                    true,
                                    40,
                                    0,
                                    0.5,
                                    0.5,
                                    "models/noodles/om/sonicball/blue.vmt"
                                )

                                ent.trail_2ndlayer = trail_2ndlayer
                                ent:DeleteOnRemove(trail_2ndlayer)
                                ballsonic:DeleteOnRemove(trail_2ndlayer)
                            end
                        end
                        
                        if ballAlpha > 254 and not spindashl then
                            spindashl = true
                            ent:SetNW2Float("DropDash_Diving", 0)
                            ent:SetNW2Float("DropDash_Diving_alt", 0)
                        end

                    end)
                end


                ent:SetNW2Float('Hit_OM_sonic',0)
            end
        end
    end,
    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
        end
    },


    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
        end,
    },

    reload=function(ply,ent)
    end,
    flashlight = function(ply, ent)
    end,
        
    jump = function(ply, ent)
        if ply:GetNW2Bool("Survivor_Downed_OM") then return end
        if SERVER then
            if ent:GetNW2Float("Spindash_Duration") > CurTime() or ent:GetNW2Float("spindash_fake") > CurTime() then 
            else
                ent:SetNW2Float('JumpDuration',CurTime()+1)
                ent.AlternatePlaySolution = true
                ent:PillAnim('Jump2')
                ent.AlternatePlaySolution = false

                AdvancedPillSound(
                    {
                        stringe = "OM/Jump.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end
        end
    end
})