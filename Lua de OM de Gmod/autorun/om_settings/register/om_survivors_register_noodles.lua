

AddCSLuaFile()

if SERVER then

    -- Amy's convars group
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Health", 100, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Amy_walk", 20, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_run", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_rollingPower", 1500, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Amy_Hammer_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Hammer_stunstack", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Hammer_ragdollstun", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Hammer_cd", 24, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Hammer_dur", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Hammer_Stun_dur", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Hammer_Stun_damage", 13, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Amy_Throw_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Throw_stunstack", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Throw_ragdollstun", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Amy_Throw_cd", 24, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_Throw_cd_cancel", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_Throw_Stun_dur", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_Throw_Stun_damage", 13, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Amy_CardSwap_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Amy_CardSwap_cd", 18, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Amy_0_1_damage_reduction", 1.15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_0_2_damage_reduction", 0.85, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_1_damage_reduction", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_2_damage_reduction", 0.85, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_3_damage_reduction", 1.15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_4_damage_reduction", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_5_damage_reduction", 1, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Amy_0_stunduration", 0, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_1_stunduration", 0, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_2_stunduration", 0, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_3_stunduration", 1, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_4_stunduration", 0, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_5_stunduration", -1, FCVAR_ARCHIVE, "", -1e9, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Amy_0_1_speed", -90, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_0_2_speed", 90, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_1_speed", 0, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_2_speed", 60, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_3_speed", -90, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_4_speed", 0, FCVAR_ARCHIVE, "", -1e9, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_5_speed", 40, FCVAR_ARCHIVE, "", -1e9, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Amy_1_healing", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Amy_1_healAmount", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_1_healLimit", 75, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Amy_1_healspeed", 2, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_amy", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_Amy_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_Health"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Amy_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_rollingPower"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_useable"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_stunstack"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_ragdollstun"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_dur"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_Hammer_Stun_damage"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Amy_Throw_useable"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_Throw_stunstack"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_Throw_ragdollstun"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Amy_Throw_cd"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_Throw_cd_cancel"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_Throw_Stun_dur"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_Throw_Stun_damage"):Revert()

        GetConVar("OUTCOMEMORIES_N_Amy_CardSwap_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_CardSwap_cd"):Revert()

        GetConVar("OUTCOMEMORIES_N_Amy_0_1_damage_reduction"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_0_2_damage_reduction"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_1_damage_reduction"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_2_damage_reduction"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_3_damage_reduction"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_4_damage_reduction"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_5_damage_reduction"):Revert()

        GetConVar("OUTCOMEMORIES_N_Amy_0_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_1_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_2_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_3_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_4_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_5_stunduration"):Revert()

        GetConVar("OUTCOMEMORIES_N_Amy_0_1_speed"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_0_2_speed"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_1_speed"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_2_speed"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_3_speed"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_4_speed"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_5_speed"):Revert()

        GetConVar("OUTCOMEMORIES_N_Amy_1_healing"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_1_healAmount"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_1_healLimit"):Revert()
        GetConVar("OUTCOMEMORIES_N_Amy_1_healspeed"):Revert()
    end)

    -- Knuckles convar group
    CreateConVar("OUTCOMEMEMORIES_N_Knuckles_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Knuckles_Health", 100, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Knuckles_walk", 40, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Knuckles_run", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Knuckles_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Knuckles_glide", 325, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Knuckles_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Knuckles_rollingPower", 1500, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_stunstack", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_cooldown", 24, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_cooldown_cancel", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_basestun", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_basedamage", 35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_canragdollstun", 1, FCVAR_ARCHIVE, "", 0, 1)


    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_cancharge", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_chargetime1", 4.5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_chargetime2", 9, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_damageamount1", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_damageamount2", 10, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_stunamount1", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Punch_stunamount2", 1, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Knuckles_Counter_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Counter_cooldownSucess", 23, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Counter_cooldownFail", 29, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Counter_basestun", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Counter_basedamage", 0, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Counter_canragdollstun", 1, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMORIES_N_Knuckles_latch_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Latch_duration", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_Glide_duration", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_latchcount", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Knuckles_latch_haslimit", 1, FCVAR_ARCHIVE, "", 0, 1)

    concommand.Add("om_reset_knuckles", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_Knuckles_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Knuckles_Health"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Knuckles_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Knuckles_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Knuckles_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Knuckles_glide"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Knuckles_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Knuckles_rollingPower"):Revert()

        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_stunstack"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_cooldown"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_cooldown_cancel"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_basestun"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_basedamage"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_canragdollstun"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_cancharge"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_chargetime1"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_chargetime2"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_damageamount1"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_damageamount2"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_stunamount1"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Punch_stunamount2"):Revert()

        GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_canragdollstun"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_cooldownSucess"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_cooldownFail"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_basestun"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Counter_basedamage"):Revert()

        GetConVar("OUTCOMEMORIES_N_Knuckles_latch_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Latch_duration"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_Glide_duration"):Revert()
        GetConVar("OUTCOMEMORIES_N_Knuckles_latchcount"):Revert()
    end)

    -- sonic convars group
    CreateConVar("OUTCOMEMEMORIES_N_Sonic_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Sonic_Health", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Sonic_Dodgemeter", 50, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Sonic_walk", 40, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Sonic_run", 460, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Sonic_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Sonic_DropDash", 1000, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Sonic_PeelOut", 1850, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Sonic_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Sonic_rollingPower", 1500, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_slippery", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_stunstack", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_cooldownSucess", 27, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_cooldownLand", 35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_AddToPeelout", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_basestun", 1.5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_basestun_final", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_basedamage", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_duration", 8, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_ringgain", 10, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Dropdash_maxhits", 3, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Sonic_Peelout_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Peelout_cooldownSuccess", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Peelout_cooldownFail", 45, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Sonic_Peelout_duration", 8, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Sonic_DropdashPeelout_useable", 1, FCVAR_ARCHIVE, "", 0, 1)

    concommand.Add("om_reset_sonic", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_Sonic_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Sonic_Health"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Sonic_Dodgemeter"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Sonic_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Sonic_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Sonic_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Sonic_DropDash"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Sonic_PeelOut"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Sonic_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Sonic_rollingPower"):Revert()

        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_slippery"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_stunstack"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_cooldownSucess"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_cooldownLand"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_AddToPeelout"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_basestun"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_basestun_final"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_duration"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_ringgain"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Dropdash_maxhits"):Revert()

        GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_cooldownSuccess"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_cooldownFail"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_Sonic_Peelout_duration"):Revert()

        GetConVar("OUTCOMEMORIES_N_Sonic_DropdashPeelout_useable"):Revert()
    end)

    -- Metal Sonic convars group
    CreateConVar("OUTCOMEMEMORIES_N_MetalSonic_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_MetalSonic_Health", 175, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_MetalSonic_radar", 1, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMEMORIES_N_MetalSonic_walk", 40, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_MetalSonic_run", 430, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_MetalSonic_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_MetalSonic_Charging", 3524, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_MetalSonic_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_MetalSonic_rollingPower", 1500, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_slippery", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_stunstack", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_cooldownSucess", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_MetalSelfDamageTick", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_DamageTick", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_slamDamage", 39*0.75, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_MetalSelfDamageSlam", 39, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_tic", 0.8, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_slam", 6, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_charge_Duration", 8, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_MetalSonic_heal_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_heal_cooldownSucess", 24, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_MetalSonic_heal_healamount", 7, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_metalsonic", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_MetalSonic_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_MetalSonic_Health"):Revert()

        GetConVar("OUTCOMEMORIES_N_MetalSonic_radar"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_MetalSonic_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_MetalSonic_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_MetalSonic_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_MetalSonic_Charging"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_MetalSonic_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_MetalSonic_rollingPower"):Revert()

        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_slippery"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_stunstack"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_cooldownSucess"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_MetalSelfDamageTick"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_DamageTick"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_slamDamage"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_MetalSelfDamageSlam"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_tic"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_slam"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_charge_Duration"):Revert()

        GetConVar("OUTCOMEMORIES_N_MetalSonic_heal_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_heal_cooldownSucess"):Revert()
        GetConVar("OUTCOMEMORIES_N_MetalSonic_heal_healamount"):Revert()
    end)

    -- Fleetway's convars group
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_HasHealth", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Health", 355, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_m1_range", 180, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_walk", 150, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_run", 535, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_jumpcd", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_rollingPower", 1500, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_CriticalDamage", 44, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Damage", 35, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_PropsDestruction", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_DoorsDestruction", 1, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_Cooldown", 24, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_CooldownStun", 44, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_damage", 35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_cancombo", 1, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_Cooldown", 24, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_healthadd", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_damage", 3, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_autocancel", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Cooldown", 24, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Duration", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_damagepertic", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_damagecd", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_canburn", 1, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMORIES_N_Fleetway_CaosDash_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_CaosDash_autocancel", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Cooldown", 24, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Duration", 7, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Damage", 12, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Speed", 1000, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_CaosDash_Limit", 5, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Fleetway_flying", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_flying_drainIdle", 0.75, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_flying_drainWalk", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_flying_drainRun", 1.5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_flying_walk", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_flying_run", 33*0.7, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_flying_regeneration", 0.1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_flying_flightmax", 150, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_Fleetway_phase2", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_Fleetway_phase2_specialactivation", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Fleetway_phase2_HealthActivation", 350*0.5, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_fleetway", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_Fleetway_HasHealth"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Health"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Fleetway_m1_range"):Revert()

        GetConVar("OUTCOMEMORIES_N_Fleetway_phase2"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_phase2_specialactivation"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_phase2_HealthActivation"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Fleetway_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_rollingPower"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Fleetway_CriticalDamage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Damage"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Fleetway_PropsDestruction"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_DoorsDestruction"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_useable"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_cancombo"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_Cooldown"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_CooldownStun"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_damage"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_useable"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_Cooldown"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_healthadd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_damage"):Revert()

        GetConVar("OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_autocancel"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Cooldown"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Duration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_damagepertic"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_damagecd"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_canburn"):Revert()

        GetConVar("OUTCOMEMORIES_N_Fleetway_CaosDash_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_CaosDash_autocancel"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Cooldown"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Duration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Damage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Speed"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_CaosDash_Limit"):Revert()

        GetConVar("OUTCOMEMORIES_N_Fleetway_flying"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_flying_drainIdle"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_flying_drainWalk"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_flying_drainRun"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_flying_walk"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_flying_run"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_flying_regeneration"):Revert()
        GetConVar("OUTCOMEMORIES_N_Fleetway_flying_flightmax"):Revert()
    end)
