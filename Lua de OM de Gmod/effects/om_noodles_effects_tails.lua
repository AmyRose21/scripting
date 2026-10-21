local EFFECT = {}

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()

    local col = data:GetStart()
    self.Color = Color(col.x, col.y, col.z)

    self.StartSize = data:GetScale() > 0 and data:GetScale() or 16
    self.EndSize = data:GetMagnitude() > 0 and data:GetMagnitude() or 200

    self.LifeTime = data:GetRadius() > 0 and data:GetRadius() or 2
    self.DieTime = CurTime() + self.LifeTime

    self.Mat = Material("icons/tails_blast")

    self.LightningMat = Material("trails/electric")

    self.BoltLife = 0.65

    local tr = util.TraceLine({
        start = self.Pos + Vector(0, 0, 16),
        endpos = self.Pos - Vector(0, 0, 128),
        mask = MASK_SOLID_BRUSHONLY
    })

    self.Normal = tr.Hit and tr.HitNormal or Vector(0, 0, 1)

    self.Bolts = {}

    for i = 1, 56 do
        local dir = VectorRand()
        dir.z = math.abs(dir.z) * 0.35
        dir:Normalize()

        table.insert(self.Bolts, {
            Dir = dir,
            Length = math.Rand(180, 360),
            Width = math.Rand(8, 18)*2,
            SpawnTime = CurTime()
        })
    end

    local emitter = ParticleEmitter(self.Pos)

    if emitter then
        for i = 1, 55 do
            local particle = emitter:Add(
                "effects/spark",
                self.Pos
            )

            if particle then
                local dir = VectorRand()
                dir.z = math.abs(dir.z)

                particle:SetVelocity(dir * math.Rand(250, 1100))

                particle:SetDieTime(math.Rand(0.4, 1.1))

                particle:SetStartAlpha(255)
                particle:SetEndAlpha(0)

                particle:SetStartSize(math.Rand(10, 22)*0.2)
                particle:SetEndSize(math.Rand(2, 6)*0.1)

                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-40, 40))

                particle:SetColor(
                    255,
                    220,
                    40
                )

                particle:SetGravity(Vector(0, 0, -700))
                particle:SetCollide(true)
                particle:SetBounce(0.5)

                particle:SetAirResistance(120)
            end
        end

        emitter:Finish()
    end

    local dlight = DynamicLight(self:EntIndex())

    if dlight then
        dlight.pos = self.Pos
        dlight.r = 255
        dlight.g = 220
        dlight.b = 40
        dlight.brightness = 10
        dlight.Decay = 3000
        dlight.Size = 500
        dlight.DieTime = CurTime() + 0.35
    end
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = math.Clamp(
        1 - ((self.DieTime - CurTime()) / self.LifeTime),
        0,
        1
    )

    local eased = 1 - ((1 - frac) ^ 3)

    local size = Lerp(eased, self.StartSize, self.EndSize)
    local rotation = Lerp(eased, 0, -360)
    local alpha = 255 * (1 - eased)

    local centerPos = self.Pos + self.Normal * 0.5

    render.SetMaterial(self.Mat)

    render.DrawQuadEasy(
        centerPos,
        self.Normal,
        size,
        size,
        Color(255, 255, 255, alpha),
        rotation
    )

    render.SetMaterial(self.LightningMat)

    for _, bolt in ipairs(self.Bolts) do
        local boltFrac = math.Clamp(
            (CurTime() - bolt.SpawnTime) / self.BoltLife,
            0,
            1
        )

        if boltFrac < 1 then
            local boltAlpha = 255 * (1 - boltFrac)

            local currentLength = bolt.Length * boltFrac

            local startPos = centerPos
            local endPos = startPos + bolt.Dir * currentLength

            local segments = 7
            local lastPos = startPos

            for i = 1, segments do
                local t = i / segments

                local pos = LerpVector(t, startPos, endPos)
                pos = pos + VectorRand() * (18 * (1 - t))

                render.DrawBeam(
                    lastPos,
                    pos,
                    bolt.Width * (1 - t) * (1 - boltFrac),
                    0,
                    1,
                    Color(
                        255,
                        220,
                        40,
                        boltAlpha
                    )
                )

                lastPos = pos
            end
        end
    end
end

effects.Register(EFFECT, "om_tails_burst")