if !pcall(require,"pk_pills") then
    if SERVER then
        hook.Add("PlayerInitialSpawn","pk_pill_extfail_cl",function(ply)
            if game.SinglePlayer() || ply:IsListenServerHost() then
                ply:SendLua('notification.AddLegacy("One or more pill extensions failed to load. Did you forget to install Parakeet\'s Pill Pack?",NOTIFY_ERROR,30)')
            end
        end)
        hook.Add("Initialize","pk_pill_extfail_sv",function(ply)
            print("[ALERT] One or more pill extensions failed to load. Did you forget to install Enhanced Parakeet's Pill Base?")
        end)
    end
    return
end

if SERVER then
else

local function OpenTestPopup()
    if IsValid(OM_TestPopup) then
        OM_TestPopup:Remove()
    end

    local frame = vgui.Create("DFrame")
    OM_TestPopup = frame

    frame:Center()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame:DockPadding(20, 70, 20, 20)

    frame:SetSize(550, 700)
    frame:Center()

    local x, y = frame:GetPos()

    frame:SizeTo(850, 900, 0.25, 0, -1)
    frame:MoveTo(
        ScrW() / 2 - 850 / 2,
        ScrH() / 2 - 900 / 2,
        0.25,
        0,
        -1
    )

frame.Paint = function(self, w, h)
    local t = RealTime()

    draw.RoundedBox(12, 0, 0, w, h, Color(15, 18, 26, 255))

    local pulse = 60 + math.sin(t * 3) * 25
    surface.SetDrawColor(80, 170, 255, pulse)
    surface.DrawOutlinedRect(0, 0, w, h, 2)

    surface.SetDrawColor(40, 120, 255, 10)
    for i = 1, 6 do
        local y = ((t * 80 + i * 120) % h)
        surface.DrawRect(0, y, w, 2)
    end

    frame.Bolts = {}

    for i = 1, 8 do
        table.insert(frame.Bolts, {
            x1 = math.random(0, 850),
            y1 = math.random(0, 900),
            x2 = math.random(0, 850),
            y2 = math.random(0, 900),
            life = CurTime() + math.Rand(0, 2)
        })
    end

    surface.SetDrawColor(120, 220, 255, 180)

    for _, b in ipairs(self.Bolts) do

        if CurTime() > (b.next or 0) then
            b.x1 = math.random(0, w)
            b.y1 = math.random(0, h)
            b.x2 = b.x1 + math.random(-120, 120)
            b.y2 = b.y1 + math.random(-120, 120)
            b.next = CurTime() + math.Rand(0.05, 0.25)
        end

        local jx = math.random(-2, 2)
        local jy = math.random(-2, 2)

        surface.DrawLine(
            b.x1 + jx,
            b.y1 + jy,
            b.x2 + jx,
            b.y2 + jy
        )
    end

    local scan = (t * 200) % h
    surface.SetDrawColor(100, 200, 255, 25)
    surface.DrawRect(0, scan, w, 3)

    draw.RoundedBoxEx(12, 0, 0, w, 60, Color(60, 120, 255, 220), true, true, false, false)

    draw.SimpleText(
        "OUTCOME MEMORIES",
        "Trebuchet24",
        20,
        30,
        color_white,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )
end

    local close = vgui.Create("DButton", frame)
    close:SetSize(40, 40)
    close:SetText("")

    close.Think = function(self)
        local parent = self:GetParent()
        self:SetPos(parent:GetWide() - self:GetWide() - 10, 10)
    end

    close.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(220, 70, 70) or Color(180, 60, 60)
        draw.RoundedBox(8, 0, 0, w, h, col)

        draw.SimpleText(
            "✕",
            "Trebuchet24",
            w / 2,
            h / 2,
            color_white,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end

    close.DoClick = function()
        frame:Close()
    end

    local content = vgui.Create("DScrollPanel", frame)
    content:Dock(FILL)

    content:DockMargin(10, 10, 10, 10)



    content.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 42, 220))
        --[[
        draw.SimpleText(
            "Content goes here...",
            "Trebuchet24",
            w / 2,
            h / 2,
            Color(220, 220, 220),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
        ]]
    end

    frame.CatalogItems = {}

    function frame:AddCatalogItem(imagePath, title, bio)

        local item = vgui.Create("DPanel", content)
        item:Dock(TOP)
        item:DockMargin(0, 0, 0, 10)
        item:SetTall(140)

        item.Alpha = 0
        item.OffsetX = -40

        item.Paint = function(self, w, h)

            draw.RoundedBox(10, 0, 0, w, h, Color(30, 30, 38, self.Alpha))

            self.Alpha = math.Approach(self.Alpha, 255, FrameTime() * 600)
            self.OffsetX = math.Approach(self.OffsetX, 0, FrameTime() * 220)
        end

        local img = vgui.Create("DImage", item)
        img:SetSize(120, 120)

        img.Think = function(self)
            self:SetPos(10 + item.OffsetX, 10)
            self:SetAlpha(item.Alpha)
        end

        img:SetImage(imagePath or "vgui/hud/icon_error")

        if not item.TitleLabel then
            item.TitleLabel = vgui.Create("DLabel", item)
            item.TitleLabel:SetFont("Trebuchet24")
            item.TitleLabel:SetTextColor(Color(220, 220, 255))
            item.TitleLabel:SetWrap(true)
            item.TitleLabel:SetAutoStretchVertical(true)
            item.TitleLabel:SetContentAlignment(7)
        end

        item.TitleLabel:SetText(title or "Unknown Item")

        item.TitleLabel.Think = function(self)
            self:SetAlpha(item.Alpha)

            self:SetPos(140 + item.OffsetX, 10)
            self:SetSize(500, 40)
        end

        if not item.BioLabel then
            item.BioLabel = vgui.Create("DLabel", item)
            item.BioLabel:SetFont("Trebuchet18")
            item.BioLabel:SetTextColor(Color(200, 200, 200))
            item.BioLabel:SetWrap(true)
            item.BioLabel:SetAutoStretchVertical(true)
            item.BioLabel:SetContentAlignment(7)
        end

        item.BioLabel:SetText(bio or "No description available.")

        item.BioLabel.Think = function(self)
            self:SetAlpha(item.Alpha)

            self:SetPos(140 + item.OffsetX, 45)
            self:SetSize(500, 90)
        end

        return item
    end

    function OpenImageRegister(imagePath, holdTime)

        if IsValid(OM_ImageRegister) then
            OM_ImageRegister:Remove()
        end

        local frame = vgui.Create("DPanel")
        OM_ImageRegister = frame

        frame:SetSize(ScrW(), ScrH())
        frame:MakePopup()
        frame:SetKeyboardInputEnabled(false)
        frame:SetMouseInputEnabled(false)

        frame.Alpha = 0
        frame.Scale = 0.7
        frame.ScanY = 0

        frame.StartTime = CurTime()
        frame.HoldTime = holdTime or 2.5

        local img = vgui.Create("DImage", frame)
        img:SetImage(imagePath or "vgui/hud/icon_error")

        img.Paint = function(self, w, h)

            local fw, fh = ScrW(), ScrH()

            frame.Alpha = math.Approach(frame.Alpha, 220, FrameTime() * 500)

            frame.Scale = math.Approach(frame.Scale, 1, FrameTime() * 2.5)

            frame.ScanY = (frame.ScanY + FrameTime() * 400) % fh

            surface.SetDrawColor(0, 0, 0, frame.Alpha)
            surface.DrawRect(0, 0, fw, fh)

            local size = math.min(fw, fh) * frame.Scale
            local x = fw / 2 - size / 2
            local y = fh / 2 - size / 2

            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Material(imagePath or "vgui/hud/icon_error"))
            surface.DrawTexturedRect(x, y, size, size)

            surface.SetDrawColor(100, 200, 255, 30)
            surface.DrawRect(0, frame.ScanY, fw, 3)

            if math.random(1, 20) == 1 then
                surface.SetDrawColor(255, 255, 255, 20)
                surface.DrawRect(0, 0, fw, fh)
            end

            if CurTime() > frame.StartTime + frame.HoldTime then
                frame.Alpha = math.Approach(frame.Alpha, 0, FrameTime() * 600)
                frame.Scale = math.Approach(frame.Scale, 1.2, FrameTime() * 2)

                if frame.Alpha <= 5 then
                    frame:Remove()
                    OM_ImageRegister = nil
                end
            end
        end
    end

    function frame:RegisterHeaderImage(imagePath, titleText)

        local header = vgui.Create("DPanel", content)
        header:Dock(TOP)
        header:DockMargin(0, 0, 0, 10)
        header:SetTall(260)

        header.TargetAlpha = 255
        header.Alpha = 0

        header.YOffset = -40
        header.TargetYOffset = 0

        header.Scale = 0.9
        header.TargetScale = 1

        header.ImageAlpha = 0

        header.RegisterStart = CurTime()
        header.Registering = true

        header.ImageMat = Material(imagePath or "vgui/hud/icon_error")

        header.Paint = function(self, w, h)

            if self.Registering then
                self.Alpha = math.Approach(self.Alpha, 255, FrameTime() * 900)
                self.YOffset = math.Approach(self.YOffset, 0, FrameTime() * 500)
                self.Scale = math.Approach(self.Scale, 1, FrameTime() * 6)

                if CurTime() > self.RegisterStart + 0.08 then
                    self.ImageAlpha = math.Approach(self.ImageAlpha, 255, FrameTime() * 900)
                end

                if self.Alpha >= 250 and self.YOffset <= 1 and self.Scale >= 0.99 then
                    self.Registering = false
                end

            else
                self.Alpha = 255
                self.YOffset = 0
                self.Scale = 1
                self.ImageAlpha = 255
            end

            local scale = self.Scale
            local sw, sh = w * scale, h * scale
            local x, y = (w - sw) / 2, (h - sh) / 2 + self.YOffset

            draw.RoundedBox(12, x, y, sw, sh, Color(20, 20, 28, self.Alpha))

            surface.SetDrawColor(255, 255, 255, self.ImageAlpha)
            surface.SetMaterial(self.ImageMat)

            surface.DrawTexturedRect(
                x + 5,
                y + 5,
                sw - 10,
                sh - 50
            )

            surface.SetDrawColor(0, 0, 0, 180 * (self.Alpha / 255))
            surface.DrawRect(x + 5, y + sh - 55, sw - 10, 50)

            local t = CurTime()
            surface.SetDrawColor(100, 200, 255, 20)
            surface.DrawRect(0, (t * 180) % h, w, 2)

            local title = titleText or "REGISTERED ENTRY"

            if not self.TitleLabel then
                self.TitleLabel = vgui.Create("DLabel", self)
                self.TitleLabel:SetFont("Trebuchet24")
                self.TitleLabel:SetTextColor(Color(230, 230, 255))
                self.TitleLabel:SetWrap(true)
                self.TitleLabel:SetAutoStretchVertical(true)
            end

            local textX = x + 15
            local textY = y + sh - 55
            local textW = sw - 30
            local textH = 50

            self.TitleLabel:SetPos(textX, textY)
            self.TitleLabel:SetSize(textW, textH)

            self.TitleLabel:SetText(title)
            self.TitleLabel:SetAlpha(self.Alpha)
        end

        return header
    end

    frame:RegisterHeaderImage(
        "pills/pill_om_sonic.png",
        "After 8 months of full release being in the works, it's finally released! Here's what's added, changed, or fixed."
    )

    timer.Simple(0.2,function()
        if !IsValid(frame) then return end
        frame:AddCatalogItem(
            "pills/pill_om_metalsonic.png",
            "Metal Sonic Self Destruction Bug",
            "Upon killing and getting stunned by Metal Sonic, you gain iframes permanently until you reset the server. "
        )
    end)