end

if CLIENT then
    CreateClientConVar("om_pills_action_Sonic_dropdash_key", KEY_E, true, true, "Sonic's dropdash keybind")
    CreateClientConVar("om_pills_action_Sonic_peelout_key", KEY_T, true, true, "Sonic's dropdash keybind")

    CreateClientConVar("om_pills_action_Knuckles_Punch_key", KEY_E, true, true, "Knuckles Punch keybind")
    CreateClientConVar("om_pills_action_Knuckles_Counter_key", KEY_T, true, true, "Knuckles Counter keybind")
    CreateClientConVar("om_pills_knuckles_custombar", 0, true, true, "This adds a custom bar to Knuckle's punch to indicate how close you are to his fully charged state.")

    CreateClientConVar("om_pills_action_MetalSonic_Charge_key", KEY_E, true, true, "Metal Sonic's charge keybind")
    CreateClientConVar("om_pills_action_MetalSonic_Heal_key", KEY_T, true, true, "Metal Sonic's heal keybind")
    CreateClientConVar("om_pills_metal_custombar", 0, true, true, "This adds a custom bar to his charge where it tells how much time is left before it ends.")
    CreateClientConVar("om_pills_metal_custombar_heal", 0, true, true, "This adds a custom bar to his heal where it tells how much time is left before it ends.")
    
    CreateClientConVar("om_pills_action_Amy_Hammer_key", KEY_E, true, true, "Amy Hammer keybind")
    CreateClientConVar("om_pills_action_Amy_Throw_key", KEY_T, true, true, "Amy Throw keybind")
    CreateClientConVar("om_pills_action_Amy_Cards_key", KEY_R, true, true, "Amy Cards keybind")

    CreateClientConVar("om_pills_action_Amy_alternateIndicator", 0, true, true, "Amy card highlight")
        
    CreateClientConVar("om_pills_action_fleetway_caosdash_key", KEY_E, true, true, "Fleetways Caosdash keybind")
    CreateClientConVar("om_pills_action_fleetway_laser_key", KEY_R, true, true, "Fleetways Laser Of Destruction keybind")
    CreateClientConVar("om_pills_action_fleetway_drain_key", KEY_T, true, true, "Fleetways Fateful Drain keybind")
    CreateClientConVar("om_pills_action_fleetway_Burst_key", KEY_I, true, true, "Fleetways Burst keybind")
    CreateClientConVar("om_pills_fleetway_custombar", 0, true, true, "This custom bar indicates how much time is left on laser of destruction")
    
    CreateClientConVar("om_pills_action_camera_Sonic", 0, true, true, "Camera Toggle is activated by abilities for Sonic")
    CreateClientConVar("om_pills_action_camera_Knuckles", 1, true, true, "Camera Toggle is activated by abilities for Knuckles")
    CreateClientConVar("om_pills_action_camera_MetalSonic", 0, true, true, "Camera Toggle is activated by abilities for Metal Sonic")
    CreateClientConVar("om_pills_action_camera_Amy", 0, true, true, "Camera Toggle is activated by abilities for Amy")
    CreateClientConVar("om_pills_action_camera_Fleetway", 0, true, true, "Camera Toggle is activated by abilities for Fleetway")


    local preservedmats = {
        ["OM_icon_survivor"] = "icons/Polygon_of_doom.png",
        ["OM_icon_monster"] = "icons/Polygon_of_DEVI.png",
        ["Sonic_OM_noodles_spindash"] = "icons/Sonic_OM_noodles_spindash.png",
        ["Sonic_OM_noodles_peelout"] = "icons/Sonic_OM_noodles_peelout.png",

        ["Knuckles_OM_noodles_punch"] = "icons/Knuckles_OM_noodles_punch.png",
        ["Knuckles_OM_noodles_counter"] = "icons/Knuckles_OM_noodles_counter.png",

        ["Metal_OM_noodles_heal"] = "icons/Metal_OM_noodles_heal.png",
        ["Metal_OM_noodles_charge"] = "icons/Metal_OM_noodles_charge.png",
        
        ["Amy_OM_Noodles_hammer"] = "icons/Amy_OM_Noodles_hammer.png",
        ["Amy_OM_Noodles_throw"] = "icons/Amy_OM_Noodles_throw.png",
        ["Amy_OM_Noodles_cardshuffle"] = "icons/Amy_OM_Noodles_cardshuffle.png",

        ["fleetway_OM_dash"] = "icons/CHAOS_DASH_-_copia.png",
        ["fleetway_OM_laser"] = "icons/sonic_eyes_-_copia.png",
        ["fleetway_OM_drain"] = "icons/fateful_drain_-_copia.png",
        ["fleetway_OM_burst"] = "icons/bURST_-_copia.png",

        ["OM_cameraset"] = "icons/OM_cameraset.png",
        ["FOV_om"] = "icons/FOV_om.png",
        ["subtitles_icon"] = "icons/subtitles_icon.png",
        ["zoom_in"] = "icons/zoom_in.png",
        ["zoom_out"] = "icons/zoom_out.png",
        ["rolling_icon_om"] = "icons/rolling_icon_om.png",
        ["bhop_remake_om"] = "icons/bhop_remake_om.png",
        ["health_bar_icon"] = "icons/health_bar_icon.png",
        ["chase_theme_toggle"] = "icons/chase_theme_toggle.png",
        ["smart_amazing_volume_om"] = "icons/smart_amazing_volume_om.png",

        ["damage_percentage"] = "icons/damage_percentage.png",
        ["walk_speed"] = "icons/walk_speed.png",
        ["run_speed"] = "icons/run_speed.png",
        ["jump_power"] = "icons/jump_power.png",
        ["peeldash_toggle"] = "icons/peeldash_toggle.png",
        ["self_revive"] = "icons/self_revive.png",
        ["last_life_icon"] = "icons/last_life_icon.png",
        

        ["preset_icon_om"] = "icons/preset_icon_om.png",
        
        ["Knuckles_GlideSetting"] = "icons/Knuckles_GlideSetting.png",
        ["Knuckles_LatcSetting"] = "icons/Knuckles_LatcSetting.png",
        
        ["OM_flyingicon"] = "icons/OM_flyingicon.png",
        ["OM_flyingcdicon"] = "icons/OM_flyingcdicon.png",
        
        ["motionblack_om"] = "icons/motionblack_om.png",
        ["epilblack_om"] = "icons/epilblack_om.png",
        
        ["DoorIcon"] = "icons/DoorIcon.png",
        ["PropsIcon"] = "icons/PropsIcon.png",

    }

    local KeyDefaults2 = {
        ["Sonic"] = {
            om_pills_action_Sonic_dropdash_key = KEY_E,
            om_pills_action_Sonic_peelout_key = KEY_T,
        },
        ["Knuckles"] = {
            om_pills_action_Knuckles_Punch_key = KEY_E,
            om_pills_action_Knuckles_Counter_key = KEY_T,
        },

        ["Metal"] = {
            om_pills_action_MetalSonic_Charge_key = KEY_E,
            om_pills_action_MetalSonic_Heal_key = KEY_T,
        },

        ["Amy"] = {
            om_pills_action_Amy_Hammer_key = KEY_E,
            om_pills_action_Amy_Throw_key = KEY_T,
            om_pills_action_Amy_Cards_key = KEY_R,
        },

        ["Fleetway"] = {
            om_pills_action_fleetway_caosdash_key = KEY_E,
            om_pills_action_fleetway_laser_key = KEY_R,
            om_pills_action_fleetway_drain_key = KEY_T,
            om_pills_action_fleetway_Burst_key = KEY_I,
        },

    }

    concommand.Add("om_sonic_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Sonic pill",
            ["Image"] = "pills/pill_om_sonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Dropdash",
            convar = "om_pills_action_Sonic_dropdash_key",
            color = Color(0, 150, 255, 180),
            isexe = false,
            bioText = "This keybind is used to activate dropdash. What else is there to say?",
            vartype = 'bind',
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_peelout"],
            labelText = "Peelout",
            convar = "om_pills_action_Sonic_peelout_key",
            color = Color(0, 45, 255, 180),
            isexe = false,
            bioText = "This keybind is used to activate Peelout. What else is there to say?",
            vartype = 'bind',
        })

        OM_RegisterResetButton_client(scroll, "Sonic", KeyDefaults2)
        
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_Sonic",
            color = Color(80, 80, 80, 180),
            isexe = false,
            bioText = "When this setting is on, this allows abilities to change the camera position and fov.",
            vartype = 'bool',
        })
    end)

    
    concommand.Add("om_knuckles_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Knuckles pill",
            ["Image"] = "pills/pill_om_knuckles.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "Punch",
            convar = "om_pills_action_Knuckles_Punch_key",
            color = Color(255, 150, 0, 180),
            vartype = "bind",
            isexe = false,
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_counter"],
            labelText = "Counter",
            convar = "om_pills_action_Knuckles_Counter_key",
            color = Color(255, 45, 0, 180),
            vartype = "bind",
            isexe = false,
            bioText = "Meow!",
        })

        
        OM_RegisterResetButton_client(scroll, "Knuckles", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_Knuckles",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            bioText = "Allows abilities to adjust camera position and FOV.",
            isexe = false,
        })
        --[[
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "Custom Bar",
            convar = "om_pills_knuckles_custombar",
            color = Color(255, 0, 0, 180),
            vartype = "bool",
            bioText = "This adds a bar where it tracks the punch's charge level ranging from 0-100",
            isexe = false,
        })
        ]]
    end)

    concommand.Add("om_amy_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Amy pill",
            ["Image"] = "pills/pill_om_amy.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Hammer",
            convar = "om_pills_action_Amy_Hammer_key",
            color = Color(255, 150, 255, 180),
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Throw",
            convar = "om_pills_action_Amy_Throw_key",
            color = Color(255, 65, 255, 180),
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Cards",
            convar = "om_pills_action_Amy_Cards_key",
            color = Color(255, 45, 175, 180),
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Amy", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_Amy",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Alternate indicator",
            convar = "om_pills_action_Amy_alternateIndicator",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
        })

    end)

    concommand.Add("om_metalSonic_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Metal Sonic pill",
            ["Image"] = "pills/pill_om_metalsonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        topImage.Think = function(self)
            local speed = 1.5
        
            local wave = (math.sin(CurTime() * speed) + 1) / 2

            local r = Lerp(wave, 255, 0)
            local g = 255
            local b = Lerp(wave, 255, 0)

            self:SetImageColor(Color(r, g, b))
        end

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Charge",
            convar = "om_pills_action_MetalSonic_Charge_key",
            color = Color(0, 0, 175, 180),
            vartype = "bind",
            isexe = false,
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_heal"],
            labelText = "Heal",
            convar = "om_pills_action_MetalSonic_Heal_key",
            color = Color(0, 0, 110, 180),
            vartype = "bind",
            isexe = false,
            bioText = "Meow!",
        })
        OM_RegisterResetButton_client(scroll, "Metal", KeyDefaults2)
                
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_MetalSonic",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Charge Custom Bar",
            convar = "om_pills_metal_custombar",
            color = Color(255, 0, 0, 180),
            vartype = "bool",
            bioText = "This bar allows you to see how much time you have before charge ends",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Heal Custom Bar",
            convar = "om_pills_metal_custombar_heal",
            color = Color(255, 0, 0, 180),
            vartype = "bool",
            bioText = "This bar allows you to see how much time you have before heal ends",
            isexe = false,
        })
    end)

    concommand.Add("om_fleetway_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Fleetway pill",
            ["Image"] = "pills/pill_om_fleetway.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        topImage.Think = function(self)
            local speed = 1.5
        
            local wave = (math.sin(CurTime() * speed) + 1) / 2

            local r = 255
            local g = Lerp(wave, 255, 0)
            local b = Lerp(wave, 255, 0)

            self:SetImageColor(Color(r, g, b))
        end

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_dash"],
            labelText = "Chaos Dash",
            convar = "om_pills_action_fleetway_caosdash_key",
            color = Color(255, 175, 0, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_laser"],
            labelText = "Laser of Destruction",
            convar = "om_pills_action_fleetway_laser_key",
            color = Color(211, 211, 0, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_drain"],
            labelText = "Fateful Drain",
            convar = "om_pills_action_fleetway_drain_key",
            color = Color(135, 135, 0, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_burst"],
            labelText = "Burst",
            convar = "om_pills_action_fleetway_Burst_key",
            color = Color(70, 70, 0, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Fleetway", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_Fleetway",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_laser"],
            labelText = "Laser Of Destruction Custom Bar",
            convar = "om_pills_fleetway_custombar",
            color = Color(255, 0, 0, 180),
            vartype = "bool",
            bioText = "This adds a bar that tracks how much time is left on the laser",
            isexe = false,
        })
    end)


    

    concommand.Add("om_sonic_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Sonic pill",
            ["Image"] = "pills/pill_om_sonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["preset_icon_om"],
            labelText = "Presents",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'preset',
            presettable = {
                listofdefualtconvars = {
                    "OUTCOMEMEMORIES_N_Sonic_Health",
                    "OUTCOMEMEMORIES_N_Sonic_Dodgemeter",
                    "OUTCOMEMEMORIES_N_Sonic_Resistance",
                    "OUTCOMEMEMORIES_N_Sonic_walk",
                    "OUTCOMEMEMORIES_N_Sonic_run",
                    "OUTCOMEMEMORIES_N_Sonic_jumppower",
                    "OUTCOMEMEMORIES_N_Sonic_DropDash",
                    "OUTCOMEMEMORIES_N_Sonic_PeelOut",
                    "OUTCOMEMEMORIES_N_Sonic_jumpcd",
                    "OUTCOMEMEMORIES_N_Sonic_rollingPower",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_useable",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_slippery",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_stunstack",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_cooldownSucess",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_cooldownLand",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_AddToPeelout",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_basestun",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_basestun_final",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_duration",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_ringgain",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_maxhits",
                    "OUTCOMEMORIES_N_Sonic_Dropdash_basedamage",
                    "OUTCOMEMORIES_N_Sonic_Peelout_useable",
                    "OUTCOMEMORIES_N_Sonic_Peelout_cooldownSuccess",
                    "OUTCOMEMORIES_N_Sonic_Peelout_cooldownFail",
                    "OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration",
                    "OUTCOMEMORIES_N_Sonic_Peelout_duration",
                    "OUTCOMEMORIES_N_Sonic_DropdashPeelout_useable",
                },
                name = "Sonic",
            }
        })

        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_Sonic_Health",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 500,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Dodge Meter",
            convar = "OUTCOMEMEMORIES_N_Sonic_Dodgemeter",
            color = Color(80, 80, 175, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_Sonic_Resistance",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 500,
                dec = 1,
                default = 100,
            }
        })

        -- speed
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["walk_speed"],
            labelText = "Walk speed",
            convar = "OUTCOMEMEMORIES_N_Sonic_walk",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["run_speed"],
            labelText = "Run speed",
            convar = "OUTCOMEMEMORIES_N_Sonic_run",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 900,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Jump Power",
            convar = "OUTCOMEMEMORIES_N_Sonic_jumppower",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 900,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Jump Cooldown",
            convar = "OUTCOMEMEMORIES_N_Sonic_jumpcd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 900,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Rolling Power",
            convar = "OUTCOMEMEMORIES_N_Sonic_rollingPower",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 5000,
                dec = 1,
                default = 400,
            }
        })


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Dropdash speed",
            convar = "OUTCOMEMEMORIES_N_Sonic_DropDash",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 8000,
                dec = 1,
                default = 325,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_peelout"],
            labelText = "Peelout speed",
            convar = "OUTCOMEMEMORIES_N_Sonic_PeelOut",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 8000,
                dec = 1,
                default = 325,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Enabled Dropdash",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_useable",
            color = Color(35, 35, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "Everybody's favorite stun ability! ..am i right?",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Slipperiness",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_slippery",
            color = Color(35, 35, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Stun Stack",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_stunstack",
            color = Color(35, 35, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Dropdash Cooldown",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_cooldownSucess",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Dropdash Cooldown Land",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_cooldownLand",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Peelout addition Cooldown",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_AddToPeelout",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Base Stun",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_basestun",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 70,
                dec = 1,
                default = 1.5,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Drill stun",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_basestun_final",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 70,
                dec = 1,
                default = 1.5,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Base Damage",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_basedamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 500,
                dec = 1,
                default = 5,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Dropdash duration",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_duration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 40,
                dec = 1,
                default = 5,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Dodge meter gain",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_ringgain",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 40,
                dec = 1,
                default = 5,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_spindash"],
            labelText = "Dropdash max hits",
            convar = "OUTCOMEMORIES_N_Sonic_Dropdash_maxhits",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 5,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_peelout"],
            labelText = "Enabled Peelout",
            convar = "OUTCOMEMORIES_N_Sonic_Peelout_useable",
            color = Color(35, 35, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "Now you can throw your friends into the void with you!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_peelout"],
            labelText = "Peelout Success Cooldown",
            convar = "OUTCOMEMORIES_N_Sonic_Peelout_cooldownSuccess",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_peelout"],
            labelText = "Peelout Failed Cooldown",
            convar = "OUTCOMEMORIES_N_Sonic_Peelout_cooldownFail",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_peelout"],
            labelText = "Peelout Charge",
            convar = "OUTCOMEMORIES_N_Sonic_Peelout_chargeupduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Sonic_OM_noodles_peelout"],
            labelText = "Peelout Duration",
            convar = "OUTCOMEMORIES_N_Sonic_Peelout_duration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 24,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["peeldash_toggle"],
            labelText = "Enabled Peeldash",
            convar = "OUTCOMEMORIES_N_Sonic_DropdashPeelout_useable",
            color = Color(35, 35, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "Executioners are definitely going to hate this one",
        })

        OM_RegisterResetButton_server(scroll, "Sonic", "om_reset_sonic")
    end)

    concommand.Add("om_fleetway_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Fleetway pill",
            ["Image"] = "pills/pill_om_fleetway.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        topImage.Think = function(self)
            local speed = 1.5
        
            local wave = (math.sin(CurTime() * speed) + 1) / 2

            local r = 255
            local g = Lerp(wave, 255, 0)
            local b = Lerp(wave, 255, 0)

            self:SetImageColor(Color(r, g, b))
        end

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["preset_icon_om"],
            labelText = "Presents",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'preset',
            presettable = {
                listofdefualtconvars = {
                    "OUTCOMEMEMORIES_N_Fleetway_m1_range",
                    "OUTCOMEMEMORIES_N_Fleetway_HasHealth",
                    "OUTCOMEMEMORIES_N_Fleetway_Resistance",
                    "OUTCOMEMEMORIES_N_Fleetway_Health",
                    "OUTCOMEMEMORIES_N_Fleetway_walk",
                    "OUTCOMEMEMORIES_N_Fleetway_run",
                    "OUTCOMEMEMORIES_N_Fleetway_jumppower",
                    "OUTCOMEMEMORIES_N_Fleetway_jumpcd",
                    "OUTCOMEMEMORIES_N_Fleetway_rollingPower",
                    "OUTCOMEMEMORIES_N_Fleetway_CriticalDamage",
                    "OUTCOMEMEMORIES_N_Fleetway_Damage",
                    "OUTCOMEMEMORIES_N_Fleetway_PropsDestruction",
                    "OUTCOMEMEMORIES_N_Fleetway_DoorsDestruction",
                    "OUTCOMEMEMORIES_N_Fleetway_Burst_useable",
                    "OUTCOMEMEMORIES_N_Fleetway_Burst_cancombo",
                    "OUTCOMEMEMORIES_N_Fleetway_Burst_Cooldown",
                    "OUTCOMEMEMORIES_N_Fleetway_Burst_CooldownStun",
                    "OUTCOMEMEMORIES_N_Fleetway_Burst_damage",
                    "OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_useable",
                    "OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_Cooldown",
                    "OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_healthadd",
                    "OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_damage",
                    "OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_useable",
                    "OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_autocancel",
                    "OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Cooldown",
                    "OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Duration",
                    "OUTCOMEMORIES_N_Fleetway_CaosDash_useable",
                    "OUTCOMEMORIES_N_Fleetway_CaosDash_autocancel",
                    "OUTCOMEMEMORIES_N_Fleetway_CaosDash_Cooldown",
                    "OUTCOMEMEMORIES_N_Fleetway_CaosDash_Duration",
                    "OUTCOMEMEMORIES_N_Fleetway_CaosDash_Damage",
                    "OUTCOMEMEMORIES_N_Fleetway_CaosDash_Speed",
                    "OUTCOMEMORIES_N_Fleetway_CaosDash_Limit",
                    "OUTCOMEMORIES_N_Fleetway_flying",
                    "OUTCOMEMORIES_N_Fleetway_flying_drainIdle",
                    "OUTCOMEMORIES_N_Fleetway_flying_drainWalk",
                    "OUTCOMEMORIES_N_Fleetway_flying_drainRun",
                    "OUTCOMEMORIES_N_Fleetway_flying_walk",
                    "OUTCOMEMORIES_N_Fleetway_flying_run",
                    "OUTCOMEMORIES_N_Fleetway_flying_regeneration",
                    "OUTCOMEMORIES_N_Fleetway_flying_flightmax",
                    "OUTCOMEMORIES_N_Fleetway_phase2",
                    "OUTCOMEMORIES_N_Fleetway_phase2_specialactivation",
                    "OUTCOMEMEMORIES_N_Fleetway_phase2_HealthActivation",
                    "OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_canburn",
                    "OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_damagecd",
                    "OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_damagepertic",


                },
                name = "Fleetway",
            }
        })

        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Has Health",
            convar = "OUTCOMEMEMORIES_N_Fleetway_HasHealth",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
            bioText = "life insurance not included",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Health",
            color = Color(80, 175, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Resistance",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 500,
                dec = 1,
                default = 100,
            }
        })

        -- phase 2
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "M1 Range",
            convar = "OUTCOMEMEMORIES_N_Fleetway_m1_range",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 500,
                dec = 1,
                default = 100,
            }
        })


        -- phase 2
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Can phase 2",
            convar = "OUTCOMEMORIES_N_Fleetway_phase2",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "phase 2Sound Activation",
            convar = "OUTCOMEMORIES_N_Fleetway_phase2_specialactivation",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Phase 2 health activation",
            convar = "OUTCOMEMEMORIES_N_Fleetway_phase2_HealthActivation",
            color = Color(80, 175, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 350,
                dec = 1,
                default = 100,
            }
        })

        -- speed
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["walk_speed"],
            labelText = "Walk speed",
            convar = "OUTCOMEMEMORIES_N_Fleetway_walk",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["run_speed"],
            labelText = "Run speed",
            convar = "OUTCOMEMEMORIES_N_Fleetway_run",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 900,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Jump Power",
            convar = "OUTCOMEMEMORIES_N_Fleetway_jumppower",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 900,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Jump Cooldown",
            convar = "OUTCOMEMEMORIES_N_Fleetway_jumpcd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 2,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Rolling Power",
            convar = "OUTCOMEMEMORIES_N_Fleetway_rollingPower",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 5000,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Damage",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Damage",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 35,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Critical Damage",
            convar = "OUTCOMEMEMORIES_N_Fleetway_CriticalDamage",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 44,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["PropsIcon"],
            labelText = "Enabled Props destruction",
            convar = "OUTCOMEMEMORIES_N_Fleetway_PropsDestruction",
            color = Color(195, 195, 35, 180),
            vartype = "bool",
            isexe = true,
            bioText = "",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["DoorIcon"],
            labelText = "Enabled Door destruction",
            convar = "OUTCOMEMEMORIES_N_Fleetway_DoorsDestruction",
            color = Color(195, 195, 35, 180),
            vartype = "bool",
            isexe = true,
            bioText = "",
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_burst"],
            labelText = "Enabled Burst",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Burst_useable",
            color = Color(195, 195, 35, 180),
            vartype = "bool",
            isexe = true,
            bioText = "Ka boom? yes Fleetway, Ka boom",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_burst"],
            labelText = "Can combo",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Burst_cancombo",
            color = Color(195, 195, 35, 180),
            vartype = "bool",
            isexe = true,
            bioText = "This removes any restrictions from using any ability",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_burst"],
            labelText = "Burst Cooldown",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Burst_Cooldown",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_burst"],
            labelText = "Burst Stunned Cooldown",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Burst_CooldownStun",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_burst"],
            labelText = "Burst Damage",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Burst_damage",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })
        
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_drain"],
            labelText = "Enabled Fateful drain",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_useable",
            color = Color(195, 195, 35, 180),
            vartype = "bool",
            isexe = true,
            bioText = "This is not how you play tag",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_drain"],
            labelText = "Fateful drain Cooldown",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_Cooldown",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_drain"],
            labelText = "Health Add",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_healthadd",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_drain"],
            labelText = "Damage Towards Target",
            convar = "OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_damage",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 40,
                dec = 1,
                default = 24,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_laser"],
            labelText = "Enabled Laser Of Destruction",
            convar = "OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_useable",
            color = Color(195, 195, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_laser"],
            labelText = "Enabled auto cancel",
            convar = "OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_autocancel",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_laser"],
            labelText = "Cooldown",
            convar = "OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Cooldown",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_laser"],
            labelText = "Duration",
            convar = "OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Duration",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_laser"],
            labelText = "Damage Per Tic",
            convar = "OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_damagepertic",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_laser"],
            labelText = "Damage cd",
            convar = "OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_damagecd",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 2,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_laser"],
            labelText = "Can burn",
            convar = "OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_canburn",
            color = Color(195, 195, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_dash"],
            labelText = "Enabled Chaos Dash",
            convar = "OUTCOMEMORIES_N_Fleetway_CaosDash_useable",
            color = Color(195, 195, 35, 180),
            vartype = "bool",
            isexe = true,
            bioText = "the cooler dropdash",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_dash"],
            labelText = "Enabled auto cancel",
            convar = "OUTCOMEMORIES_N_Fleetway_CaosDash_autocancel",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_dash"],
            labelText = "Chaos Dash Cooldown",
            convar = "OUTCOMEMEMORIES_N_Fleetway_CaosDash_Cooldown",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_dash"],
            labelText = "Chaos Dash Duration",
            convar = "OUTCOMEMEMORIES_N_Fleetway_CaosDash_Duration",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_dash"],
            labelText = "Chaos Dash damage",
            convar = "OUTCOMEMEMORIES_N_Fleetway_CaosDash_Damage",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_dash"],
            labelText = "Chaos Dash Speed",
            convar = "OUTCOMEMEMORIES_N_Fleetway_CaosDash_Speed",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 6000,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fleetway_OM_dash"],
            labelText = "Chaos Dash Hit Limit",
            convar = "OUTCOMEMORIES_N_Fleetway_CaosDash_Limit",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            },
            bioText = "0 = none. Anything greater than 0 will be the limit."
        })


        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_flyingcdicon"],
            labelText = "Enabled Flying",
            convar = "OUTCOMEMORIES_N_Fleetway_flying",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
            bioText = "Chirp Chirp",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_flyingicon"],
            labelText = "Flying idle drain",
            convar = "OUTCOMEMORIES_N_Fleetway_flying_drainIdle",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 5,
                default = 24,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_flyingicon"],
            labelText = "Flying Walk drain",
            convar = "OUTCOMEMORIES_N_Fleetway_flying_drainWalk",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 5,
                default = 24,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_flyingicon"],
            labelText = "Flying Run drain",
            convar = "OUTCOMEMORIES_N_Fleetway_flying_drainRun",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 5,
                default = 24,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_flyingicon"],
            labelText = "Flying Walk",
            convar = "OUTCOMEMORIES_N_Fleetway_flying_walk",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 5,
                default = 24,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_flyingicon"],
            labelText = "Flying Run",
            convar = "OUTCOMEMORIES_N_Fleetway_flying_run",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 90,
                dec = 5,
                default = 24,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_flyingicon"],
            labelText = "Flying Regeneration",
            convar = "OUTCOMEMORIES_N_Fleetway_flying_regeneration",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 5,
                dec = 5,
                default = 24,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_flyingicon"],
            labelText = "Max Flgiht",
            convar = "OUTCOMEMORIES_N_Fleetway_flying_flightmax",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 300,
                dec = 5,
                default = 24,
            }
        })

        OM_RegisterResetButton_server(scroll, "Fleetway", "om_reset_fleetway")
    end)


    concommand.Add("om_knuckles_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Knuckles pill",
            ["Image"] = "pills/pill_om_knuckles.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["preset_icon_om"],
            labelText = "Presents",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'preset',
            presettable = {
                listofdefualtconvars = {
                    "OUTCOMEMEMORIES_N_Knuckles_Resistance",
                    "OUTCOMEMEMORIES_N_Knuckles_Health",
                    "OUTCOMEMEMORIES_N_Knuckles_walk",
                    "OUTCOMEMEMORIES_N_Amy_run",
                    "OUTCOMEMEMORIES_N_Knuckles_jumppower",
                    "OUTCOMEMEMORIES_N_Knuckles_glide",
                    "OUTCOMEMEMORIES_N_Knuckles_rollingPower",
                    "OUTCOMEMORIES_N_Knuckles_Punch_useable",
                    "OUTCOMEMORIES_N_Knuckles_Punch_stunstack",
                    "OUTCOMEMORIES_N_Knuckles_Punch_cooldown",
                    "OUTCOMEMORIES_N_Knuckles_Punch_cooldown_cancel",
                    "OUTCOMEMORIES_N_Knuckles_Punch_basestun",
                    "OUTCOMEMORIES_N_Knuckles_Punch_basedamage",
                    "OUTCOMEMORIES_N_Knuckles_Counter_useable",
                    "OUTCOMEMORIES_N_Knuckles_Counter_canragdollstun",
                    "OUTCOMEMORIES_N_Knuckles_Counter_cooldownSucess",
                    "OUTCOMEMORIES_N_Knuckles_Counter_cooldownFail",
                    "OUTCOMEMORIES_N_Knuckles_Counter_basestun",
                    "OUTCOMEMORIES_N_Knuckles_Counter_basedamage",
                    "OUTCOMEMORIES_N_Knuckles_latch_useable",
                    "OUTCOMEMORIES_N_Knuckles_Latch_duration",
                    "OUTCOMEMORIES_N_Knuckles_Glide_duration",
                    "OUTCOMEMORIES_N_Knuckles_latchcount",
                    "OUTCOMEMORIES_N_Knuckles_Punch_canragdollstun",
                    "OUTCOMEMORIES_N_Knuckles_Punch_cancharge",
                    "OUTCOMEMORIES_N_Knuckles_Punch_chargetime1",
                    "OUTCOMEMORIES_N_Knuckles_Punch_chargetime2",
                    "OUTCOMEMORIES_N_Knuckles_Punch_damageamount1",
                    "OUTCOMEMORIES_N_Knuckles_Punch_damageamount2",
                    "OUTCOMEMORIES_N_Knuckles_Punch_stunamount1",
                    "OUTCOMEMORIES_N_Knuckles_Punch_stunamount2"
                },
                name = "Knuckles",
            }
        })

        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        -- health related stuff
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_Knuckles_Health",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_Knuckles_Resistance",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 500,
                dec = 1,
                default = 100,
            }
        })

        -- speed
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["walk_speed"],
            labelText = "Walk speed",
            convar = "OUTCOMEMEMORIES_N_Knuckles_walk",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["run_speed"],
            labelText = "Run speed",
            convar = "OUTCOMEMEMORIES_N_Knuckles_run",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 900,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Jump Power",
            convar = "OUTCOMEMEMORIES_N_Knuckles_jumppower",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 900,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Jump Cooldown",
            convar = "OUTCOMEMEMORIES_N_Knuckles_jumpcd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 2,
            }
        })


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Glide speed",
            convar = "OUTCOMEMEMORIES_N_Knuckles_glide",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 600,
                dec = 1,
                default = 325,
            }
        })
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "Enabled Punch",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_useable",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
            bioText = "THE FLAMES OF DISASTER!!!!!!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "Stun Stacking",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_stunstack",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
            bioText = "",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "Can Ragdoll Stun",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_canragdollstun",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
            bioText = "Slam or charge up that fire to ragdoll that bi-",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "Punch Cooldown",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_cooldown",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "Punch Cancel Cooldown",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_cooldown_cancel",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "Punch Base Stun",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_basestun",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 8,
                dec = 1,
                default = 4,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "Punch Base damage",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_basedamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 35,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "Can Charge",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_cancharge",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
            bioText = "",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "1st charge time",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_chargetime1",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "2nd charge time",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_chargetime2",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "1st damage amount",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_damageamount1",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "2nd damage amount",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_damageamount2",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "1st Stun Duration",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_stunamount1",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 3,
                default = 5,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_punch"],
            labelText = "2nd Stun Duration",
            convar = "OUTCOMEMORIES_N_Knuckles_Punch_stunamount2",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 3,
                default = 5,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        local ply = LocalPlayer()
        local input2 = ply:GetInfoNum("om_pills_action_Knuckles_Counter_key", KEY_T)
        local name = input.GetKeyName(input2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_counter"],
            labelText = "Enabled Counter",
            convar = "OUTCOMEMORIES_N_Knuckles_Counter_useable",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
            bioText = "Did you know you can parry any projectile or damage by pressing ".. name .." before get hurt?",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_counter"],
            labelText = "Can Ragdoll Stun",
            convar = "OUTCOMEMORIES_N_Knuckles_Counter_canragdollstun",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_counter"],
            labelText = "Counter Successfully hit Cooldown",
            convar = "OUTCOMEMORIES_N_Knuckles_Counter_cooldownSucess",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 23,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_counter"],
            labelText = "Counter failed hit Cooldown",
            convar = "OUTCOMEMORIES_N_Knuckles_Counter_cooldownFail",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 23,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_counter"],
            labelText = "Counter Base Stun",
            convar = "OUTCOMEMORIES_N_Knuckles_Counter_basestun",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 8,
                dec = 1,
                default = 4,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_OM_noodles_counter"],
            labelText = "Counter Base damage",
            convar = "OUTCOMEMORIES_N_Knuckles_Counter_basedamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 35,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_LatcSetting"],
            labelText = "Enabled Glide & Latch",
            convar = "OUTCOMEMORIES_N_Knuckles_latch_useable",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
            bioText = "How does he even glide",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_LatcSetting"],
            labelText = "Has latch Limit",
            convar = "OUTCOMEMORIES_N_Knuckles_latch_haslimit",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_LatcSetting"],
            labelText = "Latch duration",
            convar = "OUTCOMEMORIES_N_Knuckles_Latch_duration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 3,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_GlideSetting"],
            labelText = "Glide duration",
            convar = "OUTCOMEMORIES_N_Knuckles_Glide_duration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 3,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_LatcSetting"],
            labelText = "Latch limit",
            convar = "OUTCOMEMORIES_N_Knuckles_latchcount",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 3,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Glide speed",
            convar = "OUTCOMEMEMORIES_N_Knuckles_glide",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 600,
                dec = 1,
                default = 325,
            }
        })
        OM_RegisterResetButton_server(scroll, "Kncukles", "om_reset_knuckles")
    end)


    concommand.Add("om_amy_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Amy pill",
            ["Image"] = "pills/pill_om_amy.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["preset_icon_om"],
            labelText = "Presents",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'preset',
            presettable = {
                listofdefualtconvars = {
                    "OUTCOMEMEMORIES_N_Amy_Resistance",
                    "OUTCOMEMEMORIES_N_Amy_Health",
                    "OUTCOMEMEMORIES_N_Amy_walk",
                    "OUTCOMEMEMORIES_N_Amy_run",
                    "OUTCOMEMEMORIES_N_Amy_jumppower",
                    "OUTCOMEMEMORIES_N_Amy_jumpcd",
                    "OUTCOMEMEMORIES_N_Amy_rollingPower",
                    "OUTCOMEMEMORIES_N_Amy_Hammer_useable",
                    "OUTCOMEMEMORIES_N_Amy_Hammer_stunstack",
                    "OUTCOMEMEMORIES_N_Amy_Hammer_cd",
                    "OUTCOMEMEMORIES_N_Amy_Hammer_dur",
                    "OUTCOMEMEMORIES_N_Amy_Hammer_Stun_dur",
                    "OUTCOMEMEMORIES_N_Amy_Hammer_Stun_damage",
                    "OUTCOMEMEMORIES_N_Amy_Throw_useable",
                    "OUTCOMEMEMORIES_N_Amy_Throw_stunstack",
                    "OUTCOMEMEMORIES_N_Amy_Hammer_ragdollstun",
                    "OUTCOMEMEMORIES_N_Amy_Throw_ragdollstun",
                    "OUTCOMEMEMORIES_N_Amy_Throw_cd",
                    "OUTCOMEMORIES_N_Amy_Throw_cd_cancel",
                    "OUTCOMEMORIES_N_Amy_Throw_Stun_dur",
                    "OUTCOMEMORIES_N_Amy_Throw_Stun_damage",
                    "OUTCOMEMORIES_N_Amy_CardSwap_useable",
                    "OUTCOMEMORIES_N_Amy_CardSwap_cd",
                    "OUTCOMEMORIES_N_Amy_0_1_damage_reduction",
                    "OUTCOMEMORIES_N_Amy_0_2_damage_reduction",
                    "OUTCOMEMORIES_N_Amy_1_damage_reduction",
                    "OUTCOMEMORIES_N_Amy_2_damage_reduction",
                    "OUTCOMEMORIES_N_Amy_3_damage_reduction",
                    "OUTCOMEMORIES_N_Amy_4_damage_reduction",
                    "OUTCOMEMORIES_N_Amy_5_damage_reduction",
                    "OUTCOMEMORIES_N_Amy_0_stunduration",
                    "OUTCOMEMORIES_N_Amy_1_stunduration",
                    "OUTCOMEMORIES_N_Amy_2_stunduration",
                    "OUTCOMEMORIES_N_Amy_3_stunduration",
                    "OUTCOMEMORIES_N_Amy_4_stunduration",
                    "OUTCOMEMORIES_N_Amy_5_stunduration",
                    "OUTCOMEMORIES_N_Amy_0_1_speed",
                    "OUTCOMEMORIES_N_Amy_0_2_speed",
                    "OUTCOMEMORIES_N_Amy_1_speed",
                    "OUTCOMEMORIES_N_Amy_2_speed",
                    "OUTCOMEMORIES_N_Amy_3_speed",
                    "OUTCOMEMORIES_N_Amy_4_speed",
                    "OUTCOMEMORIES_N_Amy_5_speed",
                    "OUTCOMEMORIES_N_Amy_1_healing",
                    "OUTCOMEMORIES_N_Amy_1_healAmount",
                    "OUTCOMEMORIES_N_Amy_1_healLimit",
                    "OUTCOMEMORIES_N_Amy_1_healspeed",
                },
                name = "Amy",
            }
        })

        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_Amy_Health",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_Amy_Resistance",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 500,
                dec = 1,
                default = 100,
            }
        })

        -- speed
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["walk_speed"],
            labelText = "Walk speed",
            convar = "OUTCOMEMEMORIES_N_Amy_walk",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 1,
                max = 500,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["run_speed"],
            labelText = "Run speed",
            convar = "OUTCOMEMEMORIES_N_Amy_run",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 900,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Jump Power",
            convar = "OUTCOMEMEMORIES_N_Amy_jumppower",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 900,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Jump Cooldown",
            convar = "OUTCOMEMEMORIES_N_Amy_jumpcd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 2,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Rolling Power",
            convar = "OUTCOMEMEMORIES_N_Amy_rollingPower",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 5000,
                dec = 1,
                default = 400,
            }
        })

        -- hammer stats
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Enabled Hammer",
            convar = "OUTCOMEMEMORIES_N_Amy_Hammer_useable",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "Bonk!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Stun stacking",
            convar = "OUTCOMEMEMORIES_N_Amy_Hammer_stunstack",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Can ragdoll Stun",
            convar = "OUTCOMEMEMORIES_N_Amy_Hammer_ragdollstun",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "Bounce that flowr!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Hammer cooldown",
            convar = "OUTCOMEMEMORIES_N_Amy_Hammer_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Hammer Duration",
            convar = "OUTCOMEMEMORIES_N_Amy_Hammer_dur",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 8,
                dec = 1,
                default = 2,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Hammer Base Stun",
            convar = "OUTCOMEMEMORIES_N_Amy_Hammer_Stun_dur",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 8,
                dec = 1,
                default = 3,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Hammer Base Damage",
            convar = "OUTCOMEMEMORIES_N_Amy_Hammer_Stun_damage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 26,
                dec = 1,
                default = 13,
            }
        })

        -- throw stats
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Enabled Throw",
            convar = "OUTCOMEMEMORIES_N_Amy_Throw_useable",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "Shit, i missed.",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Stun Stacking",
            convar = "OUTCOMEMEMORIES_N_Amy_Throw_stunstack",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Can ragdoll Stun",
            convar = "OUTCOMEMEMORIES_N_Amy_Throw_ragdollstun",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "GET GOOD AIM!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Throw cooldown",
            convar = "OUTCOMEMEMORIES_N_Amy_Throw_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 24,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Throw cancel cooldown",
            convar = "OUTCOMEMORIES_N_Amy_Throw_cd_cancel",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 5,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Hammer Base Stun",
            convar = "OUTCOMEMORIES_N_Amy_Throw_Stun_dur",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 8,
                dec = 1,
                default = 3,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Hammer Base Damage",
            convar = "OUTCOMEMORIES_N_Amy_Throw_Stun_damage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 26,
                dec = 1,
                default = 13,
            }
        })

        -- cards stats
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Enabled Cardswap",
            convar = "OUTCOMEMORIES_N_Amy_CardSwap_useable",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "Always bet on sun card",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Cardswap Cooldown",
            convar = "OUTCOMEMORIES_N_Amy_CardSwap_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 32,
                dec = 1,
                default = 18,
            }
        })
        --om_RegisterKeyrowom_RegisterKeyrow
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Moon Stun Duration",
            convar = "OUTCOMEMORIES_N_Amy_0_stunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Moon 1 Damage Reduction",
            convar = "OUTCOMEMORIES_N_Amy_0_1_damage_reduction",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Moon 2 Damage Reduction",
            convar = "OUTCOMEMORIES_N_Amy_0_2_damage_reduction",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Moon Speed 1",
            convar = "OUTCOMEMORIES_N_Amy_0_1_speed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Moon Speed 2",
            convar = "OUTCOMEMORIES_N_Amy_0_2_speed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })
--
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Emperor Stun Duration",
            convar = "OUTCOMEMORIES_N_Amy_2_stunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Emperor Damage Reduction",
            convar = "OUTCOMEMORIES_N_Amy_2_damage_reduction",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Emperor Speed",
            convar = "OUTCOMEMORIES_N_Amy_2_speed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })
--
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Strength Stun Duration",
            convar = "OUTCOMEMORIES_N_Amy_3_stunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Strength Damage Reduction",
            convar = "OUTCOMEMORIES_N_Amy_3_damage_reduction",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Strength Speed",
            convar = "OUTCOMEMORIES_N_Amy_3_speed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })
    --
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "World Stun Duration",
            convar = "OUTCOMEMORIES_N_Amy_4_stunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "World Damage Reduction",
            convar = "OUTCOMEMORIES_N_Amy_4_damage_reduction",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "World Speed",
            convar = "OUTCOMEMORIES_N_Amy_4_speed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })
    --
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Fool Stun Duration",
            convar = "OUTCOMEMORIES_N_Amy_5_stunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Fool Damage Reduction",
            convar = "OUTCOMEMORIES_N_Amy_5_damage_reduction",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Fool Character Speed",
            convar = "OUTCOMEMORIES_N_Amy_5_speed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })
        --
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Sun card Healing",
            convar = "OUTCOMEMORIES_N_Amy_1_healing",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Heal amount",
            convar = "OUTCOMEMORIES_N_Amy_1_healAmount",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 32,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Heal maximum",
            convar = "OUTCOMEMORIES_N_Amy_1_healLimit",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Heal Speed",
            convar = "OUTCOMEMORIES_N_Amy_1_healspeed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 195,
                dec = 1,
                default = 18,
            }
        })
        
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Sun Card Stun Duration",
            convar = "OUTCOMEMORIES_N_Amy_1_stunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Sun Card Damage Reduction",
            convar = "OUTCOMEMORIES_N_Amy_1_damage_reduction",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_cardshuffle"],
            labelText = "Sun Card Character Speed",
            convar = "OUTCOMEMORIES_N_Amy_1_speed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = -195,
                max = 195,
                dec = 1,
                default = 18,
            }
        })

        OM_RegisterResetButton_server(scroll, "Amy", "om_reset_amy")

    end)

    concommand.Add("om_metalSonic_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Metal Sonic pill",
            ["Image"] = "pills/pill_om_metalsonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        topImage.Think = function(self)
            local speed = 1.5
        
            local wave = (math.sin(CurTime() * speed) + 1) / 2

            local r = Lerp(wave, 255, 0)
            local g = 255
            local b = Lerp(wave, 255, 0)

            self:SetImageColor(Color(r, g, b))
        end

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["preset_icon_om"],
            labelText = "Presents",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'preset',
            presettable = {
                listofdefualtconvars = {
                    "OUTCOMEMEMORIES_N_MetalSonic_Resistance",
                    "OUTCOMEMEMORIES_N_MetalSonic_Health",
                    "OUTCOMEMORIES_N_MetalSonic_radar",
                    "OUTCOMEMEMORIES_N_MetalSonic_walk",
                    "OUTCOMEMEMORIES_N_MetalSonic_run",
                    "OUTCOMEMEMORIES_N_MetalSonic_jumppower",
                    "OUTCOMEMEMORIES_N_MetalSonic_Charging",
                    "OUTCOMEMEMORIES_N_MetalSonic_jumpcd",
                    "OUTCOMEMEMORIES_N_MetalSonic_rollingPower",
                    "OUTCOMEMORIES_N_MetalSonic_charge_useable",
                    "OUTCOMEMORIES_N_MetalSonic_charge_slippery",
                    "OUTCOMEMORIES_N_MetalSonic_charge_stunstack",
                    "OUTCOMEMORIES_N_MetalSonic_charge_cooldownSucess",
                    "OUTCOMEMORIES_N_MetalSonic_charge_MetalSelfDamageTick",
                    "OUTCOMEMORIES_N_MetalSonic_charge_DamageTick",
                    "OUTCOMEMORIES_N_MetalSonic_charge_slamDamage",
                    "OUTCOMEMORIES_N_MetalSonic_charge_MetalSelfDamageSlam",
                    "OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_tic",
                    "OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_slam",
                    "OUTCOMEMORIES_N_MetalSonic_charge_Duration",
                    "OUTCOMEMORIES_N_MetalSonic_heal_useable",
                    "OUTCOMEMORIES_N_MetalSonic_heal_cooldownSucess",
                    "OUTCOMEMORIES_N_MetalSonic_heal_healamount"
                },
                name = "Metal Sonic",
            }

        })

        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        -- health related stuff
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_MetalSonic_Health",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_MetalSonic_Resistance",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 500,
                dec = 1,
                default = 100,
            }
        })

        -- passive
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Enabled Radar",
            convar = "OUTCOMEMORIES_N_MetalSonic_radar",
            color = Color(0, 0, 175, 180),
            vartype = "bool",
            isexe = false,
            bioText = "",
        })

        -- speed
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["walk_speed"],
            labelText = "Walk speed",
            convar = "OUTCOMEMEMORIES_N_MetalSonic_walk",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["run_speed"],
            labelText = "Run speed",
            convar = "OUTCOMEMEMORIES_N_MetalSonic_run",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 600,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Jump Power",
            convar = "OUTCOMEMEMORIES_N_MetalSonic_jumppower",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 900,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Jump Cooldown",
            convar = "OUTCOMEMEMORIES_N_MetalSonic_jumpcd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 2,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Rolling Power",
            convar = "OUTCOMEMEMORIES_N_MetalSonic_rollingPower",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 5000,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Charge speed",
            convar = "OUTCOMEMEMORIES_N_MetalSonic_Charging",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 6000,
                dec = 1,
                default = 325,
            },
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
    
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Enabled Charging",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_useable",
            color = Color(0, 0, 175, 180),
            vartype = "bool",
            isexe = false,
            bioText = "SONIC. DEAD OR ALIVE. IS M- M- MINE",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Slipperiness",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_slippery",
            color = Color(0, 0, 175, 180),
            vartype = "bool",
            isexe = false,
            bioText = "SONIC. DEAD OR ALIVE. IS M- M- MINE",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Stun Stacking",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_stunstack",
            color = Color(0, 0, 175, 180),
            vartype = "bool",
            isexe = false,
            bioText = "",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Charge Cooldown",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_cooldownSucess",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 32,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Self Damage on Tick",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_MetalSelfDamageTick",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 32,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Damage on tick",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_DamageTick",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 32,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Slam Damage",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_slamDamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Self Slam Damage",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_MetalSelfDamageSlam",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 32,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "+ Stun on tick",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_tic",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 5,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "+ Slam Stun",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_additionalstun_slam",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 32,
                dec = 1,
                default = 18,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_charge"],
            labelText = "Charge duration",
            convar = "OUTCOMEMORIES_N_MetalSonic_charge_Duration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 32,
                dec = 1,
                default = 18,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })
    
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_heal"],
            labelText = "Enabled Heal",
            convar = "OUTCOMEMORIES_N_MetalSonic_heal_useable",
            color = Color(0, 0, 175, 180),
            vartype = "bool",
            isexe = false,
            bioText = "Pray for the exe not being round the corner",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_heal"],
            labelText = "Heal Success",
            convar = "OUTCOMEMORIES_N_MetalSonic_heal_cooldownSucess",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 32,
                dec = 1,
                default = 18,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Metal_OM_noodles_heal"],
            labelText = "Heal Amount",
            convar = "OUTCOMEMORIES_N_MetalSonic_heal_healamount",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 32,
                dec = 1,
                default = 18,
            }
        })
        OM_RegisterResetButton_server(scroll, "Metal Sonic", "om_reset_metalsonic")
    end)
