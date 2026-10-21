AddCSLuaFile()

if SERVER then

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

end

if CLIENT then
    CreateClientConVar("om_pills_action_blaze_abillty1_key", KEY_E, true, true, "blaze ability1 keybind")
    CreateClientConVar("om_pills_action_blaze_abillty2_key", KEY_R, true, true, "blaze ability2 keybind")
    CreateClientConVar("om_pills_action_camera_blaze", 1, true, true, "Camera Toggle is activated by abilities for blaze")

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

        
        ["Roundhouse_kick"] = "icons/Roundhouse kick.png",
        ["burning_javelin"] = "icons/burning javelin.png",
        
        ["Knuckles_GlideSetting"] = "icons/Knuckles_GlideSetting.png",
        ["Knuckles_LatcSetting"] = "icons/Knuckles_LatcSetting.png",
        
        ["OM_flyingicon"] = "icons/OM_flyingicon.png",
        ["OM_flyingcdicon"] = "icons/OM_flyingcdicon.png",
        
        ["rouge_kick_om"] = "icons/rouge_kick_om.png",
        ["rouge_smokebomb_om"] = "icons/rouge_smokebomb_om.png",
        ["rouge_energyicon"] = "icons/rouge_energyicon.png",
        ["Knuckles_LatcSetting"] = "icons/Knuckles_LatcSetting.png",
    }
                
    local KeyDefaults2 = {
        ["Blaze"] = {
            om_pills_action_blaze_abillty1_key = KEY_E,
            om_pills_action_blaze_abillty2_key = KEY_R,
        },
    }

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

    
end


-- SERVER register
Register_OMSettings({
    Name = "Blaze Server settings",
    Command = "om_blaze_server_pill_command",
    Color = Color(255, 65, 255),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_blaze.png"
})

-- client register
Register_OMSettings({
    Name = "Blaze client settings",
    Command = "om_blaze_pill_command",
    Color = Color(255, 65, 255),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_blaze.png"
})