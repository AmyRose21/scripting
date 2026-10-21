AddCSLuaFile()

if SERVER then
    -- Mighty convar group
    CreateConVar("OUTCOMEMEMORIES_N_mighty_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_Health", 115, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_mighty_passivereduction", 75, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_mighty_walk", 60, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_run", 415, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_rollingPower", 1400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_mighty_charge", 1300, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_mighty_canusevoiceline", 1, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMORIES_N_mighty_ShouldSlowdebuff", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_Slowdebuffperability", 0.95, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("OUTCOMEMORIES_N_mighty_Celebration", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_CelebrationDuration", 1.5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_CelebrationSpeedmultiplyer", 2, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_mighty_cover_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_cover_cd_start", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_cover_cd_cancel", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_cover_cd_pary", 12, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_cover_reduction", 20, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_cover_cdgodownmultiplyer", 75, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd", 28, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd_hit", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd_stunhit", 35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_stunduration", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_stunstacking", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_canragdoll", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_stundamage", 17, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_bouldercdadd", 12, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_exponensialram_takecovercdadd", 7, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_cd", 32, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stunduration", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_ramaddcd", 6, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_TakeCoveraddcd", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stunstacking", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_canragdoll", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stundamage", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_mighty_boulderthrow_ThrowDisabledDuration", 2, FCVAR_ARCHIVE, "", 0, 1e9)


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

        GetConVar("OUTCOMEMORIES_N_mighty_ShouldSlowdebuff"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_Slowdebuffperability"):Revert()

        GetConVar("OUTCOMEMORIES_N_mighty_Celebration"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_CelebrationDuration"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_CelebrationSpeedmultiplyer"):Revert()

        GetConVar("OUTCOMEMORIES_N_mighty_cover_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_start"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_cancel"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_cover_cd_pary"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_cover_reduction"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_cover_cdgodownmultiplyer"):Revert()

        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd_hit"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_cd_stunhit"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_stunstacking"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_canragdoll"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_stundamage"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_bouldercdadd"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_exponensialram_takecovercdadd"):Revert()

        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_cd"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_ramaddcd"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_TakeCoveraddcd"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stunstacking"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_canragdoll"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_stundamage"):Revert()
        GetConVar("OUTCOMEMORIES_N_mighty_boulderthrow_ThrowDisabledDuration"):Revert()
    end)
end

