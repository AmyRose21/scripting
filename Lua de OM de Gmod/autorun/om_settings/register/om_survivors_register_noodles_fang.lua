AddCSLuaFile()

if SERVER then
    -- Fang convar group
    CreateConVar("OUTCOMEMEMORIES_N_fang_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_fang_Health", 100, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_fang_walk", 60, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_fang_run", 412, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_fang_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_fang_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_fang_rollingPower", 1800, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_fang_gun_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_stunstack", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_canragdoll", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_corkdamage", 10, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_corkstunduration", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_cancelcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_misscd", 6, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_Onetarget", 9, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_Twotarget", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMORIES_N_fang_gun_ThreeTarget", 25, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMORIES_N_fang_bounce_useable", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMORIES_N_fang_bounce_cd", 20, FCVAR_ARCHIVE, "", 0, 1e9)


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
        GetConVar("OUTCOMEMORIES_N_fang_gun_corkdamage"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_corkstunduration"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_cancelcd"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_misscd"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_Onetarget"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_Twotarget"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_gun_ThreeTarget"):Revert()

        GetConVar("OUTCOMEMORIES_N_fang_bounce_useable"):Revert()
        GetConVar("OUTCOMEMORIES_N_fang_bounce_cd"):Revert()
    end)
end

if CLIENT then
    CreateClientConVar("om_pills_action_fang_gun_key", KEY_E, true, true, "Fang Gun keybind")
    CreateClientConVar("om_pills_action_fang_bounce_key", KEY_T, true, true, "Fang Bounce keybind")
    CreateClientConVar("om_pills_action_camera_fang", 1, true, true, "Camera Toggle is activated by abilities for Fang")


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

        ["fang_bounce_icon"] = "icons/fang_bounce_icon.png",
        ["fang_gun_icon"] = "icons/fang_gun_icon.png",
    }
                
    local KeyDefaults2 = {
        ["Fang"] = {
            om_pills_action_fang_gun_key = KEY_E,
            om_pills_action_fang_bounce_key = KEY_T,
        },
    }



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
                    "OUTCOMEMORIES_N_fang_gun_corkdamage",
                    "OUTCOMEMORIES_N_fang_gun_corkstunduration",
                    "OUTCOMEMORIES_N_fang_gun_cancelcd",
                    "OUTCOMEMORIES_N_fang_gun_misscd",
                    "OUTCOMEMORIES_N_fang_gun_Onetarget",
                    "OUTCOMEMORIES_N_fang_gun_Twotarget",
                    "OUTCOMEMORIES_N_fang_gun_ThreeTarget",

                    "OUTCOMEMORIES_N_fang_bounce_useable",
                    "OUTCOMEMORIES_N_fang_bounce_cd",

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
            labelText = "Cork Damage",
            convar = "OUTCOMEMORIES_N_fang_gun_corkdamage",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = "slider",
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 10,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Cork Stun Duration",
            convar = "OUTCOMEMORIES_N_fang_gun_corkstunduration",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = "slider",
            slidertable = {
                label = "slide",
                min = 0,
                max = 15,
                dec = 1,
                default = 3,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Cancel Cooldown",
            convar = "OUTCOMEMORIES_N_fang_gun_cancelcd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = "slider",
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 6,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Miss Cooldown",
            convar = "OUTCOMEMORIES_N_fang_gun_misscd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = "slider",
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 6,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "One Target Cooldown",
            convar = "OUTCOMEMORIES_N_fang_gun_Onetarget",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = "slider",
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 9,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Two Target Cooldown",
            convar = "OUTCOMEMORIES_N_fang_gun_Twotarget",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = "slider",
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 15,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["fang_gun_icon"],
            labelText = "Three Target Cooldown",
            convar = "OUTCOMEMORIES_N_fang_gun_ThreeTarget",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = "slider",
            slidertable = {
                label = "slide",
                min = 0,
                max = 30,
                dec = 1,
                default = 25,
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
            labelText = "Bounce Cooldown",
            convar = "OUTCOMEMORIES_N_fang_bounce_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = "slider",
            slidertable = {
                label = "slide",
                min = 0,
                max = 60,
                dec = 1,
                default = 20,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        OM_RegisterResetButton_server(scroll, "Fang", "om_reset_fang")

    end)
end


-- SERVER register
Register_OMSettings({
    Name = "Fang Server settings",
    Command = "om_Fang_server_pill_command",
    Color = Color(135, 0, 135),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_fang.png"
})

-- CLIENT register
Register_OMSettings({
    Name = "Fang client settings",
    Command = "om_fang_pill_command",
    Color = Color(135, 0, 135),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_fang.png"
})