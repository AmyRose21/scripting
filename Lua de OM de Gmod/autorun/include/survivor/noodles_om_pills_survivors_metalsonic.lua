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
    ["Metal_OM_noodles_heal"] = Material("icons/Metal_OM_noodles_heal.png"),
    ["Metal_OM_noodles_charge"] = Material("icons/Metal_OM_noodles_charge.png"),
}

pk_pills.register('pill_om_MetalSonic', {

    printName='Metal Sonic',
    Outcomememories='MetalSonic',
    Outcomememories_material="Metal",
        
    model="models/Noodles/OM/metal.mdl",
    --[[
    hull = Vector(20,20,60),
    duckBy = 14,
    ]]
    
    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',


    ShouldRoll_om = function(e, ply, ent)
        if ent:GetNW2Float("ChargingDuration") > CurTime() then return false end
        return true
    end,

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Metal_OM_noodles_charge"]
            end,
            name = function(uselessvar,ply,ent)
                return "Destructive Charge"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_MetalSonic_Charge_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Charge_cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Charge_cooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.04, yaxis = 0 + iconsize* 0.05, xsize = 0 - iconsize* 0.01, ysize = 0 - iconsize * 0.01}
            end,
            survivor = true,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["Metal_OM_noodles_heal"]
            end,
            name = function(uselessvar,ply,ent)
                return "Self repair"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_MetalSonic_Heal_key", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("heal_cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("heal_cooldown_duration")
            end,
            survivor = true,
            font = "CreditsText",
        }
    },

    Outcomememories_stats = {
        moveSpeed = {
            ['walk'] = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_MetalSonic_walk"):GetFloat()
                end
            end,
            ['run'] = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_MetalSonic_run"):GetFloat()
                end
            end,
            ['ducked'] = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_MetalSonic_walk"):GetFloat()
                end
            end,
            ["Charging"] = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_MetalSonic_Charging"):GetFloat()
                end
            end,
            ['jumppower'] = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_MetalSonic_jumppower"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_MetalSonic_jumpcd"):GetFloat()
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_MetalSonic_rollingPower"):GetFloat()
                end
            end,
        },
        abilities = {
            ['Charge'] = {
                ["ActivationKey"] = KEY_E,
                ["cooldown"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_cooldownSucess"):GetFloat()
                    end
                end,
            },
            ["selfheal"] = {
                ["ActivationKey"] = KEY_T,
                ["cooldown"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMORIES_N_MetalSonic_heal_cooldownSucess"):GetFloat()
                    end
                end,
            },
        },
    },

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            glide="fall",
            ChargeUp = 'ChargeUp',
            Jump2 = "jump",
            IdleToHeal = "IdleToHeal",
            HealToIldle = "HealToIldle",
            Slam1 = "Slam1",
            Slam2 = "Slam2",
        },

        ShouldMoveRotate={
            idle= function(ent) 
                local ply = ent:GetPillUser()
                    if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return "assignedagnles" end
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                if ent:GetNW2Float("ChargingDuration") > CurTime() then return "shiftlock" end
                return 'notanything' 
            end,
            run= function(ent) 
                local ply = ent:GetPillUser()
                    if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return "assignedagnles" end
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                if ent:GetNW2Float("ChargingDuration") > CurTime() then return "shiftlock" end
                return 'notshftlock'
            end,
            walk= function(ent) 
                local ply = ent:GetPillUser()
                    if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return "assignedagnles" end
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                if ent:GetNW2Float("ChargingDuration") > CurTime() then return "shiftlock" end
                return 'notshftlock'
            end,
            jump= function(ent) 
                local ply = ent:GetPillUser()
                    if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return "assignedagnles" end
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                if ent:GetNW2Float("ChargingDuration") > CurTime() then return "shiftlock" end
                return 'notshftlock'
            end,
            fall= function(ent) 
                local ply = ent:GetPillUser()
                    if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return "assignedagnles" end
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                if ent:GetNW2Float("ChargingDuration") > CurTime() then return "shiftlock" end
                return 'notshftlock'
            end,
            Charge= function(ent) 
                local ply = ent:GetPillUser()
                    if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return "assignedagnles" end
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                return "shiftlock"
            end,
            jump= function(ent) 
                local ply = ent:GetPillUser()
                    if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return "assignedagnles" end
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                return 'notshftlock'
            end,
        },

        ShouldAlternate={
            idle= function(ent) 
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool('Healing_OM_Noodles') then return 'heal' end
                if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then return "charge" end
            end,
            walk= function(ent) 
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool('Healing_OM_Noodles') then return 'heal' end
                if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then return "charge" end
            end,
            run= function(ent) 
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool('Healing_OM_Noodles') then return 'heal' end
                if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then return "charge" end
            end,
            fall= function(ent) 
                if ent:GetNW2Float("OM_healidle") > CurTime() then return "heal" end
                if ent:GetNW2Float("RollEndTime_om") > CurTime() then return "roll" end
                if ent:GetNW2Bool('Healing_OM_Noodles') then return 'heal' end
                if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then return "charge" end
            end,

        },
    },


    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            if (ent:GetNW2Float("ChargingDuration") > CurTime() and ply:GetInfoNum("om_pills_metal_custombar", 1) == 1) or (ent:GetNW2Bool("Healing_OM_Noodles") and ply:GetInfoNum("om_pills_metal_custombar_heal", 1) == 1) then
                return true
            end
        end,
        colorbar = function(uselessvar,ply,ent)
            if ent:GetNW2Bool("Healing_OM_Noodles") then
                return Color(0,255,0,255)
            end
            return Color(0, 0, 175, 255)
        end,
        progression = function(uselessvar,ply,ent)
            if ent:GetNW2Bool("Healing_OM_Noodles") then

                return Lerp(ent:GetNW2Float('TotalHeals')/70,0,7)

            end
            local factor = math.Clamp( ((CurTime()-(ent:GetNW2Float("ChargingDuration")))*-1)/8, 0, 1)
            local lerp = Lerp(factor,0,100)
            return lerp
        end,
        maximumbar = function(uselessvar,ply,ent)
            if ent:GetNW2Bool("Healing_OM_Noodles") then
                return 7
            end
            return 100
        end,
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


        if ply:GetNW2Bool("Survivor_Downed_OM") then
            basetable =  {
                startoffset = Vector(45,0,25),  -- left-up, front-back, up-down
                dist=50,
                fov = ply:GetInfoNum("om_pills_default_fov", 80)*0.85,
                id = 67,
                transition = 1,
                canscroll = false,
            }
        end


        ent.sonic_fov_lerp = ent.sonic_fov_lerp or 0 

        if ply:GetInfoNum("om_pills_action_camera_Sonic", 1) == 1 then
            if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) and ply:GetVelocity():Length() > 300 or ent:GetVelocity():Length() > 300 then
                ent.sonic_fov_lerp = Lerp(FrameTime()*1, ent.sonic_fov_lerp, 1)
            else
                ent.sonic_fov_lerp = Lerp(FrameTime()*3, ent.sonic_fov_lerp, 0)
            end
        else
            ent.sonic_fov_lerp = Lerp(FrameTime()*3, ent.sonic_fov_lerp, 0)
        end

        basetable["fov"] = basetable["fov"] + ent.sonic_fov_lerp * 40
        basetable["dist"] = basetable["dist"] - ent.sonic_fov_lerp * 40

        
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
            if ent:GetPuppet():GetSequenceName(ent:GetPuppet():GetSequence()) == "walk" then
                AdvancedPillSound({
                    stringe = {"OM/metal/Step1.wav","OM/metal/Step2.wav","OM/metal/Step3.wav","OM/metal/Step4.wav","OM/metal/Step5.wav","OM/metal/Step6.wav"},
                    soundLevel = 90
                }, ent)
            elseif ent:GetPuppet():GetSequenceName(ent:GetPuppet():GetSequence()) == "run" then
                AdvancedPillSound({
                    stringe = {"OM/metal/RunStep1.wav","OM/metal/RunStep2.wav","OM/metal/RunStep3.wav","OM/metal/RunStep4.wav","OM/metal/RunStep5.wav","OM/metal/RunStep6.wav","OM/metal/RunStep7.wav","OM/metal/RunStep8.wav"},
                    soundLevel = 90
                }, ent)
            end

        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_survivor_om(initializetable2["entity"])
        if SERVER then
            
            initializetable2["entity"]:SetNW2Float("OM_Damage_Reduction",1)
            local health = GetConVar("OUTCOMEMEMORIES_N_MetalSonic_Health"):GetFloat()
            initializetable2["player"]:SetHealth(health)
            initializetable2["player"]:SetMaxHealth(health)
            initializetable2["player"]:GodDisable()
            initializetable2["entity"]:SetNW2Float("MaxHealth",health)
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",health)

            initializetable2["entity"]:SetNW2Float("OM_friction",0.15)
            initializetable2["player"]:SetNW2Bool("SecondLife_OM", false)
            initializetable2["player"]:SetNW2Bool("OnSecondLife_OM", false)
            initializetable2["player"]:SetNW2Bool("MetalBeing_OM", true)

            initializetable2["entity"].CanClashOpponents_OM = true
        end
        initializetable2["player"].ColorRGB_B_1_OM = Color(0,0,175, 255)
        
        local oldpos = Vector(0,0,0)
        local ent22 = ent2
        initializetable2["player"].OMInitiateClash_lnz = function(v, ent2)
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
                    ply:SetPos(ent2:GetPos()+angl:Forward()*-70+ent2:GetUp()*26)
                end
                if character == "Sonic" then
                    ply:SetPos(ent2:GetPos()+angl:Forward()*-70+ent2:GetUp()*0)
                end


                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_NONE)
                else
                    ply:SetMoveType(2)
                    if ply.loco then
                        ply.loco:SetVelocity(vector_origin)
                        ply.loco:SetDesiredSpeed(0)
                    end
                end
            end
        end

        initializetable2["player"].CustomFunctionCancelAbility_OM = function()
            if IsValid(initializetable2["entity"]) then
                local ent = initializetable2["entity"]
                ent:SetNW2Bool('Healing_OM_Noodles', false)
                ent:SetNW2Float("ChargingDuration", 0) 
                ent:SetNW2Entity("Metal_chargingEnemy", NULL)
                ent:SetNW2Float("TotalDamageTaken_Charge_OM", 0)
            end
        end

        initializetable2["player"].OM_Stun_Blockfunction = function()
            if IsValid(initializetable2["entity"]) then
                local ent = initializetable2["entity"]
                ent:SetNW2Bool('Healing_OM_Noodles', false)
                ent:SetNW2Float("ChargingDuration", 0) 
                ent:SetNW2Entity("Metal_chargingEnemy", NULL)
                ent:SetNW2Float("TotalDamageTaken_Charge_OM", 0)
            end
        end

        initializetable2["player"].OM_ShouldClash = function()
            if IsValid(initializetable2["entity"]) then
                if initializetable2["entity"]:GetNW2Float("ChargingDuration") > CurTime() then return true end
            end
            return false
        end

        initializetable2["player"].OMCompelteClash_lnz = function(Wintype)
            if !IsValid(initializetable2["entity"]) then return end

            local ply = initializetable2["player"]
            local ent = initializetable2["entity"]

            ply:SetPos(oldpos)

            if ply.loco then
                ply.loco:SetVelocity(vector_origin)
                ply.loco:SetDesiredSpeed(0)
            end
            if ply:IsPlayer() then
                ply:SetMoveType(MOVETYPE_WALK)
            else
                ply:SetMoveType(0)
                ent.TeleportEnt = nil
            end
            ent:SetNW2Float("Charge_cooldown", CurTime()+20)
            ent:SetNW2Float("Charge_cooldown_duration", 20)
            if Wintype == "Loss" then
                ent:SetNW2Float("ChargingDuration", 0) 
                ent:SetNW2Entity("Metal_chargingEnemy", NULL)
                ent:SetNW2Float("TotalDamageTaken_Charge_OM", 0)
                --ent:SetNW2Float("Charge_cooldown", CurTime()+10) 
            elseif Wintype == "Win" then
                local ent2 = ent22
                            if IsValid(ent2) then
                                
                                Mutaul_OMStunCode(
                                    {
                                        ["ply"] = ply,
                                        ["ent"] = ent,
                                        ["target"] = ent2,
                                        ["StunDur"] = GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_tic"):GetFloat()*2,
                                        ["stunfunction"] = function(shouldstundamage)
                                            if shouldstundamage then

                                                AdvancedPillSound(
                                                    {
                                                        stringe = "OM/metal/Eletricsound.wav",
                                                        pitchPercent = 100,
                                                        volume = 1,
                                                        soundLevel = 87
                                                    },
                                                    ent
                                                )

                                                local effectdata = EffectData()
                                                effectdata:SetOrigin(ply:GetPos()+Vector(0,0,30)+ply:GetForward()*20)
                                                effectdata:SetNormal(ply:GetForward()*-30)
                                                util.Effect("StunstickImpact", effectdata)
                                                local effectdata = EffectData()
                                                effectdata:SetOrigin(ply:GetPos()+Vector(0,0,30)+ply:GetForward()*20)
                                                effectdata:SetNormal(ply:GetForward()*-30)
                                                util.Effect("StunstickImpact", effectdata)
                                                local effectdata = EffectData()
                                                effectdata:SetOrigin(ply:GetPos()+Vector(0,0,30)+ply:GetForward()*20)
                                                effectdata:SetNormal(ply:GetForward()*-30)
                                                util.Effect("StunstickImpact", effectdata)

                                                ent:SetNW2Entity("Metal_chargingEnemy",ent2)
                                                ent:SetNW2Float("DamageCooldown", CurTime() + 1)
                                                ent:SetNW2Float("ChargingDuration", 0)
                                                ent2:SetVelocity(Vector(0,0,0))

                                                ent2:SetNW2Float("AbilityDisabled_OM", CurTime()+0.125)
                                            end
                                        end,
                                        ["shouldstack"] = true,
                                        ["Damage"] = GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_DamageTick"):GetFloat(),
                                        ["checkoutprevention"] = true,
                                        ["DamageType"] = DMG_CLUB
                                    }
                                )
                            end
            end
        end


        initializetable2["player"]:SetNW2Bool("NoHealing_OM_Noodles", true)
        initializetable2["player"]:SetNW2Bool("OM_character", true)
        initializetable2["player"]:SetNW2Bool("OM_character_shouldnotgrab", true)
        initializetable2["player"]:SetNW2Float("OM_Damage_Reduction",0.5)

        local function exploding(victim)
            if SERVER then
                                                    local ply = initializetable2["player"]
                                                    local ent = initializetable2["entity"]

                                                    if IsValid(ply) and ply:IsPlayer() then
                                                        if not ent.PlayedSound_selfdestruct then
                                                            ent.PlayedSound_selfdestruct = true
                                                            net.Start("MetalSonic_deathsound")
                                                            net.Send(ply)
                                                        end
                                                    end

                local pos = victim:GetPos()

                local explosion = ents.Create("env_explosion")
                if IsValid(explosion) then
                    explosion:SetPos(pos)
                    explosion:SetOwner(victim)
                    explosion:Spawn()
                    explosion:SetKeyValue("iMagnitude", "0")
                    explosion:Fire("Explode", 0, 0)
                end

                AdvancedPillSound(
                    {
                        stringe = "OM/metal/ExplodeSfx.wav",
                        pitchPercent = 100,
                        volume = 2,
                        soundLevel = 87
                    },
                    initializetable2["entity"]
                )      

                AdvancedPillSound(
                    {
                        stringe = "OM/metal/Explosion.wav",
                        pitchPercent = 100,
                        volume = 2,
                        soundLevel = 87
                    },
                    initializetable2["entity"]
                )      
                AdvancedPillSound(
                    {
                        stringe = "OM/metal/MetalBloodSound.wav",
                        pitchPercent = 100,
                        volume = 2,
                        soundLevel = 87
                    },
                    initializetable2["entity"]
                )      

                if (IsValid(initializetable2["entity"]:GetNW2Entity("Metal_chargingEnemy")) and initializetable2["entity"]:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then
                    if IsValid(initializetable2["player"]) then
                        Mutaul_OMStunCode(
                            {
                                ["ply"] = initializetable2["player"],
                                ["ent"] = initializetable2["entity"],
                                ["target"] = initializetable2["entity"]:GetNW2Entity("Metal_chargingEnemy"),
                                ["StunDur"] = 7,
                                ["stunfunction"] = function(shouldstundamage)
                                end,
                                ["shouldstack"] = true,
                                ["Damage"] = 50,
                                ["DamageType"] = DMG_CLUB
                            }
                        )

                            local ent2 = initializetable2["entity"]:GetNW2Entity("Metal_chargingEnemy")
                                                    local last = CurTime() + 1.25
                                                    local flung = false
                                                    local enemyragdoll = CreateRagdolLCharacter_OM({
                                                        target = ent2,
                                                        host = initializetable2["entity"],

                                                        shouldremove = function(createfakeragdoll)
                                                            if not IsValid(createfakeragdoll) then return true end
                                                            if not IsValid(ent2) then return true end

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
                                                            if not IsValid(ent2) then return end
                                                            if flung then return end
                                                            flung = true

                                                            local ragPos = createfakeragdoll:GetPos()

                                                            local dir = (ragPos - pos):GetNormalized()
                                                            local force = dir * 800 + Vector(0, 0, 50)

                                                            local phys = createfakeragdoll:GetPhysicsObject()
                                                            if IsValid(phys) then
                                                                phys:SetVelocity(force)
                                                                phys:AddAngleVelocity(VectorRand() * 1600)
                                                            end

                                                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                                local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                                if IsValid(bonePhys) then
                                                                    bonePhys:SetVelocity(force)
                                                                    bonePhys:AddAngleVelocity(VectorRand() * 1600)
                                                                end
                                                            end
                                                        end
                                                    })

                    else
                        Mutaul_OMStunCode(
                            {
                                ["ply"] = initializetable2["entity"],
                                ["ent"] = initializetable2["entity"],
                                ["target"] = initializetable2["entity"]:GetNW2Entity("Metal_chargingEnemy"),
                                ["StunDur"] = 7,
                                ["CallForClashing"] = true,
                                ["stunfunction"] = function(shouldstundamage)
                                    if shouldstundamage then
                                        local ent2 = initializetable2["entity"]:GetNW2Entity("Metal_chargingEnemy")
                                                    local last = CurTime() + 1.25
                                                    local flung = false
                                                    local enemyragdoll = CreateRagdolLCharacter_OM({
                                                        target = ent2,
                                                        host = initializetable2["entity"],

                                                        shouldremove = function(createfakeragdoll)
                                                            if not IsValid(createfakeragdoll) then return true end
                                                            if not IsValid(ent2) then return true end

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
                                                            if not IsValid(ent2) then return end
                                                            if flung then return end
                                                            flung = true

                                                            local ragPos = createfakeragdoll:GetPos()

                                                            local dir = (ragPos - pos):GetNormalized()
                                                            local force = dir * 800 + Vector(0, 0, 50)

                                                            local phys = createfakeragdoll:GetPhysicsObject()
                                                            if IsValid(phys) then
                                                                phys:SetVelocity(force)
                                                                phys:AddAngleVelocity(VectorRand() * 1600)
                                                            end

                                                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                                local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                                if IsValid(bonePhys) then
                                                                    bonePhys:SetVelocity(force)
                                                                    bonePhys:AddAngleVelocity(VectorRand() * 1600)
                                                                end
                                                            end
                                                        end
                                                    })

                                    end
                                end,
                                ["shouldstack"] = true,
                                ["Damage"] = 50,
                                ["DamageType"] = DMG_CLUB
                            }
                        )
                    end
                end
                for _, ent2 in pairs(ents.FindInSphere(pos, 230)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        if ent2 == initializetable2["player"] then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        
                        if Mutual_OMCanStun(initializetable2["player"], initializetable2["entity"], ent2, false) then
                            if ( ent2:GetNW2Bool("OM_character") and not GetConVar('PVPStun_OM'):GetBool() ) then continue end
                            Mutaul_OMStunCode(
                                {
                                    ["ply"] = initializetable2["player"],
                                    ["ent"] = initializetable2["entity"],
                                    ["target"] = ent2,
                                    ["StunDur"] = 7,
                                    ["CallForClashing"] = true,
                                    ["stunfunction"] = function(shouldstundamage)
                                        if shouldstundamage then


                                                    local last = CurTime() + 1.25
                                                    local flung = false
                                                    local enemyragdoll = CreateRagdolLCharacter_OM({
                                                        target = ent2,
                                                        host = initializetable2["entity"],

                                                        shouldremove = function(createfakeragdoll)
                                                            if not IsValid(createfakeragdoll) then return true end
                                                            if not IsValid(ent2) then return true end

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
                                                            if not IsValid(ent2) then return end
                                                            if flung then return end
                                                            flung = true

                                                            local ragPos = createfakeragdoll:GetPos()

                                                            local dir = (ragPos - pos):GetNormalized()
                                                            local force = dir * 800 + Vector(0, 0, 50)

                                                            local phys = createfakeragdoll:GetPhysicsObject()
                                                            if IsValid(phys) then
                                                                phys:SetVelocity(force)
                                                                phys:AddAngleVelocity(VectorRand() * 1600)
                                                            end

                                                            for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                                local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                                if IsValid(bonePhys) then
                                                                    bonePhys:SetVelocity(force)
                                                                    bonePhys:AddAngleVelocity(VectorRand() * 1600)
                                                                end
                                                            end
                                                        end
                                                    })

                                        end
                                    end,
                                    ["shouldstack"] = true,
                                    ["Damage"] = 0,
                                    ["checkoutprevention"] = true,
                                    ["DamageType"] = DMG_CLUB
                                }
                            )
                        end
                    end
                end

            end
        end

        local hookname = "OM_Metals_explode".. initializetable2["player"]:EntIndex()
        if initializetable2["player"]:IsPlayer() then
            hook.Add("PlayerDeath", hookname, function(victim, inflictor, attacker)
                if IsValid(victim) and victim == initializetable2["player"] then
                    exploding(victim)
                end
            end)
        else
            hook.Add("OnNPCKilled", hookname, function(npc, attacker, inflictor)
                if IsValid(npc) and npc == initializetable2["player"] then
                    exploding(npc)
                end
            end)
        end
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        if IsValid(initializetable2["player"]) then
            initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
            initializetable2["player"]:SetNW2Float("OM_NoMovement_noodles", CurTime())
            initializetable2["player"]:SetNW2Bool("OM_character_shouldnotgrab", false)
            initializetable2["player"]:SetNW2Float("OM_Damage_Reduction",1)

            local hookname = "OM_Metals_explode".. initializetable2["player"]:EntIndex()
            if initializetable2["player"]:IsPlayer() then
                hook.Remove("PlayerDeath", hookname)
            else
                hook.Remove("OnNPCKilled", hookname)
            end
            initializetable2["player"]:SetNW2Bool("MetalBeing_OM", false)
        end

        if SERVER then
            initializetable2["entity"]:StopSound("OM/metal/metalChargeLoopSound.wav")
        end

        hook.Remove("EntityTakeDamage", "OM_Metal_healing_".. initializetable2["entity"]:EntIndex())
        hook.Remove("EntityTakeDamage", "OM_Metal_charging_".. initializetable2["entity"]:EntIndex())
    end,

    speedhandeler_om = {
        modifiers = {
            ["Charging"] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }

                if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then

                    if GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_slippery"):GetBool() and not (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then
                        sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.Charging() - ent.formTable.Outcomememories_stats.moveSpeed.walk() *1
                        sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Charging() - ent.formTable.Outcomememories_stats.moveSpeed.run() *1
                        sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.Charging() - ent.formTable.Outcomememories_stats.moveSpeed.ducked() *1
                    else
                        local factor = 0.525
                        sendtotable["Walk"] = ent.formTable.Outcomememories_stats.moveSpeed.Charging() *factor - ent.formTable.Outcomememories_stats.moveSpeed.walk()
                        sendtotable["Run"] = ent.formTable.Outcomememories_stats.moveSpeed.Charging() *factor - ent.formTable.Outcomememories_stats.moveSpeed.run()
                        sendtotable["Crouch"] = ent.formTable.Outcomememories_stats.moveSpeed.Charging() *factor - ent.formTable.Outcomememories_stats.moveSpeed.ducked()
                    end
                end

                return sendtotable
            end,
            ['JumpHandeler'] = function(ply, ent)
                local sendtotable = {
                    ["Walk"] = 0,
                    ["Run"] = 0,
                    ["Crouch"] = 0,
                    ['Jump'] = 0,
                }
                if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() or ent:GetNW2Bool('Healing_OM_Noodles') then
                    sendtotable["Jump"] = ( ent.formTable.Outcomememories_stats.moveSpeed.jumppower(ply,ent) - 1) * -1
                else
                    if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then
                        sendtotable["Jump"] = ( ent.formTable.Outcomememories_stats.moveSpeed.jumppower(ply,ent) - 1) * -1
                    else
                    end
                end
                return sendtotable
            end,
        }
    },

    think_noodles_om_pill = function(ply, ent)
        if not SERVER then return end

        OM_PILL_speedThink(ply, ent)

        if GetConVar("OUTCOMEMORIES_N_MetalSonic_radar"):GetBool() then
            ent:SetNWBool("ShouldntShowAbility0_OM", true)
        else
            ent:SetNWBool("ShouldntShowAbility0_OM", false)
        end

        if not GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_useable"):GetBool() then
            ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
        else
            ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
        end
        if not GetConVar("OUTCOMEMORIES_N_MetalSonic_heal_useable"):GetBool() then
            ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
        else
            ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
        end

        ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_MetalSonic_Resistance"):GetFloat()/100)

        if ply:GetNW2Bool("clashingminigame_om_isinminigame") then
            if ent:GetNW2Float("ChargingDuration") > CurTime() then
                ent:SetNW2Float("ChargingDuration", CurTime()+0.4)
            end
        end

        if IsValid(ent) then
            if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() or ent:GetNW2Bool('Healing_OM_Noodles') then
                ply:SetNW2Float("OM_Damage_Reduction",1)
            else
                if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then
                    ply:SetNW2Float("OM_Damage_Reduction",0)

                    ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe3", CurTime()+0.05) 
                    ent:SetNW2Float("ShouldntGetBoost_OM", CurTime()+0.2) 
                    ply:SetNW2Float("ShouldntGetBoost_OM", CurTime()+0.2) 
                else
                    ply:SetNW2Float("OM_Damage_Reduction",0.5)
                end
            end

            if ent:GetNW2Bool('Healing_OM_Noodles') then
                if SERVER then
                    if ent:GetNW2Float('healingCooldown_OM') < CurTime() then
                        if not ent:GetNW2Bool('healingatm') then
                            ent:SetNW2Bool('healingatm', true)
                        end

                        if ply:Health() > 150 or ent:GetNW2Float('TotalHeals') > 70 then
                            ent:SetNW2Bool('Healing_OM_Noodles', false)
                        else 
                            ent:GetPuppet():SetNW2Float("MetalSonicHeal_highlight", CurTime()+0.5*0.5)
                            ent:GetPuppet():SetNW2Float("metalsonic_ability_outline", CurTime()+0.5*0.5)

                            ent:SetNW2Float('healingCooldown_OM', CurTime()+ 2)
                            ply:SetNW2Float("OM_NoMovement_noodles", 6.7 + CurTime())

                            ent:SetNW2Float('TotalHeals', ent:GetNW2Float('TotalHeals') + 7)
                            if not ent:GetNW2Bool("SelfDestruct_metal_om") then
                                ply:SetHealth(ply:Health()+GetConVar("OUTCOMEMORIES_N_MetalSonic_heal_healamount"):GetFloat())
                            end
                            AdvancedPillSound(
                                {
                                    stringe = "OM/metal/Heal.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                        end

                        if ply:Health() > 150 or ent:GetNW2Float('TotalHeals') > 70 then
                            ent:SetNW2Bool('Healing_OM_Noodles', false)
                            ply:SetNW2Float("OM_NoMovement_noodles", 0)
                        end
                    end
                end

            else                    
                if ent:GetNW2Bool('healingatm') then
                    hook.Remove("EntityTakeDamage", "OM_Metal_healing_".. ent:EntIndex())
                    ent:SetNW2Float("heal_cooldown", CurTime()+ent.formTable.Outcomememories_stats.abilities.selfheal.cooldown())
                    ent:SetNW2Float("heal_cooldown_duration", ent.formTable.Outcomememories_stats.abilities.selfheal.cooldown())
                    ent:SetNW2Bool('healingatm', false)
                    AdvancedPillSound(
                        {
                            stringe = "OM/metal/healfinished.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    if ent:GetNW2Float('TotalHeals') > 7 then
                        if ent.PillAnim then
                            ent.AlternatePlaySolution = true
                            ent:PillAnim('HealToIldle')
                            ent.AlternatePlaySolution = false
                        end
                        ply:SetNW2Float("OM_NoMovement_noodles", 0.5 + CurTime())
                    end
                end
            end

            if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then
                ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                if ply:IsPlayer() then
                    if SERVER then
                        ply:SetNW2Float("OM_MoveForwardSpeed", ent.formTable.Outcomememories_stats.moveSpeed.Charging())
                        if GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_slippery"):GetBool() and not (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then
                            ply:SetNW2Float("OM_MoveForward_WithSideways",CurTime()+0.2)
                        else
                            ply:SetNW2Float("OM_MoveForward", CurTime() + 0.2)
                        end
                    end
                end
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe3", CurTime()+0.05)
                
                local ef = EffectData()
                ef:SetOrigin(ply:GetPos()+Vector(0,0,30))
                ef:SetNormal(ply:GetForward() * -40)
                util.Effect("metalsonic_sparkle_OM", ef)

                if ent:GetNW2Float("Cooldown_effect_1") < CurTime() then
                    local ef = EffectData()
                    ef:SetOrigin(ply:GetPos()+Vector(0,0,30)+ply:GetForward()*8)
                    ef:SetNormal(ply:GetForward() * -40)
                    util.Effect("metalsonic_middlespark_OM", ef)
                    ent:SetNW2Float("Cooldown_effect_1", CurTime()+0.02)
                else

                end
                
                ent:SetNW2Bool('playingSound', true)

                local startPos = ply:GetPos() + Vector(0,0,35)
                local endPos = startPos + ply:GetForward() * 45

                if !IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) then
                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 100)) do
                        if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                            local shouldstunstack = GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_stunstack"):GetBool()
                            if Mutual_OMCanStun(ply, ent, ent2, shouldstunstack) then
                                if SERVER and GetConVar('PVPStun_OM_clashing'):GetBool() then
                                    if ent2.OM_ShouldClash then
                                        local variable = ent2.OM_ShouldClash()
                                        if variable then
                                            OM_Minigame(ply, ent2)
                                            ent:SetNW2Entity("Metal_chargingEnemy",ent2)
                                            ent:SetNW2Float("ChargingDuration", 0)
                                            break
                                        end
                                    end
                                end
                                Mutaul_OMStunCode(
                                    {
                                        ["ply"] = ply,
                                        ["ent"] = ent,
                                        ["target"] = ent2,
                                        ["CallForClashing"] = true,
                                        ["StunDur"] = GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_tic"):GetFloat()*2,
                                        ["stunfunction"] = function(shouldstundamage)
                                            if shouldstundamage then

                                                AdvancedPillSound(
                                                    {
                                                        stringe = "OM/metal/Eletricsound.wav",
                                                        pitchPercent = 100,
                                                        volume = 1,
                                                        soundLevel = 87
                                                    },
                                                    ent
                                                )

                                                local effectdata = EffectData()
                                                effectdata:SetOrigin(ply:GetPos()+Vector(0,0,30)+ply:GetForward()*20)
                                                effectdata:SetNormal(ply:GetForward()*-30)
                                                util.Effect("StunstickImpact", effectdata)
                                                local effectdata = EffectData()
                                                effectdata:SetOrigin(ply:GetPos()+Vector(0,0,30)+ply:GetForward()*20)
                                                effectdata:SetNormal(ply:GetForward()*-30)
                                                util.Effect("StunstickImpact", effectdata)
                                                local effectdata = EffectData()
                                                effectdata:SetOrigin(ply:GetPos()+Vector(0,0,30)+ply:GetForward()*20)
                                                effectdata:SetNormal(ply:GetForward()*-30)
                                                util.Effect("StunstickImpact", effectdata)

                                                ent:SetNW2Entity("Metal_chargingEnemy",ent2)
                                                ent:SetNW2Float("DamageCooldown", CurTime() + 1)
                                                ent:SetNW2Float("ChargingDuration", 0)
                                                ent2:SetVelocity(Vector(0,0,0))

                                                ent2:SetNW2Float("AbilityDisabled_OM", CurTime()+0.125)
                                            end
                                        end,
                                        ["shouldstack"] = true,
                                        ["Damage"] = GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_DamageTick"):GetFloat(),
                                        ["checkoutprevention"] = true,
                                        ["DamageType"] = DMG_CLUB
                                    }
                                )
                            end

                        end
                    end
                else

                    if not ply:GetNW2Bool("clashingminigame_om_isinminigame") then
                        if IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) then
                            if ent:GetNW2Entity("Metal_chargingEnemy"):Health() <= 0 then
                                ent:SetNW2Float("TotalDamageTaken_Charge_OM", 0)
                                ply:SetNW2Float("OM_NoMovement_noodles", 0.5 + CurTime())
                                ent:GetNW2Entity("Metal_chargingEnemy"):SetNWFloat("OM_cannotuseabailities", CurTime()+1)
                                ent:SetNW2Entity("Metal_chargingEnemy", NULL)
                            end
                        end
                        if ent:GetNW2Float("Cooldown_effect_3") < CurTime() and not ent:GetNWBool("SelfDestruct_metal_om") then
                            if SERVER then
                                --[[
                                local effectdata = EffectData()
                                effectdata:SetOrigin(ply:GetPos()+Vector(0,0,40))
                                effectdata:SetNormal(ply:GetForward()*30)
                                util.Effect("StunstickImpact", effectdata)
                                ]]
                                ent:SetNW2Float("Cooldown_effect_3", CurTime()+0.02)
                            end
                        end

                        local ent2 = ent:GetNW2Entity("Metal_chargingEnemy")
                        if IsValid(ent2) then
                            ent2:SetNWFloat("OM_cannotuseabailities", CurTime()+1)
                        end
                        if ent:GetNW2Float("DamageCooldown") < CurTime() then
                            ent:GetPuppet():SetNW2Float("MetalSonicinvert_highlight", CurTime()+0.2)
                            if IsValid(ent2) then
                                Mutaul_OMStunCode(
                                    {
                                        ["ply"] = ply,
                                        ["ent"] = ent,
                                        ["target"] = ent2,
                                        ["StunDur"] = GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_tic"):GetFloat(),
                                        ["stunfunction"] = function(shouldstundamage)
                                            if SERVER then
                                                local damage = GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_MetalSelfDamageTick"):GetFloat()

                                                if ply:Health() - damage >0.1 then
                                                    if not ent:GetNWBool("SelfDestruct_metal_om") then
                                                        ply:TakeDamage(damage)
                                                        AdvancedPillSound(
                                                            { stringe = "OM/sonic/stun.wav", pitchPercent = 100, volume = 1, soundLevel = 87 },
                                                            ent
                                                        )
                                                        ent2:SetVelocity(Vector(0,0,0))

                                                        local ed = EffectData()
                                                        ed:SetOrigin(ent2:GetPos()+Vector(0,0,40)+ply:GetForward()*20)
                                                        util.Effect("Metal_ChargeImpact", ed)
                                                        local ed = EffectData()
                                                        ed:SetOrigin(ent2:GetPos()+Vector(0,0,20))
                                                        ed:SetEntity(ent2)
                                                        util.Effect("Metal_eletricity", ed)
                                                    end
                                                else

                                                    if IsValid(ply) and ply:IsPlayer() then
                                                        if not ent.PlayedSound_selfdestruct then
                                                            ent.PlayedSound_selfdestruct = true
                                                            net.Start("MetalSonic_deathsound")
                                                            net.Send(ply)

                                                            ent:SetNW2Float("TotalDamageTaken_Charge_OM", 0)
                                                        end
                                                    end
                                                    
                                                    ent:SetNWBool("SelfDestruct_metal_om", true)
                                                    ply:SetHealth(10)
                                                end
                                                ent:SetNW2Float("TotalDamageTaken_Charge_OM", ent:GetNW2Float("TotalDamageTaken_Charge_OM")+4)
                                                ent:SetNW2Float("DamageCooldown", CurTime() + 0.25)
                                            end
                                        end,
                                        ["shouldstack"] = true,
                                        ["Damage"] = GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_DamageTick"):GetFloat(),
                                        ["checkoutprevention"] = true,
                                        ["DamageType"] = DMG_CLUB
                                    }
                                )
                                
                            end
                        end

                        local mins, maxs = Vector(-1,-1,-1),Vector(1,1,1)
                        if IsValid(ent2) then
                            mins = ent2:OBBMins()
                            maxs = ent2:OBBMaxs()
                        end
                        local lengthY = math.abs(maxs.y - mins.y)*3
                        endPos = startPos + ply:GetForward() * 65 + (ply:GetForward() * lengthY)
                    end
                end

                if not ply:GetNW2Bool("clashingminigame_om_isinminigame") then
                    local shouldsetpos = true
                    local hullSize = Vector(16, 16, 34)

                    local tr = util.TraceHull({
                        start = startPos,
                        endpos = endPos,
                        filter = ply,
                        mask = MASK_SOLID,
                        mins = -hullSize * 0.5,
                        maxs = hullSize * 0.5
                    })

                    local function latching()

                        local stairCheck = util.TraceLine({
                            start = tr.HitPos + tr.HitNormal * 4 + Vector(0, 0, 72),
                            endpos = tr.HitPos + tr.HitNormal * 4,
                            filter = ply,
                            mask = MASK_SOLID_BRUSHONLY
                        })

                        if stairCheck.Hit and stairCheck.HitNormal.z > 0.7 then
                            return
                        end

                        local groundTrace = util.TraceLine({
                            start = tr.HitPos + tr.HitNormal * 2,
                            endpos = tr.HitPos + tr.HitNormal * 2 - Vector(0, 0, 256),
                            filter = ply,
                            mask = MASK_SOLID_BRUSHONLY
                        })

                        local distance = tr.HitPos.z - groundTrace.HitPos.z

                        if distance >= 25 then
                            local normal = tr.HitNormal
                            if math.abs(normal.z) < 0.5 then
                                ent:SetNW2Float("ChargingDuration", 0)

                                if ent:GetNWBool("SelfDestruct_metal_om") then
                                    ply:TakeDamage(1e9)
                                else
                                    if IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) then

                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/metal/WallSlam.wav",
                                                pitchPercent = 100,
                                                volume = 2,
                                                soundLevel = 87
                                            },
                                            ent
                                        )    
                                        local ed = EffectData()
                                        ed:SetOrigin(tr.HitPos)
                                        ed:SetNormal(tr.HitNormal)
                                        ed:SetScale(1)
                                        util.Effect("Metal_Charge_SMASHWALL", ed)   

                                        local ent2 = ent:GetNW2Entity("Metal_chargingEnemy")
                                        local function StunFunction()
                                            ent:GetPuppet():SetNW2Float("MetalSonicinvert_highlight", CurTime()+0.2)
                                            Mutaul_OMStunCode(
                                                {
                                                    ["ply"] = ply,
                                                    ["ent"] = ent,
                                                    ["target"] = ent2,
                                                    ["StunDur"] = GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_slam"):GetFloat()*0.33,
                                                    ["stunfunction"] = function(shouldstundamage)
                                                        if shouldstundamage then
                                                            if SERVER then
                                                                ply:TakeDamage(GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_MetalSelfDamageSlam"):GetFloat()*0.33)
                                                            end
                                                            ent2:SetVelocity(Vector(0,0,0))
                                                            local ed = EffectData()
                                                            ed:SetOrigin(ply:GetPos()+Vector(0,0,30))
                                                            util.Effect("Metal_PunchImpact", ed)
                                                            --[[

                                                            local ed = EffectData()
                                                            ed:SetOrigin(ent2:GetPos()+Vector(0,0,40))
                                                            ed:SetEntity(ent2)
                                                            util.Effect("Metal_eletricity", ed)
                                                            ]]

                                                        end
                                                    end,
                                                    ["shouldstack"] = true,
                                                    ["Damage"] = GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_slamDamage"):GetFloat()*0.33,
                                                    ["checkoutprevention"] = true,
                                                    ["DamageType"] = DMG_CLUB
                                                }
                                            )
                                        end
                                        local awayFromWall = tr.HitNormal
                                        awayFromWall:Normalize()
                                        local mins, maxs
                                        local pushDist
                                        if IsValid(ent2) then
                                            mins, maxs = ent2:OBBMins(), ent2:OBBMaxs()
                                            pushDist = math.max(maxs:Length(), mins:Length()) * 0.6
                                            ent2:SetPos(tr.HitPos + awayFromWall * pushDist + Vector(0, 0, 1))
                                        end

                                        ent:SetNW2Entity("Metal_chargingEnemy",NULL)
                                        ent:SetNW2Float("TotalDamageTaken_Charge_OM", 0)
                                        ply:SetNW2Float("OM_NoMovement_noodles", 0.7 + CurTime())

                                        ply:SetPos(tr.HitPos + awayFromWall * pushDist*2 + Vector(0, 0, 1))
                                        if ply:IsPlayer() then
                                            ply:SetMoveType(MOVETYPE_NONE)
                                        else
                                            ply.setteleportpos_metal = ply:GetPos()
                                        end

                                        ent:SetNW2Float("ShouldntGetBoost_OM", CurTime()+3.5) 
                                        ply:SetNW2Float("ShouldntGetBoost_OM", CurTime()+3.5) 
                                        local duration = 0.35
                                        ent:SetNW2Float("BeatDown_Metal_OM", CurTime()+duration*3) 

                                        local firstduration = 0.1667
                                        local secondduration = 0.4167
                                        local ThirdDuration = 0.7167
                                        local MathRandom = math.random(1,2)
                                        if ent.PillAnim then
                                            ent.AlternatePlaySolution = true
                                            ent:PillAnim('Slam'..MathRandom)
                                            ent.AlternatePlaySolution = false
                                        end

                                        if MathRandom == 2 then
                                            firstduration = 0.0667
                                            secondduration = 0.25
                                            ThirdDuration = 0.6
                                        end

                                        timer.Simple(firstduration,function()
                                            if !IsValid(ply) then return end
                                            if !IsValid(ent) then return end
                                            AdvancedPillSound(
                                                { stringe = "OM/sonic/stun.wav", pitchPercent = 100, volume = 1, soundLevel = 87 },
                                                ent
                                            )
                                            if ply:IsPlayer() then
                                                ply:ViewPunch(Angle(-2, -10, 0))
                                            end
                                            StunFunction()
                                        end)
                                        timer.Simple(secondduration,function()
                                            if !IsValid(ply) then return end
                                            if !IsValid(ent) then return end

                                            AdvancedPillSound(
                                                { stringe = "OM/sonic/stun.wav", pitchPercent = 100, volume = 1, soundLevel = 87 },
                                                ent
                                            )
                                            if ply:IsPlayer() then
                                                ply:ViewPunch(Angle(-2, -10, 0))
                                            end
                                            StunFunction()
                                        end)
                                        timer.Simple(ThirdDuration,function()
                                            if !IsValid(ply) then return end
                                            if !IsValid(ent) then return end


                                                        AdvancedPillSound(
                                                            { stringe = "OM/sonic/stun.wav", pitchPercent = 100, volume = 1, soundLevel = 87 },
                                                            ent
                                                        )
                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/knuckles/punchstun.wav",
                                                    pitchPercent = 100,
                                                    volume = 2,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )     
                                            
                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/metal/MetalChargeEnd.wav",
                                                pitchPercent = 100,
                                                volume = 1,
                                                soundLevel = 87
                                            },
                                            ent
                                        )     
                                            
                                        local ed = EffectData()
                                        ed:SetOrigin(tr.HitPos)
                                        ed:SetNormal(tr.HitNormal)
                                        ed:SetScale(1)
                                        util.Effect("Metal_Charge_SMASHWALL", ed)  
                                            StunFunction()
                                        end)

                                        timer.Simple(duration*2.85,function()
                                            if !IsValid(ply) then return end
                                            if !IsValid(ent) then return end
                                            ply:SetPos(ply:GetPos() + awayFromWall * pushDist*2)
                                            if ply:IsPlayer() then
                                                ply:SetMoveType(2)
                                            else
                                                ply:SetMoveType(MOVETYPE_NONE)
                                            end
                                            if ply:IsPlayer() then
                                                ply:SetPos(ply:GetPos()+Vector(0,0,10))
                                                local dir = (startPos - (endPos-Vector(0,0,10))):GetNormalized()
                                                ply:SetVelocity(dir * 300)
                                                ply:SetLocalVelocity(dir * 300)
                                            else
                                                ply:SetPos(ply:GetPos()+Vector(0,0,30))
                                                local dir = (startPos - (endPos-Vector(0,0,30))):GetNormalized()
                                                ply:SetVelocity(dir * 300)
                                                ply:SetLocalVelocity(dir * 300)
                                            end
                                        end)
                                        
                                        shouldsetpos = false
                                    else
                                        local startPos = ply:GetPos() + Vector(0,0,30)
                                        local endPos = startPos + ply:GetForward() * 30
                                        if ply:IsPlayer() then
                                            ply:SetPos(ply:GetPos()+Vector(0,0,10))
                                            local dir = (startPos - (endPos-Vector(0,0,10))):GetNormalized()
                                            ply:SetVelocity(dir * 200)
                                            ply:SetLocalVelocity(dir * 200)
                                        else
                                            ply:SetPos(ply:GetPos()+Vector(0,0,30))
                                            local dir = (startPos - (endPos-Vector(0,0,30))):GetNormalized()
                                            ply:SetVelocity(dir * 200)
                                            ply:SetLocalVelocity(dir * 200)
                                        end
                                        ply:SetNW2Float("OM_NoMovement_noodles", 1.4 + CurTime())
                                        ent:SetNW2Float("OM_healidle", 1 + CurTime())

                                        AdvancedPillSound(
                                            {
                                                stringe = "OM/metal/WallBump.wav",
                                                pitchPercent = 100,
                                                volume = 2,
                                                soundLevel = 87
                                            },
                                            ent
                                        )


                                    end
                                    ent:SetNW2Float("Charge_cooldown",CurTime()+ ent.formTable.Outcomememories_stats.abilities.Charge.cooldown())
                                    ent:SetNW2Float("Charge_cooldown_duration", ent.formTable.Outcomememories_stats.abilities.Charge.cooldown())
                                end
                            end
                        end
                    end
                    if tr.Hit then
                        local hitEnt = tr.Entity

                        if IsValid(hitEnt) then
                            if hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:IsNextBot() then
                            else
                                local phys = hitEnt:GetPhysicsObject()

                                if not IsValid(phys) or not phys:IsMoveable() then
                                    latching()
                                end
                            end
                        else
                            latching()
                        end
                    end
                    if shouldsetpos then
                        local ent2 = ent:GetNW2Entity("Metal_chargingEnemy")
                        if IsValid(ent2) then

                            local mins, maxs =ent2:OBBMins(),ent2:OBBMaxs()
                            local lengthY = math.abs(maxs.y - mins.y)*1.25
                            ent2:SetPos(ply:GetPos() + ply:GetForward()*65 + (ply:GetForward() * lengthY))
                            ent2:SetAngles(ply:GetAngles()+ Angle(0,180,0))
                            
                        end
                    end
                end

            else                
                if ent:GetNW2Bool('playingSound') then

                    
                    ent:SetNW2Bool('playingSound', false)
                    if SERVER then
                        ply:SetNW2Float("OM_lowerFriction", CurTime()-1)
                        ent:SetNW2Float("Charge_cooldown",CurTime()+ent.formTable.Outcomememories_stats.abilities.Charge.cooldown())
                        ent:SetNW2Float("Charge_cooldown_duration", ent.formTable.Outcomememories_stats.abilities.Charge.cooldown())
                        ent:StopSound("OM/metal/metalChargeLoopSound.wav")
                    end
                    AdvancedPillSound(
                        {
                            stringe = "OM/metal/MetalChargeEnd.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end

                if ent:GetNWBool("SelfDestruct_metal_om") then
                    ent:SetNW2Float("TotalDamageTaken_Charge_OM", 4)
                    ply:TakeDamage(1e9)
                else
                    if IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) then
                        ent:GetNW2Entity("Metal_chargingEnemy",NULL)
                    end
                end
            end

            if ent:GetNW2Float("OM_healidle") > CurTime() then
                if not ent.OM_healidle then
                    ent.OM_healidle = true
                    ent:GetPuppet():SetNW2Float("MetalSonicbump_highlight", CurTime()+0.5)
                    ent:GetPuppet():SetNW2Float("metalsonic_ability_outline", CurTime()+0.5)
                end
            else
                if ent.OM_healidle then
                    ent.OM_healidle = false
                    if ent.PillAnim then 
                        ent.AlternatePlaySolution = true
                        ent:PillAnim("HealToIldle") 
                        ent.AlternatePlaySolution = false
                    end
                end
            end

        else

            local v = ent:GetPuppet()
            local expire = v:GetNW2Float("MetalSonicHeal_highlight", 0)

            if expire >= CurTime() then
                local dlight = DynamicLight(v:EntIndex())

                if dlight then
                    dlight.pos = v:GetPos()
                    dlight.r = 0
                    dlight.g = 255
                    dlight.b = 0
                    dlight.brightness = 3
                    dlight.Decay = 1000
                    dlight.Size = 200
                    dlight.DieTime = CurTime() + FrameTime() * 2
                end
            end
        end
    end,

    noodles_OM_survivor_keybinds = function(ply,ent,button)
        if not SERVER then return end

        if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() or IsValid(ply:GetNWEntity("OM_ragdollentity")) then
            return
        end
        if button == ply:GetInfoNum("om_pills_action_MetalSonic_Heal_key", KEY_T) then
            if not GetConVar("OUTCOMEMORIES_N_MetalSonic_heal_useable"):GetBool() then return end
            if ent:GetNW2Float("heal_cooldown") > CurTime() then return end
            if ent:GetNW2Bool('Healing_OM_Noodles') then return end
            if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
            if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then return end

            if ply:Health() > 150 then return end
            ent:SetNW2Bool('Healing_OM_Noodles', true)
            ent:SetNW2Float('TotalHeals', 0)
            ent:SetNW2Float('healingCooldown_OM', CurTime())
            if ent.PillAnim then
                --ent:PillAnim('IdleToHeal')
            end

            local hookname ="OM_Metal_healing_".. ent:EntIndex()
            hook.Add("EntityTakeDamage", hookname, function(target, dmg)
                if target == ply then
                    local attacker = dmg:GetAttacker()

                    ent:SetNW2Bool('Healing_OM_Noodles', false)
                    ent:SetNW2Float('TotalHeals', 1e9)
                    ent:SetNW2Float('healingCooldown_OM', CurTime())
                    ent:SetNW2Bool('healingatm', true)

                    hook.Remove("EntityTakeDamage", hookname)
                end
            end)

            AdvancedPillSound(
                {
                    stringe = "OM/metal/Metal self repair activation (2).wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )
        end
        if button == ply:GetInfoNum("om_pills_action_MetalSonic_Charge_key", KEY_E) then
            if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return end
            if not GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_useable"):GetBool() then return end
            if ent:GetNW2Float("Charge_cooldown2") > CurTime() then return end
            if ent:GetNW2Float("ChargeUp_metal_om") > CurTime() then return end
            if ent:GetNW2Float("Charge_cooldown") > CurTime() then return end
            if ent:GetNW2Bool('Healing_OM_Noodles') then return end
            if ply:GetNW2Float("OM_NoMovement_noodles") > CurTime() then return end
            if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then return end
            
            local hookname ="OM_Metal_charging_".. ent:EntIndex()
            local shouldstop = false
            hook.Add("EntityTakeDamage", hookname, function(target, dmg)
                if target == ply then
                    local attacker = dmg:GetAttacker()
                    shouldstop = true
                    ent:SetNW2Float("Charge_cooldown",CurTime()+ent.formTable.Outcomememories_stats.abilities.Charge.cooldown())
                    ent:SetNW2Float("Charge_cooldown_duration", ent.formTable.Outcomememories_stats.abilities.Charge.cooldown())

                    ent:GetPuppet():SetNW2Float("MetalSonic_cancel", CurTime()+1)
                    ent:GetPuppet():SetNW2Float("metalsonic_ability_outline", CurTime()+1)

                    hook.Remove("EntityTakeDamage", hookname)
                end
            end)

            AdvancedPillSound(
                {
                    stringe = "OM/metal/metal_chargeup.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                ent
            )
            local function copyandpasted(time)
                timer.Simple(time,function()
                    if !IsValid(ent) then return end
                    if shouldstop then return end

                                local effectdata = EffectData()
                                effectdata:SetOrigin(ply:GetPos()+Vector(0,0,30))
                                effectdata:SetNormal(ply:GetForward()*-30)
                                util.Effect("StunstickImpact", effectdata)
                end)
            end

            ent:GetPuppet():SetNW2Float('metalsonic_ability_red_long',CurTime()+0.6)
            ent:GetPuppet():SetNW2Float("metalsonic_ability_outline", CurTime()+0.6)
            copyandpasted(0.3)
            copyandpasted(0.35)
            copyandpasted(0.45)
            copyandpasted(0.5)

            if SERVER then
                local ed = EffectData()
                ed:SetOrigin(ply:GetPos())
                ed:SetEntity(ply)
                util.Effect("metalsonic_chargeOm", ed)
                ent.AlternatePlaySolution = true
                ent:PillAnim('ChargeUp')
                ent.AlternatePlaySolution = false
            end
            local dur = ent:GetPuppet():SequenceDuration(ent:GetPuppet():LookupSequence("ChargeUp"))
            ply:SetNW2Float("OM_NoMovement_noodles", dur*0.9 + CurTime())
            ent:SetNW2Float("ChargeUp_metal_om", dur+1.1 + CurTime())

            timer.Simple(dur,function()
                if !IsValid(ent) then return end
                if shouldstop then return end
                hook.Remove("EntityTakeDamage", hookname)
                ent:SetNW2Float("ChargingDuration", CurTime()+ GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_Duration"):GetFloat())
                ent:SetNW2Float("Charge_cooldown2", CurTime()+ GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_Duration"):GetFloat()+1)
                ent:SetNW2Float("TotalDamageTaken_Charge_OM", 0)
                ent:SetNW2Entity("Metal_chargingEnemy", NULL)
                
                AdvancedPillSound(
                    {
                        stringe = "OM/metal/metalChargeLoopSound.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                if SERVER then
                    
                end


            end)
        end
        if button == KEY_R then
            
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
        if ent:GetNW2Float("PeelOut_duration_anim") > CurTime() then return end
        if SERVER then
            if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then
            else
                ent.AlternatePlaySolution = true
                ent:PillAnim('Jump2')
                ent.AlternatePlaySolution = false
                AdvancedPillSound(
                    {
                        stringe = "OM/metal/metaljump.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end
        end
        
        if ent:GetNW2Float("ChargingDuration") > CurTime() or (IsValid(ent:GetNW2Entity("Metal_chargingEnemy")) and ent:GetNW2Float("TotalDamageTaken_Charge_OM") < 40) then
            ply:SetPos(ply:GetPos()+Vector(0,0,10))
            ply:SetVelocity(ply:GetUp()*400 + ply:GetForward()* 0)
            ply:SetLocalVelocity(ply:GetUp()*400 + ply:GetForward()* 0)
        end

    end
})











