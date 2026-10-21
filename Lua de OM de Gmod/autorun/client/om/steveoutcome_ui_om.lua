AddCSLuaFile()

        --[[
    local mat = Material("icons/steveoutcome_glitchtexture1.png")
    hook.Add("HUDPaint", "Steveoutcome_effectstestx", function()
        local size = ScreenScale(300)
        local x = ScrW() / 2 - size / 2
        local y = ScrH() / 2 - size / 2

        surface.SetMaterial(mat)
        surface.SetDrawColor(165, 0, 0, 255)

        local fps = 15
        local frame = math.floor(CurTime() * fps) % 16

        local column = (frame - 1) % 4
        local row = math.floor((frame - 1) / 4)

        local u1 = column * 0.25
        local v1 = row * 0.25
        local u2 = u1 + 0.25
        local v2 = v1 + 0.25

        surface.DrawTexturedRectUV(
            x, y,
            size, size,
            u1, v1,
            u2, v2
        )
    end)
        ]]


if CLIENT then
    local mat1 = Material("icons/steveoutcome_glitchtexture1.png")
    local mat2 = Material("icons/steveoutcome_glitchtexture2.png")
    local mat3 = Material("icons/steveoutcome_glitchtexture3.png")
    local mat4 = Material("icons/steveoutcome_glitchtexture4.png")

    local glitches = {}
    local eletricity = {}

    local eyeRain = {}

    hook.Add("PostDrawTranslucentRenderables", "Steveoutcome_effectstestx_1", function()
        for _, ent in ipairs(ents.FindByModel("models/Noodles/OM/steveoutcome.mdl")) do
            if !IsValid(ent) then continue end
            glitches[ent] = glitches[ent] or {}

            while #glitches[ent] < 7 do
                local mins, maxs = ent:OBBMins() * 0.75, ent:OBBMaxs() * 0.75

                local localPos = Vector(
                    math.Rand(mins.x, maxs.x),
                    math.Rand(mins.y, maxs.y),
                    math.Rand(mins.z, maxs.z)
                ) + Vector(0,0,-15)

                table.insert(glitches[ent], {
                    offset = localPos,

                    roll = math.Rand(-360, 360),

                    scale = math.Rand(0.5, 1.5),

                    startTime = CurTime() + math.Rand(0, 2),
                    cooldown = math.Rand(0.2, 1)
                })
            end

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

                    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()

                    glitch.offset = Vector(
                        math.Rand(mins.x, maxs.x),
                        math.Rand(mins.y, maxs.y),
                        math.Rand(mins.z, maxs.z)
                    )

                    continue
                end

                local pos = ent:LocalToWorld(glitch.offset)

                local bone = ent:LookupBone("Torso")
                local matrix = bone and ent:GetBoneMatrix(bone)

                if matrix then
                    pos = matrix:GetTranslation() + glitch.offset
                end

                local column = frame % 4
                local row = math.floor(frame / 4)

                local u1 = column * 0.25
                local v1 = row * 0.25
                local u2 = u1 + 0.25
                local v2 = v1 + 0.25

                local size = 10 * glitch.scale
                local ang = EyeAngles()

                cam.Start3D2D(
                    pos,
                    Angle(
                        glitch.roll,
                        ang.y - 90,
                        ang.p * -1 + 90
                    ),
                    3
                )

                    surface.SetMaterial(mat1)
                    surface.SetDrawColor(165, 0, 0, 255 * ent:GetColor().a)

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






            eletricity[ent] = eletricity[ent] or {}

            while #eletricity[ent] < 7 do
                local mins, maxs = ent:OBBMins()*0.75, ent:OBBMaxs()*0.75

                local localPos = Vector(
                    math.Rand(mins.x, maxs.x),
                    math.Rand(mins.y, maxs.y),
                    math.Rand(mins.z, maxs.z)
                ) + Vector(0,0,-15)

                table.insert(eletricity[ent], {
                    offset = localPos,
                    roll = math.Rand(-360, 360),
                    scale = math.Rand(0.5, 1.5),
                    startTime = CurTime() + math.Rand(0, 2),
                    cooldown = math.Rand(0.2, 1)
                })
            end

            for _, glitch in ipairs(eletricity[ent]) do
                local time = CurTime() - glitch.startTime

                if time < 0 then
                    continue
                end

                local fps = 20
                local frame = math.floor(time * fps)

                if frame >= 16 then
                    glitch.startTime = CurTime() + math.Rand(0.2, 1)
                    glitch.roll = math.Rand(0, 360)

                    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()

                    glitch.offset = Vector(
                        math.Rand(mins.x, maxs.x),
                        math.Rand(mins.y, maxs.y),
                        math.Rand(mins.z, maxs.z)
                    )

                    continue
                end

                local pos = ent:LocalToWorld(glitch.offset)
                local bone = ent:LookupBone("Torso")
                local matrix = bone and ent:GetBoneMatrix(bone)

                if matrix then
                    pos = matrix:GetTranslation() + glitch.offset
                end

                local column = frame % 4
                local row = math.floor(frame / 4)

                local u1 = column * 0.25
                local v1 = row * 0.25
                local u2 = u1 + 0.25
                local v2 = v1 + 0.25

                local size = 10 * glitch.scale
                local ang = EyeAngles()

                cam.Start3D2D(
                    pos,
                    Angle(
                        glitch.roll,
                        ang.y - 90,
                        ang.p * -1 + 90
                    ),
                    3
                )

                    surface.SetMaterial(mat2)
                    surface.SetDrawColor(165, 0, 0, 255* ent:GetColor().a)

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



            local function DrawEyeRain( bonepose)
                local bone = ent:LookupBone(bonepose)
                if not bone then return end

                local matrix = ent:GetBoneMatrix(bone)
                if not matrix then return end

                local eyePos = matrix:GetTranslation()

                eyeRain[ent] = eyeRain[ent] or {}

                while #eyeRain[ent] < 8 do
                    table.insert(eyeRain[ent], {
                        speed = math.Rand(1, 18),
                        startTime = CurTime() + math.Rand(0, 1),
                        frameOffset = math.random(0, 15)
                    })
                end

                local curTime = CurTime()
                local frameTime = math.floor(curTime * 30)

                local ang = EyeAngles()

                local drawAng = Angle(
                    0,
                    ang.y - 90,
                    -ang.p + 90
                )

                local alpha = ent:GetColor().a

                for _, rain in ipairs(eyeRain[ent]) do
                    local time = curTime - rain.startTime

                    if time < 0 then
                        continue
                    end

                    local maxDistance = 4

                    local distance = time * rain.speed

                    if distance >= maxDistance then
                        rain.startTime = curTime + math.Rand(0.2, 1)
                        rain.speed = math.Rand(8, 18)
                        rain.frameOffset = math.random(0, 15)

                        continue
                    end

                    local progress = distance / maxDistance

                    local size = Lerp(progress, 1, 8)

                    local fade = 1 - progress
                    local drawAlpha = 255 * fade * alpha

                    local worldPos = eyePos - Vector(0, 0, distance)

                    local frame = (frameTime + rain.frameOffset) % 16

                    local column = frame % 4
                    local row = math.floor(frame / 4)

                    local u = column * 0.25
                    local v = row * 0.25

                    cam.Start3D2D(
                        worldPos,
                        drawAng,
                        0.5
                    )

                        surface.SetMaterial(mat4)

                        surface.SetDrawColor(
                            165,
                            0,
                            0,
                            drawAlpha
                        )

                        surface.DrawTexturedRectUV(
                            -size / 2,
                            -size / 2,
                            size,
                            size,
                            u,
                            v,
                            u + 0.25,
                            v + 0.25
                        )

                    cam.End3D2D()
                end
            end


            local function draweye(bonepose)
                local bone = ent:LookupBone(bonepose)
                if not bone then return end

                local matrix = ent:GetBoneMatrix(bone)
                if not matrix then return end

                local pos = matrix:GetTranslation()

                local ang = EyeAngles()
                local drawAng = Angle(
                    0,
                    ang.y - 90,
                    -ang.p + 90
                )

                local frame = math.floor(CurTime() * 30)

                cam.Start3D2D(pos, drawAng, 0.5)

                    surface.SetMaterial(mat3)
                    surface.SetDrawColor(
                        255,
                        0,
                        0,
                        255 * ent:GetColor().a
                    )

                    local redSize = 6

                    for _, offset in ipairs({0, 2,4, 6, 8, 10, 12}) do
                        local f = (frame + offset) % 16

                        local column = f % 4
                        local row = math.floor(f / 4)

                        local u = column * 0.25
                        local v = row * 0.25

                        surface.DrawTexturedRectUV(
                            -redSize / 2,
                            -redSize / 2,
                            redSize,
                            redSize,
                            u,
                            v,
                            u + 0.25,
                            v + 0.25
                        )
                    end


                    surface.SetMaterial(mat3)
                    surface.SetDrawColor(
                        255,
                        255,
                        255,
                        255 * ent:GetColor().a
                    )

                    local whiteSize = 4

                    for _, offset in ipairs({0, 2,4, 6, 8, 10, 12}) do
                        local f = (frame + offset) % 16

                        local column = f % 4
                        local row = math.floor(f / 4)

                        local u = column * 0.25
                        local v = row * 0.25

                        surface.DrawTexturedRectUV(
                            -whiteSize / 2,
                            -whiteSize / 2,
                            whiteSize,
                            whiteSize,
                            u,
                            v,
                            u + 0.25,
                            v + 0.25
                        )
                    end

                cam.End3D2D()
            end


            DrawEyeRain("HRightEye")
            DrawEyeRain("HLeftEye")

            draweye("HRightEye")
            draweye("HLeftEye")


        end
    end)

    hook.Add("EntityRemoved", "Steveoutcome_effectstestx_cleanup", function(ent)
        glitches[ent] = nil
        eletricity[ent] = nil
        eyeRain[ent] = nil
    end)
end