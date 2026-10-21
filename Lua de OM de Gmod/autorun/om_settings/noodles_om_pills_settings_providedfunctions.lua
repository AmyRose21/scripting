AddCSLuaFile()

local OM_menusettings = {
    ["Killer"] = {
        ["Server"] = {},
        ["Client"] = {}
    },
    ["Survivor"] = {
        ["Server"] = {},
        ["Client"] = {}
    },
    ["Gameplay"] = {
        ["Server"] = {},
        ["Client"] = {}
    }
}

function Register_OMSettings(TableRegisteringInfo)
    local info = {}
    if TableRegisteringInfo.TableType ~= nil then info.TableType = TableRegisteringInfo.TableType else info.TableType = false end 
    if TableRegisteringInfo.ServerOrClient ~= nil then info.ServerOrClient = TableRegisteringInfo.ServerOrClient else info.ServerOrClient = false end 
    if TableRegisteringInfo.Command ~= nil then info.Command = TableRegisteringInfo.Command else return end 
    if TableRegisteringInfo.Name ~= nil then info.Name = TableRegisteringInfo.Name else TableRegisteringInfo.Name = "NULL" end 
    if TableRegisteringInfo.Color ~= nil then info.Color = TableRegisteringInfo.Color else TableRegisteringInfo.Color = Color(255,0,0,255) end 
    if TableRegisteringInfo.Image ~= nil then info.Image = TableRegisteringInfo.Image else info.Image = "icon16/star.png" end --

    local tabletoregisterto = OM_menusettings[info.TableType]
    if info.ServerOrClient == true then 
        tabletoregisterto = tabletoregisterto["Server"]
    else
        tabletoregisterto = tabletoregisterto["Client"]
    end

    table.insert(tabletoregisterto, {
        Name = info.Name,
        Command = info.Command,
        Color = info.Color,
        Image = info.Image
    })
end

function return_OMSETTINGS(Type)
    return OM_menusettings
end