if CLIENT then
    CreateClientConVar("om_pills_action_mighty_TakeCover", KEY_E, true, true, "Mighty's cover keybind")
    CreateClientConVar("om_pills_action_mighty_ExponensialRam", KEY_R, true, true, "Mighty's ram keybind")
    CreateClientConVar("om_pills_action_mighty_BoulderThrow", KEY_T, true, true, "Mighty's boulder throw keybind")
    CreateClientConVar("om_pills_action_camera_mighty", 1, true, true, "Camera Toggle is activated by abilities for Mighty")

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

        ["Cover_Mighty_om"] = "icons/Cover_Mighty_om.png",
        ["Charge_Mighty_om"] = "icons/Charge_Mighty_om.png",
        ["BoulderMighty_om"] = "icons/BoulderMighty_om.png",
    }
                
    local KeyDefaults2 = {
        ["Mighty"] = {
            om_pills_action_mighty_TakeCover = KEY_E,
            om_pills_action_mighty_ExponensialRam = KEY_R,
            om_pills_action_mighty_BoulderThrow = KEY_T,
        },
    }

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

                    "OUTCOMEMORIES_N_mighty_ShouldSlowdebuff",
                    "OUTCOMEMORIES_N_mighty_Slowdebuffperability",

                    "OUTCOMEMORIES_N_mighty_Celebration",
                    "OUTCOMEMORIES_N_mighty_CelebrationDuration",
                    "OUTCOMEMORIES_N_mighty_CelebrationSpeedmultiplyer",

                    "OUTCOMEMORIES_N_mighty_cover_useable",
                    "OUTCOMEMORIES_N_mighty_cover_cd_start",
                    "OUTCOMEMORIES_N_mighty_cover_cd_cancel",
                    "OUTCOMEMORIES_N_mighty_cover_cd_pary",
                    "OUTCOMEMORIES_N_mighty_cover_reduction",
                    "OUTCOMEMORIES_N_mighty_cover_cdgodownmultiplyer",

                    "OUTCOMEMORIES_N_mighty_exponensialram_useable",
                    "OUTCOMEMORIES_N_mighty_exponensialram_cd",
                    "OUTCOMEMORIES_N_mighty_exponensialram_cd_hit",
                    "OUTCOMEMORIES_N_mighty_exponensialram_cd_stunhit",
                    "OUTCOMEMORIES_N_mighty_exponensialram_stunduration",
                    "OUTCOMEMORIES_N_mighty_exponensialram_stunstacking",
                    "OUTCOMEMORIES_N_mighty_exponensialram_canragdoll",
                    "OUTCOMEMORIES_N_mighty_exponensialram_stundamage",
                    "OUTCOMEMORIES_N_mighty_exponensialram_bouldercdadd",
                    "OUTCOMEMORIES_N_mighty_exponensialram_takecovercdadd",

                    "OUTCOMEMORIES_N_mighty_boulderthrow_useable",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_cd",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_stunduration",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_ramaddcd",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_TakeCoveraddcd",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_stunstacking",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_canragdoll",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_stundamage",
                    "OUTCOMEMORIES_N_mighty_boulderthrow_ThrowDisabledDuration"
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
            labelText = "Slowdown debuff",
            convar = "OUTCOMEMORIES_N_mighty_ShouldSlowdebuff",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "slowdown multiplyer per ability",
            convar = "OUTCOMEMORIES_N_mighty_Slowdebuffperability",
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

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "Should Celebrate",
            convar = "OUTCOMEMORIES_N_mighty_Celebration",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "Celebrate Duration",
            convar = "OUTCOMEMORIES_N_mighty_CelebrationDuration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 5,
                dec = 1,
                default = 20,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "Celebrate Speed Multiplyer",
            convar = "OUTCOMEMORIES_N_mighty_CelebrationSpeedmultiplyer",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 5,
                dec = 1,
                default = 20,
            }
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
            labelText = "Cover cd parry",
            convar = "OUTCOMEMORIES_N_mighty_cover_cd_pary",
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

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Cover_Mighty_om"],
            labelText = "Other CD reduction",
            convar = "OUTCOMEMORIES_N_mighty_cover_cdgodownmultiplyer",
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
            labelText = "Ram cd cancel Hit",
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
            labelText = "Ram cd Stun Hit",
            convar = "OUTCOMEMORIES_N_mighty_exponensialram_cd_stunhit",
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

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Tae Cover CD add",
            convar = "OUTCOMEMORIES_N_mighty_exponensialram_takecovercdadd",
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
            icon = preservedmats["Charge_Mighty_om"],
            labelText = "Boulder CD add",
            convar = "OUTCOMEMORIES_N_mighty_exponensialram_bouldercdadd",
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
            labelText = "Ram add cd",
            convar = "OUTCOMEMORIES_N_mighty_boulderthrow_ramaddcd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
                dec = 1,
                default = 20,
            }
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["BoulderMighty_om"],
            labelText = "Take cover add cd",
            convar = "OUTCOMEMORIES_N_mighty_boulderthrow_TakeCoveraddcd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 10,
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

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["BoulderMighty_om"],
            labelText = "Throw Disabled Duration",
            convar = "OUTCOMEMORIES_N_mighty_boulderthrow_ThrowDisabledDuration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 5,
                dec = 1,
                default = 20,
            }
        })

        OM_RegisterResetButton_server(scroll, "Mighty", "om_reset_mighty")

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

-- CLIENT register
Register_OMSettings({
    Name = "Mighty client settings",
    Command = "om_mighty_pill_command",
    Color = Color(135, 0, 0),
    TableType = "Survivor", 
    ServerOrClient = false,
    Image = "pills/pill_om_mighty.png"
})