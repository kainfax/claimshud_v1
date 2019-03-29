--[[---------------------------------------------------------------------------

if ( !engine.IsPlayingDemo() ) then return end

local VideoSettings = engine.VideoSettings()
if ( !VideoSettings ) then return end

PrintTable( VideoSettings )

local SmoothedAng = nil
local SmoothedFOV = nil
local SmoothedPos = nil
local AutoFocusPoint = nil

hook.Add( "Initialize", "DemoRenderInit", function()

	if ( VideoSettings.frameblend < 2 ) then
		RunConsoleCommand( "pp_fb", "0" )
	else
		RunConsoleCommand( "pp_fb", "1" )
		RunConsoleCommand( "pp_fb_frames", VideoSettings.frameblend )
		RunConsoleCommand( "pp_fb_shutter", VideoSettings.fbshutter )
	end

end )

hook.Add( "RenderScene", "RenderForDemo", function ( ViewOrigin, ViewAngles, ViewFOV )

	if ( gui.IsGameUIVisible() ) then return false end

	render.Clear( 0, 0, 0, 255, true, true, true )

	local FramesPerFrame = 1

	if ( frame_blend.IsActive() ) then

		FramesPerFrame = frame_blend.RenderableFrames()
		frame_blend.AddFrame()

		if ( frame_blend.ShouldSkipFrame() ) then

			frame_blend.DrawPreview()
			return true

		end

	end

	if ( !SmoothedAng ) then SmoothedAng = ViewAngles * 1 end
	if ( !SmoothedFOV ) then SmoothedFOV = ViewFOV end
	if ( !SmoothedPos ) then SmoothedPos = ViewOrigin * 1 end
	if ( !AutoFocusPoint ) then AutoFocusPoint = SmoothedPos * 1 end

	if ( VideoSettings.viewsmooth > 0 ) then
		SmoothedAng = LerpAngle( ( 1 - VideoSettings.viewsmooth ) / FramesPerFrame, SmoothedAng, ViewAngles )
		SmoothedFOV = Lerp( ( 1 - VideoSettings.viewsmooth ) / FramesPerFrame, SmoothedFOV, ViewFOV )
	else
		SmoothedAng = ViewAngles * 1
		SmoothedFOV = ViewFOV
	end

	if ( VideoSettings.possmooth > 0 ) then
		SmoothedPos = LerpVector( ( 1 - VideoSettings.possmooth ) / FramesPerFrame, SmoothedPos, ViewOrigin )
	else
		SmoothedPos = ViewOrigin * 1
	end

	local view = {
		x				= 0,
		y				= 0,
		w				= math.Round( VideoSettings.width ),
		h				= math.Round( VideoSettings.height ),
		angles			= SmoothedAng,
		origin			= SmoothedPos,
		fov				= SmoothedFOV,
		drawhud			= false,
		drawviewmodel	= true,
		dopostprocess	= true,
		drawmonitors	= true
	}

	if ( VideoSettings.dofsteps && VideoSettings.dofpasses ) then

		local trace = util.TraceHull( {
			start	= view.origin,
			endpos	= view.origin + ( view.angles:Forward() * 8000 ),
			mins	= Vector( -2, -2, -2 ),
			maxs	= Vector( 2, 2, 2 ),
			filter	= { GetViewEntity() }
		} )

		local focuspeed = math.Clamp( ( VideoSettings.doffocusspeed / FramesPerFrame ) * 0.2, 0, 1 )
		AutoFocusPoint = LerpVector( focuspeed, AutoFocusPoint, trace.HitPos )
		local UsableFocusPoint = view.origin + view.angles:Forward() * AutoFocusPoint:Distance( view.origin )

		RenderDoF( view.origin, view.angles, UsableFocusPoint, VideoSettings.dofsize * 0.3, VideoSettings.dofsteps, VideoSettings.dofpasses, false, table.Copy( view ) )

	else

		render.RenderView( view )

	end

	-- TODO: IF RENDER HUD
	render.RenderHUD( 0, 0, view.w, view.h )

	local ShouldRecordThisFrme = frame_blend.IsLastFrame()

	if ( frame_blend.IsActive() ) then

		frame_blend.BlendFrame()
		frame_blend.DrawPreview()

	end

	if ( ShouldRecordThisFrme ) then
		menu.RecordFrame()
	end

	return true

end )


---------------------------------------------------------------------------]]
-----------------------------------------------------
if(CLIENT) then
	local dead = {}

	surface.CreateFont("KillfeedFont", {font = "Open Sans", size = ScreenScale(7)})

	timer.Simple(0, function()
		function GAMEMODE:AddDeathNotice(attacker, attackerTeam, inflictor, victim, victimTeam)
			local death = {}

			death.victim = victim
			death.victimClr = team.GetColor(victimTeam)

			death.killer = attacker
			death.killerClr = team.GetColor(attackerTeam)


			death.time = CurTime() + 5

			table.insert(dead, 0, death)
		end

		local function DrawDeath( x, y, death )
			local fadeout = ( death.time ) - CurTime()

			local text1
			local color1

			local text2
			local color2

			local text3
			local color3

			if(death.killer) then
				local ply = DarkRP.findPlayer(death.killer)

				if(ply) then
					text1 = death.killer
					color1 = death.killerClr

					text2 = " [has killed] "
					color2 = Color(150, 150, 150, 255)

					text3 = death.victim
					color3 = death.victimClr
				else
					text1 = death.victim
					color1 = death.victimClr

					text2 = " has "
					color2 = Color(150, 150, 150, 255)

					text3 = "died"
					color3 = Color(150, 150, 150, 255)
				end
			else
				text1 = death.victim
				color1 = death.victimClr

				text2 = " has "
				color2 = Color(150, 150, 150, 255)

				text3 = "committed suicide"
				color3 = Color(150, 150, 150, 255)
			end

			local alpha = math.Clamp(fadeout * 255, 0, 255)

			surface.SetFont("KillfeedFont")
			local w1 = surface.GetTextSize(text1)
			local w2 = surface.GetTextSize(text2)
			local w3 = surface.GetTextSize(text3)

			draw.SimpleText(text1, "KillfeedFont", x-w3-w2, y, Color(color1.r, color1.g, color1.b, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText(text2, "KillfeedFont", x-w3, y, Color(color2.r, color2.g, color2.b, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText(text3, "KillfeedFont", x, y, Color(color3.r, color3.g, color3.b, alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			
			return ( y + 50 * 0.4 )

		end

		local function drawNotices(x, y)
			if(GetConVarNumber("cl_drawhud") == 0) then return end

			y=y*1.2
			x=x*0.93

			x = x * ScrW()
			y = y * ScrH()
			
			-- Draw
			for k, death in pairs(dead) do
				if(death.time > CurTime()) then
					if (death.lerp) then
						x = x * 0.3 + death.lerp.x * 0.7
						y = y * 0.3 + death.lerp.y * 0.7
					end
					
					death.lerp = death.lerp or {}
					death.lerp.x = x
					death.lerp.y = y
				
					y = DrawDeath(x, y, death)
				end
			end
			
			-- We want to maintain the order of the table so instead of removing
			-- expired entries one by one we will just clear the entire table
			-- once everything is expired.
			for k, death in pairs( dead ) do
				if ( death.time > CurTime() ) then
					return
				end
			end
			
			dead = {}
		end

		hook.Add("DrawDeathNotice", "StopDefaultNotices", function(x, y) drawNotices(x, y) return false end)

	end)
end