AddCSLuaFile()

if SERVER then

    CreateConVar("ShouldCollide_om", 0, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("PVPStun_OM", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("PVPStun_OM_exe", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("PVPStun_OM_clashing", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("Damage_OM", 0, FCVAR_ARCHIVE, "", 0, 1)

    CreateConVar("om_pills_action_2ndlife", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("om_pills_action_2canrevive", 0, FCVAR_ARCHIVE, "", 0, 1)

    -- om_movement_server_pill_command
    CreateConVar("OUTCOMEMEMORIES_N_rolling", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_bhopping", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
    CreateConVar("OUTCOMEMEMORIES_N_canmovewhileinair", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

    CreateConVar("OUTCOMEMEMORIES_N_ShouldSpeedBoost", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_damageboostdur", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    --CreateConVar("OUTCOMEMEMORIES_N_basedamageboost", 30, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_basemultiplyer", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    --CreateConVar("OUTCOMEMEMORIES_N_maxboost", 200, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_damageattack", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_ShouldSpeedBoost"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_damageboostdur"):Revert()
        --GetConVar("OUTCOMEMEMORIES_N_basedamageboost"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_basemultiplyer"):Revert()
        --GetConVar("OUTCOMEMEMORIES_N_maxboost"):Revert()
    end)

    CreateConVar("OUTCOMEMEMORIES_Stun_StunLimit", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_Stun_StunLimitDuration", 10, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_Stun_StunCanStackDuration", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_Stun_StunIframesAfterStun", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_Stun_StunIframesDuration", 4, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_Stun_StunMultiplyer", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_Stun_StunStackMultiplyer", 1, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_Stun_StunLimit_visual", 1, FCVAR_ARCHIVE, "", 0, 1)

    concommand.Add("om_reset_stun", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_Stun_StunLimit"):Revert()
        GetConVar("OUTCOMEMEMORIES_Stun_StunLimitDuration"):Revert()
        GetConVar("OUTCOMEMEMORIES_Stun_StunCanStackDuration"):Revert()
        GetConVar("OUTCOMEMEMORIES_Stun_StunIframesAfterStun"):Revert()
        GetConVar("OUTCOMEMEMORIES_Stun_StunIframesDuration"):Revert()
        GetConVar("OUTCOMEMEMORIES_Stun_StunMultiplyer"):Revert()
        GetConVar("OUTCOMEMEMORIES_Stun_StunStackMultiplyer"):Revert()
        GetConVar("OUTCOMEMEMORIES_Stun_StunLimit_visual"):Revert()
    end)
end

if CLIENT then
    CreateClientConVar("om_pills_chasemusic", 1, true, true, "Enabled chase music")
    CreateClientConVar("om_pills_Shouldshowstun", 1, true, true, "")
    CreateClientConVar("om_pills_chasemusicvolume", 50, true, true, "Volume of chasemusic") -- range from 0 to 100

    CreateClientConVar("om_pills_action_scrollin", KEY_0, true, true, "Scroll In")
    CreateClientConVar("om_pills_action_scrollout", KEY_9, true, true, "Scroll Out")

    CreateClientConVar("om_pills_action_revivecharacter", KEY_F, true, true, "The keybind for reviving a character")
    
    CreateClientConVar("om_pills_default_fov", 80, true, true, "fov")
    CreateClientConVar("om_pills_action_scrollin", KEY_0, true, true, "Scroll In")
    CreateClientConVar("om_pills_action_scrollout", KEY_9, true, true, "Scroll Out")
    CreateClientConVar("om_pills_action_ragdollthirdperson", 1, true, true, "")

    CreateClientConVar("om_pills_action_subtitles", 1, true, true, "Sub titles")
    CreateClientConVar("om_pills_action_hp", 1, true, true, "")
    CreateClientConVar("om_pills_action_bar", 1, true, true, "")
    CreateClientConVar("om_pills_action_abilitybar", 1, true, true, "")
    CreateClientConVar("om_pills_action_3dmodel", 1, true, true, "")
    CreateClientConVar("om_pills_action_customui", 1, true, true, "")
    CreateClientConVar("om_pills_action_bloodoverlay", 1, true, true, "")
    CreateClientConVar("om_pills_action_lowhpoverlay", 1, true, true, "")
    CreateClientConVar("om_pills_action_downedoverlay", 1, true, true, "")
    
    -- IMPORTANT
    CreateClientConVar("OM_pills_important_popup", 1, true, true, "")
    CreateClientConVar("OM_pills_important_epilepsy", 0, true, true, "")
    CreateClientConVar("OM_pills_important_Motionsickness", 0, true, true, "")

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
    }



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
    }
                
    local KeyDefaults2 = {
        ["Camera"] = {
            om_pills_default_fov = 80,
            om_pills_action_scrollin = KEY_0,
            om_pills_action_scrollout = KEY_9,
            om_pills_action_ragdollthirdperson = 1,
        },
    }
    
    concommand.Add("om_camera_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Camera Settings",
            ["Image"] = "pills/pill_om_sonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["FOV_om"],
            labelText = "FOV",
            convar = "om_pills_default_fov",
            color = Color(80, 80, 80, 180),
            isexe = false,
            bioText = "This controls your fov",
            vartype = 'slider',
            slidertable = {
                label = "fov",
                min = 60,
                max = 125,
                dec = 1,
                default = 80,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["zoom_in"],
            labelText = "Scroll In",
            convar = "om_pills_action_scrollin",
            color = Color(0, 150, 255, 180),
            isexe = false,
            bioText = "Upon clicking this keybind, it allows you to zooms your camera in",
            vartype = 'bind',
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["zoom_out"],
            labelText = "Scroll out",
            convar = "om_pills_action_scrollout",
            color = Color(0, 150*0.85, 255*0.85, 180),
            isexe = false,
            bioText = "Upon clicking this keybind, it allows you to zooms your camera out",
            vartype = 'bind',
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["subtitles_icon"],
            labelText = "Third person ragdoll camera",
            convar = "om_pills_action_ragdollthirdperson",
            color = Color(80, 80, 80, 180),
            isexe = true,
            bioText = "",
            vartype = 'bool',
            bioText = "\"I must put myself on the shoes of someone else!\" said little johnny before disabling this setting",
        })


        OM_RegisterResetButton_client(scroll, "Camera", KeyDefaults2)
    end)

    concommand.Add("om_ui_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - UI titles",
            ["Image"] = "pills/pill_om_sonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["subtitles_icon"],
            labelText = "Sub titles",
            convar = "om_pills_action_subtitles",
            color = Color(80, 80, 80, 180),
            isexe = true,
            bioText = "When an exe were to say something, UI titles will pop up",
            vartype = 'bool',
        })

        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "hp bar ui",
            convar = "om_pills_action_hp",
            color = Color(80, 255, 80, 180),
            isexe = true,
            vartype = 'bool',
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "bar meter ui",
            convar = "om_pills_action_bar",
            color = Color(165, 80, 80, 180),
            isexe = true,
            vartype = 'bool',
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "ability display ui",
            convar = "om_pills_action_abilitybar",
            color = Color(165, 80, 80, 180),
            isexe = true,
            vartype = 'bool',
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "3d model render ui",
            convar = "om_pills_action_3dmodel",
            color = Color(125, 125, 180, 180),
            isexe = true,
            vartype = 'bool',
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "pill custom hud",
            convar = "om_pills_action_bloodoverlay",
            color = Color(165, 125, 125, 180),
            isexe = true,
            vartype = 'bool',
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "low health hud",
            convar = "om_pills_action_lowhpoverlay",
            color = Color(165, 40, 40, 180),
            isexe = true,
            vartype = 'bool',
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "downed hud",
            convar = "om_pills_action_downedoverlay",
            color = Color(125, 165, 125, 180),
            isexe = true,
            vartype = 'bool',
        })
    end)


    concommand.Add("om_reviveCl_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Revive Preferences",
            ["Image"] = "pills/pill_om_sonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["self_revive"],
            labelText = "Revive keybind",
            convar = "om_pills_action_revivecharacter",
            color = Color(0, 150*0.85, 255*0.85, 180),
            isexe = false,
            bioText = "",
            vartype = 'bind',
        })
    end)


    concommand.Add("om_stunCl_pill_command", function()
        if IsValid(OM_Pills_Frame) then OM_Pills_Frame:Remove() end

        OM_Pills_Frame = vgui.Create("DFrame")
        OM_Pills_Frame:SetSize(700, 900)
        OM_Pills_Frame:Center()
        OM_Pills_Frame:SetTitle("Outcome Memories Pillpack - Stun preferences")
        OM_Pills_Frame:MakePopup()

        local topImage = vgui.Create("DImage", OM_Pills_Frame)
        topImage:Dock(TOP)
        topImage:SetTall(100)
        topImage:SetImage("pills/pill_om_amy.png")
        topImage:SetKeepAspect(true)

        local scroll = vgui.Create("DScrollPanel", OM_Pills_Frame)
        scroll:Dock(FILL)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["chase_theme_toggle"],
            labelText = "Spinning stars",
            convar = "om_pills_Shouldshowstun",
            color = Color(175, 80, 175, 180),
            isexe = true,
            bioText = "Disabling this gets rid of the stars twirling around the entity while stunned. Though this only works on your side and not any other player's side.",
            vartype = 'bool',
        })
    end)

    concommand.Add("om_movement_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Movement Settings",
            ["Image"] = "pills/pill_om_sonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rolling_icon_om"],
            labelText = "Rolling",
            convar = "OUTCOMEMEMORIES_N_rolling",
            color = Color(80, 80, 80, 180),
            isexe = true,
            bioText = "This setting determines if the survivors can roll",
            vartype = 'bool',
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["bhop_remake_om"],
            labelText = "Bhopping / no jump cd",
            convar = "OUTCOMEMEMORIES_N_bhopping",
            color = Color(80, 0, 80, 180),
            isexe = true,
            --bioText = "Type shit they'd be banning you for in Counter Strike",
            vartype = 'bool',
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["bhop_remake_om"],
            labelText = "Move while falling",
            convar = "OUTCOMEMEMORIES_N_canmovewhileinair",
            color = Color(80, 0, 80, 180),
            isexe = true,
            bioText = "",
            vartype = 'bool',
        })

        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["preset_icon_om"],
            labelText = "Presents",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'preset',
            presettable = {
                listofdefualtconvars = {
                    "OUTCOMEMEMORIES_N_ShouldSpeedBoost",
                    "OUTCOMEMEMORIES_N_damageboostdur",
                    --"OUTCOMEMEMORIES_N_basedamageboost",
                    "OUTCOMEMEMORIES_N_basemultiplyer",
                    --"OUTCOMEMEMORIES_N_maxboost",
                },
                name = "damage boost",
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["bhop_remake_om"],
            labelText = "Should damage speedboost",
            convar = "OUTCOMEMEMORIES_N_ShouldSpeedBoost",
            color = Color(80, 0, 80, 180),
            isexe = true,
            bioText = ".",
            vartype = 'bool',
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Damage Boost Duration",
            convar = "OUTCOMEMEMORIES_N_damageboostdur",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 50,
                dec = 1,
                default = 5,
            }
        })
        --[[
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Damage Damage Boost",
            convar = "OUTCOMEMEMORIES_N_basedamageboost",
            color = Color(80, 175, 80, 180),
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
        ]]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Damage Boost multiplyer percentage",
            convar = "OUTCOMEMEMORIES_N_basemultiplyer",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 400,
                dec = 1,
                default = 5,
            }
        })
        --[[
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["health_bar_icon"],
            labelText = "Max Boost",
            convar = "OUTCOMEMEMORIES_N_maxboost",
            color = Color(80, 175, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1000,
                dec = 1,
                default = 5,
            }
        })
        ]]

        OM_RegisterResetButton_server(scroll, "Boost", "om_reset_damageattack")
    end)

    concommand.Add("om_stun_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Stun Settings",
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
                    "OUTCOMEMEMORIES_Stun_StunLimit",
                    "OUTCOMEMEMORIES_Stun_StunLimitDuration",
                    "OUTCOMEMEMORIES_Stun_StunCanStackDuration",
                    "OUTCOMEMEMORIES_Stun_StunIframesAfterStun",
                    "OUTCOMEMEMORIES_Stun_StunIframesDuration",
                    "OUTCOMEMEMORIES_Stun_StunMultiplyer",
                    "OUTCOMEMEMORIES_Stun_StunStackMultiplyer",
                    "OUTCOMEMEMORIES_Stun_StunLimit_visual",
                },
                name = "Stuns",
            }
        })

        -- health related stuff
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Should Stuns be Limit",
            convar = "OUTCOMEMEMORIES_Stun_StunLimit",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
            bioText = "This makes it so that stuns are limited to a smaller number rather than able to be any number",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Stun Limit Amount",
            convar = "OUTCOMEMEMORIES_Stun_StunLimitDuration",
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
            labelText = "Shouldnt Have Stun Limit",
            convar = "OUTCOMEMEMORIES_Stun_StunCanStackDuration",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Iframes after stun",
            convar = "OUTCOMEMEMORIES_Stun_StunIframesAfterStun",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Iframes duration",
            convar = "OUTCOMEMEMORIES_Stun_StunIframesDuration",
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
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Stun multiplyer",
            convar = "OUTCOMEMEMORIES_Stun_StunMultiplyer",
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
            icon = preservedmats["Amy_OM_Noodles_hammer"],
            labelText = "Stun Stack multiplyer",
            convar = "OUTCOMEMEMORIES_Stun_StunStackMultiplyer",
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
        --[[
        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Amy_OM_Noodles_throw"],
            labelText = "Stun Visuals",
            convar = "OUTCOMEMEMORIES_Stun_StunLimit_visual",
            color = Color(255, 155, 255, 180),
            vartype = "bool",
            isexe = false,
        })
        ]]

    end)

    concommand.Add("om_music_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Music Settings",
            ["Image"] = "pills/pill_om_sonic.png",
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

        local scroll = vgui.Create("DScrollPanel", OM_Pills_Frame)
        scroll:Dock(FILL)


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["chase_theme_toggle"],
            labelText = "Active",
            convar = "om_pills_chasemusic",
            color = Color(175, 80, 175, 180),
            isexe = true,
            bioText = "This decides if you hear the chase music of the exes or not",
            vartype = 'bool',
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["smart_amazing_volume_om"],
            labelText = "Volume",
            convar = "om_pills_chasemusicvolume",
            color = Color(80, 175, 80, 180),
            isexe = false,
            bioText = "This slider controls the volume of the chase music of the exes",
            vartype = 'slider',
            slidertable = {
                label = "Volume",
                min = 0,
                max = 100,
                dec = 1,
                default = 50,
            }
        })

    end)

    concommand.Add("om_downingsystem_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Downin Settings",
            ["Image"] = "pills/pill_om_sonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["last_life_icon"],
            labelText = "Has 2nd Life",
            convar = "om_pills_action_2ndlife",
            color = Color(80, 80, 80, 180),
            isexe = true,
            bioText = "won't be dying today",
            vartype = 'bool',
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["self_revive"],
            labelText = "Can self revive",
            convar = "om_pills_action_2canrevive",
            color = Color(80, 80, 80, 180),
            isexe = true,
            bioText = "",
            vartype = 'bool',
        })
    end)


    concommand.Add("om_importantsettings_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Important Settings",
            ["Image"] = "pills/pill_om_sonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rolling_icon_om"],
            labelText = "ON SPAWN POP UP",
            convar = "OM_pills_important_popup",
            color = Color(255, 55, 55, 180),
            isexe = true,
            bioText = "DISABLING THIS SETTING WILL DISABLE THE POP UP UPON SPAWN! If you don't want the pop up to consitatly be on your screen upon spawn, I suggest you disable this setting.",
            vartype = 'bool',
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["epilblack_om"],
            labelText = "Epilepsy",
            convar = "OM_pills_important_epilepsy",
            color = Color(80, 80, 80, 180),
            isexe = true,
            bioText = "This will simpilize effects to not have any sort of flashing lights",
            vartype = 'bool',
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["motionblack_om"],
            labelText = "Motion Sickness",
            convar = "OM_pills_important_Motionsickness",
            color = Color(80, 80, 80, 180),
            isexe = true,
            bioText = "This will remove fov changing as a whole from the pills",
            vartype = 'bool',
        })
    end)

    concommand.Add("om_collision_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Collision Settings",
            ["Image"] = "pills/pill_om_sonic.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rolling_icon_om"],
            labelText = "Should collide",
            convar = "ShouldCollide_om",
            color = Color(255, 55, 55, 180),
            isexe = true,
            bioText = "",
            vartype = 'bool',
        })
    end)


