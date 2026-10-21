AddCSLuaFile()

if SERVER then
    -- eyx's convars group
    CreateConVar("OUTCOMEMEMORIES_N_eyx_HasHealth", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Health", 565, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_eyx_walk", 80, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_run", 525, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_jumpcd", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_slamdunkgrab", 1350, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_chargerun_new", 600, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_chargewalk", 350, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage", 30, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_frenzy", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_screech", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_screech_slam", 45, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_slamdunk", 35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_slamdunk_area", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_infection", 20, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Damage_infection_leap", 25, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_eyx_HasFrenzy", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_FrenzyBuildUpDuration", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_eyx_CanLeap", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Leap_cd", 13, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Leap_wall_cd", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_eyx_CanSlamDunk", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_cd", 18, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_hit_cd", 27, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_duration_v2", 0.5, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_eyx_CanScreech", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Screech_cd", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_eyx_CanInfection", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_CanInfection_Swap", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Infection_cd", 10, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_eyx_Infection_cd_frenzy", 10, FCVAR_ARCHIVE, "", 0, 1e9)

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
        GetConVar("OUTCOMEMEMORIES_N_eyx_chargerun_new"):Revert()
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
        GetConVar("OUTCOMEMEMORIES_N_eyx_Leap_wall_cd"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_eyx_CanSlamDunk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_hit_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_SlamDunk_duration_v2"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_eyx_CanScreech"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Screech_cd"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_eyx_CanInfection"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_CanInfection_Swap"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Infection_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_Infection_cd_frenzy"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_eyx_HasFrenzy"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_eyx_FrenzyBuildUpDuration"):Revert()
    end)


end

