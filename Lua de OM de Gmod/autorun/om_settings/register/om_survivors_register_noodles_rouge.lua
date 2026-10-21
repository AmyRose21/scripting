AddCSLuaFile()

if SERVER then
    -- Rouge convar group
    CreateConVar("OUTCOMEMEMORIES_N_rouge_Resistance", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_Health", 125, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_passivereduction", 90, FCVAR_ARCHIVE, "", 0, 1e9)
    
    CreateConVar("OUTCOMEMEMORIES_N_rouge_walk", 60, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_run", 410, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_jumppower", 400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_jumpcd", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_rollingPower", 1400, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_speed", 550, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_launchy_power", 700, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_canuse_smokebomb", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_cd", 25, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_slowdownduration", 6, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_reward", 20, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_canuse_sweepkick", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_chargeup", 0.35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_miss", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_hit", 28, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_damageamouunt", 15, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_basestun", 5, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_canstunstack", 0, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_canragdoll", 1, FCVAR_ARCHIVE, "", 0, 1)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_reward", 30, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_starter", 30, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_maximum", 100, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_regen", 17, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_latches_maximum", 2, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_latch_energydrain", 0.35, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_latch_jump_energydrain", 15, FCVAR_ARCHIVE, "", 0, 1e9)

    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_maximum", 3, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_energydrain", 16, FCVAR_ARCHIVE, "", 0, 1e9)
    CreateConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_cdperjump", 6, FCVAR_ARCHIVE, "", 0, 1e9)

    concommand.Add("om_reset_rouge", function(ply)
        if IsValid(ply) and not ply:IsAdmin() then return end

        GetConVar("OUTCOMEMEMORIES_N_rouge_Resistance"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_Health"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passivereduction"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_walk"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_run"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_jumppower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_jumpcd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_rollingPower"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_speed"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_launchy_power"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_rouge_canuse_smokebomb"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_cd"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_slowdownduration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_smokebomb_reward"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_rouge_canuse_sweepkick"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_chargeup"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_duration"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_miss"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_cd_hit"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_damageamouunt"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_basestun"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_canstunstack"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_canragdoll"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_sweepkick_reward"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_starter"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_maximum"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_energy_regen"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_latches_maximum"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_latch_energydrain"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_latch_jump_energydrain"):Revert()

        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_maximum"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_energydrain"):Revert()
        GetConVar("OUTCOMEMEMORIES_N_rouge_passive_midairjumps_cdperjump"):Revert()
    end)
end

