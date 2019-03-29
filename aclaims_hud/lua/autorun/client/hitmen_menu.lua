
-----------------------------------------------------
AddCSLuaFile()

if(SERVER) then
	hook.Add("onHitAccepted", "NotifyOfHit", function(hitman, target, customer)
		for k, v in pairs(player.GetAll()) do
			if(v == hitman || v == customer) then return end
			DarkRP.notify(v, NOTIFY_GENERIC, 3, hitman:Name().." has accepted a hit!")
		end
	end)
	return
end

local PANEL = {}

AccessorFunc(PANEL, "hitman", "Hitman")
AccessorFunc(PANEL, "target", "Target")
AccessorFunc(PANEL, "selected", "Selected")
AccessorFunc(PANEL, "distance", "Distance")

surface.CreateFont("Hitmenu_Titlefont", {font = "Open Sans", size = ScreenScale(10)})
surface.CreateFont("Hitmenu_HitPrice", {font = "Roboto", size = ScreenScale(13)})

surface.CreateFont("Hitmenu_Display", {font = "Roboto", size = ScreenScale(9)})

function PANEL:Init()
	self.w = ScrW() / 4
	self.h = ScrH() / 2

	self:SetSize(self.w, self.h)
	self:MakePopup()

	self.smooth = 0
	self.anim = Derma_Anim("HitmenuOpenAnim", self, function(pnl)
		self.smooth = Lerp(FrameTime() * 8, self.smooth, self.h)
		pnl:SetSize(self.w, self.smooth)
		pnl:Center()
	end)
	self.anim:Start(3)

	self.Title = vgui.Create("DPanel", self)
	self.Title:Dock(TOP)
	self.Title:SetTall(self:GetTall()/14)
	self.Title.Paint = function(s, w, h)
		draw.SimpleText("Hitman", "Hitmenu_Titlefont", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.Close = vgui.Create("DButton", self.Title)
	self.Close:SetText("")
	self.Close:Dock(RIGHT)
	self.Close:DockMargin(7, 7, 7, 7)
	self.Close:InvalidateParent(true)
	self.Close:SetWide(self.Close:GetTall())
	self.Close.DoClick = function() self:Remove() end
	self.Close.Paint = function(s, w, h)
		surface.SetDrawColor(255, 0, 0, 100)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(255, 0, 0, 150)

		if(s:IsHovered()) then
			surface.SetDrawColor(255, 255, 255, 100)
		end

		surface.DrawRect(1, 1, w-2, h-2)
	end

	self.Info = vgui.Create("DPanel", self)
	self.Info:Dock(TOP)
	self.Info:DockMargin(10, 0, 10, 0)
	self.Info:SetTall(self:GetTall() / 8)
	self.Info:InvalidateParent(true)
	self.Info.Paint = function(s, w, h)
		surface.SetDrawColor(255, 255, 255, 30)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(2, 2, w-4, h-4)
	end

	self.Icon = vgui.Create("SpawnIcon", self.Info)
    self.Icon:SetDisabled(true)
    self.Icon:Dock(LEFT)
    self.Icon:DockMargin(2, 2, 2, 2)
    self.Icon.PaintOver = function(icon) icon:SetTooltip() end
    self.Icon:SetTooltip()

    self.Price = vgui.Create("DLabel", self.Info)
    self.Price:SetContentAlignment(5)
    self.Price:SetFont("Hitmenu_HitPrice")
    self.Price:SetSize(self.Info:GetWide(), self.Info:GetTall())
    self.Price:Center()

	self.Cont = vgui.Create("DPanel", self)
	self.Cont:Dock(FILL)
	self.Cont:DockMargin(10, 10, 10, 10)
	self.Cont.Paint = function(s, w, h)
		surface.SetDrawColor(255, 255, 255, 30)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(2, 2, w-4, h-4)
	end

	self.List = vgui.Create("DPanelList", self.Cont)
	self.List:Dock(FILL)
	self.List:DockMargin(2, 2, 2, 2)
	self.List:EnableVerticalScrollbar()
end

local blur = Material("pp/blurscreen")
function PANEL:Blur(amt, pnl)
	local x, y = (pnl || self):LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 3 do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

function PANEL:AddPlayers()
	if(!self.List) then return end

	local players = table.Copy(player.GetAll())

    table.sort(players, function(a, b)
        local aTeam, bTeam, aNick, bNick = team.GetName(a:Team()), team.GetName(b:Team()), string.lower(a:Nick()), string.lower(b:Nick())
        return aTeam == bTeam and aNick < bNick or aTeam < bTeam
    end)

    for k, v in pairs(players) do
    	local canRequest = hook.Call("canRequestHit", DarkRP.hooks, self:GetHitman(), LocalPlayer(), v, self:GetHitman():getHitPrice())
        if(!canRequest) then continue end

    	local line = vgui.Create("DButton")
    	line:SetText(v:Name())
    	line.Paint = function(s, w, h)
    		local c = team.GetColor(v:Team())

			surface.SetDrawColor(c.r, c.g, c.b, 200)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(c.r, c.g, c.b)

			if(s:IsHovered()) then
				surface.SetDrawColor(255, 255, 255, 10)
			end

			surface.DrawRect(2, 2, w-4, h-4)
		end

		line.DoClick = function()
			local q = Derma_Query("Call a hit on "..v:Name().."?", 
				"Confirmation", 
				"Call Hit", 
				function()
		            RunConsoleCommand("darkrp", "requesthit", v:SteamID(), self:GetHitman():UserID())
		            self:Remove()
				end, 
				"Cancel"
			)

			q.time = SysTime()

			q.Paint = function(s, w, h)
				if(!self || !IsValid(self)) then s:Remove() end

				Derma_DrawBackgroundBlur(s,s.time)
				self:Blur(3, s)

				surface.SetDrawColor(255, 255, 255, 20)
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(0, 0, 0, 170)
				surface.DrawRect(2, 2, w-4, h-4)
			end

			for k, v in pairs(q:GetChildren()) do
				if(v:GetTall() == 30) then
					for k, v in pairs(v:GetChildren()) do
						v:SetColor(Color(255, 255, 255, 255))
						v.Paint = function(s, w, h)
							surface.SetDrawColor(255, 255, 255, 20)
							surface.DrawRect(0, 0, w, h)

							surface.SetDrawColor(0, 0, 0, 170)
							surface.DrawRect(2, 2, w-4, h-4)
						end
					end
				end
			end
		end

    	self.List:AddItem(line)
    end
end

function PANEL:Think()
	if(self.anim:Active()) then self.anim:Run() end

    if(!IsValid(self:GetHitman()) || self:GetHitman():GetPos():DistToSqr(LocalPlayer():GetPos()) > self:GetDistance()) then
        self:Remove()
        return
    end

    self.Price:SetText(DarkRP.getPhrase("priceTag", DarkRP.formatMoney(self:GetHitman():getHitPrice()), ""))
end

function PANEL:PerformLayout()
	if(!self.Icon) then return end
    self.Icon:SetModel(self:GetHitman():GetModel())
end

function PANEL:Paint(w, h)
	self:Blur(3)

	surface.SetDrawColor(255, 255, 255, 20)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(0, 0, 0, 170)
	surface.DrawRect(2, 2, w-4, h-4)
end

vgui.Register("CustomHitmanMenu", PANEL, "Panel")

timer.Simple(0, function()
	local distance = GAMEMODE.Config.minHitDistance * GAMEMODE.Config.minHitDistance

	function DarkRP.openHitMenu(hitman)
		local hitMenu = vgui.Create("CustomHitmanMenu")
		hitMenu:SetHitman(hitman)
		hitMenu:AddPlayers()
		hitMenu:SetDistance(distance)
	end

	hook.Add("HUDPaint", "DrawHitOption", function()
	    hudText = hudText or GAMEMODE.Config.hudText
	    local x, y
	    local ply = LocalPlayer():GetEyeTrace().Entity

	    if IsValid(ply) and ply:IsPlayer() and ply:isHitman() and not ply:hasHit() and LocalPlayer():GetPos():DistToSqr(ply:GetPos()) < distance then
	        local pos = (ply:GetPos()+Vector(0, 0, 55)):ToScreen()

	        x, y = pos.x, pos.y + 30

	        draw.SimpleTextOutlined("Hitman", "Hitmenu_HitPrice", x, y-ScreenScale(9), Color(255, 0, 0, 255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))

	        draw.DrawNonParsedSimpleTextOutlined("Press E on me to request a hit!", "Hitmenu_Display", x, y, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
	    end

	    if LocalPlayer():isHitman() and LocalPlayer():hasHit() and IsValid(LocalPlayer():getHitTarget()) then
	        x, y = chat.GetChatBoxPos()
	        local text = DarkRP.getPhrase("current_hit", LocalPlayer():getHitTarget():Nick())
	        draw.DrawNonParsedText(text, "HUDNumber5", x + 1, y + 1, textCol1, 0)
	        draw.DrawNonParsedText(text, "HUDNumber5", x, y, textCol2, 0)
	    end
	end)
end)