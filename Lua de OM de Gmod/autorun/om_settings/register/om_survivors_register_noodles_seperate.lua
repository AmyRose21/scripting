if true then return end
AddCSLuaFile()


if SERVER then

    -- Rouge convar group
    CreateConVar("OUTCOMEMEMORIES_N_rouge_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_Health", 125, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_passivereduction", 90, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_rouge_walk", 60, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_run", 410, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_rollingPower", 1400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_speed", 550, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_launchy_power", 700, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_canuse_smokebomb", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_cd", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_slowdownduration", 6, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_reward", 20, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_canuse_sweepkick", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_chargeup", 0.35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_miss", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_hit", 28, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_damageamouunt", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_basestun", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_canstunstack", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_canragdoll", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_reward", 30, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_starter", 30, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_maximum", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_regen", 17, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_latches_maximum", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_latch_energydrain", 0.35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_latch_jump_energydrain", 15, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_maximum", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_energydrain", 16, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_cdperjump", 6, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_rouge", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_rouge_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_Health"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passivereduction"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_rollingPower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_speed"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_launchy_power"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_rouge_canuse_smokebomb"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_slowdownduration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_reward"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_rouge_canuse_sweepkick"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_chargeup"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_duration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_miss"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_hit"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_damageamouunt"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_basestun"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_canstunstack"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_canragdoll"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_reward"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_starter"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_maximum"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_regen"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_latches_maximum"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_latch_energydrain"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_latch_jump_energydrain"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_maximum"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_energydrain"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_cdperjump"):Revert()
    end)



    -- Shadow convar group
    CreateConVar("OUTCOMEMEMORIES_N_shadow_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_Health", 165, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_shadow_walk", 40, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_run", 410, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_rollingPower", 1400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_charge", 1000, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_shadow_CanUseGun", 1, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMEMORIES_N_shadow_aim_cd", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_aim_canparry", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_aim_bulletdamage", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_aim_bulletamounttillstun", 6, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_aim_stundamage", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_aim_baseduration", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_aim_canstunstack", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_aim_canragdoll", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_reload_cd", 2.5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_reload_canparry", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_reload_bulletsreload", 6, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_reload_reloads", 3, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_shadow_CanDashBoost", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_DashBoost_Duration", 1, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_shadow_CanChaosSnap", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_ChaosSnap_cd", 20, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_ChaosSnap_miss_cd", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_stundamage", 7, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_baseduration", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_canstunstack", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_canragdoll", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_windup", 0.65, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_shadow", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_shadow_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_Health"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_rollingPower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_charge"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_CanUseGun"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_aim_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_aim_canparry"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_aim_bulletdamage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_aim_bulletamounttillstun"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_aim_stundamage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_aim_baseduration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_aim_canstunstack"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_aim_canragdoll"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_reload_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_reload_canparry"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_reload_bulletsreload"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_reload_reloads"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_CanDashBoost"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_DashBoost_Duration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_CanChaosSnap"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_ChaosSnap_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_ChaosSnap_miss_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_stundamage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_baseduration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_canstunstack"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_canragdoll"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_shadow_chaoscontrol_windup"):Revert()
    end)

    -- Mighty convar group
    CreateConVar("OUTCOMEMEMORIES_N_mighty_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_Health", 135, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_mighty_passivereduction", 75, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_mighty_walk", 60, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_run", 420, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_rollingPower", 1400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_charge", 1450, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_mighty_canusevoiceline", 1, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMORIES_N_mighty_cover_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_cover_cd_start", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_cover_cd_cancel", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_cover_reduction", 15, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd", 20, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd_hit", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_stunduration", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_stunstacking", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_canragdoll", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_stundamage", 25, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_cd", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stunduration", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stunstacking", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_canragdoll", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stundamage", 25, FCVAR_ARCHIVE, "", 0, 1e9)


    concommand.Add("om_reset_mighty", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_mighty_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_mighty_Health"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_mighty_passivereduction"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_mighty_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_mighty_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_mighty_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_mighty_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_mighty_rollingPower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_mighty_charge"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_canusevoiceline"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_cover_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_start"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_cancel"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_cover_reduction"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd_hit"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_stunstacking"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_canragdoll"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_cd"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stunstacking"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_canragdoll"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stundamage"):Revert()
    end)

    -- Tails convar group
    CreateConVar("OUTCOMEMEMORIES_N_tails_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_tails_Health", 100, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_tails_walk", 60, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_tails_run", 412, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_tails_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_tails_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_tails_rollingPower", 1500, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_tails_glide_Horizontalspeed", 300, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_tails_glide_Verticalspeed", 90, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_tails_laser_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_cd", 30, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_cancel_cd", 14, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_tails_laser_canragdollstun_laser", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_stunstack_laser", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_basestun_laser", 8, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_basedamage_laser", 6, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_tails_laser_canragdollstun_burst", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_stunstack_burst", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_basestun_burst", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_basedamage_burst", 10, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_tails_laser_canragdollstun_orbs", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_stunstack_orbs", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_basestun_orbs", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_tails_laser_basedamage_orbs", 10, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_tails_glide_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_glidecd_expire", 32, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_tails_glidecd_cancel", 17, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_tails_glide_duration", 10, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_tails_Toggle_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_Toggle_laser_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_Toggle_burst_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_Toggle_orbs_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_Toggle_shockwave_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_tails_togglecd", 0.5, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_tails", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end
        
        GetConVar("OUTCOMEMEMORIES_N_tails_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_tails_Health"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_tails_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_tails_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_tails_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_tails_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_tails_rollingPower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_tails_glide_Horizontalspeed"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_tails_glide_Verticalspeed"):Revert()

        GetConVar("OUTCOMEMORIES_N_tails_laser_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_cd"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_cancel_cd"):Revert()

        GetConVar("OUTCOMEMORIES_N_tails_laser_canragdollstun_laser"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_stunstack_laser"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_basestun_laser"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_basedamage_laser"):Revert()
        
        GetConVar("OUTCOMEMORIES_N_tails_laser_canragdollstun_burst"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_stunstack_burst"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_basestun_burst"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_basedamage_burst"):Revert()
        
        GetConVar("OUTCOMEMORIES_N_tails_laser_canragdollstun_orbs"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_stunstack_orbs"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_basestun_orbs"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_laser_basedamage_orbs"):Revert()
        
        GetConVar("OUTCOMEMORIES_N_tails_glide_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_glidecd_expire"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_glidecd_cancel"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_glide_duration"):Revert()

        GetConVar("OUTCOMEMORIES_N_tails_Toggle_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_Toggle_laser_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_Toggle_burst_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_Toggle_orbs_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_Toggle_shockwave_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_tails_togglecd"):Revert()
    end)

    -- Blaze convar group
    CreateConVar("OUTCOMEMEMORIES_N_blaze_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_blaze_Health", 100, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_blaze_maxSolflame", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_blaze_SolfalemOnSapwn", 0, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_blaze_walk", 60, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_blaze_run", 412, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_blaze_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_blaze_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_blaze_rollingPower", 1500, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_blaze_soldashspeed", 1400, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_blaze_kick_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_blaze_kick_stunstack", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_blaze_kick_cooldownmiss", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_kick_cooldownland", 17, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_kick_basestun", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_kick_basedamage", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_kick_canragdollstun", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_blaze_kick_solflamemeter", 35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_kick_solflamemeterSolflame", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_kick_solflamemeter_penalty", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_kick_canburn", 1, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMORIES_N_blaze_SolDash_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_blaze_SolDash_stunstack", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_blaze_SolDash_cooldownmiss", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_soldash_cooldownland", 17, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_SolDash_basestun", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_SolDash_basedamage", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_soldash_canragdollstun", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_blaze_SolDash_solflamemeter", 35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_SolDash_solflamemeterSolflame", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_SolDash_canburn", 1, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMORIES_N_blaze_javelin_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_blaze_javelin_cooldown", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_blaze_javelin_solflamemeter", 15, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_blaze_solflame_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_blaze_solflame_cooldown", 25, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_blaze", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_blaze_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_blaze_Health"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_blaze_maxSolflame"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_blaze_SolfalemOnSapwn"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_blaze_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_blaze_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_blaze_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_blaze_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_blaze_rollingPower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_blaze_soldashspeed"):Revert()

        GetConVar("OUTCOMEMORIES_N_blaze_kick_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_kick_stunstack"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_kick_cooldownmiss"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_kick_cooldownland"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_kick_basestun"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_kick_basedamage"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_kick_canragdollstun"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_kick_solflamemeter"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_kick_solflamemeterSolflame"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_kick_canburn"):Revert()

        GetConVar("OUTCOMEMORIES_N_blaze_SolDash_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_SolDash_stunstack"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_SolDash_cooldownmiss"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_SolDash_cooldownland"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_SolDash_basestun"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_SolDash_basedamage"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_SolDash_canragdollstun"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_SolDash_solflamemeter"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_SolDash_solflamemeterSolflame"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_SolDash_canburn"):Revert()

        GetConVar("OUTCOMEMORIES_N_blaze_javelin_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_javelin_cooldown"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_javelin_solflamemeter"):Revert()

        GetConVar("OUTCOMEMORIES_N_blaze_solflame_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_blaze_solflame_cooldown"):Revert()
    end)

    -- Kolossos's convars group
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_HasHealth", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_Health", 670, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_walk", 80, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_run", 550, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_jumpcd", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_charge", 1400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_grab", 1750, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_Damage", 55, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeImpaleDamage", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_slamDamage", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_grabdamage", 20, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_CanCharge", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeDuration", 7, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeCooldown", 22, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_ImapleChargeDuration", 3.75, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeNoConotrolDuration", 5, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_CanGrab", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_CanCancelGrab", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_GrabCooldown", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_PunchesLeft", 3, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_CanIndicator", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_IndicatorDuration", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_IndicatorCooldown", 14, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_CanBlock", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_BlockCooldown", 14, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_CanClimb", 1, FCVAR_ARCHIVE, "", 0, 1)

    concommand.Add("om_reset_kolossos", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_HasHealth"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_Health"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_charge"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_grab"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_Damage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeImpaleDamage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_slamDamage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_grabdamage"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanCharge"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeDuration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeCooldown"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ImapleChargeDuration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_ChargeNoConotrolDuration"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanGrab"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanCancelGrab"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_GrabCooldown"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_PunchesLeft"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanIndicator"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_IndicatorDuration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_IndicatorCooldown"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanBlock"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_BlockCooldown"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanClimb"):Revert()
    end)

    -- Lilith's convars group
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_HasHealth", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_Health", 1999, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Lilith_walk", 70, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_run", 545, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_jumpcd", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_chargedash", 1400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_ChargedashCharge", 900, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Lilith_Damage", 35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashDamage", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_puddledamage", 8, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_PulseImage_damage", 10, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDash_canuse", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDash_slipperiness", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashCd", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashDuration", 10, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama_CD", 15, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Lilith_PulseImage", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_PulseImage_cd_in", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_PulseImage_cd_out", 10, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_Lilith", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_Lilith_HasHealth"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_Health"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Lilith_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_charge"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_grab"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_chargedash"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargedashCharge"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Lilith_Damage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashDamage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_puddledamage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_PulseImage_damage"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDash_slipperiness"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashCd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashDuration"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama_CD"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_Lilith_PulseImage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_PulseImage_cd_in"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_PulseImage_cd_out"):Revert()
    end)


    -- Fang convar group
    CreateConVar("OUTCOMEMEMORIES_N_fang_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_fang_Health", 100, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_fang_walk", 60, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_fang_run", 412, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_fang_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_fang_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_fang_rollingPower", 2500, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_fang_gun_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_stunstack", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_canragdoll", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_leftgun_cd", 10, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_rightgun_cd", 10, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_damage", 7, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_stunduration", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_togglecd", 3, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_fang_bounce_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_fang_bounce_stunstack", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_fang_bounce_canragdoll", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_fang_bounce_damage", 13, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_bounce_stunduration", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_bounce_cd_new", 20, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_bounce_velocitymultiplyer", 120, FCVAR_ARCHIVE, "", 0, 1e9)


    concommand.Add("om_reset_fang", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_fang_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_fang_Health"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_fang_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_fang_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_fang_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_fang_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_fang_rollingPower"):Revert()

        GetConVar("OUTCOMEMORIES_N_fang_gun_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_stunstack"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_canragdoll"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_leftgun_cd"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_rightgun_cd"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_damage"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_togglecd"):Revert()

        GetConVar("OUTCOMEMORIES_N_fang_bounce_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_bounce_stunstack"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_bounce_canragdoll"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_bounce_damage"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_bounce_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_bounce_cd_new"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_bounce_velocitymultiplyer"):Revert()
    end)



    -- eyx's convars group
    CreateConVar("OUTCOMEMEMORIES_N_eyx_HasHealth", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Health", 565, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_eyx_walk", 80, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_run", 470, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_jumpcd", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_slamdunkgrab", 1350, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_chargerun", 650, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_chargewalk", 350, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage", 30, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_frenzy", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_screech", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_screech_slam", 45, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_slamdunk", 35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_slamdunk_area", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_infection", 20, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_infection_leap", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_eyx_CanLeap", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Leap_cd", 13, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Leap_hitwall_cd", 13, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_eyx_CanSlamDunk", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_cd", 27, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_hit_cd", 18, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_eyx_CanScreech", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Screech_cd", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_eyx_CanInfection", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Infection_cd", 10, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_eyx", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_eyx_HasHealth"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Health"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_eyx_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_slamdunkgrab"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_chargerun"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_chargewalk"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_eyx_Damage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_frenzy"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_screech"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_screech_slam"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_slamdunk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_slamdunk_area"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_infection"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_infection_leap"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_eyx_CanLeap"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Leap_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Leap_hitwall_cd"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_eyx_CanSlamDunk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_hit_cd"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_eyx_CanScreech"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Screech_cd"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_eyx_CanInfection"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Infection_cd"):Revert()
    end)


end

if CLIENT then
    CreateClientConVar("om_pills_action_lilith_ChargeDash", KEY_E, true, true, "Lilith charge keybind")
    CreateClientConVar("om_pills_action_lilith_BluntTruama", KEY_R, true, true, "Lilith blunt truama keybind")
    CreateClientConVar("om_pills_action_lilith_PulseImage", KEY_T, true, true, "Lilith pulse image keybind")
    CreateClientConVar("om_pills_action_camera_lilith", 1, true, true, "Camera Toggle is activated by abilities for Lilith")

    CreateClientConVar("om_pills_action_kolossos_charge_key", KEY_E, true, true, "kolossos charge keybind")
    CreateClientConVar("om_pills_action_kolossos_grab_key", KEY_R, true, true, "kolossos grab keybind")
    CreateClientConVar("om_pills_action_kolossos_indicator_key", KEY_T, true, true, "kolossos indicator keybind")
    CreateClientConVar("om_pills_action_kolossos_block_key", KEY_I, true, true, "kolossos block keybind")
    CreateClientConVar("om_pills_action_camera_kolossos", 1, true, true, "Camera Toggle is activated by abilities for kolossos")

    CreateClientConVar("om_pills_action_blaze_abillty1_key", KEY_E, true, true, "blaze ability1 keybind")
    CreateClientConVar("om_pills_action_blaze_abillty2_key", KEY_R, true, true, "blaze ability2 keybind")
    CreateClientConVar("om_pills_action_camera_blaze", 1, true, true, "Camera Toggle is activated by abilities for blaze")

    CreateClientConVar("om_pills_action_tails_laser_key", KEY_E, true, true, "Tails Laser keybind")
    CreateClientConVar("om_pills_action_tails_glide_key", KEY_R, true, true, "Tails Glide keybind")
    CreateClientConVar("om_pills_action_tails_toggle_key", KEY_T, true, true, "Tails Toggle keybind")
    CreateClientConVar("om_pills_action_camera_tails", 1, true, true, "Camera Toggle is activated by abilities for Tails")

    CreateClientConVar("om_pills_action_fang_gun_key", KEY_E, true, true, "Fang Gun keybind")
    CreateClientConVar("om_pills_action_fang_bounce_key", KEY_T, true, true, "Fang Bounce keybind")
    CreateClientConVar("om_pills_action_camera_fang", 1, true, true, "Camera Toggle is activated by abilities for Fang")

    CreateClientConVar("om_pills_action_mighty_TakeCover", KEY_E, true, true, "Mighty's cover keybind")
    CreateClientConVar("om_pills_action_mighty_ExponensialRam", KEY_R, true, true, "Mighty's ram keybind")
    CreateClientConVar("om_pills_action_mighty_BoulderThrow", KEY_T, true, true, "Mighty's boulder throw keybind")
    CreateClientConVar("om_pills_action_camera_mighty", 1, true, true, "Camera Toggle is activated by abilities for Mighty")

    CreateClientConVar("om_pills_action_eyx_leap_key", KEY_E, true, true, "eyx leap keybind")
    CreateClientConVar("om_pills_action_eyx_slamdunk_key", KEY_R, true, true, "eyx slamdunk keybind")
    CreateClientConVar("om_pills_action_eyx_screech_key", KEY_T, true, true, "eyx screech keybind")
    CreateClientConVar("om_pills_action_eyx_infection_key", KEY_I, true, true, "eyx infection keybind")
    CreateClientConVar("om_pills_action_camera_eyx", 1, true, true, "Camera Toggle is activated by abilities for eyx")


    CreateClientConVar("om_pills_action_shadow_ability_1_key", KEY_E, true, true, "Shadow Ability 1 keybind")
    CreateClientConVar("om_pills_action_shadow_ability_2_key", KEY_R, true, true, "Shadow Ability 2 keybind")
    CreateClientConVar("om_pills_action_camera_shadow", 1, true, true, "Camera Toggle is activated by abilities for Shadow")

    CreateClientConVar("om_pills_action_rouge_ability_1_key", KEY_E, true, true, "Shadow Ability 1 keybind")
    CreateClientConVar("om_pills_action_rouge_ability_2_key", KEY_R, true, true, "Shadow Ability 2 keybind")
    CreateClientConVar("om_pills_action_camera_rouge", 1, true, true, "Camera Toggle is activated by abilities for Rouge")




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


        ["Kolossos_hi"] = "icons/Kolossos_hi.png",
        ["KOLOSSOS_PUNCH"] = "icons/KOLOSSOS_PUNCH.png",
        ["kolossos_block"] = "icons/kolossos_block.png",
        ["kolossos_peek"] = "icons/kolossos_peek.png",

        ["Roundhouse_kick"] = "icons/Roundhouse kick.png",
        ["burning_javelin"] = "icons/burning javelin.png",

        ["tails_abilitycannon"] = "icons/tails_abilitycannon.png",
        ["tails_abilityfly"] = "icons/tails_abilityfly.png",
        ["shadow_icon_reload"] = "icons/shadow_icon_reload.png",

        ["Spinball_Lilith"] = "icons/Spinball_Lilith.png",
        ["blunt_trauma"] = "icons/blunt_trauma.png",
        ["Lilith_Indicator_Move_Thingy"] = "icons/Lilith_Indicator_Move_Thingy.png",

        ["fang_bounce_icon"] = "icons/fang_bounce_icon.png",
        ["fang_gun_icon"] = "icons/fang_gun_icon.png",

        ["Cover_Mighty_om"] = "icons/Cover_Mighty_om.png",
        ["Charge_Mighty_om"] = "icons/Charge_Mighty_om.png",
        ["BoulderMighty_om"] = "icons/BoulderMighty_om.png",

        ["shadow_icon_Aim"] = "icons/shadow_icon_Aim.png",
        ["shadow_icon_dash_boost"] = "icons/shadow_icon_dash_boost.png",
        ["shadow_icon_reload"] = "icons/shadow_icon_reload.png",
        ["shadow_icon_chaos_snap"] = "icons/shadow_icon_chaos_snap.png",

        ["rouge_kick_om"] = "icons/rouge_kick_om.png",
        ["rouge_smokebomb_om"] = "icons/rouge_smokebomb_om.png",
        ["rouge_energyicon"] = "icons/rouge_energyicon.png",
        ["Knuckles_LatcSetting"] = "icons/Knuckles_LatcSetting.png",
    }
                
    local KeyDefaults2 = {
        ["Kolossos"] = {
            om_pills_action_kolossos_charge_key = KEY_E,
            om_pills_action_kolossos_grab_key = KEY_R,
            om_pills_action_kolossos_indicator_key = KEY_T,
            om_pills_action_kolossos_block_key = KEY_I,
        },
        ["Blaze"] = {
            om_pills_action_blaze_abillty1_key = KEY_E,
            om_pills_action_blaze_abillty2_key = KEY_R,
        },
        ["Tails"] = {
            om_pills_action_tails_laser_key = KEY_E,
            om_pills_action_tails_glide_key = KEY_R,
            om_pills_action_tails_toggle_key = KEY_T,
        },
        ["Lilith"] = {
            om_pills_action_lilith_ChargeDash = KEY_E,
            om_pills_action_lilith_BluntTruama = KEY_R,
            om_pills_action_lilith_PulseImage = KEY_T,
        },
        ["Fang"] = {
            om_pills_action_fang_gun_key = KEY_E,
            om_pills_action_fang_bounce_key = KEY_T,
        },
        ["Mighty"] = {
            om_pills_action_mighty_TakeCover = KEY_E,
            om_pills_action_mighty_ExponensialRam = KEY_R,
            om_pills_action_mighty_BoulderThrow = KEY_T,
        },
        ["Shadow"] = {
            om_pills_action_shadow_ability_1_key = KEY_E,
            om_pills_action_shadow_ability_2_key = KEY_R,
        },
        ["Rouge"] = {
            om_pills_action_rouge_ability_1_key = KEY_E,
            om_pills_action_rouge_ability_2_key = KEY_R,
        },
    }

    concommand.Add("om_rouge_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Rouge pill",
            ["Image"] = "pills/pill_om_rouge.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_smokebomb_om"],
            labelText = "Flash Bang",
            convar = "om_pills_action_rouge_ability_1_key",
            color = Color(175, 155, 155, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Sweep Kick Keybind",
            convar = "om_pills_action_rouge_ability_2_key",
            color = Color(211, 155, 155, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Rouge", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_rouge",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = false,
        })
    end)

    concommand.Add("om_mighty_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Mighty pill",
            ["Image"] = "pills/pill_om_mighty.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Cover Keybind",
            convar = "om_pills_action_mighty_TakeCover",
            color = Color(175, 0, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Exponensial Ram Keybind",
            convar = "om_pills_action_mighty_ExponensialRam",
            color = Color(211, 0, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["BoulderMighty_om"],
            labelText = "Boulder Throw keybind",
            convar = "om_pills_action_mighty_BoulderThrow",
            color = Color(230, 0, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Mighty", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_mighty",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = false,
        })
    end)

    concommand.Add("om_fang_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Fang pill",
            ["Image"] = "pills/pill_om_fang.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Gun Keybind",
            convar = "om_pills_action_fang_gun_key",
            color = Color(175, 0, 175, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_bounce_icon"],
            labelText = "Bounce keybind",
            convar = "om_pills_action_fang_bounce_key",
            color = Color(211, 0, 211, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Fang", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_fang",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = false,
        })
    end)

    concommand.Add("om_lilith_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Lilith pill",
            ["Image"] = "pills/pill_om_lilith.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Spinball_Lilith"],
            labelText = "Charge Dash",
            convar = "om_pills_action_lilith_ChargeDash",
            color = Color(0, 175, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["blunt_trauma"],
            labelText = "Blunt Truama",
            convar = "om_pills_action_lilith_BluntTruama",
            color = Color(0, 211, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Lilith_Indicator_Move_Thingy"],
            labelText = "Pulse Image",
            convar = "om_pills_action_lilith_PulseImage",
            color = Color(0, 175, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Lilith", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_lilith",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = false,
        })
    end)


    concommand.Add("om_tails_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Tails pill",
            ["Image"] = "pills/pill_om_tails.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["tails_abilitycannon"],
            labelText = "Laser keybind",
            convar = "om_pills_action_tails_laser_key",
            color = Color(175, 175, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["tails_abilityfly"],
            labelText = "Glide keybind",
            convar = "om_pills_action_tails_glide_key",
            color = Color(211, 211, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Toggle keybind",
            convar = "om_pills_action_tails_toggle_key",
            color = Color(175, 175, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Tails", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_tails",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = false,
        })
    end)

    concommand.Add("om_blaze_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Blaze pill",
            ["Image"] = "pills/pill_om_blaze.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Kick / Sol Dash",
            convar = "om_pills_action_blaze_abillty1_key",
            color = Color(175, 0, 175, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["burning_javelin"],
            labelText = "Javelin / Solflame",
            convar = "om_pills_action_blaze_abillty2_key",
            color = Color(211, 0, 211, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Blaze", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_blaze",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = false,
        })
    end)

    concommand.Add("om_kolossos_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Kolossos pill",
            ["Image"] = "pills/pill_om_kolossos.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Charge",
            convar = "om_pills_action_kolossos_charge_key",
            color = Color(0, 0, 175, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["KOLOSSOS_PUNCH"],
            labelText = "Grab",
            convar = "om_pills_action_kolossos_grab_key",
            color = Color(0, 0, 211, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["kolossos_peek"],
            labelText = "Indicator",
            convar = "om_pills_action_kolossos_indicator_key",
            color = Color(0, 0, 135, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["kolossos_block"],
            labelText = "Block",
            convar = "om_pills_action_kolossos_block_key",
            color = Color(0, 0, 70, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Kolossos", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_kolossos",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = true,
        })
    end)

    
    concommand.Add("om_Shadow_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Shadow pill",
            ["Image"] = "pills/pill_om_Shadow.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Ability 1",
            convar = "om_pills_action_shadow_ability_1_key",
            color = Color(175, 0, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["burning_javelin"],
            labelText = "Ability 2",
            convar = "om_pills_action_shadow_ability_2_key",
            color = Color(211, 0, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Shadow", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_shadow",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = false,
        })
    end)
    
    concommand.Add("om_Shadow_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Shadow pill",
            ["Image"] = "pills/pill_om_shadow.png",
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
                    "OUTCOMEMEMORIES_N_shadow_Resistance",
                    "OUTCOMEMEMORIES_N_shadow_Health",
                    "OUTCOMEMEMORIES_N_shadow_walk",
                    "OUTCOMEMEMORIES_N_shadow_run",
                    "OUTCOMEMEMORIES_N_shadow_jumpcd",
                    "OUTCOMEMEMORIES_N_shadow_rollingPower",
                    "OUTCOMEMEMORIES_N_shadow_charge",
                    "OUTCOMEMEMORIES_N_shadow_CanUseGun",
                    "OUTCOMEMEMORIES_N_shadow_aim_cd",
                    "OUTCOMEMEMORIES_N_shadow_aim_canparry",
                    "OUTCOMEMEMORIES_N_shadow_aim_bulletdamage",
                    "OUTCOMEMEMORIES_N_shadow_aim_bulletamounttillstun",
                    "OUTCOMEMEMORIES_N_shadow_aim_stundamage",
                    "OUTCOMEMEMORIES_N_shadow_aim_baseduration",
                    "OUTCOMEMEMORIES_N_shadow_aim_canstunstack",
                    "OUTCOMEMEMORIES_N_shadow_aim_canragdoll",
                    "OUTCOMEMEMORIES_N_shadow_reload_cd",
                    "OUTCOMEMEMORIES_N_shadow_reload_canparry",
                    "OUTCOMEMEMORIES_N_shadow_reload_bulletsreload",
                    "OUTCOMEMEMORIES_N_shadow_reload_reloads",
                    "OUTCOMEMEMORIES_N_shadow_CanDashBoost",
                    "OUTCOMEMEMORIES_N_shadow_DashBoost_Duration",
                    "OUTCOMEMEMORIES_N_shadow_CanChaosSnap",
                    "OUTCOMEMEMORIES_N_shadow_ChaosSnap_cd",
                    "OUTCOMEMEMORIES_N_shadow_ChaosSnap_miss_cd",
                    "OUTCOMEMEMORIES_N_shadow_chaoscontrol_stundamage",
                    "OUTCOMEMEMORIES_N_shadow_chaoscontrol_baseduration",
                    "OUTCOMEMEMORIES_N_shadow_chaoscontrol_canstunstack",
                    "OUTCOMEMEMORIES_N_shadow_chaoscontrol_canragdoll",
                    "OUTCOMEMEMORIES_N_shadow_chaoscontrol_windup"
                },
                name = "Shadow",
            }
        })



        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_shadow_Health",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1370,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_shadow_Resistance",
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
            convar = "OUTCOMEMEMORIES_N_shadow_walk",
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
            convar = "OUTCOMEMEMORIES_N_shadow_run",
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
            convar = "OUTCOMEMEMORIES_N_shadow_jumppower",
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
            convar = "OUTCOMEMEMORIES_N_shadow_jumpcd",
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
            convar = "OUTCOMEMEMORIES_N_shadow_rollingPower",
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
            icon = preservedmats["shadow_icon_dash_boost"],
            labelText = "Dash Boost",
            convar = "OUTCOMEMEMORIES_N_shadow_charge",
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
            icon = preservedmats["shadow_icon_Aim"],
            labelText = "Can use Gun",
            convar = "OUTCOMEMEMORIES_N_shadow_CanUseGun",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_Aim"],
            labelText = "Can Parry",
            convar = "OUTCOMEMEMORIES_N_shadow_aim_canparry",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_Aim"],
            labelText = "Can Stun stack",
            convar = "OUTCOMEMEMORIES_N_shadow_aim_canstunstack",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_Aim"],
            labelText = "Can Ragdoll",
            convar = "OUTCOMEMEMORIES_N_shadow_aim_canragdoll",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_Aim"],
            labelText = "Aim cd",
            convar = "OUTCOMEMEMORIES_N_shadow_aim_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 5,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_Aim"],
            labelText = "Bullet Damage",
            convar = "OUTCOMEMEMORIES_N_shadow_aim_bulletdamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_Aim"],
            labelText = "Bullet Amount till stun",
            convar = "OUTCOMEMEMORIES_N_shadow_aim_bulletamounttillstun",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_Aim"],
            labelText = "Bullet stun damage",
            convar = "OUTCOMEMEMORIES_N_shadow_aim_stundamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 7,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Reload cd",
            convar = "OUTCOMEMEMORIES_N_shadow_reload_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 7,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Reload cd",
            convar = "OUTCOMEMEMORIES_N_shadow_reload_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 7,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Can Parry",
            convar = "OUTCOMEMEMORIES_N_shadow_reload_canparry",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Bullet reload count",
            convar = "OUTCOMEMEMORIES_N_shadow_reload_bulletsreload",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 12,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "reload count",
            convar = "OUTCOMEMEMORIES_N_shadow_reload_reloads",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 5,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_dash_boost"],
            labelText = "Can use Dash boost",
            convar = "OUTCOMEMEMORIES_N_shadow_CanDashBoost",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Dash boost duration",
            convar = "OUTCOMEMEMORIES_N_shadow_DashBoost_Duration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 5,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_chaos_snap"],
            labelText = "Can use Chaos Snap",
            convar = "OUTCOMEMEMORIES_N_shadow_CanChaosSnap",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_chaos_snap"],
            labelText = "Can use Stun Stack",
            convar = "OUTCOMEMEMORIES_N_shadow_chaoscontrol_canstunstack",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_chaos_snap"],
            labelText = "Can ragdoll",
            convar = "OUTCOMEMEMORIES_N_shadow_chaoscontrol_canragdoll",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_chaos_snap"],
            labelText = "cd",
            convar = "OUTCOMEMEMORIES_N_shadow_ChaosSnap_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_chaos_snap"],
            labelText = "Miss cd",
            convar = "OUTCOMEMEMORIES_N_shadow_ChaosSnap_miss_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_chaos_snap"],
            labelText = "Stun damage",
            convar = "OUTCOMEMEMORIES_N_shadow_chaoscontrol_stundamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 400,
            }
        })


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_chaos_snap"],
            labelText = "Stun Duration",
            convar = "OUTCOMEMEMORIES_N_shadow_chaoscontrol_baseduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 8,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_chaos_snap"],
            labelText = "Wind up",
            convar = "OUTCOMEMEMORIES_N_shadow_chaoscontrol_windup",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 2,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        OM_RegisterResetButton_server(scroll, "Shadow", "om_reset_shadow")

    end)

    concommand.Add("om_Fang_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Fang pill",
            ["Image"] = "pills/pill_om_fang.png",
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
                    "OUTCOMEMEMORIES_N_fang_Health",
                    "OUTCOMEMEMORIES_N_fang_Resistance",

                    "OUTCOMEMEMORIES_N_fang_walk",
                    "OUTCOMEMEMORIES_N_fang_run",
                    "OUTCOMEMEMORIES_N_fang_jumppower",
                    "OUTCOMEMEMORIES_N_fang_jumpcd",
                    "OUTCOMEMEMORIES_N_fang_rollingPower",

                    "OUTCOMEMORIES_N_fang_gun_useable",
                    "OUTCOMEMORIES_N_fang_gun_stunstack",
                    "OUTCOMEMORIES_N_fang_gun_canragdoll",
                    "OUTCOMEMORIES_N_fang_gun_leftgun_cd",
                    "OUTCOMEMORIES_N_fang_gun_rightgun_cd",
                    "OUTCOMEMORIES_N_fang_gun_damage",
                    "OUTCOMEMORIES_N_fang_gun_stunduration",
                    "OUTCOMEMORIES_N_fang_gun_togglecd",

                    "OUTCOMEMORIES_N_fang_bounce_useable",
                    "OUTCOMEMORIES_N_fang_bounce_stunstack",
                    "OUTCOMEMORIES_N_fang_bounce_canragdoll",
                    "OUTCOMEMORIES_N_fang_bounce_damage",
                    "OUTCOMEMORIES_N_fang_bounce_stunduration",
                    "OUTCOMEMORIES_N_fang_bounce_cd_new",
                    "OUTCOMEMORIES_N_fang_bounce_velocitymultiplyer"
                },
                name = "Fang",
            }
        })



        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_fang_Health",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1370,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_fang_Resistance",
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
            convar = "OUTCOMEMEMORIES_N_fang_walk",
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
            convar = "OUTCOMEMEMORIES_N_fang_run",
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
            convar = "OUTCOMEMEMORIES_N_fang_jumppower",
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
            convar = "OUTCOMEMEMORIES_N_fang_jumpcd",
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
            convar = "OUTCOMEMEMORIES_N_fang_rollingPower",
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
            icon = preservedmats["fang_gun_icon"],
            labelText = "Can use Gun",
            convar = "OUTCOMEMORIES_N_fang_gun_useable",
            color = Color(175, 35, 175, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Can Stun stack",
            convar = "OUTCOMEMORIES_N_fang_gun_stunstack",
            color = Color(175, 35, 175, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Can Ragdoll",
            convar = "OUTCOMEMORIES_N_fang_gun_canragdoll",
            color = Color(175, 35, 175, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Gun toggle duration",
            convar = "OUTCOMEMORIES_N_fang_gun_togglecd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Left Bullet reload cd",
            convar = "OUTCOMEMORIES_N_fang_gun_leftgun_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Right Bullet reload cd",
            convar = "OUTCOMEMORIES_N_fang_gun_rightgun_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Cork damage",
            convar = "OUTCOMEMORIES_N_fang_gun_damage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Cork Stun duration",
            convar = "OUTCOMEMORIES_N_fang_gun_stunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_bounce_icon"],
            labelText = "Can use Bounce",
            convar = "OUTCOMEMORIES_N_fang_bounce_useable",
            color = Color(175, 35, 175, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_bounce_icon"],
            labelText = "Can Stun stack",
            convar = "OUTCOMEMORIES_N_fang_bounce_stunstack",
            color = Color(175, 35, 175, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_bounce_icon"],
            labelText = "Can Ragdoll",
            convar = "OUTCOMEMORIES_N_fang_bounce_canragdoll",
            color = Color(175, 35, 175, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_bounce_icon"],
            labelText = "Bounce Damage",
            convar = "OUTCOMEMORIES_N_fang_bounce_damage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_bounce_icon"],
            labelText = "Bounce Stun duration",
            convar = "OUTCOMEMORIES_N_fang_bounce_stunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_bounce_icon"],
            labelText = "Bounce cd",
            convar = "OUTCOMEMORIES_N_fang_bounce_cd_new",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_bounce_icon"],
            labelText = "Bounce velocity multiplyer",
            convar = "OUTCOMEMORIES_N_fang_bounce_velocitymultiplyer",
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
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        OM_RegisterResetButton_server(scroll, "Fang", "om_reset_fang")

    end)

    concommand.Add("om_tails_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Tails pill",
            ["Image"] = "pills/pill_om_tails.png",
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
                    "OUTCOMEMEMORIES_N_tails_Resistance",
                    "OUTCOMEMEMORIES_N_tails_Health",
                    
                    "OUTCOMEMEMORIES_N_tails_walk",
                    "OUTCOMEMEMORIES_N_tails_run",
                    "OUTCOMEMEMORIES_N_tails_jumppower",
                    "OUTCOMEMEMORIES_N_tails_jumpcd",
                    "OUTCOMEMEMORIES_N_tails_rollingPower",
                    "OUTCOMEMEMORIES_N_tails_glide_Horizontalspeed",
                    "OUTCOMEMEMORIES_N_tails_glide_Verticalspeed",

                    "OUTCOMEMORIES_N_tails_laser_useable",
                    "OUTCOMEMORIES_N_tails_laser_cd",
                    "OUTCOMEMORIES_N_tails_laser_cancel_cd",

                    "OUTCOMEMORIES_N_tails_laser_canragdollstun_laser",
                    "OUTCOMEMORIES_N_tails_laser_stunstack_laser",
                    "OUTCOMEMORIES_N_tails_laser_basestun_laser",
                    "OUTCOMEMORIES_N_tails_laser_basedamage_laser",
                    
                    "OUTCOMEMORIES_N_tails_laser_canragdollstun_burst",
                    "OUTCOMEMORIES_N_tails_laser_stunstack_burst",
                    "OUTCOMEMORIES_N_tails_laser_basestun_burst",
                    "OUTCOMEMORIES_N_tails_laser_basedamage_burst",
                    
                    "OUTCOMEMORIES_N_tails_laser_canragdollstun_orbs",
                    "OUTCOMEMORIES_N_tails_laser_stunstack_orbs",
                    "OUTCOMEMORIES_N_tails_laser_basestun_orbs",
                    "OUTCOMEMORIES_N_tails_laser_basedamage_orbs",
                    
                    "OUTCOMEMORIES_N_tails_glide_useable",
                    "OUTCOMEMORIES_N_tails_glidecd_expire",
                    "OUTCOMEMORIES_N_tails_glidecd_cancel",
                    "OUTCOMEMORIES_N_tails_glide_duration",

                    "OUTCOMEMORIES_N_tails_Toggle_useable",
                    "OUTCOMEMORIES_N_tails_Toggle_laser_useable",
                    "OUTCOMEMORIES_N_tails_Toggle_burst_useable",
                    "OUTCOMEMORIES_N_tails_Toggle_orbs_useable",
                    "OUTCOMEMORIES_N_tails_Toggle_shockwave_useable",
                    "OUTCOMEMORIES_N_tails_togglecd",
                },
                name = "Tails",
            }
        })


        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_tails_Health",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1370,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_tails_Resistance",
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
            convar = "OUTCOMEMEMORIES_N_tails_walk",
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
            convar = "OUTCOMEMEMORIES_N_tails_run",
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
            convar = "OUTCOMEMEMORIES_N_tails_jumppower",
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
            convar = "OUTCOMEMEMORIES_N_tails_jumpcd",
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
            convar = "OUTCOMEMEMORIES_N_tails_rollingPower",
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
            icon = preservedmats["tails_abilityfly"],
            labelText = "Horizontal Glide Speed",
            convar = "OUTCOMEMEMORIES_N_tails_glide_Horizontalspeed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 500,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["tails_abilityfly"],
            labelText = "Vertical Glide Speed",
            convar = "OUTCOMEMEMORIES_N_tails_glide_Verticalspeed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 30,
                max = 150,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["tails_abilitycannon"],
            labelText = "Can use Cannon",
            convar = "OUTCOMEMORIES_N_tails_laser_useable",
            color = Color(175, 175, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["tails_abilityfly"],
            labelText = "Canon cd",
            convar = "OUTCOMEMORIES_N_tails_laser_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["tails_abilityfly"],
            labelText = "Canon cancel cd",
            convar = "OUTCOMEMORIES_N_tails_laser_cancel_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 25,
                dec = 1,
                default = 20,
            }
        })

        --

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilitycannon"],
            labelText = "Laser ragdolling",
            convar = "OUTCOMEMORIES_N_tails_laser_canragdollstun_laser",
            color = Color(35, 35, 175, 180), vartype = "bool", isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilitycannon"],
            labelText = "Laser Stun Stacking",
            convar = "OUTCOMEMORIES_N_tails_laser_stunstack_laser",
            color = Color(35, 35, 175, 180), vartype = "bool", isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilityfly"],
            labelText = "Laser Base Stun",
            convar = "OUTCOMEMORIES_N_tails_laser_basestun_laser",
            color = Color(80, 80, 175, 180), isexe = false, vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilityfly"],
            labelText = "Laser Base damage",
            convar = "OUTCOMEMORIES_N_tails_laser_basedamage_laser",
            color = Color(80, 80, 175, 180), isexe = false, vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 20,
            }
        })

        --

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilitycannon"],
            labelText = "Burst ragdolling",
            convar = "OUTCOMEMORIES_N_tails_laser_canragdollstun_burst",
            color = Color(35, 175, 35, 180), vartype = "bool", isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilitycannon"],
            labelText = "Burst Stun Stacking",
            convar = "OUTCOMEMORIES_N_tails_laser_stunstack_burst",
            color = Color(35, 175, 35, 180), vartype = "bool", isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilityfly"],
            labelText = "Burst Base Stun",
            convar = "OUTCOMEMORIES_N_tails_laser_basestun_burst",
            color = Color(80, 175, 80, 180), isexe = false, vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilityfly"],
            labelText = "Burst Base damage",
            convar = "OUTCOMEMORIES_N_tails_laser_basedamage_burst",
            color = Color(80, 175, 80, 180), isexe = false, vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 20,
            }
        })

        --

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilitycannon"],
            labelText = "Orbs ragdolling",
            convar = "OUTCOMEMORIES_N_tails_laser_canragdollstun_orbs",
            color = Color(175, 35, 35, 180), vartype = "bool", isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilitycannon"],
            labelText = "Orbs Stun Stacking",
            convar = "OUTCOMEMORIES_N_tails_laser_stunstack_orbs",
            color = Color(175, 35, 35, 180), vartype = "bool", isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilityfly"],
            labelText = "Orbs Base Stun",
            convar = "OUTCOMEMORIES_N_tails_laser_basestun_orbs",
            color = Color(175, 80, 80, 180), isexe = false, vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll, icon = preservedmats["tails_abilityfly"],
            labelText = "Orbs Base damage",
            convar = "OUTCOMEMORIES_N_tails_laser_basedamage_orbs",
            color = Color(175, 80, 80, 180), isexe = false, vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["tails_abilityfly"],
            labelText = "Can use Glide",
            convar = "OUTCOMEMORIES_N_tails_glide_useable",
            color = Color(175, 175, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["tails_abilityfly"],
            labelText = "Glide expire cd",
            convar = "OUTCOMEMORIES_N_tails_glidecd_expire",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 40,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["tails_abilityfly"],
            labelText = "Glide cancel cd",
            convar = "OUTCOMEMORIES_N_tails_glidecd_cancel",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 25,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["tails_abilityfly"],
            labelText = "Glide Duration",
            convar = "OUTCOMEMORIES_N_tails_glide_duration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 25,
                dec = 1,
                default = 20,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Can use Toggle",
            convar = "OUTCOMEMORIES_N_tails_Toggle_useable",
            color = Color(175, 175, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Can swap to Laser mode",
            convar = "OUTCOMEMORIES_N_tails_Toggle_laser_useable",
            color = Color(35, 35, 175, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Can swap to Burst mode",
            convar = "OUTCOMEMORIES_N_tails_Toggle_burst_useable",
            color = Color(35, 175, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Can swap to Orbs mode",
            convar = "OUTCOMEMORIES_N_tails_Toggle_orbs_useable",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Can swap to shockwave mode",
            convar = "OUTCOMEMORIES_N_tails_Toggle_shockwave_useable",
            color = Color(175, 175, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
            labelText = "Toggle cd",
            convar = "OUTCOMEMORIES_N_tails_togglecd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 2,
                dec = 1,
                default = 20,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        OM_RegisterResetButton_server(scroll, "Tails", "om_reset_tails")

    end)

    concommand.Add("om_blaze_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Blaze pill",
            ["Image"] = "pills/pill_om_blaze.png",
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
                    "OUTCOMEMEMORIES_N_blaze_Resistance",
                    "OUTCOMEMEMORIES_N_blaze_Health",

                    "OUTCOMEMEMORIES_N_blaze_maxSolflame",
                    "OUTCOMEMEMORIES_N_blaze_SolfalemOnSapwn",

                    "OUTCOMEMEMORIES_N_blaze_walk",
                    "OUTCOMEMEMORIES_N_blaze_run",
                    "OUTCOMEMEMORIES_N_blaze_jumppower",
                    "OUTCOMEMEMORIES_N_blaze_jumpcd",
                    "OUTCOMEMEMORIES_N_blaze_rollingPower",
                    "OUTCOMEMEMORIES_N_blaze_soldashspeed",

                    "OUTCOMEMORIES_N_blaze_kick_useable",
                    "OUTCOMEMORIES_N_blaze_kick_stunstack",
                    "OUTCOMEMORIES_N_blaze_kick_cooldownmiss",
                    "OUTCOMEMORIES_N_blaze_kick_cooldownland",
                    "OUTCOMEMORIES_N_blaze_kick_basestun",
                    "OUTCOMEMORIES_N_blaze_kick_basedamage",
                    "OUTCOMEMORIES_N_blaze_kick_canragdollstun",
                    "OUTCOMEMORIES_N_blaze_kick_solflamemeter",
                    "OUTCOMEMORIES_N_blaze_kick_solflamemeterSolflame",
                    "OUTCOMEMORIES_N_blaze_kick_solflamemeter_penalty",
                    "OUTCOMEMORIES_N_blaze_kick_canburn",

                    "OUTCOMEMORIES_N_blaze_SolDash_useable",
                    "OUTCOMEMORIES_N_blaze_SolDash_stunstack",
                    "OUTCOMEMORIES_N_blaze_SolDash_cooldownmiss",
                    "OUTCOMEMORIES_N_blaze_soldash_cooldownland",
                    "OUTCOMEMORIES_N_blaze_SolDash_basestun",
                    "OUTCOMEMORIES_N_blaze_SolDash_basedamage",
                    "OUTCOMEMORIES_N_blaze_soldash_canragdollstun",
                    "OUTCOMEMORIES_N_blaze_SolDash_solflamemeter",
                    "OUTCOMEMORIES_N_blaze_SolDash_solflamemeterSolflame",
                    "OUTCOMEMORIES_N_blaze_SolDash_canburn",

                    "OUTCOMEMORIES_N_blaze_javelin_useable",
                    "OUTCOMEMORIES_N_blaze_javelin_cooldown",
                    "OUTCOMEMORIES_N_blaze_javelin_solflamemeter",
                    
                    "OUTCOMEMORIES_N_blaze_solflame_useable",
                    "OUTCOMEMORIES_N_blaze_solflame_cooldown",
                },
                name = "Blaze",
            }
        })



        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_blaze_Health",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1370,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_blaze_Resistance",
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
            icon = preservedmats["health_bar_icon"],
            labelText = "Max Sol Flame",
            convar = "OUTCOMEMEMORIES_N_blaze_maxSolflame",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Sol Flame On Spawn",
            convar = "OUTCOMEMEMORIES_N_blaze_SolfalemOnSapwn",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
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
            convar = "OUTCOMEMEMORIES_N_blaze_walk",
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
            convar = "OUTCOMEMEMORIES_N_blaze_run",
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
            convar = "OUTCOMEMEMORIES_N_blaze_jumppower",
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
            convar = "OUTCOMEMEMORIES_N_blaze_jumpcd",
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
            convar = "OUTCOMEMEMORIES_N_blaze_rollingPower",
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
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Sol Dash speed",
            convar = "OUTCOMEMEMORIES_N_blaze_soldashspeed",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 2000,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Can Kick",
            convar = "OUTCOMEMORIES_N_blaze_kick_useable",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Can Stunstack",
            convar = "OUTCOMEMORIES_N_blaze_kick_stunstack",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Can Burn",
            convar = "OUTCOMEMORIES_N_blaze_kick_canburn",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Can Radoll victom",
            convar = "OUTCOMEMORIES_N_blaze_kick_canragdollstun",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Cooldown Miss",
            convar = "OUTCOMEMORIES_N_blaze_kick_cooldownmiss",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Cooldown Land",
            convar = "OUTCOMEMORIES_N_blaze_kick_cooldownland",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Base Stun",
            convar = "OUTCOMEMORIES_N_blaze_kick_basestun",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 6,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Base Damage",
            convar = "OUTCOMEMORIES_N_blaze_kick_basedamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 35,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Sol flame reward",
            convar = "OUTCOMEMORIES_N_blaze_kick_solflamemeter",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Sol flame reward After solflame goal",
            convar = "OUTCOMEMORIES_N_blaze_kick_solflamemeterSolflame",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Sol flame Penalty",
            convar = "OUTCOMEMORIES_N_blaze_kick_solflamemeter_penalty",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Can Sol dash",
            convar = "OUTCOMEMORIES_N_blaze_SolDash_useable",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Can Stunstack",
            convar = "OUTCOMEMORIES_N_blaze_SolDash_stunstack",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Can Burn",
            convar = "OUTCOMEMORIES_N_blaze_SolDash_canburn",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Can Radoll victom",
            convar = "OUTCOMEMORIES_N_blaze_soldash_canragdollstun",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Cooldown Miss",
            convar = "OUTCOMEMORIES_N_blaze_SolDash_cooldownmiss",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Cooldown Land",
            convar = "OUTCOMEMORIES_N_blaze_soldash_cooldownland",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Base Stun",
            convar = "OUTCOMEMORIES_N_blaze_SolDash_basestun",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 6,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Base Damage",
            convar = "OUTCOMEMORIES_N_blaze_SolDash_basedamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 35,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Sol flame reward After solflame goal",
            convar = "OUTCOMEMORIES_N_blaze_SolDash_solflamemeter",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Roundhouse_kick"],
            labelText = "Sol flame reward",
            convar = "OUTCOMEMORIES_N_blaze_SolDash_solflamemeterSolflame",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["burning_javelin"],
            labelText = "Can Javelin",
            convar = "OUTCOMEMORIES_N_blaze_javelin_useable",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["burning_javelin"],
            labelText = "Cooldown",
            convar = "OUTCOMEMORIES_N_blaze_javelin_cooldown",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["burning_javelin"],
            labelText = "Sol flame reward",
            convar = "OUTCOMEMORIES_N_blaze_javelin_solflamemeter",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 100,
            }
        })


        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["burning_javelin"],
            labelText = "Can Sol Flame",
            convar = "OUTCOMEMORIES_N_blaze_solflame_useable",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["burning_javelin"],
            labelText = "Cooldown",
            convar = "OUTCOMEMORIES_N_blaze_solflame_cooldown",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 35,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        OM_RegisterResetButton_server(scroll, "Blaze", "om_reset_blaze")

    end)

    
    concommand.Add("om_mighty_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Mighty pill",
            ["Image"] = "pills/pill_om_mighty.png",
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
                    "OUTCOMEMEMORIES_N_mighty_Resistance",
                    "OUTCOMEMEMORIES_N_mighty_Health",
                    "OUTCOMEMEMORIES_N_mighty_passivereduction",
                    "OUTCOMEMEMORIES_N_mighty_walk",
                    "OUTCOMEMEMORIES_N_mighty_run",
                    "OUTCOMEMEMORIES_N_mighty_jumppower",
                    "OUTCOMEMEMORIES_N_mighty_jumpcd",
                    "OUTCOMEMEMORIES_N_mighty_rollingPower",
                    "OUTCOMEMEMORIES_N_mighty_charge",
                    "OUTCOMEMORIES_N_mighty_canusevoiceline",
                    "OUTCOMEMORIES_N_mighty_cover_useable",
                    "OUTCOMEMORIES_N_mighty_cover_cd_start",
                    "OUTCOMEMORIES_N_mighty_cover_cd_cancel",
                    "OUTCOMEMORIES_N_mighty_cover_reduction",
                    "OUTCOMEMORIES_N_mighty_exponensialram_useable",
                    "OUTCOMEMORIES_N_mighty_exponensialram_cd",
                    "OUTCOMEMORIES_N_mighty_exponensialram_cd_hit",
                    "OUTCOMEMORIES_N_mighty_exponensialram_stunduration",
                    "OUTCOMEMORIES_N_mighty_exponensialram_stunstacking",
                    "OUTCOMEMORIES_N_mighty_exponensialram_canragdoll",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_useable",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_cd",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_stunduration",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_stunstacking",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_canragdoll",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_stundamage"
                },
                name = "Mighty",
            }
        })



        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_mighty_Health",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1370,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_mighty_Resistance",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 300,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "passive Resistance",
            convar = "OUTCOMEMEMORIES_N_mighty_passivereduction",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 300,
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
            convar = "OUTCOMEMEMORIES_N_migty_walk",
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
            convar = "OUTCOMEMEMORIES_N_mighty_run",
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
            convar = "OUTCOMEMEMORIES_N_mighty_jumppower",
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
            convar = "OUTCOMEMEMORIES_N_mighty_jumpcd",
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
            convar = "OUTCOMEMEMORIES_N_mighty_rollingPower",
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
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Charge Speed",
            convar = "OUTCOMEMEMORIES_N_mighty_charge",
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
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "Has Voicelines",
            convar = "OUTCOMEMORIES_N_mighty_canusevoiceline",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "Can use Cover",
            convar = "OUTCOMEMORIES_N_mighty_cover_useable",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "Cover cd start",
            convar = "OUTCOMEMORIES_N_mighty_cover_cd_start",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "Cover cd Cancel",
            convar = "OUTCOMEMORIES_N_mighty_cover_cd_cancel",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "Cover cd Cancel",
            convar = "OUTCOMEMORIES_N_mighty_cover_cd_cancel",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "Cover Resistance",
            convar = "OUTCOMEMORIES_N_mighty_cover_reduction",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 300,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Can use Ram",
            convar = "OUTCOMEMORIES_N_mighty_exponensialram_useable",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Can stun stack",
            convar = "OUTCOMEMORIES_N_mighty_exponensialram_stunstacking",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Can Ragdoll",
            convar = "OUTCOMEMORIES_N_mighty_exponensialram_canragdoll",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Ram cd Miss",
            convar = "OUTCOMEMORIES_N_mighty_exponensialram_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 40,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Ram cd Hit",
            convar = "OUTCOMEMORIES_N_mighty_exponensialram_cd_hit",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 40,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Stun Duration",
            convar = "OUTCOMEMORIES_N_mighty_exponensialram_stunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 7,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Stun Damage",
            convar = "OUTCOMEMORIES_N_mighty_exponensialram_stundamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })


        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["BoulderMighty_om"],
            labelText = "Can use boulder throw",
            convar = "OUTCOMEMORIES_N_mighty_boulderthrow_useable",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["BoulderMighty_om"],
            labelText = "Can stun stack",
            convar = "OUTCOMEMORIES_N_mighty_boulderthrow_stunstacking",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["BoulderMighty_om"],
            labelText = "Can Ragdoll",
            convar = "OUTCOMEMORIES_N_mighty_boulderthrow_canragdoll",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["BoulderMighty_om"],
            labelText = "Boulder cd",
            convar = "OUTCOMEMORIES_N_mighty_boulderthrow_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["BoulderMighty_om"],
            labelText = "Stun Duration",
            convar = "OUTCOMEMORIES_N_mighty_boulderthrow_stunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 7,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["BoulderMighty_om"],
            labelText = "Stun Damage",
            convar = "OUTCOMEMORIES_N_mighty_boulderthrow_stundamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 20,
            }
        })

        OM_RegisterResetButton_server(scroll, "Mighty", "om_reset_mighty")

    end)

    concommand.Add("om_Rouge_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Rouge pill",
            ["Image"] = "pills/pill_om_rouge.png",
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

                    "OUTCOMEMEMORIES_N_rouge_Resistance",
                    "OUTCOMEMEMORIES_N_rouge_Health",
                    "OUTCOMEMEMORIES_N_rouge_passivereduction",
                    "OUTCOMEMEMORIES_N_rouge_walk",
                    "OUTCOMEMEMORIES_N_rouge_run",
                    "OUTCOMEMEMORIES_N_rouge_jumppower",
                    "OUTCOMEMEMORIES_N_rouge_jumpcd",
                    "OUTCOMEMEMORIES_N_rouge_rollingPower",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_speed",
                    "OUTCOMEMEMORIES_N_rouge_launchy_power",
                    "OUTCOMEMEMORIES_N_rouge_canuse_smokebomb",
                    "OUTCOMEMEMORIES_N_rouge_smokebomb_cd",
                    "OUTCOMEMEMORIES_N_rouge_smokebomb_slowdownduration",
                    "OUTCOMEMEMORIES_N_rouge_smokebomb_reward",
                    "OUTCOMEMEMORIES_N_rouge_canuse_sweepkick",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_chargeup",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_duration",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_cd_miss",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_cd_hit",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_damageamouunt",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_basestun",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_canstunstack",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_canragdoll",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_reward",
                    "OUTCOMEMEMORIES_N_rouge_passive_energy_starter",
                    "OUTCOMEMEMORIES_N_rouge_passive_energy_maximum",
                    "OUTCOMEMEMORIES_N_rouge_passive_energy_regen",
                    "OUTCOMEMEMORIES_N_rouge_passive_latches_maximum",
                    "OUTCOMEMEMORIES_N_rouge_passive_latch_energydrain",
                    "OUTCOMEMEMORIES_N_rouge_passive_latch_jump_energydrain",
                    "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_maximum",
                    "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_energydrain",
                    "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_cdperjump"
                },
                name = "Shadow",
            }
        })



        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_rouge_Health",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1370,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_rouge_Resistance",
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
            convar = "OUTCOMEMEMORIES_N_rouge_walk",
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
            convar = "OUTCOMEMEMORIES_N_rouge_run",
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
            convar = "OUTCOMEMEMORIES_N_rouge_jumppower",
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
            convar = "OUTCOMEMEMORIES_N_rouge_jumpcd",
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
            convar = "OUTCOMEMEMORIES_N_rouge_rollingPower",
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
            icon = preservedmats["rouge_kick_om"],
            labelText = "sweep kick speed",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_speed",
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
            icon = preservedmats["jump_power"],
            labelText = "Latch launch power",
            convar = "OUTCOMEMEMORIES_N_rouge_launchy_power",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 1000,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_smokebomb_om"],
            labelText = "Can use Smoke Bomb",
            convar = "OUTCOMEMEMORIES_N_rouge_canuse_smokebomb",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_smokebomb_om"],
            labelText = "cd",
            convar = "OUTCOMEMEMORIES_N_rouge_smokebomb_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 35,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_smokebomb_om"],
            labelText = "Slowdown debuff duration",
            convar = "OUTCOMEMEMORIES_N_rouge_smokebomb_slowdownduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = "Energy reward",
            convar = "OUTCOMEMEMORIES_N_rouge_smokebomb_reward",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 400,
            }
        })


        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Can use Sweep Kick",
            convar = "OUTCOMEMEMORIES_N_rouge_canuse_sweepkick",
            color = Color(175, 100, 100, 180),
            vartype = "bool",
            isexe = false,
        })


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Can Stun stack",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_canstunstack",
            color = Color(175, 100, 100, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Can Ragdoll",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_canragdoll",
            color = Color(175, 100, 100, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Charge Up Duraation",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_chargeup",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Cd miss",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_cd_miss",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Cd Hot",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_cd_hit",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Damage amount",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_damageamouunt",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 400,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Base Stun Amount",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_basestun",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 7,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = "Energy reward",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_reward",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = "Start Energy",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_energy_starter",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = "Max Energy",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_energy_maximum",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = " Energy regen",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_energy_regen",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 40,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_LatcSetting"],
            labelText = "Max Latches",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_latches_maximum",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = "Energy drain per tick",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_latch_energydrain",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = "Energy Drain upon jump",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_latch_jump_energydrain",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 400,
            }
        })


        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Max mid air jumps",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_maximum",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Midair jump energy drain",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_energydrain",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 40,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Cooldown count per jump",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_cdperjump",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        OM_RegisterResetButton_server(scroll, "Rouge", "om_reset_rouge")

    end)

    concommand.Add("om_kolossos_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Kolossos pill",
            ["Image"] = "pills/pill_om_kolossos.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["preset_icon_om"],
            labelText = "Presents",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'preset',
            presettable = {
                listofdefualtconvars = {
                    "OUTCOMEMEMORIES_N_Kolosssos_HasHealth",
                    "OUTCOMEMEMORIES_N_Kolosssos_Resistance",
                    "OUTCOMEMEMORIES_N_Kolosssos_Health",
                    "OUTCOMEMEMORIES_N_Kolosssos_walk",
                    "OUTCOMEMEMORIES_N_Kolosssos_run",
                    "OUTCOMEMEMORIES_N_Kolosssos_jumppower",
                    "OUTCOMEMEMORIES_N_Kolosssos_jumpcd",
                    "OUTCOMEMEMORIES_N_Kolosssos_charge",
                    "OUTCOMEMEMORIES_N_Kolosssos_Damage",
                    "OUTCOMEMEMORIES_N_Kolosssos_ChargeImpaleDamage",
                    "OUTCOMEMEMORIES_N_Kolosssos_slamDamage",
                    "OUTCOMEMEMORIES_N_Kolosssos_grabdamage",
                    "OUTCOMEMEMORIES_N_Kolosssos_CanCharge",
                    "OUTCOMEMEMORIES_N_Kolosssos_ChargeCooldown",
                    "OUTCOMEMEMORIES_N_Kolosssos_ChargeDuration",
                    "OUTCOMEMEMORIES_N_Kolosssos_ImapleChargeDuration",
                    "OUTCOMEMEMORIES_N_Kolosssos_ChargeNoConotrolDuration",
                    "OUTCOMEMEMORIES_N_Kolosssos_CanGrab",
                    "OUTCOMEMEMORIES_N_Kolosssos_CanCancelGrab",
                    "OUTCOMEMEMORIES_N_Kolosssos_GrabCooldown",
                    "OUTCOMEMEMORIES_N_Kolosssos_PunchesLeft",
                    "OUTCOMEMEMORIES_N_Kolosssos_CanIndicator",
                    "OUTCOMEMEMORIES_N_Kolosssos_IndicatorDuration",
                    "OUTCOMEMEMORIES_N_Kolosssos_IndicatorCooldown",
                    "OUTCOMEMEMORIES_N_Kolosssos_CanBlock",
                    "OUTCOMEMEMORIES_N_Kolosssos_BlockCooldown",
                    "OUTCOMEMEMORIES_N_Kolosssos_CanClimb",
                },
                name = "Kolossos",
            }
        })



        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Has Health",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_HasHealth",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
            bioText = "life insurance not included",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_Health",
            color = Color(80, 175, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1370,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_Resistance",
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
        
        -- speed
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["walk_speed"],
            labelText = "Walk speed",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_walk",
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
            convar = "OUTCOMEMEMORIES_N_Kolosssos_run",
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
            convar = "OUTCOMEMEMORIES_N_Kolosssos_jumppower",
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
            convar = "OUTCOMEMEMORIES_N_Kolosssos_jumpcd",
            color = Color(80, 80, 80, 180),
            isexe = true,
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
            icon = preservedmats["Kolossos_hi"],
            labelText = "Charge Speed",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_charge",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 500,
                max = 2500,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["KOLOSSOS_PUNCH"],
            labelText = "Grab Speed",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_grab",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 500,
                max = 2500,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Damage",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_Damage",
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
            labelText = "Charge Impale Damage",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_ChargeImpaleDamage",
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
            labelText = "Charge slam Damage",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_slamDamage",
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
            labelText = "Grab Damage",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_grabdamage",
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

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Can Charge",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_CanCharge",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Charge Cooldown",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_ChargeCooldown",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Charge Duration",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_ChargeDuration",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Impale Charge Duration",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_ImapleChargeDuration",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Auto Charge Duration",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_ChargeNoConotrolDuration",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["KOLOSSOS_PUNCH"],
            labelText = "Can Grab",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_CanGrab",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["KOLOSSOS_PUNCH"],
            labelText = "Can Cancel Grab",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_CanCancelGrab",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Grab Cooldown",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_GrabCooldown",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Punches left",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_PunchesLeft",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["kolossos_peek"],
            labelText = "Can Indicate",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_CanIndicator",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Indicator Duration",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_IndicatorDuration",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Indicator Cooldown",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_IndicatorCooldown",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 18,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["kolossos_block"],
            labelText = "Can Block",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_CanBlock",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Indicator Cooldown",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_BlockCooldown",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 18,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Can Climb",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_CanClimb",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        OM_RegisterResetButton_server(scroll, "Kolosssos", "om_reset_kolossos")

    end)


    concommand.Add("om_lilith_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Lilith pill",
            ["Image"] = "pills/pill_om_lilith.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["preset_icon_om"],
            labelText = "Presents",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'preset',
            presettable = {
                listofdefualtconvars = {
                    "OUTCOMEMEMORIES_N_Lilith_HasHealth",
                    "OUTCOMEMEMORIES_N_Lilith_Resistance",
                    "OUTCOMEMEMORIES_N_Lilith_Health",
                    "OUTCOMEMEMORIES_N_Lilith_walk",
                    "OUTCOMEMEMORIES_N_Lilith_run",
                    "OUTCOMEMEMORIES_N_Lilith_jumppower",
                    "OUTCOMEMEMORIES_N_Lilith_jumpcd",
                    "OUTCOMEMEMORIES_N_Lilith_chargedash",
                    "OUTCOMEMEMORIES_N_Lilith_ChargedashCharge",
                    "OUTCOMEMEMORIES_N_Lilith_Damage",
                    "OUTCOMEMEMORIES_N_Lilith_ChargeDashDamage",
                    "OUTCOMEMEMORIES_N_Lilith_puddledamage",
                    "OUTCOMEMEMORIES_N_Lilith_PulseImage_damage",
                    "OUTCOMEMEMORIES_N_Lilith_ChargeDash_canuse",
                    "OUTCOMEMEMORIES_N_Lilith_ChargeDash_slipperiness",
                    "OUTCOMEMEMORIES_N_Lilith_ChargeDashCd",
                    "OUTCOMEMEMORIES_N_Lilith_ChargeDashDuration",
                    "OUTCOMEMEMORIES_N_Lilith_BluntTruama",
                    "OUTCOMEMEMORIES_N_Lilith_BluntTruama_CD",
                    "OUTCOMEMEMORIES_N_Lilith_PulseImage",
                    "OUTCOMEMEMORIES_N_Lilith_PulseImage_cd_in",
                    "OUTCOMEMEMORIES_N_Lilith_PulseImage_cd_out",
                },
                name = "Lilith",
            }
        })


        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Has Health",
            convar = "OUTCOMEMEMORIES_N_Lilith_HasHealth",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
            bioText = "life insurance not included",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_Lilith_Health",
            color = Color(80, 175, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1370,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["damage_percentage"],
            labelText = "Damage Resistance",
            convar = "OUTCOMEMEMORIES_N_Lilith_Resistance",
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
        
        -- speed
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["walk_speed"],
            labelText = "Walk speed",
            convar = "OUTCOMEMEMORIES_N_Lilith_walk",
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
            convar = "OUTCOMEMEMORIES_N_Lilith_run",
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
            convar = "OUTCOMEMEMORIES_N_Lilith_jumppower",
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
            convar = "OUTCOMEMEMORIES_N_Lilith_jumpcd",
            color = Color(80, 80, 80, 180),
            isexe = true,
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
            icon = preservedmats["Spinball_Lilith"],
            labelText = "Charge Dash Speed",
            convar = "OUTCOMEMEMORIES_N_Lilith_chargedash",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 500,
                max = 2500,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Spinball_Lilith"],
            labelText = "Charge Dash Speed",
            convar = "OUTCOMEMEMORIES_N_Lilith_ChargedashCharge",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 500,
                max = 2500,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Damage",
            convar = "OUTCOMEMEMORIES_N_Lilith_Damage",
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
            icon = preservedmats["Spinball_Lilith"],
            labelText = "Charge Dash Damage",
            convar = "OUTCOMEMEMORIES_N_Lilith_ChargeDashDamage",
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
            icon = preservedmats["blunt_trauma"],
            labelText = "Blaunt Truama Damage",
            convar = "OUTCOMEMEMORIES_N_Lilith_puddledamage",
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
            icon = preservedmats["Lilith_Indicator_Move_Thingy"],
            labelText = "Pulse Image Damage",
            convar = "OUTCOMEMEMORIES_N_Lilith_PulseImage_damage",
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

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Spinball_Lilith"],
            labelText = "Can use Charge Dash",
            convar = "OUTCOMEMEMORIES_N_Lilith_ChargeDash_canuse",
            color = Color(35, 255, 35, 180),
            vartype = "bool",
            isexe = false,
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Spinball_Lilith"],
            labelText = "Slipperiness",
            convar = "OUTCOMEMEMORIES_N_Lilith_ChargeDash_slipperiness",
            color = Color(35, 255, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Spinball_Lilith"],
            labelText = "Cooldown",
            convar = "OUTCOMEMEMORIES_N_Lilith_ChargeDashCd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Spinball_Lilith"],
            labelText = "Duration",
            convar = "OUTCOMEMEMORIES_N_Lilith_ChargeDashDuration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["blunt_trauma"],
            labelText = "Can use Blunt Truama",
            convar = "OUTCOMEMEMORIES_N_Lilith_BluntTruama",
            color = Color(35, 255, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["blunt_trauma"],
            labelText = "Cooldown",
            convar = "OUTCOMEMEMORIES_N_Lilith_BluntTruama_CD",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Lilith_Indicator_Move_Thingy"],
            labelText = "Can use Pulse Image",
            convar = "OUTCOMEMEMORIES_N_Lilith_PulseImage",
            color = Color(35, 255, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Lilith_Indicator_Move_Thingy"],
            labelText = "Cooldown In",
            convar = "OUTCOMEMEMORIES_N_Lilith_PulseImage_cd_in",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Lilith_Indicator_Move_Thingy"],
            labelText = "Cooldown Out",
            convar = "OUTCOMEMEMORIES_N_Lilith_PulseImage_cd_out",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 20,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterResetButton_server(scroll, "Lilith", "om_reset_Lilith")

    end)
end


-- SERVER register
Register_OMSettings({
    Name = "Mighty Server settings",
    Command = "om_mighty_server_pill_command",
    Color = Color(135, 0, 0),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_mighty.png"
})
Register_OMSettings({
    Name = "Shadow Server settings",
    Command = "om_Shadow_server_pill_command",
    Color = Color(185, 0, 0),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_shadow.png"
})
Register_OMSettings({
    Name = "Rouge Server settings",
    Command = "om_Rouge_server_pill_command",
    Color = Color(255, 175, 175),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_rouge.png"
})
Register_OMSettings({
    Name = "Fang Server settings",
    Command = "om_Fang_server_pill_command",
    Color = Color(135, 0, 135),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_fang.png"
})
Register_OMSettings({
    Name = "Blaze Server settings",
    Command = "om_blaze_server_pill_command",
    Color = Color(255, 65, 255),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_blaze.png"
})
Register_OMSettings({
    Name = "Tails Server settings",
    Command = "om_tails_server_pill_command",
    Color = Color(255, 255, 0),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_tails.png"
})
Register_OMSettings({
    Name = "Kolossos Server settings",
    Command = "om_Kolossos_server_pill_command",
    Color = Color(0, 0, 255),
    TableType = "Killer",
    ServerOrClient = true,
    Image = "pills/pill_om_kolossos.png"
})
Register_OMSettings({
    Name = "Lilith Server settings",
    Command = "om_lilith_server_pill_command",
    Color = Color(0, 255, 0),
    TableType = "Killer",
    ServerOrClient = true,
    Image = "pills/pill_om_lilith.png"
})

-- client register
Register_OMSettings({
    Name = "Mighty client settings",
    Command = "om_mighty_pill_command",
    Color = Color(135, 0, 0),
    TableType = "Survivor", 
    ServerOrClient = false,
    Image = "pills/pill_om_mighty.png"
})
Register_OMSettings({
    Name = "Shadow client settings",
    Command = "om_Shadow_pill_command",
    Color = Color(185, 0, 0),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_shadow.png"
})
Register_OMSettings({
    Name = "Rouge client settings",
    Command = "om_rouge_pill_command",
    Color = Color(255, 175, 175),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_rouge.png"
})
Register_OMSettings({
    Name = "Fang client settings",
    Command = "om_fang_pill_command",
    Color = Color(135, 0, 135),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_fang.png"
})
Register_OMSettings({
    Name = "Blaze client settings",
    Command = "om_blaze_pill_command",
    Color = Color(255, 0, 175),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_blaze.png"
})
Register_OMSettings({
    Name = "Tails client settings",
    Command = "om_tails_pill_command",
    Color = Color(255, 255, 0),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_tails.png"
})


Register_OMSettings({
    Name = "Kolossos Client settings",
    Command = "om_kolossos_pill_command",
    Color = Color(0, 0, 255),
    TableType = "Killer",
    ServerOrClient = false,
    Image = "pills/pill_om_kolossos.png"
})
Register_OMSettings({
    Name = "Lilith Client settings",
    Command = "om_lilith_pill_command",
    Color = Color(0, 255, 0),
    TableType = "Killer",
    ServerOrClient = false,
    Image = "pills/pill_om_lilith.png"
})