if(SERVER) then
	resource.AddWorkshop("1734023605") // Remove if you're using FastDL

	return
end

/*
	Config
*/

local height = 30
local lockdown = "LOCKDOWN : RETURN BACK TO YOUR HOME"
local logotext = "Whatever Community" --- CHANGE IT TO YOUR COMMUNITY NAME AND SAVE.
local scale = 1.6


/*
	Config End
*/

surface.CreateFont("HUDMain", {font = "Roboto Bold", weight = 600, bold = true, size = ScreenScale(6)})
surface.CreateFont("AmmoPrim", {font = "Roboto Bold", size = ScreenScale(12)})
surface.CreateFont("AmmoSec", {font = "Roboto Bold", size = ScreenScale(6)})


/*--  Hide Default HUD --*/
local hideHUDElements = {
	["DarkRP_HUD"] = true, 	
	["DarkRP_PlayerInfo"] = true,
	["DarkRP_EntityDisplay"] = true,
	["DarkRP_Hungermod"] = false, // Only set to true if hungermod are active
}
/*-- Hide HUD Elements --*/
local function hideElements(name)
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudSuitPower", "CHudDeathNotice", "CHudAmmo"}) do
		if name == v then return false end
	end
	if hideHUDElements[name] then
		return false
	end
end
hook.Add("HUDShouldDraw", "hideElements", hideElements)

height = ScrH()/height
	
local lockdowncolor = Color(255, 0, 0) 
local textcolor = Color(238, 238, 238)
local logo = Material("materials/studionet.png","unlitgeneric")
local nameicon = Material("materials/player.png","unlitgeneric")
local healthicon = Material("materials/heart.png","unlitgeneric")
local armoricon = Material("materials/shield.png","unlitgeneric")
local jobicon = Material("materials/job.png","unlitgeneric")
local moneyicon = Material("materials/cash.png","unlitgeneric")
local salaryicon = Material("materials/cash2.png","unlitgeneric")
local rankicon = Material("materials/rank.png","unlitgeneric")
local lockdownicon = Material("materials/lockdownred.png","unlitgeneric")
 

 --[[surface.CreateFont( "OpenSans24", { font = "Open Sans", size = 24, weight = 600, bold = true, strikeout = false, outline = false, shadow = false, outline = false,})
    hook.Add("HUDPaint", "Lockdown", function()
     // Check if lockdown is active
    if GetGlobalBool("Darkrp_lockdown") then
        // Draw text
         draw.SimpleText("LOCKDOWN HAS BEEN INITIATED","OpenSans24", ScrW() * 0.50,ScrH() * 0.040, color_white,TEXT_ALIGN_CENTER) // Fised ScrW
         draw.SimpleText("LOCKDOWN HAS BEEN INITIATED","OpenSans24", ScrW() * 0.50,ScrH() * 0.040, Color(255,0,0, 1 + 200 * math.abs(math.sin(CurTime() * 2))),TEXT_ALIGN_CENTER) // Fised ScrW
        // 1 x icon on center of screen
        surface.SetDrawColor(Color(240,245,245))
        surface.SetMaterial(lockdownicon)
        surface.DrawTexturedRect(ScrW()/2.80, ScrH()/28, 32,32)
        surface.DrawTexturedRect(ScrW()/1.60, ScrH()/28, 32,32)
     
    end
     
    end)]]---

local function box(x, y, w, h, color)
	surface.SetDrawColor(color || Color(0, 0, 0, 150))
	surface.DrawRect(x, y, w, h)
end

local function img(x, y, w, h, mat)
	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x, y, w, h)
end

local function txt(t, x, y, f, ha, va)
	draw.SimpleText(t, f || "HUDMain", x, y, textcolor, ha || TEXT_ALIGN_CENTER, va || TEXT_ALIGN_CENTER)
end
local function lockdowntxt(t, x, y, f, ha, va)

	draw.SimpleText(t, f || "HUDMain", x, y, lockdowncolor, ha || TEXT_ALIGN_CENTER, va || TEXT_ALIGN_CENTER)
