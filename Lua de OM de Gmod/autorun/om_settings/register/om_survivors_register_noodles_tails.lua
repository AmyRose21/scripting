AddCSLuaFile()

if SERVER then
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
end

if CLIENT then
    CreateClientConVar("om_pills_action_tails_laser_key", KEY_E, true, true, "Tails Laser keybind")
    CreateClientConVar("om_pills_action_tails_glide_key", KEY_R, true, true, "Tails Glide keybind")
    CreateClientConVar("om_pills_action_tails_toggle_key", KEY_T, true, true, "Tails Toggle keybind")
    CreateClientConVar("om_pills_action_camera_tails", 1, true, true, "Camera Toggle is activated by abilities for Tails")

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

        ["tails_abilitycannon"] = "icons/tails_abilitycannon.png",
        ["tails_abilityfly"] = "icons/tails_abilityfly.png",
        ["shadow_icon_reload"] = "icons/shadow_icon_reload.png",
    }
                
    local KeyDefaults2 = {
        ["Tails"] = {
            om_pills_action_tails_laser_key = KEY_E,
            om_pills_action_tails_glide_key = KEY_R,
            om_pills_action_tails_toggle_key = KEY_T,
        },
    }

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

end


-- SERVER register
Register_OMSettings({
    Name = "Tails Server settings",
    Command = "om_tails_server_pill_command",
    Color = Color(255, 255, 0),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_tails.png"
})

-- client register
Register_OMSettings({
    Name = "Tails client settings",
    Command = "om_tails_pill_command",
    Color = Color(255, 255, 0),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_tails.png"
})