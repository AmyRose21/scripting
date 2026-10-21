AddCSLuaFile()

if SERVER then
end

if CLIENT then

    hook.Add("PopulateToolMenu", "outcomememoriespillpack_noodles", function()

        local function AddColoredButton(parent, text, command, color, Image)
            local btn = parent:Button("", command)

            if IsValid(btn) then
                btn.HoverLerp = 0
                btn.PressLerp = 0
                btn.IconSpin = 0
                btn.LastHovered = false

                local fallbackMat = Material("icon16/star.png")

                local IconMat
                if Image and Image ~= "" then
                    IconMat = Material(Image, "smooth")
                else
                    IconMat = fallbackMat
                end

                btn.Paint = function(self, w, h)
                    local hovered = self:IsHovered()

                    self.HoverLerp = Lerp(FrameTime() * 10, self.HoverLerp, hovered and 1 or 0)
                    self.PressLerp = Lerp(FrameTime() * 20, self.PressLerp, self:IsDown() and 1 or 0)

                    if hovered and not self.LastHovered then
                        self.IconSpin = self.IconSpin + 360
                    end

                    self.LastHovered = hovered

                    self.IconSpin = Lerp(FrameTime() * 8, self.IconSpin, 0)

                    local glow = self.HoverLerp * 80

                    draw.RoundedBox(12, 0, 0, w, h, Color(
                        20 + glow * 0.3,
                        20 + glow * 0.3,
                        20 + glow * 0.3,
                        255
                    ))

                    surface.SetDrawColor(color.r, color.g, color.b, glow)
                    surface.DrawOutlinedRect(0, 0, w, h, 4)

                    if self.HoverLerp > 0.01 then
                        local shine = (CurTime() * 250) % (w + 100) - 100

                        surface.SetDrawColor(255,255,255,20 * self.HoverLerp)
                        draw.NoTexture()

                        surface.DrawPoly({
                            {x = shine,      y = 0},
                            {x = shine + 40, y = 0},
                            {x = shine + 80, y = h},
                            {x = shine + 40, y = h}
                        })
                    end

                    local pulse = math.sin(CurTime() * 8) * 0.5 + 0.5

                    local iconSize = 48 + pulse * 6 * self.HoverLerp

                    local iconX = 20
                    local iconY = h * 0.5

                    local float = math.sin(CurTime() * 6) * 3 * self.HoverLerp

                    if self.HoverLerp > 0.01 then
                        surface.SetMaterial(IconMat)
                        surface.SetDrawColor(
                            color.r,
                            color.g,
                            color.b,
                            80 * self.HoverLerp
                        )

                        surface.DrawTexturedRectRotated(
                            iconX,
                            iconY + float,
                            iconSize * 1.8,
                            iconSize * 1.8,
                            self.IconSpin
                        )
                    end

                    surface.SetMaterial(IconMat)
                    surface.SetDrawColor(255,255,255)

                    surface.DrawTexturedRectRotated(
                        iconX,
                        iconY + float,
                        iconSize,
                        iconSize,
                        self.IconSpin
                    )

                    local offset = self.PressLerp * 2

                    draw.SimpleText(
                        text,
                        "DermaLarge",
                        90,
                        h / 2 + offset,
                        Color(
                            math.min(color.r + glow * 0.5, 255),
                            math.min(color.g + glow * 0.5, 255),
                            math.min(color.b + glow * 0.5, 255)
                        ),
                        TEXT_ALIGN_LEFT,
                        TEXT_ALIGN_CENTER
                    )

                    local linePulse = math.sin(CurTime() * 4) * 0.5 + 0.5

                    surface.SetDrawColor(
                        color.r,
                        color.g,
                        color.b,
                        100 + linePulse * 100 + glow
                    )

                    surface.DrawRect(0, h - 4, w, 4)
                end
            end

            return btn
        end

        spawnmenu.AddToolMenuOption("LNZ addon settings","Outcome Memories Pillpack","Noodles_OM_pills_client","Preferences","","", function(panel)
            panel:ClearControls()

            panel:Help("")
            panel:Help("Mutal settings")
            for i,v in ipairs(return_OMSETTINGS()["Gameplay"]["Client"]) do AddColoredButton(panel, v.Name, v.Command, v.Color, v.Image) end

            panel:Help("")
            panel:Help("Survivor settings")
            for i,v in ipairs(return_OMSETTINGS()["Survivor"]["Client"]) do AddColoredButton(panel, v.Name, v.Command, v.Color, v.Image) end

            panel:Help("")
            panel:Help("Killers settings")
            for i,v in ipairs(return_OMSETTINGS()["Killer"]["Client"]) do AddColoredButton(panel, v.Name, v.Command, v.Color, v.Image) end

        end)


        spawnmenu.AddToolMenuOption("LNZ addon settings","Outcome Memories Pillpack","Noodles_OM_pills_server","Server Settings","","", function(panel)
            panel:ClearControls()

            panel:Help("")
            panel:Help("Mutal settings")
            for i,v in ipairs(return_OMSETTINGS()["Gameplay"]["Server"]) do AddColoredButton(panel, v.Name, v.Command, v.Color, v.Image) end

            panel:Help("")
            panel:Help("Survivor settings")

            for i,v in ipairs(return_OMSETTINGS()["Survivor"]["Server"]) do AddColoredButton(panel, v.Name, v.Command, v.Color, v.Image) end

            panel:Help("")
            panel:Help("Killers settings")
            for i,v in ipairs(return_OMSETTINGS()["Killer"]["Server"]) do AddColoredButton(panel, v.Name, v.Command, v.Color, v.Image) end

        end)


        spawnmenu.AddToolMenuOption("LNZ addon settings","Outcome Memories Pillpack","Noodles_OM_pills_important","IMPORTANT Settings","","", function(panel)
            panel:ClearControls()
            AddColoredButton(panel, "IMPORTANT settings", "om_importantsettings_pill_command", Color(175, 175, 175))
        end)

        spawnmenu.AddToolMenuOption("LNZ addon settings", "Outcome Memories Pillpack", "Noodles_OM_pills_misc", "MISC", "", "", function(panel)
            panel:ClearControls()
            panel:Help("PVP")
            panel:CheckBox("Stunning PVP","PVPStun_OM")
            panel:CheckBox("EXE PVP","PVPStun_OM_exe")
            panel:CheckBox("Clashing","PVPStun_OM_clashing")
            panel:Help("")
            panel:Help("Stuns")
            panel:CheckBox("Can do damage","Damage_OM")
            panel:CheckBox("Clashing","PVPStun_OM_clashing")
        end)         
    end)
end