if CLIENT then
    -- AddResetButton OM_RegisterResetButton_client
    -- AddResetButtonServer OM_RegisterResetButton_server
    -- AddKeyRow om_RegisterKeyrow
    -- Bordere OM_RegisterBorder

    local preservedmats = {
        ["OM_icon_survivor"] = "icons/Polygon_of_doom.png",
        ["OM_icon_monster"] = "icons/Polygon_of_DEVI.png",
    }

    local OM_Pills_Frame

    
    function OM_RegisterSettingsPanel(RegisterTable)
        local SettingsTable = {}

        if RegisterTable.Size == nil then 
            SettingsTable.SizeX = 700
            SettingsTable.SizeY = 1000
        else
            SettingsTable.SizeX = RegisterTable.Size.x
            SettingsTable.SizeY = RegisterTable.Size.y
        end

        if RegisterTable.Title == nil then 
            SettingsTable.Title = "Outcome Memories Pillpack"
        else
            SettingsTable.Title = RegisterTable.Title
        end

        if RegisterTable.Image == nil then 
            SettingsTable.Image = "pills/pill_om_sonic.png"
        else
            SettingsTable.Image = RegisterTable.Image
        end

        if IsValid(OM_Pills_Frame) then OM_Pills_Frame:Remove() end

        OM_Pills_Frame = vgui.Create("DFrame")
        OM_Pills_Frame:SetSize(SettingsTable.SizeX, SettingsTable.SizeY)
        OM_Pills_Frame:Center()
        OM_Pills_Frame:SetTitle(SettingsTable.Title)
        OM_Pills_Frame:MakePopup()

        local topImage = vgui.Create("DImage", OM_Pills_Frame)
        topImage:Dock(TOP)
        topImage:SetTall(150)
        topImage:SetImage(SettingsTable.Image)
        topImage:SetKeepAspect(true)

        local scroll = vgui.Create("DScrollPanel", OM_Pills_Frame)
        scroll:Dock(FILL)

        return {
            ["OM_Pills_Frame"] = OM_Pills_Frame,
            ["topImage"] = topImage,
            ["scroll"] = scroll
        }
    end

    function OM_RegisterResetButton_client(parent, KeyDefaults, KeyDefaults2)
        local btn = vgui.Create("DButton", parent)
        btn:Dock(TOP)
        btn:SetTall(40)
        btn:DockMargin(8, 8, 8, 8)
        btn:SetText("Reset Keybinds")

        btn.DoClick = function()
            for convar, key in pairs(KeyDefaults2[KeyDefaults]) do
                RunConsoleCommand(convar, key)
            end
            chat.AddText(Color(0, 200, 0), "[OM Pills] All ".. KeyDefaults .. "'s keybinds have been reset!")
        end
    end

    function OM_RegisterResetButton_server(parent, KeyDefaults, command)
        local btn = vgui.Create("DButton", parent)
        btn:Dock(TOP)
        btn:SetTall(40)
        btn:DockMargin(8, 8, 8, 8)
        btn:SetText("Reset Settings")

        btn.DoClick = function()
            RunConsoleCommand(command)
            chat.AddText(Color(0, 200, 0), "[OM Pills] All ".. KeyDefaults .. "'s settings reset!")
        end
    end

    function om_RegisterKeyrow(infotable)
        local parent = infotable.parent
        local icon = infotable.icon
        local labelText = infotable.labelText
        local convar = infotable.convar
        local color = infotable.color
        local isexe = infotable.isexe
        local bioText = infotable.bioText
        local vartype = infotable.vartype
        local slidertable = infotable.slidertable
        local serversided = false
        local presettable = infotable.presettable
  
        local row = vgui.Create("DPanel", parent)
        row:Dock(TOP)
        row:SetTall(bioText and 120 or 100)
        row:DockMargin(8, 8, 8, 0)

        row.Paint = function(self, w, h)
            surface.SetDrawColor(color)
            surface.DrawRect(0, 0, w, h)
        end

        local imgPanel = vgui.Create("DPanel", row)
        imgPanel:Dock(LEFT)
        imgPanel:SetWide(140)
        imgPanel.Paint = function() end

        local baseImg = vgui.Create("DImage", imgPanel)
        baseImg:Dock(FILL)
        baseImg:SetImage(isexe and preservedmats["OM_icon_monster"] or preservedmats["OM_icon_survivor"])
        baseImg:SetKeepAspect(false)

        local img = vgui.Create("DImage", imgPanel)
        img:Dock(FILL)
        img:SetImage(icon)
        img:SetKeepAspect(false)

        local binderPanel = vgui.Create("DPanel", row)
        binderPanel:Dock(RIGHT)
        binderPanel:SetWide(120)
        binderPanel.Paint = function() end

        local binder
        if vartype == "bind" then
            binder = vgui.Create("DBinder", binderPanel)
            binder:Dock(FILL)
            binder:SetConVar(convar)
        elseif vartype == "bool" then
            binder = vgui.Create("DCheckBox", binderPanel)
            binder:Dock(FILL)
            binder:SetConVar(convar)
        elseif vartype == "slider" then
            binderPanel:SetWide(120 * 3)

            local sliderContainer = vgui.Create("DPanel", binderPanel)
            sliderContainer:Dock(TOP)
            sliderContainer:SetTall(40)
            sliderContainer.Paint = function() end

            local minusBtn = vgui.Create("DButton", sliderContainer)
            minusBtn:Dock(LEFT)
            minusBtn:SetWide(30)
            minusBtn:SetText("-")

            local plusBtn = vgui.Create("DButton", sliderContainer)
            plusBtn:Dock(RIGHT)
            plusBtn:SetWide(30)
            plusBtn:SetText("+")

            binder = vgui.Create("DNumSlider", sliderContainer)
            binder:Dock(FILL)

            binder:SetText(slidertable.label)
            binder:SetMin(slidertable.min * 0.5)
            binder:SetMax(slidertable.max * 2)
            binder:SetDecimals(slidertable.dec)
            binder:SetValue(slidertable.default)
            binder:SetConVar(convar)

            local step = 1
            local startDelay = 0.5
            local minInterval = 0.01
            local accel = 0.92

            local stepAccel = 1.08
            local maxStepMult = 25

            local function SetupHold(button, direction)

                local holding = false
                local nextChange = 0
                local interval = 0.15
                local currentStep = step

                local function ChangeValue()
                    local newVal = math.Clamp(
                        binder:GetValue() + (currentStep * direction),
                        0,
                        1e9
                    )

                    binder:SetValue(newVal)
                    RunConsoleCommand(convar, tostring(newVal))
                end

                button.OnMousePressed = function()
                    holding = true
                    interval = 0.15
                    currentStep = step

                    ChangeValue()
                    nextChange = CurTime() + startDelay
                end

                button.OnMouseReleased = function()
                    holding = false
                end

                button.Think = function()
                    if not holding then return end
                    if CurTime() < nextChange then return end

                    ChangeValue()

                    interval = math.max(interval * accel, minInterval)
                    currentStep = math.min(currentStep * stepAccel, step * maxStepMult)

                    nextChange = CurTime() + interval
                end
            end

            SetupHold(minusBtn, -1)
            SetupHold(plusBtn, 1)
        elseif vartype == "preset" then
            local presetName = presettable.name
            local listofdefualtconvars = presettable.listofdefualtconvars

            binderPanel:SetWide(120 * 2)

            local combo = vgui.Create("DComboBox", binderPanel)
            combo:Dock(TOP)
            combo:SetTall(30)
            combo:SetValue("Default")

            local saveButton = vgui.Create("DButton", binderPanel)
            saveButton:Dock(TOP)
            saveButton:SetTall(25)
            saveButton:SetText("Save Current")

            local editButton = vgui.Create("DButton", binderPanel)
            editButton:Dock(TOP)
            editButton:SetTall(25)
            editButton:SetText("Edit Presets")

            local PRESET_FOLDER = "OM_LNZ"
            local PRESET_FILE = PRESET_FOLDER .. "/preset_" .. presetName .. ".json"

            local function EnsureFolder()
                if not file.Exists(PRESET_FOLDER, "DATA") then
                    file.CreateDir(PRESET_FOLDER)
                end
            end

            local function LoadPresets()
                EnsureFolder()
                if not file.Exists(PRESET_FILE, "DATA") then return {} end
                return util.JSONToTable(file.Read(PRESET_FILE, "DATA")) or {}
            end

            local function SavePresets(tbl)
                EnsureFolder()
                file.Write(PRESET_FILE, util.TableToJSON(tbl, true))
            end

            local function RefreshDropdown()
                combo:Clear()
                combo:AddChoice("Default")
                local loaded = LoadPresets()
                for k, _ in pairs(loaded) do
                    combo:AddChoice(k)
                end
            end

            local defaultValues = {}
            for _, cvar in ipairs(listofdefualtconvars) do
                local cv = GetConVar(cvar)
                if cv then
                    defaultValues[cvar] = cv:GetDefault()
                end
            end

            RefreshDropdown()

            function combo:OnSelect(index, value)

                if value == "Default" then
                    for cvarName, val in pairs(defaultValues) do
                        RunConsoleCommand(cvarName, tostring(val))
                    end
                    return
                end

                local presets = LoadPresets()
                local preset = presets[value]
                if not preset then return end

                for convarName, val in pairs(preset) do
                    RunConsoleCommand(convarName, tostring(val))
                end
            end

            saveButton.DoClick = function()

                Derma_StringRequest(
                    "Save Preset",
                    "Preset name:",
                    "",
                    function(text)

                        if not text or text == "" then return end

                        local presets = LoadPresets()
                        presets[text] = {}

                        for _, cvar in ipairs(listofdefualtconvars) do
                            local cv = GetConVar(cvar)
                            if cv then
                                presets[text][cvar] = cv:GetString()
                            end
                        end

                        SavePresets(presets)
                        RefreshDropdown()
                        combo:SetValue(text)

                    end
                )
            end

            local function OpenPresetEditor()

                local presets = LoadPresets()

                local frame = vgui.Create("DFrame")
                frame:SetSize(550, 420)
                frame:Center()
                frame:SetTitle("Preset Editor - " .. presetName)
                frame:MakePopup()

                local list = vgui.Create("DListView", frame)
                list:Dock(LEFT)
                list:SetWide(160)
                list:AddColumn("Presets")

                for k, _ in pairs(presets) do
                    list:AddLine(k)
                end

                local right = vgui.Create("DScrollPanel", frame)
                right:Dock(FILL)

                local selected = nil

                list.OnRowSelected = function(_, _, row)

                    right:Clear()
                    selected = row:GetColumnText(1)

                    local data = presets[selected]
                    if not data then return end

                    for convarName, value in pairs(data) do

                        local rowPanel = right:Add("DPanel")
                        rowPanel:Dock(TOP)
                        rowPanel:SetTall(30)
                        rowPanel:DockMargin(4,4,4,4)

                        local label = vgui.Create("DLabel", rowPanel)
                        label:Dock(LEFT)
                        label:SetWide(250)
                        label:SetText(convarName)

                        local entry = vgui.Create("DTextEntry", rowPanel)
                        entry:Dock(FILL)
                        entry:SetValue(value)

                        entry.OnChange = function(self)
                            presets[selected][convarName] = self:GetValue()
                        end
                    end
                end

                local bottom = vgui.Create("DPanel", frame)
                bottom:Dock(BOTTOM)
                bottom:SetTall(35)

                local saveBtn = vgui.Create("DButton", bottom)
                saveBtn:Dock(LEFT)
                saveBtn:SetWide(100)
                saveBtn:SetText("Save")

                saveBtn.DoClick = function()
                    SavePresets(presets)
                    RefreshDropdown()
                end

                local deleteBtn = vgui.Create("DButton", bottom)
                deleteBtn:Dock(RIGHT)
                deleteBtn:SetWide(100)
                deleteBtn:SetText("Delete")

                deleteBtn.DoClick = function()
                    if not selected then return end
                    presets[selected] = nil
                    SavePresets(presets)
                    frame:Close()
                    RefreshDropdown()
                end

                local renameBtn = vgui.Create("DButton", bottom)
                renameBtn:Dock(FILL)
                renameBtn:SetText("Rename")

                renameBtn.DoClick = function()
                    if not selected then return end

                    Derma_StringRequest(
                        "Rename Preset",
                        "New name:",
                        selected,
                        function(newName)

                            if not newName or newName == "" then return end
                            if presets[newName] then return end

                            presets[newName] = presets[selected]
                            presets[selected] = nil

                            SavePresets(presets)
                            frame:Close()
                            RefreshDropdown()
                        end
                    )
                end
            end

            editButton.DoClick = function()
                OpenPresetEditor()
            end

            binder = combo
        end

        local textPanel = vgui.Create("DPanel", row)
        textPanel:Dock(FILL)
        textPanel:DockMargin(8, 0, 8, 0)
        textPanel.Paint = function() end

        local label = vgui.Create("DLabel", textPanel)
        label:SetText(labelText)
        label:SetFont("DermaDefaultBold")
        label:Dock(TOP)
        label:SetTall(24)
        label:SetContentAlignment(4)

        if bioText then
            local bioLabel = vgui.Create("DLabel", textPanel)
            bioLabel:SetText(bioText)
            bioLabel:SetFont("DermaDefaultBold")
            bioLabel:Dock(TOP)
            bioLabel:SetTall(24)
            bioLabel:SetContentAlignment(4)
        end
    end

    function OM_RegisterBorder(infotable)
        local parent = infotable.parent
        local color = infotable.color

        local row = vgui.Create("DPanel", parent)
        row:Dock(TOP)
        row:SetTall(40)
        row:DockMargin(8, 8, 8, 0)
    end
end