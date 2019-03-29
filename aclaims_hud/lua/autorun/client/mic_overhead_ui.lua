if(SERVER) then return end

local check = 500
local offset = Vector(0, 0, 85)

surface.CreateFont("NameFont", {font = "Roboto Bold", size = 100})
surface.CreateFont("healthFont", {font = "Roboto Bold", size = 80})
surface.CreateFont("TypingFont", {font = "Roboto Bold", size = 70})
surface.CreateFont("WantedFont", {font = "Roboto Bold", size = 120})

local voice = {}
for i=1,6 do voice[i] = Material("materials/talking-"..i..".png", "unlitgeneric") end


Material("voice/icntlk_pl"):SetFloat("$alpha", 0)
timer.Simple( 10, function() -- for thos who are realy long-loaders
	Material("voice/icntlk_pl"):SetFloat("$alpha", 0)
end)

timer.Simple( 1, function()
	hook.Remove("StartChat", "StartChatIndicator")
	hook.Remove("FinishChat", "EndChatIndicator")
end)

hook.Add("PlayerStartVoice", "ClaimsStartVoice", function(ply) ply._isTalking = true end)
hook.Add("PlayerEndVoice", "ClaimsEndVoice", function(ply) ply._isTalking = false end)

local function drawChatIndicator()
	if LocalPlayer()._isTalking then
		local fr = math.max( math.ceil(CurTime() % 1 * 10) - 4, 1 )
		surface.SetDrawColor(220,220,220)
		surface.SetMaterial(voice[fr])
		surface.DrawTexturedRect(ScrW()-100, ScrH()/2, 80, 80)
    end
end

hook.Add("HUDPaint","LuClaimsChatIndicator", drawChatIndicator)

local licenseIcon = Material("materials/gunlinc.png", "unlitgeneric")

local function getPlayerHealthStatus(ply)
	local healthFrac = ply:Health() / ply:GetMaxHealth()
	local hText = ""

	if healthFrac >= 1 then
		hText = "Healthy"
	elseif healthFrac >= 0.8 then
		hText = "Slightly Injured"
	elseif healthFrac >= 0.6 then
		hText = "Injured"
	elseif healthFrac >= 0.4 then
		hText = "Hurt"
	elseif healthFrac >= 0.01 then
		hText = "Near Death"
	end

	return hText
end

local function drawEntityDisplay(ply)
	if(!IsValid(ply)) then return end
	if(ply == LocalPlayer()) then return end
	if(LocalPlayer():InVehicle()) then return end
	if(!ply:Alive()) then return end

	local distance = LocalPlayer():GetPos():Distance(ply:GetPos())

	if(distance > check) then return end

	local ang = LocalPlayer():EyeAngles()
	local pos = ply:GetPos() + offset + ang:Up()

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)

	local name = ply:Name() || ""
	local job = ply:getDarkRPVar("job") || ""
	local hText = getPlayerHealthStatus(ply) || ""

	local alpha = math.Clamp(math.Remap(distance, check/4, check, 255, 0), 0, 255)

	cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.04)
		local clr = team.GetColor(ply:Team())
		clr = Color(clr.r, clr.g, clr.b, alpha)

		local hClr = Color(180,200,180)
		if hText == "Near Death" then
			hClr = Color(240,80,80)
		elseif hText == "Hurt" then
			hClr = Color(190,80,80)
		elseif hText == "Injured" then
			hClr = Color(93,135,101)
		elseif hText == "Slightly Injured" then
			hClr = Color(89,212,6)
		elseif hText == "Healthy" then
			hClr = Color(61,189,21)
		end

		draw.SimpleTextOutlined(name, "NameFont", 0, 0, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
		draw.SimpleTextOutlined(job, "NameFont", 0, 80, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))

		if(ply:getDarkRPVar("wanted")) then
			local cin = (math.sin(CurTime() * 8) + 1) / 2
			draw.SimpleTextOutlined("WANTED", "WantedFont", 0, -200, Color(cin * 255, 0, 255 - (cin * 255), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
		end

		if(ply:getDarkRPVar("HasGunlicense"))then
			surface.SetDrawColor(220, 220, 220, alpha)
			surface.SetMaterial(licenseIcon)
			surface.DrawTexturedRect(-80, 169, 160, 160)
        end

        local hp = math.Remap(ply:Health(), 0, 100, 0, 500)

        //surface.SetDrawColor(0, 0, 0, 255)
        //surface.DrawOutlinedRect(-251, 179, 502, 32)
        //draw.RoundedBox(0, -250, 180, 500, 30, Color(150, 0, 0, 255))
        //draw.RoundedBox(0, -hp/2, 180, hp, 30, Color(255, 0, 0, 255))

        local pos = -230
        if(ply:getDarkRPVar("wanted")) then
        	pos = -480
        end

		if(ply._isTalking)then
			local fr = math.max(math.ceil(CurTime() % 1 * 10) - 4, 1)
			surface.SetDrawColor(220, 220, 220, alpha)
			surface.SetMaterial(voice[fr])
			surface.DrawTexturedRect(-70, pos, 140, 140)
		end


		pos = 130

		draw.SimpleTextOutlined(hText, "healthFont", 0, pos + 25, hClr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))

		if(ply:getDarkRPVar("HasGunlicense")) then
			pos = 330
		end


		if(ply:IsTyping())then
			local txt = "Typing"
			local amount = math.min(math.floor(CurTime() % 1 * 10), 3)

			if(amount > 0) then
				txt = txt..("."):rep(amount)
				draw.SimpleTextOutlined(txt, "TypingFont", 0, pos + 10, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0))
			end
		end


	cam.End3D2D()
end

MsgC( Color(240, 173, 78), "[ClaimsHUD]", Color(210, 210, 210), "Loading GUIS/Hud By ", Color(240, 173, 78) ,"Claims", Color(210, 210, 210),"(STEAM_1:0:35617107)\n" )
hook.Add("PostDrawTranslucentRenderables", "DrawNameDisplay", function() for k, v in pairs(player.GetAll()) do drawEntityDisplay(v) end end)
