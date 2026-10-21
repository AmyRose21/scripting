AddCSLuaFile()
if SERVER then
	util.AddNetworkString("FleetwayBurstStart")
	util.AddNetworkString("FleetwayBurstEnd")
end

--
if CLIENT then
	
	net.Receive("FleetwayBurstStart", function()
		local ent = net.ReadEntity()
		local startPos = net.ReadVector()

		if not IsValid(ent) then return end

		if IsValid(ent:GetPuppet()) then
			ent:GetPuppet():SetNW2Float("Fleetway_body_glowwhite_burst", CurTime()+1.5)
		end

		if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then return end

		local SphereEntity_om_fleetway = ClientsideModel("models/hunter/misc/sphere075x075.mdl")
		if not IsValid(SphereEntity_om_fleetway) then return end

		SphereEntity_om_fleetway:SetPos(ent:GetPos() + Vector(0, 0, 30))
		SphereEntity_om_fleetway:SetAngles(ent:GetPuppet():GetAngles())

		SphereEntity_om_fleetway:SetNoDraw(false)
		SphereEntity_om_fleetway:SetModelScale(1, 0)


		SphereEntity_om_fleetway:SetRenderMode(RENDERMODE_TRANSCOLOR)
		SphereEntity_om_fleetway:SetColor(Color(255, 255, 255, 1))

		local start = CurTime()
		local duration = 1
		local startScale = 5
		local CurrentScale = 5
		local hookID = "ShrinkSphere_" .. SphereEntity_om_fleetway:EntIndex()
		
		hook.Add("Think", hookID, function()
			if !IsValid(ent) then
				if IsValid(SphereEntity_om_fleetway) then
					SphereEntity_om_fleetway:Remove()
				end
				hook.Remove("Think", hookID)
				hook.Remove("PostDrawTranslucentRenderables", hookID)
			end

			local t = (CurTime() - start) / duration
			t = math.Clamp(t, 0, 1)

			local scale = Lerp(t * t, startScale, 0)
			CurrentScale = scale

			SphereEntity_om_fleetway:SetModelScale(scale, 0)

			if scale <= 0.01 then
				SphereEntity_om_fleetway:Remove()
				hook.Remove("Think", hookID)
				hook.Remove("PostDrawTranslucentRenderables", hookID)
			end
		end)


		local duration = 0.85

		local function redcircle(time)

	        local ply = LocalPlayer()

	        local effectdata = EffectData()
	        effectdata:SetOrigin(SphereEntity_om_fleetway:GetPos())
	        effectdata:SetScale(time)

	        util.Effect("FleetwayBurstOutline", effectdata)
	    end

	    timer.Simple(duration / 6, function()
	        if not IsValid(ent) then return end
	    	redcircle(110)
	    end)

	    timer.Simple(duration / 5, function()
	        if not IsValid(ent) then return end
	    	redcircle(100)
	    end)

	    timer.Simple(duration / 4, function()
	        if not IsValid(ent) then return end
	    	redcircle(90)
	    end)

	    timer.Simple(duration / 3, function()
	        if not IsValid(ent) then return end
	    	redcircle(80)
	    end)

	    timer.Simple(duration / 2, function()
	        if not IsValid(ent) then return end
	    	redcircle(35)
	    end)
		


		hook.Add("PostDrawTranslucentRenderables", hookID, function()
			local ent = SphereEntity_om_fleetway
			if ent:GetNoDraw() then return end

			render.ClearStencil()

			render.SetStencilEnable(true)

			render.SetStencilWriteMask(255)
			render.SetStencilTestMask(255)

			render.SetStencilReferenceValue(1)

			render.SetStencilCompareFunction(STENCIL_ALWAYS)
			render.SetStencilPassOperation(STENCIL_REPLACE)

			cam.IgnoreZ(true)
			render.SetBlend(0)
				ent:DrawModel()
			render.SetBlend(1)
			cam.IgnoreZ(false)

			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)

			local multiplyer = 0.85

			local alpha = ent:GetColor().a / 255

			DrawColorModify({
				["$pp_colour_addr"]       = 0,
				["$pp_colour_addg"]       = 0,
				["$pp_colour_addb"]       = 0,
				["$pp_colour_brightness"] = 0.1,
				["$pp_colour_contrast"]   = 3,
				["$pp_colour_colour"]     = -1,
				["$pp_colour_mulr"]       = 0,
				["$pp_colour_mulg"]       = 0,
				["$pp_colour_mulb"]       = 0
			})
			
			DrawSharpen(
				1,
				4.0
			)

			render.SetStencilEnable(false)

		end)

	end)

	net.Receive("FleetwayBurstEnd", function()

		local ent = net.ReadEntity()
		local startPos = net.ReadVector()

		if not IsValid(ent) then return end

		local SquareEntity_om_fleetway = ClientsideModel("models/hunter/blocks/cube1x6x1.mdl")
		if not IsValid(SquareEntity_om_fleetway) then return end

		SquareEntity_om_fleetway:SetPos(ent:GetPos() + Vector(0, 0, 0))
		
		local currentangles = Angle(0,0,0)
		if IsValid(ent:GetPuppet()) then
			currentangles = ent:GetPuppet():GetAngles()
		end
        currentangles.p = 0
        currentangles.r = 0
		SquareEntity_om_fleetway:SetAngles(currentangles + Angle(0, 0, 90))

		SquareEntity_om_fleetway:SetMaterial("models/noodles/om/sonic/whiteglow")
		SquareEntity_om_fleetway:SetNoDraw(false)
		SquareEntity_om_fleetway:SetModelScale(1, 0)

		SquareEntity_om_fleetway._scanEnd = CurTime() + 3
		SquareEntity_om_fleetway._elapsed = 0
		SquareEntity_om_fleetway._duration = 1

		SquareEntity_om_fleetway._nextPillUpdate = 0

		local uid = "AnimateBone_" .. tostring(SquareEntity_om_fleetway)

		hook.Add("Think", uid, function()
			if !IsValid(SquareEntity_om_fleetway) then
				hook.Remove("Think", uid)
				return
			end

			if !IsValid(ent) then
				if IsValid(SquareEntity_om_fleetway) then
					SquareEntity_om_fleetway:Remove()
				end
				hook.Remove("Think", uid)
			end
			if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then return end

			local SquareEntity_om_fleetway = SquareEntity_om_fleetway

			if CurTime() > SquareEntity_om_fleetway._scanEnd then
				hook.Remove("Think", uid)
				return
			end

			if CurTime() > SquareEntity_om_fleetway._nextPillUpdate then
				SquareEntity_om_fleetway._nextPillUpdate = CurTime() + 0.25
			end

			SquareEntity_om_fleetway._elapsed = SquareEntity_om_fleetway._elapsed + FrameTime()

			local phase = math.max(math.sin((SquareEntity_om_fleetway._elapsed / SquareEntity_om_fleetway._duration) * math.pi), 0)
			local scale = Vector(phase * 3, 4, phase * 3)
						
			SquareEntity_om_fleetway:ManipulateBoneScale(0, scale)
		end)


		if LocalPlayer():GetInfoNum("OM_pills_important_epilepsy", 0) == 1 then
			if IsValid(SquareEntity_om_fleetway) then
				SquareEntity_om_fleetway:Remove()
			end
		end

		local explosionentity = {}
		local function createExplosionSphere(ent, alpha, scale)
			if not IsValid(ent) then return end

			local Sphere = ClientsideModel("models/hunter/misc/sphere075x075.mdl")
			if not IsValid(Sphere) then return end

			Sphere:SetPos(ent:GetPos() + Vector(0, 0, 30))
			Sphere:SetAngles(ent:GetAngles())

			Sphere:SetMaterial("models/noodles/om/spheremats/redglow")

			Sphere:SetRenderMode(RENDERMODE_TRANSALPHA)
			Sphere:SetColor(Color(255, 0, 0, 255))
			Sphere:DrawShadow(false)

			table.insert(explosionentity, Sphere)

			local startTime = CurTime()
			local duration = math.Clamp(scale * 0.4, 0.2, 1.0)

			local maxScale = scale * 6

			local hookID = "Shockwave_" .. tostring(Sphere) .. "_" .. math.random(1, 999999)

			hook.Add("Think", hookID, function()
				if not IsValid(Sphere) then
					hook.Remove("Think", hookID)
					return
				end

				if not IsValid(ent) then
					Sphere:Remove()
					hook.Remove("Think", hookID)
					return
				end

				local t = (CurTime() - startTime) / duration
				t = math.Clamp(t, 0, 1)

				local size = Lerp(t, 0, maxScale)
				Sphere:SetModelScale(size, 0)

				local col = Sphere:GetColor()
				col.a = Lerp(t, alpha, 0)
				Sphere:SetColor(col)

				if t >= 1 then
					Sphere:Remove()
					hook.Remove("Think", hookID)

					for i = #explosionentity, 1, -1 do
						if explosionentity[i] == Sphere then
							table.remove(explosionentity, i)
							break
						end
					end
				end
			end)
		end

		local currentscale = 40/4
		local CurrentAlpha = 80

		for i = 0, 3 do
			if not IsValid(ent) then return end

			local a = CurrentAlpha
			local s = currentscale

			timer.Simple(0.01 * i, function()
				if not IsValid(ent) then return end
				createExplosionSphere(ent, a, s)
			end)

			CurrentAlpha = CurrentAlpha + 45
			currentscale = currentscale * 0.75
		end

		timer.Simple(1.2,function()
			if !IsValid(ent) then return end
			SquareEntity_om_fleetway:Remove()
		end)
	end)

    hook.Add("PreRenderColor_om_plain_optimized", "fleetway_ui_OM_noodles", function()
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("fleetway_attack_glow_duration", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("fleetway_attack_glow_duration", 0)
                local duration, fade = 1.5, 0.25
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 0, 0, 255 *0.5* alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("fleetway_fatefuldrain_red", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("fleetway_fatefuldrain_red", 0)
                local duration, fade = 0.5*0.35, 0.25*0.35
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 0, 0, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("fleetwayHeal_highlight", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("fleetwayHeal_highlight", 0)
                local duration, fade = 0.5*0.35, 0.25*0.35
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(0, 255, 0, 255 * alpha)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
            	local expire = ent:GetNW2Float("Fleetway_burst_glow", 0)
	            if expire >= CurTime() then
	                om_color.Add_plaincolor({ ent = ent, color = Color(255, 255, 255, 255), ignorez = true })
	            end

				local expire1 = ent:GetNW2Float("Fleetway_body_glowwhite_burst", 0)
				local expire2 = ent:GetNW2Float("Fleetway_body_glowwhite_burst_2", 0)

				ent.Fleetway_body_glowwhite_burst = ent.Fleetway_body_glowwhite_burst or 0

				if expire1 >= CurTime() or expire2 >= CurTime() then
					ent.Fleetway_body_glowwhite_burst = Lerp(FrameTime()*4, ent.Fleetway_body_glowwhite_burst, 1)
				else
					ent.Fleetway_body_glowwhite_burst = Lerp(FrameTime()*4, ent.Fleetway_body_glowwhite_burst, 0)
				end
				
                return ent.Fleetway_body_glowwhite_burst > 0.1
            end, 
            color = function(ent)
                return Color(255, 255, 255, 255 * ent.Fleetway_body_glowwhite_burst)
            end,
            ignorez = false 
        })
        om_color.Add_plainoptimized({ 
            Canfuction = function(ent) 
                return ent:GetNW2Float("fleetway_glow_duration", 0) > CurTime()
            end, 
            color = function(ent)
                local expire = ent:GetNW2Float("fleetway_glow_duration", 0)
                local duration, fade = 0.5, 0.25
                local startTime = expire - duration
                local endTime = expire

                local alpha = 1
                if CurTime() < startTime + fade then  alpha = math.Clamp((CurTime() - startTime) / fade, 0, 1)
                elseif CurTime() > endTime - fade then alpha = math.Clamp((endTime - CurTime()) / fade, 0, 1) 
                else alpha = 1 end

                return Color(255, 255, 0, 255 * alpha)
            end,
            ignorez = false 
        })
    end)
end