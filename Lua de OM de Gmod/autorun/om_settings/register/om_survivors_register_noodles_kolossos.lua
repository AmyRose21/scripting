AddCSLuaFile()

if SERVER then

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
    CreateConVar("OUTCOMEMEMORIES_N_Kolosssos_BlockDuration", 3.5, FCVAR_ARCHIVE, "", 0, 1e9)

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
        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_BlockDuration"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Kolosssos_CanClimb"):Revert()
    end)
end

if CLIENT then
    CreateClientConVar("om_pills_action_kolossos_charge_key", KEY_E, true, true, "kolossos charge keybind")
    CreateClientConVar("om_pills_action_kolossos_grab_key", KEY_R, true, true, "kolossos grab keybind")
    CreateClientConVar("om_pills_action_kolossos_indicator_key", KEY_T, true, true, "kolossos indicator keybind")
    CreateClientConVar("om_pills_action_kolossos_block_key", KEY_I, true, true, "kolossos block keybind")
    CreateClientConVar("om_pills_action_camera_kolossos", 1, true, true, "Camera Toggle is activated by abilities for kolossos")

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

        ["Kolossos_hi"] = "icons/Kolossos_hi.png",
        ["KOLOSSOS_PUNCH"] = "icons/KOLOSSOS_PUNCH.png",
        ["kolossos_block"] = "icons/kolossos_block.png",
        ["kolossos_peek"] = "icons/kolossos_peek.png",

    }
                
    local KeyDefaults2 = {
        ["Kolossos"] = {
            om_pills_action_kolossos_charge_key = KEY_E,
            om_pills_action_kolossos_grab_key = KEY_R,
            om_pills_action_kolossos_indicator_key = KEY_T,
            om_pills_action_kolossos_block_key = KEY_I,
        },
    }

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
                    "OUTCOMEMEMORIES_N_Kolosssos_BlockDuration",
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
            labelText = "Block Cooldown",
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

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Kolossos_hi"],
            labelText = "Block duration",
            convar = "OUTCOMEMEMORIES_N_Kolosssos_BlockDuration",
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
end


-- SERVER register
Register_OMSettings({
    Name = "Kolossos Server settings",
    Command = "om_Kolossos_server_pill_command",
    Color = Color(0, 0, 255),
    TableType = "Killer",
    ServerOrClient = true,
    Image = "pills/pill_om_kolossos.png"
})

-- client register
Register_OMSettings({
    Name = "Kolossos Client settings",
    Command = "om_kolossos_pill_command",
    Color = Color(0, 0, 255),
    TableType = "Killer",
    ServerOrClient = false,
    Image = "pills/pill_om_kolossos.png"
})