end

-- SERVER register

Register_OMSettings({
    Name = "Sonic Server settings",
    Command = "om_sonic_server_pill_command",
    Color = Color(0, 150, 255),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_sonic.png"
})
Register_OMSettings({
    Name = "Knuckles Server settings",
    Command = "om_knuckles_server_pill_command",
    Color = Color(255, 0, 0),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_knuckles.png"
})
Register_OMSettings({
    Name = "Amy Server settings",
    Command = "om_amy_server_pill_command",
    Color = Color(255, 65, 255),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_amy.png"
})
Register_OMSettings({
    Name = "Metal Server settings",
    Command = "om_metalSonic_server_pill_command",
    Color = Color(0, 0, 175),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_metalsonic.png"
})
Register_OMSettings({
    Name = "Fleetway Server settings",
    Command = "om_fleetway_server_pill_command",
    Color = Color(255, 255, 0),
    TableType = "Killer", 
    ServerOrClient = true,
    Image = "pills/pill_om_fleetway.png"
})

-- client register

Register_OMSettings({
    Name = "Sonic client settings",
    Command = "om_sonic_pill_command",
    Color = Color(0, 150, 255),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_sonic.png"
})
Register_OMSettings({
    Name = "Knuckles client settings",
    Command = "om_knuckles_pill_command",
    Color = Color(255, 0, 0),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_knuckles.png"
})
Register_OMSettings({
    Name = "Amy client settings",
    Command = "om_amy_pill_command",
    Color = Color(255, 65, 255),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_amy.png"
})
Register_OMSettings({
    Name = "Metal client settings",
    Command = "om_metalSonic_pill_command",
    Color = Color(0, 0, 175),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_metalsonic.png"
})
Register_OMSettings({
    Name = "Fleetway Client settings",
    Command = "om_fleetway_pill_command",
    Color = Color(255, 255, 0),
    TableType = "Killer", 
    ServerOrClient = false,
    Image = "pills/pill_om_fleetway.png"
})