end

-- SERVER register

Register_OMSettings({
    Name = "Movement settings",
    Command = "om_movement_server_pill_command",
    Color = Color(175, 175, 175),
    TableType = "Gameplay",
    ServerOrClient = true--,
    --Image = "pills/pill_om_sonic.png"
})

Register_OMSettings({
    Name = "Downing sysytem settings",
    Command = "om_downingsystem_pill_command",
    Color = Color(175, 175, 175),
    TableType = "Gameplay",
    ServerOrClient = true--,
    --Image = "pills/pill_om_sonic.png"
})

Register_OMSettings({
    Name = "Stun settings",
    Command = "om_stun_server_pill_command",
    Color = Color(175, 135, 175),
    TableType = "Gameplay",
    ServerOrClient = true--,
    --Image = "pills/pill_om_sonic.png"
})

Register_OMSettings({
    Name = "Collision system settings",
    Command = "om_collision_pill_command",
    Color = Color(175, 175, 175),
    TableType = "Gameplay",
    ServerOrClient = true--,
    --Image = "pills/pill_om_sonic.png"
})

-- client register

Register_OMSettings({
    Name = "Camera settings",
    Command = "om_camera_pill_command",
    Color = Color(175, 135, 135),
    TableType = "Gameplay",
    ServerOrClient = false--,
    --Image = "pills/pill_om_sonic.png"
})

Register_OMSettings({
    Name = "UI settings",
    Command = "om_ui_pill_command",
    Color = Color(135, 175, 135),
    TableType = "Gameplay",
    ServerOrClient = false--,
    --Image = "pills/pill_om_sonic.png"
})

Register_OMSettings({
    Name = "Music settings",
    Command = "om_music_pill_command",
    Color = Color(135, 135, 175),
    TableType = "Gameplay",
    ServerOrClient = false--,
    --Image = "pills/pill_om_sonic.png"
})
Register_OMSettings({
    Name = "Revive settings",
    Command = "om_reviveCl_pill_command",
    Color = Color(175, 175, 135),
    TableType = "Gameplay",
    ServerOrClient = false--,
    --Image = "pills/pill_om_sonic.png"
})
Register_OMSettings({
    Name = "Stun settings",
    Command = "om_stunCl_pill_command",
    Color = Color(175, 135, 175),
    TableType = "Gameplay",
    ServerOrClient = false--,
    --Image = "pills/pill_om_sonic.png"
})
