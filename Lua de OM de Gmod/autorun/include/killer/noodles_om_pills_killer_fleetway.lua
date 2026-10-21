
AddCSLuaFile()

local function AdvancedPillSound(SoundData, ent)
    if SERVER then
        if IsValid(ent) then
            SoundData = SoundData or {}
            SoundData.stringe = SoundData.stringe or {}
            SoundData.soundLevel = SoundData.soundLevel or 75
            SoundData.pitchPercent = SoundData.pitchPercent or 100
            SoundData.volume = SoundData.volume or 1
            SoundData.channel = SoundData.channel or CHAN_AUTO
            SoundData.soundFlags = SoundData.soundFlags or 0
            SoundData.dsp = SoundData.dsp or 0
            SoundData.filter = SoundData.filter or nil

            local chosenSound = SoundData.stringe

            if istable(SoundData.stringe) then
                local index = math.random(1, #SoundData.stringe)
                chosenSound = SoundData.stringe[index]
            end

            ent:EmitSound(
                chosenSound,
                SoundData.soundLevel,
                SoundData.pitchPercent,
                SoundData.volume,
                SoundData.channel,
                SoundData.soundFlags,
                SoundData.dsp,
                SoundData.filter
            )

            if ent.formTable then
                if ent.formTable.OM_subtitles then
                    if ent.formTable.OM_subtitles[chosenSound] then
                        for i, ply in ipairs(player.GetAll()) do
                            if ply:GetPos():Distance(ent:GetPos()) < 2000 then

                                net.Start("OM_Subtitle_n")
                                    net.WriteString(ent.formTable.OM_subtitles[chosenSound])
                                net.Send(ply)

                            end
                        end                

                    end

                end
            end
        end
        return true
    end
end

local preservedmats = {
    ["fleetway_OM_dash"] = Material("icons/CHAOS_DASH_-_copia.png"),
    ["fleetway_OM_laser"] = Material("icons/sonic_eyes_-_copia.png"),
    ["fleetway_OM_drain"] = Material("icons/fateful_drain_-_copia.png"),
    ["fleetway_OM_burst"] = Material("icons/bURST_-_copia.png"),
}
pk_pills.register('pill_om_fleetway', {

    printName='Fleetway',
    Outcomememories='Fleetway',
    Outcomememories_material="Organic",
        
    model="models/Noodles/OM/fleetway.mdl",
    --[[
    hull = Vector(20,20,60),
    duckBy = 14,
    ]]

    modelScale='1',

    noragdoll = false,
    muteSteps = true,
    type='ply',
    
    OM_subtitles = {
        ["OM/Fleetway/chaosdash_1.wav"] = "Here it comes!",
        ["OM/Fleetway/chaosdash_2.wav"] = "WATCH OUT!",
        ["OM/Fleetway/chaosdash_3.wav"] = "CHOO CHOO!",
        
        ["OM/Fleetway/fleet laser 1.wav"] = "Get out of my FACE!",
        ["OM/Fleetway/fleet laser 2.wav"] = "TAKE THIS!",
        ["OM/Fleetway/fleet laser 3.wav"] = "GRRRGGGGGHHHHHAAAAAAAAAAAAAAGGGGHHH!!!",
        
        ["OM/Fleetway/FleetBurst1.wav"] = "That's enough!",
        ["OM/Fleetway/FleetBurst2.wav"] = "AGHHHHHH!!!",
        ["OM/Fleetway/FleetBurst3.wav"] = "Back off!",
        
        ["OM/Fleetway/fatefuldrain1.wav"] = "Not so fast!",
        ["OM/Fleetway/fatefuldrain2.wav"] = "Tag your it!",
        ["OM/Fleetway/fatefuldrain3.wav"] = "Come here!",

        ["OM/Fleetway/Phase2_1.wav"] = "I'll show you what I am capable of!",
        ["OM/Fleetway/Phase2_2.wav"] = "You're wasting my time!",
        ["OM/Fleetway/Phase2_3.wav"] = "Enough!",

        ["OM/Fleetway/AmyKill1.wav"] = "Sonic never wanted you rose, When will you learn?",
        ["OM/Fleetway/AmyKill2.wav"] = "Your affection's laughable, not like he'd notice.",

        ["OM/Fleetway/SonicKill1.wav"] = "Look at me, look at how strong I am with out you!",
        ["OM/Fleetway/SonicKill2.wav"] = "You and I may share the same body, but we'll never be the same!",

        ["OM/Fleetway/MetalKill1.wav"] = "Cheap scrap you is hardly worth the effort.",
        ["OM/Fleetway/MetalKill2.wav"] = "Metal rusts, I don't!",

        ["OM/Fleetway/KnucklesKill1.wav"] = "The guardion falls, with that, the world crumbles!",
        ["OM/Fleetway/KnucklesKill2.wav"] = "Does it look like I need, YOUR power?",

        ["OM/Fleetway/FleetwaySurvDown1.wav"] = "You should see your face when I hit you, PRICELESS!",
        ["OM/Fleetway/FleetwaySurvDown2.wav"] = "Don't bleed out just yet, we are just getting started!",
        ["OM/Fleetway/FleetwaySurvDown3.wav"] = "You thought you can beat me? That is ADORABLE!!",
    },

    anims={
        default={
            idle="idle",
            run="run",
            walk="walk",
            jump2="jump",
            glide="fall",
            laserofdestructionstart="laserofdestructionchargeidle",
            AbsorbEnd = "AbsorbEnd",
            KillAnim = "KillAnim",
        },
        ShouldMoveRotate_lerpspeed={
            idle= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then return 40 end
                return 8
            end,
            fall= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then return 40 end
                return 8
            end,
            run= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then return 40 end
                return 4
            end,
            walk= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then return 40 end
                return 4
            end,
        },
            
        ShouldMoveRotate={
            laserofdestructionchargeidle= function(ent) 
                return 'assignedagnles' 
            end,
            laserofdestructionstart= function(ent) 
                return 'assignedagnles' 
            end,
            idle= function(ent) 
                if ent:GetNW2Bool("FatefulDrainMode_moving") then
                    return "notshftlock"
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    ent:SetNW2Angle("pill_assignedangle", ply:GetVelocity():Angle())
                    return "assignedagnles"
                end
                return 'notanything' 
            end,
            run= function(ent) 
                if ent:GetNW2Bool("FatefulDrainMode_moving") then
                    return "notshftlock"
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    ent:SetNW2Angle("pill_assignedangle", ply:GetVelocity():Angle())
                    return "assignedagnles"
                end

                if ply:GetVelocity():Length() <= 0 then return end

                local flyingangles = ply:GetVelocity():Angle()
                flyingangles.p = 0

                local function GetMovement(ignoreZ)
                    local puppet = ent:GetPuppet()
                    if ply:GetVelocity():Length()<=0 then return Vector(0, 0, 0) end
                    local dir = ply:GetVelocity()
                    if ignoreZ then dir.z = 0 end
                    return (puppet:GetAngles()-dir:Angle()):Forward()
                end

                local function IsMovingUp(ent) return math.Round(GetMovement().z) > 0 end
                local function IsMovingDown(ent) return math.Round(GetMovement().z) < 0 end
                local function IsMovingForward(ent) return math.Round(GetMovement().x) > 0 end
                local function IsMovingBackward(ent) return math.Round(GetMovement().x) < 0 end
                local function IsMovingRight(ent) return math.Round(GetMovement().y) > 0 end
                local function IsMovingLeft(ent) return math.Round(GetMovement().y) < 0 end
                local function IsMovingForwardLeft(ent) return IsMovingForward(ent) and IsMovingLeft(ent) end
                local function IsMovingForwardRight(ent) return IsMovingForward(ent) and IsMovingRight(ent) end

                local rotationfactor = math.Clamp(ply:GetVelocity():Length()/400, 0, 2.5)

                if IsMovingLeft(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), -7 * rotationfactor)
                elseif IsMovingRight(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), 7 * rotationfactor)
                else
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), 0)
                end
                if IsMovingForward(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetRight(), -7 * rotationfactor)
                elseif IsMovingBackward(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetRight(), 7 * rotationfactor)
                else
                end

                ent:SetNW2Angle("pill_assignedangle", flyingangles)

                return "assignedagnles"
                --return 'notshftlock' 
            end,
            walk= function(ent) 
                if ent:GetNW2Bool("FatefulDrainMode_moving") then
                    return "notshftlock"
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    ent:SetNW2Angle("pill_assignedangle", ply:GetVelocity():Angle())
                    return "assignedagnles"
                end


                if ply:GetVelocity():Length() <= 0 then return end

                local flyingangles = ply:GetVelocity():Angle()
                flyingangles.p = 0

                local function GetMovement(ignoreZ)
                    local puppet = ent:GetPuppet()
                    if ply:GetVelocity():Length()<=0 then return Vector(0, 0, 0) end
                    local dir = ply:GetVelocity()
                    if ignoreZ then dir.z = 0 end
                    return (puppet:GetAngles()-dir:Angle()):Forward()
                end

                local function IsMovingUp(ent) return math.Round(GetMovement().z) > 0 end
                local function IsMovingDown(ent) return math.Round(GetMovement().z) < 0 end
                local function IsMovingForward(ent) return math.Round(GetMovement().x) > 0 end
                local function IsMovingBackward(ent) return math.Round(GetMovement().x) < 0 end
                local function IsMovingRight(ent) return math.Round(GetMovement().y) > 0 end
                local function IsMovingLeft(ent) return math.Round(GetMovement().y) < 0 end
                local function IsMovingForwardLeft(ent) return IsMovingForward(ent) and IsMovingLeft(ent) end
                local function IsMovingForwardRight(ent) return IsMovingForward(ent) and IsMovingRight(ent) end

                local rotationfactor = math.Clamp(ply:GetVelocity():Length()/400, 0, 2.5)

                if IsMovingLeft(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), -7 * rotationfactor)
                elseif IsMovingRight(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), 7 * rotationfactor)
                else
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), 0)
                end
                if IsMovingForward(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetRight(), -7 * rotationfactor)
                elseif IsMovingBackward(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetRight(), 7 * rotationfactor)
                else
                end

                ent:SetNW2Angle("pill_assignedangle", flyingangles)

                return "assignedagnles"
                --return 'notshftlock' 
            end,
            jump= function(ent)
                if ent:GetNW2Bool("FatefulDrainMode_moving") then
                    return "notshftlock"
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end 

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    ent:SetNW2Angle("pill_assignedangle", ply:GetVelocity():Angle())
                    return "assignedagnles"
                end
                return 'notshftlock'
            end,
            fall= function(ent)
                if ent:GetNW2Bool("FatefulDrainMode_moving") then
                    return "notshftlock"
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end
                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
                local ply = ent:GetPillUser()
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    ent:SetNW2Angle("pill_assignedangle", ply:GetVelocity():Angle())
                    return "assignedagnles"
                end

                if ply:GetVelocity():Length() <= 0 then return end

                local flyingangles = ply:GetVelocity():Angle()
                flyingangles.p = 0

                local function GetMovement(ignoreZ)
                    local puppet = ent:GetPuppet()
                    if ply:GetVelocity():Length()<=0 then return Vector(0, 0, 0) end
                    local dir = ply:GetVelocity()
                    if ignoreZ then dir.z = 0 end
                    return (puppet:GetAngles()-dir:Angle()):Forward()
                end

                local function IsMovingUp(ent) return math.Round(GetMovement().z) > 0 end
                local function IsMovingDown(ent) return math.Round(GetMovement().z) < 0 end
                local function IsMovingForward(ent) return math.Round(GetMovement().x) > 0 end
                local function IsMovingBackward(ent) return math.Round(GetMovement().x) < 0 end
                local function IsMovingRight(ent) return math.Round(GetMovement().y) > 0 end
                local function IsMovingLeft(ent) return math.Round(GetMovement().y) < 0 end
                local function IsMovingForwardLeft(ent) return IsMovingForward(ent) and IsMovingLeft(ent) end
                local function IsMovingForwardRight(ent) return IsMovingForward(ent) and IsMovingRight(ent) end

                local rotationfactor = math.Clamp(ply:GetVelocity():Length()/400, 0, 2.5)

                if IsMovingLeft(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), -5 * rotationfactor)
                elseif IsMovingRight(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), 5 * rotationfactor)
                else
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetForward(), 0)
                end
                if IsMovingForward(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetRight(), -5 * rotationfactor)
                elseif IsMovingBackward(ent) then
                    flyingangles:RotateAroundAxis(ent:GetPuppet():GetRight(), 5 * rotationfactor)
                else
                end

                if move == Vector(0,0,0) then
                end

                ent:SetNW2Angle("pill_assignedangle", flyingangles)

                return "assignedagnles"
            end,
            AbsorbEnd = function(ent)
                return 'notanything' 
            end,
            Spindash=function(ent)
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                local ply = ent:GetPillUser()
                local dir = ply:GetVelocity():GetNormalized()
                local aheadPos = ply:GetPos() + dir * 5
                local ang = (aheadPos - ply:GetPos()):Angle()
                ent:SetNW2Angle("pill_assignedangle",ang)
                return "assignedagnles"
            end,

            Fly=function(ent)
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "assignedagnles"
                end
                if ent:GetNW2Bool("FatefulDrainMode") then
                    return "shiftlock"
                end

                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "assignedagnles"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then 
                    return "assignedagnles"
                end
            end,
        },

        ShouldAlternate={
            jump= function(ent)
                local ply = ent:GetPillUser()
                if ent:GetNW2Bool("FatefulDrainMode_moving") then
                    return "FatefulDrain"
                end
            end,
            fall = function(ent)
                local ply = ent:GetPillUser()
                if ent:GetNW2Bool("FatefulDrainMode_moving") then
                    return "FatefulDrain"
                end
                if ent:GetNW2Float("RollEndTime_om", 0 ) > CurTime() then
                    return "Jump"
                end
                
                if ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing") then
                    return "FatefulDrain_absorbenemy"
                end
                if ent:GetNW2Float("FatefulDrain_Wait") >= CurTime() then
                    return "FatefulDrain_idle"
                end
                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "laserdestructionfire"
                end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "Stunned"
                end
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    return "Spindash"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then
                    local ply = ent:GetPillUser()
                    ent.Flightmovelength = ent.Flightmovelength or 0
                    if ent.Flightmovelength <= 1 then
                        return "Idle"
                    end

                    if (ent.Flightmovelength or 0) + 1 >= ent:GetNW2Float("Fleetway_flightspeed") then
                        return "flymovement"
                    else
                        return "Walk"
                    end
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "laserofdestructionchargeidle"
                end
            end,
            idle= function(ent)
                local ply = ent:GetPillUser()
                if ent:GetNW2Bool("FatefulDrainMode_moving") then
                    return "FatefulDrain"
                end
                if ent:GetNW2Float("RollEndTime_om", 0 ) > CurTime() then
                    return "Jump"
                end
                if ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing") then
                    return "FatefulDrain_absorbenemy"
                end
                if ent:GetNW2Float("FatefulDrain_Wait") >= CurTime() then
                    return "FatefulDrain_idle"
                end
                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "laserdestructionfire"
                end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "Stunned"
                end
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    return "Spindash"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then
                    local ply = ent:GetPillUser()
                    ent.Flightmovelength = ent.Flightmovelength or 0
                    if ent.Flightmovelength <= 1 then
                        return "Idle"
                    end

                    if (ent.Flightmovelength or 0) + 1 >= ent:GetNW2Float("Fleetway_flightspeed") then
                        return "flymovement"
                    else
                        return "Walk"
                    end
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "laserofdestructionchargeidle"
                end
                if ent:GetNW2Bool('Stunned_OM_EXE_phase2') then
                    return "phase2idle"
                end
            end,
            walk= function(ent) 
                local ply = ent:GetPillUser()
                if ent:GetNW2Bool("FatefulDrainMode_moving") then
                    return "FatefulDrain"
                end
                if ent:GetNW2Float("RollEndTime_om", 0 ) > CurTime() then
                    return "Jump"
                end
                if ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing") then
                    return "FatefulDrain_absorbenemy"
                end
                if ent:GetNW2Float("FatefulDrain_Wait") >= CurTime() then
                    return "FatefulDrain_idle"
                end
                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "laserdestructionfire"
                end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "Stunned"
                end
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    return "Spindash"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then
                    local ply = ent:GetPillUser()
                    ent.Flightmovelength = ent.Flightmovelength or 0
                    if ent.Flightmovelength <= 1 then
                        return "Idle"
                    end

                    if (ent.Flightmovelength or 0) + 1 >= ent:GetNW2Float("Fleetway_flightspeed") then
                        return "flymovement"
                    else
                        return "Walk"
                    end
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "laserofdestructionchargeidle"
                end
            end,
            run= function(ent)
                local ply = ent:GetPillUser()
                if ent:GetNW2Bool("FatefulDrainMode_moving") then
                    return "FatefulDrain"
                end
                if ent:GetNW2Float("RollEndTime_om", 0 ) > CurTime() then
                    return "Jump"
                end
                if ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing") then
                    return "FatefulDrain_absorbenemy"
                end
                if ent:GetNW2Float("FatefulDrain_Wait") >= CurTime() then
                    return "FatefulDrain_idle"
                end
                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return "laserdestructionfire"
                end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then
                    return "Stunned"
                end
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    return "Spindash"
                end
                if IsValid(ent:GetNW2Entity("flyingent")) then
                    local ply = ent:GetPillUser()
                    ent.Flightmovelength = ent.Flightmovelength or 0
                    if ent.Flightmovelength <= 1 then
                        return "Idle"
                    end

                    if (ent.Flightmovelength or 0) + 1 >= ent:GetNW2Float("Fleetway_flightspeed") then
                        return "flymovement"
                    else
                        return "Walk"
                    end
                end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then
                    return "laserofdestructionchargeidle"
                end
            end,
        },
        
        animrates = {
            laserdestructionfire = function(ent)
                return 4
            end,
            fall = function(ent)
                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return 4
                end
                return 1
            end,
            idle= function(ent)
                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return 4
                end
                return 1
            end,
            walk= function(ent)
                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return 4
                end
                return 1
            end,
            run= function(ent)
                if ent:GetNW2Bool("drawfleetwaylaser") then
                    return 4
                end
                return 1
            end,
        }
    },

    OM_cameratable = function(ply,ent)
        local basetable =  {
            startoffset = Vector(15,0,25),  -- left-up, front-back, up-down
            dist=145,
            fov = ply:GetInfoNum("om_pills_default_fov", 80),
            id = 0,
            transition = 1,
            canscroll = true,
            bonecenter = "Head",
        }


        ent.fleetway_chaosdash_chargeup_fov_lerp = ent.fleetway_chaosdash_chargeup_fov_lerp or 0 
        ent.fleetway_chaosdash_duration_fov_lerp = ent.fleetway_chaosdash_duration_fov_lerp or 0 
        ent.fleetway_laser_chargeup_fov_lerp = ent.fleetway_laser_chargeup_fov_lerp or 0 
        ent.fleetway_laser_shootout_fov_lerp = ent.fleetway_laser_shootout_fov_lerp or 0 
        ent.fleetway_fatefuldrain_fov_lerp = ent.fleetway_fatefuldrain_fov_lerp or 0 
        ent.fleetway_fatefuldrain_charge_fov_lerp = ent.fleetway_fatefuldrain_charge_fov_lerp or 0 
        ent.fleetway_fatefuldrain_steallife_fov_lerp = ent.fleetway_fatefuldrain_steallife_fov_lerp or 0 
        ent.fleetway_burst_start_fov_lerp = ent.fleetway_burst_start_fov_lerp or 0 
        ent.fleetway_burst_burst_fov_lerp = ent.fleetway_burst_burst_fov_lerp or 0 

        if ply:GetInfoNum("om_pills_action_camera_Fleetway", 1) == 1 then
            if ply:GetMoveType() == MOVETYPE_NONE then
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    basetable["bonecenter"] = "Root"
                    ent.fleetway_chaosdash_chargeup_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_chaosdash_chargeup_fov_lerp, 1)
                else
                    ent.fleetway_chaosdash_chargeup_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_chaosdash_chargeup_fov_lerp, 0)
                end
            else
                if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
                    ent.fleetway_chaosdash_duration_fov_lerp = Lerp(FrameTime()*5, ent.fleetway_chaosdash_duration_fov_lerp, 1)
                    ent.fleetway_chaosdash_chargeup_fov_lerp = Lerp(FrameTime()*5, ent.fleetway_chaosdash_chargeup_fov_lerp, 0)
                else
                    ent.fleetway_chaosdash_chargeup_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_chaosdash_chargeup_fov_lerp, 0)
                    ent.fleetway_chaosdash_duration_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_chaosdash_duration_fov_lerp, 0)
                end
            end
            if ent:GetNW2Bool("IsInLaserOfDestruction") then
                ent.fleetway_laser_chargeup_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_laser_chargeup_fov_lerp, 1)
            else
                ent.fleetway_laser_chargeup_fov_lerp = Lerp(FrameTime()*4, ent.fleetway_laser_chargeup_fov_lerp, 0)
            end
            if ent:GetNW2Bool("drawfleetwaylaser") then
                ent.fleetway_laser_shootout_fov_lerp = Lerp(FrameTime()*5, ent.fleetway_laser_shootout_fov_lerp, 1)
            else
                ent.fleetway_laser_shootout_fov_lerp = Lerp(FrameTime()*3, ent.fleetway_laser_shootout_fov_lerp, 0)
            end
            if ent:GetNW2Bool("FatefulDrainMode") then
                ent.fleetway_fatefuldrain_fov_lerp = Lerp(FrameTime()*4, ent.fleetway_fatefuldrain_fov_lerp, 1)
            else
                ent.fleetway_fatefuldrain_fov_lerp = Lerp(FrameTime()*4, ent.fleetway_fatefuldrain_fov_lerp, 0)
            end
            if ent:GetNW2Bool("FatefulDrainMode_moving") then
                ent.fleetway_fatefuldrain_charge_fov_lerp = Lerp(FrameTime()*6, ent.fleetway_fatefuldrain_charge_fov_lerp, 1)
            else
                ent.fleetway_fatefuldrain_charge_fov_lerp = Lerp(FrameTime()*4, ent.fleetway_fatefuldrain_charge_fov_lerp, 0)
            end
            if ent:GetNW2Bool("Absorbing") then
                ent.fleetway_fatefuldrain_steallife_fov_lerp = Lerp(FrameTime()*6, ent.fleetway_fatefuldrain_steallife_fov_lerp, 1)
            else
                ent.fleetway_fatefuldrain_steallife_fov_lerp = Lerp(FrameTime()*4, ent.fleetway_fatefuldrain_steallife_fov_lerp, 0)
            end
            if ent:GetNW2Bool("BurstLaserDuration") then
                ent.fleetway_burst_start_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_burst_start_fov_lerp, 1)
            else
                ent.fleetway_burst_start_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_burst_start_fov_lerp, 0)
            end
            if ent:GetNW2Bool("BurstLaserDuration2") then
                ent.fleetway_burst_burst_fov_lerp = Lerp(FrameTime()*5, ent.fleetway_burst_burst_fov_lerp, 1)
            else
                ent.fleetway_burst_burst_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_burst_burst_fov_lerp, 0)
            end
                --if ent:GetNW2Entity("") and ent:GetNW2Bool("") then

        else
            ent.fleetway_chaosdash_chargeup_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_chaosdash_chargeup_fov_lerp, 0)
            ent.fleetway_chaosdash_duration_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_chaosdash_duration_fov_lerp, 0)
            ent.fleetway_laser_chargeup_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_laser_chargeup_fov_lerp, 0)
            ent.fleetway_laser_shootout_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_laser_shootout_fov_lerp, 0)
            ent.fleetway_fatefuldrain_charge_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_fatefuldrain_charge_fov_lerp, 0)
            ent.fleetway_fatefuldrain_steallife_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_fatefuldrain_steallife_fov_lerp, 0)
            ent.fleetway_burst_start_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_burst_start_fov_lerp, 0)
            ent.fleetway_burst_burst_fov_lerp = Lerp(FrameTime()*2, ent.fleetway_burst_burst_fov_lerp, 0)
        end

        if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then
            basetable =  {
                startoffset = Vector(15,0,25),  -- left-up, front-back, up-down
                dist=145,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 2,
                transition = 1,
                canscroll = true,
            }
        end

        local fly = ent:GetNW2Entity("flyingent")
        if IsValid(fly) then
            basetable =  {
                startoffset = Vector(15,0,55),  -- left-up, front-back, up-down
                dist=145,
                fov = ply:GetInfoNum("om_pills_default_fov", 80),
                id = 2,
                transition = 1,
                canscroll = true,
            }
        end

        basetable["fov"] = basetable["fov"] + 
            ent.fleetway_chaosdash_chargeup_fov_lerp * -15 + 
            ent.fleetway_chaosdash_duration_fov_lerp * 15 + 
            ent.fleetway_laser_chargeup_fov_lerp * -15 +
            ent.fleetway_laser_shootout_fov_lerp * 15 + 
            ent.fleetway_fatefuldrain_fov_lerp * -15 + 
            ent.fleetway_fatefuldrain_charge_fov_lerp * 15 +
            ent.fleetway_fatefuldrain_steallife_fov_lerp * 15 +
            ent.fleetway_burst_start_fov_lerp * -15 +
            ent.fleetway_burst_burst_fov_lerp * 15

        basetable["dist"] = basetable["dist"] + 
            ent.fleetway_chaosdash_chargeup_fov_lerp * -30 + 
            ent.fleetway_chaosdash_duration_fov_lerp * -40 + 
            ent.fleetway_laser_chargeup_fov_lerp * -20 +
            ent.fleetway_laser_shootout_fov_lerp * 15 + 
            ent.fleetway_fatefuldrain_fov_lerp * -20 + 
            ent.fleetway_fatefuldrain_charge_fov_lerp * 40 +
            ent.fleetway_fatefuldrain_steallife_fov_lerp * 25 +
            ent.fleetway_burst_start_fov_lerp * -10 +
            ent.fleetway_burst_burst_fov_lerp * 60

        basetable["startoffset"] = basetable["startoffset"] + Vector(
                ent.fleetway_chaosdash_chargeup_fov_lerp * 20 + 
                ent.fleetway_chaosdash_duration_fov_lerp * 5  + 
                ent.fleetway_laser_chargeup_fov_lerp * 20 + 
                ent.fleetway_fatefuldrain_fov_lerp * 20, 
            0,0)

        return basetable
    end,

    OM_3D_Render = {
        scaleoffset = 0,
        vectoroffset = Vector(0,0,0),
        angleOffset = Angle(0,0,0),
    },

    OM_UI_icons = {
        [1] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility1_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["fleetway_OM_dash"]
            end,
            name = function(uselessvar,ply,ent)
                return "Chaos Dash"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_fleetway_caosdash_key", KEY_E)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("dash_OM_Fleetway_Cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("dash_OM_Fleetway_Cooldown_duration")
            end,
            --[[
            CustomDrawFunction = function(table1,table2)
                local X_axis = table2["X_axis"]
                local Y_axis = table2["Y_axis"]
                local XSize_iconsize = table2["XSize_iconsize"]
                local YSize_iconsize = table2["YSize_iconsize"]

                draw.SimpleText("Use bitch", "OM_Subtitle_Large", X_axis + XSize_iconsize * 0.5, Y_axis - XSize_iconsize * 0.25, Color(175,175,255), TEXT_ALIGN_CENTER)
            end,
            ]]
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.0, yaxis = 0 + iconsize * 0.05, xsize = 0 - iconsize* 0.0, ysize = 0 - iconsize * 0.0}
            end,
            survivor = false,
            font = "CreditsText",
        },
        [2] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility2_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["fleetway_OM_laser"]
            end,
            name = function(uselessvar,ply,ent)
                return "Laser Of Destruction"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_fleetway_laser_key", KEY_R)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("laserofchaos_OM_Fleetway_Cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("laserofchaos_OM_Fleetway_Cooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.02, yaxis = 0 + iconsize * 0.05, xsize = 0 - iconsize* 0.07, ysize = 0 - iconsize * 0.07}
            end,
            survivor = false,
            font = "CreditsText",
        },
        [3] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility3_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["fleetway_OM_drain"]
            end,
            name = function(uselessvar,ply,ent)
                return "Fateful Drain"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_fleetway_drain_key", KEY_T)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("fatefuldrain_OM_Fleetway_Cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("fatefuldrain_OM_Fleetway_Cooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.02, yaxis = 0 + iconsize * 0, xsize = 0 - iconsize* 0.0, ysize = 0 - iconsize * 0.0}
            end,
            survivor = false,
            font = "CreditsText",
        },
        [4] = {
            shouldappear = function(e,uselessvar,ply,ent)
                return not ent:GetNW2Bool("ShouldntShowAbility4_OM")
            end,
            icons = function(uselessvar,ply,ent)
                return preservedmats["fleetway_OM_burst"]
            end,
            name = function(uselessvar,ply,ent)
                return "Burst"
            end,
            keybind = function(uselessvar,ply,ent)
                local input2 = ply:GetInfoNum("om_pills_action_fleetway_Burst_key", KEY_I)
                local name = input.GetKeyName(input2)
                return string.upper(name)
            end,
            cooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Blast_OM_Fleetway_Cooldown")
            end,
            maximumcooldown = function(uselessvar,ply,ent)
                return ent:GetNW2Float("Blast_OM_Fleetway_Cooldown_duration")
            end,
            OffsetIcon = function(uselessvar,ply,ent)
                local screenW, screenH = ScrW(), ScrH()
                local iconsize = screenW / 13
                return {xaxis = 0 + iconsize * 0.05, yaxis = 0 + iconsize * 0, xsize = 0 - iconsize* 0.0, ysize = 0 - iconsize * 0.0}
            end,
            survivor = false,
            font = "CreditsText",
        },
    },
    

    Outcomememories_stats = {
        moveSpeed = {
            walk = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Fleetway_walk"):GetFloat()
                end
            end,
            run = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Fleetway_run"):GetFloat()
                end
            end,
            ducked= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Fleetway_walk"):GetFloat()
                end
            end,
            jumppower= function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Fleetway_jumppower"):GetFloat()
                end
            end,
            jumpcd = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Fleetway_jumpcd"):GetFloat()
                end
            end,
            Rolling = function(ply,ent)
                if SERVER then
                    return GetConVar("OUTCOMEMEMORIES_N_Fleetway_rollingPower"):GetFloat()
                end
            end,
        },

        abilities = {
            ["Attack"] = {
                ["CriticalAttack"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMEMORIES_N_Fleetway_CriticalDamage"):GetFloat()
                    end
                end,
                ["Damage"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMEMORIES_N_Fleetway_Damage"):GetFloat()
                    end
                end,
            },
            ["Burst"] = {
                ["ActivationKey"] = KEY_I,
                ["Cooldown"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_Cooldown"):GetFloat()
                    end
                end,
                ["CooldownStun"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_CooldownStun"):GetFloat()
                    end
                end,
            },
            ["Fatefuldrain"] = {
                ["ActivationKey"] = KEY_T,
                ["Cooldown"] =  function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_Cooldown"):GetFloat()
                    end
                end,
            },
            ["LaserOfDestruction"] = {
                ["ActivationKey"] = KEY_R,
                ["Cooldown"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Cooldown"):GetFloat()
                    end
                end,
            },
            ["CaosDash"] = {
                ["ActivationKey"] = KEY_E,
                ["Cooldown"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Cooldown"):GetFloat()
                    end
                end,
                ["Duration"] = function(ply,ent)
                    if SERVER then
                        return GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Duration"):GetFloat()
                    end
                end,
            }, 
        }
    },
    --ent.formTable.Outcomememories_stats.abilities.Attack.Damage
    movePoseMode="xy",

    aim={
        xPose="aim_yaw",
        yPose="aim_pitch",
        nocrosshair = true
    },

    ShouldRoll_om = function(e, ply, ent)
        if ent:GetNW2Bool("FatefulDrainMode") then return false end
        return true
    end,
        

    OM_Bar = {
        ShouldShow = function(uselessvar,ply,ent)
            if ent:GetNW2Bool("IsInLaserOfDestruction") and ply:GetInfoNum("om_pills_fleetway_custombar", 1) == 1 then
                return true
            end
        end,
        colorbar = function(uselessvar,ply,ent)
            return Color(255, 0, 0, 255)
        end,
        progression = function(uselessvar,ply,ent)
            --LaserLastingDuration
            local factor = math.Clamp( ( ent:GetNW2Float("LaserLastingDuration")-CurTime() )/ent:GetNW2Float("LaserLastingDuration_amount"), 0, 1)
            local lerp = Lerp(factor,0,100)

            return lerp
        end,
        maximumbar = function(uselessvar,ply,ent)
            return 100
        end,
    },
    --canAim=function(ply,ent) return ent.active end,     


    speedhandeler_om = {
        think = function(ply,ent)
            local Currentwalkspeed = ent.formTable.Outcomememories_stats.moveSpeed.walk(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.walk or 200
            local Currentrunspeed = ent.formTable.Outcomememories_stats.moveSpeed.run(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.run or 400
            local Currentcrouchspeed = ent.formTable.Outcomememories_stats.moveSpeed.ducked(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.ducked or 200
            local Currentjump = ent.formTable.Outcomememories_stats.moveSpeed.jumppower(ply,ent) or ent.formTable.Outcomememories_stats.moveSpeed.jumppower or 400
            for i,v in pairs(ent.formTable.speedhandeler_om.modifiers) do
                local modifier = v(ply, ent)
                Currentwalkspeed = Currentwalkspeed + modifier["Walk"] 
                Currentrunspeed = Currentrunspeed + modifier["Run"]
                Currentcrouchspeed = Currentcrouchspeed + modifier["Crouch"]
                Currentjump = Currentjump + modifier["Jump"]
            end
            local factor = ( 1+ent:GetNW2Float("OM_SpeedBoost_Damage"))
            ply:SetWalkSpeed(Currentwalkspeed * factor )
            ply:SetRunSpeed(Currentrunspeed * factor )
            ply:SetCrouchedWalkSpeed(Currentcrouchspeed * factor )
            ply:SetJumpPower(Currentjump )
        end,
        modifiers = {
            --['Function1'] = function(ply, ent)
            --end,
        }
    },

    HandleAnimEvent_Noodles_OM_pill = function(ply, ent, event)
        if SERVER then
            if event == "SlamImpact" then
                local bone = ent:GetPuppet():LookupBone("RightHand")
                if bone then
                    local pos, ang = ent:GetPuppet():GetBonePosition(bone)
                    local ed = EffectData()
                    ed:SetOrigin(pos)
                    ed:SetEntity(ent)
                    util.Effect("fleetway_spindashhit", ed)

                    local ed = EffectData()
                    ed:SetOrigin(pos)
                    ed:SetNormal(ent:GetPuppet():GetUp())
                    util.Effect("large_blood_squirt_om", ed)

                end
            end
            if event == "Attack" then
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") > CurTime() then return end

                if SERVER then

                    local attackPos = ent:LocalToWorld(Vector(0, 0, 50)) + ent:GetPuppet():GetForward()*40

                    for _, ent2 in pairs(ents.FindInSphere(attackPos, GetConVar("OUTCOMEMEMORIES_N_Fleetway_m1_range"):GetFloat() )) do
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                        else
                            if GetConVar("OUTCOMEMEMORIES_N_Fleetway_DoorsDestruction"):GetBool() then
                                if ent2:GetClass() == "prop_door_rotating" or ent2:GetClass() == "func_door_rotating" then
                                    local dprop = ents.Create("prop_physics")
                                    if not IsValid(dprop) then return end

                                    dprop:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
                                    dprop:SetMoveType(MOVETYPE_VPHYSICS)
                                    dprop:SetSolid(SOLID_BBOX)
                                    dprop:SetPos(ent2:GetPos() + Vector(0, 0, 2))
                                    dprop:SetAngles(ent2:GetAngles())
                                    dprop:SetModel(ent2:GetModel())

                                    ent2:Remove()

                                    dprop:Spawn()

                                    dprop:SetSkin(ent2:GetSkin() or 0)

                                    if ent2:GetNumBodyGroups() then
                                        for id = 0, ent2:GetNumBodyGroups() - 1 do
                                            dprop:SetBodygroup(id, ent2:GetBodygroup(id))
                                        end
                                    end

                                    for i = 0, 31 do
                                        local mat = ent2:GetSubMaterial(i)
                                        if mat and mat:len() > 0 then
                                            dprop:SetSubMaterial(i, mat)
                                        end
                                    end

                                    dprop:EmitSound("physics/wood/wood_crate_break3.wav")
                                    local effectdata = EffectData()
                                    effectdata:SetOrigin(dprop:GetPos() + dprop:OBBCenter())
                                    effectdata:SetMagnitude(5)
                                    effectdata:SetScale(2)
                                    effectdata:SetRadius(5)
                                    util.Effect("Sparks", effectdata)
                                            
                                    local phys = dprop:GetPhysicsObject()
                                    if IsValid(phys) then
                                        phys:ApplyForceOffset(ply:GetForward() * 1500, phys:GetMassCenter())
                                    end
                                end
                            end

                            local tr = util.TraceLine({
                                start = ent2:WorldSpaceCenter(),
                                endpos = ent2:WorldSpaceCenter(),
                                filter = function(hitEnt)
                                    return hitEnt == ent2
                                end
                            })

                            if GetConVar("OUTCOMEMEMORIES_N_Fleetway_PropsDestruction"):GetBool() then
                                if tr.Entity == ent2 then
                                    local phys = ent2:GetPhysicsObject()
                                    local dir = (ent2:GetPos() - ent:GetPos()):GetNormalized()

                                    if IsValid(phys) then

                                        local phys = ent2:GetPhysicsObject()
                                        local dir = (ent2:WorldSpaceCenter() - ent:WorldSpaceCenter()):GetNormalized()

                                        if math.random(1,2) == 1 then constraint.RemoveConstraints(ent2, "Weld") end
                                        if math.random(1,3) == 1 then constraint.RemoveConstraints(ent2, "Axis") end
                                        if math.random(1,3) == 1 then constraint.RemoveConstraints(ent2, "Ballsocket") end
                                        if math.random(1,2) == 1 then constraint.RemoveConstraints(ent2, "Rope") end
                                        if math.random(1,3) == 1 then constraint.RemoveConstraints(ent2, "Elastic") end
                                        if ply:IsPlayer() then
                                            net.Start("ShakeCamera_OM")
                                            net.Send(ply)
                                        end

                                        --if math.random(1,150) == 1 then constraint.RemoveConstraints(ent2, "NoCollide") end

                                        if IsValid(phys) then
                                            phys:EnableMotion(true)
                                            phys:Wake()

                                            phys:ApplyForceCenter(dir * 7000)

                                            local surface = string.lower(util.GetSurfacePropName(tr.SurfaceProps) or "")

                                            local impactSounds

                                            if surface:find("metal") or surface:find("steel") or surface:find("barrel") then
                                                impactSounds = {
                                                    "physics/metal/metal_barrel_impact_hard1.wav",
                                                    "physics/metal/metal_barrel_impact_hard2.wav",
                                                    "physics/metal/metal_barrel_impact_hard3.wav",
                                                    "physics/metal/metal_barrel_impact_hard4.wav",
                                                    "physics/metal/metal_box_impact_hard1.wav",
                                                    "physics/metal/metal_box_impact_hard2.wav",
                                                    "physics/metal/metal_box_impact_hard3.wav",
                                                }

                                            elseif surface:find("wood") then
                                                impactSounds = {
                                                    "physics/wood/wood_box_impact_hard1.wav",
                                                    "physics/wood/wood_box_impact_hard2.wav",
                                                    "physics/wood/wood_box_impact_hard3.wav",
                                                    "physics/wood/wood_crate_impact_hard1.wav",
                                                    "physics/wood/wood_crate_impact_hard2.wav",
                                                    "physics/wood/wood_crate_impact_hard3.wav",
                                                    "physics/wood/wood_furniture_impact_hard1.wav",
                                                    "physics/wood/wood_furniture_impact_hard2.wav",
                                                }

                                            elseif surface:find("glass") then
                                                impactSounds = {
                                                    "physics/glass/glass_impact_hard1.wav",
                                                    "physics/glass/glass_impact_hard2.wav",
                                                    "physics/glass/glass_impact_hard3.wav",
                                                }

                                            elseif surface:find("concrete") or surface:find("brick") or surface:find("stone") then
                                                impactSounds = {
                                                    "physics/concrete/concrete_impact_hard1.wav",
                                                    "physics/concrete/concrete_impact_hard2.wav",
                                                    "physics/concrete/concrete_impact_hard3.wav",
                                                }

                                            elseif surface:find("plastic") then
                                                impactSounds = {
                                                    "physics/plastic/plastic_box_impact_hard1.wav",
                                                    "physics/plastic/plastic_box_impact_hard2.wav",
                                                    "physics/plastic/plastic_box_impact_hard3.wav",
                                                }

                                            elseif surface:find("cardboard") then
                                                impactSounds = {
                                                    "physics/cardboard/cardboard_box_impact_hard1.wav",
                                                    "physics/cardboard/cardboard_box_impact_hard2.wav",
                                                    "physics/cardboard/cardboard_box_impact_hard3.wav",
                                                }

                                            elseif surface:find("chain") or surface:find("grate") then
                                                impactSounds = {
                                                    "physics/metal/metal_grate_impact_hard1.wav",
                                                    "physics/metal/metal_grate_impact_hard2.wav",
                                                    "physics/metal/metal_grate_impact_hard3.wav",
                                                }

                                            elseif surface:find("vent") then
                                                impactSounds = {
                                                    "physics/metal/metal_vent_impact_hard1.wav",
                                                    "physics/metal/metal_vent_impact_hard2.wav",
                                                }

                                            elseif surface:find("flesh") then
                                                impactSounds = {
                                                    "physics/flesh/flesh_impact_bullet1.wav",
                                                    "physics/flesh/flesh_impact_bullet2.wav",
                                                }
                                            end

                                            if impactSounds then
                                                ent2:EmitSound(impactSounds[math.random(#impactSounds)], 75, math.random(95, 105))
                                            end
                                        end
                                    end

                                    
                                    local typeofdamage = ent.formTable.Outcomememories_stats.abilities.Attack.Damage()
                                    if math.random(1, 3) == 1 and ent:GetNW2Bool("Stunned_OM_EXE_phase2") then
                                        ent:GetPuppet():SetNW2Float("fleetway_glow_duration", CurTime() + 0.45)
                                        ent2:SetNW2Float("fleetway_attack_glow_duration", CurTime() + 0.45)

                                        typeofdamage = ent.formTable.Outcomememories_stats.abilities.Attack.CriticalAttack()
                                    end

                                    local dmg = DamageInfo()
                                    dmg:SetDamage(typeofdamage)
                                    dmg:SetDamageType(DMG_CLUB)
                                    dmg:SetAttacker(ply)
                                    dmg:SetInflictor(ply)
                                    dmg:SetDamageForce(dir * 5000)
                                    dmg:SetDamagePosition(tr.HitPos)

                                    ent2:DispatchTraceAttack(dmg, tr, tr.Normal)
                                end
                            end
                        end
                    end

                    local nearest
                    local nearestDist = math.huge

                    local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                    for _, ent2 in pairs(ents.FindInSphere(attackPos, GetConVar("OUTCOMEMEMORIES_N_Fleetway_m1_range"):GetFloat() )) do
                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then
                            if ent2 == ply then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                            if not GetConVar("PVPStun_OM_exe"):GetBool() then
                                if ent2:GetNW2Bool("OM_character_monster") then continue end
                            end

                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                            if not Mutal_OMCanDamage(ply, ent, ent2) then continue end

                            local dist = attackPos:DistToSqr(ent2:GetPos())

                            if dist < nearestDist then
                                nearestDist = dist
                                nearest = ent2
                            end
                        end
                    end

                    if IsValid(nearest) then
                        local typeofdamage = ent.formTable.Outcomememories_stats.abilities.Attack.Damage()
                        if math.random(1, 3) == 1 and ent:GetNW2Bool("Stunned_OM_EXE_phase2") then
                            ent:GetPuppet():SetNW2Float("fleetway_glow_duration", CurTime() + 0.45)
                            nearest:SetNW2Float("fleetway_attack_glow_duration", CurTime() + 0.45)

                            typeofdamage = ent.formTable.Outcomememories_stats.abilities.Attack.CriticalAttack()
                        end
                        
                        KillerdamagestunDynamic({
                            ply = ply,
                            target = nearest,
                            DamageNumb = typeofdamage,
                            damagetype = DMG_CLUB,
                            CustomDamageSound = nil,
                            damagesound = true,
                            ShouldBlood = true,
                            flingremoveal = true,
                            ShouldBloodEffect = true
                        })
                    end
                end
            end
            if event == "ThrowRagdoll" then
                timer.Simple(0.1,function()
                    if !IsValid(ent) then return end
                    ent:SetNWBool("JumpscareAnim_om_boolean2", false)
                end)
            end
        end
    end,

    noodles_OM_survivor_initialize=function(initializetable,initializetable2,initializetable3)
        sharedinitializefunction_killer_om(initializetable2["entity"])


        initializetable2["player"].ColorRGB_B_1_OM = Color(215,215,0, 255)
        if SERVER then
            initializetable2["player"]:SetHealth(GetConVar("OUTCOMEMEMORIES_N_Fleetway_Health"):GetFloat())
            initializetable2["player"]:SetMaxHealth(GetConVar("OUTCOMEMEMORIES_N_Fleetway_Health"):GetFloat())
            initializetable2["entity"]:SetNW2Float("MaxHealth",GetConVar("OUTCOMEMEMORIES_N_Fleetway_Health"):GetFloat())
            initializetable2["player"]:SetNW2Float("MaxHealth_OM",GetConVar("OUTCOMEMEMORIES_N_Fleetway_Health"):GetFloat())
            if GetConVar("OUTCOMEMEMORIES_N_Fleetway_HasHealth"):GetBool() then 
                initializetable2["player"]:GodDisable()
            end
            initializetable2["entity"]:SetNW2Float('OM_friction', 1)
            initializetable2["entity"]:SetNW2Bool("OM_Fleetway_pill", true)
            initializetable2["entity"]:SetNW2Float("OM_Fleetway_flyingBar",GetConVar("OUTCOMEMORIES_N_Fleetway_flying_flightmax"):GetFloat())
            initializetable2["entity"]:SetNW2Bool('Stunned_OM_EXE_phase2_init', true)

            initializetable2["entity"]:SetNW2Bool('HasFlyCompad_OM', true)
            initializetable2["entity"]:SetNW2Float("OM_maximum_flight", GetConVar("OUTCOMEMORIES_N_Fleetway_flying_flightmax"):GetFloat())

            initializetable2["player"]:SetNW2String("TerrorRadius_om","OM/music/FleetwayRadius.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life1_om","OM/music/FleetwayLife1.wav")
            initializetable2["player"]:SetNW2String("chasemusic_life2_om","OM/music/FleetwayLife2.wav")

            initializetable2["entity"].CanClashOpponents_OM = true
            initializetable2["entity"].flight_limitpitch = true

            initializetable2["player"].OMInitiateClash_lnz = function(ent2)
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]
                    local ply = initializetable2["player"]

                    ent:SetNW2Float("CaosDash_duration", CurTime()+1e9) 

                    if ply:IsPlayer() then
                        ply:SetMoveType(0)
                    else
                        ply:SetMoveType(MOVETYPE_WALK)
                    end
                end
            end

            initializetable2["player"].OM_AfterStunBlock = function(DataTable)
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]
                    local ply = initializetable2["player"]
                    if ent:GetNW2Bool("FatefulDrainMode") or (ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing")) and ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) < CurTime() then

                        AdvancedPillSound(
                            {
                                stringe = {"OM/Fleetway/FleetwayCounter1.wav", "OM/Fleetway/FleetwayCounter2.wav"},
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            initializetable2["entity"]
                        )

                        ent.OM_CounteredByChar = true
                        ent:SetNW2Float("fateful_drain_drainenemy_ragexistance", CurTime()+ 3)
                        ent:SetNW2Float("fateful_drain_drainenemyAmountHit", ent:GetNW2Float("fateful_drain_drainenemyAmountHit") + 1e9)
                        ent:SetNW2Float("CaosDash_duration",0)

                        return {
                            canceltype = "effectstun",
                            shouldblock = true 
                        }
                    end
                end
            end

            initializetable2["player"].CustomFunctionCancelAbility_OM = function()
                if IsValid(initializetable2["entity"]) then
                    local ent = initializetable2["entity"]
                    ent:SetNW2Float("CaosDash_duration",0)
                end
            end

            initializetable2["player"].OM_ShouldClash = function()
                if IsValid(initializetable2["entity"]) then
                    if GetConVar('PVPStun_OM_clashing'):GetBool() then
                        if initializetable2["entity"]:GetNW2Float("CaosDash_duration") > CurTime() then return true end
                    end
                end
                return false
            end

            initializetable2["player"]:SetNW2String("CharacterStunned_om", "")
            initializetable2["player"].OMCompelteClash_lnz = function(Wintype)
                if !IsValid(initializetable2["entity"]) then return end

                local ply = initializetable2["player"]
                local ent = initializetable2["entity"]

                ent:SetNW2Float("CaosDash_duration", 0) 

                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_WALK)
                else
                    ply:SetMoveType(0)
                end
                if Wintype == "Loss" then
                    local ent2 = ply:GetNW2Entity("clashingminigame_om_opponent")
                    if IsValid(ent2) then
                        local character = ""
                        if ent2:IsPlayer() and ent2.pk_pill_ent then
                            character = ent2.pk_pill_ent.formTable.printName
                        end
                        if ent2.formTable then
                            character = ent2.formTable.printName
                        end
                        ply:SetNW2String("CharacterStunned_om", character)
                    end
                end
                return true
            end

            initializetable2["player"].OM_DamageCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]

                if damageamount > 0 then else return end
                if not IsValid(initializetable2["entity"]) then return end

                if initializetable2["player"]:GetPos():Distance(entityfall:GetPos()) < 130 then
                    if IsValid(entityfall) and (entityfall:IsPlayer() or entityfall:IsNPC() or entityfall:IsNextBot()) then
                        if initializetable2["player"]:IsPlayer() then
                            net.Start("Bloodeffect_killers_OM")
                            net.Send(initializetable2["player"])
                        end
                    end
                end
            end

            initializetable2["player"].CustomFunctionForDowning_OM = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if dmg:GetDamageType() ~= DMG_CLUB then return end
                if IsValid(initializetable2["entity"]) then
                    timer.Simple(1,function()
                        if !IsValid(initializetable2["entity"]) then return end
                        AdvancedPillSound(
                            {
                                stringe = {"OM/Fleetway/FleetwaySurvDown1.wav", "OM/Fleetway/FleetwaySurvDown2.wav", "OM/Fleetway/FleetwaySurvDown3.wav"},
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            initializetable2["entity"]
                        )
                    end)
                end
            end

            initializetable2["player"].canusestun_keybind_om = function(use,ply, button)
                if IsValid(initializetable2["entity"]) then
                    if button == initializetable2["player"]:GetInfoNum("om_pills_action_fleetway_Burst_key", KEY_I) then
                        return true
                    end
                end
            end

            initializetable2["player"].OM_DamageCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                local ent = initializetable2["entity"]
                if IsValid(initializetable2["entity"]) then
                    if ent:GetNW2Float("CaosDash_duration", 0) > CurTime() then
                        if IsValid(dmg:GetAttacker()) then
                            local attacker = dmg:GetAttacker()
                            if attacker:IsPlayer() or attacker:IsNPC() or attacker:IsNextBot() then
                            else
                                dmg:SetDamage(0)
                            end
                        end
                    end
                end
            end

            initializetable2["player"].OM_AttacterCustomFunction = function(table1, table2)
                local entityfall = table2[1]
                local dmg = table2[2]
                local damageamount = table2[3]
                if IsValid(initializetable2["entity"]) then
                    if entityfall:IsNextBot() or entityfall:IsNPC() or entityfall:IsPlayer() then else return end
                    if GetConVar("om_pills_action_2ndlife"):GetBool() then
                        if entityfall:GetNW2Bool("SecondLife_OM") and not entityfall:GetNW2Bool("OnSecondLife_OM") then return end
                    end
                    if entityfall:GetNW2Float("Dead_OM") > CurTime() then return end
                    if dmg:GetDamageType() ~= DMG_CLUB then return end
                    if entityfall:Health() - damageamount <= 0.5 then
                        if entityfall:GetNW2Bool("MetalBeing_OM") then
                            initializetable2["entity"]:SetNW2Bool("DownedMetalSonic_OM", true)
                            return end
                        local ent = initializetable2["entity"]
                        local ply = initializetable2["player"]


                        if ent.flyingent and IsValid(ent.flyingent) then
                            ent.flyingent:Remove()
                        end


                        initializetable2["entity"]:PillAnim("KillAnim")
                        local anim = ent:GetPuppet():LookupSequence("KillAnim")
                        local dur = ent:GetPuppet():SequenceDuration(anim)
                        initializetable2["entity"]:SetNW2Float("OM_executionanim", CurTime()+dur)

                        initializetable2["entity"]:SetNW2Float("DisablePlayerMovement_OM_stun_iframe1", CurTime()+dur)
                        
                        entityfall:SetNW2Float("OM_NoDamagePrevention", CurTime()+dur)
                        dmg:SetDamage(0)

                        ent:SetNW2Float("CaosDash_duration", 0)

                        if ent:GetNW2Bool("Absorbing") then
                            ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown", CurTime() + ent.formTable.Outcomememories_stats.abilities.Fatefuldrain.Cooldown()+3)
                            ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown_duration", ent.formTable.Outcomememories_stats.abilities.Fatefuldrain.Cooldown()+3)
                        end

                        ent:SetNWBool("JumpscareAnim_om_boolean2", true)
                        ent:SetNW2Bool("Absorbing", false)
                        ent:SetNW2Bool("FatefulDrainMode", false)
                        ent:SetNW2Entity("FatefulDrain_absorbenemy", NULL)
                        ent:SetNW2Float("FatefulDrain_left",0)

                        timer.Simple(0.5,function()
                            if !IsValid(initializetable2["entity"]) then return end
                            AdvancedPillSound(
                                {
                                    stringe = "OM/Fleetway/Fleetway-KillSound.wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                initializetable2["entity"]
                            )
                        end)


                        if entityfall.loco then
                            entityfall.loco:SetVelocity(vector_origin)
                            entityfall.loco:SetDesiredSpeed(0)
                        end
                        if entityfall:IsNPC() or entityfall:IsNextBot() then
                            entityfall:NextThink(CurTime() + dur)
                        end


                        local character = ""
                        if entityfall:IsPlayer() and entityfall.pk_pill_ent then
                            character = entityfall.pk_pill_ent.formTable.printName
                        end
                        if entityfall.formTable then
                            character = entityfall.formTable.printName
                        end

                        timer.Simple(dur,function()
                            if !IsValid(initializetable2["entity"]) then return end
                            if !IsValid(entityfall) then return end
                            ent:SetNW2Float("Dead_OM", CurTime()+0.1)

                            entityfall:SetNW2Float("OM_Damage_ReductionRemoveal", CurTime()+0.1)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_GENERIC, true, false, false, true)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_CRUSH, true, false, false, true)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_BULLET, true, false, false, true)
                            Killerdamagestun(ply, entityfall, 1e9, DMG_SLASH, true, false, false, true)
                            ent:SetNWBool("JumpscareAnim_om_boolean2", false)

                            timer.Simple(1, function()
                                if !IsValid(initializetable2["entity"]) then return end
                                if character == "Amy" then
                                    AdvancedPillSound(
                                        {
                                            stringe = {"OM/Fleetway/AmyKill1.wav", "OM/Fleetway/AmyKill2.wav"},
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        initializetable2["entity"]
                                    )
                                end
                                if character == "Sonic" then
                                    AdvancedPillSound(
                                        {
                                            stringe = {"OM/Fleetway/SonicKill1.wav", "OM/Fleetway/SonicKill2.wav"},
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        initializetable2["entity"]
                                    )
                                end
                                if character == "Knuckles" then
                                    AdvancedPillSound(
                                        {
                                            stringe = {"OM/Fleetway/KnucklesKill1.wav", "OM/Fleetway/KnucklesKill2.wav"},
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        initializetable2["entity"]
                                    )
                                end
                            end)
                        end)

                        ent:SetNWBool("JumpscareAnim_om_boolean2", true)
                        local throw = false
                        local enemyragdoll = CreateRagdolLCharacter_OM({
                            target = entityfall,
                            host = ent,

                            shouldremove = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return true end
                                if not IsValid(entityfall) then return true end
                                if not IsValid(ent) then return true end
                                if ent:GetNW2Float("OM_executionanim") < CurTime() then
                                    return true
                                else
                                    entityfall:SetNW2Float("ragdolltype_grab", CurTime()+0.1)
                                end

                                return false
                            end,

                            shoulddocustomfunction = function(createfakeragdoll)
                                if not IsValid(createfakeragdoll) then return end

                                local puppet = ent:GetPuppet()
                                if not IsValid(puppet) then return end

                                local headPhys
                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                    local phys = createfakeragdoll:GetPhysicsObjectNum(i)
                                    if IsValid(phys) then
                                        local boneIndex = createfakeragdoll:TranslatePhysBoneToBone(i)
                                        local boneName = createfakeragdoll:GetBoneName(boneIndex) or ""

                                        if string.find(string.lower(boneName), "head", 1, true) then
                                            headPhys = phys
                                            break
                                        end
                                    end
                                end

                                if not IsValid(headPhys) then headPhys = createfakeragdoll:GetPhysicsObject() end
                                if not IsValid(headPhys) then return end

                                local bone = puppet:LookupBone("RightHand")
                                if not bone then return end

                                local pos, ang = puppet:GetBonePosition(bone)
                                if not pos then return end
                                --JumpscareAnim_om_boolean2JumpscareAnim_om_boolean2
                                if not ent:GetNWBool("JumpscareAnim_om_boolean2") then
                                    if not throw then
                                        throw = true
                                        headPhys:ApplyForceCenter(puppet:GetRight()*1750)
                                    end
                                    return true end
                                headPhys:SetPos(pos)
                                headPhys:SetAngles(ang)
                                headPhys:SetVelocityInstantaneous(vector_origin)
                                headPhys:Wake()
                            end

                        })

                    end
                end
            end

            initializetable2["player"].OM_StunFunction = function()
                local ent = initializetable2["entity"]
                if !IsValid(ent) then return end
                ent:SetNW2Bool("drawfleetwaylaser", false)
                ent:SetNW2Bool("IsInLaserOfDestruction", false)
                ent:SetNW2Bool("drawfleetwaylaser", false)
                ent:SetNW2Float("CaosDash_duration", 0)
                ent:SetNW2Float("OM_LaserDuration", CurTime()-1)

                if initializetable2["player"]:IsPlayer() then
                    initializetable2["player"]:SetMoveType(MOVETYPE_WALK)
                else
                    initializetable2["player"]:SetMoveType(0)
                end
            end

            initializetable2["entity"].OM_2ndmethodforjumping = true

            AdvancedPillSound(
                {
                    stringe = "OM/Fleetway/PreLaugh.wav",
                    pitchPercent = 100,
                    volume = 1,
                    soundLevel = 87
                },
                initializetable2["entity"]
            )
            timer.Simple(0.75,function()
                if !IsValid(initializetable2["entity"]) then return end

                AdvancedPillSound(
                    {
                        stringe = "OM/Fleetway/AfterLaugh.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    initializetable2["entity"]
                )

                AdvancedPillSound(
                    {
                        stringe = {"OM/Fleetway/IntroLaugh1.wav","OM/Fleetway/IntroLaugh2.wav","OM/Fleetway/IntroLaugh3.wav"},
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    initializetable2["entity"]
                )

                --[[
                AdvancedPillSound(
                    {
                        stringe = {"OM/joke/Giggle-1.ogg","OM/joke/Giggle-2.ogg","OM/joke/Giggle-3.ogg","OM/joke/Giggle-4.ogg"},
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    initializetable2["entity"]
                )
                ]]
                --[[
                AdvancedPillSound(
                    {
                        stringe = {"OM/joke/Breathe-1.ogg","OM/joke/Breathe-2.ogg","OM/joke/Breathe-3.ogg","OM/joke/Breathe-4.ogg","OM/joke/Breathe-5.ogg"},
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    initializetable2["entity"]
                )
                ]]
            end)
        end
    end,

    noodles_OM_survivor_OnRemove=function(initializetable,initializetable2,initializetable3)
        initializetable2["entity"]:StopSound("OM/Fleetway/Fleetway laser small.wav")
        initializetable2["entity"]:StopSound("OM/Fleetway/Fleetway laser big.wav")


        if initializetable2["entity"]._OldCollisionBounds then
            local oldMins = initializetable2["entity"]._OldCollisionBounds[1]
            local oldMaxs = initializetable2["entity"]._OldCollisionBounds[2]
            if IsValid(initializetable2["player"]) then
                --initializetable2["player"]:SetCollisionBounds(oldMins, oldMaxs)

                initializetable2["player"]:SetNW2Float("OM_Damage_Reduction",1)
            end
            initializetable2["entity"]._OldCollisionBounds = nil
        end

        if IsValid(initializetable2["player"]) then
            --initializetable2["player"]:SetCollisionBounds(oldMins, oldMaxs)

            initializetable2["player"]:SetGravity(1)
        end

    end,

    think_noodles_om_pill = function(ply, ent)
        if SERVER then
            if not GetConVar("OUTCOMEMORIES_N_Fleetway_CaosDash_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility1_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility1_OM", false)
            end
            if not GetConVar("OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility2_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility2_OM", false)
            end
            if not GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility3_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility3_OM", false)
            end
            if not GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_useable"):GetBool() then
                ent:SetNW2Bool("ShouldntShowAbility4_OM", true)
            else
                ent:SetNW2Bool("ShouldntShowAbility4_OM", false)
            end
            ply:SetNW2Float("DamageResistance_OM_2", GetConVar("OUTCOMEMEMORIES_N_Fleetway_Resistance"):GetFloat()/100)

            OM_PILL_speedThink(ply, ent)
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") > CurTime() or ent:GetNW2Float("OM_executionanim") > CurTime() then
                ply:SetNW2Float("OM_Damage_Reduction",0)
            else
                ply:SetNW2Float("OM_Damage_Reduction",1)
            end


            if ent:GetNW2Float("OM_executionanim") > CurTime() or (ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing") and not ent:GetNW2Bool("FatefulDrainMode_moving")) or ent:GetNW2Float("FatefulDrain_absorbenemy_lastduration") > CurTime() then
                ent:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.2)
                if not ent:GetNW2Bool("OM_executionanimToggle") then
                    ent:SetNW2Bool("OM_executionanimToggle", true)
                end
                if ply:IsPlayer() then ply:SetMoveType(0) else ply:SetMoveType(0) end
            else
                if ent:GetNW2Bool("OM_executionanimToggle") then
                    if ply:IsPlayer() then ply:SetMoveType(2) else ply:SetMoveType(0) end
                    ent:SetNW2Bool("OM_executionanimToggle", false)
                end
            end

            local entsetfly = false
            if ply:IsOnGround() then
                ent:SetNW2Bool('StillInAir_Flying', false)
            end

            if (ent:GetNW2Bool("IsInLaserOfDestruction") or ent:GetNW2Bool("drawfleetwaylaser")) and ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) < CurTime() then 

                if ply:IsPlayer() then 
                    ply:SetMoveType(0)
                else
                    ply:SetNW2Vector("OldPosition_laser_e", ply:GetPos())
                end

                local startPos = ply:GetShootPos()
                local endPos = startPos + ply:GetAimVector() * 20000

                local laserdirection = (endPos-startPos):GetNormalized()

                local tr = util.TraceLine({
                    start = startPos,
                    endpos = endPos,
                    mask = MASK_SHOT,
                    filter = function(ent2)
                        if !IsValid(ent2) then return false end

                        if ent2:IsPlayer() then return false end

                        if ent2:IsNPC() then return false end

                        if ent2:IsNextBot() then return false end

                        return true
                    end
                })

                local angl = (tr.HitPos-ent:GetPos()):Angle()
                angl.p = 0
                ent:SetNW2Angle("pill_assignedangle", angl )
                ent:SetNW2Vector("Position2", ent:GetPos() + ent:GetPuppet():GetAngles():Up()*50)

                local hits = ents.FindAlongRay(
                    ent:GetNW2Vector("Position2"),
                    tr.HitPos,
                    Vector(-40, -40, -40),
                    Vector(40, 40, 40)
                )



                if IsValid(ent:GetNW2Entity("SphereEntity_om_fleetway")) then
                    ent:GetNW2Entity("SphereEntity_om_fleetway"):SetPos(tr.HitPos)
                end
                if ent:GetNW2Bool("drawfleetwaylaser") then
                    if not ent.drawfleetwaylaser_table then
                        ent.drawfleetwaylaser_table = {}
                    end

                    --[[
                    local ed = EffectData()
                    ed:SetOrigin(hitpos)
                    util.Effect("StunstickImpact", ed)
                    ]]

                    for _, ent2 in pairs(hits) do
                        if ply:IsNextBot() then
                            if ply:IsPossessed() then
                                if ent2 == ply:GetPossessor() then continue end
                            end
                        end
                        if ent2:GetClass() == "gmod_hands" then continue end
                        if ent2:GetClass() == "pill_ent_costume" then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if ent2:GetClass() == "predicted_viewmodel" then continue end
                        if ent2:IsNextBot() or ent2:IsNPC() or ent2:IsPlayer() then
                            if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                            if ent2 == ply then continue end
                            if not GetConVar('PVPStun_OM_exe'):GetBool() then
                                if ent2:GetNW2Bool("OM_character_monster") then continue end
                            end
                            if not Mutal_OMCanDamage(ply,ent,ent2) then continue end
                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                                    
                            if ent2:GetNW2Float("lasercooldownimpact_fleetway") > CurTime() then
                            else
                                ent2:SetNW2Float("lasercooldownimpact_fleetway", CurTime()+ GetConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_damagecd"):GetFloat()/20)
                                ent2:SetNW2Float("OM_Damage_ReductionRemoveal", CurTime()+0.1)

                                KillerdamagestunDynamic({
                                    ply = ply,
                                    target = ent2,
                                    DamageNumb = GetConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_damagepertic"):GetFloat(),
                                    damagetype = DMG_ENERGYBEAM,
                                    CustomDamageSound = nil,
                                    damagesound = false,
                                    ShouldBlood = false,
                                    flingremoveal = true,
                                    ShouldBloodEffect = false
                                })                    

                                if not ent.drawfleetwaylaser_table[ent2] then
                                    ent.drawfleetwaylaser_table[ent2] = 0
                                end

                                if ent.drawfleetwaylaser_table[ent2] then
                                    ent.drawfleetwaylaser_table[ent2] = ent.drawfleetwaylaser_table[ent2] + 1
                                    if ent.drawfleetwaylaser_table[ent2] >= 15 then
                                        if GetConVar("OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_canburn"):GetBool() then
                                            OM_burntarget(ply,ent2,1)
                                        end
                                    end
                                end

                                ent2:SetNW2Float("Fleetway_LaserHitCooldown", CurTime()+1) 
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/laserhit.wav",
                                        pitchPercent = 100,
                                        volume = 2,
                                        soundLevel = 100
                                    },
                                    ent2
                                )
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/laserhit.wav",
                                        pitchPercent = 100,
                                        volume = 2,
                                        soundLevel = 100
                                    },
                                    ent
                                )

                                ent:SetNW2Float("OM_LaserDuration_last", CurTime()+1.35)
                            end
                        else

                            local tr = util.TraceLine({
                                start = ent2:WorldSpaceCenter() + laserdirection * -5,
                                endpos = ent2:WorldSpaceCenter(),
                                filter = function(hitEnt)
                                    return hitEnt == ent2
                                end
                            })

                            local killercd = ent:EntIndex().. " fleetway_laserdamagecd"
                            if not ent2[killercd] then
                                ent2[killercd] = 0
                            end
                            if tr.Entity == ent2 then

                                if GetConVar("OUTCOMEMEMORIES_N_Fleetway_DoorsDestruction"):GetBool() then
                                    if ent2:GetClass() == "prop_door_rotating" or ent2:GetClass() == "func_door_rotating" then
                                        local dprop = ents.Create("prop_physics")
                                        if not IsValid(dprop) then return end

                                        dprop:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
                                        dprop:SetMoveType(MOVETYPE_VPHYSICS)
                                        dprop:SetSolid(SOLID_BBOX)
                                        dprop:SetPos(ent2:GetPos() + Vector(0, 0, 2))
                                        dprop:SetAngles(ent2:GetAngles())
                                        dprop:SetModel(ent2:GetModel())

                                        ent2:Remove()

                                        dprop:Spawn()

                                        dprop:SetSkin(ent2:GetSkin() or 0)

                                        if ent2:GetNumBodyGroups() then
                                            for id = 0, ent2:GetNumBodyGroups() - 1 do
                                                dprop:SetBodygroup(id, ent2:GetBodygroup(id))
                                            end
                                        end

                                        for i = 0, 31 do
                                            local mat = ent2:GetSubMaterial(i)
                                            if mat and mat:len() > 0 then
                                                dprop:SetSubMaterial(i, mat)
                                            end
                                        end

                                        dprop:EmitSound("physics/wood/wood_crate_break3.wav")
                                        local effectdata = EffectData()
                                        effectdata:SetOrigin(dprop:GetPos() + dprop:OBBCenter())
                                        effectdata:SetMagnitude(5)
                                        effectdata:SetScale(2)
                                        effectdata:SetRadius(5)
                                        util.Effect("Sparks", effectdata)
                                                
                                        local phys = dprop:GetPhysicsObject()
                                        if IsValid(phys) then
                                            phys:ApplyForceOffset(ply:GetForward() * 2000, phys:GetMassCenter())
                                        end
                                    end
                                end

                                if GetConVar("OUTCOMEMEMORIES_N_Fleetway_PropsDestruction"):GetBool() then
                                    if ent2[killercd] < CurTime() then
                                        local phys = ent2:GetPhysicsObject()
                                        local dir = (ent2:GetPos() - ent:GetPos()):GetNormalized()

                                        if IsValid(phys) then

                                            local phys = ent2:GetPhysicsObject()
                                            local dir = (ent2:WorldSpaceCenter() - ent:WorldSpaceCenter()):GetNormalized()


                                            if math.random(1,5) == 1 then constraint.RemoveConstraints(ent2, "Weld") end
                                            if math.random(1,10) == 1 then constraint.RemoveConstraints(ent2, "Axis") end
                                            if math.random(1,10) == 1 then constraint.RemoveConstraints(ent2, "Ballsocket") end
                                            if math.random(1,10) == 1 then constraint.RemoveConstraints(ent2, "Rope") end
                                            if math.random(1,5) == 1 then constraint.RemoveConstraints(ent2, "Elastic") end
                                            --if math.random(1,150) == 1 then constraint.RemoveConstraints(ent2, "NoCollide") end

                                            if IsValid(phys) then
                                                phys:EnableMotion(true)
                                                phys:Wake()

                                                phys:ApplyForceCenter(dir * 7000)
                                            end
                                        end


                                        if math.random(1,7) == 1 then
                                            ent2:Ignite(math.random(4,8)*2, 100)
                                        end
                                        ent2[killercd] = CurTime() + 0.15
                                        local dmg = DamageInfo()
                                        dmg:SetDamage(3)
                                        dmg:SetDamageType(DMG_CLUB)
                                        dmg:SetAttacker(ply)
                                        dmg:SetInflictor(ply)
                                        dmg:SetDamageForce(dir * 5000)
                                        dmg:SetDamagePosition(tr.HitPos)

                                        ent2:DispatchTraceAttack(dmg, tr, tr.Normal)
                                    end
                                end
                            end

                        end
                    end
                else
                    if ent.drawfleetwaylaser_table then
                    end
                end

                if tr.HitPos then
                    local hitpos = tr.HitPos
                    ent:SetNW2Vector("Position1", hitpos)
                end
            else
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() then
                    ent:SetNW2Bool("drawfleetwaylaser", false)
                end
            end
            
            local fly = ent:GetNW2Entity("flyingent")

            if ent:GetNW2Float("OM_Fleetway_flyingBar_cd", 0) > CurTime() then
                if not ent.OM_Fleetway_flyingBar_cd_bool then
                    ent.OM_Fleetway_flyingBar_cd_bool = true
                end
            else
                if ent.OM_Fleetway_flyingBar_cd_bool then
                    ent.OM_Fleetway_flyingBar_cd_bool = false

                    AdvancedPillSound(
                        {
                            stringe = "OM/Fleetway/emrald.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
            end

            ent:SetNW2Float("Fleetway_flightspeed", GetConVar('OUTCOMEMORIES_N_Fleetway_flying_run'):GetFloat())


            if IsValid(fly) and ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) < CurTime() then

                ply:SetNW2Float("NoJumpingCooldown_OM", CurTime() + 0.1)

                local options = {
                    speed = 23*0.7,
                    flyingdrainamount = GetConVar('OUTCOMEMORIES_N_Fleetway_flying_drainWalk'):GetFloat()
                }

                local move = Vector(0, 0, 0)
                local angled = fly:GetAngles()
                local aim = Angle(0, ply:EyeAngles().y, 0)

                if ply:IsPlayer() then
                    aim.p = math.Clamp(ply:EyeAngles().p, -90, 90)

                    if ply:KeyDown(IN_SPEED) then
                        options.speed = GetConVar('OUTCOMEMORIES_N_Fleetway_flying_run'):GetFloat()
                        options.flyingdrainamount = GetConVar('OUTCOMEMORIES_N_Fleetway_flying_drainRun'):GetFloat()
                    else
                        options.speed = GetConVar('OUTCOMEMORIES_N_Fleetway_flying_walk'):GetFloat()
                    end
                    if ply:KeyDown(IN_FORWARD) then
                        move = angled:Forward() * ent:GetNW2Float("SpeedAccelerate")
                    elseif ply:KeyDown(IN_BACK) then
                        move = angled:Forward() * -ent:GetNW2Float("SpeedAccelerate")
                    end
                    if ply:KeyDown(IN_MOVERIGHT) then
                        move = move + angled:Right() * ent:GetNW2Float("SpeedAccelerate")
                    elseif ply:KeyDown(IN_MOVELEFT) then
                        move = move + angled:Right() * -ent:GetNW2Float("SpeedAccelerate")
                    end
                    
                    if not ( (ply:KeyDown(IN_FORWARD)) or (ply:KeyDown(IN_MOVERIGHT)) or (ply:KeyDown(IN_MOVELEFT)) or (ply:KeyDown(IN_BACK)) ) then
                        if ent:GetNW2Float("SpeedAccelerate") > 0 then 
                            ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") - 0.8 )
                            move = ( ent:GetNW2Vector("CurrentVelocity_fly") - Vector(0,0,0) ):GetNormalized() * ent:GetNW2Float("SpeedAccelerate")
                        end
                    else
                        if ent:GetNW2Float("SpeedAccelerate") < options.speed then 
                            ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") + 0.8 )
                        elseif ent:GetNW2Float("SpeedAccelerate") > options.speed then 
                            ent:SetNW2Float("SpeedAccelerate", ent:GetNW2Float("SpeedAccelerate") - 0.8 )
                        end
                    end
                else
                    move = ply:GetNW2Vector("flymove_om_fleetway")
                    options.speed = ply:GetNW2Float("Fleetwayspeed")
                    aim = ply:GetNW2Angle("fleetway_OM_angle")
                end

                if move == Vector(0,0,0) then
                    options.flyingdrainamount = GetConVar('OUTCOMEMORIES_N_Fleetway_flying_drainIdle'):GetFloat()
                end

                for _, ent2 in pairs(ents.FindInSphere(ply:GetPos(), 400)) do
                    if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                    if ent2:GetClass() == "pill_puppet" then continue end
                    if ent2 == ply then continue end
                    if not GetConVar('PVPStun_OM_exe'):GetBool() then
                        if ent2:GetNW2Bool("OM_character_monster") then continue end
                    end
                    if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                    if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

                    if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                        options.flyingdrainamount = options.flyingdrainamount*1.25
                        break
                    end  
                end

                local origin = fly:GetPos()
                local endposition = ((origin+move)-origin):GetNormalized()
                if ent:GetNW2Float("OM_Fleetway_flyingBar") <= 0 then
                    ent:SetNW2Float("OM_Fleetway_flyingBar_cd", CurTime()+8)
                    OM_base_FlyingEnd(ply, ent)
                    return
                end
                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_NONE)
                else
                    ply:SetMoveType(MOVETYPE_NONE)
                end

                if ply:IsPlayer() then
                    if ent:GetNW2Float("FleetwayFlyDrainCooldown") <= CurTime() then
                        ent:SetNW2Float("FleetwayFlyDrainCooldown", CurTime() + 0.1)
                        ent:SetNW2Float("OM_Fleetway_flyingBar", ent:GetNW2Float("OM_Fleetway_flyingBar", 0) - options.flyingdrainamount)
                    end
                else
                    if ent:GetNW2Float("FleetwayFlyDrainCooldown") <= CurTime() then
                        ent:SetNW2Float("FleetwayFlyDrainCooldown", CurTime() + 0.1)
                        ent:SetNW2Float("OM_Fleetway_flyingBar", ent:GetNW2Float("OM_Fleetway_flyingBar", 0) - ply:GetNW2Float("FleetwayDrain"))
                    end
                end

                OM_base_FlyMovement(ply, ent, options, move, aim, fly, origin)
            else
                ent:SetNW2Float("SpeedAccelerate", 0 )
                if ent:GetNW2Float("OM_Fleetway_flyingBar") < ent:GetNW2Float("OM_maximum_flight") then
                    if not ent:GetNW2Bool("StillInAir_Flying") then
                        if ent:GetNW2Float("FleetwayFlyDrainCooldown") <= CurTime() then
                            ent:SetNW2Float("FleetwayFlyDrainCooldown", CurTime() + 0.08)
                            ent:SetNW2Float("OM_Fleetway_flyingBar", ent:GetNW2Float("OM_Fleetway_flyingBar") + GetConVar('OUTCOMEMORIES_N_Fleetway_flying_regeneration'):GetFloat()*1.5)
                        end
                    end
                end
            end
        end

        local shouldsay = false
        if SERVER then
            if GetConVar("OUTCOMEMORIES_N_Fleetway_phase2"):GetBool() then
                if not ent:GetNW2Bool('Stunned_OM_EXE_phase2') and ent:GetNW2Bool('Stunned_OM_EXE_phase2_init') then
                    if ply:Health() < GetConVar("OUTCOMEMEMORIES_N_Fleetway_phase2_HealthActivation"):GetFloat() then
                        if GetConVar("OUTCOMEMORIES_N_Fleetway_phase2_specialactivation"):GetBool() then
                            AdvancedPillSound(
                                {
                                    stringe = {"OM/Fleetway/Phase2_1.wav","OM/Fleetway/Phase2_2.wav","OM/Fleetway/Phase2_3.wav"},
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                            shouldsay = false
                        end
                        ent:SetNW2Bool('Stunned_OM_EXE_phase2', true)
                    end
                end
            end
        end
        
        if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() then
            ent:SetNW2Bool("IsInLaserOfDestruction", false)
            ent:SetNW2Bool("drawfleetwaylaser", false)
            if not ent:GetNW2Bool('Stunned_OM_EXE') then
                ent:SetNW2Bool('Stunned_OM_EXE', true)
                AdvancedPillSound(
                    {
                        stringe = {"OM/Fleetway/FleetwayStunned1.wav","OM/Fleetway/FleetwayStunned2.wav","OM/Fleetway/FleetwayStunned3.wav","OM/Fleetway/FleetwayStunned4.wav"},
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
            end
            if IsValid( ent.flyingent ) then
                OM_base_FlyingEnd(ply, ent)
            end
        else
            if ent:GetNW2Bool('Stunned_OM_EXE') then
                ent:SetNW2Bool('Stunned_OM_EXE', false)
                if shouldsay then
                else
                    local normalline = true
                    if ent:GetNW2Bool("DownedMetalSonic_OM") then
                        AdvancedPillSound(
                            {
                                stringe = {"OM/Fleetway/MetalKill1.wav","OM/Fleetway/MetalKill2.wav"},
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                        normalline = false
                    else
                        local characterstring = ply:GetNW2String("CharacterStunned_om")
                        if characterstring ~= "" then
                            if characterstring == "Sonic" then
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/Fleetway/sonicstunsfleetway.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                                normalline = false
                            elseif characterstring == "Metal Sonic" then
                                AdvancedPillSound(
                                    {
                                        stringe = "OM/Fleetway/metalstunfleet.wav",
                                        pitchPercent = 100,
                                        volume = 1,
                                        soundLevel = 87
                                    },
                                    ent
                                )
                                normalline = false
                            end
                        end
                    end
                    ent:SetNW2Bool("DownedMetalSonic_OM", false)
                    ply:SetNW2String("CharacterStunned_om","")
                    if normalline then
                        AdvancedPillSound(
                            {
                                stringe = {"OM/Fleetway/AfterStun1.wav","OM/Fleetway/AfterStun2.wav","OM/Fleetway/AfterStun3.wav","OM/Fleetway/AfterStun4.wav"},
                                pitchPercent = 100,
                                volume = 1,
                                soundLevel = 87
                            },
                            ent
                        )
                    end
                end
            else
                ent:SetNW2Bool("DownedMetalSonic_OM", false)
            end
        end
        if SERVER then
            if ent:GetNW2Float("CaosDash_duration", 0) > CurTime() and ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) < CurTime() then
                ent:SetNW2Float("OM_camsprint_prev", CurTime()+0.2)
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                if ent:GetNW2Float("CaosDash_chargeup_duration") > CurTime() then
                    ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.1) 
                end

                if not ply:GetNW2Bool("clashingminigame_om_isinminigame") then
                    if not ent:GetNW2Bool("CaosDashEndSoundDebounce") then
                        ent:SetNW2Bool("CaosDashEndSoundDebounce", true)
                    end
                        
                    ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.1) 
                    if ent:GetNW2Float("CaosDash_chargeup_duration") < CurTime() then
                        local jumpscare_entity = nil
                        local chasodashdirection = ply:GetVelocity():GetNormalized()
                        for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 95)) do

                            if ply:IsNextBot() then
                                if ply:IsPossessed() then
                                    if ent2 == ply:GetPossessor() then continue end
                                end
                            end
                            if ent2:GetClass() == "gmod_hands" then continue end
                            if ent2:GetClass() == "pill_ent_costume" then continue end
                            if ent2:GetClass() == "pill_puppet" then continue end
                            if ent2:GetClass() == "predicted_viewmodel" then continue end
                            if ent2:GetClass() == "manipulate_bone" then continue end
                            if ent2:GetClass() == "info_target" then continue end
                            if ent2:GetClass() == "env_spritetrail" then continue end
                            if ent2:GetClass() == "pill_omoveride_puppet" then continue end
                            if ent2:GetClass() == "ent_om_hedgehog_dropballs" then continue end

                            if ent2 == ent:GetNW2Entity("GlowingBallThingy_OM") then continue end

                            if IsValid(ent2:GetNW2Entity("DrGBasePossessing")) then continue end
                            if ent2:GetClass() == "pill_puppet" then continue end
                            if not GetConVar('PVPStun_OM_exe'):GetBool() then
                                if ent2:GetNW2Bool("OM_character_monster") then continue end
                            end
                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                            if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
                                if ent2 == ply then continue end
                                if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                if ent2:GetNW2Float("Fleetway_damage_dash"..ent:EntIndex(),0) < CurTime() then
                                    ent2:SetNW2Float("Fleetway_damage_dash"..ent:EntIndex(),CurTime()+0.3)

                                    if GetConVar('PVPStun_OM_clashing'):GetBool() then
                                        if ent2.OM_ShouldClash then
                                            local variable = ent2.OM_ShouldClash()
                                            if variable then
                                                OM_Minigame(ply, ent2)
                                                break
                                            end
                                        end
                                    end
                                    if not Mutal_OMCanDamage(ply,ent,ent2) then continue end

                                    local idname = "Fw_spindash_hit_".. ent:GetNW2Float("FleetwaySpiNDash_id") .. " " .. ent:EntIndex() .. " "

                                    local convarbcimlazy = GetConVar("OUTCOMEMORIES_N_Fleetway_CaosDash_Limit"):GetInt()

                                    if ent:GetNW2Float(idname) <= convarbcimlazy or convarbcimlazy == 0 then 

                                        if not jumpscare_entity then
                                            jumpscare_entity = ent2
                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/fleetway/Chaos dash hit 1.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )
                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/fleetway/Chaos dash hit 2.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )
                                            ent:SetNW2Float("CurrentSpeed_dashnig",GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Speed"):GetInt()*0.6)
                                            ent:SetNW2Float("CurrentSpeed_dashnigSuppressed",ent:GetNW2Float("CurrentSpeed_dashnig"))
                                        end

                                        KillerdamagestunDynamic({
                                            ply = ply,
                                            target = ent2,
                                            DamageNumb = GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Damage"):GetFloat(),
                                            damagetype = DMG_CLUB,
                                            CustomDamageSound = nil,
                                            damagesound = false,
                                            ShouldBlood = false,
                                            flingremoveal = true,
                                            ShouldBloodEffect = true
                                        })     

                                        if ent:GetNW2Float(idname) >= convarbcimlazy and convarbcimlazy ~= 0 then 
                                            ent2:SetNW2Float(idname, 0)
                                            ent:SetNW2Float("CaosDash_duration", 0)
                                        end
                                        ent:SetNW2Float(idname, ent:GetNW2Float(idname)+1)
                                    else
                                        ent2:SetNW2Float(idname, 0)
                                        ent:SetNW2Float("CaosDash_duration", 0)
                                    end
                                end
                            else
                                local tr = util.TraceLine({
                                    start = ent2:WorldSpaceCenter() + chasodashdirection * -5,
                                    endpos = ent2:WorldSpaceCenter(),
                                    filter = function(hitEnt)
                                        return hitEnt == ent2
                                    end
                                })

                                local killercd = ent:EntIndex().. " fleetway_chaosdashdamagecd"
                                if not ent2[killercd] then
                                    ent2[killercd] = 0
                                end
                                if GetConVar("OUTCOMEMEMORIES_N_Fleetway_DoorsDestruction"):GetBool() then
                                    if tr.Entity == ent2 then
                                        if ent2:GetClass() == "prop_door_rotating" or ent2:GetClass() == "func_door_rotating" then
                                            local dprop = ents.Create("prop_physics")
                                            if not IsValid(dprop) then return end

                                            dprop:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
                                            dprop:SetMoveType(MOVETYPE_VPHYSICS)
                                            dprop:SetSolid(SOLID_BBOX)
                                            dprop:SetPos(ent2:GetPos() + Vector(0, 0, 2))
                                            dprop:SetAngles(ent2:GetAngles())
                                            dprop:SetModel(ent2:GetModel())

                                            ent2:Remove()

                                            dprop:Spawn()

                                            dprop:SetSkin(ent2:GetSkin() or 0)

                                            if ent2:GetNumBodyGroups() then
                                                for id = 0, ent2:GetNumBodyGroups() - 1 do
                                                    dprop:SetBodygroup(id, ent2:GetBodygroup(id))
                                                end
                                            end

                                            for i = 0, 31 do
                                                local mat = ent2:GetSubMaterial(i)
                                                if mat and mat:len() > 0 then
                                                    dprop:SetSubMaterial(i, mat)
                                                end
                                            end

                                            dprop:EmitSound("physics/wood/wood_crate_break3.wav")
                                            local effectdata = EffectData()
                                            effectdata:SetOrigin(dprop:GetPos() + dprop:OBBCenter())
                                            effectdata:SetMagnitude(5)
                                            effectdata:SetScale(2)
                                            effectdata:SetRadius(5)
                                            util.Effect("Sparks", effectdata)
                                                    
                                            local phys = dprop:GetPhysicsObject()
                                            if IsValid(phys) then
                                                phys:ApplyForceOffset(ply:GetForward() * 2000, phys:GetMassCenter())
                                            end
                                        end
                                    end

                                    if GetConVar("OUTCOMEMEMORIES_N_Fleetway_PropsDestruction"):GetBool() then
                                        if ent2[killercd] < CurTime() then

                                            local phys = ent2:GetPhysicsObject()
                                            local dir = (ent2:GetPos() - ent:GetPos()):GetNormalized()

                                            if IsValid(phys) then

                                                local phys = ent2:GetPhysicsObject()
                                                local dir = (ent2:WorldSpaceCenter() - ent:WorldSpaceCenter()):GetNormalized()

                                                if math.random(1,4) == 1 then constraint.RemoveConstraints(ent2, "Weld") end
                                                if math.random(1,8) == 1 then constraint.RemoveConstraints(ent2, "Axis") end
                                                if math.random(1,8) == 1 then constraint.RemoveConstraints(ent2, "Ballsocket") end
                                                if math.random(1,4) == 1 then constraint.RemoveConstraints(ent2, "Rope") end
                                                if math.random(1,8) == 1 then constraint.RemoveConstraints(ent2, "Elastic") end
                                                --if math.random(1,150) == 1 then constraint.RemoveConstraints(ent2, "NoCollide") end

                                                if IsValid(phys) then
                                                    phys:EnableMotion(true)
                                                    phys:Wake()

                                                    phys:ApplyForceCenter(dir * 99999)
                                                end
                                            end


                                            if ply:IsPlayer() then
                                                net.Start("ShakeCamera_OM")
                                                net.Send(ply)
                                            end

                                            ent2[killercd] = CurTime() + 0.5

                                            local dmg = DamageInfo()
                                            dmg:SetDamage(GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Damage"):GetFloat()*0.75)
                                            dmg:SetDamageType(DMG_CLUB)
                                            dmg:SetAttacker(ply)
                                            dmg:SetInflictor(ply)
                                            dmg:SetDamageForce(dir * 2500)
                                            dmg:SetDamagePosition(tr.HitPos)

                                            ent2:DispatchTraceAttack(dmg, tr, tr.Normal)

                                            if not jumpscare_entity and ent2:Health() > 0.1 then
                                                jumpscare_entity = ent2
                                                AdvancedPillSound(
                                                    {
                                                        stringe = "OM/fleetway/Chaos dash hit 1.wav",
                                                        pitchPercent = 100,
                                                        volume = 1,
                                                        soundLevel = 87
                                                    },
                                                    ent
                                                )
                                                AdvancedPillSound(
                                                    {
                                                        stringe = "OM/fleetway/Chaos dash hit 2.wav",
                                                        pitchPercent = 100,
                                                        volume = 1,
                                                        soundLevel = 87
                                                    },
                                                    ent
                                                )
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                        
                    if not ply:GetNW2Bool("clashingminigame_om_isinminigame") then
                        if ent:GetNW2Float("CaosDash_chargeup_duration") < CurTime() then
                            ply:SetNW2Float("OM_SetVelocity_pos", CurTime()+0.2)
                            if ply:IsPlayer() then
                                ply:SetNW2Vector("OM_SetVelocity_Vector",ply:EyeAngles():Forward() * (ent:GetNW2Float("CurrentSpeed_dashnig")*2))
                            else
                            end
                        end

                        if ent:GetNW2Float("CurrentSpeed_dashnig") > 300 then 
                            ent:SetNW2Float("CurrentSpeed_dashnig",ent:GetNW2Float("CurrentSpeed_dashnig")-1.5)
                        else
                            if GetConVar("OUTCOMEMORIES_N_Fleetway_CaosDash_autocancel"):GetBool() then
                                ent:SetNW2Float("CaosDash_duration", 0)
                            end
                        end
                        if ent:GetNW2Float("CurrentSpeed_dashnigSuppressed") < 20 then 
                            if GetConVar("OUTCOMEMORIES_N_Fleetway_CaosDash_autocancel"):GetBool() then
                                ent:SetNW2Float("CaosDash_duration", 0)
                            end
                        else
                            ent:SetNW2Float("CurrentSpeed_dashnigSuppressed",ent:GetNW2Float("CurrentSpeed_dashnigSuppressed")-0)
                        end


                        if SERVER then
                            if not ent._OldCollisionBounds then
                                local mins, maxs = ply:GetCollisionBounds()
                                ent._OldCollisionBounds = { mins, maxs }
                            end

                            --ply:SetCollisionBounds(Vector(-10, -10, -10), Vector(10, 10, 10))
                        end
                        ent:SetNW2Float("dash_OM_Fleetway_Cooldown2", CurTime() + 1)
                    end
                end
            else
                if ent:GetNW2Bool("CaosDashEndSoundDebounce") then
                    ent:SetNW2Float("AttackCooldown_OM", CurTime() + 0.1)
                    ent:SetNW2Bool("CaosDashEndSoundDebounce", false)
                    ent:SetNW2Float("dash_OM_Fleetway_Cooldown", CurTime() + ent.formTable.Outcomememories_stats.abilities.CaosDash.Cooldown())
                    ent:SetNW2Float("dash_OM_Fleetway_Cooldown_duration", ent.formTable.Outcomememories_stats.abilities.CaosDash.Cooldown())

                    AdvancedPillSound(
                        {
                            stringe = "OM/fleetway/S3K_5E.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() then
                    ent:SetNW2Float("CaosDash_duration", 0)
                end
                if SERVER then
                    if ent._OldCollisionBounds then
                        local oldMins = ent._OldCollisionBounds[1]
                        local oldMaxs = ent._OldCollisionBounds[2]

                        --ply:SetCollisionBounds(oldMins, oldMaxs)

                        ent._OldCollisionBounds = nil
                    end
                    if ent.trailPeel then
                        if IsValid(ent.trailPeel) then
                            ent.trailPeel:Remove()
                        end
                        ent.trailPeel = nil
                    end
                end
            end
        end

        if ent:GetNW2Float("OM_LaserDuration") > CurTime() and ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) < CurTime() then

            if not ent:GetNW2Bool("laserofchaos_OM_Fleetway_debounce") then 
                ent:SetNW2Bool("laserofchaos_OM_Fleetway_debounce", true)

                AdvancedPillSound(
                    {
                        stringe = "OM/Fleetway/snd_bombsplosion.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                AdvancedPillSound(
                    {
                        stringe = "OM/Fleetway/lasershoot_1.wav",
                        pitchPercent = 100,
                        volume = 0.3,
                        soundLevel = 87
                    },
                    ent
                )
                AdvancedPillSound(
                    {
                        stringe = "OM/Fleetway/lasershoot_2.wav",
                        pitchPercent = 100,
                        volume = 0.3,
                        soundLevel = 87
                    },
                    ent
                )

                AdvancedPillSound(
                    {
                        stringe = "OM/Fleetway/Fleetway laser big.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent:SetNW2Float("LaserSizeCurtime", CurTime())
                ent:SetNW2Bool("drawfleetwaylaser", true)
                    
                local ed = EffectData()
                ed:SetOrigin(ent:GetPos() + Vector(0,0,50))
                util.Effect("fleetway_explosion_laser", ed, true, true)
                
                local effectdata = EffectData()
                effectdata:SetOrigin(ply:GetPos()+ply:GetAngles():Up()*60)
                util.Effect("Fleetway_lasershootout", effectdata)
            end


            if ent:GetNW2Float("OM_LaserDuration") < CurTime() + 2 then
                if not ent:GetNW2Bool("laserofchaos_OM_Fleetway_debounce2") then 
                    ent:SetNW2Bool("laserofchaos_OM_Fleetway_debounce2", true)
                    ent:SetNW2Bool("NoAbilityUse_fleetway", false)

                    ent:StopSound("OM/Fleetway/Fleetway laser small.wav")
                    ent:StopSound("OM/Fleetway/Fleetway laser big.wav")
                    AdvancedPillSound(
                        {
                            stringe = "OM/Fleetway/Fleetway laser small.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )
                    AdvancedPillSound(
                        {
                            stringe = "OM/Fleetway/emrald.wav",
                            pitchPercent = 70,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )

                    local e = EffectData()
                    e:SetEntity(ent)
                    util.Effect("OM_LaserEnd_Fleetway", e)
                end
            end

            if ent:GetNW2Float("OM_LaserDuration_last") < CurTime() then
                if SERVER and GetConVar("OUTCOMEMORIES_N_Fleetway_LaserOfDestruction_autocancel"):GetBool() then
                    ent:SetNW2Float("OM_LaserDuration", CurTime())
                end
            end
        else
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() then
                ent:SetNW2Float("OM_LaserDuration", CurTime()-1)
            end
            if ent:GetNW2Bool("laserofchaos_OM_Fleetway_debounce") then 
                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 0.1)
                ent:SetNW2Bool("laserofchaos_OM_Fleetway_debounce", false)
                ent:SetNW2Bool("laserofchaos_OM_Fleetway_debounce2", false)
                if SERVER then
                    ent:SetNW2Float("laserofchaos_OM_Fleetway_Cooldown", CurTime() + GetConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Cooldown"):GetFloat())
                    ent:SetNW2Float("laserofchaos_OM_Fleetway_Cooldown_duration", GetConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Cooldown"):GetFloat())
                end
                ply:SetNW2Float("OM_NoMovement_noodles", CurTime())


                if ply:IsPlayer() then 
                    ply:SetMoveType(MOVETYPE_WALK)
                else
                end

                ply:SetSolid(SOLID_BBOX) 
                ent:SetNW2Bool("drawfleetwaylaser", false)

                ent:StopSound("OM/Fleetway/Fleetway laser small.wav")
                ent:StopSound("OM/Fleetway/Fleetway laser big.wav")
                if IsValid(SphereEntity_om_fleetway) then
                    SphereEntity_om_fleetway:Remove()                    
                end

                local e = EffectData()
                e:SetEntity(ent)
                util.Effect("OM_LaserEnd_Fleetway", e)
                            
                AdvancedPillSound(
                    {
                        stringe = "OM/Fleetway/drainhealth.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                ent:SetNW2Bool("IsInLaserOfDestruction", false)
                ent:SetNW2Bool("NoAbilityUse_fleetway", false)
            end
        end

        if SERVER then
            if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() and ent:GetNW2Bool("FatefulDrainMode") then
                ply:SetNW2Float('OM_Noairmovemtn_noodles', CurTime()+0.5)
                ent:SetNW2Bool("Absorbing", false)
                ent:SetNW2Bool("FatefulDrainMode", false)
                if ply:IsPlayer() then
                    ply:SetMoveType(MOVETYPE_WALK)
                else
                    ply:SetMoveType(0)
                end
                ply:SetSolid(SOLID_BBOX) 
                ent:SetNW2Entity("FatefulDrain_absorbenemy", NULL)
                ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown", CurTime() + ent.formTable.Outcomememories_stats.abilities.Fatefuldrain.Cooldown())
                ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown_duration", ent.formTable.Outcomememories_stats.abilities.Fatefuldrain.Cooldown())
                ent:SetNW2Float("FatefulDrain_left",0)
            end
            
            if ent:GetNW2Bool("FatefulDrainMode") or (ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing")) and ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) < CurTime() then
                
                ent:SetNW2Float("OM_airmovement_disabled_float", CurTime()+0.1)
                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 0.1)

                --ply:SetNW2Float('OM_Noairmovemtn_noodles', CurTime()+0.1)
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun_iframe2") > CurTime()+ 1 then
                else
                    ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+0.1) 
                end

                if not ent:GetNW2Bool("FatefulDrain_toggle_new") then
                    ent:SetNW2Bool("FatefulDrain_toggle_new", true)
                    ent.Fatefuldrain_hastouchedground = false
                end

                if ply:IsOnGround() or ent.Fatefuldrain_hastouchedground then

                    if not ent.Fatefuldrain_hastouchedground then
                        ent:SetNW2Float("FatefulDrain_Wait", CurTime() + 1.1)
                        if ent:GetNW2Float("FatefulDrain_left") <= 0 then
                            ent:SetNW2Float("FatefulDrain_left",3)
                        end

                        ent:GetPuppet():SetNW2Float('Fleetway_body_glowwhite_burst',CurTime()+0.2)

                        ply:SetNW2Float("OM_NoMovement_noodles_jump", CurTime() + 1.1)
                        ply:SetGravity(1)
                    end

                    ent.Fatefuldrain_hastouchedground = true
                    if ent:GetPuppet():GetNW2Float("Fleetway_body_glowwhite_burst") < CurTime() then
                        if ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing") and not ent:GetNW2Bool("FatefulDrainMode_moving") then--FatefulDrain_absorbenemyFatefulDrain_absorbenemy

                            ent:SetNW2Float("FatefulDrain_absorbenemy_lastduration", CurTime()+2) 
                            if ent:GetNW2Bool("FatefulDrainMode_moving") then
                            else
                                if ent:GetNW2Float("fateful_drain_drainenemycooldown") > CurTime() then
                                else
                                    if ent:GetNW2Float("fateful_drain_drainenemyAmountHit") > 30 or !IsValid(ent:GetNW2Entity("FatefulDrain_absorbenemy")) or ent:GetNW2Entity("FatefulDrain_absorbenemy"):Health() < 0.1 then
                                        ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.5)
                                        ent:SetNW2Bool("Absorbing", false)
                                        ent:SetNW2Bool("FatefulDrainMode", false)
                                        if ply:IsPlayer() then
                                            --ply:SetMoveType(MOVETYPE_WALK)
                                        else
                                            --ply:SetMoveType(0)
                                        end
                                        if IsValid(ent:GetNW2Entity("FatefulDrain_absorbenemy")) and ent:GetNW2Entity("FatefulDrain_absorbenemy"):Health() > 0 then
                                            if SERVER then
                                                --[[
                                                AdvancedPillSound(
                                                    {
                                                        stringe = "OM/fleetway/Fleetway fateful drain release 2.wav",
                                                        pitchPercent = 100,
                                                        volume = 1,
                                                        soundLevel = 87
                                                    },
                                                    ent
                                                )]]
                                                ent:PillAnim('AbsorbEnd')
                                                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 2.7)
                                                ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 2)
                                                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+3) 
                                                ent:SetNW2Float("FatefulDrain_absorbenemy_lastduration", CurTime()+2) 
                                            end
                                        end
                                        ply:SetSolid(SOLID_BBOX) 
                                        ent:SetNW2Entity("FatefulDrain_absorbenemy", NULL)
                                        ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown", CurTime() + GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_Cooldown"):GetFloat())
                                        ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown_duration", ent.formTable.Outcomememories_stats.abilities.Fatefuldrain.Cooldown())
                                        ent:SetNW2Float("FatefulDrain_left",0)
                                        ent:SetNW2Float("FatefulDrain_absorbenemy_lastduration", CurTime()+2) 

                                    else
                                        if IsValid(ent:GetNW2Entity("FatefulDrain_absorbenemy")) and ent:GetNW2Entity("FatefulDrain_absorbenemy"):Health() > 0.1 then
                                            ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 0.5)
                                            if ply:GetNW2Float("MaxHealth_OM")>ply:Health() then
                                                ply:SetHealth(ply:Health()+GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_healthadd"):GetInt())
                                                if ply:GetNW2Float("MaxHealth_OM")<ply:Health() then
                                                    ply:SetHealth(ply:GetNW2Float("MaxHealth_OM"))
                                                end
                                            end

                                            ent:SetNW2Float("fateful_drain_drainenemycooldown", CurTime()+ 0.25)
                                            ent:SetNW2Float("fateful_drain_drainenemyAmountHit", ent:GetNW2Float("fateful_drain_drainenemyAmountHit") + 3)
                                            local ent2 = ent:GetNW2Entity("FatefulDrain_absorbenemy")
                                            
                                            Killerdamagestun(ply, ent2, GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_damage"):GetInt(), DMG_CLUB, true)
                                            ent2:SetNW2Float("OM_Damage_ReductionRemoveal", CurTime()+0.1)

                                            ent:SetNW2Bool("FatefulDrainMode", false)
                                            ent:SetNW2Bool("FatefulDrainMode_moving", false)

                                            ent:GetPuppet():SetNW2Float("fleetwayHeal_highlight", CurTime()+0.5*0.35)
                                            if IsValid(ent:GetNW2Entity("FatefulDrain_absorbenemy")) then
                                                ent:GetNW2Entity("FatefulDrain_absorbenemy"):SetNW2Float('fleetway_fatefuldrain_red',CurTime()+0.5*0.35)
                                            end
                                            --[[
                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/Fleetway/drainhealth.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )]]

                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/Fleetway/fatefuldrain_damage_4.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )
                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/Fleetway/fatefuldrain_damage_3.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )
                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/Fleetway/fatefuldrain_damage_2.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )
                                            AdvancedPillSound(
                                                {
                                                    stringe = "OM/Fleetway/fatefuldrain_damage_1.wav",
                                                    pitchPercent = 100,
                                                    volume = 1,
                                                    soundLevel = 87
                                                },
                                                ent
                                            )

                                            ent:SetNW2Float("fateful_drain_drainenemy_ragexistance", CurTime()+ 1)
                                                                
                                            ply:SetVelocity(Vector(0,0,0))
                                            ply:SetLocalVelocity(Vector(0,0,0))
                                        end
                                    end
                                end
                                local ent2 = ent:GetNW2Entity("FatefulDrain_absorbenemy")
                                if IsValid(ent2) then
                                else                       
                                    ent:SetNW2Bool("Absorbing", false)
                                    ent:SetNW2Bool("FatefulDrainMode", false)

                                    if ply:IsPlayer() then
                                        ply:SetMoveType(MOVETYPE_WALK)
                                    else
                                        ply:SetMoveType(0)
                                    end
                                    ply:SetSolid(SOLID_BBOX) 
                                end
                            end
                        else
                            if ent:GetNW2Float("FatefulDrain_Wait") > CurTime() then
                                if not ent:GetNW2Bool("TargetSound") then

                                    if ply:IsPlayer() then
                                        ply:SetMoveType(MOVETYPE_WALK)
                                    else
                                        ply:SetMoveType(0)
                                    end

                                    ent:SetNW2Bool("TargetSound", true)
                                    AdvancedPillSound(
                                        {
                                            stringe = "OM/Fleetway/target.wav",
                                            pitchPercent = 100,
                                            volume = 2,
                                            soundLevel = 87
                                        },
                                        ent
                                    )

                                    AdvancedPillSound(
                                        {
                                            stringe = {
                                                "OM/Fleetway/fatefuldrain1.wav",
                                                "OM/Fleetway/fatefuldrain2.wav",
                                                "OM/Fleetway/fatefuldrain3.wav"
                                            },
                                            pitchPercent = 100,
                                            volume = 1,
                                            soundLevel = 87
                                        },
                                        ent
                                    )

                                end
                                
                                local ang = ply:EyeAngles()
                                if ply:IsPlayer() then
                                else
                                    ang = ply:GetAngles()
                                end
                                ang.p = 0
                                ang.r = 0
                                ent:SetNW2Vector('PositionGoTo_fatefuldrain_om_End', ang:Forward())
                                ent:SetNW2Vector('PositionGoTo_fatefuldrain_om_Star', ply:GetPos())

                                if ent:GetNW2Float("FatefulDrain_Wait_Duration") < CurTime() then
                                    ent:SetNW2Float('FatefulDrain_Wait_Duration',CurTime()+0.5*0.5)
                                    ent:GetPuppet():SetNW2Float('fleetway_fatefuldrain_red',CurTime()+0.5*0.3)
                                    ent:GetPuppet():SetNW2Float('knuckles_block_outline',CurTime()+0.5*0.3)
                                end
                            else
                                ent:SetNW2Float("RollEndTime_om", 0 )

                                                    if SERVER then

                                                        local hullSize = Vector(16, 16, 34)
                                                        local tr = util.TraceHull({
                                                            start = ply:GetPos(),
                                                            endpos = ply:GetPos()-Vector(0,0,10),
                                                            filter = function(hitchar)
                                                                if not IsValid(hitchar) then return true end

                                                                if hitchar:IsPlayer() then return false end
                                                                if hitchar:IsNPC() then return false end
                                                                if hitchar:IsNextBot() then return false end

                                                                if hitchar == ent then return false end
                                                                if hitchar == ent:GetPuppet() then return false end

                                                                if hitchar == ent:GetNW2Entity("FatefulDrain_absorbenemy_rag") then return false end

                                                                return true
                                                            end,
                                                            mask = MASK_SOLID,
                                                            mins = -hullSize * 0.5,
                                                            maxs = hullSize * 0.5
                                                        })
                                                        if tr.Hit then
                                                            local startpos  = ent:GetNW2Vector("PositionGoTo_fatefuldrain_om_Star")
                                                            local endpos  = ent:GetNW2Vector("PositionGoTo_fatefuldrain_om_End")*5

                                                            startpos.z = ply:GetPos().z
                                                            endpos.z = ply:GetPos().z
                                                            
                                                            local position  = startpos + endpos
                                                            position.z = ply:GetPos().z

                                                            local dir = (position - startpos)
                                                            local ang = dir:Angle()
                                                            ang.p = 0

                                                            local ed = EffectData()
                                                            ed:SetOrigin(ply:GetPos()+Vector(0,0,1))
                                                            ed:SetNormal(ang:Forward())
                                                            ed:SetScale(1)
                                                            util.Effect("Fleetway_fatefuldrain_ground_destroy", ed)
                                                        end



                                                        if ent:GetNW2Float("FatefullDrain_EffectCooldown") < CurTime() then
                                                            ent:SetNW2Float("FatefullDrain_EffectCooldown", CurTime()+0.05)

                                                            util.Effect("Fleetway_fatefuldrain_energy_beam", EffectData({
                                                                origin = ply:GetPos()+Vector(0,0,1),
                                                                normal = ply:GetUp()*5,
                                                                scale = 1.5
                                                            }))
                                                            --[[
                                                            local Sphere = ents.Create("prop_physics")
                                                            Sphere:SetModel("models/xqm/cylinderx2big.mdl")
                                                            Sphere:SetPos(ply:GetPos() + Vector(0,0,30))
                                                            Sphere:SetAngles(Angle(90,0,0))
                                                            Sphere:Spawn()
                                                            Sphere:Activate()
                                                            Sphere:SetMaterial("models/noodles/om/Amy/white")

                                                            Sphere:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

                                                            Sphere:PhysicsInit(MOVETYPE_NONE)
                                                            Sphere:SetMoveType(MOVETYPE_NONE)
                                                            Sphere:SetSolid(MOVETYPE_NONE)

                                                            Sphere:SetRenderMode(RENDERMODE_TRANSALPHA)
                                                            Sphere:SetColor(Color(255,255,255,255))
                                                            Sphere:DrawShadow(false)

                                                            ent:DeleteOnRemove(Sphere)

                                                            local startTime = CurTime()
                                                            local totalTime = 0.3

                                                            local startScale = 1
                                                            local endScale   = 0.1

                                                            local hookID = "Shockwave_" .. Sphere:EntIndex()

                                                            hook.Add("Think", hookID, function()

                                                                if not IsValid(Sphere) then
                                                                    hook.Remove("Think", hookID)
                                                                    return
                                                                end

                                                                local t = (CurTime() - startTime) / totalTime
                                                                t = math.Clamp(t, 0, 1)

                                                                local eased = t * t * (3 - 2 * t)

                                                                local currentScale = Lerp(eased, startScale, endScale)*1.4
                                                                Sphere:ManipulateBoneScale(0, Vector(1,currentScale,currentScale))

                                                                if t >= 1 then
                                                                    Sphere:Remove()
                                                                    hook.Remove("Think", hookID)
                                                                end
                                                            end)
                                                            ]]
                                                            
                                                        end
                                                    end 

                                if ent:GetNW2Float("FatefulDrainMode_endlag") > CurTime() then
                                    ent:SetNW2Bool("FatefulDrainMode_endlag_bool", true)



                                else 
                                    if ent:GetNW2Bool("FatefulDrainMode") then
                                        if ent:GetNW2Bool("TargetSound") then
                                            ent:SetNW2Bool("TargetSound", false)
                                            
                                        end
                                        if ent:GetNW2Bool("FatefulDrainMode_moving") then



                                            local startpos  = ent:GetNW2Vector("PositionGoTo_fatefuldrain_om_Star")
                                            local endpos  = ent:GetNW2Vector("PositionGoTo_fatefuldrain_om_End")*5

                                            startpos.z = ply:GetPos().z
                                            endpos.z = ply:GetPos().z
                                            
                                            local position  = startpos + endpos
                                            position.z = ply:GetPos().z

                                            local dir = (position - startpos)
                                            local ang = dir:Angle()
                                            ang.p = 0

                                            local shouldreturn = false
                                            ent:SetNW2Float("fateful_drain_drainenemy_ragexistance", CurTime()+ 1)
                                            if SERVER then
                                                if ent:GetNW2Bool("Absorbing") then
                                                else

                                                    local nearest
                                                    local nearestDist = math.huge

                                                    local attackPos = ent:LocalToWorld(Vector(0, 0, 50))

                                                    for _, ent2 in pairs(ents.FindInSphere(attackPos, 180)) do
                                                        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.01 then

                                                            if ent2 == ply then continue end
                                                            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                                                            if not GetConVar('PVPStun_OM_exe'):GetBool() then
                                                                if ent2:GetNW2Bool("OM_character_monster") then continue end
                                                            end
                                                            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
                                                            if ent:IsNextBot() then
                                                                if ent.GetPossessor and ent:GetPossessor() == ent2 then continue end
                                                            end
                                                            if Mutal_OMCanDamage_grab(ply,ent,ent2) then -- FatefulDrain_absorbenemyFatefulDrain_absorbenemy

                                                                local dist = attackPos:DistToSqr(ent2:GetPos())

                                                                if dist < nearestDist then
                                                                    nearestDist = dist
                                                                    nearest = ent2
                                                                end
                                                            end
                                                        end
                                                    end

                                                    if IsValid(nearest) then
                                                        local ent2 = nearest

                                                        ent:SetNW2Entity("FatefulDrain_absorbenemy", ent2)
                                                        ent:SetNW2Bool("Absorbing", true)

                                                        ent:SetNW2Float("fateful_drain_drainenemy_ragexistance", CurTime()+ 0.25)
                                                        local hasflung = false
                                                        local hasflung2 = false
                                                        local throwduration = CurTime()

                                                        ent.OM_CounteredByChar = false
                                                        --ent:SetNWBool("JumpscareAnim_om_boolean2", false)
                                                        local enemyragdoll = CreateRagdolLCharacter_OM({
                                                            target = ent2,
                                                            host = ent,

                                                            shouldremove = function(createfakeragdoll)
                                                                if not IsValid(createfakeragdoll) then return true end
                                                                if not IsValid(ent2) then return true end
                                                                if not IsValid(ent) then return true end

                                                                if ent:GetNW2Float("OM_executionanim") > CurTime() then
                                                                    ent2:SetNW2Float("ragdolltype_grab", CurTime()+0.1)
                                                                    return false
                                                                end
                                                                
                                                                if ent:GetNW2Float("fateful_drain_drainenemy_ragexistance") < CurTime() then
                                                                    AdvancedPillSound(
                                                                        {
                                                                            stringe = "OM/Fleetway/Fatefuldrain_nd.wav",
                                                                            pitchPercent = 100,
                                                                            volume = 1,
                                                                            soundLevel = 87
                                                                        },
                                                                        ent
                                                                    )

                                                                    return true
                                                                else
                                                                    ent2:SetNW2Float("ragdolltype_grab", CurTime()+0.1)
                                                                end


                                                                return false
                                                            end,

                                                            shoulddocustomfunction = function(createfakeragdoll)
                                                                if not IsValid(createfakeragdoll) then return end

                                                                local absorbed = ent:GetNW2Entity("FatefulDrain_absorbenemy")
                                                                local puppet = ent:GetPuppet()
                                                                if not IsValid(puppet) then return end

                                                                local headPhys
                                                                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                                                    local phys = createfakeragdoll:GetPhysicsObjectNum(i)
                                                                    if IsValid(phys) then
                                                                        local boneIndex = createfakeragdoll:TranslatePhysBoneToBone(i)
                                                                        local boneName = createfakeragdoll:GetBoneName(boneIndex) or ""

                                                                        if string.find(string.lower(boneName), "head", 1, true) then
                                                                            headPhys = phys
                                                                            break
                                                                        end
                                                                    end
                                                                end

                                                                if not IsValid(headPhys) then
                                                                    headPhys = createfakeragdoll:GetPhysicsObject()
                                                                end
                                                                if not IsValid(headPhys) then return end

                                                                local bone = puppet:LookupBone("RightHand")
                                                                if not bone then return end

                                                                local pos, ang = puppet:GetBonePosition(bone)

                                                                if ent:GetNW2Float("OM_executionanim") > CurTime() then
                                                                    if not ent:GetNWBool("JumpscareAnim_om_boolean2") then
                                                                        if not throw then
                                                                            throw = true
                                                                            headPhys:ApplyForceCenter(puppet:GetRight()*3000)
                                                                        end
                                                                        return true end

                                                                    headPhys:SetPos(pos)
                                                                    headPhys:SetAngles(ang)
                                                                    headPhys:SetVelocityInstantaneous(vector_origin)
                                                                    headPhys:Wake()
                                                                end

                                                                pos = puppet:GetPos() + puppet:GetForward()* 40 + puppet:GetUp()*40
                                                                if not pos then return end

                                                                if throwduration > CurTime() then
                                                                    local throwDir = ent:GetPuppet():GetRight()
                                                                    local force = throwDir * 1000 + Vector(0, 0, 350)

                                                                    headPhys:EnableMotion(true)
                                                                    headPhys:SetVelocityInstantaneous(force)
                                                                    createfakeragdoll:SetCollisionGroup(0)
                                                                end

                                                                if ((ent:GetNW2Float("fateful_drain_drainenemyAmountHit") < 30 and IsValid(absorbed) and absorbed:Health() > 0) or hasflung) and not hasflung2 then
                                                                    headPhys:SetPos(pos)
                                                                    headPhys:SetAngles(ang)
                                                                    headPhys:SetVelocityInstantaneous(vector_origin)
                                                                    headPhys:Wake()
                                                                    return
                                                                end

                                                                if not hasflung then
                                                                    hasflung = true
                                                                    
                                                                    timer.Simple(0.75,function()
                                                                        if IsValid(createfakeragdoll) then 
                                                                            local throwDir = ang:Forward()
                                                                            local force = throwDir * 100 + Vector(0, 0, 150)

                                                                            headPhys:EnableMotion(true)
                                                                            headPhys:SetVelocityInstantaneous(force)
                                                                            createfakeragdoll:SetCollisionGroup(0)
                                                                            hasflung2 = true
                                                                            ent:SetNW2Float("fateful_drain_drainenemy_ragexistance", CurTime()+ 2.6)
                                                                            throwduration = CurTime()+0.06
                                                                        end
                                                                    end)
                                                                end
                                                            end,
                                                        })
                                                        ent:SetNW2Entity("FatefulDrain_absorbenemy_rag", enemyragdoll)

                                                    end
                                                end
                                            end

                                            local hullSize = Vector(16, 16, 34) -- FatefulDrain_absorbenemy_ragFatefulDrain_absorbenemy_rag
                                            local startPos = ply:GetPos() + Vector(0,0,30)
                                            local endPos = startPos + ent:GetPuppet():GetForward()*60

                                            local tr = util.TraceHull({
                                                start = startPos,
                                                endpos = endPos,
                                                filter = function(hitchar)
                                                    if not IsValid(hitchar) then return true end

                                                    if hitchar:IsPlayer() then return false end
                                                    if hitchar:IsNPC() then return false end
                                                    if hitchar:IsNextBot() then return false end

                                                    if hitchar == ent then return false end
                                                    if hitchar == ent:GetPuppet() then return false end

                                                    if hitchar == ent:GetNW2Entity("FatefulDrain_absorbenemy_rag") then return false end

                                                    return true
                                                end,
                                                mask = MASK_SOLID,
                                                mins = -hullSize * 0.5,
                                                maxs = hullSize * 0.5
                                            })

                                            if tr.Hit then
                                                shouldreturn = true
                                                ent:SetNW2Bool("FatefulDrainMode", false)
                                                ent:SetNW2Bool("FatefulDrainMode_moving", false)
                                                ent:SetNW2Bool("FatefulDrainMode_moving_RELOAD", false)
                                                
                                                if ent:GetNW2Float("FatefulDrain_left") > 0 and ent:GetNW2Bool("FatefulDrainMode_moving_RELOAD") then
                                                    
                                                    ent:SetNW2Bool("FatefulDrainMode_moving_RELOAD", false)

                                                    ent:SetNW2Bool("FatefulDrainMode_endlag_bool", false)
                                                    ent:SetNW2Float("FatefulDrain_Wait", CurTime() + 1.5)
                                                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 1.5)
                                                    ent:SetNW2Bool("Absorbing", false)
                                                    ent:SetNW2Float("fateful_drain_drainenemyAmountHit", 0)
                                                    ent:SetNW2Bool("FatefulDrainMode", true)
                                                else
                                                    ent:SetNW2Bool("FatefulDrainMode", false)
                                                    ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown", CurTime() + 0.3)
                                                    ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown_duration", 0.3)

                                                    if ply:IsPlayer() then
                                                        ply:SetMoveType(MOVETYPE_WALK)
                                                    else
                                                        ply:SetMoveType(0)
                                                    end
                                                    ply:SetSolid(SOLID_BBOX)

                                                    if ent:GetNW2Float("FatefulDrain_left") <= 0 then
                                                        ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown", CurTime() + GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_Cooldown"):GetFloat())
                                                        ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown_duration", GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_Cooldown"):GetFloat())
                                                    end
                                                end
                                            end

                                            if not shouldreturn then

                                                if ent:GetNW2Float("Duration_moveFateful") <= CurTime() then
                                                    ent:SetNW2Float("FatefulDrainMode_endlag", CurTime()+0.3)
                                                    shouldreturn = true
                                                end

                                                if not shouldreturn then
                                                    local vel = ang:Forward() * 3000 --ang:Forward()
                                                    --vel.z = ply:GetVelocity().z

                                                    ply:SetNW2Float("OM_SetVelocity_pos", CurTime() + 0.2)
                                                    ply:SetNW2Vector("OM_SetVelocity_Vector", vel)
                                                end
                                            end
                                        else
                                            if SERVER then
                                                local startposition = ply:EyePos()
                                                ent:SetNW2Bool("FatefulDrainMode_moving", true)
                                                
                                                ent:SetNW2Float("FatefulDrain_transition", CurTime())
                                                ent:SetNW2Float("Duration_moveFateful", CurTime() + 0.27)

                                                ent:SetNW2Float("FatefulDrain_left",ent:GetNW2Float("FatefulDrain_left") - 1)
                                                AdvancedPillSound(
                                                    {
                                                        stringe = "OM/Fleetway/fleetway fateful drain dash.wav",
                                                        pitchPercent = 100,
                                                        volume = 1,
                                                        soundLevel = 87
                                                    },
                                                    ent
                                                )

                                                AdvancedPillSound(
                                                    {
                                                        stringe = "OM/fleetway/Fleetway fateful drain release 2.wav",
                                                        pitchPercent = 100,
                                                        volume = 0.6,
                                                        soundLevel = 87
                                                    },
                                                    ent
                                                )
                                                
                                                ply:SetPos(ply:GetPos()+Vector(0,0,3))

                                                ent:SetNW2Float("fatefuldrain_RELOAD_OM_Fleetway_Cooldown", CurTime() + 0.3)         
                                            end
                                        end
                                    end

                                    if ent:GetNW2Bool("FatefulDrainMode_endlag_bool") then
                                        ent:SetNW2Bool("FatefulDrainMode_endlag_bool", false)

                                        ent:SetNW2Bool("FatefulDrainMode_moving", false)
                                        if ent:GetNW2Float("FatefulDrain_left") > 0 and ent:GetNW2Bool("FatefulDrainMode_moving_RELOAD") then
                                            
                                            ent:SetNW2Bool("FatefulDrainMode_moving_RELOAD", false)

                                            ent:SetNW2Bool("FatefulDrainMode_endlag_bool", false)
                                            ent:SetNW2Float("FatefulDrain_Wait", CurTime() + 1.5)
                                            ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 1.5)
                                            ent:SetNW2Bool("Absorbing", false)
                                            ent:SetNW2Float("fateful_drain_drainenemyAmountHit", 0)
                                            ent:SetNW2Bool("FatefulDrainMode", true)
                                        else
                                            ent:SetNW2Bool("FatefulDrainMode", false)

                                            if ply:IsPlayer() then
                                                ply:SetMoveType(MOVETYPE_WALK)
                                            else
                                                ply:SetMoveType(0)
                                            end
                                            ply:SetSolid(SOLID_BBOX)

                                            ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown", CurTime() + 0.3)
                                            ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown_duration", 0.3)


                                            if ent:GetNW2Float("FatefulDrain_left") <= 0 then
                                                ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown", CurTime() + GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_Cooldown"):GetFloat())
                                                ent:SetNW2Float("fatefuldrain_OM_Fleetway_Cooldown_duration", GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_Cooldown"):GetFloat())
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    ply:SetGravity(1.5)


                    local oldvelocity = ply:GetVelocity()
                    oldvelocity.x = oldvelocity.x*0.98
                    oldvelocity.y = oldvelocity.y*0.98
                    if ply:IsPlayer() then
                        ply:SetLocalVelocity(oldvelocity)
                    else
                        ply:SetVelocity(oldvelocity)
                    end



                end
            else
                if ent:GetNW2Bool("FatefulDrain_toggle_new") then
                    ent:SetNW2Bool("FatefulDrain_toggle_new", false)

                    ply:SetNW2Float("OM_SetVelocity_pos", CurTime() + 0.1)
                    ply:SetNW2Vector("OM_SetVelocity_Vector", Vector(0,0,0))
                    ply:SetLocalVelocity(Vector(0,0,0))
                    ply:SetVelocity(Vector(0,0,0))
                    ent:SetNW2Float("OM_cannotuseabailities", CurTime()+ 0.65)
                end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() then
                    ent:SetNW2Bool("FatefulDrainMode", false)
                    ent:SetNW2Bool("FatefulDrainMode_moving", false)
                    ent:SetNW2Float("FatefulDrain_Wait", 0)
                    ply:SetNW2Float("OM_NoMovement_noodles", 0)
                    ent:SetNW2Bool("Absorbing", false)
                end
            end
        end


        if CLIENT then

            local hookName = "PostDrawTranslucentRenderables"
            local name = "fleetway_ui_OM_noodles"..ent:EntIndex()

            local hooks = hook.GetTable()

            if hooks[hookName] and hooks[hookName][name] then
            else
                local beamMat = {
                    [0] = Material("icons/Fleetway_laser"),
                    [1] = Material("icons/fateful_drain_line"),
                    [2] = Material("icons/Fateful_drain_line_2"),
                }

                hook.Add(hookName, name, function()
                    local ply = LocalPlayer()

                    if !IsValid(ent) then hook.Remove(hookName, name) return end

                    local v = ent
                    v._laserFade = v._laserFade or 0

                    local target = v:GetNW2Bool("drawfleetwaylaser") and 1 or 0
                    v._laserFade = Lerp(FrameTime() * 8, v._laserFade, target)

                    local fade = v._laserFade

                    if fade > 0.001 then

                        local startPos = v:GetNW2Vector("Position1")
                        local endPos = v:GetNW2Vector("Position2")

                        local color = Color(255,255,255,255 * fade)
                        if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then color = Color(211,211,211,255 * fade) else end

                        local width = 100
                        local starttime = v:GetNW2Float("LaserSizeCurtime")

                        local elapsed = CurTime() - starttime
                        local duration = v:GetNW2Float("LaserLastingDuration_amount")

                        if elapsed < 0.5 then
                            width = Lerp(elapsed / 0.5, 0, 100)
                        elseif elapsed < duration - 3 then
                            width = 100
                        else
                            width = Lerp(math.Clamp((elapsed - (duration - 3)) / 3, 0, 1), 100, 0)
                        end

                        width = width *1.85

                        local t = CurTime() * 12
                        local wobble = 2 + math.sin(t) * 2

                        local function wobbleVec(pos, seed)
                            return pos + Vector(
                                math.sin(t + seed) * wobble,
                                math.cos(t * 1.3 + seed) * wobble,
                                math.sin(t * 0.7 + seed) * wobble
                            )
                        end

                        startPos = wobbleVec(startPos, 1)
                        endPos   = wobbleVec(endPos, 3)

                        local dir = (endPos - startPos)
                        local dist = dir:Length()
                        dir:Normalize()

                        local midpoint = startPos + dir * (dist * 0.5)
                        local fadeEnd = startPos + dir * (dist * 0.35)

                        local segments = 30
                        local dir = endPos - startPos
                        local dist = dir:Length()
                        dir:Normalize()

                        render.SetMaterial(beamMat[0])

                        render.StartBeam(segments + 1)

                        for i = 0, segments do
                            local frac = i / segments
                            local pos = startPos + dir * (dist * frac)

                            local beamDist = dist * frac
                            local distFromEnd = dist - beamDist

                            local alphaFrac = math.Clamp(distFromEnd / 50, 0, 1)
                            local dist = (endPos - startPos):Length()

                            local fadeDistance = math.min(150, dist)
                            local fadeStartFrac = (dist - fadeDistance) / dist

                            if frac > fadeStartFrac then
                                alphaFrac = 1 - ((frac - fadeStartFrac) / (1 - fadeStartFrac))
                            end

                            local scroll = CurTime() * 5

                            render.AddBeam(
                                pos,
                                width,
                                frac + scroll,
                                Color(
                                    color.r,
                                    color.g,
                                    color.b,
                                    color.a * alphaFrac
                                )
                            )
                        end

                        render.EndBeam()
                        -- LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1
                        if true then
                        else
                            local glowMat = Material("sprites/light_glow02_add")
                            render.SetMaterial(glowMat)

                            local ft = CurTime()
                            local flicker = (200 + math.Rand(-60, 60)) * fade
                            local pulse = math.sin(ft * 18) * 10
                            local baseSize = (140 + pulse) * (0.3 + 0.7 * fade)

                            render.DrawSprite(
                                startPos,
                                baseSize * 3,
                                baseSize * 3,
                                Color(255, 255, 255, flicker * 0.5)
                            )

                            render.DrawSprite(
                                startPos,
                                baseSize * 4.2,
                                baseSize * 4.2,
                                Color(255, 255, 255, flicker * 0.8)
                            )

                            render.DrawSprite(
                                startPos,
                                baseSize,
                                baseSize,
                                Color(255, 255, 255, flicker)
                            )
                            
                            render.DrawSprite(
                                endPos,
                                baseSize * 1.6,
                                baseSize * 1.6,
                                Color(255, 255, 255, flicker * 0.5)
                            )

                            render.DrawSprite(
                                endPos,
                                baseSize * 1.2,
                                baseSize * 1.2,
                                Color(255, 255, 255, flicker * 0.8)
                            )

                            render.DrawSprite(
                                endPos,
                                baseSize,
                                baseSize,
                                Color(255, 255, 255, flicker)
                            )
                        end
                    end


                    if v:GetNW2Float("FatefulDrain_Wait") > CurTime() then -- or true 
                        local center = v:GetPos() + Vector(0,0,10)
                        local dir = v:GetNW2Vector("PositionGoTo_fatefuldrain_om_End"):GetNormalized()

                        local length = 1250
                        local width = 140

                        local forward = dir * length
                        local right = dir:Cross(Vector(0,0,1)):GetNormalized() * width

                        local leftbottomcorner = center - right * 0.5
                        local rightbottomcorner = center + right * 0.5

                        local lefttopcorner = center + forward - right * 0.5
                        local righttopcorner = center + forward + right * 0.5

                        local midpoint_l_1 = Lerp(0.1, leftbottomcorner, lefttopcorner)
                        local midpoint_r_1 = Lerp(0.1, rightbottomcorner, righttopcorner)

                        local midpoint_l_2 = Lerp(0.8, leftbottomcorner, lefttopcorner)
                        local midpoint_r_2 = Lerp(0.8, rightbottomcorner, righttopcorner)

                        local scrollSpeed = -5
                        local t = CurTime() * scrollSpeed
                        local texScale = length / 150

                        render.SetMaterial(beamMat[1])
                        --render.SetMaterial(Material("models/noodles/om/sonic/whiteglow"))

                        mesh.Begin(MATERIAL_QUADS, 3)
                            --
                            mesh.Position(leftbottomcorner)
                            mesh.TexCoord(0, t, 0)
                            mesh.Color(255,255,255,0)
                            mesh.AdvanceVertex()

                            mesh.Position(midpoint_l_1)
                            mesh.TexCoord(0, t + texScale*0.1, 0)
                            mesh.Color(255,255,255,255)
                            mesh.AdvanceVertex()

                            mesh.Position(midpoint_r_1)
                            mesh.TexCoord(0, t + texScale*0.1, 1)
                            mesh.Color(255,255,255,255)
                            mesh.AdvanceVertex()

                            mesh.Position(rightbottomcorner)
                            mesh.TexCoord(0, t, 1)
                            mesh.Color(255,255,255,0)
                            mesh.AdvanceVertex()


                            --
                            mesh.Position(midpoint_l_1)
                            mesh.TexCoord(0, t+ texScale*0.1, 0)
                            mesh.Color(255,255,255,255)
                            mesh.AdvanceVertex()

                            mesh.Position(midpoint_l_2)
                            mesh.TexCoord(0, t + texScale*0.8, 0)
                            mesh.Color(255,255,255,255)
                            mesh.AdvanceVertex()

                            mesh.Position(midpoint_r_2)
                            mesh.TexCoord(0, t + texScale*0.8, 1)
                            mesh.Color(255,255,255,255)
                            mesh.AdvanceVertex()

                            mesh.Position(midpoint_r_1)
                            mesh.TexCoord(0, t+ texScale*0.1, 1)
                            mesh.Color(255,255,255,255)
                            mesh.AdvanceVertex()

                            --
                            mesh.Position(midpoint_l_2)
                            mesh.TexCoord(0, t + texScale*0.8, 0)
                            mesh.Color(255,255,255,255)
                            mesh.AdvanceVertex()

                            mesh.Position(lefttopcorner)
                            mesh.TexCoord(0, t + texScale, 0)
                            mesh.Color(255,255,255,0)
                            mesh.AdvanceVertex()

                            mesh.Position(righttopcorner)
                            mesh.TexCoord(0, t + texScale, 1)
                            mesh.Color(255,255,255,0)
                            mesh.AdvanceVertex()

                            mesh.Position(midpoint_r_2)
                            mesh.TexCoord(0, t + texScale*0.8, 1)
                            mesh.Color(255,255,255,255)
                            mesh.AdvanceVertex()

                        mesh.End()

                        local startPos = v:GetPos() + Vector(0,0,25)
                        local endPos = startPos + v:GetNW2Vector('PositionGoTo_fatefuldrain_om_End')*length

                        local width = 35

                        local color = Color(255,255,255,255)

                        local beamLength = (endPos - startPos):Length()

                        local scrollSpeed = -4
                        local t = CurTime() * scrollSpeed

                        render.SetMaterial(beamMat[2])
                        render.DrawBeam(startPos, endPos, width, t, t + beamLength/100, color)

                    end
                end)
            end

        end
    end,


    noodles_OM_survivor_keybinds = function(ply, ent, button)
        if SERVER then


            if IsValid(ply:GetNWEntity("OM_ragdollentity")) then
                return
            end
            if ent:GetNW2Float("OM_executionanim") > CurTime() then return end


            if button == ply:GetInfoNum("om_pills_action_fleetway_Burst_key", KEY_I) then
                if not SERVER then return end
                if not GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_useable"):GetBool() then return end

                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNWFloat("OM_cannotuseabailities") > CurTime() then return end
                if ply:GetNWFloat("OM_cannotuseabailities") > CurTime() then return end
                if ent:GetNW2Float("AbilityDisabled_OM") > CurTime() then return end
                if ent:GetNW2Bool("NoAbilityUse_fleetway") then return end
                if ent:GetNW2Bool("LaserDuration") then return end
                if ent:GetNW2Bool("BurstLaserDuration") then return end
                if ent:GetNW2Float("CaosDash_duration", 0) > CurTime() then return end
                if ent:GetNW2Bool("drawfleetwaylaser") then return end
                if ent:GetNW2Bool("FatefulDrainMode") or (ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing")) then return end

                if ent:GetNW2Float("Blast_OM_Fleetway_Cooldown") > CurTime() then return end
                local crazyzset = false

                if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() then
                    ply:SetNW2Float("DisablePlayerMovement_OM_stun", 0)
                    crazyzset = true
                end

                if ent.flyingent and IsValid(ent.flyingent) then
                    ent.flyingent:Remove()
                end
                ply:SetMoveType(MOVETYPE_NONE)

                net.Start("FleetwayBurstStart")
                    net.WriteEntity(ent)
                    net.WriteVector(ply:GetPos() + Vector(0,0,30))
                net.Broadcast()

                AdvancedPillSound(
                    {
                        stringe = {"OM/Fleetway/FleetBurst1.wav","OM/Fleetway/FleetBurst2.wav","OM/Fleetway/FleetBurst3.wav"},
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 100
                    },
                    ent
                )

                --[[
                            AdvancedPillSound(
                                {
                                    stringe = {"OM/joke/ImSorry-1.ogg","OM/joke/ImSorry-2.ogg"},
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                ]]

                AdvancedPillSound(
                    {
                        stringe = "OM/Fleetway/laserchargeup.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 50
                    },
                    ent
                )

                if not GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_cancombo"):GetBool() then
                    ent:SetNW2Bool("LaserDuration", true)
                end
                ent:SetNW2Bool("BurstLaserDuration", true)

                AdvancedPillSound(
                    {
                        stringe = "OM/Fleetway/intro_burst.wav",
                        pitchPercent = 110,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                
                ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+3) 

                timer.Simple(1.5,function()
                    if !IsValid(ent) then return end
                    ent:StopSound("OM/Fleetway/intro_burst.wav")
                    AdvancedPillSound(
                        {
                            stringe = "OM/Fleetway/mus_explosion.wav",
                            pitchPercent = 100,
                            volume = 1,
                            soundLevel = 87
                        },
                        ent
                    )


                    net.Start("FleetwayBurstEnd")
                        net.WriteEntity(ent)
                        net.WriteVector(ply:GetPos() + Vector(0,0,30))
                    net.Broadcast()

                    ent:SetNW2Bool("BurstLaserDuration2", true)

                    ent:SetNW2Float("ScanForEntities_OM", CurTime() + 5)

                    if ply:IsPlayer() then
                        --ply:SetMoveType(MOVETYPE_NONE)
                    end

                    local shouldburnself = true
                    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 650)) do
                        if ply:IsNextBot() then
                            if ply:IsPossessed() then
                                if ent2 == ply:GetPossessor() then continue end
                            end
                        end
                        if ent2:GetClass() == "gmod_hands" then continue end
                        if ent2:GetClass() == "pill_ent_costume" then continue end
                        if ent2:GetClass() == "pill_puppet" then continue end
                        if ent2:GetClass() == "predicted_viewmodel" then continue end
                        if not IsValid(ent2) then continue end
                        if ent2 == ply then continue end
                        if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end
                        if not GetConVar('PVPStun_OM_exe'):GetBool() then
                            if ent2:GetNW2Bool("OM_character_monster") then continue end
                        end
                        --if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end

                        local origin = ply:GetPos()
                        local pos = ent2:GetPos()

                        local dir = (pos - origin + Vector(0, 0, 125)):GetNormalized()
                        local dist = ent2:GetPos():Distance(ply:GetPos())
                        dist = math.Clamp(dist, 0, 650)

                        local distancemultiplyer = math.Remap(dist, 650, 0, 0.1, 1)

                        if (ent2:IsPlayer() or ent2:IsNPC() or ent2:IsNextBot()) and ent2:Health() >= 0.01 then
                            
                            ent2:SetNW2Float("OM_Damage_ReductionRemoveal", CurTime()+0.1)

                            Killerdamagestun(ply, ent2, GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_damage"):GetInt()*distancemultiplyer, DMG_BLAST, true)
                            OM_burntarget(ply, ent2, 2.5)

                            ent2:SetPos(pos + Vector(0, 0, 30))
                            ent2:SetVelocity(dir * 1250)
                            shouldburnself = false

                            local last = CurTime() + 2
                            local flung = false

                            local enemyragdoll = CreateRagdolLCharacter_OM({
                                target = ent2,
                                host = ent,

                                shouldremove = function(createfakeragdoll)
                                    if not IsValid(createfakeragdoll) then return true end
                                    if not IsValid(ent2) then return true end
                                    if not IsValid(ent) then return true end

                                    if (last < CurTime() ) then
                                        return true
                                    else
                                        
                                    end
                                    return false
                                end,

                                shoulddocustomfunction = function(createfakeragdoll)
                                    if not IsValid(createfakeragdoll) then return end
                                    if not IsValid(ent) then return end
                                    if flung then return end
                                    flung = true

                                    local ragPos = createfakeragdoll:GetPos()
                                    local entPos = ent2:GetPos()

                                    local force = dir * 1250*distancemultiplyer + Vector(0, 0, -350)

                                    local phys = createfakeragdoll:GetPhysicsObject()
                                    if IsValid(phys) then
                                        phys:SetVelocity(force)
                                        phys:AddAngleVelocity(VectorRand() * 1250*distancemultiplyer)
                                    end

                                    for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                                        local bonePhys = createfakeragdoll:GetPhysicsObjectNum(i)
                                        if IsValid(bonePhys) then
                                            bonePhys:SetVelocity(force)
                                            bonePhys:AddAngleVelocity(VectorRand() * 3125000)
                                        end
                                    end
                                end
                            })

                        else

                            local tr = util.TraceLine({
                                start = ent2:WorldSpaceCenter(),
                                endpos = ent2:WorldSpaceCenter(),
                                filter = function(hitEnt)
                                    return hitEnt == ent2
                                end
                            })

                            local killercd = ent:EntIndex().. " fleetway_laserdamagecd"
                            if not ent2[killercd] then
                                ent2[killercd] = 0
                            end

                            if GetConVar("OUTCOMEMEMORIES_N_Fleetway_DoorsDestruction"):GetBool() then
                                if tr.Entity == ent2 then
                                    if ent2:GetClass() == "prop_door_rotating" or ent2:GetClass() == "func_door_rotating" then
                                        local dprop = ents.Create("prop_physics")
                                        if not IsValid(dprop) then return end

                                        dprop:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
                                        dprop:SetMoveType(MOVETYPE_VPHYSICS)
                                        dprop:SetSolid(SOLID_BBOX)
                                        dprop:SetPos(ent2:GetPos() + Vector(0, 0, 2))
                                        dprop:SetAngles(ent2:GetAngles())
                                        dprop:SetModel(ent2:GetModel())

                                        ent2:Remove()

                                        dprop:Spawn()

                                        dprop:SetSkin(ent2:GetSkin() or 0)

                                        if ent2:GetNumBodyGroups() then
                                            for id = 0, ent2:GetNumBodyGroups() - 1 do
                                                dprop:SetBodygroup(id, ent2:GetBodygroup(id))
                                            end
                                        end

                                        for i = 0, 31 do
                                            local mat = ent2:GetSubMaterial(i)
                                            if mat and mat:len() > 0 then
                                                dprop:SetSubMaterial(i, mat)
                                            end
                                        end

                                        dprop:EmitSound("physics/wood/wood_crate_break3.wav")
                                        local effectdata = EffectData()
                                        effectdata:SetOrigin(dprop:GetPos() + dprop:OBBCenter())
                                        effectdata:SetMagnitude(5)
                                        effectdata:SetScale(2)
                                        effectdata:SetRadius(5)
                                        util.Effect("Sparks", effectdata)
                                                
                                        local phys = dprop:GetPhysicsObject()
                                        if IsValid(phys) then
                                            phys:ApplyForceOffset(ply:GetForward() * 2000, phys:GetMassCenter())
                                        end
                                    end
                                end

                                if GetConVar("OUTCOMEMEMORIES_N_Fleetway_PropsDestruction"):GetBool() then
                                    if ent2[killercd] < CurTime() then
                                        local phys = ent2:GetPhysicsObject()
                                        local dir = (ent2:GetPos() - ent:GetPos()):GetNormalized()

                                        if IsValid(phys) then

                                            local phys = ent2:GetPhysicsObject()
                                            local dir = (ent2:WorldSpaceCenter() - ent:WorldSpaceCenter()):GetNormalized()


                                            if math.random(1,2) == 1 then constraint.RemoveConstraints(ent2, "Weld") end
                                            if math.random(1,3) == 1 then constraint.RemoveConstraints(ent2, "Axis") end
                                            if math.random(1,3) == 1 then constraint.RemoveConstraints(ent2, "Ballsocket") end
                                            if math.random(1,2) == 1 then constraint.RemoveConstraints(ent2, "Rope") end
                                            if math.random(1,3) == 1 then constraint.RemoveConstraints(ent2, "Elastic") end
                                            --if math.random(1,150) == 1 then constraint.RemoveConstraints(ent2, "NoCollide") end

                                            if IsValid(phys) then
                                                phys:EnableMotion(true)
                                                phys:Wake()

                                                phys:ApplyForceCenter(dir * 7000000)
                                            end
                                            ent2:Ignite(math.random(4,8)*0.5, 100)
                                        end



                                        ent2[killercd] = CurTime() + 0.15
                                        local dmg = DamageInfo()
                                        dmg:SetDamage(GetConVar("OUTCOMEMEMORIES_N_Fleetway_Burst_damage"):GetInt()*distancemultiplyer*0.85)
                                        dmg:SetDamageType(DMG_CLUB)
                                        dmg:SetAttacker(ply)
                                        dmg:SetInflictor(ply)
                                        dmg:SetDamageForce(dir * 5000)
                                        dmg:SetDamagePosition(tr.HitPos)

                                        ent2:DispatchTraceAttack(dmg, tr, tr.Normal)
                                    end
                                end

                            end
                        end
                    end


                    timer.Simple(1.2,function()
                        if !IsValid(ent) then return end
                        ent:SetNW2Float("AttackCooldown_OM", CurTime() + 0.25)

                        if ply:IsPlayer() then
                            ply:SetMoveType(MOVETYPE_WALK)
                        else
                            ply:SetMoveType(0)
                        end
                        if shouldburnself then
                            OM_burntarget(ply, ply, 3)
                        end

                        ply:SetSolid(SOLID_BBOX) 
                        ent:SetNW2Bool("LaserDuration", false)
                        ent:SetNW2Bool("BurstLaserDuration", false)
                        ent:SetNW2Bool("BurstLaserDuration2", false)

                        ent:SetNW2Float("Blast_OM_Fleetway_Cooldown", CurTime() + ent.formTable.Outcomememories_stats.abilities.Burst.Cooldown())
                        ent:SetNW2Float("Blast_OM_Fleetway_Cooldown_duration", ent.formTable.Outcomememories_stats.abilities.Burst.Cooldown())
                        if crazyzset then
                            ent:SetNW2Float("Blast_OM_Fleetway_Cooldown", CurTime() + ent.formTable.Outcomememories_stats.abilities.Burst.CooldownStun())
                            ent:SetNW2Float("Blast_OM_Fleetway_Cooldown_duration", ent.formTable.Outcomememories_stats.abilities.Burst.CooldownStun())
                        end
                    end)
                end)
            end

            if button == ply:GetInfoNum("om_pills_action_fleetway_drain_key", KEY_T) then
                if not SERVER then return end -- EndLagFatefulDranin
                if not GetConVar("OUTCOMEMEMORIES_N_Fleetway_Fatefuldrain_useable"):GetBool() then return end
                if ent:GetNW2Bool("FatefulDrainMode") then
                else
                    if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() then return end

                    if ent:GetNW2Bool("NoAbilityUse_fleetway") then return end
                    if ent:GetNW2Bool("LaserDuration") then return end
                    if ent:GetNW2Float("CaosDash_duration", 0) > CurTime() then return end
                    if ent:GetNW2Bool("drawfleetwaylaser") then return end
                    if ent:GetNW2Bool("FatefulDrainMode") or (ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing")) then return end

                    if ent:GetNW2Float("fatefuldrain_OM_Fleetway_Cooldown") > CurTime() then return end
                    if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                    
                    if ent.flyingent and IsValid(ent.flyingent) then
                        OM_base_FlyingEnd(ply, ent)
                    end
                    
                    ent:SetNW2Bool("FatefulDrainMode_endlag_bool", false)
                    ent:SetNW2Bool("FatefulDrainMode", true)
                    ent:SetNW2Bool("FatefulDrainMode_moving", false)

                    ent:SetNW2Bool("Absorbing", false)
                    ent:SetNW2Float("fateful_drain_drainenemyAmountHit", 0)

                    ent:SetNW2Bool("FatefulDrainMode_moving_RELOAD", false)
                end
            end

            if button == ply:GetInfoNum("om_pills_action_fleetway_laser_key", KEY_R) then
                if not SERVER then return end
                if not GetConVar("OUTCOMEMORIES_N_fleetway_LaserOfDestruction_useable"):GetBool() then return end

                if ent:GetNW2Bool("IsInLaserOfDestruction") then

                else
                    if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() then return end
                    if ent:GetNW2Bool("NoAbilityUse_fleetway") then return end
                    if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                    if ent:GetNW2Bool("LaserDuration") then return end
                    if ent:GetNW2Float("CaosDash_duration", 0) > CurTime() then return end
                    if ent:GetNW2Bool("drawfleetwaylaser") then return end
                    if ent:GetNW2Bool("FatefulDrainMode") or (ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing")) then return end
                    if ent:GetNW2Float("laserofchaos_OM_Fleetway_Cooldown") > CurTime() then return end

                    if ent.flyingent and IsValid(ent.flyingent) then
                        ent.flyingent:Remove()
                    end

                    ply:SetLocalVelocity(Vector(0,0,0))
                    ply:SetVelocity(Vector(0,0,0))
                    ent:SetNW2Float("FleetwaylaserDash_id", ent:GetNW2Float("FleetwaylaserDash_id")+1)

                    ent:GetPuppet():SetNW2Float("Fleetway_body_glowwhite_burst_2", CurTime()+0.2)

                    if ply:IsPlayer() then 
                        ply:SetMoveType(0)
                    else
                        ply:SetNW2Vector("OldPosition_laser_e", ply:GetPos())
                    end
                    --laserofdestructionchargeidle
                    ent:SetNW2Bool("NoAbilityUse_fleetway", true)
                    ent:SetNW2Bool("IsInLaserOfDestruction", true)
                    ply:SetNW2Float("OM_NoMovement_noodles", CurTime() + 5)

                    AdvancedPillSound(
                        {
                            stringe = "OM/Fleetway/ShadowDio.wav",
                            pitchPercent = 100,
                            volume = 0.5,
                            soundLevel = 60
                        },
                        ent
                    )

                    AdvancedPillSound(
                        {
                            stringe = "om/fleetway/LaserChargeSound_2.wav",
                            pitchPercent = 100,
                            volume = 3,
                            soundLevel = 60
                        },
                        ent
                    )

                    AdvancedPillSound(
                        {
                            stringe = "om/fleetway/LaserChargeSound_2.wav",
                            pitchPercent = 100,
                            volume = 3,
                            soundLevel = 60
                        },
                        ent
                    )


                            --[[
                            AdvancedPillSound(
                                {
                                    stringe = {"OM/joke/IsntItAGood-1.ogg","OM/joke/IsntItAGood-2.ogg"},
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                            ]]

                    ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+2) 
                    timer.Simple(0.65,function()
                        if !IsValid(ent) then return end
                        if not ent:GetNW2Bool("IsInLaserOfDestruction") then return end
                        

                        timer.Simple(0.2,function()
                            if !IsValid(ent) then return end
                            if not ent:GetNW2Bool("IsInLaserOfDestruction") then return end
                            
                            local effectdata = EffectData()
                            effectdata:SetOrigin(ply:GetPos()+ply:GetAngles():Up()*40)
                            util.Effect("Fleetway_laserintro", effectdata)
                            
                            AdvancedPillSound(
                                {
                                    stringe = {
                                        "OM/Fleetway/fleet laser 1.wav",
                                        "OM/Fleetway/fleet laser 2.wav",
                                        "OM/Fleetway/fleet laser 3.wav",
                                    },
                                    pitchPercent = 100,
                                    volume = 0.8,
                                    soundLevel = 100
                                },
                                ent
                            )
                        end)
                    end)
                    timer.Simple(2, function()
                        if !IsValid(ent) then return end
                        local duration = GetConVar("OUTCOMEMEMORIES_N_Fleetway_LaserOfDestruction_Duration"):GetFloat()
                        ent:SetNW2Float("OM_LaserDuration", CurTime() + duration)
                        ent:SetNW2Float("OM_LaserDuration_last", CurTime() + 2)
                        ent:SetNW2Float("LaserLastingDuration", CurTime() + duration)
                        ent:SetNW2Float("LaserLastingDuration_amount", duration)
                    end)
                end
            end

            if button == ply:GetInfoNum("om_pills_action_fleetway_caosdash_key", KEY_E) then
                if not SERVER then return end
                if not GetConVar("OUTCOMEMORIES_N_fleetway_CaosDash_useable"):GetBool() then return end

                if ent._OldCollisionBounds then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() then return end
                if ent:GetNW2Bool("NoAbilityUse_fleetway") then return end
                if ent:GetNW2Bool("LaserDuration") then return end
                if ent:GetNW2Float("CaosDash_duration", 0) > CurTime() then return end
                if ent:GetNW2Bool("drawfleetwaylaser") then return end
                if ent:GetNW2Bool("FatefulDrainMode") or (ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing")) then return end

                if ent:GetNW2Float("dash_OM_Fleetway_Cooldown") > CurTime() then return end
                if ent:GetNW2Float("dash_OM_Fleetway_Cooldown2") > CurTime() then return end

                if ent.flyingent and IsValid(ent.flyingent) then
                    ent.flyingent:Remove()
                end

                ent:SetNW2Float("CaosDash_duration", CurTime() + ent.formTable.Outcomememories_stats.abilities.CaosDash.Duration())
                ent:SetNW2Float("ScanForEntities_OM", CurTime() + 5)
                ent:SetNW2Float('HitsBeforeEnd_dash', 0)
                ent:SetNW2Float("CurrentSpeed_dashnigSuppressed",GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Speed"):GetInt())
                ent:SetNW2Float("CurrentSpeed_dashnig",GetConVar("OUTCOMEMEMORIES_N_Fleetway_CaosDash_Speed"):GetInt())
               

                --ent:GetPuppet():SetNW2Float('sonic_glow_duration_white',CurTime()+0.25)


                ent:SetNW2Float('IgnoreBall_OM_moduledraw',CurTime()+0.2)
                ent:GetPuppet():SetNW2Float('IgnoreBall_OM_moduledraw',CurTime()+0.2)
                ent:GetPuppet():SetNW2Float("Fleetway_body_glowwhite_burst_2", CurTime()+0.2)

                AdvancedPillSound(
                    {
                        stringe = "OM/Fleetway/elevatorchaosdash.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 60
                    },
                    ent
                ) 
                AdvancedPillSound(
                    {
                        stringe = "OM/sonic/peelout.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 60
                    },
                    ent
                )
                
                AdvancedPillSound(
                    {
                        stringe = {"OM/Fleetway/chaosdash_1.wav","OM/Fleetway/chaosdash_2.wav"},
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                
                --[[
                AdvancedPillSound(
                    {
                        stringe = {"OM/joke/OhThisIsGoing-2.ogg","OM/joke/PlaytimeOver.ogg"},
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                ]]
                
                local rolling
                if ent:GetNW2Float("RollEndTime_om", 0 ) > CurTime() then
                    rolling = true
                end


                ent:SetNW2Float("FleetwaySpiNDash_id", ent:GetNW2Float("FleetwaySpiNDash_id")+1)

                ent:SetNW2Float("CaosDash_chargeup_duration", CurTime() + 0.65+1.35)

                if SERVER then

                    local uniqueID = "OM_Sonicsetback_" .. ent:EntIndex()
                    local oldcolor = ent:GetPuppet():GetColor()

                    local startTime = CurTime()
                    local fadeDuration = 1

                    local oldposition = ply:GetPos()
                    ply:SetNW2Float("DisablePlayerMovement_OM_stun_iframe2", CurTime()+3) 
                    if not rolling then
                        if ply:IsPlayer() then
                            ply:SetMoveType(MOVETYPE_NONE)
                        else
                            ply:SetMoveType(MOVETYPE_WALK)
                        end
                    end

                    if not rolling then
                        local directionsetback = ent:GetPuppet():GetAngles()

                        hook.Add("Think", uniqueID, function()
                            if not IsValid(ent) then
                                hook.Remove("Think", uniqueID)
                                return
                            end

                            local elapsed = CurTime() - startTime
                            local fadeFrac = math.Clamp(elapsed / fadeDuration, 0, 1)
                            local invert = Lerp(fadeFrac, 1, 0)
                            if invert <= 0 then 
                                hook.Remove("Think", uniqueID)
                                return
                            end

                            local startPos = ply:GetPos()
                            local endPos = startPos + directionsetback:Forward()*-70

                            local tr = util.TraceLine({
                                start = startPos,
                                endpos = endPos,
                                filter = ply,
                                mask = MASK_SHOT
                            })
                            if not tr.Hit then
                                ply:SetPos(ply:GetPos() + directionsetback:Forward()*-10*invert)
                            end
                        end)
                    end

                    timer.Simple(0.65,function()
                        if !IsValid(ent) then return end

                        ent:GetPuppet():SetNW2Float('fleetway_fatefuldrain_red',CurTime()+0.5*0.35)
                        ent:GetPuppet():SetNW2Float('knuckles_block_outline',CurTime()+0.5*0.35)

                        local ballsonic = ents.Create("ent_om_hedgehog_dropballs")
                        ballsonic:SetPos(ply:GetPos())
                        ballsonic:SetAngles(ply:GetAngles())
                        ballsonic:SetModelScale(1.25)
                        ballsonic:Spawn()
                        ballsonic:SetPillUser(ply)
                        ballsonic:SetPillUser2(ent:GetPuppet())
                        ent:DeleteOnRemove(ballsonic)
                        ballsonic:SetColor(Color(0, 0, 0, 0))
                        ballsonic:SetRenderMode(RENDERMODE_TRANSALPHA)
                        ent:SetNW2Entity("GlowingBallThingy_OM",ballsonic)
                        ent:GetPuppet():SetNW2Entity("GlowingBallThingy_OM",ballsonic)
                        ballsonic:SetMaterial("models/noodles/om/Sonicball/Fleetwayball")
                        ballsonic:SetNWBool("Fleetway_om_outline", true)

                        local uniqueID = "OM_SonicModelBall_" .. ballsonic:EntIndex()
                        local oldcolor = ent:GetPuppet():GetColor()

                        local startTime = CurTime()
                        local fadeDuration = 0.75

                        hook.Add("Think", uniqueID, function()
                            if not IsValid(ballsonic) then
                                hook.Remove("Think", uniqueID)
                                return
                            end

                            if ent:GetNW2Float('CaosDash_duration') < CurTime() then
                                hook.Remove("Think", uniqueID)
                                ballsonic:Remove()
                                ent:GetPuppet():SetColor(oldcolor)
                                return
                            end

                            local elapsed = CurTime() - startTime

                            local fadeFrac = math.Clamp(elapsed / fadeDuration, 0, 1)

                            local puppetAlpha = 255 * (1 - fadeFrac)

                            local ballAlpha = 255 * fadeFrac

                            ent:GetPuppet():SetRenderMode(RENDERMODE_TRANSALPHA)
                            ent:GetPuppet():SetColor(Color(255, 255, 255, puppetAlpha))

                            ballsonic:SetRenderMode(RENDERMODE_TRANSALPHA)
                            ballsonic:SetColor(Color(255, 255, 255, ballAlpha))

                            local mult
                            if elapsed >= 0.7 then
                                mult = 3
                            else
                                mult = 1 + (elapsed / 0.7) * 2
                            end

                            local ang = Angle(0, 0, CurTime() * 360 * mult)
                            ballsonic:ManipulateBoneAngles(0, ang)

                            if not ent.trailPeel then

                                local trail = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255, 255, 255),
                                    true,
                                    45,
                                    1,
                                    0.75,
                                    0.1,
                                    "models/noodles/om/sonicball/red.vmt"
                                )

                                ent.trailPeel = trail
                                ent:DeleteOnRemove(trail)
                                trail:DeleteOnRemove(ballsonic)

                                local trail_2ndlayer = util.SpriteTrail(
                                    ballsonic,
                                    0,
                                    Color(255, 255, 255),
                                    true,
                                    105,
                                    70,
                                    1,
                                    0.01,
                                    "models/noodles/om/sonicball/red_2ndlayer.vmt"
                                )

                                ent.trail_2ndlayer = trail_2ndlayer
                                ent:DeleteOnRemove(trail_2ndlayer)
                                ballsonic:DeleteOnRemove(trail_2ndlayer)
                                trail_2ndlayer:DeleteOnRemove(ballsonic)
                            end
                        end)

                        timer.Simple(1.35,function()
                            if !IsValid(ballsonic) then return end
                            ballsonic:SetNW2Float('sonic_glow_duration',CurTime()+0.35)
                            ballsonic:SetNW2Float('knuckles_block_outline',CurTime()+0.35)
                        end)


                        local oldposition = ply:GetPos()
                        timer.Simple(1.35,function()

                            if !IsValid(ent) then return end
                            if ply:GetNW2Bool("clashingminigame_om_isinminigame") then return end
                            if ply:GetNW2Float("DisablePlayerMovement_OM_stun", 0) > CurTime() then return end
                            if not rolling then
                                if IsValid(ply) then 
                                    if ply:IsPlayer() then
                                        ply:SetMoveType(MOVETYPE_WALK)
                                        ply:SetSolid(SOLID_BBOX) 
                                    else
                                        ply:SetPos(oldposition)
                                        ply:SetMoveType(MOVETYPE_NONE)
                                        timer.Simple(0.002,function()
                                            if !IsValid(ent) then return end
                                            ply:SetPos(oldposition)
                                        end)
                                    end
                                end
                            end
                            
                            AdvancedPillSound(
                                {
                                    stringe = "OM/Fleetway/S3K_4E (3).wav",
                                    pitchPercent = 100,
                                    volume = 1,
                                    soundLevel = 87
                                },
                                ent
                            )
                            if not ent._OldCollisionBounds then
                                local mins, maxs = ply:GetCollisionBounds()
                                ent._OldCollisionBounds = { mins, maxs }
                            end


                        end)
                    end)
                end
            end

            if button == KEY_SPACE then
                if not SERVER then return end
                if not GetConVar('OUTCOMEMORIES_N_Fleetway_flying'):GetBool() then return end
                if ent:GetNW2Float("OM_Fleetway_flyingBar_cd", 0) > CurTime() then return end
                if ent:GetNW2Float("OM_Fleetway_flyingBar_cd_return", 0) > CurTime() then return end
                if ent:GetNW2Float("OM_cannotuseabailities") > CurTime() then return end
                if ent:GetNW2Bool("NoAbilityUse_fleetway") then return end
                if ent:GetNW2Bool("LaserDuration") then return end
                if ent:GetNW2Bool("BurstLaserDuration") then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end
                if ent:GetNW2Float("CaosDash_duration", 0) > CurTime() then return end
                if ent:GetNW2Bool("drawfleetwaylaser") then return end
                if ent:GetNW2Bool("FatefulDrainMode") or (ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing")) then return end


                if ply:IsPlayer() then
                    if ent.flyingent and IsValid(ent.flyingent) then
                    else
                        if ply:IsOnGround() then return end
                    end
                else
                    if ply.IsPossessed and ply:IsPossessed() then
                        if ply:IsOnGround() then return end
                    end
                end
                
                ent:SetNW2Float("OM_Fleetway_flyingBar_cd_return", CurTime()+0.4)
                
                if ent.flyingent and IsValid(ent.flyingent) then
                    OM_base_FlyingEnd(ply, ent)
                    return
                end

                local flyingent = ents.Create("prop_physics")

                if !IsValid(flyingent) then return end
                ent:SetNW2Vector("CurrentVelocity_fly", Vector(0,0,0))

                ent.OM_ChargeDir = ply:GetPos()
                ply:SetVelocity(Vector(0,0,0))
                ply:SetLocalVelocity(Vector(0,0,0))

                flyingent:SetModel("models/hunter/blocks/cube1x1x1.mdl")
                flyingent:SetPos(ply:GetPos())
                flyingent:SetAngles(ply:GetAngles())
                flyingent:Spawn()
                flyingent:Activate()
                flyingent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

                flyingent:PhysicsInit(0)
                flyingent:SetMoveType(0)
                flyingent:SetSolid(0)

                ent:DeleteOnRemove(flyingent)
                
                ply:SetMoveType(MOVETYPE_NONE)

                ent.flyingent = flyingent
                ent:SetNW2Entity("flyingent",flyingent)

                flyingent:SetRenderMode(RENDERMODE_TRANSALPHA)
                flyingent:SetColor(Color(0,0,0,0))
                flyingent:DrawShadow(false)

                ent:SetNW2Bool('StillInAir_Flying', true)


                AdvancedPillSound(
                    {
                        stringe = "OM/Flystarting.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

            end
        end
    end,

    
    attack = {
        mode = 'trigger',
        func = function(ply, ent)
            if SERVER then
                if ent:GetNW2Float("OM_executionanim") > CurTime() then return end
                if ply:GetNW2Float("DisablePlayerMovement_OM_stun") >= CurTime() then return end
                if ent:GetNW2Float("CaosDash_duration", 0) > CurTime() then return end
                if ent:GetNW2Bool("drawfleetwaylaser") then return end
                if ent:GetNW2Bool("FatefulDrainMode") or (ent:GetNW2Entity("FatefulDrain_absorbenemy") and ent:GetNW2Bool("Absorbing")) then return end
                if ent:GetNW2Float("AttackCooldown_OM", 0 ) > CurTime() then return end
                if ent:GetNW2Bool("LaserDuration") then return end
                if ent:GetNW2Bool("IsInLaserOfDestruction") then return end

                local puppet = ent:GetPuppet()
                if not IsValid(puppet) then return end
                
                AdvancedPillSound(
                    {
                        stringe = "OM/fleetway/Fleetway m1 swing.wav",
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )
                
                AdvancedPillSound(
                    {
                        stringe = {
                            "OM/Fleetway/Fleetm1_1.wav",
                            "OM/Fleetway/Fleetm1_2.wav",
                            "OM/Fleetway/Fleetm1_3.wav",
                        },
                        pitchPercent = 100,
                        volume = 1,
                        soundLevel = 87
                    },
                    ent
                )

                ent:SetNW2Float("AttackCooldown_OM", CurTime() + 1.15)
                if ent.flyingent and IsValid(ent.flyingent) then
                    if ent:GetNW2Float("OM_Fleetway_flyingBar") > 0 then 
                        ent:SetNW2Float("OM_Fleetway_flyingBar",ent:GetNW2Float("OM_Fleetway_flyingBar")-15)
                    end
                end
                
                --[[
                local seqID = puppet:LookupSequence("swing")
                if seqID == -1 then return end

                local layeredAnim = puppet:AddLayeredSequence(seqID, 10)
                if layeredAnim == -1 then return end

                puppet:SetLayerPriority(layeredAnim, 10)
                puppet:SetLayerCycle(layeredAnim, 0)
                puppet:SetLayerWeight(layeredAnim, 1)
                puppet:SetLayerBlendIn(layeredAnim, 0.1)
                puppet:SetLayerBlendOut(layeredAnim, 0.85)

                local playbackRate = 1
                if IsValid(ply) and ply:IsPlayer() then
                    playbackRate = 0.5
                end
                puppet:SetLayerPlaybackRate(layeredAnim, playbackRate)

                timer.Simple(0.9, function()
                    if not IsValid(puppet) then return end
                    puppet:RemoveLayer(layeredAnim)
                end)
                ]]

                local puppet = ent:GetPuppet()
                local layeredAnim = puppet:AddGesture(ACT_MELEE_ATTACK_SWING_GESTURE, false)

                local current = 1
                puppet:SetLayerWeight(layeredAnim, current)
                puppet:SetLayerPriority(layeredAnim, 10)

                local playbackRate = 1
                puppet:SetLayerPlaybackRate(layeredAnim, playbackRate)

                local function fadeLayer()
                    if not IsValid(puppet) then return end
                    current = current - 0.04
                    puppet:SetLayerWeight(layeredAnim, math.max(current, 0))

                    if current > 0 then
                        timer.Simple(0.0005, fadeLayer)
                    end
                end

                timer.Simple(0.15, fadeLayer)

                timer.Simple(0.9,function()
                    if !IsValid(ent) then return end
                    puppet:RemoveLayer(puppet:FindGestureLayer(ACT_MELEE_ATTACK_SWING_GESTURE))
                end)


            end
        end
    },


    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
        end,
    },

    reload=function(ply,ent)
    end,
    flashlight = function(ply, ent)
    end,
        
    jump = function(ply, ent)
        if ent:GetNW2Float("CaosDash_duration", 0 ) > CurTime() then return end

        if SERVER then
            ent:PillAnim('jump2')
        end

        AdvancedPillSound(
            {
                stringe = "OM/Jump.wav",
                pitchPercent = 100,
                volume = 1,
                soundLevel = 87
            },
            ent
        )

    end
})