if CLIENT then
    CreateClientConVar("om_pills_action_eyx_leap_key", KEY_E, true, true, "eyx leap keybind")
    CreateClientConVar("om_pills_action_eyx_slamdunk_key", KEY_R, true, true, "eyx slamdunk keybind")
    CreateClientConVar("om_pills_action_eyx_screech_key", KEY_T, true, true, "eyx screech keybind")
    CreateClientConVar("om_pills_action_eyx_infection_key", KEY_I, true, true, "eyx infection keybind")
    CreateClientConVar("om_pills_action_camera_eyx", 1, true, true, "Camera Toggle is activated by abilities for eyx")

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

        ["eyxleap"] = "icons/eyxleap.png",
        ["eyxslam"] = "icons/eyxslam.png",
        ["eyxscreech"] = "icons/eyxscreech.png",
        ["infectioneyx"] = "icons/infectioneyx.png",
    }
                
    local KeyDefaults2 = {
        ["EYX"] = {
            om_pills_action_eyx_leap_key = KEY_E,
            om_pills_action_eyx_slamdunk_key = KEY_R,
            om_pills_action_eyx_screech_key = KEY_T,
            om_pills_action_eyx_infection_key = KEY_I,
        },
    }

    concommand.Add("om_eyx_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - EYX pill",
            ["Image"] = "pills/pill_om_eyx.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxleap"],
            labelText = "Leap",
            convar = "om_pills_action_eyx_leap_key",
            color = Color(0, 0, 175, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxslam"],
            labelText = "Slam dunk",
            convar = "om_pills_action_eyx_slamdunk_key",
            color = Color(0, 0, 211, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxscreech"],
            labelText = "Screech",
            convar = "om_pills_action_eyx_screech_key",
            color = Color(0, 0, 135, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["infectioneyx"],
            labelText = "Infection",
            convar = "om_pills_action_eyx_infection_key",
            color = Color(0, 0, 70, 180),
            isexe = true,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "EYX", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_eyx",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = true,
        })
    end)

    concommand.Add("om_eyx_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - EYX pill",
            ["Image"] = "pills/pill_om_eyx.png",
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

                    "OUTCOMEMEMORIES_N_eyx_HasHealth",
                    "OUTCOMEMEMORIES_N_eyx_Resistance",
                    "OUTCOMEMEMORIES_N_eyx_Health",

                    "OUTCOMEMEMORIES_N_eyx_walk",
                    "OUTCOMEMEMORIES_N_eyx_run",
                    "OUTCOMEMEMORIES_N_eyx_jumppower",
                    "OUTCOMEMEMORIES_N_eyx_jumpcd",
                    "OUTCOMEMEMORIES_N_eyx_slamdunkgrab",
                    "OUTCOMEMEMORIES_N_eyx_chargerun_new",
                    "OUTCOMEMEMORIES_N_eyx_chargewalk",
                    
                    "OUTCOMEMEMORIES_N_eyx_Damage",
                    "OUTCOMEMEMORIES_N_eyx_Damage_frenzy",
                    "OUTCOMEMEMORIES_N_eyx_Damage_screech",
                    "OUTCOMEMEMORIES_N_eyx_Damage_screech_slam",
                    "OUTCOMEMEMORIES_N_eyx_Damage_slamdunk",
                    "OUTCOMEMEMORIES_N_eyx_Damage_slamdunk_area",
                    "OUTCOMEMEMORIES_N_eyx_Damage_infection",
                    "OUTCOMEMEMORIES_N_eyx_Damage_infection_leap",
                    
                    "OUTCOMEMEMORIES_N_eyx_CanLeap",
                    "OUTCOMEMEMORIES_N_eyx_Leap_cd",
                    "OUTCOMEMEMORIES_N_eyx_Leap_wall_cd",
                    
                    "OUTCOMEMEMORIES_N_eyx_CanSlamDunk",
                    "OUTCOMEMEMORIES_N_eyx_SlamDunk_cd",
                    "OUTCOMEMEMORIES_N_eyx_SlamDunk_hit_cd",
                    "OUTCOMEMEMORIES_N_eyx_SlamDunk_duration_v2",
                    
                    "OUTCOMEMEMORIES_N_eyx_CanScreech",
                    "OUTCOMEMEMORIES_N_eyx_Screech_cd",
                    
                    "OUTCOMEMEMORIES_N_eyx_CanInfection",
                    "OUTCOMEMEMORIES_N_eyx_CanInfection_Swap",
                    "OUTCOMEMEMORIES_N_eyx_Infection_cd",
                    "OUTCOMEMEMORIES_N_eyx_Infection_cd_frenzy",

                    "OUTCOMEMEMORIES_N_eyx_HasFrenzy",
                    "OUTCOMEMEMORIES_N_eyx_FrenzyBuildUpDuration"
                },
                name = "EYX",
            }
        })

        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Has Health",
            convar = "OUTCOMEMEMORIES_N_eyx_HasHealth",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
            bioText = "life insurance not included",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Health",
            convar = "OUTCOMEMEMORIES_N_eyx_Resistance",
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
            convar = "OUTCOMEMEMORIES_N_eyx_Health",
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
            convar = "OUTCOMEMEMORIES_N_eyx_walk",
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
            convar = "OUTCOMEMEMORIES_N_eyx_run",
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
            convar = "OUTCOMEMEMORIES_N_eyx_jumppower",
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
            convar = "OUTCOMEMEMORIES_N_eyx_jumpcd",
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
            icon = preservedmats["eyxslam"],
            labelText = "Slam dunk",
            convar = "OUTCOMEMEMORIES_N_eyx_slamdunkgrab",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 800,
                max = 1650,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["walk_speed"],
            labelText = "Four legged Walk",
            convar = "OUTCOMEMEMORIES_N_eyx_chargewalk",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 300,
                max = 800,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["run_speed"],
            labelText = "Four legged Run",
            convar = "OUTCOMEMEMORIES_N_eyx_chargerun_new",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 300,
                max = 800,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Damage",
            convar = "OUTCOMEMEMORIES_N_eyx_Damage",
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
            labelText = "Frenzy Damage",
            convar = "OUTCOMEMEMORIES_N_eyx_Damage_frenzy",
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
            icon = preservedmats["eyxscreech"],
            labelText = "Screech Damage",
            convar = "OUTCOMEMEMORIES_N_eyx_Damage_screech",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 35,
            },
            bioText = "This can only be accessed via frenzy"
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxscreech"],
            labelText = "Screech Slam Damage",
            convar = "OUTCOMEMEMORIES_N_eyx_Damage_screech_slam",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 35,
            },
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxslam"],
            labelText = "Slam Dunk Damage",
            convar = "OUTCOMEMEMORIES_N_eyx_Damage_slamdunk",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 35,
            },
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxslam"],
            labelText = "Slam Dunk area damage",
            convar = "OUTCOMEMEMORIES_N_eyx_Damage_slamdunk_area",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 35,
            },
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["infectioneyx"],
            labelText = "Infection damage",
            convar = "OUTCOMEMEMORIES_N_eyx_Damage_infection",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 35,
            },
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["infectioneyx"],
            labelText = "Infection Leap damage",
            convar = "OUTCOMEMEMORIES_N_eyx_Damage_infection_leap",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 35,
            },
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxleap"],
            labelText = "Has Frenzy",
            convar = "OUTCOMEMEMORIES_N_eyx_HasFrenzy",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxleap"],
            labelText = "Frenzy Charge up",
            convar = "OUTCOMEMEMORIES_N_eyx_FrenzyBuildUpDuration",
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
            icon = preservedmats["eyxleap"],
            labelText = "Can Leap",
            convar = "OUTCOMEMEMORIES_N_eyx_CanLeap",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxleap"],
            labelText = "Leap Cooldown",
            convar = "OUTCOMEMEMORIES_N_eyx_Leap_cd",
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
            icon = preservedmats["eyxleap"],
            labelText = "Leap hitwall Cooldown",
            convar = "OUTCOMEMEMORIES_N_eyx_Leap_wall_cd",
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
            icon = preservedmats["eyxslam"],
            labelText = "Can Slamdunk",
            convar = "OUTCOMEMEMORIES_N_eyx_CanSlamDunk",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxslam"],
            labelText = "Slamdunk Cooldown",
            convar = "OUTCOMEMEMORIES_N_eyx_SlamDunk_cd",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1305,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxslam"],
            labelText = "Slamdunk Cooldown",
            convar = "OUTCOMEMEMORIES_N_eyx_SlamDunk_hit_cd",
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
            icon = preservedmats["eyxslam"],
            labelText = "Slamdunk duration",
            convar = "OUTCOMEMEMORIES_N_eyx_SlamDunk_duration_v2",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxscreech"],
            labelText = "Can Screech",
            convar = "OUTCOMEMEMORIES_N_eyx_CanScreech",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["eyxscreech"],
            labelText = "Screech Cooldown",
            convar = "OUTCOMEMEMORIES_N_eyx_Screech_cd",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1305,
                dec = 1,
                default = 100,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["infectioneyx"],
            labelText = "Can Infection",
            convar = "OUTCOMEMEMORIES_N_eyx_CanInfection",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["infectioneyx"],
            labelText = "Has Frenzy variant",
            convar = "OUTCOMEMEMORIES_N_eyx_CanInfection_Swap",
            color = Color(255, 35, 35, 180),
            vartype = "bool",
            isexe = true,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["infectioneyx"],
            labelText = "Infection CD",
            convar = "OUTCOMEMEMORIES_N_eyx_Infection_cd",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1305,
                dec = 1,
                default = 100,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["infectioneyx"],
            labelText = "Frenzy Infection CD",
            convar = "OUTCOMEMEMORIES_N_eyx_Infection_cd_frenzy",
            color = Color(80, 80, 80, 180),
            isexe = true,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1305,
                dec = 1,
                default = 100,
            }
        })


        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        OM_RegisterResetButton_server(scroll, "Eyx", "om_reset_eyx")

    end)
end


-- SERVER register
Register_OMSettings({
    Name = "EYX Server settings",
    Command = "om_eyx_server_pill_command",
    Color = Color(0, 0, 255),
    TableType = "Killer",
    ServerOrClient = true,
    Image = "pills/pill_om_eyx.png"
})

-- client register
Register_OMSettings({
    Name = "EYX Client settings",
    Command = "om_eyx_pill_command",
    Color = Color(0, 0, 255),
    TableType = "Killer",
    ServerOrClient = false,
    Image = "pills/pill_om_eyx.png"
})