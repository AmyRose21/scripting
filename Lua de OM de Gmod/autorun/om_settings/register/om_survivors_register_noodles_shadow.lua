AddCSLuaFile()

if SERVER then

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
end

if CLIENT then
    CreateClientConVar("om_pills_action_shadow_ability_1_key", KEY_E, true, true, "Shadow Ability 1 keybind")
    CreateClientConVar("om_pills_action_shadow_ability_2_key", KEY_R, true, true, "Shadow Ability 2 keybind")
    CreateClientConVar("om_pills_action_camera_shadow", 1, true, true, "Camera Toggle is activated by abilities for Shadow")
    CreateClientConVar("om_pills_action_custombar_shadow", 0, true, true, "Camera Toggle is activated by abilities for Shadow")



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

        ["shadow_icon_Aim"] = "icons/shadow_icon_Aim.png",
        ["shadow_icon_dash_boost"] = "icons/shadow_icon_dash_boost.png",
        ["shadow_icon_reload"] = "icons/shadow_icon_reload.png",
        ["shadow_icon_chaos_snap"] = "icons/shadow_icon_chaos_snap.png",
    }
                
    local KeyDefaults2 = {
        ["Shadow"] = {
            om_pills_action_shadow_ability_1_key = KEY_E,
            om_pills_action_shadow_ability_2_key = KEY_R,
        },
    }



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
            icon = preservedmats["shadow_icon_Aim"],
            labelText = "Ability 1",
            convar = "om_pills_action_shadow_ability_1_key",
            color = Color(175, 0, 0, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["shadow_icon_reload"],
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
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Custom bullet Bar",
            convar = "om_pills_action_custombar_shadow",
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
end


-- SERVER register
Register_OMSettings({
    Name = "Shadow Server settings",
    Command = "om_Shadow_server_pill_command",
    Color = Color(185, 0, 0),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_shadow.png"
})

-- CLIENT register
Register_OMSettings({
    Name = "Shadow client settings",
    Command = "om_Shadow_pill_command",
    Color = Color(185, 0, 0),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_shadow.png"
})