end

local function size(t, f)
	surface.SetFont(f || "HUDMain")
	return surface.GetTextSize(t)
end

local function drawBar()
	box(0, 0, ScrW(), height, Color(0, 0, 0, 200))
	box(0, height, ScrW(), height/20, Color(255, 255, 255, 255))
end

local function drawLogo(s)
	img(s, 3, height-6, height-6, logo)
	local w = size(logotext)
	txt(logotext, s+height+w/2, height/2)

	return s + height*scale + w
end

local function drawName(s)
	local name = LocalPlayer():Nick() || ""

	img(s+6, 6, height-12, height-12, nameicon)
	txt(name, s+height+size(name)/2, height/2)

	return s + height*scale + size(name)
end

local function drawHealth(s)
	local hp = (LocalPlayer():Health() || 0).."%",

	img(s+6, 6, height-12, height-12, healthicon)
	txt(hp, s+height+size(hp)/2, height/2)

	return s + height*scale + size(hp)
end

local function drawArmor(s)
	local armor = (LocalPlayer():Armor() || 0).."%"

	img(s+6, 6, height-12, height-12, armoricon)
	txt(armor, s+height+size(armor)/2, height/2)

	return s + height*scale + size(armor)
end

local function drawMoney(s)
	local muns = DarkRP.formatMoney((LocalPlayer():getDarkRPVar("money") || 0))

	img(s+6, 6, height-12, height-12, moneyicon)
	txt(muns, s+height+size(muns)/2, height/2)

	return s + height*scale + size(muns)
end

local function drawSalary(s)
	local sal = "Salary: "..DarkRP.formatMoney((LocalPlayer():getDarkRPVar("salary") || 0))

	img(s+6, 6, height-12, height-12, salaryicon)
	txt(sal, s+height+size(sal)/2, height/2)

	return s + height*scale + size(sal)
end

local function drawRank(s)
	if(true) then return s end
	local rank = LocalPlayer():GetNWString("usergroup")

	img(s+6, 6, height-12, height-12, rankicon)
	txt(rank, s+height+size(rank)/2, height/2)

	return s + height*scale + size(rank)
end

local function drawJob(s)
	local job = LocalPlayer():getDarkRPVar("job") || ""

	img(s+6, 6, height-12, height-12, jobicon)
	txt(job, s+height+size(job)/2, height/2)

	return s + height*scale + size(job)
end

local function drawTextOflockdown()
	if GetGlobalBool("DarkRP_LockDown") then
	local w, h = size(lockdown)

	lockdowntxt(lockdown, ScrW() - w/2 - (height-h), height/2)
end
end

surface.CreateFont("LawTitle", {font = "Roboto Bold", size = ScreenScale(6), weight = 400, underline = true})
surface.CreateFont("LawMain", {font = "Roboto Bold", size = ScreenScale(5.5)})

local function drawAgenda()
	local agenda = LocalPlayer():getAgendaTable() 
	if(!agenda) then return end

	local text = LocalPlayer():getDarkRPVar("agenda") or ""

	if(!text || text == "") then return end

	box(height*0.5, height*1.5, ScrW() / 5, ScrH() / 6, Color(0, 0, 0, 220))

	txt(agenda.Title, height*0.5 + ScrW()/16, height*1.8, "LawTitle")

	text = text:gsub("//", "\n"):gsub("\\n", "\n")
	text = DarkRP.textWrap(text, "LawMain", ScrW() / 8)
	draw.DrawNonParsedText(text, "LawMain", height*0.6, height*2.1, Color(255, 255, 255, 255), 0)
end