end

hook.Add("OnPlayerChat", "OpenTestPopup", function(ply, text)
    if ply ~= LocalPlayer() then return end
    if string.lower(text) ~= "test" then return end

    OpenTestPopup()
end)










    local _OM_ImportantPopup

    local function ShouldShowPopup()
        local cv = GetConVar("OM_pills_important_popup")
        if cv then
            return cv:GetInt() ~= 0
        end

        return LocalPlayer():GetNW2Int("OM_pills_important_popup", 1) ~= 0
    end

    local function CreateImportantPopup()
        if not IsValid(LocalPlayer()) then return end
        if not ShouldShowPopup() then return end
        if IsValid(_OM_ImportantPopup) then return end

        local frame = vgui.Create("DFrame")
        _OM_ImportantPopup = frame

        frame:SetSize(420, 180)
        frame:Center()
        frame:SetTitle("Important Settings")
        frame:MakePopup()
        frame:ShowCloseButton(false)
        frame:SetDraggable(false)

        local label = vgui.Create("DLabel", frame)
        label:SetText("Choose an option:")
        label:Dock(TOP)
        label:DockMargin(10, 10, 10, 5)
        label:SetTall(20)

        local function ClosePopup()
            if IsValid(frame) then
                frame:Close()
            end
        end

        local btn1 = vgui.Create("DButton", frame)
        btn1:Dock(TOP)
        btn1:DockMargin(10, 5, 10, 0)
        btn1:SetTall(35)
        btn1:SetText("Run Important Settings Command")

        btn1.DoClick = function()
            RunConsoleCommand("om_importantsettings_pill_command")
            ClosePopup()
        end

        local btn2 = vgui.Create("DButton", frame)
        btn2:Dock(TOP)
        btn2:DockMargin(10, 5, 10, 0)
        btn2:SetTall(35)
        btn2:SetText("Disable This Popup Forever")

        btn2.DoClick = function()
            RunConsoleCommand("OM_pills_important_popup", "0")
            ClosePopup()
        end

        local btn3 = vgui.Create("DButton", frame)
        btn3:Dock(TOP)
        btn3:DockMargin(10, 5, 10, 10)
        btn3:SetTall(35)
        btn3:SetText("Close")

        btn3.DoClick = function()
            ClosePopup()
        end
    end

    hook.Add("InitPostEntity", "OM_ShowPopupOnJoin", function()
        timer.Simple(2, function()
            if not IsValid(LocalPlayer()) then return end
            CreateImportantPopup()
        end)
    end)
