AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Infection Projectile"
ENT.Spawnable = false

if CLIENT then
    ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

    function ENT:DrawTranslucent()
        self:DrawModel()

        local pos = self:GetPos()

        render.SetColorMaterial()

        for i = 1, 9 do
            render.DrawSphere(
                pos + VectorRand() * 15,
                self:BoundingRadius() * 0.8,
                13,
                13,
                Color(0, 0, 0, 120)
            )
        end

        render.DrawSphere(
            pos,
            self:BoundingRadius(),
            27,
            27,
            Color(0, 0, 0, 200)
        )

        local v = self

        if not v.pealoutEffectcd then
            v.pealoutEffectcd = 0
        end

        if v.pealoutEffectcd < CurTime() then
            v.pealoutEffectcd = CurTime()


            for i=1,16 do
            
                local offset = Vector(
                    math.Rand(-0,0),
                    math.Rand(-0,0),
                    math.Rand(-0,0)
                )
                
                local Emitter = ParticleEmitter(v:GetPos() +Vector(0,0,27) + offset + self:GetForward() * -10, false)

                local particlePos = v:GetPos() +Vector(0,0,27) + offset + self:GetForward() * 10

                local smoke = Emitter:Add("particle/particle_smokegrenade", particlePos)

                if smoke then
                    smoke:SetVelocity(Vector(math.Rand(-300,300),math.Rand(-300,300),math.Rand(-400,400))*1.45)
                    smoke:SetLifeTime(0)
                    smoke:SetDieTime(math.Rand(0.05,0.6)*5)
                    smoke:SetColor(0,0,0)
                    smoke:SetStartAlpha(255)
                    smoke:SetEndAlpha(0)

                    local size = math.Rand(20,25)
                    smoke:SetStartSize(size)
                    smoke:SetEndSize(size * 0)

                    smoke:SetRoll(math.Rand(-180,180))
                    smoke:SetRollDelta(math.Rand(-0.2,0.2))

                    smoke:SetAirResistance(255)
                    smoke:SetGravity(Vector(0,0,math.Rand(0,0)))
                    smoke:SetCollide(false)
                    smoke:SetLighting(false)
                end

                local glow = Emitter:Add("sprites/light_glow02_add", particlePos)

                if glow then
                    glow:SetVelocity(Vector(math.Rand(-300,300),math.Rand(-300,300),math.Rand(-400,400))*1.25)
                    glow:SetLifeTime(0)
                    glow:SetDieTime(math.Rand(0.05,0.6)*5)
                    glow:SetColor(0,0,0)
                    glow:SetStartAlpha(255)
                    glow:SetEndAlpha(0)

                    local glowSize = math.Rand(45,55)
                    glow:SetStartSize(glowSize)
                    glow:SetEndSize(glowSize * 0)

                    glow:SetRoll(math.Rand(-180,180))
                    glow:SetRollDelta(math.Rand(-0.2,0.2))

                    glow:SetAirResistance(200)
                    glow:SetGravity(Vector(0,0,0))
                    glow:SetCollide(false)
                    glow:SetLighting(false)
                end
                Emitter:Finish()
            end
        end

    end

    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:RenderOverride()
    end
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/PopCan01a.mdl")

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self:SetCollisionBounds(
            Vector(-25, -25, -25),
            Vector(25, 25, 25)
        )

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableGravity(false)
            phys:SetMass(1)
        end

        local pos = self:GetPos()

        sound.Play("ambient/energy/weld1.wav", pos, 85, 120, 0.7)
        sound.Play("physics/flesh/flesh_squishy_impact_hard4.wav", pos, 80, 80, 0.7)
        sound.Play("ambient/levels/labs/electric_explosion1.wav", pos, 90, 105, 0.7)

        timer.Simple(10, function()
            if IsValid(self) then
                self:Explode()
            end
        end)
    end

    function ENT:Launch(hitPos)
        local phys = self:GetPhysicsObject()
        if not IsValid(phys) then return end

        local dir = (hitPos - self:GetPos()):GetNormalized()
        phys:SetVelocity(dir * 9000)
    end

    function ENT:PhysicsCollide(data, phys)
        self:Explode()
    end

    function ENT:Explode()
        if self.Exploded then return end
        self.Exploded = true

        local pos = self:GetPos()
        local ply = self.OwnerPlayer
        local weapon = self.OwnerWeapon

        local effect = EffectData()
        effect:SetOrigin(pos)
        util.Effect("eyx_projectile_explode", effect, true, true)

        sound.Play("ambient/explosions/explode_4.wav", pos, 90, 85, 0.7)
        sound.Play("npc/antlion_guard/shove1.wav", pos, 80, 60, 0.7)
        sound.Play("physics/flesh/flesh_squishy_impact_hard4.wav", pos, 75, 80, 0.7)

        for _, ent2 in ipairs(ents.FindInSphere(pos, 250)) do

            if not (ent2:IsPlayer() or ent2:IsNPC() or ent2:IsNextBot()) then continue end
            if ent2:Health() <= 0 then continue end
            if ent2 == ply then continue end

            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

            if not GetConVar("PVPStun_OM_exe"):GetBool() then
                if ent2:GetNW2Bool("OM_character_monster") then continue end
            end

            if bit.band(ent2:GetFlags(), FL_NOTARGET) ~= 0 then continue end
            if not Mutal_OMCanDamage(ply, weapon, ent2) then continue end

            ent2:SetNW2Float("infectionstatus_eyx", CurTime() + 13)

            KillerdamagestunDynamic({
                ply = ply,
                target = ent2,
                DamageNumb = GetConVar("OUTCOMEMEMORIES_N_eyx_Damage_infection"):GetFloat(),
                damagetype = DMG_BLAST,
                CustomDamageSound = nil,
                damagesound = true,
                ShouldBlood = true,
                flingremoveal = true,
                ShouldBloodEffect = true
            })

            local last = CurTime() + 2
            local flung = false

            timer.Simple(0.1, function()
                flung = true
            end)

            CreateRagdolLCharacter_OM({
                target = ent2,
                host = weapon,

                shouldremove = function(rag)
                    if not IsValid(rag) then return true end
                    if not IsValid(ent2) then return true end
                    return CurTime() > last
                end,

                shoulddocustomfunction = function(rag)
                    if flung then return end
                    if not IsValid(rag) then return end
                    if not IsValid(ent2) then return end

                    local dir = (ent2:GetPos() - pos):GetNormalized()

                    for i = 0, rag:GetPhysicsObjectCount() - 1 do
                        local phys = rag:GetPhysicsObjectNum(i)

                        if IsValid(phys) then
                            phys:Wake()
                            phys:SetVelocityInstantaneous(dir * 800)
                        end
                    end
                end
            })
        end

        self:Remove()
    end
end