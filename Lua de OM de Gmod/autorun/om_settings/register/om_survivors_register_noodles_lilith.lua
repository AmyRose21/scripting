AddCSLuaFile()

if SERVER then

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
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage_damage", 10, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDash_canuse", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDash_slipperiness", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashCd", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashDuration", 10, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama_CD", 15, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage_cd_in", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage_cd_out", 10, FCVAR_ARCHIVE, "", 0, 1e9)

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
        GetConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage_damage"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDash_slipperiness"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashCd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_ChargeDashDuration"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_BluntTruama_CD"):Revert()
        
        GetConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage_cd_in"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_Lilith_FalseImage_cd_out"):Revert()
    end)


end

if CLIENT then
    CreateClientConVar("om_pills_action_lilith_ChargeDash", KEY_E, true, true, "Lilith charge keybind")
    CreateClientConVar("om_pills_action_lilith_BluntTruama", KEY_R, true, true, "Lilith blunt truama keybind")
    CreateClientConVar("om_pills_action_lilith_FalseImage", KEY_T, true, true, "Lilith False image keybind")
    CreateClientConVar("om_pills_action_camera_lilith", 1, true, true, "Camera Toggle is activated by abilities for Lilith")

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

        ["Spinball_Lilith"] = "icons/Spinball_Lilith.png",
        ["blunt_trauma"] = "icons/blunt_trauma.png",
        ["Lilith_Indicator_Move_Thingy"] = "icons/Lilith_Indicator_Move_Thingy.png",
    }
                
    local KeyDefaults2 = {
        ["Lilith"] = {
            om_pills_action_lilith_ChargeDash = KEY_E,
            om_pills_action_lilith_BluntTruama = KEY_R,
            om_pills_action_lilith_FalseImage = KEY_T,
        },
    }

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
            labelText = "False Image",
            convar = "om_pills_action_lilith_FalseImage",
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
                    "OUTCOMEMEMORIES_N_Lilith_FalseImage_damage",
                    "OUTCOMEMEMORIES_N_Lilith_ChargeDash_canuse",
                    "OUTCOMEMEMORIES_N_Lilith_ChargeDash_slipperiness",
                    "OUTCOMEMEMORIES_N_Lilith_ChargeDashCd",
                    "OUTCOMEMEMORIES_N_Lilith_ChargeDashDuration",
                    "OUTCOMEMEMORIES_N_Lilith_BluntTruama",
                    "OUTCOMEMEMORIES_N_Lilith_BluntTruama_CD",
                    "OUTCOMEMEMORIES_N_Lilith_FalseImage",
                    "OUTCOMEMEMORIES_N_Lilith_FalseImage_cd_in",
                    "OUTCOMEMEMORIES_N_Lilith_FalseImage_cd_out",
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
            labelText = "False Image Damage",
            convar = "OUTCOMEMEMORIES_N_Lilith_FalseImage_damage",
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
            labelText = "Can use False Image",
            convar = "OUTCOMEMEMORIES_N_Lilith_FalseImage",
            color = Color(35, 255, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Lilith_Indicator_Move_Thingy"],
            labelText = "Cooldown In",
            convar = "OUTCOMEMEMORIES_N_Lilith_FalseImage_cd_in",
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
            convar = "OUTCOMEMEMORIES_N_Lilith_FalseImage_cd_out",
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
    Name = "Lilith Server settings",
    Command = "om_lilith_server_pill_command",
    Color = Color(0, 255, 0),
    TableType = "Killer",
    ServerOrClient = true,
    Image = "pills/pill_om_lilith.png"
})

-- client register
Register_OMSettings({
    Name = "Lilith Client settings",
    Command = "om_lilith_pill_command",
    Color = Color(0, 255, 0),
    TableType = "Killer",
    ServerOrClient = false,
    Image = "pills/pill_om_lilith.png"
})