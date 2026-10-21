AddCSLuaFile()

ENT.Type = "anim"
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "PillUser")
    self:NetworkVar("Entity", 0, "PillEntity")
    self:NetworkVar("Entity", 1, "Puppet")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")

        local ply = self:GetPillUser()
        self:SetPos(ply:GetPos())
        self:SetParent(ply)
        self:DrawShadow(false)

        local puppet = ents.Create("pill_puppet")
        puppet:SetModel("models/hunter/misc/shell2x2.mdl")
        puppet:SetPos(ply:GetPos() + Vector(0,0,40))
        puppet:SetAngles(ply:GetAngles())
        puppet:Spawn()
        puppet:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        puppet:SetNWBool("eggman_shield_rechange", true )
        puppet:SetRenderMode(RENDERMODE_TRANSCOLOR)
        puppet:SetColor(Color(255,255,255,0))

        self:SetPuppet(puppet)
        self:DeleteOnRemove(puppet)
    end
end

function ENT:Think()
    local ply = self:GetPillUser()
    local ent = self:GetPillEntity()
    local rock = self:GetPuppet()
    local puppet = ent:GetPuppet()

    if not IsValid(ply) or not IsValid(rock) then
        self:NextThink(CurTime())
        return true
    end

    local position = Vector(0,0,50)

    if SERVER then
        rock:SetPos(puppet:GetPos() + position)
        rock:SetAngles(puppet:GetAngles())
    else
        rock:SetRenderOrigin(puppet:GetRenderOrigin() + position)
        rock:SetRenderAngles(puppet:GetRenderAngles())
    end

    self:NextThink(CurTime())
    return true
end




if CLIENT then

    local mat1 = Material("icons/Eggmanshield_texture1.png")
    local mat2 = Material("icons/Eggmanshield_texture2.png")
    local mat3 = Material("icons/Eggmanshield_texture3.png")
    local FPS = 15

    local glitches = {}

    hook.Add("PostDrawTranslucentRenderables", "eggman_shield_rechange", function()

        local ply = LocalPlayer()

        local frame = math.floor(CurTime() * FPS) % 16
        local frameX = frame % 4
        local frameY = math.floor(frame / 4)

        local u1 = frameX / 4
        local v1 = frameY / 4
        local u2 = u1 + 0.25
        local v2 = v1 + 0.25

        for _, ent in ipairs(ents.FindByClass("ent_om_eggman_display")) do
            if not IsValid(ent) then continue end
            if not IsValid(ent:GetPuppet()) then continue end

            local pos = ent:GetPuppet():GetRenderOrigin()
            local angle = ply:EyeAngles()
            pos = pos + angle:Forward()*-40

            cam.Start3D2D(pos, Angle(0, angle.y - 90, -angle.p+90), 1)
                local alpha = Lerp( (math.sin(CurTime() * 4) + 1) / 2, 100, 200 )

                surface.SetMaterial( mat1 )
                surface.SetDrawColor( 166, 178, 255, alpha )
                surface.DrawTexturedRectUV( -64, -64, 128, 128, u1, v1, u2, v2 )
            cam.End3D2D()

            if !IsValid(ent) then continue end
            glitches[ent] = glitches[ent] or {}

            local mins, maxs = Vector(-45,-45,-45), Vector(45,45,45)
            while #glitches[ent] < 40 do

                local localPos = Vector(
                    math.Rand(mins.x, maxs.x),
                    math.Rand(mins.y, maxs.y),
                    math.Rand(mins.z, maxs.z)
                ) + Vector(0,0,-15)

                table.insert(glitches[ent], {
                    offset = localPos,

                    roll = math.Rand(-360, 360),

                    scale = math.Rand(0.5, 3),

                    startTime = CurTime() + math.Rand(0, 2),
                    cooldown = math.Rand(0.2, 1)
                })
            end
            pos = pos + angle:Forward()*40

            for _, glitch in ipairs(glitches[ent]) do
                local time = CurTime() - glitch.startTime

                if time < 0 then
                    continue
                end

                local fps = 15
                local frame = math.floor(time * fps)

                if frame >= 16 then
                    glitch.startTime = CurTime() + math.Rand(0.2, 1)
                    glitch.roll = math.Rand(0, 360)

                    glitch.scale = math.Rand(0.5, 1.5)

                    glitch.offset = Vector(
                        math.Rand(mins.x, maxs.x),
                        math.Rand(mins.y, maxs.y),
                        math.Rand(mins.z, maxs.z)
                    )

                    continue
                end

                local column = frame % 4
                local row = math.floor(frame / 4)

                local u1 = column * 0.25
                local v1 = row * 0.25
                local u2 = u1 + 0.25
                local v2 = v1 + 0.25

                local size = 10 * glitch.scale

                cam.Start3D2D( pos+glitch.offset, Angle(glitch.roll, angle.y - 90, -angle.p + 90), 3)

                    surface.SetMaterial(mat2)
                    surface.SetDrawColor(201, 206, 255, 255)

                    surface.DrawTexturedRectUV(
                        -size / 2,
                        -size / 2,
                        size,
                        size,
                        u1, v1,
                        u2, v2
                    )

                cam.End3D2D()
            end


        end
    end)

end