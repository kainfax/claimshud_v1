
if(SERVER) then
	resource.AddFile("resource/icons/notify_generic.png")
	resource.AddFile("resource/icons/notify_error.png")
	resource.AddFile("resource/icons/notify_undo.png")
	resource.AddFile("resource/icons/notify_hint.png")
	resource.AddFile("resource/icons/notify_cleanup.png")

	return
end

if(SERVER) then
	resource.AddWorkshop("1350999699")

	return
end

local NoticeMaterial = {}

NoticeMaterial[NOTIFY_GENERIC] = Material("materials/notify_generic.png")
NoticeMaterial[NOTIFY_ERROR] = Material("materials/notify_error.png")
NoticeMaterial[NOTIFY_UNDO]= Material("materials/notify_undo.png")
NoticeMaterial[NOTIFY_HINT]= Material("materials/notify_hint.png")
NoticeMaterial[NOTIFY_CLEANUP] = Material("materials/notify_cleanup.png")

local colors = {}

colors[NOTIFY_GENERIC] = Color(52, 152, 219)
colors[NOTIFY_ERROR] = Color(231, 76, 60)
colors[NOTIFY_UNDO] = Color(230, 126, 34)
colors[NOTIFY_HINT] = Color(46, 204, 113)
colors[NOTIFY_CLEANUP] = Color(155, 89, 182)

surface.CreateFont("NPGNotify", {
	font = "Roboto",
	size = ScreenScale(8),
})

local blur = Material("pp/blurscreen")
local function DrawBlur(panel, amount)
	local x, y = panel:LocalToScreen(0, 0)
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

local PANEL = {}

function PANEL:Init()
	self.text = ""

	self.set = false

	self.Text = vgui.Create("DPanel", self)
	self.Text:Dock(FILL)
	self.Text.Paint = function(s, w, h)
		if(!self.Type) then return end

		if(!self.set && self.Length) then self.set = CurTime() + self.Length end

		if(self.set) then
			local progress = math.Remap(CurTime() - self.set, -self.Length, 0, w, 0)
			draw.RoundedBox(6, progress, 0, w, h, Color(0, 0, 0, 70))
		end

		draw.RoundedBoxEx(6, 0, 0, h, h, Color(0, 0, 0, 255), true, false, true, false)

		surface.SetDrawColor(255,255,255,255)
		draw.NoTexture()
		surface.SetMaterial(NoticeMaterial[self.Type])
		surface.DrawTexturedRect(4,4,h-8,h-8)

		w=w-h
		draw.SimpleText(self.text, "NPGNotify", h+w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function PANEL:SetText(txt)
	self.text = txt
	self:SizeToContents()
end

function PANEL:SizeToContents()
	surface.SetFont("NPGNotify")
	local w, h = surface.GetTextSize(self.text)

	h = h * 1.7
	w = w + h/2

	self:SetSize(w+h, h)

	self:InvalidateLayout()
end

function PANEL:SetLegacyType(t)
	self.Type = t
end

function PANEL:Paint(w, h)
	DrawBlur(self, 3)
	draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 150))
end

function PANEL:KillSelf()
	if(self.StartTime + self.Length < SysTime()) then
		self:Remove()
		return true
	end

	return false
end

vgui.Register("NoticePanel", PANEL, "DPanel")