end

AddCSLuaFile()


local function Include_plusCSLuaFileFolder(path)
    local files, folders = file.Find(path .. "/*", "LUA")

    for _, fileName in ipairs(files) do
        if string.EndsWith(fileName, ".lua") then
            AddCSLuaFile(path .. "/" .. fileName)
            include(path .. "/" .. fileName)
        end
    end

    for _, folderName in ipairs(folders) do
        Include_plusCSLuaFileFolder(path .. "/" .. folderName)
    end
end

--[[
]]
Include_plusCSLuaFileFolder("autorun/modeleffects/om")
Include_plusCSLuaFileFolder("autorun/client/om")


local function IncludeFolder(path)
    local files, folders = file.Find(path .. "/*", "LUA")

    for _, fileName in ipairs(files) do
        if string.EndsWith(fileName, ".lua") then
            AddCSLuaFile(path .. "/" .. fileName)
            include(path .. "/" .. fileName)
        end
    end

    for _, folderName in ipairs(folders) do
        IncludeFolder(path .. "/" .. folderName)
    end
end

AddCSLuaFile("autorun/om_settings/noodles_om_pills_settings_providedfunctions.lua")
include("autorun/om_settings/noodles_om_pills_settings_providedfunctions.lua")

IncludeFolder("autorun/om_settings/Register")

AddCSLuaFile("autorun/om_settings/noodles_om_pills_settings.lua")
include("autorun/om_settings/noodles_om_pills_settings.lua")


--[[

                if ply:GetNW2Int("Silver_RockHit", 0) >= CurTime() then return end
]]

pk_pills.packStart("Outcome memories: Survivors", "noodlesPillz_OUTCOMEMEMORIES", "icons/SurvivorsIcon.png")

local function IncludeFolder(path)
    local files, folders = file.Find(path .. "/*", "LUA")

    for _, fileName in ipairs(files) do
        if string.EndsWith(fileName, ".lua") then
            AddCSLuaFile(path .. "/" .. fileName)
            include(path .. "/" .. fileName)
        end
    end

    for _, folderName in ipairs(folders) do
        IncludeFolder(path .. "/" .. folderName)
    end
end

IncludeFolder("autorun/include/survivor")

pk_pills.packStart("Outcome memories: Executer", "noodlesPillz_OUTCOMEMEMORIES_Monsters", "icons/EXEIcon.png")

local function IncludeFolder(path)
    local files, folders = file.Find(path .. "/*", "LUA")

    for _, fileName in ipairs(files) do
        if string.EndsWith(fileName, ".lua") then
            AddCSLuaFile(path .. "/" .. fileName)
            include(path .. "/" .. fileName)
        end
    end

    for _, folderName in ipairs(folders) do
        IncludeFolder(path .. "/" .. folderName)
    end
end

IncludeFolder("autorun/include/killer")


require("om_halo")
require("om_color")
require("om_afterimage")