local Laws = {}
local function LawHUD()
	local totalHeight = 25
	for k, v in ipairs(Laws) do
		local replaceResult, replaceCount = string.gsub(v, "\n", "")
		totalHeight = totalHeight + 1 + (fn.ReverseArgs(string.gsub(v, "\n", "")) + 1 * ((replaceCount + 1) * 13))
	end

	local w, h = ScrW() / 5, ScrH() / 4
	local x, y = ScrW() - w - height * 0.2, height * 1.2

	draw.RoundedBox(0, x, y, w, totalHeight * 1.2 + 5, Color(33, 33, 33, 220))

	draw.SimpleText("City Ordinancies", "LawTitle", x + w/2, y+h/35, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

	local col = Color(255, 255, 255, 255)
	local lastHeight = 0
	for _,v in ipairs(Laws) do
		draw.DrawText(_ .. ") " .. v, "LawMain", x + 5, y+h/8 + lastHeight*1.2, col)
		lastHeight = lastHeight + (fn.ReverseArgs(string.gsub(v, "\n", "")) + 1) * 13
	end
end

local ammoSmooth = 0
local function drawAmmo()
	if(!IsValid(LocalPlayer():GetActiveWeapon())) then return end
	if(LocalPlayer():GetActiveWeapon():Clip1() == NULL || LocalPlayer():GetActiveWeapon() == "Camera" or LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physcannon" or LocalPlayer():GetActiveWeapon():GetClass() == "weapon_bugbait") then return end
	if(LocalPlayer():GetActiveWeapon():Clip1() == -1) then return end

	local mag1 = LocalPlayer():GetActiveWeapon():Clip1()
	local mag1width, mag1height = surface.GetTextSize(mag1)
	ammoSmooth = Lerp(8 * FrameTime(), ammoSmooth, mag1)

	local mag2 = LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType())
	local mag2width, mag2height = surface.GetTextSize(mag2)

	local maxAmmo = LocalPlayer():GetActiveWeapon():GetTable().Primary.ClipSize or 1

	local w, h =  ScrW()/16, ScrH()/18
	local x, y = ScrW() - w * 1.2, ScrH() - h * 1.2

	box(x, y, w, h, Color(0, 0, 0, 200))
	box(x, y, math.Remap(ammoSmooth, 0, maxAmmo, 0, w), h / 20, Color(255, 255, 255, 240))

	txt(mag1, x+w/2, y+h/2, "AmmoPrim", TEXT_ALIGN_RIGHT)
	txt(mag2, x+w/2, y+h/2, "AmmoSec", TEXT_ALIGN_LEFT)
end

timer.Create("LawHUDUpdate", 1, 0, function()
	local temp = DarkRP.getLaws()
	table.Empty(Laws)

	for k, v in pairs(temp) do
		local replaceResult = string.gsub(v, "\n", "")
		table.insert(Laws, DarkRP.textWrap(replaceResult, "DarkRPHUD1", ScrW() / 5))
	end
end) 

local AgendaW,AgendaH = 300,100
local function Agenda()
	local agenda = LocalPlayer():getAgendaTable()
	if not agenda then return end

	draw.RoundedBox(0, 5, HUD.H+5, AgendaW, 20, Color(0, 0, 0,250))
	draw.RoundedBoxEx(4, 5, HUD.H+25, AgendaW, AgendaH, Color(0, 0, 0, 230), false, false, true, true)

	draw.SimpleText(agenda.Title,"AgendaTitleFont",5+AgendaW/2,HUD.H+15,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	local text = LocalPlayer():getDarkRPVar("agenda") or ""

	text = text:gsub("//", "\n"):gsub("\\n", "\n")
	text = DarkRP.textWrap(text, "DarkRPHUD1", AgendaW-25)
	draw.DrawNonParsedText(text, "DarkRPHUD1", 15, HUD.H+35, Color(255, 255, 255, 255), 0)
end

hook.Add("HUDPaint", "DrawclaimsHud", function()
	local start = height/3
	drawBar()	
	drawJob(drawRank(drawSalary(drawMoney(drawArmor(drawHealth(drawName(drawLogo(start))))))))
	drawTextOflockdown()
	LawHUD()
	drawAmmo() 
	drawAgenda()
end)