if CLIENT then
    CreateClientConVar("om_pills_action_rouge_ability_1_key", KEY_E, true, true, "Rouge Ability 1 keybind")
    CreateClientConVar("om_pills_action_rouge_ability_2_key", KEY_R, true, true, "Rouge Ability 2 keybind")
    CreateClientConVar("om_pills_action_camera_rouge", 1, true, true, "Camera Toggle is activated by abilities for Rouge")



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
        
        ["rouge_kick_om"] = "icons/rouge_kick_om.png",
        ["rouge_smokebomb_om"] = "icons/rouge_smokebomb_om.png",
        ["rouge_energyicon"] = "icons/rouge_energyicon.png",
        ["Knuckles_LatcSetting"] = "icons/Knuckles_LatcSetting.png",
    }
                
    local KeyDefaults2 = {
        ["Rouge"] = {
            om_pills_action_rouge_ability_1_key = KEY_E,
            om_pills_action_rouge_ability_2_key = KEY_R,
        },
    }



    concommand.Add("om_rouge_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Rouge pill",
            ["Image"] = "pills/pill_om_rouge.png",
        })
        local OM_Pills_Frame = recall_table["OM_Pills_Frame"]
        local topImage = recall_table["topImage"]
        local scroll = recall_table["scroll"]

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_smokebomb_om"],
            labelText = "Flash Bang",
            convar = "om_pills_action_rouge_ability_1_key",
            color = Color(175, 155, 155, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })
        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Sweep Kick Keybind",
            convar = "om_pills_action_rouge_ability_2_key",
            color = Color(211, 155, 155, 180),
            isexe = false,
            vartype = "bind",
            bioText = "Meow!",
        })

        OM_RegisterResetButton_client(scroll, "Rouge", KeyDefaults2)

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["OM_cameraset"],
            labelText = "Ability Camera Swapping",
            convar = "om_pills_action_camera_rouge",
            color = Color(80, 80, 80, 180),
            vartype = "bool",
            isexe = false,
        })
    end)

    concommand.Add("om_Rouge_server_pill_command", function()
        local recall_table = OM_RegisterSettingsPanel({
            ["Title"] = "Outcome Memories Pillpack - Rouge pill",
            ["Image"] = "pills/pill_om_rouge.png",
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

                    "OUTCOMEMEMORIES_N_rouge_Resistance",
                    "OUTCOMEMEMORIES_N_rouge_Health",
                    "OUTCOMEMEMORIES_N_rouge_passivereduction",
                    "OUTCOMEMEMORIES_N_rouge_walk",
                    "OUTCOMEMEMORIES_N_rouge_run",
                    "OUTCOMEMEMORIES_N_rouge_jumppower",
                    "OUTCOMEMEMORIES_N_rouge_jumpcd",
                    "OUTCOMEMEMORIES_N_rouge_rollingPower",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_speed",
                    "OUTCOMEMEMORIES_N_rouge_launchy_power",
                    "OUTCOMEMEMORIES_N_rouge_canuse_smokebomb",
                    "OUTCOMEMEMORIES_N_rouge_smokebomb_cd",
                    "OUTCOMEMEMORIES_N_rouge_smokebomb_slowdownduration",
                    "OUTCOMEMEMORIES_N_rouge_smokebomb_reward",
                    "OUTCOMEMEMORIES_N_rouge_canuse_sweepkick",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_chargeup",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_duration",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_cd_miss",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_cd_hit",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_damageamouunt",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_basestun",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_canstunstack",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_canragdoll",
                    "OUTCOMEMEMORIES_N_rouge_sweepkick_reward",
                    "OUTCOMEMEMORIES_N_rouge_passive_energy_starter",
                    "OUTCOMEMEMORIES_N_rouge_passive_energy_maximum",
                    "OUTCOMEMEMORIES_N_rouge_passive_energy_regen",
                    "OUTCOMEMEMORIES_N_rouge_passive_latches_maximum",
                    "OUTCOMEMEMORIES_N_rouge_passive_latch_energydrain",
                    "OUTCOMEMEMORIES_N_rouge_passive_latch_jump_energydrain",
                    "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_maximum",
                    "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_energydrain",
                    "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_cdperjump"
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
            convar = "OUTCOMEMEMORIES_N_rouge_Health",
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
            convar = "OUTCOMEMEMORIES_N_rouge_Resistance",
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
            convar = "OUTCOMEMEMORIES_N_rouge_walk",
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
            convar = "OUTCOMEMEMORIES_N_rouge_run",
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
            convar = "OUTCOMEMEMORIES_N_rouge_jumppower",
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
            convar = "OUTCOMEMEMORIES_N_rouge_jumpcd",
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
            convar = "OUTCOMEMEMORIES_N_rouge_rollingPower",
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
            icon = preservedmats["rouge_kick_om"],
            labelText = "sweep kick speed",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_speed",
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
            icon = preservedmats["jump_power"],
            labelText = "Latch launch power",
            convar = "OUTCOMEMEMORIES_N_rouge_launchy_power",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 200,
                max = 1000,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_smokebomb_om"],
            labelText = "Can use Smoke Bomb",
            convar = "OUTCOMEMEMORIES_N_rouge_canuse_smokebomb",
            color = Color(175, 35, 35, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_smokebomb_om"],
            labelText = "cd",
            convar = "OUTCOMEMEMORIES_N_rouge_smokebomb_cd",
            color = Color(80, 80, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 35,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_smokebomb_om"],
            labelText = "Slowdown debuff duration",
            convar = "OUTCOMEMEMORIES_N_rouge_smokebomb_slowdownduration",
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
            icon = preservedmats["rouge_energyicon"],
            labelText = "Energy reward",
            convar = "OUTCOMEMEMORIES_N_rouge_smokebomb_reward",
            color = Color(100, 100, 80, 180),
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


        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Can use Sweep Kick",
            convar = "OUTCOMEMEMORIES_N_rouge_canuse_sweepkick",
            color = Color(175, 100, 100, 180),
            vartype = "bool",
            isexe = false,
        })


        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Can Stun stack",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_canstunstack",
            color = Color(175, 100, 100, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Can Ragdoll",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_canragdoll",
            color = Color(175, 100, 100, 180),
            vartype = "bool",
            isexe = false,
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_kick_om"],
            labelText = "Charge Up Duraation",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_chargeup",
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
            icon = preservedmats["rouge_kick_om"],
            labelText = "Cd miss",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_cd_miss",
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
            icon = preservedmats["rouge_kick_om"],
            labelText = "Cd Hot",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_cd_hit",
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
            icon = preservedmats["rouge_kick_om"],
            labelText = "Damage amount",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_damageamouunt",
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
            icon = preservedmats["rouge_kick_om"],
            labelText = "Base Stun Amount",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_basestun",
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
            icon = preservedmats["rouge_energyicon"],
            labelText = "Energy reward",
            convar = "OUTCOMEMEMORIES_N_rouge_sweepkick_reward",
            color = Color(100, 100, 80, 180),
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

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = "Start Energy",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_energy_starter",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = "Max Energy",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_energy_maximum",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 200,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = " Energy regen",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_energy_regen",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 40,
                dec = 1,
                default = 400,
            }
        })

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["Knuckles_LatcSetting"],
            labelText = "Max Latches",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_latches_maximum",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = "Energy drain per tick",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_latch_energydrain",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 1,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["rouge_energyicon"],
            labelText = "Energy Drain upon jump",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_latch_jump_energydrain",
            color = Color(100, 100, 80, 180),
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


        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Max mid air jumps",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_maximum",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 100,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Midair jump energy drain",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_energydrain",
            color = Color(100, 100, 80, 180),
            isexe = false,
            vartype = 'slider',
            slidertable = {
                label = "slide",
                min = 0,
                max = 40,
                dec = 1,
                default = 400,
            }
        })

        om_RegisterKeyrow({
            parent = scroll,
            icon = preservedmats["jump_power"],
            labelText = "Cooldown count per jump",
            convar = "OUTCOMEMEMORIES_N_rouge_passive_midairjumps_cdperjump",
            color = Color(100, 100, 80, 180),
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

        OM_RegisterBorder({ parent = scroll, color = Color(56, 56, 56, 180), })

        OM_RegisterResetButton_server(scroll, "Rouge", "om_reset_rouge")

    end)
end


-- SERVER register
Register_OMSettings({
    Name = "Rouge Server settings",
    Command = "om_Rouge_server_pill_command",
    Color = Color(255, 175, 175),
    TableType = "Survivor",
    ServerOrClient = true,
    Image = "pills/pill_om_rouge.png"
})

-- CLIENT register
Register_OMSettings({
    Name = "Rouge client settings",
    Command = "om_rouge_pill_command",
    Color = Color(255, 175, 175),
    TableType = "Survivor",
    ServerOrClient = false,
    Image = "pills/pill_om_rouge.png"
})