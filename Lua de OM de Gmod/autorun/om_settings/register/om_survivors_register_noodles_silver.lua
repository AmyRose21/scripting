AddCSLuaFile()

if SERVER then

    -- Silver convar group
    CreateConVar("OUTCOMEMEMORIES_N_silver_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_silver_Health", 100, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_silver_maxenergy", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_silver_energyonspawn", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_silver_energyregen", 5, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_silver_walk", 60, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_silver_run", 412, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_silver_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_silver_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_silver_rollingPower", 1400, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_silver_suspension_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_silver_suspension_cooldownmiss", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_silver_suspension_cooldown", 17, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_silver_suspension_energydrain", 5, FCVAR_ARCHIVE, "", 0, 1e9)


    CreateConVar("OUTCOMEMORIES_N_silver_rocks_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_silver_rocks_basecd", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_silver_rocks_cdperrock", 5, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_silver_rocks_maxrocks", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_silver_rocks_rocksmusthit", 3, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_silver_rocks_slowdownduration", 5, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_silver_rocks_basestun", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_silver_rocks_basedamage_perrock", 0, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_silver_rocks_basedamagestun", 0, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_silver_rocks_canstunstack", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_silver_rocks_canragdoll", 0, FCVAR_ARCHIVE, "", 0, 1)


    CreateConVar("OUTCOMEMORIES_N_silver_timereverseal_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_silver_timereverseal_energydrain", 10, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_silver_timereverseal_tickduration", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_silver_timereverseal_cd_end", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_silver_timereverseal_cd_start", 1, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_silver", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_silver_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_silver_Health"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_silver_maxenergy"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_silver_energyonspawn"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_silver_energyregen"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_silver_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_silver_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_silver_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_silver_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_silver_rollingPower"):Revert()

        GetConVar("OUTCOMEMORIES_N_silver_suspension_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_suspension_cooldownmiss"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_suspension_cooldown"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_suspension_energydrain"):Revert()

        GetConVar("OUTCOMEMORIES_N_silver_rocks_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_rocks_basecd"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_rocks_cdperrock"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_rocks_maxrocks"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_rocks_rocksmusthit"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_rocks_slowdownduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_rocks_basestun"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_rocks_basedamage_perrock"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_rocks_basedamagestun"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_rocks_canstunstack"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_rocks_canragdoll"):Revert()

        GetConVar("OUTCOMEMORIES_N_silver_timereverseal_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_timereverseal_energydrain"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_timereverseal_tickduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_timereverseal_cd_end"):Revert()
        GetConVar("OUTCOMEMORIES_N_silver_timereverseal_cd_start"):Revert()


    end)

end

if CLIENT then
    CreateClientConVar("om_pills_action_silver_abillty1_key", KEY_E, true, true, "silver ability1 keybind")
    CreateClientConVar("om_pills_action_silver_abillty2_key", KEY_R, true, true, "silver ability2 keybind")
    CreateClientConVar("om_pills_action_silver_abillty3_key", KEY_T, true, true, "silver ability3 keybind")
    CreateClientConVar("om_pills_action_camera_silver", 1, true, true, "Camera Toggle is activated by abilities for blaze")

    local preservedmats = {
        ["OM_icon_survivor"] = "icons/Polygon_of_doom.png",
        ["OM_icon_monster"] = "icons/Polygon_of_DEVI.png",

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


        ["OM_flyingicon"] = "icons/OM_flyingicon.png",
        ["OM_flyingcdicon"] = "icons/OM_flyingcdicon.png",

        ["IT'S NO USE 2"] = "icons/IT'S NO USE 2.png",
        ["rock 2"] = "icons/rock 2.png",
        ["silverref"] = "icons/silverref.png",
        
    }
                
    local KeyDefaults2 = {
        ["Silver"] = {
            om_pills_action_silver_abillty1_key = KEY_E,
            om_pills_action_silver_abillty2_key = KEY_R,
            om_pills_action_silver_abillty3_key = KEY_T,
        },
    }


    
end


-- SERVER register
--[[
Register_OMSettings({
    Name = "Blaze Server settings",
    Command = "om_blaze_server_pill_command",
    Color = Color(255, 65, 255),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_blaze.png"
})
]]

-- client register
--[[
Register_OMSettings({
    Name = "Blaze client settings",
    Command = "om_blaze_pill_command",
    Color = Color(255, 65, 255),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_blaze.png"
})
]]